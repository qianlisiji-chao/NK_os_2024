//#include <stdlib.h>    
#include <assert.h>    
//#include <stdint.h>    
//#include <stdbool.h>  
#include <stdio.h>     // 添加此行以使用 printf
#include<buddy.h>
#include<pmm.h>
#include <buddy.h>

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

size_t
get_exp(size_t num)
{
    size_t exp = 0;
    while (num > 1)
    {
        num >>= 1; // 右移一位，相当于除以2
        exp++;
    }
    return (size_t)(1 << exp);
}

unsigned long __clzdi2(unsigned long x) {
    unsigned long n = 0;
    if (x == 0) return 64;
    while ((x & (1UL << 63)) == 0) {
        n++;
        x <<= 1;
    }
    return n;
}



static void
buddy_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
}


static void
buddy_fit_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(PageReserved(p));
        // 清空当前页框的标志和属性信息
        p->flags = p->property = 0;
        // 将页框的引用计数设置为0
        set_page_ref(p, 0);
    }
    nr_free += n;
    // 设置base指向尚未处理内存的尾地址，从后向前初始化
    base += n;
    while (n != 0)
    {
        // 获取本轮处理内存页数
        size_t curr_n = get_exp(n);
        // 将base向前移动
        base -= curr_n;
        // 设置此时的property参数
        base->property = curr_n;
        // 标记可用
        SetPageProperty(base);
        // 我们采用按照块大小排序方式插入空闲块链表，当大小相同时的排序策略是地址
        list_entry_t *le;
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
        {
            struct Page *page = le2page(le, page_link);
            if ((page->property > base->property) || (page->property == base->property && page > base))
                break;
        }
        list_add_before(le, &(base->page_link));
        n -= curr_n;
    }
}




