
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53a60613          	addi	a2,a2,1338 # ffffffffc0211574 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	4b6040ef          	jal	ra,ffffffffc0204500 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	4e258593          	addi	a1,a1,1250 # ffffffffc0204530 <etext+0x6>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0204550 <etext+0x26>
ffffffffc020005e:	060000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a4000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	2b1010ef          	jal	ra,ffffffffc0201b16 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fe000ef          	jal	ra,ffffffffc0200568 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	73e030ef          	jal	ra,ffffffffc02037ac <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	424000ef          	jal	ra,ffffffffc0200496 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	105020ef          	jal	ra,ffffffffc020297a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	35a000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020007e:	46e000ef          	jal	ra,ffffffffc02004ec <intr_enable>



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x50>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	39a000ef          	jal	ra,ffffffffc0200426 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
ffffffffc02000a0:	862a                	mv	a2,a0
ffffffffc02000a2:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a4:	00000517          	auipc	a0,0x0
ffffffffc02000a8:	fe050513          	addi	a0,a0,-32 # ffffffffc0200084 <cputch>
ffffffffc02000ac:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	79d030ef          	jal	ra,ffffffffc020404e <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	8e2a                	mv	t3,a0
ffffffffc02000c6:	f42e                	sd	a1,40(sp)
ffffffffc02000c8:	f832                	sd	a2,48(sp)
ffffffffc02000ca:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000cc:	00000517          	auipc	a0,0x0
ffffffffc02000d0:	fb850513          	addi	a0,a0,-72 # ffffffffc0200084 <cputch>
ffffffffc02000d4:	004c                	addi	a1,sp,4
ffffffffc02000d6:	869a                	mv	a3,t1
ffffffffc02000d8:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000da:	ec06                	sd	ra,24(sp)
ffffffffc02000dc:	e0ba                	sd	a4,64(sp)
ffffffffc02000de:	e4be                	sd	a5,72(sp)
ffffffffc02000e0:	e8c2                	sd	a6,80(sp)
ffffffffc02000e2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e8:	767030ef          	jal	ra,ffffffffc020404e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ec:	60e2                	ld	ra,24(sp)
ffffffffc02000ee:	4512                	lw	a0,4(sp)
ffffffffc02000f0:	6125                	addi	sp,sp,96
ffffffffc02000f2:	8082                	ret

ffffffffc02000f4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f4:	ae0d                	j	ffffffffc0200426 <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	360000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200108:	00004517          	auipc	a0,0x4
ffffffffc020010c:	45050513          	addi	a0,a0,1104 # ffffffffc0204558 <etext+0x2e>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f1c58593          	addi	a1,a1,-228 # ffffffffc0200032 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	45a50513          	addi	a0,a0,1114 # ffffffffc0204578 <etext+0x4e>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	40058593          	addi	a1,a1,1024 # ffffffffc020452a <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	46650513          	addi	a0,a0,1126 # ffffffffc0204598 <etext+0x6e>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	0000a597          	auipc	a1,0xa
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc020a040 <ide>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	47250513          	addi	a0,a0,1138 # ffffffffc02045b8 <etext+0x8e>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00011597          	auipc	a1,0x11
ffffffffc0200156:	42258593          	addi	a1,a1,1058 # ffffffffc0211574 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	47e50513          	addi	a0,a0,1150 # ffffffffc02045d8 <etext+0xae>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00012597          	auipc	a1,0x12
ffffffffc020016a:	80d58593          	addi	a1,a1,-2035 # ffffffffc0211973 <end+0x3ff>
ffffffffc020016e:	00000797          	auipc	a5,0x0
ffffffffc0200172:	ec478793          	addi	a5,a5,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200180:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200184:	95be                	add	a1,a1,a5
ffffffffc0200186:	85a9                	srai	a1,a1,0xa
ffffffffc0200188:	00004517          	auipc	a0,0x4
ffffffffc020018c:	47050513          	addi	a0,a0,1136 # ffffffffc02045f8 <etext+0xce>
}
ffffffffc0200190:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200192:	b735                	j	ffffffffc02000be <cprintf>

ffffffffc0200194 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200194:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200196:	00004617          	auipc	a2,0x4
ffffffffc020019a:	49260613          	addi	a2,a2,1170 # ffffffffc0204628 <etext+0xfe>
ffffffffc020019e:	04e00593          	li	a1,78
ffffffffc02001a2:	00004517          	auipc	a0,0x4
ffffffffc02001a6:	49e50513          	addi	a0,a0,1182 # ffffffffc0204640 <etext+0x116>
void print_stackframe(void) {
ffffffffc02001aa:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ac:	1cc000ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc02001b0 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001b0:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b2:	00004617          	auipc	a2,0x4
ffffffffc02001b6:	4a660613          	addi	a2,a2,1190 # ffffffffc0204658 <etext+0x12e>
ffffffffc02001ba:	00004597          	auipc	a1,0x4
ffffffffc02001be:	4be58593          	addi	a1,a1,1214 # ffffffffc0204678 <etext+0x14e>
ffffffffc02001c2:	00004517          	auipc	a0,0x4
ffffffffc02001c6:	4be50513          	addi	a0,a0,1214 # ffffffffc0204680 <etext+0x156>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ca:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001cc:	ef3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d0:	00004617          	auipc	a2,0x4
ffffffffc02001d4:	4c060613          	addi	a2,a2,1216 # ffffffffc0204690 <etext+0x166>
ffffffffc02001d8:	00004597          	auipc	a1,0x4
ffffffffc02001dc:	4e058593          	addi	a1,a1,1248 # ffffffffc02046b8 <etext+0x18e>
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	4a050513          	addi	a0,a0,1184 # ffffffffc0204680 <etext+0x156>
ffffffffc02001e8:	ed7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ec:	00004617          	auipc	a2,0x4
ffffffffc02001f0:	4dc60613          	addi	a2,a2,1244 # ffffffffc02046c8 <etext+0x19e>
ffffffffc02001f4:	00004597          	auipc	a1,0x4
ffffffffc02001f8:	4f458593          	addi	a1,a1,1268 # ffffffffc02046e8 <etext+0x1be>
ffffffffc02001fc:	00004517          	auipc	a0,0x4
ffffffffc0200200:	48450513          	addi	a0,a0,1156 # ffffffffc0204680 <etext+0x156>
ffffffffc0200204:	ebbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc0200208:	60a2                	ld	ra,8(sp)
ffffffffc020020a:	4501                	li	a0,0
ffffffffc020020c:	0141                	addi	sp,sp,16
ffffffffc020020e:	8082                	ret

ffffffffc0200210 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200210:	1141                	addi	sp,sp,-16
ffffffffc0200212:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200214:	ef3ff0ef          	jal	ra,ffffffffc0200106 <print_kerninfo>
    return 0;
}
ffffffffc0200218:	60a2                	ld	ra,8(sp)
ffffffffc020021a:	4501                	li	a0,0
ffffffffc020021c:	0141                	addi	sp,sp,16
ffffffffc020021e:	8082                	ret

ffffffffc0200220 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200220:	1141                	addi	sp,sp,-16
ffffffffc0200222:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200224:	f71ff0ef          	jal	ra,ffffffffc0200194 <print_stackframe>
    return 0;
}
ffffffffc0200228:	60a2                	ld	ra,8(sp)
ffffffffc020022a:	4501                	li	a0,0
ffffffffc020022c:	0141                	addi	sp,sp,16
ffffffffc020022e:	8082                	ret

ffffffffc0200230 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200230:	7115                	addi	sp,sp,-224
ffffffffc0200232:	ed5e                	sd	s7,152(sp)
ffffffffc0200234:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200236:	00004517          	auipc	a0,0x4
ffffffffc020023a:	4c250513          	addi	a0,a0,1218 # ffffffffc02046f8 <etext+0x1ce>
kmonitor(struct trapframe *tf) {
ffffffffc020023e:	ed86                	sd	ra,216(sp)
ffffffffc0200240:	e9a2                	sd	s0,208(sp)
ffffffffc0200242:	e5a6                	sd	s1,200(sp)
ffffffffc0200244:	e1ca                	sd	s2,192(sp)
ffffffffc0200246:	fd4e                	sd	s3,184(sp)
ffffffffc0200248:	f952                	sd	s4,176(sp)
ffffffffc020024a:	f556                	sd	s5,168(sp)
ffffffffc020024c:	f15a                	sd	s6,160(sp)
ffffffffc020024e:	e962                	sd	s8,144(sp)
ffffffffc0200250:	e566                	sd	s9,136(sp)
ffffffffc0200252:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200254:	e6bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200258:	00004517          	auipc	a0,0x4
ffffffffc020025c:	4c850513          	addi	a0,a0,1224 # ffffffffc0204720 <etext+0x1f6>
ffffffffc0200260:	e5fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200264:	000b8563          	beqz	s7,ffffffffc020026e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200268:	855e                	mv	a0,s7
ffffffffc020026a:	4e8000ef          	jal	ra,ffffffffc0200752 <print_trapframe>
ffffffffc020026e:	00004c17          	auipc	s8,0x4
ffffffffc0200272:	51ac0c13          	addi	s8,s8,1306 # ffffffffc0204788 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200276:	00006917          	auipc	s2,0x6
ffffffffc020027a:	98290913          	addi	s2,s2,-1662 # ffffffffc0205bf8 <default_pmm_manager+0x928>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027e:	00004497          	auipc	s1,0x4
ffffffffc0200282:	4ca48493          	addi	s1,s1,1226 # ffffffffc0204748 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc0200286:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200288:	00004b17          	auipc	s6,0x4
ffffffffc020028c:	4c8b0b13          	addi	s6,s6,1224 # ffffffffc0204750 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc0200290:	00004a17          	auipc	s4,0x4
ffffffffc0200294:	3e8a0a13          	addi	s4,s4,1000 # ffffffffc0204678 <etext+0x14e>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200298:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029a:	854a                	mv	a0,s2
ffffffffc020029c:	134040ef          	jal	ra,ffffffffc02043d0 <readline>
ffffffffc02002a0:	842a                	mv	s0,a0
ffffffffc02002a2:	dd65                	beqz	a0,ffffffffc020029a <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a4:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a8:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002aa:	e1bd                	bnez	a1,ffffffffc0200310 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002ac:	fe0c87e3          	beqz	s9,ffffffffc020029a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002b0:	6582                	ld	a1,0(sp)
ffffffffc02002b2:	00004d17          	auipc	s10,0x4
ffffffffc02002b6:	4d6d0d13          	addi	s10,s10,1238 # ffffffffc0204788 <commands>
        argv[argc ++] = buf;
ffffffffc02002ba:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002bc:	4401                	li	s0,0
ffffffffc02002be:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c0:	20c040ef          	jal	ra,ffffffffc02044cc <strcmp>
ffffffffc02002c4:	c919                	beqz	a0,ffffffffc02002da <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c6:	2405                	addiw	s0,s0,1
ffffffffc02002c8:	0b540063          	beq	s0,s5,ffffffffc0200368 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002cc:	000d3503          	ld	a0,0(s10)
ffffffffc02002d0:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d4:	1f8040ef          	jal	ra,ffffffffc02044cc <strcmp>
ffffffffc02002d8:	f57d                	bnez	a0,ffffffffc02002c6 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002da:	00141793          	slli	a5,s0,0x1
ffffffffc02002de:	97a2                	add	a5,a5,s0
ffffffffc02002e0:	078e                	slli	a5,a5,0x3
ffffffffc02002e2:	97e2                	add	a5,a5,s8
ffffffffc02002e4:	6b9c                	ld	a5,16(a5)
ffffffffc02002e6:	865e                	mv	a2,s7
ffffffffc02002e8:	002c                	addi	a1,sp,8
ffffffffc02002ea:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ee:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002f0:	fa0555e3          	bgez	a0,ffffffffc020029a <kmonitor+0x6a>
}
ffffffffc02002f4:	60ee                	ld	ra,216(sp)
ffffffffc02002f6:	644e                	ld	s0,208(sp)
ffffffffc02002f8:	64ae                	ld	s1,200(sp)
ffffffffc02002fa:	690e                	ld	s2,192(sp)
ffffffffc02002fc:	79ea                	ld	s3,184(sp)
ffffffffc02002fe:	7a4a                	ld	s4,176(sp)
ffffffffc0200300:	7aaa                	ld	s5,168(sp)
ffffffffc0200302:	7b0a                	ld	s6,160(sp)
ffffffffc0200304:	6bea                	ld	s7,152(sp)
ffffffffc0200306:	6c4a                	ld	s8,144(sp)
ffffffffc0200308:	6caa                	ld	s9,136(sp)
ffffffffc020030a:	6d0a                	ld	s10,128(sp)
ffffffffc020030c:	612d                	addi	sp,sp,224
ffffffffc020030e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200310:	8526                	mv	a0,s1
ffffffffc0200312:	1d8040ef          	jal	ra,ffffffffc02044ea <strchr>
ffffffffc0200316:	c901                	beqz	a0,ffffffffc0200326 <kmonitor+0xf6>
ffffffffc0200318:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020031c:	00040023          	sb	zero,0(s0)
ffffffffc0200320:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200322:	d5c9                	beqz	a1,ffffffffc02002ac <kmonitor+0x7c>
ffffffffc0200324:	b7f5                	j	ffffffffc0200310 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200326:	00044783          	lbu	a5,0(s0)
ffffffffc020032a:	d3c9                	beqz	a5,ffffffffc02002ac <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020032c:	033c8963          	beq	s9,s3,ffffffffc020035e <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200330:	003c9793          	slli	a5,s9,0x3
ffffffffc0200334:	0118                	addi	a4,sp,128
ffffffffc0200336:	97ba                	add	a5,a5,a4
ffffffffc0200338:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033c:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200340:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200342:	e591                	bnez	a1,ffffffffc020034e <kmonitor+0x11e>
ffffffffc0200344:	b7b5                	j	ffffffffc02002b0 <kmonitor+0x80>
ffffffffc0200346:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020034a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020034c:	d1a5                	beqz	a1,ffffffffc02002ac <kmonitor+0x7c>
ffffffffc020034e:	8526                	mv	a0,s1
ffffffffc0200350:	19a040ef          	jal	ra,ffffffffc02044ea <strchr>
ffffffffc0200354:	d96d                	beqz	a0,ffffffffc0200346 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	00044583          	lbu	a1,0(s0)
ffffffffc020035a:	d9a9                	beqz	a1,ffffffffc02002ac <kmonitor+0x7c>
ffffffffc020035c:	bf55                	j	ffffffffc0200310 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035e:	45c1                	li	a1,16
ffffffffc0200360:	855a                	mv	a0,s6
ffffffffc0200362:	d5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200366:	b7e9                	j	ffffffffc0200330 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200368:	6582                	ld	a1,0(sp)
ffffffffc020036a:	00004517          	auipc	a0,0x4
ffffffffc020036e:	40650513          	addi	a0,a0,1030 # ffffffffc0204770 <etext+0x246>
ffffffffc0200372:	d4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc0200376:	b715                	j	ffffffffc020029a <kmonitor+0x6a>

ffffffffc0200378 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200378:	00011317          	auipc	t1,0x11
ffffffffc020037c:	18030313          	addi	t1,t1,384 # ffffffffc02114f8 <is_panic>
ffffffffc0200380:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200384:	715d                	addi	sp,sp,-80
ffffffffc0200386:	ec06                	sd	ra,24(sp)
ffffffffc0200388:	e822                	sd	s0,16(sp)
ffffffffc020038a:	f436                	sd	a3,40(sp)
ffffffffc020038c:	f83a                	sd	a4,48(sp)
ffffffffc020038e:	fc3e                	sd	a5,56(sp)
ffffffffc0200390:	e0c2                	sd	a6,64(sp)
ffffffffc0200392:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200394:	020e1a63          	bnez	t3,ffffffffc02003c8 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200398:	4785                	li	a5,1
ffffffffc020039a:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039e:	8432                	mv	s0,a2
ffffffffc02003a0:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a2:	862e                	mv	a2,a1
ffffffffc02003a4:	85aa                	mv	a1,a0
ffffffffc02003a6:	00004517          	auipc	a0,0x4
ffffffffc02003aa:	42a50513          	addi	a0,a0,1066 # ffffffffc02047d0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003ae:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003b0:	d0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b4:	65a2                	ld	a1,8(sp)
ffffffffc02003b6:	8522                	mv	a0,s0
ffffffffc02003b8:	ce7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	e0450513          	addi	a0,a0,-508 # ffffffffc02061c0 <default_pmm_manager+0xef0>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	12a000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e63ff0ef          	jal	ra,ffffffffc0200230 <kmonitor>
    while (1) {
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x54>

ffffffffc02003d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003da:	00011717          	auipc	a4,0x11
ffffffffc02003de:	12f73723          	sd	a5,302(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e2:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	953e                	add	a0,a0,a5
ffffffffc02003ea:	4601                	li	a2,0
ffffffffc02003ec:	4881                	li	a7,0
ffffffffc02003ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003f2:	02000793          	li	a5,32
ffffffffc02003f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003fa:	00004517          	auipc	a0,0x4
ffffffffc02003fe:	3f650513          	addi	a0,a0,1014 # ffffffffc02047f0 <commands+0x68>
    ticks = 0;
ffffffffc0200402:	00011797          	auipc	a5,0x11
ffffffffc0200406:	0e07bf23          	sd	zero,254(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	b955                	j	ffffffffc02000be <cprintf>

ffffffffc020040c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200410:	00011797          	auipc	a5,0x11
ffffffffc0200414:	0f87b783          	ld	a5,248(a5) # ffffffffc0211508 <timebase>
ffffffffc0200418:	953e                	add	a0,a0,a5
ffffffffc020041a:	4581                	li	a1,0
ffffffffc020041c:	4601                	li	a2,0
ffffffffc020041e:	4881                	li	a7,0
ffffffffc0200420:	00000073          	ecall
ffffffffc0200424:	8082                	ret

ffffffffc0200426 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200426:	100027f3          	csrr	a5,sstatus
ffffffffc020042a:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020042c:	0ff57513          	andi	a0,a0,255
ffffffffc0200430:	e799                	bnez	a5,ffffffffc020043e <cons_putc+0x18>
ffffffffc0200432:	4581                	li	a1,0
ffffffffc0200434:	4601                	li	a2,0
ffffffffc0200436:	4885                	li	a7,1
ffffffffc0200438:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020043c:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043e:	1101                	addi	sp,sp,-32
ffffffffc0200440:	ec06                	sd	ra,24(sp)
ffffffffc0200442:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200444:	0ae000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0200448:	6522                	ld	a0,8(sp)
ffffffffc020044a:	4581                	li	a1,0
ffffffffc020044c:	4601                	li	a2,0
ffffffffc020044e:	4885                	li	a7,1
ffffffffc0200450:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200454:	60e2                	ld	ra,24(sp)
ffffffffc0200456:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200458:	a851                	j	ffffffffc02004ec <intr_enable>

ffffffffc020045a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020045a:	100027f3          	csrr	a5,sstatus
ffffffffc020045e:	8b89                	andi	a5,a5,2
ffffffffc0200460:	eb89                	bnez	a5,ffffffffc0200472 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200462:	4501                	li	a0,0
ffffffffc0200464:	4581                	li	a1,0
ffffffffc0200466:	4601                	li	a2,0
ffffffffc0200468:	4889                	li	a7,2
ffffffffc020046a:	00000073          	ecall
ffffffffc020046e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200470:	8082                	ret
int cons_getc(void) {
ffffffffc0200472:	1101                	addi	sp,sp,-32
ffffffffc0200474:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200476:	07c000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc020047a:	4501                	li	a0,0
ffffffffc020047c:	4581                	li	a1,0
ffffffffc020047e:	4601                	li	a2,0
ffffffffc0200480:	4889                	li	a7,2
ffffffffc0200482:	00000073          	ecall
ffffffffc0200486:	2501                	sext.w	a0,a0
ffffffffc0200488:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020048a:	062000ef          	jal	ra,ffffffffc02004ec <intr_enable>
}
ffffffffc020048e:	60e2                	ld	ra,24(sp)
ffffffffc0200490:	6522                	ld	a0,8(sp)
ffffffffc0200492:	6105                	addi	sp,sp,32
ffffffffc0200494:	8082                	ret

ffffffffc0200496 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200496:	8082                	ret

ffffffffc0200498 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200498:	00253513          	sltiu	a0,a0,2
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049e:	03800513          	li	a0,56
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a4:	0000a797          	auipc	a5,0xa
ffffffffc02004a8:	b9c78793          	addi	a5,a5,-1124 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004ac:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b0:	1141                	addi	sp,sp,-16
ffffffffc02004b2:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b4:	95be                	add	a1,a1,a5
ffffffffc02004b6:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004ba:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004bc:	056040ef          	jal	ra,ffffffffc0204512 <memcpy>
    return 0;
}
ffffffffc02004c0:	60a2                	ld	ra,8(sp)
ffffffffc02004c2:	4501                	li	a0,0
ffffffffc02004c4:	0141                	addi	sp,sp,16
ffffffffc02004c6:	8082                	ret

ffffffffc02004c8 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004c8:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004cc:	0000a517          	auipc	a0,0xa
ffffffffc02004d0:	b7450513          	addi	a0,a0,-1164 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d4:	1141                	addi	sp,sp,-16
ffffffffc02004d6:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d8:	953e                	add	a0,a0,a5
ffffffffc02004da:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004de:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e0:	032040ef          	jal	ra,ffffffffc0204512 <memcpy>
    return 0;
}
ffffffffc02004e4:	60a2                	ld	ra,8(sp)
ffffffffc02004e6:	4501                	li	a0,0
ffffffffc02004e8:	0141                	addi	sp,sp,16
ffffffffc02004ea:	8082                	ret

ffffffffc02004ec <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ec:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f0:	8082                	ret

ffffffffc02004f2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004fc:	1141                	addi	sp,sp,-16
ffffffffc02004fe:	e022                	sd	s0,0(sp)
ffffffffc0200500:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200502:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200506:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050a:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc020050c:	05500613          	li	a2,85
ffffffffc0200510:	c399                	beqz	a5,ffffffffc0200516 <pgfault_handler+0x1e>
ffffffffc0200512:	04b00613          	li	a2,75
ffffffffc0200516:	11843703          	ld	a4,280(s0)
ffffffffc020051a:	47bd                	li	a5,15
ffffffffc020051c:	05700693          	li	a3,87
ffffffffc0200520:	00f70463          	beq	a4,a5,ffffffffc0200528 <pgfault_handler+0x30>
ffffffffc0200524:	05200693          	li	a3,82
ffffffffc0200528:	00004517          	auipc	a0,0x4
ffffffffc020052c:	2e850513          	addi	a0,a0,744 # ffffffffc0204810 <commands+0x88>
ffffffffc0200530:	b8fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200534:	00011517          	auipc	a0,0x11
ffffffffc0200538:	03453503          	ld	a0,52(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc020053c:	c911                	beqz	a0,ffffffffc0200550 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053e:	11043603          	ld	a2,272(s0)
ffffffffc0200542:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200546:	6402                	ld	s0,0(sp)
ffffffffc0200548:	60a2                	ld	ra,8(sp)
ffffffffc020054a:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020054c:	0390306f          	j	ffffffffc0203d84 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200550:	00004617          	auipc	a2,0x4
ffffffffc0200554:	2e060613          	addi	a2,a2,736 # ffffffffc0204830 <commands+0xa8>
ffffffffc0200558:	07900593          	li	a1,121
ffffffffc020055c:	00004517          	auipc	a0,0x4
ffffffffc0200560:	2ec50513          	addi	a0,a0,748 # ffffffffc0204848 <commands+0xc0>
ffffffffc0200564:	e15ff0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0200568 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200568:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020056c:	00000797          	auipc	a5,0x0
ffffffffc0200570:	4e478793          	addi	a5,a5,1252 # ffffffffc0200a50 <__alltraps>
ffffffffc0200574:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200578:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020057c:	000407b7          	lui	a5,0x40
ffffffffc0200580:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200584:	8082                	ret

ffffffffc0200586 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200586:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200588:	1141                	addi	sp,sp,-16
ffffffffc020058a:	e022                	sd	s0,0(sp)
ffffffffc020058c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058e:	00004517          	auipc	a0,0x4
ffffffffc0200592:	2d250513          	addi	a0,a0,722 # ffffffffc0204860 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200596:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	b27ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020059c:	640c                	ld	a1,8(s0)
ffffffffc020059e:	00004517          	auipc	a0,0x4
ffffffffc02005a2:	2da50513          	addi	a0,a0,730 # ffffffffc0204878 <commands+0xf0>
ffffffffc02005a6:	b19ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005aa:	680c                	ld	a1,16(s0)
ffffffffc02005ac:	00004517          	auipc	a0,0x4
ffffffffc02005b0:	2e450513          	addi	a0,a0,740 # ffffffffc0204890 <commands+0x108>
ffffffffc02005b4:	b0bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b8:	6c0c                	ld	a1,24(s0)
ffffffffc02005ba:	00004517          	auipc	a0,0x4
ffffffffc02005be:	2ee50513          	addi	a0,a0,750 # ffffffffc02048a8 <commands+0x120>
ffffffffc02005c2:	afdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c6:	700c                	ld	a1,32(s0)
ffffffffc02005c8:	00004517          	auipc	a0,0x4
ffffffffc02005cc:	2f850513          	addi	a0,a0,760 # ffffffffc02048c0 <commands+0x138>
ffffffffc02005d0:	aefff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d4:	740c                	ld	a1,40(s0)
ffffffffc02005d6:	00004517          	auipc	a0,0x4
ffffffffc02005da:	30250513          	addi	a0,a0,770 # ffffffffc02048d8 <commands+0x150>
ffffffffc02005de:	ae1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005e2:	780c                	ld	a1,48(s0)
ffffffffc02005e4:	00004517          	auipc	a0,0x4
ffffffffc02005e8:	30c50513          	addi	a0,a0,780 # ffffffffc02048f0 <commands+0x168>
ffffffffc02005ec:	ad3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005f0:	7c0c                	ld	a1,56(s0)
ffffffffc02005f2:	00004517          	auipc	a0,0x4
ffffffffc02005f6:	31650513          	addi	a0,a0,790 # ffffffffc0204908 <commands+0x180>
ffffffffc02005fa:	ac5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fe:	602c                	ld	a1,64(s0)
ffffffffc0200600:	00004517          	auipc	a0,0x4
ffffffffc0200604:	32050513          	addi	a0,a0,800 # ffffffffc0204920 <commands+0x198>
ffffffffc0200608:	ab7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc020060c:	642c                	ld	a1,72(s0)
ffffffffc020060e:	00004517          	auipc	a0,0x4
ffffffffc0200612:	32a50513          	addi	a0,a0,810 # ffffffffc0204938 <commands+0x1b0>
ffffffffc0200616:	aa9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020061a:	682c                	ld	a1,80(s0)
ffffffffc020061c:	00004517          	auipc	a0,0x4
ffffffffc0200620:	33450513          	addi	a0,a0,820 # ffffffffc0204950 <commands+0x1c8>
ffffffffc0200624:	a9bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200628:	6c2c                	ld	a1,88(s0)
ffffffffc020062a:	00004517          	auipc	a0,0x4
ffffffffc020062e:	33e50513          	addi	a0,a0,830 # ffffffffc0204968 <commands+0x1e0>
ffffffffc0200632:	a8dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200636:	702c                	ld	a1,96(s0)
ffffffffc0200638:	00004517          	auipc	a0,0x4
ffffffffc020063c:	34850513          	addi	a0,a0,840 # ffffffffc0204980 <commands+0x1f8>
ffffffffc0200640:	a7fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200644:	742c                	ld	a1,104(s0)
ffffffffc0200646:	00004517          	auipc	a0,0x4
ffffffffc020064a:	35250513          	addi	a0,a0,850 # ffffffffc0204998 <commands+0x210>
ffffffffc020064e:	a71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200652:	782c                	ld	a1,112(s0)
ffffffffc0200654:	00004517          	auipc	a0,0x4
ffffffffc0200658:	35c50513          	addi	a0,a0,860 # ffffffffc02049b0 <commands+0x228>
ffffffffc020065c:	a63ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200660:	7c2c                	ld	a1,120(s0)
ffffffffc0200662:	00004517          	auipc	a0,0x4
ffffffffc0200666:	36650513          	addi	a0,a0,870 # ffffffffc02049c8 <commands+0x240>
ffffffffc020066a:	a55ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066e:	604c                	ld	a1,128(s0)
ffffffffc0200670:	00004517          	auipc	a0,0x4
ffffffffc0200674:	37050513          	addi	a0,a0,880 # ffffffffc02049e0 <commands+0x258>
ffffffffc0200678:	a47ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020067c:	644c                	ld	a1,136(s0)
ffffffffc020067e:	00004517          	auipc	a0,0x4
ffffffffc0200682:	37a50513          	addi	a0,a0,890 # ffffffffc02049f8 <commands+0x270>
ffffffffc0200686:	a39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020068a:	684c                	ld	a1,144(s0)
ffffffffc020068c:	00004517          	auipc	a0,0x4
ffffffffc0200690:	38450513          	addi	a0,a0,900 # ffffffffc0204a10 <commands+0x288>
ffffffffc0200694:	a2bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200698:	6c4c                	ld	a1,152(s0)
ffffffffc020069a:	00004517          	auipc	a0,0x4
ffffffffc020069e:	38e50513          	addi	a0,a0,910 # ffffffffc0204a28 <commands+0x2a0>
ffffffffc02006a2:	a1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a6:	704c                	ld	a1,160(s0)
ffffffffc02006a8:	00004517          	auipc	a0,0x4
ffffffffc02006ac:	39850513          	addi	a0,a0,920 # ffffffffc0204a40 <commands+0x2b8>
ffffffffc02006b0:	a0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b4:	744c                	ld	a1,168(s0)
ffffffffc02006b6:	00004517          	auipc	a0,0x4
ffffffffc02006ba:	3a250513          	addi	a0,a0,930 # ffffffffc0204a58 <commands+0x2d0>
ffffffffc02006be:	a01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006c2:	784c                	ld	a1,176(s0)
ffffffffc02006c4:	00004517          	auipc	a0,0x4
ffffffffc02006c8:	3ac50513          	addi	a0,a0,940 # ffffffffc0204a70 <commands+0x2e8>
ffffffffc02006cc:	9f3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006d0:	7c4c                	ld	a1,184(s0)
ffffffffc02006d2:	00004517          	auipc	a0,0x4
ffffffffc02006d6:	3b650513          	addi	a0,a0,950 # ffffffffc0204a88 <commands+0x300>
ffffffffc02006da:	9e5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006de:	606c                	ld	a1,192(s0)
ffffffffc02006e0:	00004517          	auipc	a0,0x4
ffffffffc02006e4:	3c050513          	addi	a0,a0,960 # ffffffffc0204aa0 <commands+0x318>
ffffffffc02006e8:	9d7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006ec:	646c                	ld	a1,200(s0)
ffffffffc02006ee:	00004517          	auipc	a0,0x4
ffffffffc02006f2:	3ca50513          	addi	a0,a0,970 # ffffffffc0204ab8 <commands+0x330>
ffffffffc02006f6:	9c9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006fa:	686c                	ld	a1,208(s0)
ffffffffc02006fc:	00004517          	auipc	a0,0x4
ffffffffc0200700:	3d450513          	addi	a0,a0,980 # ffffffffc0204ad0 <commands+0x348>
ffffffffc0200704:	9bbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200708:	6c6c                	ld	a1,216(s0)
ffffffffc020070a:	00004517          	auipc	a0,0x4
ffffffffc020070e:	3de50513          	addi	a0,a0,990 # ffffffffc0204ae8 <commands+0x360>
ffffffffc0200712:	9adff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200716:	706c                	ld	a1,224(s0)
ffffffffc0200718:	00004517          	auipc	a0,0x4
ffffffffc020071c:	3e850513          	addi	a0,a0,1000 # ffffffffc0204b00 <commands+0x378>
ffffffffc0200720:	99fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200724:	746c                	ld	a1,232(s0)
ffffffffc0200726:	00004517          	auipc	a0,0x4
ffffffffc020072a:	3f250513          	addi	a0,a0,1010 # ffffffffc0204b18 <commands+0x390>
ffffffffc020072e:	991ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200732:	786c                	ld	a1,240(s0)
ffffffffc0200734:	00004517          	auipc	a0,0x4
ffffffffc0200738:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204b30 <commands+0x3a8>
ffffffffc020073c:	983ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200740:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200742:	6402                	ld	s0,0(sp)
ffffffffc0200744:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200746:	00004517          	auipc	a0,0x4
ffffffffc020074a:	40250513          	addi	a0,a0,1026 # ffffffffc0204b48 <commands+0x3c0>
}
ffffffffc020074e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	b2bd                	j	ffffffffc02000be <cprintf>

ffffffffc0200752 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200752:	1141                	addi	sp,sp,-16
ffffffffc0200754:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200758:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	40650513          	addi	a0,a0,1030 # ffffffffc0204b60 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200762:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200764:	95bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200768:	8522                	mv	a0,s0
ffffffffc020076a:	e1dff0ef          	jal	ra,ffffffffc0200586 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076e:	10043583          	ld	a1,256(s0)
ffffffffc0200772:	00004517          	auipc	a0,0x4
ffffffffc0200776:	40650513          	addi	a0,a0,1030 # ffffffffc0204b78 <commands+0x3f0>
ffffffffc020077a:	945ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077e:	10843583          	ld	a1,264(s0)
ffffffffc0200782:	00004517          	auipc	a0,0x4
ffffffffc0200786:	40e50513          	addi	a0,a0,1038 # ffffffffc0204b90 <commands+0x408>
ffffffffc020078a:	935ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078e:	11043583          	ld	a1,272(s0)
ffffffffc0200792:	00004517          	auipc	a0,0x4
ffffffffc0200796:	41650513          	addi	a0,a0,1046 # ffffffffc0204ba8 <commands+0x420>
ffffffffc020079a:	925ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079e:	11843583          	ld	a1,280(s0)
}
ffffffffc02007a2:	6402                	ld	s0,0(sp)
ffffffffc02007a4:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a6:	00004517          	auipc	a0,0x4
ffffffffc02007aa:	41a50513          	addi	a0,a0,1050 # ffffffffc0204bc0 <commands+0x438>
}
ffffffffc02007ae:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b0:	90fff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007b4 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b4:	11853783          	ld	a5,280(a0)
ffffffffc02007b8:	472d                	li	a4,11
ffffffffc02007ba:	0786                	slli	a5,a5,0x1
ffffffffc02007bc:	8385                	srli	a5,a5,0x1
ffffffffc02007be:	08f76d63          	bltu	a4,a5,ffffffffc0200858 <interrupt_handler+0xa4>
ffffffffc02007c2:	00004717          	auipc	a4,0x4
ffffffffc02007c6:	4c670713          	addi	a4,a4,1222 # ffffffffc0204c88 <commands+0x500>
ffffffffc02007ca:	078a                	slli	a5,a5,0x2
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	439c                	lw	a5,0(a5)
ffffffffc02007d0:	97ba                	add	a5,a5,a4
ffffffffc02007d2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d4:	00004517          	auipc	a0,0x4
ffffffffc02007d8:	46450513          	addi	a0,a0,1124 # ffffffffc0204c38 <commands+0x4b0>
ffffffffc02007dc:	8e3ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007e0:	00004517          	auipc	a0,0x4
ffffffffc02007e4:	43850513          	addi	a0,a0,1080 # ffffffffc0204c18 <commands+0x490>
ffffffffc02007e8:	8d7ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007ec:	00004517          	auipc	a0,0x4
ffffffffc02007f0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204bd8 <commands+0x450>
ffffffffc02007f4:	8cbff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f8:	00004517          	auipc	a0,0x4
ffffffffc02007fc:	40050513          	addi	a0,a0,1024 # ffffffffc0204bf8 <commands+0x470>
ffffffffc0200800:	8bfff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200804:	1141                	addi	sp,sp,-16
ffffffffc0200806:	e022                	sd	s0,0(sp)
ffffffffc0200808:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc020080a:	c03ff0ef          	jal	ra,ffffffffc020040c <clock_set_next_event>
            ++ticks;
ffffffffc020080e:	00011797          	auipc	a5,0x11
ffffffffc0200812:	cf278793          	addi	a5,a5,-782 # ffffffffc0211500 <ticks>
ffffffffc0200816:	6398                	ld	a4,0(a5)
ffffffffc0200818:	00011417          	auipc	s0,0x11
ffffffffc020081c:	cf840413          	addi	s0,s0,-776 # ffffffffc0211510 <num>
ffffffffc0200820:	0705                	addi	a4,a4,1
ffffffffc0200822:	e398                	sd	a4,0(a5)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200824:	639c                	ld	a5,0(a5)
ffffffffc0200826:	06400713          	li	a4,100
ffffffffc020082a:	02e7f7b3          	remu	a5,a5,a4
ffffffffc020082e:	c795                	beqz	a5,ffffffffc020085a <interrupt_handler+0xa6>
                print_ticks();
                num++;
            }
            if(num == 10)
ffffffffc0200830:	6018                	ld	a4,0(s0)
ffffffffc0200832:	47a9                	li	a5,10
ffffffffc0200834:	00f71863          	bne	a4,a5,ffffffffc0200844 <interrupt_handler+0x90>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200838:	4501                	li	a0,0
ffffffffc020083a:	4581                	li	a1,0
ffffffffc020083c:	4601                	li	a2,0
ffffffffc020083e:	48a1                	li	a7,8
ffffffffc0200840:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	6402                	ld	s0,0(sp)
ffffffffc0200848:	0141                	addi	sp,sp,16
ffffffffc020084a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020084c:	00004517          	auipc	a0,0x4
ffffffffc0200850:	41c50513          	addi	a0,a0,1052 # ffffffffc0204c68 <commands+0x4e0>
ffffffffc0200854:	86bff06f          	j	ffffffffc02000be <cprintf>
            print_trapframe(tf);
ffffffffc0200858:	bded                	j	ffffffffc0200752 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085a:	06400593          	li	a1,100
ffffffffc020085e:	00004517          	auipc	a0,0x4
ffffffffc0200862:	3fa50513          	addi	a0,a0,1018 # ffffffffc0204c58 <commands+0x4d0>
ffffffffc0200866:	859ff0ef          	jal	ra,ffffffffc02000be <cprintf>
                num++;
ffffffffc020086a:	601c                	ld	a5,0(s0)
ffffffffc020086c:	0785                	addi	a5,a5,1
ffffffffc020086e:	e01c                	sd	a5,0(s0)
ffffffffc0200870:	b7c1                	j	ffffffffc0200830 <interrupt_handler+0x7c>

ffffffffc0200872 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200872:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200876:	1101                	addi	sp,sp,-32
ffffffffc0200878:	e822                	sd	s0,16(sp)
ffffffffc020087a:	ec06                	sd	ra,24(sp)
ffffffffc020087c:	e426                	sd	s1,8(sp)
ffffffffc020087e:	473d                	li	a4,15
ffffffffc0200880:	842a                	mv	s0,a0
ffffffffc0200882:	18f76963          	bltu	a4,a5,ffffffffc0200a14 <exception_handler+0x1a2>
ffffffffc0200886:	00004717          	auipc	a4,0x4
ffffffffc020088a:	64a70713          	addi	a4,a4,1610 # ffffffffc0204ed0 <commands+0x748>
ffffffffc020088e:	078a                	slli	a5,a5,0x2
ffffffffc0200890:	97ba                	add	a5,a5,a4
ffffffffc0200892:	439c                	lw	a5,0(a5)
ffffffffc0200894:	97ba                	add	a5,a5,a4
ffffffffc0200896:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200898:	00004517          	auipc	a0,0x4
ffffffffc020089c:	62050513          	addi	a0,a0,1568 # ffffffffc0204eb8 <commands+0x730>
ffffffffc02008a0:	81fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008a4:	8522                	mv	a0,s0
ffffffffc02008a6:	c53ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc02008aa:	84aa                	mv	s1,a0
ffffffffc02008ac:	16051a63          	bnez	a0,ffffffffc0200a20 <exception_handler+0x1ae>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008b0:	60e2                	ld	ra,24(sp)
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	64a2                	ld	s1,8(sp)
ffffffffc02008b6:	6105                	addi	sp,sp,32
ffffffffc02008b8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008ba:	00004517          	auipc	a0,0x4
ffffffffc02008be:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204cb8 <commands+0x530>
}
ffffffffc02008c2:	6442                	ld	s0,16(sp)
ffffffffc02008c4:	60e2                	ld	ra,24(sp)
ffffffffc02008c6:	64a2                	ld	s1,8(sp)
ffffffffc02008c8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ca:	ff4ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008ce:	00004517          	auipc	a0,0x4
ffffffffc02008d2:	40a50513          	addi	a0,a0,1034 # ffffffffc0204cd8 <commands+0x550>
ffffffffc02008d6:	b7f5                	j	ffffffffc02008c2 <exception_handler+0x50>
             cprintf("Exception Type: Illegal instruction\n");
ffffffffc02008d8:	00004517          	auipc	a0,0x4
ffffffffc02008dc:	42050513          	addi	a0,a0,1056 # ffffffffc0204cf8 <commands+0x570>
ffffffffc02008e0:	fdeff0ef          	jal	ra,ffffffffc02000be <cprintf>
             cprintf("Illegal instruction caught at 0x%lx\n",tf->epc);
ffffffffc02008e4:	10843583          	ld	a1,264(s0)
ffffffffc02008e8:	00004517          	auipc	a0,0x4
ffffffffc02008ec:	43850513          	addi	a0,a0,1080 # ffffffffc0204d20 <commands+0x598>
ffffffffc02008f0:	fceff0ef          	jal	ra,ffffffffc02000be <cprintf>
             tf->epc+=4;
ffffffffc02008f4:	10843783          	ld	a5,264(s0)
ffffffffc02008f8:	0791                	addi	a5,a5,4
ffffffffc02008fa:	10f43423          	sd	a5,264(s0)
             break;
ffffffffc02008fe:	bf4d                	j	ffffffffc02008b0 <exception_handler+0x3e>
            cprintf("Exception Type: breakpoint\n");
ffffffffc0200900:	00004517          	auipc	a0,0x4
ffffffffc0200904:	44850513          	addi	a0,a0,1096 # ffffffffc0204d48 <commands+0x5c0>
ffffffffc0200908:	fb6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            cprintf("ebreak caught at 0x%lx\n",tf->epc);
ffffffffc020090c:	10843583          	ld	a1,264(s0)
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	45850513          	addi	a0,a0,1112 # ffffffffc0204d68 <commands+0x5e0>
ffffffffc0200918:	fa6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            tf->epc+=2;
ffffffffc020091c:	10843783          	ld	a5,264(s0)
ffffffffc0200920:	0789                	addi	a5,a5,2
ffffffffc0200922:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200926:	b769                	j	ffffffffc02008b0 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200928:	00004517          	auipc	a0,0x4
ffffffffc020092c:	45850513          	addi	a0,a0,1112 # ffffffffc0204d80 <commands+0x5f8>
ffffffffc0200930:	bf49                	j	ffffffffc02008c2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	46e50513          	addi	a0,a0,1134 # ffffffffc0204da0 <commands+0x618>
ffffffffc020093a:	f84ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020093e:	8522                	mv	a0,s0
ffffffffc0200940:	bb9ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc0200944:	84aa                	mv	s1,a0
ffffffffc0200946:	d52d                	beqz	a0,ffffffffc02008b0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200948:	8522                	mv	a0,s0
ffffffffc020094a:	e09ff0ef          	jal	ra,ffffffffc0200752 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020094e:	86a6                	mv	a3,s1
ffffffffc0200950:	00004617          	auipc	a2,0x4
ffffffffc0200954:	46860613          	addi	a2,a2,1128 # ffffffffc0204db8 <commands+0x630>
ffffffffc0200958:	0db00593          	li	a1,219
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	eec50513          	addi	a0,a0,-276 # ffffffffc0204848 <commands+0xc0>
ffffffffc0200964:	a15ff0ef          	jal	ra,ffffffffc0200378 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200968:	00004517          	auipc	a0,0x4
ffffffffc020096c:	47050513          	addi	a0,a0,1136 # ffffffffc0204dd8 <commands+0x650>
ffffffffc0200970:	bf89                	j	ffffffffc02008c2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200972:	00004517          	auipc	a0,0x4
ffffffffc0200976:	47e50513          	addi	a0,a0,1150 # ffffffffc0204df0 <commands+0x668>
ffffffffc020097a:	f44ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020097e:	8522                	mv	a0,s0
ffffffffc0200980:	b79ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc0200984:	84aa                	mv	s1,a0
ffffffffc0200986:	f20505e3          	beqz	a0,ffffffffc02008b0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098a:	8522                	mv	a0,s0
ffffffffc020098c:	dc7ff0ef          	jal	ra,ffffffffc0200752 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200990:	86a6                	mv	a3,s1
ffffffffc0200992:	00004617          	auipc	a2,0x4
ffffffffc0200996:	42660613          	addi	a2,a2,1062 # ffffffffc0204db8 <commands+0x630>
ffffffffc020099a:	0e500593          	li	a1,229
ffffffffc020099e:	00004517          	auipc	a0,0x4
ffffffffc02009a2:	eaa50513          	addi	a0,a0,-342 # ffffffffc0204848 <commands+0xc0>
ffffffffc02009a6:	9d3ff0ef          	jal	ra,ffffffffc0200378 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009aa:	00004517          	auipc	a0,0x4
ffffffffc02009ae:	45e50513          	addi	a0,a0,1118 # ffffffffc0204e08 <commands+0x680>
ffffffffc02009b2:	bf01                	j	ffffffffc02008c2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009b4:	00004517          	auipc	a0,0x4
ffffffffc02009b8:	47450513          	addi	a0,a0,1140 # ffffffffc0204e28 <commands+0x6a0>
ffffffffc02009bc:	b719                	j	ffffffffc02008c2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009be:	00004517          	auipc	a0,0x4
ffffffffc02009c2:	48a50513          	addi	a0,a0,1162 # ffffffffc0204e48 <commands+0x6c0>
ffffffffc02009c6:	bdf5                	j	ffffffffc02008c2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	4a050513          	addi	a0,a0,1184 # ffffffffc0204e68 <commands+0x6e0>
ffffffffc02009d0:	bdcd                	j	ffffffffc02008c2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009d2:	00004517          	auipc	a0,0x4
ffffffffc02009d6:	4b650513          	addi	a0,a0,1206 # ffffffffc0204e88 <commands+0x700>
ffffffffc02009da:	b5e5                	j	ffffffffc02008c2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009dc:	00004517          	auipc	a0,0x4
ffffffffc02009e0:	4c450513          	addi	a0,a0,1220 # ffffffffc0204ea0 <commands+0x718>
ffffffffc02009e4:	edaff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009e8:	8522                	mv	a0,s0
ffffffffc02009ea:	b0fff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc02009ee:	84aa                	mv	s1,a0
ffffffffc02009f0:	ec0500e3          	beqz	a0,ffffffffc02008b0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	d5dff0ef          	jal	ra,ffffffffc0200752 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00004617          	auipc	a2,0x4
ffffffffc0200a00:	3bc60613          	addi	a2,a2,956 # ffffffffc0204db8 <commands+0x630>
ffffffffc0200a04:	0fb00593          	li	a1,251
ffffffffc0200a08:	00004517          	auipc	a0,0x4
ffffffffc0200a0c:	e4050513          	addi	a0,a0,-448 # ffffffffc0204848 <commands+0xc0>
ffffffffc0200a10:	969ff0ef          	jal	ra,ffffffffc0200378 <__panic>
            print_trapframe(tf);
ffffffffc0200a14:	8522                	mv	a0,s0
}
ffffffffc0200a16:	6442                	ld	s0,16(sp)
ffffffffc0200a18:	60e2                	ld	ra,24(sp)
ffffffffc0200a1a:	64a2                	ld	s1,8(sp)
ffffffffc0200a1c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a1e:	bb15                	j	ffffffffc0200752 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a20:	8522                	mv	a0,s0
ffffffffc0200a22:	d31ff0ef          	jal	ra,ffffffffc0200752 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a26:	86a6                	mv	a3,s1
ffffffffc0200a28:	00004617          	auipc	a2,0x4
ffffffffc0200a2c:	39060613          	addi	a2,a2,912 # ffffffffc0204db8 <commands+0x630>
ffffffffc0200a30:	10200593          	li	a1,258
ffffffffc0200a34:	00004517          	auipc	a0,0x4
ffffffffc0200a38:	e1450513          	addi	a0,a0,-492 # ffffffffc0204848 <commands+0xc0>
ffffffffc0200a3c:	93dff0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0200a40 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a40:	11853783          	ld	a5,280(a0)
ffffffffc0200a44:	0007c363          	bltz	a5,ffffffffc0200a4a <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a48:	b52d                	j	ffffffffc0200872 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a4a:	b3ad                	j	ffffffffc02007b4 <interrupt_handler>
ffffffffc0200a4c:	0000                	unimp
	...

ffffffffc0200a50 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a50:	14011073          	csrw	sscratch,sp
ffffffffc0200a54:	712d                	addi	sp,sp,-288
ffffffffc0200a56:	e406                	sd	ra,8(sp)
ffffffffc0200a58:	ec0e                	sd	gp,24(sp)
ffffffffc0200a5a:	f012                	sd	tp,32(sp)
ffffffffc0200a5c:	f416                	sd	t0,40(sp)
ffffffffc0200a5e:	f81a                	sd	t1,48(sp)
ffffffffc0200a60:	fc1e                	sd	t2,56(sp)
ffffffffc0200a62:	e0a2                	sd	s0,64(sp)
ffffffffc0200a64:	e4a6                	sd	s1,72(sp)
ffffffffc0200a66:	e8aa                	sd	a0,80(sp)
ffffffffc0200a68:	ecae                	sd	a1,88(sp)
ffffffffc0200a6a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a6c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a6e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a70:	fcbe                	sd	a5,120(sp)
ffffffffc0200a72:	e142                	sd	a6,128(sp)
ffffffffc0200a74:	e546                	sd	a7,136(sp)
ffffffffc0200a76:	e94a                	sd	s2,144(sp)
ffffffffc0200a78:	ed4e                	sd	s3,152(sp)
ffffffffc0200a7a:	f152                	sd	s4,160(sp)
ffffffffc0200a7c:	f556                	sd	s5,168(sp)
ffffffffc0200a7e:	f95a                	sd	s6,176(sp)
ffffffffc0200a80:	fd5e                	sd	s7,184(sp)
ffffffffc0200a82:	e1e2                	sd	s8,192(sp)
ffffffffc0200a84:	e5e6                	sd	s9,200(sp)
ffffffffc0200a86:	e9ea                	sd	s10,208(sp)
ffffffffc0200a88:	edee                	sd	s11,216(sp)
ffffffffc0200a8a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a8c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a8e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a90:	fdfe                	sd	t6,248(sp)
ffffffffc0200a92:	14002473          	csrr	s0,sscratch
ffffffffc0200a96:	100024f3          	csrr	s1,sstatus
ffffffffc0200a9a:	14102973          	csrr	s2,sepc
ffffffffc0200a9e:	143029f3          	csrr	s3,stval
ffffffffc0200aa2:	14202a73          	csrr	s4,scause
ffffffffc0200aa6:	e822                	sd	s0,16(sp)
ffffffffc0200aa8:	e226                	sd	s1,256(sp)
ffffffffc0200aaa:	e64a                	sd	s2,264(sp)
ffffffffc0200aac:	ea4e                	sd	s3,272(sp)
ffffffffc0200aae:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ab0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ab2:	f8fff0ef          	jal	ra,ffffffffc0200a40 <trap>

ffffffffc0200ab6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ab6:	6492                	ld	s1,256(sp)
ffffffffc0200ab8:	6932                	ld	s2,264(sp)
ffffffffc0200aba:	10049073          	csrw	sstatus,s1
ffffffffc0200abe:	14191073          	csrw	sepc,s2
ffffffffc0200ac2:	60a2                	ld	ra,8(sp)
ffffffffc0200ac4:	61e2                	ld	gp,24(sp)
ffffffffc0200ac6:	7202                	ld	tp,32(sp)
ffffffffc0200ac8:	72a2                	ld	t0,40(sp)
ffffffffc0200aca:	7342                	ld	t1,48(sp)
ffffffffc0200acc:	73e2                	ld	t2,56(sp)
ffffffffc0200ace:	6406                	ld	s0,64(sp)
ffffffffc0200ad0:	64a6                	ld	s1,72(sp)
ffffffffc0200ad2:	6546                	ld	a0,80(sp)
ffffffffc0200ad4:	65e6                	ld	a1,88(sp)
ffffffffc0200ad6:	7606                	ld	a2,96(sp)
ffffffffc0200ad8:	76a6                	ld	a3,104(sp)
ffffffffc0200ada:	7746                	ld	a4,112(sp)
ffffffffc0200adc:	77e6                	ld	a5,120(sp)
ffffffffc0200ade:	680a                	ld	a6,128(sp)
ffffffffc0200ae0:	68aa                	ld	a7,136(sp)
ffffffffc0200ae2:	694a                	ld	s2,144(sp)
ffffffffc0200ae4:	69ea                	ld	s3,152(sp)
ffffffffc0200ae6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ae8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aea:	7b4a                	ld	s6,176(sp)
ffffffffc0200aec:	7bea                	ld	s7,184(sp)
ffffffffc0200aee:	6c0e                	ld	s8,192(sp)
ffffffffc0200af0:	6cae                	ld	s9,200(sp)
ffffffffc0200af2:	6d4e                	ld	s10,208(sp)
ffffffffc0200af4:	6dee                	ld	s11,216(sp)
ffffffffc0200af6:	7e0e                	ld	t3,224(sp)
ffffffffc0200af8:	7eae                	ld	t4,232(sp)
ffffffffc0200afa:	7f4e                	ld	t5,240(sp)
ffffffffc0200afc:	7fee                	ld	t6,248(sp)
ffffffffc0200afe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b00:	10200073          	sret
	...

ffffffffc0200b10 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b10:	00010797          	auipc	a5,0x10
ffffffffc0200b14:	53078793          	addi	a5,a5,1328 # ffffffffc0211040 <free_area>
ffffffffc0200b18:	e79c                	sd	a5,8(a5)
ffffffffc0200b1a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b1c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b20:	8082                	ret

ffffffffc0200b22 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b22:	00010517          	auipc	a0,0x10
ffffffffc0200b26:	52e56503          	lwu	a0,1326(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200b2a:	8082                	ret

ffffffffc0200b2c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b2c:	715d                	addi	sp,sp,-80
ffffffffc0200b2e:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b30:	00010417          	auipc	s0,0x10
ffffffffc0200b34:	51040413          	addi	s0,s0,1296 # ffffffffc0211040 <free_area>
ffffffffc0200b38:	641c                	ld	a5,8(s0)
ffffffffc0200b3a:	e486                	sd	ra,72(sp)
ffffffffc0200b3c:	fc26                	sd	s1,56(sp)
ffffffffc0200b3e:	f84a                	sd	s2,48(sp)
ffffffffc0200b40:	f44e                	sd	s3,40(sp)
ffffffffc0200b42:	f052                	sd	s4,32(sp)
ffffffffc0200b44:	ec56                	sd	s5,24(sp)
ffffffffc0200b46:	e85a                	sd	s6,16(sp)
ffffffffc0200b48:	e45e                	sd	s7,8(sp)
ffffffffc0200b4a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4c:	2c878763          	beq	a5,s0,ffffffffc0200e1a <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200b50:	4481                	li	s1,0
ffffffffc0200b52:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b54:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b58:	8b09                	andi	a4,a4,2
ffffffffc0200b5a:	2c070463          	beqz	a4,ffffffffc0200e22 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200b5e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b62:	679c                	ld	a5,8(a5)
ffffffffc0200b64:	2905                	addiw	s2,s2,1
ffffffffc0200b66:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b68:	fe8796e3          	bne	a5,s0,ffffffffc0200b54 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b6c:	89a6                	mv	s3,s1
ffffffffc0200b6e:	385000ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc0200b72:	71351863          	bne	a0,s3,ffffffffc0201282 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b76:	4505                	li	a0,1
ffffffffc0200b78:	2a9000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200b7c:	8a2a                	mv	s4,a0
ffffffffc0200b7e:	44050263          	beqz	a0,ffffffffc0200fc2 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b82:	4505                	li	a0,1
ffffffffc0200b84:	29d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200b88:	89aa                	mv	s3,a0
ffffffffc0200b8a:	70050c63          	beqz	a0,ffffffffc02012a2 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b8e:	4505                	li	a0,1
ffffffffc0200b90:	291000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200b94:	8aaa                	mv	s5,a0
ffffffffc0200b96:	4a050663          	beqz	a0,ffffffffc0201042 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b9a:	2b3a0463          	beq	s4,s3,ffffffffc0200e42 <default_check+0x316>
ffffffffc0200b9e:	2aaa0263          	beq	s4,a0,ffffffffc0200e42 <default_check+0x316>
ffffffffc0200ba2:	2aa98063          	beq	s3,a0,ffffffffc0200e42 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ba6:	000a2783          	lw	a5,0(s4)
ffffffffc0200baa:	2a079c63          	bnez	a5,ffffffffc0200e62 <default_check+0x336>
ffffffffc0200bae:	0009a783          	lw	a5,0(s3)
ffffffffc0200bb2:	2a079863          	bnez	a5,ffffffffc0200e62 <default_check+0x336>
ffffffffc0200bb6:	411c                	lw	a5,0(a0)
ffffffffc0200bb8:	2a079563          	bnez	a5,ffffffffc0200e62 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bbc:	00011797          	auipc	a5,0x11
ffffffffc0200bc0:	9747b783          	ld	a5,-1676(a5) # ffffffffc0211530 <pages>
ffffffffc0200bc4:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bc8:	870d                	srai	a4,a4,0x3
ffffffffc0200bca:	00006597          	auipc	a1,0x6
ffffffffc0200bce:	8de5b583          	ld	a1,-1826(a1) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0200bd2:	02b70733          	mul	a4,a4,a1
ffffffffc0200bd6:	00006617          	auipc	a2,0x6
ffffffffc0200bda:	8da63603          	ld	a2,-1830(a2) # ffffffffc02064b0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bde:	00011697          	auipc	a3,0x11
ffffffffc0200be2:	94a6b683          	ld	a3,-1718(a3) # ffffffffc0211528 <npage>
ffffffffc0200be6:	06b2                	slli	a3,a3,0xc
ffffffffc0200be8:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bea:	0732                	slli	a4,a4,0xc
ffffffffc0200bec:	28d77b63          	bgeu	a4,a3,ffffffffc0200e82 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bf0:	40f98733          	sub	a4,s3,a5
ffffffffc0200bf4:	870d                	srai	a4,a4,0x3
ffffffffc0200bf6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bfa:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bfc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bfe:	4cd77263          	bgeu	a4,a3,ffffffffc02010c2 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c02:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c06:	878d                	srai	a5,a5,0x3
ffffffffc0200c08:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c0c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c0e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c10:	30d7f963          	bgeu	a5,a3,ffffffffc0200f22 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200c14:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c16:	00043c03          	ld	s8,0(s0)
ffffffffc0200c1a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c1e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c22:	e400                	sd	s0,8(s0)
ffffffffc0200c24:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200c26:	00010797          	auipc	a5,0x10
ffffffffc0200c2a:	4207a523          	sw	zero,1066(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c2e:	1f3000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c32:	2c051863          	bnez	a0,ffffffffc0200f02 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200c36:	4585                	li	a1,1
ffffffffc0200c38:	8552                	mv	a0,s4
ffffffffc0200c3a:	279000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p1);
ffffffffc0200c3e:	4585                	li	a1,1
ffffffffc0200c40:	854e                	mv	a0,s3
ffffffffc0200c42:	271000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p2);
ffffffffc0200c46:	4585                	li	a1,1
ffffffffc0200c48:	8556                	mv	a0,s5
ffffffffc0200c4a:	269000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c4e:	4818                	lw	a4,16(s0)
ffffffffc0200c50:	478d                	li	a5,3
ffffffffc0200c52:	28f71863          	bne	a4,a5,ffffffffc0200ee2 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c56:	4505                	li	a0,1
ffffffffc0200c58:	1c9000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c5c:	89aa                	mv	s3,a0
ffffffffc0200c5e:	26050263          	beqz	a0,ffffffffc0200ec2 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c62:	4505                	li	a0,1
ffffffffc0200c64:	1bd000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c68:	8aaa                	mv	s5,a0
ffffffffc0200c6a:	3a050c63          	beqz	a0,ffffffffc0201022 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c6e:	4505                	li	a0,1
ffffffffc0200c70:	1b1000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c74:	8a2a                	mv	s4,a0
ffffffffc0200c76:	38050663          	beqz	a0,ffffffffc0201002 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c7a:	4505                	li	a0,1
ffffffffc0200c7c:	1a5000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c80:	36051163          	bnez	a0,ffffffffc0200fe2 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c84:	4585                	li	a1,1
ffffffffc0200c86:	854e                	mv	a0,s3
ffffffffc0200c88:	22b000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c8c:	641c                	ld	a5,8(s0)
ffffffffc0200c8e:	20878a63          	beq	a5,s0,ffffffffc0200ea2 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c92:	4505                	li	a0,1
ffffffffc0200c94:	18d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c98:	30a99563          	bne	s3,a0,ffffffffc0200fa2 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c9c:	4505                	li	a0,1
ffffffffc0200c9e:	183000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200ca2:	2e051063          	bnez	a0,ffffffffc0200f82 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200ca6:	481c                	lw	a5,16(s0)
ffffffffc0200ca8:	2a079d63          	bnez	a5,ffffffffc0200f62 <default_check+0x436>
    free_page(p);
ffffffffc0200cac:	854e                	mv	a0,s3
ffffffffc0200cae:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cb0:	01843023          	sd	s8,0(s0)
ffffffffc0200cb4:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200cb8:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200cbc:	1f7000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p1);
ffffffffc0200cc0:	4585                	li	a1,1
ffffffffc0200cc2:	8556                	mv	a0,s5
ffffffffc0200cc4:	1ef000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p2);
ffffffffc0200cc8:	4585                	li	a1,1
ffffffffc0200cca:	8552                	mv	a0,s4
ffffffffc0200ccc:	1e7000ef          	jal	ra,ffffffffc02016b2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cd0:	4515                	li	a0,5
ffffffffc0200cd2:	14f000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200cd6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cd8:	26050563          	beqz	a0,ffffffffc0200f42 <default_check+0x416>
ffffffffc0200cdc:	651c                	ld	a5,8(a0)
ffffffffc0200cde:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ce0:	8b85                	andi	a5,a5,1
ffffffffc0200ce2:	54079063          	bnez	a5,ffffffffc0201222 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ce6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ce8:	00043b03          	ld	s6,0(s0)
ffffffffc0200cec:	00843a83          	ld	s5,8(s0)
ffffffffc0200cf0:	e000                	sd	s0,0(s0)
ffffffffc0200cf2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cf4:	12d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200cf8:	50051563          	bnez	a0,ffffffffc0201202 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cfc:	09098a13          	addi	s4,s3,144
ffffffffc0200d00:	8552                	mv	a0,s4
ffffffffc0200d02:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d04:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200d08:	00010797          	auipc	a5,0x10
ffffffffc0200d0c:	3407a423          	sw	zero,840(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d10:	1a3000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d14:	4511                	li	a0,4
ffffffffc0200d16:	10b000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d1a:	4c051463          	bnez	a0,ffffffffc02011e2 <default_check+0x6b6>
ffffffffc0200d1e:	0989b783          	ld	a5,152(s3)
ffffffffc0200d22:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d24:	8b85                	andi	a5,a5,1
ffffffffc0200d26:	48078e63          	beqz	a5,ffffffffc02011c2 <default_check+0x696>
ffffffffc0200d2a:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d2e:	478d                	li	a5,3
ffffffffc0200d30:	48f71963          	bne	a4,a5,ffffffffc02011c2 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d34:	450d                	li	a0,3
ffffffffc0200d36:	0eb000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d3a:	8c2a                	mv	s8,a0
ffffffffc0200d3c:	46050363          	beqz	a0,ffffffffc02011a2 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200d40:	4505                	li	a0,1
ffffffffc0200d42:	0df000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d46:	42051e63          	bnez	a0,ffffffffc0201182 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200d4a:	418a1c63          	bne	s4,s8,ffffffffc0201162 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d4e:	4585                	li	a1,1
ffffffffc0200d50:	854e                	mv	a0,s3
ffffffffc0200d52:	161000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d56:	458d                	li	a1,3
ffffffffc0200d58:	8552                	mv	a0,s4
ffffffffc0200d5a:	159000ef          	jal	ra,ffffffffc02016b2 <free_pages>
ffffffffc0200d5e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d62:	04898c13          	addi	s8,s3,72
ffffffffc0200d66:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d68:	8b85                	andi	a5,a5,1
ffffffffc0200d6a:	3c078c63          	beqz	a5,ffffffffc0201142 <default_check+0x616>
ffffffffc0200d6e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d72:	4785                	li	a5,1
ffffffffc0200d74:	3cf71763          	bne	a4,a5,ffffffffc0201142 <default_check+0x616>
ffffffffc0200d78:	008a3783          	ld	a5,8(s4)
ffffffffc0200d7c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d7e:	8b85                	andi	a5,a5,1
ffffffffc0200d80:	3a078163          	beqz	a5,ffffffffc0201122 <default_check+0x5f6>
ffffffffc0200d84:	018a2703          	lw	a4,24(s4)
ffffffffc0200d88:	478d                	li	a5,3
ffffffffc0200d8a:	38f71c63          	bne	a4,a5,ffffffffc0201122 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d8e:	4505                	li	a0,1
ffffffffc0200d90:	091000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d94:	36a99763          	bne	s3,a0,ffffffffc0201102 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d98:	4585                	li	a1,1
ffffffffc0200d9a:	119000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d9e:	4509                	li	a0,2
ffffffffc0200da0:	081000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200da4:	32aa1f63          	bne	s4,a0,ffffffffc02010e2 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200da8:	4589                	li	a1,2
ffffffffc0200daa:	109000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p2);
ffffffffc0200dae:	4585                	li	a1,1
ffffffffc0200db0:	8562                	mv	a0,s8
ffffffffc0200db2:	101000ef          	jal	ra,ffffffffc02016b2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200db6:	4515                	li	a0,5
ffffffffc0200db8:	069000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200dbc:	89aa                	mv	s3,a0
ffffffffc0200dbe:	48050263          	beqz	a0,ffffffffc0201242 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200dc2:	4505                	li	a0,1
ffffffffc0200dc4:	05d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200dc8:	2c051d63          	bnez	a0,ffffffffc02010a2 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200dcc:	481c                	lw	a5,16(s0)
ffffffffc0200dce:	2a079a63          	bnez	a5,ffffffffc0201082 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200dd2:	4595                	li	a1,5
ffffffffc0200dd4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dd6:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200dda:	01643023          	sd	s6,0(s0)
ffffffffc0200dde:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200de2:	0d1000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    return listelm->next;
ffffffffc0200de6:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200de8:	00878963          	beq	a5,s0,ffffffffc0200dfa <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dec:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200df0:	679c                	ld	a5,8(a5)
ffffffffc0200df2:	397d                	addiw	s2,s2,-1
ffffffffc0200df4:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200df6:	fe879be3          	bne	a5,s0,ffffffffc0200dec <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200dfa:	26091463          	bnez	s2,ffffffffc0201062 <default_check+0x536>
    assert(total == 0);
ffffffffc0200dfe:	46049263          	bnez	s1,ffffffffc0201262 <default_check+0x736>
}
ffffffffc0200e02:	60a6                	ld	ra,72(sp)
ffffffffc0200e04:	6406                	ld	s0,64(sp)
ffffffffc0200e06:	74e2                	ld	s1,56(sp)
ffffffffc0200e08:	7942                	ld	s2,48(sp)
ffffffffc0200e0a:	79a2                	ld	s3,40(sp)
ffffffffc0200e0c:	7a02                	ld	s4,32(sp)
ffffffffc0200e0e:	6ae2                	ld	s5,24(sp)
ffffffffc0200e10:	6b42                	ld	s6,16(sp)
ffffffffc0200e12:	6ba2                	ld	s7,8(sp)
ffffffffc0200e14:	6c02                	ld	s8,0(sp)
ffffffffc0200e16:	6161                	addi	sp,sp,80
ffffffffc0200e18:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e1a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e1c:	4481                	li	s1,0
ffffffffc0200e1e:	4901                	li	s2,0
ffffffffc0200e20:	b3b9                	j	ffffffffc0200b6e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e22:	00004697          	auipc	a3,0x4
ffffffffc0200e26:	0ee68693          	addi	a3,a3,238 # ffffffffc0204f10 <commands+0x788>
ffffffffc0200e2a:	00004617          	auipc	a2,0x4
ffffffffc0200e2e:	0f660613          	addi	a2,a2,246 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200e32:	0f000593          	li	a1,240
ffffffffc0200e36:	00004517          	auipc	a0,0x4
ffffffffc0200e3a:	10250513          	addi	a0,a0,258 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200e3e:	d3aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e42:	00004697          	auipc	a3,0x4
ffffffffc0200e46:	18e68693          	addi	a3,a3,398 # ffffffffc0204fd0 <commands+0x848>
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	0d660613          	addi	a2,a2,214 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200e52:	0bd00593          	li	a1,189
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	0e250513          	addi	a0,a0,226 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200e5e:	d1aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e62:	00004697          	auipc	a3,0x4
ffffffffc0200e66:	19668693          	addi	a3,a3,406 # ffffffffc0204ff8 <commands+0x870>
ffffffffc0200e6a:	00004617          	auipc	a2,0x4
ffffffffc0200e6e:	0b660613          	addi	a2,a2,182 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200e72:	0be00593          	li	a1,190
ffffffffc0200e76:	00004517          	auipc	a0,0x4
ffffffffc0200e7a:	0c250513          	addi	a0,a0,194 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200e7e:	cfaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	1b668693          	addi	a3,a3,438 # ffffffffc0205038 <commands+0x8b0>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	09660613          	addi	a2,a2,150 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200e92:	0c000593          	li	a1,192
ffffffffc0200e96:	00004517          	auipc	a0,0x4
ffffffffc0200e9a:	0a250513          	addi	a0,a0,162 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200e9e:	cdaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ea2:	00004697          	auipc	a3,0x4
ffffffffc0200ea6:	21e68693          	addi	a3,a3,542 # ffffffffc02050c0 <commands+0x938>
ffffffffc0200eaa:	00004617          	auipc	a2,0x4
ffffffffc0200eae:	07660613          	addi	a2,a2,118 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200eb2:	0d900593          	li	a1,217
ffffffffc0200eb6:	00004517          	auipc	a0,0x4
ffffffffc0200eba:	08250513          	addi	a0,a0,130 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200ebe:	cbaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	0ae68693          	addi	a3,a3,174 # ffffffffc0204f70 <commands+0x7e8>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	05660613          	addi	a2,a2,86 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200ed2:	0d200593          	li	a1,210
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	06250513          	addi	a0,a0,98 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200ede:	c9aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free == 3);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	1ce68693          	addi	a3,a3,462 # ffffffffc02050b0 <commands+0x928>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	03660613          	addi	a2,a2,54 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200ef2:	0d000593          	li	a1,208
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	04250513          	addi	a0,a0,66 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200efe:	c7aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	19668693          	addi	a3,a3,406 # ffffffffc0205098 <commands+0x910>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	01660613          	addi	a2,a2,22 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200f12:	0cb00593          	li	a1,203
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	02250513          	addi	a0,a0,34 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200f1e:	c5aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f22:	00004697          	auipc	a3,0x4
ffffffffc0200f26:	15668693          	addi	a3,a3,342 # ffffffffc0205078 <commands+0x8f0>
ffffffffc0200f2a:	00004617          	auipc	a2,0x4
ffffffffc0200f2e:	ff660613          	addi	a2,a2,-10 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200f32:	0c200593          	li	a1,194
ffffffffc0200f36:	00004517          	auipc	a0,0x4
ffffffffc0200f3a:	00250513          	addi	a0,a0,2 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200f3e:	c3aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(p0 != NULL);
ffffffffc0200f42:	00004697          	auipc	a3,0x4
ffffffffc0200f46:	1c668693          	addi	a3,a3,454 # ffffffffc0205108 <commands+0x980>
ffffffffc0200f4a:	00004617          	auipc	a2,0x4
ffffffffc0200f4e:	fd660613          	addi	a2,a2,-42 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200f52:	0f800593          	li	a1,248
ffffffffc0200f56:	00004517          	auipc	a0,0x4
ffffffffc0200f5a:	fe250513          	addi	a0,a0,-30 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200f5e:	c1aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free == 0);
ffffffffc0200f62:	00004697          	auipc	a3,0x4
ffffffffc0200f66:	19668693          	addi	a3,a3,406 # ffffffffc02050f8 <commands+0x970>
ffffffffc0200f6a:	00004617          	auipc	a2,0x4
ffffffffc0200f6e:	fb660613          	addi	a2,a2,-74 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200f72:	0df00593          	li	a1,223
ffffffffc0200f76:	00004517          	auipc	a0,0x4
ffffffffc0200f7a:	fc250513          	addi	a0,a0,-62 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200f7e:	bfaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	00004697          	auipc	a3,0x4
ffffffffc0200f86:	11668693          	addi	a3,a3,278 # ffffffffc0205098 <commands+0x910>
ffffffffc0200f8a:	00004617          	auipc	a2,0x4
ffffffffc0200f8e:	f9660613          	addi	a2,a2,-106 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200f92:	0dd00593          	li	a1,221
ffffffffc0200f96:	00004517          	auipc	a0,0x4
ffffffffc0200f9a:	fa250513          	addi	a0,a0,-94 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200f9e:	bdaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fa2:	00004697          	auipc	a3,0x4
ffffffffc0200fa6:	13668693          	addi	a3,a3,310 # ffffffffc02050d8 <commands+0x950>
ffffffffc0200faa:	00004617          	auipc	a2,0x4
ffffffffc0200fae:	f7660613          	addi	a2,a2,-138 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200fb2:	0dc00593          	li	a1,220
ffffffffc0200fb6:	00004517          	auipc	a0,0x4
ffffffffc0200fba:	f8250513          	addi	a0,a0,-126 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200fbe:	bbaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	fae68693          	addi	a3,a3,-82 # ffffffffc0204f70 <commands+0x7e8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	f5660613          	addi	a2,a2,-170 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200fd2:	0b900593          	li	a1,185
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	f6250513          	addi	a0,a0,-158 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200fde:	b9aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	0b668693          	addi	a3,a3,182 # ffffffffc0205098 <commands+0x910>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	f3660613          	addi	a2,a2,-202 # ffffffffc0204f20 <commands+0x798>
ffffffffc0200ff2:	0d600593          	li	a1,214
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	f4250513          	addi	a0,a0,-190 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0200ffe:	b7aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201002:	00004697          	auipc	a3,0x4
ffffffffc0201006:	fae68693          	addi	a3,a3,-82 # ffffffffc0204fb0 <commands+0x828>
ffffffffc020100a:	00004617          	auipc	a2,0x4
ffffffffc020100e:	f1660613          	addi	a2,a2,-234 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201012:	0d400593          	li	a1,212
ffffffffc0201016:	00004517          	auipc	a0,0x4
ffffffffc020101a:	f2250513          	addi	a0,a0,-222 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020101e:	b5aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201022:	00004697          	auipc	a3,0x4
ffffffffc0201026:	f6e68693          	addi	a3,a3,-146 # ffffffffc0204f90 <commands+0x808>
ffffffffc020102a:	00004617          	auipc	a2,0x4
ffffffffc020102e:	ef660613          	addi	a2,a2,-266 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201032:	0d300593          	li	a1,211
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	f0250513          	addi	a0,a0,-254 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020103e:	b3aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201042:	00004697          	auipc	a3,0x4
ffffffffc0201046:	f6e68693          	addi	a3,a3,-146 # ffffffffc0204fb0 <commands+0x828>
ffffffffc020104a:	00004617          	auipc	a2,0x4
ffffffffc020104e:	ed660613          	addi	a2,a2,-298 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201052:	0bb00593          	li	a1,187
ffffffffc0201056:	00004517          	auipc	a0,0x4
ffffffffc020105a:	ee250513          	addi	a0,a0,-286 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020105e:	b1aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(count == 0);
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	1f668693          	addi	a3,a3,502 # ffffffffc0205258 <commands+0xad0>
ffffffffc020106a:	00004617          	auipc	a2,0x4
ffffffffc020106e:	eb660613          	addi	a2,a2,-330 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201072:	12500593          	li	a1,293
ffffffffc0201076:	00004517          	auipc	a0,0x4
ffffffffc020107a:	ec250513          	addi	a0,a0,-318 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020107e:	afaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free == 0);
ffffffffc0201082:	00004697          	auipc	a3,0x4
ffffffffc0201086:	07668693          	addi	a3,a3,118 # ffffffffc02050f8 <commands+0x970>
ffffffffc020108a:	00004617          	auipc	a2,0x4
ffffffffc020108e:	e9660613          	addi	a2,a2,-362 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201092:	11a00593          	li	a1,282
ffffffffc0201096:	00004517          	auipc	a0,0x4
ffffffffc020109a:	ea250513          	addi	a0,a0,-350 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020109e:	adaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010a2:	00004697          	auipc	a3,0x4
ffffffffc02010a6:	ff668693          	addi	a3,a3,-10 # ffffffffc0205098 <commands+0x910>
ffffffffc02010aa:	00004617          	auipc	a2,0x4
ffffffffc02010ae:	e7660613          	addi	a2,a2,-394 # ffffffffc0204f20 <commands+0x798>
ffffffffc02010b2:	11800593          	li	a1,280
ffffffffc02010b6:	00004517          	auipc	a0,0x4
ffffffffc02010ba:	e8250513          	addi	a0,a0,-382 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02010be:	abaff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	f9668693          	addi	a3,a3,-106 # ffffffffc0205058 <commands+0x8d0>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	e5660613          	addi	a2,a2,-426 # ffffffffc0204f20 <commands+0x798>
ffffffffc02010d2:	0c100593          	li	a1,193
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	e6250513          	addi	a0,a0,-414 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02010de:	a9aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	13668693          	addi	a3,a3,310 # ffffffffc0205218 <commands+0xa90>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	e3660613          	addi	a2,a2,-458 # ffffffffc0204f20 <commands+0x798>
ffffffffc02010f2:	11200593          	li	a1,274
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	e4250513          	addi	a0,a0,-446 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02010fe:	a7aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	0f668693          	addi	a3,a3,246 # ffffffffc02051f8 <commands+0xa70>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	e1660613          	addi	a2,a2,-490 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201112:	11000593          	li	a1,272
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	e2250513          	addi	a0,a0,-478 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020111e:	a5aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	0ae68693          	addi	a3,a3,174 # ffffffffc02051d0 <commands+0xa48>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	df660613          	addi	a2,a2,-522 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201132:	10e00593          	li	a1,270
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	e0250513          	addi	a0,a0,-510 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020113e:	a3aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	06668693          	addi	a3,a3,102 # ffffffffc02051a8 <commands+0xa20>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	dd660613          	addi	a2,a2,-554 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201152:	10d00593          	li	a1,269
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	de250513          	addi	a0,a0,-542 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020115e:	a1aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	03668693          	addi	a3,a3,54 # ffffffffc0205198 <commands+0xa10>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	db660613          	addi	a2,a2,-586 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201172:	10800593          	li	a1,264
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	dc250513          	addi	a0,a0,-574 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020117e:	9faff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	f1668693          	addi	a3,a3,-234 # ffffffffc0205098 <commands+0x910>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	d9660613          	addi	a2,a2,-618 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201192:	10700593          	li	a1,263
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	da250513          	addi	a0,a0,-606 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020119e:	9daff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	fd668693          	addi	a3,a3,-42 # ffffffffc0205178 <commands+0x9f0>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	d7660613          	addi	a2,a2,-650 # ffffffffc0204f20 <commands+0x798>
ffffffffc02011b2:	10600593          	li	a1,262
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	d8250513          	addi	a0,a0,-638 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02011be:	9baff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	f8668693          	addi	a3,a3,-122 # ffffffffc0205148 <commands+0x9c0>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	d5660613          	addi	a2,a2,-682 # ffffffffc0204f20 <commands+0x798>
ffffffffc02011d2:	10500593          	li	a1,261
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	d6250513          	addi	a0,a0,-670 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02011de:	99aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0205130 <commands+0x9a8>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	d3660613          	addi	a2,a2,-714 # ffffffffc0204f20 <commands+0x798>
ffffffffc02011f2:	10400593          	li	a1,260
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	d4250513          	addi	a0,a0,-702 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02011fe:	97aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	e9668693          	addi	a3,a3,-362 # ffffffffc0205098 <commands+0x910>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	d1660613          	addi	a2,a2,-746 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201212:	0fe00593          	li	a1,254
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	d2250513          	addi	a0,a0,-734 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020121e:	95aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201222:	00004697          	auipc	a3,0x4
ffffffffc0201226:	ef668693          	addi	a3,a3,-266 # ffffffffc0205118 <commands+0x990>
ffffffffc020122a:	00004617          	auipc	a2,0x4
ffffffffc020122e:	cf660613          	addi	a2,a2,-778 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201232:	0f900593          	li	a1,249
ffffffffc0201236:	00004517          	auipc	a0,0x4
ffffffffc020123a:	d0250513          	addi	a0,a0,-766 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020123e:	93aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	ff668693          	addi	a3,a3,-10 # ffffffffc0205238 <commands+0xab0>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	cd660613          	addi	a2,a2,-810 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201252:	11700593          	li	a1,279
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	ce250513          	addi	a0,a0,-798 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020125e:	91aff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(total == 0);
ffffffffc0201262:	00004697          	auipc	a3,0x4
ffffffffc0201266:	00668693          	addi	a3,a3,6 # ffffffffc0205268 <commands+0xae0>
ffffffffc020126a:	00004617          	auipc	a2,0x4
ffffffffc020126e:	cb660613          	addi	a2,a2,-842 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201272:	12600593          	li	a1,294
ffffffffc0201276:	00004517          	auipc	a0,0x4
ffffffffc020127a:	cc250513          	addi	a0,a0,-830 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020127e:	8faff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201282:	00004697          	auipc	a3,0x4
ffffffffc0201286:	cce68693          	addi	a3,a3,-818 # ffffffffc0204f50 <commands+0x7c8>
ffffffffc020128a:	00004617          	auipc	a2,0x4
ffffffffc020128e:	c9660613          	addi	a2,a2,-874 # ffffffffc0204f20 <commands+0x798>
ffffffffc0201292:	0f300593          	li	a1,243
ffffffffc0201296:	00004517          	auipc	a0,0x4
ffffffffc020129a:	ca250513          	addi	a0,a0,-862 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc020129e:	8daff0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012a2:	00004697          	auipc	a3,0x4
ffffffffc02012a6:	cee68693          	addi	a3,a3,-786 # ffffffffc0204f90 <commands+0x808>
ffffffffc02012aa:	00004617          	auipc	a2,0x4
ffffffffc02012ae:	c7660613          	addi	a2,a2,-906 # ffffffffc0204f20 <commands+0x798>
ffffffffc02012b2:	0ba00593          	li	a1,186
ffffffffc02012b6:	00004517          	auipc	a0,0x4
ffffffffc02012ba:	c8250513          	addi	a0,a0,-894 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02012be:	8baff0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc02012c2 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012c2:	1141                	addi	sp,sp,-16
ffffffffc02012c4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012c6:	14058a63          	beqz	a1,ffffffffc020141a <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02012ca:	00359693          	slli	a3,a1,0x3
ffffffffc02012ce:	96ae                	add	a3,a3,a1
ffffffffc02012d0:	068e                	slli	a3,a3,0x3
ffffffffc02012d2:	96aa                	add	a3,a3,a0
ffffffffc02012d4:	87aa                	mv	a5,a0
ffffffffc02012d6:	02d50263          	beq	a0,a3,ffffffffc02012fa <default_free_pages+0x38>
ffffffffc02012da:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012dc:	8b05                	andi	a4,a4,1
ffffffffc02012de:	10071e63          	bnez	a4,ffffffffc02013fa <default_free_pages+0x138>
ffffffffc02012e2:	6798                	ld	a4,8(a5)
ffffffffc02012e4:	8b09                	andi	a4,a4,2
ffffffffc02012e6:	10071a63          	bnez	a4,ffffffffc02013fa <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02012ea:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012ee:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012f2:	04878793          	addi	a5,a5,72
ffffffffc02012f6:	fed792e3          	bne	a5,a3,ffffffffc02012da <default_free_pages+0x18>
    base->property = n;
ffffffffc02012fa:	2581                	sext.w	a1,a1
ffffffffc02012fc:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012fe:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201302:	4789                	li	a5,2
ffffffffc0201304:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201308:	00010697          	auipc	a3,0x10
ffffffffc020130c:	d3868693          	addi	a3,a3,-712 # ffffffffc0211040 <free_area>
ffffffffc0201310:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201312:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201314:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201318:	9db9                	addw	a1,a1,a4
ffffffffc020131a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020131c:	0ad78863          	beq	a5,a3,ffffffffc02013cc <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201320:	fe078713          	addi	a4,a5,-32
ffffffffc0201324:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201328:	4581                	li	a1,0
            if (base < page) {
ffffffffc020132a:	00e56a63          	bltu	a0,a4,ffffffffc020133e <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020132e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201330:	06d70263          	beq	a4,a3,ffffffffc0201394 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201334:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201336:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020133a:	fee57ae3          	bgeu	a0,a4,ffffffffc020132e <default_free_pages+0x6c>
ffffffffc020133e:	c199                	beqz	a1,ffffffffc0201344 <default_free_pages+0x82>
ffffffffc0201340:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201344:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201346:	e390                	sd	a2,0(a5)
ffffffffc0201348:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020134a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020134c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020134e:	02d70063          	beq	a4,a3,ffffffffc020136e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201352:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201356:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc020135a:	02081613          	slli	a2,a6,0x20
ffffffffc020135e:	9201                	srli	a2,a2,0x20
ffffffffc0201360:	00361793          	slli	a5,a2,0x3
ffffffffc0201364:	97b2                	add	a5,a5,a2
ffffffffc0201366:	078e                	slli	a5,a5,0x3
ffffffffc0201368:	97ae                	add	a5,a5,a1
ffffffffc020136a:	02f50f63          	beq	a0,a5,ffffffffc02013a8 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020136e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201370:	00d70f63          	beq	a4,a3,ffffffffc020138e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201374:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201376:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020137a:	02059613          	slli	a2,a1,0x20
ffffffffc020137e:	9201                	srli	a2,a2,0x20
ffffffffc0201380:	00361793          	slli	a5,a2,0x3
ffffffffc0201384:	97b2                	add	a5,a5,a2
ffffffffc0201386:	078e                	slli	a5,a5,0x3
ffffffffc0201388:	97aa                	add	a5,a5,a0
ffffffffc020138a:	04f68863          	beq	a3,a5,ffffffffc02013da <default_free_pages+0x118>
}
ffffffffc020138e:	60a2                	ld	ra,8(sp)
ffffffffc0201390:	0141                	addi	sp,sp,16
ffffffffc0201392:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201394:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201396:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201398:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020139a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020139c:	02d70563          	beq	a4,a3,ffffffffc02013c6 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02013a0:	8832                	mv	a6,a2
ffffffffc02013a2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02013a4:	87ba                	mv	a5,a4
ffffffffc02013a6:	bf41                	j	ffffffffc0201336 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02013a8:	4d1c                	lw	a5,24(a0)
ffffffffc02013aa:	0107883b          	addw	a6,a5,a6
ffffffffc02013ae:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013b2:	57f5                	li	a5,-3
ffffffffc02013b4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013b8:	7110                	ld	a2,32(a0)
ffffffffc02013ba:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc02013bc:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013be:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02013c0:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02013c2:	e390                	sd	a2,0(a5)
ffffffffc02013c4:	b775                	j	ffffffffc0201370 <default_free_pages+0xae>
ffffffffc02013c6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013c8:	873e                	mv	a4,a5
ffffffffc02013ca:	b761                	j	ffffffffc0201352 <default_free_pages+0x90>
}
ffffffffc02013cc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013ce:	e390                	sd	a2,0(a5)
ffffffffc02013d0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013d2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013d4:	f11c                	sd	a5,32(a0)
ffffffffc02013d6:	0141                	addi	sp,sp,16
ffffffffc02013d8:	8082                	ret
            base->property += p->property;
ffffffffc02013da:	ff872783          	lw	a5,-8(a4)
ffffffffc02013de:	fe870693          	addi	a3,a4,-24
ffffffffc02013e2:	9dbd                	addw	a1,a1,a5
ffffffffc02013e4:	cd0c                	sw	a1,24(a0)
ffffffffc02013e6:	57f5                	li	a5,-3
ffffffffc02013e8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013ec:	6314                	ld	a3,0(a4)
ffffffffc02013ee:	671c                	ld	a5,8(a4)
}
ffffffffc02013f0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013f2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013f4:	e394                	sd	a3,0(a5)
ffffffffc02013f6:	0141                	addi	sp,sp,16
ffffffffc02013f8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013fa:	00004697          	auipc	a3,0x4
ffffffffc02013fe:	e8668693          	addi	a3,a3,-378 # ffffffffc0205280 <commands+0xaf8>
ffffffffc0201402:	00004617          	auipc	a2,0x4
ffffffffc0201406:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0204f20 <commands+0x798>
ffffffffc020140a:	08300593          	li	a1,131
ffffffffc020140e:	00004517          	auipc	a0,0x4
ffffffffc0201412:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0201416:	f63fe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(n > 0);
ffffffffc020141a:	00004697          	auipc	a3,0x4
ffffffffc020141e:	e5e68693          	addi	a3,a3,-418 # ffffffffc0205278 <commands+0xaf0>
ffffffffc0201422:	00004617          	auipc	a2,0x4
ffffffffc0201426:	afe60613          	addi	a2,a2,-1282 # ffffffffc0204f20 <commands+0x798>
ffffffffc020142a:	08000593          	li	a1,128
ffffffffc020142e:	00004517          	auipc	a0,0x4
ffffffffc0201432:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc0201436:	f43fe0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc020143a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020143a:	c959                	beqz	a0,ffffffffc02014d0 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020143c:	00010597          	auipc	a1,0x10
ffffffffc0201440:	c0458593          	addi	a1,a1,-1020 # ffffffffc0211040 <free_area>
ffffffffc0201444:	0105a803          	lw	a6,16(a1)
ffffffffc0201448:	862a                	mv	a2,a0
ffffffffc020144a:	02081793          	slli	a5,a6,0x20
ffffffffc020144e:	9381                	srli	a5,a5,0x20
ffffffffc0201450:	00a7ee63          	bltu	a5,a0,ffffffffc020146c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201454:	87ae                	mv	a5,a1
ffffffffc0201456:	a801                	j	ffffffffc0201466 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201458:	ff87a703          	lw	a4,-8(a5)
ffffffffc020145c:	02071693          	slli	a3,a4,0x20
ffffffffc0201460:	9281                	srli	a3,a3,0x20
ffffffffc0201462:	00c6f763          	bgeu	a3,a2,ffffffffc0201470 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201466:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201468:	feb798e3          	bne	a5,a1,ffffffffc0201458 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020146c:	4501                	li	a0,0
}
ffffffffc020146e:	8082                	ret
    return listelm->prev;
ffffffffc0201470:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201474:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201478:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020147c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201480:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201484:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201488:	02d67b63          	bgeu	a2,a3,ffffffffc02014be <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020148c:	00361693          	slli	a3,a2,0x3
ffffffffc0201490:	96b2                	add	a3,a3,a2
ffffffffc0201492:	068e                	slli	a3,a3,0x3
ffffffffc0201494:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201496:	41c7073b          	subw	a4,a4,t3
ffffffffc020149a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020149c:	00868613          	addi	a2,a3,8
ffffffffc02014a0:	4709                	li	a4,2
ffffffffc02014a2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014a6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014aa:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02014ae:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02014b2:	e310                	sd	a2,0(a4)
ffffffffc02014b4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02014b8:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02014ba:	0316b023          	sd	a7,32(a3)
ffffffffc02014be:	41c8083b          	subw	a6,a6,t3
ffffffffc02014c2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014c6:	5775                	li	a4,-3
ffffffffc02014c8:	17a1                	addi	a5,a5,-24
ffffffffc02014ca:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02014ce:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014d0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014d2:	00004697          	auipc	a3,0x4
ffffffffc02014d6:	da668693          	addi	a3,a3,-602 # ffffffffc0205278 <commands+0xaf0>
ffffffffc02014da:	00004617          	auipc	a2,0x4
ffffffffc02014de:	a4660613          	addi	a2,a2,-1466 # ffffffffc0204f20 <commands+0x798>
ffffffffc02014e2:	06200593          	li	a1,98
ffffffffc02014e6:	00004517          	auipc	a0,0x4
ffffffffc02014ea:	a5250513          	addi	a0,a0,-1454 # ffffffffc0204f38 <commands+0x7b0>
default_alloc_pages(size_t n) {
ffffffffc02014ee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014f0:	e89fe0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc02014f4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014f4:	1141                	addi	sp,sp,-16
ffffffffc02014f6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014f8:	c9e1                	beqz	a1,ffffffffc02015c8 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02014fa:	00359693          	slli	a3,a1,0x3
ffffffffc02014fe:	96ae                	add	a3,a3,a1
ffffffffc0201500:	068e                	slli	a3,a3,0x3
ffffffffc0201502:	96aa                	add	a3,a3,a0
ffffffffc0201504:	87aa                	mv	a5,a0
ffffffffc0201506:	00d50f63          	beq	a0,a3,ffffffffc0201524 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020150a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020150c:	8b05                	andi	a4,a4,1
ffffffffc020150e:	cf49                	beqz	a4,ffffffffc02015a8 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201510:	0007ac23          	sw	zero,24(a5)
ffffffffc0201514:	0007b423          	sd	zero,8(a5)
ffffffffc0201518:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020151c:	04878793          	addi	a5,a5,72
ffffffffc0201520:	fed795e3          	bne	a5,a3,ffffffffc020150a <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201524:	2581                	sext.w	a1,a1
ffffffffc0201526:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201528:	4789                	li	a5,2
ffffffffc020152a:	00850713          	addi	a4,a0,8
ffffffffc020152e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201532:	00010697          	auipc	a3,0x10
ffffffffc0201536:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0211040 <free_area>
ffffffffc020153a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020153c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020153e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201542:	9db9                	addw	a1,a1,a4
ffffffffc0201544:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201546:	04d78a63          	beq	a5,a3,ffffffffc020159a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020154a:	fe078713          	addi	a4,a5,-32
ffffffffc020154e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201552:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201554:	00e56a63          	bltu	a0,a4,ffffffffc0201568 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201558:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020155a:	02d70263          	beq	a4,a3,ffffffffc020157e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020155e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201560:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201564:	fee57ae3          	bgeu	a0,a4,ffffffffc0201558 <default_init_memmap+0x64>
ffffffffc0201568:	c199                	beqz	a1,ffffffffc020156e <default_init_memmap+0x7a>
ffffffffc020156a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020156e:	6398                	ld	a4,0(a5)
}
ffffffffc0201570:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201572:	e390                	sd	a2,0(a5)
ffffffffc0201574:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201576:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201578:	f118                	sd	a4,32(a0)
ffffffffc020157a:	0141                	addi	sp,sp,16
ffffffffc020157c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020157e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201580:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201582:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201584:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201586:	00d70663          	beq	a4,a3,ffffffffc0201592 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020158a:	8832                	mv	a6,a2
ffffffffc020158c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020158e:	87ba                	mv	a5,a4
ffffffffc0201590:	bfc1                	j	ffffffffc0201560 <default_init_memmap+0x6c>
}
ffffffffc0201592:	60a2                	ld	ra,8(sp)
ffffffffc0201594:	e290                	sd	a2,0(a3)
ffffffffc0201596:	0141                	addi	sp,sp,16
ffffffffc0201598:	8082                	ret
ffffffffc020159a:	60a2                	ld	ra,8(sp)
ffffffffc020159c:	e390                	sd	a2,0(a5)
ffffffffc020159e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015a0:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015a2:	f11c                	sd	a5,32(a0)
ffffffffc02015a4:	0141                	addi	sp,sp,16
ffffffffc02015a6:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015a8:	00004697          	auipc	a3,0x4
ffffffffc02015ac:	d0068693          	addi	a3,a3,-768 # ffffffffc02052a8 <commands+0xb20>
ffffffffc02015b0:	00004617          	auipc	a2,0x4
ffffffffc02015b4:	97060613          	addi	a2,a2,-1680 # ffffffffc0204f20 <commands+0x798>
ffffffffc02015b8:	04900593          	li	a1,73
ffffffffc02015bc:	00004517          	auipc	a0,0x4
ffffffffc02015c0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02015c4:	db5fe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(n > 0);
ffffffffc02015c8:	00004697          	auipc	a3,0x4
ffffffffc02015cc:	cb068693          	addi	a3,a3,-848 # ffffffffc0205278 <commands+0xaf0>
ffffffffc02015d0:	00004617          	auipc	a2,0x4
ffffffffc02015d4:	95060613          	addi	a2,a2,-1712 # ffffffffc0204f20 <commands+0x798>
ffffffffc02015d8:	04600593          	li	a1,70
ffffffffc02015dc:	00004517          	auipc	a0,0x4
ffffffffc02015e0:	95c50513          	addi	a0,a0,-1700 # ffffffffc0204f38 <commands+0x7b0>
ffffffffc02015e4:	d95fe0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc02015e8 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015e8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015ea:	00004617          	auipc	a2,0x4
ffffffffc02015ee:	d1e60613          	addi	a2,a2,-738 # ffffffffc0205308 <default_pmm_manager+0x38>
ffffffffc02015f2:	06500593          	li	a1,101
ffffffffc02015f6:	00004517          	auipc	a0,0x4
ffffffffc02015fa:	d3250513          	addi	a0,a0,-718 # ffffffffc0205328 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015fe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201600:	d79fe0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0201604 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0201604:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201606:	00004617          	auipc	a2,0x4
ffffffffc020160a:	d3260613          	addi	a2,a2,-718 # ffffffffc0205338 <default_pmm_manager+0x68>
ffffffffc020160e:	07000593          	li	a1,112
ffffffffc0201612:	00004517          	auipc	a0,0x4
ffffffffc0201616:	d1650513          	addi	a0,a0,-746 # ffffffffc0205328 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc020161a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc020161c:	d5dfe0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0201620 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201620:	7139                	addi	sp,sp,-64
ffffffffc0201622:	f426                	sd	s1,40(sp)
ffffffffc0201624:	f04a                	sd	s2,32(sp)
ffffffffc0201626:	ec4e                	sd	s3,24(sp)
ffffffffc0201628:	e852                	sd	s4,16(sp)
ffffffffc020162a:	e456                	sd	s5,8(sp)
ffffffffc020162c:	e05a                	sd	s6,0(sp)
ffffffffc020162e:	fc06                	sd	ra,56(sp)
ffffffffc0201630:	f822                	sd	s0,48(sp)
ffffffffc0201632:	84aa                	mv	s1,a0
ffffffffc0201634:	00010917          	auipc	s2,0x10
ffffffffc0201638:	f0490913          	addi	s2,s2,-252 # ffffffffc0211538 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020163c:	4a05                	li	s4,1
ffffffffc020163e:	00010a97          	auipc	s5,0x10
ffffffffc0201642:	f1aa8a93          	addi	s5,s5,-230 # ffffffffc0211558 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201646:	0005099b          	sext.w	s3,a0
ffffffffc020164a:	00010b17          	auipc	s6,0x10
ffffffffc020164e:	f1eb0b13          	addi	s6,s6,-226 # ffffffffc0211568 <check_mm_struct>
ffffffffc0201652:	a01d                	j	ffffffffc0201678 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201654:	00093783          	ld	a5,0(s2)
ffffffffc0201658:	6f9c                	ld	a5,24(a5)
ffffffffc020165a:	9782                	jalr	a5
ffffffffc020165c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020165e:	4601                	li	a2,0
ffffffffc0201660:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201662:	ec0d                	bnez	s0,ffffffffc020169c <alloc_pages+0x7c>
ffffffffc0201664:	029a6c63          	bltu	s4,s1,ffffffffc020169c <alloc_pages+0x7c>
ffffffffc0201668:	000aa783          	lw	a5,0(s5)
ffffffffc020166c:	2781                	sext.w	a5,a5
ffffffffc020166e:	c79d                	beqz	a5,ffffffffc020169c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201670:	000b3503          	ld	a0,0(s6)
ffffffffc0201674:	189010ef          	jal	ra,ffffffffc0202ffc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201678:	100027f3          	csrr	a5,sstatus
ffffffffc020167c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020167e:	8526                	mv	a0,s1
ffffffffc0201680:	dbf1                	beqz	a5,ffffffffc0201654 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201682:	e71fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0201686:	00093783          	ld	a5,0(s2)
ffffffffc020168a:	8526                	mv	a0,s1
ffffffffc020168c:	6f9c                	ld	a5,24(a5)
ffffffffc020168e:	9782                	jalr	a5
ffffffffc0201690:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201692:	e5bfe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201696:	4601                	li	a2,0
ffffffffc0201698:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020169a:	d469                	beqz	s0,ffffffffc0201664 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020169c:	70e2                	ld	ra,56(sp)
ffffffffc020169e:	8522                	mv	a0,s0
ffffffffc02016a0:	7442                	ld	s0,48(sp)
ffffffffc02016a2:	74a2                	ld	s1,40(sp)
ffffffffc02016a4:	7902                	ld	s2,32(sp)
ffffffffc02016a6:	69e2                	ld	s3,24(sp)
ffffffffc02016a8:	6a42                	ld	s4,16(sp)
ffffffffc02016aa:	6aa2                	ld	s5,8(sp)
ffffffffc02016ac:	6b02                	ld	s6,0(sp)
ffffffffc02016ae:	6121                	addi	sp,sp,64
ffffffffc02016b0:	8082                	ret

ffffffffc02016b2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016b2:	100027f3          	csrr	a5,sstatus
ffffffffc02016b6:	8b89                	andi	a5,a5,2
ffffffffc02016b8:	e799                	bnez	a5,ffffffffc02016c6 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ba:	00010797          	auipc	a5,0x10
ffffffffc02016be:	e7e7b783          	ld	a5,-386(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016c2:	739c                	ld	a5,32(a5)
ffffffffc02016c4:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02016c6:	1101                	addi	sp,sp,-32
ffffffffc02016c8:	ec06                	sd	ra,24(sp)
ffffffffc02016ca:	e822                	sd	s0,16(sp)
ffffffffc02016cc:	e426                	sd	s1,8(sp)
ffffffffc02016ce:	842a                	mv	s0,a0
ffffffffc02016d0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016d2:	e21fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016d6:	00010797          	auipc	a5,0x10
ffffffffc02016da:	e627b783          	ld	a5,-414(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016de:	739c                	ld	a5,32(a5)
ffffffffc02016e0:	85a6                	mv	a1,s1
ffffffffc02016e2:	8522                	mv	a0,s0
ffffffffc02016e4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016e6:	6442                	ld	s0,16(sp)
ffffffffc02016e8:	60e2                	ld	ra,24(sp)
ffffffffc02016ea:	64a2                	ld	s1,8(sp)
ffffffffc02016ec:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016ee:	dfffe06f          	j	ffffffffc02004ec <intr_enable>

ffffffffc02016f2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f2:	100027f3          	csrr	a5,sstatus
ffffffffc02016f6:	8b89                	andi	a5,a5,2
ffffffffc02016f8:	e799                	bnez	a5,ffffffffc0201706 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016fa:	00010797          	auipc	a5,0x10
ffffffffc02016fe:	e3e7b783          	ld	a5,-450(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201702:	779c                	ld	a5,40(a5)
ffffffffc0201704:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201706:	1141                	addi	sp,sp,-16
ffffffffc0201708:	e406                	sd	ra,8(sp)
ffffffffc020170a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020170c:	de7fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201710:	00010797          	auipc	a5,0x10
ffffffffc0201714:	e287b783          	ld	a5,-472(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201718:	779c                	ld	a5,40(a5)
ffffffffc020171a:	9782                	jalr	a5
ffffffffc020171c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020171e:	dcffe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201722:	60a2                	ld	ra,8(sp)
ffffffffc0201724:	8522                	mv	a0,s0
ffffffffc0201726:	6402                	ld	s0,0(sp)
ffffffffc0201728:	0141                	addi	sp,sp,16
ffffffffc020172a:	8082                	ret

ffffffffc020172c <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020172c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201730:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201734:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201736:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201738:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020173a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc020173e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201740:	f84a                	sd	s2,48(sp)
ffffffffc0201742:	f44e                	sd	s3,40(sp)
ffffffffc0201744:	f052                	sd	s4,32(sp)
ffffffffc0201746:	e486                	sd	ra,72(sp)
ffffffffc0201748:	e0a2                	sd	s0,64(sp)
ffffffffc020174a:	ec56                	sd	s5,24(sp)
ffffffffc020174c:	e85a                	sd	s6,16(sp)
ffffffffc020174e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201750:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201754:	892e                	mv	s2,a1
ffffffffc0201756:	8a32                	mv	s4,a2
ffffffffc0201758:	00010997          	auipc	s3,0x10
ffffffffc020175c:	dd098993          	addi	s3,s3,-560 # ffffffffc0211528 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201760:	efb5                	bnez	a5,ffffffffc02017dc <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201762:	14060c63          	beqz	a2,ffffffffc02018ba <get_pte+0x18e>
ffffffffc0201766:	4505                	li	a0,1
ffffffffc0201768:	eb9ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc020176c:	842a                	mv	s0,a0
ffffffffc020176e:	14050663          	beqz	a0,ffffffffc02018ba <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201772:	00010b97          	auipc	s7,0x10
ffffffffc0201776:	dbeb8b93          	addi	s7,s7,-578 # ffffffffc0211530 <pages>
ffffffffc020177a:	000bb503          	ld	a0,0(s7)
ffffffffc020177e:	00005b17          	auipc	s6,0x5
ffffffffc0201782:	d2ab3b03          	ld	s6,-726(s6) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0201786:	00080ab7          	lui	s5,0x80
ffffffffc020178a:	40a40533          	sub	a0,s0,a0
ffffffffc020178e:	850d                	srai	a0,a0,0x3
ffffffffc0201790:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201794:	00010997          	auipc	s3,0x10
ffffffffc0201798:	d9498993          	addi	s3,s3,-620 # ffffffffc0211528 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020179c:	4785                	li	a5,1
ffffffffc020179e:	0009b703          	ld	a4,0(s3)
ffffffffc02017a2:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017a4:	9556                	add	a0,a0,s5
ffffffffc02017a6:	00c51793          	slli	a5,a0,0xc
ffffffffc02017aa:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017ac:	0532                	slli	a0,a0,0xc
ffffffffc02017ae:	14e7fd63          	bgeu	a5,a4,ffffffffc0201908 <get_pte+0x1dc>
ffffffffc02017b2:	00010797          	auipc	a5,0x10
ffffffffc02017b6:	d8e7b783          	ld	a5,-626(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc02017ba:	6605                	lui	a2,0x1
ffffffffc02017bc:	4581                	li	a1,0
ffffffffc02017be:	953e                	add	a0,a0,a5
ffffffffc02017c0:	541020ef          	jal	ra,ffffffffc0204500 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c4:	000bb683          	ld	a3,0(s7)
ffffffffc02017c8:	40d406b3          	sub	a3,s0,a3
ffffffffc02017cc:	868d                	srai	a3,a3,0x3
ffffffffc02017ce:	036686b3          	mul	a3,a3,s6
ffffffffc02017d2:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017d4:	06aa                	slli	a3,a3,0xa
ffffffffc02017d6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017da:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02017dc:	77fd                	lui	a5,0xfffff
ffffffffc02017de:	068a                	slli	a3,a3,0x2
ffffffffc02017e0:	0009b703          	ld	a4,0(s3)
ffffffffc02017e4:	8efd                	and	a3,a3,a5
ffffffffc02017e6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017ea:	0ce7fa63          	bgeu	a5,a4,ffffffffc02018be <get_pte+0x192>
ffffffffc02017ee:	00010a97          	auipc	s5,0x10
ffffffffc02017f2:	d52a8a93          	addi	s5,s5,-686 # ffffffffc0211540 <va_pa_offset>
ffffffffc02017f6:	000ab403          	ld	s0,0(s5)
ffffffffc02017fa:	01595793          	srli	a5,s2,0x15
ffffffffc02017fe:	1ff7f793          	andi	a5,a5,511
ffffffffc0201802:	96a2                	add	a3,a3,s0
ffffffffc0201804:	00379413          	slli	s0,a5,0x3
ffffffffc0201808:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020180a:	6014                	ld	a3,0(s0)
ffffffffc020180c:	0016f793          	andi	a5,a3,1
ffffffffc0201810:	ebad                	bnez	a5,ffffffffc0201882 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201812:	0a0a0463          	beqz	s4,ffffffffc02018ba <get_pte+0x18e>
ffffffffc0201816:	4505                	li	a0,1
ffffffffc0201818:	e09ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc020181c:	84aa                	mv	s1,a0
ffffffffc020181e:	cd51                	beqz	a0,ffffffffc02018ba <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201820:	00010b97          	auipc	s7,0x10
ffffffffc0201824:	d10b8b93          	addi	s7,s7,-752 # ffffffffc0211530 <pages>
ffffffffc0201828:	000bb503          	ld	a0,0(s7)
ffffffffc020182c:	00005b17          	auipc	s6,0x5
ffffffffc0201830:	c7cb3b03          	ld	s6,-900(s6) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0201834:	00080a37          	lui	s4,0x80
ffffffffc0201838:	40a48533          	sub	a0,s1,a0
ffffffffc020183c:	850d                	srai	a0,a0,0x3
ffffffffc020183e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201842:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201844:	0009b703          	ld	a4,0(s3)
ffffffffc0201848:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020184a:	9552                	add	a0,a0,s4
ffffffffc020184c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201850:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201852:	0532                	slli	a0,a0,0xc
ffffffffc0201854:	08e7fd63          	bgeu	a5,a4,ffffffffc02018ee <get_pte+0x1c2>
ffffffffc0201858:	000ab783          	ld	a5,0(s5)
ffffffffc020185c:	6605                	lui	a2,0x1
ffffffffc020185e:	4581                	li	a1,0
ffffffffc0201860:	953e                	add	a0,a0,a5
ffffffffc0201862:	49f020ef          	jal	ra,ffffffffc0204500 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201866:	000bb683          	ld	a3,0(s7)
ffffffffc020186a:	40d486b3          	sub	a3,s1,a3
ffffffffc020186e:	868d                	srai	a3,a3,0x3
ffffffffc0201870:	036686b3          	mul	a3,a3,s6
ffffffffc0201874:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201876:	06aa                	slli	a3,a3,0xa
ffffffffc0201878:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020187c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020187e:	0009b703          	ld	a4,0(s3)
ffffffffc0201882:	068a                	slli	a3,a3,0x2
ffffffffc0201884:	757d                	lui	a0,0xfffff
ffffffffc0201886:	8ee9                	and	a3,a3,a0
ffffffffc0201888:	00c6d793          	srli	a5,a3,0xc
ffffffffc020188c:	04e7f563          	bgeu	a5,a4,ffffffffc02018d6 <get_pte+0x1aa>
ffffffffc0201890:	000ab503          	ld	a0,0(s5)
ffffffffc0201894:	00c95913          	srli	s2,s2,0xc
ffffffffc0201898:	1ff97913          	andi	s2,s2,511
ffffffffc020189c:	96aa                	add	a3,a3,a0
ffffffffc020189e:	00391513          	slli	a0,s2,0x3
ffffffffc02018a2:	9536                	add	a0,a0,a3
}
ffffffffc02018a4:	60a6                	ld	ra,72(sp)
ffffffffc02018a6:	6406                	ld	s0,64(sp)
ffffffffc02018a8:	74e2                	ld	s1,56(sp)
ffffffffc02018aa:	7942                	ld	s2,48(sp)
ffffffffc02018ac:	79a2                	ld	s3,40(sp)
ffffffffc02018ae:	7a02                	ld	s4,32(sp)
ffffffffc02018b0:	6ae2                	ld	s5,24(sp)
ffffffffc02018b2:	6b42                	ld	s6,16(sp)
ffffffffc02018b4:	6ba2                	ld	s7,8(sp)
ffffffffc02018b6:	6161                	addi	sp,sp,80
ffffffffc02018b8:	8082                	ret
            return NULL;
ffffffffc02018ba:	4501                	li	a0,0
ffffffffc02018bc:	b7e5                	j	ffffffffc02018a4 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02018be:	00004617          	auipc	a2,0x4
ffffffffc02018c2:	aa260613          	addi	a2,a2,-1374 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc02018c6:	10200593          	li	a1,258
ffffffffc02018ca:	00004517          	auipc	a0,0x4
ffffffffc02018ce:	abe50513          	addi	a0,a0,-1346 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02018d2:	aa7fe0ef          	jal	ra,ffffffffc0200378 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018d6:	00004617          	auipc	a2,0x4
ffffffffc02018da:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc02018de:	10f00593          	li	a1,271
ffffffffc02018e2:	00004517          	auipc	a0,0x4
ffffffffc02018e6:	aa650513          	addi	a0,a0,-1370 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02018ea:	a8ffe0ef          	jal	ra,ffffffffc0200378 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018ee:	86aa                	mv	a3,a0
ffffffffc02018f0:	00004617          	auipc	a2,0x4
ffffffffc02018f4:	a7060613          	addi	a2,a2,-1424 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc02018f8:	10b00593          	li	a1,267
ffffffffc02018fc:	00004517          	auipc	a0,0x4
ffffffffc0201900:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0201904:	a75fe0ef          	jal	ra,ffffffffc0200378 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201908:	86aa                	mv	a3,a0
ffffffffc020190a:	00004617          	auipc	a2,0x4
ffffffffc020190e:	a5660613          	addi	a2,a2,-1450 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc0201912:	0ff00593          	li	a1,255
ffffffffc0201916:	00004517          	auipc	a0,0x4
ffffffffc020191a:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020191e:	a5bfe0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0201922 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201922:	1141                	addi	sp,sp,-16
ffffffffc0201924:	e022                	sd	s0,0(sp)
ffffffffc0201926:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201928:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020192a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020192c:	e01ff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201930:	c011                	beqz	s0,ffffffffc0201934 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201932:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201934:	c511                	beqz	a0,ffffffffc0201940 <get_page+0x1e>
ffffffffc0201936:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201938:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020193a:	0017f713          	andi	a4,a5,1
ffffffffc020193e:	e709                	bnez	a4,ffffffffc0201948 <get_page+0x26>
}
ffffffffc0201940:	60a2                	ld	ra,8(sp)
ffffffffc0201942:	6402                	ld	s0,0(sp)
ffffffffc0201944:	0141                	addi	sp,sp,16
ffffffffc0201946:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201948:	078a                	slli	a5,a5,0x2
ffffffffc020194a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020194c:	00010717          	auipc	a4,0x10
ffffffffc0201950:	bdc73703          	ld	a4,-1060(a4) # ffffffffc0211528 <npage>
ffffffffc0201954:	02e7f263          	bgeu	a5,a4,ffffffffc0201978 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201958:	fff80537          	lui	a0,0xfff80
ffffffffc020195c:	97aa                	add	a5,a5,a0
ffffffffc020195e:	60a2                	ld	ra,8(sp)
ffffffffc0201960:	6402                	ld	s0,0(sp)
ffffffffc0201962:	00379513          	slli	a0,a5,0x3
ffffffffc0201966:	97aa                	add	a5,a5,a0
ffffffffc0201968:	078e                	slli	a5,a5,0x3
ffffffffc020196a:	00010517          	auipc	a0,0x10
ffffffffc020196e:	bc653503          	ld	a0,-1082(a0) # ffffffffc0211530 <pages>
ffffffffc0201972:	953e                	add	a0,a0,a5
ffffffffc0201974:	0141                	addi	sp,sp,16
ffffffffc0201976:	8082                	ret
ffffffffc0201978:	c71ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>

ffffffffc020197c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020197c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020197e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201980:	ec06                	sd	ra,24(sp)
ffffffffc0201982:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201984:	da9ff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep != NULL) {
ffffffffc0201988:	c511                	beqz	a0,ffffffffc0201994 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020198a:	611c                	ld	a5,0(a0)
ffffffffc020198c:	842a                	mv	s0,a0
ffffffffc020198e:	0017f713          	andi	a4,a5,1
ffffffffc0201992:	e709                	bnez	a4,ffffffffc020199c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201994:	60e2                	ld	ra,24(sp)
ffffffffc0201996:	6442                	ld	s0,16(sp)
ffffffffc0201998:	6105                	addi	sp,sp,32
ffffffffc020199a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020199c:	078a                	slli	a5,a5,0x2
ffffffffc020199e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019a0:	00010717          	auipc	a4,0x10
ffffffffc02019a4:	b8873703          	ld	a4,-1144(a4) # ffffffffc0211528 <npage>
ffffffffc02019a8:	06e7f563          	bgeu	a5,a4,ffffffffc0201a12 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc02019ac:	fff80737          	lui	a4,0xfff80
ffffffffc02019b0:	97ba                	add	a5,a5,a4
ffffffffc02019b2:	00379513          	slli	a0,a5,0x3
ffffffffc02019b6:	97aa                	add	a5,a5,a0
ffffffffc02019b8:	078e                	slli	a5,a5,0x3
ffffffffc02019ba:	00010517          	auipc	a0,0x10
ffffffffc02019be:	b7653503          	ld	a0,-1162(a0) # ffffffffc0211530 <pages>
ffffffffc02019c2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02019c4:	411c                	lw	a5,0(a0)
ffffffffc02019c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02019ca:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02019cc:	cb09                	beqz	a4,ffffffffc02019de <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02019ce:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019d2:	12000073          	sfence.vma
}
ffffffffc02019d6:	60e2                	ld	ra,24(sp)
ffffffffc02019d8:	6442                	ld	s0,16(sp)
ffffffffc02019da:	6105                	addi	sp,sp,32
ffffffffc02019dc:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019de:	100027f3          	csrr	a5,sstatus
ffffffffc02019e2:	8b89                	andi	a5,a5,2
ffffffffc02019e4:	eb89                	bnez	a5,ffffffffc02019f6 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019e6:	00010797          	auipc	a5,0x10
ffffffffc02019ea:	b527b783          	ld	a5,-1198(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019ee:	739c                	ld	a5,32(a5)
ffffffffc02019f0:	4585                	li	a1,1
ffffffffc02019f2:	9782                	jalr	a5
    if (flag) {
ffffffffc02019f4:	bfe9                	j	ffffffffc02019ce <page_remove+0x52>
        intr_disable();
ffffffffc02019f6:	e42a                	sd	a0,8(sp)
ffffffffc02019f8:	afbfe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc02019fc:	00010797          	auipc	a5,0x10
ffffffffc0201a00:	b3c7b783          	ld	a5,-1220(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201a04:	739c                	ld	a5,32(a5)
ffffffffc0201a06:	6522                	ld	a0,8(sp)
ffffffffc0201a08:	4585                	li	a1,1
ffffffffc0201a0a:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a0c:	ae1fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc0201a10:	bf7d                	j	ffffffffc02019ce <page_remove+0x52>
ffffffffc0201a12:	bd7ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>

ffffffffc0201a16 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a16:	7179                	addi	sp,sp,-48
ffffffffc0201a18:	87b2                	mv	a5,a2
ffffffffc0201a1a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a1c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a1e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a20:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a22:	ec26                	sd	s1,24(sp)
ffffffffc0201a24:	f406                	sd	ra,40(sp)
ffffffffc0201a26:	e84a                	sd	s2,16(sp)
ffffffffc0201a28:	e44e                	sd	s3,8(sp)
ffffffffc0201a2a:	e052                	sd	s4,0(sp)
ffffffffc0201a2c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a2e:	cffff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a32:	cd71                	beqz	a0,ffffffffc0201b0e <page_insert+0xf8>
    page->ref += 1;
ffffffffc0201a34:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a36:	611c                	ld	a5,0(a0)
ffffffffc0201a38:	89aa                	mv	s3,a0
ffffffffc0201a3a:	0016871b          	addiw	a4,a3,1
ffffffffc0201a3e:	c018                	sw	a4,0(s0)
ffffffffc0201a40:	0017f713          	andi	a4,a5,1
ffffffffc0201a44:	e331                	bnez	a4,ffffffffc0201a88 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a46:	00010797          	auipc	a5,0x10
ffffffffc0201a4a:	aea7b783          	ld	a5,-1302(a5) # ffffffffc0211530 <pages>
ffffffffc0201a4e:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a52:	878d                	srai	a5,a5,0x3
ffffffffc0201a54:	00005417          	auipc	s0,0x5
ffffffffc0201a58:	a5443403          	ld	s0,-1452(s0) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0201a5c:	028787b3          	mul	a5,a5,s0
ffffffffc0201a60:	00080437          	lui	s0,0x80
ffffffffc0201a64:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a66:	07aa                	slli	a5,a5,0xa
ffffffffc0201a68:	8cdd                	or	s1,s1,a5
ffffffffc0201a6a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a6e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a72:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a76:	4501                	li	a0,0
}
ffffffffc0201a78:	70a2                	ld	ra,40(sp)
ffffffffc0201a7a:	7402                	ld	s0,32(sp)
ffffffffc0201a7c:	64e2                	ld	s1,24(sp)
ffffffffc0201a7e:	6942                	ld	s2,16(sp)
ffffffffc0201a80:	69a2                	ld	s3,8(sp)
ffffffffc0201a82:	6a02                	ld	s4,0(sp)
ffffffffc0201a84:	6145                	addi	sp,sp,48
ffffffffc0201a86:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a88:	00279713          	slli	a4,a5,0x2
ffffffffc0201a8c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a8e:	00010797          	auipc	a5,0x10
ffffffffc0201a92:	a9a7b783          	ld	a5,-1382(a5) # ffffffffc0211528 <npage>
ffffffffc0201a96:	06f77e63          	bgeu	a4,a5,ffffffffc0201b12 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a9a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a9e:	973e                	add	a4,a4,a5
ffffffffc0201aa0:	00010a17          	auipc	s4,0x10
ffffffffc0201aa4:	a90a0a13          	addi	s4,s4,-1392 # ffffffffc0211530 <pages>
ffffffffc0201aa8:	000a3783          	ld	a5,0(s4)
ffffffffc0201aac:	00371913          	slli	s2,a4,0x3
ffffffffc0201ab0:	993a                	add	s2,s2,a4
ffffffffc0201ab2:	090e                	slli	s2,s2,0x3
ffffffffc0201ab4:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201ab6:	03240063          	beq	s0,s2,ffffffffc0201ad6 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201aba:	00092783          	lw	a5,0(s2)
ffffffffc0201abe:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201ac2:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201ac6:	cb11                	beqz	a4,ffffffffc0201ada <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201ac8:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201acc:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ad0:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201ad4:	bfad                	j	ffffffffc0201a4e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201ad6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ad8:	bf9d                	j	ffffffffc0201a4e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ada:	100027f3          	csrr	a5,sstatus
ffffffffc0201ade:	8b89                	andi	a5,a5,2
ffffffffc0201ae0:	eb91                	bnez	a5,ffffffffc0201af4 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201ae2:	00010797          	auipc	a5,0x10
ffffffffc0201ae6:	a567b783          	ld	a5,-1450(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201aea:	739c                	ld	a5,32(a5)
ffffffffc0201aec:	4585                	li	a1,1
ffffffffc0201aee:	854a                	mv	a0,s2
ffffffffc0201af0:	9782                	jalr	a5
    if (flag) {
ffffffffc0201af2:	bfd9                	j	ffffffffc0201ac8 <page_insert+0xb2>
        intr_disable();
ffffffffc0201af4:	9fffe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0201af8:	00010797          	auipc	a5,0x10
ffffffffc0201afc:	a407b783          	ld	a5,-1472(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201b00:	739c                	ld	a5,32(a5)
ffffffffc0201b02:	4585                	li	a1,1
ffffffffc0201b04:	854a                	mv	a0,s2
ffffffffc0201b06:	9782                	jalr	a5
        intr_enable();
ffffffffc0201b08:	9e5fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc0201b0c:	bf75                	j	ffffffffc0201ac8 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201b0e:	5571                	li	a0,-4
ffffffffc0201b10:	b7a5                	j	ffffffffc0201a78 <page_insert+0x62>
ffffffffc0201b12:	ad7ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>

ffffffffc0201b16 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b16:	00003797          	auipc	a5,0x3
ffffffffc0201b1a:	7ba78793          	addi	a5,a5,1978 # ffffffffc02052d0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b1e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b20:	7159                	addi	sp,sp,-112
ffffffffc0201b22:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b24:	00004517          	auipc	a0,0x4
ffffffffc0201b28:	87450513          	addi	a0,a0,-1932 # ffffffffc0205398 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201b2c:	00010b97          	auipc	s7,0x10
ffffffffc0201b30:	a0cb8b93          	addi	s7,s7,-1524 # ffffffffc0211538 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b34:	f486                	sd	ra,104(sp)
ffffffffc0201b36:	f0a2                	sd	s0,96(sp)
ffffffffc0201b38:	eca6                	sd	s1,88(sp)
ffffffffc0201b3a:	e8ca                	sd	s2,80(sp)
ffffffffc0201b3c:	e4ce                	sd	s3,72(sp)
ffffffffc0201b3e:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b40:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201b44:	e0d2                	sd	s4,64(sp)
ffffffffc0201b46:	fc56                	sd	s5,56(sp)
ffffffffc0201b48:	f062                	sd	s8,32(sp)
ffffffffc0201b4a:	ec66                	sd	s9,24(sp)
ffffffffc0201b4c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b4e:	d70fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b52:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b56:	4445                	li	s0,17
ffffffffc0201b58:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201b5c:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b5e:	00010997          	auipc	s3,0x10
ffffffffc0201b62:	9e298993          	addi	s3,s3,-1566 # ffffffffc0211540 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b66:	00010497          	auipc	s1,0x10
ffffffffc0201b6a:	9c248493          	addi	s1,s1,-1598 # ffffffffc0211528 <npage>
    pmm_manager->init();
ffffffffc0201b6e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b70:	57f5                	li	a5,-3
ffffffffc0201b72:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b74:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b78:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b7c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b80:	00004517          	auipc	a0,0x4
ffffffffc0201b84:	83050513          	addi	a0,a0,-2000 # ffffffffc02053b0 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b88:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b8c:	d32fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b90:	00004517          	auipc	a0,0x4
ffffffffc0201b94:	85050513          	addi	a0,a0,-1968 # ffffffffc02053e0 <default_pmm_manager+0x110>
ffffffffc0201b98:	d26fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b9c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201ba0:	16fd                	addi	a3,a3,-1
ffffffffc0201ba2:	07e005b7          	lui	a1,0x7e00
ffffffffc0201ba6:	01591613          	slli	a2,s2,0x15
ffffffffc0201baa:	00004517          	auipc	a0,0x4
ffffffffc0201bae:	84e50513          	addi	a0,a0,-1970 # ffffffffc02053f8 <default_pmm_manager+0x128>
ffffffffc0201bb2:	d0cfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bb6:	777d                	lui	a4,0xfffff
ffffffffc0201bb8:	00011797          	auipc	a5,0x11
ffffffffc0201bbc:	9bb78793          	addi	a5,a5,-1605 # ffffffffc0212573 <end+0xfff>
ffffffffc0201bc0:	8ff9                	and	a5,a5,a4
ffffffffc0201bc2:	00010b17          	auipc	s6,0x10
ffffffffc0201bc6:	96eb0b13          	addi	s6,s6,-1682 # ffffffffc0211530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201bca:	00088737          	lui	a4,0x88
ffffffffc0201bce:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bd0:	00fb3023          	sd	a5,0(s6)
ffffffffc0201bd4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bd6:	4701                	li	a4,0
ffffffffc0201bd8:	4505                	li	a0,1
ffffffffc0201bda:	fff805b7          	lui	a1,0xfff80
ffffffffc0201bde:	a019                	j	ffffffffc0201be4 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201be0:	000b3783          	ld	a5,0(s6)
ffffffffc0201be4:	97b6                	add	a5,a5,a3
ffffffffc0201be6:	07a1                	addi	a5,a5,8
ffffffffc0201be8:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bec:	609c                	ld	a5,0(s1)
ffffffffc0201bee:	0705                	addi	a4,a4,1
ffffffffc0201bf0:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201bf4:	00b78633          	add	a2,a5,a1
ffffffffc0201bf8:	fec764e3          	bltu	a4,a2,ffffffffc0201be0 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bfc:	000b3503          	ld	a0,0(s6)
ffffffffc0201c00:	00379693          	slli	a3,a5,0x3
ffffffffc0201c04:	96be                	add	a3,a3,a5
ffffffffc0201c06:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c0a:	972a                	add	a4,a4,a0
ffffffffc0201c0c:	068e                	slli	a3,a3,0x3
ffffffffc0201c0e:	96ba                	add	a3,a3,a4
ffffffffc0201c10:	c0200737          	lui	a4,0xc0200
ffffffffc0201c14:	64e6e463          	bltu	a3,a4,ffffffffc020225c <pmm_init+0x746>
ffffffffc0201c18:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c1c:	4645                	li	a2,17
ffffffffc0201c1e:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c20:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c22:	4ec6e263          	bltu	a3,a2,ffffffffc0202106 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c26:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c2a:	00010917          	auipc	s2,0x10
ffffffffc0201c2e:	8f690913          	addi	s2,s2,-1802 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c32:	7b9c                	ld	a5,48(a5)
ffffffffc0201c34:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c36:	00004517          	auipc	a0,0x4
ffffffffc0201c3a:	81250513          	addi	a0,a0,-2030 # ffffffffc0205448 <default_pmm_manager+0x178>
ffffffffc0201c3e:	c80fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c42:	00007697          	auipc	a3,0x7
ffffffffc0201c46:	3be68693          	addi	a3,a3,958 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c4a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c4e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c52:	62f6e163          	bltu	a3,a5,ffffffffc0202274 <pmm_init+0x75e>
ffffffffc0201c56:	0009b783          	ld	a5,0(s3)
ffffffffc0201c5a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c5c:	00010797          	auipc	a5,0x10
ffffffffc0201c60:	8ad7be23          	sd	a3,-1860(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c64:	100027f3          	csrr	a5,sstatus
ffffffffc0201c68:	8b89                	andi	a5,a5,2
ffffffffc0201c6a:	4c079763          	bnez	a5,ffffffffc0202138 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c6e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c72:	779c                	ld	a5,40(a5)
ffffffffc0201c74:	9782                	jalr	a5
ffffffffc0201c76:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c78:	6098                	ld	a4,0(s1)
ffffffffc0201c7a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c7e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c80:	62e7e663          	bltu	a5,a4,ffffffffc02022ac <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c84:	00093503          	ld	a0,0(s2)
ffffffffc0201c88:	60050263          	beqz	a0,ffffffffc020228c <pmm_init+0x776>
ffffffffc0201c8c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c90:	5e079e63          	bnez	a5,ffffffffc020228c <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c94:	4601                	li	a2,0
ffffffffc0201c96:	4581                	li	a1,0
ffffffffc0201c98:	c8bff0ef          	jal	ra,ffffffffc0201922 <get_page>
ffffffffc0201c9c:	66051a63          	bnez	a0,ffffffffc0202310 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201ca0:	4505                	li	a0,1
ffffffffc0201ca2:	97fff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0201ca6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201ca8:	00093503          	ld	a0,0(s2)
ffffffffc0201cac:	4681                	li	a3,0
ffffffffc0201cae:	4601                	li	a2,0
ffffffffc0201cb0:	85d2                	mv	a1,s4
ffffffffc0201cb2:	d65ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201cb6:	62051d63          	bnez	a0,ffffffffc02022f0 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201cba:	00093503          	ld	a0,0(s2)
ffffffffc0201cbe:	4601                	li	a2,0
ffffffffc0201cc0:	4581                	li	a1,0
ffffffffc0201cc2:	a6bff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201cc6:	60050563          	beqz	a0,ffffffffc02022d0 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cca:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201ccc:	0017f713          	andi	a4,a5,1
ffffffffc0201cd0:	5e070e63          	beqz	a4,ffffffffc02022cc <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201cd4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201cd6:	078a                	slli	a5,a5,0x2
ffffffffc0201cd8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cda:	56c7ff63          	bgeu	a5,a2,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cde:	fff80737          	lui	a4,0xfff80
ffffffffc0201ce2:	97ba                	add	a5,a5,a4
ffffffffc0201ce4:	000b3683          	ld	a3,0(s6)
ffffffffc0201ce8:	00379713          	slli	a4,a5,0x3
ffffffffc0201cec:	97ba                	add	a5,a5,a4
ffffffffc0201cee:	078e                	slli	a5,a5,0x3
ffffffffc0201cf0:	97b6                	add	a5,a5,a3
ffffffffc0201cf2:	14fa18e3          	bne	s4,a5,ffffffffc0202642 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201cf6:	000a2703          	lw	a4,0(s4)
ffffffffc0201cfa:	4785                	li	a5,1
ffffffffc0201cfc:	16f71fe3          	bne	a4,a5,ffffffffc020267a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d00:	00093503          	ld	a0,0(s2)
ffffffffc0201d04:	77fd                	lui	a5,0xfffff
ffffffffc0201d06:	6114                	ld	a3,0(a0)
ffffffffc0201d08:	068a                	slli	a3,a3,0x2
ffffffffc0201d0a:	8efd                	and	a3,a3,a5
ffffffffc0201d0c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201d10:	14c779e3          	bgeu	a4,a2,ffffffffc0202662 <pmm_init+0xb4c>
ffffffffc0201d14:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d18:	96e2                	add	a3,a3,s8
ffffffffc0201d1a:	0006ba83          	ld	s5,0(a3)
ffffffffc0201d1e:	0a8a                	slli	s5,s5,0x2
ffffffffc0201d20:	00fafab3          	and	s5,s5,a5
ffffffffc0201d24:	00cad793          	srli	a5,s5,0xc
ffffffffc0201d28:	66c7f463          	bgeu	a5,a2,ffffffffc0202390 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d2c:	4601                	li	a2,0
ffffffffc0201d2e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d30:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d32:	9fbff0ef          	jal	ra,ffffffffc020172c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d36:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d38:	63551c63          	bne	a0,s5,ffffffffc0202370 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201d3c:	4505                	li	a0,1
ffffffffc0201d3e:	8e3ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0201d42:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d44:	00093503          	ld	a0,0(s2)
ffffffffc0201d48:	46d1                	li	a3,20
ffffffffc0201d4a:	6605                	lui	a2,0x1
ffffffffc0201d4c:	85d6                	mv	a1,s5
ffffffffc0201d4e:	cc9ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201d52:	5c051f63          	bnez	a0,ffffffffc0202330 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d56:	00093503          	ld	a0,0(s2)
ffffffffc0201d5a:	4601                	li	a2,0
ffffffffc0201d5c:	6585                	lui	a1,0x1
ffffffffc0201d5e:	9cfff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201d62:	12050ce3          	beqz	a0,ffffffffc020269a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201d66:	611c                	ld	a5,0(a0)
ffffffffc0201d68:	0107f713          	andi	a4,a5,16
ffffffffc0201d6c:	72070f63          	beqz	a4,ffffffffc02024aa <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d70:	8b91                	andi	a5,a5,4
ffffffffc0201d72:	6e078c63          	beqz	a5,ffffffffc020246a <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d76:	00093503          	ld	a0,0(s2)
ffffffffc0201d7a:	611c                	ld	a5,0(a0)
ffffffffc0201d7c:	8bc1                	andi	a5,a5,16
ffffffffc0201d7e:	6c078663          	beqz	a5,ffffffffc020244a <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201d82:	000aa703          	lw	a4,0(s5)
ffffffffc0201d86:	4785                	li	a5,1
ffffffffc0201d88:	5cf71463          	bne	a4,a5,ffffffffc0202350 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d8c:	4681                	li	a3,0
ffffffffc0201d8e:	6605                	lui	a2,0x1
ffffffffc0201d90:	85d2                	mv	a1,s4
ffffffffc0201d92:	c85ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201d96:	66051a63          	bnez	a0,ffffffffc020240a <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d9a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d9e:	4789                	li	a5,2
ffffffffc0201da0:	64f71563          	bne	a4,a5,ffffffffc02023ea <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201da4:	000aa783          	lw	a5,0(s5)
ffffffffc0201da8:	62079163          	bnez	a5,ffffffffc02023ca <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201dac:	00093503          	ld	a0,0(s2)
ffffffffc0201db0:	4601                	li	a2,0
ffffffffc0201db2:	6585                	lui	a1,0x1
ffffffffc0201db4:	979ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201db8:	5e050963          	beqz	a0,ffffffffc02023aa <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201dbc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201dbe:	00177793          	andi	a5,a4,1
ffffffffc0201dc2:	50078563          	beqz	a5,ffffffffc02022cc <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201dc6:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dc8:	00271793          	slli	a5,a4,0x2
ffffffffc0201dcc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dce:	48d7f563          	bgeu	a5,a3,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dd2:	fff806b7          	lui	a3,0xfff80
ffffffffc0201dd6:	97b6                	add	a5,a5,a3
ffffffffc0201dd8:	000b3603          	ld	a2,0(s6)
ffffffffc0201ddc:	00379693          	slli	a3,a5,0x3
ffffffffc0201de0:	97b6                	add	a5,a5,a3
ffffffffc0201de2:	078e                	slli	a5,a5,0x3
ffffffffc0201de4:	97b2                	add	a5,a5,a2
ffffffffc0201de6:	72fa1263          	bne	s4,a5,ffffffffc020250a <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dea:	8b41                	andi	a4,a4,16
ffffffffc0201dec:	6e071f63          	bnez	a4,ffffffffc02024ea <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201df0:	00093503          	ld	a0,0(s2)
ffffffffc0201df4:	4581                	li	a1,0
ffffffffc0201df6:	b87ff0ef          	jal	ra,ffffffffc020197c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dfa:	000a2703          	lw	a4,0(s4)
ffffffffc0201dfe:	4785                	li	a5,1
ffffffffc0201e00:	6cf71563          	bne	a4,a5,ffffffffc02024ca <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201e04:	000aa783          	lw	a5,0(s5)
ffffffffc0201e08:	78079d63          	bnez	a5,ffffffffc02025a2 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e0c:	00093503          	ld	a0,0(s2)
ffffffffc0201e10:	6585                	lui	a1,0x1
ffffffffc0201e12:	b6bff0ef          	jal	ra,ffffffffc020197c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e16:	000a2783          	lw	a5,0(s4)
ffffffffc0201e1a:	76079463          	bnez	a5,ffffffffc0202582 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201e1e:	000aa783          	lw	a5,0(s5)
ffffffffc0201e22:	74079063          	bnez	a5,ffffffffc0202562 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e26:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201e2a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e2c:	000a3783          	ld	a5,0(s4)
ffffffffc0201e30:	078a                	slli	a5,a5,0x2
ffffffffc0201e32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e34:	42c7f263          	bgeu	a5,a2,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e38:	fff80737          	lui	a4,0xfff80
ffffffffc0201e3c:	973e                	add	a4,a4,a5
ffffffffc0201e3e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e42:	000b3503          	ld	a0,0(s6)
ffffffffc0201e46:	97ba                	add	a5,a5,a4
ffffffffc0201e48:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e4a:	00f50733          	add	a4,a0,a5
ffffffffc0201e4e:	4314                	lw	a3,0(a4)
ffffffffc0201e50:	4705                	li	a4,1
ffffffffc0201e52:	6ee69863          	bne	a3,a4,ffffffffc0202542 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e56:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e5a:	00004c97          	auipc	s9,0x4
ffffffffc0201e5e:	64ecbc83          	ld	s9,1614(s9) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0201e62:	039686b3          	mul	a3,a3,s9
ffffffffc0201e66:	000805b7          	lui	a1,0x80
ffffffffc0201e6a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e6c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e70:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e72:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e74:	6ac77b63          	bgeu	a4,a2,ffffffffc020252a <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e78:	0009b703          	ld	a4,0(s3)
ffffffffc0201e7c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e7e:	629c                	ld	a5,0(a3)
ffffffffc0201e80:	078a                	slli	a5,a5,0x2
ffffffffc0201e82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e84:	3cc7fa63          	bgeu	a5,a2,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e88:	8f8d                	sub	a5,a5,a1
ffffffffc0201e8a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e8e:	97ba                	add	a5,a5,a4
ffffffffc0201e90:	078e                	slli	a5,a5,0x3
ffffffffc0201e92:	953e                	add	a0,a0,a5
ffffffffc0201e94:	100027f3          	csrr	a5,sstatus
ffffffffc0201e98:	8b89                	andi	a5,a5,2
ffffffffc0201e9a:	2e079963          	bnez	a5,ffffffffc020218c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e9e:	000bb783          	ld	a5,0(s7)
ffffffffc0201ea2:	4585                	li	a1,1
ffffffffc0201ea4:	739c                	ld	a5,32(a5)
ffffffffc0201ea6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201eac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201eae:	078a                	slli	a5,a5,0x2
ffffffffc0201eb0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eb2:	3ae7f363          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eb6:	fff80737          	lui	a4,0xfff80
ffffffffc0201eba:	97ba                	add	a5,a5,a4
ffffffffc0201ebc:	000b3503          	ld	a0,0(s6)
ffffffffc0201ec0:	00379713          	slli	a4,a5,0x3
ffffffffc0201ec4:	97ba                	add	a5,a5,a4
ffffffffc0201ec6:	078e                	slli	a5,a5,0x3
ffffffffc0201ec8:	953e                	add	a0,a0,a5
ffffffffc0201eca:	100027f3          	csrr	a5,sstatus
ffffffffc0201ece:	8b89                	andi	a5,a5,2
ffffffffc0201ed0:	2a079263          	bnez	a5,ffffffffc0202174 <pmm_init+0x65e>
ffffffffc0201ed4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ed8:	4585                	li	a1,1
ffffffffc0201eda:	739c                	ld	a5,32(a5)
ffffffffc0201edc:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201ede:	00093783          	ld	a5,0(s2)
ffffffffc0201ee2:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201ee6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eea:	8b89                	andi	a5,a5,2
ffffffffc0201eec:	26079a63          	bnez	a5,ffffffffc0202160 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ef0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ef4:	779c                	ld	a5,40(a5)
ffffffffc0201ef6:	9782                	jalr	a5
ffffffffc0201ef8:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201efa:	73441463          	bne	s0,s4,ffffffffc0202622 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201efe:	00004517          	auipc	a0,0x4
ffffffffc0201f02:	83250513          	addi	a0,a0,-1998 # ffffffffc0205730 <default_pmm_manager+0x460>
ffffffffc0201f06:	9b8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0201f0a:	100027f3          	csrr	a5,sstatus
ffffffffc0201f0e:	8b89                	andi	a5,a5,2
ffffffffc0201f10:	22079e63          	bnez	a5,ffffffffc020214c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201f14:	000bb783          	ld	a5,0(s7)
ffffffffc0201f18:	779c                	ld	a5,40(a5)
ffffffffc0201f1a:	9782                	jalr	a5
ffffffffc0201f1c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f1e:	6098                	ld	a4,0(s1)
ffffffffc0201f20:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f24:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f26:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f2a:	6a05                	lui	s4,0x1
ffffffffc0201f2c:	02f47c63          	bgeu	s0,a5,ffffffffc0201f64 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f30:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f34:	00093503          	ld	a0,0(s2)
ffffffffc0201f38:	30e7f363          	bgeu	a5,a4,ffffffffc020223e <pmm_init+0x728>
ffffffffc0201f3c:	0009b583          	ld	a1,0(s3)
ffffffffc0201f40:	4601                	li	a2,0
ffffffffc0201f42:	95a2                	add	a1,a1,s0
ffffffffc0201f44:	fe8ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201f48:	2c050b63          	beqz	a0,ffffffffc020221e <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f4c:	611c                	ld	a5,0(a0)
ffffffffc0201f4e:	078a                	slli	a5,a5,0x2
ffffffffc0201f50:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f54:	2a879563          	bne	a5,s0,ffffffffc02021fe <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f58:	6098                	ld	a4,0(s1)
ffffffffc0201f5a:	9452                	add	s0,s0,s4
ffffffffc0201f5c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f60:	fcf468e3          	bltu	s0,a5,ffffffffc0201f30 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f64:	00093783          	ld	a5,0(s2)
ffffffffc0201f68:	639c                	ld	a5,0(a5)
ffffffffc0201f6a:	68079c63          	bnez	a5,ffffffffc0202602 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f6e:	4505                	li	a0,1
ffffffffc0201f70:	eb0ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0201f74:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f76:	00093503          	ld	a0,0(s2)
ffffffffc0201f7a:	4699                	li	a3,6
ffffffffc0201f7c:	10000613          	li	a2,256
ffffffffc0201f80:	85d6                	mv	a1,s5
ffffffffc0201f82:	a95ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201f86:	64051e63          	bnez	a0,ffffffffc02025e2 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f8a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201f8e:	4785                	li	a5,1
ffffffffc0201f90:	62f71963          	bne	a4,a5,ffffffffc02025c2 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f94:	00093503          	ld	a0,0(s2)
ffffffffc0201f98:	6405                	lui	s0,0x1
ffffffffc0201f9a:	4699                	li	a3,6
ffffffffc0201f9c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201fa0:	85d6                	mv	a1,s5
ffffffffc0201fa2:	a75ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201fa6:	48051263          	bnez	a0,ffffffffc020242a <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201faa:	000aa703          	lw	a4,0(s5)
ffffffffc0201fae:	4789                	li	a5,2
ffffffffc0201fb0:	74f71563          	bne	a4,a5,ffffffffc02026fa <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fb4:	00004597          	auipc	a1,0x4
ffffffffc0201fb8:	8b458593          	addi	a1,a1,-1868 # ffffffffc0205868 <default_pmm_manager+0x598>
ffffffffc0201fbc:	10000513          	li	a0,256
ffffffffc0201fc0:	4fa020ef          	jal	ra,ffffffffc02044ba <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fc4:	10040593          	addi	a1,s0,256
ffffffffc0201fc8:	10000513          	li	a0,256
ffffffffc0201fcc:	500020ef          	jal	ra,ffffffffc02044cc <strcmp>
ffffffffc0201fd0:	70051563          	bnez	a0,ffffffffc02026da <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fd4:	000b3683          	ld	a3,0(s6)
ffffffffc0201fd8:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fdc:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fde:	40da86b3          	sub	a3,s5,a3
ffffffffc0201fe2:	868d                	srai	a3,a3,0x3
ffffffffc0201fe4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fe8:	609c                	ld	a5,0(s1)
ffffffffc0201fea:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fec:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fee:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ff2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff4:	52f77b63          	bgeu	a4,a5,ffffffffc020252a <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ff8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ffc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202000:	96be                	add	a3,a3,a5
ffffffffc0202002:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb8c>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202006:	47e020ef          	jal	ra,ffffffffc0204484 <strlen>
ffffffffc020200a:	6a051863          	bnez	a0,ffffffffc02026ba <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020200e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202012:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202014:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202018:	078a                	slli	a5,a5,0x2
ffffffffc020201a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020201c:	22e7fe63          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202020:	41a787b3          	sub	a5,a5,s10
ffffffffc0202024:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202028:	96be                	add	a3,a3,a5
ffffffffc020202a:	03968cb3          	mul	s9,a3,s9
ffffffffc020202e:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202032:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202034:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202036:	4ee47a63          	bgeu	s0,a4,ffffffffc020252a <pmm_init+0xa14>
ffffffffc020203a:	0009b403          	ld	s0,0(s3)
ffffffffc020203e:	9436                	add	s0,s0,a3
ffffffffc0202040:	100027f3          	csrr	a5,sstatus
ffffffffc0202044:	8b89                	andi	a5,a5,2
ffffffffc0202046:	1a079163          	bnez	a5,ffffffffc02021e8 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020204a:	000bb783          	ld	a5,0(s7)
ffffffffc020204e:	4585                	li	a1,1
ffffffffc0202050:	8556                	mv	a0,s5
ffffffffc0202052:	739c                	ld	a5,32(a5)
ffffffffc0202054:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202056:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202058:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020205a:	078a                	slli	a5,a5,0x2
ffffffffc020205c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020205e:	1ee7fd63          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202062:	fff80737          	lui	a4,0xfff80
ffffffffc0202066:	97ba                	add	a5,a5,a4
ffffffffc0202068:	000b3503          	ld	a0,0(s6)
ffffffffc020206c:	00379713          	slli	a4,a5,0x3
ffffffffc0202070:	97ba                	add	a5,a5,a4
ffffffffc0202072:	078e                	slli	a5,a5,0x3
ffffffffc0202074:	953e                	add	a0,a0,a5
ffffffffc0202076:	100027f3          	csrr	a5,sstatus
ffffffffc020207a:	8b89                	andi	a5,a5,2
ffffffffc020207c:	14079a63          	bnez	a5,ffffffffc02021d0 <pmm_init+0x6ba>
ffffffffc0202080:	000bb783          	ld	a5,0(s7)
ffffffffc0202084:	4585                	li	a1,1
ffffffffc0202086:	739c                	ld	a5,32(a5)
ffffffffc0202088:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020208a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020208e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202090:	078a                	slli	a5,a5,0x2
ffffffffc0202092:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202094:	1ce7f263          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202098:	fff80737          	lui	a4,0xfff80
ffffffffc020209c:	97ba                	add	a5,a5,a4
ffffffffc020209e:	000b3503          	ld	a0,0(s6)
ffffffffc02020a2:	00379713          	slli	a4,a5,0x3
ffffffffc02020a6:	97ba                	add	a5,a5,a4
ffffffffc02020a8:	078e                	slli	a5,a5,0x3
ffffffffc02020aa:	953e                	add	a0,a0,a5
ffffffffc02020ac:	100027f3          	csrr	a5,sstatus
ffffffffc02020b0:	8b89                	andi	a5,a5,2
ffffffffc02020b2:	10079363          	bnez	a5,ffffffffc02021b8 <pmm_init+0x6a2>
ffffffffc02020b6:	000bb783          	ld	a5,0(s7)
ffffffffc02020ba:	4585                	li	a1,1
ffffffffc02020bc:	739c                	ld	a5,32(a5)
ffffffffc02020be:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02020c0:	00093783          	ld	a5,0(s2)
ffffffffc02020c4:	0007b023          	sd	zero,0(a5)
ffffffffc02020c8:	100027f3          	csrr	a5,sstatus
ffffffffc02020cc:	8b89                	andi	a5,a5,2
ffffffffc02020ce:	0c079b63          	bnez	a5,ffffffffc02021a4 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020d2:	000bb783          	ld	a5,0(s7)
ffffffffc02020d6:	779c                	ld	a5,40(a5)
ffffffffc02020d8:	9782                	jalr	a5
ffffffffc02020da:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02020dc:	3a8c1763          	bne	s8,s0,ffffffffc020248a <pmm_init+0x974>
}
ffffffffc02020e0:	7406                	ld	s0,96(sp)
ffffffffc02020e2:	70a6                	ld	ra,104(sp)
ffffffffc02020e4:	64e6                	ld	s1,88(sp)
ffffffffc02020e6:	6946                	ld	s2,80(sp)
ffffffffc02020e8:	69a6                	ld	s3,72(sp)
ffffffffc02020ea:	6a06                	ld	s4,64(sp)
ffffffffc02020ec:	7ae2                	ld	s5,56(sp)
ffffffffc02020ee:	7b42                	ld	s6,48(sp)
ffffffffc02020f0:	7ba2                	ld	s7,40(sp)
ffffffffc02020f2:	7c02                	ld	s8,32(sp)
ffffffffc02020f4:	6ce2                	ld	s9,24(sp)
ffffffffc02020f6:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020f8:	00003517          	auipc	a0,0x3
ffffffffc02020fc:	7e850513          	addi	a0,a0,2024 # ffffffffc02058e0 <default_pmm_manager+0x610>
}
ffffffffc0202100:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202102:	fbdfd06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202106:	6705                	lui	a4,0x1
ffffffffc0202108:	177d                	addi	a4,a4,-1
ffffffffc020210a:	96ba                	add	a3,a3,a4
ffffffffc020210c:	777d                	lui	a4,0xfffff
ffffffffc020210e:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0202110:	00c75693          	srli	a3,a4,0xc
ffffffffc0202114:	14f6f263          	bgeu	a3,a5,ffffffffc0202258 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc0202118:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020211c:	95b6                	add	a1,a1,a3
ffffffffc020211e:	00359793          	slli	a5,a1,0x3
ffffffffc0202122:	97ae                	add	a5,a5,a1
ffffffffc0202124:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202128:	40e60733          	sub	a4,a2,a4
ffffffffc020212c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020212e:	00c75593          	srli	a1,a4,0xc
ffffffffc0202132:	953e                	add	a0,a0,a5
ffffffffc0202134:	9682                	jalr	a3
}
ffffffffc0202136:	bcc5                	j	ffffffffc0201c26 <pmm_init+0x110>
        intr_disable();
ffffffffc0202138:	bbafe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020213c:	000bb783          	ld	a5,0(s7)
ffffffffc0202140:	779c                	ld	a5,40(a5)
ffffffffc0202142:	9782                	jalr	a5
ffffffffc0202144:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202146:	ba6fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc020214a:	b63d                	j	ffffffffc0201c78 <pmm_init+0x162>
        intr_disable();
ffffffffc020214c:	ba6fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0202150:	000bb783          	ld	a5,0(s7)
ffffffffc0202154:	779c                	ld	a5,40(a5)
ffffffffc0202156:	9782                	jalr	a5
ffffffffc0202158:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020215a:	b92fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc020215e:	b3c1                	j	ffffffffc0201f1e <pmm_init+0x408>
        intr_disable();
ffffffffc0202160:	b92fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0202164:	000bb783          	ld	a5,0(s7)
ffffffffc0202168:	779c                	ld	a5,40(a5)
ffffffffc020216a:	9782                	jalr	a5
ffffffffc020216c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020216e:	b7efe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc0202172:	b361                	j	ffffffffc0201efa <pmm_init+0x3e4>
ffffffffc0202174:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202176:	b7cfe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020217a:	000bb783          	ld	a5,0(s7)
ffffffffc020217e:	6522                	ld	a0,8(sp)
ffffffffc0202180:	4585                	li	a1,1
ffffffffc0202182:	739c                	ld	a5,32(a5)
ffffffffc0202184:	9782                	jalr	a5
        intr_enable();
ffffffffc0202186:	b66fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc020218a:	bb91                	j	ffffffffc0201ede <pmm_init+0x3c8>
ffffffffc020218c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020218e:	b64fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0202192:	000bb783          	ld	a5,0(s7)
ffffffffc0202196:	6522                	ld	a0,8(sp)
ffffffffc0202198:	4585                	li	a1,1
ffffffffc020219a:	739c                	ld	a5,32(a5)
ffffffffc020219c:	9782                	jalr	a5
        intr_enable();
ffffffffc020219e:	b4efe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02021a2:	b319                	j	ffffffffc0201ea8 <pmm_init+0x392>
        intr_disable();
ffffffffc02021a4:	b4efe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02021a8:	000bb783          	ld	a5,0(s7)
ffffffffc02021ac:	779c                	ld	a5,40(a5)
ffffffffc02021ae:	9782                	jalr	a5
ffffffffc02021b0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02021b2:	b3afe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02021b6:	b71d                	j	ffffffffc02020dc <pmm_init+0x5c6>
ffffffffc02021b8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021ba:	b38fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02021be:	000bb783          	ld	a5,0(s7)
ffffffffc02021c2:	6522                	ld	a0,8(sp)
ffffffffc02021c4:	4585                	li	a1,1
ffffffffc02021c6:	739c                	ld	a5,32(a5)
ffffffffc02021c8:	9782                	jalr	a5
        intr_enable();
ffffffffc02021ca:	b22fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02021ce:	bdcd                	j	ffffffffc02020c0 <pmm_init+0x5aa>
ffffffffc02021d0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021d2:	b20fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc02021d6:	000bb783          	ld	a5,0(s7)
ffffffffc02021da:	6522                	ld	a0,8(sp)
ffffffffc02021dc:	4585                	li	a1,1
ffffffffc02021de:	739c                	ld	a5,32(a5)
ffffffffc02021e0:	9782                	jalr	a5
        intr_enable();
ffffffffc02021e2:	b0afe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02021e6:	b555                	j	ffffffffc020208a <pmm_init+0x574>
        intr_disable();
ffffffffc02021e8:	b0afe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc02021ec:	000bb783          	ld	a5,0(s7)
ffffffffc02021f0:	4585                	li	a1,1
ffffffffc02021f2:	8556                	mv	a0,s5
ffffffffc02021f4:	739c                	ld	a5,32(a5)
ffffffffc02021f6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021f8:	af4fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02021fc:	bda9                	j	ffffffffc0202056 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02021fe:	00003697          	auipc	a3,0x3
ffffffffc0202202:	59268693          	addi	a3,a3,1426 # ffffffffc0205790 <default_pmm_manager+0x4c0>
ffffffffc0202206:	00003617          	auipc	a2,0x3
ffffffffc020220a:	d1a60613          	addi	a2,a2,-742 # ffffffffc0204f20 <commands+0x798>
ffffffffc020220e:	1ce00593          	li	a1,462
ffffffffc0202212:	00003517          	auipc	a0,0x3
ffffffffc0202216:	17650513          	addi	a0,a0,374 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020221a:	95efe0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020221e:	00003697          	auipc	a3,0x3
ffffffffc0202222:	53268693          	addi	a3,a3,1330 # ffffffffc0205750 <default_pmm_manager+0x480>
ffffffffc0202226:	00003617          	auipc	a2,0x3
ffffffffc020222a:	cfa60613          	addi	a2,a2,-774 # ffffffffc0204f20 <commands+0x798>
ffffffffc020222e:	1cd00593          	li	a1,461
ffffffffc0202232:	00003517          	auipc	a0,0x3
ffffffffc0202236:	15650513          	addi	a0,a0,342 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020223a:	93efe0ef          	jal	ra,ffffffffc0200378 <__panic>
ffffffffc020223e:	86a2                	mv	a3,s0
ffffffffc0202240:	00003617          	auipc	a2,0x3
ffffffffc0202244:	12060613          	addi	a2,a2,288 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc0202248:	1cd00593          	li	a1,461
ffffffffc020224c:	00003517          	auipc	a0,0x3
ffffffffc0202250:	13c50513          	addi	a0,a0,316 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202254:	924fe0ef          	jal	ra,ffffffffc0200378 <__panic>
ffffffffc0202258:	b90ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020225c:	00003617          	auipc	a2,0x3
ffffffffc0202260:	1c460613          	addi	a2,a2,452 # ffffffffc0205420 <default_pmm_manager+0x150>
ffffffffc0202264:	07700593          	li	a1,119
ffffffffc0202268:	00003517          	auipc	a0,0x3
ffffffffc020226c:	12050513          	addi	a0,a0,288 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202270:	908fe0ef          	jal	ra,ffffffffc0200378 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202274:	00003617          	auipc	a2,0x3
ffffffffc0202278:	1ac60613          	addi	a2,a2,428 # ffffffffc0205420 <default_pmm_manager+0x150>
ffffffffc020227c:	0bd00593          	li	a1,189
ffffffffc0202280:	00003517          	auipc	a0,0x3
ffffffffc0202284:	10850513          	addi	a0,a0,264 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202288:	8f0fe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020228c:	00003697          	auipc	a3,0x3
ffffffffc0202290:	1fc68693          	addi	a3,a3,508 # ffffffffc0205488 <default_pmm_manager+0x1b8>
ffffffffc0202294:	00003617          	auipc	a2,0x3
ffffffffc0202298:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204f20 <commands+0x798>
ffffffffc020229c:	19300593          	li	a1,403
ffffffffc02022a0:	00003517          	auipc	a0,0x3
ffffffffc02022a4:	0e850513          	addi	a0,a0,232 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02022a8:	8d0fe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02022ac:	00003697          	auipc	a3,0x3
ffffffffc02022b0:	1bc68693          	addi	a3,a3,444 # ffffffffc0205468 <default_pmm_manager+0x198>
ffffffffc02022b4:	00003617          	auipc	a2,0x3
ffffffffc02022b8:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204f20 <commands+0x798>
ffffffffc02022bc:	19200593          	li	a1,402
ffffffffc02022c0:	00003517          	auipc	a0,0x3
ffffffffc02022c4:	0c850513          	addi	a0,a0,200 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02022c8:	8b0fe0ef          	jal	ra,ffffffffc0200378 <__panic>
ffffffffc02022cc:	b38ff0ef          	jal	ra,ffffffffc0201604 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02022d0:	00003697          	auipc	a3,0x3
ffffffffc02022d4:	24868693          	addi	a3,a3,584 # ffffffffc0205518 <default_pmm_manager+0x248>
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	c4860613          	addi	a2,a2,-952 # ffffffffc0204f20 <commands+0x798>
ffffffffc02022e0:	19a00593          	li	a1,410
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	0a450513          	addi	a0,a0,164 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02022ec:	88cfe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02022f0:	00003697          	auipc	a3,0x3
ffffffffc02022f4:	1f868693          	addi	a3,a3,504 # ffffffffc02054e8 <default_pmm_manager+0x218>
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	c2860613          	addi	a2,a2,-984 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202300:	19800593          	li	a1,408
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	08450513          	addi	a0,a0,132 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020230c:	86cfe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202310:	00003697          	auipc	a3,0x3
ffffffffc0202314:	1b068693          	addi	a3,a3,432 # ffffffffc02054c0 <default_pmm_manager+0x1f0>
ffffffffc0202318:	00003617          	auipc	a2,0x3
ffffffffc020231c:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202320:	19400593          	li	a1,404
ffffffffc0202324:	00003517          	auipc	a0,0x3
ffffffffc0202328:	06450513          	addi	a0,a0,100 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020232c:	84cfe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202330:	00003697          	auipc	a3,0x3
ffffffffc0202334:	27068693          	addi	a3,a3,624 # ffffffffc02055a0 <default_pmm_manager+0x2d0>
ffffffffc0202338:	00003617          	auipc	a2,0x3
ffffffffc020233c:	be860613          	addi	a2,a2,-1048 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202340:	1a300593          	li	a1,419
ffffffffc0202344:	00003517          	auipc	a0,0x3
ffffffffc0202348:	04450513          	addi	a0,a0,68 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020234c:	82cfe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202350:	00003697          	auipc	a3,0x3
ffffffffc0202354:	2f068693          	addi	a3,a3,752 # ffffffffc0205640 <default_pmm_manager+0x370>
ffffffffc0202358:	00003617          	auipc	a2,0x3
ffffffffc020235c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202360:	1a800593          	li	a1,424
ffffffffc0202364:	00003517          	auipc	a0,0x3
ffffffffc0202368:	02450513          	addi	a0,a0,36 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020236c:	80cfe0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202370:	00003697          	auipc	a3,0x3
ffffffffc0202374:	20868693          	addi	a3,a3,520 # ffffffffc0205578 <default_pmm_manager+0x2a8>
ffffffffc0202378:	00003617          	auipc	a2,0x3
ffffffffc020237c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202380:	1a000593          	li	a1,416
ffffffffc0202384:	00003517          	auipc	a0,0x3
ffffffffc0202388:	00450513          	addi	a0,a0,4 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020238c:	fedfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202390:	86d6                	mv	a3,s5
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	fce60613          	addi	a2,a2,-50 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc020239a:	19f00593          	li	a1,415
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	fea50513          	addi	a0,a0,-22 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02023a6:	fd3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	22e68693          	addi	a3,a3,558 # ffffffffc02055d8 <default_pmm_manager+0x308>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0204f20 <commands+0x798>
ffffffffc02023ba:	1ad00593          	li	a1,429
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	fca50513          	addi	a0,a0,-54 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02023c6:	fb3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	2d668693          	addi	a3,a3,726 # ffffffffc02056a0 <default_pmm_manager+0x3d0>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0204f20 <commands+0x798>
ffffffffc02023da:	1ac00593          	li	a1,428
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	faa50513          	addi	a0,a0,-86 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02023e6:	f93fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	29e68693          	addi	a3,a3,670 # ffffffffc0205688 <default_pmm_manager+0x3b8>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0204f20 <commands+0x798>
ffffffffc02023fa:	1ab00593          	li	a1,427
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	f8a50513          	addi	a0,a0,-118 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202406:	f73fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	24e68693          	addi	a3,a3,590 # ffffffffc0205658 <default_pmm_manager+0x388>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0204f20 <commands+0x798>
ffffffffc020241a:	1aa00593          	li	a1,426
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	f6a50513          	addi	a0,a0,-150 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202426:	f53fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	3e668693          	addi	a3,a3,998 # ffffffffc0205810 <default_pmm_manager+0x540>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	aee60613          	addi	a2,a2,-1298 # ffffffffc0204f20 <commands+0x798>
ffffffffc020243a:	1d800593          	li	a1,472
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	f4a50513          	addi	a0,a0,-182 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202446:	f33fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	1de68693          	addi	a3,a3,478 # ffffffffc0205628 <default_pmm_manager+0x358>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	ace60613          	addi	a2,a2,-1330 # ffffffffc0204f20 <commands+0x798>
ffffffffc020245a:	1a700593          	li	a1,423
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	f2a50513          	addi	a0,a0,-214 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202466:	f13fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	1ae68693          	addi	a3,a3,430 # ffffffffc0205618 <default_pmm_manager+0x348>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	aae60613          	addi	a2,a2,-1362 # ffffffffc0204f20 <commands+0x798>
ffffffffc020247a:	1a600593          	li	a1,422
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	f0a50513          	addi	a0,a0,-246 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202486:	ef3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	28668693          	addi	a3,a3,646 # ffffffffc0205710 <default_pmm_manager+0x440>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0204f20 <commands+0x798>
ffffffffc020249a:	1e800593          	li	a1,488
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	eea50513          	addi	a0,a0,-278 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02024a6:	ed3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	15e68693          	addi	a3,a3,350 # ffffffffc0205608 <default_pmm_manager+0x338>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204f20 <commands+0x798>
ffffffffc02024ba:	1a500593          	li	a1,421
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	eca50513          	addi	a0,a0,-310 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02024c6:	eb3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	09668693          	addi	a3,a3,150 # ffffffffc0205560 <default_pmm_manager+0x290>
ffffffffc02024d2:	00003617          	auipc	a2,0x3
ffffffffc02024d6:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204f20 <commands+0x798>
ffffffffc02024da:	1b200593          	li	a1,434
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	eaa50513          	addi	a0,a0,-342 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02024e6:	e93fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	1ce68693          	addi	a3,a3,462 # ffffffffc02056b8 <default_pmm_manager+0x3e8>
ffffffffc02024f2:	00003617          	auipc	a2,0x3
ffffffffc02024f6:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204f20 <commands+0x798>
ffffffffc02024fa:	1af00593          	li	a1,431
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	e8a50513          	addi	a0,a0,-374 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202506:	e73fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	03e68693          	addi	a3,a3,62 # ffffffffc0205548 <default_pmm_manager+0x278>
ffffffffc0202512:	00003617          	auipc	a2,0x3
ffffffffc0202516:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204f20 <commands+0x798>
ffffffffc020251a:	1ae00593          	li	a1,430
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	e6a50513          	addi	a0,a0,-406 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202526:	e53fd0ef          	jal	ra,ffffffffc0200378 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020252a:	00003617          	auipc	a2,0x3
ffffffffc020252e:	e3660613          	addi	a2,a2,-458 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc0202532:	06a00593          	li	a1,106
ffffffffc0202536:	00003517          	auipc	a0,0x3
ffffffffc020253a:	df250513          	addi	a0,a0,-526 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc020253e:	e3bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202542:	00003697          	auipc	a3,0x3
ffffffffc0202546:	1a668693          	addi	a3,a3,422 # ffffffffc02056e8 <default_pmm_manager+0x418>
ffffffffc020254a:	00003617          	auipc	a2,0x3
ffffffffc020254e:	9d660613          	addi	a2,a2,-1578 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202552:	1b900593          	li	a1,441
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	e3250513          	addi	a0,a0,-462 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020255e:	e1bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202562:	00003697          	auipc	a3,0x3
ffffffffc0202566:	13e68693          	addi	a3,a3,318 # ffffffffc02056a0 <default_pmm_manager+0x3d0>
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	9b660613          	addi	a2,a2,-1610 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202572:	1b700593          	li	a1,439
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	e1250513          	addi	a0,a0,-494 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020257e:	dfbfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	14e68693          	addi	a3,a3,334 # ffffffffc02056d0 <default_pmm_manager+0x400>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	99660613          	addi	a2,a2,-1642 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202592:	1b600593          	li	a1,438
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	df250513          	addi	a0,a0,-526 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020259e:	ddbfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	0fe68693          	addi	a3,a3,254 # ffffffffc02056a0 <default_pmm_manager+0x3d0>
ffffffffc02025aa:	00003617          	auipc	a2,0x3
ffffffffc02025ae:	97660613          	addi	a2,a2,-1674 # ffffffffc0204f20 <commands+0x798>
ffffffffc02025b2:	1b300593          	li	a1,435
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	dd250513          	addi	a0,a0,-558 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02025be:	dbbfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	23668693          	addi	a3,a3,566 # ffffffffc02057f8 <default_pmm_manager+0x528>
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	95660613          	addi	a2,a2,-1706 # ffffffffc0204f20 <commands+0x798>
ffffffffc02025d2:	1d700593          	li	a1,471
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	db250513          	addi	a0,a0,-590 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02025de:	d9bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	1de68693          	addi	a3,a3,478 # ffffffffc02057c0 <default_pmm_manager+0x4f0>
ffffffffc02025ea:	00003617          	auipc	a2,0x3
ffffffffc02025ee:	93660613          	addi	a2,a2,-1738 # ffffffffc0204f20 <commands+0x798>
ffffffffc02025f2:	1d600593          	li	a1,470
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	d9250513          	addi	a0,a0,-622 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02025fe:	d7bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	1a668693          	addi	a3,a3,422 # ffffffffc02057a8 <default_pmm_manager+0x4d8>
ffffffffc020260a:	00003617          	auipc	a2,0x3
ffffffffc020260e:	91660613          	addi	a2,a2,-1770 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202612:	1d200593          	li	a1,466
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	d7250513          	addi	a0,a0,-654 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020261e:	d5bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202622:	00003697          	auipc	a3,0x3
ffffffffc0202626:	0ee68693          	addi	a3,a3,238 # ffffffffc0205710 <default_pmm_manager+0x440>
ffffffffc020262a:	00003617          	auipc	a2,0x3
ffffffffc020262e:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202632:	1c000593          	li	a1,448
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	d5250513          	addi	a0,a0,-686 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020263e:	d3bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202642:	00003697          	auipc	a3,0x3
ffffffffc0202646:	f0668693          	addi	a3,a3,-250 # ffffffffc0205548 <default_pmm_manager+0x278>
ffffffffc020264a:	00003617          	auipc	a2,0x3
ffffffffc020264e:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202652:	19b00593          	li	a1,411
ffffffffc0202656:	00003517          	auipc	a0,0x3
ffffffffc020265a:	d3250513          	addi	a0,a0,-718 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020265e:	d1bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202662:	00003617          	auipc	a2,0x3
ffffffffc0202666:	cfe60613          	addi	a2,a2,-770 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc020266a:	19e00593          	li	a1,414
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	d1a50513          	addi	a0,a0,-742 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202676:	d03fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020267a:	00003697          	auipc	a3,0x3
ffffffffc020267e:	ee668693          	addi	a3,a3,-282 # ffffffffc0205560 <default_pmm_manager+0x290>
ffffffffc0202682:	00003617          	auipc	a2,0x3
ffffffffc0202686:	89e60613          	addi	a2,a2,-1890 # ffffffffc0204f20 <commands+0x798>
ffffffffc020268a:	19c00593          	li	a1,412
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	cfa50513          	addi	a0,a0,-774 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202696:	ce3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020269a:	00003697          	auipc	a3,0x3
ffffffffc020269e:	f3e68693          	addi	a3,a3,-194 # ffffffffc02055d8 <default_pmm_manager+0x308>
ffffffffc02026a2:	00003617          	auipc	a2,0x3
ffffffffc02026a6:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204f20 <commands+0x798>
ffffffffc02026aa:	1a400593          	li	a1,420
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	cda50513          	addi	a0,a0,-806 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02026b6:	cc3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02026ba:	00003697          	auipc	a3,0x3
ffffffffc02026be:	1fe68693          	addi	a3,a3,510 # ffffffffc02058b8 <default_pmm_manager+0x5e8>
ffffffffc02026c2:	00003617          	auipc	a2,0x3
ffffffffc02026c6:	85e60613          	addi	a2,a2,-1954 # ffffffffc0204f20 <commands+0x798>
ffffffffc02026ca:	1e000593          	li	a1,480
ffffffffc02026ce:	00003517          	auipc	a0,0x3
ffffffffc02026d2:	cba50513          	addi	a0,a0,-838 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02026d6:	ca3fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02026da:	00003697          	auipc	a3,0x3
ffffffffc02026de:	1a668693          	addi	a3,a3,422 # ffffffffc0205880 <default_pmm_manager+0x5b0>
ffffffffc02026e2:	00003617          	auipc	a2,0x3
ffffffffc02026e6:	83e60613          	addi	a2,a2,-1986 # ffffffffc0204f20 <commands+0x798>
ffffffffc02026ea:	1dd00593          	li	a1,477
ffffffffc02026ee:	00003517          	auipc	a0,0x3
ffffffffc02026f2:	c9a50513          	addi	a0,a0,-870 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc02026f6:	c83fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02026fa:	00003697          	auipc	a3,0x3
ffffffffc02026fe:	15668693          	addi	a3,a3,342 # ffffffffc0205850 <default_pmm_manager+0x580>
ffffffffc0202702:	00003617          	auipc	a2,0x3
ffffffffc0202706:	81e60613          	addi	a2,a2,-2018 # ffffffffc0204f20 <commands+0x798>
ffffffffc020270a:	1d900593          	li	a1,473
ffffffffc020270e:	00003517          	auipc	a0,0x3
ffffffffc0202712:	c7a50513          	addi	a0,a0,-902 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202716:	c63fd0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc020271a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc020271a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc020271e:	8082                	ret

ffffffffc0202720 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202720:	7179                	addi	sp,sp,-48
ffffffffc0202722:	e84a                	sd	s2,16(sp)
ffffffffc0202724:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202726:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202728:	f022                	sd	s0,32(sp)
ffffffffc020272a:	ec26                	sd	s1,24(sp)
ffffffffc020272c:	e44e                	sd	s3,8(sp)
ffffffffc020272e:	f406                	sd	ra,40(sp)
ffffffffc0202730:	84ae                	mv	s1,a1
ffffffffc0202732:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202734:	eedfe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0202738:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020273a:	cd09                	beqz	a0,ffffffffc0202754 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020273c:	85aa                	mv	a1,a0
ffffffffc020273e:	86ce                	mv	a3,s3
ffffffffc0202740:	8626                	mv	a2,s1
ffffffffc0202742:	854a                	mv	a0,s2
ffffffffc0202744:	ad2ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0202748:	ed21                	bnez	a0,ffffffffc02027a0 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020274a:	0000f797          	auipc	a5,0xf
ffffffffc020274e:	e0e7a783          	lw	a5,-498(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0202752:	eb89                	bnez	a5,ffffffffc0202764 <pgdir_alloc_page+0x44>
}
ffffffffc0202754:	70a2                	ld	ra,40(sp)
ffffffffc0202756:	8522                	mv	a0,s0
ffffffffc0202758:	7402                	ld	s0,32(sp)
ffffffffc020275a:	64e2                	ld	s1,24(sp)
ffffffffc020275c:	6942                	ld	s2,16(sp)
ffffffffc020275e:	69a2                	ld	s3,8(sp)
ffffffffc0202760:	6145                	addi	sp,sp,48
ffffffffc0202762:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202764:	4681                	li	a3,0
ffffffffc0202766:	8622                	mv	a2,s0
ffffffffc0202768:	85a6                	mv	a1,s1
ffffffffc020276a:	0000f517          	auipc	a0,0xf
ffffffffc020276e:	dfe53503          	ld	a0,-514(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0202772:	07f000ef          	jal	ra,ffffffffc0202ff0 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202776:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202778:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020277a:	4785                	li	a5,1
ffffffffc020277c:	fcf70ce3          	beq	a4,a5,ffffffffc0202754 <pgdir_alloc_page+0x34>
ffffffffc0202780:	00003697          	auipc	a3,0x3
ffffffffc0202784:	18068693          	addi	a3,a3,384 # ffffffffc0205900 <default_pmm_manager+0x630>
ffffffffc0202788:	00002617          	auipc	a2,0x2
ffffffffc020278c:	79860613          	addi	a2,a2,1944 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202790:	17a00593          	li	a1,378
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	bf450513          	addi	a0,a0,-1036 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020279c:	bddfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02027a0:	100027f3          	csrr	a5,sstatus
ffffffffc02027a4:	8b89                	andi	a5,a5,2
ffffffffc02027a6:	eb99                	bnez	a5,ffffffffc02027bc <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027a8:	0000f797          	auipc	a5,0xf
ffffffffc02027ac:	d907b783          	ld	a5,-624(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02027b0:	739c                	ld	a5,32(a5)
ffffffffc02027b2:	8522                	mv	a0,s0
ffffffffc02027b4:	4585                	li	a1,1
ffffffffc02027b6:	9782                	jalr	a5
            return NULL;
ffffffffc02027b8:	4401                	li	s0,0
ffffffffc02027ba:	bf69                	j	ffffffffc0202754 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc02027bc:	d37fd0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027c0:	0000f797          	auipc	a5,0xf
ffffffffc02027c4:	d787b783          	ld	a5,-648(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02027c8:	739c                	ld	a5,32(a5)
ffffffffc02027ca:	8522                	mv	a0,s0
ffffffffc02027cc:	4585                	li	a1,1
ffffffffc02027ce:	9782                	jalr	a5
            return NULL;
ffffffffc02027d0:	4401                	li	s0,0
        intr_enable();
ffffffffc02027d2:	d1bfd0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02027d6:	bfbd                	j	ffffffffc0202754 <pgdir_alloc_page+0x34>

ffffffffc02027d8 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02027d8:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027da:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02027dc:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027de:	fff50713          	addi	a4,a0,-1
ffffffffc02027e2:	17f9                	addi	a5,a5,-2
ffffffffc02027e4:	04e7ea63          	bltu	a5,a4,ffffffffc0202838 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027e8:	6785                	lui	a5,0x1
ffffffffc02027ea:	17fd                	addi	a5,a5,-1
ffffffffc02027ec:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027ee:	8131                	srli	a0,a0,0xc
ffffffffc02027f0:	e31fe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
    assert(base != NULL);
ffffffffc02027f4:	cd3d                	beqz	a0,ffffffffc0202872 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027f6:	0000f797          	auipc	a5,0xf
ffffffffc02027fa:	d3a7b783          	ld	a5,-710(a5) # ffffffffc0211530 <pages>
ffffffffc02027fe:	8d1d                	sub	a0,a0,a5
ffffffffc0202800:	00004697          	auipc	a3,0x4
ffffffffc0202804:	ca86b683          	ld	a3,-856(a3) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0202808:	850d                	srai	a0,a0,0x3
ffffffffc020280a:	02d50533          	mul	a0,a0,a3
ffffffffc020280e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202812:	0000f717          	auipc	a4,0xf
ffffffffc0202816:	d1673703          	ld	a4,-746(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020281a:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020281c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202820:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202822:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202824:	02e7fa63          	bgeu	a5,a4,ffffffffc0202858 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0202828:	60a2                	ld	ra,8(sp)
ffffffffc020282a:	0000f797          	auipc	a5,0xf
ffffffffc020282e:	d167b783          	ld	a5,-746(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0202832:	953e                	add	a0,a0,a5
ffffffffc0202834:	0141                	addi	sp,sp,16
ffffffffc0202836:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202838:	00003697          	auipc	a3,0x3
ffffffffc020283c:	0e068693          	addi	a3,a3,224 # ffffffffc0205918 <default_pmm_manager+0x648>
ffffffffc0202840:	00002617          	auipc	a2,0x2
ffffffffc0202844:	6e060613          	addi	a2,a2,1760 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202848:	1f000593          	li	a1,496
ffffffffc020284c:	00003517          	auipc	a0,0x3
ffffffffc0202850:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202854:	b25fd0ef          	jal	ra,ffffffffc0200378 <__panic>
ffffffffc0202858:	86aa                	mv	a3,a0
ffffffffc020285a:	00003617          	auipc	a2,0x3
ffffffffc020285e:	b0660613          	addi	a2,a2,-1274 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc0202862:	06a00593          	li	a1,106
ffffffffc0202866:	00003517          	auipc	a0,0x3
ffffffffc020286a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc020286e:	b0bfd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(base != NULL);
ffffffffc0202872:	00003697          	auipc	a3,0x3
ffffffffc0202876:	0c668693          	addi	a3,a3,198 # ffffffffc0205938 <default_pmm_manager+0x668>
ffffffffc020287a:	00002617          	auipc	a2,0x2
ffffffffc020287e:	6a660613          	addi	a2,a2,1702 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202882:	1f300593          	li	a1,499
ffffffffc0202886:	00003517          	auipc	a0,0x3
ffffffffc020288a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc020288e:	aebfd0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0202892 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202892:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202894:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202896:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202898:	fff58713          	addi	a4,a1,-1
ffffffffc020289c:	17f9                	addi	a5,a5,-2
ffffffffc020289e:	0ae7ee63          	bltu	a5,a4,ffffffffc020295a <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc02028a2:	cd41                	beqz	a0,ffffffffc020293a <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02028a4:	6785                	lui	a5,0x1
ffffffffc02028a6:	17fd                	addi	a5,a5,-1
ffffffffc02028a8:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028aa:	c02007b7          	lui	a5,0xc0200
ffffffffc02028ae:	81b1                	srli	a1,a1,0xc
ffffffffc02028b0:	06f56863          	bltu	a0,a5,ffffffffc0202920 <kfree+0x8e>
ffffffffc02028b4:	0000f697          	auipc	a3,0xf
ffffffffc02028b8:	c8c6b683          	ld	a3,-884(a3) # ffffffffc0211540 <va_pa_offset>
ffffffffc02028bc:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc02028be:	8131                	srli	a0,a0,0xc
ffffffffc02028c0:	0000f797          	auipc	a5,0xf
ffffffffc02028c4:	c687b783          	ld	a5,-920(a5) # ffffffffc0211528 <npage>
ffffffffc02028c8:	04f57a63          	bgeu	a0,a5,ffffffffc020291c <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc02028cc:	fff806b7          	lui	a3,0xfff80
ffffffffc02028d0:	9536                	add	a0,a0,a3
ffffffffc02028d2:	00351793          	slli	a5,a0,0x3
ffffffffc02028d6:	953e                	add	a0,a0,a5
ffffffffc02028d8:	050e                	slli	a0,a0,0x3
ffffffffc02028da:	0000f797          	auipc	a5,0xf
ffffffffc02028de:	c567b783          	ld	a5,-938(a5) # ffffffffc0211530 <pages>
ffffffffc02028e2:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028e4:	100027f3          	csrr	a5,sstatus
ffffffffc02028e8:	8b89                	andi	a5,a5,2
ffffffffc02028ea:	eb89                	bnez	a5,ffffffffc02028fc <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02028ec:	0000f797          	auipc	a5,0xf
ffffffffc02028f0:	c4c7b783          	ld	a5,-948(a5) # ffffffffc0211538 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02028f4:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02028f6:	739c                	ld	a5,32(a5)
}
ffffffffc02028f8:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02028fa:	8782                	jr	a5
        intr_disable();
ffffffffc02028fc:	e42a                	sd	a0,8(sp)
ffffffffc02028fe:	e02e                	sd	a1,0(sp)
ffffffffc0202900:	bf3fd0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0202904:	0000f797          	auipc	a5,0xf
ffffffffc0202908:	c347b783          	ld	a5,-972(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc020290c:	6582                	ld	a1,0(sp)
ffffffffc020290e:	6522                	ld	a0,8(sp)
ffffffffc0202910:	739c                	ld	a5,32(a5)
ffffffffc0202912:	9782                	jalr	a5
}
ffffffffc0202914:	60e2                	ld	ra,24(sp)
ffffffffc0202916:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202918:	bd5fd06f          	j	ffffffffc02004ec <intr_enable>
ffffffffc020291c:	ccdfe0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202920:	86aa                	mv	a3,a0
ffffffffc0202922:	00003617          	auipc	a2,0x3
ffffffffc0202926:	afe60613          	addi	a2,a2,-1282 # ffffffffc0205420 <default_pmm_manager+0x150>
ffffffffc020292a:	06c00593          	li	a1,108
ffffffffc020292e:	00003517          	auipc	a0,0x3
ffffffffc0202932:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc0202936:	a43fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(ptr != NULL);
ffffffffc020293a:	00003697          	auipc	a3,0x3
ffffffffc020293e:	00e68693          	addi	a3,a3,14 # ffffffffc0205948 <default_pmm_manager+0x678>
ffffffffc0202942:	00002617          	auipc	a2,0x2
ffffffffc0202946:	5de60613          	addi	a2,a2,1502 # ffffffffc0204f20 <commands+0x798>
ffffffffc020294a:	1fa00593          	li	a1,506
ffffffffc020294e:	00003517          	auipc	a0,0x3
ffffffffc0202952:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202956:	a23fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020295a:	00003697          	auipc	a3,0x3
ffffffffc020295e:	fbe68693          	addi	a3,a3,-66 # ffffffffc0205918 <default_pmm_manager+0x648>
ffffffffc0202962:	00002617          	auipc	a2,0x2
ffffffffc0202966:	5be60613          	addi	a2,a2,1470 # ffffffffc0204f20 <commands+0x798>
ffffffffc020296a:	1f900593          	li	a1,505
ffffffffc020296e:	00003517          	auipc	a0,0x3
ffffffffc0202972:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0205388 <default_pmm_manager+0xb8>
ffffffffc0202976:	a03fd0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc020297a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020297a:	7135                	addi	sp,sp,-160
ffffffffc020297c:	ed06                	sd	ra,152(sp)
ffffffffc020297e:	e922                	sd	s0,144(sp)
ffffffffc0202980:	e526                	sd	s1,136(sp)
ffffffffc0202982:	e14a                	sd	s2,128(sp)
ffffffffc0202984:	fcce                	sd	s3,120(sp)
ffffffffc0202986:	f8d2                	sd	s4,112(sp)
ffffffffc0202988:	f4d6                	sd	s5,104(sp)
ffffffffc020298a:	f0da                	sd	s6,96(sp)
ffffffffc020298c:	ecde                	sd	s7,88(sp)
ffffffffc020298e:	e8e2                	sd	s8,80(sp)
ffffffffc0202990:	e4e6                	sd	s9,72(sp)
ffffffffc0202992:	e0ea                	sd	s10,64(sp)
ffffffffc0202994:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202996:	4e0010ef          	jal	ra,ffffffffc0203e76 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020299a:	0000f697          	auipc	a3,0xf
ffffffffc020299e:	bae6b683          	ld	a3,-1106(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc02029a2:	010007b7          	lui	a5,0x1000
ffffffffc02029a6:	ff968713          	addi	a4,a3,-7
ffffffffc02029aa:	17e1                	addi	a5,a5,-8
ffffffffc02029ac:	3ee7e063          	bltu	a5,a4,ffffffffc0202d8c <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     //sm = &swap_manager_fifo;//use first in first out Page Replacement Algorithm
     //sm = &swap_manager_clock;//use clock  Page Replacement Algorithm
     sm = &swap_manager_lru;//use lru Page Replacement Algorithm
ffffffffc02029b0:	00007797          	auipc	a5,0x7
ffffffffc02029b4:	65078793          	addi	a5,a5,1616 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc02029b8:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;//use lru Page Replacement Algorithm
ffffffffc02029ba:	0000fb17          	auipc	s6,0xf
ffffffffc02029be:	b96b0b13          	addi	s6,s6,-1130 # ffffffffc0211550 <sm>
ffffffffc02029c2:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02029c6:	9702                	jalr	a4
ffffffffc02029c8:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02029ca:	c10d                	beqz	a0,ffffffffc02029ec <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02029cc:	60ea                	ld	ra,152(sp)
ffffffffc02029ce:	644a                	ld	s0,144(sp)
ffffffffc02029d0:	64aa                	ld	s1,136(sp)
ffffffffc02029d2:	690a                	ld	s2,128(sp)
ffffffffc02029d4:	7a46                	ld	s4,112(sp)
ffffffffc02029d6:	7aa6                	ld	s5,104(sp)
ffffffffc02029d8:	7b06                	ld	s6,96(sp)
ffffffffc02029da:	6be6                	ld	s7,88(sp)
ffffffffc02029dc:	6c46                	ld	s8,80(sp)
ffffffffc02029de:	6ca6                	ld	s9,72(sp)
ffffffffc02029e0:	6d06                	ld	s10,64(sp)
ffffffffc02029e2:	7de2                	ld	s11,56(sp)
ffffffffc02029e4:	854e                	mv	a0,s3
ffffffffc02029e6:	79e6                	ld	s3,120(sp)
ffffffffc02029e8:	610d                	addi	sp,sp,160
ffffffffc02029ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029ec:	000b3783          	ld	a5,0(s6)
ffffffffc02029f0:	00003517          	auipc	a0,0x3
ffffffffc02029f4:	f9850513          	addi	a0,a0,-104 # ffffffffc0205988 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc02029f8:	0000e497          	auipc	s1,0xe
ffffffffc02029fc:	64848493          	addi	s1,s1,1608 # ffffffffc0211040 <free_area>
ffffffffc0202a00:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202a02:	4785                	li	a5,1
ffffffffc0202a04:	0000f717          	auipc	a4,0xf
ffffffffc0202a08:	b4f72a23          	sw	a5,-1196(a4) # ffffffffc0211558 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202a0c:	eb2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202a10:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202a12:	4401                	li	s0,0
ffffffffc0202a14:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a16:	2c978163          	beq	a5,s1,ffffffffc0202cd8 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202a1a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202a1e:	8b09                	andi	a4,a4,2
ffffffffc0202a20:	2a070e63          	beqz	a4,ffffffffc0202cdc <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0202a24:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202a28:	679c                	ld	a5,8(a5)
ffffffffc0202a2a:	2d05                	addiw	s10,s10,1
ffffffffc0202a2c:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a2e:	fe9796e3          	bne	a5,s1,ffffffffc0202a1a <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202a32:	8922                	mv	s2,s0
ffffffffc0202a34:	cbffe0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc0202a38:	47251663          	bne	a0,s2,ffffffffc0202ea4 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202a3c:	8622                	mv	a2,s0
ffffffffc0202a3e:	85ea                	mv	a1,s10
ffffffffc0202a40:	00003517          	auipc	a0,0x3
ffffffffc0202a44:	f6050513          	addi	a0,a0,-160 # ffffffffc02059a0 <default_pmm_manager+0x6d0>
ffffffffc0202a48:	e76fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202a4c:	3a5000ef          	jal	ra,ffffffffc02035f0 <mm_create>
ffffffffc0202a50:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202a52:	52050963          	beqz	a0,ffffffffc0202f84 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a56:	0000f797          	auipc	a5,0xf
ffffffffc0202a5a:	b1278793          	addi	a5,a5,-1262 # ffffffffc0211568 <check_mm_struct>
ffffffffc0202a5e:	6398                	ld	a4,0(a5)
ffffffffc0202a60:	54071263          	bnez	a4,ffffffffc0202fa4 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a64:	0000fb97          	auipc	s7,0xf
ffffffffc0202a68:	abcbbb83          	ld	s7,-1348(s7) # ffffffffc0211520 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a6c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a70:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a72:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a76:	3c071763          	bnez	a4,ffffffffc0202e44 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a7a:	6599                	lui	a1,0x6
ffffffffc0202a7c:	460d                	li	a2,3
ffffffffc0202a7e:	6505                	lui	a0,0x1
ffffffffc0202a80:	3b9000ef          	jal	ra,ffffffffc0203638 <vma_create>
ffffffffc0202a84:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a86:	3c050f63          	beqz	a0,ffffffffc0202e64 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a8a:	8556                	mv	a0,s5
ffffffffc0202a8c:	41b000ef          	jal	ra,ffffffffc02036a6 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a90:	00003517          	auipc	a0,0x3
ffffffffc0202a94:	f8050513          	addi	a0,a0,-128 # ffffffffc0205a10 <default_pmm_manager+0x740>
ffffffffc0202a98:	e26fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a9c:	018ab503          	ld	a0,24(s5)
ffffffffc0202aa0:	4605                	li	a2,1
ffffffffc0202aa2:	6585                	lui	a1,0x1
ffffffffc0202aa4:	c89fe0ef          	jal	ra,ffffffffc020172c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202aa8:	3c050e63          	beqz	a0,ffffffffc0202e84 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202aac:	00003517          	auipc	a0,0x3
ffffffffc0202ab0:	fb450513          	addi	a0,a0,-76 # ffffffffc0205a60 <default_pmm_manager+0x790>
ffffffffc0202ab4:	0000e917          	auipc	s2,0xe
ffffffffc0202ab8:	5c490913          	addi	s2,s2,1476 # ffffffffc0211078 <check_rp>
ffffffffc0202abc:	e02fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ac0:	0000ea17          	auipc	s4,0xe
ffffffffc0202ac4:	5d8a0a13          	addi	s4,s4,1496 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202ac8:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202aca:	4505                	li	a0,1
ffffffffc0202acc:	b55fe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0202ad0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202ad4:	28050c63          	beqz	a0,ffffffffc0202d6c <swap_init+0x3f2>
ffffffffc0202ad8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202ada:	8b89                	andi	a5,a5,2
ffffffffc0202adc:	26079863          	bnez	a5,ffffffffc0202d4c <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ae0:	0c21                	addi	s8,s8,8
ffffffffc0202ae2:	ff4c14e3          	bne	s8,s4,ffffffffc0202aca <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202ae6:	609c                	ld	a5,0(s1)
ffffffffc0202ae8:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202aec:	e084                	sd	s1,0(s1)
ffffffffc0202aee:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202af0:	489c                	lw	a5,16(s1)
ffffffffc0202af2:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202af4:	0000ec17          	auipc	s8,0xe
ffffffffc0202af8:	584c0c13          	addi	s8,s8,1412 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202afc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202afe:	0000e797          	auipc	a5,0xe
ffffffffc0202b02:	5407a923          	sw	zero,1362(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202b06:	000c3503          	ld	a0,0(s8)
ffffffffc0202b0a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b0c:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202b0e:	ba5fe0ef          	jal	ra,ffffffffc02016b2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b12:	ff4c1ae3          	bne	s8,s4,ffffffffc0202b06 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202b16:	0104ac03          	lw	s8,16(s1)
ffffffffc0202b1a:	4791                	li	a5,4
ffffffffc0202b1c:	4afc1463          	bne	s8,a5,ffffffffc0202fc4 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202b20:	00003517          	auipc	a0,0x3
ffffffffc0202b24:	fc850513          	addi	a0,a0,-56 # ffffffffc0205ae8 <default_pmm_manager+0x818>
ffffffffc0202b28:	d96fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b2c:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202b2e:	0000f797          	auipc	a5,0xf
ffffffffc0202b32:	a407a123          	sw	zero,-1470(a5) # ffffffffc0211570 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b36:	4529                	li	a0,10
ffffffffc0202b38:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202b3c:	0000f597          	auipc	a1,0xf
ffffffffc0202b40:	a345a583          	lw	a1,-1484(a1) # ffffffffc0211570 <pgfault_num>
ffffffffc0202b44:	4805                	li	a6,1
ffffffffc0202b46:	0000f797          	auipc	a5,0xf
ffffffffc0202b4a:	a2a78793          	addi	a5,a5,-1494 # ffffffffc0211570 <pgfault_num>
ffffffffc0202b4e:	3f059b63          	bne	a1,a6,ffffffffc0202f44 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b52:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0202b56:	4390                	lw	a2,0(a5)
ffffffffc0202b58:	2601                	sext.w	a2,a2
ffffffffc0202b5a:	40b61563          	bne	a2,a1,ffffffffc0202f64 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b5e:	6589                	lui	a1,0x2
ffffffffc0202b60:	452d                	li	a0,11
ffffffffc0202b62:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202b66:	4390                	lw	a2,0(a5)
ffffffffc0202b68:	4809                	li	a6,2
ffffffffc0202b6a:	2601                	sext.w	a2,a2
ffffffffc0202b6c:	35061c63          	bne	a2,a6,ffffffffc0202ec4 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b70:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0202b74:	438c                	lw	a1,0(a5)
ffffffffc0202b76:	2581                	sext.w	a1,a1
ffffffffc0202b78:	36c59663          	bne	a1,a2,ffffffffc0202ee4 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b7c:	658d                	lui	a1,0x3
ffffffffc0202b7e:	4531                	li	a0,12
ffffffffc0202b80:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202b84:	4390                	lw	a2,0(a5)
ffffffffc0202b86:	480d                	li	a6,3
ffffffffc0202b88:	2601                	sext.w	a2,a2
ffffffffc0202b8a:	37061d63          	bne	a2,a6,ffffffffc0202f04 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b8e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0202b92:	438c                	lw	a1,0(a5)
ffffffffc0202b94:	2581                	sext.w	a1,a1
ffffffffc0202b96:	38c59763          	bne	a1,a2,ffffffffc0202f24 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b9a:	6591                	lui	a1,0x4
ffffffffc0202b9c:	4535                	li	a0,13
ffffffffc0202b9e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202ba2:	4390                	lw	a2,0(a5)
ffffffffc0202ba4:	2601                	sext.w	a2,a2
ffffffffc0202ba6:	21861f63          	bne	a2,s8,ffffffffc0202dc4 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202baa:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0202bae:	439c                	lw	a5,0(a5)
ffffffffc0202bb0:	2781                	sext.w	a5,a5
ffffffffc0202bb2:	22c79963          	bne	a5,a2,ffffffffc0202de4 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202bb6:	489c                	lw	a5,16(s1)
ffffffffc0202bb8:	24079663          	bnez	a5,ffffffffc0202e04 <swap_init+0x48a>
ffffffffc0202bbc:	0000e797          	auipc	a5,0xe
ffffffffc0202bc0:	4dc78793          	addi	a5,a5,1244 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202bc4:	0000e617          	auipc	a2,0xe
ffffffffc0202bc8:	4fc60613          	addi	a2,a2,1276 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202bcc:	0000e517          	auipc	a0,0xe
ffffffffc0202bd0:	4f450513          	addi	a0,a0,1268 # ffffffffc02110c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202bd4:	55fd                	li	a1,-1
ffffffffc0202bd6:	c38c                	sw	a1,0(a5)
ffffffffc0202bd8:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202bda:	0791                	addi	a5,a5,4
ffffffffc0202bdc:	0611                	addi	a2,a2,4
ffffffffc0202bde:	fef51ce3          	bne	a0,a5,ffffffffc0202bd6 <swap_init+0x25c>
ffffffffc0202be2:	0000e817          	auipc	a6,0xe
ffffffffc0202be6:	47680813          	addi	a6,a6,1142 # ffffffffc0211058 <check_ptep>
ffffffffc0202bea:	0000e897          	auipc	a7,0xe
ffffffffc0202bee:	48e88893          	addi	a7,a7,1166 # ffffffffc0211078 <check_rp>
ffffffffc0202bf2:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202bf4:	0000fc97          	auipc	s9,0xf
ffffffffc0202bf8:	93cc8c93          	addi	s9,s9,-1732 # ffffffffc0211530 <pages>
ffffffffc0202bfc:	00004c17          	auipc	s8,0x4
ffffffffc0202c00:	8b4c0c13          	addi	s8,s8,-1868 # ffffffffc02064b0 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202c04:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c08:	4601                	li	a2,0
ffffffffc0202c0a:	855e                	mv	a0,s7
ffffffffc0202c0c:	ec46                	sd	a7,24(sp)
ffffffffc0202c0e:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202c10:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c12:	b1bfe0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0202c16:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202c18:	65c2                	ld	a1,16(sp)
ffffffffc0202c1a:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c1c:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202c20:	0000f317          	auipc	t1,0xf
ffffffffc0202c24:	90830313          	addi	t1,t1,-1784 # ffffffffc0211528 <npage>
ffffffffc0202c28:	16050e63          	beqz	a0,ffffffffc0202da4 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c2c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202c2e:	0017f613          	andi	a2,a5,1
ffffffffc0202c32:	0e060563          	beqz	a2,ffffffffc0202d1c <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202c36:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c3a:	078a                	slli	a5,a5,0x2
ffffffffc0202c3c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c3e:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202d34 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c42:	000c3603          	ld	a2,0(s8)
ffffffffc0202c46:	000cb503          	ld	a0,0(s9)
ffffffffc0202c4a:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c4e:	8f91                	sub	a5,a5,a2
ffffffffc0202c50:	00379613          	slli	a2,a5,0x3
ffffffffc0202c54:	97b2                	add	a5,a5,a2
ffffffffc0202c56:	078e                	slli	a5,a5,0x3
ffffffffc0202c58:	97aa                	add	a5,a5,a0
ffffffffc0202c5a:	0aff1163          	bne	t5,a5,ffffffffc0202cfc <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c5e:	6785                	lui	a5,0x1
ffffffffc0202c60:	95be                	add	a1,a1,a5
ffffffffc0202c62:	6795                	lui	a5,0x5
ffffffffc0202c64:	0821                	addi	a6,a6,8
ffffffffc0202c66:	08a1                	addi	a7,a7,8
ffffffffc0202c68:	f8f59ee3          	bne	a1,a5,ffffffffc0202c04 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c6c:	00003517          	auipc	a0,0x3
ffffffffc0202c70:	f2450513          	addi	a0,a0,-220 # ffffffffc0205b90 <default_pmm_manager+0x8c0>
ffffffffc0202c74:	c4afd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202c78:	000b3783          	ld	a5,0(s6)
ffffffffc0202c7c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c7e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202c80:	1a051263          	bnez	a0,ffffffffc0202e24 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202c84:	00093503          	ld	a0,0(s2)
ffffffffc0202c88:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c8a:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202c8c:	a27fe0ef          	jal	ra,ffffffffc02016b2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c90:	ff491ae3          	bne	s2,s4,ffffffffc0202c84 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202c94:	8556                	mv	a0,s5
ffffffffc0202c96:	2e1000ef          	jal	ra,ffffffffc0203776 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202c9a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c9c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202ca0:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202ca2:	7782                	ld	a5,32(sp)
ffffffffc0202ca4:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ca6:	009d8a63          	beq	s11,s1,ffffffffc0202cba <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202caa:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202cae:	008dbd83          	ld	s11,8(s11)
ffffffffc0202cb2:	3d7d                	addiw	s10,s10,-1
ffffffffc0202cb4:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cb6:	fe9d9ae3          	bne	s11,s1,ffffffffc0202caa <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202cba:	8622                	mv	a2,s0
ffffffffc0202cbc:	85ea                	mv	a1,s10
ffffffffc0202cbe:	00003517          	auipc	a0,0x3
ffffffffc0202cc2:	f0250513          	addi	a0,a0,-254 # ffffffffc0205bc0 <default_pmm_manager+0x8f0>
ffffffffc0202cc6:	bf8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202cca:	00003517          	auipc	a0,0x3
ffffffffc0202cce:	f1650513          	addi	a0,a0,-234 # ffffffffc0205be0 <default_pmm_manager+0x910>
ffffffffc0202cd2:	becfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0202cd6:	b9dd                	j	ffffffffc02029cc <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cd8:	4901                	li	s2,0
ffffffffc0202cda:	bba9                	j	ffffffffc0202a34 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202cdc:	00002697          	auipc	a3,0x2
ffffffffc0202ce0:	23468693          	addi	a3,a3,564 # ffffffffc0204f10 <commands+0x788>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	23c60613          	addi	a2,a2,572 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202cec:	0bc00593          	li	a1,188
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	c8850513          	addi	a0,a0,-888 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202cf8:	e80fd0ef          	jal	ra,ffffffffc0200378 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	e6c68693          	addi	a3,a3,-404 # ffffffffc0205b68 <default_pmm_manager+0x898>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	21c60613          	addi	a2,a2,540 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202d0c:	0fc00593          	li	a1,252
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	c6850513          	addi	a0,a0,-920 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202d18:	e60fd0ef          	jal	ra,ffffffffc0200378 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202d1c:	00002617          	auipc	a2,0x2
ffffffffc0202d20:	61c60613          	addi	a2,a2,1564 # ffffffffc0205338 <default_pmm_manager+0x68>
ffffffffc0202d24:	07000593          	li	a1,112
ffffffffc0202d28:	00002517          	auipc	a0,0x2
ffffffffc0202d2c:	60050513          	addi	a0,a0,1536 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc0202d30:	e48fd0ef          	jal	ra,ffffffffc0200378 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	5d460613          	addi	a2,a2,1492 # ffffffffc0205308 <default_pmm_manager+0x38>
ffffffffc0202d3c:	06500593          	li	a1,101
ffffffffc0202d40:	00002517          	auipc	a0,0x2
ffffffffc0202d44:	5e850513          	addi	a0,a0,1512 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc0202d48:	e30fd0ef          	jal	ra,ffffffffc0200378 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d4c:	00003697          	auipc	a3,0x3
ffffffffc0202d50:	d5468693          	addi	a3,a3,-684 # ffffffffc0205aa0 <default_pmm_manager+0x7d0>
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	1cc60613          	addi	a2,a2,460 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202d5c:	0dd00593          	li	a1,221
ffffffffc0202d60:	00003517          	auipc	a0,0x3
ffffffffc0202d64:	c1850513          	addi	a0,a0,-1000 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202d68:	e10fd0ef          	jal	ra,ffffffffc0200378 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202d6c:	00003697          	auipc	a3,0x3
ffffffffc0202d70:	d1c68693          	addi	a3,a3,-740 # ffffffffc0205a88 <default_pmm_manager+0x7b8>
ffffffffc0202d74:	00002617          	auipc	a2,0x2
ffffffffc0202d78:	1ac60613          	addi	a2,a2,428 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202d7c:	0dc00593          	li	a1,220
ffffffffc0202d80:	00003517          	auipc	a0,0x3
ffffffffc0202d84:	bf850513          	addi	a0,a0,-1032 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202d88:	df0fd0ef          	jal	ra,ffffffffc0200378 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d8c:	00003617          	auipc	a2,0x3
ffffffffc0202d90:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0205958 <default_pmm_manager+0x688>
ffffffffc0202d94:	02800593          	li	a1,40
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	be050513          	addi	a0,a0,-1056 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202da0:	dd8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202da4:	00003697          	auipc	a3,0x3
ffffffffc0202da8:	dac68693          	addi	a3,a3,-596 # ffffffffc0205b50 <default_pmm_manager+0x880>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	17460613          	addi	a2,a2,372 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202db4:	0fb00593          	li	a1,251
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	bc050513          	addi	a0,a0,-1088 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202dc0:	db8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dc4:	00003697          	auipc	a3,0x3
ffffffffc0202dc8:	d7c68693          	addi	a3,a3,-644 # ffffffffc0205b40 <default_pmm_manager+0x870>
ffffffffc0202dcc:	00002617          	auipc	a2,0x2
ffffffffc0202dd0:	15460613          	addi	a2,a2,340 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202dd4:	09f00593          	li	a1,159
ffffffffc0202dd8:	00003517          	auipc	a0,0x3
ffffffffc0202ddc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202de0:	d98fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==4);
ffffffffc0202de4:	00003697          	auipc	a3,0x3
ffffffffc0202de8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0205b40 <default_pmm_manager+0x870>
ffffffffc0202dec:	00002617          	auipc	a2,0x2
ffffffffc0202df0:	13460613          	addi	a2,a2,308 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202df4:	0a100593          	li	a1,161
ffffffffc0202df8:	00003517          	auipc	a0,0x3
ffffffffc0202dfc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202e00:	d78fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e04:	00002697          	auipc	a3,0x2
ffffffffc0202e08:	2f468693          	addi	a3,a3,756 # ffffffffc02050f8 <commands+0x970>
ffffffffc0202e0c:	00002617          	auipc	a2,0x2
ffffffffc0202e10:	11460613          	addi	a2,a2,276 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202e14:	0f300593          	li	a1,243
ffffffffc0202e18:	00003517          	auipc	a0,0x3
ffffffffc0202e1c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202e20:	d58fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(ret==0);
ffffffffc0202e24:	00003697          	auipc	a3,0x3
ffffffffc0202e28:	d9468693          	addi	a3,a3,-620 # ffffffffc0205bb8 <default_pmm_manager+0x8e8>
ffffffffc0202e2c:	00002617          	auipc	a2,0x2
ffffffffc0202e30:	0f460613          	addi	a2,a2,244 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202e34:	10200593          	li	a1,258
ffffffffc0202e38:	00003517          	auipc	a0,0x3
ffffffffc0202e3c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202e40:	d38fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e44:	00003697          	auipc	a3,0x3
ffffffffc0202e48:	bac68693          	addi	a3,a3,-1108 # ffffffffc02059f0 <default_pmm_manager+0x720>
ffffffffc0202e4c:	00002617          	auipc	a2,0x2
ffffffffc0202e50:	0d460613          	addi	a2,a2,212 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202e54:	0cc00593          	li	a1,204
ffffffffc0202e58:	00003517          	auipc	a0,0x3
ffffffffc0202e5c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202e60:	d18fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(vma != NULL);
ffffffffc0202e64:	00003697          	auipc	a3,0x3
ffffffffc0202e68:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205a00 <default_pmm_manager+0x730>
ffffffffc0202e6c:	00002617          	auipc	a2,0x2
ffffffffc0202e70:	0b460613          	addi	a2,a2,180 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202e74:	0cf00593          	li	a1,207
ffffffffc0202e78:	00003517          	auipc	a0,0x3
ffffffffc0202e7c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202e80:	cf8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202e84:	00003697          	auipc	a3,0x3
ffffffffc0202e88:	bc468693          	addi	a3,a3,-1084 # ffffffffc0205a48 <default_pmm_manager+0x778>
ffffffffc0202e8c:	00002617          	auipc	a2,0x2
ffffffffc0202e90:	09460613          	addi	a2,a2,148 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202e94:	0d700593          	li	a1,215
ffffffffc0202e98:	00003517          	auipc	a0,0x3
ffffffffc0202e9c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202ea0:	cd8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202ea4:	00002697          	auipc	a3,0x2
ffffffffc0202ea8:	0ac68693          	addi	a3,a3,172 # ffffffffc0204f50 <commands+0x7c8>
ffffffffc0202eac:	00002617          	auipc	a2,0x2
ffffffffc0202eb0:	07460613          	addi	a2,a2,116 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202eb4:	0bf00593          	li	a1,191
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	ac050513          	addi	a0,a0,-1344 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202ec0:	cb8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ec4:	00003697          	auipc	a3,0x3
ffffffffc0202ec8:	c5c68693          	addi	a3,a3,-932 # ffffffffc0205b20 <default_pmm_manager+0x850>
ffffffffc0202ecc:	00002617          	auipc	a2,0x2
ffffffffc0202ed0:	05460613          	addi	a2,a2,84 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202ed4:	09700593          	li	a1,151
ffffffffc0202ed8:	00003517          	auipc	a0,0x3
ffffffffc0202edc:	aa050513          	addi	a0,a0,-1376 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202ee0:	c98fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ee4:	00003697          	auipc	a3,0x3
ffffffffc0202ee8:	c3c68693          	addi	a3,a3,-964 # ffffffffc0205b20 <default_pmm_manager+0x850>
ffffffffc0202eec:	00002617          	auipc	a2,0x2
ffffffffc0202ef0:	03460613          	addi	a2,a2,52 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202ef4:	09900593          	li	a1,153
ffffffffc0202ef8:	00003517          	auipc	a0,0x3
ffffffffc0202efc:	a8050513          	addi	a0,a0,-1408 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202f00:	c78fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f04:	00003697          	auipc	a3,0x3
ffffffffc0202f08:	c2c68693          	addi	a3,a3,-980 # ffffffffc0205b30 <default_pmm_manager+0x860>
ffffffffc0202f0c:	00002617          	auipc	a2,0x2
ffffffffc0202f10:	01460613          	addi	a2,a2,20 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202f14:	09b00593          	li	a1,155
ffffffffc0202f18:	00003517          	auipc	a0,0x3
ffffffffc0202f1c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202f20:	c58fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f24:	00003697          	auipc	a3,0x3
ffffffffc0202f28:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0205b30 <default_pmm_manager+0x860>
ffffffffc0202f2c:	00002617          	auipc	a2,0x2
ffffffffc0202f30:	ff460613          	addi	a2,a2,-12 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202f34:	09d00593          	li	a1,157
ffffffffc0202f38:	00003517          	auipc	a0,0x3
ffffffffc0202f3c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202f40:	c38fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f44:	00003697          	auipc	a3,0x3
ffffffffc0202f48:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0205b10 <default_pmm_manager+0x840>
ffffffffc0202f4c:	00002617          	auipc	a2,0x2
ffffffffc0202f50:	fd460613          	addi	a2,a2,-44 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202f54:	09300593          	li	a1,147
ffffffffc0202f58:	00003517          	auipc	a0,0x3
ffffffffc0202f5c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202f60:	c18fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f64:	00003697          	auipc	a3,0x3
ffffffffc0202f68:	bac68693          	addi	a3,a3,-1108 # ffffffffc0205b10 <default_pmm_manager+0x840>
ffffffffc0202f6c:	00002617          	auipc	a2,0x2
ffffffffc0202f70:	fb460613          	addi	a2,a2,-76 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202f74:	09500593          	li	a1,149
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202f80:	bf8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(mm != NULL);
ffffffffc0202f84:	00003697          	auipc	a3,0x3
ffffffffc0202f88:	a4468693          	addi	a3,a3,-1468 # ffffffffc02059c8 <default_pmm_manager+0x6f8>
ffffffffc0202f8c:	00002617          	auipc	a2,0x2
ffffffffc0202f90:	f9460613          	addi	a2,a2,-108 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202f94:	0c400593          	li	a1,196
ffffffffc0202f98:	00003517          	auipc	a0,0x3
ffffffffc0202f9c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202fa0:	bd8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202fa4:	00003697          	auipc	a3,0x3
ffffffffc0202fa8:	a3468693          	addi	a3,a3,-1484 # ffffffffc02059d8 <default_pmm_manager+0x708>
ffffffffc0202fac:	00002617          	auipc	a2,0x2
ffffffffc0202fb0:	f7460613          	addi	a2,a2,-140 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202fb4:	0c700593          	li	a1,199
ffffffffc0202fb8:	00003517          	auipc	a0,0x3
ffffffffc0202fbc:	9c050513          	addi	a0,a0,-1600 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202fc0:	bb8fd0ef          	jal	ra,ffffffffc0200378 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202fc4:	00003697          	auipc	a3,0x3
ffffffffc0202fc8:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205ac0 <default_pmm_manager+0x7f0>
ffffffffc0202fcc:	00002617          	auipc	a2,0x2
ffffffffc0202fd0:	f5460613          	addi	a2,a2,-172 # ffffffffc0204f20 <commands+0x798>
ffffffffc0202fd4:	0ea00593          	li	a1,234
ffffffffc0202fd8:	00003517          	auipc	a0,0x3
ffffffffc0202fdc:	9a050513          	addi	a0,a0,-1632 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0202fe0:	b98fd0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0202fe4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202fe4:	0000e797          	auipc	a5,0xe
ffffffffc0202fe8:	56c7b783          	ld	a5,1388(a5) # ffffffffc0211550 <sm>
ffffffffc0202fec:	6b9c                	ld	a5,16(a5)
ffffffffc0202fee:	8782                	jr	a5

ffffffffc0202ff0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202ff0:	0000e797          	auipc	a5,0xe
ffffffffc0202ff4:	5607b783          	ld	a5,1376(a5) # ffffffffc0211550 <sm>
ffffffffc0202ff8:	739c                	ld	a5,32(a5)
ffffffffc0202ffa:	8782                	jr	a5

ffffffffc0202ffc <swap_out>:
{
ffffffffc0202ffc:	711d                	addi	sp,sp,-96
ffffffffc0202ffe:	ec86                	sd	ra,88(sp)
ffffffffc0203000:	e8a2                	sd	s0,80(sp)
ffffffffc0203002:	e4a6                	sd	s1,72(sp)
ffffffffc0203004:	e0ca                	sd	s2,64(sp)
ffffffffc0203006:	fc4e                	sd	s3,56(sp)
ffffffffc0203008:	f852                	sd	s4,48(sp)
ffffffffc020300a:	f456                	sd	s5,40(sp)
ffffffffc020300c:	f05a                	sd	s6,32(sp)
ffffffffc020300e:	ec5e                	sd	s7,24(sp)
ffffffffc0203010:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203012:	cde9                	beqz	a1,ffffffffc02030ec <swap_out+0xf0>
ffffffffc0203014:	8a2e                	mv	s4,a1
ffffffffc0203016:	892a                	mv	s2,a0
ffffffffc0203018:	8ab2                	mv	s5,a2
ffffffffc020301a:	4401                	li	s0,0
ffffffffc020301c:	0000e997          	auipc	s3,0xe
ffffffffc0203020:	53498993          	addi	s3,s3,1332 # ffffffffc0211550 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203024:	00003b17          	auipc	s6,0x3
ffffffffc0203028:	c3cb0b13          	addi	s6,s6,-964 # ffffffffc0205c60 <default_pmm_manager+0x990>
                    cprintf("SWAP: failed to save\n");
ffffffffc020302c:	00003b97          	auipc	s7,0x3
ffffffffc0203030:	c1cb8b93          	addi	s7,s7,-996 # ffffffffc0205c48 <default_pmm_manager+0x978>
ffffffffc0203034:	a825                	j	ffffffffc020306c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203036:	67a2                	ld	a5,8(sp)
ffffffffc0203038:	8626                	mv	a2,s1
ffffffffc020303a:	85a2                	mv	a1,s0
ffffffffc020303c:	63b4                	ld	a3,64(a5)
ffffffffc020303e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203040:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203042:	82b1                	srli	a3,a3,0xc
ffffffffc0203044:	0685                	addi	a3,a3,1
ffffffffc0203046:	878fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020304a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020304c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020304e:	613c                	ld	a5,64(a0)
ffffffffc0203050:	83b1                	srli	a5,a5,0xc
ffffffffc0203052:	0785                	addi	a5,a5,1
ffffffffc0203054:	07a2                	slli	a5,a5,0x8
ffffffffc0203056:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020305a:	e58fe0ef          	jal	ra,ffffffffc02016b2 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020305e:	01893503          	ld	a0,24(s2)
ffffffffc0203062:	85a6                	mv	a1,s1
ffffffffc0203064:	eb6ff0ef          	jal	ra,ffffffffc020271a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203068:	048a0d63          	beq	s4,s0,ffffffffc02030c2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020306c:	0009b783          	ld	a5,0(s3)
ffffffffc0203070:	8656                	mv	a2,s5
ffffffffc0203072:	002c                	addi	a1,sp,8
ffffffffc0203074:	7b9c                	ld	a5,48(a5)
ffffffffc0203076:	854a                	mv	a0,s2
ffffffffc0203078:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020307a:	e12d                	bnez	a0,ffffffffc02030dc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020307c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020307e:	01893503          	ld	a0,24(s2)
ffffffffc0203082:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203084:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203086:	85a6                	mv	a1,s1
ffffffffc0203088:	ea4fe0ef          	jal	ra,ffffffffc020172c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020308c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020308e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203090:	8b85                	andi	a5,a5,1
ffffffffc0203092:	cfb9                	beqz	a5,ffffffffc02030f0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203094:	65a2                	ld	a1,8(sp)
ffffffffc0203096:	61bc                	ld	a5,64(a1)
ffffffffc0203098:	83b1                	srli	a5,a5,0xc
ffffffffc020309a:	0785                	addi	a5,a5,1
ffffffffc020309c:	00879513          	slli	a0,a5,0x8
ffffffffc02030a0:	6a9000ef          	jal	ra,ffffffffc0203f48 <swapfs_write>
ffffffffc02030a4:	d949                	beqz	a0,ffffffffc0203036 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02030a6:	855e                	mv	a0,s7
ffffffffc02030a8:	816fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02030ac:	0009b783          	ld	a5,0(s3)
ffffffffc02030b0:	6622                	ld	a2,8(sp)
ffffffffc02030b2:	4681                	li	a3,0
ffffffffc02030b4:	739c                	ld	a5,32(a5)
ffffffffc02030b6:	85a6                	mv	a1,s1
ffffffffc02030b8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02030ba:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02030bc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02030be:	fa8a17e3          	bne	s4,s0,ffffffffc020306c <swap_out+0x70>
}
ffffffffc02030c2:	60e6                	ld	ra,88(sp)
ffffffffc02030c4:	8522                	mv	a0,s0
ffffffffc02030c6:	6446                	ld	s0,80(sp)
ffffffffc02030c8:	64a6                	ld	s1,72(sp)
ffffffffc02030ca:	6906                	ld	s2,64(sp)
ffffffffc02030cc:	79e2                	ld	s3,56(sp)
ffffffffc02030ce:	7a42                	ld	s4,48(sp)
ffffffffc02030d0:	7aa2                	ld	s5,40(sp)
ffffffffc02030d2:	7b02                	ld	s6,32(sp)
ffffffffc02030d4:	6be2                	ld	s7,24(sp)
ffffffffc02030d6:	6c42                	ld	s8,16(sp)
ffffffffc02030d8:	6125                	addi	sp,sp,96
ffffffffc02030da:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02030dc:	85a2                	mv	a1,s0
ffffffffc02030de:	00003517          	auipc	a0,0x3
ffffffffc02030e2:	b2250513          	addi	a0,a0,-1246 # ffffffffc0205c00 <default_pmm_manager+0x930>
ffffffffc02030e6:	fd9fc0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc02030ea:	bfe1                	j	ffffffffc02030c2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02030ec:	4401                	li	s0,0
ffffffffc02030ee:	bfd1                	j	ffffffffc02030c2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030f0:	00003697          	auipc	a3,0x3
ffffffffc02030f4:	b4068693          	addi	a3,a3,-1216 # ffffffffc0205c30 <default_pmm_manager+0x960>
ffffffffc02030f8:	00002617          	auipc	a2,0x2
ffffffffc02030fc:	e2860613          	addi	a2,a2,-472 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203100:	06800593          	li	a1,104
ffffffffc0203104:	00003517          	auipc	a0,0x3
ffffffffc0203108:	87450513          	addi	a0,a0,-1932 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc020310c:	a6cfd0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0203110 <swap_in>:
{
ffffffffc0203110:	7179                	addi	sp,sp,-48
ffffffffc0203112:	e84a                	sd	s2,16(sp)
ffffffffc0203114:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203116:	4505                	li	a0,1
{
ffffffffc0203118:	ec26                	sd	s1,24(sp)
ffffffffc020311a:	e44e                	sd	s3,8(sp)
ffffffffc020311c:	f406                	sd	ra,40(sp)
ffffffffc020311e:	f022                	sd	s0,32(sp)
ffffffffc0203120:	84ae                	mv	s1,a1
ffffffffc0203122:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203124:	cfcfe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203128:	c129                	beqz	a0,ffffffffc020316a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020312a:	842a                	mv	s0,a0
ffffffffc020312c:	01893503          	ld	a0,24(s2)
ffffffffc0203130:	4601                	li	a2,0
ffffffffc0203132:	85a6                	mv	a1,s1
ffffffffc0203134:	df8fe0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0203138:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020313a:	6108                	ld	a0,0(a0)
ffffffffc020313c:	85a2                	mv	a1,s0
ffffffffc020313e:	571000ef          	jal	ra,ffffffffc0203eae <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203142:	00093583          	ld	a1,0(s2)
ffffffffc0203146:	8626                	mv	a2,s1
ffffffffc0203148:	00003517          	auipc	a0,0x3
ffffffffc020314c:	b6850513          	addi	a0,a0,-1176 # ffffffffc0205cb0 <default_pmm_manager+0x9e0>
ffffffffc0203150:	81a1                	srli	a1,a1,0x8
ffffffffc0203152:	f6dfc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203156:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203158:	0089b023          	sd	s0,0(s3)
}
ffffffffc020315c:	7402                	ld	s0,32(sp)
ffffffffc020315e:	64e2                	ld	s1,24(sp)
ffffffffc0203160:	6942                	ld	s2,16(sp)
ffffffffc0203162:	69a2                	ld	s3,8(sp)
ffffffffc0203164:	4501                	li	a0,0
ffffffffc0203166:	6145                	addi	sp,sp,48
ffffffffc0203168:	8082                	ret
     assert(result!=NULL);
ffffffffc020316a:	00003697          	auipc	a3,0x3
ffffffffc020316e:	b3668693          	addi	a3,a3,-1226 # ffffffffc0205ca0 <default_pmm_manager+0x9d0>
ffffffffc0203172:	00002617          	auipc	a2,0x2
ffffffffc0203176:	dae60613          	addi	a2,a2,-594 # ffffffffc0204f20 <commands+0x798>
ffffffffc020317a:	07e00593          	li	a1,126
ffffffffc020317e:	00002517          	auipc	a0,0x2
ffffffffc0203182:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205978 <default_pmm_manager+0x6a8>
ffffffffc0203186:	9f2fd0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc020318a <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020318a:	0000e797          	auipc	a5,0xe
ffffffffc020318e:	f5e78793          	addi	a5,a5,-162 # ffffffffc02110e8 <pra_list_head>

//初始化
static int _lru_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc0203192:	f51c                	sd	a5,40(a0)
ffffffffc0203194:	e79c                	sd	a5,8(a5)
ffffffffc0203196:	e39c                	sd	a5,0(a5)

    return 0;
}
ffffffffc0203198:	4501                	li	a0,0
ffffffffc020319a:	8082                	ret

ffffffffc020319c <_lru_init>:
}

static int _lru_init(void)
{
    return 0;
}
ffffffffc020319c:	4501                	li	a0,0
ffffffffc020319e:	8082                	ret

ffffffffc02031a0 <_lru_set_unswappable>:

static int _lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02031a0:	4501                	li	a0,0
ffffffffc02031a2:	8082                	ret

ffffffffc02031a4 <_lru_tick_event>:

static int _lru_tick_event(struct mm_struct *mm)
{ 
    return 0; 
}
ffffffffc02031a4:	4501                	li	a0,0
ffffffffc02031a6:	8082                	ret

ffffffffc02031a8 <_lru_check_swap>:
{
ffffffffc02031a8:	711d                	addi	sp,sp,-96
ffffffffc02031aa:	fc4e                	sd	s3,56(sp)
ffffffffc02031ac:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc02031ae:	00003517          	auipc	a0,0x3
ffffffffc02031b2:	b4250513          	addi	a0,a0,-1214 # ffffffffc0205cf0 <default_pmm_manager+0xa20>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031b6:	698d                	lui	s3,0x3
ffffffffc02031b8:	4a31                	li	s4,12
{
ffffffffc02031ba:	e0ca                	sd	s2,64(sp)
ffffffffc02031bc:	ec86                	sd	ra,88(sp)
ffffffffc02031be:	e8a2                	sd	s0,80(sp)
ffffffffc02031c0:	e4a6                	sd	s1,72(sp)
ffffffffc02031c2:	f456                	sd	s5,40(sp)
ffffffffc02031c4:	f05a                	sd	s6,32(sp)
ffffffffc02031c6:	ec5e                	sd	s7,24(sp)
ffffffffc02031c8:	e862                	sd	s8,16(sp)
ffffffffc02031ca:	e466                	sd	s9,8(sp)
ffffffffc02031cc:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc02031ce:	ef1fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031d2:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02031d6:	0000e917          	auipc	s2,0xe
ffffffffc02031da:	39a92903          	lw	s2,922(s2) # ffffffffc0211570 <pgfault_num>
ffffffffc02031de:	4791                	li	a5,4
ffffffffc02031e0:	14f91e63          	bne	s2,a5,ffffffffc020333c <_lru_check_swap+0x194>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02031e4:	00003517          	auipc	a0,0x3
ffffffffc02031e8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0205d30 <default_pmm_manager+0xa60>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031ec:	6a85                	lui	s5,0x1
ffffffffc02031ee:	4b29                	li	s6,10
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02031f0:	ecffc0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02031f4:	0000e417          	auipc	s0,0xe
ffffffffc02031f8:	37c40413          	addi	s0,s0,892 # ffffffffc0211570 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031fc:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203200:	4004                	lw	s1,0(s0)
ffffffffc0203202:	2481                	sext.w	s1,s1
ffffffffc0203204:	2b249c63          	bne	s1,s2,ffffffffc02034bc <_lru_check_swap+0x314>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203208:	00003517          	auipc	a0,0x3
ffffffffc020320c:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205d58 <default_pmm_manager+0xa88>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203210:	6b91                	lui	s7,0x4
ffffffffc0203212:	4c35                	li	s8,13
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203214:	eabfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203218:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020321c:	00042903          	lw	s2,0(s0)
ffffffffc0203220:	2901                	sext.w	s2,s2
ffffffffc0203222:	26991d63          	bne	s2,s1,ffffffffc020349c <_lru_check_swap+0x2f4>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203226:	00003517          	auipc	a0,0x3
ffffffffc020322a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205d80 <default_pmm_manager+0xab0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020322e:	6c89                	lui	s9,0x2
ffffffffc0203230:	4d2d                	li	s10,11
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203232:	e8dfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203236:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020323a:	401c                	lw	a5,0(s0)
ffffffffc020323c:	2781                	sext.w	a5,a5
ffffffffc020323e:	23279f63          	bne	a5,s2,ffffffffc020347c <_lru_check_swap+0x2d4>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0203242:	00003517          	auipc	a0,0x3
ffffffffc0203246:	b6650513          	addi	a0,a0,-1178 # ffffffffc0205da8 <default_pmm_manager+0xad8>
ffffffffc020324a:	e75fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020324e:	6795                	lui	a5,0x5
ffffffffc0203250:	4739                	li	a4,14
ffffffffc0203252:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203256:	4004                	lw	s1,0(s0)
ffffffffc0203258:	4795                	li	a5,5
ffffffffc020325a:	2481                	sext.w	s1,s1
ffffffffc020325c:	20f49063          	bne	s1,a5,ffffffffc020345c <_lru_check_swap+0x2b4>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203260:	00003517          	auipc	a0,0x3
ffffffffc0203264:	b2050513          	addi	a0,a0,-1248 # ffffffffc0205d80 <default_pmm_manager+0xab0>
ffffffffc0203268:	e57fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020326c:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203270:	401c                	lw	a5,0(s0)
ffffffffc0203272:	2781                	sext.w	a5,a5
ffffffffc0203274:	1c979463          	bne	a5,s1,ffffffffc020343c <_lru_check_swap+0x294>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203278:	00003517          	auipc	a0,0x3
ffffffffc020327c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205d30 <default_pmm_manager+0xa60>
ffffffffc0203280:	e3ffc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203284:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203288:	401c                	lw	a5,0(s0)
ffffffffc020328a:	4719                	li	a4,6
ffffffffc020328c:	2781                	sext.w	a5,a5
ffffffffc020328e:	18e79763          	bne	a5,a4,ffffffffc020341c <_lru_check_swap+0x274>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203292:	00003517          	auipc	a0,0x3
ffffffffc0203296:	aee50513          	addi	a0,a0,-1298 # ffffffffc0205d80 <default_pmm_manager+0xab0>
ffffffffc020329a:	e25fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020329e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc02032a2:	401c                	lw	a5,0(s0)
ffffffffc02032a4:	471d                	li	a4,7
ffffffffc02032a6:	2781                	sext.w	a5,a5
ffffffffc02032a8:	14e79a63          	bne	a5,a4,ffffffffc02033fc <_lru_check_swap+0x254>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc02032ac:	00003517          	auipc	a0,0x3
ffffffffc02032b0:	a4450513          	addi	a0,a0,-1468 # ffffffffc0205cf0 <default_pmm_manager+0xa20>
ffffffffc02032b4:	e0bfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02032b8:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02032bc:	401c                	lw	a5,0(s0)
ffffffffc02032be:	4721                	li	a4,8
ffffffffc02032c0:	2781                	sext.w	a5,a5
ffffffffc02032c2:	10e79d63          	bne	a5,a4,ffffffffc02033dc <_lru_check_swap+0x234>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc02032c6:	00003517          	auipc	a0,0x3
ffffffffc02032ca:	a9250513          	addi	a0,a0,-1390 # ffffffffc0205d58 <default_pmm_manager+0xa88>
ffffffffc02032ce:	df1fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02032d2:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02032d6:	401c                	lw	a5,0(s0)
ffffffffc02032d8:	4725                	li	a4,9
ffffffffc02032da:	2781                	sext.w	a5,a5
ffffffffc02032dc:	0ee79063          	bne	a5,a4,ffffffffc02033bc <_lru_check_swap+0x214>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc02032e0:	00003517          	auipc	a0,0x3
ffffffffc02032e4:	ac850513          	addi	a0,a0,-1336 # ffffffffc0205da8 <default_pmm_manager+0xad8>
ffffffffc02032e8:	dd7fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02032ec:	6795                	lui	a5,0x5
ffffffffc02032ee:	4739                	li	a4,14
ffffffffc02032f0:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02032f4:	4004                	lw	s1,0(s0)
ffffffffc02032f6:	47a9                	li	a5,10
ffffffffc02032f8:	2481                	sext.w	s1,s1
ffffffffc02032fa:	0af49163          	bne	s1,a5,ffffffffc020339c <_lru_check_swap+0x1f4>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02032fe:	00003517          	auipc	a0,0x3
ffffffffc0203302:	a3250513          	addi	a0,a0,-1486 # ffffffffc0205d30 <default_pmm_manager+0xa60>
ffffffffc0203306:	db9fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020330a:	6785                	lui	a5,0x1
ffffffffc020330c:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203310:	06979663          	bne	a5,s1,ffffffffc020337c <_lru_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203314:	401c                	lw	a5,0(s0)
ffffffffc0203316:	472d                	li	a4,11
ffffffffc0203318:	2781                	sext.w	a5,a5
ffffffffc020331a:	04e79163          	bne	a5,a4,ffffffffc020335c <_lru_check_swap+0x1b4>
}
ffffffffc020331e:	60e6                	ld	ra,88(sp)
ffffffffc0203320:	6446                	ld	s0,80(sp)
ffffffffc0203322:	64a6                	ld	s1,72(sp)
ffffffffc0203324:	6906                	ld	s2,64(sp)
ffffffffc0203326:	79e2                	ld	s3,56(sp)
ffffffffc0203328:	7a42                	ld	s4,48(sp)
ffffffffc020332a:	7aa2                	ld	s5,40(sp)
ffffffffc020332c:	7b02                	ld	s6,32(sp)
ffffffffc020332e:	6be2                	ld	s7,24(sp)
ffffffffc0203330:	6c42                	ld	s8,16(sp)
ffffffffc0203332:	6ca2                	ld	s9,8(sp)
ffffffffc0203334:	6d02                	ld	s10,0(sp)
ffffffffc0203336:	4501                	li	a0,0
ffffffffc0203338:	6125                	addi	sp,sp,96
ffffffffc020333a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020333c:	00003697          	auipc	a3,0x3
ffffffffc0203340:	80468693          	addi	a3,a3,-2044 # ffffffffc0205b40 <default_pmm_manager+0x870>
ffffffffc0203344:	00002617          	auipc	a2,0x2
ffffffffc0203348:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0204f20 <commands+0x798>
ffffffffc020334c:	06b00593          	li	a1,107
ffffffffc0203350:	00003517          	auipc	a0,0x3
ffffffffc0203354:	9c850513          	addi	a0,a0,-1592 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203358:	820fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==11);
ffffffffc020335c:	00003697          	auipc	a3,0x3
ffffffffc0203360:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205e58 <default_pmm_manager+0xb88>
ffffffffc0203364:	00002617          	auipc	a2,0x2
ffffffffc0203368:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0204f20 <commands+0x798>
ffffffffc020336c:	08d00593          	li	a1,141
ffffffffc0203370:	00003517          	auipc	a0,0x3
ffffffffc0203374:	9a850513          	addi	a0,a0,-1624 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203378:	800fd0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020337c:	00003697          	auipc	a3,0x3
ffffffffc0203380:	ab468693          	addi	a3,a3,-1356 # ffffffffc0205e30 <default_pmm_manager+0xb60>
ffffffffc0203384:	00002617          	auipc	a2,0x2
ffffffffc0203388:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0204f20 <commands+0x798>
ffffffffc020338c:	08b00593          	li	a1,139
ffffffffc0203390:	00003517          	auipc	a0,0x3
ffffffffc0203394:	98850513          	addi	a0,a0,-1656 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203398:	fe1fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==10);
ffffffffc020339c:	00003697          	auipc	a3,0x3
ffffffffc02033a0:	a8468693          	addi	a3,a3,-1404 # ffffffffc0205e20 <default_pmm_manager+0xb50>
ffffffffc02033a4:	00002617          	auipc	a2,0x2
ffffffffc02033a8:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0204f20 <commands+0x798>
ffffffffc02033ac:	08900593          	li	a1,137
ffffffffc02033b0:	00003517          	auipc	a0,0x3
ffffffffc02033b4:	96850513          	addi	a0,a0,-1688 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc02033b8:	fc1fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==9);
ffffffffc02033bc:	00003697          	auipc	a3,0x3
ffffffffc02033c0:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205e10 <default_pmm_manager+0xb40>
ffffffffc02033c4:	00002617          	auipc	a2,0x2
ffffffffc02033c8:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0204f20 <commands+0x798>
ffffffffc02033cc:	08600593          	li	a1,134
ffffffffc02033d0:	00003517          	auipc	a0,0x3
ffffffffc02033d4:	94850513          	addi	a0,a0,-1720 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc02033d8:	fa1fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==8);
ffffffffc02033dc:	00003697          	auipc	a3,0x3
ffffffffc02033e0:	a2468693          	addi	a3,a3,-1500 # ffffffffc0205e00 <default_pmm_manager+0xb30>
ffffffffc02033e4:	00002617          	auipc	a2,0x2
ffffffffc02033e8:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0204f20 <commands+0x798>
ffffffffc02033ec:	08300593          	li	a1,131
ffffffffc02033f0:	00003517          	auipc	a0,0x3
ffffffffc02033f4:	92850513          	addi	a0,a0,-1752 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc02033f8:	f81fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==7);
ffffffffc02033fc:	00003697          	auipc	a3,0x3
ffffffffc0203400:	9f468693          	addi	a3,a3,-1548 # ffffffffc0205df0 <default_pmm_manager+0xb20>
ffffffffc0203404:	00002617          	auipc	a2,0x2
ffffffffc0203408:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0204f20 <commands+0x798>
ffffffffc020340c:	08000593          	li	a1,128
ffffffffc0203410:	00003517          	auipc	a0,0x3
ffffffffc0203414:	90850513          	addi	a0,a0,-1784 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203418:	f61fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==6);
ffffffffc020341c:	00003697          	auipc	a3,0x3
ffffffffc0203420:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205de0 <default_pmm_manager+0xb10>
ffffffffc0203424:	00002617          	auipc	a2,0x2
ffffffffc0203428:	afc60613          	addi	a2,a2,-1284 # ffffffffc0204f20 <commands+0x798>
ffffffffc020342c:	07d00593          	li	a1,125
ffffffffc0203430:	00003517          	auipc	a0,0x3
ffffffffc0203434:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203438:	f41fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==5);
ffffffffc020343c:	00003697          	auipc	a3,0x3
ffffffffc0203440:	99468693          	addi	a3,a3,-1644 # ffffffffc0205dd0 <default_pmm_manager+0xb00>
ffffffffc0203444:	00002617          	auipc	a2,0x2
ffffffffc0203448:	adc60613          	addi	a2,a2,-1316 # ffffffffc0204f20 <commands+0x798>
ffffffffc020344c:	07a00593          	li	a1,122
ffffffffc0203450:	00003517          	auipc	a0,0x3
ffffffffc0203454:	8c850513          	addi	a0,a0,-1848 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203458:	f21fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==5);
ffffffffc020345c:	00003697          	auipc	a3,0x3
ffffffffc0203460:	97468693          	addi	a3,a3,-1676 # ffffffffc0205dd0 <default_pmm_manager+0xb00>
ffffffffc0203464:	00002617          	auipc	a2,0x2
ffffffffc0203468:	abc60613          	addi	a2,a2,-1348 # ffffffffc0204f20 <commands+0x798>
ffffffffc020346c:	07700593          	li	a1,119
ffffffffc0203470:	00003517          	auipc	a0,0x3
ffffffffc0203474:	8a850513          	addi	a0,a0,-1880 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203478:	f01fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==4);
ffffffffc020347c:	00002697          	auipc	a3,0x2
ffffffffc0203480:	6c468693          	addi	a3,a3,1732 # ffffffffc0205b40 <default_pmm_manager+0x870>
ffffffffc0203484:	00002617          	auipc	a2,0x2
ffffffffc0203488:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204f20 <commands+0x798>
ffffffffc020348c:	07400593          	li	a1,116
ffffffffc0203490:	00003517          	auipc	a0,0x3
ffffffffc0203494:	88850513          	addi	a0,a0,-1912 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203498:	ee1fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==4);
ffffffffc020349c:	00002697          	auipc	a3,0x2
ffffffffc02034a0:	6a468693          	addi	a3,a3,1700 # ffffffffc0205b40 <default_pmm_manager+0x870>
ffffffffc02034a4:	00002617          	auipc	a2,0x2
ffffffffc02034a8:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0204f20 <commands+0x798>
ffffffffc02034ac:	07100593          	li	a1,113
ffffffffc02034b0:	00003517          	auipc	a0,0x3
ffffffffc02034b4:	86850513          	addi	a0,a0,-1944 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc02034b8:	ec1fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgfault_num==4);
ffffffffc02034bc:	00002697          	auipc	a3,0x2
ffffffffc02034c0:	68468693          	addi	a3,a3,1668 # ffffffffc0205b40 <default_pmm_manager+0x870>
ffffffffc02034c4:	00002617          	auipc	a2,0x2
ffffffffc02034c8:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0204f20 <commands+0x798>
ffffffffc02034cc:	06e00593          	li	a1,110
ffffffffc02034d0:	00003517          	auipc	a0,0x3
ffffffffc02034d4:	84850513          	addi	a0,a0,-1976 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc02034d8:	ea1fc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc02034dc <_lru_swap_out_victim>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02034dc:	7518                	ld	a4,40(a0)
{
ffffffffc02034de:	1141                	addi	sp,sp,-16
ffffffffc02034e0:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc02034e2:	cb31                	beqz	a4,ffffffffc0203536 <_lru_swap_out_victim+0x5a>
    assert(in_tick==0);
ffffffffc02034e4:	ea0d                	bnez	a2,ffffffffc0203516 <_lru_swap_out_victim+0x3a>
    return listelm->prev;
ffffffffc02034e6:	631c                	ld	a5,0(a4)
    curr_ptr = list_prev(head);
ffffffffc02034e8:	0000e697          	auipc	a3,0xe
ffffffffc02034ec:	06f6bc23          	sd	a5,120(a3) # ffffffffc0211560 <curr_ptr>
    if (curr_ptr != head) 
ffffffffc02034f0:	00f70d63          	beq	a4,a5,ffffffffc020350a <_lru_swap_out_victim+0x2e>
    __list_del(listelm->prev, listelm->next);
ffffffffc02034f4:	6394                	ld	a3,0(a5)
ffffffffc02034f6:	6798                	ld	a4,8(a5)
}
ffffffffc02034f8:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(curr_ptr, pra_page_link);
ffffffffc02034fa:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc02034fe:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203500:	e314                	sd	a3,0(a4)
ffffffffc0203502:	e19c                	sd	a5,0(a1)
}
ffffffffc0203504:	4501                	li	a0,0
ffffffffc0203506:	0141                	addi	sp,sp,16
ffffffffc0203508:	8082                	ret
ffffffffc020350a:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc020350c:	0005b023          	sd	zero,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
}
ffffffffc0203510:	4501                	li	a0,0
ffffffffc0203512:	0141                	addi	sp,sp,16
ffffffffc0203514:	8082                	ret
    assert(in_tick==0);
ffffffffc0203516:	00003697          	auipc	a3,0x3
ffffffffc020351a:	96268693          	addi	a3,a3,-1694 # ffffffffc0205e78 <default_pmm_manager+0xba8>
ffffffffc020351e:	00002617          	auipc	a2,0x2
ffffffffc0203522:	a0260613          	addi	a2,a2,-1534 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203526:	02b00593          	li	a1,43
ffffffffc020352a:	00002517          	auipc	a0,0x2
ffffffffc020352e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203532:	e47fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(head != NULL);
ffffffffc0203536:	00003697          	auipc	a3,0x3
ffffffffc020353a:	93268693          	addi	a3,a3,-1742 # ffffffffc0205e68 <default_pmm_manager+0xb98>
ffffffffc020353e:	00002617          	auipc	a2,0x2
ffffffffc0203542:	9e260613          	addi	a2,a2,-1566 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203546:	02a00593          	li	a1,42
ffffffffc020354a:	00002517          	auipc	a0,0x2
ffffffffc020354e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205d18 <default_pmm_manager+0xa48>
ffffffffc0203552:	e27fc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0203556 <_lru_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203556:	7514                	ld	a3,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203558:	caa9                	beqz	a3,ffffffffc02035aa <_lru_map_swappable+0x54>
    curr_ptr = head->next;
ffffffffc020355a:	669c                	ld	a5,8(a3)
ffffffffc020355c:	0000e517          	auipc	a0,0xe
ffffffffc0203560:	00450513          	addi	a0,a0,4 # ffffffffc0211560 <curr_ptr>
    while(curr_ptr!=head) 
ffffffffc0203564:	4581                	li	a1,0
    curr_ptr = head->next;
ffffffffc0203566:	e11c                	sd	a5,0(a0)
    while(curr_ptr!=head) 
ffffffffc0203568:	00f69763          	bne	a3,a5,ffffffffc0203576 <_lru_map_swappable+0x20>
ffffffffc020356c:	a815                	j	ffffffffc02035a0 <_lru_map_swappable+0x4a>
        curr_ptr = curr_ptr->next;
ffffffffc020356e:	679c                	ld	a5,8(a5)
    while(curr_ptr!=head) 
ffffffffc0203570:	4585                	li	a1,1
ffffffffc0203572:	02f68963          	beq	a3,a5,ffffffffc02035a4 <_lru_map_swappable+0x4e>
        struct Page *curr_page = le2page(curr_ptr, pra_page_link);
ffffffffc0203576:	fd078713          	addi	a4,a5,-48
        if (curr_page == page) 
ffffffffc020357a:	fee61ae3          	bne	a2,a4,ffffffffc020356e <_lru_map_swappable+0x18>
ffffffffc020357e:	c191                	beqz	a1,ffffffffc0203582 <_lru_map_swappable+0x2c>
ffffffffc0203580:	e11c                	sd	a5,0(a0)
    if (curr_ptr == head) 
ffffffffc0203582:	00f68f63          	beq	a3,a5,ffffffffc02035a0 <_lru_map_swappable+0x4a>
    if (entry->prev == head) 
ffffffffc0203586:	7a1c                	ld	a5,48(a2)
ffffffffc0203588:	00f68c63          	beq	a3,a5,ffffffffc02035a0 <_lru_map_swappable+0x4a>
    __list_del(listelm->prev, listelm->next);
ffffffffc020358c:	7e08                	ld	a0,56(a2)
    list_entry_t *entry = &(page->pra_page_link);
ffffffffc020358e:	03060593          	addi	a1,a2,48
    prev->next = next;
ffffffffc0203592:	e788                	sd	a0,8(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203594:	6698                	ld	a4,8(a3)
    next->prev = prev;
ffffffffc0203596:	e11c                	sd	a5,0(a0)
    prev->next = next->prev = elm;
ffffffffc0203598:	e30c                	sd	a1,0(a4)
ffffffffc020359a:	e68c                	sd	a1,8(a3)
    elm->next = next;
ffffffffc020359c:	fe18                	sd	a4,56(a2)
    elm->prev = prev;
ffffffffc020359e:	fa14                	sd	a3,48(a2)
}
ffffffffc02035a0:	4501                	li	a0,0
ffffffffc02035a2:	8082                	ret
ffffffffc02035a4:	e114                	sd	a3,0(a0)
ffffffffc02035a6:	4501                	li	a0,0
ffffffffc02035a8:	8082                	ret
{
ffffffffc02035aa:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02035ac:	00003697          	auipc	a3,0x3
ffffffffc02035b0:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0205e88 <default_pmm_manager+0xbb8>
ffffffffc02035b4:	00002617          	auipc	a2,0x2
ffffffffc02035b8:	96c60613          	addi	a2,a2,-1684 # ffffffffc0204f20 <commands+0x798>
ffffffffc02035bc:	45f5                	li	a1,29
ffffffffc02035be:	00002517          	auipc	a0,0x2
ffffffffc02035c2:	75a50513          	addi	a0,a0,1882 # ffffffffc0205d18 <default_pmm_manager+0xa48>
{
ffffffffc02035c6:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02035c8:	db1fc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc02035cc <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035cc:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02035ce:	00003697          	auipc	a3,0x3
ffffffffc02035d2:	8f268693          	addi	a3,a3,-1806 # ffffffffc0205ec0 <default_pmm_manager+0xbf0>
ffffffffc02035d6:	00002617          	auipc	a2,0x2
ffffffffc02035da:	94a60613          	addi	a2,a2,-1718 # ffffffffc0204f20 <commands+0x798>
ffffffffc02035de:	07d00593          	li	a1,125
ffffffffc02035e2:	00003517          	auipc	a0,0x3
ffffffffc02035e6:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035ea:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02035ec:	d8dfc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc02035f0 <mm_create>:
mm_create(void) {
ffffffffc02035f0:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035f2:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02035f6:	e022                	sd	s0,0(sp)
ffffffffc02035f8:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035fa:	9deff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc02035fe:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203600:	c105                	beqz	a0,ffffffffc0203620 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0203602:	e408                	sd	a0,8(s0)
ffffffffc0203604:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203606:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020360a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020360e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203612:	0000e797          	auipc	a5,0xe
ffffffffc0203616:	f467a783          	lw	a5,-186(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc020361a:	eb81                	bnez	a5,ffffffffc020362a <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc020361c:	02053423          	sd	zero,40(a0)
}
ffffffffc0203620:	60a2                	ld	ra,8(sp)
ffffffffc0203622:	8522                	mv	a0,s0
ffffffffc0203624:	6402                	ld	s0,0(sp)
ffffffffc0203626:	0141                	addi	sp,sp,16
ffffffffc0203628:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020362a:	9bbff0ef          	jal	ra,ffffffffc0202fe4 <swap_init_mm>
}
ffffffffc020362e:	60a2                	ld	ra,8(sp)
ffffffffc0203630:	8522                	mv	a0,s0
ffffffffc0203632:	6402                	ld	s0,0(sp)
ffffffffc0203634:	0141                	addi	sp,sp,16
ffffffffc0203636:	8082                	ret

ffffffffc0203638 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203638:	1101                	addi	sp,sp,-32
ffffffffc020363a:	e04a                	sd	s2,0(sp)
ffffffffc020363c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020363e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203642:	e822                	sd	s0,16(sp)
ffffffffc0203644:	e426                	sd	s1,8(sp)
ffffffffc0203646:	ec06                	sd	ra,24(sp)
ffffffffc0203648:	84ae                	mv	s1,a1
ffffffffc020364a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020364c:	98cff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
    if (vma != NULL) {
ffffffffc0203650:	c509                	beqz	a0,ffffffffc020365a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203652:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203656:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203658:	ed00                	sd	s0,24(a0)
}
ffffffffc020365a:	60e2                	ld	ra,24(sp)
ffffffffc020365c:	6442                	ld	s0,16(sp)
ffffffffc020365e:	64a2                	ld	s1,8(sp)
ffffffffc0203660:	6902                	ld	s2,0(sp)
ffffffffc0203662:	6105                	addi	sp,sp,32
ffffffffc0203664:	8082                	ret

ffffffffc0203666 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203666:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203668:	c505                	beqz	a0,ffffffffc0203690 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020366a:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020366c:	c501                	beqz	a0,ffffffffc0203674 <find_vma+0xe>
ffffffffc020366e:	651c                	ld	a5,8(a0)
ffffffffc0203670:	02f5f263          	bgeu	a1,a5,ffffffffc0203694 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203674:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203676:	00f68d63          	beq	a3,a5,ffffffffc0203690 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020367a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020367e:	00e5e663          	bltu	a1,a4,ffffffffc020368a <find_vma+0x24>
ffffffffc0203682:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203686:	00e5ec63          	bltu	a1,a4,ffffffffc020369e <find_vma+0x38>
ffffffffc020368a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020368c:	fef697e3          	bne	a3,a5,ffffffffc020367a <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203690:	4501                	li	a0,0
}
ffffffffc0203692:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203694:	691c                	ld	a5,16(a0)
ffffffffc0203696:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203674 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020369a:	ea88                	sd	a0,16(a3)
ffffffffc020369c:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020369e:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02036a2:	ea88                	sd	a0,16(a3)
ffffffffc02036a4:	8082                	ret

ffffffffc02036a6 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036a6:	6590                	ld	a2,8(a1)
ffffffffc02036a8:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02036ac:	1141                	addi	sp,sp,-16
ffffffffc02036ae:	e406                	sd	ra,8(sp)
ffffffffc02036b0:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036b2:	01066763          	bltu	a2,a6,ffffffffc02036c0 <insert_vma_struct+0x1a>
ffffffffc02036b6:	a085                	j	ffffffffc0203716 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02036b8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02036bc:	04e66863          	bltu	a2,a4,ffffffffc020370c <insert_vma_struct+0x66>
ffffffffc02036c0:	86be                	mv	a3,a5
ffffffffc02036c2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02036c4:	fef51ae3          	bne	a0,a5,ffffffffc02036b8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02036c8:	02a68463          	beq	a3,a0,ffffffffc02036f0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02036cc:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036d0:	fe86b883          	ld	a7,-24(a3)
ffffffffc02036d4:	08e8f163          	bgeu	a7,a4,ffffffffc0203756 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036d8:	04e66f63          	bltu	a2,a4,ffffffffc0203736 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02036dc:	00f50a63          	beq	a0,a5,ffffffffc02036f0 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02036e0:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036e4:	05076963          	bltu	a4,a6,ffffffffc0203736 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036e8:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036ec:	02c77363          	bgeu	a4,a2,ffffffffc0203712 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02036f0:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036f2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036f4:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036f8:	e390                	sd	a2,0(a5)
ffffffffc02036fa:	e690                	sd	a2,8(a3)
}
ffffffffc02036fc:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036fe:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203700:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0203702:	0017079b          	addiw	a5,a4,1
ffffffffc0203706:	d11c                	sw	a5,32(a0)
}
ffffffffc0203708:	0141                	addi	sp,sp,16
ffffffffc020370a:	8082                	ret
    if (le_prev != list) {
ffffffffc020370c:	fca690e3          	bne	a3,a0,ffffffffc02036cc <insert_vma_struct+0x26>
ffffffffc0203710:	bfd1                	j	ffffffffc02036e4 <insert_vma_struct+0x3e>
ffffffffc0203712:	ebbff0ef          	jal	ra,ffffffffc02035cc <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203716:	00002697          	auipc	a3,0x2
ffffffffc020371a:	7da68693          	addi	a3,a3,2010 # ffffffffc0205ef0 <default_pmm_manager+0xc20>
ffffffffc020371e:	00002617          	auipc	a2,0x2
ffffffffc0203722:	80260613          	addi	a2,a2,-2046 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203726:	08400593          	li	a1,132
ffffffffc020372a:	00002517          	auipc	a0,0x2
ffffffffc020372e:	7b650513          	addi	a0,a0,1974 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203732:	c47fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203736:	00002697          	auipc	a3,0x2
ffffffffc020373a:	7fa68693          	addi	a3,a3,2042 # ffffffffc0205f30 <default_pmm_manager+0xc60>
ffffffffc020373e:	00001617          	auipc	a2,0x1
ffffffffc0203742:	7e260613          	addi	a2,a2,2018 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203746:	07c00593          	li	a1,124
ffffffffc020374a:	00002517          	auipc	a0,0x2
ffffffffc020374e:	79650513          	addi	a0,a0,1942 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203752:	c27fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203756:	00002697          	auipc	a3,0x2
ffffffffc020375a:	7ba68693          	addi	a3,a3,1978 # ffffffffc0205f10 <default_pmm_manager+0xc40>
ffffffffc020375e:	00001617          	auipc	a2,0x1
ffffffffc0203762:	7c260613          	addi	a2,a2,1986 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203766:	07b00593          	li	a1,123
ffffffffc020376a:	00002517          	auipc	a0,0x2
ffffffffc020376e:	77650513          	addi	a0,a0,1910 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203772:	c07fc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0203776 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203776:	1141                	addi	sp,sp,-16
ffffffffc0203778:	e022                	sd	s0,0(sp)
ffffffffc020377a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020377c:	6508                	ld	a0,8(a0)
ffffffffc020377e:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203780:	00a40e63          	beq	s0,a0,ffffffffc020379c <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203784:	6118                	ld	a4,0(a0)
ffffffffc0203786:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203788:	03000593          	li	a1,48
ffffffffc020378c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020378e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203790:	e398                	sd	a4,0(a5)
ffffffffc0203792:	900ff0ef          	jal	ra,ffffffffc0202892 <kfree>
    return listelm->next;
ffffffffc0203796:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203798:	fea416e3          	bne	s0,a0,ffffffffc0203784 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020379c:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020379e:	6402                	ld	s0,0(sp)
ffffffffc02037a0:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02037a2:	03000593          	li	a1,48
}
ffffffffc02037a6:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02037a8:	8eaff06f          	j	ffffffffc0202892 <kfree>

ffffffffc02037ac <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02037ac:	715d                	addi	sp,sp,-80
ffffffffc02037ae:	e486                	sd	ra,72(sp)
ffffffffc02037b0:	f44e                	sd	s3,40(sp)
ffffffffc02037b2:	f052                	sd	s4,32(sp)
ffffffffc02037b4:	e0a2                	sd	s0,64(sp)
ffffffffc02037b6:	fc26                	sd	s1,56(sp)
ffffffffc02037b8:	f84a                	sd	s2,48(sp)
ffffffffc02037ba:	ec56                	sd	s5,24(sp)
ffffffffc02037bc:	e85a                	sd	s6,16(sp)
ffffffffc02037be:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037c0:	f33fd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc02037c4:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037c6:	f2dfd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc02037ca:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037cc:	03000513          	li	a0,48
ffffffffc02037d0:	808ff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
    if (mm != NULL) {
ffffffffc02037d4:	56050863          	beqz	a0,ffffffffc0203d44 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc02037d8:	e508                	sd	a0,8(a0)
ffffffffc02037da:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02037dc:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037e0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037e4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037e8:	0000e797          	auipc	a5,0xe
ffffffffc02037ec:	d707a783          	lw	a5,-656(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc02037f0:	84aa                	mv	s1,a0
ffffffffc02037f2:	e7b9                	bnez	a5,ffffffffc0203840 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc02037f4:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02037f8:	03200413          	li	s0,50
ffffffffc02037fc:	a811                	j	ffffffffc0203810 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02037fe:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203800:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203802:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0203806:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203808:	8526                	mv	a0,s1
ffffffffc020380a:	e9dff0ef          	jal	ra,ffffffffc02036a6 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020380e:	cc05                	beqz	s0,ffffffffc0203846 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203810:	03000513          	li	a0,48
ffffffffc0203814:	fc5fe0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc0203818:	85aa                	mv	a1,a0
ffffffffc020381a:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020381e:	f165                	bnez	a0,ffffffffc02037fe <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0203820:	00002697          	auipc	a3,0x2
ffffffffc0203824:	1e068693          	addi	a3,a3,480 # ffffffffc0205a00 <default_pmm_manager+0x730>
ffffffffc0203828:	00001617          	auipc	a2,0x1
ffffffffc020382c:	6f860613          	addi	a2,a2,1784 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203830:	0ce00593          	li	a1,206
ffffffffc0203834:	00002517          	auipc	a0,0x2
ffffffffc0203838:	6ac50513          	addi	a0,a0,1708 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc020383c:	b3dfc0ef          	jal	ra,ffffffffc0200378 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203840:	fa4ff0ef          	jal	ra,ffffffffc0202fe4 <swap_init_mm>
ffffffffc0203844:	bf55                	j	ffffffffc02037f8 <vmm_init+0x4c>
ffffffffc0203846:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020384a:	1f900913          	li	s2,505
ffffffffc020384e:	a819                	j	ffffffffc0203864 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0203850:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203852:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203854:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203858:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020385a:	8526                	mv	a0,s1
ffffffffc020385c:	e4bff0ef          	jal	ra,ffffffffc02036a6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203860:	03240a63          	beq	s0,s2,ffffffffc0203894 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203864:	03000513          	li	a0,48
ffffffffc0203868:	f71fe0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc020386c:	85aa                	mv	a1,a0
ffffffffc020386e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203872:	fd79                	bnez	a0,ffffffffc0203850 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0203874:	00002697          	auipc	a3,0x2
ffffffffc0203878:	18c68693          	addi	a3,a3,396 # ffffffffc0205a00 <default_pmm_manager+0x730>
ffffffffc020387c:	00001617          	auipc	a2,0x1
ffffffffc0203880:	6a460613          	addi	a2,a2,1700 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203884:	0d400593          	li	a1,212
ffffffffc0203888:	00002517          	auipc	a0,0x2
ffffffffc020388c:	65850513          	addi	a0,a0,1624 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203890:	ae9fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    return listelm->next;
ffffffffc0203894:	649c                	ld	a5,8(s1)
ffffffffc0203896:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203898:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020389c:	2ef48463          	beq	s1,a5,ffffffffc0203b84 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02038a0:	fe87b603          	ld	a2,-24(a5)
ffffffffc02038a4:	ffe70693          	addi	a3,a4,-2
ffffffffc02038a8:	26d61e63          	bne	a2,a3,ffffffffc0203b24 <vmm_init+0x378>
ffffffffc02038ac:	ff07b683          	ld	a3,-16(a5)
ffffffffc02038b0:	26e69a63          	bne	a3,a4,ffffffffc0203b24 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc02038b4:	0715                	addi	a4,a4,5
ffffffffc02038b6:	679c                	ld	a5,8(a5)
ffffffffc02038b8:	feb712e3          	bne	a4,a1,ffffffffc020389c <vmm_init+0xf0>
ffffffffc02038bc:	4b1d                	li	s6,7
ffffffffc02038be:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02038c0:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02038c4:	85a2                	mv	a1,s0
ffffffffc02038c6:	8526                	mv	a0,s1
ffffffffc02038c8:	d9fff0ef          	jal	ra,ffffffffc0203666 <find_vma>
ffffffffc02038cc:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02038ce:	2c050b63          	beqz	a0,ffffffffc0203ba4 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02038d2:	00140593          	addi	a1,s0,1
ffffffffc02038d6:	8526                	mv	a0,s1
ffffffffc02038d8:	d8fff0ef          	jal	ra,ffffffffc0203666 <find_vma>
ffffffffc02038dc:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02038de:	2e050363          	beqz	a0,ffffffffc0203bc4 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02038e2:	85da                	mv	a1,s6
ffffffffc02038e4:	8526                	mv	a0,s1
ffffffffc02038e6:	d81ff0ef          	jal	ra,ffffffffc0203666 <find_vma>
        assert(vma3 == NULL);
ffffffffc02038ea:	2e051d63          	bnez	a0,ffffffffc0203be4 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02038ee:	00340593          	addi	a1,s0,3
ffffffffc02038f2:	8526                	mv	a0,s1
ffffffffc02038f4:	d73ff0ef          	jal	ra,ffffffffc0203666 <find_vma>
        assert(vma4 == NULL);
ffffffffc02038f8:	30051663          	bnez	a0,ffffffffc0203c04 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02038fc:	00440593          	addi	a1,s0,4
ffffffffc0203900:	8526                	mv	a0,s1
ffffffffc0203902:	d65ff0ef          	jal	ra,ffffffffc0203666 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203906:	30051f63          	bnez	a0,ffffffffc0203c24 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020390a:	00893783          	ld	a5,8(s2)
ffffffffc020390e:	24879b63          	bne	a5,s0,ffffffffc0203b64 <vmm_init+0x3b8>
ffffffffc0203912:	01093783          	ld	a5,16(s2)
ffffffffc0203916:	25679763          	bne	a5,s6,ffffffffc0203b64 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020391a:	008ab783          	ld	a5,8(s5)
ffffffffc020391e:	22879363          	bne	a5,s0,ffffffffc0203b44 <vmm_init+0x398>
ffffffffc0203922:	010ab783          	ld	a5,16(s5)
ffffffffc0203926:	21679f63          	bne	a5,s6,ffffffffc0203b44 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020392a:	0415                	addi	s0,s0,5
ffffffffc020392c:	0b15                	addi	s6,s6,5
ffffffffc020392e:	f9741be3          	bne	s0,s7,ffffffffc02038c4 <vmm_init+0x118>
ffffffffc0203932:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203934:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203936:	85a2                	mv	a1,s0
ffffffffc0203938:	8526                	mv	a0,s1
ffffffffc020393a:	d2dff0ef          	jal	ra,ffffffffc0203666 <find_vma>
ffffffffc020393e:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203942:	c90d                	beqz	a0,ffffffffc0203974 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203944:	6914                	ld	a3,16(a0)
ffffffffc0203946:	6510                	ld	a2,8(a0)
ffffffffc0203948:	00002517          	auipc	a0,0x2
ffffffffc020394c:	70850513          	addi	a0,a0,1800 # ffffffffc0206050 <default_pmm_manager+0xd80>
ffffffffc0203950:	f6efc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203954:	00002697          	auipc	a3,0x2
ffffffffc0203958:	72468693          	addi	a3,a3,1828 # ffffffffc0206078 <default_pmm_manager+0xda8>
ffffffffc020395c:	00001617          	auipc	a2,0x1
ffffffffc0203960:	5c460613          	addi	a2,a2,1476 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203964:	0f600593          	li	a1,246
ffffffffc0203968:	00002517          	auipc	a0,0x2
ffffffffc020396c:	57850513          	addi	a0,a0,1400 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203970:	a09fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203974:	147d                	addi	s0,s0,-1
ffffffffc0203976:	fd2410e3          	bne	s0,s2,ffffffffc0203936 <vmm_init+0x18a>
ffffffffc020397a:	a811                	j	ffffffffc020398e <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc020397c:	6118                	ld	a4,0(a0)
ffffffffc020397e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203980:	03000593          	li	a1,48
ffffffffc0203984:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203986:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203988:	e398                	sd	a4,0(a5)
ffffffffc020398a:	f09fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    return listelm->next;
ffffffffc020398e:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203990:	fea496e3          	bne	s1,a0,ffffffffc020397c <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203994:	03000593          	li	a1,48
ffffffffc0203998:	8526                	mv	a0,s1
ffffffffc020399a:	ef9fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020399e:	d55fd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc02039a2:	3caa1163          	bne	s4,a0,ffffffffc0203d64 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02039a6:	00002517          	auipc	a0,0x2
ffffffffc02039aa:	71250513          	addi	a0,a0,1810 # ffffffffc02060b8 <default_pmm_manager+0xde8>
ffffffffc02039ae:	f10fc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02039b2:	d41fd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc02039b6:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02039b8:	03000513          	li	a0,48
ffffffffc02039bc:	e1dfe0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc02039c0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02039c2:	2a050163          	beqz	a0,ffffffffc0203c64 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039c6:	0000e797          	auipc	a5,0xe
ffffffffc02039ca:	b927a783          	lw	a5,-1134(a5) # ffffffffc0211558 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc02039ce:	e508                	sd	a0,8(a0)
ffffffffc02039d0:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02039d2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02039d6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02039da:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039de:	14079063          	bnez	a5,ffffffffc0203b1e <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc02039e2:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02039e6:	0000e917          	auipc	s2,0xe
ffffffffc02039ea:	b3a93903          	ld	s2,-1222(s2) # ffffffffc0211520 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02039ee:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02039f2:	0000e717          	auipc	a4,0xe
ffffffffc02039f6:	b6873b23          	sd	s0,-1162(a4) # ffffffffc0211568 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02039fa:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02039fe:	24079363          	bnez	a5,ffffffffc0203c44 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a02:	03000513          	li	a0,48
ffffffffc0203a06:	dd3fe0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc0203a0a:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203a0c:	28050063          	beqz	a0,ffffffffc0203c8c <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0203a10:	002007b7          	lui	a5,0x200
ffffffffc0203a14:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203a18:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203a1a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203a1c:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203a20:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203a22:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203a26:	c81ff0ef          	jal	ra,ffffffffc02036a6 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a2a:	10000593          	li	a1,256
ffffffffc0203a2e:	8522                	mv	a0,s0
ffffffffc0203a30:	c37ff0ef          	jal	ra,ffffffffc0203666 <find_vma>
ffffffffc0203a34:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203a38:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a3c:	26aa1863          	bne	s4,a0,ffffffffc0203cac <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0203a40:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203a44:	0785                	addi	a5,a5,1
ffffffffc0203a46:	fee79de3          	bne	a5,a4,ffffffffc0203a40 <vmm_init+0x294>
        sum += i;
ffffffffc0203a4a:	6705                	lui	a4,0x1
ffffffffc0203a4c:	10000793          	li	a5,256
ffffffffc0203a50:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203a54:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203a58:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203a5c:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203a5e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203a60:	fec79ce3          	bne	a5,a2,ffffffffc0203a58 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0203a64:	26071463          	bnez	a4,ffffffffc0203ccc <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203a68:	4581                	li	a1,0
ffffffffc0203a6a:	854a                	mv	a0,s2
ffffffffc0203a6c:	f11fd0ef          	jal	ra,ffffffffc020197c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a70:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203a74:	0000e717          	auipc	a4,0xe
ffffffffc0203a78:	ab473703          	ld	a4,-1356(a4) # ffffffffc0211528 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a7c:	078a                	slli	a5,a5,0x2
ffffffffc0203a7e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a80:	26e7f663          	bgeu	a5,a4,ffffffffc0203cec <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a84:	00003717          	auipc	a4,0x3
ffffffffc0203a88:	a2c73703          	ld	a4,-1492(a4) # ffffffffc02064b0 <nbase>
ffffffffc0203a8c:	8f99                	sub	a5,a5,a4
ffffffffc0203a8e:	00379713          	slli	a4,a5,0x3
ffffffffc0203a92:	97ba                	add	a5,a5,a4
ffffffffc0203a94:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203a96:	0000e517          	auipc	a0,0xe
ffffffffc0203a9a:	a9a53503          	ld	a0,-1382(a0) # ffffffffc0211530 <pages>
ffffffffc0203a9e:	953e                	add	a0,a0,a5
ffffffffc0203aa0:	4585                	li	a1,1
ffffffffc0203aa2:	c11fd0ef          	jal	ra,ffffffffc02016b2 <free_pages>
    return listelm->next;
ffffffffc0203aa6:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203aa8:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203aac:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203ab0:	00a40e63          	beq	s0,a0,ffffffffc0203acc <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203ab4:	6118                	ld	a4,0(a0)
ffffffffc0203ab6:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203ab8:	03000593          	li	a1,48
ffffffffc0203abc:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203abe:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203ac0:	e398                	sd	a4,0(a5)
ffffffffc0203ac2:	dd1fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    return listelm->next;
ffffffffc0203ac6:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203ac8:	fea416e3          	bne	s0,a0,ffffffffc0203ab4 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203acc:	03000593          	li	a1,48
ffffffffc0203ad0:	8522                	mv	a0,s0
ffffffffc0203ad2:	dc1fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203ad6:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203ad8:	0000e797          	auipc	a5,0xe
ffffffffc0203adc:	a807b823          	sd	zero,-1392(a5) # ffffffffc0211568 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ae0:	c13fd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc0203ae4:	22a49063          	bne	s1,a0,ffffffffc0203d04 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203ae8:	00002517          	auipc	a0,0x2
ffffffffc0203aec:	62050513          	addi	a0,a0,1568 # ffffffffc0206108 <default_pmm_manager+0xe38>
ffffffffc0203af0:	dcefc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203af4:	bfffd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203af8:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203afa:	22a99563          	bne	s3,a0,ffffffffc0203d24 <vmm_init+0x578>
}
ffffffffc0203afe:	6406                	ld	s0,64(sp)
ffffffffc0203b00:	60a6                	ld	ra,72(sp)
ffffffffc0203b02:	74e2                	ld	s1,56(sp)
ffffffffc0203b04:	7942                	ld	s2,48(sp)
ffffffffc0203b06:	79a2                	ld	s3,40(sp)
ffffffffc0203b08:	7a02                	ld	s4,32(sp)
ffffffffc0203b0a:	6ae2                	ld	s5,24(sp)
ffffffffc0203b0c:	6b42                	ld	s6,16(sp)
ffffffffc0203b0e:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b10:	00002517          	auipc	a0,0x2
ffffffffc0203b14:	61850513          	addi	a0,a0,1560 # ffffffffc0206128 <default_pmm_manager+0xe58>
}
ffffffffc0203b18:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b1a:	da4fc06f          	j	ffffffffc02000be <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203b1e:	cc6ff0ef          	jal	ra,ffffffffc0202fe4 <swap_init_mm>
ffffffffc0203b22:	b5d1                	j	ffffffffc02039e6 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b24:	00002697          	auipc	a3,0x2
ffffffffc0203b28:	44468693          	addi	a3,a3,1092 # ffffffffc0205f68 <default_pmm_manager+0xc98>
ffffffffc0203b2c:	00001617          	auipc	a2,0x1
ffffffffc0203b30:	3f460613          	addi	a2,a2,1012 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203b34:	0dd00593          	li	a1,221
ffffffffc0203b38:	00002517          	auipc	a0,0x2
ffffffffc0203b3c:	3a850513          	addi	a0,a0,936 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203b40:	839fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b44:	00002697          	auipc	a3,0x2
ffffffffc0203b48:	4dc68693          	addi	a3,a3,1244 # ffffffffc0206020 <default_pmm_manager+0xd50>
ffffffffc0203b4c:	00001617          	auipc	a2,0x1
ffffffffc0203b50:	3d460613          	addi	a2,a2,980 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203b54:	0ee00593          	li	a1,238
ffffffffc0203b58:	00002517          	auipc	a0,0x2
ffffffffc0203b5c:	38850513          	addi	a0,a0,904 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203b60:	819fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b64:	00002697          	auipc	a3,0x2
ffffffffc0203b68:	48c68693          	addi	a3,a3,1164 # ffffffffc0205ff0 <default_pmm_manager+0xd20>
ffffffffc0203b6c:	00001617          	auipc	a2,0x1
ffffffffc0203b70:	3b460613          	addi	a2,a2,948 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203b74:	0ed00593          	li	a1,237
ffffffffc0203b78:	00002517          	auipc	a0,0x2
ffffffffc0203b7c:	36850513          	addi	a0,a0,872 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203b80:	ff8fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203b84:	00002697          	auipc	a3,0x2
ffffffffc0203b88:	3cc68693          	addi	a3,a3,972 # ffffffffc0205f50 <default_pmm_manager+0xc80>
ffffffffc0203b8c:	00001617          	auipc	a2,0x1
ffffffffc0203b90:	39460613          	addi	a2,a2,916 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203b94:	0db00593          	li	a1,219
ffffffffc0203b98:	00002517          	auipc	a0,0x2
ffffffffc0203b9c:	34850513          	addi	a0,a0,840 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203ba0:	fd8fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(vma1 != NULL);
ffffffffc0203ba4:	00002697          	auipc	a3,0x2
ffffffffc0203ba8:	3fc68693          	addi	a3,a3,1020 # ffffffffc0205fa0 <default_pmm_manager+0xcd0>
ffffffffc0203bac:	00001617          	auipc	a2,0x1
ffffffffc0203bb0:	37460613          	addi	a2,a2,884 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203bb4:	0e300593          	li	a1,227
ffffffffc0203bb8:	00002517          	auipc	a0,0x2
ffffffffc0203bbc:	32850513          	addi	a0,a0,808 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203bc0:	fb8fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(vma2 != NULL);
ffffffffc0203bc4:	00002697          	auipc	a3,0x2
ffffffffc0203bc8:	3ec68693          	addi	a3,a3,1004 # ffffffffc0205fb0 <default_pmm_manager+0xce0>
ffffffffc0203bcc:	00001617          	auipc	a2,0x1
ffffffffc0203bd0:	35460613          	addi	a2,a2,852 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203bd4:	0e500593          	li	a1,229
ffffffffc0203bd8:	00002517          	auipc	a0,0x2
ffffffffc0203bdc:	30850513          	addi	a0,a0,776 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203be0:	f98fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(vma3 == NULL);
ffffffffc0203be4:	00002697          	auipc	a3,0x2
ffffffffc0203be8:	3dc68693          	addi	a3,a3,988 # ffffffffc0205fc0 <default_pmm_manager+0xcf0>
ffffffffc0203bec:	00001617          	auipc	a2,0x1
ffffffffc0203bf0:	33460613          	addi	a2,a2,820 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203bf4:	0e700593          	li	a1,231
ffffffffc0203bf8:	00002517          	auipc	a0,0x2
ffffffffc0203bfc:	2e850513          	addi	a0,a0,744 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203c00:	f78fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(vma4 == NULL);
ffffffffc0203c04:	00002697          	auipc	a3,0x2
ffffffffc0203c08:	3cc68693          	addi	a3,a3,972 # ffffffffc0205fd0 <default_pmm_manager+0xd00>
ffffffffc0203c0c:	00001617          	auipc	a2,0x1
ffffffffc0203c10:	31460613          	addi	a2,a2,788 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203c14:	0e900593          	li	a1,233
ffffffffc0203c18:	00002517          	auipc	a0,0x2
ffffffffc0203c1c:	2c850513          	addi	a0,a0,712 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203c20:	f58fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        assert(vma5 == NULL);
ffffffffc0203c24:	00002697          	auipc	a3,0x2
ffffffffc0203c28:	3bc68693          	addi	a3,a3,956 # ffffffffc0205fe0 <default_pmm_manager+0xd10>
ffffffffc0203c2c:	00001617          	auipc	a2,0x1
ffffffffc0203c30:	2f460613          	addi	a2,a2,756 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203c34:	0eb00593          	li	a1,235
ffffffffc0203c38:	00002517          	auipc	a0,0x2
ffffffffc0203c3c:	2a850513          	addi	a0,a0,680 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203c40:	f38fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203c44:	00002697          	auipc	a3,0x2
ffffffffc0203c48:	dac68693          	addi	a3,a3,-596 # ffffffffc02059f0 <default_pmm_manager+0x720>
ffffffffc0203c4c:	00001617          	auipc	a2,0x1
ffffffffc0203c50:	2d460613          	addi	a2,a2,724 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203c54:	10d00593          	li	a1,269
ffffffffc0203c58:	00002517          	auipc	a0,0x2
ffffffffc0203c5c:	28850513          	addi	a0,a0,648 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203c60:	f18fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203c64:	00002697          	auipc	a3,0x2
ffffffffc0203c68:	4dc68693          	addi	a3,a3,1244 # ffffffffc0206140 <default_pmm_manager+0xe70>
ffffffffc0203c6c:	00001617          	auipc	a2,0x1
ffffffffc0203c70:	2b460613          	addi	a2,a2,692 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203c74:	10a00593          	li	a1,266
ffffffffc0203c78:	00002517          	auipc	a0,0x2
ffffffffc0203c7c:	26850513          	addi	a0,a0,616 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
    check_mm_struct = mm_create();
ffffffffc0203c80:	0000e797          	auipc	a5,0xe
ffffffffc0203c84:	8e07b423          	sd	zero,-1816(a5) # ffffffffc0211568 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203c88:	ef0fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(vma != NULL);
ffffffffc0203c8c:	00002697          	auipc	a3,0x2
ffffffffc0203c90:	d7468693          	addi	a3,a3,-652 # ffffffffc0205a00 <default_pmm_manager+0x730>
ffffffffc0203c94:	00001617          	auipc	a2,0x1
ffffffffc0203c98:	28c60613          	addi	a2,a2,652 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203c9c:	11100593          	li	a1,273
ffffffffc0203ca0:	00002517          	auipc	a0,0x2
ffffffffc0203ca4:	24050513          	addi	a0,a0,576 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203ca8:	ed0fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203cac:	00002697          	auipc	a3,0x2
ffffffffc0203cb0:	42c68693          	addi	a3,a3,1068 # ffffffffc02060d8 <default_pmm_manager+0xe08>
ffffffffc0203cb4:	00001617          	auipc	a2,0x1
ffffffffc0203cb8:	26c60613          	addi	a2,a2,620 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203cbc:	11600593          	li	a1,278
ffffffffc0203cc0:	00002517          	auipc	a0,0x2
ffffffffc0203cc4:	22050513          	addi	a0,a0,544 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203cc8:	eb0fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(sum == 0);
ffffffffc0203ccc:	00002697          	auipc	a3,0x2
ffffffffc0203cd0:	42c68693          	addi	a3,a3,1068 # ffffffffc02060f8 <default_pmm_manager+0xe28>
ffffffffc0203cd4:	00001617          	auipc	a2,0x1
ffffffffc0203cd8:	24c60613          	addi	a2,a2,588 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203cdc:	12000593          	li	a1,288
ffffffffc0203ce0:	00002517          	auipc	a0,0x2
ffffffffc0203ce4:	20050513          	addi	a0,a0,512 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203ce8:	e90fc0ef          	jal	ra,ffffffffc0200378 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203cec:	00001617          	auipc	a2,0x1
ffffffffc0203cf0:	61c60613          	addi	a2,a2,1564 # ffffffffc0205308 <default_pmm_manager+0x38>
ffffffffc0203cf4:	06500593          	li	a1,101
ffffffffc0203cf8:	00001517          	auipc	a0,0x1
ffffffffc0203cfc:	63050513          	addi	a0,a0,1584 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc0203d00:	e78fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d04:	00002697          	auipc	a3,0x2
ffffffffc0203d08:	38c68693          	addi	a3,a3,908 # ffffffffc0206090 <default_pmm_manager+0xdc0>
ffffffffc0203d0c:	00001617          	auipc	a2,0x1
ffffffffc0203d10:	21460613          	addi	a2,a2,532 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203d14:	12e00593          	li	a1,302
ffffffffc0203d18:	00002517          	auipc	a0,0x2
ffffffffc0203d1c:	1c850513          	addi	a0,a0,456 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203d20:	e58fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d24:	00002697          	auipc	a3,0x2
ffffffffc0203d28:	36c68693          	addi	a3,a3,876 # ffffffffc0206090 <default_pmm_manager+0xdc0>
ffffffffc0203d2c:	00001617          	auipc	a2,0x1
ffffffffc0203d30:	1f460613          	addi	a2,a2,500 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203d34:	0bd00593          	li	a1,189
ffffffffc0203d38:	00002517          	auipc	a0,0x2
ffffffffc0203d3c:	1a850513          	addi	a0,a0,424 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203d40:	e38fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(mm != NULL);
ffffffffc0203d44:	00002697          	auipc	a3,0x2
ffffffffc0203d48:	c8468693          	addi	a3,a3,-892 # ffffffffc02059c8 <default_pmm_manager+0x6f8>
ffffffffc0203d4c:	00001617          	auipc	a2,0x1
ffffffffc0203d50:	1d460613          	addi	a2,a2,468 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203d54:	0c700593          	li	a1,199
ffffffffc0203d58:	00002517          	auipc	a0,0x2
ffffffffc0203d5c:	18850513          	addi	a0,a0,392 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203d60:	e18fc0ef          	jal	ra,ffffffffc0200378 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d64:	00002697          	auipc	a3,0x2
ffffffffc0203d68:	32c68693          	addi	a3,a3,812 # ffffffffc0206090 <default_pmm_manager+0xdc0>
ffffffffc0203d6c:	00001617          	auipc	a2,0x1
ffffffffc0203d70:	1b460613          	addi	a2,a2,436 # ffffffffc0204f20 <commands+0x798>
ffffffffc0203d74:	0fb00593          	li	a1,251
ffffffffc0203d78:	00002517          	auipc	a0,0x2
ffffffffc0203d7c:	16850513          	addi	a0,a0,360 # ffffffffc0205ee0 <default_pmm_manager+0xc10>
ffffffffc0203d80:	df8fc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0203d84 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d84:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d86:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d88:	f022                	sd	s0,32(sp)
ffffffffc0203d8a:	ec26                	sd	s1,24(sp)
ffffffffc0203d8c:	f406                	sd	ra,40(sp)
ffffffffc0203d8e:	e84a                	sd	s2,16(sp)
ffffffffc0203d90:	8432                	mv	s0,a2
ffffffffc0203d92:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d94:	8d3ff0ef          	jal	ra,ffffffffc0203666 <find_vma>

    pgfault_num++;
ffffffffc0203d98:	0000d797          	auipc	a5,0xd
ffffffffc0203d9c:	7d87a783          	lw	a5,2008(a5) # ffffffffc0211570 <pgfault_num>
ffffffffc0203da0:	2785                	addiw	a5,a5,1
ffffffffc0203da2:	0000d717          	auipc	a4,0xd
ffffffffc0203da6:	7cf72723          	sw	a5,1998(a4) # ffffffffc0211570 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203daa:	c549                	beqz	a0,ffffffffc0203e34 <do_pgfault+0xb0>
ffffffffc0203dac:	651c                	ld	a5,8(a0)
ffffffffc0203dae:	08f46363          	bltu	s0,a5,ffffffffc0203e34 <do_pgfault+0xb0>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203db2:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203db4:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203db6:	8b89                	andi	a5,a5,2
ffffffffc0203db8:	efa9                	bnez	a5,ffffffffc0203e12 <do_pgfault+0x8e>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203dba:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203dbc:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203dbe:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203dc0:	85a2                	mv	a1,s0
ffffffffc0203dc2:	4605                	li	a2,1
ffffffffc0203dc4:	969fd0ef          	jal	ra,ffffffffc020172c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203dc8:	610c                	ld	a1,0(a0)
ffffffffc0203dca:	c5b1                	beqz	a1,ffffffffc0203e16 <do_pgfault+0x92>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203dcc:	0000d797          	auipc	a5,0xd
ffffffffc0203dd0:	78c7a783          	lw	a5,1932(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203dd4:	cbad                	beqz	a5,ffffffffc0203e46 <do_pgfault+0xc2>
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.           
            // 检查 swap_in 是否成功
            if(swap_in(mm, addr, &page) !=0)
ffffffffc0203dd6:	0030                	addi	a2,sp,8
ffffffffc0203dd8:	85a2                	mv	a1,s0
ffffffffc0203dda:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203ddc:	e402                	sd	zero,8(sp)
            if(swap_in(mm, addr, &page) !=0)
ffffffffc0203dde:	b32ff0ef          	jal	ra,ffffffffc0203110 <swap_in>
ffffffffc0203de2:	e935                	bnez	a0,ffffffffc0203e56 <do_pgfault+0xd2>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr                     
            // 检查映射是否成功
            if(page_insert(mm->pgdir, page, addr, perm) != 0)
ffffffffc0203de4:	65a2                	ld	a1,8(sp)
ffffffffc0203de6:	6c88                	ld	a0,24(s1)
ffffffffc0203de8:	86ca                	mv	a3,s2
ffffffffc0203dea:	8622                	mv	a2,s0
ffffffffc0203dec:	c2bfd0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0203df0:	892a                	mv	s2,a0
ffffffffc0203df2:	e935                	bnez	a0,ffffffffc0203e66 <do_pgfault+0xe2>
            	cprintf("page_insert failed! \n");
            	goto failed;
            }
            
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 0);         
ffffffffc0203df4:	6622                	ld	a2,8(sp)
ffffffffc0203df6:	4681                	li	a3,0
ffffffffc0203df8:	85a2                	mv	a1,s0
ffffffffc0203dfa:	8526                	mv	a0,s1
ffffffffc0203dfc:	9f4ff0ef          	jal	ra,ffffffffc0202ff0 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203e00:	67a2                	ld	a5,8(sp)
ffffffffc0203e02:	e3a0                	sd	s0,64(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc0203e04:	70a2                	ld	ra,40(sp)
ffffffffc0203e06:	7402                	ld	s0,32(sp)
ffffffffc0203e08:	64e2                	ld	s1,24(sp)
ffffffffc0203e0a:	854a                	mv	a0,s2
ffffffffc0203e0c:	6942                	ld	s2,16(sp)
ffffffffc0203e0e:	6145                	addi	sp,sp,48
ffffffffc0203e10:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203e12:	4959                	li	s2,22
ffffffffc0203e14:	b75d                	j	ffffffffc0203dba <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203e16:	6c88                	ld	a0,24(s1)
ffffffffc0203e18:	864a                	mv	a2,s2
ffffffffc0203e1a:	85a2                	mv	a1,s0
ffffffffc0203e1c:	905fe0ef          	jal	ra,ffffffffc0202720 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203e20:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203e22:	f16d                	bnez	a0,ffffffffc0203e04 <do_pgfault+0x80>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203e24:	00002517          	auipc	a0,0x2
ffffffffc0203e28:	36450513          	addi	a0,a0,868 # ffffffffc0206188 <default_pmm_manager+0xeb8>
ffffffffc0203e2c:	a92fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e30:	5971                	li	s2,-4
            goto failed;
ffffffffc0203e32:	bfc9                	j	ffffffffc0203e04 <do_pgfault+0x80>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203e34:	85a2                	mv	a1,s0
ffffffffc0203e36:	00002517          	auipc	a0,0x2
ffffffffc0203e3a:	32250513          	addi	a0,a0,802 # ffffffffc0206158 <default_pmm_manager+0xe88>
ffffffffc0203e3e:	a80fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203e42:	5975                	li	s2,-3
        goto failed;
ffffffffc0203e44:	b7c1                	j	ffffffffc0203e04 <do_pgfault+0x80>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203e46:	00002517          	auipc	a0,0x2
ffffffffc0203e4a:	39a50513          	addi	a0,a0,922 # ffffffffc02061e0 <default_pmm_manager+0xf10>
ffffffffc0203e4e:	a70fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e52:	5971                	li	s2,-4
            goto failed;
ffffffffc0203e54:	bf45                	j	ffffffffc0203e04 <do_pgfault+0x80>
            	cprintf("swap_in failed! \n");
ffffffffc0203e56:	00002517          	auipc	a0,0x2
ffffffffc0203e5a:	35a50513          	addi	a0,a0,858 # ffffffffc02061b0 <default_pmm_manager+0xee0>
ffffffffc0203e5e:	a60fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e62:	5971                	li	s2,-4
ffffffffc0203e64:	b745                	j	ffffffffc0203e04 <do_pgfault+0x80>
            	cprintf("page_insert failed! \n");
ffffffffc0203e66:	00002517          	auipc	a0,0x2
ffffffffc0203e6a:	36250513          	addi	a0,a0,866 # ffffffffc02061c8 <default_pmm_manager+0xef8>
ffffffffc0203e6e:	a50fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e72:	5971                	li	s2,-4
ffffffffc0203e74:	bf41                	j	ffffffffc0203e04 <do_pgfault+0x80>

ffffffffc0203e76 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203e76:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e78:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203e7a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e7c:	e1cfc0ef          	jal	ra,ffffffffc0200498 <ide_device_valid>
ffffffffc0203e80:	cd01                	beqz	a0,ffffffffc0203e98 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e82:	4505                	li	a0,1
ffffffffc0203e84:	e1afc0ef          	jal	ra,ffffffffc020049e <ide_device_size>
}
ffffffffc0203e88:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e8a:	810d                	srli	a0,a0,0x3
ffffffffc0203e8c:	0000d797          	auipc	a5,0xd
ffffffffc0203e90:	6aa7be23          	sd	a0,1724(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203e94:	0141                	addi	sp,sp,16
ffffffffc0203e96:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e98:	00002617          	auipc	a2,0x2
ffffffffc0203e9c:	37060613          	addi	a2,a2,880 # ffffffffc0206208 <default_pmm_manager+0xf38>
ffffffffc0203ea0:	45b5                	li	a1,13
ffffffffc0203ea2:	00002517          	auipc	a0,0x2
ffffffffc0203ea6:	38650513          	addi	a0,a0,902 # ffffffffc0206228 <default_pmm_manager+0xf58>
ffffffffc0203eaa:	ccefc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0203eae <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203eae:	1141                	addi	sp,sp,-16
ffffffffc0203eb0:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203eb2:	00855793          	srli	a5,a0,0x8
ffffffffc0203eb6:	c3a5                	beqz	a5,ffffffffc0203f16 <swapfs_read+0x68>
ffffffffc0203eb8:	0000d717          	auipc	a4,0xd
ffffffffc0203ebc:	69073703          	ld	a4,1680(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203ec0:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f16 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ec4:	0000d617          	auipc	a2,0xd
ffffffffc0203ec8:	66c63603          	ld	a2,1644(a2) # ffffffffc0211530 <pages>
ffffffffc0203ecc:	8d91                	sub	a1,a1,a2
ffffffffc0203ece:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ed2:	00002597          	auipc	a1,0x2
ffffffffc0203ed6:	5d65b583          	ld	a1,1494(a1) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0203eda:	02b60633          	mul	a2,a2,a1
ffffffffc0203ede:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ee2:	00002797          	auipc	a5,0x2
ffffffffc0203ee6:	5ce7b783          	ld	a5,1486(a5) # ffffffffc02064b0 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eea:	0000d717          	auipc	a4,0xd
ffffffffc0203eee:	63e73703          	ld	a4,1598(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ef2:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ef4:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ef8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203efa:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203efc:	02e7f963          	bgeu	a5,a4,ffffffffc0203f2e <swapfs_read+0x80>
}
ffffffffc0203f00:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f02:	0000d797          	auipc	a5,0xd
ffffffffc0203f06:	63e7b783          	ld	a5,1598(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203f0a:	46a1                	li	a3,8
ffffffffc0203f0c:	963e                	add	a2,a2,a5
ffffffffc0203f0e:	4505                	li	a0,1
}
ffffffffc0203f10:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f12:	d92fc06f          	j	ffffffffc02004a4 <ide_read_secs>
ffffffffc0203f16:	86aa                	mv	a3,a0
ffffffffc0203f18:	00002617          	auipc	a2,0x2
ffffffffc0203f1c:	32860613          	addi	a2,a2,808 # ffffffffc0206240 <default_pmm_manager+0xf70>
ffffffffc0203f20:	45d1                	li	a1,20
ffffffffc0203f22:	00002517          	auipc	a0,0x2
ffffffffc0203f26:	30650513          	addi	a0,a0,774 # ffffffffc0206228 <default_pmm_manager+0xf58>
ffffffffc0203f2a:	c4efc0ef          	jal	ra,ffffffffc0200378 <__panic>
ffffffffc0203f2e:	86b2                	mv	a3,a2
ffffffffc0203f30:	06a00593          	li	a1,106
ffffffffc0203f34:	00001617          	auipc	a2,0x1
ffffffffc0203f38:	42c60613          	addi	a2,a2,1068 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc0203f3c:	00001517          	auipc	a0,0x1
ffffffffc0203f40:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc0203f44:	c34fc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0203f48 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f48:	1141                	addi	sp,sp,-16
ffffffffc0203f4a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f4c:	00855793          	srli	a5,a0,0x8
ffffffffc0203f50:	c3a5                	beqz	a5,ffffffffc0203fb0 <swapfs_write+0x68>
ffffffffc0203f52:	0000d717          	auipc	a4,0xd
ffffffffc0203f56:	5f673703          	ld	a4,1526(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203f5a:	04e7fb63          	bgeu	a5,a4,ffffffffc0203fb0 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f5e:	0000d617          	auipc	a2,0xd
ffffffffc0203f62:	5d263603          	ld	a2,1490(a2) # ffffffffc0211530 <pages>
ffffffffc0203f66:	8d91                	sub	a1,a1,a2
ffffffffc0203f68:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f6c:	00002597          	auipc	a1,0x2
ffffffffc0203f70:	53c5b583          	ld	a1,1340(a1) # ffffffffc02064a8 <error_string+0x38>
ffffffffc0203f74:	02b60633          	mul	a2,a2,a1
ffffffffc0203f78:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f7c:	00002797          	auipc	a5,0x2
ffffffffc0203f80:	5347b783          	ld	a5,1332(a5) # ffffffffc02064b0 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f84:	0000d717          	auipc	a4,0xd
ffffffffc0203f88:	5a473703          	ld	a4,1444(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f8c:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f8e:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f92:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f94:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f96:	02e7f963          	bgeu	a5,a4,ffffffffc0203fc8 <swapfs_write+0x80>
}
ffffffffc0203f9a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f9c:	0000d797          	auipc	a5,0xd
ffffffffc0203fa0:	5a47b783          	ld	a5,1444(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203fa4:	46a1                	li	a3,8
ffffffffc0203fa6:	963e                	add	a2,a2,a5
ffffffffc0203fa8:	4505                	li	a0,1
}
ffffffffc0203faa:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fac:	d1cfc06f          	j	ffffffffc02004c8 <ide_write_secs>
ffffffffc0203fb0:	86aa                	mv	a3,a0
ffffffffc0203fb2:	00002617          	auipc	a2,0x2
ffffffffc0203fb6:	28e60613          	addi	a2,a2,654 # ffffffffc0206240 <default_pmm_manager+0xf70>
ffffffffc0203fba:	45e5                	li	a1,25
ffffffffc0203fbc:	00002517          	auipc	a0,0x2
ffffffffc0203fc0:	26c50513          	addi	a0,a0,620 # ffffffffc0206228 <default_pmm_manager+0xf58>
ffffffffc0203fc4:	bb4fc0ef          	jal	ra,ffffffffc0200378 <__panic>
ffffffffc0203fc8:	86b2                	mv	a3,a2
ffffffffc0203fca:	06a00593          	li	a1,106
ffffffffc0203fce:	00001617          	auipc	a2,0x1
ffffffffc0203fd2:	39260613          	addi	a2,a2,914 # ffffffffc0205360 <default_pmm_manager+0x90>
ffffffffc0203fd6:	00001517          	auipc	a0,0x1
ffffffffc0203fda:	35250513          	addi	a0,a0,850 # ffffffffc0205328 <default_pmm_manager+0x58>
ffffffffc0203fde:	b9afc0ef          	jal	ra,ffffffffc0200378 <__panic>

ffffffffc0203fe2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203fe2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fe6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203fe8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fec:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203fee:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ff2:	f022                	sd	s0,32(sp)
ffffffffc0203ff4:	ec26                	sd	s1,24(sp)
ffffffffc0203ff6:	e84a                	sd	s2,16(sp)
ffffffffc0203ff8:	f406                	sd	ra,40(sp)
ffffffffc0203ffa:	e44e                	sd	s3,8(sp)
ffffffffc0203ffc:	84aa                	mv	s1,a0
ffffffffc0203ffe:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204000:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204004:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204006:	03067e63          	bgeu	a2,a6,ffffffffc0204042 <printnum+0x60>
ffffffffc020400a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020400c:	00805763          	blez	s0,ffffffffc020401a <printnum+0x38>
ffffffffc0204010:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204012:	85ca                	mv	a1,s2
ffffffffc0204014:	854e                	mv	a0,s3
ffffffffc0204016:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204018:	fc65                	bnez	s0,ffffffffc0204010 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020401a:	1a02                	slli	s4,s4,0x20
ffffffffc020401c:	00002797          	auipc	a5,0x2
ffffffffc0204020:	24478793          	addi	a5,a5,580 # ffffffffc0206260 <default_pmm_manager+0xf90>
ffffffffc0204024:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204028:	9a3e                	add	s4,s4,a5
}
ffffffffc020402a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020402c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204030:	70a2                	ld	ra,40(sp)
ffffffffc0204032:	69a2                	ld	s3,8(sp)
ffffffffc0204034:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204036:	85ca                	mv	a1,s2
ffffffffc0204038:	87a6                	mv	a5,s1
}
ffffffffc020403a:	6942                	ld	s2,16(sp)
ffffffffc020403c:	64e2                	ld	s1,24(sp)
ffffffffc020403e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204040:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204042:	03065633          	divu	a2,a2,a6
ffffffffc0204046:	8722                	mv	a4,s0
ffffffffc0204048:	f9bff0ef          	jal	ra,ffffffffc0203fe2 <printnum>
ffffffffc020404c:	b7f9                	j	ffffffffc020401a <printnum+0x38>

ffffffffc020404e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020404e:	7119                	addi	sp,sp,-128
ffffffffc0204050:	f4a6                	sd	s1,104(sp)
ffffffffc0204052:	f0ca                	sd	s2,96(sp)
ffffffffc0204054:	ecce                	sd	s3,88(sp)
ffffffffc0204056:	e8d2                	sd	s4,80(sp)
ffffffffc0204058:	e4d6                	sd	s5,72(sp)
ffffffffc020405a:	e0da                	sd	s6,64(sp)
ffffffffc020405c:	fc5e                	sd	s7,56(sp)
ffffffffc020405e:	f06a                	sd	s10,32(sp)
ffffffffc0204060:	fc86                	sd	ra,120(sp)
ffffffffc0204062:	f8a2                	sd	s0,112(sp)
ffffffffc0204064:	f862                	sd	s8,48(sp)
ffffffffc0204066:	f466                	sd	s9,40(sp)
ffffffffc0204068:	ec6e                	sd	s11,24(sp)
ffffffffc020406a:	892a                	mv	s2,a0
ffffffffc020406c:	84ae                	mv	s1,a1
ffffffffc020406e:	8d32                	mv	s10,a2
ffffffffc0204070:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204072:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204076:	5b7d                	li	s6,-1
ffffffffc0204078:	00002a97          	auipc	s5,0x2
ffffffffc020407c:	21ca8a93          	addi	s5,s5,540 # ffffffffc0206294 <default_pmm_manager+0xfc4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204080:	00002b97          	auipc	s7,0x2
ffffffffc0204084:	3f0b8b93          	addi	s7,s7,1008 # ffffffffc0206470 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204088:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc020408c:	001d0413          	addi	s0,s10,1
ffffffffc0204090:	01350a63          	beq	a0,s3,ffffffffc02040a4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204094:	c121                	beqz	a0,ffffffffc02040d4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204096:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204098:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020409a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020409c:	fff44503          	lbu	a0,-1(s0)
ffffffffc02040a0:	ff351ae3          	bne	a0,s3,ffffffffc0204094 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040a4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02040a8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02040ac:	4c81                	li	s9,0
ffffffffc02040ae:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02040b0:	5c7d                	li	s8,-1
ffffffffc02040b2:	5dfd                	li	s11,-1
ffffffffc02040b4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02040b8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040ba:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040be:	0ff5f593          	andi	a1,a1,255
ffffffffc02040c2:	00140d13          	addi	s10,s0,1
ffffffffc02040c6:	04b56263          	bltu	a0,a1,ffffffffc020410a <vprintfmt+0xbc>
ffffffffc02040ca:	058a                	slli	a1,a1,0x2
ffffffffc02040cc:	95d6                	add	a1,a1,s5
ffffffffc02040ce:	4194                	lw	a3,0(a1)
ffffffffc02040d0:	96d6                	add	a3,a3,s5
ffffffffc02040d2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02040d4:	70e6                	ld	ra,120(sp)
ffffffffc02040d6:	7446                	ld	s0,112(sp)
ffffffffc02040d8:	74a6                	ld	s1,104(sp)
ffffffffc02040da:	7906                	ld	s2,96(sp)
ffffffffc02040dc:	69e6                	ld	s3,88(sp)
ffffffffc02040de:	6a46                	ld	s4,80(sp)
ffffffffc02040e0:	6aa6                	ld	s5,72(sp)
ffffffffc02040e2:	6b06                	ld	s6,64(sp)
ffffffffc02040e4:	7be2                	ld	s7,56(sp)
ffffffffc02040e6:	7c42                	ld	s8,48(sp)
ffffffffc02040e8:	7ca2                	ld	s9,40(sp)
ffffffffc02040ea:	7d02                	ld	s10,32(sp)
ffffffffc02040ec:	6de2                	ld	s11,24(sp)
ffffffffc02040ee:	6109                	addi	sp,sp,128
ffffffffc02040f0:	8082                	ret
            padc = '0';
ffffffffc02040f2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02040f4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f8:	846a                	mv	s0,s10
ffffffffc02040fa:	00140d13          	addi	s10,s0,1
ffffffffc02040fe:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204102:	0ff5f593          	andi	a1,a1,255
ffffffffc0204106:	fcb572e3          	bgeu	a0,a1,ffffffffc02040ca <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020410a:	85a6                	mv	a1,s1
ffffffffc020410c:	02500513          	li	a0,37
ffffffffc0204110:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204112:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204116:	8d22                	mv	s10,s0
ffffffffc0204118:	f73788e3          	beq	a5,s3,ffffffffc0204088 <vprintfmt+0x3a>
ffffffffc020411c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204120:	1d7d                	addi	s10,s10,-1
ffffffffc0204122:	ff379de3          	bne	a5,s3,ffffffffc020411c <vprintfmt+0xce>
ffffffffc0204126:	b78d                	j	ffffffffc0204088 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204128:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020412c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204130:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204132:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204136:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020413a:	02d86463          	bltu	a6,a3,ffffffffc0204162 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020413e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204142:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204146:	0186873b          	addw	a4,a3,s8
ffffffffc020414a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020414e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204150:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204154:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204156:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020415a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020415e:	fed870e3          	bgeu	a6,a3,ffffffffc020413e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204162:	f40ddce3          	bgez	s11,ffffffffc02040ba <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204166:	8de2                	mv	s11,s8
ffffffffc0204168:	5c7d                	li	s8,-1
ffffffffc020416a:	bf81                	j	ffffffffc02040ba <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020416c:	fffdc693          	not	a3,s11
ffffffffc0204170:	96fd                	srai	a3,a3,0x3f
ffffffffc0204172:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204176:	00144603          	lbu	a2,1(s0)
ffffffffc020417a:	2d81                	sext.w	s11,s11
ffffffffc020417c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020417e:	bf35                	j	ffffffffc02040ba <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204180:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204184:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204188:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020418a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020418c:	bfd9                	j	ffffffffc0204162 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020418e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204190:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204194:	01174463          	blt	a4,a7,ffffffffc020419c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204198:	1a088e63          	beqz	a7,ffffffffc0204354 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020419c:	000a3603          	ld	a2,0(s4)
ffffffffc02041a0:	46c1                	li	a3,16
ffffffffc02041a2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02041a4:	2781                	sext.w	a5,a5
ffffffffc02041a6:	876e                	mv	a4,s11
ffffffffc02041a8:	85a6                	mv	a1,s1
ffffffffc02041aa:	854a                	mv	a0,s2
ffffffffc02041ac:	e37ff0ef          	jal	ra,ffffffffc0203fe2 <printnum>
            break;
ffffffffc02041b0:	bde1                	j	ffffffffc0204088 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02041b2:	000a2503          	lw	a0,0(s4)
ffffffffc02041b6:	85a6                	mv	a1,s1
ffffffffc02041b8:	0a21                	addi	s4,s4,8
ffffffffc02041ba:	9902                	jalr	s2
            break;
ffffffffc02041bc:	b5f1                	j	ffffffffc0204088 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041be:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041c0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041c4:	01174463          	blt	a4,a7,ffffffffc02041cc <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02041c8:	18088163          	beqz	a7,ffffffffc020434a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02041cc:	000a3603          	ld	a2,0(s4)
ffffffffc02041d0:	46a9                	li	a3,10
ffffffffc02041d2:	8a2e                	mv	s4,a1
ffffffffc02041d4:	bfc1                	j	ffffffffc02041a4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02041da:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041dc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041de:	bdf1                	j	ffffffffc02040ba <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02041e0:	85a6                	mv	a1,s1
ffffffffc02041e2:	02500513          	li	a0,37
ffffffffc02041e6:	9902                	jalr	s2
            break;
ffffffffc02041e8:	b545                	j	ffffffffc0204088 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ea:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02041ee:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041f0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041f2:	b5e1                	j	ffffffffc02040ba <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02041f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041f6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041fa:	01174463          	blt	a4,a7,ffffffffc0204202 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02041fe:	14088163          	beqz	a7,ffffffffc0204340 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204202:	000a3603          	ld	a2,0(s4)
ffffffffc0204206:	46a1                	li	a3,8
ffffffffc0204208:	8a2e                	mv	s4,a1
ffffffffc020420a:	bf69                	j	ffffffffc02041a4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020420c:	03000513          	li	a0,48
ffffffffc0204210:	85a6                	mv	a1,s1
ffffffffc0204212:	e03e                	sd	a5,0(sp)
ffffffffc0204214:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204216:	85a6                	mv	a1,s1
ffffffffc0204218:	07800513          	li	a0,120
ffffffffc020421c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020421e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204220:	6782                	ld	a5,0(sp)
ffffffffc0204222:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204224:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204228:	bfb5                	j	ffffffffc02041a4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020422a:	000a3403          	ld	s0,0(s4)
ffffffffc020422e:	008a0713          	addi	a4,s4,8
ffffffffc0204232:	e03a                	sd	a4,0(sp)
ffffffffc0204234:	14040263          	beqz	s0,ffffffffc0204378 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204238:	0fb05763          	blez	s11,ffffffffc0204326 <vprintfmt+0x2d8>
ffffffffc020423c:	02d00693          	li	a3,45
ffffffffc0204240:	0cd79163          	bne	a5,a3,ffffffffc0204302 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204244:	00044783          	lbu	a5,0(s0)
ffffffffc0204248:	0007851b          	sext.w	a0,a5
ffffffffc020424c:	cf85                	beqz	a5,ffffffffc0204284 <vprintfmt+0x236>
ffffffffc020424e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204252:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204256:	000c4563          	bltz	s8,ffffffffc0204260 <vprintfmt+0x212>
ffffffffc020425a:	3c7d                	addiw	s8,s8,-1
ffffffffc020425c:	036c0263          	beq	s8,s6,ffffffffc0204280 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204260:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204262:	0e0c8e63          	beqz	s9,ffffffffc020435e <vprintfmt+0x310>
ffffffffc0204266:	3781                	addiw	a5,a5,-32
ffffffffc0204268:	0ef47b63          	bgeu	s0,a5,ffffffffc020435e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020426c:	03f00513          	li	a0,63
ffffffffc0204270:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204272:	000a4783          	lbu	a5,0(s4)
ffffffffc0204276:	3dfd                	addiw	s11,s11,-1
ffffffffc0204278:	0a05                	addi	s4,s4,1
ffffffffc020427a:	0007851b          	sext.w	a0,a5
ffffffffc020427e:	ffe1                	bnez	a5,ffffffffc0204256 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204280:	01b05963          	blez	s11,ffffffffc0204292 <vprintfmt+0x244>
ffffffffc0204284:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204286:	85a6                	mv	a1,s1
ffffffffc0204288:	02000513          	li	a0,32
ffffffffc020428c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020428e:	fe0d9be3          	bnez	s11,ffffffffc0204284 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204292:	6a02                	ld	s4,0(sp)
ffffffffc0204294:	bbd5                	j	ffffffffc0204088 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204296:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204298:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020429c:	01174463          	blt	a4,a7,ffffffffc02042a4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02042a0:	08088d63          	beqz	a7,ffffffffc020433a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02042a4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02042a8:	0a044d63          	bltz	s0,ffffffffc0204362 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02042ac:	8622                	mv	a2,s0
ffffffffc02042ae:	8a66                	mv	s4,s9
ffffffffc02042b0:	46a9                	li	a3,10
ffffffffc02042b2:	bdcd                	j	ffffffffc02041a4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02042b4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042b8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02042ba:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02042bc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02042c0:	8fb5                	xor	a5,a5,a3
ffffffffc02042c2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042c6:	02d74163          	blt	a4,a3,ffffffffc02042e8 <vprintfmt+0x29a>
ffffffffc02042ca:	00369793          	slli	a5,a3,0x3
ffffffffc02042ce:	97de                	add	a5,a5,s7
ffffffffc02042d0:	639c                	ld	a5,0(a5)
ffffffffc02042d2:	cb99                	beqz	a5,ffffffffc02042e8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02042d4:	86be                	mv	a3,a5
ffffffffc02042d6:	00002617          	auipc	a2,0x2
ffffffffc02042da:	fba60613          	addi	a2,a2,-70 # ffffffffc0206290 <default_pmm_manager+0xfc0>
ffffffffc02042de:	85a6                	mv	a1,s1
ffffffffc02042e0:	854a                	mv	a0,s2
ffffffffc02042e2:	0ce000ef          	jal	ra,ffffffffc02043b0 <printfmt>
ffffffffc02042e6:	b34d                	j	ffffffffc0204088 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02042e8:	00002617          	auipc	a2,0x2
ffffffffc02042ec:	f9860613          	addi	a2,a2,-104 # ffffffffc0206280 <default_pmm_manager+0xfb0>
ffffffffc02042f0:	85a6                	mv	a1,s1
ffffffffc02042f2:	854a                	mv	a0,s2
ffffffffc02042f4:	0bc000ef          	jal	ra,ffffffffc02043b0 <printfmt>
ffffffffc02042f8:	bb41                	j	ffffffffc0204088 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02042fa:	00002417          	auipc	s0,0x2
ffffffffc02042fe:	f7e40413          	addi	s0,s0,-130 # ffffffffc0206278 <default_pmm_manager+0xfa8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204302:	85e2                	mv	a1,s8
ffffffffc0204304:	8522                	mv	a0,s0
ffffffffc0204306:	e43e                	sd	a5,8(sp)
ffffffffc0204308:	196000ef          	jal	ra,ffffffffc020449e <strnlen>
ffffffffc020430c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204310:	01b05b63          	blez	s11,ffffffffc0204326 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204314:	67a2                	ld	a5,8(sp)
ffffffffc0204316:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020431a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020431c:	85a6                	mv	a1,s1
ffffffffc020431e:	8552                	mv	a0,s4
ffffffffc0204320:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204322:	fe0d9ce3          	bnez	s11,ffffffffc020431a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204326:	00044783          	lbu	a5,0(s0)
ffffffffc020432a:	00140a13          	addi	s4,s0,1
ffffffffc020432e:	0007851b          	sext.w	a0,a5
ffffffffc0204332:	d3a5                	beqz	a5,ffffffffc0204292 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204334:	05e00413          	li	s0,94
ffffffffc0204338:	bf39                	j	ffffffffc0204256 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020433a:	000a2403          	lw	s0,0(s4)
ffffffffc020433e:	b7ad                	j	ffffffffc02042a8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204340:	000a6603          	lwu	a2,0(s4)
ffffffffc0204344:	46a1                	li	a3,8
ffffffffc0204346:	8a2e                	mv	s4,a1
ffffffffc0204348:	bdb1                	j	ffffffffc02041a4 <vprintfmt+0x156>
ffffffffc020434a:	000a6603          	lwu	a2,0(s4)
ffffffffc020434e:	46a9                	li	a3,10
ffffffffc0204350:	8a2e                	mv	s4,a1
ffffffffc0204352:	bd89                	j	ffffffffc02041a4 <vprintfmt+0x156>
ffffffffc0204354:	000a6603          	lwu	a2,0(s4)
ffffffffc0204358:	46c1                	li	a3,16
ffffffffc020435a:	8a2e                	mv	s4,a1
ffffffffc020435c:	b5a1                	j	ffffffffc02041a4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020435e:	9902                	jalr	s2
ffffffffc0204360:	bf09                	j	ffffffffc0204272 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204362:	85a6                	mv	a1,s1
ffffffffc0204364:	02d00513          	li	a0,45
ffffffffc0204368:	e03e                	sd	a5,0(sp)
ffffffffc020436a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020436c:	6782                	ld	a5,0(sp)
ffffffffc020436e:	8a66                	mv	s4,s9
ffffffffc0204370:	40800633          	neg	a2,s0
ffffffffc0204374:	46a9                	li	a3,10
ffffffffc0204376:	b53d                	j	ffffffffc02041a4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204378:	03b05163          	blez	s11,ffffffffc020439a <vprintfmt+0x34c>
ffffffffc020437c:	02d00693          	li	a3,45
ffffffffc0204380:	f6d79de3          	bne	a5,a3,ffffffffc02042fa <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204384:	00002417          	auipc	s0,0x2
ffffffffc0204388:	ef440413          	addi	s0,s0,-268 # ffffffffc0206278 <default_pmm_manager+0xfa8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020438c:	02800793          	li	a5,40
ffffffffc0204390:	02800513          	li	a0,40
ffffffffc0204394:	00140a13          	addi	s4,s0,1
ffffffffc0204398:	bd6d                	j	ffffffffc0204252 <vprintfmt+0x204>
ffffffffc020439a:	00002a17          	auipc	s4,0x2
ffffffffc020439e:	edfa0a13          	addi	s4,s4,-289 # ffffffffc0206279 <default_pmm_manager+0xfa9>
ffffffffc02043a2:	02800513          	li	a0,40
ffffffffc02043a6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043aa:	05e00413          	li	s0,94
ffffffffc02043ae:	b565                	j	ffffffffc0204256 <vprintfmt+0x208>

ffffffffc02043b0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02043b2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043b8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043ba:	ec06                	sd	ra,24(sp)
ffffffffc02043bc:	f83a                	sd	a4,48(sp)
ffffffffc02043be:	fc3e                	sd	a5,56(sp)
ffffffffc02043c0:	e0c2                	sd	a6,64(sp)
ffffffffc02043c2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02043c4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043c6:	c89ff0ef          	jal	ra,ffffffffc020404e <vprintfmt>
}
ffffffffc02043ca:	60e2                	ld	ra,24(sp)
ffffffffc02043cc:	6161                	addi	sp,sp,80
ffffffffc02043ce:	8082                	ret

ffffffffc02043d0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02043d0:	715d                	addi	sp,sp,-80
ffffffffc02043d2:	e486                	sd	ra,72(sp)
ffffffffc02043d4:	e0a6                	sd	s1,64(sp)
ffffffffc02043d6:	fc4a                	sd	s2,56(sp)
ffffffffc02043d8:	f84e                	sd	s3,48(sp)
ffffffffc02043da:	f452                	sd	s4,40(sp)
ffffffffc02043dc:	f056                	sd	s5,32(sp)
ffffffffc02043de:	ec5a                	sd	s6,24(sp)
ffffffffc02043e0:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02043e2:	c901                	beqz	a0,ffffffffc02043f2 <readline+0x22>
ffffffffc02043e4:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02043e6:	00002517          	auipc	a0,0x2
ffffffffc02043ea:	eaa50513          	addi	a0,a0,-342 # ffffffffc0206290 <default_pmm_manager+0xfc0>
ffffffffc02043ee:	cd1fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02043f2:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043f4:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02043f6:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02043f8:	4aa9                	li	s5,10
ffffffffc02043fa:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02043fc:	0000db97          	auipc	s7,0xd
ffffffffc0204400:	cfcb8b93          	addi	s7,s7,-772 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204404:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204408:	ceffb0ef          	jal	ra,ffffffffc02000f6 <getchar>
        if (c < 0) {
ffffffffc020440c:	00054a63          	bltz	a0,ffffffffc0204420 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204410:	00a95a63          	bge	s2,a0,ffffffffc0204424 <readline+0x54>
ffffffffc0204414:	029a5263          	bge	s4,s1,ffffffffc0204438 <readline+0x68>
        c = getchar();
ffffffffc0204418:	cdffb0ef          	jal	ra,ffffffffc02000f6 <getchar>
        if (c < 0) {
ffffffffc020441c:	fe055ae3          	bgez	a0,ffffffffc0204410 <readline+0x40>
            return NULL;
ffffffffc0204420:	4501                	li	a0,0
ffffffffc0204422:	a091                	j	ffffffffc0204466 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204424:	03351463          	bne	a0,s3,ffffffffc020444c <readline+0x7c>
ffffffffc0204428:	e8a9                	bnez	s1,ffffffffc020447a <readline+0xaa>
        c = getchar();
ffffffffc020442a:	ccdfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
        if (c < 0) {
ffffffffc020442e:	fe0549e3          	bltz	a0,ffffffffc0204420 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204432:	fea959e3          	bge	s2,a0,ffffffffc0204424 <readline+0x54>
ffffffffc0204436:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204438:	e42a                	sd	a0,8(sp)
ffffffffc020443a:	cbbfb0ef          	jal	ra,ffffffffc02000f4 <cputchar>
            buf[i ++] = c;
ffffffffc020443e:	6522                	ld	a0,8(sp)
ffffffffc0204440:	009b87b3          	add	a5,s7,s1
ffffffffc0204444:	2485                	addiw	s1,s1,1
ffffffffc0204446:	00a78023          	sb	a0,0(a5)
ffffffffc020444a:	bf7d                	j	ffffffffc0204408 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020444c:	01550463          	beq	a0,s5,ffffffffc0204454 <readline+0x84>
ffffffffc0204450:	fb651ce3          	bne	a0,s6,ffffffffc0204408 <readline+0x38>
            cputchar(c);
ffffffffc0204454:	ca1fb0ef          	jal	ra,ffffffffc02000f4 <cputchar>
            buf[i] = '\0';
ffffffffc0204458:	0000d517          	auipc	a0,0xd
ffffffffc020445c:	ca050513          	addi	a0,a0,-864 # ffffffffc02110f8 <buf>
ffffffffc0204460:	94aa                	add	s1,s1,a0
ffffffffc0204462:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204466:	60a6                	ld	ra,72(sp)
ffffffffc0204468:	6486                	ld	s1,64(sp)
ffffffffc020446a:	7962                	ld	s2,56(sp)
ffffffffc020446c:	79c2                	ld	s3,48(sp)
ffffffffc020446e:	7a22                	ld	s4,40(sp)
ffffffffc0204470:	7a82                	ld	s5,32(sp)
ffffffffc0204472:	6b62                	ld	s6,24(sp)
ffffffffc0204474:	6bc2                	ld	s7,16(sp)
ffffffffc0204476:	6161                	addi	sp,sp,80
ffffffffc0204478:	8082                	ret
            cputchar(c);
ffffffffc020447a:	4521                	li	a0,8
ffffffffc020447c:	c79fb0ef          	jal	ra,ffffffffc02000f4 <cputchar>
            i --;
ffffffffc0204480:	34fd                	addiw	s1,s1,-1
ffffffffc0204482:	b759                	j	ffffffffc0204408 <readline+0x38>

ffffffffc0204484 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204484:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204488:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020448a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020448c:	cb81                	beqz	a5,ffffffffc020449c <strlen+0x18>
        cnt ++;
ffffffffc020448e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204490:	00a707b3          	add	a5,a4,a0
ffffffffc0204494:	0007c783          	lbu	a5,0(a5)
ffffffffc0204498:	fbfd                	bnez	a5,ffffffffc020448e <strlen+0xa>
ffffffffc020449a:	8082                	ret
    }
    return cnt;
}
ffffffffc020449c:	8082                	ret

ffffffffc020449e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020449e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02044a0:	e589                	bnez	a1,ffffffffc02044aa <strnlen+0xc>
ffffffffc02044a2:	a811                	j	ffffffffc02044b6 <strnlen+0x18>
        cnt ++;
ffffffffc02044a4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02044a6:	00f58863          	beq	a1,a5,ffffffffc02044b6 <strnlen+0x18>
ffffffffc02044aa:	00f50733          	add	a4,a0,a5
ffffffffc02044ae:	00074703          	lbu	a4,0(a4)
ffffffffc02044b2:	fb6d                	bnez	a4,ffffffffc02044a4 <strnlen+0x6>
ffffffffc02044b4:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02044b6:	852e                	mv	a0,a1
ffffffffc02044b8:	8082                	ret

ffffffffc02044ba <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02044ba:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02044bc:	0005c703          	lbu	a4,0(a1)
ffffffffc02044c0:	0785                	addi	a5,a5,1
ffffffffc02044c2:	0585                	addi	a1,a1,1
ffffffffc02044c4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02044c8:	fb75                	bnez	a4,ffffffffc02044bc <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02044ca:	8082                	ret

ffffffffc02044cc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044cc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044d0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044d4:	cb89                	beqz	a5,ffffffffc02044e6 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02044d6:	0505                	addi	a0,a0,1
ffffffffc02044d8:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044da:	fee789e3          	beq	a5,a4,ffffffffc02044cc <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044de:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02044e2:	9d19                	subw	a0,a0,a4
ffffffffc02044e4:	8082                	ret
ffffffffc02044e6:	4501                	li	a0,0
ffffffffc02044e8:	bfed                	j	ffffffffc02044e2 <strcmp+0x16>

ffffffffc02044ea <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02044ea:	00054783          	lbu	a5,0(a0)
ffffffffc02044ee:	c799                	beqz	a5,ffffffffc02044fc <strchr+0x12>
        if (*s == c) {
ffffffffc02044f0:	00f58763          	beq	a1,a5,ffffffffc02044fe <strchr+0x14>
    while (*s != '\0') {
ffffffffc02044f4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02044f8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02044fa:	fbfd                	bnez	a5,ffffffffc02044f0 <strchr+0x6>
    }
    return NULL;
ffffffffc02044fc:	4501                	li	a0,0
}
ffffffffc02044fe:	8082                	ret

ffffffffc0204500 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204500:	ca01                	beqz	a2,ffffffffc0204510 <memset+0x10>
ffffffffc0204502:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204504:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204506:	0785                	addi	a5,a5,1
ffffffffc0204508:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020450c:	fec79de3          	bne	a5,a2,ffffffffc0204506 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204510:	8082                	ret

ffffffffc0204512 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204512:	ca19                	beqz	a2,ffffffffc0204528 <memcpy+0x16>
ffffffffc0204514:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204516:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204518:	0005c703          	lbu	a4,0(a1)
ffffffffc020451c:	0585                	addi	a1,a1,1
ffffffffc020451e:	0785                	addi	a5,a5,1
ffffffffc0204520:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204524:	fec59ae3          	bne	a1,a2,ffffffffc0204518 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204528:	8082                	ret
