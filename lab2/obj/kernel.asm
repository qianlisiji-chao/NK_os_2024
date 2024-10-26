
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
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44660613          	addi	a2,a2,1094 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	794010ef          	jal	ra,ffffffffc02017de <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	79e50513          	addi	a0,a0,1950 # ffffffffc02017f0 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	088010ef          	jal	ra,ffffffffc02010ee <pmm_init>

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
ffffffffc02000a6:	248010ef          	jal	ra,ffffffffc02012ee <vprintfmt>
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
ffffffffc02000dc:	212010ef          	jal	ra,ffffffffc02012ee <vprintfmt>
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
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	6d450513          	addi	a0,a0,1748 # ffffffffc0201810 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	6de50513          	addi	a0,a0,1758 # ffffffffc0201830 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	69258593          	addi	a1,a1,1682 # ffffffffc02017f0 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201850 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	6f650513          	addi	a0,a0,1782 # ffffffffc0201870 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2fa58593          	addi	a1,a1,762 # ffffffffc0206480 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	70250513          	addi	a0,a0,1794 # ffffffffc0201890 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6e558593          	addi	a1,a1,1765 # ffffffffc020687f <end+0x3ff>
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
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	6f450513          	addi	a0,a0,1780 # ffffffffc02018b0 <etext+0xc0>
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
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	71660613          	addi	a2,a2,1814 # ffffffffc02018e0 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	72250513          	addi	a0,a0,1826 # ffffffffc02018f8 <etext+0x108>
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
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	72a60613          	addi	a2,a2,1834 # ffffffffc0201910 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	74258593          	addi	a1,a1,1858 # ffffffffc0201930 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	74250513          	addi	a0,a0,1858 # ffffffffc0201938 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	74460613          	addi	a2,a2,1860 # ffffffffc0201948 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	76458593          	addi	a1,a1,1892 # ffffffffc0201970 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	72450513          	addi	a0,a0,1828 # ffffffffc0201938 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	76060613          	addi	a2,a2,1888 # ffffffffc0201980 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	77858593          	addi	a1,a1,1912 # ffffffffc02019a0 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	70850513          	addi	a0,a0,1800 # ffffffffc0201938 <etext+0x148>
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
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	74650513          	addi	a0,a0,1862 # ffffffffc02019b0 <etext+0x1c0>
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
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	74c50513          	addi	a0,a0,1868 # ffffffffc02019d8 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	7a6c0c13          	addi	s8,s8,1958 # ffffffffc0201a48 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	75690913          	addi	s2,s2,1878 # ffffffffc0201a00 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	75648493          	addi	s1,s1,1878 # ffffffffc0201a08 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	754b0b13          	addi	s6,s6,1876 # ffffffffc0201a10 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	66ca0a13          	addi	s4,s4,1644 # ffffffffc0201930 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	3a0010ef          	jal	ra,ffffffffc0201670 <readline>
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
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	762d0d13          	addi	s10,s10,1890 # ffffffffc0201a48 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	4b6010ef          	jal	ra,ffffffffc02017aa <strcmp>
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
ffffffffc0200308:	4a2010ef          	jal	ra,ffffffffc02017aa <strcmp>
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
ffffffffc0200346:	482010ef          	jal	ra,ffffffffc02017c8 <strchr>
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
ffffffffc0200384:	444010ef          	jal	ra,ffffffffc02017c8 <strchr>
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
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	69250513          	addi	a0,a0,1682 # ffffffffc0201a30 <etext+0x240>
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
ffffffffc02003b0:	08430313          	addi	t1,t1,132 # ffffffffc0206430 <is_panic>
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
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	6b650513          	addi	a0,a0,1718 # ffffffffc0201a90 <commands+0x48>
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
ffffffffc02003f4:	4e850513          	addi	a0,a0,1256 # ffffffffc02018d8 <etext+0xe8>
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
ffffffffc0200420:	31e010ef          	jal	ra,ffffffffc020173e <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	68250513          	addi	a0,a0,1666 # ffffffffc0201ab0 <commands+0x68>
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
ffffffffc0200446:	2f80106f          	j	ffffffffc020173e <sbi_set_timer>

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
ffffffffc0200450:	2d40106f          	j	ffffffffc0201724 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	3040106f          	j	ffffffffc0201758 <sbi_console_getchar>

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
ffffffffc020046c:	30078793          	addi	a5,a5,768 # ffffffffc0200768 <__alltraps>
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
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	65250513          	addi	a0,a0,1618 # ffffffffc0201ad0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	65a50513          	addi	a0,a0,1626 # ffffffffc0201ae8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	66450513          	addi	a0,a0,1636 # ffffffffc0201b00 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	66e50513          	addi	a0,a0,1646 # ffffffffc0201b18 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	67850513          	addi	a0,a0,1656 # ffffffffc0201b30 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	68250513          	addi	a0,a0,1666 # ffffffffc0201b48 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	68c50513          	addi	a0,a0,1676 # ffffffffc0201b60 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	69650513          	addi	a0,a0,1686 # ffffffffc0201b78 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	6a050513          	addi	a0,a0,1696 # ffffffffc0201b90 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	6aa50513          	addi	a0,a0,1706 # ffffffffc0201ba8 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	6b450513          	addi	a0,a0,1716 # ffffffffc0201bc0 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	6be50513          	addi	a0,a0,1726 # ffffffffc0201bd8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	6c850513          	addi	a0,a0,1736 # ffffffffc0201bf0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	6d250513          	addi	a0,a0,1746 # ffffffffc0201c08 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	6dc50513          	addi	a0,a0,1756 # ffffffffc0201c20 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	6e650513          	addi	a0,a0,1766 # ffffffffc0201c38 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	6f050513          	addi	a0,a0,1776 # ffffffffc0201c50 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201c68 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	70450513          	addi	a0,a0,1796 # ffffffffc0201c80 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	70e50513          	addi	a0,a0,1806 # ffffffffc0201c98 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	71850513          	addi	a0,a0,1816 # ffffffffc0201cb0 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	72250513          	addi	a0,a0,1826 # ffffffffc0201cc8 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	72c50513          	addi	a0,a0,1836 # ffffffffc0201ce0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	73650513          	addi	a0,a0,1846 # ffffffffc0201cf8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	74050513          	addi	a0,a0,1856 # ffffffffc0201d10 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	74a50513          	addi	a0,a0,1866 # ffffffffc0201d28 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	75450513          	addi	a0,a0,1876 # ffffffffc0201d40 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	75e50513          	addi	a0,a0,1886 # ffffffffc0201d58 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	76850513          	addi	a0,a0,1896 # ffffffffc0201d70 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	77250513          	addi	a0,a0,1906 # ffffffffc0201d88 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	77c50513          	addi	a0,a0,1916 # ffffffffc0201da0 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	78250513          	addi	a0,a0,1922 # ffffffffc0201db8 <commands+0x370>
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
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	78650513          	addi	a0,a0,1926 # ffffffffc0201dd0 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	78650513          	addi	a0,a0,1926 # ffffffffc0201de8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	78e50513          	addi	a0,a0,1934 # ffffffffc0201e00 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	79650513          	addi	a0,a0,1942 # ffffffffc0201e18 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	79a50513          	addi	a0,a0,1946 # ffffffffc0201e30 <commands+0x3e8>
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
ffffffffc02006ac:	08f76263          	bltu	a4,a5,ffffffffc0200730 <interrupt_handler+0x8e>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	84870713          	addi	a4,a4,-1976 # ffffffffc0201ef8 <commands+0x4b0>
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
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	7e650513          	addi	a0,a0,2022 # ffffffffc0201ea8 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0201e88 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	77250513          	addi	a0,a0,1906 # ffffffffc0201e48 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	78850513          	addi	a0,a0,1928 # ffffffffc0201e68 <commands+0x420>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e022                	sd	s0,0(sp)
ffffffffc02006ee:	e406                	sd	ra,8(sp)
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   2213605 :  */
             //*(1)设置下次时钟中断- clock_set_next_event()
             clock_set_next_event();
ffffffffc02006f0:	d4bff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
             //*(2)计数器（ticks）加一
             ticks++;
ffffffffc02006f4:	00006797          	auipc	a5,0x6
ffffffffc02006f8:	d4478793          	addi	a5,a5,-700 # ffffffffc0206438 <ticks>
ffffffffc02006fc:	6398                	ld	a4,0(a5)
ffffffffc02006fe:	00006417          	auipc	s0,0x6
ffffffffc0200702:	d4240413          	addi	s0,s0,-702 # ffffffffc0206440 <num>
ffffffffc0200706:	0705                	addi	a4,a4,1
ffffffffc0200708:	e398                	sd	a4,0(a5)
             //*(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
             if(ticks % TICK_NUM == 0)
ffffffffc020070a:	639c                	ld	a5,0(a5)
ffffffffc020070c:	06400713          	li	a4,100
ffffffffc0200710:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200714:	cf99                	beqz	a5,ffffffffc0200732 <interrupt_handler+0x90>
             {
                num++;
                print_ticks();
             }
             //*(4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
             if(num == 10)
ffffffffc0200716:	6018                	ld	a4,0(s0)
ffffffffc0200718:	47a9                	li	a5,10
ffffffffc020071a:	02f70863          	beq	a4,a5,ffffffffc020074a <interrupt_handler+0xa8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020071e:	60a2                	ld	ra,8(sp)
ffffffffc0200720:	6402                	ld	s0,0(sp)
ffffffffc0200722:	0141                	addi	sp,sp,16
ffffffffc0200724:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200726:	00001517          	auipc	a0,0x1
ffffffffc020072a:	7b250513          	addi	a0,a0,1970 # ffffffffc0201ed8 <commands+0x490>
ffffffffc020072e:	b251                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200730:	bf09                	j	ffffffffc0200642 <print_trapframe>
                num++;
ffffffffc0200732:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200734:	06400593          	li	a1,100
ffffffffc0200738:	00001517          	auipc	a0,0x1
ffffffffc020073c:	79050513          	addi	a0,a0,1936 # ffffffffc0201ec8 <commands+0x480>
                num++;
ffffffffc0200740:	0785                	addi	a5,a5,1
ffffffffc0200742:	e01c                	sd	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200744:	96fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
}
ffffffffc0200748:	b7f9                	j	ffffffffc0200716 <interrupt_handler+0x74>
}
ffffffffc020074a:	6402                	ld	s0,0(sp)
ffffffffc020074c:	60a2                	ld	ra,8(sp)
ffffffffc020074e:	0141                	addi	sp,sp,16
                sbi_shutdown();
ffffffffc0200750:	0240106f          	j	ffffffffc0201774 <sbi_shutdown>

