#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>
#include <pmm.h>

extern list_entry_t pra_list_head,*curr_ptr;

static int _lru_update_pages(struct mm_struct *mm, struct Page *page);

//初始化
static int _lru_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;

    return 0;
}

//设置为可交换的
static int _lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
    
    assert(entry != NULL && head != NULL);

    list_add(head, entry);
    //判断访问页是否在链表中
    //_lru_update_pages(mm,page);

    return 0;
}

//换页，删除链表尾部的即可
static int _lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);

    curr_ptr = list_prev(head);

    //防止链表为空
    if (curr_ptr != head) 
    {
        //删除链表尾部的页面
        list_del(curr_ptr);
        *ptr_page = le2page(curr_ptr, pra_page_link);
    } 
    else 
    {
        *ptr_page = NULL;
    }
    return 0;
}

//更新页面，在访问时将其更新
static int _lru_update_pages(struct mm_struct *mm, struct Page *page)
{
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    list_entry_t *entry = &(page->pra_page_link);

    assert(entry != NULL && head != NULL);

    // 遍历链表，检查是否存在访问的页面
    curr_ptr = head->next;
    while(curr_ptr!=head) 
    {
        struct Page *curr_page = le2page(curr_ptr, pra_page_link);
        if (curr_page == page) 
        {
            break;  // 找到页面，退出循环
        }
        curr_ptr = curr_ptr->next;
    }

    // 页面不存在于链表中
    if (curr_ptr == head) 
    {
        return 0;
    }

    // 页面已经在链表头部
    if (entry->prev == head) 
    {
        return 0;
    }

    // 从链表中删除页面
    list_del(entry);


    // 将页面插入到链表头部
    list_add(head, entry);
    return 0;
}

//检验是否正确
static int _lru_check_swap(void) 
{
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==7);
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==8);
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==9);
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==10);
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==11);
    return 0;
}

static int _lru_init(void)
{
    return 0;
}

static int _lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int _lru_tick_event(struct mm_struct *mm)
{ 
    return 0; 
}


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
