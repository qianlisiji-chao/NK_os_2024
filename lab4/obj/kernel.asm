
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc0200024:	c020a137          	lui	sp,0xc020a

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000b517          	auipc	a0,0xb
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020b060 <buf>
ffffffffc020003a:	00016617          	auipc	a2,0x16
ffffffffc020003e:	59a60613          	addi	a2,a2,1434 # ffffffffc02165d4 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	721040ef          	jal	ra,ffffffffc0204f6a <memset>

    cons_init();                // init the console
ffffffffc020004e:	4a6000ef          	jal	ra,ffffffffc02004f4 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	f6658593          	addi	a1,a1,-154 # ffffffffc0204fb8 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	f7e50513          	addi	a0,a0,-130 # ffffffffc0204fd8 <etext+0x20>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	162000ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	6eb010ef          	jal	ra,ffffffffc0201f54 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	55a000ef          	jal	ra,ffffffffc02005c8 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	1f9030ef          	jal	ra,ffffffffc0203a6e <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	6d6040ef          	jal	ra,ffffffffc0204750 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4e8000ef          	jal	ra,ffffffffc0200566 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	347020ef          	jal	ra,ffffffffc0202bc8 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	41c000ef          	jal	ra,ffffffffc02004a2 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	532000ef          	jal	ra,ffffffffc02005bc <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	111040ef          	jal	ra,ffffffffc020499e <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00005517          	auipc	a0,0x5
ffffffffc02000ac:	f3850513          	addi	a0,a0,-200 # ffffffffc0204fe0 <etext+0x28>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	0000bb97          	auipc	s7,0xb
ffffffffc02000c2:	fa2b8b93          	addi	s7,s7,-94 # ffffffffc020b060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	0ee000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	0de000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	0cc000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	0000b517          	auipc	a0,0xb
ffffffffc020011e:	f4650513          	addi	a0,a0,-186 # ffffffffc020b060 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	3a8000ef          	jal	ra,ffffffffc02004f6 <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	1f9040ef          	jal	ra,ffffffffc0204b6c <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	1c3040ef          	jal	ra,ffffffffc0204b6c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a681                	j	ffffffffc02004f6 <cons_putc>

ffffffffc02001b8 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001b8:	1141                	addi	sp,sp,-16
ffffffffc02001ba:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001bc:	36e000ef          	jal	ra,ffffffffc020052a <cons_getc>
ffffffffc02001c0:	dd75                	beqz	a0,ffffffffc02001bc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001c2:	60a2                	ld	ra,8(sp)
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001ca:	00005517          	auipc	a0,0x5
ffffffffc02001ce:	e1e50513          	addi	a0,a0,-482 # ffffffffc0204fe8 <etext+0x30>
void print_kerninfo(void) {
ffffffffc02001d2:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001d4:	fadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001d8:	00000597          	auipc	a1,0x0
ffffffffc02001dc:	e5a58593          	addi	a1,a1,-422 # ffffffffc0200032 <kern_init>
ffffffffc02001e0:	00005517          	auipc	a0,0x5
ffffffffc02001e4:	e2850513          	addi	a0,a0,-472 # ffffffffc0205008 <etext+0x50>
ffffffffc02001e8:	f99ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001ec:	00005597          	auipc	a1,0x5
ffffffffc02001f0:	dcc58593          	addi	a1,a1,-564 # ffffffffc0204fb8 <etext>
ffffffffc02001f4:	00005517          	auipc	a0,0x5
ffffffffc02001f8:	e3450513          	addi	a0,a0,-460 # ffffffffc0205028 <etext+0x70>
ffffffffc02001fc:	f85ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200200:	0000b597          	auipc	a1,0xb
ffffffffc0200204:	e6058593          	addi	a1,a1,-416 # ffffffffc020b060 <buf>
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	e4050513          	addi	a0,a0,-448 # ffffffffc0205048 <etext+0x90>
ffffffffc0200210:	f71ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200214:	00016597          	auipc	a1,0x16
ffffffffc0200218:	3c058593          	addi	a1,a1,960 # ffffffffc02165d4 <end>
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205068 <etext+0xb0>
ffffffffc0200224:	f5dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200228:	00016597          	auipc	a1,0x16
ffffffffc020022c:	7ab58593          	addi	a1,a1,1963 # ffffffffc02169d3 <end+0x3ff>
ffffffffc0200230:	00000797          	auipc	a5,0x0
ffffffffc0200234:	e0278793          	addi	a5,a5,-510 # ffffffffc0200032 <kern_init>
ffffffffc0200238:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200240:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200242:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200246:	95be                	add	a1,a1,a5
ffffffffc0200248:	85a9                	srai	a1,a1,0xa
ffffffffc020024a:	00005517          	auipc	a0,0x5
ffffffffc020024e:	e3e50513          	addi	a0,a0,-450 # ffffffffc0205088 <etext+0xd0>
}
ffffffffc0200252:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200254:	b735                	j	ffffffffc0200180 <cprintf>

ffffffffc0200256 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200258:	00005617          	auipc	a2,0x5
ffffffffc020025c:	e6060613          	addi	a2,a2,-416 # ffffffffc02050b8 <etext+0x100>
ffffffffc0200260:	04d00593          	li	a1,77
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	e6c50513          	addi	a0,a0,-404 # ffffffffc02050d0 <etext+0x118>
void print_stackframe(void) {
ffffffffc020026c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020026e:	1d8000ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200272 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200274:	00005617          	auipc	a2,0x5
ffffffffc0200278:	e7460613          	addi	a2,a2,-396 # ffffffffc02050e8 <etext+0x130>
ffffffffc020027c:	00005597          	auipc	a1,0x5
ffffffffc0200280:	e8c58593          	addi	a1,a1,-372 # ffffffffc0205108 <etext+0x150>
ffffffffc0200284:	00005517          	auipc	a0,0x5
ffffffffc0200288:	e8c50513          	addi	a0,a0,-372 # ffffffffc0205110 <etext+0x158>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020028c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020028e:	ef3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200292:	00005617          	auipc	a2,0x5
ffffffffc0200296:	e8e60613          	addi	a2,a2,-370 # ffffffffc0205120 <etext+0x168>
ffffffffc020029a:	00005597          	auipc	a1,0x5
ffffffffc020029e:	eae58593          	addi	a1,a1,-338 # ffffffffc0205148 <etext+0x190>
ffffffffc02002a2:	00005517          	auipc	a0,0x5
ffffffffc02002a6:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205110 <etext+0x158>
ffffffffc02002aa:	ed7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ae:	00005617          	auipc	a2,0x5
ffffffffc02002b2:	eaa60613          	addi	a2,a2,-342 # ffffffffc0205158 <etext+0x1a0>
ffffffffc02002b6:	00005597          	auipc	a1,0x5
ffffffffc02002ba:	ec258593          	addi	a1,a1,-318 # ffffffffc0205178 <etext+0x1c0>
ffffffffc02002be:	00005517          	auipc	a0,0x5
ffffffffc02002c2:	e5250513          	addi	a0,a0,-430 # ffffffffc0205110 <etext+0x158>
ffffffffc02002c6:	ebbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc02002ca:	60a2                	ld	ra,8(sp)
ffffffffc02002cc:	4501                	li	a0,0
ffffffffc02002ce:	0141                	addi	sp,sp,16
ffffffffc02002d0:	8082                	ret

ffffffffc02002d2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d2:	1141                	addi	sp,sp,-16
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002d6:	ef3ff0ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002e6:	f71ff0ef          	jal	ra,ffffffffc0200256 <print_stackframe>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002f2:	7115                	addi	sp,sp,-224
ffffffffc02002f4:	ed5e                	sd	s7,152(sp)
ffffffffc02002f6:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f8:	00005517          	auipc	a0,0x5
ffffffffc02002fc:	e9050513          	addi	a0,a0,-368 # ffffffffc0205188 <etext+0x1d0>
kmonitor(struct trapframe *tf) {
ffffffffc0200300:	ed86                	sd	ra,216(sp)
ffffffffc0200302:	e9a2                	sd	s0,208(sp)
ffffffffc0200304:	e5a6                	sd	s1,200(sp)
ffffffffc0200306:	e1ca                	sd	s2,192(sp)
ffffffffc0200308:	fd4e                	sd	s3,184(sp)
ffffffffc020030a:	f952                	sd	s4,176(sp)
ffffffffc020030c:	f556                	sd	s5,168(sp)
ffffffffc020030e:	f15a                	sd	s6,160(sp)
ffffffffc0200310:	e962                	sd	s8,144(sp)
ffffffffc0200312:	e566                	sd	s9,136(sp)
ffffffffc0200314:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200316:	e6bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	e9650513          	addi	a0,a0,-362 # ffffffffc02051b0 <etext+0x1f8>
ffffffffc0200322:	e5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200326:	000b8563          	beqz	s7,ffffffffc0200330 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020032a:	855e                	mv	a0,s7
ffffffffc020032c:	4f4000ef          	jal	ra,ffffffffc0200820 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	4581                	li	a1,0
ffffffffc0200334:	4601                	li	a2,0
ffffffffc0200336:	48a1                	li	a7,8
ffffffffc0200338:	00000073          	ecall
ffffffffc020033c:	00005c17          	auipc	s8,0x5
ffffffffc0200340:	ee4c0c13          	addi	s8,s8,-284 # ffffffffc0205220 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200344:	00005917          	auipc	s2,0x5
ffffffffc0200348:	e9490913          	addi	s2,s2,-364 # ffffffffc02051d8 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	00005497          	auipc	s1,0x5
ffffffffc0200350:	e9448493          	addi	s1,s1,-364 # ffffffffc02051e0 <etext+0x228>
        if (argc == MAXARGS - 1) {
ffffffffc0200354:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200356:	00005b17          	auipc	s6,0x5
ffffffffc020035a:	e92b0b13          	addi	s6,s6,-366 # ffffffffc02051e8 <etext+0x230>
        argv[argc ++] = buf;
ffffffffc020035e:	00005a17          	auipc	s4,0x5
ffffffffc0200362:	daaa0a13          	addi	s4,s4,-598 # ffffffffc0205108 <etext+0x150>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200366:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200368:	854a                	mv	a0,s2
ffffffffc020036a:	d29ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc020036e:	842a                	mv	s0,a0
ffffffffc0200370:	dd65                	beqz	a0,ffffffffc0200368 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200372:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200376:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200378:	e1bd                	bnez	a1,ffffffffc02003de <kmonitor+0xec>
    if (argc == 0) {
ffffffffc020037a:	fe0c87e3          	beqz	s9,ffffffffc0200368 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037e:	6582                	ld	a1,0(sp)
ffffffffc0200380:	00005d17          	auipc	s10,0x5
ffffffffc0200384:	ea0d0d13          	addi	s10,s10,-352 # ffffffffc0205220 <commands>
        argv[argc ++] = buf;
ffffffffc0200388:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038a:	4401                	li	s0,0
ffffffffc020038c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038e:	3a9040ef          	jal	ra,ffffffffc0204f36 <strcmp>
ffffffffc0200392:	c919                	beqz	a0,ffffffffc02003a8 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200394:	2405                	addiw	s0,s0,1
ffffffffc0200396:	0b540063          	beq	s0,s5,ffffffffc0200436 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039a:	000d3503          	ld	a0,0(s10)
ffffffffc020039e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a2:	395040ef          	jal	ra,ffffffffc0204f36 <strcmp>
ffffffffc02003a6:	f57d                	bnez	a0,ffffffffc0200394 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003a8:	00141793          	slli	a5,s0,0x1
ffffffffc02003ac:	97a2                	add	a5,a5,s0
ffffffffc02003ae:	078e                	slli	a5,a5,0x3
ffffffffc02003b0:	97e2                	add	a5,a5,s8
ffffffffc02003b2:	6b9c                	ld	a5,16(a5)
ffffffffc02003b4:	865e                	mv	a2,s7
ffffffffc02003b6:	002c                	addi	a1,sp,8
ffffffffc02003b8:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003bc:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003be:	fa0555e3          	bgez	a0,ffffffffc0200368 <kmonitor+0x76>
}
ffffffffc02003c2:	60ee                	ld	ra,216(sp)
ffffffffc02003c4:	644e                	ld	s0,208(sp)
ffffffffc02003c6:	64ae                	ld	s1,200(sp)
ffffffffc02003c8:	690e                	ld	s2,192(sp)
ffffffffc02003ca:	79ea                	ld	s3,184(sp)
ffffffffc02003cc:	7a4a                	ld	s4,176(sp)
ffffffffc02003ce:	7aaa                	ld	s5,168(sp)
ffffffffc02003d0:	7b0a                	ld	s6,160(sp)
ffffffffc02003d2:	6bea                	ld	s7,152(sp)
ffffffffc02003d4:	6c4a                	ld	s8,144(sp)
ffffffffc02003d6:	6caa                	ld	s9,136(sp)
ffffffffc02003d8:	6d0a                	ld	s10,128(sp)
ffffffffc02003da:	612d                	addi	sp,sp,224
ffffffffc02003dc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	375040ef          	jal	ra,ffffffffc0204f54 <strchr>
ffffffffc02003e4:	c901                	beqz	a0,ffffffffc02003f4 <kmonitor+0x102>
ffffffffc02003e6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ea:	00040023          	sb	zero,0(s0)
ffffffffc02003ee:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f0:	d5c9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc02003f2:	b7f5                	j	ffffffffc02003de <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc02003f4:	00044783          	lbu	a5,0(s0)
ffffffffc02003f8:	d3c9                	beqz	a5,ffffffffc020037a <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc02003fa:	033c8963          	beq	s9,s3,ffffffffc020042c <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc02003fe:	003c9793          	slli	a5,s9,0x3
ffffffffc0200402:	0118                	addi	a4,sp,128
ffffffffc0200404:	97ba                	add	a5,a5,a4
ffffffffc0200406:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020040a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020040e:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200410:	e591                	bnez	a1,ffffffffc020041c <kmonitor+0x12a>
ffffffffc0200412:	b7b5                	j	ffffffffc020037e <kmonitor+0x8c>
ffffffffc0200414:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200418:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041a:	d1a5                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020041c:	8526                	mv	a0,s1
ffffffffc020041e:	337040ef          	jal	ra,ffffffffc0204f54 <strchr>
ffffffffc0200422:	d96d                	beqz	a0,ffffffffc0200414 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	00044583          	lbu	a1,0(s0)
ffffffffc0200428:	d9a9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020042a:	bf55                	j	ffffffffc02003de <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020042c:	45c1                	li	a1,16
ffffffffc020042e:	855a                	mv	a0,s6
ffffffffc0200430:	d51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200434:	b7e9                	j	ffffffffc02003fe <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200436:	6582                	ld	a1,0(sp)
ffffffffc0200438:	00005517          	auipc	a0,0x5
ffffffffc020043c:	dd050513          	addi	a0,a0,-560 # ffffffffc0205208 <etext+0x250>
ffffffffc0200440:	d41ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200444:	b715                	j	ffffffffc0200368 <kmonitor+0x76>

ffffffffc0200446 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200446:	00016317          	auipc	t1,0x16
ffffffffc020044a:	0f230313          	addi	t1,t1,242 # ffffffffc0216538 <is_panic>
ffffffffc020044e:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	e822                	sd	s0,16(sp)
ffffffffc0200458:	f436                	sd	a3,40(sp)
ffffffffc020045a:	f83a                	sd	a4,48(sp)
ffffffffc020045c:	fc3e                	sd	a5,56(sp)
ffffffffc020045e:	e0c2                	sd	a6,64(sp)
ffffffffc0200460:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200462:	020e1a63          	bnez	t3,ffffffffc0200496 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200466:	4785                	li	a5,1
ffffffffc0200468:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020046c:	8432                	mv	s0,a2
ffffffffc020046e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200470:	862e                	mv	a2,a1
ffffffffc0200472:	85aa                	mv	a1,a0
ffffffffc0200474:	00005517          	auipc	a0,0x5
ffffffffc0200478:	df450513          	addi	a0,a0,-524 # ffffffffc0205268 <commands+0x48>
    va_start(ap, fmt);
ffffffffc020047c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047e:	d03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cdbff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc020048a:	00007517          	auipc	a0,0x7
ffffffffc020048e:	80650513          	addi	a0,a0,-2042 # ffffffffc0206c90 <default_pmm_manager+0xf28>
ffffffffc0200492:	cefff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200496:	12c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020049a:	4501                	li	a0,0
ffffffffc020049c:	e57ff0ef          	jal	ra,ffffffffc02002f2 <kmonitor>
    while (1) {
ffffffffc02004a0:	bfed                	j	ffffffffc020049a <__panic+0x54>

ffffffffc02004a2 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004a2:	67e1                	lui	a5,0x18
ffffffffc02004a4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a8:	00016717          	auipc	a4,0x16
ffffffffc02004ac:	0af73023          	sd	a5,160(a4) # ffffffffc0216548 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004b0:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004b4:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004b6:	953e                	add	a0,a0,a5
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4881                	li	a7,0
ffffffffc02004bc:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004c0:	02000793          	li	a5,32
ffffffffc02004c4:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004c8:	00005517          	auipc	a0,0x5
ffffffffc02004cc:	dc050513          	addi	a0,a0,-576 # ffffffffc0205288 <commands+0x68>
    ticks = 0;
ffffffffc02004d0:	00016797          	auipc	a5,0x16
ffffffffc02004d4:	0607b823          	sd	zero,112(a5) # ffffffffc0216540 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d8:	b165                	j	ffffffffc0200180 <cprintf>

ffffffffc02004da <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004da:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004de:	00016797          	auipc	a5,0x16
ffffffffc02004e2:	06a7b783          	ld	a5,106(a5) # ffffffffc0216548 <timebase>
ffffffffc02004e6:	953e                	add	a0,a0,a5
ffffffffc02004e8:	4581                	li	a1,0
ffffffffc02004ea:	4601                	li	a2,0
ffffffffc02004ec:	4881                	li	a7,0
ffffffffc02004ee:	00000073          	ecall
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004f4:	8082                	ret

ffffffffc02004f6 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004f6:	100027f3          	csrr	a5,sstatus
ffffffffc02004fa:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02004fc:	0ff57513          	andi	a0,a0,255
ffffffffc0200500:	e799                	bnez	a5,ffffffffc020050e <cons_putc+0x18>
ffffffffc0200502:	4581                	li	a1,0
ffffffffc0200504:	4601                	li	a2,0
ffffffffc0200506:	4885                	li	a7,1
ffffffffc0200508:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020050c:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020050e:	1101                	addi	sp,sp,-32
ffffffffc0200510:	ec06                	sd	ra,24(sp)
ffffffffc0200512:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200514:	0ae000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0200518:	6522                	ld	a0,8(sp)
ffffffffc020051a:	4581                	li	a1,0
ffffffffc020051c:	4601                	li	a2,0
ffffffffc020051e:	4885                	li	a7,1
ffffffffc0200520:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200524:	60e2                	ld	ra,24(sp)
ffffffffc0200526:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200528:	a851                	j	ffffffffc02005bc <intr_enable>

ffffffffc020052a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020052a:	100027f3          	csrr	a5,sstatus
ffffffffc020052e:	8b89                	andi	a5,a5,2
ffffffffc0200530:	eb89                	bnez	a5,ffffffffc0200542 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200532:	4501                	li	a0,0
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4889                	li	a7,2
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200540:	8082                	ret
int cons_getc(void) {
ffffffffc0200542:	1101                	addi	sp,sp,-32
ffffffffc0200544:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200546:	07c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc020054a:	4501                	li	a0,0
ffffffffc020054c:	4581                	li	a1,0
ffffffffc020054e:	4601                	li	a2,0
ffffffffc0200550:	4889                	li	a7,2
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	2501                	sext.w	a0,a0
ffffffffc0200558:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020055a:	062000ef          	jal	ra,ffffffffc02005bc <intr_enable>
}
ffffffffc020055e:	60e2                	ld	ra,24(sp)
ffffffffc0200560:	6522                	ld	a0,8(sp)
ffffffffc0200562:	6105                	addi	sp,sp,32
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200566:	8082                	ret

ffffffffc0200568 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200568:	00253513          	sltiu	a0,a0,2
ffffffffc020056c:	8082                	ret

ffffffffc020056e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020056e:	03800513          	li	a0,56
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200574:	0000b797          	auipc	a5,0xb
ffffffffc0200578:	eec78793          	addi	a5,a5,-276 # ffffffffc020b460 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020057c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200580:	1141                	addi	sp,sp,-16
ffffffffc0200582:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200584:	95be                	add	a1,a1,a5
ffffffffc0200586:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020058a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020058c:	1f1040ef          	jal	ra,ffffffffc0204f7c <memcpy>
    return 0;
}
ffffffffc0200590:	60a2                	ld	ra,8(sp)
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	0141                	addi	sp,sp,16
ffffffffc0200596:	8082                	ret

ffffffffc0200598 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200598:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020059c:	0000b517          	auipc	a0,0xb
ffffffffc02005a0:	ec450513          	addi	a0,a0,-316 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02005a4:	1141                	addi	sp,sp,-16
ffffffffc02005a6:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a8:	953e                	add	a0,a0,a5
ffffffffc02005aa:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02005ae:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005b0:	1cd040ef          	jal	ra,ffffffffc0204f7c <memcpy>
    return 0;
}
ffffffffc02005b4:	60a2                	ld	ra,8(sp)
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	0141                	addi	sp,sp,16
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005bc:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005c0:	8082                	ret

ffffffffc02005c2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005c2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005c6:	8082                	ret

ffffffffc02005c8 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ca:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ce:	1141                	addi	sp,sp,-16
ffffffffc02005d0:	e022                	sd	s0,0(sp)
ffffffffc02005d2:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d4:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005d8:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005de:	05500613          	li	a2,85
ffffffffc02005e2:	c399                	beqz	a5,ffffffffc02005e8 <pgfault_handler+0x1e>
ffffffffc02005e4:	04b00613          	li	a2,75
ffffffffc02005e8:	11843703          	ld	a4,280(s0)
ffffffffc02005ec:	47bd                	li	a5,15
ffffffffc02005ee:	05700693          	li	a3,87
ffffffffc02005f2:	00f70463          	beq	a4,a5,ffffffffc02005fa <pgfault_handler+0x30>
ffffffffc02005f6:	05200693          	li	a3,82
ffffffffc02005fa:	00005517          	auipc	a0,0x5
ffffffffc02005fe:	cae50513          	addi	a0,a0,-850 # ffffffffc02052a8 <commands+0x88>
ffffffffc0200602:	b7fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00016517          	auipc	a0,0x16
ffffffffc020060a:	fa253503          	ld	a0,-94(a0) # ffffffffc02165a8 <check_mm_struct>
ffffffffc020060e:	c911                	beqz	a0,ffffffffc0200622 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200610:	11043603          	ld	a2,272(s0)
ffffffffc0200614:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200618:	6402                	ld	s0,0(sp)
ffffffffc020061a:	60a2                	ld	ra,8(sp)
ffffffffc020061c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020061e:	2250306f          	j	ffffffffc0204042 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00005617          	auipc	a2,0x5
ffffffffc0200626:	ca660613          	addi	a2,a2,-858 # ffffffffc02052c8 <commands+0xa8>
ffffffffc020062a:	06400593          	li	a1,100
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	cb250513          	addi	a0,a0,-846 # ffffffffc02052e0 <commands+0xc0>
ffffffffc0200636:	e11ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020063a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020063a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020063e:	00000797          	auipc	a5,0x0
ffffffffc0200642:	4de78793          	addi	a5,a5,1246 # ffffffffc0200b1c <__alltraps>
ffffffffc0200646:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020064a:	000407b7          	lui	a5,0x40
ffffffffc020064e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200654:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200656:	1141                	addi	sp,sp,-16
ffffffffc0200658:	e022                	sd	s0,0(sp)
ffffffffc020065a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065c:	00005517          	auipc	a0,0x5
ffffffffc0200660:	c9c50513          	addi	a0,a0,-868 # ffffffffc02052f8 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	b1bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	ca450513          	addi	a0,a0,-860 # ffffffffc0205310 <commands+0xf0>
ffffffffc0200674:	b0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00005517          	auipc	a0,0x5
ffffffffc020067e:	cae50513          	addi	a0,a0,-850 # ffffffffc0205328 <commands+0x108>
ffffffffc0200682:	affff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00005517          	auipc	a0,0x5
ffffffffc020068c:	cb850513          	addi	a0,a0,-840 # ffffffffc0205340 <commands+0x120>
ffffffffc0200690:	af1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00005517          	auipc	a0,0x5
ffffffffc020069a:	cc250513          	addi	a0,a0,-830 # ffffffffc0205358 <commands+0x138>
ffffffffc020069e:	ae3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00005517          	auipc	a0,0x5
ffffffffc02006a8:	ccc50513          	addi	a0,a0,-820 # ffffffffc0205370 <commands+0x150>
ffffffffc02006ac:	ad5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00005517          	auipc	a0,0x5
ffffffffc02006b6:	cd650513          	addi	a0,a0,-810 # ffffffffc0205388 <commands+0x168>
ffffffffc02006ba:	ac7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00005517          	auipc	a0,0x5
ffffffffc02006c4:	ce050513          	addi	a0,a0,-800 # ffffffffc02053a0 <commands+0x180>
ffffffffc02006c8:	ab9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00005517          	auipc	a0,0x5
ffffffffc02006d2:	cea50513          	addi	a0,a0,-790 # ffffffffc02053b8 <commands+0x198>
ffffffffc02006d6:	aabff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00005517          	auipc	a0,0x5
ffffffffc02006e0:	cf450513          	addi	a0,a0,-780 # ffffffffc02053d0 <commands+0x1b0>
ffffffffc02006e4:	a9dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00005517          	auipc	a0,0x5
ffffffffc02006ee:	cfe50513          	addi	a0,a0,-770 # ffffffffc02053e8 <commands+0x1c8>
ffffffffc02006f2:	a8fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	d0850513          	addi	a0,a0,-760 # ffffffffc0205400 <commands+0x1e0>
ffffffffc0200700:	a81ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00005517          	auipc	a0,0x5
ffffffffc020070a:	d1250513          	addi	a0,a0,-750 # ffffffffc0205418 <commands+0x1f8>
ffffffffc020070e:	a73ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00005517          	auipc	a0,0x5
ffffffffc0200718:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205430 <commands+0x210>
ffffffffc020071c:	a65ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00005517          	auipc	a0,0x5
ffffffffc0200726:	d2650513          	addi	a0,a0,-730 # ffffffffc0205448 <commands+0x228>
ffffffffc020072a:	a57ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	d3050513          	addi	a0,a0,-720 # ffffffffc0205460 <commands+0x240>
ffffffffc0200738:	a49ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00005517          	auipc	a0,0x5
ffffffffc0200742:	d3a50513          	addi	a0,a0,-710 # ffffffffc0205478 <commands+0x258>
ffffffffc0200746:	a3bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00005517          	auipc	a0,0x5
ffffffffc0200750:	d4450513          	addi	a0,a0,-700 # ffffffffc0205490 <commands+0x270>
ffffffffc0200754:	a2dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00005517          	auipc	a0,0x5
ffffffffc020075e:	d4e50513          	addi	a0,a0,-690 # ffffffffc02054a8 <commands+0x288>
ffffffffc0200762:	a1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00005517          	auipc	a0,0x5
ffffffffc020076c:	d5850513          	addi	a0,a0,-680 # ffffffffc02054c0 <commands+0x2a0>
ffffffffc0200770:	a11ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	d6250513          	addi	a0,a0,-670 # ffffffffc02054d8 <commands+0x2b8>
ffffffffc020077e:	a03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00005517          	auipc	a0,0x5
ffffffffc0200788:	d6c50513          	addi	a0,a0,-660 # ffffffffc02054f0 <commands+0x2d0>
ffffffffc020078c:	9f5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00005517          	auipc	a0,0x5
ffffffffc0200796:	d7650513          	addi	a0,a0,-650 # ffffffffc0205508 <commands+0x2e8>
ffffffffc020079a:	9e7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00005517          	auipc	a0,0x5
ffffffffc02007a4:	d8050513          	addi	a0,a0,-640 # ffffffffc0205520 <commands+0x300>
ffffffffc02007a8:	9d9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00005517          	auipc	a0,0x5
ffffffffc02007b2:	d8a50513          	addi	a0,a0,-630 # ffffffffc0205538 <commands+0x318>
ffffffffc02007b6:	9cbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	d9450513          	addi	a0,a0,-620 # ffffffffc0205550 <commands+0x330>
ffffffffc02007c4:	9bdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00005517          	auipc	a0,0x5
ffffffffc02007ce:	d9e50513          	addi	a0,a0,-610 # ffffffffc0205568 <commands+0x348>
ffffffffc02007d2:	9afff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00005517          	auipc	a0,0x5
ffffffffc02007dc:	da850513          	addi	a0,a0,-600 # ffffffffc0205580 <commands+0x360>
ffffffffc02007e0:	9a1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00005517          	auipc	a0,0x5
ffffffffc02007ea:	db250513          	addi	a0,a0,-590 # ffffffffc0205598 <commands+0x378>
ffffffffc02007ee:	993ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00005517          	auipc	a0,0x5
ffffffffc02007f8:	dbc50513          	addi	a0,a0,-580 # ffffffffc02055b0 <commands+0x390>
ffffffffc02007fc:	985ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00005517          	auipc	a0,0x5
ffffffffc0200806:	dc650513          	addi	a0,a0,-570 # ffffffffc02055c8 <commands+0x3a8>
ffffffffc020080a:	977ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00005517          	auipc	a0,0x5
ffffffffc0200818:	dcc50513          	addi	a0,a0,-564 # ffffffffc02055e0 <commands+0x3c0>
}
ffffffffc020081c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	b28d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200820 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200820:	1141                	addi	sp,sp,-16
ffffffffc0200822:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200828:	00005517          	auipc	a0,0x5
ffffffffc020082c:	dd050513          	addi	a0,a0,-560 # ffffffffc02055f8 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200832:	94fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200836:	8522                	mv	a0,s0
ffffffffc0200838:	e1dff0ef          	jal	ra,ffffffffc0200654 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083c:	10043583          	ld	a1,256(s0)
ffffffffc0200840:	00005517          	auipc	a0,0x5
ffffffffc0200844:	dd050513          	addi	a0,a0,-560 # ffffffffc0205610 <commands+0x3f0>
ffffffffc0200848:	939ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084c:	10843583          	ld	a1,264(s0)
ffffffffc0200850:	00005517          	auipc	a0,0x5
ffffffffc0200854:	dd850513          	addi	a0,a0,-552 # ffffffffc0205628 <commands+0x408>
ffffffffc0200858:	929ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085c:	11043583          	ld	a1,272(s0)
ffffffffc0200860:	00005517          	auipc	a0,0x5
ffffffffc0200864:	de050513          	addi	a0,a0,-544 # ffffffffc0205640 <commands+0x420>
ffffffffc0200868:	919ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200870:	6402                	ld	s0,0(sp)
ffffffffc0200872:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200874:	00005517          	auipc	a0,0x5
ffffffffc0200878:	de450513          	addi	a0,a0,-540 # ffffffffc0205658 <commands+0x438>
}
ffffffffc020087c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087e:	903ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200882 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200882:	11853783          	ld	a5,280(a0)
ffffffffc0200886:	472d                	li	a4,11
ffffffffc0200888:	0786                	slli	a5,a5,0x1
ffffffffc020088a:	8385                	srli	a5,a5,0x1
ffffffffc020088c:	08f76d63          	bltu	a4,a5,ffffffffc0200926 <interrupt_handler+0xa4>
ffffffffc0200890:	00005717          	auipc	a4,0x5
ffffffffc0200894:	e9070713          	addi	a4,a4,-368 # ffffffffc0205720 <commands+0x500>
ffffffffc0200898:	078a                	slli	a5,a5,0x2
ffffffffc020089a:	97ba                	add	a5,a5,a4
ffffffffc020089c:	439c                	lw	a5,0(a5)
ffffffffc020089e:	97ba                	add	a5,a5,a4
ffffffffc02008a0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008a2:	00005517          	auipc	a0,0x5
ffffffffc02008a6:	e2e50513          	addi	a0,a0,-466 # ffffffffc02056d0 <commands+0x4b0>
ffffffffc02008aa:	8d7ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ae:	00005517          	auipc	a0,0x5
ffffffffc02008b2:	e0250513          	addi	a0,a0,-510 # ffffffffc02056b0 <commands+0x490>
ffffffffc02008b6:	8cbff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008ba:	00005517          	auipc	a0,0x5
ffffffffc02008be:	db650513          	addi	a0,a0,-586 # ffffffffc0205670 <commands+0x450>
ffffffffc02008c2:	8bfff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c6:	00005517          	auipc	a0,0x5
ffffffffc02008ca:	dca50513          	addi	a0,a0,-566 # ffffffffc0205690 <commands+0x470>
ffffffffc02008ce:	8b3ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d2:	1141                	addi	sp,sp,-16
ffffffffc02008d4:	e022                	sd	s0,0(sp)
ffffffffc02008d6:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d8:	c03ff0ef          	jal	ra,ffffffffc02004da <clock_set_next_event>
            ++ticks;
ffffffffc02008dc:	00016797          	auipc	a5,0x16
ffffffffc02008e0:	c6478793          	addi	a5,a5,-924 # ffffffffc0216540 <ticks>
ffffffffc02008e4:	6398                	ld	a4,0(a5)
ffffffffc02008e6:	00016417          	auipc	s0,0x16
ffffffffc02008ea:	c6a40413          	addi	s0,s0,-918 # ffffffffc0216550 <num>
ffffffffc02008ee:	0705                	addi	a4,a4,1
ffffffffc02008f0:	e398                	sd	a4,0(a5)
            if (ticks % TICK_NUM == 0) {
ffffffffc02008f2:	639c                	ld	a5,0(a5)
ffffffffc02008f4:	06400713          	li	a4,100
ffffffffc02008f8:	02e7f7b3          	remu	a5,a5,a4
ffffffffc02008fc:	c795                	beqz	a5,ffffffffc0200928 <interrupt_handler+0xa6>
                print_ticks();
                num++;
            }
            if(num == 10)
ffffffffc02008fe:	6018                	ld	a4,0(s0)
ffffffffc0200900:	47a9                	li	a5,10
ffffffffc0200902:	00f71863          	bne	a4,a5,ffffffffc0200912 <interrupt_handler+0x90>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200906:	4501                	li	a0,0
ffffffffc0200908:	4581                	li	a1,0
ffffffffc020090a:	4601                	li	a2,0
ffffffffc020090c:	48a1                	li	a7,8
ffffffffc020090e:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200912:	60a2                	ld	ra,8(sp)
ffffffffc0200914:	6402                	ld	s0,0(sp)
ffffffffc0200916:	0141                	addi	sp,sp,16
ffffffffc0200918:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020091a:	00005517          	auipc	a0,0x5
ffffffffc020091e:	de650513          	addi	a0,a0,-538 # ffffffffc0205700 <commands+0x4e0>
ffffffffc0200922:	85fff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200926:	bded                	j	ffffffffc0200820 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200928:	06400593          	li	a1,100
ffffffffc020092c:	00005517          	auipc	a0,0x5
ffffffffc0200930:	dc450513          	addi	a0,a0,-572 # ffffffffc02056f0 <commands+0x4d0>
ffffffffc0200934:	84dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
                num++;
ffffffffc0200938:	601c                	ld	a5,0(s0)
ffffffffc020093a:	0785                	addi	a5,a5,1
ffffffffc020093c:	e01c                	sd	a5,0(s0)
ffffffffc020093e:	b7c1                	j	ffffffffc02008fe <interrupt_handler+0x7c>

ffffffffc0200940 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200940:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200944:	1101                	addi	sp,sp,-32
ffffffffc0200946:	e822                	sd	s0,16(sp)
ffffffffc0200948:	ec06                	sd	ra,24(sp)
ffffffffc020094a:	e426                	sd	s1,8(sp)
ffffffffc020094c:	473d                	li	a4,15
ffffffffc020094e:	842a                	mv	s0,a0
ffffffffc0200950:	18f76963          	bltu	a4,a5,ffffffffc0200ae2 <exception_handler+0x1a2>
ffffffffc0200954:	00005717          	auipc	a4,0x5
ffffffffc0200958:	01470713          	addi	a4,a4,20 # ffffffffc0205968 <commands+0x748>
ffffffffc020095c:	078a                	slli	a5,a5,0x2
ffffffffc020095e:	97ba                	add	a5,a5,a4
ffffffffc0200960:	439c                	lw	a5,0(a5)
ffffffffc0200962:	97ba                	add	a5,a5,a4
ffffffffc0200964:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200966:	00005517          	auipc	a0,0x5
ffffffffc020096a:	fea50513          	addi	a0,a0,-22 # ffffffffc0205950 <commands+0x730>
ffffffffc020096e:	813ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200972:	8522                	mv	a0,s0
ffffffffc0200974:	c57ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200978:	84aa                	mv	s1,a0
ffffffffc020097a:	16051a63          	bnez	a0,ffffffffc0200aee <exception_handler+0x1ae>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020097e:	60e2                	ld	ra,24(sp)
ffffffffc0200980:	6442                	ld	s0,16(sp)
ffffffffc0200982:	64a2                	ld	s1,8(sp)
ffffffffc0200984:	6105                	addi	sp,sp,32
ffffffffc0200986:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200988:	00005517          	auipc	a0,0x5
ffffffffc020098c:	dc850513          	addi	a0,a0,-568 # ffffffffc0205750 <commands+0x530>
}
ffffffffc0200990:	6442                	ld	s0,16(sp)
ffffffffc0200992:	60e2                	ld	ra,24(sp)
ffffffffc0200994:	64a2                	ld	s1,8(sp)
ffffffffc0200996:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200998:	fe8ff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc020099c:	00005517          	auipc	a0,0x5
ffffffffc02009a0:	dd450513          	addi	a0,a0,-556 # ffffffffc0205770 <commands+0x550>
ffffffffc02009a4:	b7f5                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Exception Type: Illegal instruction\n");
ffffffffc02009a6:	00005517          	auipc	a0,0x5
ffffffffc02009aa:	dea50513          	addi	a0,a0,-534 # ffffffffc0205790 <commands+0x570>
ffffffffc02009ae:	fd2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            cprintf("Illegal instruction caught at 0x%lx\n",tf->epc);
ffffffffc02009b2:	10843583          	ld	a1,264(s0)
ffffffffc02009b6:	00005517          	auipc	a0,0x5
ffffffffc02009ba:	e0250513          	addi	a0,a0,-510 # ffffffffc02057b8 <commands+0x598>
ffffffffc02009be:	fc2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc+=4;
ffffffffc02009c2:	10843783          	ld	a5,264(s0)
ffffffffc02009c6:	0791                	addi	a5,a5,4
ffffffffc02009c8:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc02009cc:	bf4d                	j	ffffffffc020097e <exception_handler+0x3e>
            cprintf("Exception Type: breakpoint\n");
ffffffffc02009ce:	00005517          	auipc	a0,0x5
ffffffffc02009d2:	e1250513          	addi	a0,a0,-494 # ffffffffc02057e0 <commands+0x5c0>
ffffffffc02009d6:	faaff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            cprintf("ebreak caught at 0x%lx\n",tf->epc);
ffffffffc02009da:	10843583          	ld	a1,264(s0)
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	e2250513          	addi	a0,a0,-478 # ffffffffc0205800 <commands+0x5e0>
ffffffffc02009e6:	f9aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc+=2;
ffffffffc02009ea:	10843783          	ld	a5,264(s0)
ffffffffc02009ee:	0789                	addi	a5,a5,2
ffffffffc02009f0:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc02009f4:	b769                	j	ffffffffc020097e <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc02009f6:	00005517          	auipc	a0,0x5
ffffffffc02009fa:	e2250513          	addi	a0,a0,-478 # ffffffffc0205818 <commands+0x5f8>
ffffffffc02009fe:	bf49                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200a00:	00005517          	auipc	a0,0x5
ffffffffc0200a04:	e3850513          	addi	a0,a0,-456 # ffffffffc0205838 <commands+0x618>
ffffffffc0200a08:	f78ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a0c:	8522                	mv	a0,s0
ffffffffc0200a0e:	bbdff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a12:	84aa                	mv	s1,a0
ffffffffc0200a14:	d52d                	beqz	a0,ffffffffc020097e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a16:	8522                	mv	a0,s0
ffffffffc0200a18:	e09ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a1c:	86a6                	mv	a3,s1
ffffffffc0200a1e:	00005617          	auipc	a2,0x5
ffffffffc0200a22:	e3260613          	addi	a2,a2,-462 # ffffffffc0205850 <commands+0x630>
ffffffffc0200a26:	0c500593          	li	a1,197
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	8b650513          	addi	a0,a0,-1866 # ffffffffc02052e0 <commands+0xc0>
ffffffffc0200a32:	a15ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200a36:	00005517          	auipc	a0,0x5
ffffffffc0200a3a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0205870 <commands+0x650>
ffffffffc0200a3e:	bf89                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a40:	00005517          	auipc	a0,0x5
ffffffffc0200a44:	e4850513          	addi	a0,a0,-440 # ffffffffc0205888 <commands+0x668>
ffffffffc0200a48:	f38ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a4c:	8522                	mv	a0,s0
ffffffffc0200a4e:	b7dff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a52:	84aa                	mv	s1,a0
ffffffffc0200a54:	f20505e3          	beqz	a0,ffffffffc020097e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a58:	8522                	mv	a0,s0
ffffffffc0200a5a:	dc7ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a5e:	86a6                	mv	a3,s1
ffffffffc0200a60:	00005617          	auipc	a2,0x5
ffffffffc0200a64:	df060613          	addi	a2,a2,-528 # ffffffffc0205850 <commands+0x630>
ffffffffc0200a68:	0cf00593          	li	a1,207
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	87450513          	addi	a0,a0,-1932 # ffffffffc02052e0 <commands+0xc0>
ffffffffc0200a74:	9d3ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a78:	00005517          	auipc	a0,0x5
ffffffffc0200a7c:	e2850513          	addi	a0,a0,-472 # ffffffffc02058a0 <commands+0x680>
ffffffffc0200a80:	bf01                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a82:	00005517          	auipc	a0,0x5
ffffffffc0200a86:	e3e50513          	addi	a0,a0,-450 # ffffffffc02058c0 <commands+0x6a0>
ffffffffc0200a8a:	b719                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00005517          	auipc	a0,0x5
ffffffffc0200a90:	e5450513          	addi	a0,a0,-428 # ffffffffc02058e0 <commands+0x6c0>
ffffffffc0200a94:	bdf5                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	e6a50513          	addi	a0,a0,-406 # ffffffffc0205900 <commands+0x6e0>
ffffffffc0200a9e:	bdcd                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aa0:	00005517          	auipc	a0,0x5
ffffffffc0200aa4:	e8050513          	addi	a0,a0,-384 # ffffffffc0205920 <commands+0x700>
ffffffffc0200aa8:	b5e5                	j	ffffffffc0200990 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200aaa:	00005517          	auipc	a0,0x5
ffffffffc0200aae:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205938 <commands+0x718>
ffffffffc0200ab2:	eceff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ab6:	8522                	mv	a0,s0
ffffffffc0200ab8:	b13ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200abc:	84aa                	mv	s1,a0
ffffffffc0200abe:	ec0500e3          	beqz	a0,ffffffffc020097e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200ac2:	8522                	mv	a0,s0
ffffffffc0200ac4:	d5dff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ac8:	86a6                	mv	a3,s1
ffffffffc0200aca:	00005617          	auipc	a2,0x5
ffffffffc0200ace:	d8660613          	addi	a2,a2,-634 # ffffffffc0205850 <commands+0x630>
ffffffffc0200ad2:	0e500593          	li	a1,229
ffffffffc0200ad6:	00005517          	auipc	a0,0x5
ffffffffc0200ada:	80a50513          	addi	a0,a0,-2038 # ffffffffc02052e0 <commands+0xc0>
ffffffffc0200ade:	969ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            print_trapframe(tf);
ffffffffc0200ae2:	8522                	mv	a0,s0
}
ffffffffc0200ae4:	6442                	ld	s0,16(sp)
ffffffffc0200ae6:	60e2                	ld	ra,24(sp)
ffffffffc0200ae8:	64a2                	ld	s1,8(sp)
ffffffffc0200aea:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200aec:	bb15                	j	ffffffffc0200820 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200aee:	8522                	mv	a0,s0
ffffffffc0200af0:	d31ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af4:	86a6                	mv	a3,s1
ffffffffc0200af6:	00005617          	auipc	a2,0x5
ffffffffc0200afa:	d5a60613          	addi	a2,a2,-678 # ffffffffc0205850 <commands+0x630>
ffffffffc0200afe:	0ec00593          	li	a1,236
ffffffffc0200b02:	00004517          	auipc	a0,0x4
ffffffffc0200b06:	7de50513          	addi	a0,a0,2014 # ffffffffc02052e0 <commands+0xc0>
ffffffffc0200b0a:	93dff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200b0e <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200b0e:	11853783          	ld	a5,280(a0)
ffffffffc0200b12:	0007c363          	bltz	a5,ffffffffc0200b18 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200b16:	b52d                	j	ffffffffc0200940 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200b18:	b3ad                	j	ffffffffc0200882 <interrupt_handler>
	...

ffffffffc0200b1c <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200b1c:	14011073          	csrw	sscratch,sp
ffffffffc0200b20:	712d                	addi	sp,sp,-288
ffffffffc0200b22:	e406                	sd	ra,8(sp)
ffffffffc0200b24:	ec0e                	sd	gp,24(sp)
ffffffffc0200b26:	f012                	sd	tp,32(sp)
ffffffffc0200b28:	f416                	sd	t0,40(sp)
ffffffffc0200b2a:	f81a                	sd	t1,48(sp)
ffffffffc0200b2c:	fc1e                	sd	t2,56(sp)
ffffffffc0200b2e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b30:	e4a6                	sd	s1,72(sp)
ffffffffc0200b32:	e8aa                	sd	a0,80(sp)
ffffffffc0200b34:	ecae                	sd	a1,88(sp)
ffffffffc0200b36:	f0b2                	sd	a2,96(sp)
ffffffffc0200b38:	f4b6                	sd	a3,104(sp)
ffffffffc0200b3a:	f8ba                	sd	a4,112(sp)
ffffffffc0200b3c:	fcbe                	sd	a5,120(sp)
ffffffffc0200b3e:	e142                	sd	a6,128(sp)
ffffffffc0200b40:	e546                	sd	a7,136(sp)
ffffffffc0200b42:	e94a                	sd	s2,144(sp)
ffffffffc0200b44:	ed4e                	sd	s3,152(sp)
ffffffffc0200b46:	f152                	sd	s4,160(sp)
ffffffffc0200b48:	f556                	sd	s5,168(sp)
ffffffffc0200b4a:	f95a                	sd	s6,176(sp)
ffffffffc0200b4c:	fd5e                	sd	s7,184(sp)
ffffffffc0200b4e:	e1e2                	sd	s8,192(sp)
ffffffffc0200b50:	e5e6                	sd	s9,200(sp)
ffffffffc0200b52:	e9ea                	sd	s10,208(sp)
ffffffffc0200b54:	edee                	sd	s11,216(sp)
ffffffffc0200b56:	f1f2                	sd	t3,224(sp)
ffffffffc0200b58:	f5f6                	sd	t4,232(sp)
ffffffffc0200b5a:	f9fa                	sd	t5,240(sp)
ffffffffc0200b5c:	fdfe                	sd	t6,248(sp)
ffffffffc0200b5e:	14002473          	csrr	s0,sscratch
ffffffffc0200b62:	100024f3          	csrr	s1,sstatus
ffffffffc0200b66:	14102973          	csrr	s2,sepc
ffffffffc0200b6a:	143029f3          	csrr	s3,stval
ffffffffc0200b6e:	14202a73          	csrr	s4,scause
ffffffffc0200b72:	e822                	sd	s0,16(sp)
ffffffffc0200b74:	e226                	sd	s1,256(sp)
ffffffffc0200b76:	e64a                	sd	s2,264(sp)
ffffffffc0200b78:	ea4e                	sd	s3,272(sp)
ffffffffc0200b7a:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b7c:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b7e:	f91ff0ef          	jal	ra,ffffffffc0200b0e <trap>

ffffffffc0200b82 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b82:	6492                	ld	s1,256(sp)
ffffffffc0200b84:	6932                	ld	s2,264(sp)
ffffffffc0200b86:	10049073          	csrw	sstatus,s1
ffffffffc0200b8a:	14191073          	csrw	sepc,s2
ffffffffc0200b8e:	60a2                	ld	ra,8(sp)
ffffffffc0200b90:	61e2                	ld	gp,24(sp)
ffffffffc0200b92:	7202                	ld	tp,32(sp)
ffffffffc0200b94:	72a2                	ld	t0,40(sp)
ffffffffc0200b96:	7342                	ld	t1,48(sp)
ffffffffc0200b98:	73e2                	ld	t2,56(sp)
ffffffffc0200b9a:	6406                	ld	s0,64(sp)
ffffffffc0200b9c:	64a6                	ld	s1,72(sp)
ffffffffc0200b9e:	6546                	ld	a0,80(sp)
ffffffffc0200ba0:	65e6                	ld	a1,88(sp)
ffffffffc0200ba2:	7606                	ld	a2,96(sp)
ffffffffc0200ba4:	76a6                	ld	a3,104(sp)
ffffffffc0200ba6:	7746                	ld	a4,112(sp)
ffffffffc0200ba8:	77e6                	ld	a5,120(sp)
ffffffffc0200baa:	680a                	ld	a6,128(sp)
ffffffffc0200bac:	68aa                	ld	a7,136(sp)
ffffffffc0200bae:	694a                	ld	s2,144(sp)
ffffffffc0200bb0:	69ea                	ld	s3,152(sp)
ffffffffc0200bb2:	7a0a                	ld	s4,160(sp)
ffffffffc0200bb4:	7aaa                	ld	s5,168(sp)
ffffffffc0200bb6:	7b4a                	ld	s6,176(sp)
ffffffffc0200bb8:	7bea                	ld	s7,184(sp)
ffffffffc0200bba:	6c0e                	ld	s8,192(sp)
ffffffffc0200bbc:	6cae                	ld	s9,200(sp)
ffffffffc0200bbe:	6d4e                	ld	s10,208(sp)
ffffffffc0200bc0:	6dee                	ld	s11,216(sp)
ffffffffc0200bc2:	7e0e                	ld	t3,224(sp)
ffffffffc0200bc4:	7eae                	ld	t4,232(sp)
ffffffffc0200bc6:	7f4e                	ld	t5,240(sp)
ffffffffc0200bc8:	7fee                	ld	t6,248(sp)
ffffffffc0200bca:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200bcc:	10200073          	sret

ffffffffc0200bd0 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200bd0:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200bd2:	bf45                	j	ffffffffc0200b82 <__trapret>
	...

ffffffffc0200bd6 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bd6:	00012797          	auipc	a5,0x12
ffffffffc0200bda:	88a78793          	addi	a5,a5,-1910 # ffffffffc0212460 <free_area>
ffffffffc0200bde:	e79c                	sd	a5,8(a5)
ffffffffc0200be0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200be2:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200be6:	8082                	ret

ffffffffc0200be8 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200be8:	00012517          	auipc	a0,0x12
ffffffffc0200bec:	88856503          	lwu	a0,-1912(a0) # ffffffffc0212470 <free_area+0x10>
ffffffffc0200bf0:	8082                	ret

ffffffffc0200bf2 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200bf2:	715d                	addi	sp,sp,-80
ffffffffc0200bf4:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200bf6:	00012417          	auipc	s0,0x12
ffffffffc0200bfa:	86a40413          	addi	s0,s0,-1942 # ffffffffc0212460 <free_area>
ffffffffc0200bfe:	641c                	ld	a5,8(s0)
ffffffffc0200c00:	e486                	sd	ra,72(sp)
ffffffffc0200c02:	fc26                	sd	s1,56(sp)
ffffffffc0200c04:	f84a                	sd	s2,48(sp)
ffffffffc0200c06:	f44e                	sd	s3,40(sp)
ffffffffc0200c08:	f052                	sd	s4,32(sp)
ffffffffc0200c0a:	ec56                	sd	s5,24(sp)
ffffffffc0200c0c:	e85a                	sd	s6,16(sp)
ffffffffc0200c0e:	e45e                	sd	s7,8(sp)
ffffffffc0200c10:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c12:	2a878d63          	beq	a5,s0,ffffffffc0200ecc <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200c16:	4481                	li	s1,0
ffffffffc0200c18:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c1a:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200c1e:	8b09                	andi	a4,a4,2
ffffffffc0200c20:	2a070a63          	beqz	a4,ffffffffc0200ed4 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200c24:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c28:	679c                	ld	a5,8(a5)
ffffffffc0200c2a:	2905                	addiw	s2,s2,1
ffffffffc0200c2c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c2e:	fe8796e3          	bne	a5,s0,ffffffffc0200c1a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200c32:	89a6                	mv	s3,s1
ffffffffc0200c34:	72f000ef          	jal	ra,ffffffffc0201b62 <nr_free_pages>
ffffffffc0200c38:	6f351e63          	bne	a0,s3,ffffffffc0201334 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c3c:	4505                	li	a0,1
ffffffffc0200c3e:	653000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200c42:	8aaa                	mv	s5,a0
ffffffffc0200c44:	42050863          	beqz	a0,ffffffffc0201074 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c48:	4505                	li	a0,1
ffffffffc0200c4a:	647000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200c4e:	89aa                	mv	s3,a0
ffffffffc0200c50:	70050263          	beqz	a0,ffffffffc0201354 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c54:	4505                	li	a0,1
ffffffffc0200c56:	63b000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200c5a:	8a2a                	mv	s4,a0
ffffffffc0200c5c:	48050c63          	beqz	a0,ffffffffc02010f4 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c60:	293a8a63          	beq	s5,s3,ffffffffc0200ef4 <default_check+0x302>
ffffffffc0200c64:	28aa8863          	beq	s5,a0,ffffffffc0200ef4 <default_check+0x302>
ffffffffc0200c68:	28a98663          	beq	s3,a0,ffffffffc0200ef4 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c6c:	000aa783          	lw	a5,0(s5)
ffffffffc0200c70:	2a079263          	bnez	a5,ffffffffc0200f14 <default_check+0x322>
ffffffffc0200c74:	0009a783          	lw	a5,0(s3)
ffffffffc0200c78:	28079e63          	bnez	a5,ffffffffc0200f14 <default_check+0x322>
ffffffffc0200c7c:	411c                	lw	a5,0(a0)
ffffffffc0200c7e:	28079b63          	bnez	a5,ffffffffc0200f14 <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c82:	00016797          	auipc	a5,0x16
ffffffffc0200c86:	8f67b783          	ld	a5,-1802(a5) # ffffffffc0216578 <pages>
ffffffffc0200c8a:	40fa8733          	sub	a4,s5,a5
ffffffffc0200c8e:	00006617          	auipc	a2,0x6
ffffffffc0200c92:	49a63603          	ld	a2,1178(a2) # ffffffffc0207128 <nbase>
ffffffffc0200c96:	8719                	srai	a4,a4,0x6
ffffffffc0200c98:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c9a:	00016697          	auipc	a3,0x16
ffffffffc0200c9e:	8d66b683          	ld	a3,-1834(a3) # ffffffffc0216570 <npage>
ffffffffc0200ca2:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ca4:	0732                	slli	a4,a4,0xc
ffffffffc0200ca6:	28d77763          	bgeu	a4,a3,ffffffffc0200f34 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200caa:	40f98733          	sub	a4,s3,a5
ffffffffc0200cae:	8719                	srai	a4,a4,0x6
ffffffffc0200cb0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cb2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cb4:	4cd77063          	bgeu	a4,a3,ffffffffc0201174 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200cb8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200cbc:	8799                	srai	a5,a5,0x6
ffffffffc0200cbe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cc0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cc2:	30d7f963          	bgeu	a5,a3,ffffffffc0200fd4 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200cc6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cc8:	00043c03          	ld	s8,0(s0)
ffffffffc0200ccc:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200cd0:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200cd4:	e400                	sd	s0,8(s0)
ffffffffc0200cd6:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200cd8:	00011797          	auipc	a5,0x11
ffffffffc0200cdc:	7807ac23          	sw	zero,1944(a5) # ffffffffc0212470 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200ce0:	5b1000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200ce4:	2c051863          	bnez	a0,ffffffffc0200fb4 <default_check+0x3c2>
    free_page(p0);
ffffffffc0200ce8:	4585                	li	a1,1
ffffffffc0200cea:	8556                	mv	a0,s5
ffffffffc0200cec:	637000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    free_page(p1);
ffffffffc0200cf0:	4585                	li	a1,1
ffffffffc0200cf2:	854e                	mv	a0,s3
ffffffffc0200cf4:	62f000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    free_page(p2);
ffffffffc0200cf8:	4585                	li	a1,1
ffffffffc0200cfa:	8552                	mv	a0,s4
ffffffffc0200cfc:	627000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    assert(nr_free == 3);
ffffffffc0200d00:	4818                	lw	a4,16(s0)
ffffffffc0200d02:	478d                	li	a5,3
ffffffffc0200d04:	28f71863          	bne	a4,a5,ffffffffc0200f94 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d08:	4505                	li	a0,1
ffffffffc0200d0a:	587000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200d0e:	89aa                	mv	s3,a0
ffffffffc0200d10:	26050263          	beqz	a0,ffffffffc0200f74 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d14:	4505                	li	a0,1
ffffffffc0200d16:	57b000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200d1a:	8aaa                	mv	s5,a0
ffffffffc0200d1c:	3a050c63          	beqz	a0,ffffffffc02010d4 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d20:	4505                	li	a0,1
ffffffffc0200d22:	56f000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200d26:	8a2a                	mv	s4,a0
ffffffffc0200d28:	38050663          	beqz	a0,ffffffffc02010b4 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200d2c:	4505                	li	a0,1
ffffffffc0200d2e:	563000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200d32:	36051163          	bnez	a0,ffffffffc0201094 <default_check+0x4a2>
    free_page(p0);
ffffffffc0200d36:	4585                	li	a1,1
ffffffffc0200d38:	854e                	mv	a0,s3
ffffffffc0200d3a:	5e9000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d3e:	641c                	ld	a5,8(s0)
ffffffffc0200d40:	20878a63          	beq	a5,s0,ffffffffc0200f54 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200d44:	4505                	li	a0,1
ffffffffc0200d46:	54b000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200d4a:	30a99563          	bne	s3,a0,ffffffffc0201054 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200d4e:	4505                	li	a0,1
ffffffffc0200d50:	541000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200d54:	2e051063          	bnez	a0,ffffffffc0201034 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200d58:	481c                	lw	a5,16(s0)
ffffffffc0200d5a:	2a079d63          	bnez	a5,ffffffffc0201014 <default_check+0x422>
    free_page(p);
ffffffffc0200d5e:	854e                	mv	a0,s3
ffffffffc0200d60:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d62:	01843023          	sd	s8,0(s0)
ffffffffc0200d66:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200d6a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200d6e:	5b5000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    free_page(p1);
ffffffffc0200d72:	4585                	li	a1,1
ffffffffc0200d74:	8556                	mv	a0,s5
ffffffffc0200d76:	5ad000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    free_page(p2);
ffffffffc0200d7a:	4585                	li	a1,1
ffffffffc0200d7c:	8552                	mv	a0,s4
ffffffffc0200d7e:	5a5000ef          	jal	ra,ffffffffc0201b22 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d82:	4515                	li	a0,5
ffffffffc0200d84:	50d000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200d88:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d8a:	26050563          	beqz	a0,ffffffffc0200ff4 <default_check+0x402>
ffffffffc0200d8e:	651c                	ld	a5,8(a0)
ffffffffc0200d90:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d92:	8b85                	andi	a5,a5,1
ffffffffc0200d94:	54079063          	bnez	a5,ffffffffc02012d4 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d98:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d9a:	00043b03          	ld	s6,0(s0)
ffffffffc0200d9e:	00843a83          	ld	s5,8(s0)
ffffffffc0200da2:	e000                	sd	s0,0(s0)
ffffffffc0200da4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200da6:	4eb000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200daa:	50051563          	bnez	a0,ffffffffc02012b4 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200dae:	08098a13          	addi	s4,s3,128
ffffffffc0200db2:	8552                	mv	a0,s4
ffffffffc0200db4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200db6:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200dba:	00011797          	auipc	a5,0x11
ffffffffc0200dbe:	6a07ab23          	sw	zero,1718(a5) # ffffffffc0212470 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200dc2:	561000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dc6:	4511                	li	a0,4
ffffffffc0200dc8:	4c9000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200dcc:	4c051463          	bnez	a0,ffffffffc0201294 <default_check+0x6a2>
ffffffffc0200dd0:	0889b783          	ld	a5,136(s3)
ffffffffc0200dd4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200dd6:	8b85                	andi	a5,a5,1
ffffffffc0200dd8:	48078e63          	beqz	a5,ffffffffc0201274 <default_check+0x682>
ffffffffc0200ddc:	0909a703          	lw	a4,144(s3)
ffffffffc0200de0:	478d                	li	a5,3
ffffffffc0200de2:	48f71963          	bne	a4,a5,ffffffffc0201274 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200de6:	450d                	li	a0,3
ffffffffc0200de8:	4a9000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200dec:	8c2a                	mv	s8,a0
ffffffffc0200dee:	46050363          	beqz	a0,ffffffffc0201254 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0200df2:	4505                	li	a0,1
ffffffffc0200df4:	49d000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200df8:	42051e63          	bnez	a0,ffffffffc0201234 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0200dfc:	418a1c63          	bne	s4,s8,ffffffffc0201214 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200e00:	4585                	li	a1,1
ffffffffc0200e02:	854e                	mv	a0,s3
ffffffffc0200e04:	51f000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    free_pages(p1, 3);
ffffffffc0200e08:	458d                	li	a1,3
ffffffffc0200e0a:	8552                	mv	a0,s4
ffffffffc0200e0c:	517000ef          	jal	ra,ffffffffc0201b22 <free_pages>
ffffffffc0200e10:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200e14:	04098c13          	addi	s8,s3,64
ffffffffc0200e18:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e1a:	8b85                	andi	a5,a5,1
ffffffffc0200e1c:	3c078c63          	beqz	a5,ffffffffc02011f4 <default_check+0x602>
ffffffffc0200e20:	0109a703          	lw	a4,16(s3)
ffffffffc0200e24:	4785                	li	a5,1
ffffffffc0200e26:	3cf71763          	bne	a4,a5,ffffffffc02011f4 <default_check+0x602>
ffffffffc0200e2a:	008a3783          	ld	a5,8(s4)
ffffffffc0200e2e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e30:	8b85                	andi	a5,a5,1
ffffffffc0200e32:	3a078163          	beqz	a5,ffffffffc02011d4 <default_check+0x5e2>
ffffffffc0200e36:	010a2703          	lw	a4,16(s4)
ffffffffc0200e3a:	478d                	li	a5,3
ffffffffc0200e3c:	38f71c63          	bne	a4,a5,ffffffffc02011d4 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e40:	4505                	li	a0,1
ffffffffc0200e42:	44f000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200e46:	36a99763          	bne	s3,a0,ffffffffc02011b4 <default_check+0x5c2>
    free_page(p0);
ffffffffc0200e4a:	4585                	li	a1,1
ffffffffc0200e4c:	4d7000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e50:	4509                	li	a0,2
ffffffffc0200e52:	43f000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200e56:	32aa1f63          	bne	s4,a0,ffffffffc0201194 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0200e5a:	4589                	li	a1,2
ffffffffc0200e5c:	4c7000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    free_page(p2);
ffffffffc0200e60:	4585                	li	a1,1
ffffffffc0200e62:	8562                	mv	a0,s8
ffffffffc0200e64:	4bf000ef          	jal	ra,ffffffffc0201b22 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e68:	4515                	li	a0,5
ffffffffc0200e6a:	427000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200e6e:	89aa                	mv	s3,a0
ffffffffc0200e70:	48050263          	beqz	a0,ffffffffc02012f4 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0200e74:	4505                	li	a0,1
ffffffffc0200e76:	41b000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0200e7a:	2c051d63          	bnez	a0,ffffffffc0201154 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0200e7e:	481c                	lw	a5,16(s0)
ffffffffc0200e80:	2a079a63          	bnez	a5,ffffffffc0201134 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e84:	4595                	li	a1,5
ffffffffc0200e86:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e88:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200e8c:	01643023          	sd	s6,0(s0)
ffffffffc0200e90:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200e94:	48f000ef          	jal	ra,ffffffffc0201b22 <free_pages>
    return listelm->next;
ffffffffc0200e98:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9a:	00878963          	beq	a5,s0,ffffffffc0200eac <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e9e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ea2:	679c                	ld	a5,8(a5)
ffffffffc0200ea4:	397d                	addiw	s2,s2,-1
ffffffffc0200ea6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ea8:	fe879be3          	bne	a5,s0,ffffffffc0200e9e <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0200eac:	26091463          	bnez	s2,ffffffffc0201114 <default_check+0x522>
    assert(total == 0);
ffffffffc0200eb0:	46049263          	bnez	s1,ffffffffc0201314 <default_check+0x722>
}
ffffffffc0200eb4:	60a6                	ld	ra,72(sp)
ffffffffc0200eb6:	6406                	ld	s0,64(sp)
ffffffffc0200eb8:	74e2                	ld	s1,56(sp)
ffffffffc0200eba:	7942                	ld	s2,48(sp)
ffffffffc0200ebc:	79a2                	ld	s3,40(sp)
ffffffffc0200ebe:	7a02                	ld	s4,32(sp)
ffffffffc0200ec0:	6ae2                	ld	s5,24(sp)
ffffffffc0200ec2:	6b42                	ld	s6,16(sp)
ffffffffc0200ec4:	6ba2                	ld	s7,8(sp)
ffffffffc0200ec6:	6c02                	ld	s8,0(sp)
ffffffffc0200ec8:	6161                	addi	sp,sp,80
ffffffffc0200eca:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ecc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ece:	4481                	li	s1,0
ffffffffc0200ed0:	4901                	li	s2,0
ffffffffc0200ed2:	b38d                	j	ffffffffc0200c34 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200ed4:	00005697          	auipc	a3,0x5
ffffffffc0200ed8:	ad468693          	addi	a3,a3,-1324 # ffffffffc02059a8 <commands+0x788>
ffffffffc0200edc:	00005617          	auipc	a2,0x5
ffffffffc0200ee0:	adc60613          	addi	a2,a2,-1316 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200ee4:	0f000593          	li	a1,240
ffffffffc0200ee8:	00005517          	auipc	a0,0x5
ffffffffc0200eec:	ae850513          	addi	a0,a0,-1304 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200ef0:	d56ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ef4:	00005697          	auipc	a3,0x5
ffffffffc0200ef8:	b7468693          	addi	a3,a3,-1164 # ffffffffc0205a68 <commands+0x848>
ffffffffc0200efc:	00005617          	auipc	a2,0x5
ffffffffc0200f00:	abc60613          	addi	a2,a2,-1348 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200f04:	0bd00593          	li	a1,189
ffffffffc0200f08:	00005517          	auipc	a0,0x5
ffffffffc0200f0c:	ac850513          	addi	a0,a0,-1336 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200f10:	d36ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f14:	00005697          	auipc	a3,0x5
ffffffffc0200f18:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205a90 <commands+0x870>
ffffffffc0200f1c:	00005617          	auipc	a2,0x5
ffffffffc0200f20:	a9c60613          	addi	a2,a2,-1380 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200f24:	0be00593          	li	a1,190
ffffffffc0200f28:	00005517          	auipc	a0,0x5
ffffffffc0200f2c:	aa850513          	addi	a0,a0,-1368 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200f30:	d16ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f34:	00005697          	auipc	a3,0x5
ffffffffc0200f38:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205ad0 <commands+0x8b0>
ffffffffc0200f3c:	00005617          	auipc	a2,0x5
ffffffffc0200f40:	a7c60613          	addi	a2,a2,-1412 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200f44:	0c000593          	li	a1,192
ffffffffc0200f48:	00005517          	auipc	a0,0x5
ffffffffc0200f4c:	a8850513          	addi	a0,a0,-1400 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200f50:	cf6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f54:	00005697          	auipc	a3,0x5
ffffffffc0200f58:	c0468693          	addi	a3,a3,-1020 # ffffffffc0205b58 <commands+0x938>
ffffffffc0200f5c:	00005617          	auipc	a2,0x5
ffffffffc0200f60:	a5c60613          	addi	a2,a2,-1444 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200f64:	0d900593          	li	a1,217
ffffffffc0200f68:	00005517          	auipc	a0,0x5
ffffffffc0200f6c:	a6850513          	addi	a0,a0,-1432 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200f70:	cd6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f74:	00005697          	auipc	a3,0x5
ffffffffc0200f78:	a9468693          	addi	a3,a3,-1388 # ffffffffc0205a08 <commands+0x7e8>
ffffffffc0200f7c:	00005617          	auipc	a2,0x5
ffffffffc0200f80:	a3c60613          	addi	a2,a2,-1476 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200f84:	0d200593          	li	a1,210
ffffffffc0200f88:	00005517          	auipc	a0,0x5
ffffffffc0200f8c:	a4850513          	addi	a0,a0,-1464 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200f90:	cb6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 3);
ffffffffc0200f94:	00005697          	auipc	a3,0x5
ffffffffc0200f98:	bb468693          	addi	a3,a3,-1100 # ffffffffc0205b48 <commands+0x928>
ffffffffc0200f9c:	00005617          	auipc	a2,0x5
ffffffffc0200fa0:	a1c60613          	addi	a2,a2,-1508 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200fa4:	0d000593          	li	a1,208
ffffffffc0200fa8:	00005517          	auipc	a0,0x5
ffffffffc0200fac:	a2850513          	addi	a0,a0,-1496 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200fb0:	c96ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb4:	00005697          	auipc	a3,0x5
ffffffffc0200fb8:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205b30 <commands+0x910>
ffffffffc0200fbc:	00005617          	auipc	a2,0x5
ffffffffc0200fc0:	9fc60613          	addi	a2,a2,-1540 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200fc4:	0cb00593          	li	a1,203
ffffffffc0200fc8:	00005517          	auipc	a0,0x5
ffffffffc0200fcc:	a0850513          	addi	a0,a0,-1528 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200fd0:	c76ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fd4:	00005697          	auipc	a3,0x5
ffffffffc0200fd8:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0205b10 <commands+0x8f0>
ffffffffc0200fdc:	00005617          	auipc	a2,0x5
ffffffffc0200fe0:	9dc60613          	addi	a2,a2,-1572 # ffffffffc02059b8 <commands+0x798>
ffffffffc0200fe4:	0c200593          	li	a1,194
ffffffffc0200fe8:	00005517          	auipc	a0,0x5
ffffffffc0200fec:	9e850513          	addi	a0,a0,-1560 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0200ff0:	c56ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc0200ff4:	00005697          	auipc	a3,0x5
ffffffffc0200ff8:	bac68693          	addi	a3,a3,-1108 # ffffffffc0205ba0 <commands+0x980>
ffffffffc0200ffc:	00005617          	auipc	a2,0x5
ffffffffc0201000:	9bc60613          	addi	a2,a2,-1604 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201004:	0f800593          	li	a1,248
ffffffffc0201008:	00005517          	auipc	a0,0x5
ffffffffc020100c:	9c850513          	addi	a0,a0,-1592 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201010:	c36ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc0201014:	00005697          	auipc	a3,0x5
ffffffffc0201018:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205b90 <commands+0x970>
ffffffffc020101c:	00005617          	auipc	a2,0x5
ffffffffc0201020:	99c60613          	addi	a2,a2,-1636 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201024:	0df00593          	li	a1,223
ffffffffc0201028:	00005517          	auipc	a0,0x5
ffffffffc020102c:	9a850513          	addi	a0,a0,-1624 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201030:	c16ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201034:	00005697          	auipc	a3,0x5
ffffffffc0201038:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205b30 <commands+0x910>
ffffffffc020103c:	00005617          	auipc	a2,0x5
ffffffffc0201040:	97c60613          	addi	a2,a2,-1668 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201044:	0dd00593          	li	a1,221
ffffffffc0201048:	00005517          	auipc	a0,0x5
ffffffffc020104c:	98850513          	addi	a0,a0,-1656 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201050:	bf6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201054:	00005697          	auipc	a3,0x5
ffffffffc0201058:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0205b70 <commands+0x950>
ffffffffc020105c:	00005617          	auipc	a2,0x5
ffffffffc0201060:	95c60613          	addi	a2,a2,-1700 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201064:	0dc00593          	li	a1,220
ffffffffc0201068:	00005517          	auipc	a0,0x5
ffffffffc020106c:	96850513          	addi	a0,a0,-1688 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201070:	bd6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201074:	00005697          	auipc	a3,0x5
ffffffffc0201078:	99468693          	addi	a3,a3,-1644 # ffffffffc0205a08 <commands+0x7e8>
ffffffffc020107c:	00005617          	auipc	a2,0x5
ffffffffc0201080:	93c60613          	addi	a2,a2,-1732 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201084:	0b900593          	li	a1,185
ffffffffc0201088:	00005517          	auipc	a0,0x5
ffffffffc020108c:	94850513          	addi	a0,a0,-1720 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201090:	bb6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201094:	00005697          	auipc	a3,0x5
ffffffffc0201098:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0205b30 <commands+0x910>
ffffffffc020109c:	00005617          	auipc	a2,0x5
ffffffffc02010a0:	91c60613          	addi	a2,a2,-1764 # ffffffffc02059b8 <commands+0x798>
ffffffffc02010a4:	0d600593          	li	a1,214
ffffffffc02010a8:	00005517          	auipc	a0,0x5
ffffffffc02010ac:	92850513          	addi	a0,a0,-1752 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02010b0:	b96ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010b4:	00005697          	auipc	a3,0x5
ffffffffc02010b8:	99468693          	addi	a3,a3,-1644 # ffffffffc0205a48 <commands+0x828>
ffffffffc02010bc:	00005617          	auipc	a2,0x5
ffffffffc02010c0:	8fc60613          	addi	a2,a2,-1796 # ffffffffc02059b8 <commands+0x798>
ffffffffc02010c4:	0d400593          	li	a1,212
ffffffffc02010c8:	00005517          	auipc	a0,0x5
ffffffffc02010cc:	90850513          	addi	a0,a0,-1784 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02010d0:	b76ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010d4:	00005697          	auipc	a3,0x5
ffffffffc02010d8:	95468693          	addi	a3,a3,-1708 # ffffffffc0205a28 <commands+0x808>
ffffffffc02010dc:	00005617          	auipc	a2,0x5
ffffffffc02010e0:	8dc60613          	addi	a2,a2,-1828 # ffffffffc02059b8 <commands+0x798>
ffffffffc02010e4:	0d300593          	li	a1,211
ffffffffc02010e8:	00005517          	auipc	a0,0x5
ffffffffc02010ec:	8e850513          	addi	a0,a0,-1816 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02010f0:	b56ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010f4:	00005697          	auipc	a3,0x5
ffffffffc02010f8:	95468693          	addi	a3,a3,-1708 # ffffffffc0205a48 <commands+0x828>
ffffffffc02010fc:	00005617          	auipc	a2,0x5
ffffffffc0201100:	8bc60613          	addi	a2,a2,-1860 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201104:	0bb00593          	li	a1,187
ffffffffc0201108:	00005517          	auipc	a0,0x5
ffffffffc020110c:	8c850513          	addi	a0,a0,-1848 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201110:	b36ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(count == 0);
ffffffffc0201114:	00005697          	auipc	a3,0x5
ffffffffc0201118:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0205cf0 <commands+0xad0>
ffffffffc020111c:	00005617          	auipc	a2,0x5
ffffffffc0201120:	89c60613          	addi	a2,a2,-1892 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201124:	12500593          	li	a1,293
ffffffffc0201128:	00005517          	auipc	a0,0x5
ffffffffc020112c:	8a850513          	addi	a0,a0,-1880 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201130:	b16ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc0201134:	00005697          	auipc	a3,0x5
ffffffffc0201138:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0205b90 <commands+0x970>
ffffffffc020113c:	00005617          	auipc	a2,0x5
ffffffffc0201140:	87c60613          	addi	a2,a2,-1924 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201144:	11a00593          	li	a1,282
ffffffffc0201148:	00005517          	auipc	a0,0x5
ffffffffc020114c:	88850513          	addi	a0,a0,-1912 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201150:	af6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201154:	00005697          	auipc	a3,0x5
ffffffffc0201158:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0205b30 <commands+0x910>
ffffffffc020115c:	00005617          	auipc	a2,0x5
ffffffffc0201160:	85c60613          	addi	a2,a2,-1956 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201164:	11800593          	li	a1,280
ffffffffc0201168:	00005517          	auipc	a0,0x5
ffffffffc020116c:	86850513          	addi	a0,a0,-1944 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201170:	ad6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201174:	00005697          	auipc	a3,0x5
ffffffffc0201178:	97c68693          	addi	a3,a3,-1668 # ffffffffc0205af0 <commands+0x8d0>
ffffffffc020117c:	00005617          	auipc	a2,0x5
ffffffffc0201180:	83c60613          	addi	a2,a2,-1988 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201184:	0c100593          	li	a1,193
ffffffffc0201188:	00005517          	auipc	a0,0x5
ffffffffc020118c:	84850513          	addi	a0,a0,-1976 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201190:	ab6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201194:	00005697          	auipc	a3,0x5
ffffffffc0201198:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0205cb0 <commands+0xa90>
ffffffffc020119c:	00005617          	auipc	a2,0x5
ffffffffc02011a0:	81c60613          	addi	a2,a2,-2020 # ffffffffc02059b8 <commands+0x798>
ffffffffc02011a4:	11200593          	li	a1,274
ffffffffc02011a8:	00005517          	auipc	a0,0x5
ffffffffc02011ac:	82850513          	addi	a0,a0,-2008 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02011b0:	a96ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011b4:	00005697          	auipc	a3,0x5
ffffffffc02011b8:	adc68693          	addi	a3,a3,-1316 # ffffffffc0205c90 <commands+0xa70>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	7fc60613          	addi	a2,a2,2044 # ffffffffc02059b8 <commands+0x798>
ffffffffc02011c4:	11000593          	li	a1,272
ffffffffc02011c8:	00005517          	auipc	a0,0x5
ffffffffc02011cc:	80850513          	addi	a0,a0,-2040 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02011d0:	a76ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011d4:	00005697          	auipc	a3,0x5
ffffffffc02011d8:	a9468693          	addi	a3,a3,-1388 # ffffffffc0205c68 <commands+0xa48>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	7dc60613          	addi	a2,a2,2012 # ffffffffc02059b8 <commands+0x798>
ffffffffc02011e4:	10e00593          	li	a1,270
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	7e850513          	addi	a0,a0,2024 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02011f0:	a56ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011f4:	00005697          	auipc	a3,0x5
ffffffffc02011f8:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0205c40 <commands+0xa20>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	7bc60613          	addi	a2,a2,1980 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201204:	10d00593          	li	a1,269
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	7c850513          	addi	a0,a0,1992 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201210:	a36ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201214:	00005697          	auipc	a3,0x5
ffffffffc0201218:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0205c30 <commands+0xa10>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	79c60613          	addi	a2,a2,1948 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201224:	10800593          	li	a1,264
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	7a850513          	addi	a0,a0,1960 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201230:	a16ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201234:	00005697          	auipc	a3,0x5
ffffffffc0201238:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0205b30 <commands+0x910>
ffffffffc020123c:	00004617          	auipc	a2,0x4
ffffffffc0201240:	77c60613          	addi	a2,a2,1916 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201244:	10700593          	li	a1,263
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	78850513          	addi	a0,a0,1928 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201250:	9f6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201254:	00005697          	auipc	a3,0x5
ffffffffc0201258:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0205c10 <commands+0x9f0>
ffffffffc020125c:	00004617          	auipc	a2,0x4
ffffffffc0201260:	75c60613          	addi	a2,a2,1884 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201264:	10600593          	li	a1,262
ffffffffc0201268:	00004517          	auipc	a0,0x4
ffffffffc020126c:	76850513          	addi	a0,a0,1896 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201270:	9d6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201274:	00005697          	auipc	a3,0x5
ffffffffc0201278:	96c68693          	addi	a3,a3,-1684 # ffffffffc0205be0 <commands+0x9c0>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	73c60613          	addi	a2,a2,1852 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201284:	10500593          	li	a1,261
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	74850513          	addi	a0,a0,1864 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201290:	9b6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201294:	00005697          	auipc	a3,0x5
ffffffffc0201298:	93468693          	addi	a3,a3,-1740 # ffffffffc0205bc8 <commands+0x9a8>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	71c60613          	addi	a2,a2,1820 # ffffffffc02059b8 <commands+0x798>
ffffffffc02012a4:	10400593          	li	a1,260
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	72850513          	addi	a0,a0,1832 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02012b0:	996ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012b4:	00005697          	auipc	a3,0x5
ffffffffc02012b8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0205b30 <commands+0x910>
ffffffffc02012bc:	00004617          	auipc	a2,0x4
ffffffffc02012c0:	6fc60613          	addi	a2,a2,1788 # ffffffffc02059b8 <commands+0x798>
ffffffffc02012c4:	0fe00593          	li	a1,254
ffffffffc02012c8:	00004517          	auipc	a0,0x4
ffffffffc02012cc:	70850513          	addi	a0,a0,1800 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02012d0:	976ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012d4:	00005697          	auipc	a3,0x5
ffffffffc02012d8:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0205bb0 <commands+0x990>
ffffffffc02012dc:	00004617          	auipc	a2,0x4
ffffffffc02012e0:	6dc60613          	addi	a2,a2,1756 # ffffffffc02059b8 <commands+0x798>
ffffffffc02012e4:	0f900593          	li	a1,249
ffffffffc02012e8:	00004517          	auipc	a0,0x4
ffffffffc02012ec:	6e850513          	addi	a0,a0,1768 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02012f0:	956ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012f4:	00005697          	auipc	a3,0x5
ffffffffc02012f8:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0205cd0 <commands+0xab0>
ffffffffc02012fc:	00004617          	auipc	a2,0x4
ffffffffc0201300:	6bc60613          	addi	a2,a2,1724 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201304:	11700593          	li	a1,279
ffffffffc0201308:	00004517          	auipc	a0,0x4
ffffffffc020130c:	6c850513          	addi	a0,a0,1736 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201310:	936ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == 0);
ffffffffc0201314:	00005697          	auipc	a3,0x5
ffffffffc0201318:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0205d00 <commands+0xae0>
ffffffffc020131c:	00004617          	auipc	a2,0x4
ffffffffc0201320:	69c60613          	addi	a2,a2,1692 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201324:	12600593          	li	a1,294
ffffffffc0201328:	00004517          	auipc	a0,0x4
ffffffffc020132c:	6a850513          	addi	a0,a0,1704 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201330:	916ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201334:	00004697          	auipc	a3,0x4
ffffffffc0201338:	6b468693          	addi	a3,a3,1716 # ffffffffc02059e8 <commands+0x7c8>
ffffffffc020133c:	00004617          	auipc	a2,0x4
ffffffffc0201340:	67c60613          	addi	a2,a2,1660 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201344:	0f300593          	li	a1,243
ffffffffc0201348:	00004517          	auipc	a0,0x4
ffffffffc020134c:	68850513          	addi	a0,a0,1672 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201350:	8f6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201354:	00004697          	auipc	a3,0x4
ffffffffc0201358:	6d468693          	addi	a3,a3,1748 # ffffffffc0205a28 <commands+0x808>
ffffffffc020135c:	00004617          	auipc	a2,0x4
ffffffffc0201360:	65c60613          	addi	a2,a2,1628 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201364:	0ba00593          	li	a1,186
ffffffffc0201368:	00004517          	auipc	a0,0x4
ffffffffc020136c:	66850513          	addi	a0,a0,1640 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201370:	8d6ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201374 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201374:	1141                	addi	sp,sp,-16
ffffffffc0201376:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201378:	14058463          	beqz	a1,ffffffffc02014c0 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc020137c:	00659693          	slli	a3,a1,0x6
ffffffffc0201380:	96aa                	add	a3,a3,a0
ffffffffc0201382:	87aa                	mv	a5,a0
ffffffffc0201384:	02d50263          	beq	a0,a3,ffffffffc02013a8 <default_free_pages+0x34>
ffffffffc0201388:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020138a:	8b05                	andi	a4,a4,1
ffffffffc020138c:	10071a63          	bnez	a4,ffffffffc02014a0 <default_free_pages+0x12c>
ffffffffc0201390:	6798                	ld	a4,8(a5)
ffffffffc0201392:	8b09                	andi	a4,a4,2
ffffffffc0201394:	10071663          	bnez	a4,ffffffffc02014a0 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201398:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc020139c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02013a0:	04078793          	addi	a5,a5,64
ffffffffc02013a4:	fed792e3          	bne	a5,a3,ffffffffc0201388 <default_free_pages+0x14>
    base->property = n;
ffffffffc02013a8:	2581                	sext.w	a1,a1
ffffffffc02013aa:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02013ac:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013b0:	4789                	li	a5,2
ffffffffc02013b2:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02013b6:	00011697          	auipc	a3,0x11
ffffffffc02013ba:	0aa68693          	addi	a3,a3,170 # ffffffffc0212460 <free_area>
ffffffffc02013be:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013c0:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02013c2:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02013c6:	9db9                	addw	a1,a1,a4
ffffffffc02013c8:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02013ca:	0ad78463          	beq	a5,a3,ffffffffc0201472 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02013ce:	fe878713          	addi	a4,a5,-24
ffffffffc02013d2:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013d6:	4581                	li	a1,0
            if (base < page) {
ffffffffc02013d8:	00e56a63          	bltu	a0,a4,ffffffffc02013ec <default_free_pages+0x78>
    return listelm->next;
ffffffffc02013dc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013de:	04d70c63          	beq	a4,a3,ffffffffc0201436 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02013e2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013e4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02013e8:	fee57ae3          	bgeu	a0,a4,ffffffffc02013dc <default_free_pages+0x68>
ffffffffc02013ec:	c199                	beqz	a1,ffffffffc02013f2 <default_free_pages+0x7e>
ffffffffc02013ee:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013f2:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013f4:	e390                	sd	a2,0(a5)
ffffffffc02013f6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02013f8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013fa:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02013fc:	00d70d63          	beq	a4,a3,ffffffffc0201416 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201400:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201404:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201408:	02059813          	slli	a6,a1,0x20
ffffffffc020140c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201410:	97b2                	add	a5,a5,a2
ffffffffc0201412:	02f50c63          	beq	a0,a5,ffffffffc020144a <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201416:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201418:	00d78c63          	beq	a5,a3,ffffffffc0201430 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc020141c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020141e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201422:	02061593          	slli	a1,a2,0x20
ffffffffc0201426:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020142a:	972a                	add	a4,a4,a0
ffffffffc020142c:	04e68a63          	beq	a3,a4,ffffffffc0201480 <default_free_pages+0x10c>
}
ffffffffc0201430:	60a2                	ld	ra,8(sp)
ffffffffc0201432:	0141                	addi	sp,sp,16
ffffffffc0201434:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201436:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201438:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020143a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020143c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020143e:	02d70763          	beq	a4,a3,ffffffffc020146c <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201442:	8832                	mv	a6,a2
ffffffffc0201444:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201446:	87ba                	mv	a5,a4
ffffffffc0201448:	bf71                	j	ffffffffc02013e4 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020144a:	491c                	lw	a5,16(a0)
ffffffffc020144c:	9dbd                	addw	a1,a1,a5
ffffffffc020144e:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201452:	57f5                	li	a5,-3
ffffffffc0201454:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201458:	01853803          	ld	a6,24(a0)
ffffffffc020145c:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020145e:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201460:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201464:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201466:	0105b023          	sd	a6,0(a1)
ffffffffc020146a:	b77d                	j	ffffffffc0201418 <default_free_pages+0xa4>
ffffffffc020146c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020146e:	873e                	mv	a4,a5
ffffffffc0201470:	bf41                	j	ffffffffc0201400 <default_free_pages+0x8c>
}
ffffffffc0201472:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201474:	e390                	sd	a2,0(a5)
ffffffffc0201476:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201478:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020147a:	ed1c                	sd	a5,24(a0)
ffffffffc020147c:	0141                	addi	sp,sp,16
ffffffffc020147e:	8082                	ret
            base->property += p->property;
ffffffffc0201480:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201484:	ff078693          	addi	a3,a5,-16
ffffffffc0201488:	9e39                	addw	a2,a2,a4
ffffffffc020148a:	c910                	sw	a2,16(a0)
ffffffffc020148c:	5775                	li	a4,-3
ffffffffc020148e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201492:	6398                	ld	a4,0(a5)
ffffffffc0201494:	679c                	ld	a5,8(a5)
}
ffffffffc0201496:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201498:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020149a:	e398                	sd	a4,0(a5)
ffffffffc020149c:	0141                	addi	sp,sp,16
ffffffffc020149e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014a0:	00005697          	auipc	a3,0x5
ffffffffc02014a4:	87868693          	addi	a3,a3,-1928 # ffffffffc0205d18 <commands+0xaf8>
ffffffffc02014a8:	00004617          	auipc	a2,0x4
ffffffffc02014ac:	51060613          	addi	a2,a2,1296 # ffffffffc02059b8 <commands+0x798>
ffffffffc02014b0:	08300593          	li	a1,131
ffffffffc02014b4:	00004517          	auipc	a0,0x4
ffffffffc02014b8:	51c50513          	addi	a0,a0,1308 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02014bc:	f8bfe0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc02014c0:	00005697          	auipc	a3,0x5
ffffffffc02014c4:	85068693          	addi	a3,a3,-1968 # ffffffffc0205d10 <commands+0xaf0>
ffffffffc02014c8:	00004617          	auipc	a2,0x4
ffffffffc02014cc:	4f060613          	addi	a2,a2,1264 # ffffffffc02059b8 <commands+0x798>
ffffffffc02014d0:	08000593          	li	a1,128
ffffffffc02014d4:	00004517          	auipc	a0,0x4
ffffffffc02014d8:	4fc50513          	addi	a0,a0,1276 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc02014dc:	f6bfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02014e0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014e0:	c941                	beqz	a0,ffffffffc0201570 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02014e2:	00011597          	auipc	a1,0x11
ffffffffc02014e6:	f7e58593          	addi	a1,a1,-130 # ffffffffc0212460 <free_area>
ffffffffc02014ea:	0105a803          	lw	a6,16(a1)
ffffffffc02014ee:	872a                	mv	a4,a0
ffffffffc02014f0:	02081793          	slli	a5,a6,0x20
ffffffffc02014f4:	9381                	srli	a5,a5,0x20
ffffffffc02014f6:	00a7ee63          	bltu	a5,a0,ffffffffc0201512 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014fa:	87ae                	mv	a5,a1
ffffffffc02014fc:	a801                	j	ffffffffc020150c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014fe:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201502:	02069613          	slli	a2,a3,0x20
ffffffffc0201506:	9201                	srli	a2,a2,0x20
ffffffffc0201508:	00e67763          	bgeu	a2,a4,ffffffffc0201516 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020150c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020150e:	feb798e3          	bne	a5,a1,ffffffffc02014fe <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201512:	4501                	li	a0,0
}
ffffffffc0201514:	8082                	ret
    return listelm->prev;
ffffffffc0201516:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020151a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020151e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201522:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201526:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020152a:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020152e:	02c77863          	bgeu	a4,a2,ffffffffc020155e <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201532:	071a                	slli	a4,a4,0x6
ffffffffc0201534:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201536:	41c686bb          	subw	a3,a3,t3
ffffffffc020153a:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020153c:	00870613          	addi	a2,a4,8
ffffffffc0201540:	4689                	li	a3,2
ffffffffc0201542:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201546:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020154a:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020154e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201552:	e290                	sd	a2,0(a3)
ffffffffc0201554:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201558:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc020155a:	01173c23          	sd	a7,24(a4)
ffffffffc020155e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201562:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201566:	5775                	li	a4,-3
ffffffffc0201568:	17c1                	addi	a5,a5,-16
ffffffffc020156a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020156e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201570:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201572:	00004697          	auipc	a3,0x4
ffffffffc0201576:	79e68693          	addi	a3,a3,1950 # ffffffffc0205d10 <commands+0xaf0>
ffffffffc020157a:	00004617          	auipc	a2,0x4
ffffffffc020157e:	43e60613          	addi	a2,a2,1086 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201582:	06200593          	li	a1,98
ffffffffc0201586:	00004517          	auipc	a0,0x4
ffffffffc020158a:	44a50513          	addi	a0,a0,1098 # ffffffffc02059d0 <commands+0x7b0>
default_alloc_pages(size_t n) {
ffffffffc020158e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201590:	eb7fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201594 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201594:	1141                	addi	sp,sp,-16
ffffffffc0201596:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201598:	c5f1                	beqz	a1,ffffffffc0201664 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc020159a:	00659693          	slli	a3,a1,0x6
ffffffffc020159e:	96aa                	add	a3,a3,a0
ffffffffc02015a0:	87aa                	mv	a5,a0
ffffffffc02015a2:	00d50f63          	beq	a0,a3,ffffffffc02015c0 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015a6:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02015a8:	8b05                	andi	a4,a4,1
ffffffffc02015aa:	cf49                	beqz	a4,ffffffffc0201644 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02015ac:	0007a823          	sw	zero,16(a5)
ffffffffc02015b0:	0007b423          	sd	zero,8(a5)
ffffffffc02015b4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015b8:	04078793          	addi	a5,a5,64
ffffffffc02015bc:	fed795e3          	bne	a5,a3,ffffffffc02015a6 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02015c0:	2581                	sext.w	a1,a1
ffffffffc02015c2:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015c4:	4789                	li	a5,2
ffffffffc02015c6:	00850713          	addi	a4,a0,8
ffffffffc02015ca:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015ce:	00011697          	auipc	a3,0x11
ffffffffc02015d2:	e9268693          	addi	a3,a3,-366 # ffffffffc0212460 <free_area>
ffffffffc02015d6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015d8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02015da:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02015de:	9db9                	addw	a1,a1,a4
ffffffffc02015e0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015e2:	04d78a63          	beq	a5,a3,ffffffffc0201636 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc02015e6:	fe878713          	addi	a4,a5,-24
ffffffffc02015ea:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ee:	4581                	li	a1,0
            if (base < page) {
ffffffffc02015f0:	00e56a63          	bltu	a0,a4,ffffffffc0201604 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02015f4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015f6:	02d70263          	beq	a4,a3,ffffffffc020161a <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc02015fa:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015fc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201600:	fee57ae3          	bgeu	a0,a4,ffffffffc02015f4 <default_init_memmap+0x60>
ffffffffc0201604:	c199                	beqz	a1,ffffffffc020160a <default_init_memmap+0x76>
ffffffffc0201606:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020160a:	6398                	ld	a4,0(a5)
}
ffffffffc020160c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020160e:	e390                	sd	a2,0(a5)
ffffffffc0201610:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201612:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201614:	ed18                	sd	a4,24(a0)
ffffffffc0201616:	0141                	addi	sp,sp,16
ffffffffc0201618:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020161a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020161c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020161e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201620:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201622:	00d70663          	beq	a4,a3,ffffffffc020162e <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201626:	8832                	mv	a6,a2
ffffffffc0201628:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020162a:	87ba                	mv	a5,a4
ffffffffc020162c:	bfc1                	j	ffffffffc02015fc <default_init_memmap+0x68>
}
ffffffffc020162e:	60a2                	ld	ra,8(sp)
ffffffffc0201630:	e290                	sd	a2,0(a3)
ffffffffc0201632:	0141                	addi	sp,sp,16
ffffffffc0201634:	8082                	ret
ffffffffc0201636:	60a2                	ld	ra,8(sp)
ffffffffc0201638:	e390                	sd	a2,0(a5)
ffffffffc020163a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020163c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020163e:	ed1c                	sd	a5,24(a0)
ffffffffc0201640:	0141                	addi	sp,sp,16
ffffffffc0201642:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201644:	00004697          	auipc	a3,0x4
ffffffffc0201648:	6fc68693          	addi	a3,a3,1788 # ffffffffc0205d40 <commands+0xb20>
ffffffffc020164c:	00004617          	auipc	a2,0x4
ffffffffc0201650:	36c60613          	addi	a2,a2,876 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201654:	04900593          	li	a1,73
ffffffffc0201658:	00004517          	auipc	a0,0x4
ffffffffc020165c:	37850513          	addi	a0,a0,888 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201660:	de7fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0201664:	00004697          	auipc	a3,0x4
ffffffffc0201668:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205d10 <commands+0xaf0>
ffffffffc020166c:	00004617          	auipc	a2,0x4
ffffffffc0201670:	34c60613          	addi	a2,a2,844 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201674:	04600593          	li	a1,70
ffffffffc0201678:	00004517          	auipc	a0,0x4
ffffffffc020167c:	35850513          	addi	a0,a0,856 # ffffffffc02059d0 <commands+0x7b0>
ffffffffc0201680:	dc7fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201684 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201684:	c94d                	beqz	a0,ffffffffc0201736 <slob_free+0xb2>
{
ffffffffc0201686:	1141                	addi	sp,sp,-16
ffffffffc0201688:	e022                	sd	s0,0(sp)
ffffffffc020168a:	e406                	sd	ra,8(sp)
ffffffffc020168c:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc020168e:	e9c1                	bnez	a1,ffffffffc020171e <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201690:	100027f3          	csrr	a5,sstatus
ffffffffc0201694:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201696:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201698:	ebd9                	bnez	a5,ffffffffc020172e <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020169a:	0000a617          	auipc	a2,0xa
ffffffffc020169e:	9b660613          	addi	a2,a2,-1610 # ffffffffc020b050 <slobfree>
ffffffffc02016a2:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016a4:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016a6:	679c                	ld	a5,8(a5)
ffffffffc02016a8:	02877a63          	bgeu	a4,s0,ffffffffc02016dc <slob_free+0x58>
ffffffffc02016ac:	00f46463          	bltu	s0,a5,ffffffffc02016b4 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016b0:	fef76ae3          	bltu	a4,a5,ffffffffc02016a4 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02016b4:	400c                	lw	a1,0(s0)
ffffffffc02016b6:	00459693          	slli	a3,a1,0x4
ffffffffc02016ba:	96a2                	add	a3,a3,s0
ffffffffc02016bc:	02d78a63          	beq	a5,a3,ffffffffc02016f0 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02016c0:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02016c2:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02016c4:	00469793          	slli	a5,a3,0x4
ffffffffc02016c8:	97ba                	add	a5,a5,a4
ffffffffc02016ca:	02f40e63          	beq	s0,a5,ffffffffc0201706 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02016ce:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02016d0:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02016d2:	e129                	bnez	a0,ffffffffc0201714 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02016d4:	60a2                	ld	ra,8(sp)
ffffffffc02016d6:	6402                	ld	s0,0(sp)
ffffffffc02016d8:	0141                	addi	sp,sp,16
ffffffffc02016da:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016dc:	fcf764e3          	bltu	a4,a5,ffffffffc02016a4 <slob_free+0x20>
ffffffffc02016e0:	fcf472e3          	bgeu	s0,a5,ffffffffc02016a4 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc02016e4:	400c                	lw	a1,0(s0)
ffffffffc02016e6:	00459693          	slli	a3,a1,0x4
ffffffffc02016ea:	96a2                	add	a3,a3,s0
ffffffffc02016ec:	fcd79ae3          	bne	a5,a3,ffffffffc02016c0 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc02016f0:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02016f2:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02016f4:	9db5                	addw	a1,a1,a3
ffffffffc02016f6:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc02016f8:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02016fa:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02016fc:	00469793          	slli	a5,a3,0x4
ffffffffc0201700:	97ba                	add	a5,a5,a4
ffffffffc0201702:	fcf416e3          	bne	s0,a5,ffffffffc02016ce <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201706:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201708:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020170a:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc020170c:	9ebd                	addw	a3,a3,a5
ffffffffc020170e:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201710:	e70c                	sd	a1,8(a4)
ffffffffc0201712:	d169                	beqz	a0,ffffffffc02016d4 <slob_free+0x50>
}
ffffffffc0201714:	6402                	ld	s0,0(sp)
ffffffffc0201716:	60a2                	ld	ra,8(sp)
ffffffffc0201718:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020171a:	ea3fe06f          	j	ffffffffc02005bc <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020171e:	25bd                	addiw	a1,a1,15
ffffffffc0201720:	8191                	srli	a1,a1,0x4
ffffffffc0201722:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201724:	100027f3          	csrr	a5,sstatus
ffffffffc0201728:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020172a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020172c:	d7bd                	beqz	a5,ffffffffc020169a <slob_free+0x16>
        intr_disable();
ffffffffc020172e:	e95fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0201732:	4505                	li	a0,1
ffffffffc0201734:	b79d                	j	ffffffffc020169a <slob_free+0x16>
ffffffffc0201736:	8082                	ret

ffffffffc0201738 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201738:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020173a:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020173c:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201740:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201742:	34e000ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
  if(!page)
ffffffffc0201746:	c91d                	beqz	a0,ffffffffc020177c <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201748:	00015697          	auipc	a3,0x15
ffffffffc020174c:	e306b683          	ld	a3,-464(a3) # ffffffffc0216578 <pages>
ffffffffc0201750:	8d15                	sub	a0,a0,a3
ffffffffc0201752:	8519                	srai	a0,a0,0x6
ffffffffc0201754:	00006697          	auipc	a3,0x6
ffffffffc0201758:	9d46b683          	ld	a3,-1580(a3) # ffffffffc0207128 <nbase>
ffffffffc020175c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020175e:	00c51793          	slli	a5,a0,0xc
ffffffffc0201762:	83b1                	srli	a5,a5,0xc
ffffffffc0201764:	00015717          	auipc	a4,0x15
ffffffffc0201768:	e0c73703          	ld	a4,-500(a4) # ffffffffc0216570 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020176c:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc020176e:	00e7fa63          	bgeu	a5,a4,ffffffffc0201782 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201772:	00015697          	auipc	a3,0x15
ffffffffc0201776:	e166b683          	ld	a3,-490(a3) # ffffffffc0216588 <va_pa_offset>
ffffffffc020177a:	9536                	add	a0,a0,a3
}
ffffffffc020177c:	60a2                	ld	ra,8(sp)
ffffffffc020177e:	0141                	addi	sp,sp,16
ffffffffc0201780:	8082                	ret
ffffffffc0201782:	86aa                	mv	a3,a0
ffffffffc0201784:	00004617          	auipc	a2,0x4
ffffffffc0201788:	61c60613          	addi	a2,a2,1564 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc020178c:	06900593          	li	a1,105
ffffffffc0201790:	00004517          	auipc	a0,0x4
ffffffffc0201794:	63850513          	addi	a0,a0,1592 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0201798:	caffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020179c <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020179c:	1101                	addi	sp,sp,-32
ffffffffc020179e:	ec06                	sd	ra,24(sp)
ffffffffc02017a0:	e822                	sd	s0,16(sp)
ffffffffc02017a2:	e426                	sd	s1,8(sp)
ffffffffc02017a4:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02017a6:	01050713          	addi	a4,a0,16
ffffffffc02017aa:	6785                	lui	a5,0x1
ffffffffc02017ac:	0cf77363          	bgeu	a4,a5,ffffffffc0201872 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02017b0:	00f50493          	addi	s1,a0,15
ffffffffc02017b4:	8091                	srli	s1,s1,0x4
ffffffffc02017b6:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017b8:	10002673          	csrr	a2,sstatus
ffffffffc02017bc:	8a09                	andi	a2,a2,2
ffffffffc02017be:	e25d                	bnez	a2,ffffffffc0201864 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02017c0:	0000a917          	auipc	s2,0xa
ffffffffc02017c4:	89090913          	addi	s2,s2,-1904 # ffffffffc020b050 <slobfree>
ffffffffc02017c8:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02017cc:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02017ce:	4398                	lw	a4,0(a5)
ffffffffc02017d0:	08975e63          	bge	a4,s1,ffffffffc020186c <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02017d4:	00d78b63          	beq	a5,a3,ffffffffc02017ea <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02017d8:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02017da:	4018                	lw	a4,0(s0)
ffffffffc02017dc:	02975a63          	bge	a4,s1,ffffffffc0201810 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc02017e0:	00093683          	ld	a3,0(s2)
ffffffffc02017e4:	87a2                	mv	a5,s0
ffffffffc02017e6:	fed799e3          	bne	a5,a3,ffffffffc02017d8 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc02017ea:	ee31                	bnez	a2,ffffffffc0201846 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02017ec:	4501                	li	a0,0
ffffffffc02017ee:	f4bff0ef          	jal	ra,ffffffffc0201738 <__slob_get_free_pages.constprop.0>
ffffffffc02017f2:	842a                	mv	s0,a0
			if (!cur)
ffffffffc02017f4:	cd05                	beqz	a0,ffffffffc020182c <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc02017f6:	6585                	lui	a1,0x1
ffffffffc02017f8:	e8dff0ef          	jal	ra,ffffffffc0201684 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017fc:	10002673          	csrr	a2,sstatus
ffffffffc0201800:	8a09                	andi	a2,a2,2
ffffffffc0201802:	ee05                	bnez	a2,ffffffffc020183a <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201804:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201808:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020180a:	4018                	lw	a4,0(s0)
ffffffffc020180c:	fc974ae3          	blt	a4,s1,ffffffffc02017e0 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201810:	04e48763          	beq	s1,a4,ffffffffc020185e <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201814:	00449693          	slli	a3,s1,0x4
ffffffffc0201818:	96a2                	add	a3,a3,s0
ffffffffc020181a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc020181c:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc020181e:	9f05                	subw	a4,a4,s1
ffffffffc0201820:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201822:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201824:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201826:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020182a:	e20d                	bnez	a2,ffffffffc020184c <slob_alloc.constprop.0+0xb0>
}
ffffffffc020182c:	60e2                	ld	ra,24(sp)
ffffffffc020182e:	8522                	mv	a0,s0
ffffffffc0201830:	6442                	ld	s0,16(sp)
ffffffffc0201832:	64a2                	ld	s1,8(sp)
ffffffffc0201834:	6902                	ld	s2,0(sp)
ffffffffc0201836:	6105                	addi	sp,sp,32
ffffffffc0201838:	8082                	ret
        intr_disable();
ffffffffc020183a:	d89fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
			cur = slobfree;
ffffffffc020183e:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201842:	4605                	li	a2,1
ffffffffc0201844:	b7d1                	j	ffffffffc0201808 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201846:	d77fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020184a:	b74d                	j	ffffffffc02017ec <slob_alloc.constprop.0+0x50>
ffffffffc020184c:	d71fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
}
ffffffffc0201850:	60e2                	ld	ra,24(sp)
ffffffffc0201852:	8522                	mv	a0,s0
ffffffffc0201854:	6442                	ld	s0,16(sp)
ffffffffc0201856:	64a2                	ld	s1,8(sp)
ffffffffc0201858:	6902                	ld	s2,0(sp)
ffffffffc020185a:	6105                	addi	sp,sp,32
ffffffffc020185c:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020185e:	6418                	ld	a4,8(s0)
ffffffffc0201860:	e798                	sd	a4,8(a5)
ffffffffc0201862:	b7d1                	j	ffffffffc0201826 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201864:	d5ffe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0201868:	4605                	li	a2,1
ffffffffc020186a:	bf99                	j	ffffffffc02017c0 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020186c:	843e                	mv	s0,a5
ffffffffc020186e:	87b6                	mv	a5,a3
ffffffffc0201870:	b745                	j	ffffffffc0201810 <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201872:	00004697          	auipc	a3,0x4
ffffffffc0201876:	56668693          	addi	a3,a3,1382 # ffffffffc0205dd8 <default_pmm_manager+0x70>
ffffffffc020187a:	00004617          	auipc	a2,0x4
ffffffffc020187e:	13e60613          	addi	a2,a2,318 # ffffffffc02059b8 <commands+0x798>
ffffffffc0201882:	06300593          	li	a1,99
ffffffffc0201886:	00004517          	auipc	a0,0x4
ffffffffc020188a:	57250513          	addi	a0,a0,1394 # ffffffffc0205df8 <default_pmm_manager+0x90>
ffffffffc020188e:	bb9fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201892 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201892:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201894:	00004517          	auipc	a0,0x4
ffffffffc0201898:	57c50513          	addi	a0,a0,1404 # ffffffffc0205e10 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc020189c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc020189e:	8e3fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02018a2:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02018a4:	00004517          	auipc	a0,0x4
ffffffffc02018a8:	58450513          	addi	a0,a0,1412 # ffffffffc0205e28 <default_pmm_manager+0xc0>
}
ffffffffc02018ac:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02018ae:	8d3fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc02018b2 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02018b2:	1101                	addi	sp,sp,-32
ffffffffc02018b4:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02018b6:	6905                	lui	s2,0x1
{
ffffffffc02018b8:	e822                	sd	s0,16(sp)
ffffffffc02018ba:	ec06                	sd	ra,24(sp)
ffffffffc02018bc:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02018be:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc02018c2:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02018c4:	04a7f963          	bgeu	a5,a0,ffffffffc0201916 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02018c8:	4561                	li	a0,24
ffffffffc02018ca:	ed3ff0ef          	jal	ra,ffffffffc020179c <slob_alloc.constprop.0>
ffffffffc02018ce:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02018d0:	c929                	beqz	a0,ffffffffc0201922 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02018d2:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02018d6:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02018d8:	00f95763          	bge	s2,a5,ffffffffc02018e6 <kmalloc+0x34>
ffffffffc02018dc:	6705                	lui	a4,0x1
ffffffffc02018de:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02018e0:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02018e2:	fef74ee3          	blt	a4,a5,ffffffffc02018de <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02018e6:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02018e8:	e51ff0ef          	jal	ra,ffffffffc0201738 <__slob_get_free_pages.constprop.0>
ffffffffc02018ec:	e488                	sd	a0,8(s1)
ffffffffc02018ee:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02018f0:	c525                	beqz	a0,ffffffffc0201958 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018f2:	100027f3          	csrr	a5,sstatus
ffffffffc02018f6:	8b89                	andi	a5,a5,2
ffffffffc02018f8:	ef8d                	bnez	a5,ffffffffc0201932 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc02018fa:	00015797          	auipc	a5,0x15
ffffffffc02018fe:	c5e78793          	addi	a5,a5,-930 # ffffffffc0216558 <bigblocks>
ffffffffc0201902:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201904:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201906:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201908:	60e2                	ld	ra,24(sp)
ffffffffc020190a:	8522                	mv	a0,s0
ffffffffc020190c:	6442                	ld	s0,16(sp)
ffffffffc020190e:	64a2                	ld	s1,8(sp)
ffffffffc0201910:	6902                	ld	s2,0(sp)
ffffffffc0201912:	6105                	addi	sp,sp,32
ffffffffc0201914:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201916:	0541                	addi	a0,a0,16
ffffffffc0201918:	e85ff0ef          	jal	ra,ffffffffc020179c <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc020191c:	01050413          	addi	s0,a0,16
ffffffffc0201920:	f565                	bnez	a0,ffffffffc0201908 <kmalloc+0x56>
ffffffffc0201922:	4401                	li	s0,0
}
ffffffffc0201924:	60e2                	ld	ra,24(sp)
ffffffffc0201926:	8522                	mv	a0,s0
ffffffffc0201928:	6442                	ld	s0,16(sp)
ffffffffc020192a:	64a2                	ld	s1,8(sp)
ffffffffc020192c:	6902                	ld	s2,0(sp)
ffffffffc020192e:	6105                	addi	sp,sp,32
ffffffffc0201930:	8082                	ret
        intr_disable();
ffffffffc0201932:	c91fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201936:	00015797          	auipc	a5,0x15
ffffffffc020193a:	c2278793          	addi	a5,a5,-990 # ffffffffc0216558 <bigblocks>
ffffffffc020193e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201940:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201942:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201944:	c79fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
		return bb->pages;
ffffffffc0201948:	6480                	ld	s0,8(s1)
}
ffffffffc020194a:	60e2                	ld	ra,24(sp)
ffffffffc020194c:	64a2                	ld	s1,8(sp)
ffffffffc020194e:	8522                	mv	a0,s0
ffffffffc0201950:	6442                	ld	s0,16(sp)
ffffffffc0201952:	6902                	ld	s2,0(sp)
ffffffffc0201954:	6105                	addi	sp,sp,32
ffffffffc0201956:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201958:	45e1                	li	a1,24
ffffffffc020195a:	8526                	mv	a0,s1
ffffffffc020195c:	d29ff0ef          	jal	ra,ffffffffc0201684 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201960:	b765                	j	ffffffffc0201908 <kmalloc+0x56>

ffffffffc0201962 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201962:	c169                	beqz	a0,ffffffffc0201a24 <kfree+0xc2>
{
ffffffffc0201964:	1101                	addi	sp,sp,-32
ffffffffc0201966:	e822                	sd	s0,16(sp)
ffffffffc0201968:	ec06                	sd	ra,24(sp)
ffffffffc020196a:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc020196c:	03451793          	slli	a5,a0,0x34
ffffffffc0201970:	842a                	mv	s0,a0
ffffffffc0201972:	e3d9                	bnez	a5,ffffffffc02019f8 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201974:	100027f3          	csrr	a5,sstatus
ffffffffc0201978:	8b89                	andi	a5,a5,2
ffffffffc020197a:	e7d9                	bnez	a5,ffffffffc0201a08 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020197c:	00015797          	auipc	a5,0x15
ffffffffc0201980:	bdc7b783          	ld	a5,-1060(a5) # ffffffffc0216558 <bigblocks>
    return 0;
ffffffffc0201984:	4601                	li	a2,0
ffffffffc0201986:	cbad                	beqz	a5,ffffffffc02019f8 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201988:	00015697          	auipc	a3,0x15
ffffffffc020198c:	bd068693          	addi	a3,a3,-1072 # ffffffffc0216558 <bigblocks>
ffffffffc0201990:	a021                	j	ffffffffc0201998 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201992:	01048693          	addi	a3,s1,16
ffffffffc0201996:	c3a5                	beqz	a5,ffffffffc02019f6 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201998:	6798                	ld	a4,8(a5)
ffffffffc020199a:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc020199c:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc020199e:	fe871ae3          	bne	a4,s0,ffffffffc0201992 <kfree+0x30>
				*last = bb->next;
ffffffffc02019a2:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02019a4:	ee2d                	bnez	a2,ffffffffc0201a1e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc02019a6:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02019aa:	4098                	lw	a4,0(s1)
ffffffffc02019ac:	08f46963          	bltu	s0,a5,ffffffffc0201a3e <kfree+0xdc>
ffffffffc02019b0:	00015697          	auipc	a3,0x15
ffffffffc02019b4:	bd86b683          	ld	a3,-1064(a3) # ffffffffc0216588 <va_pa_offset>
ffffffffc02019b8:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc02019ba:	8031                	srli	s0,s0,0xc
ffffffffc02019bc:	00015797          	auipc	a5,0x15
ffffffffc02019c0:	bb47b783          	ld	a5,-1100(a5) # ffffffffc0216570 <npage>
ffffffffc02019c4:	06f47163          	bgeu	s0,a5,ffffffffc0201a26 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc02019c8:	00005517          	auipc	a0,0x5
ffffffffc02019cc:	76053503          	ld	a0,1888(a0) # ffffffffc0207128 <nbase>
ffffffffc02019d0:	8c09                	sub	s0,s0,a0
ffffffffc02019d2:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02019d4:	00015517          	auipc	a0,0x15
ffffffffc02019d8:	ba453503          	ld	a0,-1116(a0) # ffffffffc0216578 <pages>
ffffffffc02019dc:	4585                	li	a1,1
ffffffffc02019de:	9522                	add	a0,a0,s0
ffffffffc02019e0:	00e595bb          	sllw	a1,a1,a4
ffffffffc02019e4:	13e000ef          	jal	ra,ffffffffc0201b22 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02019e8:	6442                	ld	s0,16(sp)
ffffffffc02019ea:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02019ec:	8526                	mv	a0,s1
}
ffffffffc02019ee:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02019f0:	45e1                	li	a1,24
}
ffffffffc02019f2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02019f4:	b941                	j	ffffffffc0201684 <slob_free>
ffffffffc02019f6:	e20d                	bnez	a2,ffffffffc0201a18 <kfree+0xb6>
ffffffffc02019f8:	ff040513          	addi	a0,s0,-16
}
ffffffffc02019fc:	6442                	ld	s0,16(sp)
ffffffffc02019fe:	60e2                	ld	ra,24(sp)
ffffffffc0201a00:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a02:	4581                	li	a1,0
}
ffffffffc0201a04:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a06:	b9bd                	j	ffffffffc0201684 <slob_free>
        intr_disable();
ffffffffc0201a08:	bbbfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a0c:	00015797          	auipc	a5,0x15
ffffffffc0201a10:	b4c7b783          	ld	a5,-1204(a5) # ffffffffc0216558 <bigblocks>
        return 1;
ffffffffc0201a14:	4605                	li	a2,1
ffffffffc0201a16:	fbad                	bnez	a5,ffffffffc0201988 <kfree+0x26>
        intr_enable();
ffffffffc0201a18:	ba5fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201a1c:	bff1                	j	ffffffffc02019f8 <kfree+0x96>
ffffffffc0201a1e:	b9ffe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201a22:	b751                	j	ffffffffc02019a6 <kfree+0x44>
ffffffffc0201a24:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201a26:	00004617          	auipc	a2,0x4
ffffffffc0201a2a:	44a60613          	addi	a2,a2,1098 # ffffffffc0205e70 <default_pmm_manager+0x108>
ffffffffc0201a2e:	06200593          	li	a1,98
ffffffffc0201a32:	00004517          	auipc	a0,0x4
ffffffffc0201a36:	39650513          	addi	a0,a0,918 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0201a3a:	a0dfe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201a3e:	86a2                	mv	a3,s0
ffffffffc0201a40:	00004617          	auipc	a2,0x4
ffffffffc0201a44:	40860613          	addi	a2,a2,1032 # ffffffffc0205e48 <default_pmm_manager+0xe0>
ffffffffc0201a48:	06e00593          	li	a1,110
ffffffffc0201a4c:	00004517          	auipc	a0,0x4
ffffffffc0201a50:	37c50513          	addi	a0,a0,892 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0201a54:	9f3fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a58 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201a58:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201a5a:	00004617          	auipc	a2,0x4
ffffffffc0201a5e:	41660613          	addi	a2,a2,1046 # ffffffffc0205e70 <default_pmm_manager+0x108>
ffffffffc0201a62:	06200593          	li	a1,98
ffffffffc0201a66:	00004517          	auipc	a0,0x4
ffffffffc0201a6a:	36250513          	addi	a0,a0,866 # ffffffffc0205dc8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201a6e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201a70:	9d7fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a74 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201a74:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201a76:	00004617          	auipc	a2,0x4
ffffffffc0201a7a:	41a60613          	addi	a2,a2,1050 # ffffffffc0205e90 <default_pmm_manager+0x128>
ffffffffc0201a7e:	07400593          	li	a1,116
ffffffffc0201a82:	00004517          	auipc	a0,0x4
ffffffffc0201a86:	34650513          	addi	a0,a0,838 # ffffffffc0205dc8 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201a8a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201a8c:	9bbfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a90 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201a90:	7139                	addi	sp,sp,-64
ffffffffc0201a92:	f426                	sd	s1,40(sp)
ffffffffc0201a94:	f04a                	sd	s2,32(sp)
ffffffffc0201a96:	ec4e                	sd	s3,24(sp)
ffffffffc0201a98:	e852                	sd	s4,16(sp)
ffffffffc0201a9a:	e456                	sd	s5,8(sp)
ffffffffc0201a9c:	e05a                	sd	s6,0(sp)
ffffffffc0201a9e:	fc06                	sd	ra,56(sp)
ffffffffc0201aa0:	f822                	sd	s0,48(sp)
ffffffffc0201aa2:	84aa                	mv	s1,a0
ffffffffc0201aa4:	00015917          	auipc	s2,0x15
ffffffffc0201aa8:	adc90913          	addi	s2,s2,-1316 # ffffffffc0216580 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201aac:	4a05                	li	s4,1
ffffffffc0201aae:	00015a97          	auipc	s5,0x15
ffffffffc0201ab2:	af2a8a93          	addi	s5,s5,-1294 # ffffffffc02165a0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ab6:	0005099b          	sext.w	s3,a0
ffffffffc0201aba:	00015b17          	auipc	s6,0x15
ffffffffc0201abe:	aeeb0b13          	addi	s6,s6,-1298 # ffffffffc02165a8 <check_mm_struct>
ffffffffc0201ac2:	a01d                	j	ffffffffc0201ae8 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201ac4:	00093783          	ld	a5,0(s2)
ffffffffc0201ac8:	6f9c                	ld	a5,24(a5)
ffffffffc0201aca:	9782                	jalr	a5
ffffffffc0201acc:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ace:	4601                	li	a2,0
ffffffffc0201ad0:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ad2:	ec0d                	bnez	s0,ffffffffc0201b0c <alloc_pages+0x7c>
ffffffffc0201ad4:	029a6c63          	bltu	s4,s1,ffffffffc0201b0c <alloc_pages+0x7c>
ffffffffc0201ad8:	000aa783          	lw	a5,0(s5)
ffffffffc0201adc:	2781                	sext.w	a5,a5
ffffffffc0201ade:	c79d                	beqz	a5,ffffffffc0201b0c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ae0:	000b3503          	ld	a0,0(s6)
ffffffffc0201ae4:	037010ef          	jal	ra,ffffffffc020331a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ae8:	100027f3          	csrr	a5,sstatus
ffffffffc0201aec:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201aee:	8526                	mv	a0,s1
ffffffffc0201af0:	dbf1                	beqz	a5,ffffffffc0201ac4 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201af2:	ad1fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201af6:	00093783          	ld	a5,0(s2)
ffffffffc0201afa:	8526                	mv	a0,s1
ffffffffc0201afc:	6f9c                	ld	a5,24(a5)
ffffffffc0201afe:	9782                	jalr	a5
ffffffffc0201b00:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201b02:	abbfe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201b06:	4601                	li	a2,0
ffffffffc0201b08:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201b0a:	d469                	beqz	s0,ffffffffc0201ad4 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201b0c:	70e2                	ld	ra,56(sp)
ffffffffc0201b0e:	8522                	mv	a0,s0
ffffffffc0201b10:	7442                	ld	s0,48(sp)
ffffffffc0201b12:	74a2                	ld	s1,40(sp)
ffffffffc0201b14:	7902                	ld	s2,32(sp)
ffffffffc0201b16:	69e2                	ld	s3,24(sp)
ffffffffc0201b18:	6a42                	ld	s4,16(sp)
ffffffffc0201b1a:	6aa2                	ld	s5,8(sp)
ffffffffc0201b1c:	6b02                	ld	s6,0(sp)
ffffffffc0201b1e:	6121                	addi	sp,sp,64
ffffffffc0201b20:	8082                	ret

ffffffffc0201b22 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b22:	100027f3          	csrr	a5,sstatus
ffffffffc0201b26:	8b89                	andi	a5,a5,2
ffffffffc0201b28:	e799                	bnez	a5,ffffffffc0201b36 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201b2a:	00015797          	auipc	a5,0x15
ffffffffc0201b2e:	a567b783          	ld	a5,-1450(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201b32:	739c                	ld	a5,32(a5)
ffffffffc0201b34:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201b36:	1101                	addi	sp,sp,-32
ffffffffc0201b38:	ec06                	sd	ra,24(sp)
ffffffffc0201b3a:	e822                	sd	s0,16(sp)
ffffffffc0201b3c:	e426                	sd	s1,8(sp)
ffffffffc0201b3e:	842a                	mv	s0,a0
ffffffffc0201b40:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201b42:	a81fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201b46:	00015797          	auipc	a5,0x15
ffffffffc0201b4a:	a3a7b783          	ld	a5,-1478(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201b4e:	739c                	ld	a5,32(a5)
ffffffffc0201b50:	85a6                	mv	a1,s1
ffffffffc0201b52:	8522                	mv	a0,s0
ffffffffc0201b54:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201b56:	6442                	ld	s0,16(sp)
ffffffffc0201b58:	60e2                	ld	ra,24(sp)
ffffffffc0201b5a:	64a2                	ld	s1,8(sp)
ffffffffc0201b5c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201b5e:	a5ffe06f          	j	ffffffffc02005bc <intr_enable>

ffffffffc0201b62 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b62:	100027f3          	csrr	a5,sstatus
ffffffffc0201b66:	8b89                	andi	a5,a5,2
ffffffffc0201b68:	e799                	bnez	a5,ffffffffc0201b76 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201b6a:	00015797          	auipc	a5,0x15
ffffffffc0201b6e:	a167b783          	ld	a5,-1514(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201b72:	779c                	ld	a5,40(a5)
ffffffffc0201b74:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201b76:	1141                	addi	sp,sp,-16
ffffffffc0201b78:	e406                	sd	ra,8(sp)
ffffffffc0201b7a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201b7c:	a47fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201b80:	00015797          	auipc	a5,0x15
ffffffffc0201b84:	a007b783          	ld	a5,-1536(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201b88:	779c                	ld	a5,40(a5)
ffffffffc0201b8a:	9782                	jalr	a5
ffffffffc0201b8c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201b8e:	a2ffe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201b92:	60a2                	ld	ra,8(sp)
ffffffffc0201b94:	8522                	mv	a0,s0
ffffffffc0201b96:	6402                	ld	s0,0(sp)
ffffffffc0201b98:	0141                	addi	sp,sp,16
ffffffffc0201b9a:	8082                	ret

ffffffffc0201b9c <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b9c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201ba0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ba4:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201ba6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ba8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201baa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201bae:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201bb0:	f04a                	sd	s2,32(sp)
ffffffffc0201bb2:	ec4e                	sd	s3,24(sp)
ffffffffc0201bb4:	e852                	sd	s4,16(sp)
ffffffffc0201bb6:	fc06                	sd	ra,56(sp)
ffffffffc0201bb8:	f822                	sd	s0,48(sp)
ffffffffc0201bba:	e456                	sd	s5,8(sp)
ffffffffc0201bbc:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201bbe:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201bc2:	892e                	mv	s2,a1
ffffffffc0201bc4:	89b2                	mv	s3,a2
ffffffffc0201bc6:	00015a17          	auipc	s4,0x15
ffffffffc0201bca:	9aaa0a13          	addi	s4,s4,-1622 # ffffffffc0216570 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201bce:	e7b5                	bnez	a5,ffffffffc0201c3a <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201bd0:	12060b63          	beqz	a2,ffffffffc0201d06 <get_pte+0x16a>
ffffffffc0201bd4:	4505                	li	a0,1
ffffffffc0201bd6:	ebbff0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0201bda:	842a                	mv	s0,a0
ffffffffc0201bdc:	12050563          	beqz	a0,ffffffffc0201d06 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201be0:	00015b17          	auipc	s6,0x15
ffffffffc0201be4:	998b0b13          	addi	s6,s6,-1640 # ffffffffc0216578 <pages>
ffffffffc0201be8:	000b3503          	ld	a0,0(s6)
ffffffffc0201bec:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201bf0:	00015a17          	auipc	s4,0x15
ffffffffc0201bf4:	980a0a13          	addi	s4,s4,-1664 # ffffffffc0216570 <npage>
ffffffffc0201bf8:	40a40533          	sub	a0,s0,a0
ffffffffc0201bfc:	8519                	srai	a0,a0,0x6
ffffffffc0201bfe:	9556                	add	a0,a0,s5
ffffffffc0201c00:	000a3703          	ld	a4,0(s4)
ffffffffc0201c04:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201c08:	4685                	li	a3,1
ffffffffc0201c0a:	c014                	sw	a3,0(s0)
ffffffffc0201c0c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c0e:	0532                	slli	a0,a0,0xc
ffffffffc0201c10:	14e7f263          	bgeu	a5,a4,ffffffffc0201d54 <get_pte+0x1b8>
ffffffffc0201c14:	00015797          	auipc	a5,0x15
ffffffffc0201c18:	9747b783          	ld	a5,-1676(a5) # ffffffffc0216588 <va_pa_offset>
ffffffffc0201c1c:	6605                	lui	a2,0x1
ffffffffc0201c1e:	4581                	li	a1,0
ffffffffc0201c20:	953e                	add	a0,a0,a5
ffffffffc0201c22:	348030ef          	jal	ra,ffffffffc0204f6a <memset>
    return page - pages + nbase;
ffffffffc0201c26:	000b3683          	ld	a3,0(s6)
ffffffffc0201c2a:	40d406b3          	sub	a3,s0,a3
ffffffffc0201c2e:	8699                	srai	a3,a3,0x6
ffffffffc0201c30:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201c32:	06aa                	slli	a3,a3,0xa
ffffffffc0201c34:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201c38:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201c3a:	77fd                	lui	a5,0xfffff
ffffffffc0201c3c:	068a                	slli	a3,a3,0x2
ffffffffc0201c3e:	000a3703          	ld	a4,0(s4)
ffffffffc0201c42:	8efd                	and	a3,a3,a5
ffffffffc0201c44:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201c48:	0ce7f163          	bgeu	a5,a4,ffffffffc0201d0a <get_pte+0x16e>
ffffffffc0201c4c:	00015a97          	auipc	s5,0x15
ffffffffc0201c50:	93ca8a93          	addi	s5,s5,-1732 # ffffffffc0216588 <va_pa_offset>
ffffffffc0201c54:	000ab403          	ld	s0,0(s5)
ffffffffc0201c58:	01595793          	srli	a5,s2,0x15
ffffffffc0201c5c:	1ff7f793          	andi	a5,a5,511
ffffffffc0201c60:	96a2                	add	a3,a3,s0
ffffffffc0201c62:	00379413          	slli	s0,a5,0x3
ffffffffc0201c66:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201c68:	6014                	ld	a3,0(s0)
ffffffffc0201c6a:	0016f793          	andi	a5,a3,1
ffffffffc0201c6e:	e3ad                	bnez	a5,ffffffffc0201cd0 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201c70:	08098b63          	beqz	s3,ffffffffc0201d06 <get_pte+0x16a>
ffffffffc0201c74:	4505                	li	a0,1
ffffffffc0201c76:	e1bff0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0201c7a:	84aa                	mv	s1,a0
ffffffffc0201c7c:	c549                	beqz	a0,ffffffffc0201d06 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201c7e:	00015b17          	auipc	s6,0x15
ffffffffc0201c82:	8fab0b13          	addi	s6,s6,-1798 # ffffffffc0216578 <pages>
ffffffffc0201c86:	000b3503          	ld	a0,0(s6)
ffffffffc0201c8a:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201c8e:	000a3703          	ld	a4,0(s4)
ffffffffc0201c92:	40a48533          	sub	a0,s1,a0
ffffffffc0201c96:	8519                	srai	a0,a0,0x6
ffffffffc0201c98:	954e                	add	a0,a0,s3
ffffffffc0201c9a:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201c9e:	4685                	li	a3,1
ffffffffc0201ca0:	c094                	sw	a3,0(s1)
ffffffffc0201ca2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ca4:	0532                	slli	a0,a0,0xc
ffffffffc0201ca6:	08e7fa63          	bgeu	a5,a4,ffffffffc0201d3a <get_pte+0x19e>
ffffffffc0201caa:	000ab783          	ld	a5,0(s5)
ffffffffc0201cae:	6605                	lui	a2,0x1
ffffffffc0201cb0:	4581                	li	a1,0
ffffffffc0201cb2:	953e                	add	a0,a0,a5
ffffffffc0201cb4:	2b6030ef          	jal	ra,ffffffffc0204f6a <memset>
    return page - pages + nbase;
ffffffffc0201cb8:	000b3683          	ld	a3,0(s6)
ffffffffc0201cbc:	40d486b3          	sub	a3,s1,a3
ffffffffc0201cc0:	8699                	srai	a3,a3,0x6
ffffffffc0201cc2:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201cc4:	06aa                	slli	a3,a3,0xa
ffffffffc0201cc6:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201cca:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201ccc:	000a3703          	ld	a4,0(s4)
ffffffffc0201cd0:	068a                	slli	a3,a3,0x2
ffffffffc0201cd2:	757d                	lui	a0,0xfffff
ffffffffc0201cd4:	8ee9                	and	a3,a3,a0
ffffffffc0201cd6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201cda:	04e7f463          	bgeu	a5,a4,ffffffffc0201d22 <get_pte+0x186>
ffffffffc0201cde:	000ab503          	ld	a0,0(s5)
ffffffffc0201ce2:	00c95913          	srli	s2,s2,0xc
ffffffffc0201ce6:	1ff97913          	andi	s2,s2,511
ffffffffc0201cea:	96aa                	add	a3,a3,a0
ffffffffc0201cec:	00391513          	slli	a0,s2,0x3
ffffffffc0201cf0:	9536                	add	a0,a0,a3
}
ffffffffc0201cf2:	70e2                	ld	ra,56(sp)
ffffffffc0201cf4:	7442                	ld	s0,48(sp)
ffffffffc0201cf6:	74a2                	ld	s1,40(sp)
ffffffffc0201cf8:	7902                	ld	s2,32(sp)
ffffffffc0201cfa:	69e2                	ld	s3,24(sp)
ffffffffc0201cfc:	6a42                	ld	s4,16(sp)
ffffffffc0201cfe:	6aa2                	ld	s5,8(sp)
ffffffffc0201d00:	6b02                	ld	s6,0(sp)
ffffffffc0201d02:	6121                	addi	sp,sp,64
ffffffffc0201d04:	8082                	ret
            return NULL;
ffffffffc0201d06:	4501                	li	a0,0
ffffffffc0201d08:	b7ed                	j	ffffffffc0201cf2 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d0a:	00004617          	auipc	a2,0x4
ffffffffc0201d0e:	09660613          	addi	a2,a2,150 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0201d12:	0e400593          	li	a1,228
ffffffffc0201d16:	00004517          	auipc	a0,0x4
ffffffffc0201d1a:	1a250513          	addi	a0,a0,418 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0201d1e:	f28fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201d22:	00004617          	auipc	a2,0x4
ffffffffc0201d26:	07e60613          	addi	a2,a2,126 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0201d2a:	0ef00593          	li	a1,239
ffffffffc0201d2e:	00004517          	auipc	a0,0x4
ffffffffc0201d32:	18a50513          	addi	a0,a0,394 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0201d36:	f10fe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d3a:	86aa                	mv	a3,a0
ffffffffc0201d3c:	00004617          	auipc	a2,0x4
ffffffffc0201d40:	06460613          	addi	a2,a2,100 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0201d44:	0ec00593          	li	a1,236
ffffffffc0201d48:	00004517          	auipc	a0,0x4
ffffffffc0201d4c:	17050513          	addi	a0,a0,368 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0201d50:	ef6fe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d54:	86aa                	mv	a3,a0
ffffffffc0201d56:	00004617          	auipc	a2,0x4
ffffffffc0201d5a:	04a60613          	addi	a2,a2,74 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0201d5e:	0e100593          	li	a1,225
ffffffffc0201d62:	00004517          	auipc	a0,0x4
ffffffffc0201d66:	15650513          	addi	a0,a0,342 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0201d6a:	edcfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201d6e <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201d6e:	1141                	addi	sp,sp,-16
ffffffffc0201d70:	e022                	sd	s0,0(sp)
ffffffffc0201d72:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d74:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201d76:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d78:	e25ff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201d7c:	c011                	beqz	s0,ffffffffc0201d80 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201d7e:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201d80:	c511                	beqz	a0,ffffffffc0201d8c <get_page+0x1e>
ffffffffc0201d82:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201d84:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201d86:	0017f713          	andi	a4,a5,1
ffffffffc0201d8a:	e709                	bnez	a4,ffffffffc0201d94 <get_page+0x26>
}
ffffffffc0201d8c:	60a2                	ld	ra,8(sp)
ffffffffc0201d8e:	6402                	ld	s0,0(sp)
ffffffffc0201d90:	0141                	addi	sp,sp,16
ffffffffc0201d92:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d94:	078a                	slli	a5,a5,0x2
ffffffffc0201d96:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d98:	00014717          	auipc	a4,0x14
ffffffffc0201d9c:	7d873703          	ld	a4,2008(a4) # ffffffffc0216570 <npage>
ffffffffc0201da0:	00e7ff63          	bgeu	a5,a4,ffffffffc0201dbe <get_page+0x50>
ffffffffc0201da4:	60a2                	ld	ra,8(sp)
ffffffffc0201da6:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201da8:	fff80537          	lui	a0,0xfff80
ffffffffc0201dac:	97aa                	add	a5,a5,a0
ffffffffc0201dae:	079a                	slli	a5,a5,0x6
ffffffffc0201db0:	00014517          	auipc	a0,0x14
ffffffffc0201db4:	7c853503          	ld	a0,1992(a0) # ffffffffc0216578 <pages>
ffffffffc0201db8:	953e                	add	a0,a0,a5
ffffffffc0201dba:	0141                	addi	sp,sp,16
ffffffffc0201dbc:	8082                	ret
ffffffffc0201dbe:	c9bff0ef          	jal	ra,ffffffffc0201a58 <pa2page.part.0>

ffffffffc0201dc2 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201dc2:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201dc4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201dc6:	ec26                	sd	s1,24(sp)
ffffffffc0201dc8:	f406                	sd	ra,40(sp)
ffffffffc0201dca:	f022                	sd	s0,32(sp)
ffffffffc0201dcc:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201dce:	dcfff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
    if (ptep != NULL) {
ffffffffc0201dd2:	c511                	beqz	a0,ffffffffc0201dde <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201dd4:	611c                	ld	a5,0(a0)
ffffffffc0201dd6:	842a                	mv	s0,a0
ffffffffc0201dd8:	0017f713          	andi	a4,a5,1
ffffffffc0201ddc:	e711                	bnez	a4,ffffffffc0201de8 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201dde:	70a2                	ld	ra,40(sp)
ffffffffc0201de0:	7402                	ld	s0,32(sp)
ffffffffc0201de2:	64e2                	ld	s1,24(sp)
ffffffffc0201de4:	6145                	addi	sp,sp,48
ffffffffc0201de6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201de8:	078a                	slli	a5,a5,0x2
ffffffffc0201dea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dec:	00014717          	auipc	a4,0x14
ffffffffc0201df0:	78473703          	ld	a4,1924(a4) # ffffffffc0216570 <npage>
ffffffffc0201df4:	06e7f363          	bgeu	a5,a4,ffffffffc0201e5a <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0201df8:	fff80537          	lui	a0,0xfff80
ffffffffc0201dfc:	97aa                	add	a5,a5,a0
ffffffffc0201dfe:	079a                	slli	a5,a5,0x6
ffffffffc0201e00:	00014517          	auipc	a0,0x14
ffffffffc0201e04:	77853503          	ld	a0,1912(a0) # ffffffffc0216578 <pages>
ffffffffc0201e08:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201e0a:	411c                	lw	a5,0(a0)
ffffffffc0201e0c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201e10:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201e12:	cb11                	beqz	a4,ffffffffc0201e26 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201e14:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201e18:	12048073          	sfence.vma	s1
}
ffffffffc0201e1c:	70a2                	ld	ra,40(sp)
ffffffffc0201e1e:	7402                	ld	s0,32(sp)
ffffffffc0201e20:	64e2                	ld	s1,24(sp)
ffffffffc0201e22:	6145                	addi	sp,sp,48
ffffffffc0201e24:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e26:	100027f3          	csrr	a5,sstatus
ffffffffc0201e2a:	8b89                	andi	a5,a5,2
ffffffffc0201e2c:	eb89                	bnez	a5,ffffffffc0201e3e <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0201e2e:	00014797          	auipc	a5,0x14
ffffffffc0201e32:	7527b783          	ld	a5,1874(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201e36:	739c                	ld	a5,32(a5)
ffffffffc0201e38:	4585                	li	a1,1
ffffffffc0201e3a:	9782                	jalr	a5
    if (flag) {
ffffffffc0201e3c:	bfe1                	j	ffffffffc0201e14 <page_remove+0x52>
        intr_disable();
ffffffffc0201e3e:	e42a                	sd	a0,8(sp)
ffffffffc0201e40:	f82fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201e44:	00014797          	auipc	a5,0x14
ffffffffc0201e48:	73c7b783          	ld	a5,1852(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201e4c:	739c                	ld	a5,32(a5)
ffffffffc0201e4e:	6522                	ld	a0,8(sp)
ffffffffc0201e50:	4585                	li	a1,1
ffffffffc0201e52:	9782                	jalr	a5
        intr_enable();
ffffffffc0201e54:	f68fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201e58:	bf75                	j	ffffffffc0201e14 <page_remove+0x52>
ffffffffc0201e5a:	bffff0ef          	jal	ra,ffffffffc0201a58 <pa2page.part.0>

ffffffffc0201e5e <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e5e:	7139                	addi	sp,sp,-64
ffffffffc0201e60:	e852                	sd	s4,16(sp)
ffffffffc0201e62:	8a32                	mv	s4,a2
ffffffffc0201e64:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e66:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e68:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e6a:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e6c:	f426                	sd	s1,40(sp)
ffffffffc0201e6e:	fc06                	sd	ra,56(sp)
ffffffffc0201e70:	f04a                	sd	s2,32(sp)
ffffffffc0201e72:	ec4e                	sd	s3,24(sp)
ffffffffc0201e74:	e456                	sd	s5,8(sp)
ffffffffc0201e76:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e78:	d25ff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
    if (ptep == NULL) {
ffffffffc0201e7c:	c961                	beqz	a0,ffffffffc0201f4c <page_insert+0xee>
    page->ref += 1;
ffffffffc0201e7e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201e80:	611c                	ld	a5,0(a0)
ffffffffc0201e82:	89aa                	mv	s3,a0
ffffffffc0201e84:	0016871b          	addiw	a4,a3,1
ffffffffc0201e88:	c018                	sw	a4,0(s0)
ffffffffc0201e8a:	0017f713          	andi	a4,a5,1
ffffffffc0201e8e:	ef05                	bnez	a4,ffffffffc0201ec6 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201e90:	00014717          	auipc	a4,0x14
ffffffffc0201e94:	6e873703          	ld	a4,1768(a4) # ffffffffc0216578 <pages>
ffffffffc0201e98:	8c19                	sub	s0,s0,a4
ffffffffc0201e9a:	000807b7          	lui	a5,0x80
ffffffffc0201e9e:	8419                	srai	s0,s0,0x6
ffffffffc0201ea0:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ea2:	042a                	slli	s0,s0,0xa
ffffffffc0201ea4:	8cc1                	or	s1,s1,s0
ffffffffc0201ea6:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201eaa:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201eae:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201eb2:	4501                	li	a0,0
}
ffffffffc0201eb4:	70e2                	ld	ra,56(sp)
ffffffffc0201eb6:	7442                	ld	s0,48(sp)
ffffffffc0201eb8:	74a2                	ld	s1,40(sp)
ffffffffc0201eba:	7902                	ld	s2,32(sp)
ffffffffc0201ebc:	69e2                	ld	s3,24(sp)
ffffffffc0201ebe:	6a42                	ld	s4,16(sp)
ffffffffc0201ec0:	6aa2                	ld	s5,8(sp)
ffffffffc0201ec2:	6121                	addi	sp,sp,64
ffffffffc0201ec4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ec6:	078a                	slli	a5,a5,0x2
ffffffffc0201ec8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eca:	00014717          	auipc	a4,0x14
ffffffffc0201ece:	6a673703          	ld	a4,1702(a4) # ffffffffc0216570 <npage>
ffffffffc0201ed2:	06e7ff63          	bgeu	a5,a4,ffffffffc0201f50 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ed6:	00014a97          	auipc	s5,0x14
ffffffffc0201eda:	6a2a8a93          	addi	s5,s5,1698 # ffffffffc0216578 <pages>
ffffffffc0201ede:	000ab703          	ld	a4,0(s5)
ffffffffc0201ee2:	fff80937          	lui	s2,0xfff80
ffffffffc0201ee6:	993e                	add	s2,s2,a5
ffffffffc0201ee8:	091a                	slli	s2,s2,0x6
ffffffffc0201eea:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0201eec:	01240c63          	beq	s0,s2,ffffffffc0201f04 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0201ef0:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd69a2c>
ffffffffc0201ef4:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201ef8:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0201efc:	c691                	beqz	a3,ffffffffc0201f08 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201efe:	120a0073          	sfence.vma	s4
}
ffffffffc0201f02:	bf59                	j	ffffffffc0201e98 <page_insert+0x3a>
ffffffffc0201f04:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201f06:	bf49                	j	ffffffffc0201e98 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f08:	100027f3          	csrr	a5,sstatus
ffffffffc0201f0c:	8b89                	andi	a5,a5,2
ffffffffc0201f0e:	ef91                	bnez	a5,ffffffffc0201f2a <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0201f10:	00014797          	auipc	a5,0x14
ffffffffc0201f14:	6707b783          	ld	a5,1648(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201f18:	739c                	ld	a5,32(a5)
ffffffffc0201f1a:	4585                	li	a1,1
ffffffffc0201f1c:	854a                	mv	a0,s2
ffffffffc0201f1e:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0201f20:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f24:	120a0073          	sfence.vma	s4
ffffffffc0201f28:	bf85                	j	ffffffffc0201e98 <page_insert+0x3a>
        intr_disable();
ffffffffc0201f2a:	e98fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f2e:	00014797          	auipc	a5,0x14
ffffffffc0201f32:	6527b783          	ld	a5,1618(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0201f36:	739c                	ld	a5,32(a5)
ffffffffc0201f38:	4585                	li	a1,1
ffffffffc0201f3a:	854a                	mv	a0,s2
ffffffffc0201f3c:	9782                	jalr	a5
        intr_enable();
ffffffffc0201f3e:	e7efe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201f42:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f46:	120a0073          	sfence.vma	s4
ffffffffc0201f4a:	b7b9                	j	ffffffffc0201e98 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201f4c:	5571                	li	a0,-4
ffffffffc0201f4e:	b79d                	j	ffffffffc0201eb4 <page_insert+0x56>
ffffffffc0201f50:	b09ff0ef          	jal	ra,ffffffffc0201a58 <pa2page.part.0>

ffffffffc0201f54 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201f54:	00004797          	auipc	a5,0x4
ffffffffc0201f58:	e1478793          	addi	a5,a5,-492 # ffffffffc0205d68 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201f5c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201f5e:	711d                	addi	sp,sp,-96
ffffffffc0201f60:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201f62:	00004517          	auipc	a0,0x4
ffffffffc0201f66:	f6650513          	addi	a0,a0,-154 # ffffffffc0205ec8 <default_pmm_manager+0x160>
    pmm_manager = &default_pmm_manager;
ffffffffc0201f6a:	00014b97          	auipc	s7,0x14
ffffffffc0201f6e:	616b8b93          	addi	s7,s7,1558 # ffffffffc0216580 <pmm_manager>
void pmm_init(void) {
ffffffffc0201f72:	ec86                	sd	ra,88(sp)
ffffffffc0201f74:	e4a6                	sd	s1,72(sp)
ffffffffc0201f76:	fc4e                	sd	s3,56(sp)
ffffffffc0201f78:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201f7a:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201f7e:	e8a2                	sd	s0,80(sp)
ffffffffc0201f80:	e0ca                	sd	s2,64(sp)
ffffffffc0201f82:	f852                	sd	s4,48(sp)
ffffffffc0201f84:	f456                	sd	s5,40(sp)
ffffffffc0201f86:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201f88:	9f8fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc0201f8c:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201f90:	00014997          	auipc	s3,0x14
ffffffffc0201f94:	5f898993          	addi	s3,s3,1528 # ffffffffc0216588 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201f98:	00014497          	auipc	s1,0x14
ffffffffc0201f9c:	5d848493          	addi	s1,s1,1496 # ffffffffc0216570 <npage>
    pmm_manager->init();
ffffffffc0201fa0:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201fa2:	00014b17          	auipc	s6,0x14
ffffffffc0201fa6:	5d6b0b13          	addi	s6,s6,1494 # ffffffffc0216578 <pages>
    pmm_manager->init();
ffffffffc0201faa:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201fac:	57f5                	li	a5,-3
ffffffffc0201fae:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201fb0:	00004517          	auipc	a0,0x4
ffffffffc0201fb4:	f3050513          	addi	a0,a0,-208 # ffffffffc0205ee0 <default_pmm_manager+0x178>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201fb8:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0201fbc:	9c4fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201fc0:	46c5                	li	a3,17
ffffffffc0201fc2:	06ee                	slli	a3,a3,0x1b
ffffffffc0201fc4:	40100613          	li	a2,1025
ffffffffc0201fc8:	07e005b7          	lui	a1,0x7e00
ffffffffc0201fcc:	16fd                	addi	a3,a3,-1
ffffffffc0201fce:	0656                	slli	a2,a2,0x15
ffffffffc0201fd0:	00004517          	auipc	a0,0x4
ffffffffc0201fd4:	f2850513          	addi	a0,a0,-216 # ffffffffc0205ef8 <default_pmm_manager+0x190>
ffffffffc0201fd8:	9a8fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201fdc:	777d                	lui	a4,0xfffff
ffffffffc0201fde:	00015797          	auipc	a5,0x15
ffffffffc0201fe2:	5f578793          	addi	a5,a5,1525 # ffffffffc02175d3 <end+0xfff>
ffffffffc0201fe6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201fe8:	00088737          	lui	a4,0x88
ffffffffc0201fec:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201fee:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201ff2:	4701                	li	a4,0
ffffffffc0201ff4:	4585                	li	a1,1
ffffffffc0201ff6:	fff80837          	lui	a6,0xfff80
ffffffffc0201ffa:	a019                	j	ffffffffc0202000 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0201ffc:	000b3783          	ld	a5,0(s6)
ffffffffc0202000:	00671693          	slli	a3,a4,0x6
ffffffffc0202004:	97b6                	add	a5,a5,a3
ffffffffc0202006:	07a1                	addi	a5,a5,8
ffffffffc0202008:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020200c:	6090                	ld	a2,0(s1)
ffffffffc020200e:	0705                	addi	a4,a4,1
ffffffffc0202010:	010607b3          	add	a5,a2,a6
ffffffffc0202014:	fef764e3          	bltu	a4,a5,ffffffffc0201ffc <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202018:	000b3503          	ld	a0,0(s6)
ffffffffc020201c:	079a                	slli	a5,a5,0x6
ffffffffc020201e:	c0200737          	lui	a4,0xc0200
ffffffffc0202022:	00f506b3          	add	a3,a0,a5
ffffffffc0202026:	60e6e563          	bltu	a3,a4,ffffffffc0202630 <pmm_init+0x6dc>
ffffffffc020202a:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020202e:	4745                	li	a4,17
ffffffffc0202030:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202032:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202034:	4ae6e563          	bltu	a3,a4,ffffffffc02024de <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202038:	00004517          	auipc	a0,0x4
ffffffffc020203c:	ee850513          	addi	a0,a0,-280 # ffffffffc0205f20 <default_pmm_manager+0x1b8>
ffffffffc0202040:	940fe0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202044:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202048:	00014917          	auipc	s2,0x14
ffffffffc020204c:	52090913          	addi	s2,s2,1312 # ffffffffc0216568 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202050:	7b9c                	ld	a5,48(a5)
ffffffffc0202052:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202054:	00004517          	auipc	a0,0x4
ffffffffc0202058:	ee450513          	addi	a0,a0,-284 # ffffffffc0205f38 <default_pmm_manager+0x1d0>
ffffffffc020205c:	924fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202060:	00008697          	auipc	a3,0x8
ffffffffc0202064:	fa068693          	addi	a3,a3,-96 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202068:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020206c:	c02007b7          	lui	a5,0xc0200
ffffffffc0202070:	5cf6ec63          	bltu	a3,a5,ffffffffc0202648 <pmm_init+0x6f4>
ffffffffc0202074:	0009b783          	ld	a5,0(s3)
ffffffffc0202078:	8e9d                	sub	a3,a3,a5
ffffffffc020207a:	00014797          	auipc	a5,0x14
ffffffffc020207e:	4ed7b323          	sd	a3,1254(a5) # ffffffffc0216560 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202082:	100027f3          	csrr	a5,sstatus
ffffffffc0202086:	8b89                	andi	a5,a5,2
ffffffffc0202088:	48079263          	bnez	a5,ffffffffc020250c <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020208c:	000bb783          	ld	a5,0(s7)
ffffffffc0202090:	779c                	ld	a5,40(a5)
ffffffffc0202092:	9782                	jalr	a5
ffffffffc0202094:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202096:	6098                	ld	a4,0(s1)
ffffffffc0202098:	c80007b7          	lui	a5,0xc8000
ffffffffc020209c:	83b1                	srli	a5,a5,0xc
ffffffffc020209e:	5ee7e163          	bltu	a5,a4,ffffffffc0202680 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02020a2:	00093503          	ld	a0,0(s2)
ffffffffc02020a6:	5a050d63          	beqz	a0,ffffffffc0202660 <pmm_init+0x70c>
ffffffffc02020aa:	03451793          	slli	a5,a0,0x34
ffffffffc02020ae:	5a079963          	bnez	a5,ffffffffc0202660 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02020b2:	4601                	li	a2,0
ffffffffc02020b4:	4581                	li	a1,0
ffffffffc02020b6:	cb9ff0ef          	jal	ra,ffffffffc0201d6e <get_page>
ffffffffc02020ba:	62051563          	bnez	a0,ffffffffc02026e4 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02020be:	4505                	li	a0,1
ffffffffc02020c0:	9d1ff0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc02020c4:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02020c6:	00093503          	ld	a0,0(s2)
ffffffffc02020ca:	4681                	li	a3,0
ffffffffc02020cc:	4601                	li	a2,0
ffffffffc02020ce:	85d2                	mv	a1,s4
ffffffffc02020d0:	d8fff0ef          	jal	ra,ffffffffc0201e5e <page_insert>
ffffffffc02020d4:	5e051863          	bnez	a0,ffffffffc02026c4 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02020d8:	00093503          	ld	a0,0(s2)
ffffffffc02020dc:	4601                	li	a2,0
ffffffffc02020de:	4581                	li	a1,0
ffffffffc02020e0:	abdff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
ffffffffc02020e4:	5c050063          	beqz	a0,ffffffffc02026a4 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc02020e8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02020ea:	0017f713          	andi	a4,a5,1
ffffffffc02020ee:	5a070963          	beqz	a4,ffffffffc02026a0 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02020f2:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02020f4:	078a                	slli	a5,a5,0x2
ffffffffc02020f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020f8:	52e7fa63          	bgeu	a5,a4,ffffffffc020262c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02020fc:	000b3683          	ld	a3,0(s6)
ffffffffc0202100:	fff80637          	lui	a2,0xfff80
ffffffffc0202104:	97b2                	add	a5,a5,a2
ffffffffc0202106:	079a                	slli	a5,a5,0x6
ffffffffc0202108:	97b6                	add	a5,a5,a3
ffffffffc020210a:	10fa16e3          	bne	s4,a5,ffffffffc0202a16 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc020210e:	000a2683          	lw	a3,0(s4)
ffffffffc0202112:	4785                	li	a5,1
ffffffffc0202114:	12f69de3          	bne	a3,a5,ffffffffc0202a4e <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202118:	00093503          	ld	a0,0(s2)
ffffffffc020211c:	77fd                	lui	a5,0xfffff
ffffffffc020211e:	6114                	ld	a3,0(a0)
ffffffffc0202120:	068a                	slli	a3,a3,0x2
ffffffffc0202122:	8efd                	and	a3,a3,a5
ffffffffc0202124:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202128:	10e677e3          	bgeu	a2,a4,ffffffffc0202a36 <pmm_init+0xae2>
ffffffffc020212c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202130:	96e2                	add	a3,a3,s8
ffffffffc0202132:	0006ba83          	ld	s5,0(a3)
ffffffffc0202136:	0a8a                	slli	s5,s5,0x2
ffffffffc0202138:	00fafab3          	and	s5,s5,a5
ffffffffc020213c:	00cad793          	srli	a5,s5,0xc
ffffffffc0202140:	62e7f263          	bgeu	a5,a4,ffffffffc0202764 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202144:	4601                	li	a2,0
ffffffffc0202146:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202148:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020214a:	a53ff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020214e:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202150:	5f551a63          	bne	a0,s5,ffffffffc0202744 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0202154:	4505                	li	a0,1
ffffffffc0202156:	93bff0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc020215a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020215c:	00093503          	ld	a0,0(s2)
ffffffffc0202160:	46d1                	li	a3,20
ffffffffc0202162:	6605                	lui	a2,0x1
ffffffffc0202164:	85d6                	mv	a1,s5
ffffffffc0202166:	cf9ff0ef          	jal	ra,ffffffffc0201e5e <page_insert>
ffffffffc020216a:	58051d63          	bnez	a0,ffffffffc0202704 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020216e:	00093503          	ld	a0,0(s2)
ffffffffc0202172:	4601                	li	a2,0
ffffffffc0202174:	6585                	lui	a1,0x1
ffffffffc0202176:	a27ff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
ffffffffc020217a:	0e050ae3          	beqz	a0,ffffffffc0202a6e <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020217e:	611c                	ld	a5,0(a0)
ffffffffc0202180:	0107f713          	andi	a4,a5,16
ffffffffc0202184:	6e070d63          	beqz	a4,ffffffffc020287e <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0202188:	8b91                	andi	a5,a5,4
ffffffffc020218a:	6a078a63          	beqz	a5,ffffffffc020283e <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020218e:	00093503          	ld	a0,0(s2)
ffffffffc0202192:	611c                	ld	a5,0(a0)
ffffffffc0202194:	8bc1                	andi	a5,a5,16
ffffffffc0202196:	68078463          	beqz	a5,ffffffffc020281e <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc020219a:	000aa703          	lw	a4,0(s5)
ffffffffc020219e:	4785                	li	a5,1
ffffffffc02021a0:	58f71263          	bne	a4,a5,ffffffffc0202724 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02021a4:	4681                	li	a3,0
ffffffffc02021a6:	6605                	lui	a2,0x1
ffffffffc02021a8:	85d2                	mv	a1,s4
ffffffffc02021aa:	cb5ff0ef          	jal	ra,ffffffffc0201e5e <page_insert>
ffffffffc02021ae:	62051863          	bnez	a0,ffffffffc02027de <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02021b2:	000a2703          	lw	a4,0(s4)
ffffffffc02021b6:	4789                	li	a5,2
ffffffffc02021b8:	60f71363          	bne	a4,a5,ffffffffc02027be <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02021bc:	000aa783          	lw	a5,0(s5)
ffffffffc02021c0:	5c079f63          	bnez	a5,ffffffffc020279e <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02021c4:	00093503          	ld	a0,0(s2)
ffffffffc02021c8:	4601                	li	a2,0
ffffffffc02021ca:	6585                	lui	a1,0x1
ffffffffc02021cc:	9d1ff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
ffffffffc02021d0:	5a050763          	beqz	a0,ffffffffc020277e <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02021d4:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02021d6:	00177793          	andi	a5,a4,1
ffffffffc02021da:	4c078363          	beqz	a5,ffffffffc02026a0 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02021de:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021e0:	00271793          	slli	a5,a4,0x2
ffffffffc02021e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021e6:	44d7f363          	bgeu	a5,a3,ffffffffc020262c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02021ea:	000b3683          	ld	a3,0(s6)
ffffffffc02021ee:	fff80637          	lui	a2,0xfff80
ffffffffc02021f2:	97b2                	add	a5,a5,a2
ffffffffc02021f4:	079a                	slli	a5,a5,0x6
ffffffffc02021f6:	97b6                	add	a5,a5,a3
ffffffffc02021f8:	6efa1363          	bne	s4,a5,ffffffffc02028de <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc02021fc:	8b41                	andi	a4,a4,16
ffffffffc02021fe:	6c071063          	bnez	a4,ffffffffc02028be <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202202:	00093503          	ld	a0,0(s2)
ffffffffc0202206:	4581                	li	a1,0
ffffffffc0202208:	bbbff0ef          	jal	ra,ffffffffc0201dc2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020220c:	000a2703          	lw	a4,0(s4)
ffffffffc0202210:	4785                	li	a5,1
ffffffffc0202212:	68f71663          	bne	a4,a5,ffffffffc020289e <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0202216:	000aa783          	lw	a5,0(s5)
ffffffffc020221a:	74079e63          	bnez	a5,ffffffffc0202976 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020221e:	00093503          	ld	a0,0(s2)
ffffffffc0202222:	6585                	lui	a1,0x1
ffffffffc0202224:	b9fff0ef          	jal	ra,ffffffffc0201dc2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202228:	000a2783          	lw	a5,0(s4)
ffffffffc020222c:	72079563          	bnez	a5,ffffffffc0202956 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0202230:	000aa783          	lw	a5,0(s5)
ffffffffc0202234:	70079163          	bnez	a5,ffffffffc0202936 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202238:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020223c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020223e:	000a3683          	ld	a3,0(s4)
ffffffffc0202242:	068a                	slli	a3,a3,0x2
ffffffffc0202244:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202246:	3ee6f363          	bgeu	a3,a4,ffffffffc020262c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020224a:	fff807b7          	lui	a5,0xfff80
ffffffffc020224e:	000b3503          	ld	a0,0(s6)
ffffffffc0202252:	96be                	add	a3,a3,a5
ffffffffc0202254:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202256:	00d507b3          	add	a5,a0,a3
ffffffffc020225a:	4390                	lw	a2,0(a5)
ffffffffc020225c:	4785                	li	a5,1
ffffffffc020225e:	6af61c63          	bne	a2,a5,ffffffffc0202916 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0202262:	8699                	srai	a3,a3,0x6
ffffffffc0202264:	000805b7          	lui	a1,0x80
ffffffffc0202268:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020226a:	00c69613          	slli	a2,a3,0xc
ffffffffc020226e:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202270:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202272:	68e67663          	bgeu	a2,a4,ffffffffc02028fe <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202276:	0009b603          	ld	a2,0(s3)
ffffffffc020227a:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020227c:	629c                	ld	a5,0(a3)
ffffffffc020227e:	078a                	slli	a5,a5,0x2
ffffffffc0202280:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202282:	3ae7f563          	bgeu	a5,a4,ffffffffc020262c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202286:	8f8d                	sub	a5,a5,a1
ffffffffc0202288:	079a                	slli	a5,a5,0x6
ffffffffc020228a:	953e                	add	a0,a0,a5
ffffffffc020228c:	100027f3          	csrr	a5,sstatus
ffffffffc0202290:	8b89                	andi	a5,a5,2
ffffffffc0202292:	2c079763          	bnez	a5,ffffffffc0202560 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0202296:	000bb783          	ld	a5,0(s7)
ffffffffc020229a:	4585                	li	a1,1
ffffffffc020229c:	739c                	ld	a5,32(a5)
ffffffffc020229e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02022a0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02022a4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022a6:	078a                	slli	a5,a5,0x2
ffffffffc02022a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022aa:	38e7f163          	bgeu	a5,a4,ffffffffc020262c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02022ae:	000b3503          	ld	a0,0(s6)
ffffffffc02022b2:	fff80737          	lui	a4,0xfff80
ffffffffc02022b6:	97ba                	add	a5,a5,a4
ffffffffc02022b8:	079a                	slli	a5,a5,0x6
ffffffffc02022ba:	953e                	add	a0,a0,a5
ffffffffc02022bc:	100027f3          	csrr	a5,sstatus
ffffffffc02022c0:	8b89                	andi	a5,a5,2
ffffffffc02022c2:	28079363          	bnez	a5,ffffffffc0202548 <pmm_init+0x5f4>
ffffffffc02022c6:	000bb783          	ld	a5,0(s7)
ffffffffc02022ca:	4585                	li	a1,1
ffffffffc02022cc:	739c                	ld	a5,32(a5)
ffffffffc02022ce:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02022d0:	00093783          	ld	a5,0(s2)
ffffffffc02022d4:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd69a2c>
  asm volatile("sfence.vma");
ffffffffc02022d8:	12000073          	sfence.vma
ffffffffc02022dc:	100027f3          	csrr	a5,sstatus
ffffffffc02022e0:	8b89                	andi	a5,a5,2
ffffffffc02022e2:	24079963          	bnez	a5,ffffffffc0202534 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02022e6:	000bb783          	ld	a5,0(s7)
ffffffffc02022ea:	779c                	ld	a5,40(a5)
ffffffffc02022ec:	9782                	jalr	a5
ffffffffc02022ee:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02022f0:	71441363          	bne	s0,s4,ffffffffc02029f6 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02022f4:	00004517          	auipc	a0,0x4
ffffffffc02022f8:	f2c50513          	addi	a0,a0,-212 # ffffffffc0206220 <default_pmm_manager+0x4b8>
ffffffffc02022fc:	e85fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202300:	100027f3          	csrr	a5,sstatus
ffffffffc0202304:	8b89                	andi	a5,a5,2
ffffffffc0202306:	20079d63          	bnez	a5,ffffffffc0202520 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc020230a:	000bb783          	ld	a5,0(s7)
ffffffffc020230e:	779c                	ld	a5,40(a5)
ffffffffc0202310:	9782                	jalr	a5
ffffffffc0202312:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202314:	6098                	ld	a4,0(s1)
ffffffffc0202316:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020231a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020231c:	00c71793          	slli	a5,a4,0xc
ffffffffc0202320:	6a05                	lui	s4,0x1
ffffffffc0202322:	02f47c63          	bgeu	s0,a5,ffffffffc020235a <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202326:	00c45793          	srli	a5,s0,0xc
ffffffffc020232a:	00093503          	ld	a0,0(s2)
ffffffffc020232e:	2ee7f263          	bgeu	a5,a4,ffffffffc0202612 <pmm_init+0x6be>
ffffffffc0202332:	0009b583          	ld	a1,0(s3)
ffffffffc0202336:	4601                	li	a2,0
ffffffffc0202338:	95a2                	add	a1,a1,s0
ffffffffc020233a:	863ff0ef          	jal	ra,ffffffffc0201b9c <get_pte>
ffffffffc020233e:	2a050a63          	beqz	a0,ffffffffc02025f2 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202342:	611c                	ld	a5,0(a0)
ffffffffc0202344:	078a                	slli	a5,a5,0x2
ffffffffc0202346:	0157f7b3          	and	a5,a5,s5
ffffffffc020234a:	28879463          	bne	a5,s0,ffffffffc02025d2 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020234e:	6098                	ld	a4,0(s1)
ffffffffc0202350:	9452                	add	s0,s0,s4
ffffffffc0202352:	00c71793          	slli	a5,a4,0xc
ffffffffc0202356:	fcf468e3          	bltu	s0,a5,ffffffffc0202326 <pmm_init+0x3d2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc020235a:	00093783          	ld	a5,0(s2)
ffffffffc020235e:	639c                	ld	a5,0(a5)
ffffffffc0202360:	66079b63          	bnez	a5,ffffffffc02029d6 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0202364:	4505                	li	a0,1
ffffffffc0202366:	f2aff0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc020236a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020236c:	00093503          	ld	a0,0(s2)
ffffffffc0202370:	4699                	li	a3,6
ffffffffc0202372:	10000613          	li	a2,256
ffffffffc0202376:	85d6                	mv	a1,s5
ffffffffc0202378:	ae7ff0ef          	jal	ra,ffffffffc0201e5e <page_insert>
ffffffffc020237c:	62051d63          	bnez	a0,ffffffffc02029b6 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0202380:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde8a2c>
ffffffffc0202384:	4785                	li	a5,1
ffffffffc0202386:	60f71863          	bne	a4,a5,ffffffffc0202996 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020238a:	00093503          	ld	a0,0(s2)
ffffffffc020238e:	6405                	lui	s0,0x1
ffffffffc0202390:	4699                	li	a3,6
ffffffffc0202392:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202396:	85d6                	mv	a1,s5
ffffffffc0202398:	ac7ff0ef          	jal	ra,ffffffffc0201e5e <page_insert>
ffffffffc020239c:	46051163          	bnez	a0,ffffffffc02027fe <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02023a0:	000aa703          	lw	a4,0(s5)
ffffffffc02023a4:	4789                	li	a5,2
ffffffffc02023a6:	72f71463          	bne	a4,a5,ffffffffc0202ace <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02023aa:	00004597          	auipc	a1,0x4
ffffffffc02023ae:	fae58593          	addi	a1,a1,-82 # ffffffffc0206358 <default_pmm_manager+0x5f0>
ffffffffc02023b2:	10000513          	li	a0,256
ffffffffc02023b6:	36f020ef          	jal	ra,ffffffffc0204f24 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02023ba:	10040593          	addi	a1,s0,256
ffffffffc02023be:	10000513          	li	a0,256
ffffffffc02023c2:	375020ef          	jal	ra,ffffffffc0204f36 <strcmp>
ffffffffc02023c6:	6e051463          	bnez	a0,ffffffffc0202aae <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02023ca:	000b3683          	ld	a3,0(s6)
ffffffffc02023ce:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02023d2:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02023d4:	40da86b3          	sub	a3,s5,a3
ffffffffc02023d8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02023da:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02023dc:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02023de:	8031                	srli	s0,s0,0xc
ffffffffc02023e0:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02023e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023e6:	50f77c63          	bgeu	a4,a5,ffffffffc02028fe <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02023ea:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02023ee:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02023f2:	96be                	add	a3,a3,a5
ffffffffc02023f4:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02023f8:	2f7020ef          	jal	ra,ffffffffc0204eee <strlen>
ffffffffc02023fc:	68051963          	bnez	a0,ffffffffc0202a8e <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202400:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202404:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202406:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020240a:	068a                	slli	a3,a3,0x2
ffffffffc020240c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020240e:	20f6ff63          	bgeu	a3,a5,ffffffffc020262c <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202412:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202414:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202416:	4ef47463          	bgeu	s0,a5,ffffffffc02028fe <pmm_init+0x9aa>
ffffffffc020241a:	0009b403          	ld	s0,0(s3)
ffffffffc020241e:	9436                	add	s0,s0,a3
ffffffffc0202420:	100027f3          	csrr	a5,sstatus
ffffffffc0202424:	8b89                	andi	a5,a5,2
ffffffffc0202426:	18079b63          	bnez	a5,ffffffffc02025bc <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc020242a:	000bb783          	ld	a5,0(s7)
ffffffffc020242e:	4585                	li	a1,1
ffffffffc0202430:	8556                	mv	a0,s5
ffffffffc0202432:	739c                	ld	a5,32(a5)
ffffffffc0202434:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202436:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202438:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020243a:	078a                	slli	a5,a5,0x2
ffffffffc020243c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020243e:	1ee7f763          	bgeu	a5,a4,ffffffffc020262c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202442:	000b3503          	ld	a0,0(s6)
ffffffffc0202446:	fff80737          	lui	a4,0xfff80
ffffffffc020244a:	97ba                	add	a5,a5,a4
ffffffffc020244c:	079a                	slli	a5,a5,0x6
ffffffffc020244e:	953e                	add	a0,a0,a5
ffffffffc0202450:	100027f3          	csrr	a5,sstatus
ffffffffc0202454:	8b89                	andi	a5,a5,2
ffffffffc0202456:	14079763          	bnez	a5,ffffffffc02025a4 <pmm_init+0x650>
ffffffffc020245a:	000bb783          	ld	a5,0(s7)
ffffffffc020245e:	4585                	li	a1,1
ffffffffc0202460:	739c                	ld	a5,32(a5)
ffffffffc0202462:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202464:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202468:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020246a:	078a                	slli	a5,a5,0x2
ffffffffc020246c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020246e:	1ae7ff63          	bgeu	a5,a4,ffffffffc020262c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202472:	000b3503          	ld	a0,0(s6)
ffffffffc0202476:	fff80737          	lui	a4,0xfff80
ffffffffc020247a:	97ba                	add	a5,a5,a4
ffffffffc020247c:	079a                	slli	a5,a5,0x6
ffffffffc020247e:	953e                	add	a0,a0,a5
ffffffffc0202480:	100027f3          	csrr	a5,sstatus
ffffffffc0202484:	8b89                	andi	a5,a5,2
ffffffffc0202486:	10079363          	bnez	a5,ffffffffc020258c <pmm_init+0x638>
ffffffffc020248a:	000bb783          	ld	a5,0(s7)
ffffffffc020248e:	4585                	li	a1,1
ffffffffc0202490:	739c                	ld	a5,32(a5)
ffffffffc0202492:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202494:	00093783          	ld	a5,0(s2)
ffffffffc0202498:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020249c:	12000073          	sfence.vma
ffffffffc02024a0:	100027f3          	csrr	a5,sstatus
ffffffffc02024a4:	8b89                	andi	a5,a5,2
ffffffffc02024a6:	0c079963          	bnez	a5,ffffffffc0202578 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc02024aa:	000bb783          	ld	a5,0(s7)
ffffffffc02024ae:	779c                	ld	a5,40(a5)
ffffffffc02024b0:	9782                	jalr	a5
ffffffffc02024b2:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02024b4:	3a8c1563          	bne	s8,s0,ffffffffc020285e <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02024b8:	00004517          	auipc	a0,0x4
ffffffffc02024bc:	f1850513          	addi	a0,a0,-232 # ffffffffc02063d0 <default_pmm_manager+0x668>
ffffffffc02024c0:	cc1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc02024c4:	6446                	ld	s0,80(sp)
ffffffffc02024c6:	60e6                	ld	ra,88(sp)
ffffffffc02024c8:	64a6                	ld	s1,72(sp)
ffffffffc02024ca:	6906                	ld	s2,64(sp)
ffffffffc02024cc:	79e2                	ld	s3,56(sp)
ffffffffc02024ce:	7a42                	ld	s4,48(sp)
ffffffffc02024d0:	7aa2                	ld	s5,40(sp)
ffffffffc02024d2:	7b02                	ld	s6,32(sp)
ffffffffc02024d4:	6be2                	ld	s7,24(sp)
ffffffffc02024d6:	6c42                	ld	s8,16(sp)
ffffffffc02024d8:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02024da:	bb8ff06f          	j	ffffffffc0201892 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02024de:	6785                	lui	a5,0x1
ffffffffc02024e0:	17fd                	addi	a5,a5,-1
ffffffffc02024e2:	96be                	add	a3,a3,a5
ffffffffc02024e4:	77fd                	lui	a5,0xfffff
ffffffffc02024e6:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc02024e8:	00c7d693          	srli	a3,a5,0xc
ffffffffc02024ec:	14c6f063          	bgeu	a3,a2,ffffffffc020262c <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc02024f0:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02024f4:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02024f6:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc02024fa:	6a10                	ld	a2,16(a2)
ffffffffc02024fc:	069a                	slli	a3,a3,0x6
ffffffffc02024fe:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202502:	9536                	add	a0,a0,a3
ffffffffc0202504:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202506:	0009b583          	ld	a1,0(s3)
}
ffffffffc020250a:	b63d                	j	ffffffffc0202038 <pmm_init+0xe4>
        intr_disable();
ffffffffc020250c:	8b6fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202510:	000bb783          	ld	a5,0(s7)
ffffffffc0202514:	779c                	ld	a5,40(a5)
ffffffffc0202516:	9782                	jalr	a5
ffffffffc0202518:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020251a:	8a2fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020251e:	bea5                	j	ffffffffc0202096 <pmm_init+0x142>
        intr_disable();
ffffffffc0202520:	8a2fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202524:	000bb783          	ld	a5,0(s7)
ffffffffc0202528:	779c                	ld	a5,40(a5)
ffffffffc020252a:	9782                	jalr	a5
ffffffffc020252c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020252e:	88efe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202532:	b3cd                	j	ffffffffc0202314 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202534:	88efe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202538:	000bb783          	ld	a5,0(s7)
ffffffffc020253c:	779c                	ld	a5,40(a5)
ffffffffc020253e:	9782                	jalr	a5
ffffffffc0202540:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202542:	87afe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202546:	b36d                	j	ffffffffc02022f0 <pmm_init+0x39c>
ffffffffc0202548:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020254a:	878fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020254e:	000bb783          	ld	a5,0(s7)
ffffffffc0202552:	6522                	ld	a0,8(sp)
ffffffffc0202554:	4585                	li	a1,1
ffffffffc0202556:	739c                	ld	a5,32(a5)
ffffffffc0202558:	9782                	jalr	a5
        intr_enable();
ffffffffc020255a:	862fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020255e:	bb8d                	j	ffffffffc02022d0 <pmm_init+0x37c>
ffffffffc0202560:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202562:	860fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202566:	000bb783          	ld	a5,0(s7)
ffffffffc020256a:	6522                	ld	a0,8(sp)
ffffffffc020256c:	4585                	li	a1,1
ffffffffc020256e:	739c                	ld	a5,32(a5)
ffffffffc0202570:	9782                	jalr	a5
        intr_enable();
ffffffffc0202572:	84afe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202576:	b32d                	j	ffffffffc02022a0 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202578:	84afe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020257c:	000bb783          	ld	a5,0(s7)
ffffffffc0202580:	779c                	ld	a5,40(a5)
ffffffffc0202582:	9782                	jalr	a5
ffffffffc0202584:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202586:	836fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020258a:	b72d                	j	ffffffffc02024b4 <pmm_init+0x560>
ffffffffc020258c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020258e:	834fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202592:	000bb783          	ld	a5,0(s7)
ffffffffc0202596:	6522                	ld	a0,8(sp)
ffffffffc0202598:	4585                	li	a1,1
ffffffffc020259a:	739c                	ld	a5,32(a5)
ffffffffc020259c:	9782                	jalr	a5
        intr_enable();
ffffffffc020259e:	81efe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025a2:	bdcd                	j	ffffffffc0202494 <pmm_init+0x540>
ffffffffc02025a4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02025a6:	81cfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02025aa:	000bb783          	ld	a5,0(s7)
ffffffffc02025ae:	6522                	ld	a0,8(sp)
ffffffffc02025b0:	4585                	li	a1,1
ffffffffc02025b2:	739c                	ld	a5,32(a5)
ffffffffc02025b4:	9782                	jalr	a5
        intr_enable();
ffffffffc02025b6:	806fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025ba:	b56d                	j	ffffffffc0202464 <pmm_init+0x510>
        intr_disable();
ffffffffc02025bc:	806fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02025c0:	000bb783          	ld	a5,0(s7)
ffffffffc02025c4:	4585                	li	a1,1
ffffffffc02025c6:	8556                	mv	a0,s5
ffffffffc02025c8:	739c                	ld	a5,32(a5)
ffffffffc02025ca:	9782                	jalr	a5
        intr_enable();
ffffffffc02025cc:	ff1fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02025d0:	b59d                	j	ffffffffc0202436 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02025d2:	00004697          	auipc	a3,0x4
ffffffffc02025d6:	cae68693          	addi	a3,a3,-850 # ffffffffc0206280 <default_pmm_manager+0x518>
ffffffffc02025da:	00003617          	auipc	a2,0x3
ffffffffc02025de:	3de60613          	addi	a2,a2,990 # ffffffffc02059b8 <commands+0x798>
ffffffffc02025e2:	19e00593          	li	a1,414
ffffffffc02025e6:	00004517          	auipc	a0,0x4
ffffffffc02025ea:	8d250513          	addi	a0,a0,-1838 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02025ee:	e59fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02025f2:	00004697          	auipc	a3,0x4
ffffffffc02025f6:	c4e68693          	addi	a3,a3,-946 # ffffffffc0206240 <default_pmm_manager+0x4d8>
ffffffffc02025fa:	00003617          	auipc	a2,0x3
ffffffffc02025fe:	3be60613          	addi	a2,a2,958 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202602:	19d00593          	li	a1,413
ffffffffc0202606:	00004517          	auipc	a0,0x4
ffffffffc020260a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020260e:	e39fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202612:	86a2                	mv	a3,s0
ffffffffc0202614:	00003617          	auipc	a2,0x3
ffffffffc0202618:	78c60613          	addi	a2,a2,1932 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc020261c:	19d00593          	li	a1,413
ffffffffc0202620:	00004517          	auipc	a0,0x4
ffffffffc0202624:	89850513          	addi	a0,a0,-1896 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202628:	e1ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020262c:	c2cff0ef          	jal	ra,ffffffffc0201a58 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202630:	00004617          	auipc	a2,0x4
ffffffffc0202634:	81860613          	addi	a2,a2,-2024 # ffffffffc0205e48 <default_pmm_manager+0xe0>
ffffffffc0202638:	07f00593          	li	a1,127
ffffffffc020263c:	00004517          	auipc	a0,0x4
ffffffffc0202640:	87c50513          	addi	a0,a0,-1924 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202644:	e03fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202648:	00004617          	auipc	a2,0x4
ffffffffc020264c:	80060613          	addi	a2,a2,-2048 # ffffffffc0205e48 <default_pmm_manager+0xe0>
ffffffffc0202650:	0c300593          	li	a1,195
ffffffffc0202654:	00004517          	auipc	a0,0x4
ffffffffc0202658:	86450513          	addi	a0,a0,-1948 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020265c:	debfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202660:	00004697          	auipc	a3,0x4
ffffffffc0202664:	91868693          	addi	a3,a3,-1768 # ffffffffc0205f78 <default_pmm_manager+0x210>
ffffffffc0202668:	00003617          	auipc	a2,0x3
ffffffffc020266c:	35060613          	addi	a2,a2,848 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202670:	16100593          	li	a1,353
ffffffffc0202674:	00004517          	auipc	a0,0x4
ffffffffc0202678:	84450513          	addi	a0,a0,-1980 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020267c:	dcbfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202680:	00004697          	auipc	a3,0x4
ffffffffc0202684:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205f58 <default_pmm_manager+0x1f0>
ffffffffc0202688:	00003617          	auipc	a2,0x3
ffffffffc020268c:	33060613          	addi	a2,a2,816 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202690:	16000593          	li	a1,352
ffffffffc0202694:	00004517          	auipc	a0,0x4
ffffffffc0202698:	82450513          	addi	a0,a0,-2012 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020269c:	dabfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02026a0:	bd4ff0ef          	jal	ra,ffffffffc0201a74 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02026a4:	00004697          	auipc	a3,0x4
ffffffffc02026a8:	96468693          	addi	a3,a3,-1692 # ffffffffc0206008 <default_pmm_manager+0x2a0>
ffffffffc02026ac:	00003617          	auipc	a2,0x3
ffffffffc02026b0:	30c60613          	addi	a2,a2,780 # ffffffffc02059b8 <commands+0x798>
ffffffffc02026b4:	16900593          	li	a1,361
ffffffffc02026b8:	00004517          	auipc	a0,0x4
ffffffffc02026bc:	80050513          	addi	a0,a0,-2048 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02026c0:	d87fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026c4:	00004697          	auipc	a3,0x4
ffffffffc02026c8:	91468693          	addi	a3,a3,-1772 # ffffffffc0205fd8 <default_pmm_manager+0x270>
ffffffffc02026cc:	00003617          	auipc	a2,0x3
ffffffffc02026d0:	2ec60613          	addi	a2,a2,748 # ffffffffc02059b8 <commands+0x798>
ffffffffc02026d4:	16600593          	li	a1,358
ffffffffc02026d8:	00003517          	auipc	a0,0x3
ffffffffc02026dc:	7e050513          	addi	a0,a0,2016 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02026e0:	d67fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026e4:	00004697          	auipc	a3,0x4
ffffffffc02026e8:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0205fb0 <default_pmm_manager+0x248>
ffffffffc02026ec:	00003617          	auipc	a2,0x3
ffffffffc02026f0:	2cc60613          	addi	a2,a2,716 # ffffffffc02059b8 <commands+0x798>
ffffffffc02026f4:	16200593          	li	a1,354
ffffffffc02026f8:	00003517          	auipc	a0,0x3
ffffffffc02026fc:	7c050513          	addi	a0,a0,1984 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202700:	d47fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202704:	00004697          	auipc	a3,0x4
ffffffffc0202708:	98c68693          	addi	a3,a3,-1652 # ffffffffc0206090 <default_pmm_manager+0x328>
ffffffffc020270c:	00003617          	auipc	a2,0x3
ffffffffc0202710:	2ac60613          	addi	a2,a2,684 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202714:	17200593          	li	a1,370
ffffffffc0202718:	00003517          	auipc	a0,0x3
ffffffffc020271c:	7a050513          	addi	a0,a0,1952 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202720:	d27fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202724:	00004697          	auipc	a3,0x4
ffffffffc0202728:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0206130 <default_pmm_manager+0x3c8>
ffffffffc020272c:	00003617          	auipc	a2,0x3
ffffffffc0202730:	28c60613          	addi	a2,a2,652 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202734:	17700593          	li	a1,375
ffffffffc0202738:	00003517          	auipc	a0,0x3
ffffffffc020273c:	78050513          	addi	a0,a0,1920 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202740:	d07fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202744:	00004697          	auipc	a3,0x4
ffffffffc0202748:	92468693          	addi	a3,a3,-1756 # ffffffffc0206068 <default_pmm_manager+0x300>
ffffffffc020274c:	00003617          	auipc	a2,0x3
ffffffffc0202750:	26c60613          	addi	a2,a2,620 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202754:	16f00593          	li	a1,367
ffffffffc0202758:	00003517          	auipc	a0,0x3
ffffffffc020275c:	76050513          	addi	a0,a0,1888 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202760:	ce7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202764:	86d6                	mv	a3,s5
ffffffffc0202766:	00003617          	auipc	a2,0x3
ffffffffc020276a:	63a60613          	addi	a2,a2,1594 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc020276e:	16e00593          	li	a1,366
ffffffffc0202772:	00003517          	auipc	a0,0x3
ffffffffc0202776:	74650513          	addi	a0,a0,1862 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020277a:	ccdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020277e:	00004697          	auipc	a3,0x4
ffffffffc0202782:	94a68693          	addi	a3,a3,-1718 # ffffffffc02060c8 <default_pmm_manager+0x360>
ffffffffc0202786:	00003617          	auipc	a2,0x3
ffffffffc020278a:	23260613          	addi	a2,a2,562 # ffffffffc02059b8 <commands+0x798>
ffffffffc020278e:	17c00593          	li	a1,380
ffffffffc0202792:	00003517          	auipc	a0,0x3
ffffffffc0202796:	72650513          	addi	a0,a0,1830 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020279a:	cadfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020279e:	00004697          	auipc	a3,0x4
ffffffffc02027a2:	9f268693          	addi	a3,a3,-1550 # ffffffffc0206190 <default_pmm_manager+0x428>
ffffffffc02027a6:	00003617          	auipc	a2,0x3
ffffffffc02027aa:	21260613          	addi	a2,a2,530 # ffffffffc02059b8 <commands+0x798>
ffffffffc02027ae:	17b00593          	li	a1,379
ffffffffc02027b2:	00003517          	auipc	a0,0x3
ffffffffc02027b6:	70650513          	addi	a0,a0,1798 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02027ba:	c8dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02027be:	00004697          	auipc	a3,0x4
ffffffffc02027c2:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0206178 <default_pmm_manager+0x410>
ffffffffc02027c6:	00003617          	auipc	a2,0x3
ffffffffc02027ca:	1f260613          	addi	a2,a2,498 # ffffffffc02059b8 <commands+0x798>
ffffffffc02027ce:	17a00593          	li	a1,378
ffffffffc02027d2:	00003517          	auipc	a0,0x3
ffffffffc02027d6:	6e650513          	addi	a0,a0,1766 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02027da:	c6dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027de:	00004697          	auipc	a3,0x4
ffffffffc02027e2:	96a68693          	addi	a3,a3,-1686 # ffffffffc0206148 <default_pmm_manager+0x3e0>
ffffffffc02027e6:	00003617          	auipc	a2,0x3
ffffffffc02027ea:	1d260613          	addi	a2,a2,466 # ffffffffc02059b8 <commands+0x798>
ffffffffc02027ee:	17900593          	li	a1,377
ffffffffc02027f2:	00003517          	auipc	a0,0x3
ffffffffc02027f6:	6c650513          	addi	a0,a0,1734 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02027fa:	c4dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02027fe:	00004697          	auipc	a3,0x4
ffffffffc0202802:	b0268693          	addi	a3,a3,-1278 # ffffffffc0206300 <default_pmm_manager+0x598>
ffffffffc0202806:	00003617          	auipc	a2,0x3
ffffffffc020280a:	1b260613          	addi	a2,a2,434 # ffffffffc02059b8 <commands+0x798>
ffffffffc020280e:	1a700593          	li	a1,423
ffffffffc0202812:	00003517          	auipc	a0,0x3
ffffffffc0202816:	6a650513          	addi	a0,a0,1702 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020281a:	c2dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020281e:	00004697          	auipc	a3,0x4
ffffffffc0202822:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0206118 <default_pmm_manager+0x3b0>
ffffffffc0202826:	00003617          	auipc	a2,0x3
ffffffffc020282a:	19260613          	addi	a2,a2,402 # ffffffffc02059b8 <commands+0x798>
ffffffffc020282e:	17600593          	li	a1,374
ffffffffc0202832:	00003517          	auipc	a0,0x3
ffffffffc0202836:	68650513          	addi	a0,a0,1670 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020283a:	c0dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020283e:	00004697          	auipc	a3,0x4
ffffffffc0202842:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0206108 <default_pmm_manager+0x3a0>
ffffffffc0202846:	00003617          	auipc	a2,0x3
ffffffffc020284a:	17260613          	addi	a2,a2,370 # ffffffffc02059b8 <commands+0x798>
ffffffffc020284e:	17500593          	li	a1,373
ffffffffc0202852:	00003517          	auipc	a0,0x3
ffffffffc0202856:	66650513          	addi	a0,a0,1638 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020285a:	bedfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020285e:	00004697          	auipc	a3,0x4
ffffffffc0202862:	9a268693          	addi	a3,a3,-1630 # ffffffffc0206200 <default_pmm_manager+0x498>
ffffffffc0202866:	00003617          	auipc	a2,0x3
ffffffffc020286a:	15260613          	addi	a2,a2,338 # ffffffffc02059b8 <commands+0x798>
ffffffffc020286e:	1b800593          	li	a1,440
ffffffffc0202872:	00003517          	auipc	a0,0x3
ffffffffc0202876:	64650513          	addi	a0,a0,1606 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020287a:	bcdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020287e:	00004697          	auipc	a3,0x4
ffffffffc0202882:	87a68693          	addi	a3,a3,-1926 # ffffffffc02060f8 <default_pmm_manager+0x390>
ffffffffc0202886:	00003617          	auipc	a2,0x3
ffffffffc020288a:	13260613          	addi	a2,a2,306 # ffffffffc02059b8 <commands+0x798>
ffffffffc020288e:	17400593          	li	a1,372
ffffffffc0202892:	00003517          	auipc	a0,0x3
ffffffffc0202896:	62650513          	addi	a0,a0,1574 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc020289a:	badfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020289e:	00003697          	auipc	a3,0x3
ffffffffc02028a2:	7b268693          	addi	a3,a3,1970 # ffffffffc0206050 <default_pmm_manager+0x2e8>
ffffffffc02028a6:	00003617          	auipc	a2,0x3
ffffffffc02028aa:	11260613          	addi	a2,a2,274 # ffffffffc02059b8 <commands+0x798>
ffffffffc02028ae:	18100593          	li	a1,385
ffffffffc02028b2:	00003517          	auipc	a0,0x3
ffffffffc02028b6:	60650513          	addi	a0,a0,1542 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02028ba:	b8dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028be:	00004697          	auipc	a3,0x4
ffffffffc02028c2:	8ea68693          	addi	a3,a3,-1814 # ffffffffc02061a8 <default_pmm_manager+0x440>
ffffffffc02028c6:	00003617          	auipc	a2,0x3
ffffffffc02028ca:	0f260613          	addi	a2,a2,242 # ffffffffc02059b8 <commands+0x798>
ffffffffc02028ce:	17e00593          	li	a1,382
ffffffffc02028d2:	00003517          	auipc	a0,0x3
ffffffffc02028d6:	5e650513          	addi	a0,a0,1510 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02028da:	b6dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02028de:	00003697          	auipc	a3,0x3
ffffffffc02028e2:	75a68693          	addi	a3,a3,1882 # ffffffffc0206038 <default_pmm_manager+0x2d0>
ffffffffc02028e6:	00003617          	auipc	a2,0x3
ffffffffc02028ea:	0d260613          	addi	a2,a2,210 # ffffffffc02059b8 <commands+0x798>
ffffffffc02028ee:	17d00593          	li	a1,381
ffffffffc02028f2:	00003517          	auipc	a0,0x3
ffffffffc02028f6:	5c650513          	addi	a0,a0,1478 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02028fa:	b4dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02028fe:	00003617          	auipc	a2,0x3
ffffffffc0202902:	4a260613          	addi	a2,a2,1186 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0202906:	06900593          	li	a1,105
ffffffffc020290a:	00003517          	auipc	a0,0x3
ffffffffc020290e:	4be50513          	addi	a0,a0,1214 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0202912:	b35fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202916:	00004697          	auipc	a3,0x4
ffffffffc020291a:	8c268693          	addi	a3,a3,-1854 # ffffffffc02061d8 <default_pmm_manager+0x470>
ffffffffc020291e:	00003617          	auipc	a2,0x3
ffffffffc0202922:	09a60613          	addi	a2,a2,154 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202926:	18800593          	li	a1,392
ffffffffc020292a:	00003517          	auipc	a0,0x3
ffffffffc020292e:	58e50513          	addi	a0,a0,1422 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202932:	b15fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202936:	00004697          	auipc	a3,0x4
ffffffffc020293a:	85a68693          	addi	a3,a3,-1958 # ffffffffc0206190 <default_pmm_manager+0x428>
ffffffffc020293e:	00003617          	auipc	a2,0x3
ffffffffc0202942:	07a60613          	addi	a2,a2,122 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202946:	18600593          	li	a1,390
ffffffffc020294a:	00003517          	auipc	a0,0x3
ffffffffc020294e:	56e50513          	addi	a0,a0,1390 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202952:	af5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202956:	00004697          	auipc	a3,0x4
ffffffffc020295a:	86a68693          	addi	a3,a3,-1942 # ffffffffc02061c0 <default_pmm_manager+0x458>
ffffffffc020295e:	00003617          	auipc	a2,0x3
ffffffffc0202962:	05a60613          	addi	a2,a2,90 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202966:	18500593          	li	a1,389
ffffffffc020296a:	00003517          	auipc	a0,0x3
ffffffffc020296e:	54e50513          	addi	a0,a0,1358 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202972:	ad5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202976:	00004697          	auipc	a3,0x4
ffffffffc020297a:	81a68693          	addi	a3,a3,-2022 # ffffffffc0206190 <default_pmm_manager+0x428>
ffffffffc020297e:	00003617          	auipc	a2,0x3
ffffffffc0202982:	03a60613          	addi	a2,a2,58 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202986:	18200593          	li	a1,386
ffffffffc020298a:	00003517          	auipc	a0,0x3
ffffffffc020298e:	52e50513          	addi	a0,a0,1326 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202992:	ab5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202996:	00004697          	auipc	a3,0x4
ffffffffc020299a:	95268693          	addi	a3,a3,-1710 # ffffffffc02062e8 <default_pmm_manager+0x580>
ffffffffc020299e:	00003617          	auipc	a2,0x3
ffffffffc02029a2:	01a60613          	addi	a2,a2,26 # ffffffffc02059b8 <commands+0x798>
ffffffffc02029a6:	1a600593          	li	a1,422
ffffffffc02029aa:	00003517          	auipc	a0,0x3
ffffffffc02029ae:	50e50513          	addi	a0,a0,1294 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02029b2:	a95fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02029b6:	00004697          	auipc	a3,0x4
ffffffffc02029ba:	8fa68693          	addi	a3,a3,-1798 # ffffffffc02062b0 <default_pmm_manager+0x548>
ffffffffc02029be:	00003617          	auipc	a2,0x3
ffffffffc02029c2:	ffa60613          	addi	a2,a2,-6 # ffffffffc02059b8 <commands+0x798>
ffffffffc02029c6:	1a500593          	li	a1,421
ffffffffc02029ca:	00003517          	auipc	a0,0x3
ffffffffc02029ce:	4ee50513          	addi	a0,a0,1262 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02029d2:	a75fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02029d6:	00004697          	auipc	a3,0x4
ffffffffc02029da:	8c268693          	addi	a3,a3,-1854 # ffffffffc0206298 <default_pmm_manager+0x530>
ffffffffc02029de:	00003617          	auipc	a2,0x3
ffffffffc02029e2:	fda60613          	addi	a2,a2,-38 # ffffffffc02059b8 <commands+0x798>
ffffffffc02029e6:	1a100593          	li	a1,417
ffffffffc02029ea:	00003517          	auipc	a0,0x3
ffffffffc02029ee:	4ce50513          	addi	a0,a0,1230 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc02029f2:	a55fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02029f6:	00004697          	auipc	a3,0x4
ffffffffc02029fa:	80a68693          	addi	a3,a3,-2038 # ffffffffc0206200 <default_pmm_manager+0x498>
ffffffffc02029fe:	00003617          	auipc	a2,0x3
ffffffffc0202a02:	fba60613          	addi	a2,a2,-70 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202a06:	19000593          	li	a1,400
ffffffffc0202a0a:	00003517          	auipc	a0,0x3
ffffffffc0202a0e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202a12:	a35fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a16:	00003697          	auipc	a3,0x3
ffffffffc0202a1a:	62268693          	addi	a3,a3,1570 # ffffffffc0206038 <default_pmm_manager+0x2d0>
ffffffffc0202a1e:	00003617          	auipc	a2,0x3
ffffffffc0202a22:	f9a60613          	addi	a2,a2,-102 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202a26:	16a00593          	li	a1,362
ffffffffc0202a2a:	00003517          	auipc	a0,0x3
ffffffffc0202a2e:	48e50513          	addi	a0,a0,1166 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202a32:	a15fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202a36:	00003617          	auipc	a2,0x3
ffffffffc0202a3a:	36a60613          	addi	a2,a2,874 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0202a3e:	16d00593          	li	a1,365
ffffffffc0202a42:	00003517          	auipc	a0,0x3
ffffffffc0202a46:	47650513          	addi	a0,a0,1142 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202a4a:	9fdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202a4e:	00003697          	auipc	a3,0x3
ffffffffc0202a52:	60268693          	addi	a3,a3,1538 # ffffffffc0206050 <default_pmm_manager+0x2e8>
ffffffffc0202a56:	00003617          	auipc	a2,0x3
ffffffffc0202a5a:	f6260613          	addi	a2,a2,-158 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202a5e:	16b00593          	li	a1,363
ffffffffc0202a62:	00003517          	auipc	a0,0x3
ffffffffc0202a66:	45650513          	addi	a0,a0,1110 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202a6a:	9ddfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202a6e:	00003697          	auipc	a3,0x3
ffffffffc0202a72:	65a68693          	addi	a3,a3,1626 # ffffffffc02060c8 <default_pmm_manager+0x360>
ffffffffc0202a76:	00003617          	auipc	a2,0x3
ffffffffc0202a7a:	f4260613          	addi	a2,a2,-190 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202a7e:	17300593          	li	a1,371
ffffffffc0202a82:	00003517          	auipc	a0,0x3
ffffffffc0202a86:	43650513          	addi	a0,a0,1078 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202a8a:	9bdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a8e:	00004697          	auipc	a3,0x4
ffffffffc0202a92:	91a68693          	addi	a3,a3,-1766 # ffffffffc02063a8 <default_pmm_manager+0x640>
ffffffffc0202a96:	00003617          	auipc	a2,0x3
ffffffffc0202a9a:	f2260613          	addi	a2,a2,-222 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202a9e:	1af00593          	li	a1,431
ffffffffc0202aa2:	00003517          	auipc	a0,0x3
ffffffffc0202aa6:	41650513          	addi	a0,a0,1046 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202aaa:	99dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202aae:	00004697          	auipc	a3,0x4
ffffffffc0202ab2:	8c268693          	addi	a3,a3,-1854 # ffffffffc0206370 <default_pmm_manager+0x608>
ffffffffc0202ab6:	00003617          	auipc	a2,0x3
ffffffffc0202aba:	f0260613          	addi	a2,a2,-254 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202abe:	1ac00593          	li	a1,428
ffffffffc0202ac2:	00003517          	auipc	a0,0x3
ffffffffc0202ac6:	3f650513          	addi	a0,a0,1014 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202aca:	97dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202ace:	00004697          	auipc	a3,0x4
ffffffffc0202ad2:	87268693          	addi	a3,a3,-1934 # ffffffffc0206340 <default_pmm_manager+0x5d8>
ffffffffc0202ad6:	00003617          	auipc	a2,0x3
ffffffffc0202ada:	ee260613          	addi	a2,a2,-286 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202ade:	1a800593          	li	a1,424
ffffffffc0202ae2:	00003517          	auipc	a0,0x3
ffffffffc0202ae6:	3d650513          	addi	a0,a0,982 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202aea:	95dfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202aee <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202aee:	12058073          	sfence.vma	a1
}
ffffffffc0202af2:	8082                	ret

ffffffffc0202af4 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202af4:	7179                	addi	sp,sp,-48
ffffffffc0202af6:	e84a                	sd	s2,16(sp)
ffffffffc0202af8:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202afa:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202afc:	f022                	sd	s0,32(sp)
ffffffffc0202afe:	ec26                	sd	s1,24(sp)
ffffffffc0202b00:	e44e                	sd	s3,8(sp)
ffffffffc0202b02:	f406                	sd	ra,40(sp)
ffffffffc0202b04:	84ae                	mv	s1,a1
ffffffffc0202b06:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202b08:	f89fe0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0202b0c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202b0e:	cd09                	beqz	a0,ffffffffc0202b28 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202b10:	85aa                	mv	a1,a0
ffffffffc0202b12:	86ce                	mv	a3,s3
ffffffffc0202b14:	8626                	mv	a2,s1
ffffffffc0202b16:	854a                	mv	a0,s2
ffffffffc0202b18:	b46ff0ef          	jal	ra,ffffffffc0201e5e <page_insert>
ffffffffc0202b1c:	ed21                	bnez	a0,ffffffffc0202b74 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0202b1e:	00014797          	auipc	a5,0x14
ffffffffc0202b22:	a827a783          	lw	a5,-1406(a5) # ffffffffc02165a0 <swap_init_ok>
ffffffffc0202b26:	eb89                	bnez	a5,ffffffffc0202b38 <pgdir_alloc_page+0x44>
}
ffffffffc0202b28:	70a2                	ld	ra,40(sp)
ffffffffc0202b2a:	8522                	mv	a0,s0
ffffffffc0202b2c:	7402                	ld	s0,32(sp)
ffffffffc0202b2e:	64e2                	ld	s1,24(sp)
ffffffffc0202b30:	6942                	ld	s2,16(sp)
ffffffffc0202b32:	69a2                	ld	s3,8(sp)
ffffffffc0202b34:	6145                	addi	sp,sp,48
ffffffffc0202b36:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202b38:	4681                	li	a3,0
ffffffffc0202b3a:	8622                	mv	a2,s0
ffffffffc0202b3c:	85a6                	mv	a1,s1
ffffffffc0202b3e:	00014517          	auipc	a0,0x14
ffffffffc0202b42:	a6a53503          	ld	a0,-1430(a0) # ffffffffc02165a8 <check_mm_struct>
ffffffffc0202b46:	7c8000ef          	jal	ra,ffffffffc020330e <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202b4a:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202b4c:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202b4e:	4785                	li	a5,1
ffffffffc0202b50:	fcf70ce3          	beq	a4,a5,ffffffffc0202b28 <pgdir_alloc_page+0x34>
ffffffffc0202b54:	00004697          	auipc	a3,0x4
ffffffffc0202b58:	89c68693          	addi	a3,a3,-1892 # ffffffffc02063f0 <default_pmm_manager+0x688>
ffffffffc0202b5c:	00003617          	auipc	a2,0x3
ffffffffc0202b60:	e5c60613          	addi	a2,a2,-420 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202b64:	14800593          	li	a1,328
ffffffffc0202b68:	00003517          	auipc	a0,0x3
ffffffffc0202b6c:	35050513          	addi	a0,a0,848 # ffffffffc0205eb8 <default_pmm_manager+0x150>
ffffffffc0202b70:	8d7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b74:	100027f3          	csrr	a5,sstatus
ffffffffc0202b78:	8b89                	andi	a5,a5,2
ffffffffc0202b7a:	eb99                	bnez	a5,ffffffffc0202b90 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0202b7c:	00014797          	auipc	a5,0x14
ffffffffc0202b80:	a047b783          	ld	a5,-1532(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0202b84:	739c                	ld	a5,32(a5)
ffffffffc0202b86:	8522                	mv	a0,s0
ffffffffc0202b88:	4585                	li	a1,1
ffffffffc0202b8a:	9782                	jalr	a5
            return NULL;
ffffffffc0202b8c:	4401                	li	s0,0
ffffffffc0202b8e:	bf69                	j	ffffffffc0202b28 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0202b90:	a33fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b94:	00014797          	auipc	a5,0x14
ffffffffc0202b98:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc0216580 <pmm_manager>
ffffffffc0202b9c:	739c                	ld	a5,32(a5)
ffffffffc0202b9e:	8522                	mv	a0,s0
ffffffffc0202ba0:	4585                	li	a1,1
ffffffffc0202ba2:	9782                	jalr	a5
            return NULL;
ffffffffc0202ba4:	4401                	li	s0,0
        intr_enable();
ffffffffc0202ba6:	a17fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202baa:	bfbd                	j	ffffffffc0202b28 <pgdir_alloc_page+0x34>

ffffffffc0202bac <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202bac:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202bae:	00003617          	auipc	a2,0x3
ffffffffc0202bb2:	2c260613          	addi	a2,a2,706 # ffffffffc0205e70 <default_pmm_manager+0x108>
ffffffffc0202bb6:	06200593          	li	a1,98
ffffffffc0202bba:	00003517          	auipc	a0,0x3
ffffffffc0202bbe:	20e50513          	addi	a0,a0,526 # ffffffffc0205dc8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0202bc2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202bc4:	883fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202bc8 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202bc8:	7135                	addi	sp,sp,-160
ffffffffc0202bca:	ed06                	sd	ra,152(sp)
ffffffffc0202bcc:	e922                	sd	s0,144(sp)
ffffffffc0202bce:	e526                	sd	s1,136(sp)
ffffffffc0202bd0:	e14a                	sd	s2,128(sp)
ffffffffc0202bd2:	fcce                	sd	s3,120(sp)
ffffffffc0202bd4:	f8d2                	sd	s4,112(sp)
ffffffffc0202bd6:	f4d6                	sd	s5,104(sp)
ffffffffc0202bd8:	f0da                	sd	s6,96(sp)
ffffffffc0202bda:	ecde                	sd	s7,88(sp)
ffffffffc0202bdc:	e8e2                	sd	s8,80(sp)
ffffffffc0202bde:	e4e6                	sd	s9,72(sp)
ffffffffc0202be0:	e0ea                	sd	s10,64(sp)
ffffffffc0202be2:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202be4:	562010ef          	jal	ra,ffffffffc0204146 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202be8:	00014697          	auipc	a3,0x14
ffffffffc0202bec:	9a86b683          	ld	a3,-1624(a3) # ffffffffc0216590 <max_swap_offset>
ffffffffc0202bf0:	010007b7          	lui	a5,0x1000
ffffffffc0202bf4:	ff968713          	addi	a4,a3,-7
ffffffffc0202bf8:	17e1                	addi	a5,a5,-8
ffffffffc0202bfa:	42e7e063          	bltu	a5,a4,ffffffffc020301a <swap_init+0x452>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;//use first in first out Page Replacement Algorithm
ffffffffc0202bfe:	00008797          	auipc	a5,0x8
ffffffffc0202c02:	41278793          	addi	a5,a5,1042 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202c06:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;//use first in first out Page Replacement Algorithm
ffffffffc0202c08:	00014b97          	auipc	s7,0x14
ffffffffc0202c0c:	990b8b93          	addi	s7,s7,-1648 # ffffffffc0216598 <sm>
ffffffffc0202c10:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0202c14:	9702                	jalr	a4
ffffffffc0202c16:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0202c18:	c10d                	beqz	a0,ffffffffc0202c3a <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202c1a:	60ea                	ld	ra,152(sp)
ffffffffc0202c1c:	644a                	ld	s0,144(sp)
ffffffffc0202c1e:	64aa                	ld	s1,136(sp)
ffffffffc0202c20:	79e6                	ld	s3,120(sp)
ffffffffc0202c22:	7a46                	ld	s4,112(sp)
ffffffffc0202c24:	7aa6                	ld	s5,104(sp)
ffffffffc0202c26:	7b06                	ld	s6,96(sp)
ffffffffc0202c28:	6be6                	ld	s7,88(sp)
ffffffffc0202c2a:	6c46                	ld	s8,80(sp)
ffffffffc0202c2c:	6ca6                	ld	s9,72(sp)
ffffffffc0202c2e:	6d06                	ld	s10,64(sp)
ffffffffc0202c30:	7de2                	ld	s11,56(sp)
ffffffffc0202c32:	854a                	mv	a0,s2
ffffffffc0202c34:	690a                	ld	s2,128(sp)
ffffffffc0202c36:	610d                	addi	sp,sp,160
ffffffffc0202c38:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202c3a:	000bb783          	ld	a5,0(s7)
ffffffffc0202c3e:	00003517          	auipc	a0,0x3
ffffffffc0202c42:	7fa50513          	addi	a0,a0,2042 # ffffffffc0206438 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc0202c46:	00010417          	auipc	s0,0x10
ffffffffc0202c4a:	81a40413          	addi	s0,s0,-2022 # ffffffffc0212460 <free_area>
ffffffffc0202c4e:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202c50:	4785                	li	a5,1
ffffffffc0202c52:	00014717          	auipc	a4,0x14
ffffffffc0202c56:	94f72723          	sw	a5,-1714(a4) # ffffffffc02165a0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202c5a:	d26fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202c5e:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202c60:	4d01                	li	s10,0
ffffffffc0202c62:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c64:	32878b63          	beq	a5,s0,ffffffffc0202f9a <swap_init+0x3d2>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202c68:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202c6c:	8b09                	andi	a4,a4,2
ffffffffc0202c6e:	32070863          	beqz	a4,ffffffffc0202f9e <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc0202c72:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c76:	679c                	ld	a5,8(a5)
ffffffffc0202c78:	2d85                	addiw	s11,s11,1
ffffffffc0202c7a:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c7e:	fe8795e3          	bne	a5,s0,ffffffffc0202c68 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202c82:	84ea                	mv	s1,s10
ffffffffc0202c84:	edffe0ef          	jal	ra,ffffffffc0201b62 <nr_free_pages>
ffffffffc0202c88:	42951163          	bne	a0,s1,ffffffffc02030aa <swap_init+0x4e2>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202c8c:	866a                	mv	a2,s10
ffffffffc0202c8e:	85ee                	mv	a1,s11
ffffffffc0202c90:	00003517          	auipc	a0,0x3
ffffffffc0202c94:	7c050513          	addi	a0,a0,1984 # ffffffffc0206450 <default_pmm_manager+0x6e8>
ffffffffc0202c98:	ce8fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202c9c:	41f000ef          	jal	ra,ffffffffc02038ba <mm_create>
ffffffffc0202ca0:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202ca2:	46050463          	beqz	a0,ffffffffc020310a <swap_init+0x542>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202ca6:	00014797          	auipc	a5,0x14
ffffffffc0202caa:	90278793          	addi	a5,a5,-1790 # ffffffffc02165a8 <check_mm_struct>
ffffffffc0202cae:	6398                	ld	a4,0(a5)
ffffffffc0202cb0:	3c071d63          	bnez	a4,ffffffffc020308a <swap_init+0x4c2>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202cb4:	00014717          	auipc	a4,0x14
ffffffffc0202cb8:	8b470713          	addi	a4,a4,-1868 # ffffffffc0216568 <boot_pgdir>
ffffffffc0202cbc:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0202cc0:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0202cc2:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202cc6:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202cca:	42079063          	bnez	a5,ffffffffc02030ea <swap_init+0x522>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202cce:	6599                	lui	a1,0x6
ffffffffc0202cd0:	460d                	li	a2,3
ffffffffc0202cd2:	6505                	lui	a0,0x1
ffffffffc0202cd4:	42f000ef          	jal	ra,ffffffffc0203902 <vma_create>
ffffffffc0202cd8:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202cda:	52050463          	beqz	a0,ffffffffc0203202 <swap_init+0x63a>

     insert_vma_struct(mm, vma);
ffffffffc0202cde:	8556                	mv	a0,s5
ffffffffc0202ce0:	491000ef          	jal	ra,ffffffffc0203970 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202ce4:	00003517          	auipc	a0,0x3
ffffffffc0202ce8:	7dc50513          	addi	a0,a0,2012 # ffffffffc02064c0 <default_pmm_manager+0x758>
ffffffffc0202cec:	c94fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202cf0:	018ab503          	ld	a0,24(s5)
ffffffffc0202cf4:	4605                	li	a2,1
ffffffffc0202cf6:	6585                	lui	a1,0x1
ffffffffc0202cf8:	ea5fe0ef          	jal	ra,ffffffffc0201b9c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202cfc:	4c050363          	beqz	a0,ffffffffc02031c2 <swap_init+0x5fa>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202d00:	00004517          	auipc	a0,0x4
ffffffffc0202d04:	81050513          	addi	a0,a0,-2032 # ffffffffc0206510 <default_pmm_manager+0x7a8>
ffffffffc0202d08:	0000f497          	auipc	s1,0xf
ffffffffc0202d0c:	79048493          	addi	s1,s1,1936 # ffffffffc0212498 <check_rp>
ffffffffc0202d10:	c70fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d14:	0000f997          	auipc	s3,0xf
ffffffffc0202d18:	7a498993          	addi	s3,s3,1956 # ffffffffc02124b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202d1c:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0202d1e:	4505                	li	a0,1
ffffffffc0202d20:	d71fe0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
ffffffffc0202d24:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0202d28:	2c050963          	beqz	a0,ffffffffc0202ffa <swap_init+0x432>
ffffffffc0202d2c:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d2e:	8b89                	andi	a5,a5,2
ffffffffc0202d30:	32079d63          	bnez	a5,ffffffffc020306a <swap_init+0x4a2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d34:	0a21                	addi	s4,s4,8
ffffffffc0202d36:	ff3a14e3          	bne	s4,s3,ffffffffc0202d1e <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202d3a:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202d3c:	0000fa17          	auipc	s4,0xf
ffffffffc0202d40:	75ca0a13          	addi	s4,s4,1884 # ffffffffc0212498 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0202d44:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0202d46:	ec3e                	sd	a5,24(sp)
ffffffffc0202d48:	641c                	ld	a5,8(s0)
ffffffffc0202d4a:	e400                	sd	s0,8(s0)
ffffffffc0202d4c:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202d4e:	481c                	lw	a5,16(s0)
ffffffffc0202d50:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202d52:	0000f797          	auipc	a5,0xf
ffffffffc0202d56:	7007af23          	sw	zero,1822(a5) # ffffffffc0212470 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202d5a:	000a3503          	ld	a0,0(s4)
ffffffffc0202d5e:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d60:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0202d62:	dc1fe0ef          	jal	ra,ffffffffc0201b22 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d66:	ff3a1ae3          	bne	s4,s3,ffffffffc0202d5a <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d6a:	01042a03          	lw	s4,16(s0)
ffffffffc0202d6e:	4791                	li	a5,4
ffffffffc0202d70:	42fa1963          	bne	s4,a5,ffffffffc02031a2 <swap_init+0x5da>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202d74:	00004517          	auipc	a0,0x4
ffffffffc0202d78:	82450513          	addi	a0,a0,-2012 # ffffffffc0206598 <default_pmm_manager+0x830>
ffffffffc0202d7c:	c04fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d80:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202d82:	00014797          	auipc	a5,0x14
ffffffffc0202d86:	8207a723          	sw	zero,-2002(a5) # ffffffffc02165b0 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d8a:	4629                	li	a2,10
ffffffffc0202d8c:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202d90:	00014697          	auipc	a3,0x14
ffffffffc0202d94:	8206a683          	lw	a3,-2016(a3) # ffffffffc02165b0 <pgfault_num>
ffffffffc0202d98:	4585                	li	a1,1
ffffffffc0202d9a:	00014797          	auipc	a5,0x14
ffffffffc0202d9e:	81678793          	addi	a5,a5,-2026 # ffffffffc02165b0 <pgfault_num>
ffffffffc0202da2:	54b69063          	bne	a3,a1,ffffffffc02032e2 <swap_init+0x71a>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202da6:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202daa:	4398                	lw	a4,0(a5)
ffffffffc0202dac:	2701                	sext.w	a4,a4
ffffffffc0202dae:	3cd71a63          	bne	a4,a3,ffffffffc0203182 <swap_init+0x5ba>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202db2:	6689                	lui	a3,0x2
ffffffffc0202db4:	462d                	li	a2,11
ffffffffc0202db6:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202dba:	4398                	lw	a4,0(a5)
ffffffffc0202dbc:	4589                	li	a1,2
ffffffffc0202dbe:	2701                	sext.w	a4,a4
ffffffffc0202dc0:	4ab71163          	bne	a4,a1,ffffffffc0203262 <swap_init+0x69a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202dc4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202dc8:	4394                	lw	a3,0(a5)
ffffffffc0202dca:	2681                	sext.w	a3,a3
ffffffffc0202dcc:	4ae69b63          	bne	a3,a4,ffffffffc0203282 <swap_init+0x6ba>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202dd0:	668d                	lui	a3,0x3
ffffffffc0202dd2:	4631                	li	a2,12
ffffffffc0202dd4:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202dd8:	4398                	lw	a4,0(a5)
ffffffffc0202dda:	458d                	li	a1,3
ffffffffc0202ddc:	2701                	sext.w	a4,a4
ffffffffc0202dde:	4cb71263          	bne	a4,a1,ffffffffc02032a2 <swap_init+0x6da>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202de2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202de6:	4394                	lw	a3,0(a5)
ffffffffc0202de8:	2681                	sext.w	a3,a3
ffffffffc0202dea:	4ce69c63          	bne	a3,a4,ffffffffc02032c2 <swap_init+0x6fa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202dee:	6691                	lui	a3,0x4
ffffffffc0202df0:	4635                	li	a2,13
ffffffffc0202df2:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202df6:	4398                	lw	a4,0(a5)
ffffffffc0202df8:	2701                	sext.w	a4,a4
ffffffffc0202dfa:	43471463          	bne	a4,s4,ffffffffc0203222 <swap_init+0x65a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202dfe:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202e02:	439c                	lw	a5,0(a5)
ffffffffc0202e04:	2781                	sext.w	a5,a5
ffffffffc0202e06:	42e79e63          	bne	a5,a4,ffffffffc0203242 <swap_init+0x67a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202e0a:	481c                	lw	a5,16(s0)
ffffffffc0202e0c:	2a079f63          	bnez	a5,ffffffffc02030ca <swap_init+0x502>
ffffffffc0202e10:	0000f797          	auipc	a5,0xf
ffffffffc0202e14:	6a878793          	addi	a5,a5,1704 # ffffffffc02124b8 <swap_in_seq_no>
ffffffffc0202e18:	0000f717          	auipc	a4,0xf
ffffffffc0202e1c:	6c870713          	addi	a4,a4,1736 # ffffffffc02124e0 <swap_out_seq_no>
ffffffffc0202e20:	0000f617          	auipc	a2,0xf
ffffffffc0202e24:	6c060613          	addi	a2,a2,1728 # ffffffffc02124e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202e28:	56fd                	li	a3,-1
ffffffffc0202e2a:	c394                	sw	a3,0(a5)
ffffffffc0202e2c:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202e2e:	0791                	addi	a5,a5,4
ffffffffc0202e30:	0711                	addi	a4,a4,4
ffffffffc0202e32:	fec79ce3          	bne	a5,a2,ffffffffc0202e2a <swap_init+0x262>
ffffffffc0202e36:	0000f717          	auipc	a4,0xf
ffffffffc0202e3a:	64270713          	addi	a4,a4,1602 # ffffffffc0212478 <check_ptep>
ffffffffc0202e3e:	0000f697          	auipc	a3,0xf
ffffffffc0202e42:	65a68693          	addi	a3,a3,1626 # ffffffffc0212498 <check_rp>
ffffffffc0202e46:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202e48:	00013c17          	auipc	s8,0x13
ffffffffc0202e4c:	728c0c13          	addi	s8,s8,1832 # ffffffffc0216570 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e50:	00013c97          	auipc	s9,0x13
ffffffffc0202e54:	728c8c93          	addi	s9,s9,1832 # ffffffffc0216578 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202e58:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e5c:	4601                	li	a2,0
ffffffffc0202e5e:	855a                	mv	a0,s6
ffffffffc0202e60:	e836                	sd	a3,16(sp)
ffffffffc0202e62:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202e64:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e66:	d37fe0ef          	jal	ra,ffffffffc0201b9c <get_pte>
ffffffffc0202e6a:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202e6c:	65a2                	ld	a1,8(sp)
ffffffffc0202e6e:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e70:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0202e72:	1c050063          	beqz	a0,ffffffffc0203032 <swap_init+0x46a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202e76:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e78:	0017f613          	andi	a2,a5,1
ffffffffc0202e7c:	1c060b63          	beqz	a2,ffffffffc0203052 <swap_init+0x48a>
    if (PPN(pa) >= npage) {
ffffffffc0202e80:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e84:	078a                	slli	a5,a5,0x2
ffffffffc0202e86:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e88:	12c7fd63          	bgeu	a5,a2,ffffffffc0202fc2 <swap_init+0x3fa>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e8c:	00004617          	auipc	a2,0x4
ffffffffc0202e90:	29c60613          	addi	a2,a2,668 # ffffffffc0207128 <nbase>
ffffffffc0202e94:	00063a03          	ld	s4,0(a2)
ffffffffc0202e98:	000cb603          	ld	a2,0(s9)
ffffffffc0202e9c:	6288                	ld	a0,0(a3)
ffffffffc0202e9e:	414787b3          	sub	a5,a5,s4
ffffffffc0202ea2:	079a                	slli	a5,a5,0x6
ffffffffc0202ea4:	97b2                	add	a5,a5,a2
ffffffffc0202ea6:	12f51a63          	bne	a0,a5,ffffffffc0202fda <swap_init+0x412>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202eaa:	6785                	lui	a5,0x1
ffffffffc0202eac:	95be                	add	a1,a1,a5
ffffffffc0202eae:	6795                	lui	a5,0x5
ffffffffc0202eb0:	0721                	addi	a4,a4,8
ffffffffc0202eb2:	06a1                	addi	a3,a3,8
ffffffffc0202eb4:	faf592e3          	bne	a1,a5,ffffffffc0202e58 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	78850513          	addi	a0,a0,1928 # ffffffffc0206640 <default_pmm_manager+0x8d8>
ffffffffc0202ec0:	ac0fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202ec4:	000bb783          	ld	a5,0(s7)
ffffffffc0202ec8:	7f9c                	ld	a5,56(a5)
ffffffffc0202eca:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202ecc:	30051b63          	bnez	a0,ffffffffc02031e2 <swap_init+0x61a>

     nr_free = nr_free_store;
ffffffffc0202ed0:	77a2                	ld	a5,40(sp)
ffffffffc0202ed2:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202ed4:	67e2                	ld	a5,24(sp)
ffffffffc0202ed6:	e01c                	sd	a5,0(s0)
ffffffffc0202ed8:	7782                	ld	a5,32(sp)
ffffffffc0202eda:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202edc:	6088                	ld	a0,0(s1)
ffffffffc0202ede:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ee0:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0202ee2:	c41fe0ef          	jal	ra,ffffffffc0201b22 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ee6:	ff349be3          	bne	s1,s3,ffffffffc0202edc <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202eea:	8556                	mv	a0,s5
ffffffffc0202eec:	355000ef          	jal	ra,ffffffffc0203a40 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202ef0:	00013797          	auipc	a5,0x13
ffffffffc0202ef4:	67878793          	addi	a5,a5,1656 # ffffffffc0216568 <boot_pgdir>
ffffffffc0202ef8:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202efa:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202efe:	639c                	ld	a5,0(a5)
ffffffffc0202f00:	078a                	slli	a5,a5,0x2
ffffffffc0202f02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f04:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202fbe <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f08:	414786b3          	sub	a3,a5,s4
ffffffffc0202f0c:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202f0e:	8699                	srai	a3,a3,0x6
ffffffffc0202f10:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202f12:	00c69793          	slli	a5,a3,0xc
ffffffffc0202f16:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202f18:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f1c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202f1e:	22e7f663          	bgeu	a5,a4,ffffffffc020314a <swap_init+0x582>
     free_page(pde2page(pd0[0]));
ffffffffc0202f22:	00013797          	auipc	a5,0x13
ffffffffc0202f26:	6667b783          	ld	a5,1638(a5) # ffffffffc0216588 <va_pa_offset>
ffffffffc0202f2a:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f2c:	629c                	ld	a5,0(a3)
ffffffffc0202f2e:	078a                	slli	a5,a5,0x2
ffffffffc0202f30:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f32:	08e7f663          	bgeu	a5,a4,ffffffffc0202fbe <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f36:	414787b3          	sub	a5,a5,s4
ffffffffc0202f3a:	079a                	slli	a5,a5,0x6
ffffffffc0202f3c:	953e                	add	a0,a0,a5
ffffffffc0202f3e:	4585                	li	a1,1
ffffffffc0202f40:	be3fe0ef          	jal	ra,ffffffffc0201b22 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f44:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202f48:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f4c:	078a                	slli	a5,a5,0x2
ffffffffc0202f4e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f50:	06e7f763          	bgeu	a5,a4,ffffffffc0202fbe <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f54:	000cb503          	ld	a0,0(s9)
ffffffffc0202f58:	414787b3          	sub	a5,a5,s4
ffffffffc0202f5c:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202f5e:	4585                	li	a1,1
ffffffffc0202f60:	953e                	add	a0,a0,a5
ffffffffc0202f62:	bc1fe0ef          	jal	ra,ffffffffc0201b22 <free_pages>
     pgdir[0] = 0;
ffffffffc0202f66:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202f6a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202f6e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f70:	00878a63          	beq	a5,s0,ffffffffc0202f84 <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202f74:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f78:	679c                	ld	a5,8(a5)
ffffffffc0202f7a:	3dfd                	addiw	s11,s11,-1
ffffffffc0202f7c:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f80:	fe879ae3          	bne	a5,s0,ffffffffc0202f74 <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc0202f84:	1c0d9f63          	bnez	s11,ffffffffc0203162 <swap_init+0x59a>
     assert(total==0);
ffffffffc0202f88:	1a0d1163          	bnez	s10,ffffffffc020312a <swap_init+0x562>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f8c:	00003517          	auipc	a0,0x3
ffffffffc0202f90:	70450513          	addi	a0,a0,1796 # ffffffffc0206690 <default_pmm_manager+0x928>
ffffffffc0202f94:	9ecfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202f98:	b149                	j	ffffffffc0202c1a <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f9a:	4481                	li	s1,0
ffffffffc0202f9c:	b1e5                	j	ffffffffc0202c84 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0202f9e:	00003697          	auipc	a3,0x3
ffffffffc0202fa2:	a0a68693          	addi	a3,a3,-1526 # ffffffffc02059a8 <commands+0x788>
ffffffffc0202fa6:	00003617          	auipc	a2,0x3
ffffffffc0202faa:	a1260613          	addi	a2,a2,-1518 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202fae:	0bd00593          	li	a1,189
ffffffffc0202fb2:	00003517          	auipc	a0,0x3
ffffffffc0202fb6:	47650513          	addi	a0,a0,1142 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc0202fba:	c8cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202fbe:	befff0ef          	jal	ra,ffffffffc0202bac <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0202fc2:	00003617          	auipc	a2,0x3
ffffffffc0202fc6:	eae60613          	addi	a2,a2,-338 # ffffffffc0205e70 <default_pmm_manager+0x108>
ffffffffc0202fca:	06200593          	li	a1,98
ffffffffc0202fce:	00003517          	auipc	a0,0x3
ffffffffc0202fd2:	dfa50513          	addi	a0,a0,-518 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0202fd6:	c70fd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202fda:	00003697          	auipc	a3,0x3
ffffffffc0202fde:	63e68693          	addi	a3,a3,1598 # ffffffffc0206618 <default_pmm_manager+0x8b0>
ffffffffc0202fe2:	00003617          	auipc	a2,0x3
ffffffffc0202fe6:	9d660613          	addi	a2,a2,-1578 # ffffffffc02059b8 <commands+0x798>
ffffffffc0202fea:	0fd00593          	li	a1,253
ffffffffc0202fee:	00003517          	auipc	a0,0x3
ffffffffc0202ff2:	43a50513          	addi	a0,a0,1082 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc0202ff6:	c50fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202ffa:	00003697          	auipc	a3,0x3
ffffffffc0202ffe:	53e68693          	addi	a3,a3,1342 # ffffffffc0206538 <default_pmm_manager+0x7d0>
ffffffffc0203002:	00003617          	auipc	a2,0x3
ffffffffc0203006:	9b660613          	addi	a2,a2,-1610 # ffffffffc02059b8 <commands+0x798>
ffffffffc020300a:	0dd00593          	li	a1,221
ffffffffc020300e:	00003517          	auipc	a0,0x3
ffffffffc0203012:	41a50513          	addi	a0,a0,1050 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc0203016:	c30fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020301a:	00003617          	auipc	a2,0x3
ffffffffc020301e:	3ee60613          	addi	a2,a2,1006 # ffffffffc0206408 <default_pmm_manager+0x6a0>
ffffffffc0203022:	02a00593          	li	a1,42
ffffffffc0203026:	00003517          	auipc	a0,0x3
ffffffffc020302a:	40250513          	addi	a0,a0,1026 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020302e:	c18fd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203032:	00003697          	auipc	a3,0x3
ffffffffc0203036:	5ce68693          	addi	a3,a3,1486 # ffffffffc0206600 <default_pmm_manager+0x898>
ffffffffc020303a:	00003617          	auipc	a2,0x3
ffffffffc020303e:	97e60613          	addi	a2,a2,-1666 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203042:	0fc00593          	li	a1,252
ffffffffc0203046:	00003517          	auipc	a0,0x3
ffffffffc020304a:	3e250513          	addi	a0,a0,994 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020304e:	bf8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203052:	00003617          	auipc	a2,0x3
ffffffffc0203056:	e3e60613          	addi	a2,a2,-450 # ffffffffc0205e90 <default_pmm_manager+0x128>
ffffffffc020305a:	07400593          	li	a1,116
ffffffffc020305e:	00003517          	auipc	a0,0x3
ffffffffc0203062:	d6a50513          	addi	a0,a0,-662 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0203066:	be0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020306a:	00003697          	auipc	a3,0x3
ffffffffc020306e:	4e668693          	addi	a3,a3,1254 # ffffffffc0206550 <default_pmm_manager+0x7e8>
ffffffffc0203072:	00003617          	auipc	a2,0x3
ffffffffc0203076:	94660613          	addi	a2,a2,-1722 # ffffffffc02059b8 <commands+0x798>
ffffffffc020307a:	0de00593          	li	a1,222
ffffffffc020307e:	00003517          	auipc	a0,0x3
ffffffffc0203082:	3aa50513          	addi	a0,a0,938 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc0203086:	bc0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020308a:	00003697          	auipc	a3,0x3
ffffffffc020308e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0206488 <default_pmm_manager+0x720>
ffffffffc0203092:	00003617          	auipc	a2,0x3
ffffffffc0203096:	92660613          	addi	a2,a2,-1754 # ffffffffc02059b8 <commands+0x798>
ffffffffc020309a:	0c800593          	li	a1,200
ffffffffc020309e:	00003517          	auipc	a0,0x3
ffffffffc02030a2:	38a50513          	addi	a0,a0,906 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02030a6:	ba0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total == nr_free_pages());
ffffffffc02030aa:	00003697          	auipc	a3,0x3
ffffffffc02030ae:	93e68693          	addi	a3,a3,-1730 # ffffffffc02059e8 <commands+0x7c8>
ffffffffc02030b2:	00003617          	auipc	a2,0x3
ffffffffc02030b6:	90660613          	addi	a2,a2,-1786 # ffffffffc02059b8 <commands+0x798>
ffffffffc02030ba:	0c000593          	li	a1,192
ffffffffc02030be:	00003517          	auipc	a0,0x3
ffffffffc02030c2:	36a50513          	addi	a0,a0,874 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02030c6:	b80fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert( nr_free == 0);         
ffffffffc02030ca:	00003697          	auipc	a3,0x3
ffffffffc02030ce:	ac668693          	addi	a3,a3,-1338 # ffffffffc0205b90 <commands+0x970>
ffffffffc02030d2:	00003617          	auipc	a2,0x3
ffffffffc02030d6:	8e660613          	addi	a2,a2,-1818 # ffffffffc02059b8 <commands+0x798>
ffffffffc02030da:	0f400593          	li	a1,244
ffffffffc02030de:	00003517          	auipc	a0,0x3
ffffffffc02030e2:	34a50513          	addi	a0,a0,842 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02030e6:	b60fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02030ea:	00003697          	auipc	a3,0x3
ffffffffc02030ee:	3b668693          	addi	a3,a3,950 # ffffffffc02064a0 <default_pmm_manager+0x738>
ffffffffc02030f2:	00003617          	auipc	a2,0x3
ffffffffc02030f6:	8c660613          	addi	a2,a2,-1850 # ffffffffc02059b8 <commands+0x798>
ffffffffc02030fa:	0cd00593          	li	a1,205
ffffffffc02030fe:	00003517          	auipc	a0,0x3
ffffffffc0203102:	32a50513          	addi	a0,a0,810 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc0203106:	b40fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(mm != NULL);
ffffffffc020310a:	00003697          	auipc	a3,0x3
ffffffffc020310e:	36e68693          	addi	a3,a3,878 # ffffffffc0206478 <default_pmm_manager+0x710>
ffffffffc0203112:	00003617          	auipc	a2,0x3
ffffffffc0203116:	8a660613          	addi	a2,a2,-1882 # ffffffffc02059b8 <commands+0x798>
ffffffffc020311a:	0c500593          	li	a1,197
ffffffffc020311e:	00003517          	auipc	a0,0x3
ffffffffc0203122:	30a50513          	addi	a0,a0,778 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc0203126:	b20fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total==0);
ffffffffc020312a:	00003697          	auipc	a3,0x3
ffffffffc020312e:	55668693          	addi	a3,a3,1366 # ffffffffc0206680 <default_pmm_manager+0x918>
ffffffffc0203132:	00003617          	auipc	a2,0x3
ffffffffc0203136:	88660613          	addi	a2,a2,-1914 # ffffffffc02059b8 <commands+0x798>
ffffffffc020313a:	11d00593          	li	a1,285
ffffffffc020313e:	00003517          	auipc	a0,0x3
ffffffffc0203142:	2ea50513          	addi	a0,a0,746 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc0203146:	b00fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc020314a:	00003617          	auipc	a2,0x3
ffffffffc020314e:	c5660613          	addi	a2,a2,-938 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0203152:	06900593          	li	a1,105
ffffffffc0203156:	00003517          	auipc	a0,0x3
ffffffffc020315a:	c7250513          	addi	a0,a0,-910 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc020315e:	ae8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(count==0);
ffffffffc0203162:	00003697          	auipc	a3,0x3
ffffffffc0203166:	50e68693          	addi	a3,a3,1294 # ffffffffc0206670 <default_pmm_manager+0x908>
ffffffffc020316a:	00003617          	auipc	a2,0x3
ffffffffc020316e:	84e60613          	addi	a2,a2,-1970 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203172:	11c00593          	li	a1,284
ffffffffc0203176:	00003517          	auipc	a0,0x3
ffffffffc020317a:	2b250513          	addi	a0,a0,690 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020317e:	ac8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc0203182:	00003697          	auipc	a3,0x3
ffffffffc0203186:	43e68693          	addi	a3,a3,1086 # ffffffffc02065c0 <default_pmm_manager+0x858>
ffffffffc020318a:	00003617          	auipc	a2,0x3
ffffffffc020318e:	82e60613          	addi	a2,a2,-2002 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203192:	09600593          	li	a1,150
ffffffffc0203196:	00003517          	auipc	a0,0x3
ffffffffc020319a:	29250513          	addi	a0,a0,658 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020319e:	aa8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02031a2:	00003697          	auipc	a3,0x3
ffffffffc02031a6:	3ce68693          	addi	a3,a3,974 # ffffffffc0206570 <default_pmm_manager+0x808>
ffffffffc02031aa:	00003617          	auipc	a2,0x3
ffffffffc02031ae:	80e60613          	addi	a2,a2,-2034 # ffffffffc02059b8 <commands+0x798>
ffffffffc02031b2:	0eb00593          	li	a1,235
ffffffffc02031b6:	00003517          	auipc	a0,0x3
ffffffffc02031ba:	27250513          	addi	a0,a0,626 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02031be:	a88fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02031c2:	00003697          	auipc	a3,0x3
ffffffffc02031c6:	33668693          	addi	a3,a3,822 # ffffffffc02064f8 <default_pmm_manager+0x790>
ffffffffc02031ca:	00002617          	auipc	a2,0x2
ffffffffc02031ce:	7ee60613          	addi	a2,a2,2030 # ffffffffc02059b8 <commands+0x798>
ffffffffc02031d2:	0d800593          	li	a1,216
ffffffffc02031d6:	00003517          	auipc	a0,0x3
ffffffffc02031da:	25250513          	addi	a0,a0,594 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02031de:	a68fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(ret==0);
ffffffffc02031e2:	00003697          	auipc	a3,0x3
ffffffffc02031e6:	48668693          	addi	a3,a3,1158 # ffffffffc0206668 <default_pmm_manager+0x900>
ffffffffc02031ea:	00002617          	auipc	a2,0x2
ffffffffc02031ee:	7ce60613          	addi	a2,a2,1998 # ffffffffc02059b8 <commands+0x798>
ffffffffc02031f2:	10300593          	li	a1,259
ffffffffc02031f6:	00003517          	auipc	a0,0x3
ffffffffc02031fa:	23250513          	addi	a0,a0,562 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02031fe:	a48fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(vma != NULL);
ffffffffc0203202:	00003697          	auipc	a3,0x3
ffffffffc0203206:	2ae68693          	addi	a3,a3,686 # ffffffffc02064b0 <default_pmm_manager+0x748>
ffffffffc020320a:	00002617          	auipc	a2,0x2
ffffffffc020320e:	7ae60613          	addi	a2,a2,1966 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203212:	0d000593          	li	a1,208
ffffffffc0203216:	00003517          	auipc	a0,0x3
ffffffffc020321a:	21250513          	addi	a0,a0,530 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020321e:	a28fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc0203222:	00003697          	auipc	a3,0x3
ffffffffc0203226:	3ce68693          	addi	a3,a3,974 # ffffffffc02065f0 <default_pmm_manager+0x888>
ffffffffc020322a:	00002617          	auipc	a2,0x2
ffffffffc020322e:	78e60613          	addi	a2,a2,1934 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203232:	0a000593          	li	a1,160
ffffffffc0203236:	00003517          	auipc	a0,0x3
ffffffffc020323a:	1f250513          	addi	a0,a0,498 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020323e:	a08fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc0203242:	00003697          	auipc	a3,0x3
ffffffffc0203246:	3ae68693          	addi	a3,a3,942 # ffffffffc02065f0 <default_pmm_manager+0x888>
ffffffffc020324a:	00002617          	auipc	a2,0x2
ffffffffc020324e:	76e60613          	addi	a2,a2,1902 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203252:	0a200593          	li	a1,162
ffffffffc0203256:	00003517          	auipc	a0,0x3
ffffffffc020325a:	1d250513          	addi	a0,a0,466 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020325e:	9e8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc0203262:	00003697          	auipc	a3,0x3
ffffffffc0203266:	36e68693          	addi	a3,a3,878 # ffffffffc02065d0 <default_pmm_manager+0x868>
ffffffffc020326a:	00002617          	auipc	a2,0x2
ffffffffc020326e:	74e60613          	addi	a2,a2,1870 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203272:	09800593          	li	a1,152
ffffffffc0203276:	00003517          	auipc	a0,0x3
ffffffffc020327a:	1b250513          	addi	a0,a0,434 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020327e:	9c8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc0203282:	00003697          	auipc	a3,0x3
ffffffffc0203286:	34e68693          	addi	a3,a3,846 # ffffffffc02065d0 <default_pmm_manager+0x868>
ffffffffc020328a:	00002617          	auipc	a2,0x2
ffffffffc020328e:	72e60613          	addi	a2,a2,1838 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203292:	09a00593          	li	a1,154
ffffffffc0203296:	00003517          	auipc	a0,0x3
ffffffffc020329a:	19250513          	addi	a0,a0,402 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020329e:	9a8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc02032a2:	00003697          	auipc	a3,0x3
ffffffffc02032a6:	33e68693          	addi	a3,a3,830 # ffffffffc02065e0 <default_pmm_manager+0x878>
ffffffffc02032aa:	00002617          	auipc	a2,0x2
ffffffffc02032ae:	70e60613          	addi	a2,a2,1806 # ffffffffc02059b8 <commands+0x798>
ffffffffc02032b2:	09c00593          	li	a1,156
ffffffffc02032b6:	00003517          	auipc	a0,0x3
ffffffffc02032ba:	17250513          	addi	a0,a0,370 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02032be:	988fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc02032c2:	00003697          	auipc	a3,0x3
ffffffffc02032c6:	31e68693          	addi	a3,a3,798 # ffffffffc02065e0 <default_pmm_manager+0x878>
ffffffffc02032ca:	00002617          	auipc	a2,0x2
ffffffffc02032ce:	6ee60613          	addi	a2,a2,1774 # ffffffffc02059b8 <commands+0x798>
ffffffffc02032d2:	09e00593          	li	a1,158
ffffffffc02032d6:	00003517          	auipc	a0,0x3
ffffffffc02032da:	15250513          	addi	a0,a0,338 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02032de:	968fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc02032e2:	00003697          	auipc	a3,0x3
ffffffffc02032e6:	2de68693          	addi	a3,a3,734 # ffffffffc02065c0 <default_pmm_manager+0x858>
ffffffffc02032ea:	00002617          	auipc	a2,0x2
ffffffffc02032ee:	6ce60613          	addi	a2,a2,1742 # ffffffffc02059b8 <commands+0x798>
ffffffffc02032f2:	09400593          	li	a1,148
ffffffffc02032f6:	00003517          	auipc	a0,0x3
ffffffffc02032fa:	13250513          	addi	a0,a0,306 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02032fe:	948fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203302 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203302:	00013797          	auipc	a5,0x13
ffffffffc0203306:	2967b783          	ld	a5,662(a5) # ffffffffc0216598 <sm>
ffffffffc020330a:	6b9c                	ld	a5,16(a5)
ffffffffc020330c:	8782                	jr	a5

ffffffffc020330e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020330e:	00013797          	auipc	a5,0x13
ffffffffc0203312:	28a7b783          	ld	a5,650(a5) # ffffffffc0216598 <sm>
ffffffffc0203316:	739c                	ld	a5,32(a5)
ffffffffc0203318:	8782                	jr	a5

ffffffffc020331a <swap_out>:
{
ffffffffc020331a:	711d                	addi	sp,sp,-96
ffffffffc020331c:	ec86                	sd	ra,88(sp)
ffffffffc020331e:	e8a2                	sd	s0,80(sp)
ffffffffc0203320:	e4a6                	sd	s1,72(sp)
ffffffffc0203322:	e0ca                	sd	s2,64(sp)
ffffffffc0203324:	fc4e                	sd	s3,56(sp)
ffffffffc0203326:	f852                	sd	s4,48(sp)
ffffffffc0203328:	f456                	sd	s5,40(sp)
ffffffffc020332a:	f05a                	sd	s6,32(sp)
ffffffffc020332c:	ec5e                	sd	s7,24(sp)
ffffffffc020332e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203330:	cde9                	beqz	a1,ffffffffc020340a <swap_out+0xf0>
ffffffffc0203332:	8a2e                	mv	s4,a1
ffffffffc0203334:	892a                	mv	s2,a0
ffffffffc0203336:	8ab2                	mv	s5,a2
ffffffffc0203338:	4401                	li	s0,0
ffffffffc020333a:	00013997          	auipc	s3,0x13
ffffffffc020333e:	25e98993          	addi	s3,s3,606 # ffffffffc0216598 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203342:	00003b17          	auipc	s6,0x3
ffffffffc0203346:	3ceb0b13          	addi	s6,s6,974 # ffffffffc0206710 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc020334a:	00003b97          	auipc	s7,0x3
ffffffffc020334e:	3aeb8b93          	addi	s7,s7,942 # ffffffffc02066f8 <default_pmm_manager+0x990>
ffffffffc0203352:	a825                	j	ffffffffc020338a <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203354:	67a2                	ld	a5,8(sp)
ffffffffc0203356:	8626                	mv	a2,s1
ffffffffc0203358:	85a2                	mv	a1,s0
ffffffffc020335a:	7f94                	ld	a3,56(a5)
ffffffffc020335c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc020335e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203360:	82b1                	srli	a3,a3,0xc
ffffffffc0203362:	0685                	addi	a3,a3,1
ffffffffc0203364:	e1dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203368:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020336a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020336c:	7d1c                	ld	a5,56(a0)
ffffffffc020336e:	83b1                	srli	a5,a5,0xc
ffffffffc0203370:	0785                	addi	a5,a5,1
ffffffffc0203372:	07a2                	slli	a5,a5,0x8
ffffffffc0203374:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203378:	faafe0ef          	jal	ra,ffffffffc0201b22 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020337c:	01893503          	ld	a0,24(s2)
ffffffffc0203380:	85a6                	mv	a1,s1
ffffffffc0203382:	f6cff0ef          	jal	ra,ffffffffc0202aee <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203386:	048a0d63          	beq	s4,s0,ffffffffc02033e0 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020338a:	0009b783          	ld	a5,0(s3)
ffffffffc020338e:	8656                	mv	a2,s5
ffffffffc0203390:	002c                	addi	a1,sp,8
ffffffffc0203392:	7b9c                	ld	a5,48(a5)
ffffffffc0203394:	854a                	mv	a0,s2
ffffffffc0203396:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203398:	e12d                	bnez	a0,ffffffffc02033fa <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020339a:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020339c:	01893503          	ld	a0,24(s2)
ffffffffc02033a0:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02033a2:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02033a4:	85a6                	mv	a1,s1
ffffffffc02033a6:	ff6fe0ef          	jal	ra,ffffffffc0201b9c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02033aa:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02033ac:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02033ae:	8b85                	andi	a5,a5,1
ffffffffc02033b0:	cfb9                	beqz	a5,ffffffffc020340e <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02033b2:	65a2                	ld	a1,8(sp)
ffffffffc02033b4:	7d9c                	ld	a5,56(a1)
ffffffffc02033b6:	83b1                	srli	a5,a5,0xc
ffffffffc02033b8:	0785                	addi	a5,a5,1
ffffffffc02033ba:	00879513          	slli	a0,a5,0x8
ffffffffc02033be:	64f000ef          	jal	ra,ffffffffc020420c <swapfs_write>
ffffffffc02033c2:	d949                	beqz	a0,ffffffffc0203354 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02033c4:	855e                	mv	a0,s7
ffffffffc02033c6:	dbbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02033ca:	0009b783          	ld	a5,0(s3)
ffffffffc02033ce:	6622                	ld	a2,8(sp)
ffffffffc02033d0:	4681                	li	a3,0
ffffffffc02033d2:	739c                	ld	a5,32(a5)
ffffffffc02033d4:	85a6                	mv	a1,s1
ffffffffc02033d6:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02033d8:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02033da:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02033dc:	fa8a17e3          	bne	s4,s0,ffffffffc020338a <swap_out+0x70>
}
ffffffffc02033e0:	60e6                	ld	ra,88(sp)
ffffffffc02033e2:	8522                	mv	a0,s0
ffffffffc02033e4:	6446                	ld	s0,80(sp)
ffffffffc02033e6:	64a6                	ld	s1,72(sp)
ffffffffc02033e8:	6906                	ld	s2,64(sp)
ffffffffc02033ea:	79e2                	ld	s3,56(sp)
ffffffffc02033ec:	7a42                	ld	s4,48(sp)
ffffffffc02033ee:	7aa2                	ld	s5,40(sp)
ffffffffc02033f0:	7b02                	ld	s6,32(sp)
ffffffffc02033f2:	6be2                	ld	s7,24(sp)
ffffffffc02033f4:	6c42                	ld	s8,16(sp)
ffffffffc02033f6:	6125                	addi	sp,sp,96
ffffffffc02033f8:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02033fa:	85a2                	mv	a1,s0
ffffffffc02033fc:	00003517          	auipc	a0,0x3
ffffffffc0203400:	2b450513          	addi	a0,a0,692 # ffffffffc02066b0 <default_pmm_manager+0x948>
ffffffffc0203404:	d7dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203408:	bfe1                	j	ffffffffc02033e0 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020340a:	4401                	li	s0,0
ffffffffc020340c:	bfd1                	j	ffffffffc02033e0 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc020340e:	00003697          	auipc	a3,0x3
ffffffffc0203412:	2d268693          	addi	a3,a3,722 # ffffffffc02066e0 <default_pmm_manager+0x978>
ffffffffc0203416:	00002617          	auipc	a2,0x2
ffffffffc020341a:	5a260613          	addi	a2,a2,1442 # ffffffffc02059b8 <commands+0x798>
ffffffffc020341e:	06900593          	li	a1,105
ffffffffc0203422:	00003517          	auipc	a0,0x3
ffffffffc0203426:	00650513          	addi	a0,a0,6 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc020342a:	81cfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020342e <swap_in>:
{
ffffffffc020342e:	7179                	addi	sp,sp,-48
ffffffffc0203430:	e84a                	sd	s2,16(sp)
ffffffffc0203432:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203434:	4505                	li	a0,1
{
ffffffffc0203436:	ec26                	sd	s1,24(sp)
ffffffffc0203438:	e44e                	sd	s3,8(sp)
ffffffffc020343a:	f406                	sd	ra,40(sp)
ffffffffc020343c:	f022                	sd	s0,32(sp)
ffffffffc020343e:	84ae                	mv	s1,a1
ffffffffc0203440:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203442:	e4efe0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203446:	c129                	beqz	a0,ffffffffc0203488 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203448:	842a                	mv	s0,a0
ffffffffc020344a:	01893503          	ld	a0,24(s2)
ffffffffc020344e:	4601                	li	a2,0
ffffffffc0203450:	85a6                	mv	a1,s1
ffffffffc0203452:	f4afe0ef          	jal	ra,ffffffffc0201b9c <get_pte>
ffffffffc0203456:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203458:	6108                	ld	a0,0(a0)
ffffffffc020345a:	85a2                	mv	a1,s0
ffffffffc020345c:	523000ef          	jal	ra,ffffffffc020417e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203460:	00093583          	ld	a1,0(s2)
ffffffffc0203464:	8626                	mv	a2,s1
ffffffffc0203466:	00003517          	auipc	a0,0x3
ffffffffc020346a:	2fa50513          	addi	a0,a0,762 # ffffffffc0206760 <default_pmm_manager+0x9f8>
ffffffffc020346e:	81a1                	srli	a1,a1,0x8
ffffffffc0203470:	d11fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203474:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203476:	0089b023          	sd	s0,0(s3)
}
ffffffffc020347a:	7402                	ld	s0,32(sp)
ffffffffc020347c:	64e2                	ld	s1,24(sp)
ffffffffc020347e:	6942                	ld	s2,16(sp)
ffffffffc0203480:	69a2                	ld	s3,8(sp)
ffffffffc0203482:	4501                	li	a0,0
ffffffffc0203484:	6145                	addi	sp,sp,48
ffffffffc0203486:	8082                	ret
     assert(result!=NULL);
ffffffffc0203488:	00003697          	auipc	a3,0x3
ffffffffc020348c:	2c868693          	addi	a3,a3,712 # ffffffffc0206750 <default_pmm_manager+0x9e8>
ffffffffc0203490:	00002617          	auipc	a2,0x2
ffffffffc0203494:	52860613          	addi	a2,a2,1320 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203498:	07f00593          	li	a1,127
ffffffffc020349c:	00003517          	auipc	a0,0x3
ffffffffc02034a0:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206428 <default_pmm_manager+0x6c0>
ffffffffc02034a4:	fa3fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02034a8 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02034a8:	0000f797          	auipc	a5,0xf
ffffffffc02034ac:	06078793          	addi	a5,a5,96 # ffffffffc0212508 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02034b0:	f51c                	sd	a5,40(a0)
ffffffffc02034b2:	e79c                	sd	a5,8(a5)
ffffffffc02034b4:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02034b6:	4501                	li	a0,0
ffffffffc02034b8:	8082                	ret

ffffffffc02034ba <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02034ba:	4501                	li	a0,0
ffffffffc02034bc:	8082                	ret

ffffffffc02034be <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02034be:	4501                	li	a0,0
ffffffffc02034c0:	8082                	ret

ffffffffc02034c2 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02034c2:	4501                	li	a0,0
ffffffffc02034c4:	8082                	ret

ffffffffc02034c6 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02034c6:	711d                	addi	sp,sp,-96
ffffffffc02034c8:	fc4e                	sd	s3,56(sp)
ffffffffc02034ca:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034cc:	00003517          	auipc	a0,0x3
ffffffffc02034d0:	2d450513          	addi	a0,a0,724 # ffffffffc02067a0 <default_pmm_manager+0xa38>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034d4:	698d                	lui	s3,0x3
ffffffffc02034d6:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02034d8:	e0ca                	sd	s2,64(sp)
ffffffffc02034da:	ec86                	sd	ra,88(sp)
ffffffffc02034dc:	e8a2                	sd	s0,80(sp)
ffffffffc02034de:	e4a6                	sd	s1,72(sp)
ffffffffc02034e0:	f456                	sd	s5,40(sp)
ffffffffc02034e2:	f05a                	sd	s6,32(sp)
ffffffffc02034e4:	ec5e                	sd	s7,24(sp)
ffffffffc02034e6:	e862                	sd	s8,16(sp)
ffffffffc02034e8:	e466                	sd	s9,8(sp)
ffffffffc02034ea:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034ec:	c95fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034f0:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02034f4:	00013917          	auipc	s2,0x13
ffffffffc02034f8:	0bc92903          	lw	s2,188(s2) # ffffffffc02165b0 <pgfault_num>
ffffffffc02034fc:	4791                	li	a5,4
ffffffffc02034fe:	14f91e63          	bne	s2,a5,ffffffffc020365a <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203502:	00003517          	auipc	a0,0x3
ffffffffc0203506:	2de50513          	addi	a0,a0,734 # ffffffffc02067e0 <default_pmm_manager+0xa78>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020350a:	6a85                	lui	s5,0x1
ffffffffc020350c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020350e:	c73fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203512:	00013417          	auipc	s0,0x13
ffffffffc0203516:	09e40413          	addi	s0,s0,158 # ffffffffc02165b0 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020351a:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc020351e:	4004                	lw	s1,0(s0)
ffffffffc0203520:	2481                	sext.w	s1,s1
ffffffffc0203522:	2b249c63          	bne	s1,s2,ffffffffc02037da <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203526:	00003517          	auipc	a0,0x3
ffffffffc020352a:	2e250513          	addi	a0,a0,738 # ffffffffc0206808 <default_pmm_manager+0xaa0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020352e:	6b91                	lui	s7,0x4
ffffffffc0203530:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203532:	c4ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203536:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020353a:	00042903          	lw	s2,0(s0)
ffffffffc020353e:	2901                	sext.w	s2,s2
ffffffffc0203540:	26991d63          	bne	s2,s1,ffffffffc02037ba <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203544:	00003517          	auipc	a0,0x3
ffffffffc0203548:	2ec50513          	addi	a0,a0,748 # ffffffffc0206830 <default_pmm_manager+0xac8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020354c:	6c89                	lui	s9,0x2
ffffffffc020354e:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203550:	c31fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203554:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203558:	401c                	lw	a5,0(s0)
ffffffffc020355a:	2781                	sext.w	a5,a5
ffffffffc020355c:	23279f63          	bne	a5,s2,ffffffffc020379a <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203560:	00003517          	auipc	a0,0x3
ffffffffc0203564:	2f850513          	addi	a0,a0,760 # ffffffffc0206858 <default_pmm_manager+0xaf0>
ffffffffc0203568:	c19fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020356c:	6795                	lui	a5,0x5
ffffffffc020356e:	4739                	li	a4,14
ffffffffc0203570:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203574:	4004                	lw	s1,0(s0)
ffffffffc0203576:	4795                	li	a5,5
ffffffffc0203578:	2481                	sext.w	s1,s1
ffffffffc020357a:	20f49063          	bne	s1,a5,ffffffffc020377a <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020357e:	00003517          	auipc	a0,0x3
ffffffffc0203582:	2b250513          	addi	a0,a0,690 # ffffffffc0206830 <default_pmm_manager+0xac8>
ffffffffc0203586:	bfbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020358a:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020358e:	401c                	lw	a5,0(s0)
ffffffffc0203590:	2781                	sext.w	a5,a5
ffffffffc0203592:	1c979463          	bne	a5,s1,ffffffffc020375a <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203596:	00003517          	auipc	a0,0x3
ffffffffc020359a:	24a50513          	addi	a0,a0,586 # ffffffffc02067e0 <default_pmm_manager+0xa78>
ffffffffc020359e:	be3fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035a2:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02035a6:	401c                	lw	a5,0(s0)
ffffffffc02035a8:	4719                	li	a4,6
ffffffffc02035aa:	2781                	sext.w	a5,a5
ffffffffc02035ac:	18e79763          	bne	a5,a4,ffffffffc020373a <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02035b0:	00003517          	auipc	a0,0x3
ffffffffc02035b4:	28050513          	addi	a0,a0,640 # ffffffffc0206830 <default_pmm_manager+0xac8>
ffffffffc02035b8:	bc9fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035bc:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc02035c0:	401c                	lw	a5,0(s0)
ffffffffc02035c2:	471d                	li	a4,7
ffffffffc02035c4:	2781                	sext.w	a5,a5
ffffffffc02035c6:	14e79a63          	bne	a5,a4,ffffffffc020371a <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02035ca:	00003517          	auipc	a0,0x3
ffffffffc02035ce:	1d650513          	addi	a0,a0,470 # ffffffffc02067a0 <default_pmm_manager+0xa38>
ffffffffc02035d2:	baffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035d6:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02035da:	401c                	lw	a5,0(s0)
ffffffffc02035dc:	4721                	li	a4,8
ffffffffc02035de:	2781                	sext.w	a5,a5
ffffffffc02035e0:	10e79d63          	bne	a5,a4,ffffffffc02036fa <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02035e4:	00003517          	auipc	a0,0x3
ffffffffc02035e8:	22450513          	addi	a0,a0,548 # ffffffffc0206808 <default_pmm_manager+0xaa0>
ffffffffc02035ec:	b95fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035f0:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02035f4:	401c                	lw	a5,0(s0)
ffffffffc02035f6:	4725                	li	a4,9
ffffffffc02035f8:	2781                	sext.w	a5,a5
ffffffffc02035fa:	0ee79063          	bne	a5,a4,ffffffffc02036da <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02035fe:	00003517          	auipc	a0,0x3
ffffffffc0203602:	25a50513          	addi	a0,a0,602 # ffffffffc0206858 <default_pmm_manager+0xaf0>
ffffffffc0203606:	b7bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020360a:	6795                	lui	a5,0x5
ffffffffc020360c:	4739                	li	a4,14
ffffffffc020360e:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203612:	4004                	lw	s1,0(s0)
ffffffffc0203614:	47a9                	li	a5,10
ffffffffc0203616:	2481                	sext.w	s1,s1
ffffffffc0203618:	0af49163          	bne	s1,a5,ffffffffc02036ba <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020361c:	00003517          	auipc	a0,0x3
ffffffffc0203620:	1c450513          	addi	a0,a0,452 # ffffffffc02067e0 <default_pmm_manager+0xa78>
ffffffffc0203624:	b5dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203628:	6785                	lui	a5,0x1
ffffffffc020362a:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020362e:	06979663          	bne	a5,s1,ffffffffc020369a <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203632:	401c                	lw	a5,0(s0)
ffffffffc0203634:	472d                	li	a4,11
ffffffffc0203636:	2781                	sext.w	a5,a5
ffffffffc0203638:	04e79163          	bne	a5,a4,ffffffffc020367a <_fifo_check_swap+0x1b4>
}
ffffffffc020363c:	60e6                	ld	ra,88(sp)
ffffffffc020363e:	6446                	ld	s0,80(sp)
ffffffffc0203640:	64a6                	ld	s1,72(sp)
ffffffffc0203642:	6906                	ld	s2,64(sp)
ffffffffc0203644:	79e2                	ld	s3,56(sp)
ffffffffc0203646:	7a42                	ld	s4,48(sp)
ffffffffc0203648:	7aa2                	ld	s5,40(sp)
ffffffffc020364a:	7b02                	ld	s6,32(sp)
ffffffffc020364c:	6be2                	ld	s7,24(sp)
ffffffffc020364e:	6c42                	ld	s8,16(sp)
ffffffffc0203650:	6ca2                	ld	s9,8(sp)
ffffffffc0203652:	6d02                	ld	s10,0(sp)
ffffffffc0203654:	4501                	li	a0,0
ffffffffc0203656:	6125                	addi	sp,sp,96
ffffffffc0203658:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020365a:	00003697          	auipc	a3,0x3
ffffffffc020365e:	f9668693          	addi	a3,a3,-106 # ffffffffc02065f0 <default_pmm_manager+0x888>
ffffffffc0203662:	00002617          	auipc	a2,0x2
ffffffffc0203666:	35660613          	addi	a2,a2,854 # ffffffffc02059b8 <commands+0x798>
ffffffffc020366a:	05100593          	li	a1,81
ffffffffc020366e:	00003517          	auipc	a0,0x3
ffffffffc0203672:	15a50513          	addi	a0,a0,346 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203676:	dd1fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==11);
ffffffffc020367a:	00003697          	auipc	a3,0x3
ffffffffc020367e:	28e68693          	addi	a3,a3,654 # ffffffffc0206908 <default_pmm_manager+0xba0>
ffffffffc0203682:	00002617          	auipc	a2,0x2
ffffffffc0203686:	33660613          	addi	a2,a2,822 # ffffffffc02059b8 <commands+0x798>
ffffffffc020368a:	07300593          	li	a1,115
ffffffffc020368e:	00003517          	auipc	a0,0x3
ffffffffc0203692:	13a50513          	addi	a0,a0,314 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203696:	db1fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020369a:	00003697          	auipc	a3,0x3
ffffffffc020369e:	24668693          	addi	a3,a3,582 # ffffffffc02068e0 <default_pmm_manager+0xb78>
ffffffffc02036a2:	00002617          	auipc	a2,0x2
ffffffffc02036a6:	31660613          	addi	a2,a2,790 # ffffffffc02059b8 <commands+0x798>
ffffffffc02036aa:	07100593          	li	a1,113
ffffffffc02036ae:	00003517          	auipc	a0,0x3
ffffffffc02036b2:	11a50513          	addi	a0,a0,282 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc02036b6:	d91fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==10);
ffffffffc02036ba:	00003697          	auipc	a3,0x3
ffffffffc02036be:	21668693          	addi	a3,a3,534 # ffffffffc02068d0 <default_pmm_manager+0xb68>
ffffffffc02036c2:	00002617          	auipc	a2,0x2
ffffffffc02036c6:	2f660613          	addi	a2,a2,758 # ffffffffc02059b8 <commands+0x798>
ffffffffc02036ca:	06f00593          	li	a1,111
ffffffffc02036ce:	00003517          	auipc	a0,0x3
ffffffffc02036d2:	0fa50513          	addi	a0,a0,250 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc02036d6:	d71fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==9);
ffffffffc02036da:	00003697          	auipc	a3,0x3
ffffffffc02036de:	1e668693          	addi	a3,a3,486 # ffffffffc02068c0 <default_pmm_manager+0xb58>
ffffffffc02036e2:	00002617          	auipc	a2,0x2
ffffffffc02036e6:	2d660613          	addi	a2,a2,726 # ffffffffc02059b8 <commands+0x798>
ffffffffc02036ea:	06c00593          	li	a1,108
ffffffffc02036ee:	00003517          	auipc	a0,0x3
ffffffffc02036f2:	0da50513          	addi	a0,a0,218 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc02036f6:	d51fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==8);
ffffffffc02036fa:	00003697          	auipc	a3,0x3
ffffffffc02036fe:	1b668693          	addi	a3,a3,438 # ffffffffc02068b0 <default_pmm_manager+0xb48>
ffffffffc0203702:	00002617          	auipc	a2,0x2
ffffffffc0203706:	2b660613          	addi	a2,a2,694 # ffffffffc02059b8 <commands+0x798>
ffffffffc020370a:	06900593          	li	a1,105
ffffffffc020370e:	00003517          	auipc	a0,0x3
ffffffffc0203712:	0ba50513          	addi	a0,a0,186 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203716:	d31fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==7);
ffffffffc020371a:	00003697          	auipc	a3,0x3
ffffffffc020371e:	18668693          	addi	a3,a3,390 # ffffffffc02068a0 <default_pmm_manager+0xb38>
ffffffffc0203722:	00002617          	auipc	a2,0x2
ffffffffc0203726:	29660613          	addi	a2,a2,662 # ffffffffc02059b8 <commands+0x798>
ffffffffc020372a:	06600593          	li	a1,102
ffffffffc020372e:	00003517          	auipc	a0,0x3
ffffffffc0203732:	09a50513          	addi	a0,a0,154 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203736:	d11fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==6);
ffffffffc020373a:	00003697          	auipc	a3,0x3
ffffffffc020373e:	15668693          	addi	a3,a3,342 # ffffffffc0206890 <default_pmm_manager+0xb28>
ffffffffc0203742:	00002617          	auipc	a2,0x2
ffffffffc0203746:	27660613          	addi	a2,a2,630 # ffffffffc02059b8 <commands+0x798>
ffffffffc020374a:	06300593          	li	a1,99
ffffffffc020374e:	00003517          	auipc	a0,0x3
ffffffffc0203752:	07a50513          	addi	a0,a0,122 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203756:	cf1fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc020375a:	00003697          	auipc	a3,0x3
ffffffffc020375e:	12668693          	addi	a3,a3,294 # ffffffffc0206880 <default_pmm_manager+0xb18>
ffffffffc0203762:	00002617          	auipc	a2,0x2
ffffffffc0203766:	25660613          	addi	a2,a2,598 # ffffffffc02059b8 <commands+0x798>
ffffffffc020376a:	06000593          	li	a1,96
ffffffffc020376e:	00003517          	auipc	a0,0x3
ffffffffc0203772:	05a50513          	addi	a0,a0,90 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203776:	cd1fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc020377a:	00003697          	auipc	a3,0x3
ffffffffc020377e:	10668693          	addi	a3,a3,262 # ffffffffc0206880 <default_pmm_manager+0xb18>
ffffffffc0203782:	00002617          	auipc	a2,0x2
ffffffffc0203786:	23660613          	addi	a2,a2,566 # ffffffffc02059b8 <commands+0x798>
ffffffffc020378a:	05d00593          	li	a1,93
ffffffffc020378e:	00003517          	auipc	a0,0x3
ffffffffc0203792:	03a50513          	addi	a0,a0,58 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203796:	cb1fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc020379a:	00003697          	auipc	a3,0x3
ffffffffc020379e:	e5668693          	addi	a3,a3,-426 # ffffffffc02065f0 <default_pmm_manager+0x888>
ffffffffc02037a2:	00002617          	auipc	a2,0x2
ffffffffc02037a6:	21660613          	addi	a2,a2,534 # ffffffffc02059b8 <commands+0x798>
ffffffffc02037aa:	05a00593          	li	a1,90
ffffffffc02037ae:	00003517          	auipc	a0,0x3
ffffffffc02037b2:	01a50513          	addi	a0,a0,26 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc02037b6:	c91fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc02037ba:	00003697          	auipc	a3,0x3
ffffffffc02037be:	e3668693          	addi	a3,a3,-458 # ffffffffc02065f0 <default_pmm_manager+0x888>
ffffffffc02037c2:	00002617          	auipc	a2,0x2
ffffffffc02037c6:	1f660613          	addi	a2,a2,502 # ffffffffc02059b8 <commands+0x798>
ffffffffc02037ca:	05700593          	li	a1,87
ffffffffc02037ce:	00003517          	auipc	a0,0x3
ffffffffc02037d2:	ffa50513          	addi	a0,a0,-6 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc02037d6:	c71fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc02037da:	00003697          	auipc	a3,0x3
ffffffffc02037de:	e1668693          	addi	a3,a3,-490 # ffffffffc02065f0 <default_pmm_manager+0x888>
ffffffffc02037e2:	00002617          	auipc	a2,0x2
ffffffffc02037e6:	1d660613          	addi	a2,a2,470 # ffffffffc02059b8 <commands+0x798>
ffffffffc02037ea:	05400593          	li	a1,84
ffffffffc02037ee:	00003517          	auipc	a0,0x3
ffffffffc02037f2:	fda50513          	addi	a0,a0,-38 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc02037f6:	c51fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02037fa <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02037fa:	751c                	ld	a5,40(a0)
{
ffffffffc02037fc:	1141                	addi	sp,sp,-16
ffffffffc02037fe:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203800:	cf91                	beqz	a5,ffffffffc020381c <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203802:	ee0d                	bnez	a2,ffffffffc020383c <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203804:	679c                	ld	a5,8(a5)
}
ffffffffc0203806:	60a2                	ld	ra,8(sp)
ffffffffc0203808:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020380a:	6394                	ld	a3,0(a5)
ffffffffc020380c:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020380e:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203812:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203814:	e314                	sd	a3,0(a4)
ffffffffc0203816:	e19c                	sd	a5,0(a1)
}
ffffffffc0203818:	0141                	addi	sp,sp,16
ffffffffc020381a:	8082                	ret
         assert(head != NULL);
ffffffffc020381c:	00003697          	auipc	a3,0x3
ffffffffc0203820:	0fc68693          	addi	a3,a3,252 # ffffffffc0206918 <default_pmm_manager+0xbb0>
ffffffffc0203824:	00002617          	auipc	a2,0x2
ffffffffc0203828:	19460613          	addi	a2,a2,404 # ffffffffc02059b8 <commands+0x798>
ffffffffc020382c:	04100593          	li	a1,65
ffffffffc0203830:	00003517          	auipc	a0,0x3
ffffffffc0203834:	f9850513          	addi	a0,a0,-104 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203838:	c0ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(in_tick==0);
ffffffffc020383c:	00003697          	auipc	a3,0x3
ffffffffc0203840:	0ec68693          	addi	a3,a3,236 # ffffffffc0206928 <default_pmm_manager+0xbc0>
ffffffffc0203844:	00002617          	auipc	a2,0x2
ffffffffc0203848:	17460613          	addi	a2,a2,372 # ffffffffc02059b8 <commands+0x798>
ffffffffc020384c:	04200593          	li	a1,66
ffffffffc0203850:	00003517          	auipc	a0,0x3
ffffffffc0203854:	f7850513          	addi	a0,a0,-136 # ffffffffc02067c8 <default_pmm_manager+0xa60>
ffffffffc0203858:	beffc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020385c <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020385c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020385e:	cb91                	beqz	a5,ffffffffc0203872 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203860:	6394                	ld	a3,0(a5)
ffffffffc0203862:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0203866:	e398                	sd	a4,0(a5)
ffffffffc0203868:	e698                	sd	a4,8(a3)
}
ffffffffc020386a:	4501                	li	a0,0
    elm->next = next;
ffffffffc020386c:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020386e:	f614                	sd	a3,40(a2)
ffffffffc0203870:	8082                	ret
{
ffffffffc0203872:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203874:	00003697          	auipc	a3,0x3
ffffffffc0203878:	0c468693          	addi	a3,a3,196 # ffffffffc0206938 <default_pmm_manager+0xbd0>
ffffffffc020387c:	00002617          	auipc	a2,0x2
ffffffffc0203880:	13c60613          	addi	a2,a2,316 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203884:	03200593          	li	a1,50
ffffffffc0203888:	00003517          	auipc	a0,0x3
ffffffffc020388c:	f4050513          	addi	a0,a0,-192 # ffffffffc02067c8 <default_pmm_manager+0xa60>
{
ffffffffc0203890:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203892:	bb5fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203896 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203896:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203898:	00003697          	auipc	a3,0x3
ffffffffc020389c:	0d868693          	addi	a3,a3,216 # ffffffffc0206970 <default_pmm_manager+0xc08>
ffffffffc02038a0:	00002617          	auipc	a2,0x2
ffffffffc02038a4:	11860613          	addi	a2,a2,280 # ffffffffc02059b8 <commands+0x798>
ffffffffc02038a8:	07e00593          	li	a1,126
ffffffffc02038ac:	00003517          	auipc	a0,0x3
ffffffffc02038b0:	0e450513          	addi	a0,a0,228 # ffffffffc0206990 <default_pmm_manager+0xc28>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02038b4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02038b6:	b91fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02038ba <mm_create>:
mm_create(void) {
ffffffffc02038ba:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02038bc:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02038c0:	e022                	sd	s0,0(sp)
ffffffffc02038c2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02038c4:	feffd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
ffffffffc02038c8:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02038ca:	c105                	beqz	a0,ffffffffc02038ea <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02038cc:	e408                	sd	a0,8(s0)
ffffffffc02038ce:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02038d0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02038d4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02038d8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038dc:	00013797          	auipc	a5,0x13
ffffffffc02038e0:	cc47a783          	lw	a5,-828(a5) # ffffffffc02165a0 <swap_init_ok>
ffffffffc02038e4:	eb81                	bnez	a5,ffffffffc02038f4 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02038e6:	02053423          	sd	zero,40(a0)
}
ffffffffc02038ea:	60a2                	ld	ra,8(sp)
ffffffffc02038ec:	8522                	mv	a0,s0
ffffffffc02038ee:	6402                	ld	s0,0(sp)
ffffffffc02038f0:	0141                	addi	sp,sp,16
ffffffffc02038f2:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038f4:	a0fff0ef          	jal	ra,ffffffffc0203302 <swap_init_mm>
}
ffffffffc02038f8:	60a2                	ld	ra,8(sp)
ffffffffc02038fa:	8522                	mv	a0,s0
ffffffffc02038fc:	6402                	ld	s0,0(sp)
ffffffffc02038fe:	0141                	addi	sp,sp,16
ffffffffc0203900:	8082                	ret

ffffffffc0203902 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203902:	1101                	addi	sp,sp,-32
ffffffffc0203904:	e04a                	sd	s2,0(sp)
ffffffffc0203906:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203908:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020390c:	e822                	sd	s0,16(sp)
ffffffffc020390e:	e426                	sd	s1,8(sp)
ffffffffc0203910:	ec06                	sd	ra,24(sp)
ffffffffc0203912:	84ae                	mv	s1,a1
ffffffffc0203914:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203916:	f9dfd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
    if (vma != NULL) {
ffffffffc020391a:	c509                	beqz	a0,ffffffffc0203924 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020391c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203920:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203922:	cd00                	sw	s0,24(a0)
}
ffffffffc0203924:	60e2                	ld	ra,24(sp)
ffffffffc0203926:	6442                	ld	s0,16(sp)
ffffffffc0203928:	64a2                	ld	s1,8(sp)
ffffffffc020392a:	6902                	ld	s2,0(sp)
ffffffffc020392c:	6105                	addi	sp,sp,32
ffffffffc020392e:	8082                	ret

ffffffffc0203930 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203930:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203932:	c505                	beqz	a0,ffffffffc020395a <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203934:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203936:	c501                	beqz	a0,ffffffffc020393e <find_vma+0xe>
ffffffffc0203938:	651c                	ld	a5,8(a0)
ffffffffc020393a:	02f5f263          	bgeu	a1,a5,ffffffffc020395e <find_vma+0x2e>
    return listelm->next;
ffffffffc020393e:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203940:	00f68d63          	beq	a3,a5,ffffffffc020395a <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203944:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203948:	00e5e663          	bltu	a1,a4,ffffffffc0203954 <find_vma+0x24>
ffffffffc020394c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203950:	00e5ec63          	bltu	a1,a4,ffffffffc0203968 <find_vma+0x38>
ffffffffc0203954:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203956:	fef697e3          	bne	a3,a5,ffffffffc0203944 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020395a:	4501                	li	a0,0
}
ffffffffc020395c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020395e:	691c                	ld	a5,16(a0)
ffffffffc0203960:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020393e <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203964:	ea88                	sd	a0,16(a3)
ffffffffc0203966:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203968:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020396c:	ea88                	sd	a0,16(a3)
ffffffffc020396e:	8082                	ret

ffffffffc0203970 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203970:	6590                	ld	a2,8(a1)
ffffffffc0203972:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203976:	1141                	addi	sp,sp,-16
ffffffffc0203978:	e406                	sd	ra,8(sp)
ffffffffc020397a:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020397c:	01066763          	bltu	a2,a6,ffffffffc020398a <insert_vma_struct+0x1a>
ffffffffc0203980:	a085                	j	ffffffffc02039e0 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203982:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203986:	04e66863          	bltu	a2,a4,ffffffffc02039d6 <insert_vma_struct+0x66>
ffffffffc020398a:	86be                	mv	a3,a5
ffffffffc020398c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020398e:	fef51ae3          	bne	a0,a5,ffffffffc0203982 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203992:	02a68463          	beq	a3,a0,ffffffffc02039ba <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203996:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020399a:	fe86b883          	ld	a7,-24(a3)
ffffffffc020399e:	08e8f163          	bgeu	a7,a4,ffffffffc0203a20 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02039a2:	04e66f63          	bltu	a2,a4,ffffffffc0203a00 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02039a6:	00f50a63          	beq	a0,a5,ffffffffc02039ba <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02039aa:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02039ae:	05076963          	bltu	a4,a6,ffffffffc0203a00 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02039b2:	ff07b603          	ld	a2,-16(a5)
ffffffffc02039b6:	02c77363          	bgeu	a4,a2,ffffffffc02039dc <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02039ba:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02039bc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02039be:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02039c2:	e390                	sd	a2,0(a5)
ffffffffc02039c4:	e690                	sd	a2,8(a3)
}
ffffffffc02039c6:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02039c8:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02039ca:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02039cc:	0017079b          	addiw	a5,a4,1
ffffffffc02039d0:	d11c                	sw	a5,32(a0)
}
ffffffffc02039d2:	0141                	addi	sp,sp,16
ffffffffc02039d4:	8082                	ret
    if (le_prev != list) {
ffffffffc02039d6:	fca690e3          	bne	a3,a0,ffffffffc0203996 <insert_vma_struct+0x26>
ffffffffc02039da:	bfd1                	j	ffffffffc02039ae <insert_vma_struct+0x3e>
ffffffffc02039dc:	ebbff0ef          	jal	ra,ffffffffc0203896 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02039e0:	00003697          	auipc	a3,0x3
ffffffffc02039e4:	fc068693          	addi	a3,a3,-64 # ffffffffc02069a0 <default_pmm_manager+0xc38>
ffffffffc02039e8:	00002617          	auipc	a2,0x2
ffffffffc02039ec:	fd060613          	addi	a2,a2,-48 # ffffffffc02059b8 <commands+0x798>
ffffffffc02039f0:	08500593          	li	a1,133
ffffffffc02039f4:	00003517          	auipc	a0,0x3
ffffffffc02039f8:	f9c50513          	addi	a0,a0,-100 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc02039fc:	a4bfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203a00:	00003697          	auipc	a3,0x3
ffffffffc0203a04:	fe068693          	addi	a3,a3,-32 # ffffffffc02069e0 <default_pmm_manager+0xc78>
ffffffffc0203a08:	00002617          	auipc	a2,0x2
ffffffffc0203a0c:	fb060613          	addi	a2,a2,-80 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203a10:	07d00593          	li	a1,125
ffffffffc0203a14:	00003517          	auipc	a0,0x3
ffffffffc0203a18:	f7c50513          	addi	a0,a0,-132 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203a1c:	a2bfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203a20:	00003697          	auipc	a3,0x3
ffffffffc0203a24:	fa068693          	addi	a3,a3,-96 # ffffffffc02069c0 <default_pmm_manager+0xc58>
ffffffffc0203a28:	00002617          	auipc	a2,0x2
ffffffffc0203a2c:	f9060613          	addi	a2,a2,-112 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203a30:	07c00593          	li	a1,124
ffffffffc0203a34:	00003517          	auipc	a0,0x3
ffffffffc0203a38:	f5c50513          	addi	a0,a0,-164 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203a3c:	a0bfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203a40 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203a40:	1141                	addi	sp,sp,-16
ffffffffc0203a42:	e022                	sd	s0,0(sp)
ffffffffc0203a44:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203a46:	6508                	ld	a0,8(a0)
ffffffffc0203a48:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203a4a:	00a40c63          	beq	s0,a0,ffffffffc0203a62 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a4e:	6118                	ld	a4,0(a0)
ffffffffc0203a50:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203a52:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a54:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a56:	e398                	sd	a4,0(a5)
ffffffffc0203a58:	f0bfd0ef          	jal	ra,ffffffffc0201962 <kfree>
    return listelm->next;
ffffffffc0203a5c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a5e:	fea418e3          	bne	s0,a0,ffffffffc0203a4e <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203a62:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203a64:	6402                	ld	s0,0(sp)
ffffffffc0203a66:	60a2                	ld	ra,8(sp)
ffffffffc0203a68:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203a6a:	ef9fd06f          	j	ffffffffc0201962 <kfree>

ffffffffc0203a6e <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203a6e:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a70:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0203a74:	fc06                	sd	ra,56(sp)
ffffffffc0203a76:	f822                	sd	s0,48(sp)
ffffffffc0203a78:	f426                	sd	s1,40(sp)
ffffffffc0203a7a:	f04a                	sd	s2,32(sp)
ffffffffc0203a7c:	ec4e                	sd	s3,24(sp)
ffffffffc0203a7e:	e852                	sd	s4,16(sp)
ffffffffc0203a80:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a82:	e31fd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
    if (mm != NULL) {
ffffffffc0203a86:	58050e63          	beqz	a0,ffffffffc0204022 <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc0203a8a:	e508                	sd	a0,8(a0)
ffffffffc0203a8c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203a8e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203a92:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203a96:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a9a:	00013797          	auipc	a5,0x13
ffffffffc0203a9e:	b067a783          	lw	a5,-1274(a5) # ffffffffc02165a0 <swap_init_ok>
ffffffffc0203aa2:	84aa                	mv	s1,a0
ffffffffc0203aa4:	e7b9                	bnez	a5,ffffffffc0203af2 <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0203aa6:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0203aaa:	03200413          	li	s0,50
ffffffffc0203aae:	a811                	j	ffffffffc0203ac2 <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc0203ab0:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203ab2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203ab4:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0203ab8:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203aba:	8526                	mv	a0,s1
ffffffffc0203abc:	eb5ff0ef          	jal	ra,ffffffffc0203970 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203ac0:	cc05                	beqz	s0,ffffffffc0203af8 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ac2:	03000513          	li	a0,48
ffffffffc0203ac6:	dedfd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
ffffffffc0203aca:	85aa                	mv	a1,a0
ffffffffc0203acc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203ad0:	f165                	bnez	a0,ffffffffc0203ab0 <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc0203ad2:	00003697          	auipc	a3,0x3
ffffffffc0203ad6:	9de68693          	addi	a3,a3,-1570 # ffffffffc02064b0 <default_pmm_manager+0x748>
ffffffffc0203ada:	00002617          	auipc	a2,0x2
ffffffffc0203ade:	ede60613          	addi	a2,a2,-290 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203ae2:	0c900593          	li	a1,201
ffffffffc0203ae6:	00003517          	auipc	a0,0x3
ffffffffc0203aea:	eaa50513          	addi	a0,a0,-342 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203aee:	959fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203af2:	811ff0ef          	jal	ra,ffffffffc0203302 <swap_init_mm>
ffffffffc0203af6:	bf55                	j	ffffffffc0203aaa <vmm_init+0x3c>
ffffffffc0203af8:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203afc:	1f900913          	li	s2,505
ffffffffc0203b00:	a819                	j	ffffffffc0203b16 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0203b02:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203b04:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b06:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203b0a:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203b0c:	8526                	mv	a0,s1
ffffffffc0203b0e:	e63ff0ef          	jal	ra,ffffffffc0203970 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203b12:	03240a63          	beq	s0,s2,ffffffffc0203b46 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b16:	03000513          	li	a0,48
ffffffffc0203b1a:	d99fd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
ffffffffc0203b1e:	85aa                	mv	a1,a0
ffffffffc0203b20:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203b24:	fd79                	bnez	a0,ffffffffc0203b02 <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0203b26:	00003697          	auipc	a3,0x3
ffffffffc0203b2a:	98a68693          	addi	a3,a3,-1654 # ffffffffc02064b0 <default_pmm_manager+0x748>
ffffffffc0203b2e:	00002617          	auipc	a2,0x2
ffffffffc0203b32:	e8a60613          	addi	a2,a2,-374 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203b36:	0cf00593          	li	a1,207
ffffffffc0203b3a:	00003517          	auipc	a0,0x3
ffffffffc0203b3e:	e5650513          	addi	a0,a0,-426 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203b42:	905fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return listelm->next;
ffffffffc0203b46:	649c                	ld	a5,8(s1)
ffffffffc0203b48:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203b4a:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203b4e:	30f48e63          	beq	s1,a5,ffffffffc0203e6a <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b52:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203b56:	ffe70613          	addi	a2,a4,-2
ffffffffc0203b5a:	2ad61863          	bne	a2,a3,ffffffffc0203e0a <vmm_init+0x39c>
ffffffffc0203b5e:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203b62:	2ae69463          	bne	a3,a4,ffffffffc0203e0a <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203b66:	0715                	addi	a4,a4,5
ffffffffc0203b68:	679c                	ld	a5,8(a5)
ffffffffc0203b6a:	feb712e3          	bne	a4,a1,ffffffffc0203b4e <vmm_init+0xe0>
ffffffffc0203b6e:	4a1d                	li	s4,7
ffffffffc0203b70:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b72:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b76:	85a2                	mv	a1,s0
ffffffffc0203b78:	8526                	mv	a0,s1
ffffffffc0203b7a:	db7ff0ef          	jal	ra,ffffffffc0203930 <find_vma>
ffffffffc0203b7e:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203b80:	34050563          	beqz	a0,ffffffffc0203eca <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203b84:	00140593          	addi	a1,s0,1
ffffffffc0203b88:	8526                	mv	a0,s1
ffffffffc0203b8a:	da7ff0ef          	jal	ra,ffffffffc0203930 <find_vma>
ffffffffc0203b8e:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b90:	34050d63          	beqz	a0,ffffffffc0203eea <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203b94:	85d2                	mv	a1,s4
ffffffffc0203b96:	8526                	mv	a0,s1
ffffffffc0203b98:	d99ff0ef          	jal	ra,ffffffffc0203930 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b9c:	36051763          	bnez	a0,ffffffffc0203f0a <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203ba0:	00340593          	addi	a1,s0,3
ffffffffc0203ba4:	8526                	mv	a0,s1
ffffffffc0203ba6:	d8bff0ef          	jal	ra,ffffffffc0203930 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203baa:	2e051063          	bnez	a0,ffffffffc0203e8a <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203bae:	00440593          	addi	a1,s0,4
ffffffffc0203bb2:	8526                	mv	a0,s1
ffffffffc0203bb4:	d7dff0ef          	jal	ra,ffffffffc0203930 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203bb8:	2e051963          	bnez	a0,ffffffffc0203eaa <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203bbc:	00893783          	ld	a5,8(s2)
ffffffffc0203bc0:	26879563          	bne	a5,s0,ffffffffc0203e2a <vmm_init+0x3bc>
ffffffffc0203bc4:	01093783          	ld	a5,16(s2)
ffffffffc0203bc8:	27479163          	bne	a5,s4,ffffffffc0203e2a <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203bcc:	0089b783          	ld	a5,8(s3)
ffffffffc0203bd0:	26879d63          	bne	a5,s0,ffffffffc0203e4a <vmm_init+0x3dc>
ffffffffc0203bd4:	0109b783          	ld	a5,16(s3)
ffffffffc0203bd8:	27479963          	bne	a5,s4,ffffffffc0203e4a <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203bdc:	0415                	addi	s0,s0,5
ffffffffc0203bde:	0a15                	addi	s4,s4,5
ffffffffc0203be0:	f9541be3          	bne	s0,s5,ffffffffc0203b76 <vmm_init+0x108>
ffffffffc0203be4:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203be6:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203be8:	85a2                	mv	a1,s0
ffffffffc0203bea:	8526                	mv	a0,s1
ffffffffc0203bec:	d45ff0ef          	jal	ra,ffffffffc0203930 <find_vma>
ffffffffc0203bf0:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203bf4:	c90d                	beqz	a0,ffffffffc0203c26 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203bf6:	6914                	ld	a3,16(a0)
ffffffffc0203bf8:	6510                	ld	a2,8(a0)
ffffffffc0203bfa:	00003517          	auipc	a0,0x3
ffffffffc0203bfe:	f0650513          	addi	a0,a0,-250 # ffffffffc0206b00 <default_pmm_manager+0xd98>
ffffffffc0203c02:	d7efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203c06:	00003697          	auipc	a3,0x3
ffffffffc0203c0a:	f2268693          	addi	a3,a3,-222 # ffffffffc0206b28 <default_pmm_manager+0xdc0>
ffffffffc0203c0e:	00002617          	auipc	a2,0x2
ffffffffc0203c12:	daa60613          	addi	a2,a2,-598 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203c16:	0f100593          	li	a1,241
ffffffffc0203c1a:	00003517          	auipc	a0,0x3
ffffffffc0203c1e:	d7650513          	addi	a0,a0,-650 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203c22:	825fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203c26:	147d                	addi	s0,s0,-1
ffffffffc0203c28:	fd2410e3          	bne	s0,s2,ffffffffc0203be8 <vmm_init+0x17a>
ffffffffc0203c2c:	a801                	j	ffffffffc0203c3c <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203c2e:	6118                	ld	a4,0(a0)
ffffffffc0203c30:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203c32:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203c34:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203c36:	e398                	sd	a4,0(a5)
ffffffffc0203c38:	d2bfd0ef          	jal	ra,ffffffffc0201962 <kfree>
    return listelm->next;
ffffffffc0203c3c:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203c3e:	fea498e3          	bne	s1,a0,ffffffffc0203c2e <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0203c42:	8526                	mv	a0,s1
ffffffffc0203c44:	d1ffd0ef          	jal	ra,ffffffffc0201962 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203c48:	00003517          	auipc	a0,0x3
ffffffffc0203c4c:	ef850513          	addi	a0,a0,-264 # ffffffffc0206b40 <default_pmm_manager+0xdd8>
ffffffffc0203c50:	d30fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203c54:	f0ffd0ef          	jal	ra,ffffffffc0201b62 <nr_free_pages>
ffffffffc0203c58:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203c5a:	03000513          	li	a0,48
ffffffffc0203c5e:	c55fd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
ffffffffc0203c62:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203c64:	2c050363          	beqz	a0,ffffffffc0203f2a <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203c68:	00013797          	auipc	a5,0x13
ffffffffc0203c6c:	9387a783          	lw	a5,-1736(a5) # ffffffffc02165a0 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203c70:	e508                	sd	a0,8(a0)
ffffffffc0203c72:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203c74:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203c78:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203c7c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203c80:	18079263          	bnez	a5,ffffffffc0203e04 <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc0203c84:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c88:	00013917          	auipc	s2,0x13
ffffffffc0203c8c:	8e093903          	ld	s2,-1824(s2) # ffffffffc0216568 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203c90:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203c94:	00013717          	auipc	a4,0x13
ffffffffc0203c98:	90873a23          	sd	s0,-1772(a4) # ffffffffc02165a8 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c9c:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203ca0:	36079163          	bnez	a5,ffffffffc0204002 <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ca4:	03000513          	li	a0,48
ffffffffc0203ca8:	c0bfd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
ffffffffc0203cac:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0203cae:	2a050263          	beqz	a0,ffffffffc0203f52 <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc0203cb2:	002007b7          	lui	a5,0x200
ffffffffc0203cb6:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0203cba:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203cbc:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203cbe:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203cc2:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203cc4:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203cc8:	ca9ff0ef          	jal	ra,ffffffffc0203970 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203ccc:	10000593          	li	a1,256
ffffffffc0203cd0:	8522                	mv	a0,s0
ffffffffc0203cd2:	c5fff0ef          	jal	ra,ffffffffc0203930 <find_vma>
ffffffffc0203cd6:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203cda:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203cde:	28a99a63          	bne	s3,a0,ffffffffc0203f72 <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc0203ce2:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203ce6:	0785                	addi	a5,a5,1
ffffffffc0203ce8:	fee79de3          	bne	a5,a4,ffffffffc0203ce2 <vmm_init+0x274>
        sum += i;
ffffffffc0203cec:	6705                	lui	a4,0x1
ffffffffc0203cee:	10000793          	li	a5,256
ffffffffc0203cf2:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203cf6:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203cfa:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203cfe:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203d00:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203d02:	fec79ce3          	bne	a5,a2,ffffffffc0203cfa <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0203d06:	28071663          	bnez	a4,ffffffffc0203f92 <vmm_init+0x524>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d0a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203d0e:	00013a97          	auipc	s5,0x13
ffffffffc0203d12:	862a8a93          	addi	s5,s5,-1950 # ffffffffc0216570 <npage>
ffffffffc0203d16:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d1a:	078a                	slli	a5,a5,0x2
ffffffffc0203d1c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d1e:	28c7fa63          	bgeu	a5,a2,ffffffffc0203fb2 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d22:	00003a17          	auipc	s4,0x3
ffffffffc0203d26:	406a3a03          	ld	s4,1030(s4) # ffffffffc0207128 <nbase>
ffffffffc0203d2a:	414787b3          	sub	a5,a5,s4
ffffffffc0203d2e:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0203d30:	8799                	srai	a5,a5,0x6
ffffffffc0203d32:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0203d34:	00c79713          	slli	a4,a5,0xc
ffffffffc0203d38:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d3a:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203d3e:	28c77663          	bgeu	a4,a2,ffffffffc0203fca <vmm_init+0x55c>
ffffffffc0203d42:	00013997          	auipc	s3,0x13
ffffffffc0203d46:	8469b983          	ld	s3,-1978(s3) # ffffffffc0216588 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203d4a:	4581                	li	a1,0
ffffffffc0203d4c:	854a                	mv	a0,s2
ffffffffc0203d4e:	99b6                	add	s3,s3,a3
ffffffffc0203d50:	872fe0ef          	jal	ra,ffffffffc0201dc2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d54:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0203d58:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d5c:	078a                	slli	a5,a5,0x2
ffffffffc0203d5e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d60:	24e7f963          	bgeu	a5,a4,ffffffffc0203fb2 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d64:	00013997          	auipc	s3,0x13
ffffffffc0203d68:	81498993          	addi	s3,s3,-2028 # ffffffffc0216578 <pages>
ffffffffc0203d6c:	0009b503          	ld	a0,0(s3)
ffffffffc0203d70:	414787b3          	sub	a5,a5,s4
ffffffffc0203d74:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203d76:	953e                	add	a0,a0,a5
ffffffffc0203d78:	4585                	li	a1,1
ffffffffc0203d7a:	da9fd0ef          	jal	ra,ffffffffc0201b22 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d7e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203d82:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d86:	078a                	slli	a5,a5,0x2
ffffffffc0203d88:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d8a:	22e7f463          	bgeu	a5,a4,ffffffffc0203fb2 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d8e:	0009b503          	ld	a0,0(s3)
ffffffffc0203d92:	414787b3          	sub	a5,a5,s4
ffffffffc0203d96:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203d98:	4585                	li	a1,1
ffffffffc0203d9a:	953e                	add	a0,a0,a5
ffffffffc0203d9c:	d87fd0ef          	jal	ra,ffffffffc0201b22 <free_pages>
    pgdir[0] = 0;
ffffffffc0203da0:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203da4:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203da8:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203daa:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203dae:	00a40c63          	beq	s0,a0,ffffffffc0203dc6 <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203db2:	6118                	ld	a4,0(a0)
ffffffffc0203db4:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203db6:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203db8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203dba:	e398                	sd	a4,0(a5)
ffffffffc0203dbc:	ba7fd0ef          	jal	ra,ffffffffc0201962 <kfree>
    return listelm->next;
ffffffffc0203dc0:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203dc2:	fea418e3          	bne	s0,a0,ffffffffc0203db2 <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc0203dc6:	8522                	mv	a0,s0
ffffffffc0203dc8:	b9bfd0ef          	jal	ra,ffffffffc0201962 <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc0203dcc:	00012797          	auipc	a5,0x12
ffffffffc0203dd0:	7c07be23          	sd	zero,2012(a5) # ffffffffc02165a8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203dd4:	d8ffd0ef          	jal	ra,ffffffffc0201b62 <nr_free_pages>
ffffffffc0203dd8:	20a49563          	bne	s1,a0,ffffffffc0203fe2 <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203ddc:	00003517          	auipc	a0,0x3
ffffffffc0203de0:	ddc50513          	addi	a0,a0,-548 # ffffffffc0206bb8 <default_pmm_manager+0xe50>
ffffffffc0203de4:	b9cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203de8:	7442                	ld	s0,48(sp)
ffffffffc0203dea:	70e2                	ld	ra,56(sp)
ffffffffc0203dec:	74a2                	ld	s1,40(sp)
ffffffffc0203dee:	7902                	ld	s2,32(sp)
ffffffffc0203df0:	69e2                	ld	s3,24(sp)
ffffffffc0203df2:	6a42                	ld	s4,16(sp)
ffffffffc0203df4:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203df6:	00003517          	auipc	a0,0x3
ffffffffc0203dfa:	de250513          	addi	a0,a0,-542 # ffffffffc0206bd8 <default_pmm_manager+0xe70>
}
ffffffffc0203dfe:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203e00:	b80fc06f          	j	ffffffffc0200180 <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203e04:	cfeff0ef          	jal	ra,ffffffffc0203302 <swap_init_mm>
ffffffffc0203e08:	b541                	j	ffffffffc0203c88 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203e0a:	00003697          	auipc	a3,0x3
ffffffffc0203e0e:	c0e68693          	addi	a3,a3,-1010 # ffffffffc0206a18 <default_pmm_manager+0xcb0>
ffffffffc0203e12:	00002617          	auipc	a2,0x2
ffffffffc0203e16:	ba660613          	addi	a2,a2,-1114 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203e1a:	0d800593          	li	a1,216
ffffffffc0203e1e:	00003517          	auipc	a0,0x3
ffffffffc0203e22:	b7250513          	addi	a0,a0,-1166 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203e26:	e20fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203e2a:	00003697          	auipc	a3,0x3
ffffffffc0203e2e:	c7668693          	addi	a3,a3,-906 # ffffffffc0206aa0 <default_pmm_manager+0xd38>
ffffffffc0203e32:	00002617          	auipc	a2,0x2
ffffffffc0203e36:	b8660613          	addi	a2,a2,-1146 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203e3a:	0e800593          	li	a1,232
ffffffffc0203e3e:	00003517          	auipc	a0,0x3
ffffffffc0203e42:	b5250513          	addi	a0,a0,-1198 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203e46:	e00fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203e4a:	00003697          	auipc	a3,0x3
ffffffffc0203e4e:	c8668693          	addi	a3,a3,-890 # ffffffffc0206ad0 <default_pmm_manager+0xd68>
ffffffffc0203e52:	00002617          	auipc	a2,0x2
ffffffffc0203e56:	b6660613          	addi	a2,a2,-1178 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203e5a:	0e900593          	li	a1,233
ffffffffc0203e5e:	00003517          	auipc	a0,0x3
ffffffffc0203e62:	b3250513          	addi	a0,a0,-1230 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203e66:	de0fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203e6a:	00003697          	auipc	a3,0x3
ffffffffc0203e6e:	b9668693          	addi	a3,a3,-1130 # ffffffffc0206a00 <default_pmm_manager+0xc98>
ffffffffc0203e72:	00002617          	auipc	a2,0x2
ffffffffc0203e76:	b4660613          	addi	a2,a2,-1210 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203e7a:	0d600593          	li	a1,214
ffffffffc0203e7e:	00003517          	auipc	a0,0x3
ffffffffc0203e82:	b1250513          	addi	a0,a0,-1262 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203e86:	dc0fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc0203e8a:	00003697          	auipc	a3,0x3
ffffffffc0203e8e:	bf668693          	addi	a3,a3,-1034 # ffffffffc0206a80 <default_pmm_manager+0xd18>
ffffffffc0203e92:	00002617          	auipc	a2,0x2
ffffffffc0203e96:	b2660613          	addi	a2,a2,-1242 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203e9a:	0e400593          	li	a1,228
ffffffffc0203e9e:	00003517          	auipc	a0,0x3
ffffffffc0203ea2:	af250513          	addi	a0,a0,-1294 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203ea6:	da0fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc0203eaa:	00003697          	auipc	a3,0x3
ffffffffc0203eae:	be668693          	addi	a3,a3,-1050 # ffffffffc0206a90 <default_pmm_manager+0xd28>
ffffffffc0203eb2:	00002617          	auipc	a2,0x2
ffffffffc0203eb6:	b0660613          	addi	a2,a2,-1274 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203eba:	0e600593          	li	a1,230
ffffffffc0203ebe:	00003517          	auipc	a0,0x3
ffffffffc0203ec2:	ad250513          	addi	a0,a0,-1326 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203ec6:	d80fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc0203eca:	00003697          	auipc	a3,0x3
ffffffffc0203ece:	b8668693          	addi	a3,a3,-1146 # ffffffffc0206a50 <default_pmm_manager+0xce8>
ffffffffc0203ed2:	00002617          	auipc	a2,0x2
ffffffffc0203ed6:	ae660613          	addi	a2,a2,-1306 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203eda:	0de00593          	li	a1,222
ffffffffc0203ede:	00003517          	auipc	a0,0x3
ffffffffc0203ee2:	ab250513          	addi	a0,a0,-1358 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203ee6:	d60fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc0203eea:	00003697          	auipc	a3,0x3
ffffffffc0203eee:	b7668693          	addi	a3,a3,-1162 # ffffffffc0206a60 <default_pmm_manager+0xcf8>
ffffffffc0203ef2:	00002617          	auipc	a2,0x2
ffffffffc0203ef6:	ac660613          	addi	a2,a2,-1338 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203efa:	0e000593          	li	a1,224
ffffffffc0203efe:	00003517          	auipc	a0,0x3
ffffffffc0203f02:	a9250513          	addi	a0,a0,-1390 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203f06:	d40fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc0203f0a:	00003697          	auipc	a3,0x3
ffffffffc0203f0e:	b6668693          	addi	a3,a3,-1178 # ffffffffc0206a70 <default_pmm_manager+0xd08>
ffffffffc0203f12:	00002617          	auipc	a2,0x2
ffffffffc0203f16:	aa660613          	addi	a2,a2,-1370 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203f1a:	0e200593          	li	a1,226
ffffffffc0203f1e:	00003517          	auipc	a0,0x3
ffffffffc0203f22:	a7250513          	addi	a0,a0,-1422 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203f26:	d20fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203f2a:	00003697          	auipc	a3,0x3
ffffffffc0203f2e:	cc668693          	addi	a3,a3,-826 # ffffffffc0206bf0 <default_pmm_manager+0xe88>
ffffffffc0203f32:	00002617          	auipc	a2,0x2
ffffffffc0203f36:	a8660613          	addi	a2,a2,-1402 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203f3a:	10100593          	li	a1,257
ffffffffc0203f3e:	00003517          	auipc	a0,0x3
ffffffffc0203f42:	a5250513          	addi	a0,a0,-1454 # ffffffffc0206990 <default_pmm_manager+0xc28>
    check_mm_struct = mm_create();
ffffffffc0203f46:	00012797          	auipc	a5,0x12
ffffffffc0203f4a:	6607b123          	sd	zero,1634(a5) # ffffffffc02165a8 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203f4e:	cf8fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(vma != NULL);
ffffffffc0203f52:	00002697          	auipc	a3,0x2
ffffffffc0203f56:	55e68693          	addi	a3,a3,1374 # ffffffffc02064b0 <default_pmm_manager+0x748>
ffffffffc0203f5a:	00002617          	auipc	a2,0x2
ffffffffc0203f5e:	a5e60613          	addi	a2,a2,-1442 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203f62:	10800593          	li	a1,264
ffffffffc0203f66:	00003517          	auipc	a0,0x3
ffffffffc0203f6a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203f6e:	cd8fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203f72:	00003697          	auipc	a3,0x3
ffffffffc0203f76:	bee68693          	addi	a3,a3,-1042 # ffffffffc0206b60 <default_pmm_manager+0xdf8>
ffffffffc0203f7a:	00002617          	auipc	a2,0x2
ffffffffc0203f7e:	a3e60613          	addi	a2,a2,-1474 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203f82:	10d00593          	li	a1,269
ffffffffc0203f86:	00003517          	auipc	a0,0x3
ffffffffc0203f8a:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203f8e:	cb8fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(sum == 0);
ffffffffc0203f92:	00003697          	auipc	a3,0x3
ffffffffc0203f96:	bee68693          	addi	a3,a3,-1042 # ffffffffc0206b80 <default_pmm_manager+0xe18>
ffffffffc0203f9a:	00002617          	auipc	a2,0x2
ffffffffc0203f9e:	a1e60613          	addi	a2,a2,-1506 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203fa2:	11700593          	li	a1,279
ffffffffc0203fa6:	00003517          	auipc	a0,0x3
ffffffffc0203faa:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203fae:	c98fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203fb2:	00002617          	auipc	a2,0x2
ffffffffc0203fb6:	ebe60613          	addi	a2,a2,-322 # ffffffffc0205e70 <default_pmm_manager+0x108>
ffffffffc0203fba:	06200593          	li	a1,98
ffffffffc0203fbe:	00002517          	auipc	a0,0x2
ffffffffc0203fc2:	e0a50513          	addi	a0,a0,-502 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0203fc6:	c80fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203fca:	00002617          	auipc	a2,0x2
ffffffffc0203fce:	dd660613          	addi	a2,a2,-554 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0203fd2:	06900593          	li	a1,105
ffffffffc0203fd6:	00002517          	auipc	a0,0x2
ffffffffc0203fda:	df250513          	addi	a0,a0,-526 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0203fde:	c68fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203fe2:	00003697          	auipc	a3,0x3
ffffffffc0203fe6:	bae68693          	addi	a3,a3,-1106 # ffffffffc0206b90 <default_pmm_manager+0xe28>
ffffffffc0203fea:	00002617          	auipc	a2,0x2
ffffffffc0203fee:	9ce60613          	addi	a2,a2,-1586 # ffffffffc02059b8 <commands+0x798>
ffffffffc0203ff2:	12400593          	li	a1,292
ffffffffc0203ff6:	00003517          	auipc	a0,0x3
ffffffffc0203ffa:	99a50513          	addi	a0,a0,-1638 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc0203ffe:	c48fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204002:	00002697          	auipc	a3,0x2
ffffffffc0204006:	49e68693          	addi	a3,a3,1182 # ffffffffc02064a0 <default_pmm_manager+0x738>
ffffffffc020400a:	00002617          	auipc	a2,0x2
ffffffffc020400e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc02059b8 <commands+0x798>
ffffffffc0204012:	10500593          	li	a1,261
ffffffffc0204016:	00003517          	auipc	a0,0x3
ffffffffc020401a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc020401e:	c28fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc0204022:	00002697          	auipc	a3,0x2
ffffffffc0204026:	45668693          	addi	a3,a3,1110 # ffffffffc0206478 <default_pmm_manager+0x710>
ffffffffc020402a:	00002617          	auipc	a2,0x2
ffffffffc020402e:	98e60613          	addi	a2,a2,-1650 # ffffffffc02059b8 <commands+0x798>
ffffffffc0204032:	0c200593          	li	a1,194
ffffffffc0204036:	00003517          	auipc	a0,0x3
ffffffffc020403a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0206990 <default_pmm_manager+0xc28>
ffffffffc020403e:	c08fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204042 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0204042:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204044:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0204046:	f022                	sd	s0,32(sp)
ffffffffc0204048:	ec26                	sd	s1,24(sp)
ffffffffc020404a:	f406                	sd	ra,40(sp)
ffffffffc020404c:	e84a                	sd	s2,16(sp)
ffffffffc020404e:	8432                	mv	s0,a2
ffffffffc0204050:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204052:	8dfff0ef          	jal	ra,ffffffffc0203930 <find_vma>

    pgfault_num++;
ffffffffc0204056:	00012797          	auipc	a5,0x12
ffffffffc020405a:	55a7a783          	lw	a5,1370(a5) # ffffffffc02165b0 <pgfault_num>
ffffffffc020405e:	2785                	addiw	a5,a5,1
ffffffffc0204060:	00012717          	auipc	a4,0x12
ffffffffc0204064:	54f72823          	sw	a5,1360(a4) # ffffffffc02165b0 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204068:	c551                	beqz	a0,ffffffffc02040f4 <do_pgfault+0xb2>
ffffffffc020406a:	651c                	ld	a5,8(a0)
ffffffffc020406c:	08f46463          	bltu	s0,a5,ffffffffc02040f4 <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204070:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204072:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204074:	8b89                	andi	a5,a5,2
ffffffffc0204076:	efb1                	bnez	a5,ffffffffc02040d2 <do_pgfault+0x90>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204078:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020407a:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020407c:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020407e:	4605                	li	a2,1
ffffffffc0204080:	85a2                	mv	a1,s0
ffffffffc0204082:	b1bfd0ef          	jal	ra,ffffffffc0201b9c <get_pte>
ffffffffc0204086:	c945                	beqz	a0,ffffffffc0204136 <do_pgfault+0xf4>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204088:	610c                	ld	a1,0(a0)
ffffffffc020408a:	c5b1                	beqz	a1,ffffffffc02040d6 <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc020408c:	00012797          	auipc	a5,0x12
ffffffffc0204090:	5147a783          	lw	a5,1300(a5) # ffffffffc02165a0 <swap_init_ok>
ffffffffc0204094:	cbad                	beqz	a5,ffffffffc0204106 <do_pgfault+0xc4>
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            // 检查 swap_in 是否成功
            if(swap_in(mm, addr, &page) !=0)
ffffffffc0204096:	0030                	addi	a2,sp,8
ffffffffc0204098:	85a2                	mv	a1,s0
ffffffffc020409a:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc020409c:	e402                	sd	zero,8(sp)
            if(swap_in(mm, addr, &page) !=0)
ffffffffc020409e:	b90ff0ef          	jal	ra,ffffffffc020342e <swap_in>
ffffffffc02040a2:	e935                	bnez	a0,ffffffffc0204116 <do_pgfault+0xd4>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            // 检查映射是否成功
            if(page_insert(mm->pgdir, page, addr, perm) != 0)
ffffffffc02040a4:	65a2                	ld	a1,8(sp)
ffffffffc02040a6:	6c88                	ld	a0,24(s1)
ffffffffc02040a8:	86ca                	mv	a3,s2
ffffffffc02040aa:	8622                	mv	a2,s0
ffffffffc02040ac:	db3fd0ef          	jal	ra,ffffffffc0201e5e <page_insert>
ffffffffc02040b0:	892a                	mv	s2,a0
ffffffffc02040b2:	e935                	bnez	a0,ffffffffc0204126 <do_pgfault+0xe4>
            {
            	cprintf("page_insert failed! \n");
            	goto failed;
            }
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 0);         
ffffffffc02040b4:	6622                	ld	a2,8(sp)
ffffffffc02040b6:	4681                	li	a3,0
ffffffffc02040b8:	85a2                	mv	a1,s0
ffffffffc02040ba:	8526                	mv	a0,s1
ffffffffc02040bc:	a52ff0ef          	jal	ra,ffffffffc020330e <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02040c0:	67a2                	ld	a5,8(sp)
ffffffffc02040c2:	ff80                	sd	s0,56(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc02040c4:	70a2                	ld	ra,40(sp)
ffffffffc02040c6:	7402                	ld	s0,32(sp)
ffffffffc02040c8:	64e2                	ld	s1,24(sp)
ffffffffc02040ca:	854a                	mv	a0,s2
ffffffffc02040cc:	6942                	ld	s2,16(sp)
ffffffffc02040ce:	6145                	addi	sp,sp,48
ffffffffc02040d0:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02040d2:	495d                	li	s2,23
ffffffffc02040d4:	b755                	j	ffffffffc0204078 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02040d6:	6c88                	ld	a0,24(s1)
ffffffffc02040d8:	864a                	mv	a2,s2
ffffffffc02040da:	85a2                	mv	a1,s0
ffffffffc02040dc:	a19fe0ef          	jal	ra,ffffffffc0202af4 <pgdir_alloc_page>
   ret = 0;
ffffffffc02040e0:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02040e2:	f16d                	bnez	a0,ffffffffc02040c4 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02040e4:	00003517          	auipc	a0,0x3
ffffffffc02040e8:	b7450513          	addi	a0,a0,-1164 # ffffffffc0206c58 <default_pmm_manager+0xef0>
ffffffffc02040ec:	894fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02040f0:	5971                	li	s2,-4
            goto failed;
ffffffffc02040f2:	bfc9                	j	ffffffffc02040c4 <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02040f4:	85a2                	mv	a1,s0
ffffffffc02040f6:	00003517          	auipc	a0,0x3
ffffffffc02040fa:	b1250513          	addi	a0,a0,-1262 # ffffffffc0206c08 <default_pmm_manager+0xea0>
ffffffffc02040fe:	882fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204102:	5975                	li	s2,-3
        goto failed;
ffffffffc0204104:	b7c1                	j	ffffffffc02040c4 <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204106:	00003517          	auipc	a0,0x3
ffffffffc020410a:	baa50513          	addi	a0,a0,-1110 # ffffffffc0206cb0 <default_pmm_manager+0xf48>
ffffffffc020410e:	872fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204112:	5971                	li	s2,-4
            goto failed;
ffffffffc0204114:	bf45                	j	ffffffffc02040c4 <do_pgfault+0x82>
            	cprintf("swap_in failed! \n");
ffffffffc0204116:	00003517          	auipc	a0,0x3
ffffffffc020411a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0206c80 <default_pmm_manager+0xf18>
ffffffffc020411e:	862fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204122:	5971                	li	s2,-4
ffffffffc0204124:	b745                	j	ffffffffc02040c4 <do_pgfault+0x82>
            	cprintf("page_insert failed! \n");
ffffffffc0204126:	00003517          	auipc	a0,0x3
ffffffffc020412a:	b7250513          	addi	a0,a0,-1166 # ffffffffc0206c98 <default_pmm_manager+0xf30>
ffffffffc020412e:	852fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204132:	5971                	li	s2,-4
ffffffffc0204134:	bf41                	j	ffffffffc02040c4 <do_pgfault+0x82>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204136:	00003517          	auipc	a0,0x3
ffffffffc020413a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0206c38 <default_pmm_manager+0xed0>
ffffffffc020413e:	842fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204142:	5971                	li	s2,-4
        goto failed;
ffffffffc0204144:	b741                	j	ffffffffc02040c4 <do_pgfault+0x82>

ffffffffc0204146 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204146:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204148:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc020414a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020414c:	c1cfc0ef          	jal	ra,ffffffffc0200568 <ide_device_valid>
ffffffffc0204150:	cd01                	beqz	a0,ffffffffc0204168 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204152:	4505                	li	a0,1
ffffffffc0204154:	c1afc0ef          	jal	ra,ffffffffc020056e <ide_device_size>
}
ffffffffc0204158:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020415a:	810d                	srli	a0,a0,0x3
ffffffffc020415c:	00012797          	auipc	a5,0x12
ffffffffc0204160:	42a7ba23          	sd	a0,1076(a5) # ffffffffc0216590 <max_swap_offset>
}
ffffffffc0204164:	0141                	addi	sp,sp,16
ffffffffc0204166:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204168:	00003617          	auipc	a2,0x3
ffffffffc020416c:	b7060613          	addi	a2,a2,-1168 # ffffffffc0206cd8 <default_pmm_manager+0xf70>
ffffffffc0204170:	45b5                	li	a1,13
ffffffffc0204172:	00003517          	auipc	a0,0x3
ffffffffc0204176:	b8650513          	addi	a0,a0,-1146 # ffffffffc0206cf8 <default_pmm_manager+0xf90>
ffffffffc020417a:	accfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020417e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc020417e:	1141                	addi	sp,sp,-16
ffffffffc0204180:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204182:	00855793          	srli	a5,a0,0x8
ffffffffc0204186:	cbb1                	beqz	a5,ffffffffc02041da <swapfs_read+0x5c>
ffffffffc0204188:	00012717          	auipc	a4,0x12
ffffffffc020418c:	40873703          	ld	a4,1032(a4) # ffffffffc0216590 <max_swap_offset>
ffffffffc0204190:	04e7f563          	bgeu	a5,a4,ffffffffc02041da <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204194:	00012617          	auipc	a2,0x12
ffffffffc0204198:	3e463603          	ld	a2,996(a2) # ffffffffc0216578 <pages>
ffffffffc020419c:	8d91                	sub	a1,a1,a2
ffffffffc020419e:	4065d613          	srai	a2,a1,0x6
ffffffffc02041a2:	00003717          	auipc	a4,0x3
ffffffffc02041a6:	f8673703          	ld	a4,-122(a4) # ffffffffc0207128 <nbase>
ffffffffc02041aa:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc02041ac:	00c61713          	slli	a4,a2,0xc
ffffffffc02041b0:	8331                	srli	a4,a4,0xc
ffffffffc02041b2:	00012697          	auipc	a3,0x12
ffffffffc02041b6:	3be6b683          	ld	a3,958(a3) # ffffffffc0216570 <npage>
ffffffffc02041ba:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041be:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02041c0:	02d77963          	bgeu	a4,a3,ffffffffc02041f2 <swapfs_read+0x74>
}
ffffffffc02041c4:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041c6:	00012797          	auipc	a5,0x12
ffffffffc02041ca:	3c27b783          	ld	a5,962(a5) # ffffffffc0216588 <va_pa_offset>
ffffffffc02041ce:	46a1                	li	a3,8
ffffffffc02041d0:	963e                	add	a2,a2,a5
ffffffffc02041d2:	4505                	li	a0,1
}
ffffffffc02041d4:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041d6:	b9efc06f          	j	ffffffffc0200574 <ide_read_secs>
ffffffffc02041da:	86aa                	mv	a3,a0
ffffffffc02041dc:	00003617          	auipc	a2,0x3
ffffffffc02041e0:	b3460613          	addi	a2,a2,-1228 # ffffffffc0206d10 <default_pmm_manager+0xfa8>
ffffffffc02041e4:	45d1                	li	a1,20
ffffffffc02041e6:	00003517          	auipc	a0,0x3
ffffffffc02041ea:	b1250513          	addi	a0,a0,-1262 # ffffffffc0206cf8 <default_pmm_manager+0xf90>
ffffffffc02041ee:	a58fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02041f2:	86b2                	mv	a3,a2
ffffffffc02041f4:	06900593          	li	a1,105
ffffffffc02041f8:	00002617          	auipc	a2,0x2
ffffffffc02041fc:	ba860613          	addi	a2,a2,-1112 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc0204200:	00002517          	auipc	a0,0x2
ffffffffc0204204:	bc850513          	addi	a0,a0,-1080 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0204208:	a3efc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020420c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc020420c:	1141                	addi	sp,sp,-16
ffffffffc020420e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204210:	00855793          	srli	a5,a0,0x8
ffffffffc0204214:	cbb1                	beqz	a5,ffffffffc0204268 <swapfs_write+0x5c>
ffffffffc0204216:	00012717          	auipc	a4,0x12
ffffffffc020421a:	37a73703          	ld	a4,890(a4) # ffffffffc0216590 <max_swap_offset>
ffffffffc020421e:	04e7f563          	bgeu	a5,a4,ffffffffc0204268 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204222:	00012617          	auipc	a2,0x12
ffffffffc0204226:	35663603          	ld	a2,854(a2) # ffffffffc0216578 <pages>
ffffffffc020422a:	8d91                	sub	a1,a1,a2
ffffffffc020422c:	4065d613          	srai	a2,a1,0x6
ffffffffc0204230:	00003717          	auipc	a4,0x3
ffffffffc0204234:	ef873703          	ld	a4,-264(a4) # ffffffffc0207128 <nbase>
ffffffffc0204238:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc020423a:	00c61713          	slli	a4,a2,0xc
ffffffffc020423e:	8331                	srli	a4,a4,0xc
ffffffffc0204240:	00012697          	auipc	a3,0x12
ffffffffc0204244:	3306b683          	ld	a3,816(a3) # ffffffffc0216570 <npage>
ffffffffc0204248:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc020424c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020424e:	02d77963          	bgeu	a4,a3,ffffffffc0204280 <swapfs_write+0x74>
}
ffffffffc0204252:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204254:	00012797          	auipc	a5,0x12
ffffffffc0204258:	3347b783          	ld	a5,820(a5) # ffffffffc0216588 <va_pa_offset>
ffffffffc020425c:	46a1                	li	a3,8
ffffffffc020425e:	963e                	add	a2,a2,a5
ffffffffc0204260:	4505                	li	a0,1
}
ffffffffc0204262:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204264:	b34fc06f          	j	ffffffffc0200598 <ide_write_secs>
ffffffffc0204268:	86aa                	mv	a3,a0
ffffffffc020426a:	00003617          	auipc	a2,0x3
ffffffffc020426e:	aa660613          	addi	a2,a2,-1370 # ffffffffc0206d10 <default_pmm_manager+0xfa8>
ffffffffc0204272:	45e5                	li	a1,25
ffffffffc0204274:	00003517          	auipc	a0,0x3
ffffffffc0204278:	a8450513          	addi	a0,a0,-1404 # ffffffffc0206cf8 <default_pmm_manager+0xf90>
ffffffffc020427c:	9cafc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0204280:	86b2                	mv	a3,a2
ffffffffc0204282:	06900593          	li	a1,105
ffffffffc0204286:	00002617          	auipc	a2,0x2
ffffffffc020428a:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc020428e:	00002517          	auipc	a0,0x2
ffffffffc0204292:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc0204296:	9b0fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020429a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020429a:	8526                	mv	a0,s1
	jalr s0
ffffffffc020429c:	9402                	jalr	s0

	jal do_exit
ffffffffc020429e:	496000ef          	jal	ra,ffffffffc0204734 <do_exit>

ffffffffc02042a2 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc02042a2:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02042a4:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc02042a8:	e022                	sd	s0,0(sp)
ffffffffc02042aa:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02042ac:	e06fd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
ffffffffc02042b0:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02042b2:	c521                	beqz	a0,ffffffffc02042fa <alloc_proc+0x58>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT; //状态设置为未初始化
ffffffffc02042b4:	57fd                	li	a5,-1
ffffffffc02042b6:	1782                	slli	a5,a5,0x20
ffffffffc02042b8:	e11c                	sd	a5,0(a0)
    proc->runs = 0; //运行次数默认为0
    proc->kstack = 0; //除了0号进程全需要后续分配
    proc->need_resched = 0; //不需要切换线程
    proc->parent = NULL; //没有父进程
    proc->mm = NULL; //一开始创建未分配内存
    memset(&(proc->context), 0, sizeof(struct context));//将上下文变量全部赋值为0，清空
ffffffffc02042ba:	07000613          	li	a2,112
ffffffffc02042be:	4581                	li	a1,0
    proc->runs = 0; //运行次数默认为0
ffffffffc02042c0:	00052423          	sw	zero,8(a0)
    proc->kstack = 0; //除了0号进程全需要后续分配
ffffffffc02042c4:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0; //不需要切换线程
ffffffffc02042c8:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL; //没有父进程
ffffffffc02042cc:	02053023          	sd	zero,32(a0)
    proc->mm = NULL; //一开始创建未分配内存
ffffffffc02042d0:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));//将上下文变量全部赋值为0，清空
ffffffffc02042d4:	03050513          	addi	a0,a0,48
ffffffffc02042d8:	493000ef          	jal	ra,ffffffffc0204f6a <memset>
    proc->tf = NULL; //初始化没有中断帧
    proc->cr3 = boot_cr3; //内核线程的cr3为boot_cr3，即页目录为内核页目录表
ffffffffc02042dc:	00012797          	auipc	a5,0x12
ffffffffc02042e0:	2847b783          	ld	a5,644(a5) # ffffffffc0216560 <boot_cr3>
    proc->tf = NULL; //初始化没有中断帧
ffffffffc02042e4:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3; //内核线程的cr3为boot_cr3，即页目录为内核页目录表
ffffffffc02042e8:	f45c                	sd	a5,168(s0)
    proc->flags = 0; //标志位设置为0
ffffffffc02042ea:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN+1); //将线程名变量全部赋值为0，清空
ffffffffc02042ee:	4641                	li	a2,16
ffffffffc02042f0:	4581                	li	a1,0
ffffffffc02042f2:	0b440513          	addi	a0,s0,180
ffffffffc02042f6:	475000ef          	jal	ra,ffffffffc0204f6a <memset>

    }
    return proc;
}
ffffffffc02042fa:	60a2                	ld	ra,8(sp)
ffffffffc02042fc:	8522                	mv	a0,s0
ffffffffc02042fe:	6402                	ld	s0,0(sp)
ffffffffc0204300:	0141                	addi	sp,sp,16
ffffffffc0204302:	8082                	ret

ffffffffc0204304 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204304:	00012797          	auipc	a5,0x12
ffffffffc0204308:	2b47b783          	ld	a5,692(a5) # ffffffffc02165b8 <current>
ffffffffc020430c:	73c8                	ld	a0,160(a5)
ffffffffc020430e:	8c3fc06f          	j	ffffffffc0200bd0 <forkrets>

ffffffffc0204312 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0204312:	7179                	addi	sp,sp,-48
ffffffffc0204314:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204316:	00012497          	auipc	s1,0x12
ffffffffc020431a:	20248493          	addi	s1,s1,514 # ffffffffc0216518 <name.2>
init_main(void *arg) {
ffffffffc020431e:	f022                	sd	s0,32(sp)
ffffffffc0204320:	e84a                	sd	s2,16(sp)
ffffffffc0204322:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204324:	00012917          	auipc	s2,0x12
ffffffffc0204328:	29493903          	ld	s2,660(s2) # ffffffffc02165b8 <current>
    memset(name, 0, sizeof(name));
ffffffffc020432c:	4641                	li	a2,16
ffffffffc020432e:	4581                	li	a1,0
ffffffffc0204330:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc0204332:	f406                	sd	ra,40(sp)
ffffffffc0204334:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204336:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc020433a:	431000ef          	jal	ra,ffffffffc0204f6a <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020433e:	0b490593          	addi	a1,s2,180
ffffffffc0204342:	463d                	li	a2,15
ffffffffc0204344:	8526                	mv	a0,s1
ffffffffc0204346:	437000ef          	jal	ra,ffffffffc0204f7c <memcpy>
ffffffffc020434a:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020434c:	85ce                	mv	a1,s3
ffffffffc020434e:	00003517          	auipc	a0,0x3
ffffffffc0204352:	9e250513          	addi	a0,a0,-1566 # ffffffffc0206d30 <default_pmm_manager+0xfc8>
ffffffffc0204356:	e2bfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020435a:	85a2                	mv	a1,s0
ffffffffc020435c:	00003517          	auipc	a0,0x3
ffffffffc0204360:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0206d58 <default_pmm_manager+0xff0>
ffffffffc0204364:	e1dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204368:	00003517          	auipc	a0,0x3
ffffffffc020436c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0206d68 <default_pmm_manager+0x1000>
ffffffffc0204370:	e11fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0204374:	70a2                	ld	ra,40(sp)
ffffffffc0204376:	7402                	ld	s0,32(sp)
ffffffffc0204378:	64e2                	ld	s1,24(sp)
ffffffffc020437a:	6942                	ld	s2,16(sp)
ffffffffc020437c:	69a2                	ld	s3,8(sp)
ffffffffc020437e:	4501                	li	a0,0
ffffffffc0204380:	6145                	addi	sp,sp,48
ffffffffc0204382:	8082                	ret

ffffffffc0204384 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204384:	7179                	addi	sp,sp,-48
ffffffffc0204386:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204388:	00012917          	auipc	s2,0x12
ffffffffc020438c:	23090913          	addi	s2,s2,560 # ffffffffc02165b8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204390:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204392:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204396:	f406                	sd	ra,40(sp)
ffffffffc0204398:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc020439a:	02a48963          	beq	s1,a0,ffffffffc02043cc <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020439e:	100027f3          	csrr	a5,sstatus
ffffffffc02043a2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02043a4:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02043a6:	e3a1                	bnez	a5,ffffffffc02043e6 <proc_run+0x62>
            lcr3(proc->cr3);
ffffffffc02043a8:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc02043aa:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc02043ae:	00a93023          	sd	a0,0(s2)
ffffffffc02043b2:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02043b6:	8fd9                	or	a5,a5,a4
ffffffffc02043b8:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc02043bc:	03050593          	addi	a1,a0,48
ffffffffc02043c0:	03048513          	addi	a0,s1,48
ffffffffc02043c4:	5f6000ef          	jal	ra,ffffffffc02049ba <switch_to>
    if (flag) {
ffffffffc02043c8:	00099863          	bnez	s3,ffffffffc02043d8 <proc_run+0x54>
}
ffffffffc02043cc:	70a2                	ld	ra,40(sp)
ffffffffc02043ce:	7482                	ld	s1,32(sp)
ffffffffc02043d0:	6962                	ld	s2,24(sp)
ffffffffc02043d2:	69c2                	ld	s3,16(sp)
ffffffffc02043d4:	6145                	addi	sp,sp,48
ffffffffc02043d6:	8082                	ret
ffffffffc02043d8:	70a2                	ld	ra,40(sp)
ffffffffc02043da:	7482                	ld	s1,32(sp)
ffffffffc02043dc:	6962                	ld	s2,24(sp)
ffffffffc02043de:	69c2                	ld	s3,16(sp)
ffffffffc02043e0:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02043e2:	9dafc06f          	j	ffffffffc02005bc <intr_enable>
ffffffffc02043e6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02043e8:	9dafc0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc02043ec:	6522                	ld	a0,8(sp)
ffffffffc02043ee:	4985                	li	s3,1
ffffffffc02043f0:	bf65                	j	ffffffffc02043a8 <proc_run+0x24>

ffffffffc02043f2 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043f2:	7179                	addi	sp,sp,-48
ffffffffc02043f4:	ec26                	sd	s1,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043f6:	00012497          	auipc	s1,0x12
ffffffffc02043fa:	1da48493          	addi	s1,s1,474 # ffffffffc02165d0 <nr_process>
ffffffffc02043fe:	4098                	lw	a4,0(s1)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204400:	f406                	sd	ra,40(sp)
ffffffffc0204402:	f022                	sd	s0,32(sp)
ffffffffc0204404:	e84a                	sd	s2,16(sp)
ffffffffc0204406:	e44e                	sd	s3,8(sp)
ffffffffc0204408:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020440a:	6785                	lui	a5,0x1
ffffffffc020440c:	26f75163          	bge	a4,a5,ffffffffc020466e <do_fork+0x27c>
ffffffffc0204410:	892e                	mv	s2,a1
ffffffffc0204412:	8432                	mv	s0,a2
    proc = alloc_proc();
ffffffffc0204414:	e8fff0ef          	jal	ra,ffffffffc02042a2 <alloc_proc>
ffffffffc0204418:	89aa                	mv	s3,a0
    if(!proc)
ffffffffc020441a:	24050f63          	beqz	a0,ffffffffc0204678 <do_fork+0x286>
    proc->parent = current;
ffffffffc020441e:	00012a17          	auipc	s4,0x12
ffffffffc0204422:	19aa0a13          	addi	s4,s4,410 # ffffffffc02165b8 <current>
ffffffffc0204426:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020442a:	4509                	li	a0,2
    proc->parent = current;
ffffffffc020442c:	02f9b023          	sd	a5,32(s3)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204430:	e60fd0ef          	jal	ra,ffffffffc0201a90 <alloc_pages>
    if (page != NULL) {
ffffffffc0204434:	1e050763          	beqz	a0,ffffffffc0204622 <do_fork+0x230>
    return page - pages + nbase;
ffffffffc0204438:	00012697          	auipc	a3,0x12
ffffffffc020443c:	1406b683          	ld	a3,320(a3) # ffffffffc0216578 <pages>
ffffffffc0204440:	40d506b3          	sub	a3,a0,a3
ffffffffc0204444:	8699                	srai	a3,a3,0x6
ffffffffc0204446:	00003517          	auipc	a0,0x3
ffffffffc020444a:	ce253503          	ld	a0,-798(a0) # ffffffffc0207128 <nbase>
ffffffffc020444e:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204450:	00c69793          	slli	a5,a3,0xc
ffffffffc0204454:	83b1                	srli	a5,a5,0xc
ffffffffc0204456:	00012717          	auipc	a4,0x12
ffffffffc020445a:	11a73703          	ld	a4,282(a4) # ffffffffc0216570 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020445e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204460:	22e7fe63          	bgeu	a5,a4,ffffffffc020469c <do_fork+0x2aa>
    assert(current->mm == NULL);
ffffffffc0204464:	000a3783          	ld	a5,0(s4)
ffffffffc0204468:	00012717          	auipc	a4,0x12
ffffffffc020446c:	12073703          	ld	a4,288(a4) # ffffffffc0216588 <va_pa_offset>
ffffffffc0204470:	96ba                	add	a3,a3,a4
ffffffffc0204472:	779c                	ld	a5,40(a5)
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204474:	00d9b823          	sd	a3,16(s3)
    assert(current->mm == NULL);
ffffffffc0204478:	20079263          	bnez	a5,ffffffffc020467c <do_fork+0x28a>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020447c:	6789                	lui	a5,0x2
ffffffffc020447e:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0204482:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204484:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204486:	0ad9b023          	sd	a3,160(s3)
    *(proc->tf) = *tf;
ffffffffc020448a:	87b6                	mv	a5,a3
ffffffffc020448c:	12040893          	addi	a7,s0,288
ffffffffc0204490:	00063803          	ld	a6,0(a2)
ffffffffc0204494:	6608                	ld	a0,8(a2)
ffffffffc0204496:	6a0c                	ld	a1,16(a2)
ffffffffc0204498:	6e18                	ld	a4,24(a2)
ffffffffc020449a:	0107b023          	sd	a6,0(a5)
ffffffffc020449e:	e788                	sd	a0,8(a5)
ffffffffc02044a0:	eb8c                	sd	a1,16(a5)
ffffffffc02044a2:	ef98                	sd	a4,24(a5)
ffffffffc02044a4:	02060613          	addi	a2,a2,32
ffffffffc02044a8:	02078793          	addi	a5,a5,32
ffffffffc02044ac:	ff1612e3          	bne	a2,a7,ffffffffc0204490 <do_fork+0x9e>
    proc->tf->gpr.a0 = 0;
ffffffffc02044b0:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044b4:	12090563          	beqz	s2,ffffffffc02045de <do_fork+0x1ec>
ffffffffc02044b8:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044bc:	00000797          	auipc	a5,0x0
ffffffffc02044c0:	e4878793          	addi	a5,a5,-440 # ffffffffc0204304 <forkret>
ffffffffc02044c4:	02f9b823          	sd	a5,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044c8:	02d9bc23          	sd	a3,56(s3)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044cc:	100027f3          	csrr	a5,sstatus
ffffffffc02044d0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044d2:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044d4:	12079663          	bnez	a5,ffffffffc0204600 <do_fork+0x20e>
    if (++ last_pid >= MAX_PID) {
ffffffffc02044d8:	00007817          	auipc	a6,0x7
ffffffffc02044dc:	b8080813          	addi	a6,a6,-1152 # ffffffffc020b058 <last_pid.1>
ffffffffc02044e0:	00082783          	lw	a5,0(a6)
ffffffffc02044e4:	6709                	lui	a4,0x2
ffffffffc02044e6:	0017851b          	addiw	a0,a5,1
ffffffffc02044ea:	00a82023          	sw	a0,0(a6)
ffffffffc02044ee:	08e55163          	bge	a0,a4,ffffffffc0204570 <do_fork+0x17e>
    if (last_pid >= next_safe) {
ffffffffc02044f2:	00007317          	auipc	t1,0x7
ffffffffc02044f6:	b6a30313          	addi	t1,t1,-1174 # ffffffffc020b05c <next_safe.0>
ffffffffc02044fa:	00032783          	lw	a5,0(t1)
ffffffffc02044fe:	00012417          	auipc	s0,0x12
ffffffffc0204502:	02a40413          	addi	s0,s0,42 # ffffffffc0216528 <proc_list>
ffffffffc0204506:	06f55d63          	bge	a0,a5,ffffffffc0204580 <do_fork+0x18e>
    proc->pid = get_pid(); 
ffffffffc020450a:	00a9a223          	sw	a0,4(s3)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020450e:	45a9                	li	a1,10
ffffffffc0204510:	2501                	sext.w	a0,a0
ffffffffc0204512:	5d8000ef          	jal	ra,ffffffffc0204aea <hash32>
ffffffffc0204516:	02051793          	slli	a5,a0,0x20
ffffffffc020451a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020451e:	0000e797          	auipc	a5,0xe
ffffffffc0204522:	ffa78793          	addi	a5,a5,-6 # ffffffffc0212518 <hash_list>
ffffffffc0204526:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204528:	6510                	ld	a2,8(a0)
ffffffffc020452a:	0d898793          	addi	a5,s3,216
ffffffffc020452e:	6414                	ld	a3,8(s0)
    nr_process ++;//更新进程数量计数器
ffffffffc0204530:	4098                	lw	a4,0(s1)
    prev->next = next->prev = elm;
ffffffffc0204532:	e21c                	sd	a5,0(a2)
ffffffffc0204534:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204536:	0ec9b023          	sd	a2,224(s3)
    list_add(&proc_list,&(proc->list_link));//将proc->list_link加到proc_list后
ffffffffc020453a:	0c898793          	addi	a5,s3,200
    elm->prev = prev;
ffffffffc020453e:	0ca9bc23          	sd	a0,216(s3)
    prev->next = next->prev = elm;
ffffffffc0204542:	e29c                	sd	a5,0(a3)
    nr_process ++;//更新进程数量计数器
ffffffffc0204544:	2705                	addiw	a4,a4,1
ffffffffc0204546:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204548:	0cd9b823          	sd	a3,208(s3)
    elm->prev = prev;
ffffffffc020454c:	0c89b423          	sd	s0,200(s3)
ffffffffc0204550:	c098                	sw	a4,0(s1)
    if (flag) {
ffffffffc0204552:	0a091b63          	bnez	s2,ffffffffc0204608 <do_fork+0x216>
    wakeup_proc(proc);
ffffffffc0204556:	854e                	mv	a0,s3
ffffffffc0204558:	4cc000ef          	jal	ra,ffffffffc0204a24 <wakeup_proc>
    ret = proc->pid;
ffffffffc020455c:	0049a503          	lw	a0,4(s3)
}
ffffffffc0204560:	70a2                	ld	ra,40(sp)
ffffffffc0204562:	7402                	ld	s0,32(sp)
ffffffffc0204564:	64e2                	ld	s1,24(sp)
ffffffffc0204566:	6942                	ld	s2,16(sp)
ffffffffc0204568:	69a2                	ld	s3,8(sp)
ffffffffc020456a:	6a02                	ld	s4,0(sp)
ffffffffc020456c:	6145                	addi	sp,sp,48
ffffffffc020456e:	8082                	ret
        last_pid = 1;
ffffffffc0204570:	4785                	li	a5,1
ffffffffc0204572:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204576:	4505                	li	a0,1
ffffffffc0204578:	00007317          	auipc	t1,0x7
ffffffffc020457c:	ae430313          	addi	t1,t1,-1308 # ffffffffc020b05c <next_safe.0>
    return listelm->next;
ffffffffc0204580:	00012417          	auipc	s0,0x12
ffffffffc0204584:	fa840413          	addi	s0,s0,-88 # ffffffffc0216528 <proc_list>
ffffffffc0204588:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020458c:	6789                	lui	a5,0x2
ffffffffc020458e:	00f32023          	sw	a5,0(t1)
ffffffffc0204592:	86aa                	mv	a3,a0
ffffffffc0204594:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0204596:	6e89                	lui	t4,0x2
ffffffffc0204598:	088e0063          	beq	t3,s0,ffffffffc0204618 <do_fork+0x226>
ffffffffc020459c:	88ae                	mv	a7,a1
ffffffffc020459e:	87f2                	mv	a5,t3
ffffffffc02045a0:	6609                	lui	a2,0x2
ffffffffc02045a2:	a811                	j	ffffffffc02045b6 <do_fork+0x1c4>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02045a4:	00e6d663          	bge	a3,a4,ffffffffc02045b0 <do_fork+0x1be>
ffffffffc02045a8:	00c75463          	bge	a4,a2,ffffffffc02045b0 <do_fork+0x1be>
ffffffffc02045ac:	863a                	mv	a2,a4
ffffffffc02045ae:	4885                	li	a7,1
ffffffffc02045b0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02045b2:	00878d63          	beq	a5,s0,ffffffffc02045cc <do_fork+0x1da>
            if (proc->pid == last_pid) {
ffffffffc02045b6:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc02045ba:	fed715e3          	bne	a4,a3,ffffffffc02045a4 <do_fork+0x1b2>
                if (++ last_pid >= next_safe) {
ffffffffc02045be:	2685                	addiw	a3,a3,1
ffffffffc02045c0:	04c6d763          	bge	a3,a2,ffffffffc020460e <do_fork+0x21c>
ffffffffc02045c4:	679c                	ld	a5,8(a5)
ffffffffc02045c6:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc02045c8:	fe8797e3          	bne	a5,s0,ffffffffc02045b6 <do_fork+0x1c4>
ffffffffc02045cc:	c581                	beqz	a1,ffffffffc02045d4 <do_fork+0x1e2>
ffffffffc02045ce:	00d82023          	sw	a3,0(a6)
ffffffffc02045d2:	8536                	mv	a0,a3
ffffffffc02045d4:	f2088be3          	beqz	a7,ffffffffc020450a <do_fork+0x118>
ffffffffc02045d8:	00c32023          	sw	a2,0(t1)
ffffffffc02045dc:	b73d                	j	ffffffffc020450a <do_fork+0x118>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045de:	8936                	mv	s2,a3
ffffffffc02045e0:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02045e4:	00000797          	auipc	a5,0x0
ffffffffc02045e8:	d2078793          	addi	a5,a5,-736 # ffffffffc0204304 <forkret>
ffffffffc02045ec:	02f9b823          	sd	a5,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02045f0:	02d9bc23          	sd	a3,56(s3)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045f4:	100027f3          	csrr	a5,sstatus
ffffffffc02045f8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045fa:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045fc:	ec078ee3          	beqz	a5,ffffffffc02044d8 <do_fork+0xe6>
        intr_disable();
ffffffffc0204600:	fc3fb0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0204604:	4905                	li	s2,1
ffffffffc0204606:	bdc9                	j	ffffffffc02044d8 <do_fork+0xe6>
        intr_enable();
ffffffffc0204608:	fb5fb0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020460c:	b7a9                	j	ffffffffc0204556 <do_fork+0x164>
                    if (last_pid >= MAX_PID) {
ffffffffc020460e:	01d6c363          	blt	a3,t4,ffffffffc0204614 <do_fork+0x222>
                        last_pid = 1;
ffffffffc0204612:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204614:	4585                	li	a1,1
ffffffffc0204616:	b749                	j	ffffffffc0204598 <do_fork+0x1a6>
ffffffffc0204618:	cda9                	beqz	a1,ffffffffc0204672 <do_fork+0x280>
ffffffffc020461a:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020461e:	8536                	mv	a0,a3
ffffffffc0204620:	b5ed                	j	ffffffffc020450a <do_fork+0x118>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204622:	0109b683          	ld	a3,16(s3)
    return pa2page(PADDR(kva));
ffffffffc0204626:	c02007b7          	lui	a5,0xc0200
ffffffffc020462a:	0af6e163          	bltu	a3,a5,ffffffffc02046cc <do_fork+0x2da>
ffffffffc020462e:	00012797          	auipc	a5,0x12
ffffffffc0204632:	f5a7b783          	ld	a5,-166(a5) # ffffffffc0216588 <va_pa_offset>
ffffffffc0204636:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020463a:	83b1                	srli	a5,a5,0xc
ffffffffc020463c:	00012717          	auipc	a4,0x12
ffffffffc0204640:	f3473703          	ld	a4,-204(a4) # ffffffffc0216570 <npage>
ffffffffc0204644:	06e7f863          	bgeu	a5,a4,ffffffffc02046b4 <do_fork+0x2c2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204648:	00003717          	auipc	a4,0x3
ffffffffc020464c:	ae073703          	ld	a4,-1312(a4) # ffffffffc0207128 <nbase>
ffffffffc0204650:	8f99                	sub	a5,a5,a4
ffffffffc0204652:	079a                	slli	a5,a5,0x6
ffffffffc0204654:	00012517          	auipc	a0,0x12
ffffffffc0204658:	f2453503          	ld	a0,-220(a0) # ffffffffc0216578 <pages>
ffffffffc020465c:	953e                	add	a0,a0,a5
ffffffffc020465e:	4589                	li	a1,2
ffffffffc0204660:	cc2fd0ef          	jal	ra,ffffffffc0201b22 <free_pages>
    kfree(proc);
ffffffffc0204664:	854e                	mv	a0,s3
ffffffffc0204666:	afcfd0ef          	jal	ra,ffffffffc0201962 <kfree>
    ret = -E_NO_MEM;
ffffffffc020466a:	5571                	li	a0,-4
    goto fork_out;
ffffffffc020466c:	bdd5                	j	ffffffffc0204560 <do_fork+0x16e>
    int ret = -E_NO_FREE_PROC;
ffffffffc020466e:	556d                	li	a0,-5
ffffffffc0204670:	bdc5                	j	ffffffffc0204560 <do_fork+0x16e>
    return last_pid;
ffffffffc0204672:	00082503          	lw	a0,0(a6)
ffffffffc0204676:	bd51                	j	ffffffffc020450a <do_fork+0x118>
    ret = -E_NO_MEM;
ffffffffc0204678:	5571                	li	a0,-4
    return ret;
ffffffffc020467a:	b5dd                	j	ffffffffc0204560 <do_fork+0x16e>
    assert(current->mm == NULL);
ffffffffc020467c:	00002697          	auipc	a3,0x2
ffffffffc0204680:	70c68693          	addi	a3,a3,1804 # ffffffffc0206d88 <default_pmm_manager+0x1020>
ffffffffc0204684:	00001617          	auipc	a2,0x1
ffffffffc0204688:	33460613          	addi	a2,a2,820 # ffffffffc02059b8 <commands+0x798>
ffffffffc020468c:	10c00593          	li	a1,268
ffffffffc0204690:	00002517          	auipc	a0,0x2
ffffffffc0204694:	71050513          	addi	a0,a0,1808 # ffffffffc0206da0 <default_pmm_manager+0x1038>
ffffffffc0204698:	daffb0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc020469c:	00001617          	auipc	a2,0x1
ffffffffc02046a0:	70460613          	addi	a2,a2,1796 # ffffffffc0205da0 <default_pmm_manager+0x38>
ffffffffc02046a4:	06900593          	li	a1,105
ffffffffc02046a8:	00001517          	auipc	a0,0x1
ffffffffc02046ac:	72050513          	addi	a0,a0,1824 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc02046b0:	d97fb0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02046b4:	00001617          	auipc	a2,0x1
ffffffffc02046b8:	7bc60613          	addi	a2,a2,1980 # ffffffffc0205e70 <default_pmm_manager+0x108>
ffffffffc02046bc:	06200593          	li	a1,98
ffffffffc02046c0:	00001517          	auipc	a0,0x1
ffffffffc02046c4:	70850513          	addi	a0,a0,1800 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc02046c8:	d7ffb0ef          	jal	ra,ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02046cc:	00001617          	auipc	a2,0x1
ffffffffc02046d0:	77c60613          	addi	a2,a2,1916 # ffffffffc0205e48 <default_pmm_manager+0xe0>
ffffffffc02046d4:	06e00593          	li	a1,110
ffffffffc02046d8:	00001517          	auipc	a0,0x1
ffffffffc02046dc:	6f050513          	addi	a0,a0,1776 # ffffffffc0205dc8 <default_pmm_manager+0x60>
ffffffffc02046e0:	d67fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02046e4 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02046e4:	7129                	addi	sp,sp,-320
ffffffffc02046e6:	fa22                	sd	s0,304(sp)
ffffffffc02046e8:	f626                	sd	s1,296(sp)
ffffffffc02046ea:	f24a                	sd	s2,288(sp)
ffffffffc02046ec:	84ae                	mv	s1,a1
ffffffffc02046ee:	892a                	mv	s2,a0
ffffffffc02046f0:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046f2:	4581                	li	a1,0
ffffffffc02046f4:	12000613          	li	a2,288
ffffffffc02046f8:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02046fa:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046fc:	06f000ef          	jal	ra,ffffffffc0204f6a <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204700:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204702:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204704:	100027f3          	csrr	a5,sstatus
ffffffffc0204708:	edd7f793          	andi	a5,a5,-291
ffffffffc020470c:	1207e793          	ori	a5,a5,288
ffffffffc0204710:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204712:	860a                	mv	a2,sp
ffffffffc0204714:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204718:	00000797          	auipc	a5,0x0
ffffffffc020471c:	b8278793          	addi	a5,a5,-1150 # ffffffffc020429a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204720:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204722:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204724:	ccfff0ef          	jal	ra,ffffffffc02043f2 <do_fork>
}
ffffffffc0204728:	70f2                	ld	ra,312(sp)
ffffffffc020472a:	7452                	ld	s0,304(sp)
ffffffffc020472c:	74b2                	ld	s1,296(sp)
ffffffffc020472e:	7912                	ld	s2,288(sp)
ffffffffc0204730:	6131                	addi	sp,sp,320
ffffffffc0204732:	8082                	ret

ffffffffc0204734 <do_exit>:
do_exit(int error_code) {
ffffffffc0204734:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204736:	00002617          	auipc	a2,0x2
ffffffffc020473a:	68260613          	addi	a2,a2,1666 # ffffffffc0206db8 <default_pmm_manager+0x1050>
ffffffffc020473e:	18b00593          	li	a1,395
ffffffffc0204742:	00002517          	auipc	a0,0x2
ffffffffc0204746:	65e50513          	addi	a0,a0,1630 # ffffffffc0206da0 <default_pmm_manager+0x1038>
do_exit(int error_code) {
ffffffffc020474a:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc020474c:	cfbfb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204750 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204750:	7179                	addi	sp,sp,-48
ffffffffc0204752:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc0204754:	00012797          	auipc	a5,0x12
ffffffffc0204758:	dd478793          	addi	a5,a5,-556 # ffffffffc0216528 <proc_list>
ffffffffc020475c:	f406                	sd	ra,40(sp)
ffffffffc020475e:	f022                	sd	s0,32(sp)
ffffffffc0204760:	e84a                	sd	s2,16(sp)
ffffffffc0204762:	e44e                	sd	s3,8(sp)
ffffffffc0204764:	0000e497          	auipc	s1,0xe
ffffffffc0204768:	db448493          	addi	s1,s1,-588 # ffffffffc0212518 <hash_list>
ffffffffc020476c:	e79c                	sd	a5,8(a5)
ffffffffc020476e:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204770:	00012717          	auipc	a4,0x12
ffffffffc0204774:	da870713          	addi	a4,a4,-600 # ffffffffc0216518 <name.2>
ffffffffc0204778:	87a6                	mv	a5,s1
ffffffffc020477a:	e79c                	sd	a5,8(a5)
ffffffffc020477c:	e39c                	sd	a5,0(a5)
ffffffffc020477e:	07c1                	addi	a5,a5,16
ffffffffc0204780:	fef71de3          	bne	a4,a5,ffffffffc020477a <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204784:	b1fff0ef          	jal	ra,ffffffffc02042a2 <alloc_proc>
ffffffffc0204788:	00012917          	auipc	s2,0x12
ffffffffc020478c:	e3890913          	addi	s2,s2,-456 # ffffffffc02165c0 <idleproc>
ffffffffc0204790:	00a93023          	sd	a0,0(s2)
ffffffffc0204794:	18050d63          	beqz	a0,ffffffffc020492e <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204798:	07000513          	li	a0,112
ffffffffc020479c:	916fd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02047a0:	07000613          	li	a2,112
ffffffffc02047a4:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02047a6:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02047a8:	7c2000ef          	jal	ra,ffffffffc0204f6a <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02047ac:	00093503          	ld	a0,0(s2)
ffffffffc02047b0:	85a2                	mv	a1,s0
ffffffffc02047b2:	07000613          	li	a2,112
ffffffffc02047b6:	03050513          	addi	a0,a0,48
ffffffffc02047ba:	7da000ef          	jal	ra,ffffffffc0204f94 <memcmp>
ffffffffc02047be:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02047c0:	453d                	li	a0,15
ffffffffc02047c2:	8f0fd0ef          	jal	ra,ffffffffc02018b2 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02047c6:	463d                	li	a2,15
ffffffffc02047c8:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02047ca:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02047cc:	79e000ef          	jal	ra,ffffffffc0204f6a <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02047d0:	00093503          	ld	a0,0(s2)
ffffffffc02047d4:	463d                	li	a2,15
ffffffffc02047d6:	85a2                	mv	a1,s0
ffffffffc02047d8:	0b450513          	addi	a0,a0,180
ffffffffc02047dc:	7b8000ef          	jal	ra,ffffffffc0204f94 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02047e0:	00093783          	ld	a5,0(s2)
ffffffffc02047e4:	00012717          	auipc	a4,0x12
ffffffffc02047e8:	d7c73703          	ld	a4,-644(a4) # ffffffffc0216560 <boot_cr3>
ffffffffc02047ec:	77d4                	ld	a3,168(a5)
ffffffffc02047ee:	0ee68463          	beq	a3,a4,ffffffffc02048d6 <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02047f2:	4709                	li	a4,2
ffffffffc02047f4:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02047f6:	00004717          	auipc	a4,0x4
ffffffffc02047fa:	80a70713          	addi	a4,a4,-2038 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047fe:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204802:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204804:	4705                	li	a4,1
ffffffffc0204806:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204808:	4641                	li	a2,16
ffffffffc020480a:	4581                	li	a1,0
ffffffffc020480c:	8522                	mv	a0,s0
ffffffffc020480e:	75c000ef          	jal	ra,ffffffffc0204f6a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204812:	463d                	li	a2,15
ffffffffc0204814:	00002597          	auipc	a1,0x2
ffffffffc0204818:	5ec58593          	addi	a1,a1,1516 # ffffffffc0206e00 <default_pmm_manager+0x1098>
ffffffffc020481c:	8522                	mv	a0,s0
ffffffffc020481e:	75e000ef          	jal	ra,ffffffffc0204f7c <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204822:	00012717          	auipc	a4,0x12
ffffffffc0204826:	dae70713          	addi	a4,a4,-594 # ffffffffc02165d0 <nr_process>
ffffffffc020482a:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020482c:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204830:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204832:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204834:	00002597          	auipc	a1,0x2
ffffffffc0204838:	5d458593          	addi	a1,a1,1492 # ffffffffc0206e08 <default_pmm_manager+0x10a0>
ffffffffc020483c:	00000517          	auipc	a0,0x0
ffffffffc0204840:	ad650513          	addi	a0,a0,-1322 # ffffffffc0204312 <init_main>
    nr_process ++;
ffffffffc0204844:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204846:	00012797          	auipc	a5,0x12
ffffffffc020484a:	d6d7b923          	sd	a3,-654(a5) # ffffffffc02165b8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020484e:	e97ff0ef          	jal	ra,ffffffffc02046e4 <kernel_thread>
ffffffffc0204852:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0204854:	0ea05963          	blez	a0,ffffffffc0204946 <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204858:	6789                	lui	a5,0x2
ffffffffc020485a:	fff5071b          	addiw	a4,a0,-1
ffffffffc020485e:	17f9                	addi	a5,a5,-2
ffffffffc0204860:	2501                	sext.w	a0,a0
ffffffffc0204862:	02e7e363          	bltu	a5,a4,ffffffffc0204888 <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204866:	45a9                	li	a1,10
ffffffffc0204868:	282000ef          	jal	ra,ffffffffc0204aea <hash32>
ffffffffc020486c:	02051793          	slli	a5,a0,0x20
ffffffffc0204870:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204874:	96a6                	add	a3,a3,s1
ffffffffc0204876:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204878:	a029                	j	ffffffffc0204882 <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc020487a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc020487e:	0a870563          	beq	a4,s0,ffffffffc0204928 <proc_init+0x1d8>
    return listelm->next;
ffffffffc0204882:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204884:	fef69be3          	bne	a3,a5,ffffffffc020487a <proc_init+0x12a>
    return NULL;
ffffffffc0204888:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020488a:	0b478493          	addi	s1,a5,180
ffffffffc020488e:	4641                	li	a2,16
ffffffffc0204890:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204892:	00012417          	auipc	s0,0x12
ffffffffc0204896:	d3640413          	addi	s0,s0,-714 # ffffffffc02165c8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020489a:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020489c:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020489e:	6cc000ef          	jal	ra,ffffffffc0204f6a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02048a2:	463d                	li	a2,15
ffffffffc02048a4:	00002597          	auipc	a1,0x2
ffffffffc02048a8:	59458593          	addi	a1,a1,1428 # ffffffffc0206e38 <default_pmm_manager+0x10d0>
ffffffffc02048ac:	8526                	mv	a0,s1
ffffffffc02048ae:	6ce000ef          	jal	ra,ffffffffc0204f7c <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02048b2:	00093783          	ld	a5,0(s2)
ffffffffc02048b6:	c7e1                	beqz	a5,ffffffffc020497e <proc_init+0x22e>
ffffffffc02048b8:	43dc                	lw	a5,4(a5)
ffffffffc02048ba:	e3f1                	bnez	a5,ffffffffc020497e <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02048bc:	601c                	ld	a5,0(s0)
ffffffffc02048be:	c3c5                	beqz	a5,ffffffffc020495e <proc_init+0x20e>
ffffffffc02048c0:	43d8                	lw	a4,4(a5)
ffffffffc02048c2:	4785                	li	a5,1
ffffffffc02048c4:	08f71d63          	bne	a4,a5,ffffffffc020495e <proc_init+0x20e>
}
ffffffffc02048c8:	70a2                	ld	ra,40(sp)
ffffffffc02048ca:	7402                	ld	s0,32(sp)
ffffffffc02048cc:	64e2                	ld	s1,24(sp)
ffffffffc02048ce:	6942                	ld	s2,16(sp)
ffffffffc02048d0:	69a2                	ld	s3,8(sp)
ffffffffc02048d2:	6145                	addi	sp,sp,48
ffffffffc02048d4:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02048d6:	73d8                	ld	a4,160(a5)
ffffffffc02048d8:	ff09                	bnez	a4,ffffffffc02047f2 <proc_init+0xa2>
ffffffffc02048da:	f0099ce3          	bnez	s3,ffffffffc02047f2 <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02048de:	6394                	ld	a3,0(a5)
ffffffffc02048e0:	577d                	li	a4,-1
ffffffffc02048e2:	1702                	slli	a4,a4,0x20
ffffffffc02048e4:	f0e697e3          	bne	a3,a4,ffffffffc02047f2 <proc_init+0xa2>
ffffffffc02048e8:	4798                	lw	a4,8(a5)
ffffffffc02048ea:	f00714e3          	bnez	a4,ffffffffc02047f2 <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02048ee:	6b98                	ld	a4,16(a5)
ffffffffc02048f0:	f00711e3          	bnez	a4,ffffffffc02047f2 <proc_init+0xa2>
ffffffffc02048f4:	4f98                	lw	a4,24(a5)
ffffffffc02048f6:	2701                	sext.w	a4,a4
ffffffffc02048f8:	ee071de3          	bnez	a4,ffffffffc02047f2 <proc_init+0xa2>
ffffffffc02048fc:	7398                	ld	a4,32(a5)
ffffffffc02048fe:	ee071ae3          	bnez	a4,ffffffffc02047f2 <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204902:	7798                	ld	a4,40(a5)
ffffffffc0204904:	ee0717e3          	bnez	a4,ffffffffc02047f2 <proc_init+0xa2>
ffffffffc0204908:	0b07a703          	lw	a4,176(a5)
ffffffffc020490c:	8d59                	or	a0,a0,a4
ffffffffc020490e:	0005071b          	sext.w	a4,a0
ffffffffc0204912:	ee0710e3          	bnez	a4,ffffffffc02047f2 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204916:	00002517          	auipc	a0,0x2
ffffffffc020491a:	4d250513          	addi	a0,a0,1234 # ffffffffc0206de8 <default_pmm_manager+0x1080>
ffffffffc020491e:	863fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    idleproc->pid = 0;
ffffffffc0204922:	00093783          	ld	a5,0(s2)
ffffffffc0204926:	b5f1                	j	ffffffffc02047f2 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204928:	f2878793          	addi	a5,a5,-216
ffffffffc020492c:	bfb9                	j	ffffffffc020488a <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc020492e:	00002617          	auipc	a2,0x2
ffffffffc0204932:	4a260613          	addi	a2,a2,1186 # ffffffffc0206dd0 <default_pmm_manager+0x1068>
ffffffffc0204936:	1a300593          	li	a1,419
ffffffffc020493a:	00002517          	auipc	a0,0x2
ffffffffc020493e:	46650513          	addi	a0,a0,1126 # ffffffffc0206da0 <default_pmm_manager+0x1038>
ffffffffc0204942:	b05fb0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204946:	00002617          	auipc	a2,0x2
ffffffffc020494a:	4d260613          	addi	a2,a2,1234 # ffffffffc0206e18 <default_pmm_manager+0x10b0>
ffffffffc020494e:	1c300593          	li	a1,451
ffffffffc0204952:	00002517          	auipc	a0,0x2
ffffffffc0204956:	44e50513          	addi	a0,a0,1102 # ffffffffc0206da0 <default_pmm_manager+0x1038>
ffffffffc020495a:	aedfb0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020495e:	00002697          	auipc	a3,0x2
ffffffffc0204962:	50a68693          	addi	a3,a3,1290 # ffffffffc0206e68 <default_pmm_manager+0x1100>
ffffffffc0204966:	00001617          	auipc	a2,0x1
ffffffffc020496a:	05260613          	addi	a2,a2,82 # ffffffffc02059b8 <commands+0x798>
ffffffffc020496e:	1ca00593          	li	a1,458
ffffffffc0204972:	00002517          	auipc	a0,0x2
ffffffffc0204976:	42e50513          	addi	a0,a0,1070 # ffffffffc0206da0 <default_pmm_manager+0x1038>
ffffffffc020497a:	acdfb0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020497e:	00002697          	auipc	a3,0x2
ffffffffc0204982:	4c268693          	addi	a3,a3,1218 # ffffffffc0206e40 <default_pmm_manager+0x10d8>
ffffffffc0204986:	00001617          	auipc	a2,0x1
ffffffffc020498a:	03260613          	addi	a2,a2,50 # ffffffffc02059b8 <commands+0x798>
ffffffffc020498e:	1c900593          	li	a1,457
ffffffffc0204992:	00002517          	auipc	a0,0x2
ffffffffc0204996:	40e50513          	addi	a0,a0,1038 # ffffffffc0206da0 <default_pmm_manager+0x1038>
ffffffffc020499a:	aadfb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020499e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020499e:	1141                	addi	sp,sp,-16
ffffffffc02049a0:	e022                	sd	s0,0(sp)
ffffffffc02049a2:	e406                	sd	ra,8(sp)
ffffffffc02049a4:	00012417          	auipc	s0,0x12
ffffffffc02049a8:	c1440413          	addi	s0,s0,-1004 # ffffffffc02165b8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02049ac:	6018                	ld	a4,0(s0)
ffffffffc02049ae:	4f1c                	lw	a5,24(a4)
ffffffffc02049b0:	2781                	sext.w	a5,a5
ffffffffc02049b2:	dff5                	beqz	a5,ffffffffc02049ae <cpu_idle+0x10>
            schedule();
ffffffffc02049b4:	0a2000ef          	jal	ra,ffffffffc0204a56 <schedule>
ffffffffc02049b8:	bfd5                	j	ffffffffc02049ac <cpu_idle+0xe>

ffffffffc02049ba <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02049ba:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02049be:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02049c2:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02049c4:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02049c6:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02049ca:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02049ce:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02049d2:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02049d6:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02049da:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02049de:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02049e2:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02049e6:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02049ea:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02049ee:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02049f2:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02049f6:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02049f8:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02049fa:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02049fe:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204a02:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204a06:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204a0a:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204a0e:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204a12:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204a16:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204a1a:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204a1e:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204a22:	8082                	ret

ffffffffc0204a24 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204a24:	411c                	lw	a5,0(a0)
ffffffffc0204a26:	4705                	li	a4,1
ffffffffc0204a28:	37f9                	addiw	a5,a5,-2
ffffffffc0204a2a:	00f77563          	bgeu	a4,a5,ffffffffc0204a34 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204a2e:	4789                	li	a5,2
ffffffffc0204a30:	c11c                	sw	a5,0(a0)
ffffffffc0204a32:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204a34:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204a36:	00002697          	auipc	a3,0x2
ffffffffc0204a3a:	45a68693          	addi	a3,a3,1114 # ffffffffc0206e90 <default_pmm_manager+0x1128>
ffffffffc0204a3e:	00001617          	auipc	a2,0x1
ffffffffc0204a42:	f7a60613          	addi	a2,a2,-134 # ffffffffc02059b8 <commands+0x798>
ffffffffc0204a46:	45a5                	li	a1,9
ffffffffc0204a48:	00002517          	auipc	a0,0x2
ffffffffc0204a4c:	48850513          	addi	a0,a0,1160 # ffffffffc0206ed0 <default_pmm_manager+0x1168>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204a50:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204a52:	9f5fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204a56 <schedule>:
}

void
schedule(void) {
ffffffffc0204a56:	1141                	addi	sp,sp,-16
ffffffffc0204a58:	e406                	sd	ra,8(sp)
ffffffffc0204a5a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a5c:	100027f3          	csrr	a5,sstatus
ffffffffc0204a60:	8b89                	andi	a5,a5,2
ffffffffc0204a62:	4401                	li	s0,0
ffffffffc0204a64:	efbd                	bnez	a5,ffffffffc0204ae2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204a66:	00012897          	auipc	a7,0x12
ffffffffc0204a6a:	b528b883          	ld	a7,-1198(a7) # ffffffffc02165b8 <current>
ffffffffc0204a6e:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204a72:	00012517          	auipc	a0,0x12
ffffffffc0204a76:	b4e53503          	ld	a0,-1202(a0) # ffffffffc02165c0 <idleproc>
ffffffffc0204a7a:	04a88e63          	beq	a7,a0,ffffffffc0204ad6 <schedule+0x80>
ffffffffc0204a7e:	0c888693          	addi	a3,a7,200
ffffffffc0204a82:	00012617          	auipc	a2,0x12
ffffffffc0204a86:	aa660613          	addi	a2,a2,-1370 # ffffffffc0216528 <proc_list>
        le = last;
ffffffffc0204a8a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204a8c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a8e:	4809                	li	a6,2
ffffffffc0204a90:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204a92:	00c78863          	beq	a5,a2,ffffffffc0204aa2 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a96:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204a9a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a9e:	03070163          	beq	a4,a6,ffffffffc0204ac0 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204aa2:	fef697e3          	bne	a3,a5,ffffffffc0204a90 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204aa6:	ed89                	bnez	a1,ffffffffc0204ac0 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204aa8:	451c                	lw	a5,8(a0)
ffffffffc0204aaa:	2785                	addiw	a5,a5,1
ffffffffc0204aac:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204aae:	00a88463          	beq	a7,a0,ffffffffc0204ab6 <schedule+0x60>
            proc_run(next);
ffffffffc0204ab2:	8d3ff0ef          	jal	ra,ffffffffc0204384 <proc_run>
    if (flag) {
ffffffffc0204ab6:	e819                	bnez	s0,ffffffffc0204acc <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204ab8:	60a2                	ld	ra,8(sp)
ffffffffc0204aba:	6402                	ld	s0,0(sp)
ffffffffc0204abc:	0141                	addi	sp,sp,16
ffffffffc0204abe:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204ac0:	4198                	lw	a4,0(a1)
ffffffffc0204ac2:	4789                	li	a5,2
ffffffffc0204ac4:	fef712e3          	bne	a4,a5,ffffffffc0204aa8 <schedule+0x52>
ffffffffc0204ac8:	852e                	mv	a0,a1
ffffffffc0204aca:	bff9                	j	ffffffffc0204aa8 <schedule+0x52>
}
ffffffffc0204acc:	6402                	ld	s0,0(sp)
ffffffffc0204ace:	60a2                	ld	ra,8(sp)
ffffffffc0204ad0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204ad2:	aebfb06f          	j	ffffffffc02005bc <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204ad6:	00012617          	auipc	a2,0x12
ffffffffc0204ada:	a5260613          	addi	a2,a2,-1454 # ffffffffc0216528 <proc_list>
ffffffffc0204ade:	86b2                	mv	a3,a2
ffffffffc0204ae0:	b76d                	j	ffffffffc0204a8a <schedule+0x34>
        intr_disable();
ffffffffc0204ae2:	ae1fb0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0204ae6:	4405                	li	s0,1
ffffffffc0204ae8:	bfbd                	j	ffffffffc0204a66 <schedule+0x10>

ffffffffc0204aea <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204aea:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204aee:	2785                	addiw	a5,a5,1
ffffffffc0204af0:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204af4:	02000793          	li	a5,32
ffffffffc0204af8:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204afa:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204afe:	8082                	ret

ffffffffc0204b00 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204b00:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204b04:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204b06:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204b0a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204b0c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204b10:	f022                	sd	s0,32(sp)
ffffffffc0204b12:	ec26                	sd	s1,24(sp)
ffffffffc0204b14:	e84a                	sd	s2,16(sp)
ffffffffc0204b16:	f406                	sd	ra,40(sp)
ffffffffc0204b18:	e44e                	sd	s3,8(sp)
ffffffffc0204b1a:	84aa                	mv	s1,a0
ffffffffc0204b1c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204b1e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204b22:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204b24:	03067e63          	bgeu	a2,a6,ffffffffc0204b60 <printnum+0x60>
ffffffffc0204b28:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204b2a:	00805763          	blez	s0,ffffffffc0204b38 <printnum+0x38>
ffffffffc0204b2e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204b30:	85ca                	mv	a1,s2
ffffffffc0204b32:	854e                	mv	a0,s3
ffffffffc0204b34:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204b36:	fc65                	bnez	s0,ffffffffc0204b2e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b38:	1a02                	slli	s4,s4,0x20
ffffffffc0204b3a:	00002797          	auipc	a5,0x2
ffffffffc0204b3e:	3ae78793          	addi	a5,a5,942 # ffffffffc0206ee8 <default_pmm_manager+0x1180>
ffffffffc0204b42:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204b46:	9a3e                	add	s4,s4,a5
}
ffffffffc0204b48:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b4a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204b4e:	70a2                	ld	ra,40(sp)
ffffffffc0204b50:	69a2                	ld	s3,8(sp)
ffffffffc0204b52:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b54:	85ca                	mv	a1,s2
ffffffffc0204b56:	87a6                	mv	a5,s1
}
ffffffffc0204b58:	6942                	ld	s2,16(sp)
ffffffffc0204b5a:	64e2                	ld	s1,24(sp)
ffffffffc0204b5c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b5e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204b60:	03065633          	divu	a2,a2,a6
ffffffffc0204b64:	8722                	mv	a4,s0
ffffffffc0204b66:	f9bff0ef          	jal	ra,ffffffffc0204b00 <printnum>
ffffffffc0204b6a:	b7f9                	j	ffffffffc0204b38 <printnum+0x38>

ffffffffc0204b6c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204b6c:	7119                	addi	sp,sp,-128
ffffffffc0204b6e:	f4a6                	sd	s1,104(sp)
ffffffffc0204b70:	f0ca                	sd	s2,96(sp)
ffffffffc0204b72:	ecce                	sd	s3,88(sp)
ffffffffc0204b74:	e8d2                	sd	s4,80(sp)
ffffffffc0204b76:	e4d6                	sd	s5,72(sp)
ffffffffc0204b78:	e0da                	sd	s6,64(sp)
ffffffffc0204b7a:	fc5e                	sd	s7,56(sp)
ffffffffc0204b7c:	f06a                	sd	s10,32(sp)
ffffffffc0204b7e:	fc86                	sd	ra,120(sp)
ffffffffc0204b80:	f8a2                	sd	s0,112(sp)
ffffffffc0204b82:	f862                	sd	s8,48(sp)
ffffffffc0204b84:	f466                	sd	s9,40(sp)
ffffffffc0204b86:	ec6e                	sd	s11,24(sp)
ffffffffc0204b88:	892a                	mv	s2,a0
ffffffffc0204b8a:	84ae                	mv	s1,a1
ffffffffc0204b8c:	8d32                	mv	s10,a2
ffffffffc0204b8e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b90:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b94:	5b7d                	li	s6,-1
ffffffffc0204b96:	00002a97          	auipc	s5,0x2
ffffffffc0204b9a:	37ea8a93          	addi	s5,s5,894 # ffffffffc0206f14 <default_pmm_manager+0x11ac>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b9e:	00002b97          	auipc	s7,0x2
ffffffffc0204ba2:	552b8b93          	addi	s7,s7,1362 # ffffffffc02070f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204ba6:	000d4503          	lbu	a0,0(s10)
ffffffffc0204baa:	001d0413          	addi	s0,s10,1
ffffffffc0204bae:	01350a63          	beq	a0,s3,ffffffffc0204bc2 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204bb2:	c121                	beqz	a0,ffffffffc0204bf2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204bb4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204bb6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204bb8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204bba:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204bbe:	ff351ae3          	bne	a0,s3,ffffffffc0204bb2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bc2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204bc6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204bca:	4c81                	li	s9,0
ffffffffc0204bcc:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204bce:	5c7d                	li	s8,-1
ffffffffc0204bd0:	5dfd                	li	s11,-1
ffffffffc0204bd2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204bd6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bd8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204bdc:	0ff5f593          	andi	a1,a1,255
ffffffffc0204be0:	00140d13          	addi	s10,s0,1
ffffffffc0204be4:	04b56263          	bltu	a0,a1,ffffffffc0204c28 <vprintfmt+0xbc>
ffffffffc0204be8:	058a                	slli	a1,a1,0x2
ffffffffc0204bea:	95d6                	add	a1,a1,s5
ffffffffc0204bec:	4194                	lw	a3,0(a1)
ffffffffc0204bee:	96d6                	add	a3,a3,s5
ffffffffc0204bf0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204bf2:	70e6                	ld	ra,120(sp)
ffffffffc0204bf4:	7446                	ld	s0,112(sp)
ffffffffc0204bf6:	74a6                	ld	s1,104(sp)
ffffffffc0204bf8:	7906                	ld	s2,96(sp)
ffffffffc0204bfa:	69e6                	ld	s3,88(sp)
ffffffffc0204bfc:	6a46                	ld	s4,80(sp)
ffffffffc0204bfe:	6aa6                	ld	s5,72(sp)
ffffffffc0204c00:	6b06                	ld	s6,64(sp)
ffffffffc0204c02:	7be2                	ld	s7,56(sp)
ffffffffc0204c04:	7c42                	ld	s8,48(sp)
ffffffffc0204c06:	7ca2                	ld	s9,40(sp)
ffffffffc0204c08:	7d02                	ld	s10,32(sp)
ffffffffc0204c0a:	6de2                	ld	s11,24(sp)
ffffffffc0204c0c:	6109                	addi	sp,sp,128
ffffffffc0204c0e:	8082                	ret
            padc = '0';
ffffffffc0204c10:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204c12:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c16:	846a                	mv	s0,s10
ffffffffc0204c18:	00140d13          	addi	s10,s0,1
ffffffffc0204c1c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204c20:	0ff5f593          	andi	a1,a1,255
ffffffffc0204c24:	fcb572e3          	bgeu	a0,a1,ffffffffc0204be8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204c28:	85a6                	mv	a1,s1
ffffffffc0204c2a:	02500513          	li	a0,37
ffffffffc0204c2e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204c30:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204c34:	8d22                	mv	s10,s0
ffffffffc0204c36:	f73788e3          	beq	a5,s3,ffffffffc0204ba6 <vprintfmt+0x3a>
ffffffffc0204c3a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204c3e:	1d7d                	addi	s10,s10,-1
ffffffffc0204c40:	ff379de3          	bne	a5,s3,ffffffffc0204c3a <vprintfmt+0xce>
ffffffffc0204c44:	b78d                	j	ffffffffc0204ba6 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204c46:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204c4a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c4e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204c50:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204c54:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c58:	02d86463          	bltu	a6,a3,ffffffffc0204c80 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204c5c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204c60:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204c64:	0186873b          	addw	a4,a3,s8
ffffffffc0204c68:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204c6c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204c6e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204c72:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204c74:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204c78:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c7c:	fed870e3          	bgeu	a6,a3,ffffffffc0204c5c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204c80:	f40ddce3          	bgez	s11,ffffffffc0204bd8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204c84:	8de2                	mv	s11,s8
ffffffffc0204c86:	5c7d                	li	s8,-1
ffffffffc0204c88:	bf81                	j	ffffffffc0204bd8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204c8a:	fffdc693          	not	a3,s11
ffffffffc0204c8e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204c90:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c94:	00144603          	lbu	a2,1(s0)
ffffffffc0204c98:	2d81                	sext.w	s11,s11
ffffffffc0204c9a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c9c:	bf35                	j	ffffffffc0204bd8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204c9e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ca2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204ca6:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ca8:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204caa:	bfd9                	j	ffffffffc0204c80 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204cac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204cae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204cb2:	01174463          	blt	a4,a7,ffffffffc0204cba <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204cb6:	1a088e63          	beqz	a7,ffffffffc0204e72 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204cba:	000a3603          	ld	a2,0(s4)
ffffffffc0204cbe:	46c1                	li	a3,16
ffffffffc0204cc0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204cc2:	2781                	sext.w	a5,a5
ffffffffc0204cc4:	876e                	mv	a4,s11
ffffffffc0204cc6:	85a6                	mv	a1,s1
ffffffffc0204cc8:	854a                	mv	a0,s2
ffffffffc0204cca:	e37ff0ef          	jal	ra,ffffffffc0204b00 <printnum>
            break;
ffffffffc0204cce:	bde1                	j	ffffffffc0204ba6 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204cd0:	000a2503          	lw	a0,0(s4)
ffffffffc0204cd4:	85a6                	mv	a1,s1
ffffffffc0204cd6:	0a21                	addi	s4,s4,8
ffffffffc0204cd8:	9902                	jalr	s2
            break;
ffffffffc0204cda:	b5f1                	j	ffffffffc0204ba6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204cdc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204cde:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204ce2:	01174463          	blt	a4,a7,ffffffffc0204cea <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204ce6:	18088163          	beqz	a7,ffffffffc0204e68 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204cea:	000a3603          	ld	a2,0(s4)
ffffffffc0204cee:	46a9                	li	a3,10
ffffffffc0204cf0:	8a2e                	mv	s4,a1
ffffffffc0204cf2:	bfc1                	j	ffffffffc0204cc2 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cf4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204cf8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cfa:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204cfc:	bdf1                	j	ffffffffc0204bd8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204cfe:	85a6                	mv	a1,s1
ffffffffc0204d00:	02500513          	li	a0,37
ffffffffc0204d04:	9902                	jalr	s2
            break;
ffffffffc0204d06:	b545                	j	ffffffffc0204ba6 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d08:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204d0c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d0e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204d10:	b5e1                	j	ffffffffc0204bd8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204d12:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204d14:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204d18:	01174463          	blt	a4,a7,ffffffffc0204d20 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204d1c:	14088163          	beqz	a7,ffffffffc0204e5e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204d20:	000a3603          	ld	a2,0(s4)
ffffffffc0204d24:	46a1                	li	a3,8
ffffffffc0204d26:	8a2e                	mv	s4,a1
ffffffffc0204d28:	bf69                	j	ffffffffc0204cc2 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204d2a:	03000513          	li	a0,48
ffffffffc0204d2e:	85a6                	mv	a1,s1
ffffffffc0204d30:	e03e                	sd	a5,0(sp)
ffffffffc0204d32:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204d34:	85a6                	mv	a1,s1
ffffffffc0204d36:	07800513          	li	a0,120
ffffffffc0204d3a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204d3c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204d3e:	6782                	ld	a5,0(sp)
ffffffffc0204d40:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204d42:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204d46:	bfb5                	j	ffffffffc0204cc2 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d48:	000a3403          	ld	s0,0(s4)
ffffffffc0204d4c:	008a0713          	addi	a4,s4,8
ffffffffc0204d50:	e03a                	sd	a4,0(sp)
ffffffffc0204d52:	14040263          	beqz	s0,ffffffffc0204e96 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204d56:	0fb05763          	blez	s11,ffffffffc0204e44 <vprintfmt+0x2d8>
ffffffffc0204d5a:	02d00693          	li	a3,45
ffffffffc0204d5e:	0cd79163          	bne	a5,a3,ffffffffc0204e20 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d62:	00044783          	lbu	a5,0(s0)
ffffffffc0204d66:	0007851b          	sext.w	a0,a5
ffffffffc0204d6a:	cf85                	beqz	a5,ffffffffc0204da2 <vprintfmt+0x236>
ffffffffc0204d6c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d70:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d74:	000c4563          	bltz	s8,ffffffffc0204d7e <vprintfmt+0x212>
ffffffffc0204d78:	3c7d                	addiw	s8,s8,-1
ffffffffc0204d7a:	036c0263          	beq	s8,s6,ffffffffc0204d9e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204d7e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d80:	0e0c8e63          	beqz	s9,ffffffffc0204e7c <vprintfmt+0x310>
ffffffffc0204d84:	3781                	addiw	a5,a5,-32
ffffffffc0204d86:	0ef47b63          	bgeu	s0,a5,ffffffffc0204e7c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204d8a:	03f00513          	li	a0,63
ffffffffc0204d8e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d90:	000a4783          	lbu	a5,0(s4)
ffffffffc0204d94:	3dfd                	addiw	s11,s11,-1
ffffffffc0204d96:	0a05                	addi	s4,s4,1
ffffffffc0204d98:	0007851b          	sext.w	a0,a5
ffffffffc0204d9c:	ffe1                	bnez	a5,ffffffffc0204d74 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204d9e:	01b05963          	blez	s11,ffffffffc0204db0 <vprintfmt+0x244>
ffffffffc0204da2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204da4:	85a6                	mv	a1,s1
ffffffffc0204da6:	02000513          	li	a0,32
ffffffffc0204daa:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204dac:	fe0d9be3          	bnez	s11,ffffffffc0204da2 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204db0:	6a02                	ld	s4,0(sp)
ffffffffc0204db2:	bbd5                	j	ffffffffc0204ba6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204db4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204db6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204dba:	01174463          	blt	a4,a7,ffffffffc0204dc2 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204dbe:	08088d63          	beqz	a7,ffffffffc0204e58 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204dc2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204dc6:	0a044d63          	bltz	s0,ffffffffc0204e80 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204dca:	8622                	mv	a2,s0
ffffffffc0204dcc:	8a66                	mv	s4,s9
ffffffffc0204dce:	46a9                	li	a3,10
ffffffffc0204dd0:	bdcd                	j	ffffffffc0204cc2 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204dd2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204dd6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204dd8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204dda:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204dde:	8fb5                	xor	a5,a5,a3
ffffffffc0204de0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204de4:	02d74163          	blt	a4,a3,ffffffffc0204e06 <vprintfmt+0x29a>
ffffffffc0204de8:	00369793          	slli	a5,a3,0x3
ffffffffc0204dec:	97de                	add	a5,a5,s7
ffffffffc0204dee:	639c                	ld	a5,0(a5)
ffffffffc0204df0:	cb99                	beqz	a5,ffffffffc0204e06 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204df2:	86be                	mv	a3,a5
ffffffffc0204df4:	00000617          	auipc	a2,0x0
ffffffffc0204df8:	1ec60613          	addi	a2,a2,492 # ffffffffc0204fe0 <etext+0x28>
ffffffffc0204dfc:	85a6                	mv	a1,s1
ffffffffc0204dfe:	854a                	mv	a0,s2
ffffffffc0204e00:	0ce000ef          	jal	ra,ffffffffc0204ece <printfmt>
ffffffffc0204e04:	b34d                	j	ffffffffc0204ba6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204e06:	00002617          	auipc	a2,0x2
ffffffffc0204e0a:	10260613          	addi	a2,a2,258 # ffffffffc0206f08 <default_pmm_manager+0x11a0>
ffffffffc0204e0e:	85a6                	mv	a1,s1
ffffffffc0204e10:	854a                	mv	a0,s2
ffffffffc0204e12:	0bc000ef          	jal	ra,ffffffffc0204ece <printfmt>
ffffffffc0204e16:	bb41                	j	ffffffffc0204ba6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204e18:	00002417          	auipc	s0,0x2
ffffffffc0204e1c:	0e840413          	addi	s0,s0,232 # ffffffffc0206f00 <default_pmm_manager+0x1198>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e20:	85e2                	mv	a1,s8
ffffffffc0204e22:	8522                	mv	a0,s0
ffffffffc0204e24:	e43e                	sd	a5,8(sp)
ffffffffc0204e26:	0e2000ef          	jal	ra,ffffffffc0204f08 <strnlen>
ffffffffc0204e2a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204e2e:	01b05b63          	blez	s11,ffffffffc0204e44 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204e32:	67a2                	ld	a5,8(sp)
ffffffffc0204e34:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e38:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204e3a:	85a6                	mv	a1,s1
ffffffffc0204e3c:	8552                	mv	a0,s4
ffffffffc0204e3e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e40:	fe0d9ce3          	bnez	s11,ffffffffc0204e38 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e44:	00044783          	lbu	a5,0(s0)
ffffffffc0204e48:	00140a13          	addi	s4,s0,1
ffffffffc0204e4c:	0007851b          	sext.w	a0,a5
ffffffffc0204e50:	d3a5                	beqz	a5,ffffffffc0204db0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e52:	05e00413          	li	s0,94
ffffffffc0204e56:	bf39                	j	ffffffffc0204d74 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204e58:	000a2403          	lw	s0,0(s4)
ffffffffc0204e5c:	b7ad                	j	ffffffffc0204dc6 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204e5e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e62:	46a1                	li	a3,8
ffffffffc0204e64:	8a2e                	mv	s4,a1
ffffffffc0204e66:	bdb1                	j	ffffffffc0204cc2 <vprintfmt+0x156>
ffffffffc0204e68:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e6c:	46a9                	li	a3,10
ffffffffc0204e6e:	8a2e                	mv	s4,a1
ffffffffc0204e70:	bd89                	j	ffffffffc0204cc2 <vprintfmt+0x156>
ffffffffc0204e72:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e76:	46c1                	li	a3,16
ffffffffc0204e78:	8a2e                	mv	s4,a1
ffffffffc0204e7a:	b5a1                	j	ffffffffc0204cc2 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204e7c:	9902                	jalr	s2
ffffffffc0204e7e:	bf09                	j	ffffffffc0204d90 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204e80:	85a6                	mv	a1,s1
ffffffffc0204e82:	02d00513          	li	a0,45
ffffffffc0204e86:	e03e                	sd	a5,0(sp)
ffffffffc0204e88:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204e8a:	6782                	ld	a5,0(sp)
ffffffffc0204e8c:	8a66                	mv	s4,s9
ffffffffc0204e8e:	40800633          	neg	a2,s0
ffffffffc0204e92:	46a9                	li	a3,10
ffffffffc0204e94:	b53d                	j	ffffffffc0204cc2 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204e96:	03b05163          	blez	s11,ffffffffc0204eb8 <vprintfmt+0x34c>
ffffffffc0204e9a:	02d00693          	li	a3,45
ffffffffc0204e9e:	f6d79de3          	bne	a5,a3,ffffffffc0204e18 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204ea2:	00002417          	auipc	s0,0x2
ffffffffc0204ea6:	05e40413          	addi	s0,s0,94 # ffffffffc0206f00 <default_pmm_manager+0x1198>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204eaa:	02800793          	li	a5,40
ffffffffc0204eae:	02800513          	li	a0,40
ffffffffc0204eb2:	00140a13          	addi	s4,s0,1
ffffffffc0204eb6:	bd6d                	j	ffffffffc0204d70 <vprintfmt+0x204>
ffffffffc0204eb8:	00002a17          	auipc	s4,0x2
ffffffffc0204ebc:	049a0a13          	addi	s4,s4,73 # ffffffffc0206f01 <default_pmm_manager+0x1199>
ffffffffc0204ec0:	02800513          	li	a0,40
ffffffffc0204ec4:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204ec8:	05e00413          	li	s0,94
ffffffffc0204ecc:	b565                	j	ffffffffc0204d74 <vprintfmt+0x208>

ffffffffc0204ece <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204ece:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204ed0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204ed4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204ed6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204ed8:	ec06                	sd	ra,24(sp)
ffffffffc0204eda:	f83a                	sd	a4,48(sp)
ffffffffc0204edc:	fc3e                	sd	a5,56(sp)
ffffffffc0204ede:	e0c2                	sd	a6,64(sp)
ffffffffc0204ee0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204ee2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204ee4:	c89ff0ef          	jal	ra,ffffffffc0204b6c <vprintfmt>
}
ffffffffc0204ee8:	60e2                	ld	ra,24(sp)
ffffffffc0204eea:	6161                	addi	sp,sp,80
ffffffffc0204eec:	8082                	ret

ffffffffc0204eee <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204eee:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204ef2:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204ef4:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204ef6:	cb81                	beqz	a5,ffffffffc0204f06 <strlen+0x18>
        cnt ++;
ffffffffc0204ef8:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204efa:	00a707b3          	add	a5,a4,a0
ffffffffc0204efe:	0007c783          	lbu	a5,0(a5)
ffffffffc0204f02:	fbfd                	bnez	a5,ffffffffc0204ef8 <strlen+0xa>
ffffffffc0204f04:	8082                	ret
    }
    return cnt;
}
ffffffffc0204f06:	8082                	ret

ffffffffc0204f08 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204f08:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204f0a:	e589                	bnez	a1,ffffffffc0204f14 <strnlen+0xc>
ffffffffc0204f0c:	a811                	j	ffffffffc0204f20 <strnlen+0x18>
        cnt ++;
ffffffffc0204f0e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204f10:	00f58863          	beq	a1,a5,ffffffffc0204f20 <strnlen+0x18>
ffffffffc0204f14:	00f50733          	add	a4,a0,a5
ffffffffc0204f18:	00074703          	lbu	a4,0(a4)
ffffffffc0204f1c:	fb6d                	bnez	a4,ffffffffc0204f0e <strnlen+0x6>
ffffffffc0204f1e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204f20:	852e                	mv	a0,a1
ffffffffc0204f22:	8082                	ret

ffffffffc0204f24 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204f24:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204f26:	0005c703          	lbu	a4,0(a1)
ffffffffc0204f2a:	0785                	addi	a5,a5,1
ffffffffc0204f2c:	0585                	addi	a1,a1,1
ffffffffc0204f2e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204f32:	fb75                	bnez	a4,ffffffffc0204f26 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204f34:	8082                	ret

ffffffffc0204f36 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204f36:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204f3a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204f3e:	cb89                	beqz	a5,ffffffffc0204f50 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204f40:	0505                	addi	a0,a0,1
ffffffffc0204f42:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204f44:	fee789e3          	beq	a5,a4,ffffffffc0204f36 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204f48:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204f4c:	9d19                	subw	a0,a0,a4
ffffffffc0204f4e:	8082                	ret
ffffffffc0204f50:	4501                	li	a0,0
ffffffffc0204f52:	bfed                	j	ffffffffc0204f4c <strcmp+0x16>

ffffffffc0204f54 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204f54:	00054783          	lbu	a5,0(a0)
ffffffffc0204f58:	c799                	beqz	a5,ffffffffc0204f66 <strchr+0x12>
        if (*s == c) {
ffffffffc0204f5a:	00f58763          	beq	a1,a5,ffffffffc0204f68 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204f5e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204f62:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204f64:	fbfd                	bnez	a5,ffffffffc0204f5a <strchr+0x6>
    }
    return NULL;
ffffffffc0204f66:	4501                	li	a0,0
}
ffffffffc0204f68:	8082                	ret

ffffffffc0204f6a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204f6a:	ca01                	beqz	a2,ffffffffc0204f7a <memset+0x10>
ffffffffc0204f6c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204f6e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204f70:	0785                	addi	a5,a5,1
ffffffffc0204f72:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204f76:	fec79de3          	bne	a5,a2,ffffffffc0204f70 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204f7a:	8082                	ret

ffffffffc0204f7c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204f7c:	ca19                	beqz	a2,ffffffffc0204f92 <memcpy+0x16>
ffffffffc0204f7e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204f80:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204f82:	0005c703          	lbu	a4,0(a1)
ffffffffc0204f86:	0585                	addi	a1,a1,1
ffffffffc0204f88:	0785                	addi	a5,a5,1
ffffffffc0204f8a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204f8e:	fec59ae3          	bne	a1,a2,ffffffffc0204f82 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204f92:	8082                	ret

ffffffffc0204f94 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204f94:	c205                	beqz	a2,ffffffffc0204fb4 <memcmp+0x20>
ffffffffc0204f96:	962e                	add	a2,a2,a1
ffffffffc0204f98:	a019                	j	ffffffffc0204f9e <memcmp+0xa>
ffffffffc0204f9a:	00c58d63          	beq	a1,a2,ffffffffc0204fb4 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0204f9e:	00054783          	lbu	a5,0(a0)
ffffffffc0204fa2:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204fa6:	0505                	addi	a0,a0,1
ffffffffc0204fa8:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0204faa:	fee788e3          	beq	a5,a4,ffffffffc0204f9a <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204fae:	40e7853b          	subw	a0,a5,a4
ffffffffc0204fb2:	8082                	ret
    }
    return 0;
ffffffffc0204fb4:	4501                	li	a0,0
}
ffffffffc0204fb6:	8082                	ret