ffffffffc0200754 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200754:	11853783          	ld	a5,280(a0)
ffffffffc0200758:	0007c763          	bltz	a5,ffffffffc0200766 <trap+0x12>
    switch (tf->cause) {
ffffffffc020075c:	472d                	li	a4,11
ffffffffc020075e:	00f76363          	bltu	a4,a5,ffffffffc0200764 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200762:	8082                	ret
            print_trapframe(tf);
ffffffffc0200764:	bdf9                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200766:	bf35                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc0200768 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200768:	14011073          	csrw	sscratch,sp
ffffffffc020076c:	712d                	addi	sp,sp,-288
ffffffffc020076e:	e002                	sd	zero,0(sp)
ffffffffc0200770:	e406                	sd	ra,8(sp)
ffffffffc0200772:	ec0e                	sd	gp,24(sp)
ffffffffc0200774:	f012                	sd	tp,32(sp)
ffffffffc0200776:	f416                	sd	t0,40(sp)
ffffffffc0200778:	f81a                	sd	t1,48(sp)
ffffffffc020077a:	fc1e                	sd	t2,56(sp)
ffffffffc020077c:	e0a2                	sd	s0,64(sp)
ffffffffc020077e:	e4a6                	sd	s1,72(sp)
ffffffffc0200780:	e8aa                	sd	a0,80(sp)
ffffffffc0200782:	ecae                	sd	a1,88(sp)
ffffffffc0200784:	f0b2                	sd	a2,96(sp)
ffffffffc0200786:	f4b6                	sd	a3,104(sp)
ffffffffc0200788:	f8ba                	sd	a4,112(sp)
ffffffffc020078a:	fcbe                	sd	a5,120(sp)
ffffffffc020078c:	e142                	sd	a6,128(sp)
ffffffffc020078e:	e546                	sd	a7,136(sp)
ffffffffc0200790:	e94a                	sd	s2,144(sp)
ffffffffc0200792:	ed4e                	sd	s3,152(sp)
ffffffffc0200794:	f152                	sd	s4,160(sp)
ffffffffc0200796:	f556                	sd	s5,168(sp)
ffffffffc0200798:	f95a                	sd	s6,176(sp)
ffffffffc020079a:	fd5e                	sd	s7,184(sp)
ffffffffc020079c:	e1e2                	sd	s8,192(sp)
ffffffffc020079e:	e5e6                	sd	s9,200(sp)
ffffffffc02007a0:	e9ea                	sd	s10,208(sp)
ffffffffc02007a2:	edee                	sd	s11,216(sp)
ffffffffc02007a4:	f1f2                	sd	t3,224(sp)
ffffffffc02007a6:	f5f6                	sd	t4,232(sp)
ffffffffc02007a8:	f9fa                	sd	t5,240(sp)
ffffffffc02007aa:	fdfe                	sd	t6,248(sp)
ffffffffc02007ac:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007b0:	100024f3          	csrr	s1,sstatus
ffffffffc02007b4:	14102973          	csrr	s2,sepc
ffffffffc02007b8:	143029f3          	csrr	s3,stval
ffffffffc02007bc:	14202a73          	csrr	s4,scause
ffffffffc02007c0:	e822                	sd	s0,16(sp)
ffffffffc02007c2:	e226                	sd	s1,256(sp)
ffffffffc02007c4:	e64a                	sd	s2,264(sp)
ffffffffc02007c6:	ea4e                	sd	s3,272(sp)
ffffffffc02007c8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ca:	850a                	mv	a0,sp
    jal trap
ffffffffc02007cc:	f89ff0ef          	jal	ra,ffffffffc0200754 <trap>

ffffffffc02007d0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007d0:	6492                	ld	s1,256(sp)
ffffffffc02007d2:	6932                	ld	s2,264(sp)
ffffffffc02007d4:	10049073          	csrw	sstatus,s1
ffffffffc02007d8:	14191073          	csrw	sepc,s2
ffffffffc02007dc:	60a2                	ld	ra,8(sp)
ffffffffc02007de:	61e2                	ld	gp,24(sp)
ffffffffc02007e0:	7202                	ld	tp,32(sp)
ffffffffc02007e2:	72a2                	ld	t0,40(sp)
ffffffffc02007e4:	7342                	ld	t1,48(sp)
ffffffffc02007e6:	73e2                	ld	t2,56(sp)
ffffffffc02007e8:	6406                	ld	s0,64(sp)
ffffffffc02007ea:	64a6                	ld	s1,72(sp)
ffffffffc02007ec:	6546                	ld	a0,80(sp)
ffffffffc02007ee:	65e6                	ld	a1,88(sp)
ffffffffc02007f0:	7606                	ld	a2,96(sp)
ffffffffc02007f2:	76a6                	ld	a3,104(sp)
ffffffffc02007f4:	7746                	ld	a4,112(sp)
ffffffffc02007f6:	77e6                	ld	a5,120(sp)
ffffffffc02007f8:	680a                	ld	a6,128(sp)
ffffffffc02007fa:	68aa                	ld	a7,136(sp)
ffffffffc02007fc:	694a                	ld	s2,144(sp)
ffffffffc02007fe:	69ea                	ld	s3,152(sp)
ffffffffc0200800:	7a0a                	ld	s4,160(sp)
ffffffffc0200802:	7aaa                	ld	s5,168(sp)
ffffffffc0200804:	7b4a                	ld	s6,176(sp)
ffffffffc0200806:	7bea                	ld	s7,184(sp)
ffffffffc0200808:	6c0e                	ld	s8,192(sp)
ffffffffc020080a:	6cae                	ld	s9,200(sp)
ffffffffc020080c:	6d4e                	ld	s10,208(sp)
ffffffffc020080e:	6dee                	ld	s11,216(sp)
ffffffffc0200810:	7e0e                	ld	t3,224(sp)
ffffffffc0200812:	7eae                	ld	t4,232(sp)
ffffffffc0200814:	7f4e                	ld	t5,240(sp)
ffffffffc0200816:	7fee                	ld	t6,248(sp)
ffffffffc0200818:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020081a:	10200073          	sret

ffffffffc020081e <buddy_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020081e:	00005797          	auipc	a5,0x5
ffffffffc0200822:	7fa78793          	addi	a5,a5,2042 # ffffffffc0206018 <free_area>
ffffffffc0200826:	e79c                	sd	a5,8(a5)
ffffffffc0200828:	e39c                	sd	a5,0(a5)


static void
buddy_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020082a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020082e:	8082                	ret

ffffffffc0200830 <buddy_fit_nr_free_pages>:

static size_t
buddy_fit_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200830:	00005517          	auipc	a0,0x5
ffffffffc0200834:	7f856503          	lwu	a0,2040(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200838:	8082                	ret

ffffffffc020083a <buddy_fit_check>:
static void buddy_fit_check(void) {
ffffffffc020083a:	711d                	addi	sp,sp,-96
ffffffffc020083c:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020083e:	00005917          	auipc	s2,0x5
ffffffffc0200842:	7da90913          	addi	s2,s2,2010 # ffffffffc0206018 <free_area>
ffffffffc0200846:	00893783          	ld	a5,8(s2)
ffffffffc020084a:	ec86                	sd	ra,88(sp)
ffffffffc020084c:	e8a2                	sd	s0,80(sp)
ffffffffc020084e:	e4a6                	sd	s1,72(sp)
ffffffffc0200850:	fc4e                	sd	s3,56(sp)
ffffffffc0200852:	f852                	sd	s4,48(sp)
ffffffffc0200854:	f456                	sd	s5,40(sp)
ffffffffc0200856:	f05a                	sd	s6,32(sp)
ffffffffc0200858:	ec5e                	sd	s7,24(sp)
ffffffffc020085a:	e862                	sd	s8,16(sp)
ffffffffc020085c:	e466                	sd	s9,8(sp)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085e:	1b278263          	beq	a5,s2,ffffffffc0200a02 <buddy_fit_check+0x1c8>
    int count = 0, total = 0;
ffffffffc0200862:	4401                	li	s0,0
ffffffffc0200864:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200866:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020086a:	8b09                	andi	a4,a4,2
ffffffffc020086c:	1a070f63          	beqz	a4,ffffffffc0200a2a <buddy_fit_check+0x1f0>
        count++, total += p->property;
ffffffffc0200870:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200874:	679c                	ld	a5,8(a5)
ffffffffc0200876:	2485                	addiw	s1,s1,1
ffffffffc0200878:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020087a:	ff2796e3          	bne	a5,s2,ffffffffc0200866 <buddy_fit_check+0x2c>
    assert(total == nr_free_pages());
ffffffffc020087e:	89a2                	mv	s3,s0
ffffffffc0200880:	035000ef          	jal	ra,ffffffffc02010b4 <nr_free_pages>
ffffffffc0200884:	2b351363          	bne	a0,s3,ffffffffc0200b2a <buddy_fit_check+0x2f0>
    struct Page *p0 = alloc_pages(26), *p1;
ffffffffc0200888:	4569                	li	a0,26
ffffffffc020088a:	7ac000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
ffffffffc020088e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200890:	24050d63          	beqz	a0,ffffffffc0200aea <buddy_fit_check+0x2b0>
ffffffffc0200894:	651c                	ld	a5,8(a0)
ffffffffc0200896:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200898:	8b85                	andi	a5,a5,1
ffffffffc020089a:	3a079863          	bnez	a5,ffffffffc0200c4a <buddy_fit_check+0x410>
    assert(alloc_page() == NULL);
ffffffffc020089e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02008a0:	00093b03          	ld	s6,0(s2)
ffffffffc02008a4:	00893a83          	ld	s5,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02008a8:	01092b83          	lw	s7,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02008ac:	01293423          	sd	s2,8(s2)
ffffffffc02008b0:	01293023          	sd	s2,0(s2)
    nr_free = 0;
ffffffffc02008b4:	00005797          	auipc	a5,0x5
ffffffffc02008b8:	7607aa23          	sw	zero,1908(a5) # ffffffffc0206028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02008bc:	77a000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
ffffffffc02008c0:	2a051563          	bnez	a0,ffffffffc0200b6a <buddy_fit_check+0x330>
    free_pages(p0, 26);
ffffffffc02008c4:	45e9                	li	a1,26
ffffffffc02008c6:	854e                	mv	a0,s3
ffffffffc02008c8:	7ac000ef          	jal	ra,ffffffffc0201074 <free_pages>
    p0 = alloc_pages(6);
ffffffffc02008cc:	4519                	li	a0,6
ffffffffc02008ce:	768000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
ffffffffc02008d2:	89aa                	mv	s3,a0
    p1 = alloc_pages(10);
ffffffffc02008d4:	4529                	li	a0,10
ffffffffc02008d6:	760000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
    assert((p0 + 8)->property == 8);
ffffffffc02008da:	1509ac03          	lw	s8,336(s3)
ffffffffc02008de:	47a1                	li	a5,8
    p1 = alloc_pages(10);
ffffffffc02008e0:	8a2a                	mv	s4,a0
    assert((p0 + 8)->property == 8);
ffffffffc02008e2:	1afc1463          	bne	s8,a5,ffffffffc0200a8a <buddy_fit_check+0x250>
    free_pages(p1, 10);
ffffffffc02008e6:	45a9                	li	a1,10
ffffffffc02008e8:	78c000ef          	jal	ra,ffffffffc0201074 <free_pages>
    assert((p0 + 8)->property == 8);
ffffffffc02008ec:	1509a783          	lw	a5,336(s3)
ffffffffc02008f0:	17879d63          	bne	a5,s8,ffffffffc0200a6a <buddy_fit_check+0x230>
    assert(p1->property == 16);
ffffffffc02008f4:	010a2c83          	lw	s9,16(s4)
ffffffffc02008f8:	47c1                	li	a5,16
ffffffffc02008fa:	20fc9863          	bne	s9,a5,ffffffffc0200b0a <buddy_fit_check+0x2d0>
    p1 = alloc_pages(16);
ffffffffc02008fe:	4541                	li	a0,16
ffffffffc0200900:	736000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
ffffffffc0200904:	8a2a                	mv	s4,a0
    free_pages(p0, 6);
ffffffffc0200906:	4599                	li	a1,6
ffffffffc0200908:	854e                	mv	a0,s3
ffffffffc020090a:	76a000ef          	jal	ra,ffffffffc0201074 <free_pages>
    assert(p0->property == 16);
ffffffffc020090e:	0109ac03          	lw	s8,16(s3)
ffffffffc0200912:	139c1c63          	bne	s8,s9,ffffffffc0200a4a <buddy_fit_check+0x210>
    free_pages(p1, 16);
ffffffffc0200916:	45c1                	li	a1,16
ffffffffc0200918:	8552                	mv	a0,s4
ffffffffc020091a:	75a000ef          	jal	ra,ffffffffc0201074 <free_pages>
    assert(p0->property == 32);
ffffffffc020091e:	0109a703          	lw	a4,16(s3)
ffffffffc0200922:	02000793          	li	a5,32
ffffffffc0200926:	1af71263          	bne	a4,a5,ffffffffc0200aca <buddy_fit_check+0x290>
    p0 = alloc_pages(8);
ffffffffc020092a:	4521                	li	a0,8
ffffffffc020092c:	70a000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
ffffffffc0200930:	89aa                	mv	s3,a0
    p1 = alloc_pages(9);
ffffffffc0200932:	4525                	li	a0,9
ffffffffc0200934:	702000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
    free_pages(p1, 9);
ffffffffc0200938:	45a5                	li	a1,9
    p1 = alloc_pages(9);
ffffffffc020093a:	8a2a                	mv	s4,a0
    free_pages(p1, 9);
ffffffffc020093c:	738000ef          	jal	ra,ffffffffc0201074 <free_pages>
    assert(p1->property == 16);
ffffffffc0200940:	010a2783          	lw	a5,16(s4)
ffffffffc0200944:	17879363          	bne	a5,s8,ffffffffc0200aaa <buddy_fit_check+0x270>
    assert((p0 + 8)->property == 8);
ffffffffc0200948:	1509a703          	lw	a4,336(s3)
ffffffffc020094c:	47a1                	li	a5,8
ffffffffc020094e:	2af71e63          	bne	a4,a5,ffffffffc0200c0a <buddy_fit_check+0x3d0>
    free_pages(p0, 8);
ffffffffc0200952:	45a1                	li	a1,8
ffffffffc0200954:	854e                	mv	a0,s3
ffffffffc0200956:	71e000ef          	jal	ra,ffffffffc0201074 <free_pages>
    assert(p0->property == 32);
ffffffffc020095a:	0109a703          	lw	a4,16(s3)
ffffffffc020095e:	02000793          	li	a5,32
ffffffffc0200962:	28f71463          	bne	a4,a5,ffffffffc0200bea <buddy_fit_check+0x3b0>
    p0 = alloc_pages(5);
ffffffffc0200966:	4515                	li	a0,5
ffffffffc0200968:	6ce000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
ffffffffc020096c:	89aa                	mv	s3,a0
    p1 = alloc_pages(16);
ffffffffc020096e:	4541                	li	a0,16
ffffffffc0200970:	6c6000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
    free_pages(p1, 16);
ffffffffc0200974:	45c1                	li	a1,16
    p1 = alloc_pages(16);
ffffffffc0200976:	8a2a                	mv	s4,a0
    free_pages(p1, 16);
ffffffffc0200978:	6fc000ef          	jal	ra,ffffffffc0201074 <free_pages>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc020097c:	00893783          	ld	a5,8(s2)
ffffffffc0200980:	ed8a0a13          	addi	s4,s4,-296
ffffffffc0200984:	25479363          	bne	a5,s4,ffffffffc0200bca <buddy_fit_check+0x390>
    free_pages(p0, 5);
ffffffffc0200988:	854e                	mv	a0,s3
ffffffffc020098a:	4595                	li	a1,5
ffffffffc020098c:	6e8000ef          	jal	ra,ffffffffc0201074 <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200990:	00893783          	ld	a5,8(s2)
ffffffffc0200994:	09e1                	addi	s3,s3,24
ffffffffc0200996:	21379a63          	bne	a5,s3,ffffffffc0200baa <buddy_fit_check+0x370>
    p0 = alloc_pages(26);
ffffffffc020099a:	4569                	li	a0,26
ffffffffc020099c:	69a000ef          	jal	ra,ffffffffc0201036 <alloc_pages>
    assert(nr_free == 0);
ffffffffc02009a0:	01092783          	lw	a5,16(s2)
ffffffffc02009a4:	1e079363          	bnez	a5,ffffffffc0200b8a <buddy_fit_check+0x350>
    free_pages(p0, 26);
ffffffffc02009a8:	45e9                	li	a1,26
    nr_free = nr_free_store;
ffffffffc02009aa:	01792823          	sw	s7,16(s2)
    free_list = free_list_store;
ffffffffc02009ae:	01693023          	sd	s6,0(s2)
ffffffffc02009b2:	01593423          	sd	s5,8(s2)
    free_pages(p0, 26);
ffffffffc02009b6:	6be000ef          	jal	ra,ffffffffc0201074 <free_pages>
    return listelm->next;
ffffffffc02009ba:	00893783          	ld	a5,8(s2)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009be:	03278163          	beq	a5,s2,ffffffffc02009e0 <buddy_fit_check+0x1a6>
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc02009c2:	86be                	mv	a3,a5
ffffffffc02009c4:	679c                	ld	a5,8(a5)
ffffffffc02009c6:	6398                	ld	a4,0(a5)
ffffffffc02009c8:	04d71163          	bne	a4,a3,ffffffffc0200a0a <buddy_fit_check+0x1d0>
ffffffffc02009cc:	6314                	ld	a3,0(a4)
ffffffffc02009ce:	6694                	ld	a3,8(a3)
ffffffffc02009d0:	02e69d63          	bne	a3,a4,ffffffffc0200a0a <buddy_fit_check+0x1d0>
        count--, total -= p->property;
ffffffffc02009d4:	ff86a703          	lw	a4,-8(a3)
ffffffffc02009d8:	34fd                	addiw	s1,s1,-1
ffffffffc02009da:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009dc:	ff2793e3          	bne	a5,s2,ffffffffc02009c2 <buddy_fit_check+0x188>
    assert(count == 0);
ffffffffc02009e0:	24049563          	bnez	s1,ffffffffc0200c2a <buddy_fit_check+0x3f0>
    assert(total == 0);
ffffffffc02009e4:	16041363          	bnez	s0,ffffffffc0200b4a <buddy_fit_check+0x310>
}
ffffffffc02009e8:	60e6                	ld	ra,88(sp)
ffffffffc02009ea:	6446                	ld	s0,80(sp)
ffffffffc02009ec:	64a6                	ld	s1,72(sp)
ffffffffc02009ee:	6906                	ld	s2,64(sp)
ffffffffc02009f0:	79e2                	ld	s3,56(sp)
ffffffffc02009f2:	7a42                	ld	s4,48(sp)
ffffffffc02009f4:	7aa2                	ld	s5,40(sp)
ffffffffc02009f6:	7b02                	ld	s6,32(sp)
ffffffffc02009f8:	6be2                	ld	s7,24(sp)
ffffffffc02009fa:	6c42                	ld	s8,16(sp)
ffffffffc02009fc:	6ca2                	ld	s9,8(sp)
ffffffffc02009fe:	6125                	addi	sp,sp,96
ffffffffc0200a00:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a02:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200a04:	4401                	li	s0,0
ffffffffc0200a06:	4481                	li	s1,0
ffffffffc0200a08:	bda5                	j	ffffffffc0200880 <buddy_fit_check+0x46>
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc0200a0a:	00001697          	auipc	a3,0x1
ffffffffc0200a0e:	68e68693          	addi	a3,a3,1678 # ffffffffc0202098 <commands+0x650>
ffffffffc0200a12:	00001617          	auipc	a2,0x1
ffffffffc0200a16:	52660613          	addi	a2,a2,1318 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200a1a:	21c00593          	li	a1,540
ffffffffc0200a1e:	00001517          	auipc	a0,0x1
ffffffffc0200a22:	53250513          	addi	a0,a0,1330 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200a26:	987ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        assert(PageProperty(p));
ffffffffc0200a2a:	00001697          	auipc	a3,0x1
ffffffffc0200a2e:	4fe68693          	addi	a3,a3,1278 # ffffffffc0201f28 <commands+0x4e0>
ffffffffc0200a32:	00001617          	auipc	a2,0x1
ffffffffc0200a36:	50660613          	addi	a2,a2,1286 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200a3a:	1d900593          	li	a1,473
ffffffffc0200a3e:	00001517          	auipc	a0,0x1
ffffffffc0200a42:	51250513          	addi	a0,a0,1298 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200a46:	967ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0->property == 16);
ffffffffc0200a4a:	00001697          	auipc	a3,0x1
ffffffffc0200a4e:	5a668693          	addi	a3,a3,1446 # ffffffffc0201ff0 <commands+0x5a8>
ffffffffc0200a52:	00001617          	auipc	a2,0x1
ffffffffc0200a56:	4e660613          	addi	a2,a2,1254 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200a5a:	1fc00593          	li	a1,508
ffffffffc0200a5e:	00001517          	auipc	a0,0x1
ffffffffc0200a62:	4f250513          	addi	a0,a0,1266 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200a66:	947ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200a6a:	00001697          	auipc	a3,0x1
ffffffffc0200a6e:	55668693          	addi	a3,a3,1366 # ffffffffc0201fc0 <commands+0x578>
ffffffffc0200a72:	00001617          	auipc	a2,0x1
ffffffffc0200a76:	4c660613          	addi	a2,a2,1222 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200a7a:	1f700593          	li	a1,503
ffffffffc0200a7e:	00001517          	auipc	a0,0x1
ffffffffc0200a82:	4d250513          	addi	a0,a0,1234 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200a86:	927ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200a8a:	00001697          	auipc	a3,0x1
ffffffffc0200a8e:	53668693          	addi	a3,a3,1334 # ffffffffc0201fc0 <commands+0x578>
ffffffffc0200a92:	00001617          	auipc	a2,0x1
ffffffffc0200a96:	4a660613          	addi	a2,a2,1190 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200a9a:	1f500593          	li	a1,501
ffffffffc0200a9e:	00001517          	auipc	a0,0x1
ffffffffc0200aa2:	4b250513          	addi	a0,a0,1202 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200aa6:	907ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->property == 16);
ffffffffc0200aaa:	00001697          	auipc	a3,0x1
ffffffffc0200aae:	52e68693          	addi	a3,a3,1326 # ffffffffc0201fd8 <commands+0x590>
ffffffffc0200ab2:	00001617          	auipc	a2,0x1
ffffffffc0200ab6:	48660613          	addi	a2,a2,1158 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200aba:	20400593          	li	a1,516
ffffffffc0200abe:	00001517          	auipc	a0,0x1
ffffffffc0200ac2:	49250513          	addi	a0,a0,1170 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200ac6:	8e7ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0->property == 32);
ffffffffc0200aca:	00001697          	auipc	a3,0x1
ffffffffc0200ace:	53e68693          	addi	a3,a3,1342 # ffffffffc0202008 <commands+0x5c0>
ffffffffc0200ad2:	00001617          	auipc	a2,0x1
ffffffffc0200ad6:	46660613          	addi	a2,a2,1126 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200ada:	1fe00593          	li	a1,510
ffffffffc0200ade:	00001517          	auipc	a0,0x1
ffffffffc0200ae2:	47250513          	addi	a0,a0,1138 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200ae6:	8c7ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200aea:	00001697          	auipc	a3,0x1
ffffffffc0200aee:	49668693          	addi	a3,a3,1174 # ffffffffc0201f80 <commands+0x538>
ffffffffc0200af2:	00001617          	auipc	a2,0x1
ffffffffc0200af6:	44660613          	addi	a2,a2,1094 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200afa:	1e200593          	li	a1,482
ffffffffc0200afe:	00001517          	auipc	a0,0x1
ffffffffc0200b02:	45250513          	addi	a0,a0,1106 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200b06:	8a7ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->property == 16);
ffffffffc0200b0a:	00001697          	auipc	a3,0x1
ffffffffc0200b0e:	4ce68693          	addi	a3,a3,1230 # ffffffffc0201fd8 <commands+0x590>
ffffffffc0200b12:	00001617          	auipc	a2,0x1
ffffffffc0200b16:	42660613          	addi	a2,a2,1062 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200b1a:	1f800593          	li	a1,504
ffffffffc0200b1e:	00001517          	auipc	a0,0x1
ffffffffc0200b22:	43250513          	addi	a0,a0,1074 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200b26:	887ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200b2a:	00001697          	auipc	a3,0x1
ffffffffc0200b2e:	43668693          	addi	a3,a3,1078 # ffffffffc0201f60 <commands+0x518>
ffffffffc0200b32:	00001617          	auipc	a2,0x1
ffffffffc0200b36:	40660613          	addi	a2,a2,1030 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200b3a:	1dc00593          	li	a1,476
ffffffffc0200b3e:	00001517          	auipc	a0,0x1
ffffffffc0200b42:	41250513          	addi	a0,a0,1042 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200b46:	867ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200b4a:	00001697          	auipc	a3,0x1
ffffffffc0200b4e:	58e68693          	addi	a3,a3,1422 # ffffffffc02020d8 <commands+0x690>
ffffffffc0200b52:	00001617          	auipc	a2,0x1
ffffffffc0200b56:	3e660613          	addi	a2,a2,998 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200b5a:	22100593          	li	a1,545
ffffffffc0200b5e:	00001517          	auipc	a0,0x1
ffffffffc0200b62:	3f250513          	addi	a0,a0,1010 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200b66:	847ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200b6a:	00001697          	auipc	a3,0x1
ffffffffc0200b6e:	43e68693          	addi	a3,a3,1086 # ffffffffc0201fa8 <commands+0x560>
ffffffffc0200b72:	00001617          	auipc	a2,0x1
ffffffffc0200b76:	3c660613          	addi	a2,a2,966 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200b7a:	1ed00593          	li	a1,493
ffffffffc0200b7e:	00001517          	auipc	a0,0x1
ffffffffc0200b82:	3d250513          	addi	a0,a0,978 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200b86:	827ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200b8a:	00001697          	auipc	a3,0x1
ffffffffc0200b8e:	4fe68693          	addi	a3,a3,1278 # ffffffffc0202088 <commands+0x640>
ffffffffc0200b92:	00001617          	auipc	a2,0x1
ffffffffc0200b96:	3a660613          	addi	a2,a2,934 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200b9a:	21300593          	li	a1,531
ffffffffc0200b9e:	00001517          	auipc	a0,0x1
ffffffffc0200ba2:	3b250513          	addi	a0,a0,946 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200ba6:	807ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200baa:	00001697          	auipc	a3,0x1
ffffffffc0200bae:	4ae68693          	addi	a3,a3,1198 # ffffffffc0202058 <commands+0x610>
ffffffffc0200bb2:	00001617          	auipc	a2,0x1
ffffffffc0200bb6:	38660613          	addi	a2,a2,902 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200bba:	20f00593          	li	a1,527
ffffffffc0200bbe:	00001517          	auipc	a0,0x1
ffffffffc0200bc2:	39250513          	addi	a0,a0,914 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200bc6:	fe6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc0200bca:	00001697          	auipc	a3,0x1
ffffffffc0200bce:	45668693          	addi	a3,a3,1110 # ffffffffc0202020 <commands+0x5d8>
ffffffffc0200bd2:	00001617          	auipc	a2,0x1
ffffffffc0200bd6:	36660613          	addi	a2,a2,870 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200bda:	20d00593          	li	a1,525
ffffffffc0200bde:	00001517          	auipc	a0,0x1
ffffffffc0200be2:	37250513          	addi	a0,a0,882 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200be6:	fc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0->property == 32);
ffffffffc0200bea:	00001697          	auipc	a3,0x1
ffffffffc0200bee:	41e68693          	addi	a3,a3,1054 # ffffffffc0202008 <commands+0x5c0>
ffffffffc0200bf2:	00001617          	auipc	a2,0x1
ffffffffc0200bf6:	34660613          	addi	a2,a2,838 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200bfa:	20700593          	li	a1,519
ffffffffc0200bfe:	00001517          	auipc	a0,0x1
ffffffffc0200c02:	35250513          	addi	a0,a0,850 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200c06:	fa6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200c0a:	00001697          	auipc	a3,0x1
ffffffffc0200c0e:	3b668693          	addi	a3,a3,950 # ffffffffc0201fc0 <commands+0x578>
ffffffffc0200c12:	00001617          	auipc	a2,0x1
ffffffffc0200c16:	32660613          	addi	a2,a2,806 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200c1a:	20500593          	li	a1,517
ffffffffc0200c1e:	00001517          	auipc	a0,0x1
ffffffffc0200c22:	33250513          	addi	a0,a0,818 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200c26:	f86ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200c2a:	00001697          	auipc	a3,0x1
ffffffffc0200c2e:	49e68693          	addi	a3,a3,1182 # ffffffffc02020c8 <commands+0x680>
ffffffffc0200c32:	00001617          	auipc	a2,0x1
ffffffffc0200c36:	30660613          	addi	a2,a2,774 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200c3a:	22000593          	li	a1,544
ffffffffc0200c3e:	00001517          	auipc	a0,0x1
ffffffffc0200c42:	31250513          	addi	a0,a0,786 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200c46:	f66ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200c4a:	00001697          	auipc	a3,0x1
ffffffffc0200c4e:	34668693          	addi	a3,a3,838 # ffffffffc0201f90 <commands+0x548>
ffffffffc0200c52:	00001617          	auipc	a2,0x1
ffffffffc0200c56:	2e660613          	addi	a2,a2,742 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200c5a:	1e300593          	li	a1,483
ffffffffc0200c5e:	00001517          	auipc	a0,0x1
ffffffffc0200c62:	2f250513          	addi	a0,a0,754 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200c66:	f46ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c6a <buddy_fit_free_pages>:
{
ffffffffc0200c6a:	1141                	addi	sp,sp,-16
ffffffffc0200c6c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c6e:	18058a63          	beqz	a1,ffffffffc0200e02 <buddy_fit_free_pages+0x198>
    while (num > 1)
ffffffffc0200c72:	4605                	li	a2,1
ffffffffc0200c74:	87ae                	mv	a5,a1
    size_t exp = 0;
ffffffffc0200c76:	4701                	li	a4,0
    while (num > 1)
ffffffffc0200c78:	4685                	li	a3,1
ffffffffc0200c7a:	00c58d63          	beq	a1,a2,ffffffffc0200c94 <buddy_fit_free_pages+0x2a>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc0200c7e:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc0200c80:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc0200c82:	fed79ee3          	bne	a5,a3,ffffffffc0200c7e <buddy_fit_free_pages+0x14>
    return (size_t)(1 << exp);
ffffffffc0200c86:	4785                	li	a5,1
ffffffffc0200c88:	00e7973b          	sllw	a4,a5,a4
    if (size < n)
ffffffffc0200c8c:	00b77463          	bgeu	a4,a1,ffffffffc0200c94 <buddy_fit_free_pages+0x2a>
        n = 2 * size;
ffffffffc0200c90:	00171593          	slli	a1,a4,0x1
    for (; p != base + n; p++)
ffffffffc0200c94:	00259693          	slli	a3,a1,0x2
ffffffffc0200c98:	96ae                	add	a3,a3,a1
ffffffffc0200c9a:	068e                	slli	a3,a3,0x3
ffffffffc0200c9c:	96aa                	add	a3,a3,a0
ffffffffc0200c9e:	87aa                	mv	a5,a0
ffffffffc0200ca0:	02d50263          	beq	a0,a3,ffffffffc0200cc4 <buddy_fit_free_pages+0x5a>
ffffffffc0200ca4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ca6:	8b05                	andi	a4,a4,1
ffffffffc0200ca8:	12071d63          	bnez	a4,ffffffffc0200de2 <buddy_fit_free_pages+0x178>
ffffffffc0200cac:	6798                	ld	a4,8(a5)
ffffffffc0200cae:	8b09                	andi	a4,a4,2
ffffffffc0200cb0:	12071963          	bnez	a4,ffffffffc0200de2 <buddy_fit_free_pages+0x178>
        p->flags = 0;
ffffffffc0200cb4:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200cb8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200cbc:	02878793          	addi	a5,a5,40
ffffffffc0200cc0:	fed792e3          	bne	a5,a3,ffffffffc0200ca4 <buddy_fit_free_pages+0x3a>
    base->property = n;
ffffffffc0200cc4:	2581                	sext.w	a1,a1
ffffffffc0200cc6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200cc8:	00850313          	addi	t1,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ccc:	4789                	li	a5,2
ffffffffc0200cce:	40f3302f          	amoor.d	zero,a5,(t1)
    nr_free += n;
ffffffffc0200cd2:	00005817          	auipc	a6,0x5
ffffffffc0200cd6:	34680813          	addi	a6,a6,838 # ffffffffc0206018 <free_area>
ffffffffc0200cda:	01082703          	lw	a4,16(a6)
ffffffffc0200cde:	00883783          	ld	a5,8(a6)
ffffffffc0200ce2:	9db9                	addw	a1,a1,a4
ffffffffc0200ce4:	00b82823          	sw	a1,16(a6)
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc0200ce8:	0f078b63          	beq	a5,a6,ffffffffc0200dde <buddy_fit_free_pages+0x174>
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc0200cec:	4910                	lw	a2,16(a0)
ffffffffc0200cee:	a021                	j	ffffffffc0200cf6 <buddy_fit_free_pages+0x8c>
ffffffffc0200cf0:	679c                	ld	a5,8(a5)
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc0200cf2:	01078c63          	beq	a5,a6,ffffffffc0200d0a <buddy_fit_free_pages+0xa0>
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc0200cf6:	ff87a703          	lw	a4,-8(a5)
        p = le2page(le, page_link);
ffffffffc0200cfa:	fe878693          	addi	a3,a5,-24
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc0200cfe:	00e66663          	bltu	a2,a4,ffffffffc0200d0a <buddy_fit_free_pages+0xa0>
ffffffffc0200d02:	fee617e3          	bne	a2,a4,ffffffffc0200cf0 <buddy_fit_free_pages+0x86>
ffffffffc0200d06:	fed575e3          	bgeu	a0,a3,ffffffffc0200cf0 <buddy_fit_free_pages+0x86>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d0a:	6398                	ld	a4,0(a5)
    list_add_before(le, &(base->page_link));
ffffffffc0200d0c:	01850593          	addi	a1,a0,24
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc0200d10:	0106a883          	lw	a7,16(a3)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200d14:	e38c                	sd	a1,0(a5)
ffffffffc0200d16:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200d18:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200d1a:	ed18                	sd	a4,24(a0)
ffffffffc0200d1c:	08c88963          	beq	a7,a2,ffffffffc0200dae <buddy_fit_free_pages+0x144>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200d20:	55f5                	li	a1,-3
    while (le != &free_list)
ffffffffc0200d22:	01079863          	bne	a5,a6,ffffffffc0200d32 <buddy_fit_free_pages+0xc8>
ffffffffc0200d26:	a0b9                	j	ffffffffc0200d74 <buddy_fit_free_pages+0x10a>
        else if (base->property < p->property)
ffffffffc0200d28:	04e6e963          	bltu	a3,a4,ffffffffc0200d7a <buddy_fit_free_pages+0x110>
    return listelm->next;
ffffffffc0200d2c:	679c                	ld	a5,8(a5)
    while (le != &free_list)
ffffffffc0200d2e:	05078363          	beq	a5,a6,ffffffffc0200d74 <buddy_fit_free_pages+0x10a>
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc0200d32:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d36:	4914                	lw	a3,16(a0)
ffffffffc0200d38:	fed718e3          	bne	a4,a3,ffffffffc0200d28 <buddy_fit_free_pages+0xbe>
ffffffffc0200d3c:	02071613          	slli	a2,a4,0x20
ffffffffc0200d40:	9201                	srli	a2,a2,0x20
ffffffffc0200d42:	00261693          	slli	a3,a2,0x2
ffffffffc0200d46:	96b2                	add	a3,a3,a2
ffffffffc0200d48:	068e                	slli	a3,a3,0x3
        p = le2page(le, page_link);
ffffffffc0200d4a:	fe878613          	addi	a2,a5,-24
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc0200d4e:	96aa                	add	a3,a3,a0
ffffffffc0200d50:	fcd61ee3          	bne	a2,a3,ffffffffc0200d2c <buddy_fit_free_pages+0xc2>
            base->property += p->property;
ffffffffc0200d54:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200d58:	c918                	sw	a4,16(a0)
ffffffffc0200d5a:	ff078713          	addi	a4,a5,-16
ffffffffc0200d5e:	60b7302f          	amoand.d	zero,a1,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d62:	6394                	ld	a3,0(a5)
ffffffffc0200d64:	6798                	ld	a4,8(a5)
            le = &(base->page_link);
ffffffffc0200d66:	01850793          	addi	a5,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d6a:	e698                	sd	a4,8(a3)
    return listelm->next;
ffffffffc0200d6c:	679c                	ld	a5,8(a5)
    next->prev = prev;
ffffffffc0200d6e:	e314                	sd	a3,0(a4)
    while (le != &free_list)
ffffffffc0200d70:	fd0791e3          	bne	a5,a6,ffffffffc0200d32 <buddy_fit_free_pages+0xc8>
}
ffffffffc0200d74:	60a2                	ld	ra,8(sp)
ffffffffc0200d76:	0141                	addi	sp,sp,16
ffffffffc0200d78:	8082                	ret
    return listelm->next;
