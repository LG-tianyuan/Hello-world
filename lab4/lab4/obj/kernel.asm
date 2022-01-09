
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 50 12 00       	mov    $0x125000,%eax
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
c0100020:	a3 00 50 12 c0       	mov    %eax,0xc0125000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 40 12 c0       	mov    $0xc0124000,%esp
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
c010003c:	ba d8 a1 12 c0       	mov    $0xc012a1d8,%edx
c0100041:	b8 00 70 12 c0       	mov    $0xc0127000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 70 12 c0 	movl   $0xc0127000,(%esp)
c010005d:	e8 fc 9d 00 00       	call   c0109e5e <memset>

    cons_init();                // init the console
c0100062:	e8 a3 15 00 00       	call   c010160a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 a0 10 c0 	movl   $0xc010a000,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c a0 10 c0 	movl   $0xc010a01c,(%esp)
c010007c:	e8 de 02 00 00       	call   c010035f <cprintf>

    print_kerninfo();
c0100081:	e8 0d 08 00 00       	call   c0100893 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 9d 00 00 00       	call   c0100128 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 20 55 00 00       	call   c01055b0 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 53 1f 00 00       	call   c0101fe8 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 a5 20 00 00       	call   c010213f <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 26 7c 00 00       	call   c0107cc5 <vmm_init>
    proc_init();                // init process table
c010009f:	e8 b0 8f 00 00       	call   c0109054 <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 92 16 00 00       	call   c010173b <ide_init>
    swap_init();                // init swap
c01000a9:	e8 3a 67 00 00       	call   c01067e8 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 0d 0d 00 00       	call   c0100dc0 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 9e 1e 00 00       	call   c0101f56 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 56 91 00 00       	call   c0109213 <cpu_idle>

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
c01000da:	e8 02 0c 00 00       	call   c0100ce1 <mon_backtrace>
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
c010016b:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100170:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100174:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100178:	c7 04 24 21 a0 10 c0 	movl   $0xc010a021,(%esp)
c010017f:	e8 db 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100184:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100188:	0f b7 d0             	movzwl %ax,%edx
c010018b:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 2f a0 10 c0 	movl   $0xc010a02f,(%esp)
c010019f:	e8 bb 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	0f b7 d0             	movzwl %ax,%edx
c01001ab:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b8:	c7 04 24 3d a0 10 c0 	movl   $0xc010a03d,(%esp)
c01001bf:	e8 9b 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c8:	0f b7 d0             	movzwl %ax,%edx
c01001cb:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d8:	c7 04 24 4b a0 10 c0 	movl   $0xc010a04b,(%esp)
c01001df:	e8 7b 01 00 00       	call   c010035f <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e8:	0f b7 d0             	movzwl %ax,%edx
c01001eb:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c01001f0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f8:	c7 04 24 59 a0 10 c0 	movl   $0xc010a059,(%esp)
c01001ff:	e8 5b 01 00 00       	call   c010035f <cprintf>
    round ++;
c0100204:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0100209:	83 c0 01             	add    $0x1,%eax
c010020c:	a3 00 70 12 c0       	mov    %eax,0xc0127000
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
c0100228:	c7 04 24 68 a0 10 c0 	movl   $0xc010a068,(%esp)
c010022f:	e8 2b 01 00 00       	call   c010035f <cprintf>
    lab1_switch_to_user();
c0100234:	e8 da ff ff ff       	call   c0100213 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100239:	e8 0f ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023e:	c7 04 24 88 a0 10 c0 	movl   $0xc010a088,(%esp)
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
c0100269:	c7 04 24 a7 a0 10 c0 	movl   $0xc010a0a7,(%esp)
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
c01002b7:	88 90 20 70 12 c0    	mov    %dl,-0x3fed8fe0(%eax)
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
c01002f6:	05 20 70 12 c0       	add    $0xc0127020,%eax
c01002fb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002fe:	b8 20 70 12 c0       	mov    $0xc0127020,%eax
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
c0100318:	e8 19 13 00 00       	call   c0101636 <cons_putc>
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
c0100355:	e8 45 92 00 00       	call   c010959f <vprintfmt>
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
c0100391:	e8 a0 12 00 00       	call   c0101636 <cons_putc>
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
c01003ed:	e8 80 12 00 00       	call   c0101672 <cons_getc>
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
c010055f:	c7 00 ac a0 10 c0    	movl   $0xc010a0ac,(%eax)
    info->eip_line = 0;
c0100565:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100568:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010056f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100572:	c7 40 08 ac a0 10 c0 	movl   $0xc010a0ac,0x8(%eax)
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

    stabs = __STAB_BEGIN__;
c0100596:	c7 45 f4 d8 c2 10 c0 	movl   $0xc010c2d8,-0xc(%ebp)
    stab_end = __STAB_END__;
c010059d:	c7 45 f0 38 d7 11 c0 	movl   $0xc011d738,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005a4:	c7 45 ec 39 d7 11 c0 	movl   $0xc011d739,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005ab:	c7 45 e8 2e 1f 12 c0 	movl   $0xc0121f2e,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b8:	76 0d                	jbe    c01005c7 <debuginfo_eip+0x71>
c01005ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005bd:	83 e8 01             	sub    $0x1,%eax
c01005c0:	0f b6 00             	movzbl (%eax),%eax
c01005c3:	84 c0                	test   %al,%al
c01005c5:	74 0a                	je     c01005d1 <debuginfo_eip+0x7b>
        return -1;
c01005c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005cc:	e9 c0 02 00 00       	jmp    c0100891 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005de:	29 c2                	sub    %eax,%edx
c01005e0:	89 d0                	mov    %edx,%eax
c01005e2:	c1 f8 02             	sar    $0x2,%eax
c01005e5:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005eb:	83 e8 01             	sub    $0x1,%eax
c01005ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01005f4:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005f8:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005ff:	00 
c0100600:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0100603:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100607:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010060a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010060e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100611:	89 04 24             	mov    %eax,(%esp)
c0100614:	e8 e7 fd ff ff       	call   c0100400 <stab_binsearch>
    if (lfile == 0)
c0100619:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010061c:	85 c0                	test   %eax,%eax
c010061e:	75 0a                	jne    c010062a <debuginfo_eip+0xd4>
        return -1;
c0100620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100625:	e9 67 02 00 00       	jmp    c0100891 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010062a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010062d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100630:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100633:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100636:	8b 45 08             	mov    0x8(%ebp),%eax
c0100639:	89 44 24 10          	mov    %eax,0x10(%esp)
c010063d:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100644:	00 
c0100645:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100648:	89 44 24 08          	mov    %eax,0x8(%esp)
c010064c:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010064f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100653:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100656:	89 04 24             	mov    %eax,(%esp)
c0100659:	e8 a2 fd ff ff       	call   c0100400 <stab_binsearch>

    if (lfun <= rfun) {
c010065e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100661:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100664:	39 c2                	cmp    %eax,%edx
c0100666:	7f 7c                	jg     c01006e4 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100668:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010066b:	89 c2                	mov    %eax,%edx
c010066d:	89 d0                	mov    %edx,%eax
c010066f:	01 c0                	add    %eax,%eax
c0100671:	01 d0                	add    %edx,%eax
c0100673:	c1 e0 02             	shl    $0x2,%eax
c0100676:	89 c2                	mov    %eax,%edx
c0100678:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010067b:	01 d0                	add    %edx,%eax
c010067d:	8b 10                	mov    (%eax),%edx
c010067f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100682:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100685:	29 c1                	sub    %eax,%ecx
c0100687:	89 c8                	mov    %ecx,%eax
c0100689:	39 c2                	cmp    %eax,%edx
c010068b:	73 22                	jae    c01006af <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010068d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100690:	89 c2                	mov    %eax,%edx
c0100692:	89 d0                	mov    %edx,%eax
c0100694:	01 c0                	add    %eax,%eax
c0100696:	01 d0                	add    %edx,%eax
c0100698:	c1 e0 02             	shl    $0x2,%eax
c010069b:	89 c2                	mov    %eax,%edx
c010069d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a0:	01 d0                	add    %edx,%eax
c01006a2:	8b 10                	mov    (%eax),%edx
c01006a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006a7:	01 c2                	add    %eax,%edx
c01006a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006ac:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006af:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006b2:	89 c2                	mov    %eax,%edx
c01006b4:	89 d0                	mov    %edx,%eax
c01006b6:	01 c0                	add    %eax,%eax
c01006b8:	01 d0                	add    %edx,%eax
c01006ba:	c1 e0 02             	shl    $0x2,%eax
c01006bd:	89 c2                	mov    %eax,%edx
c01006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c2:	01 d0                	add    %edx,%eax
c01006c4:	8b 50 08             	mov    0x8(%eax),%edx
c01006c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006ca:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d0:	8b 40 10             	mov    0x10(%eax),%eax
c01006d3:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006e2:	eb 15                	jmp    c01006f9 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e7:	8b 55 08             	mov    0x8(%ebp),%edx
c01006ea:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fc:	8b 40 08             	mov    0x8(%eax),%eax
c01006ff:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100706:	00 
c0100707:	89 04 24             	mov    %eax,(%esp)
c010070a:	e8 c3 95 00 00       	call   c0109cd2 <strfind>
c010070f:	89 c2                	mov    %eax,%edx
c0100711:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100714:	8b 40 08             	mov    0x8(%eax),%eax
c0100717:	29 c2                	sub    %eax,%edx
c0100719:	8b 45 0c             	mov    0xc(%ebp),%eax
c010071c:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010071f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100722:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100726:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010072d:	00 
c010072e:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100731:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100735:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100738:	89 44 24 04          	mov    %eax,0x4(%esp)
c010073c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073f:	89 04 24             	mov    %eax,(%esp)
c0100742:	e8 b9 fc ff ff       	call   c0100400 <stab_binsearch>
    if (lline <= rline) {
c0100747:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010074a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010074d:	39 c2                	cmp    %eax,%edx
c010074f:	7f 24                	jg     c0100775 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100751:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100754:	89 c2                	mov    %eax,%edx
c0100756:	89 d0                	mov    %edx,%eax
c0100758:	01 c0                	add    %eax,%eax
c010075a:	01 d0                	add    %edx,%eax
c010075c:	c1 e0 02             	shl    $0x2,%eax
c010075f:	89 c2                	mov    %eax,%edx
c0100761:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100764:	01 d0                	add    %edx,%eax
c0100766:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010076a:	0f b7 d0             	movzwl %ax,%edx
c010076d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100770:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100773:	eb 13                	jmp    c0100788 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010077a:	e9 12 01 00 00       	jmp    c0100891 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010077f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100782:	83 e8 01             	sub    $0x1,%eax
c0100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100788:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010078b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010078e:	39 c2                	cmp    %eax,%edx
c0100790:	7c 56                	jl     c01007e8 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c0100792:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100795:	89 c2                	mov    %eax,%edx
c0100797:	89 d0                	mov    %edx,%eax
c0100799:	01 c0                	add    %eax,%eax
c010079b:	01 d0                	add    %edx,%eax
c010079d:	c1 e0 02             	shl    $0x2,%eax
c01007a0:	89 c2                	mov    %eax,%edx
c01007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a5:	01 d0                	add    %edx,%eax
c01007a7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007ab:	3c 84                	cmp    $0x84,%al
c01007ad:	74 39                	je     c01007e8 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b2:	89 c2                	mov    %eax,%edx
c01007b4:	89 d0                	mov    %edx,%eax
c01007b6:	01 c0                	add    %eax,%eax
c01007b8:	01 d0                	add    %edx,%eax
c01007ba:	c1 e0 02             	shl    $0x2,%eax
c01007bd:	89 c2                	mov    %eax,%edx
c01007bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c2:	01 d0                	add    %edx,%eax
c01007c4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007c8:	3c 64                	cmp    $0x64,%al
c01007ca:	75 b3                	jne    c010077f <debuginfo_eip+0x229>
c01007cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007cf:	89 c2                	mov    %eax,%edx
c01007d1:	89 d0                	mov    %edx,%eax
c01007d3:	01 c0                	add    %eax,%eax
c01007d5:	01 d0                	add    %edx,%eax
c01007d7:	c1 e0 02             	shl    $0x2,%eax
c01007da:	89 c2                	mov    %eax,%edx
c01007dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007df:	01 d0                	add    %edx,%eax
c01007e1:	8b 40 08             	mov    0x8(%eax),%eax
c01007e4:	85 c0                	test   %eax,%eax
c01007e6:	74 97                	je     c010077f <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007ee:	39 c2                	cmp    %eax,%edx
c01007f0:	7c 46                	jl     c0100838 <debuginfo_eip+0x2e2>
c01007f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007f5:	89 c2                	mov    %eax,%edx
c01007f7:	89 d0                	mov    %edx,%eax
c01007f9:	01 c0                	add    %eax,%eax
c01007fb:	01 d0                	add    %edx,%eax
c01007fd:	c1 e0 02             	shl    $0x2,%eax
c0100800:	89 c2                	mov    %eax,%edx
c0100802:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100805:	01 d0                	add    %edx,%eax
c0100807:	8b 10                	mov    (%eax),%edx
c0100809:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010080c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010080f:	29 c1                	sub    %eax,%ecx
c0100811:	89 c8                	mov    %ecx,%eax
c0100813:	39 c2                	cmp    %eax,%edx
c0100815:	73 21                	jae    c0100838 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100817:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010081a:	89 c2                	mov    %eax,%edx
c010081c:	89 d0                	mov    %edx,%eax
c010081e:	01 c0                	add    %eax,%eax
c0100820:	01 d0                	add    %edx,%eax
c0100822:	c1 e0 02             	shl    $0x2,%eax
c0100825:	89 c2                	mov    %eax,%edx
c0100827:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010082a:	01 d0                	add    %edx,%eax
c010082c:	8b 10                	mov    (%eax),%edx
c010082e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100831:	01 c2                	add    %eax,%edx
c0100833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100836:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100838:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010083b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010083e:	39 c2                	cmp    %eax,%edx
c0100840:	7d 4a                	jge    c010088c <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c0100842:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100845:	83 c0 01             	add    $0x1,%eax
c0100848:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010084b:	eb 18                	jmp    c0100865 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010084d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100850:	8b 40 14             	mov    0x14(%eax),%eax
c0100853:	8d 50 01             	lea    0x1(%eax),%edx
c0100856:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100859:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c010085c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085f:	83 c0 01             	add    $0x1,%eax
c0100862:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100865:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100868:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c010086b:	39 c2                	cmp    %eax,%edx
c010086d:	7d 1d                	jge    c010088c <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010086f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100872:	89 c2                	mov    %eax,%edx
c0100874:	89 d0                	mov    %edx,%eax
c0100876:	01 c0                	add    %eax,%eax
c0100878:	01 d0                	add    %edx,%eax
c010087a:	c1 e0 02             	shl    $0x2,%eax
c010087d:	89 c2                	mov    %eax,%edx
c010087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100882:	01 d0                	add    %edx,%eax
c0100884:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100888:	3c a0                	cmp    $0xa0,%al
c010088a:	74 c1                	je     c010084d <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c010088c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100891:	c9                   	leave  
c0100892:	c3                   	ret    

c0100893 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100893:	55                   	push   %ebp
c0100894:	89 e5                	mov    %esp,%ebp
c0100896:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100899:	c7 04 24 b6 a0 10 c0 	movl   $0xc010a0b6,(%esp)
c01008a0:	e8 ba fa ff ff       	call   c010035f <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01008a5:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008ac:	c0 
c01008ad:	c7 04 24 cf a0 10 c0 	movl   $0xc010a0cf,(%esp)
c01008b4:	e8 a6 fa ff ff       	call   c010035f <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008b9:	c7 44 24 04 e7 9f 10 	movl   $0xc0109fe7,0x4(%esp)
c01008c0:	c0 
c01008c1:	c7 04 24 e7 a0 10 c0 	movl   $0xc010a0e7,(%esp)
c01008c8:	e8 92 fa ff ff       	call   c010035f <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008cd:	c7 44 24 04 00 70 12 	movl   $0xc0127000,0x4(%esp)
c01008d4:	c0 
c01008d5:	c7 04 24 ff a0 10 c0 	movl   $0xc010a0ff,(%esp)
c01008dc:	e8 7e fa ff ff       	call   c010035f <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008e1:	c7 44 24 04 d8 a1 12 	movl   $0xc012a1d8,0x4(%esp)
c01008e8:	c0 
c01008e9:	c7 04 24 17 a1 10 c0 	movl   $0xc010a117,(%esp)
c01008f0:	e8 6a fa ff ff       	call   c010035f <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008f5:	b8 d8 a1 12 c0       	mov    $0xc012a1d8,%eax
c01008fa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100900:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100905:	29 c2                	sub    %eax,%edx
c0100907:	89 d0                	mov    %edx,%eax
c0100909:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c010090f:	85 c0                	test   %eax,%eax
c0100911:	0f 48 c2             	cmovs  %edx,%eax
c0100914:	c1 f8 0a             	sar    $0xa,%eax
c0100917:	89 44 24 04          	mov    %eax,0x4(%esp)
c010091b:	c7 04 24 30 a1 10 c0 	movl   $0xc010a130,(%esp)
c0100922:	e8 38 fa ff ff       	call   c010035f <cprintf>
}
c0100927:	c9                   	leave  
c0100928:	c3                   	ret    

c0100929 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100929:	55                   	push   %ebp
c010092a:	89 e5                	mov    %esp,%ebp
c010092c:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100932:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100935:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100939:	8b 45 08             	mov    0x8(%ebp),%eax
c010093c:	89 04 24             	mov    %eax,(%esp)
c010093f:	e8 12 fc ff ff       	call   c0100556 <debuginfo_eip>
c0100944:	85 c0                	test   %eax,%eax
c0100946:	74 15                	je     c010095d <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100948:	8b 45 08             	mov    0x8(%ebp),%eax
c010094b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010094f:	c7 04 24 5a a1 10 c0 	movl   $0xc010a15a,(%esp)
c0100956:	e8 04 fa ff ff       	call   c010035f <cprintf>
c010095b:	eb 6d                	jmp    c01009ca <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c010095d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100964:	eb 1c                	jmp    c0100982 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100966:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100969:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096c:	01 d0                	add    %edx,%eax
c010096e:	0f b6 00             	movzbl (%eax),%eax
c0100971:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100977:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010097a:	01 ca                	add    %ecx,%edx
c010097c:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c010097e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100982:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100985:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100988:	7f dc                	jg     c0100966 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c010098a:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100990:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100993:	01 d0                	add    %edx,%eax
c0100995:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100998:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010099b:	8b 55 08             	mov    0x8(%ebp),%edx
c010099e:	89 d1                	mov    %edx,%ecx
c01009a0:	29 c1                	sub    %eax,%ecx
c01009a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01009a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009a8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009ac:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009b2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009b6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009be:	c7 04 24 76 a1 10 c0 	movl   $0xc010a176,(%esp)
c01009c5:	e8 95 f9 ff ff       	call   c010035f <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009ca:	c9                   	leave  
c01009cb:	c3                   	ret    

c01009cc <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009cc:	55                   	push   %ebp
c01009cd:	89 e5                	mov    %esp,%ebp
c01009cf:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009d2:	8b 45 04             	mov    0x4(%ebp),%eax
c01009d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009db:	c9                   	leave  
c01009dc:	c3                   	ret    

c01009dd <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009dd:	55                   	push   %ebp
c01009de:	89 e5                	mov    %esp,%ebp
c01009e0:	53                   	push   %ebx
c01009e1:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009e4:	89 e8                	mov    %ebp,%eax
c01009e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c01009ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
c01009ef:	e8 d8 ff ff ff       	call   c01009cc <read_eip>
c01009f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c01009f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009fe:	e9 8d 00 00 00       	jmp    c0100a90 <print_stackframe+0xb3>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c0100a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a06:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a11:	c7 04 24 88 a1 10 c0 	movl   $0xc010a188,(%esp)
c0100a18:	e8 42 f9 ff ff       	call   c010035f <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
c0100a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a20:	83 c0 08             	add    $0x8,%eax
c0100a23:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("0x%08x 0x%08x 0x%08x 0x%08x",*args,*(args+1),*(args+2),*(args+3));
c0100a26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a29:	83 c0 0c             	add    $0xc,%eax
c0100a2c:	8b 18                	mov    (%eax),%ebx
c0100a2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a31:	83 c0 08             	add    $0x8,%eax
c0100a34:	8b 08                	mov    (%eax),%ecx
c0100a36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a39:	83 c0 04             	add    $0x4,%eax
c0100a3c:	8b 10                	mov    (%eax),%edx
c0100a3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a41:	8b 00                	mov    (%eax),%eax
c0100a43:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100a47:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a4b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a53:	c7 04 24 a4 a1 10 c0 	movl   $0xc010a1a4,(%esp)
c0100a5a:	e8 00 f9 ff ff       	call   c010035f <cprintf>
		cprintf("\n");
c0100a5f:	c7 04 24 c0 a1 10 c0 	movl   $0xc010a1c0,(%esp)
c0100a66:	e8 f4 f8 ff ff       	call   c010035f <cprintf>
		print_debuginfo(eip-1);
c0100a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a6e:	83 e8 01             	sub    $0x1,%eax
c0100a71:	89 04 24             	mov    %eax,(%esp)
c0100a74:	e8 b0 fe ff ff       	call   c0100929 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a7c:	83 c0 04             	add    $0x4,%eax
c0100a7f:	8b 00                	mov    (%eax),%eax
c0100a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
c0100a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a87:	8b 00                	mov    (%eax),%eax
c0100a89:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100a8c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a94:	74 0a                	je     c0100aa0 <print_stackframe+0xc3>
c0100a96:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a9a:	0f 8e 63 ff ff ff    	jle    c0100a03 <print_stackframe+0x26>
		cprintf("\n");
		print_debuginfo(eip-1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
c0100aa0:	83 c4 44             	add    $0x44,%esp
c0100aa3:	5b                   	pop    %ebx
c0100aa4:	5d                   	pop    %ebp
c0100aa5:	c3                   	ret    

c0100aa6 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100aa6:	55                   	push   %ebp
c0100aa7:	89 e5                	mov    %esp,%ebp
c0100aa9:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100aac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ab3:	eb 0c                	jmp    c0100ac1 <parse+0x1b>
            *buf ++ = '\0';
c0100ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab8:	8d 50 01             	lea    0x1(%eax),%edx
c0100abb:	89 55 08             	mov    %edx,0x8(%ebp)
c0100abe:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ac1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac4:	0f b6 00             	movzbl (%eax),%eax
c0100ac7:	84 c0                	test   %al,%al
c0100ac9:	74 1d                	je     c0100ae8 <parse+0x42>
c0100acb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ace:	0f b6 00             	movzbl (%eax),%eax
c0100ad1:	0f be c0             	movsbl %al,%eax
c0100ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad8:	c7 04 24 44 a2 10 c0 	movl   $0xc010a244,(%esp)
c0100adf:	e8 bb 91 00 00       	call   c0109c9f <strchr>
c0100ae4:	85 c0                	test   %eax,%eax
c0100ae6:	75 cd                	jne    c0100ab5 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ae8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aeb:	0f b6 00             	movzbl (%eax),%eax
c0100aee:	84 c0                	test   %al,%al
c0100af0:	75 02                	jne    c0100af4 <parse+0x4e>
            break;
c0100af2:	eb 67                	jmp    c0100b5b <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100af4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100af8:	75 14                	jne    c0100b0e <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100afa:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b01:	00 
c0100b02:	c7 04 24 49 a2 10 c0 	movl   $0xc010a249,(%esp)
c0100b09:	e8 51 f8 ff ff       	call   c010035f <cprintf>
        }
        argv[argc ++] = buf;
c0100b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b11:	8d 50 01             	lea    0x1(%eax),%edx
c0100b14:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b21:	01 c2                	add    %eax,%edx
c0100b23:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b26:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b28:	eb 04                	jmp    c0100b2e <parse+0x88>
            buf ++;
c0100b2a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b31:	0f b6 00             	movzbl (%eax),%eax
c0100b34:	84 c0                	test   %al,%al
c0100b36:	74 1d                	je     c0100b55 <parse+0xaf>
c0100b38:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b3b:	0f b6 00             	movzbl (%eax),%eax
c0100b3e:	0f be c0             	movsbl %al,%eax
c0100b41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b45:	c7 04 24 44 a2 10 c0 	movl   $0xc010a244,(%esp)
c0100b4c:	e8 4e 91 00 00       	call   c0109c9f <strchr>
c0100b51:	85 c0                	test   %eax,%eax
c0100b53:	74 d5                	je     c0100b2a <parse+0x84>
            buf ++;
        }
    }
c0100b55:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b56:	e9 66 ff ff ff       	jmp    c0100ac1 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b5e:	c9                   	leave  
c0100b5f:	c3                   	ret    

c0100b60 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b60:	55                   	push   %ebp
c0100b61:	89 e5                	mov    %esp,%ebp
c0100b63:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b66:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b70:	89 04 24             	mov    %eax,(%esp)
c0100b73:	e8 2e ff ff ff       	call   c0100aa6 <parse>
c0100b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b7f:	75 0a                	jne    c0100b8b <runcmd+0x2b>
        return 0;
c0100b81:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b86:	e9 85 00 00 00       	jmp    c0100c10 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b92:	eb 5c                	jmp    c0100bf0 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b94:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9a:	89 d0                	mov    %edx,%eax
c0100b9c:	01 c0                	add    %eax,%eax
c0100b9e:	01 d0                	add    %edx,%eax
c0100ba0:	c1 e0 02             	shl    $0x2,%eax
c0100ba3:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100ba8:	8b 00                	mov    (%eax),%eax
c0100baa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100bae:	89 04 24             	mov    %eax,(%esp)
c0100bb1:	e8 4a 90 00 00       	call   c0109c00 <strcmp>
c0100bb6:	85 c0                	test   %eax,%eax
c0100bb8:	75 32                	jne    c0100bec <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bbd:	89 d0                	mov    %edx,%eax
c0100bbf:	01 c0                	add    %eax,%eax
c0100bc1:	01 d0                	add    %edx,%eax
c0100bc3:	c1 e0 02             	shl    $0x2,%eax
c0100bc6:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100bcb:	8b 40 08             	mov    0x8(%eax),%eax
c0100bce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bd1:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bd4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bd7:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bdb:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bde:	83 c2 04             	add    $0x4,%edx
c0100be1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100be5:	89 0c 24             	mov    %ecx,(%esp)
c0100be8:	ff d0                	call   *%eax
c0100bea:	eb 24                	jmp    c0100c10 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf3:	83 f8 02             	cmp    $0x2,%eax
c0100bf6:	76 9c                	jbe    c0100b94 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bf8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bff:	c7 04 24 67 a2 10 c0 	movl   $0xc010a267,(%esp)
c0100c06:	e8 54 f7 ff ff       	call   c010035f <cprintf>
    return 0;
c0100c0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c10:	c9                   	leave  
c0100c11:	c3                   	ret    

c0100c12 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c12:	55                   	push   %ebp
c0100c13:	89 e5                	mov    %esp,%ebp
c0100c15:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c18:	c7 04 24 80 a2 10 c0 	movl   $0xc010a280,(%esp)
c0100c1f:	e8 3b f7 ff ff       	call   c010035f <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c24:	c7 04 24 a8 a2 10 c0 	movl   $0xc010a2a8,(%esp)
c0100c2b:	e8 2f f7 ff ff       	call   c010035f <cprintf>

    if (tf != NULL) {
c0100c30:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c34:	74 0b                	je     c0100c41 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c36:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c39:	89 04 24             	mov    %eax,(%esp)
c0100c3c:	e8 b3 16 00 00       	call   c01022f4 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c41:	c7 04 24 cd a2 10 c0 	movl   $0xc010a2cd,(%esp)
c0100c48:	e8 09 f6 ff ff       	call   c0100256 <readline>
c0100c4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c54:	74 18                	je     c0100c6e <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c56:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c60:	89 04 24             	mov    %eax,(%esp)
c0100c63:	e8 f8 fe ff ff       	call   c0100b60 <runcmd>
c0100c68:	85 c0                	test   %eax,%eax
c0100c6a:	79 02                	jns    c0100c6e <kmonitor+0x5c>
                break;
c0100c6c:	eb 02                	jmp    c0100c70 <kmonitor+0x5e>
            }
        }
    }
c0100c6e:	eb d1                	jmp    c0100c41 <kmonitor+0x2f>
}
c0100c70:	c9                   	leave  
c0100c71:	c3                   	ret    

c0100c72 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c72:	55                   	push   %ebp
c0100c73:	89 e5                	mov    %esp,%ebp
c0100c75:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c7f:	eb 3f                	jmp    c0100cc0 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c81:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c84:	89 d0                	mov    %edx,%eax
c0100c86:	01 c0                	add    %eax,%eax
c0100c88:	01 d0                	add    %edx,%eax
c0100c8a:	c1 e0 02             	shl    $0x2,%eax
c0100c8d:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100c92:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c95:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c98:	89 d0                	mov    %edx,%eax
c0100c9a:	01 c0                	add    %eax,%eax
c0100c9c:	01 d0                	add    %edx,%eax
c0100c9e:	c1 e0 02             	shl    $0x2,%eax
c0100ca1:	05 00 40 12 c0       	add    $0xc0124000,%eax
c0100ca6:	8b 00                	mov    (%eax),%eax
c0100ca8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100cac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cb0:	c7 04 24 d1 a2 10 c0 	movl   $0xc010a2d1,(%esp)
c0100cb7:	e8 a3 f6 ff ff       	call   c010035f <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cc3:	83 f8 02             	cmp    $0x2,%eax
c0100cc6:	76 b9                	jbe    c0100c81 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100cc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ccd:	c9                   	leave  
c0100cce:	c3                   	ret    

c0100ccf <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100ccf:	55                   	push   %ebp
c0100cd0:	89 e5                	mov    %esp,%ebp
c0100cd2:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cd5:	e8 b9 fb ff ff       	call   c0100893 <print_kerninfo>
    return 0;
c0100cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cdf:	c9                   	leave  
c0100ce0:	c3                   	ret    

c0100ce1 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100ce1:	55                   	push   %ebp
c0100ce2:	89 e5                	mov    %esp,%ebp
c0100ce4:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ce7:	e8 f1 fc ff ff       	call   c01009dd <print_stackframe>
    return 0;
c0100cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cf1:	c9                   	leave  
c0100cf2:	c3                   	ret    

c0100cf3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cf3:	55                   	push   %ebp
c0100cf4:	89 e5                	mov    %esp,%ebp
c0100cf6:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cf9:	a1 20 74 12 c0       	mov    0xc0127420,%eax
c0100cfe:	85 c0                	test   %eax,%eax
c0100d00:	74 02                	je     c0100d04 <__panic+0x11>
        goto panic_dead;
c0100d02:	eb 59                	jmp    c0100d5d <__panic+0x6a>
    }
    is_panic = 1;
c0100d04:	c7 05 20 74 12 c0 01 	movl   $0x1,0xc0127420
c0100d0b:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d0e:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d17:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d22:	c7 04 24 da a2 10 c0 	movl   $0xc010a2da,(%esp)
c0100d29:	e8 31 f6 ff ff       	call   c010035f <cprintf>
    vcprintf(fmt, ap);
c0100d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d35:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d38:	89 04 24             	mov    %eax,(%esp)
c0100d3b:	e8 ec f5 ff ff       	call   c010032c <vcprintf>
    cprintf("\n");
c0100d40:	c7 04 24 f6 a2 10 c0 	movl   $0xc010a2f6,(%esp)
c0100d47:	e8 13 f6 ff ff       	call   c010035f <cprintf>
    
    cprintf("stack trackback:\n");
c0100d4c:	c7 04 24 f8 a2 10 c0 	movl   $0xc010a2f8,(%esp)
c0100d53:	e8 07 f6 ff ff       	call   c010035f <cprintf>
    print_stackframe();
c0100d58:	e8 80 fc ff ff       	call   c01009dd <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d5d:	e8 fa 11 00 00       	call   c0101f5c <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d69:	e8 a4 fe ff ff       	call   c0100c12 <kmonitor>
    }
c0100d6e:	eb f2                	jmp    c0100d62 <__panic+0x6f>

c0100d70 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d70:	55                   	push   %ebp
c0100d71:	89 e5                	mov    %esp,%ebp
c0100d73:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d76:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d7f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d83:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d8a:	c7 04 24 0a a3 10 c0 	movl   $0xc010a30a,(%esp)
c0100d91:	e8 c9 f5 ff ff       	call   c010035f <cprintf>
    vcprintf(fmt, ap);
c0100d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d9d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100da0:	89 04 24             	mov    %eax,(%esp)
c0100da3:	e8 84 f5 ff ff       	call   c010032c <vcprintf>
    cprintf("\n");
c0100da8:	c7 04 24 f6 a2 10 c0 	movl   $0xc010a2f6,(%esp)
c0100daf:	e8 ab f5 ff ff       	call   c010035f <cprintf>
    va_end(ap);
}
c0100db4:	c9                   	leave  
c0100db5:	c3                   	ret    

c0100db6 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100db6:	55                   	push   %ebp
c0100db7:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100db9:	a1 20 74 12 c0       	mov    0xc0127420,%eax
}
c0100dbe:	5d                   	pop    %ebp
c0100dbf:	c3                   	ret    

c0100dc0 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dc0:	55                   	push   %ebp
c0100dc1:	89 e5                	mov    %esp,%ebp
c0100dc3:	83 ec 28             	sub    $0x28,%esp
c0100dc6:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dcc:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dd0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dd4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dd8:	ee                   	out    %al,(%dx)
c0100dd9:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100ddf:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100de3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100de7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100deb:	ee                   	out    %al,(%dx)
c0100dec:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100df2:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100df6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dfa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dfe:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dff:	c7 05 74 a0 12 c0 00 	movl   $0x0,0xc012a074
c0100e06:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e09:	c7 04 24 28 a3 10 c0 	movl   $0xc010a328,(%esp)
c0100e10:	e8 4a f5 ff ff       	call   c010035f <cprintf>
    pic_enable(IRQ_TIMER);
c0100e15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e1c:	e8 99 11 00 00       	call   c0101fba <pic_enable>
}
c0100e21:	c9                   	leave  
c0100e22:	c3                   	ret    

c0100e23 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e23:	55                   	push   %ebp
c0100e24:	89 e5                	mov    %esp,%ebp
c0100e26:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e29:	9c                   	pushf  
c0100e2a:	58                   	pop    %eax
c0100e2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e31:	25 00 02 00 00       	and    $0x200,%eax
c0100e36:	85 c0                	test   %eax,%eax
c0100e38:	74 0c                	je     c0100e46 <__intr_save+0x23>
        intr_disable();
c0100e3a:	e8 1d 11 00 00       	call   c0101f5c <intr_disable>
        return 1;
c0100e3f:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e44:	eb 05                	jmp    c0100e4b <__intr_save+0x28>
    }
    return 0;
c0100e46:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e4b:	c9                   	leave  
c0100e4c:	c3                   	ret    

c0100e4d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e4d:	55                   	push   %ebp
c0100e4e:	89 e5                	mov    %esp,%ebp
c0100e50:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e53:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e57:	74 05                	je     c0100e5e <__intr_restore+0x11>
        intr_enable();
c0100e59:	e8 f8 10 00 00       	call   c0101f56 <intr_enable>
    }
}
c0100e5e:	c9                   	leave  
c0100e5f:	c3                   	ret    

c0100e60 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e60:	55                   	push   %ebp
c0100e61:	89 e5                	mov    %esp,%ebp
c0100e63:	83 ec 10             	sub    $0x10,%esp
c0100e66:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e6c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e70:	89 c2                	mov    %eax,%edx
c0100e72:	ec                   	in     (%dx),%al
c0100e73:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e76:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e7c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e80:	89 c2                	mov    %eax,%edx
c0100e82:	ec                   	in     (%dx),%al
c0100e83:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e86:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e8c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e90:	89 c2                	mov    %eax,%edx
c0100e92:	ec                   	in     (%dx),%al
c0100e93:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e96:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e9c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ea0:	89 c2                	mov    %eax,%edx
c0100ea2:	ec                   	in     (%dx),%al
c0100ea3:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100ea6:	c9                   	leave  
c0100ea7:	c3                   	ret    

c0100ea8 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ea8:	55                   	push   %ebp
c0100ea9:	89 e5                	mov    %esp,%ebp
c0100eab:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100eae:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100eb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb8:	0f b7 00             	movzwl (%eax),%eax
c0100ebb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100ebf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec2:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eca:	0f b7 00             	movzwl (%eax),%eax
c0100ecd:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100ed1:	74 12                	je     c0100ee5 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ed3:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eda:	66 c7 05 46 74 12 c0 	movw   $0x3b4,0xc0127446
c0100ee1:	b4 03 
c0100ee3:	eb 13                	jmp    c0100ef8 <cga_init+0x50>
    } else {
        *cp = was;
c0100ee5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eec:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100eef:	66 c7 05 46 74 12 c0 	movw   $0x3d4,0xc0127446
c0100ef6:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ef8:	0f b7 05 46 74 12 c0 	movzwl 0xc0127446,%eax
c0100eff:	0f b7 c0             	movzwl %ax,%eax
c0100f02:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100f06:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f0a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f0e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f12:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f13:	0f b7 05 46 74 12 c0 	movzwl 0xc0127446,%eax
c0100f1a:	83 c0 01             	add    $0x1,%eax
c0100f1d:	0f b7 c0             	movzwl %ax,%eax
c0100f20:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f24:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f28:	89 c2                	mov    %eax,%edx
c0100f2a:	ec                   	in     (%dx),%al
c0100f2b:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f2e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f32:	0f b6 c0             	movzbl %al,%eax
c0100f35:	c1 e0 08             	shl    $0x8,%eax
c0100f38:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f3b:	0f b7 05 46 74 12 c0 	movzwl 0xc0127446,%eax
c0100f42:	0f b7 c0             	movzwl %ax,%eax
c0100f45:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f49:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f4d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f51:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f55:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f56:	0f b7 05 46 74 12 c0 	movzwl 0xc0127446,%eax
c0100f5d:	83 c0 01             	add    $0x1,%eax
c0100f60:	0f b7 c0             	movzwl %ax,%eax
c0100f63:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f67:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f6b:	89 c2                	mov    %eax,%edx
c0100f6d:	ec                   	in     (%dx),%al
c0100f6e:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f71:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f75:	0f b6 c0             	movzbl %al,%eax
c0100f78:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f7e:	a3 40 74 12 c0       	mov    %eax,0xc0127440
    crt_pos = pos;
c0100f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f86:	66 a3 44 74 12 c0    	mov    %ax,0xc0127444
}
c0100f8c:	c9                   	leave  
c0100f8d:	c3                   	ret    

c0100f8e <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f8e:	55                   	push   %ebp
c0100f8f:	89 e5                	mov    %esp,%ebp
c0100f91:	83 ec 48             	sub    $0x48,%esp
c0100f94:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f9a:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f9e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100fa2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100fa6:	ee                   	out    %al,(%dx)
c0100fa7:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100fad:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100fb1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fb5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fb9:	ee                   	out    %al,(%dx)
c0100fba:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100fc0:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fc4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fc8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fcc:	ee                   	out    %al,(%dx)
c0100fcd:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fd3:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fd7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fdb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fdf:	ee                   	out    %al,(%dx)
c0100fe0:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fe6:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fea:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fee:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100ff2:	ee                   	out    %al,(%dx)
c0100ff3:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100ff9:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100ffd:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101001:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101005:	ee                   	out    %al,(%dx)
c0101006:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010100c:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101010:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101014:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101018:	ee                   	out    %al,(%dx)
c0101019:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101f:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101023:	89 c2                	mov    %eax,%edx
c0101025:	ec                   	in     (%dx),%al
c0101026:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101029:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010102d:	3c ff                	cmp    $0xff,%al
c010102f:	0f 95 c0             	setne  %al
c0101032:	0f b6 c0             	movzbl %al,%eax
c0101035:	a3 48 74 12 c0       	mov    %eax,0xc0127448
c010103a:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101040:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101044:	89 c2                	mov    %eax,%edx
c0101046:	ec                   	in     (%dx),%al
c0101047:	88 45 d5             	mov    %al,-0x2b(%ebp)
c010104a:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101050:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101054:	89 c2                	mov    %eax,%edx
c0101056:	ec                   	in     (%dx),%al
c0101057:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010105a:	a1 48 74 12 c0       	mov    0xc0127448,%eax
c010105f:	85 c0                	test   %eax,%eax
c0101061:	74 0c                	je     c010106f <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101063:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010106a:	e8 4b 0f 00 00       	call   c0101fba <pic_enable>
    }
}
c010106f:	c9                   	leave  
c0101070:	c3                   	ret    

c0101071 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101071:	55                   	push   %ebp
c0101072:	89 e5                	mov    %esp,%ebp
c0101074:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101077:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010107e:	eb 09                	jmp    c0101089 <lpt_putc_sub+0x18>
        delay();
c0101080:	e8 db fd ff ff       	call   c0100e60 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101085:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101089:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010108f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101093:	89 c2                	mov    %eax,%edx
c0101095:	ec                   	in     (%dx),%al
c0101096:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101099:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010109d:	84 c0                	test   %al,%al
c010109f:	78 09                	js     c01010aa <lpt_putc_sub+0x39>
c01010a1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010a8:	7e d6                	jle    c0101080 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01010aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01010ad:	0f b6 c0             	movzbl %al,%eax
c01010b0:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01010b6:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010b9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010bd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010c1:	ee                   	out    %al,(%dx)
c01010c2:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010c8:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010cc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010d0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010d4:	ee                   	out    %al,(%dx)
c01010d5:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010db:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010df:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010e3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010e7:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010e8:	c9                   	leave  
c01010e9:	c3                   	ret    

c01010ea <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010ea:	55                   	push   %ebp
c01010eb:	89 e5                	mov    %esp,%ebp
c01010ed:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010f0:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010f4:	74 0d                	je     c0101103 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f9:	89 04 24             	mov    %eax,(%esp)
c01010fc:	e8 70 ff ff ff       	call   c0101071 <lpt_putc_sub>
c0101101:	eb 24                	jmp    c0101127 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101103:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010110a:	e8 62 ff ff ff       	call   c0101071 <lpt_putc_sub>
        lpt_putc_sub(' ');
c010110f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101116:	e8 56 ff ff ff       	call   c0101071 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010111b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101122:	e8 4a ff ff ff       	call   c0101071 <lpt_putc_sub>
    }
}
c0101127:	c9                   	leave  
c0101128:	c3                   	ret    

c0101129 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101129:	55                   	push   %ebp
c010112a:	89 e5                	mov    %esp,%ebp
c010112c:	53                   	push   %ebx
c010112d:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101130:	8b 45 08             	mov    0x8(%ebp),%eax
c0101133:	b0 00                	mov    $0x0,%al
c0101135:	85 c0                	test   %eax,%eax
c0101137:	75 07                	jne    c0101140 <cga_putc+0x17>
        c |= 0x0700;
c0101139:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101140:	8b 45 08             	mov    0x8(%ebp),%eax
c0101143:	0f b6 c0             	movzbl %al,%eax
c0101146:	83 f8 0a             	cmp    $0xa,%eax
c0101149:	74 4c                	je     c0101197 <cga_putc+0x6e>
c010114b:	83 f8 0d             	cmp    $0xd,%eax
c010114e:	74 57                	je     c01011a7 <cga_putc+0x7e>
c0101150:	83 f8 08             	cmp    $0x8,%eax
c0101153:	0f 85 88 00 00 00    	jne    c01011e1 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101159:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c0101160:	66 85 c0             	test   %ax,%ax
c0101163:	74 30                	je     c0101195 <cga_putc+0x6c>
            crt_pos --;
c0101165:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c010116c:	83 e8 01             	sub    $0x1,%eax
c010116f:	66 a3 44 74 12 c0    	mov    %ax,0xc0127444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101175:	a1 40 74 12 c0       	mov    0xc0127440,%eax
c010117a:	0f b7 15 44 74 12 c0 	movzwl 0xc0127444,%edx
c0101181:	0f b7 d2             	movzwl %dx,%edx
c0101184:	01 d2                	add    %edx,%edx
c0101186:	01 c2                	add    %eax,%edx
c0101188:	8b 45 08             	mov    0x8(%ebp),%eax
c010118b:	b0 00                	mov    $0x0,%al
c010118d:	83 c8 20             	or     $0x20,%eax
c0101190:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101193:	eb 72                	jmp    c0101207 <cga_putc+0xde>
c0101195:	eb 70                	jmp    c0101207 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101197:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c010119e:	83 c0 50             	add    $0x50,%eax
c01011a1:	66 a3 44 74 12 c0    	mov    %ax,0xc0127444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011a7:	0f b7 1d 44 74 12 c0 	movzwl 0xc0127444,%ebx
c01011ae:	0f b7 0d 44 74 12 c0 	movzwl 0xc0127444,%ecx
c01011b5:	0f b7 c1             	movzwl %cx,%eax
c01011b8:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01011be:	c1 e8 10             	shr    $0x10,%eax
c01011c1:	89 c2                	mov    %eax,%edx
c01011c3:	66 c1 ea 06          	shr    $0x6,%dx
c01011c7:	89 d0                	mov    %edx,%eax
c01011c9:	c1 e0 02             	shl    $0x2,%eax
c01011cc:	01 d0                	add    %edx,%eax
c01011ce:	c1 e0 04             	shl    $0x4,%eax
c01011d1:	29 c1                	sub    %eax,%ecx
c01011d3:	89 ca                	mov    %ecx,%edx
c01011d5:	89 d8                	mov    %ebx,%eax
c01011d7:	29 d0                	sub    %edx,%eax
c01011d9:	66 a3 44 74 12 c0    	mov    %ax,0xc0127444
        break;
c01011df:	eb 26                	jmp    c0101207 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011e1:	8b 0d 40 74 12 c0    	mov    0xc0127440,%ecx
c01011e7:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c01011ee:	8d 50 01             	lea    0x1(%eax),%edx
c01011f1:	66 89 15 44 74 12 c0 	mov    %dx,0xc0127444
c01011f8:	0f b7 c0             	movzwl %ax,%eax
c01011fb:	01 c0                	add    %eax,%eax
c01011fd:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101200:	8b 45 08             	mov    0x8(%ebp),%eax
c0101203:	66 89 02             	mov    %ax,(%edx)
        break;
c0101206:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101207:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c010120e:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101212:	76 5b                	jbe    c010126f <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101214:	a1 40 74 12 c0       	mov    0xc0127440,%eax
c0101219:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010121f:	a1 40 74 12 c0       	mov    0xc0127440,%eax
c0101224:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010122b:	00 
c010122c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101230:	89 04 24             	mov    %eax,(%esp)
c0101233:	e8 65 8c 00 00       	call   c0109e9d <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101238:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010123f:	eb 15                	jmp    c0101256 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101241:	a1 40 74 12 c0       	mov    0xc0127440,%eax
c0101246:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101249:	01 d2                	add    %edx,%edx
c010124b:	01 d0                	add    %edx,%eax
c010124d:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101252:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101256:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010125d:	7e e2                	jle    c0101241 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010125f:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c0101266:	83 e8 50             	sub    $0x50,%eax
c0101269:	66 a3 44 74 12 c0    	mov    %ax,0xc0127444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010126f:	0f b7 05 46 74 12 c0 	movzwl 0xc0127446,%eax
c0101276:	0f b7 c0             	movzwl %ax,%eax
c0101279:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010127d:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101281:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101285:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101289:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010128a:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c0101291:	66 c1 e8 08          	shr    $0x8,%ax
c0101295:	0f b6 c0             	movzbl %al,%eax
c0101298:	0f b7 15 46 74 12 c0 	movzwl 0xc0127446,%edx
c010129f:	83 c2 01             	add    $0x1,%edx
c01012a2:	0f b7 d2             	movzwl %dx,%edx
c01012a5:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01012a9:	88 45 ed             	mov    %al,-0x13(%ebp)
c01012ac:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012b0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012b4:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012b5:	0f b7 05 46 74 12 c0 	movzwl 0xc0127446,%eax
c01012bc:	0f b7 c0             	movzwl %ax,%eax
c01012bf:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012c3:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012c7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012cb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012cf:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012d0:	0f b7 05 44 74 12 c0 	movzwl 0xc0127444,%eax
c01012d7:	0f b6 c0             	movzbl %al,%eax
c01012da:	0f b7 15 46 74 12 c0 	movzwl 0xc0127446,%edx
c01012e1:	83 c2 01             	add    $0x1,%edx
c01012e4:	0f b7 d2             	movzwl %dx,%edx
c01012e7:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012eb:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012ee:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012f2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012f6:	ee                   	out    %al,(%dx)
}
c01012f7:	83 c4 34             	add    $0x34,%esp
c01012fa:	5b                   	pop    %ebx
c01012fb:	5d                   	pop    %ebp
c01012fc:	c3                   	ret    

c01012fd <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012fd:	55                   	push   %ebp
c01012fe:	89 e5                	mov    %esp,%ebp
c0101300:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101303:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010130a:	eb 09                	jmp    c0101315 <serial_putc_sub+0x18>
        delay();
c010130c:	e8 4f fb ff ff       	call   c0100e60 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101311:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101315:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010131b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010131f:	89 c2                	mov    %eax,%edx
c0101321:	ec                   	in     (%dx),%al
c0101322:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101325:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101329:	0f b6 c0             	movzbl %al,%eax
c010132c:	83 e0 20             	and    $0x20,%eax
c010132f:	85 c0                	test   %eax,%eax
c0101331:	75 09                	jne    c010133c <serial_putc_sub+0x3f>
c0101333:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010133a:	7e d0                	jle    c010130c <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010133c:	8b 45 08             	mov    0x8(%ebp),%eax
c010133f:	0f b6 c0             	movzbl %al,%eax
c0101342:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101348:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010134b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010134f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101353:	ee                   	out    %al,(%dx)
}
c0101354:	c9                   	leave  
c0101355:	c3                   	ret    

c0101356 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101356:	55                   	push   %ebp
c0101357:	89 e5                	mov    %esp,%ebp
c0101359:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010135c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101360:	74 0d                	je     c010136f <serial_putc+0x19>
        serial_putc_sub(c);
c0101362:	8b 45 08             	mov    0x8(%ebp),%eax
c0101365:	89 04 24             	mov    %eax,(%esp)
c0101368:	e8 90 ff ff ff       	call   c01012fd <serial_putc_sub>
c010136d:	eb 24                	jmp    c0101393 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010136f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101376:	e8 82 ff ff ff       	call   c01012fd <serial_putc_sub>
        serial_putc_sub(' ');
c010137b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101382:	e8 76 ff ff ff       	call   c01012fd <serial_putc_sub>
        serial_putc_sub('\b');
c0101387:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010138e:	e8 6a ff ff ff       	call   c01012fd <serial_putc_sub>
    }
}
c0101393:	c9                   	leave  
c0101394:	c3                   	ret    

c0101395 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101395:	55                   	push   %ebp
c0101396:	89 e5                	mov    %esp,%ebp
c0101398:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010139b:	eb 33                	jmp    c01013d0 <cons_intr+0x3b>
        if (c != 0) {
c010139d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013a1:	74 2d                	je     c01013d0 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013a3:	a1 64 76 12 c0       	mov    0xc0127664,%eax
c01013a8:	8d 50 01             	lea    0x1(%eax),%edx
c01013ab:	89 15 64 76 12 c0    	mov    %edx,0xc0127664
c01013b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013b4:	88 90 60 74 12 c0    	mov    %dl,-0x3fed8ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013ba:	a1 64 76 12 c0       	mov    0xc0127664,%eax
c01013bf:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013c4:	75 0a                	jne    c01013d0 <cons_intr+0x3b>
                cons.wpos = 0;
c01013c6:	c7 05 64 76 12 c0 00 	movl   $0x0,0xc0127664
c01013cd:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01013d3:	ff d0                	call   *%eax
c01013d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013d8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013dc:	75 bf                	jne    c010139d <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013de:	c9                   	leave  
c01013df:	c3                   	ret    

c01013e0 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013e0:	55                   	push   %ebp
c01013e1:	89 e5                	mov    %esp,%ebp
c01013e3:	83 ec 10             	sub    $0x10,%esp
c01013e6:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ec:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013f0:	89 c2                	mov    %eax,%edx
c01013f2:	ec                   	in     (%dx),%al
c01013f3:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013f6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013fa:	0f b6 c0             	movzbl %al,%eax
c01013fd:	83 e0 01             	and    $0x1,%eax
c0101400:	85 c0                	test   %eax,%eax
c0101402:	75 07                	jne    c010140b <serial_proc_data+0x2b>
        return -1;
c0101404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101409:	eb 2a                	jmp    c0101435 <serial_proc_data+0x55>
c010140b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101411:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101415:	89 c2                	mov    %eax,%edx
c0101417:	ec                   	in     (%dx),%al
c0101418:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010141b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010141f:	0f b6 c0             	movzbl %al,%eax
c0101422:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101425:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101429:	75 07                	jne    c0101432 <serial_proc_data+0x52>
        c = '\b';
c010142b:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101432:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101435:	c9                   	leave  
c0101436:	c3                   	ret    

c0101437 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101437:	55                   	push   %ebp
c0101438:	89 e5                	mov    %esp,%ebp
c010143a:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010143d:	a1 48 74 12 c0       	mov    0xc0127448,%eax
c0101442:	85 c0                	test   %eax,%eax
c0101444:	74 0c                	je     c0101452 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101446:	c7 04 24 e0 13 10 c0 	movl   $0xc01013e0,(%esp)
c010144d:	e8 43 ff ff ff       	call   c0101395 <cons_intr>
    }
}
c0101452:	c9                   	leave  
c0101453:	c3                   	ret    

c0101454 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101454:	55                   	push   %ebp
c0101455:	89 e5                	mov    %esp,%ebp
c0101457:	83 ec 38             	sub    $0x38,%esp
c010145a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101460:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101464:	89 c2                	mov    %eax,%edx
c0101466:	ec                   	in     (%dx),%al
c0101467:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010146a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010146e:	0f b6 c0             	movzbl %al,%eax
c0101471:	83 e0 01             	and    $0x1,%eax
c0101474:	85 c0                	test   %eax,%eax
c0101476:	75 0a                	jne    c0101482 <kbd_proc_data+0x2e>
        return -1;
c0101478:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010147d:	e9 59 01 00 00       	jmp    c01015db <kbd_proc_data+0x187>
c0101482:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101488:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010148c:	89 c2                	mov    %eax,%edx
c010148e:	ec                   	in     (%dx),%al
c010148f:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101492:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101496:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101499:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010149d:	75 17                	jne    c01014b6 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010149f:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c01014a4:	83 c8 40             	or     $0x40,%eax
c01014a7:	a3 68 76 12 c0       	mov    %eax,0xc0127668
        return 0;
c01014ac:	b8 00 00 00 00       	mov    $0x0,%eax
c01014b1:	e9 25 01 00 00       	jmp    c01015db <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01014b6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ba:	84 c0                	test   %al,%al
c01014bc:	79 47                	jns    c0101505 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014be:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c01014c3:	83 e0 40             	and    $0x40,%eax
c01014c6:	85 c0                	test   %eax,%eax
c01014c8:	75 09                	jne    c01014d3 <kbd_proc_data+0x7f>
c01014ca:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ce:	83 e0 7f             	and    $0x7f,%eax
c01014d1:	eb 04                	jmp    c01014d7 <kbd_proc_data+0x83>
c01014d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014d7:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014da:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014de:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c01014e5:	83 c8 40             	or     $0x40,%eax
c01014e8:	0f b6 c0             	movzbl %al,%eax
c01014eb:	f7 d0                	not    %eax
c01014ed:	89 c2                	mov    %eax,%edx
c01014ef:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c01014f4:	21 d0                	and    %edx,%eax
c01014f6:	a3 68 76 12 c0       	mov    %eax,0xc0127668
        return 0;
c01014fb:	b8 00 00 00 00       	mov    $0x0,%eax
c0101500:	e9 d6 00 00 00       	jmp    c01015db <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101505:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c010150a:	83 e0 40             	and    $0x40,%eax
c010150d:	85 c0                	test   %eax,%eax
c010150f:	74 11                	je     c0101522 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101511:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101515:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c010151a:	83 e0 bf             	and    $0xffffffbf,%eax
c010151d:	a3 68 76 12 c0       	mov    %eax,0xc0127668
    }

    shift |= shiftcode[data];
c0101522:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101526:	0f b6 80 40 40 12 c0 	movzbl -0x3fedbfc0(%eax),%eax
c010152d:	0f b6 d0             	movzbl %al,%edx
c0101530:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c0101535:	09 d0                	or     %edx,%eax
c0101537:	a3 68 76 12 c0       	mov    %eax,0xc0127668
    shift ^= togglecode[data];
c010153c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101540:	0f b6 80 40 41 12 c0 	movzbl -0x3fedbec0(%eax),%eax
c0101547:	0f b6 d0             	movzbl %al,%edx
c010154a:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c010154f:	31 d0                	xor    %edx,%eax
c0101551:	a3 68 76 12 c0       	mov    %eax,0xc0127668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101556:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c010155b:	83 e0 03             	and    $0x3,%eax
c010155e:	8b 14 85 40 45 12 c0 	mov    -0x3fedbac0(,%eax,4),%edx
c0101565:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101569:	01 d0                	add    %edx,%eax
c010156b:	0f b6 00             	movzbl (%eax),%eax
c010156e:	0f b6 c0             	movzbl %al,%eax
c0101571:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101574:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c0101579:	83 e0 08             	and    $0x8,%eax
c010157c:	85 c0                	test   %eax,%eax
c010157e:	74 22                	je     c01015a2 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101580:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101584:	7e 0c                	jle    c0101592 <kbd_proc_data+0x13e>
c0101586:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010158a:	7f 06                	jg     c0101592 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010158c:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101590:	eb 10                	jmp    c01015a2 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101592:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101596:	7e 0a                	jle    c01015a2 <kbd_proc_data+0x14e>
c0101598:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010159c:	7f 04                	jg     c01015a2 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010159e:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01015a2:	a1 68 76 12 c0       	mov    0xc0127668,%eax
c01015a7:	f7 d0                	not    %eax
c01015a9:	83 e0 06             	and    $0x6,%eax
c01015ac:	85 c0                	test   %eax,%eax
c01015ae:	75 28                	jne    c01015d8 <kbd_proc_data+0x184>
c01015b0:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015b7:	75 1f                	jne    c01015d8 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01015b9:	c7 04 24 43 a3 10 c0 	movl   $0xc010a343,(%esp)
c01015c0:	e8 9a ed ff ff       	call   c010035f <cprintf>
c01015c5:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015cb:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015cf:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015d3:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015d7:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015db:	c9                   	leave  
c01015dc:	c3                   	ret    

c01015dd <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015dd:	55                   	push   %ebp
c01015de:	89 e5                	mov    %esp,%ebp
c01015e0:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015e3:	c7 04 24 54 14 10 c0 	movl   $0xc0101454,(%esp)
c01015ea:	e8 a6 fd ff ff       	call   c0101395 <cons_intr>
}
c01015ef:	c9                   	leave  
c01015f0:	c3                   	ret    

c01015f1 <kbd_init>:

static void
kbd_init(void) {
c01015f1:	55                   	push   %ebp
c01015f2:	89 e5                	mov    %esp,%ebp
c01015f4:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015f7:	e8 e1 ff ff ff       	call   c01015dd <kbd_intr>
    pic_enable(IRQ_KBD);
c01015fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101603:	e8 b2 09 00 00       	call   c0101fba <pic_enable>
}
c0101608:	c9                   	leave  
c0101609:	c3                   	ret    

c010160a <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010160a:	55                   	push   %ebp
c010160b:	89 e5                	mov    %esp,%ebp
c010160d:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101610:	e8 93 f8 ff ff       	call   c0100ea8 <cga_init>
    serial_init();
c0101615:	e8 74 f9 ff ff       	call   c0100f8e <serial_init>
    kbd_init();
c010161a:	e8 d2 ff ff ff       	call   c01015f1 <kbd_init>
    if (!serial_exists) {
c010161f:	a1 48 74 12 c0       	mov    0xc0127448,%eax
c0101624:	85 c0                	test   %eax,%eax
c0101626:	75 0c                	jne    c0101634 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101628:	c7 04 24 4f a3 10 c0 	movl   $0xc010a34f,(%esp)
c010162f:	e8 2b ed ff ff       	call   c010035f <cprintf>
    }
}
c0101634:	c9                   	leave  
c0101635:	c3                   	ret    

c0101636 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101636:	55                   	push   %ebp
c0101637:	89 e5                	mov    %esp,%ebp
c0101639:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010163c:	e8 e2 f7 ff ff       	call   c0100e23 <__intr_save>
c0101641:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101644:	8b 45 08             	mov    0x8(%ebp),%eax
c0101647:	89 04 24             	mov    %eax,(%esp)
c010164a:	e8 9b fa ff ff       	call   c01010ea <lpt_putc>
        cga_putc(c);
c010164f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101652:	89 04 24             	mov    %eax,(%esp)
c0101655:	e8 cf fa ff ff       	call   c0101129 <cga_putc>
        serial_putc(c);
c010165a:	8b 45 08             	mov    0x8(%ebp),%eax
c010165d:	89 04 24             	mov    %eax,(%esp)
c0101660:	e8 f1 fc ff ff       	call   c0101356 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101665:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101668:	89 04 24             	mov    %eax,(%esp)
c010166b:	e8 dd f7 ff ff       	call   c0100e4d <__intr_restore>
}
c0101670:	c9                   	leave  
c0101671:	c3                   	ret    

c0101672 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101672:	55                   	push   %ebp
c0101673:	89 e5                	mov    %esp,%ebp
c0101675:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010167f:	e8 9f f7 ff ff       	call   c0100e23 <__intr_save>
c0101684:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101687:	e8 ab fd ff ff       	call   c0101437 <serial_intr>
        kbd_intr();
c010168c:	e8 4c ff ff ff       	call   c01015dd <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101691:	8b 15 60 76 12 c0    	mov    0xc0127660,%edx
c0101697:	a1 64 76 12 c0       	mov    0xc0127664,%eax
c010169c:	39 c2                	cmp    %eax,%edx
c010169e:	74 31                	je     c01016d1 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016a0:	a1 60 76 12 c0       	mov    0xc0127660,%eax
c01016a5:	8d 50 01             	lea    0x1(%eax),%edx
c01016a8:	89 15 60 76 12 c0    	mov    %edx,0xc0127660
c01016ae:	0f b6 80 60 74 12 c0 	movzbl -0x3fed8ba0(%eax),%eax
c01016b5:	0f b6 c0             	movzbl %al,%eax
c01016b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016bb:	a1 60 76 12 c0       	mov    0xc0127660,%eax
c01016c0:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016c5:	75 0a                	jne    c01016d1 <cons_getc+0x5f>
                cons.rpos = 0;
c01016c7:	c7 05 60 76 12 c0 00 	movl   $0x0,0xc0127660
c01016ce:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016d4:	89 04 24             	mov    %eax,(%esp)
c01016d7:	e8 71 f7 ff ff       	call   c0100e4d <__intr_restore>
    return c;
c01016dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016df:	c9                   	leave  
c01016e0:	c3                   	ret    

c01016e1 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01016e1:	55                   	push   %ebp
c01016e2:	89 e5                	mov    %esp,%ebp
c01016e4:	83 ec 14             	sub    $0x14,%esp
c01016e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01016ea:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01016ee:	90                   	nop
c01016ef:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f3:	83 c0 07             	add    $0x7,%eax
c01016f6:	0f b7 c0             	movzwl %ax,%eax
c01016f9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016fd:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101701:	89 c2                	mov    %eax,%edx
c0101703:	ec                   	in     (%dx),%al
c0101704:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101707:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010170b:	0f b6 c0             	movzbl %al,%eax
c010170e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101711:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101714:	25 80 00 00 00       	and    $0x80,%eax
c0101719:	85 c0                	test   %eax,%eax
c010171b:	75 d2                	jne    c01016ef <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c010171d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101721:	74 11                	je     c0101734 <ide_wait_ready+0x53>
c0101723:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101726:	83 e0 21             	and    $0x21,%eax
c0101729:	85 c0                	test   %eax,%eax
c010172b:	74 07                	je     c0101734 <ide_wait_ready+0x53>
        return -1;
c010172d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101732:	eb 05                	jmp    c0101739 <ide_wait_ready+0x58>
    }
    return 0;
c0101734:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101739:	c9                   	leave  
c010173a:	c3                   	ret    

c010173b <ide_init>:

void
ide_init(void) {
c010173b:	55                   	push   %ebp
c010173c:	89 e5                	mov    %esp,%ebp
c010173e:	57                   	push   %edi
c010173f:	53                   	push   %ebx
c0101740:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101746:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c010174c:	e9 d6 02 00 00       	jmp    c0101a27 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101751:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101755:	c1 e0 03             	shl    $0x3,%eax
c0101758:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010175f:	29 c2                	sub    %eax,%edx
c0101761:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c0101767:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c010176a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010176e:	66 d1 e8             	shr    %ax
c0101771:	0f b7 c0             	movzwl %ax,%eax
c0101774:	0f b7 04 85 70 a3 10 	movzwl -0x3fef5c90(,%eax,4),%eax
c010177b:	c0 
c010177c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101780:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101784:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010178b:	00 
c010178c:	89 04 24             	mov    %eax,(%esp)
c010178f:	e8 4d ff ff ff       	call   c01016e1 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0101794:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101798:	83 e0 01             	and    $0x1,%eax
c010179b:	c1 e0 04             	shl    $0x4,%eax
c010179e:	83 c8 e0             	or     $0xffffffe0,%eax
c01017a1:	0f b6 c0             	movzbl %al,%eax
c01017a4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017a8:	83 c2 06             	add    $0x6,%edx
c01017ab:	0f b7 d2             	movzwl %dx,%edx
c01017ae:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c01017b2:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017b5:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017b9:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017bd:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01017be:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01017c9:	00 
c01017ca:	89 04 24             	mov    %eax,(%esp)
c01017cd:	e8 0f ff ff ff       	call   c01016e1 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01017d2:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017d6:	83 c0 07             	add    $0x7,%eax
c01017d9:	0f b7 c0             	movzwl %ax,%eax
c01017dc:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01017e0:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01017e4:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01017e8:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01017ec:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01017ed:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01017f8:	00 
c01017f9:	89 04 24             	mov    %eax,(%esp)
c01017fc:	e8 e0 fe ff ff       	call   c01016e1 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0101801:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101805:	83 c0 07             	add    $0x7,%eax
c0101808:	0f b7 c0             	movzwl %ax,%eax
c010180b:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010180f:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0101813:	89 c2                	mov    %eax,%edx
c0101815:	ec                   	in     (%dx),%al
c0101816:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0101819:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010181d:	84 c0                	test   %al,%al
c010181f:	0f 84 f7 01 00 00    	je     c0101a1c <ide_init+0x2e1>
c0101825:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101829:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101830:	00 
c0101831:	89 04 24             	mov    %eax,(%esp)
c0101834:	e8 a8 fe ff ff       	call   c01016e1 <ide_wait_ready>
c0101839:	85 c0                	test   %eax,%eax
c010183b:	0f 85 db 01 00 00    	jne    c0101a1c <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101841:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101845:	c1 e0 03             	shl    $0x3,%eax
c0101848:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010184f:	29 c2                	sub    %eax,%edx
c0101851:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c0101857:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c010185a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010185e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101861:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101867:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010186a:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101871:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101874:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101877:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010187a:	89 cb                	mov    %ecx,%ebx
c010187c:	89 df                	mov    %ebx,%edi
c010187e:	89 c1                	mov    %eax,%ecx
c0101880:	fc                   	cld    
c0101881:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101883:	89 c8                	mov    %ecx,%eax
c0101885:	89 fb                	mov    %edi,%ebx
c0101887:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c010188a:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c010188d:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101893:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101896:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101899:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010189f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01018a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01018a5:	25 00 00 00 04       	and    $0x4000000,%eax
c01018aa:	85 c0                	test   %eax,%eax
c01018ac:	74 0e                	je     c01018bc <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01018ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018b1:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01018b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01018ba:	eb 09                	jmp    c01018c5 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01018bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018bf:	8b 40 78             	mov    0x78(%eax),%eax
c01018c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01018c5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018c9:	c1 e0 03             	shl    $0x3,%eax
c01018cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01018d3:	29 c2                	sub    %eax,%edx
c01018d5:	81 c2 80 76 12 c0    	add    $0xc0127680,%edx
c01018db:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01018de:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01018e1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018e5:	c1 e0 03             	shl    $0x3,%eax
c01018e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01018ef:	29 c2                	sub    %eax,%edx
c01018f1:	81 c2 80 76 12 c0    	add    $0xc0127680,%edx
c01018f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018fa:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01018fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101900:	83 c0 62             	add    $0x62,%eax
c0101903:	0f b7 00             	movzwl (%eax),%eax
c0101906:	0f b7 c0             	movzwl %ax,%eax
c0101909:	25 00 02 00 00       	and    $0x200,%eax
c010190e:	85 c0                	test   %eax,%eax
c0101910:	75 24                	jne    c0101936 <ide_init+0x1fb>
c0101912:	c7 44 24 0c 78 a3 10 	movl   $0xc010a378,0xc(%esp)
c0101919:	c0 
c010191a:	c7 44 24 08 bb a3 10 	movl   $0xc010a3bb,0x8(%esp)
c0101921:	c0 
c0101922:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101929:	00 
c010192a:	c7 04 24 d0 a3 10 c0 	movl   $0xc010a3d0,(%esp)
c0101931:	e8 bd f3 ff ff       	call   c0100cf3 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101936:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010193a:	c1 e0 03             	shl    $0x3,%eax
c010193d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101944:	29 c2                	sub    %eax,%edx
c0101946:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c010194c:	83 c0 0c             	add    $0xc,%eax
c010194f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101952:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101955:	83 c0 36             	add    $0x36,%eax
c0101958:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c010195b:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101962:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101969:	eb 34                	jmp    c010199f <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010196b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010196e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101971:	01 c2                	add    %eax,%edx
c0101973:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101976:	8d 48 01             	lea    0x1(%eax),%ecx
c0101979:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010197c:	01 c8                	add    %ecx,%eax
c010197e:	0f b6 00             	movzbl (%eax),%eax
c0101981:	88 02                	mov    %al,(%edx)
c0101983:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101986:	8d 50 01             	lea    0x1(%eax),%edx
c0101989:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010198c:	01 c2                	add    %eax,%edx
c010198e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101991:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101994:	01 c8                	add    %ecx,%eax
c0101996:	0f b6 00             	movzbl (%eax),%eax
c0101999:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c010199b:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010199f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019a2:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c01019a5:	72 c4                	jb     c010196b <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c01019a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01019ad:	01 d0                	add    %edx,%eax
c01019af:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01019b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019b5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01019b8:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01019bb:	85 c0                	test   %eax,%eax
c01019bd:	74 0f                	je     c01019ce <ide_init+0x293>
c01019bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01019c5:	01 d0                	add    %edx,%eax
c01019c7:	0f b6 00             	movzbl (%eax),%eax
c01019ca:	3c 20                	cmp    $0x20,%al
c01019cc:	74 d9                	je     c01019a7 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01019ce:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019d2:	c1 e0 03             	shl    $0x3,%eax
c01019d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019dc:	29 c2                	sub    %eax,%edx
c01019de:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c01019e4:	8d 48 0c             	lea    0xc(%eax),%ecx
c01019e7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019eb:	c1 e0 03             	shl    $0x3,%eax
c01019ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019f5:	29 c2                	sub    %eax,%edx
c01019f7:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c01019fd:	8b 50 08             	mov    0x8(%eax),%edx
c0101a00:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a04:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101a08:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a10:	c7 04 24 e2 a3 10 c0 	movl   $0xc010a3e2,(%esp)
c0101a17:	e8 43 e9 ff ff       	call   c010035f <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a1c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a20:	83 c0 01             	add    $0x1,%eax
c0101a23:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101a27:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101a2c:	0f 86 1f fd ff ff    	jbe    c0101751 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101a32:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101a39:	e8 7c 05 00 00       	call   c0101fba <pic_enable>
    pic_enable(IRQ_IDE2);
c0101a3e:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101a45:	e8 70 05 00 00       	call   c0101fba <pic_enable>
}
c0101a4a:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101a50:	5b                   	pop    %ebx
c0101a51:	5f                   	pop    %edi
c0101a52:	5d                   	pop    %ebp
c0101a53:	c3                   	ret    

c0101a54 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101a54:	55                   	push   %ebp
c0101a55:	89 e5                	mov    %esp,%ebp
c0101a57:	83 ec 04             	sub    $0x4,%esp
c0101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a5d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101a61:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101a66:	77 24                	ja     c0101a8c <ide_device_valid+0x38>
c0101a68:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101a6c:	c1 e0 03             	shl    $0x3,%eax
c0101a6f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a76:	29 c2                	sub    %eax,%edx
c0101a78:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c0101a7e:	0f b6 00             	movzbl (%eax),%eax
c0101a81:	84 c0                	test   %al,%al
c0101a83:	74 07                	je     c0101a8c <ide_device_valid+0x38>
c0101a85:	b8 01 00 00 00       	mov    $0x1,%eax
c0101a8a:	eb 05                	jmp    c0101a91 <ide_device_valid+0x3d>
c0101a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101a91:	c9                   	leave  
c0101a92:	c3                   	ret    

c0101a93 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101a93:	55                   	push   %ebp
c0101a94:	89 e5                	mov    %esp,%ebp
c0101a96:	83 ec 08             	sub    $0x8,%esp
c0101a99:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a9c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101aa0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101aa4:	89 04 24             	mov    %eax,(%esp)
c0101aa7:	e8 a8 ff ff ff       	call   c0101a54 <ide_device_valid>
c0101aac:	85 c0                	test   %eax,%eax
c0101aae:	74 1b                	je     c0101acb <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101ab0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101ab4:	c1 e0 03             	shl    $0x3,%eax
c0101ab7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101abe:	29 c2                	sub    %eax,%edx
c0101ac0:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c0101ac6:	8b 40 08             	mov    0x8(%eax),%eax
c0101ac9:	eb 05                	jmp    c0101ad0 <ide_device_size+0x3d>
    }
    return 0;
c0101acb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101ad0:	c9                   	leave  
c0101ad1:	c3                   	ret    

c0101ad2 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101ad2:	55                   	push   %ebp
c0101ad3:	89 e5                	mov    %esp,%ebp
c0101ad5:	57                   	push   %edi
c0101ad6:	53                   	push   %ebx
c0101ad7:	83 ec 50             	sub    $0x50,%esp
c0101ada:	8b 45 08             	mov    0x8(%ebp),%eax
c0101add:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101ae1:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101ae8:	77 24                	ja     c0101b0e <ide_read_secs+0x3c>
c0101aea:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101aef:	77 1d                	ja     c0101b0e <ide_read_secs+0x3c>
c0101af1:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101af5:	c1 e0 03             	shl    $0x3,%eax
c0101af8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101aff:	29 c2                	sub    %eax,%edx
c0101b01:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c0101b07:	0f b6 00             	movzbl (%eax),%eax
c0101b0a:	84 c0                	test   %al,%al
c0101b0c:	75 24                	jne    c0101b32 <ide_read_secs+0x60>
c0101b0e:	c7 44 24 0c 00 a4 10 	movl   $0xc010a400,0xc(%esp)
c0101b15:	c0 
c0101b16:	c7 44 24 08 bb a3 10 	movl   $0xc010a3bb,0x8(%esp)
c0101b1d:	c0 
c0101b1e:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101b25:	00 
c0101b26:	c7 04 24 d0 a3 10 c0 	movl   $0xc010a3d0,(%esp)
c0101b2d:	e8 c1 f1 ff ff       	call   c0100cf3 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101b32:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101b39:	77 0f                	ja     c0101b4a <ide_read_secs+0x78>
c0101b3b:	8b 45 14             	mov    0x14(%ebp),%eax
c0101b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101b41:	01 d0                	add    %edx,%eax
c0101b43:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101b48:	76 24                	jbe    c0101b6e <ide_read_secs+0x9c>
c0101b4a:	c7 44 24 0c 28 a4 10 	movl   $0xc010a428,0xc(%esp)
c0101b51:	c0 
c0101b52:	c7 44 24 08 bb a3 10 	movl   $0xc010a3bb,0x8(%esp)
c0101b59:	c0 
c0101b5a:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101b61:	00 
c0101b62:	c7 04 24 d0 a3 10 c0 	movl   $0xc010a3d0,(%esp)
c0101b69:	e8 85 f1 ff ff       	call   c0100cf3 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101b6e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b72:	66 d1 e8             	shr    %ax
c0101b75:	0f b7 c0             	movzwl %ax,%eax
c0101b78:	0f b7 04 85 70 a3 10 	movzwl -0x3fef5c90(,%eax,4),%eax
c0101b7f:	c0 
c0101b80:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101b84:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b88:	66 d1 e8             	shr    %ax
c0101b8b:	0f b7 c0             	movzwl %ax,%eax
c0101b8e:	0f b7 04 85 72 a3 10 	movzwl -0x3fef5c8e(,%eax,4),%eax
c0101b95:	c0 
c0101b96:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101b9a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101b9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ba5:	00 
c0101ba6:	89 04 24             	mov    %eax,(%esp)
c0101ba9:	e8 33 fb ff ff       	call   c01016e1 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101bae:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101bb2:	83 c0 02             	add    $0x2,%eax
c0101bb5:	0f b7 c0             	movzwl %ax,%eax
c0101bb8:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101bbc:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bc0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101bc4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101bc8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101bc9:	8b 45 14             	mov    0x14(%ebp),%eax
c0101bcc:	0f b6 c0             	movzbl %al,%eax
c0101bcf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bd3:	83 c2 02             	add    $0x2,%edx
c0101bd6:	0f b7 d2             	movzwl %dx,%edx
c0101bd9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101bdd:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101be0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101be4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101be8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101be9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bec:	0f b6 c0             	movzbl %al,%eax
c0101bef:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bf3:	83 c2 03             	add    $0x3,%edx
c0101bf6:	0f b7 d2             	movzwl %dx,%edx
c0101bf9:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101bfd:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101c00:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101c04:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101c08:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c0c:	c1 e8 08             	shr    $0x8,%eax
c0101c0f:	0f b6 c0             	movzbl %al,%eax
c0101c12:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c16:	83 c2 04             	add    $0x4,%edx
c0101c19:	0f b7 d2             	movzwl %dx,%edx
c0101c1c:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c20:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101c23:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101c27:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101c2b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c2f:	c1 e8 10             	shr    $0x10,%eax
c0101c32:	0f b6 c0             	movzbl %al,%eax
c0101c35:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c39:	83 c2 05             	add    $0x5,%edx
c0101c3c:	0f b7 d2             	movzwl %dx,%edx
c0101c3f:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c43:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101c46:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c4a:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c4e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101c4f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c53:	83 e0 01             	and    $0x1,%eax
c0101c56:	c1 e0 04             	shl    $0x4,%eax
c0101c59:	89 c2                	mov    %eax,%edx
c0101c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c5e:	c1 e8 18             	shr    $0x18,%eax
c0101c61:	83 e0 0f             	and    $0xf,%eax
c0101c64:	09 d0                	or     %edx,%eax
c0101c66:	83 c8 e0             	or     $0xffffffe0,%eax
c0101c69:	0f b6 c0             	movzbl %al,%eax
c0101c6c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c70:	83 c2 06             	add    $0x6,%edx
c0101c73:	0f b7 d2             	movzwl %dx,%edx
c0101c76:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c7a:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101c7d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c81:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c85:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101c86:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c8a:	83 c0 07             	add    $0x7,%eax
c0101c8d:	0f b7 c0             	movzwl %ax,%eax
c0101c90:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101c94:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101c98:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c9c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101ca0:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101ca1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101ca8:	eb 5a                	jmp    c0101d04 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101caa:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101cb5:	00 
c0101cb6:	89 04 24             	mov    %eax,(%esp)
c0101cb9:	e8 23 fa ff ff       	call   c01016e1 <ide_wait_ready>
c0101cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101cc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101cc5:	74 02                	je     c0101cc9 <ide_read_secs+0x1f7>
            goto out;
c0101cc7:	eb 41                	jmp    c0101d0a <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101cc9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ccd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101cd0:	8b 45 10             	mov    0x10(%ebp),%eax
c0101cd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101cd6:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101cdd:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101ce0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101ce3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101ce6:	89 cb                	mov    %ecx,%ebx
c0101ce8:	89 df                	mov    %ebx,%edi
c0101cea:	89 c1                	mov    %eax,%ecx
c0101cec:	fc                   	cld    
c0101ced:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101cef:	89 c8                	mov    %ecx,%eax
c0101cf1:	89 fb                	mov    %edi,%ebx
c0101cf3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101cf6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101cf9:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101cfd:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101d04:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d08:	75 a0                	jne    c0101caa <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d0d:	83 c4 50             	add    $0x50,%esp
c0101d10:	5b                   	pop    %ebx
c0101d11:	5f                   	pop    %edi
c0101d12:	5d                   	pop    %ebp
c0101d13:	c3                   	ret    

c0101d14 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d14:	55                   	push   %ebp
c0101d15:	89 e5                	mov    %esp,%ebp
c0101d17:	56                   	push   %esi
c0101d18:	53                   	push   %ebx
c0101d19:	83 ec 50             	sub    $0x50,%esp
c0101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d1f:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101d23:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101d2a:	77 24                	ja     c0101d50 <ide_write_secs+0x3c>
c0101d2c:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101d31:	77 1d                	ja     c0101d50 <ide_write_secs+0x3c>
c0101d33:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d37:	c1 e0 03             	shl    $0x3,%eax
c0101d3a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101d41:	29 c2                	sub    %eax,%edx
c0101d43:	8d 82 80 76 12 c0    	lea    -0x3fed8980(%edx),%eax
c0101d49:	0f b6 00             	movzbl (%eax),%eax
c0101d4c:	84 c0                	test   %al,%al
c0101d4e:	75 24                	jne    c0101d74 <ide_write_secs+0x60>
c0101d50:	c7 44 24 0c 00 a4 10 	movl   $0xc010a400,0xc(%esp)
c0101d57:	c0 
c0101d58:	c7 44 24 08 bb a3 10 	movl   $0xc010a3bb,0x8(%esp)
c0101d5f:	c0 
c0101d60:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101d67:	00 
c0101d68:	c7 04 24 d0 a3 10 c0 	movl   $0xc010a3d0,(%esp)
c0101d6f:	e8 7f ef ff ff       	call   c0100cf3 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101d74:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101d7b:	77 0f                	ja     c0101d8c <ide_write_secs+0x78>
c0101d7d:	8b 45 14             	mov    0x14(%ebp),%eax
c0101d80:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101d83:	01 d0                	add    %edx,%eax
c0101d85:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101d8a:	76 24                	jbe    c0101db0 <ide_write_secs+0x9c>
c0101d8c:	c7 44 24 0c 28 a4 10 	movl   $0xc010a428,0xc(%esp)
c0101d93:	c0 
c0101d94:	c7 44 24 08 bb a3 10 	movl   $0xc010a3bb,0x8(%esp)
c0101d9b:	c0 
c0101d9c:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101da3:	00 
c0101da4:	c7 04 24 d0 a3 10 c0 	movl   $0xc010a3d0,(%esp)
c0101dab:	e8 43 ef ff ff       	call   c0100cf3 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101db0:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101db4:	66 d1 e8             	shr    %ax
c0101db7:	0f b7 c0             	movzwl %ax,%eax
c0101dba:	0f b7 04 85 70 a3 10 	movzwl -0x3fef5c90(,%eax,4),%eax
c0101dc1:	c0 
c0101dc2:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101dc6:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101dca:	66 d1 e8             	shr    %ax
c0101dcd:	0f b7 c0             	movzwl %ax,%eax
c0101dd0:	0f b7 04 85 72 a3 10 	movzwl -0x3fef5c8e(,%eax,4),%eax
c0101dd7:	c0 
c0101dd8:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101ddc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101de0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101de7:	00 
c0101de8:	89 04 24             	mov    %eax,(%esp)
c0101deb:	e8 f1 f8 ff ff       	call   c01016e1 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101df0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101df4:	83 c0 02             	add    $0x2,%eax
c0101df7:	0f b7 c0             	movzwl %ax,%eax
c0101dfa:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101dfe:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e02:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101e06:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101e0a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101e0b:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e0e:	0f b6 c0             	movzbl %al,%eax
c0101e11:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e15:	83 c2 02             	add    $0x2,%edx
c0101e18:	0f b7 d2             	movzwl %dx,%edx
c0101e1b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101e1f:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101e22:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101e26:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101e2a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e2e:	0f b6 c0             	movzbl %al,%eax
c0101e31:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e35:	83 c2 03             	add    $0x3,%edx
c0101e38:	0f b7 d2             	movzwl %dx,%edx
c0101e3b:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101e3f:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101e42:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101e46:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101e4a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e4e:	c1 e8 08             	shr    $0x8,%eax
c0101e51:	0f b6 c0             	movzbl %al,%eax
c0101e54:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e58:	83 c2 04             	add    $0x4,%edx
c0101e5b:	0f b7 d2             	movzwl %dx,%edx
c0101e5e:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101e62:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101e65:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101e69:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101e6d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e71:	c1 e8 10             	shr    $0x10,%eax
c0101e74:	0f b6 c0             	movzbl %al,%eax
c0101e77:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e7b:	83 c2 05             	add    $0x5,%edx
c0101e7e:	0f b7 d2             	movzwl %dx,%edx
c0101e81:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101e85:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101e88:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101e8c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101e90:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101e91:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e95:	83 e0 01             	and    $0x1,%eax
c0101e98:	c1 e0 04             	shl    $0x4,%eax
c0101e9b:	89 c2                	mov    %eax,%edx
c0101e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ea0:	c1 e8 18             	shr    $0x18,%eax
c0101ea3:	83 e0 0f             	and    $0xf,%eax
c0101ea6:	09 d0                	or     %edx,%eax
c0101ea8:	83 c8 e0             	or     $0xffffffe0,%eax
c0101eab:	0f b6 c0             	movzbl %al,%eax
c0101eae:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101eb2:	83 c2 06             	add    $0x6,%edx
c0101eb5:	0f b7 d2             	movzwl %dx,%edx
c0101eb8:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101ebc:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101ebf:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101ec3:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101ec7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101ec8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ecc:	83 c0 07             	add    $0x7,%eax
c0101ecf:	0f b7 c0             	movzwl %ax,%eax
c0101ed2:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101ed6:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101eda:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101ede:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101ee2:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101ee3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101eea:	eb 5a                	jmp    c0101f46 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101eec:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ef0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101ef7:	00 
c0101ef8:	89 04 24             	mov    %eax,(%esp)
c0101efb:	e8 e1 f7 ff ff       	call   c01016e1 <ide_wait_ready>
c0101f00:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101f03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f07:	74 02                	je     c0101f0b <ide_write_secs+0x1f7>
            goto out;
c0101f09:	eb 41                	jmp    c0101f4c <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f0b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f0f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f12:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f15:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f18:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101f1f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f22:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101f25:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101f28:	89 cb                	mov    %ecx,%ebx
c0101f2a:	89 de                	mov    %ebx,%esi
c0101f2c:	89 c1                	mov    %eax,%ecx
c0101f2e:	fc                   	cld    
c0101f2f:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101f31:	89 c8                	mov    %ecx,%eax
c0101f33:	89 f3                	mov    %esi,%ebx
c0101f35:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101f38:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f3b:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101f3f:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101f46:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101f4a:	75 a0                	jne    c0101eec <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f4f:	83 c4 50             	add    $0x50,%esp
c0101f52:	5b                   	pop    %ebx
c0101f53:	5e                   	pop    %esi
c0101f54:	5d                   	pop    %ebp
c0101f55:	c3                   	ret    

c0101f56 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101f56:	55                   	push   %ebp
c0101f57:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101f59:	fb                   	sti    
    sti();
}
c0101f5a:	5d                   	pop    %ebp
c0101f5b:	c3                   	ret    

c0101f5c <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101f5c:	55                   	push   %ebp
c0101f5d:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0101f5f:	fa                   	cli    
    cli();
}
c0101f60:	5d                   	pop    %ebp
c0101f61:	c3                   	ret    

c0101f62 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f62:	55                   	push   %ebp
c0101f63:	89 e5                	mov    %esp,%ebp
c0101f65:	83 ec 14             	sub    $0x14,%esp
c0101f68:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f6b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f6f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f73:	66 a3 50 45 12 c0    	mov    %ax,0xc0124550
    if (did_init) {
c0101f79:	a1 60 77 12 c0       	mov    0xc0127760,%eax
c0101f7e:	85 c0                	test   %eax,%eax
c0101f80:	74 36                	je     c0101fb8 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f82:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f86:	0f b6 c0             	movzbl %al,%eax
c0101f89:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f8f:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f92:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f96:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f9a:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f9b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f9f:	66 c1 e8 08          	shr    $0x8,%ax
c0101fa3:	0f b6 c0             	movzbl %al,%eax
c0101fa6:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101fac:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101faf:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101fb3:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101fb7:	ee                   	out    %al,(%dx)
    }
}
c0101fb8:	c9                   	leave  
c0101fb9:	c3                   	ret    

c0101fba <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101fba:	55                   	push   %ebp
c0101fbb:	89 e5                	mov    %esp,%ebp
c0101fbd:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101fc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fc3:	ba 01 00 00 00       	mov    $0x1,%edx
c0101fc8:	89 c1                	mov    %eax,%ecx
c0101fca:	d3 e2                	shl    %cl,%edx
c0101fcc:	89 d0                	mov    %edx,%eax
c0101fce:	f7 d0                	not    %eax
c0101fd0:	89 c2                	mov    %eax,%edx
c0101fd2:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0101fd9:	21 d0                	and    %edx,%eax
c0101fdb:	0f b7 c0             	movzwl %ax,%eax
c0101fde:	89 04 24             	mov    %eax,(%esp)
c0101fe1:	e8 7c ff ff ff       	call   c0101f62 <pic_setmask>
}
c0101fe6:	c9                   	leave  
c0101fe7:	c3                   	ret    

c0101fe8 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fe8:	55                   	push   %ebp
c0101fe9:	89 e5                	mov    %esp,%ebp
c0101feb:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101fee:	c7 05 60 77 12 c0 01 	movl   $0x1,0xc0127760
c0101ff5:	00 00 00 
c0101ff8:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101ffe:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0102002:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102006:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010200a:	ee                   	out    %al,(%dx)
c010200b:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102011:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102015:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102019:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010201d:	ee                   	out    %al,(%dx)
c010201e:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102024:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102028:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010202c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102030:	ee                   	out    %al,(%dx)
c0102031:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102037:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c010203b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010203f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102043:	ee                   	out    %al,(%dx)
c0102044:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c010204a:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010204e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102052:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102056:	ee                   	out    %al,(%dx)
c0102057:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010205d:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102061:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102065:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102069:	ee                   	out    %al,(%dx)
c010206a:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102070:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102074:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102078:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010207c:	ee                   	out    %al,(%dx)
c010207d:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102083:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102087:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010208b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010208f:	ee                   	out    %al,(%dx)
c0102090:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0102096:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010209a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010209e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01020a2:	ee                   	out    %al,(%dx)
c01020a3:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c01020a9:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01020ad:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020b1:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020b5:	ee                   	out    %al,(%dx)
c01020b6:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01020bc:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01020c0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020c4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020c8:	ee                   	out    %al,(%dx)
c01020c9:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020cf:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01020d3:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020d7:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020db:	ee                   	out    %al,(%dx)
c01020dc:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01020e2:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01020e6:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020ea:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020ee:	ee                   	out    %al,(%dx)
c01020ef:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01020f5:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01020f9:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01020fd:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102101:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102102:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0102109:	66 83 f8 ff          	cmp    $0xffff,%ax
c010210d:	74 12                	je     c0102121 <pic_init+0x139>
        pic_setmask(irq_mask);
c010210f:	0f b7 05 50 45 12 c0 	movzwl 0xc0124550,%eax
c0102116:	0f b7 c0             	movzwl %ax,%eax
c0102119:	89 04 24             	mov    %eax,(%esp)
c010211c:	e8 41 fe ff ff       	call   c0101f62 <pic_setmask>
    }
}
c0102121:	c9                   	leave  
c0102122:	c3                   	ret    

c0102123 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102123:	55                   	push   %ebp
c0102124:	89 e5                	mov    %esp,%ebp
c0102126:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102129:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102130:	00 
c0102131:	c7 04 24 80 a4 10 c0 	movl   $0xc010a480,(%esp)
c0102138:	e8 22 e2 ff ff       	call   c010035f <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010213d:	c9                   	leave  
c010213e:	c3                   	ret    

c010213f <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010213f:	55                   	push   %ebp
c0102140:	89 e5                	mov    %esp,%ebp
c0102142:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c0102145:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010214c:	e9 c3 00 00 00       	jmp    c0102214 <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102151:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102154:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c010215b:	89 c2                	mov    %eax,%edx
c010215d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102160:	66 89 14 c5 80 77 12 	mov    %dx,-0x3fed8880(,%eax,8)
c0102167:	c0 
c0102168:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010216b:	66 c7 04 c5 82 77 12 	movw   $0x8,-0x3fed887e(,%eax,8)
c0102172:	c0 08 00 
c0102175:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102178:	0f b6 14 c5 84 77 12 	movzbl -0x3fed887c(,%eax,8),%edx
c010217f:	c0 
c0102180:	83 e2 e0             	and    $0xffffffe0,%edx
c0102183:	88 14 c5 84 77 12 c0 	mov    %dl,-0x3fed887c(,%eax,8)
c010218a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010218d:	0f b6 14 c5 84 77 12 	movzbl -0x3fed887c(,%eax,8),%edx
c0102194:	c0 
c0102195:	83 e2 1f             	and    $0x1f,%edx
c0102198:	88 14 c5 84 77 12 c0 	mov    %dl,-0x3fed887c(,%eax,8)
c010219f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021a2:	0f b6 14 c5 85 77 12 	movzbl -0x3fed887b(,%eax,8),%edx
c01021a9:	c0 
c01021aa:	83 e2 f0             	and    $0xfffffff0,%edx
c01021ad:	83 ca 0e             	or     $0xe,%edx
c01021b0:	88 14 c5 85 77 12 c0 	mov    %dl,-0x3fed887b(,%eax,8)
c01021b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ba:	0f b6 14 c5 85 77 12 	movzbl -0x3fed887b(,%eax,8),%edx
c01021c1:	c0 
c01021c2:	83 e2 ef             	and    $0xffffffef,%edx
c01021c5:	88 14 c5 85 77 12 c0 	mov    %dl,-0x3fed887b(,%eax,8)
c01021cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021cf:	0f b6 14 c5 85 77 12 	movzbl -0x3fed887b(,%eax,8),%edx
c01021d6:	c0 
c01021d7:	83 e2 9f             	and    $0xffffff9f,%edx
c01021da:	88 14 c5 85 77 12 c0 	mov    %dl,-0x3fed887b(,%eax,8)
c01021e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021e4:	0f b6 14 c5 85 77 12 	movzbl -0x3fed887b(,%eax,8),%edx
c01021eb:	c0 
c01021ec:	83 ca 80             	or     $0xffffff80,%edx
c01021ef:	88 14 c5 85 77 12 c0 	mov    %dl,-0x3fed887b(,%eax,8)
c01021f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021f9:	8b 04 85 e0 45 12 c0 	mov    -0x3fedba20(,%eax,4),%eax
c0102200:	c1 e8 10             	shr    $0x10,%eax
c0102203:	89 c2                	mov    %eax,%edx
c0102205:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102208:	66 89 14 c5 86 77 12 	mov    %dx,-0x3fed887a(,%eax,8)
c010220f:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c0102210:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102214:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102217:	3d ff 00 00 00       	cmp    $0xff,%eax
c010221c:	0f 86 2f ff ff ff    	jbe    c0102151 <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
	}
	//SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], 3);
c0102222:	a1 c4 47 12 c0       	mov    0xc01247c4,%eax
c0102227:	66 a3 48 7b 12 c0    	mov    %ax,0xc0127b48
c010222d:	66 c7 05 4a 7b 12 c0 	movw   $0x8,0xc0127b4a
c0102234:	08 00 
c0102236:	0f b6 05 4c 7b 12 c0 	movzbl 0xc0127b4c,%eax
c010223d:	83 e0 e0             	and    $0xffffffe0,%eax
c0102240:	a2 4c 7b 12 c0       	mov    %al,0xc0127b4c
c0102245:	0f b6 05 4c 7b 12 c0 	movzbl 0xc0127b4c,%eax
c010224c:	83 e0 1f             	and    $0x1f,%eax
c010224f:	a2 4c 7b 12 c0       	mov    %al,0xc0127b4c
c0102254:	0f b6 05 4d 7b 12 c0 	movzbl 0xc0127b4d,%eax
c010225b:	83 c8 0f             	or     $0xf,%eax
c010225e:	a2 4d 7b 12 c0       	mov    %al,0xc0127b4d
c0102263:	0f b6 05 4d 7b 12 c0 	movzbl 0xc0127b4d,%eax
c010226a:	83 e0 ef             	and    $0xffffffef,%eax
c010226d:	a2 4d 7b 12 c0       	mov    %al,0xc0127b4d
c0102272:	0f b6 05 4d 7b 12 c0 	movzbl 0xc0127b4d,%eax
c0102279:	83 c8 60             	or     $0x60,%eax
c010227c:	a2 4d 7b 12 c0       	mov    %al,0xc0127b4d
c0102281:	0f b6 05 4d 7b 12 c0 	movzbl 0xc0127b4d,%eax
c0102288:	83 c8 80             	or     $0xffffff80,%eax
c010228b:	a2 4d 7b 12 c0       	mov    %al,0xc0127b4d
c0102290:	a1 c4 47 12 c0       	mov    0xc01247c4,%eax
c0102295:	c1 e8 10             	shr    $0x10,%eax
c0102298:	66 a3 4e 7b 12 c0    	mov    %ax,0xc0127b4e
c010229e:	c7 45 f8 60 45 12 c0 	movl   $0xc0124560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01022a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01022a8:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
c01022ab:	c9                   	leave  
c01022ac:	c3                   	ret    

c01022ad <trapname>:

static const char *
trapname(int trapno) {
c01022ad:	55                   	push   %ebp
c01022ae:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01022b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022b3:	83 f8 13             	cmp    $0x13,%eax
c01022b6:	77 0c                	ja     c01022c4 <trapname+0x17>
        return excnames[trapno];
c01022b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022bb:	8b 04 85 40 a8 10 c0 	mov    -0x3fef57c0(,%eax,4),%eax
c01022c2:	eb 18                	jmp    c01022dc <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01022c4:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01022c8:	7e 0d                	jle    c01022d7 <trapname+0x2a>
c01022ca:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01022ce:	7f 07                	jg     c01022d7 <trapname+0x2a>
        return "Hardware Interrupt";
c01022d0:	b8 8a a4 10 c0       	mov    $0xc010a48a,%eax
c01022d5:	eb 05                	jmp    c01022dc <trapname+0x2f>
    }
    return "(unknown trap)";
c01022d7:	b8 9d a4 10 c0       	mov    $0xc010a49d,%eax
}
c01022dc:	5d                   	pop    %ebp
c01022dd:	c3                   	ret    

c01022de <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01022de:	55                   	push   %ebp
c01022df:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01022e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022e8:	66 83 f8 08          	cmp    $0x8,%ax
c01022ec:	0f 94 c0             	sete   %al
c01022ef:	0f b6 c0             	movzbl %al,%eax
}
c01022f2:	5d                   	pop    %ebp
c01022f3:	c3                   	ret    

c01022f4 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01022f4:	55                   	push   %ebp
c01022f5:	89 e5                	mov    %esp,%ebp
c01022f7:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01022fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01022fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102301:	c7 04 24 de a4 10 c0 	movl   $0xc010a4de,(%esp)
c0102308:	e8 52 e0 ff ff       	call   c010035f <cprintf>
    print_regs(&tf->tf_regs);
c010230d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102310:	89 04 24             	mov    %eax,(%esp)
c0102313:	e8 a1 01 00 00       	call   c01024b9 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102318:	8b 45 08             	mov    0x8(%ebp),%eax
c010231b:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010231f:	0f b7 c0             	movzwl %ax,%eax
c0102322:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102326:	c7 04 24 ef a4 10 c0 	movl   $0xc010a4ef,(%esp)
c010232d:	e8 2d e0 ff ff       	call   c010035f <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102332:	8b 45 08             	mov    0x8(%ebp),%eax
c0102335:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102339:	0f b7 c0             	movzwl %ax,%eax
c010233c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102340:	c7 04 24 02 a5 10 c0 	movl   $0xc010a502,(%esp)
c0102347:	e8 13 e0 ff ff       	call   c010035f <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010234c:	8b 45 08             	mov    0x8(%ebp),%eax
c010234f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102353:	0f b7 c0             	movzwl %ax,%eax
c0102356:	89 44 24 04          	mov    %eax,0x4(%esp)
c010235a:	c7 04 24 15 a5 10 c0 	movl   $0xc010a515,(%esp)
c0102361:	e8 f9 df ff ff       	call   c010035f <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102366:	8b 45 08             	mov    0x8(%ebp),%eax
c0102369:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010236d:	0f b7 c0             	movzwl %ax,%eax
c0102370:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102374:	c7 04 24 28 a5 10 c0 	movl   $0xc010a528,(%esp)
c010237b:	e8 df df ff ff       	call   c010035f <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102380:	8b 45 08             	mov    0x8(%ebp),%eax
c0102383:	8b 40 30             	mov    0x30(%eax),%eax
c0102386:	89 04 24             	mov    %eax,(%esp)
c0102389:	e8 1f ff ff ff       	call   c01022ad <trapname>
c010238e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102391:	8b 52 30             	mov    0x30(%edx),%edx
c0102394:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102398:	89 54 24 04          	mov    %edx,0x4(%esp)
c010239c:	c7 04 24 3b a5 10 c0 	movl   $0xc010a53b,(%esp)
c01023a3:	e8 b7 df ff ff       	call   c010035f <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01023a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ab:	8b 40 34             	mov    0x34(%eax),%eax
c01023ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023b2:	c7 04 24 4d a5 10 c0 	movl   $0xc010a54d,(%esp)
c01023b9:	e8 a1 df ff ff       	call   c010035f <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01023be:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c1:	8b 40 38             	mov    0x38(%eax),%eax
c01023c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023c8:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01023cf:	e8 8b df ff ff       	call   c010035f <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01023d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023db:	0f b7 c0             	movzwl %ax,%eax
c01023de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023e2:	c7 04 24 6b a5 10 c0 	movl   $0xc010a56b,(%esp)
c01023e9:	e8 71 df ff ff       	call   c010035f <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01023ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f1:	8b 40 40             	mov    0x40(%eax),%eax
c01023f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023f8:	c7 04 24 7e a5 10 c0 	movl   $0xc010a57e,(%esp)
c01023ff:	e8 5b df ff ff       	call   c010035f <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010240b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102412:	eb 3e                	jmp    c0102452 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102414:	8b 45 08             	mov    0x8(%ebp),%eax
c0102417:	8b 50 40             	mov    0x40(%eax),%edx
c010241a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010241d:	21 d0                	and    %edx,%eax
c010241f:	85 c0                	test   %eax,%eax
c0102421:	74 28                	je     c010244b <print_trapframe+0x157>
c0102423:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102426:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c010242d:	85 c0                	test   %eax,%eax
c010242f:	74 1a                	je     c010244b <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0102431:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102434:	8b 04 85 80 45 12 c0 	mov    -0x3fedba80(,%eax,4),%eax
c010243b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010243f:	c7 04 24 8d a5 10 c0 	movl   $0xc010a58d,(%esp)
c0102446:	e8 14 df ff ff       	call   c010035f <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010244b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010244f:	d1 65 f0             	shll   -0x10(%ebp)
c0102452:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102455:	83 f8 17             	cmp    $0x17,%eax
c0102458:	76 ba                	jbe    c0102414 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010245a:	8b 45 08             	mov    0x8(%ebp),%eax
c010245d:	8b 40 40             	mov    0x40(%eax),%eax
c0102460:	25 00 30 00 00       	and    $0x3000,%eax
c0102465:	c1 e8 0c             	shr    $0xc,%eax
c0102468:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246c:	c7 04 24 91 a5 10 c0 	movl   $0xc010a591,(%esp)
c0102473:	e8 e7 de ff ff       	call   c010035f <cprintf>

    if (!trap_in_kernel(tf)) {
c0102478:	8b 45 08             	mov    0x8(%ebp),%eax
c010247b:	89 04 24             	mov    %eax,(%esp)
c010247e:	e8 5b fe ff ff       	call   c01022de <trap_in_kernel>
c0102483:	85 c0                	test   %eax,%eax
c0102485:	75 30                	jne    c01024b7 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102487:	8b 45 08             	mov    0x8(%ebp),%eax
c010248a:	8b 40 44             	mov    0x44(%eax),%eax
c010248d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102491:	c7 04 24 9a a5 10 c0 	movl   $0xc010a59a,(%esp)
c0102498:	e8 c2 de ff ff       	call   c010035f <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010249d:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a0:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01024a4:	0f b7 c0             	movzwl %ax,%eax
c01024a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ab:	c7 04 24 a9 a5 10 c0 	movl   $0xc010a5a9,(%esp)
c01024b2:	e8 a8 de ff ff       	call   c010035f <cprintf>
    }
}
c01024b7:	c9                   	leave  
c01024b8:	c3                   	ret    

c01024b9 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01024b9:	55                   	push   %ebp
c01024ba:	89 e5                	mov    %esp,%ebp
c01024bc:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01024bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c2:	8b 00                	mov    (%eax),%eax
c01024c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c8:	c7 04 24 bc a5 10 c0 	movl   $0xc010a5bc,(%esp)
c01024cf:	e8 8b de ff ff       	call   c010035f <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01024d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d7:	8b 40 04             	mov    0x4(%eax),%eax
c01024da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024de:	c7 04 24 cb a5 10 c0 	movl   $0xc010a5cb,(%esp)
c01024e5:	e8 75 de ff ff       	call   c010035f <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01024ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ed:	8b 40 08             	mov    0x8(%eax),%eax
c01024f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f4:	c7 04 24 da a5 10 c0 	movl   $0xc010a5da,(%esp)
c01024fb:	e8 5f de ff ff       	call   c010035f <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102500:	8b 45 08             	mov    0x8(%ebp),%eax
c0102503:	8b 40 0c             	mov    0xc(%eax),%eax
c0102506:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250a:	c7 04 24 e9 a5 10 c0 	movl   $0xc010a5e9,(%esp)
c0102511:	e8 49 de ff ff       	call   c010035f <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102516:	8b 45 08             	mov    0x8(%ebp),%eax
c0102519:	8b 40 10             	mov    0x10(%eax),%eax
c010251c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102520:	c7 04 24 f8 a5 10 c0 	movl   $0xc010a5f8,(%esp)
c0102527:	e8 33 de ff ff       	call   c010035f <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010252c:	8b 45 08             	mov    0x8(%ebp),%eax
c010252f:	8b 40 14             	mov    0x14(%eax),%eax
c0102532:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102536:	c7 04 24 07 a6 10 c0 	movl   $0xc010a607,(%esp)
c010253d:	e8 1d de ff ff       	call   c010035f <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102542:	8b 45 08             	mov    0x8(%ebp),%eax
c0102545:	8b 40 18             	mov    0x18(%eax),%eax
c0102548:	89 44 24 04          	mov    %eax,0x4(%esp)
c010254c:	c7 04 24 16 a6 10 c0 	movl   $0xc010a616,(%esp)
c0102553:	e8 07 de ff ff       	call   c010035f <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102558:	8b 45 08             	mov    0x8(%ebp),%eax
c010255b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010255e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102562:	c7 04 24 25 a6 10 c0 	movl   $0xc010a625,(%esp)
c0102569:	e8 f1 dd ff ff       	call   c010035f <cprintf>
}
c010256e:	c9                   	leave  
c010256f:	c3                   	ret    

c0102570 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102570:	55                   	push   %ebp
c0102571:	89 e5                	mov    %esp,%ebp
c0102573:	53                   	push   %ebx
c0102574:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102577:	8b 45 08             	mov    0x8(%ebp),%eax
c010257a:	8b 40 34             	mov    0x34(%eax),%eax
c010257d:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102580:	85 c0                	test   %eax,%eax
c0102582:	74 07                	je     c010258b <print_pgfault+0x1b>
c0102584:	b9 34 a6 10 c0       	mov    $0xc010a634,%ecx
c0102589:	eb 05                	jmp    c0102590 <print_pgfault+0x20>
c010258b:	b9 45 a6 10 c0       	mov    $0xc010a645,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0102590:	8b 45 08             	mov    0x8(%ebp),%eax
c0102593:	8b 40 34             	mov    0x34(%eax),%eax
c0102596:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102599:	85 c0                	test   %eax,%eax
c010259b:	74 07                	je     c01025a4 <print_pgfault+0x34>
c010259d:	ba 57 00 00 00       	mov    $0x57,%edx
c01025a2:	eb 05                	jmp    c01025a9 <print_pgfault+0x39>
c01025a4:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01025a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ac:	8b 40 34             	mov    0x34(%eax),%eax
c01025af:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025b2:	85 c0                	test   %eax,%eax
c01025b4:	74 07                	je     c01025bd <print_pgfault+0x4d>
c01025b6:	b8 55 00 00 00       	mov    $0x55,%eax
c01025bb:	eb 05                	jmp    c01025c2 <print_pgfault+0x52>
c01025bd:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025c2:	0f 20 d3             	mov    %cr2,%ebx
c01025c5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01025c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01025cb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01025cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01025d3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01025d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01025db:	c7 04 24 54 a6 10 c0 	movl   $0xc010a654,(%esp)
c01025e2:	e8 78 dd ff ff       	call   c010035f <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01025e7:	83 c4 34             	add    $0x34,%esp
c01025ea:	5b                   	pop    %ebx
c01025eb:	5d                   	pop    %ebp
c01025ec:	c3                   	ret    

c01025ed <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01025ed:	55                   	push   %ebp
c01025ee:	89 e5                	mov    %esp,%ebp
c01025f0:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01025f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f6:	89 04 24             	mov    %eax,(%esp)
c01025f9:	e8 72 ff ff ff       	call   c0102570 <print_pgfault>
    if (check_mm_struct != NULL) {
c01025fe:	a1 cc a1 12 c0       	mov    0xc012a1cc,%eax
c0102603:	85 c0                	test   %eax,%eax
c0102605:	74 28                	je     c010262f <pgfault_handler+0x42>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102607:	0f 20 d0             	mov    %cr2,%eax
c010260a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102610:	89 c1                	mov    %eax,%ecx
c0102612:	8b 45 08             	mov    0x8(%ebp),%eax
c0102615:	8b 50 34             	mov    0x34(%eax),%edx
c0102618:	a1 cc a1 12 c0       	mov    0xc012a1cc,%eax
c010261d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102621:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102625:	89 04 24             	mov    %eax,(%esp)
c0102628:	e8 a9 5d 00 00       	call   c01083d6 <do_pgfault>
c010262d:	eb 1c                	jmp    c010264b <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c010262f:	c7 44 24 08 77 a6 10 	movl   $0xc010a677,0x8(%esp)
c0102636:	c0 
c0102637:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c010263e:	00 
c010263f:	c7 04 24 8e a6 10 c0 	movl   $0xc010a68e,(%esp)
c0102646:	e8 a8 e6 ff ff       	call   c0100cf3 <__panic>
}
c010264b:	c9                   	leave  
c010264c:	c3                   	ret    

c010264d <trap_dispatch>:

/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

static void
trap_dispatch(struct trapframe *tf) {
c010264d:	55                   	push   %ebp
c010264e:	89 e5                	mov    %esp,%ebp
c0102650:	57                   	push   %edi
c0102651:	56                   	push   %esi
c0102652:	53                   	push   %ebx
c0102653:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102656:	8b 45 08             	mov    0x8(%ebp),%eax
c0102659:	8b 40 30             	mov    0x30(%eax),%eax
c010265c:	83 f8 24             	cmp    $0x24,%eax
c010265f:	0f 84 d0 00 00 00    	je     c0102735 <trap_dispatch+0xe8>
c0102665:	83 f8 24             	cmp    $0x24,%eax
c0102668:	77 1c                	ja     c0102686 <trap_dispatch+0x39>
c010266a:	83 f8 20             	cmp    $0x20,%eax
c010266d:	0f 84 87 00 00 00    	je     c01026fa <trap_dispatch+0xad>
c0102673:	83 f8 21             	cmp    $0x21,%eax
c0102676:	0f 84 e2 00 00 00    	je     c010275e <trap_dispatch+0x111>
c010267c:	83 f8 0e             	cmp    $0xe,%eax
c010267f:	74 32                	je     c01026b3 <trap_dispatch+0x66>
c0102681:	e9 f9 01 00 00       	jmp    c010287f <trap_dispatch+0x232>
c0102686:	83 f8 78             	cmp    $0x78,%eax
c0102689:	0f 84 f8 00 00 00    	je     c0102787 <trap_dispatch+0x13a>
c010268f:	83 f8 78             	cmp    $0x78,%eax
c0102692:	77 11                	ja     c01026a5 <trap_dispatch+0x58>
c0102694:	83 e8 2e             	sub    $0x2e,%eax
c0102697:	83 f8 01             	cmp    $0x1,%eax
c010269a:	0f 87 df 01 00 00    	ja     c010287f <trap_dispatch+0x232>
	tf->tf_es = KERNEL_DS;
        break;*/
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01026a0:	e9 12 02 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
trap_dispatch(struct trapframe *tf) {
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01026a5:	83 f8 79             	cmp    $0x79,%eax
c01026a8:	0f 84 58 01 00 00    	je     c0102806 <trap_dispatch+0x1b9>
c01026ae:	e9 cc 01 00 00       	jmp    c010287f <trap_dispatch+0x232>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01026b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b6:	89 04 24             	mov    %eax,(%esp)
c01026b9:	e8 2f ff ff ff       	call   c01025ed <pgfault_handler>
c01026be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01026c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01026c5:	74 2e                	je     c01026f5 <trap_dispatch+0xa8>
            print_trapframe(tf);
c01026c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01026ca:	89 04 24             	mov    %eax,(%esp)
c01026cd:	e8 22 fc ff ff       	call   c01022f4 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c01026d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01026d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01026d9:	c7 44 24 08 9f a6 10 	movl   $0xc010a69f,0x8(%esp)
c01026e0:	c0 
c01026e1:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c01026e8:	00 
c01026e9:	c7 04 24 8e a6 10 c0 	movl   $0xc010a68e,(%esp)
c01026f0:	e8 fe e5 ff ff       	call   c0100cf3 <__panic>
        }
        break;
c01026f5:	e9 bd 01 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks++;
c01026fa:	a1 74 a0 12 c0       	mov    0xc012a074,%eax
c01026ff:	83 c0 01             	add    $0x1,%eax
c0102702:	a3 74 a0 12 c0       	mov    %eax,0xc012a074
	if(ticks % TICK_NUM == 0){
c0102707:	8b 0d 74 a0 12 c0    	mov    0xc012a074,%ecx
c010270d:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102712:	89 c8                	mov    %ecx,%eax
c0102714:	f7 e2                	mul    %edx
c0102716:	89 d0                	mov    %edx,%eax
c0102718:	c1 e8 05             	shr    $0x5,%eax
c010271b:	6b c0 64             	imul   $0x64,%eax,%eax
c010271e:	29 c1                	sub    %eax,%ecx
c0102720:	89 c8                	mov    %ecx,%eax
c0102722:	85 c0                	test   %eax,%eax
c0102724:	75 0a                	jne    c0102730 <trap_dispatch+0xe3>
		print_ticks();	
c0102726:	e8 f8 f9 ff ff       	call   c0102123 <print_ticks>
	}
        break;
c010272b:	e9 87 01 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
c0102730:	e9 82 01 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102735:	e8 38 ef ff ff       	call   c0101672 <cons_getc>
c010273a:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010273d:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0102741:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c0102745:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102749:	89 44 24 04          	mov    %eax,0x4(%esp)
c010274d:	c7 04 24 ba a6 10 c0 	movl   $0xc010a6ba,(%esp)
c0102754:	e8 06 dc ff ff       	call   c010035f <cprintf>
        break;
c0102759:	e9 59 01 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c010275e:	e8 0f ef ff ff       	call   c0101672 <cons_getc>
c0102763:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102766:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c010276a:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c010276e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102772:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102776:	c7 04 24 cc a6 10 c0 	movl   $0xc010a6cc,(%esp)
c010277d:	e8 dd db ff ff       	call   c010035f <cprintf>
        break;
c0102782:	e9 30 01 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
	if (tf->tf_cs != USER_CS) {
c0102787:	8b 45 08             	mov    0x8(%ebp),%eax
c010278a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010278e:	66 83 f8 1b          	cmp    $0x1b,%ax
c0102792:	74 6d                	je     c0102801 <trap_dispatch+0x1b4>
            switchk2u = *tf;
c0102794:	8b 45 08             	mov    0x8(%ebp),%eax
c0102797:	ba 80 a0 12 c0       	mov    $0xc012a080,%edx
c010279c:	89 c3                	mov    %eax,%ebx
c010279e:	b8 13 00 00 00       	mov    $0x13,%eax
c01027a3:	89 d7                	mov    %edx,%edi
c01027a5:	89 de                	mov    %ebx,%esi
c01027a7:	89 c1                	mov    %eax,%ecx
c01027a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
c01027ab:	66 c7 05 bc a0 12 c0 	movw   $0x1b,0xc012a0bc
c01027b2:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c01027b4:	66 c7 05 c8 a0 12 c0 	movw   $0x23,0xc012a0c8
c01027bb:	23 00 
c01027bd:	0f b7 05 c8 a0 12 c0 	movzwl 0xc012a0c8,%eax
c01027c4:	66 a3 a8 a0 12 c0    	mov    %ax,0xc012a0a8
c01027ca:	0f b7 05 a8 a0 12 c0 	movzwl 0xc012a0a8,%eax
c01027d1:	66 a3 ac a0 12 c0    	mov    %ax,0xc012a0ac
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c01027d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01027da:	83 c0 44             	add    $0x44,%eax
c01027dd:	a3 c4 a0 12 c0       	mov    %eax,0xc012a0c4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c01027e2:	a1 c0 a0 12 c0       	mov    0xc012a0c0,%eax
c01027e7:	80 cc 30             	or     $0x30,%ah
c01027ea:	a3 c0 a0 12 c0       	mov    %eax,0xc012a0c0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c01027ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01027f2:	8d 50 fc             	lea    -0x4(%eax),%edx
c01027f5:	b8 80 a0 12 c0       	mov    $0xc012a080,%eax
c01027fa:	89 02                	mov    %eax,(%edx)
        }
        break;
c01027fc:	e9 b6 00 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
c0102801:	e9 b1 00 00 00       	jmp    c01028b7 <trap_dispatch+0x26a>
	tf->tf_ds = USER_DS;
	tf->tf_es = USER_DS;
	tf->tf_ss = USER_DS;
	break;*/
    case T_SWITCH_TOK:
	if (tf->tf_cs != KERNEL_CS) {
c0102806:	8b 45 08             	mov    0x8(%ebp),%eax
c0102809:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010280d:	66 83 f8 08          	cmp    $0x8,%ax
c0102811:	74 6a                	je     c010287d <trap_dispatch+0x230>
            tf->tf_cs = KERNEL_CS;
c0102813:	8b 45 08             	mov    0x8(%ebp),%eax
c0102816:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c010281c:	8b 45 08             	mov    0x8(%ebp),%eax
c010281f:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0102825:	8b 45 08             	mov    0x8(%ebp),%eax
c0102828:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010282c:	8b 45 08             	mov    0x8(%ebp),%eax
c010282f:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0102833:	8b 45 08             	mov    0x8(%ebp),%eax
c0102836:	8b 40 40             	mov    0x40(%eax),%eax
c0102839:	80 e4 cf             	and    $0xcf,%ah
c010283c:	89 c2                	mov    %eax,%edx
c010283e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102841:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0102844:	8b 45 08             	mov    0x8(%ebp),%eax
c0102847:	8b 40 44             	mov    0x44(%eax),%eax
c010284a:	83 e8 44             	sub    $0x44,%eax
c010284d:	a3 cc a0 12 c0       	mov    %eax,0xc012a0cc
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102852:	a1 cc a0 12 c0       	mov    0xc012a0cc,%eax
c0102857:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c010285e:	00 
c010285f:	8b 55 08             	mov    0x8(%ebp),%edx
c0102862:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102866:	89 04 24             	mov    %eax,(%esp)
c0102869:	e8 2f 76 00 00       	call   c0109e9d <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c010286e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102871:	8d 50 fc             	lea    -0x4(%eax),%edx
c0102874:	a1 cc a0 12 c0       	mov    0xc012a0cc,%eax
c0102879:	89 02                	mov    %eax,(%edx)
        }
        break;
c010287b:	eb 3a                	jmp    c01028b7 <trap_dispatch+0x26a>
c010287d:	eb 38                	jmp    c01028b7 <trap_dispatch+0x26a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c010287f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102882:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102886:	0f b7 c0             	movzwl %ax,%eax
c0102889:	83 e0 03             	and    $0x3,%eax
c010288c:	85 c0                	test   %eax,%eax
c010288e:	75 27                	jne    c01028b7 <trap_dispatch+0x26a>
            print_trapframe(tf);
c0102890:	8b 45 08             	mov    0x8(%ebp),%eax
c0102893:	89 04 24             	mov    %eax,(%esp)
c0102896:	e8 59 fa ff ff       	call   c01022f4 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c010289b:	c7 44 24 08 db a6 10 	movl   $0xc010a6db,0x8(%esp)
c01028a2:	c0 
c01028a3:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01028aa:	00 
c01028ab:	c7 04 24 8e a6 10 c0 	movl   $0xc010a68e,(%esp)
c01028b2:	e8 3c e4 ff ff       	call   c0100cf3 <__panic>
        }
    }
}
c01028b7:	83 c4 2c             	add    $0x2c,%esp
c01028ba:	5b                   	pop    %ebx
c01028bb:	5e                   	pop    %esi
c01028bc:	5f                   	pop    %edi
c01028bd:	5d                   	pop    %ebp
c01028be:	c3                   	ret    

c01028bf <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01028bf:	55                   	push   %ebp
c01028c0:	89 e5                	mov    %esp,%ebp
c01028c2:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01028c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01028c8:	89 04 24             	mov    %eax,(%esp)
c01028cb:	e8 7d fd ff ff       	call   c010264d <trap_dispatch>
}
c01028d0:	c9                   	leave  
c01028d1:	c3                   	ret    

c01028d2 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01028d2:	1e                   	push   %ds
    pushl %es
c01028d3:	06                   	push   %es
    pushl %fs
c01028d4:	0f a0                	push   %fs
    pushl %gs
c01028d6:	0f a8                	push   %gs
    pushal
c01028d8:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01028d9:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01028de:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01028e0:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01028e2:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01028e3:	e8 d7 ff ff ff       	call   c01028bf <trap>

    # pop the pushed stack pointer
    popl %esp
c01028e8:	5c                   	pop    %esp

c01028e9 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01028e9:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01028ea:	0f a9                	pop    %gs
    popl %fs
c01028ec:	0f a1                	pop    %fs
    popl %es
c01028ee:	07                   	pop    %es
    popl %ds
c01028ef:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01028f0:	83 c4 08             	add    $0x8,%esp
    iret
c01028f3:	cf                   	iret   

c01028f4 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c01028f4:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c01028f8:	e9 ec ff ff ff       	jmp    c01028e9 <__trapret>

c01028fd <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01028fd:	6a 00                	push   $0x0
  pushl $0
c01028ff:	6a 00                	push   $0x0
  jmp __alltraps
c0102901:	e9 cc ff ff ff       	jmp    c01028d2 <__alltraps>

c0102906 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102906:	6a 00                	push   $0x0
  pushl $1
c0102908:	6a 01                	push   $0x1
  jmp __alltraps
c010290a:	e9 c3 ff ff ff       	jmp    c01028d2 <__alltraps>

c010290f <vector2>:
.globl vector2
vector2:
  pushl $0
c010290f:	6a 00                	push   $0x0
  pushl $2
c0102911:	6a 02                	push   $0x2
  jmp __alltraps
c0102913:	e9 ba ff ff ff       	jmp    c01028d2 <__alltraps>

c0102918 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102918:	6a 00                	push   $0x0
  pushl $3
c010291a:	6a 03                	push   $0x3
  jmp __alltraps
c010291c:	e9 b1 ff ff ff       	jmp    c01028d2 <__alltraps>

c0102921 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102921:	6a 00                	push   $0x0
  pushl $4
c0102923:	6a 04                	push   $0x4
  jmp __alltraps
c0102925:	e9 a8 ff ff ff       	jmp    c01028d2 <__alltraps>

c010292a <vector5>:
.globl vector5
vector5:
  pushl $0
c010292a:	6a 00                	push   $0x0
  pushl $5
c010292c:	6a 05                	push   $0x5
  jmp __alltraps
c010292e:	e9 9f ff ff ff       	jmp    c01028d2 <__alltraps>

c0102933 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102933:	6a 00                	push   $0x0
  pushl $6
c0102935:	6a 06                	push   $0x6
  jmp __alltraps
c0102937:	e9 96 ff ff ff       	jmp    c01028d2 <__alltraps>

c010293c <vector7>:
.globl vector7
vector7:
  pushl $0
c010293c:	6a 00                	push   $0x0
  pushl $7
c010293e:	6a 07                	push   $0x7
  jmp __alltraps
c0102940:	e9 8d ff ff ff       	jmp    c01028d2 <__alltraps>

c0102945 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102945:	6a 08                	push   $0x8
  jmp __alltraps
c0102947:	e9 86 ff ff ff       	jmp    c01028d2 <__alltraps>

c010294c <vector9>:
.globl vector9
vector9:
  pushl $0
c010294c:	6a 00                	push   $0x0
  pushl $9
c010294e:	6a 09                	push   $0x9
  jmp __alltraps
c0102950:	e9 7d ff ff ff       	jmp    c01028d2 <__alltraps>

c0102955 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102955:	6a 0a                	push   $0xa
  jmp __alltraps
c0102957:	e9 76 ff ff ff       	jmp    c01028d2 <__alltraps>

c010295c <vector11>:
.globl vector11
vector11:
  pushl $11
c010295c:	6a 0b                	push   $0xb
  jmp __alltraps
c010295e:	e9 6f ff ff ff       	jmp    c01028d2 <__alltraps>

c0102963 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102963:	6a 0c                	push   $0xc
  jmp __alltraps
c0102965:	e9 68 ff ff ff       	jmp    c01028d2 <__alltraps>

c010296a <vector13>:
.globl vector13
vector13:
  pushl $13
c010296a:	6a 0d                	push   $0xd
  jmp __alltraps
c010296c:	e9 61 ff ff ff       	jmp    c01028d2 <__alltraps>

c0102971 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102971:	6a 0e                	push   $0xe
  jmp __alltraps
c0102973:	e9 5a ff ff ff       	jmp    c01028d2 <__alltraps>

c0102978 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102978:	6a 00                	push   $0x0
  pushl $15
c010297a:	6a 0f                	push   $0xf
  jmp __alltraps
c010297c:	e9 51 ff ff ff       	jmp    c01028d2 <__alltraps>

c0102981 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102981:	6a 00                	push   $0x0
  pushl $16
c0102983:	6a 10                	push   $0x10
  jmp __alltraps
c0102985:	e9 48 ff ff ff       	jmp    c01028d2 <__alltraps>

c010298a <vector17>:
.globl vector17
vector17:
  pushl $17
c010298a:	6a 11                	push   $0x11
  jmp __alltraps
c010298c:	e9 41 ff ff ff       	jmp    c01028d2 <__alltraps>

c0102991 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102991:	6a 00                	push   $0x0
  pushl $18
c0102993:	6a 12                	push   $0x12
  jmp __alltraps
c0102995:	e9 38 ff ff ff       	jmp    c01028d2 <__alltraps>

c010299a <vector19>:
.globl vector19
vector19:
  pushl $0
c010299a:	6a 00                	push   $0x0
  pushl $19
c010299c:	6a 13                	push   $0x13
  jmp __alltraps
c010299e:	e9 2f ff ff ff       	jmp    c01028d2 <__alltraps>

c01029a3 <vector20>:
.globl vector20
vector20:
  pushl $0
c01029a3:	6a 00                	push   $0x0
  pushl $20
c01029a5:	6a 14                	push   $0x14
  jmp __alltraps
c01029a7:	e9 26 ff ff ff       	jmp    c01028d2 <__alltraps>

c01029ac <vector21>:
.globl vector21
vector21:
  pushl $0
c01029ac:	6a 00                	push   $0x0
  pushl $21
c01029ae:	6a 15                	push   $0x15
  jmp __alltraps
c01029b0:	e9 1d ff ff ff       	jmp    c01028d2 <__alltraps>

c01029b5 <vector22>:
.globl vector22
vector22:
  pushl $0
c01029b5:	6a 00                	push   $0x0
  pushl $22
c01029b7:	6a 16                	push   $0x16
  jmp __alltraps
c01029b9:	e9 14 ff ff ff       	jmp    c01028d2 <__alltraps>

c01029be <vector23>:
.globl vector23
vector23:
  pushl $0
c01029be:	6a 00                	push   $0x0
  pushl $23
c01029c0:	6a 17                	push   $0x17
  jmp __alltraps
c01029c2:	e9 0b ff ff ff       	jmp    c01028d2 <__alltraps>

c01029c7 <vector24>:
.globl vector24
vector24:
  pushl $0
c01029c7:	6a 00                	push   $0x0
  pushl $24
c01029c9:	6a 18                	push   $0x18
  jmp __alltraps
c01029cb:	e9 02 ff ff ff       	jmp    c01028d2 <__alltraps>

c01029d0 <vector25>:
.globl vector25
vector25:
  pushl $0
c01029d0:	6a 00                	push   $0x0
  pushl $25
c01029d2:	6a 19                	push   $0x19
  jmp __alltraps
c01029d4:	e9 f9 fe ff ff       	jmp    c01028d2 <__alltraps>

c01029d9 <vector26>:
.globl vector26
vector26:
  pushl $0
c01029d9:	6a 00                	push   $0x0
  pushl $26
c01029db:	6a 1a                	push   $0x1a
  jmp __alltraps
c01029dd:	e9 f0 fe ff ff       	jmp    c01028d2 <__alltraps>

c01029e2 <vector27>:
.globl vector27
vector27:
  pushl $0
c01029e2:	6a 00                	push   $0x0
  pushl $27
c01029e4:	6a 1b                	push   $0x1b
  jmp __alltraps
c01029e6:	e9 e7 fe ff ff       	jmp    c01028d2 <__alltraps>

c01029eb <vector28>:
.globl vector28
vector28:
  pushl $0
c01029eb:	6a 00                	push   $0x0
  pushl $28
c01029ed:	6a 1c                	push   $0x1c
  jmp __alltraps
c01029ef:	e9 de fe ff ff       	jmp    c01028d2 <__alltraps>

c01029f4 <vector29>:
.globl vector29
vector29:
  pushl $0
c01029f4:	6a 00                	push   $0x0
  pushl $29
c01029f6:	6a 1d                	push   $0x1d
  jmp __alltraps
c01029f8:	e9 d5 fe ff ff       	jmp    c01028d2 <__alltraps>

c01029fd <vector30>:
.globl vector30
vector30:
  pushl $0
c01029fd:	6a 00                	push   $0x0
  pushl $30
c01029ff:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102a01:	e9 cc fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a06 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102a06:	6a 00                	push   $0x0
  pushl $31
c0102a08:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102a0a:	e9 c3 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a0f <vector32>:
.globl vector32
vector32:
  pushl $0
c0102a0f:	6a 00                	push   $0x0
  pushl $32
c0102a11:	6a 20                	push   $0x20
  jmp __alltraps
c0102a13:	e9 ba fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a18 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102a18:	6a 00                	push   $0x0
  pushl $33
c0102a1a:	6a 21                	push   $0x21
  jmp __alltraps
c0102a1c:	e9 b1 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a21 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102a21:	6a 00                	push   $0x0
  pushl $34
c0102a23:	6a 22                	push   $0x22
  jmp __alltraps
c0102a25:	e9 a8 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a2a <vector35>:
.globl vector35
vector35:
  pushl $0
c0102a2a:	6a 00                	push   $0x0
  pushl $35
c0102a2c:	6a 23                	push   $0x23
  jmp __alltraps
c0102a2e:	e9 9f fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a33 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102a33:	6a 00                	push   $0x0
  pushl $36
c0102a35:	6a 24                	push   $0x24
  jmp __alltraps
c0102a37:	e9 96 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a3c <vector37>:
.globl vector37
vector37:
  pushl $0
c0102a3c:	6a 00                	push   $0x0
  pushl $37
c0102a3e:	6a 25                	push   $0x25
  jmp __alltraps
c0102a40:	e9 8d fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a45 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102a45:	6a 00                	push   $0x0
  pushl $38
c0102a47:	6a 26                	push   $0x26
  jmp __alltraps
c0102a49:	e9 84 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a4e <vector39>:
.globl vector39
vector39:
  pushl $0
c0102a4e:	6a 00                	push   $0x0
  pushl $39
c0102a50:	6a 27                	push   $0x27
  jmp __alltraps
c0102a52:	e9 7b fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a57 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102a57:	6a 00                	push   $0x0
  pushl $40
c0102a59:	6a 28                	push   $0x28
  jmp __alltraps
c0102a5b:	e9 72 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a60 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102a60:	6a 00                	push   $0x0
  pushl $41
c0102a62:	6a 29                	push   $0x29
  jmp __alltraps
c0102a64:	e9 69 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a69 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102a69:	6a 00                	push   $0x0
  pushl $42
c0102a6b:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102a6d:	e9 60 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a72 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102a72:	6a 00                	push   $0x0
  pushl $43
c0102a74:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102a76:	e9 57 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a7b <vector44>:
.globl vector44
vector44:
  pushl $0
c0102a7b:	6a 00                	push   $0x0
  pushl $44
c0102a7d:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102a7f:	e9 4e fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a84 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102a84:	6a 00                	push   $0x0
  pushl $45
c0102a86:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102a88:	e9 45 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a8d <vector46>:
.globl vector46
vector46:
  pushl $0
c0102a8d:	6a 00                	push   $0x0
  pushl $46
c0102a8f:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102a91:	e9 3c fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a96 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102a96:	6a 00                	push   $0x0
  pushl $47
c0102a98:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102a9a:	e9 33 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102a9f <vector48>:
.globl vector48
vector48:
  pushl $0
c0102a9f:	6a 00                	push   $0x0
  pushl $48
c0102aa1:	6a 30                	push   $0x30
  jmp __alltraps
c0102aa3:	e9 2a fe ff ff       	jmp    c01028d2 <__alltraps>

c0102aa8 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102aa8:	6a 00                	push   $0x0
  pushl $49
c0102aaa:	6a 31                	push   $0x31
  jmp __alltraps
c0102aac:	e9 21 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102ab1 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102ab1:	6a 00                	push   $0x0
  pushl $50
c0102ab3:	6a 32                	push   $0x32
  jmp __alltraps
c0102ab5:	e9 18 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102aba <vector51>:
.globl vector51
vector51:
  pushl $0
c0102aba:	6a 00                	push   $0x0
  pushl $51
c0102abc:	6a 33                	push   $0x33
  jmp __alltraps
c0102abe:	e9 0f fe ff ff       	jmp    c01028d2 <__alltraps>

c0102ac3 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102ac3:	6a 00                	push   $0x0
  pushl $52
c0102ac5:	6a 34                	push   $0x34
  jmp __alltraps
c0102ac7:	e9 06 fe ff ff       	jmp    c01028d2 <__alltraps>

c0102acc <vector53>:
.globl vector53
vector53:
  pushl $0
c0102acc:	6a 00                	push   $0x0
  pushl $53
c0102ace:	6a 35                	push   $0x35
  jmp __alltraps
c0102ad0:	e9 fd fd ff ff       	jmp    c01028d2 <__alltraps>

c0102ad5 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102ad5:	6a 00                	push   $0x0
  pushl $54
c0102ad7:	6a 36                	push   $0x36
  jmp __alltraps
c0102ad9:	e9 f4 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102ade <vector55>:
.globl vector55
vector55:
  pushl $0
c0102ade:	6a 00                	push   $0x0
  pushl $55
c0102ae0:	6a 37                	push   $0x37
  jmp __alltraps
c0102ae2:	e9 eb fd ff ff       	jmp    c01028d2 <__alltraps>

c0102ae7 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102ae7:	6a 00                	push   $0x0
  pushl $56
c0102ae9:	6a 38                	push   $0x38
  jmp __alltraps
c0102aeb:	e9 e2 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102af0 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102af0:	6a 00                	push   $0x0
  pushl $57
c0102af2:	6a 39                	push   $0x39
  jmp __alltraps
c0102af4:	e9 d9 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102af9 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102af9:	6a 00                	push   $0x0
  pushl $58
c0102afb:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102afd:	e9 d0 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b02 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102b02:	6a 00                	push   $0x0
  pushl $59
c0102b04:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102b06:	e9 c7 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b0b <vector60>:
.globl vector60
vector60:
  pushl $0
c0102b0b:	6a 00                	push   $0x0
  pushl $60
c0102b0d:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102b0f:	e9 be fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b14 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102b14:	6a 00                	push   $0x0
  pushl $61
c0102b16:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102b18:	e9 b5 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b1d <vector62>:
.globl vector62
vector62:
  pushl $0
c0102b1d:	6a 00                	push   $0x0
  pushl $62
c0102b1f:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102b21:	e9 ac fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b26 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102b26:	6a 00                	push   $0x0
  pushl $63
c0102b28:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102b2a:	e9 a3 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b2f <vector64>:
.globl vector64
vector64:
  pushl $0
c0102b2f:	6a 00                	push   $0x0
  pushl $64
c0102b31:	6a 40                	push   $0x40
  jmp __alltraps
c0102b33:	e9 9a fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b38 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102b38:	6a 00                	push   $0x0
  pushl $65
c0102b3a:	6a 41                	push   $0x41
  jmp __alltraps
c0102b3c:	e9 91 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b41 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102b41:	6a 00                	push   $0x0
  pushl $66
c0102b43:	6a 42                	push   $0x42
  jmp __alltraps
c0102b45:	e9 88 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b4a <vector67>:
.globl vector67
vector67:
  pushl $0
c0102b4a:	6a 00                	push   $0x0
  pushl $67
c0102b4c:	6a 43                	push   $0x43
  jmp __alltraps
c0102b4e:	e9 7f fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b53 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102b53:	6a 00                	push   $0x0
  pushl $68
c0102b55:	6a 44                	push   $0x44
  jmp __alltraps
c0102b57:	e9 76 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b5c <vector69>:
.globl vector69
vector69:
  pushl $0
c0102b5c:	6a 00                	push   $0x0
  pushl $69
c0102b5e:	6a 45                	push   $0x45
  jmp __alltraps
c0102b60:	e9 6d fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b65 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102b65:	6a 00                	push   $0x0
  pushl $70
c0102b67:	6a 46                	push   $0x46
  jmp __alltraps
c0102b69:	e9 64 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b6e <vector71>:
.globl vector71
vector71:
  pushl $0
c0102b6e:	6a 00                	push   $0x0
  pushl $71
c0102b70:	6a 47                	push   $0x47
  jmp __alltraps
c0102b72:	e9 5b fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b77 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102b77:	6a 00                	push   $0x0
  pushl $72
c0102b79:	6a 48                	push   $0x48
  jmp __alltraps
c0102b7b:	e9 52 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b80 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102b80:	6a 00                	push   $0x0
  pushl $73
c0102b82:	6a 49                	push   $0x49
  jmp __alltraps
c0102b84:	e9 49 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b89 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102b89:	6a 00                	push   $0x0
  pushl $74
c0102b8b:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102b8d:	e9 40 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b92 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102b92:	6a 00                	push   $0x0
  pushl $75
c0102b94:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102b96:	e9 37 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102b9b <vector76>:
.globl vector76
vector76:
  pushl $0
c0102b9b:	6a 00                	push   $0x0
  pushl $76
c0102b9d:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102b9f:	e9 2e fd ff ff       	jmp    c01028d2 <__alltraps>

c0102ba4 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102ba4:	6a 00                	push   $0x0
  pushl $77
c0102ba6:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102ba8:	e9 25 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102bad <vector78>:
.globl vector78
vector78:
  pushl $0
c0102bad:	6a 00                	push   $0x0
  pushl $78
c0102baf:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102bb1:	e9 1c fd ff ff       	jmp    c01028d2 <__alltraps>

c0102bb6 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102bb6:	6a 00                	push   $0x0
  pushl $79
c0102bb8:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102bba:	e9 13 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102bbf <vector80>:
.globl vector80
vector80:
  pushl $0
c0102bbf:	6a 00                	push   $0x0
  pushl $80
c0102bc1:	6a 50                	push   $0x50
  jmp __alltraps
c0102bc3:	e9 0a fd ff ff       	jmp    c01028d2 <__alltraps>

c0102bc8 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102bc8:	6a 00                	push   $0x0
  pushl $81
c0102bca:	6a 51                	push   $0x51
  jmp __alltraps
c0102bcc:	e9 01 fd ff ff       	jmp    c01028d2 <__alltraps>

c0102bd1 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102bd1:	6a 00                	push   $0x0
  pushl $82
c0102bd3:	6a 52                	push   $0x52
  jmp __alltraps
c0102bd5:	e9 f8 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102bda <vector83>:
.globl vector83
vector83:
  pushl $0
c0102bda:	6a 00                	push   $0x0
  pushl $83
c0102bdc:	6a 53                	push   $0x53
  jmp __alltraps
c0102bde:	e9 ef fc ff ff       	jmp    c01028d2 <__alltraps>

c0102be3 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102be3:	6a 00                	push   $0x0
  pushl $84
c0102be5:	6a 54                	push   $0x54
  jmp __alltraps
c0102be7:	e9 e6 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102bec <vector85>:
.globl vector85
vector85:
  pushl $0
c0102bec:	6a 00                	push   $0x0
  pushl $85
c0102bee:	6a 55                	push   $0x55
  jmp __alltraps
c0102bf0:	e9 dd fc ff ff       	jmp    c01028d2 <__alltraps>

c0102bf5 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102bf5:	6a 00                	push   $0x0
  pushl $86
c0102bf7:	6a 56                	push   $0x56
  jmp __alltraps
c0102bf9:	e9 d4 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102bfe <vector87>:
.globl vector87
vector87:
  pushl $0
c0102bfe:	6a 00                	push   $0x0
  pushl $87
c0102c00:	6a 57                	push   $0x57
  jmp __alltraps
c0102c02:	e9 cb fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c07 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102c07:	6a 00                	push   $0x0
  pushl $88
c0102c09:	6a 58                	push   $0x58
  jmp __alltraps
c0102c0b:	e9 c2 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c10 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102c10:	6a 00                	push   $0x0
  pushl $89
c0102c12:	6a 59                	push   $0x59
  jmp __alltraps
c0102c14:	e9 b9 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c19 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102c19:	6a 00                	push   $0x0
  pushl $90
c0102c1b:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102c1d:	e9 b0 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c22 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102c22:	6a 00                	push   $0x0
  pushl $91
c0102c24:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102c26:	e9 a7 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c2b <vector92>:
.globl vector92
vector92:
  pushl $0
c0102c2b:	6a 00                	push   $0x0
  pushl $92
c0102c2d:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102c2f:	e9 9e fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c34 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102c34:	6a 00                	push   $0x0
  pushl $93
c0102c36:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102c38:	e9 95 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c3d <vector94>:
.globl vector94
vector94:
  pushl $0
c0102c3d:	6a 00                	push   $0x0
  pushl $94
c0102c3f:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102c41:	e9 8c fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c46 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102c46:	6a 00                	push   $0x0
  pushl $95
c0102c48:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102c4a:	e9 83 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c4f <vector96>:
.globl vector96
vector96:
  pushl $0
c0102c4f:	6a 00                	push   $0x0
  pushl $96
c0102c51:	6a 60                	push   $0x60
  jmp __alltraps
c0102c53:	e9 7a fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c58 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102c58:	6a 00                	push   $0x0
  pushl $97
c0102c5a:	6a 61                	push   $0x61
  jmp __alltraps
c0102c5c:	e9 71 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c61 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102c61:	6a 00                	push   $0x0
  pushl $98
c0102c63:	6a 62                	push   $0x62
  jmp __alltraps
c0102c65:	e9 68 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c6a <vector99>:
.globl vector99
vector99:
  pushl $0
c0102c6a:	6a 00                	push   $0x0
  pushl $99
c0102c6c:	6a 63                	push   $0x63
  jmp __alltraps
c0102c6e:	e9 5f fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c73 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102c73:	6a 00                	push   $0x0
  pushl $100
c0102c75:	6a 64                	push   $0x64
  jmp __alltraps
c0102c77:	e9 56 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c7c <vector101>:
.globl vector101
vector101:
  pushl $0
c0102c7c:	6a 00                	push   $0x0
  pushl $101
c0102c7e:	6a 65                	push   $0x65
  jmp __alltraps
c0102c80:	e9 4d fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c85 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102c85:	6a 00                	push   $0x0
  pushl $102
c0102c87:	6a 66                	push   $0x66
  jmp __alltraps
c0102c89:	e9 44 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c8e <vector103>:
.globl vector103
vector103:
  pushl $0
c0102c8e:	6a 00                	push   $0x0
  pushl $103
c0102c90:	6a 67                	push   $0x67
  jmp __alltraps
c0102c92:	e9 3b fc ff ff       	jmp    c01028d2 <__alltraps>

c0102c97 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102c97:	6a 00                	push   $0x0
  pushl $104
c0102c99:	6a 68                	push   $0x68
  jmp __alltraps
c0102c9b:	e9 32 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102ca0 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102ca0:	6a 00                	push   $0x0
  pushl $105
c0102ca2:	6a 69                	push   $0x69
  jmp __alltraps
c0102ca4:	e9 29 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102ca9 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102ca9:	6a 00                	push   $0x0
  pushl $106
c0102cab:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102cad:	e9 20 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102cb2 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102cb2:	6a 00                	push   $0x0
  pushl $107
c0102cb4:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102cb6:	e9 17 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102cbb <vector108>:
.globl vector108
vector108:
  pushl $0
c0102cbb:	6a 00                	push   $0x0
  pushl $108
c0102cbd:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102cbf:	e9 0e fc ff ff       	jmp    c01028d2 <__alltraps>

c0102cc4 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102cc4:	6a 00                	push   $0x0
  pushl $109
c0102cc6:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102cc8:	e9 05 fc ff ff       	jmp    c01028d2 <__alltraps>

c0102ccd <vector110>:
.globl vector110
vector110:
  pushl $0
c0102ccd:	6a 00                	push   $0x0
  pushl $110
c0102ccf:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102cd1:	e9 fc fb ff ff       	jmp    c01028d2 <__alltraps>

c0102cd6 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102cd6:	6a 00                	push   $0x0
  pushl $111
c0102cd8:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102cda:	e9 f3 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102cdf <vector112>:
.globl vector112
vector112:
  pushl $0
c0102cdf:	6a 00                	push   $0x0
  pushl $112
c0102ce1:	6a 70                	push   $0x70
  jmp __alltraps
c0102ce3:	e9 ea fb ff ff       	jmp    c01028d2 <__alltraps>

c0102ce8 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102ce8:	6a 00                	push   $0x0
  pushl $113
c0102cea:	6a 71                	push   $0x71
  jmp __alltraps
c0102cec:	e9 e1 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102cf1 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102cf1:	6a 00                	push   $0x0
  pushl $114
c0102cf3:	6a 72                	push   $0x72
  jmp __alltraps
c0102cf5:	e9 d8 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102cfa <vector115>:
.globl vector115
vector115:
  pushl $0
c0102cfa:	6a 00                	push   $0x0
  pushl $115
c0102cfc:	6a 73                	push   $0x73
  jmp __alltraps
c0102cfe:	e9 cf fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d03 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102d03:	6a 00                	push   $0x0
  pushl $116
c0102d05:	6a 74                	push   $0x74
  jmp __alltraps
c0102d07:	e9 c6 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d0c <vector117>:
.globl vector117
vector117:
  pushl $0
c0102d0c:	6a 00                	push   $0x0
  pushl $117
c0102d0e:	6a 75                	push   $0x75
  jmp __alltraps
c0102d10:	e9 bd fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d15 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102d15:	6a 00                	push   $0x0
  pushl $118
c0102d17:	6a 76                	push   $0x76
  jmp __alltraps
c0102d19:	e9 b4 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d1e <vector119>:
.globl vector119
vector119:
  pushl $0
c0102d1e:	6a 00                	push   $0x0
  pushl $119
c0102d20:	6a 77                	push   $0x77
  jmp __alltraps
c0102d22:	e9 ab fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d27 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102d27:	6a 00                	push   $0x0
  pushl $120
c0102d29:	6a 78                	push   $0x78
  jmp __alltraps
c0102d2b:	e9 a2 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d30 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102d30:	6a 00                	push   $0x0
  pushl $121
c0102d32:	6a 79                	push   $0x79
  jmp __alltraps
c0102d34:	e9 99 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d39 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102d39:	6a 00                	push   $0x0
  pushl $122
c0102d3b:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102d3d:	e9 90 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d42 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102d42:	6a 00                	push   $0x0
  pushl $123
c0102d44:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102d46:	e9 87 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d4b <vector124>:
.globl vector124
vector124:
  pushl $0
c0102d4b:	6a 00                	push   $0x0
  pushl $124
c0102d4d:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102d4f:	e9 7e fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d54 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102d54:	6a 00                	push   $0x0
  pushl $125
c0102d56:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102d58:	e9 75 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d5d <vector126>:
.globl vector126
vector126:
  pushl $0
c0102d5d:	6a 00                	push   $0x0
  pushl $126
c0102d5f:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102d61:	e9 6c fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d66 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102d66:	6a 00                	push   $0x0
  pushl $127
c0102d68:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102d6a:	e9 63 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d6f <vector128>:
.globl vector128
vector128:
  pushl $0
c0102d6f:	6a 00                	push   $0x0
  pushl $128
c0102d71:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102d76:	e9 57 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d7b <vector129>:
.globl vector129
vector129:
  pushl $0
c0102d7b:	6a 00                	push   $0x0
  pushl $129
c0102d7d:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102d82:	e9 4b fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d87 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102d87:	6a 00                	push   $0x0
  pushl $130
c0102d89:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102d8e:	e9 3f fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d93 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102d93:	6a 00                	push   $0x0
  pushl $131
c0102d95:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102d9a:	e9 33 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102d9f <vector132>:
.globl vector132
vector132:
  pushl $0
c0102d9f:	6a 00                	push   $0x0
  pushl $132
c0102da1:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102da6:	e9 27 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102dab <vector133>:
.globl vector133
vector133:
  pushl $0
c0102dab:	6a 00                	push   $0x0
  pushl $133
c0102dad:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102db2:	e9 1b fb ff ff       	jmp    c01028d2 <__alltraps>

c0102db7 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102db7:	6a 00                	push   $0x0
  pushl $134
c0102db9:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102dbe:	e9 0f fb ff ff       	jmp    c01028d2 <__alltraps>

c0102dc3 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102dc3:	6a 00                	push   $0x0
  pushl $135
c0102dc5:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102dca:	e9 03 fb ff ff       	jmp    c01028d2 <__alltraps>

c0102dcf <vector136>:
.globl vector136
vector136:
  pushl $0
c0102dcf:	6a 00                	push   $0x0
  pushl $136
c0102dd1:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102dd6:	e9 f7 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102ddb <vector137>:
.globl vector137
vector137:
  pushl $0
c0102ddb:	6a 00                	push   $0x0
  pushl $137
c0102ddd:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102de2:	e9 eb fa ff ff       	jmp    c01028d2 <__alltraps>

c0102de7 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102de7:	6a 00                	push   $0x0
  pushl $138
c0102de9:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102dee:	e9 df fa ff ff       	jmp    c01028d2 <__alltraps>

c0102df3 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102df3:	6a 00                	push   $0x0
  pushl $139
c0102df5:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102dfa:	e9 d3 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102dff <vector140>:
.globl vector140
vector140:
  pushl $0
c0102dff:	6a 00                	push   $0x0
  pushl $140
c0102e01:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102e06:	e9 c7 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e0b <vector141>:
.globl vector141
vector141:
  pushl $0
c0102e0b:	6a 00                	push   $0x0
  pushl $141
c0102e0d:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102e12:	e9 bb fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e17 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102e17:	6a 00                	push   $0x0
  pushl $142
c0102e19:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102e1e:	e9 af fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e23 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102e23:	6a 00                	push   $0x0
  pushl $143
c0102e25:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102e2a:	e9 a3 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e2f <vector144>:
.globl vector144
vector144:
  pushl $0
c0102e2f:	6a 00                	push   $0x0
  pushl $144
c0102e31:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102e36:	e9 97 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e3b <vector145>:
.globl vector145
vector145:
  pushl $0
c0102e3b:	6a 00                	push   $0x0
  pushl $145
c0102e3d:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102e42:	e9 8b fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e47 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102e47:	6a 00                	push   $0x0
  pushl $146
c0102e49:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102e4e:	e9 7f fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e53 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102e53:	6a 00                	push   $0x0
  pushl $147
c0102e55:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102e5a:	e9 73 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e5f <vector148>:
.globl vector148
vector148:
  pushl $0
c0102e5f:	6a 00                	push   $0x0
  pushl $148
c0102e61:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102e66:	e9 67 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e6b <vector149>:
.globl vector149
vector149:
  pushl $0
c0102e6b:	6a 00                	push   $0x0
  pushl $149
c0102e6d:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102e72:	e9 5b fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e77 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102e77:	6a 00                	push   $0x0
  pushl $150
c0102e79:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102e7e:	e9 4f fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e83 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102e83:	6a 00                	push   $0x0
  pushl $151
c0102e85:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102e8a:	e9 43 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e8f <vector152>:
.globl vector152
vector152:
  pushl $0
c0102e8f:	6a 00                	push   $0x0
  pushl $152
c0102e91:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102e96:	e9 37 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102e9b <vector153>:
.globl vector153
vector153:
  pushl $0
c0102e9b:	6a 00                	push   $0x0
  pushl $153
c0102e9d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102ea2:	e9 2b fa ff ff       	jmp    c01028d2 <__alltraps>

c0102ea7 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102ea7:	6a 00                	push   $0x0
  pushl $154
c0102ea9:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102eae:	e9 1f fa ff ff       	jmp    c01028d2 <__alltraps>

c0102eb3 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102eb3:	6a 00                	push   $0x0
  pushl $155
c0102eb5:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102eba:	e9 13 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102ebf <vector156>:
.globl vector156
vector156:
  pushl $0
c0102ebf:	6a 00                	push   $0x0
  pushl $156
c0102ec1:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102ec6:	e9 07 fa ff ff       	jmp    c01028d2 <__alltraps>

c0102ecb <vector157>:
.globl vector157
vector157:
  pushl $0
c0102ecb:	6a 00                	push   $0x0
  pushl $157
c0102ecd:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102ed2:	e9 fb f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102ed7 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102ed7:	6a 00                	push   $0x0
  pushl $158
c0102ed9:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102ede:	e9 ef f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102ee3 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102ee3:	6a 00                	push   $0x0
  pushl $159
c0102ee5:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102eea:	e9 e3 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102eef <vector160>:
.globl vector160
vector160:
  pushl $0
c0102eef:	6a 00                	push   $0x0
  pushl $160
c0102ef1:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102ef6:	e9 d7 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102efb <vector161>:
.globl vector161
vector161:
  pushl $0
c0102efb:	6a 00                	push   $0x0
  pushl $161
c0102efd:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102f02:	e9 cb f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f07 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102f07:	6a 00                	push   $0x0
  pushl $162
c0102f09:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102f0e:	e9 bf f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f13 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102f13:	6a 00                	push   $0x0
  pushl $163
c0102f15:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102f1a:	e9 b3 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f1f <vector164>:
.globl vector164
vector164:
  pushl $0
c0102f1f:	6a 00                	push   $0x0
  pushl $164
c0102f21:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102f26:	e9 a7 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f2b <vector165>:
.globl vector165
vector165:
  pushl $0
c0102f2b:	6a 00                	push   $0x0
  pushl $165
c0102f2d:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102f32:	e9 9b f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f37 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102f37:	6a 00                	push   $0x0
  pushl $166
c0102f39:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102f3e:	e9 8f f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f43 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102f43:	6a 00                	push   $0x0
  pushl $167
c0102f45:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102f4a:	e9 83 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f4f <vector168>:
.globl vector168
vector168:
  pushl $0
c0102f4f:	6a 00                	push   $0x0
  pushl $168
c0102f51:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102f56:	e9 77 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f5b <vector169>:
.globl vector169
vector169:
  pushl $0
c0102f5b:	6a 00                	push   $0x0
  pushl $169
c0102f5d:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102f62:	e9 6b f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f67 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102f67:	6a 00                	push   $0x0
  pushl $170
c0102f69:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102f6e:	e9 5f f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f73 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102f73:	6a 00                	push   $0x0
  pushl $171
c0102f75:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102f7a:	e9 53 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f7f <vector172>:
.globl vector172
vector172:
  pushl $0
c0102f7f:	6a 00                	push   $0x0
  pushl $172
c0102f81:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102f86:	e9 47 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f8b <vector173>:
.globl vector173
vector173:
  pushl $0
c0102f8b:	6a 00                	push   $0x0
  pushl $173
c0102f8d:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102f92:	e9 3b f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102f97 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102f97:	6a 00                	push   $0x0
  pushl $174
c0102f99:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102f9e:	e9 2f f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102fa3 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102fa3:	6a 00                	push   $0x0
  pushl $175
c0102fa5:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102faa:	e9 23 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102faf <vector176>:
.globl vector176
vector176:
  pushl $0
c0102faf:	6a 00                	push   $0x0
  pushl $176
c0102fb1:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102fb6:	e9 17 f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102fbb <vector177>:
.globl vector177
vector177:
  pushl $0
c0102fbb:	6a 00                	push   $0x0
  pushl $177
c0102fbd:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102fc2:	e9 0b f9 ff ff       	jmp    c01028d2 <__alltraps>

c0102fc7 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102fc7:	6a 00                	push   $0x0
  pushl $178
c0102fc9:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102fce:	e9 ff f8 ff ff       	jmp    c01028d2 <__alltraps>

c0102fd3 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102fd3:	6a 00                	push   $0x0
  pushl $179
c0102fd5:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102fda:	e9 f3 f8 ff ff       	jmp    c01028d2 <__alltraps>

c0102fdf <vector180>:
.globl vector180
vector180:
  pushl $0
c0102fdf:	6a 00                	push   $0x0
  pushl $180
c0102fe1:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102fe6:	e9 e7 f8 ff ff       	jmp    c01028d2 <__alltraps>

c0102feb <vector181>:
.globl vector181
vector181:
  pushl $0
c0102feb:	6a 00                	push   $0x0
  pushl $181
c0102fed:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102ff2:	e9 db f8 ff ff       	jmp    c01028d2 <__alltraps>

c0102ff7 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102ff7:	6a 00                	push   $0x0
  pushl $182
c0102ff9:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102ffe:	e9 cf f8 ff ff       	jmp    c01028d2 <__alltraps>

c0103003 <vector183>:
.globl vector183
vector183:
  pushl $0
c0103003:	6a 00                	push   $0x0
  pushl $183
c0103005:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010300a:	e9 c3 f8 ff ff       	jmp    c01028d2 <__alltraps>

c010300f <vector184>:
.globl vector184
vector184:
  pushl $0
c010300f:	6a 00                	push   $0x0
  pushl $184
c0103011:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103016:	e9 b7 f8 ff ff       	jmp    c01028d2 <__alltraps>

c010301b <vector185>:
.globl vector185
vector185:
  pushl $0
c010301b:	6a 00                	push   $0x0
  pushl $185
c010301d:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103022:	e9 ab f8 ff ff       	jmp    c01028d2 <__alltraps>

c0103027 <vector186>:
.globl vector186
vector186:
  pushl $0
c0103027:	6a 00                	push   $0x0
  pushl $186
c0103029:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010302e:	e9 9f f8 ff ff       	jmp    c01028d2 <__alltraps>

c0103033 <vector187>:
.globl vector187
vector187:
  pushl $0
c0103033:	6a 00                	push   $0x0
  pushl $187
c0103035:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010303a:	e9 93 f8 ff ff       	jmp    c01028d2 <__alltraps>

c010303f <vector188>:
.globl vector188
vector188:
  pushl $0
c010303f:	6a 00                	push   $0x0
  pushl $188
c0103041:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0103046:	e9 87 f8 ff ff       	jmp    c01028d2 <__alltraps>

c010304b <vector189>:
.globl vector189
vector189:
  pushl $0
c010304b:	6a 00                	push   $0x0
  pushl $189
c010304d:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0103052:	e9 7b f8 ff ff       	jmp    c01028d2 <__alltraps>

c0103057 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103057:	6a 00                	push   $0x0
  pushl $190
c0103059:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010305e:	e9 6f f8 ff ff       	jmp    c01028d2 <__alltraps>

c0103063 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103063:	6a 00                	push   $0x0
  pushl $191
c0103065:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010306a:	e9 63 f8 ff ff       	jmp    c01028d2 <__alltraps>

c010306f <vector192>:
.globl vector192
vector192:
  pushl $0
c010306f:	6a 00                	push   $0x0
  pushl $192
c0103071:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103076:	e9 57 f8 ff ff       	jmp    c01028d2 <__alltraps>

c010307b <vector193>:
.globl vector193
vector193:
  pushl $0
c010307b:	6a 00                	push   $0x0
  pushl $193
c010307d:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103082:	e9 4b f8 ff ff       	jmp    c01028d2 <__alltraps>

c0103087 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103087:	6a 00                	push   $0x0
  pushl $194
c0103089:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010308e:	e9 3f f8 ff ff       	jmp    c01028d2 <__alltraps>

c0103093 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103093:	6a 00                	push   $0x0
  pushl $195
c0103095:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010309a:	e9 33 f8 ff ff       	jmp    c01028d2 <__alltraps>

c010309f <vector196>:
.globl vector196
vector196:
  pushl $0
c010309f:	6a 00                	push   $0x0
  pushl $196
c01030a1:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01030a6:	e9 27 f8 ff ff       	jmp    c01028d2 <__alltraps>

c01030ab <vector197>:
.globl vector197
vector197:
  pushl $0
c01030ab:	6a 00                	push   $0x0
  pushl $197
c01030ad:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01030b2:	e9 1b f8 ff ff       	jmp    c01028d2 <__alltraps>

c01030b7 <vector198>:
.globl vector198
vector198:
  pushl $0
c01030b7:	6a 00                	push   $0x0
  pushl $198
c01030b9:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01030be:	e9 0f f8 ff ff       	jmp    c01028d2 <__alltraps>

c01030c3 <vector199>:
.globl vector199
vector199:
  pushl $0
c01030c3:	6a 00                	push   $0x0
  pushl $199
c01030c5:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01030ca:	e9 03 f8 ff ff       	jmp    c01028d2 <__alltraps>

c01030cf <vector200>:
.globl vector200
vector200:
  pushl $0
c01030cf:	6a 00                	push   $0x0
  pushl $200
c01030d1:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01030d6:	e9 f7 f7 ff ff       	jmp    c01028d2 <__alltraps>

c01030db <vector201>:
.globl vector201
vector201:
  pushl $0
c01030db:	6a 00                	push   $0x0
  pushl $201
c01030dd:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01030e2:	e9 eb f7 ff ff       	jmp    c01028d2 <__alltraps>

c01030e7 <vector202>:
.globl vector202
vector202:
  pushl $0
c01030e7:	6a 00                	push   $0x0
  pushl $202
c01030e9:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01030ee:	e9 df f7 ff ff       	jmp    c01028d2 <__alltraps>

c01030f3 <vector203>:
.globl vector203
vector203:
  pushl $0
c01030f3:	6a 00                	push   $0x0
  pushl $203
c01030f5:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01030fa:	e9 d3 f7 ff ff       	jmp    c01028d2 <__alltraps>

c01030ff <vector204>:
.globl vector204
vector204:
  pushl $0
c01030ff:	6a 00                	push   $0x0
  pushl $204
c0103101:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103106:	e9 c7 f7 ff ff       	jmp    c01028d2 <__alltraps>

c010310b <vector205>:
.globl vector205
vector205:
  pushl $0
c010310b:	6a 00                	push   $0x0
  pushl $205
c010310d:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103112:	e9 bb f7 ff ff       	jmp    c01028d2 <__alltraps>

c0103117 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103117:	6a 00                	push   $0x0
  pushl $206
c0103119:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010311e:	e9 af f7 ff ff       	jmp    c01028d2 <__alltraps>

c0103123 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103123:	6a 00                	push   $0x0
  pushl $207
c0103125:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010312a:	e9 a3 f7 ff ff       	jmp    c01028d2 <__alltraps>

c010312f <vector208>:
.globl vector208
vector208:
  pushl $0
c010312f:	6a 00                	push   $0x0
  pushl $208
c0103131:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103136:	e9 97 f7 ff ff       	jmp    c01028d2 <__alltraps>

c010313b <vector209>:
.globl vector209
vector209:
  pushl $0
c010313b:	6a 00                	push   $0x0
  pushl $209
c010313d:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0103142:	e9 8b f7 ff ff       	jmp    c01028d2 <__alltraps>

c0103147 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103147:	6a 00                	push   $0x0
  pushl $210
c0103149:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010314e:	e9 7f f7 ff ff       	jmp    c01028d2 <__alltraps>

c0103153 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103153:	6a 00                	push   $0x0
  pushl $211
c0103155:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010315a:	e9 73 f7 ff ff       	jmp    c01028d2 <__alltraps>

c010315f <vector212>:
.globl vector212
vector212:
  pushl $0
c010315f:	6a 00                	push   $0x0
  pushl $212
c0103161:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103166:	e9 67 f7 ff ff       	jmp    c01028d2 <__alltraps>

c010316b <vector213>:
.globl vector213
vector213:
  pushl $0
c010316b:	6a 00                	push   $0x0
  pushl $213
c010316d:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103172:	e9 5b f7 ff ff       	jmp    c01028d2 <__alltraps>

c0103177 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103177:	6a 00                	push   $0x0
  pushl $214
c0103179:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010317e:	e9 4f f7 ff ff       	jmp    c01028d2 <__alltraps>

c0103183 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103183:	6a 00                	push   $0x0
  pushl $215
c0103185:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010318a:	e9 43 f7 ff ff       	jmp    c01028d2 <__alltraps>

c010318f <vector216>:
.globl vector216
vector216:
  pushl $0
c010318f:	6a 00                	push   $0x0
  pushl $216
c0103191:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103196:	e9 37 f7 ff ff       	jmp    c01028d2 <__alltraps>

c010319b <vector217>:
.globl vector217
vector217:
  pushl $0
c010319b:	6a 00                	push   $0x0
  pushl $217
c010319d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01031a2:	e9 2b f7 ff ff       	jmp    c01028d2 <__alltraps>

c01031a7 <vector218>:
.globl vector218
vector218:
  pushl $0
c01031a7:	6a 00                	push   $0x0
  pushl $218
c01031a9:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01031ae:	e9 1f f7 ff ff       	jmp    c01028d2 <__alltraps>

c01031b3 <vector219>:
.globl vector219
vector219:
  pushl $0
c01031b3:	6a 00                	push   $0x0
  pushl $219
c01031b5:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01031ba:	e9 13 f7 ff ff       	jmp    c01028d2 <__alltraps>

c01031bf <vector220>:
.globl vector220
vector220:
  pushl $0
c01031bf:	6a 00                	push   $0x0
  pushl $220
c01031c1:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01031c6:	e9 07 f7 ff ff       	jmp    c01028d2 <__alltraps>

c01031cb <vector221>:
.globl vector221
vector221:
  pushl $0
c01031cb:	6a 00                	push   $0x0
  pushl $221
c01031cd:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01031d2:	e9 fb f6 ff ff       	jmp    c01028d2 <__alltraps>

c01031d7 <vector222>:
.globl vector222
vector222:
  pushl $0
c01031d7:	6a 00                	push   $0x0
  pushl $222
c01031d9:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01031de:	e9 ef f6 ff ff       	jmp    c01028d2 <__alltraps>

c01031e3 <vector223>:
.globl vector223
vector223:
  pushl $0
c01031e3:	6a 00                	push   $0x0
  pushl $223
c01031e5:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01031ea:	e9 e3 f6 ff ff       	jmp    c01028d2 <__alltraps>

c01031ef <vector224>:
.globl vector224
vector224:
  pushl $0
c01031ef:	6a 00                	push   $0x0
  pushl $224
c01031f1:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01031f6:	e9 d7 f6 ff ff       	jmp    c01028d2 <__alltraps>

c01031fb <vector225>:
.globl vector225
vector225:
  pushl $0
c01031fb:	6a 00                	push   $0x0
  pushl $225
c01031fd:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103202:	e9 cb f6 ff ff       	jmp    c01028d2 <__alltraps>

c0103207 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103207:	6a 00                	push   $0x0
  pushl $226
c0103209:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010320e:	e9 bf f6 ff ff       	jmp    c01028d2 <__alltraps>

c0103213 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103213:	6a 00                	push   $0x0
  pushl $227
c0103215:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010321a:	e9 b3 f6 ff ff       	jmp    c01028d2 <__alltraps>

c010321f <vector228>:
.globl vector228
vector228:
  pushl $0
c010321f:	6a 00                	push   $0x0
  pushl $228
c0103221:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103226:	e9 a7 f6 ff ff       	jmp    c01028d2 <__alltraps>

c010322b <vector229>:
.globl vector229
vector229:
  pushl $0
c010322b:	6a 00                	push   $0x0
  pushl $229
c010322d:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103232:	e9 9b f6 ff ff       	jmp    c01028d2 <__alltraps>

c0103237 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103237:	6a 00                	push   $0x0
  pushl $230
c0103239:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010323e:	e9 8f f6 ff ff       	jmp    c01028d2 <__alltraps>

c0103243 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103243:	6a 00                	push   $0x0
  pushl $231
c0103245:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010324a:	e9 83 f6 ff ff       	jmp    c01028d2 <__alltraps>

c010324f <vector232>:
.globl vector232
vector232:
  pushl $0
c010324f:	6a 00                	push   $0x0
  pushl $232
c0103251:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103256:	e9 77 f6 ff ff       	jmp    c01028d2 <__alltraps>

c010325b <vector233>:
.globl vector233
vector233:
  pushl $0
c010325b:	6a 00                	push   $0x0
  pushl $233
c010325d:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103262:	e9 6b f6 ff ff       	jmp    c01028d2 <__alltraps>

c0103267 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103267:	6a 00                	push   $0x0
  pushl $234
c0103269:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010326e:	e9 5f f6 ff ff       	jmp    c01028d2 <__alltraps>

c0103273 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103273:	6a 00                	push   $0x0
  pushl $235
c0103275:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010327a:	e9 53 f6 ff ff       	jmp    c01028d2 <__alltraps>

c010327f <vector236>:
.globl vector236
vector236:
  pushl $0
c010327f:	6a 00                	push   $0x0
  pushl $236
c0103281:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103286:	e9 47 f6 ff ff       	jmp    c01028d2 <__alltraps>

c010328b <vector237>:
.globl vector237
vector237:
  pushl $0
c010328b:	6a 00                	push   $0x0
  pushl $237
c010328d:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103292:	e9 3b f6 ff ff       	jmp    c01028d2 <__alltraps>

c0103297 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103297:	6a 00                	push   $0x0
  pushl $238
c0103299:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010329e:	e9 2f f6 ff ff       	jmp    c01028d2 <__alltraps>

c01032a3 <vector239>:
.globl vector239
vector239:
  pushl $0
c01032a3:	6a 00                	push   $0x0
  pushl $239
c01032a5:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01032aa:	e9 23 f6 ff ff       	jmp    c01028d2 <__alltraps>

c01032af <vector240>:
.globl vector240
vector240:
  pushl $0
c01032af:	6a 00                	push   $0x0
  pushl $240
c01032b1:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01032b6:	e9 17 f6 ff ff       	jmp    c01028d2 <__alltraps>

c01032bb <vector241>:
.globl vector241
vector241:
  pushl $0
c01032bb:	6a 00                	push   $0x0
  pushl $241
c01032bd:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01032c2:	e9 0b f6 ff ff       	jmp    c01028d2 <__alltraps>

c01032c7 <vector242>:
.globl vector242
vector242:
  pushl $0
c01032c7:	6a 00                	push   $0x0
  pushl $242
c01032c9:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01032ce:	e9 ff f5 ff ff       	jmp    c01028d2 <__alltraps>

c01032d3 <vector243>:
.globl vector243
vector243:
  pushl $0
c01032d3:	6a 00                	push   $0x0
  pushl $243
c01032d5:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01032da:	e9 f3 f5 ff ff       	jmp    c01028d2 <__alltraps>

c01032df <vector244>:
.globl vector244
vector244:
  pushl $0
c01032df:	6a 00                	push   $0x0
  pushl $244
c01032e1:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01032e6:	e9 e7 f5 ff ff       	jmp    c01028d2 <__alltraps>

c01032eb <vector245>:
.globl vector245
vector245:
  pushl $0
c01032eb:	6a 00                	push   $0x0
  pushl $245
c01032ed:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01032f2:	e9 db f5 ff ff       	jmp    c01028d2 <__alltraps>

c01032f7 <vector246>:
.globl vector246
vector246:
  pushl $0
c01032f7:	6a 00                	push   $0x0
  pushl $246
c01032f9:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01032fe:	e9 cf f5 ff ff       	jmp    c01028d2 <__alltraps>

c0103303 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103303:	6a 00                	push   $0x0
  pushl $247
c0103305:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010330a:	e9 c3 f5 ff ff       	jmp    c01028d2 <__alltraps>

c010330f <vector248>:
.globl vector248
vector248:
  pushl $0
c010330f:	6a 00                	push   $0x0
  pushl $248
c0103311:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103316:	e9 b7 f5 ff ff       	jmp    c01028d2 <__alltraps>

c010331b <vector249>:
.globl vector249
vector249:
  pushl $0
c010331b:	6a 00                	push   $0x0
  pushl $249
c010331d:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103322:	e9 ab f5 ff ff       	jmp    c01028d2 <__alltraps>

c0103327 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103327:	6a 00                	push   $0x0
  pushl $250
c0103329:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010332e:	e9 9f f5 ff ff       	jmp    c01028d2 <__alltraps>

c0103333 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103333:	6a 00                	push   $0x0
  pushl $251
c0103335:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010333a:	e9 93 f5 ff ff       	jmp    c01028d2 <__alltraps>

c010333f <vector252>:
.globl vector252
vector252:
  pushl $0
c010333f:	6a 00                	push   $0x0
  pushl $252
c0103341:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103346:	e9 87 f5 ff ff       	jmp    c01028d2 <__alltraps>

c010334b <vector253>:
.globl vector253
vector253:
  pushl $0
c010334b:	6a 00                	push   $0x0
  pushl $253
c010334d:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103352:	e9 7b f5 ff ff       	jmp    c01028d2 <__alltraps>

c0103357 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103357:	6a 00                	push   $0x0
  pushl $254
c0103359:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010335e:	e9 6f f5 ff ff       	jmp    c01028d2 <__alltraps>

c0103363 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103363:	6a 00                	push   $0x0
  pushl $255
c0103365:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010336a:	e9 63 f5 ff ff       	jmp    c01028d2 <__alltraps>

c010336f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010336f:	55                   	push   %ebp
c0103370:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103372:	8b 55 08             	mov    0x8(%ebp),%edx
c0103375:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c010337a:	29 c2                	sub    %eax,%edx
c010337c:	89 d0                	mov    %edx,%eax
c010337e:	c1 f8 05             	sar    $0x5,%eax
}
c0103381:	5d                   	pop    %ebp
c0103382:	c3                   	ret    

c0103383 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103383:	55                   	push   %ebp
c0103384:	89 e5                	mov    %esp,%ebp
c0103386:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103389:	8b 45 08             	mov    0x8(%ebp),%eax
c010338c:	89 04 24             	mov    %eax,(%esp)
c010338f:	e8 db ff ff ff       	call   c010336f <page2ppn>
c0103394:	c1 e0 0c             	shl    $0xc,%eax
}
c0103397:	c9                   	leave  
c0103398:	c3                   	ret    

c0103399 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103399:	55                   	push   %ebp
c010339a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010339c:	8b 45 08             	mov    0x8(%ebp),%eax
c010339f:	8b 00                	mov    (%eax),%eax
}
c01033a1:	5d                   	pop    %ebp
c01033a2:	c3                   	ret    

c01033a3 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01033a3:	55                   	push   %ebp
c01033a4:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01033a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01033a9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01033ac:	89 10                	mov    %edx,(%eax)
}
c01033ae:	5d                   	pop    %ebp
c01033af:	c3                   	ret    

c01033b0 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01033b0:	55                   	push   %ebp
c01033b1:	89 e5                	mov    %esp,%ebp
c01033b3:	83 ec 10             	sub    $0x10,%esp
c01033b6:	c7 45 fc d0 a0 12 c0 	movl   $0xc012a0d0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01033bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033c0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01033c3:	89 50 04             	mov    %edx,0x4(%eax)
c01033c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033c9:	8b 50 04             	mov    0x4(%eax),%edx
c01033cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033cf:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01033d1:	c7 05 d8 a0 12 c0 00 	movl   $0x0,0xc012a0d8
c01033d8:	00 00 00 
}
c01033db:	c9                   	leave  
c01033dc:	c3                   	ret    

c01033dd <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01033dd:	55                   	push   %ebp
c01033de:	89 e5                	mov    %esp,%ebp
c01033e0:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01033e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01033e7:	75 24                	jne    c010340d <default_init_memmap+0x30>
c01033e9:	c7 44 24 0c 90 a8 10 	movl   $0xc010a890,0xc(%esp)
c01033f0:	c0 
c01033f1:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01033f8:	c0 
c01033f9:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103400:	00 
c0103401:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103408:	e8 e6 d8 ff ff       	call   c0100cf3 <__panic>
    struct Page *p = base;
c010340d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103410:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103413:	eb 7d                	jmp    c0103492 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0103415:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103418:	83 c0 04             	add    $0x4,%eax
c010341b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103422:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103425:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103428:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010342b:	0f a3 10             	bt     %edx,(%eax)
c010342e:	19 c0                	sbb    %eax,%eax
c0103430:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103433:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103437:	0f 95 c0             	setne  %al
c010343a:	0f b6 c0             	movzbl %al,%eax
c010343d:	85 c0                	test   %eax,%eax
c010343f:	75 24                	jne    c0103465 <default_init_memmap+0x88>
c0103441:	c7 44 24 0c c1 a8 10 	movl   $0xc010a8c1,0xc(%esp)
c0103448:	c0 
c0103449:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103450:	c0 
c0103451:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103458:	00 
c0103459:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103460:	e8 8e d8 ff ff       	call   c0100cf3 <__panic>
        p->flags = p->property = 0;
c0103465:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103468:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010346f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103472:	8b 50 08             	mov    0x8(%eax),%edx
c0103475:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103478:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010347b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103482:	00 
c0103483:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103486:	89 04 24             	mov    %eax,(%esp)
c0103489:	e8 15 ff ff ff       	call   c01033a3 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010348e:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103492:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103495:	c1 e0 05             	shl    $0x5,%eax
c0103498:	89 c2                	mov    %eax,%edx
c010349a:	8b 45 08             	mov    0x8(%ebp),%eax
c010349d:	01 d0                	add    %edx,%eax
c010349f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01034a2:	0f 85 6d ff ff ff    	jne    c0103415 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01034a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01034ab:	8b 55 0c             	mov    0xc(%ebp),%edx
c01034ae:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01034b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01034b4:	83 c0 04             	add    $0x4,%eax
c01034b7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01034be:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01034c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01034c7:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01034ca:	8b 15 d8 a0 12 c0    	mov    0xc012a0d8,%edx
c01034d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034d3:	01 d0                	add    %edx,%eax
c01034d5:	a3 d8 a0 12 c0       	mov    %eax,0xc012a0d8
    list_add_before(&free_list, &(base->page_link));
c01034da:	8b 45 08             	mov    0x8(%ebp),%eax
c01034dd:	83 c0 0c             	add    $0xc,%eax
c01034e0:	c7 45 dc d0 a0 12 c0 	movl   $0xc012a0d0,-0x24(%ebp)
c01034e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01034ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01034ed:	8b 00                	mov    (%eax),%eax
c01034ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01034f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01034f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01034f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01034fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01034fe:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103501:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103504:	89 10                	mov    %edx,(%eax)
c0103506:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103509:	8b 10                	mov    (%eax),%edx
c010350b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010350e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103511:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103514:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103517:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010351a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010351d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103520:	89 10                	mov    %edx,(%eax)
}
c0103522:	c9                   	leave  
c0103523:	c3                   	ret    

c0103524 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0103524:	55                   	push   %ebp
c0103525:	89 e5                	mov    %esp,%ebp
c0103527:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010352a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010352e:	75 24                	jne    c0103554 <default_alloc_pages+0x30>
c0103530:	c7 44 24 0c 90 a8 10 	movl   $0xc010a890,0xc(%esp)
c0103537:	c0 
c0103538:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010353f:	c0 
c0103540:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0103547:	00 
c0103548:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010354f:	e8 9f d7 ff ff       	call   c0100cf3 <__panic>
    if (n > nr_free) {
c0103554:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c0103559:	3b 45 08             	cmp    0x8(%ebp),%eax
c010355c:	73 0a                	jae    c0103568 <default_alloc_pages+0x44>
        return NULL;
c010355e:	b8 00 00 00 00       	mov    $0x0,%eax
c0103563:	e9 36 01 00 00       	jmp    c010369e <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c0103568:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010356f:	c7 45 f0 d0 a0 12 c0 	movl   $0xc012a0d0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103576:	eb 1c                	jmp    c0103594 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103578:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010357b:	83 e8 0c             	sub    $0xc,%eax
c010357e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0103581:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103584:	8b 40 08             	mov    0x8(%eax),%eax
c0103587:	3b 45 08             	cmp    0x8(%ebp),%eax
c010358a:	72 08                	jb     c0103594 <default_alloc_pages+0x70>
            page = p;
c010358c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010358f:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0103592:	eb 18                	jmp    c01035ac <default_alloc_pages+0x88>
c0103594:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103597:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010359a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010359d:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01035a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01035a3:	81 7d f0 d0 a0 12 c0 	cmpl   $0xc012a0d0,-0x10(%ebp)
c01035aa:	75 cc                	jne    c0103578 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c01035ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035b0:	0f 84 e5 00 00 00    	je     c010369b <default_alloc_pages+0x177>
        if (page->property > n) {
c01035b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035b9:	8b 40 08             	mov    0x8(%eax),%eax
c01035bc:	3b 45 08             	cmp    0x8(%ebp),%eax
c01035bf:	0f 86 85 00 00 00    	jbe    c010364a <default_alloc_pages+0x126>
            struct Page *p = page + n;
c01035c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c8:	c1 e0 05             	shl    $0x5,%eax
c01035cb:	89 c2                	mov    %eax,%edx
c01035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035d0:	01 d0                	add    %edx,%eax
c01035d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
			SetPageProperty(p);
c01035d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035d8:	83 c0 04             	add    $0x4,%eax
c01035db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01035e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01035e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01035e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01035eb:	0f ab 10             	bts    %edx,(%eax)
            p->property = page->property - n;
c01035ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035f1:	8b 40 08             	mov    0x8(%eax),%eax
c01035f4:	2b 45 08             	sub    0x8(%ebp),%eax
c01035f7:	89 c2                	mov    %eax,%edx
c01035f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035fc:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c01035ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103602:	83 c0 0c             	add    $0xc,%eax
c0103605:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103608:	83 c2 0c             	add    $0xc,%edx
c010360b:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010360e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103611:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103614:	8b 40 04             	mov    0x4(%eax),%eax
c0103617:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010361a:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010361d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103620:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103623:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103626:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103629:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010362c:	89 10                	mov    %edx,(%eax)
c010362e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103631:	8b 10                	mov    (%eax),%edx
c0103633:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103636:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103639:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010363c:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010363f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103642:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103645:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103648:	89 10                	mov    %edx,(%eax)
    }
	list_del(&(page->page_link));
c010364a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010364d:	83 c0 0c             	add    $0xc,%eax
c0103650:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103653:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103656:	8b 40 04             	mov    0x4(%eax),%eax
c0103659:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010365c:	8b 12                	mov    (%edx),%edx
c010365e:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0103661:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103664:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103667:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010366a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010366d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103670:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103673:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0103675:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c010367a:	2b 45 08             	sub    0x8(%ebp),%eax
c010367d:	a3 d8 a0 12 c0       	mov    %eax,0xc012a0d8
        ClearPageProperty(page);
c0103682:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103685:	83 c0 04             	add    $0x4,%eax
c0103688:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010368f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103692:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103695:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103698:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c010369b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010369e:	c9                   	leave  
c010369f:	c3                   	ret    

c01036a0 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01036a0:	55                   	push   %ebp
c01036a1:	89 e5                	mov    %esp,%ebp
c01036a3:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01036a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01036ad:	75 24                	jne    c01036d3 <default_free_pages+0x33>
c01036af:	c7 44 24 0c 90 a8 10 	movl   $0xc010a890,0xc(%esp)
c01036b6:	c0 
c01036b7:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01036be:	c0 
c01036bf:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c01036c6:	00 
c01036c7:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c01036ce:	e8 20 d6 ff ff       	call   c0100cf3 <__panic>
    struct Page *p = base;
c01036d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01036d9:	e9 9d 00 00 00       	jmp    c010377b <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01036de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036e1:	83 c0 04             	add    $0x4,%eax
c01036e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01036eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01036f4:	0f a3 10             	bt     %edx,(%eax)
c01036f7:	19 c0                	sbb    %eax,%eax
c01036f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01036fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103700:	0f 95 c0             	setne  %al
c0103703:	0f b6 c0             	movzbl %al,%eax
c0103706:	85 c0                	test   %eax,%eax
c0103708:	75 2c                	jne    c0103736 <default_free_pages+0x96>
c010370a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010370d:	83 c0 04             	add    $0x4,%eax
c0103710:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0103717:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010371a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010371d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103720:	0f a3 10             	bt     %edx,(%eax)
c0103723:	19 c0                	sbb    %eax,%eax
c0103725:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0103728:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010372c:	0f 95 c0             	setne  %al
c010372f:	0f b6 c0             	movzbl %al,%eax
c0103732:	85 c0                	test   %eax,%eax
c0103734:	74 24                	je     c010375a <default_free_pages+0xba>
c0103736:	c7 44 24 0c d4 a8 10 	movl   $0xc010a8d4,0xc(%esp)
c010373d:	c0 
c010373e:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103745:	c0 
c0103746:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010374d:	00 
c010374e:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103755:	e8 99 d5 ff ff       	call   c0100cf3 <__panic>
        p->flags = 0;
c010375a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010375d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103764:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010376b:	00 
c010376c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010376f:	89 04 24             	mov    %eax,(%esp)
c0103772:	e8 2c fc ff ff       	call   c01033a3 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103777:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010377b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010377e:	c1 e0 05             	shl    $0x5,%eax
c0103781:	89 c2                	mov    %eax,%edx
c0103783:	8b 45 08             	mov    0x8(%ebp),%eax
c0103786:	01 d0                	add    %edx,%eax
c0103788:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010378b:	0f 85 4d ff ff ff    	jne    c01036de <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103791:	8b 45 08             	mov    0x8(%ebp),%eax
c0103794:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103797:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010379a:	8b 45 08             	mov    0x8(%ebp),%eax
c010379d:	83 c0 04             	add    $0x4,%eax
c01037a0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01037a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01037ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01037b0:	0f ab 10             	bts    %edx,(%eax)
c01037b3:	c7 45 cc d0 a0 12 c0 	movl   $0xc012a0d0,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01037ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01037bd:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01037c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01037c3:	e9 fa 00 00 00       	jmp    c01038c2 <default_free_pages+0x222>
        p = le2page(le, page_link);
c01037c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037cb:	83 e8 0c             	sub    $0xc,%eax
c01037ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01037d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037d4:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01037d7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01037da:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01037dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c01037e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e3:	8b 40 08             	mov    0x8(%eax),%eax
c01037e6:	c1 e0 05             	shl    $0x5,%eax
c01037e9:	89 c2                	mov    %eax,%edx
c01037eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01037ee:	01 d0                	add    %edx,%eax
c01037f0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01037f3:	75 5a                	jne    c010384f <default_free_pages+0x1af>
            base->property += p->property;
c01037f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01037f8:	8b 50 08             	mov    0x8(%eax),%edx
c01037fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037fe:	8b 40 08             	mov    0x8(%eax),%eax
c0103801:	01 c2                	add    %eax,%edx
c0103803:	8b 45 08             	mov    0x8(%ebp),%eax
c0103806:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103809:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010380c:	83 c0 04             	add    $0x4,%eax
c010380f:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103816:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103819:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010381c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010381f:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0103822:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103825:	83 c0 0c             	add    $0xc,%eax
c0103828:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010382b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010382e:	8b 40 04             	mov    0x4(%eax),%eax
c0103831:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103834:	8b 12                	mov    (%edx),%edx
c0103836:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0103839:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010383c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010383f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103842:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103845:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103848:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010384b:	89 10                	mov    %edx,(%eax)
c010384d:	eb 73                	jmp    c01038c2 <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c010384f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103852:	8b 40 08             	mov    0x8(%eax),%eax
c0103855:	c1 e0 05             	shl    $0x5,%eax
c0103858:	89 c2                	mov    %eax,%edx
c010385a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010385d:	01 d0                	add    %edx,%eax
c010385f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103862:	75 5e                	jne    c01038c2 <default_free_pages+0x222>
            p->property += base->property;
c0103864:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103867:	8b 50 08             	mov    0x8(%eax),%edx
c010386a:	8b 45 08             	mov    0x8(%ebp),%eax
c010386d:	8b 40 08             	mov    0x8(%eax),%eax
c0103870:	01 c2                	add    %eax,%edx
c0103872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103875:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103878:	8b 45 08             	mov    0x8(%ebp),%eax
c010387b:	83 c0 04             	add    $0x4,%eax
c010387e:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0103885:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103888:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010388b:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010388e:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0103891:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103894:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103897:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389a:	83 c0 0c             	add    $0xc,%eax
c010389d:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01038a0:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01038a3:	8b 40 04             	mov    0x4(%eax),%eax
c01038a6:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01038a9:	8b 12                	mov    (%edx),%edx
c01038ab:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01038ae:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01038b1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01038b4:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01038b7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01038ba:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01038bd:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01038c0:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c01038c2:	81 7d f0 d0 a0 12 c0 	cmpl   $0xc012a0d0,-0x10(%ebp)
c01038c9:	0f 85 f9 fe ff ff    	jne    c01037c8 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c01038cf:	8b 15 d8 a0 12 c0    	mov    0xc012a0d8,%edx
c01038d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038d8:	01 d0                	add    %edx,%eax
c01038da:	a3 d8 a0 12 c0       	mov    %eax,0xc012a0d8
c01038df:	c7 45 9c d0 a0 12 c0 	movl   $0xc012a0d0,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01038e6:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01038e9:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c01038ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01038ef:	eb 68                	jmp    c0103959 <default_free_pages+0x2b9>
        p = le2page(le, page_link);
c01038f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038f4:	83 e8 0c             	sub    $0xc,%eax
c01038f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c01038fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01038fd:	8b 40 08             	mov    0x8(%eax),%eax
c0103900:	c1 e0 05             	shl    $0x5,%eax
c0103903:	89 c2                	mov    %eax,%edx
c0103905:	8b 45 08             	mov    0x8(%ebp),%eax
c0103908:	01 d0                	add    %edx,%eax
c010390a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010390d:	77 3b                	ja     c010394a <default_free_pages+0x2aa>
            assert(base + base->property != p);
c010390f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103912:	8b 40 08             	mov    0x8(%eax),%eax
c0103915:	c1 e0 05             	shl    $0x5,%eax
c0103918:	89 c2                	mov    %eax,%edx
c010391a:	8b 45 08             	mov    0x8(%ebp),%eax
c010391d:	01 d0                	add    %edx,%eax
c010391f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103922:	75 24                	jne    c0103948 <default_free_pages+0x2a8>
c0103924:	c7 44 24 0c f9 a8 10 	movl   $0xc010a8f9,0xc(%esp)
c010392b:	c0 
c010392c:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103933:	c0 
c0103934:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c010393b:	00 
c010393c:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103943:	e8 ab d3 ff ff       	call   c0100cf3 <__panic>
            break;
c0103948:	eb 18                	jmp    c0103962 <default_free_pages+0x2c2>
c010394a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010394d:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103950:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103953:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0103956:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0103959:	81 7d f0 d0 a0 12 c0 	cmpl   $0xc012a0d0,-0x10(%ebp)
c0103960:	75 8f                	jne    c01038f1 <default_free_pages+0x251>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0103962:	8b 45 08             	mov    0x8(%ebp),%eax
c0103965:	8d 50 0c             	lea    0xc(%eax),%edx
c0103968:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010396b:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010396e:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103971:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103974:	8b 00                	mov    (%eax),%eax
c0103976:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103979:	89 55 8c             	mov    %edx,-0x74(%ebp)
c010397c:	89 45 88             	mov    %eax,-0x78(%ebp)
c010397f:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103982:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103985:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103988:	8b 55 8c             	mov    -0x74(%ebp),%edx
c010398b:	89 10                	mov    %edx,(%eax)
c010398d:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103990:	8b 10                	mov    (%eax),%edx
c0103992:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103995:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103998:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010399b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010399e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01039a1:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01039a4:	8b 55 88             	mov    -0x78(%ebp),%edx
c01039a7:	89 10                	mov    %edx,(%eax)
}
c01039a9:	c9                   	leave  
c01039aa:	c3                   	ret    

c01039ab <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01039ab:	55                   	push   %ebp
c01039ac:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01039ae:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
}
c01039b3:	5d                   	pop    %ebp
c01039b4:	c3                   	ret    

c01039b5 <basic_check>:

static void
basic_check(void) {
c01039b5:	55                   	push   %ebp
c01039b6:	89 e5                	mov    %esp,%ebp
c01039b8:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01039bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01039c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01039ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039d5:	e8 dc 15 00 00       	call   c0104fb6 <alloc_pages>
c01039da:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01039e1:	75 24                	jne    c0103a07 <basic_check+0x52>
c01039e3:	c7 44 24 0c 14 a9 10 	movl   $0xc010a914,0xc(%esp)
c01039ea:	c0 
c01039eb:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01039f2:	c0 
c01039f3:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01039fa:	00 
c01039fb:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103a02:	e8 ec d2 ff ff       	call   c0100cf3 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103a07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a0e:	e8 a3 15 00 00       	call   c0104fb6 <alloc_pages>
c0103a13:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a1a:	75 24                	jne    c0103a40 <basic_check+0x8b>
c0103a1c:	c7 44 24 0c 30 a9 10 	movl   $0xc010a930,0xc(%esp)
c0103a23:	c0 
c0103a24:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103a2b:	c0 
c0103a2c:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103a33:	00 
c0103a34:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103a3b:	e8 b3 d2 ff ff       	call   c0100cf3 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103a40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a47:	e8 6a 15 00 00       	call   c0104fb6 <alloc_pages>
c0103a4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a53:	75 24                	jne    c0103a79 <basic_check+0xc4>
c0103a55:	c7 44 24 0c 4c a9 10 	movl   $0xc010a94c,0xc(%esp)
c0103a5c:	c0 
c0103a5d:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103a64:	c0 
c0103a65:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0103a6c:	00 
c0103a6d:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103a74:	e8 7a d2 ff ff       	call   c0100cf3 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103a79:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a7c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103a7f:	74 10                	je     c0103a91 <basic_check+0xdc>
c0103a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a84:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a87:	74 08                	je     c0103a91 <basic_check+0xdc>
c0103a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a8c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a8f:	75 24                	jne    c0103ab5 <basic_check+0x100>
c0103a91:	c7 44 24 0c 68 a9 10 	movl   $0xc010a968,0xc(%esp)
c0103a98:	c0 
c0103a99:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103aa0:	c0 
c0103aa1:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103aa8:	00 
c0103aa9:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103ab0:	e8 3e d2 ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ab8:	89 04 24             	mov    %eax,(%esp)
c0103abb:	e8 d9 f8 ff ff       	call   c0103399 <page_ref>
c0103ac0:	85 c0                	test   %eax,%eax
c0103ac2:	75 1e                	jne    c0103ae2 <basic_check+0x12d>
c0103ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ac7:	89 04 24             	mov    %eax,(%esp)
c0103aca:	e8 ca f8 ff ff       	call   c0103399 <page_ref>
c0103acf:	85 c0                	test   %eax,%eax
c0103ad1:	75 0f                	jne    c0103ae2 <basic_check+0x12d>
c0103ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad6:	89 04 24             	mov    %eax,(%esp)
c0103ad9:	e8 bb f8 ff ff       	call   c0103399 <page_ref>
c0103ade:	85 c0                	test   %eax,%eax
c0103ae0:	74 24                	je     c0103b06 <basic_check+0x151>
c0103ae2:	c7 44 24 0c 8c a9 10 	movl   $0xc010a98c,0xc(%esp)
c0103ae9:	c0 
c0103aea:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103af1:	c0 
c0103af2:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103af9:	00 
c0103afa:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103b01:	e8 ed d1 ff ff       	call   c0100cf3 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103b06:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b09:	89 04 24             	mov    %eax,(%esp)
c0103b0c:	e8 72 f8 ff ff       	call   c0103383 <page2pa>
c0103b11:	8b 15 a0 7f 12 c0    	mov    0xc0127fa0,%edx
c0103b17:	c1 e2 0c             	shl    $0xc,%edx
c0103b1a:	39 d0                	cmp    %edx,%eax
c0103b1c:	72 24                	jb     c0103b42 <basic_check+0x18d>
c0103b1e:	c7 44 24 0c c8 a9 10 	movl   $0xc010a9c8,0xc(%esp)
c0103b25:	c0 
c0103b26:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103b2d:	c0 
c0103b2e:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103b35:	00 
c0103b36:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103b3d:	e8 b1 d1 ff ff       	call   c0100cf3 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b45:	89 04 24             	mov    %eax,(%esp)
c0103b48:	e8 36 f8 ff ff       	call   c0103383 <page2pa>
c0103b4d:	8b 15 a0 7f 12 c0    	mov    0xc0127fa0,%edx
c0103b53:	c1 e2 0c             	shl    $0xc,%edx
c0103b56:	39 d0                	cmp    %edx,%eax
c0103b58:	72 24                	jb     c0103b7e <basic_check+0x1c9>
c0103b5a:	c7 44 24 0c e5 a9 10 	movl   $0xc010a9e5,0xc(%esp)
c0103b61:	c0 
c0103b62:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103b69:	c0 
c0103b6a:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103b71:	00 
c0103b72:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103b79:	e8 75 d1 ff ff       	call   c0100cf3 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b81:	89 04 24             	mov    %eax,(%esp)
c0103b84:	e8 fa f7 ff ff       	call   c0103383 <page2pa>
c0103b89:	8b 15 a0 7f 12 c0    	mov    0xc0127fa0,%edx
c0103b8f:	c1 e2 0c             	shl    $0xc,%edx
c0103b92:	39 d0                	cmp    %edx,%eax
c0103b94:	72 24                	jb     c0103bba <basic_check+0x205>
c0103b96:	c7 44 24 0c 02 aa 10 	movl   $0xc010aa02,0xc(%esp)
c0103b9d:	c0 
c0103b9e:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103ba5:	c0 
c0103ba6:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103bad:	00 
c0103bae:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103bb5:	e8 39 d1 ff ff       	call   c0100cf3 <__panic>

    list_entry_t free_list_store = free_list;
c0103bba:	a1 d0 a0 12 c0       	mov    0xc012a0d0,%eax
c0103bbf:	8b 15 d4 a0 12 c0    	mov    0xc012a0d4,%edx
c0103bc5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103bc8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103bcb:	c7 45 e0 d0 a0 12 c0 	movl   $0xc012a0d0,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103bd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103bd8:	89 50 04             	mov    %edx,0x4(%eax)
c0103bdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bde:	8b 50 04             	mov    0x4(%eax),%edx
c0103be1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103be4:	89 10                	mov    %edx,(%eax)
c0103be6:	c7 45 dc d0 a0 12 c0 	movl   $0xc012a0d0,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103bed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103bf0:	8b 40 04             	mov    0x4(%eax),%eax
c0103bf3:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103bf6:	0f 94 c0             	sete   %al
c0103bf9:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103bfc:	85 c0                	test   %eax,%eax
c0103bfe:	75 24                	jne    c0103c24 <basic_check+0x26f>
c0103c00:	c7 44 24 0c 1f aa 10 	movl   $0xc010aa1f,0xc(%esp)
c0103c07:	c0 
c0103c08:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103c0f:	c0 
c0103c10:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103c17:	00 
c0103c18:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103c1f:	e8 cf d0 ff ff       	call   c0100cf3 <__panic>

    unsigned int nr_free_store = nr_free;
c0103c24:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c0103c29:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103c2c:	c7 05 d8 a0 12 c0 00 	movl   $0x0,0xc012a0d8
c0103c33:	00 00 00 

    assert(alloc_page() == NULL);
c0103c36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c3d:	e8 74 13 00 00       	call   c0104fb6 <alloc_pages>
c0103c42:	85 c0                	test   %eax,%eax
c0103c44:	74 24                	je     c0103c6a <basic_check+0x2b5>
c0103c46:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c0103c4d:	c0 
c0103c4e:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103c55:	c0 
c0103c56:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103c5d:	00 
c0103c5e:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103c65:	e8 89 d0 ff ff       	call   c0100cf3 <__panic>

    free_page(p0);
c0103c6a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c71:	00 
c0103c72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c75:	89 04 24             	mov    %eax,(%esp)
c0103c78:	e8 a4 13 00 00       	call   c0105021 <free_pages>
    free_page(p1);
c0103c7d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c84:	00 
c0103c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c88:	89 04 24             	mov    %eax,(%esp)
c0103c8b:	e8 91 13 00 00       	call   c0105021 <free_pages>
    free_page(p2);
c0103c90:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c97:	00 
c0103c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c9b:	89 04 24             	mov    %eax,(%esp)
c0103c9e:	e8 7e 13 00 00       	call   c0105021 <free_pages>
    assert(nr_free == 3);
c0103ca3:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c0103ca8:	83 f8 03             	cmp    $0x3,%eax
c0103cab:	74 24                	je     c0103cd1 <basic_check+0x31c>
c0103cad:	c7 44 24 0c 4b aa 10 	movl   $0xc010aa4b,0xc(%esp)
c0103cb4:	c0 
c0103cb5:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103cbc:	c0 
c0103cbd:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103cc4:	00 
c0103cc5:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103ccc:	e8 22 d0 ff ff       	call   c0100cf3 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103cd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cd8:	e8 d9 12 00 00       	call   c0104fb6 <alloc_pages>
c0103cdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103ce0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103ce4:	75 24                	jne    c0103d0a <basic_check+0x355>
c0103ce6:	c7 44 24 0c 14 a9 10 	movl   $0xc010a914,0xc(%esp)
c0103ced:	c0 
c0103cee:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103cf5:	c0 
c0103cf6:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103cfd:	00 
c0103cfe:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103d05:	e8 e9 cf ff ff       	call   c0100cf3 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103d0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d11:	e8 a0 12 00 00       	call   c0104fb6 <alloc_pages>
c0103d16:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d1d:	75 24                	jne    c0103d43 <basic_check+0x38e>
c0103d1f:	c7 44 24 0c 30 a9 10 	movl   $0xc010a930,0xc(%esp)
c0103d26:	c0 
c0103d27:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103d2e:	c0 
c0103d2f:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103d36:	00 
c0103d37:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103d3e:	e8 b0 cf ff ff       	call   c0100cf3 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103d43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d4a:	e8 67 12 00 00       	call   c0104fb6 <alloc_pages>
c0103d4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d56:	75 24                	jne    c0103d7c <basic_check+0x3c7>
c0103d58:	c7 44 24 0c 4c a9 10 	movl   $0xc010a94c,0xc(%esp)
c0103d5f:	c0 
c0103d60:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103d67:	c0 
c0103d68:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103d6f:	00 
c0103d70:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103d77:	e8 77 cf ff ff       	call   c0100cf3 <__panic>

    assert(alloc_page() == NULL);
c0103d7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d83:	e8 2e 12 00 00       	call   c0104fb6 <alloc_pages>
c0103d88:	85 c0                	test   %eax,%eax
c0103d8a:	74 24                	je     c0103db0 <basic_check+0x3fb>
c0103d8c:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c0103d93:	c0 
c0103d94:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103d9b:	c0 
c0103d9c:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0103da3:	00 
c0103da4:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103dab:	e8 43 cf ff ff       	call   c0100cf3 <__panic>

    free_page(p0);
c0103db0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103db7:	00 
c0103db8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dbb:	89 04 24             	mov    %eax,(%esp)
c0103dbe:	e8 5e 12 00 00       	call   c0105021 <free_pages>
c0103dc3:	c7 45 d8 d0 a0 12 c0 	movl   $0xc012a0d0,-0x28(%ebp)
c0103dca:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103dcd:	8b 40 04             	mov    0x4(%eax),%eax
c0103dd0:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103dd3:	0f 94 c0             	sete   %al
c0103dd6:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103dd9:	85 c0                	test   %eax,%eax
c0103ddb:	74 24                	je     c0103e01 <basic_check+0x44c>
c0103ddd:	c7 44 24 0c 58 aa 10 	movl   $0xc010aa58,0xc(%esp)
c0103de4:	c0 
c0103de5:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103dec:	c0 
c0103ded:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0103df4:	00 
c0103df5:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103dfc:	e8 f2 ce ff ff       	call   c0100cf3 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103e01:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e08:	e8 a9 11 00 00       	call   c0104fb6 <alloc_pages>
c0103e0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e13:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103e16:	74 24                	je     c0103e3c <basic_check+0x487>
c0103e18:	c7 44 24 0c 70 aa 10 	movl   $0xc010aa70,0xc(%esp)
c0103e1f:	c0 
c0103e20:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103e27:	c0 
c0103e28:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0103e2f:	00 
c0103e30:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103e37:	e8 b7 ce ff ff       	call   c0100cf3 <__panic>
    assert(alloc_page() == NULL);
c0103e3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e43:	e8 6e 11 00 00       	call   c0104fb6 <alloc_pages>
c0103e48:	85 c0                	test   %eax,%eax
c0103e4a:	74 24                	je     c0103e70 <basic_check+0x4bb>
c0103e4c:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c0103e53:	c0 
c0103e54:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103e5b:	c0 
c0103e5c:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103e63:	00 
c0103e64:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103e6b:	e8 83 ce ff ff       	call   c0100cf3 <__panic>

    assert(nr_free == 0);
c0103e70:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c0103e75:	85 c0                	test   %eax,%eax
c0103e77:	74 24                	je     c0103e9d <basic_check+0x4e8>
c0103e79:	c7 44 24 0c 89 aa 10 	movl   $0xc010aa89,0xc(%esp)
c0103e80:	c0 
c0103e81:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103e88:	c0 
c0103e89:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0103e90:	00 
c0103e91:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103e98:	e8 56 ce ff ff       	call   c0100cf3 <__panic>
    free_list = free_list_store;
c0103e9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103ea0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103ea3:	a3 d0 a0 12 c0       	mov    %eax,0xc012a0d0
c0103ea8:	89 15 d4 a0 12 c0    	mov    %edx,0xc012a0d4
    nr_free = nr_free_store;
c0103eae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103eb1:	a3 d8 a0 12 c0       	mov    %eax,0xc012a0d8

    free_page(p);
c0103eb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ebd:	00 
c0103ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ec1:	89 04 24             	mov    %eax,(%esp)
c0103ec4:	e8 58 11 00 00       	call   c0105021 <free_pages>
    free_page(p1);
c0103ec9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ed0:	00 
c0103ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ed4:	89 04 24             	mov    %eax,(%esp)
c0103ed7:	e8 45 11 00 00       	call   c0105021 <free_pages>
    free_page(p2);
c0103edc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ee3:	00 
c0103ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ee7:	89 04 24             	mov    %eax,(%esp)
c0103eea:	e8 32 11 00 00       	call   c0105021 <free_pages>
}
c0103eef:	c9                   	leave  
c0103ef0:	c3                   	ret    

c0103ef1 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103ef1:	55                   	push   %ebp
c0103ef2:	89 e5                	mov    %esp,%ebp
c0103ef4:	53                   	push   %ebx
c0103ef5:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103efb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f02:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103f09:	c7 45 ec d0 a0 12 c0 	movl   $0xc012a0d0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103f10:	eb 6b                	jmp    c0103f7d <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103f12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f15:	83 e8 0c             	sub    $0xc,%eax
c0103f18:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103f1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f1e:	83 c0 04             	add    $0x4,%eax
c0103f21:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103f28:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f2b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103f2e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103f31:	0f a3 10             	bt     %edx,(%eax)
c0103f34:	19 c0                	sbb    %eax,%eax
c0103f36:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103f39:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103f3d:	0f 95 c0             	setne  %al
c0103f40:	0f b6 c0             	movzbl %al,%eax
c0103f43:	85 c0                	test   %eax,%eax
c0103f45:	75 24                	jne    c0103f6b <default_check+0x7a>
c0103f47:	c7 44 24 0c 96 aa 10 	movl   $0xc010aa96,0xc(%esp)
c0103f4e:	c0 
c0103f4f:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103f56:	c0 
c0103f57:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103f5e:	00 
c0103f5f:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103f66:	e8 88 cd ff ff       	call   c0100cf3 <__panic>
        count ++, total += p->property;
c0103f6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103f6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f72:	8b 50 08             	mov    0x8(%eax),%edx
c0103f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f78:	01 d0                	add    %edx,%eax
c0103f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f80:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103f83:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103f86:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103f89:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f8c:	81 7d ec d0 a0 12 c0 	cmpl   $0xc012a0d0,-0x14(%ebp)
c0103f93:	0f 85 79 ff ff ff    	jne    c0103f12 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103f99:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0103f9c:	e8 b2 10 00 00       	call   c0105053 <nr_free_pages>
c0103fa1:	39 c3                	cmp    %eax,%ebx
c0103fa3:	74 24                	je     c0103fc9 <default_check+0xd8>
c0103fa5:	c7 44 24 0c a6 aa 10 	movl   $0xc010aaa6,0xc(%esp)
c0103fac:	c0 
c0103fad:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103fb4:	c0 
c0103fb5:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0103fbc:	00 
c0103fbd:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0103fc4:	e8 2a cd ff ff       	call   c0100cf3 <__panic>

    basic_check();
c0103fc9:	e8 e7 f9 ff ff       	call   c01039b5 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103fce:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103fd5:	e8 dc 0f 00 00       	call   c0104fb6 <alloc_pages>
c0103fda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103fdd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103fe1:	75 24                	jne    c0104007 <default_check+0x116>
c0103fe3:	c7 44 24 0c bf aa 10 	movl   $0xc010aabf,0xc(%esp)
c0103fea:	c0 
c0103feb:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0103ff2:	c0 
c0103ff3:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0103ffa:	00 
c0103ffb:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0104002:	e8 ec cc ff ff       	call   c0100cf3 <__panic>
    assert(!PageProperty(p0));
c0104007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010400a:	83 c0 04             	add    $0x4,%eax
c010400d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104014:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104017:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010401a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010401d:	0f a3 10             	bt     %edx,(%eax)
c0104020:	19 c0                	sbb    %eax,%eax
c0104022:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104025:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104029:	0f 95 c0             	setne  %al
c010402c:	0f b6 c0             	movzbl %al,%eax
c010402f:	85 c0                	test   %eax,%eax
c0104031:	74 24                	je     c0104057 <default_check+0x166>
c0104033:	c7 44 24 0c ca aa 10 	movl   $0xc010aaca,0xc(%esp)
c010403a:	c0 
c010403b:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0104042:	c0 
c0104043:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c010404a:	00 
c010404b:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0104052:	e8 9c cc ff ff       	call   c0100cf3 <__panic>

    list_entry_t free_list_store = free_list;
c0104057:	a1 d0 a0 12 c0       	mov    0xc012a0d0,%eax
c010405c:	8b 15 d4 a0 12 c0    	mov    0xc012a0d4,%edx
c0104062:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104065:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104068:	c7 45 b4 d0 a0 12 c0 	movl   $0xc012a0d0,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010406f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104072:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104075:	89 50 04             	mov    %edx,0x4(%eax)
c0104078:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010407b:	8b 50 04             	mov    0x4(%eax),%edx
c010407e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104081:	89 10                	mov    %edx,(%eax)
c0104083:	c7 45 b0 d0 a0 12 c0 	movl   $0xc012a0d0,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010408a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010408d:	8b 40 04             	mov    0x4(%eax),%eax
c0104090:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104093:	0f 94 c0             	sete   %al
c0104096:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104099:	85 c0                	test   %eax,%eax
c010409b:	75 24                	jne    c01040c1 <default_check+0x1d0>
c010409d:	c7 44 24 0c 1f aa 10 	movl   $0xc010aa1f,0xc(%esp)
c01040a4:	c0 
c01040a5:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01040ac:	c0 
c01040ad:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01040b4:	00 
c01040b5:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c01040bc:	e8 32 cc ff ff       	call   c0100cf3 <__panic>
    assert(alloc_page() == NULL);
c01040c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040c8:	e8 e9 0e 00 00       	call   c0104fb6 <alloc_pages>
c01040cd:	85 c0                	test   %eax,%eax
c01040cf:	74 24                	je     c01040f5 <default_check+0x204>
c01040d1:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c01040d8:	c0 
c01040d9:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01040e0:	c0 
c01040e1:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01040e8:	00 
c01040e9:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c01040f0:	e8 fe cb ff ff       	call   c0100cf3 <__panic>

    unsigned int nr_free_store = nr_free;
c01040f5:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c01040fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01040fd:	c7 05 d8 a0 12 c0 00 	movl   $0x0,0xc012a0d8
c0104104:	00 00 00 

    free_pages(p0 + 2, 3);
c0104107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010410a:	83 c0 40             	add    $0x40,%eax
c010410d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104114:	00 
c0104115:	89 04 24             	mov    %eax,(%esp)
c0104118:	e8 04 0f 00 00       	call   c0105021 <free_pages>
    assert(alloc_pages(4) == NULL);
c010411d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104124:	e8 8d 0e 00 00       	call   c0104fb6 <alloc_pages>
c0104129:	85 c0                	test   %eax,%eax
c010412b:	74 24                	je     c0104151 <default_check+0x260>
c010412d:	c7 44 24 0c dc aa 10 	movl   $0xc010aadc,0xc(%esp)
c0104134:	c0 
c0104135:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010413c:	c0 
c010413d:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0104144:	00 
c0104145:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010414c:	e8 a2 cb ff ff       	call   c0100cf3 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104151:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104154:	83 c0 40             	add    $0x40,%eax
c0104157:	83 c0 04             	add    $0x4,%eax
c010415a:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104161:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104164:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104167:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010416a:	0f a3 10             	bt     %edx,(%eax)
c010416d:	19 c0                	sbb    %eax,%eax
c010416f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104172:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104176:	0f 95 c0             	setne  %al
c0104179:	0f b6 c0             	movzbl %al,%eax
c010417c:	85 c0                	test   %eax,%eax
c010417e:	74 0e                	je     c010418e <default_check+0x29d>
c0104180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104183:	83 c0 40             	add    $0x40,%eax
c0104186:	8b 40 08             	mov    0x8(%eax),%eax
c0104189:	83 f8 03             	cmp    $0x3,%eax
c010418c:	74 24                	je     c01041b2 <default_check+0x2c1>
c010418e:	c7 44 24 0c f4 aa 10 	movl   $0xc010aaf4,0xc(%esp)
c0104195:	c0 
c0104196:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010419d:	c0 
c010419e:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01041a5:	00 
c01041a6:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c01041ad:	e8 41 cb ff ff       	call   c0100cf3 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01041b2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01041b9:	e8 f8 0d 00 00       	call   c0104fb6 <alloc_pages>
c01041be:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01041c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01041c5:	75 24                	jne    c01041eb <default_check+0x2fa>
c01041c7:	c7 44 24 0c 20 ab 10 	movl   $0xc010ab20,0xc(%esp)
c01041ce:	c0 
c01041cf:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01041d6:	c0 
c01041d7:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01041de:	00 
c01041df:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c01041e6:	e8 08 cb ff ff       	call   c0100cf3 <__panic>
    assert(alloc_page() == NULL);
c01041eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01041f2:	e8 bf 0d 00 00       	call   c0104fb6 <alloc_pages>
c01041f7:	85 c0                	test   %eax,%eax
c01041f9:	74 24                	je     c010421f <default_check+0x32e>
c01041fb:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c0104202:	c0 
c0104203:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010420a:	c0 
c010420b:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0104212:	00 
c0104213:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010421a:	e8 d4 ca ff ff       	call   c0100cf3 <__panic>
    assert(p0 + 2 == p1);
c010421f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104222:	83 c0 40             	add    $0x40,%eax
c0104225:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104228:	74 24                	je     c010424e <default_check+0x35d>
c010422a:	c7 44 24 0c 3e ab 10 	movl   $0xc010ab3e,0xc(%esp)
c0104231:	c0 
c0104232:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0104239:	c0 
c010423a:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0104241:	00 
c0104242:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0104249:	e8 a5 ca ff ff       	call   c0100cf3 <__panic>

    p2 = p0 + 1;
c010424e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104251:	83 c0 20             	add    $0x20,%eax
c0104254:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104257:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010425e:	00 
c010425f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104262:	89 04 24             	mov    %eax,(%esp)
c0104265:	e8 b7 0d 00 00       	call   c0105021 <free_pages>
    free_pages(p1, 3);
c010426a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104271:	00 
c0104272:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104275:	89 04 24             	mov    %eax,(%esp)
c0104278:	e8 a4 0d 00 00       	call   c0105021 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010427d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104280:	83 c0 04             	add    $0x4,%eax
c0104283:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010428a:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010428d:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104290:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104293:	0f a3 10             	bt     %edx,(%eax)
c0104296:	19 c0                	sbb    %eax,%eax
c0104298:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010429b:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010429f:	0f 95 c0             	setne  %al
c01042a2:	0f b6 c0             	movzbl %al,%eax
c01042a5:	85 c0                	test   %eax,%eax
c01042a7:	74 0b                	je     c01042b4 <default_check+0x3c3>
c01042a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042ac:	8b 40 08             	mov    0x8(%eax),%eax
c01042af:	83 f8 01             	cmp    $0x1,%eax
c01042b2:	74 24                	je     c01042d8 <default_check+0x3e7>
c01042b4:	c7 44 24 0c 4c ab 10 	movl   $0xc010ab4c,0xc(%esp)
c01042bb:	c0 
c01042bc:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01042c3:	c0 
c01042c4:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01042cb:	00 
c01042cc:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c01042d3:	e8 1b ca ff ff       	call   c0100cf3 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01042d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042db:	83 c0 04             	add    $0x4,%eax
c01042de:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01042e5:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042e8:	8b 45 90             	mov    -0x70(%ebp),%eax
c01042eb:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01042ee:	0f a3 10             	bt     %edx,(%eax)
c01042f1:	19 c0                	sbb    %eax,%eax
c01042f3:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01042f6:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01042fa:	0f 95 c0             	setne  %al
c01042fd:	0f b6 c0             	movzbl %al,%eax
c0104300:	85 c0                	test   %eax,%eax
c0104302:	74 0b                	je     c010430f <default_check+0x41e>
c0104304:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104307:	8b 40 08             	mov    0x8(%eax),%eax
c010430a:	83 f8 03             	cmp    $0x3,%eax
c010430d:	74 24                	je     c0104333 <default_check+0x442>
c010430f:	c7 44 24 0c 74 ab 10 	movl   $0xc010ab74,0xc(%esp)
c0104316:	c0 
c0104317:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010431e:	c0 
c010431f:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0104326:	00 
c0104327:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010432e:	e8 c0 c9 ff ff       	call   c0100cf3 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104333:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010433a:	e8 77 0c 00 00       	call   c0104fb6 <alloc_pages>
c010433f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104342:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104345:	83 e8 20             	sub    $0x20,%eax
c0104348:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010434b:	74 24                	je     c0104371 <default_check+0x480>
c010434d:	c7 44 24 0c 9a ab 10 	movl   $0xc010ab9a,0xc(%esp)
c0104354:	c0 
c0104355:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010435c:	c0 
c010435d:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0104364:	00 
c0104365:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010436c:	e8 82 c9 ff ff       	call   c0100cf3 <__panic>
    free_page(p0);
c0104371:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104378:	00 
c0104379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010437c:	89 04 24             	mov    %eax,(%esp)
c010437f:	e8 9d 0c 00 00       	call   c0105021 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104384:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010438b:	e8 26 0c 00 00       	call   c0104fb6 <alloc_pages>
c0104390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104393:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104396:	83 c0 20             	add    $0x20,%eax
c0104399:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010439c:	74 24                	je     c01043c2 <default_check+0x4d1>
c010439e:	c7 44 24 0c b8 ab 10 	movl   $0xc010abb8,0xc(%esp)
c01043a5:	c0 
c01043a6:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c01043ad:	c0 
c01043ae:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01043b5:	00 
c01043b6:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c01043bd:	e8 31 c9 ff ff       	call   c0100cf3 <__panic>

    free_pages(p0, 2);
c01043c2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01043c9:	00 
c01043ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043cd:	89 04 24             	mov    %eax,(%esp)
c01043d0:	e8 4c 0c 00 00       	call   c0105021 <free_pages>
    free_page(p2);
c01043d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043dc:	00 
c01043dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043e0:	89 04 24             	mov    %eax,(%esp)
c01043e3:	e8 39 0c 00 00       	call   c0105021 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01043e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01043ef:	e8 c2 0b 00 00       	call   c0104fb6 <alloc_pages>
c01043f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01043fb:	75 24                	jne    c0104421 <default_check+0x530>
c01043fd:	c7 44 24 0c d8 ab 10 	movl   $0xc010abd8,0xc(%esp)
c0104404:	c0 
c0104405:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010440c:	c0 
c010440d:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0104414:	00 
c0104415:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010441c:	e8 d2 c8 ff ff       	call   c0100cf3 <__panic>
    assert(alloc_page() == NULL);
c0104421:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104428:	e8 89 0b 00 00       	call   c0104fb6 <alloc_pages>
c010442d:	85 c0                	test   %eax,%eax
c010442f:	74 24                	je     c0104455 <default_check+0x564>
c0104431:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c0104438:	c0 
c0104439:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0104440:	c0 
c0104441:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0104448:	00 
c0104449:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0104450:	e8 9e c8 ff ff       	call   c0100cf3 <__panic>

    assert(nr_free == 0);
c0104455:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c010445a:	85 c0                	test   %eax,%eax
c010445c:	74 24                	je     c0104482 <default_check+0x591>
c010445e:	c7 44 24 0c 89 aa 10 	movl   $0xc010aa89,0xc(%esp)
c0104465:	c0 
c0104466:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010446d:	c0 
c010446e:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0104475:	00 
c0104476:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010447d:	e8 71 c8 ff ff       	call   c0100cf3 <__panic>
    nr_free = nr_free_store;
c0104482:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104485:	a3 d8 a0 12 c0       	mov    %eax,0xc012a0d8

    free_list = free_list_store;
c010448a:	8b 45 80             	mov    -0x80(%ebp),%eax
c010448d:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104490:	a3 d0 a0 12 c0       	mov    %eax,0xc012a0d0
c0104495:	89 15 d4 a0 12 c0    	mov    %edx,0xc012a0d4
    free_pages(p0, 5);
c010449b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01044a2:	00 
c01044a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044a6:	89 04 24             	mov    %eax,(%esp)
c01044a9:	e8 73 0b 00 00       	call   c0105021 <free_pages>

    le = &free_list;
c01044ae:	c7 45 ec d0 a0 12 c0 	movl   $0xc012a0d0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01044b5:	eb 1d                	jmp    c01044d4 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c01044b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044ba:	83 e8 0c             	sub    $0xc,%eax
c01044bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01044c0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01044c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01044c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01044ca:	8b 40 08             	mov    0x8(%eax),%eax
c01044cd:	29 c2                	sub    %eax,%edx
c01044cf:	89 d0                	mov    %edx,%eax
c01044d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044d7:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01044da:	8b 45 88             	mov    -0x78(%ebp),%eax
c01044dd:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01044e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01044e3:	81 7d ec d0 a0 12 c0 	cmpl   $0xc012a0d0,-0x14(%ebp)
c01044ea:	75 cb                	jne    c01044b7 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01044ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044f0:	74 24                	je     c0104516 <default_check+0x625>
c01044f2:	c7 44 24 0c f6 ab 10 	movl   $0xc010abf6,0xc(%esp)
c01044f9:	c0 
c01044fa:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c0104501:	c0 
c0104502:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0104509:	00 
c010450a:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c0104511:	e8 dd c7 ff ff       	call   c0100cf3 <__panic>
    assert(total == 0);
c0104516:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010451a:	74 24                	je     c0104540 <default_check+0x64f>
c010451c:	c7 44 24 0c 01 ac 10 	movl   $0xc010ac01,0xc(%esp)
c0104523:	c0 
c0104524:	c7 44 24 08 96 a8 10 	movl   $0xc010a896,0x8(%esp)
c010452b:	c0 
c010452c:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0104533:	00 
c0104534:	c7 04 24 ab a8 10 c0 	movl   $0xc010a8ab,(%esp)
c010453b:	e8 b3 c7 ff ff       	call   c0100cf3 <__panic>
}
c0104540:	81 c4 94 00 00 00    	add    $0x94,%esp
c0104546:	5b                   	pop    %ebx
c0104547:	5d                   	pop    %ebp
c0104548:	c3                   	ret    

c0104549 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0104549:	55                   	push   %ebp
c010454a:	89 e5                	mov    %esp,%ebp
c010454c:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010454f:	9c                   	pushf  
c0104550:	58                   	pop    %eax
c0104551:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104557:	25 00 02 00 00       	and    $0x200,%eax
c010455c:	85 c0                	test   %eax,%eax
c010455e:	74 0c                	je     c010456c <__intr_save+0x23>
        intr_disable();
c0104560:	e8 f7 d9 ff ff       	call   c0101f5c <intr_disable>
        return 1;
c0104565:	b8 01 00 00 00       	mov    $0x1,%eax
c010456a:	eb 05                	jmp    c0104571 <__intr_save+0x28>
    }
    return 0;
c010456c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104571:	c9                   	leave  
c0104572:	c3                   	ret    

c0104573 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104573:	55                   	push   %ebp
c0104574:	89 e5                	mov    %esp,%ebp
c0104576:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104579:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010457d:	74 05                	je     c0104584 <__intr_restore+0x11>
        intr_enable();
c010457f:	e8 d2 d9 ff ff       	call   c0101f56 <intr_enable>
    }
}
c0104584:	c9                   	leave  
c0104585:	c3                   	ret    

c0104586 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104586:	55                   	push   %ebp
c0104587:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104589:	8b 55 08             	mov    0x8(%ebp),%edx
c010458c:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c0104591:	29 c2                	sub    %eax,%edx
c0104593:	89 d0                	mov    %edx,%eax
c0104595:	c1 f8 05             	sar    $0x5,%eax
}
c0104598:	5d                   	pop    %ebp
c0104599:	c3                   	ret    

c010459a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010459a:	55                   	push   %ebp
c010459b:	89 e5                	mov    %esp,%ebp
c010459d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01045a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a3:	89 04 24             	mov    %eax,(%esp)
c01045a6:	e8 db ff ff ff       	call   c0104586 <page2ppn>
c01045ab:	c1 e0 0c             	shl    $0xc,%eax
}
c01045ae:	c9                   	leave  
c01045af:	c3                   	ret    

c01045b0 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01045b0:	55                   	push   %ebp
c01045b1:	89 e5                	mov    %esp,%ebp
c01045b3:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01045b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b9:	c1 e8 0c             	shr    $0xc,%eax
c01045bc:	89 c2                	mov    %eax,%edx
c01045be:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c01045c3:	39 c2                	cmp    %eax,%edx
c01045c5:	72 1c                	jb     c01045e3 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01045c7:	c7 44 24 08 3c ac 10 	movl   $0xc010ac3c,0x8(%esp)
c01045ce:	c0 
c01045cf:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01045d6:	00 
c01045d7:	c7 04 24 5b ac 10 c0 	movl   $0xc010ac5b,(%esp)
c01045de:	e8 10 c7 ff ff       	call   c0100cf3 <__panic>
    }
    return &pages[PPN(pa)];
c01045e3:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c01045e8:	8b 55 08             	mov    0x8(%ebp),%edx
c01045eb:	c1 ea 0c             	shr    $0xc,%edx
c01045ee:	c1 e2 05             	shl    $0x5,%edx
c01045f1:	01 d0                	add    %edx,%eax
}
c01045f3:	c9                   	leave  
c01045f4:	c3                   	ret    

c01045f5 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01045f5:	55                   	push   %ebp
c01045f6:	89 e5                	mov    %esp,%ebp
c01045f8:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01045fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01045fe:	89 04 24             	mov    %eax,(%esp)
c0104601:	e8 94 ff ff ff       	call   c010459a <page2pa>
c0104606:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010460c:	c1 e8 0c             	shr    $0xc,%eax
c010460f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104612:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0104617:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010461a:	72 23                	jb     c010463f <page2kva+0x4a>
c010461c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010461f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104623:	c7 44 24 08 6c ac 10 	movl   $0xc010ac6c,0x8(%esp)
c010462a:	c0 
c010462b:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0104632:	00 
c0104633:	c7 04 24 5b ac 10 c0 	movl   $0xc010ac5b,(%esp)
c010463a:	e8 b4 c6 ff ff       	call   c0100cf3 <__panic>
c010463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104642:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104647:	c9                   	leave  
c0104648:	c3                   	ret    

c0104649 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0104649:	55                   	push   %ebp
c010464a:	89 e5                	mov    %esp,%ebp
c010464c:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010464f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104652:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104655:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010465c:	77 23                	ja     c0104681 <kva2page+0x38>
c010465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104661:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104665:	c7 44 24 08 90 ac 10 	movl   $0xc010ac90,0x8(%esp)
c010466c:	c0 
c010466d:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0104674:	00 
c0104675:	c7 04 24 5b ac 10 c0 	movl   $0xc010ac5b,(%esp)
c010467c:	e8 72 c6 ff ff       	call   c0100cf3 <__panic>
c0104681:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104684:	05 00 00 00 40       	add    $0x40000000,%eax
c0104689:	89 04 24             	mov    %eax,(%esp)
c010468c:	e8 1f ff ff ff       	call   c01045b0 <pa2page>
}
c0104691:	c9                   	leave  
c0104692:	c3                   	ret    

c0104693 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104693:	55                   	push   %ebp
c0104694:	89 e5                	mov    %esp,%ebp
c0104696:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104699:	8b 45 0c             	mov    0xc(%ebp),%eax
c010469c:	ba 01 00 00 00       	mov    $0x1,%edx
c01046a1:	89 c1                	mov    %eax,%ecx
c01046a3:	d3 e2                	shl    %cl,%edx
c01046a5:	89 d0                	mov    %edx,%eax
c01046a7:	89 04 24             	mov    %eax,(%esp)
c01046aa:	e8 07 09 00 00       	call   c0104fb6 <alloc_pages>
c01046af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c01046b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046b6:	75 07                	jne    c01046bf <__slob_get_free_pages+0x2c>
    return NULL;
c01046b8:	b8 00 00 00 00       	mov    $0x0,%eax
c01046bd:	eb 0b                	jmp    c01046ca <__slob_get_free_pages+0x37>
  return page2kva(page);
c01046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c2:	89 04 24             	mov    %eax,(%esp)
c01046c5:	e8 2b ff ff ff       	call   c01045f5 <page2kva>
}
c01046ca:	c9                   	leave  
c01046cb:	c3                   	ret    

c01046cc <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c01046cc:	55                   	push   %ebp
c01046cd:	89 e5                	mov    %esp,%ebp
c01046cf:	53                   	push   %ebx
c01046d0:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c01046d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046d6:	ba 01 00 00 00       	mov    $0x1,%edx
c01046db:	89 c1                	mov    %eax,%ecx
c01046dd:	d3 e2                	shl    %cl,%edx
c01046df:	89 d0                	mov    %edx,%eax
c01046e1:	89 c3                	mov    %eax,%ebx
c01046e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e6:	89 04 24             	mov    %eax,(%esp)
c01046e9:	e8 5b ff ff ff       	call   c0104649 <kva2page>
c01046ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01046f2:	89 04 24             	mov    %eax,(%esp)
c01046f5:	e8 27 09 00 00       	call   c0105021 <free_pages>
}
c01046fa:	83 c4 14             	add    $0x14,%esp
c01046fd:	5b                   	pop    %ebx
c01046fe:	5d                   	pop    %ebp
c01046ff:	c3                   	ret    

c0104700 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104700:	55                   	push   %ebp
c0104701:	89 e5                	mov    %esp,%ebp
c0104703:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104706:	8b 45 08             	mov    0x8(%ebp),%eax
c0104709:	83 c0 08             	add    $0x8,%eax
c010470c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0104711:	76 24                	jbe    c0104737 <slob_alloc+0x37>
c0104713:	c7 44 24 0c b4 ac 10 	movl   $0xc010acb4,0xc(%esp)
c010471a:	c0 
c010471b:	c7 44 24 08 d3 ac 10 	movl   $0xc010acd3,0x8(%esp)
c0104722:	c0 
c0104723:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010472a:	00 
c010472b:	c7 04 24 e8 ac 10 c0 	movl   $0xc010ace8,(%esp)
c0104732:	e8 bc c5 ff ff       	call   c0100cf3 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104737:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c010473e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104745:	8b 45 08             	mov    0x8(%ebp),%eax
c0104748:	83 c0 07             	add    $0x7,%eax
c010474b:	c1 e8 03             	shr    $0x3,%eax
c010474e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104751:	e8 f3 fd ff ff       	call   c0104549 <__intr_save>
c0104756:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104759:	a1 e8 49 12 c0       	mov    0xc01249e8,%eax
c010475e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104761:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104764:	8b 40 04             	mov    0x4(%eax),%eax
c0104767:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c010476a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010476e:	74 25                	je     c0104795 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104770:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104773:	8b 45 10             	mov    0x10(%ebp),%eax
c0104776:	01 d0                	add    %edx,%eax
c0104778:	8d 50 ff             	lea    -0x1(%eax),%edx
c010477b:	8b 45 10             	mov    0x10(%ebp),%eax
c010477e:	f7 d8                	neg    %eax
c0104780:	21 d0                	and    %edx,%eax
c0104782:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104785:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104788:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010478b:	29 c2                	sub    %eax,%edx
c010478d:	89 d0                	mov    %edx,%eax
c010478f:	c1 f8 03             	sar    $0x3,%eax
c0104792:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104795:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104798:	8b 00                	mov    (%eax),%eax
c010479a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010479d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01047a0:	01 ca                	add    %ecx,%edx
c01047a2:	39 d0                	cmp    %edx,%eax
c01047a4:	0f 8c aa 00 00 00    	jl     c0104854 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c01047aa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01047ae:	74 38                	je     c01047e8 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c01047b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047b3:	8b 00                	mov    (%eax),%eax
c01047b5:	2b 45 e8             	sub    -0x18(%ebp),%eax
c01047b8:	89 c2                	mov    %eax,%edx
c01047ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047bd:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c01047bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047c2:	8b 50 04             	mov    0x4(%eax),%edx
c01047c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047c8:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01047cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01047d1:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01047d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047d7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01047da:	89 10                	mov    %edx,(%eax)
				prev = cur;
c01047dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047df:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c01047e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01047e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047eb:	8b 00                	mov    (%eax),%eax
c01047ed:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01047f0:	75 0e                	jne    c0104800 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c01047f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047f5:	8b 50 04             	mov    0x4(%eax),%edx
c01047f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047fb:	89 50 04             	mov    %edx,0x4(%eax)
c01047fe:	eb 3c                	jmp    c010483c <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0104800:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104803:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010480a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010480d:	01 c2                	add    %eax,%edx
c010480f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104812:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104815:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104818:	8b 40 04             	mov    0x4(%eax),%eax
c010481b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010481e:	8b 12                	mov    (%edx),%edx
c0104820:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104823:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104825:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104828:	8b 40 04             	mov    0x4(%eax),%eax
c010482b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010482e:	8b 52 04             	mov    0x4(%edx),%edx
c0104831:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104834:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104837:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010483a:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c010483c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010483f:	a3 e8 49 12 c0       	mov    %eax,0xc01249e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0104844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104847:	89 04 24             	mov    %eax,(%esp)
c010484a:	e8 24 fd ff ff       	call   c0104573 <__intr_restore>
			return cur;
c010484f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104852:	eb 7f                	jmp    c01048d3 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0104854:	a1 e8 49 12 c0       	mov    0xc01249e8,%eax
c0104859:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010485c:	75 61                	jne    c01048bf <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c010485e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104861:	89 04 24             	mov    %eax,(%esp)
c0104864:	e8 0a fd ff ff       	call   c0104573 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104869:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104870:	75 07                	jne    c0104879 <slob_alloc+0x179>
				return 0;
c0104872:	b8 00 00 00 00       	mov    $0x0,%eax
c0104877:	eb 5a                	jmp    c01048d3 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104879:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104880:	00 
c0104881:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104884:	89 04 24             	mov    %eax,(%esp)
c0104887:	e8 07 fe ff ff       	call   c0104693 <__slob_get_free_pages>
c010488c:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c010488f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104893:	75 07                	jne    c010489c <slob_alloc+0x19c>
				return 0;
c0104895:	b8 00 00 00 00       	mov    $0x0,%eax
c010489a:	eb 37                	jmp    c01048d3 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c010489c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01048a3:	00 
c01048a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048a7:	89 04 24             	mov    %eax,(%esp)
c01048aa:	e8 26 00 00 00       	call   c01048d5 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c01048af:	e8 95 fc ff ff       	call   c0104549 <__intr_save>
c01048b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c01048b7:	a1 e8 49 12 c0       	mov    0xc01249e8,%eax
c01048bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01048bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048c8:	8b 40 04             	mov    0x4(%eax),%eax
c01048cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c01048ce:	e9 97 fe ff ff       	jmp    c010476a <slob_alloc+0x6a>
}
c01048d3:	c9                   	leave  
c01048d4:	c3                   	ret    

c01048d5 <slob_free>:

static void slob_free(void *block, int size)
{
c01048d5:	55                   	push   %ebp
c01048d6:	89 e5                	mov    %esp,%ebp
c01048d8:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c01048db:	8b 45 08             	mov    0x8(%ebp),%eax
c01048de:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01048e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01048e5:	75 05                	jne    c01048ec <slob_free+0x17>
		return;
c01048e7:	e9 ff 00 00 00       	jmp    c01049eb <slob_free+0x116>

	if (size)
c01048ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01048f0:	74 10                	je     c0104902 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c01048f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048f5:	83 c0 07             	add    $0x7,%eax
c01048f8:	c1 e8 03             	shr    $0x3,%eax
c01048fb:	89 c2                	mov    %eax,%edx
c01048fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104900:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0104902:	e8 42 fc ff ff       	call   c0104549 <__intr_save>
c0104907:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010490a:	a1 e8 49 12 c0       	mov    0xc01249e8,%eax
c010490f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104912:	eb 27                	jmp    c010493b <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104917:	8b 40 04             	mov    0x4(%eax),%eax
c010491a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010491d:	77 13                	ja     c0104932 <slob_free+0x5d>
c010491f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104922:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104925:	77 27                	ja     c010494e <slob_free+0x79>
c0104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010492a:	8b 40 04             	mov    0x4(%eax),%eax
c010492d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104930:	77 1c                	ja     c010494e <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104932:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104935:	8b 40 04             	mov    0x4(%eax),%eax
c0104938:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010493b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010493e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104941:	76 d1                	jbe    c0104914 <slob_free+0x3f>
c0104943:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104946:	8b 40 04             	mov    0x4(%eax),%eax
c0104949:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010494c:	76 c6                	jbe    c0104914 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c010494e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104951:	8b 00                	mov    (%eax),%eax
c0104953:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010495a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010495d:	01 c2                	add    %eax,%edx
c010495f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104962:	8b 40 04             	mov    0x4(%eax),%eax
c0104965:	39 c2                	cmp    %eax,%edx
c0104967:	75 25                	jne    c010498e <slob_free+0xb9>
		b->units += cur->next->units;
c0104969:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010496c:	8b 10                	mov    (%eax),%edx
c010496e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104971:	8b 40 04             	mov    0x4(%eax),%eax
c0104974:	8b 00                	mov    (%eax),%eax
c0104976:	01 c2                	add    %eax,%edx
c0104978:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010497b:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c010497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104980:	8b 40 04             	mov    0x4(%eax),%eax
c0104983:	8b 50 04             	mov    0x4(%eax),%edx
c0104986:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104989:	89 50 04             	mov    %edx,0x4(%eax)
c010498c:	eb 0c                	jmp    c010499a <slob_free+0xc5>
	} else
		b->next = cur->next;
c010498e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104991:	8b 50 04             	mov    0x4(%eax),%edx
c0104994:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104997:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c010499a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010499d:	8b 00                	mov    (%eax),%eax
c010499f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01049a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049a9:	01 d0                	add    %edx,%eax
c01049ab:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049ae:	75 1f                	jne    c01049cf <slob_free+0xfa>
		cur->units += b->units;
c01049b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049b3:	8b 10                	mov    (%eax),%edx
c01049b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049b8:	8b 00                	mov    (%eax),%eax
c01049ba:	01 c2                	add    %eax,%edx
c01049bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049bf:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c01049c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049c4:	8b 50 04             	mov    0x4(%eax),%edx
c01049c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ca:	89 50 04             	mov    %edx,0x4(%eax)
c01049cd:	eb 09                	jmp    c01049d8 <slob_free+0x103>
	} else
		cur->next = b;
c01049cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01049d5:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c01049d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049db:	a3 e8 49 12 c0       	mov    %eax,0xc01249e8

	spin_unlock_irqrestore(&slob_lock, flags);
c01049e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049e3:	89 04 24             	mov    %eax,(%esp)
c01049e6:	e8 88 fb ff ff       	call   c0104573 <__intr_restore>
}
c01049eb:	c9                   	leave  
c01049ec:	c3                   	ret    

c01049ed <slob_init>:



void
slob_init(void) {
c01049ed:	55                   	push   %ebp
c01049ee:	89 e5                	mov    %esp,%ebp
c01049f0:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c01049f3:	c7 04 24 fa ac 10 c0 	movl   $0xc010acfa,(%esp)
c01049fa:	e8 60 b9 ff ff       	call   c010035f <cprintf>
}
c01049ff:	c9                   	leave  
c0104a00:	c3                   	ret    

c0104a01 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104a01:	55                   	push   %ebp
c0104a02:	89 e5                	mov    %esp,%ebp
c0104a04:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104a07:	e8 e1 ff ff ff       	call   c01049ed <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104a0c:	c7 04 24 0e ad 10 c0 	movl   $0xc010ad0e,(%esp)
c0104a13:	e8 47 b9 ff ff       	call   c010035f <cprintf>
}
c0104a18:	c9                   	leave  
c0104a19:	c3                   	ret    

c0104a1a <slob_allocated>:

size_t
slob_allocated(void) {
c0104a1a:	55                   	push   %ebp
c0104a1b:	89 e5                	mov    %esp,%ebp
  return 0;
c0104a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104a22:	5d                   	pop    %ebp
c0104a23:	c3                   	ret    

c0104a24 <kallocated>:

size_t
kallocated(void) {
c0104a24:	55                   	push   %ebp
c0104a25:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104a27:	e8 ee ff ff ff       	call   c0104a1a <slob_allocated>
}
c0104a2c:	5d                   	pop    %ebp
c0104a2d:	c3                   	ret    

c0104a2e <find_order>:

static int find_order(int size)
{
c0104a2e:	55                   	push   %ebp
c0104a2f:	89 e5                	mov    %esp,%ebp
c0104a31:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104a34:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104a3b:	eb 07                	jmp    c0104a44 <find_order+0x16>
		order++;
c0104a3d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0104a41:	d1 7d 08             	sarl   0x8(%ebp)
c0104a44:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104a4b:	7f f0                	jg     c0104a3d <find_order+0xf>
		order++;
	return order;
c0104a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104a50:	c9                   	leave  
c0104a51:	c3                   	ret    

c0104a52 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104a52:	55                   	push   %ebp
c0104a53:	89 e5                	mov    %esp,%ebp
c0104a55:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104a58:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104a5f:	77 38                	ja     c0104a99 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104a61:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a64:	8d 50 08             	lea    0x8(%eax),%edx
c0104a67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a6e:	00 
c0104a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a76:	89 14 24             	mov    %edx,(%esp)
c0104a79:	e8 82 fc ff ff       	call   c0104700 <slob_alloc>
c0104a7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104a81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a85:	74 08                	je     c0104a8f <__kmalloc+0x3d>
c0104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a8a:	83 c0 08             	add    $0x8,%eax
c0104a8d:	eb 05                	jmp    c0104a94 <__kmalloc+0x42>
c0104a8f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a94:	e9 a6 00 00 00       	jmp    c0104b3f <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104a99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104aa0:	00 
c0104aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104aa8:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104aaf:	e8 4c fc ff ff       	call   c0104700 <slob_alloc>
c0104ab4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104ab7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104abb:	75 07                	jne    c0104ac4 <__kmalloc+0x72>
		return 0;
c0104abd:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ac2:	eb 7b                	jmp    c0104b3f <__kmalloc+0xed>

	bb->order = find_order(size);
c0104ac4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ac7:	89 04 24             	mov    %eax,(%esp)
c0104aca:	e8 5f ff ff ff       	call   c0104a2e <find_order>
c0104acf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104ad2:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ad7:	8b 00                	mov    (%eax),%eax
c0104ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104add:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ae0:	89 04 24             	mov    %eax,(%esp)
c0104ae3:	e8 ab fb ff ff       	call   c0104693 <__slob_get_free_pages>
c0104ae8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104aeb:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104af1:	8b 40 04             	mov    0x4(%eax),%eax
c0104af4:	85 c0                	test   %eax,%eax
c0104af6:	74 2f                	je     c0104b27 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0104af8:	e8 4c fa ff ff       	call   c0104549 <__intr_save>
c0104afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104b00:	8b 15 84 7f 12 c0    	mov    0xc0127f84,%edx
c0104b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b09:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b0f:	a3 84 7f 12 c0       	mov    %eax,0xc0127f84
		spin_unlock_irqrestore(&block_lock, flags);
c0104b14:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b17:	89 04 24             	mov    %eax,(%esp)
c0104b1a:	e8 54 fa ff ff       	call   c0104573 <__intr_restore>
		return bb->pages;
c0104b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b22:	8b 40 04             	mov    0x4(%eax),%eax
c0104b25:	eb 18                	jmp    c0104b3f <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104b27:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104b2e:	00 
c0104b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b32:	89 04 24             	mov    %eax,(%esp)
c0104b35:	e8 9b fd ff ff       	call   c01048d5 <slob_free>
	return 0;
c0104b3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b3f:	c9                   	leave  
c0104b40:	c3                   	ret    

c0104b41 <kmalloc>:

void *
kmalloc(size_t size)
{
c0104b41:	55                   	push   %ebp
c0104b42:	89 e5                	mov    %esp,%ebp
c0104b44:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104b47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b4e:	00 
c0104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b52:	89 04 24             	mov    %eax,(%esp)
c0104b55:	e8 f8 fe ff ff       	call   c0104a52 <__kmalloc>
}
c0104b5a:	c9                   	leave  
c0104b5b:	c3                   	ret    

c0104b5c <kfree>:


void kfree(void *block)
{
c0104b5c:	55                   	push   %ebp
c0104b5d:	89 e5                	mov    %esp,%ebp
c0104b5f:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104b62:	c7 45 f0 84 7f 12 c0 	movl   $0xc0127f84,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104b69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104b6d:	75 05                	jne    c0104b74 <kfree+0x18>
		return;
c0104b6f:	e9 a2 00 00 00       	jmp    c0104c16 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104b74:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b77:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104b7c:	85 c0                	test   %eax,%eax
c0104b7e:	75 7f                	jne    c0104bff <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104b80:	e8 c4 f9 ff ff       	call   c0104549 <__intr_save>
c0104b85:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104b88:	a1 84 7f 12 c0       	mov    0xc0127f84,%eax
c0104b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b90:	eb 5c                	jmp    c0104bee <kfree+0x92>
			if (bb->pages == block) {
c0104b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b95:	8b 40 04             	mov    0x4(%eax),%eax
c0104b98:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104b9b:	75 3f                	jne    c0104bdc <kfree+0x80>
				*last = bb->next;
c0104b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ba0:	8b 50 08             	mov    0x8(%eax),%edx
c0104ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ba6:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bab:	89 04 24             	mov    %eax,(%esp)
c0104bae:	e8 c0 f9 ff ff       	call   c0104573 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bb6:	8b 10                	mov    (%eax),%edx
c0104bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bbb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104bbf:	89 04 24             	mov    %eax,(%esp)
c0104bc2:	e8 05 fb ff ff       	call   c01046cc <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104bc7:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104bce:	00 
c0104bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd2:	89 04 24             	mov    %eax,(%esp)
c0104bd5:	e8 fb fc ff ff       	call   c01048d5 <slob_free>
				return;
c0104bda:	eb 3a                	jmp    c0104c16 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bdf:	83 c0 08             	add    $0x8,%eax
c0104be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104be8:	8b 40 08             	mov    0x8(%eax),%eax
c0104beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bf2:	75 9e                	jne    c0104b92 <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104bf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bf7:	89 04 24             	mov    %eax,(%esp)
c0104bfa:	e8 74 f9 ff ff       	call   c0104573 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104bff:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c02:	83 e8 08             	sub    $0x8,%eax
c0104c05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104c0c:	00 
c0104c0d:	89 04 24             	mov    %eax,(%esp)
c0104c10:	e8 c0 fc ff ff       	call   c01048d5 <slob_free>
	return;
c0104c15:	90                   	nop
}
c0104c16:	c9                   	leave  
c0104c17:	c3                   	ret    

c0104c18 <ksize>:


unsigned int ksize(const void *block)
{
c0104c18:	55                   	push   %ebp
c0104c19:	89 e5                	mov    %esp,%ebp
c0104c1b:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104c1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c22:	75 07                	jne    c0104c2b <ksize+0x13>
		return 0;
c0104c24:	b8 00 00 00 00       	mov    $0x0,%eax
c0104c29:	eb 6b                	jmp    c0104c96 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c2e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c33:	85 c0                	test   %eax,%eax
c0104c35:	75 54                	jne    c0104c8b <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104c37:	e8 0d f9 ff ff       	call   c0104549 <__intr_save>
c0104c3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104c3f:	a1 84 7f 12 c0       	mov    0xc0127f84,%eax
c0104c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c47:	eb 31                	jmp    c0104c7a <ksize+0x62>
			if (bb->pages == block) {
c0104c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c4c:	8b 40 04             	mov    0x4(%eax),%eax
c0104c4f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104c52:	75 1d                	jne    c0104c71 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c57:	89 04 24             	mov    %eax,(%esp)
c0104c5a:	e8 14 f9 ff ff       	call   c0104573 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c62:	8b 00                	mov    (%eax),%eax
c0104c64:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104c69:	89 c1                	mov    %eax,%ecx
c0104c6b:	d3 e2                	shl    %cl,%edx
c0104c6d:	89 d0                	mov    %edx,%eax
c0104c6f:	eb 25                	jmp    c0104c96 <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0104c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c74:	8b 40 08             	mov    0x8(%eax),%eax
c0104c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c7e:	75 c9                	jne    c0104c49 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c83:	89 04 24             	mov    %eax,(%esp)
c0104c86:	e8 e8 f8 ff ff       	call   c0104573 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104c8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c8e:	83 e8 08             	sub    $0x8,%eax
c0104c91:	8b 00                	mov    (%eax),%eax
c0104c93:	c1 e0 03             	shl    $0x3,%eax
}
c0104c96:	c9                   	leave  
c0104c97:	c3                   	ret    

c0104c98 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104c98:	55                   	push   %ebp
c0104c99:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104c9b:	8b 55 08             	mov    0x8(%ebp),%edx
c0104c9e:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c0104ca3:	29 c2                	sub    %eax,%edx
c0104ca5:	89 d0                	mov    %edx,%eax
c0104ca7:	c1 f8 05             	sar    $0x5,%eax
}
c0104caa:	5d                   	pop    %ebp
c0104cab:	c3                   	ret    

c0104cac <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104cac:	55                   	push   %ebp
c0104cad:	89 e5                	mov    %esp,%ebp
c0104caf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cb5:	89 04 24             	mov    %eax,(%esp)
c0104cb8:	e8 db ff ff ff       	call   c0104c98 <page2ppn>
c0104cbd:	c1 e0 0c             	shl    $0xc,%eax
}
c0104cc0:	c9                   	leave  
c0104cc1:	c3                   	ret    

c0104cc2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104cc2:	55                   	push   %ebp
c0104cc3:	89 e5                	mov    %esp,%ebp
c0104cc5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ccb:	c1 e8 0c             	shr    $0xc,%eax
c0104cce:	89 c2                	mov    %eax,%edx
c0104cd0:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0104cd5:	39 c2                	cmp    %eax,%edx
c0104cd7:	72 1c                	jb     c0104cf5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104cd9:	c7 44 24 08 2c ad 10 	movl   $0xc010ad2c,0x8(%esp)
c0104ce0:	c0 
c0104ce1:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104ce8:	00 
c0104ce9:	c7 04 24 4b ad 10 c0 	movl   $0xc010ad4b,(%esp)
c0104cf0:	e8 fe bf ff ff       	call   c0100cf3 <__panic>
    }
    return &pages[PPN(pa)];
c0104cf5:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c0104cfa:	8b 55 08             	mov    0x8(%ebp),%edx
c0104cfd:	c1 ea 0c             	shr    $0xc,%edx
c0104d00:	c1 e2 05             	shl    $0x5,%edx
c0104d03:	01 d0                	add    %edx,%eax
}
c0104d05:	c9                   	leave  
c0104d06:	c3                   	ret    

c0104d07 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104d07:	55                   	push   %ebp
c0104d08:	89 e5                	mov    %esp,%ebp
c0104d0a:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104d0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d10:	89 04 24             	mov    %eax,(%esp)
c0104d13:	e8 94 ff ff ff       	call   c0104cac <page2pa>
c0104d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d1e:	c1 e8 0c             	shr    $0xc,%eax
c0104d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d24:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0104d29:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104d2c:	72 23                	jb     c0104d51 <page2kva+0x4a>
c0104d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d31:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d35:	c7 44 24 08 5c ad 10 	movl   $0xc010ad5c,0x8(%esp)
c0104d3c:	c0 
c0104d3d:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0104d44:	00 
c0104d45:	c7 04 24 4b ad 10 c0 	movl   $0xc010ad4b,(%esp)
c0104d4c:	e8 a2 bf ff ff       	call   c0100cf3 <__panic>
c0104d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d54:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104d59:	c9                   	leave  
c0104d5a:	c3                   	ret    

c0104d5b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0104d5b:	55                   	push   %ebp
c0104d5c:	89 e5                	mov    %esp,%ebp
c0104d5e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104d61:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d64:	83 e0 01             	and    $0x1,%eax
c0104d67:	85 c0                	test   %eax,%eax
c0104d69:	75 1c                	jne    c0104d87 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104d6b:	c7 44 24 08 80 ad 10 	movl   $0xc010ad80,0x8(%esp)
c0104d72:	c0 
c0104d73:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0104d7a:	00 
c0104d7b:	c7 04 24 4b ad 10 c0 	movl   $0xc010ad4b,(%esp)
c0104d82:	e8 6c bf ff ff       	call   c0100cf3 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104d87:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104d8f:	89 04 24             	mov    %eax,(%esp)
c0104d92:	e8 2b ff ff ff       	call   c0104cc2 <pa2page>
}
c0104d97:	c9                   	leave  
c0104d98:	c3                   	ret    

c0104d99 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104d99:	55                   	push   %ebp
c0104d9a:	89 e5                	mov    %esp,%ebp
c0104d9c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104d9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104da2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104da7:	89 04 24             	mov    %eax,(%esp)
c0104daa:	e8 13 ff ff ff       	call   c0104cc2 <pa2page>
}
c0104daf:	c9                   	leave  
c0104db0:	c3                   	ret    

c0104db1 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104db1:	55                   	push   %ebp
c0104db2:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104db4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104db7:	8b 00                	mov    (%eax),%eax
}
c0104db9:	5d                   	pop    %ebp
c0104dba:	c3                   	ret    

c0104dbb <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104dbb:	55                   	push   %ebp
c0104dbc:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104dbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104dc4:	89 10                	mov    %edx,(%eax)
}
c0104dc6:	5d                   	pop    %ebp
c0104dc7:	c3                   	ret    

c0104dc8 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104dc8:	55                   	push   %ebp
c0104dc9:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104dcb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dce:	8b 00                	mov    (%eax),%eax
c0104dd0:	8d 50 01             	lea    0x1(%eax),%edx
c0104dd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dd6:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104dd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ddb:	8b 00                	mov    (%eax),%eax
}
c0104ddd:	5d                   	pop    %ebp
c0104dde:	c3                   	ret    

c0104ddf <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104ddf:	55                   	push   %ebp
c0104de0:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104de2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104de5:	8b 00                	mov    (%eax),%eax
c0104de7:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104dea:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ded:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104def:	8b 45 08             	mov    0x8(%ebp),%eax
c0104df2:	8b 00                	mov    (%eax),%eax
}
c0104df4:	5d                   	pop    %ebp
c0104df5:	c3                   	ret    

c0104df6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0104df6:	55                   	push   %ebp
c0104df7:	89 e5                	mov    %esp,%ebp
c0104df9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104dfc:	9c                   	pushf  
c0104dfd:	58                   	pop    %eax
c0104dfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104e04:	25 00 02 00 00       	and    $0x200,%eax
c0104e09:	85 c0                	test   %eax,%eax
c0104e0b:	74 0c                	je     c0104e19 <__intr_save+0x23>
        intr_disable();
c0104e0d:	e8 4a d1 ff ff       	call   c0101f5c <intr_disable>
        return 1;
c0104e12:	b8 01 00 00 00       	mov    $0x1,%eax
c0104e17:	eb 05                	jmp    c0104e1e <__intr_save+0x28>
    }
    return 0;
c0104e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e1e:	c9                   	leave  
c0104e1f:	c3                   	ret    

c0104e20 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104e20:	55                   	push   %ebp
c0104e21:	89 e5                	mov    %esp,%ebp
c0104e23:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104e26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104e2a:	74 05                	je     c0104e31 <__intr_restore+0x11>
        intr_enable();
c0104e2c:	e8 25 d1 ff ff       	call   c0101f56 <intr_enable>
    }
}
c0104e31:	c9                   	leave  
c0104e32:	c3                   	ret    

c0104e33 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104e33:	55                   	push   %ebp
c0104e34:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104e36:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e39:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104e3c:	b8 23 00 00 00       	mov    $0x23,%eax
c0104e41:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104e43:	b8 23 00 00 00       	mov    $0x23,%eax
c0104e48:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104e4a:	b8 10 00 00 00       	mov    $0x10,%eax
c0104e4f:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104e51:	b8 10 00 00 00       	mov    $0x10,%eax
c0104e56:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104e58:	b8 10 00 00 00       	mov    $0x10,%eax
c0104e5d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104e5f:	ea 66 4e 10 c0 08 00 	ljmp   $0x8,$0xc0104e66
}
c0104e66:	5d                   	pop    %ebp
c0104e67:	c3                   	ret    

c0104e68 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104e68:	55                   	push   %ebp
c0104e69:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e6e:	a3 c4 7f 12 c0       	mov    %eax,0xc0127fc4
}
c0104e73:	5d                   	pop    %ebp
c0104e74:	c3                   	ret    

c0104e75 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104e75:	55                   	push   %ebp
c0104e76:	89 e5                	mov    %esp,%ebp
c0104e78:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104e7b:	b8 00 40 12 c0       	mov    $0xc0124000,%eax
c0104e80:	89 04 24             	mov    %eax,(%esp)
c0104e83:	e8 e0 ff ff ff       	call   c0104e68 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104e88:	66 c7 05 c8 7f 12 c0 	movw   $0x10,0xc0127fc8
c0104e8f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104e91:	66 c7 05 48 4a 12 c0 	movw   $0x68,0xc0124a48
c0104e98:	68 00 
c0104e9a:	b8 c0 7f 12 c0       	mov    $0xc0127fc0,%eax
c0104e9f:	66 a3 4a 4a 12 c0    	mov    %ax,0xc0124a4a
c0104ea5:	b8 c0 7f 12 c0       	mov    $0xc0127fc0,%eax
c0104eaa:	c1 e8 10             	shr    $0x10,%eax
c0104ead:	a2 4c 4a 12 c0       	mov    %al,0xc0124a4c
c0104eb2:	0f b6 05 4d 4a 12 c0 	movzbl 0xc0124a4d,%eax
c0104eb9:	83 e0 f0             	and    $0xfffffff0,%eax
c0104ebc:	83 c8 09             	or     $0x9,%eax
c0104ebf:	a2 4d 4a 12 c0       	mov    %al,0xc0124a4d
c0104ec4:	0f b6 05 4d 4a 12 c0 	movzbl 0xc0124a4d,%eax
c0104ecb:	83 e0 ef             	and    $0xffffffef,%eax
c0104ece:	a2 4d 4a 12 c0       	mov    %al,0xc0124a4d
c0104ed3:	0f b6 05 4d 4a 12 c0 	movzbl 0xc0124a4d,%eax
c0104eda:	83 e0 9f             	and    $0xffffff9f,%eax
c0104edd:	a2 4d 4a 12 c0       	mov    %al,0xc0124a4d
c0104ee2:	0f b6 05 4d 4a 12 c0 	movzbl 0xc0124a4d,%eax
c0104ee9:	83 c8 80             	or     $0xffffff80,%eax
c0104eec:	a2 4d 4a 12 c0       	mov    %al,0xc0124a4d
c0104ef1:	0f b6 05 4e 4a 12 c0 	movzbl 0xc0124a4e,%eax
c0104ef8:	83 e0 f0             	and    $0xfffffff0,%eax
c0104efb:	a2 4e 4a 12 c0       	mov    %al,0xc0124a4e
c0104f00:	0f b6 05 4e 4a 12 c0 	movzbl 0xc0124a4e,%eax
c0104f07:	83 e0 ef             	and    $0xffffffef,%eax
c0104f0a:	a2 4e 4a 12 c0       	mov    %al,0xc0124a4e
c0104f0f:	0f b6 05 4e 4a 12 c0 	movzbl 0xc0124a4e,%eax
c0104f16:	83 e0 df             	and    $0xffffffdf,%eax
c0104f19:	a2 4e 4a 12 c0       	mov    %al,0xc0124a4e
c0104f1e:	0f b6 05 4e 4a 12 c0 	movzbl 0xc0124a4e,%eax
c0104f25:	83 c8 40             	or     $0x40,%eax
c0104f28:	a2 4e 4a 12 c0       	mov    %al,0xc0124a4e
c0104f2d:	0f b6 05 4e 4a 12 c0 	movzbl 0xc0124a4e,%eax
c0104f34:	83 e0 7f             	and    $0x7f,%eax
c0104f37:	a2 4e 4a 12 c0       	mov    %al,0xc0124a4e
c0104f3c:	b8 c0 7f 12 c0       	mov    $0xc0127fc0,%eax
c0104f41:	c1 e8 18             	shr    $0x18,%eax
c0104f44:	a2 4f 4a 12 c0       	mov    %al,0xc0124a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104f49:	c7 04 24 50 4a 12 c0 	movl   $0xc0124a50,(%esp)
c0104f50:	e8 de fe ff ff       	call   c0104e33 <lgdt>
c0104f55:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104f5b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104f5f:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0104f62:	c9                   	leave  
c0104f63:	c3                   	ret    

c0104f64 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104f64:	55                   	push   %ebp
c0104f65:	89 e5                	mov    %esp,%ebp
c0104f67:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0104f6a:	c7 05 dc a0 12 c0 20 	movl   $0xc010ac20,0xc012a0dc
c0104f71:	ac 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104f74:	a1 dc a0 12 c0       	mov    0xc012a0dc,%eax
c0104f79:	8b 00                	mov    (%eax),%eax
c0104f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f7f:	c7 04 24 ac ad 10 c0 	movl   $0xc010adac,(%esp)
c0104f86:	e8 d4 b3 ff ff       	call   c010035f <cprintf>
    pmm_manager->init();
c0104f8b:	a1 dc a0 12 c0       	mov    0xc012a0dc,%eax
c0104f90:	8b 40 04             	mov    0x4(%eax),%eax
c0104f93:	ff d0                	call   *%eax
}
c0104f95:	c9                   	leave  
c0104f96:	c3                   	ret    

c0104f97 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104f97:	55                   	push   %ebp
c0104f98:	89 e5                	mov    %esp,%ebp
c0104f9a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104f9d:	a1 dc a0 12 c0       	mov    0xc012a0dc,%eax
c0104fa2:	8b 40 08             	mov    0x8(%eax),%eax
c0104fa5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104fa8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104fac:	8b 55 08             	mov    0x8(%ebp),%edx
c0104faf:	89 14 24             	mov    %edx,(%esp)
c0104fb2:	ff d0                	call   *%eax
}
c0104fb4:	c9                   	leave  
c0104fb5:	c3                   	ret    

c0104fb6 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104fb6:	55                   	push   %ebp
c0104fb7:	89 e5                	mov    %esp,%ebp
c0104fb9:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104fbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0104fc3:	e8 2e fe ff ff       	call   c0104df6 <__intr_save>
c0104fc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0104fcb:	a1 dc a0 12 c0       	mov    0xc012a0dc,%eax
c0104fd0:	8b 40 0c             	mov    0xc(%eax),%eax
c0104fd3:	8b 55 08             	mov    0x8(%ebp),%edx
c0104fd6:	89 14 24             	mov    %edx,(%esp)
c0104fd9:	ff d0                	call   *%eax
c0104fdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0104fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fe1:	89 04 24             	mov    %eax,(%esp)
c0104fe4:	e8 37 fe ff ff       	call   c0104e20 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0104fe9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104fed:	75 2d                	jne    c010501c <alloc_pages+0x66>
c0104fef:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0104ff3:	77 27                	ja     c010501c <alloc_pages+0x66>
c0104ff5:	a1 2c 80 12 c0       	mov    0xc012802c,%eax
c0104ffa:	85 c0                	test   %eax,%eax
c0104ffc:	74 1e                	je     c010501c <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0104ffe:	8b 55 08             	mov    0x8(%ebp),%edx
c0105001:	a1 cc a1 12 c0       	mov    0xc012a1cc,%eax
c0105006:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010500d:	00 
c010500e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105012:	89 04 24             	mov    %eax,(%esp)
c0105015:	e8 da 18 00 00       	call   c01068f4 <swap_out>
    }
c010501a:	eb a7                	jmp    c0104fc3 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c010501c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010501f:	c9                   	leave  
c0105020:	c3                   	ret    

c0105021 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0105021:	55                   	push   %ebp
c0105022:	89 e5                	mov    %esp,%ebp
c0105024:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0105027:	e8 ca fd ff ff       	call   c0104df6 <__intr_save>
c010502c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c010502f:	a1 dc a0 12 c0       	mov    0xc012a0dc,%eax
c0105034:	8b 40 10             	mov    0x10(%eax),%eax
c0105037:	8b 55 0c             	mov    0xc(%ebp),%edx
c010503a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010503e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105041:	89 14 24             	mov    %edx,(%esp)
c0105044:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0105046:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105049:	89 04 24             	mov    %eax,(%esp)
c010504c:	e8 cf fd ff ff       	call   c0104e20 <__intr_restore>
}
c0105051:	c9                   	leave  
c0105052:	c3                   	ret    

c0105053 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0105053:	55                   	push   %ebp
c0105054:	89 e5                	mov    %esp,%ebp
c0105056:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0105059:	e8 98 fd ff ff       	call   c0104df6 <__intr_save>
c010505e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0105061:	a1 dc a0 12 c0       	mov    0xc012a0dc,%eax
c0105066:	8b 40 14             	mov    0x14(%eax),%eax
c0105069:	ff d0                	call   *%eax
c010506b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010506e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105071:	89 04 24             	mov    %eax,(%esp)
c0105074:	e8 a7 fd ff ff       	call   c0104e20 <__intr_restore>
    return ret;
c0105079:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010507c:	c9                   	leave  
c010507d:	c3                   	ret    

c010507e <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010507e:	55                   	push   %ebp
c010507f:	89 e5                	mov    %esp,%ebp
c0105081:	57                   	push   %edi
c0105082:	56                   	push   %esi
c0105083:	53                   	push   %ebx
c0105084:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010508a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0105091:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105098:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010509f:	c7 04 24 c3 ad 10 c0 	movl   $0xc010adc3,(%esp)
c01050a6:	e8 b4 b2 ff ff       	call   c010035f <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01050ab:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01050b2:	e9 15 01 00 00       	jmp    c01051cc <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01050b7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01050ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050bd:	89 d0                	mov    %edx,%eax
c01050bf:	c1 e0 02             	shl    $0x2,%eax
c01050c2:	01 d0                	add    %edx,%eax
c01050c4:	c1 e0 02             	shl    $0x2,%eax
c01050c7:	01 c8                	add    %ecx,%eax
c01050c9:	8b 50 08             	mov    0x8(%eax),%edx
c01050cc:	8b 40 04             	mov    0x4(%eax),%eax
c01050cf:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01050d2:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01050d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01050d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050db:	89 d0                	mov    %edx,%eax
c01050dd:	c1 e0 02             	shl    $0x2,%eax
c01050e0:	01 d0                	add    %edx,%eax
c01050e2:	c1 e0 02             	shl    $0x2,%eax
c01050e5:	01 c8                	add    %ecx,%eax
c01050e7:	8b 48 0c             	mov    0xc(%eax),%ecx
c01050ea:	8b 58 10             	mov    0x10(%eax),%ebx
c01050ed:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01050f0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01050f3:	01 c8                	add    %ecx,%eax
c01050f5:	11 da                	adc    %ebx,%edx
c01050f7:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01050fa:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01050fd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105100:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105103:	89 d0                	mov    %edx,%eax
c0105105:	c1 e0 02             	shl    $0x2,%eax
c0105108:	01 d0                	add    %edx,%eax
c010510a:	c1 e0 02             	shl    $0x2,%eax
c010510d:	01 c8                	add    %ecx,%eax
c010510f:	83 c0 14             	add    $0x14,%eax
c0105112:	8b 00                	mov    (%eax),%eax
c0105114:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c010511a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010511d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105120:	83 c0 ff             	add    $0xffffffff,%eax
c0105123:	83 d2 ff             	adc    $0xffffffff,%edx
c0105126:	89 c6                	mov    %eax,%esi
c0105128:	89 d7                	mov    %edx,%edi
c010512a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010512d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105130:	89 d0                	mov    %edx,%eax
c0105132:	c1 e0 02             	shl    $0x2,%eax
c0105135:	01 d0                	add    %edx,%eax
c0105137:	c1 e0 02             	shl    $0x2,%eax
c010513a:	01 c8                	add    %ecx,%eax
c010513c:	8b 48 0c             	mov    0xc(%eax),%ecx
c010513f:	8b 58 10             	mov    0x10(%eax),%ebx
c0105142:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0105148:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c010514c:	89 74 24 14          	mov    %esi,0x14(%esp)
c0105150:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0105154:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105157:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010515a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010515e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105162:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105166:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010516a:	c7 04 24 d0 ad 10 c0 	movl   $0xc010add0,(%esp)
c0105171:	e8 e9 b1 ff ff       	call   c010035f <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0105176:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105179:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010517c:	89 d0                	mov    %edx,%eax
c010517e:	c1 e0 02             	shl    $0x2,%eax
c0105181:	01 d0                	add    %edx,%eax
c0105183:	c1 e0 02             	shl    $0x2,%eax
c0105186:	01 c8                	add    %ecx,%eax
c0105188:	83 c0 14             	add    $0x14,%eax
c010518b:	8b 00                	mov    (%eax),%eax
c010518d:	83 f8 01             	cmp    $0x1,%eax
c0105190:	75 36                	jne    c01051c8 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0105192:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105195:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105198:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010519b:	77 2b                	ja     c01051c8 <page_init+0x14a>
c010519d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01051a0:	72 05                	jb     c01051a7 <page_init+0x129>
c01051a2:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c01051a5:	73 21                	jae    c01051c8 <page_init+0x14a>
c01051a7:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01051ab:	77 1b                	ja     c01051c8 <page_init+0x14a>
c01051ad:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01051b1:	72 09                	jb     c01051bc <page_init+0x13e>
c01051b3:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c01051ba:	77 0c                	ja     c01051c8 <page_init+0x14a>
                maxpa = end;
c01051bc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01051bf:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01051c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01051c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01051c8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01051cc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01051cf:	8b 00                	mov    (%eax),%eax
c01051d1:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01051d4:	0f 8f dd fe ff ff    	jg     c01050b7 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01051da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01051de:	72 1d                	jb     c01051fd <page_init+0x17f>
c01051e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01051e4:	77 09                	ja     c01051ef <page_init+0x171>
c01051e6:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01051ed:	76 0e                	jbe    c01051fd <page_init+0x17f>
        maxpa = KMEMSIZE;
c01051ef:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01051f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01051fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105200:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105203:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105207:	c1 ea 0c             	shr    $0xc,%edx
c010520a:	a3 a0 7f 12 c0       	mov    %eax,0xc0127fa0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010520f:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0105216:	b8 d8 a1 12 c0       	mov    $0xc012a1d8,%eax
c010521b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010521e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105221:	01 d0                	add    %edx,%eax
c0105223:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0105226:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105229:	ba 00 00 00 00       	mov    $0x0,%edx
c010522e:	f7 75 ac             	divl   -0x54(%ebp)
c0105231:	89 d0                	mov    %edx,%eax
c0105233:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105236:	29 c2                	sub    %eax,%edx
c0105238:	89 d0                	mov    %edx,%eax
c010523a:	a3 e4 a0 12 c0       	mov    %eax,0xc012a0e4

    for (i = 0; i < npage; i ++) {
c010523f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105246:	eb 27                	jmp    c010526f <page_init+0x1f1>
        SetPageReserved(pages + i);
c0105248:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c010524d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105250:	c1 e2 05             	shl    $0x5,%edx
c0105253:	01 d0                	add    %edx,%eax
c0105255:	83 c0 04             	add    $0x4,%eax
c0105258:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c010525f:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105262:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105265:	8b 55 90             	mov    -0x70(%ebp),%edx
c0105268:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c010526b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010526f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105272:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0105277:	39 c2                	cmp    %eax,%edx
c0105279:	72 cd                	jb     c0105248 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010527b:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0105280:	c1 e0 05             	shl    $0x5,%eax
c0105283:	89 c2                	mov    %eax,%edx
c0105285:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c010528a:	01 d0                	add    %edx,%eax
c010528c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010528f:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0105296:	77 23                	ja     c01052bb <page_init+0x23d>
c0105298:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010529b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010529f:	c7 44 24 08 00 ae 10 	movl   $0xc010ae00,0x8(%esp)
c01052a6:	c0 
c01052a7:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01052ae:	00 
c01052af:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01052b6:	e8 38 ba ff ff       	call   c0100cf3 <__panic>
c01052bb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01052be:	05 00 00 00 40       	add    $0x40000000,%eax
c01052c3:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01052c6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01052cd:	e9 74 01 00 00       	jmp    c0105446 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01052d2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01052d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052d8:	89 d0                	mov    %edx,%eax
c01052da:	c1 e0 02             	shl    $0x2,%eax
c01052dd:	01 d0                	add    %edx,%eax
c01052df:	c1 e0 02             	shl    $0x2,%eax
c01052e2:	01 c8                	add    %ecx,%eax
c01052e4:	8b 50 08             	mov    0x8(%eax),%edx
c01052e7:	8b 40 04             	mov    0x4(%eax),%eax
c01052ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01052ed:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01052f0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01052f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052f6:	89 d0                	mov    %edx,%eax
c01052f8:	c1 e0 02             	shl    $0x2,%eax
c01052fb:	01 d0                	add    %edx,%eax
c01052fd:	c1 e0 02             	shl    $0x2,%eax
c0105300:	01 c8                	add    %ecx,%eax
c0105302:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105305:	8b 58 10             	mov    0x10(%eax),%ebx
c0105308:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010530b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010530e:	01 c8                	add    %ecx,%eax
c0105310:	11 da                	adc    %ebx,%edx
c0105312:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105315:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0105318:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010531b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010531e:	89 d0                	mov    %edx,%eax
c0105320:	c1 e0 02             	shl    $0x2,%eax
c0105323:	01 d0                	add    %edx,%eax
c0105325:	c1 e0 02             	shl    $0x2,%eax
c0105328:	01 c8                	add    %ecx,%eax
c010532a:	83 c0 14             	add    $0x14,%eax
c010532d:	8b 00                	mov    (%eax),%eax
c010532f:	83 f8 01             	cmp    $0x1,%eax
c0105332:	0f 85 0a 01 00 00    	jne    c0105442 <page_init+0x3c4>
            if (begin < freemem) {
c0105338:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010533b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105340:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105343:	72 17                	jb     c010535c <page_init+0x2de>
c0105345:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105348:	77 05                	ja     c010534f <page_init+0x2d1>
c010534a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010534d:	76 0d                	jbe    c010535c <page_init+0x2de>
                begin = freemem;
c010534f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105352:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105355:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010535c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105360:	72 1d                	jb     c010537f <page_init+0x301>
c0105362:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105366:	77 09                	ja     c0105371 <page_init+0x2f3>
c0105368:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c010536f:	76 0e                	jbe    c010537f <page_init+0x301>
                end = KMEMSIZE;
c0105371:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0105378:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010537f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105382:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105385:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105388:	0f 87 b4 00 00 00    	ja     c0105442 <page_init+0x3c4>
c010538e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105391:	72 09                	jb     c010539c <page_init+0x31e>
c0105393:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105396:	0f 83 a6 00 00 00    	jae    c0105442 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c010539c:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01053a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01053a6:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01053a9:	01 d0                	add    %edx,%eax
c01053ab:	83 e8 01             	sub    $0x1,%eax
c01053ae:	89 45 98             	mov    %eax,-0x68(%ebp)
c01053b1:	8b 45 98             	mov    -0x68(%ebp),%eax
c01053b4:	ba 00 00 00 00       	mov    $0x0,%edx
c01053b9:	f7 75 9c             	divl   -0x64(%ebp)
c01053bc:	89 d0                	mov    %edx,%eax
c01053be:	8b 55 98             	mov    -0x68(%ebp),%edx
c01053c1:	29 c2                	sub    %eax,%edx
c01053c3:	89 d0                	mov    %edx,%eax
c01053c5:	ba 00 00 00 00       	mov    $0x0,%edx
c01053ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01053cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01053d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01053d3:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01053d6:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01053d9:	ba 00 00 00 00       	mov    $0x0,%edx
c01053de:	89 c7                	mov    %eax,%edi
c01053e0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01053e6:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01053e9:	89 d0                	mov    %edx,%eax
c01053eb:	83 e0 00             	and    $0x0,%eax
c01053ee:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01053f1:	8b 45 80             	mov    -0x80(%ebp),%eax
c01053f4:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01053f7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01053fa:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01053fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105400:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105403:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105406:	77 3a                	ja     c0105442 <page_init+0x3c4>
c0105408:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010540b:	72 05                	jb     c0105412 <page_init+0x394>
c010540d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105410:	73 30                	jae    c0105442 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0105412:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0105415:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0105418:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010541b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010541e:	29 c8                	sub    %ecx,%eax
c0105420:	19 da                	sbb    %ebx,%edx
c0105422:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105426:	c1 ea 0c             	shr    $0xc,%edx
c0105429:	89 c3                	mov    %eax,%ebx
c010542b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010542e:	89 04 24             	mov    %eax,(%esp)
c0105431:	e8 8c f8 ff ff       	call   c0104cc2 <pa2page>
c0105436:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010543a:	89 04 24             	mov    %eax,(%esp)
c010543d:	e8 55 fb ff ff       	call   c0104f97 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0105442:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0105446:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105449:	8b 00                	mov    (%eax),%eax
c010544b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010544e:	0f 8f 7e fe ff ff    	jg     c01052d2 <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0105454:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010545a:	5b                   	pop    %ebx
c010545b:	5e                   	pop    %esi
c010545c:	5f                   	pop    %edi
c010545d:	5d                   	pop    %ebp
c010545e:	c3                   	ret    

c010545f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010545f:	55                   	push   %ebp
c0105460:	89 e5                	mov    %esp,%ebp
c0105462:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0105465:	8b 45 14             	mov    0x14(%ebp),%eax
c0105468:	8b 55 0c             	mov    0xc(%ebp),%edx
c010546b:	31 d0                	xor    %edx,%eax
c010546d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105472:	85 c0                	test   %eax,%eax
c0105474:	74 24                	je     c010549a <boot_map_segment+0x3b>
c0105476:	c7 44 24 0c 32 ae 10 	movl   $0xc010ae32,0xc(%esp)
c010547d:	c0 
c010547e:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105485:	c0 
c0105486:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c010548d:	00 
c010548e:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105495:	e8 59 b8 ff ff       	call   c0100cf3 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010549a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01054a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054a4:	25 ff 0f 00 00       	and    $0xfff,%eax
c01054a9:	89 c2                	mov    %eax,%edx
c01054ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01054ae:	01 c2                	add    %eax,%edx
c01054b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054b3:	01 d0                	add    %edx,%eax
c01054b5:	83 e8 01             	sub    $0x1,%eax
c01054b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01054bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054be:	ba 00 00 00 00       	mov    $0x0,%edx
c01054c3:	f7 75 f0             	divl   -0x10(%ebp)
c01054c6:	89 d0                	mov    %edx,%eax
c01054c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054cb:	29 c2                	sub    %eax,%edx
c01054cd:	89 d0                	mov    %edx,%eax
c01054cf:	c1 e8 0c             	shr    $0xc,%eax
c01054d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01054d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01054e3:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01054e6:	8b 45 14             	mov    0x14(%ebp),%eax
c01054e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01054ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01054f4:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01054f7:	eb 6b                	jmp    c0105564 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01054f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105500:	00 
c0105501:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105504:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105508:	8b 45 08             	mov    0x8(%ebp),%eax
c010550b:	89 04 24             	mov    %eax,(%esp)
c010550e:	e8 87 01 00 00       	call   c010569a <get_pte>
c0105513:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0105516:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010551a:	75 24                	jne    c0105540 <boot_map_segment+0xe1>
c010551c:	c7 44 24 0c 5e ae 10 	movl   $0xc010ae5e,0xc(%esp)
c0105523:	c0 
c0105524:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c010552b:	c0 
c010552c:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0105533:	00 
c0105534:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c010553b:	e8 b3 b7 ff ff       	call   c0100cf3 <__panic>
        *ptep = pa | PTE_P | perm;
c0105540:	8b 45 18             	mov    0x18(%ebp),%eax
c0105543:	8b 55 14             	mov    0x14(%ebp),%edx
c0105546:	09 d0                	or     %edx,%eax
c0105548:	83 c8 01             	or     $0x1,%eax
c010554b:	89 c2                	mov    %eax,%edx
c010554d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105550:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0105552:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105556:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010555d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0105564:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105568:	75 8f                	jne    c01054f9 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010556a:	c9                   	leave  
c010556b:	c3                   	ret    

c010556c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010556c:	55                   	push   %ebp
c010556d:	89 e5                	mov    %esp,%ebp
c010556f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0105572:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105579:	e8 38 fa ff ff       	call   c0104fb6 <alloc_pages>
c010557e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0105581:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105585:	75 1c                	jne    c01055a3 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105587:	c7 44 24 08 6b ae 10 	movl   $0xc010ae6b,0x8(%esp)
c010558e:	c0 
c010558f:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105596:	00 
c0105597:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c010559e:	e8 50 b7 ff ff       	call   c0100cf3 <__panic>
    }
    return page2kva(p);
c01055a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055a6:	89 04 24             	mov    %eax,(%esp)
c01055a9:	e8 59 f7 ff ff       	call   c0104d07 <page2kva>
}
c01055ae:	c9                   	leave  
c01055af:	c3                   	ret    

c01055b0 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01055b0:	55                   	push   %ebp
c01055b1:	89 e5                	mov    %esp,%ebp
c01055b3:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01055b6:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c01055bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01055be:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01055c5:	77 23                	ja     c01055ea <pmm_init+0x3a>
c01055c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01055ce:	c7 44 24 08 00 ae 10 	movl   $0xc010ae00,0x8(%esp)
c01055d5:	c0 
c01055d6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01055dd:	00 
c01055de:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01055e5:	e8 09 b7 ff ff       	call   c0100cf3 <__panic>
c01055ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055ed:	05 00 00 00 40       	add    $0x40000000,%eax
c01055f2:	a3 e0 a0 12 c0       	mov    %eax,0xc012a0e0
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01055f7:	e8 68 f9 ff ff       	call   c0104f64 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01055fc:	e8 7d fa ff ff       	call   c010507e <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0105601:	e8 ab 04 00 00       	call   c0105ab1 <check_alloc_page>

    check_pgdir();
c0105606:	e8 c4 04 00 00       	call   c0105acf <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010560b:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105610:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0105616:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c010561b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010561e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105625:	77 23                	ja     c010564a <pmm_init+0x9a>
c0105627:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010562a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010562e:	c7 44 24 08 00 ae 10 	movl   $0xc010ae00,0x8(%esp)
c0105635:	c0 
c0105636:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c010563d:	00 
c010563e:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105645:	e8 a9 b6 ff ff       	call   c0100cf3 <__panic>
c010564a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010564d:	05 00 00 00 40       	add    $0x40000000,%eax
c0105652:	83 c8 03             	or     $0x3,%eax
c0105655:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105657:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c010565c:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105663:	00 
c0105664:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010566b:	00 
c010566c:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105673:	38 
c0105674:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010567b:	c0 
c010567c:	89 04 24             	mov    %eax,(%esp)
c010567f:	e8 db fd ff ff       	call   c010545f <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105684:	e8 ec f7 ff ff       	call   c0104e75 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0105689:	e8 dc 0a 00 00       	call   c010616a <check_boot_pgdir>

    print_pgdir();
c010568e:	e8 64 0f 00 00       	call   c01065f7 <print_pgdir>
    
    kmalloc_init();
c0105693:	e8 69 f3 ff ff       	call   c0104a01 <kmalloc_init>

}
c0105698:	c9                   	leave  
c0105699:	c3                   	ret    

c010569a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010569a:	55                   	push   %ebp
c010569b:	89 e5                	mov    %esp,%ebp
c010569d:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01056a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056a3:	c1 e8 16             	shr    $0x16,%eax
c01056a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01056ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b0:	01 d0                	add    %edx,%eax
c01056b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01056b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056b8:	8b 00                	mov    (%eax),%eax
c01056ba:	83 e0 01             	and    $0x1,%eax
c01056bd:	85 c0                	test   %eax,%eax
c01056bf:	0f 85 af 00 00 00    	jne    c0105774 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01056c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01056c9:	74 15                	je     c01056e0 <get_pte+0x46>
c01056cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01056d2:	e8 df f8 ff ff       	call   c0104fb6 <alloc_pages>
c01056d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056de:	75 0a                	jne    c01056ea <get_pte+0x50>
            return NULL;
c01056e0:	b8 00 00 00 00       	mov    $0x0,%eax
c01056e5:	e9 e6 00 00 00       	jmp    c01057d0 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01056ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01056f1:	00 
c01056f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056f5:	89 04 24             	mov    %eax,(%esp)
c01056f8:	e8 be f6 ff ff       	call   c0104dbb <set_page_ref>
        uintptr_t pa = page2pa(page);
c01056fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105700:	89 04 24             	mov    %eax,(%esp)
c0105703:	e8 a4 f5 ff ff       	call   c0104cac <page2pa>
c0105708:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c010570b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010570e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105711:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105714:	c1 e8 0c             	shr    $0xc,%eax
c0105717:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010571a:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c010571f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105722:	72 23                	jb     c0105747 <get_pte+0xad>
c0105724:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105727:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010572b:	c7 44 24 08 5c ad 10 	movl   $0xc010ad5c,0x8(%esp)
c0105732:	c0 
c0105733:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c010573a:	00 
c010573b:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105742:	e8 ac b5 ff ff       	call   c0100cf3 <__panic>
c0105747:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010574a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010574f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105756:	00 
c0105757:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010575e:	00 
c010575f:	89 04 24             	mov    %eax,(%esp)
c0105762:	e8 f7 46 00 00       	call   c0109e5e <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0105767:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010576a:	83 c8 07             	or     $0x7,%eax
c010576d:	89 c2                	mov    %eax,%edx
c010576f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105772:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0105774:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105777:	8b 00                	mov    (%eax),%eax
c0105779:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010577e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105781:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105784:	c1 e8 0c             	shr    $0xc,%eax
c0105787:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010578a:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c010578f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105792:	72 23                	jb     c01057b7 <get_pte+0x11d>
c0105794:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105797:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010579b:	c7 44 24 08 5c ad 10 	movl   $0xc010ad5c,0x8(%esp)
c01057a2:	c0 
c01057a3:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c01057aa:	00 
c01057ab:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01057b2:	e8 3c b5 ff ff       	call   c0100cf3 <__panic>
c01057b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057ba:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01057bf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057c2:	c1 ea 0c             	shr    $0xc,%edx
c01057c5:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01057cb:	c1 e2 02             	shl    $0x2,%edx
c01057ce:	01 d0                	add    %edx,%eax
}
c01057d0:	c9                   	leave  
c01057d1:	c3                   	ret    

c01057d2 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01057d2:	55                   	push   %ebp
c01057d3:	89 e5                	mov    %esp,%ebp
c01057d5:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01057d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01057df:	00 
c01057e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ea:	89 04 24             	mov    %eax,(%esp)
c01057ed:	e8 a8 fe ff ff       	call   c010569a <get_pte>
c01057f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01057f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01057f9:	74 08                	je     c0105803 <get_page+0x31>
        *ptep_store = ptep;
c01057fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01057fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105801:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105803:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105807:	74 1b                	je     c0105824 <get_page+0x52>
c0105809:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010580c:	8b 00                	mov    (%eax),%eax
c010580e:	83 e0 01             	and    $0x1,%eax
c0105811:	85 c0                	test   %eax,%eax
c0105813:	74 0f                	je     c0105824 <get_page+0x52>
        return pte2page(*ptep);
c0105815:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105818:	8b 00                	mov    (%eax),%eax
c010581a:	89 04 24             	mov    %eax,(%esp)
c010581d:	e8 39 f5 ff ff       	call   c0104d5b <pte2page>
c0105822:	eb 05                	jmp    c0105829 <get_page+0x57>
    }
    return NULL;
c0105824:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105829:	c9                   	leave  
c010582a:	c3                   	ret    

c010582b <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010582b:	55                   	push   %ebp
c010582c:	89 e5                	mov    %esp,%ebp
c010582e:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0105831:	8b 45 10             	mov    0x10(%ebp),%eax
c0105834:	8b 00                	mov    (%eax),%eax
c0105836:	83 e0 01             	and    $0x1,%eax
c0105839:	85 c0                	test   %eax,%eax
c010583b:	74 4d                	je     c010588a <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c010583d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105840:	8b 00                	mov    (%eax),%eax
c0105842:	89 04 24             	mov    %eax,(%esp)
c0105845:	e8 11 f5 ff ff       	call   c0104d5b <pte2page>
c010584a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010584d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105850:	89 04 24             	mov    %eax,(%esp)
c0105853:	e8 87 f5 ff ff       	call   c0104ddf <page_ref_dec>
c0105858:	85 c0                	test   %eax,%eax
c010585a:	75 13                	jne    c010586f <page_remove_pte+0x44>
            free_page(page);
c010585c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105863:	00 
c0105864:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105867:	89 04 24             	mov    %eax,(%esp)
c010586a:	e8 b2 f7 ff ff       	call   c0105021 <free_pages>
        }
        *ptep = 0;
c010586f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105872:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0105878:	8b 45 0c             	mov    0xc(%ebp),%eax
c010587b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010587f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105882:	89 04 24             	mov    %eax,(%esp)
c0105885:	e8 ff 00 00 00       	call   c0105989 <tlb_invalidate>
    }

}
c010588a:	c9                   	leave  
c010588b:	c3                   	ret    

c010588c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010588c:	55                   	push   %ebp
c010588d:	89 e5                	mov    %esp,%ebp
c010588f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105892:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105899:	00 
c010589a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010589d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a4:	89 04 24             	mov    %eax,(%esp)
c01058a7:	e8 ee fd ff ff       	call   c010569a <get_pte>
c01058ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01058af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058b3:	74 19                	je     c01058ce <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01058b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058b8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01058c6:	89 04 24             	mov    %eax,(%esp)
c01058c9:	e8 5d ff ff ff       	call   c010582b <page_remove_pte>
    }
}
c01058ce:	c9                   	leave  
c01058cf:	c3                   	ret    

c01058d0 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01058d0:	55                   	push   %ebp
c01058d1:	89 e5                	mov    %esp,%ebp
c01058d3:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01058d6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01058dd:	00 
c01058de:	8b 45 10             	mov    0x10(%ebp),%eax
c01058e1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01058e8:	89 04 24             	mov    %eax,(%esp)
c01058eb:	e8 aa fd ff ff       	call   c010569a <get_pte>
c01058f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01058f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058f7:	75 0a                	jne    c0105903 <page_insert+0x33>
        return -E_NO_MEM;
c01058f9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01058fe:	e9 84 00 00 00       	jmp    c0105987 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105903:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105906:	89 04 24             	mov    %eax,(%esp)
c0105909:	e8 ba f4 ff ff       	call   c0104dc8 <page_ref_inc>
    if (*ptep & PTE_P) {
c010590e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105911:	8b 00                	mov    (%eax),%eax
c0105913:	83 e0 01             	and    $0x1,%eax
c0105916:	85 c0                	test   %eax,%eax
c0105918:	74 3e                	je     c0105958 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010591a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010591d:	8b 00                	mov    (%eax),%eax
c010591f:	89 04 24             	mov    %eax,(%esp)
c0105922:	e8 34 f4 ff ff       	call   c0104d5b <pte2page>
c0105927:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010592a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010592d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105930:	75 0d                	jne    c010593f <page_insert+0x6f>
            page_ref_dec(page);
c0105932:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105935:	89 04 24             	mov    %eax,(%esp)
c0105938:	e8 a2 f4 ff ff       	call   c0104ddf <page_ref_dec>
c010593d:	eb 19                	jmp    c0105958 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010593f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105942:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105946:	8b 45 10             	mov    0x10(%ebp),%eax
c0105949:	89 44 24 04          	mov    %eax,0x4(%esp)
c010594d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105950:	89 04 24             	mov    %eax,(%esp)
c0105953:	e8 d3 fe ff ff       	call   c010582b <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105958:	8b 45 0c             	mov    0xc(%ebp),%eax
c010595b:	89 04 24             	mov    %eax,(%esp)
c010595e:	e8 49 f3 ff ff       	call   c0104cac <page2pa>
c0105963:	0b 45 14             	or     0x14(%ebp),%eax
c0105966:	83 c8 01             	or     $0x1,%eax
c0105969:	89 c2                	mov    %eax,%edx
c010596b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010596e:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105970:	8b 45 10             	mov    0x10(%ebp),%eax
c0105973:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105977:	8b 45 08             	mov    0x8(%ebp),%eax
c010597a:	89 04 24             	mov    %eax,(%esp)
c010597d:	e8 07 00 00 00       	call   c0105989 <tlb_invalidate>
    return 0;
c0105982:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105987:	c9                   	leave  
c0105988:	c3                   	ret    

c0105989 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105989:	55                   	push   %ebp
c010598a:	89 e5                	mov    %esp,%ebp
c010598c:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010598f:	0f 20 d8             	mov    %cr3,%eax
c0105992:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105995:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0105998:	89 c2                	mov    %eax,%edx
c010599a:	8b 45 08             	mov    0x8(%ebp),%eax
c010599d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059a0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01059a7:	77 23                	ja     c01059cc <tlb_invalidate+0x43>
c01059a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059b0:	c7 44 24 08 00 ae 10 	movl   $0xc010ae00,0x8(%esp)
c01059b7:	c0 
c01059b8:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c01059bf:	00 
c01059c0:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01059c7:	e8 27 b3 ff ff       	call   c0100cf3 <__panic>
c01059cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059cf:	05 00 00 00 40       	add    $0x40000000,%eax
c01059d4:	39 c2                	cmp    %eax,%edx
c01059d6:	75 0c                	jne    c01059e4 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01059d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059db:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01059de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059e1:	0f 01 38             	invlpg (%eax)
    }
}
c01059e4:	c9                   	leave  
c01059e5:	c3                   	ret    

c01059e6 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01059e6:	55                   	push   %ebp
c01059e7:	89 e5                	mov    %esp,%ebp
c01059e9:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01059ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01059f3:	e8 be f5 ff ff       	call   c0104fb6 <alloc_pages>
c01059f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01059fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01059ff:	0f 84 a7 00 00 00    	je     c0105aac <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105a05:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a1d:	89 04 24             	mov    %eax,(%esp)
c0105a20:	e8 ab fe ff ff       	call   c01058d0 <page_insert>
c0105a25:	85 c0                	test   %eax,%eax
c0105a27:	74 1a                	je     c0105a43 <pgdir_alloc_page+0x5d>
            free_page(page);
c0105a29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a30:	00 
c0105a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a34:	89 04 24             	mov    %eax,(%esp)
c0105a37:	e8 e5 f5 ff ff       	call   c0105021 <free_pages>
            return NULL;
c0105a3c:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a41:	eb 6c                	jmp    c0105aaf <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105a43:	a1 2c 80 12 c0       	mov    0xc012802c,%eax
c0105a48:	85 c0                	test   %eax,%eax
c0105a4a:	74 60                	je     c0105aac <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0105a4c:	a1 cc a1 12 c0       	mov    0xc012a1cc,%eax
c0105a51:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105a58:	00 
c0105a59:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a5c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105a60:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a63:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a67:	89 04 24             	mov    %eax,(%esp)
c0105a6a:	e8 39 0e 00 00       	call   c01068a8 <swap_map_swappable>
            page->pra_vaddr=la;
c0105a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a72:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a75:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0105a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a7b:	89 04 24             	mov    %eax,(%esp)
c0105a7e:	e8 2e f3 ff ff       	call   c0104db1 <page_ref>
c0105a83:	83 f8 01             	cmp    $0x1,%eax
c0105a86:	74 24                	je     c0105aac <pgdir_alloc_page+0xc6>
c0105a88:	c7 44 24 0c 84 ae 10 	movl   $0xc010ae84,0xc(%esp)
c0105a8f:	c0 
c0105a90:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105a97:	c0 
c0105a98:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0105a9f:	00 
c0105aa0:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105aa7:	e8 47 b2 ff ff       	call   c0100cf3 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0105aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105aaf:	c9                   	leave  
c0105ab0:	c3                   	ret    

c0105ab1 <check_alloc_page>:

static void
check_alloc_page(void) {
c0105ab1:	55                   	push   %ebp
c0105ab2:	89 e5                	mov    %esp,%ebp
c0105ab4:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0105ab7:	a1 dc a0 12 c0       	mov    0xc012a0dc,%eax
c0105abc:	8b 40 18             	mov    0x18(%eax),%eax
c0105abf:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0105ac1:	c7 04 24 98 ae 10 c0 	movl   $0xc010ae98,(%esp)
c0105ac8:	e8 92 a8 ff ff       	call   c010035f <cprintf>
}
c0105acd:	c9                   	leave  
c0105ace:	c3                   	ret    

c0105acf <check_pgdir>:

static void
check_pgdir(void) {
c0105acf:	55                   	push   %ebp
c0105ad0:	89 e5                	mov    %esp,%ebp
c0105ad2:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105ad5:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0105ada:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0105adf:	76 24                	jbe    c0105b05 <check_pgdir+0x36>
c0105ae1:	c7 44 24 0c b7 ae 10 	movl   $0xc010aeb7,0xc(%esp)
c0105ae8:	c0 
c0105ae9:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105af0:	c0 
c0105af1:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0105af8:	00 
c0105af9:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105b00:	e8 ee b1 ff ff       	call   c0100cf3 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105b05:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105b0a:	85 c0                	test   %eax,%eax
c0105b0c:	74 0e                	je     c0105b1c <check_pgdir+0x4d>
c0105b0e:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105b13:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b18:	85 c0                	test   %eax,%eax
c0105b1a:	74 24                	je     c0105b40 <check_pgdir+0x71>
c0105b1c:	c7 44 24 0c d4 ae 10 	movl   $0xc010aed4,0xc(%esp)
c0105b23:	c0 
c0105b24:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105b2b:	c0 
c0105b2c:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0105b33:	00 
c0105b34:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105b3b:	e8 b3 b1 ff ff       	call   c0100cf3 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105b40:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105b45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b4c:	00 
c0105b4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105b54:	00 
c0105b55:	89 04 24             	mov    %eax,(%esp)
c0105b58:	e8 75 fc ff ff       	call   c01057d2 <get_page>
c0105b5d:	85 c0                	test   %eax,%eax
c0105b5f:	74 24                	je     c0105b85 <check_pgdir+0xb6>
c0105b61:	c7 44 24 0c 0c af 10 	movl   $0xc010af0c,0xc(%esp)
c0105b68:	c0 
c0105b69:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105b70:	c0 
c0105b71:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0105b78:	00 
c0105b79:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105b80:	e8 6e b1 ff ff       	call   c0100cf3 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105b85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105b8c:	e8 25 f4 ff ff       	call   c0104fb6 <alloc_pages>
c0105b91:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105b94:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105b99:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105ba0:	00 
c0105ba1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105ba8:	00 
c0105ba9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105bac:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105bb0:	89 04 24             	mov    %eax,(%esp)
c0105bb3:	e8 18 fd ff ff       	call   c01058d0 <page_insert>
c0105bb8:	85 c0                	test   %eax,%eax
c0105bba:	74 24                	je     c0105be0 <check_pgdir+0x111>
c0105bbc:	c7 44 24 0c 34 af 10 	movl   $0xc010af34,0xc(%esp)
c0105bc3:	c0 
c0105bc4:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105bcb:	c0 
c0105bcc:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105bd3:	00 
c0105bd4:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105bdb:	e8 13 b1 ff ff       	call   c0100cf3 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0105be0:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105be5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105bec:	00 
c0105bed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105bf4:	00 
c0105bf5:	89 04 24             	mov    %eax,(%esp)
c0105bf8:	e8 9d fa ff ff       	call   c010569a <get_pte>
c0105bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105c04:	75 24                	jne    c0105c2a <check_pgdir+0x15b>
c0105c06:	c7 44 24 0c 60 af 10 	movl   $0xc010af60,0xc(%esp)
c0105c0d:	c0 
c0105c0e:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105c15:	c0 
c0105c16:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0105c1d:	00 
c0105c1e:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105c25:	e8 c9 b0 ff ff       	call   c0100cf3 <__panic>
    assert(pte2page(*ptep) == p1);
c0105c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c2d:	8b 00                	mov    (%eax),%eax
c0105c2f:	89 04 24             	mov    %eax,(%esp)
c0105c32:	e8 24 f1 ff ff       	call   c0104d5b <pte2page>
c0105c37:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105c3a:	74 24                	je     c0105c60 <check_pgdir+0x191>
c0105c3c:	c7 44 24 0c 8d af 10 	movl   $0xc010af8d,0xc(%esp)
c0105c43:	c0 
c0105c44:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105c4b:	c0 
c0105c4c:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0105c53:	00 
c0105c54:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105c5b:	e8 93 b0 ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p1) == 1);
c0105c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c63:	89 04 24             	mov    %eax,(%esp)
c0105c66:	e8 46 f1 ff ff       	call   c0104db1 <page_ref>
c0105c6b:	83 f8 01             	cmp    $0x1,%eax
c0105c6e:	74 24                	je     c0105c94 <check_pgdir+0x1c5>
c0105c70:	c7 44 24 0c a3 af 10 	movl   $0xc010afa3,0xc(%esp)
c0105c77:	c0 
c0105c78:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105c7f:	c0 
c0105c80:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0105c87:	00 
c0105c88:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105c8f:	e8 5f b0 ff ff       	call   c0100cf3 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105c94:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105c99:	8b 00                	mov    (%eax),%eax
c0105c9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105ca0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ca6:	c1 e8 0c             	shr    $0xc,%eax
c0105ca9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105cac:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0105cb1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105cb4:	72 23                	jb     c0105cd9 <check_pgdir+0x20a>
c0105cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105cbd:	c7 44 24 08 5c ad 10 	movl   $0xc010ad5c,0x8(%esp)
c0105cc4:	c0 
c0105cc5:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105ccc:	00 
c0105ccd:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105cd4:	e8 1a b0 ff ff       	call   c0100cf3 <__panic>
c0105cd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105cdc:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105ce1:	83 c0 04             	add    $0x4,%eax
c0105ce4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0105ce7:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105cec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105cf3:	00 
c0105cf4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105cfb:	00 
c0105cfc:	89 04 24             	mov    %eax,(%esp)
c0105cff:	e8 96 f9 ff ff       	call   c010569a <get_pte>
c0105d04:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105d07:	74 24                	je     c0105d2d <check_pgdir+0x25e>
c0105d09:	c7 44 24 0c b8 af 10 	movl   $0xc010afb8,0xc(%esp)
c0105d10:	c0 
c0105d11:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105d18:	c0 
c0105d19:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0105d20:	00 
c0105d21:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105d28:	e8 c6 af ff ff       	call   c0100cf3 <__panic>

    p2 = alloc_page();
c0105d2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105d34:	e8 7d f2 ff ff       	call   c0104fb6 <alloc_pages>
c0105d39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105d3c:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105d41:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0105d48:	00 
c0105d49:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105d50:	00 
c0105d51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105d54:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d58:	89 04 24             	mov    %eax,(%esp)
c0105d5b:	e8 70 fb ff ff       	call   c01058d0 <page_insert>
c0105d60:	85 c0                	test   %eax,%eax
c0105d62:	74 24                	je     c0105d88 <check_pgdir+0x2b9>
c0105d64:	c7 44 24 0c e0 af 10 	movl   $0xc010afe0,0xc(%esp)
c0105d6b:	c0 
c0105d6c:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105d73:	c0 
c0105d74:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0105d7b:	00 
c0105d7c:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105d83:	e8 6b af ff ff       	call   c0100cf3 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105d88:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105d8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105d94:	00 
c0105d95:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105d9c:	00 
c0105d9d:	89 04 24             	mov    %eax,(%esp)
c0105da0:	e8 f5 f8 ff ff       	call   c010569a <get_pte>
c0105da5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105da8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105dac:	75 24                	jne    c0105dd2 <check_pgdir+0x303>
c0105dae:	c7 44 24 0c 18 b0 10 	movl   $0xc010b018,0xc(%esp)
c0105db5:	c0 
c0105db6:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105dbd:	c0 
c0105dbe:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105dc5:	00 
c0105dc6:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105dcd:	e8 21 af ff ff       	call   c0100cf3 <__panic>
    assert(*ptep & PTE_U);
c0105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dd5:	8b 00                	mov    (%eax),%eax
c0105dd7:	83 e0 04             	and    $0x4,%eax
c0105dda:	85 c0                	test   %eax,%eax
c0105ddc:	75 24                	jne    c0105e02 <check_pgdir+0x333>
c0105dde:	c7 44 24 0c 48 b0 10 	movl   $0xc010b048,0xc(%esp)
c0105de5:	c0 
c0105de6:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105ded:	c0 
c0105dee:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0105df5:	00 
c0105df6:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105dfd:	e8 f1 ae ff ff       	call   c0100cf3 <__panic>
    assert(*ptep & PTE_W);
c0105e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e05:	8b 00                	mov    (%eax),%eax
c0105e07:	83 e0 02             	and    $0x2,%eax
c0105e0a:	85 c0                	test   %eax,%eax
c0105e0c:	75 24                	jne    c0105e32 <check_pgdir+0x363>
c0105e0e:	c7 44 24 0c 56 b0 10 	movl   $0xc010b056,0xc(%esp)
c0105e15:	c0 
c0105e16:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105e1d:	c0 
c0105e1e:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0105e25:	00 
c0105e26:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105e2d:	e8 c1 ae ff ff       	call   c0100cf3 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105e32:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105e37:	8b 00                	mov    (%eax),%eax
c0105e39:	83 e0 04             	and    $0x4,%eax
c0105e3c:	85 c0                	test   %eax,%eax
c0105e3e:	75 24                	jne    c0105e64 <check_pgdir+0x395>
c0105e40:	c7 44 24 0c 64 b0 10 	movl   $0xc010b064,0xc(%esp)
c0105e47:	c0 
c0105e48:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105e4f:	c0 
c0105e50:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0105e57:	00 
c0105e58:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105e5f:	e8 8f ae ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p2) == 1);
c0105e64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e67:	89 04 24             	mov    %eax,(%esp)
c0105e6a:	e8 42 ef ff ff       	call   c0104db1 <page_ref>
c0105e6f:	83 f8 01             	cmp    $0x1,%eax
c0105e72:	74 24                	je     c0105e98 <check_pgdir+0x3c9>
c0105e74:	c7 44 24 0c 7a b0 10 	movl   $0xc010b07a,0xc(%esp)
c0105e7b:	c0 
c0105e7c:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105e83:	c0 
c0105e84:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0105e8b:	00 
c0105e8c:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105e93:	e8 5b ae ff ff       	call   c0100cf3 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105e98:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105e9d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105ea4:	00 
c0105ea5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105eac:	00 
c0105ead:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105eb0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105eb4:	89 04 24             	mov    %eax,(%esp)
c0105eb7:	e8 14 fa ff ff       	call   c01058d0 <page_insert>
c0105ebc:	85 c0                	test   %eax,%eax
c0105ebe:	74 24                	je     c0105ee4 <check_pgdir+0x415>
c0105ec0:	c7 44 24 0c 8c b0 10 	movl   $0xc010b08c,0xc(%esp)
c0105ec7:	c0 
c0105ec8:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105ecf:	c0 
c0105ed0:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105ed7:	00 
c0105ed8:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105edf:	e8 0f ae ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p1) == 2);
c0105ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ee7:	89 04 24             	mov    %eax,(%esp)
c0105eea:	e8 c2 ee ff ff       	call   c0104db1 <page_ref>
c0105eef:	83 f8 02             	cmp    $0x2,%eax
c0105ef2:	74 24                	je     c0105f18 <check_pgdir+0x449>
c0105ef4:	c7 44 24 0c b8 b0 10 	movl   $0xc010b0b8,0xc(%esp)
c0105efb:	c0 
c0105efc:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105f03:	c0 
c0105f04:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0105f0b:	00 
c0105f0c:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105f13:	e8 db ad ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p2) == 0);
c0105f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f1b:	89 04 24             	mov    %eax,(%esp)
c0105f1e:	e8 8e ee ff ff       	call   c0104db1 <page_ref>
c0105f23:	85 c0                	test   %eax,%eax
c0105f25:	74 24                	je     c0105f4b <check_pgdir+0x47c>
c0105f27:	c7 44 24 0c ca b0 10 	movl   $0xc010b0ca,0xc(%esp)
c0105f2e:	c0 
c0105f2f:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105f36:	c0 
c0105f37:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0105f3e:	00 
c0105f3f:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105f46:	e8 a8 ad ff ff       	call   c0100cf3 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105f4b:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0105f50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105f57:	00 
c0105f58:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105f5f:	00 
c0105f60:	89 04 24             	mov    %eax,(%esp)
c0105f63:	e8 32 f7 ff ff       	call   c010569a <get_pte>
c0105f68:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105f6f:	75 24                	jne    c0105f95 <check_pgdir+0x4c6>
c0105f71:	c7 44 24 0c 18 b0 10 	movl   $0xc010b018,0xc(%esp)
c0105f78:	c0 
c0105f79:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105f80:	c0 
c0105f81:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0105f88:	00 
c0105f89:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105f90:	e8 5e ad ff ff       	call   c0100cf3 <__panic>
    assert(pte2page(*ptep) == p1);
c0105f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f98:	8b 00                	mov    (%eax),%eax
c0105f9a:	89 04 24             	mov    %eax,(%esp)
c0105f9d:	e8 b9 ed ff ff       	call   c0104d5b <pte2page>
c0105fa2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105fa5:	74 24                	je     c0105fcb <check_pgdir+0x4fc>
c0105fa7:	c7 44 24 0c 8d af 10 	movl   $0xc010af8d,0xc(%esp)
c0105fae:	c0 
c0105faf:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105fb6:	c0 
c0105fb7:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0105fbe:	00 
c0105fbf:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105fc6:	e8 28 ad ff ff       	call   c0100cf3 <__panic>
    assert((*ptep & PTE_U) == 0);
c0105fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fce:	8b 00                	mov    (%eax),%eax
c0105fd0:	83 e0 04             	and    $0x4,%eax
c0105fd3:	85 c0                	test   %eax,%eax
c0105fd5:	74 24                	je     c0105ffb <check_pgdir+0x52c>
c0105fd7:	c7 44 24 0c dc b0 10 	movl   $0xc010b0dc,0xc(%esp)
c0105fde:	c0 
c0105fdf:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0105fe6:	c0 
c0105fe7:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0105fee:	00 
c0105fef:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0105ff6:	e8 f8 ac ff ff       	call   c0100cf3 <__panic>

    page_remove(boot_pgdir, 0x0);
c0105ffb:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0106000:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106007:	00 
c0106008:	89 04 24             	mov    %eax,(%esp)
c010600b:	e8 7c f8 ff ff       	call   c010588c <page_remove>
    assert(page_ref(p1) == 1);
c0106010:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106013:	89 04 24             	mov    %eax,(%esp)
c0106016:	e8 96 ed ff ff       	call   c0104db1 <page_ref>
c010601b:	83 f8 01             	cmp    $0x1,%eax
c010601e:	74 24                	je     c0106044 <check_pgdir+0x575>
c0106020:	c7 44 24 0c a3 af 10 	movl   $0xc010afa3,0xc(%esp)
c0106027:	c0 
c0106028:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c010602f:	c0 
c0106030:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0106037:	00 
c0106038:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c010603f:	e8 af ac ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p2) == 0);
c0106044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106047:	89 04 24             	mov    %eax,(%esp)
c010604a:	e8 62 ed ff ff       	call   c0104db1 <page_ref>
c010604f:	85 c0                	test   %eax,%eax
c0106051:	74 24                	je     c0106077 <check_pgdir+0x5a8>
c0106053:	c7 44 24 0c ca b0 10 	movl   $0xc010b0ca,0xc(%esp)
c010605a:	c0 
c010605b:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0106062:	c0 
c0106063:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c010606a:	00 
c010606b:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0106072:	e8 7c ac ff ff       	call   c0100cf3 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0106077:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c010607c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106083:	00 
c0106084:	89 04 24             	mov    %eax,(%esp)
c0106087:	e8 00 f8 ff ff       	call   c010588c <page_remove>
    assert(page_ref(p1) == 0);
c010608c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010608f:	89 04 24             	mov    %eax,(%esp)
c0106092:	e8 1a ed ff ff       	call   c0104db1 <page_ref>
c0106097:	85 c0                	test   %eax,%eax
c0106099:	74 24                	je     c01060bf <check_pgdir+0x5f0>
c010609b:	c7 44 24 0c f1 b0 10 	movl   $0xc010b0f1,0xc(%esp)
c01060a2:	c0 
c01060a3:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c01060aa:	c0 
c01060ab:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c01060b2:	00 
c01060b3:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01060ba:	e8 34 ac ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p2) == 0);
c01060bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060c2:	89 04 24             	mov    %eax,(%esp)
c01060c5:	e8 e7 ec ff ff       	call   c0104db1 <page_ref>
c01060ca:	85 c0                	test   %eax,%eax
c01060cc:	74 24                	je     c01060f2 <check_pgdir+0x623>
c01060ce:	c7 44 24 0c ca b0 10 	movl   $0xc010b0ca,0xc(%esp)
c01060d5:	c0 
c01060d6:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c01060dd:	c0 
c01060de:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c01060e5:	00 
c01060e6:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01060ed:	e8 01 ac ff ff       	call   c0100cf3 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01060f2:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c01060f7:	8b 00                	mov    (%eax),%eax
c01060f9:	89 04 24             	mov    %eax,(%esp)
c01060fc:	e8 98 ec ff ff       	call   c0104d99 <pde2page>
c0106101:	89 04 24             	mov    %eax,(%esp)
c0106104:	e8 a8 ec ff ff       	call   c0104db1 <page_ref>
c0106109:	83 f8 01             	cmp    $0x1,%eax
c010610c:	74 24                	je     c0106132 <check_pgdir+0x663>
c010610e:	c7 44 24 0c 04 b1 10 	movl   $0xc010b104,0xc(%esp)
c0106115:	c0 
c0106116:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c010611d:	c0 
c010611e:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c0106125:	00 
c0106126:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c010612d:	e8 c1 ab ff ff       	call   c0100cf3 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0106132:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0106137:	8b 00                	mov    (%eax),%eax
c0106139:	89 04 24             	mov    %eax,(%esp)
c010613c:	e8 58 ec ff ff       	call   c0104d99 <pde2page>
c0106141:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106148:	00 
c0106149:	89 04 24             	mov    %eax,(%esp)
c010614c:	e8 d0 ee ff ff       	call   c0105021 <free_pages>
    boot_pgdir[0] = 0;
c0106151:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0106156:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c010615c:	c7 04 24 2b b1 10 c0 	movl   $0xc010b12b,(%esp)
c0106163:	e8 f7 a1 ff ff       	call   c010035f <cprintf>
}
c0106168:	c9                   	leave  
c0106169:	c3                   	ret    

c010616a <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c010616a:	55                   	push   %ebp
c010616b:	89 e5                	mov    %esp,%ebp
c010616d:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106170:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106177:	e9 ca 00 00 00       	jmp    c0106246 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c010617c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010617f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106182:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106185:	c1 e8 0c             	shr    $0xc,%eax
c0106188:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010618b:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0106190:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106193:	72 23                	jb     c01061b8 <check_boot_pgdir+0x4e>
c0106195:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106198:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010619c:	c7 44 24 08 5c ad 10 	movl   $0xc010ad5c,0x8(%esp)
c01061a3:	c0 
c01061a4:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c01061ab:	00 
c01061ac:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01061b3:	e8 3b ab ff ff       	call   c0100cf3 <__panic>
c01061b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061bb:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01061c0:	89 c2                	mov    %eax,%edx
c01061c2:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c01061c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01061ce:	00 
c01061cf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061d3:	89 04 24             	mov    %eax,(%esp)
c01061d6:	e8 bf f4 ff ff       	call   c010569a <get_pte>
c01061db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01061de:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01061e2:	75 24                	jne    c0106208 <check_boot_pgdir+0x9e>
c01061e4:	c7 44 24 0c 48 b1 10 	movl   $0xc010b148,0xc(%esp)
c01061eb:	c0 
c01061ec:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c01061f3:	c0 
c01061f4:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c01061fb:	00 
c01061fc:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0106203:	e8 eb aa ff ff       	call   c0100cf3 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0106208:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010620b:	8b 00                	mov    (%eax),%eax
c010620d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106212:	89 c2                	mov    %eax,%edx
c0106214:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106217:	39 c2                	cmp    %eax,%edx
c0106219:	74 24                	je     c010623f <check_boot_pgdir+0xd5>
c010621b:	c7 44 24 0c 85 b1 10 	movl   $0xc010b185,0xc(%esp)
c0106222:	c0 
c0106223:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c010622a:	c0 
c010622b:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c0106232:	00 
c0106233:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c010623a:	e8 b4 aa ff ff       	call   c0100cf3 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010623f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0106246:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106249:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c010624e:	39 c2                	cmp    %eax,%edx
c0106250:	0f 82 26 ff ff ff    	jb     c010617c <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0106256:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c010625b:	05 ac 0f 00 00       	add    $0xfac,%eax
c0106260:	8b 00                	mov    (%eax),%eax
c0106262:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106267:	89 c2                	mov    %eax,%edx
c0106269:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c010626e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106271:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0106278:	77 23                	ja     c010629d <check_boot_pgdir+0x133>
c010627a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010627d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106281:	c7 44 24 08 00 ae 10 	movl   $0xc010ae00,0x8(%esp)
c0106288:	c0 
c0106289:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0106290:	00 
c0106291:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0106298:	e8 56 aa ff ff       	call   c0100cf3 <__panic>
c010629d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062a0:	05 00 00 00 40       	add    $0x40000000,%eax
c01062a5:	39 c2                	cmp    %eax,%edx
c01062a7:	74 24                	je     c01062cd <check_boot_pgdir+0x163>
c01062a9:	c7 44 24 0c 9c b1 10 	movl   $0xc010b19c,0xc(%esp)
c01062b0:	c0 
c01062b1:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c01062b8:	c0 
c01062b9:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c01062c0:	00 
c01062c1:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01062c8:	e8 26 aa ff ff       	call   c0100cf3 <__panic>

    assert(boot_pgdir[0] == 0);
c01062cd:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c01062d2:	8b 00                	mov    (%eax),%eax
c01062d4:	85 c0                	test   %eax,%eax
c01062d6:	74 24                	je     c01062fc <check_boot_pgdir+0x192>
c01062d8:	c7 44 24 0c d0 b1 10 	movl   $0xc010b1d0,0xc(%esp)
c01062df:	c0 
c01062e0:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c01062e7:	c0 
c01062e8:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c01062ef:	00 
c01062f0:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01062f7:	e8 f7 a9 ff ff       	call   c0100cf3 <__panic>

    struct Page *p;
    p = alloc_page();
c01062fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106303:	e8 ae ec ff ff       	call   c0104fb6 <alloc_pages>
c0106308:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010630b:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0106310:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106317:	00 
c0106318:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010631f:	00 
c0106320:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106323:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106327:	89 04 24             	mov    %eax,(%esp)
c010632a:	e8 a1 f5 ff ff       	call   c01058d0 <page_insert>
c010632f:	85 c0                	test   %eax,%eax
c0106331:	74 24                	je     c0106357 <check_boot_pgdir+0x1ed>
c0106333:	c7 44 24 0c e4 b1 10 	movl   $0xc010b1e4,0xc(%esp)
c010633a:	c0 
c010633b:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0106342:	c0 
c0106343:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c010634a:	00 
c010634b:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0106352:	e8 9c a9 ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p) == 1);
c0106357:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010635a:	89 04 24             	mov    %eax,(%esp)
c010635d:	e8 4f ea ff ff       	call   c0104db1 <page_ref>
c0106362:	83 f8 01             	cmp    $0x1,%eax
c0106365:	74 24                	je     c010638b <check_boot_pgdir+0x221>
c0106367:	c7 44 24 0c 12 b2 10 	movl   $0xc010b212,0xc(%esp)
c010636e:	c0 
c010636f:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0106376:	c0 
c0106377:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c010637e:	00 
c010637f:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0106386:	e8 68 a9 ff ff       	call   c0100cf3 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c010638b:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c0106390:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106397:	00 
c0106398:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010639f:	00 
c01063a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01063a3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063a7:	89 04 24             	mov    %eax,(%esp)
c01063aa:	e8 21 f5 ff ff       	call   c01058d0 <page_insert>
c01063af:	85 c0                	test   %eax,%eax
c01063b1:	74 24                	je     c01063d7 <check_boot_pgdir+0x26d>
c01063b3:	c7 44 24 0c 24 b2 10 	movl   $0xc010b224,0xc(%esp)
c01063ba:	c0 
c01063bb:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c01063c2:	c0 
c01063c3:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01063ca:	00 
c01063cb:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01063d2:	e8 1c a9 ff ff       	call   c0100cf3 <__panic>
    assert(page_ref(p) == 2);
c01063d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01063da:	89 04 24             	mov    %eax,(%esp)
c01063dd:	e8 cf e9 ff ff       	call   c0104db1 <page_ref>
c01063e2:	83 f8 02             	cmp    $0x2,%eax
c01063e5:	74 24                	je     c010640b <check_boot_pgdir+0x2a1>
c01063e7:	c7 44 24 0c 5b b2 10 	movl   $0xc010b25b,0xc(%esp)
c01063ee:	c0 
c01063ef:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c01063f6:	c0 
c01063f7:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c01063fe:	00 
c01063ff:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c0106406:	e8 e8 a8 ff ff       	call   c0100cf3 <__panic>

    const char *str = "ucore: Hello world!!";
c010640b:	c7 45 dc 6c b2 10 c0 	movl   $0xc010b26c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0106412:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106415:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106419:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106420:	e8 62 37 00 00       	call   c0109b87 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0106425:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010642c:	00 
c010642d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106434:	e8 c7 37 00 00       	call   c0109c00 <strcmp>
c0106439:	85 c0                	test   %eax,%eax
c010643b:	74 24                	je     c0106461 <check_boot_pgdir+0x2f7>
c010643d:	c7 44 24 0c 84 b2 10 	movl   $0xc010b284,0xc(%esp)
c0106444:	c0 
c0106445:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c010644c:	c0 
c010644d:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c0106454:	00 
c0106455:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c010645c:	e8 92 a8 ff ff       	call   c0100cf3 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106461:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106464:	89 04 24             	mov    %eax,(%esp)
c0106467:	e8 9b e8 ff ff       	call   c0104d07 <page2kva>
c010646c:	05 00 01 00 00       	add    $0x100,%eax
c0106471:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106474:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010647b:	e8 af 36 00 00       	call   c0109b2f <strlen>
c0106480:	85 c0                	test   %eax,%eax
c0106482:	74 24                	je     c01064a8 <check_boot_pgdir+0x33e>
c0106484:	c7 44 24 0c bc b2 10 	movl   $0xc010b2bc,0xc(%esp)
c010648b:	c0 
c010648c:	c7 44 24 08 49 ae 10 	movl   $0xc010ae49,0x8(%esp)
c0106493:	c0 
c0106494:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c010649b:	00 
c010649c:	c7 04 24 24 ae 10 c0 	movl   $0xc010ae24,(%esp)
c01064a3:	e8 4b a8 ff ff       	call   c0100cf3 <__panic>

    free_page(p);
c01064a8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01064af:	00 
c01064b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01064b3:	89 04 24             	mov    %eax,(%esp)
c01064b6:	e8 66 eb ff ff       	call   c0105021 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01064bb:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c01064c0:	8b 00                	mov    (%eax),%eax
c01064c2:	89 04 24             	mov    %eax,(%esp)
c01064c5:	e8 cf e8 ff ff       	call   c0104d99 <pde2page>
c01064ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01064d1:	00 
c01064d2:	89 04 24             	mov    %eax,(%esp)
c01064d5:	e8 47 eb ff ff       	call   c0105021 <free_pages>
    boot_pgdir[0] = 0;
c01064da:	a1 00 4a 12 c0       	mov    0xc0124a00,%eax
c01064df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01064e5:	c7 04 24 e0 b2 10 c0 	movl   $0xc010b2e0,(%esp)
c01064ec:	e8 6e 9e ff ff       	call   c010035f <cprintf>
}
c01064f1:	c9                   	leave  
c01064f2:	c3                   	ret    

c01064f3 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01064f3:	55                   	push   %ebp
c01064f4:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01064f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f9:	83 e0 04             	and    $0x4,%eax
c01064fc:	85 c0                	test   %eax,%eax
c01064fe:	74 07                	je     c0106507 <perm2str+0x14>
c0106500:	b8 75 00 00 00       	mov    $0x75,%eax
c0106505:	eb 05                	jmp    c010650c <perm2str+0x19>
c0106507:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010650c:	a2 28 80 12 c0       	mov    %al,0xc0128028
    str[1] = 'r';
c0106511:	c6 05 29 80 12 c0 72 	movb   $0x72,0xc0128029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106518:	8b 45 08             	mov    0x8(%ebp),%eax
c010651b:	83 e0 02             	and    $0x2,%eax
c010651e:	85 c0                	test   %eax,%eax
c0106520:	74 07                	je     c0106529 <perm2str+0x36>
c0106522:	b8 77 00 00 00       	mov    $0x77,%eax
c0106527:	eb 05                	jmp    c010652e <perm2str+0x3b>
c0106529:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010652e:	a2 2a 80 12 c0       	mov    %al,0xc012802a
    str[3] = '\0';
c0106533:	c6 05 2b 80 12 c0 00 	movb   $0x0,0xc012802b
    return str;
c010653a:	b8 28 80 12 c0       	mov    $0xc0128028,%eax
}
c010653f:	5d                   	pop    %ebp
c0106540:	c3                   	ret    

c0106541 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106541:	55                   	push   %ebp
c0106542:	89 e5                	mov    %esp,%ebp
c0106544:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106547:	8b 45 10             	mov    0x10(%ebp),%eax
c010654a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010654d:	72 0a                	jb     c0106559 <get_pgtable_items+0x18>
        return 0;
c010654f:	b8 00 00 00 00       	mov    $0x0,%eax
c0106554:	e9 9c 00 00 00       	jmp    c01065f5 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106559:	eb 04                	jmp    c010655f <get_pgtable_items+0x1e>
        start ++;
c010655b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c010655f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106562:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106565:	73 18                	jae    c010657f <get_pgtable_items+0x3e>
c0106567:	8b 45 10             	mov    0x10(%ebp),%eax
c010656a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106571:	8b 45 14             	mov    0x14(%ebp),%eax
c0106574:	01 d0                	add    %edx,%eax
c0106576:	8b 00                	mov    (%eax),%eax
c0106578:	83 e0 01             	and    $0x1,%eax
c010657b:	85 c0                	test   %eax,%eax
c010657d:	74 dc                	je     c010655b <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c010657f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106582:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106585:	73 69                	jae    c01065f0 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0106587:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010658b:	74 08                	je     c0106595 <get_pgtable_items+0x54>
            *left_store = start;
c010658d:	8b 45 18             	mov    0x18(%ebp),%eax
c0106590:	8b 55 10             	mov    0x10(%ebp),%edx
c0106593:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106595:	8b 45 10             	mov    0x10(%ebp),%eax
c0106598:	8d 50 01             	lea    0x1(%eax),%edx
c010659b:	89 55 10             	mov    %edx,0x10(%ebp)
c010659e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01065a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01065a8:	01 d0                	add    %edx,%eax
c01065aa:	8b 00                	mov    (%eax),%eax
c01065ac:	83 e0 07             	and    $0x7,%eax
c01065af:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01065b2:	eb 04                	jmp    c01065b8 <get_pgtable_items+0x77>
            start ++;
c01065b4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01065b8:	8b 45 10             	mov    0x10(%ebp),%eax
c01065bb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01065be:	73 1d                	jae    c01065dd <get_pgtable_items+0x9c>
c01065c0:	8b 45 10             	mov    0x10(%ebp),%eax
c01065c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01065ca:	8b 45 14             	mov    0x14(%ebp),%eax
c01065cd:	01 d0                	add    %edx,%eax
c01065cf:	8b 00                	mov    (%eax),%eax
c01065d1:	83 e0 07             	and    $0x7,%eax
c01065d4:	89 c2                	mov    %eax,%edx
c01065d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01065d9:	39 c2                	cmp    %eax,%edx
c01065db:	74 d7                	je     c01065b4 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c01065dd:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01065e1:	74 08                	je     c01065eb <get_pgtable_items+0xaa>
            *right_store = start;
c01065e3:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01065e6:	8b 55 10             	mov    0x10(%ebp),%edx
c01065e9:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01065eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01065ee:	eb 05                	jmp    c01065f5 <get_pgtable_items+0xb4>
    }
    return 0;
c01065f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01065f5:	c9                   	leave  
c01065f6:	c3                   	ret    

c01065f7 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01065f7:	55                   	push   %ebp
c01065f8:	89 e5                	mov    %esp,%ebp
c01065fa:	57                   	push   %edi
c01065fb:	56                   	push   %esi
c01065fc:	53                   	push   %ebx
c01065fd:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106600:	c7 04 24 00 b3 10 c0 	movl   $0xc010b300,(%esp)
c0106607:	e8 53 9d ff ff       	call   c010035f <cprintf>
    size_t left, right = 0, perm;
c010660c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106613:	e9 fa 00 00 00       	jmp    c0106712 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010661b:	89 04 24             	mov    %eax,(%esp)
c010661e:	e8 d0 fe ff ff       	call   c01064f3 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106623:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106626:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106629:	29 d1                	sub    %edx,%ecx
c010662b:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010662d:	89 d6                	mov    %edx,%esi
c010662f:	c1 e6 16             	shl    $0x16,%esi
c0106632:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106635:	89 d3                	mov    %edx,%ebx
c0106637:	c1 e3 16             	shl    $0x16,%ebx
c010663a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010663d:	89 d1                	mov    %edx,%ecx
c010663f:	c1 e1 16             	shl    $0x16,%ecx
c0106642:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0106645:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106648:	29 d7                	sub    %edx,%edi
c010664a:	89 fa                	mov    %edi,%edx
c010664c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106650:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106654:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010665c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106660:	c7 04 24 31 b3 10 c0 	movl   $0xc010b331,(%esp)
c0106667:	e8 f3 9c ff ff       	call   c010035f <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c010666c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010666f:	c1 e0 0a             	shl    $0xa,%eax
c0106672:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106675:	eb 54                	jmp    c01066cb <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106677:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010667a:	89 04 24             	mov    %eax,(%esp)
c010667d:	e8 71 fe ff ff       	call   c01064f3 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106682:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106685:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106688:	29 d1                	sub    %edx,%ecx
c010668a:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010668c:	89 d6                	mov    %edx,%esi
c010668e:	c1 e6 0c             	shl    $0xc,%esi
c0106691:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106694:	89 d3                	mov    %edx,%ebx
c0106696:	c1 e3 0c             	shl    $0xc,%ebx
c0106699:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010669c:	c1 e2 0c             	shl    $0xc,%edx
c010669f:	89 d1                	mov    %edx,%ecx
c01066a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01066a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01066a7:	29 d7                	sub    %edx,%edi
c01066a9:	89 fa                	mov    %edi,%edx
c01066ab:	89 44 24 14          	mov    %eax,0x14(%esp)
c01066af:	89 74 24 10          	mov    %esi,0x10(%esp)
c01066b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01066b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01066bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01066bf:	c7 04 24 50 b3 10 c0 	movl   $0xc010b350,(%esp)
c01066c6:	e8 94 9c ff ff       	call   c010035f <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01066cb:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01066d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01066d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01066d6:	89 ce                	mov    %ecx,%esi
c01066d8:	c1 e6 0a             	shl    $0xa,%esi
c01066db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01066de:	89 cb                	mov    %ecx,%ebx
c01066e0:	c1 e3 0a             	shl    $0xa,%ebx
c01066e3:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01066e6:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01066ea:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01066ed:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01066f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01066f5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01066f9:	89 74 24 04          	mov    %esi,0x4(%esp)
c01066fd:	89 1c 24             	mov    %ebx,(%esp)
c0106700:	e8 3c fe ff ff       	call   c0106541 <get_pgtable_items>
c0106705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106708:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010670c:	0f 85 65 ff ff ff    	jne    c0106677 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106712:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0106717:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010671a:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010671d:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106721:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106724:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106728:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010672c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106730:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106737:	00 
c0106738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010673f:	e8 fd fd ff ff       	call   c0106541 <get_pgtable_items>
c0106744:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106747:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010674b:	0f 85 c7 fe ff ff    	jne    c0106618 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106751:	c7 04 24 74 b3 10 c0 	movl   $0xc010b374,(%esp)
c0106758:	e8 02 9c ff ff       	call   c010035f <cprintf>
}
c010675d:	83 c4 4c             	add    $0x4c,%esp
c0106760:	5b                   	pop    %ebx
c0106761:	5e                   	pop    %esi
c0106762:	5f                   	pop    %edi
c0106763:	5d                   	pop    %ebp
c0106764:	c3                   	ret    

c0106765 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0106765:	55                   	push   %ebp
c0106766:	89 e5                	mov    %esp,%ebp
c0106768:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010676b:	8b 45 08             	mov    0x8(%ebp),%eax
c010676e:	c1 e8 0c             	shr    $0xc,%eax
c0106771:	89 c2                	mov    %eax,%edx
c0106773:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c0106778:	39 c2                	cmp    %eax,%edx
c010677a:	72 1c                	jb     c0106798 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010677c:	c7 44 24 08 a8 b3 10 	movl   $0xc010b3a8,0x8(%esp)
c0106783:	c0 
c0106784:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010678b:	00 
c010678c:	c7 04 24 c7 b3 10 c0 	movl   $0xc010b3c7,(%esp)
c0106793:	e8 5b a5 ff ff       	call   c0100cf3 <__panic>
    }
    return &pages[PPN(pa)];
c0106798:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c010679d:	8b 55 08             	mov    0x8(%ebp),%edx
c01067a0:	c1 ea 0c             	shr    $0xc,%edx
c01067a3:	c1 e2 05             	shl    $0x5,%edx
c01067a6:	01 d0                	add    %edx,%eax
}
c01067a8:	c9                   	leave  
c01067a9:	c3                   	ret    

c01067aa <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01067aa:	55                   	push   %ebp
c01067ab:	89 e5                	mov    %esp,%ebp
c01067ad:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01067b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01067b3:	83 e0 01             	and    $0x1,%eax
c01067b6:	85 c0                	test   %eax,%eax
c01067b8:	75 1c                	jne    c01067d6 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01067ba:	c7 44 24 08 d8 b3 10 	movl   $0xc010b3d8,0x8(%esp)
c01067c1:	c0 
c01067c2:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01067c9:	00 
c01067ca:	c7 04 24 c7 b3 10 c0 	movl   $0xc010b3c7,(%esp)
c01067d1:	e8 1d a5 ff ff       	call   c0100cf3 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01067d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01067de:	89 04 24             	mov    %eax,(%esp)
c01067e1:	e8 7f ff ff ff       	call   c0106765 <pa2page>
}
c01067e6:	c9                   	leave  
c01067e7:	c3                   	ret    

c01067e8 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01067e8:	55                   	push   %ebp
c01067e9:	89 e5                	mov    %esp,%ebp
c01067eb:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01067ee:	e8 79 1e 00 00       	call   c010866c <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01067f3:	a1 9c a1 12 c0       	mov    0xc012a19c,%eax
c01067f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01067fd:	76 0c                	jbe    c010680b <swap_init+0x23>
c01067ff:	a1 9c a1 12 c0       	mov    0xc012a19c,%eax
c0106804:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106809:	76 25                	jbe    c0106830 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c010680b:	a1 9c a1 12 c0       	mov    0xc012a19c,%eax
c0106810:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106814:	c7 44 24 08 f9 b3 10 	movl   $0xc010b3f9,0x8(%esp)
c010681b:	c0 
c010681c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0106823:	00 
c0106824:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c010682b:	e8 c3 a4 ff ff       	call   c0100cf3 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106830:	c7 05 34 80 12 c0 60 	movl   $0xc0124a60,0xc0128034
c0106837:	4a 12 c0 
     int r = sm->init();
c010683a:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c010683f:	8b 40 04             	mov    0x4(%eax),%eax
c0106842:	ff d0                	call   *%eax
c0106844:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106847:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010684b:	75 26                	jne    c0106873 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c010684d:	c7 05 2c 80 12 c0 01 	movl   $0x1,0xc012802c
c0106854:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106857:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c010685c:	8b 00                	mov    (%eax),%eax
c010685e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106862:	c7 04 24 23 b4 10 c0 	movl   $0xc010b423,(%esp)
c0106869:	e8 f1 9a ff ff       	call   c010035f <cprintf>
          check_swap();
c010686e:	e8 a4 04 00 00       	call   c0106d17 <check_swap>
     }

     return r;
c0106873:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106876:	c9                   	leave  
c0106877:	c3                   	ret    

c0106878 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106878:	55                   	push   %ebp
c0106879:	89 e5                	mov    %esp,%ebp
c010687b:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c010687e:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c0106883:	8b 40 08             	mov    0x8(%eax),%eax
c0106886:	8b 55 08             	mov    0x8(%ebp),%edx
c0106889:	89 14 24             	mov    %edx,(%esp)
c010688c:	ff d0                	call   *%eax
}
c010688e:	c9                   	leave  
c010688f:	c3                   	ret    

c0106890 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106890:	55                   	push   %ebp
c0106891:	89 e5                	mov    %esp,%ebp
c0106893:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106896:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c010689b:	8b 40 0c             	mov    0xc(%eax),%eax
c010689e:	8b 55 08             	mov    0x8(%ebp),%edx
c01068a1:	89 14 24             	mov    %edx,(%esp)
c01068a4:	ff d0                	call   *%eax
}
c01068a6:	c9                   	leave  
c01068a7:	c3                   	ret    

c01068a8 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01068a8:	55                   	push   %ebp
c01068a9:	89 e5                	mov    %esp,%ebp
c01068ab:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01068ae:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c01068b3:	8b 40 10             	mov    0x10(%eax),%eax
c01068b6:	8b 55 14             	mov    0x14(%ebp),%edx
c01068b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01068bd:	8b 55 10             	mov    0x10(%ebp),%edx
c01068c0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01068c4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01068c7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01068cb:	8b 55 08             	mov    0x8(%ebp),%edx
c01068ce:	89 14 24             	mov    %edx,(%esp)
c01068d1:	ff d0                	call   *%eax
}
c01068d3:	c9                   	leave  
c01068d4:	c3                   	ret    

c01068d5 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01068d5:	55                   	push   %ebp
c01068d6:	89 e5                	mov    %esp,%ebp
c01068d8:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01068db:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c01068e0:	8b 40 14             	mov    0x14(%eax),%eax
c01068e3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01068e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01068ea:	8b 55 08             	mov    0x8(%ebp),%edx
c01068ed:	89 14 24             	mov    %edx,(%esp)
c01068f0:	ff d0                	call   *%eax
}
c01068f2:	c9                   	leave  
c01068f3:	c3                   	ret    

c01068f4 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01068f4:	55                   	push   %ebp
c01068f5:	89 e5                	mov    %esp,%ebp
c01068f7:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01068fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106901:	e9 5a 01 00 00       	jmp    c0106a60 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106906:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c010690b:	8b 40 18             	mov    0x18(%eax),%eax
c010690e:	8b 55 10             	mov    0x10(%ebp),%edx
c0106911:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106915:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106918:	89 54 24 04          	mov    %edx,0x4(%esp)
c010691c:	8b 55 08             	mov    0x8(%ebp),%edx
c010691f:	89 14 24             	mov    %edx,(%esp)
c0106922:	ff d0                	call   *%eax
c0106924:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010692b:	74 18                	je     c0106945 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c010692d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106930:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106934:	c7 04 24 38 b4 10 c0 	movl   $0xc010b438,(%esp)
c010693b:	e8 1f 9a ff ff       	call   c010035f <cprintf>
c0106940:	e9 27 01 00 00       	jmp    c0106a6c <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106945:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106948:	8b 40 1c             	mov    0x1c(%eax),%eax
c010694b:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010694e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106951:	8b 40 0c             	mov    0xc(%eax),%eax
c0106954:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010695b:	00 
c010695c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010695f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106963:	89 04 24             	mov    %eax,(%esp)
c0106966:	e8 2f ed ff ff       	call   c010569a <get_pte>
c010696b:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010696e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106971:	8b 00                	mov    (%eax),%eax
c0106973:	83 e0 01             	and    $0x1,%eax
c0106976:	85 c0                	test   %eax,%eax
c0106978:	75 24                	jne    c010699e <swap_out+0xaa>
c010697a:	c7 44 24 0c 65 b4 10 	movl   $0xc010b465,0xc(%esp)
c0106981:	c0 
c0106982:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106989:	c0 
c010698a:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0106991:	00 
c0106992:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106999:	e8 55 a3 ff ff       	call   c0100cf3 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c010699e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01069a4:	8b 52 1c             	mov    0x1c(%edx),%edx
c01069a7:	c1 ea 0c             	shr    $0xc,%edx
c01069aa:	83 c2 01             	add    $0x1,%edx
c01069ad:	c1 e2 08             	shl    $0x8,%edx
c01069b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069b4:	89 14 24             	mov    %edx,(%esp)
c01069b7:	e8 6a 1d 00 00       	call   c0108726 <swapfs_write>
c01069bc:	85 c0                	test   %eax,%eax
c01069be:	74 34                	je     c01069f4 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c01069c0:	c7 04 24 8f b4 10 c0 	movl   $0xc010b48f,(%esp)
c01069c7:	e8 93 99 ff ff       	call   c010035f <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01069cc:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c01069d1:	8b 40 10             	mov    0x10(%eax),%eax
c01069d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01069d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01069de:	00 
c01069df:	89 54 24 08          	mov    %edx,0x8(%esp)
c01069e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01069e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069ea:	8b 55 08             	mov    0x8(%ebp),%edx
c01069ed:	89 14 24             	mov    %edx,(%esp)
c01069f0:	ff d0                	call   *%eax
c01069f2:	eb 68                	jmp    c0106a5c <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01069f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069f7:	8b 40 1c             	mov    0x1c(%eax),%eax
c01069fa:	c1 e8 0c             	shr    $0xc,%eax
c01069fd:	83 c0 01             	add    $0x1,%eax
c0106a00:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a07:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a12:	c7 04 24 a8 b4 10 c0 	movl   $0xc010b4a8,(%esp)
c0106a19:	e8 41 99 ff ff       	call   c010035f <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106a1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a21:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106a24:	c1 e8 0c             	shr    $0xc,%eax
c0106a27:	83 c0 01             	add    $0x1,%eax
c0106a2a:	c1 e0 08             	shl    $0x8,%eax
c0106a2d:	89 c2                	mov    %eax,%edx
c0106a2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a32:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a3e:	00 
c0106a3f:	89 04 24             	mov    %eax,(%esp)
c0106a42:	e8 da e5 ff ff       	call   c0105021 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106a47:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a4a:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a50:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a54:	89 04 24             	mov    %eax,(%esp)
c0106a57:	e8 2d ef ff ff       	call   c0105989 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0106a5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a63:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106a66:	0f 85 9a fe ff ff    	jne    c0106906 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0106a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106a6f:	c9                   	leave  
c0106a70:	c3                   	ret    

c0106a71 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106a71:	55                   	push   %ebp
c0106a72:	89 e5                	mov    %esp,%ebp
c0106a74:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106a77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a7e:	e8 33 e5 ff ff       	call   c0104fb6 <alloc_pages>
c0106a83:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106a86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106a8a:	75 24                	jne    c0106ab0 <swap_in+0x3f>
c0106a8c:	c7 44 24 0c e8 b4 10 	movl   $0xc010b4e8,0xc(%esp)
c0106a93:	c0 
c0106a94:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106a9b:	c0 
c0106a9c:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0106aa3:	00 
c0106aa4:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106aab:	e8 43 a2 ff ff       	call   c0100cf3 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ab3:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ab6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106abd:	00 
c0106abe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106ac1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ac5:	89 04 24             	mov    %eax,(%esp)
c0106ac8:	e8 cd eb ff ff       	call   c010569a <get_pte>
c0106acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ad3:	8b 00                	mov    (%eax),%eax
c0106ad5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106ad8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106adc:	89 04 24             	mov    %eax,(%esp)
c0106adf:	e8 d0 1b 00 00       	call   c01086b4 <swapfs_read>
c0106ae4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106ae7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106aeb:	74 2a                	je     c0106b17 <swap_in+0xa6>
     {
        assert(r!=0);
c0106aed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106af1:	75 24                	jne    c0106b17 <swap_in+0xa6>
c0106af3:	c7 44 24 0c f5 b4 10 	movl   $0xc010b4f5,0xc(%esp)
c0106afa:	c0 
c0106afb:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106b02:	c0 
c0106b03:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0106b0a:	00 
c0106b0b:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106b12:	e8 dc a1 ff ff       	call   c0100cf3 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b1a:	8b 00                	mov    (%eax),%eax
c0106b1c:	c1 e8 08             	shr    $0x8,%eax
c0106b1f:	89 c2                	mov    %eax,%edx
c0106b21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b24:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b28:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b2c:	c7 04 24 fc b4 10 c0 	movl   $0xc010b4fc,(%esp)
c0106b33:	e8 27 98 ff ff       	call   c010035f <cprintf>
     *ptr_result=result;
c0106b38:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b3e:	89 10                	mov    %edx,(%eax)
     return 0;
c0106b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106b45:	c9                   	leave  
c0106b46:	c3                   	ret    

c0106b47 <check_content_set>:



static inline void
check_content_set(void)
{
c0106b47:	55                   	push   %ebp
c0106b48:	89 e5                	mov    %esp,%ebp
c0106b4a:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106b4d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106b52:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106b55:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106b5a:	83 f8 01             	cmp    $0x1,%eax
c0106b5d:	74 24                	je     c0106b83 <check_content_set+0x3c>
c0106b5f:	c7 44 24 0c 3a b5 10 	movl   $0xc010b53a,0xc(%esp)
c0106b66:	c0 
c0106b67:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106b6e:	c0 
c0106b6f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0106b76:	00 
c0106b77:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106b7e:	e8 70 a1 ff ff       	call   c0100cf3 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106b83:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106b88:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106b8b:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106b90:	83 f8 01             	cmp    $0x1,%eax
c0106b93:	74 24                	je     c0106bb9 <check_content_set+0x72>
c0106b95:	c7 44 24 0c 3a b5 10 	movl   $0xc010b53a,0xc(%esp)
c0106b9c:	c0 
c0106b9d:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106ba4:	c0 
c0106ba5:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0106bac:	00 
c0106bad:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106bb4:	e8 3a a1 ff ff       	call   c0100cf3 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106bb9:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106bbe:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106bc1:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106bc6:	83 f8 02             	cmp    $0x2,%eax
c0106bc9:	74 24                	je     c0106bef <check_content_set+0xa8>
c0106bcb:	c7 44 24 0c 49 b5 10 	movl   $0xc010b549,0xc(%esp)
c0106bd2:	c0 
c0106bd3:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106bda:	c0 
c0106bdb:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0106be2:	00 
c0106be3:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106bea:	e8 04 a1 ff ff       	call   c0100cf3 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106bef:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106bf4:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106bf7:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106bfc:	83 f8 02             	cmp    $0x2,%eax
c0106bff:	74 24                	je     c0106c25 <check_content_set+0xde>
c0106c01:	c7 44 24 0c 49 b5 10 	movl   $0xc010b549,0xc(%esp)
c0106c08:	c0 
c0106c09:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106c10:	c0 
c0106c11:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106c18:	00 
c0106c19:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106c20:	e8 ce a0 ff ff       	call   c0100cf3 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106c25:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106c2a:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106c2d:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106c32:	83 f8 03             	cmp    $0x3,%eax
c0106c35:	74 24                	je     c0106c5b <check_content_set+0x114>
c0106c37:	c7 44 24 0c 58 b5 10 	movl   $0xc010b558,0xc(%esp)
c0106c3e:	c0 
c0106c3f:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106c46:	c0 
c0106c47:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106c4e:	00 
c0106c4f:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106c56:	e8 98 a0 ff ff       	call   c0100cf3 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106c5b:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106c60:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106c63:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106c68:	83 f8 03             	cmp    $0x3,%eax
c0106c6b:	74 24                	je     c0106c91 <check_content_set+0x14a>
c0106c6d:	c7 44 24 0c 58 b5 10 	movl   $0xc010b558,0xc(%esp)
c0106c74:	c0 
c0106c75:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106c7c:	c0 
c0106c7d:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0106c84:	00 
c0106c85:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106c8c:	e8 62 a0 ff ff       	call   c0100cf3 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106c91:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106c96:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106c99:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106c9e:	83 f8 04             	cmp    $0x4,%eax
c0106ca1:	74 24                	je     c0106cc7 <check_content_set+0x180>
c0106ca3:	c7 44 24 0c 67 b5 10 	movl   $0xc010b567,0xc(%esp)
c0106caa:	c0 
c0106cab:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106cb2:	c0 
c0106cb3:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0106cba:	00 
c0106cbb:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106cc2:	e8 2c a0 ff ff       	call   c0100cf3 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106cc7:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106ccc:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106ccf:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0106cd4:	83 f8 04             	cmp    $0x4,%eax
c0106cd7:	74 24                	je     c0106cfd <check_content_set+0x1b6>
c0106cd9:	c7 44 24 0c 67 b5 10 	movl   $0xc010b567,0xc(%esp)
c0106ce0:	c0 
c0106ce1:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106ce8:	c0 
c0106ce9:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0106cf0:	00 
c0106cf1:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106cf8:	e8 f6 9f ff ff       	call   c0100cf3 <__panic>
}
c0106cfd:	c9                   	leave  
c0106cfe:	c3                   	ret    

c0106cff <check_content_access>:

static inline int
check_content_access(void)
{
c0106cff:	55                   	push   %ebp
c0106d00:	89 e5                	mov    %esp,%ebp
c0106d02:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106d05:	a1 34 80 12 c0       	mov    0xc0128034,%eax
c0106d0a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106d0d:	ff d0                	call   *%eax
c0106d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106d15:	c9                   	leave  
c0106d16:	c3                   	ret    

c0106d17 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106d17:	55                   	push   %ebp
c0106d18:	89 e5                	mov    %esp,%ebp
c0106d1a:	53                   	push   %ebx
c0106d1b:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106d1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106d25:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106d2c:	c7 45 e8 d0 a0 12 c0 	movl   $0xc012a0d0,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106d33:	eb 6b                	jmp    c0106da0 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0106d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d38:	83 e8 0c             	sub    $0xc,%eax
c0106d3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0106d3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d41:	83 c0 04             	add    $0x4,%eax
c0106d44:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106d4b:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106d4e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106d51:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106d54:	0f a3 10             	bt     %edx,(%eax)
c0106d57:	19 c0                	sbb    %eax,%eax
c0106d59:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106d5c:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106d60:	0f 95 c0             	setne  %al
c0106d63:	0f b6 c0             	movzbl %al,%eax
c0106d66:	85 c0                	test   %eax,%eax
c0106d68:	75 24                	jne    c0106d8e <check_swap+0x77>
c0106d6a:	c7 44 24 0c 76 b5 10 	movl   $0xc010b576,0xc(%esp)
c0106d71:	c0 
c0106d72:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106d79:	c0 
c0106d7a:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0106d81:	00 
c0106d82:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106d89:	e8 65 9f ff ff       	call   c0100cf3 <__panic>
        count ++, total += p->property;
c0106d8e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d95:	8b 50 08             	mov    0x8(%eax),%edx
c0106d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d9b:	01 d0                	add    %edx,%eax
c0106d9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106da0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106da3:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106da6:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106da9:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0106dac:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106daf:	81 7d e8 d0 a0 12 c0 	cmpl   $0xc012a0d0,-0x18(%ebp)
c0106db6:	0f 85 79 ff ff ff    	jne    c0106d35 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c0106dbc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0106dbf:	e8 8f e2 ff ff       	call   c0105053 <nr_free_pages>
c0106dc4:	39 c3                	cmp    %eax,%ebx
c0106dc6:	74 24                	je     c0106dec <check_swap+0xd5>
c0106dc8:	c7 44 24 0c 86 b5 10 	movl   $0xc010b586,0xc(%esp)
c0106dcf:	c0 
c0106dd0:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106dd7:	c0 
c0106dd8:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0106ddf:	00 
c0106de0:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106de7:	e8 07 9f ff ff       	call   c0100cf3 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106def:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106df6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106dfa:	c7 04 24 a0 b5 10 c0 	movl   $0xc010b5a0,(%esp)
c0106e01:	e8 59 95 ff ff       	call   c010035f <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106e06:	e8 13 0b 00 00       	call   c010791e <mm_create>
c0106e0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c0106e0e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106e12:	75 24                	jne    c0106e38 <check_swap+0x121>
c0106e14:	c7 44 24 0c c6 b5 10 	movl   $0xc010b5c6,0xc(%esp)
c0106e1b:	c0 
c0106e1c:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106e23:	c0 
c0106e24:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0106e2b:	00 
c0106e2c:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106e33:	e8 bb 9e ff ff       	call   c0100cf3 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106e38:	a1 cc a1 12 c0       	mov    0xc012a1cc,%eax
c0106e3d:	85 c0                	test   %eax,%eax
c0106e3f:	74 24                	je     c0106e65 <check_swap+0x14e>
c0106e41:	c7 44 24 0c d1 b5 10 	movl   $0xc010b5d1,0xc(%esp)
c0106e48:	c0 
c0106e49:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106e50:	c0 
c0106e51:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0106e58:	00 
c0106e59:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106e60:	e8 8e 9e ff ff       	call   c0100cf3 <__panic>

     check_mm_struct = mm;
c0106e65:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e68:	a3 cc a1 12 c0       	mov    %eax,0xc012a1cc

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106e6d:	8b 15 00 4a 12 c0    	mov    0xc0124a00,%edx
c0106e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e76:	89 50 0c             	mov    %edx,0xc(%eax)
c0106e79:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e7c:	8b 40 0c             	mov    0xc(%eax),%eax
c0106e7f:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0106e82:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e85:	8b 00                	mov    (%eax),%eax
c0106e87:	85 c0                	test   %eax,%eax
c0106e89:	74 24                	je     c0106eaf <check_swap+0x198>
c0106e8b:	c7 44 24 0c e9 b5 10 	movl   $0xc010b5e9,0xc(%esp)
c0106e92:	c0 
c0106e93:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106e9a:	c0 
c0106e9b:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0106ea2:	00 
c0106ea3:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106eaa:	e8 44 9e ff ff       	call   c0100cf3 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106eaf:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106eb6:	00 
c0106eb7:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106ebe:	00 
c0106ebf:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0106ec6:	e8 cb 0a 00 00       	call   c0107996 <vma_create>
c0106ecb:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0106ece:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106ed2:	75 24                	jne    c0106ef8 <check_swap+0x1e1>
c0106ed4:	c7 44 24 0c f7 b5 10 	movl   $0xc010b5f7,0xc(%esp)
c0106edb:	c0 
c0106edc:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106ee3:	c0 
c0106ee4:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0106eeb:	00 
c0106eec:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106ef3:	e8 fb 9d ff ff       	call   c0100cf3 <__panic>

     insert_vma_struct(mm, vma);
c0106ef8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106efb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106eff:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f02:	89 04 24             	mov    %eax,(%esp)
c0106f05:	e8 1c 0c 00 00       	call   c0107b26 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106f0a:	c7 04 24 04 b6 10 c0 	movl   $0xc010b604,(%esp)
c0106f11:	e8 49 94 ff ff       	call   c010035f <cprintf>
     pte_t *temp_ptep=NULL;
c0106f16:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f20:	8b 40 0c             	mov    0xc(%eax),%eax
c0106f23:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106f2a:	00 
c0106f2b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106f32:	00 
c0106f33:	89 04 24             	mov    %eax,(%esp)
c0106f36:	e8 5f e7 ff ff       	call   c010569a <get_pte>
c0106f3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0106f3e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0106f42:	75 24                	jne    c0106f68 <check_swap+0x251>
c0106f44:	c7 44 24 0c 38 b6 10 	movl   $0xc010b638,0xc(%esp)
c0106f4b:	c0 
c0106f4c:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106f53:	c0 
c0106f54:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0106f5b:	00 
c0106f5c:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106f63:	e8 8b 9d ff ff       	call   c0100cf3 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106f68:	c7 04 24 4c b6 10 c0 	movl   $0xc010b64c,(%esp)
c0106f6f:	e8 eb 93 ff ff       	call   c010035f <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106f74:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106f7b:	e9 a3 00 00 00       	jmp    c0107023 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0106f80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f87:	e8 2a e0 ff ff       	call   c0104fb6 <alloc_pages>
c0106f8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f8f:	89 04 95 00 a1 12 c0 	mov    %eax,-0x3fed5f00(,%edx,4)
          assert(check_rp[i] != NULL );
c0106f96:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f99:	8b 04 85 00 a1 12 c0 	mov    -0x3fed5f00(,%eax,4),%eax
c0106fa0:	85 c0                	test   %eax,%eax
c0106fa2:	75 24                	jne    c0106fc8 <check_swap+0x2b1>
c0106fa4:	c7 44 24 0c 70 b6 10 	movl   $0xc010b670,0xc(%esp)
c0106fab:	c0 
c0106fac:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0106fb3:	c0 
c0106fb4:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0106fbb:	00 
c0106fbc:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0106fc3:	e8 2b 9d ff ff       	call   c0100cf3 <__panic>
          assert(!PageProperty(check_rp[i]));
c0106fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106fcb:	8b 04 85 00 a1 12 c0 	mov    -0x3fed5f00(,%eax,4),%eax
c0106fd2:	83 c0 04             	add    $0x4,%eax
c0106fd5:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106fdc:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106fdf:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106fe2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106fe5:	0f a3 10             	bt     %edx,(%eax)
c0106fe8:	19 c0                	sbb    %eax,%eax
c0106fea:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106fed:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106ff1:	0f 95 c0             	setne  %al
c0106ff4:	0f b6 c0             	movzbl %al,%eax
c0106ff7:	85 c0                	test   %eax,%eax
c0106ff9:	74 24                	je     c010701f <check_swap+0x308>
c0106ffb:	c7 44 24 0c 84 b6 10 	movl   $0xc010b684,0xc(%esp)
c0107002:	c0 
c0107003:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c010700a:	c0 
c010700b:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0107012:	00 
c0107013:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c010701a:	e8 d4 9c ff ff       	call   c0100cf3 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010701f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107023:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107027:	0f 8e 53 ff ff ff    	jle    c0106f80 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c010702d:	a1 d0 a0 12 c0       	mov    0xc012a0d0,%eax
c0107032:	8b 15 d4 a0 12 c0    	mov    0xc012a0d4,%edx
c0107038:	89 45 98             	mov    %eax,-0x68(%ebp)
c010703b:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010703e:	c7 45 a8 d0 a0 12 c0 	movl   $0xc012a0d0,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107045:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107048:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010704b:	89 50 04             	mov    %edx,0x4(%eax)
c010704e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107051:	8b 50 04             	mov    0x4(%eax),%edx
c0107054:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107057:	89 10                	mov    %edx,(%eax)
c0107059:	c7 45 a4 d0 a0 12 c0 	movl   $0xc012a0d0,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0107060:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107063:	8b 40 04             	mov    0x4(%eax),%eax
c0107066:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0107069:	0f 94 c0             	sete   %al
c010706c:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c010706f:	85 c0                	test   %eax,%eax
c0107071:	75 24                	jne    c0107097 <check_swap+0x380>
c0107073:	c7 44 24 0c 9f b6 10 	movl   $0xc010b69f,0xc(%esp)
c010707a:	c0 
c010707b:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0107082:	c0 
c0107083:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c010708a:	00 
c010708b:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0107092:	e8 5c 9c ff ff       	call   c0100cf3 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0107097:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c010709c:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c010709f:	c7 05 d8 a0 12 c0 00 	movl   $0x0,0xc012a0d8
c01070a6:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01070a9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01070b0:	eb 1e                	jmp    c01070d0 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01070b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01070b5:	8b 04 85 00 a1 12 c0 	mov    -0x3fed5f00(,%eax,4),%eax
c01070bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01070c3:	00 
c01070c4:	89 04 24             	mov    %eax,(%esp)
c01070c7:	e8 55 df ff ff       	call   c0105021 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01070cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01070d0:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01070d4:	7e dc                	jle    c01070b2 <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01070d6:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c01070db:	83 f8 04             	cmp    $0x4,%eax
c01070de:	74 24                	je     c0107104 <check_swap+0x3ed>
c01070e0:	c7 44 24 0c b8 b6 10 	movl   $0xc010b6b8,0xc(%esp)
c01070e7:	c0 
c01070e8:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c01070ef:	c0 
c01070f0:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01070f7:	00 
c01070f8:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c01070ff:	e8 ef 9b ff ff       	call   c0100cf3 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0107104:	c7 04 24 dc b6 10 c0 	movl   $0xc010b6dc,(%esp)
c010710b:	e8 4f 92 ff ff       	call   c010035f <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0107110:	c7 05 38 80 12 c0 00 	movl   $0x0,0xc0128038
c0107117:	00 00 00 
     
     check_content_set();
c010711a:	e8 28 fa ff ff       	call   c0106b47 <check_content_set>
     assert( nr_free == 0);         
c010711f:	a1 d8 a0 12 c0       	mov    0xc012a0d8,%eax
c0107124:	85 c0                	test   %eax,%eax
c0107126:	74 24                	je     c010714c <check_swap+0x435>
c0107128:	c7 44 24 0c 03 b7 10 	movl   $0xc010b703,0xc(%esp)
c010712f:	c0 
c0107130:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0107137:	c0 
c0107138:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010713f:	00 
c0107140:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0107147:	e8 a7 9b ff ff       	call   c0100cf3 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010714c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107153:	eb 26                	jmp    c010717b <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0107155:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107158:	c7 04 85 20 a1 12 c0 	movl   $0xffffffff,-0x3fed5ee0(,%eax,4)
c010715f:	ff ff ff ff 
c0107163:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107166:	8b 14 85 20 a1 12 c0 	mov    -0x3fed5ee0(,%eax,4),%edx
c010716d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107170:	89 14 85 60 a1 12 c0 	mov    %edx,-0x3fed5ea0(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107177:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010717b:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c010717f:	7e d4                	jle    c0107155 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107181:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107188:	e9 eb 00 00 00       	jmp    c0107278 <check_swap+0x561>
         check_ptep[i]=0;
c010718d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107190:	c7 04 85 b4 a1 12 c0 	movl   $0x0,-0x3fed5e4c(,%eax,4)
c0107197:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c010719b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010719e:	83 c0 01             	add    $0x1,%eax
c01071a1:	c1 e0 0c             	shl    $0xc,%eax
c01071a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01071ab:	00 
c01071ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01071b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01071b3:	89 04 24             	mov    %eax,(%esp)
c01071b6:	e8 df e4 ff ff       	call   c010569a <get_pte>
c01071bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01071be:	89 04 95 b4 a1 12 c0 	mov    %eax,-0x3fed5e4c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01071c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071c8:	8b 04 85 b4 a1 12 c0 	mov    -0x3fed5e4c(,%eax,4),%eax
c01071cf:	85 c0                	test   %eax,%eax
c01071d1:	75 24                	jne    c01071f7 <check_swap+0x4e0>
c01071d3:	c7 44 24 0c 10 b7 10 	movl   $0xc010b710,0xc(%esp)
c01071da:	c0 
c01071db:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c01071e2:	c0 
c01071e3:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01071ea:	00 
c01071eb:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c01071f2:	e8 fc 9a ff ff       	call   c0100cf3 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01071f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071fa:	8b 04 85 b4 a1 12 c0 	mov    -0x3fed5e4c(,%eax,4),%eax
c0107201:	8b 00                	mov    (%eax),%eax
c0107203:	89 04 24             	mov    %eax,(%esp)
c0107206:	e8 9f f5 ff ff       	call   c01067aa <pte2page>
c010720b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010720e:	8b 14 95 00 a1 12 c0 	mov    -0x3fed5f00(,%edx,4),%edx
c0107215:	39 d0                	cmp    %edx,%eax
c0107217:	74 24                	je     c010723d <check_swap+0x526>
c0107219:	c7 44 24 0c 28 b7 10 	movl   $0xc010b728,0xc(%esp)
c0107220:	c0 
c0107221:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c0107228:	c0 
c0107229:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0107230:	00 
c0107231:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c0107238:	e8 b6 9a ff ff       	call   c0100cf3 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010723d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107240:	8b 04 85 b4 a1 12 c0 	mov    -0x3fed5e4c(,%eax,4),%eax
c0107247:	8b 00                	mov    (%eax),%eax
c0107249:	83 e0 01             	and    $0x1,%eax
c010724c:	85 c0                	test   %eax,%eax
c010724e:	75 24                	jne    c0107274 <check_swap+0x55d>
c0107250:	c7 44 24 0c 50 b7 10 	movl   $0xc010b750,0xc(%esp)
c0107257:	c0 
c0107258:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c010725f:	c0 
c0107260:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0107267:	00 
c0107268:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c010726f:	e8 7f 9a ff ff       	call   c0100cf3 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107274:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107278:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010727c:	0f 8e 0b ff ff ff    	jle    c010718d <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0107282:	c7 04 24 6c b7 10 c0 	movl   $0xc010b76c,(%esp)
c0107289:	e8 d1 90 ff ff       	call   c010035f <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c010728e:	e8 6c fa ff ff       	call   c0106cff <check_content_access>
c0107293:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0107296:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010729a:	74 24                	je     c01072c0 <check_swap+0x5a9>
c010729c:	c7 44 24 0c 92 b7 10 	movl   $0xc010b792,0xc(%esp)
c01072a3:	c0 
c01072a4:	c7 44 24 08 7a b4 10 	movl   $0xc010b47a,0x8(%esp)
c01072ab:	c0 
c01072ac:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01072b3:	00 
c01072b4:	c7 04 24 14 b4 10 c0 	movl   $0xc010b414,(%esp)
c01072bb:	e8 33 9a ff ff       	call   c0100cf3 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01072c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01072c7:	eb 1e                	jmp    c01072e7 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c01072c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072cc:	8b 04 85 00 a1 12 c0 	mov    -0x3fed5f00(,%eax,4),%eax
c01072d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01072da:	00 
c01072db:	89 04 24             	mov    %eax,(%esp)
c01072de:	e8 3e dd ff ff       	call   c0105021 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01072e3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01072e7:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01072eb:	7e dc                	jle    c01072c9 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c01072ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01072f0:	89 04 24             	mov    %eax,(%esp)
c01072f3:	e8 5e 09 00 00       	call   c0107c56 <mm_destroy>
         
     nr_free = nr_free_store;
c01072f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01072fb:	a3 d8 a0 12 c0       	mov    %eax,0xc012a0d8
     free_list = free_list_store;
c0107300:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107303:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107306:	a3 d0 a0 12 c0       	mov    %eax,0xc012a0d0
c010730b:	89 15 d4 a0 12 c0    	mov    %edx,0xc012a0d4

     
     le = &free_list;
c0107311:	c7 45 e8 d0 a0 12 c0 	movl   $0xc012a0d0,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107318:	eb 1d                	jmp    c0107337 <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c010731a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010731d:	83 e8 0c             	sub    $0xc,%eax
c0107320:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0107323:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107327:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010732a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010732d:	8b 40 08             	mov    0x8(%eax),%eax
c0107330:	29 c2                	sub    %eax,%edx
c0107332:	89 d0                	mov    %edx,%eax
c0107334:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107337:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010733a:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010733d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107340:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0107343:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107346:	81 7d e8 d0 a0 12 c0 	cmpl   $0xc012a0d0,-0x18(%ebp)
c010734d:	75 cb                	jne    c010731a <check_swap+0x603>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c010734f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107352:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107356:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107359:	89 44 24 04          	mov    %eax,0x4(%esp)
c010735d:	c7 04 24 99 b7 10 c0 	movl   $0xc010b799,(%esp)
c0107364:	e8 f6 8f ff ff       	call   c010035f <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107369:	c7 04 24 b3 b7 10 c0 	movl   $0xc010b7b3,(%esp)
c0107370:	e8 ea 8f ff ff       	call   c010035f <cprintf>
}
c0107375:	83 c4 74             	add    $0x74,%esp
c0107378:	5b                   	pop    %ebx
c0107379:	5d                   	pop    %ebp
c010737a:	c3                   	ret    

c010737b <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c010737b:	55                   	push   %ebp
c010737c:	89 e5                	mov    %esp,%ebp
c010737e:	83 ec 10             	sub    $0x10,%esp
c0107381:	c7 45 fc c4 a1 12 c0 	movl   $0xc012a1c4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107388:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010738b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010738e:	89 50 04             	mov    %edx,0x4(%eax)
c0107391:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107394:	8b 50 04             	mov    0x4(%eax),%edx
c0107397:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010739a:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c010739c:	8b 45 08             	mov    0x8(%ebp),%eax
c010739f:	c7 40 14 c4 a1 12 c0 	movl   $0xc012a1c4,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01073a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073ab:	c9                   	leave  
c01073ac:	c3                   	ret    

c01073ad <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01073ad:	55                   	push   %ebp
c01073ae:	89 e5                	mov    %esp,%ebp
c01073b0:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01073b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01073b6:	8b 40 14             	mov    0x14(%eax),%eax
c01073b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01073bc:	8b 45 10             	mov    0x10(%ebp),%eax
c01073bf:	83 c0 14             	add    $0x14,%eax
c01073c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c01073c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01073c9:	74 06                	je     c01073d1 <_fifo_map_swappable+0x24>
c01073cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01073cf:	75 24                	jne    c01073f5 <_fifo_map_swappable+0x48>
c01073d1:	c7 44 24 0c cc b7 10 	movl   $0xc010b7cc,0xc(%esp)
c01073d8:	c0 
c01073d9:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c01073e0:	c0 
c01073e1:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c01073e8:	00 
c01073e9:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c01073f0:	e8 fe 98 ff ff       	call   c0100cf3 <__panic>
c01073f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01073fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107401:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107407:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010740a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010740d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107410:	8b 40 04             	mov    0x4(%eax),%eax
c0107413:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107416:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107419:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010741c:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010741f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0107422:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107425:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107428:	89 10                	mov    %edx,(%eax)
c010742a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010742d:	8b 10                	mov    (%eax),%edx
c010742f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107432:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107435:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107438:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010743b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010743e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107441:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107444:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
	list_add(head, entry);
    return 0;
c0107446:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010744b:	c9                   	leave  
c010744c:	c3                   	ret    

c010744d <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c010744d:	55                   	push   %ebp
c010744e:	89 e5                	mov    %esp,%ebp
c0107450:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107453:	8b 45 08             	mov    0x8(%ebp),%eax
c0107456:	8b 40 14             	mov    0x14(%eax),%eax
c0107459:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c010745c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107460:	75 24                	jne    c0107486 <_fifo_swap_out_victim+0x39>
c0107462:	c7 44 24 0c 13 b8 10 	movl   $0xc010b813,0xc(%esp)
c0107469:	c0 
c010746a:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107471:	c0 
c0107472:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107479:	00 
c010747a:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107481:	e8 6d 98 ff ff       	call   c0100cf3 <__panic>
     assert(in_tick==0);
c0107486:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010748a:	74 24                	je     c01074b0 <_fifo_swap_out_victim+0x63>
c010748c:	c7 44 24 0c 20 b8 10 	movl   $0xc010b820,0xc(%esp)
c0107493:	c0 
c0107494:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c010749b:	c0 
c010749c:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01074a3:	00 
c01074a4:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c01074ab:	e8 43 98 ff ff       	call   c0100cf3 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *le = head->prev;
c01074b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074b3:	8b 00                	mov    (%eax),%eax
c01074b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c01074b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074bb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01074be:	75 24                	jne    c01074e4 <_fifo_swap_out_victim+0x97>
c01074c0:	c7 44 24 0c 2b b8 10 	movl   $0xc010b82b,0xc(%esp)
c01074c7:	c0 
c01074c8:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c01074cf:	c0 
c01074d0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c01074d7:	00 
c01074d8:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c01074df:	e8 0f 98 ff ff       	call   c0100cf3 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c01074e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074e7:	83 e8 14             	sub    $0x14,%eax
c01074ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01074ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01074f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01074f6:	8b 40 04             	mov    0x4(%eax),%eax
c01074f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01074fc:	8b 12                	mov    (%edx),%edx
c01074fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107501:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107507:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010750a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010750d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107510:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107513:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0107515:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107519:	75 24                	jne    c010753f <_fifo_swap_out_victim+0xf2>
c010751b:	c7 44 24 0c 34 b8 10 	movl   $0xc010b834,0xc(%esp)
c0107522:	c0 
c0107523:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c010752a:	c0 
c010752b:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0107532:	00 
c0107533:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c010753a:	e8 b4 97 ff ff       	call   c0100cf3 <__panic>
     *ptr_page = p;
c010753f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107542:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107545:	89 10                	mov    %edx,(%eax)
     return 0;
c0107547:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010754c:	c9                   	leave  
c010754d:	c3                   	ret    

c010754e <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c010754e:	55                   	push   %ebp
c010754f:	89 e5                	mov    %esp,%ebp
c0107551:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107554:	c7 04 24 40 b8 10 c0 	movl   $0xc010b840,(%esp)
c010755b:	e8 ff 8d ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107560:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107565:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107568:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c010756d:	83 f8 04             	cmp    $0x4,%eax
c0107570:	74 24                	je     c0107596 <_fifo_check_swap+0x48>
c0107572:	c7 44 24 0c 66 b8 10 	movl   $0xc010b866,0xc(%esp)
c0107579:	c0 
c010757a:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107581:	c0 
c0107582:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0107589:	00 
c010758a:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107591:	e8 5d 97 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107596:	c7 04 24 78 b8 10 c0 	movl   $0xc010b878,(%esp)
c010759d:	e8 bd 8d ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01075a2:	b8 00 10 00 00       	mov    $0x1000,%eax
c01075a7:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01075aa:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c01075af:	83 f8 04             	cmp    $0x4,%eax
c01075b2:	74 24                	je     c01075d8 <_fifo_check_swap+0x8a>
c01075b4:	c7 44 24 0c 66 b8 10 	movl   $0xc010b866,0xc(%esp)
c01075bb:	c0 
c01075bc:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c01075c3:	c0 
c01075c4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c01075cb:	00 
c01075cc:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c01075d3:	e8 1b 97 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01075d8:	c7 04 24 a0 b8 10 c0 	movl   $0xc010b8a0,(%esp)
c01075df:	e8 7b 8d ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01075e4:	b8 00 40 00 00       	mov    $0x4000,%eax
c01075e9:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c01075ec:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c01075f1:	83 f8 04             	cmp    $0x4,%eax
c01075f4:	74 24                	je     c010761a <_fifo_check_swap+0xcc>
c01075f6:	c7 44 24 0c 66 b8 10 	movl   $0xc010b866,0xc(%esp)
c01075fd:	c0 
c01075fe:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107605:	c0 
c0107606:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c010760d:	00 
c010760e:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107615:	e8 d9 96 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010761a:	c7 04 24 c8 b8 10 c0 	movl   $0xc010b8c8,(%esp)
c0107621:	e8 39 8d ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107626:	b8 00 20 00 00       	mov    $0x2000,%eax
c010762b:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010762e:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0107633:	83 f8 04             	cmp    $0x4,%eax
c0107636:	74 24                	je     c010765c <_fifo_check_swap+0x10e>
c0107638:	c7 44 24 0c 66 b8 10 	movl   $0xc010b866,0xc(%esp)
c010763f:	c0 
c0107640:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107647:	c0 
c0107648:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c010764f:	00 
c0107650:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107657:	e8 97 96 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010765c:	c7 04 24 f0 b8 10 c0 	movl   $0xc010b8f0,(%esp)
c0107663:	e8 f7 8c ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107668:	b8 00 50 00 00       	mov    $0x5000,%eax
c010766d:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0107670:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0107675:	83 f8 05             	cmp    $0x5,%eax
c0107678:	74 24                	je     c010769e <_fifo_check_swap+0x150>
c010767a:	c7 44 24 0c 16 b9 10 	movl   $0xc010b916,0xc(%esp)
c0107681:	c0 
c0107682:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107689:	c0 
c010768a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0107691:	00 
c0107692:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107699:	e8 55 96 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010769e:	c7 04 24 c8 b8 10 c0 	movl   $0xc010b8c8,(%esp)
c01076a5:	e8 b5 8c ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01076aa:	b8 00 20 00 00       	mov    $0x2000,%eax
c01076af:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01076b2:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c01076b7:	83 f8 05             	cmp    $0x5,%eax
c01076ba:	74 24                	je     c01076e0 <_fifo_check_swap+0x192>
c01076bc:	c7 44 24 0c 16 b9 10 	movl   $0xc010b916,0xc(%esp)
c01076c3:	c0 
c01076c4:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c01076cb:	c0 
c01076cc:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c01076d3:	00 
c01076d4:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c01076db:	e8 13 96 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01076e0:	c7 04 24 78 b8 10 c0 	movl   $0xc010b878,(%esp)
c01076e7:	e8 73 8c ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01076ec:	b8 00 10 00 00       	mov    $0x1000,%eax
c01076f1:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c01076f4:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c01076f9:	83 f8 06             	cmp    $0x6,%eax
c01076fc:	74 24                	je     c0107722 <_fifo_check_swap+0x1d4>
c01076fe:	c7 44 24 0c 25 b9 10 	movl   $0xc010b925,0xc(%esp)
c0107705:	c0 
c0107706:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c010770d:	c0 
c010770e:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0107715:	00 
c0107716:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c010771d:	e8 d1 95 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107722:	c7 04 24 c8 b8 10 c0 	movl   $0xc010b8c8,(%esp)
c0107729:	e8 31 8c ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010772e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107733:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107736:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c010773b:	83 f8 07             	cmp    $0x7,%eax
c010773e:	74 24                	je     c0107764 <_fifo_check_swap+0x216>
c0107740:	c7 44 24 0c 34 b9 10 	movl   $0xc010b934,0xc(%esp)
c0107747:	c0 
c0107748:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c010774f:	c0 
c0107750:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107757:	00 
c0107758:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c010775f:	e8 8f 95 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107764:	c7 04 24 40 b8 10 c0 	movl   $0xc010b840,(%esp)
c010776b:	e8 ef 8b ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107770:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107775:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107778:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c010777d:	83 f8 08             	cmp    $0x8,%eax
c0107780:	74 24                	je     c01077a6 <_fifo_check_swap+0x258>
c0107782:	c7 44 24 0c 43 b9 10 	movl   $0xc010b943,0xc(%esp)
c0107789:	c0 
c010778a:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107791:	c0 
c0107792:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107799:	00 
c010779a:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c01077a1:	e8 4d 95 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01077a6:	c7 04 24 a0 b8 10 c0 	movl   $0xc010b8a0,(%esp)
c01077ad:	e8 ad 8b ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01077b2:	b8 00 40 00 00       	mov    $0x4000,%eax
c01077b7:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01077ba:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c01077bf:	83 f8 09             	cmp    $0x9,%eax
c01077c2:	74 24                	je     c01077e8 <_fifo_check_swap+0x29a>
c01077c4:	c7 44 24 0c 52 b9 10 	movl   $0xc010b952,0xc(%esp)
c01077cb:	c0 
c01077cc:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c01077d3:	c0 
c01077d4:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c01077db:	00 
c01077dc:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c01077e3:	e8 0b 95 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01077e8:	c7 04 24 f0 b8 10 c0 	movl   $0xc010b8f0,(%esp)
c01077ef:	e8 6b 8b ff ff       	call   c010035f <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01077f4:	b8 00 50 00 00       	mov    $0x5000,%eax
c01077f9:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01077fc:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0107801:	83 f8 0a             	cmp    $0xa,%eax
c0107804:	74 24                	je     c010782a <_fifo_check_swap+0x2dc>
c0107806:	c7 44 24 0c 61 b9 10 	movl   $0xc010b961,0xc(%esp)
c010780d:	c0 
c010780e:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107815:	c0 
c0107816:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010781d:	00 
c010781e:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107825:	e8 c9 94 ff ff       	call   c0100cf3 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010782a:	c7 04 24 78 b8 10 c0 	movl   $0xc010b878,(%esp)
c0107831:	e8 29 8b ff ff       	call   c010035f <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107836:	b8 00 10 00 00       	mov    $0x1000,%eax
c010783b:	0f b6 00             	movzbl (%eax),%eax
c010783e:	3c 0a                	cmp    $0xa,%al
c0107840:	74 24                	je     c0107866 <_fifo_check_swap+0x318>
c0107842:	c7 44 24 0c 74 b9 10 	movl   $0xc010b974,0xc(%esp)
c0107849:	c0 
c010784a:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107851:	c0 
c0107852:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107859:	00 
c010785a:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107861:	e8 8d 94 ff ff       	call   c0100cf3 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107866:	b8 00 10 00 00       	mov    $0x1000,%eax
c010786b:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c010786e:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c0107873:	83 f8 0b             	cmp    $0xb,%eax
c0107876:	74 24                	je     c010789c <_fifo_check_swap+0x34e>
c0107878:	c7 44 24 0c 95 b9 10 	movl   $0xc010b995,0xc(%esp)
c010787f:	c0 
c0107880:	c7 44 24 08 ea b7 10 	movl   $0xc010b7ea,0x8(%esp)
c0107887:	c0 
c0107888:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c010788f:	00 
c0107890:	c7 04 24 ff b7 10 c0 	movl   $0xc010b7ff,(%esp)
c0107897:	e8 57 94 ff ff       	call   c0100cf3 <__panic>
    return 0;
c010789c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01078a1:	c9                   	leave  
c01078a2:	c3                   	ret    

c01078a3 <_fifo_init>:


static int
_fifo_init(void)
{
c01078a3:	55                   	push   %ebp
c01078a4:	89 e5                	mov    %esp,%ebp
    return 0;
c01078a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01078ab:	5d                   	pop    %ebp
c01078ac:	c3                   	ret    

c01078ad <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01078ad:	55                   	push   %ebp
c01078ae:	89 e5                	mov    %esp,%ebp
    return 0;
c01078b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01078b5:	5d                   	pop    %ebp
c01078b6:	c3                   	ret    

c01078b7 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01078b7:	55                   	push   %ebp
c01078b8:	89 e5                	mov    %esp,%ebp
c01078ba:	b8 00 00 00 00       	mov    $0x0,%eax
c01078bf:	5d                   	pop    %ebp
c01078c0:	c3                   	ret    

c01078c1 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c01078c1:	55                   	push   %ebp
c01078c2:	89 e5                	mov    %esp,%ebp
c01078c4:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01078c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01078ca:	c1 e8 0c             	shr    $0xc,%eax
c01078cd:	89 c2                	mov    %eax,%edx
c01078cf:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c01078d4:	39 c2                	cmp    %eax,%edx
c01078d6:	72 1c                	jb     c01078f4 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01078d8:	c7 44 24 08 b8 b9 10 	movl   $0xc010b9b8,0x8(%esp)
c01078df:	c0 
c01078e0:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01078e7:	00 
c01078e8:	c7 04 24 d7 b9 10 c0 	movl   $0xc010b9d7,(%esp)
c01078ef:	e8 ff 93 ff ff       	call   c0100cf3 <__panic>
    }
    return &pages[PPN(pa)];
c01078f4:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c01078f9:	8b 55 08             	mov    0x8(%ebp),%edx
c01078fc:	c1 ea 0c             	shr    $0xc,%edx
c01078ff:	c1 e2 05             	shl    $0x5,%edx
c0107902:	01 d0                	add    %edx,%eax
}
c0107904:	c9                   	leave  
c0107905:	c3                   	ret    

c0107906 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0107906:	55                   	push   %ebp
c0107907:	89 e5                	mov    %esp,%ebp
c0107909:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010790c:	8b 45 08             	mov    0x8(%ebp),%eax
c010790f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107914:	89 04 24             	mov    %eax,(%esp)
c0107917:	e8 a5 ff ff ff       	call   c01078c1 <pa2page>
}
c010791c:	c9                   	leave  
c010791d:	c3                   	ret    

c010791e <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010791e:	55                   	push   %ebp
c010791f:	89 e5                	mov    %esp,%ebp
c0107921:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107924:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010792b:	e8 11 d2 ff ff       	call   c0104b41 <kmalloc>
c0107930:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107933:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107937:	74 58                	je     c0107991 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c0107939:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010793c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010793f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107942:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107945:	89 50 04             	mov    %edx,0x4(%eax)
c0107948:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010794b:	8b 50 04             	mov    0x4(%eax),%edx
c010794e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107951:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0107953:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107956:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c010795d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107960:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107967:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010796a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0107971:	a1 2c 80 12 c0       	mov    0xc012802c,%eax
c0107976:	85 c0                	test   %eax,%eax
c0107978:	74 0d                	je     c0107987 <mm_create+0x69>
c010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010797d:	89 04 24             	mov    %eax,(%esp)
c0107980:	e8 f3 ee ff ff       	call   c0106878 <swap_init_mm>
c0107985:	eb 0a                	jmp    c0107991 <mm_create+0x73>
        else mm->sm_priv = NULL;
c0107987:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010798a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0107991:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107994:	c9                   	leave  
c0107995:	c3                   	ret    

c0107996 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0107996:	55                   	push   %ebp
c0107997:	89 e5                	mov    %esp,%ebp
c0107999:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c010799c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01079a3:	e8 99 d1 ff ff       	call   c0104b41 <kmalloc>
c01079a8:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01079ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01079af:	74 1b                	je     c01079cc <vma_create+0x36>
        vma->vm_start = vm_start;
c01079b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01079b7:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01079ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079bd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01079c0:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01079c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079c6:	8b 55 10             	mov    0x10(%ebp),%edx
c01079c9:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01079cf:	c9                   	leave  
c01079d0:	c3                   	ret    

c01079d1 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01079d1:	55                   	push   %ebp
c01079d2:	89 e5                	mov    %esp,%ebp
c01079d4:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01079d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01079de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01079e2:	0f 84 95 00 00 00    	je     c0107a7d <find_vma+0xac>
        vma = mm->mmap_cache;
c01079e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01079eb:	8b 40 08             	mov    0x8(%eax),%eax
c01079ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01079f1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01079f5:	74 16                	je     c0107a0d <find_vma+0x3c>
c01079f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01079fa:	8b 40 04             	mov    0x4(%eax),%eax
c01079fd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107a00:	77 0b                	ja     c0107a0d <find_vma+0x3c>
c0107a02:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a05:	8b 40 08             	mov    0x8(%eax),%eax
c0107a08:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107a0b:	77 61                	ja     c0107a6e <find_vma+0x9d>
                bool found = 0;
c0107a0d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0107a14:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a17:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0107a20:	eb 28                	jmp    c0107a4a <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0107a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a25:	83 e8 10             	sub    $0x10,%eax
c0107a28:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0107a2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a2e:	8b 40 04             	mov    0x4(%eax),%eax
c0107a31:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107a34:	77 14                	ja     c0107a4a <find_vma+0x79>
c0107a36:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a39:	8b 40 08             	mov    0x8(%eax),%eax
c0107a3c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107a3f:	76 09                	jbe    c0107a4a <find_vma+0x79>
                        found = 1;
c0107a41:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107a48:	eb 17                	jmp    c0107a61 <find_vma+0x90>
c0107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a53:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0107a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a5c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107a5f:	75 c1                	jne    c0107a22 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c0107a61:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0107a65:	75 07                	jne    c0107a6e <find_vma+0x9d>
                    vma = NULL;
c0107a67:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0107a6e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107a72:	74 09                	je     c0107a7d <find_vma+0xac>
            mm->mmap_cache = vma;
c0107a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a77:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107a7a:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0107a7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107a80:	c9                   	leave  
c0107a81:	c3                   	ret    

c0107a82 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0107a82:	55                   	push   %ebp
c0107a83:	89 e5                	mov    %esp,%ebp
c0107a85:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0107a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a8b:	8b 50 04             	mov    0x4(%eax),%edx
c0107a8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a91:	8b 40 08             	mov    0x8(%eax),%eax
c0107a94:	39 c2                	cmp    %eax,%edx
c0107a96:	72 24                	jb     c0107abc <check_vma_overlap+0x3a>
c0107a98:	c7 44 24 0c e5 b9 10 	movl   $0xc010b9e5,0xc(%esp)
c0107a9f:	c0 
c0107aa0:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107aa7:	c0 
c0107aa8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0107aaf:	00 
c0107ab0:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107ab7:	e8 37 92 ff ff       	call   c0100cf3 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0107abc:	8b 45 08             	mov    0x8(%ebp),%eax
c0107abf:	8b 50 08             	mov    0x8(%eax),%edx
c0107ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ac5:	8b 40 04             	mov    0x4(%eax),%eax
c0107ac8:	39 c2                	cmp    %eax,%edx
c0107aca:	76 24                	jbe    c0107af0 <check_vma_overlap+0x6e>
c0107acc:	c7 44 24 0c 28 ba 10 	movl   $0xc010ba28,0xc(%esp)
c0107ad3:	c0 
c0107ad4:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107adb:	c0 
c0107adc:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107ae3:	00 
c0107ae4:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107aeb:	e8 03 92 ff ff       	call   c0100cf3 <__panic>
    assert(next->vm_start < next->vm_end);
c0107af0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107af3:	8b 50 04             	mov    0x4(%eax),%edx
c0107af6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107af9:	8b 40 08             	mov    0x8(%eax),%eax
c0107afc:	39 c2                	cmp    %eax,%edx
c0107afe:	72 24                	jb     c0107b24 <check_vma_overlap+0xa2>
c0107b00:	c7 44 24 0c 47 ba 10 	movl   $0xc010ba47,0xc(%esp)
c0107b07:	c0 
c0107b08:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107b0f:	c0 
c0107b10:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0107b17:	00 
c0107b18:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107b1f:	e8 cf 91 ff ff       	call   c0100cf3 <__panic>
}
c0107b24:	c9                   	leave  
c0107b25:	c3                   	ret    

c0107b26 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107b26:	55                   	push   %ebp
c0107b27:	89 e5                	mov    %esp,%ebp
c0107b29:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0107b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b2f:	8b 50 04             	mov    0x4(%eax),%edx
c0107b32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b35:	8b 40 08             	mov    0x8(%eax),%eax
c0107b38:	39 c2                	cmp    %eax,%edx
c0107b3a:	72 24                	jb     c0107b60 <insert_vma_struct+0x3a>
c0107b3c:	c7 44 24 0c 65 ba 10 	movl   $0xc010ba65,0xc(%esp)
c0107b43:	c0 
c0107b44:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107b4b:	c0 
c0107b4c:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107b53:	00 
c0107b54:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107b5b:	e8 93 91 ff ff       	call   c0100cf3 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0107b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b63:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0107b66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b69:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0107b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0107b72:	eb 21                	jmp    c0107b95 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0107b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b77:	83 e8 10             	sub    $0x10,%eax
c0107b7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0107b7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b80:	8b 50 04             	mov    0x4(%eax),%edx
c0107b83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b86:	8b 40 04             	mov    0x4(%eax),%eax
c0107b89:	39 c2                	cmp    %eax,%edx
c0107b8b:	76 02                	jbe    c0107b8f <insert_vma_struct+0x69>
                break;
c0107b8d:	eb 1d                	jmp    c0107bac <insert_vma_struct+0x86>
            }
            le_prev = le;
c0107b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b92:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b98:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107b9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107b9e:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c0107ba1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ba7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107baa:	75 c8                	jne    c0107b74 <insert_vma_struct+0x4e>
c0107bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107baf:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107bb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bb5:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0107bb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0107bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bbe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107bc1:	74 15                	je     c0107bd8 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bc6:	8d 50 f0             	lea    -0x10(%eax),%edx
c0107bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bd0:	89 14 24             	mov    %edx,(%esp)
c0107bd3:	e8 aa fe ff ff       	call   c0107a82 <check_vma_overlap>
    }
    if (le_next != list) {
c0107bd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bdb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107bde:	74 15                	je     c0107bf5 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0107be0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107be3:	83 e8 10             	sub    $0x10,%eax
c0107be6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bed:	89 04 24             	mov    %eax,(%esp)
c0107bf0:	e8 8d fe ff ff       	call   c0107a82 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0107bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bf8:	8b 55 08             	mov    0x8(%ebp),%edx
c0107bfb:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0107bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c00:	8d 50 10             	lea    0x10(%eax),%edx
c0107c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c06:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107c09:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0107c0c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c0f:	8b 40 04             	mov    0x4(%eax),%eax
c0107c12:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107c15:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107c18:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107c1b:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0107c1e:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0107c21:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107c24:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107c27:	89 10                	mov    %edx,(%eax)
c0107c29:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107c2c:	8b 10                	mov    (%eax),%edx
c0107c2e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107c31:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107c34:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107c37:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107c3a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107c3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107c40:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107c43:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0107c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c48:	8b 40 10             	mov    0x10(%eax),%eax
c0107c4b:	8d 50 01             	lea    0x1(%eax),%edx
c0107c4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c51:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107c54:	c9                   	leave  
c0107c55:	c3                   	ret    

c0107c56 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107c56:	55                   	push   %ebp
c0107c57:	89 e5                	mov    %esp,%ebp
c0107c59:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0107c5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0107c62:	eb 36                	jmp    c0107c9a <mm_destroy+0x44>
c0107c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c67:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c6d:	8b 40 04             	mov    0x4(%eax),%eax
c0107c70:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107c73:	8b 12                	mov    (%edx),%edx
c0107c75:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107c78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107c7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107c81:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c87:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107c8a:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0107c8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c8f:	83 e8 10             	sub    $0x10,%eax
c0107c92:	89 04 24             	mov    %eax,(%esp)
c0107c95:	e8 c2 ce ff ff       	call   c0104b5c <kfree>
c0107c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107ca0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ca3:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0107ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107caf:	75 b3                	jne    c0107c64 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c0107cb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cb4:	89 04 24             	mov    %eax,(%esp)
c0107cb7:	e8 a0 ce ff ff       	call   c0104b5c <kfree>
    mm=NULL;
c0107cbc:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107cc3:	c9                   	leave  
c0107cc4:	c3                   	ret    

c0107cc5 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107cc5:	55                   	push   %ebp
c0107cc6:	89 e5                	mov    %esp,%ebp
c0107cc8:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0107ccb:	e8 02 00 00 00       	call   c0107cd2 <check_vmm>
}
c0107cd0:	c9                   	leave  
c0107cd1:	c3                   	ret    

c0107cd2 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107cd2:	55                   	push   %ebp
c0107cd3:	89 e5                	mov    %esp,%ebp
c0107cd5:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107cd8:	e8 76 d3 ff ff       	call   c0105053 <nr_free_pages>
c0107cdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0107ce0:	e8 13 00 00 00       	call   c0107cf8 <check_vma_struct>
    check_pgfault();
c0107ce5:	e8 a7 04 00 00       	call   c0108191 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0107cea:	c7 04 24 81 ba 10 c0 	movl   $0xc010ba81,(%esp)
c0107cf1:	e8 69 86 ff ff       	call   c010035f <cprintf>
}
c0107cf6:	c9                   	leave  
c0107cf7:	c3                   	ret    

c0107cf8 <check_vma_struct>:

static void
check_vma_struct(void) {
c0107cf8:	55                   	push   %ebp
c0107cf9:	89 e5                	mov    %esp,%ebp
c0107cfb:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107cfe:	e8 50 d3 ff ff       	call   c0105053 <nr_free_pages>
c0107d03:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107d06:	e8 13 fc ff ff       	call   c010791e <mm_create>
c0107d0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107d0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107d12:	75 24                	jne    c0107d38 <check_vma_struct+0x40>
c0107d14:	c7 44 24 0c 99 ba 10 	movl   $0xc010ba99,0xc(%esp)
c0107d1b:	c0 
c0107d1c:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107d23:	c0 
c0107d24:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0107d2b:	00 
c0107d2c:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107d33:	e8 bb 8f ff ff       	call   c0100cf3 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107d38:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107d3f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d42:	89 d0                	mov    %edx,%eax
c0107d44:	c1 e0 02             	shl    $0x2,%eax
c0107d47:	01 d0                	add    %edx,%eax
c0107d49:	01 c0                	add    %eax,%eax
c0107d4b:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107d54:	eb 70                	jmp    c0107dc6 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107d56:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107d59:	89 d0                	mov    %edx,%eax
c0107d5b:	c1 e0 02             	shl    $0x2,%eax
c0107d5e:	01 d0                	add    %edx,%eax
c0107d60:	83 c0 02             	add    $0x2,%eax
c0107d63:	89 c1                	mov    %eax,%ecx
c0107d65:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107d68:	89 d0                	mov    %edx,%eax
c0107d6a:	c1 e0 02             	shl    $0x2,%eax
c0107d6d:	01 d0                	add    %edx,%eax
c0107d6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107d76:	00 
c0107d77:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107d7b:	89 04 24             	mov    %eax,(%esp)
c0107d7e:	e8 13 fc ff ff       	call   c0107996 <vma_create>
c0107d83:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0107d86:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107d8a:	75 24                	jne    c0107db0 <check_vma_struct+0xb8>
c0107d8c:	c7 44 24 0c a4 ba 10 	movl   $0xc010baa4,0xc(%esp)
c0107d93:	c0 
c0107d94:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107d9b:	c0 
c0107d9c:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0107da3:	00 
c0107da4:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107dab:	e8 43 8f ff ff       	call   c0100cf3 <__panic>
        insert_vma_struct(mm, vma);
c0107db0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107db3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107db7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107dba:	89 04 24             	mov    %eax,(%esp)
c0107dbd:	e8 64 fd ff ff       	call   c0107b26 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c0107dc2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107dc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107dca:	7f 8a                	jg     c0107d56 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107dcf:	83 c0 01             	add    $0x1,%eax
c0107dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107dd5:	eb 70                	jmp    c0107e47 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107dd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107dda:	89 d0                	mov    %edx,%eax
c0107ddc:	c1 e0 02             	shl    $0x2,%eax
c0107ddf:	01 d0                	add    %edx,%eax
c0107de1:	83 c0 02             	add    $0x2,%eax
c0107de4:	89 c1                	mov    %eax,%ecx
c0107de6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107de9:	89 d0                	mov    %edx,%eax
c0107deb:	c1 e0 02             	shl    $0x2,%eax
c0107dee:	01 d0                	add    %edx,%eax
c0107df0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107df7:	00 
c0107df8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107dfc:	89 04 24             	mov    %eax,(%esp)
c0107dff:	e8 92 fb ff ff       	call   c0107996 <vma_create>
c0107e04:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0107e07:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107e0b:	75 24                	jne    c0107e31 <check_vma_struct+0x139>
c0107e0d:	c7 44 24 0c a4 ba 10 	movl   $0xc010baa4,0xc(%esp)
c0107e14:	c0 
c0107e15:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107e1c:	c0 
c0107e1d:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0107e24:	00 
c0107e25:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107e2c:	e8 c2 8e ff ff       	call   c0100cf3 <__panic>
        insert_vma_struct(mm, vma);
c0107e31:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107e34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e3b:	89 04 24             	mov    %eax,(%esp)
c0107e3e:	e8 e3 fc ff ff       	call   c0107b26 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107e43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e4a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107e4d:	7e 88                	jle    c0107dd7 <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107e4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e52:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107e55:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107e58:	8b 40 04             	mov    0x4(%eax),%eax
c0107e5b:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107e5e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107e65:	e9 97 00 00 00       	jmp    c0107f01 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c0107e6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e6d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107e70:	75 24                	jne    c0107e96 <check_vma_struct+0x19e>
c0107e72:	c7 44 24 0c b0 ba 10 	movl   $0xc010bab0,0xc(%esp)
c0107e79:	c0 
c0107e7a:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107e81:	c0 
c0107e82:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0107e89:	00 
c0107e8a:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107e91:	e8 5d 8e ff ff       	call   c0100cf3 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e99:	83 e8 10             	sub    $0x10,%eax
c0107e9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107e9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107ea2:	8b 48 04             	mov    0x4(%eax),%ecx
c0107ea5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ea8:	89 d0                	mov    %edx,%eax
c0107eaa:	c1 e0 02             	shl    $0x2,%eax
c0107ead:	01 d0                	add    %edx,%eax
c0107eaf:	39 c1                	cmp    %eax,%ecx
c0107eb1:	75 17                	jne    c0107eca <check_vma_struct+0x1d2>
c0107eb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107eb6:	8b 48 08             	mov    0x8(%eax),%ecx
c0107eb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ebc:	89 d0                	mov    %edx,%eax
c0107ebe:	c1 e0 02             	shl    $0x2,%eax
c0107ec1:	01 d0                	add    %edx,%eax
c0107ec3:	83 c0 02             	add    $0x2,%eax
c0107ec6:	39 c1                	cmp    %eax,%ecx
c0107ec8:	74 24                	je     c0107eee <check_vma_struct+0x1f6>
c0107eca:	c7 44 24 0c c8 ba 10 	movl   $0xc010bac8,0xc(%esp)
c0107ed1:	c0 
c0107ed2:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107ed9:	c0 
c0107eda:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0107ee1:	00 
c0107ee2:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107ee9:	e8 05 8e ff ff       	call   c0100cf3 <__panic>
c0107eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ef1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107ef4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107ef7:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107efa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0107efd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f04:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107f07:	0f 8e 5d ff ff ff    	jle    c0107e6a <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107f0d:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107f14:	e9 cd 01 00 00       	jmp    c01080e6 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f23:	89 04 24             	mov    %eax,(%esp)
c0107f26:	e8 a6 fa ff ff       	call   c01079d1 <find_vma>
c0107f2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0107f2e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107f32:	75 24                	jne    c0107f58 <check_vma_struct+0x260>
c0107f34:	c7 44 24 0c fd ba 10 	movl   $0xc010bafd,0xc(%esp)
c0107f3b:	c0 
c0107f3c:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107f43:	c0 
c0107f44:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0107f4b:	00 
c0107f4c:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107f53:	e8 9b 8d ff ff       	call   c0100cf3 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0107f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f5b:	83 c0 01             	add    $0x1,%eax
c0107f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f62:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f65:	89 04 24             	mov    %eax,(%esp)
c0107f68:	e8 64 fa ff ff       	call   c01079d1 <find_vma>
c0107f6d:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0107f70:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107f74:	75 24                	jne    c0107f9a <check_vma_struct+0x2a2>
c0107f76:	c7 44 24 0c 0a bb 10 	movl   $0xc010bb0a,0xc(%esp)
c0107f7d:	c0 
c0107f7e:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107f85:	c0 
c0107f86:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0107f8d:	00 
c0107f8e:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107f95:	e8 59 8d ff ff       	call   c0100cf3 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0107f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f9d:	83 c0 02             	add    $0x2,%eax
c0107fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107fa4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fa7:	89 04 24             	mov    %eax,(%esp)
c0107faa:	e8 22 fa ff ff       	call   c01079d1 <find_vma>
c0107faf:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0107fb2:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107fb6:	74 24                	je     c0107fdc <check_vma_struct+0x2e4>
c0107fb8:	c7 44 24 0c 17 bb 10 	movl   $0xc010bb17,0xc(%esp)
c0107fbf:	c0 
c0107fc0:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0107fc7:	c0 
c0107fc8:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0107fcf:	00 
c0107fd0:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0107fd7:	e8 17 8d ff ff       	call   c0100cf3 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0107fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fdf:	83 c0 03             	add    $0x3,%eax
c0107fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107fe6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fe9:	89 04 24             	mov    %eax,(%esp)
c0107fec:	e8 e0 f9 ff ff       	call   c01079d1 <find_vma>
c0107ff1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0107ff4:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0107ff8:	74 24                	je     c010801e <check_vma_struct+0x326>
c0107ffa:	c7 44 24 0c 24 bb 10 	movl   $0xc010bb24,0xc(%esp)
c0108001:	c0 
c0108002:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0108009:	c0 
c010800a:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0108011:	00 
c0108012:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0108019:	e8 d5 8c ff ff       	call   c0100cf3 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c010801e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108021:	83 c0 04             	add    $0x4,%eax
c0108024:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108028:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010802b:	89 04 24             	mov    %eax,(%esp)
c010802e:	e8 9e f9 ff ff       	call   c01079d1 <find_vma>
c0108033:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0108036:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010803a:	74 24                	je     c0108060 <check_vma_struct+0x368>
c010803c:	c7 44 24 0c 31 bb 10 	movl   $0xc010bb31,0xc(%esp)
c0108043:	c0 
c0108044:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c010804b:	c0 
c010804c:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0108053:	00 
c0108054:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c010805b:	e8 93 8c ff ff       	call   c0100cf3 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108060:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108063:	8b 50 04             	mov    0x4(%eax),%edx
c0108066:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108069:	39 c2                	cmp    %eax,%edx
c010806b:	75 10                	jne    c010807d <check_vma_struct+0x385>
c010806d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108070:	8b 50 08             	mov    0x8(%eax),%edx
c0108073:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108076:	83 c0 02             	add    $0x2,%eax
c0108079:	39 c2                	cmp    %eax,%edx
c010807b:	74 24                	je     c01080a1 <check_vma_struct+0x3a9>
c010807d:	c7 44 24 0c 40 bb 10 	movl   $0xc010bb40,0xc(%esp)
c0108084:	c0 
c0108085:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c010808c:	c0 
c010808d:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0108094:	00 
c0108095:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c010809c:	e8 52 8c ff ff       	call   c0100cf3 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c01080a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01080a4:	8b 50 04             	mov    0x4(%eax),%edx
c01080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080aa:	39 c2                	cmp    %eax,%edx
c01080ac:	75 10                	jne    c01080be <check_vma_struct+0x3c6>
c01080ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01080b1:	8b 50 08             	mov    0x8(%eax),%edx
c01080b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080b7:	83 c0 02             	add    $0x2,%eax
c01080ba:	39 c2                	cmp    %eax,%edx
c01080bc:	74 24                	je     c01080e2 <check_vma_struct+0x3ea>
c01080be:	c7 44 24 0c 70 bb 10 	movl   $0xc010bb70,0xc(%esp)
c01080c5:	c0 
c01080c6:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c01080cd:	c0 
c01080ce:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01080d5:	00 
c01080d6:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c01080dd:	e8 11 8c ff ff       	call   c0100cf3 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01080e2:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c01080e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01080e9:	89 d0                	mov    %edx,%eax
c01080eb:	c1 e0 02             	shl    $0x2,%eax
c01080ee:	01 d0                	add    %edx,%eax
c01080f0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01080f3:	0f 8d 20 fe ff ff    	jge    c0107f19 <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01080f9:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108100:	eb 70                	jmp    c0108172 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0108102:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108105:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108109:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010810c:	89 04 24             	mov    %eax,(%esp)
c010810f:	e8 bd f8 ff ff       	call   c01079d1 <find_vma>
c0108114:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0108117:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010811b:	74 27                	je     c0108144 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c010811d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108120:	8b 50 08             	mov    0x8(%eax),%edx
c0108123:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108126:	8b 40 04             	mov    0x4(%eax),%eax
c0108129:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010812d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108131:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108134:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108138:	c7 04 24 a0 bb 10 c0 	movl   $0xc010bba0,(%esp)
c010813f:	e8 1b 82 ff ff       	call   c010035f <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108144:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108148:	74 24                	je     c010816e <check_vma_struct+0x476>
c010814a:	c7 44 24 0c c5 bb 10 	movl   $0xc010bbc5,0xc(%esp)
c0108151:	c0 
c0108152:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0108159:	c0 
c010815a:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0108161:	00 
c0108162:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0108169:	e8 85 8b ff ff       	call   c0100cf3 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c010816e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108172:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108176:	79 8a                	jns    c0108102 <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0108178:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010817b:	89 04 24             	mov    %eax,(%esp)
c010817e:	e8 d3 fa ff ff       	call   c0107c56 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108183:	c7 04 24 dc bb 10 c0 	movl   $0xc010bbdc,(%esp)
c010818a:	e8 d0 81 ff ff       	call   c010035f <cprintf>
}
c010818f:	c9                   	leave  
c0108190:	c3                   	ret    

c0108191 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108191:	55                   	push   %ebp
c0108192:	89 e5                	mov    %esp,%ebp
c0108194:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108197:	e8 b7 ce ff ff       	call   c0105053 <nr_free_pages>
c010819c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c010819f:	e8 7a f7 ff ff       	call   c010791e <mm_create>
c01081a4:	a3 cc a1 12 c0       	mov    %eax,0xc012a1cc
    assert(check_mm_struct != NULL);
c01081a9:	a1 cc a1 12 c0       	mov    0xc012a1cc,%eax
c01081ae:	85 c0                	test   %eax,%eax
c01081b0:	75 24                	jne    c01081d6 <check_pgfault+0x45>
c01081b2:	c7 44 24 0c fb bb 10 	movl   $0xc010bbfb,0xc(%esp)
c01081b9:	c0 
c01081ba:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c01081c1:	c0 
c01081c2:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c01081c9:	00 
c01081ca:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c01081d1:	e8 1d 8b ff ff       	call   c0100cf3 <__panic>

    struct mm_struct *mm = check_mm_struct;
c01081d6:	a1 cc a1 12 c0       	mov    0xc012a1cc,%eax
c01081db:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c01081de:	8b 15 00 4a 12 c0    	mov    0xc0124a00,%edx
c01081e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081e7:	89 50 0c             	mov    %edx,0xc(%eax)
c01081ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081ed:	8b 40 0c             	mov    0xc(%eax),%eax
c01081f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c01081f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081f6:	8b 00                	mov    (%eax),%eax
c01081f8:	85 c0                	test   %eax,%eax
c01081fa:	74 24                	je     c0108220 <check_pgfault+0x8f>
c01081fc:	c7 44 24 0c 13 bc 10 	movl   $0xc010bc13,0xc(%esp)
c0108203:	c0 
c0108204:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c010820b:	c0 
c010820c:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0108213:	00 
c0108214:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c010821b:	e8 d3 8a ff ff       	call   c0100cf3 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108220:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108227:	00 
c0108228:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c010822f:	00 
c0108230:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108237:	e8 5a f7 ff ff       	call   c0107996 <vma_create>
c010823c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c010823f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108243:	75 24                	jne    c0108269 <check_pgfault+0xd8>
c0108245:	c7 44 24 0c a4 ba 10 	movl   $0xc010baa4,0xc(%esp)
c010824c:	c0 
c010824d:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0108254:	c0 
c0108255:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c010825c:	00 
c010825d:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0108264:	e8 8a 8a ff ff       	call   c0100cf3 <__panic>

    insert_vma_struct(mm, vma);
c0108269:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010826c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108270:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108273:	89 04 24             	mov    %eax,(%esp)
c0108276:	e8 ab f8 ff ff       	call   c0107b26 <insert_vma_struct>

    uintptr_t addr = 0x100;
c010827b:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108282:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108285:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108289:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010828c:	89 04 24             	mov    %eax,(%esp)
c010828f:	e8 3d f7 ff ff       	call   c01079d1 <find_vma>
c0108294:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108297:	74 24                	je     c01082bd <check_pgfault+0x12c>
c0108299:	c7 44 24 0c 21 bc 10 	movl   $0xc010bc21,0xc(%esp)
c01082a0:	c0 
c01082a1:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c01082a8:	c0 
c01082a9:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c01082b0:	00 
c01082b1:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c01082b8:	e8 36 8a ff ff       	call   c0100cf3 <__panic>

    int i, sum = 0;
c01082bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01082c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01082cb:	eb 17                	jmp    c01082e4 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c01082cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01082d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01082d3:	01 d0                	add    %edx,%eax
c01082d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01082d8:	88 10                	mov    %dl,(%eax)
        sum += i;
c01082da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082dd:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c01082e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01082e4:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01082e8:	7e e3                	jle    c01082cd <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c01082ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01082f1:	eb 15                	jmp    c0108308 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c01082f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01082f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01082f9:	01 d0                	add    %edx,%eax
c01082fb:	0f b6 00             	movzbl (%eax),%eax
c01082fe:	0f be c0             	movsbl %al,%eax
c0108301:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108304:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108308:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010830c:	7e e5                	jle    c01082f3 <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c010830e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108312:	74 24                	je     c0108338 <check_pgfault+0x1a7>
c0108314:	c7 44 24 0c 3b bc 10 	movl   $0xc010bc3b,0xc(%esp)
c010831b:	c0 
c010831c:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c0108323:	c0 
c0108324:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c010832b:	00 
c010832c:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c0108333:	e8 bb 89 ff ff       	call   c0100cf3 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0108338:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010833b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010833e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108341:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108346:	89 44 24 04          	mov    %eax,0x4(%esp)
c010834a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010834d:	89 04 24             	mov    %eax,(%esp)
c0108350:	e8 37 d5 ff ff       	call   c010588c <page_remove>
    free_page(pde2page(pgdir[0]));
c0108355:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108358:	8b 00                	mov    (%eax),%eax
c010835a:	89 04 24             	mov    %eax,(%esp)
c010835d:	e8 a4 f5 ff ff       	call   c0107906 <pde2page>
c0108362:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108369:	00 
c010836a:	89 04 24             	mov    %eax,(%esp)
c010836d:	e8 af cc ff ff       	call   c0105021 <free_pages>
    pgdir[0] = 0;
c0108372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108375:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010837b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010837e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108385:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108388:	89 04 24             	mov    %eax,(%esp)
c010838b:	e8 c6 f8 ff ff       	call   c0107c56 <mm_destroy>
    check_mm_struct = NULL;
c0108390:	c7 05 cc a1 12 c0 00 	movl   $0x0,0xc012a1cc
c0108397:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c010839a:	e8 b4 cc ff ff       	call   c0105053 <nr_free_pages>
c010839f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01083a2:	74 24                	je     c01083c8 <check_pgfault+0x237>
c01083a4:	c7 44 24 0c 44 bc 10 	movl   $0xc010bc44,0xc(%esp)
c01083ab:	c0 
c01083ac:	c7 44 24 08 03 ba 10 	movl   $0xc010ba03,0x8(%esp)
c01083b3:	c0 
c01083b4:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c01083bb:	00 
c01083bc:	c7 04 24 18 ba 10 c0 	movl   $0xc010ba18,(%esp)
c01083c3:	e8 2b 89 ff ff       	call   c0100cf3 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c01083c8:	c7 04 24 6b bc 10 c0 	movl   $0xc010bc6b,(%esp)
c01083cf:	e8 8b 7f ff ff       	call   c010035f <cprintf>
}
c01083d4:	c9                   	leave  
c01083d5:	c3                   	ret    

c01083d6 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c01083d6:	55                   	push   %ebp
c01083d7:	89 e5                	mov    %esp,%ebp
c01083d9:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c01083dc:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01083e3:	8b 45 10             	mov    0x10(%ebp),%eax
c01083e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ed:	89 04 24             	mov    %eax,(%esp)
c01083f0:	e8 dc f5 ff ff       	call   c01079d1 <find_vma>
c01083f5:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01083f8:	a1 38 80 12 c0       	mov    0xc0128038,%eax
c01083fd:	83 c0 01             	add    $0x1,%eax
c0108400:	a3 38 80 12 c0       	mov    %eax,0xc0128038
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0108405:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108409:	74 0b                	je     c0108416 <do_pgfault+0x40>
c010840b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010840e:	8b 40 04             	mov    0x4(%eax),%eax
c0108411:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108414:	76 18                	jbe    c010842e <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0108416:	8b 45 10             	mov    0x10(%ebp),%eax
c0108419:	89 44 24 04          	mov    %eax,0x4(%esp)
c010841d:	c7 04 24 88 bc 10 c0 	movl   $0xc010bc88,(%esp)
c0108424:	e8 36 7f ff ff       	call   c010035f <cprintf>
        goto failed;
c0108429:	e9 bb 01 00 00       	jmp    c01085e9 <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c010842e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108431:	83 e0 03             	and    $0x3,%eax
c0108434:	85 c0                	test   %eax,%eax
c0108436:	74 36                	je     c010846e <do_pgfault+0x98>
c0108438:	83 f8 01             	cmp    $0x1,%eax
c010843b:	74 20                	je     c010845d <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c010843d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108440:	8b 40 0c             	mov    0xc(%eax),%eax
c0108443:	83 e0 02             	and    $0x2,%eax
c0108446:	85 c0                	test   %eax,%eax
c0108448:	75 11                	jne    c010845b <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010844a:	c7 04 24 b8 bc 10 c0 	movl   $0xc010bcb8,(%esp)
c0108451:	e8 09 7f ff ff       	call   c010035f <cprintf>
            goto failed;
c0108456:	e9 8e 01 00 00       	jmp    c01085e9 <do_pgfault+0x213>
        }
        break;
c010845b:	eb 2f                	jmp    c010848c <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c010845d:	c7 04 24 18 bd 10 c0 	movl   $0xc010bd18,(%esp)
c0108464:	e8 f6 7e ff ff       	call   c010035f <cprintf>
        goto failed;
c0108469:	e9 7b 01 00 00       	jmp    c01085e9 <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c010846e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108471:	8b 40 0c             	mov    0xc(%eax),%eax
c0108474:	83 e0 05             	and    $0x5,%eax
c0108477:	85 c0                	test   %eax,%eax
c0108479:	75 11                	jne    c010848c <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010847b:	c7 04 24 50 bd 10 c0 	movl   $0xc010bd50,(%esp)
c0108482:	e8 d8 7e ff ff       	call   c010035f <cprintf>
            goto failed;
c0108487:	e9 5d 01 00 00       	jmp    c01085e9 <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c010848c:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108493:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108496:	8b 40 0c             	mov    0xc(%eax),%eax
c0108499:	83 e0 02             	and    $0x2,%eax
c010849c:	85 c0                	test   %eax,%eax
c010849e:	74 04                	je     c01084a4 <do_pgfault+0xce>
        perm |= PTE_W;
c01084a0:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01084a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01084a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01084aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01084b2:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01084b5:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c01084bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c01084c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01084c6:	8b 40 0c             	mov    0xc(%eax),%eax
c01084c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01084d0:	00 
c01084d1:	8b 55 10             	mov    0x10(%ebp),%edx
c01084d4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084d8:	89 04 24             	mov    %eax,(%esp)
c01084db:	e8 ba d1 ff ff       	call   c010569a <get_pte>
c01084e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01084e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01084e7:	75 11                	jne    c01084fa <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c01084e9:	c7 04 24 b3 bd 10 c0 	movl   $0xc010bdb3,(%esp)
c01084f0:	e8 6a 7e ff ff       	call   c010035f <cprintf>
        goto failed;
c01084f5:	e9 ef 00 00 00       	jmp    c01085e9 <do_pgfault+0x213>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c01084fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01084fd:	8b 00                	mov    (%eax),%eax
c01084ff:	85 c0                	test   %eax,%eax
c0108501:	75 35                	jne    c0108538 <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0108503:	8b 45 08             	mov    0x8(%ebp),%eax
c0108506:	8b 40 0c             	mov    0xc(%eax),%eax
c0108509:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010850c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108510:	8b 55 10             	mov    0x10(%ebp),%edx
c0108513:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108517:	89 04 24             	mov    %eax,(%esp)
c010851a:	e8 c7 d4 ff ff       	call   c01059e6 <pgdir_alloc_page>
c010851f:	85 c0                	test   %eax,%eax
c0108521:	0f 85 bb 00 00 00    	jne    c01085e2 <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0108527:	c7 04 24 d4 bd 10 c0 	movl   $0xc010bdd4,(%esp)
c010852e:	e8 2c 7e ff ff       	call   c010035f <cprintf>
            goto failed;
c0108533:	e9 b1 00 00 00       	jmp    c01085e9 <do_pgfault+0x213>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c0108538:	a1 2c 80 12 c0       	mov    0xc012802c,%eax
c010853d:	85 c0                	test   %eax,%eax
c010853f:	0f 84 86 00 00 00    	je     c01085cb <do_pgfault+0x1f5>
            struct Page *page=NULL;
c0108545:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c010854c:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010854f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108553:	8b 45 10             	mov    0x10(%ebp),%eax
c0108556:	89 44 24 04          	mov    %eax,0x4(%esp)
c010855a:	8b 45 08             	mov    0x8(%ebp),%eax
c010855d:	89 04 24             	mov    %eax,(%esp)
c0108560:	e8 0c e5 ff ff       	call   c0106a71 <swap_in>
c0108565:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108568:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010856c:	74 0e                	je     c010857c <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c010856e:	c7 04 24 fb bd 10 c0 	movl   $0xc010bdfb,(%esp)
c0108575:	e8 e5 7d ff ff       	call   c010035f <cprintf>
c010857a:	eb 6d                	jmp    c01085e9 <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c010857c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010857f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108582:	8b 40 0c             	mov    0xc(%eax),%eax
c0108585:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108588:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010858c:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010858f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108593:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108597:	89 04 24             	mov    %eax,(%esp)
c010859a:	e8 31 d3 ff ff       	call   c01058d0 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c010859f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085a2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01085a9:	00 
c01085aa:	89 44 24 08          	mov    %eax,0x8(%esp)
c01085ae:	8b 45 10             	mov    0x10(%ebp),%eax
c01085b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01085b8:	89 04 24             	mov    %eax,(%esp)
c01085bb:	e8 e8 e2 ff ff       	call   c01068a8 <swap_map_swappable>
            page->pra_vaddr = addr;
c01085c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085c3:	8b 55 10             	mov    0x10(%ebp),%edx
c01085c6:	89 50 1c             	mov    %edx,0x1c(%eax)
c01085c9:	eb 17                	jmp    c01085e2 <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c01085cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085ce:	8b 00                	mov    (%eax),%eax
c01085d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085d4:	c7 04 24 1c be 10 c0 	movl   $0xc010be1c,(%esp)
c01085db:	e8 7f 7d ff ff       	call   c010035f <cprintf>
            goto failed;
c01085e0:	eb 07                	jmp    c01085e9 <do_pgfault+0x213>
        }
   }
   ret = 0;
c01085e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01085e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01085ec:	c9                   	leave  
c01085ed:	c3                   	ret    

c01085ee <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01085ee:	55                   	push   %ebp
c01085ef:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01085f1:	8b 55 08             	mov    0x8(%ebp),%edx
c01085f4:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c01085f9:	29 c2                	sub    %eax,%edx
c01085fb:	89 d0                	mov    %edx,%eax
c01085fd:	c1 f8 05             	sar    $0x5,%eax
}
c0108600:	5d                   	pop    %ebp
c0108601:	c3                   	ret    

c0108602 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0108602:	55                   	push   %ebp
c0108603:	89 e5                	mov    %esp,%ebp
c0108605:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0108608:	8b 45 08             	mov    0x8(%ebp),%eax
c010860b:	89 04 24             	mov    %eax,(%esp)
c010860e:	e8 db ff ff ff       	call   c01085ee <page2ppn>
c0108613:	c1 e0 0c             	shl    $0xc,%eax
}
c0108616:	c9                   	leave  
c0108617:	c3                   	ret    

c0108618 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0108618:	55                   	push   %ebp
c0108619:	89 e5                	mov    %esp,%ebp
c010861b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010861e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108621:	89 04 24             	mov    %eax,(%esp)
c0108624:	e8 d9 ff ff ff       	call   c0108602 <page2pa>
c0108629:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010862c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010862f:	c1 e8 0c             	shr    $0xc,%eax
c0108632:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108635:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c010863a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010863d:	72 23                	jb     c0108662 <page2kva+0x4a>
c010863f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108642:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108646:	c7 44 24 08 44 be 10 	movl   $0xc010be44,0x8(%esp)
c010864d:	c0 
c010864e:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0108655:	00 
c0108656:	c7 04 24 67 be 10 c0 	movl   $0xc010be67,(%esp)
c010865d:	e8 91 86 ff ff       	call   c0100cf3 <__panic>
c0108662:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108665:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010866a:	c9                   	leave  
c010866b:	c3                   	ret    

c010866c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010866c:	55                   	push   %ebp
c010866d:	89 e5                	mov    %esp,%ebp
c010866f:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0108672:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108679:	e8 d6 93 ff ff       	call   c0101a54 <ide_device_valid>
c010867e:	85 c0                	test   %eax,%eax
c0108680:	75 1c                	jne    c010869e <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0108682:	c7 44 24 08 75 be 10 	movl   $0xc010be75,0x8(%esp)
c0108689:	c0 
c010868a:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0108691:	00 
c0108692:	c7 04 24 8f be 10 c0 	movl   $0xc010be8f,(%esp)
c0108699:	e8 55 86 ff ff       	call   c0100cf3 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c010869e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01086a5:	e8 e9 93 ff ff       	call   c0101a93 <ide_device_size>
c01086aa:	c1 e8 03             	shr    $0x3,%eax
c01086ad:	a3 9c a1 12 c0       	mov    %eax,0xc012a19c
}
c01086b2:	c9                   	leave  
c01086b3:	c3                   	ret    

c01086b4 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01086b4:	55                   	push   %ebp
c01086b5:	89 e5                	mov    %esp,%ebp
c01086b7:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01086ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086bd:	89 04 24             	mov    %eax,(%esp)
c01086c0:	e8 53 ff ff ff       	call   c0108618 <page2kva>
c01086c5:	8b 55 08             	mov    0x8(%ebp),%edx
c01086c8:	c1 ea 08             	shr    $0x8,%edx
c01086cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01086ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01086d2:	74 0b                	je     c01086df <swapfs_read+0x2b>
c01086d4:	8b 15 9c a1 12 c0    	mov    0xc012a19c,%edx
c01086da:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01086dd:	72 23                	jb     c0108702 <swapfs_read+0x4e>
c01086df:	8b 45 08             	mov    0x8(%ebp),%eax
c01086e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01086e6:	c7 44 24 08 a0 be 10 	movl   $0xc010bea0,0x8(%esp)
c01086ed:	c0 
c01086ee:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01086f5:	00 
c01086f6:	c7 04 24 8f be 10 c0 	movl   $0xc010be8f,(%esp)
c01086fd:	e8 f1 85 ff ff       	call   c0100cf3 <__panic>
c0108702:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108705:	c1 e2 03             	shl    $0x3,%edx
c0108708:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010870f:	00 
c0108710:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108714:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108718:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010871f:	e8 ae 93 ff ff       	call   c0101ad2 <ide_read_secs>
}
c0108724:	c9                   	leave  
c0108725:	c3                   	ret    

c0108726 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0108726:	55                   	push   %ebp
c0108727:	89 e5                	mov    %esp,%ebp
c0108729:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010872c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010872f:	89 04 24             	mov    %eax,(%esp)
c0108732:	e8 e1 fe ff ff       	call   c0108618 <page2kva>
c0108737:	8b 55 08             	mov    0x8(%ebp),%edx
c010873a:	c1 ea 08             	shr    $0x8,%edx
c010873d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108740:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108744:	74 0b                	je     c0108751 <swapfs_write+0x2b>
c0108746:	8b 15 9c a1 12 c0    	mov    0xc012a19c,%edx
c010874c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010874f:	72 23                	jb     c0108774 <swapfs_write+0x4e>
c0108751:	8b 45 08             	mov    0x8(%ebp),%eax
c0108754:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108758:	c7 44 24 08 a0 be 10 	movl   $0xc010bea0,0x8(%esp)
c010875f:	c0 
c0108760:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0108767:	00 
c0108768:	c7 04 24 8f be 10 c0 	movl   $0xc010be8f,(%esp)
c010876f:	e8 7f 85 ff ff       	call   c0100cf3 <__panic>
c0108774:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108777:	c1 e2 03             	shl    $0x3,%edx
c010877a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108781:	00 
c0108782:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108786:	89 54 24 04          	mov    %edx,0x4(%esp)
c010878a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108791:	e8 7e 95 ff ff       	call   c0101d14 <ide_write_secs>
}
c0108796:	c9                   	leave  
c0108797:	c3                   	ret    

c0108798 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0108798:	52                   	push   %edx
    call *%ebx              # call fn
c0108799:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c010879b:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c010879c:	e8 3b 08 00 00       	call   c0108fdc <do_exit>

c01087a1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01087a1:	55                   	push   %ebp
c01087a2:	89 e5                	mov    %esp,%ebp
c01087a4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01087a7:	9c                   	pushf  
c01087a8:	58                   	pop    %eax
c01087a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01087ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01087af:	25 00 02 00 00       	and    $0x200,%eax
c01087b4:	85 c0                	test   %eax,%eax
c01087b6:	74 0c                	je     c01087c4 <__intr_save+0x23>
        intr_disable();
c01087b8:	e8 9f 97 ff ff       	call   c0101f5c <intr_disable>
        return 1;
c01087bd:	b8 01 00 00 00       	mov    $0x1,%eax
c01087c2:	eb 05                	jmp    c01087c9 <__intr_save+0x28>
    }
    return 0;
c01087c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01087c9:	c9                   	leave  
c01087ca:	c3                   	ret    

c01087cb <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01087cb:	55                   	push   %ebp
c01087cc:	89 e5                	mov    %esp,%ebp
c01087ce:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01087d1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01087d5:	74 05                	je     c01087dc <__intr_restore+0x11>
        intr_enable();
c01087d7:	e8 7a 97 ff ff       	call   c0101f56 <intr_enable>
    }
}
c01087dc:	c9                   	leave  
c01087dd:	c3                   	ret    

c01087de <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01087de:	55                   	push   %ebp
c01087df:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01087e1:	8b 55 08             	mov    0x8(%ebp),%edx
c01087e4:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c01087e9:	29 c2                	sub    %eax,%edx
c01087eb:	89 d0                	mov    %edx,%eax
c01087ed:	c1 f8 05             	sar    $0x5,%eax
}
c01087f0:	5d                   	pop    %ebp
c01087f1:	c3                   	ret    

c01087f2 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01087f2:	55                   	push   %ebp
c01087f3:	89 e5                	mov    %esp,%ebp
c01087f5:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01087f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01087fb:	89 04 24             	mov    %eax,(%esp)
c01087fe:	e8 db ff ff ff       	call   c01087de <page2ppn>
c0108803:	c1 e0 0c             	shl    $0xc,%eax
}
c0108806:	c9                   	leave  
c0108807:	c3                   	ret    

c0108808 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0108808:	55                   	push   %ebp
c0108809:	89 e5                	mov    %esp,%ebp
c010880b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010880e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108811:	c1 e8 0c             	shr    $0xc,%eax
c0108814:	89 c2                	mov    %eax,%edx
c0108816:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c010881b:	39 c2                	cmp    %eax,%edx
c010881d:	72 1c                	jb     c010883b <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010881f:	c7 44 24 08 c0 be 10 	movl   $0xc010bec0,0x8(%esp)
c0108826:	c0 
c0108827:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010882e:	00 
c010882f:	c7 04 24 df be 10 c0 	movl   $0xc010bedf,(%esp)
c0108836:	e8 b8 84 ff ff       	call   c0100cf3 <__panic>
    }
    return &pages[PPN(pa)];
c010883b:	a1 e4 a0 12 c0       	mov    0xc012a0e4,%eax
c0108840:	8b 55 08             	mov    0x8(%ebp),%edx
c0108843:	c1 ea 0c             	shr    $0xc,%edx
c0108846:	c1 e2 05             	shl    $0x5,%edx
c0108849:	01 d0                	add    %edx,%eax
}
c010884b:	c9                   	leave  
c010884c:	c3                   	ret    

c010884d <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010884d:	55                   	push   %ebp
c010884e:	89 e5                	mov    %esp,%ebp
c0108850:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0108853:	8b 45 08             	mov    0x8(%ebp),%eax
c0108856:	89 04 24             	mov    %eax,(%esp)
c0108859:	e8 94 ff ff ff       	call   c01087f2 <page2pa>
c010885e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108861:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108864:	c1 e8 0c             	shr    $0xc,%eax
c0108867:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010886a:	a1 a0 7f 12 c0       	mov    0xc0127fa0,%eax
c010886f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108872:	72 23                	jb     c0108897 <page2kva+0x4a>
c0108874:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108877:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010887b:	c7 44 24 08 f0 be 10 	movl   $0xc010bef0,0x8(%esp)
c0108882:	c0 
c0108883:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010888a:	00 
c010888b:	c7 04 24 df be 10 c0 	movl   $0xc010bedf,(%esp)
c0108892:	e8 5c 84 ff ff       	call   c0100cf3 <__panic>
c0108897:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010889a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010889f:	c9                   	leave  
c01088a0:	c3                   	ret    

c01088a1 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01088a1:	55                   	push   %ebp
c01088a2:	89 e5                	mov    %esp,%ebp
c01088a4:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01088a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01088aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088ad:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01088b4:	77 23                	ja     c01088d9 <kva2page+0x38>
c01088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01088bd:	c7 44 24 08 14 bf 10 	movl   $0xc010bf14,0x8(%esp)
c01088c4:	c0 
c01088c5:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01088cc:	00 
c01088cd:	c7 04 24 df be 10 c0 	movl   $0xc010bedf,(%esp)
c01088d4:	e8 1a 84 ff ff       	call   c0100cf3 <__panic>
c01088d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088dc:	05 00 00 00 40       	add    $0x40000000,%eax
c01088e1:	89 04 24             	mov    %eax,(%esp)
c01088e4:	e8 1f ff ff ff       	call   c0108808 <pa2page>
}
c01088e9:	c9                   	leave  
c01088ea:	c3                   	ret    

c01088eb <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c01088eb:	55                   	push   %ebp
c01088ec:	89 e5                	mov    %esp,%ebp
c01088ee:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c01088f1:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c01088f8:	e8 44 c2 ff ff       	call   c0104b41 <kmalloc>
c01088fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0108900:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108904:	0f 84 a1 00 00 00    	je     c01089ab <alloc_proc+0xc0>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c010890a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010890d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0108913:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108916:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c010891d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108920:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0108927:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010892a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c0108931:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108934:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c010893b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010893e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c0108945:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108948:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c010894f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108952:	83 c0 1c             	add    $0x1c,%eax
c0108955:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c010895c:	00 
c010895d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108964:	00 
c0108965:	89 04 24             	mov    %eax,(%esp)
c0108968:	e8 f1 14 00 00       	call   c0109e5e <memset>
        proc->tf = NULL;
c010896d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108970:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c0108977:	8b 15 e0 a0 12 c0    	mov    0xc012a0e0,%edx
c010897d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108980:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c0108983:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108986:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c010898d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108990:	83 c0 48             	add    $0x48,%eax
c0108993:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010899a:	00 
c010899b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01089a2:	00 
c01089a3:	89 04 24             	mov    %eax,(%esp)
c01089a6:	e8 b3 14 00 00       	call   c0109e5e <memset>
    }
    return proc;
c01089ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01089ae:	c9                   	leave  
c01089af:	c3                   	ret    

c01089b0 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01089b0:	55                   	push   %ebp
c01089b1:	89 e5                	mov    %esp,%ebp
c01089b3:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01089b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01089b9:	83 c0 48             	add    $0x48,%eax
c01089bc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01089c3:	00 
c01089c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01089cb:	00 
c01089cc:	89 04 24             	mov    %eax,(%esp)
c01089cf:	e8 8a 14 00 00       	call   c0109e5e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01089d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01089d7:	8d 50 48             	lea    0x48(%eax),%edx
c01089da:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01089e1:	00 
c01089e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089e9:	89 14 24             	mov    %edx,(%esp)
c01089ec:	e8 4f 15 00 00       	call   c0109f40 <memcpy>
}
c01089f1:	c9                   	leave  
c01089f2:	c3                   	ret    

c01089f3 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01089f3:	55                   	push   %ebp
c01089f4:	89 e5                	mov    %esp,%ebp
c01089f6:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c01089f9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108a00:	00 
c0108a01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108a08:	00 
c0108a09:	c7 04 24 64 a0 12 c0 	movl   $0xc012a064,(%esp)
c0108a10:	e8 49 14 00 00       	call   c0109e5e <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0108a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a18:	83 c0 48             	add    $0x48,%eax
c0108a1b:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108a22:	00 
c0108a23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a27:	c7 04 24 64 a0 12 c0 	movl   $0xc012a064,(%esp)
c0108a2e:	e8 0d 15 00 00       	call   c0109f40 <memcpy>
}
c0108a33:	c9                   	leave  
c0108a34:	c3                   	ret    

c0108a35 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0108a35:	55                   	push   %ebp
c0108a36:	89 e5                	mov    %esp,%ebp
c0108a38:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0108a3b:	c7 45 f8 d0 a1 12 c0 	movl   $0xc012a1d0,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0108a42:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0108a47:	83 c0 01             	add    $0x1,%eax
c0108a4a:	a3 80 4a 12 c0       	mov    %eax,0xc0124a80
c0108a4f:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0108a54:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108a59:	7e 0c                	jle    c0108a67 <get_pid+0x32>
        last_pid = 1;
c0108a5b:	c7 05 80 4a 12 c0 01 	movl   $0x1,0xc0124a80
c0108a62:	00 00 00 
        goto inside;
c0108a65:	eb 13                	jmp    c0108a7a <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0108a67:	8b 15 80 4a 12 c0    	mov    0xc0124a80,%edx
c0108a6d:	a1 84 4a 12 c0       	mov    0xc0124a84,%eax
c0108a72:	39 c2                	cmp    %eax,%edx
c0108a74:	0f 8c ac 00 00 00    	jl     c0108b26 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0108a7a:	c7 05 84 4a 12 c0 00 	movl   $0x2000,0xc0124a84
c0108a81:	20 00 00 
    repeat:
        le = list;
c0108a84:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108a87:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0108a8a:	eb 7f                	jmp    c0108b0b <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0108a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108a8f:	83 e8 58             	sub    $0x58,%eax
c0108a92:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0108a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a98:	8b 50 04             	mov    0x4(%eax),%edx
c0108a9b:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0108aa0:	39 c2                	cmp    %eax,%edx
c0108aa2:	75 3e                	jne    c0108ae2 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0108aa4:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0108aa9:	83 c0 01             	add    $0x1,%eax
c0108aac:	a3 80 4a 12 c0       	mov    %eax,0xc0124a80
c0108ab1:	8b 15 80 4a 12 c0    	mov    0xc0124a80,%edx
c0108ab7:	a1 84 4a 12 c0       	mov    0xc0124a84,%eax
c0108abc:	39 c2                	cmp    %eax,%edx
c0108abe:	7c 4b                	jl     c0108b0b <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c0108ac0:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0108ac5:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108aca:	7e 0a                	jle    c0108ad6 <get_pid+0xa1>
                        last_pid = 1;
c0108acc:	c7 05 80 4a 12 c0 01 	movl   $0x1,0xc0124a80
c0108ad3:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108ad6:	c7 05 84 4a 12 c0 00 	movl   $0x2000,0xc0124a84
c0108add:	20 00 00 
                    goto repeat;
c0108ae0:	eb a2                	jmp    c0108a84 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0108ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ae5:	8b 50 04             	mov    0x4(%eax),%edx
c0108ae8:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
c0108aed:	39 c2                	cmp    %eax,%edx
c0108aef:	7e 1a                	jle    c0108b0b <get_pid+0xd6>
c0108af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108af4:	8b 50 04             	mov    0x4(%eax),%edx
c0108af7:	a1 84 4a 12 c0       	mov    0xc0124a84,%eax
c0108afc:	39 c2                	cmp    %eax,%edx
c0108afe:	7d 0b                	jge    c0108b0b <get_pid+0xd6>
                next_safe = proc->pid;
c0108b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b03:	8b 40 04             	mov    0x4(%eax),%eax
c0108b06:	a3 84 4a 12 c0       	mov    %eax,0xc0124a84
c0108b0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b14:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0108b17:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0108b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108b1d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0108b20:	0f 85 66 ff ff ff    	jne    c0108a8c <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0108b26:	a1 80 4a 12 c0       	mov    0xc0124a80,%eax
}
c0108b2b:	c9                   	leave  
c0108b2c:	c3                   	ret    

c0108b2d <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0108b2d:	55                   	push   %ebp
c0108b2e:	89 e5                	mov    %esp,%ebp
c0108b30:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0108b33:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0108b38:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108b3b:	74 63                	je     c0108ba0 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0108b3d:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0108b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b45:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b48:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0108b4b:	e8 51 fc ff ff       	call   c01087a1 <__intr_save>
c0108b50:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0108b53:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b56:	a3 48 80 12 c0       	mov    %eax,0xc0128048
            load_esp0(next->kstack + KSTACKSIZE);
c0108b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b5e:	8b 40 0c             	mov    0xc(%eax),%eax
c0108b61:	05 00 20 00 00       	add    $0x2000,%eax
c0108b66:	89 04 24             	mov    %eax,(%esp)
c0108b69:	e8 fa c2 ff ff       	call   c0104e68 <load_esp0>
            lcr3(next->cr3);
c0108b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b71:	8b 40 40             	mov    0x40(%eax),%eax
c0108b74:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108b77:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b7a:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0108b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b80:	8d 50 1c             	lea    0x1c(%eax),%edx
c0108b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b86:	83 c0 1c             	add    $0x1c,%eax
c0108b89:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108b8d:	89 04 24             	mov    %eax,(%esp)
c0108b90:	e8 99 06 00 00       	call   c010922e <switch_to>
        }
        local_intr_restore(intr_flag);
c0108b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b98:	89 04 24             	mov    %eax,(%esp)
c0108b9b:	e8 2b fc ff ff       	call   c01087cb <__intr_restore>
    }
}
c0108ba0:	c9                   	leave  
c0108ba1:	c3                   	ret    

c0108ba2 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0108ba2:	55                   	push   %ebp
c0108ba3:	89 e5                	mov    %esp,%ebp
c0108ba5:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0108ba8:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0108bad:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108bb0:	89 04 24             	mov    %eax,(%esp)
c0108bb3:	e8 3c 9d ff ff       	call   c01028f4 <forkrets>
}
c0108bb8:	c9                   	leave  
c0108bb9:	c3                   	ret    

c0108bba <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0108bba:	55                   	push   %ebp
c0108bbb:	89 e5                	mov    %esp,%ebp
c0108bbd:	53                   	push   %ebx
c0108bbe:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0108bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bc4:	8d 58 60             	lea    0x60(%eax),%ebx
c0108bc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bca:	8b 40 04             	mov    0x4(%eax),%eax
c0108bcd:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108bd4:	00 
c0108bd5:	89 04 24             	mov    %eax,(%esp)
c0108bd8:	e8 d4 07 00 00       	call   c01093b1 <hash32>
c0108bdd:	c1 e0 03             	shl    $0x3,%eax
c0108be0:	05 60 80 12 c0       	add    $0xc0128060,%eax
c0108be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108be8:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0108beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bee:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108bf4:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bfa:	8b 40 04             	mov    0x4(%eax),%eax
c0108bfd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108c00:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108c03:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108c06:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0108c09:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0108c0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108c0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108c12:	89 10                	mov    %edx,(%eax)
c0108c14:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108c17:	8b 10                	mov    (%eax),%edx
c0108c19:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c1c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108c1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c22:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108c25:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108c28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c2b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108c2e:	89 10                	mov    %edx,(%eax)
}
c0108c30:	83 c4 34             	add    $0x34,%esp
c0108c33:	5b                   	pop    %ebx
c0108c34:	5d                   	pop    %ebp
c0108c35:	c3                   	ret    

c0108c36 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0108c36:	55                   	push   %ebp
c0108c37:	89 e5                	mov    %esp,%ebp
c0108c39:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0108c3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108c40:	7e 5f                	jle    c0108ca1 <find_proc+0x6b>
c0108c42:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0108c49:	7f 56                	jg     c0108ca1 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0108c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c4e:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108c55:	00 
c0108c56:	89 04 24             	mov    %eax,(%esp)
c0108c59:	e8 53 07 00 00       	call   c01093b1 <hash32>
c0108c5e:	c1 e0 03             	shl    $0x3,%eax
c0108c61:	05 60 80 12 c0       	add    $0xc0128060,%eax
c0108c66:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0108c6f:	eb 19                	jmp    c0108c8a <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0108c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c74:	83 e8 60             	sub    $0x60,%eax
c0108c77:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0108c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c7d:	8b 40 04             	mov    0x4(%eax),%eax
c0108c80:	3b 45 08             	cmp    0x8(%ebp),%eax
c0108c83:	75 05                	jne    c0108c8a <find_proc+0x54>
                return proc;
c0108c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c88:	eb 1c                	jmp    c0108ca6 <find_proc+0x70>
c0108c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c8d:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108c90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c93:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0108c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c9c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108c9f:	75 d0                	jne    c0108c71 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0108ca1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108ca6:	c9                   	leave  
c0108ca7:	c3                   	ret    

c0108ca8 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0108ca8:	55                   	push   %ebp
c0108ca9:	89 e5                	mov    %esp,%ebp
c0108cab:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0108cae:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0108cb5:	00 
c0108cb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108cbd:	00 
c0108cbe:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108cc1:	89 04 24             	mov    %eax,(%esp)
c0108cc4:	e8 95 11 00 00       	call   c0109e5e <memset>
    tf.tf_cs = KERNEL_CS;
c0108cc9:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0108ccf:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108cd5:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0108cd9:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108cdd:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0108ce1:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0108ce5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0108ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108cee:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0108cf1:	b8 98 87 10 c0       	mov    $0xc0108798,%eax
c0108cf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0108cf9:	8b 45 10             	mov    0x10(%ebp),%eax
c0108cfc:	80 cc 01             	or     $0x1,%ah
c0108cff:	89 c2                	mov    %eax,%edx
c0108d01:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108d04:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108d08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108d0f:	00 
c0108d10:	89 14 24             	mov    %edx,(%esp)
c0108d13:	e8 79 01 00 00       	call   c0108e91 <do_fork>
}
c0108d18:	c9                   	leave  
c0108d19:	c3                   	ret    

c0108d1a <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0108d1a:	55                   	push   %ebp
c0108d1b:	89 e5                	mov    %esp,%ebp
c0108d1d:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0108d20:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0108d27:	e8 8a c2 ff ff       	call   c0104fb6 <alloc_pages>
c0108d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0108d2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108d33:	74 1a                	je     c0108d4f <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0108d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d38:	89 04 24             	mov    %eax,(%esp)
c0108d3b:	e8 0d fb ff ff       	call   c010884d <page2kva>
c0108d40:	89 c2                	mov    %eax,%edx
c0108d42:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d45:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0108d48:	b8 00 00 00 00       	mov    $0x0,%eax
c0108d4d:	eb 05                	jmp    c0108d54 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0108d4f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0108d54:	c9                   	leave  
c0108d55:	c3                   	ret    

c0108d56 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0108d56:	55                   	push   %ebp
c0108d57:	89 e5                	mov    %esp,%ebp
c0108d59:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0108d5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d5f:	8b 40 0c             	mov    0xc(%eax),%eax
c0108d62:	89 04 24             	mov    %eax,(%esp)
c0108d65:	e8 37 fb ff ff       	call   c01088a1 <kva2page>
c0108d6a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0108d71:	00 
c0108d72:	89 04 24             	mov    %eax,(%esp)
c0108d75:	e8 a7 c2 ff ff       	call   c0105021 <free_pages>
}
c0108d7a:	c9                   	leave  
c0108d7b:	c3                   	ret    

c0108d7c <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0108d7c:	55                   	push   %ebp
c0108d7d:	89 e5                	mov    %esp,%ebp
c0108d7f:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c0108d82:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0108d87:	8b 40 18             	mov    0x18(%eax),%eax
c0108d8a:	85 c0                	test   %eax,%eax
c0108d8c:	74 24                	je     c0108db2 <copy_mm+0x36>
c0108d8e:	c7 44 24 0c 38 bf 10 	movl   $0xc010bf38,0xc(%esp)
c0108d95:	c0 
c0108d96:	c7 44 24 08 4c bf 10 	movl   $0xc010bf4c,0x8(%esp)
c0108d9d:	c0 
c0108d9e:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0108da5:	00 
c0108da6:	c7 04 24 61 bf 10 c0 	movl   $0xc010bf61,(%esp)
c0108dad:	e8 41 7f ff ff       	call   c0100cf3 <__panic>
    /* do nothing in this project */
    return 0;
c0108db2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108db7:	c9                   	leave  
c0108db8:	c3                   	ret    

c0108db9 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0108db9:	55                   	push   %ebp
c0108dba:	89 e5                	mov    %esp,%ebp
c0108dbc:	57                   	push   %edi
c0108dbd:	56                   	push   %esi
c0108dbe:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108dbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dc2:	8b 40 0c             	mov    0xc(%eax),%eax
c0108dc5:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0108dca:	89 c2                	mov    %eax,%edx
c0108dcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dcf:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dd5:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108dd8:	8b 55 10             	mov    0x10(%ebp),%edx
c0108ddb:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0108de0:	89 c1                	mov    %eax,%ecx
c0108de2:	83 e1 01             	and    $0x1,%ecx
c0108de5:	85 c9                	test   %ecx,%ecx
c0108de7:	74 0e                	je     c0108df7 <copy_thread+0x3e>
c0108de9:	0f b6 0a             	movzbl (%edx),%ecx
c0108dec:	88 08                	mov    %cl,(%eax)
c0108dee:	83 c0 01             	add    $0x1,%eax
c0108df1:	83 c2 01             	add    $0x1,%edx
c0108df4:	83 eb 01             	sub    $0x1,%ebx
c0108df7:	89 c1                	mov    %eax,%ecx
c0108df9:	83 e1 02             	and    $0x2,%ecx
c0108dfc:	85 c9                	test   %ecx,%ecx
c0108dfe:	74 0f                	je     c0108e0f <copy_thread+0x56>
c0108e00:	0f b7 0a             	movzwl (%edx),%ecx
c0108e03:	66 89 08             	mov    %cx,(%eax)
c0108e06:	83 c0 02             	add    $0x2,%eax
c0108e09:	83 c2 02             	add    $0x2,%edx
c0108e0c:	83 eb 02             	sub    $0x2,%ebx
c0108e0f:	89 d9                	mov    %ebx,%ecx
c0108e11:	c1 e9 02             	shr    $0x2,%ecx
c0108e14:	89 c7                	mov    %eax,%edi
c0108e16:	89 d6                	mov    %edx,%esi
c0108e18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108e1a:	89 f2                	mov    %esi,%edx
c0108e1c:	89 f8                	mov    %edi,%eax
c0108e1e:	b9 00 00 00 00       	mov    $0x0,%ecx
c0108e23:	89 de                	mov    %ebx,%esi
c0108e25:	83 e6 02             	and    $0x2,%esi
c0108e28:	85 f6                	test   %esi,%esi
c0108e2a:	74 0b                	je     c0108e37 <copy_thread+0x7e>
c0108e2c:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0108e30:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0108e34:	83 c1 02             	add    $0x2,%ecx
c0108e37:	83 e3 01             	and    $0x1,%ebx
c0108e3a:	85 db                	test   %ebx,%ebx
c0108e3c:	74 07                	je     c0108e45 <copy_thread+0x8c>
c0108e3e:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0108e42:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0108e45:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e48:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e4b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0108e52:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e55:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e58:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108e5b:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0108e5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e61:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e64:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e67:	8b 52 3c             	mov    0x3c(%edx),%edx
c0108e6a:	8b 52 40             	mov    0x40(%edx),%edx
c0108e6d:	80 ce 02             	or     $0x2,%dh
c0108e70:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0108e73:	ba a2 8b 10 c0       	mov    $0xc0108ba2,%edx
c0108e78:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e7b:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0108e7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e81:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e84:	89 c2                	mov    %eax,%edx
c0108e86:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e89:	89 50 20             	mov    %edx,0x20(%eax)
}
c0108e8c:	5b                   	pop    %ebx
c0108e8d:	5e                   	pop    %esi
c0108e8e:	5f                   	pop    %edi
c0108e8f:	5d                   	pop    %ebp
c0108e90:	c3                   	ret    

c0108e91 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0108e91:	55                   	push   %ebp
c0108e92:	89 e5                	mov    %esp,%ebp
c0108e94:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c0108e97:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0108e9e:	a1 60 a0 12 c0       	mov    0xc012a060,%eax
c0108ea3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0108ea8:	7e 05                	jle    c0108eaf <do_fork+0x1e>
        goto fork_out;
c0108eaa:	e9 19 01 00 00       	jmp    c0108fc8 <do_fork+0x137>
    }
    ret = -E_NO_MEM;
c0108eaf:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
	if((proc=alloc_proc())==NULL){
c0108eb6:	e8 30 fa ff ff       	call   c01088eb <alloc_proc>
c0108ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ebe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108ec2:	75 05                	jne    c0108ec9 <do_fork+0x38>
		goto fork_out;
c0108ec4:	e9 ff 00 00 00       	jmp    c0108fc8 <do_fork+0x137>
	}
	proc->parent = current;
c0108ec9:	8b 15 48 80 12 c0    	mov    0xc0128048,%edx
c0108ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ed2:	89 50 14             	mov    %edx,0x14(%eax)

    if (setup_kstack(proc) != 0) {
c0108ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ed8:	89 04 24             	mov    %eax,(%esp)
c0108edb:	e8 3a fe ff ff       	call   c0108d1a <setup_kstack>
c0108ee0:	85 c0                	test   %eax,%eax
c0108ee2:	74 05                	je     c0108ee9 <do_fork+0x58>
        goto bad_fork_cleanup_proc;
c0108ee4:	e9 e4 00 00 00       	jmp    c0108fcd <do_fork+0x13c>
    }
    if (copy_mm(clone_flags, proc) != 0) {
c0108ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108eec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ef0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ef3:	89 04 24             	mov    %eax,(%esp)
c0108ef6:	e8 81 fe ff ff       	call   c0108d7c <copy_mm>
c0108efb:	85 c0                	test   %eax,%eax
c0108efd:	74 11                	je     c0108f10 <do_fork+0x7f>
        goto bad_fork_cleanup_kstack;
c0108eff:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0108f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f03:	89 04 24             	mov    %eax,(%esp)
c0108f06:	e8 4b fe ff ff       	call   c0108d56 <put_kstack>
c0108f0b:	e9 bd 00 00 00       	jmp    c0108fcd <do_fork+0x13c>
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c0108f10:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f13:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108f17:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f21:	89 04 24             	mov    %eax,(%esp)
c0108f24:	e8 90 fe ff ff       	call   c0108db9 <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c0108f29:	e8 73 f8 ff ff       	call   c01087a1 <__intr_save>
c0108f2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c0108f31:	e8 ff fa ff ff       	call   c0108a35 <get_pid>
c0108f36:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108f39:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c0108f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f3f:	89 04 24             	mov    %eax,(%esp)
c0108f42:	e8 73 fc ff ff       	call   c0108bba <hash_proc>
        list_add(&proc_list, &(proc->list_link));
c0108f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f4a:	83 c0 58             	add    $0x58,%eax
c0108f4d:	c7 45 e8 d0 a1 12 c0 	movl   $0xc012a1d0,-0x18(%ebp)
c0108f54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108f57:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f60:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108f63:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f66:	8b 40 04             	mov    0x4(%eax),%eax
c0108f69:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108f6c:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0108f6f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f72:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108f75:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0108f78:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108f7b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108f7e:	89 10                	mov    %edx,(%eax)
c0108f80:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108f83:	8b 10                	mov    (%eax),%edx
c0108f85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108f88:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108f8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108f8e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108f91:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108f94:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108f97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108f9a:	89 10                	mov    %edx,(%eax)
        nr_process ++;
c0108f9c:	a1 60 a0 12 c0       	mov    0xc012a060,%eax
c0108fa1:	83 c0 01             	add    $0x1,%eax
c0108fa4:	a3 60 a0 12 c0       	mov    %eax,0xc012a060
    }
    local_intr_restore(intr_flag);
c0108fa9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108fac:	89 04 24             	mov    %eax,(%esp)
c0108faf:	e8 17 f8 ff ff       	call   c01087cb <__intr_restore>

    wakeup_proc(proc);
c0108fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fb7:	89 04 24             	mov    %eax,(%esp)
c0108fba:	e8 e3 02 00 00       	call   c01092a2 <wakeup_proc>

    ret = proc->pid;
c0108fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fc2:	8b 40 04             	mov    0x4(%eax),%eax
c0108fc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
fork_out:
    return ret;
c0108fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fcb:	eb 0d                	jmp    c0108fda <do_fork+0x149>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c0108fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fd0:	89 04 24             	mov    %eax,(%esp)
c0108fd3:	e8 84 bb ff ff       	call   c0104b5c <kfree>
    goto fork_out;
c0108fd8:	eb ee                	jmp    c0108fc8 <do_fork+0x137>
}
c0108fda:	c9                   	leave  
c0108fdb:	c3                   	ret    

c0108fdc <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0108fdc:	55                   	push   %ebp
c0108fdd:	89 e5                	mov    %esp,%ebp
c0108fdf:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c0108fe2:	c7 44 24 08 75 bf 10 	movl   $0xc010bf75,0x8(%esp)
c0108fe9:	c0 
c0108fea:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0108ff1:	00 
c0108ff2:	c7 04 24 61 bf 10 c0 	movl   $0xc010bf61,(%esp)
c0108ff9:	e8 f5 7c ff ff       	call   c0100cf3 <__panic>

c0108ffe <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0108ffe:	55                   	push   %ebp
c0108fff:	89 e5                	mov    %esp,%ebp
c0109001:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c0109004:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0109009:	89 04 24             	mov    %eax,(%esp)
c010900c:	e8 e2 f9 ff ff       	call   c01089f3 <get_proc_name>
c0109011:	8b 15 48 80 12 c0    	mov    0xc0128048,%edx
c0109017:	8b 52 04             	mov    0x4(%edx),%edx
c010901a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010901e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109022:	c7 04 24 88 bf 10 c0 	movl   $0xc010bf88,(%esp)
c0109029:	e8 31 73 ff ff       	call   c010035f <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c010902e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109031:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109035:	c7 04 24 ae bf 10 c0 	movl   $0xc010bfae,(%esp)
c010903c:	e8 1e 73 ff ff       	call   c010035f <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0109041:	c7 04 24 bb bf 10 c0 	movl   $0xc010bfbb,(%esp)
c0109048:	e8 12 73 ff ff       	call   c010035f <cprintf>
    return 0;
c010904d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109052:	c9                   	leave  
c0109053:	c3                   	ret    

c0109054 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0109054:	55                   	push   %ebp
c0109055:	89 e5                	mov    %esp,%ebp
c0109057:	83 ec 28             	sub    $0x28,%esp
c010905a:	c7 45 ec d0 a1 12 c0 	movl   $0xc012a1d0,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0109061:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109064:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109067:	89 50 04             	mov    %edx,0x4(%eax)
c010906a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010906d:	8b 50 04             	mov    0x4(%eax),%edx
c0109070:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109073:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109075:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010907c:	eb 26                	jmp    c01090a4 <proc_init+0x50>
        list_init(hash_list + i);
c010907e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109081:	c1 e0 03             	shl    $0x3,%eax
c0109084:	05 60 80 12 c0       	add    $0xc0128060,%eax
c0109089:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010908c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010908f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109092:	89 50 04             	mov    %edx,0x4(%eax)
c0109095:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109098:	8b 50 04             	mov    0x4(%eax),%edx
c010909b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010909e:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c01090a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01090a4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c01090ab:	7e d1                	jle    c010907e <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c01090ad:	e8 39 f8 ff ff       	call   c01088eb <alloc_proc>
c01090b2:	a3 40 80 12 c0       	mov    %eax,0xc0128040
c01090b7:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c01090bc:	85 c0                	test   %eax,%eax
c01090be:	75 1c                	jne    c01090dc <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c01090c0:	c7 44 24 08 d7 bf 10 	movl   $0xc010bfd7,0x8(%esp)
c01090c7:	c0 
c01090c8:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
c01090cf:	00 
c01090d0:	c7 04 24 61 bf 10 c0 	movl   $0xc010bf61,(%esp)
c01090d7:	e8 17 7c ff ff       	call   c0100cf3 <__panic>
    }

    idleproc->pid = 0;
c01090dc:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c01090e1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c01090e8:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c01090ed:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c01090f3:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c01090f8:	ba 00 20 12 c0       	mov    $0xc0122000,%edx
c01090fd:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c0109100:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c0109105:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010910c:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c0109111:	c7 44 24 04 ef bf 10 	movl   $0xc010bfef,0x4(%esp)
c0109118:	c0 
c0109119:	89 04 24             	mov    %eax,(%esp)
c010911c:	e8 8f f8 ff ff       	call   c01089b0 <set_proc_name>
    nr_process ++;
c0109121:	a1 60 a0 12 c0       	mov    0xc012a060,%eax
c0109126:	83 c0 01             	add    $0x1,%eax
c0109129:	a3 60 a0 12 c0       	mov    %eax,0xc012a060

    current = idleproc;
c010912e:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c0109133:	a3 48 80 12 c0       	mov    %eax,0xc0128048

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0109138:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010913f:	00 
c0109140:	c7 44 24 04 f4 bf 10 	movl   $0xc010bff4,0x4(%esp)
c0109147:	c0 
c0109148:	c7 04 24 fe 8f 10 c0 	movl   $0xc0108ffe,(%esp)
c010914f:	e8 54 fb ff ff       	call   c0108ca8 <kernel_thread>
c0109154:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c0109157:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010915b:	7f 1c                	jg     c0109179 <proc_init+0x125>
        panic("create init_main failed.\n");
c010915d:	c7 44 24 08 02 c0 10 	movl   $0xc010c002,0x8(%esp)
c0109164:	c0 
c0109165:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c010916c:	00 
c010916d:	c7 04 24 61 bf 10 c0 	movl   $0xc010bf61,(%esp)
c0109174:	e8 7a 7b ff ff       	call   c0100cf3 <__panic>
    }

    initproc = find_proc(pid);
c0109179:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010917c:	89 04 24             	mov    %eax,(%esp)
c010917f:	e8 b2 fa ff ff       	call   c0108c36 <find_proc>
c0109184:	a3 44 80 12 c0       	mov    %eax,0xc0128044
    set_proc_name(initproc, "init");
c0109189:	a1 44 80 12 c0       	mov    0xc0128044,%eax
c010918e:	c7 44 24 04 1c c0 10 	movl   $0xc010c01c,0x4(%esp)
c0109195:	c0 
c0109196:	89 04 24             	mov    %eax,(%esp)
c0109199:	e8 12 f8 ff ff       	call   c01089b0 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010919e:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c01091a3:	85 c0                	test   %eax,%eax
c01091a5:	74 0c                	je     c01091b3 <proc_init+0x15f>
c01091a7:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c01091ac:	8b 40 04             	mov    0x4(%eax),%eax
c01091af:	85 c0                	test   %eax,%eax
c01091b1:	74 24                	je     c01091d7 <proc_init+0x183>
c01091b3:	c7 44 24 0c 24 c0 10 	movl   $0xc010c024,0xc(%esp)
c01091ba:	c0 
c01091bb:	c7 44 24 08 4c bf 10 	movl   $0xc010bf4c,0x8(%esp)
c01091c2:	c0 
c01091c3:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c01091ca:	00 
c01091cb:	c7 04 24 61 bf 10 c0 	movl   $0xc010bf61,(%esp)
c01091d2:	e8 1c 7b ff ff       	call   c0100cf3 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c01091d7:	a1 44 80 12 c0       	mov    0xc0128044,%eax
c01091dc:	85 c0                	test   %eax,%eax
c01091de:	74 0d                	je     c01091ed <proc_init+0x199>
c01091e0:	a1 44 80 12 c0       	mov    0xc0128044,%eax
c01091e5:	8b 40 04             	mov    0x4(%eax),%eax
c01091e8:	83 f8 01             	cmp    $0x1,%eax
c01091eb:	74 24                	je     c0109211 <proc_init+0x1bd>
c01091ed:	c7 44 24 0c 4c c0 10 	movl   $0xc010c04c,0xc(%esp)
c01091f4:	c0 
c01091f5:	c7 44 24 08 4c bf 10 	movl   $0xc010bf4c,0x8(%esp)
c01091fc:	c0 
c01091fd:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c0109204:	00 
c0109205:	c7 04 24 61 bf 10 c0 	movl   $0xc010bf61,(%esp)
c010920c:	e8 e2 7a ff ff       	call   c0100cf3 <__panic>
}
c0109211:	c9                   	leave  
c0109212:	c3                   	ret    

c0109213 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c0109213:	55                   	push   %ebp
c0109214:	89 e5                	mov    %esp,%ebp
c0109216:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c0109219:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c010921e:	8b 40 10             	mov    0x10(%eax),%eax
c0109221:	85 c0                	test   %eax,%eax
c0109223:	74 07                	je     c010922c <cpu_idle+0x19>
            schedule();
c0109225:	e8 c1 00 00 00       	call   c01092eb <schedule>
        }
    }
c010922a:	eb ed                	jmp    c0109219 <cpu_idle+0x6>
c010922c:	eb eb                	jmp    c0109219 <cpu_idle+0x6>

c010922e <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010922e:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c0109232:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c0109234:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c0109237:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c010923a:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c010923d:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c0109240:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c0109243:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c0109246:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0109249:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c010924d:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c0109250:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c0109253:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c0109256:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c0109259:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c010925c:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c010925f:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c0109262:	ff 30                	pushl  (%eax)

    ret
c0109264:	c3                   	ret    

c0109265 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0109265:	55                   	push   %ebp
c0109266:	89 e5                	mov    %esp,%ebp
c0109268:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010926b:	9c                   	pushf  
c010926c:	58                   	pop    %eax
c010926d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109270:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109273:	25 00 02 00 00       	and    $0x200,%eax
c0109278:	85 c0                	test   %eax,%eax
c010927a:	74 0c                	je     c0109288 <__intr_save+0x23>
        intr_disable();
c010927c:	e8 db 8c ff ff       	call   c0101f5c <intr_disable>
        return 1;
c0109281:	b8 01 00 00 00       	mov    $0x1,%eax
c0109286:	eb 05                	jmp    c010928d <__intr_save+0x28>
    }
    return 0;
c0109288:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010928d:	c9                   	leave  
c010928e:	c3                   	ret    

c010928f <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010928f:	55                   	push   %ebp
c0109290:	89 e5                	mov    %esp,%ebp
c0109292:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109295:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109299:	74 05                	je     c01092a0 <__intr_restore+0x11>
        intr_enable();
c010929b:	e8 b6 8c ff ff       	call   c0101f56 <intr_enable>
    }
}
c01092a0:	c9                   	leave  
c01092a1:	c3                   	ret    

c01092a2 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c01092a2:	55                   	push   %ebp
c01092a3:	89 e5                	mov    %esp,%ebp
c01092a5:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c01092a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01092ab:	8b 00                	mov    (%eax),%eax
c01092ad:	83 f8 03             	cmp    $0x3,%eax
c01092b0:	74 0a                	je     c01092bc <wakeup_proc+0x1a>
c01092b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01092b5:	8b 00                	mov    (%eax),%eax
c01092b7:	83 f8 02             	cmp    $0x2,%eax
c01092ba:	75 24                	jne    c01092e0 <wakeup_proc+0x3e>
c01092bc:	c7 44 24 0c 74 c0 10 	movl   $0xc010c074,0xc(%esp)
c01092c3:	c0 
c01092c4:	c7 44 24 08 af c0 10 	movl   $0xc010c0af,0x8(%esp)
c01092cb:	c0 
c01092cc:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c01092d3:	00 
c01092d4:	c7 04 24 c4 c0 10 c0 	movl   $0xc010c0c4,(%esp)
c01092db:	e8 13 7a ff ff       	call   c0100cf3 <__panic>
    proc->state = PROC_RUNNABLE;
c01092e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01092e3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c01092e9:	c9                   	leave  
c01092ea:	c3                   	ret    

c01092eb <schedule>:

void
schedule(void) {
c01092eb:	55                   	push   %ebp
c01092ec:	89 e5                	mov    %esp,%ebp
c01092ee:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c01092f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c01092f8:	e8 68 ff ff ff       	call   c0109265 <__intr_save>
c01092fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c0109300:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0109305:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010930c:	8b 15 48 80 12 c0    	mov    0xc0128048,%edx
c0109312:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c0109317:	39 c2                	cmp    %eax,%edx
c0109319:	74 0a                	je     c0109325 <schedule+0x3a>
c010931b:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0109320:	83 c0 58             	add    $0x58,%eax
c0109323:	eb 05                	jmp    c010932a <schedule+0x3f>
c0109325:	b8 d0 a1 12 c0       	mov    $0xc012a1d0,%eax
c010932a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010932d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109330:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109333:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010933c:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010933f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109342:	81 7d f4 d0 a1 12 c0 	cmpl   $0xc012a1d0,-0xc(%ebp)
c0109349:	74 15                	je     c0109360 <schedule+0x75>
                next = le2proc(le, list_link);
c010934b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010934e:	83 e8 58             	sub    $0x58,%eax
c0109351:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0109354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109357:	8b 00                	mov    (%eax),%eax
c0109359:	83 f8 02             	cmp    $0x2,%eax
c010935c:	75 02                	jne    c0109360 <schedule+0x75>
                    break;
c010935e:	eb 08                	jmp    c0109368 <schedule+0x7d>
                }
            }
        } while (le != last);
c0109360:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109363:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0109366:	75 cb                	jne    c0109333 <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0109368:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010936c:	74 0a                	je     c0109378 <schedule+0x8d>
c010936e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109371:	8b 00                	mov    (%eax),%eax
c0109373:	83 f8 02             	cmp    $0x2,%eax
c0109376:	74 08                	je     c0109380 <schedule+0x95>
            next = idleproc;
c0109378:	a1 40 80 12 c0       	mov    0xc0128040,%eax
c010937d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c0109380:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109383:	8b 40 08             	mov    0x8(%eax),%eax
c0109386:	8d 50 01             	lea    0x1(%eax),%edx
c0109389:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010938c:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010938f:	a1 48 80 12 c0       	mov    0xc0128048,%eax
c0109394:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109397:	74 0b                	je     c01093a4 <schedule+0xb9>
            proc_run(next);
c0109399:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010939c:	89 04 24             	mov    %eax,(%esp)
c010939f:	e8 89 f7 ff ff       	call   c0108b2d <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c01093a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01093a7:	89 04 24             	mov    %eax,(%esp)
c01093aa:	e8 e0 fe ff ff       	call   c010928f <__intr_restore>
}
c01093af:	c9                   	leave  
c01093b0:	c3                   	ret    

c01093b1 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c01093b1:	55                   	push   %ebp
c01093b2:	89 e5                	mov    %esp,%ebp
c01093b4:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c01093b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01093ba:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c01093c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c01093c3:	b8 20 00 00 00       	mov    $0x20,%eax
c01093c8:	2b 45 0c             	sub    0xc(%ebp),%eax
c01093cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01093ce:	89 c1                	mov    %eax,%ecx
c01093d0:	d3 ea                	shr    %cl,%edx
c01093d2:	89 d0                	mov    %edx,%eax
}
c01093d4:	c9                   	leave  
c01093d5:	c3                   	ret    

c01093d6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01093d6:	55                   	push   %ebp
c01093d7:	89 e5                	mov    %esp,%ebp
c01093d9:	83 ec 58             	sub    $0x58,%esp
c01093dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01093df:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01093e2:	8b 45 14             	mov    0x14(%ebp),%eax
c01093e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01093e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01093eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01093ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01093f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01093f4:	8b 45 18             	mov    0x18(%ebp),%eax
c01093f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01093fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01093fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109400:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109403:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0109406:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109409:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010940c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109410:	74 1c                	je     c010942e <printnum+0x58>
c0109412:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109415:	ba 00 00 00 00       	mov    $0x0,%edx
c010941a:	f7 75 e4             	divl   -0x1c(%ebp)
c010941d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109420:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109423:	ba 00 00 00 00       	mov    $0x0,%edx
c0109428:	f7 75 e4             	divl   -0x1c(%ebp)
c010942b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010942e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109431:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109434:	f7 75 e4             	divl   -0x1c(%ebp)
c0109437:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010943a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010943d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109440:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109443:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109446:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109449:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010944c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010944f:	8b 45 18             	mov    0x18(%ebp),%eax
c0109452:	ba 00 00 00 00       	mov    $0x0,%edx
c0109457:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010945a:	77 56                	ja     c01094b2 <printnum+0xdc>
c010945c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010945f:	72 05                	jb     c0109466 <printnum+0x90>
c0109461:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0109464:	77 4c                	ja     c01094b2 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0109466:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0109469:	8d 50 ff             	lea    -0x1(%eax),%edx
c010946c:	8b 45 20             	mov    0x20(%ebp),%eax
c010946f:	89 44 24 18          	mov    %eax,0x18(%esp)
c0109473:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109477:	8b 45 18             	mov    0x18(%ebp),%eax
c010947a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010947e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109481:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109484:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109488:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010948c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010948f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109493:	8b 45 08             	mov    0x8(%ebp),%eax
c0109496:	89 04 24             	mov    %eax,(%esp)
c0109499:	e8 38 ff ff ff       	call   c01093d6 <printnum>
c010949e:	eb 1c                	jmp    c01094bc <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01094a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01094a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094a7:	8b 45 20             	mov    0x20(%ebp),%eax
c01094aa:	89 04 24             	mov    %eax,(%esp)
c01094ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b0:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01094b2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01094b6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01094ba:	7f e4                	jg     c01094a0 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01094bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01094bf:	05 5c c1 10 c0       	add    $0xc010c15c,%eax
c01094c4:	0f b6 00             	movzbl (%eax),%eax
c01094c7:	0f be c0             	movsbl %al,%eax
c01094ca:	8b 55 0c             	mov    0xc(%ebp),%edx
c01094cd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01094d1:	89 04 24             	mov    %eax,(%esp)
c01094d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01094d7:	ff d0                	call   *%eax
}
c01094d9:	c9                   	leave  
c01094da:	c3                   	ret    

c01094db <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01094db:	55                   	push   %ebp
c01094dc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01094de:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01094e2:	7e 14                	jle    c01094f8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01094e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e7:	8b 00                	mov    (%eax),%eax
c01094e9:	8d 48 08             	lea    0x8(%eax),%ecx
c01094ec:	8b 55 08             	mov    0x8(%ebp),%edx
c01094ef:	89 0a                	mov    %ecx,(%edx)
c01094f1:	8b 50 04             	mov    0x4(%eax),%edx
c01094f4:	8b 00                	mov    (%eax),%eax
c01094f6:	eb 30                	jmp    c0109528 <getuint+0x4d>
    }
    else if (lflag) {
c01094f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01094fc:	74 16                	je     c0109514 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01094fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109501:	8b 00                	mov    (%eax),%eax
c0109503:	8d 48 04             	lea    0x4(%eax),%ecx
c0109506:	8b 55 08             	mov    0x8(%ebp),%edx
c0109509:	89 0a                	mov    %ecx,(%edx)
c010950b:	8b 00                	mov    (%eax),%eax
c010950d:	ba 00 00 00 00       	mov    $0x0,%edx
c0109512:	eb 14                	jmp    c0109528 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0109514:	8b 45 08             	mov    0x8(%ebp),%eax
c0109517:	8b 00                	mov    (%eax),%eax
c0109519:	8d 48 04             	lea    0x4(%eax),%ecx
c010951c:	8b 55 08             	mov    0x8(%ebp),%edx
c010951f:	89 0a                	mov    %ecx,(%edx)
c0109521:	8b 00                	mov    (%eax),%eax
c0109523:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0109528:	5d                   	pop    %ebp
c0109529:	c3                   	ret    

c010952a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010952a:	55                   	push   %ebp
c010952b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010952d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0109531:	7e 14                	jle    c0109547 <getint+0x1d>
        return va_arg(*ap, long long);
c0109533:	8b 45 08             	mov    0x8(%ebp),%eax
c0109536:	8b 00                	mov    (%eax),%eax
c0109538:	8d 48 08             	lea    0x8(%eax),%ecx
c010953b:	8b 55 08             	mov    0x8(%ebp),%edx
c010953e:	89 0a                	mov    %ecx,(%edx)
c0109540:	8b 50 04             	mov    0x4(%eax),%edx
c0109543:	8b 00                	mov    (%eax),%eax
c0109545:	eb 28                	jmp    c010956f <getint+0x45>
    }
    else if (lflag) {
c0109547:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010954b:	74 12                	je     c010955f <getint+0x35>
        return va_arg(*ap, long);
c010954d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109550:	8b 00                	mov    (%eax),%eax
c0109552:	8d 48 04             	lea    0x4(%eax),%ecx
c0109555:	8b 55 08             	mov    0x8(%ebp),%edx
c0109558:	89 0a                	mov    %ecx,(%edx)
c010955a:	8b 00                	mov    (%eax),%eax
c010955c:	99                   	cltd   
c010955d:	eb 10                	jmp    c010956f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010955f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109562:	8b 00                	mov    (%eax),%eax
c0109564:	8d 48 04             	lea    0x4(%eax),%ecx
c0109567:	8b 55 08             	mov    0x8(%ebp),%edx
c010956a:	89 0a                	mov    %ecx,(%edx)
c010956c:	8b 00                	mov    (%eax),%eax
c010956e:	99                   	cltd   
    }
}
c010956f:	5d                   	pop    %ebp
c0109570:	c3                   	ret    

c0109571 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0109571:	55                   	push   %ebp
c0109572:	89 e5                	mov    %esp,%ebp
c0109574:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0109577:	8d 45 14             	lea    0x14(%ebp),%eax
c010957a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010957d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109580:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109584:	8b 45 10             	mov    0x10(%ebp),%eax
c0109587:	89 44 24 08          	mov    %eax,0x8(%esp)
c010958b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010958e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109592:	8b 45 08             	mov    0x8(%ebp),%eax
c0109595:	89 04 24             	mov    %eax,(%esp)
c0109598:	e8 02 00 00 00       	call   c010959f <vprintfmt>
    va_end(ap);
}
c010959d:	c9                   	leave  
c010959e:	c3                   	ret    

c010959f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010959f:	55                   	push   %ebp
c01095a0:	89 e5                	mov    %esp,%ebp
c01095a2:	56                   	push   %esi
c01095a3:	53                   	push   %ebx
c01095a4:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01095a7:	eb 18                	jmp    c01095c1 <vprintfmt+0x22>
            if (ch == '\0') {
c01095a9:	85 db                	test   %ebx,%ebx
c01095ab:	75 05                	jne    c01095b2 <vprintfmt+0x13>
                return;
c01095ad:	e9 d1 03 00 00       	jmp    c0109983 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01095b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01095b9:	89 1c 24             	mov    %ebx,(%esp)
c01095bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01095bf:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01095c1:	8b 45 10             	mov    0x10(%ebp),%eax
c01095c4:	8d 50 01             	lea    0x1(%eax),%edx
c01095c7:	89 55 10             	mov    %edx,0x10(%ebp)
c01095ca:	0f b6 00             	movzbl (%eax),%eax
c01095cd:	0f b6 d8             	movzbl %al,%ebx
c01095d0:	83 fb 25             	cmp    $0x25,%ebx
c01095d3:	75 d4                	jne    c01095a9 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01095d5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01095d9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01095e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01095e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01095e6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01095ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01095f0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01095f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01095f6:	8d 50 01             	lea    0x1(%eax),%edx
c01095f9:	89 55 10             	mov    %edx,0x10(%ebp)
c01095fc:	0f b6 00             	movzbl (%eax),%eax
c01095ff:	0f b6 d8             	movzbl %al,%ebx
c0109602:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0109605:	83 f8 55             	cmp    $0x55,%eax
c0109608:	0f 87 44 03 00 00    	ja     c0109952 <vprintfmt+0x3b3>
c010960e:	8b 04 85 80 c1 10 c0 	mov    -0x3fef3e80(,%eax,4),%eax
c0109615:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0109617:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010961b:	eb d6                	jmp    c01095f3 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010961d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0109621:	eb d0                	jmp    c01095f3 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0109623:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010962a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010962d:	89 d0                	mov    %edx,%eax
c010962f:	c1 e0 02             	shl    $0x2,%eax
c0109632:	01 d0                	add    %edx,%eax
c0109634:	01 c0                	add    %eax,%eax
c0109636:	01 d8                	add    %ebx,%eax
c0109638:	83 e8 30             	sub    $0x30,%eax
c010963b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010963e:	8b 45 10             	mov    0x10(%ebp),%eax
c0109641:	0f b6 00             	movzbl (%eax),%eax
c0109644:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0109647:	83 fb 2f             	cmp    $0x2f,%ebx
c010964a:	7e 0b                	jle    c0109657 <vprintfmt+0xb8>
c010964c:	83 fb 39             	cmp    $0x39,%ebx
c010964f:	7f 06                	jg     c0109657 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0109651:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0109655:	eb d3                	jmp    c010962a <vprintfmt+0x8b>
            goto process_precision;
c0109657:	eb 33                	jmp    c010968c <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0109659:	8b 45 14             	mov    0x14(%ebp),%eax
c010965c:	8d 50 04             	lea    0x4(%eax),%edx
c010965f:	89 55 14             	mov    %edx,0x14(%ebp)
c0109662:	8b 00                	mov    (%eax),%eax
c0109664:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0109667:	eb 23                	jmp    c010968c <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0109669:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010966d:	79 0c                	jns    c010967b <vprintfmt+0xdc>
                width = 0;
c010966f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0109676:	e9 78 ff ff ff       	jmp    c01095f3 <vprintfmt+0x54>
c010967b:	e9 73 ff ff ff       	jmp    c01095f3 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0109680:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0109687:	e9 67 ff ff ff       	jmp    c01095f3 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010968c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109690:	79 12                	jns    c01096a4 <vprintfmt+0x105>
                width = precision, precision = -1;
c0109692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109695:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109698:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010969f:	e9 4f ff ff ff       	jmp    c01095f3 <vprintfmt+0x54>
c01096a4:	e9 4a ff ff ff       	jmp    c01095f3 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01096a9:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c01096ad:	e9 41 ff ff ff       	jmp    c01095f3 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01096b2:	8b 45 14             	mov    0x14(%ebp),%eax
c01096b5:	8d 50 04             	lea    0x4(%eax),%edx
c01096b8:	89 55 14             	mov    %edx,0x14(%ebp)
c01096bb:	8b 00                	mov    (%eax),%eax
c01096bd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01096c0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01096c4:	89 04 24             	mov    %eax,(%esp)
c01096c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01096ca:	ff d0                	call   *%eax
            break;
c01096cc:	e9 ac 02 00 00       	jmp    c010997d <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01096d1:	8b 45 14             	mov    0x14(%ebp),%eax
c01096d4:	8d 50 04             	lea    0x4(%eax),%edx
c01096d7:	89 55 14             	mov    %edx,0x14(%ebp)
c01096da:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01096dc:	85 db                	test   %ebx,%ebx
c01096de:	79 02                	jns    c01096e2 <vprintfmt+0x143>
                err = -err;
c01096e0:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01096e2:	83 fb 06             	cmp    $0x6,%ebx
c01096e5:	7f 0b                	jg     c01096f2 <vprintfmt+0x153>
c01096e7:	8b 34 9d 40 c1 10 c0 	mov    -0x3fef3ec0(,%ebx,4),%esi
c01096ee:	85 f6                	test   %esi,%esi
c01096f0:	75 23                	jne    c0109715 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01096f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01096f6:	c7 44 24 08 6d c1 10 	movl   $0xc010c16d,0x8(%esp)
c01096fd:	c0 
c01096fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109701:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109705:	8b 45 08             	mov    0x8(%ebp),%eax
c0109708:	89 04 24             	mov    %eax,(%esp)
c010970b:	e8 61 fe ff ff       	call   c0109571 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0109710:	e9 68 02 00 00       	jmp    c010997d <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0109715:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0109719:	c7 44 24 08 76 c1 10 	movl   $0xc010c176,0x8(%esp)
c0109720:	c0 
c0109721:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109724:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109728:	8b 45 08             	mov    0x8(%ebp),%eax
c010972b:	89 04 24             	mov    %eax,(%esp)
c010972e:	e8 3e fe ff ff       	call   c0109571 <printfmt>
            }
            break;
c0109733:	e9 45 02 00 00       	jmp    c010997d <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0109738:	8b 45 14             	mov    0x14(%ebp),%eax
c010973b:	8d 50 04             	lea    0x4(%eax),%edx
c010973e:	89 55 14             	mov    %edx,0x14(%ebp)
c0109741:	8b 30                	mov    (%eax),%esi
c0109743:	85 f6                	test   %esi,%esi
c0109745:	75 05                	jne    c010974c <vprintfmt+0x1ad>
                p = "(null)";
c0109747:	be 79 c1 10 c0       	mov    $0xc010c179,%esi
            }
            if (width > 0 && padc != '-') {
c010974c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109750:	7e 3e                	jle    c0109790 <vprintfmt+0x1f1>
c0109752:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0109756:	74 38                	je     c0109790 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109758:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010975b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010975e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109762:	89 34 24             	mov    %esi,(%esp)
c0109765:	e8 ed 03 00 00       	call   c0109b57 <strnlen>
c010976a:	29 c3                	sub    %eax,%ebx
c010976c:	89 d8                	mov    %ebx,%eax
c010976e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109771:	eb 17                	jmp    c010978a <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0109773:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0109777:	8b 55 0c             	mov    0xc(%ebp),%edx
c010977a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010977e:	89 04 24             	mov    %eax,(%esp)
c0109781:	8b 45 08             	mov    0x8(%ebp),%eax
c0109784:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109786:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010978a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010978e:	7f e3                	jg     c0109773 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109790:	eb 38                	jmp    c01097ca <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0109792:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109796:	74 1f                	je     c01097b7 <vprintfmt+0x218>
c0109798:	83 fb 1f             	cmp    $0x1f,%ebx
c010979b:	7e 05                	jle    c01097a2 <vprintfmt+0x203>
c010979d:	83 fb 7e             	cmp    $0x7e,%ebx
c01097a0:	7e 15                	jle    c01097b7 <vprintfmt+0x218>
                    putch('?', putdat);
c01097a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097a9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01097b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01097b3:	ff d0                	call   *%eax
c01097b5:	eb 0f                	jmp    c01097c6 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c01097b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097be:	89 1c 24             	mov    %ebx,(%esp)
c01097c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01097c4:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01097c6:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01097ca:	89 f0                	mov    %esi,%eax
c01097cc:	8d 70 01             	lea    0x1(%eax),%esi
c01097cf:	0f b6 00             	movzbl (%eax),%eax
c01097d2:	0f be d8             	movsbl %al,%ebx
c01097d5:	85 db                	test   %ebx,%ebx
c01097d7:	74 10                	je     c01097e9 <vprintfmt+0x24a>
c01097d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01097dd:	78 b3                	js     c0109792 <vprintfmt+0x1f3>
c01097df:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c01097e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01097e7:	79 a9                	jns    c0109792 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01097e9:	eb 17                	jmp    c0109802 <vprintfmt+0x263>
                putch(' ', putdat);
c01097eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01097f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01097fc:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01097fe:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0109802:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109806:	7f e3                	jg     c01097eb <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c0109808:	e9 70 01 00 00       	jmp    c010997d <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010980d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109810:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109814:	8d 45 14             	lea    0x14(%ebp),%eax
c0109817:	89 04 24             	mov    %eax,(%esp)
c010981a:	e8 0b fd ff ff       	call   c010952a <getint>
c010981f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109822:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0109825:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109828:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010982b:	85 d2                	test   %edx,%edx
c010982d:	79 26                	jns    c0109855 <vprintfmt+0x2b6>
                putch('-', putdat);
c010982f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109832:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109836:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010983d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109840:	ff d0                	call   *%eax
                num = -(long long)num;
c0109842:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109845:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109848:	f7 d8                	neg    %eax
c010984a:	83 d2 00             	adc    $0x0,%edx
c010984d:	f7 da                	neg    %edx
c010984f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109852:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0109855:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010985c:	e9 a8 00 00 00       	jmp    c0109909 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0109861:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109864:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109868:	8d 45 14             	lea    0x14(%ebp),%eax
c010986b:	89 04 24             	mov    %eax,(%esp)
c010986e:	e8 68 fc ff ff       	call   c01094db <getuint>
c0109873:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109876:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0109879:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109880:	e9 84 00 00 00       	jmp    c0109909 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0109885:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109888:	89 44 24 04          	mov    %eax,0x4(%esp)
c010988c:	8d 45 14             	lea    0x14(%ebp),%eax
c010988f:	89 04 24             	mov    %eax,(%esp)
c0109892:	e8 44 fc ff ff       	call   c01094db <getuint>
c0109897:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010989a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010989d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01098a4:	eb 63                	jmp    c0109909 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c01098a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01098a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098ad:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01098b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01098b7:	ff d0                	call   *%eax
            putch('x', putdat);
c01098b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01098bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098c0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01098c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ca:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01098cc:	8b 45 14             	mov    0x14(%ebp),%eax
c01098cf:	8d 50 04             	lea    0x4(%eax),%edx
c01098d2:	89 55 14             	mov    %edx,0x14(%ebp)
c01098d5:	8b 00                	mov    (%eax),%eax
c01098d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01098da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01098e1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01098e8:	eb 1f                	jmp    c0109909 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01098ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01098ed:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098f1:	8d 45 14             	lea    0x14(%ebp),%eax
c01098f4:	89 04 24             	mov    %eax,(%esp)
c01098f7:	e8 df fb ff ff       	call   c01094db <getuint>
c01098fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01098ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0109902:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0109909:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010990d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109910:	89 54 24 18          	mov    %edx,0x18(%esp)
c0109914:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109917:	89 54 24 14          	mov    %edx,0x14(%esp)
c010991b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010991f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109922:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109925:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109929:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010992d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109930:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109934:	8b 45 08             	mov    0x8(%ebp),%eax
c0109937:	89 04 24             	mov    %eax,(%esp)
c010993a:	e8 97 fa ff ff       	call   c01093d6 <printnum>
            break;
c010993f:	eb 3c                	jmp    c010997d <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0109941:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109944:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109948:	89 1c 24             	mov    %ebx,(%esp)
c010994b:	8b 45 08             	mov    0x8(%ebp),%eax
c010994e:	ff d0                	call   *%eax
            break;
c0109950:	eb 2b                	jmp    c010997d <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0109952:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109955:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109959:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0109960:	8b 45 08             	mov    0x8(%ebp),%eax
c0109963:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109965:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0109969:	eb 04                	jmp    c010996f <vprintfmt+0x3d0>
c010996b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010996f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109972:	83 e8 01             	sub    $0x1,%eax
c0109975:	0f b6 00             	movzbl (%eax),%eax
c0109978:	3c 25                	cmp    $0x25,%al
c010997a:	75 ef                	jne    c010996b <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010997c:	90                   	nop
        }
    }
c010997d:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010997e:	e9 3e fc ff ff       	jmp    c01095c1 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0109983:	83 c4 40             	add    $0x40,%esp
c0109986:	5b                   	pop    %ebx
c0109987:	5e                   	pop    %esi
c0109988:	5d                   	pop    %ebp
c0109989:	c3                   	ret    

c010998a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010998a:	55                   	push   %ebp
c010998b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010998d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109990:	8b 40 08             	mov    0x8(%eax),%eax
c0109993:	8d 50 01             	lea    0x1(%eax),%edx
c0109996:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109999:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010999c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010999f:	8b 10                	mov    (%eax),%edx
c01099a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01099a4:	8b 40 04             	mov    0x4(%eax),%eax
c01099a7:	39 c2                	cmp    %eax,%edx
c01099a9:	73 12                	jae    c01099bd <sprintputch+0x33>
        *b->buf ++ = ch;
c01099ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01099ae:	8b 00                	mov    (%eax),%eax
c01099b0:	8d 48 01             	lea    0x1(%eax),%ecx
c01099b3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01099b6:	89 0a                	mov    %ecx,(%edx)
c01099b8:	8b 55 08             	mov    0x8(%ebp),%edx
c01099bb:	88 10                	mov    %dl,(%eax)
    }
}
c01099bd:	5d                   	pop    %ebp
c01099be:	c3                   	ret    

c01099bf <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01099bf:	55                   	push   %ebp
c01099c0:	89 e5                	mov    %esp,%ebp
c01099c2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01099c5:	8d 45 14             	lea    0x14(%ebp),%eax
c01099c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c01099cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01099d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01099d5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01099d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01099dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099e3:	89 04 24             	mov    %eax,(%esp)
c01099e6:	e8 08 00 00 00       	call   c01099f3 <vsnprintf>
c01099eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01099ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01099f1:	c9                   	leave  
c01099f2:	c3                   	ret    

c01099f3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01099f3:	55                   	push   %ebp
c01099f4:	89 e5                	mov    %esp,%ebp
c01099f6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01099f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01099fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01099ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a02:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109a05:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a08:	01 d0                	add    %edx,%eax
c0109a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109a14:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109a18:	74 0a                	je     c0109a24 <vsnprintf+0x31>
c0109a1a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a20:	39 c2                	cmp    %eax,%edx
c0109a22:	76 07                	jbe    c0109a2b <vsnprintf+0x38>
        return -E_INVAL;
c0109a24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109a29:	eb 2a                	jmp    c0109a55 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0109a2b:	8b 45 14             	mov    0x14(%ebp),%eax
c0109a2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109a32:	8b 45 10             	mov    0x10(%ebp),%eax
c0109a35:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109a39:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0109a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a40:	c7 04 24 8a 99 10 c0 	movl   $0xc010998a,(%esp)
c0109a47:	e8 53 fb ff ff       	call   c010959f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0109a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a4f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0109a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109a55:	c9                   	leave  
c0109a56:	c3                   	ret    

c0109a57 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0109a57:	55                   	push   %ebp
c0109a58:	89 e5                	mov    %esp,%ebp
c0109a5a:	57                   	push   %edi
c0109a5b:	56                   	push   %esi
c0109a5c:	53                   	push   %ebx
c0109a5d:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0109a60:	a1 88 4a 12 c0       	mov    0xc0124a88,%eax
c0109a65:	8b 15 8c 4a 12 c0    	mov    0xc0124a8c,%edx
c0109a6b:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0109a71:	6b f0 05             	imul   $0x5,%eax,%esi
c0109a74:	01 f7                	add    %esi,%edi
c0109a76:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c0109a7b:	f7 e6                	mul    %esi
c0109a7d:	8d 34 17             	lea    (%edi,%edx,1),%esi
c0109a80:	89 f2                	mov    %esi,%edx
c0109a82:	83 c0 0b             	add    $0xb,%eax
c0109a85:	83 d2 00             	adc    $0x0,%edx
c0109a88:	89 c7                	mov    %eax,%edi
c0109a8a:	83 e7 ff             	and    $0xffffffff,%edi
c0109a8d:	89 f9                	mov    %edi,%ecx
c0109a8f:	0f b7 da             	movzwl %dx,%ebx
c0109a92:	89 0d 88 4a 12 c0    	mov    %ecx,0xc0124a88
c0109a98:	89 1d 8c 4a 12 c0    	mov    %ebx,0xc0124a8c
    unsigned long long result = (next >> 12);
c0109a9e:	a1 88 4a 12 c0       	mov    0xc0124a88,%eax
c0109aa3:	8b 15 8c 4a 12 c0    	mov    0xc0124a8c,%edx
c0109aa9:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109aad:	c1 ea 0c             	shr    $0xc,%edx
c0109ab0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109ab3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109ab6:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109abd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109ac0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109ac3:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109ac6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109ac9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109acc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109acf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109ad3:	74 1c                	je     c0109af1 <rand+0x9a>
c0109ad5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ad8:	ba 00 00 00 00       	mov    $0x0,%edx
c0109add:	f7 75 dc             	divl   -0x24(%ebp)
c0109ae0:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109ae3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ae6:	ba 00 00 00 00       	mov    $0x0,%edx
c0109aeb:	f7 75 dc             	divl   -0x24(%ebp)
c0109aee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109af1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109af4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109af7:	f7 75 dc             	divl   -0x24(%ebp)
c0109afa:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109afd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109b00:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109b03:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109b06:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109b09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109b0c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0109b0f:	83 c4 24             	add    $0x24,%esp
c0109b12:	5b                   	pop    %ebx
c0109b13:	5e                   	pop    %esi
c0109b14:	5f                   	pop    %edi
c0109b15:	5d                   	pop    %ebp
c0109b16:	c3                   	ret    

c0109b17 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0109b17:	55                   	push   %ebp
c0109b18:	89 e5                	mov    %esp,%ebp
    next = seed;
c0109b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b1d:	ba 00 00 00 00       	mov    $0x0,%edx
c0109b22:	a3 88 4a 12 c0       	mov    %eax,0xc0124a88
c0109b27:	89 15 8c 4a 12 c0    	mov    %edx,0xc0124a8c
}
c0109b2d:	5d                   	pop    %ebp
c0109b2e:	c3                   	ret    

c0109b2f <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109b2f:	55                   	push   %ebp
c0109b30:	89 e5                	mov    %esp,%ebp
c0109b32:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109b35:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109b3c:	eb 04                	jmp    c0109b42 <strlen+0x13>
        cnt ++;
c0109b3e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0109b42:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b45:	8d 50 01             	lea    0x1(%eax),%edx
c0109b48:	89 55 08             	mov    %edx,0x8(%ebp)
c0109b4b:	0f b6 00             	movzbl (%eax),%eax
c0109b4e:	84 c0                	test   %al,%al
c0109b50:	75 ec                	jne    c0109b3e <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0109b52:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109b55:	c9                   	leave  
c0109b56:	c3                   	ret    

c0109b57 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0109b57:	55                   	push   %ebp
c0109b58:	89 e5                	mov    %esp,%ebp
c0109b5a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109b5d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109b64:	eb 04                	jmp    c0109b6a <strnlen+0x13>
        cnt ++;
c0109b66:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0109b6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109b6d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109b70:	73 10                	jae    c0109b82 <strnlen+0x2b>
c0109b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b75:	8d 50 01             	lea    0x1(%eax),%edx
c0109b78:	89 55 08             	mov    %edx,0x8(%ebp)
c0109b7b:	0f b6 00             	movzbl (%eax),%eax
c0109b7e:	84 c0                	test   %al,%al
c0109b80:	75 e4                	jne    c0109b66 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0109b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109b85:	c9                   	leave  
c0109b86:	c3                   	ret    

c0109b87 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0109b87:	55                   	push   %ebp
c0109b88:	89 e5                	mov    %esp,%ebp
c0109b8a:	57                   	push   %edi
c0109b8b:	56                   	push   %esi
c0109b8c:	83 ec 20             	sub    $0x20,%esp
c0109b8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b92:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b98:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0109b9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ba1:	89 d1                	mov    %edx,%ecx
c0109ba3:	89 c2                	mov    %eax,%edx
c0109ba5:	89 ce                	mov    %ecx,%esi
c0109ba7:	89 d7                	mov    %edx,%edi
c0109ba9:	ac                   	lods   %ds:(%esi),%al
c0109baa:	aa                   	stos   %al,%es:(%edi)
c0109bab:	84 c0                	test   %al,%al
c0109bad:	75 fa                	jne    c0109ba9 <strcpy+0x22>
c0109baf:	89 fa                	mov    %edi,%edx
c0109bb1:	89 f1                	mov    %esi,%ecx
c0109bb3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109bb6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109bb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0109bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0109bbf:	83 c4 20             	add    $0x20,%esp
c0109bc2:	5e                   	pop    %esi
c0109bc3:	5f                   	pop    %edi
c0109bc4:	5d                   	pop    %ebp
c0109bc5:	c3                   	ret    

c0109bc6 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0109bc6:	55                   	push   %ebp
c0109bc7:	89 e5                	mov    %esp,%ebp
c0109bc9:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0109bcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bcf:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0109bd2:	eb 21                	jmp    c0109bf5 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0109bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bd7:	0f b6 10             	movzbl (%eax),%edx
c0109bda:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109bdd:	88 10                	mov    %dl,(%eax)
c0109bdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109be2:	0f b6 00             	movzbl (%eax),%eax
c0109be5:	84 c0                	test   %al,%al
c0109be7:	74 04                	je     c0109bed <strncpy+0x27>
            src ++;
c0109be9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0109bed:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0109bf1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0109bf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109bf9:	75 d9                	jne    c0109bd4 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0109bfb:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109bfe:	c9                   	leave  
c0109bff:	c3                   	ret    

c0109c00 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0109c00:	55                   	push   %ebp
c0109c01:	89 e5                	mov    %esp,%ebp
c0109c03:	57                   	push   %edi
c0109c04:	56                   	push   %esi
c0109c05:	83 ec 20             	sub    $0x20,%esp
c0109c08:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c11:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0109c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c1a:	89 d1                	mov    %edx,%ecx
c0109c1c:	89 c2                	mov    %eax,%edx
c0109c1e:	89 ce                	mov    %ecx,%esi
c0109c20:	89 d7                	mov    %edx,%edi
c0109c22:	ac                   	lods   %ds:(%esi),%al
c0109c23:	ae                   	scas   %es:(%edi),%al
c0109c24:	75 08                	jne    c0109c2e <strcmp+0x2e>
c0109c26:	84 c0                	test   %al,%al
c0109c28:	75 f8                	jne    c0109c22 <strcmp+0x22>
c0109c2a:	31 c0                	xor    %eax,%eax
c0109c2c:	eb 04                	jmp    c0109c32 <strcmp+0x32>
c0109c2e:	19 c0                	sbb    %eax,%eax
c0109c30:	0c 01                	or     $0x1,%al
c0109c32:	89 fa                	mov    %edi,%edx
c0109c34:	89 f1                	mov    %esi,%ecx
c0109c36:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109c39:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109c3c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0109c3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0109c42:	83 c4 20             	add    $0x20,%esp
c0109c45:	5e                   	pop    %esi
c0109c46:	5f                   	pop    %edi
c0109c47:	5d                   	pop    %ebp
c0109c48:	c3                   	ret    

c0109c49 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0109c49:	55                   	push   %ebp
c0109c4a:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109c4c:	eb 0c                	jmp    c0109c5a <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0109c4e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0109c52:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109c56:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109c5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109c5e:	74 1a                	je     c0109c7a <strncmp+0x31>
c0109c60:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c63:	0f b6 00             	movzbl (%eax),%eax
c0109c66:	84 c0                	test   %al,%al
c0109c68:	74 10                	je     c0109c7a <strncmp+0x31>
c0109c6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c6d:	0f b6 10             	movzbl (%eax),%edx
c0109c70:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c73:	0f b6 00             	movzbl (%eax),%eax
c0109c76:	38 c2                	cmp    %al,%dl
c0109c78:	74 d4                	je     c0109c4e <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109c7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109c7e:	74 18                	je     c0109c98 <strncmp+0x4f>
c0109c80:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c83:	0f b6 00             	movzbl (%eax),%eax
c0109c86:	0f b6 d0             	movzbl %al,%edx
c0109c89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c8c:	0f b6 00             	movzbl (%eax),%eax
c0109c8f:	0f b6 c0             	movzbl %al,%eax
c0109c92:	29 c2                	sub    %eax,%edx
c0109c94:	89 d0                	mov    %edx,%eax
c0109c96:	eb 05                	jmp    c0109c9d <strncmp+0x54>
c0109c98:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109c9d:	5d                   	pop    %ebp
c0109c9e:	c3                   	ret    

c0109c9f <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0109c9f:	55                   	push   %ebp
c0109ca0:	89 e5                	mov    %esp,%ebp
c0109ca2:	83 ec 04             	sub    $0x4,%esp
c0109ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ca8:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109cab:	eb 14                	jmp    c0109cc1 <strchr+0x22>
        if (*s == c) {
c0109cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cb0:	0f b6 00             	movzbl (%eax),%eax
c0109cb3:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109cb6:	75 05                	jne    c0109cbd <strchr+0x1e>
            return (char *)s;
c0109cb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cbb:	eb 13                	jmp    c0109cd0 <strchr+0x31>
        }
        s ++;
c0109cbd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0109cc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cc4:	0f b6 00             	movzbl (%eax),%eax
c0109cc7:	84 c0                	test   %al,%al
c0109cc9:	75 e2                	jne    c0109cad <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0109ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109cd0:	c9                   	leave  
c0109cd1:	c3                   	ret    

c0109cd2 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0109cd2:	55                   	push   %ebp
c0109cd3:	89 e5                	mov    %esp,%ebp
c0109cd5:	83 ec 04             	sub    $0x4,%esp
c0109cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109cdb:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109cde:	eb 11                	jmp    c0109cf1 <strfind+0x1f>
        if (*s == c) {
c0109ce0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ce3:	0f b6 00             	movzbl (%eax),%eax
c0109ce6:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109ce9:	75 02                	jne    c0109ced <strfind+0x1b>
            break;
c0109ceb:	eb 0e                	jmp    c0109cfb <strfind+0x29>
        }
        s ++;
c0109ced:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0109cf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cf4:	0f b6 00             	movzbl (%eax),%eax
c0109cf7:	84 c0                	test   %al,%al
c0109cf9:	75 e5                	jne    c0109ce0 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0109cfb:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109cfe:	c9                   	leave  
c0109cff:	c3                   	ret    

c0109d00 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0109d00:	55                   	push   %ebp
c0109d01:	89 e5                	mov    %esp,%ebp
c0109d03:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0109d06:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0109d0d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109d14:	eb 04                	jmp    c0109d1a <strtol+0x1a>
        s ++;
c0109d16:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109d1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d1d:	0f b6 00             	movzbl (%eax),%eax
c0109d20:	3c 20                	cmp    $0x20,%al
c0109d22:	74 f2                	je     c0109d16 <strtol+0x16>
c0109d24:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d27:	0f b6 00             	movzbl (%eax),%eax
c0109d2a:	3c 09                	cmp    $0x9,%al
c0109d2c:	74 e8                	je     c0109d16 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0109d2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d31:	0f b6 00             	movzbl (%eax),%eax
c0109d34:	3c 2b                	cmp    $0x2b,%al
c0109d36:	75 06                	jne    c0109d3e <strtol+0x3e>
        s ++;
c0109d38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109d3c:	eb 15                	jmp    c0109d53 <strtol+0x53>
    }
    else if (*s == '-') {
c0109d3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d41:	0f b6 00             	movzbl (%eax),%eax
c0109d44:	3c 2d                	cmp    $0x2d,%al
c0109d46:	75 0b                	jne    c0109d53 <strtol+0x53>
        s ++, neg = 1;
c0109d48:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109d4c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0109d53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109d57:	74 06                	je     c0109d5f <strtol+0x5f>
c0109d59:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0109d5d:	75 24                	jne    c0109d83 <strtol+0x83>
c0109d5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d62:	0f b6 00             	movzbl (%eax),%eax
c0109d65:	3c 30                	cmp    $0x30,%al
c0109d67:	75 1a                	jne    c0109d83 <strtol+0x83>
c0109d69:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d6c:	83 c0 01             	add    $0x1,%eax
c0109d6f:	0f b6 00             	movzbl (%eax),%eax
c0109d72:	3c 78                	cmp    $0x78,%al
c0109d74:	75 0d                	jne    c0109d83 <strtol+0x83>
        s += 2, base = 16;
c0109d76:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0109d7a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0109d81:	eb 2a                	jmp    c0109dad <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0109d83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109d87:	75 17                	jne    c0109da0 <strtol+0xa0>
c0109d89:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d8c:	0f b6 00             	movzbl (%eax),%eax
c0109d8f:	3c 30                	cmp    $0x30,%al
c0109d91:	75 0d                	jne    c0109da0 <strtol+0xa0>
        s ++, base = 8;
c0109d93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109d97:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0109d9e:	eb 0d                	jmp    c0109dad <strtol+0xad>
    }
    else if (base == 0) {
c0109da0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109da4:	75 07                	jne    c0109dad <strtol+0xad>
        base = 10;
c0109da6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0109dad:	8b 45 08             	mov    0x8(%ebp),%eax
c0109db0:	0f b6 00             	movzbl (%eax),%eax
c0109db3:	3c 2f                	cmp    $0x2f,%al
c0109db5:	7e 1b                	jle    c0109dd2 <strtol+0xd2>
c0109db7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dba:	0f b6 00             	movzbl (%eax),%eax
c0109dbd:	3c 39                	cmp    $0x39,%al
c0109dbf:	7f 11                	jg     c0109dd2 <strtol+0xd2>
            dig = *s - '0';
c0109dc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dc4:	0f b6 00             	movzbl (%eax),%eax
c0109dc7:	0f be c0             	movsbl %al,%eax
c0109dca:	83 e8 30             	sub    $0x30,%eax
c0109dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109dd0:	eb 48                	jmp    c0109e1a <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0109dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd5:	0f b6 00             	movzbl (%eax),%eax
c0109dd8:	3c 60                	cmp    $0x60,%al
c0109dda:	7e 1b                	jle    c0109df7 <strtol+0xf7>
c0109ddc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ddf:	0f b6 00             	movzbl (%eax),%eax
c0109de2:	3c 7a                	cmp    $0x7a,%al
c0109de4:	7f 11                	jg     c0109df7 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0109de6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109de9:	0f b6 00             	movzbl (%eax),%eax
c0109dec:	0f be c0             	movsbl %al,%eax
c0109def:	83 e8 57             	sub    $0x57,%eax
c0109df2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109df5:	eb 23                	jmp    c0109e1a <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0109df7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dfa:	0f b6 00             	movzbl (%eax),%eax
c0109dfd:	3c 40                	cmp    $0x40,%al
c0109dff:	7e 3d                	jle    c0109e3e <strtol+0x13e>
c0109e01:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e04:	0f b6 00             	movzbl (%eax),%eax
c0109e07:	3c 5a                	cmp    $0x5a,%al
c0109e09:	7f 33                	jg     c0109e3e <strtol+0x13e>
            dig = *s - 'A' + 10;
c0109e0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e0e:	0f b6 00             	movzbl (%eax),%eax
c0109e11:	0f be c0             	movsbl %al,%eax
c0109e14:	83 e8 37             	sub    $0x37,%eax
c0109e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0109e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e1d:	3b 45 10             	cmp    0x10(%ebp),%eax
c0109e20:	7c 02                	jl     c0109e24 <strtol+0x124>
            break;
c0109e22:	eb 1a                	jmp    c0109e3e <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0109e24:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109e28:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109e2b:	0f af 45 10          	imul   0x10(%ebp),%eax
c0109e2f:	89 c2                	mov    %eax,%edx
c0109e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e34:	01 d0                	add    %edx,%eax
c0109e36:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0109e39:	e9 6f ff ff ff       	jmp    c0109dad <strtol+0xad>

    if (endptr) {
c0109e3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109e42:	74 08                	je     c0109e4c <strtol+0x14c>
        *endptr = (char *) s;
c0109e44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e47:	8b 55 08             	mov    0x8(%ebp),%edx
c0109e4a:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0109e4c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109e50:	74 07                	je     c0109e59 <strtol+0x159>
c0109e52:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109e55:	f7 d8                	neg    %eax
c0109e57:	eb 03                	jmp    c0109e5c <strtol+0x15c>
c0109e59:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0109e5c:	c9                   	leave  
c0109e5d:	c3                   	ret    

c0109e5e <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0109e5e:	55                   	push   %ebp
c0109e5f:	89 e5                	mov    %esp,%ebp
c0109e61:	57                   	push   %edi
c0109e62:	83 ec 24             	sub    $0x24,%esp
c0109e65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e68:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0109e6b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0109e6f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109e72:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109e75:	88 45 f7             	mov    %al,-0x9(%ebp)
c0109e78:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0109e7e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0109e81:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0109e85:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109e88:	89 d7                	mov    %edx,%edi
c0109e8a:	f3 aa                	rep stos %al,%es:(%edi)
c0109e8c:	89 fa                	mov    %edi,%edx
c0109e8e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109e91:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0109e94:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109e97:	83 c4 24             	add    $0x24,%esp
c0109e9a:	5f                   	pop    %edi
c0109e9b:	5d                   	pop    %ebp
c0109e9c:	c3                   	ret    

c0109e9d <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0109e9d:	55                   	push   %ebp
c0109e9e:	89 e5                	mov    %esp,%ebp
c0109ea0:	57                   	push   %edi
c0109ea1:	56                   	push   %esi
c0109ea2:	53                   	push   %ebx
c0109ea3:	83 ec 30             	sub    $0x30,%esp
c0109ea6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109eac:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109eaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109eb2:	8b 45 10             	mov    0x10(%ebp),%eax
c0109eb5:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0109eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ebb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0109ebe:	73 42                	jae    c0109f02 <memmove+0x65>
c0109ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ec3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109ec6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ec9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109ecc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ecf:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109ed2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109ed5:	c1 e8 02             	shr    $0x2,%eax
c0109ed8:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0109eda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109edd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109ee0:	89 d7                	mov    %edx,%edi
c0109ee2:	89 c6                	mov    %eax,%esi
c0109ee4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109ee6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109ee9:	83 e1 03             	and    $0x3,%ecx
c0109eec:	74 02                	je     c0109ef0 <memmove+0x53>
c0109eee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109ef0:	89 f0                	mov    %esi,%eax
c0109ef2:	89 fa                	mov    %edi,%edx
c0109ef4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0109ef7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109efa:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0109efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109f00:	eb 36                	jmp    c0109f38 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0109f02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f05:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109f08:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f0b:	01 c2                	add    %eax,%edx
c0109f0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f10:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0109f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f16:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0109f19:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f1c:	89 c1                	mov    %eax,%ecx
c0109f1e:	89 d8                	mov    %ebx,%eax
c0109f20:	89 d6                	mov    %edx,%esi
c0109f22:	89 c7                	mov    %eax,%edi
c0109f24:	fd                   	std    
c0109f25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109f27:	fc                   	cld    
c0109f28:	89 f8                	mov    %edi,%eax
c0109f2a:	89 f2                	mov    %esi,%edx
c0109f2c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0109f2f:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0109f32:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0109f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0109f38:	83 c4 30             	add    $0x30,%esp
c0109f3b:	5b                   	pop    %ebx
c0109f3c:	5e                   	pop    %esi
c0109f3d:	5f                   	pop    %edi
c0109f3e:	5d                   	pop    %ebp
c0109f3f:	c3                   	ret    

c0109f40 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0109f40:	55                   	push   %ebp
c0109f41:	89 e5                	mov    %esp,%ebp
c0109f43:	57                   	push   %edi
c0109f44:	56                   	push   %esi
c0109f45:	83 ec 20             	sub    $0x20,%esp
c0109f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109f54:	8b 45 10             	mov    0x10(%ebp),%eax
c0109f57:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109f5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f5d:	c1 e8 02             	shr    $0x2,%eax
c0109f60:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0109f62:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f68:	89 d7                	mov    %edx,%edi
c0109f6a:	89 c6                	mov    %eax,%esi
c0109f6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109f6e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0109f71:	83 e1 03             	and    $0x3,%ecx
c0109f74:	74 02                	je     c0109f78 <memcpy+0x38>
c0109f76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109f78:	89 f0                	mov    %esi,%eax
c0109f7a:	89 fa                	mov    %edi,%edx
c0109f7c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109f7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109f82:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0109f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0109f88:	83 c4 20             	add    $0x20,%esp
c0109f8b:	5e                   	pop    %esi
c0109f8c:	5f                   	pop    %edi
c0109f8d:	5d                   	pop    %ebp
c0109f8e:	c3                   	ret    

c0109f8f <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0109f8f:	55                   	push   %ebp
c0109f90:	89 e5                	mov    %esp,%ebp
c0109f92:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0109f95:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f98:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0109f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f9e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0109fa1:	eb 30                	jmp    c0109fd3 <memcmp+0x44>
        if (*s1 != *s2) {
c0109fa3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109fa6:	0f b6 10             	movzbl (%eax),%edx
c0109fa9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109fac:	0f b6 00             	movzbl (%eax),%eax
c0109faf:	38 c2                	cmp    %al,%dl
c0109fb1:	74 18                	je     c0109fcb <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109fb6:	0f b6 00             	movzbl (%eax),%eax
c0109fb9:	0f b6 d0             	movzbl %al,%edx
c0109fbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109fbf:	0f b6 00             	movzbl (%eax),%eax
c0109fc2:	0f b6 c0             	movzbl %al,%eax
c0109fc5:	29 c2                	sub    %eax,%edx
c0109fc7:	89 d0                	mov    %edx,%eax
c0109fc9:	eb 1a                	jmp    c0109fe5 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0109fcb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0109fcf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0109fd3:	8b 45 10             	mov    0x10(%ebp),%eax
c0109fd6:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109fd9:	89 55 10             	mov    %edx,0x10(%ebp)
c0109fdc:	85 c0                	test   %eax,%eax
c0109fde:	75 c3                	jne    c0109fa3 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0109fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109fe5:	c9                   	leave  
c0109fe6:	c3                   	ret    