static struct Page *
buddy_fit_alloc_pages(size_t n)
{
    assert(n > 0);
    // 现在我们要向上取整来分配合适的内存
    size_t size = get_exp(n);
    if (size < n)
        n = 2 * size;
    if (n > nr_free)
    {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
    while ((le = list_next(le)) != &free_list)
    {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n){
            page = p;
            break;
        }
    }
    // 如果需要切割，分配切割后的前一块
    if (page != NULL)
    {
        while (page->property > n)
        {
            page->property /= 2;
            // 切割出的右边那一半内存块不用于内存分配
            struct Page *p = page + page->property;
            p->property = page->property;
            SetPageProperty(p);
            list_add_after(&(page->page_link), &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
        assert(page->property == n);
        list_del(&(page->page_link));
    }
    return page;
}

static void
buddy_fit_free_pages(struct Page *base, size_t n)
{
    assert(n > 0);
    // 回收也是同样的，现在我们要向上取整来分配合适的内存
    size_t size = get_exp(n);
    if (size < n)
        n = 2 * size;
    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    list_entry_t *le;
    // 先插入至链表中
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
    {
        p = le2page(le, page_link);
        // 这里的条件修改：与初始化策略相似
        if ((base->property < p->property) || (base->property == p->property && base < p))
            break;
    }
    list_add_before(le, &(base->page_link));
    // 合并：合并条件如下
    /*
        - 大小相同且为2的整数次幂
        - 地址相邻
        - 低地址空闲块的起始地址为块大小的整数次幂的位数
    */

    // 1、判断前面的空闲页块是否与当前页块是连续的，相同大小的，如果是连续的且是相同大小的，则将当前页块合并到前面的空闲页块中
    if ((p->property == base->property) && (p + p->property == base))
    {
        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
        p->property += base->property;
        // 3、清除当前页块的属性标记，表示不再是空闲页块
        ClearPageProperty(base);
        // 4、从链表中删除当前页块
        list_del(&(base->page_link));
        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
        base = p;
        le = &(base->page_link);
    }

    // 循环向右合并

    while (le != &free_list)
    {
        p = le2page(le, page_link);
        if ((p->property == base->property) && (base + base->property == p))
        {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
            le = &(base->page_link);
        }
        // 无法合并时，退出
        else if (base->property < p->property)
        {
            // 修改base在链表中的位置使大小相同的聚在一起
            list_entry_t *targetLe = list_next(&base->page_link);
            while (le2page(targetLe, page_link)->property < base->property)
                targetLe = list_next(targetLe);
            if (targetLe != list_next(&base->page_link))
            {
                list_del(&(base->page_link));
                list_add_before(targetLe, &(base->page_link));
            }
            // 最后退出
            break;
        }
        le = list_next(le);
    }
}














/*
static void
buddy_fit_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(PageReserved(p));
        // 清空当前页框的标志和属性信息
        p->flags = p->property = 0;
        // 将页框的引用计数设置为0
        set_page_ref(p, 0);
    }
    nr_free += n;
    // 设置base指向尚未处理内存的尾地址，从后向前初始化
    base += n;
    while (n != 0)
    {
        // 获取本轮处理内存页数
        size_t curr_n = 1;
        for(int i=0;i<fixsize(n)-1;i++){
            curr_n*=2;
        }
        // 将base向前移动
        base -= curr_n;
        // 设置此时的property参数
        base->property = curr_n;
        // 标记可用
        SetPageProperty(base);
        // 我们采用按照块大小排序方式插入空闲块链表，当大小相同时的排序策略是地址
        list_entry_t *le;
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
        {
            struct Page *page = le2page(le, page_link);
            if ((page->property > base->property) || (page->property == base->property && page > base))
                break;
        }
        list_add_before(le, &(base->page_link));
        n -= curr_n;
    }
        cprintf("1\n");
}


static struct Page *
buddy_fit_alloc_pages(size_t n) {
    assert(n > 0);
    
    list_entry_t *le1;
    struct Page *page1 = NULL;
    for(le1 = list_next(&free_list); le1 != &free_list; le1 = list_next(le1))
    {
        page1 = le2page(le1, page_link);
    }    
    //buddy系统最大能分配的空间由最大的节点决定，而非整体空闲块数
    if(page1->property < n )
    {
    	return NULL;
    } 
   
    size_t op = fixsize(n);//得到n的最高二次幂
    size_t size=1;//得到应该分配给n的空间
    for(int i=0;i<op;i++){
        size *=2;
    }
    list_entry_t *le = &free_list;
    struct Page *page = NULL;
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
    while ((le = list_next(le)) != &free_list)
    {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n){
            page = p;
            break;
        }
    }
    // 如果需要切割，分配切割后的前一块
    while (page->property > size)
    {
    	page->property /= 2;
            // 切割出的右边那一半内存块不用于内存分配
            struct Page *p = page + page->property;
            p->property = page->property;
            SetPageProperty(p);
            list_add_after(&(page->page_link), &(p->page_link));
    }
    nr_free -= size;
    ClearPageProperty(page);
    assert(page->property == size);
    list_del(&(page->page_link));
    return page;
}


static void
buddy_fit_free_pages(struct Page *base, size_t n)
{
    assert(n > 0);
    size_t op = fixsize(n);//得到n的最高二次幂
    size_t size=1;
    for(int i=0;i<op;i++){
    size *=2;
    }

    struct Page *p = base;
    for (; p != base + size; p++)
    {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
    base->property = size;
    SetPageProperty(base);
    nr_free += size;
    list_entry_t *le = list_next(&free_list); // 初始化 le

// 先插入至链表中
for (; le != &free_list; le = list_next(le))
{
    p = le2page(le, page_link);
    // 这里的条件修改：与初始化策略相似
    if ((base->property < p->property) || (base->property == p->property && base < p))
        break;
}
list_add_before(le, &(base->page_link));

// 合并逻辑...
// 1、判断前面的空闲页块是否与当前页块是连续的，相同大小的，如果是连续的且是相同大小的，则将当前页块合并到前面的空闲页块中
if ((p->property == base->property) && (p + p->property == base))
{
    // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
    p->property += base->property;
    // 3、清除当前页块的属性标记，表示不再是空闲页块
    ClearPageProperty(base);
    // 4、从链表中删除当前页块
    list_del(&(base->page_link));
    // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
    base = p;
    le = &(base->page_link);
}

// 循环向右合并
while (le != &free_list)
{
    p = le2page(le, page_link);
    if ((p->property == base->property) && (base + base->property == p))
    {
        base->property += p->property;
        ClearPageProperty(p);
        list_del(&(p->page_link));
        le = &(base->page_link);
    }
    // 无法合并时，退出
    else if (base->property < p->property)
    {
        // 修改 base 在链表中的位置使大小相同的聚在一起
        list_entry_t *targetLe = list_next(&base->page_link);
        while (le2page(targetLe, page_link)->property < base->property)
            targetLe = list_next(targetLe);
        if (targetLe != list_next(&base->page_link))
        {
            list_del(&(base->page_link));
            list_add_before(targetLe, &(base->page_link));
        }
        // 最后退出
        break;
    }
    le = list_next(le);
}

}

*/
static void basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    
    // 分配页面
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    // 确保它们是不同的页面
    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    // 确保页面地址在有效范围内
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    // 保存当前状态
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // 检查无可用页面
    assert(alloc_page() == NULL);

    // 释放页面
    free_page(p0);
    free_page(p1);
    free_page(p2);
    nr_free += 3;  // 更新可用页面计数

    // 再次分配页面
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    
    // 再次检查无可用页面
    assert(alloc_page() == NULL);

    // 确保 p0 被成功释放，并且链表不为空
    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    // 确保分配的页面是 p0
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    // 还原状态
    free_list = free_list_store;
    nr_free = nr_free_store;

    // 最后释放页面
    free_page(p);
    free_page(p1);
    free_page(p2);
}


static void buddy_fit_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    // 遍历空闲链表
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count++, total += p->property;
    }
    assert(total == nr_free_pages());

    // 调用基本检查
    //basic_check();

    struct Page *p0 = alloc_pages(26), *p1;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    // 清空空闲列表
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    unsigned int nr_free_store = nr_free;
    nr_free = 0;
    
    // 检查无可用页面
    assert(alloc_page() == NULL);

    // 释放页面
    free_pages(p0, 26);
    
    // 检查对齐
    p0 = alloc_pages(6);
    p1 = alloc_pages(10);
    assert((p0 + 8)->property == 8);
    free_pages(p1, 10);
    assert((p0 + 8)->property == 8);
    assert(p1->property == 16);
    
    p1 = alloc_pages(16);
    free_pages(p0, 6);
    assert(p0->property == 16);
    free_pages(p1, 16);
    assert(p0->property == 32);

    // 更多页面分配和释放测试
    p0 = alloc_pages(8);
    p1 = alloc_pages(9);
    free_pages(p1, 9);
    assert(p1->property == 16);
    assert((p0 + 8)->property == 8);
    free_pages(p0, 8);
    assert(p0->property == 32);

    // 检查链表顺序
    p0 = alloc_pages(5);
    p1 = alloc_pages(16);
    free_pages(p1, 16);
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
    free_pages(p0, 5);
    assert(list_next(&(free_list)) == &(p0->page_link));

    // 还原状态
    p0 = alloc_pages(26);
    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 26);

    // 检查链表一致性
    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
  
}


static size_t
buddy_fit_nr_free_pages(void)
{
    return nr_free;
}
//这个结构体在
const struct pmm_manager buddy_fit_pmm_manager = {
    .name = "buddy_fit_pmm_manager",
    .init = buddy_fit_init,
    .init_memmap = buddy_fit_init_memmap,
    .alloc_pages = buddy_fit_alloc_pages,
    .free_pages = buddy_fit_free_pages,
    .nr_free_pages = buddy_fit_nr_free_pages,
    .check = buddy_fit_check,
};

