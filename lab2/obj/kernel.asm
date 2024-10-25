
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	161010ef          	jal	ra,ffffffffc02019aa <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	96e50513          	addi	a0,a0,-1682 # ffffffffc02019c0 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	26e010ef          	jal	ra,ffffffffc02012d4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	42e010ef          	jal	ra,ffffffffc02014d4 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	3f8010ef          	jal	ra,ffffffffc02014d4 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	8a450513          	addi	a0,a0,-1884 # ffffffffc02019e0 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201a00 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	85e58593          	addi	a1,a1,-1954 # ffffffffc02019bc <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201a20 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0201a40 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201a60 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201a80 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	8e660613          	addi	a2,a2,-1818 # ffffffffc0201ab0 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201ac8 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0201ae0 <etext+0x124>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	91258593          	addi	a1,a1,-1774 # ffffffffc0201b00 <etext+0x144>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	91250513          	addi	a0,a0,-1774 # ffffffffc0201b08 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	91460613          	addi	a2,a2,-1772 # ffffffffc0201b18 <etext+0x15c>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	93458593          	addi	a1,a1,-1740 # ffffffffc0201b40 <etext+0x184>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201b08 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	93060613          	addi	a2,a2,-1744 # ffffffffc0201b50 <etext+0x194>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	94858593          	addi	a1,a1,-1720 # ffffffffc0201b70 <etext+0x1b4>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	8d850513          	addi	a0,a0,-1832 # ffffffffc0201b08 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	91650513          	addi	a0,a0,-1770 # ffffffffc0201b80 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201ba8 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	976c0c13          	addi	s8,s8,-1674 # ffffffffc0201c18 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	92690913          	addi	s2,s2,-1754 # ffffffffc0201bd0 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	92648493          	addi	s1,s1,-1754 # ffffffffc0201bd8 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	924b0b13          	addi	s6,s6,-1756 # ffffffffc0201be0 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	83ca0a13          	addi	s4,s4,-1988 # ffffffffc0201b00 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	586010ef          	jal	ra,ffffffffc0201856 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	932d0d13          	addi	s10,s10,-1742 # ffffffffc0201c18 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	682010ef          	jal	ra,ffffffffc0201976 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	66e010ef          	jal	ra,ffffffffc0201976 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	64e010ef          	jal	ra,ffffffffc0201994 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	610010ef          	jal	ra,ffffffffc0201994 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	86250513          	addi	a0,a0,-1950 # ffffffffc0201c00 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	88650513          	addi	a0,a0,-1914 # ffffffffc0201c60 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	6b850513          	addi	a0,a0,1720 # ffffffffc0201aa8 <etext+0xec>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	504010ef          	jal	ra,ffffffffc0201924 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	85250513          	addi	a0,a0,-1966 # ffffffffc0201c80 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	4de0106f          	j	ffffffffc0201924 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	4ba0106f          	j	ffffffffc020190a <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	4ea0106f          	j	ffffffffc020193e <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	82250513          	addi	a0,a0,-2014 # ffffffffc0201ca0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	82a50513          	addi	a0,a0,-2006 # ffffffffc0201cb8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	83450513          	addi	a0,a0,-1996 # ffffffffc0201cd0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	83e50513          	addi	a0,a0,-1986 # ffffffffc0201ce8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	84850513          	addi	a0,a0,-1976 # ffffffffc0201d00 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	85250513          	addi	a0,a0,-1966 # ffffffffc0201d18 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	85c50513          	addi	a0,a0,-1956 # ffffffffc0201d30 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	86650513          	addi	a0,a0,-1946 # ffffffffc0201d48 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	87050513          	addi	a0,a0,-1936 # ffffffffc0201d60 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	87a50513          	addi	a0,a0,-1926 # ffffffffc0201d78 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	88450513          	addi	a0,a0,-1916 # ffffffffc0201d90 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	88e50513          	addi	a0,a0,-1906 # ffffffffc0201da8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	89850513          	addi	a0,a0,-1896 # ffffffffc0201dc0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	8a250513          	addi	a0,a0,-1886 # ffffffffc0201dd8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0201df0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201e08 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	8c050513          	addi	a0,a0,-1856 # ffffffffc0201e20 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201e38 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	8d450513          	addi	a0,a0,-1836 # ffffffffc0201e50 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201e68 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0201e80 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201e98 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0201eb0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	90650513          	addi	a0,a0,-1786 # ffffffffc0201ec8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	91050513          	addi	a0,a0,-1776 # ffffffffc0201ee0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	91a50513          	addi	a0,a0,-1766 # ffffffffc0201ef8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	92450513          	addi	a0,a0,-1756 # ffffffffc0201f10 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201f28 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	93850513          	addi	a0,a0,-1736 # ffffffffc0201f40 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	94250513          	addi	a0,a0,-1726 # ffffffffc0201f58 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201f70 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	95250513          	addi	a0,a0,-1710 # ffffffffc0201f88 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	95650513          	addi	a0,a0,-1706 # ffffffffc0201fa0 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	95650513          	addi	a0,a0,-1706 # ffffffffc0201fb8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201fd0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	96650513          	addi	a0,a0,-1690 # ffffffffc0201fe8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0202000 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	a3070713          	addi	a4,a4,-1488 # ffffffffc02020e0 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	9b650513          	addi	a0,a0,-1610 # ffffffffc0202078 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	98c50513          	addi	a0,a0,-1652 # ffffffffc0202058 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	94250513          	addi	a0,a0,-1726 # ffffffffc0202018 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0202098 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	9b050513          	addi	a0,a0,-1616 # ffffffffc02020c0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	91e50513          	addi	a0,a0,-1762 # ffffffffc0202038 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	98450513          	addi	a0,a0,-1660 # ffffffffc02020b0 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc020081e:	715d                	addi	sp,sp,-80
ffffffffc0200820:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200822:	00005417          	auipc	s0,0x5
ffffffffc0200826:	7ee40413          	addi	s0,s0,2030 # ffffffffc0206010 <free_area>
ffffffffc020082a:	641c                	ld	a5,8(s0)
ffffffffc020082c:	e486                	sd	ra,72(sp)
ffffffffc020082e:	fc26                	sd	s1,56(sp)
ffffffffc0200830:	f84a                	sd	s2,48(sp)
ffffffffc0200832:	f44e                	sd	s3,40(sp)
ffffffffc0200834:	f052                	sd	s4,32(sp)
ffffffffc0200836:	ec56                	sd	s5,24(sp)
ffffffffc0200838:	e85a                	sd	s6,16(sp)
ffffffffc020083a:	e45e                	sd	s7,8(sp)
ffffffffc020083c:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020083e:	26878b63          	beq	a5,s0,ffffffffc0200ab4 <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200842:	4481                	li	s1,0
ffffffffc0200844:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200846:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020084a:	8b09                	andi	a4,a4,2
ffffffffc020084c:	26070863          	beqz	a4,ffffffffc0200abc <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200850:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200854:	679c                	ld	a5,8(a5)
ffffffffc0200856:	2905                	addiw	s2,s2,1
ffffffffc0200858:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085a:	fe8796e3          	bne	a5,s0,ffffffffc0200846 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020085e:	89a6                	mv	s3,s1
ffffffffc0200860:	23b000ef          	jal	ra,ffffffffc020129a <nr_free_pages>
ffffffffc0200864:	33351c63          	bne	a0,s3,ffffffffc0200b9c <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200868:	4505                	li	a0,1
ffffffffc020086a:	1b3000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc020086e:	8a2a                	mv	s4,a0
ffffffffc0200870:	36050663          	beqz	a0,ffffffffc0200bdc <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200874:	4505                	li	a0,1
ffffffffc0200876:	1a7000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc020087a:	89aa                	mv	s3,a0
ffffffffc020087c:	34050063          	beqz	a0,ffffffffc0200bbc <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200880:	4505                	li	a0,1
ffffffffc0200882:	19b000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200886:	8aaa                	mv	s5,a0
ffffffffc0200888:	2c050a63          	beqz	a0,ffffffffc0200b5c <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020088c:	253a0863          	beq	s4,s3,ffffffffc0200adc <best_fit_check+0x2be>
ffffffffc0200890:	24aa0663          	beq	s4,a0,ffffffffc0200adc <best_fit_check+0x2be>
ffffffffc0200894:	24a98463          	beq	s3,a0,ffffffffc0200adc <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200898:	000a2783          	lw	a5,0(s4)
ffffffffc020089c:	26079063          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
ffffffffc02008a0:	0009a783          	lw	a5,0(s3)
ffffffffc02008a4:	24079c63          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
ffffffffc02008a8:	411c                	lw	a5,0(a0)
ffffffffc02008aa:	24079963          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008ae:	00006797          	auipc	a5,0x6
ffffffffc02008b2:	b927b783          	ld	a5,-1134(a5) # ffffffffc0206440 <pages>
ffffffffc02008b6:	40fa0733          	sub	a4,s4,a5
ffffffffc02008ba:	870d                	srai	a4,a4,0x3
ffffffffc02008bc:	00002597          	auipc	a1,0x2
ffffffffc02008c0:	f445b583          	ld	a1,-188(a1) # ffffffffc0202800 <error_string+0x38>
ffffffffc02008c4:	02b70733          	mul	a4,a4,a1
ffffffffc02008c8:	00002617          	auipc	a2,0x2
ffffffffc02008cc:	f4063603          	ld	a2,-192(a2) # ffffffffc0202808 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008d0:	00006697          	auipc	a3,0x6
ffffffffc02008d4:	b686b683          	ld	a3,-1176(a3) # ffffffffc0206438 <npage>
ffffffffc02008d8:	06b2                	slli	a3,a3,0xc
ffffffffc02008da:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008dc:	0732                	slli	a4,a4,0xc
ffffffffc02008de:	22d77f63          	bgeu	a4,a3,ffffffffc0200b1c <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e2:	40f98733          	sub	a4,s3,a5
ffffffffc02008e6:	870d                	srai	a4,a4,0x3
ffffffffc02008e8:	02b70733          	mul	a4,a4,a1
ffffffffc02008ec:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02008ee:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008f0:	3ed77663          	bgeu	a4,a3,ffffffffc0200cdc <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f4:	40f507b3          	sub	a5,a0,a5
ffffffffc02008f8:	878d                	srai	a5,a5,0x3
ffffffffc02008fa:	02b787b3          	mul	a5,a5,a1
ffffffffc02008fe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200900:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200902:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200cbc <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200906:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200908:	00043c03          	ld	s8,0(s0)
ffffffffc020090c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200910:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200914:	e400                	sd	s0,8(s0)
ffffffffc0200916:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200918:	00005797          	auipc	a5,0x5
ffffffffc020091c:	7007a423          	sw	zero,1800(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200920:	0fd000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200924:	36051c63          	bnez	a0,ffffffffc0200c9c <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200928:	4585                	li	a1,1
ffffffffc020092a:	8552                	mv	a0,s4
ffffffffc020092c:	12f000ef          	jal	ra,ffffffffc020125a <free_pages>
    free_page(p1);
ffffffffc0200930:	4585                	li	a1,1
ffffffffc0200932:	854e                	mv	a0,s3
ffffffffc0200934:	127000ef          	jal	ra,ffffffffc020125a <free_pages>
    free_page(p2);
ffffffffc0200938:	4585                	li	a1,1
ffffffffc020093a:	8556                	mv	a0,s5
ffffffffc020093c:	11f000ef          	jal	ra,ffffffffc020125a <free_pages>
    assert(nr_free == 3);
ffffffffc0200940:	4818                	lw	a4,16(s0)
ffffffffc0200942:	478d                	li	a5,3
ffffffffc0200944:	32f71c63          	bne	a4,a5,ffffffffc0200c7c <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200948:	4505                	li	a0,1
ffffffffc020094a:	0d3000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc020094e:	89aa                	mv	s3,a0
ffffffffc0200950:	30050663          	beqz	a0,ffffffffc0200c5c <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200954:	4505                	li	a0,1
ffffffffc0200956:	0c7000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc020095a:	8aaa                	mv	s5,a0
ffffffffc020095c:	2e050063          	beqz	a0,ffffffffc0200c3c <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200960:	4505                	li	a0,1
ffffffffc0200962:	0bb000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200966:	8a2a                	mv	s4,a0
ffffffffc0200968:	2a050a63          	beqz	a0,ffffffffc0200c1c <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc020096c:	4505                	li	a0,1
ffffffffc020096e:	0af000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200972:	28051563          	bnez	a0,ffffffffc0200bfc <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200976:	4585                	li	a1,1
ffffffffc0200978:	854e                	mv	a0,s3
ffffffffc020097a:	0e1000ef          	jal	ra,ffffffffc020125a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020097e:	641c                	ld	a5,8(s0)
ffffffffc0200980:	1a878e63          	beq	a5,s0,ffffffffc0200b3c <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200984:	4505                	li	a0,1
ffffffffc0200986:	097000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc020098a:	52a99963          	bne	s3,a0,ffffffffc0200ebc <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	08d000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200994:	50051463          	bnez	a0,ffffffffc0200e9c <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200998:	481c                	lw	a5,16(s0)
ffffffffc020099a:	4e079163          	bnez	a5,ffffffffc0200e7c <best_fit_check+0x65e>
    free_page(p);
ffffffffc020099e:	854e                	mv	a0,s3
ffffffffc02009a0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009a2:	01843023          	sd	s8,0(s0)
ffffffffc02009a6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02009aa:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02009ae:	0ad000ef          	jal	ra,ffffffffc020125a <free_pages>
    free_page(p1);
ffffffffc02009b2:	4585                	li	a1,1
ffffffffc02009b4:	8556                	mv	a0,s5
ffffffffc02009b6:	0a5000ef          	jal	ra,ffffffffc020125a <free_pages>
    free_page(p2);
ffffffffc02009ba:	4585                	li	a1,1
ffffffffc02009bc:	8552                	mv	a0,s4
ffffffffc02009be:	09d000ef          	jal	ra,ffffffffc020125a <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02009c2:	4515                	li	a0,5
ffffffffc02009c4:	059000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc02009c8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009ca:	48050963          	beqz	a0,ffffffffc0200e5c <best_fit_check+0x63e>
ffffffffc02009ce:	651c                	ld	a5,8(a0)
ffffffffc02009d0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02009d2:	8b85                	andi	a5,a5,1
ffffffffc02009d4:	46079463          	bnez	a5,ffffffffc0200e3c <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02009d8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009da:	00043a83          	ld	s5,0(s0)
ffffffffc02009de:	00843a03          	ld	s4,8(s0)
ffffffffc02009e2:	e000                	sd	s0,0(s0)
ffffffffc02009e4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02009e6:	037000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc02009ea:	42051963          	bnez	a0,ffffffffc0200e1c <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc02009ee:	4589                	li	a1,2
ffffffffc02009f0:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc02009f4:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc02009f8:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc02009fc:	00005797          	auipc	a5,0x5
ffffffffc0200a00:	6207a223          	sw	zero,1572(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200a04:	057000ef          	jal	ra,ffffffffc020125a <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200a08:	8562                	mv	a0,s8
ffffffffc0200a0a:	4585                	li	a1,1
ffffffffc0200a0c:	04f000ef          	jal	ra,ffffffffc020125a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a10:	4511                	li	a0,4
ffffffffc0200a12:	00b000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200a16:	3e051363          	bnez	a0,ffffffffc0200dfc <best_fit_check+0x5de>
ffffffffc0200a1a:	0309b783          	ld	a5,48(s3)
ffffffffc0200a1e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200a20:	8b85                	andi	a5,a5,1
ffffffffc0200a22:	3a078d63          	beqz	a5,ffffffffc0200ddc <best_fit_check+0x5be>
ffffffffc0200a26:	0389a703          	lw	a4,56(s3)
ffffffffc0200a2a:	4789                	li	a5,2
ffffffffc0200a2c:	3af71863          	bne	a4,a5,ffffffffc0200ddc <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200a30:	4505                	li	a0,1
ffffffffc0200a32:	7ea000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200a36:	8baa                	mv	s7,a0
ffffffffc0200a38:	38050263          	beqz	a0,ffffffffc0200dbc <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200a3c:	4509                	li	a0,2
ffffffffc0200a3e:	7de000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200a42:	34050d63          	beqz	a0,ffffffffc0200d9c <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200a46:	337c1b63          	bne	s8,s7,ffffffffc0200d7c <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200a4a:	854e                	mv	a0,s3
ffffffffc0200a4c:	4595                	li	a1,5
ffffffffc0200a4e:	00d000ef          	jal	ra,ffffffffc020125a <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200a52:	4515                	li	a0,5
ffffffffc0200a54:	7c8000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200a58:	89aa                	mv	s3,a0
ffffffffc0200a5a:	30050163          	beqz	a0,ffffffffc0200d5c <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200a5e:	4505                	li	a0,1
ffffffffc0200a60:	7bc000ef          	jal	ra,ffffffffc020121c <alloc_pages>
ffffffffc0200a64:	2c051c63          	bnez	a0,ffffffffc0200d3c <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200a68:	481c                	lw	a5,16(s0)
ffffffffc0200a6a:	2a079963          	bnez	a5,ffffffffc0200d1c <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200a6e:	4595                	li	a1,5
ffffffffc0200a70:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200a72:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200a76:	01543023          	sd	s5,0(s0)
ffffffffc0200a7a:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200a7e:	7dc000ef          	jal	ra,ffffffffc020125a <free_pages>
    return listelm->next;
ffffffffc0200a82:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a84:	00878963          	beq	a5,s0,ffffffffc0200a96 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200a88:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a8c:	679c                	ld	a5,8(a5)
ffffffffc0200a8e:	397d                	addiw	s2,s2,-1
ffffffffc0200a90:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a92:	fe879be3          	bne	a5,s0,ffffffffc0200a88 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200a96:	26091363          	bnez	s2,ffffffffc0200cfc <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200a9a:	e0ed                	bnez	s1,ffffffffc0200b7c <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200a9c:	60a6                	ld	ra,72(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	74e2                	ld	s1,56(sp)
ffffffffc0200aa2:	7942                	ld	s2,48(sp)
ffffffffc0200aa4:	79a2                	ld	s3,40(sp)
ffffffffc0200aa6:	7a02                	ld	s4,32(sp)
ffffffffc0200aa8:	6ae2                	ld	s5,24(sp)
ffffffffc0200aaa:	6b42                	ld	s6,16(sp)
ffffffffc0200aac:	6ba2                	ld	s7,8(sp)
ffffffffc0200aae:	6c02                	ld	s8,0(sp)
ffffffffc0200ab0:	6161                	addi	sp,sp,80
ffffffffc0200ab2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ab4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ab6:	4481                	li	s1,0
ffffffffc0200ab8:	4901                	li	s2,0
ffffffffc0200aba:	b35d                	j	ffffffffc0200860 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200abc:	00001697          	auipc	a3,0x1
ffffffffc0200ac0:	65468693          	addi	a3,a3,1620 # ffffffffc0202110 <commands+0x4f8>
ffffffffc0200ac4:	00001617          	auipc	a2,0x1
ffffffffc0200ac8:	65c60613          	addi	a2,a2,1628 # ffffffffc0202120 <commands+0x508>
ffffffffc0200acc:	12100593          	li	a1,289
ffffffffc0200ad0:	00001517          	auipc	a0,0x1
ffffffffc0200ad4:	66850513          	addi	a0,a0,1640 # ffffffffc0202138 <commands+0x520>
ffffffffc0200ad8:	8d5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200adc:	00001697          	auipc	a3,0x1
ffffffffc0200ae0:	6f468693          	addi	a3,a3,1780 # ffffffffc02021d0 <commands+0x5b8>
ffffffffc0200ae4:	00001617          	auipc	a2,0x1
ffffffffc0200ae8:	63c60613          	addi	a2,a2,1596 # ffffffffc0202120 <commands+0x508>
ffffffffc0200aec:	0ed00593          	li	a1,237
ffffffffc0200af0:	00001517          	auipc	a0,0x1
ffffffffc0200af4:	64850513          	addi	a0,a0,1608 # ffffffffc0202138 <commands+0x520>
ffffffffc0200af8:	8b5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200afc:	00001697          	auipc	a3,0x1
ffffffffc0200b00:	6fc68693          	addi	a3,a3,1788 # ffffffffc02021f8 <commands+0x5e0>
ffffffffc0200b04:	00001617          	auipc	a2,0x1
ffffffffc0200b08:	61c60613          	addi	a2,a2,1564 # ffffffffc0202120 <commands+0x508>
ffffffffc0200b0c:	0ee00593          	li	a1,238
ffffffffc0200b10:	00001517          	auipc	a0,0x1
ffffffffc0200b14:	62850513          	addi	a0,a0,1576 # ffffffffc0202138 <commands+0x520>
ffffffffc0200b18:	895ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b1c:	00001697          	auipc	a3,0x1
ffffffffc0200b20:	71c68693          	addi	a3,a3,1820 # ffffffffc0202238 <commands+0x620>
ffffffffc0200b24:	00001617          	auipc	a2,0x1
ffffffffc0200b28:	5fc60613          	addi	a2,a2,1532 # ffffffffc0202120 <commands+0x508>
ffffffffc0200b2c:	0f000593          	li	a1,240
ffffffffc0200b30:	00001517          	auipc	a0,0x1
ffffffffc0200b34:	60850513          	addi	a0,a0,1544 # ffffffffc0202138 <commands+0x520>
ffffffffc0200b38:	875ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200b3c:	00001697          	auipc	a3,0x1
ffffffffc0200b40:	78468693          	addi	a3,a3,1924 # ffffffffc02022c0 <commands+0x6a8>
ffffffffc0200b44:	00001617          	auipc	a2,0x1
ffffffffc0200b48:	5dc60613          	addi	a2,a2,1500 # ffffffffc0202120 <commands+0x508>
ffffffffc0200b4c:	10900593          	li	a1,265
ffffffffc0200b50:	00001517          	auipc	a0,0x1
ffffffffc0200b54:	5e850513          	addi	a0,a0,1512 # ffffffffc0202138 <commands+0x520>
ffffffffc0200b58:	855ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b5c:	00001697          	auipc	a3,0x1
ffffffffc0200b60:	65468693          	addi	a3,a3,1620 # ffffffffc02021b0 <commands+0x598>
ffffffffc0200b64:	00001617          	auipc	a2,0x1
ffffffffc0200b68:	5bc60613          	addi	a2,a2,1468 # ffffffffc0202120 <commands+0x508>
ffffffffc0200b6c:	0eb00593          	li	a1,235
ffffffffc0200b70:	00001517          	auipc	a0,0x1
ffffffffc0200b74:	5c850513          	addi	a0,a0,1480 # ffffffffc0202138 <commands+0x520>
ffffffffc0200b78:	835ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200b7c:	00002697          	auipc	a3,0x2
ffffffffc0200b80:	87468693          	addi	a3,a3,-1932 # ffffffffc02023f0 <commands+0x7d8>
ffffffffc0200b84:	00001617          	auipc	a2,0x1
ffffffffc0200b88:	59c60613          	addi	a2,a2,1436 # ffffffffc0202120 <commands+0x508>
ffffffffc0200b8c:	16300593          	li	a1,355
ffffffffc0200b90:	00001517          	auipc	a0,0x1
ffffffffc0200b94:	5a850513          	addi	a0,a0,1448 # ffffffffc0202138 <commands+0x520>
ffffffffc0200b98:	815ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200b9c:	00001697          	auipc	a3,0x1
ffffffffc0200ba0:	5b468693          	addi	a3,a3,1460 # ffffffffc0202150 <commands+0x538>
ffffffffc0200ba4:	00001617          	auipc	a2,0x1
ffffffffc0200ba8:	57c60613          	addi	a2,a2,1404 # ffffffffc0202120 <commands+0x508>
ffffffffc0200bac:	12400593          	li	a1,292
ffffffffc0200bb0:	00001517          	auipc	a0,0x1
ffffffffc0200bb4:	58850513          	addi	a0,a0,1416 # ffffffffc0202138 <commands+0x520>
ffffffffc0200bb8:	ff4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bbc:	00001697          	auipc	a3,0x1
ffffffffc0200bc0:	5d468693          	addi	a3,a3,1492 # ffffffffc0202190 <commands+0x578>
ffffffffc0200bc4:	00001617          	auipc	a2,0x1
ffffffffc0200bc8:	55c60613          	addi	a2,a2,1372 # ffffffffc0202120 <commands+0x508>
ffffffffc0200bcc:	0ea00593          	li	a1,234
ffffffffc0200bd0:	00001517          	auipc	a0,0x1
ffffffffc0200bd4:	56850513          	addi	a0,a0,1384 # ffffffffc0202138 <commands+0x520>
ffffffffc0200bd8:	fd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bdc:	00001697          	auipc	a3,0x1
ffffffffc0200be0:	59468693          	addi	a3,a3,1428 # ffffffffc0202170 <commands+0x558>
ffffffffc0200be4:	00001617          	auipc	a2,0x1
ffffffffc0200be8:	53c60613          	addi	a2,a2,1340 # ffffffffc0202120 <commands+0x508>
ffffffffc0200bec:	0e900593          	li	a1,233
ffffffffc0200bf0:	00001517          	auipc	a0,0x1
ffffffffc0200bf4:	54850513          	addi	a0,a0,1352 # ffffffffc0202138 <commands+0x520>
ffffffffc0200bf8:	fb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200bfc:	00001697          	auipc	a3,0x1
ffffffffc0200c00:	69c68693          	addi	a3,a3,1692 # ffffffffc0202298 <commands+0x680>
ffffffffc0200c04:	00001617          	auipc	a2,0x1
ffffffffc0200c08:	51c60613          	addi	a2,a2,1308 # ffffffffc0202120 <commands+0x508>
ffffffffc0200c0c:	10600593          	li	a1,262
ffffffffc0200c10:	00001517          	auipc	a0,0x1
ffffffffc0200c14:	52850513          	addi	a0,a0,1320 # ffffffffc0202138 <commands+0x520>
ffffffffc0200c18:	f94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c1c:	00001697          	auipc	a3,0x1
ffffffffc0200c20:	59468693          	addi	a3,a3,1428 # ffffffffc02021b0 <commands+0x598>
ffffffffc0200c24:	00001617          	auipc	a2,0x1
ffffffffc0200c28:	4fc60613          	addi	a2,a2,1276 # ffffffffc0202120 <commands+0x508>
ffffffffc0200c2c:	10400593          	li	a1,260
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	50850513          	addi	a0,a0,1288 # ffffffffc0202138 <commands+0x520>
ffffffffc0200c38:	f74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c3c:	00001697          	auipc	a3,0x1
ffffffffc0200c40:	55468693          	addi	a3,a3,1364 # ffffffffc0202190 <commands+0x578>
ffffffffc0200c44:	00001617          	auipc	a2,0x1
ffffffffc0200c48:	4dc60613          	addi	a2,a2,1244 # ffffffffc0202120 <commands+0x508>
ffffffffc0200c4c:	10300593          	li	a1,259
ffffffffc0200c50:	00001517          	auipc	a0,0x1
ffffffffc0200c54:	4e850513          	addi	a0,a0,1256 # ffffffffc0202138 <commands+0x520>
ffffffffc0200c58:	f54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c5c:	00001697          	auipc	a3,0x1
ffffffffc0200c60:	51468693          	addi	a3,a3,1300 # ffffffffc0202170 <commands+0x558>
ffffffffc0200c64:	00001617          	auipc	a2,0x1
ffffffffc0200c68:	4bc60613          	addi	a2,a2,1212 # ffffffffc0202120 <commands+0x508>
ffffffffc0200c6c:	10200593          	li	a1,258
ffffffffc0200c70:	00001517          	auipc	a0,0x1
ffffffffc0200c74:	4c850513          	addi	a0,a0,1224 # ffffffffc0202138 <commands+0x520>
ffffffffc0200c78:	f34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200c7c:	00001697          	auipc	a3,0x1
ffffffffc0200c80:	63468693          	addi	a3,a3,1588 # ffffffffc02022b0 <commands+0x698>
ffffffffc0200c84:	00001617          	auipc	a2,0x1
ffffffffc0200c88:	49c60613          	addi	a2,a2,1180 # ffffffffc0202120 <commands+0x508>
ffffffffc0200c8c:	10000593          	li	a1,256
ffffffffc0200c90:	00001517          	auipc	a0,0x1
ffffffffc0200c94:	4a850513          	addi	a0,a0,1192 # ffffffffc0202138 <commands+0x520>
ffffffffc0200c98:	f14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c9c:	00001697          	auipc	a3,0x1
ffffffffc0200ca0:	5fc68693          	addi	a3,a3,1532 # ffffffffc0202298 <commands+0x680>
ffffffffc0200ca4:	00001617          	auipc	a2,0x1
ffffffffc0200ca8:	47c60613          	addi	a2,a2,1148 # ffffffffc0202120 <commands+0x508>
ffffffffc0200cac:	0fb00593          	li	a1,251
ffffffffc0200cb0:	00001517          	auipc	a0,0x1
ffffffffc0200cb4:	48850513          	addi	a0,a0,1160 # ffffffffc0202138 <commands+0x520>
ffffffffc0200cb8:	ef4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cbc:	00001697          	auipc	a3,0x1
ffffffffc0200cc0:	5bc68693          	addi	a3,a3,1468 # ffffffffc0202278 <commands+0x660>
ffffffffc0200cc4:	00001617          	auipc	a2,0x1
ffffffffc0200cc8:	45c60613          	addi	a2,a2,1116 # ffffffffc0202120 <commands+0x508>
ffffffffc0200ccc:	0f200593          	li	a1,242
ffffffffc0200cd0:	00001517          	auipc	a0,0x1
ffffffffc0200cd4:	46850513          	addi	a0,a0,1128 # ffffffffc0202138 <commands+0x520>
ffffffffc0200cd8:	ed4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cdc:	00001697          	auipc	a3,0x1
ffffffffc0200ce0:	57c68693          	addi	a3,a3,1404 # ffffffffc0202258 <commands+0x640>
ffffffffc0200ce4:	00001617          	auipc	a2,0x1
ffffffffc0200ce8:	43c60613          	addi	a2,a2,1084 # ffffffffc0202120 <commands+0x508>
ffffffffc0200cec:	0f100593          	li	a1,241
ffffffffc0200cf0:	00001517          	auipc	a0,0x1
ffffffffc0200cf4:	44850513          	addi	a0,a0,1096 # ffffffffc0202138 <commands+0x520>
ffffffffc0200cf8:	eb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200cfc:	00001697          	auipc	a3,0x1
ffffffffc0200d00:	6e468693          	addi	a3,a3,1764 # ffffffffc02023e0 <commands+0x7c8>
ffffffffc0200d04:	00001617          	auipc	a2,0x1
ffffffffc0200d08:	41c60613          	addi	a2,a2,1052 # ffffffffc0202120 <commands+0x508>
ffffffffc0200d0c:	16200593          	li	a1,354
ffffffffc0200d10:	00001517          	auipc	a0,0x1
ffffffffc0200d14:	42850513          	addi	a0,a0,1064 # ffffffffc0202138 <commands+0x520>
ffffffffc0200d18:	e94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d1c:	00001697          	auipc	a3,0x1
ffffffffc0200d20:	5dc68693          	addi	a3,a3,1500 # ffffffffc02022f8 <commands+0x6e0>
ffffffffc0200d24:	00001617          	auipc	a2,0x1
ffffffffc0200d28:	3fc60613          	addi	a2,a2,1020 # ffffffffc0202120 <commands+0x508>
ffffffffc0200d2c:	15700593          	li	a1,343
ffffffffc0200d30:	00001517          	auipc	a0,0x1
ffffffffc0200d34:	40850513          	addi	a0,a0,1032 # ffffffffc0202138 <commands+0x520>
ffffffffc0200d38:	e74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d3c:	00001697          	auipc	a3,0x1
ffffffffc0200d40:	55c68693          	addi	a3,a3,1372 # ffffffffc0202298 <commands+0x680>
ffffffffc0200d44:	00001617          	auipc	a2,0x1
ffffffffc0200d48:	3dc60613          	addi	a2,a2,988 # ffffffffc0202120 <commands+0x508>
ffffffffc0200d4c:	15100593          	li	a1,337
ffffffffc0200d50:	00001517          	auipc	a0,0x1
ffffffffc0200d54:	3e850513          	addi	a0,a0,1000 # ffffffffc0202138 <commands+0x520>
ffffffffc0200d58:	e54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d5c:	00001697          	auipc	a3,0x1
ffffffffc0200d60:	66468693          	addi	a3,a3,1636 # ffffffffc02023c0 <commands+0x7a8>
ffffffffc0200d64:	00001617          	auipc	a2,0x1
ffffffffc0200d68:	3bc60613          	addi	a2,a2,956 # ffffffffc0202120 <commands+0x508>
ffffffffc0200d6c:	15000593          	li	a1,336
ffffffffc0200d70:	00001517          	auipc	a0,0x1
ffffffffc0200d74:	3c850513          	addi	a0,a0,968 # ffffffffc0202138 <commands+0x520>
ffffffffc0200d78:	e34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200d7c:	00001697          	auipc	a3,0x1
ffffffffc0200d80:	63468693          	addi	a3,a3,1588 # ffffffffc02023b0 <commands+0x798>
ffffffffc0200d84:	00001617          	auipc	a2,0x1
ffffffffc0200d88:	39c60613          	addi	a2,a2,924 # ffffffffc0202120 <commands+0x508>
ffffffffc0200d8c:	14800593          	li	a1,328
ffffffffc0200d90:	00001517          	auipc	a0,0x1
ffffffffc0200d94:	3a850513          	addi	a0,a0,936 # ffffffffc0202138 <commands+0x520>
ffffffffc0200d98:	e14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200d9c:	00001697          	auipc	a3,0x1
ffffffffc0200da0:	5fc68693          	addi	a3,a3,1532 # ffffffffc0202398 <commands+0x780>
ffffffffc0200da4:	00001617          	auipc	a2,0x1
ffffffffc0200da8:	37c60613          	addi	a2,a2,892 # ffffffffc0202120 <commands+0x508>
ffffffffc0200dac:	14700593          	li	a1,327
ffffffffc0200db0:	00001517          	auipc	a0,0x1
ffffffffc0200db4:	38850513          	addi	a0,a0,904 # ffffffffc0202138 <commands+0x520>
ffffffffc0200db8:	df4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200dbc:	00001697          	auipc	a3,0x1
ffffffffc0200dc0:	5bc68693          	addi	a3,a3,1468 # ffffffffc0202378 <commands+0x760>
ffffffffc0200dc4:	00001617          	auipc	a2,0x1
ffffffffc0200dc8:	35c60613          	addi	a2,a2,860 # ffffffffc0202120 <commands+0x508>
ffffffffc0200dcc:	14600593          	li	a1,326
ffffffffc0200dd0:	00001517          	auipc	a0,0x1
ffffffffc0200dd4:	36850513          	addi	a0,a0,872 # ffffffffc0202138 <commands+0x520>
ffffffffc0200dd8:	dd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ddc:	00001697          	auipc	a3,0x1
ffffffffc0200de0:	56c68693          	addi	a3,a3,1388 # ffffffffc0202348 <commands+0x730>
ffffffffc0200de4:	00001617          	auipc	a2,0x1
ffffffffc0200de8:	33c60613          	addi	a2,a2,828 # ffffffffc0202120 <commands+0x508>
ffffffffc0200dec:	14400593          	li	a1,324
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	34850513          	addi	a0,a0,840 # ffffffffc0202138 <commands+0x520>
ffffffffc0200df8:	db4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dfc:	00001697          	auipc	a3,0x1
ffffffffc0200e00:	53468693          	addi	a3,a3,1332 # ffffffffc0202330 <commands+0x718>
ffffffffc0200e04:	00001617          	auipc	a2,0x1
ffffffffc0200e08:	31c60613          	addi	a2,a2,796 # ffffffffc0202120 <commands+0x508>
ffffffffc0200e0c:	14300593          	li	a1,323
ffffffffc0200e10:	00001517          	auipc	a0,0x1
ffffffffc0200e14:	32850513          	addi	a0,a0,808 # ffffffffc0202138 <commands+0x520>
ffffffffc0200e18:	d94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e1c:	00001697          	auipc	a3,0x1
ffffffffc0200e20:	47c68693          	addi	a3,a3,1148 # ffffffffc0202298 <commands+0x680>
ffffffffc0200e24:	00001617          	auipc	a2,0x1
ffffffffc0200e28:	2fc60613          	addi	a2,a2,764 # ffffffffc0202120 <commands+0x508>
ffffffffc0200e2c:	13700593          	li	a1,311
ffffffffc0200e30:	00001517          	auipc	a0,0x1
ffffffffc0200e34:	30850513          	addi	a0,a0,776 # ffffffffc0202138 <commands+0x520>
ffffffffc0200e38:	d74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200e3c:	00001697          	auipc	a3,0x1
ffffffffc0200e40:	4dc68693          	addi	a3,a3,1244 # ffffffffc0202318 <commands+0x700>
ffffffffc0200e44:	00001617          	auipc	a2,0x1
ffffffffc0200e48:	2dc60613          	addi	a2,a2,732 # ffffffffc0202120 <commands+0x508>
ffffffffc0200e4c:	12e00593          	li	a1,302
ffffffffc0200e50:	00001517          	auipc	a0,0x1
ffffffffc0200e54:	2e850513          	addi	a0,a0,744 # ffffffffc0202138 <commands+0x520>
ffffffffc0200e58:	d54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200e5c:	00001697          	auipc	a3,0x1
ffffffffc0200e60:	4ac68693          	addi	a3,a3,1196 # ffffffffc0202308 <commands+0x6f0>
ffffffffc0200e64:	00001617          	auipc	a2,0x1
ffffffffc0200e68:	2bc60613          	addi	a2,a2,700 # ffffffffc0202120 <commands+0x508>
ffffffffc0200e6c:	12d00593          	li	a1,301
ffffffffc0200e70:	00001517          	auipc	a0,0x1
ffffffffc0200e74:	2c850513          	addi	a0,a0,712 # ffffffffc0202138 <commands+0x520>
ffffffffc0200e78:	d34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e7c:	00001697          	auipc	a3,0x1
ffffffffc0200e80:	47c68693          	addi	a3,a3,1148 # ffffffffc02022f8 <commands+0x6e0>
ffffffffc0200e84:	00001617          	auipc	a2,0x1
ffffffffc0200e88:	29c60613          	addi	a2,a2,668 # ffffffffc0202120 <commands+0x508>
ffffffffc0200e8c:	10f00593          	li	a1,271
ffffffffc0200e90:	00001517          	auipc	a0,0x1
ffffffffc0200e94:	2a850513          	addi	a0,a0,680 # ffffffffc0202138 <commands+0x520>
ffffffffc0200e98:	d14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e9c:	00001697          	auipc	a3,0x1
ffffffffc0200ea0:	3fc68693          	addi	a3,a3,1020 # ffffffffc0202298 <commands+0x680>
ffffffffc0200ea4:	00001617          	auipc	a2,0x1
ffffffffc0200ea8:	27c60613          	addi	a2,a2,636 # ffffffffc0202120 <commands+0x508>
ffffffffc0200eac:	10d00593          	li	a1,269
ffffffffc0200eb0:	00001517          	auipc	a0,0x1
ffffffffc0200eb4:	28850513          	addi	a0,a0,648 # ffffffffc0202138 <commands+0x520>
ffffffffc0200eb8:	cf4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ebc:	00001697          	auipc	a3,0x1
ffffffffc0200ec0:	41c68693          	addi	a3,a3,1052 # ffffffffc02022d8 <commands+0x6c0>
ffffffffc0200ec4:	00001617          	auipc	a2,0x1
ffffffffc0200ec8:	25c60613          	addi	a2,a2,604 # ffffffffc0202120 <commands+0x508>
ffffffffc0200ecc:	10c00593          	li	a1,268
ffffffffc0200ed0:	00001517          	auipc	a0,0x1
ffffffffc0200ed4:	26850513          	addi	a0,a0,616 # ffffffffc0202138 <commands+0x520>
ffffffffc0200ed8:	cd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200edc <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200edc:	1141                	addi	sp,sp,-16
ffffffffc0200ede:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ee0:	14058a63          	beqz	a1,ffffffffc0201034 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200ee4:	00259693          	slli	a3,a1,0x2
ffffffffc0200ee8:	96ae                	add	a3,a3,a1
ffffffffc0200eea:	068e                	slli	a3,a3,0x3
ffffffffc0200eec:	96aa                	add	a3,a3,a0
ffffffffc0200eee:	87aa                	mv	a5,a0
ffffffffc0200ef0:	02d50263          	beq	a0,a3,ffffffffc0200f14 <best_fit_free_pages+0x38>
ffffffffc0200ef4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ef6:	8b05                	andi	a4,a4,1
ffffffffc0200ef8:	10071e63          	bnez	a4,ffffffffc0201014 <best_fit_free_pages+0x138>
ffffffffc0200efc:	6798                	ld	a4,8(a5)
ffffffffc0200efe:	8b09                	andi	a4,a4,2
ffffffffc0200f00:	10071a63          	bnez	a4,ffffffffc0201014 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200f04:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f08:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200f0c:	02878793          	addi	a5,a5,40
ffffffffc0200f10:	fed792e3          	bne	a5,a3,ffffffffc0200ef4 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0200f14:	2581                	sext.w	a1,a1
ffffffffc0200f16:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200f18:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f1c:	4789                	li	a5,2
ffffffffc0200f1e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0200f22:	00005697          	auipc	a3,0x5
ffffffffc0200f26:	0ee68693          	addi	a3,a3,238 # ffffffffc0206010 <free_area>
ffffffffc0200f2a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200f2c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200f2e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0200f32:	9db9                	addw	a1,a1,a4
ffffffffc0200f34:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200f36:	0ad78863          	beq	a5,a3,ffffffffc0200fe6 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0200f3a:	fe878713          	addi	a4,a5,-24
ffffffffc0200f3e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200f42:	4581                	li	a1,0
            if (base < page) {
ffffffffc0200f44:	00e56a63          	bltu	a0,a4,ffffffffc0200f58 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0200f48:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200f4a:	06d70263          	beq	a4,a3,ffffffffc0200fae <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0200f4e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200f50:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200f54:	fee57ae3          	bgeu	a0,a4,ffffffffc0200f48 <best_fit_free_pages+0x6c>
ffffffffc0200f58:	c199                	beqz	a1,ffffffffc0200f5e <best_fit_free_pages+0x82>
ffffffffc0200f5a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f5e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f60:	e390                	sd	a2,0(a5)
ffffffffc0200f62:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200f64:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f66:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0200f68:	02d70063          	beq	a4,a3,ffffffffc0200f88 <best_fit_free_pages+0xac>
        if (p + p->property == base) 
ffffffffc0200f6c:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0200f70:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) 
ffffffffc0200f74:	02081613          	slli	a2,a6,0x20
ffffffffc0200f78:	9201                	srli	a2,a2,0x20
ffffffffc0200f7a:	00261793          	slli	a5,a2,0x2
ffffffffc0200f7e:	97b2                	add	a5,a5,a2
ffffffffc0200f80:	078e                	slli	a5,a5,0x3
ffffffffc0200f82:	97ae                	add	a5,a5,a1
ffffffffc0200f84:	02f50f63          	beq	a0,a5,ffffffffc0200fc2 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0200f88:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0200f8a:	00d70f63          	beq	a4,a3,ffffffffc0200fa8 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0200f8e:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0200f90:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0200f94:	02059613          	slli	a2,a1,0x20
ffffffffc0200f98:	9201                	srli	a2,a2,0x20
ffffffffc0200f9a:	00261793          	slli	a5,a2,0x2
ffffffffc0200f9e:	97b2                	add	a5,a5,a2
ffffffffc0200fa0:	078e                	slli	a5,a5,0x3
ffffffffc0200fa2:	97aa                	add	a5,a5,a0
ffffffffc0200fa4:	04f68863          	beq	a3,a5,ffffffffc0200ff4 <best_fit_free_pages+0x118>
}
ffffffffc0200fa8:	60a2                	ld	ra,8(sp)
ffffffffc0200faa:	0141                	addi	sp,sp,16
ffffffffc0200fac:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200fae:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200fb0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200fb2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200fb4:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fb6:	02d70563          	beq	a4,a3,ffffffffc0200fe0 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0200fba:	8832                	mv	a6,a2
ffffffffc0200fbc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0200fbe:	87ba                	mv	a5,a4
ffffffffc0200fc0:	bf41                	j	ffffffffc0200f50 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc0200fc2:	491c                	lw	a5,16(a0)
ffffffffc0200fc4:	0107883b          	addw	a6,a5,a6
ffffffffc0200fc8:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200fcc:	57f5                	li	a5,-3
ffffffffc0200fce:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fd2:	6d10                	ld	a2,24(a0)
ffffffffc0200fd4:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0200fd6:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200fd8:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0200fda:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0200fdc:	e390                	sd	a2,0(a5)
ffffffffc0200fde:	b775                	j	ffffffffc0200f8a <best_fit_free_pages+0xae>
ffffffffc0200fe0:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fe2:	873e                	mv	a4,a5
ffffffffc0200fe4:	b761                	j	ffffffffc0200f6c <best_fit_free_pages+0x90>
}
ffffffffc0200fe6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200fe8:	e390                	sd	a2,0(a5)
ffffffffc0200fea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200fec:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200fee:	ed1c                	sd	a5,24(a0)
ffffffffc0200ff0:	0141                	addi	sp,sp,16
ffffffffc0200ff2:	8082                	ret
            base->property += p->property;
ffffffffc0200ff4:	ff872783          	lw	a5,-8(a4)
ffffffffc0200ff8:	ff070693          	addi	a3,a4,-16
ffffffffc0200ffc:	9dbd                	addw	a1,a1,a5
ffffffffc0200ffe:	c90c                	sw	a1,16(a0)
ffffffffc0201000:	57f5                	li	a5,-3
ffffffffc0201002:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201006:	6314                	ld	a3,0(a4)
ffffffffc0201008:	671c                	ld	a5,8(a4)
}
ffffffffc020100a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020100c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020100e:	e394                	sd	a3,0(a5)
ffffffffc0201010:	0141                	addi	sp,sp,16
ffffffffc0201012:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	3f468693          	addi	a3,a3,1012 # ffffffffc0202408 <commands+0x7f0>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	10460613          	addi	a2,a2,260 # ffffffffc0202120 <commands+0x508>
ffffffffc0201024:	0a800593          	li	a1,168
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	11050513          	addi	a0,a0,272 # ffffffffc0202138 <commands+0x520>
ffffffffc0201030:	b7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	3cc68693          	addi	a3,a3,972 # ffffffffc0202400 <commands+0x7e8>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	0e460613          	addi	a2,a2,228 # ffffffffc0202120 <commands+0x508>
ffffffffc0201044:	0a500593          	li	a1,165
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	0f050513          	addi	a0,a0,240 # ffffffffc0202138 <commands+0x520>
ffffffffc0201050:	b5cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201054 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0201054:	c945                	beqz	a0,ffffffffc0201104 <best_fit_alloc_pages+0xb0>
    if (n > nr_free) {
ffffffffc0201056:	00005817          	auipc	a6,0x5
ffffffffc020105a:	fba80813          	addi	a6,a6,-70 # ffffffffc0206010 <free_area>
ffffffffc020105e:	01082303          	lw	t1,16(a6)
ffffffffc0201062:	862a                	mv	a2,a0
ffffffffc0201064:	02031793          	slli	a5,t1,0x20
ffffffffc0201068:	9381                	srli	a5,a5,0x20
ffffffffc020106a:	08a7e863          	bltu	a5,a0,ffffffffc02010fa <best_fit_alloc_pages+0xa6>
    return listelm->next;
ffffffffc020106e:	00883703          	ld	a4,8(a6)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201072:	09070463          	beq	a4,a6,ffffffffc02010fa <best_fit_alloc_pages+0xa6>
    int best_size_diff = 65535; //用于存储当前找到的最佳匹配页块大小与所需大小之间的差值
ffffffffc0201076:	65c1                	lui	a1,0x10
            size_diff = p->property - n;
ffffffffc0201078:	0005089b          	sext.w	a7,a0
    int best_size_diff = 65535; //用于存储当前找到的最佳匹配页块大小与所需大小之间的差值
ffffffffc020107c:	15fd                	addi	a1,a1,-1
    struct Page *page = NULL;
ffffffffc020107e:	4501                	li	a0,0
        if (p->property > n)
ffffffffc0201080:	ff872783          	lw	a5,-8(a4)
ffffffffc0201084:	02079693          	slli	a3,a5,0x20
ffffffffc0201088:	9281                	srli	a3,a3,0x20
ffffffffc020108a:	06d67a63          	bgeu	a2,a3,ffffffffc02010fe <best_fit_alloc_pages+0xaa>
            size_diff = p->property - n;
ffffffffc020108e:	411787bb          	subw	a5,a5,a7
        if (size_diff < best_size_diff)
ffffffffc0201092:	00b7d663          	bge	a5,a1,ffffffffc020109e <best_fit_alloc_pages+0x4a>
        struct Page *p = le2page(le, page_link);
ffffffffc0201096:	fe870513          	addi	a0,a4,-24
            if (size_diff == 0)
ffffffffc020109a:	c791                	beqz	a5,ffffffffc02010a6 <best_fit_alloc_pages+0x52>
ffffffffc020109c:	85be                	mv	a1,a5
ffffffffc020109e:	6718                	ld	a4,8(a4)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010a0:	ff0710e3          	bne	a4,a6,ffffffffc0201080 <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc02010a4:	cd21                	beqz	a0,ffffffffc02010fc <best_fit_alloc_pages+0xa8>
    __list_del(listelm->prev, listelm->next);
ffffffffc02010a6:	711c                	ld	a5,32(a0)
    return listelm->prev;
ffffffffc02010a8:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc02010aa:	4914                	lw	a3,16(a0)
    prev->next = next;
ffffffffc02010ac:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010ae:	e398                	sd	a4,0(a5)
ffffffffc02010b0:	02069793          	slli	a5,a3,0x20
ffffffffc02010b4:	9381                	srli	a5,a5,0x20
ffffffffc02010b6:	02f67863          	bgeu	a2,a5,ffffffffc02010e6 <best_fit_alloc_pages+0x92>
            struct Page *p = page + n;
ffffffffc02010ba:	00261793          	slli	a5,a2,0x2
ffffffffc02010be:	97b2                	add	a5,a5,a2
ffffffffc02010c0:	078e                	slli	a5,a5,0x3
ffffffffc02010c2:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc02010c4:	411686bb          	subw	a3,a3,a7
ffffffffc02010c8:	cb94                	sw	a3,16(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010ca:	00878613          	addi	a2,a5,8
ffffffffc02010ce:	4689                	li	a3,2
ffffffffc02010d0:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02010d4:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc02010d6:	01878613          	addi	a2,a5,24
        nr_free -= n;
ffffffffc02010da:	01082303          	lw	t1,16(a6)
    prev->next = next->prev = elm;
ffffffffc02010de:	e290                	sd	a2,0(a3)
ffffffffc02010e0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010e2:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02010e4:	ef98                	sd	a4,24(a5)
ffffffffc02010e6:	411308bb          	subw	a7,t1,a7
ffffffffc02010ea:	01182823          	sw	a7,16(a6)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010ee:	57f5                	li	a5,-3
ffffffffc02010f0:	00850713          	addi	a4,a0,8
ffffffffc02010f4:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02010f8:	8082                	ret
        return NULL;
ffffffffc02010fa:	4501                	li	a0,0
}
ffffffffc02010fc:	8082                	ret
            size_diff = n - p->property;
ffffffffc02010fe:	40f887bb          	subw	a5,a7,a5
ffffffffc0201102:	bf41                	j	ffffffffc0201092 <best_fit_alloc_pages+0x3e>
best_fit_alloc_pages(size_t n) {
ffffffffc0201104:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201106:	00001697          	auipc	a3,0x1
ffffffffc020110a:	2fa68693          	addi	a3,a3,762 # ffffffffc0202400 <commands+0x7e8>
ffffffffc020110e:	00001617          	auipc	a2,0x1
ffffffffc0201112:	01260613          	addi	a2,a2,18 # ffffffffc0202120 <commands+0x508>
ffffffffc0201116:	06d00593          	li	a1,109
ffffffffc020111a:	00001517          	auipc	a0,0x1
ffffffffc020111e:	01e50513          	addi	a0,a0,30 # ffffffffc0202138 <commands+0x520>
best_fit_alloc_pages(size_t n) {
ffffffffc0201122:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201124:	a88ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201128 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201128:	1141                	addi	sp,sp,-16
ffffffffc020112a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020112c:	c9e1                	beqz	a1,ffffffffc02011fc <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020112e:	00259693          	slli	a3,a1,0x2
ffffffffc0201132:	96ae                	add	a3,a3,a1
ffffffffc0201134:	068e                	slli	a3,a3,0x3
ffffffffc0201136:	96aa                	add	a3,a3,a0
ffffffffc0201138:	87aa                	mv	a5,a0
ffffffffc020113a:	00d50f63          	beq	a0,a3,ffffffffc0201158 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020113e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201140:	8b05                	andi	a4,a4,1
ffffffffc0201142:	cf49                	beqz	a4,ffffffffc02011dc <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201144:	0007a823          	sw	zero,16(a5)
ffffffffc0201148:	0007b423          	sd	zero,8(a5)
ffffffffc020114c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201150:	02878793          	addi	a5,a5,40
ffffffffc0201154:	fed795e3          	bne	a5,a3,ffffffffc020113e <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0201158:	2581                	sext.w	a1,a1
ffffffffc020115a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020115c:	4789                	li	a5,2
ffffffffc020115e:	00850713          	addi	a4,a0,8
ffffffffc0201162:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201166:	00005697          	auipc	a3,0x5
ffffffffc020116a:	eaa68693          	addi	a3,a3,-342 # ffffffffc0206010 <free_area>
ffffffffc020116e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201170:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201172:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201176:	9db9                	addw	a1,a1,a4
ffffffffc0201178:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020117a:	04d78a63          	beq	a5,a3,ffffffffc02011ce <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020117e:	fe878713          	addi	a4,a5,-24
ffffffffc0201182:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201186:	4581                	li	a1,0
            if(base < page)
ffffffffc0201188:	00e56a63          	bltu	a0,a4,ffffffffc020119c <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc020118c:	6798                	ld	a4,8(a5)
            else if(list_next(le) == &free_list)
ffffffffc020118e:	02d70263          	beq	a4,a3,ffffffffc02011b2 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201192:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201194:	fe878713          	addi	a4,a5,-24
            if(base < page)
ffffffffc0201198:	fee57ae3          	bgeu	a0,a4,ffffffffc020118c <best_fit_init_memmap+0x64>
ffffffffc020119c:	c199                	beqz	a1,ffffffffc02011a2 <best_fit_init_memmap+0x7a>
ffffffffc020119e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011a2:	6398                	ld	a4,0(a5)
}
ffffffffc02011a4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02011a6:	e390                	sd	a2,0(a5)
ffffffffc02011a8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011aa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011ac:	ed18                	sd	a4,24(a0)
ffffffffc02011ae:	0141                	addi	sp,sp,16
ffffffffc02011b0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011b2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011b4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011b6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011b8:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011ba:	00d70663          	beq	a4,a3,ffffffffc02011c6 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011be:	8832                	mv	a6,a2
ffffffffc02011c0:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02011c2:	87ba                	mv	a5,a4
ffffffffc02011c4:	bfc1                	j	ffffffffc0201194 <best_fit_init_memmap+0x6c>
}
ffffffffc02011c6:	60a2                	ld	ra,8(sp)
ffffffffc02011c8:	e290                	sd	a2,0(a3)
ffffffffc02011ca:	0141                	addi	sp,sp,16
ffffffffc02011cc:	8082                	ret
ffffffffc02011ce:	60a2                	ld	ra,8(sp)
ffffffffc02011d0:	e390                	sd	a2,0(a5)
ffffffffc02011d2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011d4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011d6:	ed1c                	sd	a5,24(a0)
ffffffffc02011d8:	0141                	addi	sp,sp,16
ffffffffc02011da:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011dc:	00001697          	auipc	a3,0x1
ffffffffc02011e0:	25468693          	addi	a3,a3,596 # ffffffffc0202430 <commands+0x818>
ffffffffc02011e4:	00001617          	auipc	a2,0x1
ffffffffc02011e8:	f3c60613          	addi	a2,a2,-196 # ffffffffc0202120 <commands+0x508>
ffffffffc02011ec:	04a00593          	li	a1,74
ffffffffc02011f0:	00001517          	auipc	a0,0x1
ffffffffc02011f4:	f4850513          	addi	a0,a0,-184 # ffffffffc0202138 <commands+0x520>
ffffffffc02011f8:	9b4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011fc:	00001697          	auipc	a3,0x1
ffffffffc0201200:	20468693          	addi	a3,a3,516 # ffffffffc0202400 <commands+0x7e8>
ffffffffc0201204:	00001617          	auipc	a2,0x1
ffffffffc0201208:	f1c60613          	addi	a2,a2,-228 # ffffffffc0202120 <commands+0x508>
ffffffffc020120c:	04700593          	li	a1,71
ffffffffc0201210:	00001517          	auipc	a0,0x1
ffffffffc0201214:	f2850513          	addi	a0,a0,-216 # ffffffffc0202138 <commands+0x520>
ffffffffc0201218:	994ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020121c <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020121c:	100027f3          	csrr	a5,sstatus
ffffffffc0201220:	8b89                	andi	a5,a5,2
ffffffffc0201222:	e799                	bnez	a5,ffffffffc0201230 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201224:	00005797          	auipc	a5,0x5
ffffffffc0201228:	2247b783          	ld	a5,548(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020122c:	6f9c                	ld	a5,24(a5)
ffffffffc020122e:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201230:	1141                	addi	sp,sp,-16
ffffffffc0201232:	e406                	sd	ra,8(sp)
ffffffffc0201234:	e022                	sd	s0,0(sp)
ffffffffc0201236:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201238:	a26ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020123c:	00005797          	auipc	a5,0x5
ffffffffc0201240:	20c7b783          	ld	a5,524(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201244:	6f9c                	ld	a5,24(a5)
ffffffffc0201246:	8522                	mv	a0,s0
ffffffffc0201248:	9782                	jalr	a5
ffffffffc020124a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020124c:	a0cff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201250:	60a2                	ld	ra,8(sp)
ffffffffc0201252:	8522                	mv	a0,s0
ffffffffc0201254:	6402                	ld	s0,0(sp)
ffffffffc0201256:	0141                	addi	sp,sp,16
ffffffffc0201258:	8082                	ret

ffffffffc020125a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020125a:	100027f3          	csrr	a5,sstatus
ffffffffc020125e:	8b89                	andi	a5,a5,2
ffffffffc0201260:	e799                	bnez	a5,ffffffffc020126e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201262:	00005797          	auipc	a5,0x5
ffffffffc0201266:	1e67b783          	ld	a5,486(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020126a:	739c                	ld	a5,32(a5)
ffffffffc020126c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020126e:	1101                	addi	sp,sp,-32
ffffffffc0201270:	ec06                	sd	ra,24(sp)
ffffffffc0201272:	e822                	sd	s0,16(sp)
ffffffffc0201274:	e426                	sd	s1,8(sp)
ffffffffc0201276:	842a                	mv	s0,a0
ffffffffc0201278:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020127a:	9e4ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020127e:	00005797          	auipc	a5,0x5
ffffffffc0201282:	1ca7b783          	ld	a5,458(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201286:	739c                	ld	a5,32(a5)
ffffffffc0201288:	85a6                	mv	a1,s1
ffffffffc020128a:	8522                	mv	a0,s0
ffffffffc020128c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020128e:	6442                	ld	s0,16(sp)
ffffffffc0201290:	60e2                	ld	ra,24(sp)
ffffffffc0201292:	64a2                	ld	s1,8(sp)
ffffffffc0201294:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201296:	9c2ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc020129a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020129a:	100027f3          	csrr	a5,sstatus
ffffffffc020129e:	8b89                	andi	a5,a5,2
ffffffffc02012a0:	e799                	bnez	a5,ffffffffc02012ae <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02012a2:	00005797          	auipc	a5,0x5
ffffffffc02012a6:	1a67b783          	ld	a5,422(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012aa:	779c                	ld	a5,40(a5)
ffffffffc02012ac:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02012ae:	1141                	addi	sp,sp,-16
ffffffffc02012b0:	e406                	sd	ra,8(sp)
ffffffffc02012b2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012b4:	9aaff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012b8:	00005797          	auipc	a5,0x5
ffffffffc02012bc:	1907b783          	ld	a5,400(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012c0:	779c                	ld	a5,40(a5)
ffffffffc02012c2:	9782                	jalr	a5
ffffffffc02012c4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012c6:	992ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012ca:	60a2                	ld	ra,8(sp)
ffffffffc02012cc:	8522                	mv	a0,s0
ffffffffc02012ce:	6402                	ld	s0,0(sp)
ffffffffc02012d0:	0141                	addi	sp,sp,16
ffffffffc02012d2:	8082                	ret

ffffffffc02012d4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012d4:	00001797          	auipc	a5,0x1
ffffffffc02012d8:	18478793          	addi	a5,a5,388 # ffffffffc0202458 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012dc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012de:	1101                	addi	sp,sp,-32
ffffffffc02012e0:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012e2:	00001517          	auipc	a0,0x1
ffffffffc02012e6:	1ae50513          	addi	a0,a0,430 # ffffffffc0202490 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012ea:	00005497          	auipc	s1,0x5
ffffffffc02012ee:	15e48493          	addi	s1,s1,350 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02012f2:	ec06                	sd	ra,24(sp)
ffffffffc02012f4:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012f6:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012f8:	dbbfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02012fc:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012fe:	00005417          	auipc	s0,0x5
ffffffffc0201302:	16240413          	addi	s0,s0,354 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201306:	679c                	ld	a5,8(a5)
ffffffffc0201308:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020130a:	57f5                	li	a5,-3
ffffffffc020130c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020130e:	00001517          	auipc	a0,0x1
ffffffffc0201312:	19a50513          	addi	a0,a0,410 # ffffffffc02024a8 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201316:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201318:	d9bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020131c:	46c5                	li	a3,17
ffffffffc020131e:	06ee                	slli	a3,a3,0x1b
ffffffffc0201320:	40100613          	li	a2,1025
ffffffffc0201324:	16fd                	addi	a3,a3,-1
ffffffffc0201326:	07e005b7          	lui	a1,0x7e00
ffffffffc020132a:	0656                	slli	a2,a2,0x15
ffffffffc020132c:	00001517          	auipc	a0,0x1
ffffffffc0201330:	19450513          	addi	a0,a0,404 # ffffffffc02024c0 <best_fit_pmm_manager+0x68>
ffffffffc0201334:	d7ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201338:	777d                	lui	a4,0xfffff
ffffffffc020133a:	00006797          	auipc	a5,0x6
ffffffffc020133e:	13578793          	addi	a5,a5,309 # ffffffffc020746f <end+0xfff>
ffffffffc0201342:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201344:	00005517          	auipc	a0,0x5
ffffffffc0201348:	0f450513          	addi	a0,a0,244 # ffffffffc0206438 <npage>
ffffffffc020134c:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201350:	00005597          	auipc	a1,0x5
ffffffffc0201354:	0f058593          	addi	a1,a1,240 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201358:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020135a:	e19c                	sd	a5,0(a1)
ffffffffc020135c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020135e:	4701                	li	a4,0
ffffffffc0201360:	4885                	li	a7,1
ffffffffc0201362:	fff80837          	lui	a6,0xfff80
ffffffffc0201366:	a011                	j	ffffffffc020136a <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201368:	619c                	ld	a5,0(a1)
ffffffffc020136a:	97b6                	add	a5,a5,a3
ffffffffc020136c:	07a1                	addi	a5,a5,8
ffffffffc020136e:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201372:	611c                	ld	a5,0(a0)
ffffffffc0201374:	0705                	addi	a4,a4,1
ffffffffc0201376:	02868693          	addi	a3,a3,40
ffffffffc020137a:	01078633          	add	a2,a5,a6
ffffffffc020137e:	fec765e3          	bltu	a4,a2,ffffffffc0201368 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201382:	6190                	ld	a2,0(a1)
ffffffffc0201384:	00279713          	slli	a4,a5,0x2
ffffffffc0201388:	973e                	add	a4,a4,a5
ffffffffc020138a:	fec006b7          	lui	a3,0xfec00
ffffffffc020138e:	070e                	slli	a4,a4,0x3
ffffffffc0201390:	96b2                	add	a3,a3,a2
ffffffffc0201392:	96ba                	add	a3,a3,a4
ffffffffc0201394:	c0200737          	lui	a4,0xc0200
ffffffffc0201398:	08e6ef63          	bltu	a3,a4,ffffffffc0201436 <pmm_init+0x162>
ffffffffc020139c:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020139e:	45c5                	li	a1,17
ffffffffc02013a0:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013a2:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02013a4:	04b6e863          	bltu	a3,a1,ffffffffc02013f4 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02013a8:	609c                	ld	a5,0(s1)
ffffffffc02013aa:	7b9c                	ld	a5,48(a5)
ffffffffc02013ac:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013ae:	00001517          	auipc	a0,0x1
ffffffffc02013b2:	1aa50513          	addi	a0,a0,426 # ffffffffc0202558 <best_fit_pmm_manager+0x100>
ffffffffc02013b6:	cfdfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013ba:	00004597          	auipc	a1,0x4
ffffffffc02013be:	c4658593          	addi	a1,a1,-954 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013c2:	00005797          	auipc	a5,0x5
ffffffffc02013c6:	08b7bb23          	sd	a1,150(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02013ce:	08f5e063          	bltu	a1,a5,ffffffffc020144e <pmm_init+0x17a>
ffffffffc02013d2:	6010                	ld	a2,0(s0)
}
ffffffffc02013d4:	6442                	ld	s0,16(sp)
ffffffffc02013d6:	60e2                	ld	ra,24(sp)
ffffffffc02013d8:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013da:	40c58633          	sub	a2,a1,a2
ffffffffc02013de:	00005797          	auipc	a5,0x5
ffffffffc02013e2:	06c7b923          	sd	a2,114(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013e6:	00001517          	auipc	a0,0x1
ffffffffc02013ea:	19250513          	addi	a0,a0,402 # ffffffffc0202578 <best_fit_pmm_manager+0x120>
}
ffffffffc02013ee:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013f0:	cc3fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02013f4:	6705                	lui	a4,0x1
ffffffffc02013f6:	177d                	addi	a4,a4,-1
ffffffffc02013f8:	96ba                	add	a3,a3,a4
ffffffffc02013fa:	777d                	lui	a4,0xfffff
ffffffffc02013fc:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02013fe:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201402:	00f57e63          	bgeu	a0,a5,ffffffffc020141e <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201406:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201408:	982a                	add	a6,a6,a0
ffffffffc020140a:	00281513          	slli	a0,a6,0x2
ffffffffc020140e:	9542                	add	a0,a0,a6
ffffffffc0201410:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201412:	8d95                	sub	a1,a1,a3
ffffffffc0201414:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201416:	81b1                	srli	a1,a1,0xc
ffffffffc0201418:	9532                	add	a0,a0,a2
ffffffffc020141a:	9782                	jalr	a5
}
ffffffffc020141c:	b771                	j	ffffffffc02013a8 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020141e:	00001617          	auipc	a2,0x1
ffffffffc0201422:	10a60613          	addi	a2,a2,266 # ffffffffc0202528 <best_fit_pmm_manager+0xd0>
ffffffffc0201426:	06b00593          	li	a1,107
ffffffffc020142a:	00001517          	auipc	a0,0x1
ffffffffc020142e:	11e50513          	addi	a0,a0,286 # ffffffffc0202548 <best_fit_pmm_manager+0xf0>
ffffffffc0201432:	f7bfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201436:	00001617          	auipc	a2,0x1
ffffffffc020143a:	0ba60613          	addi	a2,a2,186 # ffffffffc02024f0 <best_fit_pmm_manager+0x98>
ffffffffc020143e:	06e00593          	li	a1,110
ffffffffc0201442:	00001517          	auipc	a0,0x1
ffffffffc0201446:	0d650513          	addi	a0,a0,214 # ffffffffc0202518 <best_fit_pmm_manager+0xc0>
ffffffffc020144a:	f63fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020144e:	86ae                	mv	a3,a1
ffffffffc0201450:	00001617          	auipc	a2,0x1
ffffffffc0201454:	0a060613          	addi	a2,a2,160 # ffffffffc02024f0 <best_fit_pmm_manager+0x98>
ffffffffc0201458:	08900593          	li	a1,137
ffffffffc020145c:	00001517          	auipc	a0,0x1
ffffffffc0201460:	0bc50513          	addi	a0,a0,188 # ffffffffc0202518 <best_fit_pmm_manager+0xc0>
ffffffffc0201464:	f49fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201468 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201468:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020146c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020146e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201472:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201474:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201478:	f022                	sd	s0,32(sp)
ffffffffc020147a:	ec26                	sd	s1,24(sp)
ffffffffc020147c:	e84a                	sd	s2,16(sp)
ffffffffc020147e:	f406                	sd	ra,40(sp)
ffffffffc0201480:	e44e                	sd	s3,8(sp)
ffffffffc0201482:	84aa                	mv	s1,a0
ffffffffc0201484:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201486:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020148a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020148c:	03067e63          	bgeu	a2,a6,ffffffffc02014c8 <printnum+0x60>
ffffffffc0201490:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201492:	00805763          	blez	s0,ffffffffc02014a0 <printnum+0x38>
ffffffffc0201496:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201498:	85ca                	mv	a1,s2
ffffffffc020149a:	854e                	mv	a0,s3
ffffffffc020149c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020149e:	fc65                	bnez	s0,ffffffffc0201496 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014a0:	1a02                	slli	s4,s4,0x20
ffffffffc02014a2:	00001797          	auipc	a5,0x1
ffffffffc02014a6:	11678793          	addi	a5,a5,278 # ffffffffc02025b8 <best_fit_pmm_manager+0x160>
ffffffffc02014aa:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014ae:	9a3e                	add	s4,s4,a5
}
ffffffffc02014b0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014b2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014b6:	70a2                	ld	ra,40(sp)
ffffffffc02014b8:	69a2                	ld	s3,8(sp)
ffffffffc02014ba:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014bc:	85ca                	mv	a1,s2
ffffffffc02014be:	87a6                	mv	a5,s1
}
ffffffffc02014c0:	6942                	ld	s2,16(sp)
ffffffffc02014c2:	64e2                	ld	s1,24(sp)
ffffffffc02014c4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014c6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014c8:	03065633          	divu	a2,a2,a6
ffffffffc02014cc:	8722                	mv	a4,s0
ffffffffc02014ce:	f9bff0ef          	jal	ra,ffffffffc0201468 <printnum>
ffffffffc02014d2:	b7f9                	j	ffffffffc02014a0 <printnum+0x38>

ffffffffc02014d4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014d4:	7119                	addi	sp,sp,-128
ffffffffc02014d6:	f4a6                	sd	s1,104(sp)
ffffffffc02014d8:	f0ca                	sd	s2,96(sp)
ffffffffc02014da:	ecce                	sd	s3,88(sp)
ffffffffc02014dc:	e8d2                	sd	s4,80(sp)
ffffffffc02014de:	e4d6                	sd	s5,72(sp)
ffffffffc02014e0:	e0da                	sd	s6,64(sp)
ffffffffc02014e2:	fc5e                	sd	s7,56(sp)
ffffffffc02014e4:	f06a                	sd	s10,32(sp)
ffffffffc02014e6:	fc86                	sd	ra,120(sp)
ffffffffc02014e8:	f8a2                	sd	s0,112(sp)
ffffffffc02014ea:	f862                	sd	s8,48(sp)
ffffffffc02014ec:	f466                	sd	s9,40(sp)
ffffffffc02014ee:	ec6e                	sd	s11,24(sp)
ffffffffc02014f0:	892a                	mv	s2,a0
ffffffffc02014f2:	84ae                	mv	s1,a1
ffffffffc02014f4:	8d32                	mv	s10,a2
ffffffffc02014f6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014f8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02014fc:	5b7d                	li	s6,-1
ffffffffc02014fe:	00001a97          	auipc	s5,0x1
ffffffffc0201502:	0eea8a93          	addi	s5,s5,238 # ffffffffc02025ec <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201506:	00001b97          	auipc	s7,0x1
ffffffffc020150a:	2c2b8b93          	addi	s7,s7,706 # ffffffffc02027c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020150e:	000d4503          	lbu	a0,0(s10)
ffffffffc0201512:	001d0413          	addi	s0,s10,1
ffffffffc0201516:	01350a63          	beq	a0,s3,ffffffffc020152a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020151a:	c121                	beqz	a0,ffffffffc020155a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020151c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020151e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201520:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201522:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201526:	ff351ae3          	bne	a0,s3,ffffffffc020151a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020152a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020152e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201532:	4c81                	li	s9,0
ffffffffc0201534:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201536:	5c7d                	li	s8,-1
ffffffffc0201538:	5dfd                	li	s11,-1
ffffffffc020153a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020153e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201540:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201544:	0ff5f593          	andi	a1,a1,255
ffffffffc0201548:	00140d13          	addi	s10,s0,1
ffffffffc020154c:	04b56263          	bltu	a0,a1,ffffffffc0201590 <vprintfmt+0xbc>
ffffffffc0201550:	058a                	slli	a1,a1,0x2
ffffffffc0201552:	95d6                	add	a1,a1,s5
ffffffffc0201554:	4194                	lw	a3,0(a1)
ffffffffc0201556:	96d6                	add	a3,a3,s5
ffffffffc0201558:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020155a:	70e6                	ld	ra,120(sp)
ffffffffc020155c:	7446                	ld	s0,112(sp)
ffffffffc020155e:	74a6                	ld	s1,104(sp)
ffffffffc0201560:	7906                	ld	s2,96(sp)
ffffffffc0201562:	69e6                	ld	s3,88(sp)
ffffffffc0201564:	6a46                	ld	s4,80(sp)
ffffffffc0201566:	6aa6                	ld	s5,72(sp)
ffffffffc0201568:	6b06                	ld	s6,64(sp)
ffffffffc020156a:	7be2                	ld	s7,56(sp)
ffffffffc020156c:	7c42                	ld	s8,48(sp)
ffffffffc020156e:	7ca2                	ld	s9,40(sp)
ffffffffc0201570:	7d02                	ld	s10,32(sp)
ffffffffc0201572:	6de2                	ld	s11,24(sp)
ffffffffc0201574:	6109                	addi	sp,sp,128
ffffffffc0201576:	8082                	ret
            padc = '0';
ffffffffc0201578:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020157a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020157e:	846a                	mv	s0,s10
ffffffffc0201580:	00140d13          	addi	s10,s0,1
ffffffffc0201584:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201588:	0ff5f593          	andi	a1,a1,255
ffffffffc020158c:	fcb572e3          	bgeu	a0,a1,ffffffffc0201550 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201590:	85a6                	mv	a1,s1
ffffffffc0201592:	02500513          	li	a0,37
ffffffffc0201596:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201598:	fff44783          	lbu	a5,-1(s0)
ffffffffc020159c:	8d22                	mv	s10,s0
ffffffffc020159e:	f73788e3          	beq	a5,s3,ffffffffc020150e <vprintfmt+0x3a>
ffffffffc02015a2:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02015a6:	1d7d                	addi	s10,s10,-1
ffffffffc02015a8:	ff379de3          	bne	a5,s3,ffffffffc02015a2 <vprintfmt+0xce>
ffffffffc02015ac:	b78d                	j	ffffffffc020150e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02015ae:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015b2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015b8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015bc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015c0:	02d86463          	bltu	a6,a3,ffffffffc02015e8 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02015c4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015c8:	002c169b          	slliw	a3,s8,0x2
ffffffffc02015cc:	0186873b          	addw	a4,a3,s8
ffffffffc02015d0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015d4:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02015d6:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02015da:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015dc:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02015e0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015e4:	fed870e3          	bgeu	a6,a3,ffffffffc02015c4 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02015e8:	f40ddce3          	bgez	s11,ffffffffc0201540 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02015ec:	8de2                	mv	s11,s8
ffffffffc02015ee:	5c7d                	li	s8,-1
ffffffffc02015f0:	bf81                	j	ffffffffc0201540 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02015f2:	fffdc693          	not	a3,s11
ffffffffc02015f6:	96fd                	srai	a3,a3,0x3f
ffffffffc02015f8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015fc:	00144603          	lbu	a2,1(s0)
ffffffffc0201600:	2d81                	sext.w	s11,s11
ffffffffc0201602:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201604:	bf35                	j	ffffffffc0201540 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201606:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020160a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020160e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201610:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201612:	bfd9                	j	ffffffffc02015e8 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201614:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201616:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020161a:	01174463          	blt	a4,a7,ffffffffc0201622 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020161e:	1a088e63          	beqz	a7,ffffffffc02017da <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201622:	000a3603          	ld	a2,0(s4)
ffffffffc0201626:	46c1                	li	a3,16
ffffffffc0201628:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020162a:	2781                	sext.w	a5,a5
ffffffffc020162c:	876e                	mv	a4,s11
ffffffffc020162e:	85a6                	mv	a1,s1
ffffffffc0201630:	854a                	mv	a0,s2
ffffffffc0201632:	e37ff0ef          	jal	ra,ffffffffc0201468 <printnum>
            break;
ffffffffc0201636:	bde1                	j	ffffffffc020150e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201638:	000a2503          	lw	a0,0(s4)
ffffffffc020163c:	85a6                	mv	a1,s1
ffffffffc020163e:	0a21                	addi	s4,s4,8
ffffffffc0201640:	9902                	jalr	s2
            break;
ffffffffc0201642:	b5f1                	j	ffffffffc020150e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201644:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201646:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020164a:	01174463          	blt	a4,a7,ffffffffc0201652 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020164e:	18088163          	beqz	a7,ffffffffc02017d0 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201652:	000a3603          	ld	a2,0(s4)
ffffffffc0201656:	46a9                	li	a3,10
ffffffffc0201658:	8a2e                	mv	s4,a1
ffffffffc020165a:	bfc1                	j	ffffffffc020162a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201660:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201662:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201664:	bdf1                	j	ffffffffc0201540 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201666:	85a6                	mv	a1,s1
ffffffffc0201668:	02500513          	li	a0,37
ffffffffc020166c:	9902                	jalr	s2
            break;
ffffffffc020166e:	b545                	j	ffffffffc020150e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201670:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201674:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201676:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201678:	b5e1                	j	ffffffffc0201540 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020167a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020167c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201680:	01174463          	blt	a4,a7,ffffffffc0201688 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201684:	14088163          	beqz	a7,ffffffffc02017c6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201688:	000a3603          	ld	a2,0(s4)
ffffffffc020168c:	46a1                	li	a3,8
ffffffffc020168e:	8a2e                	mv	s4,a1
ffffffffc0201690:	bf69                	j	ffffffffc020162a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201692:	03000513          	li	a0,48
ffffffffc0201696:	85a6                	mv	a1,s1
ffffffffc0201698:	e03e                	sd	a5,0(sp)
ffffffffc020169a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020169c:	85a6                	mv	a1,s1
ffffffffc020169e:	07800513          	li	a0,120
ffffffffc02016a2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016a4:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02016a6:	6782                	ld	a5,0(sp)
ffffffffc02016a8:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016aa:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02016ae:	bfb5                	j	ffffffffc020162a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016b0:	000a3403          	ld	s0,0(s4)
ffffffffc02016b4:	008a0713          	addi	a4,s4,8
ffffffffc02016b8:	e03a                	sd	a4,0(sp)
ffffffffc02016ba:	14040263          	beqz	s0,ffffffffc02017fe <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02016be:	0fb05763          	blez	s11,ffffffffc02017ac <vprintfmt+0x2d8>
ffffffffc02016c2:	02d00693          	li	a3,45
ffffffffc02016c6:	0cd79163          	bne	a5,a3,ffffffffc0201788 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016ca:	00044783          	lbu	a5,0(s0)
ffffffffc02016ce:	0007851b          	sext.w	a0,a5
ffffffffc02016d2:	cf85                	beqz	a5,ffffffffc020170a <vprintfmt+0x236>
ffffffffc02016d4:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016d8:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016dc:	000c4563          	bltz	s8,ffffffffc02016e6 <vprintfmt+0x212>
ffffffffc02016e0:	3c7d                	addiw	s8,s8,-1
ffffffffc02016e2:	036c0263          	beq	s8,s6,ffffffffc0201706 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02016e6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016e8:	0e0c8e63          	beqz	s9,ffffffffc02017e4 <vprintfmt+0x310>
ffffffffc02016ec:	3781                	addiw	a5,a5,-32
ffffffffc02016ee:	0ef47b63          	bgeu	s0,a5,ffffffffc02017e4 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02016f2:	03f00513          	li	a0,63
ffffffffc02016f6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016f8:	000a4783          	lbu	a5,0(s4)
ffffffffc02016fc:	3dfd                	addiw	s11,s11,-1
ffffffffc02016fe:	0a05                	addi	s4,s4,1
ffffffffc0201700:	0007851b          	sext.w	a0,a5
ffffffffc0201704:	ffe1                	bnez	a5,ffffffffc02016dc <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201706:	01b05963          	blez	s11,ffffffffc0201718 <vprintfmt+0x244>
ffffffffc020170a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020170c:	85a6                	mv	a1,s1
ffffffffc020170e:	02000513          	li	a0,32
ffffffffc0201712:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201714:	fe0d9be3          	bnez	s11,ffffffffc020170a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201718:	6a02                	ld	s4,0(sp)
ffffffffc020171a:	bbd5                	j	ffffffffc020150e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020171c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020171e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201722:	01174463          	blt	a4,a7,ffffffffc020172a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201726:	08088d63          	beqz	a7,ffffffffc02017c0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020172a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020172e:	0a044d63          	bltz	s0,ffffffffc02017e8 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201732:	8622                	mv	a2,s0
ffffffffc0201734:	8a66                	mv	s4,s9
ffffffffc0201736:	46a9                	li	a3,10
ffffffffc0201738:	bdcd                	j	ffffffffc020162a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020173a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020173e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201740:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201742:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201746:	8fb5                	xor	a5,a5,a3
ffffffffc0201748:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020174c:	02d74163          	blt	a4,a3,ffffffffc020176e <vprintfmt+0x29a>
ffffffffc0201750:	00369793          	slli	a5,a3,0x3
ffffffffc0201754:	97de                	add	a5,a5,s7
ffffffffc0201756:	639c                	ld	a5,0(a5)
ffffffffc0201758:	cb99                	beqz	a5,ffffffffc020176e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020175a:	86be                	mv	a3,a5
ffffffffc020175c:	00001617          	auipc	a2,0x1
ffffffffc0201760:	e8c60613          	addi	a2,a2,-372 # ffffffffc02025e8 <best_fit_pmm_manager+0x190>
ffffffffc0201764:	85a6                	mv	a1,s1
ffffffffc0201766:	854a                	mv	a0,s2
ffffffffc0201768:	0ce000ef          	jal	ra,ffffffffc0201836 <printfmt>
ffffffffc020176c:	b34d                	j	ffffffffc020150e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020176e:	00001617          	auipc	a2,0x1
ffffffffc0201772:	e6a60613          	addi	a2,a2,-406 # ffffffffc02025d8 <best_fit_pmm_manager+0x180>
ffffffffc0201776:	85a6                	mv	a1,s1
ffffffffc0201778:	854a                	mv	a0,s2
ffffffffc020177a:	0bc000ef          	jal	ra,ffffffffc0201836 <printfmt>
ffffffffc020177e:	bb41                	j	ffffffffc020150e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201780:	00001417          	auipc	s0,0x1
ffffffffc0201784:	e5040413          	addi	s0,s0,-432 # ffffffffc02025d0 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201788:	85e2                	mv	a1,s8
ffffffffc020178a:	8522                	mv	a0,s0
ffffffffc020178c:	e43e                	sd	a5,8(sp)
ffffffffc020178e:	1cc000ef          	jal	ra,ffffffffc020195a <strnlen>
ffffffffc0201792:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201796:	01b05b63          	blez	s11,ffffffffc02017ac <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020179a:	67a2                	ld	a5,8(sp)
ffffffffc020179c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017a0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017a2:	85a6                	mv	a1,s1
ffffffffc02017a4:	8552                	mv	a0,s4
ffffffffc02017a6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017a8:	fe0d9ce3          	bnez	s11,ffffffffc02017a0 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ac:	00044783          	lbu	a5,0(s0)
ffffffffc02017b0:	00140a13          	addi	s4,s0,1
ffffffffc02017b4:	0007851b          	sext.w	a0,a5
ffffffffc02017b8:	d3a5                	beqz	a5,ffffffffc0201718 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017ba:	05e00413          	li	s0,94
ffffffffc02017be:	bf39                	j	ffffffffc02016dc <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02017c0:	000a2403          	lw	s0,0(s4)
ffffffffc02017c4:	b7ad                	j	ffffffffc020172e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02017c6:	000a6603          	lwu	a2,0(s4)
ffffffffc02017ca:	46a1                	li	a3,8
ffffffffc02017cc:	8a2e                	mv	s4,a1
ffffffffc02017ce:	bdb1                	j	ffffffffc020162a <vprintfmt+0x156>
ffffffffc02017d0:	000a6603          	lwu	a2,0(s4)
ffffffffc02017d4:	46a9                	li	a3,10
ffffffffc02017d6:	8a2e                	mv	s4,a1
ffffffffc02017d8:	bd89                	j	ffffffffc020162a <vprintfmt+0x156>
ffffffffc02017da:	000a6603          	lwu	a2,0(s4)
ffffffffc02017de:	46c1                	li	a3,16
ffffffffc02017e0:	8a2e                	mv	s4,a1
ffffffffc02017e2:	b5a1                	j	ffffffffc020162a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02017e4:	9902                	jalr	s2
ffffffffc02017e6:	bf09                	j	ffffffffc02016f8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02017e8:	85a6                	mv	a1,s1
ffffffffc02017ea:	02d00513          	li	a0,45
ffffffffc02017ee:	e03e                	sd	a5,0(sp)
ffffffffc02017f0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02017f2:	6782                	ld	a5,0(sp)
ffffffffc02017f4:	8a66                	mv	s4,s9
ffffffffc02017f6:	40800633          	neg	a2,s0
ffffffffc02017fa:	46a9                	li	a3,10
ffffffffc02017fc:	b53d                	j	ffffffffc020162a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02017fe:	03b05163          	blez	s11,ffffffffc0201820 <vprintfmt+0x34c>
ffffffffc0201802:	02d00693          	li	a3,45
ffffffffc0201806:	f6d79de3          	bne	a5,a3,ffffffffc0201780 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020180a:	00001417          	auipc	s0,0x1
ffffffffc020180e:	dc640413          	addi	s0,s0,-570 # ffffffffc02025d0 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201812:	02800793          	li	a5,40
ffffffffc0201816:	02800513          	li	a0,40
ffffffffc020181a:	00140a13          	addi	s4,s0,1
ffffffffc020181e:	bd6d                	j	ffffffffc02016d8 <vprintfmt+0x204>
ffffffffc0201820:	00001a17          	auipc	s4,0x1
ffffffffc0201824:	db1a0a13          	addi	s4,s4,-591 # ffffffffc02025d1 <best_fit_pmm_manager+0x179>
ffffffffc0201828:	02800513          	li	a0,40
ffffffffc020182c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201830:	05e00413          	li	s0,94
ffffffffc0201834:	b565                	j	ffffffffc02016dc <vprintfmt+0x208>

ffffffffc0201836 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201836:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201838:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020183c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020183e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201840:	ec06                	sd	ra,24(sp)
ffffffffc0201842:	f83a                	sd	a4,48(sp)
ffffffffc0201844:	fc3e                	sd	a5,56(sp)
ffffffffc0201846:	e0c2                	sd	a6,64(sp)
ffffffffc0201848:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020184a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020184c:	c89ff0ef          	jal	ra,ffffffffc02014d4 <vprintfmt>
}
ffffffffc0201850:	60e2                	ld	ra,24(sp)
ffffffffc0201852:	6161                	addi	sp,sp,80
ffffffffc0201854:	8082                	ret

ffffffffc0201856 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201856:	715d                	addi	sp,sp,-80
ffffffffc0201858:	e486                	sd	ra,72(sp)
ffffffffc020185a:	e0a6                	sd	s1,64(sp)
ffffffffc020185c:	fc4a                	sd	s2,56(sp)
ffffffffc020185e:	f84e                	sd	s3,48(sp)
ffffffffc0201860:	f452                	sd	s4,40(sp)
ffffffffc0201862:	f056                	sd	s5,32(sp)
ffffffffc0201864:	ec5a                	sd	s6,24(sp)
ffffffffc0201866:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201868:	c901                	beqz	a0,ffffffffc0201878 <readline+0x22>
ffffffffc020186a:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020186c:	00001517          	auipc	a0,0x1
ffffffffc0201870:	d7c50513          	addi	a0,a0,-644 # ffffffffc02025e8 <best_fit_pmm_manager+0x190>
ffffffffc0201874:	83ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201878:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020187a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020187c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020187e:	4aa9                	li	s5,10
ffffffffc0201880:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201882:	00004b97          	auipc	s7,0x4
ffffffffc0201886:	7a6b8b93          	addi	s7,s7,1958 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020188a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020188e:	89dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201892:	00054a63          	bltz	a0,ffffffffc02018a6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201896:	00a95a63          	bge	s2,a0,ffffffffc02018aa <readline+0x54>
ffffffffc020189a:	029a5263          	bge	s4,s1,ffffffffc02018be <readline+0x68>
        c = getchar();
ffffffffc020189e:	88dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018a2:	fe055ae3          	bgez	a0,ffffffffc0201896 <readline+0x40>
            return NULL;
ffffffffc02018a6:	4501                	li	a0,0
ffffffffc02018a8:	a091                	j	ffffffffc02018ec <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02018aa:	03351463          	bne	a0,s3,ffffffffc02018d2 <readline+0x7c>
ffffffffc02018ae:	e8a9                	bnez	s1,ffffffffc0201900 <readline+0xaa>
        c = getchar();
ffffffffc02018b0:	87bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018b4:	fe0549e3          	bltz	a0,ffffffffc02018a6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018b8:	fea959e3          	bge	s2,a0,ffffffffc02018aa <readline+0x54>
ffffffffc02018bc:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018be:	e42a                	sd	a0,8(sp)
ffffffffc02018c0:	829fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02018c4:	6522                	ld	a0,8(sp)
ffffffffc02018c6:	009b87b3          	add	a5,s7,s1
ffffffffc02018ca:	2485                	addiw	s1,s1,1
ffffffffc02018cc:	00a78023          	sb	a0,0(a5)
ffffffffc02018d0:	bf7d                	j	ffffffffc020188e <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02018d2:	01550463          	beq	a0,s5,ffffffffc02018da <readline+0x84>
ffffffffc02018d6:	fb651ce3          	bne	a0,s6,ffffffffc020188e <readline+0x38>
            cputchar(c);
ffffffffc02018da:	80ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02018de:	00004517          	auipc	a0,0x4
ffffffffc02018e2:	74a50513          	addi	a0,a0,1866 # ffffffffc0206028 <buf>
ffffffffc02018e6:	94aa                	add	s1,s1,a0
ffffffffc02018e8:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02018ec:	60a6                	ld	ra,72(sp)
ffffffffc02018ee:	6486                	ld	s1,64(sp)
ffffffffc02018f0:	7962                	ld	s2,56(sp)
ffffffffc02018f2:	79c2                	ld	s3,48(sp)
ffffffffc02018f4:	7a22                	ld	s4,40(sp)
ffffffffc02018f6:	7a82                	ld	s5,32(sp)
ffffffffc02018f8:	6b62                	ld	s6,24(sp)
ffffffffc02018fa:	6bc2                	ld	s7,16(sp)
ffffffffc02018fc:	6161                	addi	sp,sp,80
ffffffffc02018fe:	8082                	ret
            cputchar(c);
ffffffffc0201900:	4521                	li	a0,8
ffffffffc0201902:	fe6fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201906:	34fd                	addiw	s1,s1,-1
ffffffffc0201908:	b759                	j	ffffffffc020188e <readline+0x38>

ffffffffc020190a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020190a:	4781                	li	a5,0
ffffffffc020190c:	00004717          	auipc	a4,0x4
ffffffffc0201910:	6fc73703          	ld	a4,1788(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201914:	88ba                	mv	a7,a4
ffffffffc0201916:	852a                	mv	a0,a0
ffffffffc0201918:	85be                	mv	a1,a5
ffffffffc020191a:	863e                	mv	a2,a5
ffffffffc020191c:	00000073          	ecall
ffffffffc0201920:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201922:	8082                	ret

ffffffffc0201924 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201924:	4781                	li	a5,0
ffffffffc0201926:	00005717          	auipc	a4,0x5
ffffffffc020192a:	b4273703          	ld	a4,-1214(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc020192e:	88ba                	mv	a7,a4
ffffffffc0201930:	852a                	mv	a0,a0
ffffffffc0201932:	85be                	mv	a1,a5
ffffffffc0201934:	863e                	mv	a2,a5
ffffffffc0201936:	00000073          	ecall
ffffffffc020193a:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020193c:	8082                	ret

ffffffffc020193e <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020193e:	4501                	li	a0,0
ffffffffc0201940:	00004797          	auipc	a5,0x4
ffffffffc0201944:	6c07b783          	ld	a5,1728(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201948:	88be                	mv	a7,a5
ffffffffc020194a:	852a                	mv	a0,a0
ffffffffc020194c:	85aa                	mv	a1,a0
ffffffffc020194e:	862a                	mv	a2,a0
ffffffffc0201950:	00000073          	ecall
ffffffffc0201954:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201956:	2501                	sext.w	a0,a0
ffffffffc0201958:	8082                	ret

ffffffffc020195a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020195a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020195c:	e589                	bnez	a1,ffffffffc0201966 <strnlen+0xc>
ffffffffc020195e:	a811                	j	ffffffffc0201972 <strnlen+0x18>
        cnt ++;
ffffffffc0201960:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201962:	00f58863          	beq	a1,a5,ffffffffc0201972 <strnlen+0x18>
ffffffffc0201966:	00f50733          	add	a4,a0,a5
ffffffffc020196a:	00074703          	lbu	a4,0(a4)
ffffffffc020196e:	fb6d                	bnez	a4,ffffffffc0201960 <strnlen+0x6>
ffffffffc0201970:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201972:	852e                	mv	a0,a1
ffffffffc0201974:	8082                	ret

ffffffffc0201976 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201976:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020197a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020197e:	cb89                	beqz	a5,ffffffffc0201990 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201980:	0505                	addi	a0,a0,1
ffffffffc0201982:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201984:	fee789e3          	beq	a5,a4,ffffffffc0201976 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201988:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020198c:	9d19                	subw	a0,a0,a4
ffffffffc020198e:	8082                	ret
ffffffffc0201990:	4501                	li	a0,0
ffffffffc0201992:	bfed                	j	ffffffffc020198c <strcmp+0x16>

ffffffffc0201994 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201994:	00054783          	lbu	a5,0(a0)
ffffffffc0201998:	c799                	beqz	a5,ffffffffc02019a6 <strchr+0x12>
        if (*s == c) {
ffffffffc020199a:	00f58763          	beq	a1,a5,ffffffffc02019a8 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020199e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02019a2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019a4:	fbfd                	bnez	a5,ffffffffc020199a <strchr+0x6>
    }
    return NULL;
ffffffffc02019a6:	4501                	li	a0,0
}
ffffffffc02019a8:	8082                	ret

ffffffffc02019aa <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019aa:	ca01                	beqz	a2,ffffffffc02019ba <memset+0x10>
ffffffffc02019ac:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019ae:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019b0:	0785                	addi	a5,a5,1
ffffffffc02019b2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019b6:	fec79de3          	bne	a5,a2,ffffffffc02019b0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019ba:	8082                	ret