ffffffffc0200d7a:	7110                	ld	a2,32(a0)
            while (le2page(targetLe, page_link)->property < base->property)
ffffffffc0200d7c:	ff862703          	lw	a4,-8(a2)
ffffffffc0200d80:	87b2                	mv	a5,a2
ffffffffc0200d82:	fed779e3          	bgeu	a4,a3,ffffffffc0200d74 <buddy_fit_free_pages+0x10a>
ffffffffc0200d86:	679c                	ld	a5,8(a5)
ffffffffc0200d88:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d8c:	fed76de3          	bltu	a4,a3,ffffffffc0200d86 <buddy_fit_free_pages+0x11c>
            if (targetLe != list_next(&base->page_link))
ffffffffc0200d90:	fef602e3          	beq	a2,a5,ffffffffc0200d74 <buddy_fit_free_pages+0x10a>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d94:	6d18                	ld	a4,24(a0)
                list_add_before(targetLe, &(base->page_link));
ffffffffc0200d96:	01850693          	addi	a3,a0,24
}
ffffffffc0200d9a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0200d9c:	e710                	sd	a2,8(a4)
    next->prev = prev;
ffffffffc0200d9e:	e218                	sd	a4,0(a2)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200da0:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200da2:	e394                	sd	a3,0(a5)
ffffffffc0200da4:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200da6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200da8:	ed18                	sd	a4,24(a0)
ffffffffc0200daa:	0141                	addi	sp,sp,16
ffffffffc0200dac:	8082                	ret
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc0200dae:	02061593          	slli	a1,a2,0x20
ffffffffc0200db2:	9181                	srli	a1,a1,0x20
ffffffffc0200db4:	00259713          	slli	a4,a1,0x2
ffffffffc0200db8:	972e                	add	a4,a4,a1
ffffffffc0200dba:	070e                	slli	a4,a4,0x3
ffffffffc0200dbc:	9736                	add	a4,a4,a3
ffffffffc0200dbe:	f6e511e3          	bne	a0,a4,ffffffffc0200d20 <buddy_fit_free_pages+0xb6>
        p->property += base->property;
