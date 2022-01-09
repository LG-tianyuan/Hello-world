
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 c0 19 00       	mov    $0x19c000,%eax
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
c0100020:	a3 00 c0 19 c0       	mov    %eax,0xc019c000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 a0 12 c0       	mov    $0xc012a000,%esp
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
c010003c:	ba d8 11 1a c0       	mov    $0xc01a11d8,%edx
c0100041:	b8 00 e0 19 c0       	mov    $0xc019e000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 e0 19 c0 	movl   $0xc019e000,(%esp)
c010005d:	e8 f7 bd 00 00       	call   c010be59 <memset>

    cons_init();                // init the console
c0100062:	e8 9b 16 00 00       	call   c0101702 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 c0 10 c0 	movl   $0xc010c000,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c c0 10 c0 	movl   $0xc010c01c,(%esp)
c010007c:	e8 de 02 00 00       	call   c010035f <cprintf>

    print_kerninfo();
c0100081:	e8 05 09 00 00       	call   c010098b <print_kerninfo>

    grade_backtrace();
c0100086:	e8 9d 00 00 00       	call   c0100128 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 ed 57 00 00       	call   c010587d <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 4b 20 00 00       	call   c01020e0 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 c3 21 00 00       	call   c010225d <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 7f 87 00 00       	call   c010881e <vmm_init>
    proc_init();                // init process table
c010009f:	e8 78 ad 00 00       	call   c010ae1c <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 8a 17 00 00       	call   c0101833 <ide_init>
    swap_init();                // init swap
c01000a9:	e8 46 6e 00 00       	call   c0106ef4 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 05 0e 00 00       	call   c0100eb8 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 96 1f 00 00       	call   c010204e <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 1e af 00 00       	call   c010afdb <cpu_idle>

c01000bd <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000bd:	55                   	push   %ebp
c01000be:	89 e5                	mov    %esp,%ebp
c01000c0:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000ca:	00 
c01000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d2:	00 
c01000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000da:	e8 fa 0c 00 00       	call   c0100dd9 <mon_backtrace>
}
c01000df:	c9                   	leave  
c01000e0:	c3                   	ret    

c01000e1 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e1:	55                   	push   %ebp
c01000e2:	89 e5                	mov    %esp,%ebp
c01000e4:	53                   	push   %ebx
c01000e5:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e8:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000ee:	8d 55 08             	lea    0x8(%ebp),%edx
c01000f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000fc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100100:	89 04 24             	mov    %eax,(%esp)
c0100103:	e8 b5 ff ff ff       	call   c01000bd <grade_backtrace2>
}
c0100108:	83 c4 14             	add    $0x14,%esp
c010010b:	5b                   	pop    %ebx
c010010c:	5d                   	pop    %ebp
c010010d:	c3                   	ret    

c010010e <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c010010e:	55                   	push   %ebp
c010010f:	89 e5                	mov    %esp,%ebp
c0100111:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100114:	8b 45 10             	mov    0x10(%ebp),%eax
c0100117:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011b:	8b 45 08             	mov    0x8(%ebp),%eax
c010011e:	89 04 24             	mov    %eax,(%esp)
c0100121:	e8 bb ff ff ff       	call   c01000e1 <grade_backtrace1>
}
c0100126:	c9                   	leave  
c0100127:	c3                   	ret    

c0100128 <grade_backtrace>:

void
grade_backtrace(void) {
c0100128:	55                   	push   %ebp
c0100129:	89 e5                	mov    %esp,%ebp
c010012b:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012e:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100133:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013a:	ff 
c010013b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100146:	e8 c3 ff ff ff       	call   c010010e <grade_backtrace0>
}
c010014b:	c9                   	leave  
c010014c:	c3                   	ret    

c010014d <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014d:	55                   	push   %ebp
c010014e:	89 e5                	mov    %esp,%ebp
c0100150:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100153:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100156:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100159:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010015c:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010015f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100163:	0f b7 c0             	movzwl %ax,%eax
c0100166:	83 e0 03             	and    $0x3,%eax
c0100169:	89 c2                	mov    %eax,%edx
c010016b:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c0100170:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100174:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100178:	c7 04 24 21 c0 10 c0 	movl   $0xc010c021,(%esp)
c010017f:	e8 db 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100184:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100188:	0f b7 d0             	movzwl %ax,%edx
c010018b:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 2f c0 10 c0 	movl   $0xc010c02f,(%esp)
c010019f:	e8 bb 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	0f b7 d0             	movzwl %ax,%edx
c01001ab:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c01001b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b8:	c7 04 24 3d c0 10 c0 	movl   $0xc010c03d,(%esp)
c01001bf:	e8 9b 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c8:	0f b7 d0             	movzwl %ax,%edx
c01001cb:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c01001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d8:	c7 04 24 4b c0 10 c0 	movl   $0xc010c04b,(%esp)
c01001df:	e8 7b 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e8:	0f b7 d0             	movzwl %ax,%edx
c01001eb:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c01001f0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f8:	c7 04 24 59 c0 10 c0 	movl   $0xc010c059,(%esp)
c01001ff:	e8 5b 01 00 00       	call   c010035f <cprintf>
    round ++;
c0100204:	a1 00 e0 19 c0       	mov    0xc019e000,%eax
c0100209:	83 c0 01             	add    $0x1,%eax
c010020c:	a3 00 e0 19 c0       	mov    %eax,0xc019e000
}
c0100211:	c9                   	leave  
c0100212:	c3                   	ret    

c0100213 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100213:	55                   	push   %ebp
c0100214:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100216:	5d                   	pop    %ebp
c0100217:	c3                   	ret    

c0100218 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100218:	55                   	push   %ebp
c0100219:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010021b:	5d                   	pop    %ebp
c010021c:	c3                   	ret    

c010021d <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021d:	55                   	push   %ebp
c010021e:	89 e5                	mov    %esp,%ebp
c0100220:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100223:	e8 25 ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100228:	c7 04 24 68 c0 10 c0 	movl   $0xc010c068,(%esp)
c010022f:	e8 2b 01 00 00       	call   c010035f <cprintf>
    lab1_switch_to_user();
c0100234:	e8 da ff ff ff       	call   c0100213 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100239:	e8 0f ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023e:	c7 04 24 88 c0 10 c0 	movl   $0xc010c088,(%esp)
c0100245:	e8 15 01 00 00       	call   c010035f <cprintf>
    lab1_switch_to_kernel();
c010024a:	e8 c9 ff ff ff       	call   c0100218 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010024f:	e8 f9 fe ff ff       	call   c010014d <lab1_print_cur_status>
}
c0100254:	c9                   	leave  
c0100255:	c3                   	ret    

c0100256 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100256:	55                   	push   %ebp
c0100257:	89 e5                	mov    %esp,%ebp
c0100259:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010025c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100260:	74 13                	je     c0100275 <readline+0x1f>
        cprintf("%s", prompt);
c0100262:	8b 45 08             	mov    0x8(%ebp),%eax
c0100265:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100269:	c7 04 24 a7 c0 10 c0 	movl   $0xc010c0a7,(%esp)
c0100270:	e8 ea 00 00 00       	call   c010035f <cprintf>
    }
    int i = 0, c;
c0100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010027c:	e8 66 01 00 00       	call   c01003e7 <getchar>
c0100281:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100284:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100288:	79 07                	jns    c0100291 <readline+0x3b>
            return NULL;
c010028a:	b8 00 00 00 00       	mov    $0x0,%eax
c010028f:	eb 79                	jmp    c010030a <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100291:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100295:	7e 28                	jle    c01002bf <readline+0x69>
c0100297:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010029e:	7f 1f                	jg     c01002bf <readline+0x69>
            cputchar(c);
c01002a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a3:	89 04 24             	mov    %eax,(%esp)
c01002a6:	e8 da 00 00 00       	call   c0100385 <cputchar>
            buf[i ++] = c;
c01002ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ae:	8d 50 01             	lea    0x1(%eax),%edx
c01002b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002b7:	88 90 20 e0 19 c0    	mov    %dl,-0x3fe61fe0(%eax)
c01002bd:	eb 46                	jmp    c0100305 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002bf:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002c3:	75 17                	jne    c01002dc <readline+0x86>
c01002c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c9:	7e 11                	jle    c01002dc <readline+0x86>
            cputchar(c);
c01002cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ce:	89 04 24             	mov    %eax,(%esp)
c01002d1:	e8 af 00 00 00       	call   c0100385 <cputchar>
            i --;
c01002d6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002da:	eb 29                	jmp    c0100305 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002dc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002e0:	74 06                	je     c01002e8 <readline+0x92>
c01002e2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002e6:	75 1d                	jne    c0100305 <readline+0xaf>
            cputchar(c);
c01002e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002eb:	89 04 24             	mov    %eax,(%esp)
c01002ee:	e8 92 00 00 00       	call   c0100385 <cputchar>
            buf[i] = '\0';
c01002f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002f6:	05 20 e0 19 c0       	add    $0xc019e020,%eax
c01002fb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002fe:	b8 20 e0 19 c0       	mov    $0xc019e020,%eax
c0100303:	eb 05                	jmp    c010030a <readline+0xb4>
        }
    }
c0100305:	e9 72 ff ff ff       	jmp    c010027c <readline+0x26>
}
c010030a:	c9                   	leave  
c010030b:	c3                   	ret    

c010030c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010030c:	55                   	push   %ebp
c010030d:	89 e5                	mov    %esp,%ebp
c010030f:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100312:	8b 45 08             	mov    0x8(%ebp),%eax
c0100315:	89 04 24             	mov    %eax,(%esp)
c0100318:	e8 11 14 00 00       	call   c010172e <cons_putc>
    (*cnt) ++;
c010031d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100320:	8b 00                	mov    (%eax),%eax
c0100322:	8d 50 01             	lea    0x1(%eax),%edx
c0100325:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100328:	89 10                	mov    %edx,(%eax)
}
c010032a:	c9                   	leave  
c010032b:	c3                   	ret    

c010032c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010032c:	55                   	push   %ebp
c010032d:	89 e5                	mov    %esp,%ebp
c010032f:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100332:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100339:	8b 45 0c             	mov    0xc(%ebp),%eax
c010033c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100340:	8b 45 08             	mov    0x8(%ebp),%eax
c0100343:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100347:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010034a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010034e:	c7 04 24 0c 03 10 c0 	movl   $0xc010030c,(%esp)
c0100355:	e8 40 b2 00 00       	call   c010b59a <vprintfmt>
    return cnt;
c010035a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010035d:	c9                   	leave  
c010035e:	c3                   	ret    

c010035f <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010035f:	55                   	push   %ebp
c0100360:	89 e5                	mov    %esp,%ebp
c0100362:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100365:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100368:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010036b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010036e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100372:	8b 45 08             	mov    0x8(%ebp),%eax
c0100375:	89 04 24             	mov    %eax,(%esp)
c0100378:	e8 af ff ff ff       	call   c010032c <vcprintf>
c010037d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100380:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100383:	c9                   	leave  
c0100384:	c3                   	ret    

c0100385 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100385:	55                   	push   %ebp
c0100386:	89 e5                	mov    %esp,%ebp
c0100388:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010038b:	8b 45 08             	mov    0x8(%ebp),%eax
c010038e:	89 04 24             	mov    %eax,(%esp)
c0100391:	e8 98 13 00 00       	call   c010172e <cons_putc>
}
c0100396:	c9                   	leave  
c0100397:	c3                   	ret    

c0100398 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100398:	55                   	push   %ebp
c0100399:	89 e5                	mov    %esp,%ebp
c010039b:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010039e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003a5:	eb 13                	jmp    c01003ba <cputs+0x22>
        cputch(c, &cnt);
c01003a7:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003ab:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003ae:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003b2:	89 04 24             	mov    %eax,(%esp)
c01003b5:	e8 52 ff ff ff       	call   c010030c <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01003bd:	8d 50 01             	lea    0x1(%eax),%edx
c01003c0:	89 55 08             	mov    %edx,0x8(%ebp)
c01003c3:	0f b6 00             	movzbl (%eax),%eax
c01003c6:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003cd:	75 d8                	jne    c01003a7 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003d6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003dd:	e8 2a ff ff ff       	call   c010030c <cputch>
    return cnt;
c01003e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003e5:	c9                   	leave  
c01003e6:	c3                   	ret    

c01003e7 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e7:	55                   	push   %ebp
c01003e8:	89 e5                	mov    %esp,%ebp
c01003ea:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003ed:	e8 78 13 00 00       	call   c010176a <cons_getc>
c01003f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f9:	74 f2                	je     c01003ed <getchar+0x6>
        /* do nothing */;
    return c;
c01003fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003fe:	c9                   	leave  
c01003ff:	c3                   	ret    

c0100400 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100400:	55                   	push   %ebp
c0100401:	89 e5                	mov    %esp,%ebp
c0100403:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100406:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100409:	8b 00                	mov    (%eax),%eax
c010040b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010040e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100411:	8b 00                	mov    (%eax),%eax
c0100413:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100416:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010041d:	e9 d2 00 00 00       	jmp    c01004f4 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c0100422:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100425:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100428:	01 d0                	add    %edx,%eax
c010042a:	89 c2                	mov    %eax,%edx
c010042c:	c1 ea 1f             	shr    $0x1f,%edx
c010042f:	01 d0                	add    %edx,%eax
c0100431:	d1 f8                	sar    %eax
c0100433:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100436:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100439:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043c:	eb 04                	jmp    c0100442 <stab_binsearch+0x42>
            m --;
c010043e:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100448:	7c 1f                	jl     c0100469 <stab_binsearch+0x69>
c010044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010044d:	89 d0                	mov    %edx,%eax
c010044f:	01 c0                	add    %eax,%eax
c0100451:	01 d0                	add    %edx,%eax
c0100453:	c1 e0 02             	shl    $0x2,%eax
c0100456:	89 c2                	mov    %eax,%edx
c0100458:	8b 45 08             	mov    0x8(%ebp),%eax
c010045b:	01 d0                	add    %edx,%eax
c010045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100461:	0f b6 c0             	movzbl %al,%eax
c0100464:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100467:	75 d5                	jne    c010043e <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010046f:	7d 0b                	jge    c010047c <stab_binsearch+0x7c>
            l = true_m + 1;
c0100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100474:	83 c0 01             	add    $0x1,%eax
c0100477:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010047a:	eb 78                	jmp    c01004f4 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c010047c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100483:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100486:	89 d0                	mov    %edx,%eax
c0100488:	01 c0                	add    %eax,%eax
c010048a:	01 d0                	add    %edx,%eax
c010048c:	c1 e0 02             	shl    $0x2,%eax
c010048f:	89 c2                	mov    %eax,%edx
c0100491:	8b 45 08             	mov    0x8(%ebp),%eax
c0100494:	01 d0                	add    %edx,%eax
c0100496:	8b 40 08             	mov    0x8(%eax),%eax
c0100499:	3b 45 18             	cmp    0x18(%ebp),%eax
c010049c:	73 13                	jae    c01004b1 <stab_binsearch+0xb1>
            *region_left = m;
c010049e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a4:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a9:	83 c0 01             	add    $0x1,%eax
c01004ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004af:	eb 43                	jmp    c01004f4 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b4:	89 d0                	mov    %edx,%eax
c01004b6:	01 c0                	add    %eax,%eax
c01004b8:	01 d0                	add    %edx,%eax
c01004ba:	c1 e0 02             	shl    $0x2,%eax
c01004bd:	89 c2                	mov    %eax,%edx
c01004bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01004c2:	01 d0                	add    %edx,%eax
c01004c4:	8b 40 08             	mov    0x8(%eax),%eax
c01004c7:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004ca:	76 16                	jbe    c01004e2 <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004cf:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d5:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004da:	83 e8 01             	sub    $0x1,%eax
c01004dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e0:	eb 12                	jmp    c01004f4 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e8:	89 10                	mov    %edx,(%eax)
            l = m;
c01004ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004f0:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004fa:	0f 8e 22 ff ff ff    	jle    c0100422 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c0100500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100504:	75 0f                	jne    c0100515 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c0100506:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100509:	8b 00                	mov    (%eax),%eax
c010050b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	89 10                	mov    %edx,(%eax)
c0100513:	eb 3f                	jmp    c0100554 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0100515:	8b 45 10             	mov    0x10(%ebp),%eax
c0100518:	8b 00                	mov    (%eax),%eax
c010051a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c010051d:	eb 04                	jmp    c0100523 <stab_binsearch+0x123>
c010051f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100523:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100526:	8b 00                	mov    (%eax),%eax
c0100528:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010052b:	7d 1f                	jge    c010054c <stab_binsearch+0x14c>
c010052d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100530:	89 d0                	mov    %edx,%eax
c0100532:	01 c0                	add    %eax,%eax
c0100534:	01 d0                	add    %edx,%eax
c0100536:	c1 e0 02             	shl    $0x2,%eax
c0100539:	89 c2                	mov    %eax,%edx
c010053b:	8b 45 08             	mov    0x8(%ebp),%eax
c010053e:	01 d0                	add    %edx,%eax
c0100540:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100544:	0f b6 c0             	movzbl %al,%eax
c0100547:	3b 45 14             	cmp    0x14(%ebp),%eax
c010054a:	75 d3                	jne    c010051f <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c010054c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010054f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100552:	89 10                	mov    %edx,(%eax)
    }
}
c0100554:	c9                   	leave  
c0100555:	c3                   	ret    

c0100556 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100556:	55                   	push   %ebp
c0100557:	89 e5                	mov    %esp,%ebp
c0100559:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010055c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055f:	c7 00 ac c0 10 c0    	movl   $0xc010c0ac,(%eax)
    info->eip_line = 0;
c0100565:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100568:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010056f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100572:	c7 40 08 ac c0 10 c0 	movl   $0xc010c0ac,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100583:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100586:	8b 55 08             	mov    0x8(%ebp),%edx
c0100589:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010058c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c0100596:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c010059d:	76 21                	jbe    c01005c0 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c010059f:	c7 45 f4 40 e8 10 c0 	movl   $0xc010e840,-0xc(%ebp)
        stab_end = __STAB_END__;
c01005a6:	c7 45 f0 64 2c 12 c0 	movl   $0xc0122c64,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01005ad:	c7 45 ec 65 2c 12 c0 	movl   $0xc0122c65,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005b4:	c7 45 e8 65 79 12 c0 	movl   $0xc0127965,-0x18(%ebp)
c01005bb:	e9 ea 00 00 00       	jmp    c01006aa <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005c0:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005c7:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c01005cc:	85 c0                	test   %eax,%eax
c01005ce:	74 11                	je     c01005e1 <debuginfo_eip+0x8b>
c01005d0:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c01005d5:	8b 40 18             	mov    0x18(%eax),%eax
c01005d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005df:	75 0a                	jne    c01005eb <debuginfo_eip+0x95>
            return -1;
c01005e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005e6:	e9 9e 03 00 00       	jmp    c0100989 <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01005eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005ee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01005f5:	00 
c01005f6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01005fd:	00 
c01005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100602:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100605:	89 04 24             	mov    %eax,(%esp)
c0100608:	e8 3a 8b 00 00       	call   c0109147 <user_mem_check>
c010060d:	85 c0                	test   %eax,%eax
c010060f:	75 0a                	jne    c010061b <debuginfo_eip+0xc5>
            return -1;
c0100611:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100616:	e9 6e 03 00 00       	jmp    c0100989 <debuginfo_eip+0x433>
        }

        stabs = usd->stabs;
c010061b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010061e:	8b 00                	mov    (%eax),%eax
c0100620:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c0100623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100626:	8b 40 04             	mov    0x4(%eax),%eax
c0100629:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c010062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010062f:	8b 40 08             	mov    0x8(%eax),%eax
c0100632:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100638:	8b 40 0c             	mov    0xc(%eax),%eax
c010063b:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c010063e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100641:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100644:	29 c2                	sub    %eax,%edx
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100650:	00 
c0100651:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100655:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100659:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010065c:	89 04 24             	mov    %eax,(%esp)
c010065f:	e8 e3 8a 00 00       	call   c0109147 <user_mem_check>
c0100664:	85 c0                	test   %eax,%eax
c0100666:	75 0a                	jne    c0100672 <debuginfo_eip+0x11c>
            return -1;
c0100668:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010066d:	e9 17 03 00 00       	jmp    c0100989 <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100672:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100675:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100678:	29 c2                	sub    %eax,%edx
c010067a:	89 d0                	mov    %edx,%eax
c010067c:	89 c2                	mov    %eax,%edx
c010067e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100681:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100688:	00 
c0100689:	89 54 24 08          	mov    %edx,0x8(%esp)
c010068d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100691:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100694:	89 04 24             	mov    %eax,(%esp)
c0100697:	e8 ab 8a 00 00       	call   c0109147 <user_mem_check>
c010069c:	85 c0                	test   %eax,%eax
c010069e:	75 0a                	jne    c01006aa <debuginfo_eip+0x154>
            return -1;
c01006a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006a5:	e9 df 02 00 00       	jmp    c0100989 <debuginfo_eip+0x433>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006ad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006b0:	76 0d                	jbe    c01006bf <debuginfo_eip+0x169>
c01006b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006b5:	83 e8 01             	sub    $0x1,%eax
c01006b8:	0f b6 00             	movzbl (%eax),%eax
c01006bb:	84 c0                	test   %al,%al
c01006bd:	74 0a                	je     c01006c9 <debuginfo_eip+0x173>
        return -1;
c01006bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006c4:	e9 c0 02 00 00       	jmp    c0100989 <debuginfo_eip+0x433>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006c9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01006d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d6:	29 c2                	sub    %eax,%edx
c01006d8:	89 d0                	mov    %edx,%eax
c01006da:	c1 f8 02             	sar    $0x2,%eax
c01006dd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006e3:	83 e8 01             	sub    $0x1,%eax
c01006e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01006ec:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f0:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006f7:	00 
c01006f8:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006ff:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100702:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100709:	89 04 24             	mov    %eax,(%esp)
c010070c:	e8 ef fc ff ff       	call   c0100400 <stab_binsearch>
    if (lfile == 0)
c0100711:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100714:	85 c0                	test   %eax,%eax
c0100716:	75 0a                	jne    c0100722 <debuginfo_eip+0x1cc>
        return -1;
c0100718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010071d:	e9 67 02 00 00       	jmp    c0100989 <debuginfo_eip+0x433>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100722:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100725:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100728:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010072b:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010072e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100731:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100735:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010073c:	00 
c010073d:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100740:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100744:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100747:	89 44 24 04          	mov    %eax,0x4(%esp)
c010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074e:	89 04 24             	mov    %eax,(%esp)
c0100751:	e8 aa fc ff ff       	call   c0100400 <stab_binsearch>

    if (lfun <= rfun) {
c0100756:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100759:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010075c:	39 c2                	cmp    %eax,%edx
c010075e:	7f 7c                	jg     c01007dc <debuginfo_eip+0x286>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100760:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100763:	89 c2                	mov    %eax,%edx
c0100765:	89 d0                	mov    %edx,%eax
c0100767:	01 c0                	add    %eax,%eax
c0100769:	01 d0                	add    %edx,%eax
c010076b:	c1 e0 02             	shl    $0x2,%eax
c010076e:	89 c2                	mov    %eax,%edx
c0100770:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100773:	01 d0                	add    %edx,%eax
c0100775:	8b 10                	mov    (%eax),%edx
c0100777:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010077a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010077d:	29 c1                	sub    %eax,%ecx
c010077f:	89 c8                	mov    %ecx,%eax
c0100781:	39 c2                	cmp    %eax,%edx
c0100783:	73 22                	jae    c01007a7 <debuginfo_eip+0x251>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100785:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100788:	89 c2                	mov    %eax,%edx
c010078a:	89 d0                	mov    %edx,%eax
c010078c:	01 c0                	add    %eax,%eax
c010078e:	01 d0                	add    %edx,%eax
c0100790:	c1 e0 02             	shl    $0x2,%eax
c0100793:	89 c2                	mov    %eax,%edx
c0100795:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100798:	01 d0                	add    %edx,%eax
c010079a:	8b 10                	mov    (%eax),%edx
c010079c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010079f:	01 c2                	add    %eax,%edx
c01007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a4:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007aa:	89 c2                	mov    %eax,%edx
c01007ac:	89 d0                	mov    %edx,%eax
c01007ae:	01 c0                	add    %eax,%eax
c01007b0:	01 d0                	add    %edx,%eax
c01007b2:	c1 e0 02             	shl    $0x2,%eax
c01007b5:	89 c2                	mov    %eax,%edx
c01007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ba:	01 d0                	add    %edx,%eax
c01007bc:	8b 50 08             	mov    0x8(%eax),%edx
c01007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c2:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c8:	8b 40 10             	mov    0x10(%eax),%eax
c01007cb:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01007d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007d7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01007da:	eb 15                	jmp    c01007f1 <debuginfo_eip+0x29b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007df:	8b 55 08             	mov    0x8(%ebp),%edx
c01007e2:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007e8:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01007eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007f4:	8b 40 08             	mov    0x8(%eax),%eax
c01007f7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007fe:	00 
c01007ff:	89 04 24             	mov    %eax,(%esp)
c0100802:	e8 c6 b4 00 00       	call   c010bccd <strfind>
c0100807:	89 c2                	mov    %eax,%edx
c0100809:	8b 45 0c             	mov    0xc(%ebp),%eax
c010080c:	8b 40 08             	mov    0x8(%eax),%eax
c010080f:	29 c2                	sub    %eax,%edx
c0100811:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100814:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100817:	8b 45 08             	mov    0x8(%ebp),%eax
c010081a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010081e:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100825:	00 
c0100826:	8d 45 c8             	lea    -0x38(%ebp),%eax
c0100829:	89 44 24 08          	mov    %eax,0x8(%esp)
c010082d:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100830:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100834:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100837:	89 04 24             	mov    %eax,(%esp)
c010083a:	e8 c1 fb ff ff       	call   c0100400 <stab_binsearch>
    if (lline <= rline) {
c010083f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100842:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100845:	39 c2                	cmp    %eax,%edx
c0100847:	7f 24                	jg     c010086d <debuginfo_eip+0x317>
        info->eip_line = stabs[rline].n_desc;
c0100849:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010084c:	89 c2                	mov    %eax,%edx
c010084e:	89 d0                	mov    %edx,%eax
c0100850:	01 c0                	add    %eax,%eax
c0100852:	01 d0                	add    %edx,%eax
c0100854:	c1 e0 02             	shl    $0x2,%eax
c0100857:	89 c2                	mov    %eax,%edx
c0100859:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085c:	01 d0                	add    %edx,%eax
c010085e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100862:	0f b7 d0             	movzwl %ax,%edx
c0100865:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100868:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010086b:	eb 13                	jmp    c0100880 <debuginfo_eip+0x32a>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010086d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100872:	e9 12 01 00 00       	jmp    c0100989 <debuginfo_eip+0x433>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100877:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010087a:	83 e8 01             	sub    $0x1,%eax
c010087d:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100880:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100883:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100886:	39 c2                	cmp    %eax,%edx
c0100888:	7c 56                	jl     c01008e0 <debuginfo_eip+0x38a>
           && stabs[lline].n_type != N_SOL
c010088a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010088d:	89 c2                	mov    %eax,%edx
c010088f:	89 d0                	mov    %edx,%eax
c0100891:	01 c0                	add    %eax,%eax
c0100893:	01 d0                	add    %edx,%eax
c0100895:	c1 e0 02             	shl    $0x2,%eax
c0100898:	89 c2                	mov    %eax,%edx
c010089a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010089d:	01 d0                	add    %edx,%eax
c010089f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008a3:	3c 84                	cmp    $0x84,%al
c01008a5:	74 39                	je     c01008e0 <debuginfo_eip+0x38a>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008aa:	89 c2                	mov    %eax,%edx
c01008ac:	89 d0                	mov    %edx,%eax
c01008ae:	01 c0                	add    %eax,%eax
c01008b0:	01 d0                	add    %edx,%eax
c01008b2:	c1 e0 02             	shl    $0x2,%eax
c01008b5:	89 c2                	mov    %eax,%edx
c01008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ba:	01 d0                	add    %edx,%eax
c01008bc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008c0:	3c 64                	cmp    $0x64,%al
c01008c2:	75 b3                	jne    c0100877 <debuginfo_eip+0x321>
c01008c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008c7:	89 c2                	mov    %eax,%edx
c01008c9:	89 d0                	mov    %edx,%eax
c01008cb:	01 c0                	add    %eax,%eax
c01008cd:	01 d0                	add    %edx,%eax
c01008cf:	c1 e0 02             	shl    $0x2,%eax
c01008d2:	89 c2                	mov    %eax,%edx
c01008d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d7:	01 d0                	add    %edx,%eax
c01008d9:	8b 40 08             	mov    0x8(%eax),%eax
c01008dc:	85 c0                	test   %eax,%eax
c01008de:	74 97                	je     c0100877 <debuginfo_eip+0x321>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008e0:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008e6:	39 c2                	cmp    %eax,%edx
c01008e8:	7c 46                	jl     c0100930 <debuginfo_eip+0x3da>
c01008ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008ed:	89 c2                	mov    %eax,%edx
c01008ef:	89 d0                	mov    %edx,%eax
c01008f1:	01 c0                	add    %eax,%eax
c01008f3:	01 d0                	add    %edx,%eax
c01008f5:	c1 e0 02             	shl    $0x2,%eax
c01008f8:	89 c2                	mov    %eax,%edx
c01008fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008fd:	01 d0                	add    %edx,%eax
c01008ff:	8b 10                	mov    (%eax),%edx
c0100901:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100904:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100907:	29 c1                	sub    %eax,%ecx
c0100909:	89 c8                	mov    %ecx,%eax
c010090b:	39 c2                	cmp    %eax,%edx
c010090d:	73 21                	jae    c0100930 <debuginfo_eip+0x3da>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010090f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100912:	89 c2                	mov    %eax,%edx
c0100914:	89 d0                	mov    %edx,%eax
c0100916:	01 c0                	add    %eax,%eax
c0100918:	01 d0                	add    %edx,%eax
c010091a:	c1 e0 02             	shl    $0x2,%eax
c010091d:	89 c2                	mov    %eax,%edx
c010091f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100922:	01 d0                	add    %edx,%eax
c0100924:	8b 10                	mov    (%eax),%edx
c0100926:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100929:	01 c2                	add    %eax,%edx
c010092b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010092e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100930:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100933:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100936:	39 c2                	cmp    %eax,%edx
c0100938:	7d 4a                	jge    c0100984 <debuginfo_eip+0x42e>
        for (lline = lfun + 1;
c010093a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010093d:	83 c0 01             	add    $0x1,%eax
c0100940:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100943:	eb 18                	jmp    c010095d <debuginfo_eip+0x407>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100945:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100948:	8b 40 14             	mov    0x14(%eax),%eax
c010094b:	8d 50 01             	lea    0x1(%eax),%edx
c010094e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100951:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100954:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100957:	83 c0 01             	add    $0x1,%eax
c010095a:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100960:	8b 45 d0             	mov    -0x30(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100963:	39 c2                	cmp    %eax,%edx
c0100965:	7d 1d                	jge    c0100984 <debuginfo_eip+0x42e>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100967:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010096a:	89 c2                	mov    %eax,%edx
c010096c:	89 d0                	mov    %edx,%eax
c010096e:	01 c0                	add    %eax,%eax
c0100970:	01 d0                	add    %edx,%eax
c0100972:	c1 e0 02             	shl    $0x2,%eax
c0100975:	89 c2                	mov    %eax,%edx
c0100977:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097a:	01 d0                	add    %edx,%eax
c010097c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100980:	3c a0                	cmp    $0xa0,%al
c0100982:	74 c1                	je     c0100945 <debuginfo_eip+0x3ef>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100984:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100989:	c9                   	leave  
c010098a:	c3                   	ret    

c010098b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010098b:	55                   	push   %ebp
c010098c:	89 e5                	mov    %esp,%ebp
c010098e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100991:	c7 04 24 b6 c0 10 c0 	movl   $0xc010c0b6,(%esp)
c0100998:	e8 c2 f9 ff ff       	call   c010035f <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010099d:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009a4:	c0 
c01009a5:	c7 04 24 cf c0 10 c0 	movl   $0xc010c0cf,(%esp)
c01009ac:	e8 ae f9 ff ff       	call   c010035f <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009b1:	c7 44 24 04 e2 bf 10 	movl   $0xc010bfe2,0x4(%esp)
c01009b8:	c0 
c01009b9:	c7 04 24 e7 c0 10 c0 	movl   $0xc010c0e7,(%esp)
c01009c0:	e8 9a f9 ff ff       	call   c010035f <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009c5:	c7 44 24 04 00 e0 19 	movl   $0xc019e000,0x4(%esp)
c01009cc:	c0 
c01009cd:	c7 04 24 ff c0 10 c0 	movl   $0xc010c0ff,(%esp)
c01009d4:	e8 86 f9 ff ff       	call   c010035f <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009d9:	c7 44 24 04 d8 11 1a 	movl   $0xc01a11d8,0x4(%esp)
c01009e0:	c0 
c01009e1:	c7 04 24 17 c1 10 c0 	movl   $0xc010c117,(%esp)
c01009e8:	e8 72 f9 ff ff       	call   c010035f <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009ed:	b8 d8 11 1a c0       	mov    $0xc01a11d8,%eax
c01009f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009f8:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009fd:	29 c2                	sub    %eax,%edx
c01009ff:	89 d0                	mov    %edx,%eax
c0100a01:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a07:	85 c0                	test   %eax,%eax
c0100a09:	0f 48 c2             	cmovs  %edx,%eax
c0100a0c:	c1 f8 0a             	sar    $0xa,%eax
c0100a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a13:	c7 04 24 30 c1 10 c0 	movl   $0xc010c130,(%esp)
c0100a1a:	e8 40 f9 ff ff       	call   c010035f <cprintf>
}
c0100a1f:	c9                   	leave  
c0100a20:	c3                   	ret    

c0100a21 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a21:	55                   	push   %ebp
c0100a22:	89 e5                	mov    %esp,%ebp
c0100a24:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a2a:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a31:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a34:	89 04 24             	mov    %eax,(%esp)
c0100a37:	e8 1a fb ff ff       	call   c0100556 <debuginfo_eip>
c0100a3c:	85 c0                	test   %eax,%eax
c0100a3e:	74 15                	je     c0100a55 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a47:	c7 04 24 5a c1 10 c0 	movl   $0xc010c15a,(%esp)
c0100a4e:	e8 0c f9 ff ff       	call   c010035f <cprintf>
c0100a53:	eb 6d                	jmp    c0100ac2 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a5c:	eb 1c                	jmp    c0100a7a <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a64:	01 d0                	add    %edx,%eax
c0100a66:	0f b6 00             	movzbl (%eax),%eax
c0100a69:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a72:	01 ca                	add    %ecx,%edx
c0100a74:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a76:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a7d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a80:	7f dc                	jg     c0100a5e <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a82:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a8b:	01 d0                	add    %edx,%eax
c0100a8d:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a90:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a93:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a96:	89 d1                	mov    %edx,%ecx
c0100a98:	29 c1                	sub    %eax,%ecx
c0100a9a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100aa0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100aa4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aaa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aae:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab6:	c7 04 24 76 c1 10 c0 	movl   $0xc010c176,(%esp)
c0100abd:	e8 9d f8 ff ff       	call   c010035f <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100ac2:	c9                   	leave  
c0100ac3:	c3                   	ret    

c0100ac4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ac4:	55                   	push   %ebp
c0100ac5:	89 e5                	mov    %esp,%ebp
c0100ac7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100aca:	8b 45 04             	mov    0x4(%ebp),%eax
c0100acd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ad0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ad3:	c9                   	leave  
c0100ad4:	c3                   	ret    

c0100ad5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ad5:	55                   	push   %ebp
c0100ad6:	89 e5                	mov    %esp,%ebp
c0100ad8:	53                   	push   %ebx
c0100ad9:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100adc:	89 e8                	mov    %ebp,%eax
c0100ade:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c0100ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
c0100ae7:	e8 d8 ff ff ff       	call   c0100ac4 <read_eip>
c0100aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100aef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100af6:	e9 8d 00 00 00       	jmp    c0100b88 <print_stackframe+0xb3>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c0100afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100afe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b09:	c7 04 24 88 c1 10 c0 	movl   $0xc010c188,(%esp)
c0100b10:	e8 4a f8 ff ff       	call   c010035f <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
c0100b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b18:	83 c0 08             	add    $0x8,%eax
c0100b1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("0x%08x 0x%08x 0x%08x 0x%08x",*args,*(args+1),*(args+2),*(args+3));
c0100b1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b21:	83 c0 0c             	add    $0xc,%eax
c0100b24:	8b 18                	mov    (%eax),%ebx
c0100b26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b29:	83 c0 08             	add    $0x8,%eax
c0100b2c:	8b 08                	mov    (%eax),%ecx
c0100b2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b31:	83 c0 04             	add    $0x4,%eax
c0100b34:	8b 10                	mov    (%eax),%edx
c0100b36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b39:	8b 00                	mov    (%eax),%eax
c0100b3b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100b3f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b43:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4b:	c7 04 24 a4 c1 10 c0 	movl   $0xc010c1a4,(%esp)
c0100b52:	e8 08 f8 ff ff       	call   c010035f <cprintf>
		cprintf("\n");
c0100b57:	c7 04 24 c0 c1 10 c0 	movl   $0xc010c1c0,(%esp)
c0100b5e:	e8 fc f7 ff ff       	call   c010035f <cprintf>
		print_debuginfo(eip-1);
c0100b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b66:	83 e8 01             	sub    $0x1,%eax
c0100b69:	89 04 24             	mov    %eax,(%esp)
c0100b6c:	e8 b0 fe ff ff       	call   c0100a21 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b74:	83 c0 04             	add    $0x4,%eax
c0100b77:	8b 00                	mov    (%eax),%eax
c0100b79:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
c0100b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b7f:	8b 00                	mov    (%eax),%eax
c0100b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100b84:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b8c:	74 0a                	je     c0100b98 <print_stackframe+0xc3>
c0100b8e:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b92:	0f 8e 63 ff ff ff    	jle    c0100afb <print_stackframe+0x26>
		cprintf("\n");
		print_debuginfo(eip-1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
c0100b98:	83 c4 44             	add    $0x44,%esp
c0100b9b:	5b                   	pop    %ebx
c0100b9c:	5d                   	pop    %ebp
c0100b9d:	c3                   	ret    

c0100b9e <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b9e:	55                   	push   %ebp
c0100b9f:	89 e5                	mov    %esp,%ebp
c0100ba1:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ba4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bab:	eb 0c                	jmp    c0100bb9 <parse+0x1b>
            *buf ++ = '\0';
c0100bad:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb0:	8d 50 01             	lea    0x1(%eax),%edx
c0100bb3:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bb6:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbc:	0f b6 00             	movzbl (%eax),%eax
c0100bbf:	84 c0                	test   %al,%al
c0100bc1:	74 1d                	je     c0100be0 <parse+0x42>
c0100bc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc6:	0f b6 00             	movzbl (%eax),%eax
c0100bc9:	0f be c0             	movsbl %al,%eax
c0100bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd0:	c7 04 24 44 c2 10 c0 	movl   $0xc010c244,(%esp)
c0100bd7:	e8 be b0 00 00       	call   c010bc9a <strchr>
c0100bdc:	85 c0                	test   %eax,%eax
c0100bde:	75 cd                	jne    c0100bad <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be3:	0f b6 00             	movzbl (%eax),%eax
c0100be6:	84 c0                	test   %al,%al
c0100be8:	75 02                	jne    c0100bec <parse+0x4e>
            break;
c0100bea:	eb 67                	jmp    c0100c53 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bec:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bf0:	75 14                	jne    c0100c06 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bf2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bf9:	00 
c0100bfa:	c7 04 24 49 c2 10 c0 	movl   $0xc010c249,(%esp)
c0100c01:	e8 59 f7 ff ff       	call   c010035f <cprintf>
        }
        argv[argc ++] = buf;
c0100c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c09:	8d 50 01             	lea    0x1(%eax),%edx
c0100c0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c19:	01 c2                	add    %eax,%edx
c0100c1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1e:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c20:	eb 04                	jmp    c0100c26 <parse+0x88>
            buf ++;
c0100c22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c26:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c29:	0f b6 00             	movzbl (%eax),%eax
c0100c2c:	84 c0                	test   %al,%al
c0100c2e:	74 1d                	je     c0100c4d <parse+0xaf>
c0100c30:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c33:	0f b6 00             	movzbl (%eax),%eax
c0100c36:	0f be c0             	movsbl %al,%eax
c0100c39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3d:	c7 04 24 44 c2 10 c0 	movl   $0xc010c244,(%esp)
c0100c44:	e8 51 b0 00 00       	call   c010bc9a <strchr>
c0100c49:	85 c0                	test   %eax,%eax
c0100c4b:	74 d5                	je     c0100c22 <parse+0x84>
            buf ++;
        }
    }
c0100c4d:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c4e:	e9 66 ff ff ff       	jmp    c0100bb9 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c56:	c9                   	leave  
c0100c57:	c3                   	ret    

c0100c58 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c58:	55                   	push   %ebp
c0100c59:	89 e5                	mov    %esp,%ebp
c0100c5b:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c5e:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c65:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c68:	89 04 24             	mov    %eax,(%esp)
c0100c6b:	e8 2e ff ff ff       	call   c0100b9e <parse>
c0100c70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c77:	75 0a                	jne    c0100c83 <runcmd+0x2b>
        return 0;
c0100c79:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c7e:	e9 85 00 00 00       	jmp    c0100d08 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c8a:	eb 5c                	jmp    c0100ce8 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c8c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c92:	89 d0                	mov    %edx,%eax
c0100c94:	01 c0                	add    %eax,%eax
c0100c96:	01 d0                	add    %edx,%eax
c0100c98:	c1 e0 02             	shl    $0x2,%eax
c0100c9b:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100ca0:	8b 00                	mov    (%eax),%eax
c0100ca2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ca6:	89 04 24             	mov    %eax,(%esp)
c0100ca9:	e8 4d af 00 00       	call   c010bbfb <strcmp>
c0100cae:	85 c0                	test   %eax,%eax
c0100cb0:	75 32                	jne    c0100ce4 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cb5:	89 d0                	mov    %edx,%eax
c0100cb7:	01 c0                	add    %eax,%eax
c0100cb9:	01 d0                	add    %edx,%eax
c0100cbb:	c1 e0 02             	shl    $0x2,%eax
c0100cbe:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100cc3:	8b 40 08             	mov    0x8(%eax),%eax
c0100cc6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100cc9:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100ccc:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100ccf:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cd3:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100cd6:	83 c2 04             	add    $0x4,%edx
c0100cd9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100cdd:	89 0c 24             	mov    %ecx,(%esp)
c0100ce0:	ff d0                	call   *%eax
c0100ce2:	eb 24                	jmp    c0100d08 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ce4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ceb:	83 f8 02             	cmp    $0x2,%eax
c0100cee:	76 9c                	jbe    c0100c8c <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cf0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf7:	c7 04 24 67 c2 10 c0 	movl   $0xc010c267,(%esp)
c0100cfe:	e8 5c f6 ff ff       	call   c010035f <cprintf>
    return 0;
c0100d03:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d08:	c9                   	leave  
c0100d09:	c3                   	ret    

c0100d0a <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d0a:	55                   	push   %ebp
c0100d0b:	89 e5                	mov    %esp,%ebp
c0100d0d:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d10:	c7 04 24 80 c2 10 c0 	movl   $0xc010c280,(%esp)
c0100d17:	e8 43 f6 ff ff       	call   c010035f <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d1c:	c7 04 24 a8 c2 10 c0 	movl   $0xc010c2a8,(%esp)
c0100d23:	e8 37 f6 ff ff       	call   c010035f <cprintf>

    if (tf != NULL) {
c0100d28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d2c:	74 0b                	je     c0100d39 <kmonitor+0x2f>
        print_trapframe(tf);
c0100d2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d31:	89 04 24             	mov    %eax,(%esp)
c0100d34:	e8 d9 16 00 00       	call   c0102412 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d39:	c7 04 24 cd c2 10 c0 	movl   $0xc010c2cd,(%esp)
c0100d40:	e8 11 f5 ff ff       	call   c0100256 <readline>
c0100d45:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d4c:	74 18                	je     c0100d66 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d58:	89 04 24             	mov    %eax,(%esp)
c0100d5b:	e8 f8 fe ff ff       	call   c0100c58 <runcmd>
c0100d60:	85 c0                	test   %eax,%eax
c0100d62:	79 02                	jns    c0100d66 <kmonitor+0x5c>
                break;
c0100d64:	eb 02                	jmp    c0100d68 <kmonitor+0x5e>
            }
        }
    }
c0100d66:	eb d1                	jmp    c0100d39 <kmonitor+0x2f>
}
c0100d68:	c9                   	leave  
c0100d69:	c3                   	ret    

c0100d6a <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d6a:	55                   	push   %ebp
c0100d6b:	89 e5                	mov    %esp,%ebp
c0100d6d:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d77:	eb 3f                	jmp    c0100db8 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d79:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d7c:	89 d0                	mov    %edx,%eax
c0100d7e:	01 c0                	add    %eax,%eax
c0100d80:	01 d0                	add    %edx,%eax
c0100d82:	c1 e0 02             	shl    $0x2,%eax
c0100d85:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100d8a:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d90:	89 d0                	mov    %edx,%eax
c0100d92:	01 c0                	add    %eax,%eax
c0100d94:	01 d0                	add    %edx,%eax
c0100d96:	c1 e0 02             	shl    $0x2,%eax
c0100d99:	05 00 a0 12 c0       	add    $0xc012a000,%eax
c0100d9e:	8b 00                	mov    (%eax),%eax
c0100da0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100da4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100da8:	c7 04 24 d1 c2 10 c0 	movl   $0xc010c2d1,(%esp)
c0100daf:	e8 ab f5 ff ff       	call   c010035f <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100db4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dbb:	83 f8 02             	cmp    $0x2,%eax
c0100dbe:	76 b9                	jbe    c0100d79 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dc5:	c9                   	leave  
c0100dc6:	c3                   	ret    

c0100dc7 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100dc7:	55                   	push   %ebp
c0100dc8:	89 e5                	mov    %esp,%ebp
c0100dca:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100dcd:	e8 b9 fb ff ff       	call   c010098b <print_kerninfo>
    return 0;
c0100dd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd7:	c9                   	leave  
c0100dd8:	c3                   	ret    

c0100dd9 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dd9:	55                   	push   %ebp
c0100dda:	89 e5                	mov    %esp,%ebp
c0100ddc:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ddf:	e8 f1 fc ff ff       	call   c0100ad5 <print_stackframe>
    return 0;
c0100de4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100de9:	c9                   	leave  
c0100dea:	c3                   	ret    

c0100deb <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100deb:	55                   	push   %ebp
c0100dec:	89 e5                	mov    %esp,%ebp
c0100dee:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100df1:	a1 20 e4 19 c0       	mov    0xc019e420,%eax
c0100df6:	85 c0                	test   %eax,%eax
c0100df8:	74 02                	je     c0100dfc <__panic+0x11>
        goto panic_dead;
c0100dfa:	eb 59                	jmp    c0100e55 <__panic+0x6a>
    }
    is_panic = 1;
c0100dfc:	c7 05 20 e4 19 c0 01 	movl   $0x1,0xc019e420
c0100e03:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100e06:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e0f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e13:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e1a:	c7 04 24 da c2 10 c0 	movl   $0xc010c2da,(%esp)
c0100e21:	e8 39 f5 ff ff       	call   c010035f <cprintf>
    vcprintf(fmt, ap);
c0100e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e2d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e30:	89 04 24             	mov    %eax,(%esp)
c0100e33:	e8 f4 f4 ff ff       	call   c010032c <vcprintf>
    cprintf("\n");
c0100e38:	c7 04 24 f6 c2 10 c0 	movl   $0xc010c2f6,(%esp)
c0100e3f:	e8 1b f5 ff ff       	call   c010035f <cprintf>
    
    cprintf("stack trackback:\n");
c0100e44:	c7 04 24 f8 c2 10 c0 	movl   $0xc010c2f8,(%esp)
c0100e4b:	e8 0f f5 ff ff       	call   c010035f <cprintf>
    print_stackframe();
c0100e50:	e8 80 fc ff ff       	call   c0100ad5 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100e55:	e8 fa 11 00 00       	call   c0102054 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100e5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e61:	e8 a4 fe ff ff       	call   c0100d0a <kmonitor>
    }
c0100e66:	eb f2                	jmp    c0100e5a <__panic+0x6f>

c0100e68 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e68:	55                   	push   %ebp
c0100e69:	89 e5                	mov    %esp,%ebp
c0100e6b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e6e:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e74:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e77:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e82:	c7 04 24 0a c3 10 c0 	movl   $0xc010c30a,(%esp)
c0100e89:	e8 d1 f4 ff ff       	call   c010035f <cprintf>
    vcprintf(fmt, ap);
c0100e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e95:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e98:	89 04 24             	mov    %eax,(%esp)
c0100e9b:	e8 8c f4 ff ff       	call   c010032c <vcprintf>
    cprintf("\n");
c0100ea0:	c7 04 24 f6 c2 10 c0 	movl   $0xc010c2f6,(%esp)
c0100ea7:	e8 b3 f4 ff ff       	call   c010035f <cprintf>
    va_end(ap);
}
c0100eac:	c9                   	leave  
c0100ead:	c3                   	ret    

c0100eae <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100eae:	55                   	push   %ebp
c0100eaf:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100eb1:	a1 20 e4 19 c0       	mov    0xc019e420,%eax
}
c0100eb6:	5d                   	pop    %ebp
c0100eb7:	c3                   	ret    

c0100eb8 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100eb8:	55                   	push   %ebp
c0100eb9:	89 e5                	mov    %esp,%ebp
c0100ebb:	83 ec 28             	sub    $0x28,%esp
c0100ebe:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100ec4:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ec8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ecc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ed0:	ee                   	out    %al,(%dx)
c0100ed1:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100ed7:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100edb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100edf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ee3:	ee                   	out    %al,(%dx)
c0100ee4:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100eea:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100eee:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ef2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ef6:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100ef7:	c7 05 74 10 1a c0 00 	movl   $0x0,0xc01a1074
c0100efe:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100f01:	c7 04 24 28 c3 10 c0 	movl   $0xc010c328,(%esp)
c0100f08:	e8 52 f4 ff ff       	call   c010035f <cprintf>
    pic_enable(IRQ_TIMER);
c0100f0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100f14:	e8 99 11 00 00       	call   c01020b2 <pic_enable>
}
c0100f19:	c9                   	leave  
c0100f1a:	c3                   	ret    

c0100f1b <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100f1b:	55                   	push   %ebp
c0100f1c:	89 e5                	mov    %esp,%ebp
c0100f1e:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100f21:	9c                   	pushf  
c0100f22:	58                   	pop    %eax
c0100f23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100f29:	25 00 02 00 00       	and    $0x200,%eax
c0100f2e:	85 c0                	test   %eax,%eax
c0100f30:	74 0c                	je     c0100f3e <__intr_save+0x23>
        intr_disable();
c0100f32:	e8 1d 11 00 00       	call   c0102054 <intr_disable>
        return 1;
c0100f37:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f3c:	eb 05                	jmp    c0100f43 <__intr_save+0x28>
    }
    return 0;
c0100f3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f43:	c9                   	leave  
c0100f44:	c3                   	ret    

c0100f45 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100f45:	55                   	push   %ebp
c0100f46:	89 e5                	mov    %esp,%ebp
c0100f48:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100f4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100f4f:	74 05                	je     c0100f56 <__intr_restore+0x11>
        intr_enable();
c0100f51:	e8 f8 10 00 00       	call   c010204e <intr_enable>
    }
}
c0100f56:	c9                   	leave  
c0100f57:	c3                   	ret    

c0100f58 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f58:	55                   	push   %ebp
c0100f59:	89 e5                	mov    %esp,%ebp
c0100f5b:	83 ec 10             	sub    $0x10,%esp
c0100f5e:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f64:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100f68:	89 c2                	mov    %eax,%edx
c0100f6a:	ec                   	in     (%dx),%al
c0100f6b:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100f6e:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f74:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f78:	89 c2                	mov    %eax,%edx
c0100f7a:	ec                   	in     (%dx),%al
c0100f7b:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100f7e:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f84:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f88:	89 c2                	mov    %eax,%edx
c0100f8a:	ec                   	in     (%dx),%al
c0100f8b:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100f8e:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100f94:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f98:	89 c2                	mov    %eax,%edx
c0100f9a:	ec                   	in     (%dx),%al
c0100f9b:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100f9e:	c9                   	leave  
c0100f9f:	c3                   	ret    

c0100fa0 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100fa0:	55                   	push   %ebp
c0100fa1:	89 e5                	mov    %esp,%ebp
c0100fa3:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100fa6:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100fad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fb0:	0f b7 00             	movzwl (%eax),%eax
c0100fb3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100fb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fba:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100fbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc2:	0f b7 00             	movzwl (%eax),%eax
c0100fc5:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100fc9:	74 12                	je     c0100fdd <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100fcb:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100fd2:	66 c7 05 46 e4 19 c0 	movw   $0x3b4,0xc019e446
c0100fd9:	b4 03 
c0100fdb:	eb 13                	jmp    c0100ff0 <cga_init+0x50>
    } else {
        *cp = was;
c0100fdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fe0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100fe4:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100fe7:	66 c7 05 46 e4 19 c0 	movw   $0x3d4,0xc019e446
c0100fee:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ff0:	0f b7 05 46 e4 19 c0 	movzwl 0xc019e446,%eax
c0100ff7:	0f b7 c0             	movzwl %ax,%eax
c0100ffa:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ffe:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101002:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101006:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010100a:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010100b:	0f b7 05 46 e4 19 c0 	movzwl 0xc019e446,%eax
c0101012:	83 c0 01             	add    $0x1,%eax
c0101015:	0f b7 c0             	movzwl %ax,%eax
c0101018:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101c:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101020:	89 c2                	mov    %eax,%edx
c0101022:	ec                   	in     (%dx),%al
c0101023:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101026:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010102a:	0f b6 c0             	movzbl %al,%eax
c010102d:	c1 e0 08             	shl    $0x8,%eax
c0101030:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101033:	0f b7 05 46 e4 19 c0 	movzwl 0xc019e446,%eax
c010103a:	0f b7 c0             	movzwl %ax,%eax
c010103d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101041:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101045:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101049:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010104d:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c010104e:	0f b7 05 46 e4 19 c0 	movzwl 0xc019e446,%eax
c0101055:	83 c0 01             	add    $0x1,%eax
c0101058:	0f b7 c0             	movzwl %ax,%eax
c010105b:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010105f:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101063:	89 c2                	mov    %eax,%edx
c0101065:	ec                   	in     (%dx),%al
c0101066:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0101069:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010106d:	0f b6 c0             	movzbl %al,%eax
c0101070:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101073:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101076:	a3 40 e4 19 c0       	mov    %eax,0xc019e440
    crt_pos = pos;
c010107b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010107e:	66 a3 44 e4 19 c0    	mov    %ax,0xc019e444
}
c0101084:	c9                   	leave  
c0101085:	c3                   	ret    

c0101086 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101086:	55                   	push   %ebp
c0101087:	89 e5                	mov    %esp,%ebp
c0101089:	83 ec 48             	sub    $0x48,%esp
c010108c:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0101092:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101096:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010109a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010109e:	ee                   	out    %al,(%dx)
c010109f:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c01010a5:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c01010a9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010ad:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010b1:	ee                   	out    %al,(%dx)
c01010b2:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c01010b8:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c01010bc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c4:	ee                   	out    %al,(%dx)
c01010c5:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01010cb:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c01010cf:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01010d3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01010d7:	ee                   	out    %al,(%dx)
c01010d8:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c01010de:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c01010e2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01010e6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01010ea:	ee                   	out    %al,(%dx)
c01010eb:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c01010f1:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c01010f5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01010f9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01010fd:	ee                   	out    %al,(%dx)
c01010fe:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101104:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101108:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010110c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101110:	ee                   	out    %al,(%dx)
c0101111:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101117:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010111b:	89 c2                	mov    %eax,%edx
c010111d:	ec                   	in     (%dx),%al
c010111e:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101121:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101125:	3c ff                	cmp    $0xff,%al
c0101127:	0f 95 c0             	setne  %al
c010112a:	0f b6 c0             	movzbl %al,%eax
c010112d:	a3 48 e4 19 c0       	mov    %eax,0xc019e448
c0101132:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101138:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c010113c:	89 c2                	mov    %eax,%edx
c010113e:	ec                   	in     (%dx),%al
c010113f:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101142:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101148:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010114c:	89 c2                	mov    %eax,%edx
c010114e:	ec                   	in     (%dx),%al
c010114f:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101152:	a1 48 e4 19 c0       	mov    0xc019e448,%eax
c0101157:	85 c0                	test   %eax,%eax
c0101159:	74 0c                	je     c0101167 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010115b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101162:	e8 4b 0f 00 00       	call   c01020b2 <pic_enable>
    }
}
c0101167:	c9                   	leave  
c0101168:	c3                   	ret    

c0101169 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101169:	55                   	push   %ebp
c010116a:	89 e5                	mov    %esp,%ebp
c010116c:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010116f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101176:	eb 09                	jmp    c0101181 <lpt_putc_sub+0x18>
        delay();
c0101178:	e8 db fd ff ff       	call   c0100f58 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010117d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101181:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101187:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010118b:	89 c2                	mov    %eax,%edx
c010118d:	ec                   	in     (%dx),%al
c010118e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101191:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101195:	84 c0                	test   %al,%al
c0101197:	78 09                	js     c01011a2 <lpt_putc_sub+0x39>
c0101199:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01011a0:	7e d6                	jle    c0101178 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01011a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01011a5:	0f b6 c0             	movzbl %al,%eax
c01011a8:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01011ae:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011b1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01011b5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01011b9:	ee                   	out    %al,(%dx)
c01011ba:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01011c0:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01011c4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011c8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011cc:	ee                   	out    %al,(%dx)
c01011cd:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01011d3:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01011d7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011db:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011df:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01011e0:	c9                   	leave  
c01011e1:	c3                   	ret    

c01011e2 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01011e2:	55                   	push   %ebp
c01011e3:	89 e5                	mov    %esp,%ebp
c01011e5:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01011e8:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01011ec:	74 0d                	je     c01011fb <lpt_putc+0x19>
        lpt_putc_sub(c);
c01011ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f1:	89 04 24             	mov    %eax,(%esp)
c01011f4:	e8 70 ff ff ff       	call   c0101169 <lpt_putc_sub>
c01011f9:	eb 24                	jmp    c010121f <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01011fb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101202:	e8 62 ff ff ff       	call   c0101169 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101207:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010120e:	e8 56 ff ff ff       	call   c0101169 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101213:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010121a:	e8 4a ff ff ff       	call   c0101169 <lpt_putc_sub>
    }
}
c010121f:	c9                   	leave  
c0101220:	c3                   	ret    

c0101221 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101221:	55                   	push   %ebp
c0101222:	89 e5                	mov    %esp,%ebp
c0101224:	53                   	push   %ebx
c0101225:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101228:	8b 45 08             	mov    0x8(%ebp),%eax
c010122b:	b0 00                	mov    $0x0,%al
c010122d:	85 c0                	test   %eax,%eax
c010122f:	75 07                	jne    c0101238 <cga_putc+0x17>
        c |= 0x0700;
c0101231:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101238:	8b 45 08             	mov    0x8(%ebp),%eax
c010123b:	0f b6 c0             	movzbl %al,%eax
c010123e:	83 f8 0a             	cmp    $0xa,%eax
c0101241:	74 4c                	je     c010128f <cga_putc+0x6e>
c0101243:	83 f8 0d             	cmp    $0xd,%eax
c0101246:	74 57                	je     c010129f <cga_putc+0x7e>
c0101248:	83 f8 08             	cmp    $0x8,%eax
c010124b:	0f 85 88 00 00 00    	jne    c01012d9 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101251:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c0101258:	66 85 c0             	test   %ax,%ax
c010125b:	74 30                	je     c010128d <cga_putc+0x6c>
            crt_pos --;
c010125d:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c0101264:	83 e8 01             	sub    $0x1,%eax
c0101267:	66 a3 44 e4 19 c0    	mov    %ax,0xc019e444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010126d:	a1 40 e4 19 c0       	mov    0xc019e440,%eax
c0101272:	0f b7 15 44 e4 19 c0 	movzwl 0xc019e444,%edx
c0101279:	0f b7 d2             	movzwl %dx,%edx
c010127c:	01 d2                	add    %edx,%edx
c010127e:	01 c2                	add    %eax,%edx
c0101280:	8b 45 08             	mov    0x8(%ebp),%eax
c0101283:	b0 00                	mov    $0x0,%al
c0101285:	83 c8 20             	or     $0x20,%eax
c0101288:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010128b:	eb 72                	jmp    c01012ff <cga_putc+0xde>
c010128d:	eb 70                	jmp    c01012ff <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c010128f:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c0101296:	83 c0 50             	add    $0x50,%eax
c0101299:	66 a3 44 e4 19 c0    	mov    %ax,0xc019e444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010129f:	0f b7 1d 44 e4 19 c0 	movzwl 0xc019e444,%ebx
c01012a6:	0f b7 0d 44 e4 19 c0 	movzwl 0xc019e444,%ecx
c01012ad:	0f b7 c1             	movzwl %cx,%eax
c01012b0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01012b6:	c1 e8 10             	shr    $0x10,%eax
c01012b9:	89 c2                	mov    %eax,%edx
c01012bb:	66 c1 ea 06          	shr    $0x6,%dx
c01012bf:	89 d0                	mov    %edx,%eax
c01012c1:	c1 e0 02             	shl    $0x2,%eax
c01012c4:	01 d0                	add    %edx,%eax
c01012c6:	c1 e0 04             	shl    $0x4,%eax
c01012c9:	29 c1                	sub    %eax,%ecx
c01012cb:	89 ca                	mov    %ecx,%edx
c01012cd:	89 d8                	mov    %ebx,%eax
c01012cf:	29 d0                	sub    %edx,%eax
c01012d1:	66 a3 44 e4 19 c0    	mov    %ax,0xc019e444
        break;
c01012d7:	eb 26                	jmp    c01012ff <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01012d9:	8b 0d 40 e4 19 c0    	mov    0xc019e440,%ecx
c01012df:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c01012e6:	8d 50 01             	lea    0x1(%eax),%edx
c01012e9:	66 89 15 44 e4 19 c0 	mov    %dx,0xc019e444
c01012f0:	0f b7 c0             	movzwl %ax,%eax
c01012f3:	01 c0                	add    %eax,%eax
c01012f5:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01012f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01012fb:	66 89 02             	mov    %ax,(%edx)
        break;
c01012fe:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01012ff:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c0101306:	66 3d cf 07          	cmp    $0x7cf,%ax
c010130a:	76 5b                	jbe    c0101367 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010130c:	a1 40 e4 19 c0       	mov    0xc019e440,%eax
c0101311:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101317:	a1 40 e4 19 c0       	mov    0xc019e440,%eax
c010131c:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101323:	00 
c0101324:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101328:	89 04 24             	mov    %eax,(%esp)
c010132b:	e8 68 ab 00 00       	call   c010be98 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101330:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101337:	eb 15                	jmp    c010134e <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101339:	a1 40 e4 19 c0       	mov    0xc019e440,%eax
c010133e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101341:	01 d2                	add    %edx,%edx
c0101343:	01 d0                	add    %edx,%eax
c0101345:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010134a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010134e:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101355:	7e e2                	jle    c0101339 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101357:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c010135e:	83 e8 50             	sub    $0x50,%eax
c0101361:	66 a3 44 e4 19 c0    	mov    %ax,0xc019e444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101367:	0f b7 05 46 e4 19 c0 	movzwl 0xc019e446,%eax
c010136e:	0f b7 c0             	movzwl %ax,%eax
c0101371:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101375:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101379:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010137d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101381:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101382:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c0101389:	66 c1 e8 08          	shr    $0x8,%ax
c010138d:	0f b6 c0             	movzbl %al,%eax
c0101390:	0f b7 15 46 e4 19 c0 	movzwl 0xc019e446,%edx
c0101397:	83 c2 01             	add    $0x1,%edx
c010139a:	0f b7 d2             	movzwl %dx,%edx
c010139d:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01013a1:	88 45 ed             	mov    %al,-0x13(%ebp)
c01013a4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01013a8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01013ac:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01013ad:	0f b7 05 46 e4 19 c0 	movzwl 0xc019e446,%eax
c01013b4:	0f b7 c0             	movzwl %ax,%eax
c01013b7:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01013bb:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01013bf:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013c3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013c7:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01013c8:	0f b7 05 44 e4 19 c0 	movzwl 0xc019e444,%eax
c01013cf:	0f b6 c0             	movzbl %al,%eax
c01013d2:	0f b7 15 46 e4 19 c0 	movzwl 0xc019e446,%edx
c01013d9:	83 c2 01             	add    $0x1,%edx
c01013dc:	0f b7 d2             	movzwl %dx,%edx
c01013df:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013e3:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013e6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013ea:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013ee:	ee                   	out    %al,(%dx)
}
c01013ef:	83 c4 34             	add    $0x34,%esp
c01013f2:	5b                   	pop    %ebx
c01013f3:	5d                   	pop    %ebp
c01013f4:	c3                   	ret    

c01013f5 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01013f5:	55                   	push   %ebp
c01013f6:	89 e5                	mov    %esp,%ebp
c01013f8:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013fb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101402:	eb 09                	jmp    c010140d <serial_putc_sub+0x18>
        delay();
c0101404:	e8 4f fb ff ff       	call   c0100f58 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101409:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010140d:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101413:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101417:	89 c2                	mov    %eax,%edx
c0101419:	ec                   	in     (%dx),%al
c010141a:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010141d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101421:	0f b6 c0             	movzbl %al,%eax
c0101424:	83 e0 20             	and    $0x20,%eax
c0101427:	85 c0                	test   %eax,%eax
c0101429:	75 09                	jne    c0101434 <serial_putc_sub+0x3f>
c010142b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101432:	7e d0                	jle    c0101404 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101434:	8b 45 08             	mov    0x8(%ebp),%eax
c0101437:	0f b6 c0             	movzbl %al,%eax
c010143a:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101440:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101443:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101447:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010144b:	ee                   	out    %al,(%dx)
}
c010144c:	c9                   	leave  
c010144d:	c3                   	ret    

c010144e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010144e:	55                   	push   %ebp
c010144f:	89 e5                	mov    %esp,%ebp
c0101451:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101454:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101458:	74 0d                	je     c0101467 <serial_putc+0x19>
        serial_putc_sub(c);
c010145a:	8b 45 08             	mov    0x8(%ebp),%eax
c010145d:	89 04 24             	mov    %eax,(%esp)
c0101460:	e8 90 ff ff ff       	call   c01013f5 <serial_putc_sub>
c0101465:	eb 24                	jmp    c010148b <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101467:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010146e:	e8 82 ff ff ff       	call   c01013f5 <serial_putc_sub>
        serial_putc_sub(' ');
c0101473:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010147a:	e8 76 ff ff ff       	call   c01013f5 <serial_putc_sub>
        serial_putc_sub('\b');
c010147f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101486:	e8 6a ff ff ff       	call   c01013f5 <serial_putc_sub>
    }
}
c010148b:	c9                   	leave  
c010148c:	c3                   	ret    

c010148d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010148d:	55                   	push   %ebp
c010148e:	89 e5                	mov    %esp,%ebp
c0101490:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101493:	eb 33                	jmp    c01014c8 <cons_intr+0x3b>
        if (c != 0) {
c0101495:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101499:	74 2d                	je     c01014c8 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010149b:	a1 64 e6 19 c0       	mov    0xc019e664,%eax
c01014a0:	8d 50 01             	lea    0x1(%eax),%edx
c01014a3:	89 15 64 e6 19 c0    	mov    %edx,0xc019e664
c01014a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01014ac:	88 90 60 e4 19 c0    	mov    %dl,-0x3fe61ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01014b2:	a1 64 e6 19 c0       	mov    0xc019e664,%eax
c01014b7:	3d 00 02 00 00       	cmp    $0x200,%eax
c01014bc:	75 0a                	jne    c01014c8 <cons_intr+0x3b>
                cons.wpos = 0;
c01014be:	c7 05 64 e6 19 c0 00 	movl   $0x0,0xc019e664
c01014c5:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01014c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01014cb:	ff d0                	call   *%eax
c01014cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014d0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01014d4:	75 bf                	jne    c0101495 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01014d6:	c9                   	leave  
c01014d7:	c3                   	ret    

c01014d8 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01014d8:	55                   	push   %ebp
c01014d9:	89 e5                	mov    %esp,%ebp
c01014db:	83 ec 10             	sub    $0x10,%esp
c01014de:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014e4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01014e8:	89 c2                	mov    %eax,%edx
c01014ea:	ec                   	in     (%dx),%al
c01014eb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01014ee:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01014f2:	0f b6 c0             	movzbl %al,%eax
c01014f5:	83 e0 01             	and    $0x1,%eax
c01014f8:	85 c0                	test   %eax,%eax
c01014fa:	75 07                	jne    c0101503 <serial_proc_data+0x2b>
        return -1;
c01014fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101501:	eb 2a                	jmp    c010152d <serial_proc_data+0x55>
c0101503:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101509:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010150d:	89 c2                	mov    %eax,%edx
c010150f:	ec                   	in     (%dx),%al
c0101510:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101513:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101517:	0f b6 c0             	movzbl %al,%eax
c010151a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010151d:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101521:	75 07                	jne    c010152a <serial_proc_data+0x52>
        c = '\b';
c0101523:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010152a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010152d:	c9                   	leave  
c010152e:	c3                   	ret    

c010152f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010152f:	55                   	push   %ebp
c0101530:	89 e5                	mov    %esp,%ebp
c0101532:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101535:	a1 48 e4 19 c0       	mov    0xc019e448,%eax
c010153a:	85 c0                	test   %eax,%eax
c010153c:	74 0c                	je     c010154a <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010153e:	c7 04 24 d8 14 10 c0 	movl   $0xc01014d8,(%esp)
c0101545:	e8 43 ff ff ff       	call   c010148d <cons_intr>
    }
}
c010154a:	c9                   	leave  
c010154b:	c3                   	ret    

c010154c <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010154c:	55                   	push   %ebp
c010154d:	89 e5                	mov    %esp,%ebp
c010154f:	83 ec 38             	sub    $0x38,%esp
c0101552:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101558:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010155c:	89 c2                	mov    %eax,%edx
c010155e:	ec                   	in     (%dx),%al
c010155f:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101562:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101566:	0f b6 c0             	movzbl %al,%eax
c0101569:	83 e0 01             	and    $0x1,%eax
c010156c:	85 c0                	test   %eax,%eax
c010156e:	75 0a                	jne    c010157a <kbd_proc_data+0x2e>
        return -1;
c0101570:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101575:	e9 59 01 00 00       	jmp    c01016d3 <kbd_proc_data+0x187>
c010157a:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101580:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101584:	89 c2                	mov    %eax,%edx
c0101586:	ec                   	in     (%dx),%al
c0101587:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010158a:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010158e:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101591:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101595:	75 17                	jne    c01015ae <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101597:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c010159c:	83 c8 40             	or     $0x40,%eax
c010159f:	a3 68 e6 19 c0       	mov    %eax,0xc019e668
        return 0;
c01015a4:	b8 00 00 00 00       	mov    $0x0,%eax
c01015a9:	e9 25 01 00 00       	jmp    c01016d3 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01015ae:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015b2:	84 c0                	test   %al,%al
c01015b4:	79 47                	jns    c01015fd <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01015b6:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c01015bb:	83 e0 40             	and    $0x40,%eax
c01015be:	85 c0                	test   %eax,%eax
c01015c0:	75 09                	jne    c01015cb <kbd_proc_data+0x7f>
c01015c2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015c6:	83 e0 7f             	and    $0x7f,%eax
c01015c9:	eb 04                	jmp    c01015cf <kbd_proc_data+0x83>
c01015cb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015cf:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01015d2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015d6:	0f b6 80 40 a0 12 c0 	movzbl -0x3fed5fc0(%eax),%eax
c01015dd:	83 c8 40             	or     $0x40,%eax
c01015e0:	0f b6 c0             	movzbl %al,%eax
c01015e3:	f7 d0                	not    %eax
c01015e5:	89 c2                	mov    %eax,%edx
c01015e7:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c01015ec:	21 d0                	and    %edx,%eax
c01015ee:	a3 68 e6 19 c0       	mov    %eax,0xc019e668
        return 0;
c01015f3:	b8 00 00 00 00       	mov    $0x0,%eax
c01015f8:	e9 d6 00 00 00       	jmp    c01016d3 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01015fd:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c0101602:	83 e0 40             	and    $0x40,%eax
c0101605:	85 c0                	test   %eax,%eax
c0101607:	74 11                	je     c010161a <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101609:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010160d:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c0101612:	83 e0 bf             	and    $0xffffffbf,%eax
c0101615:	a3 68 e6 19 c0       	mov    %eax,0xc019e668
    }

    shift |= shiftcode[data];
c010161a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010161e:	0f b6 80 40 a0 12 c0 	movzbl -0x3fed5fc0(%eax),%eax
c0101625:	0f b6 d0             	movzbl %al,%edx
c0101628:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c010162d:	09 d0                	or     %edx,%eax
c010162f:	a3 68 e6 19 c0       	mov    %eax,0xc019e668
    shift ^= togglecode[data];
c0101634:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101638:	0f b6 80 40 a1 12 c0 	movzbl -0x3fed5ec0(%eax),%eax
c010163f:	0f b6 d0             	movzbl %al,%edx
c0101642:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c0101647:	31 d0                	xor    %edx,%eax
c0101649:	a3 68 e6 19 c0       	mov    %eax,0xc019e668

    c = charcode[shift & (CTL | SHIFT)][data];
c010164e:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c0101653:	83 e0 03             	and    $0x3,%eax
c0101656:	8b 14 85 40 a5 12 c0 	mov    -0x3fed5ac0(,%eax,4),%edx
c010165d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101661:	01 d0                	add    %edx,%eax
c0101663:	0f b6 00             	movzbl (%eax),%eax
c0101666:	0f b6 c0             	movzbl %al,%eax
c0101669:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010166c:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c0101671:	83 e0 08             	and    $0x8,%eax
c0101674:	85 c0                	test   %eax,%eax
c0101676:	74 22                	je     c010169a <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101678:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010167c:	7e 0c                	jle    c010168a <kbd_proc_data+0x13e>
c010167e:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101682:	7f 06                	jg     c010168a <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101684:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101688:	eb 10                	jmp    c010169a <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010168a:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010168e:	7e 0a                	jle    c010169a <kbd_proc_data+0x14e>
c0101690:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101694:	7f 04                	jg     c010169a <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101696:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010169a:	a1 68 e6 19 c0       	mov    0xc019e668,%eax
c010169f:	f7 d0                	not    %eax
c01016a1:	83 e0 06             	and    $0x6,%eax
c01016a4:	85 c0                	test   %eax,%eax
c01016a6:	75 28                	jne    c01016d0 <kbd_proc_data+0x184>
c01016a8:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01016af:	75 1f                	jne    c01016d0 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01016b1:	c7 04 24 43 c3 10 c0 	movl   $0xc010c343,(%esp)
c01016b8:	e8 a2 ec ff ff       	call   c010035f <cprintf>
c01016bd:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01016c3:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016c7:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01016cb:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01016cf:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01016d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016d3:	c9                   	leave  
c01016d4:	c3                   	ret    

c01016d5 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01016d5:	55                   	push   %ebp
c01016d6:	89 e5                	mov    %esp,%ebp
c01016d8:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01016db:	c7 04 24 4c 15 10 c0 	movl   $0xc010154c,(%esp)
c01016e2:	e8 a6 fd ff ff       	call   c010148d <cons_intr>
}
c01016e7:	c9                   	leave  
c01016e8:	c3                   	ret    

c01016e9 <kbd_init>:

static void
kbd_init(void) {
c01016e9:	55                   	push   %ebp
c01016ea:	89 e5                	mov    %esp,%ebp
c01016ec:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01016ef:	e8 e1 ff ff ff       	call   c01016d5 <kbd_intr>
    pic_enable(IRQ_KBD);
c01016f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01016fb:	e8 b2 09 00 00       	call   c01020b2 <pic_enable>
}
c0101700:	c9                   	leave  
c0101701:	c3                   	ret    

c0101702 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101702:	55                   	push   %ebp
c0101703:	89 e5                	mov    %esp,%ebp
c0101705:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101708:	e8 93 f8 ff ff       	call   c0100fa0 <cga_init>
    serial_init();
c010170d:	e8 74 f9 ff ff       	call   c0101086 <serial_init>
    kbd_init();
c0101712:	e8 d2 ff ff ff       	call   c01016e9 <kbd_init>
    if (!serial_exists) {
c0101717:	a1 48 e4 19 c0       	mov    0xc019e448,%eax
c010171c:	85 c0                	test   %eax,%eax
c010171e:	75 0c                	jne    c010172c <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101720:	c7 04 24 4f c3 10 c0 	movl   $0xc010c34f,(%esp)
c0101727:	e8 33 ec ff ff       	call   c010035f <cprintf>
    }
}
c010172c:	c9                   	leave  
c010172d:	c3                   	ret    

c010172e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010172e:	55                   	push   %ebp
c010172f:	89 e5                	mov    %esp,%ebp
c0101731:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101734:	e8 e2 f7 ff ff       	call   c0100f1b <__intr_save>
c0101739:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010173c:	8b 45 08             	mov    0x8(%ebp),%eax
c010173f:	89 04 24             	mov    %eax,(%esp)
c0101742:	e8 9b fa ff ff       	call   c01011e2 <lpt_putc>
        cga_putc(c);
c0101747:	8b 45 08             	mov    0x8(%ebp),%eax
c010174a:	89 04 24             	mov    %eax,(%esp)
c010174d:	e8 cf fa ff ff       	call   c0101221 <cga_putc>
        serial_putc(c);
c0101752:	8b 45 08             	mov    0x8(%ebp),%eax
c0101755:	89 04 24             	mov    %eax,(%esp)
c0101758:	e8 f1 fc ff ff       	call   c010144e <serial_putc>
    }
    local_intr_restore(intr_flag);
c010175d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101760:	89 04 24             	mov    %eax,(%esp)
c0101763:	e8 dd f7 ff ff       	call   c0100f45 <__intr_restore>
}
c0101768:	c9                   	leave  
c0101769:	c3                   	ret    

c010176a <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010176a:	55                   	push   %ebp
c010176b:	89 e5                	mov    %esp,%ebp
c010176d:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101777:	e8 9f f7 ff ff       	call   c0100f1b <__intr_save>
c010177c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010177f:	e8 ab fd ff ff       	call   c010152f <serial_intr>
        kbd_intr();
c0101784:	e8 4c ff ff ff       	call   c01016d5 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101789:	8b 15 60 e6 19 c0    	mov    0xc019e660,%edx
c010178f:	a1 64 e6 19 c0       	mov    0xc019e664,%eax
c0101794:	39 c2                	cmp    %eax,%edx
c0101796:	74 31                	je     c01017c9 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101798:	a1 60 e6 19 c0       	mov    0xc019e660,%eax
c010179d:	8d 50 01             	lea    0x1(%eax),%edx
c01017a0:	89 15 60 e6 19 c0    	mov    %edx,0xc019e660
c01017a6:	0f b6 80 60 e4 19 c0 	movzbl -0x3fe61ba0(%eax),%eax
c01017ad:	0f b6 c0             	movzbl %al,%eax
c01017b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01017b3:	a1 60 e6 19 c0       	mov    0xc019e660,%eax
c01017b8:	3d 00 02 00 00       	cmp    $0x200,%eax
c01017bd:	75 0a                	jne    c01017c9 <cons_getc+0x5f>
                cons.rpos = 0;
c01017bf:	c7 05 60 e6 19 c0 00 	movl   $0x0,0xc019e660
c01017c6:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01017c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017cc:	89 04 24             	mov    %eax,(%esp)
c01017cf:	e8 71 f7 ff ff       	call   c0100f45 <__intr_restore>
    return c;
c01017d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017d7:	c9                   	leave  
c01017d8:	c3                   	ret    

c01017d9 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01017d9:	55                   	push   %ebp
c01017da:	89 e5                	mov    %esp,%ebp
c01017dc:	83 ec 14             	sub    $0x14,%esp
c01017df:	8b 45 08             	mov    0x8(%ebp),%eax
c01017e2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01017e6:	90                   	nop
c01017e7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017eb:	83 c0 07             	add    $0x7,%eax
c01017ee:	0f b7 c0             	movzwl %ax,%eax
c01017f1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017f5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017f9:	89 c2                	mov    %eax,%edx
c01017fb:	ec                   	in     (%dx),%al
c01017fc:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01017ff:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101803:	0f b6 c0             	movzbl %al,%eax
c0101806:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101809:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010180c:	25 80 00 00 00       	and    $0x80,%eax
c0101811:	85 c0                	test   %eax,%eax
c0101813:	75 d2                	jne    c01017e7 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0101815:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101819:	74 11                	je     c010182c <ide_wait_ready+0x53>
c010181b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010181e:	83 e0 21             	and    $0x21,%eax
c0101821:	85 c0                	test   %eax,%eax
c0101823:	74 07                	je     c010182c <ide_wait_ready+0x53>
        return -1;
c0101825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010182a:	eb 05                	jmp    c0101831 <ide_wait_ready+0x58>
    }
    return 0;
c010182c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101831:	c9                   	leave  
c0101832:	c3                   	ret    

c0101833 <ide_init>:

void
ide_init(void) {
c0101833:	55                   	push   %ebp
c0101834:	89 e5                	mov    %esp,%ebp
c0101836:	57                   	push   %edi
c0101837:	53                   	push   %ebx
c0101838:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010183e:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0101844:	e9 d6 02 00 00       	jmp    c0101b1f <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101849:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010184d:	c1 e0 03             	shl    $0x3,%eax
c0101850:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101857:	29 c2                	sub    %eax,%edx
c0101859:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c010185f:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0101862:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101866:	66 d1 e8             	shr    %ax
c0101869:	0f b7 c0             	movzwl %ax,%eax
c010186c:	0f b7 04 85 70 c3 10 	movzwl -0x3fef3c90(,%eax,4),%eax
c0101873:	c0 
c0101874:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101878:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010187c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101883:	00 
c0101884:	89 04 24             	mov    %eax,(%esp)
c0101887:	e8 4d ff ff ff       	call   c01017d9 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c010188c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101890:	83 e0 01             	and    $0x1,%eax
c0101893:	c1 e0 04             	shl    $0x4,%eax
c0101896:	83 c8 e0             	or     $0xffffffe0,%eax
c0101899:	0f b6 c0             	movzbl %al,%eax
c010189c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018a0:	83 c2 06             	add    $0x6,%edx
c01018a3:	0f b7 d2             	movzwl %dx,%edx
c01018a6:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c01018aa:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ad:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01018b1:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01018b5:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018b6:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018c1:	00 
c01018c2:	89 04 24             	mov    %eax,(%esp)
c01018c5:	e8 0f ff ff ff       	call   c01017d9 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01018ca:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018ce:	83 c0 07             	add    $0x7,%eax
c01018d1:	0f b7 c0             	movzwl %ax,%eax
c01018d4:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01018d8:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01018dc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01018e0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01018e4:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018e5:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018f0:	00 
c01018f1:	89 04 24             	mov    %eax,(%esp)
c01018f4:	e8 e0 fe ff ff       	call   c01017d9 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01018f9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018fd:	83 c0 07             	add    $0x7,%eax
c0101900:	0f b7 c0             	movzwl %ax,%eax
c0101903:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101907:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c010190b:	89 c2                	mov    %eax,%edx
c010190d:	ec                   	in     (%dx),%al
c010190e:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0101911:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101915:	84 c0                	test   %al,%al
c0101917:	0f 84 f7 01 00 00    	je     c0101b14 <ide_init+0x2e1>
c010191d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101921:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101928:	00 
c0101929:	89 04 24             	mov    %eax,(%esp)
c010192c:	e8 a8 fe ff ff       	call   c01017d9 <ide_wait_ready>
c0101931:	85 c0                	test   %eax,%eax
c0101933:	0f 85 db 01 00 00    	jne    c0101b14 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101939:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010193d:	c1 e0 03             	shl    $0x3,%eax
c0101940:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101947:	29 c2                	sub    %eax,%edx
c0101949:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c010194f:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101952:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101956:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101959:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010195f:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101962:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101969:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010196c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010196f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101972:	89 cb                	mov    %ecx,%ebx
c0101974:	89 df                	mov    %ebx,%edi
c0101976:	89 c1                	mov    %eax,%ecx
c0101978:	fc                   	cld    
c0101979:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010197b:	89 c8                	mov    %ecx,%eax
c010197d:	89 fb                	mov    %edi,%ebx
c010197f:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101982:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0101985:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010198b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c010198e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101991:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0101997:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010199a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010199d:	25 00 00 00 04       	and    $0x4000000,%eax
c01019a2:	85 c0                	test   %eax,%eax
c01019a4:	74 0e                	je     c01019b4 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01019a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019a9:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01019af:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01019b2:	eb 09                	jmp    c01019bd <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01019b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019b7:	8b 40 78             	mov    0x78(%eax),%eax
c01019ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01019bd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019c1:	c1 e0 03             	shl    $0x3,%eax
c01019c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019cb:	29 c2                	sub    %eax,%edx
c01019cd:	81 c2 80 e6 19 c0    	add    $0xc019e680,%edx
c01019d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019d6:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01019d9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019dd:	c1 e0 03             	shl    $0x3,%eax
c01019e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019e7:	29 c2                	sub    %eax,%edx
c01019e9:	81 c2 80 e6 19 c0    	add    $0xc019e680,%edx
c01019ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019f2:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01019f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019f8:	83 c0 62             	add    $0x62,%eax
c01019fb:	0f b7 00             	movzwl (%eax),%eax
c01019fe:	0f b7 c0             	movzwl %ax,%eax
c0101a01:	25 00 02 00 00       	and    $0x200,%eax
c0101a06:	85 c0                	test   %eax,%eax
c0101a08:	75 24                	jne    c0101a2e <ide_init+0x1fb>
c0101a0a:	c7 44 24 0c 78 c3 10 	movl   $0xc010c378,0xc(%esp)
c0101a11:	c0 
c0101a12:	c7 44 24 08 bb c3 10 	movl   $0xc010c3bb,0x8(%esp)
c0101a19:	c0 
c0101a1a:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101a21:	00 
c0101a22:	c7 04 24 d0 c3 10 c0 	movl   $0xc010c3d0,(%esp)
c0101a29:	e8 bd f3 ff ff       	call   c0100deb <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101a2e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a32:	c1 e0 03             	shl    $0x3,%eax
c0101a35:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a3c:	29 c2                	sub    %eax,%edx
c0101a3e:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c0101a44:	83 c0 0c             	add    $0xc,%eax
c0101a47:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a4d:	83 c0 36             	add    $0x36,%eax
c0101a50:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101a53:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101a5a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101a61:	eb 34                	jmp    c0101a97 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101a63:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a66:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a69:	01 c2                	add    %eax,%edx
c0101a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a6e:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a71:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a74:	01 c8                	add    %ecx,%eax
c0101a76:	0f b6 00             	movzbl (%eax),%eax
c0101a79:	88 02                	mov    %al,(%edx)
c0101a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a7e:	8d 50 01             	lea    0x1(%eax),%edx
c0101a81:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a84:	01 c2                	add    %eax,%edx
c0101a86:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a89:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101a8c:	01 c8                	add    %ecx,%eax
c0101a8e:	0f b6 00             	movzbl (%eax),%eax
c0101a91:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101a93:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a9a:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a9d:	72 c4                	jb     c0101a63 <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101a9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aa2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101aa5:	01 d0                	add    %edx,%eax
c0101aa7:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101aaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aad:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101ab0:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101ab3:	85 c0                	test   %eax,%eax
c0101ab5:	74 0f                	je     c0101ac6 <ide_init+0x293>
c0101ab7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101abd:	01 d0                	add    %edx,%eax
c0101abf:	0f b6 00             	movzbl (%eax),%eax
c0101ac2:	3c 20                	cmp    $0x20,%al
c0101ac4:	74 d9                	je     c0101a9f <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101ac6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101aca:	c1 e0 03             	shl    $0x3,%eax
c0101acd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101ad4:	29 c2                	sub    %eax,%edx
c0101ad6:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c0101adc:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101adf:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101ae3:	c1 e0 03             	shl    $0x3,%eax
c0101ae6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101aed:	29 c2                	sub    %eax,%edx
c0101aef:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c0101af5:	8b 50 08             	mov    0x8(%eax),%edx
c0101af8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101afc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101b00:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b08:	c7 04 24 e2 c3 10 c0 	movl   $0xc010c3e2,(%esp)
c0101b0f:	e8 4b e8 ff ff       	call   c010035f <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101b14:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b18:	83 c0 01             	add    $0x1,%eax
c0101b1b:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b1f:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101b24:	0f 86 1f fd ff ff    	jbe    c0101849 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101b2a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101b31:	e8 7c 05 00 00       	call   c01020b2 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101b36:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101b3d:	e8 70 05 00 00       	call   c01020b2 <pic_enable>
}
c0101b42:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101b48:	5b                   	pop    %ebx
c0101b49:	5f                   	pop    %edi
c0101b4a:	5d                   	pop    %ebp
c0101b4b:	c3                   	ret    

c0101b4c <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101b4c:	55                   	push   %ebp
c0101b4d:	89 e5                	mov    %esp,%ebp
c0101b4f:	83 ec 04             	sub    $0x4,%esp
c0101b52:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b55:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101b59:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101b5e:	77 24                	ja     c0101b84 <ide_device_valid+0x38>
c0101b60:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b64:	c1 e0 03             	shl    $0x3,%eax
c0101b67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b6e:	29 c2                	sub    %eax,%edx
c0101b70:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c0101b76:	0f b6 00             	movzbl (%eax),%eax
c0101b79:	84 c0                	test   %al,%al
c0101b7b:	74 07                	je     c0101b84 <ide_device_valid+0x38>
c0101b7d:	b8 01 00 00 00       	mov    $0x1,%eax
c0101b82:	eb 05                	jmp    c0101b89 <ide_device_valid+0x3d>
c0101b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b89:	c9                   	leave  
c0101b8a:	c3                   	ret    

c0101b8b <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b8b:	55                   	push   %ebp
c0101b8c:	89 e5                	mov    %esp,%ebp
c0101b8e:	83 ec 08             	sub    $0x8,%esp
c0101b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b94:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b98:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b9c:	89 04 24             	mov    %eax,(%esp)
c0101b9f:	e8 a8 ff ff ff       	call   c0101b4c <ide_device_valid>
c0101ba4:	85 c0                	test   %eax,%eax
c0101ba6:	74 1b                	je     c0101bc3 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101ba8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101bac:	c1 e0 03             	shl    $0x3,%eax
c0101baf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101bb6:	29 c2                	sub    %eax,%edx
c0101bb8:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c0101bbe:	8b 40 08             	mov    0x8(%eax),%eax
c0101bc1:	eb 05                	jmp    c0101bc8 <ide_device_size+0x3d>
    }
    return 0;
c0101bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101bc8:	c9                   	leave  
c0101bc9:	c3                   	ret    

c0101bca <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101bca:	55                   	push   %ebp
c0101bcb:	89 e5                	mov    %esp,%ebp
c0101bcd:	57                   	push   %edi
c0101bce:	53                   	push   %ebx
c0101bcf:	83 ec 50             	sub    $0x50,%esp
c0101bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd5:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101bd9:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101be0:	77 24                	ja     c0101c06 <ide_read_secs+0x3c>
c0101be2:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101be7:	77 1d                	ja     c0101c06 <ide_read_secs+0x3c>
c0101be9:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bed:	c1 e0 03             	shl    $0x3,%eax
c0101bf0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101bf7:	29 c2                	sub    %eax,%edx
c0101bf9:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c0101bff:	0f b6 00             	movzbl (%eax),%eax
c0101c02:	84 c0                	test   %al,%al
c0101c04:	75 24                	jne    c0101c2a <ide_read_secs+0x60>
c0101c06:	c7 44 24 0c 00 c4 10 	movl   $0xc010c400,0xc(%esp)
c0101c0d:	c0 
c0101c0e:	c7 44 24 08 bb c3 10 	movl   $0xc010c3bb,0x8(%esp)
c0101c15:	c0 
c0101c16:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101c1d:	00 
c0101c1e:	c7 04 24 d0 c3 10 c0 	movl   $0xc010c3d0,(%esp)
c0101c25:	e8 c1 f1 ff ff       	call   c0100deb <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101c2a:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101c31:	77 0f                	ja     c0101c42 <ide_read_secs+0x78>
c0101c33:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c36:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101c39:	01 d0                	add    %edx,%eax
c0101c3b:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101c40:	76 24                	jbe    c0101c66 <ide_read_secs+0x9c>
c0101c42:	c7 44 24 0c 28 c4 10 	movl   $0xc010c428,0xc(%esp)
c0101c49:	c0 
c0101c4a:	c7 44 24 08 bb c3 10 	movl   $0xc010c3bb,0x8(%esp)
c0101c51:	c0 
c0101c52:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101c59:	00 
c0101c5a:	c7 04 24 d0 c3 10 c0 	movl   $0xc010c3d0,(%esp)
c0101c61:	e8 85 f1 ff ff       	call   c0100deb <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101c66:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c6a:	66 d1 e8             	shr    %ax
c0101c6d:	0f b7 c0             	movzwl %ax,%eax
c0101c70:	0f b7 04 85 70 c3 10 	movzwl -0x3fef3c90(,%eax,4),%eax
c0101c77:	c0 
c0101c78:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101c7c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c80:	66 d1 e8             	shr    %ax
c0101c83:	0f b7 c0             	movzwl %ax,%eax
c0101c86:	0f b7 04 85 72 c3 10 	movzwl -0x3fef3c8e(,%eax,4),%eax
c0101c8d:	c0 
c0101c8e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101c92:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101c9d:	00 
c0101c9e:	89 04 24             	mov    %eax,(%esp)
c0101ca1:	e8 33 fb ff ff       	call   c01017d9 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101ca6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101caa:	83 c0 02             	add    $0x2,%eax
c0101cad:	0f b7 c0             	movzwl %ax,%eax
c0101cb0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101cb4:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cb8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101cbc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101cc0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101cc1:	8b 45 14             	mov    0x14(%ebp),%eax
c0101cc4:	0f b6 c0             	movzbl %al,%eax
c0101cc7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ccb:	83 c2 02             	add    $0x2,%edx
c0101cce:	0f b7 d2             	movzwl %dx,%edx
c0101cd1:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cd5:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101cd8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101cdc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101ce0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ce4:	0f b6 c0             	movzbl %al,%eax
c0101ce7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ceb:	83 c2 03             	add    $0x3,%edx
c0101cee:	0f b7 d2             	movzwl %dx,%edx
c0101cf1:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101cf5:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101cf8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101cfc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101d00:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101d01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d04:	c1 e8 08             	shr    $0x8,%eax
c0101d07:	0f b6 c0             	movzbl %al,%eax
c0101d0a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d0e:	83 c2 04             	add    $0x4,%edx
c0101d11:	0f b7 d2             	movzwl %dx,%edx
c0101d14:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101d18:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101d1b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101d1f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101d23:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d27:	c1 e8 10             	shr    $0x10,%eax
c0101d2a:	0f b6 c0             	movzbl %al,%eax
c0101d2d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d31:	83 c2 05             	add    $0x5,%edx
c0101d34:	0f b7 d2             	movzwl %dx,%edx
c0101d37:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101d3b:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101d3e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101d42:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101d46:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101d47:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d4b:	83 e0 01             	and    $0x1,%eax
c0101d4e:	c1 e0 04             	shl    $0x4,%eax
c0101d51:	89 c2                	mov    %eax,%edx
c0101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d56:	c1 e8 18             	shr    $0x18,%eax
c0101d59:	83 e0 0f             	and    $0xf,%eax
c0101d5c:	09 d0                	or     %edx,%eax
c0101d5e:	83 c8 e0             	or     $0xffffffe0,%eax
c0101d61:	0f b6 c0             	movzbl %al,%eax
c0101d64:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d68:	83 c2 06             	add    $0x6,%edx
c0101d6b:	0f b7 d2             	movzwl %dx,%edx
c0101d6e:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101d72:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101d75:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101d79:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101d7d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101d7e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d82:	83 c0 07             	add    $0x7,%eax
c0101d85:	0f b7 c0             	movzwl %ax,%eax
c0101d88:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101d8c:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101d90:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101d94:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101d98:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101d99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101da0:	eb 5a                	jmp    c0101dfc <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101da2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101da6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101dad:	00 
c0101dae:	89 04 24             	mov    %eax,(%esp)
c0101db1:	e8 23 fa ff ff       	call   c01017d9 <ide_wait_ready>
c0101db6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101db9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101dbd:	74 02                	je     c0101dc1 <ide_read_secs+0x1f7>
            goto out;
c0101dbf:	eb 41                	jmp    c0101e02 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101dc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dc5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101dc8:	8b 45 10             	mov    0x10(%ebp),%eax
c0101dcb:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101dce:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101dd5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101dd8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101ddb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101dde:	89 cb                	mov    %ecx,%ebx
c0101de0:	89 df                	mov    %ebx,%edi
c0101de2:	89 c1                	mov    %eax,%ecx
c0101de4:	fc                   	cld    
c0101de5:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101de7:	89 c8                	mov    %ecx,%eax
c0101de9:	89 fb                	mov    %edi,%ebx
c0101deb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101dee:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101df1:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101df5:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101dfc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101e00:	75 a0                	jne    c0101da2 <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e05:	83 c4 50             	add    $0x50,%esp
c0101e08:	5b                   	pop    %ebx
c0101e09:	5f                   	pop    %edi
c0101e0a:	5d                   	pop    %ebp
c0101e0b:	c3                   	ret    

c0101e0c <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101e0c:	55                   	push   %ebp
c0101e0d:	89 e5                	mov    %esp,%ebp
c0101e0f:	56                   	push   %esi
c0101e10:	53                   	push   %ebx
c0101e11:	83 ec 50             	sub    $0x50,%esp
c0101e14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e17:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101e1b:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101e22:	77 24                	ja     c0101e48 <ide_write_secs+0x3c>
c0101e24:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101e29:	77 1d                	ja     c0101e48 <ide_write_secs+0x3c>
c0101e2b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e2f:	c1 e0 03             	shl    $0x3,%eax
c0101e32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101e39:	29 c2                	sub    %eax,%edx
c0101e3b:	8d 82 80 e6 19 c0    	lea    -0x3fe61980(%edx),%eax
c0101e41:	0f b6 00             	movzbl (%eax),%eax
c0101e44:	84 c0                	test   %al,%al
c0101e46:	75 24                	jne    c0101e6c <ide_write_secs+0x60>
c0101e48:	c7 44 24 0c 00 c4 10 	movl   $0xc010c400,0xc(%esp)
c0101e4f:	c0 
c0101e50:	c7 44 24 08 bb c3 10 	movl   $0xc010c3bb,0x8(%esp)
c0101e57:	c0 
c0101e58:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101e5f:	00 
c0101e60:	c7 04 24 d0 c3 10 c0 	movl   $0xc010c3d0,(%esp)
c0101e67:	e8 7f ef ff ff       	call   c0100deb <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101e6c:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101e73:	77 0f                	ja     c0101e84 <ide_write_secs+0x78>
c0101e75:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e78:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101e7b:	01 d0                	add    %edx,%eax
c0101e7d:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101e82:	76 24                	jbe    c0101ea8 <ide_write_secs+0x9c>
c0101e84:	c7 44 24 0c 28 c4 10 	movl   $0xc010c428,0xc(%esp)
c0101e8b:	c0 
c0101e8c:	c7 44 24 08 bb c3 10 	movl   $0xc010c3bb,0x8(%esp)
c0101e93:	c0 
c0101e94:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e9b:	00 
c0101e9c:	c7 04 24 d0 c3 10 c0 	movl   $0xc010c3d0,(%esp)
c0101ea3:	e8 43 ef ff ff       	call   c0100deb <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101ea8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101eac:	66 d1 e8             	shr    %ax
c0101eaf:	0f b7 c0             	movzwl %ax,%eax
c0101eb2:	0f b7 04 85 70 c3 10 	movzwl -0x3fef3c90(,%eax,4),%eax
c0101eb9:	c0 
c0101eba:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101ebe:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ec2:	66 d1 e8             	shr    %ax
c0101ec5:	0f b7 c0             	movzwl %ax,%eax
c0101ec8:	0f b7 04 85 72 c3 10 	movzwl -0x3fef3c8e(,%eax,4),%eax
c0101ecf:	c0 
c0101ed0:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101ed4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ed8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101edf:	00 
c0101ee0:	89 04 24             	mov    %eax,(%esp)
c0101ee3:	e8 f1 f8 ff ff       	call   c01017d9 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101ee8:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101eec:	83 c0 02             	add    $0x2,%eax
c0101eef:	0f b7 c0             	movzwl %ax,%eax
c0101ef2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101ef6:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101efa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101efe:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f02:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101f03:	8b 45 14             	mov    0x14(%ebp),%eax
c0101f06:	0f b6 c0             	movzbl %al,%eax
c0101f09:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f0d:	83 c2 02             	add    $0x2,%edx
c0101f10:	0f b7 d2             	movzwl %dx,%edx
c0101f13:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101f17:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101f1a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f1e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f22:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101f23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f26:	0f b6 c0             	movzbl %al,%eax
c0101f29:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f2d:	83 c2 03             	add    $0x3,%edx
c0101f30:	0f b7 d2             	movzwl %dx,%edx
c0101f33:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101f37:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101f3a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101f3e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101f42:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101f43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f46:	c1 e8 08             	shr    $0x8,%eax
c0101f49:	0f b6 c0             	movzbl %al,%eax
c0101f4c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f50:	83 c2 04             	add    $0x4,%edx
c0101f53:	0f b7 d2             	movzwl %dx,%edx
c0101f56:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101f5a:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101f5d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101f61:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101f65:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101f66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f69:	c1 e8 10             	shr    $0x10,%eax
c0101f6c:	0f b6 c0             	movzbl %al,%eax
c0101f6f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f73:	83 c2 05             	add    $0x5,%edx
c0101f76:	0f b7 d2             	movzwl %dx,%edx
c0101f79:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101f7d:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101f80:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f84:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101f88:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101f89:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101f8d:	83 e0 01             	and    $0x1,%eax
c0101f90:	c1 e0 04             	shl    $0x4,%eax
c0101f93:	89 c2                	mov    %eax,%edx
c0101f95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f98:	c1 e8 18             	shr    $0x18,%eax
c0101f9b:	83 e0 0f             	and    $0xf,%eax
c0101f9e:	09 d0                	or     %edx,%eax
c0101fa0:	83 c8 e0             	or     $0xffffffe0,%eax
c0101fa3:	0f b6 c0             	movzbl %al,%eax
c0101fa6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101faa:	83 c2 06             	add    $0x6,%edx
c0101fad:	0f b7 d2             	movzwl %dx,%edx
c0101fb0:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101fb4:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101fb7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101fbb:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101fbf:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101fc0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fc4:	83 c0 07             	add    $0x7,%eax
c0101fc7:	0f b7 c0             	movzwl %ax,%eax
c0101fca:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101fce:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101fd2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101fd6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101fda:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101fe2:	eb 5a                	jmp    c010203e <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101fe4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fe8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101fef:	00 
c0101ff0:	89 04 24             	mov    %eax,(%esp)
c0101ff3:	e8 e1 f7 ff ff       	call   c01017d9 <ide_wait_ready>
c0101ff8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101ffb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101fff:	74 02                	je     c0102003 <ide_write_secs+0x1f7>
            goto out;
c0102001:	eb 41                	jmp    c0102044 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0102003:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102007:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010200a:	8b 45 10             	mov    0x10(%ebp),%eax
c010200d:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102010:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0102017:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010201a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010201d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102020:	89 cb                	mov    %ecx,%ebx
c0102022:	89 de                	mov    %ebx,%esi
c0102024:	89 c1                	mov    %eax,%ecx
c0102026:	fc                   	cld    
c0102027:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102029:	89 c8                	mov    %ecx,%eax
c010202b:	89 f3                	mov    %esi,%ebx
c010202d:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102030:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102033:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102037:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010203e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102042:	75 a0                	jne    c0101fe4 <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0102044:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102047:	83 c4 50             	add    $0x50,%esp
c010204a:	5b                   	pop    %ebx
c010204b:	5e                   	pop    %esi
c010204c:	5d                   	pop    %ebp
c010204d:	c3                   	ret    

c010204e <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010204e:	55                   	push   %ebp
c010204f:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0102051:	fb                   	sti    
    sti();
}
c0102052:	5d                   	pop    %ebp
c0102053:	c3                   	ret    

c0102054 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102054:	55                   	push   %ebp
c0102055:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0102057:	fa                   	cli    
    cli();
}
c0102058:	5d                   	pop    %ebp
c0102059:	c3                   	ret    

c010205a <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010205a:	55                   	push   %ebp
c010205b:	89 e5                	mov    %esp,%ebp
c010205d:	83 ec 14             	sub    $0x14,%esp
c0102060:	8b 45 08             	mov    0x8(%ebp),%eax
c0102063:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0102067:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010206b:	66 a3 50 a5 12 c0    	mov    %ax,0xc012a550
    if (did_init) {
c0102071:	a1 60 e7 19 c0       	mov    0xc019e760,%eax
c0102076:	85 c0                	test   %eax,%eax
c0102078:	74 36                	je     c01020b0 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c010207a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010207e:	0f b6 c0             	movzbl %al,%eax
c0102081:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0102087:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010208a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010208e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102092:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0102093:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102097:	66 c1 e8 08          	shr    $0x8,%ax
c010209b:	0f b6 c0             	movzbl %al,%eax
c010209e:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01020a4:	88 45 f9             	mov    %al,-0x7(%ebp)
c01020a7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020ab:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020af:	ee                   	out    %al,(%dx)
    }
}
c01020b0:	c9                   	leave  
c01020b1:	c3                   	ret    

c01020b2 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01020b2:	55                   	push   %ebp
c01020b3:	89 e5                	mov    %esp,%ebp
c01020b5:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01020b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01020bb:	ba 01 00 00 00       	mov    $0x1,%edx
c01020c0:	89 c1                	mov    %eax,%ecx
c01020c2:	d3 e2                	shl    %cl,%edx
c01020c4:	89 d0                	mov    %edx,%eax
c01020c6:	f7 d0                	not    %eax
c01020c8:	89 c2                	mov    %eax,%edx
c01020ca:	0f b7 05 50 a5 12 c0 	movzwl 0xc012a550,%eax
c01020d1:	21 d0                	and    %edx,%eax
c01020d3:	0f b7 c0             	movzwl %ax,%eax
c01020d6:	89 04 24             	mov    %eax,(%esp)
c01020d9:	e8 7c ff ff ff       	call   c010205a <pic_setmask>
}
c01020de:	c9                   	leave  
c01020df:	c3                   	ret    

c01020e0 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020e0:	55                   	push   %ebp
c01020e1:	89 e5                	mov    %esp,%ebp
c01020e3:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020e6:	c7 05 60 e7 19 c0 01 	movl   $0x1,0xc019e760
c01020ed:	00 00 00 
c01020f0:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020f6:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01020fa:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020fe:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102102:	ee                   	out    %al,(%dx)
c0102103:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102109:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010210d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102111:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102115:	ee                   	out    %al,(%dx)
c0102116:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010211c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102120:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102124:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102128:	ee                   	out    %al,(%dx)
c0102129:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010212f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0102133:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102137:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010213b:	ee                   	out    %al,(%dx)
c010213c:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0102142:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c0102146:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010214a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010214e:	ee                   	out    %al,(%dx)
c010214f:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0102155:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102159:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010215d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102161:	ee                   	out    %al,(%dx)
c0102162:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102168:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c010216c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102170:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102174:	ee                   	out    %al,(%dx)
c0102175:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c010217b:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c010217f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102183:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102187:	ee                   	out    %al,(%dx)
c0102188:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010218e:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0102192:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102196:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010219a:	ee                   	out    %al,(%dx)
c010219b:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c01021a1:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01021a5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01021a9:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01021ad:	ee                   	out    %al,(%dx)
c01021ae:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01021b4:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01021b8:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01021bc:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01021c0:	ee                   	out    %al,(%dx)
c01021c1:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021c7:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01021cb:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021cf:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021d3:	ee                   	out    %al,(%dx)
c01021d4:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01021da:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01021de:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021e2:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021e6:	ee                   	out    %al,(%dx)
c01021e7:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01021ed:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01021f1:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01021f5:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01021f9:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021fa:	0f b7 05 50 a5 12 c0 	movzwl 0xc012a550,%eax
c0102201:	66 83 f8 ff          	cmp    $0xffff,%ax
c0102205:	74 12                	je     c0102219 <pic_init+0x139>
        pic_setmask(irq_mask);
c0102207:	0f b7 05 50 a5 12 c0 	movzwl 0xc012a550,%eax
c010220e:	0f b7 c0             	movzwl %ax,%eax
c0102211:	89 04 24             	mov    %eax,(%esp)
c0102214:	e8 41 fe ff ff       	call   c010205a <pic_setmask>
    }
}
c0102219:	c9                   	leave  
c010221a:	c3                   	ret    

c010221b <print_ticks>:
#include <sched.h>
#include <sync.h>

#define TICK_NUM 100

static void print_ticks() {
c010221b:	55                   	push   %ebp
c010221c:	89 e5                	mov    %esp,%ebp
c010221e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102221:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102228:	00 
c0102229:	c7 04 24 80 c4 10 c0 	movl   $0xc010c480,(%esp)
c0102230:	e8 2a e1 ff ff       	call   c010035f <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0102235:	c7 04 24 8a c4 10 c0 	movl   $0xc010c48a,(%esp)
c010223c:	e8 1e e1 ff ff       	call   c010035f <cprintf>
    panic("EOT: kernel seems ok.");
c0102241:	c7 44 24 08 98 c4 10 	movl   $0xc010c498,0x8(%esp)
c0102248:	c0 
c0102249:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0102250:	00 
c0102251:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c0102258:	e8 8e eb ff ff       	call   c0100deb <__panic>

c010225d <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010225d:	55                   	push   %ebp
c010225e:	89 e5                	mov    %esp,%ebp
c0102260:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c0102263:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010226a:	e9 c3 00 00 00       	jmp    c0102332 <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010226f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102272:	8b 04 85 e0 a5 12 c0 	mov    -0x3fed5a20(,%eax,4),%eax
c0102279:	89 c2                	mov    %eax,%edx
c010227b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010227e:	66 89 14 c5 80 e7 19 	mov    %dx,-0x3fe61880(,%eax,8)
c0102285:	c0 
c0102286:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102289:	66 c7 04 c5 82 e7 19 	movw   $0x8,-0x3fe6187e(,%eax,8)
c0102290:	c0 08 00 
c0102293:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102296:	0f b6 14 c5 84 e7 19 	movzbl -0x3fe6187c(,%eax,8),%edx
c010229d:	c0 
c010229e:	83 e2 e0             	and    $0xffffffe0,%edx
c01022a1:	88 14 c5 84 e7 19 c0 	mov    %dl,-0x3fe6187c(,%eax,8)
c01022a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022ab:	0f b6 14 c5 84 e7 19 	movzbl -0x3fe6187c(,%eax,8),%edx
c01022b2:	c0 
c01022b3:	83 e2 1f             	and    $0x1f,%edx
c01022b6:	88 14 c5 84 e7 19 c0 	mov    %dl,-0x3fe6187c(,%eax,8)
c01022bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022c0:	0f b6 14 c5 85 e7 19 	movzbl -0x3fe6187b(,%eax,8),%edx
c01022c7:	c0 
c01022c8:	83 e2 f0             	and    $0xfffffff0,%edx
c01022cb:	83 ca 0e             	or     $0xe,%edx
c01022ce:	88 14 c5 85 e7 19 c0 	mov    %dl,-0x3fe6187b(,%eax,8)
c01022d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022d8:	0f b6 14 c5 85 e7 19 	movzbl -0x3fe6187b(,%eax,8),%edx
c01022df:	c0 
c01022e0:	83 e2 ef             	and    $0xffffffef,%edx
c01022e3:	88 14 c5 85 e7 19 c0 	mov    %dl,-0x3fe6187b(,%eax,8)
c01022ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022ed:	0f b6 14 c5 85 e7 19 	movzbl -0x3fe6187b(,%eax,8),%edx
c01022f4:	c0 
c01022f5:	83 e2 9f             	and    $0xffffff9f,%edx
c01022f8:	88 14 c5 85 e7 19 c0 	mov    %dl,-0x3fe6187b(,%eax,8)
c01022ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102302:	0f b6 14 c5 85 e7 19 	movzbl -0x3fe6187b(,%eax,8),%edx
c0102309:	c0 
c010230a:	83 ca 80             	or     $0xffffff80,%edx
c010230d:	88 14 c5 85 e7 19 c0 	mov    %dl,-0x3fe6187b(,%eax,8)
c0102314:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102317:	8b 04 85 e0 a5 12 c0 	mov    -0x3fed5a20(,%eax,4),%eax
c010231e:	c1 e8 10             	shr    $0x10,%eax
c0102321:	89 c2                	mov    %eax,%edx
c0102323:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102326:	66 89 14 c5 86 e7 19 	mov    %dx,-0x3fe6187a(,%eax,8)
c010232d:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c010232e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102332:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102335:	3d ff 00 00 00       	cmp    $0xff,%eax
c010233a:	0f 86 2f ff ff ff    	jbe    c010226f <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
	}
	//SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	//SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], 3);
	SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c0102340:	a1 e0 a7 12 c0       	mov    0xc012a7e0,%eax
c0102345:	66 a3 80 eb 19 c0    	mov    %ax,0xc019eb80
c010234b:	66 c7 05 82 eb 19 c0 	movw   $0x8,0xc019eb82
c0102352:	08 00 
c0102354:	0f b6 05 84 eb 19 c0 	movzbl 0xc019eb84,%eax
c010235b:	83 e0 e0             	and    $0xffffffe0,%eax
c010235e:	a2 84 eb 19 c0       	mov    %al,0xc019eb84
c0102363:	0f b6 05 84 eb 19 c0 	movzbl 0xc019eb84,%eax
c010236a:	83 e0 1f             	and    $0x1f,%eax
c010236d:	a2 84 eb 19 c0       	mov    %al,0xc019eb84
c0102372:	0f b6 05 85 eb 19 c0 	movzbl 0xc019eb85,%eax
c0102379:	83 c8 0f             	or     $0xf,%eax
c010237c:	a2 85 eb 19 c0       	mov    %al,0xc019eb85
c0102381:	0f b6 05 85 eb 19 c0 	movzbl 0xc019eb85,%eax
c0102388:	83 e0 ef             	and    $0xffffffef,%eax
c010238b:	a2 85 eb 19 c0       	mov    %al,0xc019eb85
c0102390:	0f b6 05 85 eb 19 c0 	movzbl 0xc019eb85,%eax
c0102397:	83 c8 60             	or     $0x60,%eax
c010239a:	a2 85 eb 19 c0       	mov    %al,0xc019eb85
c010239f:	0f b6 05 85 eb 19 c0 	movzbl 0xc019eb85,%eax
c01023a6:	83 c8 80             	or     $0xffffff80,%eax
c01023a9:	a2 85 eb 19 c0       	mov    %al,0xc019eb85
c01023ae:	a1 e0 a7 12 c0       	mov    0xc012a7e0,%eax
c01023b3:	c1 e8 10             	shr    $0x10,%eax
c01023b6:	66 a3 86 eb 19 c0    	mov    %ax,0xc019eb86
c01023bc:	c7 45 f8 60 a5 12 c0 	movl   $0xc012a560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01023c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01023c6:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here

}
c01023c9:	c9                   	leave  
c01023ca:	c3                   	ret    

c01023cb <trapname>:

static const char *
trapname(int trapno) {
c01023cb:	55                   	push   %ebp
c01023cc:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d1:	83 f8 13             	cmp    $0x13,%eax
c01023d4:	77 0c                	ja     c01023e2 <trapname+0x17>
        return excnames[trapno];
c01023d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d9:	8b 04 85 20 c9 10 c0 	mov    -0x3fef36e0(,%eax,4),%eax
c01023e0:	eb 18                	jmp    c01023fa <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023e2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023e6:	7e 0d                	jle    c01023f5 <trapname+0x2a>
c01023e8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023ec:	7f 07                	jg     c01023f5 <trapname+0x2a>
        return "Hardware Interrupt";
c01023ee:	b8 bf c4 10 c0       	mov    $0xc010c4bf,%eax
c01023f3:	eb 05                	jmp    c01023fa <trapname+0x2f>
    }
    return "(unknown trap)";
c01023f5:	b8 d2 c4 10 c0       	mov    $0xc010c4d2,%eax
}
c01023fa:	5d                   	pop    %ebp
c01023fb:	c3                   	ret    

c01023fc <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023fc:	55                   	push   %ebp
c01023fd:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102402:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102406:	66 83 f8 08          	cmp    $0x8,%ax
c010240a:	0f 94 c0             	sete   %al
c010240d:	0f b6 c0             	movzbl %al,%eax
}
c0102410:	5d                   	pop    %ebp
c0102411:	c3                   	ret    

c0102412 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102412:	55                   	push   %ebp
c0102413:	89 e5                	mov    %esp,%ebp
c0102415:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102418:	8b 45 08             	mov    0x8(%ebp),%eax
c010241b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010241f:	c7 04 24 13 c5 10 c0 	movl   $0xc010c513,(%esp)
c0102426:	e8 34 df ff ff       	call   c010035f <cprintf>
    print_regs(&tf->tf_regs);
c010242b:	8b 45 08             	mov    0x8(%ebp),%eax
c010242e:	89 04 24             	mov    %eax,(%esp)
c0102431:	e8 a1 01 00 00       	call   c01025d7 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102436:	8b 45 08             	mov    0x8(%ebp),%eax
c0102439:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010243d:	0f b7 c0             	movzwl %ax,%eax
c0102440:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102444:	c7 04 24 24 c5 10 c0 	movl   $0xc010c524,(%esp)
c010244b:	e8 0f df ff ff       	call   c010035f <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102450:	8b 45 08             	mov    0x8(%ebp),%eax
c0102453:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102457:	0f b7 c0             	movzwl %ax,%eax
c010245a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010245e:	c7 04 24 37 c5 10 c0 	movl   $0xc010c537,(%esp)
c0102465:	e8 f5 de ff ff       	call   c010035f <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010246a:	8b 45 08             	mov    0x8(%ebp),%eax
c010246d:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102471:	0f b7 c0             	movzwl %ax,%eax
c0102474:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102478:	c7 04 24 4a c5 10 c0 	movl   $0xc010c54a,(%esp)
c010247f:	e8 db de ff ff       	call   c010035f <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102484:	8b 45 08             	mov    0x8(%ebp),%eax
c0102487:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010248b:	0f b7 c0             	movzwl %ax,%eax
c010248e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102492:	c7 04 24 5d c5 10 c0 	movl   $0xc010c55d,(%esp)
c0102499:	e8 c1 de ff ff       	call   c010035f <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010249e:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a1:	8b 40 30             	mov    0x30(%eax),%eax
c01024a4:	89 04 24             	mov    %eax,(%esp)
c01024a7:	e8 1f ff ff ff       	call   c01023cb <trapname>
c01024ac:	8b 55 08             	mov    0x8(%ebp),%edx
c01024af:	8b 52 30             	mov    0x30(%edx),%edx
c01024b2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01024b6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01024ba:	c7 04 24 70 c5 10 c0 	movl   $0xc010c570,(%esp)
c01024c1:	e8 99 de ff ff       	call   c010035f <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01024c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c9:	8b 40 34             	mov    0x34(%eax),%eax
c01024cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d0:	c7 04 24 82 c5 10 c0 	movl   $0xc010c582,(%esp)
c01024d7:	e8 83 de ff ff       	call   c010035f <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01024df:	8b 40 38             	mov    0x38(%eax),%eax
c01024e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e6:	c7 04 24 91 c5 10 c0 	movl   $0xc010c591,(%esp)
c01024ed:	e8 6d de ff ff       	call   c010035f <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024f9:	0f b7 c0             	movzwl %ax,%eax
c01024fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102500:	c7 04 24 a0 c5 10 c0 	movl   $0xc010c5a0,(%esp)
c0102507:	e8 53 de ff ff       	call   c010035f <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010250c:	8b 45 08             	mov    0x8(%ebp),%eax
c010250f:	8b 40 40             	mov    0x40(%eax),%eax
c0102512:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102516:	c7 04 24 b3 c5 10 c0 	movl   $0xc010c5b3,(%esp)
c010251d:	e8 3d de ff ff       	call   c010035f <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102522:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102529:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102530:	eb 3e                	jmp    c0102570 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102532:	8b 45 08             	mov    0x8(%ebp),%eax
c0102535:	8b 50 40             	mov    0x40(%eax),%edx
c0102538:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010253b:	21 d0                	and    %edx,%eax
c010253d:	85 c0                	test   %eax,%eax
c010253f:	74 28                	je     c0102569 <print_trapframe+0x157>
c0102541:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102544:	8b 04 85 80 a5 12 c0 	mov    -0x3fed5a80(,%eax,4),%eax
c010254b:	85 c0                	test   %eax,%eax
c010254d:	74 1a                	je     c0102569 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c010254f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102552:	8b 04 85 80 a5 12 c0 	mov    -0x3fed5a80(,%eax,4),%eax
c0102559:	89 44 24 04          	mov    %eax,0x4(%esp)
c010255d:	c7 04 24 c2 c5 10 c0 	movl   $0xc010c5c2,(%esp)
c0102564:	e8 f6 dd ff ff       	call   c010035f <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010256d:	d1 65 f0             	shll   -0x10(%ebp)
c0102570:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102573:	83 f8 17             	cmp    $0x17,%eax
c0102576:	76 ba                	jbe    c0102532 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102578:	8b 45 08             	mov    0x8(%ebp),%eax
c010257b:	8b 40 40             	mov    0x40(%eax),%eax
c010257e:	25 00 30 00 00       	and    $0x3000,%eax
c0102583:	c1 e8 0c             	shr    $0xc,%eax
c0102586:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258a:	c7 04 24 c6 c5 10 c0 	movl   $0xc010c5c6,(%esp)
c0102591:	e8 c9 dd ff ff       	call   c010035f <cprintf>

    if (!trap_in_kernel(tf)) {
c0102596:	8b 45 08             	mov    0x8(%ebp),%eax
c0102599:	89 04 24             	mov    %eax,(%esp)
c010259c:	e8 5b fe ff ff       	call   c01023fc <trap_in_kernel>
c01025a1:	85 c0                	test   %eax,%eax
c01025a3:	75 30                	jne    c01025d5 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01025a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a8:	8b 40 44             	mov    0x44(%eax),%eax
c01025ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025af:	c7 04 24 cf c5 10 c0 	movl   $0xc010c5cf,(%esp)
c01025b6:	e8 a4 dd ff ff       	call   c010035f <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01025bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025be:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01025c2:	0f b7 c0             	movzwl %ax,%eax
c01025c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c9:	c7 04 24 de c5 10 c0 	movl   $0xc010c5de,(%esp)
c01025d0:	e8 8a dd ff ff       	call   c010035f <cprintf>
    }
}
c01025d5:	c9                   	leave  
c01025d6:	c3                   	ret    

c01025d7 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025d7:	55                   	push   %ebp
c01025d8:	89 e5                	mov    %esp,%ebp
c01025da:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e0:	8b 00                	mov    (%eax),%eax
c01025e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025e6:	c7 04 24 f1 c5 10 c0 	movl   $0xc010c5f1,(%esp)
c01025ed:	e8 6d dd ff ff       	call   c010035f <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f5:	8b 40 04             	mov    0x4(%eax),%eax
c01025f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025fc:	c7 04 24 00 c6 10 c0 	movl   $0xc010c600,(%esp)
c0102603:	e8 57 dd ff ff       	call   c010035f <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102608:	8b 45 08             	mov    0x8(%ebp),%eax
c010260b:	8b 40 08             	mov    0x8(%eax),%eax
c010260e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102612:	c7 04 24 0f c6 10 c0 	movl   $0xc010c60f,(%esp)
c0102619:	e8 41 dd ff ff       	call   c010035f <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010261e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102621:	8b 40 0c             	mov    0xc(%eax),%eax
c0102624:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102628:	c7 04 24 1e c6 10 c0 	movl   $0xc010c61e,(%esp)
c010262f:	e8 2b dd ff ff       	call   c010035f <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102634:	8b 45 08             	mov    0x8(%ebp),%eax
c0102637:	8b 40 10             	mov    0x10(%eax),%eax
c010263a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010263e:	c7 04 24 2d c6 10 c0 	movl   $0xc010c62d,(%esp)
c0102645:	e8 15 dd ff ff       	call   c010035f <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010264a:	8b 45 08             	mov    0x8(%ebp),%eax
c010264d:	8b 40 14             	mov    0x14(%eax),%eax
c0102650:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102654:	c7 04 24 3c c6 10 c0 	movl   $0xc010c63c,(%esp)
c010265b:	e8 ff dc ff ff       	call   c010035f <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102660:	8b 45 08             	mov    0x8(%ebp),%eax
c0102663:	8b 40 18             	mov    0x18(%eax),%eax
c0102666:	89 44 24 04          	mov    %eax,0x4(%esp)
c010266a:	c7 04 24 4b c6 10 c0 	movl   $0xc010c64b,(%esp)
c0102671:	e8 e9 dc ff ff       	call   c010035f <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102676:	8b 45 08             	mov    0x8(%ebp),%eax
c0102679:	8b 40 1c             	mov    0x1c(%eax),%eax
c010267c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102680:	c7 04 24 5a c6 10 c0 	movl   $0xc010c65a,(%esp)
c0102687:	e8 d3 dc ff ff       	call   c010035f <cprintf>
}
c010268c:	c9                   	leave  
c010268d:	c3                   	ret    

c010268e <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010268e:	55                   	push   %ebp
c010268f:	89 e5                	mov    %esp,%ebp
c0102691:	53                   	push   %ebx
c0102692:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102695:	8b 45 08             	mov    0x8(%ebp),%eax
c0102698:	8b 40 34             	mov    0x34(%eax),%eax
c010269b:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010269e:	85 c0                	test   %eax,%eax
c01026a0:	74 07                	je     c01026a9 <print_pgfault+0x1b>
c01026a2:	b9 69 c6 10 c0       	mov    $0xc010c669,%ecx
c01026a7:	eb 05                	jmp    c01026ae <print_pgfault+0x20>
c01026a9:	b9 7a c6 10 c0       	mov    $0xc010c67a,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c01026ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b1:	8b 40 34             	mov    0x34(%eax),%eax
c01026b4:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026b7:	85 c0                	test   %eax,%eax
c01026b9:	74 07                	je     c01026c2 <print_pgfault+0x34>
c01026bb:	ba 57 00 00 00       	mov    $0x57,%edx
c01026c0:	eb 05                	jmp    c01026c7 <print_pgfault+0x39>
c01026c2:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01026c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01026ca:	8b 40 34             	mov    0x34(%eax),%eax
c01026cd:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026d0:	85 c0                	test   %eax,%eax
c01026d2:	74 07                	je     c01026db <print_pgfault+0x4d>
c01026d4:	b8 55 00 00 00       	mov    $0x55,%eax
c01026d9:	eb 05                	jmp    c01026e0 <print_pgfault+0x52>
c01026db:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026e0:	0f 20 d3             	mov    %cr2,%ebx
c01026e3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01026e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01026e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01026ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01026f1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01026f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01026f9:	c7 04 24 88 c6 10 c0 	movl   $0xc010c688,(%esp)
c0102700:	e8 5a dc ff ff       	call   c010035f <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c0102705:	83 c4 34             	add    $0x34,%esp
c0102708:	5b                   	pop    %ebx
c0102709:	5d                   	pop    %ebp
c010270a:	c3                   	ret    

c010270b <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010270b:	55                   	push   %ebp
c010270c:	89 e5                	mov    %esp,%ebp
c010270e:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c0102711:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c0102716:	85 c0                	test   %eax,%eax
c0102718:	74 0b                	je     c0102725 <pgfault_handler+0x1a>
            print_pgfault(tf);
c010271a:	8b 45 08             	mov    0x8(%ebp),%eax
c010271d:	89 04 24             	mov    %eax,(%esp)
c0102720:	e8 69 ff ff ff       	call   c010268e <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c0102725:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c010272a:	85 c0                	test   %eax,%eax
c010272c:	74 3d                	je     c010276b <pgfault_handler+0x60>
        assert(current == idleproc);
c010272e:	8b 15 48 f0 19 c0    	mov    0xc019f048,%edx
c0102734:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c0102739:	39 c2                	cmp    %eax,%edx
c010273b:	74 24                	je     c0102761 <pgfault_handler+0x56>
c010273d:	c7 44 24 0c ab c6 10 	movl   $0xc010c6ab,0xc(%esp)
c0102744:	c0 
c0102745:	c7 44 24 08 bf c6 10 	movl   $0xc010c6bf,0x8(%esp)
c010274c:	c0 
c010274d:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0102754:	00 
c0102755:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c010275c:	e8 8a e6 ff ff       	call   c0100deb <__panic>
        mm = check_mm_struct;
c0102761:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c0102766:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102769:	eb 46                	jmp    c01027b1 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c010276b:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102770:	85 c0                	test   %eax,%eax
c0102772:	75 32                	jne    c01027a6 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102774:	8b 45 08             	mov    0x8(%ebp),%eax
c0102777:	89 04 24             	mov    %eax,(%esp)
c010277a:	e8 93 fc ff ff       	call   c0102412 <print_trapframe>
            print_pgfault(tf);
c010277f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102782:	89 04 24             	mov    %eax,(%esp)
c0102785:	e8 04 ff ff ff       	call   c010268e <print_pgfault>
            panic("unhandled page fault.\n");
c010278a:	c7 44 24 08 d4 c6 10 	movl   $0xc010c6d4,0x8(%esp)
c0102791:	c0 
c0102792:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0102799:	00 
c010279a:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c01027a1:	e8 45 e6 ff ff       	call   c0100deb <__panic>
        }
        mm = current->mm;
c01027a6:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c01027ab:	8b 40 18             	mov    0x18(%eax),%eax
c01027ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01027b1:	0f 20 d0             	mov    %cr2,%eax
c01027b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c01027b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c01027ba:	89 c2                	mov    %eax,%edx
c01027bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01027bf:	8b 40 34             	mov    0x34(%eax),%eax
c01027c2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027cd:	89 04 24             	mov    %eax,(%esp)
c01027d0:	e8 5a 67 00 00       	call   c0108f2f <do_pgfault>
}
c01027d5:	c9                   	leave  
c01027d6:	c3                   	ret    

c01027d7 <trap_dispatch>:

/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

static void
trap_dispatch(struct trapframe *tf) {
c01027d7:	55                   	push   %ebp
c01027d8:	89 e5                	mov    %esp,%ebp
c01027da:	57                   	push   %edi
c01027db:	56                   	push   %esi
c01027dc:	53                   	push   %ebx
c01027dd:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    int ret=0;
c01027e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    switch (tf->tf_trapno) {
c01027e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01027ea:	8b 40 30             	mov    0x30(%eax),%eax
c01027ed:	83 f8 2f             	cmp    $0x2f,%eax
c01027f0:	77 38                	ja     c010282a <trap_dispatch+0x53>
c01027f2:	83 f8 2e             	cmp    $0x2e,%eax
c01027f5:	0f 83 11 03 00 00    	jae    c0102b0c <trap_dispatch+0x335>
c01027fb:	83 f8 20             	cmp    $0x20,%eax
c01027fe:	0f 84 07 01 00 00    	je     c010290b <trap_dispatch+0x134>
c0102804:	83 f8 20             	cmp    $0x20,%eax
c0102807:	77 0a                	ja     c0102813 <trap_dispatch+0x3c>
c0102809:	83 f8 0e             	cmp    $0xe,%eax
c010280c:	74 3e                	je     c010284c <trap_dispatch+0x75>
c010280e:	e9 b1 02 00 00       	jmp    c0102ac4 <trap_dispatch+0x2ed>
c0102813:	83 f8 21             	cmp    $0x21,%eax
c0102816:	0f 84 87 01 00 00    	je     c01029a3 <trap_dispatch+0x1cc>
c010281c:	83 f8 24             	cmp    $0x24,%eax
c010281f:	0f 84 55 01 00 00    	je     c010297a <trap_dispatch+0x1a3>
c0102825:	e9 9a 02 00 00       	jmp    c0102ac4 <trap_dispatch+0x2ed>
c010282a:	83 f8 79             	cmp    $0x79,%eax
c010282d:	0f 84 18 02 00 00    	je     c0102a4b <trap_dispatch+0x274>
c0102833:	3d 80 00 00 00       	cmp    $0x80,%eax
c0102838:	0f 84 c3 00 00 00    	je     c0102901 <trap_dispatch+0x12a>
c010283e:	83 f8 78             	cmp    $0x78,%eax
c0102841:	0f 84 85 01 00 00    	je     c01029cc <trap_dispatch+0x1f5>
c0102847:	e9 78 02 00 00       	jmp    c0102ac4 <trap_dispatch+0x2ed>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010284c:	8b 45 08             	mov    0x8(%ebp),%eax
c010284f:	89 04 24             	mov    %eax,(%esp)
c0102852:	e8 b4 fe ff ff       	call   c010270b <pgfault_handler>
c0102857:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010285a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010285e:	0f 84 98 00 00 00    	je     c01028fc <trap_dispatch+0x125>
            print_trapframe(tf);
c0102864:	8b 45 08             	mov    0x8(%ebp),%eax
c0102867:	89 04 24             	mov    %eax,(%esp)
c010286a:	e8 a3 fb ff ff       	call   c0102412 <print_trapframe>
            if (current == NULL) {
c010286f:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102874:	85 c0                	test   %eax,%eax
c0102876:	75 23                	jne    c010289b <trap_dispatch+0xc4>
                panic("handle pgfault failed. ret=%d\n", ret);
c0102878:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010287b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010287f:	c7 44 24 08 ec c6 10 	movl   $0xc010c6ec,0x8(%esp)
c0102886:	c0 
c0102887:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c010288e:	00 
c010288f:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c0102896:	e8 50 e5 ff ff       	call   c0100deb <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c010289b:	8b 45 08             	mov    0x8(%ebp),%eax
c010289e:	89 04 24             	mov    %eax,(%esp)
c01028a1:	e8 56 fb ff ff       	call   c01023fc <trap_in_kernel>
c01028a6:	85 c0                	test   %eax,%eax
c01028a8:	74 23                	je     c01028cd <trap_dispatch+0xf6>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c01028aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01028ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028b1:	c7 44 24 08 0c c7 10 	movl   $0xc010c70c,0x8(%esp)
c01028b8:	c0 
c01028b9:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c01028c0:	00 
c01028c1:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c01028c8:	e8 1e e5 ff ff       	call   c0100deb <__panic>
                }
                cprintf("killed by kernel.\n");
c01028cd:	c7 04 24 3a c7 10 c0 	movl   $0xc010c73a,(%esp)
c01028d4:	e8 86 da ff ff       	call   c010035f <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c01028d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01028dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028e0:	c7 44 24 08 50 c7 10 	movl   $0xc010c750,0x8(%esp)
c01028e7:	c0 
c01028e8:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c01028ef:	00 
c01028f0:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c01028f7:	e8 ef e4 ff ff       	call   c0100deb <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
c01028fc:	e9 0c 02 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
    case T_SYSCALL:
        syscall();
c0102901:	e8 e0 89 00 00       	call   c010b2e6 <syscall>
        break;
c0102906:	e9 02 02 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks++;
c010290b:	a1 74 10 1a c0       	mov    0xc01a1074,%eax
c0102910:	83 c0 01             	add    $0x1,%eax
c0102913:	a3 74 10 1a c0       	mov    %eax,0xc01a1074
	if(ticks % TICK_NUM == 0){
c0102918:	8b 0d 74 10 1a c0    	mov    0xc01a1074,%ecx
c010291e:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102923:	89 c8                	mov    %ecx,%eax
c0102925:	f7 e2                	mul    %edx
c0102927:	89 d0                	mov    %edx,%eax
c0102929:	c1 e8 05             	shr    $0x5,%eax
c010292c:	6b c0 64             	imul   $0x64,%eax,%eax
c010292f:	29 c1                	sub    %eax,%ecx
c0102931:	89 c8                	mov    %ecx,%eax
c0102933:	85 c0                	test   %eax,%eax
c0102935:	75 3e                	jne    c0102975 <trap_dispatch+0x19e>
		//print_ticks();	
            assert(current != NULL);
c0102937:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010293c:	85 c0                	test   %eax,%eax
c010293e:	75 24                	jne    c0102964 <trap_dispatch+0x18d>
c0102940:	c7 44 24 0c 79 c7 10 	movl   $0xc010c779,0xc(%esp)
c0102947:	c0 
c0102948:	c7 44 24 08 bf c6 10 	movl   $0xc010c6bf,0x8(%esp)
c010294f:	c0 
c0102950:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0102957:	00 
c0102958:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c010295f:	e8 87 e4 ff ff       	call   c0100deb <__panic>
            current->need_resched = 1;
c0102964:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102969:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
	}
        break;
c0102970:	e9 98 01 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
c0102975:	e9 93 01 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
  
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c010297a:	e8 eb ed ff ff       	call   c010176a <cons_getc>
c010297f:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102982:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0102986:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c010298a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010298e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102992:	c7 04 24 89 c7 10 c0 	movl   $0xc010c789,(%esp)
c0102999:	e8 c1 d9 ff ff       	call   c010035f <cprintf>
        break;
c010299e:	e9 6a 01 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01029a3:	e8 c2 ed ff ff       	call   c010176a <cons_getc>
c01029a8:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01029ab:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c01029af:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c01029b3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01029b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01029bb:	c7 04 24 9b c7 10 c0 	movl   $0xc010c79b,(%esp)
c01029c2:	e8 98 d9 ff ff       	call   c010035f <cprintf>
        break;
c01029c7:	e9 41 01 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
	if (tf->tf_cs != USER_CS) {
c01029cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01029cf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01029d3:	66 83 f8 1b          	cmp    $0x1b,%ax
c01029d7:	74 6d                	je     c0102a46 <trap_dispatch+0x26f>
            switchk2u = *tf;
c01029d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01029dc:	ba 80 10 1a c0       	mov    $0xc01a1080,%edx
c01029e1:	89 c3                	mov    %eax,%ebx
c01029e3:	b8 13 00 00 00       	mov    $0x13,%eax
c01029e8:	89 d7                	mov    %edx,%edi
c01029ea:	89 de                	mov    %ebx,%esi
c01029ec:	89 c1                	mov    %eax,%ecx
c01029ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
c01029f0:	66 c7 05 bc 10 1a c0 	movw   $0x1b,0xc01a10bc
c01029f7:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c01029f9:	66 c7 05 c8 10 1a c0 	movw   $0x23,0xc01a10c8
c0102a00:	23 00 
c0102a02:	0f b7 05 c8 10 1a c0 	movzwl 0xc01a10c8,%eax
c0102a09:	66 a3 a8 10 1a c0    	mov    %ax,0xc01a10a8
c0102a0f:	0f b7 05 a8 10 1a c0 	movzwl 0xc01a10a8,%eax
c0102a16:	66 a3 ac 10 1a c0    	mov    %ax,0xc01a10ac
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c0102a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a1f:	83 c0 44             	add    $0x44,%eax
c0102a22:	a3 c4 10 1a c0       	mov    %eax,0xc01a10c4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c0102a27:	a1 c0 10 1a c0       	mov    0xc01a10c0,%eax
c0102a2c:	80 cc 30             	or     $0x30,%ah
c0102a2f:	a3 c0 10 1a c0       	mov    %eax,0xc01a10c0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0102a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a37:	8d 50 fc             	lea    -0x4(%eax),%edx
c0102a3a:	b8 80 10 1a c0       	mov    $0xc01a1080,%eax
c0102a3f:	89 02                	mov    %eax,(%edx)
        }
        break;
c0102a41:	e9 c7 00 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
c0102a46:	e9 c2 00 00 00       	jmp    c0102b0d <trap_dispatch+0x336>
	tf->tf_ds = USER_DS;
	tf->tf_es = USER_DS;
	tf->tf_ss = USER_DS;
	break;*/
    case T_SWITCH_TOK:
	if (tf->tf_cs != KERNEL_CS) {
c0102a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a4e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102a52:	66 83 f8 08          	cmp    $0x8,%ax
c0102a56:	74 6a                	je     c0102ac2 <trap_dispatch+0x2eb>
            tf->tf_cs = KERNEL_CS;
c0102a58:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a5b:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0102a61:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a64:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0102a6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a6d:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102a71:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a74:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0102a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a7b:	8b 40 40             	mov    0x40(%eax),%eax
c0102a7e:	80 e4 cf             	and    $0xcf,%ah
c0102a81:	89 c2                	mov    %eax,%edx
c0102a83:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a86:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0102a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a8c:	8b 40 44             	mov    0x44(%eax),%eax
c0102a8f:	83 e8 44             	sub    $0x44,%eax
c0102a92:	a3 cc 10 1a c0       	mov    %eax,0xc01a10cc
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102a97:	a1 cc 10 1a c0       	mov    0xc01a10cc,%eax
c0102a9c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0102aa3:	00 
c0102aa4:	8b 55 08             	mov    0x8(%ebp),%edx
c0102aa7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102aab:	89 04 24             	mov    %eax,(%esp)
c0102aae:	e8 e5 93 00 00       	call   c010be98 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0102ab3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ab6:	8d 50 fc             	lea    -0x4(%eax),%edx
c0102ab9:	a1 cc 10 1a c0       	mov    0xc01a10cc,%eax
c0102abe:	89 02                	mov    %eax,(%edx)
        }
        break;
c0102ac0:	eb 4b                	jmp    c0102b0d <trap_dispatch+0x336>
c0102ac2:	eb 49                	jmp    c0102b0d <trap_dispatch+0x336>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c0102ac4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ac7:	89 04 24             	mov    %eax,(%esp)
c0102aca:	e8 43 f9 ff ff       	call   c0102412 <print_trapframe>
        if (current != NULL) {
c0102acf:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102ad4:	85 c0                	test   %eax,%eax
c0102ad6:	74 18                	je     c0102af0 <trap_dispatch+0x319>
            cprintf("unhandled trap.\n");
c0102ad8:	c7 04 24 aa c7 10 c0 	movl   $0xc010c7aa,(%esp)
c0102adf:	e8 7b d8 ff ff       	call   c010035f <cprintf>
            do_exit(-E_KILLED);
c0102ae4:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102aeb:	e8 99 75 00 00       	call   c010a089 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c0102af0:	c7 44 24 08 bb c7 10 	movl   $0xc010c7bb,0x8(%esp)
c0102af7:	c0 
c0102af8:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0102aff:	00 
c0102b00:	c7 04 24 ae c4 10 c0 	movl   $0xc010c4ae,(%esp)
c0102b07:	e8 df e2 ff ff       	call   c0100deb <__panic>
	tf->tf_es = KERNEL_DS;
        break;*/
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0102b0c:	90                   	nop
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");

    }
}
c0102b0d:	83 c4 2c             	add    $0x2c,%esp
c0102b10:	5b                   	pop    %ebx
c0102b11:	5e                   	pop    %esi
c0102b12:	5f                   	pop    %edi
c0102b13:	5d                   	pop    %ebp
c0102b14:	c3                   	ret    

c0102b15 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102b15:	55                   	push   %ebp
c0102b16:	89 e5                	mov    %esp,%ebp
c0102b18:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c0102b1b:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102b20:	85 c0                	test   %eax,%eax
c0102b22:	75 0d                	jne    c0102b31 <trap+0x1c>
        trap_dispatch(tf);
c0102b24:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b27:	89 04 24             	mov    %eax,(%esp)
c0102b2a:	e8 a8 fc ff ff       	call   c01027d7 <trap_dispatch>
c0102b2f:	eb 6c                	jmp    c0102b9d <trap+0x88>
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c0102b31:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102b36:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102b39:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102b3c:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102b41:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b44:	89 50 3c             	mov    %edx,0x3c(%eax)
    
        bool in_kernel = trap_in_kernel(tf);
c0102b47:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b4a:	89 04 24             	mov    %eax,(%esp)
c0102b4d:	e8 aa f8 ff ff       	call   c01023fc <trap_in_kernel>
c0102b52:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
        trap_dispatch(tf);
c0102b55:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b58:	89 04 24             	mov    %eax,(%esp)
c0102b5b:	e8 77 fc ff ff       	call   c01027d7 <trap_dispatch>
    
        current->tf = otf;
c0102b60:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b68:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102b6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102b6f:	75 2c                	jne    c0102b9d <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102b71:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102b76:	8b 40 44             	mov    0x44(%eax),%eax
c0102b79:	83 e0 01             	and    $0x1,%eax
c0102b7c:	85 c0                	test   %eax,%eax
c0102b7e:	74 0c                	je     c0102b8c <trap+0x77>
                do_exit(-E_KILLED);
c0102b80:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102b87:	e8 fd 74 00 00       	call   c010a089 <do_exit>
            }
            if (current->need_resched) {
c0102b8c:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0102b91:	8b 40 10             	mov    0x10(%eax),%eax
c0102b94:	85 c0                	test   %eax,%eax
c0102b96:	74 05                	je     c0102b9d <trap+0x88>
                schedule();
c0102b98:	e8 51 85 00 00       	call   c010b0ee <schedule>
            }
        }
    }
}
c0102b9d:	c9                   	leave  
c0102b9e:	c3                   	ret    

c0102b9f <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102b9f:	1e                   	push   %ds
    pushl %es
c0102ba0:	06                   	push   %es
    pushl %fs
c0102ba1:	0f a0                	push   %fs
    pushl %gs
c0102ba3:	0f a8                	push   %gs
    pushal
c0102ba5:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102ba6:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102bab:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102bad:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102baf:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102bb0:	e8 60 ff ff ff       	call   c0102b15 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102bb5:	5c                   	pop    %esp

c0102bb6 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102bb6:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102bb7:	0f a9                	pop    %gs
    popl %fs
c0102bb9:	0f a1                	pop    %fs
    popl %es
c0102bbb:	07                   	pop    %es
    popl %ds
c0102bbc:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102bbd:	83 c4 08             	add    $0x8,%esp
    iret
c0102bc0:	cf                   	iret   

c0102bc1 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102bc1:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102bc5:	e9 ec ff ff ff       	jmp    c0102bb6 <__trapret>

c0102bca <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102bca:	6a 00                	push   $0x0
  pushl $0
c0102bcc:	6a 00                	push   $0x0
  jmp __alltraps
c0102bce:	e9 cc ff ff ff       	jmp    c0102b9f <__alltraps>

c0102bd3 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102bd3:	6a 00                	push   $0x0
  pushl $1
c0102bd5:	6a 01                	push   $0x1
  jmp __alltraps
c0102bd7:	e9 c3 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102bdc <vector2>:
.globl vector2
vector2:
  pushl $0
c0102bdc:	6a 00                	push   $0x0
  pushl $2
c0102bde:	6a 02                	push   $0x2
  jmp __alltraps
c0102be0:	e9 ba ff ff ff       	jmp    c0102b9f <__alltraps>

c0102be5 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102be5:	6a 00                	push   $0x0
  pushl $3
c0102be7:	6a 03                	push   $0x3
  jmp __alltraps
c0102be9:	e9 b1 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102bee <vector4>:
.globl vector4
vector4:
  pushl $0
c0102bee:	6a 00                	push   $0x0
  pushl $4
c0102bf0:	6a 04                	push   $0x4
  jmp __alltraps
c0102bf2:	e9 a8 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102bf7 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102bf7:	6a 00                	push   $0x0
  pushl $5
c0102bf9:	6a 05                	push   $0x5
  jmp __alltraps
c0102bfb:	e9 9f ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c00 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102c00:	6a 00                	push   $0x0
  pushl $6
c0102c02:	6a 06                	push   $0x6
  jmp __alltraps
c0102c04:	e9 96 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c09 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102c09:	6a 00                	push   $0x0
  pushl $7
c0102c0b:	6a 07                	push   $0x7
  jmp __alltraps
c0102c0d:	e9 8d ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c12 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102c12:	6a 08                	push   $0x8
  jmp __alltraps
c0102c14:	e9 86 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c19 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102c19:	6a 00                	push   $0x0
  pushl $9
c0102c1b:	6a 09                	push   $0x9
  jmp __alltraps
c0102c1d:	e9 7d ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c22 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102c22:	6a 0a                	push   $0xa
  jmp __alltraps
c0102c24:	e9 76 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c29 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102c29:	6a 0b                	push   $0xb
  jmp __alltraps
c0102c2b:	e9 6f ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c30 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102c30:	6a 0c                	push   $0xc
  jmp __alltraps
c0102c32:	e9 68 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c37 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102c37:	6a 0d                	push   $0xd
  jmp __alltraps
c0102c39:	e9 61 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c3e <vector14>:
.globl vector14
vector14:
  pushl $14
c0102c3e:	6a 0e                	push   $0xe
  jmp __alltraps
c0102c40:	e9 5a ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c45 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102c45:	6a 00                	push   $0x0
  pushl $15
c0102c47:	6a 0f                	push   $0xf
  jmp __alltraps
c0102c49:	e9 51 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c4e <vector16>:
.globl vector16
vector16:
  pushl $0
c0102c4e:	6a 00                	push   $0x0
  pushl $16
c0102c50:	6a 10                	push   $0x10
  jmp __alltraps
c0102c52:	e9 48 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c57 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102c57:	6a 11                	push   $0x11
  jmp __alltraps
c0102c59:	e9 41 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c5e <vector18>:
.globl vector18
vector18:
  pushl $0
c0102c5e:	6a 00                	push   $0x0
  pushl $18
c0102c60:	6a 12                	push   $0x12
  jmp __alltraps
c0102c62:	e9 38 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c67 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102c67:	6a 00                	push   $0x0
  pushl $19
c0102c69:	6a 13                	push   $0x13
  jmp __alltraps
c0102c6b:	e9 2f ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c70 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102c70:	6a 00                	push   $0x0
  pushl $20
c0102c72:	6a 14                	push   $0x14
  jmp __alltraps
c0102c74:	e9 26 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c79 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102c79:	6a 00                	push   $0x0
  pushl $21
c0102c7b:	6a 15                	push   $0x15
  jmp __alltraps
c0102c7d:	e9 1d ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c82 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102c82:	6a 00                	push   $0x0
  pushl $22
c0102c84:	6a 16                	push   $0x16
  jmp __alltraps
c0102c86:	e9 14 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c8b <vector23>:
.globl vector23
vector23:
  pushl $0
c0102c8b:	6a 00                	push   $0x0
  pushl $23
c0102c8d:	6a 17                	push   $0x17
  jmp __alltraps
c0102c8f:	e9 0b ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c94 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102c94:	6a 00                	push   $0x0
  pushl $24
c0102c96:	6a 18                	push   $0x18
  jmp __alltraps
c0102c98:	e9 02 ff ff ff       	jmp    c0102b9f <__alltraps>

c0102c9d <vector25>:
.globl vector25
vector25:
  pushl $0
c0102c9d:	6a 00                	push   $0x0
  pushl $25
c0102c9f:	6a 19                	push   $0x19
  jmp __alltraps
c0102ca1:	e9 f9 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102ca6 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102ca6:	6a 00                	push   $0x0
  pushl $26
c0102ca8:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102caa:	e9 f0 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102caf <vector27>:
.globl vector27
vector27:
  pushl $0
c0102caf:	6a 00                	push   $0x0
  pushl $27
c0102cb1:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102cb3:	e9 e7 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102cb8 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102cb8:	6a 00                	push   $0x0
  pushl $28
c0102cba:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102cbc:	e9 de fe ff ff       	jmp    c0102b9f <__alltraps>

c0102cc1 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102cc1:	6a 00                	push   $0x0
  pushl $29
c0102cc3:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102cc5:	e9 d5 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102cca <vector30>:
.globl vector30
vector30:
  pushl $0
c0102cca:	6a 00                	push   $0x0
  pushl $30
c0102ccc:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102cce:	e9 cc fe ff ff       	jmp    c0102b9f <__alltraps>

c0102cd3 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102cd3:	6a 00                	push   $0x0
  pushl $31
c0102cd5:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102cd7:	e9 c3 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102cdc <vector32>:
.globl vector32
vector32:
  pushl $0
c0102cdc:	6a 00                	push   $0x0
  pushl $32
c0102cde:	6a 20                	push   $0x20
  jmp __alltraps
c0102ce0:	e9 ba fe ff ff       	jmp    c0102b9f <__alltraps>

c0102ce5 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102ce5:	6a 00                	push   $0x0
  pushl $33
c0102ce7:	6a 21                	push   $0x21
  jmp __alltraps
c0102ce9:	e9 b1 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102cee <vector34>:
.globl vector34
vector34:
  pushl $0
c0102cee:	6a 00                	push   $0x0
  pushl $34
c0102cf0:	6a 22                	push   $0x22
  jmp __alltraps
c0102cf2:	e9 a8 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102cf7 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102cf7:	6a 00                	push   $0x0
  pushl $35
c0102cf9:	6a 23                	push   $0x23
  jmp __alltraps
c0102cfb:	e9 9f fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d00 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102d00:	6a 00                	push   $0x0
  pushl $36
c0102d02:	6a 24                	push   $0x24
  jmp __alltraps
c0102d04:	e9 96 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d09 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102d09:	6a 00                	push   $0x0
  pushl $37
c0102d0b:	6a 25                	push   $0x25
  jmp __alltraps
c0102d0d:	e9 8d fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d12 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102d12:	6a 00                	push   $0x0
  pushl $38
c0102d14:	6a 26                	push   $0x26
  jmp __alltraps
c0102d16:	e9 84 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d1b <vector39>:
.globl vector39
vector39:
  pushl $0
c0102d1b:	6a 00                	push   $0x0
  pushl $39
c0102d1d:	6a 27                	push   $0x27
  jmp __alltraps
c0102d1f:	e9 7b fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d24 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102d24:	6a 00                	push   $0x0
  pushl $40
c0102d26:	6a 28                	push   $0x28
  jmp __alltraps
c0102d28:	e9 72 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d2d <vector41>:
.globl vector41
vector41:
  pushl $0
c0102d2d:	6a 00                	push   $0x0
  pushl $41
c0102d2f:	6a 29                	push   $0x29
  jmp __alltraps
c0102d31:	e9 69 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d36 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102d36:	6a 00                	push   $0x0
  pushl $42
c0102d38:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102d3a:	e9 60 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d3f <vector43>:
.globl vector43
vector43:
  pushl $0
c0102d3f:	6a 00                	push   $0x0
  pushl $43
c0102d41:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102d43:	e9 57 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d48 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102d48:	6a 00                	push   $0x0
  pushl $44
c0102d4a:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102d4c:	e9 4e fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d51 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102d51:	6a 00                	push   $0x0
  pushl $45
c0102d53:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102d55:	e9 45 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d5a <vector46>:
.globl vector46
vector46:
  pushl $0
c0102d5a:	6a 00                	push   $0x0
  pushl $46
c0102d5c:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102d5e:	e9 3c fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d63 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102d63:	6a 00                	push   $0x0
  pushl $47
c0102d65:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102d67:	e9 33 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d6c <vector48>:
.globl vector48
vector48:
  pushl $0
c0102d6c:	6a 00                	push   $0x0
  pushl $48
c0102d6e:	6a 30                	push   $0x30
  jmp __alltraps
c0102d70:	e9 2a fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d75 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102d75:	6a 00                	push   $0x0
  pushl $49
c0102d77:	6a 31                	push   $0x31
  jmp __alltraps
c0102d79:	e9 21 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d7e <vector50>:
.globl vector50
vector50:
  pushl $0
c0102d7e:	6a 00                	push   $0x0
  pushl $50
c0102d80:	6a 32                	push   $0x32
  jmp __alltraps
c0102d82:	e9 18 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d87 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102d87:	6a 00                	push   $0x0
  pushl $51
c0102d89:	6a 33                	push   $0x33
  jmp __alltraps
c0102d8b:	e9 0f fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d90 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102d90:	6a 00                	push   $0x0
  pushl $52
c0102d92:	6a 34                	push   $0x34
  jmp __alltraps
c0102d94:	e9 06 fe ff ff       	jmp    c0102b9f <__alltraps>

c0102d99 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102d99:	6a 00                	push   $0x0
  pushl $53
c0102d9b:	6a 35                	push   $0x35
  jmp __alltraps
c0102d9d:	e9 fd fd ff ff       	jmp    c0102b9f <__alltraps>

c0102da2 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102da2:	6a 00                	push   $0x0
  pushl $54
c0102da4:	6a 36                	push   $0x36
  jmp __alltraps
c0102da6:	e9 f4 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102dab <vector55>:
.globl vector55
vector55:
  pushl $0
c0102dab:	6a 00                	push   $0x0
  pushl $55
c0102dad:	6a 37                	push   $0x37
  jmp __alltraps
c0102daf:	e9 eb fd ff ff       	jmp    c0102b9f <__alltraps>

c0102db4 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102db4:	6a 00                	push   $0x0
  pushl $56
c0102db6:	6a 38                	push   $0x38
  jmp __alltraps
c0102db8:	e9 e2 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102dbd <vector57>:
.globl vector57
vector57:
  pushl $0
c0102dbd:	6a 00                	push   $0x0
  pushl $57
c0102dbf:	6a 39                	push   $0x39
  jmp __alltraps
c0102dc1:	e9 d9 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102dc6 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102dc6:	6a 00                	push   $0x0
  pushl $58
c0102dc8:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102dca:	e9 d0 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102dcf <vector59>:
.globl vector59
vector59:
  pushl $0
c0102dcf:	6a 00                	push   $0x0
  pushl $59
c0102dd1:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102dd3:	e9 c7 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102dd8 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102dd8:	6a 00                	push   $0x0
  pushl $60
c0102dda:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102ddc:	e9 be fd ff ff       	jmp    c0102b9f <__alltraps>

c0102de1 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102de1:	6a 00                	push   $0x0
  pushl $61
c0102de3:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102de5:	e9 b5 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102dea <vector62>:
.globl vector62
vector62:
  pushl $0
c0102dea:	6a 00                	push   $0x0
  pushl $62
c0102dec:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102dee:	e9 ac fd ff ff       	jmp    c0102b9f <__alltraps>

c0102df3 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102df3:	6a 00                	push   $0x0
  pushl $63
c0102df5:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102df7:	e9 a3 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102dfc <vector64>:
.globl vector64
vector64:
  pushl $0
c0102dfc:	6a 00                	push   $0x0
  pushl $64
c0102dfe:	6a 40                	push   $0x40
  jmp __alltraps
c0102e00:	e9 9a fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e05 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102e05:	6a 00                	push   $0x0
  pushl $65
c0102e07:	6a 41                	push   $0x41
  jmp __alltraps
c0102e09:	e9 91 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e0e <vector66>:
.globl vector66
vector66:
  pushl $0
c0102e0e:	6a 00                	push   $0x0
  pushl $66
c0102e10:	6a 42                	push   $0x42
  jmp __alltraps
c0102e12:	e9 88 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e17 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102e17:	6a 00                	push   $0x0
  pushl $67
c0102e19:	6a 43                	push   $0x43
  jmp __alltraps
c0102e1b:	e9 7f fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e20 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102e20:	6a 00                	push   $0x0
  pushl $68
c0102e22:	6a 44                	push   $0x44
  jmp __alltraps
c0102e24:	e9 76 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e29 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102e29:	6a 00                	push   $0x0
  pushl $69
c0102e2b:	6a 45                	push   $0x45
  jmp __alltraps
c0102e2d:	e9 6d fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e32 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102e32:	6a 00                	push   $0x0
  pushl $70
c0102e34:	6a 46                	push   $0x46
  jmp __alltraps
c0102e36:	e9 64 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e3b <vector71>:
.globl vector71
vector71:
  pushl $0
c0102e3b:	6a 00                	push   $0x0
  pushl $71
c0102e3d:	6a 47                	push   $0x47
  jmp __alltraps
c0102e3f:	e9 5b fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e44 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102e44:	6a 00                	push   $0x0
  pushl $72
c0102e46:	6a 48                	push   $0x48
  jmp __alltraps
c0102e48:	e9 52 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e4d <vector73>:
.globl vector73
vector73:
  pushl $0
c0102e4d:	6a 00                	push   $0x0
  pushl $73
c0102e4f:	6a 49                	push   $0x49
  jmp __alltraps
c0102e51:	e9 49 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e56 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102e56:	6a 00                	push   $0x0
  pushl $74
c0102e58:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102e5a:	e9 40 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e5f <vector75>:
.globl vector75
vector75:
  pushl $0
c0102e5f:	6a 00                	push   $0x0
  pushl $75
c0102e61:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102e63:	e9 37 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e68 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102e68:	6a 00                	push   $0x0
  pushl $76
c0102e6a:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102e6c:	e9 2e fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e71 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102e71:	6a 00                	push   $0x0
  pushl $77
c0102e73:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102e75:	e9 25 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e7a <vector78>:
.globl vector78
vector78:
  pushl $0
c0102e7a:	6a 00                	push   $0x0
  pushl $78
c0102e7c:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102e7e:	e9 1c fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e83 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102e83:	6a 00                	push   $0x0
  pushl $79
c0102e85:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102e87:	e9 13 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e8c <vector80>:
.globl vector80
vector80:
  pushl $0
c0102e8c:	6a 00                	push   $0x0
  pushl $80
c0102e8e:	6a 50                	push   $0x50
  jmp __alltraps
c0102e90:	e9 0a fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e95 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102e95:	6a 00                	push   $0x0
  pushl $81
c0102e97:	6a 51                	push   $0x51
  jmp __alltraps
c0102e99:	e9 01 fd ff ff       	jmp    c0102b9f <__alltraps>

c0102e9e <vector82>:
.globl vector82
vector82:
  pushl $0
c0102e9e:	6a 00                	push   $0x0
  pushl $82
c0102ea0:	6a 52                	push   $0x52
  jmp __alltraps
c0102ea2:	e9 f8 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102ea7 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102ea7:	6a 00                	push   $0x0
  pushl $83
c0102ea9:	6a 53                	push   $0x53
  jmp __alltraps
c0102eab:	e9 ef fc ff ff       	jmp    c0102b9f <__alltraps>

c0102eb0 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102eb0:	6a 00                	push   $0x0
  pushl $84
c0102eb2:	6a 54                	push   $0x54
  jmp __alltraps
c0102eb4:	e9 e6 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102eb9 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102eb9:	6a 00                	push   $0x0
  pushl $85
c0102ebb:	6a 55                	push   $0x55
  jmp __alltraps
c0102ebd:	e9 dd fc ff ff       	jmp    c0102b9f <__alltraps>

c0102ec2 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102ec2:	6a 00                	push   $0x0
  pushl $86
c0102ec4:	6a 56                	push   $0x56
  jmp __alltraps
c0102ec6:	e9 d4 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102ecb <vector87>:
.globl vector87
vector87:
  pushl $0
c0102ecb:	6a 00                	push   $0x0
  pushl $87
c0102ecd:	6a 57                	push   $0x57
  jmp __alltraps
c0102ecf:	e9 cb fc ff ff       	jmp    c0102b9f <__alltraps>

c0102ed4 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102ed4:	6a 00                	push   $0x0
  pushl $88
c0102ed6:	6a 58                	push   $0x58
  jmp __alltraps
c0102ed8:	e9 c2 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102edd <vector89>:
.globl vector89
vector89:
  pushl $0
c0102edd:	6a 00                	push   $0x0
  pushl $89
c0102edf:	6a 59                	push   $0x59
  jmp __alltraps
c0102ee1:	e9 b9 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102ee6 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102ee6:	6a 00                	push   $0x0
  pushl $90
c0102ee8:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102eea:	e9 b0 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102eef <vector91>:
.globl vector91
vector91:
  pushl $0
c0102eef:	6a 00                	push   $0x0
  pushl $91
c0102ef1:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102ef3:	e9 a7 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102ef8 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102ef8:	6a 00                	push   $0x0
  pushl $92
c0102efa:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102efc:	e9 9e fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f01 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102f01:	6a 00                	push   $0x0
  pushl $93
c0102f03:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102f05:	e9 95 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f0a <vector94>:
.globl vector94
vector94:
  pushl $0
c0102f0a:	6a 00                	push   $0x0
  pushl $94
c0102f0c:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102f0e:	e9 8c fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f13 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102f13:	6a 00                	push   $0x0
  pushl $95
c0102f15:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102f17:	e9 83 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f1c <vector96>:
.globl vector96
vector96:
  pushl $0
c0102f1c:	6a 00                	push   $0x0
  pushl $96
c0102f1e:	6a 60                	push   $0x60
  jmp __alltraps
c0102f20:	e9 7a fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f25 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102f25:	6a 00                	push   $0x0
  pushl $97
c0102f27:	6a 61                	push   $0x61
  jmp __alltraps
c0102f29:	e9 71 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f2e <vector98>:
.globl vector98
vector98:
  pushl $0
c0102f2e:	6a 00                	push   $0x0
  pushl $98
c0102f30:	6a 62                	push   $0x62
  jmp __alltraps
c0102f32:	e9 68 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f37 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102f37:	6a 00                	push   $0x0
  pushl $99
c0102f39:	6a 63                	push   $0x63
  jmp __alltraps
c0102f3b:	e9 5f fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f40 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102f40:	6a 00                	push   $0x0
  pushl $100
c0102f42:	6a 64                	push   $0x64
  jmp __alltraps
c0102f44:	e9 56 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f49 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102f49:	6a 00                	push   $0x0
  pushl $101
c0102f4b:	6a 65                	push   $0x65
  jmp __alltraps
c0102f4d:	e9 4d fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f52 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102f52:	6a 00                	push   $0x0
  pushl $102
c0102f54:	6a 66                	push   $0x66
  jmp __alltraps
c0102f56:	e9 44 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f5b <vector103>:
.globl vector103
vector103:
  pushl $0
c0102f5b:	6a 00                	push   $0x0
  pushl $103
c0102f5d:	6a 67                	push   $0x67
  jmp __alltraps
c0102f5f:	e9 3b fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f64 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102f64:	6a 00                	push   $0x0
  pushl $104
c0102f66:	6a 68                	push   $0x68
  jmp __alltraps
c0102f68:	e9 32 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f6d <vector105>:
.globl vector105
vector105:
  pushl $0
c0102f6d:	6a 00                	push   $0x0
  pushl $105
c0102f6f:	6a 69                	push   $0x69
  jmp __alltraps
c0102f71:	e9 29 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f76 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102f76:	6a 00                	push   $0x0
  pushl $106
c0102f78:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102f7a:	e9 20 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f7f <vector107>:
.globl vector107
vector107:
  pushl $0
c0102f7f:	6a 00                	push   $0x0
  pushl $107
c0102f81:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102f83:	e9 17 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f88 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102f88:	6a 00                	push   $0x0
  pushl $108
c0102f8a:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102f8c:	e9 0e fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f91 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102f91:	6a 00                	push   $0x0
  pushl $109
c0102f93:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102f95:	e9 05 fc ff ff       	jmp    c0102b9f <__alltraps>

c0102f9a <vector110>:
.globl vector110
vector110:
  pushl $0
c0102f9a:	6a 00                	push   $0x0
  pushl $110
c0102f9c:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102f9e:	e9 fc fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fa3 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102fa3:	6a 00                	push   $0x0
  pushl $111
c0102fa5:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102fa7:	e9 f3 fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fac <vector112>:
.globl vector112
vector112:
  pushl $0
c0102fac:	6a 00                	push   $0x0
  pushl $112
c0102fae:	6a 70                	push   $0x70
  jmp __alltraps
c0102fb0:	e9 ea fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fb5 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102fb5:	6a 00                	push   $0x0
  pushl $113
c0102fb7:	6a 71                	push   $0x71
  jmp __alltraps
c0102fb9:	e9 e1 fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fbe <vector114>:
.globl vector114
vector114:
  pushl $0
c0102fbe:	6a 00                	push   $0x0
  pushl $114
c0102fc0:	6a 72                	push   $0x72
  jmp __alltraps
c0102fc2:	e9 d8 fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fc7 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102fc7:	6a 00                	push   $0x0
  pushl $115
c0102fc9:	6a 73                	push   $0x73
  jmp __alltraps
c0102fcb:	e9 cf fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fd0 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102fd0:	6a 00                	push   $0x0
  pushl $116
c0102fd2:	6a 74                	push   $0x74
  jmp __alltraps
c0102fd4:	e9 c6 fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fd9 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102fd9:	6a 00                	push   $0x0
  pushl $117
c0102fdb:	6a 75                	push   $0x75
  jmp __alltraps
c0102fdd:	e9 bd fb ff ff       	jmp    c0102b9f <__alltraps>

c0102fe2 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102fe2:	6a 00                	push   $0x0
  pushl $118
c0102fe4:	6a 76                	push   $0x76
  jmp __alltraps
c0102fe6:	e9 b4 fb ff ff       	jmp    c0102b9f <__alltraps>

c0102feb <vector119>:
.globl vector119
vector119:
  pushl $0
c0102feb:	6a 00                	push   $0x0
  pushl $119
c0102fed:	6a 77                	push   $0x77
  jmp __alltraps
c0102fef:	e9 ab fb ff ff       	jmp    c0102b9f <__alltraps>

c0102ff4 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102ff4:	6a 00                	push   $0x0
  pushl $120
c0102ff6:	6a 78                	push   $0x78
  jmp __alltraps
c0102ff8:	e9 a2 fb ff ff       	jmp    c0102b9f <__alltraps>

c0102ffd <vector121>:
.globl vector121
vector121:
  pushl $0
c0102ffd:	6a 00                	push   $0x0
  pushl $121
c0102fff:	6a 79                	push   $0x79
  jmp __alltraps
c0103001:	e9 99 fb ff ff       	jmp    c0102b9f <__alltraps>

c0103006 <vector122>:
.globl vector122
vector122:
  pushl $0
c0103006:	6a 00                	push   $0x0
  pushl $122
c0103008:	6a 7a                	push   $0x7a
  jmp __alltraps
c010300a:	e9 90 fb ff ff       	jmp    c0102b9f <__alltraps>

c010300f <vector123>:
.globl vector123
vector123:
  pushl $0
c010300f:	6a 00                	push   $0x0
  pushl $123
c0103011:	6a 7b                	push   $0x7b
  jmp __alltraps
c0103013:	e9 87 fb ff ff       	jmp    c0102b9f <__alltraps>

c0103018 <vector124>:
.globl vector124
vector124:
  pushl $0
c0103018:	6a 00                	push   $0x0
  pushl $124
c010301a:	6a 7c                	push   $0x7c
  jmp __alltraps
c010301c:	e9 7e fb ff ff       	jmp    c0102b9f <__alltraps>

c0103021 <vector125>:
.globl vector125
vector125:
  pushl $0
c0103021:	6a 00                	push   $0x0
  pushl $125
c0103023:	6a 7d                	push   $0x7d
  jmp __alltraps
c0103025:	e9 75 fb ff ff       	jmp    c0102b9f <__alltraps>

c010302a <vector126>:
.globl vector126
vector126:
  pushl $0
c010302a:	6a 00                	push   $0x0
  pushl $126
c010302c:	6a 7e                	push   $0x7e
  jmp __alltraps
c010302e:	e9 6c fb ff ff       	jmp    c0102b9f <__alltraps>

c0103033 <vector127>:
.globl vector127
vector127:
  pushl $0
c0103033:	6a 00                	push   $0x0
  pushl $127
c0103035:	6a 7f                	push   $0x7f
  jmp __alltraps
c0103037:	e9 63 fb ff ff       	jmp    c0102b9f <__alltraps>

c010303c <vector128>:
.globl vector128
vector128:
  pushl $0
c010303c:	6a 00                	push   $0x0
  pushl $128
c010303e:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0103043:	e9 57 fb ff ff       	jmp    c0102b9f <__alltraps>

c0103048 <vector129>:
.globl vector129
vector129:
  pushl $0
c0103048:	6a 00                	push   $0x0
  pushl $129
c010304a:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010304f:	e9 4b fb ff ff       	jmp    c0102b9f <__alltraps>

c0103054 <vector130>:
.globl vector130
vector130:
  pushl $0
c0103054:	6a 00                	push   $0x0
  pushl $130
c0103056:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010305b:	e9 3f fb ff ff       	jmp    c0102b9f <__alltraps>

c0103060 <vector131>:
.globl vector131
vector131:
  pushl $0
c0103060:	6a 00                	push   $0x0
  pushl $131
c0103062:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0103067:	e9 33 fb ff ff       	jmp    c0102b9f <__alltraps>

c010306c <vector132>:
.globl vector132
vector132:
  pushl $0
c010306c:	6a 00                	push   $0x0
  pushl $132
c010306e:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0103073:	e9 27 fb ff ff       	jmp    c0102b9f <__alltraps>

c0103078 <vector133>:
.globl vector133
vector133:
  pushl $0
c0103078:	6a 00                	push   $0x0
  pushl $133
c010307a:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010307f:	e9 1b fb ff ff       	jmp    c0102b9f <__alltraps>

c0103084 <vector134>:
.globl vector134
vector134:
  pushl $0
c0103084:	6a 00                	push   $0x0
  pushl $134
c0103086:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010308b:	e9 0f fb ff ff       	jmp    c0102b9f <__alltraps>

c0103090 <vector135>:
.globl vector135
vector135:
  pushl $0
c0103090:	6a 00                	push   $0x0
  pushl $135
c0103092:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0103097:	e9 03 fb ff ff       	jmp    c0102b9f <__alltraps>

c010309c <vector136>:
.globl vector136
vector136:
  pushl $0
c010309c:	6a 00                	push   $0x0
  pushl $136
c010309e:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01030a3:	e9 f7 fa ff ff       	jmp    c0102b9f <__alltraps>

c01030a8 <vector137>:
.globl vector137
vector137:
  pushl $0
c01030a8:	6a 00                	push   $0x0
  pushl $137
c01030aa:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01030af:	e9 eb fa ff ff       	jmp    c0102b9f <__alltraps>

c01030b4 <vector138>:
.globl vector138
vector138:
  pushl $0
c01030b4:	6a 00                	push   $0x0
  pushl $138
c01030b6:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01030bb:	e9 df fa ff ff       	jmp    c0102b9f <__alltraps>

c01030c0 <vector139>:
.globl vector139
vector139:
  pushl $0
c01030c0:	6a 00                	push   $0x0
  pushl $139
c01030c2:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01030c7:	e9 d3 fa ff ff       	jmp    c0102b9f <__alltraps>

c01030cc <vector140>:
.globl vector140
vector140:
  pushl $0
c01030cc:	6a 00                	push   $0x0
  pushl $140
c01030ce:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01030d3:	e9 c7 fa ff ff       	jmp    c0102b9f <__alltraps>

c01030d8 <vector141>:
.globl vector141
vector141:
  pushl $0
c01030d8:	6a 00                	push   $0x0
  pushl $141
c01030da:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01030df:	e9 bb fa ff ff       	jmp    c0102b9f <__alltraps>

c01030e4 <vector142>:
.globl vector142
vector142:
  pushl $0
c01030e4:	6a 00                	push   $0x0
  pushl $142
c01030e6:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01030eb:	e9 af fa ff ff       	jmp    c0102b9f <__alltraps>

c01030f0 <vector143>:
.globl vector143
vector143:
  pushl $0
c01030f0:	6a 00                	push   $0x0
  pushl $143
c01030f2:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01030f7:	e9 a3 fa ff ff       	jmp    c0102b9f <__alltraps>

c01030fc <vector144>:
.globl vector144
vector144:
  pushl $0
c01030fc:	6a 00                	push   $0x0
  pushl $144
c01030fe:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0103103:	e9 97 fa ff ff       	jmp    c0102b9f <__alltraps>

c0103108 <vector145>:
.globl vector145
vector145:
  pushl $0
c0103108:	6a 00                	push   $0x0
  pushl $145
c010310a:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010310f:	e9 8b fa ff ff       	jmp    c0102b9f <__alltraps>

c0103114 <vector146>:
.globl vector146
vector146:
  pushl $0
c0103114:	6a 00                	push   $0x0
  pushl $146
c0103116:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010311b:	e9 7f fa ff ff       	jmp    c0102b9f <__alltraps>

c0103120 <vector147>:
.globl vector147
vector147:
  pushl $0
c0103120:	6a 00                	push   $0x0
  pushl $147
c0103122:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0103127:	e9 73 fa ff ff       	jmp    c0102b9f <__alltraps>

c010312c <vector148>:
.globl vector148
vector148:
  pushl $0
c010312c:	6a 00                	push   $0x0
  pushl $148
c010312e:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0103133:	e9 67 fa ff ff       	jmp    c0102b9f <__alltraps>

c0103138 <vector149>:
.globl vector149
vector149:
  pushl $0
c0103138:	6a 00                	push   $0x0
  pushl $149
c010313a:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010313f:	e9 5b fa ff ff       	jmp    c0102b9f <__alltraps>

c0103144 <vector150>:
.globl vector150
vector150:
  pushl $0
c0103144:	6a 00                	push   $0x0
  pushl $150
c0103146:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010314b:	e9 4f fa ff ff       	jmp    c0102b9f <__alltraps>

c0103150 <vector151>:
.globl vector151
vector151:
  pushl $0
c0103150:	6a 00                	push   $0x0
  pushl $151
c0103152:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0103157:	e9 43 fa ff ff       	jmp    c0102b9f <__alltraps>

c010315c <vector152>:
.globl vector152
vector152:
  pushl $0
c010315c:	6a 00                	push   $0x0
  pushl $152
c010315e:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0103163:	e9 37 fa ff ff       	jmp    c0102b9f <__alltraps>

c0103168 <vector153>:
.globl vector153
vector153:
  pushl $0
c0103168:	6a 00                	push   $0x0
  pushl $153
c010316a:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010316f:	e9 2b fa ff ff       	jmp    c0102b9f <__alltraps>

c0103174 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103174:	6a 00                	push   $0x0
  pushl $154
c0103176:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010317b:	e9 1f fa ff ff       	jmp    c0102b9f <__alltraps>

c0103180 <vector155>:
.globl vector155
vector155:
  pushl $0
c0103180:	6a 00                	push   $0x0
  pushl $155
c0103182:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103187:	e9 13 fa ff ff       	jmp    c0102b9f <__alltraps>

c010318c <vector156>:
.globl vector156
vector156:
  pushl $0
c010318c:	6a 00                	push   $0x0
  pushl $156
c010318e:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103193:	e9 07 fa ff ff       	jmp    c0102b9f <__alltraps>

c0103198 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103198:	6a 00                	push   $0x0
  pushl $157
c010319a:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010319f:	e9 fb f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031a4 <vector158>:
.globl vector158
vector158:
  pushl $0
c01031a4:	6a 00                	push   $0x0
  pushl $158
c01031a6:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01031ab:	e9 ef f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031b0 <vector159>:
.globl vector159
vector159:
  pushl $0
c01031b0:	6a 00                	push   $0x0
  pushl $159
c01031b2:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01031b7:	e9 e3 f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031bc <vector160>:
.globl vector160
vector160:
  pushl $0
c01031bc:	6a 00                	push   $0x0
  pushl $160
c01031be:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01031c3:	e9 d7 f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031c8 <vector161>:
.globl vector161
vector161:
  pushl $0
c01031c8:	6a 00                	push   $0x0
  pushl $161
c01031ca:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01031cf:	e9 cb f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031d4 <vector162>:
.globl vector162
vector162:
  pushl $0
c01031d4:	6a 00                	push   $0x0
  pushl $162
c01031d6:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01031db:	e9 bf f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031e0 <vector163>:
.globl vector163
vector163:
  pushl $0
c01031e0:	6a 00                	push   $0x0
  pushl $163
c01031e2:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01031e7:	e9 b3 f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031ec <vector164>:
.globl vector164
vector164:
  pushl $0
c01031ec:	6a 00                	push   $0x0
  pushl $164
c01031ee:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01031f3:	e9 a7 f9 ff ff       	jmp    c0102b9f <__alltraps>

c01031f8 <vector165>:
.globl vector165
vector165:
  pushl $0
c01031f8:	6a 00                	push   $0x0
  pushl $165
c01031fa:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01031ff:	e9 9b f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103204 <vector166>:
.globl vector166
vector166:
  pushl $0
c0103204:	6a 00                	push   $0x0
  pushl $166
c0103206:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010320b:	e9 8f f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103210 <vector167>:
.globl vector167
vector167:
  pushl $0
c0103210:	6a 00                	push   $0x0
  pushl $167
c0103212:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0103217:	e9 83 f9 ff ff       	jmp    c0102b9f <__alltraps>

c010321c <vector168>:
.globl vector168
vector168:
  pushl $0
c010321c:	6a 00                	push   $0x0
  pushl $168
c010321e:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0103223:	e9 77 f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103228 <vector169>:
.globl vector169
vector169:
  pushl $0
c0103228:	6a 00                	push   $0x0
  pushl $169
c010322a:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010322f:	e9 6b f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103234 <vector170>:
.globl vector170
vector170:
  pushl $0
c0103234:	6a 00                	push   $0x0
  pushl $170
c0103236:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010323b:	e9 5f f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103240 <vector171>:
.globl vector171
vector171:
  pushl $0
c0103240:	6a 00                	push   $0x0
  pushl $171
c0103242:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0103247:	e9 53 f9 ff ff       	jmp    c0102b9f <__alltraps>

c010324c <vector172>:
.globl vector172
vector172:
  pushl $0
c010324c:	6a 00                	push   $0x0
  pushl $172
c010324e:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0103253:	e9 47 f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103258 <vector173>:
.globl vector173
vector173:
  pushl $0
c0103258:	6a 00                	push   $0x0
  pushl $173
c010325a:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010325f:	e9 3b f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103264 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103264:	6a 00                	push   $0x0
  pushl $174
c0103266:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010326b:	e9 2f f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103270 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103270:	6a 00                	push   $0x0
  pushl $175
c0103272:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103277:	e9 23 f9 ff ff       	jmp    c0102b9f <__alltraps>

c010327c <vector176>:
.globl vector176
vector176:
  pushl $0
c010327c:	6a 00                	push   $0x0
  pushl $176
c010327e:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103283:	e9 17 f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103288 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103288:	6a 00                	push   $0x0
  pushl $177
c010328a:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010328f:	e9 0b f9 ff ff       	jmp    c0102b9f <__alltraps>

c0103294 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103294:	6a 00                	push   $0x0
  pushl $178
c0103296:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010329b:	e9 ff f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032a0 <vector179>:
.globl vector179
vector179:
  pushl $0
c01032a0:	6a 00                	push   $0x0
  pushl $179
c01032a2:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01032a7:	e9 f3 f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032ac <vector180>:
.globl vector180
vector180:
  pushl $0
c01032ac:	6a 00                	push   $0x0
  pushl $180
c01032ae:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01032b3:	e9 e7 f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032b8 <vector181>:
.globl vector181
vector181:
  pushl $0
c01032b8:	6a 00                	push   $0x0
  pushl $181
c01032ba:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01032bf:	e9 db f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032c4 <vector182>:
.globl vector182
vector182:
  pushl $0
c01032c4:	6a 00                	push   $0x0
  pushl $182
c01032c6:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01032cb:	e9 cf f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032d0 <vector183>:
.globl vector183
vector183:
  pushl $0
c01032d0:	6a 00                	push   $0x0
  pushl $183
c01032d2:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01032d7:	e9 c3 f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032dc <vector184>:
.globl vector184
vector184:
  pushl $0
c01032dc:	6a 00                	push   $0x0
  pushl $184
c01032de:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01032e3:	e9 b7 f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032e8 <vector185>:
.globl vector185
vector185:
  pushl $0
c01032e8:	6a 00                	push   $0x0
  pushl $185
c01032ea:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01032ef:	e9 ab f8 ff ff       	jmp    c0102b9f <__alltraps>

c01032f4 <vector186>:
.globl vector186
vector186:
  pushl $0
c01032f4:	6a 00                	push   $0x0
  pushl $186
c01032f6:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01032fb:	e9 9f f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103300 <vector187>:
.globl vector187
vector187:
  pushl $0
c0103300:	6a 00                	push   $0x0
  pushl $187
c0103302:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0103307:	e9 93 f8 ff ff       	jmp    c0102b9f <__alltraps>

c010330c <vector188>:
.globl vector188
vector188:
  pushl $0
c010330c:	6a 00                	push   $0x0
  pushl $188
c010330e:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0103313:	e9 87 f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103318 <vector189>:
.globl vector189
vector189:
  pushl $0
c0103318:	6a 00                	push   $0x0
  pushl $189
c010331a:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010331f:	e9 7b f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103324 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103324:	6a 00                	push   $0x0
  pushl $190
c0103326:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010332b:	e9 6f f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103330 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103330:	6a 00                	push   $0x0
  pushl $191
c0103332:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0103337:	e9 63 f8 ff ff       	jmp    c0102b9f <__alltraps>

c010333c <vector192>:
.globl vector192
vector192:
  pushl $0
c010333c:	6a 00                	push   $0x0
  pushl $192
c010333e:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103343:	e9 57 f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103348 <vector193>:
.globl vector193
vector193:
  pushl $0
c0103348:	6a 00                	push   $0x0
  pushl $193
c010334a:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010334f:	e9 4b f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103354 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103354:	6a 00                	push   $0x0
  pushl $194
c0103356:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010335b:	e9 3f f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103360 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103360:	6a 00                	push   $0x0
  pushl $195
c0103362:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103367:	e9 33 f8 ff ff       	jmp    c0102b9f <__alltraps>

c010336c <vector196>:
.globl vector196
vector196:
  pushl $0
c010336c:	6a 00                	push   $0x0
  pushl $196
c010336e:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103373:	e9 27 f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103378 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103378:	6a 00                	push   $0x0
  pushl $197
c010337a:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010337f:	e9 1b f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103384 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103384:	6a 00                	push   $0x0
  pushl $198
c0103386:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010338b:	e9 0f f8 ff ff       	jmp    c0102b9f <__alltraps>

c0103390 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103390:	6a 00                	push   $0x0
  pushl $199
c0103392:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103397:	e9 03 f8 ff ff       	jmp    c0102b9f <__alltraps>

c010339c <vector200>:
.globl vector200
vector200:
  pushl $0
c010339c:	6a 00                	push   $0x0
  pushl $200
c010339e:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01033a3:	e9 f7 f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033a8 <vector201>:
.globl vector201
vector201:
  pushl $0
c01033a8:	6a 00                	push   $0x0
  pushl $201
c01033aa:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01033af:	e9 eb f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033b4 <vector202>:
.globl vector202
vector202:
  pushl $0
c01033b4:	6a 00                	push   $0x0
  pushl $202
c01033b6:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01033bb:	e9 df f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033c0 <vector203>:
.globl vector203
vector203:
  pushl $0
c01033c0:	6a 00                	push   $0x0
  pushl $203
c01033c2:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01033c7:	e9 d3 f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033cc <vector204>:
.globl vector204
vector204:
  pushl $0
c01033cc:	6a 00                	push   $0x0
  pushl $204
c01033ce:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01033d3:	e9 c7 f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033d8 <vector205>:
.globl vector205
vector205:
  pushl $0
c01033d8:	6a 00                	push   $0x0
  pushl $205
c01033da:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01033df:	e9 bb f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033e4 <vector206>:
.globl vector206
vector206:
  pushl $0
c01033e4:	6a 00                	push   $0x0
  pushl $206
c01033e6:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01033eb:	e9 af f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033f0 <vector207>:
.globl vector207
vector207:
  pushl $0
c01033f0:	6a 00                	push   $0x0
  pushl $207
c01033f2:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01033f7:	e9 a3 f7 ff ff       	jmp    c0102b9f <__alltraps>

c01033fc <vector208>:
.globl vector208
vector208:
  pushl $0
c01033fc:	6a 00                	push   $0x0
  pushl $208
c01033fe:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103403:	e9 97 f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103408 <vector209>:
.globl vector209
vector209:
  pushl $0
c0103408:	6a 00                	push   $0x0
  pushl $209
c010340a:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010340f:	e9 8b f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103414 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103414:	6a 00                	push   $0x0
  pushl $210
c0103416:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010341b:	e9 7f f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103420 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103420:	6a 00                	push   $0x0
  pushl $211
c0103422:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103427:	e9 73 f7 ff ff       	jmp    c0102b9f <__alltraps>

c010342c <vector212>:
.globl vector212
vector212:
  pushl $0
c010342c:	6a 00                	push   $0x0
  pushl $212
c010342e:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103433:	e9 67 f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103438 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103438:	6a 00                	push   $0x0
  pushl $213
c010343a:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010343f:	e9 5b f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103444 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103444:	6a 00                	push   $0x0
  pushl $214
c0103446:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010344b:	e9 4f f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103450 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103450:	6a 00                	push   $0x0
  pushl $215
c0103452:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103457:	e9 43 f7 ff ff       	jmp    c0102b9f <__alltraps>

c010345c <vector216>:
.globl vector216
vector216:
  pushl $0
c010345c:	6a 00                	push   $0x0
  pushl $216
c010345e:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103463:	e9 37 f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103468 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103468:	6a 00                	push   $0x0
  pushl $217
c010346a:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010346f:	e9 2b f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103474 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103474:	6a 00                	push   $0x0
  pushl $218
c0103476:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010347b:	e9 1f f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103480 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103480:	6a 00                	push   $0x0
  pushl $219
c0103482:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103487:	e9 13 f7 ff ff       	jmp    c0102b9f <__alltraps>

c010348c <vector220>:
.globl vector220
vector220:
  pushl $0
c010348c:	6a 00                	push   $0x0
  pushl $220
c010348e:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103493:	e9 07 f7 ff ff       	jmp    c0102b9f <__alltraps>

c0103498 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103498:	6a 00                	push   $0x0
  pushl $221
c010349a:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010349f:	e9 fb f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034a4 <vector222>:
.globl vector222
vector222:
  pushl $0
c01034a4:	6a 00                	push   $0x0
  pushl $222
c01034a6:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01034ab:	e9 ef f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034b0 <vector223>:
.globl vector223
vector223:
  pushl $0
c01034b0:	6a 00                	push   $0x0
  pushl $223
c01034b2:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01034b7:	e9 e3 f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034bc <vector224>:
.globl vector224
vector224:
  pushl $0
c01034bc:	6a 00                	push   $0x0
  pushl $224
c01034be:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01034c3:	e9 d7 f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034c8 <vector225>:
.globl vector225
vector225:
  pushl $0
c01034c8:	6a 00                	push   $0x0
  pushl $225
c01034ca:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01034cf:	e9 cb f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034d4 <vector226>:
.globl vector226
vector226:
  pushl $0
c01034d4:	6a 00                	push   $0x0
  pushl $226
c01034d6:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01034db:	e9 bf f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034e0 <vector227>:
.globl vector227
vector227:
  pushl $0
c01034e0:	6a 00                	push   $0x0
  pushl $227
c01034e2:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01034e7:	e9 b3 f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034ec <vector228>:
.globl vector228
vector228:
  pushl $0
c01034ec:	6a 00                	push   $0x0
  pushl $228
c01034ee:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01034f3:	e9 a7 f6 ff ff       	jmp    c0102b9f <__alltraps>

c01034f8 <vector229>:
.globl vector229
vector229:
  pushl $0
c01034f8:	6a 00                	push   $0x0
  pushl $229
c01034fa:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01034ff:	e9 9b f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103504 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103504:	6a 00                	push   $0x0
  pushl $230
c0103506:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010350b:	e9 8f f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103510 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103510:	6a 00                	push   $0x0
  pushl $231
c0103512:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103517:	e9 83 f6 ff ff       	jmp    c0102b9f <__alltraps>

c010351c <vector232>:
.globl vector232
vector232:
  pushl $0
c010351c:	6a 00                	push   $0x0
  pushl $232
c010351e:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103523:	e9 77 f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103528 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103528:	6a 00                	push   $0x0
  pushl $233
c010352a:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010352f:	e9 6b f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103534 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103534:	6a 00                	push   $0x0
  pushl $234
c0103536:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010353b:	e9 5f f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103540 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103540:	6a 00                	push   $0x0
  pushl $235
c0103542:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103547:	e9 53 f6 ff ff       	jmp    c0102b9f <__alltraps>

c010354c <vector236>:
.globl vector236
vector236:
  pushl $0
c010354c:	6a 00                	push   $0x0
  pushl $236
c010354e:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103553:	e9 47 f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103558 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103558:	6a 00                	push   $0x0
  pushl $237
c010355a:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010355f:	e9 3b f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103564 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103564:	6a 00                	push   $0x0
  pushl $238
c0103566:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010356b:	e9 2f f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103570 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103570:	6a 00                	push   $0x0
  pushl $239
c0103572:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103577:	e9 23 f6 ff ff       	jmp    c0102b9f <__alltraps>

c010357c <vector240>:
.globl vector240
vector240:
  pushl $0
c010357c:	6a 00                	push   $0x0
  pushl $240
c010357e:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103583:	e9 17 f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103588 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103588:	6a 00                	push   $0x0
  pushl $241
c010358a:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010358f:	e9 0b f6 ff ff       	jmp    c0102b9f <__alltraps>

c0103594 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103594:	6a 00                	push   $0x0
  pushl $242
c0103596:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010359b:	e9 ff f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035a0 <vector243>:
.globl vector243
vector243:
  pushl $0
c01035a0:	6a 00                	push   $0x0
  pushl $243
c01035a2:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01035a7:	e9 f3 f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035ac <vector244>:
.globl vector244
vector244:
  pushl $0
c01035ac:	6a 00                	push   $0x0
  pushl $244
c01035ae:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01035b3:	e9 e7 f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035b8 <vector245>:
.globl vector245
vector245:
  pushl $0
c01035b8:	6a 00                	push   $0x0
  pushl $245
c01035ba:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01035bf:	e9 db f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035c4 <vector246>:
.globl vector246
vector246:
  pushl $0
c01035c4:	6a 00                	push   $0x0
  pushl $246
c01035c6:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01035cb:	e9 cf f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035d0 <vector247>:
.globl vector247
vector247:
  pushl $0
c01035d0:	6a 00                	push   $0x0
  pushl $247
c01035d2:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01035d7:	e9 c3 f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035dc <vector248>:
.globl vector248
vector248:
  pushl $0
c01035dc:	6a 00                	push   $0x0
  pushl $248
c01035de:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01035e3:	e9 b7 f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035e8 <vector249>:
.globl vector249
vector249:
  pushl $0
c01035e8:	6a 00                	push   $0x0
  pushl $249
c01035ea:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01035ef:	e9 ab f5 ff ff       	jmp    c0102b9f <__alltraps>

c01035f4 <vector250>:
.globl vector250
vector250:
  pushl $0
c01035f4:	6a 00                	push   $0x0
  pushl $250
c01035f6:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01035fb:	e9 9f f5 ff ff       	jmp    c0102b9f <__alltraps>

c0103600 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103600:	6a 00                	push   $0x0
  pushl $251
c0103602:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103607:	e9 93 f5 ff ff       	jmp    c0102b9f <__alltraps>

c010360c <vector252>:
.globl vector252
vector252:
  pushl $0
c010360c:	6a 00                	push   $0x0
  pushl $252
c010360e:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103613:	e9 87 f5 ff ff       	jmp    c0102b9f <__alltraps>

c0103618 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103618:	6a 00                	push   $0x0
  pushl $253
c010361a:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010361f:	e9 7b f5 ff ff       	jmp    c0102b9f <__alltraps>

c0103624 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103624:	6a 00                	push   $0x0
  pushl $254
c0103626:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010362b:	e9 6f f5 ff ff       	jmp    c0102b9f <__alltraps>

c0103630 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103630:	6a 00                	push   $0x0
  pushl $255
c0103632:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103637:	e9 63 f5 ff ff       	jmp    c0102b9f <__alltraps>

c010363c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010363c:	55                   	push   %ebp
c010363d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010363f:	8b 55 08             	mov    0x8(%ebp),%edx
c0103642:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0103647:	29 c2                	sub    %eax,%edx
c0103649:	89 d0                	mov    %edx,%eax
c010364b:	c1 f8 05             	sar    $0x5,%eax
}
c010364e:	5d                   	pop    %ebp
c010364f:	c3                   	ret    

c0103650 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103650:	55                   	push   %ebp
c0103651:	89 e5                	mov    %esp,%ebp
c0103653:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103656:	8b 45 08             	mov    0x8(%ebp),%eax
c0103659:	89 04 24             	mov    %eax,(%esp)
c010365c:	e8 db ff ff ff       	call   c010363c <page2ppn>
c0103661:	c1 e0 0c             	shl    $0xc,%eax
}
c0103664:	c9                   	leave  
c0103665:	c3                   	ret    

c0103666 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103666:	55                   	push   %ebp
c0103667:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103669:	8b 45 08             	mov    0x8(%ebp),%eax
c010366c:	8b 00                	mov    (%eax),%eax
}
c010366e:	5d                   	pop    %ebp
c010366f:	c3                   	ret    

c0103670 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103670:	55                   	push   %ebp
c0103671:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103673:	8b 45 08             	mov    0x8(%ebp),%eax
c0103676:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103679:	89 10                	mov    %edx,(%eax)
}
c010367b:	5d                   	pop    %ebp
c010367c:	c3                   	ret    

c010367d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010367d:	55                   	push   %ebp
c010367e:	89 e5                	mov    %esp,%ebp
c0103680:	83 ec 10             	sub    $0x10,%esp
c0103683:	c7 45 fc d0 10 1a c0 	movl   $0xc01a10d0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010368a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010368d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103690:	89 50 04             	mov    %edx,0x4(%eax)
c0103693:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103696:	8b 50 04             	mov    0x4(%eax),%edx
c0103699:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010369c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010369e:	c7 05 d8 10 1a c0 00 	movl   $0x0,0xc01a10d8
c01036a5:	00 00 00 
}
c01036a8:	c9                   	leave  
c01036a9:	c3                   	ret    

c01036aa <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01036aa:	55                   	push   %ebp
c01036ab:	89 e5                	mov    %esp,%ebp
c01036ad:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01036b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01036b4:	75 24                	jne    c01036da <default_init_memmap+0x30>
c01036b6:	c7 44 24 0c 70 c9 10 	movl   $0xc010c970,0xc(%esp)
c01036bd:	c0 
c01036be:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01036c5:	c0 
c01036c6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01036cd:	00 
c01036ce:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01036d5:	e8 11 d7 ff ff       	call   c0100deb <__panic>
    struct Page *p = base;
c01036da:	8b 45 08             	mov    0x8(%ebp),%eax
c01036dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01036e0:	eb 7d                	jmp    c010375f <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01036e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036e5:	83 c0 04             	add    $0x4,%eax
c01036e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01036ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036f8:	0f a3 10             	bt     %edx,(%eax)
c01036fb:	19 c0                	sbb    %eax,%eax
c01036fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103700:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103704:	0f 95 c0             	setne  %al
c0103707:	0f b6 c0             	movzbl %al,%eax
c010370a:	85 c0                	test   %eax,%eax
c010370c:	75 24                	jne    c0103732 <default_init_memmap+0x88>
c010370e:	c7 44 24 0c a1 c9 10 	movl   $0xc010c9a1,0xc(%esp)
c0103715:	c0 
c0103716:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010371d:	c0 
c010371e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103725:	00 
c0103726:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010372d:	e8 b9 d6 ff ff       	call   c0100deb <__panic>
        p->flags = p->property = 0;
c0103732:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103735:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010373c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010373f:	8b 50 08             	mov    0x8(%eax),%edx
c0103742:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103745:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103748:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010374f:	00 
c0103750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103753:	89 04 24             	mov    %eax,(%esp)
c0103756:	e8 15 ff ff ff       	call   c0103670 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010375b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010375f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103762:	c1 e0 05             	shl    $0x5,%eax
c0103765:	89 c2                	mov    %eax,%edx
c0103767:	8b 45 08             	mov    0x8(%ebp),%eax
c010376a:	01 d0                	add    %edx,%eax
c010376c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010376f:	0f 85 6d ff ff ff    	jne    c01036e2 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103775:	8b 45 08             	mov    0x8(%ebp),%eax
c0103778:	8b 55 0c             	mov    0xc(%ebp),%edx
c010377b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010377e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103781:	83 c0 04             	add    $0x4,%eax
c0103784:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c010378b:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010378e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103791:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103794:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0103797:	8b 15 d8 10 1a c0    	mov    0xc01a10d8,%edx
c010379d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037a0:	01 d0                	add    %edx,%eax
c01037a2:	a3 d8 10 1a c0       	mov    %eax,0xc01a10d8
    list_add_before(&free_list, &(base->page_link));
c01037a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01037aa:	83 c0 0c             	add    $0xc,%eax
c01037ad:	c7 45 dc d0 10 1a c0 	movl   $0xc01a10d0,-0x24(%ebp)
c01037b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01037b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037ba:	8b 00                	mov    (%eax),%eax
c01037bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01037bf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01037c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01037c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01037cb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01037ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01037d1:	89 10                	mov    %edx,(%eax)
c01037d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01037d6:	8b 10                	mov    (%eax),%edx
c01037d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01037db:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01037de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01037e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01037e4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01037e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01037ea:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01037ed:	89 10                	mov    %edx,(%eax)
}
c01037ef:	c9                   	leave  
c01037f0:	c3                   	ret    

c01037f1 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01037f1:	55                   	push   %ebp
c01037f2:	89 e5                	mov    %esp,%ebp
c01037f4:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01037f7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01037fb:	75 24                	jne    c0103821 <default_alloc_pages+0x30>
c01037fd:	c7 44 24 0c 70 c9 10 	movl   $0xc010c970,0xc(%esp)
c0103804:	c0 
c0103805:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010380c:	c0 
c010380d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0103814:	00 
c0103815:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010381c:	e8 ca d5 ff ff       	call   c0100deb <__panic>
    if (n > nr_free) {
c0103821:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c0103826:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103829:	73 0a                	jae    c0103835 <default_alloc_pages+0x44>
        return NULL;
c010382b:	b8 00 00 00 00       	mov    $0x0,%eax
c0103830:	e9 36 01 00 00       	jmp    c010396b <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c0103835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010383c:	c7 45 f0 d0 10 1a c0 	movl   $0xc01a10d0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103843:	eb 1c                	jmp    c0103861 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103845:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103848:	83 e8 0c             	sub    $0xc,%eax
c010384b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010384e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103851:	8b 40 08             	mov    0x8(%eax),%eax
c0103854:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103857:	72 08                	jb     c0103861 <default_alloc_pages+0x70>
            page = p;
c0103859:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010385c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010385f:	eb 18                	jmp    c0103879 <default_alloc_pages+0x88>
c0103861:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103864:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103867:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010386a:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010386d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103870:	81 7d f0 d0 10 1a c0 	cmpl   $0xc01a10d0,-0x10(%ebp)
c0103877:	75 cc                	jne    c0103845 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0103879:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010387d:	0f 84 e5 00 00 00    	je     c0103968 <default_alloc_pages+0x177>
        if (page->property > n) {
c0103883:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103886:	8b 40 08             	mov    0x8(%eax),%eax
c0103889:	3b 45 08             	cmp    0x8(%ebp),%eax
c010388c:	0f 86 85 00 00 00    	jbe    c0103917 <default_alloc_pages+0x126>
            struct Page *p = page + n;
c0103892:	8b 45 08             	mov    0x8(%ebp),%eax
c0103895:	c1 e0 05             	shl    $0x5,%eax
c0103898:	89 c2                	mov    %eax,%edx
c010389a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389d:	01 d0                	add    %edx,%eax
c010389f:	89 45 e8             	mov    %eax,-0x18(%ebp)
			SetPageProperty(p);
c01038a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038a5:	83 c0 04             	add    $0x4,%eax
c01038a8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01038af:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01038b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01038b8:	0f ab 10             	bts    %edx,(%eax)
            p->property = page->property - n;
c01038bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038be:	8b 40 08             	mov    0x8(%eax),%eax
c01038c1:	2b 45 08             	sub    0x8(%ebp),%eax
c01038c4:	89 c2                	mov    %eax,%edx
c01038c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038c9:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c01038cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038cf:	83 c0 0c             	add    $0xc,%eax
c01038d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038d5:	83 c2 0c             	add    $0xc,%edx
c01038d8:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01038db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01038de:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038e1:	8b 40 04             	mov    0x4(%eax),%eax
c01038e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038e7:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01038ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01038f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01038f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038f9:	89 10                	mov    %edx,(%eax)
c01038fb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038fe:	8b 10                	mov    (%eax),%edx
c0103900:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103903:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103906:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103909:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010390c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010390f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103912:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103915:	89 10                	mov    %edx,(%eax)
    }
	list_del(&(page->page_link));
c0103917:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010391a:	83 c0 0c             	add    $0xc,%eax
c010391d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103920:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103923:	8b 40 04             	mov    0x4(%eax),%eax
c0103926:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103929:	8b 12                	mov    (%edx),%edx
c010392b:	89 55 c0             	mov    %edx,-0x40(%ebp)
c010392e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103931:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103934:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103937:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010393a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010393d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103940:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0103942:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c0103947:	2b 45 08             	sub    0x8(%ebp),%eax
c010394a:	a3 d8 10 1a c0       	mov    %eax,0xc01a10d8
        ClearPageProperty(page);
c010394f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103952:	83 c0 04             	add    $0x4,%eax
c0103955:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010395c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010395f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103962:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103965:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0103968:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010396b:	c9                   	leave  
c010396c:	c3                   	ret    

c010396d <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010396d:	55                   	push   %ebp
c010396e:	89 e5                	mov    %esp,%ebp
c0103970:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0103976:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010397a:	75 24                	jne    c01039a0 <default_free_pages+0x33>
c010397c:	c7 44 24 0c 70 c9 10 	movl   $0xc010c970,0xc(%esp)
c0103983:	c0 
c0103984:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010398b:	c0 
c010398c:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c0103993:	00 
c0103994:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010399b:	e8 4b d4 ff ff       	call   c0100deb <__panic>
    struct Page *p = base;
c01039a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01039a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01039a6:	e9 9d 00 00 00       	jmp    c0103a48 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01039ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039ae:	83 c0 04             	add    $0x4,%eax
c01039b1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01039b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039be:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01039c1:	0f a3 10             	bt     %edx,(%eax)
c01039c4:	19 c0                	sbb    %eax,%eax
c01039c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01039c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01039cd:	0f 95 c0             	setne  %al
c01039d0:	0f b6 c0             	movzbl %al,%eax
c01039d3:	85 c0                	test   %eax,%eax
c01039d5:	75 2c                	jne    c0103a03 <default_free_pages+0x96>
c01039d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039da:	83 c0 04             	add    $0x4,%eax
c01039dd:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01039e4:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01039ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01039ed:	0f a3 10             	bt     %edx,(%eax)
c01039f0:	19 c0                	sbb    %eax,%eax
c01039f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01039f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01039f9:	0f 95 c0             	setne  %al
c01039fc:	0f b6 c0             	movzbl %al,%eax
c01039ff:	85 c0                	test   %eax,%eax
c0103a01:	74 24                	je     c0103a27 <default_free_pages+0xba>
c0103a03:	c7 44 24 0c b4 c9 10 	movl   $0xc010c9b4,0xc(%esp)
c0103a0a:	c0 
c0103a0b:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103a12:	c0 
c0103a13:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0103a1a:	00 
c0103a1b:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103a22:	e8 c4 d3 ff ff       	call   c0100deb <__panic>
        p->flags = 0;
c0103a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a2a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103a31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103a38:	00 
c0103a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a3c:	89 04 24             	mov    %eax,(%esp)
c0103a3f:	e8 2c fc ff ff       	call   c0103670 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103a44:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103a48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a4b:	c1 e0 05             	shl    $0x5,%eax
c0103a4e:	89 c2                	mov    %eax,%edx
c0103a50:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a53:	01 d0                	add    %edx,%eax
c0103a55:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a58:	0f 85 4d ff ff ff    	jne    c01039ab <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103a5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a61:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103a64:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103a67:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a6a:	83 c0 04             	add    $0x4,%eax
c0103a6d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103a74:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a77:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103a7a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103a7d:	0f ab 10             	bts    %edx,(%eax)
c0103a80:	c7 45 cc d0 10 1a c0 	movl   $0xc01a10d0,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103a87:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a8a:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0103a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103a90:	e9 fa 00 00 00       	jmp    c0103b8f <default_free_pages+0x222>
        p = le2page(le, page_link);
c0103a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a98:	83 e8 0c             	sub    $0xc,%eax
c0103a9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103aa1:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103aa4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103aa7:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103aaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0103aad:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab0:	8b 40 08             	mov    0x8(%eax),%eax
c0103ab3:	c1 e0 05             	shl    $0x5,%eax
c0103ab6:	89 c2                	mov    %eax,%edx
c0103ab8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103abb:	01 d0                	add    %edx,%eax
c0103abd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103ac0:	75 5a                	jne    c0103b1c <default_free_pages+0x1af>
            base->property += p->property;
c0103ac2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac5:	8b 50 08             	mov    0x8(%eax),%edx
c0103ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103acb:	8b 40 08             	mov    0x8(%eax),%eax
c0103ace:	01 c2                	add    %eax,%edx
c0103ad0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ad3:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad9:	83 c0 04             	add    $0x4,%eax
c0103adc:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103ae3:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103ae6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103ae9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103aec:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0103aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103af2:	83 c0 0c             	add    $0xc,%eax
c0103af5:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103af8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103afb:	8b 40 04             	mov    0x4(%eax),%eax
c0103afe:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103b01:	8b 12                	mov    (%edx),%edx
c0103b03:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0103b06:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103b09:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103b0c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103b0f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b12:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103b15:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103b18:	89 10                	mov    %edx,(%eax)
c0103b1a:	eb 73                	jmp    c0103b8f <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c0103b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b1f:	8b 40 08             	mov    0x8(%eax),%eax
c0103b22:	c1 e0 05             	shl    $0x5,%eax
c0103b25:	89 c2                	mov    %eax,%edx
c0103b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b2a:	01 d0                	add    %edx,%eax
c0103b2c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103b2f:	75 5e                	jne    c0103b8f <default_free_pages+0x222>
            p->property += base->property;
c0103b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b34:	8b 50 08             	mov    0x8(%eax),%edx
c0103b37:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b3a:	8b 40 08             	mov    0x8(%eax),%eax
c0103b3d:	01 c2                	add    %eax,%edx
c0103b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b42:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103b45:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b48:	83 c0 04             	add    $0x4,%eax
c0103b4b:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0103b52:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103b55:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103b58:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103b5b:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0103b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b61:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b67:	83 c0 0c             	add    $0xc,%eax
c0103b6a:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103b6d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103b70:	8b 40 04             	mov    0x4(%eax),%eax
c0103b73:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103b76:	8b 12                	mov    (%edx),%edx
c0103b78:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0103b7b:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103b7e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103b81:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103b84:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b87:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103b8a:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103b8d:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0103b8f:	81 7d f0 d0 10 1a c0 	cmpl   $0xc01a10d0,-0x10(%ebp)
c0103b96:	0f 85 f9 fe ff ff    	jne    c0103a95 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0103b9c:	8b 15 d8 10 1a c0    	mov    0xc01a10d8,%edx
c0103ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ba5:	01 d0                	add    %edx,%eax
c0103ba7:	a3 d8 10 1a c0       	mov    %eax,0xc01a10d8
c0103bac:	c7 45 9c d0 10 1a c0 	movl   $0xc01a10d0,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103bb3:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103bb6:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0103bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103bbc:	eb 68                	jmp    c0103c26 <default_free_pages+0x2b9>
        p = le2page(le, page_link);
c0103bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bc1:	83 e8 0c             	sub    $0xc,%eax
c0103bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0103bc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bca:	8b 40 08             	mov    0x8(%eax),%eax
c0103bcd:	c1 e0 05             	shl    $0x5,%eax
c0103bd0:	89 c2                	mov    %eax,%edx
c0103bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd5:	01 d0                	add    %edx,%eax
c0103bd7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103bda:	77 3b                	ja     c0103c17 <default_free_pages+0x2aa>
            assert(base + base->property != p);
c0103bdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bdf:	8b 40 08             	mov    0x8(%eax),%eax
c0103be2:	c1 e0 05             	shl    $0x5,%eax
c0103be5:	89 c2                	mov    %eax,%edx
c0103be7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bea:	01 d0                	add    %edx,%eax
c0103bec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103bef:	75 24                	jne    c0103c15 <default_free_pages+0x2a8>
c0103bf1:	c7 44 24 0c d9 c9 10 	movl   $0xc010c9d9,0xc(%esp)
c0103bf8:	c0 
c0103bf9:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103c00:	c0 
c0103c01:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0103c08:	00 
c0103c09:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103c10:	e8 d6 d1 ff ff       	call   c0100deb <__panic>
            break;
c0103c15:	eb 18                	jmp    c0103c2f <default_free_pages+0x2c2>
c0103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c1a:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103c1d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103c20:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0103c23:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0103c26:	81 7d f0 d0 10 1a c0 	cmpl   $0xc01a10d0,-0x10(%ebp)
c0103c2d:	75 8f                	jne    c0103bbe <default_free_pages+0x251>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0103c2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c32:	8d 50 0c             	lea    0xc(%eax),%edx
c0103c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c38:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103c3b:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103c3e:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103c41:	8b 00                	mov    (%eax),%eax
c0103c43:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103c46:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103c49:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103c4c:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103c4f:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103c52:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103c55:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103c58:	89 10                	mov    %edx,(%eax)
c0103c5a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103c5d:	8b 10                	mov    (%eax),%edx
c0103c5f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103c62:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103c65:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103c68:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103c6b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103c6e:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103c71:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103c74:	89 10                	mov    %edx,(%eax)
}
c0103c76:	c9                   	leave  
c0103c77:	c3                   	ret    

c0103c78 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103c78:	55                   	push   %ebp
c0103c79:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103c7b:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
}
c0103c80:	5d                   	pop    %ebp
c0103c81:	c3                   	ret    

c0103c82 <basic_check>:

static void
basic_check(void) {
c0103c82:	55                   	push   %ebp
c0103c83:	89 e5                	mov    %esp,%ebp
c0103c85:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103c88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103c9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ca2:	e8 dc 15 00 00       	call   c0105283 <alloc_pages>
c0103ca7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103caa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103cae:	75 24                	jne    c0103cd4 <basic_check+0x52>
c0103cb0:	c7 44 24 0c f4 c9 10 	movl   $0xc010c9f4,0xc(%esp)
c0103cb7:	c0 
c0103cb8:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103cbf:	c0 
c0103cc0:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0103cc7:	00 
c0103cc8:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103ccf:	e8 17 d1 ff ff       	call   c0100deb <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103cd4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cdb:	e8 a3 15 00 00       	call   c0105283 <alloc_pages>
c0103ce0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ce3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ce7:	75 24                	jne    c0103d0d <basic_check+0x8b>
c0103ce9:	c7 44 24 0c 10 ca 10 	movl   $0xc010ca10,0xc(%esp)
c0103cf0:	c0 
c0103cf1:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103cf8:	c0 
c0103cf9:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103d00:	00 
c0103d01:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103d08:	e8 de d0 ff ff       	call   c0100deb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103d0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d14:	e8 6a 15 00 00       	call   c0105283 <alloc_pages>
c0103d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d20:	75 24                	jne    c0103d46 <basic_check+0xc4>
c0103d22:	c7 44 24 0c 2c ca 10 	movl   $0xc010ca2c,0xc(%esp)
c0103d29:	c0 
c0103d2a:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103d31:	c0 
c0103d32:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0103d39:	00 
c0103d3a:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103d41:	e8 a5 d0 ff ff       	call   c0100deb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103d46:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d49:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103d4c:	74 10                	je     c0103d5e <basic_check+0xdc>
c0103d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d51:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d54:	74 08                	je     c0103d5e <basic_check+0xdc>
c0103d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d59:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d5c:	75 24                	jne    c0103d82 <basic_check+0x100>
c0103d5e:	c7 44 24 0c 48 ca 10 	movl   $0xc010ca48,0xc(%esp)
c0103d65:	c0 
c0103d66:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103d6d:	c0 
c0103d6e:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103d75:	00 
c0103d76:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103d7d:	e8 69 d0 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d85:	89 04 24             	mov    %eax,(%esp)
c0103d88:	e8 d9 f8 ff ff       	call   c0103666 <page_ref>
c0103d8d:	85 c0                	test   %eax,%eax
c0103d8f:	75 1e                	jne    c0103daf <basic_check+0x12d>
c0103d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d94:	89 04 24             	mov    %eax,(%esp)
c0103d97:	e8 ca f8 ff ff       	call   c0103666 <page_ref>
c0103d9c:	85 c0                	test   %eax,%eax
c0103d9e:	75 0f                	jne    c0103daf <basic_check+0x12d>
c0103da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103da3:	89 04 24             	mov    %eax,(%esp)
c0103da6:	e8 bb f8 ff ff       	call   c0103666 <page_ref>
c0103dab:	85 c0                	test   %eax,%eax
c0103dad:	74 24                	je     c0103dd3 <basic_check+0x151>
c0103daf:	c7 44 24 0c 6c ca 10 	movl   $0xc010ca6c,0xc(%esp)
c0103db6:	c0 
c0103db7:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103dbe:	c0 
c0103dbf:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103dc6:	00 
c0103dc7:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103dce:	e8 18 d0 ff ff       	call   c0100deb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103dd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dd6:	89 04 24             	mov    %eax,(%esp)
c0103dd9:	e8 72 f8 ff ff       	call   c0103650 <page2pa>
c0103dde:	8b 15 a0 ef 19 c0    	mov    0xc019efa0,%edx
c0103de4:	c1 e2 0c             	shl    $0xc,%edx
c0103de7:	39 d0                	cmp    %edx,%eax
c0103de9:	72 24                	jb     c0103e0f <basic_check+0x18d>
c0103deb:	c7 44 24 0c a8 ca 10 	movl   $0xc010caa8,0xc(%esp)
c0103df2:	c0 
c0103df3:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103dfa:	c0 
c0103dfb:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103e02:	00 
c0103e03:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103e0a:	e8 dc cf ff ff       	call   c0100deb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e12:	89 04 24             	mov    %eax,(%esp)
c0103e15:	e8 36 f8 ff ff       	call   c0103650 <page2pa>
c0103e1a:	8b 15 a0 ef 19 c0    	mov    0xc019efa0,%edx
c0103e20:	c1 e2 0c             	shl    $0xc,%edx
c0103e23:	39 d0                	cmp    %edx,%eax
c0103e25:	72 24                	jb     c0103e4b <basic_check+0x1c9>
c0103e27:	c7 44 24 0c c5 ca 10 	movl   $0xc010cac5,0xc(%esp)
c0103e2e:	c0 
c0103e2f:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103e36:	c0 
c0103e37:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103e3e:	00 
c0103e3f:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103e46:	e8 a0 cf ff ff       	call   c0100deb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e4e:	89 04 24             	mov    %eax,(%esp)
c0103e51:	e8 fa f7 ff ff       	call   c0103650 <page2pa>
c0103e56:	8b 15 a0 ef 19 c0    	mov    0xc019efa0,%edx
c0103e5c:	c1 e2 0c             	shl    $0xc,%edx
c0103e5f:	39 d0                	cmp    %edx,%eax
c0103e61:	72 24                	jb     c0103e87 <basic_check+0x205>
c0103e63:	c7 44 24 0c e2 ca 10 	movl   $0xc010cae2,0xc(%esp)
c0103e6a:	c0 
c0103e6b:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103e72:	c0 
c0103e73:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103e7a:	00 
c0103e7b:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103e82:	e8 64 cf ff ff       	call   c0100deb <__panic>

    list_entry_t free_list_store = free_list;
c0103e87:	a1 d0 10 1a c0       	mov    0xc01a10d0,%eax
c0103e8c:	8b 15 d4 10 1a c0    	mov    0xc01a10d4,%edx
c0103e92:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103e95:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103e98:	c7 45 e0 d0 10 1a c0 	movl   $0xc01a10d0,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103e9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ea2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103ea5:	89 50 04             	mov    %edx,0x4(%eax)
c0103ea8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103eab:	8b 50 04             	mov    0x4(%eax),%edx
c0103eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103eb1:	89 10                	mov    %edx,(%eax)
c0103eb3:	c7 45 dc d0 10 1a c0 	movl   $0xc01a10d0,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103eba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ebd:	8b 40 04             	mov    0x4(%eax),%eax
c0103ec0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103ec3:	0f 94 c0             	sete   %al
c0103ec6:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103ec9:	85 c0                	test   %eax,%eax
c0103ecb:	75 24                	jne    c0103ef1 <basic_check+0x26f>
c0103ecd:	c7 44 24 0c ff ca 10 	movl   $0xc010caff,0xc(%esp)
c0103ed4:	c0 
c0103ed5:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103edc:	c0 
c0103edd:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103ee4:	00 
c0103ee5:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103eec:	e8 fa ce ff ff       	call   c0100deb <__panic>

    unsigned int nr_free_store = nr_free;
c0103ef1:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c0103ef6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103ef9:	c7 05 d8 10 1a c0 00 	movl   $0x0,0xc01a10d8
c0103f00:	00 00 00 

    assert(alloc_page() == NULL);
c0103f03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f0a:	e8 74 13 00 00       	call   c0105283 <alloc_pages>
c0103f0f:	85 c0                	test   %eax,%eax
c0103f11:	74 24                	je     c0103f37 <basic_check+0x2b5>
c0103f13:	c7 44 24 0c 16 cb 10 	movl   $0xc010cb16,0xc(%esp)
c0103f1a:	c0 
c0103f1b:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103f22:	c0 
c0103f23:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103f2a:	00 
c0103f2b:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103f32:	e8 b4 ce ff ff       	call   c0100deb <__panic>

    free_page(p0);
c0103f37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f3e:	00 
c0103f3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f42:	89 04 24             	mov    %eax,(%esp)
c0103f45:	e8 a4 13 00 00       	call   c01052ee <free_pages>
    free_page(p1);
c0103f4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f51:	00 
c0103f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f55:	89 04 24             	mov    %eax,(%esp)
c0103f58:	e8 91 13 00 00       	call   c01052ee <free_pages>
    free_page(p2);
c0103f5d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f64:	00 
c0103f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f68:	89 04 24             	mov    %eax,(%esp)
c0103f6b:	e8 7e 13 00 00       	call   c01052ee <free_pages>
    assert(nr_free == 3);
c0103f70:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c0103f75:	83 f8 03             	cmp    $0x3,%eax
c0103f78:	74 24                	je     c0103f9e <basic_check+0x31c>
c0103f7a:	c7 44 24 0c 2b cb 10 	movl   $0xc010cb2b,0xc(%esp)
c0103f81:	c0 
c0103f82:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103f89:	c0 
c0103f8a:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103f91:	00 
c0103f92:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103f99:	e8 4d ce ff ff       	call   c0100deb <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103f9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fa5:	e8 d9 12 00 00       	call   c0105283 <alloc_pages>
c0103faa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103fad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103fb1:	75 24                	jne    c0103fd7 <basic_check+0x355>
c0103fb3:	c7 44 24 0c f4 c9 10 	movl   $0xc010c9f4,0xc(%esp)
c0103fba:	c0 
c0103fbb:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103fc2:	c0 
c0103fc3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103fca:	00 
c0103fcb:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0103fd2:	e8 14 ce ff ff       	call   c0100deb <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103fd7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fde:	e8 a0 12 00 00       	call   c0105283 <alloc_pages>
c0103fe3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fe6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103fea:	75 24                	jne    c0104010 <basic_check+0x38e>
c0103fec:	c7 44 24 0c 10 ca 10 	movl   $0xc010ca10,0xc(%esp)
c0103ff3:	c0 
c0103ff4:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0103ffb:	c0 
c0103ffc:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0104003:	00 
c0104004:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010400b:	e8 db cd ff ff       	call   c0100deb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104010:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104017:	e8 67 12 00 00       	call   c0105283 <alloc_pages>
c010401c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010401f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104023:	75 24                	jne    c0104049 <basic_check+0x3c7>
c0104025:	c7 44 24 0c 2c ca 10 	movl   $0xc010ca2c,0xc(%esp)
c010402c:	c0 
c010402d:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104034:	c0 
c0104035:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c010403c:	00 
c010403d:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104044:	e8 a2 cd ff ff       	call   c0100deb <__panic>

    assert(alloc_page() == NULL);
c0104049:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104050:	e8 2e 12 00 00       	call   c0105283 <alloc_pages>
c0104055:	85 c0                	test   %eax,%eax
c0104057:	74 24                	je     c010407d <basic_check+0x3fb>
c0104059:	c7 44 24 0c 16 cb 10 	movl   $0xc010cb16,0xc(%esp)
c0104060:	c0 
c0104061:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104068:	c0 
c0104069:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0104070:	00 
c0104071:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104078:	e8 6e cd ff ff       	call   c0100deb <__panic>

    free_page(p0);
c010407d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104084:	00 
c0104085:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104088:	89 04 24             	mov    %eax,(%esp)
c010408b:	e8 5e 12 00 00       	call   c01052ee <free_pages>
c0104090:	c7 45 d8 d0 10 1a c0 	movl   $0xc01a10d0,-0x28(%ebp)
c0104097:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010409a:	8b 40 04             	mov    0x4(%eax),%eax
c010409d:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01040a0:	0f 94 c0             	sete   %al
c01040a3:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01040a6:	85 c0                	test   %eax,%eax
c01040a8:	74 24                	je     c01040ce <basic_check+0x44c>
c01040aa:	c7 44 24 0c 38 cb 10 	movl   $0xc010cb38,0xc(%esp)
c01040b1:	c0 
c01040b2:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01040b9:	c0 
c01040ba:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c01040c1:	00 
c01040c2:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01040c9:	e8 1d cd ff ff       	call   c0100deb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01040ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040d5:	e8 a9 11 00 00       	call   c0105283 <alloc_pages>
c01040da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01040dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040e0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01040e3:	74 24                	je     c0104109 <basic_check+0x487>
c01040e5:	c7 44 24 0c 50 cb 10 	movl   $0xc010cb50,0xc(%esp)
c01040ec:	c0 
c01040ed:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01040f4:	c0 
c01040f5:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01040fc:	00 
c01040fd:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104104:	e8 e2 cc ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c0104109:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104110:	e8 6e 11 00 00       	call   c0105283 <alloc_pages>
c0104115:	85 c0                	test   %eax,%eax
c0104117:	74 24                	je     c010413d <basic_check+0x4bb>
c0104119:	c7 44 24 0c 16 cb 10 	movl   $0xc010cb16,0xc(%esp)
c0104120:	c0 
c0104121:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104128:	c0 
c0104129:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0104130:	00 
c0104131:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104138:	e8 ae cc ff ff       	call   c0100deb <__panic>

    assert(nr_free == 0);
c010413d:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c0104142:	85 c0                	test   %eax,%eax
c0104144:	74 24                	je     c010416a <basic_check+0x4e8>
c0104146:	c7 44 24 0c 69 cb 10 	movl   $0xc010cb69,0xc(%esp)
c010414d:	c0 
c010414e:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104155:	c0 
c0104156:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c010415d:	00 
c010415e:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104165:	e8 81 cc ff ff       	call   c0100deb <__panic>
    free_list = free_list_store;
c010416a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010416d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104170:	a3 d0 10 1a c0       	mov    %eax,0xc01a10d0
c0104175:	89 15 d4 10 1a c0    	mov    %edx,0xc01a10d4
    nr_free = nr_free_store;
c010417b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010417e:	a3 d8 10 1a c0       	mov    %eax,0xc01a10d8

    free_page(p);
c0104183:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010418a:	00 
c010418b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010418e:	89 04 24             	mov    %eax,(%esp)
c0104191:	e8 58 11 00 00       	call   c01052ee <free_pages>
    free_page(p1);
c0104196:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010419d:	00 
c010419e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01041a1:	89 04 24             	mov    %eax,(%esp)
c01041a4:	e8 45 11 00 00       	call   c01052ee <free_pages>
    free_page(p2);
c01041a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041b0:	00 
c01041b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041b4:	89 04 24             	mov    %eax,(%esp)
c01041b7:	e8 32 11 00 00       	call   c01052ee <free_pages>
}
c01041bc:	c9                   	leave  
c01041bd:	c3                   	ret    

c01041be <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01041be:	55                   	push   %ebp
c01041bf:	89 e5                	mov    %esp,%ebp
c01041c1:	53                   	push   %ebx
c01041c2:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c01041c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01041cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01041d6:	c7 45 ec d0 10 1a c0 	movl   $0xc01a10d0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01041dd:	eb 6b                	jmp    c010424a <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c01041df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041e2:	83 e8 0c             	sub    $0xc,%eax
c01041e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c01041e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041eb:	83 c0 04             	add    $0x4,%eax
c01041ee:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01041f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01041fb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01041fe:	0f a3 10             	bt     %edx,(%eax)
c0104201:	19 c0                	sbb    %eax,%eax
c0104203:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104206:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010420a:	0f 95 c0             	setne  %al
c010420d:	0f b6 c0             	movzbl %al,%eax
c0104210:	85 c0                	test   %eax,%eax
c0104212:	75 24                	jne    c0104238 <default_check+0x7a>
c0104214:	c7 44 24 0c 76 cb 10 	movl   $0xc010cb76,0xc(%esp)
c010421b:	c0 
c010421c:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104223:	c0 
c0104224:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010422b:	00 
c010422c:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104233:	e8 b3 cb ff ff       	call   c0100deb <__panic>
        count ++, total += p->property;
c0104238:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010423c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010423f:	8b 50 08             	mov    0x8(%eax),%edx
c0104242:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104245:	01 d0                	add    %edx,%eax
c0104247:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010424a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010424d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104250:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104253:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104256:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104259:	81 7d ec d0 10 1a c0 	cmpl   $0xc01a10d0,-0x14(%ebp)
c0104260:	0f 85 79 ff ff ff    	jne    c01041df <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0104266:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0104269:	e8 b2 10 00 00       	call   c0105320 <nr_free_pages>
c010426e:	39 c3                	cmp    %eax,%ebx
c0104270:	74 24                	je     c0104296 <default_check+0xd8>
c0104272:	c7 44 24 0c 86 cb 10 	movl   $0xc010cb86,0xc(%esp)
c0104279:	c0 
c010427a:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104281:	c0 
c0104282:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0104289:	00 
c010428a:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104291:	e8 55 cb ff ff       	call   c0100deb <__panic>

    basic_check();
c0104296:	e8 e7 f9 ff ff       	call   c0103c82 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010429b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01042a2:	e8 dc 0f 00 00       	call   c0105283 <alloc_pages>
c01042a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c01042aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01042ae:	75 24                	jne    c01042d4 <default_check+0x116>
c01042b0:	c7 44 24 0c 9f cb 10 	movl   $0xc010cb9f,0xc(%esp)
c01042b7:	c0 
c01042b8:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01042bf:	c0 
c01042c0:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01042c7:	00 
c01042c8:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01042cf:	e8 17 cb ff ff       	call   c0100deb <__panic>
    assert(!PageProperty(p0));
c01042d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042d7:	83 c0 04             	add    $0x4,%eax
c01042da:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01042e1:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042e4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01042e7:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01042ea:	0f a3 10             	bt     %edx,(%eax)
c01042ed:	19 c0                	sbb    %eax,%eax
c01042ef:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01042f2:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01042f6:	0f 95 c0             	setne  %al
c01042f9:	0f b6 c0             	movzbl %al,%eax
c01042fc:	85 c0                	test   %eax,%eax
c01042fe:	74 24                	je     c0104324 <default_check+0x166>
c0104300:	c7 44 24 0c aa cb 10 	movl   $0xc010cbaa,0xc(%esp)
c0104307:	c0 
c0104308:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010430f:	c0 
c0104310:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104317:	00 
c0104318:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010431f:	e8 c7 ca ff ff       	call   c0100deb <__panic>

    list_entry_t free_list_store = free_list;
c0104324:	a1 d0 10 1a c0       	mov    0xc01a10d0,%eax
c0104329:	8b 15 d4 10 1a c0    	mov    0xc01a10d4,%edx
c010432f:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104332:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104335:	c7 45 b4 d0 10 1a c0 	movl   $0xc01a10d0,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010433c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010433f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104342:	89 50 04             	mov    %edx,0x4(%eax)
c0104345:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104348:	8b 50 04             	mov    0x4(%eax),%edx
c010434b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010434e:	89 10                	mov    %edx,(%eax)
c0104350:	c7 45 b0 d0 10 1a c0 	movl   $0xc01a10d0,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104357:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010435a:	8b 40 04             	mov    0x4(%eax),%eax
c010435d:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104360:	0f 94 c0             	sete   %al
c0104363:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104366:	85 c0                	test   %eax,%eax
c0104368:	75 24                	jne    c010438e <default_check+0x1d0>
c010436a:	c7 44 24 0c ff ca 10 	movl   $0xc010caff,0xc(%esp)
c0104371:	c0 
c0104372:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104379:	c0 
c010437a:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104381:	00 
c0104382:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104389:	e8 5d ca ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c010438e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104395:	e8 e9 0e 00 00       	call   c0105283 <alloc_pages>
c010439a:	85 c0                	test   %eax,%eax
c010439c:	74 24                	je     c01043c2 <default_check+0x204>
c010439e:	c7 44 24 0c 16 cb 10 	movl   $0xc010cb16,0xc(%esp)
c01043a5:	c0 
c01043a6:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01043ad:	c0 
c01043ae:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01043b5:	00 
c01043b6:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01043bd:	e8 29 ca ff ff       	call   c0100deb <__panic>

    unsigned int nr_free_store = nr_free;
c01043c2:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c01043c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01043ca:	c7 05 d8 10 1a c0 00 	movl   $0x0,0xc01a10d8
c01043d1:	00 00 00 

    free_pages(p0 + 2, 3);
c01043d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043d7:	83 c0 40             	add    $0x40,%eax
c01043da:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01043e1:	00 
c01043e2:	89 04 24             	mov    %eax,(%esp)
c01043e5:	e8 04 0f 00 00       	call   c01052ee <free_pages>
    assert(alloc_pages(4) == NULL);
c01043ea:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01043f1:	e8 8d 0e 00 00       	call   c0105283 <alloc_pages>
c01043f6:	85 c0                	test   %eax,%eax
c01043f8:	74 24                	je     c010441e <default_check+0x260>
c01043fa:	c7 44 24 0c bc cb 10 	movl   $0xc010cbbc,0xc(%esp)
c0104401:	c0 
c0104402:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104409:	c0 
c010440a:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0104411:	00 
c0104412:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104419:	e8 cd c9 ff ff       	call   c0100deb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010441e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104421:	83 c0 40             	add    $0x40,%eax
c0104424:	83 c0 04             	add    $0x4,%eax
c0104427:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010442e:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104431:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104434:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104437:	0f a3 10             	bt     %edx,(%eax)
c010443a:	19 c0                	sbb    %eax,%eax
c010443c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010443f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104443:	0f 95 c0             	setne  %al
c0104446:	0f b6 c0             	movzbl %al,%eax
c0104449:	85 c0                	test   %eax,%eax
c010444b:	74 0e                	je     c010445b <default_check+0x29d>
c010444d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104450:	83 c0 40             	add    $0x40,%eax
c0104453:	8b 40 08             	mov    0x8(%eax),%eax
c0104456:	83 f8 03             	cmp    $0x3,%eax
c0104459:	74 24                	je     c010447f <default_check+0x2c1>
c010445b:	c7 44 24 0c d4 cb 10 	movl   $0xc010cbd4,0xc(%esp)
c0104462:	c0 
c0104463:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010446a:	c0 
c010446b:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104472:	00 
c0104473:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010447a:	e8 6c c9 ff ff       	call   c0100deb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010447f:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104486:	e8 f8 0d 00 00       	call   c0105283 <alloc_pages>
c010448b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010448e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104492:	75 24                	jne    c01044b8 <default_check+0x2fa>
c0104494:	c7 44 24 0c 00 cc 10 	movl   $0xc010cc00,0xc(%esp)
c010449b:	c0 
c010449c:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01044a3:	c0 
c01044a4:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01044ab:	00 
c01044ac:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01044b3:	e8 33 c9 ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c01044b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044bf:	e8 bf 0d 00 00       	call   c0105283 <alloc_pages>
c01044c4:	85 c0                	test   %eax,%eax
c01044c6:	74 24                	je     c01044ec <default_check+0x32e>
c01044c8:	c7 44 24 0c 16 cb 10 	movl   $0xc010cb16,0xc(%esp)
c01044cf:	c0 
c01044d0:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01044d7:	c0 
c01044d8:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c01044df:	00 
c01044e0:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01044e7:	e8 ff c8 ff ff       	call   c0100deb <__panic>
    assert(p0 + 2 == p1);
c01044ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044ef:	83 c0 40             	add    $0x40,%eax
c01044f2:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01044f5:	74 24                	je     c010451b <default_check+0x35d>
c01044f7:	c7 44 24 0c 1e cc 10 	movl   $0xc010cc1e,0xc(%esp)
c01044fe:	c0 
c01044ff:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104506:	c0 
c0104507:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c010450e:	00 
c010450f:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104516:	e8 d0 c8 ff ff       	call   c0100deb <__panic>

    p2 = p0 + 1;
c010451b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010451e:	83 c0 20             	add    $0x20,%eax
c0104521:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104524:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010452b:	00 
c010452c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010452f:	89 04 24             	mov    %eax,(%esp)
c0104532:	e8 b7 0d 00 00       	call   c01052ee <free_pages>
    free_pages(p1, 3);
c0104537:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010453e:	00 
c010453f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104542:	89 04 24             	mov    %eax,(%esp)
c0104545:	e8 a4 0d 00 00       	call   c01052ee <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010454a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010454d:	83 c0 04             	add    $0x4,%eax
c0104550:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104557:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010455a:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010455d:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104560:	0f a3 10             	bt     %edx,(%eax)
c0104563:	19 c0                	sbb    %eax,%eax
c0104565:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104568:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010456c:	0f 95 c0             	setne  %al
c010456f:	0f b6 c0             	movzbl %al,%eax
c0104572:	85 c0                	test   %eax,%eax
c0104574:	74 0b                	je     c0104581 <default_check+0x3c3>
c0104576:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104579:	8b 40 08             	mov    0x8(%eax),%eax
c010457c:	83 f8 01             	cmp    $0x1,%eax
c010457f:	74 24                	je     c01045a5 <default_check+0x3e7>
c0104581:	c7 44 24 0c 2c cc 10 	movl   $0xc010cc2c,0xc(%esp)
c0104588:	c0 
c0104589:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104590:	c0 
c0104591:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0104598:	00 
c0104599:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01045a0:	e8 46 c8 ff ff       	call   c0100deb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01045a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045a8:	83 c0 04             	add    $0x4,%eax
c01045ab:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01045b2:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045b5:	8b 45 90             	mov    -0x70(%ebp),%eax
c01045b8:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01045bb:	0f a3 10             	bt     %edx,(%eax)
c01045be:	19 c0                	sbb    %eax,%eax
c01045c0:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01045c3:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01045c7:	0f 95 c0             	setne  %al
c01045ca:	0f b6 c0             	movzbl %al,%eax
c01045cd:	85 c0                	test   %eax,%eax
c01045cf:	74 0b                	je     c01045dc <default_check+0x41e>
c01045d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045d4:	8b 40 08             	mov    0x8(%eax),%eax
c01045d7:	83 f8 03             	cmp    $0x3,%eax
c01045da:	74 24                	je     c0104600 <default_check+0x442>
c01045dc:	c7 44 24 0c 54 cc 10 	movl   $0xc010cc54,0xc(%esp)
c01045e3:	c0 
c01045e4:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01045eb:	c0 
c01045ec:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c01045f3:	00 
c01045f4:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01045fb:	e8 eb c7 ff ff       	call   c0100deb <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104600:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104607:	e8 77 0c 00 00       	call   c0105283 <alloc_pages>
c010460c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010460f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104612:	83 e8 20             	sub    $0x20,%eax
c0104615:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104618:	74 24                	je     c010463e <default_check+0x480>
c010461a:	c7 44 24 0c 7a cc 10 	movl   $0xc010cc7a,0xc(%esp)
c0104621:	c0 
c0104622:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c0104629:	c0 
c010462a:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0104631:	00 
c0104632:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104639:	e8 ad c7 ff ff       	call   c0100deb <__panic>
    free_page(p0);
c010463e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104645:	00 
c0104646:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104649:	89 04 24             	mov    %eax,(%esp)
c010464c:	e8 9d 0c 00 00       	call   c01052ee <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104651:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0104658:	e8 26 0c 00 00       	call   c0105283 <alloc_pages>
c010465d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104660:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104663:	83 c0 20             	add    $0x20,%eax
c0104666:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104669:	74 24                	je     c010468f <default_check+0x4d1>
c010466b:	c7 44 24 0c 98 cc 10 	movl   $0xc010cc98,0xc(%esp)
c0104672:	c0 
c0104673:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010467a:	c0 
c010467b:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0104682:	00 
c0104683:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010468a:	e8 5c c7 ff ff       	call   c0100deb <__panic>

    free_pages(p0, 2);
c010468f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104696:	00 
c0104697:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010469a:	89 04 24             	mov    %eax,(%esp)
c010469d:	e8 4c 0c 00 00       	call   c01052ee <free_pages>
    free_page(p2);
c01046a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01046a9:	00 
c01046aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046ad:	89 04 24             	mov    %eax,(%esp)
c01046b0:	e8 39 0c 00 00       	call   c01052ee <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01046b5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01046bc:	e8 c2 0b 00 00       	call   c0105283 <alloc_pages>
c01046c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01046c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01046c8:	75 24                	jne    c01046ee <default_check+0x530>
c01046ca:	c7 44 24 0c b8 cc 10 	movl   $0xc010ccb8,0xc(%esp)
c01046d1:	c0 
c01046d2:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01046d9:	c0 
c01046da:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01046e1:	00 
c01046e2:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01046e9:	e8 fd c6 ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c01046ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01046f5:	e8 89 0b 00 00       	call   c0105283 <alloc_pages>
c01046fa:	85 c0                	test   %eax,%eax
c01046fc:	74 24                	je     c0104722 <default_check+0x564>
c01046fe:	c7 44 24 0c 16 cb 10 	movl   $0xc010cb16,0xc(%esp)
c0104705:	c0 
c0104706:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010470d:	c0 
c010470e:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0104715:	00 
c0104716:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010471d:	e8 c9 c6 ff ff       	call   c0100deb <__panic>

    assert(nr_free == 0);
c0104722:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c0104727:	85 c0                	test   %eax,%eax
c0104729:	74 24                	je     c010474f <default_check+0x591>
c010472b:	c7 44 24 0c 69 cb 10 	movl   $0xc010cb69,0xc(%esp)
c0104732:	c0 
c0104733:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c010473a:	c0 
c010473b:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0104742:	00 
c0104743:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c010474a:	e8 9c c6 ff ff       	call   c0100deb <__panic>
    nr_free = nr_free_store;
c010474f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104752:	a3 d8 10 1a c0       	mov    %eax,0xc01a10d8

    free_list = free_list_store;
c0104757:	8b 45 80             	mov    -0x80(%ebp),%eax
c010475a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010475d:	a3 d0 10 1a c0       	mov    %eax,0xc01a10d0
c0104762:	89 15 d4 10 1a c0    	mov    %edx,0xc01a10d4
    free_pages(p0, 5);
c0104768:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010476f:	00 
c0104770:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104773:	89 04 24             	mov    %eax,(%esp)
c0104776:	e8 73 0b 00 00       	call   c01052ee <free_pages>

    le = &free_list;
c010477b:	c7 45 ec d0 10 1a c0 	movl   $0xc01a10d0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104782:	eb 1d                	jmp    c01047a1 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0104784:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104787:	83 e8 0c             	sub    $0xc,%eax
c010478a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c010478d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104791:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104794:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104797:	8b 40 08             	mov    0x8(%eax),%eax
c010479a:	29 c2                	sub    %eax,%edx
c010479c:	89 d0                	mov    %edx,%eax
c010479e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047a4:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01047a7:	8b 45 88             	mov    -0x78(%ebp),%eax
c01047aa:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01047ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01047b0:	81 7d ec d0 10 1a c0 	cmpl   $0xc01a10d0,-0x14(%ebp)
c01047b7:	75 cb                	jne    c0104784 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01047b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047bd:	74 24                	je     c01047e3 <default_check+0x625>
c01047bf:	c7 44 24 0c d6 cc 10 	movl   $0xc010ccd6,0xc(%esp)
c01047c6:	c0 
c01047c7:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01047ce:	c0 
c01047cf:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c01047d6:	00 
c01047d7:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c01047de:	e8 08 c6 ff ff       	call   c0100deb <__panic>
    assert(total == 0);
c01047e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01047e7:	74 24                	je     c010480d <default_check+0x64f>
c01047e9:	c7 44 24 0c e1 cc 10 	movl   $0xc010cce1,0xc(%esp)
c01047f0:	c0 
c01047f1:	c7 44 24 08 76 c9 10 	movl   $0xc010c976,0x8(%esp)
c01047f8:	c0 
c01047f9:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0104800:	00 
c0104801:	c7 04 24 8b c9 10 c0 	movl   $0xc010c98b,(%esp)
c0104808:	e8 de c5 ff ff       	call   c0100deb <__panic>
}
c010480d:	81 c4 94 00 00 00    	add    $0x94,%esp
c0104813:	5b                   	pop    %ebx
c0104814:	5d                   	pop    %ebp
c0104815:	c3                   	ret    

c0104816 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0104816:	55                   	push   %ebp
c0104817:	89 e5                	mov    %esp,%ebp
c0104819:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010481c:	9c                   	pushf  
c010481d:	58                   	pop    %eax
c010481e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104821:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104824:	25 00 02 00 00       	and    $0x200,%eax
c0104829:	85 c0                	test   %eax,%eax
c010482b:	74 0c                	je     c0104839 <__intr_save+0x23>
        intr_disable();
c010482d:	e8 22 d8 ff ff       	call   c0102054 <intr_disable>
        return 1;
c0104832:	b8 01 00 00 00       	mov    $0x1,%eax
c0104837:	eb 05                	jmp    c010483e <__intr_save+0x28>
    }
    return 0;
c0104839:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010483e:	c9                   	leave  
c010483f:	c3                   	ret    

c0104840 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104840:	55                   	push   %ebp
c0104841:	89 e5                	mov    %esp,%ebp
c0104843:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104846:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010484a:	74 05                	je     c0104851 <__intr_restore+0x11>
        intr_enable();
c010484c:	e8 fd d7 ff ff       	call   c010204e <intr_enable>
    }
}
c0104851:	c9                   	leave  
c0104852:	c3                   	ret    

c0104853 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104853:	55                   	push   %ebp
c0104854:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104856:	8b 55 08             	mov    0x8(%ebp),%edx
c0104859:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c010485e:	29 c2                	sub    %eax,%edx
c0104860:	89 d0                	mov    %edx,%eax
c0104862:	c1 f8 05             	sar    $0x5,%eax
}
c0104865:	5d                   	pop    %ebp
c0104866:	c3                   	ret    

c0104867 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104867:	55                   	push   %ebp
c0104868:	89 e5                	mov    %esp,%ebp
c010486a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010486d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104870:	89 04 24             	mov    %eax,(%esp)
c0104873:	e8 db ff ff ff       	call   c0104853 <page2ppn>
c0104878:	c1 e0 0c             	shl    $0xc,%eax
}
c010487b:	c9                   	leave  
c010487c:	c3                   	ret    

c010487d <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010487d:	55                   	push   %ebp
c010487e:	89 e5                	mov    %esp,%ebp
c0104880:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104883:	8b 45 08             	mov    0x8(%ebp),%eax
c0104886:	c1 e8 0c             	shr    $0xc,%eax
c0104889:	89 c2                	mov    %eax,%edx
c010488b:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0104890:	39 c2                	cmp    %eax,%edx
c0104892:	72 1c                	jb     c01048b0 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104894:	c7 44 24 08 1c cd 10 	movl   $0xc010cd1c,0x8(%esp)
c010489b:	c0 
c010489c:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01048a3:	00 
c01048a4:	c7 04 24 3b cd 10 c0 	movl   $0xc010cd3b,(%esp)
c01048ab:	e8 3b c5 ff ff       	call   c0100deb <__panic>
    }
    return &pages[PPN(pa)];
c01048b0:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c01048b5:	8b 55 08             	mov    0x8(%ebp),%edx
c01048b8:	c1 ea 0c             	shr    $0xc,%edx
c01048bb:	c1 e2 05             	shl    $0x5,%edx
c01048be:	01 d0                	add    %edx,%eax
}
c01048c0:	c9                   	leave  
c01048c1:	c3                   	ret    

c01048c2 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01048c2:	55                   	push   %ebp
c01048c3:	89 e5                	mov    %esp,%ebp
c01048c5:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01048c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01048cb:	89 04 24             	mov    %eax,(%esp)
c01048ce:	e8 94 ff ff ff       	call   c0104867 <page2pa>
c01048d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d9:	c1 e8 0c             	shr    $0xc,%eax
c01048dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048df:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01048e4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01048e7:	72 23                	jb     c010490c <page2kva+0x4a>
c01048e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048f0:	c7 44 24 08 4c cd 10 	movl   $0xc010cd4c,0x8(%esp)
c01048f7:	c0 
c01048f8:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01048ff:	00 
c0104900:	c7 04 24 3b cd 10 c0 	movl   $0xc010cd3b,(%esp)
c0104907:	e8 df c4 ff ff       	call   c0100deb <__panic>
c010490c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010490f:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104914:	c9                   	leave  
c0104915:	c3                   	ret    

c0104916 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0104916:	55                   	push   %ebp
c0104917:	89 e5                	mov    %esp,%ebp
c0104919:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010491c:	8b 45 08             	mov    0x8(%ebp),%eax
c010491f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104922:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104929:	77 23                	ja     c010494e <kva2page+0x38>
c010492b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010492e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104932:	c7 44 24 08 70 cd 10 	movl   $0xc010cd70,0x8(%esp)
c0104939:	c0 
c010493a:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104941:	00 
c0104942:	c7 04 24 3b cd 10 c0 	movl   $0xc010cd3b,(%esp)
c0104949:	e8 9d c4 ff ff       	call   c0100deb <__panic>
c010494e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104951:	05 00 00 00 40       	add    $0x40000000,%eax
c0104956:	89 04 24             	mov    %eax,(%esp)
c0104959:	e8 1f ff ff ff       	call   c010487d <pa2page>
}
c010495e:	c9                   	leave  
c010495f:	c3                   	ret    

c0104960 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104960:	55                   	push   %ebp
c0104961:	89 e5                	mov    %esp,%ebp
c0104963:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104966:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104969:	ba 01 00 00 00       	mov    $0x1,%edx
c010496e:	89 c1                	mov    %eax,%ecx
c0104970:	d3 e2                	shl    %cl,%edx
c0104972:	89 d0                	mov    %edx,%eax
c0104974:	89 04 24             	mov    %eax,(%esp)
c0104977:	e8 07 09 00 00       	call   c0105283 <alloc_pages>
c010497c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c010497f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104983:	75 07                	jne    c010498c <__slob_get_free_pages+0x2c>
    return NULL;
c0104985:	b8 00 00 00 00       	mov    $0x0,%eax
c010498a:	eb 0b                	jmp    c0104997 <__slob_get_free_pages+0x37>
  return page2kva(page);
c010498c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010498f:	89 04 24             	mov    %eax,(%esp)
c0104992:	e8 2b ff ff ff       	call   c01048c2 <page2kva>
}
c0104997:	c9                   	leave  
c0104998:	c3                   	ret    

c0104999 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104999:	55                   	push   %ebp
c010499a:	89 e5                	mov    %esp,%ebp
c010499c:	53                   	push   %ebx
c010499d:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c01049a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049a3:	ba 01 00 00 00       	mov    $0x1,%edx
c01049a8:	89 c1                	mov    %eax,%ecx
c01049aa:	d3 e2                	shl    %cl,%edx
c01049ac:	89 d0                	mov    %edx,%eax
c01049ae:	89 c3                	mov    %eax,%ebx
c01049b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01049b3:	89 04 24             	mov    %eax,(%esp)
c01049b6:	e8 5b ff ff ff       	call   c0104916 <kva2page>
c01049bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01049bf:	89 04 24             	mov    %eax,(%esp)
c01049c2:	e8 27 09 00 00       	call   c01052ee <free_pages>
}
c01049c7:	83 c4 14             	add    $0x14,%esp
c01049ca:	5b                   	pop    %ebx
c01049cb:	5d                   	pop    %ebp
c01049cc:	c3                   	ret    

c01049cd <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c01049cd:	55                   	push   %ebp
c01049ce:	89 e5                	mov    %esp,%ebp
c01049d0:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c01049d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01049d6:	83 c0 08             	add    $0x8,%eax
c01049d9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01049de:	76 24                	jbe    c0104a04 <slob_alloc+0x37>
c01049e0:	c7 44 24 0c 94 cd 10 	movl   $0xc010cd94,0xc(%esp)
c01049e7:	c0 
c01049e8:	c7 44 24 08 b3 cd 10 	movl   $0xc010cdb3,0x8(%esp)
c01049ef:	c0 
c01049f0:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01049f7:	00 
c01049f8:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01049ff:	e8 e7 c3 ff ff       	call   c0100deb <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104a04:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0104a0b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104a12:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a15:	83 c0 07             	add    $0x7,%eax
c0104a18:	c1 e8 03             	shr    $0x3,%eax
c0104a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104a1e:	e8 f3 fd ff ff       	call   c0104816 <__intr_save>
c0104a23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104a26:	a1 e8 a9 12 c0       	mov    0xc012a9e8,%eax
c0104a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a31:	8b 40 04             	mov    0x4(%eax),%eax
c0104a34:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104a37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104a3b:	74 25                	je     c0104a62 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104a3d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a40:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a43:	01 d0                	add    %edx,%eax
c0104a45:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104a48:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a4b:	f7 d8                	neg    %eax
c0104a4d:	21 d0                	and    %edx,%eax
c0104a4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104a52:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a58:	29 c2                	sub    %eax,%edx
c0104a5a:	89 d0                	mov    %edx,%eax
c0104a5c:	c1 f8 03             	sar    $0x3,%eax
c0104a5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a65:	8b 00                	mov    (%eax),%eax
c0104a67:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104a6a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104a6d:	01 ca                	add    %ecx,%edx
c0104a6f:	39 d0                	cmp    %edx,%eax
c0104a71:	0f 8c aa 00 00 00    	jl     c0104b21 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0104a77:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104a7b:	74 38                	je     c0104ab5 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0104a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a80:	8b 00                	mov    (%eax),%eax
c0104a82:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104a85:	89 c2                	mov    %eax,%edx
c0104a87:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a8a:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a8f:	8b 50 04             	mov    0x4(%eax),%edx
c0104a92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a95:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a9b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a9e:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aa4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104aa7:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aac:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104aaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ab2:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ab8:	8b 00                	mov    (%eax),%eax
c0104aba:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104abd:	75 0e                	jne    c0104acd <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0104abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ac2:	8b 50 04             	mov    0x4(%eax),%edx
c0104ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ac8:	89 50 04             	mov    %edx,0x4(%eax)
c0104acb:	eb 3c                	jmp    c0104b09 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0104acd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ad0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ada:	01 c2                	add    %eax,%edx
c0104adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104adf:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ae5:	8b 40 04             	mov    0x4(%eax),%eax
c0104ae8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104aeb:	8b 12                	mov    (%edx),%edx
c0104aed:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104af0:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104af5:	8b 40 04             	mov    0x4(%eax),%eax
c0104af8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104afb:	8b 52 04             	mov    0x4(%edx),%edx
c0104afe:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b04:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104b07:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b0c:	a3 e8 a9 12 c0       	mov    %eax,0xc012a9e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0104b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b14:	89 04 24             	mov    %eax,(%esp)
c0104b17:	e8 24 fd ff ff       	call   c0104840 <__intr_restore>
			return cur;
c0104b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b1f:	eb 7f                	jmp    c0104ba0 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0104b21:	a1 e8 a9 12 c0       	mov    0xc012a9e8,%eax
c0104b26:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104b29:	75 61                	jne    c0104b8c <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b2e:	89 04 24             	mov    %eax,(%esp)
c0104b31:	e8 0a fd ff ff       	call   c0104840 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104b36:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104b3d:	75 07                	jne    c0104b46 <slob_alloc+0x179>
				return 0;
c0104b3f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b44:	eb 5a                	jmp    c0104ba0 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104b46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b4d:	00 
c0104b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b51:	89 04 24             	mov    %eax,(%esp)
c0104b54:	e8 07 fe ff ff       	call   c0104960 <__slob_get_free_pages>
c0104b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104b5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b60:	75 07                	jne    c0104b69 <slob_alloc+0x19c>
				return 0;
c0104b62:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b67:	eb 37                	jmp    c0104ba0 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c0104b69:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b70:	00 
c0104b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b74:	89 04 24             	mov    %eax,(%esp)
c0104b77:	e8 26 00 00 00       	call   c0104ba2 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104b7c:	e8 95 fc ff ff       	call   c0104816 <__intr_save>
c0104b81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104b84:	a1 e8 a9 12 c0       	mov    0xc012a9e8,%eax
c0104b89:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b95:	8b 40 04             	mov    0x4(%eax),%eax
c0104b98:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0104b9b:	e9 97 fe ff ff       	jmp    c0104a37 <slob_alloc+0x6a>
}
c0104ba0:	c9                   	leave  
c0104ba1:	c3                   	ret    

c0104ba2 <slob_free>:

static void slob_free(void *block, int size)
{
c0104ba2:	55                   	push   %ebp
c0104ba3:	89 e5                	mov    %esp,%ebp
c0104ba5:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104bae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104bb2:	75 05                	jne    c0104bb9 <slob_free+0x17>
		return;
c0104bb4:	e9 ff 00 00 00       	jmp    c0104cb8 <slob_free+0x116>

	if (size)
c0104bb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104bbd:	74 10                	je     c0104bcf <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c0104bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bc2:	83 c0 07             	add    $0x7,%eax
c0104bc5:	c1 e8 03             	shr    $0x3,%eax
c0104bc8:	89 c2                	mov    %eax,%edx
c0104bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bcd:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0104bcf:	e8 42 fc ff ff       	call   c0104816 <__intr_save>
c0104bd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104bd7:	a1 e8 a9 12 c0       	mov    0xc012a9e8,%eax
c0104bdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bdf:	eb 27                	jmp    c0104c08 <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0104be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104be4:	8b 40 04             	mov    0x4(%eax),%eax
c0104be7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bea:	77 13                	ja     c0104bff <slob_free+0x5d>
c0104bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bf2:	77 27                	ja     c0104c1b <slob_free+0x79>
c0104bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bf7:	8b 40 04             	mov    0x4(%eax),%eax
c0104bfa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104bfd:	77 1c                	ja     c0104c1b <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c02:	8b 40 04             	mov    0x4(%eax),%eax
c0104c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c0b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c0e:	76 d1                	jbe    c0104be1 <slob_free+0x3f>
c0104c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c13:	8b 40 04             	mov    0x4(%eax),%eax
c0104c16:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104c19:	76 c6                	jbe    c0104be1 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0104c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c1e:	8b 00                	mov    (%eax),%eax
c0104c20:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c2a:	01 c2                	add    %eax,%edx
c0104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c2f:	8b 40 04             	mov    0x4(%eax),%eax
c0104c32:	39 c2                	cmp    %eax,%edx
c0104c34:	75 25                	jne    c0104c5b <slob_free+0xb9>
		b->units += cur->next->units;
c0104c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c39:	8b 10                	mov    (%eax),%edx
c0104c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c3e:	8b 40 04             	mov    0x4(%eax),%eax
c0104c41:	8b 00                	mov    (%eax),%eax
c0104c43:	01 c2                	add    %eax,%edx
c0104c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c48:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c4d:	8b 40 04             	mov    0x4(%eax),%eax
c0104c50:	8b 50 04             	mov    0x4(%eax),%edx
c0104c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c56:	89 50 04             	mov    %edx,0x4(%eax)
c0104c59:	eb 0c                	jmp    c0104c67 <slob_free+0xc5>
	} else
		b->next = cur->next;
c0104c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c5e:	8b 50 04             	mov    0x4(%eax),%edx
c0104c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c64:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c6a:	8b 00                	mov    (%eax),%eax
c0104c6c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c76:	01 d0                	add    %edx,%eax
c0104c78:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104c7b:	75 1f                	jne    c0104c9c <slob_free+0xfa>
		cur->units += b->units;
c0104c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c80:	8b 10                	mov    (%eax),%edx
c0104c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c85:	8b 00                	mov    (%eax),%eax
c0104c87:	01 c2                	add    %eax,%edx
c0104c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c8c:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c91:	8b 50 04             	mov    0x4(%eax),%edx
c0104c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c97:	89 50 04             	mov    %edx,0x4(%eax)
c0104c9a:	eb 09                	jmp    c0104ca5 <slob_free+0x103>
	} else
		cur->next = b;
c0104c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104ca2:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca8:	a3 e8 a9 12 c0       	mov    %eax,0xc012a9e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0104cad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cb0:	89 04 24             	mov    %eax,(%esp)
c0104cb3:	e8 88 fb ff ff       	call   c0104840 <__intr_restore>
}
c0104cb8:	c9                   	leave  
c0104cb9:	c3                   	ret    

c0104cba <slob_init>:



void
slob_init(void) {
c0104cba:	55                   	push   %ebp
c0104cbb:	89 e5                	mov    %esp,%ebp
c0104cbd:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104cc0:	c7 04 24 da cd 10 c0 	movl   $0xc010cdda,(%esp)
c0104cc7:	e8 93 b6 ff ff       	call   c010035f <cprintf>
}
c0104ccc:	c9                   	leave  
c0104ccd:	c3                   	ret    

c0104cce <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104cce:	55                   	push   %ebp
c0104ccf:	89 e5                	mov    %esp,%ebp
c0104cd1:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104cd4:	e8 e1 ff ff ff       	call   c0104cba <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104cd9:	c7 04 24 ee cd 10 c0 	movl   $0xc010cdee,(%esp)
c0104ce0:	e8 7a b6 ff ff       	call   c010035f <cprintf>
}
c0104ce5:	c9                   	leave  
c0104ce6:	c3                   	ret    

c0104ce7 <slob_allocated>:

size_t
slob_allocated(void) {
c0104ce7:	55                   	push   %ebp
c0104ce8:	89 e5                	mov    %esp,%ebp
  return 0;
c0104cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cef:	5d                   	pop    %ebp
c0104cf0:	c3                   	ret    

c0104cf1 <kallocated>:

size_t
kallocated(void) {
c0104cf1:	55                   	push   %ebp
c0104cf2:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104cf4:	e8 ee ff ff ff       	call   c0104ce7 <slob_allocated>
}
c0104cf9:	5d                   	pop    %ebp
c0104cfa:	c3                   	ret    

c0104cfb <find_order>:

static int find_order(int size)
{
c0104cfb:	55                   	push   %ebp
c0104cfc:	89 e5                	mov    %esp,%ebp
c0104cfe:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104d01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104d08:	eb 07                	jmp    c0104d11 <find_order+0x16>
		order++;
c0104d0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0104d0e:	d1 7d 08             	sarl   0x8(%ebp)
c0104d11:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104d18:	7f f0                	jg     c0104d0a <find_order+0xf>
		order++;
	return order;
c0104d1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104d1d:	c9                   	leave  
c0104d1e:	c3                   	ret    

c0104d1f <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104d1f:	55                   	push   %ebp
c0104d20:	89 e5                	mov    %esp,%ebp
c0104d22:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104d25:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104d2c:	77 38                	ja     c0104d66 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104d2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d31:	8d 50 08             	lea    0x8(%eax),%edx
c0104d34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d3b:	00 
c0104d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d43:	89 14 24             	mov    %edx,(%esp)
c0104d46:	e8 82 fc ff ff       	call   c01049cd <slob_alloc>
c0104d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d52:	74 08                	je     c0104d5c <__kmalloc+0x3d>
c0104d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d57:	83 c0 08             	add    $0x8,%eax
c0104d5a:	eb 05                	jmp    c0104d61 <__kmalloc+0x42>
c0104d5c:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d61:	e9 a6 00 00 00       	jmp    c0104e0c <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104d66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d6d:	00 
c0104d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d75:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104d7c:	e8 4c fc ff ff       	call   c01049cd <slob_alloc>
c0104d81:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104d84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d88:	75 07                	jne    c0104d91 <__kmalloc+0x72>
		return 0;
c0104d8a:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d8f:	eb 7b                	jmp    c0104e0c <__kmalloc+0xed>

	bb->order = find_order(size);
c0104d91:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d94:	89 04 24             	mov    %eax,(%esp)
c0104d97:	e8 5f ff ff ff       	call   c0104cfb <find_order>
c0104d9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104d9f:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104da4:	8b 00                	mov    (%eax),%eax
c0104da6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104daa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dad:	89 04 24             	mov    %eax,(%esp)
c0104db0:	e8 ab fb ff ff       	call   c0104960 <__slob_get_free_pages>
c0104db5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104db8:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dbe:	8b 40 04             	mov    0x4(%eax),%eax
c0104dc1:	85 c0                	test   %eax,%eax
c0104dc3:	74 2f                	je     c0104df4 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0104dc5:	e8 4c fa ff ff       	call   c0104816 <__intr_save>
c0104dca:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104dcd:	8b 15 84 ef 19 c0    	mov    0xc019ef84,%edx
c0104dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dd6:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ddc:	a3 84 ef 19 c0       	mov    %eax,0xc019ef84
		spin_unlock_irqrestore(&block_lock, flags);
c0104de1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104de4:	89 04 24             	mov    %eax,(%esp)
c0104de7:	e8 54 fa ff ff       	call   c0104840 <__intr_restore>
		return bb->pages;
c0104dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104def:	8b 40 04             	mov    0x4(%eax),%eax
c0104df2:	eb 18                	jmp    c0104e0c <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104df4:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104dfb:	00 
c0104dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dff:	89 04 24             	mov    %eax,(%esp)
c0104e02:	e8 9b fd ff ff       	call   c0104ba2 <slob_free>
	return 0;
c0104e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e0c:	c9                   	leave  
c0104e0d:	c3                   	ret    

c0104e0e <kmalloc>:

void *
kmalloc(size_t size)
{
c0104e0e:	55                   	push   %ebp
c0104e0f:	89 e5                	mov    %esp,%ebp
c0104e11:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104e14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104e1b:	00 
c0104e1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e1f:	89 04 24             	mov    %eax,(%esp)
c0104e22:	e8 f8 fe ff ff       	call   c0104d1f <__kmalloc>
}
c0104e27:	c9                   	leave  
c0104e28:	c3                   	ret    

c0104e29 <kfree>:


void kfree(void *block)
{
c0104e29:	55                   	push   %ebp
c0104e2a:	89 e5                	mov    %esp,%ebp
c0104e2c:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104e2f:	c7 45 f0 84 ef 19 c0 	movl   $0xc019ef84,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104e36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104e3a:	75 05                	jne    c0104e41 <kfree+0x18>
		return;
c0104e3c:	e9 a2 00 00 00       	jmp    c0104ee3 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104e41:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e44:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e49:	85 c0                	test   %eax,%eax
c0104e4b:	75 7f                	jne    c0104ecc <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104e4d:	e8 c4 f9 ff ff       	call   c0104816 <__intr_save>
c0104e52:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104e55:	a1 84 ef 19 c0       	mov    0xc019ef84,%eax
c0104e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e5d:	eb 5c                	jmp    c0104ebb <kfree+0x92>
			if (bb->pages == block) {
c0104e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e62:	8b 40 04             	mov    0x4(%eax),%eax
c0104e65:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104e68:	75 3f                	jne    c0104ea9 <kfree+0x80>
				*last = bb->next;
c0104e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e6d:	8b 50 08             	mov    0x8(%eax),%edx
c0104e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e73:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e78:	89 04 24             	mov    %eax,(%esp)
c0104e7b:	e8 c0 f9 ff ff       	call   c0104840 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e83:	8b 10                	mov    (%eax),%edx
c0104e85:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e88:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e8c:	89 04 24             	mov    %eax,(%esp)
c0104e8f:	e8 05 fb ff ff       	call   c0104999 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104e94:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104e9b:	00 
c0104e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e9f:	89 04 24             	mov    %eax,(%esp)
c0104ea2:	e8 fb fc ff ff       	call   c0104ba2 <slob_free>
				return;
c0104ea7:	eb 3a                	jmp    c0104ee3 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eac:	83 c0 08             	add    $0x8,%eax
c0104eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eb5:	8b 40 08             	mov    0x8(%eax),%eax
c0104eb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ebb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ebf:	75 9e                	jne    c0104e5f <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ec4:	89 04 24             	mov    %eax,(%esp)
c0104ec7:	e8 74 f9 ff ff       	call   c0104840 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104ecc:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ecf:	83 e8 08             	sub    $0x8,%eax
c0104ed2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104ed9:	00 
c0104eda:	89 04 24             	mov    %eax,(%esp)
c0104edd:	e8 c0 fc ff ff       	call   c0104ba2 <slob_free>
	return;
c0104ee2:	90                   	nop
}
c0104ee3:	c9                   	leave  
c0104ee4:	c3                   	ret    

c0104ee5 <ksize>:


unsigned int ksize(const void *block)
{
c0104ee5:	55                   	push   %ebp
c0104ee6:	89 e5                	mov    %esp,%ebp
c0104ee8:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104eeb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104eef:	75 07                	jne    c0104ef8 <ksize+0x13>
		return 0;
c0104ef1:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ef6:	eb 6b                	jmp    c0104f63 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104ef8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104efb:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104f00:	85 c0                	test   %eax,%eax
c0104f02:	75 54                	jne    c0104f58 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104f04:	e8 0d f9 ff ff       	call   c0104816 <__intr_save>
c0104f09:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104f0c:	a1 84 ef 19 c0       	mov    0xc019ef84,%eax
c0104f11:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f14:	eb 31                	jmp    c0104f47 <ksize+0x62>
			if (bb->pages == block) {
c0104f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f19:	8b 40 04             	mov    0x4(%eax),%eax
c0104f1c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104f1f:	75 1d                	jne    c0104f3e <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f24:	89 04 24             	mov    %eax,(%esp)
c0104f27:	e8 14 f9 ff ff       	call   c0104840 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f2f:	8b 00                	mov    (%eax),%eax
c0104f31:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104f36:	89 c1                	mov    %eax,%ecx
c0104f38:	d3 e2                	shl    %cl,%edx
c0104f3a:	89 d0                	mov    %edx,%eax
c0104f3c:	eb 25                	jmp    c0104f63 <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0104f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f41:	8b 40 08             	mov    0x8(%eax),%eax
c0104f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f4b:	75 c9                	jne    c0104f16 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f50:	89 04 24             	mov    %eax,(%esp)
c0104f53:	e8 e8 f8 ff ff       	call   c0104840 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104f58:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f5b:	83 e8 08             	sub    $0x8,%eax
c0104f5e:	8b 00                	mov    (%eax),%eax
c0104f60:	c1 e0 03             	shl    $0x3,%eax
}
c0104f63:	c9                   	leave  
c0104f64:	c3                   	ret    

c0104f65 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104f65:	55                   	push   %ebp
c0104f66:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104f68:	8b 55 08             	mov    0x8(%ebp),%edx
c0104f6b:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0104f70:	29 c2                	sub    %eax,%edx
c0104f72:	89 d0                	mov    %edx,%eax
c0104f74:	c1 f8 05             	sar    $0x5,%eax
}
c0104f77:	5d                   	pop    %ebp
c0104f78:	c3                   	ret    

c0104f79 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104f79:	55                   	push   %ebp
c0104f7a:	89 e5                	mov    %esp,%ebp
c0104f7c:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104f7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f82:	89 04 24             	mov    %eax,(%esp)
c0104f85:	e8 db ff ff ff       	call   c0104f65 <page2ppn>
c0104f8a:	c1 e0 0c             	shl    $0xc,%eax
}
c0104f8d:	c9                   	leave  
c0104f8e:	c3                   	ret    

c0104f8f <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104f8f:	55                   	push   %ebp
c0104f90:	89 e5                	mov    %esp,%ebp
c0104f92:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104f95:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f98:	c1 e8 0c             	shr    $0xc,%eax
c0104f9b:	89 c2                	mov    %eax,%edx
c0104f9d:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0104fa2:	39 c2                	cmp    %eax,%edx
c0104fa4:	72 1c                	jb     c0104fc2 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104fa6:	c7 44 24 08 0c ce 10 	movl   $0xc010ce0c,0x8(%esp)
c0104fad:	c0 
c0104fae:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104fb5:	00 
c0104fb6:	c7 04 24 2b ce 10 c0 	movl   $0xc010ce2b,(%esp)
c0104fbd:	e8 29 be ff ff       	call   c0100deb <__panic>
    }
    return &pages[PPN(pa)];
c0104fc2:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0104fc7:	8b 55 08             	mov    0x8(%ebp),%edx
c0104fca:	c1 ea 0c             	shr    $0xc,%edx
c0104fcd:	c1 e2 05             	shl    $0x5,%edx
c0104fd0:	01 d0                	add    %edx,%eax
}
c0104fd2:	c9                   	leave  
c0104fd3:	c3                   	ret    

c0104fd4 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104fd4:	55                   	push   %ebp
c0104fd5:	89 e5                	mov    %esp,%ebp
c0104fd7:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104fda:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fdd:	89 04 24             	mov    %eax,(%esp)
c0104fe0:	e8 94 ff ff ff       	call   c0104f79 <page2pa>
c0104fe5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104feb:	c1 e8 0c             	shr    $0xc,%eax
c0104fee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ff1:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0104ff6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104ff9:	72 23                	jb     c010501e <page2kva+0x4a>
c0104ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ffe:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105002:	c7 44 24 08 3c ce 10 	movl   $0xc010ce3c,0x8(%esp)
c0105009:	c0 
c010500a:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0105011:	00 
c0105012:	c7 04 24 2b ce 10 c0 	movl   $0xc010ce2b,(%esp)
c0105019:	e8 cd bd ff ff       	call   c0100deb <__panic>
c010501e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105021:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105026:	c9                   	leave  
c0105027:	c3                   	ret    

c0105028 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0105028:	55                   	push   %ebp
c0105029:	89 e5                	mov    %esp,%ebp
c010502b:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010502e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105031:	83 e0 01             	and    $0x1,%eax
c0105034:	85 c0                	test   %eax,%eax
c0105036:	75 1c                	jne    c0105054 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0105038:	c7 44 24 08 60 ce 10 	movl   $0xc010ce60,0x8(%esp)
c010503f:	c0 
c0105040:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0105047:	00 
c0105048:	c7 04 24 2b ce 10 c0 	movl   $0xc010ce2b,(%esp)
c010504f:	e8 97 bd ff ff       	call   c0100deb <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0105054:	8b 45 08             	mov    0x8(%ebp),%eax
c0105057:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010505c:	89 04 24             	mov    %eax,(%esp)
c010505f:	e8 2b ff ff ff       	call   c0104f8f <pa2page>
}
c0105064:	c9                   	leave  
c0105065:	c3                   	ret    

c0105066 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0105066:	55                   	push   %ebp
c0105067:	89 e5                	mov    %esp,%ebp
c0105069:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010506c:	8b 45 08             	mov    0x8(%ebp),%eax
c010506f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105074:	89 04 24             	mov    %eax,(%esp)
c0105077:	e8 13 ff ff ff       	call   c0104f8f <pa2page>
}
c010507c:	c9                   	leave  
c010507d:	c3                   	ret    

c010507e <page_ref>:

static inline int
page_ref(struct Page *page) {
c010507e:	55                   	push   %ebp
c010507f:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105081:	8b 45 08             	mov    0x8(%ebp),%eax
c0105084:	8b 00                	mov    (%eax),%eax
}
c0105086:	5d                   	pop    %ebp
c0105087:	c3                   	ret    

c0105088 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0105088:	55                   	push   %ebp
c0105089:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010508b:	8b 45 08             	mov    0x8(%ebp),%eax
c010508e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105091:	89 10                	mov    %edx,(%eax)
}
c0105093:	5d                   	pop    %ebp
c0105094:	c3                   	ret    

c0105095 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0105095:	55                   	push   %ebp
c0105096:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0105098:	8b 45 08             	mov    0x8(%ebp),%eax
c010509b:	8b 00                	mov    (%eax),%eax
c010509d:	8d 50 01             	lea    0x1(%eax),%edx
c01050a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01050a3:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01050a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01050a8:	8b 00                	mov    (%eax),%eax
}
c01050aa:	5d                   	pop    %ebp
c01050ab:	c3                   	ret    

c01050ac <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01050ac:	55                   	push   %ebp
c01050ad:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01050af:	8b 45 08             	mov    0x8(%ebp),%eax
c01050b2:	8b 00                	mov    (%eax),%eax
c01050b4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01050b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01050ba:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01050bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01050bf:	8b 00                	mov    (%eax),%eax
}
c01050c1:	5d                   	pop    %ebp
c01050c2:	c3                   	ret    

c01050c3 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01050c3:	55                   	push   %ebp
c01050c4:	89 e5                	mov    %esp,%ebp
c01050c6:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01050c9:	9c                   	pushf  
c01050ca:	58                   	pop    %eax
c01050cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01050ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01050d1:	25 00 02 00 00       	and    $0x200,%eax
c01050d6:	85 c0                	test   %eax,%eax
c01050d8:	74 0c                	je     c01050e6 <__intr_save+0x23>
        intr_disable();
c01050da:	e8 75 cf ff ff       	call   c0102054 <intr_disable>
        return 1;
c01050df:	b8 01 00 00 00       	mov    $0x1,%eax
c01050e4:	eb 05                	jmp    c01050eb <__intr_save+0x28>
    }
    return 0;
c01050e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01050eb:	c9                   	leave  
c01050ec:	c3                   	ret    

c01050ed <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01050ed:	55                   	push   %ebp
c01050ee:	89 e5                	mov    %esp,%ebp
c01050f0:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01050f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01050f7:	74 05                	je     c01050fe <__intr_restore+0x11>
        intr_enable();
c01050f9:	e8 50 cf ff ff       	call   c010204e <intr_enable>
    }
}
c01050fe:	c9                   	leave  
c01050ff:	c3                   	ret    

c0105100 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0105100:	55                   	push   %ebp
c0105101:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0105103:	8b 45 08             	mov    0x8(%ebp),%eax
c0105106:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0105109:	b8 23 00 00 00       	mov    $0x23,%eax
c010510e:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0105110:	b8 23 00 00 00       	mov    $0x23,%eax
c0105115:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0105117:	b8 10 00 00 00       	mov    $0x10,%eax
c010511c:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c010511e:	b8 10 00 00 00       	mov    $0x10,%eax
c0105123:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0105125:	b8 10 00 00 00       	mov    $0x10,%eax
c010512a:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c010512c:	ea 33 51 10 c0 08 00 	ljmp   $0x8,$0xc0105133
}
c0105133:	5d                   	pop    %ebp
c0105134:	c3                   	ret    

c0105135 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0105135:	55                   	push   %ebp
c0105136:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0105138:	8b 45 08             	mov    0x8(%ebp),%eax
c010513b:	a3 c4 ef 19 c0       	mov    %eax,0xc019efc4
}
c0105140:	5d                   	pop    %ebp
c0105141:	c3                   	ret    

c0105142 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0105142:	55                   	push   %ebp
c0105143:	89 e5                	mov    %esp,%ebp
c0105145:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0105148:	b8 00 a0 12 c0       	mov    $0xc012a000,%eax
c010514d:	89 04 24             	mov    %eax,(%esp)
c0105150:	e8 e0 ff ff ff       	call   c0105135 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0105155:	66 c7 05 c8 ef 19 c0 	movw   $0x10,0xc019efc8
c010515c:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010515e:	66 c7 05 48 aa 12 c0 	movw   $0x68,0xc012aa48
c0105165:	68 00 
c0105167:	b8 c0 ef 19 c0       	mov    $0xc019efc0,%eax
c010516c:	66 a3 4a aa 12 c0    	mov    %ax,0xc012aa4a
c0105172:	b8 c0 ef 19 c0       	mov    $0xc019efc0,%eax
c0105177:	c1 e8 10             	shr    $0x10,%eax
c010517a:	a2 4c aa 12 c0       	mov    %al,0xc012aa4c
c010517f:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0105186:	83 e0 f0             	and    $0xfffffff0,%eax
c0105189:	83 c8 09             	or     $0x9,%eax
c010518c:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0105191:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0105198:	83 e0 ef             	and    $0xffffffef,%eax
c010519b:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c01051a0:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c01051a7:	83 e0 9f             	and    $0xffffff9f,%eax
c01051aa:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c01051af:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c01051b6:	83 c8 80             	or     $0xffffff80,%eax
c01051b9:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c01051be:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c01051c5:	83 e0 f0             	and    $0xfffffff0,%eax
c01051c8:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c01051cd:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c01051d4:	83 e0 ef             	and    $0xffffffef,%eax
c01051d7:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c01051dc:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c01051e3:	83 e0 df             	and    $0xffffffdf,%eax
c01051e6:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c01051eb:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c01051f2:	83 c8 40             	or     $0x40,%eax
c01051f5:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c01051fa:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0105201:	83 e0 7f             	and    $0x7f,%eax
c0105204:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c0105209:	b8 c0 ef 19 c0       	mov    $0xc019efc0,%eax
c010520e:	c1 e8 18             	shr    $0x18,%eax
c0105211:	a2 4f aa 12 c0       	mov    %al,0xc012aa4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0105216:	c7 04 24 50 aa 12 c0 	movl   $0xc012aa50,(%esp)
c010521d:	e8 de fe ff ff       	call   c0105100 <lgdt>
c0105222:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0105228:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c010522c:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c010522f:	c9                   	leave  
c0105230:	c3                   	ret    

c0105231 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0105231:	55                   	push   %ebp
c0105232:	89 e5                	mov    %esp,%ebp
c0105234:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0105237:	c7 05 dc 10 1a c0 00 	movl   $0xc010cd00,0xc01a10dc
c010523e:	cd 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0105241:	a1 dc 10 1a c0       	mov    0xc01a10dc,%eax
c0105246:	8b 00                	mov    (%eax),%eax
c0105248:	89 44 24 04          	mov    %eax,0x4(%esp)
c010524c:	c7 04 24 8c ce 10 c0 	movl   $0xc010ce8c,(%esp)
c0105253:	e8 07 b1 ff ff       	call   c010035f <cprintf>
    pmm_manager->init();
c0105258:	a1 dc 10 1a c0       	mov    0xc01a10dc,%eax
c010525d:	8b 40 04             	mov    0x4(%eax),%eax
c0105260:	ff d0                	call   *%eax
}
c0105262:	c9                   	leave  
c0105263:	c3                   	ret    

c0105264 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0105264:	55                   	push   %ebp
c0105265:	89 e5                	mov    %esp,%ebp
c0105267:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010526a:	a1 dc 10 1a c0       	mov    0xc01a10dc,%eax
c010526f:	8b 40 08             	mov    0x8(%eax),%eax
c0105272:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105275:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105279:	8b 55 08             	mov    0x8(%ebp),%edx
c010527c:	89 14 24             	mov    %edx,(%esp)
c010527f:	ff d0                	call   *%eax
}
c0105281:	c9                   	leave  
c0105282:	c3                   	ret    

c0105283 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0105283:	55                   	push   %ebp
c0105284:	89 e5                	mov    %esp,%ebp
c0105286:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0105289:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0105290:	e8 2e fe ff ff       	call   c01050c3 <__intr_save>
c0105295:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0105298:	a1 dc 10 1a c0       	mov    0xc01a10dc,%eax
c010529d:	8b 40 0c             	mov    0xc(%eax),%eax
c01052a0:	8b 55 08             	mov    0x8(%ebp),%edx
c01052a3:	89 14 24             	mov    %edx,(%esp)
c01052a6:	ff d0                	call   *%eax
c01052a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01052ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052ae:	89 04 24             	mov    %eax,(%esp)
c01052b1:	e8 37 fe ff ff       	call   c01050ed <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01052b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052ba:	75 2d                	jne    c01052e9 <alloc_pages+0x66>
c01052bc:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01052c0:	77 27                	ja     c01052e9 <alloc_pages+0x66>
c01052c2:	a1 2c f0 19 c0       	mov    0xc019f02c,%eax
c01052c7:	85 c0                	test   %eax,%eax
c01052c9:	74 1e                	je     c01052e9 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01052cb:	8b 55 08             	mov    0x8(%ebp),%edx
c01052ce:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c01052d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01052da:	00 
c01052db:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052df:	89 04 24             	mov    %eax,(%esp)
c01052e2:	e8 19 1d 00 00       	call   c0107000 <swap_out>
    }
c01052e7:	eb a7                	jmp    c0105290 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01052e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01052ec:	c9                   	leave  
c01052ed:	c3                   	ret    

c01052ee <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01052ee:	55                   	push   %ebp
c01052ef:	89 e5                	mov    %esp,%ebp
c01052f1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01052f4:	e8 ca fd ff ff       	call   c01050c3 <__intr_save>
c01052f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01052fc:	a1 dc 10 1a c0       	mov    0xc01a10dc,%eax
c0105301:	8b 40 10             	mov    0x10(%eax),%eax
c0105304:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105307:	89 54 24 04          	mov    %edx,0x4(%esp)
c010530b:	8b 55 08             	mov    0x8(%ebp),%edx
c010530e:	89 14 24             	mov    %edx,(%esp)
c0105311:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0105313:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105316:	89 04 24             	mov    %eax,(%esp)
c0105319:	e8 cf fd ff ff       	call   c01050ed <__intr_restore>
}
c010531e:	c9                   	leave  
c010531f:	c3                   	ret    

c0105320 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0105320:	55                   	push   %ebp
c0105321:	89 e5                	mov    %esp,%ebp
c0105323:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0105326:	e8 98 fd ff ff       	call   c01050c3 <__intr_save>
c010532b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010532e:	a1 dc 10 1a c0       	mov    0xc01a10dc,%eax
c0105333:	8b 40 14             	mov    0x14(%eax),%eax
c0105336:	ff d0                	call   *%eax
c0105338:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010533b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010533e:	89 04 24             	mov    %eax,(%esp)
c0105341:	e8 a7 fd ff ff       	call   c01050ed <__intr_restore>
    return ret;
c0105346:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0105349:	c9                   	leave  
c010534a:	c3                   	ret    

c010534b <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010534b:	55                   	push   %ebp
c010534c:	89 e5                	mov    %esp,%ebp
c010534e:	57                   	push   %edi
c010534f:	56                   	push   %esi
c0105350:	53                   	push   %ebx
c0105351:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0105357:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010535e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105365:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010536c:	c7 04 24 a3 ce 10 c0 	movl   $0xc010cea3,(%esp)
c0105373:	e8 e7 af ff ff       	call   c010035f <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105378:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010537f:	e9 15 01 00 00       	jmp    c0105499 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105384:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105387:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010538a:	89 d0                	mov    %edx,%eax
c010538c:	c1 e0 02             	shl    $0x2,%eax
c010538f:	01 d0                	add    %edx,%eax
c0105391:	c1 e0 02             	shl    $0x2,%eax
c0105394:	01 c8                	add    %ecx,%eax
c0105396:	8b 50 08             	mov    0x8(%eax),%edx
c0105399:	8b 40 04             	mov    0x4(%eax),%eax
c010539c:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010539f:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01053a2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053a8:	89 d0                	mov    %edx,%eax
c01053aa:	c1 e0 02             	shl    $0x2,%eax
c01053ad:	01 d0                	add    %edx,%eax
c01053af:	c1 e0 02             	shl    $0x2,%eax
c01053b2:	01 c8                	add    %ecx,%eax
c01053b4:	8b 48 0c             	mov    0xc(%eax),%ecx
c01053b7:	8b 58 10             	mov    0x10(%eax),%ebx
c01053ba:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01053bd:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01053c0:	01 c8                	add    %ecx,%eax
c01053c2:	11 da                	adc    %ebx,%edx
c01053c4:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01053c7:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01053ca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053d0:	89 d0                	mov    %edx,%eax
c01053d2:	c1 e0 02             	shl    $0x2,%eax
c01053d5:	01 d0                	add    %edx,%eax
c01053d7:	c1 e0 02             	shl    $0x2,%eax
c01053da:	01 c8                	add    %ecx,%eax
c01053dc:	83 c0 14             	add    $0x14,%eax
c01053df:	8b 00                	mov    (%eax),%eax
c01053e1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01053e7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01053ea:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01053ed:	83 c0 ff             	add    $0xffffffff,%eax
c01053f0:	83 d2 ff             	adc    $0xffffffff,%edx
c01053f3:	89 c6                	mov    %eax,%esi
c01053f5:	89 d7                	mov    %edx,%edi
c01053f7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053fd:	89 d0                	mov    %edx,%eax
c01053ff:	c1 e0 02             	shl    $0x2,%eax
c0105402:	01 d0                	add    %edx,%eax
c0105404:	c1 e0 02             	shl    $0x2,%eax
c0105407:	01 c8                	add    %ecx,%eax
c0105409:	8b 48 0c             	mov    0xc(%eax),%ecx
c010540c:	8b 58 10             	mov    0x10(%eax),%ebx
c010540f:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0105415:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0105419:	89 74 24 14          	mov    %esi,0x14(%esp)
c010541d:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0105421:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105424:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105427:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010542b:	89 54 24 10          	mov    %edx,0x10(%esp)
c010542f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105433:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0105437:	c7 04 24 b0 ce 10 c0 	movl   $0xc010ceb0,(%esp)
c010543e:	e8 1c af ff ff       	call   c010035f <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0105443:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105446:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105449:	89 d0                	mov    %edx,%eax
c010544b:	c1 e0 02             	shl    $0x2,%eax
c010544e:	01 d0                	add    %edx,%eax
c0105450:	c1 e0 02             	shl    $0x2,%eax
c0105453:	01 c8                	add    %ecx,%eax
c0105455:	83 c0 14             	add    $0x14,%eax
c0105458:	8b 00                	mov    (%eax),%eax
c010545a:	83 f8 01             	cmp    $0x1,%eax
c010545d:	75 36                	jne    c0105495 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c010545f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105462:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105465:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0105468:	77 2b                	ja     c0105495 <page_init+0x14a>
c010546a:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010546d:	72 05                	jb     c0105474 <page_init+0x129>
c010546f:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0105472:	73 21                	jae    c0105495 <page_init+0x14a>
c0105474:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105478:	77 1b                	ja     c0105495 <page_init+0x14a>
c010547a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010547e:	72 09                	jb     c0105489 <page_init+0x13e>
c0105480:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0105487:	77 0c                	ja     c0105495 <page_init+0x14a>
                maxpa = end;
c0105489:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010548c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010548f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105492:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105495:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0105499:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010549c:	8b 00                	mov    (%eax),%eax
c010549e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01054a1:	0f 8f dd fe ff ff    	jg     c0105384 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01054a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01054ab:	72 1d                	jb     c01054ca <page_init+0x17f>
c01054ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01054b1:	77 09                	ja     c01054bc <page_init+0x171>
c01054b3:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01054ba:	76 0e                	jbe    c01054ca <page_init+0x17f>
        maxpa = KMEMSIZE;
c01054bc:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01054c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01054ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01054d0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01054d4:	c1 ea 0c             	shr    $0xc,%edx
c01054d7:	a3 a0 ef 19 c0       	mov    %eax,0xc019efa0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01054dc:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01054e3:	b8 d8 11 1a c0       	mov    $0xc01a11d8,%eax
c01054e8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01054eb:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01054ee:	01 d0                	add    %edx,%eax
c01054f0:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01054f3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01054f6:	ba 00 00 00 00       	mov    $0x0,%edx
c01054fb:	f7 75 ac             	divl   -0x54(%ebp)
c01054fe:	89 d0                	mov    %edx,%eax
c0105500:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105503:	29 c2                	sub    %eax,%edx
c0105505:	89 d0                	mov    %edx,%eax
c0105507:	a3 e4 10 1a c0       	mov    %eax,0xc01a10e4

    for (i = 0; i < npage; i ++) {
c010550c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105513:	eb 27                	jmp    c010553c <page_init+0x1f1>
        SetPageReserved(pages + i);
c0105515:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c010551a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010551d:	c1 e2 05             	shl    $0x5,%edx
c0105520:	01 d0                	add    %edx,%eax
c0105522:	83 c0 04             	add    $0x4,%eax
c0105525:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c010552c:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010552f:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105532:	8b 55 90             	mov    -0x70(%ebp),%edx
c0105535:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0105538:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010553c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010553f:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0105544:	39 c2                	cmp    %eax,%edx
c0105546:	72 cd                	jb     c0105515 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0105548:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c010554d:	c1 e0 05             	shl    $0x5,%eax
c0105550:	89 c2                	mov    %eax,%edx
c0105552:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0105557:	01 d0                	add    %edx,%eax
c0105559:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010555c:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0105563:	77 23                	ja     c0105588 <page_init+0x23d>
c0105565:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105568:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010556c:	c7 44 24 08 e0 ce 10 	movl   $0xc010cee0,0x8(%esp)
c0105573:	c0 
c0105574:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c010557b:	00 
c010557c:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105583:	e8 63 b8 ff ff       	call   c0100deb <__panic>
c0105588:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010558b:	05 00 00 00 40       	add    $0x40000000,%eax
c0105590:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0105593:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010559a:	e9 74 01 00 00       	jmp    c0105713 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010559f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01055a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055a5:	89 d0                	mov    %edx,%eax
c01055a7:	c1 e0 02             	shl    $0x2,%eax
c01055aa:	01 d0                	add    %edx,%eax
c01055ac:	c1 e0 02             	shl    $0x2,%eax
c01055af:	01 c8                	add    %ecx,%eax
c01055b1:	8b 50 08             	mov    0x8(%eax),%edx
c01055b4:	8b 40 04             	mov    0x4(%eax),%eax
c01055b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01055ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01055bd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01055c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055c3:	89 d0                	mov    %edx,%eax
c01055c5:	c1 e0 02             	shl    $0x2,%eax
c01055c8:	01 d0                	add    %edx,%eax
c01055ca:	c1 e0 02             	shl    $0x2,%eax
c01055cd:	01 c8                	add    %ecx,%eax
c01055cf:	8b 48 0c             	mov    0xc(%eax),%ecx
c01055d2:	8b 58 10             	mov    0x10(%eax),%ebx
c01055d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01055d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01055db:	01 c8                	add    %ecx,%eax
c01055dd:	11 da                	adc    %ebx,%edx
c01055df:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01055e2:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01055e5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01055e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055eb:	89 d0                	mov    %edx,%eax
c01055ed:	c1 e0 02             	shl    $0x2,%eax
c01055f0:	01 d0                	add    %edx,%eax
c01055f2:	c1 e0 02             	shl    $0x2,%eax
c01055f5:	01 c8                	add    %ecx,%eax
c01055f7:	83 c0 14             	add    $0x14,%eax
c01055fa:	8b 00                	mov    (%eax),%eax
c01055fc:	83 f8 01             	cmp    $0x1,%eax
c01055ff:	0f 85 0a 01 00 00    	jne    c010570f <page_init+0x3c4>
            if (begin < freemem) {
c0105605:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105608:	ba 00 00 00 00       	mov    $0x0,%edx
c010560d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105610:	72 17                	jb     c0105629 <page_init+0x2de>
c0105612:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105615:	77 05                	ja     c010561c <page_init+0x2d1>
c0105617:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010561a:	76 0d                	jbe    c0105629 <page_init+0x2de>
                begin = freemem;
c010561c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010561f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105622:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0105629:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010562d:	72 1d                	jb     c010564c <page_init+0x301>
c010562f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105633:	77 09                	ja     c010563e <page_init+0x2f3>
c0105635:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c010563c:	76 0e                	jbe    c010564c <page_init+0x301>
                end = KMEMSIZE;
c010563e:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0105645:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010564c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010564f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105652:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105655:	0f 87 b4 00 00 00    	ja     c010570f <page_init+0x3c4>
c010565b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010565e:	72 09                	jb     c0105669 <page_init+0x31e>
c0105660:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105663:	0f 83 a6 00 00 00    	jae    c010570f <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0105669:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0105670:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105673:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105676:	01 d0                	add    %edx,%eax
c0105678:	83 e8 01             	sub    $0x1,%eax
c010567b:	89 45 98             	mov    %eax,-0x68(%ebp)
c010567e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105681:	ba 00 00 00 00       	mov    $0x0,%edx
c0105686:	f7 75 9c             	divl   -0x64(%ebp)
c0105689:	89 d0                	mov    %edx,%eax
c010568b:	8b 55 98             	mov    -0x68(%ebp),%edx
c010568e:	29 c2                	sub    %eax,%edx
c0105690:	89 d0                	mov    %edx,%eax
c0105692:	ba 00 00 00 00       	mov    $0x0,%edx
c0105697:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010569a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010569d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01056a0:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01056a3:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01056a6:	ba 00 00 00 00       	mov    $0x0,%edx
c01056ab:	89 c7                	mov    %eax,%edi
c01056ad:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01056b3:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01056b6:	89 d0                	mov    %edx,%eax
c01056b8:	83 e0 00             	and    $0x0,%eax
c01056bb:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01056be:	8b 45 80             	mov    -0x80(%ebp),%eax
c01056c1:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01056c4:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01056c7:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01056ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01056cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01056d0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01056d3:	77 3a                	ja     c010570f <page_init+0x3c4>
c01056d5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01056d8:	72 05                	jb     c01056df <page_init+0x394>
c01056da:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01056dd:	73 30                	jae    c010570f <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01056df:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01056e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01056e5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01056e8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01056eb:	29 c8                	sub    %ecx,%eax
c01056ed:	19 da                	sbb    %ebx,%edx
c01056ef:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01056f3:	c1 ea 0c             	shr    $0xc,%edx
c01056f6:	89 c3                	mov    %eax,%ebx
c01056f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01056fb:	89 04 24             	mov    %eax,(%esp)
c01056fe:	e8 8c f8 ff ff       	call   c0104f8f <pa2page>
c0105703:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0105707:	89 04 24             	mov    %eax,(%esp)
c010570a:	e8 55 fb ff ff       	call   c0105264 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c010570f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0105713:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105716:	8b 00                	mov    (%eax),%eax
c0105718:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010571b:	0f 8f 7e fe ff ff    	jg     c010559f <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0105721:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0105727:	5b                   	pop    %ebx
c0105728:	5e                   	pop    %esi
c0105729:	5f                   	pop    %edi
c010572a:	5d                   	pop    %ebp
c010572b:	c3                   	ret    

c010572c <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010572c:	55                   	push   %ebp
c010572d:	89 e5                	mov    %esp,%ebp
c010572f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0105732:	8b 45 14             	mov    0x14(%ebp),%eax
c0105735:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105738:	31 d0                	xor    %edx,%eax
c010573a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010573f:	85 c0                	test   %eax,%eax
c0105741:	74 24                	je     c0105767 <boot_map_segment+0x3b>
c0105743:	c7 44 24 0c 12 cf 10 	movl   $0xc010cf12,0xc(%esp)
c010574a:	c0 
c010574b:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105752:	c0 
c0105753:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c010575a:	00 
c010575b:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105762:	e8 84 b6 ff ff       	call   c0100deb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0105767:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010576e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105771:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105776:	89 c2                	mov    %eax,%edx
c0105778:	8b 45 10             	mov    0x10(%ebp),%eax
c010577b:	01 c2                	add    %eax,%edx
c010577d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105780:	01 d0                	add    %edx,%eax
c0105782:	83 e8 01             	sub    $0x1,%eax
c0105785:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105788:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010578b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105790:	f7 75 f0             	divl   -0x10(%ebp)
c0105793:	89 d0                	mov    %edx,%eax
c0105795:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105798:	29 c2                	sub    %eax,%edx
c010579a:	89 d0                	mov    %edx,%eax
c010579c:	c1 e8 0c             	shr    $0xc,%eax
c010579f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01057a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01057b0:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01057b3:	8b 45 14             	mov    0x14(%ebp),%eax
c01057b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01057b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01057c1:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01057c4:	eb 6b                	jmp    c0105831 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01057c6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01057cd:	00 
c01057ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d8:	89 04 24             	mov    %eax,(%esp)
c01057db:	e8 87 01 00 00       	call   c0105967 <get_pte>
c01057e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01057e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01057e7:	75 24                	jne    c010580d <boot_map_segment+0xe1>
c01057e9:	c7 44 24 0c 3e cf 10 	movl   $0xc010cf3e,0xc(%esp)
c01057f0:	c0 
c01057f1:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01057f8:	c0 
c01057f9:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0105800:	00 
c0105801:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105808:	e8 de b5 ff ff       	call   c0100deb <__panic>
        *ptep = pa | PTE_P | perm;
c010580d:	8b 45 18             	mov    0x18(%ebp),%eax
c0105810:	8b 55 14             	mov    0x14(%ebp),%edx
c0105813:	09 d0                	or     %edx,%eax
c0105815:	83 c8 01             	or     $0x1,%eax
c0105818:	89 c2                	mov    %eax,%edx
c010581a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010581d:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010581f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105823:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010582a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0105831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105835:	75 8f                	jne    c01057c6 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0105837:	c9                   	leave  
c0105838:	c3                   	ret    

c0105839 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0105839:	55                   	push   %ebp
c010583a:	89 e5                	mov    %esp,%ebp
c010583c:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010583f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105846:	e8 38 fa ff ff       	call   c0105283 <alloc_pages>
c010584b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010584e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105852:	75 1c                	jne    c0105870 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105854:	c7 44 24 08 4b cf 10 	movl   $0xc010cf4b,0x8(%esp)
c010585b:	c0 
c010585c:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105863:	00 
c0105864:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010586b:	e8 7b b5 ff ff       	call   c0100deb <__panic>
    }
    return page2kva(p);
c0105870:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105873:	89 04 24             	mov    %eax,(%esp)
c0105876:	e8 59 f7 ff ff       	call   c0104fd4 <page2kva>
}
c010587b:	c9                   	leave  
c010587c:	c3                   	ret    

c010587d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010587d:	55                   	push   %ebp
c010587e:	89 e5                	mov    %esp,%ebp
c0105880:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0105883:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0105888:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010588b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105892:	77 23                	ja     c01058b7 <pmm_init+0x3a>
c0105894:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105897:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010589b:	c7 44 24 08 e0 ce 10 	movl   $0xc010cee0,0x8(%esp)
c01058a2:	c0 
c01058a3:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01058aa:	00 
c01058ab:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01058b2:	e8 34 b5 ff ff       	call   c0100deb <__panic>
c01058b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058ba:	05 00 00 00 40       	add    $0x40000000,%eax
c01058bf:	a3 e0 10 1a c0       	mov    %eax,0xc01a10e0
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01058c4:	e8 68 f9 ff ff       	call   c0105231 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01058c9:	e8 7d fa ff ff       	call   c010534b <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01058ce:	e8 d2 08 00 00       	call   c01061a5 <check_alloc_page>

    check_pgdir();
c01058d3:	e8 eb 08 00 00       	call   c01061c3 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01058d8:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01058dd:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01058e3:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01058e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058eb:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01058f2:	77 23                	ja     c0105917 <pmm_init+0x9a>
c01058f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058fb:	c7 44 24 08 e0 ce 10 	movl   $0xc010cee0,0x8(%esp)
c0105902:	c0 
c0105903:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c010590a:	00 
c010590b:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105912:	e8 d4 b4 ff ff       	call   c0100deb <__panic>
c0105917:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010591a:	05 00 00 00 40       	add    $0x40000000,%eax
c010591f:	83 c8 03             	or     $0x3,%eax
c0105922:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105924:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0105929:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105930:	00 
c0105931:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105938:	00 
c0105939:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105940:	38 
c0105941:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0105948:	c0 
c0105949:	89 04 24             	mov    %eax,(%esp)
c010594c:	e8 db fd ff ff       	call   c010572c <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105951:	e8 ec f7 ff ff       	call   c0105142 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0105956:	e8 03 0f 00 00       	call   c010685e <check_boot_pgdir>

    print_pgdir();
c010595b:	e8 8b 13 00 00       	call   c0106ceb <print_pgdir>
    
    kmalloc_init();
c0105960:	e8 69 f3 ff ff       	call   c0104cce <kmalloc_init>

}
c0105965:	c9                   	leave  
c0105966:	c3                   	ret    

c0105967 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0105967:	55                   	push   %ebp
c0105968:	89 e5                	mov    %esp,%ebp
c010596a:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c010596d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105970:	c1 e8 16             	shr    $0x16,%eax
c0105973:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010597a:	8b 45 08             	mov    0x8(%ebp),%eax
c010597d:	01 d0                	add    %edx,%eax
c010597f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0105982:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105985:	8b 00                	mov    (%eax),%eax
c0105987:	83 e0 01             	and    $0x1,%eax
c010598a:	85 c0                	test   %eax,%eax
c010598c:	0f 85 af 00 00 00    	jne    c0105a41 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0105992:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105996:	74 15                	je     c01059ad <get_pte+0x46>
c0105998:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010599f:	e8 df f8 ff ff       	call   c0105283 <alloc_pages>
c01059a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01059ab:	75 0a                	jne    c01059b7 <get_pte+0x50>
            return NULL;
c01059ad:	b8 00 00 00 00       	mov    $0x0,%eax
c01059b2:	e9 e6 00 00 00       	jmp    c0105a9d <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01059b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01059be:	00 
c01059bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059c2:	89 04 24             	mov    %eax,(%esp)
c01059c5:	e8 be f6 ff ff       	call   c0105088 <set_page_ref>
        uintptr_t pa = page2pa(page);
c01059ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059cd:	89 04 24             	mov    %eax,(%esp)
c01059d0:	e8 a4 f5 ff ff       	call   c0104f79 <page2pa>
c01059d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01059d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01059de:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059e1:	c1 e8 0c             	shr    $0xc,%eax
c01059e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01059e7:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01059ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01059ef:	72 23                	jb     c0105a14 <get_pte+0xad>
c01059f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059f8:	c7 44 24 08 3c ce 10 	movl   $0xc010ce3c,0x8(%esp)
c01059ff:	c0 
c0105a00:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0105a07:	00 
c0105a08:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105a0f:	e8 d7 b3 ff ff       	call   c0100deb <__panic>
c0105a14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a17:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105a1c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105a23:	00 
c0105a24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105a2b:	00 
c0105a2c:	89 04 24             	mov    %eax,(%esp)
c0105a2f:	e8 25 64 00 00       	call   c010be59 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0105a34:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a37:	83 c8 07             	or     $0x7,%eax
c0105a3a:	89 c2                	mov    %eax,%edx
c0105a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a3f:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0105a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a44:	8b 00                	mov    (%eax),%eax
c0105a46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105a4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a51:	c1 e8 0c             	shr    $0xc,%eax
c0105a54:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105a57:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0105a5c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105a5f:	72 23                	jb     c0105a84 <get_pte+0x11d>
c0105a61:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a64:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a68:	c7 44 24 08 3c ce 10 	movl   $0xc010ce3c,0x8(%esp)
c0105a6f:	c0 
c0105a70:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c0105a77:	00 
c0105a78:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105a7f:	e8 67 b3 ff ff       	call   c0100deb <__panic>
c0105a84:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a87:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a8f:	c1 ea 0c             	shr    $0xc,%edx
c0105a92:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0105a98:	c1 e2 02             	shl    $0x2,%edx
c0105a9b:	01 d0                	add    %edx,%eax
}
c0105a9d:	c9                   	leave  
c0105a9e:	c3                   	ret    

c0105a9f <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105a9f:	55                   	push   %ebp
c0105aa0:	89 e5                	mov    %esp,%ebp
c0105aa2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105aa5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105aac:	00 
c0105aad:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ab7:	89 04 24             	mov    %eax,(%esp)
c0105aba:	e8 a8 fe ff ff       	call   c0105967 <get_pte>
c0105abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0105ac2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105ac6:	74 08                	je     c0105ad0 <get_page+0x31>
        *ptep_store = ptep;
c0105ac8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ace:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105ad0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ad4:	74 1b                	je     c0105af1 <get_page+0x52>
c0105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ad9:	8b 00                	mov    (%eax),%eax
c0105adb:	83 e0 01             	and    $0x1,%eax
c0105ade:	85 c0                	test   %eax,%eax
c0105ae0:	74 0f                	je     c0105af1 <get_page+0x52>
        return pte2page(*ptep);
c0105ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ae5:	8b 00                	mov    (%eax),%eax
c0105ae7:	89 04 24             	mov    %eax,(%esp)
c0105aea:	e8 39 f5 ff ff       	call   c0105028 <pte2page>
c0105aef:	eb 05                	jmp    c0105af6 <get_page+0x57>
    }
    return NULL;
c0105af1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105af6:	c9                   	leave  
c0105af7:	c3                   	ret    

c0105af8 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105af8:	55                   	push   %ebp
c0105af9:	89 e5                	mov    %esp,%ebp
c0105afb:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0105afe:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b01:	8b 00                	mov    (%eax),%eax
c0105b03:	83 e0 01             	and    $0x1,%eax
c0105b06:	85 c0                	test   %eax,%eax
c0105b08:	74 4d                	je     c0105b57 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0105b0a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b0d:	8b 00                	mov    (%eax),%eax
c0105b0f:	89 04 24             	mov    %eax,(%esp)
c0105b12:	e8 11 f5 ff ff       	call   c0105028 <pte2page>
c0105b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0105b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b1d:	89 04 24             	mov    %eax,(%esp)
c0105b20:	e8 87 f5 ff ff       	call   c01050ac <page_ref_dec>
c0105b25:	85 c0                	test   %eax,%eax
c0105b27:	75 13                	jne    c0105b3c <page_remove_pte+0x44>
            free_page(page);
c0105b29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b30:	00 
c0105b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b34:	89 04 24             	mov    %eax,(%esp)
c0105b37:	e8 b2 f7 ff ff       	call   c01052ee <free_pages>
        }
        *ptep = 0;
c0105b3c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0105b45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b4f:	89 04 24             	mov    %eax,(%esp)
c0105b52:	e8 1d 05 00 00       	call   c0106074 <tlb_invalidate>
    }
}
c0105b57:	c9                   	leave  
c0105b58:	c3                   	ret    

c0105b59 <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105b59:	55                   	push   %ebp
c0105b5a:	89 e5                	mov    %esp,%ebp
c0105b5c:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b62:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b67:	85 c0                	test   %eax,%eax
c0105b69:	75 0c                	jne    c0105b77 <unmap_range+0x1e>
c0105b6b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b6e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b73:	85 c0                	test   %eax,%eax
c0105b75:	74 24                	je     c0105b9b <unmap_range+0x42>
c0105b77:	c7 44 24 0c 64 cf 10 	movl   $0xc010cf64,0xc(%esp)
c0105b7e:	c0 
c0105b7f:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105b86:	c0 
c0105b87:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
c0105b8e:	00 
c0105b8f:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105b96:	e8 50 b2 ff ff       	call   c0100deb <__panic>
    assert(USER_ACCESS(start, end));
c0105b9b:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105ba2:	76 11                	jbe    c0105bb5 <unmap_range+0x5c>
c0105ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ba7:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105baa:	73 09                	jae    c0105bb5 <unmap_range+0x5c>
c0105bac:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105bb3:	76 24                	jbe    c0105bd9 <unmap_range+0x80>
c0105bb5:	c7 44 24 0c 8d cf 10 	movl   $0xc010cf8d,0xc(%esp)
c0105bbc:	c0 
c0105bbd:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105bc4:	c0 
c0105bc5:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
c0105bcc:	00 
c0105bcd:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105bd4:	e8 12 b2 ff ff       	call   c0100deb <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0105bd9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105be0:	00 
c0105be1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105be4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105be8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105beb:	89 04 24             	mov    %eax,(%esp)
c0105bee:	e8 74 fd ff ff       	call   c0105967 <get_pte>
c0105bf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105bf6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105bfa:	75 18                	jne    c0105c14 <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bff:	05 00 00 40 00       	add    $0x400000,%eax
c0105c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c0a:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105c0f:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0105c12:	eb 29                	jmp    c0105c3d <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c17:	8b 00                	mov    (%eax),%eax
c0105c19:	85 c0                	test   %eax,%eax
c0105c1b:	74 19                	je     c0105c36 <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0105c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c20:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c24:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2e:	89 04 24             	mov    %eax,(%esp)
c0105c31:	e8 c2 fe ff ff       	call   c0105af8 <page_remove_pte>
        }
        start += PGSIZE;
c0105c36:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105c3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c41:	74 08                	je     c0105c4b <unmap_range+0xf2>
c0105c43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c46:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c49:	72 8e                	jb     c0105bd9 <unmap_range+0x80>
}
c0105c4b:	c9                   	leave  
c0105c4c:	c3                   	ret    

c0105c4d <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105c4d:	55                   	push   %ebp
c0105c4e:	89 e5                	mov    %esp,%ebp
c0105c50:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105c53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c56:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c5b:	85 c0                	test   %eax,%eax
c0105c5d:	75 0c                	jne    c0105c6b <exit_range+0x1e>
c0105c5f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c62:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c67:	85 c0                	test   %eax,%eax
c0105c69:	74 24                	je     c0105c8f <exit_range+0x42>
c0105c6b:	c7 44 24 0c 64 cf 10 	movl   $0xc010cf64,0xc(%esp)
c0105c72:	c0 
c0105c73:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105c7a:	c0 
c0105c7b:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0105c82:	00 
c0105c83:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105c8a:	e8 5c b1 ff ff       	call   c0100deb <__panic>
    assert(USER_ACCESS(start, end));
c0105c8f:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105c96:	76 11                	jbe    c0105ca9 <exit_range+0x5c>
c0105c98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c9b:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c9e:	73 09                	jae    c0105ca9 <exit_range+0x5c>
c0105ca0:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105ca7:	76 24                	jbe    c0105ccd <exit_range+0x80>
c0105ca9:	c7 44 24 0c 8d cf 10 	movl   $0xc010cf8d,0xc(%esp)
c0105cb0:	c0 
c0105cb1:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105cb8:	c0 
c0105cb9:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0105cc0:	00 
c0105cc1:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105cc8:	e8 1e b1 ff ff       	call   c0100deb <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0105ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cd6:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105cdb:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0105cde:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ce1:	c1 e8 16             	shr    $0x16,%eax
c0105ce4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105cf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf4:	01 d0                	add    %edx,%eax
c0105cf6:	8b 00                	mov    (%eax),%eax
c0105cf8:	83 e0 01             	and    $0x1,%eax
c0105cfb:	85 c0                	test   %eax,%eax
c0105cfd:	74 3e                	je     c0105d3d <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0105cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d09:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d0c:	01 d0                	add    %edx,%eax
c0105d0e:	8b 00                	mov    (%eax),%eax
c0105d10:	89 04 24             	mov    %eax,(%esp)
c0105d13:	e8 4e f3 ff ff       	call   c0105066 <pde2page>
c0105d18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105d1f:	00 
c0105d20:	89 04 24             	mov    %eax,(%esp)
c0105d23:	e8 c6 f5 ff ff       	call   c01052ee <free_pages>
            pgdir[pde_idx] = 0;
c0105d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d35:	01 d0                	add    %edx,%eax
c0105d37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0105d3d:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105d44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105d48:	74 08                	je     c0105d52 <exit_range+0x105>
c0105d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d4d:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105d50:	72 8c                	jb     c0105cde <exit_range+0x91>
}
c0105d52:	c9                   	leave  
c0105d53:	c3                   	ret    

c0105d54 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105d54:	55                   	push   %ebp
c0105d55:	89 e5                	mov    %esp,%ebp
c0105d57:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105d5a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d5d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d62:	85 c0                	test   %eax,%eax
c0105d64:	75 0c                	jne    c0105d72 <copy_range+0x1e>
c0105d66:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d69:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d6e:	85 c0                	test   %eax,%eax
c0105d70:	74 24                	je     c0105d96 <copy_range+0x42>
c0105d72:	c7 44 24 0c 64 cf 10 	movl   $0xc010cf64,0xc(%esp)
c0105d79:	c0 
c0105d7a:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105d81:	c0 
c0105d82:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0105d89:	00 
c0105d8a:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105d91:	e8 55 b0 ff ff       	call   c0100deb <__panic>
    assert(USER_ACCESS(start, end));
c0105d96:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0105d9d:	76 11                	jbe    c0105db0 <copy_range+0x5c>
c0105d9f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105da2:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105da5:	73 09                	jae    c0105db0 <copy_range+0x5c>
c0105da7:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0105dae:	76 24                	jbe    c0105dd4 <copy_range+0x80>
c0105db0:	c7 44 24 0c 8d cf 10 	movl   $0xc010cf8d,0xc(%esp)
c0105db7:	c0 
c0105db8:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105dbf:	c0 
c0105dc0:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0105dc7:	00 
c0105dc8:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105dcf:	e8 17 b0 ff ff       	call   c0100deb <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0105dd4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105ddb:	00 
c0105ddc:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105de3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105de6:	89 04 24             	mov    %eax,(%esp)
c0105de9:	e8 79 fb ff ff       	call   c0105967 <get_pte>
c0105dee:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105df1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105df5:	75 1b                	jne    c0105e12 <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105df7:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dfa:	05 00 00 40 00       	add    $0x400000,%eax
c0105dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e05:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105e0a:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0105e0d:	e9 4c 01 00 00       	jmp    c0105f5e <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e15:	8b 00                	mov    (%eax),%eax
c0105e17:	83 e0 01             	and    $0x1,%eax
c0105e1a:	85 c0                	test   %eax,%eax
c0105e1c:	0f 84 35 01 00 00    	je     c0105f57 <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105e22:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105e29:	00 
c0105e2a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e31:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e34:	89 04 24             	mov    %eax,(%esp)
c0105e37:	e8 2b fb ff ff       	call   c0105967 <get_pte>
c0105e3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e3f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105e43:	75 0a                	jne    c0105e4f <copy_range+0xfb>
                return -E_NO_MEM;
c0105e45:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105e4a:	e9 26 01 00 00       	jmp    c0105f75 <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c0105e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e52:	8b 00                	mov    (%eax),%eax
c0105e54:	83 e0 07             	and    $0x7,%eax
c0105e57:	89 45 e8             	mov    %eax,-0x18(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c0105e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e5d:	8b 00                	mov    (%eax),%eax
c0105e5f:	89 04 24             	mov    %eax,(%esp)
c0105e62:	e8 c1 f1 ff ff       	call   c0105028 <pte2page>
c0105e67:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c0105e6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e71:	e8 0d f4 ff ff       	call   c0105283 <alloc_pages>
c0105e76:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(page!=NULL);
c0105e79:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e7d:	75 24                	jne    c0105ea3 <copy_range+0x14f>
c0105e7f:	c7 44 24 0c a5 cf 10 	movl   $0xc010cfa5,0xc(%esp)
c0105e86:	c0 
c0105e87:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105e8e:	c0 
c0105e8f:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0105e96:	00 
c0105e97:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105e9e:	e8 48 af ff ff       	call   c0100deb <__panic>
        assert(npage!=NULL);
c0105ea3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105ea7:	75 24                	jne    c0105ecd <copy_range+0x179>
c0105ea9:	c7 44 24 0c b0 cf 10 	movl   $0xc010cfb0,0xc(%esp)
c0105eb0:	c0 
c0105eb1:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105eb8:	c0 
c0105eb9:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0105ec0:	00 
c0105ec1:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105ec8:	e8 1e af ff ff       	call   c0100deb <__panic>
        int ret=0;
c0105ecd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        void * kva_src = page2kva(page);
c0105ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ed7:	89 04 24             	mov    %eax,(%esp)
c0105eda:	e8 f5 f0 ff ff       	call   c0104fd4 <page2kva>
c0105edf:	89 45 d8             	mov    %eax,-0x28(%ebp)
        void * kva_dst = page2kva(npage);
c0105ee2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ee5:	89 04 24             	mov    %eax,(%esp)
c0105ee8:	e8 e7 f0 ff ff       	call   c0104fd4 <page2kva>
c0105eed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    
        memcpy(kva_dst, kva_src, PGSIZE);
c0105ef0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105ef7:	00 
c0105ef8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105efb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105f02:	89 04 24             	mov    %eax,(%esp)
c0105f05:	e8 31 60 00 00       	call   c010bf3b <memcpy>

        ret = page_insert(to, npage, start, perm);
c0105f0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f11:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f14:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f18:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f22:	89 04 24             	mov    %eax,(%esp)
c0105f25:	e8 91 00 00 00       	call   c0105fbb <page_insert>
c0105f2a:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ret == 0);
c0105f2d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105f31:	74 24                	je     c0105f57 <copy_range+0x203>
c0105f33:	c7 44 24 0c bc cf 10 	movl   $0xc010cfbc,0xc(%esp)
c0105f3a:	c0 
c0105f3b:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0105f42:	c0 
c0105f43:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105f4a:	00 
c0105f4b:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0105f52:	e8 94 ae ff ff       	call   c0100deb <__panic>
        }
        start += PGSIZE;
c0105f57:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105f5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105f62:	74 0c                	je     c0105f70 <copy_range+0x21c>
c0105f64:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f67:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105f6a:	0f 82 64 fe ff ff    	jb     c0105dd4 <copy_range+0x80>
    return 0;
c0105f70:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f75:	c9                   	leave  
c0105f76:	c3                   	ret    

c0105f77 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105f77:	55                   	push   %ebp
c0105f78:	89 e5                	mov    %esp,%ebp
c0105f7a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105f7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105f84:	00 
c0105f85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f8f:	89 04 24             	mov    %eax,(%esp)
c0105f92:	e8 d0 f9 ff ff       	call   c0105967 <get_pte>
c0105f97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105f9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f9e:	74 19                	je     c0105fb9 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fa3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105faa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fae:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fb1:	89 04 24             	mov    %eax,(%esp)
c0105fb4:	e8 3f fb ff ff       	call   c0105af8 <page_remove_pte>
    }
}
c0105fb9:	c9                   	leave  
c0105fba:	c3                   	ret    

c0105fbb <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105fbb:	55                   	push   %ebp
c0105fbc:	89 e5                	mov    %esp,%ebp
c0105fbe:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105fc1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105fc8:	00 
c0105fc9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fd3:	89 04 24             	mov    %eax,(%esp)
c0105fd6:	e8 8c f9 ff ff       	call   c0105967 <get_pte>
c0105fdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105fde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105fe2:	75 0a                	jne    c0105fee <page_insert+0x33>
        return -E_NO_MEM;
c0105fe4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105fe9:	e9 84 00 00 00       	jmp    c0106072 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105fee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ff1:	89 04 24             	mov    %eax,(%esp)
c0105ff4:	e8 9c f0 ff ff       	call   c0105095 <page_ref_inc>
    if (*ptep & PTE_P) {
c0105ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ffc:	8b 00                	mov    (%eax),%eax
c0105ffe:	83 e0 01             	and    $0x1,%eax
c0106001:	85 c0                	test   %eax,%eax
c0106003:	74 3e                	je     c0106043 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0106005:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106008:	8b 00                	mov    (%eax),%eax
c010600a:	89 04 24             	mov    %eax,(%esp)
c010600d:	e8 16 f0 ff ff       	call   c0105028 <pte2page>
c0106012:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106015:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106018:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010601b:	75 0d                	jne    c010602a <page_insert+0x6f>
            page_ref_dec(page);
c010601d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106020:	89 04 24             	mov    %eax,(%esp)
c0106023:	e8 84 f0 ff ff       	call   c01050ac <page_ref_dec>
c0106028:	eb 19                	jmp    c0106043 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010602a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010602d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106031:	8b 45 10             	mov    0x10(%ebp),%eax
c0106034:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106038:	8b 45 08             	mov    0x8(%ebp),%eax
c010603b:	89 04 24             	mov    %eax,(%esp)
c010603e:	e8 b5 fa ff ff       	call   c0105af8 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106043:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106046:	89 04 24             	mov    %eax,(%esp)
c0106049:	e8 2b ef ff ff       	call   c0104f79 <page2pa>
c010604e:	0b 45 14             	or     0x14(%ebp),%eax
c0106051:	83 c8 01             	or     $0x1,%eax
c0106054:	89 c2                	mov    %eax,%edx
c0106056:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106059:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010605b:	8b 45 10             	mov    0x10(%ebp),%eax
c010605e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106062:	8b 45 08             	mov    0x8(%ebp),%eax
c0106065:	89 04 24             	mov    %eax,(%esp)
c0106068:	e8 07 00 00 00       	call   c0106074 <tlb_invalidate>
    return 0;
c010606d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106072:	c9                   	leave  
c0106073:	c3                   	ret    

c0106074 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0106074:	55                   	push   %ebp
c0106075:	89 e5                	mov    %esp,%ebp
c0106077:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010607a:	0f 20 d8             	mov    %cr3,%eax
c010607d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0106080:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0106083:	89 c2                	mov    %eax,%edx
c0106085:	8b 45 08             	mov    0x8(%ebp),%eax
c0106088:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010608b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106092:	77 23                	ja     c01060b7 <tlb_invalidate+0x43>
c0106094:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106097:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010609b:	c7 44 24 08 e0 ce 10 	movl   $0xc010cee0,0x8(%esp)
c01060a2:	c0 
c01060a3:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c01060aa:	00 
c01060ab:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01060b2:	e8 34 ad ff ff       	call   c0100deb <__panic>
c01060b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060ba:	05 00 00 00 40       	add    $0x40000000,%eax
c01060bf:	39 c2                	cmp    %eax,%edx
c01060c1:	75 0c                	jne    c01060cf <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01060c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01060c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060cc:	0f 01 38             	invlpg (%eax)
    }
}
c01060cf:	c9                   	leave  
c01060d0:	c3                   	ret    

c01060d1 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01060d1:	55                   	push   %ebp
c01060d2:	89 e5                	mov    %esp,%ebp
c01060d4:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01060d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01060de:	e8 a0 f1 ff ff       	call   c0105283 <alloc_pages>
c01060e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01060e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01060ea:	0f 84 b0 00 00 00    	je     c01061a0 <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01060f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01060f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060fa:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106101:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106105:	8b 45 08             	mov    0x8(%ebp),%eax
c0106108:	89 04 24             	mov    %eax,(%esp)
c010610b:	e8 ab fe ff ff       	call   c0105fbb <page_insert>
c0106110:	85 c0                	test   %eax,%eax
c0106112:	74 1a                	je     c010612e <pgdir_alloc_page+0x5d>
            free_page(page);
c0106114:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010611b:	00 
c010611c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010611f:	89 04 24             	mov    %eax,(%esp)
c0106122:	e8 c7 f1 ff ff       	call   c01052ee <free_pages>
            return NULL;
c0106127:	b8 00 00 00 00       	mov    $0x0,%eax
c010612c:	eb 75                	jmp    c01061a3 <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c010612e:	a1 2c f0 19 c0       	mov    0xc019f02c,%eax
c0106133:	85 c0                	test   %eax,%eax
c0106135:	74 69                	je     c01061a0 <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c0106137:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c010613c:	85 c0                	test   %eax,%eax
c010613e:	74 60                	je     c01061a0 <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c0106140:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c0106145:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010614c:	00 
c010614d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106150:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106154:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106157:	89 54 24 04          	mov    %edx,0x4(%esp)
c010615b:	89 04 24             	mov    %eax,(%esp)
c010615e:	e8 51 0e 00 00       	call   c0106fb4 <swap_map_swappable>
                page->pra_vaddr=la;
c0106163:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106166:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106169:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c010616c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010616f:	89 04 24             	mov    %eax,(%esp)
c0106172:	e8 07 ef ff ff       	call   c010507e <page_ref>
c0106177:	83 f8 01             	cmp    $0x1,%eax
c010617a:	74 24                	je     c01061a0 <pgdir_alloc_page+0xcf>
c010617c:	c7 44 24 0c c5 cf 10 	movl   $0xc010cfc5,0xc(%esp)
c0106183:	c0 
c0106184:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c010618b:	c0 
c010618c:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
c0106193:	00 
c0106194:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010619b:	e8 4b ac ff ff       	call   c0100deb <__panic>
            }
        }

    }

    return page;
c01061a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01061a3:	c9                   	leave  
c01061a4:	c3                   	ret    

c01061a5 <check_alloc_page>:

static void
check_alloc_page(void) {
c01061a5:	55                   	push   %ebp
c01061a6:	89 e5                	mov    %esp,%ebp
c01061a8:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01061ab:	a1 dc 10 1a c0       	mov    0xc01a10dc,%eax
c01061b0:	8b 40 18             	mov    0x18(%eax),%eax
c01061b3:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01061b5:	c7 04 24 dc cf 10 c0 	movl   $0xc010cfdc,(%esp)
c01061bc:	e8 9e a1 ff ff       	call   c010035f <cprintf>
}
c01061c1:	c9                   	leave  
c01061c2:	c3                   	ret    

c01061c3 <check_pgdir>:

static void
check_pgdir(void) {
c01061c3:	55                   	push   %ebp
c01061c4:	89 e5                	mov    %esp,%ebp
c01061c6:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01061c9:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01061ce:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01061d3:	76 24                	jbe    c01061f9 <check_pgdir+0x36>
c01061d5:	c7 44 24 0c fb cf 10 	movl   $0xc010cffb,0xc(%esp)
c01061dc:	c0 
c01061dd:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01061e4:	c0 
c01061e5:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c01061ec:	00 
c01061ed:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01061f4:	e8 f2 ab ff ff       	call   c0100deb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01061f9:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01061fe:	85 c0                	test   %eax,%eax
c0106200:	74 0e                	je     c0106210 <check_pgdir+0x4d>
c0106202:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106207:	25 ff 0f 00 00       	and    $0xfff,%eax
c010620c:	85 c0                	test   %eax,%eax
c010620e:	74 24                	je     c0106234 <check_pgdir+0x71>
c0106210:	c7 44 24 0c 18 d0 10 	movl   $0xc010d018,0xc(%esp)
c0106217:	c0 
c0106218:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c010621f:	c0 
c0106220:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c0106227:	00 
c0106228:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010622f:	e8 b7 ab ff ff       	call   c0100deb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0106234:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106239:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106240:	00 
c0106241:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106248:	00 
c0106249:	89 04 24             	mov    %eax,(%esp)
c010624c:	e8 4e f8 ff ff       	call   c0105a9f <get_page>
c0106251:	85 c0                	test   %eax,%eax
c0106253:	74 24                	je     c0106279 <check_pgdir+0xb6>
c0106255:	c7 44 24 0c 50 d0 10 	movl   $0xc010d050,0xc(%esp)
c010625c:	c0 
c010625d:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106264:	c0 
c0106265:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c010626c:	00 
c010626d:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106274:	e8 72 ab ff ff       	call   c0100deb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106279:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106280:	e8 fe ef ff ff       	call   c0105283 <alloc_pages>
c0106285:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106288:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c010628d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106294:	00 
c0106295:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010629c:	00 
c010629d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01062a0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062a4:	89 04 24             	mov    %eax,(%esp)
c01062a7:	e8 0f fd ff ff       	call   c0105fbb <page_insert>
c01062ac:	85 c0                	test   %eax,%eax
c01062ae:	74 24                	je     c01062d4 <check_pgdir+0x111>
c01062b0:	c7 44 24 0c 78 d0 10 	movl   $0xc010d078,0xc(%esp)
c01062b7:	c0 
c01062b8:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01062bf:	c0 
c01062c0:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c01062c7:	00 
c01062c8:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01062cf:	e8 17 ab ff ff       	call   c0100deb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01062d4:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01062d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01062e0:	00 
c01062e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01062e8:	00 
c01062e9:	89 04 24             	mov    %eax,(%esp)
c01062ec:	e8 76 f6 ff ff       	call   c0105967 <get_pte>
c01062f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01062f8:	75 24                	jne    c010631e <check_pgdir+0x15b>
c01062fa:	c7 44 24 0c a4 d0 10 	movl   $0xc010d0a4,0xc(%esp)
c0106301:	c0 
c0106302:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106309:	c0 
c010630a:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c0106311:	00 
c0106312:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106319:	e8 cd aa ff ff       	call   c0100deb <__panic>
    assert(pte2page(*ptep) == p1);
c010631e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106321:	8b 00                	mov    (%eax),%eax
c0106323:	89 04 24             	mov    %eax,(%esp)
c0106326:	e8 fd ec ff ff       	call   c0105028 <pte2page>
c010632b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010632e:	74 24                	je     c0106354 <check_pgdir+0x191>
c0106330:	c7 44 24 0c d1 d0 10 	movl   $0xc010d0d1,0xc(%esp)
c0106337:	c0 
c0106338:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c010633f:	c0 
c0106340:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0106347:	00 
c0106348:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010634f:	e8 97 aa ff ff       	call   c0100deb <__panic>
    assert(page_ref(p1) == 1);
c0106354:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106357:	89 04 24             	mov    %eax,(%esp)
c010635a:	e8 1f ed ff ff       	call   c010507e <page_ref>
c010635f:	83 f8 01             	cmp    $0x1,%eax
c0106362:	74 24                	je     c0106388 <check_pgdir+0x1c5>
c0106364:	c7 44 24 0c e7 d0 10 	movl   $0xc010d0e7,0xc(%esp)
c010636b:	c0 
c010636c:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106373:	c0 
c0106374:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
c010637b:	00 
c010637c:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106383:	e8 63 aa ff ff       	call   c0100deb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0106388:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c010638d:	8b 00                	mov    (%eax),%eax
c010638f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106394:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106397:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010639a:	c1 e8 0c             	shr    $0xc,%eax
c010639d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01063a0:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01063a5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01063a8:	72 23                	jb     c01063cd <check_pgdir+0x20a>
c01063aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01063b1:	c7 44 24 08 3c ce 10 	movl   $0xc010ce3c,0x8(%esp)
c01063b8:	c0 
c01063b9:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
c01063c0:	00 
c01063c1:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01063c8:	e8 1e aa ff ff       	call   c0100deb <__panic>
c01063cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063d0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01063d5:	83 c0 04             	add    $0x4,%eax
c01063d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01063db:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01063e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01063e7:	00 
c01063e8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01063ef:	00 
c01063f0:	89 04 24             	mov    %eax,(%esp)
c01063f3:	e8 6f f5 ff ff       	call   c0105967 <get_pte>
c01063f8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01063fb:	74 24                	je     c0106421 <check_pgdir+0x25e>
c01063fd:	c7 44 24 0c fc d0 10 	movl   $0xc010d0fc,0xc(%esp)
c0106404:	c0 
c0106405:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c010640c:	c0 
c010640d:	c7 44 24 04 7d 02 00 	movl   $0x27d,0x4(%esp)
c0106414:	00 
c0106415:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010641c:	e8 ca a9 ff ff       	call   c0100deb <__panic>

    p2 = alloc_page();
c0106421:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106428:	e8 56 ee ff ff       	call   c0105283 <alloc_pages>
c010642d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0106430:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106435:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010643c:	00 
c010643d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106444:	00 
c0106445:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106448:	89 54 24 04          	mov    %edx,0x4(%esp)
c010644c:	89 04 24             	mov    %eax,(%esp)
c010644f:	e8 67 fb ff ff       	call   c0105fbb <page_insert>
c0106454:	85 c0                	test   %eax,%eax
c0106456:	74 24                	je     c010647c <check_pgdir+0x2b9>
c0106458:	c7 44 24 0c 24 d1 10 	movl   $0xc010d124,0xc(%esp)
c010645f:	c0 
c0106460:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106467:	c0 
c0106468:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c010646f:	00 
c0106470:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106477:	e8 6f a9 ff ff       	call   c0100deb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010647c:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106481:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106488:	00 
c0106489:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106490:	00 
c0106491:	89 04 24             	mov    %eax,(%esp)
c0106494:	e8 ce f4 ff ff       	call   c0105967 <get_pte>
c0106499:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010649c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01064a0:	75 24                	jne    c01064c6 <check_pgdir+0x303>
c01064a2:	c7 44 24 0c 5c d1 10 	movl   $0xc010d15c,0xc(%esp)
c01064a9:	c0 
c01064aa:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01064b1:	c0 
c01064b2:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c01064b9:	00 
c01064ba:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01064c1:	e8 25 a9 ff ff       	call   c0100deb <__panic>
    assert(*ptep & PTE_U);
c01064c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064c9:	8b 00                	mov    (%eax),%eax
c01064cb:	83 e0 04             	and    $0x4,%eax
c01064ce:	85 c0                	test   %eax,%eax
c01064d0:	75 24                	jne    c01064f6 <check_pgdir+0x333>
c01064d2:	c7 44 24 0c 8c d1 10 	movl   $0xc010d18c,0xc(%esp)
c01064d9:	c0 
c01064da:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01064e1:	c0 
c01064e2:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c01064e9:	00 
c01064ea:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01064f1:	e8 f5 a8 ff ff       	call   c0100deb <__panic>
    assert(*ptep & PTE_W);
c01064f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064f9:	8b 00                	mov    (%eax),%eax
c01064fb:	83 e0 02             	and    $0x2,%eax
c01064fe:	85 c0                	test   %eax,%eax
c0106500:	75 24                	jne    c0106526 <check_pgdir+0x363>
c0106502:	c7 44 24 0c 9a d1 10 	movl   $0xc010d19a,0xc(%esp)
c0106509:	c0 
c010650a:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106511:	c0 
c0106512:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
c0106519:	00 
c010651a:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106521:	e8 c5 a8 ff ff       	call   c0100deb <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0106526:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c010652b:	8b 00                	mov    (%eax),%eax
c010652d:	83 e0 04             	and    $0x4,%eax
c0106530:	85 c0                	test   %eax,%eax
c0106532:	75 24                	jne    c0106558 <check_pgdir+0x395>
c0106534:	c7 44 24 0c a8 d1 10 	movl   $0xc010d1a8,0xc(%esp)
c010653b:	c0 
c010653c:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106543:	c0 
c0106544:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
c010654b:	00 
c010654c:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106553:	e8 93 a8 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 1);
c0106558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010655b:	89 04 24             	mov    %eax,(%esp)
c010655e:	e8 1b eb ff ff       	call   c010507e <page_ref>
c0106563:	83 f8 01             	cmp    $0x1,%eax
c0106566:	74 24                	je     c010658c <check_pgdir+0x3c9>
c0106568:	c7 44 24 0c be d1 10 	movl   $0xc010d1be,0xc(%esp)
c010656f:	c0 
c0106570:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106577:	c0 
c0106578:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
c010657f:	00 
c0106580:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106587:	e8 5f a8 ff ff       	call   c0100deb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010658c:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106591:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106598:	00 
c0106599:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01065a0:	00 
c01065a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065a4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065a8:	89 04 24             	mov    %eax,(%esp)
c01065ab:	e8 0b fa ff ff       	call   c0105fbb <page_insert>
c01065b0:	85 c0                	test   %eax,%eax
c01065b2:	74 24                	je     c01065d8 <check_pgdir+0x415>
c01065b4:	c7 44 24 0c d0 d1 10 	movl   $0xc010d1d0,0xc(%esp)
c01065bb:	c0 
c01065bc:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01065c3:	c0 
c01065c4:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
c01065cb:	00 
c01065cc:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01065d3:	e8 13 a8 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p1) == 2);
c01065d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065db:	89 04 24             	mov    %eax,(%esp)
c01065de:	e8 9b ea ff ff       	call   c010507e <page_ref>
c01065e3:	83 f8 02             	cmp    $0x2,%eax
c01065e6:	74 24                	je     c010660c <check_pgdir+0x449>
c01065e8:	c7 44 24 0c fc d1 10 	movl   $0xc010d1fc,0xc(%esp)
c01065ef:	c0 
c01065f0:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01065f7:	c0 
c01065f8:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
c01065ff:	00 
c0106600:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106607:	e8 df a7 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 0);
c010660c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010660f:	89 04 24             	mov    %eax,(%esp)
c0106612:	e8 67 ea ff ff       	call   c010507e <page_ref>
c0106617:	85 c0                	test   %eax,%eax
c0106619:	74 24                	je     c010663f <check_pgdir+0x47c>
c010661b:	c7 44 24 0c 0e d2 10 	movl   $0xc010d20e,0xc(%esp)
c0106622:	c0 
c0106623:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c010662a:	c0 
c010662b:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c0106632:	00 
c0106633:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010663a:	e8 ac a7 ff ff       	call   c0100deb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010663f:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106644:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010664b:	00 
c010664c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106653:	00 
c0106654:	89 04 24             	mov    %eax,(%esp)
c0106657:	e8 0b f3 ff ff       	call   c0105967 <get_pte>
c010665c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010665f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106663:	75 24                	jne    c0106689 <check_pgdir+0x4c6>
c0106665:	c7 44 24 0c 5c d1 10 	movl   $0xc010d15c,0xc(%esp)
c010666c:	c0 
c010666d:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106674:	c0 
c0106675:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c010667c:	00 
c010667d:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106684:	e8 62 a7 ff ff       	call   c0100deb <__panic>
    assert(pte2page(*ptep) == p1);
c0106689:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010668c:	8b 00                	mov    (%eax),%eax
c010668e:	89 04 24             	mov    %eax,(%esp)
c0106691:	e8 92 e9 ff ff       	call   c0105028 <pte2page>
c0106696:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106699:	74 24                	je     c01066bf <check_pgdir+0x4fc>
c010669b:	c7 44 24 0c d1 d0 10 	movl   $0xc010d0d1,0xc(%esp)
c01066a2:	c0 
c01066a3:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01066aa:	c0 
c01066ab:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
c01066b2:	00 
c01066b3:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01066ba:	e8 2c a7 ff ff       	call   c0100deb <__panic>
    assert((*ptep & PTE_U) == 0);
c01066bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066c2:	8b 00                	mov    (%eax),%eax
c01066c4:	83 e0 04             	and    $0x4,%eax
c01066c7:	85 c0                	test   %eax,%eax
c01066c9:	74 24                	je     c01066ef <check_pgdir+0x52c>
c01066cb:	c7 44 24 0c 20 d2 10 	movl   $0xc010d220,0xc(%esp)
c01066d2:	c0 
c01066d3:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01066da:	c0 
c01066db:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
c01066e2:	00 
c01066e3:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01066ea:	e8 fc a6 ff ff       	call   c0100deb <__panic>

    page_remove(boot_pgdir, 0x0);
c01066ef:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01066f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01066fb:	00 
c01066fc:	89 04 24             	mov    %eax,(%esp)
c01066ff:	e8 73 f8 ff ff       	call   c0105f77 <page_remove>
    assert(page_ref(p1) == 1);
c0106704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106707:	89 04 24             	mov    %eax,(%esp)
c010670a:	e8 6f e9 ff ff       	call   c010507e <page_ref>
c010670f:	83 f8 01             	cmp    $0x1,%eax
c0106712:	74 24                	je     c0106738 <check_pgdir+0x575>
c0106714:	c7 44 24 0c e7 d0 10 	movl   $0xc010d0e7,0xc(%esp)
c010671b:	c0 
c010671c:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106723:	c0 
c0106724:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
c010672b:	00 
c010672c:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106733:	e8 b3 a6 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 0);
c0106738:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010673b:	89 04 24             	mov    %eax,(%esp)
c010673e:	e8 3b e9 ff ff       	call   c010507e <page_ref>
c0106743:	85 c0                	test   %eax,%eax
c0106745:	74 24                	je     c010676b <check_pgdir+0x5a8>
c0106747:	c7 44 24 0c 0e d2 10 	movl   $0xc010d20e,0xc(%esp)
c010674e:	c0 
c010674f:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106756:	c0 
c0106757:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
c010675e:	00 
c010675f:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106766:	e8 80 a6 ff ff       	call   c0100deb <__panic>

    page_remove(boot_pgdir, PGSIZE);
c010676b:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106770:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106777:	00 
c0106778:	89 04 24             	mov    %eax,(%esp)
c010677b:	e8 f7 f7 ff ff       	call   c0105f77 <page_remove>
    assert(page_ref(p1) == 0);
c0106780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106783:	89 04 24             	mov    %eax,(%esp)
c0106786:	e8 f3 e8 ff ff       	call   c010507e <page_ref>
c010678b:	85 c0                	test   %eax,%eax
c010678d:	74 24                	je     c01067b3 <check_pgdir+0x5f0>
c010678f:	c7 44 24 0c 35 d2 10 	movl   $0xc010d235,0xc(%esp)
c0106796:	c0 
c0106797:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c010679e:	c0 
c010679f:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
c01067a6:	00 
c01067a7:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01067ae:	e8 38 a6 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 0);
c01067b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067b6:	89 04 24             	mov    %eax,(%esp)
c01067b9:	e8 c0 e8 ff ff       	call   c010507e <page_ref>
c01067be:	85 c0                	test   %eax,%eax
c01067c0:	74 24                	je     c01067e6 <check_pgdir+0x623>
c01067c2:	c7 44 24 0c 0e d2 10 	movl   $0xc010d20e,0xc(%esp)
c01067c9:	c0 
c01067ca:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01067d1:	c0 
c01067d2:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
c01067d9:	00 
c01067da:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01067e1:	e8 05 a6 ff ff       	call   c0100deb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01067e6:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01067eb:	8b 00                	mov    (%eax),%eax
c01067ed:	89 04 24             	mov    %eax,(%esp)
c01067f0:	e8 71 e8 ff ff       	call   c0105066 <pde2page>
c01067f5:	89 04 24             	mov    %eax,(%esp)
c01067f8:	e8 81 e8 ff ff       	call   c010507e <page_ref>
c01067fd:	83 f8 01             	cmp    $0x1,%eax
c0106800:	74 24                	je     c0106826 <check_pgdir+0x663>
c0106802:	c7 44 24 0c 48 d2 10 	movl   $0xc010d248,0xc(%esp)
c0106809:	c0 
c010680a:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106811:	c0 
c0106812:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
c0106819:	00 
c010681a:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106821:	e8 c5 a5 ff ff       	call   c0100deb <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0106826:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c010682b:	8b 00                	mov    (%eax),%eax
c010682d:	89 04 24             	mov    %eax,(%esp)
c0106830:	e8 31 e8 ff ff       	call   c0105066 <pde2page>
c0106835:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010683c:	00 
c010683d:	89 04 24             	mov    %eax,(%esp)
c0106840:	e8 a9 ea ff ff       	call   c01052ee <free_pages>
    boot_pgdir[0] = 0;
c0106845:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c010684a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0106850:	c7 04 24 6f d2 10 c0 	movl   $0xc010d26f,(%esp)
c0106857:	e8 03 9b ff ff       	call   c010035f <cprintf>
}
c010685c:	c9                   	leave  
c010685d:	c3                   	ret    

c010685e <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c010685e:	55                   	push   %ebp
c010685f:	89 e5                	mov    %esp,%ebp
c0106861:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106864:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010686b:	e9 ca 00 00 00       	jmp    c010693a <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0106870:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106873:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106876:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106879:	c1 e8 0c             	shr    $0xc,%eax
c010687c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010687f:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0106884:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106887:	72 23                	jb     c01068ac <check_boot_pgdir+0x4e>
c0106889:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010688c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106890:	c7 44 24 08 3c ce 10 	movl   $0xc010ce3c,0x8(%esp)
c0106897:	c0 
c0106898:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c010689f:	00 
c01068a0:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01068a7:	e8 3f a5 ff ff       	call   c0100deb <__panic>
c01068ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068af:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01068b4:	89 c2                	mov    %eax,%edx
c01068b6:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01068bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01068c2:	00 
c01068c3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01068c7:	89 04 24             	mov    %eax,(%esp)
c01068ca:	e8 98 f0 ff ff       	call   c0105967 <get_pte>
c01068cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01068d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01068d6:	75 24                	jne    c01068fc <check_boot_pgdir+0x9e>
c01068d8:	c7 44 24 0c 8c d2 10 	movl   $0xc010d28c,0xc(%esp)
c01068df:	c0 
c01068e0:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01068e7:	c0 
c01068e8:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c01068ef:	00 
c01068f0:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01068f7:	e8 ef a4 ff ff       	call   c0100deb <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01068fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01068ff:	8b 00                	mov    (%eax),%eax
c0106901:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106906:	89 c2                	mov    %eax,%edx
c0106908:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010690b:	39 c2                	cmp    %eax,%edx
c010690d:	74 24                	je     c0106933 <check_boot_pgdir+0xd5>
c010690f:	c7 44 24 0c c9 d2 10 	movl   $0xc010d2c9,0xc(%esp)
c0106916:	c0 
c0106917:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c010691e:	c0 
c010691f:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
c0106926:	00 
c0106927:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010692e:	e8 b8 a4 ff ff       	call   c0100deb <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106933:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c010693a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010693d:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0106942:	39 c2                	cmp    %eax,%edx
c0106944:	0f 82 26 ff ff ff    	jb     c0106870 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c010694a:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c010694f:	05 ac 0f 00 00       	add    $0xfac,%eax
c0106954:	8b 00                	mov    (%eax),%eax
c0106956:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010695b:	89 c2                	mov    %eax,%edx
c010695d:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106962:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106965:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c010696c:	77 23                	ja     c0106991 <check_boot_pgdir+0x133>
c010696e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106971:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106975:	c7 44 24 08 e0 ce 10 	movl   $0xc010cee0,0x8(%esp)
c010697c:	c0 
c010697d:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0106984:	00 
c0106985:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c010698c:	e8 5a a4 ff ff       	call   c0100deb <__panic>
c0106991:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106994:	05 00 00 00 40       	add    $0x40000000,%eax
c0106999:	39 c2                	cmp    %eax,%edx
c010699b:	74 24                	je     c01069c1 <check_boot_pgdir+0x163>
c010699d:	c7 44 24 0c e0 d2 10 	movl   $0xc010d2e0,0xc(%esp)
c01069a4:	c0 
c01069a5:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01069ac:	c0 
c01069ad:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c01069b4:	00 
c01069b5:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01069bc:	e8 2a a4 ff ff       	call   c0100deb <__panic>

    assert(boot_pgdir[0] == 0);
c01069c1:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c01069c6:	8b 00                	mov    (%eax),%eax
c01069c8:	85 c0                	test   %eax,%eax
c01069ca:	74 24                	je     c01069f0 <check_boot_pgdir+0x192>
c01069cc:	c7 44 24 0c 14 d3 10 	movl   $0xc010d314,0xc(%esp)
c01069d3:	c0 
c01069d4:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c01069db:	c0 
c01069dc:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
c01069e3:	00 
c01069e4:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c01069eb:	e8 fb a3 ff ff       	call   c0100deb <__panic>

    struct Page *p;
    p = alloc_page();
c01069f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069f7:	e8 87 e8 ff ff       	call   c0105283 <alloc_pages>
c01069fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01069ff:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106a04:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106a0b:	00 
c0106a0c:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0106a13:	00 
c0106a14:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106a17:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a1b:	89 04 24             	mov    %eax,(%esp)
c0106a1e:	e8 98 f5 ff ff       	call   c0105fbb <page_insert>
c0106a23:	85 c0                	test   %eax,%eax
c0106a25:	74 24                	je     c0106a4b <check_boot_pgdir+0x1ed>
c0106a27:	c7 44 24 0c 28 d3 10 	movl   $0xc010d328,0xc(%esp)
c0106a2e:	c0 
c0106a2f:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106a36:	c0 
c0106a37:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
c0106a3e:	00 
c0106a3f:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106a46:	e8 a0 a3 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p) == 1);
c0106a4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a4e:	89 04 24             	mov    %eax,(%esp)
c0106a51:	e8 28 e6 ff ff       	call   c010507e <page_ref>
c0106a56:	83 f8 01             	cmp    $0x1,%eax
c0106a59:	74 24                	je     c0106a7f <check_boot_pgdir+0x221>
c0106a5b:	c7 44 24 0c 56 d3 10 	movl   $0xc010d356,0xc(%esp)
c0106a62:	c0 
c0106a63:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106a6a:	c0 
c0106a6b:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c0106a72:	00 
c0106a73:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106a7a:	e8 6c a3 ff ff       	call   c0100deb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0106a7f:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106a84:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106a8b:	00 
c0106a8c:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0106a93:	00 
c0106a94:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106a97:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a9b:	89 04 24             	mov    %eax,(%esp)
c0106a9e:	e8 18 f5 ff ff       	call   c0105fbb <page_insert>
c0106aa3:	85 c0                	test   %eax,%eax
c0106aa5:	74 24                	je     c0106acb <check_boot_pgdir+0x26d>
c0106aa7:	c7 44 24 0c 68 d3 10 	movl   $0xc010d368,0xc(%esp)
c0106aae:	c0 
c0106aaf:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106ab6:	c0 
c0106ab7:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
c0106abe:	00 
c0106abf:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106ac6:	e8 20 a3 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p) == 2);
c0106acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ace:	89 04 24             	mov    %eax,(%esp)
c0106ad1:	e8 a8 e5 ff ff       	call   c010507e <page_ref>
c0106ad6:	83 f8 02             	cmp    $0x2,%eax
c0106ad9:	74 24                	je     c0106aff <check_boot_pgdir+0x2a1>
c0106adb:	c7 44 24 0c 9f d3 10 	movl   $0xc010d39f,0xc(%esp)
c0106ae2:	c0 
c0106ae3:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106aea:	c0 
c0106aeb:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
c0106af2:	00 
c0106af3:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106afa:	e8 ec a2 ff ff       	call   c0100deb <__panic>

    const char *str = "ucore: Hello world!!";
c0106aff:	c7 45 dc b0 d3 10 c0 	movl   $0xc010d3b0,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0106b06:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106b09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b0d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106b14:	e8 69 50 00 00       	call   c010bb82 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0106b19:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0106b20:	00 
c0106b21:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106b28:	e8 ce 50 00 00       	call   c010bbfb <strcmp>
c0106b2d:	85 c0                	test   %eax,%eax
c0106b2f:	74 24                	je     c0106b55 <check_boot_pgdir+0x2f7>
c0106b31:	c7 44 24 0c c8 d3 10 	movl   $0xc010d3c8,0xc(%esp)
c0106b38:	c0 
c0106b39:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106b40:	c0 
c0106b41:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
c0106b48:	00 
c0106b49:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106b50:	e8 96 a2 ff ff       	call   c0100deb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106b55:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b58:	89 04 24             	mov    %eax,(%esp)
c0106b5b:	e8 74 e4 ff ff       	call   c0104fd4 <page2kva>
c0106b60:	05 00 01 00 00       	add    $0x100,%eax
c0106b65:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106b68:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106b6f:	e8 b6 4f 00 00       	call   c010bb2a <strlen>
c0106b74:	85 c0                	test   %eax,%eax
c0106b76:	74 24                	je     c0106b9c <check_boot_pgdir+0x33e>
c0106b78:	c7 44 24 0c 00 d4 10 	movl   $0xc010d400,0xc(%esp)
c0106b7f:	c0 
c0106b80:	c7 44 24 08 29 cf 10 	movl   $0xc010cf29,0x8(%esp)
c0106b87:	c0 
c0106b88:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
c0106b8f:	00 
c0106b90:	c7 04 24 04 cf 10 c0 	movl   $0xc010cf04,(%esp)
c0106b97:	e8 4f a2 ff ff       	call   c0100deb <__panic>

    free_page(p);
c0106b9c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ba3:	00 
c0106ba4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ba7:	89 04 24             	mov    %eax,(%esp)
c0106baa:	e8 3f e7 ff ff       	call   c01052ee <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106baf:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106bb4:	8b 00                	mov    (%eax),%eax
c0106bb6:	89 04 24             	mov    %eax,(%esp)
c0106bb9:	e8 a8 e4 ff ff       	call   c0105066 <pde2page>
c0106bbe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106bc5:	00 
c0106bc6:	89 04 24             	mov    %eax,(%esp)
c0106bc9:	e8 20 e7 ff ff       	call   c01052ee <free_pages>
    boot_pgdir[0] = 0;
c0106bce:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0106bd3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106bd9:	c7 04 24 24 d4 10 c0 	movl   $0xc010d424,(%esp)
c0106be0:	e8 7a 97 ff ff       	call   c010035f <cprintf>
}
c0106be5:	c9                   	leave  
c0106be6:	c3                   	ret    

c0106be7 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106be7:	55                   	push   %ebp
c0106be8:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106bea:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bed:	83 e0 04             	and    $0x4,%eax
c0106bf0:	85 c0                	test   %eax,%eax
c0106bf2:	74 07                	je     c0106bfb <perm2str+0x14>
c0106bf4:	b8 75 00 00 00       	mov    $0x75,%eax
c0106bf9:	eb 05                	jmp    c0106c00 <perm2str+0x19>
c0106bfb:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106c00:	a2 28 f0 19 c0       	mov    %al,0xc019f028
    str[1] = 'r';
c0106c05:	c6 05 29 f0 19 c0 72 	movb   $0x72,0xc019f029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106c0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c0f:	83 e0 02             	and    $0x2,%eax
c0106c12:	85 c0                	test   %eax,%eax
c0106c14:	74 07                	je     c0106c1d <perm2str+0x36>
c0106c16:	b8 77 00 00 00       	mov    $0x77,%eax
c0106c1b:	eb 05                	jmp    c0106c22 <perm2str+0x3b>
c0106c1d:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106c22:	a2 2a f0 19 c0       	mov    %al,0xc019f02a
    str[3] = '\0';
c0106c27:	c6 05 2b f0 19 c0 00 	movb   $0x0,0xc019f02b
    return str;
c0106c2e:	b8 28 f0 19 c0       	mov    $0xc019f028,%eax
}
c0106c33:	5d                   	pop    %ebp
c0106c34:	c3                   	ret    

c0106c35 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106c35:	55                   	push   %ebp
c0106c36:	89 e5                	mov    %esp,%ebp
c0106c38:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106c3b:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c3e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c41:	72 0a                	jb     c0106c4d <get_pgtable_items+0x18>
        return 0;
c0106c43:	b8 00 00 00 00       	mov    $0x0,%eax
c0106c48:	e9 9c 00 00 00       	jmp    c0106ce9 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106c4d:	eb 04                	jmp    c0106c53 <get_pgtable_items+0x1e>
        start ++;
c0106c4f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106c53:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c56:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c59:	73 18                	jae    c0106c73 <get_pgtable_items+0x3e>
c0106c5b:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106c65:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c68:	01 d0                	add    %edx,%eax
c0106c6a:	8b 00                	mov    (%eax),%eax
c0106c6c:	83 e0 01             	and    $0x1,%eax
c0106c6f:	85 c0                	test   %eax,%eax
c0106c71:	74 dc                	je     c0106c4f <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0106c73:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c76:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c79:	73 69                	jae    c0106ce4 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0106c7b:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106c7f:	74 08                	je     c0106c89 <get_pgtable_items+0x54>
            *left_store = start;
c0106c81:	8b 45 18             	mov    0x18(%ebp),%eax
c0106c84:	8b 55 10             	mov    0x10(%ebp),%edx
c0106c87:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106c89:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c8c:	8d 50 01             	lea    0x1(%eax),%edx
c0106c8f:	89 55 10             	mov    %edx,0x10(%ebp)
c0106c92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106c99:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c9c:	01 d0                	add    %edx,%eax
c0106c9e:	8b 00                	mov    (%eax),%eax
c0106ca0:	83 e0 07             	and    $0x7,%eax
c0106ca3:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106ca6:	eb 04                	jmp    c0106cac <get_pgtable_items+0x77>
            start ++;
c0106ca8:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106cac:	8b 45 10             	mov    0x10(%ebp),%eax
c0106caf:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106cb2:	73 1d                	jae    c0106cd1 <get_pgtable_items+0x9c>
c0106cb4:	8b 45 10             	mov    0x10(%ebp),%eax
c0106cb7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106cbe:	8b 45 14             	mov    0x14(%ebp),%eax
c0106cc1:	01 d0                	add    %edx,%eax
c0106cc3:	8b 00                	mov    (%eax),%eax
c0106cc5:	83 e0 07             	and    $0x7,%eax
c0106cc8:	89 c2                	mov    %eax,%edx
c0106cca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ccd:	39 c2                	cmp    %eax,%edx
c0106ccf:	74 d7                	je     c0106ca8 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0106cd1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106cd5:	74 08                	je     c0106cdf <get_pgtable_items+0xaa>
            *right_store = start;
c0106cd7:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106cda:	8b 55 10             	mov    0x10(%ebp),%edx
c0106cdd:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106cdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ce2:	eb 05                	jmp    c0106ce9 <get_pgtable_items+0xb4>
    }
    return 0;
c0106ce4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106ce9:	c9                   	leave  
c0106cea:	c3                   	ret    

c0106ceb <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106ceb:	55                   	push   %ebp
c0106cec:	89 e5                	mov    %esp,%ebp
c0106cee:	57                   	push   %edi
c0106cef:	56                   	push   %esi
c0106cf0:	53                   	push   %ebx
c0106cf1:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106cf4:	c7 04 24 44 d4 10 c0 	movl   $0xc010d444,(%esp)
c0106cfb:	e8 5f 96 ff ff       	call   c010035f <cprintf>
    size_t left, right = 0, perm;
c0106d00:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106d07:	e9 fa 00 00 00       	jmp    c0106e06 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d0f:	89 04 24             	mov    %eax,(%esp)
c0106d12:	e8 d0 fe ff ff       	call   c0106be7 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106d17:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106d1a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106d1d:	29 d1                	sub    %edx,%ecx
c0106d1f:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106d21:	89 d6                	mov    %edx,%esi
c0106d23:	c1 e6 16             	shl    $0x16,%esi
c0106d26:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d29:	89 d3                	mov    %edx,%ebx
c0106d2b:	c1 e3 16             	shl    $0x16,%ebx
c0106d2e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106d31:	89 d1                	mov    %edx,%ecx
c0106d33:	c1 e1 16             	shl    $0x16,%ecx
c0106d36:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0106d39:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106d3c:	29 d7                	sub    %edx,%edi
c0106d3e:	89 fa                	mov    %edi,%edx
c0106d40:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106d44:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106d48:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106d4c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106d50:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106d54:	c7 04 24 75 d4 10 c0 	movl   $0xc010d475,(%esp)
c0106d5b:	e8 ff 95 ff ff       	call   c010035f <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0106d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d63:	c1 e0 0a             	shl    $0xa,%eax
c0106d66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106d69:	eb 54                	jmp    c0106dbf <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d6e:	89 04 24             	mov    %eax,(%esp)
c0106d71:	e8 71 fe ff ff       	call   c0106be7 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106d76:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106d79:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d7c:	29 d1                	sub    %edx,%ecx
c0106d7e:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106d80:	89 d6                	mov    %edx,%esi
c0106d82:	c1 e6 0c             	shl    $0xc,%esi
c0106d85:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106d88:	89 d3                	mov    %edx,%ebx
c0106d8a:	c1 e3 0c             	shl    $0xc,%ebx
c0106d8d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d90:	c1 e2 0c             	shl    $0xc,%edx
c0106d93:	89 d1                	mov    %edx,%ecx
c0106d95:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0106d98:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d9b:	29 d7                	sub    %edx,%edi
c0106d9d:	89 fa                	mov    %edi,%edx
c0106d9f:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106da3:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106da7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106dab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106daf:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106db3:	c7 04 24 94 d4 10 c0 	movl   $0xc010d494,(%esp)
c0106dba:	e8 a0 95 ff ff       	call   c010035f <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106dbf:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0106dc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106dc7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106dca:	89 ce                	mov    %ecx,%esi
c0106dcc:	c1 e6 0a             	shl    $0xa,%esi
c0106dcf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106dd2:	89 cb                	mov    %ecx,%ebx
c0106dd4:	c1 e3 0a             	shl    $0xa,%ebx
c0106dd7:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0106dda:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106dde:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0106de1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106de5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106de9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ded:	89 74 24 04          	mov    %esi,0x4(%esp)
c0106df1:	89 1c 24             	mov    %ebx,(%esp)
c0106df4:	e8 3c fe ff ff       	call   c0106c35 <get_pgtable_items>
c0106df9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106dfc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e00:	0f 85 65 ff ff ff    	jne    c0106d6b <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106e06:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0106e0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e0e:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0106e11:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106e15:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106e18:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106e1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106e20:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e24:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106e2b:	00 
c0106e2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106e33:	e8 fd fd ff ff       	call   c0106c35 <get_pgtable_items>
c0106e38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106e3b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e3f:	0f 85 c7 fe ff ff    	jne    c0106d0c <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106e45:	c7 04 24 b8 d4 10 c0 	movl   $0xc010d4b8,(%esp)
c0106e4c:	e8 0e 95 ff ff       	call   c010035f <cprintf>
}
c0106e51:	83 c4 4c             	add    $0x4c,%esp
c0106e54:	5b                   	pop    %ebx
c0106e55:	5e                   	pop    %esi
c0106e56:	5f                   	pop    %edi
c0106e57:	5d                   	pop    %ebp
c0106e58:	c3                   	ret    

c0106e59 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0106e59:	55                   	push   %ebp
c0106e5a:	89 e5                	mov    %esp,%ebp
c0106e5c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106e5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e62:	c1 e8 0c             	shr    $0xc,%eax
c0106e65:	89 c2                	mov    %eax,%edx
c0106e67:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0106e6c:	39 c2                	cmp    %eax,%edx
c0106e6e:	72 1c                	jb     c0106e8c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106e70:	c7 44 24 08 ec d4 10 	movl   $0xc010d4ec,0x8(%esp)
c0106e77:	c0 
c0106e78:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106e7f:	00 
c0106e80:	c7 04 24 0b d5 10 c0 	movl   $0xc010d50b,(%esp)
c0106e87:	e8 5f 9f ff ff       	call   c0100deb <__panic>
    }
    return &pages[PPN(pa)];
c0106e8c:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0106e91:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e94:	c1 ea 0c             	shr    $0xc,%edx
c0106e97:	c1 e2 05             	shl    $0x5,%edx
c0106e9a:	01 d0                	add    %edx,%eax
}
c0106e9c:	c9                   	leave  
c0106e9d:	c3                   	ret    

c0106e9e <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0106e9e:	55                   	push   %ebp
c0106e9f:	89 e5                	mov    %esp,%ebp
c0106ea1:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ea7:	83 e0 01             	and    $0x1,%eax
c0106eaa:	85 c0                	test   %eax,%eax
c0106eac:	75 1c                	jne    c0106eca <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106eae:	c7 44 24 08 1c d5 10 	movl   $0xc010d51c,0x8(%esp)
c0106eb5:	c0 
c0106eb6:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106ebd:	00 
c0106ebe:	c7 04 24 0b d5 10 c0 	movl   $0xc010d50b,(%esp)
c0106ec5:	e8 21 9f ff ff       	call   c0100deb <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106eca:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ecd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106ed2:	89 04 24             	mov    %eax,(%esp)
c0106ed5:	e8 7f ff ff ff       	call   c0106e59 <pa2page>
}
c0106eda:	c9                   	leave  
c0106edb:	c3                   	ret    

c0106edc <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106edc:	55                   	push   %ebp
c0106edd:	89 e5                	mov    %esp,%ebp
c0106edf:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106ee2:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ee5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106eea:	89 04 24             	mov    %eax,(%esp)
c0106eed:	e8 67 ff ff ff       	call   c0106e59 <pa2page>
}
c0106ef2:	c9                   	leave  
c0106ef3:	c3                   	ret    

c0106ef4 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106ef4:	55                   	push   %ebp
c0106ef5:	89 e5                	mov    %esp,%ebp
c0106ef7:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106efa:	e8 e9 23 00 00       	call   c01092e8 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106eff:	a1 9c 11 1a c0       	mov    0xc01a119c,%eax
c0106f04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106f09:	76 0c                	jbe    c0106f17 <swap_init+0x23>
c0106f0b:	a1 9c 11 1a c0       	mov    0xc01a119c,%eax
c0106f10:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106f15:	76 25                	jbe    c0106f3c <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106f17:	a1 9c 11 1a c0       	mov    0xc01a119c,%eax
c0106f1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106f20:	c7 44 24 08 3d d5 10 	movl   $0xc010d53d,0x8(%esp)
c0106f27:	c0 
c0106f28:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106f2f:	00 
c0106f30:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0106f37:	e8 af 9e ff ff       	call   c0100deb <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106f3c:	c7 05 34 f0 19 c0 60 	movl   $0xc012aa60,0xc019f034
c0106f43:	aa 12 c0 
     int r = sm->init();
c0106f46:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0106f4b:	8b 40 04             	mov    0x4(%eax),%eax
c0106f4e:	ff d0                	call   *%eax
c0106f50:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106f53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f57:	75 26                	jne    c0106f7f <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106f59:	c7 05 2c f0 19 c0 01 	movl   $0x1,0xc019f02c
c0106f60:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106f63:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0106f68:	8b 00                	mov    (%eax),%eax
c0106f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f6e:	c7 04 24 67 d5 10 c0 	movl   $0xc010d567,(%esp)
c0106f75:	e8 e5 93 ff ff       	call   c010035f <cprintf>
          check_swap();
c0106f7a:	e8 a4 04 00 00       	call   c0107423 <check_swap>
     }

     return r;
c0106f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106f82:	c9                   	leave  
c0106f83:	c3                   	ret    

c0106f84 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106f84:	55                   	push   %ebp
c0106f85:	89 e5                	mov    %esp,%ebp
c0106f87:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106f8a:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0106f8f:	8b 40 08             	mov    0x8(%eax),%eax
c0106f92:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f95:	89 14 24             	mov    %edx,(%esp)
c0106f98:	ff d0                	call   *%eax
}
c0106f9a:	c9                   	leave  
c0106f9b:	c3                   	ret    

c0106f9c <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106f9c:	55                   	push   %ebp
c0106f9d:	89 e5                	mov    %esp,%ebp
c0106f9f:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106fa2:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0106fa7:	8b 40 0c             	mov    0xc(%eax),%eax
c0106faa:	8b 55 08             	mov    0x8(%ebp),%edx
c0106fad:	89 14 24             	mov    %edx,(%esp)
c0106fb0:	ff d0                	call   *%eax
}
c0106fb2:	c9                   	leave  
c0106fb3:	c3                   	ret    

c0106fb4 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106fb4:	55                   	push   %ebp
c0106fb5:	89 e5                	mov    %esp,%ebp
c0106fb7:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106fba:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0106fbf:	8b 40 10             	mov    0x10(%eax),%eax
c0106fc2:	8b 55 14             	mov    0x14(%ebp),%edx
c0106fc5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106fc9:	8b 55 10             	mov    0x10(%ebp),%edx
c0106fcc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106fd7:	8b 55 08             	mov    0x8(%ebp),%edx
c0106fda:	89 14 24             	mov    %edx,(%esp)
c0106fdd:	ff d0                	call   *%eax
}
c0106fdf:	c9                   	leave  
c0106fe0:	c3                   	ret    

c0106fe1 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106fe1:	55                   	push   %ebp
c0106fe2:	89 e5                	mov    %esp,%ebp
c0106fe4:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0106fe7:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0106fec:	8b 40 14             	mov    0x14(%eax),%eax
c0106fef:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106ff2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ff6:	8b 55 08             	mov    0x8(%ebp),%edx
c0106ff9:	89 14 24             	mov    %edx,(%esp)
c0106ffc:	ff d0                	call   *%eax
}
c0106ffe:	c9                   	leave  
c0106fff:	c3                   	ret    

c0107000 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0107000:	55                   	push   %ebp
c0107001:	89 e5                	mov    %esp,%ebp
c0107003:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0107006:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010700d:	e9 5a 01 00 00       	jmp    c010716c <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0107012:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0107017:	8b 40 18             	mov    0x18(%eax),%eax
c010701a:	8b 55 10             	mov    0x10(%ebp),%edx
c010701d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107021:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0107024:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107028:	8b 55 08             	mov    0x8(%ebp),%edx
c010702b:	89 14 24             	mov    %edx,(%esp)
c010702e:	ff d0                	call   *%eax
c0107030:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0107033:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107037:	74 18                	je     c0107051 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0107039:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010703c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107040:	c7 04 24 7c d5 10 c0 	movl   $0xc010d57c,(%esp)
c0107047:	e8 13 93 ff ff       	call   c010035f <cprintf>
c010704c:	e9 27 01 00 00       	jmp    c0107178 <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0107051:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107054:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107057:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010705a:	8b 45 08             	mov    0x8(%ebp),%eax
c010705d:	8b 40 0c             	mov    0xc(%eax),%eax
c0107060:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107067:	00 
c0107068:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010706b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010706f:	89 04 24             	mov    %eax,(%esp)
c0107072:	e8 f0 e8 ff ff       	call   c0105967 <get_pte>
c0107077:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010707a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010707d:	8b 00                	mov    (%eax),%eax
c010707f:	83 e0 01             	and    $0x1,%eax
c0107082:	85 c0                	test   %eax,%eax
c0107084:	75 24                	jne    c01070aa <swap_out+0xaa>
c0107086:	c7 44 24 0c a9 d5 10 	movl   $0xc010d5a9,0xc(%esp)
c010708d:	c0 
c010708e:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c0107095:	c0 
c0107096:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c010709d:	00 
c010709e:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01070a5:	e8 41 9d ff ff       	call   c0100deb <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01070aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01070b0:	8b 52 1c             	mov    0x1c(%edx),%edx
c01070b3:	c1 ea 0c             	shr    $0xc,%edx
c01070b6:	83 c2 01             	add    $0x1,%edx
c01070b9:	c1 e2 08             	shl    $0x8,%edx
c01070bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01070c0:	89 14 24             	mov    %edx,(%esp)
c01070c3:	e8 da 22 00 00       	call   c01093a2 <swapfs_write>
c01070c8:	85 c0                	test   %eax,%eax
c01070ca:	74 34                	je     c0107100 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c01070cc:	c7 04 24 d3 d5 10 c0 	movl   $0xc010d5d3,(%esp)
c01070d3:	e8 87 92 ff ff       	call   c010035f <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01070d8:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c01070dd:	8b 40 10             	mov    0x10(%eax),%eax
c01070e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01070e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01070ea:	00 
c01070eb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01070ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070f2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070f6:	8b 55 08             	mov    0x8(%ebp),%edx
c01070f9:	89 14 24             	mov    %edx,(%esp)
c01070fc:	ff d0                	call   *%eax
c01070fe:	eb 68                	jmp    c0107168 <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0107100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107103:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107106:	c1 e8 0c             	shr    $0xc,%eax
c0107109:	83 c0 01             	add    $0x1,%eax
c010710c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107110:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107113:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107117:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010711a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010711e:	c7 04 24 ec d5 10 c0 	movl   $0xc010d5ec,(%esp)
c0107125:	e8 35 92 ff ff       	call   c010035f <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010712a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010712d:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107130:	c1 e8 0c             	shr    $0xc,%eax
c0107133:	83 c0 01             	add    $0x1,%eax
c0107136:	c1 e0 08             	shl    $0x8,%eax
c0107139:	89 c2                	mov    %eax,%edx
c010713b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010713e:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0107140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107143:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010714a:	00 
c010714b:	89 04 24             	mov    %eax,(%esp)
c010714e:	e8 9b e1 ff ff       	call   c01052ee <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0107153:	8b 45 08             	mov    0x8(%ebp),%eax
c0107156:	8b 40 0c             	mov    0xc(%eax),%eax
c0107159:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010715c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107160:	89 04 24             	mov    %eax,(%esp)
c0107163:	e8 0c ef ff ff       	call   c0106074 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0107168:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010716c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010716f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107172:	0f 85 9a fe ff ff    	jne    c0107012 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0107178:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010717b:	c9                   	leave  
c010717c:	c3                   	ret    

c010717d <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c010717d:	55                   	push   %ebp
c010717e:	89 e5                	mov    %esp,%ebp
c0107180:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0107183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010718a:	e8 f4 e0 ff ff       	call   c0105283 <alloc_pages>
c010718f:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0107192:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107196:	75 24                	jne    c01071bc <swap_in+0x3f>
c0107198:	c7 44 24 0c 2c d6 10 	movl   $0xc010d62c,0xc(%esp)
c010719f:	c0 
c01071a0:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01071a7:	c0 
c01071a8:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01071af:	00 
c01071b0:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01071b7:	e8 2f 9c ff ff       	call   c0100deb <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01071bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01071bf:	8b 40 0c             	mov    0xc(%eax),%eax
c01071c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01071c9:	00 
c01071ca:	8b 55 0c             	mov    0xc(%ebp),%edx
c01071cd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071d1:	89 04 24             	mov    %eax,(%esp)
c01071d4:	e8 8e e7 ff ff       	call   c0105967 <get_pte>
c01071d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01071dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01071df:	8b 00                	mov    (%eax),%eax
c01071e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01071e4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071e8:	89 04 24             	mov    %eax,(%esp)
c01071eb:	e8 40 21 00 00       	call   c0109330 <swapfs_read>
c01071f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01071f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01071f7:	74 2a                	je     c0107223 <swap_in+0xa6>
     {
        assert(r!=0);
c01071f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01071fd:	75 24                	jne    c0107223 <swap_in+0xa6>
c01071ff:	c7 44 24 0c 39 d6 10 	movl   $0xc010d639,0xc(%esp)
c0107206:	c0 
c0107207:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010720e:	c0 
c010720f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0107216:	00 
c0107217:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010721e:	e8 c8 9b ff ff       	call   c0100deb <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0107223:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107226:	8b 00                	mov    (%eax),%eax
c0107228:	c1 e8 08             	shr    $0x8,%eax
c010722b:	89 c2                	mov    %eax,%edx
c010722d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107230:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107234:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107238:	c7 04 24 40 d6 10 c0 	movl   $0xc010d640,(%esp)
c010723f:	e8 1b 91 ff ff       	call   c010035f <cprintf>
     *ptr_result=result;
c0107244:	8b 45 10             	mov    0x10(%ebp),%eax
c0107247:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010724a:	89 10                	mov    %edx,(%eax)
     return 0;
c010724c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107251:	c9                   	leave  
c0107252:	c3                   	ret    

c0107253 <check_content_set>:



static inline void
check_content_set(void)
{
c0107253:	55                   	push   %ebp
c0107254:	89 e5                	mov    %esp,%ebp
c0107256:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0107259:	b8 00 10 00 00       	mov    $0x1000,%eax
c010725e:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107261:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107266:	83 f8 01             	cmp    $0x1,%eax
c0107269:	74 24                	je     c010728f <check_content_set+0x3c>
c010726b:	c7 44 24 0c 7e d6 10 	movl   $0xc010d67e,0xc(%esp)
c0107272:	c0 
c0107273:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010727a:	c0 
c010727b:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0107282:	00 
c0107283:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010728a:	e8 5c 9b ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c010728f:	b8 10 10 00 00       	mov    $0x1010,%eax
c0107294:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107297:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c010729c:	83 f8 01             	cmp    $0x1,%eax
c010729f:	74 24                	je     c01072c5 <check_content_set+0x72>
c01072a1:	c7 44 24 0c 7e d6 10 	movl   $0xc010d67e,0xc(%esp)
c01072a8:	c0 
c01072a9:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01072b0:	c0 
c01072b1:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01072b8:	00 
c01072b9:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01072c0:	e8 26 9b ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01072c5:	b8 00 20 00 00       	mov    $0x2000,%eax
c01072ca:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01072cd:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c01072d2:	83 f8 02             	cmp    $0x2,%eax
c01072d5:	74 24                	je     c01072fb <check_content_set+0xa8>
c01072d7:	c7 44 24 0c 8d d6 10 	movl   $0xc010d68d,0xc(%esp)
c01072de:	c0 
c01072df:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01072e6:	c0 
c01072e7:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c01072ee:	00 
c01072ef:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01072f6:	e8 f0 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01072fb:	b8 10 20 00 00       	mov    $0x2010,%eax
c0107300:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107303:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107308:	83 f8 02             	cmp    $0x2,%eax
c010730b:	74 24                	je     c0107331 <check_content_set+0xde>
c010730d:	c7 44 24 0c 8d d6 10 	movl   $0xc010d68d,0xc(%esp)
c0107314:	c0 
c0107315:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010731c:	c0 
c010731d:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0107324:	00 
c0107325:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010732c:	e8 ba 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0107331:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107336:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0107339:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c010733e:	83 f8 03             	cmp    $0x3,%eax
c0107341:	74 24                	je     c0107367 <check_content_set+0x114>
c0107343:	c7 44 24 0c 9c d6 10 	movl   $0xc010d69c,0xc(%esp)
c010734a:	c0 
c010734b:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c0107352:	c0 
c0107353:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c010735a:	00 
c010735b:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0107362:	e8 84 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0107367:	b8 10 30 00 00       	mov    $0x3010,%eax
c010736c:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010736f:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107374:	83 f8 03             	cmp    $0x3,%eax
c0107377:	74 24                	je     c010739d <check_content_set+0x14a>
c0107379:	c7 44 24 0c 9c d6 10 	movl   $0xc010d69c,0xc(%esp)
c0107380:	c0 
c0107381:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c0107388:	c0 
c0107389:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0107390:	00 
c0107391:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0107398:	e8 4e 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c010739d:	b8 00 40 00 00       	mov    $0x4000,%eax
c01073a2:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01073a5:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c01073aa:	83 f8 04             	cmp    $0x4,%eax
c01073ad:	74 24                	je     c01073d3 <check_content_set+0x180>
c01073af:	c7 44 24 0c ab d6 10 	movl   $0xc010d6ab,0xc(%esp)
c01073b6:	c0 
c01073b7:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01073be:	c0 
c01073bf:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01073c6:	00 
c01073c7:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01073ce:	e8 18 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01073d3:	b8 10 40 00 00       	mov    $0x4010,%eax
c01073d8:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01073db:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c01073e0:	83 f8 04             	cmp    $0x4,%eax
c01073e3:	74 24                	je     c0107409 <check_content_set+0x1b6>
c01073e5:	c7 44 24 0c ab d6 10 	movl   $0xc010d6ab,0xc(%esp)
c01073ec:	c0 
c01073ed:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01073f4:	c0 
c01073f5:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01073fc:	00 
c01073fd:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0107404:	e8 e2 99 ff ff       	call   c0100deb <__panic>
}
c0107409:	c9                   	leave  
c010740a:	c3                   	ret    

c010740b <check_content_access>:

static inline int
check_content_access(void)
{
c010740b:	55                   	push   %ebp
c010740c:	89 e5                	mov    %esp,%ebp
c010740e:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0107411:	a1 34 f0 19 c0       	mov    0xc019f034,%eax
c0107416:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107419:	ff d0                	call   *%eax
c010741b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010741e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107421:	c9                   	leave  
c0107422:	c3                   	ret    

c0107423 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0107423:	55                   	push   %ebp
c0107424:	89 e5                	mov    %esp,%ebp
c0107426:	53                   	push   %ebx
c0107427:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010742a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107431:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0107438:	c7 45 e8 d0 10 1a c0 	movl   $0xc01a10d0,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010743f:	eb 6b                	jmp    c01074ac <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0107441:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107444:	83 e8 0c             	sub    $0xc,%eax
c0107447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c010744a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010744d:	83 c0 04             	add    $0x4,%eax
c0107450:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0107457:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010745a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010745d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107460:	0f a3 10             	bt     %edx,(%eax)
c0107463:	19 c0                	sbb    %eax,%eax
c0107465:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0107468:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010746c:	0f 95 c0             	setne  %al
c010746f:	0f b6 c0             	movzbl %al,%eax
c0107472:	85 c0                	test   %eax,%eax
c0107474:	75 24                	jne    c010749a <check_swap+0x77>
c0107476:	c7 44 24 0c ba d6 10 	movl   $0xc010d6ba,0xc(%esp)
c010747d:	c0 
c010747e:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c0107485:	c0 
c0107486:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c010748d:	00 
c010748e:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0107495:	e8 51 99 ff ff       	call   c0100deb <__panic>
        count ++, total += p->property;
c010749a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010749e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074a1:	8b 50 08             	mov    0x8(%eax),%edx
c01074a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074a7:	01 d0                	add    %edx,%eax
c01074a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01074ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01074af:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01074b2:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01074b5:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01074b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01074bb:	81 7d e8 d0 10 1a c0 	cmpl   $0xc01a10d0,-0x18(%ebp)
c01074c2:	0f 85 79 ff ff ff    	jne    c0107441 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01074c8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01074cb:	e8 50 de ff ff       	call   c0105320 <nr_free_pages>
c01074d0:	39 c3                	cmp    %eax,%ebx
c01074d2:	74 24                	je     c01074f8 <check_swap+0xd5>
c01074d4:	c7 44 24 0c ca d6 10 	movl   $0xc010d6ca,0xc(%esp)
c01074db:	c0 
c01074dc:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01074e3:	c0 
c01074e4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c01074eb:	00 
c01074ec:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01074f3:	e8 f3 98 ff ff       	call   c0100deb <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01074f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01074ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107502:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107506:	c7 04 24 e4 d6 10 c0 	movl   $0xc010d6e4,(%esp)
c010750d:	e8 4d 8e ff ff       	call   c010035f <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0107512:	e8 74 0b 00 00       	call   c010808b <mm_create>
c0107517:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c010751a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010751e:	75 24                	jne    c0107544 <check_swap+0x121>
c0107520:	c7 44 24 0c 0a d7 10 	movl   $0xc010d70a,0xc(%esp)
c0107527:	c0 
c0107528:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010752f:	c0 
c0107530:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0107537:	00 
c0107538:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010753f:	e8 a7 98 ff ff       	call   c0100deb <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0107544:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c0107549:	85 c0                	test   %eax,%eax
c010754b:	74 24                	je     c0107571 <check_swap+0x14e>
c010754d:	c7 44 24 0c 15 d7 10 	movl   $0xc010d715,0xc(%esp)
c0107554:	c0 
c0107555:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010755c:	c0 
c010755d:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0107564:	00 
c0107565:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010756c:	e8 7a 98 ff ff       	call   c0100deb <__panic>

     check_mm_struct = mm;
c0107571:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107574:	a3 cc 11 1a c0       	mov    %eax,0xc01a11cc

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107579:	8b 15 00 aa 12 c0    	mov    0xc012aa00,%edx
c010757f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107582:	89 50 0c             	mov    %edx,0xc(%eax)
c0107585:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107588:	8b 40 0c             	mov    0xc(%eax),%eax
c010758b:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c010758e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107591:	8b 00                	mov    (%eax),%eax
c0107593:	85 c0                	test   %eax,%eax
c0107595:	74 24                	je     c01075bb <check_swap+0x198>
c0107597:	c7 44 24 0c 2d d7 10 	movl   $0xc010d72d,0xc(%esp)
c010759e:	c0 
c010759f:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01075a6:	c0 
c01075a7:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01075ae:	00 
c01075af:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01075b6:	e8 30 98 ff ff       	call   c0100deb <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01075bb:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01075c2:	00 
c01075c3:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01075ca:	00 
c01075cb:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01075d2:	e8 4d 0b 00 00       	call   c0108124 <vma_create>
c01075d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c01075da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01075de:	75 24                	jne    c0107604 <check_swap+0x1e1>
c01075e0:	c7 44 24 0c 3b d7 10 	movl   $0xc010d73b,0xc(%esp)
c01075e7:	c0 
c01075e8:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01075ef:	c0 
c01075f0:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c01075f7:	00 
c01075f8:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01075ff:	e8 e7 97 ff ff       	call   c0100deb <__panic>

     insert_vma_struct(mm, vma);
c0107604:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107607:	89 44 24 04          	mov    %eax,0x4(%esp)
c010760b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010760e:	89 04 24             	mov    %eax,(%esp)
c0107611:	e8 9e 0c 00 00       	call   c01082b4 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0107616:	c7 04 24 48 d7 10 c0 	movl   $0xc010d748,(%esp)
c010761d:	e8 3d 8d ff ff       	call   c010035f <cprintf>
     pte_t *temp_ptep=NULL;
c0107622:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0107629:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010762c:	8b 40 0c             	mov    0xc(%eax),%eax
c010762f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107636:	00 
c0107637:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010763e:	00 
c010763f:	89 04 24             	mov    %eax,(%esp)
c0107642:	e8 20 e3 ff ff       	call   c0105967 <get_pte>
c0107647:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c010764a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010764e:	75 24                	jne    c0107674 <check_swap+0x251>
c0107650:	c7 44 24 0c 7c d7 10 	movl   $0xc010d77c,0xc(%esp)
c0107657:	c0 
c0107658:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010765f:	c0 
c0107660:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0107667:	00 
c0107668:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010766f:	e8 77 97 ff ff       	call   c0100deb <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0107674:	c7 04 24 90 d7 10 c0 	movl   $0xc010d790,(%esp)
c010767b:	e8 df 8c ff ff       	call   c010035f <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107680:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107687:	e9 a3 00 00 00       	jmp    c010772f <check_swap+0x30c>
          check_rp[i] = alloc_page();
c010768c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107693:	e8 eb db ff ff       	call   c0105283 <alloc_pages>
c0107698:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010769b:	89 04 95 00 11 1a c0 	mov    %eax,-0x3fe5ef00(,%edx,4)
          assert(check_rp[i] != NULL );
c01076a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076a5:	8b 04 85 00 11 1a c0 	mov    -0x3fe5ef00(,%eax,4),%eax
c01076ac:	85 c0                	test   %eax,%eax
c01076ae:	75 24                	jne    c01076d4 <check_swap+0x2b1>
c01076b0:	c7 44 24 0c b4 d7 10 	movl   $0xc010d7b4,0xc(%esp)
c01076b7:	c0 
c01076b8:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01076bf:	c0 
c01076c0:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c01076c7:	00 
c01076c8:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01076cf:	e8 17 97 ff ff       	call   c0100deb <__panic>
          assert(!PageProperty(check_rp[i]));
c01076d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076d7:	8b 04 85 00 11 1a c0 	mov    -0x3fe5ef00(,%eax,4),%eax
c01076de:	83 c0 04             	add    $0x4,%eax
c01076e1:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01076e8:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01076eb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01076ee:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01076f1:	0f a3 10             	bt     %edx,(%eax)
c01076f4:	19 c0                	sbb    %eax,%eax
c01076f6:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01076f9:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01076fd:	0f 95 c0             	setne  %al
c0107700:	0f b6 c0             	movzbl %al,%eax
c0107703:	85 c0                	test   %eax,%eax
c0107705:	74 24                	je     c010772b <check_swap+0x308>
c0107707:	c7 44 24 0c c8 d7 10 	movl   $0xc010d7c8,0xc(%esp)
c010770e:	c0 
c010770f:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c0107716:	c0 
c0107717:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010771e:	00 
c010771f:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0107726:	e8 c0 96 ff ff       	call   c0100deb <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010772b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010772f:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107733:	0f 8e 53 ff ff ff    	jle    c010768c <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c0107739:	a1 d0 10 1a c0       	mov    0xc01a10d0,%eax
c010773e:	8b 15 d4 10 1a c0    	mov    0xc01a10d4,%edx
c0107744:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107747:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010774a:	c7 45 a8 d0 10 1a c0 	movl   $0xc01a10d0,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107751:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107754:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0107757:	89 50 04             	mov    %edx,0x4(%eax)
c010775a:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010775d:	8b 50 04             	mov    0x4(%eax),%edx
c0107760:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107763:	89 10                	mov    %edx,(%eax)
c0107765:	c7 45 a4 d0 10 1a c0 	movl   $0xc01a10d0,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010776c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010776f:	8b 40 04             	mov    0x4(%eax),%eax
c0107772:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0107775:	0f 94 c0             	sete   %al
c0107778:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c010777b:	85 c0                	test   %eax,%eax
c010777d:	75 24                	jne    c01077a3 <check_swap+0x380>
c010777f:	c7 44 24 0c e3 d7 10 	movl   $0xc010d7e3,0xc(%esp)
c0107786:	c0 
c0107787:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010778e:	c0 
c010778f:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0107796:	00 
c0107797:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010779e:	e8 48 96 ff ff       	call   c0100deb <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01077a3:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c01077a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c01077ab:	c7 05 d8 10 1a c0 00 	movl   $0x0,0xc01a10d8
c01077b2:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01077b5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01077bc:	eb 1e                	jmp    c01077dc <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01077be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077c1:	8b 04 85 00 11 1a c0 	mov    -0x3fe5ef00(,%eax,4),%eax
c01077c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01077cf:	00 
c01077d0:	89 04 24             	mov    %eax,(%esp)
c01077d3:	e8 16 db ff ff       	call   c01052ee <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01077d8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01077dc:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01077e0:	7e dc                	jle    c01077be <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01077e2:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c01077e7:	83 f8 04             	cmp    $0x4,%eax
c01077ea:	74 24                	je     c0107810 <check_swap+0x3ed>
c01077ec:	c7 44 24 0c fc d7 10 	movl   $0xc010d7fc,0xc(%esp)
c01077f3:	c0 
c01077f4:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01077fb:	c0 
c01077fc:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0107803:	00 
c0107804:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010780b:	e8 db 95 ff ff       	call   c0100deb <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0107810:	c7 04 24 20 d8 10 c0 	movl   $0xc010d820,(%esp)
c0107817:	e8 43 8b ff ff       	call   c010035f <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010781c:	c7 05 38 f0 19 c0 00 	movl   $0x0,0xc019f038
c0107823:	00 00 00 
     
     check_content_set();
c0107826:	e8 28 fa ff ff       	call   c0107253 <check_content_set>
     assert( nr_free == 0);         
c010782b:	a1 d8 10 1a c0       	mov    0xc01a10d8,%eax
c0107830:	85 c0                	test   %eax,%eax
c0107832:	74 24                	je     c0107858 <check_swap+0x435>
c0107834:	c7 44 24 0c 47 d8 10 	movl   $0xc010d847,0xc(%esp)
c010783b:	c0 
c010783c:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c0107843:	c0 
c0107844:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c010784b:	00 
c010784c:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0107853:	e8 93 95 ff ff       	call   c0100deb <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107858:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010785f:	eb 26                	jmp    c0107887 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0107861:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107864:	c7 04 85 20 11 1a c0 	movl   $0xffffffff,-0x3fe5eee0(,%eax,4)
c010786b:	ff ff ff ff 
c010786f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107872:	8b 14 85 20 11 1a c0 	mov    -0x3fe5eee0(,%eax,4),%edx
c0107879:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010787c:	89 14 85 60 11 1a c0 	mov    %edx,-0x3fe5eea0(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107883:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107887:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c010788b:	7e d4                	jle    c0107861 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010788d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107894:	e9 eb 00 00 00       	jmp    c0107984 <check_swap+0x561>
         check_ptep[i]=0;
c0107899:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010789c:	c7 04 85 b4 11 1a c0 	movl   $0x0,-0x3fe5ee4c(,%eax,4)
c01078a3:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01078a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078aa:	83 c0 01             	add    $0x1,%eax
c01078ad:	c1 e0 0c             	shl    $0xc,%eax
c01078b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01078b7:	00 
c01078b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01078bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01078bf:	89 04 24             	mov    %eax,(%esp)
c01078c2:	e8 a0 e0 ff ff       	call   c0105967 <get_pte>
c01078c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01078ca:	89 04 95 b4 11 1a c0 	mov    %eax,-0x3fe5ee4c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01078d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078d4:	8b 04 85 b4 11 1a c0 	mov    -0x3fe5ee4c(,%eax,4),%eax
c01078db:	85 c0                	test   %eax,%eax
c01078dd:	75 24                	jne    c0107903 <check_swap+0x4e0>
c01078df:	c7 44 24 0c 54 d8 10 	movl   $0xc010d854,0xc(%esp)
c01078e6:	c0 
c01078e7:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01078ee:	c0 
c01078ef:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01078f6:	00 
c01078f7:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01078fe:	e8 e8 94 ff ff       	call   c0100deb <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0107903:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107906:	8b 04 85 b4 11 1a c0 	mov    -0x3fe5ee4c(,%eax,4),%eax
c010790d:	8b 00                	mov    (%eax),%eax
c010790f:	89 04 24             	mov    %eax,(%esp)
c0107912:	e8 87 f5 ff ff       	call   c0106e9e <pte2page>
c0107917:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010791a:	8b 14 95 00 11 1a c0 	mov    -0x3fe5ef00(,%edx,4),%edx
c0107921:	39 d0                	cmp    %edx,%eax
c0107923:	74 24                	je     c0107949 <check_swap+0x526>
c0107925:	c7 44 24 0c 6c d8 10 	movl   $0xc010d86c,0xc(%esp)
c010792c:	c0 
c010792d:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c0107934:	c0 
c0107935:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c010793c:	00 
c010793d:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c0107944:	e8 a2 94 ff ff       	call   c0100deb <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0107949:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010794c:	8b 04 85 b4 11 1a c0 	mov    -0x3fe5ee4c(,%eax,4),%eax
c0107953:	8b 00                	mov    (%eax),%eax
c0107955:	83 e0 01             	and    $0x1,%eax
c0107958:	85 c0                	test   %eax,%eax
c010795a:	75 24                	jne    c0107980 <check_swap+0x55d>
c010795c:	c7 44 24 0c 94 d8 10 	movl   $0xc010d894,0xc(%esp)
c0107963:	c0 
c0107964:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c010796b:	c0 
c010796c:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0107973:	00 
c0107974:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c010797b:	e8 6b 94 ff ff       	call   c0100deb <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107980:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107984:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107988:	0f 8e 0b ff ff ff    	jle    c0107899 <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c010798e:	c7 04 24 b0 d8 10 c0 	movl   $0xc010d8b0,(%esp)
c0107995:	e8 c5 89 ff ff       	call   c010035f <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c010799a:	e8 6c fa ff ff       	call   c010740b <check_content_access>
c010799f:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c01079a2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01079a6:	74 24                	je     c01079cc <check_swap+0x5a9>
c01079a8:	c7 44 24 0c d6 d8 10 	movl   $0xc010d8d6,0xc(%esp)
c01079af:	c0 
c01079b0:	c7 44 24 08 be d5 10 	movl   $0xc010d5be,0x8(%esp)
c01079b7:	c0 
c01079b8:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01079bf:	00 
c01079c0:	c7 04 24 58 d5 10 c0 	movl   $0xc010d558,(%esp)
c01079c7:	e8 1f 94 ff ff       	call   c0100deb <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01079cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01079d3:	eb 1e                	jmp    c01079f3 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c01079d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079d8:	8b 04 85 00 11 1a c0 	mov    -0x3fe5ef00(,%eax,4),%eax
c01079df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01079e6:	00 
c01079e7:	89 04 24             	mov    %eax,(%esp)
c01079ea:	e8 ff d8 ff ff       	call   c01052ee <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01079ef:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01079f3:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01079f7:	7e dc                	jle    c01079d5 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c01079f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079fc:	8b 00                	mov    (%eax),%eax
c01079fe:	89 04 24             	mov    %eax,(%esp)
c0107a01:	e8 d6 f4 ff ff       	call   c0106edc <pde2page>
c0107a06:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a0d:	00 
c0107a0e:	89 04 24             	mov    %eax,(%esp)
c0107a11:	e8 d8 d8 ff ff       	call   c01052ee <free_pages>
     pgdir[0] = 0;
c0107a16:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107a19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c0107a1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a22:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0107a29:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a2c:	89 04 24             	mov    %eax,(%esp)
c0107a2f:	e8 b0 09 00 00       	call   c01083e4 <mm_destroy>
     check_mm_struct = NULL;
c0107a34:	c7 05 cc 11 1a c0 00 	movl   $0x0,0xc01a11cc
c0107a3b:	00 00 00 
     
     nr_free = nr_free_store;
c0107a3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107a41:	a3 d8 10 1a c0       	mov    %eax,0xc01a10d8
     free_list = free_list_store;
c0107a46:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107a49:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107a4c:	a3 d0 10 1a c0       	mov    %eax,0xc01a10d0
c0107a51:	89 15 d4 10 1a c0    	mov    %edx,0xc01a10d4

     
     le = &free_list;
c0107a57:	c7 45 e8 d0 10 1a c0 	movl   $0xc01a10d0,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107a5e:	eb 1d                	jmp    c0107a7d <check_swap+0x65a>
         struct Page *p = le2page(le, page_link);
c0107a60:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a63:	83 e8 0c             	sub    $0xc,%eax
c0107a66:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0107a69:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107a6d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107a70:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107a73:	8b 40 08             	mov    0x8(%eax),%eax
c0107a76:	29 c2                	sub    %eax,%edx
c0107a78:	89 d0                	mov    %edx,%eax
c0107a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a80:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107a83:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107a86:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0107a89:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107a8c:	81 7d e8 d0 10 1a c0 	cmpl   $0xc01a10d0,-0x18(%ebp)
c0107a93:	75 cb                	jne    c0107a60 <check_swap+0x63d>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0107a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a98:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107aa3:	c7 04 24 dd d8 10 c0 	movl   $0xc010d8dd,(%esp)
c0107aaa:	e8 b0 88 ff ff       	call   c010035f <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107aaf:	c7 04 24 f7 d8 10 c0 	movl   $0xc010d8f7,(%esp)
c0107ab6:	e8 a4 88 ff ff       	call   c010035f <cprintf>
}
c0107abb:	83 c4 74             	add    $0x74,%esp
c0107abe:	5b                   	pop    %ebx
c0107abf:	5d                   	pop    %ebp
c0107ac0:	c3                   	ret    

c0107ac1 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0107ac1:	55                   	push   %ebp
c0107ac2:	89 e5                	mov    %esp,%ebp
c0107ac4:	83 ec 10             	sub    $0x10,%esp
c0107ac7:	c7 45 fc c4 11 1a c0 	movl   $0xc01a11c4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107ace:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ad1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107ad4:	89 50 04             	mov    %edx,0x4(%eax)
c0107ad7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ada:	8b 50 04             	mov    0x4(%eax),%edx
c0107add:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ae0:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107ae2:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ae5:	c7 40 14 c4 11 1a c0 	movl   $0xc01a11c4,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107af1:	c9                   	leave  
c0107af2:	c3                   	ret    

c0107af3 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107af3:	55                   	push   %ebp
c0107af4:	89 e5                	mov    %esp,%ebp
c0107af6:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107af9:	8b 45 08             	mov    0x8(%ebp),%eax
c0107afc:	8b 40 14             	mov    0x14(%eax),%eax
c0107aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107b02:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b05:	83 c0 14             	add    $0x14,%eax
c0107b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107b0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107b0f:	74 06                	je     c0107b17 <_fifo_map_swappable+0x24>
c0107b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b15:	75 24                	jne    c0107b3b <_fifo_map_swappable+0x48>
c0107b17:	c7 44 24 0c 10 d9 10 	movl   $0xc010d910,0xc(%esp)
c0107b1e:	c0 
c0107b1f:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107b26:	c0 
c0107b27:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0107b2e:	00 
c0107b2f:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107b36:	e8 b0 92 ff ff       	call   c0100deb <__panic>
c0107b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b44:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107b47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107b4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b50:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0107b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b56:	8b 40 04             	mov    0x4(%eax),%eax
c0107b59:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107b5c:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107b5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107b62:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0107b65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0107b68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107b6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107b6e:	89 10                	mov    %edx,(%eax)
c0107b70:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107b73:	8b 10                	mov    (%eax),%edx
c0107b75:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107b78:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107b7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b7e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107b81:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107b84:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b87:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107b8a:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
	list_add(head, entry);
    return 0;
c0107b8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b91:	c9                   	leave  
c0107b92:	c3                   	ret    

c0107b93 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107b93:	55                   	push   %ebp
c0107b94:	89 e5                	mov    %esp,%ebp
c0107b96:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107b99:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b9c:	8b 40 14             	mov    0x14(%eax),%eax
c0107b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0107ba2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ba6:	75 24                	jne    c0107bcc <_fifo_swap_out_victim+0x39>
c0107ba8:	c7 44 24 0c 57 d9 10 	movl   $0xc010d957,0xc(%esp)
c0107baf:	c0 
c0107bb0:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107bb7:	c0 
c0107bb8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107bbf:	00 
c0107bc0:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107bc7:	e8 1f 92 ff ff       	call   c0100deb <__panic>
     assert(in_tick==0);
c0107bcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107bd0:	74 24                	je     c0107bf6 <_fifo_swap_out_victim+0x63>
c0107bd2:	c7 44 24 0c 64 d9 10 	movl   $0xc010d964,0xc(%esp)
c0107bd9:	c0 
c0107bda:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107be1:	c0 
c0107be2:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107be9:	00 
c0107bea:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107bf1:	e8 f5 91 ff ff       	call   c0100deb <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *le = head->prev;
c0107bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bf9:	8b 00                	mov    (%eax),%eax
c0107bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0107bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c01:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107c04:	75 24                	jne    c0107c2a <_fifo_swap_out_victim+0x97>
c0107c06:	c7 44 24 0c 6f d9 10 	movl   $0xc010d96f,0xc(%esp)
c0107c0d:	c0 
c0107c0e:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107c15:	c0 
c0107c16:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107c1d:	00 
c0107c1e:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107c25:	e8 c1 91 ff ff       	call   c0100deb <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0107c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c2d:	83 e8 14             	sub    $0x14,%eax
c0107c30:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c36:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c3c:	8b 40 04             	mov    0x4(%eax),%eax
c0107c3f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107c42:	8b 12                	mov    (%edx),%edx
c0107c44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107c47:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107c4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c4d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c50:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107c53:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107c59:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0107c5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107c5f:	75 24                	jne    c0107c85 <_fifo_swap_out_victim+0xf2>
c0107c61:	c7 44 24 0c 78 d9 10 	movl   $0xc010d978,0xc(%esp)
c0107c68:	c0 
c0107c69:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107c70:	c0 
c0107c71:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0107c78:	00 
c0107c79:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107c80:	e8 66 91 ff ff       	call   c0100deb <__panic>
     *ptr_page = p;
c0107c85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c88:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107c8b:	89 10                	mov    %edx,(%eax)
     return 0;
c0107c8d:	b8 00 00 00 00       	mov    $0x0,%eax
     return 0;
}
c0107c92:	c9                   	leave  
c0107c93:	c3                   	ret    

c0107c94 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107c94:	55                   	push   %ebp
c0107c95:	89 e5                	mov    %esp,%ebp
c0107c97:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107c9a:	c7 04 24 84 d9 10 c0 	movl   $0xc010d984,(%esp)
c0107ca1:	e8 b9 86 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107ca6:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107cab:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107cae:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107cb3:	83 f8 04             	cmp    $0x4,%eax
c0107cb6:	74 24                	je     c0107cdc <_fifo_check_swap+0x48>
c0107cb8:	c7 44 24 0c aa d9 10 	movl   $0xc010d9aa,0xc(%esp)
c0107cbf:	c0 
c0107cc0:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107cc7:	c0 
c0107cc8:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c0107ccf:	00 
c0107cd0:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107cd7:	e8 0f 91 ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107cdc:	c7 04 24 bc d9 10 c0 	movl   $0xc010d9bc,(%esp)
c0107ce3:	e8 77 86 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107ce8:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107ced:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107cf0:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107cf5:	83 f8 04             	cmp    $0x4,%eax
c0107cf8:	74 24                	je     c0107d1e <_fifo_check_swap+0x8a>
c0107cfa:	c7 44 24 0c aa d9 10 	movl   $0xc010d9aa,0xc(%esp)
c0107d01:	c0 
c0107d02:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107d09:	c0 
c0107d0a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c0107d11:	00 
c0107d12:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107d19:	e8 cd 90 ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107d1e:	c7 04 24 e4 d9 10 c0 	movl   $0xc010d9e4,(%esp)
c0107d25:	e8 35 86 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107d2a:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107d2f:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107d32:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107d37:	83 f8 04             	cmp    $0x4,%eax
c0107d3a:	74 24                	je     c0107d60 <_fifo_check_swap+0xcc>
c0107d3c:	c7 44 24 0c aa d9 10 	movl   $0xc010d9aa,0xc(%esp)
c0107d43:	c0 
c0107d44:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107d4b:	c0 
c0107d4c:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0107d53:	00 
c0107d54:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107d5b:	e8 8b 90 ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107d60:	c7 04 24 0c da 10 c0 	movl   $0xc010da0c,(%esp)
c0107d67:	e8 f3 85 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107d6c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107d71:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107d74:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107d79:	83 f8 04             	cmp    $0x4,%eax
c0107d7c:	74 24                	je     c0107da2 <_fifo_check_swap+0x10e>
c0107d7e:	c7 44 24 0c aa d9 10 	movl   $0xc010d9aa,0xc(%esp)
c0107d85:	c0 
c0107d86:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107d8d:	c0 
c0107d8e:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0107d95:	00 
c0107d96:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107d9d:	e8 49 90 ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107da2:	c7 04 24 34 da 10 c0 	movl   $0xc010da34,(%esp)
c0107da9:	e8 b1 85 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107dae:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107db3:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0107db6:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107dbb:	83 f8 05             	cmp    $0x5,%eax
c0107dbe:	74 24                	je     c0107de4 <_fifo_check_swap+0x150>
c0107dc0:	c7 44 24 0c 5a da 10 	movl   $0xc010da5a,0xc(%esp)
c0107dc7:	c0 
c0107dc8:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107dcf:	c0 
c0107dd0:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0107dd7:	00 
c0107dd8:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107ddf:	e8 07 90 ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107de4:	c7 04 24 0c da 10 c0 	movl   $0xc010da0c,(%esp)
c0107deb:	e8 6f 85 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107df0:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107df5:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107df8:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107dfd:	83 f8 05             	cmp    $0x5,%eax
c0107e00:	74 24                	je     c0107e26 <_fifo_check_swap+0x192>
c0107e02:	c7 44 24 0c 5a da 10 	movl   $0xc010da5a,0xc(%esp)
c0107e09:	c0 
c0107e0a:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107e11:	c0 
c0107e12:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0107e19:	00 
c0107e1a:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107e21:	e8 c5 8f ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107e26:	c7 04 24 bc d9 10 c0 	movl   $0xc010d9bc,(%esp)
c0107e2d:	e8 2d 85 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107e32:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e37:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107e3a:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107e3f:	83 f8 06             	cmp    $0x6,%eax
c0107e42:	74 24                	je     c0107e68 <_fifo_check_swap+0x1d4>
c0107e44:	c7 44 24 0c 69 da 10 	movl   $0xc010da69,0xc(%esp)
c0107e4b:	c0 
c0107e4c:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107e53:	c0 
c0107e54:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0107e5b:	00 
c0107e5c:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107e63:	e8 83 8f ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107e68:	c7 04 24 0c da 10 c0 	movl   $0xc010da0c,(%esp)
c0107e6f:	e8 eb 84 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107e74:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107e79:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107e7c:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107e81:	83 f8 07             	cmp    $0x7,%eax
c0107e84:	74 24                	je     c0107eaa <_fifo_check_swap+0x216>
c0107e86:	c7 44 24 0c 78 da 10 	movl   $0xc010da78,0xc(%esp)
c0107e8d:	c0 
c0107e8e:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107e95:	c0 
c0107e96:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0107e9d:	00 
c0107e9e:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107ea5:	e8 41 8f ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107eaa:	c7 04 24 84 d9 10 c0 	movl   $0xc010d984,(%esp)
c0107eb1:	e8 a9 84 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107eb6:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107ebb:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107ebe:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107ec3:	83 f8 08             	cmp    $0x8,%eax
c0107ec6:	74 24                	je     c0107eec <_fifo_check_swap+0x258>
c0107ec8:	c7 44 24 0c 87 da 10 	movl   $0xc010da87,0xc(%esp)
c0107ecf:	c0 
c0107ed0:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107ed7:	c0 
c0107ed8:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0107edf:	00 
c0107ee0:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107ee7:	e8 ff 8e ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107eec:	c7 04 24 e4 d9 10 c0 	movl   $0xc010d9e4,(%esp)
c0107ef3:	e8 67 84 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107ef8:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107efd:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107f00:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107f05:	83 f8 09             	cmp    $0x9,%eax
c0107f08:	74 24                	je     c0107f2e <_fifo_check_swap+0x29a>
c0107f0a:	c7 44 24 0c 96 da 10 	movl   $0xc010da96,0xc(%esp)
c0107f11:	c0 
c0107f12:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107f19:	c0 
c0107f1a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0107f21:	00 
c0107f22:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107f29:	e8 bd 8e ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107f2e:	c7 04 24 34 da 10 c0 	movl   $0xc010da34,(%esp)
c0107f35:	e8 25 84 ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107f3a:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107f3f:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107f42:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107f47:	83 f8 0a             	cmp    $0xa,%eax
c0107f4a:	74 24                	je     c0107f70 <_fifo_check_swap+0x2dc>
c0107f4c:	c7 44 24 0c a5 da 10 	movl   $0xc010daa5,0xc(%esp)
c0107f53:	c0 
c0107f54:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107f5b:	c0 
c0107f5c:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0107f63:	00 
c0107f64:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107f6b:	e8 7b 8e ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107f70:	c7 04 24 bc d9 10 c0 	movl   $0xc010d9bc,(%esp)
c0107f77:	e8 e3 83 ff ff       	call   c010035f <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107f7c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107f81:	0f b6 00             	movzbl (%eax),%eax
c0107f84:	3c 0a                	cmp    $0xa,%al
c0107f86:	74 24                	je     c0107fac <_fifo_check_swap+0x318>
c0107f88:	c7 44 24 0c b8 da 10 	movl   $0xc010dab8,0xc(%esp)
c0107f8f:	c0 
c0107f90:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107f97:	c0 
c0107f98:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c0107f9f:	00 
c0107fa0:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107fa7:	e8 3f 8e ff ff       	call   c0100deb <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107fac:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107fb1:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0107fb4:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0107fb9:	83 f8 0b             	cmp    $0xb,%eax
c0107fbc:	74 24                	je     c0107fe2 <_fifo_check_swap+0x34e>
c0107fbe:	c7 44 24 0c d9 da 10 	movl   $0xc010dad9,0xc(%esp)
c0107fc5:	c0 
c0107fc6:	c7 44 24 08 2e d9 10 	movl   $0xc010d92e,0x8(%esp)
c0107fcd:	c0 
c0107fce:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c0107fd5:	00 
c0107fd6:	c7 04 24 43 d9 10 c0 	movl   $0xc010d943,(%esp)
c0107fdd:	e8 09 8e ff ff       	call   c0100deb <__panic>
    return 0;
c0107fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107fe7:	c9                   	leave  
c0107fe8:	c3                   	ret    

c0107fe9 <_fifo_init>:


static int
_fifo_init(void)
{
c0107fe9:	55                   	push   %ebp
c0107fea:	89 e5                	mov    %esp,%ebp
    return 0;
c0107fec:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ff1:	5d                   	pop    %ebp
c0107ff2:	c3                   	ret    

c0107ff3 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107ff3:	55                   	push   %ebp
c0107ff4:	89 e5                	mov    %esp,%ebp
    return 0;
c0107ff6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ffb:	5d                   	pop    %ebp
c0107ffc:	c3                   	ret    

c0107ffd <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0107ffd:	55                   	push   %ebp
c0107ffe:	89 e5                	mov    %esp,%ebp
c0108000:	b8 00 00 00 00       	mov    $0x0,%eax
c0108005:	5d                   	pop    %ebp
c0108006:	c3                   	ret    

c0108007 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0108007:	55                   	push   %ebp
c0108008:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c010800a:	8b 45 08             	mov    0x8(%ebp),%eax
c010800d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c0108013:	5d                   	pop    %ebp
c0108014:	c3                   	ret    

c0108015 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0108015:	55                   	push   %ebp
c0108016:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0108018:	8b 45 08             	mov    0x8(%ebp),%eax
c010801b:	8b 40 18             	mov    0x18(%eax),%eax
}
c010801e:	5d                   	pop    %ebp
c010801f:	c3                   	ret    

c0108020 <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c0108020:	55                   	push   %ebp
c0108021:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c0108023:	8b 45 08             	mov    0x8(%ebp),%eax
c0108026:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108029:	89 50 18             	mov    %edx,0x18(%eax)
}
c010802c:	5d                   	pop    %ebp
c010802d:	c3                   	ret    

c010802e <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010802e:	55                   	push   %ebp
c010802f:	89 e5                	mov    %esp,%ebp
c0108031:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0108034:	8b 45 08             	mov    0x8(%ebp),%eax
c0108037:	c1 e8 0c             	shr    $0xc,%eax
c010803a:	89 c2                	mov    %eax,%edx
c010803c:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0108041:	39 c2                	cmp    %eax,%edx
c0108043:	72 1c                	jb     c0108061 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0108045:	c7 44 24 08 fc da 10 	movl   $0xc010dafc,0x8(%esp)
c010804c:	c0 
c010804d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0108054:	00 
c0108055:	c7 04 24 1b db 10 c0 	movl   $0xc010db1b,(%esp)
c010805c:	e8 8a 8d ff ff       	call   c0100deb <__panic>
    }
    return &pages[PPN(pa)];
c0108061:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0108066:	8b 55 08             	mov    0x8(%ebp),%edx
c0108069:	c1 ea 0c             	shr    $0xc,%edx
c010806c:	c1 e2 05             	shl    $0x5,%edx
c010806f:	01 d0                	add    %edx,%eax
}
c0108071:	c9                   	leave  
c0108072:	c3                   	ret    

c0108073 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0108073:	55                   	push   %ebp
c0108074:	89 e5                	mov    %esp,%ebp
c0108076:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0108079:	8b 45 08             	mov    0x8(%ebp),%eax
c010807c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108081:	89 04 24             	mov    %eax,(%esp)
c0108084:	e8 a5 ff ff ff       	call   c010802e <pa2page>
}
c0108089:	c9                   	leave  
c010808a:	c3                   	ret    

c010808b <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010808b:	55                   	push   %ebp
c010808c:	89 e5                	mov    %esp,%ebp
c010808e:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0108091:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108098:	e8 71 cd ff ff       	call   c0104e0e <kmalloc>
c010809d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01080a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01080a4:	74 79                	je     c010811f <mm_create+0x94>
        list_init(&(mm->mmap_list));
c01080a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01080ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080af:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01080b2:	89 50 04             	mov    %edx,0x4(%eax)
c01080b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080b8:	8b 50 04             	mov    0x4(%eax),%edx
c01080bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080be:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01080c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01080ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080cd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01080d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080d7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01080de:	a1 2c f0 19 c0       	mov    0xc019f02c,%eax
c01080e3:	85 c0                	test   %eax,%eax
c01080e5:	74 0d                	je     c01080f4 <mm_create+0x69>
c01080e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080ea:	89 04 24             	mov    %eax,(%esp)
c01080ed:	e8 92 ee ff ff       	call   c0106f84 <swap_init_mm>
c01080f2:	eb 0a                	jmp    c01080fe <mm_create+0x73>
        else mm->sm_priv = NULL;
c01080f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080f7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c01080fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108105:	00 
c0108106:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108109:	89 04 24             	mov    %eax,(%esp)
c010810c:	e8 0f ff ff ff       	call   c0108020 <set_mm_count>
        lock_init(&(mm->mm_lock));
c0108111:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108114:	83 c0 1c             	add    $0x1c,%eax
c0108117:	89 04 24             	mov    %eax,(%esp)
c010811a:	e8 e8 fe ff ff       	call   c0108007 <lock_init>
    }    
    return mm;
c010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108122:	c9                   	leave  
c0108123:	c3                   	ret    

c0108124 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0108124:	55                   	push   %ebp
c0108125:	89 e5                	mov    %esp,%ebp
c0108127:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c010812a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0108131:	e8 d8 cc ff ff       	call   c0104e0e <kmalloc>
c0108136:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0108139:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010813d:	74 1b                	je     c010815a <vma_create+0x36>
        vma->vm_start = vm_start;
c010813f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108142:	8b 55 08             	mov    0x8(%ebp),%edx
c0108145:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0108148:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010814b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010814e:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0108151:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108154:	8b 55 10             	mov    0x10(%ebp),%edx
c0108157:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010815a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010815d:	c9                   	leave  
c010815e:	c3                   	ret    

c010815f <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c010815f:	55                   	push   %ebp
c0108160:	89 e5                	mov    %esp,%ebp
c0108162:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0108165:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010816c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108170:	0f 84 95 00 00 00    	je     c010820b <find_vma+0xac>
        vma = mm->mmap_cache;
c0108176:	8b 45 08             	mov    0x8(%ebp),%eax
c0108179:	8b 40 08             	mov    0x8(%eax),%eax
c010817c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c010817f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108183:	74 16                	je     c010819b <find_vma+0x3c>
c0108185:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108188:	8b 40 04             	mov    0x4(%eax),%eax
c010818b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010818e:	77 0b                	ja     c010819b <find_vma+0x3c>
c0108190:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108193:	8b 40 08             	mov    0x8(%eax),%eax
c0108196:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108199:	77 61                	ja     c01081fc <find_vma+0x9d>
                bool found = 0;
c010819b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01081a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01081a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01081ae:	eb 28                	jmp    c01081d8 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01081b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081b3:	83 e8 10             	sub    $0x10,%eax
c01081b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01081b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01081bc:	8b 40 04             	mov    0x4(%eax),%eax
c01081bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01081c2:	77 14                	ja     c01081d8 <find_vma+0x79>
c01081c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01081c7:	8b 40 08             	mov    0x8(%eax),%eax
c01081ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01081cd:	76 09                	jbe    c01081d8 <find_vma+0x79>
                        found = 1;
c01081cf:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01081d6:	eb 17                	jmp    c01081ef <find_vma+0x90>
c01081d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081db:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01081de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081e1:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01081e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01081e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081ea:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01081ed:	75 c1                	jne    c01081b0 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01081ef:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01081f3:	75 07                	jne    c01081fc <find_vma+0x9d>
                    vma = NULL;
c01081f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01081fc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108200:	74 09                	je     c010820b <find_vma+0xac>
            mm->mmap_cache = vma;
c0108202:	8b 45 08             	mov    0x8(%ebp),%eax
c0108205:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108208:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c010820b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010820e:	c9                   	leave  
c010820f:	c3                   	ret    

c0108210 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0108210:	55                   	push   %ebp
c0108211:	89 e5                	mov    %esp,%ebp
c0108213:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0108216:	8b 45 08             	mov    0x8(%ebp),%eax
c0108219:	8b 50 04             	mov    0x4(%eax),%edx
c010821c:	8b 45 08             	mov    0x8(%ebp),%eax
c010821f:	8b 40 08             	mov    0x8(%eax),%eax
c0108222:	39 c2                	cmp    %eax,%edx
c0108224:	72 24                	jb     c010824a <check_vma_overlap+0x3a>
c0108226:	c7 44 24 0c 29 db 10 	movl   $0xc010db29,0xc(%esp)
c010822d:	c0 
c010822e:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108235:	c0 
c0108236:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c010823d:	00 
c010823e:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108245:	e8 a1 8b ff ff       	call   c0100deb <__panic>
    assert(prev->vm_end <= next->vm_start);
c010824a:	8b 45 08             	mov    0x8(%ebp),%eax
c010824d:	8b 50 08             	mov    0x8(%eax),%edx
c0108250:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108253:	8b 40 04             	mov    0x4(%eax),%eax
c0108256:	39 c2                	cmp    %eax,%edx
c0108258:	76 24                	jbe    c010827e <check_vma_overlap+0x6e>
c010825a:	c7 44 24 0c 6c db 10 	movl   $0xc010db6c,0xc(%esp)
c0108261:	c0 
c0108262:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108269:	c0 
c010826a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0108271:	00 
c0108272:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108279:	e8 6d 8b ff ff       	call   c0100deb <__panic>
    assert(next->vm_start < next->vm_end);
c010827e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108281:	8b 50 04             	mov    0x4(%eax),%edx
c0108284:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108287:	8b 40 08             	mov    0x8(%eax),%eax
c010828a:	39 c2                	cmp    %eax,%edx
c010828c:	72 24                	jb     c01082b2 <check_vma_overlap+0xa2>
c010828e:	c7 44 24 0c 8b db 10 	movl   $0xc010db8b,0xc(%esp)
c0108295:	c0 
c0108296:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c010829d:	c0 
c010829e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01082a5:	00 
c01082a6:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c01082ad:	e8 39 8b ff ff       	call   c0100deb <__panic>
}
c01082b2:	c9                   	leave  
c01082b3:	c3                   	ret    

c01082b4 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01082b4:	55                   	push   %ebp
c01082b5:	89 e5                	mov    %esp,%ebp
c01082b7:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c01082ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082bd:	8b 50 04             	mov    0x4(%eax),%edx
c01082c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082c3:	8b 40 08             	mov    0x8(%eax),%eax
c01082c6:	39 c2                	cmp    %eax,%edx
c01082c8:	72 24                	jb     c01082ee <insert_vma_struct+0x3a>
c01082ca:	c7 44 24 0c a9 db 10 	movl   $0xc010dba9,0xc(%esp)
c01082d1:	c0 
c01082d2:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c01082d9:	c0 
c01082da:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c01082e1:	00 
c01082e2:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c01082e9:	e8 fd 8a ff ff       	call   c0100deb <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01082ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01082f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01082f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01082fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0108300:	eb 21                	jmp    c0108323 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0108302:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108305:	83 e8 10             	sub    $0x10,%eax
c0108308:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c010830b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010830e:	8b 50 04             	mov    0x4(%eax),%edx
c0108311:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108314:	8b 40 04             	mov    0x4(%eax),%eax
c0108317:	39 c2                	cmp    %eax,%edx
c0108319:	76 02                	jbe    c010831d <insert_vma_struct+0x69>
                break;
c010831b:	eb 1d                	jmp    c010833a <insert_vma_struct+0x86>
            }
            le_prev = le;
c010831d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108320:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108323:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108326:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108329:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010832c:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c010832f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108332:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108335:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108338:	75 c8                	jne    c0108302 <insert_vma_struct+0x4e>
c010833a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010833d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108340:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108343:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0108346:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0108349:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010834c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010834f:	74 15                	je     c0108366 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0108351:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108354:	8d 50 f0             	lea    -0x10(%eax),%edx
c0108357:	8b 45 0c             	mov    0xc(%ebp),%eax
c010835a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010835e:	89 14 24             	mov    %edx,(%esp)
c0108361:	e8 aa fe ff ff       	call   c0108210 <check_vma_overlap>
    }
    if (le_next != list) {
c0108366:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108369:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010836c:	74 15                	je     c0108383 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010836e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108371:	83 e8 10             	sub    $0x10,%eax
c0108374:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108378:	8b 45 0c             	mov    0xc(%ebp),%eax
c010837b:	89 04 24             	mov    %eax,(%esp)
c010837e:	e8 8d fe ff ff       	call   c0108210 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0108383:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108386:	8b 55 08             	mov    0x8(%ebp),%edx
c0108389:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010838b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010838e:	8d 50 10             	lea    0x10(%eax),%edx
c0108391:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108394:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108397:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010839a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010839d:	8b 40 04             	mov    0x4(%eax),%eax
c01083a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01083a3:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01083a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01083a9:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01083ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01083af:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01083b2:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01083b5:	89 10                	mov    %edx,(%eax)
c01083b7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01083ba:	8b 10                	mov    (%eax),%edx
c01083bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01083bf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01083c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01083c5:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01083c8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01083cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01083ce:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01083d1:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01083d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01083d6:	8b 40 10             	mov    0x10(%eax),%eax
c01083d9:	8d 50 01             	lea    0x1(%eax),%edx
c01083dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01083df:	89 50 10             	mov    %edx,0x10(%eax)
}
c01083e2:	c9                   	leave  
c01083e3:	c3                   	ret    

c01083e4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01083e4:	55                   	push   %ebp
c01083e5:	89 e5                	mov    %esp,%ebp
c01083e7:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c01083ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ed:	89 04 24             	mov    %eax,(%esp)
c01083f0:	e8 20 fc ff ff       	call   c0108015 <mm_count>
c01083f5:	85 c0                	test   %eax,%eax
c01083f7:	74 24                	je     c010841d <mm_destroy+0x39>
c01083f9:	c7 44 24 0c c5 db 10 	movl   $0xc010dbc5,0xc(%esp)
c0108400:	c0 
c0108401:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108408:	c0 
c0108409:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0108410:	00 
c0108411:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108418:	e8 ce 89 ff ff       	call   c0100deb <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c010841d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108420:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0108423:	eb 36                	jmp    c010845b <mm_destroy+0x77>
c0108425:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108428:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010842b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010842e:	8b 40 04             	mov    0x4(%eax),%eax
c0108431:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108434:	8b 12                	mov    (%edx),%edx
c0108436:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010843c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010843f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108442:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108448:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010844b:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c010844d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108450:	83 e8 10             	sub    $0x10,%eax
c0108453:	89 04 24             	mov    %eax,(%esp)
c0108456:	e8 ce c9 ff ff       	call   c0104e29 <kfree>
c010845b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010845e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108461:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108464:	8b 40 04             	mov    0x4(%eax),%eax
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0108467:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010846a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010846d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108470:	75 b3                	jne    c0108425 <mm_destroy+0x41>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c0108472:	8b 45 08             	mov    0x8(%ebp),%eax
c0108475:	89 04 24             	mov    %eax,(%esp)
c0108478:	e8 ac c9 ff ff       	call   c0104e29 <kfree>
    mm=NULL;
c010847d:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0108484:	c9                   	leave  
c0108485:	c3                   	ret    

c0108486 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c0108486:	55                   	push   %ebp
c0108487:	89 e5                	mov    %esp,%ebp
c0108489:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c010848c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010848f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108492:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108495:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010849a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010849d:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c01084a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01084a7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01084aa:	01 c2                	add    %eax,%edx
c01084ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084af:	01 d0                	add    %edx,%eax
c01084b1:	83 e8 01             	sub    $0x1,%eax
c01084b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01084b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01084ba:	ba 00 00 00 00       	mov    $0x0,%edx
c01084bf:	f7 75 e8             	divl   -0x18(%ebp)
c01084c2:	89 d0                	mov    %edx,%eax
c01084c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01084c7:	29 c2                	sub    %eax,%edx
c01084c9:	89 d0                	mov    %edx,%eax
c01084cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c01084ce:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c01084d5:	76 11                	jbe    c01084e8 <mm_map+0x62>
c01084d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084da:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01084dd:	73 09                	jae    c01084e8 <mm_map+0x62>
c01084df:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c01084e6:	76 0a                	jbe    c01084f2 <mm_map+0x6c>
        return -E_INVAL;
c01084e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01084ed:	e9 ae 00 00 00       	jmp    c01085a0 <mm_map+0x11a>
    }

    assert(mm != NULL);
c01084f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01084f6:	75 24                	jne    c010851c <mm_map+0x96>
c01084f8:	c7 44 24 0c d7 db 10 	movl   $0xc010dbd7,0xc(%esp)
c01084ff:	c0 
c0108500:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108507:	c0 
c0108508:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c010850f:	00 
c0108510:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108517:	e8 cf 88 ff ff       	call   c0100deb <__panic>

    int ret = -E_INVAL;
c010851c:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c0108523:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108526:	89 44 24 04          	mov    %eax,0x4(%esp)
c010852a:	8b 45 08             	mov    0x8(%ebp),%eax
c010852d:	89 04 24             	mov    %eax,(%esp)
c0108530:	e8 2a fc ff ff       	call   c010815f <find_vma>
c0108535:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108538:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010853c:	74 0d                	je     c010854b <mm_map+0xc5>
c010853e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108541:	8b 40 04             	mov    0x4(%eax),%eax
c0108544:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108547:	73 02                	jae    c010854b <mm_map+0xc5>
        goto out;
c0108549:	eb 52                	jmp    c010859d <mm_map+0x117>
    }
    ret = -E_NO_MEM;
c010854b:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c0108552:	8b 45 14             	mov    0x14(%ebp),%eax
c0108555:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108559:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010855c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108560:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108563:	89 04 24             	mov    %eax,(%esp)
c0108566:	e8 b9 fb ff ff       	call   c0108124 <vma_create>
c010856b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010856e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108572:	75 02                	jne    c0108576 <mm_map+0xf0>
        goto out;
c0108574:	eb 27                	jmp    c010859d <mm_map+0x117>
    }
    insert_vma_struct(mm, vma);
c0108576:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108579:	89 44 24 04          	mov    %eax,0x4(%esp)
c010857d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108580:	89 04 24             	mov    %eax,(%esp)
c0108583:	e8 2c fd ff ff       	call   c01082b4 <insert_vma_struct>
    if (vma_store != NULL) {
c0108588:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010858c:	74 08                	je     c0108596 <mm_map+0x110>
        *vma_store = vma;
c010858e:	8b 45 18             	mov    0x18(%ebp),%eax
c0108591:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108594:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0108596:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

out:
    return ret;
c010859d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01085a0:	c9                   	leave  
c01085a1:	c3                   	ret    

c01085a2 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c01085a2:	55                   	push   %ebp
c01085a3:	89 e5                	mov    %esp,%ebp
c01085a5:	56                   	push   %esi
c01085a6:	53                   	push   %ebx
c01085a7:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c01085aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01085ae:	74 06                	je     c01085b6 <dup_mmap+0x14>
c01085b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01085b4:	75 24                	jne    c01085da <dup_mmap+0x38>
c01085b6:	c7 44 24 0c e2 db 10 	movl   $0xc010dbe2,0xc(%esp)
c01085bd:	c0 
c01085be:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c01085c5:	c0 
c01085c6:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c01085cd:	00 
c01085ce:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c01085d5:	e8 11 88 ff ff       	call   c0100deb <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c01085da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c01085e6:	e9 92 00 00 00       	jmp    c010867d <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c01085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085ee:	83 e8 10             	sub    $0x10,%eax
c01085f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c01085f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085f7:	8b 48 0c             	mov    0xc(%eax),%ecx
c01085fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085fd:	8b 50 08             	mov    0x8(%eax),%edx
c0108600:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108603:	8b 40 04             	mov    0x4(%eax),%eax
c0108606:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010860a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010860e:	89 04 24             	mov    %eax,(%esp)
c0108611:	e8 0e fb ff ff       	call   c0108124 <vma_create>
c0108616:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0108619:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010861d:	75 07                	jne    c0108626 <dup_mmap+0x84>
            return -E_NO_MEM;
c010861f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0108624:	eb 76                	jmp    c010869c <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c0108626:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108629:	89 44 24 04          	mov    %eax,0x4(%esp)
c010862d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108630:	89 04 24             	mov    %eax,(%esp)
c0108633:	e8 7c fc ff ff       	call   c01082b4 <insert_vma_struct>

        bool share = 0;
c0108638:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c010863f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108642:	8b 58 08             	mov    0x8(%eax),%ebx
c0108645:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108648:	8b 48 04             	mov    0x4(%eax),%ecx
c010864b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010864e:	8b 50 0c             	mov    0xc(%eax),%edx
c0108651:	8b 45 08             	mov    0x8(%ebp),%eax
c0108654:	8b 40 0c             	mov    0xc(%eax),%eax
c0108657:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c010865a:	89 74 24 10          	mov    %esi,0x10(%esp)
c010865e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108662:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108666:	89 54 24 04          	mov    %edx,0x4(%esp)
c010866a:	89 04 24             	mov    %eax,(%esp)
c010866d:	e8 e2 d6 ff ff       	call   c0105d54 <copy_range>
c0108672:	85 c0                	test   %eax,%eax
c0108674:	74 07                	je     c010867d <dup_mmap+0xdb>
            return -E_NO_MEM;
c0108676:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010867b:	eb 1f                	jmp    c010869c <dup_mmap+0xfa>
c010867d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108680:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0108683:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108686:	8b 00                	mov    (%eax),%eax

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
c0108688:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010868b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010868e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108691:	0f 85 54 ff ff ff    	jne    c01085eb <dup_mmap+0x49>
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
c0108697:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010869c:	83 c4 40             	add    $0x40,%esp
c010869f:	5b                   	pop    %ebx
c01086a0:	5e                   	pop    %esi
c01086a1:	5d                   	pop    %ebp
c01086a2:	c3                   	ret    

c01086a3 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c01086a3:	55                   	push   %ebp
c01086a4:	89 e5                	mov    %esp,%ebp
c01086a6:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c01086a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01086ad:	74 0f                	je     c01086be <exit_mmap+0x1b>
c01086af:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b2:	89 04 24             	mov    %eax,(%esp)
c01086b5:	e8 5b f9 ff ff       	call   c0108015 <mm_count>
c01086ba:	85 c0                	test   %eax,%eax
c01086bc:	74 24                	je     c01086e2 <exit_mmap+0x3f>
c01086be:	c7 44 24 0c 00 dc 10 	movl   $0xc010dc00,0xc(%esp)
c01086c5:	c0 
c01086c6:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c01086cd:	c0 
c01086ce:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01086d5:	00 
c01086d6:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c01086dd:	e8 09 87 ff ff       	call   c0100deb <__panic>
    pde_t *pgdir = mm->pgdir;
c01086e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01086e5:	8b 40 0c             	mov    0xc(%eax),%eax
c01086e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c01086eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01086f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c01086f7:	eb 28                	jmp    c0108721 <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c01086f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086fc:	83 e8 10             	sub    $0x10,%eax
c01086ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0108702:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108705:	8b 50 08             	mov    0x8(%eax),%edx
c0108708:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010870b:	8b 40 04             	mov    0x4(%eax),%eax
c010870e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108712:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108716:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108719:	89 04 24             	mov    %eax,(%esp)
c010871c:	e8 38 d4 ff ff       	call   c0105b59 <unmap_range>
c0108721:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108724:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108727:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010872a:	8b 40 04             	mov    0x4(%eax),%eax
void
exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
c010872d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108730:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108733:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108736:	75 c1                	jne    c01086f9 <exit_mmap+0x56>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c0108738:	eb 28                	jmp    c0108762 <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c010873a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010873d:	83 e8 10             	sub    $0x10,%eax
c0108740:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0108743:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108746:	8b 50 08             	mov    0x8(%eax),%edx
c0108749:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010874c:	8b 40 04             	mov    0x4(%eax),%eax
c010874f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108753:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108757:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010875a:	89 04 24             	mov    %eax,(%esp)
c010875d:	e8 eb d4 ff ff       	call   c0105c4d <exit_range>
c0108762:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108765:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108768:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010876b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c010876e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108771:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108774:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108777:	75 c1                	jne    c010873a <exit_mmap+0x97>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}
c0108779:	c9                   	leave  
c010877a:	c3                   	ret    

c010877b <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c010877b:	55                   	push   %ebp
c010877c:	89 e5                	mov    %esp,%ebp
c010877e:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0108781:	8b 45 10             	mov    0x10(%ebp),%eax
c0108784:	8b 55 18             	mov    0x18(%ebp),%edx
c0108787:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010878b:	8b 55 14             	mov    0x14(%ebp),%edx
c010878e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108792:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108796:	8b 45 08             	mov    0x8(%ebp),%eax
c0108799:	89 04 24             	mov    %eax,(%esp)
c010879c:	e8 a6 09 00 00       	call   c0109147 <user_mem_check>
c01087a1:	85 c0                	test   %eax,%eax
c01087a3:	75 07                	jne    c01087ac <copy_from_user+0x31>
        return 0;
c01087a5:	b8 00 00 00 00       	mov    $0x0,%eax
c01087aa:	eb 1e                	jmp    c01087ca <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c01087ac:	8b 45 14             	mov    0x14(%ebp),%eax
c01087af:	89 44 24 08          	mov    %eax,0x8(%esp)
c01087b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01087b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087bd:	89 04 24             	mov    %eax,(%esp)
c01087c0:	e8 76 37 00 00       	call   c010bf3b <memcpy>
    return 1;
c01087c5:	b8 01 00 00 00       	mov    $0x1,%eax
}
c01087ca:	c9                   	leave  
c01087cb:	c3                   	ret    

c01087cc <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c01087cc:	55                   	push   %ebp
c01087cd:	89 e5                	mov    %esp,%ebp
c01087cf:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c01087d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087d5:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01087dc:	00 
c01087dd:	8b 55 14             	mov    0x14(%ebp),%edx
c01087e0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01087e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01087eb:	89 04 24             	mov    %eax,(%esp)
c01087ee:	e8 54 09 00 00       	call   c0109147 <user_mem_check>
c01087f3:	85 c0                	test   %eax,%eax
c01087f5:	75 07                	jne    c01087fe <copy_to_user+0x32>
        return 0;
c01087f7:	b8 00 00 00 00       	mov    $0x0,%eax
c01087fc:	eb 1e                	jmp    c010881c <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c01087fe:	8b 45 14             	mov    0x14(%ebp),%eax
c0108801:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108805:	8b 45 10             	mov    0x10(%ebp),%eax
c0108808:	89 44 24 04          	mov    %eax,0x4(%esp)
c010880c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010880f:	89 04 24             	mov    %eax,(%esp)
c0108812:	e8 24 37 00 00       	call   c010bf3b <memcpy>
    return 1;
c0108817:	b8 01 00 00 00       	mov    $0x1,%eax
}
c010881c:	c9                   	leave  
c010881d:	c3                   	ret    

c010881e <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c010881e:	55                   	push   %ebp
c010881f:	89 e5                	mov    %esp,%ebp
c0108821:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0108824:	e8 02 00 00 00       	call   c010882b <check_vmm>
}
c0108829:	c9                   	leave  
c010882a:	c3                   	ret    

c010882b <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010882b:	55                   	push   %ebp
c010882c:	89 e5                	mov    %esp,%ebp
c010882e:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108831:	e8 ea ca ff ff       	call   c0105320 <nr_free_pages>
c0108836:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0108839:	e8 13 00 00 00       	call   c0108851 <check_vma_struct>
    check_pgfault();
c010883e:	e8 a7 04 00 00       	call   c0108cea <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0108843:	c7 04 24 20 dc 10 c0 	movl   $0xc010dc20,(%esp)
c010884a:	e8 10 7b ff ff       	call   c010035f <cprintf>
}
c010884f:	c9                   	leave  
c0108850:	c3                   	ret    

c0108851 <check_vma_struct>:

static void
check_vma_struct(void) {
c0108851:	55                   	push   %ebp
c0108852:	89 e5                	mov    %esp,%ebp
c0108854:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108857:	e8 c4 ca ff ff       	call   c0105320 <nr_free_pages>
c010885c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c010885f:	e8 27 f8 ff ff       	call   c010808b <mm_create>
c0108864:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0108867:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010886b:	75 24                	jne    c0108891 <check_vma_struct+0x40>
c010886d:	c7 44 24 0c d7 db 10 	movl   $0xc010dbd7,0xc(%esp)
c0108874:	c0 
c0108875:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c010887c:	c0 
c010887d:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0108884:	00 
c0108885:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c010888c:	e8 5a 85 ff ff       	call   c0100deb <__panic>

    int step1 = 10, step2 = step1 * 10;
c0108891:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108898:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010889b:	89 d0                	mov    %edx,%eax
c010889d:	c1 e0 02             	shl    $0x2,%eax
c01088a0:	01 d0                	add    %edx,%eax
c01088a2:	01 c0                	add    %eax,%eax
c01088a4:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c01088a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088ad:	eb 70                	jmp    c010891f <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01088af:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088b2:	89 d0                	mov    %edx,%eax
c01088b4:	c1 e0 02             	shl    $0x2,%eax
c01088b7:	01 d0                	add    %edx,%eax
c01088b9:	83 c0 02             	add    $0x2,%eax
c01088bc:	89 c1                	mov    %eax,%ecx
c01088be:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088c1:	89 d0                	mov    %edx,%eax
c01088c3:	c1 e0 02             	shl    $0x2,%eax
c01088c6:	01 d0                	add    %edx,%eax
c01088c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01088cf:	00 
c01088d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01088d4:	89 04 24             	mov    %eax,(%esp)
c01088d7:	e8 48 f8 ff ff       	call   c0108124 <vma_create>
c01088dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c01088df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01088e3:	75 24                	jne    c0108909 <check_vma_struct+0xb8>
c01088e5:	c7 44 24 0c 38 dc 10 	movl   $0xc010dc38,0xc(%esp)
c01088ec:	c0 
c01088ed:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c01088f4:	c0 
c01088f5:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01088fc:	00 
c01088fd:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108904:	e8 e2 84 ff ff       	call   c0100deb <__panic>
        insert_vma_struct(mm, vma);
c0108909:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010890c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108910:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108913:	89 04 24             	mov    %eax,(%esp)
c0108916:	e8 99 f9 ff ff       	call   c01082b4 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c010891b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010891f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108923:	7f 8a                	jg     c01088af <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0108925:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108928:	83 c0 01             	add    $0x1,%eax
c010892b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010892e:	eb 70                	jmp    c01089a0 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108930:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108933:	89 d0                	mov    %edx,%eax
c0108935:	c1 e0 02             	shl    $0x2,%eax
c0108938:	01 d0                	add    %edx,%eax
c010893a:	83 c0 02             	add    $0x2,%eax
c010893d:	89 c1                	mov    %eax,%ecx
c010893f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108942:	89 d0                	mov    %edx,%eax
c0108944:	c1 e0 02             	shl    $0x2,%eax
c0108947:	01 d0                	add    %edx,%eax
c0108949:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108950:	00 
c0108951:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108955:	89 04 24             	mov    %eax,(%esp)
c0108958:	e8 c7 f7 ff ff       	call   c0108124 <vma_create>
c010895d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0108960:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0108964:	75 24                	jne    c010898a <check_vma_struct+0x139>
c0108966:	c7 44 24 0c 38 dc 10 	movl   $0xc010dc38,0xc(%esp)
c010896d:	c0 
c010896e:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108975:	c0 
c0108976:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c010897d:	00 
c010897e:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108985:	e8 61 84 ff ff       	call   c0100deb <__panic>
        insert_vma_struct(mm, vma);
c010898a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010898d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108991:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108994:	89 04 24             	mov    %eax,(%esp)
c0108997:	e8 18 f9 ff ff       	call   c01082b4 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c010899c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01089a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089a3:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01089a6:	7e 88                	jle    c0108930 <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01089a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089ab:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01089ae:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01089b1:	8b 40 04             	mov    0x4(%eax),%eax
c01089b4:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01089b7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c01089be:	e9 97 00 00 00       	jmp    c0108a5a <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c01089c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01089c9:	75 24                	jne    c01089ef <check_vma_struct+0x19e>
c01089cb:	c7 44 24 0c 44 dc 10 	movl   $0xc010dc44,0xc(%esp)
c01089d2:	c0 
c01089d3:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c01089da:	c0 
c01089db:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c01089e2:	00 
c01089e3:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c01089ea:	e8 fc 83 ff ff       	call   c0100deb <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01089ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089f2:	83 e8 10             	sub    $0x10,%eax
c01089f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01089f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01089fb:	8b 48 04             	mov    0x4(%eax),%ecx
c01089fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a01:	89 d0                	mov    %edx,%eax
c0108a03:	c1 e0 02             	shl    $0x2,%eax
c0108a06:	01 d0                	add    %edx,%eax
c0108a08:	39 c1                	cmp    %eax,%ecx
c0108a0a:	75 17                	jne    c0108a23 <check_vma_struct+0x1d2>
c0108a0c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108a0f:	8b 48 08             	mov    0x8(%eax),%ecx
c0108a12:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a15:	89 d0                	mov    %edx,%eax
c0108a17:	c1 e0 02             	shl    $0x2,%eax
c0108a1a:	01 d0                	add    %edx,%eax
c0108a1c:	83 c0 02             	add    $0x2,%eax
c0108a1f:	39 c1                	cmp    %eax,%ecx
c0108a21:	74 24                	je     c0108a47 <check_vma_struct+0x1f6>
c0108a23:	c7 44 24 0c 5c dc 10 	movl   $0xc010dc5c,0xc(%esp)
c0108a2a:	c0 
c0108a2b:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108a32:	c0 
c0108a33:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0108a3a:	00 
c0108a3b:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108a42:	e8 a4 83 ff ff       	call   c0100deb <__panic>
c0108a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a4a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0108a4d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108a50:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0108a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0108a56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a5d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108a60:	0f 8e 5d ff ff ff    	jle    c01089c3 <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108a66:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0108a6d:	e9 cd 01 00 00       	jmp    c0108c3f <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0108a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a79:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a7c:	89 04 24             	mov    %eax,(%esp)
c0108a7f:	e8 db f6 ff ff       	call   c010815f <find_vma>
c0108a84:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0108a87:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0108a8b:	75 24                	jne    c0108ab1 <check_vma_struct+0x260>
c0108a8d:	c7 44 24 0c 91 dc 10 	movl   $0xc010dc91,0xc(%esp)
c0108a94:	c0 
c0108a95:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108a9c:	c0 
c0108a9d:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0108aa4:	00 
c0108aa5:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108aac:	e8 3a 83 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0108ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ab4:	83 c0 01             	add    $0x1,%eax
c0108ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108abb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108abe:	89 04 24             	mov    %eax,(%esp)
c0108ac1:	e8 99 f6 ff ff       	call   c010815f <find_vma>
c0108ac6:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0108ac9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108acd:	75 24                	jne    c0108af3 <check_vma_struct+0x2a2>
c0108acf:	c7 44 24 0c 9e dc 10 	movl   $0xc010dc9e,0xc(%esp)
c0108ad6:	c0 
c0108ad7:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108ade:	c0 
c0108adf:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0108ae6:	00 
c0108ae7:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108aee:	e8 f8 82 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0108af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108af6:	83 c0 02             	add    $0x2,%eax
c0108af9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108afd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b00:	89 04 24             	mov    %eax,(%esp)
c0108b03:	e8 57 f6 ff ff       	call   c010815f <find_vma>
c0108b08:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0108b0b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108b0f:	74 24                	je     c0108b35 <check_vma_struct+0x2e4>
c0108b11:	c7 44 24 0c ab dc 10 	movl   $0xc010dcab,0xc(%esp)
c0108b18:	c0 
c0108b19:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108b20:	c0 
c0108b21:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0108b28:	00 
c0108b29:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108b30:	e8 b6 82 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0108b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b38:	83 c0 03             	add    $0x3,%eax
c0108b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b42:	89 04 24             	mov    %eax,(%esp)
c0108b45:	e8 15 f6 ff ff       	call   c010815f <find_vma>
c0108b4a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0108b4d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0108b51:	74 24                	je     c0108b77 <check_vma_struct+0x326>
c0108b53:	c7 44 24 0c b8 dc 10 	movl   $0xc010dcb8,0xc(%esp)
c0108b5a:	c0 
c0108b5b:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108b62:	c0 
c0108b63:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0108b6a:	00 
c0108b6b:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108b72:	e8 74 82 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0108b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b7a:	83 c0 04             	add    $0x4,%eax
c0108b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b84:	89 04 24             	mov    %eax,(%esp)
c0108b87:	e8 d3 f5 ff ff       	call   c010815f <find_vma>
c0108b8c:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0108b8f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0108b93:	74 24                	je     c0108bb9 <check_vma_struct+0x368>
c0108b95:	c7 44 24 0c c5 dc 10 	movl   $0xc010dcc5,0xc(%esp)
c0108b9c:	c0 
c0108b9d:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108ba4:	c0 
c0108ba5:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0108bac:	00 
c0108bad:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108bb4:	e8 32 82 ff ff       	call   c0100deb <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108bb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108bbc:	8b 50 04             	mov    0x4(%eax),%edx
c0108bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bc2:	39 c2                	cmp    %eax,%edx
c0108bc4:	75 10                	jne    c0108bd6 <check_vma_struct+0x385>
c0108bc6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108bc9:	8b 50 08             	mov    0x8(%eax),%edx
c0108bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bcf:	83 c0 02             	add    $0x2,%eax
c0108bd2:	39 c2                	cmp    %eax,%edx
c0108bd4:	74 24                	je     c0108bfa <check_vma_struct+0x3a9>
c0108bd6:	c7 44 24 0c d4 dc 10 	movl   $0xc010dcd4,0xc(%esp)
c0108bdd:	c0 
c0108bde:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108be5:	c0 
c0108be6:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0108bed:	00 
c0108bee:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108bf5:	e8 f1 81 ff ff       	call   c0100deb <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0108bfa:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108bfd:	8b 50 04             	mov    0x4(%eax),%edx
c0108c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c03:	39 c2                	cmp    %eax,%edx
c0108c05:	75 10                	jne    c0108c17 <check_vma_struct+0x3c6>
c0108c07:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108c0a:	8b 50 08             	mov    0x8(%eax),%edx
c0108c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c10:	83 c0 02             	add    $0x2,%eax
c0108c13:	39 c2                	cmp    %eax,%edx
c0108c15:	74 24                	je     c0108c3b <check_vma_struct+0x3ea>
c0108c17:	c7 44 24 0c 04 dd 10 	movl   $0xc010dd04,0xc(%esp)
c0108c1e:	c0 
c0108c1f:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108c26:	c0 
c0108c27:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108c2e:	00 
c0108c2f:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108c36:	e8 b0 81 ff ff       	call   c0100deb <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108c3b:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0108c3f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108c42:	89 d0                	mov    %edx,%eax
c0108c44:	c1 e0 02             	shl    $0x2,%eax
c0108c47:	01 d0                	add    %edx,%eax
c0108c49:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108c4c:	0f 8d 20 fe ff ff    	jge    c0108a72 <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108c52:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108c59:	eb 70                	jmp    c0108ccb <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0108c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c62:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c65:	89 04 24             	mov    %eax,(%esp)
c0108c68:	e8 f2 f4 ff ff       	call   c010815f <find_vma>
c0108c6d:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0108c70:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108c74:	74 27                	je     c0108c9d <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0108c76:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108c79:	8b 50 08             	mov    0x8(%eax),%edx
c0108c7c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108c7f:	8b 40 04             	mov    0x4(%eax),%eax
c0108c82:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108c86:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c91:	c7 04 24 34 dd 10 c0 	movl   $0xc010dd34,(%esp)
c0108c98:	e8 c2 76 ff ff       	call   c010035f <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108c9d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108ca1:	74 24                	je     c0108cc7 <check_vma_struct+0x476>
c0108ca3:	c7 44 24 0c 59 dd 10 	movl   $0xc010dd59,0xc(%esp)
c0108caa:	c0 
c0108cab:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108cb2:	c0 
c0108cb3:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108cba:	00 
c0108cbb:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108cc2:	e8 24 81 ff ff       	call   c0100deb <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108cc7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108ccb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108ccf:	79 8a                	jns    c0108c5b <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0108cd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cd4:	89 04 24             	mov    %eax,(%esp)
c0108cd7:	e8 08 f7 ff ff       	call   c01083e4 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108cdc:	c7 04 24 70 dd 10 c0 	movl   $0xc010dd70,(%esp)
c0108ce3:	e8 77 76 ff ff       	call   c010035f <cprintf>
}
c0108ce8:	c9                   	leave  
c0108ce9:	c3                   	ret    

c0108cea <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108cea:	55                   	push   %ebp
c0108ceb:	89 e5                	mov    %esp,%ebp
c0108ced:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108cf0:	e8 2b c6 ff ff       	call   c0105320 <nr_free_pages>
c0108cf5:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108cf8:	e8 8e f3 ff ff       	call   c010808b <mm_create>
c0108cfd:	a3 cc 11 1a c0       	mov    %eax,0xc01a11cc
    assert(check_mm_struct != NULL);
c0108d02:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c0108d07:	85 c0                	test   %eax,%eax
c0108d09:	75 24                	jne    c0108d2f <check_pgfault+0x45>
c0108d0b:	c7 44 24 0c 8f dd 10 	movl   $0xc010dd8f,0xc(%esp)
c0108d12:	c0 
c0108d13:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108d1a:	c0 
c0108d1b:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0108d22:	00 
c0108d23:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108d2a:	e8 bc 80 ff ff       	call   c0100deb <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108d2f:	a1 cc 11 1a c0       	mov    0xc01a11cc,%eax
c0108d34:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108d37:	8b 15 00 aa 12 c0    	mov    0xc012aa00,%edx
c0108d3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d40:	89 50 0c             	mov    %edx,0xc(%eax)
c0108d43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d46:	8b 40 0c             	mov    0xc(%eax),%eax
c0108d49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0108d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d4f:	8b 00                	mov    (%eax),%eax
c0108d51:	85 c0                	test   %eax,%eax
c0108d53:	74 24                	je     c0108d79 <check_pgfault+0x8f>
c0108d55:	c7 44 24 0c a7 dd 10 	movl   $0xc010dda7,0xc(%esp)
c0108d5c:	c0 
c0108d5d:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108d64:	c0 
c0108d65:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0108d6c:	00 
c0108d6d:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108d74:	e8 72 80 ff ff       	call   c0100deb <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108d79:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108d80:	00 
c0108d81:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108d88:	00 
c0108d89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108d90:	e8 8f f3 ff ff       	call   c0108124 <vma_create>
c0108d95:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108d98:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108d9c:	75 24                	jne    c0108dc2 <check_pgfault+0xd8>
c0108d9e:	c7 44 24 0c 38 dc 10 	movl   $0xc010dc38,0xc(%esp)
c0108da5:	c0 
c0108da6:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108dad:	c0 
c0108dae:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0108db5:	00 
c0108db6:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108dbd:	e8 29 80 ff ff       	call   c0100deb <__panic>

    insert_vma_struct(mm, vma);
c0108dc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108dc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108dcc:	89 04 24             	mov    %eax,(%esp)
c0108dcf:	e8 e0 f4 ff ff       	call   c01082b4 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108dd4:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108ddb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108dde:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108de2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108de5:	89 04 24             	mov    %eax,(%esp)
c0108de8:	e8 72 f3 ff ff       	call   c010815f <find_vma>
c0108ded:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108df0:	74 24                	je     c0108e16 <check_pgfault+0x12c>
c0108df2:	c7 44 24 0c b5 dd 10 	movl   $0xc010ddb5,0xc(%esp)
c0108df9:	c0 
c0108dfa:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108e01:	c0 
c0108e02:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0108e09:	00 
c0108e0a:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108e11:	e8 d5 7f ff ff       	call   c0100deb <__panic>

    int i, sum = 0;
c0108e16:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108e1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108e24:	eb 17                	jmp    c0108e3d <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0108e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e2c:	01 d0                	add    %edx,%eax
c0108e2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108e31:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e36:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0108e39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108e3d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108e41:	7e e3                	jle    c0108e26 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108e43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108e4a:	eb 15                	jmp    c0108e61 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0108e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e52:	01 d0                	add    %edx,%eax
c0108e54:	0f b6 00             	movzbl (%eax),%eax
c0108e57:	0f be c0             	movsbl %al,%eax
c0108e5a:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108e5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108e61:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108e65:	7e e5                	jle    c0108e4c <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0108e67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108e6b:	74 24                	je     c0108e91 <check_pgfault+0x1a7>
c0108e6d:	c7 44 24 0c cf dd 10 	movl   $0xc010ddcf,0xc(%esp)
c0108e74:	c0 
c0108e75:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108e7c:	c0 
c0108e7d:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0108e84:	00 
c0108e85:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108e8c:	e8 5a 7f ff ff       	call   c0100deb <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0108e91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e94:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108e97:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108e9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ea3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ea6:	89 04 24             	mov    %eax,(%esp)
c0108ea9:	e8 c9 d0 ff ff       	call   c0105f77 <page_remove>
    free_page(pde2page(pgdir[0]));
c0108eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108eb1:	8b 00                	mov    (%eax),%eax
c0108eb3:	89 04 24             	mov    %eax,(%esp)
c0108eb6:	e8 b8 f1 ff ff       	call   c0108073 <pde2page>
c0108ebb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108ec2:	00 
c0108ec3:	89 04 24             	mov    %eax,(%esp)
c0108ec6:	e8 23 c4 ff ff       	call   c01052ee <free_pages>
    pgdir[0] = 0;
c0108ecb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ece:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ed7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108ede:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ee1:	89 04 24             	mov    %eax,(%esp)
c0108ee4:	e8 fb f4 ff ff       	call   c01083e4 <mm_destroy>
    check_mm_struct = NULL;
c0108ee9:	c7 05 cc 11 1a c0 00 	movl   $0x0,0xc01a11cc
c0108ef0:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108ef3:	e8 28 c4 ff ff       	call   c0105320 <nr_free_pages>
c0108ef8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108efb:	74 24                	je     c0108f21 <check_pgfault+0x237>
c0108efd:	c7 44 24 0c d8 dd 10 	movl   $0xc010ddd8,0xc(%esp)
c0108f04:	c0 
c0108f05:	c7 44 24 08 47 db 10 	movl   $0xc010db47,0x8(%esp)
c0108f0c:	c0 
c0108f0d:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0108f14:	00 
c0108f15:	c7 04 24 5c db 10 c0 	movl   $0xc010db5c,(%esp)
c0108f1c:	e8 ca 7e ff ff       	call   c0100deb <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108f21:	c7 04 24 ff dd 10 c0 	movl   $0xc010ddff,(%esp)
c0108f28:	e8 32 74 ff ff       	call   c010035f <cprintf>
}
c0108f2d:	c9                   	leave  
c0108f2e:	c3                   	ret    

c0108f2f <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0108f2f:	55                   	push   %ebp
c0108f30:	89 e5                	mov    %esp,%ebp
c0108f32:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108f35:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108f3c:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f43:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f46:	89 04 24             	mov    %eax,(%esp)
c0108f49:	e8 11 f2 ff ff       	call   c010815f <find_vma>
c0108f4e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0108f51:	a1 38 f0 19 c0       	mov    0xc019f038,%eax
c0108f56:	83 c0 01             	add    $0x1,%eax
c0108f59:	a3 38 f0 19 c0       	mov    %eax,0xc019f038
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0108f5e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108f62:	74 0b                	je     c0108f6f <do_pgfault+0x40>
c0108f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f67:	8b 40 04             	mov    0x4(%eax),%eax
c0108f6a:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108f6d:	76 18                	jbe    c0108f87 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0108f6f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f76:	c7 04 24 1c de 10 c0 	movl   $0xc010de1c,(%esp)
c0108f7d:	e8 dd 73 ff ff       	call   c010035f <cprintf>
        goto failed;
c0108f82:	e9 bb 01 00 00       	jmp    c0109142 <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c0108f87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f8a:	83 e0 03             	and    $0x3,%eax
c0108f8d:	85 c0                	test   %eax,%eax
c0108f8f:	74 36                	je     c0108fc7 <do_pgfault+0x98>
c0108f91:	83 f8 01             	cmp    $0x1,%eax
c0108f94:	74 20                	je     c0108fb6 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0108f96:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f99:	8b 40 0c             	mov    0xc(%eax),%eax
c0108f9c:	83 e0 02             	and    $0x2,%eax
c0108f9f:	85 c0                	test   %eax,%eax
c0108fa1:	75 11                	jne    c0108fb4 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108fa3:	c7 04 24 4c de 10 c0 	movl   $0xc010de4c,(%esp)
c0108faa:	e8 b0 73 ff ff       	call   c010035f <cprintf>
            goto failed;
c0108faf:	e9 8e 01 00 00       	jmp    c0109142 <do_pgfault+0x213>
        }
        break;
c0108fb4:	eb 2f                	jmp    c0108fe5 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108fb6:	c7 04 24 ac de 10 c0 	movl   $0xc010deac,(%esp)
c0108fbd:	e8 9d 73 ff ff       	call   c010035f <cprintf>
        goto failed;
c0108fc2:	e9 7b 01 00 00       	jmp    c0109142 <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108fc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108fca:	8b 40 0c             	mov    0xc(%eax),%eax
c0108fcd:	83 e0 05             	and    $0x5,%eax
c0108fd0:	85 c0                	test   %eax,%eax
c0108fd2:	75 11                	jne    c0108fe5 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108fd4:	c7 04 24 e4 de 10 c0 	movl   $0xc010dee4,(%esp)
c0108fdb:	e8 7f 73 ff ff       	call   c010035f <cprintf>
            goto failed;
c0108fe0:	e9 5d 01 00 00       	jmp    c0109142 <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108fe5:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108fec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108fef:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ff2:	83 e0 02             	and    $0x2,%eax
c0108ff5:	85 c0                	test   %eax,%eax
c0108ff7:	74 04                	je     c0108ffd <do_pgfault+0xce>
        perm |= PTE_W;
c0108ff9:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108ffd:	8b 45 10             	mov    0x10(%ebp),%eax
c0109000:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109003:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109006:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010900b:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c010900e:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0109015:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c010901c:	8b 45 08             	mov    0x8(%ebp),%eax
c010901f:	8b 40 0c             	mov    0xc(%eax),%eax
c0109022:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0109029:	00 
c010902a:	8b 55 10             	mov    0x10(%ebp),%edx
c010902d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109031:	89 04 24             	mov    %eax,(%esp)
c0109034:	e8 2e c9 ff ff       	call   c0105967 <get_pte>
c0109039:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010903c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109040:	75 11                	jne    c0109053 <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0109042:	c7 04 24 47 df 10 c0 	movl   $0xc010df47,(%esp)
c0109049:	e8 11 73 ff ff       	call   c010035f <cprintf>
        goto failed;
c010904e:	e9 ef 00 00 00       	jmp    c0109142 <do_pgfault+0x213>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0109053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109056:	8b 00                	mov    (%eax),%eax
c0109058:	85 c0                	test   %eax,%eax
c010905a:	75 35                	jne    c0109091 <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c010905c:	8b 45 08             	mov    0x8(%ebp),%eax
c010905f:	8b 40 0c             	mov    0xc(%eax),%eax
c0109062:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109065:	89 54 24 08          	mov    %edx,0x8(%esp)
c0109069:	8b 55 10             	mov    0x10(%ebp),%edx
c010906c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109070:	89 04 24             	mov    %eax,(%esp)
c0109073:	e8 59 d0 ff ff       	call   c01060d1 <pgdir_alloc_page>
c0109078:	85 c0                	test   %eax,%eax
c010907a:	0f 85 bb 00 00 00    	jne    c010913b <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0109080:	c7 04 24 68 df 10 c0 	movl   $0xc010df68,(%esp)
c0109087:	e8 d3 72 ff ff       	call   c010035f <cprintf>
            goto failed;
c010908c:	e9 b1 00 00 00       	jmp    c0109142 <do_pgfault+0x213>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c0109091:	a1 2c f0 19 c0       	mov    0xc019f02c,%eax
c0109096:	85 c0                	test   %eax,%eax
c0109098:	0f 84 86 00 00 00    	je     c0109124 <do_pgfault+0x1f5>
            struct Page *page=NULL;
c010909e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01090a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01090a8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01090ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01090af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01090b6:	89 04 24             	mov    %eax,(%esp)
c01090b9:	e8 bf e0 ff ff       	call   c010717d <swap_in>
c01090be:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01090c5:	74 0e                	je     c01090d5 <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c01090c7:	c7 04 24 8f df 10 c0 	movl   $0xc010df8f,(%esp)
c01090ce:	e8 8c 72 ff ff       	call   c010035f <cprintf>
c01090d3:	eb 6d                	jmp    c0109142 <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c01090d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01090d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01090db:	8b 40 0c             	mov    0xc(%eax),%eax
c01090de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01090e1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01090e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
c01090e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01090ec:	89 54 24 04          	mov    %edx,0x4(%esp)
c01090f0:	89 04 24             	mov    %eax,(%esp)
c01090f3:	e8 c3 ce ff ff       	call   c0105fbb <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c01090f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01090fb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0109102:	00 
c0109103:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109107:	8b 45 10             	mov    0x10(%ebp),%eax
c010910a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010910e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109111:	89 04 24             	mov    %eax,(%esp)
c0109114:	e8 9b de ff ff       	call   c0106fb4 <swap_map_swappable>
            page->pra_vaddr = addr;
c0109119:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010911c:	8b 55 10             	mov    0x10(%ebp),%edx
c010911f:	89 50 1c             	mov    %edx,0x1c(%eax)
c0109122:	eb 17                	jmp    c010913b <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0109124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109127:	8b 00                	mov    (%eax),%eax
c0109129:	89 44 24 04          	mov    %eax,0x4(%esp)
c010912d:	c7 04 24 b0 df 10 c0 	movl   $0xc010dfb0,(%esp)
c0109134:	e8 26 72 ff ff       	call   c010035f <cprintf>
            goto failed;
c0109139:	eb 07                	jmp    c0109142 <do_pgfault+0x213>
        }
   }
   ret = 0;
c010913b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0109142:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109145:	c9                   	leave  
c0109146:	c3                   	ret    

c0109147 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0109147:	55                   	push   %ebp
c0109148:	89 e5                	mov    %esp,%ebp
c010914a:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c010914d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109151:	0f 84 e0 00 00 00    	je     c0109237 <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c0109157:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010915e:	76 1c                	jbe    c010917c <user_mem_check+0x35>
c0109160:	8b 45 10             	mov    0x10(%ebp),%eax
c0109163:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109166:	01 d0                	add    %edx,%eax
c0109168:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010916b:	76 0f                	jbe    c010917c <user_mem_check+0x35>
c010916d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109170:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109173:	01 d0                	add    %edx,%eax
c0109175:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c010917a:	76 0a                	jbe    c0109186 <user_mem_check+0x3f>
            return 0;
c010917c:	b8 00 00 00 00       	mov    $0x0,%eax
c0109181:	e9 e2 00 00 00       	jmp    c0109268 <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c0109186:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109189:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010918c:	8b 45 10             	mov    0x10(%ebp),%eax
c010918f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109192:	01 d0                	add    %edx,%eax
c0109194:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c0109197:	e9 88 00 00 00       	jmp    c0109224 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c010919c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010919f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01091a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01091a6:	89 04 24             	mov    %eax,(%esp)
c01091a9:	e8 b1 ef ff ff       	call   c010815f <find_vma>
c01091ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01091b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01091b5:	74 0b                	je     c01091c2 <user_mem_check+0x7b>
c01091b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091ba:	8b 40 04             	mov    0x4(%eax),%eax
c01091bd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01091c0:	76 0a                	jbe    c01091cc <user_mem_check+0x85>
                return 0;
c01091c2:	b8 00 00 00 00       	mov    $0x0,%eax
c01091c7:	e9 9c 00 00 00       	jmp    c0109268 <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c01091cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091cf:	8b 50 0c             	mov    0xc(%eax),%edx
c01091d2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01091d6:	74 07                	je     c01091df <user_mem_check+0x98>
c01091d8:	b8 02 00 00 00       	mov    $0x2,%eax
c01091dd:	eb 05                	jmp    c01091e4 <user_mem_check+0x9d>
c01091df:	b8 01 00 00 00       	mov    $0x1,%eax
c01091e4:	21 d0                	and    %edx,%eax
c01091e6:	85 c0                	test   %eax,%eax
c01091e8:	75 07                	jne    c01091f1 <user_mem_check+0xaa>
                return 0;
c01091ea:	b8 00 00 00 00       	mov    $0x0,%eax
c01091ef:	eb 77                	jmp    c0109268 <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c01091f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01091f5:	74 24                	je     c010921b <user_mem_check+0xd4>
c01091f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091fa:	8b 40 0c             	mov    0xc(%eax),%eax
c01091fd:	83 e0 08             	and    $0x8,%eax
c0109200:	85 c0                	test   %eax,%eax
c0109202:	74 17                	je     c010921b <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c0109204:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109207:	8b 40 04             	mov    0x4(%eax),%eax
c010920a:	05 00 10 00 00       	add    $0x1000,%eax
c010920f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0109212:	76 07                	jbe    c010921b <user_mem_check+0xd4>
                    return 0;
c0109214:	b8 00 00 00 00       	mov    $0x0,%eax
c0109219:	eb 4d                	jmp    c0109268 <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c010921b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010921e:	8b 40 08             	mov    0x8(%eax),%eax
c0109221:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!USER_ACCESS(addr, addr + len)) {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end) {
c0109224:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109227:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010922a:	0f 82 6c ff ff ff    	jb     c010919c <user_mem_check+0x55>
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
c0109230:	b8 01 00 00 00       	mov    $0x1,%eax
c0109235:	eb 31                	jmp    c0109268 <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c0109237:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c010923e:	76 23                	jbe    c0109263 <user_mem_check+0x11c>
c0109240:	8b 45 10             	mov    0x10(%ebp),%eax
c0109243:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109246:	01 d0                	add    %edx,%eax
c0109248:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010924b:	76 16                	jbe    c0109263 <user_mem_check+0x11c>
c010924d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109250:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109253:	01 d0                	add    %edx,%eax
c0109255:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c010925a:	77 07                	ja     c0109263 <user_mem_check+0x11c>
c010925c:	b8 01 00 00 00       	mov    $0x1,%eax
c0109261:	eb 05                	jmp    c0109268 <user_mem_check+0x121>
c0109263:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109268:	c9                   	leave  
c0109269:	c3                   	ret    

c010926a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010926a:	55                   	push   %ebp
c010926b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010926d:	8b 55 08             	mov    0x8(%ebp),%edx
c0109270:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0109275:	29 c2                	sub    %eax,%edx
c0109277:	89 d0                	mov    %edx,%eax
c0109279:	c1 f8 05             	sar    $0x5,%eax
}
c010927c:	5d                   	pop    %ebp
c010927d:	c3                   	ret    

c010927e <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010927e:	55                   	push   %ebp
c010927f:	89 e5                	mov    %esp,%ebp
c0109281:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109284:	8b 45 08             	mov    0x8(%ebp),%eax
c0109287:	89 04 24             	mov    %eax,(%esp)
c010928a:	e8 db ff ff ff       	call   c010926a <page2ppn>
c010928f:	c1 e0 0c             	shl    $0xc,%eax
}
c0109292:	c9                   	leave  
c0109293:	c3                   	ret    

c0109294 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109294:	55                   	push   %ebp
c0109295:	89 e5                	mov    %esp,%ebp
c0109297:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010929a:	8b 45 08             	mov    0x8(%ebp),%eax
c010929d:	89 04 24             	mov    %eax,(%esp)
c01092a0:	e8 d9 ff ff ff       	call   c010927e <page2pa>
c01092a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01092a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092ab:	c1 e8 0c             	shr    $0xc,%eax
c01092ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01092b1:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01092b6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01092b9:	72 23                	jb     c01092de <page2kva+0x4a>
c01092bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092be:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01092c2:	c7 44 24 08 d8 df 10 	movl   $0xc010dfd8,0x8(%esp)
c01092c9:	c0 
c01092ca:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01092d1:	00 
c01092d2:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01092d9:	e8 0d 7b ff ff       	call   c0100deb <__panic>
c01092de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092e1:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01092e6:	c9                   	leave  
c01092e7:	c3                   	ret    

c01092e8 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01092e8:	55                   	push   %ebp
c01092e9:	89 e5                	mov    %esp,%ebp
c01092eb:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01092ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092f5:	e8 52 88 ff ff       	call   c0101b4c <ide_device_valid>
c01092fa:	85 c0                	test   %eax,%eax
c01092fc:	75 1c                	jne    c010931a <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01092fe:	c7 44 24 08 09 e0 10 	movl   $0xc010e009,0x8(%esp)
c0109305:	c0 
c0109306:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c010930d:	00 
c010930e:	c7 04 24 23 e0 10 c0 	movl   $0xc010e023,(%esp)
c0109315:	e8 d1 7a ff ff       	call   c0100deb <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c010931a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109321:	e8 65 88 ff ff       	call   c0101b8b <ide_device_size>
c0109326:	c1 e8 03             	shr    $0x3,%eax
c0109329:	a3 9c 11 1a c0       	mov    %eax,0xc01a119c
}
c010932e:	c9                   	leave  
c010932f:	c3                   	ret    

c0109330 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0109330:	55                   	push   %ebp
c0109331:	89 e5                	mov    %esp,%ebp
c0109333:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109336:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109339:	89 04 24             	mov    %eax,(%esp)
c010933c:	e8 53 ff ff ff       	call   c0109294 <page2kva>
c0109341:	8b 55 08             	mov    0x8(%ebp),%edx
c0109344:	c1 ea 08             	shr    $0x8,%edx
c0109347:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010934a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010934e:	74 0b                	je     c010935b <swapfs_read+0x2b>
c0109350:	8b 15 9c 11 1a c0    	mov    0xc01a119c,%edx
c0109356:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109359:	72 23                	jb     c010937e <swapfs_read+0x4e>
c010935b:	8b 45 08             	mov    0x8(%ebp),%eax
c010935e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109362:	c7 44 24 08 34 e0 10 	movl   $0xc010e034,0x8(%esp)
c0109369:	c0 
c010936a:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0109371:	00 
c0109372:	c7 04 24 23 e0 10 c0 	movl   $0xc010e023,(%esp)
c0109379:	e8 6d 7a ff ff       	call   c0100deb <__panic>
c010937e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109381:	c1 e2 03             	shl    $0x3,%edx
c0109384:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010938b:	00 
c010938c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109390:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109394:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010939b:	e8 2a 88 ff ff       	call   c0101bca <ide_read_secs>
}
c01093a0:	c9                   	leave  
c01093a1:	c3                   	ret    

c01093a2 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01093a2:	55                   	push   %ebp
c01093a3:	89 e5                	mov    %esp,%ebp
c01093a5:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01093a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01093ab:	89 04 24             	mov    %eax,(%esp)
c01093ae:	e8 e1 fe ff ff       	call   c0109294 <page2kva>
c01093b3:	8b 55 08             	mov    0x8(%ebp),%edx
c01093b6:	c1 ea 08             	shr    $0x8,%edx
c01093b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01093bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01093c0:	74 0b                	je     c01093cd <swapfs_write+0x2b>
c01093c2:	8b 15 9c 11 1a c0    	mov    0xc01a119c,%edx
c01093c8:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01093cb:	72 23                	jb     c01093f0 <swapfs_write+0x4e>
c01093cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01093d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01093d4:	c7 44 24 08 34 e0 10 	movl   $0xc010e034,0x8(%esp)
c01093db:	c0 
c01093dc:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c01093e3:	00 
c01093e4:	c7 04 24 23 e0 10 c0 	movl   $0xc010e023,(%esp)
c01093eb:	e8 fb 79 ff ff       	call   c0100deb <__panic>
c01093f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01093f3:	c1 e2 03             	shl    $0x3,%edx
c01093f6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01093fd:	00 
c01093fe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109402:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109406:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010940d:	e8 fa 89 ff ff       	call   c0101e0c <ide_write_secs>
}
c0109412:	c9                   	leave  
c0109413:	c3                   	ret    

c0109414 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0109414:	52                   	push   %edx
    call *%ebx              # call fn
c0109415:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0109417:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0109418:	e8 6c 0c 00 00       	call   c010a089 <do_exit>

c010941d <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c010941d:	55                   	push   %ebp
c010941e:	89 e5                	mov    %esp,%ebp
c0109420:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c0109423:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109426:	8b 45 08             	mov    0x8(%ebp),%eax
c0109429:	0f ab 02             	bts    %eax,(%edx)
c010942c:	19 c0                	sbb    %eax,%eax
c010942e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0109431:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109435:	0f 95 c0             	setne  %al
c0109438:	0f b6 c0             	movzbl %al,%eax
}
c010943b:	c9                   	leave  
c010943c:	c3                   	ret    

c010943d <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c010943d:	55                   	push   %ebp
c010943e:	89 e5                	mov    %esp,%ebp
c0109440:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c0109443:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109446:	8b 45 08             	mov    0x8(%ebp),%eax
c0109449:	0f b3 02             	btr    %eax,(%edx)
c010944c:	19 c0                	sbb    %eax,%eax
c010944e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0109451:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109455:	0f 95 c0             	setne  %al
c0109458:	0f b6 c0             	movzbl %al,%eax
}
c010945b:	c9                   	leave  
c010945c:	c3                   	ret    

c010945d <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010945d:	55                   	push   %ebp
c010945e:	89 e5                	mov    %esp,%ebp
c0109460:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109463:	9c                   	pushf  
c0109464:	58                   	pop    %eax
c0109465:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109468:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010946b:	25 00 02 00 00       	and    $0x200,%eax
c0109470:	85 c0                	test   %eax,%eax
c0109472:	74 0c                	je     c0109480 <__intr_save+0x23>
        intr_disable();
c0109474:	e8 db 8b ff ff       	call   c0102054 <intr_disable>
        return 1;
c0109479:	b8 01 00 00 00       	mov    $0x1,%eax
c010947e:	eb 05                	jmp    c0109485 <__intr_save+0x28>
    }
    return 0;
c0109480:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109485:	c9                   	leave  
c0109486:	c3                   	ret    

c0109487 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109487:	55                   	push   %ebp
c0109488:	89 e5                	mov    %esp,%ebp
c010948a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010948d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109491:	74 05                	je     c0109498 <__intr_restore+0x11>
        intr_enable();
c0109493:	e8 b6 8b ff ff       	call   c010204e <intr_enable>
    }
}
c0109498:	c9                   	leave  
c0109499:	c3                   	ret    

c010949a <try_lock>:
lock_init(lock_t *lock) {
    *lock = 0;
}

static inline bool
try_lock(lock_t *lock) {
c010949a:	55                   	push   %ebp
c010949b:	89 e5                	mov    %esp,%ebp
c010949d:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c01094a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01094a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01094ae:	e8 6a ff ff ff       	call   c010941d <test_and_set_bit>
c01094b3:	85 c0                	test   %eax,%eax
c01094b5:	0f 94 c0             	sete   %al
c01094b8:	0f b6 c0             	movzbl %al,%eax
}
c01094bb:	c9                   	leave  
c01094bc:	c3                   	ret    

c01094bd <lock>:

static inline void
lock(lock_t *lock) {
c01094bd:	55                   	push   %ebp
c01094be:	89 e5                	mov    %esp,%ebp
c01094c0:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c01094c3:	eb 05                	jmp    c01094ca <lock+0xd>
        schedule();
c01094c5:	e8 24 1c 00 00       	call   c010b0ee <schedule>
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
c01094ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01094cd:	89 04 24             	mov    %eax,(%esp)
c01094d0:	e8 c5 ff ff ff       	call   c010949a <try_lock>
c01094d5:	85 c0                	test   %eax,%eax
c01094d7:	74 ec                	je     c01094c5 <lock+0x8>
        schedule();
    }
}
c01094d9:	c9                   	leave  
c01094da:	c3                   	ret    

c01094db <unlock>:

static inline void
unlock(lock_t *lock) {
c01094db:	55                   	push   %ebp
c01094dc:	89 e5                	mov    %esp,%ebp
c01094de:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c01094e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01094ef:	e8 49 ff ff ff       	call   c010943d <test_and_clear_bit>
c01094f4:	85 c0                	test   %eax,%eax
c01094f6:	75 1c                	jne    c0109514 <unlock+0x39>
        panic("Unlock failed.\n");
c01094f8:	c7 44 24 08 54 e0 10 	movl   $0xc010e054,0x8(%esp)
c01094ff:	c0 
c0109500:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c0109507:	00 
c0109508:	c7 04 24 64 e0 10 c0 	movl   $0xc010e064,(%esp)
c010950f:	e8 d7 78 ff ff       	call   c0100deb <__panic>
    }
}
c0109514:	c9                   	leave  
c0109515:	c3                   	ret    

c0109516 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109516:	55                   	push   %ebp
c0109517:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109519:	8b 55 08             	mov    0x8(%ebp),%edx
c010951c:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0109521:	29 c2                	sub    %eax,%edx
c0109523:	89 d0                	mov    %edx,%eax
c0109525:	c1 f8 05             	sar    $0x5,%eax
}
c0109528:	5d                   	pop    %ebp
c0109529:	c3                   	ret    

c010952a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010952a:	55                   	push   %ebp
c010952b:	89 e5                	mov    %esp,%ebp
c010952d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109530:	8b 45 08             	mov    0x8(%ebp),%eax
c0109533:	89 04 24             	mov    %eax,(%esp)
c0109536:	e8 db ff ff ff       	call   c0109516 <page2ppn>
c010953b:	c1 e0 0c             	shl    $0xc,%eax
}
c010953e:	c9                   	leave  
c010953f:	c3                   	ret    

c0109540 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0109540:	55                   	push   %ebp
c0109541:	89 e5                	mov    %esp,%ebp
c0109543:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109546:	8b 45 08             	mov    0x8(%ebp),%eax
c0109549:	c1 e8 0c             	shr    $0xc,%eax
c010954c:	89 c2                	mov    %eax,%edx
c010954e:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0109553:	39 c2                	cmp    %eax,%edx
c0109555:	72 1c                	jb     c0109573 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0109557:	c7 44 24 08 78 e0 10 	movl   $0xc010e078,0x8(%esp)
c010955e:	c0 
c010955f:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0109566:	00 
c0109567:	c7 04 24 97 e0 10 c0 	movl   $0xc010e097,(%esp)
c010956e:	e8 78 78 ff ff       	call   c0100deb <__panic>
    }
    return &pages[PPN(pa)];
c0109573:	a1 e4 10 1a c0       	mov    0xc01a10e4,%eax
c0109578:	8b 55 08             	mov    0x8(%ebp),%edx
c010957b:	c1 ea 0c             	shr    $0xc,%edx
c010957e:	c1 e2 05             	shl    $0x5,%edx
c0109581:	01 d0                	add    %edx,%eax
}
c0109583:	c9                   	leave  
c0109584:	c3                   	ret    

c0109585 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109585:	55                   	push   %ebp
c0109586:	89 e5                	mov    %esp,%ebp
c0109588:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010958b:	8b 45 08             	mov    0x8(%ebp),%eax
c010958e:	89 04 24             	mov    %eax,(%esp)
c0109591:	e8 94 ff ff ff       	call   c010952a <page2pa>
c0109596:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109599:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010959c:	c1 e8 0c             	shr    $0xc,%eax
c010959f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01095a2:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01095a7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01095aa:	72 23                	jb     c01095cf <page2kva+0x4a>
c01095ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095af:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01095b3:	c7 44 24 08 a8 e0 10 	movl   $0xc010e0a8,0x8(%esp)
c01095ba:	c0 
c01095bb:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01095c2:	00 
c01095c3:	c7 04 24 97 e0 10 c0 	movl   $0xc010e097,(%esp)
c01095ca:	e8 1c 78 ff ff       	call   c0100deb <__panic>
c01095cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095d2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01095d7:	c9                   	leave  
c01095d8:	c3                   	ret    

c01095d9 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01095d9:	55                   	push   %ebp
c01095da:	89 e5                	mov    %esp,%ebp
c01095dc:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01095df:	8b 45 08             	mov    0x8(%ebp),%eax
c01095e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01095e5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01095ec:	77 23                	ja     c0109611 <kva2page+0x38>
c01095ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01095f5:	c7 44 24 08 cc e0 10 	movl   $0xc010e0cc,0x8(%esp)
c01095fc:	c0 
c01095fd:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0109604:	00 
c0109605:	c7 04 24 97 e0 10 c0 	movl   $0xc010e097,(%esp)
c010960c:	e8 da 77 ff ff       	call   c0100deb <__panic>
c0109611:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109614:	05 00 00 00 40       	add    $0x40000000,%eax
c0109619:	89 04 24             	mov    %eax,(%esp)
c010961c:	e8 1f ff ff ff       	call   c0109540 <pa2page>
}
c0109621:	c9                   	leave  
c0109622:	c3                   	ret    

c0109623 <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c0109623:	55                   	push   %ebp
c0109624:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c0109626:	8b 45 08             	mov    0x8(%ebp),%eax
c0109629:	8b 40 18             	mov    0x18(%eax),%eax
c010962c:	8d 50 01             	lea    0x1(%eax),%edx
c010962f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109632:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c0109635:	8b 45 08             	mov    0x8(%ebp),%eax
c0109638:	8b 40 18             	mov    0x18(%eax),%eax
}
c010963b:	5d                   	pop    %ebp
c010963c:	c3                   	ret    

c010963d <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c010963d:	55                   	push   %ebp
c010963e:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c0109640:	8b 45 08             	mov    0x8(%ebp),%eax
c0109643:	8b 40 18             	mov    0x18(%eax),%eax
c0109646:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109649:	8b 45 08             	mov    0x8(%ebp),%eax
c010964c:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c010964f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109652:	8b 40 18             	mov    0x18(%eax),%eax
}
c0109655:	5d                   	pop    %ebp
c0109656:	c3                   	ret    

c0109657 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c0109657:	55                   	push   %ebp
c0109658:	89 e5                	mov    %esp,%ebp
c010965a:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c010965d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109661:	74 0e                	je     c0109671 <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c0109663:	8b 45 08             	mov    0x8(%ebp),%eax
c0109666:	83 c0 1c             	add    $0x1c,%eax
c0109669:	89 04 24             	mov    %eax,(%esp)
c010966c:	e8 4c fe ff ff       	call   c01094bd <lock>
    }
}
c0109671:	c9                   	leave  
c0109672:	c3                   	ret    

c0109673 <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c0109673:	55                   	push   %ebp
c0109674:	89 e5                	mov    %esp,%ebp
c0109676:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109679:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010967d:	74 0e                	je     c010968d <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c010967f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109682:	83 c0 1c             	add    $0x1c,%eax
c0109685:	89 04 24             	mov    %eax,(%esp)
c0109688:	e8 4e fe ff ff       	call   c01094db <unlock>
    }
}
c010968d:	c9                   	leave  
c010968e:	c3                   	ret    

c010968f <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010968f:	55                   	push   %ebp
c0109690:	89 e5                	mov    %esp,%ebp
c0109692:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109695:	c7 04 24 7c 00 00 00 	movl   $0x7c,(%esp)
c010969c:	e8 6d b7 ff ff       	call   c0104e0e <kmalloc>
c01096a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c01096a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01096a8:	0f 84 cd 00 00 00    	je     c010977b <alloc_proc+0xec>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c01096ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c01096b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096ba:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c01096c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c01096cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096ce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c01096d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096d8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c01096df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096e2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c01096e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096ec:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c01096f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096f6:	83 c0 1c             	add    $0x1c,%eax
c01096f9:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0109700:	00 
c0109701:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109708:	00 
c0109709:	89 04 24             	mov    %eax,(%esp)
c010970c:	e8 48 27 00 00       	call   c010be59 <memset>
        proc->tf = NULL;
c0109711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109714:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c010971b:	8b 15 e0 10 1a c0    	mov    0xc01a10e0,%edx
c0109721:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109724:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c0109727:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010972a:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c0109731:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109734:	83 c0 48             	add    $0x48,%eax
c0109737:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010973e:	00 
c010973f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109746:	00 
c0109747:	89 04 24             	mov    %eax,(%esp)
c010974a:	e8 0a 27 00 00       	call   c010be59 <memset>
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
	proc->wait_state = 0;
c010974f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109752:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->optr = proc->yptr = NULL;
c0109759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010975c:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
c0109763:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109766:	8b 50 74             	mov    0x74(%eax),%edx
c0109769:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010976c:	89 50 78             	mov    %edx,0x78(%eax)
c010976f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109772:	8b 50 78             	mov    0x78(%eax),%edx
c0109775:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109778:	89 50 70             	mov    %edx,0x70(%eax)
    }
    return proc;
c010977b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010977e:	c9                   	leave  
c010977f:	c3                   	ret    

c0109780 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0109780:	55                   	push   %ebp
c0109781:	89 e5                	mov    %esp,%ebp
c0109783:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109786:	8b 45 08             	mov    0x8(%ebp),%eax
c0109789:	83 c0 48             	add    $0x48,%eax
c010978c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109793:	00 
c0109794:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010979b:	00 
c010979c:	89 04 24             	mov    %eax,(%esp)
c010979f:	e8 b5 26 00 00       	call   c010be59 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01097a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01097a7:	8d 50 48             	lea    0x48(%eax),%edx
c01097aa:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01097b1:	00 
c01097b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097b9:	89 14 24             	mov    %edx,(%esp)
c01097bc:	e8 7a 27 00 00       	call   c010bf3b <memcpy>
}
c01097c1:	c9                   	leave  
c01097c2:	c3                   	ret    

c01097c3 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01097c3:	55                   	push   %ebp
c01097c4:	89 e5                	mov    %esp,%ebp
c01097c6:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c01097c9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01097d0:	00 
c01097d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01097d8:	00 
c01097d9:	c7 04 24 64 10 1a c0 	movl   $0xc01a1064,(%esp)
c01097e0:	e8 74 26 00 00       	call   c010be59 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c01097e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e8:	83 c0 48             	add    $0x48,%eax
c01097eb:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01097f2:	00 
c01097f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097f7:	c7 04 24 64 10 1a c0 	movl   $0xc01a1064,(%esp)
c01097fe:	e8 38 27 00 00       	call   c010bf3b <memcpy>
}
c0109803:	c9                   	leave  
c0109804:	c3                   	ret    

c0109805 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109805:	55                   	push   %ebp
c0109806:	89 e5                	mov    %esp,%ebp
c0109808:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c010980b:	8b 45 08             	mov    0x8(%ebp),%eax
c010980e:	83 c0 58             	add    $0x58,%eax
c0109811:	c7 45 fc d0 11 1a c0 	movl   $0xc01a11d0,-0x4(%ebp)
c0109818:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010981b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010981e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109821:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109824:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109827:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010982a:	8b 40 04             	mov    0x4(%eax),%eax
c010982d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109830:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109833:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109836:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109839:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010983c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010983f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109842:	89 10                	mov    %edx,(%eax)
c0109844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109847:	8b 10                	mov    (%eax),%edx
c0109849:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010984c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010984f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109852:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109855:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109858:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010985b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010985e:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c0109860:	8b 45 08             	mov    0x8(%ebp),%eax
c0109863:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c010986a:	8b 45 08             	mov    0x8(%ebp),%eax
c010986d:	8b 40 14             	mov    0x14(%eax),%eax
c0109870:	8b 50 70             	mov    0x70(%eax),%edx
c0109873:	8b 45 08             	mov    0x8(%ebp),%eax
c0109876:	89 50 78             	mov    %edx,0x78(%eax)
c0109879:	8b 45 08             	mov    0x8(%ebp),%eax
c010987c:	8b 40 78             	mov    0x78(%eax),%eax
c010987f:	85 c0                	test   %eax,%eax
c0109881:	74 0c                	je     c010988f <set_links+0x8a>
        proc->optr->yptr = proc;
c0109883:	8b 45 08             	mov    0x8(%ebp),%eax
c0109886:	8b 40 78             	mov    0x78(%eax),%eax
c0109889:	8b 55 08             	mov    0x8(%ebp),%edx
c010988c:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c010988f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109892:	8b 40 14             	mov    0x14(%eax),%eax
c0109895:	8b 55 08             	mov    0x8(%ebp),%edx
c0109898:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c010989b:	a1 60 10 1a c0       	mov    0xc01a1060,%eax
c01098a0:	83 c0 01             	add    $0x1,%eax
c01098a3:	a3 60 10 1a c0       	mov    %eax,0xc01a1060
}
c01098a8:	c9                   	leave  
c01098a9:	c3                   	ret    

c01098aa <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c01098aa:	55                   	push   %ebp
c01098ab:	89 e5                	mov    %esp,%ebp
c01098ad:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c01098b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01098b3:	83 c0 58             	add    $0x58,%eax
c01098b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01098b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098bc:	8b 40 04             	mov    0x4(%eax),%eax
c01098bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01098c2:	8b 12                	mov    (%edx),%edx
c01098c4:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01098c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01098ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01098cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01098d0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01098d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098d6:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01098d9:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c01098db:	8b 45 08             	mov    0x8(%ebp),%eax
c01098de:	8b 40 78             	mov    0x78(%eax),%eax
c01098e1:	85 c0                	test   %eax,%eax
c01098e3:	74 0f                	je     c01098f4 <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c01098e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01098e8:	8b 40 78             	mov    0x78(%eax),%eax
c01098eb:	8b 55 08             	mov    0x8(%ebp),%edx
c01098ee:	8b 52 74             	mov    0x74(%edx),%edx
c01098f1:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c01098f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01098f7:	8b 40 74             	mov    0x74(%eax),%eax
c01098fa:	85 c0                	test   %eax,%eax
c01098fc:	74 11                	je     c010990f <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c01098fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109901:	8b 40 74             	mov    0x74(%eax),%eax
c0109904:	8b 55 08             	mov    0x8(%ebp),%edx
c0109907:	8b 52 78             	mov    0x78(%edx),%edx
c010990a:	89 50 78             	mov    %edx,0x78(%eax)
c010990d:	eb 0f                	jmp    c010991e <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c010990f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109912:	8b 40 14             	mov    0x14(%eax),%eax
c0109915:	8b 55 08             	mov    0x8(%ebp),%edx
c0109918:	8b 52 78             	mov    0x78(%edx),%edx
c010991b:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c010991e:	a1 60 10 1a c0       	mov    0xc01a1060,%eax
c0109923:	83 e8 01             	sub    $0x1,%eax
c0109926:	a3 60 10 1a c0       	mov    %eax,0xc01a1060
}
c010992b:	c9                   	leave  
c010992c:	c3                   	ret    

c010992d <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c010992d:	55                   	push   %ebp
c010992e:	89 e5                	mov    %esp,%ebp
c0109930:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109933:	c7 45 f8 d0 11 1a c0 	movl   $0xc01a11d0,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c010993a:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c010993f:	83 c0 01             	add    $0x1,%eax
c0109942:	a3 80 aa 12 c0       	mov    %eax,0xc012aa80
c0109947:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c010994c:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109951:	7e 0c                	jle    c010995f <get_pid+0x32>
        last_pid = 1;
c0109953:	c7 05 80 aa 12 c0 01 	movl   $0x1,0xc012aa80
c010995a:	00 00 00 
        goto inside;
c010995d:	eb 13                	jmp    c0109972 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c010995f:	8b 15 80 aa 12 c0    	mov    0xc012aa80,%edx
c0109965:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c010996a:	39 c2                	cmp    %eax,%edx
c010996c:	0f 8c ac 00 00 00    	jl     c0109a1e <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0109972:	c7 05 84 aa 12 c0 00 	movl   $0x2000,0xc012aa84
c0109979:	20 00 00 
    repeat:
        le = list;
c010997c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010997f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109982:	eb 7f                	jmp    c0109a03 <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0109984:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109987:	83 e8 58             	sub    $0x58,%eax
c010998a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c010998d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109990:	8b 50 04             	mov    0x4(%eax),%edx
c0109993:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c0109998:	39 c2                	cmp    %eax,%edx
c010999a:	75 3e                	jne    c01099da <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c010999c:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c01099a1:	83 c0 01             	add    $0x1,%eax
c01099a4:	a3 80 aa 12 c0       	mov    %eax,0xc012aa80
c01099a9:	8b 15 80 aa 12 c0    	mov    0xc012aa80,%edx
c01099af:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c01099b4:	39 c2                	cmp    %eax,%edx
c01099b6:	7c 4b                	jl     c0109a03 <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c01099b8:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c01099bd:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01099c2:	7e 0a                	jle    c01099ce <get_pid+0xa1>
                        last_pid = 1;
c01099c4:	c7 05 80 aa 12 c0 01 	movl   $0x1,0xc012aa80
c01099cb:	00 00 00 
                    }
                    next_safe = MAX_PID;
c01099ce:	c7 05 84 aa 12 c0 00 	movl   $0x2000,0xc012aa84
c01099d5:	20 00 00 
                    goto repeat;
c01099d8:	eb a2                	jmp    c010997c <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c01099da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099dd:	8b 50 04             	mov    0x4(%eax),%edx
c01099e0:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c01099e5:	39 c2                	cmp    %eax,%edx
c01099e7:	7e 1a                	jle    c0109a03 <get_pid+0xd6>
c01099e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099ec:	8b 50 04             	mov    0x4(%eax),%edx
c01099ef:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c01099f4:	39 c2                	cmp    %eax,%edx
c01099f6:	7d 0b                	jge    c0109a03 <get_pid+0xd6>
                next_safe = proc->pid;
c01099f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099fb:	8b 40 04             	mov    0x4(%eax),%eax
c01099fe:	a3 84 aa 12 c0       	mov    %eax,0xc012aa84
c0109a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a06:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a0c:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109a0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a15:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109a18:	0f 85 66 ff ff ff    	jne    c0109984 <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0109a1e:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
}
c0109a23:	c9                   	leave  
c0109a24:	c3                   	ret    

c0109a25 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109a25:	55                   	push   %ebp
c0109a26:	89 e5                	mov    %esp,%ebp
c0109a28:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0109a2b:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0109a30:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109a33:	74 63                	je     c0109a98 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109a35:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0109a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109a43:	e8 15 fa ff ff       	call   c010945d <__intr_save>
c0109a48:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a4e:	a3 48 f0 19 c0       	mov    %eax,0xc019f048
            load_esp0(next->kstack + KSTACKSIZE);
c0109a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a56:	8b 40 0c             	mov    0xc(%eax),%eax
c0109a59:	05 00 20 00 00       	add    $0x2000,%eax
c0109a5e:	89 04 24             	mov    %eax,(%esp)
c0109a61:	e8 cf b6 ff ff       	call   c0105135 <load_esp0>
            lcr3(next->cr3);
c0109a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a69:	8b 40 40             	mov    0x40(%eax),%eax
c0109a6c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109a6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a72:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a78:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a7e:	83 c0 1c             	add    $0x1c,%eax
c0109a81:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109a85:	89 04 24             	mov    %eax,(%esp)
c0109a88:	e8 69 15 00 00       	call   c010aff6 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109a8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a90:	89 04 24             	mov    %eax,(%esp)
c0109a93:	e8 ef f9 ff ff       	call   c0109487 <__intr_restore>
    }
}
c0109a98:	c9                   	leave  
c0109a99:	c3                   	ret    

c0109a9a <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109a9a:	55                   	push   %ebp
c0109a9b:	89 e5                	mov    %esp,%ebp
c0109a9d:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109aa0:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0109aa5:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109aa8:	89 04 24             	mov    %eax,(%esp)
c0109aab:	e8 11 91 ff ff       	call   c0102bc1 <forkrets>
}
c0109ab0:	c9                   	leave  
c0109ab1:	c3                   	ret    

c0109ab2 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109ab2:	55                   	push   %ebp
c0109ab3:	89 e5                	mov    %esp,%ebp
c0109ab5:	53                   	push   %ebx
c0109ab6:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109abc:	8d 58 60             	lea    0x60(%eax),%ebx
c0109abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ac2:	8b 40 04             	mov    0x4(%eax),%eax
c0109ac5:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109acc:	00 
c0109acd:	89 04 24             	mov    %eax,(%esp)
c0109ad0:	e8 d7 18 00 00       	call   c010b3ac <hash32>
c0109ad5:	c1 e0 03             	shl    $0x3,%eax
c0109ad8:	05 60 f0 19 c0       	add    $0xc019f060,%eax
c0109add:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ae0:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ae6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109aec:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109aef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109af2:	8b 40 04             	mov    0x4(%eax),%eax
c0109af5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109af8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109afb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109afe:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109b01:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109b04:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109b0a:	89 10                	mov    %edx,(%eax)
c0109b0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b0f:	8b 10                	mov    (%eax),%edx
c0109b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b14:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109b17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109b1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109b1d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109b20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109b23:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109b26:	89 10                	mov    %edx,(%eax)
}
c0109b28:	83 c4 34             	add    $0x34,%esp
c0109b2b:	5b                   	pop    %ebx
c0109b2c:	5d                   	pop    %ebp
c0109b2d:	c3                   	ret    

c0109b2e <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109b2e:	55                   	push   %ebp
c0109b2f:	89 e5                	mov    %esp,%ebp
c0109b31:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109b34:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b37:	83 c0 60             	add    $0x60,%eax
c0109b3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109b3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109b40:	8b 40 04             	mov    0x4(%eax),%eax
c0109b43:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109b46:	8b 12                	mov    (%edx),%edx
c0109b48:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109b4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109b4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109b51:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b54:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b5a:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109b5d:	89 10                	mov    %edx,(%eax)
}
c0109b5f:	c9                   	leave  
c0109b60:	c3                   	ret    

c0109b61 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109b61:	55                   	push   %ebp
c0109b62:	89 e5                	mov    %esp,%ebp
c0109b64:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109b67:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109b6b:	7e 5f                	jle    c0109bcc <find_proc+0x6b>
c0109b6d:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109b74:	7f 56                	jg     c0109bcc <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109b76:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b79:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109b80:	00 
c0109b81:	89 04 24             	mov    %eax,(%esp)
c0109b84:	e8 23 18 00 00       	call   c010b3ac <hash32>
c0109b89:	c1 e0 03             	shl    $0x3,%eax
c0109b8c:	05 60 f0 19 c0       	add    $0xc019f060,%eax
c0109b91:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109b9a:	eb 19                	jmp    c0109bb5 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b9f:	83 e8 60             	sub    $0x60,%eax
c0109ba2:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109ba5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ba8:	8b 40 04             	mov    0x4(%eax),%eax
c0109bab:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109bae:	75 05                	jne    c0109bb5 <find_proc+0x54>
                return proc;
c0109bb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bb3:	eb 1c                	jmp    c0109bd1 <find_proc+0x70>
c0109bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109bbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109bbe:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bc7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109bca:	75 d0                	jne    c0109b9c <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0109bcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109bd1:	c9                   	leave  
c0109bd2:	c3                   	ret    

c0109bd3 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109bd3:	55                   	push   %ebp
c0109bd4:	89 e5                	mov    %esp,%ebp
c0109bd6:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109bd9:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109be0:	00 
c0109be1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109be8:	00 
c0109be9:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109bec:	89 04 24             	mov    %eax,(%esp)
c0109bef:	e8 65 22 00 00       	call   c010be59 <memset>
    tf.tf_cs = KERNEL_CS;
c0109bf4:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109bfa:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109c00:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109c04:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109c08:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109c0c:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109c10:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c13:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109c16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c19:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109c1c:	b8 14 94 10 c0       	mov    $0xc0109414,%eax
c0109c21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109c24:	8b 45 10             	mov    0x10(%ebp),%eax
c0109c27:	80 cc 01             	or     $0x1,%ah
c0109c2a:	89 c2                	mov    %eax,%edx
c0109c2c:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109c33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109c3a:	00 
c0109c3b:	89 14 24             	mov    %edx,(%esp)
c0109c3e:	e8 25 03 00 00       	call   c0109f68 <do_fork>
}
c0109c43:	c9                   	leave  
c0109c44:	c3                   	ret    

c0109c45 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109c45:	55                   	push   %ebp
c0109c46:	89 e5                	mov    %esp,%ebp
c0109c48:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109c4b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109c52:	e8 2c b6 ff ff       	call   c0105283 <alloc_pages>
c0109c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109c5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c5e:	74 1a                	je     c0109c7a <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c63:	89 04 24             	mov    %eax,(%esp)
c0109c66:	e8 1a f9 ff ff       	call   c0109585 <page2kva>
c0109c6b:	89 c2                	mov    %eax,%edx
c0109c6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c70:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109c73:	b8 00 00 00 00       	mov    $0x0,%eax
c0109c78:	eb 05                	jmp    c0109c7f <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109c7a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109c7f:	c9                   	leave  
c0109c80:	c3                   	ret    

c0109c81 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109c81:	55                   	push   %ebp
c0109c82:	89 e5                	mov    %esp,%ebp
c0109c84:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c8a:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c8d:	89 04 24             	mov    %eax,(%esp)
c0109c90:	e8 44 f9 ff ff       	call   c01095d9 <kva2page>
c0109c95:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109c9c:	00 
c0109c9d:	89 04 24             	mov    %eax,(%esp)
c0109ca0:	e8 49 b6 ff ff       	call   c01052ee <free_pages>
}
c0109ca5:	c9                   	leave  
c0109ca6:	c3                   	ret    

c0109ca7 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109ca7:	55                   	push   %ebp
c0109ca8:	89 e5                	mov    %esp,%ebp
c0109caa:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109cad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109cb4:	e8 ca b5 ff ff       	call   c0105283 <alloc_pages>
c0109cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109cbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109cc0:	75 0a                	jne    c0109ccc <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109cc2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109cc7:	e9 80 00 00 00       	jmp    c0109d4c <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ccf:	89 04 24             	mov    %eax,(%esp)
c0109cd2:	e8 ae f8 ff ff       	call   c0109585 <page2kva>
c0109cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109cda:	a1 00 aa 12 c0       	mov    0xc012aa00,%eax
c0109cdf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109ce6:	00 
c0109ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ceb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cee:	89 04 24             	mov    %eax,(%esp)
c0109cf1:	e8 45 22 00 00       	call   c010bf3b <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cf9:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d02:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d05:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109d0c:	77 23                	ja     c0109d31 <setup_pgdir+0x8a>
c0109d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d11:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109d15:	c7 44 24 08 cc e0 10 	movl   $0xc010e0cc,0x8(%esp)
c0109d1c:	c0 
c0109d1d:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0109d24:	00 
c0109d25:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c0109d2c:	e8 ba 70 ff ff       	call   c0100deb <__panic>
c0109d31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d34:	05 00 00 00 40       	add    $0x40000000,%eax
c0109d39:	83 c8 03             	or     $0x3,%eax
c0109d3c:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109d3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d41:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109d44:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109d47:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109d4c:	c9                   	leave  
c0109d4d:	c3                   	ret    

c0109d4e <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109d4e:	55                   	push   %ebp
c0109d4f:	89 e5                	mov    %esp,%ebp
c0109d51:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109d54:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d57:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d5a:	89 04 24             	mov    %eax,(%esp)
c0109d5d:	e8 77 f8 ff ff       	call   c01095d9 <kva2page>
c0109d62:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109d69:	00 
c0109d6a:	89 04 24             	mov    %eax,(%esp)
c0109d6d:	e8 7c b5 ff ff       	call   c01052ee <free_pages>
}
c0109d72:	c9                   	leave  
c0109d73:	c3                   	ret    

c0109d74 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109d74:	55                   	push   %ebp
c0109d75:	89 e5                	mov    %esp,%ebp
c0109d77:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109d7a:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0109d7f:	8b 40 18             	mov    0x18(%eax),%eax
c0109d82:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109d85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109d89:	75 0a                	jne    c0109d95 <copy_mm+0x21>
        return 0;
c0109d8b:	b8 00 00 00 00       	mov    $0x0,%eax
c0109d90:	e9 f9 00 00 00       	jmp    c0109e8e <copy_mm+0x11a>
    }
    if (clone_flags & CLONE_VM) {
c0109d95:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d98:	25 00 01 00 00       	and    $0x100,%eax
c0109d9d:	85 c0                	test   %eax,%eax
c0109d9f:	74 08                	je     c0109da9 <copy_mm+0x35>
        mm = oldmm;
c0109da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109da7:	eb 78                	jmp    c0109e21 <copy_mm+0xad>
    }

    int ret = -E_NO_MEM;
c0109da9:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109db0:	e8 d6 e2 ff ff       	call   c010808b <mm_create>
c0109db5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109db8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109dbc:	75 05                	jne    c0109dc3 <copy_mm+0x4f>
        goto bad_mm;
c0109dbe:	e9 c8 00 00 00       	jmp    c0109e8b <copy_mm+0x117>
    }
    if (setup_pgdir(mm) != 0) {
c0109dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109dc6:	89 04 24             	mov    %eax,(%esp)
c0109dc9:	e8 d9 fe ff ff       	call   c0109ca7 <setup_pgdir>
c0109dce:	85 c0                	test   %eax,%eax
c0109dd0:	74 05                	je     c0109dd7 <copy_mm+0x63>
        goto bad_pgdir_cleanup_mm;
c0109dd2:	e9 a9 00 00 00       	jmp    c0109e80 <copy_mm+0x10c>
    }

    lock_mm(oldmm);
c0109dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109dda:	89 04 24             	mov    %eax,(%esp)
c0109ddd:	e8 75 f8 ff ff       	call   c0109657 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109de2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109de5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109dec:	89 04 24             	mov    %eax,(%esp)
c0109def:	e8 ae e7 ff ff       	call   c01085a2 <dup_mmap>
c0109df4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109dfa:	89 04 24             	mov    %eax,(%esp)
c0109dfd:	e8 71 f8 ff ff       	call   c0109673 <unlock_mm>

    if (ret != 0) {
c0109e02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109e06:	74 19                	je     c0109e21 <copy_mm+0xad>
        goto bad_dup_cleanup_mmap;
c0109e08:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e0c:	89 04 24             	mov    %eax,(%esp)
c0109e0f:	e8 8f e8 ff ff       	call   c01086a3 <exit_mmap>
    put_pgdir(mm);
c0109e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e17:	89 04 24             	mov    %eax,(%esp)
c0109e1a:	e8 2f ff ff ff       	call   c0109d4e <put_pgdir>
c0109e1f:	eb 5f                	jmp    c0109e80 <copy_mm+0x10c>
    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
c0109e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e24:	89 04 24             	mov    %eax,(%esp)
c0109e27:	e8 f7 f7 ff ff       	call   c0109623 <mm_count_inc>
    proc->mm = mm;
c0109e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109e32:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e38:	8b 40 0c             	mov    0xc(%eax),%eax
c0109e3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109e3e:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109e45:	77 23                	ja     c0109e6a <copy_mm+0xf6>
c0109e47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109e4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109e4e:	c7 44 24 08 cc e0 10 	movl   $0xc010e0cc,0x8(%esp)
c0109e55:	c0 
c0109e56:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c0109e5d:	00 
c0109e5e:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c0109e65:	e8 81 6f ff ff       	call   c0100deb <__panic>
c0109e6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109e6d:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109e73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e76:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109e79:	b8 00 00 00 00       	mov    $0x0,%eax
c0109e7e:	eb 0e                	jmp    c0109e8e <copy_mm+0x11a>
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e83:	89 04 24             	mov    %eax,(%esp)
c0109e86:	e8 59 e5 ff ff       	call   c01083e4 <mm_destroy>
bad_mm:
    return ret;
c0109e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109e8e:	c9                   	leave  
c0109e8f:	c3                   	ret    

c0109e90 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109e90:	55                   	push   %ebp
c0109e91:	89 e5                	mov    %esp,%ebp
c0109e93:	57                   	push   %edi
c0109e94:	56                   	push   %esi
c0109e95:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e99:	8b 40 0c             	mov    0xc(%eax),%eax
c0109e9c:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109ea1:	89 c2                	mov    %eax,%edx
c0109ea3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ea6:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109ea9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eac:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109eaf:	8b 55 10             	mov    0x10(%ebp),%edx
c0109eb2:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109eb7:	89 c1                	mov    %eax,%ecx
c0109eb9:	83 e1 01             	and    $0x1,%ecx
c0109ebc:	85 c9                	test   %ecx,%ecx
c0109ebe:	74 0e                	je     c0109ece <copy_thread+0x3e>
c0109ec0:	0f b6 0a             	movzbl (%edx),%ecx
c0109ec3:	88 08                	mov    %cl,(%eax)
c0109ec5:	83 c0 01             	add    $0x1,%eax
c0109ec8:	83 c2 01             	add    $0x1,%edx
c0109ecb:	83 eb 01             	sub    $0x1,%ebx
c0109ece:	89 c1                	mov    %eax,%ecx
c0109ed0:	83 e1 02             	and    $0x2,%ecx
c0109ed3:	85 c9                	test   %ecx,%ecx
c0109ed5:	74 0f                	je     c0109ee6 <copy_thread+0x56>
c0109ed7:	0f b7 0a             	movzwl (%edx),%ecx
c0109eda:	66 89 08             	mov    %cx,(%eax)
c0109edd:	83 c0 02             	add    $0x2,%eax
c0109ee0:	83 c2 02             	add    $0x2,%edx
c0109ee3:	83 eb 02             	sub    $0x2,%ebx
c0109ee6:	89 d9                	mov    %ebx,%ecx
c0109ee8:	c1 e9 02             	shr    $0x2,%ecx
c0109eeb:	89 c7                	mov    %eax,%edi
c0109eed:	89 d6                	mov    %edx,%esi
c0109eef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109ef1:	89 f2                	mov    %esi,%edx
c0109ef3:	89 f8                	mov    %edi,%eax
c0109ef5:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109efa:	89 de                	mov    %ebx,%esi
c0109efc:	83 e6 02             	and    $0x2,%esi
c0109eff:	85 f6                	test   %esi,%esi
c0109f01:	74 0b                	je     c0109f0e <copy_thread+0x7e>
c0109f03:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109f07:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109f0b:	83 c1 02             	add    $0x2,%ecx
c0109f0e:	83 e3 01             	and    $0x1,%ebx
c0109f11:	85 db                	test   %ebx,%ebx
c0109f13:	74 07                	je     c0109f1c <copy_thread+0x8c>
c0109f15:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109f19:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109f1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f1f:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f22:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109f29:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f2c:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109f32:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109f35:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f38:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f3b:	8b 55 08             	mov    0x8(%ebp),%edx
c0109f3e:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109f41:	8b 52 40             	mov    0x40(%edx),%edx
c0109f44:	80 ce 02             	or     $0x2,%dh
c0109f47:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109f4a:	ba 9a 9a 10 c0       	mov    $0xc0109a9a,%edx
c0109f4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f52:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f58:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f5b:	89 c2                	mov    %eax,%edx
c0109f5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f60:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109f63:	5b                   	pop    %ebx
c0109f64:	5e                   	pop    %esi
c0109f65:	5f                   	pop    %edi
c0109f66:	5d                   	pop    %ebp
c0109f67:	c3                   	ret    

c0109f68 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109f68:	55                   	push   %ebp
c0109f69:	89 e5                	mov    %esp,%ebp
c0109f6b:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109f6e:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109f75:	a1 60 10 1a c0       	mov    0xc01a1060,%eax
c0109f7a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109f7f:	7e 05                	jle    c0109f86 <do_fork+0x1e>
        goto fork_out;
c0109f81:	e9 ef 00 00 00       	jmp    c010a075 <do_fork+0x10d>
    }
    ret = -E_NO_MEM;
c0109f86:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
	if((proc=alloc_proc())==NULL){
c0109f8d:	e8 fd f6 ff ff       	call   c010968f <alloc_proc>
c0109f92:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109f95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109f99:	75 05                	jne    c0109fa0 <do_fork+0x38>
		goto fork_out;
c0109f9b:	e9 d5 00 00 00       	jmp    c010a075 <do_fork+0x10d>
	}
	proc->parent = current;
c0109fa0:	8b 15 48 f0 19 c0    	mov    0xc019f048,%edx
c0109fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fa9:	89 50 14             	mov    %edx,0x14(%eax)
	assert(current->wait_state == 0);
c0109fac:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c0109fb1:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109fb4:	85 c0                	test   %eax,%eax
c0109fb6:	74 24                	je     c0109fdc <do_fork+0x74>
c0109fb8:	c7 44 24 0c 04 e1 10 	movl   $0xc010e104,0xc(%esp)
c0109fbf:	c0 
c0109fc0:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c0109fc7:	c0 
c0109fc8:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
c0109fcf:	00 
c0109fd0:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c0109fd7:	e8 0f 6e ff ff       	call   c0100deb <__panic>

    if (setup_kstack(proc) != 0) {
c0109fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fdf:	89 04 24             	mov    %eax,(%esp)
c0109fe2:	e8 5e fc ff ff       	call   c0109c45 <setup_kstack>
c0109fe7:	85 c0                	test   %eax,%eax
c0109fe9:	74 05                	je     c0109ff0 <do_fork+0x88>
        goto bad_fork_cleanup_proc;
c0109feb:	e9 8a 00 00 00       	jmp    c010a07a <do_fork+0x112>
    }
    if (copy_mm(clone_flags, proc) != 0) {
c0109ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ff7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ffa:	89 04 24             	mov    %eax,(%esp)
c0109ffd:	e8 72 fd ff ff       	call   c0109d74 <copy_mm>
c010a002:	85 c0                	test   %eax,%eax
c010a004:	74 0e                	je     c010a014 <do_fork+0xac>
        goto bad_fork_cleanup_kstack;
c010a006:	90                   	nop
	
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a007:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a00a:	89 04 24             	mov    %eax,(%esp)
c010a00d:	e8 6f fc ff ff       	call   c0109c81 <put_kstack>
c010a012:	eb 66                	jmp    c010a07a <do_fork+0x112>
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c010a014:	8b 45 10             	mov    0x10(%ebp),%eax
c010a017:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a01b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a01e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a022:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a025:	89 04 24             	mov    %eax,(%esp)
c010a028:	e8 63 fe ff ff       	call   c0109e90 <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c010a02d:	e8 2b f4 ff ff       	call   c010945d <__intr_save>
c010a032:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c010a035:	e8 f3 f8 ff ff       	call   c010992d <get_pid>
c010a03a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a03d:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010a040:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a043:	89 04 24             	mov    %eax,(%esp)
c010a046:	e8 67 fa ff ff       	call   c0109ab2 <hash_proc>
        //list_add(&proc_list, &(proc->list_link));
        //nr_process ++;
		set_links(proc);
c010a04b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a04e:	89 04 24             	mov    %eax,(%esp)
c010a051:	e8 af f7 ff ff       	call   c0109805 <set_links>
    }
    local_intr_restore(intr_flag);
c010a056:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a059:	89 04 24             	mov    %eax,(%esp)
c010a05c:	e8 26 f4 ff ff       	call   c0109487 <__intr_restore>

    wakeup_proc(proc);
c010a061:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a064:	89 04 24             	mov    %eax,(%esp)
c010a067:	e8 fe 0f 00 00       	call   c010b06a <wakeup_proc>

    ret = proc->pid;
c010a06c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a06f:	8b 40 04             	mov    0x4(%eax),%eax
c010a072:	89 45 f4             	mov    %eax,-0xc(%ebp)
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
	
fork_out:
    return ret;
c010a075:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a078:	eb 0d                	jmp    c010a087 <do_fork+0x11f>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c010a07a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a07d:	89 04 24             	mov    %eax,(%esp)
c010a080:	e8 a4 ad ff ff       	call   c0104e29 <kfree>
    goto fork_out;
c010a085:	eb ee                	jmp    c010a075 <do_fork+0x10d>
}
c010a087:	c9                   	leave  
c010a088:	c3                   	ret    

c010a089 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a089:	55                   	push   %ebp
c010a08a:	89 e5                	mov    %esp,%ebp
c010a08c:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c010a08f:	8b 15 48 f0 19 c0    	mov    0xc019f048,%edx
c010a095:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010a09a:	39 c2                	cmp    %eax,%edx
c010a09c:	75 1c                	jne    c010a0ba <do_exit+0x31>
        panic("idleproc exit.\n");
c010a09e:	c7 44 24 08 32 e1 10 	movl   $0xc010e132,0x8(%esp)
c010a0a5:	c0 
c010a0a6:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c010a0ad:	00 
c010a0ae:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a0b5:	e8 31 6d ff ff       	call   c0100deb <__panic>
    }
    if (current == initproc) {
c010a0ba:	8b 15 48 f0 19 c0    	mov    0xc019f048,%edx
c010a0c0:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010a0c5:	39 c2                	cmp    %eax,%edx
c010a0c7:	75 1c                	jne    c010a0e5 <do_exit+0x5c>
        panic("initproc exit.\n");
c010a0c9:	c7 44 24 08 42 e1 10 	movl   $0xc010e142,0x8(%esp)
c010a0d0:	c0 
c010a0d1:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
c010a0d8:	00 
c010a0d9:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a0e0:	e8 06 6d ff ff       	call   c0100deb <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c010a0e5:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a0ea:	8b 40 18             	mov    0x18(%eax),%eax
c010a0ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c010a0f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a0f4:	74 4a                	je     c010a140 <do_exit+0xb7>
        lcr3(boot_cr3);
c010a0f6:	a1 e0 10 1a c0       	mov    0xc01a10e0,%eax
c010a0fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a0fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a101:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a104:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a107:	89 04 24             	mov    %eax,(%esp)
c010a10a:	e8 2e f5 ff ff       	call   c010963d <mm_count_dec>
c010a10f:	85 c0                	test   %eax,%eax
c010a111:	75 21                	jne    c010a134 <do_exit+0xab>
            exit_mmap(mm);
c010a113:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a116:	89 04 24             	mov    %eax,(%esp)
c010a119:	e8 85 e5 ff ff       	call   c01086a3 <exit_mmap>
            put_pgdir(mm);
c010a11e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a121:	89 04 24             	mov    %eax,(%esp)
c010a124:	e8 25 fc ff ff       	call   c0109d4e <put_pgdir>
            mm_destroy(mm);
c010a129:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a12c:	89 04 24             	mov    %eax,(%esp)
c010a12f:	e8 b0 e2 ff ff       	call   c01083e4 <mm_destroy>
        }
        current->mm = NULL;
c010a134:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a139:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a140:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a145:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a14b:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a150:	8b 55 08             	mov    0x8(%ebp),%edx
c010a153:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a156:	e8 02 f3 ff ff       	call   c010945d <__intr_save>
c010a15b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a15e:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a163:	8b 40 14             	mov    0x14(%eax),%eax
c010a166:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a169:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a16c:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a16f:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a174:	75 10                	jne    c010a186 <do_exit+0xfd>
            wakeup_proc(proc);
c010a176:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a179:	89 04 24             	mov    %eax,(%esp)
c010a17c:	e8 e9 0e 00 00       	call   c010b06a <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a181:	e9 8b 00 00 00       	jmp    c010a211 <do_exit+0x188>
c010a186:	e9 86 00 00 00       	jmp    c010a211 <do_exit+0x188>
            proc = current->cptr;
c010a18b:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a190:	8b 40 70             	mov    0x70(%eax),%eax
c010a193:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a196:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a19b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a19e:	8b 52 78             	mov    0x78(%edx),%edx
c010a1a1:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a1a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1a7:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a1ae:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010a1b3:	8b 50 70             	mov    0x70(%eax),%edx
c010a1b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1b9:	89 50 78             	mov    %edx,0x78(%eax)
c010a1bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1bf:	8b 40 78             	mov    0x78(%eax),%eax
c010a1c2:	85 c0                	test   %eax,%eax
c010a1c4:	74 0e                	je     c010a1d4 <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a1c6:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010a1cb:	8b 40 70             	mov    0x70(%eax),%eax
c010a1ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a1d1:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a1d4:	8b 15 44 f0 19 c0    	mov    0xc019f044,%edx
c010a1da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1dd:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a1e0:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010a1e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a1e8:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a1eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1ee:	8b 00                	mov    (%eax),%eax
c010a1f0:	83 f8 03             	cmp    $0x3,%eax
c010a1f3:	75 1c                	jne    c010a211 <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a1f5:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010a1fa:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a1fd:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a202:	75 0d                	jne    c010a211 <do_exit+0x188>
                    wakeup_proc(initproc);
c010a204:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010a209:	89 04 24             	mov    %eax,(%esp)
c010a20c:	e8 59 0e 00 00       	call   c010b06a <wakeup_proc>
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
c010a211:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a216:	8b 40 70             	mov    0x70(%eax),%eax
c010a219:	85 c0                	test   %eax,%eax
c010a21b:	0f 85 6a ff ff ff    	jne    c010a18b <do_exit+0x102>
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a221:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a224:	89 04 24             	mov    %eax,(%esp)
c010a227:	e8 5b f2 ff ff       	call   c0109487 <__intr_restore>
    
    schedule();
c010a22c:	e8 bd 0e 00 00       	call   c010b0ee <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a231:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a236:	8b 40 04             	mov    0x4(%eax),%eax
c010a239:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a23d:	c7 44 24 08 54 e1 10 	movl   $0xc010e154,0x8(%esp)
c010a244:	c0 
c010a245:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c010a24c:	00 
c010a24d:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a254:	e8 92 6b ff ff       	call   c0100deb <__panic>

c010a259 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a259:	55                   	push   %ebp
c010a25a:	89 e5                	mov    %esp,%ebp
c010a25c:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a25f:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a264:	8b 40 18             	mov    0x18(%eax),%eax
c010a267:	85 c0                	test   %eax,%eax
c010a269:	74 1c                	je     c010a287 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a26b:	c7 44 24 08 74 e1 10 	movl   $0xc010e174,0x8(%esp)
c010a272:	c0 
c010a273:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c010a27a:	00 
c010a27b:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a282:	e8 64 6b ff ff       	call   c0100deb <__panic>
    }

    int ret = -E_NO_MEM;
c010a287:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a28e:	e8 f8 dd ff ff       	call   c010808b <mm_create>
c010a293:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a296:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a29a:	75 06                	jne    c010a2a2 <load_icode+0x49>
        goto bad_mm;
c010a29c:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a29d:	e9 ef 05 00 00       	jmp    c010a891 <load_icode+0x638>
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a2a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a2a5:	89 04 24             	mov    %eax,(%esp)
c010a2a8:	e8 fa f9 ff ff       	call   c0109ca7 <setup_pgdir>
c010a2ad:	85 c0                	test   %eax,%eax
c010a2af:	74 05                	je     c010a2b6 <load_icode+0x5d>
        goto bad_pgdir_cleanup_mm;
c010a2b1:	e9 f6 05 00 00       	jmp    c010a8ac <load_icode+0x653>
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a2b6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a2bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a2bf:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a2c2:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2c5:	01 d0                	add    %edx,%eax
c010a2c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a2ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a2cd:	8b 00                	mov    (%eax),%eax
c010a2cf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a2d4:	74 0c                	je     c010a2e2 <load_icode+0x89>
        ret = -E_INVAL_ELF;
c010a2d6:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a2dd:	e9 bf 05 00 00       	jmp    c010a8a1 <load_icode+0x648>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a2e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a2e5:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a2e9:	0f b7 c0             	movzwl %ax,%eax
c010a2ec:	c1 e0 05             	shl    $0x5,%eax
c010a2ef:	89 c2                	mov    %eax,%edx
c010a2f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2f4:	01 d0                	add    %edx,%eax
c010a2f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a2f9:	e9 13 03 00 00       	jmp    c010a611 <load_icode+0x3b8>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a2fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a301:	8b 00                	mov    (%eax),%eax
c010a303:	83 f8 01             	cmp    $0x1,%eax
c010a306:	74 05                	je     c010a30d <load_icode+0xb4>
            continue ;
c010a308:	e9 00 03 00 00       	jmp    c010a60d <load_icode+0x3b4>
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a30d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a310:	8b 50 10             	mov    0x10(%eax),%edx
c010a313:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a316:	8b 40 14             	mov    0x14(%eax),%eax
c010a319:	39 c2                	cmp    %eax,%edx
c010a31b:	76 0c                	jbe    c010a329 <load_icode+0xd0>
            ret = -E_INVAL_ELF;
c010a31d:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a324:	e9 6d 05 00 00       	jmp    c010a896 <load_icode+0x63d>
        }
        if (ph->p_filesz == 0) {
c010a329:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a32c:	8b 40 10             	mov    0x10(%eax),%eax
c010a32f:	85 c0                	test   %eax,%eax
c010a331:	75 05                	jne    c010a338 <load_icode+0xdf>
            continue ;
c010a333:	e9 d5 02 00 00       	jmp    c010a60d <load_icode+0x3b4>
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a338:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a33f:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a346:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a349:	8b 40 18             	mov    0x18(%eax),%eax
c010a34c:	83 e0 01             	and    $0x1,%eax
c010a34f:	85 c0                	test   %eax,%eax
c010a351:	74 04                	je     c010a357 <load_icode+0xfe>
c010a353:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a357:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a35a:	8b 40 18             	mov    0x18(%eax),%eax
c010a35d:	83 e0 02             	and    $0x2,%eax
c010a360:	85 c0                	test   %eax,%eax
c010a362:	74 04                	je     c010a368 <load_icode+0x10f>
c010a364:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a368:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a36b:	8b 40 18             	mov    0x18(%eax),%eax
c010a36e:	83 e0 04             	and    $0x4,%eax
c010a371:	85 c0                	test   %eax,%eax
c010a373:	74 04                	je     c010a379 <load_icode+0x120>
c010a375:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a379:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a37c:	83 e0 02             	and    $0x2,%eax
c010a37f:	85 c0                	test   %eax,%eax
c010a381:	74 04                	je     c010a387 <load_icode+0x12e>
c010a383:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a387:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a38a:	8b 50 14             	mov    0x14(%eax),%edx
c010a38d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a390:	8b 40 08             	mov    0x8(%eax),%eax
c010a393:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a39a:	00 
c010a39b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a39e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a3a2:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a3a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a3aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a3ad:	89 04 24             	mov    %eax,(%esp)
c010a3b0:	e8 d1 e0 ff ff       	call   c0108486 <mm_map>
c010a3b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a3b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a3bc:	74 05                	je     c010a3c3 <load_icode+0x16a>
            goto bad_cleanup_mmap;
c010a3be:	e9 d3 04 00 00       	jmp    c010a896 <load_icode+0x63d>
        }
        unsigned char *from = binary + ph->p_offset;
c010a3c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3c6:	8b 50 04             	mov    0x4(%eax),%edx
c010a3c9:	8b 45 08             	mov    0x8(%ebp),%eax
c010a3cc:	01 d0                	add    %edx,%eax
c010a3ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a3d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3d4:	8b 40 08             	mov    0x8(%eax),%eax
c010a3d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a3da:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3dd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a3e0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a3e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a3e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a3eb:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a3f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3f5:	8b 50 08             	mov    0x8(%eax),%edx
c010a3f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3fb:	8b 40 10             	mov    0x10(%eax),%eax
c010a3fe:	01 d0                	add    %edx,%eax
c010a400:	89 45 c0             	mov    %eax,-0x40(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a403:	e9 90 00 00 00       	jmp    c010a498 <load_icode+0x23f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a408:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a40b:	8b 40 0c             	mov    0xc(%eax),%eax
c010a40e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a411:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a415:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a418:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a41c:	89 04 24             	mov    %eax,(%esp)
c010a41f:	e8 ad bc ff ff       	call   c01060d1 <pgdir_alloc_page>
c010a424:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a427:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a42b:	75 05                	jne    c010a432 <load_icode+0x1d9>
                goto bad_cleanup_mmap;
c010a42d:	e9 64 04 00 00       	jmp    c010a896 <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a432:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a435:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a438:	29 c2                	sub    %eax,%edx
c010a43a:	89 d0                	mov    %edx,%eax
c010a43c:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a43f:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a444:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a447:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a44a:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a451:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a454:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a457:	73 0d                	jae    c010a466 <load_icode+0x20d>
                size -= la - end;
c010a459:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a45c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a45f:	29 c2                	sub    %eax,%edx
c010a461:	89 d0                	mov    %edx,%eax
c010a463:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a466:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a469:	89 04 24             	mov    %eax,(%esp)
c010a46c:	e8 14 f1 ff ff       	call   c0109585 <page2kva>
c010a471:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a474:	01 c2                	add    %eax,%edx
c010a476:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a479:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a47d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a480:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a484:	89 14 24             	mov    %edx,(%esp)
c010a487:	e8 af 1a 00 00       	call   c010bf3b <memcpy>
            start += size, from += size;
c010a48c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a48f:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a492:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a495:	01 45 e0             	add    %eax,-0x20(%ebp)
        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a498:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a49b:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a49e:	0f 82 64 ff ff ff    	jb     c010a408 <load_icode+0x1af>
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a4a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4a7:	8b 50 08             	mov    0x8(%eax),%edx
c010a4aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4ad:	8b 40 14             	mov    0x14(%eax),%eax
c010a4b0:	01 d0                	add    %edx,%eax
c010a4b2:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a4b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4b8:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4bb:	0f 83 b0 00 00 00    	jae    c010a571 <load_icode+0x318>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a4c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4c4:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a4c7:	75 05                	jne    c010a4ce <load_icode+0x275>
                continue ;
c010a4c9:	e9 3f 01 00 00       	jmp    c010a60d <load_icode+0x3b4>
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a4ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a4d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a4d4:	29 c2                	sub    %eax,%edx
c010a4d6:	89 d0                	mov    %edx,%eax
c010a4d8:	05 00 10 00 00       	add    $0x1000,%eax
c010a4dd:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a4e0:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a4e5:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a4e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a4eb:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a4ee:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4f1:	73 0d                	jae    c010a500 <load_icode+0x2a7>
                size -= la - end;
c010a4f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a4f6:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a4f9:	29 c2                	sub    %eax,%edx
c010a4fb:	89 d0                	mov    %edx,%eax
c010a4fd:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a500:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a503:	89 04 24             	mov    %eax,(%esp)
c010a506:	e8 7a f0 ff ff       	call   c0109585 <page2kva>
c010a50b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a50e:	01 c2                	add    %eax,%edx
c010a510:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a513:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a517:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a51e:	00 
c010a51f:	89 14 24             	mov    %edx,(%esp)
c010a522:	e8 32 19 00 00       	call   c010be59 <memset>
            start += size;
c010a527:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a52a:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a52d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a530:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a533:	73 08                	jae    c010a53d <load_icode+0x2e4>
c010a535:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a538:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a53b:	74 34                	je     c010a571 <load_icode+0x318>
c010a53d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a540:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a543:	72 08                	jb     c010a54d <load_icode+0x2f4>
c010a545:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a548:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a54b:	74 24                	je     c010a571 <load_icode+0x318>
c010a54d:	c7 44 24 0c 9c e1 10 	movl   $0xc010e19c,0xc(%esp)
c010a554:	c0 
c010a555:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010a55c:	c0 
c010a55d:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
c010a564:	00 
c010a565:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a56c:	e8 7a 68 ff ff       	call   c0100deb <__panic>
        }
        while (start < end) {
c010a571:	e9 8b 00 00 00       	jmp    c010a601 <load_icode+0x3a8>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a576:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a579:	8b 40 0c             	mov    0xc(%eax),%eax
c010a57c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a57f:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a583:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a586:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a58a:	89 04 24             	mov    %eax,(%esp)
c010a58d:	e8 3f bb ff ff       	call   c01060d1 <pgdir_alloc_page>
c010a592:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a595:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a599:	75 05                	jne    c010a5a0 <load_icode+0x347>
                goto bad_cleanup_mmap;
c010a59b:	e9 f6 02 00 00       	jmp    c010a896 <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a5a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a5a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a5a6:	29 c2                	sub    %eax,%edx
c010a5a8:	89 d0                	mov    %edx,%eax
c010a5aa:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a5ad:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a5b2:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a5b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a5b8:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a5bf:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a5c2:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a5c5:	73 0d                	jae    c010a5d4 <load_icode+0x37b>
                size -= la - end;
c010a5c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a5ca:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a5cd:	29 c2                	sub    %eax,%edx
c010a5cf:	89 d0                	mov    %edx,%eax
c010a5d1:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a5d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a5d7:	89 04 24             	mov    %eax,(%esp)
c010a5da:	e8 a6 ef ff ff       	call   c0109585 <page2kva>
c010a5df:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a5e2:	01 c2                	add    %eax,%edx
c010a5e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a5e7:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a5eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a5f2:	00 
c010a5f3:	89 14 24             	mov    %edx,(%esp)
c010a5f6:	e8 5e 18 00 00       	call   c010be59 <memset>
            start += size;
c010a5fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a5fe:	01 45 d8             	add    %eax,-0x28(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
c010a601:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a604:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a607:	0f 82 69 ff ff ff    	jb     c010a576 <load_icode+0x31d>
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
c010a60d:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a611:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a614:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a617:	0f 82 e1 fc ff ff    	jb     c010a2fe <load_icode+0xa5>
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a61d:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a624:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a62b:	00 
c010a62c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a62f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a633:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a63a:	00 
c010a63b:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a642:	af 
c010a643:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a646:	89 04 24             	mov    %eax,(%esp)
c010a649:	e8 38 de ff ff       	call   c0108486 <mm_map>
c010a64e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a651:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a655:	74 05                	je     c010a65c <load_icode+0x403>
        goto bad_cleanup_mmap;
c010a657:	e9 3a 02 00 00       	jmp    c010a896 <load_icode+0x63d>
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a65c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a65f:	8b 40 0c             	mov    0xc(%eax),%eax
c010a662:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a669:	00 
c010a66a:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a671:	af 
c010a672:	89 04 24             	mov    %eax,(%esp)
c010a675:	e8 57 ba ff ff       	call   c01060d1 <pgdir_alloc_page>
c010a67a:	85 c0                	test   %eax,%eax
c010a67c:	75 24                	jne    c010a6a2 <load_icode+0x449>
c010a67e:	c7 44 24 0c d8 e1 10 	movl   $0xc010e1d8,0xc(%esp)
c010a685:	c0 
c010a686:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010a68d:	c0 
c010a68e:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c010a695:	00 
c010a696:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a69d:	e8 49 67 ff ff       	call   c0100deb <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a6a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6a5:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6a8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a6af:	00 
c010a6b0:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a6b7:	af 
c010a6b8:	89 04 24             	mov    %eax,(%esp)
c010a6bb:	e8 11 ba ff ff       	call   c01060d1 <pgdir_alloc_page>
c010a6c0:	85 c0                	test   %eax,%eax
c010a6c2:	75 24                	jne    c010a6e8 <load_icode+0x48f>
c010a6c4:	c7 44 24 0c 1c e2 10 	movl   $0xc010e21c,0xc(%esp)
c010a6cb:	c0 
c010a6cc:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010a6d3:	c0 
c010a6d4:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c010a6db:	00 
c010a6dc:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a6e3:	e8 03 67 ff ff       	call   c0100deb <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a6e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6eb:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6ee:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a6f5:	00 
c010a6f6:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a6fd:	af 
c010a6fe:	89 04 24             	mov    %eax,(%esp)
c010a701:	e8 cb b9 ff ff       	call   c01060d1 <pgdir_alloc_page>
c010a706:	85 c0                	test   %eax,%eax
c010a708:	75 24                	jne    c010a72e <load_icode+0x4d5>
c010a70a:	c7 44 24 0c 60 e2 10 	movl   $0xc010e260,0xc(%esp)
c010a711:	c0 
c010a712:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010a719:	c0 
c010a71a:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c010a721:	00 
c010a722:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a729:	e8 bd 66 ff ff       	call   c0100deb <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a72e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a731:	8b 40 0c             	mov    0xc(%eax),%eax
c010a734:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a73b:	00 
c010a73c:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a743:	af 
c010a744:	89 04 24             	mov    %eax,(%esp)
c010a747:	e8 85 b9 ff ff       	call   c01060d1 <pgdir_alloc_page>
c010a74c:	85 c0                	test   %eax,%eax
c010a74e:	75 24                	jne    c010a774 <load_icode+0x51b>
c010a750:	c7 44 24 0c a4 e2 10 	movl   $0xc010e2a4,0xc(%esp)
c010a757:	c0 
c010a758:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010a75f:	c0 
c010a760:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
c010a767:	00 
c010a768:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a76f:	e8 77 66 ff ff       	call   c0100deb <__panic>
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a774:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a777:	89 04 24             	mov    %eax,(%esp)
c010a77a:	e8 a4 ee ff ff       	call   c0109623 <mm_count_inc>
    current->mm = mm;
c010a77f:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a784:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a787:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a78a:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a78f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a792:	8b 52 0c             	mov    0xc(%edx),%edx
c010a795:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a798:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a79f:	77 23                	ja     c010a7c4 <load_icode+0x56b>
c010a7a1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a7a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a7a8:	c7 44 24 08 cc e0 10 	movl   $0xc010e0cc,0x8(%esp)
c010a7af:	c0 
c010a7b0:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
c010a7b7:	00 
c010a7b8:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a7bf:	e8 27 66 ff ff       	call   c0100deb <__panic>
c010a7c4:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a7c7:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a7cd:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a7d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7d3:	8b 40 0c             	mov    0xc(%eax),%eax
c010a7d6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a7d9:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a7e0:	77 23                	ja     c010a805 <load_icode+0x5ac>
c010a7e2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a7e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a7e9:	c7 44 24 08 cc e0 10 	movl   $0xc010e0cc,0x8(%esp)
c010a7f0:	c0 
c010a7f1:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c010a7f8:	00 
c010a7f9:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a800:	e8 e6 65 ff ff       	call   c0100deb <__panic>
c010a805:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a808:	05 00 00 00 40       	add    $0x40000000,%eax
c010a80d:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a810:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a813:	0f 22 d8             	mov    %eax,%cr3

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a816:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a81b:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a81e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a821:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a828:	00 
c010a829:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a830:	00 
c010a831:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a834:	89 04 24             	mov    %eax,(%esp)
c010a837:	e8 1d 16 00 00       	call   c010be59 <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010a83c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a83f:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a845:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a848:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a84e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a851:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a855:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a858:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a85c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a85f:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a863:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a866:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a86a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a86d:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a874:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a877:	8b 50 18             	mov    0x18(%eax),%edx
c010a87a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a87d:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a880:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a883:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a88a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a891:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a894:	eb 23                	jmp    c010a8b9 <load_icode+0x660>
bad_cleanup_mmap:
    exit_mmap(mm);
c010a896:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a899:	89 04 24             	mov    %eax,(%esp)
c010a89c:	e8 02 de ff ff       	call   c01086a3 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010a8a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8a4:	89 04 24             	mov    %eax,(%esp)
c010a8a7:	e8 a2 f4 ff ff       	call   c0109d4e <put_pgdir>
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a8ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8af:	89 04 24             	mov    %eax,(%esp)
c010a8b2:	e8 2d db ff ff       	call   c01083e4 <mm_destroy>
bad_mm:
    goto out;
c010a8b7:	eb d8                	jmp    c010a891 <load_icode+0x638>
}
c010a8b9:	c9                   	leave  
c010a8ba:	c3                   	ret    

c010a8bb <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a8bb:	55                   	push   %ebp
c010a8bc:	89 e5                	mov    %esp,%ebp
c010a8be:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a8c1:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a8c6:	8b 40 18             	mov    0x18(%eax),%eax
c010a8c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a8cc:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a8d6:	00 
c010a8d7:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a8da:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a8de:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a8e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a8e5:	89 04 24             	mov    %eax,(%esp)
c010a8e8:	e8 5a e8 ff ff       	call   c0109147 <user_mem_check>
c010a8ed:	85 c0                	test   %eax,%eax
c010a8ef:	75 0a                	jne    c010a8fb <do_execve+0x40>
        return -E_INVAL;
c010a8f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a8f6:	e9 f4 00 00 00       	jmp    c010a9ef <do_execve+0x134>
    }
    if (len > PROC_NAME_LEN) {
c010a8fb:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a8ff:	76 07                	jbe    c010a908 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a901:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a908:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a90f:	00 
c010a910:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a917:	00 
c010a918:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a91b:	89 04 24             	mov    %eax,(%esp)
c010a91e:	e8 36 15 00 00       	call   c010be59 <memset>
    memcpy(local_name, name, len);
c010a923:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a926:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a92a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a92d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a931:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a934:	89 04 24             	mov    %eax,(%esp)
c010a937:	e8 ff 15 00 00       	call   c010bf3b <memcpy>

    if (mm != NULL) {
c010a93c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a940:	74 4a                	je     c010a98c <do_execve+0xd1>
        lcr3(boot_cr3);
c010a942:	a1 e0 10 1a c0       	mov    0xc01a10e0,%eax
c010a947:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a94a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a94d:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a950:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a953:	89 04 24             	mov    %eax,(%esp)
c010a956:	e8 e2 ec ff ff       	call   c010963d <mm_count_dec>
c010a95b:	85 c0                	test   %eax,%eax
c010a95d:	75 21                	jne    c010a980 <do_execve+0xc5>
            exit_mmap(mm);
c010a95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a962:	89 04 24             	mov    %eax,(%esp)
c010a965:	e8 39 dd ff ff       	call   c01086a3 <exit_mmap>
            put_pgdir(mm);
c010a96a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a96d:	89 04 24             	mov    %eax,(%esp)
c010a970:	e8 d9 f3 ff ff       	call   c0109d4e <put_pgdir>
            mm_destroy(mm);
c010a975:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a978:	89 04 24             	mov    %eax,(%esp)
c010a97b:	e8 64 da ff ff       	call   c01083e4 <mm_destroy>
        }
        current->mm = NULL;
c010a980:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a985:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010a98c:	8b 45 14             	mov    0x14(%ebp),%eax
c010a98f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a993:	8b 45 10             	mov    0x10(%ebp),%eax
c010a996:	89 04 24             	mov    %eax,(%esp)
c010a999:	e8 bb f8 ff ff       	call   c010a259 <load_icode>
c010a99e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a9a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a9a5:	74 2f                	je     c010a9d6 <do_execve+0x11b>
        goto execve_exit;
c010a9a7:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a9a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a9ab:	89 04 24             	mov    %eax,(%esp)
c010a9ae:	e8 d6 f6 ff ff       	call   c010a089 <do_exit>
    panic("already exit: %e.\n", ret);
c010a9b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a9b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a9ba:	c7 44 24 08 e7 e2 10 	movl   $0xc010e2e7,0x8(%esp)
c010a9c1:	c0 
c010a9c2:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
c010a9c9:	00 
c010a9ca:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010a9d1:	e8 15 64 ff ff       	call   c0100deb <__panic>
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010a9d6:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a9db:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a9de:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a9e2:	89 04 24             	mov    %eax,(%esp)
c010a9e5:	e8 96 ed ff ff       	call   c0109780 <set_proc_name>
    return 0;
c010a9ea:	b8 00 00 00 00       	mov    $0x0,%eax

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
c010a9ef:	c9                   	leave  
c010a9f0:	c3                   	ret    

c010a9f1 <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010a9f1:	55                   	push   %ebp
c010a9f2:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010a9f4:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010a9f9:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010aa00:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aa05:	5d                   	pop    %ebp
c010aa06:	c3                   	ret    

c010aa07 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010aa07:	55                   	push   %ebp
c010aa08:	89 e5                	mov    %esp,%ebp
c010aa0a:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010aa0d:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010aa12:	8b 40 18             	mov    0x18(%eax),%eax
c010aa15:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010aa18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010aa1c:	74 30                	je     c010aa4e <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010aa1e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa21:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010aa28:	00 
c010aa29:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010aa30:	00 
c010aa31:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa35:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aa38:	89 04 24             	mov    %eax,(%esp)
c010aa3b:	e8 07 e7 ff ff       	call   c0109147 <user_mem_check>
c010aa40:	85 c0                	test   %eax,%eax
c010aa42:	75 0a                	jne    c010aa4e <do_wait+0x47>
            return -E_INVAL;
c010aa44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010aa49:	e9 4b 01 00 00       	jmp    c010ab99 <do_wait+0x192>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010aa4e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010aa55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aa59:	74 39                	je     c010aa94 <do_wait+0x8d>
        proc = find_proc(pid);
c010aa5b:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa5e:	89 04 24             	mov    %eax,(%esp)
c010aa61:	e8 fb f0 ff ff       	call   c0109b61 <find_proc>
c010aa66:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010aa69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aa6d:	74 54                	je     c010aac3 <do_wait+0xbc>
c010aa6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa72:	8b 50 14             	mov    0x14(%eax),%edx
c010aa75:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010aa7a:	39 c2                	cmp    %eax,%edx
c010aa7c:	75 45                	jne    c010aac3 <do_wait+0xbc>
            haskid = 1;
c010aa7e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010aa85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa88:	8b 00                	mov    (%eax),%eax
c010aa8a:	83 f8 03             	cmp    $0x3,%eax
c010aa8d:	75 34                	jne    c010aac3 <do_wait+0xbc>
                goto found;
c010aa8f:	e9 80 00 00 00       	jmp    c010ab14 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
c010aa94:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010aa99:	8b 40 70             	mov    0x70(%eax),%eax
c010aa9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010aa9f:	eb 1c                	jmp    c010aabd <do_wait+0xb6>
            haskid = 1;
c010aaa1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010aaa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaab:	8b 00                	mov    (%eax),%eax
c010aaad:	83 f8 03             	cmp    $0x3,%eax
c010aab0:	75 02                	jne    c010aab4 <do_wait+0xad>
                goto found;
c010aab2:	eb 60                	jmp    c010ab14 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
c010aab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aab7:	8b 40 78             	mov    0x78(%eax),%eax
c010aaba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aabd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aac1:	75 de                	jne    c010aaa1 <do_wait+0x9a>
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
c010aac3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010aac7:	74 41                	je     c010ab0a <do_wait+0x103>
        current->state = PROC_SLEEPING;
c010aac9:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010aace:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010aad4:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010aad9:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010aae0:	e8 09 06 00 00       	call   c010b0ee <schedule>
        if (current->flags & PF_EXITING) {
c010aae5:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010aaea:	8b 40 44             	mov    0x44(%eax),%eax
c010aaed:	83 e0 01             	and    $0x1,%eax
c010aaf0:	85 c0                	test   %eax,%eax
c010aaf2:	74 11                	je     c010ab05 <do_wait+0xfe>
            do_exit(-E_KILLED);
c010aaf4:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010aafb:	e8 89 f5 ff ff       	call   c010a089 <do_exit>
        }
        goto repeat;
c010ab00:	e9 49 ff ff ff       	jmp    c010aa4e <do_wait+0x47>
c010ab05:	e9 44 ff ff ff       	jmp    c010aa4e <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010ab0a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010ab0f:	e9 85 00 00 00       	jmp    c010ab99 <do_wait+0x192>

found:
    if (proc == idleproc || proc == initproc) {
c010ab14:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010ab19:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ab1c:	74 0a                	je     c010ab28 <do_wait+0x121>
c010ab1e:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010ab23:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ab26:	75 1c                	jne    c010ab44 <do_wait+0x13d>
        panic("wait idleproc or initproc.\n");
c010ab28:	c7 44 24 08 fa e2 10 	movl   $0xc010e2fa,0x8(%esp)
c010ab2f:	c0 
c010ab30:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
c010ab37:	00 
c010ab38:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010ab3f:	e8 a7 62 ff ff       	call   c0100deb <__panic>
    }
    if (code_store != NULL) {
c010ab44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ab48:	74 0b                	je     c010ab55 <do_wait+0x14e>
        *code_store = proc->exit_code;
c010ab4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab4d:	8b 50 68             	mov    0x68(%eax),%edx
c010ab50:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab53:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010ab55:	e8 03 e9 ff ff       	call   c010945d <__intr_save>
c010ab5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010ab5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab60:	89 04 24             	mov    %eax,(%esp)
c010ab63:	e8 c6 ef ff ff       	call   c0109b2e <unhash_proc>
        remove_links(proc);
c010ab68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab6b:	89 04 24             	mov    %eax,(%esp)
c010ab6e:	e8 37 ed ff ff       	call   c01098aa <remove_links>
    }
    local_intr_restore(intr_flag);
c010ab73:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ab76:	89 04 24             	mov    %eax,(%esp)
c010ab79:	e8 09 e9 ff ff       	call   c0109487 <__intr_restore>
    put_kstack(proc);
c010ab7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab81:	89 04 24             	mov    %eax,(%esp)
c010ab84:	e8 f8 f0 ff ff       	call   c0109c81 <put_kstack>
    kfree(proc);
c010ab89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab8c:	89 04 24             	mov    %eax,(%esp)
c010ab8f:	e8 95 a2 ff ff       	call   c0104e29 <kfree>
    return 0;
c010ab94:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ab99:	c9                   	leave  
c010ab9a:	c3                   	ret    

c010ab9b <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010ab9b:	55                   	push   %ebp
c010ab9c:	89 e5                	mov    %esp,%ebp
c010ab9e:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010aba1:	8b 45 08             	mov    0x8(%ebp),%eax
c010aba4:	89 04 24             	mov    %eax,(%esp)
c010aba7:	e8 b5 ef ff ff       	call   c0109b61 <find_proc>
c010abac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010abaf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010abb3:	74 41                	je     c010abf6 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010abb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abb8:	8b 40 44             	mov    0x44(%eax),%eax
c010abbb:	83 e0 01             	and    $0x1,%eax
c010abbe:	85 c0                	test   %eax,%eax
c010abc0:	75 2d                	jne    c010abef <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010abc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abc5:	8b 40 44             	mov    0x44(%eax),%eax
c010abc8:	83 c8 01             	or     $0x1,%eax
c010abcb:	89 c2                	mov    %eax,%edx
c010abcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abd0:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010abd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abd6:	8b 40 6c             	mov    0x6c(%eax),%eax
c010abd9:	85 c0                	test   %eax,%eax
c010abdb:	79 0b                	jns    c010abe8 <do_kill+0x4d>
                wakeup_proc(proc);
c010abdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abe0:	89 04 24             	mov    %eax,(%esp)
c010abe3:	e8 82 04 00 00       	call   c010b06a <wakeup_proc>
            }
            return 0;
c010abe8:	b8 00 00 00 00       	mov    $0x0,%eax
c010abed:	eb 0c                	jmp    c010abfb <do_kill+0x60>
        }
        return -E_KILLED;
c010abef:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010abf4:	eb 05                	jmp    c010abfb <do_kill+0x60>
    }
    return -E_INVAL;
c010abf6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010abfb:	c9                   	leave  
c010abfc:	c3                   	ret    

c010abfd <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010abfd:	55                   	push   %ebp
c010abfe:	89 e5                	mov    %esp,%ebp
c010ac00:	57                   	push   %edi
c010ac01:	56                   	push   %esi
c010ac02:	53                   	push   %ebx
c010ac03:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010ac06:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac09:	89 04 24             	mov    %eax,(%esp)
c010ac0c:	e8 19 0f 00 00       	call   c010bb2a <strlen>
c010ac11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010ac14:	b8 04 00 00 00       	mov    $0x4,%eax
c010ac19:	8b 55 08             	mov    0x8(%ebp),%edx
c010ac1c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010ac1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010ac22:	8b 75 10             	mov    0x10(%ebp),%esi
c010ac25:	89 f7                	mov    %esi,%edi
c010ac27:	cd 80                	int    $0x80
c010ac29:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010ac2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010ac2f:	83 c4 2c             	add    $0x2c,%esp
c010ac32:	5b                   	pop    %ebx
c010ac33:	5e                   	pop    %esi
c010ac34:	5f                   	pop    %edi
c010ac35:	5d                   	pop    %ebp
c010ac36:	c3                   	ret    

c010ac37 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010ac37:	55                   	push   %ebp
c010ac38:	89 e5                	mov    %esp,%ebp
c010ac3a:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
c010ac3d:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010ac42:	8b 40 04             	mov    0x4(%eax),%eax
c010ac45:	c7 44 24 08 16 e3 10 	movl   $0xc010e316,0x8(%esp)
c010ac4c:	c0 
c010ac4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac51:	c7 04 24 20 e3 10 c0 	movl   $0xc010e320,(%esp)
c010ac58:	e8 02 57 ff ff       	call   c010035f <cprintf>
c010ac5d:	b8 e2 78 00 00       	mov    $0x78e2,%eax
c010ac62:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ac66:	c7 44 24 04 79 f8 15 	movl   $0xc015f879,0x4(%esp)
c010ac6d:	c0 
c010ac6e:	c7 04 24 16 e3 10 c0 	movl   $0xc010e316,(%esp)
c010ac75:	e8 83 ff ff ff       	call   c010abfd <kernel_execve>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
c010ac7a:	c7 44 24 08 47 e3 10 	movl   $0xc010e347,0x8(%esp)
c010ac81:	c0 
c010ac82:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
c010ac89:	00 
c010ac8a:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010ac91:	e8 55 61 ff ff       	call   c0100deb <__panic>

c010ac96 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ac96:	55                   	push   %ebp
c010ac97:	89 e5                	mov    %esp,%ebp
c010ac99:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ac9c:	e8 7f a6 ff ff       	call   c0105320 <nr_free_pages>
c010aca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010aca4:	e8 48 a0 ff ff       	call   c0104cf1 <kallocated>
c010aca9:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010acac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010acb3:	00 
c010acb4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010acbb:	00 
c010acbc:	c7 04 24 37 ac 10 c0 	movl   $0xc010ac37,(%esp)
c010acc3:	e8 0b ef ff ff       	call   c0109bd3 <kernel_thread>
c010acc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010accb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010accf:	7f 1c                	jg     c010aced <init_main+0x57>
        panic("create user_main failed.\n");
c010acd1:	c7 44 24 08 61 e3 10 	movl   $0xc010e361,0x8(%esp)
c010acd8:	c0 
c010acd9:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
c010ace0:	00 
c010ace1:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010ace8:	e8 fe 60 ff ff       	call   c0100deb <__panic>
    }

    while (do_wait(0, NULL) == 0) {
c010aced:	eb 05                	jmp    c010acf4 <init_main+0x5e>
        schedule();
c010acef:	e8 fa 03 00 00       	call   c010b0ee <schedule>
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
c010acf4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010acfb:	00 
c010acfc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ad03:	e8 ff fc ff ff       	call   c010aa07 <do_wait>
c010ad08:	85 c0                	test   %eax,%eax
c010ad0a:	74 e3                	je     c010acef <init_main+0x59>
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
c010ad0c:	c7 04 24 7c e3 10 c0 	movl   $0xc010e37c,(%esp)
c010ad13:	e8 47 56 ff ff       	call   c010035f <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010ad18:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010ad1d:	8b 40 70             	mov    0x70(%eax),%eax
c010ad20:	85 c0                	test   %eax,%eax
c010ad22:	75 18                	jne    c010ad3c <init_main+0xa6>
c010ad24:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010ad29:	8b 40 74             	mov    0x74(%eax),%eax
c010ad2c:	85 c0                	test   %eax,%eax
c010ad2e:	75 0c                	jne    c010ad3c <init_main+0xa6>
c010ad30:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010ad35:	8b 40 78             	mov    0x78(%eax),%eax
c010ad38:	85 c0                	test   %eax,%eax
c010ad3a:	74 24                	je     c010ad60 <init_main+0xca>
c010ad3c:	c7 44 24 0c a0 e3 10 	movl   $0xc010e3a0,0xc(%esp)
c010ad43:	c0 
c010ad44:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010ad4b:	c0 
c010ad4c:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
c010ad53:	00 
c010ad54:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010ad5b:	e8 8b 60 ff ff       	call   c0100deb <__panic>
    assert(nr_process == 2);
c010ad60:	a1 60 10 1a c0       	mov    0xc01a1060,%eax
c010ad65:	83 f8 02             	cmp    $0x2,%eax
c010ad68:	74 24                	je     c010ad8e <init_main+0xf8>
c010ad6a:	c7 44 24 0c eb e3 10 	movl   $0xc010e3eb,0xc(%esp)
c010ad71:	c0 
c010ad72:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010ad79:	c0 
c010ad7a:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
c010ad81:	00 
c010ad82:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010ad89:	e8 5d 60 ff ff       	call   c0100deb <__panic>
c010ad8e:	c7 45 e8 d0 11 1a c0 	movl   $0xc01a11d0,-0x18(%ebp)
c010ad95:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad98:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010ad9b:	8b 15 44 f0 19 c0    	mov    0xc019f044,%edx
c010ada1:	83 c2 58             	add    $0x58,%edx
c010ada4:	39 d0                	cmp    %edx,%eax
c010ada6:	74 24                	je     c010adcc <init_main+0x136>
c010ada8:	c7 44 24 0c fc e3 10 	movl   $0xc010e3fc,0xc(%esp)
c010adaf:	c0 
c010adb0:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010adb7:	c0 
c010adb8:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
c010adbf:	00 
c010adc0:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010adc7:	e8 1f 60 ff ff       	call   c0100deb <__panic>
c010adcc:	c7 45 e4 d0 11 1a c0 	movl   $0xc01a11d0,-0x1c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c010add3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010add6:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010add8:	8b 15 44 f0 19 c0    	mov    0xc019f044,%edx
c010adde:	83 c2 58             	add    $0x58,%edx
c010ade1:	39 d0                	cmp    %edx,%eax
c010ade3:	74 24                	je     c010ae09 <init_main+0x173>
c010ade5:	c7 44 24 0c 2c e4 10 	movl   $0xc010e42c,0xc(%esp)
c010adec:	c0 
c010aded:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010adf4:	c0 
c010adf5:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
c010adfc:	00 
c010adfd:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010ae04:	e8 e2 5f ff ff       	call   c0100deb <__panic>

    cprintf("init check memory pass.\n");
c010ae09:	c7 04 24 5c e4 10 c0 	movl   $0xc010e45c,(%esp)
c010ae10:	e8 4a 55 ff ff       	call   c010035f <cprintf>
    return 0;
c010ae15:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ae1a:	c9                   	leave  
c010ae1b:	c3                   	ret    

c010ae1c <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010ae1c:	55                   	push   %ebp
c010ae1d:	89 e5                	mov    %esp,%ebp
c010ae1f:	83 ec 28             	sub    $0x28,%esp
c010ae22:	c7 45 ec d0 11 1a c0 	movl   $0xc01a11d0,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010ae29:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ae2c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ae2f:	89 50 04             	mov    %edx,0x4(%eax)
c010ae32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ae35:	8b 50 04             	mov    0x4(%eax),%edx
c010ae38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ae3b:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ae3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010ae44:	eb 26                	jmp    c010ae6c <proc_init+0x50>
        list_init(hash_list + i);
c010ae46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae49:	c1 e0 03             	shl    $0x3,%eax
c010ae4c:	05 60 f0 19 c0       	add    $0xc019f060,%eax
c010ae51:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ae54:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae57:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ae5a:	89 50 04             	mov    %edx,0x4(%eax)
c010ae5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae60:	8b 50 04             	mov    0x4(%eax),%edx
c010ae63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae66:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ae68:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010ae6c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010ae73:	7e d1                	jle    c010ae46 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010ae75:	e8 15 e8 ff ff       	call   c010968f <alloc_proc>
c010ae7a:	a3 40 f0 19 c0       	mov    %eax,0xc019f040
c010ae7f:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010ae84:	85 c0                	test   %eax,%eax
c010ae86:	75 1c                	jne    c010aea4 <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010ae88:	c7 44 24 08 75 e4 10 	movl   $0xc010e475,0x8(%esp)
c010ae8f:	c0 
c010ae90:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
c010ae97:	00 
c010ae98:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010ae9f:	e8 47 5f ff ff       	call   c0100deb <__panic>
    }

    idleproc->pid = 0;
c010aea4:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010aea9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010aeb0:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010aeb5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010aebb:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010aec0:	ba 00 80 12 c0       	mov    $0xc0128000,%edx
c010aec5:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010aec8:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010aecd:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010aed4:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010aed9:	c7 44 24 04 8d e4 10 	movl   $0xc010e48d,0x4(%esp)
c010aee0:	c0 
c010aee1:	89 04 24             	mov    %eax,(%esp)
c010aee4:	e8 97 e8 ff ff       	call   c0109780 <set_proc_name>
    nr_process ++;
c010aee9:	a1 60 10 1a c0       	mov    0xc01a1060,%eax
c010aeee:	83 c0 01             	add    $0x1,%eax
c010aef1:	a3 60 10 1a c0       	mov    %eax,0xc01a1060

    current = idleproc;
c010aef6:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010aefb:	a3 48 f0 19 c0       	mov    %eax,0xc019f048

    int pid = kernel_thread(init_main, NULL, 0);
c010af00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010af07:	00 
c010af08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010af0f:	00 
c010af10:	c7 04 24 96 ac 10 c0 	movl   $0xc010ac96,(%esp)
c010af17:	e8 b7 ec ff ff       	call   c0109bd3 <kernel_thread>
c010af1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010af1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010af23:	7f 1c                	jg     c010af41 <proc_init+0x125>
        panic("create init_main failed.\n");
c010af25:	c7 44 24 08 92 e4 10 	movl   $0xc010e492,0x8(%esp)
c010af2c:	c0 
c010af2d:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
c010af34:	00 
c010af35:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010af3c:	e8 aa 5e ff ff       	call   c0100deb <__panic>
    }

    initproc = find_proc(pid);
c010af41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010af44:	89 04 24             	mov    %eax,(%esp)
c010af47:	e8 15 ec ff ff       	call   c0109b61 <find_proc>
c010af4c:	a3 44 f0 19 c0       	mov    %eax,0xc019f044
    set_proc_name(initproc, "init");
c010af51:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010af56:	c7 44 24 04 ac e4 10 	movl   $0xc010e4ac,0x4(%esp)
c010af5d:	c0 
c010af5e:	89 04 24             	mov    %eax,(%esp)
c010af61:	e8 1a e8 ff ff       	call   c0109780 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010af66:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010af6b:	85 c0                	test   %eax,%eax
c010af6d:	74 0c                	je     c010af7b <proc_init+0x15f>
c010af6f:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010af74:	8b 40 04             	mov    0x4(%eax),%eax
c010af77:	85 c0                	test   %eax,%eax
c010af79:	74 24                	je     c010af9f <proc_init+0x183>
c010af7b:	c7 44 24 0c b4 e4 10 	movl   $0xc010e4b4,0xc(%esp)
c010af82:	c0 
c010af83:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010af8a:	c0 
c010af8b:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
c010af92:	00 
c010af93:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010af9a:	e8 4c 5e ff ff       	call   c0100deb <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010af9f:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010afa4:	85 c0                	test   %eax,%eax
c010afa6:	74 0d                	je     c010afb5 <proc_init+0x199>
c010afa8:	a1 44 f0 19 c0       	mov    0xc019f044,%eax
c010afad:	8b 40 04             	mov    0x4(%eax),%eax
c010afb0:	83 f8 01             	cmp    $0x1,%eax
c010afb3:	74 24                	je     c010afd9 <proc_init+0x1bd>
c010afb5:	c7 44 24 0c dc e4 10 	movl   $0xc010e4dc,0xc(%esp)
c010afbc:	c0 
c010afbd:	c7 44 24 08 1d e1 10 	movl   $0xc010e11d,0x8(%esp)
c010afc4:	c0 
c010afc5:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
c010afcc:	00 
c010afcd:	c7 04 24 f0 e0 10 c0 	movl   $0xc010e0f0,(%esp)
c010afd4:	e8 12 5e ff ff       	call   c0100deb <__panic>
}
c010afd9:	c9                   	leave  
c010afda:	c3                   	ret    

c010afdb <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010afdb:	55                   	push   %ebp
c010afdc:	89 e5                	mov    %esp,%ebp
c010afde:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010afe1:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010afe6:	8b 40 10             	mov    0x10(%eax),%eax
c010afe9:	85 c0                	test   %eax,%eax
c010afeb:	74 07                	je     c010aff4 <cpu_idle+0x19>
            schedule();
c010afed:	e8 fc 00 00 00       	call   c010b0ee <schedule>
        }
    }
c010aff2:	eb ed                	jmp    c010afe1 <cpu_idle+0x6>
c010aff4:	eb eb                	jmp    c010afe1 <cpu_idle+0x6>

c010aff6 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010aff6:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010affa:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010affc:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010afff:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010b002:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010b005:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010b008:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010b00b:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010b00e:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010b011:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010b015:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010b018:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010b01b:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010b01e:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010b021:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010b024:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010b027:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010b02a:	ff 30                	pushl  (%eax)

    ret
c010b02c:	c3                   	ret    

c010b02d <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010b02d:	55                   	push   %ebp
c010b02e:	89 e5                	mov    %esp,%ebp
c010b030:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010b033:	9c                   	pushf  
c010b034:	58                   	pop    %eax
c010b035:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010b038:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010b03b:	25 00 02 00 00       	and    $0x200,%eax
c010b040:	85 c0                	test   %eax,%eax
c010b042:	74 0c                	je     c010b050 <__intr_save+0x23>
        intr_disable();
c010b044:	e8 0b 70 ff ff       	call   c0102054 <intr_disable>
        return 1;
c010b049:	b8 01 00 00 00       	mov    $0x1,%eax
c010b04e:	eb 05                	jmp    c010b055 <__intr_save+0x28>
    }
    return 0;
c010b050:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b055:	c9                   	leave  
c010b056:	c3                   	ret    

c010b057 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010b057:	55                   	push   %ebp
c010b058:	89 e5                	mov    %esp,%ebp
c010b05a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010b05d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b061:	74 05                	je     c010b068 <__intr_restore+0x11>
        intr_enable();
c010b063:	e8 e6 6f ff ff       	call   c010204e <intr_enable>
    }
}
c010b068:	c9                   	leave  
c010b069:	c3                   	ret    

c010b06a <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010b06a:	55                   	push   %ebp
c010b06b:	89 e5                	mov    %esp,%ebp
c010b06d:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b070:	8b 45 08             	mov    0x8(%ebp),%eax
c010b073:	8b 00                	mov    (%eax),%eax
c010b075:	83 f8 03             	cmp    $0x3,%eax
c010b078:	75 24                	jne    c010b09e <wakeup_proc+0x34>
c010b07a:	c7 44 24 0c 03 e5 10 	movl   $0xc010e503,0xc(%esp)
c010b081:	c0 
c010b082:	c7 44 24 08 1e e5 10 	movl   $0xc010e51e,0x8(%esp)
c010b089:	c0 
c010b08a:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010b091:	00 
c010b092:	c7 04 24 33 e5 10 c0 	movl   $0xc010e533,(%esp)
c010b099:	e8 4d 5d ff ff       	call   c0100deb <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b09e:	e8 8a ff ff ff       	call   c010b02d <__intr_save>
c010b0a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b0a6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0a9:	8b 00                	mov    (%eax),%eax
c010b0ab:	83 f8 02             	cmp    $0x2,%eax
c010b0ae:	74 15                	je     c010b0c5 <wakeup_proc+0x5b>
            proc->state = PROC_RUNNABLE;
c010b0b0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0b3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b0b9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0bc:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010b0c3:	eb 1c                	jmp    c010b0e1 <wakeup_proc+0x77>
        }
        else {
            warn("wakeup runnable process.\n");
c010b0c5:	c7 44 24 08 49 e5 10 	movl   $0xc010e549,0x8(%esp)
c010b0cc:	c0 
c010b0cd:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010b0d4:	00 
c010b0d5:	c7 04 24 33 e5 10 c0 	movl   $0xc010e533,(%esp)
c010b0dc:	e8 87 5d ff ff       	call   c0100e68 <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b0e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0e4:	89 04 24             	mov    %eax,(%esp)
c010b0e7:	e8 6b ff ff ff       	call   c010b057 <__intr_restore>
}
c010b0ec:	c9                   	leave  
c010b0ed:	c3                   	ret    

c010b0ee <schedule>:

void
schedule(void) {
c010b0ee:	55                   	push   %ebp
c010b0ef:	89 e5                	mov    %esp,%ebp
c010b0f1:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010b0f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010b0fb:	e8 2d ff ff ff       	call   c010b02d <__intr_save>
c010b100:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010b103:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b108:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010b10f:	8b 15 48 f0 19 c0    	mov    0xc019f048,%edx
c010b115:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010b11a:	39 c2                	cmp    %eax,%edx
c010b11c:	74 0a                	je     c010b128 <schedule+0x3a>
c010b11e:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b123:	83 c0 58             	add    $0x58,%eax
c010b126:	eb 05                	jmp    c010b12d <schedule+0x3f>
c010b128:	b8 d0 11 1a c0       	mov    $0xc01a11d0,%eax
c010b12d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010b130:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b133:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b136:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010b13c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b13f:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010b142:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b145:	81 7d f4 d0 11 1a c0 	cmpl   $0xc01a11d0,-0xc(%ebp)
c010b14c:	74 15                	je     c010b163 <schedule+0x75>
                next = le2proc(le, list_link);
c010b14e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b151:	83 e8 58             	sub    $0x58,%eax
c010b154:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010b157:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b15a:	8b 00                	mov    (%eax),%eax
c010b15c:	83 f8 02             	cmp    $0x2,%eax
c010b15f:	75 02                	jne    c010b163 <schedule+0x75>
                    break;
c010b161:	eb 08                	jmp    c010b16b <schedule+0x7d>
                }
            }
        } while (le != last);
c010b163:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b166:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010b169:	75 cb                	jne    c010b136 <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010b16b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b16f:	74 0a                	je     c010b17b <schedule+0x8d>
c010b171:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b174:	8b 00                	mov    (%eax),%eax
c010b176:	83 f8 02             	cmp    $0x2,%eax
c010b179:	74 08                	je     c010b183 <schedule+0x95>
            next = idleproc;
c010b17b:	a1 40 f0 19 c0       	mov    0xc019f040,%eax
c010b180:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010b183:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b186:	8b 40 08             	mov    0x8(%eax),%eax
c010b189:	8d 50 01             	lea    0x1(%eax),%edx
c010b18c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b18f:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b192:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b197:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b19a:	74 0b                	je     c010b1a7 <schedule+0xb9>
            proc_run(next);
c010b19c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b19f:	89 04 24             	mov    %eax,(%esp)
c010b1a2:	e8 7e e8 ff ff       	call   c0109a25 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b1a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b1aa:	89 04 24             	mov    %eax,(%esp)
c010b1ad:	e8 a5 fe ff ff       	call   c010b057 <__intr_restore>
}
c010b1b2:	c9                   	leave  
c010b1b3:	c3                   	ret    

c010b1b4 <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010b1b4:	55                   	push   %ebp
c010b1b5:	89 e5                	mov    %esp,%ebp
c010b1b7:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b1ba:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1bd:	8b 00                	mov    (%eax),%eax
c010b1bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b1c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1c5:	89 04 24             	mov    %eax,(%esp)
c010b1c8:	e8 bc ee ff ff       	call   c010a089 <do_exit>
}
c010b1cd:	c9                   	leave  
c010b1ce:	c3                   	ret    

c010b1cf <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b1cf:	55                   	push   %ebp
c010b1d0:	89 e5                	mov    %esp,%ebp
c010b1d2:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b1d5:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b1da:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b1dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b1e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1e3:	8b 40 44             	mov    0x44(%eax),%eax
c010b1e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b1e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b1f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b1f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b1fe:	e8 65 ed ff ff       	call   c0109f68 <do_fork>
}
c010b203:	c9                   	leave  
c010b204:	c3                   	ret    

c010b205 <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b205:	55                   	push   %ebp
c010b206:	89 e5                	mov    %esp,%ebp
c010b208:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b20b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b20e:	8b 00                	mov    (%eax),%eax
c010b210:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b213:	8b 45 08             	mov    0x8(%ebp),%eax
c010b216:	83 c0 04             	add    $0x4,%eax
c010b219:	8b 00                	mov    (%eax),%eax
c010b21b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b21e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b221:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b225:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b228:	89 04 24             	mov    %eax,(%esp)
c010b22b:	e8 d7 f7 ff ff       	call   c010aa07 <do_wait>
}
c010b230:	c9                   	leave  
c010b231:	c3                   	ret    

c010b232 <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b232:	55                   	push   %ebp
c010b233:	89 e5                	mov    %esp,%ebp
c010b235:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b238:	8b 45 08             	mov    0x8(%ebp),%eax
c010b23b:	8b 00                	mov    (%eax),%eax
c010b23d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b240:	8b 45 08             	mov    0x8(%ebp),%eax
c010b243:	8b 40 04             	mov    0x4(%eax),%eax
c010b246:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b249:	8b 45 08             	mov    0x8(%ebp),%eax
c010b24c:	83 c0 08             	add    $0x8,%eax
c010b24f:	8b 00                	mov    (%eax),%eax
c010b251:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b254:	8b 45 08             	mov    0x8(%ebp),%eax
c010b257:	8b 40 0c             	mov    0xc(%eax),%eax
c010b25a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b25d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b260:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b264:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b267:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b26b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b26e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b272:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b275:	89 04 24             	mov    %eax,(%esp)
c010b278:	e8 3e f6 ff ff       	call   c010a8bb <do_execve>
}
c010b27d:	c9                   	leave  
c010b27e:	c3                   	ret    

c010b27f <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b27f:	55                   	push   %ebp
c010b280:	89 e5                	mov    %esp,%ebp
c010b282:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b285:	e8 67 f7 ff ff       	call   c010a9f1 <do_yield>
}
c010b28a:	c9                   	leave  
c010b28b:	c3                   	ret    

c010b28c <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b28c:	55                   	push   %ebp
c010b28d:	89 e5                	mov    %esp,%ebp
c010b28f:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b292:	8b 45 08             	mov    0x8(%ebp),%eax
c010b295:	8b 00                	mov    (%eax),%eax
c010b297:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b29a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b29d:	89 04 24             	mov    %eax,(%esp)
c010b2a0:	e8 f6 f8 ff ff       	call   c010ab9b <do_kill>
}
c010b2a5:	c9                   	leave  
c010b2a6:	c3                   	ret    

c010b2a7 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b2a7:	55                   	push   %ebp
c010b2a8:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b2aa:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b2af:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b2b2:	5d                   	pop    %ebp
c010b2b3:	c3                   	ret    

c010b2b4 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b2b4:	55                   	push   %ebp
c010b2b5:	89 e5                	mov    %esp,%ebp
c010b2b7:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b2ba:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2bd:	8b 00                	mov    (%eax),%eax
c010b2bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2c5:	89 04 24             	mov    %eax,(%esp)
c010b2c8:	e8 b8 50 ff ff       	call   c0100385 <cputchar>
    return 0;
c010b2cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b2d2:	c9                   	leave  
c010b2d3:	c3                   	ret    

c010b2d4 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b2d4:	55                   	push   %ebp
c010b2d5:	89 e5                	mov    %esp,%ebp
c010b2d7:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b2da:	e8 0c ba ff ff       	call   c0106ceb <print_pgdir>
    return 0;
c010b2df:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b2e4:	c9                   	leave  
c010b2e5:	c3                   	ret    

c010b2e6 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b2e6:	55                   	push   %ebp
c010b2e7:	89 e5                	mov    %esp,%ebp
c010b2e9:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b2ec:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b2f1:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b2f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b2f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2fa:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b2fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b300:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b304:	78 5e                	js     c010b364 <syscall+0x7e>
c010b306:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b309:	83 f8 1f             	cmp    $0x1f,%eax
c010b30c:	77 56                	ja     c010b364 <syscall+0x7e>
        if (syscalls[num] != NULL) {
c010b30e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b311:	8b 04 85 a0 aa 12 c0 	mov    -0x3fed5560(,%eax,4),%eax
c010b318:	85 c0                	test   %eax,%eax
c010b31a:	74 48                	je     c010b364 <syscall+0x7e>
            arg[0] = tf->tf_regs.reg_edx;
c010b31c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b31f:	8b 40 14             	mov    0x14(%eax),%eax
c010b322:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b325:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b328:	8b 40 18             	mov    0x18(%eax),%eax
c010b32b:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b32e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b331:	8b 40 10             	mov    0x10(%eax),%eax
c010b334:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b337:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b33a:	8b 00                	mov    (%eax),%eax
c010b33c:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b33f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b342:	8b 40 04             	mov    0x4(%eax),%eax
c010b345:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b348:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b34b:	8b 04 85 a0 aa 12 c0 	mov    -0x3fed5560(,%eax,4),%eax
c010b352:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b355:	89 14 24             	mov    %edx,(%esp)
c010b358:	ff d0                	call   *%eax
c010b35a:	89 c2                	mov    %eax,%edx
c010b35c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b35f:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b362:	eb 46                	jmp    c010b3aa <syscall+0xc4>
        }
    }
    print_trapframe(tf);
c010b364:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b367:	89 04 24             	mov    %eax,(%esp)
c010b36a:	e8 a3 70 ff ff       	call   c0102412 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b36f:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b374:	8d 50 48             	lea    0x48(%eax),%edx
c010b377:	a1 48 f0 19 c0       	mov    0xc019f048,%eax
c010b37c:	8b 40 04             	mov    0x4(%eax),%eax
c010b37f:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b383:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b387:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b38a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b38e:	c7 44 24 08 64 e5 10 	movl   $0xc010e564,0x8(%esp)
c010b395:	c0 
c010b396:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c010b39d:	00 
c010b39e:	c7 04 24 90 e5 10 c0 	movl   $0xc010e590,(%esp)
c010b3a5:	e8 41 5a ff ff       	call   c0100deb <__panic>
            num, current->pid, current->name);
}
c010b3aa:	c9                   	leave  
c010b3ab:	c3                   	ret    

c010b3ac <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010b3ac:	55                   	push   %ebp
c010b3ad:	89 e5                	mov    %esp,%ebp
c010b3af:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010b3b2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3b5:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010b3bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010b3be:	b8 20 00 00 00       	mov    $0x20,%eax
c010b3c3:	2b 45 0c             	sub    0xc(%ebp),%eax
c010b3c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b3c9:	89 c1                	mov    %eax,%ecx
c010b3cb:	d3 ea                	shr    %cl,%edx
c010b3cd:	89 d0                	mov    %edx,%eax
}
c010b3cf:	c9                   	leave  
c010b3d0:	c3                   	ret    

c010b3d1 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b3d1:	55                   	push   %ebp
c010b3d2:	89 e5                	mov    %esp,%ebp
c010b3d4:	83 ec 58             	sub    $0x58,%esp
c010b3d7:	8b 45 10             	mov    0x10(%ebp),%eax
c010b3da:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b3dd:	8b 45 14             	mov    0x14(%ebp),%eax
c010b3e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b3e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b3e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b3e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b3ec:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b3ef:	8b 45 18             	mov    0x18(%ebp),%eax
c010b3f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b3f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b3fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b3fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b401:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b404:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b40b:	74 1c                	je     c010b429 <printnum+0x58>
c010b40d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b410:	ba 00 00 00 00       	mov    $0x0,%edx
c010b415:	f7 75 e4             	divl   -0x1c(%ebp)
c010b418:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b41b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b41e:	ba 00 00 00 00       	mov    $0x0,%edx
c010b423:	f7 75 e4             	divl   -0x1c(%ebp)
c010b426:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b429:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b42c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b42f:	f7 75 e4             	divl   -0x1c(%ebp)
c010b432:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b435:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b438:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b43b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b43e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b441:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b444:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b447:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b44a:	8b 45 18             	mov    0x18(%ebp),%eax
c010b44d:	ba 00 00 00 00       	mov    $0x0,%edx
c010b452:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b455:	77 56                	ja     c010b4ad <printnum+0xdc>
c010b457:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b45a:	72 05                	jb     c010b461 <printnum+0x90>
c010b45c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010b45f:	77 4c                	ja     c010b4ad <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b461:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b464:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b467:	8b 45 20             	mov    0x20(%ebp),%eax
c010b46a:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b46e:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b472:	8b 45 18             	mov    0x18(%ebp),%eax
c010b475:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b479:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b47c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b47f:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b483:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b487:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b48a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b48e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b491:	89 04 24             	mov    %eax,(%esp)
c010b494:	e8 38 ff ff ff       	call   c010b3d1 <printnum>
c010b499:	eb 1c                	jmp    c010b4b7 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b49b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b49e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b4a2:	8b 45 20             	mov    0x20(%ebp),%eax
c010b4a5:	89 04 24             	mov    %eax,(%esp)
c010b4a8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4ab:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010b4ad:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010b4b1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b4b5:	7f e4                	jg     c010b49b <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b4b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b4ba:	05 c4 e6 10 c0       	add    $0xc010e6c4,%eax
c010b4bf:	0f b6 00             	movzbl (%eax),%eax
c010b4c2:	0f be c0             	movsbl %al,%eax
c010b4c5:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b4c8:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b4cc:	89 04 24             	mov    %eax,(%esp)
c010b4cf:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4d2:	ff d0                	call   *%eax
}
c010b4d4:	c9                   	leave  
c010b4d5:	c3                   	ret    

c010b4d6 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b4d6:	55                   	push   %ebp
c010b4d7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b4d9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b4dd:	7e 14                	jle    c010b4f3 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b4df:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4e2:	8b 00                	mov    (%eax),%eax
c010b4e4:	8d 48 08             	lea    0x8(%eax),%ecx
c010b4e7:	8b 55 08             	mov    0x8(%ebp),%edx
c010b4ea:	89 0a                	mov    %ecx,(%edx)
c010b4ec:	8b 50 04             	mov    0x4(%eax),%edx
c010b4ef:	8b 00                	mov    (%eax),%eax
c010b4f1:	eb 30                	jmp    c010b523 <getuint+0x4d>
    }
    else if (lflag) {
c010b4f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b4f7:	74 16                	je     c010b50f <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b4f9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4fc:	8b 00                	mov    (%eax),%eax
c010b4fe:	8d 48 04             	lea    0x4(%eax),%ecx
c010b501:	8b 55 08             	mov    0x8(%ebp),%edx
c010b504:	89 0a                	mov    %ecx,(%edx)
c010b506:	8b 00                	mov    (%eax),%eax
c010b508:	ba 00 00 00 00       	mov    $0x0,%edx
c010b50d:	eb 14                	jmp    c010b523 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b50f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b512:	8b 00                	mov    (%eax),%eax
c010b514:	8d 48 04             	lea    0x4(%eax),%ecx
c010b517:	8b 55 08             	mov    0x8(%ebp),%edx
c010b51a:	89 0a                	mov    %ecx,(%edx)
c010b51c:	8b 00                	mov    (%eax),%eax
c010b51e:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010b523:	5d                   	pop    %ebp
c010b524:	c3                   	ret    

c010b525 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010b525:	55                   	push   %ebp
c010b526:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b528:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b52c:	7e 14                	jle    c010b542 <getint+0x1d>
        return va_arg(*ap, long long);
c010b52e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b531:	8b 00                	mov    (%eax),%eax
c010b533:	8d 48 08             	lea    0x8(%eax),%ecx
c010b536:	8b 55 08             	mov    0x8(%ebp),%edx
c010b539:	89 0a                	mov    %ecx,(%edx)
c010b53b:	8b 50 04             	mov    0x4(%eax),%edx
c010b53e:	8b 00                	mov    (%eax),%eax
c010b540:	eb 28                	jmp    c010b56a <getint+0x45>
    }
    else if (lflag) {
c010b542:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b546:	74 12                	je     c010b55a <getint+0x35>
        return va_arg(*ap, long);
c010b548:	8b 45 08             	mov    0x8(%ebp),%eax
c010b54b:	8b 00                	mov    (%eax),%eax
c010b54d:	8d 48 04             	lea    0x4(%eax),%ecx
c010b550:	8b 55 08             	mov    0x8(%ebp),%edx
c010b553:	89 0a                	mov    %ecx,(%edx)
c010b555:	8b 00                	mov    (%eax),%eax
c010b557:	99                   	cltd   
c010b558:	eb 10                	jmp    c010b56a <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010b55a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b55d:	8b 00                	mov    (%eax),%eax
c010b55f:	8d 48 04             	lea    0x4(%eax),%ecx
c010b562:	8b 55 08             	mov    0x8(%ebp),%edx
c010b565:	89 0a                	mov    %ecx,(%edx)
c010b567:	8b 00                	mov    (%eax),%eax
c010b569:	99                   	cltd   
    }
}
c010b56a:	5d                   	pop    %ebp
c010b56b:	c3                   	ret    

c010b56c <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010b56c:	55                   	push   %ebp
c010b56d:	89 e5                	mov    %esp,%ebp
c010b56f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010b572:	8d 45 14             	lea    0x14(%ebp),%eax
c010b575:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010b578:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b57b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b57f:	8b 45 10             	mov    0x10(%ebp),%eax
c010b582:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b586:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b589:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b58d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b590:	89 04 24             	mov    %eax,(%esp)
c010b593:	e8 02 00 00 00       	call   c010b59a <vprintfmt>
    va_end(ap);
}
c010b598:	c9                   	leave  
c010b599:	c3                   	ret    

c010b59a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010b59a:	55                   	push   %ebp
c010b59b:	89 e5                	mov    %esp,%ebp
c010b59d:	56                   	push   %esi
c010b59e:	53                   	push   %ebx
c010b59f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b5a2:	eb 18                	jmp    c010b5bc <vprintfmt+0x22>
            if (ch == '\0') {
c010b5a4:	85 db                	test   %ebx,%ebx
c010b5a6:	75 05                	jne    c010b5ad <vprintfmt+0x13>
                return;
c010b5a8:	e9 d1 03 00 00       	jmp    c010b97e <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010b5ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b5b4:	89 1c 24             	mov    %ebx,(%esp)
c010b5b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5ba:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b5bc:	8b 45 10             	mov    0x10(%ebp),%eax
c010b5bf:	8d 50 01             	lea    0x1(%eax),%edx
c010b5c2:	89 55 10             	mov    %edx,0x10(%ebp)
c010b5c5:	0f b6 00             	movzbl (%eax),%eax
c010b5c8:	0f b6 d8             	movzbl %al,%ebx
c010b5cb:	83 fb 25             	cmp    $0x25,%ebx
c010b5ce:	75 d4                	jne    c010b5a4 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010b5d0:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010b5d4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010b5db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b5de:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010b5e1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010b5e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b5eb:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010b5ee:	8b 45 10             	mov    0x10(%ebp),%eax
c010b5f1:	8d 50 01             	lea    0x1(%eax),%edx
c010b5f4:	89 55 10             	mov    %edx,0x10(%ebp)
c010b5f7:	0f b6 00             	movzbl (%eax),%eax
c010b5fa:	0f b6 d8             	movzbl %al,%ebx
c010b5fd:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010b600:	83 f8 55             	cmp    $0x55,%eax
c010b603:	0f 87 44 03 00 00    	ja     c010b94d <vprintfmt+0x3b3>
c010b609:	8b 04 85 e8 e6 10 c0 	mov    -0x3fef1918(,%eax,4),%eax
c010b610:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010b612:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010b616:	eb d6                	jmp    c010b5ee <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010b618:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010b61c:	eb d0                	jmp    c010b5ee <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b61e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010b625:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b628:	89 d0                	mov    %edx,%eax
c010b62a:	c1 e0 02             	shl    $0x2,%eax
c010b62d:	01 d0                	add    %edx,%eax
c010b62f:	01 c0                	add    %eax,%eax
c010b631:	01 d8                	add    %ebx,%eax
c010b633:	83 e8 30             	sub    $0x30,%eax
c010b636:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010b639:	8b 45 10             	mov    0x10(%ebp),%eax
c010b63c:	0f b6 00             	movzbl (%eax),%eax
c010b63f:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010b642:	83 fb 2f             	cmp    $0x2f,%ebx
c010b645:	7e 0b                	jle    c010b652 <vprintfmt+0xb8>
c010b647:	83 fb 39             	cmp    $0x39,%ebx
c010b64a:	7f 06                	jg     c010b652 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b64c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010b650:	eb d3                	jmp    c010b625 <vprintfmt+0x8b>
            goto process_precision;
c010b652:	eb 33                	jmp    c010b687 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010b654:	8b 45 14             	mov    0x14(%ebp),%eax
c010b657:	8d 50 04             	lea    0x4(%eax),%edx
c010b65a:	89 55 14             	mov    %edx,0x14(%ebp)
c010b65d:	8b 00                	mov    (%eax),%eax
c010b65f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010b662:	eb 23                	jmp    c010b687 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010b664:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b668:	79 0c                	jns    c010b676 <vprintfmt+0xdc>
                width = 0;
c010b66a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010b671:	e9 78 ff ff ff       	jmp    c010b5ee <vprintfmt+0x54>
c010b676:	e9 73 ff ff ff       	jmp    c010b5ee <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010b67b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010b682:	e9 67 ff ff ff       	jmp    c010b5ee <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010b687:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b68b:	79 12                	jns    c010b69f <vprintfmt+0x105>
                width = precision, precision = -1;
c010b68d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b690:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b693:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010b69a:	e9 4f ff ff ff       	jmp    c010b5ee <vprintfmt+0x54>
c010b69f:	e9 4a ff ff ff       	jmp    c010b5ee <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010b6a4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010b6a8:	e9 41 ff ff ff       	jmp    c010b5ee <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010b6ad:	8b 45 14             	mov    0x14(%ebp),%eax
c010b6b0:	8d 50 04             	lea    0x4(%eax),%edx
c010b6b3:	89 55 14             	mov    %edx,0x14(%ebp)
c010b6b6:	8b 00                	mov    (%eax),%eax
c010b6b8:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b6bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b6bf:	89 04 24             	mov    %eax,(%esp)
c010b6c2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6c5:	ff d0                	call   *%eax
            break;
c010b6c7:	e9 ac 02 00 00       	jmp    c010b978 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010b6cc:	8b 45 14             	mov    0x14(%ebp),%eax
c010b6cf:	8d 50 04             	lea    0x4(%eax),%edx
c010b6d2:	89 55 14             	mov    %edx,0x14(%ebp)
c010b6d5:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010b6d7:	85 db                	test   %ebx,%ebx
c010b6d9:	79 02                	jns    c010b6dd <vprintfmt+0x143>
                err = -err;
c010b6db:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010b6dd:	83 fb 18             	cmp    $0x18,%ebx
c010b6e0:	7f 0b                	jg     c010b6ed <vprintfmt+0x153>
c010b6e2:	8b 34 9d 60 e6 10 c0 	mov    -0x3fef19a0(,%ebx,4),%esi
c010b6e9:	85 f6                	test   %esi,%esi
c010b6eb:	75 23                	jne    c010b710 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010b6ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010b6f1:	c7 44 24 08 d5 e6 10 	movl   $0xc010e6d5,0x8(%esp)
c010b6f8:	c0 
c010b6f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b6fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b700:	8b 45 08             	mov    0x8(%ebp),%eax
c010b703:	89 04 24             	mov    %eax,(%esp)
c010b706:	e8 61 fe ff ff       	call   c010b56c <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010b70b:	e9 68 02 00 00       	jmp    c010b978 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010b710:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010b714:	c7 44 24 08 de e6 10 	movl   $0xc010e6de,0x8(%esp)
c010b71b:	c0 
c010b71c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b71f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b723:	8b 45 08             	mov    0x8(%ebp),%eax
c010b726:	89 04 24             	mov    %eax,(%esp)
c010b729:	e8 3e fe ff ff       	call   c010b56c <printfmt>
            }
            break;
c010b72e:	e9 45 02 00 00       	jmp    c010b978 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010b733:	8b 45 14             	mov    0x14(%ebp),%eax
c010b736:	8d 50 04             	lea    0x4(%eax),%edx
c010b739:	89 55 14             	mov    %edx,0x14(%ebp)
c010b73c:	8b 30                	mov    (%eax),%esi
c010b73e:	85 f6                	test   %esi,%esi
c010b740:	75 05                	jne    c010b747 <vprintfmt+0x1ad>
                p = "(null)";
c010b742:	be e1 e6 10 c0       	mov    $0xc010e6e1,%esi
            }
            if (width > 0 && padc != '-') {
c010b747:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b74b:	7e 3e                	jle    c010b78b <vprintfmt+0x1f1>
c010b74d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010b751:	74 38                	je     c010b78b <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b753:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010b756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b759:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b75d:	89 34 24             	mov    %esi,(%esp)
c010b760:	e8 ed 03 00 00       	call   c010bb52 <strnlen>
c010b765:	29 c3                	sub    %eax,%ebx
c010b767:	89 d8                	mov    %ebx,%eax
c010b769:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b76c:	eb 17                	jmp    c010b785 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010b76e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010b772:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b775:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b779:	89 04 24             	mov    %eax,(%esp)
c010b77c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b77f:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b781:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b785:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b789:	7f e3                	jg     c010b76e <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b78b:	eb 38                	jmp    c010b7c5 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010b78d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010b791:	74 1f                	je     c010b7b2 <vprintfmt+0x218>
c010b793:	83 fb 1f             	cmp    $0x1f,%ebx
c010b796:	7e 05                	jle    c010b79d <vprintfmt+0x203>
c010b798:	83 fb 7e             	cmp    $0x7e,%ebx
c010b79b:	7e 15                	jle    c010b7b2 <vprintfmt+0x218>
                    putch('?', putdat);
c010b79d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010b7ab:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7ae:	ff d0                	call   *%eax
c010b7b0:	eb 0f                	jmp    c010b7c1 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010b7b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7b9:	89 1c 24             	mov    %ebx,(%esp)
c010b7bc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7bf:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b7c1:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b7c5:	89 f0                	mov    %esi,%eax
c010b7c7:	8d 70 01             	lea    0x1(%eax),%esi
c010b7ca:	0f b6 00             	movzbl (%eax),%eax
c010b7cd:	0f be d8             	movsbl %al,%ebx
c010b7d0:	85 db                	test   %ebx,%ebx
c010b7d2:	74 10                	je     c010b7e4 <vprintfmt+0x24a>
c010b7d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b7d8:	78 b3                	js     c010b78d <vprintfmt+0x1f3>
c010b7da:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010b7de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b7e2:	79 a9                	jns    c010b78d <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010b7e4:	eb 17                	jmp    c010b7fd <vprintfmt+0x263>
                putch(' ', putdat);
c010b7e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7ed:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010b7f4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7f7:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010b7f9:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b7fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b801:	7f e3                	jg     c010b7e6 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010b803:	e9 70 01 00 00       	jmp    c010b978 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010b808:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b80b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b80f:	8d 45 14             	lea    0x14(%ebp),%eax
c010b812:	89 04 24             	mov    %eax,(%esp)
c010b815:	e8 0b fd ff ff       	call   c010b525 <getint>
c010b81a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b81d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010b820:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b823:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b826:	85 d2                	test   %edx,%edx
c010b828:	79 26                	jns    c010b850 <vprintfmt+0x2b6>
                putch('-', putdat);
c010b82a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b82d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b831:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010b838:	8b 45 08             	mov    0x8(%ebp),%eax
c010b83b:	ff d0                	call   *%eax
                num = -(long long)num;
c010b83d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b840:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b843:	f7 d8                	neg    %eax
c010b845:	83 d2 00             	adc    $0x0,%edx
c010b848:	f7 da                	neg    %edx
c010b84a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b84d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010b850:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010b857:	e9 a8 00 00 00       	jmp    c010b904 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010b85c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b85f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b863:	8d 45 14             	lea    0x14(%ebp),%eax
c010b866:	89 04 24             	mov    %eax,(%esp)
c010b869:	e8 68 fc ff ff       	call   c010b4d6 <getuint>
c010b86e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b871:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010b874:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010b87b:	e9 84 00 00 00       	jmp    c010b904 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010b880:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b883:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b887:	8d 45 14             	lea    0x14(%ebp),%eax
c010b88a:	89 04 24             	mov    %eax,(%esp)
c010b88d:	e8 44 fc ff ff       	call   c010b4d6 <getuint>
c010b892:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b895:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010b898:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010b89f:	eb 63                	jmp    c010b904 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010b8a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b8a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8a8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010b8af:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8b2:	ff d0                	call   *%eax
            putch('x', putdat);
c010b8b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b8b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8bb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010b8c2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8c5:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010b8c7:	8b 45 14             	mov    0x14(%ebp),%eax
c010b8ca:	8d 50 04             	lea    0x4(%eax),%edx
c010b8cd:	89 55 14             	mov    %edx,0x14(%ebp)
c010b8d0:	8b 00                	mov    (%eax),%eax
c010b8d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b8d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010b8dc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010b8e3:	eb 1f                	jmp    c010b904 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010b8e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b8e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8ec:	8d 45 14             	lea    0x14(%ebp),%eax
c010b8ef:	89 04 24             	mov    %eax,(%esp)
c010b8f2:	e8 df fb ff ff       	call   c010b4d6 <getuint>
c010b8f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b8fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010b8fd:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010b904:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010b908:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b90b:	89 54 24 18          	mov    %edx,0x18(%esp)
c010b90f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b912:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b916:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b91a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b91d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b920:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b924:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b928:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b92b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b92f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b932:	89 04 24             	mov    %eax,(%esp)
c010b935:	e8 97 fa ff ff       	call   c010b3d1 <printnum>
            break;
c010b93a:	eb 3c                	jmp    c010b978 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010b93c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b93f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b943:	89 1c 24             	mov    %ebx,(%esp)
c010b946:	8b 45 08             	mov    0x8(%ebp),%eax
c010b949:	ff d0                	call   *%eax
            break;
c010b94b:	eb 2b                	jmp    c010b978 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010b94d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b950:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b954:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010b95b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b95e:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010b960:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b964:	eb 04                	jmp    c010b96a <vprintfmt+0x3d0>
c010b966:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b96a:	8b 45 10             	mov    0x10(%ebp),%eax
c010b96d:	83 e8 01             	sub    $0x1,%eax
c010b970:	0f b6 00             	movzbl (%eax),%eax
c010b973:	3c 25                	cmp    $0x25,%al
c010b975:	75 ef                	jne    c010b966 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010b977:	90                   	nop
        }
    }
c010b978:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b979:	e9 3e fc ff ff       	jmp    c010b5bc <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010b97e:	83 c4 40             	add    $0x40,%esp
c010b981:	5b                   	pop    %ebx
c010b982:	5e                   	pop    %esi
c010b983:	5d                   	pop    %ebp
c010b984:	c3                   	ret    

c010b985 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010b985:	55                   	push   %ebp
c010b986:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010b988:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b98b:	8b 40 08             	mov    0x8(%eax),%eax
c010b98e:	8d 50 01             	lea    0x1(%eax),%edx
c010b991:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b994:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010b997:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b99a:	8b 10                	mov    (%eax),%edx
c010b99c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b99f:	8b 40 04             	mov    0x4(%eax),%eax
c010b9a2:	39 c2                	cmp    %eax,%edx
c010b9a4:	73 12                	jae    c010b9b8 <sprintputch+0x33>
        *b->buf ++ = ch;
c010b9a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b9a9:	8b 00                	mov    (%eax),%eax
c010b9ab:	8d 48 01             	lea    0x1(%eax),%ecx
c010b9ae:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b9b1:	89 0a                	mov    %ecx,(%edx)
c010b9b3:	8b 55 08             	mov    0x8(%ebp),%edx
c010b9b6:	88 10                	mov    %dl,(%eax)
    }
}
c010b9b8:	5d                   	pop    %ebp
c010b9b9:	c3                   	ret    

c010b9ba <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010b9ba:	55                   	push   %ebp
c010b9bb:	89 e5                	mov    %esp,%ebp
c010b9bd:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010b9c0:	8d 45 14             	lea    0x14(%ebp),%eax
c010b9c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010b9c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b9c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b9cd:	8b 45 10             	mov    0x10(%ebp),%eax
c010b9d0:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b9d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b9d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b9db:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9de:	89 04 24             	mov    %eax,(%esp)
c010b9e1:	e8 08 00 00 00       	call   c010b9ee <vsnprintf>
c010b9e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010b9e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010b9ec:	c9                   	leave  
c010b9ed:	c3                   	ret    

c010b9ee <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010b9ee:	55                   	push   %ebp
c010b9ef:	89 e5                	mov    %esp,%ebp
c010b9f1:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010b9f4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b9fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b9fd:	8d 50 ff             	lea    -0x1(%eax),%edx
c010ba00:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba03:	01 d0                	add    %edx,%eax
c010ba05:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ba08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010ba0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010ba13:	74 0a                	je     c010ba1f <vsnprintf+0x31>
c010ba15:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ba18:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba1b:	39 c2                	cmp    %eax,%edx
c010ba1d:	76 07                	jbe    c010ba26 <vsnprintf+0x38>
        return -E_INVAL;
c010ba1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010ba24:	eb 2a                	jmp    c010ba50 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010ba26:	8b 45 14             	mov    0x14(%ebp),%eax
c010ba29:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ba2d:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba30:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ba34:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010ba37:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba3b:	c7 04 24 85 b9 10 c0 	movl   $0xc010b985,(%esp)
c010ba42:	e8 53 fb ff ff       	call   c010b59a <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010ba47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ba4a:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010ba4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010ba50:	c9                   	leave  
c010ba51:	c3                   	ret    

c010ba52 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010ba52:	55                   	push   %ebp
c010ba53:	89 e5                	mov    %esp,%ebp
c010ba55:	57                   	push   %edi
c010ba56:	56                   	push   %esi
c010ba57:	53                   	push   %ebx
c010ba58:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010ba5b:	a1 20 ab 12 c0       	mov    0xc012ab20,%eax
c010ba60:	8b 15 24 ab 12 c0    	mov    0xc012ab24,%edx
c010ba66:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010ba6c:	6b f0 05             	imul   $0x5,%eax,%esi
c010ba6f:	01 f7                	add    %esi,%edi
c010ba71:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010ba76:	f7 e6                	mul    %esi
c010ba78:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010ba7b:	89 f2                	mov    %esi,%edx
c010ba7d:	83 c0 0b             	add    $0xb,%eax
c010ba80:	83 d2 00             	adc    $0x0,%edx
c010ba83:	89 c7                	mov    %eax,%edi
c010ba85:	83 e7 ff             	and    $0xffffffff,%edi
c010ba88:	89 f9                	mov    %edi,%ecx
c010ba8a:	0f b7 da             	movzwl %dx,%ebx
c010ba8d:	89 0d 20 ab 12 c0    	mov    %ecx,0xc012ab20
c010ba93:	89 1d 24 ab 12 c0    	mov    %ebx,0xc012ab24
    unsigned long long result = (next >> 12);
c010ba99:	a1 20 ab 12 c0       	mov    0xc012ab20,%eax
c010ba9e:	8b 15 24 ab 12 c0    	mov    0xc012ab24,%edx
c010baa4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010baa8:	c1 ea 0c             	shr    $0xc,%edx
c010baab:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010baae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010bab1:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010bab8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010babb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010babe:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bac1:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bac4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bac7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010baca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bace:	74 1c                	je     c010baec <rand+0x9a>
c010bad0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bad3:	ba 00 00 00 00       	mov    $0x0,%edx
c010bad8:	f7 75 dc             	divl   -0x24(%ebp)
c010badb:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bade:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bae1:	ba 00 00 00 00       	mov    $0x0,%edx
c010bae6:	f7 75 dc             	divl   -0x24(%ebp)
c010bae9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010baec:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010baef:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010baf2:	f7 75 dc             	divl   -0x24(%ebp)
c010baf5:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010baf8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bafb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bafe:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bb01:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bb04:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010bb07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010bb0a:	83 c4 24             	add    $0x24,%esp
c010bb0d:	5b                   	pop    %ebx
c010bb0e:	5e                   	pop    %esi
c010bb0f:	5f                   	pop    %edi
c010bb10:	5d                   	pop    %ebp
c010bb11:	c3                   	ret    

c010bb12 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010bb12:	55                   	push   %ebp
c010bb13:	89 e5                	mov    %esp,%ebp
    next = seed;
c010bb15:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb18:	ba 00 00 00 00       	mov    $0x0,%edx
c010bb1d:	a3 20 ab 12 c0       	mov    %eax,0xc012ab20
c010bb22:	89 15 24 ab 12 c0    	mov    %edx,0xc012ab24
}
c010bb28:	5d                   	pop    %ebp
c010bb29:	c3                   	ret    

c010bb2a <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010bb2a:	55                   	push   %ebp
c010bb2b:	89 e5                	mov    %esp,%ebp
c010bb2d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010bb30:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010bb37:	eb 04                	jmp    c010bb3d <strlen+0x13>
        cnt ++;
c010bb39:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010bb3d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb40:	8d 50 01             	lea    0x1(%eax),%edx
c010bb43:	89 55 08             	mov    %edx,0x8(%ebp)
c010bb46:	0f b6 00             	movzbl (%eax),%eax
c010bb49:	84 c0                	test   %al,%al
c010bb4b:	75 ec                	jne    c010bb39 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010bb4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010bb50:	c9                   	leave  
c010bb51:	c3                   	ret    

c010bb52 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010bb52:	55                   	push   %ebp
c010bb53:	89 e5                	mov    %esp,%ebp
c010bb55:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010bb58:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010bb5f:	eb 04                	jmp    c010bb65 <strnlen+0x13>
        cnt ++;
c010bb61:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010bb65:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bb68:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010bb6b:	73 10                	jae    c010bb7d <strnlen+0x2b>
c010bb6d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb70:	8d 50 01             	lea    0x1(%eax),%edx
c010bb73:	89 55 08             	mov    %edx,0x8(%ebp)
c010bb76:	0f b6 00             	movzbl (%eax),%eax
c010bb79:	84 c0                	test   %al,%al
c010bb7b:	75 e4                	jne    c010bb61 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010bb7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010bb80:	c9                   	leave  
c010bb81:	c3                   	ret    

c010bb82 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010bb82:	55                   	push   %ebp
c010bb83:	89 e5                	mov    %esp,%ebp
c010bb85:	57                   	push   %edi
c010bb86:	56                   	push   %esi
c010bb87:	83 ec 20             	sub    $0x20,%esp
c010bb8a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bb90:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb93:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010bb96:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bb99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bb9c:	89 d1                	mov    %edx,%ecx
c010bb9e:	89 c2                	mov    %eax,%edx
c010bba0:	89 ce                	mov    %ecx,%esi
c010bba2:	89 d7                	mov    %edx,%edi
c010bba4:	ac                   	lods   %ds:(%esi),%al
c010bba5:	aa                   	stos   %al,%es:(%edi)
c010bba6:	84 c0                	test   %al,%al
c010bba8:	75 fa                	jne    c010bba4 <strcpy+0x22>
c010bbaa:	89 fa                	mov    %edi,%edx
c010bbac:	89 f1                	mov    %esi,%ecx
c010bbae:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010bbb1:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bbb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010bbb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010bbba:	83 c4 20             	add    $0x20,%esp
c010bbbd:	5e                   	pop    %esi
c010bbbe:	5f                   	pop    %edi
c010bbbf:	5d                   	pop    %ebp
c010bbc0:	c3                   	ret    

c010bbc1 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010bbc1:	55                   	push   %ebp
c010bbc2:	89 e5                	mov    %esp,%ebp
c010bbc4:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010bbc7:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbca:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010bbcd:	eb 21                	jmp    c010bbf0 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010bbcf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbd2:	0f b6 10             	movzbl (%eax),%edx
c010bbd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bbd8:	88 10                	mov    %dl,(%eax)
c010bbda:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bbdd:	0f b6 00             	movzbl (%eax),%eax
c010bbe0:	84 c0                	test   %al,%al
c010bbe2:	74 04                	je     c010bbe8 <strncpy+0x27>
            src ++;
c010bbe4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010bbe8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010bbec:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010bbf0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bbf4:	75 d9                	jne    c010bbcf <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010bbf6:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010bbf9:	c9                   	leave  
c010bbfa:	c3                   	ret    

c010bbfb <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010bbfb:	55                   	push   %ebp
c010bbfc:	89 e5                	mov    %esp,%ebp
c010bbfe:	57                   	push   %edi
c010bbff:	56                   	push   %esi
c010bc00:	83 ec 20             	sub    $0x20,%esp
c010bc03:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc06:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bc09:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010bc0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bc12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bc15:	89 d1                	mov    %edx,%ecx
c010bc17:	89 c2                	mov    %eax,%edx
c010bc19:	89 ce                	mov    %ecx,%esi
c010bc1b:	89 d7                	mov    %edx,%edi
c010bc1d:	ac                   	lods   %ds:(%esi),%al
c010bc1e:	ae                   	scas   %es:(%edi),%al
c010bc1f:	75 08                	jne    c010bc29 <strcmp+0x2e>
c010bc21:	84 c0                	test   %al,%al
c010bc23:	75 f8                	jne    c010bc1d <strcmp+0x22>
c010bc25:	31 c0                	xor    %eax,%eax
c010bc27:	eb 04                	jmp    c010bc2d <strcmp+0x32>
c010bc29:	19 c0                	sbb    %eax,%eax
c010bc2b:	0c 01                	or     $0x1,%al
c010bc2d:	89 fa                	mov    %edi,%edx
c010bc2f:	89 f1                	mov    %esi,%ecx
c010bc31:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bc34:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010bc37:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010bc3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010bc3d:	83 c4 20             	add    $0x20,%esp
c010bc40:	5e                   	pop    %esi
c010bc41:	5f                   	pop    %edi
c010bc42:	5d                   	pop    %ebp
c010bc43:	c3                   	ret    

c010bc44 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010bc44:	55                   	push   %ebp
c010bc45:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010bc47:	eb 0c                	jmp    c010bc55 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010bc49:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010bc4d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bc51:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010bc55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bc59:	74 1a                	je     c010bc75 <strncmp+0x31>
c010bc5b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc5e:	0f b6 00             	movzbl (%eax),%eax
c010bc61:	84 c0                	test   %al,%al
c010bc63:	74 10                	je     c010bc75 <strncmp+0x31>
c010bc65:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc68:	0f b6 10             	movzbl (%eax),%edx
c010bc6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc6e:	0f b6 00             	movzbl (%eax),%eax
c010bc71:	38 c2                	cmp    %al,%dl
c010bc73:	74 d4                	je     c010bc49 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010bc75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bc79:	74 18                	je     c010bc93 <strncmp+0x4f>
c010bc7b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc7e:	0f b6 00             	movzbl (%eax),%eax
c010bc81:	0f b6 d0             	movzbl %al,%edx
c010bc84:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc87:	0f b6 00             	movzbl (%eax),%eax
c010bc8a:	0f b6 c0             	movzbl %al,%eax
c010bc8d:	29 c2                	sub    %eax,%edx
c010bc8f:	89 d0                	mov    %edx,%eax
c010bc91:	eb 05                	jmp    c010bc98 <strncmp+0x54>
c010bc93:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bc98:	5d                   	pop    %ebp
c010bc99:	c3                   	ret    

c010bc9a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010bc9a:	55                   	push   %ebp
c010bc9b:	89 e5                	mov    %esp,%ebp
c010bc9d:	83 ec 04             	sub    $0x4,%esp
c010bca0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bca3:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010bca6:	eb 14                	jmp    c010bcbc <strchr+0x22>
        if (*s == c) {
c010bca8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcab:	0f b6 00             	movzbl (%eax),%eax
c010bcae:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010bcb1:	75 05                	jne    c010bcb8 <strchr+0x1e>
            return (char *)s;
c010bcb3:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcb6:	eb 13                	jmp    c010bccb <strchr+0x31>
        }
        s ++;
c010bcb8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010bcbc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcbf:	0f b6 00             	movzbl (%eax),%eax
c010bcc2:	84 c0                	test   %al,%al
c010bcc4:	75 e2                	jne    c010bca8 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010bcc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bccb:	c9                   	leave  
c010bccc:	c3                   	ret    

c010bccd <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010bccd:	55                   	push   %ebp
c010bcce:	89 e5                	mov    %esp,%ebp
c010bcd0:	83 ec 04             	sub    $0x4,%esp
c010bcd3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcd6:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010bcd9:	eb 11                	jmp    c010bcec <strfind+0x1f>
        if (*s == c) {
c010bcdb:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcde:	0f b6 00             	movzbl (%eax),%eax
c010bce1:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010bce4:	75 02                	jne    c010bce8 <strfind+0x1b>
            break;
c010bce6:	eb 0e                	jmp    c010bcf6 <strfind+0x29>
        }
        s ++;
c010bce8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010bcec:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcef:	0f b6 00             	movzbl (%eax),%eax
c010bcf2:	84 c0                	test   %al,%al
c010bcf4:	75 e5                	jne    c010bcdb <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010bcf6:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010bcf9:	c9                   	leave  
c010bcfa:	c3                   	ret    

c010bcfb <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010bcfb:	55                   	push   %ebp
c010bcfc:	89 e5                	mov    %esp,%ebp
c010bcfe:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010bd01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010bd08:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010bd0f:	eb 04                	jmp    c010bd15 <strtol+0x1a>
        s ++;
c010bd11:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010bd15:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd18:	0f b6 00             	movzbl (%eax),%eax
c010bd1b:	3c 20                	cmp    $0x20,%al
c010bd1d:	74 f2                	je     c010bd11 <strtol+0x16>
c010bd1f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd22:	0f b6 00             	movzbl (%eax),%eax
c010bd25:	3c 09                	cmp    $0x9,%al
c010bd27:	74 e8                	je     c010bd11 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010bd29:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd2c:	0f b6 00             	movzbl (%eax),%eax
c010bd2f:	3c 2b                	cmp    $0x2b,%al
c010bd31:	75 06                	jne    c010bd39 <strtol+0x3e>
        s ++;
c010bd33:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bd37:	eb 15                	jmp    c010bd4e <strtol+0x53>
    }
    else if (*s == '-') {
c010bd39:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd3c:	0f b6 00             	movzbl (%eax),%eax
c010bd3f:	3c 2d                	cmp    $0x2d,%al
c010bd41:	75 0b                	jne    c010bd4e <strtol+0x53>
        s ++, neg = 1;
c010bd43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bd47:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010bd4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bd52:	74 06                	je     c010bd5a <strtol+0x5f>
c010bd54:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010bd58:	75 24                	jne    c010bd7e <strtol+0x83>
c010bd5a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd5d:	0f b6 00             	movzbl (%eax),%eax
c010bd60:	3c 30                	cmp    $0x30,%al
c010bd62:	75 1a                	jne    c010bd7e <strtol+0x83>
c010bd64:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd67:	83 c0 01             	add    $0x1,%eax
c010bd6a:	0f b6 00             	movzbl (%eax),%eax
c010bd6d:	3c 78                	cmp    $0x78,%al
c010bd6f:	75 0d                	jne    c010bd7e <strtol+0x83>
        s += 2, base = 16;
c010bd71:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010bd75:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010bd7c:	eb 2a                	jmp    c010bda8 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010bd7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bd82:	75 17                	jne    c010bd9b <strtol+0xa0>
c010bd84:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd87:	0f b6 00             	movzbl (%eax),%eax
c010bd8a:	3c 30                	cmp    $0x30,%al
c010bd8c:	75 0d                	jne    c010bd9b <strtol+0xa0>
        s ++, base = 8;
c010bd8e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bd92:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010bd99:	eb 0d                	jmp    c010bda8 <strtol+0xad>
    }
    else if (base == 0) {
c010bd9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bd9f:	75 07                	jne    c010bda8 <strtol+0xad>
        base = 10;
c010bda1:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010bda8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdab:	0f b6 00             	movzbl (%eax),%eax
c010bdae:	3c 2f                	cmp    $0x2f,%al
c010bdb0:	7e 1b                	jle    c010bdcd <strtol+0xd2>
c010bdb2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdb5:	0f b6 00             	movzbl (%eax),%eax
c010bdb8:	3c 39                	cmp    $0x39,%al
c010bdba:	7f 11                	jg     c010bdcd <strtol+0xd2>
            dig = *s - '0';
c010bdbc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdbf:	0f b6 00             	movzbl (%eax),%eax
c010bdc2:	0f be c0             	movsbl %al,%eax
c010bdc5:	83 e8 30             	sub    $0x30,%eax
c010bdc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bdcb:	eb 48                	jmp    c010be15 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010bdcd:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdd0:	0f b6 00             	movzbl (%eax),%eax
c010bdd3:	3c 60                	cmp    $0x60,%al
c010bdd5:	7e 1b                	jle    c010bdf2 <strtol+0xf7>
c010bdd7:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdda:	0f b6 00             	movzbl (%eax),%eax
c010bddd:	3c 7a                	cmp    $0x7a,%al
c010bddf:	7f 11                	jg     c010bdf2 <strtol+0xf7>
            dig = *s - 'a' + 10;
c010bde1:	8b 45 08             	mov    0x8(%ebp),%eax
c010bde4:	0f b6 00             	movzbl (%eax),%eax
c010bde7:	0f be c0             	movsbl %al,%eax
c010bdea:	83 e8 57             	sub    $0x57,%eax
c010bded:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bdf0:	eb 23                	jmp    c010be15 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010bdf2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdf5:	0f b6 00             	movzbl (%eax),%eax
c010bdf8:	3c 40                	cmp    $0x40,%al
c010bdfa:	7e 3d                	jle    c010be39 <strtol+0x13e>
c010bdfc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdff:	0f b6 00             	movzbl (%eax),%eax
c010be02:	3c 5a                	cmp    $0x5a,%al
c010be04:	7f 33                	jg     c010be39 <strtol+0x13e>
            dig = *s - 'A' + 10;
c010be06:	8b 45 08             	mov    0x8(%ebp),%eax
c010be09:	0f b6 00             	movzbl (%eax),%eax
c010be0c:	0f be c0             	movsbl %al,%eax
c010be0f:	83 e8 37             	sub    $0x37,%eax
c010be12:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010be15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010be18:	3b 45 10             	cmp    0x10(%ebp),%eax
c010be1b:	7c 02                	jl     c010be1f <strtol+0x124>
            break;
c010be1d:	eb 1a                	jmp    c010be39 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010be1f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010be23:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010be26:	0f af 45 10          	imul   0x10(%ebp),%eax
c010be2a:	89 c2                	mov    %eax,%edx
c010be2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010be2f:	01 d0                	add    %edx,%eax
c010be31:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010be34:	e9 6f ff ff ff       	jmp    c010bda8 <strtol+0xad>

    if (endptr) {
c010be39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010be3d:	74 08                	je     c010be47 <strtol+0x14c>
        *endptr = (char *) s;
c010be3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be42:	8b 55 08             	mov    0x8(%ebp),%edx
c010be45:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010be47:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010be4b:	74 07                	je     c010be54 <strtol+0x159>
c010be4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010be50:	f7 d8                	neg    %eax
c010be52:	eb 03                	jmp    c010be57 <strtol+0x15c>
c010be54:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010be57:	c9                   	leave  
c010be58:	c3                   	ret    

c010be59 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010be59:	55                   	push   %ebp
c010be5a:	89 e5                	mov    %esp,%ebp
c010be5c:	57                   	push   %edi
c010be5d:	83 ec 24             	sub    $0x24,%esp
c010be60:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be63:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010be66:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010be6a:	8b 55 08             	mov    0x8(%ebp),%edx
c010be6d:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010be70:	88 45 f7             	mov    %al,-0x9(%ebp)
c010be73:	8b 45 10             	mov    0x10(%ebp),%eax
c010be76:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010be79:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010be7c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010be80:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010be83:	89 d7                	mov    %edx,%edi
c010be85:	f3 aa                	rep stos %al,%es:(%edi)
c010be87:	89 fa                	mov    %edi,%edx
c010be89:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010be8c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010be8f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010be92:	83 c4 24             	add    $0x24,%esp
c010be95:	5f                   	pop    %edi
c010be96:	5d                   	pop    %ebp
c010be97:	c3                   	ret    

c010be98 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010be98:	55                   	push   %ebp
c010be99:	89 e5                	mov    %esp,%ebp
c010be9b:	57                   	push   %edi
c010be9c:	56                   	push   %esi
c010be9d:	53                   	push   %ebx
c010be9e:	83 ec 30             	sub    $0x30,%esp
c010bea1:	8b 45 08             	mov    0x8(%ebp),%eax
c010bea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bea7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010beaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bead:	8b 45 10             	mov    0x10(%ebp),%eax
c010beb0:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010beb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010beb6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010beb9:	73 42                	jae    c010befd <memmove+0x65>
c010bebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bebe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010bec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bec4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010beca:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010becd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bed0:	c1 e8 02             	shr    $0x2,%eax
c010bed3:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010bed5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bed8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bedb:	89 d7                	mov    %edx,%edi
c010bedd:	89 c6                	mov    %eax,%esi
c010bedf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010bee1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010bee4:	83 e1 03             	and    $0x3,%ecx
c010bee7:	74 02                	je     c010beeb <memmove+0x53>
c010bee9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010beeb:	89 f0                	mov    %esi,%eax
c010beed:	89 fa                	mov    %edi,%edx
c010beef:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010bef2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bef5:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010bef8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010befb:	eb 36                	jmp    c010bf33 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010befd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bf00:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bf03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bf06:	01 c2                	add    %eax,%edx
c010bf08:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bf0b:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010bf0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bf11:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010bf14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bf17:	89 c1                	mov    %eax,%ecx
c010bf19:	89 d8                	mov    %ebx,%eax
c010bf1b:	89 d6                	mov    %edx,%esi
c010bf1d:	89 c7                	mov    %eax,%edi
c010bf1f:	fd                   	std    
c010bf20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bf22:	fc                   	cld    
c010bf23:	89 f8                	mov    %edi,%eax
c010bf25:	89 f2                	mov    %esi,%edx
c010bf27:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010bf2a:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010bf2d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010bf30:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010bf33:	83 c4 30             	add    $0x30,%esp
c010bf36:	5b                   	pop    %ebx
c010bf37:	5e                   	pop    %esi
c010bf38:	5f                   	pop    %edi
c010bf39:	5d                   	pop    %ebp
c010bf3a:	c3                   	ret    

c010bf3b <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010bf3b:	55                   	push   %ebp
c010bf3c:	89 e5                	mov    %esp,%ebp
c010bf3e:	57                   	push   %edi
c010bf3f:	56                   	push   %esi
c010bf40:	83 ec 20             	sub    $0x20,%esp
c010bf43:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf46:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bf49:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bf4f:	8b 45 10             	mov    0x10(%ebp),%eax
c010bf52:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010bf55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bf58:	c1 e8 02             	shr    $0x2,%eax
c010bf5b:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010bf5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bf60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bf63:	89 d7                	mov    %edx,%edi
c010bf65:	89 c6                	mov    %eax,%esi
c010bf67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010bf69:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010bf6c:	83 e1 03             	and    $0x3,%ecx
c010bf6f:	74 02                	je     c010bf73 <memcpy+0x38>
c010bf71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bf73:	89 f0                	mov    %esi,%eax
c010bf75:	89 fa                	mov    %edi,%edx
c010bf77:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010bf7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010bf7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010bf80:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010bf83:	83 c4 20             	add    $0x20,%esp
c010bf86:	5e                   	pop    %esi
c010bf87:	5f                   	pop    %edi
c010bf88:	5d                   	pop    %ebp
c010bf89:	c3                   	ret    

c010bf8a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010bf8a:	55                   	push   %ebp
c010bf8b:	89 e5                	mov    %esp,%ebp
c010bf8d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010bf90:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf93:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010bf96:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf99:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010bf9c:	eb 30                	jmp    c010bfce <memcmp+0x44>
        if (*s1 != *s2) {
c010bf9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bfa1:	0f b6 10             	movzbl (%eax),%edx
c010bfa4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bfa7:	0f b6 00             	movzbl (%eax),%eax
c010bfaa:	38 c2                	cmp    %al,%dl
c010bfac:	74 18                	je     c010bfc6 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010bfae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bfb1:	0f b6 00             	movzbl (%eax),%eax
c010bfb4:	0f b6 d0             	movzbl %al,%edx
c010bfb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bfba:	0f b6 00             	movzbl (%eax),%eax
c010bfbd:	0f b6 c0             	movzbl %al,%eax
c010bfc0:	29 c2                	sub    %eax,%edx
c010bfc2:	89 d0                	mov    %edx,%eax
c010bfc4:	eb 1a                	jmp    c010bfe0 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010bfc6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010bfca:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010bfce:	8b 45 10             	mov    0x10(%ebp),%eax
c010bfd1:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bfd4:	89 55 10             	mov    %edx,0x10(%ebp)
c010bfd7:	85 c0                	test   %eax,%eax
c010bfd9:	75 c3                	jne    c010bf9e <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010bfdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bfe0:	c9                   	leave  
c010bfe1:	c3                   	ret    
