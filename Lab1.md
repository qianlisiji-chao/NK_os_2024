# Lab0.5实验报告
## 实验目的
通过Qemu 模拟器模拟最小可执行内核的启动流程，理解代码执行流程及含义。尝试掌握使用链接脚本描述内存布局进行交叉编译生成可执行文件，进而生成内核镜像使用OpenSBI作为bootloader加载内核镜像，并使用Qemu进行模拟使用OpenSBI提供的服务，在屏幕上格式化打印字符串用于以后调试。

## 实验内容
了解 Qemu 模拟器的启动流程，还需要一些程序内存布局和编译流程（特别是链接）相关知识,以及通过opensbi固件来通过服务。

## 练习
   练习1: 使用GDB验证启动流程
   RISC-V计算机开始加电时，pc的复位地址是0x1000
   作为 bootloader 的 OpenSBI.bin 被加载到物理内存以物理地址 0x80000000开头的区域上
   同时内核镜像 os.bin 被加载到以物理地址 0x80200000 开头的区域上。

   当我们利用make debug 和make gdb 逐行查看汇编代码时，我们首先利用x/10i $pc看一看初始代码在什么地址上。
	
   ![image1-lab0_1.png](https://github.com/qianlisiji-chao/image/blob/main/image1-lab0_1.png)  
   现在即将执行的第一行代码正是我们的pc复位地址所指向的代码。

   下面我们逐行解释即将运行的汇编代码。
	auipc t0,0x0      auipc指令是将立即数的高12位与PC值相加存到t0寄存器中，得到t0=pc=0x1000
	addi  a1,t0,32	  a1=t0+32= 0x01030
	csrr  a0,mhartid  csrr指令将读取当前硬件线程的 ID，并将其存放到寄存器 a0 中
	ld    t0,24(t0)	  t0+24=0x1018，通过x/1xw 0x1018 查看内存地址 0x1018 中的存储内容为0x80000000
	jr    t0          跳转到0x80000000
	
0x80000000地址上是我们的OpenSBI开始的地址，这也就是说，前面的五条指令是RISC-V硬件加电后执行的几条指令。
__这几条代码实现了系统的初始化并跳转到程序的执行入口的功能。__ 	
我们尝试继续逐步调试以到达0x80200000地址，但是太多了，我们只再分析几个汇编代码，然后输入命令break *0x80200000，在 0x80200000 处设置断点，输入命令continue，执行直到碰到断点。<br>
![](https://github.com/qianlisiji-chao/image/blob/main/image4-lab0_1.png)  
现在我们利用x/10i $pc 查看即将执行的十条指令<br>
![](https://github.com/qianlisiji-chao/image/blob/main/image2-lab0_1.png)  
	下面我们继续逐行解释即将运行的汇编代码。<br>
 ```  
0x80000000:	csrr	a6,mhartid     csrr指令将读取当前硬件线程的 ID，并将其存放到寄存器 a6 中  
0x80000004:	bgtz	a6,0x80000108  bgtz指令是大于0则跳转，通过info r a6，发现a6寄存器中的值为0  
0x80000008:	auipc	t0,0x0		   得到t0=pc=0x80000008  
0x8000000c:	addi	t0,t0,1032	   t0=0x80000410  
0x80000010:	auipc	t1,0x0		   得到t1=pc=0x80000010  
0x80000014:	addi	t1,t1,-16	   t1=0x80000000  
0x80000018:	sd		t1,0(t0)	   将 t1 中的值 0x80000000 写入内存地址 0x80000410  
0x8000001c:	auipc	t0,0x0		   t0=0x8000001c  
0x80000020:	addi	t0,t0,1020	   t0=0x80000418
```
## 知识点
bootloader，一个全新的知识点，第一次知道在操作系统运行前是由bootloader将其加载到内存中
四个特权级，与课本不同的是，课本上并没有给出固件也有特权级。
复位地址，CPU在上电的时候，或者按下复位键的时候，PC被赋的初始值
     	

# Lab1实验报告  
## 实验目的
了解中断处理机制的运行过程，了解riscv 的中断相关知识，中断前后如何进行上下文环境的保存与恢复
处理最简单的断点中断和时钟中断
## 实验内容
通过处理断点和时钟中断验证了我们正确实现了中断机制。
## 练习1：理解内核启动中的程序入口操作
	指令 la sp, bootstacktop 将 bootstacktop 的地址加载到栈指针 sp 中，用于初始化栈指针，以便后续的栈操作。
	kern/init/entry.S: OpenSBI启动之后将要跳转到的一段汇编代码。
	在这里进行内核栈的分配，然后转入C语言编写的内核初始化函数。
	tail kern_init 完成了内核的初始化操作，目的是为内核的完全启动做准备    

## 练习2：完善中断处理
	首先，看一看现在这次中断是不是第100次中断。如果是的话我们要打印一次100ticks，并记录现在已经打印了多少次了。要是打印次数到达10次，证明该结束了。如果没结束，记得重新设置时钟中断。
```c
       /* LAB1 EXERCISE2   2213605 :  */
	   if(ticks==100)
       {
           print_ticks();
           num+=1;
           if(num==10)
           {
              sbi_shutdown();
           }
           ticks=0;
       }
       clock_set_next_event();
       ticks+=1;
```
## 扩展练习 Challenge1：描述与理解中断流程  
1.描述ucore中处理中断异常的流程（从异常的产生开始）  
    （1）中断处理程序初始化，在init.c文件中进行初始化，调用idt_init()初始化中断，将sscratch置0,表示中断前处于S态。同时初始化时钟中断（调用clock_init()函数）和使能中断（调用intr_enable()函数）。  
    （2）CPU发现中断，打断当前执行的用户程序。同时跳转到stvec，跳到中断处理程序的入口点。  
    （3）保存上下文，通过定义一个汇编宏`SAVE_ALL`，将所有寄存器保存到栈顶（实则把一个trapFrame结构体放到了栈顶）  
    （4）中断处理程序执行，在trap.c中，把中断处理和异常处理工作分发给interrupt_hanlder()和exception_handler()，根据scause的数值进行分类。执行对应的处理程序。  
    （5）中断处理结束，恢复上下文，通过汇编宏`RESTORE_ALL`恢复到之前保存的寄存器状态。继续执行被中断的程序。  
2.`mov a0,sp`的目的  
    `mov a0,sp`的目的是将栈顶指针当作参数传递给接下来调用的函数trap，即将trapFrame结构体传递到函数中，使异常处理函数能够访问到原来的状态进行分类，好进行处理。  
3.`SAVE_ALL`中寄存器保存在栈中的位置是什么确定的  
    是有栈顶指针sp的基础上进行偏移来确定。  
4.对于任何中断，\_\_alltraps 中都需要保存所有寄存器吗？请说明理由。  
    不都需要，但这种情况是万无一失的。对于一些程序，有的寄存器从未使用，便可以不用保存,例如零寄存器等。
## 扩展练习 Challenge2：理解上下文切换机制
    汇编代码`csrw sscratch, sp`实现了当前栈指针（sp）的值写入到寄存器sscratch中。目的用来保存栈指针的值，以便需要时恢复。  
    汇编代码`csrrw s0, sscratch, x0`是一个原子读-修改-写操作，它首先从sscratch寄存器读取值到s0寄存器，然后将x0（通常是0）写入sscratch寄存器。目的是清除sscratch寄存器的值，以防止在递归中断发生时或恢复时产生混淆。通过将sscratch设置为0，如果再次发生中断，中断处理程序可以检测到这一点，并知道它是从内核空间被调用的。  
    store的意义在于1.在中断处理程序中，可以通过检查这些寄存器来确定异常的原因和位置。2.如果中断处理程序本身能够再次触发中断（例如，通过设备访问），保存这些寄存器可以帮助确保递归中断处理的正确性。  
## 扩展练习Challenge3：完善异常中断
代码如下：  
```c
        case CAUSE_ILLEGAL_INSTRUCTION:
             // 非法指令异常处理
             /* LAB1 CHALLENGE3   2210751 :  */
             //*(1)输出指令异常类型（ Illegal instruction）
             cprintf("Exception Type: Illegal instruction\n");
             //*(2)输出异常指令地址
             cprintf("Illegal instruction caught at 0x%lx\n",tf->epc);
             //*(3)更新 tf->epc寄存器
             tf->epc+=4;
            break;
        case CAUSE_BREAKPOINT:
            //断点异常处理
            /* LAB1 CHALLLENGE3   2210751 :  */
            //*(1)输出指令异常类型（ breakpoint）
            cprintf("Exception Type: breakpoint\n");
            //*(2)输出异常指令地址
            cprintf("ebreak caught at 0x%lx\n",tf->epc);
            //*(3)更新 tf->epc寄存器
            tf->epc+=2;
            break;
```  
同时，在init.c中加入如下代码，以便触发异常
```c
        //Challenge3
        asm volatile("mret");
    
        asm volatile("ebreak");
```
## 知识点
### 1.riscv64中断  
riscv64中断的机制和分类，以及的控制状态寄存器（CSRs）。例如  
`sstatus`寄存器：在2^1对应的二进制位`SIE`为0时禁止CPU在S态时禁用全部中断。二进制位`UIE`为0时禁止用户态程序产生中断  
`stvec`寄存器：是所谓的中断向量表基址，负责把不同种类的中断映射到对应的中断处理程序  
还有以下提供信息给中断处理程序的寄存器：  
`sepc`寄存器：记录触发中断的那条指令的地址  
`scause`寄存器：记录中断发生的原因，还会记录该中断是不是一个外部中断  
`srval`寄存器：记录一些中断处理所需要的辅助信息，比如指令获取(instruction fetch)、访存、缺页异常，它会把发生问题的目标地址或者出错的指令记录下来  
### 2.和中断相关的特权指令  
**ecall**:当我们在S态执行这条指令时，会触发一个 ecall-from-s-mode-exception，从而进入M模式中的中断处理流程（如设置定时器等）；当我们在U态执行这条指令时，会触发一个 ecall-from-u-mode-exception，从而进入S模式中的中断处理流程（常用来进行系统调用）  
**sret**:用于S态中断返回到U态，返回到通过中断进入S态之前的地址。  
**ebreak**:执行这条指令会触发一个断点中断从而进入中断处理流程。  
**mret**:用于 M 态中断返回到S态或U态。  
### 3.处理中断的流程  
见扩展练习1  