ffffffffc0200dc2:	0016161b          	slliw	a2,a2,0x1
ffffffffc0200dc6:	ca90                	sw	a2,16(a3)
ffffffffc0200dc8:	57f5                	li	a5,-3
ffffffffc0200dca:	60f3302f          	amoand.d	zero,a5,(t1)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200dce:	6d10                	ld	a2,24(a0)
ffffffffc0200dd0:	7118                	ld	a4,32(a0)
        le = &(base->page_link);
ffffffffc0200dd2:	01868793          	addi	a5,a3,24
ffffffffc0200dd6:	8536                	mv	a0,a3
    prev->next = next;
ffffffffc0200dd8:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0200dda:	e310                	sd	a2,0(a4)
ffffffffc0200ddc:	b791                	j	ffffffffc0200d20 <buddy_fit_free_pages+0xb6>
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc0200dde:	4910                	lw	a2,16(a0)
ffffffffc0200de0:	b72d                	j	ffffffffc0200d0a <buddy_fit_free_pages+0xa0>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200de2:	00001697          	auipc	a3,0x1
ffffffffc0200de6:	30e68693          	addi	a3,a3,782 # ffffffffc02020f0 <commands+0x6a8>
ffffffffc0200dea:	00001617          	auipc	a2,0x1
ffffffffc0200dee:	14e60613          	addi	a2,a2,334 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200df2:	08f00593          	li	a1,143
ffffffffc0200df6:	00001517          	auipc	a0,0x1
ffffffffc0200dfa:	15a50513          	addi	a0,a0,346 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200dfe:	daeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200e02:	00001697          	auipc	a3,0x1
ffffffffc0200e06:	2e668693          	addi	a3,a3,742 # ffffffffc02020e8 <commands+0x6a0>
ffffffffc0200e0a:	00001617          	auipc	a2,0x1
ffffffffc0200e0e:	12e60613          	addi	a2,a2,302 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200e12:	08700593          	li	a1,135
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	13a50513          	addi	a0,a0,314 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200e1e:	d8eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e22 <buddy_fit_alloc_pages>:
{
ffffffffc0200e22:	1141                	addi	sp,sp,-16
ffffffffc0200e24:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e26:	c96d                	beqz	a0,ffffffffc0200f18 <buddy_fit_alloc_pages+0xf6>
    while (num > 1)
ffffffffc0200e28:	4585                	li	a1,1
ffffffffc0200e2a:	862a                	mv	a2,a0
ffffffffc0200e2c:	87aa                	mv	a5,a0
    size_t exp = 0;
ffffffffc0200e2e:	4701                	li	a4,0
    while (num > 1)
ffffffffc0200e30:	4685                	li	a3,1
ffffffffc0200e32:	00b50d63          	beq	a0,a1,ffffffffc0200e4c <buddy_fit_alloc_pages+0x2a>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc0200e36:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc0200e38:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc0200e3a:	fed79ee3          	bne	a5,a3,ffffffffc0200e36 <buddy_fit_alloc_pages+0x14>
    return (size_t)(1 << exp);
ffffffffc0200e3e:	4785                	li	a5,1
ffffffffc0200e40:	00e7973b          	sllw	a4,a5,a4
    if (size < n)
ffffffffc0200e44:	00c77463          	bgeu	a4,a2,ffffffffc0200e4c <buddy_fit_alloc_pages+0x2a>
        n = 2 * size;
ffffffffc0200e48:	00171613          	slli	a2,a4,0x1
    if (n > nr_free)
ffffffffc0200e4c:	00005897          	auipc	a7,0x5
ffffffffc0200e50:	1cc88893          	addi	a7,a7,460 # ffffffffc0206018 <free_area>
ffffffffc0200e54:	0108a583          	lw	a1,16(a7)
ffffffffc0200e58:	02059793          	slli	a5,a1,0x20
ffffffffc0200e5c:	9381                	srli	a5,a5,0x20
ffffffffc0200e5e:	00c7ee63          	bltu	a5,a2,ffffffffc0200e7a <buddy_fit_alloc_pages+0x58>
    list_entry_t *le = &free_list;
ffffffffc0200e62:	8746                	mv	a4,a7
ffffffffc0200e64:	a801                	j	ffffffffc0200e74 <buddy_fit_alloc_pages+0x52>
        if (p->property >= n){
ffffffffc0200e66:	ff872683          	lw	a3,-8(a4)
ffffffffc0200e6a:	02069793          	slli	a5,a3,0x20
ffffffffc0200e6e:	9381                	srli	a5,a5,0x20
ffffffffc0200e70:	00c7f963          	bgeu	a5,a2,ffffffffc0200e82 <buddy_fit_alloc_pages+0x60>
    return listelm->next;
ffffffffc0200e74:	6718                	ld	a4,8(a4)
    while ((le = list_next(le)) != &free_list)
ffffffffc0200e76:	ff1718e3          	bne	a4,a7,ffffffffc0200e66 <buddy_fit_alloc_pages+0x44>
}
ffffffffc0200e7a:	60a2                	ld	ra,8(sp)
        return NULL;
ffffffffc0200e7c:	4501                	li	a0,0
}
ffffffffc0200e7e:	0141                	addi	sp,sp,16
ffffffffc0200e80:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0200e82:	fe870513          	addi	a0,a4,-24
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e86:	4309                	li	t1,2
        while (page->property > n)
