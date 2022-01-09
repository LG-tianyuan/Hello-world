
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 e0 1a 00       	mov    $0x1ae000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 e0 1a c0       	mov    %eax,0xc01ae000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 c0 12 c0       	mov    $0xc012c000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba f8 31 1b c0       	mov    $0xc01b31f8,%edx
c0100041:	b8 00 00 1b c0       	mov    $0xc01b0000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 00 1b c0 	movl   $0xc01b0000,(%esp)
c010005d:	e8 df c2 00 00       	call   c010c341 <memset>

    cons_init();                // init the console
c0100062:	e8 a0 16 00 00       	call   c0101707 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 c4 10 c0 	movl   $0xc010c4e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc c4 10 c0 	movl   $0xc010c4fc,(%esp)
c010007c:	e8 e3 02 00 00       	call   c0100364 <cprintf>

    print_kerninfo();
c0100081:	e8 0a 09 00 00       	call   c0100990 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 a2 00 00 00       	call   c010012d <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 a9 57 00 00       	call   c0105839 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 50 20 00 00       	call   c01020e5 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 a2 21 00 00       	call   c010223c <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 3b 87 00 00       	call   c01087da <vmm_init>
    sched_init();               // init scheduler
c010009f:	e8 3b b4 00 00       	call   c010b4df <sched_init>
    proc_init();                // init process table
c01000a4:	e8 ae ad 00 00       	call   c010ae57 <proc_init>
    
    ide_init();                 // init ide devices
c01000a9:	e8 8a 17 00 00       	call   c0101838 <ide_init>
    swap_init();                // init swap
c01000ae:	e8 fd 6d 00 00       	call   c0106eb0 <swap_init>

    clock_init();               // init clock interrupt
c01000b3:	e8 05 0e 00 00       	call   c0100ebd <clock_init>
    intr_enable();              // enable irq interrupt
c01000b8:	e8 96 1f 00 00       	call   c0102053 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000bd:	e8 54 af 00 00       	call   c010b016 <cpu_idle>

c01000c2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000c2:	55                   	push   %ebp
c01000c3:	89 e5                	mov    %esp,%ebp
c01000c5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000cf:	00 
c01000d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d7:	00 
c01000d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000df:	e8 fa 0c 00 00       	call   c0100dde <mon_backtrace>
}
c01000e4:	c9                   	leave  
c01000e5:	c3                   	ret    

c01000e6 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e6:	55                   	push   %ebp
c01000e7:	89 e5                	mov    %esp,%ebp
c01000e9:	53                   	push   %ebx
c01000ea:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000ed:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000f3:	8d 55 08             	lea    0x8(%ebp),%edx
c01000f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100101:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100105:	89 04 24             	mov    %eax,(%esp)
c0100108:	e8 b5 ff ff ff       	call   c01000c2 <grade_backtrace2>
}
c010010d:	83 c4 14             	add    $0x14,%esp
c0100110:	5b                   	pop    %ebx
c0100111:	5d                   	pop    %ebp
c0100112:	c3                   	ret    

c0100113 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100113:	55                   	push   %ebp
c0100114:	89 e5                	mov    %esp,%ebp
c0100116:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100119:	8b 45 10             	mov    0x10(%ebp),%eax
c010011c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100120:	8b 45 08             	mov    0x8(%ebp),%eax
c0100123:	89 04 24             	mov    %eax,(%esp)
c0100126:	e8 bb ff ff ff       	call   c01000e6 <grade_backtrace1>
}
c010012b:	c9                   	leave  
c010012c:	c3                   	ret    

c010012d <grade_backtrace>:

void
grade_backtrace(void) {
c010012d:	55                   	push   %ebp
c010012e:	89 e5                	mov    %esp,%ebp
c0100130:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100133:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100138:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013f:	ff 
c0100140:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100144:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010014b:	e8 c3 ff ff ff       	call   c0100113 <grade_backtrace0>
}
c0100150:	c9                   	leave  
c0100151:	c3                   	ret    

c0100152 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100152:	55                   	push   %ebp
c0100153:	89 e5                	mov    %esp,%ebp
c0100155:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100158:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015b:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015e:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100161:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100164:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100168:	0f b7 c0             	movzwl %ax,%eax
c010016b:	83 e0 03             	and    $0x3,%eax
c010016e:	89 c2                	mov    %eax,%edx
c0100170:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c0100175:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100179:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017d:	c7 04 24 01 c5 10 c0 	movl   $0xc010c501,(%esp)
c0100184:	e8 db 01 00 00       	call   c0100364 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100189:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018d:	0f b7 d0             	movzwl %ax,%edx
c0100190:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c0100195:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100199:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019d:	c7 04 24 0f c5 10 c0 	movl   $0xc010c50f,(%esp)
c01001a4:	e8 bb 01 00 00       	call   c0100364 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a9:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001ad:	0f b7 d0             	movzwl %ax,%edx
c01001b0:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001b5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bd:	c7 04 24 1d c5 10 c0 	movl   $0xc010c51d,(%esp)
c01001c4:	e8 9b 01 00 00       	call   c0100364 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001cd:	0f b7 d0             	movzwl %ax,%edx
c01001d0:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001d5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001dd:	c7 04 24 2b c5 10 c0 	movl   $0xc010c52b,(%esp)
c01001e4:	e8 7b 01 00 00       	call   c0100364 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001ed:	0f b7 d0             	movzwl %ax,%edx
c01001f0:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001f5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001fd:	c7 04 24 39 c5 10 c0 	movl   $0xc010c539,(%esp)
c0100204:	e8 5b 01 00 00       	call   c0100364 <cprintf>
    round ++;
c0100209:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c010020e:	83 c0 01             	add    $0x1,%eax
c0100211:	a3 00 00 1b c0       	mov    %eax,0xc01b0000
}
c0100216:	c9                   	leave  
c0100217:	c3                   	ret    

c0100218 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100218:	55                   	push   %ebp
c0100219:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010021b:	5d                   	pop    %ebp
c010021c:	c3                   	ret    

c010021d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010021d:	55                   	push   %ebp
c010021e:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100220:	5d                   	pop    %ebp
c0100221:	c3                   	ret    

c0100222 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100222:	55                   	push   %ebp
c0100223:	89 e5                	mov    %esp,%ebp
c0100225:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100228:	e8 25 ff ff ff       	call   c0100152 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010022d:	c7 04 24 48 c5 10 c0 	movl   $0xc010c548,(%esp)
c0100234:	e8 2b 01 00 00       	call   c0100364 <cprintf>
    lab1_switch_to_user();
c0100239:	e8 da ff ff ff       	call   c0100218 <lab1_switch_to_user>
    lab1_print_cur_status();
c010023e:	e8 0f ff ff ff       	call   c0100152 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100243:	c7 04 24 68 c5 10 c0 	movl   $0xc010c568,(%esp)
c010024a:	e8 15 01 00 00       	call   c0100364 <cprintf>
    lab1_switch_to_kernel();
c010024f:	e8 c9 ff ff ff       	call   c010021d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100254:	e8 f9 fe ff ff       	call   c0100152 <lab1_print_cur_status>
}
c0100259:	c9                   	leave  
c010025a:	c3                   	ret    

c010025b <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010025b:	55                   	push   %ebp
c010025c:	89 e5                	mov    %esp,%ebp
c010025e:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100261:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100265:	74 13                	je     c010027a <readline+0x1f>
        cprintf("%s", prompt);
c0100267:	8b 45 08             	mov    0x8(%ebp),%eax
c010026a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010026e:	c7 04 24 87 c5 10 c0 	movl   $0xc010c587,(%esp)
c0100275:	e8 ea 00 00 00       	call   c0100364 <cprintf>
    }
    int i = 0, c;
c010027a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100281:	e8 66 01 00 00       	call   c01003ec <getchar>
c0100286:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100289:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010028d:	79 07                	jns    c0100296 <readline+0x3b>
            return NULL;
c010028f:	b8 00 00 00 00       	mov    $0x0,%eax
c0100294:	eb 79                	jmp    c010030f <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100296:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010029a:	7e 28                	jle    c01002c4 <readline+0x69>
c010029c:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01002a3:	7f 1f                	jg     c01002c4 <readline+0x69>
            cputchar(c);
c01002a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a8:	89 04 24             	mov    %eax,(%esp)
c01002ab:	e8 da 00 00 00       	call   c010038a <cputchar>
            buf[i ++] = c;
c01002b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002b3:	8d 50 01             	lea    0x1(%eax),%edx
c01002b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002bc:	88 90 20 00 1b c0    	mov    %dl,-0x3fe4ffe0(%eax)
c01002c2:	eb 46                	jmp    c010030a <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002c4:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002c8:	75 17                	jne    c01002e1 <readline+0x86>
c01002ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ce:	7e 11                	jle    c01002e1 <readline+0x86>
            cputchar(c);
c01002d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d3:	89 04 24             	mov    %eax,(%esp)
c01002d6:	e8 af 00 00 00       	call   c010038a <cputchar>
            i --;
c01002db:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002df:	eb 29                	jmp    c010030a <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002e1:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002e5:	74 06                	je     c01002ed <readline+0x92>
c01002e7:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002eb:	75 1d                	jne    c010030a <readline+0xaf>
            cputchar(c);
c01002ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002f0:	89 04 24             	mov    %eax,(%esp)
c01002f3:	e8 92 00 00 00       	call   c010038a <cputchar>
            buf[i] = '\0';
c01002f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002fb:	05 20 00 1b c0       	add    $0xc01b0020,%eax
c0100300:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100303:	b8 20 00 1b c0       	mov    $0xc01b0020,%eax
c0100308:	eb 05                	jmp    c010030f <readline+0xb4>
        }
    }
c010030a:	e9 72 ff ff ff       	jmp    c0100281 <readline+0x26>
}
c010030f:	c9                   	leave  
c0100310:	c3                   	ret    

c0100311 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100311:	55                   	push   %ebp
c0100312:	89 e5                	mov    %esp,%ebp
c0100314:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100317:	8b 45 08             	mov    0x8(%ebp),%eax
c010031a:	89 04 24             	mov    %eax,(%esp)
c010031d:	e8 11 14 00 00       	call   c0101733 <cons_putc>
    (*cnt) ++;
c0100322:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100325:	8b 00                	mov    (%eax),%eax
c0100327:	8d 50 01             	lea    0x1(%eax),%edx
c010032a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010032d:	89 10                	mov    %edx,(%eax)
}
c010032f:	c9                   	leave  
c0100330:	c3                   	ret    

c0100331 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100331:	55                   	push   %ebp
c0100332:	89 e5                	mov    %esp,%ebp
c0100334:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100337:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010033e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100341:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100345:	8b 45 08             	mov    0x8(%ebp),%eax
c0100348:	89 44 24 08          	mov    %eax,0x8(%esp)
c010034c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010034f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100353:	c7 04 24 11 03 10 c0 	movl   $0xc0100311,(%esp)
c010035a:	e8 23 b7 00 00       	call   c010ba82 <vprintfmt>
    return cnt;
c010035f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100362:	c9                   	leave  
c0100363:	c3                   	ret    

c0100364 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100364:	55                   	push   %ebp
c0100365:	89 e5                	mov    %esp,%ebp
c0100367:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010036a:	8d 45 0c             	lea    0xc(%ebp),%eax
c010036d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100370:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100373:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100377:	8b 45 08             	mov    0x8(%ebp),%eax
c010037a:	89 04 24             	mov    %eax,(%esp)
c010037d:	e8 af ff ff ff       	call   c0100331 <vcprintf>
c0100382:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100385:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100388:	c9                   	leave  
c0100389:	c3                   	ret    

c010038a <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010038a:	55                   	push   %ebp
c010038b:	89 e5                	mov    %esp,%ebp
c010038d:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100390:	8b 45 08             	mov    0x8(%ebp),%eax
c0100393:	89 04 24             	mov    %eax,(%esp)
c0100396:	e8 98 13 00 00       	call   c0101733 <cons_putc>
}
c010039b:	c9                   	leave  
c010039c:	c3                   	ret    

c010039d <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010039d:	55                   	push   %ebp
c010039e:	89 e5                	mov    %esp,%ebp
c01003a0:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003aa:	eb 13                	jmp    c01003bf <cputs+0x22>
        cputch(c, &cnt);
c01003ac:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003b0:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003b3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003b7:	89 04 24             	mov    %eax,(%esp)
c01003ba:	e8 52 ff ff ff       	call   c0100311 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01003c2:	8d 50 01             	lea    0x1(%eax),%edx
c01003c5:	89 55 08             	mov    %edx,0x8(%ebp)
c01003c8:	0f b6 00             	movzbl (%eax),%eax
c01003cb:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003ce:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003d2:	75 d8                	jne    c01003ac <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003db:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003e2:	e8 2a ff ff ff       	call   c0100311 <cputch>
    return cnt;
c01003e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003ea:	c9                   	leave  
c01003eb:	c3                   	ret    

c01003ec <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003ec:	55                   	push   %ebp
c01003ed:	89 e5                	mov    %esp,%ebp
c01003ef:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003f2:	e8 78 13 00 00       	call   c010176f <cons_getc>
c01003f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003fe:	74 f2                	je     c01003f2 <getchar+0x6>
        /* do nothing */;
    return c;
c0100400:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100403:	c9                   	leave  
c0100404:	c3                   	ret    

c0100405 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100405:	55                   	push   %ebp
c0100406:	89 e5                	mov    %esp,%ebp
c0100408:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010040b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040e:	8b 00                	mov    (%eax),%eax
c0100410:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100413:	8b 45 10             	mov    0x10(%ebp),%eax
c0100416:	8b 00                	mov    (%eax),%eax
c0100418:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010041b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100422:	e9 d2 00 00 00       	jmp    c01004f9 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c0100427:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010042a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010042d:	01 d0                	add    %edx,%eax
c010042f:	89 c2                	mov    %eax,%edx
c0100431:	c1 ea 1f             	shr    $0x1f,%edx
c0100434:	01 d0                	add    %edx,%eax
c0100436:	d1 f8                	sar    %eax
c0100438:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010043b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010043e:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100441:	eb 04                	jmp    c0100447 <stab_binsearch+0x42>
            m --;
c0100443:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100447:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010044a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010044d:	7c 1f                	jl     c010046e <stab_binsearch+0x69>
c010044f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100452:	89 d0                	mov    %edx,%eax
c0100454:	01 c0                	add    %eax,%eax
c0100456:	01 d0                	add    %edx,%eax
c0100458:	c1 e0 02             	shl    $0x2,%eax
c010045b:	89 c2                	mov    %eax,%edx
c010045d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100460:	01 d0                	add    %edx,%eax
c0100462:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100466:	0f b6 c0             	movzbl %al,%eax
c0100469:	3b 45 14             	cmp    0x14(%ebp),%eax
c010046c:	75 d5                	jne    c0100443 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100471:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100474:	7d 0b                	jge    c0100481 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100476:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100479:	83 c0 01             	add    $0x1,%eax
c010047c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010047f:	eb 78                	jmp    c01004f9 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100481:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100488:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010048b:	89 d0                	mov    %edx,%eax
c010048d:	01 c0                	add    %eax,%eax
c010048f:	01 d0                	add    %edx,%eax
c0100491:	c1 e0 02             	shl    $0x2,%eax
c0100494:	89 c2                	mov    %eax,%edx
c0100496:	8b 45 08             	mov    0x8(%ebp),%eax
c0100499:	01 d0                	add    %edx,%eax
c010049b:	8b 40 08             	mov    0x8(%eax),%eax
c010049e:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004a1:	73 13                	jae    c01004b6 <stab_binsearch+0xb1>
            *region_left = m;
c01004a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a9:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004ae:	83 c0 01             	add    $0x1,%eax
c01004b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004b4:	eb 43                	jmp    c01004f9 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b9:	89 d0                	mov    %edx,%eax
c01004bb:	01 c0                	add    %eax,%eax
c01004bd:	01 d0                	add    %edx,%eax
c01004bf:	c1 e0 02             	shl    $0x2,%eax
c01004c2:	89 c2                	mov    %eax,%edx
c01004c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01004c7:	01 d0                	add    %edx,%eax
c01004c9:	8b 40 08             	mov    0x8(%eax),%eax
c01004cc:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004cf:	76 16                	jbe    c01004e7 <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01004da:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004df:	83 e8 01             	sub    $0x1,%eax
c01004e2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e5:	eb 12                	jmp    c01004f9 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004ed:	89 10                	mov    %edx,(%eax)
            l = m;
c01004ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004f5:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004ff:	0f 8e 22 ff ff ff    	jle    c0100427 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c0100505:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100509:	75 0f                	jne    c010051a <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c010050b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050e:	8b 00                	mov    (%eax),%eax
c0100510:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100513:	8b 45 10             	mov    0x10(%ebp),%eax
c0100516:	89 10                	mov    %edx,(%eax)
c0100518:	eb 3f                	jmp    c0100559 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010051a:	8b 45 10             	mov    0x10(%ebp),%eax
c010051d:	8b 00                	mov    (%eax),%eax
c010051f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100522:	eb 04                	jmp    c0100528 <stab_binsearch+0x123>
c0100524:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100528:	8b 45 0c             	mov    0xc(%ebp),%eax
c010052b:	8b 00                	mov    (%eax),%eax
c010052d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100530:	7d 1f                	jge    c0100551 <stab_binsearch+0x14c>
c0100532:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100535:	89 d0                	mov    %edx,%eax
c0100537:	01 c0                	add    %eax,%eax
c0100539:	01 d0                	add    %edx,%eax
c010053b:	c1 e0 02             	shl    $0x2,%eax
c010053e:	89 c2                	mov    %eax,%edx
c0100540:	8b 45 08             	mov    0x8(%ebp),%eax
c0100543:	01 d0                	add    %edx,%eax
c0100545:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100549:	0f b6 c0             	movzbl %al,%eax
c010054c:	3b 45 14             	cmp    0x14(%ebp),%eax
c010054f:	75 d3                	jne    c0100524 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100551:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100554:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100557:	89 10                	mov    %edx,(%eax)
    }
}
c0100559:	c9                   	leave  
c010055a:	c3                   	ret    

c010055b <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010055b:	55                   	push   %ebp
c010055c:	89 e5                	mov    %esp,%ebp
c010055e:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100561:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100564:	c7 00 8c c5 10 c0    	movl   $0xc010c58c,(%eax)
    info->eip_line = 0;
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100577:	c7 40 08 8c c5 10 c0 	movl   $0xc010c58c,0x8(%eax)
    info->eip_fn_namelen = 9;
c010057e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100581:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100588:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058b:	8b 55 08             	mov    0x8(%ebp),%edx
c010058e:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100591:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100594:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c010059b:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c01005a2:	76 21                	jbe    c01005c5 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c01005a4:	c7 45 f4 20 ed 10 c0 	movl   $0xc010ed20,-0xc(%ebp)
        stab_end = __STAB_END__;
c01005ab:	c7 45 f0 84 3c 12 c0 	movl   $0xc0123c84,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01005b2:	c7 45 ec 85 3c 12 c0 	movl   $0xc0123c85,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005b9:	c7 45 e8 79 9d 12 c0 	movl   $0xc0129d79,-0x18(%ebp)
c01005c0:	e9 ea 00 00 00       	jmp    c01006af <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005c5:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005cc:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c01005d1:	85 c0                	test   %eax,%eax
c01005d3:	74 11                	je     c01005e6 <debuginfo_eip+0x8b>
c01005d5:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c01005da:	8b 40 18             	mov    0x18(%eax),%eax
c01005dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005e4:	75 0a                	jne    c01005f0 <debuginfo_eip+0x95>
            return -1;
c01005e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005eb:	e9 9e 03 00 00       	jmp    c010098e <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01005f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01005fa:	00 
c01005fb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0100602:	00 
c0100603:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100607:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010060a:	89 04 24             	mov    %eax,(%esp)
c010060d:	e8 f1 8a 00 00       	call   c0109103 <user_mem_check>
c0100612:	85 c0                	test   %eax,%eax
c0100614:	75 0a                	jne    c0100620 <debuginfo_eip+0xc5>
            return -1;
c0100616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010061b:	e9 6e 03 00 00       	jmp    c010098e <debuginfo_eip+0x433>
        }

        stabs = usd->stabs;
c0100620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100623:	8b 00                	mov    (%eax),%eax
c0100625:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c0100628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010062b:	8b 40 04             	mov    0x4(%eax),%eax
c010062e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c0100631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100634:	8b 40 08             	mov    0x8(%eax),%eax
c0100637:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c010063a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010063d:	8b 40 0c             	mov    0xc(%eax),%eax
c0100640:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100643:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	29 c2                	sub    %eax,%edx
c010064b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100655:	00 
c0100656:	89 54 24 08          	mov    %edx,0x8(%esp)
c010065a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010065e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100661:	89 04 24             	mov    %eax,(%esp)
c0100664:	e8 9a 8a 00 00       	call   c0109103 <user_mem_check>
c0100669:	85 c0                	test   %eax,%eax
c010066b:	75 0a                	jne    c0100677 <debuginfo_eip+0x11c>
            return -1;
c010066d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100672:	e9 17 03 00 00       	jmp    c010098e <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100677:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010067a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010067d:	29 c2                	sub    %eax,%edx
c010067f:	89 d0                	mov    %edx,%eax
c0100681:	89 c2                	mov    %eax,%edx
c0100683:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100686:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010068d:	00 
c010068e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100692:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100696:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100699:	89 04 24             	mov    %eax,(%esp)
c010069c:	e8 62 8a 00 00       	call   c0109103 <user_mem_check>
c01006a1:	85 c0                	test   %eax,%eax
c01006a3:	75 0a                	jne    c01006af <debuginfo_eip+0x154>
            return -1;
c01006a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006aa:	e9 df 02 00 00       	jmp    c010098e <debuginfo_eip+0x433>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006af:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006b2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006b5:	76 0d                	jbe    c01006c4 <debuginfo_eip+0x169>
c01006b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006ba:	83 e8 01             	sub    $0x1,%eax
c01006bd:	0f b6 00             	movzbl (%eax),%eax
c01006c0:	84 c0                	test   %al,%al
c01006c2:	74 0a                	je     c01006ce <debuginfo_eip+0x173>
        return -1;
c01006c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006c9:	e9 c0 02 00 00       	jmp    c010098e <debuginfo_eip+0x433>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006ce:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01006d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006db:	29 c2                	sub    %eax,%edx
c01006dd:	89 d0                	mov    %edx,%eax
c01006df:	c1 f8 02             	sar    $0x2,%eax
c01006e2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006e8:	83 e8 01             	sub    $0x1,%eax
c01006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f1:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f5:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006fc:	00 
c01006fd:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100700:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100704:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100707:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010070e:	89 04 24             	mov    %eax,(%esp)
c0100711:	e8 ef fc ff ff       	call   c0100405 <stab_binsearch>
    if (lfile == 0)
c0100716:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100719:	85 c0                	test   %eax,%eax
c010071b:	75 0a                	jne    c0100727 <debuginfo_eip+0x1cc>
        return -1;
c010071d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100722:	e9 67 02 00 00       	jmp    c010098e <debuginfo_eip+0x433>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100727:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010072a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010072d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100730:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100733:	8b 45 08             	mov    0x8(%ebp),%eax
c0100736:	89 44 24 10          	mov    %eax,0x10(%esp)
c010073a:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100741:	00 
c0100742:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100745:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100749:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010074c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100753:	89 04 24             	mov    %eax,(%esp)
c0100756:	e8 aa fc ff ff       	call   c0100405 <stab_binsearch>

    if (lfun <= rfun) {
c010075b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010075e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100761:	39 c2                	cmp    %eax,%edx
c0100763:	7f 7c                	jg     c01007e1 <debuginfo_eip+0x286>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100765:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100768:	89 c2                	mov    %eax,%edx
c010076a:	89 d0                	mov    %edx,%eax
c010076c:	01 c0                	add    %eax,%eax
c010076e:	01 d0                	add    %edx,%eax
c0100770:	c1 e0 02             	shl    $0x2,%eax
c0100773:	89 c2                	mov    %eax,%edx
c0100775:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100778:	01 d0                	add    %edx,%eax
c010077a:	8b 10                	mov    (%eax),%edx
c010077c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010077f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100782:	29 c1                	sub    %eax,%ecx
c0100784:	89 c8                	mov    %ecx,%eax
c0100786:	39 c2                	cmp    %eax,%edx
c0100788:	73 22                	jae    c01007ac <debuginfo_eip+0x251>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010078a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010078d:	89 c2                	mov    %eax,%edx
c010078f:	89 d0                	mov    %edx,%eax
c0100791:	01 c0                	add    %eax,%eax
c0100793:	01 d0                	add    %edx,%eax
c0100795:	c1 e0 02             	shl    $0x2,%eax
c0100798:	89 c2                	mov    %eax,%edx
c010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079d:	01 d0                	add    %edx,%eax
c010079f:	8b 10                	mov    (%eax),%edx
c01007a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007a4:	01 c2                	add    %eax,%edx
c01007a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a9:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007af:	89 c2                	mov    %eax,%edx
c01007b1:	89 d0                	mov    %edx,%eax
c01007b3:	01 c0                	add    %eax,%eax
c01007b5:	01 d0                	add    %edx,%eax
c01007b7:	c1 e0 02             	shl    $0x2,%eax
c01007ba:	89 c2                	mov    %eax,%edx
c01007bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007bf:	01 d0                	add    %edx,%eax
c01007c1:	8b 50 08             	mov    0x8(%eax),%edx
c01007c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c7:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cd:	8b 40 10             	mov    0x10(%eax),%eax
c01007d0:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01007d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01007df:	eb 15                	jmp    c01007f6 <debuginfo_eip+0x29b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e4:	8b 55 08             	mov    0x8(%ebp),%edx
c01007e7:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01007f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007f3:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007f9:	8b 40 08             	mov    0x8(%eax),%eax
c01007fc:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100803:	00 
c0100804:	89 04 24             	mov    %eax,(%esp)
c0100807:	e8 a9 b9 00 00       	call   c010c1b5 <strfind>
c010080c:	89 c2                	mov    %eax,%edx
c010080e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100811:	8b 40 08             	mov    0x8(%eax),%eax
c0100814:	29 c2                	sub    %eax,%edx
c0100816:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100819:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010081c:	8b 45 08             	mov    0x8(%ebp),%eax
c010081f:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100823:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010082a:	00 
c010082b:	8d 45 c8             	lea    -0x38(%ebp),%eax
c010082e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100832:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100835:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100839:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010083c:	89 04 24             	mov    %eax,(%esp)
c010083f:	e8 c1 fb ff ff       	call   c0100405 <stab_binsearch>
    if (lline <= rline) {
c0100844:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100847:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010084a:	39 c2                	cmp    %eax,%edx
c010084c:	7f 24                	jg     c0100872 <debuginfo_eip+0x317>
        info->eip_line = stabs[rline].n_desc;
c010084e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100851:	89 c2                	mov    %eax,%edx
c0100853:	89 d0                	mov    %edx,%eax
c0100855:	01 c0                	add    %eax,%eax
c0100857:	01 d0                	add    %edx,%eax
c0100859:	c1 e0 02             	shl    $0x2,%eax
c010085c:	89 c2                	mov    %eax,%edx
c010085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100867:	0f b7 d0             	movzwl %ax,%edx
c010086a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010086d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100870:	eb 13                	jmp    c0100885 <debuginfo_eip+0x32a>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100877:	e9 12 01 00 00       	jmp    c010098e <debuginfo_eip+0x433>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010087c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010087f:	83 e8 01             	sub    $0x1,%eax
c0100882:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100885:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100888:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010088b:	39 c2                	cmp    %eax,%edx
c010088d:	7c 56                	jl     c01008e5 <debuginfo_eip+0x38a>
           && stabs[lline].n_type != N_SOL
c010088f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100892:	89 c2                	mov    %eax,%edx
c0100894:	89 d0                	mov    %edx,%eax
c0100896:	01 c0                	add    %eax,%eax
c0100898:	01 d0                	add    %edx,%eax
c010089a:	c1 e0 02             	shl    $0x2,%eax
c010089d:	89 c2                	mov    %eax,%edx
c010089f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a2:	01 d0                	add    %edx,%eax
c01008a4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008a8:	3c 84                	cmp    $0x84,%al
c01008aa:	74 39                	je     c01008e5 <debuginfo_eip+0x38a>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008af:	89 c2                	mov    %eax,%edx
c01008b1:	89 d0                	mov    %edx,%eax
c01008b3:	01 c0                	add    %eax,%eax
c01008b5:	01 d0                	add    %edx,%eax
c01008b7:	c1 e0 02             	shl    $0x2,%eax
c01008ba:	89 c2                	mov    %eax,%edx
c01008bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008bf:	01 d0                	add    %edx,%eax
c01008c1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008c5:	3c 64                	cmp    $0x64,%al
c01008c7:	75 b3                	jne    c010087c <debuginfo_eip+0x321>
c01008c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008cc:	89 c2                	mov    %eax,%edx
c01008ce:	89 d0                	mov    %edx,%eax
c01008d0:	01 c0                	add    %eax,%eax
c01008d2:	01 d0                	add    %edx,%eax
c01008d4:	c1 e0 02             	shl    $0x2,%eax
c01008d7:	89 c2                	mov    %eax,%edx
c01008d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008dc:	01 d0                	add    %edx,%eax
c01008de:	8b 40 08             	mov    0x8(%eax),%eax
c01008e1:	85 c0                	test   %eax,%eax
c01008e3:	74 97                	je     c010087c <debuginfo_eip+0x321>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008e5:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008eb:	39 c2                	cmp    %eax,%edx
c01008ed:	7c 46                	jl     c0100935 <debuginfo_eip+0x3da>
c01008ef:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008f2:	89 c2                	mov    %eax,%edx
c01008f4:	89 d0                	mov    %edx,%eax
c01008f6:	01 c0                	add    %eax,%eax
c01008f8:	01 d0                	add    %edx,%eax
c01008fa:	c1 e0 02             	shl    $0x2,%eax
c01008fd:	89 c2                	mov    %eax,%edx
c01008ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100902:	01 d0                	add    %edx,%eax
c0100904:	8b 10                	mov    (%eax),%edx
c0100906:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100909:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010090c:	29 c1                	sub    %eax,%ecx
c010090e:	89 c8                	mov    %ecx,%eax
c0100910:	39 c2                	cmp    %eax,%edx
c0100912:	73 21                	jae    c0100935 <debuginfo_eip+0x3da>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100914:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	89 d0                	mov    %edx,%eax
c010091b:	01 c0                	add    %eax,%eax
c010091d:	01 d0                	add    %edx,%eax
c010091f:	c1 e0 02             	shl    $0x2,%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100927:	01 d0                	add    %edx,%eax
c0100929:	8b 10                	mov    (%eax),%edx
c010092b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010092e:	01 c2                	add    %eax,%edx
c0100930:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100933:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100935:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100938:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010093b:	39 c2                	cmp    %eax,%edx
c010093d:	7d 4a                	jge    c0100989 <debuginfo_eip+0x42e>
        for (lline = lfun + 1;
c010093f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100942:	83 c0 01             	add    $0x1,%eax
c0100945:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100948:	eb 18                	jmp    c0100962 <debuginfo_eip+0x407>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010094a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010094d:	8b 40 14             	mov    0x14(%eax),%eax
c0100950:	8d 50 01             	lea    0x1(%eax),%edx
c0100953:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100956:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100959:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010095c:	83 c0 01             	add    $0x1,%eax
c010095f:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100962:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100965:	8b 45 d0             	mov    -0x30(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100968:	39 c2                	cmp    %eax,%edx
c010096a:	7d 1d                	jge    c0100989 <debuginfo_eip+0x42e>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010096c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010096f:	89 c2                	mov    %eax,%edx
c0100971:	89 d0                	mov    %edx,%eax
c0100973:	01 c0                	add    %eax,%eax
c0100975:	01 d0                	add    %edx,%eax
c0100977:	c1 e0 02             	shl    $0x2,%eax
c010097a:	89 c2                	mov    %eax,%edx
c010097c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097f:	01 d0                	add    %edx,%eax
c0100981:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100985:	3c a0                	cmp    $0xa0,%al
c0100987:	74 c1                	je     c010094a <debuginfo_eip+0x3ef>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100989:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010098e:	c9                   	leave  
c010098f:	c3                   	ret    

c0100990 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100990:	55                   	push   %ebp
c0100991:	89 e5                	mov    %esp,%ebp
c0100993:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100996:	c7 04 24 96 c5 10 c0 	movl   $0xc010c596,(%esp)
c010099d:	e8 c2 f9 ff ff       	call   c0100364 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01009a2:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009a9:	c0 
c01009aa:	c7 04 24 af c5 10 c0 	movl   $0xc010c5af,(%esp)
c01009b1:	e8 ae f9 ff ff       	call   c0100364 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009b6:	c7 44 24 04 ca c4 10 	movl   $0xc010c4ca,0x4(%esp)
c01009bd:	c0 
c01009be:	c7 04 24 c7 c5 10 c0 	movl   $0xc010c5c7,(%esp)
c01009c5:	e8 9a f9 ff ff       	call   c0100364 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009ca:	c7 44 24 04 00 00 1b 	movl   $0xc01b0000,0x4(%esp)
c01009d1:	c0 
c01009d2:	c7 04 24 df c5 10 c0 	movl   $0xc010c5df,(%esp)
c01009d9:	e8 86 f9 ff ff       	call   c0100364 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009de:	c7 44 24 04 f8 31 1b 	movl   $0xc01b31f8,0x4(%esp)
c01009e5:	c0 
c01009e6:	c7 04 24 f7 c5 10 c0 	movl   $0xc010c5f7,(%esp)
c01009ed:	e8 72 f9 ff ff       	call   c0100364 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009f2:	b8 f8 31 1b c0       	mov    $0xc01b31f8,%eax
c01009f7:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009fd:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100a02:	29 c2                	sub    %eax,%edx
c0100a04:	89 d0                	mov    %edx,%eax
c0100a06:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a0c:	85 c0                	test   %eax,%eax
c0100a0e:	0f 48 c2             	cmovs  %edx,%eax
c0100a11:	c1 f8 0a             	sar    $0xa,%eax
c0100a14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a18:	c7 04 24 10 c6 10 c0 	movl   $0xc010c610,(%esp)
c0100a1f:	e8 40 f9 ff ff       	call   c0100364 <cprintf>
}
c0100a24:	c9                   	leave  
c0100a25:	c3                   	ret    

c0100a26 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a26:	55                   	push   %ebp
c0100a27:	89 e5                	mov    %esp,%ebp
c0100a29:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a2f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a36:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a39:	89 04 24             	mov    %eax,(%esp)
c0100a3c:	e8 1a fb ff ff       	call   c010055b <debuginfo_eip>
c0100a41:	85 c0                	test   %eax,%eax
c0100a43:	74 15                	je     c0100a5a <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a4c:	c7 04 24 3a c6 10 c0 	movl   $0xc010c63a,(%esp)
c0100a53:	e8 0c f9 ff ff       	call   c0100364 <cprintf>
c0100a58:	eb 6d                	jmp    c0100ac7 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a61:	eb 1c                	jmp    c0100a7f <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a69:	01 d0                	add    %edx,%eax
c0100a6b:	0f b6 00             	movzbl (%eax),%eax
c0100a6e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a77:	01 ca                	add    %ecx,%edx
c0100a79:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a7b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a82:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a85:	7f dc                	jg     c0100a63 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a87:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a90:	01 d0                	add    %edx,%eax
c0100a92:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a95:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a98:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a9b:	89 d1                	mov    %edx,%ecx
c0100a9d:	29 c1                	sub    %eax,%ecx
c0100a9f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100aa2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100aa5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100aa9:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aaf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100ab3:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100abb:	c7 04 24 56 c6 10 c0 	movl   $0xc010c656,(%esp)
c0100ac2:	e8 9d f8 ff ff       	call   c0100364 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100ac7:	c9                   	leave  
c0100ac8:	c3                   	ret    

c0100ac9 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ac9:	55                   	push   %ebp
c0100aca:	89 e5                	mov    %esp,%ebp
c0100acc:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100acf:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ad2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ad5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ad8:	c9                   	leave  
c0100ad9:	c3                   	ret    

c0100ada <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ada:	55                   	push   %ebp
c0100adb:	89 e5                	mov    %esp,%ebp
c0100add:	53                   	push   %ebx
c0100ade:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ae1:	89 e8                	mov    %ebp,%eax
c0100ae3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100ae6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c0100ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
c0100aec:	e8 d8 ff ff ff       	call   c0100ac9 <read_eip>
c0100af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100af4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100afb:	e9 8d 00 00 00       	jmp    c0100b8d <print_stackframe+0xb3>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c0100b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b03:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b0e:	c7 04 24 68 c6 10 c0 	movl   $0xc010c668,(%esp)
c0100b15:	e8 4a f8 ff ff       	call   c0100364 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
c0100b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b1d:	83 c0 08             	add    $0x8,%eax
c0100b20:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("0x%08x 0x%08x 0x%08x 0x%08x",*args,*(args+1),*(args+2),*(args+3));
c0100b23:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b26:	83 c0 0c             	add    $0xc,%eax
c0100b29:	8b 18                	mov    (%eax),%ebx
c0100b2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b2e:	83 c0 08             	add    $0x8,%eax
c0100b31:	8b 08                	mov    (%eax),%ecx
c0100b33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b36:	83 c0 04             	add    $0x4,%eax
c0100b39:	8b 10                	mov    (%eax),%edx
c0100b3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b3e:	8b 00                	mov    (%eax),%eax
c0100b40:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100b44:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b48:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b50:	c7 04 24 84 c6 10 c0 	movl   $0xc010c684,(%esp)
c0100b57:	e8 08 f8 ff ff       	call   c0100364 <cprintf>
		cprintf("\n");
c0100b5c:	c7 04 24 a0 c6 10 c0 	movl   $0xc010c6a0,(%esp)
c0100b63:	e8 fc f7 ff ff       	call   c0100364 <cprintf>
		print_debuginfo(eip-1);
c0100b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b6b:	83 e8 01             	sub    $0x1,%eax
c0100b6e:	89 04 24             	mov    %eax,(%esp)
c0100b71:	e8 b0 fe ff ff       	call   c0100a26 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b79:	83 c0 04             	add    $0x4,%eax
c0100b7c:	8b 00                	mov    (%eax),%eax
c0100b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
c0100b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b84:	8b 00                	mov    (%eax),%eax
c0100b86:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100b89:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b91:	74 0a                	je     c0100b9d <print_stackframe+0xc3>
c0100b93:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b97:	0f 8e 63 ff ff ff    	jle    c0100b00 <print_stackframe+0x26>
		cprintf("\n");
		print_debuginfo(eip-1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
c0100b9d:	83 c4 44             	add    $0x44,%esp
c0100ba0:	5b                   	pop    %ebx
c0100ba1:	5d                   	pop    %ebp
c0100ba2:	c3                   	ret    

c0100ba3 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ba3:	55                   	push   %ebp
c0100ba4:	89 e5                	mov    %esp,%ebp
c0100ba6:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ba9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bb0:	eb 0c                	jmp    c0100bbe <parse+0x1b>
            *buf ++ = '\0';
c0100bb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb5:	8d 50 01             	lea    0x1(%eax),%edx
c0100bb8:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bbb:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc1:	0f b6 00             	movzbl (%eax),%eax
c0100bc4:	84 c0                	test   %al,%al
c0100bc6:	74 1d                	je     c0100be5 <parse+0x42>
c0100bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcb:	0f b6 00             	movzbl (%eax),%eax
c0100bce:	0f be c0             	movsbl %al,%eax
c0100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd5:	c7 04 24 24 c7 10 c0 	movl   $0xc010c724,(%esp)
c0100bdc:	e8 a1 b5 00 00       	call   c010c182 <strchr>
c0100be1:	85 c0                	test   %eax,%eax
c0100be3:	75 cd                	jne    c0100bb2 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be8:	0f b6 00             	movzbl (%eax),%eax
c0100beb:	84 c0                	test   %al,%al
c0100bed:	75 02                	jne    c0100bf1 <parse+0x4e>
            break;
c0100bef:	eb 67                	jmp    c0100c58 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bf1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bf5:	75 14                	jne    c0100c0b <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bf7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bfe:	00 
c0100bff:	c7 04 24 29 c7 10 c0 	movl   $0xc010c729,(%esp)
c0100c06:	e8 59 f7 ff ff       	call   c0100364 <cprintf>
        }
        argv[argc ++] = buf;
c0100c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c0e:	8d 50 01             	lea    0x1(%eax),%edx
c0100c11:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c1e:	01 c2                	add    %eax,%edx
c0100c20:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c23:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c25:	eb 04                	jmp    c0100c2b <parse+0x88>
            buf ++;
c0100c27:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2e:	0f b6 00             	movzbl (%eax),%eax
c0100c31:	84 c0                	test   %al,%al
c0100c33:	74 1d                	je     c0100c52 <parse+0xaf>
c0100c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c38:	0f b6 00             	movzbl (%eax),%eax
c0100c3b:	0f be c0             	movsbl %al,%eax
c0100c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c42:	c7 04 24 24 c7 10 c0 	movl   $0xc010c724,(%esp)
c0100c49:	e8 34 b5 00 00       	call   c010c182 <strchr>
c0100c4e:	85 c0                	test   %eax,%eax
c0100c50:	74 d5                	je     c0100c27 <parse+0x84>
            buf ++;
        }
    }
c0100c52:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c53:	e9 66 ff ff ff       	jmp    c0100bbe <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c5b:	c9                   	leave  
c0100c5c:	c3                   	ret    

c0100c5d <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c5d:	55                   	push   %ebp
c0100c5e:	89 e5                	mov    %esp,%ebp
c0100c60:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c63:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c6d:	89 04 24             	mov    %eax,(%esp)
c0100c70:	e8 2e ff ff ff       	call   c0100ba3 <parse>
c0100c75:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c7c:	75 0a                	jne    c0100c88 <runcmd+0x2b>
        return 0;
c0100c7e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c83:	e9 85 00 00 00       	jmp    c0100d0d <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c8f:	eb 5c                	jmp    c0100ced <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c91:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c94:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c97:	89 d0                	mov    %edx,%eax
c0100c99:	01 c0                	add    %eax,%eax
c0100c9b:	01 d0                	add    %edx,%eax
c0100c9d:	c1 e0 02             	shl    $0x2,%eax
c0100ca0:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100ca5:	8b 00                	mov    (%eax),%eax
c0100ca7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100cab:	89 04 24             	mov    %eax,(%esp)
c0100cae:	e8 30 b4 00 00       	call   c010c0e3 <strcmp>
c0100cb3:	85 c0                	test   %eax,%eax
c0100cb5:	75 32                	jne    c0100ce9 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cba:	89 d0                	mov    %edx,%eax
c0100cbc:	01 c0                	add    %eax,%eax
c0100cbe:	01 d0                	add    %edx,%eax
c0100cc0:	c1 e0 02             	shl    $0x2,%eax
c0100cc3:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100cc8:	8b 40 08             	mov    0x8(%eax),%eax
c0100ccb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100cce:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100cd4:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cd8:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100cdb:	83 c2 04             	add    $0x4,%edx
c0100cde:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100ce2:	89 0c 24             	mov    %ecx,(%esp)
c0100ce5:	ff d0                	call   *%eax
c0100ce7:	eb 24                	jmp    c0100d0d <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ce9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf0:	83 f8 02             	cmp    $0x2,%eax
c0100cf3:	76 9c                	jbe    c0100c91 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cf5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cfc:	c7 04 24 47 c7 10 c0 	movl   $0xc010c747,(%esp)
c0100d03:	e8 5c f6 ff ff       	call   c0100364 <cprintf>
    return 0;
c0100d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d0d:	c9                   	leave  
c0100d0e:	c3                   	ret    

c0100d0f <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d0f:	55                   	push   %ebp
c0100d10:	89 e5                	mov    %esp,%ebp
c0100d12:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d15:	c7 04 24 60 c7 10 c0 	movl   $0xc010c760,(%esp)
c0100d1c:	e8 43 f6 ff ff       	call   c0100364 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d21:	c7 04 24 88 c7 10 c0 	movl   $0xc010c788,(%esp)
c0100d28:	e8 37 f6 ff ff       	call   c0100364 <cprintf>

    if (tf != NULL) {
c0100d2d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d31:	74 0b                	je     c0100d3e <kmonitor+0x2f>
        print_trapframe(tf);
c0100d33:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d36:	89 04 24             	mov    %eax,(%esp)
c0100d39:	e8 b3 16 00 00       	call   c01023f1 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d3e:	c7 04 24 ad c7 10 c0 	movl   $0xc010c7ad,(%esp)
c0100d45:	e8 11 f5 ff ff       	call   c010025b <readline>
c0100d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d51:	74 18                	je     c0100d6b <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d53:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5d:	89 04 24             	mov    %eax,(%esp)
c0100d60:	e8 f8 fe ff ff       	call   c0100c5d <runcmd>
c0100d65:	85 c0                	test   %eax,%eax
c0100d67:	79 02                	jns    c0100d6b <kmonitor+0x5c>
                break;
c0100d69:	eb 02                	jmp    c0100d6d <kmonitor+0x5e>
            }
        }
    }
c0100d6b:	eb d1                	jmp    c0100d3e <kmonitor+0x2f>
}
c0100d6d:	c9                   	leave  
c0100d6e:	c3                   	ret    

c0100d6f <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d6f:	55                   	push   %ebp
c0100d70:	89 e5                	mov    %esp,%ebp
c0100d72:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d7c:	eb 3f                	jmp    c0100dbd <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d81:	89 d0                	mov    %edx,%eax
c0100d83:	01 c0                	add    %eax,%eax
c0100d85:	01 d0                	add    %edx,%eax
c0100d87:	c1 e0 02             	shl    $0x2,%eax
c0100d8a:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100d8f:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d95:	89 d0                	mov    %edx,%eax
c0100d97:	01 c0                	add    %eax,%eax
c0100d99:	01 d0                	add    %edx,%eax
c0100d9b:	c1 e0 02             	shl    $0x2,%eax
c0100d9e:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100da3:	8b 00                	mov    (%eax),%eax
c0100da5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100da9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dad:	c7 04 24 b1 c7 10 c0 	movl   $0xc010c7b1,(%esp)
c0100db4:	e8 ab f5 ff ff       	call   c0100364 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100db9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dc0:	83 f8 02             	cmp    $0x2,%eax
c0100dc3:	76 b9                	jbe    c0100d7e <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dca:	c9                   	leave  
c0100dcb:	c3                   	ret    

c0100dcc <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100dcc:	55                   	push   %ebp
c0100dcd:	89 e5                	mov    %esp,%ebp
c0100dcf:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100dd2:	e8 b9 fb ff ff       	call   c0100990 <print_kerninfo>
    return 0;
c0100dd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ddc:	c9                   	leave  
c0100ddd:	c3                   	ret    

c0100dde <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dde:	55                   	push   %ebp
c0100ddf:	89 e5                	mov    %esp,%ebp
c0100de1:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100de4:	e8 f1 fc ff ff       	call   c0100ada <print_stackframe>
    return 0;
c0100de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dee:	c9                   	leave  
c0100def:	c3                   	ret    

c0100df0 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100df0:	55                   	push   %ebp
c0100df1:	89 e5                	mov    %esp,%ebp
c0100df3:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100df6:	a1 20 04 1b c0       	mov    0xc01b0420,%eax
c0100dfb:	85 c0                	test   %eax,%eax
c0100dfd:	74 02                	je     c0100e01 <__panic+0x11>
        goto panic_dead;
c0100dff:	eb 59                	jmp    c0100e5a <__panic+0x6a>
    }
    is_panic = 1;
c0100e01:	c7 05 20 04 1b c0 01 	movl   $0x1,0xc01b0420
c0100e08:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100e0b:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100e11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e14:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e18:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e1f:	c7 04 24 ba c7 10 c0 	movl   $0xc010c7ba,(%esp)
c0100e26:	e8 39 f5 ff ff       	call   c0100364 <cprintf>
    vcprintf(fmt, ap);
c0100e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e32:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e35:	89 04 24             	mov    %eax,(%esp)
c0100e38:	e8 f4 f4 ff ff       	call   c0100331 <vcprintf>
    cprintf("\n");
c0100e3d:	c7 04 24 d6 c7 10 c0 	movl   $0xc010c7d6,(%esp)
c0100e44:	e8 1b f5 ff ff       	call   c0100364 <cprintf>
    
    cprintf("stack trackback:\n");
c0100e49:	c7 04 24 d8 c7 10 c0 	movl   $0xc010c7d8,(%esp)
c0100e50:	e8 0f f5 ff ff       	call   c0100364 <cprintf>
    print_stackframe();
c0100e55:	e8 80 fc ff ff       	call   c0100ada <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100e5a:	e8 fa 11 00 00       	call   c0102059 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100e5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e66:	e8 a4 fe ff ff       	call   c0100d0f <kmonitor>
    }
c0100e6b:	eb f2                	jmp    c0100e5f <__panic+0x6f>

c0100e6d <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e6d:	55                   	push   %ebp
c0100e6e:	89 e5                	mov    %esp,%ebp
c0100e70:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e73:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e79:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e80:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e87:	c7 04 24 ea c7 10 c0 	movl   $0xc010c7ea,(%esp)
c0100e8e:	e8 d1 f4 ff ff       	call   c0100364 <cprintf>
    vcprintf(fmt, ap);
c0100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e9a:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e9d:	89 04 24             	mov    %eax,(%esp)
c0100ea0:	e8 8c f4 ff ff       	call   c0100331 <vcprintf>
    cprintf("\n");
c0100ea5:	c7 04 24 d6 c7 10 c0 	movl   $0xc010c7d6,(%esp)
c0100eac:	e8 b3 f4 ff ff       	call   c0100364 <cprintf>
    va_end(ap);
}
c0100eb1:	c9                   	leave  
c0100eb2:	c3                   	ret    

c0100eb3 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100eb3:	55                   	push   %ebp
c0100eb4:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100eb6:	a1 20 04 1b c0       	mov    0xc01b0420,%eax
}
c0100ebb:	5d                   	pop    %ebp
c0100ebc:	c3                   	ret    

c0100ebd <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100ebd:	55                   	push   %ebp
c0100ebe:	89 e5                	mov    %esp,%ebp
c0100ec0:	83 ec 28             	sub    $0x28,%esp
c0100ec3:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100ec9:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ecd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ed1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ed5:	ee                   	out    %al,(%dx)
c0100ed6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100edc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100ee0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ee4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ee8:	ee                   	out    %al,(%dx)
c0100ee9:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100eef:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100ef3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ef7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100efb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100efc:	c7 05 98 30 1b c0 00 	movl   $0x0,0xc01b3098
c0100f03:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100f06:	c7 04 24 08 c8 10 c0 	movl   $0xc010c808,(%esp)
c0100f0d:	e8 52 f4 ff ff       	call   c0100364 <cprintf>
    pic_enable(IRQ_TIMER);
c0100f12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100f19:	e8 99 11 00 00       	call   c01020b7 <pic_enable>
}
c0100f1e:	c9                   	leave  
c0100f1f:	c3                   	ret    

c0100f20 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100f20:	55                   	push   %ebp
c0100f21:	89 e5                	mov    %esp,%ebp
c0100f23:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100f26:	9c                   	pushf  
c0100f27:	58                   	pop    %eax
c0100f28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100f2e:	25 00 02 00 00       	and    $0x200,%eax
c0100f33:	85 c0                	test   %eax,%eax
c0100f35:	74 0c                	je     c0100f43 <__intr_save+0x23>
        intr_disable();
c0100f37:	e8 1d 11 00 00       	call   c0102059 <intr_disable>
        return 1;
c0100f3c:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f41:	eb 05                	jmp    c0100f48 <__intr_save+0x28>
    }
    return 0;
c0100f43:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f48:	c9                   	leave  
c0100f49:	c3                   	ret    

c0100f4a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100f4a:	55                   	push   %ebp
c0100f4b:	89 e5                	mov    %esp,%ebp
c0100f4d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100f50:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100f54:	74 05                	je     c0100f5b <__intr_restore+0x11>
        intr_enable();
c0100f56:	e8 f8 10 00 00       	call   c0102053 <intr_enable>
    }
}
c0100f5b:	c9                   	leave  
c0100f5c:	c3                   	ret    

c0100f5d <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f5d:	55                   	push   %ebp
c0100f5e:	89 e5                	mov    %esp,%ebp
c0100f60:	83 ec 10             	sub    $0x10,%esp
c0100f63:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f69:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100f6d:	89 c2                	mov    %eax,%edx
c0100f6f:	ec                   	in     (%dx),%al
c0100f70:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100f73:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f79:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f7d:	89 c2                	mov    %eax,%edx
c0100f7f:	ec                   	in     (%dx),%al
c0100f80:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100f83:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f89:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f8d:	89 c2                	mov    %eax,%edx
c0100f8f:	ec                   	in     (%dx),%al
c0100f90:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100f93:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100f99:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f9d:	89 c2                	mov    %eax,%edx
c0100f9f:	ec                   	in     (%dx),%al
c0100fa0:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100fa3:	c9                   	leave  
c0100fa4:	c3                   	ret    

c0100fa5 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100fa5:	55                   	push   %ebp
c0100fa6:	89 e5                	mov    %esp,%ebp
c0100fa8:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100fab:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100fb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fb5:	0f b7 00             	movzwl (%eax),%eax
c0100fb8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100fbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fbf:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100fc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc7:	0f b7 00             	movzwl (%eax),%eax
c0100fca:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100fce:	74 12                	je     c0100fe2 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100fd0:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100fd7:	66 c7 05 46 04 1b c0 	movw   $0x3b4,0xc01b0446
c0100fde:	b4 03 
c0100fe0:	eb 13                	jmp    c0100ff5 <cga_init+0x50>
    } else {
        *cp = was;
c0100fe2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fe5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100fe9:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100fec:	66 c7 05 46 04 1b c0 	movw   $0x3d4,0xc01b0446
c0100ff3:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ff5:	0f b7 05 46 04 1b c0 	movzwl 0xc01b0446,%eax
c0100ffc:	0f b7 c0             	movzwl %ax,%eax
c0100fff:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101003:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101007:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010100b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010100f:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101010:	0f b7 05 46 04 1b c0 	movzwl 0xc01b0446,%eax
c0101017:	83 c0 01             	add    $0x1,%eax
c010101a:	0f b7 c0             	movzwl %ax,%eax
c010101d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101021:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101025:	89 c2                	mov    %eax,%edx
c0101027:	ec                   	in     (%dx),%al
c0101028:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010102b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010102f:	0f b6 c0             	movzbl %al,%eax
c0101032:	c1 e0 08             	shl    $0x8,%eax
c0101035:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101038:	0f b7 05 46 04 1b c0 	movzwl 0xc01b0446,%eax
c010103f:	0f b7 c0             	movzwl %ax,%eax
c0101042:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101046:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010104a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010104e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101052:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0101053:	0f b7 05 46 04 1b c0 	movzwl 0xc01b0446,%eax
c010105a:	83 c0 01             	add    $0x1,%eax
c010105d:	0f b7 c0             	movzwl %ax,%eax
c0101060:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101064:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101068:	89 c2                	mov    %eax,%edx
c010106a:	ec                   	in     (%dx),%al
c010106b:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c010106e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101072:	0f b6 c0             	movzbl %al,%eax
c0101075:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101078:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010107b:	a3 40 04 1b c0       	mov    %eax,0xc01b0440
    crt_pos = pos;
c0101080:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101083:	66 a3 44 04 1b c0    	mov    %ax,0xc01b0444
}
c0101089:	c9                   	leave  
c010108a:	c3                   	ret    

c010108b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c010108b:	55                   	push   %ebp
c010108c:	89 e5                	mov    %esp,%ebp
c010108e:	83 ec 48             	sub    $0x48,%esp
c0101091:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0101097:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010109b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010109f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010a3:	ee                   	out    %al,(%dx)
c01010a4:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c01010aa:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c01010ae:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010b2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010b6:	ee                   	out    %al,(%dx)
c01010b7:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c01010bd:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c01010c1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c9:	ee                   	out    %al,(%dx)
c01010ca:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01010d0:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c01010d4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01010d8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01010dc:	ee                   	out    %al,(%dx)
c01010dd:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c01010e3:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c01010e7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01010eb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01010ef:	ee                   	out    %al,(%dx)
c01010f0:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c01010f6:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c01010fa:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01010fe:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101102:	ee                   	out    %al,(%dx)
c0101103:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101109:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c010110d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101111:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101115:	ee                   	out    %al,(%dx)
c0101116:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010111c:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101120:	89 c2                	mov    %eax,%edx
c0101122:	ec                   	in     (%dx),%al
c0101123:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101126:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010112a:	3c ff                	cmp    $0xff,%al
c010112c:	0f 95 c0             	setne  %al
c010112f:	0f b6 c0             	movzbl %al,%eax
c0101132:	a3 48 04 1b c0       	mov    %eax,0xc01b0448
c0101137:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010113d:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101141:	89 c2                	mov    %eax,%edx
c0101143:	ec                   	in     (%dx),%al
c0101144:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101147:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010114d:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101151:	89 c2                	mov    %eax,%edx
c0101153:	ec                   	in     (%dx),%al
c0101154:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101157:	a1 48 04 1b c0       	mov    0xc01b0448,%eax
c010115c:	85 c0                	test   %eax,%eax
c010115e:	74 0c                	je     c010116c <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101160:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101167:	e8 4b 0f 00 00       	call   c01020b7 <pic_enable>
    }
}
c010116c:	c9                   	leave  
c010116d:	c3                   	ret    

c010116e <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010116e:	55                   	push   %ebp
c010116f:	89 e5                	mov    %esp,%ebp
c0101171:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101174:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010117b:	eb 09                	jmp    c0101186 <lpt_putc_sub+0x18>
        delay();
c010117d:	e8 db fd ff ff       	call   c0100f5d <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101182:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101186:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010118c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101190:	89 c2                	mov    %eax,%edx
c0101192:	ec                   	in     (%dx),%al
c0101193:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101196:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010119a:	84 c0                	test   %al,%al
c010119c:	78 09                	js     c01011a7 <lpt_putc_sub+0x39>
c010119e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01011a5:	7e d6                	jle    c010117d <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01011a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01011aa:	0f b6 c0             	movzbl %al,%eax
c01011ad:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01011b3:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011b6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01011ba:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01011be:	ee                   	out    %al,(%dx)
c01011bf:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01011c5:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01011c9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011cd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011d1:	ee                   	out    %al,(%dx)
c01011d2:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01011d8:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01011dc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011e0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011e4:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01011e5:	c9                   	leave  
c01011e6:	c3                   	ret    

c01011e7 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01011e7:	55                   	push   %ebp
c01011e8:	89 e5                	mov    %esp,%ebp
c01011ea:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01011ed:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01011f1:	74 0d                	je     c0101200 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01011f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f6:	89 04 24             	mov    %eax,(%esp)
c01011f9:	e8 70 ff ff ff       	call   c010116e <lpt_putc_sub>
c01011fe:	eb 24                	jmp    c0101224 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101200:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101207:	e8 62 ff ff ff       	call   c010116e <lpt_putc_sub>
        lpt_putc_sub(' ');
c010120c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101213:	e8 56 ff ff ff       	call   c010116e <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101218:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010121f:	e8 4a ff ff ff       	call   c010116e <lpt_putc_sub>
    }
}
c0101224:	c9                   	leave  
c0101225:	c3                   	ret    

c0101226 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101226:	55                   	push   %ebp
c0101227:	89 e5                	mov    %esp,%ebp
c0101229:	53                   	push   %ebx
c010122a:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010122d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101230:	b0 00                	mov    $0x0,%al
c0101232:	85 c0                	test   %eax,%eax
c0101234:	75 07                	jne    c010123d <cga_putc+0x17>
        c |= 0x0700;
c0101236:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010123d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101240:	0f b6 c0             	movzbl %al,%eax
c0101243:	83 f8 0a             	cmp    $0xa,%eax
c0101246:	74 4c                	je     c0101294 <cga_putc+0x6e>
c0101248:	83 f8 0d             	cmp    $0xd,%eax
c010124b:	74 57                	je     c01012a4 <cga_putc+0x7e>
c010124d:	83 f8 08             	cmp    $0x8,%eax
c0101250:	0f 85 88 00 00 00    	jne    c01012de <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101256:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c010125d:	66 85 c0             	test   %ax,%ax
c0101260:	74 30                	je     c0101292 <cga_putc+0x6c>
            crt_pos --;
c0101262:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c0101269:	83 e8 01             	sub    $0x1,%eax
c010126c:	66 a3 44 04 1b c0    	mov    %ax,0xc01b0444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101272:	a1 40 04 1b c0       	mov    0xc01b0440,%eax
c0101277:	0f b7 15 44 04 1b c0 	movzwl 0xc01b0444,%edx
c010127e:	0f b7 d2             	movzwl %dx,%edx
c0101281:	01 d2                	add    %edx,%edx
c0101283:	01 c2                	add    %eax,%edx
c0101285:	8b 45 08             	mov    0x8(%ebp),%eax
c0101288:	b0 00                	mov    $0x0,%al
c010128a:	83 c8 20             	or     $0x20,%eax
c010128d:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101290:	eb 72                	jmp    c0101304 <cga_putc+0xde>
c0101292:	eb 70                	jmp    c0101304 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101294:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c010129b:	83 c0 50             	add    $0x50,%eax
c010129e:	66 a3 44 04 1b c0    	mov    %ax,0xc01b0444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01012a4:	0f b7 1d 44 04 1b c0 	movzwl 0xc01b0444,%ebx
c01012ab:	0f b7 0d 44 04 1b c0 	movzwl 0xc01b0444,%ecx
c01012b2:	0f b7 c1             	movzwl %cx,%eax
c01012b5:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01012bb:	c1 e8 10             	shr    $0x10,%eax
c01012be:	89 c2                	mov    %eax,%edx
c01012c0:	66 c1 ea 06          	shr    $0x6,%dx
c01012c4:	89 d0                	mov    %edx,%eax
c01012c6:	c1 e0 02             	shl    $0x2,%eax
c01012c9:	01 d0                	add    %edx,%eax
c01012cb:	c1 e0 04             	shl    $0x4,%eax
c01012ce:	29 c1                	sub    %eax,%ecx
c01012d0:	89 ca                	mov    %ecx,%edx
c01012d2:	89 d8                	mov    %ebx,%eax
c01012d4:	29 d0                	sub    %edx,%eax
c01012d6:	66 a3 44 04 1b c0    	mov    %ax,0xc01b0444
        break;
c01012dc:	eb 26                	jmp    c0101304 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01012de:	8b 0d 40 04 1b c0    	mov    0xc01b0440,%ecx
c01012e4:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c01012eb:	8d 50 01             	lea    0x1(%eax),%edx
c01012ee:	66 89 15 44 04 1b c0 	mov    %dx,0xc01b0444
c01012f5:	0f b7 c0             	movzwl %ax,%eax
c01012f8:	01 c0                	add    %eax,%eax
c01012fa:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01012fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101300:	66 89 02             	mov    %ax,(%edx)
        break;
c0101303:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101304:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c010130b:	66 3d cf 07          	cmp    $0x7cf,%ax
c010130f:	76 5b                	jbe    c010136c <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101311:	a1 40 04 1b c0       	mov    0xc01b0440,%eax
c0101316:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010131c:	a1 40 04 1b c0       	mov    0xc01b0440,%eax
c0101321:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101328:	00 
c0101329:	89 54 24 04          	mov    %edx,0x4(%esp)
c010132d:	89 04 24             	mov    %eax,(%esp)
c0101330:	e8 4b b0 00 00       	call   c010c380 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101335:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010133c:	eb 15                	jmp    c0101353 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010133e:	a1 40 04 1b c0       	mov    0xc01b0440,%eax
c0101343:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101346:	01 d2                	add    %edx,%edx
c0101348:	01 d0                	add    %edx,%eax
c010134a:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010134f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101353:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010135a:	7e e2                	jle    c010133e <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010135c:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c0101363:	83 e8 50             	sub    $0x50,%eax
c0101366:	66 a3 44 04 1b c0    	mov    %ax,0xc01b0444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010136c:	0f b7 05 46 04 1b c0 	movzwl 0xc01b0446,%eax
c0101373:	0f b7 c0             	movzwl %ax,%eax
c0101376:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010137a:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010137e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101382:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101386:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101387:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c010138e:	66 c1 e8 08          	shr    $0x8,%ax
c0101392:	0f b6 c0             	movzbl %al,%eax
c0101395:	0f b7 15 46 04 1b c0 	movzwl 0xc01b0446,%edx
c010139c:	83 c2 01             	add    $0x1,%edx
c010139f:	0f b7 d2             	movzwl %dx,%edx
c01013a2:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01013a6:	88 45 ed             	mov    %al,-0x13(%ebp)
c01013a9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01013ad:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01013b1:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01013b2:	0f b7 05 46 04 1b c0 	movzwl 0xc01b0446,%eax
c01013b9:	0f b7 c0             	movzwl %ax,%eax
c01013bc:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01013c0:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01013c4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013c8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013cc:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01013cd:	0f b7 05 44 04 1b c0 	movzwl 0xc01b0444,%eax
c01013d4:	0f b6 c0             	movzbl %al,%eax
c01013d7:	0f b7 15 46 04 1b c0 	movzwl 0xc01b0446,%edx
c01013de:	83 c2 01             	add    $0x1,%edx
c01013e1:	0f b7 d2             	movzwl %dx,%edx
c01013e4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013e8:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013eb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013ef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013f3:	ee                   	out    %al,(%dx)
}
c01013f4:	83 c4 34             	add    $0x34,%esp
c01013f7:	5b                   	pop    %ebx
c01013f8:	5d                   	pop    %ebp
c01013f9:	c3                   	ret    

c01013fa <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01013fa:	55                   	push   %ebp
c01013fb:	89 e5                	mov    %esp,%ebp
c01013fd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101400:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101407:	eb 09                	jmp    c0101412 <serial_putc_sub+0x18>
        delay();
c0101409:	e8 4f fb ff ff       	call   c0100f5d <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010140e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101412:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101418:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010141c:	89 c2                	mov    %eax,%edx
c010141e:	ec                   	in     (%dx),%al
c010141f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101422:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101426:	0f b6 c0             	movzbl %al,%eax
c0101429:	83 e0 20             	and    $0x20,%eax
c010142c:	85 c0                	test   %eax,%eax
c010142e:	75 09                	jne    c0101439 <serial_putc_sub+0x3f>
c0101430:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101437:	7e d0                	jle    c0101409 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101439:	8b 45 08             	mov    0x8(%ebp),%eax
c010143c:	0f b6 c0             	movzbl %al,%eax
c010143f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101445:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101448:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010144c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101450:	ee                   	out    %al,(%dx)
}
c0101451:	c9                   	leave  
c0101452:	c3                   	ret    

c0101453 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101453:	55                   	push   %ebp
c0101454:	89 e5                	mov    %esp,%ebp
c0101456:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101459:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010145d:	74 0d                	je     c010146c <serial_putc+0x19>
        serial_putc_sub(c);
c010145f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101462:	89 04 24             	mov    %eax,(%esp)
c0101465:	e8 90 ff ff ff       	call   c01013fa <serial_putc_sub>
c010146a:	eb 24                	jmp    c0101490 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010146c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101473:	e8 82 ff ff ff       	call   c01013fa <serial_putc_sub>
        serial_putc_sub(' ');
c0101478:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010147f:	e8 76 ff ff ff       	call   c01013fa <serial_putc_sub>
        serial_putc_sub('\b');
c0101484:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010148b:	e8 6a ff ff ff       	call   c01013fa <serial_putc_sub>
    }
}
c0101490:	c9                   	leave  
c0101491:	c3                   	ret    

c0101492 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101492:	55                   	push   %ebp
c0101493:	89 e5                	mov    %esp,%ebp
c0101495:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101498:	eb 33                	jmp    c01014cd <cons_intr+0x3b>
        if (c != 0) {
c010149a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010149e:	74 2d                	je     c01014cd <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01014a0:	a1 64 06 1b c0       	mov    0xc01b0664,%eax
c01014a5:	8d 50 01             	lea    0x1(%eax),%edx
c01014a8:	89 15 64 06 1b c0    	mov    %edx,0xc01b0664
c01014ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01014b1:	88 90 60 04 1b c0    	mov    %dl,-0x3fe4fba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01014b7:	a1 64 06 1b c0       	mov    0xc01b0664,%eax
c01014bc:	3d 00 02 00 00       	cmp    $0x200,%eax
c01014c1:	75 0a                	jne    c01014cd <cons_intr+0x3b>
                cons.wpos = 0;
c01014c3:	c7 05 64 06 1b c0 00 	movl   $0x0,0xc01b0664
c01014ca:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01014cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01014d0:	ff d0                	call   *%eax
c01014d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014d5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01014d9:	75 bf                	jne    c010149a <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01014db:	c9                   	leave  
c01014dc:	c3                   	ret    

c01014dd <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01014dd:	55                   	push   %ebp
c01014de:	89 e5                	mov    %esp,%ebp
c01014e0:	83 ec 10             	sub    $0x10,%esp
c01014e3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014e9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01014ed:	89 c2                	mov    %eax,%edx
c01014ef:	ec                   	in     (%dx),%al
c01014f0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01014f3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01014f7:	0f b6 c0             	movzbl %al,%eax
c01014fa:	83 e0 01             	and    $0x1,%eax
c01014fd:	85 c0                	test   %eax,%eax
c01014ff:	75 07                	jne    c0101508 <serial_proc_data+0x2b>
        return -1;
c0101501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101506:	eb 2a                	jmp    c0101532 <serial_proc_data+0x55>
c0101508:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010150e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101512:	89 c2                	mov    %eax,%edx
c0101514:	ec                   	in     (%dx),%al
c0101515:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101518:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010151c:	0f b6 c0             	movzbl %al,%eax
c010151f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101522:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101526:	75 07                	jne    c010152f <serial_proc_data+0x52>
        c = '\b';
c0101528:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010152f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101532:	c9                   	leave  
c0101533:	c3                   	ret    

c0101534 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101534:	55                   	push   %ebp
c0101535:	89 e5                	mov    %esp,%ebp
c0101537:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010153a:	a1 48 04 1b c0       	mov    0xc01b0448,%eax
c010153f:	85 c0                	test   %eax,%eax
c0101541:	74 0c                	je     c010154f <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101543:	c7 04 24 dd 14 10 c0 	movl   $0xc01014dd,(%esp)
c010154a:	e8 43 ff ff ff       	call   c0101492 <cons_intr>
    }
}
c010154f:	c9                   	leave  
c0101550:	c3                   	ret    

c0101551 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101551:	55                   	push   %ebp
c0101552:	89 e5                	mov    %esp,%ebp
c0101554:	83 ec 38             	sub    $0x38,%esp
c0101557:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010155d:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101561:	89 c2                	mov    %eax,%edx
c0101563:	ec                   	in     (%dx),%al
c0101564:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101567:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010156b:	0f b6 c0             	movzbl %al,%eax
c010156e:	83 e0 01             	and    $0x1,%eax
c0101571:	85 c0                	test   %eax,%eax
c0101573:	75 0a                	jne    c010157f <kbd_proc_data+0x2e>
        return -1;
c0101575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010157a:	e9 59 01 00 00       	jmp    c01016d8 <kbd_proc_data+0x187>
c010157f:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101585:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101589:	89 c2                	mov    %eax,%edx
c010158b:	ec                   	in     (%dx),%al
c010158c:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010158f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101593:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101596:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010159a:	75 17                	jne    c01015b3 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010159c:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c01015a1:	83 c8 40             	or     $0x40,%eax
c01015a4:	a3 68 06 1b c0       	mov    %eax,0xc01b0668
        return 0;
c01015a9:	b8 00 00 00 00       	mov    $0x0,%eax
c01015ae:	e9 25 01 00 00       	jmp    c01016d8 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01015b3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015b7:	84 c0                	test   %al,%al
c01015b9:	79 47                	jns    c0101602 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01015bb:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c01015c0:	83 e0 40             	and    $0x40,%eax
c01015c3:	85 c0                	test   %eax,%eax
c01015c5:	75 09                	jne    c01015d0 <kbd_proc_data+0x7f>
c01015c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015cb:	83 e0 7f             	and    $0x7f,%eax
c01015ce:	eb 04                	jmp    c01015d4 <kbd_proc_data+0x83>
c01015d0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015d4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01015d7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015db:	0f b6 80 40 c0 12 c0 	movzbl -0x3fed3fc0(%eax),%eax
c01015e2:	83 c8 40             	or     $0x40,%eax
c01015e5:	0f b6 c0             	movzbl %al,%eax
c01015e8:	f7 d0                	not    %eax
c01015ea:	89 c2                	mov    %eax,%edx
c01015ec:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c01015f1:	21 d0                	and    %edx,%eax
c01015f3:	a3 68 06 1b c0       	mov    %eax,0xc01b0668
        return 0;
c01015f8:	b8 00 00 00 00       	mov    $0x0,%eax
c01015fd:	e9 d6 00 00 00       	jmp    c01016d8 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101602:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c0101607:	83 e0 40             	and    $0x40,%eax
c010160a:	85 c0                	test   %eax,%eax
c010160c:	74 11                	je     c010161f <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010160e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101612:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c0101617:	83 e0 bf             	and    $0xffffffbf,%eax
c010161a:	a3 68 06 1b c0       	mov    %eax,0xc01b0668
    }

    shift |= shiftcode[data];
c010161f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101623:	0f b6 80 40 c0 12 c0 	movzbl -0x3fed3fc0(%eax),%eax
c010162a:	0f b6 d0             	movzbl %al,%edx
c010162d:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c0101632:	09 d0                	or     %edx,%eax
c0101634:	a3 68 06 1b c0       	mov    %eax,0xc01b0668
    shift ^= togglecode[data];
c0101639:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010163d:	0f b6 80 40 c1 12 c0 	movzbl -0x3fed3ec0(%eax),%eax
c0101644:	0f b6 d0             	movzbl %al,%edx
c0101647:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c010164c:	31 d0                	xor    %edx,%eax
c010164e:	a3 68 06 1b c0       	mov    %eax,0xc01b0668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101653:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c0101658:	83 e0 03             	and    $0x3,%eax
c010165b:	8b 14 85 40 c5 12 c0 	mov    -0x3fed3ac0(,%eax,4),%edx
c0101662:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101666:	01 d0                	add    %edx,%eax
c0101668:	0f b6 00             	movzbl (%eax),%eax
c010166b:	0f b6 c0             	movzbl %al,%eax
c010166e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101671:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c0101676:	83 e0 08             	and    $0x8,%eax
c0101679:	85 c0                	test   %eax,%eax
c010167b:	74 22                	je     c010169f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010167d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101681:	7e 0c                	jle    c010168f <kbd_proc_data+0x13e>
c0101683:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101687:	7f 06                	jg     c010168f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101689:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010168d:	eb 10                	jmp    c010169f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010168f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101693:	7e 0a                	jle    c010169f <kbd_proc_data+0x14e>
c0101695:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101699:	7f 04                	jg     c010169f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010169b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010169f:	a1 68 06 1b c0       	mov    0xc01b0668,%eax
c01016a4:	f7 d0                	not    %eax
c01016a6:	83 e0 06             	and    $0x6,%eax
c01016a9:	85 c0                	test   %eax,%eax
c01016ab:	75 28                	jne    c01016d5 <kbd_proc_data+0x184>
c01016ad:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01016b4:	75 1f                	jne    c01016d5 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01016b6:	c7 04 24 23 c8 10 c0 	movl   $0xc010c823,(%esp)
c01016bd:	e8 a2 ec ff ff       	call   c0100364 <cprintf>
c01016c2:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01016c8:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016cc:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01016d0:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01016d4:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016d8:	c9                   	leave  
c01016d9:	c3                   	ret    

c01016da <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01016da:	55                   	push   %ebp
c01016db:	89 e5                	mov    %esp,%ebp
c01016dd:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01016e0:	c7 04 24 51 15 10 c0 	movl   $0xc0101551,(%esp)
c01016e7:	e8 a6 fd ff ff       	call   c0101492 <cons_intr>
}
c01016ec:	c9                   	leave  
c01016ed:	c3                   	ret    

c01016ee <kbd_init>:

static void
kbd_init(void) {
c01016ee:	55                   	push   %ebp
c01016ef:	89 e5                	mov    %esp,%ebp
c01016f1:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01016f4:	e8 e1 ff ff ff       	call   c01016da <kbd_intr>
    pic_enable(IRQ_KBD);
c01016f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101700:	e8 b2 09 00 00       	call   c01020b7 <pic_enable>
}
c0101705:	c9                   	leave  
c0101706:	c3                   	ret    

c0101707 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101707:	55                   	push   %ebp
c0101708:	89 e5                	mov    %esp,%ebp
c010170a:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c010170d:	e8 93 f8 ff ff       	call   c0100fa5 <cga_init>
    serial_init();
c0101712:	e8 74 f9 ff ff       	call   c010108b <serial_init>
    kbd_init();
c0101717:	e8 d2 ff ff ff       	call   c01016ee <kbd_init>
    if (!serial_exists) {
c010171c:	a1 48 04 1b c0       	mov    0xc01b0448,%eax
c0101721:	85 c0                	test   %eax,%eax
c0101723:	75 0c                	jne    c0101731 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101725:	c7 04 24 2f c8 10 c0 	movl   $0xc010c82f,(%esp)
c010172c:	e8 33 ec ff ff       	call   c0100364 <cprintf>
    }
}
c0101731:	c9                   	leave  
c0101732:	c3                   	ret    

c0101733 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101733:	55                   	push   %ebp
c0101734:	89 e5                	mov    %esp,%ebp
c0101736:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101739:	e8 e2 f7 ff ff       	call   c0100f20 <__intr_save>
c010173e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101741:	8b 45 08             	mov    0x8(%ebp),%eax
c0101744:	89 04 24             	mov    %eax,(%esp)
c0101747:	e8 9b fa ff ff       	call   c01011e7 <lpt_putc>
        cga_putc(c);
c010174c:	8b 45 08             	mov    0x8(%ebp),%eax
c010174f:	89 04 24             	mov    %eax,(%esp)
c0101752:	e8 cf fa ff ff       	call   c0101226 <cga_putc>
        serial_putc(c);
c0101757:	8b 45 08             	mov    0x8(%ebp),%eax
c010175a:	89 04 24             	mov    %eax,(%esp)
c010175d:	e8 f1 fc ff ff       	call   c0101453 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101762:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101765:	89 04 24             	mov    %eax,(%esp)
c0101768:	e8 dd f7 ff ff       	call   c0100f4a <__intr_restore>
}
c010176d:	c9                   	leave  
c010176e:	c3                   	ret    

c010176f <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010176f:	55                   	push   %ebp
c0101770:	89 e5                	mov    %esp,%ebp
c0101772:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101775:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010177c:	e8 9f f7 ff ff       	call   c0100f20 <__intr_save>
c0101781:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101784:	e8 ab fd ff ff       	call   c0101534 <serial_intr>
        kbd_intr();
c0101789:	e8 4c ff ff ff       	call   c01016da <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010178e:	8b 15 60 06 1b c0    	mov    0xc01b0660,%edx
c0101794:	a1 64 06 1b c0       	mov    0xc01b0664,%eax
c0101799:	39 c2                	cmp    %eax,%edx
c010179b:	74 31                	je     c01017ce <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010179d:	a1 60 06 1b c0       	mov    0xc01b0660,%eax
c01017a2:	8d 50 01             	lea    0x1(%eax),%edx
c01017a5:	89 15 60 06 1b c0    	mov    %edx,0xc01b0660
c01017ab:	0f b6 80 60 04 1b c0 	movzbl -0x3fe4fba0(%eax),%eax
c01017b2:	0f b6 c0             	movzbl %al,%eax
c01017b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01017b8:	a1 60 06 1b c0       	mov    0xc01b0660,%eax
c01017bd:	3d 00 02 00 00       	cmp    $0x200,%eax
c01017c2:	75 0a                	jne    c01017ce <cons_getc+0x5f>
                cons.rpos = 0;
c01017c4:	c7 05 60 06 1b c0 00 	movl   $0x0,0xc01b0660
c01017cb:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01017ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017d1:	89 04 24             	mov    %eax,(%esp)
c01017d4:	e8 71 f7 ff ff       	call   c0100f4a <__intr_restore>
    return c;
c01017d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017dc:	c9                   	leave  
c01017dd:	c3                   	ret    

c01017de <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01017de:	55                   	push   %ebp
c01017df:	89 e5                	mov    %esp,%ebp
c01017e1:	83 ec 14             	sub    $0x14,%esp
c01017e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01017e7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01017eb:	90                   	nop
c01017ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017f0:	83 c0 07             	add    $0x7,%eax
c01017f3:	0f b7 c0             	movzwl %ax,%eax
c01017f6:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017fe:	89 c2                	mov    %eax,%edx
c0101800:	ec                   	in     (%dx),%al
c0101801:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101804:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101808:	0f b6 c0             	movzbl %al,%eax
c010180b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010180e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101811:	25 80 00 00 00       	and    $0x80,%eax
c0101816:	85 c0                	test   %eax,%eax
c0101818:	75 d2                	jne    c01017ec <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c010181a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010181e:	74 11                	je     c0101831 <ide_wait_ready+0x53>
c0101820:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101823:	83 e0 21             	and    $0x21,%eax
c0101826:	85 c0                	test   %eax,%eax
c0101828:	74 07                	je     c0101831 <ide_wait_ready+0x53>
        return -1;
c010182a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010182f:	eb 05                	jmp    c0101836 <ide_wait_ready+0x58>
    }
    return 0;
c0101831:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101836:	c9                   	leave  
c0101837:	c3                   	ret    

c0101838 <ide_init>:

void
ide_init(void) {
c0101838:	55                   	push   %ebp
c0101839:	89 e5                	mov    %esp,%ebp
c010183b:	57                   	push   %edi
c010183c:	53                   	push   %ebx
c010183d:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101843:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0101849:	e9 d6 02 00 00       	jmp    c0101b24 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c010184e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101852:	c1 e0 03             	shl    $0x3,%eax
c0101855:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010185c:	29 c2                	sub    %eax,%edx
c010185e:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101864:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0101867:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010186b:	66 d1 e8             	shr    %ax
c010186e:	0f b7 c0             	movzwl %ax,%eax
c0101871:	0f b7 04 85 50 c8 10 	movzwl -0x3fef37b0(,%eax,4),%eax
c0101878:	c0 
c0101879:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c010187d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101881:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101888:	00 
c0101889:	89 04 24             	mov    %eax,(%esp)
c010188c:	e8 4d ff ff ff       	call   c01017de <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0101891:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101895:	83 e0 01             	and    $0x1,%eax
c0101898:	c1 e0 04             	shl    $0x4,%eax
c010189b:	83 c8 e0             	or     $0xffffffe0,%eax
c010189e:	0f b6 c0             	movzbl %al,%eax
c01018a1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018a5:	83 c2 06             	add    $0x6,%edx
c01018a8:	0f b7 d2             	movzwl %dx,%edx
c01018ab:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c01018af:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018b2:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01018b6:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01018ba:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018bb:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018c6:	00 
c01018c7:	89 04 24             	mov    %eax,(%esp)
c01018ca:	e8 0f ff ff ff       	call   c01017de <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01018cf:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018d3:	83 c0 07             	add    $0x7,%eax
c01018d6:	0f b7 c0             	movzwl %ax,%eax
c01018d9:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01018dd:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01018e1:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01018e5:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01018e9:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018ea:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018f5:	00 
c01018f6:	89 04 24             	mov    %eax,(%esp)
c01018f9:	e8 e0 fe ff ff       	call   c01017de <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01018fe:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101902:	83 c0 07             	add    $0x7,%eax
c0101905:	0f b7 c0             	movzwl %ax,%eax
c0101908:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010190c:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0101910:	89 c2                	mov    %eax,%edx
c0101912:	ec                   	in     (%dx),%al
c0101913:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0101916:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010191a:	84 c0                	test   %al,%al
c010191c:	0f 84 f7 01 00 00    	je     c0101b19 <ide_init+0x2e1>
c0101922:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101926:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010192d:	00 
c010192e:	89 04 24             	mov    %eax,(%esp)
c0101931:	e8 a8 fe ff ff       	call   c01017de <ide_wait_ready>
c0101936:	85 c0                	test   %eax,%eax
c0101938:	0f 85 db 01 00 00    	jne    c0101b19 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c010193e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101942:	c1 e0 03             	shl    $0x3,%eax
c0101945:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010194c:	29 c2                	sub    %eax,%edx
c010194e:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101954:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101957:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010195b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010195e:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101964:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101967:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c010196e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101971:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101974:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101977:	89 cb                	mov    %ecx,%ebx
c0101979:	89 df                	mov    %ebx,%edi
c010197b:	89 c1                	mov    %eax,%ecx
c010197d:	fc                   	cld    
c010197e:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101980:	89 c8                	mov    %ecx,%eax
c0101982:	89 fb                	mov    %edi,%ebx
c0101984:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101987:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c010198a:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101990:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101993:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101996:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010199c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010199f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019a2:	25 00 00 00 04       	and    $0x4000000,%eax
c01019a7:	85 c0                	test   %eax,%eax
c01019a9:	74 0e                	je     c01019b9 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01019ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019ae:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01019b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01019b7:	eb 09                	jmp    c01019c2 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01019b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019bc:	8b 40 78             	mov    0x78(%eax),%eax
c01019bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01019c2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019c6:	c1 e0 03             	shl    $0x3,%eax
c01019c9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019d0:	29 c2                	sub    %eax,%edx
c01019d2:	81 c2 80 06 1b c0    	add    $0xc01b0680,%edx
c01019d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019db:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01019de:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019e2:	c1 e0 03             	shl    $0x3,%eax
c01019e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019ec:	29 c2                	sub    %eax,%edx
c01019ee:	81 c2 80 06 1b c0    	add    $0xc01b0680,%edx
c01019f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019f7:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01019fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019fd:	83 c0 62             	add    $0x62,%eax
c0101a00:	0f b7 00             	movzwl (%eax),%eax
c0101a03:	0f b7 c0             	movzwl %ax,%eax
c0101a06:	25 00 02 00 00       	and    $0x200,%eax
c0101a0b:	85 c0                	test   %eax,%eax
c0101a0d:	75 24                	jne    c0101a33 <ide_init+0x1fb>
c0101a0f:	c7 44 24 0c 58 c8 10 	movl   $0xc010c858,0xc(%esp)
c0101a16:	c0 
c0101a17:	c7 44 24 08 9b c8 10 	movl   $0xc010c89b,0x8(%esp)
c0101a1e:	c0 
c0101a1f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101a26:	00 
c0101a27:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0101a2e:	e8 bd f3 ff ff       	call   c0100df0 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101a33:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a37:	c1 e0 03             	shl    $0x3,%eax
c0101a3a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a41:	29 c2                	sub    %eax,%edx
c0101a43:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101a49:	83 c0 0c             	add    $0xc,%eax
c0101a4c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a52:	83 c0 36             	add    $0x36,%eax
c0101a55:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101a58:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101a5f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101a66:	eb 34                	jmp    c0101a9c <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101a68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a6e:	01 c2                	add    %eax,%edx
c0101a70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a73:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a76:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a79:	01 c8                	add    %ecx,%eax
c0101a7b:	0f b6 00             	movzbl (%eax),%eax
c0101a7e:	88 02                	mov    %al,(%edx)
c0101a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a83:	8d 50 01             	lea    0x1(%eax),%edx
c0101a86:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a89:	01 c2                	add    %eax,%edx
c0101a8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a8e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101a91:	01 c8                	add    %ecx,%eax
c0101a93:	0f b6 00             	movzbl (%eax),%eax
c0101a96:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101a98:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a9f:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101aa2:	72 c4                	jb     c0101a68 <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aa7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101aaa:	01 d0                	add    %edx,%eax
c0101aac:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101aaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ab2:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101ab5:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101ab8:	85 c0                	test   %eax,%eax
c0101aba:	74 0f                	je     c0101acb <ide_init+0x293>
c0101abc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101abf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101ac2:	01 d0                	add    %edx,%eax
c0101ac4:	0f b6 00             	movzbl (%eax),%eax
c0101ac7:	3c 20                	cmp    $0x20,%al
c0101ac9:	74 d9                	je     c0101aa4 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101acb:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101acf:	c1 e0 03             	shl    $0x3,%eax
c0101ad2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101ad9:	29 c2                	sub    %eax,%edx
c0101adb:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101ae1:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101ae4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101ae8:	c1 e0 03             	shl    $0x3,%eax
c0101aeb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101af2:	29 c2                	sub    %eax,%edx
c0101af4:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101afa:	8b 50 08             	mov    0x8(%eax),%edx
c0101afd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b01:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101b05:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b0d:	c7 04 24 c2 c8 10 c0 	movl   $0xc010c8c2,(%esp)
c0101b14:	e8 4b e8 ff ff       	call   c0100364 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101b19:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b1d:	83 c0 01             	add    $0x1,%eax
c0101b20:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b24:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101b29:	0f 86 1f fd ff ff    	jbe    c010184e <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101b2f:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101b36:	e8 7c 05 00 00       	call   c01020b7 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101b3b:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101b42:	e8 70 05 00 00       	call   c01020b7 <pic_enable>
}
c0101b47:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101b4d:	5b                   	pop    %ebx
c0101b4e:	5f                   	pop    %edi
c0101b4f:	5d                   	pop    %ebp
c0101b50:	c3                   	ret    

c0101b51 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101b51:	55                   	push   %ebp
c0101b52:	89 e5                	mov    %esp,%ebp
c0101b54:	83 ec 04             	sub    $0x4,%esp
c0101b57:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101b5e:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101b63:	77 24                	ja     c0101b89 <ide_device_valid+0x38>
c0101b65:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b69:	c1 e0 03             	shl    $0x3,%eax
c0101b6c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b73:	29 c2                	sub    %eax,%edx
c0101b75:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101b7b:	0f b6 00             	movzbl (%eax),%eax
c0101b7e:	84 c0                	test   %al,%al
c0101b80:	74 07                	je     c0101b89 <ide_device_valid+0x38>
c0101b82:	b8 01 00 00 00       	mov    $0x1,%eax
c0101b87:	eb 05                	jmp    c0101b8e <ide_device_valid+0x3d>
c0101b89:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b8e:	c9                   	leave  
c0101b8f:	c3                   	ret    

c0101b90 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b90:	55                   	push   %ebp
c0101b91:	89 e5                	mov    %esp,%ebp
c0101b93:	83 ec 08             	sub    $0x8,%esp
c0101b96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b9d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101ba1:	89 04 24             	mov    %eax,(%esp)
c0101ba4:	e8 a8 ff ff ff       	call   c0101b51 <ide_device_valid>
c0101ba9:	85 c0                	test   %eax,%eax
c0101bab:	74 1b                	je     c0101bc8 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101bad:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101bb1:	c1 e0 03             	shl    $0x3,%eax
c0101bb4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101bbb:	29 c2                	sub    %eax,%edx
c0101bbd:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101bc3:	8b 40 08             	mov    0x8(%eax),%eax
c0101bc6:	eb 05                	jmp    c0101bcd <ide_device_size+0x3d>
    }
    return 0;
c0101bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101bcd:	c9                   	leave  
c0101bce:	c3                   	ret    

c0101bcf <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101bcf:	55                   	push   %ebp
c0101bd0:	89 e5                	mov    %esp,%ebp
c0101bd2:	57                   	push   %edi
c0101bd3:	53                   	push   %ebx
c0101bd4:	83 ec 50             	sub    $0x50,%esp
c0101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bda:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101bde:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101be5:	77 24                	ja     c0101c0b <ide_read_secs+0x3c>
c0101be7:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101bec:	77 1d                	ja     c0101c0b <ide_read_secs+0x3c>
c0101bee:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bf2:	c1 e0 03             	shl    $0x3,%eax
c0101bf5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101bfc:	29 c2                	sub    %eax,%edx
c0101bfe:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101c04:	0f b6 00             	movzbl (%eax),%eax
c0101c07:	84 c0                	test   %al,%al
c0101c09:	75 24                	jne    c0101c2f <ide_read_secs+0x60>
c0101c0b:	c7 44 24 0c e0 c8 10 	movl   $0xc010c8e0,0xc(%esp)
c0101c12:	c0 
c0101c13:	c7 44 24 08 9b c8 10 	movl   $0xc010c89b,0x8(%esp)
c0101c1a:	c0 
c0101c1b:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101c22:	00 
c0101c23:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0101c2a:	e8 c1 f1 ff ff       	call   c0100df0 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101c2f:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101c36:	77 0f                	ja     c0101c47 <ide_read_secs+0x78>
c0101c38:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101c3e:	01 d0                	add    %edx,%eax
c0101c40:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101c45:	76 24                	jbe    c0101c6b <ide_read_secs+0x9c>
c0101c47:	c7 44 24 0c 08 c9 10 	movl   $0xc010c908,0xc(%esp)
c0101c4e:	c0 
c0101c4f:	c7 44 24 08 9b c8 10 	movl   $0xc010c89b,0x8(%esp)
c0101c56:	c0 
c0101c57:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101c5e:	00 
c0101c5f:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0101c66:	e8 85 f1 ff ff       	call   c0100df0 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101c6b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c6f:	66 d1 e8             	shr    %ax
c0101c72:	0f b7 c0             	movzwl %ax,%eax
c0101c75:	0f b7 04 85 50 c8 10 	movzwl -0x3fef37b0(,%eax,4),%eax
c0101c7c:	c0 
c0101c7d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101c81:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c85:	66 d1 e8             	shr    %ax
c0101c88:	0f b7 c0             	movzwl %ax,%eax
c0101c8b:	0f b7 04 85 52 c8 10 	movzwl -0x3fef37ae(,%eax,4),%eax
c0101c92:	c0 
c0101c93:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101c97:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ca2:	00 
c0101ca3:	89 04 24             	mov    %eax,(%esp)
c0101ca6:	e8 33 fb ff ff       	call   c01017de <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101cab:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101caf:	83 c0 02             	add    $0x2,%eax
c0101cb2:	0f b7 c0             	movzwl %ax,%eax
c0101cb5:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101cb9:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cbd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101cc1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101cc5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101cc6:	8b 45 14             	mov    0x14(%ebp),%eax
c0101cc9:	0f b6 c0             	movzbl %al,%eax
c0101ccc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cd0:	83 c2 02             	add    $0x2,%edx
c0101cd3:	0f b7 d2             	movzwl %dx,%edx
c0101cd6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cda:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101cdd:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101ce1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101ce5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ce9:	0f b6 c0             	movzbl %al,%eax
c0101cec:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cf0:	83 c2 03             	add    $0x3,%edx
c0101cf3:	0f b7 d2             	movzwl %dx,%edx
c0101cf6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101cfa:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101cfd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101d01:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101d05:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101d06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d09:	c1 e8 08             	shr    $0x8,%eax
c0101d0c:	0f b6 c0             	movzbl %al,%eax
c0101d0f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d13:	83 c2 04             	add    $0x4,%edx
c0101d16:	0f b7 d2             	movzwl %dx,%edx
c0101d19:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101d1d:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101d20:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101d24:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101d28:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101d29:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d2c:	c1 e8 10             	shr    $0x10,%eax
c0101d2f:	0f b6 c0             	movzbl %al,%eax
c0101d32:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d36:	83 c2 05             	add    $0x5,%edx
c0101d39:	0f b7 d2             	movzwl %dx,%edx
c0101d3c:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101d40:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101d43:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101d47:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101d4b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101d4c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d50:	83 e0 01             	and    $0x1,%eax
c0101d53:	c1 e0 04             	shl    $0x4,%eax
c0101d56:	89 c2                	mov    %eax,%edx
c0101d58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d5b:	c1 e8 18             	shr    $0x18,%eax
c0101d5e:	83 e0 0f             	and    $0xf,%eax
c0101d61:	09 d0                	or     %edx,%eax
c0101d63:	83 c8 e0             	or     $0xffffffe0,%eax
c0101d66:	0f b6 c0             	movzbl %al,%eax
c0101d69:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d6d:	83 c2 06             	add    $0x6,%edx
c0101d70:	0f b7 d2             	movzwl %dx,%edx
c0101d73:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101d77:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101d7a:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101d7e:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101d82:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101d83:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d87:	83 c0 07             	add    $0x7,%eax
c0101d8a:	0f b7 c0             	movzwl %ax,%eax
c0101d8d:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101d91:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101d95:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101d99:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101d9d:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101d9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101da5:	eb 5a                	jmp    c0101e01 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101da7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101db2:	00 
c0101db3:	89 04 24             	mov    %eax,(%esp)
c0101db6:	e8 23 fa ff ff       	call   c01017de <ide_wait_ready>
c0101dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101dbe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101dc2:	74 02                	je     c0101dc6 <ide_read_secs+0x1f7>
            goto out;
c0101dc4:	eb 41                	jmp    c0101e07 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101dc6:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dca:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101dcd:	8b 45 10             	mov    0x10(%ebp),%eax
c0101dd0:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101dd3:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101dda:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101ddd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101de0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101de3:	89 cb                	mov    %ecx,%ebx
c0101de5:	89 df                	mov    %ebx,%edi
c0101de7:	89 c1                	mov    %eax,%ecx
c0101de9:	fc                   	cld    
c0101dea:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101dec:	89 c8                	mov    %ecx,%eax
c0101dee:	89 fb                	mov    %edi,%ebx
c0101df0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101df3:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101df6:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101dfa:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101e01:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101e05:	75 a0                	jne    c0101da7 <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e0a:	83 c4 50             	add    $0x50,%esp
c0101e0d:	5b                   	pop    %ebx
c0101e0e:	5f                   	pop    %edi
c0101e0f:	5d                   	pop    %ebp
c0101e10:	c3                   	ret    

c0101e11 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101e11:	55                   	push   %ebp
c0101e12:	89 e5                	mov    %esp,%ebp
c0101e14:	56                   	push   %esi
c0101e15:	53                   	push   %ebx
c0101e16:	83 ec 50             	sub    $0x50,%esp
c0101e19:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e1c:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101e20:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101e27:	77 24                	ja     c0101e4d <ide_write_secs+0x3c>
c0101e29:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101e2e:	77 1d                	ja     c0101e4d <ide_write_secs+0x3c>
c0101e30:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e34:	c1 e0 03             	shl    $0x3,%eax
c0101e37:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101e3e:	29 c2                	sub    %eax,%edx
c0101e40:	8d 82 80 06 1b c0    	lea    -0x3fe4f980(%edx),%eax
c0101e46:	0f b6 00             	movzbl (%eax),%eax
c0101e49:	84 c0                	test   %al,%al
c0101e4b:	75 24                	jne    c0101e71 <ide_write_secs+0x60>
c0101e4d:	c7 44 24 0c e0 c8 10 	movl   $0xc010c8e0,0xc(%esp)
c0101e54:	c0 
c0101e55:	c7 44 24 08 9b c8 10 	movl   $0xc010c89b,0x8(%esp)
c0101e5c:	c0 
c0101e5d:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101e64:	00 
c0101e65:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0101e6c:	e8 7f ef ff ff       	call   c0100df0 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101e71:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101e78:	77 0f                	ja     c0101e89 <ide_write_secs+0x78>
c0101e7a:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e7d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101e80:	01 d0                	add    %edx,%eax
c0101e82:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101e87:	76 24                	jbe    c0101ead <ide_write_secs+0x9c>
c0101e89:	c7 44 24 0c 08 c9 10 	movl   $0xc010c908,0xc(%esp)
c0101e90:	c0 
c0101e91:	c7 44 24 08 9b c8 10 	movl   $0xc010c89b,0x8(%esp)
c0101e98:	c0 
c0101e99:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101ea0:	00 
c0101ea1:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0101ea8:	e8 43 ef ff ff       	call   c0100df0 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101ead:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101eb1:	66 d1 e8             	shr    %ax
c0101eb4:	0f b7 c0             	movzwl %ax,%eax
c0101eb7:	0f b7 04 85 50 c8 10 	movzwl -0x3fef37b0(,%eax,4),%eax
c0101ebe:	c0 
c0101ebf:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101ec3:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ec7:	66 d1 e8             	shr    %ax
c0101eca:	0f b7 c0             	movzwl %ax,%eax
c0101ecd:	0f b7 04 85 52 c8 10 	movzwl -0x3fef37ae(,%eax,4),%eax
c0101ed4:	c0 
c0101ed5:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101ed9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101edd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ee4:	00 
c0101ee5:	89 04 24             	mov    %eax,(%esp)
c0101ee8:	e8 f1 f8 ff ff       	call   c01017de <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101eed:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101ef1:	83 c0 02             	add    $0x2,%eax
c0101ef4:	0f b7 c0             	movzwl %ax,%eax
c0101ef7:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101efb:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101eff:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f03:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f07:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101f08:	8b 45 14             	mov    0x14(%ebp),%eax
c0101f0b:	0f b6 c0             	movzbl %al,%eax
c0101f0e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f12:	83 c2 02             	add    $0x2,%edx
c0101f15:	0f b7 d2             	movzwl %dx,%edx
c0101f18:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101f1c:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101f1f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f23:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f27:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101f28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f2b:	0f b6 c0             	movzbl %al,%eax
c0101f2e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f32:	83 c2 03             	add    $0x3,%edx
c0101f35:	0f b7 d2             	movzwl %dx,%edx
c0101f38:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101f3c:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101f3f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101f43:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101f47:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101f48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f4b:	c1 e8 08             	shr    $0x8,%eax
c0101f4e:	0f b6 c0             	movzbl %al,%eax
c0101f51:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f55:	83 c2 04             	add    $0x4,%edx
c0101f58:	0f b7 d2             	movzwl %dx,%edx
c0101f5b:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101f5f:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101f62:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101f66:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101f6a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f6e:	c1 e8 10             	shr    $0x10,%eax
c0101f71:	0f b6 c0             	movzbl %al,%eax
c0101f74:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f78:	83 c2 05             	add    $0x5,%edx
c0101f7b:	0f b7 d2             	movzwl %dx,%edx
c0101f7e:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101f82:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101f85:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f89:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101f8d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101f8e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101f92:	83 e0 01             	and    $0x1,%eax
c0101f95:	c1 e0 04             	shl    $0x4,%eax
c0101f98:	89 c2                	mov    %eax,%edx
c0101f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f9d:	c1 e8 18             	shr    $0x18,%eax
c0101fa0:	83 e0 0f             	and    $0xf,%eax
c0101fa3:	09 d0                	or     %edx,%eax
c0101fa5:	83 c8 e0             	or     $0xffffffe0,%eax
c0101fa8:	0f b6 c0             	movzbl %al,%eax
c0101fab:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101faf:	83 c2 06             	add    $0x6,%edx
c0101fb2:	0f b7 d2             	movzwl %dx,%edx
c0101fb5:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101fb9:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101fbc:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101fc0:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101fc4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101fc5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fc9:	83 c0 07             	add    $0x7,%eax
c0101fcc:	0f b7 c0             	movzwl %ax,%eax
c0101fcf:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101fd3:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101fd7:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101fdb:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101fdf:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101fe0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101fe7:	eb 5a                	jmp    c0102043 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101fe9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101ff4:	00 
c0101ff5:	89 04 24             	mov    %eax,(%esp)
c0101ff8:	e8 e1 f7 ff ff       	call   c01017de <ide_wait_ready>
c0101ffd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102000:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102004:	74 02                	je     c0102008 <ide_write_secs+0x1f7>
            goto out;
c0102006:	eb 41                	jmp    c0102049 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0102008:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010200c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010200f:	8b 45 10             	mov    0x10(%ebp),%eax
c0102012:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102015:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c010201c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010201f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0102022:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102025:	89 cb                	mov    %ecx,%ebx
c0102027:	89 de                	mov    %ebx,%esi
c0102029:	89 c1                	mov    %eax,%ecx
c010202b:	fc                   	cld    
c010202c:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c010202e:	89 c8                	mov    %ecx,%eax
c0102030:	89 f3                	mov    %esi,%ebx
c0102032:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102035:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102038:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c010203c:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102043:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102047:	75 a0                	jne    c0101fe9 <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0102049:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010204c:	83 c4 50             	add    $0x50,%esp
c010204f:	5b                   	pop    %ebx
c0102050:	5e                   	pop    %esi
c0102051:	5d                   	pop    %ebp
c0102052:	c3                   	ret    

c0102053 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0102053:	55                   	push   %ebp
c0102054:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0102056:	fb                   	sti    
    sti();
}
c0102057:	5d                   	pop    %ebp
c0102058:	c3                   	ret    

c0102059 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102059:	55                   	push   %ebp
c010205a:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010205c:	fa                   	cli    
    cli();
}
c010205d:	5d                   	pop    %ebp
c010205e:	c3                   	ret    

c010205f <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010205f:	55                   	push   %ebp
c0102060:	89 e5                	mov    %esp,%ebp
c0102062:	83 ec 14             	sub    $0x14,%esp
c0102065:	8b 45 08             	mov    0x8(%ebp),%eax
c0102068:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010206c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102070:	66 a3 50 c5 12 c0    	mov    %ax,0xc012c550
    if (did_init) {
c0102076:	a1 60 07 1b c0       	mov    0xc01b0760,%eax
c010207b:	85 c0                	test   %eax,%eax
c010207d:	74 36                	je     c01020b5 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c010207f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102083:	0f b6 c0             	movzbl %al,%eax
c0102086:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010208c:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010208f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102093:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102097:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0102098:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010209c:	66 c1 e8 08          	shr    $0x8,%ax
c01020a0:	0f b6 c0             	movzbl %al,%eax
c01020a3:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01020a9:	88 45 f9             	mov    %al,-0x7(%ebp)
c01020ac:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020b0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020b4:	ee                   	out    %al,(%dx)
    }
}
c01020b5:	c9                   	leave  
c01020b6:	c3                   	ret    

c01020b7 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01020b7:	55                   	push   %ebp
c01020b8:	89 e5                	mov    %esp,%ebp
c01020ba:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01020bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01020c0:	ba 01 00 00 00       	mov    $0x1,%edx
c01020c5:	89 c1                	mov    %eax,%ecx
c01020c7:	d3 e2                	shl    %cl,%edx
c01020c9:	89 d0                	mov    %edx,%eax
c01020cb:	f7 d0                	not    %eax
c01020cd:	89 c2                	mov    %eax,%edx
c01020cf:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c01020d6:	21 d0                	and    %edx,%eax
c01020d8:	0f b7 c0             	movzwl %ax,%eax
c01020db:	89 04 24             	mov    %eax,(%esp)
c01020de:	e8 7c ff ff ff       	call   c010205f <pic_setmask>
}
c01020e3:	c9                   	leave  
c01020e4:	c3                   	ret    

c01020e5 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020e5:	55                   	push   %ebp
c01020e6:	89 e5                	mov    %esp,%ebp
c01020e8:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020eb:	c7 05 60 07 1b c0 01 	movl   $0x1,0xc01b0760
c01020f2:	00 00 00 
c01020f5:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020fb:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01020ff:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102103:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102107:	ee                   	out    %al,(%dx)
c0102108:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010210e:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102112:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102116:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010211a:	ee                   	out    %al,(%dx)
c010211b:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102121:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102125:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102129:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010212d:	ee                   	out    %al,(%dx)
c010212e:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102134:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0102138:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010213c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102140:	ee                   	out    %al,(%dx)
c0102141:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0102147:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010214b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010214f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102153:	ee                   	out    %al,(%dx)
c0102154:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010215a:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c010215e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102162:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102166:	ee                   	out    %al,(%dx)
c0102167:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c010216d:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102171:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102175:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102179:	ee                   	out    %al,(%dx)
c010217a:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102180:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102184:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102188:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010218c:	ee                   	out    %al,(%dx)
c010218d:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0102193:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0102197:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010219b:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010219f:	ee                   	out    %al,(%dx)
c01021a0:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c01021a6:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01021aa:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01021ae:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01021b2:	ee                   	out    %al,(%dx)
c01021b3:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01021b9:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01021bd:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01021c1:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01021c5:	ee                   	out    %al,(%dx)
c01021c6:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021cc:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01021d0:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021d4:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021d8:	ee                   	out    %al,(%dx)
c01021d9:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01021df:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01021e3:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021e7:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021eb:	ee                   	out    %al,(%dx)
c01021ec:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01021f2:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01021f6:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01021fa:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01021fe:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021ff:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c0102206:	66 83 f8 ff          	cmp    $0xffff,%ax
c010220a:	74 12                	je     c010221e <pic_init+0x139>
        pic_setmask(irq_mask);
c010220c:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c0102213:	0f b7 c0             	movzwl %ax,%eax
c0102216:	89 04 24             	mov    %eax,(%esp)
c0102219:	e8 41 fe ff ff       	call   c010205f <pic_setmask>
    }
}
c010221e:	c9                   	leave  
c010221f:	c3                   	ret    

c0102220 <print_ticks>:
#include <sync.h>
#include <proc.h>

#define TICK_NUM 100

static void print_ticks() {
c0102220:	55                   	push   %ebp
c0102221:	89 e5                	mov    %esp,%ebp
c0102223:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102226:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010222d:	00 
c010222e:	c7 04 24 60 c9 10 c0 	movl   $0xc010c960,(%esp)
c0102235:	e8 2a e1 ff ff       	call   c0100364 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010223a:	c9                   	leave  
c010223b:	c3                   	ret    

c010223c <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010223c:	55                   	push   %ebp
c010223d:	89 e5                	mov    %esp,%ebp
c010223f:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c0102242:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102249:	e9 c3 00 00 00       	jmp    c0102311 <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010224e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102251:	8b 04 85 e0 c5 12 c0 	mov    -0x3fed3a20(,%eax,4),%eax
c0102258:	89 c2                	mov    %eax,%edx
c010225a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010225d:	66 89 14 c5 80 07 1b 	mov    %dx,-0x3fe4f880(,%eax,8)
c0102264:	c0 
c0102265:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102268:	66 c7 04 c5 82 07 1b 	movw   $0x8,-0x3fe4f87e(,%eax,8)
c010226f:	c0 08 00 
c0102272:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102275:	0f b6 14 c5 84 07 1b 	movzbl -0x3fe4f87c(,%eax,8),%edx
c010227c:	c0 
c010227d:	83 e2 e0             	and    $0xffffffe0,%edx
c0102280:	88 14 c5 84 07 1b c0 	mov    %dl,-0x3fe4f87c(,%eax,8)
c0102287:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010228a:	0f b6 14 c5 84 07 1b 	movzbl -0x3fe4f87c(,%eax,8),%edx
c0102291:	c0 
c0102292:	83 e2 1f             	and    $0x1f,%edx
c0102295:	88 14 c5 84 07 1b c0 	mov    %dl,-0x3fe4f87c(,%eax,8)
c010229c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010229f:	0f b6 14 c5 85 07 1b 	movzbl -0x3fe4f87b(,%eax,8),%edx
c01022a6:	c0 
c01022a7:	83 e2 f0             	and    $0xfffffff0,%edx
c01022aa:	83 ca 0e             	or     $0xe,%edx
c01022ad:	88 14 c5 85 07 1b c0 	mov    %dl,-0x3fe4f87b(,%eax,8)
c01022b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022b7:	0f b6 14 c5 85 07 1b 	movzbl -0x3fe4f87b(,%eax,8),%edx
c01022be:	c0 
c01022bf:	83 e2 ef             	and    $0xffffffef,%edx
c01022c2:	88 14 c5 85 07 1b c0 	mov    %dl,-0x3fe4f87b(,%eax,8)
c01022c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022cc:	0f b6 14 c5 85 07 1b 	movzbl -0x3fe4f87b(,%eax,8),%edx
c01022d3:	c0 
c01022d4:	83 e2 9f             	and    $0xffffff9f,%edx
c01022d7:	88 14 c5 85 07 1b c0 	mov    %dl,-0x3fe4f87b(,%eax,8)
c01022de:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022e1:	0f b6 14 c5 85 07 1b 	movzbl -0x3fe4f87b(,%eax,8),%edx
c01022e8:	c0 
c01022e9:	83 ca 80             	or     $0xffffff80,%edx
c01022ec:	88 14 c5 85 07 1b c0 	mov    %dl,-0x3fe4f87b(,%eax,8)
c01022f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f6:	8b 04 85 e0 c5 12 c0 	mov    -0x3fed3a20(,%eax,4),%eax
c01022fd:	c1 e8 10             	shr    $0x10,%eax
c0102300:	89 c2                	mov    %eax,%edx
c0102302:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102305:	66 89 14 c5 86 07 1b 	mov    %dx,-0x3fe4f87a(,%eax,8)
c010230c:	c0 
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c010230d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102311:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102314:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102319:	0f 86 2f ff ff ff    	jbe    c010224e <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
	}
	//SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	//SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], 3);
	SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c010231f:	a1 e0 c7 12 c0       	mov    0xc012c7e0,%eax
c0102324:	66 a3 80 0b 1b c0    	mov    %ax,0xc01b0b80
c010232a:	66 c7 05 82 0b 1b c0 	movw   $0x8,0xc01b0b82
c0102331:	08 00 
c0102333:	0f b6 05 84 0b 1b c0 	movzbl 0xc01b0b84,%eax
c010233a:	83 e0 e0             	and    $0xffffffe0,%eax
c010233d:	a2 84 0b 1b c0       	mov    %al,0xc01b0b84
c0102342:	0f b6 05 84 0b 1b c0 	movzbl 0xc01b0b84,%eax
c0102349:	83 e0 1f             	and    $0x1f,%eax
c010234c:	a2 84 0b 1b c0       	mov    %al,0xc01b0b84
c0102351:	0f b6 05 85 0b 1b c0 	movzbl 0xc01b0b85,%eax
c0102358:	83 c8 0f             	or     $0xf,%eax
c010235b:	a2 85 0b 1b c0       	mov    %al,0xc01b0b85
c0102360:	0f b6 05 85 0b 1b c0 	movzbl 0xc01b0b85,%eax
c0102367:	83 e0 ef             	and    $0xffffffef,%eax
c010236a:	a2 85 0b 1b c0       	mov    %al,0xc01b0b85
c010236f:	0f b6 05 85 0b 1b c0 	movzbl 0xc01b0b85,%eax
c0102376:	83 c8 60             	or     $0x60,%eax
c0102379:	a2 85 0b 1b c0       	mov    %al,0xc01b0b85
c010237e:	0f b6 05 85 0b 1b c0 	movzbl 0xc01b0b85,%eax
c0102385:	83 c8 80             	or     $0xffffff80,%eax
c0102388:	a2 85 0b 1b c0       	mov    %al,0xc01b0b85
c010238d:	a1 e0 c7 12 c0       	mov    0xc012c7e0,%eax
c0102392:	c1 e8 10             	shr    $0x10,%eax
c0102395:	66 a3 86 0b 1b c0    	mov    %ax,0xc01b0b86
c010239b:	c7 45 f8 60 c5 12 c0 	movl   $0xc012c560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01023a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01023a5:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
c01023a8:	c9                   	leave  
c01023a9:	c3                   	ret    

c01023aa <trapname>:

static const char *
trapname(int trapno) {
c01023aa:	55                   	push   %ebp
c01023ab:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b0:	83 f8 13             	cmp    $0x13,%eax
c01023b3:	77 0c                	ja     c01023c1 <trapname+0x17>
        return excnames[trapno];
c01023b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b8:	8b 04 85 e0 cd 10 c0 	mov    -0x3fef3220(,%eax,4),%eax
c01023bf:	eb 18                	jmp    c01023d9 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023c1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023c5:	7e 0d                	jle    c01023d4 <trapname+0x2a>
c01023c7:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023cb:	7f 07                	jg     c01023d4 <trapname+0x2a>
        return "Hardware Interrupt";
c01023cd:	b8 6a c9 10 c0       	mov    $0xc010c96a,%eax
c01023d2:	eb 05                	jmp    c01023d9 <trapname+0x2f>
    }
    return "(unknown trap)";
c01023d4:	b8 7d c9 10 c0       	mov    $0xc010c97d,%eax
}
c01023d9:	5d                   	pop    %ebp
c01023da:	c3                   	ret    

c01023db <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023db:	55                   	push   %ebp
c01023dc:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023de:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023e5:	66 83 f8 08          	cmp    $0x8,%ax
c01023e9:	0f 94 c0             	sete   %al
c01023ec:	0f b6 c0             	movzbl %al,%eax
}
c01023ef:	5d                   	pop    %ebp
c01023f0:	c3                   	ret    

c01023f1 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023f1:	55                   	push   %ebp
c01023f2:	89 e5                	mov    %esp,%ebp
c01023f4:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023fe:	c7 04 24 be c9 10 c0 	movl   $0xc010c9be,(%esp)
c0102405:	e8 5a df ff ff       	call   c0100364 <cprintf>
    print_regs(&tf->tf_regs);
c010240a:	8b 45 08             	mov    0x8(%ebp),%eax
c010240d:	89 04 24             	mov    %eax,(%esp)
c0102410:	e8 a1 01 00 00       	call   c01025b6 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102415:	8b 45 08             	mov    0x8(%ebp),%eax
c0102418:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010241c:	0f b7 c0             	movzwl %ax,%eax
c010241f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102423:	c7 04 24 cf c9 10 c0 	movl   $0xc010c9cf,(%esp)
c010242a:	e8 35 df ff ff       	call   c0100364 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010242f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102432:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102436:	0f b7 c0             	movzwl %ax,%eax
c0102439:	89 44 24 04          	mov    %eax,0x4(%esp)
c010243d:	c7 04 24 e2 c9 10 c0 	movl   $0xc010c9e2,(%esp)
c0102444:	e8 1b df ff ff       	call   c0100364 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102449:	8b 45 08             	mov    0x8(%ebp),%eax
c010244c:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102450:	0f b7 c0             	movzwl %ax,%eax
c0102453:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102457:	c7 04 24 f5 c9 10 c0 	movl   $0xc010c9f5,(%esp)
c010245e:	e8 01 df ff ff       	call   c0100364 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102463:	8b 45 08             	mov    0x8(%ebp),%eax
c0102466:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010246a:	0f b7 c0             	movzwl %ax,%eax
c010246d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102471:	c7 04 24 08 ca 10 c0 	movl   $0xc010ca08,(%esp)
c0102478:	e8 e7 de ff ff       	call   c0100364 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010247d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102480:	8b 40 30             	mov    0x30(%eax),%eax
c0102483:	89 04 24             	mov    %eax,(%esp)
c0102486:	e8 1f ff ff ff       	call   c01023aa <trapname>
c010248b:	8b 55 08             	mov    0x8(%ebp),%edx
c010248e:	8b 52 30             	mov    0x30(%edx),%edx
c0102491:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102495:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102499:	c7 04 24 1b ca 10 c0 	movl   $0xc010ca1b,(%esp)
c01024a0:	e8 bf de ff ff       	call   c0100364 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01024a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a8:	8b 40 34             	mov    0x34(%eax),%eax
c01024ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024af:	c7 04 24 2d ca 10 c0 	movl   $0xc010ca2d,(%esp)
c01024b6:	e8 a9 de ff ff       	call   c0100364 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01024be:	8b 40 38             	mov    0x38(%eax),%eax
c01024c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c5:	c7 04 24 3c ca 10 c0 	movl   $0xc010ca3c,(%esp)
c01024cc:	e8 93 de ff ff       	call   c0100364 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024d8:	0f b7 c0             	movzwl %ax,%eax
c01024db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024df:	c7 04 24 4b ca 10 c0 	movl   $0xc010ca4b,(%esp)
c01024e6:	e8 79 de ff ff       	call   c0100364 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ee:	8b 40 40             	mov    0x40(%eax),%eax
c01024f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f5:	c7 04 24 5e ca 10 c0 	movl   $0xc010ca5e,(%esp)
c01024fc:	e8 63 de ff ff       	call   c0100364 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102508:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c010250f:	eb 3e                	jmp    c010254f <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102511:	8b 45 08             	mov    0x8(%ebp),%eax
c0102514:	8b 50 40             	mov    0x40(%eax),%edx
c0102517:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010251a:	21 d0                	and    %edx,%eax
c010251c:	85 c0                	test   %eax,%eax
c010251e:	74 28                	je     c0102548 <print_trapframe+0x157>
c0102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102523:	8b 04 85 80 c5 12 c0 	mov    -0x3fed3a80(,%eax,4),%eax
c010252a:	85 c0                	test   %eax,%eax
c010252c:	74 1a                	je     c0102548 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c010252e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102531:	8b 04 85 80 c5 12 c0 	mov    -0x3fed3a80(,%eax,4),%eax
c0102538:	89 44 24 04          	mov    %eax,0x4(%esp)
c010253c:	c7 04 24 6d ca 10 c0 	movl   $0xc010ca6d,(%esp)
c0102543:	e8 1c de ff ff       	call   c0100364 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102548:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010254c:	d1 65 f0             	shll   -0x10(%ebp)
c010254f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102552:	83 f8 17             	cmp    $0x17,%eax
c0102555:	76 ba                	jbe    c0102511 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102557:	8b 45 08             	mov    0x8(%ebp),%eax
c010255a:	8b 40 40             	mov    0x40(%eax),%eax
c010255d:	25 00 30 00 00       	and    $0x3000,%eax
c0102562:	c1 e8 0c             	shr    $0xc,%eax
c0102565:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102569:	c7 04 24 71 ca 10 c0 	movl   $0xc010ca71,(%esp)
c0102570:	e8 ef dd ff ff       	call   c0100364 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102575:	8b 45 08             	mov    0x8(%ebp),%eax
c0102578:	89 04 24             	mov    %eax,(%esp)
c010257b:	e8 5b fe ff ff       	call   c01023db <trap_in_kernel>
c0102580:	85 c0                	test   %eax,%eax
c0102582:	75 30                	jne    c01025b4 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102584:	8b 45 08             	mov    0x8(%ebp),%eax
c0102587:	8b 40 44             	mov    0x44(%eax),%eax
c010258a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258e:	c7 04 24 7a ca 10 c0 	movl   $0xc010ca7a,(%esp)
c0102595:	e8 ca dd ff ff       	call   c0100364 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010259a:	8b 45 08             	mov    0x8(%ebp),%eax
c010259d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01025a1:	0f b7 c0             	movzwl %ax,%eax
c01025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a8:	c7 04 24 89 ca 10 c0 	movl   $0xc010ca89,(%esp)
c01025af:	e8 b0 dd ff ff       	call   c0100364 <cprintf>
    }
}
c01025b4:	c9                   	leave  
c01025b5:	c3                   	ret    

c01025b6 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025b6:	55                   	push   %ebp
c01025b7:	89 e5                	mov    %esp,%ebp
c01025b9:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01025bf:	8b 00                	mov    (%eax),%eax
c01025c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c5:	c7 04 24 9c ca 10 c0 	movl   $0xc010ca9c,(%esp)
c01025cc:	e8 93 dd ff ff       	call   c0100364 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d4:	8b 40 04             	mov    0x4(%eax),%eax
c01025d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025db:	c7 04 24 ab ca 10 c0 	movl   $0xc010caab,(%esp)
c01025e2:	e8 7d dd ff ff       	call   c0100364 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01025e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ea:	8b 40 08             	mov    0x8(%eax),%eax
c01025ed:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025f1:	c7 04 24 ba ca 10 c0 	movl   $0xc010caba,(%esp)
c01025f8:	e8 67 dd ff ff       	call   c0100364 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102600:	8b 40 0c             	mov    0xc(%eax),%eax
c0102603:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102607:	c7 04 24 c9 ca 10 c0 	movl   $0xc010cac9,(%esp)
c010260e:	e8 51 dd ff ff       	call   c0100364 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102613:	8b 45 08             	mov    0x8(%ebp),%eax
c0102616:	8b 40 10             	mov    0x10(%eax),%eax
c0102619:	89 44 24 04          	mov    %eax,0x4(%esp)
c010261d:	c7 04 24 d8 ca 10 c0 	movl   $0xc010cad8,(%esp)
c0102624:	e8 3b dd ff ff       	call   c0100364 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102629:	8b 45 08             	mov    0x8(%ebp),%eax
c010262c:	8b 40 14             	mov    0x14(%eax),%eax
c010262f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102633:	c7 04 24 e7 ca 10 c0 	movl   $0xc010cae7,(%esp)
c010263a:	e8 25 dd ff ff       	call   c0100364 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010263f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102642:	8b 40 18             	mov    0x18(%eax),%eax
c0102645:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102649:	c7 04 24 f6 ca 10 c0 	movl   $0xc010caf6,(%esp)
c0102650:	e8 0f dd ff ff       	call   c0100364 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102655:	8b 45 08             	mov    0x8(%ebp),%eax
c0102658:	8b 40 1c             	mov    0x1c(%eax),%eax
c010265b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010265f:	c7 04 24 05 cb 10 c0 	movl   $0xc010cb05,(%esp)
c0102666:	e8 f9 dc ff ff       	call   c0100364 <cprintf>
}
c010266b:	c9                   	leave  
c010266c:	c3                   	ret    

c010266d <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010266d:	55                   	push   %ebp
c010266e:	89 e5                	mov    %esp,%ebp
c0102670:	53                   	push   %ebx
c0102671:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102674:	8b 45 08             	mov    0x8(%ebp),%eax
c0102677:	8b 40 34             	mov    0x34(%eax),%eax
c010267a:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010267d:	85 c0                	test   %eax,%eax
c010267f:	74 07                	je     c0102688 <print_pgfault+0x1b>
c0102681:	b9 14 cb 10 c0       	mov    $0xc010cb14,%ecx
c0102686:	eb 05                	jmp    c010268d <print_pgfault+0x20>
c0102688:	b9 25 cb 10 c0       	mov    $0xc010cb25,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c010268d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102690:	8b 40 34             	mov    0x34(%eax),%eax
c0102693:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102696:	85 c0                	test   %eax,%eax
c0102698:	74 07                	je     c01026a1 <print_pgfault+0x34>
c010269a:	ba 57 00 00 00       	mov    $0x57,%edx
c010269f:	eb 05                	jmp    c01026a6 <print_pgfault+0x39>
c01026a1:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01026a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01026a9:	8b 40 34             	mov    0x34(%eax),%eax
c01026ac:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026af:	85 c0                	test   %eax,%eax
c01026b1:	74 07                	je     c01026ba <print_pgfault+0x4d>
c01026b3:	b8 55 00 00 00       	mov    $0x55,%eax
c01026b8:	eb 05                	jmp    c01026bf <print_pgfault+0x52>
c01026ba:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026bf:	0f 20 d3             	mov    %cr2,%ebx
c01026c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01026c5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01026c8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01026cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01026d0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01026d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01026d8:	c7 04 24 34 cb 10 c0 	movl   $0xc010cb34,(%esp)
c01026df:	e8 80 dc ff ff       	call   c0100364 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01026e4:	83 c4 34             	add    $0x34,%esp
c01026e7:	5b                   	pop    %ebx
c01026e8:	5d                   	pop    %ebp
c01026e9:	c3                   	ret    

c01026ea <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026ea:	55                   	push   %ebp
c01026eb:	89 e5                	mov    %esp,%ebp
c01026ed:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c01026f0:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c01026f5:	85 c0                	test   %eax,%eax
c01026f7:	74 0b                	je     c0102704 <pgfault_handler+0x1a>
            print_pgfault(tf);
c01026f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01026fc:	89 04 24             	mov    %eax,(%esp)
c01026ff:	e8 69 ff ff ff       	call   c010266d <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c0102704:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c0102709:	85 c0                	test   %eax,%eax
c010270b:	74 3d                	je     c010274a <pgfault_handler+0x60>
        assert(current == idleproc);
c010270d:	8b 15 48 10 1b c0    	mov    0xc01b1048,%edx
c0102713:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c0102718:	39 c2                	cmp    %eax,%edx
c010271a:	74 24                	je     c0102740 <pgfault_handler+0x56>
c010271c:	c7 44 24 0c 57 cb 10 	movl   $0xc010cb57,0xc(%esp)
c0102723:	c0 
c0102724:	c7 44 24 08 6b cb 10 	movl   $0xc010cb6b,0x8(%esp)
c010272b:	c0 
c010272c:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0102733:	00 
c0102734:	c7 04 24 80 cb 10 c0 	movl   $0xc010cb80,(%esp)
c010273b:	e8 b0 e6 ff ff       	call   c0100df0 <__panic>
        mm = check_mm_struct;
c0102740:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c0102745:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102748:	eb 46                	jmp    c0102790 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c010274a:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010274f:	85 c0                	test   %eax,%eax
c0102751:	75 32                	jne    c0102785 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102753:	8b 45 08             	mov    0x8(%ebp),%eax
c0102756:	89 04 24             	mov    %eax,(%esp)
c0102759:	e8 93 fc ff ff       	call   c01023f1 <print_trapframe>
            print_pgfault(tf);
c010275e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102761:	89 04 24             	mov    %eax,(%esp)
c0102764:	e8 04 ff ff ff       	call   c010266d <print_pgfault>
            panic("unhandled page fault.\n");
c0102769:	c7 44 24 08 91 cb 10 	movl   $0xc010cb91,0x8(%esp)
c0102770:	c0 
c0102771:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0102778:	00 
c0102779:	c7 04 24 80 cb 10 c0 	movl   $0xc010cb80,(%esp)
c0102780:	e8 6b e6 ff ff       	call   c0100df0 <__panic>
        }
        mm = current->mm;
c0102785:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010278a:	8b 40 18             	mov    0x18(%eax),%eax
c010278d:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102790:	0f 20 d0             	mov    %cr2,%eax
c0102793:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c0102796:	8b 45 f0             	mov    -0x10(%ebp),%eax
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c0102799:	89 c2                	mov    %eax,%edx
c010279b:	8b 45 08             	mov    0x8(%ebp),%eax
c010279e:	8b 40 34             	mov    0x34(%eax),%eax
c01027a1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027ac:	89 04 24             	mov    %eax,(%esp)
c01027af:	e8 37 67 00 00       	call   c0108eeb <do_pgfault>
}
c01027b4:	c9                   	leave  
c01027b5:	c3                   	ret    

c01027b6 <trap_dispatch>:

/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

static void
trap_dispatch(struct trapframe *tf) {
c01027b6:	55                   	push   %ebp
c01027b7:	89 e5                	mov    %esp,%ebp
c01027b9:	57                   	push   %edi
c01027ba:	56                   	push   %esi
c01027bb:	53                   	push   %ebx
c01027bc:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    int ret=0;
c01027bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    switch (tf->tf_trapno) {
c01027c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01027c9:	8b 40 30             	mov    0x30(%eax),%eax
c01027cc:	83 f8 2f             	cmp    $0x2f,%eax
c01027cf:	77 38                	ja     c0102809 <trap_dispatch+0x53>
c01027d1:	83 f8 2e             	cmp    $0x2e,%eax
c01027d4:	0f 83 ee 02 00 00    	jae    c0102ac8 <trap_dispatch+0x312>
c01027da:	83 f8 20             	cmp    $0x20,%eax
c01027dd:	0f 84 07 01 00 00    	je     c01028ea <trap_dispatch+0x134>
c01027e3:	83 f8 20             	cmp    $0x20,%eax
c01027e6:	77 0a                	ja     c01027f2 <trap_dispatch+0x3c>
c01027e8:	83 f8 0e             	cmp    $0xe,%eax
c01027eb:	74 3e                	je     c010282b <trap_dispatch+0x75>
c01027ed:	e9 8e 02 00 00       	jmp    c0102a80 <trap_dispatch+0x2ca>
c01027f2:	83 f8 21             	cmp    $0x21,%eax
c01027f5:	0f 84 64 01 00 00    	je     c010295f <trap_dispatch+0x1a9>
c01027fb:	83 f8 24             	cmp    $0x24,%eax
c01027fe:	0f 84 32 01 00 00    	je     c0102936 <trap_dispatch+0x180>
c0102804:	e9 77 02 00 00       	jmp    c0102a80 <trap_dispatch+0x2ca>
c0102809:	83 f8 79             	cmp    $0x79,%eax
c010280c:	0f 84 f5 01 00 00    	je     c0102a07 <trap_dispatch+0x251>
c0102812:	3d 80 00 00 00       	cmp    $0x80,%eax
c0102817:	0f 84 c3 00 00 00    	je     c01028e0 <trap_dispatch+0x12a>
c010281d:	83 f8 78             	cmp    $0x78,%eax
c0102820:	0f 84 62 01 00 00    	je     c0102988 <trap_dispatch+0x1d2>
c0102826:	e9 55 02 00 00       	jmp    c0102a80 <trap_dispatch+0x2ca>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010282b:	8b 45 08             	mov    0x8(%ebp),%eax
c010282e:	89 04 24             	mov    %eax,(%esp)
c0102831:	e8 b4 fe ff ff       	call   c01026ea <pgfault_handler>
c0102836:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0102839:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010283d:	0f 84 98 00 00 00    	je     c01028db <trap_dispatch+0x125>
            print_trapframe(tf);
c0102843:	8b 45 08             	mov    0x8(%ebp),%eax
c0102846:	89 04 24             	mov    %eax,(%esp)
c0102849:	e8 a3 fb ff ff       	call   c01023f1 <print_trapframe>
            if (current == NULL) {
c010284e:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102853:	85 c0                	test   %eax,%eax
c0102855:	75 23                	jne    c010287a <trap_dispatch+0xc4>
                panic("handle pgfault failed. ret=%d\n", ret);
c0102857:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010285a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010285e:	c7 44 24 08 a8 cb 10 	movl   $0xc010cba8,0x8(%esp)
c0102865:	c0 
c0102866:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c010286d:	00 
c010286e:	c7 04 24 80 cb 10 c0 	movl   $0xc010cb80,(%esp)
c0102875:	e8 76 e5 ff ff       	call   c0100df0 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c010287a:	8b 45 08             	mov    0x8(%ebp),%eax
c010287d:	89 04 24             	mov    %eax,(%esp)
c0102880:	e8 56 fb ff ff       	call   c01023db <trap_in_kernel>
c0102885:	85 c0                	test   %eax,%eax
c0102887:	74 23                	je     c01028ac <trap_dispatch+0xf6>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c0102889:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010288c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102890:	c7 44 24 08 c8 cb 10 	movl   $0xc010cbc8,0x8(%esp)
c0102897:	c0 
c0102898:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010289f:	00 
c01028a0:	c7 04 24 80 cb 10 c0 	movl   $0xc010cb80,(%esp)
c01028a7:	e8 44 e5 ff ff       	call   c0100df0 <__panic>
                }
                cprintf("killed by kernel.\n");
c01028ac:	c7 04 24 f6 cb 10 c0 	movl   $0xc010cbf6,(%esp)
c01028b3:	e8 ac da ff ff       	call   c0100364 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c01028b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01028bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028bf:	c7 44 24 08 0c cc 10 	movl   $0xc010cc0c,0x8(%esp)
c01028c6:	c0 
c01028c7:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c01028ce:	00 
c01028cf:	c7 04 24 80 cb 10 c0 	movl   $0xc010cb80,(%esp)
c01028d6:	e8 15 e5 ff ff       	call   c0100df0 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
c01028db:	e9 e9 01 00 00       	jmp    c0102ac9 <trap_dispatch+0x313>
    case T_SYSCALL:
        syscall();
c01028e0:	e8 e7 8e 00 00       	call   c010b7cc <syscall>
        break;
c01028e5:	e9 df 01 00 00       	jmp    c0102ac9 <trap_dispatch+0x313>
        /* LAB6 YOUR CODE */
        /* you should upate you lab5 code
         * IMPORTANT FUNCTIONS:
	     * sched_class_proc_tick
         */
	ticks++;	
c01028ea:	a1 98 30 1b c0       	mov    0xc01b3098,%eax
c01028ef:	83 c0 01             	add    $0x1,%eax
c01028f2:	a3 98 30 1b c0       	mov    %eax,0xc01b3098
        assert(current != NULL);
c01028f7:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c01028fc:	85 c0                	test   %eax,%eax
c01028fe:	75 24                	jne    c0102924 <trap_dispatch+0x16e>
c0102900:	c7 44 24 0c 35 cc 10 	movl   $0xc010cc35,0xc(%esp)
c0102907:	c0 
c0102908:	c7 44 24 08 6b cb 10 	movl   $0xc010cb6b,0x8(%esp)
c010290f:	c0 
c0102910:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0102917:	00 
c0102918:	c7 04 24 80 cb 10 c0 	movl   $0xc010cb80,(%esp)
c010291f:	e8 cc e4 ff ff       	call   c0100df0 <__panic>
	sched_class_proc_tick(current);
c0102924:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102929:	89 04 24             	mov    %eax,(%esp)
c010292c:	e8 76 8b 00 00       	call   c010b4a7 <sched_class_proc_tick>
        break;
c0102931:	e9 93 01 00 00       	jmp    c0102ac9 <trap_dispatch+0x313>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102936:	e8 34 ee ff ff       	call   c010176f <cons_getc>
c010293b:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010293e:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0102942:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c0102946:	89 54 24 08          	mov    %edx,0x8(%esp)
c010294a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010294e:	c7 04 24 45 cc 10 c0 	movl   $0xc010cc45,(%esp)
c0102955:	e8 0a da ff ff       	call   c0100364 <cprintf>
        break;
c010295a:	e9 6a 01 00 00       	jmp    c0102ac9 <trap_dispatch+0x313>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c010295f:	e8 0b ee ff ff       	call   c010176f <cons_getc>
c0102964:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102967:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c010296b:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c010296f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102973:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102977:	c7 04 24 57 cc 10 c0 	movl   $0xc010cc57,(%esp)
c010297e:	e8 e1 d9 ff ff       	call   c0100364 <cprintf>
        break;
c0102983:	e9 41 01 00 00       	jmp    c0102ac9 <trap_dispatch+0x313>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
	if (tf->tf_cs != USER_CS) {
c0102988:	8b 45 08             	mov    0x8(%ebp),%eax
c010298b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010298f:	66 83 f8 1b          	cmp    $0x1b,%ax
c0102993:	74 6d                	je     c0102a02 <trap_dispatch+0x24c>
            switchk2u = *tf;
c0102995:	8b 45 08             	mov    0x8(%ebp),%eax
c0102998:	ba a0 30 1b c0       	mov    $0xc01b30a0,%edx
c010299d:	89 c3                	mov    %eax,%ebx
c010299f:	b8 13 00 00 00       	mov    $0x13,%eax
c01029a4:	89 d7                	mov    %edx,%edi
c01029a6:	89 de                	mov    %ebx,%esi
c01029a8:	89 c1                	mov    %eax,%ecx
c01029aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
c01029ac:	66 c7 05 dc 30 1b c0 	movw   $0x1b,0xc01b30dc
c01029b3:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c01029b5:	66 c7 05 e8 30 1b c0 	movw   $0x23,0xc01b30e8
c01029bc:	23 00 
c01029be:	0f b7 05 e8 30 1b c0 	movzwl 0xc01b30e8,%eax
c01029c5:	66 a3 c8 30 1b c0    	mov    %ax,0xc01b30c8
c01029cb:	0f b7 05 c8 30 1b c0 	movzwl 0xc01b30c8,%eax
c01029d2:	66 a3 cc 30 1b c0    	mov    %ax,0xc01b30cc
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c01029d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01029db:	83 c0 44             	add    $0x44,%eax
c01029de:	a3 e4 30 1b c0       	mov    %eax,0xc01b30e4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c01029e3:	a1 e0 30 1b c0       	mov    0xc01b30e0,%eax
c01029e8:	80 cc 30             	or     $0x30,%ah
c01029eb:	a3 e0 30 1b c0       	mov    %eax,0xc01b30e0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c01029f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f3:	8d 50 fc             	lea    -0x4(%eax),%edx
c01029f6:	b8 a0 30 1b c0       	mov    $0xc01b30a0,%eax
c01029fb:	89 02                	mov    %eax,(%edx)
        }
        break;
c01029fd:	e9 c7 00 00 00       	jmp    c0102ac9 <trap_dispatch+0x313>
c0102a02:	e9 c2 00 00 00       	jmp    c0102ac9 <trap_dispatch+0x313>
    case T_SWITCH_TOK:
	if (tf->tf_cs != KERNEL_CS) {
c0102a07:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102a0e:	66 83 f8 08          	cmp    $0x8,%ax
c0102a12:	74 6a                	je     c0102a7e <trap_dispatch+0x2c8>
            tf->tf_cs = KERNEL_CS;
c0102a14:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a17:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a20:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0102a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a29:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102a2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a30:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0102a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a37:	8b 40 40             	mov    0x40(%eax),%eax
c0102a3a:	80 e4 cf             	and    $0xcf,%ah
c0102a3d:	89 c2                	mov    %eax,%edx
c0102a3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a42:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0102a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a48:	8b 40 44             	mov    0x44(%eax),%eax
c0102a4b:	83 e8 44             	sub    $0x44,%eax
c0102a4e:	a3 ec 30 1b c0       	mov    %eax,0xc01b30ec
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102a53:	a1 ec 30 1b c0       	mov    0xc01b30ec,%eax
c0102a58:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0102a5f:	00 
c0102a60:	8b 55 08             	mov    0x8(%ebp),%edx
c0102a63:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102a67:	89 04 24             	mov    %eax,(%esp)
c0102a6a:	e8 11 99 00 00       	call   c010c380 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0102a6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a72:	8d 50 fc             	lea    -0x4(%eax),%edx
c0102a75:	a1 ec 30 1b c0       	mov    0xc01b30ec,%eax
c0102a7a:	89 02                	mov    %eax,(%edx)
        }
        break;
c0102a7c:	eb 4b                	jmp    c0102ac9 <trap_dispatch+0x313>
c0102a7e:	eb 49                	jmp    c0102ac9 <trap_dispatch+0x313>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c0102a80:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a83:	89 04 24             	mov    %eax,(%esp)
c0102a86:	e8 66 f9 ff ff       	call   c01023f1 <print_trapframe>
        if (current != NULL) {
c0102a8b:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102a90:	85 c0                	test   %eax,%eax
c0102a92:	74 18                	je     c0102aac <trap_dispatch+0x2f6>
            cprintf("unhandled trap.\n");
c0102a94:	c7 04 24 66 cc 10 c0 	movl   $0xc010cc66,(%esp)
c0102a9b:	e8 c4 d8 ff ff       	call   c0100364 <cprintf>
            do_exit(-E_KILLED);
c0102aa0:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102aa7:	e8 18 76 00 00       	call   c010a0c4 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c0102aac:	c7 44 24 08 77 cc 10 	movl   $0xc010cc77,0x8(%esp)
c0102ab3:	c0 
c0102ab4:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0102abb:	00 
c0102abc:	c7 04 24 80 cb 10 c0 	movl   $0xc010cb80,(%esp)
c0102ac3:	e8 28 e3 ff ff       	call   c0100df0 <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0102ac8:	90                   	nop
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");

    }
}
c0102ac9:	83 c4 2c             	add    $0x2c,%esp
c0102acc:	5b                   	pop    %ebx
c0102acd:	5e                   	pop    %esi
c0102ace:	5f                   	pop    %edi
c0102acf:	5d                   	pop    %ebp
c0102ad0:	c3                   	ret    

c0102ad1 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102ad1:	55                   	push   %ebp
c0102ad2:	89 e5                	mov    %esp,%ebp
c0102ad4:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c0102ad7:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102adc:	85 c0                	test   %eax,%eax
c0102ade:	75 0d                	jne    c0102aed <trap+0x1c>
        trap_dispatch(tf);
c0102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ae3:	89 04 24             	mov    %eax,(%esp)
c0102ae6:	e8 cb fc ff ff       	call   c01027b6 <trap_dispatch>
c0102aeb:	eb 6c                	jmp    c0102b59 <trap+0x88>
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c0102aed:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102af2:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102af8:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102afd:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b00:	89 50 3c             	mov    %edx,0x3c(%eax)
    
        bool in_kernel = trap_in_kernel(tf);
c0102b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b06:	89 04 24             	mov    %eax,(%esp)
c0102b09:	e8 cd f8 ff ff       	call   c01023db <trap_in_kernel>
c0102b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
        trap_dispatch(tf);
c0102b11:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b14:	89 04 24             	mov    %eax,(%esp)
c0102b17:	e8 9a fc ff ff       	call   c01027b6 <trap_dispatch>
    
        current->tf = otf;
c0102b1c:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102b21:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b24:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102b27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102b2b:	75 2c                	jne    c0102b59 <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102b2d:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102b32:	8b 40 44             	mov    0x44(%eax),%eax
c0102b35:	83 e0 01             	and    $0x1,%eax
c0102b38:	85 c0                	test   %eax,%eax
c0102b3a:	74 0c                	je     c0102b48 <trap+0x77>
                do_exit(-E_KILLED);
c0102b3c:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102b43:	e8 7c 75 00 00       	call   c010a0c4 <do_exit>
            }
            if (current->need_resched) {
c0102b48:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0102b4d:	8b 40 10             	mov    0x10(%eax),%eax
c0102b50:	85 c0                	test   %eax,%eax
c0102b52:	74 05                	je     c0102b59 <trap+0x88>
                schedule();
c0102b54:	e8 8c 8a 00 00       	call   c010b5e5 <schedule>
            }
        }
    }
}
c0102b59:	c9                   	leave  
c0102b5a:	c3                   	ret    

c0102b5b <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102b5b:	1e                   	push   %ds
    pushl %es
c0102b5c:	06                   	push   %es
    pushl %fs
c0102b5d:	0f a0                	push   %fs
    pushl %gs
c0102b5f:	0f a8                	push   %gs
    pushal
c0102b61:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102b62:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102b67:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102b69:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102b6b:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102b6c:	e8 60 ff ff ff       	call   c0102ad1 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102b71:	5c                   	pop    %esp

c0102b72 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102b72:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102b73:	0f a9                	pop    %gs
    popl %fs
c0102b75:	0f a1                	pop    %fs
    popl %es
c0102b77:	07                   	pop    %es
    popl %ds
c0102b78:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102b79:	83 c4 08             	add    $0x8,%esp
    iret
c0102b7c:	cf                   	iret   

c0102b7d <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102b7d:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102b81:	e9 ec ff ff ff       	jmp    c0102b72 <__trapret>

c0102b86 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102b86:	6a 00                	push   $0x0
  pushl $0
c0102b88:	6a 00                	push   $0x0
  jmp __alltraps
c0102b8a:	e9 cc ff ff ff       	jmp    c0102b5b <__alltraps>

c0102b8f <vector1>:
.globl vector1
vector1:
  pushl $0
c0102b8f:	6a 00                	push   $0x0
  pushl $1
c0102b91:	6a 01                	push   $0x1
  jmp __alltraps
c0102b93:	e9 c3 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102b98 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102b98:	6a 00                	push   $0x0
  pushl $2
c0102b9a:	6a 02                	push   $0x2
  jmp __alltraps
c0102b9c:	e9 ba ff ff ff       	jmp    c0102b5b <__alltraps>

c0102ba1 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102ba1:	6a 00                	push   $0x0
  pushl $3
c0102ba3:	6a 03                	push   $0x3
  jmp __alltraps
c0102ba5:	e9 b1 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102baa <vector4>:
.globl vector4
vector4:
  pushl $0
c0102baa:	6a 00                	push   $0x0
  pushl $4
c0102bac:	6a 04                	push   $0x4
  jmp __alltraps
c0102bae:	e9 a8 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bb3 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102bb3:	6a 00                	push   $0x0
  pushl $5
c0102bb5:	6a 05                	push   $0x5
  jmp __alltraps
c0102bb7:	e9 9f ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bbc <vector6>:
.globl vector6
vector6:
  pushl $0
c0102bbc:	6a 00                	push   $0x0
  pushl $6
c0102bbe:	6a 06                	push   $0x6
  jmp __alltraps
c0102bc0:	e9 96 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bc5 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102bc5:	6a 00                	push   $0x0
  pushl $7
c0102bc7:	6a 07                	push   $0x7
  jmp __alltraps
c0102bc9:	e9 8d ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bce <vector8>:
.globl vector8
vector8:
  pushl $8
c0102bce:	6a 08                	push   $0x8
  jmp __alltraps
c0102bd0:	e9 86 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bd5 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102bd5:	6a 00                	push   $0x0
  pushl $9
c0102bd7:	6a 09                	push   $0x9
  jmp __alltraps
c0102bd9:	e9 7d ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bde <vector10>:
.globl vector10
vector10:
  pushl $10
c0102bde:	6a 0a                	push   $0xa
  jmp __alltraps
c0102be0:	e9 76 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102be5 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102be5:	6a 0b                	push   $0xb
  jmp __alltraps
c0102be7:	e9 6f ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bec <vector12>:
.globl vector12
vector12:
  pushl $12
c0102bec:	6a 0c                	push   $0xc
  jmp __alltraps
c0102bee:	e9 68 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bf3 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102bf3:	6a 0d                	push   $0xd
  jmp __alltraps
c0102bf5:	e9 61 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102bfa <vector14>:
.globl vector14
vector14:
  pushl $14
c0102bfa:	6a 0e                	push   $0xe
  jmp __alltraps
c0102bfc:	e9 5a ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c01 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102c01:	6a 00                	push   $0x0
  pushl $15
c0102c03:	6a 0f                	push   $0xf
  jmp __alltraps
c0102c05:	e9 51 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c0a <vector16>:
.globl vector16
vector16:
  pushl $0
c0102c0a:	6a 00                	push   $0x0
  pushl $16
c0102c0c:	6a 10                	push   $0x10
  jmp __alltraps
c0102c0e:	e9 48 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c13 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102c13:	6a 11                	push   $0x11
  jmp __alltraps
c0102c15:	e9 41 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c1a <vector18>:
.globl vector18
vector18:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $18
c0102c1c:	6a 12                	push   $0x12
  jmp __alltraps
c0102c1e:	e9 38 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c23 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $19
c0102c25:	6a 13                	push   $0x13
  jmp __alltraps
c0102c27:	e9 2f ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c2c <vector20>:
.globl vector20
vector20:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $20
c0102c2e:	6a 14                	push   $0x14
  jmp __alltraps
c0102c30:	e9 26 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c35 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $21
c0102c37:	6a 15                	push   $0x15
  jmp __alltraps
c0102c39:	e9 1d ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c3e <vector22>:
.globl vector22
vector22:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $22
c0102c40:	6a 16                	push   $0x16
  jmp __alltraps
c0102c42:	e9 14 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c47 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $23
c0102c49:	6a 17                	push   $0x17
  jmp __alltraps
c0102c4b:	e9 0b ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c50 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $24
c0102c52:	6a 18                	push   $0x18
  jmp __alltraps
c0102c54:	e9 02 ff ff ff       	jmp    c0102b5b <__alltraps>

c0102c59 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $25
c0102c5b:	6a 19                	push   $0x19
  jmp __alltraps
c0102c5d:	e9 f9 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102c62 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $26
c0102c64:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102c66:	e9 f0 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102c6b <vector27>:
.globl vector27
vector27:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $27
c0102c6d:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102c6f:	e9 e7 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102c74 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $28
c0102c76:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102c78:	e9 de fe ff ff       	jmp    c0102b5b <__alltraps>

c0102c7d <vector29>:
.globl vector29
vector29:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $29
c0102c7f:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102c81:	e9 d5 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102c86 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $30
c0102c88:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102c8a:	e9 cc fe ff ff       	jmp    c0102b5b <__alltraps>

c0102c8f <vector31>:
.globl vector31
vector31:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $31
c0102c91:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102c93:	e9 c3 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102c98 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $32
c0102c9a:	6a 20                	push   $0x20
  jmp __alltraps
c0102c9c:	e9 ba fe ff ff       	jmp    c0102b5b <__alltraps>

c0102ca1 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $33
c0102ca3:	6a 21                	push   $0x21
  jmp __alltraps
c0102ca5:	e9 b1 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102caa <vector34>:
.globl vector34
vector34:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $34
c0102cac:	6a 22                	push   $0x22
  jmp __alltraps
c0102cae:	e9 a8 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102cb3 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $35
c0102cb5:	6a 23                	push   $0x23
  jmp __alltraps
c0102cb7:	e9 9f fe ff ff       	jmp    c0102b5b <__alltraps>

c0102cbc <vector36>:
.globl vector36
vector36:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $36
c0102cbe:	6a 24                	push   $0x24
  jmp __alltraps
c0102cc0:	e9 96 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102cc5 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $37
c0102cc7:	6a 25                	push   $0x25
  jmp __alltraps
c0102cc9:	e9 8d fe ff ff       	jmp    c0102b5b <__alltraps>

c0102cce <vector38>:
.globl vector38
vector38:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $38
c0102cd0:	6a 26                	push   $0x26
  jmp __alltraps
c0102cd2:	e9 84 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102cd7 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102cd7:	6a 00                	push   $0x0
  pushl $39
c0102cd9:	6a 27                	push   $0x27
  jmp __alltraps
c0102cdb:	e9 7b fe ff ff       	jmp    c0102b5b <__alltraps>

c0102ce0 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102ce0:	6a 00                	push   $0x0
  pushl $40
c0102ce2:	6a 28                	push   $0x28
  jmp __alltraps
c0102ce4:	e9 72 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102ce9 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $41
c0102ceb:	6a 29                	push   $0x29
  jmp __alltraps
c0102ced:	e9 69 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102cf2 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $42
c0102cf4:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102cf6:	e9 60 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102cfb <vector43>:
.globl vector43
vector43:
  pushl $0
c0102cfb:	6a 00                	push   $0x0
  pushl $43
c0102cfd:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102cff:	e9 57 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d04 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102d04:	6a 00                	push   $0x0
  pushl $44
c0102d06:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102d08:	e9 4e fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d0d <vector45>:
.globl vector45
vector45:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $45
c0102d0f:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102d11:	e9 45 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d16 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $46
c0102d18:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102d1a:	e9 3c fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d1f <vector47>:
.globl vector47
vector47:
  pushl $0
c0102d1f:	6a 00                	push   $0x0
  pushl $47
c0102d21:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102d23:	e9 33 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d28 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102d28:	6a 00                	push   $0x0
  pushl $48
c0102d2a:	6a 30                	push   $0x30
  jmp __alltraps
c0102d2c:	e9 2a fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d31 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $49
c0102d33:	6a 31                	push   $0x31
  jmp __alltraps
c0102d35:	e9 21 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d3a <vector50>:
.globl vector50
vector50:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $50
c0102d3c:	6a 32                	push   $0x32
  jmp __alltraps
c0102d3e:	e9 18 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d43 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102d43:	6a 00                	push   $0x0
  pushl $51
c0102d45:	6a 33                	push   $0x33
  jmp __alltraps
c0102d47:	e9 0f fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d4c <vector52>:
.globl vector52
vector52:
  pushl $0
c0102d4c:	6a 00                	push   $0x0
  pushl $52
c0102d4e:	6a 34                	push   $0x34
  jmp __alltraps
c0102d50:	e9 06 fe ff ff       	jmp    c0102b5b <__alltraps>

c0102d55 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $53
c0102d57:	6a 35                	push   $0x35
  jmp __alltraps
c0102d59:	e9 fd fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d5e <vector54>:
.globl vector54
vector54:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $54
c0102d60:	6a 36                	push   $0x36
  jmp __alltraps
c0102d62:	e9 f4 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d67 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102d67:	6a 00                	push   $0x0
  pushl $55
c0102d69:	6a 37                	push   $0x37
  jmp __alltraps
c0102d6b:	e9 eb fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d70 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102d70:	6a 00                	push   $0x0
  pushl $56
c0102d72:	6a 38                	push   $0x38
  jmp __alltraps
c0102d74:	e9 e2 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d79 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102d79:	6a 00                	push   $0x0
  pushl $57
c0102d7b:	6a 39                	push   $0x39
  jmp __alltraps
c0102d7d:	e9 d9 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d82 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $58
c0102d84:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102d86:	e9 d0 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d8b <vector59>:
.globl vector59
vector59:
  pushl $0
c0102d8b:	6a 00                	push   $0x0
  pushl $59
c0102d8d:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102d8f:	e9 c7 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d94 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102d94:	6a 00                	push   $0x0
  pushl $60
c0102d96:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102d98:	e9 be fd ff ff       	jmp    c0102b5b <__alltraps>

c0102d9d <vector61>:
.globl vector61
vector61:
  pushl $0
c0102d9d:	6a 00                	push   $0x0
  pushl $61
c0102d9f:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102da1:	e9 b5 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102da6 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $62
c0102da8:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102daa:	e9 ac fd ff ff       	jmp    c0102b5b <__alltraps>

c0102daf <vector63>:
.globl vector63
vector63:
  pushl $0
c0102daf:	6a 00                	push   $0x0
  pushl $63
c0102db1:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102db3:	e9 a3 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102db8 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102db8:	6a 00                	push   $0x0
  pushl $64
c0102dba:	6a 40                	push   $0x40
  jmp __alltraps
c0102dbc:	e9 9a fd ff ff       	jmp    c0102b5b <__alltraps>

c0102dc1 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $65
c0102dc3:	6a 41                	push   $0x41
  jmp __alltraps
c0102dc5:	e9 91 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102dca <vector66>:
.globl vector66
vector66:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $66
c0102dcc:	6a 42                	push   $0x42
  jmp __alltraps
c0102dce:	e9 88 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102dd3 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102dd3:	6a 00                	push   $0x0
  pushl $67
c0102dd5:	6a 43                	push   $0x43
  jmp __alltraps
c0102dd7:	e9 7f fd ff ff       	jmp    c0102b5b <__alltraps>

c0102ddc <vector68>:
.globl vector68
vector68:
  pushl $0
c0102ddc:	6a 00                	push   $0x0
  pushl $68
c0102dde:	6a 44                	push   $0x44
  jmp __alltraps
c0102de0:	e9 76 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102de5 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $69
c0102de7:	6a 45                	push   $0x45
  jmp __alltraps
c0102de9:	e9 6d fd ff ff       	jmp    c0102b5b <__alltraps>

c0102dee <vector70>:
.globl vector70
vector70:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $70
c0102df0:	6a 46                	push   $0x46
  jmp __alltraps
c0102df2:	e9 64 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102df7 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102df7:	6a 00                	push   $0x0
  pushl $71
c0102df9:	6a 47                	push   $0x47
  jmp __alltraps
c0102dfb:	e9 5b fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e00 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102e00:	6a 00                	push   $0x0
  pushl $72
c0102e02:	6a 48                	push   $0x48
  jmp __alltraps
c0102e04:	e9 52 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e09 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $73
c0102e0b:	6a 49                	push   $0x49
  jmp __alltraps
c0102e0d:	e9 49 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e12 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $74
c0102e14:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102e16:	e9 40 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e1b <vector75>:
.globl vector75
vector75:
  pushl $0
c0102e1b:	6a 00                	push   $0x0
  pushl $75
c0102e1d:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102e1f:	e9 37 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e24 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102e24:	6a 00                	push   $0x0
  pushl $76
c0102e26:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102e28:	e9 2e fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e2d <vector77>:
.globl vector77
vector77:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $77
c0102e2f:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102e31:	e9 25 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e36 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $78
c0102e38:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102e3a:	e9 1c fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e3f <vector79>:
.globl vector79
vector79:
  pushl $0
c0102e3f:	6a 00                	push   $0x0
  pushl $79
c0102e41:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102e43:	e9 13 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e48 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102e48:	6a 00                	push   $0x0
  pushl $80
c0102e4a:	6a 50                	push   $0x50
  jmp __alltraps
c0102e4c:	e9 0a fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e51 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $81
c0102e53:	6a 51                	push   $0x51
  jmp __alltraps
c0102e55:	e9 01 fd ff ff       	jmp    c0102b5b <__alltraps>

c0102e5a <vector82>:
.globl vector82
vector82:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $82
c0102e5c:	6a 52                	push   $0x52
  jmp __alltraps
c0102e5e:	e9 f8 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102e63 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102e63:	6a 00                	push   $0x0
  pushl $83
c0102e65:	6a 53                	push   $0x53
  jmp __alltraps
c0102e67:	e9 ef fc ff ff       	jmp    c0102b5b <__alltraps>

c0102e6c <vector84>:
.globl vector84
vector84:
  pushl $0
c0102e6c:	6a 00                	push   $0x0
  pushl $84
c0102e6e:	6a 54                	push   $0x54
  jmp __alltraps
c0102e70:	e9 e6 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102e75 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $85
c0102e77:	6a 55                	push   $0x55
  jmp __alltraps
c0102e79:	e9 dd fc ff ff       	jmp    c0102b5b <__alltraps>

c0102e7e <vector86>:
.globl vector86
vector86:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $86
c0102e80:	6a 56                	push   $0x56
  jmp __alltraps
c0102e82:	e9 d4 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102e87 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102e87:	6a 00                	push   $0x0
  pushl $87
c0102e89:	6a 57                	push   $0x57
  jmp __alltraps
c0102e8b:	e9 cb fc ff ff       	jmp    c0102b5b <__alltraps>

c0102e90 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102e90:	6a 00                	push   $0x0
  pushl $88
c0102e92:	6a 58                	push   $0x58
  jmp __alltraps
c0102e94:	e9 c2 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102e99 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $89
c0102e9b:	6a 59                	push   $0x59
  jmp __alltraps
c0102e9d:	e9 b9 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102ea2 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $90
c0102ea4:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102ea6:	e9 b0 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102eab <vector91>:
.globl vector91
vector91:
  pushl $0
c0102eab:	6a 00                	push   $0x0
  pushl $91
c0102ead:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102eaf:	e9 a7 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102eb4 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102eb4:	6a 00                	push   $0x0
  pushl $92
c0102eb6:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102eb8:	e9 9e fc ff ff       	jmp    c0102b5b <__alltraps>

c0102ebd <vector93>:
.globl vector93
vector93:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $93
c0102ebf:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102ec1:	e9 95 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102ec6 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102ec6:	6a 00                	push   $0x0
  pushl $94
c0102ec8:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102eca:	e9 8c fc ff ff       	jmp    c0102b5b <__alltraps>

c0102ecf <vector95>:
.globl vector95
vector95:
  pushl $0
c0102ecf:	6a 00                	push   $0x0
  pushl $95
c0102ed1:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102ed3:	e9 83 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102ed8 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102ed8:	6a 00                	push   $0x0
  pushl $96
c0102eda:	6a 60                	push   $0x60
  jmp __alltraps
c0102edc:	e9 7a fc ff ff       	jmp    c0102b5b <__alltraps>

c0102ee1 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $97
c0102ee3:	6a 61                	push   $0x61
  jmp __alltraps
c0102ee5:	e9 71 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102eea <vector98>:
.globl vector98
vector98:
  pushl $0
c0102eea:	6a 00                	push   $0x0
  pushl $98
c0102eec:	6a 62                	push   $0x62
  jmp __alltraps
c0102eee:	e9 68 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102ef3 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102ef3:	6a 00                	push   $0x0
  pushl $99
c0102ef5:	6a 63                	push   $0x63
  jmp __alltraps
c0102ef7:	e9 5f fc ff ff       	jmp    c0102b5b <__alltraps>

c0102efc <vector100>:
.globl vector100
vector100:
  pushl $0
c0102efc:	6a 00                	push   $0x0
  pushl $100
c0102efe:	6a 64                	push   $0x64
  jmp __alltraps
c0102f00:	e9 56 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f05 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $101
c0102f07:	6a 65                	push   $0x65
  jmp __alltraps
c0102f09:	e9 4d fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f0e <vector102>:
.globl vector102
vector102:
  pushl $0
c0102f0e:	6a 00                	push   $0x0
  pushl $102
c0102f10:	6a 66                	push   $0x66
  jmp __alltraps
c0102f12:	e9 44 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f17 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102f17:	6a 00                	push   $0x0
  pushl $103
c0102f19:	6a 67                	push   $0x67
  jmp __alltraps
c0102f1b:	e9 3b fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f20 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102f20:	6a 00                	push   $0x0
  pushl $104
c0102f22:	6a 68                	push   $0x68
  jmp __alltraps
c0102f24:	e9 32 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f29 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102f29:	6a 00                	push   $0x0
  pushl $105
c0102f2b:	6a 69                	push   $0x69
  jmp __alltraps
c0102f2d:	e9 29 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f32 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102f32:	6a 00                	push   $0x0
  pushl $106
c0102f34:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102f36:	e9 20 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f3b <vector107>:
.globl vector107
vector107:
  pushl $0
c0102f3b:	6a 00                	push   $0x0
  pushl $107
c0102f3d:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102f3f:	e9 17 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f44 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102f44:	6a 00                	push   $0x0
  pushl $108
c0102f46:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102f48:	e9 0e fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f4d <vector109>:
.globl vector109
vector109:
  pushl $0
c0102f4d:	6a 00                	push   $0x0
  pushl $109
c0102f4f:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102f51:	e9 05 fc ff ff       	jmp    c0102b5b <__alltraps>

c0102f56 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102f56:	6a 00                	push   $0x0
  pushl $110
c0102f58:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102f5a:	e9 fc fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f5f <vector111>:
.globl vector111
vector111:
  pushl $0
c0102f5f:	6a 00                	push   $0x0
  pushl $111
c0102f61:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102f63:	e9 f3 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f68 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102f68:	6a 00                	push   $0x0
  pushl $112
c0102f6a:	6a 70                	push   $0x70
  jmp __alltraps
c0102f6c:	e9 ea fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f71 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102f71:	6a 00                	push   $0x0
  pushl $113
c0102f73:	6a 71                	push   $0x71
  jmp __alltraps
c0102f75:	e9 e1 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f7a <vector114>:
.globl vector114
vector114:
  pushl $0
c0102f7a:	6a 00                	push   $0x0
  pushl $114
c0102f7c:	6a 72                	push   $0x72
  jmp __alltraps
c0102f7e:	e9 d8 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f83 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102f83:	6a 00                	push   $0x0
  pushl $115
c0102f85:	6a 73                	push   $0x73
  jmp __alltraps
c0102f87:	e9 cf fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f8c <vector116>:
.globl vector116
vector116:
  pushl $0
c0102f8c:	6a 00                	push   $0x0
  pushl $116
c0102f8e:	6a 74                	push   $0x74
  jmp __alltraps
c0102f90:	e9 c6 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f95 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102f95:	6a 00                	push   $0x0
  pushl $117
c0102f97:	6a 75                	push   $0x75
  jmp __alltraps
c0102f99:	e9 bd fb ff ff       	jmp    c0102b5b <__alltraps>

c0102f9e <vector118>:
.globl vector118
vector118:
  pushl $0
c0102f9e:	6a 00                	push   $0x0
  pushl $118
c0102fa0:	6a 76                	push   $0x76
  jmp __alltraps
c0102fa2:	e9 b4 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fa7 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102fa7:	6a 00                	push   $0x0
  pushl $119
c0102fa9:	6a 77                	push   $0x77
  jmp __alltraps
c0102fab:	e9 ab fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fb0 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102fb0:	6a 00                	push   $0x0
  pushl $120
c0102fb2:	6a 78                	push   $0x78
  jmp __alltraps
c0102fb4:	e9 a2 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fb9 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102fb9:	6a 00                	push   $0x0
  pushl $121
c0102fbb:	6a 79                	push   $0x79
  jmp __alltraps
c0102fbd:	e9 99 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fc2 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102fc2:	6a 00                	push   $0x0
  pushl $122
c0102fc4:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102fc6:	e9 90 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fcb <vector123>:
.globl vector123
vector123:
  pushl $0
c0102fcb:	6a 00                	push   $0x0
  pushl $123
c0102fcd:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102fcf:	e9 87 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fd4 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102fd4:	6a 00                	push   $0x0
  pushl $124
c0102fd6:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102fd8:	e9 7e fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fdd <vector125>:
.globl vector125
vector125:
  pushl $0
c0102fdd:	6a 00                	push   $0x0
  pushl $125
c0102fdf:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102fe1:	e9 75 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fe6 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102fe6:	6a 00                	push   $0x0
  pushl $126
c0102fe8:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102fea:	e9 6c fb ff ff       	jmp    c0102b5b <__alltraps>

c0102fef <vector127>:
.globl vector127
vector127:
  pushl $0
c0102fef:	6a 00                	push   $0x0
  pushl $127
c0102ff1:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102ff3:	e9 63 fb ff ff       	jmp    c0102b5b <__alltraps>

c0102ff8 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102ff8:	6a 00                	push   $0x0
  pushl $128
c0102ffa:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102fff:	e9 57 fb ff ff       	jmp    c0102b5b <__alltraps>

c0103004 <vector129>:
.globl vector129
vector129:
  pushl $0
c0103004:	6a 00                	push   $0x0
  pushl $129
c0103006:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010300b:	e9 4b fb ff ff       	jmp    c0102b5b <__alltraps>

c0103010 <vector130>:
.globl vector130
vector130:
  pushl $0
c0103010:	6a 00                	push   $0x0
  pushl $130
c0103012:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0103017:	e9 3f fb ff ff       	jmp    c0102b5b <__alltraps>

c010301c <vector131>:
.globl vector131
vector131:
  pushl $0
c010301c:	6a 00                	push   $0x0
  pushl $131
c010301e:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0103023:	e9 33 fb ff ff       	jmp    c0102b5b <__alltraps>

c0103028 <vector132>:
.globl vector132
vector132:
  pushl $0
c0103028:	6a 00                	push   $0x0
  pushl $132
c010302a:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010302f:	e9 27 fb ff ff       	jmp    c0102b5b <__alltraps>

c0103034 <vector133>:
.globl vector133
vector133:
  pushl $0
c0103034:	6a 00                	push   $0x0
  pushl $133
c0103036:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010303b:	e9 1b fb ff ff       	jmp    c0102b5b <__alltraps>

c0103040 <vector134>:
.globl vector134
vector134:
  pushl $0
c0103040:	6a 00                	push   $0x0
  pushl $134
c0103042:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0103047:	e9 0f fb ff ff       	jmp    c0102b5b <__alltraps>

c010304c <vector135>:
.globl vector135
vector135:
  pushl $0
c010304c:	6a 00                	push   $0x0
  pushl $135
c010304e:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0103053:	e9 03 fb ff ff       	jmp    c0102b5b <__alltraps>

c0103058 <vector136>:
.globl vector136
vector136:
  pushl $0
c0103058:	6a 00                	push   $0x0
  pushl $136
c010305a:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010305f:	e9 f7 fa ff ff       	jmp    c0102b5b <__alltraps>

c0103064 <vector137>:
.globl vector137
vector137:
  pushl $0
c0103064:	6a 00                	push   $0x0
  pushl $137
c0103066:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010306b:	e9 eb fa ff ff       	jmp    c0102b5b <__alltraps>

c0103070 <vector138>:
.globl vector138
vector138:
  pushl $0
c0103070:	6a 00                	push   $0x0
  pushl $138
c0103072:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0103077:	e9 df fa ff ff       	jmp    c0102b5b <__alltraps>

c010307c <vector139>:
.globl vector139
vector139:
  pushl $0
c010307c:	6a 00                	push   $0x0
  pushl $139
c010307e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0103083:	e9 d3 fa ff ff       	jmp    c0102b5b <__alltraps>

c0103088 <vector140>:
.globl vector140
vector140:
  pushl $0
c0103088:	6a 00                	push   $0x0
  pushl $140
c010308a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010308f:	e9 c7 fa ff ff       	jmp    c0102b5b <__alltraps>

c0103094 <vector141>:
.globl vector141
vector141:
  pushl $0
c0103094:	6a 00                	push   $0x0
  pushl $141
c0103096:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010309b:	e9 bb fa ff ff       	jmp    c0102b5b <__alltraps>

c01030a0 <vector142>:
.globl vector142
vector142:
  pushl $0
c01030a0:	6a 00                	push   $0x0
  pushl $142
c01030a2:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01030a7:	e9 af fa ff ff       	jmp    c0102b5b <__alltraps>

c01030ac <vector143>:
.globl vector143
vector143:
  pushl $0
c01030ac:	6a 00                	push   $0x0
  pushl $143
c01030ae:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01030b3:	e9 a3 fa ff ff       	jmp    c0102b5b <__alltraps>

c01030b8 <vector144>:
.globl vector144
vector144:
  pushl $0
c01030b8:	6a 00                	push   $0x0
  pushl $144
c01030ba:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01030bf:	e9 97 fa ff ff       	jmp    c0102b5b <__alltraps>

c01030c4 <vector145>:
.globl vector145
vector145:
  pushl $0
c01030c4:	6a 00                	push   $0x0
  pushl $145
c01030c6:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01030cb:	e9 8b fa ff ff       	jmp    c0102b5b <__alltraps>

c01030d0 <vector146>:
.globl vector146
vector146:
  pushl $0
c01030d0:	6a 00                	push   $0x0
  pushl $146
c01030d2:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01030d7:	e9 7f fa ff ff       	jmp    c0102b5b <__alltraps>

c01030dc <vector147>:
.globl vector147
vector147:
  pushl $0
c01030dc:	6a 00                	push   $0x0
  pushl $147
c01030de:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01030e3:	e9 73 fa ff ff       	jmp    c0102b5b <__alltraps>

c01030e8 <vector148>:
.globl vector148
vector148:
  pushl $0
c01030e8:	6a 00                	push   $0x0
  pushl $148
c01030ea:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01030ef:	e9 67 fa ff ff       	jmp    c0102b5b <__alltraps>

c01030f4 <vector149>:
.globl vector149
vector149:
  pushl $0
c01030f4:	6a 00                	push   $0x0
  pushl $149
c01030f6:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01030fb:	e9 5b fa ff ff       	jmp    c0102b5b <__alltraps>

c0103100 <vector150>:
.globl vector150
vector150:
  pushl $0
c0103100:	6a 00                	push   $0x0
  pushl $150
c0103102:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0103107:	e9 4f fa ff ff       	jmp    c0102b5b <__alltraps>

c010310c <vector151>:
.globl vector151
vector151:
  pushl $0
c010310c:	6a 00                	push   $0x0
  pushl $151
c010310e:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0103113:	e9 43 fa ff ff       	jmp    c0102b5b <__alltraps>

c0103118 <vector152>:
.globl vector152
vector152:
  pushl $0
c0103118:	6a 00                	push   $0x0
  pushl $152
c010311a:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010311f:	e9 37 fa ff ff       	jmp    c0102b5b <__alltraps>

c0103124 <vector153>:
.globl vector153
vector153:
  pushl $0
c0103124:	6a 00                	push   $0x0
  pushl $153
c0103126:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010312b:	e9 2b fa ff ff       	jmp    c0102b5b <__alltraps>

c0103130 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103130:	6a 00                	push   $0x0
  pushl $154
c0103132:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0103137:	e9 1f fa ff ff       	jmp    c0102b5b <__alltraps>

c010313c <vector155>:
.globl vector155
vector155:
  pushl $0
c010313c:	6a 00                	push   $0x0
  pushl $155
c010313e:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103143:	e9 13 fa ff ff       	jmp    c0102b5b <__alltraps>

c0103148 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103148:	6a 00                	push   $0x0
  pushl $156
c010314a:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010314f:	e9 07 fa ff ff       	jmp    c0102b5b <__alltraps>

c0103154 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103154:	6a 00                	push   $0x0
  pushl $157
c0103156:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010315b:	e9 fb f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103160 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103160:	6a 00                	push   $0x0
  pushl $158
c0103162:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103167:	e9 ef f9 ff ff       	jmp    c0102b5b <__alltraps>

c010316c <vector159>:
.globl vector159
vector159:
  pushl $0
c010316c:	6a 00                	push   $0x0
  pushl $159
c010316e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0103173:	e9 e3 f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103178 <vector160>:
.globl vector160
vector160:
  pushl $0
c0103178:	6a 00                	push   $0x0
  pushl $160
c010317a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010317f:	e9 d7 f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103184 <vector161>:
.globl vector161
vector161:
  pushl $0
c0103184:	6a 00                	push   $0x0
  pushl $161
c0103186:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010318b:	e9 cb f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103190 <vector162>:
.globl vector162
vector162:
  pushl $0
c0103190:	6a 00                	push   $0x0
  pushl $162
c0103192:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0103197:	e9 bf f9 ff ff       	jmp    c0102b5b <__alltraps>

c010319c <vector163>:
.globl vector163
vector163:
  pushl $0
c010319c:	6a 00                	push   $0x0
  pushl $163
c010319e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01031a3:	e9 b3 f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031a8 <vector164>:
.globl vector164
vector164:
  pushl $0
c01031a8:	6a 00                	push   $0x0
  pushl $164
c01031aa:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01031af:	e9 a7 f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031b4 <vector165>:
.globl vector165
vector165:
  pushl $0
c01031b4:	6a 00                	push   $0x0
  pushl $165
c01031b6:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01031bb:	e9 9b f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031c0 <vector166>:
.globl vector166
vector166:
  pushl $0
c01031c0:	6a 00                	push   $0x0
  pushl $166
c01031c2:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01031c7:	e9 8f f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031cc <vector167>:
.globl vector167
vector167:
  pushl $0
c01031cc:	6a 00                	push   $0x0
  pushl $167
c01031ce:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01031d3:	e9 83 f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031d8 <vector168>:
.globl vector168
vector168:
  pushl $0
c01031d8:	6a 00                	push   $0x0
  pushl $168
c01031da:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01031df:	e9 77 f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031e4 <vector169>:
.globl vector169
vector169:
  pushl $0
c01031e4:	6a 00                	push   $0x0
  pushl $169
c01031e6:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01031eb:	e9 6b f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031f0 <vector170>:
.globl vector170
vector170:
  pushl $0
c01031f0:	6a 00                	push   $0x0
  pushl $170
c01031f2:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01031f7:	e9 5f f9 ff ff       	jmp    c0102b5b <__alltraps>

c01031fc <vector171>:
.globl vector171
vector171:
  pushl $0
c01031fc:	6a 00                	push   $0x0
  pushl $171
c01031fe:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0103203:	e9 53 f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103208 <vector172>:
.globl vector172
vector172:
  pushl $0
c0103208:	6a 00                	push   $0x0
  pushl $172
c010320a:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010320f:	e9 47 f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103214 <vector173>:
.globl vector173
vector173:
  pushl $0
c0103214:	6a 00                	push   $0x0
  pushl $173
c0103216:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010321b:	e9 3b f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103220 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103220:	6a 00                	push   $0x0
  pushl $174
c0103222:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0103227:	e9 2f f9 ff ff       	jmp    c0102b5b <__alltraps>

c010322c <vector175>:
.globl vector175
vector175:
  pushl $0
c010322c:	6a 00                	push   $0x0
  pushl $175
c010322e:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103233:	e9 23 f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103238 <vector176>:
.globl vector176
vector176:
  pushl $0
c0103238:	6a 00                	push   $0x0
  pushl $176
c010323a:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010323f:	e9 17 f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103244 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103244:	6a 00                	push   $0x0
  pushl $177
c0103246:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010324b:	e9 0b f9 ff ff       	jmp    c0102b5b <__alltraps>

c0103250 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103250:	6a 00                	push   $0x0
  pushl $178
c0103252:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103257:	e9 ff f8 ff ff       	jmp    c0102b5b <__alltraps>

c010325c <vector179>:
.globl vector179
vector179:
  pushl $0
c010325c:	6a 00                	push   $0x0
  pushl $179
c010325e:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103263:	e9 f3 f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103268 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103268:	6a 00                	push   $0x0
  pushl $180
c010326a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010326f:	e9 e7 f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103274 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103274:	6a 00                	push   $0x0
  pushl $181
c0103276:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010327b:	e9 db f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103280 <vector182>:
.globl vector182
vector182:
  pushl $0
c0103280:	6a 00                	push   $0x0
  pushl $182
c0103282:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0103287:	e9 cf f8 ff ff       	jmp    c0102b5b <__alltraps>

c010328c <vector183>:
.globl vector183
vector183:
  pushl $0
c010328c:	6a 00                	push   $0x0
  pushl $183
c010328e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0103293:	e9 c3 f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103298 <vector184>:
.globl vector184
vector184:
  pushl $0
c0103298:	6a 00                	push   $0x0
  pushl $184
c010329a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010329f:	e9 b7 f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032a4 <vector185>:
.globl vector185
vector185:
  pushl $0
c01032a4:	6a 00                	push   $0x0
  pushl $185
c01032a6:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01032ab:	e9 ab f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032b0 <vector186>:
.globl vector186
vector186:
  pushl $0
c01032b0:	6a 00                	push   $0x0
  pushl $186
c01032b2:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01032b7:	e9 9f f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032bc <vector187>:
.globl vector187
vector187:
  pushl $0
c01032bc:	6a 00                	push   $0x0
  pushl $187
c01032be:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01032c3:	e9 93 f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032c8 <vector188>:
.globl vector188
vector188:
  pushl $0
c01032c8:	6a 00                	push   $0x0
  pushl $188
c01032ca:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01032cf:	e9 87 f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032d4 <vector189>:
.globl vector189
vector189:
  pushl $0
c01032d4:	6a 00                	push   $0x0
  pushl $189
c01032d6:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01032db:	e9 7b f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032e0 <vector190>:
.globl vector190
vector190:
  pushl $0
c01032e0:	6a 00                	push   $0x0
  pushl $190
c01032e2:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01032e7:	e9 6f f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032ec <vector191>:
.globl vector191
vector191:
  pushl $0
c01032ec:	6a 00                	push   $0x0
  pushl $191
c01032ee:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01032f3:	e9 63 f8 ff ff       	jmp    c0102b5b <__alltraps>

c01032f8 <vector192>:
.globl vector192
vector192:
  pushl $0
c01032f8:	6a 00                	push   $0x0
  pushl $192
c01032fa:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01032ff:	e9 57 f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103304 <vector193>:
.globl vector193
vector193:
  pushl $0
c0103304:	6a 00                	push   $0x0
  pushl $193
c0103306:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010330b:	e9 4b f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103310 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103310:	6a 00                	push   $0x0
  pushl $194
c0103312:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0103317:	e9 3f f8 ff ff       	jmp    c0102b5b <__alltraps>

c010331c <vector195>:
.globl vector195
vector195:
  pushl $0
c010331c:	6a 00                	push   $0x0
  pushl $195
c010331e:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103323:	e9 33 f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103328 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103328:	6a 00                	push   $0x0
  pushl $196
c010332a:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010332f:	e9 27 f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103334 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103334:	6a 00                	push   $0x0
  pushl $197
c0103336:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010333b:	e9 1b f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103340 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103340:	6a 00                	push   $0x0
  pushl $198
c0103342:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103347:	e9 0f f8 ff ff       	jmp    c0102b5b <__alltraps>

c010334c <vector199>:
.globl vector199
vector199:
  pushl $0
c010334c:	6a 00                	push   $0x0
  pushl $199
c010334e:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103353:	e9 03 f8 ff ff       	jmp    c0102b5b <__alltraps>

c0103358 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103358:	6a 00                	push   $0x0
  pushl $200
c010335a:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010335f:	e9 f7 f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103364 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103364:	6a 00                	push   $0x0
  pushl $201
c0103366:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010336b:	e9 eb f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103370 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103370:	6a 00                	push   $0x0
  pushl $202
c0103372:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103377:	e9 df f7 ff ff       	jmp    c0102b5b <__alltraps>

c010337c <vector203>:
.globl vector203
vector203:
  pushl $0
c010337c:	6a 00                	push   $0x0
  pushl $203
c010337e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103383:	e9 d3 f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103388 <vector204>:
.globl vector204
vector204:
  pushl $0
c0103388:	6a 00                	push   $0x0
  pushl $204
c010338a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010338f:	e9 c7 f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103394 <vector205>:
.globl vector205
vector205:
  pushl $0
c0103394:	6a 00                	push   $0x0
  pushl $205
c0103396:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010339b:	e9 bb f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033a0 <vector206>:
.globl vector206
vector206:
  pushl $0
c01033a0:	6a 00                	push   $0x0
  pushl $206
c01033a2:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01033a7:	e9 af f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033ac <vector207>:
.globl vector207
vector207:
  pushl $0
c01033ac:	6a 00                	push   $0x0
  pushl $207
c01033ae:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01033b3:	e9 a3 f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033b8 <vector208>:
.globl vector208
vector208:
  pushl $0
c01033b8:	6a 00                	push   $0x0
  pushl $208
c01033ba:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01033bf:	e9 97 f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033c4 <vector209>:
.globl vector209
vector209:
  pushl $0
c01033c4:	6a 00                	push   $0x0
  pushl $209
c01033c6:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01033cb:	e9 8b f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033d0 <vector210>:
.globl vector210
vector210:
  pushl $0
c01033d0:	6a 00                	push   $0x0
  pushl $210
c01033d2:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01033d7:	e9 7f f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033dc <vector211>:
.globl vector211
vector211:
  pushl $0
c01033dc:	6a 00                	push   $0x0
  pushl $211
c01033de:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01033e3:	e9 73 f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033e8 <vector212>:
.globl vector212
vector212:
  pushl $0
c01033e8:	6a 00                	push   $0x0
  pushl $212
c01033ea:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01033ef:	e9 67 f7 ff ff       	jmp    c0102b5b <__alltraps>

c01033f4 <vector213>:
.globl vector213
vector213:
  pushl $0
c01033f4:	6a 00                	push   $0x0
  pushl $213
c01033f6:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01033fb:	e9 5b f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103400 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103400:	6a 00                	push   $0x0
  pushl $214
c0103402:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103407:	e9 4f f7 ff ff       	jmp    c0102b5b <__alltraps>

c010340c <vector215>:
.globl vector215
vector215:
  pushl $0
c010340c:	6a 00                	push   $0x0
  pushl $215
c010340e:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103413:	e9 43 f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103418 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103418:	6a 00                	push   $0x0
  pushl $216
c010341a:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010341f:	e9 37 f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103424 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103424:	6a 00                	push   $0x0
  pushl $217
c0103426:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010342b:	e9 2b f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103430 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103430:	6a 00                	push   $0x0
  pushl $218
c0103432:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103437:	e9 1f f7 ff ff       	jmp    c0102b5b <__alltraps>

c010343c <vector219>:
.globl vector219
vector219:
  pushl $0
c010343c:	6a 00                	push   $0x0
  pushl $219
c010343e:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103443:	e9 13 f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103448 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103448:	6a 00                	push   $0x0
  pushl $220
c010344a:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010344f:	e9 07 f7 ff ff       	jmp    c0102b5b <__alltraps>

c0103454 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103454:	6a 00                	push   $0x0
  pushl $221
c0103456:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010345b:	e9 fb f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103460 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103460:	6a 00                	push   $0x0
  pushl $222
c0103462:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103467:	e9 ef f6 ff ff       	jmp    c0102b5b <__alltraps>

c010346c <vector223>:
.globl vector223
vector223:
  pushl $0
c010346c:	6a 00                	push   $0x0
  pushl $223
c010346e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103473:	e9 e3 f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103478 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103478:	6a 00                	push   $0x0
  pushl $224
c010347a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010347f:	e9 d7 f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103484 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103484:	6a 00                	push   $0x0
  pushl $225
c0103486:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010348b:	e9 cb f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103490 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103490:	6a 00                	push   $0x0
  pushl $226
c0103492:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103497:	e9 bf f6 ff ff       	jmp    c0102b5b <__alltraps>

c010349c <vector227>:
.globl vector227
vector227:
  pushl $0
c010349c:	6a 00                	push   $0x0
  pushl $227
c010349e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01034a3:	e9 b3 f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034a8 <vector228>:
.globl vector228
vector228:
  pushl $0
c01034a8:	6a 00                	push   $0x0
  pushl $228
c01034aa:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01034af:	e9 a7 f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034b4 <vector229>:
.globl vector229
vector229:
  pushl $0
c01034b4:	6a 00                	push   $0x0
  pushl $229
c01034b6:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01034bb:	e9 9b f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034c0 <vector230>:
.globl vector230
vector230:
  pushl $0
c01034c0:	6a 00                	push   $0x0
  pushl $230
c01034c2:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01034c7:	e9 8f f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034cc <vector231>:
.globl vector231
vector231:
  pushl $0
c01034cc:	6a 00                	push   $0x0
  pushl $231
c01034ce:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01034d3:	e9 83 f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034d8 <vector232>:
.globl vector232
vector232:
  pushl $0
c01034d8:	6a 00                	push   $0x0
  pushl $232
c01034da:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01034df:	e9 77 f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034e4 <vector233>:
.globl vector233
vector233:
  pushl $0
c01034e4:	6a 00                	push   $0x0
  pushl $233
c01034e6:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01034eb:	e9 6b f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034f0 <vector234>:
.globl vector234
vector234:
  pushl $0
c01034f0:	6a 00                	push   $0x0
  pushl $234
c01034f2:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01034f7:	e9 5f f6 ff ff       	jmp    c0102b5b <__alltraps>

c01034fc <vector235>:
.globl vector235
vector235:
  pushl $0
c01034fc:	6a 00                	push   $0x0
  pushl $235
c01034fe:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103503:	e9 53 f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103508 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103508:	6a 00                	push   $0x0
  pushl $236
c010350a:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010350f:	e9 47 f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103514 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103514:	6a 00                	push   $0x0
  pushl $237
c0103516:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010351b:	e9 3b f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103520 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103520:	6a 00                	push   $0x0
  pushl $238
c0103522:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103527:	e9 2f f6 ff ff       	jmp    c0102b5b <__alltraps>

c010352c <vector239>:
.globl vector239
vector239:
  pushl $0
c010352c:	6a 00                	push   $0x0
  pushl $239
c010352e:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103533:	e9 23 f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103538 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103538:	6a 00                	push   $0x0
  pushl $240
c010353a:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010353f:	e9 17 f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103544 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103544:	6a 00                	push   $0x0
  pushl $241
c0103546:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010354b:	e9 0b f6 ff ff       	jmp    c0102b5b <__alltraps>

c0103550 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103550:	6a 00                	push   $0x0
  pushl $242
c0103552:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103557:	e9 ff f5 ff ff       	jmp    c0102b5b <__alltraps>

c010355c <vector243>:
.globl vector243
vector243:
  pushl $0
c010355c:	6a 00                	push   $0x0
  pushl $243
c010355e:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103563:	e9 f3 f5 ff ff       	jmp    c0102b5b <__alltraps>

c0103568 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103568:	6a 00                	push   $0x0
  pushl $244
c010356a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010356f:	e9 e7 f5 ff ff       	jmp    c0102b5b <__alltraps>

c0103574 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103574:	6a 00                	push   $0x0
  pushl $245
c0103576:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010357b:	e9 db f5 ff ff       	jmp    c0102b5b <__alltraps>

c0103580 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103580:	6a 00                	push   $0x0
  pushl $246
c0103582:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103587:	e9 cf f5 ff ff       	jmp    c0102b5b <__alltraps>

c010358c <vector247>:
.globl vector247
vector247:
  pushl $0
c010358c:	6a 00                	push   $0x0
  pushl $247
c010358e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103593:	e9 c3 f5 ff ff       	jmp    c0102b5b <__alltraps>

c0103598 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103598:	6a 00                	push   $0x0
  pushl $248
c010359a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010359f:	e9 b7 f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035a4 <vector249>:
.globl vector249
vector249:
  pushl $0
c01035a4:	6a 00                	push   $0x0
  pushl $249
c01035a6:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01035ab:	e9 ab f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035b0 <vector250>:
.globl vector250
vector250:
  pushl $0
c01035b0:	6a 00                	push   $0x0
  pushl $250
c01035b2:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01035b7:	e9 9f f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035bc <vector251>:
.globl vector251
vector251:
  pushl $0
c01035bc:	6a 00                	push   $0x0
  pushl $251
c01035be:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01035c3:	e9 93 f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035c8 <vector252>:
.globl vector252
vector252:
  pushl $0
c01035c8:	6a 00                	push   $0x0
  pushl $252
c01035ca:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01035cf:	e9 87 f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035d4 <vector253>:
.globl vector253
vector253:
  pushl $0
c01035d4:	6a 00                	push   $0x0
  pushl $253
c01035d6:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01035db:	e9 7b f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035e0 <vector254>:
.globl vector254
vector254:
  pushl $0
c01035e0:	6a 00                	push   $0x0
  pushl $254
c01035e2:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01035e7:	e9 6f f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035ec <vector255>:
.globl vector255
vector255:
  pushl $0
c01035ec:	6a 00                	push   $0x0
  pushl $255
c01035ee:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01035f3:	e9 63 f5 ff ff       	jmp    c0102b5b <__alltraps>

c01035f8 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01035f8:	55                   	push   %ebp
c01035f9:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01035fb:	8b 55 08             	mov    0x8(%ebp),%edx
c01035fe:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0103603:	29 c2                	sub    %eax,%edx
c0103605:	89 d0                	mov    %edx,%eax
c0103607:	c1 f8 05             	sar    $0x5,%eax
}
c010360a:	5d                   	pop    %ebp
c010360b:	c3                   	ret    

c010360c <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010360c:	55                   	push   %ebp
c010360d:	89 e5                	mov    %esp,%ebp
c010360f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103612:	8b 45 08             	mov    0x8(%ebp),%eax
c0103615:	89 04 24             	mov    %eax,(%esp)
c0103618:	e8 db ff ff ff       	call   c01035f8 <page2ppn>
c010361d:	c1 e0 0c             	shl    $0xc,%eax
}
c0103620:	c9                   	leave  
c0103621:	c3                   	ret    

c0103622 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103622:	55                   	push   %ebp
c0103623:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103625:	8b 45 08             	mov    0x8(%ebp),%eax
c0103628:	8b 00                	mov    (%eax),%eax
}
c010362a:	5d                   	pop    %ebp
c010362b:	c3                   	ret    

c010362c <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010362c:	55                   	push   %ebp
c010362d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010362f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103632:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103635:	89 10                	mov    %edx,(%eax)
}
c0103637:	5d                   	pop    %ebp
c0103638:	c3                   	ret    

c0103639 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103639:	55                   	push   %ebp
c010363a:	89 e5                	mov    %esp,%ebp
c010363c:	83 ec 10             	sub    $0x10,%esp
c010363f:	c7 45 fc f0 30 1b c0 	movl   $0xc01b30f0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103646:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103649:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010364c:	89 50 04             	mov    %edx,0x4(%eax)
c010364f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103652:	8b 50 04             	mov    0x4(%eax),%edx
c0103655:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103658:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010365a:	c7 05 f8 30 1b c0 00 	movl   $0x0,0xc01b30f8
c0103661:	00 00 00 
}
c0103664:	c9                   	leave  
c0103665:	c3                   	ret    

c0103666 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103666:	55                   	push   %ebp
c0103667:	89 e5                	mov    %esp,%ebp
c0103669:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010366c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103670:	75 24                	jne    c0103696 <default_init_memmap+0x30>
c0103672:	c7 44 24 0c 30 ce 10 	movl   $0xc010ce30,0xc(%esp)
c0103679:	c0 
c010367a:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103681:	c0 
c0103682:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103689:	00 
c010368a:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103691:	e8 5a d7 ff ff       	call   c0100df0 <__panic>
    struct Page *p = base;
c0103696:	8b 45 08             	mov    0x8(%ebp),%eax
c0103699:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010369c:	eb 7d                	jmp    c010371b <default_init_memmap+0xb5>
        assert(PageReserved(p));
c010369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a1:	83 c0 04             	add    $0x4,%eax
c01036a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01036ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036b4:	0f a3 10             	bt     %edx,(%eax)
c01036b7:	19 c0                	sbb    %eax,%eax
c01036b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01036bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036c0:	0f 95 c0             	setne  %al
c01036c3:	0f b6 c0             	movzbl %al,%eax
c01036c6:	85 c0                	test   %eax,%eax
c01036c8:	75 24                	jne    c01036ee <default_init_memmap+0x88>
c01036ca:	c7 44 24 0c 61 ce 10 	movl   $0xc010ce61,0xc(%esp)
c01036d1:	c0 
c01036d2:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01036d9:	c0 
c01036da:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01036e1:	00 
c01036e2:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01036e9:	e8 02 d7 ff ff       	call   c0100df0 <__panic>
        p->flags = p->property = 0;
c01036ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01036f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036fb:	8b 50 08             	mov    0x8(%eax),%edx
c01036fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103701:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103704:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010370b:	00 
c010370c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010370f:	89 04 24             	mov    %eax,(%esp)
c0103712:	e8 15 ff ff ff       	call   c010362c <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103717:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010371b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010371e:	c1 e0 05             	shl    $0x5,%eax
c0103721:	89 c2                	mov    %eax,%edx
c0103723:	8b 45 08             	mov    0x8(%ebp),%eax
c0103726:	01 d0                	add    %edx,%eax
c0103728:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010372b:	0f 85 6d ff ff ff    	jne    c010369e <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103731:	8b 45 08             	mov    0x8(%ebp),%eax
c0103734:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103737:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010373a:	8b 45 08             	mov    0x8(%ebp),%eax
c010373d:	83 c0 04             	add    $0x4,%eax
c0103740:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0103747:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010374a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010374d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103750:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0103753:	8b 15 f8 30 1b c0    	mov    0xc01b30f8,%edx
c0103759:	8b 45 0c             	mov    0xc(%ebp),%eax
c010375c:	01 d0                	add    %edx,%eax
c010375e:	a3 f8 30 1b c0       	mov    %eax,0xc01b30f8
    list_add_before(&free_list, &(base->page_link));
c0103763:	8b 45 08             	mov    0x8(%ebp),%eax
c0103766:	83 c0 0c             	add    $0xc,%eax
c0103769:	c7 45 dc f0 30 1b c0 	movl   $0xc01b30f0,-0x24(%ebp)
c0103770:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103773:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103776:	8b 00                	mov    (%eax),%eax
c0103778:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010377b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010377e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103781:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103784:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103787:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010378a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010378d:	89 10                	mov    %edx,(%eax)
c010378f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103792:	8b 10                	mov    (%eax),%edx
c0103794:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103797:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010379a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010379d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01037a0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01037a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01037a6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01037a9:	89 10                	mov    %edx,(%eax)
}
c01037ab:	c9                   	leave  
c01037ac:	c3                   	ret    

c01037ad <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01037ad:	55                   	push   %ebp
c01037ae:	89 e5                	mov    %esp,%ebp
c01037b0:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01037b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01037b7:	75 24                	jne    c01037dd <default_alloc_pages+0x30>
c01037b9:	c7 44 24 0c 30 ce 10 	movl   $0xc010ce30,0xc(%esp)
c01037c0:	c0 
c01037c1:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01037c8:	c0 
c01037c9:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01037d0:	00 
c01037d1:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01037d8:	e8 13 d6 ff ff       	call   c0100df0 <__panic>
    if (n > nr_free) {
c01037dd:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c01037e2:	3b 45 08             	cmp    0x8(%ebp),%eax
c01037e5:	73 0a                	jae    c01037f1 <default_alloc_pages+0x44>
        return NULL;
c01037e7:	b8 00 00 00 00       	mov    $0x0,%eax
c01037ec:	e9 36 01 00 00       	jmp    c0103927 <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c01037f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01037f8:	c7 45 f0 f0 30 1b c0 	movl   $0xc01b30f0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01037ff:	eb 1c                	jmp    c010381d <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103801:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103804:	83 e8 0c             	sub    $0xc,%eax
c0103807:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010380a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010380d:	8b 40 08             	mov    0x8(%eax),%eax
c0103810:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103813:	72 08                	jb     c010381d <default_alloc_pages+0x70>
            page = p;
c0103815:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103818:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010381b:	eb 18                	jmp    c0103835 <default_alloc_pages+0x88>
c010381d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103823:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103826:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103829:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010382c:	81 7d f0 f0 30 1b c0 	cmpl   $0xc01b30f0,-0x10(%ebp)
c0103833:	75 cc                	jne    c0103801 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0103835:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103839:	0f 84 e5 00 00 00    	je     c0103924 <default_alloc_pages+0x177>
        if (page->property > n) {
c010383f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103842:	8b 40 08             	mov    0x8(%eax),%eax
c0103845:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103848:	0f 86 85 00 00 00    	jbe    c01038d3 <default_alloc_pages+0x126>
            struct Page *p = page + n;
c010384e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103851:	c1 e0 05             	shl    $0x5,%eax
c0103854:	89 c2                	mov    %eax,%edx
c0103856:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103859:	01 d0                	add    %edx,%eax
c010385b:	89 45 e8             	mov    %eax,-0x18(%ebp)
			SetPageProperty(p);
c010385e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103861:	83 c0 04             	add    $0x4,%eax
c0103864:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010386b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010386e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103871:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103874:	0f ab 10             	bts    %edx,(%eax)
            p->property = page->property - n;
c0103877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010387a:	8b 40 08             	mov    0x8(%eax),%eax
c010387d:	2b 45 08             	sub    0x8(%ebp),%eax
c0103880:	89 c2                	mov    %eax,%edx
c0103882:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103885:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0103888:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010388b:	83 c0 0c             	add    $0xc,%eax
c010388e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103891:	83 c2 0c             	add    $0xc,%edx
c0103894:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0103897:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010389a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010389d:	8b 40 04             	mov    0x4(%eax),%eax
c01038a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038a3:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01038a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038a9:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01038ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01038af:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038b2:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038b5:	89 10                	mov    %edx,(%eax)
c01038b7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038ba:	8b 10                	mov    (%eax),%edx
c01038bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038bf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01038c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038c5:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01038c8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01038cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038ce:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01038d1:	89 10                	mov    %edx,(%eax)
    }
	list_del(&(page->page_link));
c01038d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038d6:	83 c0 0c             	add    $0xc,%eax
c01038d9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01038dc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01038df:	8b 40 04             	mov    0x4(%eax),%eax
c01038e2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01038e5:	8b 12                	mov    (%edx),%edx
c01038e7:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01038ea:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01038ed:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01038f0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01038f3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01038f6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01038f9:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01038fc:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c01038fe:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c0103903:	2b 45 08             	sub    0x8(%ebp),%eax
c0103906:	a3 f8 30 1b c0       	mov    %eax,0xc01b30f8
        ClearPageProperty(page);
c010390b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010390e:	83 c0 04             	add    $0x4,%eax
c0103911:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103918:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010391b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010391e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103921:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0103924:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103927:	c9                   	leave  
c0103928:	c3                   	ret    

c0103929 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103929:	55                   	push   %ebp
c010392a:	89 e5                	mov    %esp,%ebp
c010392c:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0103932:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103936:	75 24                	jne    c010395c <default_free_pages+0x33>
c0103938:	c7 44 24 0c 30 ce 10 	movl   $0xc010ce30,0xc(%esp)
c010393f:	c0 
c0103940:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103947:	c0 
c0103948:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c010394f:	00 
c0103950:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103957:	e8 94 d4 ff ff       	call   c0100df0 <__panic>
    struct Page *p = base;
c010395c:	8b 45 08             	mov    0x8(%ebp),%eax
c010395f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103962:	e9 9d 00 00 00       	jmp    c0103a04 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0103967:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010396a:	83 c0 04             	add    $0x4,%eax
c010396d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0103974:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103977:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010397a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010397d:	0f a3 10             	bt     %edx,(%eax)
c0103980:	19 c0                	sbb    %eax,%eax
c0103982:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0103985:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103989:	0f 95 c0             	setne  %al
c010398c:	0f b6 c0             	movzbl %al,%eax
c010398f:	85 c0                	test   %eax,%eax
c0103991:	75 2c                	jne    c01039bf <default_free_pages+0x96>
c0103993:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103996:	83 c0 04             	add    $0x4,%eax
c0103999:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01039a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01039a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01039a9:	0f a3 10             	bt     %edx,(%eax)
c01039ac:	19 c0                	sbb    %eax,%eax
c01039ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01039b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01039b5:	0f 95 c0             	setne  %al
c01039b8:	0f b6 c0             	movzbl %al,%eax
c01039bb:	85 c0                	test   %eax,%eax
c01039bd:	74 24                	je     c01039e3 <default_free_pages+0xba>
c01039bf:	c7 44 24 0c 74 ce 10 	movl   $0xc010ce74,0xc(%esp)
c01039c6:	c0 
c01039c7:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01039ce:	c0 
c01039cf:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01039d6:	00 
c01039d7:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01039de:	e8 0d d4 ff ff       	call   c0100df0 <__panic>
        p->flags = 0;
c01039e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039e6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01039ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01039f4:	00 
c01039f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039f8:	89 04 24             	mov    %eax,(%esp)
c01039fb:	e8 2c fc ff ff       	call   c010362c <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103a00:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103a04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a07:	c1 e0 05             	shl    $0x5,%eax
c0103a0a:	89 c2                	mov    %eax,%edx
c0103a0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a0f:	01 d0                	add    %edx,%eax
c0103a11:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a14:	0f 85 4d ff ff ff    	jne    c0103967 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103a1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103a20:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103a23:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a26:	83 c0 04             	add    $0x4,%eax
c0103a29:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103a30:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a33:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103a36:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103a39:	0f ab 10             	bts    %edx,(%eax)
c0103a3c:	c7 45 cc f0 30 1b c0 	movl   $0xc01b30f0,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103a43:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a46:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0103a49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103a4c:	e9 fa 00 00 00       	jmp    c0103b4b <default_free_pages+0x222>
        p = le2page(le, page_link);
c0103a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a54:	83 e8 0c             	sub    $0xc,%eax
c0103a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a5d:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103a60:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103a63:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103a66:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0103a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a6c:	8b 40 08             	mov    0x8(%eax),%eax
c0103a6f:	c1 e0 05             	shl    $0x5,%eax
c0103a72:	89 c2                	mov    %eax,%edx
c0103a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a77:	01 d0                	add    %edx,%eax
c0103a79:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a7c:	75 5a                	jne    c0103ad8 <default_free_pages+0x1af>
            base->property += p->property;
c0103a7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a81:	8b 50 08             	mov    0x8(%eax),%edx
c0103a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a87:	8b 40 08             	mov    0x8(%eax),%eax
c0103a8a:	01 c2                	add    %eax,%edx
c0103a8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a8f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a95:	83 c0 04             	add    $0x4,%eax
c0103a98:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103a9f:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103aa2:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103aa5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103aa8:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0103aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aae:	83 c0 0c             	add    $0xc,%eax
c0103ab1:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103ab4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103ab7:	8b 40 04             	mov    0x4(%eax),%eax
c0103aba:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103abd:	8b 12                	mov    (%edx),%edx
c0103abf:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0103ac2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103ac5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103ac8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103acb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103ace:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103ad1:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103ad4:	89 10                	mov    %edx,(%eax)
c0103ad6:	eb 73                	jmp    c0103b4b <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c0103ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103adb:	8b 40 08             	mov    0x8(%eax),%eax
c0103ade:	c1 e0 05             	shl    $0x5,%eax
c0103ae1:	89 c2                	mov    %eax,%edx
c0103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae6:	01 d0                	add    %edx,%eax
c0103ae8:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103aeb:	75 5e                	jne    c0103b4b <default_free_pages+0x222>
            p->property += base->property;
c0103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103af0:	8b 50 08             	mov    0x8(%eax),%edx
c0103af3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103af6:	8b 40 08             	mov    0x8(%eax),%eax
c0103af9:	01 c2                	add    %eax,%edx
c0103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103afe:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103b01:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b04:	83 c0 04             	add    $0x4,%eax
c0103b07:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0103b0e:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103b11:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103b14:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103b17:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0103b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b1d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b23:	83 c0 0c             	add    $0xc,%eax
c0103b26:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103b29:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103b2c:	8b 40 04             	mov    0x4(%eax),%eax
c0103b2f:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103b32:	8b 12                	mov    (%edx),%edx
c0103b34:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0103b37:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103b3a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103b3d:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103b40:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b43:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103b46:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103b49:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0103b4b:	81 7d f0 f0 30 1b c0 	cmpl   $0xc01b30f0,-0x10(%ebp)
c0103b52:	0f 85 f9 fe ff ff    	jne    c0103a51 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0103b58:	8b 15 f8 30 1b c0    	mov    0xc01b30f8,%edx
c0103b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b61:	01 d0                	add    %edx,%eax
c0103b63:	a3 f8 30 1b c0       	mov    %eax,0xc01b30f8
c0103b68:	c7 45 9c f0 30 1b c0 	movl   $0xc01b30f0,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103b6f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103b72:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0103b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103b78:	eb 68                	jmp    c0103be2 <default_free_pages+0x2b9>
        p = le2page(le, page_link);
c0103b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b7d:	83 e8 0c             	sub    $0xc,%eax
c0103b80:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0103b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b86:	8b 40 08             	mov    0x8(%eax),%eax
c0103b89:	c1 e0 05             	shl    $0x5,%eax
c0103b8c:	89 c2                	mov    %eax,%edx
c0103b8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b91:	01 d0                	add    %edx,%eax
c0103b93:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b96:	77 3b                	ja     c0103bd3 <default_free_pages+0x2aa>
            assert(base + base->property != p);
c0103b98:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b9b:	8b 40 08             	mov    0x8(%eax),%eax
c0103b9e:	c1 e0 05             	shl    $0x5,%eax
c0103ba1:	89 c2                	mov    %eax,%edx
c0103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba6:	01 d0                	add    %edx,%eax
c0103ba8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103bab:	75 24                	jne    c0103bd1 <default_free_pages+0x2a8>
c0103bad:	c7 44 24 0c 99 ce 10 	movl   $0xc010ce99,0xc(%esp)
c0103bb4:	c0 
c0103bb5:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103bbc:	c0 
c0103bbd:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0103bc4:	00 
c0103bc5:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103bcc:	e8 1f d2 ff ff       	call   c0100df0 <__panic>
            break;
c0103bd1:	eb 18                	jmp    c0103beb <default_free_pages+0x2c2>
c0103bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bd6:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103bd9:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103bdc:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0103bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0103be2:	81 7d f0 f0 30 1b c0 	cmpl   $0xc01b30f0,-0x10(%ebp)
c0103be9:	75 8f                	jne    c0103b7a <default_free_pages+0x251>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0103beb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bee:	8d 50 0c             	lea    0xc(%eax),%edx
c0103bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bf4:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103bf7:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103bfa:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103bfd:	8b 00                	mov    (%eax),%eax
c0103bff:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103c02:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103c05:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103c08:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103c0b:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103c0e:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103c11:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103c14:	89 10                	mov    %edx,(%eax)
c0103c16:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103c19:	8b 10                	mov    (%eax),%edx
c0103c1b:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103c1e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103c21:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103c24:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103c27:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103c2a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103c2d:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103c30:	89 10                	mov    %edx,(%eax)
}
c0103c32:	c9                   	leave  
c0103c33:	c3                   	ret    

c0103c34 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103c34:	55                   	push   %ebp
c0103c35:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103c37:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
}
c0103c3c:	5d                   	pop    %ebp
c0103c3d:	c3                   	ret    

c0103c3e <basic_check>:

static void
basic_check(void) {
c0103c3e:	55                   	push   %ebp
c0103c3f:	89 e5                	mov    %esp,%ebp
c0103c41:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103c44:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c54:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103c57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c5e:	e8 dc 15 00 00       	call   c010523f <alloc_pages>
c0103c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c66:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103c6a:	75 24                	jne    c0103c90 <basic_check+0x52>
c0103c6c:	c7 44 24 0c b4 ce 10 	movl   $0xc010ceb4,0xc(%esp)
c0103c73:	c0 
c0103c74:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103c7b:	c0 
c0103c7c:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0103c83:	00 
c0103c84:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103c8b:	e8 60 d1 ff ff       	call   c0100df0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103c90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c97:	e8 a3 15 00 00       	call   c010523f <alloc_pages>
c0103c9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ca3:	75 24                	jne    c0103cc9 <basic_check+0x8b>
c0103ca5:	c7 44 24 0c d0 ce 10 	movl   $0xc010ced0,0xc(%esp)
c0103cac:	c0 
c0103cad:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103cb4:	c0 
c0103cb5:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103cbc:	00 
c0103cbd:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103cc4:	e8 27 d1 ff ff       	call   c0100df0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103cc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cd0:	e8 6a 15 00 00       	call   c010523f <alloc_pages>
c0103cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103cd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103cdc:	75 24                	jne    c0103d02 <basic_check+0xc4>
c0103cde:	c7 44 24 0c ec ce 10 	movl   $0xc010ceec,0xc(%esp)
c0103ce5:	c0 
c0103ce6:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103ced:	c0 
c0103cee:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0103cf5:	00 
c0103cf6:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103cfd:	e8 ee d0 ff ff       	call   c0100df0 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d05:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103d08:	74 10                	je     c0103d1a <basic_check+0xdc>
c0103d0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d10:	74 08                	je     c0103d1a <basic_check+0xdc>
c0103d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d15:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d18:	75 24                	jne    c0103d3e <basic_check+0x100>
c0103d1a:	c7 44 24 0c 08 cf 10 	movl   $0xc010cf08,0xc(%esp)
c0103d21:	c0 
c0103d22:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103d29:	c0 
c0103d2a:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103d31:	00 
c0103d32:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103d39:	e8 b2 d0 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d41:	89 04 24             	mov    %eax,(%esp)
c0103d44:	e8 d9 f8 ff ff       	call   c0103622 <page_ref>
c0103d49:	85 c0                	test   %eax,%eax
c0103d4b:	75 1e                	jne    c0103d6b <basic_check+0x12d>
c0103d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d50:	89 04 24             	mov    %eax,(%esp)
c0103d53:	e8 ca f8 ff ff       	call   c0103622 <page_ref>
c0103d58:	85 c0                	test   %eax,%eax
c0103d5a:	75 0f                	jne    c0103d6b <basic_check+0x12d>
c0103d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d5f:	89 04 24             	mov    %eax,(%esp)
c0103d62:	e8 bb f8 ff ff       	call   c0103622 <page_ref>
c0103d67:	85 c0                	test   %eax,%eax
c0103d69:	74 24                	je     c0103d8f <basic_check+0x151>
c0103d6b:	c7 44 24 0c 2c cf 10 	movl   $0xc010cf2c,0xc(%esp)
c0103d72:	c0 
c0103d73:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103d7a:	c0 
c0103d7b:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103d82:	00 
c0103d83:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103d8a:	e8 61 d0 ff ff       	call   c0100df0 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103d8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d92:	89 04 24             	mov    %eax,(%esp)
c0103d95:	e8 72 f8 ff ff       	call   c010360c <page2pa>
c0103d9a:	8b 15 a0 0f 1b c0    	mov    0xc01b0fa0,%edx
c0103da0:	c1 e2 0c             	shl    $0xc,%edx
c0103da3:	39 d0                	cmp    %edx,%eax
c0103da5:	72 24                	jb     c0103dcb <basic_check+0x18d>
c0103da7:	c7 44 24 0c 68 cf 10 	movl   $0xc010cf68,0xc(%esp)
c0103dae:	c0 
c0103daf:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103db6:	c0 
c0103db7:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103dbe:	00 
c0103dbf:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103dc6:	e8 25 d0 ff ff       	call   c0100df0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103dce:	89 04 24             	mov    %eax,(%esp)
c0103dd1:	e8 36 f8 ff ff       	call   c010360c <page2pa>
c0103dd6:	8b 15 a0 0f 1b c0    	mov    0xc01b0fa0,%edx
c0103ddc:	c1 e2 0c             	shl    $0xc,%edx
c0103ddf:	39 d0                	cmp    %edx,%eax
c0103de1:	72 24                	jb     c0103e07 <basic_check+0x1c9>
c0103de3:	c7 44 24 0c 85 cf 10 	movl   $0xc010cf85,0xc(%esp)
c0103dea:	c0 
c0103deb:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103df2:	c0 
c0103df3:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103dfa:	00 
c0103dfb:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103e02:	e8 e9 cf ff ff       	call   c0100df0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e0a:	89 04 24             	mov    %eax,(%esp)
c0103e0d:	e8 fa f7 ff ff       	call   c010360c <page2pa>
c0103e12:	8b 15 a0 0f 1b c0    	mov    0xc01b0fa0,%edx
c0103e18:	c1 e2 0c             	shl    $0xc,%edx
c0103e1b:	39 d0                	cmp    %edx,%eax
c0103e1d:	72 24                	jb     c0103e43 <basic_check+0x205>
c0103e1f:	c7 44 24 0c a2 cf 10 	movl   $0xc010cfa2,0xc(%esp)
c0103e26:	c0 
c0103e27:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103e2e:	c0 
c0103e2f:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103e36:	00 
c0103e37:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103e3e:	e8 ad cf ff ff       	call   c0100df0 <__panic>

    list_entry_t free_list_store = free_list;
c0103e43:	a1 f0 30 1b c0       	mov    0xc01b30f0,%eax
c0103e48:	8b 15 f4 30 1b c0    	mov    0xc01b30f4,%edx
c0103e4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103e51:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103e54:	c7 45 e0 f0 30 1b c0 	movl   $0xc01b30f0,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103e61:	89 50 04             	mov    %edx,0x4(%eax)
c0103e64:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e67:	8b 50 04             	mov    0x4(%eax),%edx
c0103e6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e6d:	89 10                	mov    %edx,(%eax)
c0103e6f:	c7 45 dc f0 30 1b c0 	movl   $0xc01b30f0,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103e76:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e79:	8b 40 04             	mov    0x4(%eax),%eax
c0103e7c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103e7f:	0f 94 c0             	sete   %al
c0103e82:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103e85:	85 c0                	test   %eax,%eax
c0103e87:	75 24                	jne    c0103ead <basic_check+0x26f>
c0103e89:	c7 44 24 0c bf cf 10 	movl   $0xc010cfbf,0xc(%esp)
c0103e90:	c0 
c0103e91:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103e98:	c0 
c0103e99:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103ea0:	00 
c0103ea1:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103ea8:	e8 43 cf ff ff       	call   c0100df0 <__panic>

    unsigned int nr_free_store = nr_free;
c0103ead:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c0103eb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103eb5:	c7 05 f8 30 1b c0 00 	movl   $0x0,0xc01b30f8
c0103ebc:	00 00 00 

    assert(alloc_page() == NULL);
c0103ebf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ec6:	e8 74 13 00 00       	call   c010523f <alloc_pages>
c0103ecb:	85 c0                	test   %eax,%eax
c0103ecd:	74 24                	je     c0103ef3 <basic_check+0x2b5>
c0103ecf:	c7 44 24 0c d6 cf 10 	movl   $0xc010cfd6,0xc(%esp)
c0103ed6:	c0 
c0103ed7:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103ede:	c0 
c0103edf:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103ee6:	00 
c0103ee7:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103eee:	e8 fd ce ff ff       	call   c0100df0 <__panic>

    free_page(p0);
c0103ef3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103efa:	00 
c0103efb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103efe:	89 04 24             	mov    %eax,(%esp)
c0103f01:	e8 a4 13 00 00       	call   c01052aa <free_pages>
    free_page(p1);
c0103f06:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f0d:	00 
c0103f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f11:	89 04 24             	mov    %eax,(%esp)
c0103f14:	e8 91 13 00 00       	call   c01052aa <free_pages>
    free_page(p2);
c0103f19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f20:	00 
c0103f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f24:	89 04 24             	mov    %eax,(%esp)
c0103f27:	e8 7e 13 00 00       	call   c01052aa <free_pages>
    assert(nr_free == 3);
c0103f2c:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c0103f31:	83 f8 03             	cmp    $0x3,%eax
c0103f34:	74 24                	je     c0103f5a <basic_check+0x31c>
c0103f36:	c7 44 24 0c eb cf 10 	movl   $0xc010cfeb,0xc(%esp)
c0103f3d:	c0 
c0103f3e:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103f45:	c0 
c0103f46:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103f4d:	00 
c0103f4e:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103f55:	e8 96 ce ff ff       	call   c0100df0 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103f5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f61:	e8 d9 12 00 00       	call   c010523f <alloc_pages>
c0103f66:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f69:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103f6d:	75 24                	jne    c0103f93 <basic_check+0x355>
c0103f6f:	c7 44 24 0c b4 ce 10 	movl   $0xc010ceb4,0xc(%esp)
c0103f76:	c0 
c0103f77:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103f7e:	c0 
c0103f7f:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103f86:	00 
c0103f87:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103f8e:	e8 5d ce ff ff       	call   c0100df0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103f93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f9a:	e8 a0 12 00 00       	call   c010523f <alloc_pages>
c0103f9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103fa6:	75 24                	jne    c0103fcc <basic_check+0x38e>
c0103fa8:	c7 44 24 0c d0 ce 10 	movl   $0xc010ced0,0xc(%esp)
c0103faf:	c0 
c0103fb0:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103fb7:	c0 
c0103fb8:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103fbf:	00 
c0103fc0:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0103fc7:	e8 24 ce ff ff       	call   c0100df0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103fcc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fd3:	e8 67 12 00 00       	call   c010523f <alloc_pages>
c0103fd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103fdb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103fdf:	75 24                	jne    c0104005 <basic_check+0x3c7>
c0103fe1:	c7 44 24 0c ec ce 10 	movl   $0xc010ceec,0xc(%esp)
c0103fe8:	c0 
c0103fe9:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0103ff0:	c0 
c0103ff1:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103ff8:	00 
c0103ff9:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104000:	e8 eb cd ff ff       	call   c0100df0 <__panic>

    assert(alloc_page() == NULL);
c0104005:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010400c:	e8 2e 12 00 00       	call   c010523f <alloc_pages>
c0104011:	85 c0                	test   %eax,%eax
c0104013:	74 24                	je     c0104039 <basic_check+0x3fb>
c0104015:	c7 44 24 0c d6 cf 10 	movl   $0xc010cfd6,0xc(%esp)
c010401c:	c0 
c010401d:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104024:	c0 
c0104025:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c010402c:	00 
c010402d:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104034:	e8 b7 cd ff ff       	call   c0100df0 <__panic>

    free_page(p0);
c0104039:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104040:	00 
c0104041:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104044:	89 04 24             	mov    %eax,(%esp)
c0104047:	e8 5e 12 00 00       	call   c01052aa <free_pages>
c010404c:	c7 45 d8 f0 30 1b c0 	movl   $0xc01b30f0,-0x28(%ebp)
c0104053:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104056:	8b 40 04             	mov    0x4(%eax),%eax
c0104059:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010405c:	0f 94 c0             	sete   %al
c010405f:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104062:	85 c0                	test   %eax,%eax
c0104064:	74 24                	je     c010408a <basic_check+0x44c>
c0104066:	c7 44 24 0c f8 cf 10 	movl   $0xc010cff8,0xc(%esp)
c010406d:	c0 
c010406e:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104075:	c0 
c0104076:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010407d:	00 
c010407e:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104085:	e8 66 cd ff ff       	call   c0100df0 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c010408a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104091:	e8 a9 11 00 00       	call   c010523f <alloc_pages>
c0104096:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104099:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010409c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010409f:	74 24                	je     c01040c5 <basic_check+0x487>
c01040a1:	c7 44 24 0c 10 d0 10 	movl   $0xc010d010,0xc(%esp)
c01040a8:	c0 
c01040a9:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01040b0:	c0 
c01040b1:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01040b8:	00 
c01040b9:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01040c0:	e8 2b cd ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c01040c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040cc:	e8 6e 11 00 00       	call   c010523f <alloc_pages>
c01040d1:	85 c0                	test   %eax,%eax
c01040d3:	74 24                	je     c01040f9 <basic_check+0x4bb>
c01040d5:	c7 44 24 0c d6 cf 10 	movl   $0xc010cfd6,0xc(%esp)
c01040dc:	c0 
c01040dd:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01040e4:	c0 
c01040e5:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01040ec:	00 
c01040ed:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01040f4:	e8 f7 cc ff ff       	call   c0100df0 <__panic>

    assert(nr_free == 0);
c01040f9:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c01040fe:	85 c0                	test   %eax,%eax
c0104100:	74 24                	je     c0104126 <basic_check+0x4e8>
c0104102:	c7 44 24 0c 29 d0 10 	movl   $0xc010d029,0xc(%esp)
c0104109:	c0 
c010410a:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104111:	c0 
c0104112:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0104119:	00 
c010411a:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104121:	e8 ca cc ff ff       	call   c0100df0 <__panic>
    free_list = free_list_store;
c0104126:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104129:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010412c:	a3 f0 30 1b c0       	mov    %eax,0xc01b30f0
c0104131:	89 15 f4 30 1b c0    	mov    %edx,0xc01b30f4
    nr_free = nr_free_store;
c0104137:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010413a:	a3 f8 30 1b c0       	mov    %eax,0xc01b30f8

    free_page(p);
c010413f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104146:	00 
c0104147:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010414a:	89 04 24             	mov    %eax,(%esp)
c010414d:	e8 58 11 00 00       	call   c01052aa <free_pages>
    free_page(p1);
c0104152:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104159:	00 
c010415a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010415d:	89 04 24             	mov    %eax,(%esp)
c0104160:	e8 45 11 00 00       	call   c01052aa <free_pages>
    free_page(p2);
c0104165:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010416c:	00 
c010416d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104170:	89 04 24             	mov    %eax,(%esp)
c0104173:	e8 32 11 00 00       	call   c01052aa <free_pages>
}
c0104178:	c9                   	leave  
c0104179:	c3                   	ret    

c010417a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010417a:	55                   	push   %ebp
c010417b:	89 e5                	mov    %esp,%ebp
c010417d:	53                   	push   %ebx
c010417e:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0104184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010418b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104192:	c7 45 ec f0 30 1b c0 	movl   $0xc01b30f0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104199:	eb 6b                	jmp    c0104206 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c010419b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010419e:	83 e8 0c             	sub    $0xc,%eax
c01041a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c01041a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041a7:	83 c0 04             	add    $0x4,%eax
c01041aa:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01041b1:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041b4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01041b7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01041ba:	0f a3 10             	bt     %edx,(%eax)
c01041bd:	19 c0                	sbb    %eax,%eax
c01041bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01041c2:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01041c6:	0f 95 c0             	setne  %al
c01041c9:	0f b6 c0             	movzbl %al,%eax
c01041cc:	85 c0                	test   %eax,%eax
c01041ce:	75 24                	jne    c01041f4 <default_check+0x7a>
c01041d0:	c7 44 24 0c 36 d0 10 	movl   $0xc010d036,0xc(%esp)
c01041d7:	c0 
c01041d8:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01041df:	c0 
c01041e0:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01041e7:	00 
c01041e8:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01041ef:	e8 fc cb ff ff       	call   c0100df0 <__panic>
        count ++, total += p->property;
c01041f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01041f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041fb:	8b 50 08             	mov    0x8(%eax),%edx
c01041fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104201:	01 d0                	add    %edx,%eax
c0104203:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104206:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104209:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010420c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010420f:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104212:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104215:	81 7d ec f0 30 1b c0 	cmpl   $0xc01b30f0,-0x14(%ebp)
c010421c:	0f 85 79 ff ff ff    	jne    c010419b <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0104222:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0104225:	e8 b2 10 00 00       	call   c01052dc <nr_free_pages>
c010422a:	39 c3                	cmp    %eax,%ebx
c010422c:	74 24                	je     c0104252 <default_check+0xd8>
c010422e:	c7 44 24 0c 46 d0 10 	movl   $0xc010d046,0xc(%esp)
c0104235:	c0 
c0104236:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c010423d:	c0 
c010423e:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0104245:	00 
c0104246:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c010424d:	e8 9e cb ff ff       	call   c0100df0 <__panic>

    basic_check();
c0104252:	e8 e7 f9 ff ff       	call   c0103c3e <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104257:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010425e:	e8 dc 0f 00 00       	call   c010523f <alloc_pages>
c0104263:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0104266:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010426a:	75 24                	jne    c0104290 <default_check+0x116>
c010426c:	c7 44 24 0c 5f d0 10 	movl   $0xc010d05f,0xc(%esp)
c0104273:	c0 
c0104274:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c010427b:	c0 
c010427c:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104283:	00 
c0104284:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c010428b:	e8 60 cb ff ff       	call   c0100df0 <__panic>
    assert(!PageProperty(p0));
c0104290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104293:	83 c0 04             	add    $0x4,%eax
c0104296:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010429d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042a0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01042a3:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01042a6:	0f a3 10             	bt     %edx,(%eax)
c01042a9:	19 c0                	sbb    %eax,%eax
c01042ab:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01042ae:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01042b2:	0f 95 c0             	setne  %al
c01042b5:	0f b6 c0             	movzbl %al,%eax
c01042b8:	85 c0                	test   %eax,%eax
c01042ba:	74 24                	je     c01042e0 <default_check+0x166>
c01042bc:	c7 44 24 0c 6a d0 10 	movl   $0xc010d06a,0xc(%esp)
c01042c3:	c0 
c01042c4:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01042cb:	c0 
c01042cc:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c01042d3:	00 
c01042d4:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01042db:	e8 10 cb ff ff       	call   c0100df0 <__panic>

    list_entry_t free_list_store = free_list;
c01042e0:	a1 f0 30 1b c0       	mov    0xc01b30f0,%eax
c01042e5:	8b 15 f4 30 1b c0    	mov    0xc01b30f4,%edx
c01042eb:	89 45 80             	mov    %eax,-0x80(%ebp)
c01042ee:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01042f1:	c7 45 b4 f0 30 1b c0 	movl   $0xc01b30f0,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01042f8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01042fb:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01042fe:	89 50 04             	mov    %edx,0x4(%eax)
c0104301:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104304:	8b 50 04             	mov    0x4(%eax),%edx
c0104307:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010430a:	89 10                	mov    %edx,(%eax)
c010430c:	c7 45 b0 f0 30 1b c0 	movl   $0xc01b30f0,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104313:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104316:	8b 40 04             	mov    0x4(%eax),%eax
c0104319:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c010431c:	0f 94 c0             	sete   %al
c010431f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104322:	85 c0                	test   %eax,%eax
c0104324:	75 24                	jne    c010434a <default_check+0x1d0>
c0104326:	c7 44 24 0c bf cf 10 	movl   $0xc010cfbf,0xc(%esp)
c010432d:	c0 
c010432e:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104335:	c0 
c0104336:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c010433d:	00 
c010433e:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104345:	e8 a6 ca ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c010434a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104351:	e8 e9 0e 00 00       	call   c010523f <alloc_pages>
c0104356:	85 c0                	test   %eax,%eax
c0104358:	74 24                	je     c010437e <default_check+0x204>
c010435a:	c7 44 24 0c d6 cf 10 	movl   $0xc010cfd6,0xc(%esp)
c0104361:	c0 
c0104362:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104369:	c0 
c010436a:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0104371:	00 
c0104372:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104379:	e8 72 ca ff ff       	call   c0100df0 <__panic>

    unsigned int nr_free_store = nr_free;
c010437e:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c0104383:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0104386:	c7 05 f8 30 1b c0 00 	movl   $0x0,0xc01b30f8
c010438d:	00 00 00 

    free_pages(p0 + 2, 3);
c0104390:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104393:	83 c0 40             	add    $0x40,%eax
c0104396:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010439d:	00 
c010439e:	89 04 24             	mov    %eax,(%esp)
c01043a1:	e8 04 0f 00 00       	call   c01052aa <free_pages>
    assert(alloc_pages(4) == NULL);
c01043a6:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01043ad:	e8 8d 0e 00 00       	call   c010523f <alloc_pages>
c01043b2:	85 c0                	test   %eax,%eax
c01043b4:	74 24                	je     c01043da <default_check+0x260>
c01043b6:	c7 44 24 0c 7c d0 10 	movl   $0xc010d07c,0xc(%esp)
c01043bd:	c0 
c01043be:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01043c5:	c0 
c01043c6:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c01043cd:	00 
c01043ce:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01043d5:	e8 16 ca ff ff       	call   c0100df0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01043da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043dd:	83 c0 40             	add    $0x40,%eax
c01043e0:	83 c0 04             	add    $0x4,%eax
c01043e3:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01043ea:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01043ed:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01043f0:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01043f3:	0f a3 10             	bt     %edx,(%eax)
c01043f6:	19 c0                	sbb    %eax,%eax
c01043f8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01043fb:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01043ff:	0f 95 c0             	setne  %al
c0104402:	0f b6 c0             	movzbl %al,%eax
c0104405:	85 c0                	test   %eax,%eax
c0104407:	74 0e                	je     c0104417 <default_check+0x29d>
c0104409:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010440c:	83 c0 40             	add    $0x40,%eax
c010440f:	8b 40 08             	mov    0x8(%eax),%eax
c0104412:	83 f8 03             	cmp    $0x3,%eax
c0104415:	74 24                	je     c010443b <default_check+0x2c1>
c0104417:	c7 44 24 0c 94 d0 10 	movl   $0xc010d094,0xc(%esp)
c010441e:	c0 
c010441f:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104426:	c0 
c0104427:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010442e:	00 
c010442f:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104436:	e8 b5 c9 ff ff       	call   c0100df0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010443b:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104442:	e8 f8 0d 00 00       	call   c010523f <alloc_pages>
c0104447:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010444a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010444e:	75 24                	jne    c0104474 <default_check+0x2fa>
c0104450:	c7 44 24 0c c0 d0 10 	movl   $0xc010d0c0,0xc(%esp)
c0104457:	c0 
c0104458:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c010445f:	c0 
c0104460:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104467:	00 
c0104468:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c010446f:	e8 7c c9 ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c0104474:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010447b:	e8 bf 0d 00 00       	call   c010523f <alloc_pages>
c0104480:	85 c0                	test   %eax,%eax
c0104482:	74 24                	je     c01044a8 <default_check+0x32e>
c0104484:	c7 44 24 0c d6 cf 10 	movl   $0xc010cfd6,0xc(%esp)
c010448b:	c0 
c010448c:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104493:	c0 
c0104494:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c010449b:	00 
c010449c:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01044a3:	e8 48 c9 ff ff       	call   c0100df0 <__panic>
    assert(p0 + 2 == p1);
c01044a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044ab:	83 c0 40             	add    $0x40,%eax
c01044ae:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01044b1:	74 24                	je     c01044d7 <default_check+0x35d>
c01044b3:	c7 44 24 0c de d0 10 	movl   $0xc010d0de,0xc(%esp)
c01044ba:	c0 
c01044bb:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01044c2:	c0 
c01044c3:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c01044ca:	00 
c01044cb:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01044d2:	e8 19 c9 ff ff       	call   c0100df0 <__panic>

    p2 = p0 + 1;
c01044d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044da:	83 c0 20             	add    $0x20,%eax
c01044dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01044e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01044e7:	00 
c01044e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044eb:	89 04 24             	mov    %eax,(%esp)
c01044ee:	e8 b7 0d 00 00       	call   c01052aa <free_pages>
    free_pages(p1, 3);
c01044f3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01044fa:	00 
c01044fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044fe:	89 04 24             	mov    %eax,(%esp)
c0104501:	e8 a4 0d 00 00       	call   c01052aa <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0104506:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104509:	83 c0 04             	add    $0x4,%eax
c010450c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104513:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104516:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104519:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010451c:	0f a3 10             	bt     %edx,(%eax)
c010451f:	19 c0                	sbb    %eax,%eax
c0104521:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104524:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104528:	0f 95 c0             	setne  %al
c010452b:	0f b6 c0             	movzbl %al,%eax
c010452e:	85 c0                	test   %eax,%eax
c0104530:	74 0b                	je     c010453d <default_check+0x3c3>
c0104532:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104535:	8b 40 08             	mov    0x8(%eax),%eax
c0104538:	83 f8 01             	cmp    $0x1,%eax
c010453b:	74 24                	je     c0104561 <default_check+0x3e7>
c010453d:	c7 44 24 0c ec d0 10 	movl   $0xc010d0ec,0xc(%esp)
c0104544:	c0 
c0104545:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c010454c:	c0 
c010454d:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0104554:	00 
c0104555:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c010455c:	e8 8f c8 ff ff       	call   c0100df0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104561:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104564:	83 c0 04             	add    $0x4,%eax
c0104567:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010456e:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104571:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104574:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104577:	0f a3 10             	bt     %edx,(%eax)
c010457a:	19 c0                	sbb    %eax,%eax
c010457c:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010457f:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0104583:	0f 95 c0             	setne  %al
c0104586:	0f b6 c0             	movzbl %al,%eax
c0104589:	85 c0                	test   %eax,%eax
c010458b:	74 0b                	je     c0104598 <default_check+0x41e>
c010458d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104590:	8b 40 08             	mov    0x8(%eax),%eax
c0104593:	83 f8 03             	cmp    $0x3,%eax
c0104596:	74 24                	je     c01045bc <default_check+0x442>
c0104598:	c7 44 24 0c 14 d1 10 	movl   $0xc010d114,0xc(%esp)
c010459f:	c0 
c01045a0:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01045a7:	c0 
c01045a8:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c01045af:	00 
c01045b0:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01045b7:	e8 34 c8 ff ff       	call   c0100df0 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01045bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01045c3:	e8 77 0c 00 00       	call   c010523f <alloc_pages>
c01045c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01045cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01045ce:	83 e8 20             	sub    $0x20,%eax
c01045d1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01045d4:	74 24                	je     c01045fa <default_check+0x480>
c01045d6:	c7 44 24 0c 3a d1 10 	movl   $0xc010d13a,0xc(%esp)
c01045dd:	c0 
c01045de:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01045e5:	c0 
c01045e6:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c01045ed:	00 
c01045ee:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01045f5:	e8 f6 c7 ff ff       	call   c0100df0 <__panic>
    free_page(p0);
c01045fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104601:	00 
c0104602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104605:	89 04 24             	mov    %eax,(%esp)
c0104608:	e8 9d 0c 00 00       	call   c01052aa <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010460d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0104614:	e8 26 0c 00 00       	call   c010523f <alloc_pages>
c0104619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010461c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010461f:	83 c0 20             	add    $0x20,%eax
c0104622:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104625:	74 24                	je     c010464b <default_check+0x4d1>
c0104627:	c7 44 24 0c 58 d1 10 	movl   $0xc010d158,0xc(%esp)
c010462e:	c0 
c010462f:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104636:	c0 
c0104637:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c010463e:	00 
c010463f:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104646:	e8 a5 c7 ff ff       	call   c0100df0 <__panic>

    free_pages(p0, 2);
c010464b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104652:	00 
c0104653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104656:	89 04 24             	mov    %eax,(%esp)
c0104659:	e8 4c 0c 00 00       	call   c01052aa <free_pages>
    free_page(p2);
c010465e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104665:	00 
c0104666:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104669:	89 04 24             	mov    %eax,(%esp)
c010466c:	e8 39 0c 00 00       	call   c01052aa <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104671:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104678:	e8 c2 0b 00 00       	call   c010523f <alloc_pages>
c010467d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104680:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104684:	75 24                	jne    c01046aa <default_check+0x530>
c0104686:	c7 44 24 0c 78 d1 10 	movl   $0xc010d178,0xc(%esp)
c010468d:	c0 
c010468e:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c0104695:	c0 
c0104696:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c010469d:	00 
c010469e:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01046a5:	e8 46 c7 ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c01046aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01046b1:	e8 89 0b 00 00       	call   c010523f <alloc_pages>
c01046b6:	85 c0                	test   %eax,%eax
c01046b8:	74 24                	je     c01046de <default_check+0x564>
c01046ba:	c7 44 24 0c d6 cf 10 	movl   $0xc010cfd6,0xc(%esp)
c01046c1:	c0 
c01046c2:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01046c9:	c0 
c01046ca:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c01046d1:	00 
c01046d2:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01046d9:	e8 12 c7 ff ff       	call   c0100df0 <__panic>

    assert(nr_free == 0);
c01046de:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c01046e3:	85 c0                	test   %eax,%eax
c01046e5:	74 24                	je     c010470b <default_check+0x591>
c01046e7:	c7 44 24 0c 29 d0 10 	movl   $0xc010d029,0xc(%esp)
c01046ee:	c0 
c01046ef:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01046f6:	c0 
c01046f7:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01046fe:	00 
c01046ff:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c0104706:	e8 e5 c6 ff ff       	call   c0100df0 <__panic>
    nr_free = nr_free_store;
c010470b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010470e:	a3 f8 30 1b c0       	mov    %eax,0xc01b30f8

    free_list = free_list_store;
c0104713:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104716:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104719:	a3 f0 30 1b c0       	mov    %eax,0xc01b30f0
c010471e:	89 15 f4 30 1b c0    	mov    %edx,0xc01b30f4
    free_pages(p0, 5);
c0104724:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010472b:	00 
c010472c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010472f:	89 04 24             	mov    %eax,(%esp)
c0104732:	e8 73 0b 00 00       	call   c01052aa <free_pages>

    le = &free_list;
c0104737:	c7 45 ec f0 30 1b c0 	movl   $0xc01b30f0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010473e:	eb 1d                	jmp    c010475d <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0104740:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104743:	83 e8 0c             	sub    $0xc,%eax
c0104746:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0104749:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010474d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104750:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104753:	8b 40 08             	mov    0x8(%eax),%eax
c0104756:	29 c2                	sub    %eax,%edx
c0104758:	89 d0                	mov    %edx,%eax
c010475a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010475d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104760:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104763:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104766:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104769:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010476c:	81 7d ec f0 30 1b c0 	cmpl   $0xc01b30f0,-0x14(%ebp)
c0104773:	75 cb                	jne    c0104740 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0104775:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104779:	74 24                	je     c010479f <default_check+0x625>
c010477b:	c7 44 24 0c 96 d1 10 	movl   $0xc010d196,0xc(%esp)
c0104782:	c0 
c0104783:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c010478a:	c0 
c010478b:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0104792:	00 
c0104793:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c010479a:	e8 51 c6 ff ff       	call   c0100df0 <__panic>
    assert(total == 0);
c010479f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01047a3:	74 24                	je     c01047c9 <default_check+0x64f>
c01047a5:	c7 44 24 0c a1 d1 10 	movl   $0xc010d1a1,0xc(%esp)
c01047ac:	c0 
c01047ad:	c7 44 24 08 36 ce 10 	movl   $0xc010ce36,0x8(%esp)
c01047b4:	c0 
c01047b5:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c01047bc:	00 
c01047bd:	c7 04 24 4b ce 10 c0 	movl   $0xc010ce4b,(%esp)
c01047c4:	e8 27 c6 ff ff       	call   c0100df0 <__panic>
}
c01047c9:	81 c4 94 00 00 00    	add    $0x94,%esp
c01047cf:	5b                   	pop    %ebx
c01047d0:	5d                   	pop    %ebp
c01047d1:	c3                   	ret    

c01047d2 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01047d2:	55                   	push   %ebp
c01047d3:	89 e5                	mov    %esp,%ebp
c01047d5:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01047d8:	9c                   	pushf  
c01047d9:	58                   	pop    %eax
c01047da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01047dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01047e0:	25 00 02 00 00       	and    $0x200,%eax
c01047e5:	85 c0                	test   %eax,%eax
c01047e7:	74 0c                	je     c01047f5 <__intr_save+0x23>
        intr_disable();
c01047e9:	e8 6b d8 ff ff       	call   c0102059 <intr_disable>
        return 1;
c01047ee:	b8 01 00 00 00       	mov    $0x1,%eax
c01047f3:	eb 05                	jmp    c01047fa <__intr_save+0x28>
    }
    return 0;
c01047f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047fa:	c9                   	leave  
c01047fb:	c3                   	ret    

c01047fc <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01047fc:	55                   	push   %ebp
c01047fd:	89 e5                	mov    %esp,%ebp
c01047ff:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104802:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104806:	74 05                	je     c010480d <__intr_restore+0x11>
        intr_enable();
c0104808:	e8 46 d8 ff ff       	call   c0102053 <intr_enable>
    }
}
c010480d:	c9                   	leave  
c010480e:	c3                   	ret    

c010480f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010480f:	55                   	push   %ebp
c0104810:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104812:	8b 55 08             	mov    0x8(%ebp),%edx
c0104815:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c010481a:	29 c2                	sub    %eax,%edx
c010481c:	89 d0                	mov    %edx,%eax
c010481e:	c1 f8 05             	sar    $0x5,%eax
}
c0104821:	5d                   	pop    %ebp
c0104822:	c3                   	ret    

c0104823 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104823:	55                   	push   %ebp
c0104824:	89 e5                	mov    %esp,%ebp
c0104826:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104829:	8b 45 08             	mov    0x8(%ebp),%eax
c010482c:	89 04 24             	mov    %eax,(%esp)
c010482f:	e8 db ff ff ff       	call   c010480f <page2ppn>
c0104834:	c1 e0 0c             	shl    $0xc,%eax
}
c0104837:	c9                   	leave  
c0104838:	c3                   	ret    

c0104839 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104839:	55                   	push   %ebp
c010483a:	89 e5                	mov    %esp,%ebp
c010483c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010483f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104842:	c1 e8 0c             	shr    $0xc,%eax
c0104845:	89 c2                	mov    %eax,%edx
c0104847:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c010484c:	39 c2                	cmp    %eax,%edx
c010484e:	72 1c                	jb     c010486c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104850:	c7 44 24 08 dc d1 10 	movl   $0xc010d1dc,0x8(%esp)
c0104857:	c0 
c0104858:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010485f:	00 
c0104860:	c7 04 24 fb d1 10 c0 	movl   $0xc010d1fb,(%esp)
c0104867:	e8 84 c5 ff ff       	call   c0100df0 <__panic>
    }
    return &pages[PPN(pa)];
c010486c:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0104871:	8b 55 08             	mov    0x8(%ebp),%edx
c0104874:	c1 ea 0c             	shr    $0xc,%edx
c0104877:	c1 e2 05             	shl    $0x5,%edx
c010487a:	01 d0                	add    %edx,%eax
}
c010487c:	c9                   	leave  
c010487d:	c3                   	ret    

c010487e <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010487e:	55                   	push   %ebp
c010487f:	89 e5                	mov    %esp,%ebp
c0104881:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104884:	8b 45 08             	mov    0x8(%ebp),%eax
c0104887:	89 04 24             	mov    %eax,(%esp)
c010488a:	e8 94 ff ff ff       	call   c0104823 <page2pa>
c010488f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104892:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104895:	c1 e8 0c             	shr    $0xc,%eax
c0104898:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010489b:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c01048a0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01048a3:	72 23                	jb     c01048c8 <page2kva+0x4a>
c01048a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048ac:	c7 44 24 08 0c d2 10 	movl   $0xc010d20c,0x8(%esp)
c01048b3:	c0 
c01048b4:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01048bb:	00 
c01048bc:	c7 04 24 fb d1 10 c0 	movl   $0xc010d1fb,(%esp)
c01048c3:	e8 28 c5 ff ff       	call   c0100df0 <__panic>
c01048c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048cb:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01048d0:	c9                   	leave  
c01048d1:	c3                   	ret    

c01048d2 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01048d2:	55                   	push   %ebp
c01048d3:	89 e5                	mov    %esp,%ebp
c01048d5:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01048d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01048db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048de:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01048e5:	77 23                	ja     c010490a <kva2page+0x38>
c01048e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048ee:	c7 44 24 08 30 d2 10 	movl   $0xc010d230,0x8(%esp)
c01048f5:	c0 
c01048f6:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01048fd:	00 
c01048fe:	c7 04 24 fb d1 10 c0 	movl   $0xc010d1fb,(%esp)
c0104905:	e8 e6 c4 ff ff       	call   c0100df0 <__panic>
c010490a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010490d:	05 00 00 00 40       	add    $0x40000000,%eax
c0104912:	89 04 24             	mov    %eax,(%esp)
c0104915:	e8 1f ff ff ff       	call   c0104839 <pa2page>
}
c010491a:	c9                   	leave  
c010491b:	c3                   	ret    

c010491c <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c010491c:	55                   	push   %ebp
c010491d:	89 e5                	mov    %esp,%ebp
c010491f:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104922:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104925:	ba 01 00 00 00       	mov    $0x1,%edx
c010492a:	89 c1                	mov    %eax,%ecx
c010492c:	d3 e2                	shl    %cl,%edx
c010492e:	89 d0                	mov    %edx,%eax
c0104930:	89 04 24             	mov    %eax,(%esp)
c0104933:	e8 07 09 00 00       	call   c010523f <alloc_pages>
c0104938:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c010493b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010493f:	75 07                	jne    c0104948 <__slob_get_free_pages+0x2c>
    return NULL;
c0104941:	b8 00 00 00 00       	mov    $0x0,%eax
c0104946:	eb 0b                	jmp    c0104953 <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104948:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010494b:	89 04 24             	mov    %eax,(%esp)
c010494e:	e8 2b ff ff ff       	call   c010487e <page2kva>
}
c0104953:	c9                   	leave  
c0104954:	c3                   	ret    

c0104955 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104955:	55                   	push   %ebp
c0104956:	89 e5                	mov    %esp,%ebp
c0104958:	53                   	push   %ebx
c0104959:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c010495c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010495f:	ba 01 00 00 00       	mov    $0x1,%edx
c0104964:	89 c1                	mov    %eax,%ecx
c0104966:	d3 e2                	shl    %cl,%edx
c0104968:	89 d0                	mov    %edx,%eax
c010496a:	89 c3                	mov    %eax,%ebx
c010496c:	8b 45 08             	mov    0x8(%ebp),%eax
c010496f:	89 04 24             	mov    %eax,(%esp)
c0104972:	e8 5b ff ff ff       	call   c01048d2 <kva2page>
c0104977:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010497b:	89 04 24             	mov    %eax,(%esp)
c010497e:	e8 27 09 00 00       	call   c01052aa <free_pages>
}
c0104983:	83 c4 14             	add    $0x14,%esp
c0104986:	5b                   	pop    %ebx
c0104987:	5d                   	pop    %ebp
c0104988:	c3                   	ret    

c0104989 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104989:	55                   	push   %ebp
c010498a:	89 e5                	mov    %esp,%ebp
c010498c:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c010498f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104992:	83 c0 08             	add    $0x8,%eax
c0104995:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010499a:	76 24                	jbe    c01049c0 <slob_alloc+0x37>
c010499c:	c7 44 24 0c 54 d2 10 	movl   $0xc010d254,0xc(%esp)
c01049a3:	c0 
c01049a4:	c7 44 24 08 73 d2 10 	movl   $0xc010d273,0x8(%esp)
c01049ab:	c0 
c01049ac:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01049b3:	00 
c01049b4:	c7 04 24 88 d2 10 c0 	movl   $0xc010d288,(%esp)
c01049bb:	e8 30 c4 ff ff       	call   c0100df0 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c01049c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01049c7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01049ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01049d1:	83 c0 07             	add    $0x7,%eax
c01049d4:	c1 e8 03             	shr    $0x3,%eax
c01049d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01049da:	e8 f3 fd ff ff       	call   c01047d2 <__intr_save>
c01049df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01049e2:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c01049e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01049ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ed:	8b 40 04             	mov    0x4(%eax),%eax
c01049f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01049f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01049f7:	74 25                	je     c0104a1e <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c01049f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01049fc:	8b 45 10             	mov    0x10(%ebp),%eax
c01049ff:	01 d0                	add    %edx,%eax
c0104a01:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104a04:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a07:	f7 d8                	neg    %eax
c0104a09:	21 d0                	and    %edx,%eax
c0104a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104a0e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a14:	29 c2                	sub    %eax,%edx
c0104a16:	89 d0                	mov    %edx,%eax
c0104a18:	c1 f8 03             	sar    $0x3,%eax
c0104a1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a21:	8b 00                	mov    (%eax),%eax
c0104a23:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104a26:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104a29:	01 ca                	add    %ecx,%edx
c0104a2b:	39 d0                	cmp    %edx,%eax
c0104a2d:	0f 8c aa 00 00 00    	jl     c0104add <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0104a33:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104a37:	74 38                	je     c0104a71 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0104a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a3c:	8b 00                	mov    (%eax),%eax
c0104a3e:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104a41:	89 c2                	mov    %eax,%edx
c0104a43:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a46:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a4b:	8b 50 04             	mov    0x4(%eax),%edx
c0104a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a51:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a57:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a5a:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a60:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104a63:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a74:	8b 00                	mov    (%eax),%eax
c0104a76:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104a79:	75 0e                	jne    c0104a89 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0104a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a7e:	8b 50 04             	mov    0x4(%eax),%edx
c0104a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a84:	89 50 04             	mov    %edx,0x4(%eax)
c0104a87:	eb 3c                	jmp    c0104ac5 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0104a89:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a8c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a96:	01 c2                	add    %eax,%edx
c0104a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a9b:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104aa1:	8b 40 04             	mov    0x4(%eax),%eax
c0104aa4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104aa7:	8b 12                	mov    (%edx),%edx
c0104aa9:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104aac:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ab1:	8b 40 04             	mov    0x4(%eax),%eax
c0104ab4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104ab7:	8b 52 04             	mov    0x4(%edx),%edx
c0104aba:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ac0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104ac3:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ac8:	a3 e8 c9 12 c0       	mov    %eax,0xc012c9e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0104acd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ad0:	89 04 24             	mov    %eax,(%esp)
c0104ad3:	e8 24 fd ff ff       	call   c01047fc <__intr_restore>
			return cur;
c0104ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104adb:	eb 7f                	jmp    c0104b5c <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0104add:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c0104ae2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104ae5:	75 61                	jne    c0104b48 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104ae7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104aea:	89 04 24             	mov    %eax,(%esp)
c0104aed:	e8 0a fd ff ff       	call   c01047fc <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104af2:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104af9:	75 07                	jne    c0104b02 <slob_alloc+0x179>
				return 0;
c0104afb:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b00:	eb 5a                	jmp    c0104b5c <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104b02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b09:	00 
c0104b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b0d:	89 04 24             	mov    %eax,(%esp)
c0104b10:	e8 07 fe ff ff       	call   c010491c <__slob_get_free_pages>
c0104b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104b18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b1c:	75 07                	jne    c0104b25 <slob_alloc+0x19c>
				return 0;
c0104b1e:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b23:	eb 37                	jmp    c0104b5c <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c0104b25:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b2c:	00 
c0104b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b30:	89 04 24             	mov    %eax,(%esp)
c0104b33:	e8 26 00 00 00       	call   c0104b5e <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104b38:	e8 95 fc ff ff       	call   c01047d2 <__intr_save>
c0104b3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104b40:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c0104b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b51:	8b 40 04             	mov    0x4(%eax),%eax
c0104b54:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0104b57:	e9 97 fe ff ff       	jmp    c01049f3 <slob_alloc+0x6a>
}
c0104b5c:	c9                   	leave  
c0104b5d:	c3                   	ret    

c0104b5e <slob_free>:

static void slob_free(void *block, int size)
{
c0104b5e:	55                   	push   %ebp
c0104b5f:	89 e5                	mov    %esp,%ebp
c0104b61:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b67:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104b6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104b6e:	75 05                	jne    c0104b75 <slob_free+0x17>
		return;
c0104b70:	e9 ff 00 00 00       	jmp    c0104c74 <slob_free+0x116>

	if (size)
c0104b75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104b79:	74 10                	je     c0104b8b <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c0104b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b7e:	83 c0 07             	add    $0x7,%eax
c0104b81:	c1 e8 03             	shr    $0x3,%eax
c0104b84:	89 c2                	mov    %eax,%edx
c0104b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b89:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0104b8b:	e8 42 fc ff ff       	call   c01047d2 <__intr_save>
c0104b90:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104b93:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c0104b98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b9b:	eb 27                	jmp    c0104bc4 <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0104b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ba0:	8b 40 04             	mov    0x4(%eax),%eax
c0104ba3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104ba6:	77 13                	ja     c0104bbb <slob_free+0x5d>
c0104ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bae:	77 27                	ja     c0104bd7 <slob_free+0x79>
c0104bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bb3:	8b 40 04             	mov    0x4(%eax),%eax
c0104bb6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104bb9:	77 1c                	ja     c0104bd7 <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bbe:	8b 40 04             	mov    0x4(%eax),%eax
c0104bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bc7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bca:	76 d1                	jbe    c0104b9d <slob_free+0x3f>
c0104bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bcf:	8b 40 04             	mov    0x4(%eax),%eax
c0104bd2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104bd5:	76 c6                	jbe    c0104b9d <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0104bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bda:	8b 00                	mov    (%eax),%eax
c0104bdc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be6:	01 c2                	add    %eax,%edx
c0104be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104beb:	8b 40 04             	mov    0x4(%eax),%eax
c0104bee:	39 c2                	cmp    %eax,%edx
c0104bf0:	75 25                	jne    c0104c17 <slob_free+0xb9>
		b->units += cur->next->units;
c0104bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bf5:	8b 10                	mov    (%eax),%edx
c0104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bfa:	8b 40 04             	mov    0x4(%eax),%eax
c0104bfd:	8b 00                	mov    (%eax),%eax
c0104bff:	01 c2                	add    %eax,%edx
c0104c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c04:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c09:	8b 40 04             	mov    0x4(%eax),%eax
c0104c0c:	8b 50 04             	mov    0x4(%eax),%edx
c0104c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c12:	89 50 04             	mov    %edx,0x4(%eax)
c0104c15:	eb 0c                	jmp    c0104c23 <slob_free+0xc5>
	} else
		b->next = cur->next;
c0104c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c1a:	8b 50 04             	mov    0x4(%eax),%edx
c0104c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c20:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c26:	8b 00                	mov    (%eax),%eax
c0104c28:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c32:	01 d0                	add    %edx,%eax
c0104c34:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104c37:	75 1f                	jne    c0104c58 <slob_free+0xfa>
		cur->units += b->units;
c0104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c3c:	8b 10                	mov    (%eax),%edx
c0104c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c41:	8b 00                	mov    (%eax),%eax
c0104c43:	01 c2                	add    %eax,%edx
c0104c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c48:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c4d:	8b 50 04             	mov    0x4(%eax),%edx
c0104c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c53:	89 50 04             	mov    %edx,0x4(%eax)
c0104c56:	eb 09                	jmp    c0104c61 <slob_free+0x103>
	} else
		cur->next = b;
c0104c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104c5e:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c64:	a3 e8 c9 12 c0       	mov    %eax,0xc012c9e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0104c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c6c:	89 04 24             	mov    %eax,(%esp)
c0104c6f:	e8 88 fb ff ff       	call   c01047fc <__intr_restore>
}
c0104c74:	c9                   	leave  
c0104c75:	c3                   	ret    

c0104c76 <slob_init>:



void
slob_init(void) {
c0104c76:	55                   	push   %ebp
c0104c77:	89 e5                	mov    %esp,%ebp
c0104c79:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104c7c:	c7 04 24 9a d2 10 c0 	movl   $0xc010d29a,(%esp)
c0104c83:	e8 dc b6 ff ff       	call   c0100364 <cprintf>
}
c0104c88:	c9                   	leave  
c0104c89:	c3                   	ret    

c0104c8a <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104c8a:	55                   	push   %ebp
c0104c8b:	89 e5                	mov    %esp,%ebp
c0104c8d:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104c90:	e8 e1 ff ff ff       	call   c0104c76 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104c95:	c7 04 24 ae d2 10 c0 	movl   $0xc010d2ae,(%esp)
c0104c9c:	e8 c3 b6 ff ff       	call   c0100364 <cprintf>
}
c0104ca1:	c9                   	leave  
c0104ca2:	c3                   	ret    

c0104ca3 <slob_allocated>:

size_t
slob_allocated(void) {
c0104ca3:	55                   	push   %ebp
c0104ca4:	89 e5                	mov    %esp,%ebp
  return 0;
c0104ca6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cab:	5d                   	pop    %ebp
c0104cac:	c3                   	ret    

c0104cad <kallocated>:

size_t
kallocated(void) {
c0104cad:	55                   	push   %ebp
c0104cae:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104cb0:	e8 ee ff ff ff       	call   c0104ca3 <slob_allocated>
}
c0104cb5:	5d                   	pop    %ebp
c0104cb6:	c3                   	ret    

c0104cb7 <find_order>:

static int find_order(int size)
{
c0104cb7:	55                   	push   %ebp
c0104cb8:	89 e5                	mov    %esp,%ebp
c0104cba:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104cbd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104cc4:	eb 07                	jmp    c0104ccd <find_order+0x16>
		order++;
c0104cc6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0104cca:	d1 7d 08             	sarl   0x8(%ebp)
c0104ccd:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104cd4:	7f f0                	jg     c0104cc6 <find_order+0xf>
		order++;
	return order;
c0104cd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104cd9:	c9                   	leave  
c0104cda:	c3                   	ret    

c0104cdb <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104cdb:	55                   	push   %ebp
c0104cdc:	89 e5                	mov    %esp,%ebp
c0104cde:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104ce1:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104ce8:	77 38                	ja     c0104d22 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104cea:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ced:	8d 50 08             	lea    0x8(%eax),%edx
c0104cf0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104cf7:	00 
c0104cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104cff:	89 14 24             	mov    %edx,(%esp)
c0104d02:	e8 82 fc ff ff       	call   c0104989 <slob_alloc>
c0104d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d0e:	74 08                	je     c0104d18 <__kmalloc+0x3d>
c0104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d13:	83 c0 08             	add    $0x8,%eax
c0104d16:	eb 05                	jmp    c0104d1d <__kmalloc+0x42>
c0104d18:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d1d:	e9 a6 00 00 00       	jmp    c0104dc8 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104d22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d29:	00 
c0104d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d31:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104d38:	e8 4c fc ff ff       	call   c0104989 <slob_alloc>
c0104d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104d40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d44:	75 07                	jne    c0104d4d <__kmalloc+0x72>
		return 0;
c0104d46:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d4b:	eb 7b                	jmp    c0104dc8 <__kmalloc+0xed>

	bb->order = find_order(size);
c0104d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d50:	89 04 24             	mov    %eax,(%esp)
c0104d53:	e8 5f ff ff ff       	call   c0104cb7 <find_order>
c0104d58:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104d5b:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d60:	8b 00                	mov    (%eax),%eax
c0104d62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d69:	89 04 24             	mov    %eax,(%esp)
c0104d6c:	e8 ab fb ff ff       	call   c010491c <__slob_get_free_pages>
c0104d71:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104d74:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d7a:	8b 40 04             	mov    0x4(%eax),%eax
c0104d7d:	85 c0                	test   %eax,%eax
c0104d7f:	74 2f                	je     c0104db0 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0104d81:	e8 4c fa ff ff       	call   c01047d2 <__intr_save>
c0104d86:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104d89:	8b 15 84 0f 1b c0    	mov    0xc01b0f84,%edx
c0104d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d92:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d98:	a3 84 0f 1b c0       	mov    %eax,0xc01b0f84
		spin_unlock_irqrestore(&block_lock, flags);
c0104d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104da0:	89 04 24             	mov    %eax,(%esp)
c0104da3:	e8 54 fa ff ff       	call   c01047fc <__intr_restore>
		return bb->pages;
c0104da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dab:	8b 40 04             	mov    0x4(%eax),%eax
c0104dae:	eb 18                	jmp    c0104dc8 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104db0:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104db7:	00 
c0104db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dbb:	89 04 24             	mov    %eax,(%esp)
c0104dbe:	e8 9b fd ff ff       	call   c0104b5e <slob_free>
	return 0;
c0104dc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104dc8:	c9                   	leave  
c0104dc9:	c3                   	ret    

c0104dca <kmalloc>:

void *
kmalloc(size_t size)
{
c0104dca:	55                   	push   %ebp
c0104dcb:	89 e5                	mov    %esp,%ebp
c0104dcd:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104dd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104dd7:	00 
c0104dd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ddb:	89 04 24             	mov    %eax,(%esp)
c0104dde:	e8 f8 fe ff ff       	call   c0104cdb <__kmalloc>
}
c0104de3:	c9                   	leave  
c0104de4:	c3                   	ret    

c0104de5 <kfree>:


void kfree(void *block)
{
c0104de5:	55                   	push   %ebp
c0104de6:	89 e5                	mov    %esp,%ebp
c0104de8:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104deb:	c7 45 f0 84 0f 1b c0 	movl   $0xc01b0f84,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104df2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104df6:	75 05                	jne    c0104dfd <kfree+0x18>
		return;
c0104df8:	e9 a2 00 00 00       	jmp    c0104e9f <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e00:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e05:	85 c0                	test   %eax,%eax
c0104e07:	75 7f                	jne    c0104e88 <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104e09:	e8 c4 f9 ff ff       	call   c01047d2 <__intr_save>
c0104e0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104e11:	a1 84 0f 1b c0       	mov    0xc01b0f84,%eax
c0104e16:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e19:	eb 5c                	jmp    c0104e77 <kfree+0x92>
			if (bb->pages == block) {
c0104e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e1e:	8b 40 04             	mov    0x4(%eax),%eax
c0104e21:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104e24:	75 3f                	jne    c0104e65 <kfree+0x80>
				*last = bb->next;
c0104e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e29:	8b 50 08             	mov    0x8(%eax),%edx
c0104e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e2f:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104e31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e34:	89 04 24             	mov    %eax,(%esp)
c0104e37:	e8 c0 f9 ff ff       	call   c01047fc <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e3f:	8b 10                	mov    (%eax),%edx
c0104e41:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e44:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e48:	89 04 24             	mov    %eax,(%esp)
c0104e4b:	e8 05 fb ff ff       	call   c0104955 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104e50:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104e57:	00 
c0104e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e5b:	89 04 24             	mov    %eax,(%esp)
c0104e5e:	e8 fb fc ff ff       	call   c0104b5e <slob_free>
				return;
c0104e63:	eb 3a                	jmp    c0104e9f <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e68:	83 c0 08             	add    $0x8,%eax
c0104e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e71:	8b 40 08             	mov    0x8(%eax),%eax
c0104e74:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e7b:	75 9e                	jne    c0104e1b <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104e7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e80:	89 04 24             	mov    %eax,(%esp)
c0104e83:	e8 74 f9 ff ff       	call   c01047fc <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104e88:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e8b:	83 e8 08             	sub    $0x8,%eax
c0104e8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104e95:	00 
c0104e96:	89 04 24             	mov    %eax,(%esp)
c0104e99:	e8 c0 fc ff ff       	call   c0104b5e <slob_free>
	return;
c0104e9e:	90                   	nop
}
c0104e9f:	c9                   	leave  
c0104ea0:	c3                   	ret    

c0104ea1 <ksize>:


unsigned int ksize(const void *block)
{
c0104ea1:	55                   	push   %ebp
c0104ea2:	89 e5                	mov    %esp,%ebp
c0104ea4:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104ea7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104eab:	75 07                	jne    c0104eb4 <ksize+0x13>
		return 0;
c0104ead:	b8 00 00 00 00       	mov    $0x0,%eax
c0104eb2:	eb 6b                	jmp    c0104f1f <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104eb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eb7:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104ebc:	85 c0                	test   %eax,%eax
c0104ebe:	75 54                	jne    c0104f14 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104ec0:	e8 0d f9 ff ff       	call   c01047d2 <__intr_save>
c0104ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104ec8:	a1 84 0f 1b c0       	mov    0xc01b0f84,%eax
c0104ecd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ed0:	eb 31                	jmp    c0104f03 <ksize+0x62>
			if (bb->pages == block) {
c0104ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ed5:	8b 40 04             	mov    0x4(%eax),%eax
c0104ed8:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104edb:	75 1d                	jne    c0104efa <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ee0:	89 04 24             	mov    %eax,(%esp)
c0104ee3:	e8 14 f9 ff ff       	call   c01047fc <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eeb:	8b 00                	mov    (%eax),%eax
c0104eed:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104ef2:	89 c1                	mov    %eax,%ecx
c0104ef4:	d3 e2                	shl    %cl,%edx
c0104ef6:	89 d0                	mov    %edx,%eax
c0104ef8:	eb 25                	jmp    c0104f1f <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0104efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104efd:	8b 40 08             	mov    0x8(%eax),%eax
c0104f00:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f07:	75 c9                	jne    c0104ed2 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f0c:	89 04 24             	mov    %eax,(%esp)
c0104f0f:	e8 e8 f8 ff ff       	call   c01047fc <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f17:	83 e8 08             	sub    $0x8,%eax
c0104f1a:	8b 00                	mov    (%eax),%eax
c0104f1c:	c1 e0 03             	shl    $0x3,%eax
}
c0104f1f:	c9                   	leave  
c0104f20:	c3                   	ret    

c0104f21 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104f21:	55                   	push   %ebp
c0104f22:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104f24:	8b 55 08             	mov    0x8(%ebp),%edx
c0104f27:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0104f2c:	29 c2                	sub    %eax,%edx
c0104f2e:	89 d0                	mov    %edx,%eax
c0104f30:	c1 f8 05             	sar    $0x5,%eax
}
c0104f33:	5d                   	pop    %ebp
c0104f34:	c3                   	ret    

c0104f35 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104f35:	55                   	push   %ebp
c0104f36:	89 e5                	mov    %esp,%ebp
c0104f38:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104f3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f3e:	89 04 24             	mov    %eax,(%esp)
c0104f41:	e8 db ff ff ff       	call   c0104f21 <page2ppn>
c0104f46:	c1 e0 0c             	shl    $0xc,%eax
}
c0104f49:	c9                   	leave  
c0104f4a:	c3                   	ret    

c0104f4b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104f4b:	55                   	push   %ebp
c0104f4c:	89 e5                	mov    %esp,%ebp
c0104f4e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104f51:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f54:	c1 e8 0c             	shr    $0xc,%eax
c0104f57:	89 c2                	mov    %eax,%edx
c0104f59:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0104f5e:	39 c2                	cmp    %eax,%edx
c0104f60:	72 1c                	jb     c0104f7e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104f62:	c7 44 24 08 cc d2 10 	movl   $0xc010d2cc,0x8(%esp)
c0104f69:	c0 
c0104f6a:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104f71:	00 
c0104f72:	c7 04 24 eb d2 10 c0 	movl   $0xc010d2eb,(%esp)
c0104f79:	e8 72 be ff ff       	call   c0100df0 <__panic>
    }
    return &pages[PPN(pa)];
c0104f7e:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0104f83:	8b 55 08             	mov    0x8(%ebp),%edx
c0104f86:	c1 ea 0c             	shr    $0xc,%edx
c0104f89:	c1 e2 05             	shl    $0x5,%edx
c0104f8c:	01 d0                	add    %edx,%eax
}
c0104f8e:	c9                   	leave  
c0104f8f:	c3                   	ret    

c0104f90 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104f90:	55                   	push   %ebp
c0104f91:	89 e5                	mov    %esp,%ebp
c0104f93:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104f96:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f99:	89 04 24             	mov    %eax,(%esp)
c0104f9c:	e8 94 ff ff ff       	call   c0104f35 <page2pa>
c0104fa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fa7:	c1 e8 0c             	shr    $0xc,%eax
c0104faa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104fad:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0104fb2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104fb5:	72 23                	jb     c0104fda <page2kva+0x4a>
c0104fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fba:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104fbe:	c7 44 24 08 fc d2 10 	movl   $0xc010d2fc,0x8(%esp)
c0104fc5:	c0 
c0104fc6:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104fcd:	00 
c0104fce:	c7 04 24 eb d2 10 c0 	movl   $0xc010d2eb,(%esp)
c0104fd5:	e8 16 be ff ff       	call   c0100df0 <__panic>
c0104fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fdd:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104fe2:	c9                   	leave  
c0104fe3:	c3                   	ret    

c0104fe4 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0104fe4:	55                   	push   %ebp
c0104fe5:	89 e5                	mov    %esp,%ebp
c0104fe7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104fea:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fed:	83 e0 01             	and    $0x1,%eax
c0104ff0:	85 c0                	test   %eax,%eax
c0104ff2:	75 1c                	jne    c0105010 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104ff4:	c7 44 24 08 20 d3 10 	movl   $0xc010d320,0x8(%esp)
c0104ffb:	c0 
c0104ffc:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0105003:	00 
c0105004:	c7 04 24 eb d2 10 c0 	movl   $0xc010d2eb,(%esp)
c010500b:	e8 e0 bd ff ff       	call   c0100df0 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0105010:	8b 45 08             	mov    0x8(%ebp),%eax
c0105013:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105018:	89 04 24             	mov    %eax,(%esp)
c010501b:	e8 2b ff ff ff       	call   c0104f4b <pa2page>
}
c0105020:	c9                   	leave  
c0105021:	c3                   	ret    

c0105022 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0105022:	55                   	push   %ebp
c0105023:	89 e5                	mov    %esp,%ebp
c0105025:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0105028:	8b 45 08             	mov    0x8(%ebp),%eax
c010502b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105030:	89 04 24             	mov    %eax,(%esp)
c0105033:	e8 13 ff ff ff       	call   c0104f4b <pa2page>
}
c0105038:	c9                   	leave  
c0105039:	c3                   	ret    

c010503a <page_ref>:

static inline int
page_ref(struct Page *page) {
c010503a:	55                   	push   %ebp
c010503b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010503d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105040:	8b 00                	mov    (%eax),%eax
}
c0105042:	5d                   	pop    %ebp
c0105043:	c3                   	ret    

c0105044 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0105044:	55                   	push   %ebp
c0105045:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105047:	8b 45 08             	mov    0x8(%ebp),%eax
c010504a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010504d:	89 10                	mov    %edx,(%eax)
}
c010504f:	5d                   	pop    %ebp
c0105050:	c3                   	ret    

c0105051 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0105051:	55                   	push   %ebp
c0105052:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0105054:	8b 45 08             	mov    0x8(%ebp),%eax
c0105057:	8b 00                	mov    (%eax),%eax
c0105059:	8d 50 01             	lea    0x1(%eax),%edx
c010505c:	8b 45 08             	mov    0x8(%ebp),%eax
c010505f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0105061:	8b 45 08             	mov    0x8(%ebp),%eax
c0105064:	8b 00                	mov    (%eax),%eax
}
c0105066:	5d                   	pop    %ebp
c0105067:	c3                   	ret    

c0105068 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0105068:	55                   	push   %ebp
c0105069:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010506b:	8b 45 08             	mov    0x8(%ebp),%eax
c010506e:	8b 00                	mov    (%eax),%eax
c0105070:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105073:	8b 45 08             	mov    0x8(%ebp),%eax
c0105076:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0105078:	8b 45 08             	mov    0x8(%ebp),%eax
c010507b:	8b 00                	mov    (%eax),%eax
}
c010507d:	5d                   	pop    %ebp
c010507e:	c3                   	ret    

c010507f <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010507f:	55                   	push   %ebp
c0105080:	89 e5                	mov    %esp,%ebp
c0105082:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0105085:	9c                   	pushf  
c0105086:	58                   	pop    %eax
c0105087:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010508a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010508d:	25 00 02 00 00       	and    $0x200,%eax
c0105092:	85 c0                	test   %eax,%eax
c0105094:	74 0c                	je     c01050a2 <__intr_save+0x23>
        intr_disable();
c0105096:	e8 be cf ff ff       	call   c0102059 <intr_disable>
        return 1;
c010509b:	b8 01 00 00 00       	mov    $0x1,%eax
c01050a0:	eb 05                	jmp    c01050a7 <__intr_save+0x28>
    }
    return 0;
c01050a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01050a7:	c9                   	leave  
c01050a8:	c3                   	ret    

c01050a9 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01050a9:	55                   	push   %ebp
c01050aa:	89 e5                	mov    %esp,%ebp
c01050ac:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01050af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01050b3:	74 05                	je     c01050ba <__intr_restore+0x11>
        intr_enable();
c01050b5:	e8 99 cf ff ff       	call   c0102053 <intr_enable>
    }
}
c01050ba:	c9                   	leave  
c01050bb:	c3                   	ret    

c01050bc <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01050bc:	55                   	push   %ebp
c01050bd:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01050bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01050c2:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01050c5:	b8 23 00 00 00       	mov    $0x23,%eax
c01050ca:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01050cc:	b8 23 00 00 00       	mov    $0x23,%eax
c01050d1:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01050d3:	b8 10 00 00 00       	mov    $0x10,%eax
c01050d8:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01050da:	b8 10 00 00 00       	mov    $0x10,%eax
c01050df:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01050e1:	b8 10 00 00 00       	mov    $0x10,%eax
c01050e6:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01050e8:	ea ef 50 10 c0 08 00 	ljmp   $0x8,$0xc01050ef
}
c01050ef:	5d                   	pop    %ebp
c01050f0:	c3                   	ret    

c01050f1 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01050f1:	55                   	push   %ebp
c01050f2:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01050f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01050f7:	a3 c4 0f 1b c0       	mov    %eax,0xc01b0fc4
}
c01050fc:	5d                   	pop    %ebp
c01050fd:	c3                   	ret    

c01050fe <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01050fe:	55                   	push   %ebp
c01050ff:	89 e5                	mov    %esp,%ebp
c0105101:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0105104:	b8 00 c0 12 c0       	mov    $0xc012c000,%eax
c0105109:	89 04 24             	mov    %eax,(%esp)
c010510c:	e8 e0 ff ff ff       	call   c01050f1 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0105111:	66 c7 05 c8 0f 1b c0 	movw   $0x10,0xc01b0fc8
c0105118:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010511a:	66 c7 05 48 ca 12 c0 	movw   $0x68,0xc012ca48
c0105121:	68 00 
c0105123:	b8 c0 0f 1b c0       	mov    $0xc01b0fc0,%eax
c0105128:	66 a3 4a ca 12 c0    	mov    %ax,0xc012ca4a
c010512e:	b8 c0 0f 1b c0       	mov    $0xc01b0fc0,%eax
c0105133:	c1 e8 10             	shr    $0x10,%eax
c0105136:	a2 4c ca 12 c0       	mov    %al,0xc012ca4c
c010513b:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0105142:	83 e0 f0             	and    $0xfffffff0,%eax
c0105145:	83 c8 09             	or     $0x9,%eax
c0105148:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c010514d:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0105154:	83 e0 ef             	and    $0xffffffef,%eax
c0105157:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c010515c:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0105163:	83 e0 9f             	and    $0xffffff9f,%eax
c0105166:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c010516b:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0105172:	83 c8 80             	or     $0xffffff80,%eax
c0105175:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c010517a:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c0105181:	83 e0 f0             	and    $0xfffffff0,%eax
c0105184:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c0105189:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c0105190:	83 e0 ef             	and    $0xffffffef,%eax
c0105193:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c0105198:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c010519f:	83 e0 df             	and    $0xffffffdf,%eax
c01051a2:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c01051a7:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c01051ae:	83 c8 40             	or     $0x40,%eax
c01051b1:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c01051b6:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c01051bd:	83 e0 7f             	and    $0x7f,%eax
c01051c0:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c01051c5:	b8 c0 0f 1b c0       	mov    $0xc01b0fc0,%eax
c01051ca:	c1 e8 18             	shr    $0x18,%eax
c01051cd:	a2 4f ca 12 c0       	mov    %al,0xc012ca4f

    // reload all segment registers
    lgdt(&gdt_pd);
c01051d2:	c7 04 24 50 ca 12 c0 	movl   $0xc012ca50,(%esp)
c01051d9:	e8 de fe ff ff       	call   c01050bc <lgdt>
c01051de:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01051e4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01051e8:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01051eb:	c9                   	leave  
c01051ec:	c3                   	ret    

c01051ed <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01051ed:	55                   	push   %ebp
c01051ee:	89 e5                	mov    %esp,%ebp
c01051f0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01051f3:	c7 05 fc 30 1b c0 c0 	movl   $0xc010d1c0,0xc01b30fc
c01051fa:	d1 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01051fd:	a1 fc 30 1b c0       	mov    0xc01b30fc,%eax
c0105202:	8b 00                	mov    (%eax),%eax
c0105204:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105208:	c7 04 24 4c d3 10 c0 	movl   $0xc010d34c,(%esp)
c010520f:	e8 50 b1 ff ff       	call   c0100364 <cprintf>
    pmm_manager->init();
c0105214:	a1 fc 30 1b c0       	mov    0xc01b30fc,%eax
c0105219:	8b 40 04             	mov    0x4(%eax),%eax
c010521c:	ff d0                	call   *%eax
}
c010521e:	c9                   	leave  
c010521f:	c3                   	ret    

c0105220 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0105220:	55                   	push   %ebp
c0105221:	89 e5                	mov    %esp,%ebp
c0105223:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0105226:	a1 fc 30 1b c0       	mov    0xc01b30fc,%eax
c010522b:	8b 40 08             	mov    0x8(%eax),%eax
c010522e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105231:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105235:	8b 55 08             	mov    0x8(%ebp),%edx
c0105238:	89 14 24             	mov    %edx,(%esp)
c010523b:	ff d0                	call   *%eax
}
c010523d:	c9                   	leave  
c010523e:	c3                   	ret    

c010523f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010523f:	55                   	push   %ebp
c0105240:	89 e5                	mov    %esp,%ebp
c0105242:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0105245:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010524c:	e8 2e fe ff ff       	call   c010507f <__intr_save>
c0105251:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0105254:	a1 fc 30 1b c0       	mov    0xc01b30fc,%eax
c0105259:	8b 40 0c             	mov    0xc(%eax),%eax
c010525c:	8b 55 08             	mov    0x8(%ebp),%edx
c010525f:	89 14 24             	mov    %edx,(%esp)
c0105262:	ff d0                	call   *%eax
c0105264:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0105267:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010526a:	89 04 24             	mov    %eax,(%esp)
c010526d:	e8 37 fe ff ff       	call   c01050a9 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0105272:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105276:	75 2d                	jne    c01052a5 <alloc_pages+0x66>
c0105278:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010527c:	77 27                	ja     c01052a5 <alloc_pages+0x66>
c010527e:	a1 2c 10 1b c0       	mov    0xc01b102c,%eax
c0105283:	85 c0                	test   %eax,%eax
c0105285:	74 1e                	je     c01052a5 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0105287:	8b 55 08             	mov    0x8(%ebp),%edx
c010528a:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c010528f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105296:	00 
c0105297:	89 54 24 04          	mov    %edx,0x4(%esp)
c010529b:	89 04 24             	mov    %eax,(%esp)
c010529e:	e8 19 1d 00 00       	call   c0106fbc <swap_out>
    }
c01052a3:	eb a7                	jmp    c010524c <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01052a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01052a8:	c9                   	leave  
c01052a9:	c3                   	ret    

c01052aa <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01052aa:	55                   	push   %ebp
c01052ab:	89 e5                	mov    %esp,%ebp
c01052ad:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01052b0:	e8 ca fd ff ff       	call   c010507f <__intr_save>
c01052b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01052b8:	a1 fc 30 1b c0       	mov    0xc01b30fc,%eax
c01052bd:	8b 40 10             	mov    0x10(%eax),%eax
c01052c0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01052c3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052c7:	8b 55 08             	mov    0x8(%ebp),%edx
c01052ca:	89 14 24             	mov    %edx,(%esp)
c01052cd:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01052cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052d2:	89 04 24             	mov    %eax,(%esp)
c01052d5:	e8 cf fd ff ff       	call   c01050a9 <__intr_restore>
}
c01052da:	c9                   	leave  
c01052db:	c3                   	ret    

c01052dc <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01052dc:	55                   	push   %ebp
c01052dd:	89 e5                	mov    %esp,%ebp
c01052df:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01052e2:	e8 98 fd ff ff       	call   c010507f <__intr_save>
c01052e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01052ea:	a1 fc 30 1b c0       	mov    0xc01b30fc,%eax
c01052ef:	8b 40 14             	mov    0x14(%eax),%eax
c01052f2:	ff d0                	call   *%eax
c01052f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01052f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052fa:	89 04 24             	mov    %eax,(%esp)
c01052fd:	e8 a7 fd ff ff       	call   c01050a9 <__intr_restore>
    return ret;
c0105302:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0105305:	c9                   	leave  
c0105306:	c3                   	ret    

c0105307 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0105307:	55                   	push   %ebp
c0105308:	89 e5                	mov    %esp,%ebp
c010530a:	57                   	push   %edi
c010530b:	56                   	push   %esi
c010530c:	53                   	push   %ebx
c010530d:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0105313:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010531a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105321:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0105328:	c7 04 24 63 d3 10 c0 	movl   $0xc010d363,(%esp)
c010532f:	e8 30 b0 ff ff       	call   c0100364 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105334:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010533b:	e9 15 01 00 00       	jmp    c0105455 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105340:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105343:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105346:	89 d0                	mov    %edx,%eax
c0105348:	c1 e0 02             	shl    $0x2,%eax
c010534b:	01 d0                	add    %edx,%eax
c010534d:	c1 e0 02             	shl    $0x2,%eax
c0105350:	01 c8                	add    %ecx,%eax
c0105352:	8b 50 08             	mov    0x8(%eax),%edx
c0105355:	8b 40 04             	mov    0x4(%eax),%eax
c0105358:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010535b:	89 55 bc             	mov    %edx,-0x44(%ebp)
c010535e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105361:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105364:	89 d0                	mov    %edx,%eax
c0105366:	c1 e0 02             	shl    $0x2,%eax
c0105369:	01 d0                	add    %edx,%eax
c010536b:	c1 e0 02             	shl    $0x2,%eax
c010536e:	01 c8                	add    %ecx,%eax
c0105370:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105373:	8b 58 10             	mov    0x10(%eax),%ebx
c0105376:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105379:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010537c:	01 c8                	add    %ecx,%eax
c010537e:	11 da                	adc    %ebx,%edx
c0105380:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0105383:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0105386:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105389:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010538c:	89 d0                	mov    %edx,%eax
c010538e:	c1 e0 02             	shl    $0x2,%eax
c0105391:	01 d0                	add    %edx,%eax
c0105393:	c1 e0 02             	shl    $0x2,%eax
c0105396:	01 c8                	add    %ecx,%eax
c0105398:	83 c0 14             	add    $0x14,%eax
c010539b:	8b 00                	mov    (%eax),%eax
c010539d:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01053a3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01053a6:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01053a9:	83 c0 ff             	add    $0xffffffff,%eax
c01053ac:	83 d2 ff             	adc    $0xffffffff,%edx
c01053af:	89 c6                	mov    %eax,%esi
c01053b1:	89 d7                	mov    %edx,%edi
c01053b3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053b9:	89 d0                	mov    %edx,%eax
c01053bb:	c1 e0 02             	shl    $0x2,%eax
c01053be:	01 d0                	add    %edx,%eax
c01053c0:	c1 e0 02             	shl    $0x2,%eax
c01053c3:	01 c8                	add    %ecx,%eax
c01053c5:	8b 48 0c             	mov    0xc(%eax),%ecx
c01053c8:	8b 58 10             	mov    0x10(%eax),%ebx
c01053cb:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01053d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01053d5:	89 74 24 14          	mov    %esi,0x14(%esp)
c01053d9:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01053dd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01053e0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01053e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01053e7:	89 54 24 10          	mov    %edx,0x10(%esp)
c01053eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01053ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01053f3:	c7 04 24 70 d3 10 c0 	movl   $0xc010d370,(%esp)
c01053fa:	e8 65 af ff ff       	call   c0100364 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01053ff:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105402:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105405:	89 d0                	mov    %edx,%eax
c0105407:	c1 e0 02             	shl    $0x2,%eax
c010540a:	01 d0                	add    %edx,%eax
c010540c:	c1 e0 02             	shl    $0x2,%eax
c010540f:	01 c8                	add    %ecx,%eax
c0105411:	83 c0 14             	add    $0x14,%eax
c0105414:	8b 00                	mov    (%eax),%eax
c0105416:	83 f8 01             	cmp    $0x1,%eax
c0105419:	75 36                	jne    c0105451 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c010541b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010541e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105421:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0105424:	77 2b                	ja     c0105451 <page_init+0x14a>
c0105426:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0105429:	72 05                	jb     c0105430 <page_init+0x129>
c010542b:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010542e:	73 21                	jae    c0105451 <page_init+0x14a>
c0105430:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105434:	77 1b                	ja     c0105451 <page_init+0x14a>
c0105436:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010543a:	72 09                	jb     c0105445 <page_init+0x13e>
c010543c:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0105443:	77 0c                	ja     c0105451 <page_init+0x14a>
                maxpa = end;
c0105445:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105448:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010544b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010544e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105451:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0105455:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105458:	8b 00                	mov    (%eax),%eax
c010545a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010545d:	0f 8f dd fe ff ff    	jg     c0105340 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0105463:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105467:	72 1d                	jb     c0105486 <page_init+0x17f>
c0105469:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010546d:	77 09                	ja     c0105478 <page_init+0x171>
c010546f:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0105476:	76 0e                	jbe    c0105486 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0105478:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010547f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0105486:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105489:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010548c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105490:	c1 ea 0c             	shr    $0xc,%edx
c0105493:	a3 a0 0f 1b c0       	mov    %eax,0xc01b0fa0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0105498:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c010549f:	b8 f8 31 1b c0       	mov    $0xc01b31f8,%eax
c01054a4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01054a7:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01054aa:	01 d0                	add    %edx,%eax
c01054ac:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01054af:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01054b2:	ba 00 00 00 00       	mov    $0x0,%edx
c01054b7:	f7 75 ac             	divl   -0x54(%ebp)
c01054ba:	89 d0                	mov    %edx,%eax
c01054bc:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01054bf:	29 c2                	sub    %eax,%edx
c01054c1:	89 d0                	mov    %edx,%eax
c01054c3:	a3 04 31 1b c0       	mov    %eax,0xc01b3104

    for (i = 0; i < npage; i ++) {
c01054c8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01054cf:	eb 27                	jmp    c01054f8 <page_init+0x1f1>
        SetPageReserved(pages + i);
c01054d1:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c01054d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01054d9:	c1 e2 05             	shl    $0x5,%edx
c01054dc:	01 d0                	add    %edx,%eax
c01054de:	83 c0 04             	add    $0x4,%eax
c01054e1:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01054e8:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01054eb:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01054ee:	8b 55 90             	mov    -0x70(%ebp),%edx
c01054f1:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01054f4:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01054f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01054fb:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0105500:	39 c2                	cmp    %eax,%edx
c0105502:	72 cd                	jb     c01054d1 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0105504:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0105509:	c1 e0 05             	shl    $0x5,%eax
c010550c:	89 c2                	mov    %eax,%edx
c010550e:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0105513:	01 d0                	add    %edx,%eax
c0105515:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0105518:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c010551f:	77 23                	ja     c0105544 <page_init+0x23d>
c0105521:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105524:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105528:	c7 44 24 08 a0 d3 10 	movl   $0xc010d3a0,0x8(%esp)
c010552f:	c0 
c0105530:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0105537:	00 
c0105538:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010553f:	e8 ac b8 ff ff       	call   c0100df0 <__panic>
c0105544:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105547:	05 00 00 00 40       	add    $0x40000000,%eax
c010554c:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010554f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105556:	e9 74 01 00 00       	jmp    c01056cf <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010555b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010555e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105561:	89 d0                	mov    %edx,%eax
c0105563:	c1 e0 02             	shl    $0x2,%eax
c0105566:	01 d0                	add    %edx,%eax
c0105568:	c1 e0 02             	shl    $0x2,%eax
c010556b:	01 c8                	add    %ecx,%eax
c010556d:	8b 50 08             	mov    0x8(%eax),%edx
c0105570:	8b 40 04             	mov    0x4(%eax),%eax
c0105573:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105576:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105579:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010557c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010557f:	89 d0                	mov    %edx,%eax
c0105581:	c1 e0 02             	shl    $0x2,%eax
c0105584:	01 d0                	add    %edx,%eax
c0105586:	c1 e0 02             	shl    $0x2,%eax
c0105589:	01 c8                	add    %ecx,%eax
c010558b:	8b 48 0c             	mov    0xc(%eax),%ecx
c010558e:	8b 58 10             	mov    0x10(%eax),%ebx
c0105591:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105594:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105597:	01 c8                	add    %ecx,%eax
c0105599:	11 da                	adc    %ebx,%edx
c010559b:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010559e:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01055a1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01055a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055a7:	89 d0                	mov    %edx,%eax
c01055a9:	c1 e0 02             	shl    $0x2,%eax
c01055ac:	01 d0                	add    %edx,%eax
c01055ae:	c1 e0 02             	shl    $0x2,%eax
c01055b1:	01 c8                	add    %ecx,%eax
c01055b3:	83 c0 14             	add    $0x14,%eax
c01055b6:	8b 00                	mov    (%eax),%eax
c01055b8:	83 f8 01             	cmp    $0x1,%eax
c01055bb:	0f 85 0a 01 00 00    	jne    c01056cb <page_init+0x3c4>
            if (begin < freemem) {
c01055c1:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01055c4:	ba 00 00 00 00       	mov    $0x0,%edx
c01055c9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01055cc:	72 17                	jb     c01055e5 <page_init+0x2de>
c01055ce:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01055d1:	77 05                	ja     c01055d8 <page_init+0x2d1>
c01055d3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01055d6:	76 0d                	jbe    c01055e5 <page_init+0x2de>
                begin = freemem;
c01055d8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01055db:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01055de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01055e5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01055e9:	72 1d                	jb     c0105608 <page_init+0x301>
c01055eb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01055ef:	77 09                	ja     c01055fa <page_init+0x2f3>
c01055f1:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01055f8:	76 0e                	jbe    c0105608 <page_init+0x301>
                end = KMEMSIZE;
c01055fa:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0105601:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0105608:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010560b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010560e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105611:	0f 87 b4 00 00 00    	ja     c01056cb <page_init+0x3c4>
c0105617:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010561a:	72 09                	jb     c0105625 <page_init+0x31e>
c010561c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010561f:	0f 83 a6 00 00 00    	jae    c01056cb <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0105625:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c010562c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010562f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105632:	01 d0                	add    %edx,%eax
c0105634:	83 e8 01             	sub    $0x1,%eax
c0105637:	89 45 98             	mov    %eax,-0x68(%ebp)
c010563a:	8b 45 98             	mov    -0x68(%ebp),%eax
c010563d:	ba 00 00 00 00       	mov    $0x0,%edx
c0105642:	f7 75 9c             	divl   -0x64(%ebp)
c0105645:	89 d0                	mov    %edx,%eax
c0105647:	8b 55 98             	mov    -0x68(%ebp),%edx
c010564a:	29 c2                	sub    %eax,%edx
c010564c:	89 d0                	mov    %edx,%eax
c010564e:	ba 00 00 00 00       	mov    $0x0,%edx
c0105653:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105656:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0105659:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010565c:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010565f:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105662:	ba 00 00 00 00       	mov    $0x0,%edx
c0105667:	89 c7                	mov    %eax,%edi
c0105669:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010566f:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0105672:	89 d0                	mov    %edx,%eax
c0105674:	83 e0 00             	and    $0x0,%eax
c0105677:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010567a:	8b 45 80             	mov    -0x80(%ebp),%eax
c010567d:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105680:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105683:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0105686:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105689:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010568c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010568f:	77 3a                	ja     c01056cb <page_init+0x3c4>
c0105691:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105694:	72 05                	jb     c010569b <page_init+0x394>
c0105696:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105699:	73 30                	jae    c01056cb <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010569b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010569e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01056a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01056a4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01056a7:	29 c8                	sub    %ecx,%eax
c01056a9:	19 da                	sbb    %ebx,%edx
c01056ab:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01056af:	c1 ea 0c             	shr    $0xc,%edx
c01056b2:	89 c3                	mov    %eax,%ebx
c01056b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01056b7:	89 04 24             	mov    %eax,(%esp)
c01056ba:	e8 8c f8 ff ff       	call   c0104f4b <pa2page>
c01056bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01056c3:	89 04 24             	mov    %eax,(%esp)
c01056c6:	e8 55 fb ff ff       	call   c0105220 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01056cb:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01056cf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01056d2:	8b 00                	mov    (%eax),%eax
c01056d4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01056d7:	0f 8f 7e fe ff ff    	jg     c010555b <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01056dd:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01056e3:	5b                   	pop    %ebx
c01056e4:	5e                   	pop    %esi
c01056e5:	5f                   	pop    %edi
c01056e6:	5d                   	pop    %ebp
c01056e7:	c3                   	ret    

c01056e8 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01056e8:	55                   	push   %ebp
c01056e9:	89 e5                	mov    %esp,%ebp
c01056eb:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01056ee:	8b 45 14             	mov    0x14(%ebp),%eax
c01056f1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01056f4:	31 d0                	xor    %edx,%eax
c01056f6:	25 ff 0f 00 00       	and    $0xfff,%eax
c01056fb:	85 c0                	test   %eax,%eax
c01056fd:	74 24                	je     c0105723 <boot_map_segment+0x3b>
c01056ff:	c7 44 24 0c d2 d3 10 	movl   $0xc010d3d2,0xc(%esp)
c0105706:	c0 
c0105707:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010570e:	c0 
c010570f:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0105716:	00 
c0105717:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010571e:	e8 cd b6 ff ff       	call   c0100df0 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0105723:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010572a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010572d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105732:	89 c2                	mov    %eax,%edx
c0105734:	8b 45 10             	mov    0x10(%ebp),%eax
c0105737:	01 c2                	add    %eax,%edx
c0105739:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010573c:	01 d0                	add    %edx,%eax
c010573e:	83 e8 01             	sub    $0x1,%eax
c0105741:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105744:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105747:	ba 00 00 00 00       	mov    $0x0,%edx
c010574c:	f7 75 f0             	divl   -0x10(%ebp)
c010574f:	89 d0                	mov    %edx,%eax
c0105751:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105754:	29 c2                	sub    %eax,%edx
c0105756:	89 d0                	mov    %edx,%eax
c0105758:	c1 e8 0c             	shr    $0xc,%eax
c010575b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010575e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105761:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105764:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105767:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010576c:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010576f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105772:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105775:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105778:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010577d:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0105780:	eb 6b                	jmp    c01057ed <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0105782:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105789:	00 
c010578a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010578d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105791:	8b 45 08             	mov    0x8(%ebp),%eax
c0105794:	89 04 24             	mov    %eax,(%esp)
c0105797:	e8 87 01 00 00       	call   c0105923 <get_pte>
c010579c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010579f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01057a3:	75 24                	jne    c01057c9 <boot_map_segment+0xe1>
c01057a5:	c7 44 24 0c fe d3 10 	movl   $0xc010d3fe,0xc(%esp)
c01057ac:	c0 
c01057ad:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01057b4:	c0 
c01057b5:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01057bc:	00 
c01057bd:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01057c4:	e8 27 b6 ff ff       	call   c0100df0 <__panic>
        *ptep = pa | PTE_P | perm;
c01057c9:	8b 45 18             	mov    0x18(%ebp),%eax
c01057cc:	8b 55 14             	mov    0x14(%ebp),%edx
c01057cf:	09 d0                	or     %edx,%eax
c01057d1:	83 c8 01             	or     $0x1,%eax
c01057d4:	89 c2                	mov    %eax,%edx
c01057d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057d9:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01057db:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01057df:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01057e6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01057ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01057f1:	75 8f                	jne    c0105782 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c01057f3:	c9                   	leave  
c01057f4:	c3                   	ret    

c01057f5 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01057f5:	55                   	push   %ebp
c01057f6:	89 e5                	mov    %esp,%ebp
c01057f8:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01057fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105802:	e8 38 fa ff ff       	call   c010523f <alloc_pages>
c0105807:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010580a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010580e:	75 1c                	jne    c010582c <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105810:	c7 44 24 08 0b d4 10 	movl   $0xc010d40b,0x8(%esp)
c0105817:	c0 
c0105818:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c010581f:	00 
c0105820:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105827:	e8 c4 b5 ff ff       	call   c0100df0 <__panic>
    }
    return page2kva(p);
c010582c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010582f:	89 04 24             	mov    %eax,(%esp)
c0105832:	e8 59 f7 ff ff       	call   c0104f90 <page2kva>
}
c0105837:	c9                   	leave  
c0105838:	c3                   	ret    

c0105839 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0105839:	55                   	push   %ebp
c010583a:	89 e5                	mov    %esp,%ebp
c010583c:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010583f:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0105844:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105847:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010584e:	77 23                	ja     c0105873 <pmm_init+0x3a>
c0105850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105853:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105857:	c7 44 24 08 a0 d3 10 	movl   $0xc010d3a0,0x8(%esp)
c010585e:	c0 
c010585f:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0105866:	00 
c0105867:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010586e:	e8 7d b5 ff ff       	call   c0100df0 <__panic>
c0105873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105876:	05 00 00 00 40       	add    $0x40000000,%eax
c010587b:	a3 00 31 1b c0       	mov    %eax,0xc01b3100
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0105880:	e8 68 f9 ff ff       	call   c01051ed <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0105885:	e8 7d fa ff ff       	call   c0105307 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010588a:	e8 d2 08 00 00       	call   c0106161 <check_alloc_page>

    check_pgdir();
c010588f:	e8 eb 08 00 00       	call   c010617f <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0105894:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0105899:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010589f:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01058a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058a7:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01058ae:	77 23                	ja     c01058d3 <pmm_init+0x9a>
c01058b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058b7:	c7 44 24 08 a0 d3 10 	movl   $0xc010d3a0,0x8(%esp)
c01058be:	c0 
c01058bf:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01058c6:	00 
c01058c7:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01058ce:	e8 1d b5 ff ff       	call   c0100df0 <__panic>
c01058d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058d6:	05 00 00 00 40       	add    $0x40000000,%eax
c01058db:	83 c8 03             	or     $0x3,%eax
c01058de:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01058e0:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01058e5:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01058ec:	00 
c01058ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01058f4:	00 
c01058f5:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01058fc:	38 
c01058fd:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0105904:	c0 
c0105905:	89 04 24             	mov    %eax,(%esp)
c0105908:	e8 db fd ff ff       	call   c01056e8 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010590d:	e8 ec f7 ff ff       	call   c01050fe <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0105912:	e8 03 0f 00 00       	call   c010681a <check_boot_pgdir>

    print_pgdir();
c0105917:	e8 8b 13 00 00       	call   c0106ca7 <print_pgdir>
    
    kmalloc_init();
c010591c:	e8 69 f3 ff ff       	call   c0104c8a <kmalloc_init>

}
c0105921:	c9                   	leave  
c0105922:	c3                   	ret    

c0105923 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0105923:	55                   	push   %ebp
c0105924:	89 e5                	mov    %esp,%ebp
c0105926:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0105929:	8b 45 0c             	mov    0xc(%ebp),%eax
c010592c:	c1 e8 16             	shr    $0x16,%eax
c010592f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105936:	8b 45 08             	mov    0x8(%ebp),%eax
c0105939:	01 d0                	add    %edx,%eax
c010593b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c010593e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105941:	8b 00                	mov    (%eax),%eax
c0105943:	83 e0 01             	and    $0x1,%eax
c0105946:	85 c0                	test   %eax,%eax
c0105948:	0f 85 af 00 00 00    	jne    c01059fd <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c010594e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105952:	74 15                	je     c0105969 <get_pte+0x46>
c0105954:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010595b:	e8 df f8 ff ff       	call   c010523f <alloc_pages>
c0105960:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105963:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105967:	75 0a                	jne    c0105973 <get_pte+0x50>
            return NULL;
c0105969:	b8 00 00 00 00       	mov    $0x0,%eax
c010596e:	e9 e6 00 00 00       	jmp    c0105a59 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c0105973:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010597a:	00 
c010597b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010597e:	89 04 24             	mov    %eax,(%esp)
c0105981:	e8 be f6 ff ff       	call   c0105044 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0105986:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105989:	89 04 24             	mov    %eax,(%esp)
c010598c:	e8 a4 f5 ff ff       	call   c0104f35 <page2pa>
c0105991:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0105994:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105997:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010599a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010599d:	c1 e8 0c             	shr    $0xc,%eax
c01059a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01059a3:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c01059a8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01059ab:	72 23                	jb     c01059d0 <get_pte+0xad>
c01059ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059b4:	c7 44 24 08 fc d2 10 	movl   $0xc010d2fc,0x8(%esp)
c01059bb:	c0 
c01059bc:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c01059c3:	00 
c01059c4:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01059cb:	e8 20 b4 ff ff       	call   c0100df0 <__panic>
c01059d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059d3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01059d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01059df:	00 
c01059e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01059e7:	00 
c01059e8:	89 04 24             	mov    %eax,(%esp)
c01059eb:	e8 51 69 00 00       	call   c010c341 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c01059f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059f3:	83 c8 07             	or     $0x7,%eax
c01059f6:	89 c2                	mov    %eax,%edx
c01059f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059fb:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01059fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a00:	8b 00                	mov    (%eax),%eax
c0105a02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a07:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105a0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a0d:	c1 e8 0c             	shr    $0xc,%eax
c0105a10:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105a13:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0105a18:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105a1b:	72 23                	jb     c0105a40 <get_pte+0x11d>
c0105a1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a24:	c7 44 24 08 fc d2 10 	movl   $0xc010d2fc,0x8(%esp)
c0105a2b:	c0 
c0105a2c:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c0105a33:	00 
c0105a34:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105a3b:	e8 b0 b3 ff ff       	call   c0100df0 <__panic>
c0105a40:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a43:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105a48:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a4b:	c1 ea 0c             	shr    $0xc,%edx
c0105a4e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0105a54:	c1 e2 02             	shl    $0x2,%edx
c0105a57:	01 d0                	add    %edx,%eax
}
c0105a59:	c9                   	leave  
c0105a5a:	c3                   	ret    

c0105a5b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105a5b:	55                   	push   %ebp
c0105a5c:	89 e5                	mov    %esp,%ebp
c0105a5e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105a61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105a68:	00 
c0105a69:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a70:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a73:	89 04 24             	mov    %eax,(%esp)
c0105a76:	e8 a8 fe ff ff       	call   c0105923 <get_pte>
c0105a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0105a7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a82:	74 08                	je     c0105a8c <get_page+0x31>
        *ptep_store = ptep;
c0105a84:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a8a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105a8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a90:	74 1b                	je     c0105aad <get_page+0x52>
c0105a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a95:	8b 00                	mov    (%eax),%eax
c0105a97:	83 e0 01             	and    $0x1,%eax
c0105a9a:	85 c0                	test   %eax,%eax
c0105a9c:	74 0f                	je     c0105aad <get_page+0x52>
        return pte2page(*ptep);
c0105a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa1:	8b 00                	mov    (%eax),%eax
c0105aa3:	89 04 24             	mov    %eax,(%esp)
c0105aa6:	e8 39 f5 ff ff       	call   c0104fe4 <pte2page>
c0105aab:	eb 05                	jmp    c0105ab2 <get_page+0x57>
    }
    return NULL;
c0105aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ab2:	c9                   	leave  
c0105ab3:	c3                   	ret    

c0105ab4 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105ab4:	55                   	push   %ebp
c0105ab5:	89 e5                	mov    %esp,%ebp
c0105ab7:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0105aba:	8b 45 10             	mov    0x10(%ebp),%eax
c0105abd:	8b 00                	mov    (%eax),%eax
c0105abf:	83 e0 01             	and    $0x1,%eax
c0105ac2:	85 c0                	test   %eax,%eax
c0105ac4:	74 4d                	je     c0105b13 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0105ac6:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ac9:	8b 00                	mov    (%eax),%eax
c0105acb:	89 04 24             	mov    %eax,(%esp)
c0105ace:	e8 11 f5 ff ff       	call   c0104fe4 <pte2page>
c0105ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ad9:	89 04 24             	mov    %eax,(%esp)
c0105adc:	e8 87 f5 ff ff       	call   c0105068 <page_ref_dec>
c0105ae1:	85 c0                	test   %eax,%eax
c0105ae3:	75 13                	jne    c0105af8 <page_remove_pte+0x44>
            free_page(page);
c0105ae5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105aec:	00 
c0105aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105af0:	89 04 24             	mov    %eax,(%esp)
c0105af3:	e8 b2 f7 ff ff       	call   c01052aa <free_pages>
        }
        *ptep = 0;
c0105af8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105afb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0105b01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0b:	89 04 24             	mov    %eax,(%esp)
c0105b0e:	e8 1d 05 00 00       	call   c0106030 <tlb_invalidate>
    }
}
c0105b13:	c9                   	leave  
c0105b14:	c3                   	ret    

c0105b15 <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105b15:	55                   	push   %ebp
c0105b16:	89 e5                	mov    %esp,%ebp
c0105b18:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b1e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b23:	85 c0                	test   %eax,%eax
c0105b25:	75 0c                	jne    c0105b33 <unmap_range+0x1e>
c0105b27:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b2a:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b2f:	85 c0                	test   %eax,%eax
c0105b31:	74 24                	je     c0105b57 <unmap_range+0x42>
c0105b33:	c7 44 24 0c 24 d4 10 	movl   $0xc010d424,0xc(%esp)
c0105b3a:	c0 
c0105b3b:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105b42:	c0 
c0105b43:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
c0105b4a:	00 
c0105b4b:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105b52:	e8 99 b2 ff ff       	call   c0100df0 <__panic>
    assert(USER_ACCESS(start, end));
c0105b57:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105b5e:	76 11                	jbe    c0105b71 <unmap_range+0x5c>
c0105b60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b63:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105b66:	73 09                	jae    c0105b71 <unmap_range+0x5c>
c0105b68:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105b6f:	76 24                	jbe    c0105b95 <unmap_range+0x80>
c0105b71:	c7 44 24 0c 4d d4 10 	movl   $0xc010d44d,0xc(%esp)
c0105b78:	c0 
c0105b79:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105b80:	c0 
c0105b81:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
c0105b88:	00 
c0105b89:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105b90:	e8 5b b2 ff ff       	call   c0100df0 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0105b95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b9c:	00 
c0105b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ba4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ba7:	89 04 24             	mov    %eax,(%esp)
c0105baa:	e8 74 fd ff ff       	call   c0105923 <get_pte>
c0105baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105bb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105bb6:	75 18                	jne    c0105bd0 <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bbb:	05 00 00 40 00       	add    $0x400000,%eax
c0105bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bc6:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105bcb:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0105bce:	eb 29                	jmp    c0105bf9 <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0105bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bd3:	8b 00                	mov    (%eax),%eax
c0105bd5:	85 c0                	test   %eax,%eax
c0105bd7:	74 19                	je     c0105bf2 <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0105bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bdc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105be0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105be3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105be7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bea:	89 04 24             	mov    %eax,(%esp)
c0105bed:	e8 c2 fe ff ff       	call   c0105ab4 <page_remove_pte>
        }
        start += PGSIZE;
c0105bf2:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105bf9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105bfd:	74 08                	je     c0105c07 <unmap_range+0xf2>
c0105bff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c02:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c05:	72 8e                	jb     c0105b95 <unmap_range+0x80>
}
c0105c07:	c9                   	leave  
c0105c08:	c3                   	ret    

c0105c09 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105c09:	55                   	push   %ebp
c0105c0a:	89 e5                	mov    %esp,%ebp
c0105c0c:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c12:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c17:	85 c0                	test   %eax,%eax
c0105c19:	75 0c                	jne    c0105c27 <exit_range+0x1e>
c0105c1b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c1e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c23:	85 c0                	test   %eax,%eax
c0105c25:	74 24                	je     c0105c4b <exit_range+0x42>
c0105c27:	c7 44 24 0c 24 d4 10 	movl   $0xc010d424,0xc(%esp)
c0105c2e:	c0 
c0105c2f:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105c36:	c0 
c0105c37:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0105c3e:	00 
c0105c3f:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105c46:	e8 a5 b1 ff ff       	call   c0100df0 <__panic>
    assert(USER_ACCESS(start, end));
c0105c4b:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105c52:	76 11                	jbe    c0105c65 <exit_range+0x5c>
c0105c54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c57:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c5a:	73 09                	jae    c0105c65 <exit_range+0x5c>
c0105c5c:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105c63:	76 24                	jbe    c0105c89 <exit_range+0x80>
c0105c65:	c7 44 24 0c 4d d4 10 	movl   $0xc010d44d,0xc(%esp)
c0105c6c:	c0 
c0105c6d:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105c74:	c0 
c0105c75:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0105c7c:	00 
c0105c7d:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105c84:	e8 67 b1 ff ff       	call   c0100df0 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0105c89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c92:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105c97:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0105c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c9d:	c1 e8 16             	shr    $0x16,%eax
c0105ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ca6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb0:	01 d0                	add    %edx,%eax
c0105cb2:	8b 00                	mov    (%eax),%eax
c0105cb4:	83 e0 01             	and    $0x1,%eax
c0105cb7:	85 c0                	test   %eax,%eax
c0105cb9:	74 3e                	je     c0105cf9 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0105cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105cc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc8:	01 d0                	add    %edx,%eax
c0105cca:	8b 00                	mov    (%eax),%eax
c0105ccc:	89 04 24             	mov    %eax,(%esp)
c0105ccf:	e8 4e f3 ff ff       	call   c0105022 <pde2page>
c0105cd4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105cdb:	00 
c0105cdc:	89 04 24             	mov    %eax,(%esp)
c0105cdf:	e8 c6 f5 ff ff       	call   c01052aa <free_pages>
            pgdir[pde_idx] = 0;
c0105ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ce7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105cee:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf1:	01 d0                	add    %edx,%eax
c0105cf3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0105cf9:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105d00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105d04:	74 08                	je     c0105d0e <exit_range+0x105>
c0105d06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d09:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105d0c:	72 8c                	jb     c0105c9a <exit_range+0x91>
}
c0105d0e:	c9                   	leave  
c0105d0f:	c3                   	ret    

c0105d10 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105d10:	55                   	push   %ebp
c0105d11:	89 e5                	mov    %esp,%ebp
c0105d13:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105d16:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d19:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d1e:	85 c0                	test   %eax,%eax
c0105d20:	75 0c                	jne    c0105d2e <copy_range+0x1e>
c0105d22:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d25:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d2a:	85 c0                	test   %eax,%eax
c0105d2c:	74 24                	je     c0105d52 <copy_range+0x42>
c0105d2e:	c7 44 24 0c 24 d4 10 	movl   $0xc010d424,0xc(%esp)
c0105d35:	c0 
c0105d36:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105d3d:	c0 
c0105d3e:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0105d45:	00 
c0105d46:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105d4d:	e8 9e b0 ff ff       	call   c0100df0 <__panic>
    assert(USER_ACCESS(start, end));
c0105d52:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0105d59:	76 11                	jbe    c0105d6c <copy_range+0x5c>
c0105d5b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d5e:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105d61:	73 09                	jae    c0105d6c <copy_range+0x5c>
c0105d63:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0105d6a:	76 24                	jbe    c0105d90 <copy_range+0x80>
c0105d6c:	c7 44 24 0c 4d d4 10 	movl   $0xc010d44d,0xc(%esp)
c0105d73:	c0 
c0105d74:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105d7b:	c0 
c0105d7c:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0105d83:	00 
c0105d84:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105d8b:	e8 60 b0 ff ff       	call   c0100df0 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0105d90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105d97:	00 
c0105d98:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105da2:	89 04 24             	mov    %eax,(%esp)
c0105da5:	e8 79 fb ff ff       	call   c0105923 <get_pte>
c0105daa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105dad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105db1:	75 1b                	jne    c0105dce <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105db3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105db6:	05 00 00 40 00       	add    $0x400000,%eax
c0105dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dc1:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105dc6:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0105dc9:	e9 4c 01 00 00       	jmp    c0105f1a <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dd1:	8b 00                	mov    (%eax),%eax
c0105dd3:	83 e0 01             	and    $0x1,%eax
c0105dd6:	85 c0                	test   %eax,%eax
c0105dd8:	0f 84 35 01 00 00    	je     c0105f13 <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105dde:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105de5:	00 
c0105de6:	8b 45 10             	mov    0x10(%ebp),%eax
c0105de9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ded:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df0:	89 04 24             	mov    %eax,(%esp)
c0105df3:	e8 2b fb ff ff       	call   c0105923 <get_pte>
c0105df8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105dfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105dff:	75 0a                	jne    c0105e0b <copy_range+0xfb>
                return -E_NO_MEM;
c0105e01:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105e06:	e9 26 01 00 00       	jmp    c0105f31 <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c0105e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e0e:	8b 00                	mov    (%eax),%eax
c0105e10:	83 e0 07             	and    $0x7,%eax
c0105e13:	89 45 e8             	mov    %eax,-0x18(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c0105e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e19:	8b 00                	mov    (%eax),%eax
c0105e1b:	89 04 24             	mov    %eax,(%esp)
c0105e1e:	e8 c1 f1 ff ff       	call   c0104fe4 <pte2page>
c0105e23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c0105e26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e2d:	e8 0d f4 ff ff       	call   c010523f <alloc_pages>
c0105e32:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(page!=NULL);
c0105e35:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e39:	75 24                	jne    c0105e5f <copy_range+0x14f>
c0105e3b:	c7 44 24 0c 65 d4 10 	movl   $0xc010d465,0xc(%esp)
c0105e42:	c0 
c0105e43:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105e4a:	c0 
c0105e4b:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0105e52:	00 
c0105e53:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105e5a:	e8 91 af ff ff       	call   c0100df0 <__panic>
        assert(npage!=NULL);
c0105e5f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105e63:	75 24                	jne    c0105e89 <copy_range+0x179>
c0105e65:	c7 44 24 0c 70 d4 10 	movl   $0xc010d470,0xc(%esp)
c0105e6c:	c0 
c0105e6d:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105e74:	c0 
c0105e75:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0105e7c:	00 
c0105e7d:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105e84:	e8 67 af ff ff       	call   c0100df0 <__panic>
        int ret=0;
c0105e89:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        void * kva_src = page2kva(page);
c0105e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e93:	89 04 24             	mov    %eax,(%esp)
c0105e96:	e8 f5 f0 ff ff       	call   c0104f90 <page2kva>
c0105e9b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        void * kva_dst = page2kva(npage);
c0105e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ea1:	89 04 24             	mov    %eax,(%esp)
c0105ea4:	e8 e7 f0 ff ff       	call   c0104f90 <page2kva>
c0105ea9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    
        memcpy(kva_dst, kva_src, PGSIZE);
c0105eac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105eb3:	00 
c0105eb4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ebb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105ebe:	89 04 24             	mov    %eax,(%esp)
c0105ec1:	e8 5d 65 00 00       	call   c010c423 <memcpy>

        ret = page_insert(to, npage, start, perm);
c0105ec6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ec9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ecd:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ed0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ed4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105edb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ede:	89 04 24             	mov    %eax,(%esp)
c0105ee1:	e8 91 00 00 00       	call   c0105f77 <page_insert>
c0105ee6:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ret == 0);
c0105ee9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105eed:	74 24                	je     c0105f13 <copy_range+0x203>
c0105eef:	c7 44 24 0c 7c d4 10 	movl   $0xc010d47c,0xc(%esp)
c0105ef6:	c0 
c0105ef7:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0105efe:	c0 
c0105eff:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105f06:	00 
c0105f07:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0105f0e:	e8 dd ae ff ff       	call   c0100df0 <__panic>
        }
        start += PGSIZE;
c0105f13:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105f1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105f1e:	74 0c                	je     c0105f2c <copy_range+0x21c>
c0105f20:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f23:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105f26:	0f 82 64 fe ff ff    	jb     c0105d90 <copy_range+0x80>
    return 0;
c0105f2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f31:	c9                   	leave  
c0105f32:	c3                   	ret    

c0105f33 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105f33:	55                   	push   %ebp
c0105f34:	89 e5                	mov    %esp,%ebp
c0105f36:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105f39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105f40:	00 
c0105f41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f4b:	89 04 24             	mov    %eax,(%esp)
c0105f4e:	e8 d0 f9 ff ff       	call   c0105923 <get_pte>
c0105f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105f56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f5a:	74 19                	je     c0105f75 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f5f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f6d:	89 04 24             	mov    %eax,(%esp)
c0105f70:	e8 3f fb ff ff       	call   c0105ab4 <page_remove_pte>
    }
}
c0105f75:	c9                   	leave  
c0105f76:	c3                   	ret    

c0105f77 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105f77:	55                   	push   %ebp
c0105f78:	89 e5                	mov    %esp,%ebp
c0105f7a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105f7d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105f84:	00 
c0105f85:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f8f:	89 04 24             	mov    %eax,(%esp)
c0105f92:	e8 8c f9 ff ff       	call   c0105923 <get_pte>
c0105f97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105f9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f9e:	75 0a                	jne    c0105faa <page_insert+0x33>
        return -E_NO_MEM;
c0105fa0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105fa5:	e9 84 00 00 00       	jmp    c010602e <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105faa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fad:	89 04 24             	mov    %eax,(%esp)
c0105fb0:	e8 9c f0 ff ff       	call   c0105051 <page_ref_inc>
    if (*ptep & PTE_P) {
c0105fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fb8:	8b 00                	mov    (%eax),%eax
c0105fba:	83 e0 01             	and    $0x1,%eax
c0105fbd:	85 c0                	test   %eax,%eax
c0105fbf:	74 3e                	je     c0105fff <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0105fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fc4:	8b 00                	mov    (%eax),%eax
c0105fc6:	89 04 24             	mov    %eax,(%esp)
c0105fc9:	e8 16 f0 ff ff       	call   c0104fe4 <pte2page>
c0105fce:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fd4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105fd7:	75 0d                	jne    c0105fe6 <page_insert+0x6f>
            page_ref_dec(page);
c0105fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fdc:	89 04 24             	mov    %eax,(%esp)
c0105fdf:	e8 84 f0 ff ff       	call   c0105068 <page_ref_dec>
c0105fe4:	eb 19                	jmp    c0105fff <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fe9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105fed:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ff4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ff7:	89 04 24             	mov    %eax,(%esp)
c0105ffa:	e8 b5 fa ff ff       	call   c0105ab4 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105fff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106002:	89 04 24             	mov    %eax,(%esp)
c0106005:	e8 2b ef ff ff       	call   c0104f35 <page2pa>
c010600a:	0b 45 14             	or     0x14(%ebp),%eax
c010600d:	83 c8 01             	or     $0x1,%eax
c0106010:	89 c2                	mov    %eax,%edx
c0106012:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106015:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0106017:	8b 45 10             	mov    0x10(%ebp),%eax
c010601a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010601e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106021:	89 04 24             	mov    %eax,(%esp)
c0106024:	e8 07 00 00 00       	call   c0106030 <tlb_invalidate>
    return 0;
c0106029:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010602e:	c9                   	leave  
c010602f:	c3                   	ret    

c0106030 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0106030:	55                   	push   %ebp
c0106031:	89 e5                	mov    %esp,%ebp
c0106033:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106036:	0f 20 d8             	mov    %cr3,%eax
c0106039:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010603c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c010603f:	89 c2                	mov    %eax,%edx
c0106041:	8b 45 08             	mov    0x8(%ebp),%eax
c0106044:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106047:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010604e:	77 23                	ja     c0106073 <tlb_invalidate+0x43>
c0106050:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106053:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106057:	c7 44 24 08 a0 d3 10 	movl   $0xc010d3a0,0x8(%esp)
c010605e:	c0 
c010605f:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0106066:	00 
c0106067:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010606e:	e8 7d ad ff ff       	call   c0100df0 <__panic>
c0106073:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106076:	05 00 00 00 40       	add    $0x40000000,%eax
c010607b:	39 c2                	cmp    %eax,%edx
c010607d:	75 0c                	jne    c010608b <tlb_invalidate+0x5b>
        invlpg((void *)la);
c010607f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106082:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0106085:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106088:	0f 01 38             	invlpg (%eax)
    }
}
c010608b:	c9                   	leave  
c010608c:	c3                   	ret    

c010608d <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c010608d:	55                   	push   %ebp
c010608e:	89 e5                	mov    %esp,%ebp
c0106090:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0106093:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010609a:	e8 a0 f1 ff ff       	call   c010523f <alloc_pages>
c010609f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01060a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01060a6:	0f 84 b0 00 00 00    	je     c010615c <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01060ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01060af:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060b6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01060c4:	89 04 24             	mov    %eax,(%esp)
c01060c7:	e8 ab fe ff ff       	call   c0105f77 <page_insert>
c01060cc:	85 c0                	test   %eax,%eax
c01060ce:	74 1a                	je     c01060ea <pgdir_alloc_page+0x5d>
            free_page(page);
c01060d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060d7:	00 
c01060d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060db:	89 04 24             	mov    %eax,(%esp)
c01060de:	e8 c7 f1 ff ff       	call   c01052aa <free_pages>
            return NULL;
c01060e3:	b8 00 00 00 00       	mov    $0x0,%eax
c01060e8:	eb 75                	jmp    c010615f <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c01060ea:	a1 2c 10 1b c0       	mov    0xc01b102c,%eax
c01060ef:	85 c0                	test   %eax,%eax
c01060f1:	74 69                	je     c010615c <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c01060f3:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c01060f8:	85 c0                	test   %eax,%eax
c01060fa:	74 60                	je     c010615c <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c01060fc:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c0106101:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106108:	00 
c0106109:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010610c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106110:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106113:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106117:	89 04 24             	mov    %eax,(%esp)
c010611a:	e8 51 0e 00 00       	call   c0106f70 <swap_map_swappable>
                page->pra_vaddr=la;
c010611f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106122:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106125:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c0106128:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010612b:	89 04 24             	mov    %eax,(%esp)
c010612e:	e8 07 ef ff ff       	call   c010503a <page_ref>
c0106133:	83 f8 01             	cmp    $0x1,%eax
c0106136:	74 24                	je     c010615c <pgdir_alloc_page+0xcf>
c0106138:	c7 44 24 0c 85 d4 10 	movl   $0xc010d485,0xc(%esp)
c010613f:	c0 
c0106140:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106147:	c0 
c0106148:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
c010614f:	00 
c0106150:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106157:	e8 94 ac ff ff       	call   c0100df0 <__panic>
            }
        }

    }

    return page;
c010615c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010615f:	c9                   	leave  
c0106160:	c3                   	ret    

c0106161 <check_alloc_page>:

static void
check_alloc_page(void) {
c0106161:	55                   	push   %ebp
c0106162:	89 e5                	mov    %esp,%ebp
c0106164:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0106167:	a1 fc 30 1b c0       	mov    0xc01b30fc,%eax
c010616c:	8b 40 18             	mov    0x18(%eax),%eax
c010616f:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0106171:	c7 04 24 9c d4 10 c0 	movl   $0xc010d49c,(%esp)
c0106178:	e8 e7 a1 ff ff       	call   c0100364 <cprintf>
}
c010617d:	c9                   	leave  
c010617e:	c3                   	ret    

c010617f <check_pgdir>:

static void
check_pgdir(void) {
c010617f:	55                   	push   %ebp
c0106180:	89 e5                	mov    %esp,%ebp
c0106182:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106185:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c010618a:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010618f:	76 24                	jbe    c01061b5 <check_pgdir+0x36>
c0106191:	c7 44 24 0c bb d4 10 	movl   $0xc010d4bb,0xc(%esp)
c0106198:	c0 
c0106199:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01061a0:	c0 
c01061a1:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c01061a8:	00 
c01061a9:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01061b0:	e8 3b ac ff ff       	call   c0100df0 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01061b5:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01061ba:	85 c0                	test   %eax,%eax
c01061bc:	74 0e                	je     c01061cc <check_pgdir+0x4d>
c01061be:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01061c3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01061c8:	85 c0                	test   %eax,%eax
c01061ca:	74 24                	je     c01061f0 <check_pgdir+0x71>
c01061cc:	c7 44 24 0c d8 d4 10 	movl   $0xc010d4d8,0xc(%esp)
c01061d3:	c0 
c01061d4:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01061db:	c0 
c01061dc:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c01061e3:	00 
c01061e4:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01061eb:	e8 00 ac ff ff       	call   c0100df0 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01061f0:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01061f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01061fc:	00 
c01061fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106204:	00 
c0106205:	89 04 24             	mov    %eax,(%esp)
c0106208:	e8 4e f8 ff ff       	call   c0105a5b <get_page>
c010620d:	85 c0                	test   %eax,%eax
c010620f:	74 24                	je     c0106235 <check_pgdir+0xb6>
c0106211:	c7 44 24 0c 10 d5 10 	movl   $0xc010d510,0xc(%esp)
c0106218:	c0 
c0106219:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106220:	c0 
c0106221:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c0106228:	00 
c0106229:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106230:	e8 bb ab ff ff       	call   c0100df0 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106235:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010623c:	e8 fe ef ff ff       	call   c010523f <alloc_pages>
c0106241:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106244:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106249:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106250:	00 
c0106251:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106258:	00 
c0106259:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010625c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106260:	89 04 24             	mov    %eax,(%esp)
c0106263:	e8 0f fd ff ff       	call   c0105f77 <page_insert>
c0106268:	85 c0                	test   %eax,%eax
c010626a:	74 24                	je     c0106290 <check_pgdir+0x111>
c010626c:	c7 44 24 0c 38 d5 10 	movl   $0xc010d538,0xc(%esp)
c0106273:	c0 
c0106274:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010627b:	c0 
c010627c:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0106283:	00 
c0106284:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010628b:	e8 60 ab ff ff       	call   c0100df0 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106290:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106295:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010629c:	00 
c010629d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01062a4:	00 
c01062a5:	89 04 24             	mov    %eax,(%esp)
c01062a8:	e8 76 f6 ff ff       	call   c0105923 <get_pte>
c01062ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01062b4:	75 24                	jne    c01062da <check_pgdir+0x15b>
c01062b6:	c7 44 24 0c 64 d5 10 	movl   $0xc010d564,0xc(%esp)
c01062bd:	c0 
c01062be:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01062c5:	c0 
c01062c6:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c01062cd:	00 
c01062ce:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01062d5:	e8 16 ab ff ff       	call   c0100df0 <__panic>
    assert(pte2page(*ptep) == p1);
c01062da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062dd:	8b 00                	mov    (%eax),%eax
c01062df:	89 04 24             	mov    %eax,(%esp)
c01062e2:	e8 fd ec ff ff       	call   c0104fe4 <pte2page>
c01062e7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01062ea:	74 24                	je     c0106310 <check_pgdir+0x191>
c01062ec:	c7 44 24 0c 91 d5 10 	movl   $0xc010d591,0xc(%esp)
c01062f3:	c0 
c01062f4:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01062fb:	c0 
c01062fc:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0106303:	00 
c0106304:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010630b:	e8 e0 aa ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p1) == 1);
c0106310:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106313:	89 04 24             	mov    %eax,(%esp)
c0106316:	e8 1f ed ff ff       	call   c010503a <page_ref>
c010631b:	83 f8 01             	cmp    $0x1,%eax
c010631e:	74 24                	je     c0106344 <check_pgdir+0x1c5>
c0106320:	c7 44 24 0c a7 d5 10 	movl   $0xc010d5a7,0xc(%esp)
c0106327:	c0 
c0106328:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010632f:	c0 
c0106330:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
c0106337:	00 
c0106338:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010633f:	e8 ac aa ff ff       	call   c0100df0 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0106344:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106349:	8b 00                	mov    (%eax),%eax
c010634b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106350:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106353:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106356:	c1 e8 0c             	shr    $0xc,%eax
c0106359:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010635c:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0106361:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106364:	72 23                	jb     c0106389 <check_pgdir+0x20a>
c0106366:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106369:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010636d:	c7 44 24 08 fc d2 10 	movl   $0xc010d2fc,0x8(%esp)
c0106374:	c0 
c0106375:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
c010637c:	00 
c010637d:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106384:	e8 67 aa ff ff       	call   c0100df0 <__panic>
c0106389:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010638c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106391:	83 c0 04             	add    $0x4,%eax
c0106394:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106397:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c010639c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01063a3:	00 
c01063a4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01063ab:	00 
c01063ac:	89 04 24             	mov    %eax,(%esp)
c01063af:	e8 6f f5 ff ff       	call   c0105923 <get_pte>
c01063b4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01063b7:	74 24                	je     c01063dd <check_pgdir+0x25e>
c01063b9:	c7 44 24 0c bc d5 10 	movl   $0xc010d5bc,0xc(%esp)
c01063c0:	c0 
c01063c1:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01063c8:	c0 
c01063c9:	c7 44 24 04 7d 02 00 	movl   $0x27d,0x4(%esp)
c01063d0:	00 
c01063d1:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01063d8:	e8 13 aa ff ff       	call   c0100df0 <__panic>

    p2 = alloc_page();
c01063dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01063e4:	e8 56 ee ff ff       	call   c010523f <alloc_pages>
c01063e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01063ec:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01063f1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01063f8:	00 
c01063f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106400:	00 
c0106401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106404:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106408:	89 04 24             	mov    %eax,(%esp)
c010640b:	e8 67 fb ff ff       	call   c0105f77 <page_insert>
c0106410:	85 c0                	test   %eax,%eax
c0106412:	74 24                	je     c0106438 <check_pgdir+0x2b9>
c0106414:	c7 44 24 0c e4 d5 10 	movl   $0xc010d5e4,0xc(%esp)
c010641b:	c0 
c010641c:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106423:	c0 
c0106424:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c010642b:	00 
c010642c:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106433:	e8 b8 a9 ff ff       	call   c0100df0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106438:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c010643d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106444:	00 
c0106445:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010644c:	00 
c010644d:	89 04 24             	mov    %eax,(%esp)
c0106450:	e8 ce f4 ff ff       	call   c0105923 <get_pte>
c0106455:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106458:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010645c:	75 24                	jne    c0106482 <check_pgdir+0x303>
c010645e:	c7 44 24 0c 1c d6 10 	movl   $0xc010d61c,0xc(%esp)
c0106465:	c0 
c0106466:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010646d:	c0 
c010646e:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c0106475:	00 
c0106476:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010647d:	e8 6e a9 ff ff       	call   c0100df0 <__panic>
    assert(*ptep & PTE_U);
c0106482:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106485:	8b 00                	mov    (%eax),%eax
c0106487:	83 e0 04             	and    $0x4,%eax
c010648a:	85 c0                	test   %eax,%eax
c010648c:	75 24                	jne    c01064b2 <check_pgdir+0x333>
c010648e:	c7 44 24 0c 4c d6 10 	movl   $0xc010d64c,0xc(%esp)
c0106495:	c0 
c0106496:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010649d:	c0 
c010649e:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c01064a5:	00 
c01064a6:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01064ad:	e8 3e a9 ff ff       	call   c0100df0 <__panic>
    assert(*ptep & PTE_W);
c01064b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064b5:	8b 00                	mov    (%eax),%eax
c01064b7:	83 e0 02             	and    $0x2,%eax
c01064ba:	85 c0                	test   %eax,%eax
c01064bc:	75 24                	jne    c01064e2 <check_pgdir+0x363>
c01064be:	c7 44 24 0c 5a d6 10 	movl   $0xc010d65a,0xc(%esp)
c01064c5:	c0 
c01064c6:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01064cd:	c0 
c01064ce:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
c01064d5:	00 
c01064d6:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01064dd:	e8 0e a9 ff ff       	call   c0100df0 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01064e2:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01064e7:	8b 00                	mov    (%eax),%eax
c01064e9:	83 e0 04             	and    $0x4,%eax
c01064ec:	85 c0                	test   %eax,%eax
c01064ee:	75 24                	jne    c0106514 <check_pgdir+0x395>
c01064f0:	c7 44 24 0c 68 d6 10 	movl   $0xc010d668,0xc(%esp)
c01064f7:	c0 
c01064f8:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01064ff:	c0 
c0106500:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
c0106507:	00 
c0106508:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010650f:	e8 dc a8 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 1);
c0106514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106517:	89 04 24             	mov    %eax,(%esp)
c010651a:	e8 1b eb ff ff       	call   c010503a <page_ref>
c010651f:	83 f8 01             	cmp    $0x1,%eax
c0106522:	74 24                	je     c0106548 <check_pgdir+0x3c9>
c0106524:	c7 44 24 0c 7e d6 10 	movl   $0xc010d67e,0xc(%esp)
c010652b:	c0 
c010652c:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106533:	c0 
c0106534:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
c010653b:	00 
c010653c:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106543:	e8 a8 a8 ff ff       	call   c0100df0 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0106548:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c010654d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106554:	00 
c0106555:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010655c:	00 
c010655d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106560:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106564:	89 04 24             	mov    %eax,(%esp)
c0106567:	e8 0b fa ff ff       	call   c0105f77 <page_insert>
c010656c:	85 c0                	test   %eax,%eax
c010656e:	74 24                	je     c0106594 <check_pgdir+0x415>
c0106570:	c7 44 24 0c 90 d6 10 	movl   $0xc010d690,0xc(%esp)
c0106577:	c0 
c0106578:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010657f:	c0 
c0106580:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
c0106587:	00 
c0106588:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010658f:	e8 5c a8 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p1) == 2);
c0106594:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106597:	89 04 24             	mov    %eax,(%esp)
c010659a:	e8 9b ea ff ff       	call   c010503a <page_ref>
c010659f:	83 f8 02             	cmp    $0x2,%eax
c01065a2:	74 24                	je     c01065c8 <check_pgdir+0x449>
c01065a4:	c7 44 24 0c bc d6 10 	movl   $0xc010d6bc,0xc(%esp)
c01065ab:	c0 
c01065ac:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01065b3:	c0 
c01065b4:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
c01065bb:	00 
c01065bc:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01065c3:	e8 28 a8 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 0);
c01065c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065cb:	89 04 24             	mov    %eax,(%esp)
c01065ce:	e8 67 ea ff ff       	call   c010503a <page_ref>
c01065d3:	85 c0                	test   %eax,%eax
c01065d5:	74 24                	je     c01065fb <check_pgdir+0x47c>
c01065d7:	c7 44 24 0c ce d6 10 	movl   $0xc010d6ce,0xc(%esp)
c01065de:	c0 
c01065df:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01065e6:	c0 
c01065e7:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c01065ee:	00 
c01065ef:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01065f6:	e8 f5 a7 ff ff       	call   c0100df0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01065fb:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106600:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106607:	00 
c0106608:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010660f:	00 
c0106610:	89 04 24             	mov    %eax,(%esp)
c0106613:	e8 0b f3 ff ff       	call   c0105923 <get_pte>
c0106618:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010661b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010661f:	75 24                	jne    c0106645 <check_pgdir+0x4c6>
c0106621:	c7 44 24 0c 1c d6 10 	movl   $0xc010d61c,0xc(%esp)
c0106628:	c0 
c0106629:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106630:	c0 
c0106631:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c0106638:	00 
c0106639:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106640:	e8 ab a7 ff ff       	call   c0100df0 <__panic>
    assert(pte2page(*ptep) == p1);
c0106645:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106648:	8b 00                	mov    (%eax),%eax
c010664a:	89 04 24             	mov    %eax,(%esp)
c010664d:	e8 92 e9 ff ff       	call   c0104fe4 <pte2page>
c0106652:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106655:	74 24                	je     c010667b <check_pgdir+0x4fc>
c0106657:	c7 44 24 0c 91 d5 10 	movl   $0xc010d591,0xc(%esp)
c010665e:	c0 
c010665f:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106666:	c0 
c0106667:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
c010666e:	00 
c010666f:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106676:	e8 75 a7 ff ff       	call   c0100df0 <__panic>
    assert((*ptep & PTE_U) == 0);
c010667b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010667e:	8b 00                	mov    (%eax),%eax
c0106680:	83 e0 04             	and    $0x4,%eax
c0106683:	85 c0                	test   %eax,%eax
c0106685:	74 24                	je     c01066ab <check_pgdir+0x52c>
c0106687:	c7 44 24 0c e0 d6 10 	movl   $0xc010d6e0,0xc(%esp)
c010668e:	c0 
c010668f:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106696:	c0 
c0106697:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
c010669e:	00 
c010669f:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01066a6:	e8 45 a7 ff ff       	call   c0100df0 <__panic>

    page_remove(boot_pgdir, 0x0);
c01066ab:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01066b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01066b7:	00 
c01066b8:	89 04 24             	mov    %eax,(%esp)
c01066bb:	e8 73 f8 ff ff       	call   c0105f33 <page_remove>
    assert(page_ref(p1) == 1);
c01066c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066c3:	89 04 24             	mov    %eax,(%esp)
c01066c6:	e8 6f e9 ff ff       	call   c010503a <page_ref>
c01066cb:	83 f8 01             	cmp    $0x1,%eax
c01066ce:	74 24                	je     c01066f4 <check_pgdir+0x575>
c01066d0:	c7 44 24 0c a7 d5 10 	movl   $0xc010d5a7,0xc(%esp)
c01066d7:	c0 
c01066d8:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01066df:	c0 
c01066e0:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
c01066e7:	00 
c01066e8:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01066ef:	e8 fc a6 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 0);
c01066f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066f7:	89 04 24             	mov    %eax,(%esp)
c01066fa:	e8 3b e9 ff ff       	call   c010503a <page_ref>
c01066ff:	85 c0                	test   %eax,%eax
c0106701:	74 24                	je     c0106727 <check_pgdir+0x5a8>
c0106703:	c7 44 24 0c ce d6 10 	movl   $0xc010d6ce,0xc(%esp)
c010670a:	c0 
c010670b:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106712:	c0 
c0106713:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
c010671a:	00 
c010671b:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106722:	e8 c9 a6 ff ff       	call   c0100df0 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0106727:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c010672c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106733:	00 
c0106734:	89 04 24             	mov    %eax,(%esp)
c0106737:	e8 f7 f7 ff ff       	call   c0105f33 <page_remove>
    assert(page_ref(p1) == 0);
c010673c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010673f:	89 04 24             	mov    %eax,(%esp)
c0106742:	e8 f3 e8 ff ff       	call   c010503a <page_ref>
c0106747:	85 c0                	test   %eax,%eax
c0106749:	74 24                	je     c010676f <check_pgdir+0x5f0>
c010674b:	c7 44 24 0c f5 d6 10 	movl   $0xc010d6f5,0xc(%esp)
c0106752:	c0 
c0106753:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010675a:	c0 
c010675b:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
c0106762:	00 
c0106763:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010676a:	e8 81 a6 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 0);
c010676f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106772:	89 04 24             	mov    %eax,(%esp)
c0106775:	e8 c0 e8 ff ff       	call   c010503a <page_ref>
c010677a:	85 c0                	test   %eax,%eax
c010677c:	74 24                	je     c01067a2 <check_pgdir+0x623>
c010677e:	c7 44 24 0c ce d6 10 	movl   $0xc010d6ce,0xc(%esp)
c0106785:	c0 
c0106786:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c010678d:	c0 
c010678e:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
c0106795:	00 
c0106796:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c010679d:	e8 4e a6 ff ff       	call   c0100df0 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01067a2:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01067a7:	8b 00                	mov    (%eax),%eax
c01067a9:	89 04 24             	mov    %eax,(%esp)
c01067ac:	e8 71 e8 ff ff       	call   c0105022 <pde2page>
c01067b1:	89 04 24             	mov    %eax,(%esp)
c01067b4:	e8 81 e8 ff ff       	call   c010503a <page_ref>
c01067b9:	83 f8 01             	cmp    $0x1,%eax
c01067bc:	74 24                	je     c01067e2 <check_pgdir+0x663>
c01067be:	c7 44 24 0c 08 d7 10 	movl   $0xc010d708,0xc(%esp)
c01067c5:	c0 
c01067c6:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01067cd:	c0 
c01067ce:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
c01067d5:	00 
c01067d6:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01067dd:	e8 0e a6 ff ff       	call   c0100df0 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01067e2:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01067e7:	8b 00                	mov    (%eax),%eax
c01067e9:	89 04 24             	mov    %eax,(%esp)
c01067ec:	e8 31 e8 ff ff       	call   c0105022 <pde2page>
c01067f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01067f8:	00 
c01067f9:	89 04 24             	mov    %eax,(%esp)
c01067fc:	e8 a9 ea ff ff       	call   c01052aa <free_pages>
    boot_pgdir[0] = 0;
c0106801:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106806:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c010680c:	c7 04 24 2f d7 10 c0 	movl   $0xc010d72f,(%esp)
c0106813:	e8 4c 9b ff ff       	call   c0100364 <cprintf>
}
c0106818:	c9                   	leave  
c0106819:	c3                   	ret    

c010681a <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c010681a:	55                   	push   %ebp
c010681b:	89 e5                	mov    %esp,%ebp
c010681d:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106820:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106827:	e9 ca 00 00 00       	jmp    c01068f6 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c010682c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010682f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106832:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106835:	c1 e8 0c             	shr    $0xc,%eax
c0106838:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010683b:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0106840:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106843:	72 23                	jb     c0106868 <check_boot_pgdir+0x4e>
c0106845:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106848:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010684c:	c7 44 24 08 fc d2 10 	movl   $0xc010d2fc,0x8(%esp)
c0106853:	c0 
c0106854:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c010685b:	00 
c010685c:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106863:	e8 88 a5 ff ff       	call   c0100df0 <__panic>
c0106868:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010686b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106870:	89 c2                	mov    %eax,%edx
c0106872:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106877:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010687e:	00 
c010687f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106883:	89 04 24             	mov    %eax,(%esp)
c0106886:	e8 98 f0 ff ff       	call   c0105923 <get_pte>
c010688b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010688e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106892:	75 24                	jne    c01068b8 <check_boot_pgdir+0x9e>
c0106894:	c7 44 24 0c 4c d7 10 	movl   $0xc010d74c,0xc(%esp)
c010689b:	c0 
c010689c:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01068a3:	c0 
c01068a4:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c01068ab:	00 
c01068ac:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01068b3:	e8 38 a5 ff ff       	call   c0100df0 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01068b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01068bb:	8b 00                	mov    (%eax),%eax
c01068bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01068c2:	89 c2                	mov    %eax,%edx
c01068c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068c7:	39 c2                	cmp    %eax,%edx
c01068c9:	74 24                	je     c01068ef <check_boot_pgdir+0xd5>
c01068cb:	c7 44 24 0c 89 d7 10 	movl   $0xc010d789,0xc(%esp)
c01068d2:	c0 
c01068d3:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01068da:	c0 
c01068db:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
c01068e2:	00 
c01068e3:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01068ea:	e8 01 a5 ff ff       	call   c0100df0 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01068ef:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01068f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01068f9:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c01068fe:	39 c2                	cmp    %eax,%edx
c0106900:	0f 82 26 ff ff ff    	jb     c010682c <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0106906:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c010690b:	05 ac 0f 00 00       	add    $0xfac,%eax
c0106910:	8b 00                	mov    (%eax),%eax
c0106912:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106917:	89 c2                	mov    %eax,%edx
c0106919:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c010691e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106921:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0106928:	77 23                	ja     c010694d <check_boot_pgdir+0x133>
c010692a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010692d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106931:	c7 44 24 08 a0 d3 10 	movl   $0xc010d3a0,0x8(%esp)
c0106938:	c0 
c0106939:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0106940:	00 
c0106941:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106948:	e8 a3 a4 ff ff       	call   c0100df0 <__panic>
c010694d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106950:	05 00 00 00 40       	add    $0x40000000,%eax
c0106955:	39 c2                	cmp    %eax,%edx
c0106957:	74 24                	je     c010697d <check_boot_pgdir+0x163>
c0106959:	c7 44 24 0c a0 d7 10 	movl   $0xc010d7a0,0xc(%esp)
c0106960:	c0 
c0106961:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106968:	c0 
c0106969:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0106970:	00 
c0106971:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106978:	e8 73 a4 ff ff       	call   c0100df0 <__panic>

    assert(boot_pgdir[0] == 0);
c010697d:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106982:	8b 00                	mov    (%eax),%eax
c0106984:	85 c0                	test   %eax,%eax
c0106986:	74 24                	je     c01069ac <check_boot_pgdir+0x192>
c0106988:	c7 44 24 0c d4 d7 10 	movl   $0xc010d7d4,0xc(%esp)
c010698f:	c0 
c0106990:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106997:	c0 
c0106998:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
c010699f:	00 
c01069a0:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c01069a7:	e8 44 a4 ff ff       	call   c0100df0 <__panic>

    struct Page *p;
    p = alloc_page();
c01069ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069b3:	e8 87 e8 ff ff       	call   c010523f <alloc_pages>
c01069b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01069bb:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c01069c0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01069c7:	00 
c01069c8:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01069cf:	00 
c01069d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01069d3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069d7:	89 04 24             	mov    %eax,(%esp)
c01069da:	e8 98 f5 ff ff       	call   c0105f77 <page_insert>
c01069df:	85 c0                	test   %eax,%eax
c01069e1:	74 24                	je     c0106a07 <check_boot_pgdir+0x1ed>
c01069e3:	c7 44 24 0c e8 d7 10 	movl   $0xc010d7e8,0xc(%esp)
c01069ea:	c0 
c01069eb:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c01069f2:	c0 
c01069f3:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
c01069fa:	00 
c01069fb:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106a02:	e8 e9 a3 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p) == 1);
c0106a07:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a0a:	89 04 24             	mov    %eax,(%esp)
c0106a0d:	e8 28 e6 ff ff       	call   c010503a <page_ref>
c0106a12:	83 f8 01             	cmp    $0x1,%eax
c0106a15:	74 24                	je     c0106a3b <check_boot_pgdir+0x221>
c0106a17:	c7 44 24 0c 16 d8 10 	movl   $0xc010d816,0xc(%esp)
c0106a1e:	c0 
c0106a1f:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106a26:	c0 
c0106a27:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c0106a2e:	00 
c0106a2f:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106a36:	e8 b5 a3 ff ff       	call   c0100df0 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0106a3b:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106a40:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106a47:	00 
c0106a48:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0106a4f:	00 
c0106a50:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106a53:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a57:	89 04 24             	mov    %eax,(%esp)
c0106a5a:	e8 18 f5 ff ff       	call   c0105f77 <page_insert>
c0106a5f:	85 c0                	test   %eax,%eax
c0106a61:	74 24                	je     c0106a87 <check_boot_pgdir+0x26d>
c0106a63:	c7 44 24 0c 28 d8 10 	movl   $0xc010d828,0xc(%esp)
c0106a6a:	c0 
c0106a6b:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106a72:	c0 
c0106a73:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
c0106a7a:	00 
c0106a7b:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106a82:	e8 69 a3 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p) == 2);
c0106a87:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a8a:	89 04 24             	mov    %eax,(%esp)
c0106a8d:	e8 a8 e5 ff ff       	call   c010503a <page_ref>
c0106a92:	83 f8 02             	cmp    $0x2,%eax
c0106a95:	74 24                	je     c0106abb <check_boot_pgdir+0x2a1>
c0106a97:	c7 44 24 0c 5f d8 10 	movl   $0xc010d85f,0xc(%esp)
c0106a9e:	c0 
c0106a9f:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106aa6:	c0 
c0106aa7:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
c0106aae:	00 
c0106aaf:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106ab6:	e8 35 a3 ff ff       	call   c0100df0 <__panic>

    const char *str = "ucore: Hello world!!";
c0106abb:	c7 45 dc 70 d8 10 c0 	movl   $0xc010d870,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0106ac2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ac9:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106ad0:	e8 95 55 00 00       	call   c010c06a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0106ad5:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0106adc:	00 
c0106add:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106ae4:	e8 fa 55 00 00       	call   c010c0e3 <strcmp>
c0106ae9:	85 c0                	test   %eax,%eax
c0106aeb:	74 24                	je     c0106b11 <check_boot_pgdir+0x2f7>
c0106aed:	c7 44 24 0c 88 d8 10 	movl   $0xc010d888,0xc(%esp)
c0106af4:	c0 
c0106af5:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106afc:	c0 
c0106afd:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
c0106b04:	00 
c0106b05:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106b0c:	e8 df a2 ff ff       	call   c0100df0 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b14:	89 04 24             	mov    %eax,(%esp)
c0106b17:	e8 74 e4 ff ff       	call   c0104f90 <page2kva>
c0106b1c:	05 00 01 00 00       	add    $0x100,%eax
c0106b21:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106b24:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106b2b:	e8 e2 54 00 00       	call   c010c012 <strlen>
c0106b30:	85 c0                	test   %eax,%eax
c0106b32:	74 24                	je     c0106b58 <check_boot_pgdir+0x33e>
c0106b34:	c7 44 24 0c c0 d8 10 	movl   $0xc010d8c0,0xc(%esp)
c0106b3b:	c0 
c0106b3c:	c7 44 24 08 e9 d3 10 	movl   $0xc010d3e9,0x8(%esp)
c0106b43:	c0 
c0106b44:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
c0106b4b:	00 
c0106b4c:	c7 04 24 c4 d3 10 c0 	movl   $0xc010d3c4,(%esp)
c0106b53:	e8 98 a2 ff ff       	call   c0100df0 <__panic>

    free_page(p);
c0106b58:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b5f:	00 
c0106b60:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b63:	89 04 24             	mov    %eax,(%esp)
c0106b66:	e8 3f e7 ff ff       	call   c01052aa <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106b6b:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106b70:	8b 00                	mov    (%eax),%eax
c0106b72:	89 04 24             	mov    %eax,(%esp)
c0106b75:	e8 a8 e4 ff ff       	call   c0105022 <pde2page>
c0106b7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b81:	00 
c0106b82:	89 04 24             	mov    %eax,(%esp)
c0106b85:	e8 20 e7 ff ff       	call   c01052aa <free_pages>
    boot_pgdir[0] = 0;
c0106b8a:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0106b8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106b95:	c7 04 24 e4 d8 10 c0 	movl   $0xc010d8e4,(%esp)
c0106b9c:	e8 c3 97 ff ff       	call   c0100364 <cprintf>
}
c0106ba1:	c9                   	leave  
c0106ba2:	c3                   	ret    

c0106ba3 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106ba3:	55                   	push   %ebp
c0106ba4:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106ba6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ba9:	83 e0 04             	and    $0x4,%eax
c0106bac:	85 c0                	test   %eax,%eax
c0106bae:	74 07                	je     c0106bb7 <perm2str+0x14>
c0106bb0:	b8 75 00 00 00       	mov    $0x75,%eax
c0106bb5:	eb 05                	jmp    c0106bbc <perm2str+0x19>
c0106bb7:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106bbc:	a2 28 10 1b c0       	mov    %al,0xc01b1028
    str[1] = 'r';
c0106bc1:	c6 05 29 10 1b c0 72 	movb   $0x72,0xc01b1029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bcb:	83 e0 02             	and    $0x2,%eax
c0106bce:	85 c0                	test   %eax,%eax
c0106bd0:	74 07                	je     c0106bd9 <perm2str+0x36>
c0106bd2:	b8 77 00 00 00       	mov    $0x77,%eax
c0106bd7:	eb 05                	jmp    c0106bde <perm2str+0x3b>
c0106bd9:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106bde:	a2 2a 10 1b c0       	mov    %al,0xc01b102a
    str[3] = '\0';
c0106be3:	c6 05 2b 10 1b c0 00 	movb   $0x0,0xc01b102b
    return str;
c0106bea:	b8 28 10 1b c0       	mov    $0xc01b1028,%eax
}
c0106bef:	5d                   	pop    %ebp
c0106bf0:	c3                   	ret    

c0106bf1 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106bf1:	55                   	push   %ebp
c0106bf2:	89 e5                	mov    %esp,%ebp
c0106bf4:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106bf7:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bfa:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106bfd:	72 0a                	jb     c0106c09 <get_pgtable_items+0x18>
        return 0;
c0106bff:	b8 00 00 00 00       	mov    $0x0,%eax
c0106c04:	e9 9c 00 00 00       	jmp    c0106ca5 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106c09:	eb 04                	jmp    c0106c0f <get_pgtable_items+0x1e>
        start ++;
c0106c0b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106c0f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c12:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c15:	73 18                	jae    c0106c2f <get_pgtable_items+0x3e>
c0106c17:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106c21:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c24:	01 d0                	add    %edx,%eax
c0106c26:	8b 00                	mov    (%eax),%eax
c0106c28:	83 e0 01             	and    $0x1,%eax
c0106c2b:	85 c0                	test   %eax,%eax
c0106c2d:	74 dc                	je     c0106c0b <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0106c2f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c32:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c35:	73 69                	jae    c0106ca0 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0106c37:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106c3b:	74 08                	je     c0106c45 <get_pgtable_items+0x54>
            *left_store = start;
c0106c3d:	8b 45 18             	mov    0x18(%ebp),%eax
c0106c40:	8b 55 10             	mov    0x10(%ebp),%edx
c0106c43:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106c45:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c48:	8d 50 01             	lea    0x1(%eax),%edx
c0106c4b:	89 55 10             	mov    %edx,0x10(%ebp)
c0106c4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106c55:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c58:	01 d0                	add    %edx,%eax
c0106c5a:	8b 00                	mov    (%eax),%eax
c0106c5c:	83 e0 07             	and    $0x7,%eax
c0106c5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106c62:	eb 04                	jmp    c0106c68 <get_pgtable_items+0x77>
            start ++;
c0106c64:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106c68:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c6e:	73 1d                	jae    c0106c8d <get_pgtable_items+0x9c>
c0106c70:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106c7a:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c7d:	01 d0                	add    %edx,%eax
c0106c7f:	8b 00                	mov    (%eax),%eax
c0106c81:	83 e0 07             	and    $0x7,%eax
c0106c84:	89 c2                	mov    %eax,%edx
c0106c86:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c89:	39 c2                	cmp    %eax,%edx
c0106c8b:	74 d7                	je     c0106c64 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0106c8d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106c91:	74 08                	je     c0106c9b <get_pgtable_items+0xaa>
            *right_store = start;
c0106c93:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106c96:	8b 55 10             	mov    0x10(%ebp),%edx
c0106c99:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106c9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c9e:	eb 05                	jmp    c0106ca5 <get_pgtable_items+0xb4>
    }
    return 0;
c0106ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106ca5:	c9                   	leave  
c0106ca6:	c3                   	ret    

c0106ca7 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106ca7:	55                   	push   %ebp
c0106ca8:	89 e5                	mov    %esp,%ebp
c0106caa:	57                   	push   %edi
c0106cab:	56                   	push   %esi
c0106cac:	53                   	push   %ebx
c0106cad:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106cb0:	c7 04 24 04 d9 10 c0 	movl   $0xc010d904,(%esp)
c0106cb7:	e8 a8 96 ff ff       	call   c0100364 <cprintf>
    size_t left, right = 0, perm;
c0106cbc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106cc3:	e9 fa 00 00 00       	jmp    c0106dc2 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106cc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ccb:	89 04 24             	mov    %eax,(%esp)
c0106cce:	e8 d0 fe ff ff       	call   c0106ba3 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106cd3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106cd6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106cd9:	29 d1                	sub    %edx,%ecx
c0106cdb:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106cdd:	89 d6                	mov    %edx,%esi
c0106cdf:	c1 e6 16             	shl    $0x16,%esi
c0106ce2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106ce5:	89 d3                	mov    %edx,%ebx
c0106ce7:	c1 e3 16             	shl    $0x16,%ebx
c0106cea:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106ced:	89 d1                	mov    %edx,%ecx
c0106cef:	c1 e1 16             	shl    $0x16,%ecx
c0106cf2:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0106cf5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106cf8:	29 d7                	sub    %edx,%edi
c0106cfa:	89 fa                	mov    %edi,%edx
c0106cfc:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106d00:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106d04:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106d08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106d0c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106d10:	c7 04 24 35 d9 10 c0 	movl   $0xc010d935,(%esp)
c0106d17:	e8 48 96 ff ff       	call   c0100364 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0106d1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d1f:	c1 e0 0a             	shl    $0xa,%eax
c0106d22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106d25:	eb 54                	jmp    c0106d7b <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d2a:	89 04 24             	mov    %eax,(%esp)
c0106d2d:	e8 71 fe ff ff       	call   c0106ba3 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106d32:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106d35:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d38:	29 d1                	sub    %edx,%ecx
c0106d3a:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106d3c:	89 d6                	mov    %edx,%esi
c0106d3e:	c1 e6 0c             	shl    $0xc,%esi
c0106d41:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106d44:	89 d3                	mov    %edx,%ebx
c0106d46:	c1 e3 0c             	shl    $0xc,%ebx
c0106d49:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d4c:	c1 e2 0c             	shl    $0xc,%edx
c0106d4f:	89 d1                	mov    %edx,%ecx
c0106d51:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0106d54:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d57:	29 d7                	sub    %edx,%edi
c0106d59:	89 fa                	mov    %edi,%edx
c0106d5b:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106d5f:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106d63:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106d67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106d6b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106d6f:	c7 04 24 54 d9 10 c0 	movl   $0xc010d954,(%esp)
c0106d76:	e8 e9 95 ff ff       	call   c0100364 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106d7b:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0106d80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106d83:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106d86:	89 ce                	mov    %ecx,%esi
c0106d88:	c1 e6 0a             	shl    $0xa,%esi
c0106d8b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106d8e:	89 cb                	mov    %ecx,%ebx
c0106d90:	c1 e3 0a             	shl    $0xa,%ebx
c0106d93:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0106d96:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106d9a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0106d9d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106da1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106da5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106da9:	89 74 24 04          	mov    %esi,0x4(%esp)
c0106dad:	89 1c 24             	mov    %ebx,(%esp)
c0106db0:	e8 3c fe ff ff       	call   c0106bf1 <get_pgtable_items>
c0106db5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106db8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106dbc:	0f 85 65 ff ff ff    	jne    c0106d27 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106dc2:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0106dc7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106dca:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0106dcd:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106dd1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106dd4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106dd8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106ddc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106de0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106de7:	00 
c0106de8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106def:	e8 fd fd ff ff       	call   c0106bf1 <get_pgtable_items>
c0106df4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106df7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106dfb:	0f 85 c7 fe ff ff    	jne    c0106cc8 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106e01:	c7 04 24 78 d9 10 c0 	movl   $0xc010d978,(%esp)
c0106e08:	e8 57 95 ff ff       	call   c0100364 <cprintf>
}
c0106e0d:	83 c4 4c             	add    $0x4c,%esp
c0106e10:	5b                   	pop    %ebx
c0106e11:	5e                   	pop    %esi
c0106e12:	5f                   	pop    %edi
c0106e13:	5d                   	pop    %ebp
c0106e14:	c3                   	ret    

c0106e15 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0106e15:	55                   	push   %ebp
c0106e16:	89 e5                	mov    %esp,%ebp
c0106e18:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106e1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e1e:	c1 e8 0c             	shr    $0xc,%eax
c0106e21:	89 c2                	mov    %eax,%edx
c0106e23:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0106e28:	39 c2                	cmp    %eax,%edx
c0106e2a:	72 1c                	jb     c0106e48 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106e2c:	c7 44 24 08 ac d9 10 	movl   $0xc010d9ac,0x8(%esp)
c0106e33:	c0 
c0106e34:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106e3b:	00 
c0106e3c:	c7 04 24 cb d9 10 c0 	movl   $0xc010d9cb,(%esp)
c0106e43:	e8 a8 9f ff ff       	call   c0100df0 <__panic>
    }
    return &pages[PPN(pa)];
c0106e48:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0106e4d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e50:	c1 ea 0c             	shr    $0xc,%edx
c0106e53:	c1 e2 05             	shl    $0x5,%edx
c0106e56:	01 d0                	add    %edx,%eax
}
c0106e58:	c9                   	leave  
c0106e59:	c3                   	ret    

c0106e5a <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0106e5a:	55                   	push   %ebp
c0106e5b:	89 e5                	mov    %esp,%ebp
c0106e5d:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106e60:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e63:	83 e0 01             	and    $0x1,%eax
c0106e66:	85 c0                	test   %eax,%eax
c0106e68:	75 1c                	jne    c0106e86 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106e6a:	c7 44 24 08 dc d9 10 	movl   $0xc010d9dc,0x8(%esp)
c0106e71:	c0 
c0106e72:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106e79:	00 
c0106e7a:	c7 04 24 cb d9 10 c0 	movl   $0xc010d9cb,(%esp)
c0106e81:	e8 6a 9f ff ff       	call   c0100df0 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106e86:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106e8e:	89 04 24             	mov    %eax,(%esp)
c0106e91:	e8 7f ff ff ff       	call   c0106e15 <pa2page>
}
c0106e96:	c9                   	leave  
c0106e97:	c3                   	ret    

c0106e98 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106e98:	55                   	push   %ebp
c0106e99:	89 e5                	mov    %esp,%ebp
c0106e9b:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106e9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ea1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106ea6:	89 04 24             	mov    %eax,(%esp)
c0106ea9:	e8 67 ff ff ff       	call   c0106e15 <pa2page>
}
c0106eae:	c9                   	leave  
c0106eaf:	c3                   	ret    

c0106eb0 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106eb0:	55                   	push   %ebp
c0106eb1:	89 e5                	mov    %esp,%ebp
c0106eb3:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106eb6:	e8 e9 23 00 00       	call   c01092a4 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106ebb:	a1 bc 31 1b c0       	mov    0xc01b31bc,%eax
c0106ec0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106ec5:	76 0c                	jbe    c0106ed3 <swap_init+0x23>
c0106ec7:	a1 bc 31 1b c0       	mov    0xc01b31bc,%eax
c0106ecc:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106ed1:	76 25                	jbe    c0106ef8 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106ed3:	a1 bc 31 1b c0       	mov    0xc01b31bc,%eax
c0106ed8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106edc:	c7 44 24 08 fd d9 10 	movl   $0xc010d9fd,0x8(%esp)
c0106ee3:	c0 
c0106ee4:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106eeb:	00 
c0106eec:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0106ef3:	e8 f8 9e ff ff       	call   c0100df0 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106ef8:	c7 05 34 10 1b c0 60 	movl   $0xc012ca60,0xc01b1034
c0106eff:	ca 12 c0 
     int r = sm->init();
c0106f02:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0106f07:	8b 40 04             	mov    0x4(%eax),%eax
c0106f0a:	ff d0                	call   *%eax
c0106f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106f0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f13:	75 26                	jne    c0106f3b <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106f15:	c7 05 2c 10 1b c0 01 	movl   $0x1,0xc01b102c
c0106f1c:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106f1f:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0106f24:	8b 00                	mov    (%eax),%eax
c0106f26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f2a:	c7 04 24 27 da 10 c0 	movl   $0xc010da27,(%esp)
c0106f31:	e8 2e 94 ff ff       	call   c0100364 <cprintf>
          check_swap();
c0106f36:	e8 a4 04 00 00       	call   c01073df <check_swap>
     }

     return r;
c0106f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106f3e:	c9                   	leave  
c0106f3f:	c3                   	ret    

c0106f40 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106f40:	55                   	push   %ebp
c0106f41:	89 e5                	mov    %esp,%ebp
c0106f43:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106f46:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0106f4b:	8b 40 08             	mov    0x8(%eax),%eax
c0106f4e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f51:	89 14 24             	mov    %edx,(%esp)
c0106f54:	ff d0                	call   *%eax
}
c0106f56:	c9                   	leave  
c0106f57:	c3                   	ret    

c0106f58 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106f58:	55                   	push   %ebp
c0106f59:	89 e5                	mov    %esp,%ebp
c0106f5b:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106f5e:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0106f63:	8b 40 0c             	mov    0xc(%eax),%eax
c0106f66:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f69:	89 14 24             	mov    %edx,(%esp)
c0106f6c:	ff d0                	call   *%eax
}
c0106f6e:	c9                   	leave  
c0106f6f:	c3                   	ret    

c0106f70 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106f70:	55                   	push   %ebp
c0106f71:	89 e5                	mov    %esp,%ebp
c0106f73:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106f76:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0106f7b:	8b 40 10             	mov    0x10(%eax),%eax
c0106f7e:	8b 55 14             	mov    0x14(%ebp),%edx
c0106f81:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106f85:	8b 55 10             	mov    0x10(%ebp),%edx
c0106f88:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106f8c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106f8f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f93:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f96:	89 14 24             	mov    %edx,(%esp)
c0106f99:	ff d0                	call   *%eax
}
c0106f9b:	c9                   	leave  
c0106f9c:	c3                   	ret    

c0106f9d <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106f9d:	55                   	push   %ebp
c0106f9e:	89 e5                	mov    %esp,%ebp
c0106fa0:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0106fa3:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0106fa8:	8b 40 14             	mov    0x14(%eax),%eax
c0106fab:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106fae:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106fb2:	8b 55 08             	mov    0x8(%ebp),%edx
c0106fb5:	89 14 24             	mov    %edx,(%esp)
c0106fb8:	ff d0                	call   *%eax
}
c0106fba:	c9                   	leave  
c0106fbb:	c3                   	ret    

c0106fbc <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106fbc:	55                   	push   %ebp
c0106fbd:	89 e5                	mov    %esp,%ebp
c0106fbf:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106fc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106fc9:	e9 5a 01 00 00       	jmp    c0107128 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106fce:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0106fd3:	8b 40 18             	mov    0x18(%eax),%eax
c0106fd6:	8b 55 10             	mov    0x10(%ebp),%edx
c0106fd9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106fdd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106fe0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106fe4:	8b 55 08             	mov    0x8(%ebp),%edx
c0106fe7:	89 14 24             	mov    %edx,(%esp)
c0106fea:	ff d0                	call   *%eax
c0106fec:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106fef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106ff3:	74 18                	je     c010700d <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ffc:	c7 04 24 3c da 10 c0 	movl   $0xc010da3c,(%esp)
c0107003:	e8 5c 93 ff ff       	call   c0100364 <cprintf>
c0107008:	e9 27 01 00 00       	jmp    c0107134 <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c010700d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107010:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107013:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0107016:	8b 45 08             	mov    0x8(%ebp),%eax
c0107019:	8b 40 0c             	mov    0xc(%eax),%eax
c010701c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107023:	00 
c0107024:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107027:	89 54 24 04          	mov    %edx,0x4(%esp)
c010702b:	89 04 24             	mov    %eax,(%esp)
c010702e:	e8 f0 e8 ff ff       	call   c0105923 <get_pte>
c0107033:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0107036:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107039:	8b 00                	mov    (%eax),%eax
c010703b:	83 e0 01             	and    $0x1,%eax
c010703e:	85 c0                	test   %eax,%eax
c0107040:	75 24                	jne    c0107066 <swap_out+0xaa>
c0107042:	c7 44 24 0c 69 da 10 	movl   $0xc010da69,0xc(%esp)
c0107049:	c0 
c010704a:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107051:	c0 
c0107052:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0107059:	00 
c010705a:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107061:	e8 8a 9d ff ff       	call   c0100df0 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0107066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107069:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010706c:	8b 52 1c             	mov    0x1c(%edx),%edx
c010706f:	c1 ea 0c             	shr    $0xc,%edx
c0107072:	83 c2 01             	add    $0x1,%edx
c0107075:	c1 e2 08             	shl    $0x8,%edx
c0107078:	89 44 24 04          	mov    %eax,0x4(%esp)
c010707c:	89 14 24             	mov    %edx,(%esp)
c010707f:	e8 da 22 00 00       	call   c010935e <swapfs_write>
c0107084:	85 c0                	test   %eax,%eax
c0107086:	74 34                	je     c01070bc <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0107088:	c7 04 24 93 da 10 c0 	movl   $0xc010da93,(%esp)
c010708f:	e8 d0 92 ff ff       	call   c0100364 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0107094:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c0107099:	8b 40 10             	mov    0x10(%eax),%eax
c010709c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010709f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01070a6:	00 
c01070a7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01070ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070ae:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01070b5:	89 14 24             	mov    %edx,(%esp)
c01070b8:	ff d0                	call   *%eax
c01070ba:	eb 68                	jmp    c0107124 <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01070bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070bf:	8b 40 1c             	mov    0x1c(%eax),%eax
c01070c2:	c1 e8 0c             	shr    $0xc,%eax
c01070c5:	83 c0 01             	add    $0x1,%eax
c01070c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01070cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01070cf:	89 44 24 08          	mov    %eax,0x8(%esp)
c01070d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01070da:	c7 04 24 ac da 10 c0 	movl   $0xc010daac,(%esp)
c01070e1:	e8 7e 92 ff ff       	call   c0100364 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01070e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070e9:	8b 40 1c             	mov    0x1c(%eax),%eax
c01070ec:	c1 e8 0c             	shr    $0xc,%eax
c01070ef:	83 c0 01             	add    $0x1,%eax
c01070f2:	c1 e0 08             	shl    $0x8,%eax
c01070f5:	89 c2                	mov    %eax,%edx
c01070f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01070fa:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c01070fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070ff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107106:	00 
c0107107:	89 04 24             	mov    %eax,(%esp)
c010710a:	e8 9b e1 ff ff       	call   c01052aa <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c010710f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107112:	8b 40 0c             	mov    0xc(%eax),%eax
c0107115:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107118:	89 54 24 04          	mov    %edx,0x4(%esp)
c010711c:	89 04 24             	mov    %eax,(%esp)
c010711f:	e8 0c ef ff ff       	call   c0106030 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0107124:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107128:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010712b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010712e:	0f 85 9a fe ff ff    	jne    c0106fce <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0107134:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107137:	c9                   	leave  
c0107138:	c3                   	ret    

c0107139 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0107139:	55                   	push   %ebp
c010713a:	89 e5                	mov    %esp,%ebp
c010713c:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c010713f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107146:	e8 f4 e0 ff ff       	call   c010523f <alloc_pages>
c010714b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c010714e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107152:	75 24                	jne    c0107178 <swap_in+0x3f>
c0107154:	c7 44 24 0c ec da 10 	movl   $0xc010daec,0xc(%esp)
c010715b:	c0 
c010715c:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107163:	c0 
c0107164:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c010716b:	00 
c010716c:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107173:	e8 78 9c ff ff       	call   c0100df0 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0107178:	8b 45 08             	mov    0x8(%ebp),%eax
c010717b:	8b 40 0c             	mov    0xc(%eax),%eax
c010717e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107185:	00 
c0107186:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107189:	89 54 24 04          	mov    %edx,0x4(%esp)
c010718d:	89 04 24             	mov    %eax,(%esp)
c0107190:	e8 8e e7 ff ff       	call   c0105923 <get_pte>
c0107195:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0107198:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010719b:	8b 00                	mov    (%eax),%eax
c010719d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01071a0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071a4:	89 04 24             	mov    %eax,(%esp)
c01071a7:	e8 40 21 00 00       	call   c01092ec <swapfs_read>
c01071ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01071af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01071b3:	74 2a                	je     c01071df <swap_in+0xa6>
     {
        assert(r!=0);
c01071b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01071b9:	75 24                	jne    c01071df <swap_in+0xa6>
c01071bb:	c7 44 24 0c f9 da 10 	movl   $0xc010daf9,0xc(%esp)
c01071c2:	c0 
c01071c3:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01071ca:	c0 
c01071cb:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c01071d2:	00 
c01071d3:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01071da:	e8 11 9c ff ff       	call   c0100df0 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01071df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01071e2:	8b 00                	mov    (%eax),%eax
c01071e4:	c1 e8 08             	shr    $0x8,%eax
c01071e7:	89 c2                	mov    %eax,%edx
c01071e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01071f0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071f4:	c7 04 24 00 db 10 c0 	movl   $0xc010db00,(%esp)
c01071fb:	e8 64 91 ff ff       	call   c0100364 <cprintf>
     *ptr_result=result;
c0107200:	8b 45 10             	mov    0x10(%ebp),%eax
c0107203:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107206:	89 10                	mov    %edx,(%eax)
     return 0;
c0107208:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010720d:	c9                   	leave  
c010720e:	c3                   	ret    

c010720f <check_content_set>:



static inline void
check_content_set(void)
{
c010720f:	55                   	push   %ebp
c0107210:	89 e5                	mov    %esp,%ebp
c0107212:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0107215:	b8 00 10 00 00       	mov    $0x1000,%eax
c010721a:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010721d:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107222:	83 f8 01             	cmp    $0x1,%eax
c0107225:	74 24                	je     c010724b <check_content_set+0x3c>
c0107227:	c7 44 24 0c 3e db 10 	movl   $0xc010db3e,0xc(%esp)
c010722e:	c0 
c010722f:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107236:	c0 
c0107237:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c010723e:	00 
c010723f:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107246:	e8 a5 9b ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c010724b:	b8 10 10 00 00       	mov    $0x1010,%eax
c0107250:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107253:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107258:	83 f8 01             	cmp    $0x1,%eax
c010725b:	74 24                	je     c0107281 <check_content_set+0x72>
c010725d:	c7 44 24 0c 3e db 10 	movl   $0xc010db3e,0xc(%esp)
c0107264:	c0 
c0107265:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c010726c:	c0 
c010726d:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0107274:	00 
c0107275:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c010727c:	e8 6f 9b ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0107281:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107286:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107289:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c010728e:	83 f8 02             	cmp    $0x2,%eax
c0107291:	74 24                	je     c01072b7 <check_content_set+0xa8>
c0107293:	c7 44 24 0c 4d db 10 	movl   $0xc010db4d,0xc(%esp)
c010729a:	c0 
c010729b:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01072a2:	c0 
c01072a3:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c01072aa:	00 
c01072ab:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01072b2:	e8 39 9b ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01072b7:	b8 10 20 00 00       	mov    $0x2010,%eax
c01072bc:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01072bf:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c01072c4:	83 f8 02             	cmp    $0x2,%eax
c01072c7:	74 24                	je     c01072ed <check_content_set+0xde>
c01072c9:	c7 44 24 0c 4d db 10 	movl   $0xc010db4d,0xc(%esp)
c01072d0:	c0 
c01072d1:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01072d8:	c0 
c01072d9:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01072e0:	00 
c01072e1:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01072e8:	e8 03 9b ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c01072ed:	b8 00 30 00 00       	mov    $0x3000,%eax
c01072f2:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01072f5:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c01072fa:	83 f8 03             	cmp    $0x3,%eax
c01072fd:	74 24                	je     c0107323 <check_content_set+0x114>
c01072ff:	c7 44 24 0c 5c db 10 	movl   $0xc010db5c,0xc(%esp)
c0107306:	c0 
c0107307:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c010730e:	c0 
c010730f:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0107316:	00 
c0107317:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c010731e:	e8 cd 9a ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0107323:	b8 10 30 00 00       	mov    $0x3010,%eax
c0107328:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010732b:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107330:	83 f8 03             	cmp    $0x3,%eax
c0107333:	74 24                	je     c0107359 <check_content_set+0x14a>
c0107335:	c7 44 24 0c 5c db 10 	movl   $0xc010db5c,0xc(%esp)
c010733c:	c0 
c010733d:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107344:	c0 
c0107345:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010734c:	00 
c010734d:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107354:	e8 97 9a ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0107359:	b8 00 40 00 00       	mov    $0x4000,%eax
c010735e:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107361:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107366:	83 f8 04             	cmp    $0x4,%eax
c0107369:	74 24                	je     c010738f <check_content_set+0x180>
c010736b:	c7 44 24 0c 6b db 10 	movl   $0xc010db6b,0xc(%esp)
c0107372:	c0 
c0107373:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c010737a:	c0 
c010737b:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0107382:	00 
c0107383:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c010738a:	e8 61 9a ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c010738f:	b8 10 40 00 00       	mov    $0x4010,%eax
c0107394:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107397:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c010739c:	83 f8 04             	cmp    $0x4,%eax
c010739f:	74 24                	je     c01073c5 <check_content_set+0x1b6>
c01073a1:	c7 44 24 0c 6b db 10 	movl   $0xc010db6b,0xc(%esp)
c01073a8:	c0 
c01073a9:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01073b0:	c0 
c01073b1:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01073b8:	00 
c01073b9:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01073c0:	e8 2b 9a ff ff       	call   c0100df0 <__panic>
}
c01073c5:	c9                   	leave  
c01073c6:	c3                   	ret    

c01073c7 <check_content_access>:

static inline int
check_content_access(void)
{
c01073c7:	55                   	push   %ebp
c01073c8:	89 e5                	mov    %esp,%ebp
c01073ca:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c01073cd:	a1 34 10 1b c0       	mov    0xc01b1034,%eax
c01073d2:	8b 40 1c             	mov    0x1c(%eax),%eax
c01073d5:	ff d0                	call   *%eax
c01073d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c01073da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01073dd:	c9                   	leave  
c01073de:	c3                   	ret    

c01073df <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c01073df:	55                   	push   %ebp
c01073e0:	89 e5                	mov    %esp,%ebp
c01073e2:	53                   	push   %ebx
c01073e3:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c01073e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01073ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c01073f4:	c7 45 e8 f0 30 1b c0 	movl   $0xc01b30f0,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01073fb:	eb 6b                	jmp    c0107468 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c01073fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107400:	83 e8 0c             	sub    $0xc,%eax
c0107403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0107406:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107409:	83 c0 04             	add    $0x4,%eax
c010740c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0107413:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107416:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107419:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010741c:	0f a3 10             	bt     %edx,(%eax)
c010741f:	19 c0                	sbb    %eax,%eax
c0107421:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0107424:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107428:	0f 95 c0             	setne  %al
c010742b:	0f b6 c0             	movzbl %al,%eax
c010742e:	85 c0                	test   %eax,%eax
c0107430:	75 24                	jne    c0107456 <check_swap+0x77>
c0107432:	c7 44 24 0c 7a db 10 	movl   $0xc010db7a,0xc(%esp)
c0107439:	c0 
c010743a:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107441:	c0 
c0107442:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0107449:	00 
c010744a:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107451:	e8 9a 99 ff ff       	call   c0100df0 <__panic>
        count ++, total += p->property;
c0107456:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010745a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010745d:	8b 50 08             	mov    0x8(%eax),%edx
c0107460:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107463:	01 d0                	add    %edx,%eax
c0107465:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107468:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010746b:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010746e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107471:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0107474:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107477:	81 7d e8 f0 30 1b c0 	cmpl   $0xc01b30f0,-0x18(%ebp)
c010747e:	0f 85 79 ff ff ff    	jne    c01073fd <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c0107484:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0107487:	e8 50 de ff ff       	call   c01052dc <nr_free_pages>
c010748c:	39 c3                	cmp    %eax,%ebx
c010748e:	74 24                	je     c01074b4 <check_swap+0xd5>
c0107490:	c7 44 24 0c 8a db 10 	movl   $0xc010db8a,0xc(%esp)
c0107497:	c0 
c0107498:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c010749f:	c0 
c01074a0:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c01074a7:	00 
c01074a8:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01074af:	e8 3c 99 ff ff       	call   c0100df0 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01074b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074b7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01074bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01074c2:	c7 04 24 a4 db 10 c0 	movl   $0xc010dba4,(%esp)
c01074c9:	e8 96 8e ff ff       	call   c0100364 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c01074ce:	e8 74 0b 00 00       	call   c0108047 <mm_create>
c01074d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c01074d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01074da:	75 24                	jne    c0107500 <check_swap+0x121>
c01074dc:	c7 44 24 0c ca db 10 	movl   $0xc010dbca,0xc(%esp)
c01074e3:	c0 
c01074e4:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01074eb:	c0 
c01074ec:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c01074f3:	00 
c01074f4:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01074fb:	e8 f0 98 ff ff       	call   c0100df0 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0107500:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c0107505:	85 c0                	test   %eax,%eax
c0107507:	74 24                	je     c010752d <check_swap+0x14e>
c0107509:	c7 44 24 0c d5 db 10 	movl   $0xc010dbd5,0xc(%esp)
c0107510:	c0 
c0107511:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107518:	c0 
c0107519:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0107520:	00 
c0107521:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107528:	e8 c3 98 ff ff       	call   c0100df0 <__panic>

     check_mm_struct = mm;
c010752d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107530:	a3 ec 31 1b c0       	mov    %eax,0xc01b31ec

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107535:	8b 15 00 ca 12 c0    	mov    0xc012ca00,%edx
c010753b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010753e:	89 50 0c             	mov    %edx,0xc(%eax)
c0107541:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107544:	8b 40 0c             	mov    0xc(%eax),%eax
c0107547:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c010754a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010754d:	8b 00                	mov    (%eax),%eax
c010754f:	85 c0                	test   %eax,%eax
c0107551:	74 24                	je     c0107577 <check_swap+0x198>
c0107553:	c7 44 24 0c ed db 10 	movl   $0xc010dbed,0xc(%esp)
c010755a:	c0 
c010755b:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107562:	c0 
c0107563:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c010756a:	00 
c010756b:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107572:	e8 79 98 ff ff       	call   c0100df0 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0107577:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c010757e:	00 
c010757f:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0107586:	00 
c0107587:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c010758e:	e8 4d 0b 00 00       	call   c01080e0 <vma_create>
c0107593:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0107596:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010759a:	75 24                	jne    c01075c0 <check_swap+0x1e1>
c010759c:	c7 44 24 0c fb db 10 	movl   $0xc010dbfb,0xc(%esp)
c01075a3:	c0 
c01075a4:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01075ab:	c0 
c01075ac:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c01075b3:	00 
c01075b4:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01075bb:	e8 30 98 ff ff       	call   c0100df0 <__panic>

     insert_vma_struct(mm, vma);
c01075c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01075c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01075c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01075ca:	89 04 24             	mov    %eax,(%esp)
c01075cd:	e8 9e 0c 00 00       	call   c0108270 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01075d2:	c7 04 24 08 dc 10 c0 	movl   $0xc010dc08,(%esp)
c01075d9:	e8 86 8d ff ff       	call   c0100364 <cprintf>
     pte_t *temp_ptep=NULL;
c01075de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01075e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01075e8:	8b 40 0c             	mov    0xc(%eax),%eax
c01075eb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01075f2:	00 
c01075f3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01075fa:	00 
c01075fb:	89 04 24             	mov    %eax,(%esp)
c01075fe:	e8 20 e3 ff ff       	call   c0105923 <get_pte>
c0107603:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0107606:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010760a:	75 24                	jne    c0107630 <check_swap+0x251>
c010760c:	c7 44 24 0c 3c dc 10 	movl   $0xc010dc3c,0xc(%esp)
c0107613:	c0 
c0107614:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c010761b:	c0 
c010761c:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0107623:	00 
c0107624:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c010762b:	e8 c0 97 ff ff       	call   c0100df0 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0107630:	c7 04 24 50 dc 10 c0 	movl   $0xc010dc50,(%esp)
c0107637:	e8 28 8d ff ff       	call   c0100364 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010763c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107643:	e9 a3 00 00 00       	jmp    c01076eb <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0107648:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010764f:	e8 eb db ff ff       	call   c010523f <alloc_pages>
c0107654:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107657:	89 04 95 20 31 1b c0 	mov    %eax,-0x3fe4cee0(,%edx,4)
          assert(check_rp[i] != NULL );
c010765e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107661:	8b 04 85 20 31 1b c0 	mov    -0x3fe4cee0(,%eax,4),%eax
c0107668:	85 c0                	test   %eax,%eax
c010766a:	75 24                	jne    c0107690 <check_swap+0x2b1>
c010766c:	c7 44 24 0c 74 dc 10 	movl   $0xc010dc74,0xc(%esp)
c0107673:	c0 
c0107674:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c010767b:	c0 
c010767c:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0107683:	00 
c0107684:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c010768b:	e8 60 97 ff ff       	call   c0100df0 <__panic>
          assert(!PageProperty(check_rp[i]));
c0107690:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107693:	8b 04 85 20 31 1b c0 	mov    -0x3fe4cee0(,%eax,4),%eax
c010769a:	83 c0 04             	add    $0x4,%eax
c010769d:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01076a4:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01076a7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01076aa:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01076ad:	0f a3 10             	bt     %edx,(%eax)
c01076b0:	19 c0                	sbb    %eax,%eax
c01076b2:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01076b5:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01076b9:	0f 95 c0             	setne  %al
c01076bc:	0f b6 c0             	movzbl %al,%eax
c01076bf:	85 c0                	test   %eax,%eax
c01076c1:	74 24                	je     c01076e7 <check_swap+0x308>
c01076c3:	c7 44 24 0c 88 dc 10 	movl   $0xc010dc88,0xc(%esp)
c01076ca:	c0 
c01076cb:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01076d2:	c0 
c01076d3:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01076da:	00 
c01076db:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01076e2:	e8 09 97 ff ff       	call   c0100df0 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01076e7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01076eb:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01076ef:	0f 8e 53 ff ff ff    	jle    c0107648 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01076f5:	a1 f0 30 1b c0       	mov    0xc01b30f0,%eax
c01076fa:	8b 15 f4 30 1b c0    	mov    0xc01b30f4,%edx
c0107700:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107703:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0107706:	c7 45 a8 f0 30 1b c0 	movl   $0xc01b30f0,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010770d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107710:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0107713:	89 50 04             	mov    %edx,0x4(%eax)
c0107716:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107719:	8b 50 04             	mov    0x4(%eax),%edx
c010771c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010771f:	89 10                	mov    %edx,(%eax)
c0107721:	c7 45 a4 f0 30 1b c0 	movl   $0xc01b30f0,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0107728:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010772b:	8b 40 04             	mov    0x4(%eax),%eax
c010772e:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0107731:	0f 94 c0             	sete   %al
c0107734:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0107737:	85 c0                	test   %eax,%eax
c0107739:	75 24                	jne    c010775f <check_swap+0x380>
c010773b:	c7 44 24 0c a3 dc 10 	movl   $0xc010dca3,0xc(%esp)
c0107742:	c0 
c0107743:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c010774a:	c0 
c010774b:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0107752:	00 
c0107753:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c010775a:	e8 91 96 ff ff       	call   c0100df0 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010775f:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c0107764:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0107767:	c7 05 f8 30 1b c0 00 	movl   $0x0,0xc01b30f8
c010776e:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107771:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107778:	eb 1e                	jmp    c0107798 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c010777a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010777d:	8b 04 85 20 31 1b c0 	mov    -0x3fe4cee0(,%eax,4),%eax
c0107784:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010778b:	00 
c010778c:	89 04 24             	mov    %eax,(%esp)
c010778f:	e8 16 db ff ff       	call   c01052aa <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107794:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107798:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010779c:	7e dc                	jle    c010777a <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c010779e:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c01077a3:	83 f8 04             	cmp    $0x4,%eax
c01077a6:	74 24                	je     c01077cc <check_swap+0x3ed>
c01077a8:	c7 44 24 0c bc dc 10 	movl   $0xc010dcbc,0xc(%esp)
c01077af:	c0 
c01077b0:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01077b7:	c0 
c01077b8:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c01077bf:	00 
c01077c0:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01077c7:	e8 24 96 ff ff       	call   c0100df0 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01077cc:	c7 04 24 e0 dc 10 c0 	movl   $0xc010dce0,(%esp)
c01077d3:	e8 8c 8b ff ff       	call   c0100364 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01077d8:	c7 05 38 10 1b c0 00 	movl   $0x0,0xc01b1038
c01077df:	00 00 00 
     
     check_content_set();
c01077e2:	e8 28 fa ff ff       	call   c010720f <check_content_set>
     assert( nr_free == 0);         
c01077e7:	a1 f8 30 1b c0       	mov    0xc01b30f8,%eax
c01077ec:	85 c0                	test   %eax,%eax
c01077ee:	74 24                	je     c0107814 <check_swap+0x435>
c01077f0:	c7 44 24 0c 07 dd 10 	movl   $0xc010dd07,0xc(%esp)
c01077f7:	c0 
c01077f8:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01077ff:	c0 
c0107800:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0107807:	00 
c0107808:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c010780f:	e8 dc 95 ff ff       	call   c0100df0 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107814:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010781b:	eb 26                	jmp    c0107843 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c010781d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107820:	c7 04 85 40 31 1b c0 	movl   $0xffffffff,-0x3fe4cec0(,%eax,4)
c0107827:	ff ff ff ff 
c010782b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010782e:	8b 14 85 40 31 1b c0 	mov    -0x3fe4cec0(,%eax,4),%edx
c0107835:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107838:	89 14 85 80 31 1b c0 	mov    %edx,-0x3fe4ce80(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010783f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107843:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0107847:	7e d4                	jle    c010781d <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107849:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107850:	e9 eb 00 00 00       	jmp    c0107940 <check_swap+0x561>
         check_ptep[i]=0;
c0107855:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107858:	c7 04 85 d4 31 1b c0 	movl   $0x0,-0x3fe4ce2c(,%eax,4)
c010785f:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0107863:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107866:	83 c0 01             	add    $0x1,%eax
c0107869:	c1 e0 0c             	shl    $0xc,%eax
c010786c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107873:	00 
c0107874:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107878:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010787b:	89 04 24             	mov    %eax,(%esp)
c010787e:	e8 a0 e0 ff ff       	call   c0105923 <get_pte>
c0107883:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107886:	89 04 95 d4 31 1b c0 	mov    %eax,-0x3fe4ce2c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c010788d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107890:	8b 04 85 d4 31 1b c0 	mov    -0x3fe4ce2c(,%eax,4),%eax
c0107897:	85 c0                	test   %eax,%eax
c0107899:	75 24                	jne    c01078bf <check_swap+0x4e0>
c010789b:	c7 44 24 0c 14 dd 10 	movl   $0xc010dd14,0xc(%esp)
c01078a2:	c0 
c01078a3:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01078aa:	c0 
c01078ab:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01078b2:	00 
c01078b3:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c01078ba:	e8 31 95 ff ff       	call   c0100df0 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01078bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078c2:	8b 04 85 d4 31 1b c0 	mov    -0x3fe4ce2c(,%eax,4),%eax
c01078c9:	8b 00                	mov    (%eax),%eax
c01078cb:	89 04 24             	mov    %eax,(%esp)
c01078ce:	e8 87 f5 ff ff       	call   c0106e5a <pte2page>
c01078d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01078d6:	8b 14 95 20 31 1b c0 	mov    -0x3fe4cee0(,%edx,4),%edx
c01078dd:	39 d0                	cmp    %edx,%eax
c01078df:	74 24                	je     c0107905 <check_swap+0x526>
c01078e1:	c7 44 24 0c 2c dd 10 	movl   $0xc010dd2c,0xc(%esp)
c01078e8:	c0 
c01078e9:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c01078f0:	c0 
c01078f1:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01078f8:	00 
c01078f9:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107900:	e8 eb 94 ff ff       	call   c0100df0 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0107905:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107908:	8b 04 85 d4 31 1b c0 	mov    -0x3fe4ce2c(,%eax,4),%eax
c010790f:	8b 00                	mov    (%eax),%eax
c0107911:	83 e0 01             	and    $0x1,%eax
c0107914:	85 c0                	test   %eax,%eax
c0107916:	75 24                	jne    c010793c <check_swap+0x55d>
c0107918:	c7 44 24 0c 54 dd 10 	movl   $0xc010dd54,0xc(%esp)
c010791f:	c0 
c0107920:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107927:	c0 
c0107928:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c010792f:	00 
c0107930:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107937:	e8 b4 94 ff ff       	call   c0100df0 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010793c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107940:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107944:	0f 8e 0b ff ff ff    	jle    c0107855 <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c010794a:	c7 04 24 70 dd 10 c0 	movl   $0xc010dd70,(%esp)
c0107951:	e8 0e 8a ff ff       	call   c0100364 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0107956:	e8 6c fa ff ff       	call   c01073c7 <check_content_access>
c010795b:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c010795e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107962:	74 24                	je     c0107988 <check_swap+0x5a9>
c0107964:	c7 44 24 0c 96 dd 10 	movl   $0xc010dd96,0xc(%esp)
c010796b:	c0 
c010796c:	c7 44 24 08 7e da 10 	movl   $0xc010da7e,0x8(%esp)
c0107973:	c0 
c0107974:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c010797b:	00 
c010797c:	c7 04 24 18 da 10 c0 	movl   $0xc010da18,(%esp)
c0107983:	e8 68 94 ff ff       	call   c0100df0 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107988:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010798f:	eb 1e                	jmp    c01079af <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c0107991:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107994:	8b 04 85 20 31 1b c0 	mov    -0x3fe4cee0(,%eax,4),%eax
c010799b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01079a2:	00 
c01079a3:	89 04 24             	mov    %eax,(%esp)
c01079a6:	e8 ff d8 ff ff       	call   c01052aa <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01079ab:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01079af:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01079b3:	7e dc                	jle    c0107991 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c01079b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079b8:	8b 00                	mov    (%eax),%eax
c01079ba:	89 04 24             	mov    %eax,(%esp)
c01079bd:	e8 d6 f4 ff ff       	call   c0106e98 <pde2page>
c01079c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01079c9:	00 
c01079ca:	89 04 24             	mov    %eax,(%esp)
c01079cd:	e8 d8 d8 ff ff       	call   c01052aa <free_pages>
     pgdir[0] = 0;
c01079d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c01079db:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01079de:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c01079e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01079e8:	89 04 24             	mov    %eax,(%esp)
c01079eb:	e8 b0 09 00 00       	call   c01083a0 <mm_destroy>
     check_mm_struct = NULL;
c01079f0:	c7 05 ec 31 1b c0 00 	movl   $0x0,0xc01b31ec
c01079f7:	00 00 00 
     
     nr_free = nr_free_store;
c01079fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01079fd:	a3 f8 30 1b c0       	mov    %eax,0xc01b30f8
     free_list = free_list_store;
c0107a02:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107a05:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107a08:	a3 f0 30 1b c0       	mov    %eax,0xc01b30f0
c0107a0d:	89 15 f4 30 1b c0    	mov    %edx,0xc01b30f4

     
     le = &free_list;
c0107a13:	c7 45 e8 f0 30 1b c0 	movl   $0xc01b30f0,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107a1a:	eb 1d                	jmp    c0107a39 <check_swap+0x65a>
         struct Page *p = le2page(le, page_link);
c0107a1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a1f:	83 e8 0c             	sub    $0xc,%eax
c0107a22:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0107a25:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107a29:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107a2c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107a2f:	8b 40 08             	mov    0x8(%eax),%eax
c0107a32:	29 c2                	sub    %eax,%edx
c0107a34:	89 d0                	mov    %edx,%eax
c0107a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a3c:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107a3f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107a42:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0107a45:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107a48:	81 7d e8 f0 30 1b c0 	cmpl   $0xc01b30f0,-0x18(%ebp)
c0107a4f:	75 cb                	jne    c0107a1c <check_swap+0x63d>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0107a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a54:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a5f:	c7 04 24 9d dd 10 c0 	movl   $0xc010dd9d,(%esp)
c0107a66:	e8 f9 88 ff ff       	call   c0100364 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107a6b:	c7 04 24 b7 dd 10 c0 	movl   $0xc010ddb7,(%esp)
c0107a72:	e8 ed 88 ff ff       	call   c0100364 <cprintf>
}
c0107a77:	83 c4 74             	add    $0x74,%esp
c0107a7a:	5b                   	pop    %ebx
c0107a7b:	5d                   	pop    %ebp
c0107a7c:	c3                   	ret    

c0107a7d <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0107a7d:	55                   	push   %ebp
c0107a7e:	89 e5                	mov    %esp,%ebp
c0107a80:	83 ec 10             	sub    $0x10,%esp
c0107a83:	c7 45 fc e4 31 1b c0 	movl   $0xc01b31e4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107a8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a8d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107a90:	89 50 04             	mov    %edx,0x4(%eax)
c0107a93:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a96:	8b 50 04             	mov    0x4(%eax),%edx
c0107a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a9c:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107aa1:	c7 40 14 e4 31 1b c0 	movl   $0xc01b31e4,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107aad:	c9                   	leave  
c0107aae:	c3                   	ret    

c0107aaf <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107aaf:	55                   	push   %ebp
c0107ab0:	89 e5                	mov    %esp,%ebp
c0107ab2:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ab8:	8b 40 14             	mov    0x14(%eax),%eax
c0107abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107abe:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ac1:	83 c0 14             	add    $0x14,%eax
c0107ac4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107ac7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107acb:	74 06                	je     c0107ad3 <_fifo_map_swappable+0x24>
c0107acd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ad1:	75 24                	jne    c0107af7 <_fifo_map_swappable+0x48>
c0107ad3:	c7 44 24 0c d0 dd 10 	movl   $0xc010ddd0,0xc(%esp)
c0107ada:	c0 
c0107adb:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107ae2:	c0 
c0107ae3:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0107aea:	00 
c0107aeb:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107af2:	e8 f9 92 ff ff       	call   c0100df0 <__panic>
c0107af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107afa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b00:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107b03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107b09:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0107b0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b12:	8b 40 04             	mov    0x4(%eax),%eax
c0107b15:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107b1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107b1e:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0107b21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0107b24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107b27:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107b2a:	89 10                	mov    %edx,(%eax)
c0107b2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107b2f:	8b 10                	mov    (%eax),%edx
c0107b31:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107b34:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107b37:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b3a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107b3d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107b40:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b43:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107b46:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
	list_add(head, entry);
    return 0;
c0107b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b4d:	c9                   	leave  
c0107b4e:	c3                   	ret    

c0107b4f <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107b4f:	55                   	push   %ebp
c0107b50:	89 e5                	mov    %esp,%ebp
c0107b52:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107b55:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b58:	8b 40 14             	mov    0x14(%eax),%eax
c0107b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0107b5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b62:	75 24                	jne    c0107b88 <_fifo_swap_out_victim+0x39>
c0107b64:	c7 44 24 0c 17 de 10 	movl   $0xc010de17,0xc(%esp)
c0107b6b:	c0 
c0107b6c:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107b73:	c0 
c0107b74:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107b7b:	00 
c0107b7c:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107b83:	e8 68 92 ff ff       	call   c0100df0 <__panic>
     assert(in_tick==0);
c0107b88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107b8c:	74 24                	je     c0107bb2 <_fifo_swap_out_victim+0x63>
c0107b8e:	c7 44 24 0c 24 de 10 	movl   $0xc010de24,0xc(%esp)
c0107b95:	c0 
c0107b96:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107b9d:	c0 
c0107b9e:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107ba5:	00 
c0107ba6:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107bad:	e8 3e 92 ff ff       	call   c0100df0 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *le = head->prev;
c0107bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bb5:	8b 00                	mov    (%eax),%eax
c0107bb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0107bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bbd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107bc0:	75 24                	jne    c0107be6 <_fifo_swap_out_victim+0x97>
c0107bc2:	c7 44 24 0c 2f de 10 	movl   $0xc010de2f,0xc(%esp)
c0107bc9:	c0 
c0107bca:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107bd1:	c0 
c0107bd2:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107bd9:	00 
c0107bda:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107be1:	e8 0a 92 ff ff       	call   c0100df0 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0107be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107be9:	83 e8 14             	sub    $0x14,%eax
c0107bec:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bf2:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107bf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bf8:	8b 40 04             	mov    0x4(%eax),%eax
c0107bfb:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107bfe:	8b 12                	mov    (%edx),%edx
c0107c00:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107c03:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c09:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c0c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107c0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107c15:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0107c17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107c1b:	75 24                	jne    c0107c41 <_fifo_swap_out_victim+0xf2>
c0107c1d:	c7 44 24 0c 38 de 10 	movl   $0xc010de38,0xc(%esp)
c0107c24:	c0 
c0107c25:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107c2c:	c0 
c0107c2d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0107c34:	00 
c0107c35:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107c3c:	e8 af 91 ff ff       	call   c0100df0 <__panic>
     *ptr_page = p;
c0107c41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c44:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107c47:	89 10                	mov    %edx,(%eax)
     return 0;
c0107c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107c4e:	c9                   	leave  
c0107c4f:	c3                   	ret    

c0107c50 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107c50:	55                   	push   %ebp
c0107c51:	89 e5                	mov    %esp,%ebp
c0107c53:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107c56:	c7 04 24 44 de 10 c0 	movl   $0xc010de44,(%esp)
c0107c5d:	e8 02 87 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107c62:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107c67:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107c6a:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107c6f:	83 f8 04             	cmp    $0x4,%eax
c0107c72:	74 24                	je     c0107c98 <_fifo_check_swap+0x48>
c0107c74:	c7 44 24 0c 6a de 10 	movl   $0xc010de6a,0xc(%esp)
c0107c7b:	c0 
c0107c7c:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107c83:	c0 
c0107c84:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0107c8b:	00 
c0107c8c:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107c93:	e8 58 91 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107c98:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c0107c9f:	e8 c0 86 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107ca4:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107ca9:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107cac:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107cb1:	83 f8 04             	cmp    $0x4,%eax
c0107cb4:	74 24                	je     c0107cda <_fifo_check_swap+0x8a>
c0107cb6:	c7 44 24 0c 6a de 10 	movl   $0xc010de6a,0xc(%esp)
c0107cbd:	c0 
c0107cbe:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107cc5:	c0 
c0107cc6:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0107ccd:	00 
c0107cce:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107cd5:	e8 16 91 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107cda:	c7 04 24 a4 de 10 c0 	movl   $0xc010dea4,(%esp)
c0107ce1:	e8 7e 86 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107ce6:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107ceb:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107cee:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107cf3:	83 f8 04             	cmp    $0x4,%eax
c0107cf6:	74 24                	je     c0107d1c <_fifo_check_swap+0xcc>
c0107cf8:	c7 44 24 0c 6a de 10 	movl   $0xc010de6a,0xc(%esp)
c0107cff:	c0 
c0107d00:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107d07:	c0 
c0107d08:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0107d0f:	00 
c0107d10:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107d17:	e8 d4 90 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107d1c:	c7 04 24 cc de 10 c0 	movl   $0xc010decc,(%esp)
c0107d23:	e8 3c 86 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107d28:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107d2d:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107d30:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107d35:	83 f8 04             	cmp    $0x4,%eax
c0107d38:	74 24                	je     c0107d5e <_fifo_check_swap+0x10e>
c0107d3a:	c7 44 24 0c 6a de 10 	movl   $0xc010de6a,0xc(%esp)
c0107d41:	c0 
c0107d42:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107d49:	c0 
c0107d4a:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c0107d51:	00 
c0107d52:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107d59:	e8 92 90 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107d5e:	c7 04 24 f4 de 10 c0 	movl   $0xc010def4,(%esp)
c0107d65:	e8 fa 85 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107d6a:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107d6f:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0107d72:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107d77:	83 f8 05             	cmp    $0x5,%eax
c0107d7a:	74 24                	je     c0107da0 <_fifo_check_swap+0x150>
c0107d7c:	c7 44 24 0c 1a df 10 	movl   $0xc010df1a,0xc(%esp)
c0107d83:	c0 
c0107d84:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107d8b:	c0 
c0107d8c:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0107d93:	00 
c0107d94:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107d9b:	e8 50 90 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107da0:	c7 04 24 cc de 10 c0 	movl   $0xc010decc,(%esp)
c0107da7:	e8 b8 85 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107dac:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107db1:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107db4:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107db9:	83 f8 05             	cmp    $0x5,%eax
c0107dbc:	74 24                	je     c0107de2 <_fifo_check_swap+0x192>
c0107dbe:	c7 44 24 0c 1a df 10 	movl   $0xc010df1a,0xc(%esp)
c0107dc5:	c0 
c0107dc6:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107dcd:	c0 
c0107dce:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0107dd5:	00 
c0107dd6:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107ddd:	e8 0e 90 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107de2:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c0107de9:	e8 76 85 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107dee:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107df3:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107df6:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107dfb:	83 f8 06             	cmp    $0x6,%eax
c0107dfe:	74 24                	je     c0107e24 <_fifo_check_swap+0x1d4>
c0107e00:	c7 44 24 0c 29 df 10 	movl   $0xc010df29,0xc(%esp)
c0107e07:	c0 
c0107e08:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107e0f:	c0 
c0107e10:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0107e17:	00 
c0107e18:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107e1f:	e8 cc 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107e24:	c7 04 24 cc de 10 c0 	movl   $0xc010decc,(%esp)
c0107e2b:	e8 34 85 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107e30:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107e35:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107e38:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107e3d:	83 f8 07             	cmp    $0x7,%eax
c0107e40:	74 24                	je     c0107e66 <_fifo_check_swap+0x216>
c0107e42:	c7 44 24 0c 38 df 10 	movl   $0xc010df38,0xc(%esp)
c0107e49:	c0 
c0107e4a:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107e51:	c0 
c0107e52:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107e59:	00 
c0107e5a:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107e61:	e8 8a 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107e66:	c7 04 24 44 de 10 c0 	movl   $0xc010de44,(%esp)
c0107e6d:	e8 f2 84 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107e72:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107e77:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107e7a:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107e7f:	83 f8 08             	cmp    $0x8,%eax
c0107e82:	74 24                	je     c0107ea8 <_fifo_check_swap+0x258>
c0107e84:	c7 44 24 0c 47 df 10 	movl   $0xc010df47,0xc(%esp)
c0107e8b:	c0 
c0107e8c:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107e93:	c0 
c0107e94:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107e9b:	00 
c0107e9c:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107ea3:	e8 48 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107ea8:	c7 04 24 a4 de 10 c0 	movl   $0xc010dea4,(%esp)
c0107eaf:	e8 b0 84 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107eb4:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107eb9:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107ebc:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107ec1:	83 f8 09             	cmp    $0x9,%eax
c0107ec4:	74 24                	je     c0107eea <_fifo_check_swap+0x29a>
c0107ec6:	c7 44 24 0c 56 df 10 	movl   $0xc010df56,0xc(%esp)
c0107ecd:	c0 
c0107ece:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107ed5:	c0 
c0107ed6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0107edd:	00 
c0107ede:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107ee5:	e8 06 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107eea:	c7 04 24 f4 de 10 c0 	movl   $0xc010def4,(%esp)
c0107ef1:	e8 6e 84 ff ff       	call   c0100364 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107ef6:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107efb:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107efe:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107f03:	83 f8 0a             	cmp    $0xa,%eax
c0107f06:	74 24                	je     c0107f2c <_fifo_check_swap+0x2dc>
c0107f08:	c7 44 24 0c 65 df 10 	movl   $0xc010df65,0xc(%esp)
c0107f0f:	c0 
c0107f10:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107f17:	c0 
c0107f18:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0107f1f:	00 
c0107f20:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107f27:	e8 c4 8e ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107f2c:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c0107f33:	e8 2c 84 ff ff       	call   c0100364 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107f38:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107f3d:	0f b6 00             	movzbl (%eax),%eax
c0107f40:	3c 0a                	cmp    $0xa,%al
c0107f42:	74 24                	je     c0107f68 <_fifo_check_swap+0x318>
c0107f44:	c7 44 24 0c 78 df 10 	movl   $0xc010df78,0xc(%esp)
c0107f4b:	c0 
c0107f4c:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107f53:	c0 
c0107f54:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107f5b:	00 
c0107f5c:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107f63:	e8 88 8e ff ff       	call   c0100df0 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107f68:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107f6d:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0107f70:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0107f75:	83 f8 0b             	cmp    $0xb,%eax
c0107f78:	74 24                	je     c0107f9e <_fifo_check_swap+0x34e>
c0107f7a:	c7 44 24 0c 99 df 10 	movl   $0xc010df99,0xc(%esp)
c0107f81:	c0 
c0107f82:	c7 44 24 08 ee dd 10 	movl   $0xc010ddee,0x8(%esp)
c0107f89:	c0 
c0107f8a:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0107f91:	00 
c0107f92:	c7 04 24 03 de 10 c0 	movl   $0xc010de03,(%esp)
c0107f99:	e8 52 8e ff ff       	call   c0100df0 <__panic>
    return 0;
c0107f9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107fa3:	c9                   	leave  
c0107fa4:	c3                   	ret    

c0107fa5 <_fifo_init>:


static int
_fifo_init(void)
{
c0107fa5:	55                   	push   %ebp
c0107fa6:	89 e5                	mov    %esp,%ebp
    return 0;
c0107fa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107fad:	5d                   	pop    %ebp
c0107fae:	c3                   	ret    

c0107faf <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107faf:	55                   	push   %ebp
c0107fb0:	89 e5                	mov    %esp,%ebp
    return 0;
c0107fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107fb7:	5d                   	pop    %ebp
c0107fb8:	c3                   	ret    

c0107fb9 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0107fb9:	55                   	push   %ebp
c0107fba:	89 e5                	mov    %esp,%ebp
c0107fbc:	b8 00 00 00 00       	mov    $0x0,%eax
c0107fc1:	5d                   	pop    %ebp
c0107fc2:	c3                   	ret    

c0107fc3 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0107fc3:	55                   	push   %ebp
c0107fc4:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0107fc6:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c0107fcf:	5d                   	pop    %ebp
c0107fd0:	c3                   	ret    

c0107fd1 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0107fd1:	55                   	push   %ebp
c0107fd2:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0107fd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fd7:	8b 40 18             	mov    0x18(%eax),%eax
}
c0107fda:	5d                   	pop    %ebp
c0107fdb:	c3                   	ret    

c0107fdc <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c0107fdc:	55                   	push   %ebp
c0107fdd:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c0107fdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fe2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107fe5:	89 50 18             	mov    %edx,0x18(%eax)
}
c0107fe8:	5d                   	pop    %ebp
c0107fe9:	c3                   	ret    

c0107fea <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107fea:	55                   	push   %ebp
c0107feb:	89 e5                	mov    %esp,%ebp
c0107fed:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107ff0:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ff3:	c1 e8 0c             	shr    $0xc,%eax
c0107ff6:	89 c2                	mov    %eax,%edx
c0107ff8:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0107ffd:	39 c2                	cmp    %eax,%edx
c0107fff:	72 1c                	jb     c010801d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0108001:	c7 44 24 08 bc df 10 	movl   $0xc010dfbc,0x8(%esp)
c0108008:	c0 
c0108009:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0108010:	00 
c0108011:	c7 04 24 db df 10 c0 	movl   $0xc010dfdb,(%esp)
c0108018:	e8 d3 8d ff ff       	call   c0100df0 <__panic>
    }
    return &pages[PPN(pa)];
c010801d:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0108022:	8b 55 08             	mov    0x8(%ebp),%edx
c0108025:	c1 ea 0c             	shr    $0xc,%edx
c0108028:	c1 e2 05             	shl    $0x5,%edx
c010802b:	01 d0                	add    %edx,%eax
}
c010802d:	c9                   	leave  
c010802e:	c3                   	ret    

c010802f <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c010802f:	55                   	push   %ebp
c0108030:	89 e5                	mov    %esp,%ebp
c0108032:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0108035:	8b 45 08             	mov    0x8(%ebp),%eax
c0108038:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010803d:	89 04 24             	mov    %eax,(%esp)
c0108040:	e8 a5 ff ff ff       	call   c0107fea <pa2page>
}
c0108045:	c9                   	leave  
c0108046:	c3                   	ret    

c0108047 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0108047:	55                   	push   %ebp
c0108048:	89 e5                	mov    %esp,%ebp
c010804a:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c010804d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108054:	e8 71 cd ff ff       	call   c0104dca <kmalloc>
c0108059:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c010805c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108060:	74 79                	je     c01080db <mm_create+0x94>
        list_init(&(mm->mmap_list));
c0108062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108065:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0108068:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010806b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010806e:	89 50 04             	mov    %edx,0x4(%eax)
c0108071:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108074:	8b 50 04             	mov    0x4(%eax),%edx
c0108077:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010807a:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c010807c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010807f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0108086:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108089:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0108090:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108093:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c010809a:	a1 2c 10 1b c0       	mov    0xc01b102c,%eax
c010809f:	85 c0                	test   %eax,%eax
c01080a1:	74 0d                	je     c01080b0 <mm_create+0x69>
c01080a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080a6:	89 04 24             	mov    %eax,(%esp)
c01080a9:	e8 92 ee ff ff       	call   c0106f40 <swap_init_mm>
c01080ae:	eb 0a                	jmp    c01080ba <mm_create+0x73>
        else mm->sm_priv = NULL;
c01080b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080b3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c01080ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01080c1:	00 
c01080c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080c5:	89 04 24             	mov    %eax,(%esp)
c01080c8:	e8 0f ff ff ff       	call   c0107fdc <set_mm_count>
        lock_init(&(mm->mm_lock));
c01080cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080d0:	83 c0 1c             	add    $0x1c,%eax
c01080d3:	89 04 24             	mov    %eax,(%esp)
c01080d6:	e8 e8 fe ff ff       	call   c0107fc3 <lock_init>
    }    
    return mm;
c01080db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01080de:	c9                   	leave  
c01080df:	c3                   	ret    

c01080e0 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01080e0:	55                   	push   %ebp
c01080e1:	89 e5                	mov    %esp,%ebp
c01080e3:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01080e6:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01080ed:	e8 d8 cc ff ff       	call   c0104dca <kmalloc>
c01080f2:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01080f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01080f9:	74 1b                	je     c0108116 <vma_create+0x36>
        vma->vm_start = vm_start;
c01080fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080fe:	8b 55 08             	mov    0x8(%ebp),%edx
c0108101:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0108104:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108107:	8b 55 0c             	mov    0xc(%ebp),%edx
c010810a:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010810d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108110:	8b 55 10             	mov    0x10(%ebp),%edx
c0108113:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0108116:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108119:	c9                   	leave  
c010811a:	c3                   	ret    

c010811b <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c010811b:	55                   	push   %ebp
c010811c:	89 e5                	mov    %esp,%ebp
c010811e:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0108121:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0108128:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010812c:	0f 84 95 00 00 00    	je     c01081c7 <find_vma+0xac>
        vma = mm->mmap_cache;
c0108132:	8b 45 08             	mov    0x8(%ebp),%eax
c0108135:	8b 40 08             	mov    0x8(%eax),%eax
c0108138:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c010813b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010813f:	74 16                	je     c0108157 <find_vma+0x3c>
c0108141:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108144:	8b 40 04             	mov    0x4(%eax),%eax
c0108147:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010814a:	77 0b                	ja     c0108157 <find_vma+0x3c>
c010814c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010814f:	8b 40 08             	mov    0x8(%eax),%eax
c0108152:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108155:	77 61                	ja     c01081b8 <find_vma+0x9d>
                bool found = 0;
c0108157:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c010815e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108161:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108164:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108167:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c010816a:	eb 28                	jmp    c0108194 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010816f:	83 e8 10             	sub    $0x10,%eax
c0108172:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0108175:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108178:	8b 40 04             	mov    0x4(%eax),%eax
c010817b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010817e:	77 14                	ja     c0108194 <find_vma+0x79>
c0108180:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108183:	8b 40 08             	mov    0x8(%eax),%eax
c0108186:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108189:	76 09                	jbe    c0108194 <find_vma+0x79>
                        found = 1;
c010818b:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0108192:	eb 17                	jmp    c01081ab <find_vma+0x90>
c0108194:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108197:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010819a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010819d:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01081a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01081a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081a6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01081a9:	75 c1                	jne    c010816c <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01081ab:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01081af:	75 07                	jne    c01081b8 <find_vma+0x9d>
                    vma = NULL;
c01081b1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01081b8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01081bc:	74 09                	je     c01081c7 <find_vma+0xac>
            mm->mmap_cache = vma;
c01081be:	8b 45 08             	mov    0x8(%ebp),%eax
c01081c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01081c4:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01081c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01081ca:	c9                   	leave  
c01081cb:	c3                   	ret    

c01081cc <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01081cc:	55                   	push   %ebp
c01081cd:	89 e5                	mov    %esp,%ebp
c01081cf:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01081d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01081d5:	8b 50 04             	mov    0x4(%eax),%edx
c01081d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01081db:	8b 40 08             	mov    0x8(%eax),%eax
c01081de:	39 c2                	cmp    %eax,%edx
c01081e0:	72 24                	jb     c0108206 <check_vma_overlap+0x3a>
c01081e2:	c7 44 24 0c e9 df 10 	movl   $0xc010dfe9,0xc(%esp)
c01081e9:	c0 
c01081ea:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c01081f1:	c0 
c01081f2:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01081f9:	00 
c01081fa:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108201:	e8 ea 8b ff ff       	call   c0100df0 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0108206:	8b 45 08             	mov    0x8(%ebp),%eax
c0108209:	8b 50 08             	mov    0x8(%eax),%edx
c010820c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010820f:	8b 40 04             	mov    0x4(%eax),%eax
c0108212:	39 c2                	cmp    %eax,%edx
c0108214:	76 24                	jbe    c010823a <check_vma_overlap+0x6e>
c0108216:	c7 44 24 0c 2c e0 10 	movl   $0xc010e02c,0xc(%esp)
c010821d:	c0 
c010821e:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108225:	c0 
c0108226:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010822d:	00 
c010822e:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108235:	e8 b6 8b ff ff       	call   c0100df0 <__panic>
    assert(next->vm_start < next->vm_end);
c010823a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010823d:	8b 50 04             	mov    0x4(%eax),%edx
c0108240:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108243:	8b 40 08             	mov    0x8(%eax),%eax
c0108246:	39 c2                	cmp    %eax,%edx
c0108248:	72 24                	jb     c010826e <check_vma_overlap+0xa2>
c010824a:	c7 44 24 0c 4b e0 10 	movl   $0xc010e04b,0xc(%esp)
c0108251:	c0 
c0108252:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108259:	c0 
c010825a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0108261:	00 
c0108262:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108269:	e8 82 8b ff ff       	call   c0100df0 <__panic>
}
c010826e:	c9                   	leave  
c010826f:	c3                   	ret    

c0108270 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0108270:	55                   	push   %ebp
c0108271:	89 e5                	mov    %esp,%ebp
c0108273:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0108276:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108279:	8b 50 04             	mov    0x4(%eax),%edx
c010827c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010827f:	8b 40 08             	mov    0x8(%eax),%eax
c0108282:	39 c2                	cmp    %eax,%edx
c0108284:	72 24                	jb     c01082aa <insert_vma_struct+0x3a>
c0108286:	c7 44 24 0c 69 e0 10 	movl   $0xc010e069,0xc(%esp)
c010828d:	c0 
c010828e:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108295:	c0 
c0108296:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c010829d:	00 
c010829e:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c01082a5:	e8 46 8b ff ff       	call   c0100df0 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01082aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01082ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01082b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082b3:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01082b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01082bc:	eb 21                	jmp    c01082df <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01082be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082c1:	83 e8 10             	sub    $0x10,%eax
c01082c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01082c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082ca:	8b 50 04             	mov    0x4(%eax),%edx
c01082cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082d0:	8b 40 04             	mov    0x4(%eax),%eax
c01082d3:	39 c2                	cmp    %eax,%edx
c01082d5:	76 02                	jbe    c01082d9 <insert_vma_struct+0x69>
                break;
c01082d7:	eb 1d                	jmp    c01082f6 <insert_vma_struct+0x86>
            }
            le_prev = le;
c01082d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01082df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01082e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082e8:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01082eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01082ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082f1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01082f4:	75 c8                	jne    c01082be <insert_vma_struct+0x4e>
c01082f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01082fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01082ff:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0108302:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0108305:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108308:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010830b:	74 15                	je     c0108322 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c010830d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108310:	8d 50 f0             	lea    -0x10(%eax),%edx
c0108313:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108316:	89 44 24 04          	mov    %eax,0x4(%esp)
c010831a:	89 14 24             	mov    %edx,(%esp)
c010831d:	e8 aa fe ff ff       	call   c01081cc <check_vma_overlap>
    }
    if (le_next != list) {
c0108322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108325:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108328:	74 15                	je     c010833f <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010832a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010832d:	83 e8 10             	sub    $0x10,%eax
c0108330:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108334:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108337:	89 04 24             	mov    %eax,(%esp)
c010833a:	e8 8d fe ff ff       	call   c01081cc <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010833f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108342:	8b 55 08             	mov    0x8(%ebp),%edx
c0108345:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0108347:	8b 45 0c             	mov    0xc(%ebp),%eax
c010834a:	8d 50 10             	lea    0x10(%eax),%edx
c010834d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108350:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108353:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108356:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108359:	8b 40 04             	mov    0x4(%eax),%eax
c010835c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010835f:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0108362:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108365:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0108368:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010836b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010836e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108371:	89 10                	mov    %edx,(%eax)
c0108373:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108376:	8b 10                	mov    (%eax),%edx
c0108378:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010837b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010837e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108381:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108384:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108387:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010838a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010838d:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c010838f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108392:	8b 40 10             	mov    0x10(%eax),%eax
c0108395:	8d 50 01             	lea    0x1(%eax),%edx
c0108398:	8b 45 08             	mov    0x8(%ebp),%eax
c010839b:	89 50 10             	mov    %edx,0x10(%eax)
}
c010839e:	c9                   	leave  
c010839f:	c3                   	ret    

c01083a0 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01083a0:	55                   	push   %ebp
c01083a1:	89 e5                	mov    %esp,%ebp
c01083a3:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c01083a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01083a9:	89 04 24             	mov    %eax,(%esp)
c01083ac:	e8 20 fc ff ff       	call   c0107fd1 <mm_count>
c01083b1:	85 c0                	test   %eax,%eax
c01083b3:	74 24                	je     c01083d9 <mm_destroy+0x39>
c01083b5:	c7 44 24 0c 85 e0 10 	movl   $0xc010e085,0xc(%esp)
c01083bc:	c0 
c01083bd:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c01083c4:	c0 
c01083c5:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01083cc:	00 
c01083cd:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c01083d4:	e8 17 8a ff ff       	call   c0100df0 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c01083d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01083dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01083df:	eb 36                	jmp    c0108417 <mm_destroy+0x77>
c01083e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01083e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083ea:	8b 40 04             	mov    0x4(%eax),%eax
c01083ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01083f0:	8b 12                	mov    (%edx),%edx
c01083f2:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01083f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01083f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01083fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01083fe:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108401:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108404:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108407:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0108409:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010840c:	83 e8 10             	sub    $0x10,%eax
c010840f:	89 04 24             	mov    %eax,(%esp)
c0108412:	e8 ce c9 ff ff       	call   c0104de5 <kfree>
c0108417:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010841a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010841d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108420:	8b 40 04             	mov    0x4(%eax),%eax
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0108423:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108426:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108429:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010842c:	75 b3                	jne    c01083e1 <mm_destroy+0x41>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c010842e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108431:	89 04 24             	mov    %eax,(%esp)
c0108434:	e8 ac c9 ff ff       	call   c0104de5 <kfree>
    mm=NULL;
c0108439:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0108440:	c9                   	leave  
c0108441:	c3                   	ret    

c0108442 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c0108442:	55                   	push   %ebp
c0108443:	89 e5                	mov    %esp,%ebp
c0108445:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c0108448:	8b 45 0c             	mov    0xc(%ebp),%eax
c010844b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010844e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108451:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108456:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108459:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0108460:	8b 45 10             	mov    0x10(%ebp),%eax
c0108463:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108466:	01 c2                	add    %eax,%edx
c0108468:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010846b:	01 d0                	add    %edx,%eax
c010846d:	83 e8 01             	sub    $0x1,%eax
c0108470:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108476:	ba 00 00 00 00       	mov    $0x0,%edx
c010847b:	f7 75 e8             	divl   -0x18(%ebp)
c010847e:	89 d0                	mov    %edx,%eax
c0108480:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108483:	29 c2                	sub    %eax,%edx
c0108485:	89 d0                	mov    %edx,%eax
c0108487:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c010848a:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0108491:	76 11                	jbe    c01084a4 <mm_map+0x62>
c0108493:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108496:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108499:	73 09                	jae    c01084a4 <mm_map+0x62>
c010849b:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c01084a2:	76 0a                	jbe    c01084ae <mm_map+0x6c>
        return -E_INVAL;
c01084a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01084a9:	e9 ae 00 00 00       	jmp    c010855c <mm_map+0x11a>
    }

    assert(mm != NULL);
c01084ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01084b2:	75 24                	jne    c01084d8 <mm_map+0x96>
c01084b4:	c7 44 24 0c 97 e0 10 	movl   $0xc010e097,0xc(%esp)
c01084bb:	c0 
c01084bc:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c01084c3:	c0 
c01084c4:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c01084cb:	00 
c01084cc:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c01084d3:	e8 18 89 ff ff       	call   c0100df0 <__panic>

    int ret = -E_INVAL;
c01084d8:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c01084df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01084e9:	89 04 24             	mov    %eax,(%esp)
c01084ec:	e8 2a fc ff ff       	call   c010811b <find_vma>
c01084f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01084f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01084f8:	74 0d                	je     c0108507 <mm_map+0xc5>
c01084fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01084fd:	8b 40 04             	mov    0x4(%eax),%eax
c0108500:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108503:	73 02                	jae    c0108507 <mm_map+0xc5>
        goto out;
c0108505:	eb 52                	jmp    c0108559 <mm_map+0x117>
    }
    ret = -E_NO_MEM;
c0108507:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c010850e:	8b 45 14             	mov    0x14(%ebp),%eax
c0108511:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108515:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108518:	89 44 24 04          	mov    %eax,0x4(%esp)
c010851c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010851f:	89 04 24             	mov    %eax,(%esp)
c0108522:	e8 b9 fb ff ff       	call   c01080e0 <vma_create>
c0108527:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010852a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010852e:	75 02                	jne    c0108532 <mm_map+0xf0>
        goto out;
c0108530:	eb 27                	jmp    c0108559 <mm_map+0x117>
    }
    insert_vma_struct(mm, vma);
c0108532:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108535:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108539:	8b 45 08             	mov    0x8(%ebp),%eax
c010853c:	89 04 24             	mov    %eax,(%esp)
c010853f:	e8 2c fd ff ff       	call   c0108270 <insert_vma_struct>
    if (vma_store != NULL) {
c0108544:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108548:	74 08                	je     c0108552 <mm_map+0x110>
        *vma_store = vma;
c010854a:	8b 45 18             	mov    0x18(%ebp),%eax
c010854d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108550:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0108552:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

out:
    return ret;
c0108559:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010855c:	c9                   	leave  
c010855d:	c3                   	ret    

c010855e <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c010855e:	55                   	push   %ebp
c010855f:	89 e5                	mov    %esp,%ebp
c0108561:	56                   	push   %esi
c0108562:	53                   	push   %ebx
c0108563:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c0108566:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010856a:	74 06                	je     c0108572 <dup_mmap+0x14>
c010856c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108570:	75 24                	jne    c0108596 <dup_mmap+0x38>
c0108572:	c7 44 24 0c a2 e0 10 	movl   $0xc010e0a2,0xc(%esp)
c0108579:	c0 
c010857a:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108581:	c0 
c0108582:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0108589:	00 
c010858a:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108591:	e8 5a 88 ff ff       	call   c0100df0 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0108596:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108599:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010859c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010859f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c01085a2:	e9 92 00 00 00       	jmp    c0108639 <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c01085a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085aa:	83 e8 10             	sub    $0x10,%eax
c01085ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c01085b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085b3:	8b 48 0c             	mov    0xc(%eax),%ecx
c01085b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085b9:	8b 50 08             	mov    0x8(%eax),%edx
c01085bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085bf:	8b 40 04             	mov    0x4(%eax),%eax
c01085c2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01085c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01085ca:	89 04 24             	mov    %eax,(%esp)
c01085cd:	e8 0e fb ff ff       	call   c01080e0 <vma_create>
c01085d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c01085d5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01085d9:	75 07                	jne    c01085e2 <dup_mmap+0x84>
            return -E_NO_MEM;
c01085db:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01085e0:	eb 76                	jmp    c0108658 <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c01085e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01085ec:	89 04 24             	mov    %eax,(%esp)
c01085ef:	e8 7c fc ff ff       	call   c0108270 <insert_vma_struct>

        bool share = 0;
c01085f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c01085fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085fe:	8b 58 08             	mov    0x8(%eax),%ebx
c0108601:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108604:	8b 48 04             	mov    0x4(%eax),%ecx
c0108607:	8b 45 0c             	mov    0xc(%ebp),%eax
c010860a:	8b 50 0c             	mov    0xc(%eax),%edx
c010860d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108610:	8b 40 0c             	mov    0xc(%eax),%eax
c0108613:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0108616:	89 74 24 10          	mov    %esi,0x10(%esp)
c010861a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010861e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108622:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108626:	89 04 24             	mov    %eax,(%esp)
c0108629:	e8 e2 d6 ff ff       	call   c0105d10 <copy_range>
c010862e:	85 c0                	test   %eax,%eax
c0108630:	74 07                	je     c0108639 <dup_mmap+0xdb>
            return -E_NO_MEM;
c0108632:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0108637:	eb 1f                	jmp    c0108658 <dup_mmap+0xfa>
c0108639:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010863c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c010863f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108642:	8b 00                	mov    (%eax),%eax

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
c0108644:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108647:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010864a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010864d:	0f 85 54 ff ff ff    	jne    c01085a7 <dup_mmap+0x49>
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
c0108653:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108658:	83 c4 40             	add    $0x40,%esp
c010865b:	5b                   	pop    %ebx
c010865c:	5e                   	pop    %esi
c010865d:	5d                   	pop    %ebp
c010865e:	c3                   	ret    

c010865f <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c010865f:	55                   	push   %ebp
c0108660:	89 e5                	mov    %esp,%ebp
c0108662:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0108665:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108669:	74 0f                	je     c010867a <exit_mmap+0x1b>
c010866b:	8b 45 08             	mov    0x8(%ebp),%eax
c010866e:	89 04 24             	mov    %eax,(%esp)
c0108671:	e8 5b f9 ff ff       	call   c0107fd1 <mm_count>
c0108676:	85 c0                	test   %eax,%eax
c0108678:	74 24                	je     c010869e <exit_mmap+0x3f>
c010867a:	c7 44 24 0c c0 e0 10 	movl   $0xc010e0c0,0xc(%esp)
c0108681:	c0 
c0108682:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108689:	c0 
c010868a:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0108691:	00 
c0108692:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108699:	e8 52 87 ff ff       	call   c0100df0 <__panic>
    pde_t *pgdir = mm->pgdir;
c010869e:	8b 45 08             	mov    0x8(%ebp),%eax
c01086a1:	8b 40 0c             	mov    0xc(%eax),%eax
c01086a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c01086a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01086aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01086ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c01086b3:	eb 28                	jmp    c01086dd <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c01086b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086b8:	83 e8 10             	sub    $0x10,%eax
c01086bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c01086be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01086c1:	8b 50 08             	mov    0x8(%eax),%edx
c01086c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01086c7:	8b 40 04             	mov    0x4(%eax),%eax
c01086ca:	89 54 24 08          	mov    %edx,0x8(%esp)
c01086ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01086d5:	89 04 24             	mov    %eax,(%esp)
c01086d8:	e8 38 d4 ff ff       	call   c0105b15 <unmap_range>
c01086dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01086e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01086e6:	8b 40 04             	mov    0x4(%eax),%eax
void
exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
c01086e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01086ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01086f2:	75 c1                	jne    c01086b5 <exit_mmap+0x56>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c01086f4:	eb 28                	jmp    c010871e <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c01086f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086f9:	83 e8 10             	sub    $0x10,%eax
c01086fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c01086ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108702:	8b 50 08             	mov    0x8(%eax),%edx
c0108705:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108708:	8b 40 04             	mov    0x4(%eax),%eax
c010870b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010870f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108713:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108716:	89 04 24             	mov    %eax,(%esp)
c0108719:	e8 eb d4 ff ff       	call   c0105c09 <exit_range>
c010871e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108721:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108724:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108727:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c010872a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010872d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108730:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108733:	75 c1                	jne    c01086f6 <exit_mmap+0x97>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}
c0108735:	c9                   	leave  
c0108736:	c3                   	ret    

c0108737 <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c0108737:	55                   	push   %ebp
c0108738:	89 e5                	mov    %esp,%ebp
c010873a:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c010873d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108740:	8b 55 18             	mov    0x18(%ebp),%edx
c0108743:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108747:	8b 55 14             	mov    0x14(%ebp),%edx
c010874a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010874e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108752:	8b 45 08             	mov    0x8(%ebp),%eax
c0108755:	89 04 24             	mov    %eax,(%esp)
c0108758:	e8 a6 09 00 00       	call   c0109103 <user_mem_check>
c010875d:	85 c0                	test   %eax,%eax
c010875f:	75 07                	jne    c0108768 <copy_from_user+0x31>
        return 0;
c0108761:	b8 00 00 00 00       	mov    $0x0,%eax
c0108766:	eb 1e                	jmp    c0108786 <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0108768:	8b 45 14             	mov    0x14(%ebp),%eax
c010876b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010876f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108772:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108776:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108779:	89 04 24             	mov    %eax,(%esp)
c010877c:	e8 a2 3c 00 00       	call   c010c423 <memcpy>
    return 1;
c0108781:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0108786:	c9                   	leave  
c0108787:	c3                   	ret    

c0108788 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0108788:	55                   	push   %ebp
c0108789:	89 e5                	mov    %esp,%ebp
c010878b:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c010878e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108791:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108798:	00 
c0108799:	8b 55 14             	mov    0x14(%ebp),%edx
c010879c:	89 54 24 08          	mov    %edx,0x8(%esp)
c01087a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01087a7:	89 04 24             	mov    %eax,(%esp)
c01087aa:	e8 54 09 00 00       	call   c0109103 <user_mem_check>
c01087af:	85 c0                	test   %eax,%eax
c01087b1:	75 07                	jne    c01087ba <copy_to_user+0x32>
        return 0;
c01087b3:	b8 00 00 00 00       	mov    $0x0,%eax
c01087b8:	eb 1e                	jmp    c01087d8 <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c01087ba:	8b 45 14             	mov    0x14(%ebp),%eax
c01087bd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01087c1:	8b 45 10             	mov    0x10(%ebp),%eax
c01087c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087cb:	89 04 24             	mov    %eax,(%esp)
c01087ce:	e8 50 3c 00 00       	call   c010c423 <memcpy>
    return 1;
c01087d3:	b8 01 00 00 00       	mov    $0x1,%eax
}
c01087d8:	c9                   	leave  
c01087d9:	c3                   	ret    

c01087da <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01087da:	55                   	push   %ebp
c01087db:	89 e5                	mov    %esp,%ebp
c01087dd:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01087e0:	e8 02 00 00 00       	call   c01087e7 <check_vmm>
}
c01087e5:	c9                   	leave  
c01087e6:	c3                   	ret    

c01087e7 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01087e7:	55                   	push   %ebp
c01087e8:	89 e5                	mov    %esp,%ebp
c01087ea:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01087ed:	e8 ea ca ff ff       	call   c01052dc <nr_free_pages>
c01087f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01087f5:	e8 13 00 00 00       	call   c010880d <check_vma_struct>
    check_pgfault();
c01087fa:	e8 a7 04 00 00       	call   c0108ca6 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c01087ff:	c7 04 24 e0 e0 10 c0 	movl   $0xc010e0e0,(%esp)
c0108806:	e8 59 7b ff ff       	call   c0100364 <cprintf>
}
c010880b:	c9                   	leave  
c010880c:	c3                   	ret    

c010880d <check_vma_struct>:

static void
check_vma_struct(void) {
c010880d:	55                   	push   %ebp
c010880e:	89 e5                	mov    %esp,%ebp
c0108810:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108813:	e8 c4 ca ff ff       	call   c01052dc <nr_free_pages>
c0108818:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c010881b:	e8 27 f8 ff ff       	call   c0108047 <mm_create>
c0108820:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0108823:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108827:	75 24                	jne    c010884d <check_vma_struct+0x40>
c0108829:	c7 44 24 0c 97 e0 10 	movl   $0xc010e097,0xc(%esp)
c0108830:	c0 
c0108831:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108838:	c0 
c0108839:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0108840:	00 
c0108841:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108848:	e8 a3 85 ff ff       	call   c0100df0 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010884d:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108854:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108857:	89 d0                	mov    %edx,%eax
c0108859:	c1 e0 02             	shl    $0x2,%eax
c010885c:	01 d0                	add    %edx,%eax
c010885e:	01 c0                	add    %eax,%eax
c0108860:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0108863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108866:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108869:	eb 70                	jmp    c01088db <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010886b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010886e:	89 d0                	mov    %edx,%eax
c0108870:	c1 e0 02             	shl    $0x2,%eax
c0108873:	01 d0                	add    %edx,%eax
c0108875:	83 c0 02             	add    $0x2,%eax
c0108878:	89 c1                	mov    %eax,%ecx
c010887a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010887d:	89 d0                	mov    %edx,%eax
c010887f:	c1 e0 02             	shl    $0x2,%eax
c0108882:	01 d0                	add    %edx,%eax
c0108884:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010888b:	00 
c010888c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108890:	89 04 24             	mov    %eax,(%esp)
c0108893:	e8 48 f8 ff ff       	call   c01080e0 <vma_create>
c0108898:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c010889b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010889f:	75 24                	jne    c01088c5 <check_vma_struct+0xb8>
c01088a1:	c7 44 24 0c f8 e0 10 	movl   $0xc010e0f8,0xc(%esp)
c01088a8:	c0 
c01088a9:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c01088b0:	c0 
c01088b1:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01088b8:	00 
c01088b9:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c01088c0:	e8 2b 85 ff ff       	call   c0100df0 <__panic>
        insert_vma_struct(mm, vma);
c01088c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01088c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088cf:	89 04 24             	mov    %eax,(%esp)
c01088d2:	e8 99 f9 ff ff       	call   c0108270 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c01088d7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01088db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01088df:	7f 8a                	jg     c010886b <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01088e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088e4:	83 c0 01             	add    $0x1,%eax
c01088e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088ea:	eb 70                	jmp    c010895c <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01088ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088ef:	89 d0                	mov    %edx,%eax
c01088f1:	c1 e0 02             	shl    $0x2,%eax
c01088f4:	01 d0                	add    %edx,%eax
c01088f6:	83 c0 02             	add    $0x2,%eax
c01088f9:	89 c1                	mov    %eax,%ecx
c01088fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088fe:	89 d0                	mov    %edx,%eax
c0108900:	c1 e0 02             	shl    $0x2,%eax
c0108903:	01 d0                	add    %edx,%eax
c0108905:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010890c:	00 
c010890d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108911:	89 04 24             	mov    %eax,(%esp)
c0108914:	e8 c7 f7 ff ff       	call   c01080e0 <vma_create>
c0108919:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c010891c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0108920:	75 24                	jne    c0108946 <check_vma_struct+0x139>
c0108922:	c7 44 24 0c f8 e0 10 	movl   $0xc010e0f8,0xc(%esp)
c0108929:	c0 
c010892a:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108931:	c0 
c0108932:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0108939:	00 
c010893a:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108941:	e8 aa 84 ff ff       	call   c0100df0 <__panic>
        insert_vma_struct(mm, vma);
c0108946:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108949:	89 44 24 04          	mov    %eax,0x4(%esp)
c010894d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108950:	89 04 24             	mov    %eax,(%esp)
c0108953:	e8 18 f9 ff ff       	call   c0108270 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0108958:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010895c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010895f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108962:	7e 88                	jle    c01088ec <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0108964:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108967:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010896a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010896d:	8b 40 04             	mov    0x4(%eax),%eax
c0108970:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0108973:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c010897a:	e9 97 00 00 00       	jmp    c0108a16 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c010897f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108982:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108985:	75 24                	jne    c01089ab <check_vma_struct+0x19e>
c0108987:	c7 44 24 0c 04 e1 10 	movl   $0xc010e104,0xc(%esp)
c010898e:	c0 
c010898f:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108996:	c0 
c0108997:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c010899e:	00 
c010899f:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c01089a6:	e8 45 84 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01089ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089ae:	83 e8 10             	sub    $0x10,%eax
c01089b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01089b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01089b7:	8b 48 04             	mov    0x4(%eax),%ecx
c01089ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089bd:	89 d0                	mov    %edx,%eax
c01089bf:	c1 e0 02             	shl    $0x2,%eax
c01089c2:	01 d0                	add    %edx,%eax
c01089c4:	39 c1                	cmp    %eax,%ecx
c01089c6:	75 17                	jne    c01089df <check_vma_struct+0x1d2>
c01089c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01089cb:	8b 48 08             	mov    0x8(%eax),%ecx
c01089ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089d1:	89 d0                	mov    %edx,%eax
c01089d3:	c1 e0 02             	shl    $0x2,%eax
c01089d6:	01 d0                	add    %edx,%eax
c01089d8:	83 c0 02             	add    $0x2,%eax
c01089db:	39 c1                	cmp    %eax,%ecx
c01089dd:	74 24                	je     c0108a03 <check_vma_struct+0x1f6>
c01089df:	c7 44 24 0c 1c e1 10 	movl   $0xc010e11c,0xc(%esp)
c01089e6:	c0 
c01089e7:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c01089ee:	c0 
c01089ef:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01089f6:	00 
c01089f7:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c01089fe:	e8 ed 83 ff ff       	call   c0100df0 <__panic>
c0108a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a06:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0108a09:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108a0c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0108a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0108a12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a19:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108a1c:	0f 8e 5d ff ff ff    	jle    c010897f <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108a22:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0108a29:	e9 cd 01 00 00       	jmp    c0108bfb <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0108a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a38:	89 04 24             	mov    %eax,(%esp)
c0108a3b:	e8 db f6 ff ff       	call   c010811b <find_vma>
c0108a40:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0108a43:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0108a47:	75 24                	jne    c0108a6d <check_vma_struct+0x260>
c0108a49:	c7 44 24 0c 51 e1 10 	movl   $0xc010e151,0xc(%esp)
c0108a50:	c0 
c0108a51:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108a58:	c0 
c0108a59:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0108a60:	00 
c0108a61:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108a68:	e8 83 83 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0108a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a70:	83 c0 01             	add    $0x1,%eax
c0108a73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a77:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a7a:	89 04 24             	mov    %eax,(%esp)
c0108a7d:	e8 99 f6 ff ff       	call   c010811b <find_vma>
c0108a82:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0108a85:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108a89:	75 24                	jne    c0108aaf <check_vma_struct+0x2a2>
c0108a8b:	c7 44 24 0c 5e e1 10 	movl   $0xc010e15e,0xc(%esp)
c0108a92:	c0 
c0108a93:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108a9a:	c0 
c0108a9b:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0108aa2:	00 
c0108aa3:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108aaa:	e8 41 83 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0108aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ab2:	83 c0 02             	add    $0x2,%eax
c0108ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ab9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108abc:	89 04 24             	mov    %eax,(%esp)
c0108abf:	e8 57 f6 ff ff       	call   c010811b <find_vma>
c0108ac4:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0108ac7:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108acb:	74 24                	je     c0108af1 <check_vma_struct+0x2e4>
c0108acd:	c7 44 24 0c 6b e1 10 	movl   $0xc010e16b,0xc(%esp)
c0108ad4:	c0 
c0108ad5:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108adc:	c0 
c0108add:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0108ae4:	00 
c0108ae5:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108aec:	e8 ff 82 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0108af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108af4:	83 c0 03             	add    $0x3,%eax
c0108af7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108afe:	89 04 24             	mov    %eax,(%esp)
c0108b01:	e8 15 f6 ff ff       	call   c010811b <find_vma>
c0108b06:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0108b09:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0108b0d:	74 24                	je     c0108b33 <check_vma_struct+0x326>
c0108b0f:	c7 44 24 0c 78 e1 10 	movl   $0xc010e178,0xc(%esp)
c0108b16:	c0 
c0108b17:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108b1e:	c0 
c0108b1f:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0108b26:	00 
c0108b27:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108b2e:	e8 bd 82 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0108b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b36:	83 c0 04             	add    $0x4,%eax
c0108b39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b40:	89 04 24             	mov    %eax,(%esp)
c0108b43:	e8 d3 f5 ff ff       	call   c010811b <find_vma>
c0108b48:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0108b4b:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0108b4f:	74 24                	je     c0108b75 <check_vma_struct+0x368>
c0108b51:	c7 44 24 0c 85 e1 10 	movl   $0xc010e185,0xc(%esp)
c0108b58:	c0 
c0108b59:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108b60:	c0 
c0108b61:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0108b68:	00 
c0108b69:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108b70:	e8 7b 82 ff ff       	call   c0100df0 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108b75:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108b78:	8b 50 04             	mov    0x4(%eax),%edx
c0108b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b7e:	39 c2                	cmp    %eax,%edx
c0108b80:	75 10                	jne    c0108b92 <check_vma_struct+0x385>
c0108b82:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108b85:	8b 50 08             	mov    0x8(%eax),%edx
c0108b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b8b:	83 c0 02             	add    $0x2,%eax
c0108b8e:	39 c2                	cmp    %eax,%edx
c0108b90:	74 24                	je     c0108bb6 <check_vma_struct+0x3a9>
c0108b92:	c7 44 24 0c 94 e1 10 	movl   $0xc010e194,0xc(%esp)
c0108b99:	c0 
c0108b9a:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108ba1:	c0 
c0108ba2:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0108ba9:	00 
c0108baa:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108bb1:	e8 3a 82 ff ff       	call   c0100df0 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0108bb6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108bb9:	8b 50 04             	mov    0x4(%eax),%edx
c0108bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bbf:	39 c2                	cmp    %eax,%edx
c0108bc1:	75 10                	jne    c0108bd3 <check_vma_struct+0x3c6>
c0108bc3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108bc6:	8b 50 08             	mov    0x8(%eax),%edx
c0108bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bcc:	83 c0 02             	add    $0x2,%eax
c0108bcf:	39 c2                	cmp    %eax,%edx
c0108bd1:	74 24                	je     c0108bf7 <check_vma_struct+0x3ea>
c0108bd3:	c7 44 24 0c c4 e1 10 	movl   $0xc010e1c4,0xc(%esp)
c0108bda:	c0 
c0108bdb:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108be2:	c0 
c0108be3:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108bea:	00 
c0108beb:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108bf2:	e8 f9 81 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108bf7:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0108bfb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108bfe:	89 d0                	mov    %edx,%eax
c0108c00:	c1 e0 02             	shl    $0x2,%eax
c0108c03:	01 d0                	add    %edx,%eax
c0108c05:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108c08:	0f 8d 20 fe ff ff    	jge    c0108a2e <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108c0e:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108c15:	eb 70                	jmp    c0108c87 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0108c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c21:	89 04 24             	mov    %eax,(%esp)
c0108c24:	e8 f2 f4 ff ff       	call   c010811b <find_vma>
c0108c29:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0108c2c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108c30:	74 27                	je     c0108c59 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0108c32:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108c35:	8b 50 08             	mov    0x8(%eax),%edx
c0108c38:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108c3b:	8b 40 04             	mov    0x4(%eax),%eax
c0108c3e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108c42:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c4d:	c7 04 24 f4 e1 10 c0 	movl   $0xc010e1f4,(%esp)
c0108c54:	e8 0b 77 ff ff       	call   c0100364 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108c59:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108c5d:	74 24                	je     c0108c83 <check_vma_struct+0x476>
c0108c5f:	c7 44 24 0c 19 e2 10 	movl   $0xc010e219,0xc(%esp)
c0108c66:	c0 
c0108c67:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108c6e:	c0 
c0108c6f:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108c76:	00 
c0108c77:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108c7e:	e8 6d 81 ff ff       	call   c0100df0 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108c83:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108c87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108c8b:	79 8a                	jns    c0108c17 <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0108c8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c90:	89 04 24             	mov    %eax,(%esp)
c0108c93:	e8 08 f7 ff ff       	call   c01083a0 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108c98:	c7 04 24 30 e2 10 c0 	movl   $0xc010e230,(%esp)
c0108c9f:	e8 c0 76 ff ff       	call   c0100364 <cprintf>
}
c0108ca4:	c9                   	leave  
c0108ca5:	c3                   	ret    

c0108ca6 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108ca6:	55                   	push   %ebp
c0108ca7:	89 e5                	mov    %esp,%ebp
c0108ca9:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108cac:	e8 2b c6 ff ff       	call   c01052dc <nr_free_pages>
c0108cb1:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108cb4:	e8 8e f3 ff ff       	call   c0108047 <mm_create>
c0108cb9:	a3 ec 31 1b c0       	mov    %eax,0xc01b31ec
    assert(check_mm_struct != NULL);
c0108cbe:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c0108cc3:	85 c0                	test   %eax,%eax
c0108cc5:	75 24                	jne    c0108ceb <check_pgfault+0x45>
c0108cc7:	c7 44 24 0c 4f e2 10 	movl   $0xc010e24f,0xc(%esp)
c0108cce:	c0 
c0108ccf:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108cd6:	c0 
c0108cd7:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0108cde:	00 
c0108cdf:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108ce6:	e8 05 81 ff ff       	call   c0100df0 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108ceb:	a1 ec 31 1b c0       	mov    0xc01b31ec,%eax
c0108cf0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108cf3:	8b 15 00 ca 12 c0    	mov    0xc012ca00,%edx
c0108cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cfc:	89 50 0c             	mov    %edx,0xc(%eax)
c0108cff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d02:	8b 40 0c             	mov    0xc(%eax),%eax
c0108d05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0108d08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d0b:	8b 00                	mov    (%eax),%eax
c0108d0d:	85 c0                	test   %eax,%eax
c0108d0f:	74 24                	je     c0108d35 <check_pgfault+0x8f>
c0108d11:	c7 44 24 0c 67 e2 10 	movl   $0xc010e267,0xc(%esp)
c0108d18:	c0 
c0108d19:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108d20:	c0 
c0108d21:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0108d28:	00 
c0108d29:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108d30:	e8 bb 80 ff ff       	call   c0100df0 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108d35:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108d3c:	00 
c0108d3d:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108d44:	00 
c0108d45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108d4c:	e8 8f f3 ff ff       	call   c01080e0 <vma_create>
c0108d51:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108d54:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108d58:	75 24                	jne    c0108d7e <check_pgfault+0xd8>
c0108d5a:	c7 44 24 0c f8 e0 10 	movl   $0xc010e0f8,0xc(%esp)
c0108d61:	c0 
c0108d62:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108d69:	c0 
c0108d6a:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0108d71:	00 
c0108d72:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108d79:	e8 72 80 ff ff       	call   c0100df0 <__panic>

    insert_vma_struct(mm, vma);
c0108d7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108d81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d85:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d88:	89 04 24             	mov    %eax,(%esp)
c0108d8b:	e8 e0 f4 ff ff       	call   c0108270 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108d90:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108d97:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108da1:	89 04 24             	mov    %eax,(%esp)
c0108da4:	e8 72 f3 ff ff       	call   c010811b <find_vma>
c0108da9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108dac:	74 24                	je     c0108dd2 <check_pgfault+0x12c>
c0108dae:	c7 44 24 0c 75 e2 10 	movl   $0xc010e275,0xc(%esp)
c0108db5:	c0 
c0108db6:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108dbd:	c0 
c0108dbe:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0108dc5:	00 
c0108dc6:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108dcd:	e8 1e 80 ff ff       	call   c0100df0 <__panic>

    int i, sum = 0;
c0108dd2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108dd9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108de0:	eb 17                	jmp    c0108df9 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0108de2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108de5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108de8:	01 d0                	add    %edx,%eax
c0108dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ded:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108def:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108df2:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0108df5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108df9:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108dfd:	7e e3                	jle    c0108de2 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108dff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108e06:	eb 15                	jmp    c0108e1d <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0108e08:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108e0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e0e:	01 d0                	add    %edx,%eax
c0108e10:	0f b6 00             	movzbl (%eax),%eax
c0108e13:	0f be c0             	movsbl %al,%eax
c0108e16:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108e19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108e1d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108e21:	7e e5                	jle    c0108e08 <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0108e23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108e27:	74 24                	je     c0108e4d <check_pgfault+0x1a7>
c0108e29:	c7 44 24 0c 8f e2 10 	movl   $0xc010e28f,0xc(%esp)
c0108e30:	c0 
c0108e31:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108e38:	c0 
c0108e39:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0108e40:	00 
c0108e41:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108e48:	e8 a3 7f ff ff       	call   c0100df0 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0108e4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e50:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108e53:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108e56:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e62:	89 04 24             	mov    %eax,(%esp)
c0108e65:	e8 c9 d0 ff ff       	call   c0105f33 <page_remove>
    free_page(pde2page(pgdir[0]));
c0108e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e6d:	8b 00                	mov    (%eax),%eax
c0108e6f:	89 04 24             	mov    %eax,(%esp)
c0108e72:	e8 b8 f1 ff ff       	call   c010802f <pde2page>
c0108e77:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108e7e:	00 
c0108e7f:	89 04 24             	mov    %eax,(%esp)
c0108e82:	e8 23 c4 ff ff       	call   c01052aa <free_pages>
    pgdir[0] = 0;
c0108e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108e90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e93:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108e9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e9d:	89 04 24             	mov    %eax,(%esp)
c0108ea0:	e8 fb f4 ff ff       	call   c01083a0 <mm_destroy>
    check_mm_struct = NULL;
c0108ea5:	c7 05 ec 31 1b c0 00 	movl   $0x0,0xc01b31ec
c0108eac:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108eaf:	e8 28 c4 ff ff       	call   c01052dc <nr_free_pages>
c0108eb4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108eb7:	74 24                	je     c0108edd <check_pgfault+0x237>
c0108eb9:	c7 44 24 0c 98 e2 10 	movl   $0xc010e298,0xc(%esp)
c0108ec0:	c0 
c0108ec1:	c7 44 24 08 07 e0 10 	movl   $0xc010e007,0x8(%esp)
c0108ec8:	c0 
c0108ec9:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0108ed0:	00 
c0108ed1:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c0108ed8:	e8 13 7f ff ff       	call   c0100df0 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108edd:	c7 04 24 bf e2 10 c0 	movl   $0xc010e2bf,(%esp)
c0108ee4:	e8 7b 74 ff ff       	call   c0100364 <cprintf>
}
c0108ee9:	c9                   	leave  
c0108eea:	c3                   	ret    

c0108eeb <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0108eeb:	55                   	push   %ebp
c0108eec:	89 e5                	mov    %esp,%ebp
c0108eee:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108ef1:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108ef8:	8b 45 10             	mov    0x10(%ebp),%eax
c0108efb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108eff:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f02:	89 04 24             	mov    %eax,(%esp)
c0108f05:	e8 11 f2 ff ff       	call   c010811b <find_vma>
c0108f0a:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0108f0d:	a1 38 10 1b c0       	mov    0xc01b1038,%eax
c0108f12:	83 c0 01             	add    $0x1,%eax
c0108f15:	a3 38 10 1b c0       	mov    %eax,0xc01b1038
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0108f1a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108f1e:	74 0b                	je     c0108f2b <do_pgfault+0x40>
c0108f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f23:	8b 40 04             	mov    0x4(%eax),%eax
c0108f26:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108f29:	76 18                	jbe    c0108f43 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0108f2b:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f32:	c7 04 24 dc e2 10 c0 	movl   $0xc010e2dc,(%esp)
c0108f39:	e8 26 74 ff ff       	call   c0100364 <cprintf>
        goto failed;
c0108f3e:	e9 bb 01 00 00       	jmp    c01090fe <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c0108f43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f46:	83 e0 03             	and    $0x3,%eax
c0108f49:	85 c0                	test   %eax,%eax
c0108f4b:	74 36                	je     c0108f83 <do_pgfault+0x98>
c0108f4d:	83 f8 01             	cmp    $0x1,%eax
c0108f50:	74 20                	je     c0108f72 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0108f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f55:	8b 40 0c             	mov    0xc(%eax),%eax
c0108f58:	83 e0 02             	and    $0x2,%eax
c0108f5b:	85 c0                	test   %eax,%eax
c0108f5d:	75 11                	jne    c0108f70 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108f5f:	c7 04 24 0c e3 10 c0 	movl   $0xc010e30c,(%esp)
c0108f66:	e8 f9 73 ff ff       	call   c0100364 <cprintf>
            goto failed;
c0108f6b:	e9 8e 01 00 00       	jmp    c01090fe <do_pgfault+0x213>
        }
        break;
c0108f70:	eb 2f                	jmp    c0108fa1 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108f72:	c7 04 24 6c e3 10 c0 	movl   $0xc010e36c,(%esp)
c0108f79:	e8 e6 73 ff ff       	call   c0100364 <cprintf>
        goto failed;
c0108f7e:	e9 7b 01 00 00       	jmp    c01090fe <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f86:	8b 40 0c             	mov    0xc(%eax),%eax
c0108f89:	83 e0 05             	and    $0x5,%eax
c0108f8c:	85 c0                	test   %eax,%eax
c0108f8e:	75 11                	jne    c0108fa1 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108f90:	c7 04 24 a4 e3 10 c0 	movl   $0xc010e3a4,(%esp)
c0108f97:	e8 c8 73 ff ff       	call   c0100364 <cprintf>
            goto failed;
c0108f9c:	e9 5d 01 00 00       	jmp    c01090fe <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108fa1:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108fa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108fab:	8b 40 0c             	mov    0xc(%eax),%eax
c0108fae:	83 e0 02             	and    $0x2,%eax
c0108fb1:	85 c0                	test   %eax,%eax
c0108fb3:	74 04                	je     c0108fb9 <do_pgfault+0xce>
        perm |= PTE_W;
c0108fb5:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108fb9:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fbc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108fbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108fc2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108fc7:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0108fca:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108fd1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0108fd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fdb:	8b 40 0c             	mov    0xc(%eax),%eax
c0108fde:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108fe5:	00 
c0108fe6:	8b 55 10             	mov    0x10(%ebp),%edx
c0108fe9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108fed:	89 04 24             	mov    %eax,(%esp)
c0108ff0:	e8 2e c9 ff ff       	call   c0105923 <get_pte>
c0108ff5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108ff8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108ffc:	75 11                	jne    c010900f <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0108ffe:	c7 04 24 07 e4 10 c0 	movl   $0xc010e407,(%esp)
c0109005:	e8 5a 73 ff ff       	call   c0100364 <cprintf>
        goto failed;
c010900a:	e9 ef 00 00 00       	jmp    c01090fe <do_pgfault+0x213>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c010900f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109012:	8b 00                	mov    (%eax),%eax
c0109014:	85 c0                	test   %eax,%eax
c0109016:	75 35                	jne    c010904d <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0109018:	8b 45 08             	mov    0x8(%ebp),%eax
c010901b:	8b 40 0c             	mov    0xc(%eax),%eax
c010901e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109021:	89 54 24 08          	mov    %edx,0x8(%esp)
c0109025:	8b 55 10             	mov    0x10(%ebp),%edx
c0109028:	89 54 24 04          	mov    %edx,0x4(%esp)
c010902c:	89 04 24             	mov    %eax,(%esp)
c010902f:	e8 59 d0 ff ff       	call   c010608d <pgdir_alloc_page>
c0109034:	85 c0                	test   %eax,%eax
c0109036:	0f 85 bb 00 00 00    	jne    c01090f7 <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c010903c:	c7 04 24 28 e4 10 c0 	movl   $0xc010e428,(%esp)
c0109043:	e8 1c 73 ff ff       	call   c0100364 <cprintf>
            goto failed;
c0109048:	e9 b1 00 00 00       	jmp    c01090fe <do_pgfault+0x213>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c010904d:	a1 2c 10 1b c0       	mov    0xc01b102c,%eax
c0109052:	85 c0                	test   %eax,%eax
c0109054:	0f 84 86 00 00 00    	je     c01090e0 <do_pgfault+0x1f5>
            struct Page *page=NULL;
c010905a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0109061:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0109064:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109068:	8b 45 10             	mov    0x10(%ebp),%eax
c010906b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010906f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109072:	89 04 24             	mov    %eax,(%esp)
c0109075:	e8 bf e0 ff ff       	call   c0107139 <swap_in>
c010907a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010907d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109081:	74 0e                	je     c0109091 <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c0109083:	c7 04 24 4f e4 10 c0 	movl   $0xc010e44f,(%esp)
c010908a:	e8 d5 72 ff ff       	call   c0100364 <cprintf>
c010908f:	eb 6d                	jmp    c01090fe <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0109091:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109094:	8b 45 08             	mov    0x8(%ebp),%eax
c0109097:	8b 40 0c             	mov    0xc(%eax),%eax
c010909a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010909d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01090a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
c01090a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01090a8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01090ac:	89 04 24             	mov    %eax,(%esp)
c01090af:	e8 c3 ce ff ff       	call   c0105f77 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c01090b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01090b7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01090be:	00 
c01090bf:	89 44 24 08          	mov    %eax,0x8(%esp)
c01090c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01090c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01090cd:	89 04 24             	mov    %eax,(%esp)
c01090d0:	e8 9b de ff ff       	call   c0106f70 <swap_map_swappable>
            page->pra_vaddr = addr;
c01090d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01090d8:	8b 55 10             	mov    0x10(%ebp),%edx
c01090db:	89 50 1c             	mov    %edx,0x1c(%eax)
c01090de:	eb 17                	jmp    c01090f7 <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c01090e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01090e3:	8b 00                	mov    (%eax),%eax
c01090e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090e9:	c7 04 24 70 e4 10 c0 	movl   $0xc010e470,(%esp)
c01090f0:	e8 6f 72 ff ff       	call   c0100364 <cprintf>
            goto failed;
c01090f5:	eb 07                	jmp    c01090fe <do_pgfault+0x213>
        }
   }
   ret = 0;
c01090f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01090fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109101:	c9                   	leave  
c0109102:	c3                   	ret    

c0109103 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0109103:	55                   	push   %ebp
c0109104:	89 e5                	mov    %esp,%ebp
c0109106:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109109:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010910d:	0f 84 e0 00 00 00    	je     c01091f3 <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c0109113:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010911a:	76 1c                	jbe    c0109138 <user_mem_check+0x35>
c010911c:	8b 45 10             	mov    0x10(%ebp),%eax
c010911f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109122:	01 d0                	add    %edx,%eax
c0109124:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109127:	76 0f                	jbe    c0109138 <user_mem_check+0x35>
c0109129:	8b 45 10             	mov    0x10(%ebp),%eax
c010912c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010912f:	01 d0                	add    %edx,%eax
c0109131:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c0109136:	76 0a                	jbe    c0109142 <user_mem_check+0x3f>
            return 0;
c0109138:	b8 00 00 00 00       	mov    $0x0,%eax
c010913d:	e9 e2 00 00 00       	jmp    c0109224 <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c0109142:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109145:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109148:	8b 45 10             	mov    0x10(%ebp),%eax
c010914b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010914e:	01 d0                	add    %edx,%eax
c0109150:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c0109153:	e9 88 00 00 00       	jmp    c01091e0 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c0109158:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010915b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010915f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109162:	89 04 24             	mov    %eax,(%esp)
c0109165:	e8 b1 ef ff ff       	call   c010811b <find_vma>
c010916a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010916d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109171:	74 0b                	je     c010917e <user_mem_check+0x7b>
c0109173:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109176:	8b 40 04             	mov    0x4(%eax),%eax
c0109179:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010917c:	76 0a                	jbe    c0109188 <user_mem_check+0x85>
                return 0;
c010917e:	b8 00 00 00 00       	mov    $0x0,%eax
c0109183:	e9 9c 00 00 00       	jmp    c0109224 <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c0109188:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010918b:	8b 50 0c             	mov    0xc(%eax),%edx
c010918e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109192:	74 07                	je     c010919b <user_mem_check+0x98>
c0109194:	b8 02 00 00 00       	mov    $0x2,%eax
c0109199:	eb 05                	jmp    c01091a0 <user_mem_check+0x9d>
c010919b:	b8 01 00 00 00       	mov    $0x1,%eax
c01091a0:	21 d0                	and    %edx,%eax
c01091a2:	85 c0                	test   %eax,%eax
c01091a4:	75 07                	jne    c01091ad <user_mem_check+0xaa>
                return 0;
c01091a6:	b8 00 00 00 00       	mov    $0x0,%eax
c01091ab:	eb 77                	jmp    c0109224 <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c01091ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01091b1:	74 24                	je     c01091d7 <user_mem_check+0xd4>
c01091b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091b6:	8b 40 0c             	mov    0xc(%eax),%eax
c01091b9:	83 e0 08             	and    $0x8,%eax
c01091bc:	85 c0                	test   %eax,%eax
c01091be:	74 17                	je     c01091d7 <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c01091c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091c3:	8b 40 04             	mov    0x4(%eax),%eax
c01091c6:	05 00 10 00 00       	add    $0x1000,%eax
c01091cb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01091ce:	76 07                	jbe    c01091d7 <user_mem_check+0xd4>
                    return 0;
c01091d0:	b8 00 00 00 00       	mov    $0x0,%eax
c01091d5:	eb 4d                	jmp    c0109224 <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c01091d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091da:	8b 40 08             	mov    0x8(%eax),%eax
c01091dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!USER_ACCESS(addr, addr + len)) {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end) {
c01091e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01091e3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01091e6:	0f 82 6c ff ff ff    	jb     c0109158 <user_mem_check+0x55>
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
c01091ec:	b8 01 00 00 00       	mov    $0x1,%eax
c01091f1:	eb 31                	jmp    c0109224 <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c01091f3:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c01091fa:	76 23                	jbe    c010921f <user_mem_check+0x11c>
c01091fc:	8b 45 10             	mov    0x10(%ebp),%eax
c01091ff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109202:	01 d0                	add    %edx,%eax
c0109204:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109207:	76 16                	jbe    c010921f <user_mem_check+0x11c>
c0109209:	8b 45 10             	mov    0x10(%ebp),%eax
c010920c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010920f:	01 d0                	add    %edx,%eax
c0109211:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c0109216:	77 07                	ja     c010921f <user_mem_check+0x11c>
c0109218:	b8 01 00 00 00       	mov    $0x1,%eax
c010921d:	eb 05                	jmp    c0109224 <user_mem_check+0x121>
c010921f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109224:	c9                   	leave  
c0109225:	c3                   	ret    

c0109226 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109226:	55                   	push   %ebp
c0109227:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109229:	8b 55 08             	mov    0x8(%ebp),%edx
c010922c:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0109231:	29 c2                	sub    %eax,%edx
c0109233:	89 d0                	mov    %edx,%eax
c0109235:	c1 f8 05             	sar    $0x5,%eax
}
c0109238:	5d                   	pop    %ebp
c0109239:	c3                   	ret    

c010923a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010923a:	55                   	push   %ebp
c010923b:	89 e5                	mov    %esp,%ebp
c010923d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109240:	8b 45 08             	mov    0x8(%ebp),%eax
c0109243:	89 04 24             	mov    %eax,(%esp)
c0109246:	e8 db ff ff ff       	call   c0109226 <page2ppn>
c010924b:	c1 e0 0c             	shl    $0xc,%eax
}
c010924e:	c9                   	leave  
c010924f:	c3                   	ret    

c0109250 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109250:	55                   	push   %ebp
c0109251:	89 e5                	mov    %esp,%ebp
c0109253:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109256:	8b 45 08             	mov    0x8(%ebp),%eax
c0109259:	89 04 24             	mov    %eax,(%esp)
c010925c:	e8 d9 ff ff ff       	call   c010923a <page2pa>
c0109261:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109264:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109267:	c1 e8 0c             	shr    $0xc,%eax
c010926a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010926d:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0109272:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109275:	72 23                	jb     c010929a <page2kva+0x4a>
c0109277:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010927a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010927e:	c7 44 24 08 98 e4 10 	movl   $0xc010e498,0x8(%esp)
c0109285:	c0 
c0109286:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010928d:	00 
c010928e:	c7 04 24 bb e4 10 c0 	movl   $0xc010e4bb,(%esp)
c0109295:	e8 56 7b ff ff       	call   c0100df0 <__panic>
c010929a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010929d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01092a2:	c9                   	leave  
c01092a3:	c3                   	ret    

c01092a4 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01092a4:	55                   	push   %ebp
c01092a5:	89 e5                	mov    %esp,%ebp
c01092a7:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01092aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092b1:	e8 9b 88 ff ff       	call   c0101b51 <ide_device_valid>
c01092b6:	85 c0                	test   %eax,%eax
c01092b8:	75 1c                	jne    c01092d6 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01092ba:	c7 44 24 08 c9 e4 10 	movl   $0xc010e4c9,0x8(%esp)
c01092c1:	c0 
c01092c2:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01092c9:	00 
c01092ca:	c7 04 24 e3 e4 10 c0 	movl   $0xc010e4e3,(%esp)
c01092d1:	e8 1a 7b ff ff       	call   c0100df0 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01092d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092dd:	e8 ae 88 ff ff       	call   c0101b90 <ide_device_size>
c01092e2:	c1 e8 03             	shr    $0x3,%eax
c01092e5:	a3 bc 31 1b c0       	mov    %eax,0xc01b31bc
}
c01092ea:	c9                   	leave  
c01092eb:	c3                   	ret    

c01092ec <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01092ec:	55                   	push   %ebp
c01092ed:	89 e5                	mov    %esp,%ebp
c01092ef:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01092f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092f5:	89 04 24             	mov    %eax,(%esp)
c01092f8:	e8 53 ff ff ff       	call   c0109250 <page2kva>
c01092fd:	8b 55 08             	mov    0x8(%ebp),%edx
c0109300:	c1 ea 08             	shr    $0x8,%edx
c0109303:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109306:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010930a:	74 0b                	je     c0109317 <swapfs_read+0x2b>
c010930c:	8b 15 bc 31 1b c0    	mov    0xc01b31bc,%edx
c0109312:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109315:	72 23                	jb     c010933a <swapfs_read+0x4e>
c0109317:	8b 45 08             	mov    0x8(%ebp),%eax
c010931a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010931e:	c7 44 24 08 f4 e4 10 	movl   $0xc010e4f4,0x8(%esp)
c0109325:	c0 
c0109326:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010932d:	00 
c010932e:	c7 04 24 e3 e4 10 c0 	movl   $0xc010e4e3,(%esp)
c0109335:	e8 b6 7a ff ff       	call   c0100df0 <__panic>
c010933a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010933d:	c1 e2 03             	shl    $0x3,%edx
c0109340:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109347:	00 
c0109348:	89 44 24 08          	mov    %eax,0x8(%esp)
c010934c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109350:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109357:	e8 73 88 ff ff       	call   c0101bcf <ide_read_secs>
}
c010935c:	c9                   	leave  
c010935d:	c3                   	ret    

c010935e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010935e:	55                   	push   %ebp
c010935f:	89 e5                	mov    %esp,%ebp
c0109361:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109364:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109367:	89 04 24             	mov    %eax,(%esp)
c010936a:	e8 e1 fe ff ff       	call   c0109250 <page2kva>
c010936f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109372:	c1 ea 08             	shr    $0x8,%edx
c0109375:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109378:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010937c:	74 0b                	je     c0109389 <swapfs_write+0x2b>
c010937e:	8b 15 bc 31 1b c0    	mov    0xc01b31bc,%edx
c0109384:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109387:	72 23                	jb     c01093ac <swapfs_write+0x4e>
c0109389:	8b 45 08             	mov    0x8(%ebp),%eax
c010938c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109390:	c7 44 24 08 f4 e4 10 	movl   $0xc010e4f4,0x8(%esp)
c0109397:	c0 
c0109398:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010939f:	00 
c01093a0:	c7 04 24 e3 e4 10 c0 	movl   $0xc010e4e3,(%esp)
c01093a7:	e8 44 7a ff ff       	call   c0100df0 <__panic>
c01093ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01093af:	c1 e2 03             	shl    $0x3,%edx
c01093b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01093b9:	00 
c01093ba:	89 44 24 08          	mov    %eax,0x8(%esp)
c01093be:	89 54 24 04          	mov    %edx,0x4(%esp)
c01093c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01093c9:	e8 43 8a ff ff       	call   c0101e11 <ide_write_secs>
}
c01093ce:	c9                   	leave  
c01093cf:	c3                   	ret    

c01093d0 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01093d0:	52                   	push   %edx
    call *%ebx              # call fn
c01093d1:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01093d3:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01093d4:	e8 eb 0c 00 00       	call   c010a0c4 <do_exit>

c01093d9 <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c01093d9:	55                   	push   %ebp
c01093da:	89 e5                	mov    %esp,%ebp
c01093dc:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01093df:	8b 55 0c             	mov    0xc(%ebp),%edx
c01093e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01093e5:	0f ab 02             	bts    %eax,(%edx)
c01093e8:	19 c0                	sbb    %eax,%eax
c01093ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01093ed:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01093f1:	0f 95 c0             	setne  %al
c01093f4:	0f b6 c0             	movzbl %al,%eax
}
c01093f7:	c9                   	leave  
c01093f8:	c3                   	ret    

c01093f9 <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01093f9:	55                   	push   %ebp
c01093fa:	89 e5                	mov    %esp,%ebp
c01093fc:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01093ff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109402:	8b 45 08             	mov    0x8(%ebp),%eax
c0109405:	0f b3 02             	btr    %eax,(%edx)
c0109408:	19 c0                	sbb    %eax,%eax
c010940a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c010940d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109411:	0f 95 c0             	setne  %al
c0109414:	0f b6 c0             	movzbl %al,%eax
}
c0109417:	c9                   	leave  
c0109418:	c3                   	ret    

c0109419 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0109419:	55                   	push   %ebp
c010941a:	89 e5                	mov    %esp,%ebp
c010941c:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010941f:	9c                   	pushf  
c0109420:	58                   	pop    %eax
c0109421:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109424:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109427:	25 00 02 00 00       	and    $0x200,%eax
c010942c:	85 c0                	test   %eax,%eax
c010942e:	74 0c                	je     c010943c <__intr_save+0x23>
        intr_disable();
c0109430:	e8 24 8c ff ff       	call   c0102059 <intr_disable>
        return 1;
c0109435:	b8 01 00 00 00       	mov    $0x1,%eax
c010943a:	eb 05                	jmp    c0109441 <__intr_save+0x28>
    }
    return 0;
c010943c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109441:	c9                   	leave  
c0109442:	c3                   	ret    

c0109443 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109443:	55                   	push   %ebp
c0109444:	89 e5                	mov    %esp,%ebp
c0109446:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109449:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010944d:	74 05                	je     c0109454 <__intr_restore+0x11>
        intr_enable();
c010944f:	e8 ff 8b ff ff       	call   c0102053 <intr_enable>
    }
}
c0109454:	c9                   	leave  
c0109455:	c3                   	ret    

c0109456 <try_lock>:
lock_init(lock_t *lock) {
    *lock = 0;
}

static inline bool
try_lock(lock_t *lock) {
c0109456:	55                   	push   %ebp
c0109457:	89 e5                	mov    %esp,%ebp
c0109459:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c010945c:	8b 45 08             	mov    0x8(%ebp),%eax
c010945f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109463:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010946a:	e8 6a ff ff ff       	call   c01093d9 <test_and_set_bit>
c010946f:	85 c0                	test   %eax,%eax
c0109471:	0f 94 c0             	sete   %al
c0109474:	0f b6 c0             	movzbl %al,%eax
}
c0109477:	c9                   	leave  
c0109478:	c3                   	ret    

c0109479 <lock>:

static inline void
lock(lock_t *lock) {
c0109479:	55                   	push   %ebp
c010947a:	89 e5                	mov    %esp,%ebp
c010947c:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c010947f:	eb 05                	jmp    c0109486 <lock+0xd>
        schedule();
c0109481:	e8 5f 21 00 00       	call   c010b5e5 <schedule>
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
c0109486:	8b 45 08             	mov    0x8(%ebp),%eax
c0109489:	89 04 24             	mov    %eax,(%esp)
c010948c:	e8 c5 ff ff ff       	call   c0109456 <try_lock>
c0109491:	85 c0                	test   %eax,%eax
c0109493:	74 ec                	je     c0109481 <lock+0x8>
        schedule();
    }
}
c0109495:	c9                   	leave  
c0109496:	c3                   	ret    

c0109497 <unlock>:

static inline void
unlock(lock_t *lock) {
c0109497:	55                   	push   %ebp
c0109498:	89 e5                	mov    %esp,%ebp
c010949a:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c010949d:	8b 45 08             	mov    0x8(%ebp),%eax
c01094a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01094ab:	e8 49 ff ff ff       	call   c01093f9 <test_and_clear_bit>
c01094b0:	85 c0                	test   %eax,%eax
c01094b2:	75 1c                	jne    c01094d0 <unlock+0x39>
        panic("Unlock failed.\n");
c01094b4:	c7 44 24 08 14 e5 10 	movl   $0xc010e514,0x8(%esp)
c01094bb:	c0 
c01094bc:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c01094c3:	00 
c01094c4:	c7 04 24 24 e5 10 c0 	movl   $0xc010e524,(%esp)
c01094cb:	e8 20 79 ff ff       	call   c0100df0 <__panic>
    }
}
c01094d0:	c9                   	leave  
c01094d1:	c3                   	ret    

c01094d2 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01094d2:	55                   	push   %ebp
c01094d3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01094d5:	8b 55 08             	mov    0x8(%ebp),%edx
c01094d8:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c01094dd:	29 c2                	sub    %eax,%edx
c01094df:	89 d0                	mov    %edx,%eax
c01094e1:	c1 f8 05             	sar    $0x5,%eax
}
c01094e4:	5d                   	pop    %ebp
c01094e5:	c3                   	ret    

c01094e6 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01094e6:	55                   	push   %ebp
c01094e7:	89 e5                	mov    %esp,%ebp
c01094e9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01094ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ef:	89 04 24             	mov    %eax,(%esp)
c01094f2:	e8 db ff ff ff       	call   c01094d2 <page2ppn>
c01094f7:	c1 e0 0c             	shl    $0xc,%eax
}
c01094fa:	c9                   	leave  
c01094fb:	c3                   	ret    

c01094fc <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01094fc:	55                   	push   %ebp
c01094fd:	89 e5                	mov    %esp,%ebp
c01094ff:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109502:	8b 45 08             	mov    0x8(%ebp),%eax
c0109505:	c1 e8 0c             	shr    $0xc,%eax
c0109508:	89 c2                	mov    %eax,%edx
c010950a:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c010950f:	39 c2                	cmp    %eax,%edx
c0109511:	72 1c                	jb     c010952f <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0109513:	c7 44 24 08 38 e5 10 	movl   $0xc010e538,0x8(%esp)
c010951a:	c0 
c010951b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0109522:	00 
c0109523:	c7 04 24 57 e5 10 c0 	movl   $0xc010e557,(%esp)
c010952a:	e8 c1 78 ff ff       	call   c0100df0 <__panic>
    }
    return &pages[PPN(pa)];
c010952f:	a1 04 31 1b c0       	mov    0xc01b3104,%eax
c0109534:	8b 55 08             	mov    0x8(%ebp),%edx
c0109537:	c1 ea 0c             	shr    $0xc,%edx
c010953a:	c1 e2 05             	shl    $0x5,%edx
c010953d:	01 d0                	add    %edx,%eax
}
c010953f:	c9                   	leave  
c0109540:	c3                   	ret    

c0109541 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109541:	55                   	push   %ebp
c0109542:	89 e5                	mov    %esp,%ebp
c0109544:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109547:	8b 45 08             	mov    0x8(%ebp),%eax
c010954a:	89 04 24             	mov    %eax,(%esp)
c010954d:	e8 94 ff ff ff       	call   c01094e6 <page2pa>
c0109552:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109555:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109558:	c1 e8 0c             	shr    $0xc,%eax
c010955b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010955e:	a1 a0 0f 1b c0       	mov    0xc01b0fa0,%eax
c0109563:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109566:	72 23                	jb     c010958b <page2kva+0x4a>
c0109568:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010956b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010956f:	c7 44 24 08 68 e5 10 	movl   $0xc010e568,0x8(%esp)
c0109576:	c0 
c0109577:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010957e:	00 
c010957f:	c7 04 24 57 e5 10 c0 	movl   $0xc010e557,(%esp)
c0109586:	e8 65 78 ff ff       	call   c0100df0 <__panic>
c010958b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010958e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109593:	c9                   	leave  
c0109594:	c3                   	ret    

c0109595 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0109595:	55                   	push   %ebp
c0109596:	89 e5                	mov    %esp,%ebp
c0109598:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010959b:	8b 45 08             	mov    0x8(%ebp),%eax
c010959e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01095a1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01095a8:	77 23                	ja     c01095cd <kva2page+0x38>
c01095aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01095b1:	c7 44 24 08 8c e5 10 	movl   $0xc010e58c,0x8(%esp)
c01095b8:	c0 
c01095b9:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01095c0:	00 
c01095c1:	c7 04 24 57 e5 10 c0 	movl   $0xc010e557,(%esp)
c01095c8:	e8 23 78 ff ff       	call   c0100df0 <__panic>
c01095cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095d0:	05 00 00 00 40       	add    $0x40000000,%eax
c01095d5:	89 04 24             	mov    %eax,(%esp)
c01095d8:	e8 1f ff ff ff       	call   c01094fc <pa2page>
}
c01095dd:	c9                   	leave  
c01095de:	c3                   	ret    

c01095df <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01095df:	55                   	push   %ebp
c01095e0:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01095e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01095e5:	8b 40 18             	mov    0x18(%eax),%eax
c01095e8:	8d 50 01             	lea    0x1(%eax),%edx
c01095eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01095ee:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01095f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01095f4:	8b 40 18             	mov    0x18(%eax),%eax
}
c01095f7:	5d                   	pop    %ebp
c01095f8:	c3                   	ret    

c01095f9 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01095f9:	55                   	push   %ebp
c01095fa:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01095fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01095ff:	8b 40 18             	mov    0x18(%eax),%eax
c0109602:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109605:	8b 45 08             	mov    0x8(%ebp),%eax
c0109608:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c010960b:	8b 45 08             	mov    0x8(%ebp),%eax
c010960e:	8b 40 18             	mov    0x18(%eax),%eax
}
c0109611:	5d                   	pop    %ebp
c0109612:	c3                   	ret    

c0109613 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c0109613:	55                   	push   %ebp
c0109614:	89 e5                	mov    %esp,%ebp
c0109616:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109619:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010961d:	74 0e                	je     c010962d <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c010961f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109622:	83 c0 1c             	add    $0x1c,%eax
c0109625:	89 04 24             	mov    %eax,(%esp)
c0109628:	e8 4c fe ff ff       	call   c0109479 <lock>
    }
}
c010962d:	c9                   	leave  
c010962e:	c3                   	ret    

c010962f <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c010962f:	55                   	push   %ebp
c0109630:	89 e5                	mov    %esp,%ebp
c0109632:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109635:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109639:	74 0e                	je     c0109649 <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c010963b:	8b 45 08             	mov    0x8(%ebp),%eax
c010963e:	83 c0 1c             	add    $0x1c,%eax
c0109641:	89 04 24             	mov    %eax,(%esp)
c0109644:	e8 4e fe ff ff       	call   c0109497 <unlock>
    }
}
c0109649:	c9                   	leave  
c010964a:	c3                   	ret    

c010964b <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010964b:	55                   	push   %ebp
c010964c:	89 e5                	mov    %esp,%ebp
c010964e:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109651:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
c0109658:	e8 6d b7 ff ff       	call   c0104dca <kmalloc>
c010965d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109660:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109664:	0f 84 4c 01 00 00    	je     c01097b6 <alloc_proc+0x16b>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c010966a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010966d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0109673:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109676:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c010967d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109680:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109687:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010968a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c0109691:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109694:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c010969b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010969e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c01096a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096a8:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c01096af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096b2:	83 c0 1c             	add    $0x1c,%eax
c01096b5:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c01096bc:	00 
c01096bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01096c4:	00 
c01096c5:	89 04 24             	mov    %eax,(%esp)
c01096c8:	e8 74 2c 00 00       	call   c010c341 <memset>
        proc->tf = NULL;
c01096cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096d0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c01096d7:	8b 15 00 31 1b c0    	mov    0xc01b3100,%edx
c01096dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096e0:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c01096e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096e6:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c01096ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096f0:	83 c0 48             	add    $0x48,%eax
c01096f3:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01096fa:	00 
c01096fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109702:	00 
c0109703:	89 04 24             	mov    %eax,(%esp)
c0109706:	e8 36 2c 00 00       	call   c010c341 <memset>
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
	proc->wait_state = 0;
c010970b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010970e:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->optr = proc->yptr = NULL;
c0109715:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109718:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
c010971f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109722:	8b 50 74             	mov    0x74(%eax),%edx
c0109725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109728:	89 50 78             	mov    %edx,0x78(%eax)
c010972b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010972e:	8b 50 78             	mov    0x78(%eax),%edx
c0109731:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109734:	89 50 70             	mov    %edx,0x70(%eax)
     *     int time_slice;                             // time slice for occupying the CPU
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
        proc->rq = NULL;
c0109737:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010973a:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
        list_init(&(proc->run_link));
c0109741:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109744:	83 e8 80             	sub    $0xffffff80,%eax
c0109747:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010974a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010974d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109750:	89 50 04             	mov    %edx,0x4(%eax)
c0109753:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109756:	8b 50 04             	mov    0x4(%eax),%edx
c0109759:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010975c:	89 10                	mov    %edx,(%eax)
        proc->time_slice = 0;
c010975e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109761:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
c0109768:	00 00 00 
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
c010976b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010976e:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
c0109775:	00 00 00 
c0109778:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010977b:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
c0109781:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109784:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
c010978a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010978d:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
c0109793:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109796:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        proc->lab6_stride = 0;
c010979c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010979f:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
c01097a6:	00 00 00 
        proc->lab6_priority = 0;
c01097a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097ac:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
c01097b3:	00 00 00 
	//lab6 challenge
	/*proc->fair_run_time = 0;
	proc->fair_priority = 0;
	proc->fair_run_pool.left = proc->fair_run_pool.right = proc->fair_run_pool.parent = NULL;*/
    }
    return proc;
c01097b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01097b9:	c9                   	leave  
c01097ba:	c3                   	ret    

c01097bb <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01097bb:	55                   	push   %ebp
c01097bc:	89 e5                	mov    %esp,%ebp
c01097be:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01097c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01097c4:	83 c0 48             	add    $0x48,%eax
c01097c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01097ce:	00 
c01097cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01097d6:	00 
c01097d7:	89 04 24             	mov    %eax,(%esp)
c01097da:	e8 62 2b 00 00       	call   c010c341 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01097df:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e2:	8d 50 48             	lea    0x48(%eax),%edx
c01097e5:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01097ec:	00 
c01097ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097f4:	89 14 24             	mov    %edx,(%esp)
c01097f7:	e8 27 2c 00 00       	call   c010c423 <memcpy>
}
c01097fc:	c9                   	leave  
c01097fd:	c3                   	ret    

c01097fe <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01097fe:	55                   	push   %ebp
c01097ff:	89 e5                	mov    %esp,%ebp
c0109801:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109804:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010980b:	00 
c010980c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109813:	00 
c0109814:	c7 04 24 64 30 1b c0 	movl   $0xc01b3064,(%esp)
c010981b:	e8 21 2b 00 00       	call   c010c341 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109820:	8b 45 08             	mov    0x8(%ebp),%eax
c0109823:	83 c0 48             	add    $0x48,%eax
c0109826:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010982d:	00 
c010982e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109832:	c7 04 24 64 30 1b c0 	movl   $0xc01b3064,(%esp)
c0109839:	e8 e5 2b 00 00       	call   c010c423 <memcpy>
}
c010983e:	c9                   	leave  
c010983f:	c3                   	ret    

c0109840 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109840:	55                   	push   %ebp
c0109841:	89 e5                	mov    %esp,%ebp
c0109843:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c0109846:	8b 45 08             	mov    0x8(%ebp),%eax
c0109849:	83 c0 58             	add    $0x58,%eax
c010984c:	c7 45 fc f0 31 1b c0 	movl   $0xc01b31f0,-0x4(%ebp)
c0109853:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0109856:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109859:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010985c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010985f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109865:	8b 40 04             	mov    0x4(%eax),%eax
c0109868:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010986b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010986e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109871:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109874:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109877:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010987a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010987d:	89 10                	mov    %edx,(%eax)
c010987f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109882:	8b 10                	mov    (%eax),%edx
c0109884:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109887:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010988a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010988d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109890:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109893:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109896:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109899:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c010989b:	8b 45 08             	mov    0x8(%ebp),%eax
c010989e:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c01098a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01098a8:	8b 40 14             	mov    0x14(%eax),%eax
c01098ab:	8b 50 70             	mov    0x70(%eax),%edx
c01098ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01098b1:	89 50 78             	mov    %edx,0x78(%eax)
c01098b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01098b7:	8b 40 78             	mov    0x78(%eax),%eax
c01098ba:	85 c0                	test   %eax,%eax
c01098bc:	74 0c                	je     c01098ca <set_links+0x8a>
        proc->optr->yptr = proc;
c01098be:	8b 45 08             	mov    0x8(%ebp),%eax
c01098c1:	8b 40 78             	mov    0x78(%eax),%eax
c01098c4:	8b 55 08             	mov    0x8(%ebp),%edx
c01098c7:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c01098ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01098cd:	8b 40 14             	mov    0x14(%eax),%eax
c01098d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01098d3:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c01098d6:	a1 60 30 1b c0       	mov    0xc01b3060,%eax
c01098db:	83 c0 01             	add    $0x1,%eax
c01098de:	a3 60 30 1b c0       	mov    %eax,0xc01b3060
}
c01098e3:	c9                   	leave  
c01098e4:	c3                   	ret    

c01098e5 <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c01098e5:	55                   	push   %ebp
c01098e6:	89 e5                	mov    %esp,%ebp
c01098e8:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c01098eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ee:	83 c0 58             	add    $0x58,%eax
c01098f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01098f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098f7:	8b 40 04             	mov    0x4(%eax),%eax
c01098fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01098fd:	8b 12                	mov    (%edx),%edx
c01098ff:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109902:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109905:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109908:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010990b:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010990e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109911:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109914:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c0109916:	8b 45 08             	mov    0x8(%ebp),%eax
c0109919:	8b 40 78             	mov    0x78(%eax),%eax
c010991c:	85 c0                	test   %eax,%eax
c010991e:	74 0f                	je     c010992f <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c0109920:	8b 45 08             	mov    0x8(%ebp),%eax
c0109923:	8b 40 78             	mov    0x78(%eax),%eax
c0109926:	8b 55 08             	mov    0x8(%ebp),%edx
c0109929:	8b 52 74             	mov    0x74(%edx),%edx
c010992c:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c010992f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109932:	8b 40 74             	mov    0x74(%eax),%eax
c0109935:	85 c0                	test   %eax,%eax
c0109937:	74 11                	je     c010994a <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c0109939:	8b 45 08             	mov    0x8(%ebp),%eax
c010993c:	8b 40 74             	mov    0x74(%eax),%eax
c010993f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109942:	8b 52 78             	mov    0x78(%edx),%edx
c0109945:	89 50 78             	mov    %edx,0x78(%eax)
c0109948:	eb 0f                	jmp    c0109959 <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c010994a:	8b 45 08             	mov    0x8(%ebp),%eax
c010994d:	8b 40 14             	mov    0x14(%eax),%eax
c0109950:	8b 55 08             	mov    0x8(%ebp),%edx
c0109953:	8b 52 78             	mov    0x78(%edx),%edx
c0109956:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c0109959:	a1 60 30 1b c0       	mov    0xc01b3060,%eax
c010995e:	83 e8 01             	sub    $0x1,%eax
c0109961:	a3 60 30 1b c0       	mov    %eax,0xc01b3060
}
c0109966:	c9                   	leave  
c0109967:	c3                   	ret    

c0109968 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109968:	55                   	push   %ebp
c0109969:	89 e5                	mov    %esp,%ebp
c010996b:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c010996e:	c7 45 f8 f0 31 1b c0 	movl   $0xc01b31f0,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0109975:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c010997a:	83 c0 01             	add    $0x1,%eax
c010997d:	a3 80 ca 12 c0       	mov    %eax,0xc012ca80
c0109982:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c0109987:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c010998c:	7e 0c                	jle    c010999a <get_pid+0x32>
        last_pid = 1;
c010998e:	c7 05 80 ca 12 c0 01 	movl   $0x1,0xc012ca80
c0109995:	00 00 00 
        goto inside;
c0109998:	eb 13                	jmp    c01099ad <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c010999a:	8b 15 80 ca 12 c0    	mov    0xc012ca80,%edx
c01099a0:	a1 84 ca 12 c0       	mov    0xc012ca84,%eax
c01099a5:	39 c2                	cmp    %eax,%edx
c01099a7:	0f 8c ac 00 00 00    	jl     c0109a59 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c01099ad:	c7 05 84 ca 12 c0 00 	movl   $0x2000,0xc012ca84
c01099b4:	20 00 00 
    repeat:
        le = list;
c01099b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01099ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c01099bd:	eb 7f                	jmp    c0109a3e <get_pid+0xd6>
            proc = le2proc(le, list_link);
c01099bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01099c2:	83 e8 58             	sub    $0x58,%eax
c01099c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c01099c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099cb:	8b 50 04             	mov    0x4(%eax),%edx
c01099ce:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c01099d3:	39 c2                	cmp    %eax,%edx
c01099d5:	75 3e                	jne    c0109a15 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c01099d7:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c01099dc:	83 c0 01             	add    $0x1,%eax
c01099df:	a3 80 ca 12 c0       	mov    %eax,0xc012ca80
c01099e4:	8b 15 80 ca 12 c0    	mov    0xc012ca80,%edx
c01099ea:	a1 84 ca 12 c0       	mov    0xc012ca84,%eax
c01099ef:	39 c2                	cmp    %eax,%edx
c01099f1:	7c 4b                	jl     c0109a3e <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c01099f3:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c01099f8:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01099fd:	7e 0a                	jle    c0109a09 <get_pid+0xa1>
                        last_pid = 1;
c01099ff:	c7 05 80 ca 12 c0 01 	movl   $0x1,0xc012ca80
c0109a06:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109a09:	c7 05 84 ca 12 c0 00 	movl   $0x2000,0xc012ca84
c0109a10:	20 00 00 
                    goto repeat;
c0109a13:	eb a2                	jmp    c01099b7 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a18:	8b 50 04             	mov    0x4(%eax),%edx
c0109a1b:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c0109a20:	39 c2                	cmp    %eax,%edx
c0109a22:	7e 1a                	jle    c0109a3e <get_pid+0xd6>
c0109a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a27:	8b 50 04             	mov    0x4(%eax),%edx
c0109a2a:	a1 84 ca 12 c0       	mov    0xc012ca84,%eax
c0109a2f:	39 c2                	cmp    %eax,%edx
c0109a31:	7d 0b                	jge    c0109a3e <get_pid+0xd6>
                next_safe = proc->pid;
c0109a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a36:	8b 40 04             	mov    0x4(%eax),%eax
c0109a39:	a3 84 ca 12 c0       	mov    %eax,0xc012ca84
c0109a3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a47:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109a4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a50:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109a53:	0f 85 66 ff ff ff    	jne    c01099bf <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0109a59:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
}
c0109a5e:	c9                   	leave  
c0109a5f:	c3                   	ret    

c0109a60 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109a60:	55                   	push   %ebp
c0109a61:	89 e5                	mov    %esp,%ebp
c0109a63:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0109a66:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0109a6b:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109a6e:	74 63                	je     c0109ad3 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109a70:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0109a75:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109a7e:	e8 96 f9 ff ff       	call   c0109419 <__intr_save>
c0109a83:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109a86:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a89:	a3 48 10 1b c0       	mov    %eax,0xc01b1048
            load_esp0(next->kstack + KSTACKSIZE);
c0109a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a91:	8b 40 0c             	mov    0xc(%eax),%eax
c0109a94:	05 00 20 00 00       	add    $0x2000,%eax
c0109a99:	89 04 24             	mov    %eax,(%esp)
c0109a9c:	e8 50 b6 ff ff       	call   c01050f1 <load_esp0>
            lcr3(next->cr3);
c0109aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109aa4:	8b 40 40             	mov    0x40(%eax),%eax
c0109aa7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109aaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109aad:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ab3:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ab9:	83 c0 1c             	add    $0x1c,%eax
c0109abc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109ac0:	89 04 24             	mov    %eax,(%esp)
c0109ac3:	e8 93 15 00 00       	call   c010b05b <switch_to>
        }
        local_intr_restore(intr_flag);
c0109ac8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109acb:	89 04 24             	mov    %eax,(%esp)
c0109ace:	e8 70 f9 ff ff       	call   c0109443 <__intr_restore>
    }
}
c0109ad3:	c9                   	leave  
c0109ad4:	c3                   	ret    

c0109ad5 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109ad5:	55                   	push   %ebp
c0109ad6:	89 e5                	mov    %esp,%ebp
c0109ad8:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109adb:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0109ae0:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109ae3:	89 04 24             	mov    %eax,(%esp)
c0109ae6:	e8 92 90 ff ff       	call   c0102b7d <forkrets>
}
c0109aeb:	c9                   	leave  
c0109aec:	c3                   	ret    

c0109aed <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109aed:	55                   	push   %ebp
c0109aee:	89 e5                	mov    %esp,%ebp
c0109af0:	53                   	push   %ebx
c0109af1:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109af4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109af7:	8d 58 60             	lea    0x60(%eax),%ebx
c0109afa:	8b 45 08             	mov    0x8(%ebp),%eax
c0109afd:	8b 40 04             	mov    0x4(%eax),%eax
c0109b00:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109b07:	00 
c0109b08:	89 04 24             	mov    %eax,(%esp)
c0109b0b:	e8 84 1d 00 00       	call   c010b894 <hash32>
c0109b10:	c1 e0 03             	shl    $0x3,%eax
c0109b13:	05 60 10 1b c0       	add    $0xc01b1060,%eax
c0109b18:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b1b:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b21:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b27:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b2d:	8b 40 04             	mov    0x4(%eax),%eax
c0109b30:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109b33:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109b36:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109b39:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109b3c:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109b3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109b45:	89 10                	mov    %edx,(%eax)
c0109b47:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b4a:	8b 10                	mov    (%eax),%edx
c0109b4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b4f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109b52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109b55:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109b58:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109b5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109b5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109b61:	89 10                	mov    %edx,(%eax)
}
c0109b63:	83 c4 34             	add    $0x34,%esp
c0109b66:	5b                   	pop    %ebx
c0109b67:	5d                   	pop    %ebp
c0109b68:	c3                   	ret    

c0109b69 <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109b69:	55                   	push   %ebp
c0109b6a:	89 e5                	mov    %esp,%ebp
c0109b6c:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109b6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b72:	83 c0 60             	add    $0x60,%eax
c0109b75:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109b7b:	8b 40 04             	mov    0x4(%eax),%eax
c0109b7e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109b81:	8b 12                	mov    (%edx),%edx
c0109b83:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109b86:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109b89:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109b8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b8f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b95:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109b98:	89 10                	mov    %edx,(%eax)
}
c0109b9a:	c9                   	leave  
c0109b9b:	c3                   	ret    

c0109b9c <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109b9c:	55                   	push   %ebp
c0109b9d:	89 e5                	mov    %esp,%ebp
c0109b9f:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109ba2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109ba6:	7e 5f                	jle    c0109c07 <find_proc+0x6b>
c0109ba8:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109baf:	7f 56                	jg     c0109c07 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109bb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bb4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109bbb:	00 
c0109bbc:	89 04 24             	mov    %eax,(%esp)
c0109bbf:	e8 d0 1c 00 00       	call   c010b894 <hash32>
c0109bc4:	c1 e0 03             	shl    $0x3,%eax
c0109bc7:	05 60 10 1b c0       	add    $0xc01b1060,%eax
c0109bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109bd5:	eb 19                	jmp    c0109bf0 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bda:	83 e8 60             	sub    $0x60,%eax
c0109bdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109be0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109be3:	8b 40 04             	mov    0x4(%eax),%eax
c0109be6:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109be9:	75 05                	jne    c0109bf0 <find_proc+0x54>
                return proc;
c0109beb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bee:	eb 1c                	jmp    c0109c0c <find_proc+0x70>
c0109bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bf3:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109bf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109bf9:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109bfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c02:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109c05:	75 d0                	jne    c0109bd7 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0109c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109c0c:	c9                   	leave  
c0109c0d:	c3                   	ret    

c0109c0e <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109c0e:	55                   	push   %ebp
c0109c0f:	89 e5                	mov    %esp,%ebp
c0109c11:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109c14:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109c1b:	00 
c0109c1c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109c23:	00 
c0109c24:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109c27:	89 04 24             	mov    %eax,(%esp)
c0109c2a:	e8 12 27 00 00       	call   c010c341 <memset>
    tf.tf_cs = KERNEL_CS;
c0109c2f:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109c35:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109c3b:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109c3f:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109c43:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109c47:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c4e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109c51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c54:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109c57:	b8 d0 93 10 c0       	mov    $0xc01093d0,%eax
c0109c5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109c5f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109c62:	80 cc 01             	or     $0x1,%ah
c0109c65:	89 c2                	mov    %eax,%edx
c0109c67:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109c6a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109c6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109c75:	00 
c0109c76:	89 14 24             	mov    %edx,(%esp)
c0109c79:	e8 25 03 00 00       	call   c0109fa3 <do_fork>
}
c0109c7e:	c9                   	leave  
c0109c7f:	c3                   	ret    

c0109c80 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109c80:	55                   	push   %ebp
c0109c81:	89 e5                	mov    %esp,%ebp
c0109c83:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109c86:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109c8d:	e8 ad b5 ff ff       	call   c010523f <alloc_pages>
c0109c92:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109c95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c99:	74 1a                	je     c0109cb5 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c9e:	89 04 24             	mov    %eax,(%esp)
c0109ca1:	e8 9b f8 ff ff       	call   c0109541 <page2kva>
c0109ca6:	89 c2                	mov    %eax,%edx
c0109ca8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cab:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109cae:	b8 00 00 00 00       	mov    $0x0,%eax
c0109cb3:	eb 05                	jmp    c0109cba <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109cb5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109cba:	c9                   	leave  
c0109cbb:	c3                   	ret    

c0109cbc <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109cbc:	55                   	push   %ebp
c0109cbd:	89 e5                	mov    %esp,%ebp
c0109cbf:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109cc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cc5:	8b 40 0c             	mov    0xc(%eax),%eax
c0109cc8:	89 04 24             	mov    %eax,(%esp)
c0109ccb:	e8 c5 f8 ff ff       	call   c0109595 <kva2page>
c0109cd0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109cd7:	00 
c0109cd8:	89 04 24             	mov    %eax,(%esp)
c0109cdb:	e8 ca b5 ff ff       	call   c01052aa <free_pages>
}
c0109ce0:	c9                   	leave  
c0109ce1:	c3                   	ret    

c0109ce2 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109ce2:	55                   	push   %ebp
c0109ce3:	89 e5                	mov    %esp,%ebp
c0109ce5:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109ce8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109cef:	e8 4b b5 ff ff       	call   c010523f <alloc_pages>
c0109cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109cf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109cfb:	75 0a                	jne    c0109d07 <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109cfd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109d02:	e9 80 00 00 00       	jmp    c0109d87 <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d0a:	89 04 24             	mov    %eax,(%esp)
c0109d0d:	e8 2f f8 ff ff       	call   c0109541 <page2kva>
c0109d12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109d15:	a1 00 ca 12 c0       	mov    0xc012ca00,%eax
c0109d1a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109d21:	00 
c0109d22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d29:	89 04 24             	mov    %eax,(%esp)
c0109d2c:	e8 f2 26 00 00       	call   c010c423 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d34:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109d3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d40:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109d47:	77 23                	ja     c0109d6c <setup_pgdir+0x8a>
c0109d49:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109d50:	c7 44 24 08 8c e5 10 	movl   $0xc010e58c,0x8(%esp)
c0109d57:	c0 
c0109d58:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c0109d5f:	00 
c0109d60:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c0109d67:	e8 84 70 ff ff       	call   c0100df0 <__panic>
c0109d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d6f:	05 00 00 00 40       	add    $0x40000000,%eax
c0109d74:	83 c8 03             	or     $0x3,%eax
c0109d77:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109d79:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109d7f:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109d87:	c9                   	leave  
c0109d88:	c3                   	ret    

c0109d89 <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109d89:	55                   	push   %ebp
c0109d8a:	89 e5                	mov    %esp,%ebp
c0109d8c:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109d8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d92:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d95:	89 04 24             	mov    %eax,(%esp)
c0109d98:	e8 f8 f7 ff ff       	call   c0109595 <kva2page>
c0109d9d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109da4:	00 
c0109da5:	89 04 24             	mov    %eax,(%esp)
c0109da8:	e8 fd b4 ff ff       	call   c01052aa <free_pages>
}
c0109dad:	c9                   	leave  
c0109dae:	c3                   	ret    

c0109daf <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109daf:	55                   	push   %ebp
c0109db0:	89 e5                	mov    %esp,%ebp
c0109db2:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109db5:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0109dba:	8b 40 18             	mov    0x18(%eax),%eax
c0109dbd:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109dc0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109dc4:	75 0a                	jne    c0109dd0 <copy_mm+0x21>
        return 0;
c0109dc6:	b8 00 00 00 00       	mov    $0x0,%eax
c0109dcb:	e9 f9 00 00 00       	jmp    c0109ec9 <copy_mm+0x11a>
    }
    if (clone_flags & CLONE_VM) {
c0109dd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd3:	25 00 01 00 00       	and    $0x100,%eax
c0109dd8:	85 c0                	test   %eax,%eax
c0109dda:	74 08                	je     c0109de4 <copy_mm+0x35>
        mm = oldmm;
c0109ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ddf:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109de2:	eb 78                	jmp    c0109e5c <copy_mm+0xad>
    }

    int ret = -E_NO_MEM;
c0109de4:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109deb:	e8 57 e2 ff ff       	call   c0108047 <mm_create>
c0109df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109df3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109df7:	75 05                	jne    c0109dfe <copy_mm+0x4f>
        goto bad_mm;
c0109df9:	e9 c8 00 00 00       	jmp    c0109ec6 <copy_mm+0x117>
    }
    if (setup_pgdir(mm) != 0) {
c0109dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e01:	89 04 24             	mov    %eax,(%esp)
c0109e04:	e8 d9 fe ff ff       	call   c0109ce2 <setup_pgdir>
c0109e09:	85 c0                	test   %eax,%eax
c0109e0b:	74 05                	je     c0109e12 <copy_mm+0x63>
        goto bad_pgdir_cleanup_mm;
c0109e0d:	e9 a9 00 00 00       	jmp    c0109ebb <copy_mm+0x10c>
    }

    lock_mm(oldmm);
c0109e12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e15:	89 04 24             	mov    %eax,(%esp)
c0109e18:	e8 f6 f7 ff ff       	call   c0109613 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109e1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e27:	89 04 24             	mov    %eax,(%esp)
c0109e2a:	e8 2f e7 ff ff       	call   c010855e <dup_mmap>
c0109e2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e35:	89 04 24             	mov    %eax,(%esp)
c0109e38:	e8 f2 f7 ff ff       	call   c010962f <unlock_mm>

    if (ret != 0) {
c0109e3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109e41:	74 19                	je     c0109e5c <copy_mm+0xad>
        goto bad_dup_cleanup_mmap;
c0109e43:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e47:	89 04 24             	mov    %eax,(%esp)
c0109e4a:	e8 10 e8 ff ff       	call   c010865f <exit_mmap>
    put_pgdir(mm);
c0109e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e52:	89 04 24             	mov    %eax,(%esp)
c0109e55:	e8 2f ff ff ff       	call   c0109d89 <put_pgdir>
c0109e5a:	eb 5f                	jmp    c0109ebb <copy_mm+0x10c>
    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
c0109e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e5f:	89 04 24             	mov    %eax,(%esp)
c0109e62:	e8 78 f7 ff ff       	call   c01095df <mm_count_inc>
    proc->mm = mm;
c0109e67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109e6d:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e73:	8b 40 0c             	mov    0xc(%eax),%eax
c0109e76:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109e79:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109e80:	77 23                	ja     c0109ea5 <copy_mm+0xf6>
c0109e82:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109e85:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109e89:	c7 44 24 08 8c e5 10 	movl   $0xc010e58c,0x8(%esp)
c0109e90:	c0 
c0109e91:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
c0109e98:	00 
c0109e99:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c0109ea0:	e8 4b 6f ff ff       	call   c0100df0 <__panic>
c0109ea5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ea8:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109eae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109eb1:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109eb4:	b8 00 00 00 00       	mov    $0x0,%eax
c0109eb9:	eb 0e                	jmp    c0109ec9 <copy_mm+0x11a>
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ebe:	89 04 24             	mov    %eax,(%esp)
c0109ec1:	e8 da e4 ff ff       	call   c01083a0 <mm_destroy>
bad_mm:
    return ret;
c0109ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109ec9:	c9                   	leave  
c0109eca:	c3                   	ret    

c0109ecb <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109ecb:	55                   	push   %ebp
c0109ecc:	89 e5                	mov    %esp,%ebp
c0109ece:	57                   	push   %edi
c0109ecf:	56                   	push   %esi
c0109ed0:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109ed1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ed4:	8b 40 0c             	mov    0xc(%eax),%eax
c0109ed7:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109edc:	89 c2                	mov    %eax,%edx
c0109ede:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ee1:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109ee4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ee7:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109eea:	8b 55 10             	mov    0x10(%ebp),%edx
c0109eed:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109ef2:	89 c1                	mov    %eax,%ecx
c0109ef4:	83 e1 01             	and    $0x1,%ecx
c0109ef7:	85 c9                	test   %ecx,%ecx
c0109ef9:	74 0e                	je     c0109f09 <copy_thread+0x3e>
c0109efb:	0f b6 0a             	movzbl (%edx),%ecx
c0109efe:	88 08                	mov    %cl,(%eax)
c0109f00:	83 c0 01             	add    $0x1,%eax
c0109f03:	83 c2 01             	add    $0x1,%edx
c0109f06:	83 eb 01             	sub    $0x1,%ebx
c0109f09:	89 c1                	mov    %eax,%ecx
c0109f0b:	83 e1 02             	and    $0x2,%ecx
c0109f0e:	85 c9                	test   %ecx,%ecx
c0109f10:	74 0f                	je     c0109f21 <copy_thread+0x56>
c0109f12:	0f b7 0a             	movzwl (%edx),%ecx
c0109f15:	66 89 08             	mov    %cx,(%eax)
c0109f18:	83 c0 02             	add    $0x2,%eax
c0109f1b:	83 c2 02             	add    $0x2,%edx
c0109f1e:	83 eb 02             	sub    $0x2,%ebx
c0109f21:	89 d9                	mov    %ebx,%ecx
c0109f23:	c1 e9 02             	shr    $0x2,%ecx
c0109f26:	89 c7                	mov    %eax,%edi
c0109f28:	89 d6                	mov    %edx,%esi
c0109f2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109f2c:	89 f2                	mov    %esi,%edx
c0109f2e:	89 f8                	mov    %edi,%eax
c0109f30:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109f35:	89 de                	mov    %ebx,%esi
c0109f37:	83 e6 02             	and    $0x2,%esi
c0109f3a:	85 f6                	test   %esi,%esi
c0109f3c:	74 0b                	je     c0109f49 <copy_thread+0x7e>
c0109f3e:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109f42:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109f46:	83 c1 02             	add    $0x2,%ecx
c0109f49:	83 e3 01             	and    $0x1,%ebx
c0109f4c:	85 db                	test   %ebx,%ebx
c0109f4e:	74 07                	je     c0109f57 <copy_thread+0x8c>
c0109f50:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109f54:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109f57:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f5a:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f5d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109f64:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f67:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109f6d:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109f70:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f73:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f76:	8b 55 08             	mov    0x8(%ebp),%edx
c0109f79:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109f7c:	8b 52 40             	mov    0x40(%edx),%edx
c0109f7f:	80 ce 02             	or     $0x2,%dh
c0109f82:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109f85:	ba d5 9a 10 c0       	mov    $0xc0109ad5,%edx
c0109f8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f8d:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109f90:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f93:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f96:	89 c2                	mov    %eax,%edx
c0109f98:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f9b:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109f9e:	5b                   	pop    %ebx
c0109f9f:	5e                   	pop    %esi
c0109fa0:	5f                   	pop    %edi
c0109fa1:	5d                   	pop    %ebp
c0109fa2:	c3                   	ret    

c0109fa3 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109fa3:	55                   	push   %ebp
c0109fa4:	89 e5                	mov    %esp,%ebp
c0109fa6:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109fa9:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109fb0:	a1 60 30 1b c0       	mov    0xc01b3060,%eax
c0109fb5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109fba:	7e 05                	jle    c0109fc1 <do_fork+0x1e>
        goto fork_out;
c0109fbc:	e9 ef 00 00 00       	jmp    c010a0b0 <do_fork+0x10d>
    }
    ret = -E_NO_MEM;
c0109fc1:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
	if((proc=alloc_proc())==NULL){
c0109fc8:	e8 7e f6 ff ff       	call   c010964b <alloc_proc>
c0109fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109fd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109fd4:	75 05                	jne    c0109fdb <do_fork+0x38>
		goto fork_out;
c0109fd6:	e9 d5 00 00 00       	jmp    c010a0b0 <do_fork+0x10d>
	}
	proc->parent = current;
c0109fdb:	8b 15 48 10 1b c0    	mov    0xc01b1048,%edx
c0109fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fe4:	89 50 14             	mov    %edx,0x14(%eax)
	assert(current->wait_state == 0);
c0109fe7:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c0109fec:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109fef:	85 c0                	test   %eax,%eax
c0109ff1:	74 24                	je     c010a017 <do_fork+0x74>
c0109ff3:	c7 44 24 0c c4 e5 10 	movl   $0xc010e5c4,0xc(%esp)
c0109ffa:	c0 
c0109ffb:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010a002:	c0 
c010a003:	c7 44 24 04 bc 01 00 	movl   $0x1bc,0x4(%esp)
c010a00a:	00 
c010a00b:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a012:	e8 d9 6d ff ff       	call   c0100df0 <__panic>

    if (setup_kstack(proc) != 0) {
c010a017:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a01a:	89 04 24             	mov    %eax,(%esp)
c010a01d:	e8 5e fc ff ff       	call   c0109c80 <setup_kstack>
c010a022:	85 c0                	test   %eax,%eax
c010a024:	74 05                	je     c010a02b <do_fork+0x88>
        goto bad_fork_cleanup_proc;
c010a026:	e9 8a 00 00 00       	jmp    c010a0b5 <do_fork+0x112>
    }
    if (copy_mm(clone_flags, proc) != 0) {
c010a02b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a02e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a032:	8b 45 08             	mov    0x8(%ebp),%eax
c010a035:	89 04 24             	mov    %eax,(%esp)
c010a038:	e8 72 fd ff ff       	call   c0109daf <copy_mm>
c010a03d:	85 c0                	test   %eax,%eax
c010a03f:	74 0e                	je     c010a04f <do_fork+0xac>
        goto bad_fork_cleanup_kstack;
c010a041:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a042:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a045:	89 04 24             	mov    %eax,(%esp)
c010a048:	e8 6f fc ff ff       	call   c0109cbc <put_kstack>
c010a04d:	eb 66                	jmp    c010a0b5 <do_fork+0x112>
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c010a04f:	8b 45 10             	mov    0x10(%ebp),%eax
c010a052:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a056:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a059:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a05d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a060:	89 04 24             	mov    %eax,(%esp)
c010a063:	e8 63 fe ff ff       	call   c0109ecb <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c010a068:	e8 ac f3 ff ff       	call   c0109419 <__intr_save>
c010a06d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c010a070:	e8 f3 f8 ff ff       	call   c0109968 <get_pid>
c010a075:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a078:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010a07b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a07e:	89 04 24             	mov    %eax,(%esp)
c010a081:	e8 67 fa ff ff       	call   c0109aed <hash_proc>
        //list_add(&proc_list, &(proc->list_link));
        //nr_process ++;
		set_links(proc);
c010a086:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a089:	89 04 24             	mov    %eax,(%esp)
c010a08c:	e8 af f7 ff ff       	call   c0109840 <set_links>
    }
    local_intr_restore(intr_flag);
c010a091:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a094:	89 04 24             	mov    %eax,(%esp)
c010a097:	e8 a7 f3 ff ff       	call   c0109443 <__intr_restore>

    wakeup_proc(proc);
c010a09c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a09f:	89 04 24             	mov    %eax,(%esp)
c010a0a2:	e8 a5 14 00 00       	call   c010b54c <wakeup_proc>

    ret = proc->pid;
c010a0a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0aa:	8b 40 04             	mov    0x4(%eax),%eax
c010a0ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
fork_out:
    return ret;
c010a0b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0b3:	eb 0d                	jmp    c010a0c2 <do_fork+0x11f>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c010a0b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0b8:	89 04 24             	mov    %eax,(%esp)
c010a0bb:	e8 25 ad ff ff       	call   c0104de5 <kfree>
    goto fork_out;
c010a0c0:	eb ee                	jmp    c010a0b0 <do_fork+0x10d>
}
c010a0c2:	c9                   	leave  
c010a0c3:	c3                   	ret    

c010a0c4 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a0c4:	55                   	push   %ebp
c010a0c5:	89 e5                	mov    %esp,%ebp
c010a0c7:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c010a0ca:	8b 15 48 10 1b c0    	mov    0xc01b1048,%edx
c010a0d0:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010a0d5:	39 c2                	cmp    %eax,%edx
c010a0d7:	75 1c                	jne    c010a0f5 <do_exit+0x31>
        panic("idleproc exit.\n");
c010a0d9:	c7 44 24 08 f2 e5 10 	movl   $0xc010e5f2,0x8(%esp)
c010a0e0:	c0 
c010a0e1:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c010a0e8:	00 
c010a0e9:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a0f0:	e8 fb 6c ff ff       	call   c0100df0 <__panic>
    }
    if (current == initproc) {
c010a0f5:	8b 15 48 10 1b c0    	mov    0xc01b1048,%edx
c010a0fb:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010a100:	39 c2                	cmp    %eax,%edx
c010a102:	75 1c                	jne    c010a120 <do_exit+0x5c>
        panic("initproc exit.\n");
c010a104:	c7 44 24 08 02 e6 10 	movl   $0xc010e602,0x8(%esp)
c010a10b:	c0 
c010a10c:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c010a113:	00 
c010a114:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a11b:	e8 d0 6c ff ff       	call   c0100df0 <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c010a120:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a125:	8b 40 18             	mov    0x18(%eax),%eax
c010a128:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c010a12b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a12f:	74 4a                	je     c010a17b <do_exit+0xb7>
        lcr3(boot_cr3);
c010a131:	a1 00 31 1b c0       	mov    0xc01b3100,%eax
c010a136:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a139:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a13c:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a13f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a142:	89 04 24             	mov    %eax,(%esp)
c010a145:	e8 af f4 ff ff       	call   c01095f9 <mm_count_dec>
c010a14a:	85 c0                	test   %eax,%eax
c010a14c:	75 21                	jne    c010a16f <do_exit+0xab>
            exit_mmap(mm);
c010a14e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a151:	89 04 24             	mov    %eax,(%esp)
c010a154:	e8 06 e5 ff ff       	call   c010865f <exit_mmap>
            put_pgdir(mm);
c010a159:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a15c:	89 04 24             	mov    %eax,(%esp)
c010a15f:	e8 25 fc ff ff       	call   c0109d89 <put_pgdir>
            mm_destroy(mm);
c010a164:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a167:	89 04 24             	mov    %eax,(%esp)
c010a16a:	e8 31 e2 ff ff       	call   c01083a0 <mm_destroy>
        }
        current->mm = NULL;
c010a16f:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a174:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a17b:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a180:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a186:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a18b:	8b 55 08             	mov    0x8(%ebp),%edx
c010a18e:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a191:	e8 83 f2 ff ff       	call   c0109419 <__intr_save>
c010a196:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a199:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a19e:	8b 40 14             	mov    0x14(%eax),%eax
c010a1a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a1a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1a7:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a1aa:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a1af:	75 10                	jne    c010a1c1 <do_exit+0xfd>
            wakeup_proc(proc);
c010a1b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1b4:	89 04 24             	mov    %eax,(%esp)
c010a1b7:	e8 90 13 00 00       	call   c010b54c <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a1bc:	e9 8b 00 00 00       	jmp    c010a24c <do_exit+0x188>
c010a1c1:	e9 86 00 00 00       	jmp    c010a24c <do_exit+0x188>
            proc = current->cptr;
c010a1c6:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a1cb:	8b 40 70             	mov    0x70(%eax),%eax
c010a1ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a1d1:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a1d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a1d9:	8b 52 78             	mov    0x78(%edx),%edx
c010a1dc:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a1df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1e2:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a1e9:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010a1ee:	8b 50 70             	mov    0x70(%eax),%edx
c010a1f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1f4:	89 50 78             	mov    %edx,0x78(%eax)
c010a1f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1fa:	8b 40 78             	mov    0x78(%eax),%eax
c010a1fd:	85 c0                	test   %eax,%eax
c010a1ff:	74 0e                	je     c010a20f <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a201:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010a206:	8b 40 70             	mov    0x70(%eax),%eax
c010a209:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a20c:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a20f:	8b 15 44 10 1b c0    	mov    0xc01b1044,%edx
c010a215:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a218:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a21b:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010a220:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a223:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a226:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a229:	8b 00                	mov    (%eax),%eax
c010a22b:	83 f8 03             	cmp    $0x3,%eax
c010a22e:	75 1c                	jne    c010a24c <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a230:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010a235:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a238:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a23d:	75 0d                	jne    c010a24c <do_exit+0x188>
                    wakeup_proc(initproc);
c010a23f:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010a244:	89 04 24             	mov    %eax,(%esp)
c010a247:	e8 00 13 00 00       	call   c010b54c <wakeup_proc>
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
c010a24c:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a251:	8b 40 70             	mov    0x70(%eax),%eax
c010a254:	85 c0                	test   %eax,%eax
c010a256:	0f 85 6a ff ff ff    	jne    c010a1c6 <do_exit+0x102>
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a25c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a25f:	89 04 24             	mov    %eax,(%esp)
c010a262:	e8 dc f1 ff ff       	call   c0109443 <__intr_restore>
    
    schedule();
c010a267:	e8 79 13 00 00       	call   c010b5e5 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a26c:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a271:	8b 40 04             	mov    0x4(%eax),%eax
c010a274:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a278:	c7 44 24 08 14 e6 10 	movl   $0xc010e614,0x8(%esp)
c010a27f:	c0 
c010a280:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c010a287:	00 
c010a288:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a28f:	e8 5c 6b ff ff       	call   c0100df0 <__panic>

c010a294 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a294:	55                   	push   %ebp
c010a295:	89 e5                	mov    %esp,%ebp
c010a297:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a29a:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a29f:	8b 40 18             	mov    0x18(%eax),%eax
c010a2a2:	85 c0                	test   %eax,%eax
c010a2a4:	74 1c                	je     c010a2c2 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a2a6:	c7 44 24 08 34 e6 10 	movl   $0xc010e634,0x8(%esp)
c010a2ad:	c0 
c010a2ae:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c010a2b5:	00 
c010a2b6:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a2bd:	e8 2e 6b ff ff       	call   c0100df0 <__panic>
    }

    int ret = -E_NO_MEM;
c010a2c2:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a2c9:	e8 79 dd ff ff       	call   c0108047 <mm_create>
c010a2ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a2d1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a2d5:	75 06                	jne    c010a2dd <load_icode+0x49>
        goto bad_mm;
c010a2d7:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a2d8:	e9 ef 05 00 00       	jmp    c010a8cc <load_icode+0x638>
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a2dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a2e0:	89 04 24             	mov    %eax,(%esp)
c010a2e3:	e8 fa f9 ff ff       	call   c0109ce2 <setup_pgdir>
c010a2e8:	85 c0                	test   %eax,%eax
c010a2ea:	74 05                	je     c010a2f1 <load_icode+0x5d>
        goto bad_pgdir_cleanup_mm;
c010a2ec:	e9 f6 05 00 00       	jmp    c010a8e7 <load_icode+0x653>
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a2f1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a2f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a2fa:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a2fd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a300:	01 d0                	add    %edx,%eax
c010a302:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a305:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a308:	8b 00                	mov    (%eax),%eax
c010a30a:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a30f:	74 0c                	je     c010a31d <load_icode+0x89>
        ret = -E_INVAL_ELF;
c010a311:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a318:	e9 bf 05 00 00       	jmp    c010a8dc <load_icode+0x648>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a31d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a320:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a324:	0f b7 c0             	movzwl %ax,%eax
c010a327:	c1 e0 05             	shl    $0x5,%eax
c010a32a:	89 c2                	mov    %eax,%edx
c010a32c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a32f:	01 d0                	add    %edx,%eax
c010a331:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a334:	e9 13 03 00 00       	jmp    c010a64c <load_icode+0x3b8>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a339:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a33c:	8b 00                	mov    (%eax),%eax
c010a33e:	83 f8 01             	cmp    $0x1,%eax
c010a341:	74 05                	je     c010a348 <load_icode+0xb4>
            continue ;
c010a343:	e9 00 03 00 00       	jmp    c010a648 <load_icode+0x3b4>
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a348:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a34b:	8b 50 10             	mov    0x10(%eax),%edx
c010a34e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a351:	8b 40 14             	mov    0x14(%eax),%eax
c010a354:	39 c2                	cmp    %eax,%edx
c010a356:	76 0c                	jbe    c010a364 <load_icode+0xd0>
            ret = -E_INVAL_ELF;
c010a358:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a35f:	e9 6d 05 00 00       	jmp    c010a8d1 <load_icode+0x63d>
        }
        if (ph->p_filesz == 0) {
c010a364:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a367:	8b 40 10             	mov    0x10(%eax),%eax
c010a36a:	85 c0                	test   %eax,%eax
c010a36c:	75 05                	jne    c010a373 <load_icode+0xdf>
            continue ;
c010a36e:	e9 d5 02 00 00       	jmp    c010a648 <load_icode+0x3b4>
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a373:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a37a:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a381:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a384:	8b 40 18             	mov    0x18(%eax),%eax
c010a387:	83 e0 01             	and    $0x1,%eax
c010a38a:	85 c0                	test   %eax,%eax
c010a38c:	74 04                	je     c010a392 <load_icode+0xfe>
c010a38e:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a392:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a395:	8b 40 18             	mov    0x18(%eax),%eax
c010a398:	83 e0 02             	and    $0x2,%eax
c010a39b:	85 c0                	test   %eax,%eax
c010a39d:	74 04                	je     c010a3a3 <load_icode+0x10f>
c010a39f:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a3a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3a6:	8b 40 18             	mov    0x18(%eax),%eax
c010a3a9:	83 e0 04             	and    $0x4,%eax
c010a3ac:	85 c0                	test   %eax,%eax
c010a3ae:	74 04                	je     c010a3b4 <load_icode+0x120>
c010a3b0:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a3b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a3b7:	83 e0 02             	and    $0x2,%eax
c010a3ba:	85 c0                	test   %eax,%eax
c010a3bc:	74 04                	je     c010a3c2 <load_icode+0x12e>
c010a3be:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a3c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3c5:	8b 50 14             	mov    0x14(%eax),%edx
c010a3c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3cb:	8b 40 08             	mov    0x8(%eax),%eax
c010a3ce:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a3d5:	00 
c010a3d6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a3d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a3dd:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a3e1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a3e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a3e8:	89 04 24             	mov    %eax,(%esp)
c010a3eb:	e8 52 e0 ff ff       	call   c0108442 <mm_map>
c010a3f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a3f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a3f7:	74 05                	je     c010a3fe <load_icode+0x16a>
            goto bad_cleanup_mmap;
c010a3f9:	e9 d3 04 00 00       	jmp    c010a8d1 <load_icode+0x63d>
        }
        unsigned char *from = binary + ph->p_offset;
c010a3fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a401:	8b 50 04             	mov    0x4(%eax),%edx
c010a404:	8b 45 08             	mov    0x8(%ebp),%eax
c010a407:	01 d0                	add    %edx,%eax
c010a409:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a40c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a40f:	8b 40 08             	mov    0x8(%eax),%eax
c010a412:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a415:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a418:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a41b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a41e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a423:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a426:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a42d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a430:	8b 50 08             	mov    0x8(%eax),%edx
c010a433:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a436:	8b 40 10             	mov    0x10(%eax),%eax
c010a439:	01 d0                	add    %edx,%eax
c010a43b:	89 45 c0             	mov    %eax,-0x40(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a43e:	e9 90 00 00 00       	jmp    c010a4d3 <load_icode+0x23f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a443:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a446:	8b 40 0c             	mov    0xc(%eax),%eax
c010a449:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a44c:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a450:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a453:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a457:	89 04 24             	mov    %eax,(%esp)
c010a45a:	e8 2e bc ff ff       	call   c010608d <pgdir_alloc_page>
c010a45f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a462:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a466:	75 05                	jne    c010a46d <load_icode+0x1d9>
                goto bad_cleanup_mmap;
c010a468:	e9 64 04 00 00       	jmp    c010a8d1 <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a46d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a470:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a473:	29 c2                	sub    %eax,%edx
c010a475:	89 d0                	mov    %edx,%eax
c010a477:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a47a:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a47f:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a482:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a485:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a48c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a48f:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a492:	73 0d                	jae    c010a4a1 <load_icode+0x20d>
                size -= la - end;
c010a494:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a497:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a49a:	29 c2                	sub    %eax,%edx
c010a49c:	89 d0                	mov    %edx,%eax
c010a49e:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a4a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a4a4:	89 04 24             	mov    %eax,(%esp)
c010a4a7:	e8 95 f0 ff ff       	call   c0109541 <page2kva>
c010a4ac:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a4af:	01 c2                	add    %eax,%edx
c010a4b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4b4:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a4b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a4bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a4bf:	89 14 24             	mov    %edx,(%esp)
c010a4c2:	e8 5c 1f 00 00       	call   c010c423 <memcpy>
            start += size, from += size;
c010a4c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4ca:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a4cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4d0:	01 45 e0             	add    %eax,-0x20(%ebp)
        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a4d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4d6:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a4d9:	0f 82 64 ff ff ff    	jb     c010a443 <load_icode+0x1af>
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a4df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4e2:	8b 50 08             	mov    0x8(%eax),%edx
c010a4e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4e8:	8b 40 14             	mov    0x14(%eax),%eax
c010a4eb:	01 d0                	add    %edx,%eax
c010a4ed:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a4f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4f3:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4f6:	0f 83 b0 00 00 00    	jae    c010a5ac <load_icode+0x318>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a4fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4ff:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a502:	75 05                	jne    c010a509 <load_icode+0x275>
                continue ;
c010a504:	e9 3f 01 00 00       	jmp    c010a648 <load_icode+0x3b4>
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a509:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a50c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a50f:	29 c2                	sub    %eax,%edx
c010a511:	89 d0                	mov    %edx,%eax
c010a513:	05 00 10 00 00       	add    $0x1000,%eax
c010a518:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a51b:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a520:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a523:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a526:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a529:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a52c:	73 0d                	jae    c010a53b <load_icode+0x2a7>
                size -= la - end;
c010a52e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a531:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a534:	29 c2                	sub    %eax,%edx
c010a536:	89 d0                	mov    %edx,%eax
c010a538:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a53b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a53e:	89 04 24             	mov    %eax,(%esp)
c010a541:	e8 fb ef ff ff       	call   c0109541 <page2kva>
c010a546:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a549:	01 c2                	add    %eax,%edx
c010a54b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a54e:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a552:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a559:	00 
c010a55a:	89 14 24             	mov    %edx,(%esp)
c010a55d:	e8 df 1d 00 00       	call   c010c341 <memset>
            start += size;
c010a562:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a565:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a568:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a56b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a56e:	73 08                	jae    c010a578 <load_icode+0x2e4>
c010a570:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a573:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a576:	74 34                	je     c010a5ac <load_icode+0x318>
c010a578:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a57b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a57e:	72 08                	jb     c010a588 <load_icode+0x2f4>
c010a580:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a583:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a586:	74 24                	je     c010a5ac <load_icode+0x318>
c010a588:	c7 44 24 0c 5c e6 10 	movl   $0xc010e65c,0xc(%esp)
c010a58f:	c0 
c010a590:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010a597:	c0 
c010a598:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c010a59f:	00 
c010a5a0:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a5a7:	e8 44 68 ff ff       	call   c0100df0 <__panic>
        }
        while (start < end) {
c010a5ac:	e9 8b 00 00 00       	jmp    c010a63c <load_icode+0x3a8>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a5b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5b4:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a5ba:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a5be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a5c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a5c5:	89 04 24             	mov    %eax,(%esp)
c010a5c8:	e8 c0 ba ff ff       	call   c010608d <pgdir_alloc_page>
c010a5cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a5d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a5d4:	75 05                	jne    c010a5db <load_icode+0x347>
                goto bad_cleanup_mmap;
c010a5d6:	e9 f6 02 00 00       	jmp    c010a8d1 <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a5db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a5de:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a5e1:	29 c2                	sub    %eax,%edx
c010a5e3:	89 d0                	mov    %edx,%eax
c010a5e5:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a5e8:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a5ed:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a5f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a5f3:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a5fa:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a5fd:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a600:	73 0d                	jae    c010a60f <load_icode+0x37b>
                size -= la - end;
c010a602:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a605:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a608:	29 c2                	sub    %eax,%edx
c010a60a:	89 d0                	mov    %edx,%eax
c010a60c:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a60f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a612:	89 04 24             	mov    %eax,(%esp)
c010a615:	e8 27 ef ff ff       	call   c0109541 <page2kva>
c010a61a:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a61d:	01 c2                	add    %eax,%edx
c010a61f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a622:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a626:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a62d:	00 
c010a62e:	89 14 24             	mov    %edx,(%esp)
c010a631:	e8 0b 1d 00 00       	call   c010c341 <memset>
            start += size;
c010a636:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a639:	01 45 d8             	add    %eax,-0x28(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
c010a63c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a63f:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a642:	0f 82 69 ff ff ff    	jb     c010a5b1 <load_icode+0x31d>
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
c010a648:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a64c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a64f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a652:	0f 82 e1 fc ff ff    	jb     c010a339 <load_icode+0xa5>
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a658:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a65f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a666:	00 
c010a667:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a66a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a66e:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a675:	00 
c010a676:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a67d:	af 
c010a67e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a681:	89 04 24             	mov    %eax,(%esp)
c010a684:	e8 b9 dd ff ff       	call   c0108442 <mm_map>
c010a689:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a68c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a690:	74 05                	je     c010a697 <load_icode+0x403>
        goto bad_cleanup_mmap;
c010a692:	e9 3a 02 00 00       	jmp    c010a8d1 <load_icode+0x63d>
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a697:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a69a:	8b 40 0c             	mov    0xc(%eax),%eax
c010a69d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a6a4:	00 
c010a6a5:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a6ac:	af 
c010a6ad:	89 04 24             	mov    %eax,(%esp)
c010a6b0:	e8 d8 b9 ff ff       	call   c010608d <pgdir_alloc_page>
c010a6b5:	85 c0                	test   %eax,%eax
c010a6b7:	75 24                	jne    c010a6dd <load_icode+0x449>
c010a6b9:	c7 44 24 0c 98 e6 10 	movl   $0xc010e698,0xc(%esp)
c010a6c0:	c0 
c010a6c1:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010a6c8:	c0 
c010a6c9:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
c010a6d0:	00 
c010a6d1:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a6d8:	e8 13 67 ff ff       	call   c0100df0 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a6dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6e0:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a6ea:	00 
c010a6eb:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a6f2:	af 
c010a6f3:	89 04 24             	mov    %eax,(%esp)
c010a6f6:	e8 92 b9 ff ff       	call   c010608d <pgdir_alloc_page>
c010a6fb:	85 c0                	test   %eax,%eax
c010a6fd:	75 24                	jne    c010a723 <load_icode+0x48f>
c010a6ff:	c7 44 24 0c dc e6 10 	movl   $0xc010e6dc,0xc(%esp)
c010a706:	c0 
c010a707:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010a70e:	c0 
c010a70f:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
c010a716:	00 
c010a717:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a71e:	e8 cd 66 ff ff       	call   c0100df0 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a723:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a726:	8b 40 0c             	mov    0xc(%eax),%eax
c010a729:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a730:	00 
c010a731:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a738:	af 
c010a739:	89 04 24             	mov    %eax,(%esp)
c010a73c:	e8 4c b9 ff ff       	call   c010608d <pgdir_alloc_page>
c010a741:	85 c0                	test   %eax,%eax
c010a743:	75 24                	jne    c010a769 <load_icode+0x4d5>
c010a745:	c7 44 24 0c 20 e7 10 	movl   $0xc010e720,0xc(%esp)
c010a74c:	c0 
c010a74d:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010a754:	c0 
c010a755:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
c010a75c:	00 
c010a75d:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a764:	e8 87 66 ff ff       	call   c0100df0 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a769:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a76c:	8b 40 0c             	mov    0xc(%eax),%eax
c010a76f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a776:	00 
c010a777:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a77e:	af 
c010a77f:	89 04 24             	mov    %eax,(%esp)
c010a782:	e8 06 b9 ff ff       	call   c010608d <pgdir_alloc_page>
c010a787:	85 c0                	test   %eax,%eax
c010a789:	75 24                	jne    c010a7af <load_icode+0x51b>
c010a78b:	c7 44 24 0c 64 e7 10 	movl   $0xc010e764,0xc(%esp)
c010a792:	c0 
c010a793:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010a79a:	c0 
c010a79b:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c010a7a2:	00 
c010a7a3:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a7aa:	e8 41 66 ff ff       	call   c0100df0 <__panic>
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a7af:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7b2:	89 04 24             	mov    %eax,(%esp)
c010a7b5:	e8 25 ee ff ff       	call   c01095df <mm_count_inc>
    current->mm = mm;
c010a7ba:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a7bf:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a7c2:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a7c5:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a7ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a7cd:	8b 52 0c             	mov    0xc(%edx),%edx
c010a7d0:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a7d3:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a7da:	77 23                	ja     c010a7ff <load_icode+0x56b>
c010a7dc:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a7df:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a7e3:	c7 44 24 08 8c e5 10 	movl   $0xc010e58c,0x8(%esp)
c010a7ea:	c0 
c010a7eb:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
c010a7f2:	00 
c010a7f3:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a7fa:	e8 f1 65 ff ff       	call   c0100df0 <__panic>
c010a7ff:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a802:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a808:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a80b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a80e:	8b 40 0c             	mov    0xc(%eax),%eax
c010a811:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a814:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a81b:	77 23                	ja     c010a840 <load_icode+0x5ac>
c010a81d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a820:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a824:	c7 44 24 08 8c e5 10 	movl   $0xc010e58c,0x8(%esp)
c010a82b:	c0 
c010a82c:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
c010a833:	00 
c010a834:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010a83b:	e8 b0 65 ff ff       	call   c0100df0 <__panic>
c010a840:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a843:	05 00 00 00 40       	add    $0x40000000,%eax
c010a848:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a84b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a84e:	0f 22 d8             	mov    %eax,%cr3

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a851:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a856:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a859:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a85c:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a863:	00 
c010a864:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a86b:	00 
c010a86c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a86f:	89 04 24             	mov    %eax,(%esp)
c010a872:	e8 ca 1a 00 00       	call   c010c341 <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010a877:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a87a:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a880:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a883:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a889:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a88c:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a890:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a893:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a897:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a89a:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a89e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a8a1:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a8a5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a8a8:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a8af:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a8b2:	8b 50 18             	mov    0x18(%eax),%edx
c010a8b5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a8b8:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a8bb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a8be:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a8c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a8cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a8cf:	eb 23                	jmp    c010a8f4 <load_icode+0x660>
bad_cleanup_mmap:
    exit_mmap(mm);
c010a8d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8d4:	89 04 24             	mov    %eax,(%esp)
c010a8d7:	e8 83 dd ff ff       	call   c010865f <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010a8dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8df:	89 04 24             	mov    %eax,(%esp)
c010a8e2:	e8 a2 f4 ff ff       	call   c0109d89 <put_pgdir>
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a8e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8ea:	89 04 24             	mov    %eax,(%esp)
c010a8ed:	e8 ae da ff ff       	call   c01083a0 <mm_destroy>
bad_mm:
    goto out;
c010a8f2:	eb d8                	jmp    c010a8cc <load_icode+0x638>
}
c010a8f4:	c9                   	leave  
c010a8f5:	c3                   	ret    

c010a8f6 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a8f6:	55                   	push   %ebp
c010a8f7:	89 e5                	mov    %esp,%ebp
c010a8f9:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a8fc:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a901:	8b 40 18             	mov    0x18(%eax),%eax
c010a904:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a907:	8b 45 08             	mov    0x8(%ebp),%eax
c010a90a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a911:	00 
c010a912:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a915:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a919:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a920:	89 04 24             	mov    %eax,(%esp)
c010a923:	e8 db e7 ff ff       	call   c0109103 <user_mem_check>
c010a928:	85 c0                	test   %eax,%eax
c010a92a:	75 0a                	jne    c010a936 <do_execve+0x40>
        return -E_INVAL;
c010a92c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a931:	e9 f4 00 00 00       	jmp    c010aa2a <do_execve+0x134>
    }
    if (len > PROC_NAME_LEN) {
c010a936:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a93a:	76 07                	jbe    c010a943 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a93c:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a943:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a94a:	00 
c010a94b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a952:	00 
c010a953:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a956:	89 04 24             	mov    %eax,(%esp)
c010a959:	e8 e3 19 00 00       	call   c010c341 <memset>
    memcpy(local_name, name, len);
c010a95e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a961:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a965:	8b 45 08             	mov    0x8(%ebp),%eax
c010a968:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a96c:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a96f:	89 04 24             	mov    %eax,(%esp)
c010a972:	e8 ac 1a 00 00       	call   c010c423 <memcpy>

    if (mm != NULL) {
c010a977:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a97b:	74 4a                	je     c010a9c7 <do_execve+0xd1>
        lcr3(boot_cr3);
c010a97d:	a1 00 31 1b c0       	mov    0xc01b3100,%eax
c010a982:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a985:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a988:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a98e:	89 04 24             	mov    %eax,(%esp)
c010a991:	e8 63 ec ff ff       	call   c01095f9 <mm_count_dec>
c010a996:	85 c0                	test   %eax,%eax
c010a998:	75 21                	jne    c010a9bb <do_execve+0xc5>
            exit_mmap(mm);
c010a99a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a99d:	89 04 24             	mov    %eax,(%esp)
c010a9a0:	e8 ba dc ff ff       	call   c010865f <exit_mmap>
            put_pgdir(mm);
c010a9a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9a8:	89 04 24             	mov    %eax,(%esp)
c010a9ab:	e8 d9 f3 ff ff       	call   c0109d89 <put_pgdir>
            mm_destroy(mm);
c010a9b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9b3:	89 04 24             	mov    %eax,(%esp)
c010a9b6:	e8 e5 d9 ff ff       	call   c01083a0 <mm_destroy>
        }
        current->mm = NULL;
c010a9bb:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010a9c0:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010a9c7:	8b 45 14             	mov    0x14(%ebp),%eax
c010a9ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a9ce:	8b 45 10             	mov    0x10(%ebp),%eax
c010a9d1:	89 04 24             	mov    %eax,(%esp)
c010a9d4:	e8 bb f8 ff ff       	call   c010a294 <load_icode>
c010a9d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a9dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a9e0:	74 2f                	je     c010aa11 <do_execve+0x11b>
        goto execve_exit;
c010a9e2:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a9e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a9e6:	89 04 24             	mov    %eax,(%esp)
c010a9e9:	e8 d6 f6 ff ff       	call   c010a0c4 <do_exit>
    panic("already exit: %e.\n", ret);
c010a9ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a9f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a9f5:	c7 44 24 08 a7 e7 10 	movl   $0xc010e7a7,0x8(%esp)
c010a9fc:	c0 
c010a9fd:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
c010aa04:	00 
c010aa05:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010aa0c:	e8 df 63 ff ff       	call   c0100df0 <__panic>
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010aa11:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010aa16:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010aa19:	89 54 24 04          	mov    %edx,0x4(%esp)
c010aa1d:	89 04 24             	mov    %eax,(%esp)
c010aa20:	e8 96 ed ff ff       	call   c01097bb <set_proc_name>
    return 0;
c010aa25:	b8 00 00 00 00       	mov    $0x0,%eax

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
c010aa2a:	c9                   	leave  
c010aa2b:	c3                   	ret    

c010aa2c <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010aa2c:	55                   	push   %ebp
c010aa2d:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010aa2f:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010aa34:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
	//lab6 challenge
    //current->fair_run_time += current->rq->max_time_slice * current->fair_priority;
    return 0;
c010aa3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aa40:	5d                   	pop    %ebp
c010aa41:	c3                   	ret    

c010aa42 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010aa42:	55                   	push   %ebp
c010aa43:	89 e5                	mov    %esp,%ebp
c010aa45:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010aa48:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010aa4d:	8b 40 18             	mov    0x18(%eax),%eax
c010aa50:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010aa53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010aa57:	74 30                	je     c010aa89 <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010aa59:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa5c:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010aa63:	00 
c010aa64:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010aa6b:	00 
c010aa6c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aa73:	89 04 24             	mov    %eax,(%esp)
c010aa76:	e8 88 e6 ff ff       	call   c0109103 <user_mem_check>
c010aa7b:	85 c0                	test   %eax,%eax
c010aa7d:	75 0a                	jne    c010aa89 <do_wait+0x47>
            return -E_INVAL;
c010aa7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010aa84:	e9 4b 01 00 00       	jmp    c010abd4 <do_wait+0x192>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010aa89:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010aa90:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aa94:	74 39                	je     c010aacf <do_wait+0x8d>
        proc = find_proc(pid);
c010aa96:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa99:	89 04 24             	mov    %eax,(%esp)
c010aa9c:	e8 fb f0 ff ff       	call   c0109b9c <find_proc>
c010aaa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010aaa4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aaa8:	74 54                	je     c010aafe <do_wait+0xbc>
c010aaaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaad:	8b 50 14             	mov    0x14(%eax),%edx
c010aab0:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010aab5:	39 c2                	cmp    %eax,%edx
c010aab7:	75 45                	jne    c010aafe <do_wait+0xbc>
            haskid = 1;
c010aab9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010aac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aac3:	8b 00                	mov    (%eax),%eax
c010aac5:	83 f8 03             	cmp    $0x3,%eax
c010aac8:	75 34                	jne    c010aafe <do_wait+0xbc>
                goto found;
c010aaca:	e9 80 00 00 00       	jmp    c010ab4f <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
c010aacf:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010aad4:	8b 40 70             	mov    0x70(%eax),%eax
c010aad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010aada:	eb 1c                	jmp    c010aaf8 <do_wait+0xb6>
            haskid = 1;
c010aadc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010aae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aae6:	8b 00                	mov    (%eax),%eax
c010aae8:	83 f8 03             	cmp    $0x3,%eax
c010aaeb:	75 02                	jne    c010aaef <do_wait+0xad>
                goto found;
c010aaed:	eb 60                	jmp    c010ab4f <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
c010aaef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaf2:	8b 40 78             	mov    0x78(%eax),%eax
c010aaf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aaf8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aafc:	75 de                	jne    c010aadc <do_wait+0x9a>
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
c010aafe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ab02:	74 41                	je     c010ab45 <do_wait+0x103>
        current->state = PROC_SLEEPING;
c010ab04:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010ab09:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010ab0f:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010ab14:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010ab1b:	e8 c5 0a 00 00       	call   c010b5e5 <schedule>
        if (current->flags & PF_EXITING) {
c010ab20:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010ab25:	8b 40 44             	mov    0x44(%eax),%eax
c010ab28:	83 e0 01             	and    $0x1,%eax
c010ab2b:	85 c0                	test   %eax,%eax
c010ab2d:	74 11                	je     c010ab40 <do_wait+0xfe>
            do_exit(-E_KILLED);
c010ab2f:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010ab36:	e8 89 f5 ff ff       	call   c010a0c4 <do_exit>
        }
        goto repeat;
c010ab3b:	e9 49 ff ff ff       	jmp    c010aa89 <do_wait+0x47>
c010ab40:	e9 44 ff ff ff       	jmp    c010aa89 <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010ab45:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010ab4a:	e9 85 00 00 00       	jmp    c010abd4 <do_wait+0x192>

found:
    if (proc == idleproc || proc == initproc) {
c010ab4f:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010ab54:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ab57:	74 0a                	je     c010ab63 <do_wait+0x121>
c010ab59:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010ab5e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ab61:	75 1c                	jne    c010ab7f <do_wait+0x13d>
        panic("wait idleproc or initproc.\n");
c010ab63:	c7 44 24 08 ba e7 10 	movl   $0xc010e7ba,0x8(%esp)
c010ab6a:	c0 
c010ab6b:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
c010ab72:	00 
c010ab73:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010ab7a:	e8 71 62 ff ff       	call   c0100df0 <__panic>
    }
    if (code_store != NULL) {
c010ab7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ab83:	74 0b                	je     c010ab90 <do_wait+0x14e>
        *code_store = proc->exit_code;
c010ab85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab88:	8b 50 68             	mov    0x68(%eax),%edx
c010ab8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab8e:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010ab90:	e8 84 e8 ff ff       	call   c0109419 <__intr_save>
c010ab95:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010ab98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab9b:	89 04 24             	mov    %eax,(%esp)
c010ab9e:	e8 c6 ef ff ff       	call   c0109b69 <unhash_proc>
        remove_links(proc);
c010aba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aba6:	89 04 24             	mov    %eax,(%esp)
c010aba9:	e8 37 ed ff ff       	call   c01098e5 <remove_links>
    }
    local_intr_restore(intr_flag);
c010abae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010abb1:	89 04 24             	mov    %eax,(%esp)
c010abb4:	e8 8a e8 ff ff       	call   c0109443 <__intr_restore>
    put_kstack(proc);
c010abb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abbc:	89 04 24             	mov    %eax,(%esp)
c010abbf:	e8 f8 f0 ff ff       	call   c0109cbc <put_kstack>
    kfree(proc);
c010abc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abc7:	89 04 24             	mov    %eax,(%esp)
c010abca:	e8 16 a2 ff ff       	call   c0104de5 <kfree>
    return 0;
c010abcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010abd4:	c9                   	leave  
c010abd5:	c3                   	ret    

c010abd6 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010abd6:	55                   	push   %ebp
c010abd7:	89 e5                	mov    %esp,%ebp
c010abd9:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010abdc:	8b 45 08             	mov    0x8(%ebp),%eax
c010abdf:	89 04 24             	mov    %eax,(%esp)
c010abe2:	e8 b5 ef ff ff       	call   c0109b9c <find_proc>
c010abe7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010abea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010abee:	74 41                	je     c010ac31 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010abf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abf3:	8b 40 44             	mov    0x44(%eax),%eax
c010abf6:	83 e0 01             	and    $0x1,%eax
c010abf9:	85 c0                	test   %eax,%eax
c010abfb:	75 2d                	jne    c010ac2a <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010abfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac00:	8b 40 44             	mov    0x44(%eax),%eax
c010ac03:	83 c8 01             	or     $0x1,%eax
c010ac06:	89 c2                	mov    %eax,%edx
c010ac08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac0b:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010ac0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac11:	8b 40 6c             	mov    0x6c(%eax),%eax
c010ac14:	85 c0                	test   %eax,%eax
c010ac16:	79 0b                	jns    c010ac23 <do_kill+0x4d>
                wakeup_proc(proc);
c010ac18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac1b:	89 04 24             	mov    %eax,(%esp)
c010ac1e:	e8 29 09 00 00       	call   c010b54c <wakeup_proc>
            }
            return 0;
c010ac23:	b8 00 00 00 00       	mov    $0x0,%eax
c010ac28:	eb 0c                	jmp    c010ac36 <do_kill+0x60>
        }
        return -E_KILLED;
c010ac2a:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010ac2f:	eb 05                	jmp    c010ac36 <do_kill+0x60>
    }
    return -E_INVAL;
c010ac31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010ac36:	c9                   	leave  
c010ac37:	c3                   	ret    

c010ac38 <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010ac38:	55                   	push   %ebp
c010ac39:	89 e5                	mov    %esp,%ebp
c010ac3b:	57                   	push   %edi
c010ac3c:	56                   	push   %esi
c010ac3d:	53                   	push   %ebx
c010ac3e:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010ac41:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac44:	89 04 24             	mov    %eax,(%esp)
c010ac47:	e8 c6 13 00 00       	call   c010c012 <strlen>
c010ac4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010ac4f:	b8 04 00 00 00       	mov    $0x4,%eax
c010ac54:	8b 55 08             	mov    0x8(%ebp),%edx
c010ac57:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010ac5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010ac5d:	8b 75 10             	mov    0x10(%ebp),%esi
c010ac60:	89 f7                	mov    %esi,%edi
c010ac62:	cd 80                	int    $0x80
c010ac64:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010ac67:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010ac6a:	83 c4 2c             	add    $0x2c,%esp
c010ac6d:	5b                   	pop    %ebx
c010ac6e:	5e                   	pop    %esi
c010ac6f:	5f                   	pop    %edi
c010ac70:	5d                   	pop    %ebp
c010ac71:	c3                   	ret    

c010ac72 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010ac72:	55                   	push   %ebp
c010ac73:	89 e5                	mov    %esp,%ebp
c010ac75:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
c010ac78:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010ac7d:	8b 40 04             	mov    0x4(%eax),%eax
c010ac80:	c7 44 24 08 d6 e7 10 	movl   $0xc010e7d6,0x8(%esp)
c010ac87:	c0 
c010ac88:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac8c:	c7 04 24 e0 e7 10 c0 	movl   $0xc010e7e0,(%esp)
c010ac93:	e8 cc 56 ff ff       	call   c0100364 <cprintf>
c010ac98:	b8 c7 79 00 00       	mov    $0x79c7,%eax
c010ac9d:	89 44 24 08          	mov    %eax,0x8(%esp)
c010aca1:	c7 44 24 04 11 05 18 	movl   $0xc0180511,0x4(%esp)
c010aca8:	c0 
c010aca9:	c7 04 24 d6 e7 10 c0 	movl   $0xc010e7d6,(%esp)
c010acb0:	e8 83 ff ff ff       	call   c010ac38 <kernel_execve>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
c010acb5:	c7 44 24 08 07 e8 10 	movl   $0xc010e807,0x8(%esp)
c010acbc:	c0 
c010acbd:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
c010acc4:	00 
c010acc5:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010accc:	e8 1f 61 ff ff       	call   c0100df0 <__panic>

c010acd1 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010acd1:	55                   	push   %ebp
c010acd2:	89 e5                	mov    %esp,%ebp
c010acd4:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010acd7:	e8 00 a6 ff ff       	call   c01052dc <nr_free_pages>
c010acdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010acdf:	e8 c9 9f ff ff       	call   c0104cad <kallocated>
c010ace4:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ace7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010acee:	00 
c010acef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010acf6:	00 
c010acf7:	c7 04 24 72 ac 10 c0 	movl   $0xc010ac72,(%esp)
c010acfe:	e8 0b ef ff ff       	call   c0109c0e <kernel_thread>
c010ad03:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010ad06:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010ad0a:	7f 1c                	jg     c010ad28 <init_main+0x57>
        panic("create user_main failed.\n");
c010ad0c:	c7 44 24 08 21 e8 10 	movl   $0xc010e821,0x8(%esp)
c010ad13:	c0 
c010ad14:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
c010ad1b:	00 
c010ad1c:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010ad23:	e8 c8 60 ff ff       	call   c0100df0 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
c010ad28:	eb 05                	jmp    c010ad2f <init_main+0x5e>
        schedule();
c010ad2a:	e8 b6 08 00 00       	call   c010b5e5 <schedule>
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
c010ad2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ad36:	00 
c010ad37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ad3e:	e8 ff fc ff ff       	call   c010aa42 <do_wait>
c010ad43:	85 c0                	test   %eax,%eax
c010ad45:	74 e3                	je     c010ad2a <init_main+0x59>
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
c010ad47:	c7 04 24 3c e8 10 c0 	movl   $0xc010e83c,(%esp)
c010ad4e:	e8 11 56 ff ff       	call   c0100364 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010ad53:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010ad58:	8b 40 70             	mov    0x70(%eax),%eax
c010ad5b:	85 c0                	test   %eax,%eax
c010ad5d:	75 18                	jne    c010ad77 <init_main+0xa6>
c010ad5f:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010ad64:	8b 40 74             	mov    0x74(%eax),%eax
c010ad67:	85 c0                	test   %eax,%eax
c010ad69:	75 0c                	jne    c010ad77 <init_main+0xa6>
c010ad6b:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010ad70:	8b 40 78             	mov    0x78(%eax),%eax
c010ad73:	85 c0                	test   %eax,%eax
c010ad75:	74 24                	je     c010ad9b <init_main+0xca>
c010ad77:	c7 44 24 0c 60 e8 10 	movl   $0xc010e860,0xc(%esp)
c010ad7e:	c0 
c010ad7f:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010ad86:	c0 
c010ad87:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
c010ad8e:	00 
c010ad8f:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010ad96:	e8 55 60 ff ff       	call   c0100df0 <__panic>
    assert(nr_process == 2);
c010ad9b:	a1 60 30 1b c0       	mov    0xc01b3060,%eax
c010ada0:	83 f8 02             	cmp    $0x2,%eax
c010ada3:	74 24                	je     c010adc9 <init_main+0xf8>
c010ada5:	c7 44 24 0c ab e8 10 	movl   $0xc010e8ab,0xc(%esp)
c010adac:	c0 
c010adad:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010adb4:	c0 
c010adb5:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
c010adbc:	00 
c010adbd:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010adc4:	e8 27 60 ff ff       	call   c0100df0 <__panic>
c010adc9:	c7 45 e8 f0 31 1b c0 	movl   $0xc01b31f0,-0x18(%ebp)
c010add0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010add3:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010add6:	8b 15 44 10 1b c0    	mov    0xc01b1044,%edx
c010addc:	83 c2 58             	add    $0x58,%edx
c010addf:	39 d0                	cmp    %edx,%eax
c010ade1:	74 24                	je     c010ae07 <init_main+0x136>
c010ade3:	c7 44 24 0c bc e8 10 	movl   $0xc010e8bc,0xc(%esp)
c010adea:	c0 
c010adeb:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010adf2:	c0 
c010adf3:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
c010adfa:	00 
c010adfb:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010ae02:	e8 e9 5f ff ff       	call   c0100df0 <__panic>
c010ae07:	c7 45 e4 f0 31 1b c0 	movl   $0xc01b31f0,-0x1c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c010ae0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ae11:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010ae13:	8b 15 44 10 1b c0    	mov    0xc01b1044,%edx
c010ae19:	83 c2 58             	add    $0x58,%edx
c010ae1c:	39 d0                	cmp    %edx,%eax
c010ae1e:	74 24                	je     c010ae44 <init_main+0x173>
c010ae20:	c7 44 24 0c ec e8 10 	movl   $0xc010e8ec,0xc(%esp)
c010ae27:	c0 
c010ae28:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010ae2f:	c0 
c010ae30:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
c010ae37:	00 
c010ae38:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010ae3f:	e8 ac 5f ff ff       	call   c0100df0 <__panic>

    cprintf("init check memory pass.\n");
c010ae44:	c7 04 24 1c e9 10 c0 	movl   $0xc010e91c,(%esp)
c010ae4b:	e8 14 55 ff ff       	call   c0100364 <cprintf>
    return 0;
c010ae50:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ae55:	c9                   	leave  
c010ae56:	c3                   	ret    

c010ae57 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010ae57:	55                   	push   %ebp
c010ae58:	89 e5                	mov    %esp,%ebp
c010ae5a:	83 ec 28             	sub    $0x28,%esp
c010ae5d:	c7 45 ec f0 31 1b c0 	movl   $0xc01b31f0,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010ae64:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ae67:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ae6a:	89 50 04             	mov    %edx,0x4(%eax)
c010ae6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ae70:	8b 50 04             	mov    0x4(%eax),%edx
c010ae73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ae76:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ae78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010ae7f:	eb 26                	jmp    c010aea7 <proc_init+0x50>
        list_init(hash_list + i);
c010ae81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae84:	c1 e0 03             	shl    $0x3,%eax
c010ae87:	05 60 10 1b c0       	add    $0xc01b1060,%eax
c010ae8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ae8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae92:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ae95:	89 50 04             	mov    %edx,0x4(%eax)
c010ae98:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae9b:	8b 50 04             	mov    0x4(%eax),%edx
c010ae9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aea1:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010aea3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010aea7:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010aeae:	7e d1                	jle    c010ae81 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010aeb0:	e8 96 e7 ff ff       	call   c010964b <alloc_proc>
c010aeb5:	a3 40 10 1b c0       	mov    %eax,0xc01b1040
c010aeba:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010aebf:	85 c0                	test   %eax,%eax
c010aec1:	75 1c                	jne    c010aedf <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010aec3:	c7 44 24 08 35 e9 10 	movl   $0xc010e935,0x8(%esp)
c010aeca:	c0 
c010aecb:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
c010aed2:	00 
c010aed3:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010aeda:	e8 11 5f ff ff       	call   c0100df0 <__panic>
    }

    idleproc->pid = 0;
c010aedf:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010aee4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010aeeb:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010aef0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010aef6:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010aefb:	ba 00 a0 12 c0       	mov    $0xc012a000,%edx
c010af00:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010af03:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010af08:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010af0f:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010af14:	c7 44 24 04 4d e9 10 	movl   $0xc010e94d,0x4(%esp)
c010af1b:	c0 
c010af1c:	89 04 24             	mov    %eax,(%esp)
c010af1f:	e8 97 e8 ff ff       	call   c01097bb <set_proc_name>
    nr_process ++;
c010af24:	a1 60 30 1b c0       	mov    0xc01b3060,%eax
c010af29:	83 c0 01             	add    $0x1,%eax
c010af2c:	a3 60 30 1b c0       	mov    %eax,0xc01b3060

    current = idleproc;
c010af31:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010af36:	a3 48 10 1b c0       	mov    %eax,0xc01b1048

    int pid = kernel_thread(init_main, NULL, 0);
c010af3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010af42:	00 
c010af43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010af4a:	00 
c010af4b:	c7 04 24 d1 ac 10 c0 	movl   $0xc010acd1,(%esp)
c010af52:	e8 b7 ec ff ff       	call   c0109c0e <kernel_thread>
c010af57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010af5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010af5e:	7f 1c                	jg     c010af7c <proc_init+0x125>
        panic("create init_main failed.\n");
c010af60:	c7 44 24 08 52 e9 10 	movl   $0xc010e952,0x8(%esp)
c010af67:	c0 
c010af68:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
c010af6f:	00 
c010af70:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010af77:	e8 74 5e ff ff       	call   c0100df0 <__panic>
    }

    initproc = find_proc(pid);
c010af7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010af7f:	89 04 24             	mov    %eax,(%esp)
c010af82:	e8 15 ec ff ff       	call   c0109b9c <find_proc>
c010af87:	a3 44 10 1b c0       	mov    %eax,0xc01b1044
    set_proc_name(initproc, "init");
c010af8c:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010af91:	c7 44 24 04 6c e9 10 	movl   $0xc010e96c,0x4(%esp)
c010af98:	c0 
c010af99:	89 04 24             	mov    %eax,(%esp)
c010af9c:	e8 1a e8 ff ff       	call   c01097bb <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010afa1:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010afa6:	85 c0                	test   %eax,%eax
c010afa8:	74 0c                	je     c010afb6 <proc_init+0x15f>
c010afaa:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010afaf:	8b 40 04             	mov    0x4(%eax),%eax
c010afb2:	85 c0                	test   %eax,%eax
c010afb4:	74 24                	je     c010afda <proc_init+0x183>
c010afb6:	c7 44 24 0c 74 e9 10 	movl   $0xc010e974,0xc(%esp)
c010afbd:	c0 
c010afbe:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010afc5:	c0 
c010afc6:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
c010afcd:	00 
c010afce:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010afd5:	e8 16 5e ff ff       	call   c0100df0 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010afda:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010afdf:	85 c0                	test   %eax,%eax
c010afe1:	74 0d                	je     c010aff0 <proc_init+0x199>
c010afe3:	a1 44 10 1b c0       	mov    0xc01b1044,%eax
c010afe8:	8b 40 04             	mov    0x4(%eax),%eax
c010afeb:	83 f8 01             	cmp    $0x1,%eax
c010afee:	74 24                	je     c010b014 <proc_init+0x1bd>
c010aff0:	c7 44 24 0c 9c e9 10 	movl   $0xc010e99c,0xc(%esp)
c010aff7:	c0 
c010aff8:	c7 44 24 08 dd e5 10 	movl   $0xc010e5dd,0x8(%esp)
c010afff:	c0 
c010b000:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
c010b007:	00 
c010b008:	c7 04 24 b0 e5 10 c0 	movl   $0xc010e5b0,(%esp)
c010b00f:	e8 dc 5d ff ff       	call   c0100df0 <__panic>
}
c010b014:	c9                   	leave  
c010b015:	c3                   	ret    

c010b016 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010b016:	55                   	push   %ebp
c010b017:	89 e5                	mov    %esp,%ebp
c010b019:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010b01c:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b021:	8b 40 10             	mov    0x10(%eax),%eax
c010b024:	85 c0                	test   %eax,%eax
c010b026:	74 07                	je     c010b02f <cpu_idle+0x19>
            schedule();
c010b028:	e8 b8 05 00 00       	call   c010b5e5 <schedule>
        }
    }
c010b02d:	eb ed                	jmp    c010b01c <cpu_idle+0x6>
c010b02f:	eb eb                	jmp    c010b01c <cpu_idle+0x6>

c010b031 <lab6_set_priority>:
}

//FOR LAB6, set the process's priority (bigger value will get more CPU time) 
void
lab6_set_priority(uint32_t priority)
{
c010b031:	55                   	push   %ebp
c010b032:	89 e5                	mov    %esp,%ebp
    if (priority == 0)
c010b034:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b038:	75 11                	jne    c010b04b <lab6_set_priority+0x1a>
        current->lab6_priority = 1;
c010b03a:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b03f:	c7 80 9c 00 00 00 01 	movl   $0x1,0x9c(%eax)
c010b046:	00 00 00 
c010b049:	eb 0e                	jmp    c010b059 <lab6_set_priority+0x28>
    else current->lab6_priority = priority;
c010b04b:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b050:	8b 55 08             	mov    0x8(%ebp),%edx
c010b053:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
	//lab6 challenge
    /*current->fair_priority = 60 / current->lab6_priority + 1;	//
    if (current->fair_priority < 1)
        current->fair_priority = 1;		//设置此进程成员变量 need_resched 标识为 1，进程需要调度
*/
}
c010b059:	5d                   	pop    %ebp
c010b05a:	c3                   	ret    

c010b05b <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010b05b:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010b05f:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010b061:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010b064:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010b067:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010b06a:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010b06d:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010b070:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010b073:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010b076:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010b07a:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010b07d:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010b080:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010b083:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010b086:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010b089:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010b08c:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010b08f:	ff 30                	pushl  (%eax)

    ret
c010b091:	c3                   	ret    

c010b092 <skew_heap_merge>:
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
                compare_f comp)
{
c010b092:	55                   	push   %ebp
c010b093:	89 e5                	mov    %esp,%ebp
c010b095:	83 ec 28             	sub    $0x28,%esp
     if (a == NULL) return b;
c010b098:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b09c:	75 08                	jne    c010b0a6 <skew_heap_merge+0x14>
c010b09e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0a1:	e9 bd 00 00 00       	jmp    c010b163 <skew_heap_merge+0xd1>
     else if (b == NULL) return a;
c010b0a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b0aa:	75 08                	jne    c010b0b4 <skew_heap_merge+0x22>
c010b0ac:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0af:	e9 af 00 00 00       	jmp    c010b163 <skew_heap_merge+0xd1>
     
     skew_heap_entry_t *l, *r;
     if (comp(a, b) == -1)
c010b0b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b0bb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0be:	89 04 24             	mov    %eax,(%esp)
c010b0c1:	8b 45 10             	mov    0x10(%ebp),%eax
c010b0c4:	ff d0                	call   *%eax
c010b0c6:	83 f8 ff             	cmp    $0xffffffff,%eax
c010b0c9:	75 4d                	jne    c010b118 <skew_heap_merge+0x86>
     {
          r = a->left;
c010b0cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ce:	8b 40 04             	mov    0x4(%eax),%eax
c010b0d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
          l = skew_heap_merge(a->right, b, comp);
c010b0d4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0d7:	8b 40 08             	mov    0x8(%eax),%eax
c010b0da:	8b 55 10             	mov    0x10(%ebp),%edx
c010b0dd:	89 54 24 08          	mov    %edx,0x8(%esp)
c010b0e1:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b0e4:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b0e8:	89 04 24             	mov    %eax,(%esp)
c010b0eb:	e8 a2 ff ff ff       	call   c010b092 <skew_heap_merge>
c010b0f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
          
          a->left = l;
c010b0f3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b0f9:	89 50 04             	mov    %edx,0x4(%eax)
          a->right = r;
c010b0fc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b102:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = a;
c010b105:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b109:	74 08                	je     c010b113 <skew_heap_merge+0x81>
c010b10b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b10e:	8b 55 08             	mov    0x8(%ebp),%edx
c010b111:	89 10                	mov    %edx,(%eax)

          return a;
c010b113:	8b 45 08             	mov    0x8(%ebp),%eax
c010b116:	eb 4b                	jmp    c010b163 <skew_heap_merge+0xd1>
     }
     else
     {
          r = b->left;
c010b118:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b11b:	8b 40 04             	mov    0x4(%eax),%eax
c010b11e:	89 45 f4             	mov    %eax,-0xc(%ebp)
          l = skew_heap_merge(a, b->right, comp);
c010b121:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b124:	8b 40 08             	mov    0x8(%eax),%eax
c010b127:	8b 55 10             	mov    0x10(%ebp),%edx
c010b12a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010b12e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b132:	8b 45 08             	mov    0x8(%ebp),%eax
c010b135:	89 04 24             	mov    %eax,(%esp)
c010b138:	e8 55 ff ff ff       	call   c010b092 <skew_heap_merge>
c010b13d:	89 45 f0             	mov    %eax,-0x10(%ebp)
          
          b->left = l;
c010b140:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b143:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b146:	89 50 04             	mov    %edx,0x4(%eax)
          b->right = r;
c010b149:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b14c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b14f:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = b;
c010b152:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b156:	74 08                	je     c010b160 <skew_heap_merge+0xce>
c010b158:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b15b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b15e:	89 10                	mov    %edx,(%eax)

          return b;
c010b160:	8b 45 0c             	mov    0xc(%ebp),%eax
     }
}
c010b163:	c9                   	leave  
c010b164:	c3                   	ret    

c010b165 <proc_stride_comp_f>:

/* The compare function for two skew_heap_node_t's and the
 * corresponding procs*/
static int
proc_stride_comp_f(void *a, void *b)
{
c010b165:	55                   	push   %ebp
c010b166:	89 e5                	mov    %esp,%ebp
c010b168:	83 ec 10             	sub    $0x10,%esp
     struct proc_struct *p = le2proc(a, lab6_run_pool);
c010b16b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b16e:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b173:	89 45 fc             	mov    %eax,-0x4(%ebp)
     struct proc_struct *q = le2proc(b, lab6_run_pool);
c010b176:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b179:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b17e:	89 45 f8             	mov    %eax,-0x8(%ebp)
     int32_t c = p->lab6_stride - q->lab6_stride;
c010b181:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b184:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
c010b18a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b18d:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
c010b193:	29 c2                	sub    %eax,%edx
c010b195:	89 d0                	mov    %edx,%eax
c010b197:	89 45 f4             	mov    %eax,-0xc(%ebp)
     if (c > 0) return 1;
c010b19a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b19e:	7e 07                	jle    c010b1a7 <proc_stride_comp_f+0x42>
c010b1a0:	b8 01 00 00 00       	mov    $0x1,%eax
c010b1a5:	eb 12                	jmp    c010b1b9 <proc_stride_comp_f+0x54>
     else if (c == 0) return 0;
c010b1a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b1ab:	75 07                	jne    c010b1b4 <proc_stride_comp_f+0x4f>
c010b1ad:	b8 00 00 00 00       	mov    $0x0,%eax
c010b1b2:	eb 05                	jmp    c010b1b9 <proc_stride_comp_f+0x54>
     else return -1;
c010b1b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c010b1b9:	c9                   	leave  
c010b1ba:	c3                   	ret    

c010b1bb <stride_init>:
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
stride_init(struct run_queue *rq) {
c010b1bb:	55                   	push   %ebp
c010b1bc:	89 e5                	mov    %esp,%ebp
c010b1be:	83 ec 10             	sub    $0x10,%esp
     /* LAB6: YOUR CODE 
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0       
      */
     list_init(&(rq->run_list));
c010b1c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010b1c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b1ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b1cd:	89 50 04             	mov    %edx,0x4(%eax)
c010b1d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b1d3:	8b 50 04             	mov    0x4(%eax),%edx
c010b1d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b1d9:	89 10                	mov    %edx,(%eax)
     rq->lab6_run_pool = NULL;
c010b1db:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1de:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
     rq->proc_num = 0;
c010b1e5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1e8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
c010b1ef:	c9                   	leave  
c010b1f0:	c3                   	ret    

c010b1f1 <stride_enqueue>:
 * 
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
c010b1f1:	55                   	push   %ebp
c010b1f2:	89 e5                	mov    %esp,%ebp
c010b1f4:	83 ec 28             	sub    $0x28,%esp
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
#if USE_SKEW_HEAP
     rq->lab6_run_pool =
          skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
c010b1f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b1fa:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b200:	8b 45 08             	mov    0x8(%ebp),%eax
c010b203:	8b 40 10             	mov    0x10(%eax),%eax
c010b206:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b209:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b20c:	c7 45 ec 65 b1 10 c0 	movl   $0xc010b165,-0x14(%ebp)
c010b213:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b216:	89 45 e8             	mov    %eax,-0x18(%ebp)
     compare_f comp) __attribute__((always_inline));

static inline void
skew_heap_init(skew_heap_entry_t *a)
{
     a->left = a->right = a->parent = NULL;
c010b219:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b21c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010b222:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b225:	8b 10                	mov    (%eax),%edx
c010b227:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b22a:	89 50 08             	mov    %edx,0x8(%eax)
c010b22d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b230:	8b 50 08             	mov    0x8(%eax),%edx
c010b233:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b236:	89 50 04             	mov    %edx,0x4(%eax)
static inline skew_heap_entry_t *
skew_heap_insert(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_init(b);
     return skew_heap_merge(a, b, comp);
c010b239:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b23c:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b240:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b243:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b247:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b24a:	89 04 24             	mov    %eax,(%esp)
c010b24d:	e8 40 fe ff ff       	call   c010b092 <skew_heap_merge>
c010b252:	89 c2                	mov    %eax,%edx
      * (2) recalculate proc->time_slice
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
#if USE_SKEW_HEAP
     rq->lab6_run_pool =
c010b254:	8b 45 08             	mov    0x8(%ebp),%eax
c010b257:	89 50 10             	mov    %edx,0x10(%eax)
          skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
#else
     assert(list_empty(&(proc->run_link)));
     list_add_before(&(rq->run_list), &(proc->run_link));
#endif
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
c010b25a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b25d:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b263:	85 c0                	test   %eax,%eax
c010b265:	74 13                	je     c010b27a <stride_enqueue+0x89>
c010b267:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b26a:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
c010b270:	8b 45 08             	mov    0x8(%ebp),%eax
c010b273:	8b 40 0c             	mov    0xc(%eax),%eax
c010b276:	39 c2                	cmp    %eax,%edx
c010b278:	7e 0f                	jle    c010b289 <stride_enqueue+0x98>
          proc->time_slice = rq->max_time_slice;
c010b27a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b27d:	8b 50 0c             	mov    0xc(%eax),%edx
c010b280:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b283:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
     }
     proc->rq = rq;
c010b289:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b28c:	8b 55 08             	mov    0x8(%ebp),%edx
c010b28f:	89 50 7c             	mov    %edx,0x7c(%eax)
     rq->proc_num ++;
c010b292:	8b 45 08             	mov    0x8(%ebp),%eax
c010b295:	8b 40 08             	mov    0x8(%eax),%eax
c010b298:	8d 50 01             	lea    0x1(%eax),%edx
c010b29b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b29e:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b2a1:	c9                   	leave  
c010b2a2:	c3                   	ret    

c010b2a3 <stride_dequeue>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
c010b2a3:	55                   	push   %ebp
c010b2a4:	89 e5                	mov    %esp,%ebp
c010b2a6:	83 ec 38             	sub    $0x38,%esp
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
#if USE_SKEW_HEAP
     rq->lab6_run_pool =
          skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
c010b2a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2ac:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b2b2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2b5:	8b 40 10             	mov    0x10(%eax),%eax
c010b2b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b2bb:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b2be:	c7 45 ec 65 b1 10 c0 	movl   $0xc010b165,-0x14(%ebp)

static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
c010b2c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2c8:	8b 00                	mov    (%eax),%eax
c010b2ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
c010b2cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2d0:	8b 50 08             	mov    0x8(%eax),%edx
c010b2d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2d6:	8b 40 04             	mov    0x4(%eax),%eax
c010b2d9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b2dc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010b2e0:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b2e4:	89 04 24             	mov    %eax,(%esp)
c010b2e7:	e8 a6 fd ff ff       	call   c010b092 <skew_heap_merge>
c010b2ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     if (rep) rep->parent = p;
c010b2ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b2f3:	74 08                	je     c010b2fd <stride_dequeue+0x5a>
c010b2f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b2f8:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b2fb:	89 10                	mov    %edx,(%eax)
     
     if (p)
c010b2fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b301:	74 24                	je     c010b327 <stride_dequeue+0x84>
     {
          if (p->left == b)
c010b303:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b306:	8b 40 04             	mov    0x4(%eax),%eax
c010b309:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b30c:	75 0b                	jne    c010b319 <stride_dequeue+0x76>
               p->left = rep;
c010b30e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b311:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b314:	89 50 04             	mov    %edx,0x4(%eax)
c010b317:	eb 09                	jmp    c010b322 <stride_dequeue+0x7f>
          else p->right = rep;
c010b319:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b31c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b31f:	89 50 08             	mov    %edx,0x8(%eax)
          return a;
c010b322:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b325:	eb 03                	jmp    c010b32a <stride_dequeue+0x87>
     }
     else return rep;
c010b327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b32a:	89 c2                	mov    %eax,%edx
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
#if USE_SKEW_HEAP
     rq->lab6_run_pool =
c010b32c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b32f:	89 50 10             	mov    %edx,0x10(%eax)
          skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
#else
     assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
     list_del_init(&(proc->run_link));
#endif
     rq->proc_num --;
c010b332:	8b 45 08             	mov    0x8(%ebp),%eax
c010b335:	8b 40 08             	mov    0x8(%eax),%eax
c010b338:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b33b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b33e:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b341:	c9                   	leave  
c010b342:	c3                   	ret    

c010b343 <stride_pick_next>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static struct proc_struct *
stride_pick_next(struct run_queue *rq) {
c010b343:	55                   	push   %ebp
c010b344:	89 e5                	mov    %esp,%ebp
c010b346:	53                   	push   %ebx
c010b347:	83 ec 10             	sub    $0x10,%esp
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
#if USE_SKEW_HEAP
     if (rq->lab6_run_pool == NULL) return NULL;
c010b34a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b34d:	8b 40 10             	mov    0x10(%eax),%eax
c010b350:	85 c0                	test   %eax,%eax
c010b352:	75 07                	jne    c010b35b <stride_pick_next+0x18>
c010b354:	b8 00 00 00 00       	mov    $0x0,%eax
c010b359:	eb 62                	jmp    c010b3bd <stride_pick_next+0x7a>
     struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
c010b35b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b35e:	8b 40 10             	mov    0x10(%eax),%eax
c010b361:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b366:	89 45 f8             	mov    %eax,-0x8(%ebp)
          if ((int32_t)(p->lab6_stride - q->lab6_stride) > 0)
               p = q;
          le = list_next(le);
     }
#endif
     if (p->lab6_priority == 0)
c010b369:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b36c:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
c010b372:	85 c0                	test   %eax,%eax
c010b374:	75 1a                	jne    c010b390 <stride_pick_next+0x4d>
          p->lab6_stride += BIG_STRIDE;
c010b376:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b379:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
c010b37f:	8d 90 ff ff ff 7f    	lea    0x7fffffff(%eax),%edx
c010b385:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b388:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
c010b38e:	eb 2a                	jmp    c010b3ba <stride_pick_next+0x77>
     else p->lab6_stride += BIG_STRIDE / p->lab6_priority;
c010b390:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b393:	8b 88 98 00 00 00    	mov    0x98(%eax),%ecx
c010b399:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b39c:	8b 98 9c 00 00 00    	mov    0x9c(%eax),%ebx
c010b3a2:	b8 ff ff ff 7f       	mov    $0x7fffffff,%eax
c010b3a7:	ba 00 00 00 00       	mov    $0x0,%edx
c010b3ac:	f7 f3                	div    %ebx
c010b3ae:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010b3b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b3b4:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
     return p;
c010b3ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b3bd:	83 c4 10             	add    $0x10,%esp
c010b3c0:	5b                   	pop    %ebx
c010b3c1:	5d                   	pop    %ebp
c010b3c2:	c3                   	ret    

c010b3c3 <stride_proc_tick>:
 * denotes the time slices left for current
 * process. proc->need_resched is the flag variable for process
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
c010b3c3:	55                   	push   %ebp
c010b3c4:	89 e5                	mov    %esp,%ebp
     /* LAB6: YOUR CODE */
     if (proc->time_slice > 0) {
c010b3c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3c9:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b3cf:	85 c0                	test   %eax,%eax
c010b3d1:	7e 15                	jle    c010b3e8 <stride_proc_tick+0x25>
          proc->time_slice --;
c010b3d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3d6:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b3dc:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b3df:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3e2:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
     }
     if (proc->time_slice == 0) {
c010b3e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3eb:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b3f1:	85 c0                	test   %eax,%eax
c010b3f3:	75 0a                	jne    c010b3ff <stride_proc_tick+0x3c>
          proc->need_resched = 1;
c010b3f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3f8:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
     }
}
c010b3ff:	5d                   	pop    %ebp
c010b400:	c3                   	ret    

c010b401 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010b401:	55                   	push   %ebp
c010b402:	89 e5                	mov    %esp,%ebp
c010b404:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010b407:	9c                   	pushf  
c010b408:	58                   	pop    %eax
c010b409:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010b40c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010b40f:	25 00 02 00 00       	and    $0x200,%eax
c010b414:	85 c0                	test   %eax,%eax
c010b416:	74 0c                	je     c010b424 <__intr_save+0x23>
        intr_disable();
c010b418:	e8 3c 6c ff ff       	call   c0102059 <intr_disable>
        return 1;
c010b41d:	b8 01 00 00 00       	mov    $0x1,%eax
c010b422:	eb 05                	jmp    c010b429 <__intr_save+0x28>
    }
    return 0;
c010b424:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b429:	c9                   	leave  
c010b42a:	c3                   	ret    

c010b42b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010b42b:	55                   	push   %ebp
c010b42c:	89 e5                	mov    %esp,%ebp
c010b42e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010b431:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b435:	74 05                	je     c010b43c <__intr_restore+0x11>
        intr_enable();
c010b437:	e8 17 6c ff ff       	call   c0102053 <intr_enable>
    }
}
c010b43c:	c9                   	leave  
c010b43d:	c3                   	ret    

c010b43e <sched_class_enqueue>:
static struct sched_class *sched_class;

static struct run_queue *rq;

static inline void
sched_class_enqueue(struct proc_struct *proc) {
c010b43e:	55                   	push   %ebp
c010b43f:	89 e5                	mov    %esp,%ebp
c010b441:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010b444:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010b449:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b44c:	74 1a                	je     c010b468 <sched_class_enqueue+0x2a>
        sched_class->enqueue(rq, proc);
c010b44e:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010b453:	8b 40 08             	mov    0x8(%eax),%eax
c010b456:	8b 15 80 30 1b c0    	mov    0xc01b3080,%edx
c010b45c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b45f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b463:	89 14 24             	mov    %edx,(%esp)
c010b466:	ff d0                	call   *%eax
    }
}
c010b468:	c9                   	leave  
c010b469:	c3                   	ret    

c010b46a <sched_class_dequeue>:

static inline void
sched_class_dequeue(struct proc_struct *proc) {
c010b46a:	55                   	push   %ebp
c010b46b:	89 e5                	mov    %esp,%ebp
c010b46d:	83 ec 18             	sub    $0x18,%esp
    sched_class->dequeue(rq, proc);
c010b470:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010b475:	8b 40 0c             	mov    0xc(%eax),%eax
c010b478:	8b 15 80 30 1b c0    	mov    0xc01b3080,%edx
c010b47e:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b481:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b485:	89 14 24             	mov    %edx,(%esp)
c010b488:	ff d0                	call   *%eax
}
c010b48a:	c9                   	leave  
c010b48b:	c3                   	ret    

c010b48c <sched_class_pick_next>:

static inline struct proc_struct *
sched_class_pick_next(void) {
c010b48c:	55                   	push   %ebp
c010b48d:	89 e5                	mov    %esp,%ebp
c010b48f:	83 ec 18             	sub    $0x18,%esp
    return sched_class->pick_next(rq);
c010b492:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010b497:	8b 40 10             	mov    0x10(%eax),%eax
c010b49a:	8b 15 80 30 1b c0    	mov    0xc01b3080,%edx
c010b4a0:	89 14 24             	mov    %edx,(%esp)
c010b4a3:	ff d0                	call   *%eax
}
c010b4a5:	c9                   	leave  
c010b4a6:	c3                   	ret    

c010b4a7 <sched_class_proc_tick>:

void
sched_class_proc_tick(struct proc_struct *proc) {
c010b4a7:	55                   	push   %ebp
c010b4a8:	89 e5                	mov    %esp,%ebp
c010b4aa:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010b4ad:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010b4b2:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b4b5:	74 1c                	je     c010b4d3 <sched_class_proc_tick+0x2c>
        sched_class->proc_tick(rq, proc);
c010b4b7:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010b4bc:	8b 40 14             	mov    0x14(%eax),%eax
c010b4bf:	8b 15 80 30 1b c0    	mov    0xc01b3080,%edx
c010b4c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b4c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b4cc:	89 14 24             	mov    %edx,(%esp)
c010b4cf:	ff d0                	call   *%eax
c010b4d1:	eb 0a                	jmp    c010b4dd <sched_class_proc_tick+0x36>
    }
    else {
        proc->need_resched = 1;
c010b4d3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4d6:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    }
}
c010b4dd:	c9                   	leave  
c010b4de:	c3                   	ret    

c010b4df <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
c010b4df:	55                   	push   %ebp
c010b4e0:	89 e5                	mov    %esp,%ebp
c010b4e2:	83 ec 28             	sub    $0x28,%esp
c010b4e5:	c7 45 f4 74 30 1b c0 	movl   $0xc01b3074,-0xc(%ebp)
c010b4ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b4f2:	89 50 04             	mov    %edx,0x4(%eax)
c010b4f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4f8:	8b 50 04             	mov    0x4(%eax),%edx
c010b4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4fe:	89 10                	mov    %edx,(%eax)
    list_init(&timer_list);

    sched_class = &default_sched_class;
c010b500:	c7 05 7c 30 1b c0 88 	movl   $0xc012ca88,0xc01b307c
c010b507:	ca 12 c0 

    rq = &__rq;
c010b50a:	c7 05 80 30 1b c0 84 	movl   $0xc01b3084,0xc01b3080
c010b511:	30 1b c0 
    rq->max_time_slice = MAX_TIME_SLICE;
c010b514:	a1 80 30 1b c0       	mov    0xc01b3080,%eax
c010b519:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
    sched_class->init(rq);
c010b520:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010b525:	8b 40 04             	mov    0x4(%eax),%eax
c010b528:	8b 15 80 30 1b c0    	mov    0xc01b3080,%edx
c010b52e:	89 14 24             	mov    %edx,(%esp)
c010b531:	ff d0                	call   *%eax

    cprintf("sched class: %s\n", sched_class->name);
c010b533:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010b538:	8b 00                	mov    (%eax),%eax
c010b53a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b53e:	c7 04 24 d4 e9 10 c0 	movl   $0xc010e9d4,(%esp)
c010b545:	e8 1a 4e ff ff       	call   c0100364 <cprintf>
}
c010b54a:	c9                   	leave  
c010b54b:	c3                   	ret    

c010b54c <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
c010b54c:	55                   	push   %ebp
c010b54d:	89 e5                	mov    %esp,%ebp
c010b54f:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b552:	8b 45 08             	mov    0x8(%ebp),%eax
c010b555:	8b 00                	mov    (%eax),%eax
c010b557:	83 f8 03             	cmp    $0x3,%eax
c010b55a:	75 24                	jne    c010b580 <wakeup_proc+0x34>
c010b55c:	c7 44 24 0c e5 e9 10 	movl   $0xc010e9e5,0xc(%esp)
c010b563:	c0 
c010b564:	c7 44 24 08 00 ea 10 	movl   $0xc010ea00,0x8(%esp)
c010b56b:	c0 
c010b56c:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
c010b573:	00 
c010b574:	c7 04 24 15 ea 10 c0 	movl   $0xc010ea15,(%esp)
c010b57b:	e8 70 58 ff ff       	call   c0100df0 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b580:	e8 7c fe ff ff       	call   c010b401 <__intr_save>
c010b585:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b588:	8b 45 08             	mov    0x8(%ebp),%eax
c010b58b:	8b 00                	mov    (%eax),%eax
c010b58d:	83 f8 02             	cmp    $0x2,%eax
c010b590:	74 2a                	je     c010b5bc <wakeup_proc+0x70>
            proc->state = PROC_RUNNABLE;
c010b592:	8b 45 08             	mov    0x8(%ebp),%eax
c010b595:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b59b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b59e:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
            if (proc != current) {
c010b5a5:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b5aa:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b5ad:	74 29                	je     c010b5d8 <wakeup_proc+0x8c>
                sched_class_enqueue(proc);
c010b5af:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5b2:	89 04 24             	mov    %eax,(%esp)
c010b5b5:	e8 84 fe ff ff       	call   c010b43e <sched_class_enqueue>
c010b5ba:	eb 1c                	jmp    c010b5d8 <wakeup_proc+0x8c>
            }
        }
        else {
            warn("wakeup runnable process.\n");
c010b5bc:	c7 44 24 08 2b ea 10 	movl   $0xc010ea2b,0x8(%esp)
c010b5c3:	c0 
c010b5c4:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c010b5cb:	00 
c010b5cc:	c7 04 24 15 ea 10 c0 	movl   $0xc010ea15,(%esp)
c010b5d3:	e8 95 58 ff ff       	call   c0100e6d <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b5d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5db:	89 04 24             	mov    %eax,(%esp)
c010b5de:	e8 48 fe ff ff       	call   c010b42b <__intr_restore>
}
c010b5e3:	c9                   	leave  
c010b5e4:	c3                   	ret    

c010b5e5 <schedule>:

void
schedule(void) {
c010b5e5:	55                   	push   %ebp
c010b5e6:	89 e5                	mov    %esp,%ebp
c010b5e8:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
c010b5eb:	e8 11 fe ff ff       	call   c010b401 <__intr_save>
c010b5f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        current->need_resched = 0;
c010b5f3:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b5f8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        if (current->state == PROC_RUNNABLE) {
c010b5ff:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b604:	8b 00                	mov    (%eax),%eax
c010b606:	83 f8 02             	cmp    $0x2,%eax
c010b609:	75 0d                	jne    c010b618 <schedule+0x33>
            sched_class_enqueue(current);
c010b60b:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b610:	89 04 24             	mov    %eax,(%esp)
c010b613:	e8 26 fe ff ff       	call   c010b43e <sched_class_enqueue>
        }
        if ((next = sched_class_pick_next()) != NULL) {
c010b618:	e8 6f fe ff ff       	call   c010b48c <sched_class_pick_next>
c010b61d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b620:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b624:	74 0b                	je     c010b631 <schedule+0x4c>
            sched_class_dequeue(next);
c010b626:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b629:	89 04 24             	mov    %eax,(%esp)
c010b62c:	e8 39 fe ff ff       	call   c010b46a <sched_class_dequeue>
        }
        if (next == NULL) {
c010b631:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b635:	75 08                	jne    c010b63f <schedule+0x5a>
            next = idleproc;
c010b637:	a1 40 10 1b c0       	mov    0xc01b1040,%eax
c010b63c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        next->runs ++;
c010b63f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b642:	8b 40 08             	mov    0x8(%eax),%eax
c010b645:	8d 50 01             	lea    0x1(%eax),%edx
c010b648:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b64b:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b64e:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b653:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010b656:	74 0b                	je     c010b663 <schedule+0x7e>
            proc_run(next);
c010b658:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b65b:	89 04 24             	mov    %eax,(%esp)
c010b65e:	e8 fd e3 ff ff       	call   c0109a60 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b663:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b666:	89 04 24             	mov    %eax,(%esp)
c010b669:	e8 bd fd ff ff       	call   c010b42b <__intr_restore>
}
c010b66e:	c9                   	leave  
c010b66f:	c3                   	ret    

c010b670 <sys_exit>:
#include <pmm.h>
#include <assert.h>
#include <clock.h>

static int
sys_exit(uint32_t arg[]) {
c010b670:	55                   	push   %ebp
c010b671:	89 e5                	mov    %esp,%ebp
c010b673:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b676:	8b 45 08             	mov    0x8(%ebp),%eax
c010b679:	8b 00                	mov    (%eax),%eax
c010b67b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b67e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b681:	89 04 24             	mov    %eax,(%esp)
c010b684:	e8 3b ea ff ff       	call   c010a0c4 <do_exit>
}
c010b689:	c9                   	leave  
c010b68a:	c3                   	ret    

c010b68b <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b68b:	55                   	push   %ebp
c010b68c:	89 e5                	mov    %esp,%ebp
c010b68e:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b691:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b696:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b699:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b69c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b69f:	8b 40 44             	mov    0x44(%eax),%eax
c010b6a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b6a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6a8:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b6ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6af:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b6ba:	e8 e4 e8 ff ff       	call   c0109fa3 <do_fork>
}
c010b6bf:	c9                   	leave  
c010b6c0:	c3                   	ret    

c010b6c1 <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b6c1:	55                   	push   %ebp
c010b6c2:	89 e5                	mov    %esp,%ebp
c010b6c4:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b6c7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6ca:	8b 00                	mov    (%eax),%eax
c010b6cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b6cf:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6d2:	83 c0 04             	add    $0x4,%eax
c010b6d5:	8b 00                	mov    (%eax),%eax
c010b6d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b6da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6e4:	89 04 24             	mov    %eax,(%esp)
c010b6e7:	e8 56 f3 ff ff       	call   c010aa42 <do_wait>
}
c010b6ec:	c9                   	leave  
c010b6ed:	c3                   	ret    

c010b6ee <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b6ee:	55                   	push   %ebp
c010b6ef:	89 e5                	mov    %esp,%ebp
c010b6f1:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b6f4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6f7:	8b 00                	mov    (%eax),%eax
c010b6f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b6fc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6ff:	8b 40 04             	mov    0x4(%eax),%eax
c010b702:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b705:	8b 45 08             	mov    0x8(%ebp),%eax
c010b708:	83 c0 08             	add    $0x8,%eax
c010b70b:	8b 00                	mov    (%eax),%eax
c010b70d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b710:	8b 45 08             	mov    0x8(%ebp),%eax
c010b713:	8b 40 0c             	mov    0xc(%eax),%eax
c010b716:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b719:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b71c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b720:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b723:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b727:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b72a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b72e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b731:	89 04 24             	mov    %eax,(%esp)
c010b734:	e8 bd f1 ff ff       	call   c010a8f6 <do_execve>
}
c010b739:	c9                   	leave  
c010b73a:	c3                   	ret    

c010b73b <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b73b:	55                   	push   %ebp
c010b73c:	89 e5                	mov    %esp,%ebp
c010b73e:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b741:	e8 e6 f2 ff ff       	call   c010aa2c <do_yield>
}
c010b746:	c9                   	leave  
c010b747:	c3                   	ret    

c010b748 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b748:	55                   	push   %ebp
c010b749:	89 e5                	mov    %esp,%ebp
c010b74b:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b74e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b751:	8b 00                	mov    (%eax),%eax
c010b753:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b756:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b759:	89 04 24             	mov    %eax,(%esp)
c010b75c:	e8 75 f4 ff ff       	call   c010abd6 <do_kill>
}
c010b761:	c9                   	leave  
c010b762:	c3                   	ret    

c010b763 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b763:	55                   	push   %ebp
c010b764:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b766:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b76b:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b76e:	5d                   	pop    %ebp
c010b76f:	c3                   	ret    

c010b770 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b770:	55                   	push   %ebp
c010b771:	89 e5                	mov    %esp,%ebp
c010b773:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b776:	8b 45 08             	mov    0x8(%ebp),%eax
c010b779:	8b 00                	mov    (%eax),%eax
c010b77b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b77e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b781:	89 04 24             	mov    %eax,(%esp)
c010b784:	e8 01 4c ff ff       	call   c010038a <cputchar>
    return 0;
c010b789:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b78e:	c9                   	leave  
c010b78f:	c3                   	ret    

c010b790 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b790:	55                   	push   %ebp
c010b791:	89 e5                	mov    %esp,%ebp
c010b793:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b796:	e8 0c b5 ff ff       	call   c0106ca7 <print_pgdir>
    return 0;
c010b79b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b7a0:	c9                   	leave  
c010b7a1:	c3                   	ret    

c010b7a2 <sys_gettime>:

static int
sys_gettime(uint32_t arg[]) {
c010b7a2:	55                   	push   %ebp
c010b7a3:	89 e5                	mov    %esp,%ebp
    return (int)ticks;
c010b7a5:	a1 98 30 1b c0       	mov    0xc01b3098,%eax
}
c010b7aa:	5d                   	pop    %ebp
c010b7ab:	c3                   	ret    

c010b7ac <sys_lab6_set_priority>:
static int
sys_lab6_set_priority(uint32_t arg[])
{
c010b7ac:	55                   	push   %ebp
c010b7ad:	89 e5                	mov    %esp,%ebp
c010b7af:	83 ec 28             	sub    $0x28,%esp
    uint32_t priority = (uint32_t)arg[0];
c010b7b2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7b5:	8b 00                	mov    (%eax),%eax
c010b7b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lab6_set_priority(priority);
c010b7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b7bd:	89 04 24             	mov    %eax,(%esp)
c010b7c0:	e8 6c f8 ff ff       	call   c010b031 <lab6_set_priority>
    return 0;
c010b7c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b7ca:	c9                   	leave  
c010b7cb:	c3                   	ret    

c010b7cc <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b7cc:	55                   	push   %ebp
c010b7cd:	89 e5                	mov    %esp,%ebp
c010b7cf:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b7d2:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b7d7:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b7da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b7e0:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b7e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b7e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b7ea:	78 60                	js     c010b84c <syscall+0x80>
c010b7ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7ef:	3d ff 00 00 00       	cmp    $0xff,%eax
c010b7f4:	77 56                	ja     c010b84c <syscall+0x80>
        if (syscalls[num] != NULL) {
c010b7f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7f9:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b800:	85 c0                	test   %eax,%eax
c010b802:	74 48                	je     c010b84c <syscall+0x80>
            arg[0] = tf->tf_regs.reg_edx;
c010b804:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b807:	8b 40 14             	mov    0x14(%eax),%eax
c010b80a:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b810:	8b 40 18             	mov    0x18(%eax),%eax
c010b813:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b816:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b819:	8b 40 10             	mov    0x10(%eax),%eax
c010b81c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b822:	8b 00                	mov    (%eax),%eax
c010b824:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b827:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b82a:	8b 40 04             	mov    0x4(%eax),%eax
c010b82d:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b830:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b833:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b83a:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b83d:	89 14 24             	mov    %edx,(%esp)
c010b840:	ff d0                	call   *%eax
c010b842:	89 c2                	mov    %eax,%edx
c010b844:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b847:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b84a:	eb 46                	jmp    c010b892 <syscall+0xc6>
        }
    }
    print_trapframe(tf);
c010b84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b84f:	89 04 24             	mov    %eax,(%esp)
c010b852:	e8 9a 6b ff ff       	call   c01023f1 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b857:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b85c:	8d 50 48             	lea    0x48(%eax),%edx
c010b85f:	a1 48 10 1b c0       	mov    0xc01b1048,%eax
c010b864:	8b 40 04             	mov    0x4(%eax),%eax
c010b867:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b86b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b86f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b872:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b876:	c7 44 24 08 48 ea 10 	movl   $0xc010ea48,0x8(%esp)
c010b87d:	c0 
c010b87e:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010b885:	00 
c010b886:	c7 04 24 74 ea 10 c0 	movl   $0xc010ea74,(%esp)
c010b88d:	e8 5e 55 ff ff       	call   c0100df0 <__panic>
            num, current->pid, current->name);
}
c010b892:	c9                   	leave  
c010b893:	c3                   	ret    

c010b894 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010b894:	55                   	push   %ebp
c010b895:	89 e5                	mov    %esp,%ebp
c010b897:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010b89a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b89d:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010b8a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010b8a6:	b8 20 00 00 00       	mov    $0x20,%eax
c010b8ab:	2b 45 0c             	sub    0xc(%ebp),%eax
c010b8ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b8b1:	89 c1                	mov    %eax,%ecx
c010b8b3:	d3 ea                	shr    %cl,%edx
c010b8b5:	89 d0                	mov    %edx,%eax
}
c010b8b7:	c9                   	leave  
c010b8b8:	c3                   	ret    

c010b8b9 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b8b9:	55                   	push   %ebp
c010b8ba:	89 e5                	mov    %esp,%ebp
c010b8bc:	83 ec 58             	sub    $0x58,%esp
c010b8bf:	8b 45 10             	mov    0x10(%ebp),%eax
c010b8c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b8c5:	8b 45 14             	mov    0x14(%ebp),%eax
c010b8c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b8cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b8ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b8d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b8d4:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b8d7:	8b 45 18             	mov    0x18(%ebp),%eax
c010b8da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b8dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b8e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b8e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b8e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b8e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b8ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b8ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b8f3:	74 1c                	je     c010b911 <printnum+0x58>
c010b8f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b8f8:	ba 00 00 00 00       	mov    $0x0,%edx
c010b8fd:	f7 75 e4             	divl   -0x1c(%ebp)
c010b900:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b903:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b906:	ba 00 00 00 00       	mov    $0x0,%edx
c010b90b:	f7 75 e4             	divl   -0x1c(%ebp)
c010b90e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b911:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b914:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b917:	f7 75 e4             	divl   -0x1c(%ebp)
c010b91a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b91d:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b920:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b923:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b926:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b929:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b92c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b92f:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b932:	8b 45 18             	mov    0x18(%ebp),%eax
c010b935:	ba 00 00 00 00       	mov    $0x0,%edx
c010b93a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b93d:	77 56                	ja     c010b995 <printnum+0xdc>
c010b93f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b942:	72 05                	jb     c010b949 <printnum+0x90>
c010b944:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010b947:	77 4c                	ja     c010b995 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b949:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b94c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b94f:	8b 45 20             	mov    0x20(%ebp),%eax
c010b952:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b956:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b95a:	8b 45 18             	mov    0x18(%ebp),%eax
c010b95d:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b961:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b964:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b967:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b96b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b96f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b972:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b976:	8b 45 08             	mov    0x8(%ebp),%eax
c010b979:	89 04 24             	mov    %eax,(%esp)
c010b97c:	e8 38 ff ff ff       	call   c010b8b9 <printnum>
c010b981:	eb 1c                	jmp    c010b99f <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b983:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b986:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b98a:	8b 45 20             	mov    0x20(%ebp),%eax
c010b98d:	89 04 24             	mov    %eax,(%esp)
c010b990:	8b 45 08             	mov    0x8(%ebp),%eax
c010b993:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010b995:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010b999:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b99d:	7f e4                	jg     c010b983 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b99f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b9a2:	05 a4 eb 10 c0       	add    $0xc010eba4,%eax
c010b9a7:	0f b6 00             	movzbl (%eax),%eax
c010b9aa:	0f be c0             	movsbl %al,%eax
c010b9ad:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b9b0:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b9b4:	89 04 24             	mov    %eax,(%esp)
c010b9b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9ba:	ff d0                	call   *%eax
}
c010b9bc:	c9                   	leave  
c010b9bd:	c3                   	ret    

c010b9be <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b9be:	55                   	push   %ebp
c010b9bf:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b9c1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b9c5:	7e 14                	jle    c010b9db <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b9c7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9ca:	8b 00                	mov    (%eax),%eax
c010b9cc:	8d 48 08             	lea    0x8(%eax),%ecx
c010b9cf:	8b 55 08             	mov    0x8(%ebp),%edx
c010b9d2:	89 0a                	mov    %ecx,(%edx)
c010b9d4:	8b 50 04             	mov    0x4(%eax),%edx
c010b9d7:	8b 00                	mov    (%eax),%eax
c010b9d9:	eb 30                	jmp    c010ba0b <getuint+0x4d>
    }
    else if (lflag) {
c010b9db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b9df:	74 16                	je     c010b9f7 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b9e1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9e4:	8b 00                	mov    (%eax),%eax
c010b9e6:	8d 48 04             	lea    0x4(%eax),%ecx
c010b9e9:	8b 55 08             	mov    0x8(%ebp),%edx
c010b9ec:	89 0a                	mov    %ecx,(%edx)
c010b9ee:	8b 00                	mov    (%eax),%eax
c010b9f0:	ba 00 00 00 00       	mov    $0x0,%edx
c010b9f5:	eb 14                	jmp    c010ba0b <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b9f7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9fa:	8b 00                	mov    (%eax),%eax
c010b9fc:	8d 48 04             	lea    0x4(%eax),%ecx
c010b9ff:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba02:	89 0a                	mov    %ecx,(%edx)
c010ba04:	8b 00                	mov    (%eax),%eax
c010ba06:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010ba0b:	5d                   	pop    %ebp
c010ba0c:	c3                   	ret    

c010ba0d <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010ba0d:	55                   	push   %ebp
c010ba0e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010ba10:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010ba14:	7e 14                	jle    c010ba2a <getint+0x1d>
        return va_arg(*ap, long long);
c010ba16:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba19:	8b 00                	mov    (%eax),%eax
c010ba1b:	8d 48 08             	lea    0x8(%eax),%ecx
c010ba1e:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba21:	89 0a                	mov    %ecx,(%edx)
c010ba23:	8b 50 04             	mov    0x4(%eax),%edx
c010ba26:	8b 00                	mov    (%eax),%eax
c010ba28:	eb 28                	jmp    c010ba52 <getint+0x45>
    }
    else if (lflag) {
c010ba2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ba2e:	74 12                	je     c010ba42 <getint+0x35>
        return va_arg(*ap, long);
c010ba30:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba33:	8b 00                	mov    (%eax),%eax
c010ba35:	8d 48 04             	lea    0x4(%eax),%ecx
c010ba38:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba3b:	89 0a                	mov    %ecx,(%edx)
c010ba3d:	8b 00                	mov    (%eax),%eax
c010ba3f:	99                   	cltd   
c010ba40:	eb 10                	jmp    c010ba52 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010ba42:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba45:	8b 00                	mov    (%eax),%eax
c010ba47:	8d 48 04             	lea    0x4(%eax),%ecx
c010ba4a:	8b 55 08             	mov    0x8(%ebp),%edx
c010ba4d:	89 0a                	mov    %ecx,(%edx)
c010ba4f:	8b 00                	mov    (%eax),%eax
c010ba51:	99                   	cltd   
    }
}
c010ba52:	5d                   	pop    %ebp
c010ba53:	c3                   	ret    

c010ba54 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010ba54:	55                   	push   %ebp
c010ba55:	89 e5                	mov    %esp,%ebp
c010ba57:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010ba5a:	8d 45 14             	lea    0x14(%ebp),%eax
c010ba5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010ba60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ba63:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ba67:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba6a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ba6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba71:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba75:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba78:	89 04 24             	mov    %eax,(%esp)
c010ba7b:	e8 02 00 00 00       	call   c010ba82 <vprintfmt>
    va_end(ap);
}
c010ba80:	c9                   	leave  
c010ba81:	c3                   	ret    

c010ba82 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010ba82:	55                   	push   %ebp
c010ba83:	89 e5                	mov    %esp,%ebp
c010ba85:	56                   	push   %esi
c010ba86:	53                   	push   %ebx
c010ba87:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010ba8a:	eb 18                	jmp    c010baa4 <vprintfmt+0x22>
            if (ch == '\0') {
c010ba8c:	85 db                	test   %ebx,%ebx
c010ba8e:	75 05                	jne    c010ba95 <vprintfmt+0x13>
                return;
c010ba90:	e9 d1 03 00 00       	jmp    c010be66 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010ba95:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba98:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba9c:	89 1c 24             	mov    %ebx,(%esp)
c010ba9f:	8b 45 08             	mov    0x8(%ebp),%eax
c010baa2:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010baa4:	8b 45 10             	mov    0x10(%ebp),%eax
c010baa7:	8d 50 01             	lea    0x1(%eax),%edx
c010baaa:	89 55 10             	mov    %edx,0x10(%ebp)
c010baad:	0f b6 00             	movzbl (%eax),%eax
c010bab0:	0f b6 d8             	movzbl %al,%ebx
c010bab3:	83 fb 25             	cmp    $0x25,%ebx
c010bab6:	75 d4                	jne    c010ba8c <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010bab8:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010babc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010bac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bac6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010bac9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010bad0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bad3:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010bad6:	8b 45 10             	mov    0x10(%ebp),%eax
c010bad9:	8d 50 01             	lea    0x1(%eax),%edx
c010badc:	89 55 10             	mov    %edx,0x10(%ebp)
c010badf:	0f b6 00             	movzbl (%eax),%eax
c010bae2:	0f b6 d8             	movzbl %al,%ebx
c010bae5:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010bae8:	83 f8 55             	cmp    $0x55,%eax
c010baeb:	0f 87 44 03 00 00    	ja     c010be35 <vprintfmt+0x3b3>
c010baf1:	8b 04 85 c8 eb 10 c0 	mov    -0x3fef1438(,%eax,4),%eax
c010baf8:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010bafa:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010bafe:	eb d6                	jmp    c010bad6 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010bb00:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010bb04:	eb d0                	jmp    c010bad6 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010bb06:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010bb0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bb10:	89 d0                	mov    %edx,%eax
c010bb12:	c1 e0 02             	shl    $0x2,%eax
c010bb15:	01 d0                	add    %edx,%eax
c010bb17:	01 c0                	add    %eax,%eax
c010bb19:	01 d8                	add    %ebx,%eax
c010bb1b:	83 e8 30             	sub    $0x30,%eax
c010bb1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010bb21:	8b 45 10             	mov    0x10(%ebp),%eax
c010bb24:	0f b6 00             	movzbl (%eax),%eax
c010bb27:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010bb2a:	83 fb 2f             	cmp    $0x2f,%ebx
c010bb2d:	7e 0b                	jle    c010bb3a <vprintfmt+0xb8>
c010bb2f:	83 fb 39             	cmp    $0x39,%ebx
c010bb32:	7f 06                	jg     c010bb3a <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010bb34:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010bb38:	eb d3                	jmp    c010bb0d <vprintfmt+0x8b>
            goto process_precision;
c010bb3a:	eb 33                	jmp    c010bb6f <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010bb3c:	8b 45 14             	mov    0x14(%ebp),%eax
c010bb3f:	8d 50 04             	lea    0x4(%eax),%edx
c010bb42:	89 55 14             	mov    %edx,0x14(%ebp)
c010bb45:	8b 00                	mov    (%eax),%eax
c010bb47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010bb4a:	eb 23                	jmp    c010bb6f <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010bb4c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bb50:	79 0c                	jns    c010bb5e <vprintfmt+0xdc>
                width = 0;
c010bb52:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010bb59:	e9 78 ff ff ff       	jmp    c010bad6 <vprintfmt+0x54>
c010bb5e:	e9 73 ff ff ff       	jmp    c010bad6 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010bb63:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010bb6a:	e9 67 ff ff ff       	jmp    c010bad6 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010bb6f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bb73:	79 12                	jns    c010bb87 <vprintfmt+0x105>
                width = precision, precision = -1;
c010bb75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bb78:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bb7b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010bb82:	e9 4f ff ff ff       	jmp    c010bad6 <vprintfmt+0x54>
c010bb87:	e9 4a ff ff ff       	jmp    c010bad6 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010bb8c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010bb90:	e9 41 ff ff ff       	jmp    c010bad6 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010bb95:	8b 45 14             	mov    0x14(%ebp),%eax
c010bb98:	8d 50 04             	lea    0x4(%eax),%edx
c010bb9b:	89 55 14             	mov    %edx,0x14(%ebp)
c010bb9e:	8b 00                	mov    (%eax),%eax
c010bba0:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bba3:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bba7:	89 04 24             	mov    %eax,(%esp)
c010bbaa:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbad:	ff d0                	call   *%eax
            break;
c010bbaf:	e9 ac 02 00 00       	jmp    c010be60 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010bbb4:	8b 45 14             	mov    0x14(%ebp),%eax
c010bbb7:	8d 50 04             	lea    0x4(%eax),%edx
c010bbba:	89 55 14             	mov    %edx,0x14(%ebp)
c010bbbd:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010bbbf:	85 db                	test   %ebx,%ebx
c010bbc1:	79 02                	jns    c010bbc5 <vprintfmt+0x143>
                err = -err;
c010bbc3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010bbc5:	83 fb 18             	cmp    $0x18,%ebx
c010bbc8:	7f 0b                	jg     c010bbd5 <vprintfmt+0x153>
c010bbca:	8b 34 9d 40 eb 10 c0 	mov    -0x3fef14c0(,%ebx,4),%esi
c010bbd1:	85 f6                	test   %esi,%esi
c010bbd3:	75 23                	jne    c010bbf8 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010bbd5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010bbd9:	c7 44 24 08 b5 eb 10 	movl   $0xc010ebb5,0x8(%esp)
c010bbe0:	c0 
c010bbe1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbe4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbe8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbeb:	89 04 24             	mov    %eax,(%esp)
c010bbee:	e8 61 fe ff ff       	call   c010ba54 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010bbf3:	e9 68 02 00 00       	jmp    c010be60 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010bbf8:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010bbfc:	c7 44 24 08 be eb 10 	movl   $0xc010ebbe,0x8(%esp)
c010bc03:	c0 
c010bc04:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc07:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc0b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc0e:	89 04 24             	mov    %eax,(%esp)
c010bc11:	e8 3e fe ff ff       	call   c010ba54 <printfmt>
            }
            break;
c010bc16:	e9 45 02 00 00       	jmp    c010be60 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010bc1b:	8b 45 14             	mov    0x14(%ebp),%eax
c010bc1e:	8d 50 04             	lea    0x4(%eax),%edx
c010bc21:	89 55 14             	mov    %edx,0x14(%ebp)
c010bc24:	8b 30                	mov    (%eax),%esi
c010bc26:	85 f6                	test   %esi,%esi
c010bc28:	75 05                	jne    c010bc2f <vprintfmt+0x1ad>
                p = "(null)";
c010bc2a:	be c1 eb 10 c0       	mov    $0xc010ebc1,%esi
            }
            if (width > 0 && padc != '-') {
c010bc2f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bc33:	7e 3e                	jle    c010bc73 <vprintfmt+0x1f1>
c010bc35:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010bc39:	74 38                	je     c010bc73 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bc3b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010bc3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bc41:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc45:	89 34 24             	mov    %esi,(%esp)
c010bc48:	e8 ed 03 00 00       	call   c010c03a <strnlen>
c010bc4d:	29 c3                	sub    %eax,%ebx
c010bc4f:	89 d8                	mov    %ebx,%eax
c010bc51:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bc54:	eb 17                	jmp    c010bc6d <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010bc56:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010bc5a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bc5d:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bc61:	89 04 24             	mov    %eax,(%esp)
c010bc64:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc67:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bc69:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bc6d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bc71:	7f e3                	jg     c010bc56 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bc73:	eb 38                	jmp    c010bcad <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010bc75:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010bc79:	74 1f                	je     c010bc9a <vprintfmt+0x218>
c010bc7b:	83 fb 1f             	cmp    $0x1f,%ebx
c010bc7e:	7e 05                	jle    c010bc85 <vprintfmt+0x203>
c010bc80:	83 fb 7e             	cmp    $0x7e,%ebx
c010bc83:	7e 15                	jle    c010bc9a <vprintfmt+0x218>
                    putch('?', putdat);
c010bc85:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc88:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010bc93:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc96:	ff d0                	call   *%eax
c010bc98:	eb 0f                	jmp    c010bca9 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010bc9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bca1:	89 1c 24             	mov    %ebx,(%esp)
c010bca4:	8b 45 08             	mov    0x8(%ebp),%eax
c010bca7:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bca9:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bcad:	89 f0                	mov    %esi,%eax
c010bcaf:	8d 70 01             	lea    0x1(%eax),%esi
c010bcb2:	0f b6 00             	movzbl (%eax),%eax
c010bcb5:	0f be d8             	movsbl %al,%ebx
c010bcb8:	85 db                	test   %ebx,%ebx
c010bcba:	74 10                	je     c010bccc <vprintfmt+0x24a>
c010bcbc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bcc0:	78 b3                	js     c010bc75 <vprintfmt+0x1f3>
c010bcc2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010bcc6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bcca:	79 a9                	jns    c010bc75 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010bccc:	eb 17                	jmp    c010bce5 <vprintfmt+0x263>
                putch(' ', putdat);
c010bcce:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bcd5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010bcdc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcdf:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010bce1:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bce5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bce9:	7f e3                	jg     c010bcce <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010bceb:	e9 70 01 00 00       	jmp    c010be60 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010bcf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bcf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bcf7:	8d 45 14             	lea    0x14(%ebp),%eax
c010bcfa:	89 04 24             	mov    %eax,(%esp)
c010bcfd:	e8 0b fd ff ff       	call   c010ba0d <getint>
c010bd02:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd05:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010bd08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bd0e:	85 d2                	test   %edx,%edx
c010bd10:	79 26                	jns    c010bd38 <vprintfmt+0x2b6>
                putch('-', putdat);
c010bd12:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd15:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd19:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010bd20:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd23:	ff d0                	call   *%eax
                num = -(long long)num;
c010bd25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd28:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bd2b:	f7 d8                	neg    %eax
c010bd2d:	83 d2 00             	adc    $0x0,%edx
c010bd30:	f7 da                	neg    %edx
c010bd32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd35:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010bd38:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bd3f:	e9 a8 00 00 00       	jmp    c010bdec <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010bd44:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bd47:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd4b:	8d 45 14             	lea    0x14(%ebp),%eax
c010bd4e:	89 04 24             	mov    %eax,(%esp)
c010bd51:	e8 68 fc ff ff       	call   c010b9be <getuint>
c010bd56:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd59:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010bd5c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bd63:	e9 84 00 00 00       	jmp    c010bdec <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010bd68:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bd6b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd6f:	8d 45 14             	lea    0x14(%ebp),%eax
c010bd72:	89 04 24             	mov    %eax,(%esp)
c010bd75:	e8 44 fc ff ff       	call   c010b9be <getuint>
c010bd7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd7d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010bd80:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010bd87:	eb 63                	jmp    c010bdec <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010bd89:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd90:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010bd97:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd9a:	ff d0                	call   *%eax
            putch('x', putdat);
c010bd9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bda3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010bdaa:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdad:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010bdaf:	8b 45 14             	mov    0x14(%ebp),%eax
c010bdb2:	8d 50 04             	lea    0x4(%eax),%edx
c010bdb5:	89 55 14             	mov    %edx,0x14(%ebp)
c010bdb8:	8b 00                	mov    (%eax),%eax
c010bdba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bdbd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010bdc4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010bdcb:	eb 1f                	jmp    c010bdec <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010bdcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bdd0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bdd4:	8d 45 14             	lea    0x14(%ebp),%eax
c010bdd7:	89 04 24             	mov    %eax,(%esp)
c010bdda:	e8 df fb ff ff       	call   c010b9be <getuint>
c010bddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bde2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010bde5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010bdec:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010bdf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bdf3:	89 54 24 18          	mov    %edx,0x18(%esp)
c010bdf7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bdfa:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bdfe:	89 44 24 10          	mov    %eax,0x10(%esp)
c010be02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010be05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010be08:	89 44 24 08          	mov    %eax,0x8(%esp)
c010be0c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010be10:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be13:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be17:	8b 45 08             	mov    0x8(%ebp),%eax
c010be1a:	89 04 24             	mov    %eax,(%esp)
c010be1d:	e8 97 fa ff ff       	call   c010b8b9 <printnum>
            break;
c010be22:	eb 3c                	jmp    c010be60 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010be24:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be27:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be2b:	89 1c 24             	mov    %ebx,(%esp)
c010be2e:	8b 45 08             	mov    0x8(%ebp),%eax
c010be31:	ff d0                	call   *%eax
            break;
c010be33:	eb 2b                	jmp    c010be60 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010be35:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be38:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be3c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010be43:	8b 45 08             	mov    0x8(%ebp),%eax
c010be46:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010be48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010be4c:	eb 04                	jmp    c010be52 <vprintfmt+0x3d0>
c010be4e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010be52:	8b 45 10             	mov    0x10(%ebp),%eax
c010be55:	83 e8 01             	sub    $0x1,%eax
c010be58:	0f b6 00             	movzbl (%eax),%eax
c010be5b:	3c 25                	cmp    $0x25,%al
c010be5d:	75 ef                	jne    c010be4e <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010be5f:	90                   	nop
        }
    }
c010be60:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010be61:	e9 3e fc ff ff       	jmp    c010baa4 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010be66:	83 c4 40             	add    $0x40,%esp
c010be69:	5b                   	pop    %ebx
c010be6a:	5e                   	pop    %esi
c010be6b:	5d                   	pop    %ebp
c010be6c:	c3                   	ret    

c010be6d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010be6d:	55                   	push   %ebp
c010be6e:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010be70:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be73:	8b 40 08             	mov    0x8(%eax),%eax
c010be76:	8d 50 01             	lea    0x1(%eax),%edx
c010be79:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be7c:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010be7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be82:	8b 10                	mov    (%eax),%edx
c010be84:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be87:	8b 40 04             	mov    0x4(%eax),%eax
c010be8a:	39 c2                	cmp    %eax,%edx
c010be8c:	73 12                	jae    c010bea0 <sprintputch+0x33>
        *b->buf ++ = ch;
c010be8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be91:	8b 00                	mov    (%eax),%eax
c010be93:	8d 48 01             	lea    0x1(%eax),%ecx
c010be96:	8b 55 0c             	mov    0xc(%ebp),%edx
c010be99:	89 0a                	mov    %ecx,(%edx)
c010be9b:	8b 55 08             	mov    0x8(%ebp),%edx
c010be9e:	88 10                	mov    %dl,(%eax)
    }
}
c010bea0:	5d                   	pop    %ebp
c010bea1:	c3                   	ret    

c010bea2 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010bea2:	55                   	push   %ebp
c010bea3:	89 e5                	mov    %esp,%ebp
c010bea5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010bea8:	8d 45 14             	lea    0x14(%ebp),%eax
c010beab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010beae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010beb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010beb5:	8b 45 10             	mov    0x10(%ebp),%eax
c010beb8:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bebc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bebf:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bec3:	8b 45 08             	mov    0x8(%ebp),%eax
c010bec6:	89 04 24             	mov    %eax,(%esp)
c010bec9:	e8 08 00 00 00       	call   c010bed6 <vsnprintf>
c010bece:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010bed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bed4:	c9                   	leave  
c010bed5:	c3                   	ret    

c010bed6 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010bed6:	55                   	push   %ebp
c010bed7:	89 e5                	mov    %esp,%ebp
c010bed9:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010bedc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bedf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bee2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bee5:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bee8:	8b 45 08             	mov    0x8(%ebp),%eax
c010beeb:	01 d0                	add    %edx,%eax
c010beed:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bef0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010bef7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010befb:	74 0a                	je     c010bf07 <vsnprintf+0x31>
c010befd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bf00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bf03:	39 c2                	cmp    %eax,%edx
c010bf05:	76 07                	jbe    c010bf0e <vsnprintf+0x38>
        return -E_INVAL;
c010bf07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010bf0c:	eb 2a                	jmp    c010bf38 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010bf0e:	8b 45 14             	mov    0x14(%ebp),%eax
c010bf11:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bf15:	8b 45 10             	mov    0x10(%ebp),%eax
c010bf18:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bf1c:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010bf1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf23:	c7 04 24 6d be 10 c0 	movl   $0xc010be6d,(%esp)
c010bf2a:	e8 53 fb ff ff       	call   c010ba82 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010bf2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bf32:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010bf35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bf38:	c9                   	leave  
c010bf39:	c3                   	ret    

c010bf3a <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010bf3a:	55                   	push   %ebp
c010bf3b:	89 e5                	mov    %esp,%ebp
c010bf3d:	57                   	push   %edi
c010bf3e:	56                   	push   %esi
c010bf3f:	53                   	push   %ebx
c010bf40:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010bf43:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010bf48:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010bf4e:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010bf54:	6b f0 05             	imul   $0x5,%eax,%esi
c010bf57:	01 f7                	add    %esi,%edi
c010bf59:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010bf5e:	f7 e6                	mul    %esi
c010bf60:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010bf63:	89 f2                	mov    %esi,%edx
c010bf65:	83 c0 0b             	add    $0xb,%eax
c010bf68:	83 d2 00             	adc    $0x0,%edx
c010bf6b:	89 c7                	mov    %eax,%edi
c010bf6d:	83 e7 ff             	and    $0xffffffff,%edi
c010bf70:	89 f9                	mov    %edi,%ecx
c010bf72:	0f b7 da             	movzwl %dx,%ebx
c010bf75:	89 0d a0 ce 12 c0    	mov    %ecx,0xc012cea0
c010bf7b:	89 1d a4 ce 12 c0    	mov    %ebx,0xc012cea4
    unsigned long long result = (next >> 12);
c010bf81:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010bf86:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010bf8c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010bf90:	c1 ea 0c             	shr    $0xc,%edx
c010bf93:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bf96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010bf99:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010bfa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bfa3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bfa6:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bfa9:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bfac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bfaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bfb2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bfb6:	74 1c                	je     c010bfd4 <rand+0x9a>
c010bfb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bfbb:	ba 00 00 00 00       	mov    $0x0,%edx
c010bfc0:	f7 75 dc             	divl   -0x24(%ebp)
c010bfc3:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bfc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bfc9:	ba 00 00 00 00       	mov    $0x0,%edx
c010bfce:	f7 75 dc             	divl   -0x24(%ebp)
c010bfd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bfd4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bfd7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bfda:	f7 75 dc             	divl   -0x24(%ebp)
c010bfdd:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bfe0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bfe3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bfe6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bfe9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bfec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010bfef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010bff2:	83 c4 24             	add    $0x24,%esp
c010bff5:	5b                   	pop    %ebx
c010bff6:	5e                   	pop    %esi
c010bff7:	5f                   	pop    %edi
c010bff8:	5d                   	pop    %ebp
c010bff9:	c3                   	ret    

c010bffa <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010bffa:	55                   	push   %ebp
c010bffb:	89 e5                	mov    %esp,%ebp
    next = seed;
c010bffd:	8b 45 08             	mov    0x8(%ebp),%eax
c010c000:	ba 00 00 00 00       	mov    $0x0,%edx
c010c005:	a3 a0 ce 12 c0       	mov    %eax,0xc012cea0
c010c00a:	89 15 a4 ce 12 c0    	mov    %edx,0xc012cea4
}
c010c010:	5d                   	pop    %ebp
c010c011:	c3                   	ret    

c010c012 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010c012:	55                   	push   %ebp
c010c013:	89 e5                	mov    %esp,%ebp
c010c015:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010c018:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010c01f:	eb 04                	jmp    c010c025 <strlen+0x13>
        cnt ++;
c010c021:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010c025:	8b 45 08             	mov    0x8(%ebp),%eax
c010c028:	8d 50 01             	lea    0x1(%eax),%edx
c010c02b:	89 55 08             	mov    %edx,0x8(%ebp)
c010c02e:	0f b6 00             	movzbl (%eax),%eax
c010c031:	84 c0                	test   %al,%al
c010c033:	75 ec                	jne    c010c021 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010c035:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010c038:	c9                   	leave  
c010c039:	c3                   	ret    

c010c03a <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010c03a:	55                   	push   %ebp
c010c03b:	89 e5                	mov    %esp,%ebp
c010c03d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010c040:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010c047:	eb 04                	jmp    c010c04d <strnlen+0x13>
        cnt ++;
c010c049:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010c04d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c050:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010c053:	73 10                	jae    c010c065 <strnlen+0x2b>
c010c055:	8b 45 08             	mov    0x8(%ebp),%eax
c010c058:	8d 50 01             	lea    0x1(%eax),%edx
c010c05b:	89 55 08             	mov    %edx,0x8(%ebp)
c010c05e:	0f b6 00             	movzbl (%eax),%eax
c010c061:	84 c0                	test   %al,%al
c010c063:	75 e4                	jne    c010c049 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010c065:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010c068:	c9                   	leave  
c010c069:	c3                   	ret    

c010c06a <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010c06a:	55                   	push   %ebp
c010c06b:	89 e5                	mov    %esp,%ebp
c010c06d:	57                   	push   %edi
c010c06e:	56                   	push   %esi
c010c06f:	83 ec 20             	sub    $0x20,%esp
c010c072:	8b 45 08             	mov    0x8(%ebp),%eax
c010c075:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c078:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c07b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010c07e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010c081:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c084:	89 d1                	mov    %edx,%ecx
c010c086:	89 c2                	mov    %eax,%edx
c010c088:	89 ce                	mov    %ecx,%esi
c010c08a:	89 d7                	mov    %edx,%edi
c010c08c:	ac                   	lods   %ds:(%esi),%al
c010c08d:	aa                   	stos   %al,%es:(%edi)
c010c08e:	84 c0                	test   %al,%al
c010c090:	75 fa                	jne    c010c08c <strcpy+0x22>
c010c092:	89 fa                	mov    %edi,%edx
c010c094:	89 f1                	mov    %esi,%ecx
c010c096:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010c099:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010c09c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010c09f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010c0a2:	83 c4 20             	add    $0x20,%esp
c010c0a5:	5e                   	pop    %esi
c010c0a6:	5f                   	pop    %edi
c010c0a7:	5d                   	pop    %ebp
c010c0a8:	c3                   	ret    

c010c0a9 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010c0a9:	55                   	push   %ebp
c010c0aa:	89 e5                	mov    %esp,%ebp
c010c0ac:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010c0af:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010c0b5:	eb 21                	jmp    c010c0d8 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010c0b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0ba:	0f b6 10             	movzbl (%eax),%edx
c010c0bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c0c0:	88 10                	mov    %dl,(%eax)
c010c0c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c0c5:	0f b6 00             	movzbl (%eax),%eax
c010c0c8:	84 c0                	test   %al,%al
c010c0ca:	74 04                	je     c010c0d0 <strncpy+0x27>
            src ++;
c010c0cc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010c0d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010c0d4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010c0d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c0dc:	75 d9                	jne    c010c0b7 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010c0de:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010c0e1:	c9                   	leave  
c010c0e2:	c3                   	ret    

c010c0e3 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010c0e3:	55                   	push   %ebp
c010c0e4:	89 e5                	mov    %esp,%ebp
c010c0e6:	57                   	push   %edi
c010c0e7:	56                   	push   %esi
c010c0e8:	83 ec 20             	sub    $0x20,%esp
c010c0eb:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c0f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010c0f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c0fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c0fd:	89 d1                	mov    %edx,%ecx
c010c0ff:	89 c2                	mov    %eax,%edx
c010c101:	89 ce                	mov    %ecx,%esi
c010c103:	89 d7                	mov    %edx,%edi
c010c105:	ac                   	lods   %ds:(%esi),%al
c010c106:	ae                   	scas   %es:(%edi),%al
c010c107:	75 08                	jne    c010c111 <strcmp+0x2e>
c010c109:	84 c0                	test   %al,%al
c010c10b:	75 f8                	jne    c010c105 <strcmp+0x22>
c010c10d:	31 c0                	xor    %eax,%eax
c010c10f:	eb 04                	jmp    c010c115 <strcmp+0x32>
c010c111:	19 c0                	sbb    %eax,%eax
c010c113:	0c 01                	or     $0x1,%al
c010c115:	89 fa                	mov    %edi,%edx
c010c117:	89 f1                	mov    %esi,%ecx
c010c119:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c11c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010c11f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010c122:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010c125:	83 c4 20             	add    $0x20,%esp
c010c128:	5e                   	pop    %esi
c010c129:	5f                   	pop    %edi
c010c12a:	5d                   	pop    %ebp
c010c12b:	c3                   	ret    

c010c12c <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010c12c:	55                   	push   %ebp
c010c12d:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010c12f:	eb 0c                	jmp    c010c13d <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010c131:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010c135:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c139:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010c13d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c141:	74 1a                	je     c010c15d <strncmp+0x31>
c010c143:	8b 45 08             	mov    0x8(%ebp),%eax
c010c146:	0f b6 00             	movzbl (%eax),%eax
c010c149:	84 c0                	test   %al,%al
c010c14b:	74 10                	je     c010c15d <strncmp+0x31>
c010c14d:	8b 45 08             	mov    0x8(%ebp),%eax
c010c150:	0f b6 10             	movzbl (%eax),%edx
c010c153:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c156:	0f b6 00             	movzbl (%eax),%eax
c010c159:	38 c2                	cmp    %al,%dl
c010c15b:	74 d4                	je     c010c131 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010c15d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c161:	74 18                	je     c010c17b <strncmp+0x4f>
c010c163:	8b 45 08             	mov    0x8(%ebp),%eax
c010c166:	0f b6 00             	movzbl (%eax),%eax
c010c169:	0f b6 d0             	movzbl %al,%edx
c010c16c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c16f:	0f b6 00             	movzbl (%eax),%eax
c010c172:	0f b6 c0             	movzbl %al,%eax
c010c175:	29 c2                	sub    %eax,%edx
c010c177:	89 d0                	mov    %edx,%eax
c010c179:	eb 05                	jmp    c010c180 <strncmp+0x54>
c010c17b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c180:	5d                   	pop    %ebp
c010c181:	c3                   	ret    

c010c182 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010c182:	55                   	push   %ebp
c010c183:	89 e5                	mov    %esp,%ebp
c010c185:	83 ec 04             	sub    $0x4,%esp
c010c188:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c18b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010c18e:	eb 14                	jmp    c010c1a4 <strchr+0x22>
        if (*s == c) {
c010c190:	8b 45 08             	mov    0x8(%ebp),%eax
c010c193:	0f b6 00             	movzbl (%eax),%eax
c010c196:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010c199:	75 05                	jne    c010c1a0 <strchr+0x1e>
            return (char *)s;
c010c19b:	8b 45 08             	mov    0x8(%ebp),%eax
c010c19e:	eb 13                	jmp    c010c1b3 <strchr+0x31>
        }
        s ++;
c010c1a0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010c1a4:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1a7:	0f b6 00             	movzbl (%eax),%eax
c010c1aa:	84 c0                	test   %al,%al
c010c1ac:	75 e2                	jne    c010c190 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010c1ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c1b3:	c9                   	leave  
c010c1b4:	c3                   	ret    

c010c1b5 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010c1b5:	55                   	push   %ebp
c010c1b6:	89 e5                	mov    %esp,%ebp
c010c1b8:	83 ec 04             	sub    $0x4,%esp
c010c1bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c1be:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010c1c1:	eb 11                	jmp    c010c1d4 <strfind+0x1f>
        if (*s == c) {
c010c1c3:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1c6:	0f b6 00             	movzbl (%eax),%eax
c010c1c9:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010c1cc:	75 02                	jne    c010c1d0 <strfind+0x1b>
            break;
c010c1ce:	eb 0e                	jmp    c010c1de <strfind+0x29>
        }
        s ++;
c010c1d0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010c1d4:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1d7:	0f b6 00             	movzbl (%eax),%eax
c010c1da:	84 c0                	test   %al,%al
c010c1dc:	75 e5                	jne    c010c1c3 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010c1de:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010c1e1:	c9                   	leave  
c010c1e2:	c3                   	ret    

c010c1e3 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010c1e3:	55                   	push   %ebp
c010c1e4:	89 e5                	mov    %esp,%ebp
c010c1e6:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010c1e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010c1f0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010c1f7:	eb 04                	jmp    c010c1fd <strtol+0x1a>
        s ++;
c010c1f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010c1fd:	8b 45 08             	mov    0x8(%ebp),%eax
c010c200:	0f b6 00             	movzbl (%eax),%eax
c010c203:	3c 20                	cmp    $0x20,%al
c010c205:	74 f2                	je     c010c1f9 <strtol+0x16>
c010c207:	8b 45 08             	mov    0x8(%ebp),%eax
c010c20a:	0f b6 00             	movzbl (%eax),%eax
c010c20d:	3c 09                	cmp    $0x9,%al
c010c20f:	74 e8                	je     c010c1f9 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010c211:	8b 45 08             	mov    0x8(%ebp),%eax
c010c214:	0f b6 00             	movzbl (%eax),%eax
c010c217:	3c 2b                	cmp    $0x2b,%al
c010c219:	75 06                	jne    c010c221 <strtol+0x3e>
        s ++;
c010c21b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c21f:	eb 15                	jmp    c010c236 <strtol+0x53>
    }
    else if (*s == '-') {
c010c221:	8b 45 08             	mov    0x8(%ebp),%eax
c010c224:	0f b6 00             	movzbl (%eax),%eax
c010c227:	3c 2d                	cmp    $0x2d,%al
c010c229:	75 0b                	jne    c010c236 <strtol+0x53>
        s ++, neg = 1;
c010c22b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c22f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010c236:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c23a:	74 06                	je     c010c242 <strtol+0x5f>
c010c23c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010c240:	75 24                	jne    c010c266 <strtol+0x83>
c010c242:	8b 45 08             	mov    0x8(%ebp),%eax
c010c245:	0f b6 00             	movzbl (%eax),%eax
c010c248:	3c 30                	cmp    $0x30,%al
c010c24a:	75 1a                	jne    c010c266 <strtol+0x83>
c010c24c:	8b 45 08             	mov    0x8(%ebp),%eax
c010c24f:	83 c0 01             	add    $0x1,%eax
c010c252:	0f b6 00             	movzbl (%eax),%eax
c010c255:	3c 78                	cmp    $0x78,%al
c010c257:	75 0d                	jne    c010c266 <strtol+0x83>
        s += 2, base = 16;
c010c259:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010c25d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010c264:	eb 2a                	jmp    c010c290 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010c266:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c26a:	75 17                	jne    c010c283 <strtol+0xa0>
c010c26c:	8b 45 08             	mov    0x8(%ebp),%eax
c010c26f:	0f b6 00             	movzbl (%eax),%eax
c010c272:	3c 30                	cmp    $0x30,%al
c010c274:	75 0d                	jne    c010c283 <strtol+0xa0>
        s ++, base = 8;
c010c276:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c27a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010c281:	eb 0d                	jmp    c010c290 <strtol+0xad>
    }
    else if (base == 0) {
c010c283:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c287:	75 07                	jne    c010c290 <strtol+0xad>
        base = 10;
c010c289:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010c290:	8b 45 08             	mov    0x8(%ebp),%eax
c010c293:	0f b6 00             	movzbl (%eax),%eax
c010c296:	3c 2f                	cmp    $0x2f,%al
c010c298:	7e 1b                	jle    c010c2b5 <strtol+0xd2>
c010c29a:	8b 45 08             	mov    0x8(%ebp),%eax
c010c29d:	0f b6 00             	movzbl (%eax),%eax
c010c2a0:	3c 39                	cmp    $0x39,%al
c010c2a2:	7f 11                	jg     c010c2b5 <strtol+0xd2>
            dig = *s - '0';
c010c2a4:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2a7:	0f b6 00             	movzbl (%eax),%eax
c010c2aa:	0f be c0             	movsbl %al,%eax
c010c2ad:	83 e8 30             	sub    $0x30,%eax
c010c2b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c2b3:	eb 48                	jmp    c010c2fd <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010c2b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2b8:	0f b6 00             	movzbl (%eax),%eax
c010c2bb:	3c 60                	cmp    $0x60,%al
c010c2bd:	7e 1b                	jle    c010c2da <strtol+0xf7>
c010c2bf:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2c2:	0f b6 00             	movzbl (%eax),%eax
c010c2c5:	3c 7a                	cmp    $0x7a,%al
c010c2c7:	7f 11                	jg     c010c2da <strtol+0xf7>
            dig = *s - 'a' + 10;
c010c2c9:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2cc:	0f b6 00             	movzbl (%eax),%eax
c010c2cf:	0f be c0             	movsbl %al,%eax
c010c2d2:	83 e8 57             	sub    $0x57,%eax
c010c2d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c2d8:	eb 23                	jmp    c010c2fd <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010c2da:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2dd:	0f b6 00             	movzbl (%eax),%eax
c010c2e0:	3c 40                	cmp    $0x40,%al
c010c2e2:	7e 3d                	jle    c010c321 <strtol+0x13e>
c010c2e4:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2e7:	0f b6 00             	movzbl (%eax),%eax
c010c2ea:	3c 5a                	cmp    $0x5a,%al
c010c2ec:	7f 33                	jg     c010c321 <strtol+0x13e>
            dig = *s - 'A' + 10;
c010c2ee:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2f1:	0f b6 00             	movzbl (%eax),%eax
c010c2f4:	0f be c0             	movsbl %al,%eax
c010c2f7:	83 e8 37             	sub    $0x37,%eax
c010c2fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010c2fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c300:	3b 45 10             	cmp    0x10(%ebp),%eax
c010c303:	7c 02                	jl     c010c307 <strtol+0x124>
            break;
c010c305:	eb 1a                	jmp    c010c321 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010c307:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c30b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c30e:	0f af 45 10          	imul   0x10(%ebp),%eax
c010c312:	89 c2                	mov    %eax,%edx
c010c314:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c317:	01 d0                	add    %edx,%eax
c010c319:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010c31c:	e9 6f ff ff ff       	jmp    c010c290 <strtol+0xad>

    if (endptr) {
c010c321:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010c325:	74 08                	je     c010c32f <strtol+0x14c>
        *endptr = (char *) s;
c010c327:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c32a:	8b 55 08             	mov    0x8(%ebp),%edx
c010c32d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010c32f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010c333:	74 07                	je     c010c33c <strtol+0x159>
c010c335:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c338:	f7 d8                	neg    %eax
c010c33a:	eb 03                	jmp    c010c33f <strtol+0x15c>
c010c33c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010c33f:	c9                   	leave  
c010c340:	c3                   	ret    

c010c341 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010c341:	55                   	push   %ebp
c010c342:	89 e5                	mov    %esp,%ebp
c010c344:	57                   	push   %edi
c010c345:	83 ec 24             	sub    $0x24,%esp
c010c348:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c34b:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010c34e:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010c352:	8b 55 08             	mov    0x8(%ebp),%edx
c010c355:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010c358:	88 45 f7             	mov    %al,-0x9(%ebp)
c010c35b:	8b 45 10             	mov    0x10(%ebp),%eax
c010c35e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010c361:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010c364:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010c368:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010c36b:	89 d7                	mov    %edx,%edi
c010c36d:	f3 aa                	rep stos %al,%es:(%edi)
c010c36f:	89 fa                	mov    %edi,%edx
c010c371:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010c374:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010c377:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010c37a:	83 c4 24             	add    $0x24,%esp
c010c37d:	5f                   	pop    %edi
c010c37e:	5d                   	pop    %ebp
c010c37f:	c3                   	ret    

c010c380 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010c380:	55                   	push   %ebp
c010c381:	89 e5                	mov    %esp,%ebp
c010c383:	57                   	push   %edi
c010c384:	56                   	push   %esi
c010c385:	53                   	push   %ebx
c010c386:	83 ec 30             	sub    $0x30,%esp
c010c389:	8b 45 08             	mov    0x8(%ebp),%eax
c010c38c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c38f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c392:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c395:	8b 45 10             	mov    0x10(%ebp),%eax
c010c398:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010c39b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c39e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010c3a1:	73 42                	jae    c010c3e5 <memmove+0x65>
c010c3a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c3a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010c3a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c3ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c3af:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c3b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c3b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010c3b8:	c1 e8 02             	shr    $0x2,%eax
c010c3bb:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010c3bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c3c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c3c3:	89 d7                	mov    %edx,%edi
c010c3c5:	89 c6                	mov    %eax,%esi
c010c3c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c3c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010c3cc:	83 e1 03             	and    $0x3,%ecx
c010c3cf:	74 02                	je     c010c3d3 <memmove+0x53>
c010c3d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c3d3:	89 f0                	mov    %esi,%eax
c010c3d5:	89 fa                	mov    %edi,%edx
c010c3d7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010c3da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c3dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010c3e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010c3e3:	eb 36                	jmp    c010c41b <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010c3e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c3e8:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c3eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c3ee:	01 c2                	add    %eax,%edx
c010c3f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c3f3:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010c3f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c3f9:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010c3fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c3ff:	89 c1                	mov    %eax,%ecx
c010c401:	89 d8                	mov    %ebx,%eax
c010c403:	89 d6                	mov    %edx,%esi
c010c405:	89 c7                	mov    %eax,%edi
c010c407:	fd                   	std    
c010c408:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c40a:	fc                   	cld    
c010c40b:	89 f8                	mov    %edi,%eax
c010c40d:	89 f2                	mov    %esi,%edx
c010c40f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010c412:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010c415:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010c418:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010c41b:	83 c4 30             	add    $0x30,%esp
c010c41e:	5b                   	pop    %ebx
c010c41f:	5e                   	pop    %esi
c010c420:	5f                   	pop    %edi
c010c421:	5d                   	pop    %ebp
c010c422:	c3                   	ret    

c010c423 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010c423:	55                   	push   %ebp
c010c424:	89 e5                	mov    %esp,%ebp
c010c426:	57                   	push   %edi
c010c427:	56                   	push   %esi
c010c428:	83 ec 20             	sub    $0x20,%esp
c010c42b:	8b 45 08             	mov    0x8(%ebp),%eax
c010c42e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c431:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c434:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c437:	8b 45 10             	mov    0x10(%ebp),%eax
c010c43a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c43d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c440:	c1 e8 02             	shr    $0x2,%eax
c010c443:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010c445:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c448:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c44b:	89 d7                	mov    %edx,%edi
c010c44d:	89 c6                	mov    %eax,%esi
c010c44f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c451:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010c454:	83 e1 03             	and    $0x3,%ecx
c010c457:	74 02                	je     c010c45b <memcpy+0x38>
c010c459:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c45b:	89 f0                	mov    %esi,%eax
c010c45d:	89 fa                	mov    %edi,%edx
c010c45f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010c462:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c465:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010c468:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010c46b:	83 c4 20             	add    $0x20,%esp
c010c46e:	5e                   	pop    %esi
c010c46f:	5f                   	pop    %edi
c010c470:	5d                   	pop    %ebp
c010c471:	c3                   	ret    

c010c472 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010c472:	55                   	push   %ebp
c010c473:	89 e5                	mov    %esp,%ebp
c010c475:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010c478:	8b 45 08             	mov    0x8(%ebp),%eax
c010c47b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010c47e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c481:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010c484:	eb 30                	jmp    c010c4b6 <memcmp+0x44>
        if (*s1 != *s2) {
c010c486:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c489:	0f b6 10             	movzbl (%eax),%edx
c010c48c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c48f:	0f b6 00             	movzbl (%eax),%eax
c010c492:	38 c2                	cmp    %al,%dl
c010c494:	74 18                	je     c010c4ae <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010c496:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c499:	0f b6 00             	movzbl (%eax),%eax
c010c49c:	0f b6 d0             	movzbl %al,%edx
c010c49f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c4a2:	0f b6 00             	movzbl (%eax),%eax
c010c4a5:	0f b6 c0             	movzbl %al,%eax
c010c4a8:	29 c2                	sub    %eax,%edx
c010c4aa:	89 d0                	mov    %edx,%eax
c010c4ac:	eb 1a                	jmp    c010c4c8 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010c4ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010c4b2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010c4b6:	8b 45 10             	mov    0x10(%ebp),%eax
c010c4b9:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c4bc:	89 55 10             	mov    %edx,0x10(%ebp)
c010c4bf:	85 c0                	test   %eax,%eax
c010c4c1:	75 c3                	jne    c010c486 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010c4c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c4c8:	c9                   	leave  
c010c4c9:	c3                   	ret    