ffffffffc0200e88:	04f67563          	bgeu	a2,a5,ffffffffc0200ed2 <buddy_fit_alloc_pages+0xb0>
            page->property /= 2;
ffffffffc0200e8c:	0016d69b          	srliw	a3,a3,0x1
            struct Page *p = page + page->property;
ffffffffc0200e90:	02069593          	slli	a1,a3,0x20
ffffffffc0200e94:	9181                	srli	a1,a1,0x20
ffffffffc0200e96:	00259793          	slli	a5,a1,0x2
ffffffffc0200e9a:	97ae                	add	a5,a5,a1
ffffffffc0200e9c:	078e                	slli	a5,a5,0x3
            page->property /= 2;
ffffffffc0200e9e:	fed72c23          	sw	a3,-8(a4)
            struct Page *p = page + page->property;
ffffffffc0200ea2:	97aa                	add	a5,a5,a0
            p->property = page->property;
ffffffffc0200ea4:	cb94                	sw	a3,16(a5)
ffffffffc0200ea6:	00878693          	addi	a3,a5,8
ffffffffc0200eaa:	4066b02f          	amoor.d	zero,t1,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200eae:	670c                	ld	a1,8(a4)
        while (page->property > n)
ffffffffc0200eb0:	ff872683          	lw	a3,-8(a4)
            list_add_after(&(page->page_link), &(p->page_link));
ffffffffc0200eb4:	01878813          	addi	a6,a5,24
    prev->next = next->prev = elm;
ffffffffc0200eb8:	0105b023          	sd	a6,0(a1)
ffffffffc0200ebc:	01073423          	sd	a6,8(a4)
    elm->next = next;
ffffffffc0200ec0:	f38c                	sd	a1,32(a5)
    elm->prev = prev;
ffffffffc0200ec2:	ef98                	sd	a4,24(a5)
        while (page->property > n)
ffffffffc0200ec4:	02069793          	slli	a5,a3,0x20
ffffffffc0200ec8:	9381                	srli	a5,a5,0x20
ffffffffc0200eca:	fcf661e3          	bltu	a2,a5,ffffffffc0200e8c <buddy_fit_alloc_pages+0x6a>
        nr_free -= n;
ffffffffc0200ece:	0108a583          	lw	a1,16(a7)
ffffffffc0200ed2:	9d91                	subw	a1,a1,a2
ffffffffc0200ed4:	00b8a823          	sw	a1,16(a7)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ed8:	57f5                	li	a5,-3
ffffffffc0200eda:	ff070693          	addi	a3,a4,-16
ffffffffc0200ede:	60f6b02f          	amoand.d	zero,a5,(a3)
        assert(page->property == n);
ffffffffc0200ee2:	ff876783          	lwu	a5,-8(a4)
ffffffffc0200ee6:	00f61963          	bne	a2,a5,ffffffffc0200ef8 <buddy_fit_alloc_pages+0xd6>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200eea:	6314                	ld	a3,0(a4)
ffffffffc0200eec:	671c                	ld	a5,8(a4)
}
ffffffffc0200eee:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0200ef0:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200ef2:	e394                	sd	a3,0(a5)
ffffffffc0200ef4:	0141                	addi	sp,sp,16
ffffffffc0200ef6:	8082                	ret
        assert(page->property == n);
ffffffffc0200ef8:	00001697          	auipc	a3,0x1
ffffffffc0200efc:	22068693          	addi	a3,a3,544 # ffffffffc0202118 <commands+0x6d0>
ffffffffc0200f00:	00001617          	auipc	a2,0x1
ffffffffc0200f04:	03860613          	addi	a2,a2,56 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200f08:	07e00593          	li	a1,126
ffffffffc0200f0c:	00001517          	auipc	a0,0x1
ffffffffc0200f10:	04450513          	addi	a0,a0,68 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200f14:	c98ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200f18:	00001697          	auipc	a3,0x1
ffffffffc0200f1c:	1d068693          	addi	a3,a3,464 # ffffffffc02020e8 <commands+0x6a0>
ffffffffc0200f20:	00001617          	auipc	a2,0x1
ffffffffc0200f24:	01860613          	addi	a2,a2,24 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0200f28:	05b00593          	li	a1,91
ffffffffc0200f2c:	00001517          	auipc	a0,0x1
ffffffffc0200f30:	02450513          	addi	a0,a0,36 # ffffffffc0201f50 <commands+0x508>
ffffffffc0200f34:	c78ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f38 <buddy_fit_init_memmap>:
{
ffffffffc0200f38:	1141                	addi	sp,sp,-16
ffffffffc0200f3a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f3c:	cde9                	beqz	a1,ffffffffc0201016 <buddy_fit_init_memmap+0xde>
    for (; p != base + n; p++)
ffffffffc0200f3e:	00259813          	slli	a6,a1,0x2
ffffffffc0200f42:	982e                	add	a6,a6,a1
ffffffffc0200f44:	080e                	slli	a6,a6,0x3
ffffffffc0200f46:	982a                	add	a6,a6,a0
ffffffffc0200f48:	01050f63          	beq	a0,a6,ffffffffc0200f66 <buddy_fit_init_memmap+0x2e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f4c:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200f4e:	8b85                	andi	a5,a5,1
ffffffffc0200f50:	c3dd                	beqz	a5,ffffffffc0200ff6 <buddy_fit_init_memmap+0xbe>
        p->flags = p->property = 0;
ffffffffc0200f52:	00052823          	sw	zero,16(a0)
ffffffffc0200f56:	00053423          	sd	zero,8(a0)
ffffffffc0200f5a:	00052023          	sw	zero,0(a0)
    for (; p != base + n; p++)
ffffffffc0200f5e:	02850513          	addi	a0,a0,40
ffffffffc0200f62:	ff0515e3          	bne	a0,a6,ffffffffc0200f4c <buddy_fit_init_memmap+0x14>
    nr_free += n;
ffffffffc0200f66:	00005517          	auipc	a0,0x5
ffffffffc0200f6a:	0b250513          	addi	a0,a0,178 # ffffffffc0206018 <free_area>
ffffffffc0200f6e:	491c                	lw	a5,16(a0)
    while (num > 1)
ffffffffc0200f70:	4885                	li	a7,1
    return (size_t)(1 << exp);
ffffffffc0200f72:	4e05                	li	t3,1
    nr_free += n;
ffffffffc0200f74:	9fad                	addw	a5,a5,a1
ffffffffc0200f76:	c91c                	sw	a5,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f78:	4309                	li	t1,2
    while (num > 1)
ffffffffc0200f7a:	87ae                	mv	a5,a1
    size_t exp = 0;
ffffffffc0200f7c:	4701                	li	a4,0
    while (num > 1)
ffffffffc0200f7e:	07158763          	beq	a1,a7,ffffffffc0200fec <buddy_fit_init_memmap+0xb4>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc0200f82:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc0200f84:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc0200f86:	ff179ee3          	bne	a5,a7,ffffffffc0200f82 <buddy_fit_init_memmap+0x4a>
    return (size_t)(1 << exp);
ffffffffc0200f8a:	00ee163b          	sllw	a2,t3,a4
        base -= curr_n;
ffffffffc0200f8e:	00261793          	slli	a5,a2,0x2
ffffffffc0200f92:	97b2                	add	a5,a5,a2
ffffffffc0200f94:	078e                	slli	a5,a5,0x3
ffffffffc0200f96:	40f007b3          	neg	a5,a5
        base->property = curr_n;
ffffffffc0200f9a:	8732                	mv	a4,a2
        base -= curr_n;
ffffffffc0200f9c:	983e                	add	a6,a6,a5
        base->property = curr_n;
ffffffffc0200f9e:	00e82823          	sw	a4,16(a6)
ffffffffc0200fa2:	00880793          	addi	a5,a6,8
ffffffffc0200fa6:	4067b02f          	amoor.d	zero,t1,(a5)
    return listelm->next;
ffffffffc0200faa:	651c                	ld	a5,8(a0)
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc0200fac:	02a78263          	beq	a5,a0,ffffffffc0200fd0 <buddy_fit_init_memmap+0x98>
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc0200fb0:	01082683          	lw	a3,16(a6)
ffffffffc0200fb4:	a021                	j	ffffffffc0200fbc <buddy_fit_init_memmap+0x84>
ffffffffc0200fb6:	679c                	ld	a5,8(a5)
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc0200fb8:	00a78c63          	beq	a5,a0,ffffffffc0200fd0 <buddy_fit_init_memmap+0x98>
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc0200fbc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200fc0:	00e6e863          	bltu	a3,a4,ffffffffc0200fd0 <buddy_fit_init_memmap+0x98>
ffffffffc0200fc4:	fed719e3          	bne	a4,a3,ffffffffc0200fb6 <buddy_fit_init_memmap+0x7e>
            struct Page *page = le2page(le, page_link);
ffffffffc0200fc8:	fe878713          	addi	a4,a5,-24
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc0200fcc:	fee875e3          	bgeu	a6,a4,ffffffffc0200fb6 <buddy_fit_init_memmap+0x7e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200fd0:	6398                	ld	a4,0(a5)
        list_add_before(le, &(base->page_link));
ffffffffc0200fd2:	01880693          	addi	a3,a6,24
    prev->next = next->prev = elm;
ffffffffc0200fd6:	e394                	sd	a3,0(a5)
ffffffffc0200fd8:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200fda:	02f83023          	sd	a5,32(a6)
    elm->prev = prev;
ffffffffc0200fde:	00e83c23          	sd	a4,24(a6)
        n -= curr_n;
ffffffffc0200fe2:	8d91                	sub	a1,a1,a2
    while (n != 0)
ffffffffc0200fe4:	f9d9                	bnez	a1,ffffffffc0200f7a <buddy_fit_init_memmap+0x42>
}
ffffffffc0200fe6:	60a2                	ld	ra,8(sp)
ffffffffc0200fe8:	0141                	addi	sp,sp,16
ffffffffc0200fea:	8082                	ret
    while (num > 1)
ffffffffc0200fec:	4605                	li	a2,1
ffffffffc0200fee:	4705                	li	a4,1
ffffffffc0200ff0:	fd800793          	li	a5,-40
ffffffffc0200ff4:	b765                	j	ffffffffc0200f9c <buddy_fit_init_memmap+0x64>
        assert(PageReserved(p));
ffffffffc0200ff6:	00001697          	auipc	a3,0x1
ffffffffc0200ffa:	13a68693          	addi	a3,a3,314 # ffffffffc0202130 <commands+0x6e8>
ffffffffc0200ffe:	00001617          	auipc	a2,0x1
ffffffffc0201002:	f3a60613          	addi	a2,a2,-198 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0201006:	03500593          	li	a1,53
ffffffffc020100a:	00001517          	auipc	a0,0x1
ffffffffc020100e:	f4650513          	addi	a0,a0,-186 # ffffffffc0201f50 <commands+0x508>
ffffffffc0201012:	b9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201016:	00001697          	auipc	a3,0x1
ffffffffc020101a:	0d268693          	addi	a3,a3,210 # ffffffffc02020e8 <commands+0x6a0>
ffffffffc020101e:	00001617          	auipc	a2,0x1
ffffffffc0201022:	f1a60613          	addi	a2,a2,-230 # ffffffffc0201f38 <commands+0x4f0>
ffffffffc0201026:	03100593          	li	a1,49
ffffffffc020102a:	00001517          	auipc	a0,0x1
ffffffffc020102e:	f2650513          	addi	a0,a0,-218 # ffffffffc0201f50 <commands+0x508>
ffffffffc0201032:	b7aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201036 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201036:	100027f3          	csrr	a5,sstatus
ffffffffc020103a:	8b89                	andi	a5,a5,2
ffffffffc020103c:	e799                	bnez	a5,ffffffffc020104a <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020103e:	00005797          	auipc	a5,0x5
ffffffffc0201042:	41a7b783          	ld	a5,1050(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201046:	6f9c                	ld	a5,24(a5)
ffffffffc0201048:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020104a:	1141                	addi	sp,sp,-16
ffffffffc020104c:	e406                	sd	ra,8(sp)
ffffffffc020104e:	e022                	sd	s0,0(sp)
ffffffffc0201050:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201052:	c0cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201056:	00005797          	auipc	a5,0x5
ffffffffc020105a:	4027b783          	ld	a5,1026(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc020105e:	6f9c                	ld	a5,24(a5)
ffffffffc0201060:	8522                	mv	a0,s0
ffffffffc0201062:	9782                	jalr	a5
ffffffffc0201064:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201066:	bf2ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020106a:	60a2                	ld	ra,8(sp)
ffffffffc020106c:	8522                	mv	a0,s0
ffffffffc020106e:	6402                	ld	s0,0(sp)
ffffffffc0201070:	0141                	addi	sp,sp,16
ffffffffc0201072:	8082                	ret

ffffffffc0201074 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201074:	100027f3          	csrr	a5,sstatus
ffffffffc0201078:	8b89                	andi	a5,a5,2
ffffffffc020107a:	e799                	bnez	a5,ffffffffc0201088 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020107c:	00005797          	auipc	a5,0x5
ffffffffc0201080:	3dc7b783          	ld	a5,988(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201084:	739c                	ld	a5,32(a5)
ffffffffc0201086:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201088:	1101                	addi	sp,sp,-32
ffffffffc020108a:	ec06                	sd	ra,24(sp)
ffffffffc020108c:	e822                	sd	s0,16(sp)
ffffffffc020108e:	e426                	sd	s1,8(sp)
ffffffffc0201090:	842a                	mv	s0,a0
ffffffffc0201092:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201094:	bcaff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201098:	00005797          	auipc	a5,0x5
ffffffffc020109c:	3c07b783          	ld	a5,960(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02010a0:	739c                	ld	a5,32(a5)
ffffffffc02010a2:	85a6                	mv	a1,s1
ffffffffc02010a4:	8522                	mv	a0,s0
ffffffffc02010a6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02010a8:	6442                	ld	s0,16(sp)
ffffffffc02010aa:	60e2                	ld	ra,24(sp)
ffffffffc02010ac:	64a2                	ld	s1,8(sp)
ffffffffc02010ae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02010b0:	ba8ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02010b4 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010b4:	100027f3          	csrr	a5,sstatus
ffffffffc02010b8:	8b89                	andi	a5,a5,2
ffffffffc02010ba:	e799                	bnez	a5,ffffffffc02010c8 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02010bc:	00005797          	auipc	a5,0x5
ffffffffc02010c0:	39c7b783          	ld	a5,924(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02010c4:	779c                	ld	a5,40(a5)
ffffffffc02010c6:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02010c8:	1141                	addi	sp,sp,-16
ffffffffc02010ca:	e406                	sd	ra,8(sp)
ffffffffc02010cc:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02010ce:	b90ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02010d2:	00005797          	auipc	a5,0x5
ffffffffc02010d6:	3867b783          	ld	a5,902(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02010da:	779c                	ld	a5,40(a5)
ffffffffc02010dc:	9782                	jalr	a5
ffffffffc02010de:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02010e0:	b78ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02010e4:	60a2                	ld	ra,8(sp)
ffffffffc02010e6:	8522                	mv	a0,s0
ffffffffc02010e8:	6402                	ld	s0,0(sp)
ffffffffc02010ea:	0141                	addi	sp,sp,16
ffffffffc02010ec:	8082                	ret

ffffffffc02010ee <pmm_init>:
    pmm_manager = &buddy_fit_pmm_manager;
ffffffffc02010ee:	00001797          	auipc	a5,0x1
ffffffffc02010f2:	06a78793          	addi	a5,a5,106 # ffffffffc0202158 <buddy_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010f6:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02010f8:	1101                	addi	sp,sp,-32
ffffffffc02010fa:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010fc:	00001517          	auipc	a0,0x1
ffffffffc0201100:	09450513          	addi	a0,a0,148 # ffffffffc0202190 <buddy_fit_pmm_manager+0x38>
    pmm_manager = &buddy_fit_pmm_manager;
ffffffffc0201104:	00005497          	auipc	s1,0x5
ffffffffc0201108:	35448493          	addi	s1,s1,852 # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc020110c:	ec06                	sd	ra,24(sp)
ffffffffc020110e:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_fit_pmm_manager;
ffffffffc0201110:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201112:	fa1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0201116:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201118:	00005417          	auipc	s0,0x5
ffffffffc020111c:	35840413          	addi	s0,s0,856 # ffffffffc0206470 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201120:	679c                	ld	a5,8(a5)
ffffffffc0201122:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201124:	57f5                	li	a5,-3
ffffffffc0201126:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201128:	00001517          	auipc	a0,0x1
ffffffffc020112c:	08050513          	addi	a0,a0,128 # ffffffffc02021a8 <buddy_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201130:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201132:	f81fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201136:	46c5                	li	a3,17
ffffffffc0201138:	06ee                	slli	a3,a3,0x1b
ffffffffc020113a:	40100613          	li	a2,1025
ffffffffc020113e:	16fd                	addi	a3,a3,-1
ffffffffc0201140:	07e005b7          	lui	a1,0x7e00
ffffffffc0201144:	0656                	slli	a2,a2,0x15
ffffffffc0201146:	00001517          	auipc	a0,0x1
ffffffffc020114a:	07a50513          	addi	a0,a0,122 # ffffffffc02021c0 <buddy_fit_pmm_manager+0x68>
ffffffffc020114e:	f65fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201152:	777d                	lui	a4,0xfffff
ffffffffc0201154:	00006797          	auipc	a5,0x6
ffffffffc0201158:	32b78793          	addi	a5,a5,811 # ffffffffc020747f <end+0xfff>
ffffffffc020115c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020115e:	00005517          	auipc	a0,0x5
ffffffffc0201162:	2ea50513          	addi	a0,a0,746 # ffffffffc0206448 <npage>
ffffffffc0201166:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020116a:	00005597          	auipc	a1,0x5
ffffffffc020116e:	2e658593          	addi	a1,a1,742 # ffffffffc0206450 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201172:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201174:	e19c                	sd	a5,0(a1)
ffffffffc0201176:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201178:	4701                	li	a4,0
ffffffffc020117a:	4885                	li	a7,1
ffffffffc020117c:	fff80837          	lui	a6,0xfff80
ffffffffc0201180:	a011                	j	ffffffffc0201184 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201182:	619c                	ld	a5,0(a1)
ffffffffc0201184:	97b6                	add	a5,a5,a3
ffffffffc0201186:	07a1                	addi	a5,a5,8
ffffffffc0201188:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020118c:	611c                	ld	a5,0(a0)
ffffffffc020118e:	0705                	addi	a4,a4,1
ffffffffc0201190:	02868693          	addi	a3,a3,40
ffffffffc0201194:	01078633          	add	a2,a5,a6
ffffffffc0201198:	fec765e3          	bltu	a4,a2,ffffffffc0201182 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020119c:	6190                	ld	a2,0(a1)
ffffffffc020119e:	00279713          	slli	a4,a5,0x2
ffffffffc02011a2:	973e                	add	a4,a4,a5
ffffffffc02011a4:	fec006b7          	lui	a3,0xfec00
ffffffffc02011a8:	070e                	slli	a4,a4,0x3
ffffffffc02011aa:	96b2                	add	a3,a3,a2
ffffffffc02011ac:	96ba                	add	a3,a3,a4
ffffffffc02011ae:	c0200737          	lui	a4,0xc0200
ffffffffc02011b2:	08e6ef63          	bltu	a3,a4,ffffffffc0201250 <pmm_init+0x162>
ffffffffc02011b6:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02011b8:	45c5                	li	a1,17
ffffffffc02011ba:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011bc:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02011be:	04b6e863          	bltu	a3,a1,ffffffffc020120e <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02011c2:	609c                	ld	a5,0(s1)
ffffffffc02011c4:	7b9c                	ld	a5,48(a5)
ffffffffc02011c6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02011c8:	00001517          	auipc	a0,0x1
ffffffffc02011cc:	09050513          	addi	a0,a0,144 # ffffffffc0202258 <buddy_fit_pmm_manager+0x100>
ffffffffc02011d0:	ee3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02011d4:	00004597          	auipc	a1,0x4
ffffffffc02011d8:	e2c58593          	addi	a1,a1,-468 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02011dc:	00005797          	auipc	a5,0x5
ffffffffc02011e0:	28b7b623          	sd	a1,652(a5) # ffffffffc0206468 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011e4:	c02007b7          	lui	a5,0xc0200
ffffffffc02011e8:	08f5e063          	bltu	a1,a5,ffffffffc0201268 <pmm_init+0x17a>
ffffffffc02011ec:	6010                	ld	a2,0(s0)
}
ffffffffc02011ee:	6442                	ld	s0,16(sp)
ffffffffc02011f0:	60e2                	ld	ra,24(sp)
ffffffffc02011f2:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02011f4:	40c58633          	sub	a2,a1,a2
ffffffffc02011f8:	00005797          	auipc	a5,0x5
ffffffffc02011fc:	26c7b423          	sd	a2,616(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201200:	00001517          	auipc	a0,0x1
ffffffffc0201204:	07850513          	addi	a0,a0,120 # ffffffffc0202278 <buddy_fit_pmm_manager+0x120>
}
ffffffffc0201208:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020120a:	ea9fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020120e:	6705                	lui	a4,0x1
ffffffffc0201210:	177d                	addi	a4,a4,-1
ffffffffc0201212:	96ba                	add	a3,a3,a4
ffffffffc0201214:	777d                	lui	a4,0xfffff
ffffffffc0201216:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201218:	00c6d513          	srli	a0,a3,0xc
ffffffffc020121c:	00f57e63          	bgeu	a0,a5,ffffffffc0201238 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201220:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201222:	982a                	add	a6,a6,a0
ffffffffc0201224:	00281513          	slli	a0,a6,0x2
ffffffffc0201228:	9542                	add	a0,a0,a6
ffffffffc020122a:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020122c:	8d95                	sub	a1,a1,a3
ffffffffc020122e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201230:	81b1                	srli	a1,a1,0xc
ffffffffc0201232:	9532                	add	a0,a0,a2
ffffffffc0201234:	9782                	jalr	a5
}
ffffffffc0201236:	b771                	j	ffffffffc02011c2 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201238:	00001617          	auipc	a2,0x1
ffffffffc020123c:	ff060613          	addi	a2,a2,-16 # ffffffffc0202228 <buddy_fit_pmm_manager+0xd0>
ffffffffc0201240:	06b00593          	li	a1,107
ffffffffc0201244:	00001517          	auipc	a0,0x1
ffffffffc0201248:	00450513          	addi	a0,a0,4 # ffffffffc0202248 <buddy_fit_pmm_manager+0xf0>
ffffffffc020124c:	960ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201250:	00001617          	auipc	a2,0x1
ffffffffc0201254:	fa060613          	addi	a2,a2,-96 # ffffffffc02021f0 <buddy_fit_pmm_manager+0x98>
ffffffffc0201258:	07200593          	li	a1,114
ffffffffc020125c:	00001517          	auipc	a0,0x1
ffffffffc0201260:	fbc50513          	addi	a0,a0,-68 # ffffffffc0202218 <buddy_fit_pmm_manager+0xc0>
ffffffffc0201264:	948ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201268:	86ae                	mv	a3,a1
ffffffffc020126a:	00001617          	auipc	a2,0x1
ffffffffc020126e:	f8660613          	addi	a2,a2,-122 # ffffffffc02021f0 <buddy_fit_pmm_manager+0x98>
ffffffffc0201272:	08d00593          	li	a1,141
ffffffffc0201276:	00001517          	auipc	a0,0x1
ffffffffc020127a:	fa250513          	addi	a0,a0,-94 # ffffffffc0202218 <buddy_fit_pmm_manager+0xc0>
ffffffffc020127e:	92eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201282 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201282:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201286:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201288:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020128c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020128e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201292:	f022                	sd	s0,32(sp)
ffffffffc0201294:	ec26                	sd	s1,24(sp)
ffffffffc0201296:	e84a                	sd	s2,16(sp)
ffffffffc0201298:	f406                	sd	ra,40(sp)
ffffffffc020129a:	e44e                	sd	s3,8(sp)
ffffffffc020129c:	84aa                	mv	s1,a0
ffffffffc020129e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02012a0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02012a4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02012a6:	03067e63          	bgeu	a2,a6,ffffffffc02012e2 <printnum+0x60>
ffffffffc02012aa:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02012ac:	00805763          	blez	s0,ffffffffc02012ba <printnum+0x38>
ffffffffc02012b0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02012b2:	85ca                	mv	a1,s2
ffffffffc02012b4:	854e                	mv	a0,s3
ffffffffc02012b6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02012b8:	fc65                	bnez	s0,ffffffffc02012b0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012ba:	1a02                	slli	s4,s4,0x20
ffffffffc02012bc:	00001797          	auipc	a5,0x1
ffffffffc02012c0:	ffc78793          	addi	a5,a5,-4 # ffffffffc02022b8 <buddy_fit_pmm_manager+0x160>
ffffffffc02012c4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02012c8:	9a3e                	add	s4,s4,a5
}
ffffffffc02012ca:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012cc:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02012d0:	70a2                	ld	ra,40(sp)
ffffffffc02012d2:	69a2                	ld	s3,8(sp)
ffffffffc02012d4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012d6:	85ca                	mv	a1,s2
ffffffffc02012d8:	87a6                	mv	a5,s1
}
ffffffffc02012da:	6942                	ld	s2,16(sp)
ffffffffc02012dc:	64e2                	ld	s1,24(sp)
ffffffffc02012de:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012e0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02012e2:	03065633          	divu	a2,a2,a6
ffffffffc02012e6:	8722                	mv	a4,s0
ffffffffc02012e8:	f9bff0ef          	jal	ra,ffffffffc0201282 <printnum>
ffffffffc02012ec:	b7f9                	j	ffffffffc02012ba <printnum+0x38>

ffffffffc02012ee <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02012ee:	7119                	addi	sp,sp,-128
ffffffffc02012f0:	f4a6                	sd	s1,104(sp)
ffffffffc02012f2:	f0ca                	sd	s2,96(sp)
ffffffffc02012f4:	ecce                	sd	s3,88(sp)
ffffffffc02012f6:	e8d2                	sd	s4,80(sp)
ffffffffc02012f8:	e4d6                	sd	s5,72(sp)
ffffffffc02012fa:	e0da                	sd	s6,64(sp)
ffffffffc02012fc:	fc5e                	sd	s7,56(sp)
ffffffffc02012fe:	f06a                	sd	s10,32(sp)
ffffffffc0201300:	fc86                	sd	ra,120(sp)
ffffffffc0201302:	f8a2                	sd	s0,112(sp)
ffffffffc0201304:	f862                	sd	s8,48(sp)
ffffffffc0201306:	f466                	sd	s9,40(sp)
ffffffffc0201308:	ec6e                	sd	s11,24(sp)
ffffffffc020130a:	892a                	mv	s2,a0
ffffffffc020130c:	84ae                	mv	s1,a1
ffffffffc020130e:	8d32                	mv	s10,a2
ffffffffc0201310:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201312:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201316:	5b7d                	li	s6,-1
ffffffffc0201318:	00001a97          	auipc	s5,0x1
ffffffffc020131c:	fd4a8a93          	addi	s5,s5,-44 # ffffffffc02022ec <buddy_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201320:	00001b97          	auipc	s7,0x1
ffffffffc0201324:	1a8b8b93          	addi	s7,s7,424 # ffffffffc02024c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201328:	000d4503          	lbu	a0,0(s10)
ffffffffc020132c:	001d0413          	addi	s0,s10,1
ffffffffc0201330:	01350a63          	beq	a0,s3,ffffffffc0201344 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201334:	c121                	beqz	a0,ffffffffc0201374 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201336:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201338:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020133a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020133c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201340:	ff351ae3          	bne	a0,s3,ffffffffc0201334 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201344:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201348:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020134c:	4c81                	li	s9,0
ffffffffc020134e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201350:	5c7d                	li	s8,-1
ffffffffc0201352:	5dfd                	li	s11,-1
ffffffffc0201354:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201358:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020135a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020135e:	0ff5f593          	andi	a1,a1,255
ffffffffc0201362:	00140d13          	addi	s10,s0,1
ffffffffc0201366:	04b56263          	bltu	a0,a1,ffffffffc02013aa <vprintfmt+0xbc>
ffffffffc020136a:	058a                	slli	a1,a1,0x2
ffffffffc020136c:	95d6                	add	a1,a1,s5
ffffffffc020136e:	4194                	lw	a3,0(a1)
ffffffffc0201370:	96d6                	add	a3,a3,s5
ffffffffc0201372:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201374:	70e6                	ld	ra,120(sp)
ffffffffc0201376:	7446                	ld	s0,112(sp)
ffffffffc0201378:	74a6                	ld	s1,104(sp)
ffffffffc020137a:	7906                	ld	s2,96(sp)
ffffffffc020137c:	69e6                	ld	s3,88(sp)
ffffffffc020137e:	6a46                	ld	s4,80(sp)
ffffffffc0201380:	6aa6                	ld	s5,72(sp)
ffffffffc0201382:	6b06                	ld	s6,64(sp)
ffffffffc0201384:	7be2                	ld	s7,56(sp)
ffffffffc0201386:	7c42                	ld	s8,48(sp)
ffffffffc0201388:	7ca2                	ld	s9,40(sp)
ffffffffc020138a:	7d02                	ld	s10,32(sp)
ffffffffc020138c:	6de2                	ld	s11,24(sp)
ffffffffc020138e:	6109                	addi	sp,sp,128
ffffffffc0201390:	8082                	ret
            padc = '0';
ffffffffc0201392:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201394:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201398:	846a                	mv	s0,s10
ffffffffc020139a:	00140d13          	addi	s10,s0,1
ffffffffc020139e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02013a2:	0ff5f593          	andi	a1,a1,255
ffffffffc02013a6:	fcb572e3          	bgeu	a0,a1,ffffffffc020136a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02013aa:	85a6                	mv	a1,s1
ffffffffc02013ac:	02500513          	li	a0,37
ffffffffc02013b0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02013b2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02013b6:	8d22                	mv	s10,s0
ffffffffc02013b8:	f73788e3          	beq	a5,s3,ffffffffc0201328 <vprintfmt+0x3a>
ffffffffc02013bc:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02013c0:	1d7d                	addi	s10,s10,-1
ffffffffc02013c2:	ff379de3          	bne	a5,s3,ffffffffc02013bc <vprintfmt+0xce>
ffffffffc02013c6:	b78d                	j	ffffffffc0201328 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02013c8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02013cc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013d0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02013d2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02013d6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013da:	02d86463          	bltu	a6,a3,ffffffffc0201402 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02013de:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02013e2:	002c169b          	slliw	a3,s8,0x2
ffffffffc02013e6:	0186873b          	addw	a4,a3,s8
ffffffffc02013ea:	0017171b          	slliw	a4,a4,0x1
ffffffffc02013ee:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02013f0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02013f4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02013f6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02013fa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013fe:	fed870e3          	bgeu	a6,a3,ffffffffc02013de <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201402:	f40ddce3          	bgez	s11,ffffffffc020135a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201406:	8de2                	mv	s11,s8
ffffffffc0201408:	5c7d                	li	s8,-1
ffffffffc020140a:	bf81                	j	ffffffffc020135a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020140c:	fffdc693          	not	a3,s11
ffffffffc0201410:	96fd                	srai	a3,a3,0x3f
ffffffffc0201412:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201416:	00144603          	lbu	a2,1(s0)
ffffffffc020141a:	2d81                	sext.w	s11,s11
ffffffffc020141c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020141e:	bf35                	j	ffffffffc020135a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201420:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201424:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201428:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020142a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020142c:	bfd9                	j	ffffffffc0201402 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020142e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201430:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201434:	01174463          	blt	a4,a7,ffffffffc020143c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201438:	1a088e63          	beqz	a7,ffffffffc02015f4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020143c:	000a3603          	ld	a2,0(s4)
ffffffffc0201440:	46c1                	li	a3,16
ffffffffc0201442:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201444:	2781                	sext.w	a5,a5
ffffffffc0201446:	876e                	mv	a4,s11
ffffffffc0201448:	85a6                	mv	a1,s1
ffffffffc020144a:	854a                	mv	a0,s2
ffffffffc020144c:	e37ff0ef          	jal	ra,ffffffffc0201282 <printnum>
            break;
ffffffffc0201450:	bde1                	j	ffffffffc0201328 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201452:	000a2503          	lw	a0,0(s4)
ffffffffc0201456:	85a6                	mv	a1,s1
ffffffffc0201458:	0a21                	addi	s4,s4,8
ffffffffc020145a:	9902                	jalr	s2
            break;
ffffffffc020145c:	b5f1                	j	ffffffffc0201328 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020145e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201460:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201464:	01174463          	blt	a4,a7,ffffffffc020146c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201468:	18088163          	beqz	a7,ffffffffc02015ea <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020146c:	000a3603          	ld	a2,0(s4)
ffffffffc0201470:	46a9                	li	a3,10
ffffffffc0201472:	8a2e                	mv	s4,a1
ffffffffc0201474:	bfc1                	j	ffffffffc0201444 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201476:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020147a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020147c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020147e:	bdf1                	j	ffffffffc020135a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201480:	85a6                	mv	a1,s1
ffffffffc0201482:	02500513          	li	a0,37
ffffffffc0201486:	9902                	jalr	s2
            break;
ffffffffc0201488:	b545                	j	ffffffffc0201328 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020148a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020148e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201490:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201492:	b5e1                	j	ffffffffc020135a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201494:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201496:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020149a:	01174463          	blt	a4,a7,ffffffffc02014a2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020149e:	14088163          	beqz	a7,ffffffffc02015e0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02014a2:	000a3603          	ld	a2,0(s4)
ffffffffc02014a6:	46a1                	li	a3,8
ffffffffc02014a8:	8a2e                	mv	s4,a1
ffffffffc02014aa:	bf69                	j	ffffffffc0201444 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02014ac:	03000513          	li	a0,48
ffffffffc02014b0:	85a6                	mv	a1,s1
ffffffffc02014b2:	e03e                	sd	a5,0(sp)
ffffffffc02014b4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02014b6:	85a6                	mv	a1,s1
ffffffffc02014b8:	07800513          	li	a0,120
ffffffffc02014bc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02014be:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02014c0:	6782                	ld	a5,0(sp)
ffffffffc02014c2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02014c4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02014c8:	bfb5                	j	ffffffffc0201444 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014ca:	000a3403          	ld	s0,0(s4)
ffffffffc02014ce:	008a0713          	addi	a4,s4,8
ffffffffc02014d2:	e03a                	sd	a4,0(sp)
ffffffffc02014d4:	14040263          	beqz	s0,ffffffffc0201618 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02014d8:	0fb05763          	blez	s11,ffffffffc02015c6 <vprintfmt+0x2d8>
ffffffffc02014dc:	02d00693          	li	a3,45
ffffffffc02014e0:	0cd79163          	bne	a5,a3,ffffffffc02015a2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014e4:	00044783          	lbu	a5,0(s0)
ffffffffc02014e8:	0007851b          	sext.w	a0,a5
ffffffffc02014ec:	cf85                	beqz	a5,ffffffffc0201524 <vprintfmt+0x236>
ffffffffc02014ee:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014f2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014f6:	000c4563          	bltz	s8,ffffffffc0201500 <vprintfmt+0x212>
ffffffffc02014fa:	3c7d                	addiw	s8,s8,-1
ffffffffc02014fc:	036c0263          	beq	s8,s6,ffffffffc0201520 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201500:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201502:	0e0c8e63          	beqz	s9,ffffffffc02015fe <vprintfmt+0x310>
ffffffffc0201506:	3781                	addiw	a5,a5,-32
ffffffffc0201508:	0ef47b63          	bgeu	s0,a5,ffffffffc02015fe <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020150c:	03f00513          	li	a0,63
ffffffffc0201510:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201512:	000a4783          	lbu	a5,0(s4)
ffffffffc0201516:	3dfd                	addiw	s11,s11,-1
ffffffffc0201518:	0a05                	addi	s4,s4,1
ffffffffc020151a:	0007851b          	sext.w	a0,a5
ffffffffc020151e:	ffe1                	bnez	a5,ffffffffc02014f6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201520:	01b05963          	blez	s11,ffffffffc0201532 <vprintfmt+0x244>
ffffffffc0201524:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201526:	85a6                	mv	a1,s1
ffffffffc0201528:	02000513          	li	a0,32
ffffffffc020152c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020152e:	fe0d9be3          	bnez	s11,ffffffffc0201524 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201532:	6a02                	ld	s4,0(sp)
ffffffffc0201534:	bbd5                	j	ffffffffc0201328 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201536:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201538:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020153c:	01174463          	blt	a4,a7,ffffffffc0201544 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201540:	08088d63          	beqz	a7,ffffffffc02015da <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201544:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201548:	0a044d63          	bltz	s0,ffffffffc0201602 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020154c:	8622                	mv	a2,s0
ffffffffc020154e:	8a66                	mv	s4,s9
ffffffffc0201550:	46a9                	li	a3,10
ffffffffc0201552:	bdcd                	j	ffffffffc0201444 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201554:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201558:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020155a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020155c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201560:	8fb5                	xor	a5,a5,a3
ffffffffc0201562:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201566:	02d74163          	blt	a4,a3,ffffffffc0201588 <vprintfmt+0x29a>
ffffffffc020156a:	00369793          	slli	a5,a3,0x3
ffffffffc020156e:	97de                	add	a5,a5,s7
ffffffffc0201570:	639c                	ld	a5,0(a5)
ffffffffc0201572:	cb99                	beqz	a5,ffffffffc0201588 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201574:	86be                	mv	a3,a5
ffffffffc0201576:	00001617          	auipc	a2,0x1
ffffffffc020157a:	d7260613          	addi	a2,a2,-654 # ffffffffc02022e8 <buddy_fit_pmm_manager+0x190>
ffffffffc020157e:	85a6                	mv	a1,s1
ffffffffc0201580:	854a                	mv	a0,s2
ffffffffc0201582:	0ce000ef          	jal	ra,ffffffffc0201650 <printfmt>
ffffffffc0201586:	b34d                	j	ffffffffc0201328 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201588:	00001617          	auipc	a2,0x1
ffffffffc020158c:	d5060613          	addi	a2,a2,-688 # ffffffffc02022d8 <buddy_fit_pmm_manager+0x180>
ffffffffc0201590:	85a6                	mv	a1,s1
ffffffffc0201592:	854a                	mv	a0,s2
ffffffffc0201594:	0bc000ef          	jal	ra,ffffffffc0201650 <printfmt>
ffffffffc0201598:	bb41                	j	ffffffffc0201328 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020159a:	00001417          	auipc	s0,0x1
ffffffffc020159e:	d3640413          	addi	s0,s0,-714 # ffffffffc02022d0 <buddy_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015a2:	85e2                	mv	a1,s8
ffffffffc02015a4:	8522                	mv	a0,s0
ffffffffc02015a6:	e43e                	sd	a5,8(sp)
ffffffffc02015a8:	1e6000ef          	jal	ra,ffffffffc020178e <strnlen>
ffffffffc02015ac:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02015b0:	01b05b63          	blez	s11,ffffffffc02015c6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02015b4:	67a2                	ld	a5,8(sp)
ffffffffc02015b6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015ba:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02015bc:	85a6                	mv	a1,s1
ffffffffc02015be:	8552                	mv	a0,s4
ffffffffc02015c0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015c2:	fe0d9ce3          	bnez	s11,ffffffffc02015ba <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015c6:	00044783          	lbu	a5,0(s0)
ffffffffc02015ca:	00140a13          	addi	s4,s0,1
ffffffffc02015ce:	0007851b          	sext.w	a0,a5
ffffffffc02015d2:	d3a5                	beqz	a5,ffffffffc0201532 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015d4:	05e00413          	li	s0,94
ffffffffc02015d8:	bf39                	j	ffffffffc02014f6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02015da:	000a2403          	lw	s0,0(s4)
ffffffffc02015de:	b7ad                	j	ffffffffc0201548 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02015e0:	000a6603          	lwu	a2,0(s4)
ffffffffc02015e4:	46a1                	li	a3,8
ffffffffc02015e6:	8a2e                	mv	s4,a1
ffffffffc02015e8:	bdb1                	j	ffffffffc0201444 <vprintfmt+0x156>
ffffffffc02015ea:	000a6603          	lwu	a2,0(s4)
ffffffffc02015ee:	46a9                	li	a3,10
ffffffffc02015f0:	8a2e                	mv	s4,a1
ffffffffc02015f2:	bd89                	j	ffffffffc0201444 <vprintfmt+0x156>
ffffffffc02015f4:	000a6603          	lwu	a2,0(s4)
ffffffffc02015f8:	46c1                	li	a3,16
ffffffffc02015fa:	8a2e                	mv	s4,a1
ffffffffc02015fc:	b5a1                	j	ffffffffc0201444 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02015fe:	9902                	jalr	s2
ffffffffc0201600:	bf09                	j	ffffffffc0201512 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201602:	85a6                	mv	a1,s1
ffffffffc0201604:	02d00513          	li	a0,45
ffffffffc0201608:	e03e                	sd	a5,0(sp)
ffffffffc020160a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020160c:	6782                	ld	a5,0(sp)
ffffffffc020160e:	8a66                	mv	s4,s9
ffffffffc0201610:	40800633          	neg	a2,s0
ffffffffc0201614:	46a9                	li	a3,10
ffffffffc0201616:	b53d                	j	ffffffffc0201444 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201618:	03b05163          	blez	s11,ffffffffc020163a <vprintfmt+0x34c>
ffffffffc020161c:	02d00693          	li	a3,45
ffffffffc0201620:	f6d79de3          	bne	a5,a3,ffffffffc020159a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201624:	00001417          	auipc	s0,0x1
ffffffffc0201628:	cac40413          	addi	s0,s0,-852 # ffffffffc02022d0 <buddy_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020162c:	02800793          	li	a5,40
ffffffffc0201630:	02800513          	li	a0,40
ffffffffc0201634:	00140a13          	addi	s4,s0,1
ffffffffc0201638:	bd6d                	j	ffffffffc02014f2 <vprintfmt+0x204>
ffffffffc020163a:	00001a17          	auipc	s4,0x1
ffffffffc020163e:	c97a0a13          	addi	s4,s4,-873 # ffffffffc02022d1 <buddy_fit_pmm_manager+0x179>
ffffffffc0201642:	02800513          	li	a0,40
ffffffffc0201646:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020164a:	05e00413          	li	s0,94
ffffffffc020164e:	b565                	j	ffffffffc02014f6 <vprintfmt+0x208>

ffffffffc0201650 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201650:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201652:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201656:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201658:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020165a:	ec06                	sd	ra,24(sp)
ffffffffc020165c:	f83a                	sd	a4,48(sp)
ffffffffc020165e:	fc3e                	sd	a5,56(sp)
ffffffffc0201660:	e0c2                	sd	a6,64(sp)
ffffffffc0201662:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201664:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201666:	c89ff0ef          	jal	ra,ffffffffc02012ee <vprintfmt>
}
ffffffffc020166a:	60e2                	ld	ra,24(sp)
ffffffffc020166c:	6161                	addi	sp,sp,80
ffffffffc020166e:	8082                	ret

ffffffffc0201670 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201670:	715d                	addi	sp,sp,-80
ffffffffc0201672:	e486                	sd	ra,72(sp)
ffffffffc0201674:	e0a6                	sd	s1,64(sp)
ffffffffc0201676:	fc4a                	sd	s2,56(sp)
ffffffffc0201678:	f84e                	sd	s3,48(sp)
ffffffffc020167a:	f452                	sd	s4,40(sp)
ffffffffc020167c:	f056                	sd	s5,32(sp)
ffffffffc020167e:	ec5a                	sd	s6,24(sp)
ffffffffc0201680:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201682:	c901                	beqz	a0,ffffffffc0201692 <readline+0x22>
ffffffffc0201684:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201686:	00001517          	auipc	a0,0x1
ffffffffc020168a:	c6250513          	addi	a0,a0,-926 # ffffffffc02022e8 <buddy_fit_pmm_manager+0x190>
ffffffffc020168e:	a25fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201692:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201694:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201696:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201698:	4aa9                	li	s5,10
ffffffffc020169a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020169c:	00005b97          	auipc	s7,0x5
ffffffffc02016a0:	994b8b93          	addi	s7,s7,-1644 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016a4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02016a8:	a83fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02016ac:	00054a63          	bltz	a0,ffffffffc02016c0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016b0:	00a95a63          	bge	s2,a0,ffffffffc02016c4 <readline+0x54>
ffffffffc02016b4:	029a5263          	bge	s4,s1,ffffffffc02016d8 <readline+0x68>
        c = getchar();
ffffffffc02016b8:	a73fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02016bc:	fe055ae3          	bgez	a0,ffffffffc02016b0 <readline+0x40>
            return NULL;
ffffffffc02016c0:	4501                	li	a0,0
ffffffffc02016c2:	a091                	j	ffffffffc0201706 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02016c4:	03351463          	bne	a0,s3,ffffffffc02016ec <readline+0x7c>
ffffffffc02016c8:	e8a9                	bnez	s1,ffffffffc020171a <readline+0xaa>
        c = getchar();
ffffffffc02016ca:	a61fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02016ce:	fe0549e3          	bltz	a0,ffffffffc02016c0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016d2:	fea959e3          	bge	s2,a0,ffffffffc02016c4 <readline+0x54>
ffffffffc02016d6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02016d8:	e42a                	sd	a0,8(sp)
ffffffffc02016da:	a0ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02016de:	6522                	ld	a0,8(sp)
ffffffffc02016e0:	009b87b3          	add	a5,s7,s1
ffffffffc02016e4:	2485                	addiw	s1,s1,1
ffffffffc02016e6:	00a78023          	sb	a0,0(a5)
ffffffffc02016ea:	bf7d                	j	ffffffffc02016a8 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02016ec:	01550463          	beq	a0,s5,ffffffffc02016f4 <readline+0x84>
ffffffffc02016f0:	fb651ce3          	bne	a0,s6,ffffffffc02016a8 <readline+0x38>
            cputchar(c);
ffffffffc02016f4:	9f5fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02016f8:	00005517          	auipc	a0,0x5
ffffffffc02016fc:	93850513          	addi	a0,a0,-1736 # ffffffffc0206030 <buf>
ffffffffc0201700:	94aa                	add	s1,s1,a0
ffffffffc0201702:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201706:	60a6                	ld	ra,72(sp)
ffffffffc0201708:	6486                	ld	s1,64(sp)
ffffffffc020170a:	7962                	ld	s2,56(sp)
ffffffffc020170c:	79c2                	ld	s3,48(sp)
ffffffffc020170e:	7a22                	ld	s4,40(sp)
ffffffffc0201710:	7a82                	ld	s5,32(sp)
ffffffffc0201712:	6b62                	ld	s6,24(sp)
ffffffffc0201714:	6bc2                	ld	s7,16(sp)
ffffffffc0201716:	6161                	addi	sp,sp,80
ffffffffc0201718:	8082                	ret
            cputchar(c);
ffffffffc020171a:	4521                	li	a0,8
ffffffffc020171c:	9cdfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201720:	34fd                	addiw	s1,s1,-1
ffffffffc0201722:	b759                	j	ffffffffc02016a8 <readline+0x38>

ffffffffc0201724 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201724:	4781                	li	a5,0
ffffffffc0201726:	00005717          	auipc	a4,0x5
ffffffffc020172a:	8e273703          	ld	a4,-1822(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc020172e:	88ba                	mv	a7,a4
ffffffffc0201730:	852a                	mv	a0,a0
ffffffffc0201732:	85be                	mv	a1,a5
ffffffffc0201734:	863e                	mv	a2,a5
ffffffffc0201736:	00000073          	ecall
ffffffffc020173a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020173c:	8082                	ret

ffffffffc020173e <sbi_set_timer>:
    __asm__ volatile (
ffffffffc020173e:	4781                	li	a5,0
ffffffffc0201740:	00005717          	auipc	a4,0x5
ffffffffc0201744:	d3873703          	ld	a4,-712(a4) # ffffffffc0206478 <SBI_SET_TIMER>
ffffffffc0201748:	88ba                	mv	a7,a4
ffffffffc020174a:	852a                	mv	a0,a0
ffffffffc020174c:	85be                	mv	a1,a5
ffffffffc020174e:	863e                	mv	a2,a5
ffffffffc0201750:	00000073          	ecall
ffffffffc0201754:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201756:	8082                	ret

ffffffffc0201758 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201758:	4501                	li	a0,0
ffffffffc020175a:	00005797          	auipc	a5,0x5
ffffffffc020175e:	8a67b783          	ld	a5,-1882(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201762:	88be                	mv	a7,a5
ffffffffc0201764:	852a                	mv	a0,a0
ffffffffc0201766:	85aa                	mv	a1,a0
ffffffffc0201768:	862a                	mv	a2,a0
ffffffffc020176a:	00000073          	ecall
ffffffffc020176e:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201770:	2501                	sext.w	a0,a0
ffffffffc0201772:	8082                	ret

ffffffffc0201774 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201774:	4781                	li	a5,0
ffffffffc0201776:	00005717          	auipc	a4,0x5
ffffffffc020177a:	89a73703          	ld	a4,-1894(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc020177e:	88ba                	mv	a7,a4
ffffffffc0201780:	853e                	mv	a0,a5
ffffffffc0201782:	85be                	mv	a1,a5
ffffffffc0201784:	863e                	mv	a2,a5
ffffffffc0201786:	00000073          	ecall
ffffffffc020178a:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
}
ffffffffc020178c:	8082                	ret

ffffffffc020178e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020178e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201790:	e589                	bnez	a1,ffffffffc020179a <strnlen+0xc>
ffffffffc0201792:	a811                	j	ffffffffc02017a6 <strnlen+0x18>
        cnt ++;
ffffffffc0201794:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201796:	00f58863          	beq	a1,a5,ffffffffc02017a6 <strnlen+0x18>
ffffffffc020179a:	00f50733          	add	a4,a0,a5
ffffffffc020179e:	00074703          	lbu	a4,0(a4)
ffffffffc02017a2:	fb6d                	bnez	a4,ffffffffc0201794 <strnlen+0x6>
ffffffffc02017a4:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02017a6:	852e                	mv	a0,a1
ffffffffc02017a8:	8082                	ret

ffffffffc02017aa <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017aa:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017ae:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017b2:	cb89                	beqz	a5,ffffffffc02017c4 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02017b4:	0505                	addi	a0,a0,1
ffffffffc02017b6:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017b8:	fee789e3          	beq	a5,a4,ffffffffc02017aa <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017bc:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02017c0:	9d19                	subw	a0,a0,a4
ffffffffc02017c2:	8082                	ret
ffffffffc02017c4:	4501                	li	a0,0
ffffffffc02017c6:	bfed                	j	ffffffffc02017c0 <strcmp+0x16>

ffffffffc02017c8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02017c8:	00054783          	lbu	a5,0(a0)
ffffffffc02017cc:	c799                	beqz	a5,ffffffffc02017da <strchr+0x12>
        if (*s == c) {
ffffffffc02017ce:	00f58763          	beq	a1,a5,ffffffffc02017dc <strchr+0x14>
    while (*s != '\0') {
ffffffffc02017d2:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02017d6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02017d8:	fbfd                	bnez	a5,ffffffffc02017ce <strchr+0x6>
    }
    return NULL;
ffffffffc02017da:	4501                	li	a0,0
}
ffffffffc02017dc:	8082                	ret

ffffffffc02017de <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02017de:	ca01                	beqz	a2,ffffffffc02017ee <memset+0x10>
ffffffffc02017e0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02017e2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02017e4:	0785                	addi	a5,a5,1
ffffffffc02017e6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02017ea:	fec79de3          	bne	a5,a2,ffffffffc02017e4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02017ee:	8082                	ret
