
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 10 12 00       	mov    $0x121000,%eax
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
c0100020:	a3 00 10 12 c0       	mov    %eax,0xc0121000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 00 12 c0       	mov    $0xc0120000,%esp
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
c010003c:	ba 90 41 12 c0       	mov    $0xc0124190,%edx
c0100041:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 30 12 c0 	movl   $0xc0123000,(%esp)
c010005d:	e8 6b 8f 00 00       	call   c0108fcd <memset>

    cons_init();                // init the console
c0100062:	e8 9b 15 00 00       	call   c0101602 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 60 91 10 c0 	movl   $0xc0109160,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 7c 91 10 c0 	movl   $0xc010917c,(%esp)
c010007c:	e8 d6 02 00 00       	call   c0100357 <cprintf>

    print_kerninfo();
c0100081:	e8 05 08 00 00       	call   c010088b <print_kerninfo>

    grade_backtrace();
c0100086:	e8 95 00 00 00       	call   c0100120 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 0a 4e 00 00       	call   c0104e9a <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 4b 1f 00 00       	call   c0101fe0 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 9d 20 00 00       	call   c0102137 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 77 79 00 00       	call   c0107a16 <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 8f 16 00 00       	call   c0101733 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 5e 61 00 00       	call   c0106207 <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 0a 0d 00 00       	call   c0100db8 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 9b 1e 00 00       	call   c0101f4e <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	55                   	push   %ebp
c01000b6:	89 e5                	mov    %esp,%ebp
c01000b8:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c2:	00 
c01000c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ca:	00 
c01000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d2:	e8 02 0c 00 00       	call   c0100cd9 <mon_backtrace>
}
c01000d7:	c9                   	leave  
c01000d8:	c3                   	ret    

c01000d9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d9:	55                   	push   %ebp
c01000da:	89 e5                	mov    %esp,%ebp
c01000dc:	53                   	push   %ebx
c01000dd:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e0:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e6:	8d 55 08             	lea    0x8(%ebp),%edx
c01000e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f8:	89 04 24             	mov    %eax,(%esp)
c01000fb:	e8 b5 ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100100:	83 c4 14             	add    $0x14,%esp
c0100103:	5b                   	pop    %ebx
c0100104:	5d                   	pop    %ebp
c0100105:	c3                   	ret    

c0100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100106:	55                   	push   %ebp
c0100107:	89 e5                	mov    %esp,%ebp
c0100109:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010c:	8b 45 10             	mov    0x10(%ebp),%eax
c010010f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100113:	8b 45 08             	mov    0x8(%ebp),%eax
c0100116:	89 04 24             	mov    %eax,(%esp)
c0100119:	e8 bb ff ff ff       	call   c01000d9 <grade_backtrace1>
}
c010011e:	c9                   	leave  
c010011f:	c3                   	ret    

c0100120 <grade_backtrace>:

void
grade_backtrace(void) {
c0100120:	55                   	push   %ebp
c0100121:	89 e5                	mov    %esp,%ebp
c0100123:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100126:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012b:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100132:	ff 
c0100133:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013e:	e8 c3 ff ff ff       	call   c0100106 <grade_backtrace0>
}
c0100143:	c9                   	leave  
c0100144:	c3                   	ret    

c0100145 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100145:	55                   	push   %ebp
c0100146:	89 e5                	mov    %esp,%ebp
c0100148:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100151:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100154:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100157:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015b:	0f b7 c0             	movzwl %ax,%eax
c010015e:	83 e0 03             	and    $0x3,%eax
c0100161:	89 c2                	mov    %eax,%edx
c0100163:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100168:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100170:	c7 04 24 81 91 10 c0 	movl   $0xc0109181,(%esp)
c0100177:	e8 db 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100180:	0f b7 d0             	movzwl %ax,%edx
c0100183:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100188:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100190:	c7 04 24 8f 91 10 c0 	movl   $0xc010918f,(%esp)
c0100197:	e8 bb 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a0:	0f b7 d0             	movzwl %ax,%edx
c01001a3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001a8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b0:	c7 04 24 9d 91 10 c0 	movl   $0xc010919d,(%esp)
c01001b7:	e8 9b 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c0:	0f b7 d0             	movzwl %ax,%edx
c01001c3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001c8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d0:	c7 04 24 ab 91 10 c0 	movl   $0xc01091ab,(%esp)
c01001d7:	e8 7b 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001dc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e0:	0f b7 d0             	movzwl %ax,%edx
c01001e3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001e8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f0:	c7 04 24 b9 91 10 c0 	movl   $0xc01091b9,(%esp)
c01001f7:	e8 5b 01 00 00       	call   c0100357 <cprintf>
    round ++;
c01001fc:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100201:	83 c0 01             	add    $0x1,%eax
c0100204:	a3 00 30 12 c0       	mov    %eax,0xc0123000
}
c0100209:	c9                   	leave  
c010020a:	c3                   	ret    

c010020b <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020e:	5d                   	pop    %ebp
c010020f:	c3                   	ret    

c0100210 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100210:	55                   	push   %ebp
c0100211:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100213:	5d                   	pop    %ebp
c0100214:	c3                   	ret    

c0100215 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
c0100218:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021b:	e8 25 ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100220:	c7 04 24 c8 91 10 c0 	movl   $0xc01091c8,(%esp)
c0100227:	e8 2b 01 00 00       	call   c0100357 <cprintf>
    lab1_switch_to_user();
c010022c:	e8 da ff ff ff       	call   c010020b <lab1_switch_to_user>
    lab1_print_cur_status();
c0100231:	e8 0f ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100236:	c7 04 24 e8 91 10 c0 	movl   $0xc01091e8,(%esp)
c010023d:	e8 15 01 00 00       	call   c0100357 <cprintf>
    lab1_switch_to_kernel();
c0100242:	e8 c9 ff ff ff       	call   c0100210 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100247:	e8 f9 fe ff ff       	call   c0100145 <lab1_print_cur_status>
}
c010024c:	c9                   	leave  
c010024d:	c3                   	ret    

c010024e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024e:	55                   	push   %ebp
c010024f:	89 e5                	mov    %esp,%ebp
c0100251:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100254:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100258:	74 13                	je     c010026d <readline+0x1f>
        cprintf("%s", prompt);
c010025a:	8b 45 08             	mov    0x8(%ebp),%eax
c010025d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100261:	c7 04 24 07 92 10 c0 	movl   $0xc0109207,(%esp)
c0100268:	e8 ea 00 00 00       	call   c0100357 <cprintf>
    }
    int i = 0, c;
c010026d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100274:	e8 66 01 00 00       	call   c01003df <getchar>
c0100279:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010027c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100280:	79 07                	jns    c0100289 <readline+0x3b>
            return NULL;
c0100282:	b8 00 00 00 00       	mov    $0x0,%eax
c0100287:	eb 79                	jmp    c0100302 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100289:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010028d:	7e 28                	jle    c01002b7 <readline+0x69>
c010028f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100296:	7f 1f                	jg     c01002b7 <readline+0x69>
            cputchar(c);
c0100298:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010029b:	89 04 24             	mov    %eax,(%esp)
c010029e:	e8 da 00 00 00       	call   c010037d <cputchar>
            buf[i ++] = c;
c01002a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a6:	8d 50 01             	lea    0x1(%eax),%edx
c01002a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002af:	88 90 20 30 12 c0    	mov    %dl,-0x3fedcfe0(%eax)
c01002b5:	eb 46                	jmp    c01002fd <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002bb:	75 17                	jne    c01002d4 <readline+0x86>
c01002bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c1:	7e 11                	jle    c01002d4 <readline+0x86>
            cputchar(c);
c01002c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c6:	89 04 24             	mov    %eax,(%esp)
c01002c9:	e8 af 00 00 00       	call   c010037d <cputchar>
            i --;
c01002ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002d2:	eb 29                	jmp    c01002fd <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d8:	74 06                	je     c01002e0 <readline+0x92>
c01002da:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002de:	75 1d                	jne    c01002fd <readline+0xaf>
            cputchar(c);
c01002e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e3:	89 04 24             	mov    %eax,(%esp)
c01002e6:	e8 92 00 00 00       	call   c010037d <cputchar>
            buf[i] = '\0';
c01002eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ee:	05 20 30 12 c0       	add    $0xc0123020,%eax
c01002f3:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f6:	b8 20 30 12 c0       	mov    $0xc0123020,%eax
c01002fb:	eb 05                	jmp    c0100302 <readline+0xb4>
        }
    }
c01002fd:	e9 72 ff ff ff       	jmp    c0100274 <readline+0x26>
}
c0100302:	c9                   	leave  
c0100303:	c3                   	ret    

c0100304 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100304:	55                   	push   %ebp
c0100305:	89 e5                	mov    %esp,%ebp
c0100307:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010030a:	8b 45 08             	mov    0x8(%ebp),%eax
c010030d:	89 04 24             	mov    %eax,(%esp)
c0100310:	e8 19 13 00 00       	call   c010162e <cons_putc>
    (*cnt) ++;
c0100315:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100318:	8b 00                	mov    (%eax),%eax
c010031a:	8d 50 01             	lea    0x1(%eax),%edx
c010031d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100320:	89 10                	mov    %edx,(%eax)
}
c0100322:	c9                   	leave  
c0100323:	c3                   	ret    

c0100324 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100324:	55                   	push   %ebp
c0100325:	89 e5                	mov    %esp,%ebp
c0100327:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010032a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100331:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100334:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100338:	8b 45 08             	mov    0x8(%ebp),%eax
c010033b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033f:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100342:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100346:	c7 04 24 04 03 10 c0 	movl   $0xc0100304,(%esp)
c010034d:	e8 bc 83 00 00       	call   c010870e <vprintfmt>
    return cnt;
c0100352:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100355:	c9                   	leave  
c0100356:	c3                   	ret    

c0100357 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100357:	55                   	push   %ebp
c0100358:	89 e5                	mov    %esp,%ebp
c010035a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035d:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100360:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100363:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100366:	89 44 24 04          	mov    %eax,0x4(%esp)
c010036a:	8b 45 08             	mov    0x8(%ebp),%eax
c010036d:	89 04 24             	mov    %eax,(%esp)
c0100370:	e8 af ff ff ff       	call   c0100324 <vcprintf>
c0100375:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100378:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037b:	c9                   	leave  
c010037c:	c3                   	ret    

c010037d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037d:	55                   	push   %ebp
c010037e:	89 e5                	mov    %esp,%ebp
c0100380:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100383:	8b 45 08             	mov    0x8(%ebp),%eax
c0100386:	89 04 24             	mov    %eax,(%esp)
c0100389:	e8 a0 12 00 00       	call   c010162e <cons_putc>
}
c010038e:	c9                   	leave  
c010038f:	c3                   	ret    

c0100390 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100390:	55                   	push   %ebp
c0100391:	89 e5                	mov    %esp,%ebp
c0100393:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100396:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010039d:	eb 13                	jmp    c01003b2 <cputs+0x22>
        cputch(c, &cnt);
c010039f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a3:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003aa:	89 04 24             	mov    %eax,(%esp)
c01003ad:	e8 52 ff ff ff       	call   c0100304 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b5:	8d 50 01             	lea    0x1(%eax),%edx
c01003b8:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bb:	0f b6 00             	movzbl (%eax),%eax
c01003be:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c5:	75 d8                	jne    c010039f <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ce:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d5:	e8 2a ff ff ff       	call   c0100304 <cputch>
    return cnt;
c01003da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003dd:	c9                   	leave  
c01003de:	c3                   	ret    

c01003df <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003df:	55                   	push   %ebp
c01003e0:	89 e5                	mov    %esp,%ebp
c01003e2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e5:	e8 80 12 00 00       	call   c010166a <cons_getc>
c01003ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f1:	74 f2                	je     c01003e5 <getchar+0x6>
        /* do nothing */;
    return c;
c01003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f6:	c9                   	leave  
c01003f7:	c3                   	ret    

c01003f8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f8:	55                   	push   %ebp
c01003f9:	89 e5                	mov    %esp,%ebp
c01003fb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100401:	8b 00                	mov    (%eax),%eax
c0100403:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100406:	8b 45 10             	mov    0x10(%ebp),%eax
c0100409:	8b 00                	mov    (%eax),%eax
c010040b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100415:	e9 d2 00 00 00       	jmp    c01004ec <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010041a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010041d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100420:	01 d0                	add    %edx,%eax
c0100422:	89 c2                	mov    %eax,%edx
c0100424:	c1 ea 1f             	shr    $0x1f,%edx
c0100427:	01 d0                	add    %edx,%eax
c0100429:	d1 f8                	sar    %eax
c010042b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100431:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100434:	eb 04                	jmp    c010043a <stab_binsearch+0x42>
            m --;
c0100436:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010043d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100440:	7c 1f                	jl     c0100461 <stab_binsearch+0x69>
c0100442:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100445:	89 d0                	mov    %edx,%eax
c0100447:	01 c0                	add    %eax,%eax
c0100449:	01 d0                	add    %edx,%eax
c010044b:	c1 e0 02             	shl    $0x2,%eax
c010044e:	89 c2                	mov    %eax,%edx
c0100450:	8b 45 08             	mov    0x8(%ebp),%eax
c0100453:	01 d0                	add    %edx,%eax
c0100455:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100459:	0f b6 c0             	movzbl %al,%eax
c010045c:	3b 45 14             	cmp    0x14(%ebp),%eax
c010045f:	75 d5                	jne    c0100436 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100461:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100464:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100467:	7d 0b                	jge    c0100474 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100469:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010046c:	83 c0 01             	add    $0x1,%eax
c010046f:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100472:	eb 78                	jmp    c01004ec <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100474:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010047b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047e:	89 d0                	mov    %edx,%eax
c0100480:	01 c0                	add    %eax,%eax
c0100482:	01 d0                	add    %edx,%eax
c0100484:	c1 e0 02             	shl    $0x2,%eax
c0100487:	89 c2                	mov    %eax,%edx
c0100489:	8b 45 08             	mov    0x8(%ebp),%eax
c010048c:	01 d0                	add    %edx,%eax
c010048e:	8b 40 08             	mov    0x8(%eax),%eax
c0100491:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100494:	73 13                	jae    c01004a9 <stab_binsearch+0xb1>
            *region_left = m;
c0100496:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100499:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049c:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a1:	83 c0 01             	add    $0x1,%eax
c01004a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a7:	eb 43                	jmp    c01004ec <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004ac:	89 d0                	mov    %edx,%eax
c01004ae:	01 c0                	add    %eax,%eax
c01004b0:	01 d0                	add    %edx,%eax
c01004b2:	c1 e0 02             	shl    $0x2,%eax
c01004b5:	89 c2                	mov    %eax,%edx
c01004b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ba:	01 d0                	add    %edx,%eax
c01004bc:	8b 40 08             	mov    0x8(%eax),%eax
c01004bf:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004c2:	76 16                	jbe    c01004da <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01004cd:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d2:	83 e8 01             	sub    $0x1,%eax
c01004d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d8:	eb 12                	jmp    c01004ec <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e0:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e8:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004ef:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f2:	0f 8e 22 ff ff ff    	jle    c010041a <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fc:	75 0f                	jne    c010050d <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100506:	8b 45 10             	mov    0x10(%ebp),%eax
c0100509:	89 10                	mov    %edx,(%eax)
c010050b:	eb 3f                	jmp    c010054c <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010050d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100510:	8b 00                	mov    (%eax),%eax
c0100512:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100515:	eb 04                	jmp    c010051b <stab_binsearch+0x123>
c0100517:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100523:	7d 1f                	jge    c0100544 <stab_binsearch+0x14c>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100542:	75 d3                	jne    c0100517 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
    }
}
c010054c:	c9                   	leave  
c010054d:	c3                   	ret    

c010054e <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054e:	55                   	push   %ebp
c010054f:	89 e5                	mov    %esp,%ebp
c0100551:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100554:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100557:	c7 00 0c 92 10 c0    	movl   $0xc010920c,(%eax)
    info->eip_line = 0;
c010055d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100560:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100567:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056a:	c7 40 08 0c 92 10 c0 	movl   $0xc010920c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100571:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100574:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057e:	8b 55 08             	mov    0x8(%ebp),%edx
c0100581:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100584:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100587:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010058e:	c7 45 f4 40 b1 10 c0 	movl   $0xc010b140,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100595:	c7 45 f0 d4 a3 11 c0 	movl   $0xc011a3d4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059c:	c7 45 ec d5 a3 11 c0 	movl   $0xc011a3d5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a3:	c7 45 e8 8f dc 11 c0 	movl   $0xc011dc8f,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005ad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b0:	76 0d                	jbe    c01005bf <debuginfo_eip+0x71>
c01005b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b5:	83 e8 01             	sub    $0x1,%eax
c01005b8:	0f b6 00             	movzbl (%eax),%eax
c01005bb:	84 c0                	test   %al,%al
c01005bd:	74 0a                	je     c01005c9 <debuginfo_eip+0x7b>
        return -1;
c01005bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c4:	e9 c0 02 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d6:	29 c2                	sub    %eax,%edx
c01005d8:	89 d0                	mov    %edx,%eax
c01005da:	c1 f8 02             	sar    $0x2,%eax
c01005dd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e3:	83 e8 01             	sub    $0x1,%eax
c01005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ec:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005f0:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f7:	00 
c01005f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100602:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100609:	89 04 24             	mov    %eax,(%esp)
c010060c:	e8 e7 fd ff ff       	call   c01003f8 <stab_binsearch>
    if (lfile == 0)
c0100611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100614:	85 c0                	test   %eax,%eax
c0100616:	75 0a                	jne    c0100622 <debuginfo_eip+0xd4>
        return -1;
c0100618:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010061d:	e9 67 02 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100625:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100628:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010062e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100631:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100635:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010063c:	00 
c010063d:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100640:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100644:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100647:	89 44 24 04          	mov    %eax,0x4(%esp)
c010064b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064e:	89 04 24             	mov    %eax,(%esp)
c0100651:	e8 a2 fd ff ff       	call   c01003f8 <stab_binsearch>

    if (lfun <= rfun) {
c0100656:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100659:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010065c:	39 c2                	cmp    %eax,%edx
c010065e:	7f 7c                	jg     c01006dc <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100660:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100663:	89 c2                	mov    %eax,%edx
c0100665:	89 d0                	mov    %edx,%eax
c0100667:	01 c0                	add    %eax,%eax
c0100669:	01 d0                	add    %edx,%eax
c010066b:	c1 e0 02             	shl    $0x2,%eax
c010066e:	89 c2                	mov    %eax,%edx
c0100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100673:	01 d0                	add    %edx,%eax
c0100675:	8b 10                	mov    (%eax),%edx
c0100677:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010067a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010067d:	29 c1                	sub    %eax,%ecx
c010067f:	89 c8                	mov    %ecx,%eax
c0100681:	39 c2                	cmp    %eax,%edx
c0100683:	73 22                	jae    c01006a7 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100685:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100688:	89 c2                	mov    %eax,%edx
c010068a:	89 d0                	mov    %edx,%eax
c010068c:	01 c0                	add    %eax,%eax
c010068e:	01 d0                	add    %edx,%eax
c0100690:	c1 e0 02             	shl    $0x2,%eax
c0100693:	89 c2                	mov    %eax,%edx
c0100695:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100698:	01 d0                	add    %edx,%eax
c010069a:	8b 10                	mov    (%eax),%edx
c010069c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010069f:	01 c2                	add    %eax,%edx
c01006a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a4:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006aa:	89 c2                	mov    %eax,%edx
c01006ac:	89 d0                	mov    %edx,%eax
c01006ae:	01 c0                	add    %eax,%eax
c01006b0:	01 d0                	add    %edx,%eax
c01006b2:	c1 e0 02             	shl    $0x2,%eax
c01006b5:	89 c2                	mov    %eax,%edx
c01006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ba:	01 d0                	add    %edx,%eax
c01006bc:	8b 50 08             	mov    0x8(%eax),%edx
c01006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c2:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c8:	8b 40 10             	mov    0x10(%eax),%eax
c01006cb:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006da:	eb 15                	jmp    c01006f1 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006df:	8b 55 08             	mov    0x8(%ebp),%edx
c01006e2:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f4:	8b 40 08             	mov    0x8(%eax),%eax
c01006f7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006fe:	00 
c01006ff:	89 04 24             	mov    %eax,(%esp)
c0100702:	e8 3a 87 00 00       	call   c0108e41 <strfind>
c0100707:	89 c2                	mov    %eax,%edx
c0100709:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070c:	8b 40 08             	mov    0x8(%eax),%eax
c010070f:	29 c2                	sub    %eax,%edx
c0100711:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100714:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100717:	8b 45 08             	mov    0x8(%ebp),%eax
c010071a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010071e:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100725:	00 
c0100726:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100729:	89 44 24 08          	mov    %eax,0x8(%esp)
c010072d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100730:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100734:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100737:	89 04 24             	mov    %eax,(%esp)
c010073a:	e8 b9 fc ff ff       	call   c01003f8 <stab_binsearch>
    if (lline <= rline) {
c010073f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100742:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100745:	39 c2                	cmp    %eax,%edx
c0100747:	7f 24                	jg     c010076d <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100749:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010074c:	89 c2                	mov    %eax,%edx
c010074e:	89 d0                	mov    %edx,%eax
c0100750:	01 c0                	add    %eax,%eax
c0100752:	01 d0                	add    %edx,%eax
c0100754:	c1 e0 02             	shl    $0x2,%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	01 d0                	add    %edx,%eax
c010075e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100762:	0f b7 d0             	movzwl %ax,%edx
c0100765:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100768:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010076b:	eb 13                	jmp    c0100780 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010076d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100772:	e9 12 01 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100777:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077a:	83 e8 01             	sub    $0x1,%eax
c010077d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100780:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100783:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100786:	39 c2                	cmp    %eax,%edx
c0100788:	7c 56                	jl     c01007e0 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010078a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010078d:	89 c2                	mov    %eax,%edx
c010078f:	89 d0                	mov    %edx,%eax
c0100791:	01 c0                	add    %eax,%eax
c0100793:	01 d0                	add    %edx,%eax
c0100795:	c1 e0 02             	shl    $0x2,%eax
c0100798:	89 c2                	mov    %eax,%edx
c010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079d:	01 d0                	add    %edx,%eax
c010079f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007a3:	3c 84                	cmp    $0x84,%al
c01007a5:	74 39                	je     c01007e0 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007aa:	89 c2                	mov    %eax,%edx
c01007ac:	89 d0                	mov    %edx,%eax
c01007ae:	01 c0                	add    %eax,%eax
c01007b0:	01 d0                	add    %edx,%eax
c01007b2:	c1 e0 02             	shl    $0x2,%eax
c01007b5:	89 c2                	mov    %eax,%edx
c01007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ba:	01 d0                	add    %edx,%eax
c01007bc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007c0:	3c 64                	cmp    $0x64,%al
c01007c2:	75 b3                	jne    c0100777 <debuginfo_eip+0x229>
c01007c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c7:	89 c2                	mov    %eax,%edx
c01007c9:	89 d0                	mov    %edx,%eax
c01007cb:	01 c0                	add    %eax,%eax
c01007cd:	01 d0                	add    %edx,%eax
c01007cf:	c1 e0 02             	shl    $0x2,%eax
c01007d2:	89 c2                	mov    %eax,%edx
c01007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d7:	01 d0                	add    %edx,%eax
c01007d9:	8b 40 08             	mov    0x8(%eax),%eax
c01007dc:	85 c0                	test   %eax,%eax
c01007de:	74 97                	je     c0100777 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e6:	39 c2                	cmp    %eax,%edx
c01007e8:	7c 46                	jl     c0100830 <debuginfo_eip+0x2e2>
c01007ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ed:	89 c2                	mov    %eax,%edx
c01007ef:	89 d0                	mov    %edx,%eax
c01007f1:	01 c0                	add    %eax,%eax
c01007f3:	01 d0                	add    %edx,%eax
c01007f5:	c1 e0 02             	shl    $0x2,%eax
c01007f8:	89 c2                	mov    %eax,%edx
c01007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fd:	01 d0                	add    %edx,%eax
c01007ff:	8b 10                	mov    (%eax),%edx
c0100801:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100804:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100807:	29 c1                	sub    %eax,%ecx
c0100809:	89 c8                	mov    %ecx,%eax
c010080b:	39 c2                	cmp    %eax,%edx
c010080d:	73 21                	jae    c0100830 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010080f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100812:	89 c2                	mov    %eax,%edx
c0100814:	89 d0                	mov    %edx,%eax
c0100816:	01 c0                	add    %eax,%eax
c0100818:	01 d0                	add    %edx,%eax
c010081a:	c1 e0 02             	shl    $0x2,%eax
c010081d:	89 c2                	mov    %eax,%edx
c010081f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100822:	01 d0                	add    %edx,%eax
c0100824:	8b 10                	mov    (%eax),%edx
c0100826:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100829:	01 c2                	add    %eax,%edx
c010082b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100830:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100833:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100836:	39 c2                	cmp    %eax,%edx
c0100838:	7d 4a                	jge    c0100884 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010083a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010083d:	83 c0 01             	add    $0x1,%eax
c0100840:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100843:	eb 18                	jmp    c010085d <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100845:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100848:	8b 40 14             	mov    0x14(%eax),%eax
c010084b:	8d 50 01             	lea    0x1(%eax),%edx
c010084e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100851:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100857:	83 c0 01             	add    $0x1,%eax
c010085a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010085d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100860:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100863:	39 c2                	cmp    %eax,%edx
c0100865:	7d 1d                	jge    c0100884 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100867:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086a:	89 c2                	mov    %eax,%edx
c010086c:	89 d0                	mov    %edx,%eax
c010086e:	01 c0                	add    %eax,%eax
c0100870:	01 d0                	add    %edx,%eax
c0100872:	c1 e0 02             	shl    $0x2,%eax
c0100875:	89 c2                	mov    %eax,%edx
c0100877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087a:	01 d0                	add    %edx,%eax
c010087c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100880:	3c a0                	cmp    $0xa0,%al
c0100882:	74 c1                	je     c0100845 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100884:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100889:	c9                   	leave  
c010088a:	c3                   	ret    

c010088b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010088b:	55                   	push   %ebp
c010088c:	89 e5                	mov    %esp,%ebp
c010088e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100891:	c7 04 24 16 92 10 c0 	movl   $0xc0109216,(%esp)
c0100898:	e8 ba fa ff ff       	call   c0100357 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010089d:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a4:	c0 
c01008a5:	c7 04 24 2f 92 10 c0 	movl   $0xc010922f,(%esp)
c01008ac:	e8 a6 fa ff ff       	call   c0100357 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008b1:	c7 44 24 04 56 91 10 	movl   $0xc0109156,0x4(%esp)
c01008b8:	c0 
c01008b9:	c7 04 24 47 92 10 c0 	movl   $0xc0109247,(%esp)
c01008c0:	e8 92 fa ff ff       	call   c0100357 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c5:	c7 44 24 04 00 30 12 	movl   $0xc0123000,0x4(%esp)
c01008cc:	c0 
c01008cd:	c7 04 24 5f 92 10 c0 	movl   $0xc010925f,(%esp)
c01008d4:	e8 7e fa ff ff       	call   c0100357 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d9:	c7 44 24 04 90 41 12 	movl   $0xc0124190,0x4(%esp)
c01008e0:	c0 
c01008e1:	c7 04 24 77 92 10 c0 	movl   $0xc0109277,(%esp)
c01008e8:	e8 6a fa ff ff       	call   c0100357 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008ed:	b8 90 41 12 c0       	mov    $0xc0124190,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008fd:	29 c2                	sub    %eax,%edx
c01008ff:	89 d0                	mov    %edx,%eax
c0100901:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100907:	85 c0                	test   %eax,%eax
c0100909:	0f 48 c2             	cmovs  %edx,%eax
c010090c:	c1 f8 0a             	sar    $0xa,%eax
c010090f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100913:	c7 04 24 90 92 10 c0 	movl   $0xc0109290,(%esp)
c010091a:	e8 38 fa ff ff       	call   c0100357 <cprintf>
}
c010091f:	c9                   	leave  
c0100920:	c3                   	ret    

c0100921 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100921:	55                   	push   %ebp
c0100922:	89 e5                	mov    %esp,%ebp
c0100924:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010092a:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010092d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 04 24             	mov    %eax,(%esp)
c0100937:	e8 12 fc ff ff       	call   c010054e <debuginfo_eip>
c010093c:	85 c0                	test   %eax,%eax
c010093e:	74 15                	je     c0100955 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100940:	8b 45 08             	mov    0x8(%ebp),%eax
c0100943:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100947:	c7 04 24 ba 92 10 c0 	movl   $0xc01092ba,(%esp)
c010094e:	e8 04 fa ff ff       	call   c0100357 <cprintf>
c0100953:	eb 6d                	jmp    c01009c2 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010095c:	eb 1c                	jmp    c010097a <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010095e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100964:	01 d0                	add    %edx,%eax
c0100966:	0f b6 00             	movzbl (%eax),%eax
c0100969:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010096f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100972:	01 ca                	add    %ecx,%edx
c0100974:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100976:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010097a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010097d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100980:	7f dc                	jg     c010095e <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100982:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100988:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010098b:	01 d0                	add    %edx,%eax
c010098d:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100990:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100993:	8b 55 08             	mov    0x8(%ebp),%edx
c0100996:	89 d1                	mov    %edx,%ecx
c0100998:	29 c1                	sub    %eax,%ecx
c010099a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009a0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009a4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009aa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009ae:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b6:	c7 04 24 d6 92 10 c0 	movl   $0xc01092d6,(%esp)
c01009bd:	e8 95 f9 ff ff       	call   c0100357 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009c2:	c9                   	leave  
c01009c3:	c3                   	ret    

c01009c4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c4:	55                   	push   %ebp
c01009c5:	89 e5                	mov    %esp,%ebp
c01009c7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009ca:	8b 45 04             	mov    0x4(%ebp),%eax
c01009cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009d3:	c9                   	leave  
c01009d4:	c3                   	ret    

c01009d5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d5:	55                   	push   %ebp
c01009d6:	89 e5                	mov    %esp,%ebp
c01009d8:	53                   	push   %ebx
c01009d9:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009dc:	89 e8                	mov    %ebp,%eax
c01009de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c01009e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
c01009e7:	e8 d8 ff ff ff       	call   c01009c4 <read_eip>
c01009ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c01009ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009f6:	e9 8d 00 00 00       	jmp    c0100a88 <print_stackframe+0xb3>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c01009fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009fe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a09:	c7 04 24 e8 92 10 c0 	movl   $0xc01092e8,(%esp)
c0100a10:	e8 42 f9 ff ff       	call   c0100357 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
c0100a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a18:	83 c0 08             	add    $0x8,%eax
c0100a1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("0x%08x 0x%08x 0x%08x 0x%08x",*args,*(args+1),*(args+2),*(args+3));
c0100a1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a21:	83 c0 0c             	add    $0xc,%eax
c0100a24:	8b 18                	mov    (%eax),%ebx
c0100a26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a29:	83 c0 08             	add    $0x8,%eax
c0100a2c:	8b 08                	mov    (%eax),%ecx
c0100a2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a31:	83 c0 04             	add    $0x4,%eax
c0100a34:	8b 10                	mov    (%eax),%edx
c0100a36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a39:	8b 00                	mov    (%eax),%eax
c0100a3b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100a3f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a43:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a4b:	c7 04 24 04 93 10 c0 	movl   $0xc0109304,(%esp)
c0100a52:	e8 00 f9 ff ff       	call   c0100357 <cprintf>
		cprintf("\n");
c0100a57:	c7 04 24 20 93 10 c0 	movl   $0xc0109320,(%esp)
c0100a5e:	e8 f4 f8 ff ff       	call   c0100357 <cprintf>
		print_debuginfo(eip-1);
c0100a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a66:	83 e8 01             	sub    $0x1,%eax
c0100a69:	89 04 24             	mov    %eax,(%esp)
c0100a6c:	e8 b0 fe ff ff       	call   c0100921 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a74:	83 c0 04             	add    $0x4,%eax
c0100a77:	8b 00                	mov    (%eax),%eax
c0100a79:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
c0100a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a7f:	8b 00                	mov    (%eax),%eax
c0100a81:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100a84:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a8c:	74 0a                	je     c0100a98 <print_stackframe+0xc3>
c0100a8e:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a92:	0f 8e 63 ff ff ff    	jle    c01009fb <print_stackframe+0x26>
		cprintf("\n");
		print_debuginfo(eip-1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
c0100a98:	83 c4 44             	add    $0x44,%esp
c0100a9b:	5b                   	pop    %ebx
c0100a9c:	5d                   	pop    %ebp
c0100a9d:	c3                   	ret    

c0100a9e <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a9e:	55                   	push   %ebp
c0100a9f:	89 e5                	mov    %esp,%ebp
c0100aa1:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100aa4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aab:	eb 0c                	jmp    c0100ab9 <parse+0x1b>
            *buf ++ = '\0';
c0100aad:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab0:	8d 50 01             	lea    0x1(%eax),%edx
c0100ab3:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ab6:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100abc:	0f b6 00             	movzbl (%eax),%eax
c0100abf:	84 c0                	test   %al,%al
c0100ac1:	74 1d                	je     c0100ae0 <parse+0x42>
c0100ac3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac6:	0f b6 00             	movzbl (%eax),%eax
c0100ac9:	0f be c0             	movsbl %al,%eax
c0100acc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad0:	c7 04 24 a4 93 10 c0 	movl   $0xc01093a4,(%esp)
c0100ad7:	e8 32 83 00 00       	call   c0108e0e <strchr>
c0100adc:	85 c0                	test   %eax,%eax
c0100ade:	75 cd                	jne    c0100aad <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ae0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ae3:	0f b6 00             	movzbl (%eax),%eax
c0100ae6:	84 c0                	test   %al,%al
c0100ae8:	75 02                	jne    c0100aec <parse+0x4e>
            break;
c0100aea:	eb 67                	jmp    c0100b53 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100aec:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100af0:	75 14                	jne    c0100b06 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100af2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100af9:	00 
c0100afa:	c7 04 24 a9 93 10 c0 	movl   $0xc01093a9,(%esp)
c0100b01:	e8 51 f8 ff ff       	call   c0100357 <cprintf>
        }
        argv[argc ++] = buf;
c0100b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b09:	8d 50 01             	lea    0x1(%eax),%edx
c0100b0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b19:	01 c2                	add    %eax,%edx
c0100b1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1e:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b20:	eb 04                	jmp    c0100b26 <parse+0x88>
            buf ++;
c0100b22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b26:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b29:	0f b6 00             	movzbl (%eax),%eax
c0100b2c:	84 c0                	test   %al,%al
c0100b2e:	74 1d                	je     c0100b4d <parse+0xaf>
c0100b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b33:	0f b6 00             	movzbl (%eax),%eax
c0100b36:	0f be c0             	movsbl %al,%eax
c0100b39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b3d:	c7 04 24 a4 93 10 c0 	movl   $0xc01093a4,(%esp)
c0100b44:	e8 c5 82 00 00       	call   c0108e0e <strchr>
c0100b49:	85 c0                	test   %eax,%eax
c0100b4b:	74 d5                	je     c0100b22 <parse+0x84>
            buf ++;
        }
    }
c0100b4d:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4e:	e9 66 ff ff ff       	jmp    c0100ab9 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b56:	c9                   	leave  
c0100b57:	c3                   	ret    

c0100b58 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b58:	55                   	push   %ebp
c0100b59:	89 e5                	mov    %esp,%ebp
c0100b5b:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b5e:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b65:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b68:	89 04 24             	mov    %eax,(%esp)
c0100b6b:	e8 2e ff ff ff       	call   c0100a9e <parse>
c0100b70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b77:	75 0a                	jne    c0100b83 <runcmd+0x2b>
        return 0;
c0100b79:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b7e:	e9 85 00 00 00       	jmp    c0100c08 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b8a:	eb 5c                	jmp    c0100be8 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b8c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b92:	89 d0                	mov    %edx,%eax
c0100b94:	01 c0                	add    %eax,%eax
c0100b96:	01 d0                	add    %edx,%eax
c0100b98:	c1 e0 02             	shl    $0x2,%eax
c0100b9b:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100ba0:	8b 00                	mov    (%eax),%eax
c0100ba2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ba6:	89 04 24             	mov    %eax,(%esp)
c0100ba9:	e8 c1 81 00 00       	call   c0108d6f <strcmp>
c0100bae:	85 c0                	test   %eax,%eax
c0100bb0:	75 32                	jne    c0100be4 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bb5:	89 d0                	mov    %edx,%eax
c0100bb7:	01 c0                	add    %eax,%eax
c0100bb9:	01 d0                	add    %edx,%eax
c0100bbb:	c1 e0 02             	shl    $0x2,%eax
c0100bbe:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100bc3:	8b 40 08             	mov    0x8(%eax),%eax
c0100bc6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bc9:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bcf:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bd3:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bd6:	83 c2 04             	add    $0x4,%edx
c0100bd9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bdd:	89 0c 24             	mov    %ecx,(%esp)
c0100be0:	ff d0                	call   *%eax
c0100be2:	eb 24                	jmp    c0100c08 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100be4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100beb:	83 f8 02             	cmp    $0x2,%eax
c0100bee:	76 9c                	jbe    c0100b8c <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bf0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf7:	c7 04 24 c7 93 10 c0 	movl   $0xc01093c7,(%esp)
c0100bfe:	e8 54 f7 ff ff       	call   c0100357 <cprintf>
    return 0;
c0100c03:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c08:	c9                   	leave  
c0100c09:	c3                   	ret    

c0100c0a <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c0a:	55                   	push   %ebp
c0100c0b:	89 e5                	mov    %esp,%ebp
c0100c0d:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c10:	c7 04 24 e0 93 10 c0 	movl   $0xc01093e0,(%esp)
c0100c17:	e8 3b f7 ff ff       	call   c0100357 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c1c:	c7 04 24 08 94 10 c0 	movl   $0xc0109408,(%esp)
c0100c23:	e8 2f f7 ff ff       	call   c0100357 <cprintf>

    if (tf != NULL) {
c0100c28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c2c:	74 0b                	je     c0100c39 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c31:	89 04 24             	mov    %eax,(%esp)
c0100c34:	e8 b3 16 00 00       	call   c01022ec <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c39:	c7 04 24 2d 94 10 c0 	movl   $0xc010942d,(%esp)
c0100c40:	e8 09 f6 ff ff       	call   c010024e <readline>
c0100c45:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c4c:	74 18                	je     c0100c66 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c58:	89 04 24             	mov    %eax,(%esp)
c0100c5b:	e8 f8 fe ff ff       	call   c0100b58 <runcmd>
c0100c60:	85 c0                	test   %eax,%eax
c0100c62:	79 02                	jns    c0100c66 <kmonitor+0x5c>
                break;
c0100c64:	eb 02                	jmp    c0100c68 <kmonitor+0x5e>
            }
        }
    }
c0100c66:	eb d1                	jmp    c0100c39 <kmonitor+0x2f>
}
c0100c68:	c9                   	leave  
c0100c69:	c3                   	ret    

c0100c6a <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c6a:	55                   	push   %ebp
c0100c6b:	89 e5                	mov    %esp,%ebp
c0100c6d:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c77:	eb 3f                	jmp    c0100cb8 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c79:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c7c:	89 d0                	mov    %edx,%eax
c0100c7e:	01 c0                	add    %eax,%eax
c0100c80:	01 d0                	add    %edx,%eax
c0100c82:	c1 e0 02             	shl    $0x2,%eax
c0100c85:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c8a:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c90:	89 d0                	mov    %edx,%eax
c0100c92:	01 c0                	add    %eax,%eax
c0100c94:	01 d0                	add    %edx,%eax
c0100c96:	c1 e0 02             	shl    $0x2,%eax
c0100c99:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c9e:	8b 00                	mov    (%eax),%eax
c0100ca0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca8:	c7 04 24 31 94 10 c0 	movl   $0xc0109431,(%esp)
c0100caf:	e8 a3 f6 ff ff       	call   c0100357 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cb4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cbb:	83 f8 02             	cmp    $0x2,%eax
c0100cbe:	76 b9                	jbe    c0100c79 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc5:	c9                   	leave  
c0100cc6:	c3                   	ret    

c0100cc7 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cc7:	55                   	push   %ebp
c0100cc8:	89 e5                	mov    %esp,%ebp
c0100cca:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100ccd:	e8 b9 fb ff ff       	call   c010088b <print_kerninfo>
    return 0;
c0100cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd7:	c9                   	leave  
c0100cd8:	c3                   	ret    

c0100cd9 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cd9:	55                   	push   %ebp
c0100cda:	89 e5                	mov    %esp,%ebp
c0100cdc:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cdf:	e8 f1 fc ff ff       	call   c01009d5 <print_stackframe>
    return 0;
c0100ce4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ce9:	c9                   	leave  
c0100cea:	c3                   	ret    

c0100ceb <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100ceb:	55                   	push   %ebp
c0100cec:	89 e5                	mov    %esp,%ebp
c0100cee:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cf1:	a1 20 34 12 c0       	mov    0xc0123420,%eax
c0100cf6:	85 c0                	test   %eax,%eax
c0100cf8:	74 02                	je     c0100cfc <__panic+0x11>
        goto panic_dead;
c0100cfa:	eb 59                	jmp    c0100d55 <__panic+0x6a>
    }
    is_panic = 1;
c0100cfc:	c7 05 20 34 12 c0 01 	movl   $0x1,0xc0123420
c0100d03:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d06:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d0f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d13:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1a:	c7 04 24 3a 94 10 c0 	movl   $0xc010943a,(%esp)
c0100d21:	e8 31 f6 ff ff       	call   c0100357 <cprintf>
    vcprintf(fmt, ap);
c0100d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d2d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d30:	89 04 24             	mov    %eax,(%esp)
c0100d33:	e8 ec f5 ff ff       	call   c0100324 <vcprintf>
    cprintf("\n");
c0100d38:	c7 04 24 56 94 10 c0 	movl   $0xc0109456,(%esp)
c0100d3f:	e8 13 f6 ff ff       	call   c0100357 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d44:	c7 04 24 58 94 10 c0 	movl   $0xc0109458,(%esp)
c0100d4b:	e8 07 f6 ff ff       	call   c0100357 <cprintf>
    print_stackframe();
c0100d50:	e8 80 fc ff ff       	call   c01009d5 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d55:	e8 fa 11 00 00       	call   c0101f54 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d61:	e8 a4 fe ff ff       	call   c0100c0a <kmonitor>
    }
c0100d66:	eb f2                	jmp    c0100d5a <__panic+0x6f>

c0100d68 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d68:	55                   	push   %ebp
c0100d69:	89 e5                	mov    %esp,%ebp
c0100d6b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d6e:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d74:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d77:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d82:	c7 04 24 6a 94 10 c0 	movl   $0xc010946a,(%esp)
c0100d89:	e8 c9 f5 ff ff       	call   c0100357 <cprintf>
    vcprintf(fmt, ap);
c0100d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d95:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d98:	89 04 24             	mov    %eax,(%esp)
c0100d9b:	e8 84 f5 ff ff       	call   c0100324 <vcprintf>
    cprintf("\n");
c0100da0:	c7 04 24 56 94 10 c0 	movl   $0xc0109456,(%esp)
c0100da7:	e8 ab f5 ff ff       	call   c0100357 <cprintf>
    va_end(ap);
}
c0100dac:	c9                   	leave  
c0100dad:	c3                   	ret    

c0100dae <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100dae:	55                   	push   %ebp
c0100daf:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100db1:	a1 20 34 12 c0       	mov    0xc0123420,%eax
}
c0100db6:	5d                   	pop    %ebp
c0100db7:	c3                   	ret    

c0100db8 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100db8:	55                   	push   %ebp
c0100db9:	89 e5                	mov    %esp,%ebp
c0100dbb:	83 ec 28             	sub    $0x28,%esp
c0100dbe:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dc4:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dc8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dcc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dd0:	ee                   	out    %al,(%dx)
c0100dd1:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dd7:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100ddb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ddf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100de3:	ee                   	out    %al,(%dx)
c0100de4:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dea:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dee:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100df2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100df6:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100df7:	c7 05 3c 40 12 c0 00 	movl   $0x0,0xc012403c
c0100dfe:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e01:	c7 04 24 88 94 10 c0 	movl   $0xc0109488,(%esp)
c0100e08:	e8 4a f5 ff ff       	call   c0100357 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e14:	e8 99 11 00 00       	call   c0101fb2 <pic_enable>
}
c0100e19:	c9                   	leave  
c0100e1a:	c3                   	ret    

c0100e1b <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e1b:	55                   	push   %ebp
c0100e1c:	89 e5                	mov    %esp,%ebp
c0100e1e:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e21:	9c                   	pushf  
c0100e22:	58                   	pop    %eax
c0100e23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e29:	25 00 02 00 00       	and    $0x200,%eax
c0100e2e:	85 c0                	test   %eax,%eax
c0100e30:	74 0c                	je     c0100e3e <__intr_save+0x23>
        intr_disable();
c0100e32:	e8 1d 11 00 00       	call   c0101f54 <intr_disable>
        return 1;
c0100e37:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e3c:	eb 05                	jmp    c0100e43 <__intr_save+0x28>
    }
    return 0;
c0100e3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e43:	c9                   	leave  
c0100e44:	c3                   	ret    

c0100e45 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e45:	55                   	push   %ebp
c0100e46:	89 e5                	mov    %esp,%ebp
c0100e48:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e4f:	74 05                	je     c0100e56 <__intr_restore+0x11>
        intr_enable();
c0100e51:	e8 f8 10 00 00       	call   c0101f4e <intr_enable>
    }
}
c0100e56:	c9                   	leave  
c0100e57:	c3                   	ret    

c0100e58 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e58:	55                   	push   %ebp
c0100e59:	89 e5                	mov    %esp,%ebp
c0100e5b:	83 ec 10             	sub    $0x10,%esp
c0100e5e:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e64:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e68:	89 c2                	mov    %eax,%edx
c0100e6a:	ec                   	in     (%dx),%al
c0100e6b:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e6e:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e74:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e78:	89 c2                	mov    %eax,%edx
c0100e7a:	ec                   	in     (%dx),%al
c0100e7b:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e7e:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e84:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e88:	89 c2                	mov    %eax,%edx
c0100e8a:	ec                   	in     (%dx),%al
c0100e8b:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e8e:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e94:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e98:	89 c2                	mov    %eax,%edx
c0100e9a:	ec                   	in     (%dx),%al
c0100e9b:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e9e:	c9                   	leave  
c0100e9f:	c3                   	ret    

c0100ea0 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ea0:	55                   	push   %ebp
c0100ea1:	89 e5                	mov    %esp,%ebp
c0100ea3:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ea6:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ead:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb0:	0f b7 00             	movzwl (%eax),%eax
c0100eb3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eba:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ebf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec2:	0f b7 00             	movzwl (%eax),%eax
c0100ec5:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100ec9:	74 12                	je     c0100edd <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ecb:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ed2:	66 c7 05 46 34 12 c0 	movw   $0x3b4,0xc0123446
c0100ed9:	b4 03 
c0100edb:	eb 13                	jmp    c0100ef0 <cga_init+0x50>
    } else {
        *cp = was;
c0100edd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ee4:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ee7:	66 c7 05 46 34 12 c0 	movw   $0x3d4,0xc0123446
c0100eee:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ef0:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100ef7:	0f b7 c0             	movzwl %ax,%eax
c0100efa:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100efe:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f02:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f06:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f0a:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f0b:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100f12:	83 c0 01             	add    $0x1,%eax
c0100f15:	0f b7 c0             	movzwl %ax,%eax
c0100f18:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f1c:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f20:	89 c2                	mov    %eax,%edx
c0100f22:	ec                   	in     (%dx),%al
c0100f23:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f26:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f2a:	0f b6 c0             	movzbl %al,%eax
c0100f2d:	c1 e0 08             	shl    $0x8,%eax
c0100f30:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f33:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100f3a:	0f b7 c0             	movzwl %ax,%eax
c0100f3d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f41:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f45:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f49:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f4d:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f4e:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100f55:	83 c0 01             	add    $0x1,%eax
c0100f58:	0f b7 c0             	movzwl %ax,%eax
c0100f5b:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f5f:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f63:	89 c2                	mov    %eax,%edx
c0100f65:	ec                   	in     (%dx),%al
c0100f66:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f69:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f6d:	0f b6 c0             	movzbl %al,%eax
c0100f70:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f73:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f76:	a3 40 34 12 c0       	mov    %eax,0xc0123440
    crt_pos = pos;
c0100f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f7e:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
}
c0100f84:	c9                   	leave  
c0100f85:	c3                   	ret    

c0100f86 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f86:	55                   	push   %ebp
c0100f87:	89 e5                	mov    %esp,%ebp
c0100f89:	83 ec 48             	sub    $0x48,%esp
c0100f8c:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f92:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f96:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f9a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f9e:	ee                   	out    %al,(%dx)
c0100f9f:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100fa5:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100fa9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fad:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fb1:	ee                   	out    %al,(%dx)
c0100fb2:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100fb8:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fbc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fc0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fc4:	ee                   	out    %al,(%dx)
c0100fc5:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fcb:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fcf:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fd3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fd7:	ee                   	out    %al,(%dx)
c0100fd8:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fde:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fe2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fe6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fea:	ee                   	out    %al,(%dx)
c0100feb:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100ff1:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100ff5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100ff9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100ffd:	ee                   	out    %al,(%dx)
c0100ffe:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101004:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101008:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010100c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101010:	ee                   	out    %al,(%dx)
c0101011:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101017:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010101b:	89 c2                	mov    %eax,%edx
c010101d:	ec                   	in     (%dx),%al
c010101e:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101021:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101025:	3c ff                	cmp    $0xff,%al
c0101027:	0f 95 c0             	setne  %al
c010102a:	0f b6 c0             	movzbl %al,%eax
c010102d:	a3 48 34 12 c0       	mov    %eax,0xc0123448
c0101032:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101038:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c010103c:	89 c2                	mov    %eax,%edx
c010103e:	ec                   	in     (%dx),%al
c010103f:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101042:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101048:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010104c:	89 c2                	mov    %eax,%edx
c010104e:	ec                   	in     (%dx),%al
c010104f:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101052:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c0101057:	85 c0                	test   %eax,%eax
c0101059:	74 0c                	je     c0101067 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010105b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101062:	e8 4b 0f 00 00       	call   c0101fb2 <pic_enable>
    }
}
c0101067:	c9                   	leave  
c0101068:	c3                   	ret    

c0101069 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101069:	55                   	push   %ebp
c010106a:	89 e5                	mov    %esp,%ebp
c010106c:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010106f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101076:	eb 09                	jmp    c0101081 <lpt_putc_sub+0x18>
        delay();
c0101078:	e8 db fd ff ff       	call   c0100e58 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010107d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101081:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101087:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010108b:	89 c2                	mov    %eax,%edx
c010108d:	ec                   	in     (%dx),%al
c010108e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101091:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101095:	84 c0                	test   %al,%al
c0101097:	78 09                	js     c01010a2 <lpt_putc_sub+0x39>
c0101099:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010a0:	7e d6                	jle    c0101078 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01010a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01010a5:	0f b6 c0             	movzbl %al,%eax
c01010a8:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01010ae:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010b1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010b5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010b9:	ee                   	out    %al,(%dx)
c01010ba:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010c0:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010c4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010c8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010cc:	ee                   	out    %al,(%dx)
c01010cd:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010d3:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010d7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010db:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010df:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010e0:	c9                   	leave  
c01010e1:	c3                   	ret    

c01010e2 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010e2:	55                   	push   %ebp
c01010e3:	89 e5                	mov    %esp,%ebp
c01010e5:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010e8:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010ec:	74 0d                	je     c01010fb <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f1:	89 04 24             	mov    %eax,(%esp)
c01010f4:	e8 70 ff ff ff       	call   c0101069 <lpt_putc_sub>
c01010f9:	eb 24                	jmp    c010111f <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010fb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101102:	e8 62 ff ff ff       	call   c0101069 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101107:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010110e:	e8 56 ff ff ff       	call   c0101069 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101113:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010111a:	e8 4a ff ff ff       	call   c0101069 <lpt_putc_sub>
    }
}
c010111f:	c9                   	leave  
c0101120:	c3                   	ret    

c0101121 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101121:	55                   	push   %ebp
c0101122:	89 e5                	mov    %esp,%ebp
c0101124:	53                   	push   %ebx
c0101125:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101128:	8b 45 08             	mov    0x8(%ebp),%eax
c010112b:	b0 00                	mov    $0x0,%al
c010112d:	85 c0                	test   %eax,%eax
c010112f:	75 07                	jne    c0101138 <cga_putc+0x17>
        c |= 0x0700;
c0101131:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101138:	8b 45 08             	mov    0x8(%ebp),%eax
c010113b:	0f b6 c0             	movzbl %al,%eax
c010113e:	83 f8 0a             	cmp    $0xa,%eax
c0101141:	74 4c                	je     c010118f <cga_putc+0x6e>
c0101143:	83 f8 0d             	cmp    $0xd,%eax
c0101146:	74 57                	je     c010119f <cga_putc+0x7e>
c0101148:	83 f8 08             	cmp    $0x8,%eax
c010114b:	0f 85 88 00 00 00    	jne    c01011d9 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101151:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101158:	66 85 c0             	test   %ax,%ax
c010115b:	74 30                	je     c010118d <cga_putc+0x6c>
            crt_pos --;
c010115d:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101164:	83 e8 01             	sub    $0x1,%eax
c0101167:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010116d:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c0101172:	0f b7 15 44 34 12 c0 	movzwl 0xc0123444,%edx
c0101179:	0f b7 d2             	movzwl %dx,%edx
c010117c:	01 d2                	add    %edx,%edx
c010117e:	01 c2                	add    %eax,%edx
c0101180:	8b 45 08             	mov    0x8(%ebp),%eax
c0101183:	b0 00                	mov    $0x0,%al
c0101185:	83 c8 20             	or     $0x20,%eax
c0101188:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010118b:	eb 72                	jmp    c01011ff <cga_putc+0xde>
c010118d:	eb 70                	jmp    c01011ff <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c010118f:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101196:	83 c0 50             	add    $0x50,%eax
c0101199:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010119f:	0f b7 1d 44 34 12 c0 	movzwl 0xc0123444,%ebx
c01011a6:	0f b7 0d 44 34 12 c0 	movzwl 0xc0123444,%ecx
c01011ad:	0f b7 c1             	movzwl %cx,%eax
c01011b0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01011b6:	c1 e8 10             	shr    $0x10,%eax
c01011b9:	89 c2                	mov    %eax,%edx
c01011bb:	66 c1 ea 06          	shr    $0x6,%dx
c01011bf:	89 d0                	mov    %edx,%eax
c01011c1:	c1 e0 02             	shl    $0x2,%eax
c01011c4:	01 d0                	add    %edx,%eax
c01011c6:	c1 e0 04             	shl    $0x4,%eax
c01011c9:	29 c1                	sub    %eax,%ecx
c01011cb:	89 ca                	mov    %ecx,%edx
c01011cd:	89 d8                	mov    %ebx,%eax
c01011cf:	29 d0                	sub    %edx,%eax
c01011d1:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
        break;
c01011d7:	eb 26                	jmp    c01011ff <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011d9:	8b 0d 40 34 12 c0    	mov    0xc0123440,%ecx
c01011df:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01011e6:	8d 50 01             	lea    0x1(%eax),%edx
c01011e9:	66 89 15 44 34 12 c0 	mov    %dx,0xc0123444
c01011f0:	0f b7 c0             	movzwl %ax,%eax
c01011f3:	01 c0                	add    %eax,%eax
c01011f5:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01011fb:	66 89 02             	mov    %ax,(%edx)
        break;
c01011fe:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011ff:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101206:	66 3d cf 07          	cmp    $0x7cf,%ax
c010120a:	76 5b                	jbe    c0101267 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010120c:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c0101211:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101217:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c010121c:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101223:	00 
c0101224:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101228:	89 04 24             	mov    %eax,(%esp)
c010122b:	e8 dc 7d 00 00       	call   c010900c <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101230:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101237:	eb 15                	jmp    c010124e <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101239:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c010123e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101241:	01 d2                	add    %edx,%edx
c0101243:	01 d0                	add    %edx,%eax
c0101245:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010124a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010124e:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101255:	7e e2                	jle    c0101239 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101257:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c010125e:	83 e8 50             	sub    $0x50,%eax
c0101261:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101267:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c010126e:	0f b7 c0             	movzwl %ax,%eax
c0101271:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101275:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101279:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010127d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101281:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101282:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101289:	66 c1 e8 08          	shr    $0x8,%ax
c010128d:	0f b6 c0             	movzbl %al,%eax
c0101290:	0f b7 15 46 34 12 c0 	movzwl 0xc0123446,%edx
c0101297:	83 c2 01             	add    $0x1,%edx
c010129a:	0f b7 d2             	movzwl %dx,%edx
c010129d:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01012a1:	88 45 ed             	mov    %al,-0x13(%ebp)
c01012a4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012a8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012ac:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012ad:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c01012b4:	0f b7 c0             	movzwl %ax,%eax
c01012b7:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012bb:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012bf:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012c3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012c7:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012c8:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01012cf:	0f b6 c0             	movzbl %al,%eax
c01012d2:	0f b7 15 46 34 12 c0 	movzwl 0xc0123446,%edx
c01012d9:	83 c2 01             	add    $0x1,%edx
c01012dc:	0f b7 d2             	movzwl %dx,%edx
c01012df:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012e3:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012e6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012ea:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ee:	ee                   	out    %al,(%dx)
}
c01012ef:	83 c4 34             	add    $0x34,%esp
c01012f2:	5b                   	pop    %ebx
c01012f3:	5d                   	pop    %ebp
c01012f4:	c3                   	ret    

c01012f5 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012f5:	55                   	push   %ebp
c01012f6:	89 e5                	mov    %esp,%ebp
c01012f8:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012fb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101302:	eb 09                	jmp    c010130d <serial_putc_sub+0x18>
        delay();
c0101304:	e8 4f fb ff ff       	call   c0100e58 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101309:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010130d:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101313:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101317:	89 c2                	mov    %eax,%edx
c0101319:	ec                   	in     (%dx),%al
c010131a:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010131d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101321:	0f b6 c0             	movzbl %al,%eax
c0101324:	83 e0 20             	and    $0x20,%eax
c0101327:	85 c0                	test   %eax,%eax
c0101329:	75 09                	jne    c0101334 <serial_putc_sub+0x3f>
c010132b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101332:	7e d0                	jle    c0101304 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101334:	8b 45 08             	mov    0x8(%ebp),%eax
c0101337:	0f b6 c0             	movzbl %al,%eax
c010133a:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101340:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101343:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101347:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010134b:	ee                   	out    %al,(%dx)
}
c010134c:	c9                   	leave  
c010134d:	c3                   	ret    

c010134e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010134e:	55                   	push   %ebp
c010134f:	89 e5                	mov    %esp,%ebp
c0101351:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101354:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101358:	74 0d                	je     c0101367 <serial_putc+0x19>
        serial_putc_sub(c);
c010135a:	8b 45 08             	mov    0x8(%ebp),%eax
c010135d:	89 04 24             	mov    %eax,(%esp)
c0101360:	e8 90 ff ff ff       	call   c01012f5 <serial_putc_sub>
c0101365:	eb 24                	jmp    c010138b <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101367:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136e:	e8 82 ff ff ff       	call   c01012f5 <serial_putc_sub>
        serial_putc_sub(' ');
c0101373:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010137a:	e8 76 ff ff ff       	call   c01012f5 <serial_putc_sub>
        serial_putc_sub('\b');
c010137f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101386:	e8 6a ff ff ff       	call   c01012f5 <serial_putc_sub>
    }
}
c010138b:	c9                   	leave  
c010138c:	c3                   	ret    

c010138d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010138d:	55                   	push   %ebp
c010138e:	89 e5                	mov    %esp,%ebp
c0101390:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101393:	eb 33                	jmp    c01013c8 <cons_intr+0x3b>
        if (c != 0) {
c0101395:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101399:	74 2d                	je     c01013c8 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010139b:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c01013a0:	8d 50 01             	lea    0x1(%eax),%edx
c01013a3:	89 15 64 36 12 c0    	mov    %edx,0xc0123664
c01013a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013ac:	88 90 60 34 12 c0    	mov    %dl,-0x3fedcba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013b2:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c01013b7:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013bc:	75 0a                	jne    c01013c8 <cons_intr+0x3b>
                cons.wpos = 0;
c01013be:	c7 05 64 36 12 c0 00 	movl   $0x0,0xc0123664
c01013c5:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01013cb:	ff d0                	call   *%eax
c01013cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013d0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013d4:	75 bf                	jne    c0101395 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013d6:	c9                   	leave  
c01013d7:	c3                   	ret    

c01013d8 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013d8:	55                   	push   %ebp
c01013d9:	89 e5                	mov    %esp,%ebp
c01013db:	83 ec 10             	sub    $0x10,%esp
c01013de:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013e4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013e8:	89 c2                	mov    %eax,%edx
c01013ea:	ec                   	in     (%dx),%al
c01013eb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013ee:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013f2:	0f b6 c0             	movzbl %al,%eax
c01013f5:	83 e0 01             	and    $0x1,%eax
c01013f8:	85 c0                	test   %eax,%eax
c01013fa:	75 07                	jne    c0101403 <serial_proc_data+0x2b>
        return -1;
c01013fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101401:	eb 2a                	jmp    c010142d <serial_proc_data+0x55>
c0101403:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101409:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010140d:	89 c2                	mov    %eax,%edx
c010140f:	ec                   	in     (%dx),%al
c0101410:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101413:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101417:	0f b6 c0             	movzbl %al,%eax
c010141a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010141d:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101421:	75 07                	jne    c010142a <serial_proc_data+0x52>
        c = '\b';
c0101423:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010142a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010142d:	c9                   	leave  
c010142e:	c3                   	ret    

c010142f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010142f:	55                   	push   %ebp
c0101430:	89 e5                	mov    %esp,%ebp
c0101432:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101435:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c010143a:	85 c0                	test   %eax,%eax
c010143c:	74 0c                	je     c010144a <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010143e:	c7 04 24 d8 13 10 c0 	movl   $0xc01013d8,(%esp)
c0101445:	e8 43 ff ff ff       	call   c010138d <cons_intr>
    }
}
c010144a:	c9                   	leave  
c010144b:	c3                   	ret    

c010144c <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010144c:	55                   	push   %ebp
c010144d:	89 e5                	mov    %esp,%ebp
c010144f:	83 ec 38             	sub    $0x38,%esp
c0101452:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101458:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010145c:	89 c2                	mov    %eax,%edx
c010145e:	ec                   	in     (%dx),%al
c010145f:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101462:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101466:	0f b6 c0             	movzbl %al,%eax
c0101469:	83 e0 01             	and    $0x1,%eax
c010146c:	85 c0                	test   %eax,%eax
c010146e:	75 0a                	jne    c010147a <kbd_proc_data+0x2e>
        return -1;
c0101470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101475:	e9 59 01 00 00       	jmp    c01015d3 <kbd_proc_data+0x187>
c010147a:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101480:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101484:	89 c2                	mov    %eax,%edx
c0101486:	ec                   	in     (%dx),%al
c0101487:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010148a:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010148e:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101491:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101495:	75 17                	jne    c01014ae <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101497:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c010149c:	83 c8 40             	or     $0x40,%eax
c010149f:	a3 68 36 12 c0       	mov    %eax,0xc0123668
        return 0;
c01014a4:	b8 00 00 00 00       	mov    $0x0,%eax
c01014a9:	e9 25 01 00 00       	jmp    c01015d3 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01014ae:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b2:	84 c0                	test   %al,%al
c01014b4:	79 47                	jns    c01014fd <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014b6:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01014bb:	83 e0 40             	and    $0x40,%eax
c01014be:	85 c0                	test   %eax,%eax
c01014c0:	75 09                	jne    c01014cb <kbd_proc_data+0x7f>
c01014c2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c6:	83 e0 7f             	and    $0x7f,%eax
c01014c9:	eb 04                	jmp    c01014cf <kbd_proc_data+0x83>
c01014cb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014cf:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014d2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014d6:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c01014dd:	83 c8 40             	or     $0x40,%eax
c01014e0:	0f b6 c0             	movzbl %al,%eax
c01014e3:	f7 d0                	not    %eax
c01014e5:	89 c2                	mov    %eax,%edx
c01014e7:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01014ec:	21 d0                	and    %edx,%eax
c01014ee:	a3 68 36 12 c0       	mov    %eax,0xc0123668
        return 0;
c01014f3:	b8 00 00 00 00       	mov    $0x0,%eax
c01014f8:	e9 d6 00 00 00       	jmp    c01015d3 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014fd:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101502:	83 e0 40             	and    $0x40,%eax
c0101505:	85 c0                	test   %eax,%eax
c0101507:	74 11                	je     c010151a <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101509:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010150d:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101512:	83 e0 bf             	and    $0xffffffbf,%eax
c0101515:	a3 68 36 12 c0       	mov    %eax,0xc0123668
    }

    shift |= shiftcode[data];
c010151a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151e:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101525:	0f b6 d0             	movzbl %al,%edx
c0101528:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c010152d:	09 d0                	or     %edx,%eax
c010152f:	a3 68 36 12 c0       	mov    %eax,0xc0123668
    shift ^= togglecode[data];
c0101534:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101538:	0f b6 80 40 01 12 c0 	movzbl -0x3fedfec0(%eax),%eax
c010153f:	0f b6 d0             	movzbl %al,%edx
c0101542:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101547:	31 d0                	xor    %edx,%eax
c0101549:	a3 68 36 12 c0       	mov    %eax,0xc0123668

    c = charcode[shift & (CTL | SHIFT)][data];
c010154e:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101553:	83 e0 03             	and    $0x3,%eax
c0101556:	8b 14 85 40 05 12 c0 	mov    -0x3fedfac0(,%eax,4),%edx
c010155d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101561:	01 d0                	add    %edx,%eax
c0101563:	0f b6 00             	movzbl (%eax),%eax
c0101566:	0f b6 c0             	movzbl %al,%eax
c0101569:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010156c:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101571:	83 e0 08             	and    $0x8,%eax
c0101574:	85 c0                	test   %eax,%eax
c0101576:	74 22                	je     c010159a <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101578:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010157c:	7e 0c                	jle    c010158a <kbd_proc_data+0x13e>
c010157e:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101582:	7f 06                	jg     c010158a <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101584:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101588:	eb 10                	jmp    c010159a <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010158a:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010158e:	7e 0a                	jle    c010159a <kbd_proc_data+0x14e>
c0101590:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101594:	7f 04                	jg     c010159a <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101596:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010159a:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c010159f:	f7 d0                	not    %eax
c01015a1:	83 e0 06             	and    $0x6,%eax
c01015a4:	85 c0                	test   %eax,%eax
c01015a6:	75 28                	jne    c01015d0 <kbd_proc_data+0x184>
c01015a8:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015af:	75 1f                	jne    c01015d0 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01015b1:	c7 04 24 a3 94 10 c0 	movl   $0xc01094a3,(%esp)
c01015b8:	e8 9a ed ff ff       	call   c0100357 <cprintf>
c01015bd:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015c3:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015c7:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015cb:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015cf:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015d3:	c9                   	leave  
c01015d4:	c3                   	ret    

c01015d5 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015d5:	55                   	push   %ebp
c01015d6:	89 e5                	mov    %esp,%ebp
c01015d8:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015db:	c7 04 24 4c 14 10 c0 	movl   $0xc010144c,(%esp)
c01015e2:	e8 a6 fd ff ff       	call   c010138d <cons_intr>
}
c01015e7:	c9                   	leave  
c01015e8:	c3                   	ret    

c01015e9 <kbd_init>:

static void
kbd_init(void) {
c01015e9:	55                   	push   %ebp
c01015ea:	89 e5                	mov    %esp,%ebp
c01015ec:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015ef:	e8 e1 ff ff ff       	call   c01015d5 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015fb:	e8 b2 09 00 00       	call   c0101fb2 <pic_enable>
}
c0101600:	c9                   	leave  
c0101601:	c3                   	ret    

c0101602 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101602:	55                   	push   %ebp
c0101603:	89 e5                	mov    %esp,%ebp
c0101605:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101608:	e8 93 f8 ff ff       	call   c0100ea0 <cga_init>
    serial_init();
c010160d:	e8 74 f9 ff ff       	call   c0100f86 <serial_init>
    kbd_init();
c0101612:	e8 d2 ff ff ff       	call   c01015e9 <kbd_init>
    if (!serial_exists) {
c0101617:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c010161c:	85 c0                	test   %eax,%eax
c010161e:	75 0c                	jne    c010162c <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101620:	c7 04 24 af 94 10 c0 	movl   $0xc01094af,(%esp)
c0101627:	e8 2b ed ff ff       	call   c0100357 <cprintf>
    }
}
c010162c:	c9                   	leave  
c010162d:	c3                   	ret    

c010162e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010162e:	55                   	push   %ebp
c010162f:	89 e5                	mov    %esp,%ebp
c0101631:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101634:	e8 e2 f7 ff ff       	call   c0100e1b <__intr_save>
c0101639:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010163c:	8b 45 08             	mov    0x8(%ebp),%eax
c010163f:	89 04 24             	mov    %eax,(%esp)
c0101642:	e8 9b fa ff ff       	call   c01010e2 <lpt_putc>
        cga_putc(c);
c0101647:	8b 45 08             	mov    0x8(%ebp),%eax
c010164a:	89 04 24             	mov    %eax,(%esp)
c010164d:	e8 cf fa ff ff       	call   c0101121 <cga_putc>
        serial_putc(c);
c0101652:	8b 45 08             	mov    0x8(%ebp),%eax
c0101655:	89 04 24             	mov    %eax,(%esp)
c0101658:	e8 f1 fc ff ff       	call   c010134e <serial_putc>
    }
    local_intr_restore(intr_flag);
c010165d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101660:	89 04 24             	mov    %eax,(%esp)
c0101663:	e8 dd f7 ff ff       	call   c0100e45 <__intr_restore>
}
c0101668:	c9                   	leave  
c0101669:	c3                   	ret    

c010166a <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010166a:	55                   	push   %ebp
c010166b:	89 e5                	mov    %esp,%ebp
c010166d:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101670:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101677:	e8 9f f7 ff ff       	call   c0100e1b <__intr_save>
c010167c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010167f:	e8 ab fd ff ff       	call   c010142f <serial_intr>
        kbd_intr();
c0101684:	e8 4c ff ff ff       	call   c01015d5 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101689:	8b 15 60 36 12 c0    	mov    0xc0123660,%edx
c010168f:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c0101694:	39 c2                	cmp    %eax,%edx
c0101696:	74 31                	je     c01016c9 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101698:	a1 60 36 12 c0       	mov    0xc0123660,%eax
c010169d:	8d 50 01             	lea    0x1(%eax),%edx
c01016a0:	89 15 60 36 12 c0    	mov    %edx,0xc0123660
c01016a6:	0f b6 80 60 34 12 c0 	movzbl -0x3fedcba0(%eax),%eax
c01016ad:	0f b6 c0             	movzbl %al,%eax
c01016b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016b3:	a1 60 36 12 c0       	mov    0xc0123660,%eax
c01016b8:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016bd:	75 0a                	jne    c01016c9 <cons_getc+0x5f>
                cons.rpos = 0;
c01016bf:	c7 05 60 36 12 c0 00 	movl   $0x0,0xc0123660
c01016c6:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016cc:	89 04 24             	mov    %eax,(%esp)
c01016cf:	e8 71 f7 ff ff       	call   c0100e45 <__intr_restore>
    return c;
c01016d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016d7:	c9                   	leave  
c01016d8:	c3                   	ret    

c01016d9 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01016d9:	55                   	push   %ebp
c01016da:	89 e5                	mov    %esp,%ebp
c01016dc:	83 ec 14             	sub    $0x14,%esp
c01016df:	8b 45 08             	mov    0x8(%ebp),%eax
c01016e2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01016e6:	90                   	nop
c01016e7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016eb:	83 c0 07             	add    $0x7,%eax
c01016ee:	0f b7 c0             	movzwl %ax,%eax
c01016f1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016f5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016f9:	89 c2                	mov    %eax,%edx
c01016fb:	ec                   	in     (%dx),%al
c01016fc:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01016ff:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101703:	0f b6 c0             	movzbl %al,%eax
c0101706:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101709:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010170c:	25 80 00 00 00       	and    $0x80,%eax
c0101711:	85 c0                	test   %eax,%eax
c0101713:	75 d2                	jne    c01016e7 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0101715:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101719:	74 11                	je     c010172c <ide_wait_ready+0x53>
c010171b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010171e:	83 e0 21             	and    $0x21,%eax
c0101721:	85 c0                	test   %eax,%eax
c0101723:	74 07                	je     c010172c <ide_wait_ready+0x53>
        return -1;
c0101725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010172a:	eb 05                	jmp    c0101731 <ide_wait_ready+0x58>
    }
    return 0;
c010172c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101731:	c9                   	leave  
c0101732:	c3                   	ret    

c0101733 <ide_init>:

void
ide_init(void) {
c0101733:	55                   	push   %ebp
c0101734:	89 e5                	mov    %esp,%ebp
c0101736:	57                   	push   %edi
c0101737:	53                   	push   %ebx
c0101738:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010173e:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0101744:	e9 d6 02 00 00       	jmp    c0101a1f <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101749:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010174d:	c1 e0 03             	shl    $0x3,%eax
c0101750:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101757:	29 c2                	sub    %eax,%edx
c0101759:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c010175f:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0101762:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101766:	66 d1 e8             	shr    %ax
c0101769:	0f b7 c0             	movzwl %ax,%eax
c010176c:	0f b7 04 85 d0 94 10 	movzwl -0x3fef6b30(,%eax,4),%eax
c0101773:	c0 
c0101774:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101778:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010177c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101783:	00 
c0101784:	89 04 24             	mov    %eax,(%esp)
c0101787:	e8 4d ff ff ff       	call   c01016d9 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c010178c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101790:	83 e0 01             	and    $0x1,%eax
c0101793:	c1 e0 04             	shl    $0x4,%eax
c0101796:	83 c8 e0             	or     $0xffffffe0,%eax
c0101799:	0f b6 c0             	movzbl %al,%eax
c010179c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017a0:	83 c2 06             	add    $0x6,%edx
c01017a3:	0f b7 d2             	movzwl %dx,%edx
c01017a6:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c01017aa:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017ad:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017b1:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017b5:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01017b6:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01017c1:	00 
c01017c2:	89 04 24             	mov    %eax,(%esp)
c01017c5:	e8 0f ff ff ff       	call   c01016d9 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01017ca:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017ce:	83 c0 07             	add    $0x7,%eax
c01017d1:	0f b7 c0             	movzwl %ax,%eax
c01017d4:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01017d8:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01017dc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01017e0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01017e4:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01017e5:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01017f0:	00 
c01017f1:	89 04 24             	mov    %eax,(%esp)
c01017f4:	e8 e0 fe ff ff       	call   c01016d9 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01017f9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017fd:	83 c0 07             	add    $0x7,%eax
c0101800:	0f b7 c0             	movzwl %ax,%eax
c0101803:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101807:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c010180b:	89 c2                	mov    %eax,%edx
c010180d:	ec                   	in     (%dx),%al
c010180e:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0101811:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101815:	84 c0                	test   %al,%al
c0101817:	0f 84 f7 01 00 00    	je     c0101a14 <ide_init+0x2e1>
c010181d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101821:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101828:	00 
c0101829:	89 04 24             	mov    %eax,(%esp)
c010182c:	e8 a8 fe ff ff       	call   c01016d9 <ide_wait_ready>
c0101831:	85 c0                	test   %eax,%eax
c0101833:	0f 85 db 01 00 00    	jne    c0101a14 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101839:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010183d:	c1 e0 03             	shl    $0x3,%eax
c0101840:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101847:	29 c2                	sub    %eax,%edx
c0101849:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c010184f:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101852:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101856:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101859:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010185f:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101862:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101869:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010186c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010186f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101872:	89 cb                	mov    %ecx,%ebx
c0101874:	89 df                	mov    %ebx,%edi
c0101876:	89 c1                	mov    %eax,%ecx
c0101878:	fc                   	cld    
c0101879:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010187b:	89 c8                	mov    %ecx,%eax
c010187d:	89 fb                	mov    %edi,%ebx
c010187f:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101882:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0101885:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010188b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c010188e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101891:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0101897:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010189a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010189d:	25 00 00 00 04       	and    $0x4000000,%eax
c01018a2:	85 c0                	test   %eax,%eax
c01018a4:	74 0e                	je     c01018b4 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01018a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018a9:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01018af:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01018b2:	eb 09                	jmp    c01018bd <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01018b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018b7:	8b 40 78             	mov    0x78(%eax),%eax
c01018ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01018bd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018c1:	c1 e0 03             	shl    $0x3,%eax
c01018c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01018cb:	29 c2                	sub    %eax,%edx
c01018cd:	81 c2 80 36 12 c0    	add    $0xc0123680,%edx
c01018d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01018d6:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01018d9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018dd:	c1 e0 03             	shl    $0x3,%eax
c01018e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01018e7:	29 c2                	sub    %eax,%edx
c01018e9:	81 c2 80 36 12 c0    	add    $0xc0123680,%edx
c01018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018f2:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01018f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018f8:	83 c0 62             	add    $0x62,%eax
c01018fb:	0f b7 00             	movzwl (%eax),%eax
c01018fe:	0f b7 c0             	movzwl %ax,%eax
c0101901:	25 00 02 00 00       	and    $0x200,%eax
c0101906:	85 c0                	test   %eax,%eax
c0101908:	75 24                	jne    c010192e <ide_init+0x1fb>
c010190a:	c7 44 24 0c d8 94 10 	movl   $0xc01094d8,0xc(%esp)
c0101911:	c0 
c0101912:	c7 44 24 08 1b 95 10 	movl   $0xc010951b,0x8(%esp)
c0101919:	c0 
c010191a:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101921:	00 
c0101922:	c7 04 24 30 95 10 c0 	movl   $0xc0109530,(%esp)
c0101929:	e8 bd f3 ff ff       	call   c0100ceb <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c010192e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101932:	c1 e0 03             	shl    $0x3,%eax
c0101935:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010193c:	29 c2                	sub    %eax,%edx
c010193e:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101944:	83 c0 0c             	add    $0xc,%eax
c0101947:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010194a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010194d:	83 c0 36             	add    $0x36,%eax
c0101950:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101953:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c010195a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101961:	eb 34                	jmp    c0101997 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101963:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101966:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101969:	01 c2                	add    %eax,%edx
c010196b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010196e:	8d 48 01             	lea    0x1(%eax),%ecx
c0101971:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101974:	01 c8                	add    %ecx,%eax
c0101976:	0f b6 00             	movzbl (%eax),%eax
c0101979:	88 02                	mov    %al,(%edx)
c010197b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010197e:	8d 50 01             	lea    0x1(%eax),%edx
c0101981:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101984:	01 c2                	add    %eax,%edx
c0101986:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101989:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c010198c:	01 c8                	add    %ecx,%eax
c010198e:	0f b6 00             	movzbl (%eax),%eax
c0101991:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101993:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101997:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010199a:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010199d:	72 c4                	jb     c0101963 <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c010199f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01019a5:	01 d0                	add    %edx,%eax
c01019a7:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01019aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019ad:	8d 50 ff             	lea    -0x1(%eax),%edx
c01019b0:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01019b3:	85 c0                	test   %eax,%eax
c01019b5:	74 0f                	je     c01019c6 <ide_init+0x293>
c01019b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01019bd:	01 d0                	add    %edx,%eax
c01019bf:	0f b6 00             	movzbl (%eax),%eax
c01019c2:	3c 20                	cmp    $0x20,%al
c01019c4:	74 d9                	je     c010199f <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01019c6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019ca:	c1 e0 03             	shl    $0x3,%eax
c01019cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019d4:	29 c2                	sub    %eax,%edx
c01019d6:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c01019dc:	8d 48 0c             	lea    0xc(%eax),%ecx
c01019df:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019e3:	c1 e0 03             	shl    $0x3,%eax
c01019e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019ed:	29 c2                	sub    %eax,%edx
c01019ef:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c01019f5:	8b 50 08             	mov    0x8(%eax),%edx
c01019f8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019fc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101a00:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a08:	c7 04 24 42 95 10 c0 	movl   $0xc0109542,(%esp)
c0101a0f:	e8 43 e9 ff ff       	call   c0100357 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a14:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a18:	83 c0 01             	add    $0x1,%eax
c0101a1b:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101a1f:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101a24:	0f 86 1f fd ff ff    	jbe    c0101749 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101a2a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101a31:	e8 7c 05 00 00       	call   c0101fb2 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101a36:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101a3d:	e8 70 05 00 00       	call   c0101fb2 <pic_enable>
}
c0101a42:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101a48:	5b                   	pop    %ebx
c0101a49:	5f                   	pop    %edi
c0101a4a:	5d                   	pop    %ebp
c0101a4b:	c3                   	ret    

c0101a4c <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101a4c:	55                   	push   %ebp
c0101a4d:	89 e5                	mov    %esp,%ebp
c0101a4f:	83 ec 04             	sub    $0x4,%esp
c0101a52:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a55:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101a59:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101a5e:	77 24                	ja     c0101a84 <ide_device_valid+0x38>
c0101a60:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101a64:	c1 e0 03             	shl    $0x3,%eax
c0101a67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a6e:	29 c2                	sub    %eax,%edx
c0101a70:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101a76:	0f b6 00             	movzbl (%eax),%eax
c0101a79:	84 c0                	test   %al,%al
c0101a7b:	74 07                	je     c0101a84 <ide_device_valid+0x38>
c0101a7d:	b8 01 00 00 00       	mov    $0x1,%eax
c0101a82:	eb 05                	jmp    c0101a89 <ide_device_valid+0x3d>
c0101a84:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101a89:	c9                   	leave  
c0101a8a:	c3                   	ret    

c0101a8b <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101a8b:	55                   	push   %ebp
c0101a8c:	89 e5                	mov    %esp,%ebp
c0101a8e:	83 ec 08             	sub    $0x8,%esp
c0101a91:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a94:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101a98:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101a9c:	89 04 24             	mov    %eax,(%esp)
c0101a9f:	e8 a8 ff ff ff       	call   c0101a4c <ide_device_valid>
c0101aa4:	85 c0                	test   %eax,%eax
c0101aa6:	74 1b                	je     c0101ac3 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101aa8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101aac:	c1 e0 03             	shl    $0x3,%eax
c0101aaf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101ab6:	29 c2                	sub    %eax,%edx
c0101ab8:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101abe:	8b 40 08             	mov    0x8(%eax),%eax
c0101ac1:	eb 05                	jmp    c0101ac8 <ide_device_size+0x3d>
    }
    return 0;
c0101ac3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101ac8:	c9                   	leave  
c0101ac9:	c3                   	ret    

c0101aca <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101aca:	55                   	push   %ebp
c0101acb:	89 e5                	mov    %esp,%ebp
c0101acd:	57                   	push   %edi
c0101ace:	53                   	push   %ebx
c0101acf:	83 ec 50             	sub    $0x50,%esp
c0101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad5:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101ad9:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101ae0:	77 24                	ja     c0101b06 <ide_read_secs+0x3c>
c0101ae2:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101ae7:	77 1d                	ja     c0101b06 <ide_read_secs+0x3c>
c0101ae9:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101aed:	c1 e0 03             	shl    $0x3,%eax
c0101af0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101af7:	29 c2                	sub    %eax,%edx
c0101af9:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101aff:	0f b6 00             	movzbl (%eax),%eax
c0101b02:	84 c0                	test   %al,%al
c0101b04:	75 24                	jne    c0101b2a <ide_read_secs+0x60>
c0101b06:	c7 44 24 0c 60 95 10 	movl   $0xc0109560,0xc(%esp)
c0101b0d:	c0 
c0101b0e:	c7 44 24 08 1b 95 10 	movl   $0xc010951b,0x8(%esp)
c0101b15:	c0 
c0101b16:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101b1d:	00 
c0101b1e:	c7 04 24 30 95 10 c0 	movl   $0xc0109530,(%esp)
c0101b25:	e8 c1 f1 ff ff       	call   c0100ceb <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101b2a:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101b31:	77 0f                	ja     c0101b42 <ide_read_secs+0x78>
c0101b33:	8b 45 14             	mov    0x14(%ebp),%eax
c0101b36:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101b39:	01 d0                	add    %edx,%eax
c0101b3b:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101b40:	76 24                	jbe    c0101b66 <ide_read_secs+0x9c>
c0101b42:	c7 44 24 0c 88 95 10 	movl   $0xc0109588,0xc(%esp)
c0101b49:	c0 
c0101b4a:	c7 44 24 08 1b 95 10 	movl   $0xc010951b,0x8(%esp)
c0101b51:	c0 
c0101b52:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101b59:	00 
c0101b5a:	c7 04 24 30 95 10 c0 	movl   $0xc0109530,(%esp)
c0101b61:	e8 85 f1 ff ff       	call   c0100ceb <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101b66:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b6a:	66 d1 e8             	shr    %ax
c0101b6d:	0f b7 c0             	movzwl %ax,%eax
c0101b70:	0f b7 04 85 d0 94 10 	movzwl -0x3fef6b30(,%eax,4),%eax
c0101b77:	c0 
c0101b78:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101b7c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b80:	66 d1 e8             	shr    %ax
c0101b83:	0f b7 c0             	movzwl %ax,%eax
c0101b86:	0f b7 04 85 d2 94 10 	movzwl -0x3fef6b2e(,%eax,4),%eax
c0101b8d:	c0 
c0101b8e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101b92:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101b96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101b9d:	00 
c0101b9e:	89 04 24             	mov    %eax,(%esp)
c0101ba1:	e8 33 fb ff ff       	call   c01016d9 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101ba6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101baa:	83 c0 02             	add    $0x2,%eax
c0101bad:	0f b7 c0             	movzwl %ax,%eax
c0101bb0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101bb4:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bb8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101bbc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101bc0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101bc1:	8b 45 14             	mov    0x14(%ebp),%eax
c0101bc4:	0f b6 c0             	movzbl %al,%eax
c0101bc7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bcb:	83 c2 02             	add    $0x2,%edx
c0101bce:	0f b7 d2             	movzwl %dx,%edx
c0101bd1:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101bd5:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101bd8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101bdc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101be0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101be1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101be4:	0f b6 c0             	movzbl %al,%eax
c0101be7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101beb:	83 c2 03             	add    $0x3,%edx
c0101bee:	0f b7 d2             	movzwl %dx,%edx
c0101bf1:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101bf5:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101bf8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101bfc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101c00:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c04:	c1 e8 08             	shr    $0x8,%eax
c0101c07:	0f b6 c0             	movzbl %al,%eax
c0101c0a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c0e:	83 c2 04             	add    $0x4,%edx
c0101c11:	0f b7 d2             	movzwl %dx,%edx
c0101c14:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c18:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101c1b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101c1f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101c23:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101c24:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c27:	c1 e8 10             	shr    $0x10,%eax
c0101c2a:	0f b6 c0             	movzbl %al,%eax
c0101c2d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c31:	83 c2 05             	add    $0x5,%edx
c0101c34:	0f b7 d2             	movzwl %dx,%edx
c0101c37:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c3b:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101c3e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c42:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c46:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101c47:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c4b:	83 e0 01             	and    $0x1,%eax
c0101c4e:	c1 e0 04             	shl    $0x4,%eax
c0101c51:	89 c2                	mov    %eax,%edx
c0101c53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c56:	c1 e8 18             	shr    $0x18,%eax
c0101c59:	83 e0 0f             	and    $0xf,%eax
c0101c5c:	09 d0                	or     %edx,%eax
c0101c5e:	83 c8 e0             	or     $0xffffffe0,%eax
c0101c61:	0f b6 c0             	movzbl %al,%eax
c0101c64:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c68:	83 c2 06             	add    $0x6,%edx
c0101c6b:	0f b7 d2             	movzwl %dx,%edx
c0101c6e:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c72:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101c75:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c79:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c7d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101c7e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c82:	83 c0 07             	add    $0x7,%eax
c0101c85:	0f b7 c0             	movzwl %ax,%eax
c0101c88:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101c8c:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101c90:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c94:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c98:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101c99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101ca0:	eb 5a                	jmp    c0101cfc <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101ca2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ca6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101cad:	00 
c0101cae:	89 04 24             	mov    %eax,(%esp)
c0101cb1:	e8 23 fa ff ff       	call   c01016d9 <ide_wait_ready>
c0101cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101cb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101cbd:	74 02                	je     c0101cc1 <ide_read_secs+0x1f7>
            goto out;
c0101cbf:	eb 41                	jmp    c0101d02 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101cc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cc5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101cc8:	8b 45 10             	mov    0x10(%ebp),%eax
c0101ccb:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101cce:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101cd5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101cd8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101cdb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101cde:	89 cb                	mov    %ecx,%ebx
c0101ce0:	89 df                	mov    %ebx,%edi
c0101ce2:	89 c1                	mov    %eax,%ecx
c0101ce4:	fc                   	cld    
c0101ce5:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101ce7:	89 c8                	mov    %ecx,%eax
c0101ce9:	89 fb                	mov    %edi,%ebx
c0101ceb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101cee:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101cf1:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101cf5:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101cfc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d00:	75 a0                	jne    c0101ca2 <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d05:	83 c4 50             	add    $0x50,%esp
c0101d08:	5b                   	pop    %ebx
c0101d09:	5f                   	pop    %edi
c0101d0a:	5d                   	pop    %ebp
c0101d0b:	c3                   	ret    

c0101d0c <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d0c:	55                   	push   %ebp
c0101d0d:	89 e5                	mov    %esp,%ebp
c0101d0f:	56                   	push   %esi
c0101d10:	53                   	push   %ebx
c0101d11:	83 ec 50             	sub    $0x50,%esp
c0101d14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d17:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101d1b:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101d22:	77 24                	ja     c0101d48 <ide_write_secs+0x3c>
c0101d24:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101d29:	77 1d                	ja     c0101d48 <ide_write_secs+0x3c>
c0101d2b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d2f:	c1 e0 03             	shl    $0x3,%eax
c0101d32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101d39:	29 c2                	sub    %eax,%edx
c0101d3b:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101d41:	0f b6 00             	movzbl (%eax),%eax
c0101d44:	84 c0                	test   %al,%al
c0101d46:	75 24                	jne    c0101d6c <ide_write_secs+0x60>
c0101d48:	c7 44 24 0c 60 95 10 	movl   $0xc0109560,0xc(%esp)
c0101d4f:	c0 
c0101d50:	c7 44 24 08 1b 95 10 	movl   $0xc010951b,0x8(%esp)
c0101d57:	c0 
c0101d58:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101d5f:	00 
c0101d60:	c7 04 24 30 95 10 c0 	movl   $0xc0109530,(%esp)
c0101d67:	e8 7f ef ff ff       	call   c0100ceb <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101d6c:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101d73:	77 0f                	ja     c0101d84 <ide_write_secs+0x78>
c0101d75:	8b 45 14             	mov    0x14(%ebp),%eax
c0101d78:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101d7b:	01 d0                	add    %edx,%eax
c0101d7d:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101d82:	76 24                	jbe    c0101da8 <ide_write_secs+0x9c>
c0101d84:	c7 44 24 0c 88 95 10 	movl   $0xc0109588,0xc(%esp)
c0101d8b:	c0 
c0101d8c:	c7 44 24 08 1b 95 10 	movl   $0xc010951b,0x8(%esp)
c0101d93:	c0 
c0101d94:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101d9b:	00 
c0101d9c:	c7 04 24 30 95 10 c0 	movl   $0xc0109530,(%esp)
c0101da3:	e8 43 ef ff ff       	call   c0100ceb <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101da8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101dac:	66 d1 e8             	shr    %ax
c0101daf:	0f b7 c0             	movzwl %ax,%eax
c0101db2:	0f b7 04 85 d0 94 10 	movzwl -0x3fef6b30(,%eax,4),%eax
c0101db9:	c0 
c0101dba:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101dbe:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101dc2:	66 d1 e8             	shr    %ax
c0101dc5:	0f b7 c0             	movzwl %ax,%eax
c0101dc8:	0f b7 04 85 d2 94 10 	movzwl -0x3fef6b2e(,%eax,4),%eax
c0101dcf:	c0 
c0101dd0:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101dd4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ddf:	00 
c0101de0:	89 04 24             	mov    %eax,(%esp)
c0101de3:	e8 f1 f8 ff ff       	call   c01016d9 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101de8:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101dec:	83 c0 02             	add    $0x2,%eax
c0101def:	0f b7 c0             	movzwl %ax,%eax
c0101df2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101df6:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101dfa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101dfe:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101e02:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101e03:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e06:	0f b6 c0             	movzbl %al,%eax
c0101e09:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e0d:	83 c2 02             	add    $0x2,%edx
c0101e10:	0f b7 d2             	movzwl %dx,%edx
c0101e13:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101e17:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101e1a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101e1e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101e22:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101e23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e26:	0f b6 c0             	movzbl %al,%eax
c0101e29:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e2d:	83 c2 03             	add    $0x3,%edx
c0101e30:	0f b7 d2             	movzwl %dx,%edx
c0101e33:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101e37:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101e3a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101e3e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101e42:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101e43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e46:	c1 e8 08             	shr    $0x8,%eax
c0101e49:	0f b6 c0             	movzbl %al,%eax
c0101e4c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e50:	83 c2 04             	add    $0x4,%edx
c0101e53:	0f b7 d2             	movzwl %dx,%edx
c0101e56:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101e5a:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101e5d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101e61:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101e65:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101e66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e69:	c1 e8 10             	shr    $0x10,%eax
c0101e6c:	0f b6 c0             	movzbl %al,%eax
c0101e6f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e73:	83 c2 05             	add    $0x5,%edx
c0101e76:	0f b7 d2             	movzwl %dx,%edx
c0101e79:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101e7d:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101e80:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101e84:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101e88:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101e89:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e8d:	83 e0 01             	and    $0x1,%eax
c0101e90:	c1 e0 04             	shl    $0x4,%eax
c0101e93:	89 c2                	mov    %eax,%edx
c0101e95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e98:	c1 e8 18             	shr    $0x18,%eax
c0101e9b:	83 e0 0f             	and    $0xf,%eax
c0101e9e:	09 d0                	or     %edx,%eax
c0101ea0:	83 c8 e0             	or     $0xffffffe0,%eax
c0101ea3:	0f b6 c0             	movzbl %al,%eax
c0101ea6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101eaa:	83 c2 06             	add    $0x6,%edx
c0101ead:	0f b7 d2             	movzwl %dx,%edx
c0101eb0:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101eb4:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101eb7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101ebb:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101ebf:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101ec0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ec4:	83 c0 07             	add    $0x7,%eax
c0101ec7:	0f b7 c0             	movzwl %ax,%eax
c0101eca:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101ece:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101ed2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101ed6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101eda:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101edb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101ee2:	eb 5a                	jmp    c0101f3e <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101ee4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ee8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101eef:	00 
c0101ef0:	89 04 24             	mov    %eax,(%esp)
c0101ef3:	e8 e1 f7 ff ff       	call   c01016d9 <ide_wait_ready>
c0101ef8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101efb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101eff:	74 02                	je     c0101f03 <ide_write_secs+0x1f7>
            goto out;
c0101f01:	eb 41                	jmp    c0101f44 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f03:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f07:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f0a:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f0d:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f10:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101f17:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f1a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101f1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101f20:	89 cb                	mov    %ecx,%ebx
c0101f22:	89 de                	mov    %ebx,%esi
c0101f24:	89 c1                	mov    %eax,%ecx
c0101f26:	fc                   	cld    
c0101f27:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101f29:	89 c8                	mov    %ecx,%eax
c0101f2b:	89 f3                	mov    %esi,%ebx
c0101f2d:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101f30:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f33:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101f37:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101f3e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101f42:	75 a0                	jne    c0101ee4 <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f47:	83 c4 50             	add    $0x50,%esp
c0101f4a:	5b                   	pop    %ebx
c0101f4b:	5e                   	pop    %esi
c0101f4c:	5d                   	pop    %ebp
c0101f4d:	c3                   	ret    

c0101f4e <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101f4e:	55                   	push   %ebp
c0101f4f:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101f51:	fb                   	sti    
    sti();
}
c0101f52:	5d                   	pop    %ebp
c0101f53:	c3                   	ret    

c0101f54 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101f54:	55                   	push   %ebp
c0101f55:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0101f57:	fa                   	cli    
    cli();
}
c0101f58:	5d                   	pop    %ebp
c0101f59:	c3                   	ret    

c0101f5a <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f5a:	55                   	push   %ebp
c0101f5b:	89 e5                	mov    %esp,%ebp
c0101f5d:	83 ec 14             	sub    $0x14,%esp
c0101f60:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f63:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f67:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f6b:	66 a3 50 05 12 c0    	mov    %ax,0xc0120550
    if (did_init) {
c0101f71:	a1 60 37 12 c0       	mov    0xc0123760,%eax
c0101f76:	85 c0                	test   %eax,%eax
c0101f78:	74 36                	je     c0101fb0 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f7a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f7e:	0f b6 c0             	movzbl %al,%eax
c0101f81:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f87:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f8a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f8e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f92:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f93:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f97:	66 c1 e8 08          	shr    $0x8,%ax
c0101f9b:	0f b6 c0             	movzbl %al,%eax
c0101f9e:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101fa4:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101fa7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101fab:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101faf:	ee                   	out    %al,(%dx)
    }
}
c0101fb0:	c9                   	leave  
c0101fb1:	c3                   	ret    

c0101fb2 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101fb2:	55                   	push   %ebp
c0101fb3:	89 e5                	mov    %esp,%ebp
c0101fb5:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101fb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fbb:	ba 01 00 00 00       	mov    $0x1,%edx
c0101fc0:	89 c1                	mov    %eax,%ecx
c0101fc2:	d3 e2                	shl    %cl,%edx
c0101fc4:	89 d0                	mov    %edx,%eax
c0101fc6:	f7 d0                	not    %eax
c0101fc8:	89 c2                	mov    %eax,%edx
c0101fca:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0101fd1:	21 d0                	and    %edx,%eax
c0101fd3:	0f b7 c0             	movzwl %ax,%eax
c0101fd6:	89 04 24             	mov    %eax,(%esp)
c0101fd9:	e8 7c ff ff ff       	call   c0101f5a <pic_setmask>
}
c0101fde:	c9                   	leave  
c0101fdf:	c3                   	ret    

c0101fe0 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fe0:	55                   	push   %ebp
c0101fe1:	89 e5                	mov    %esp,%ebp
c0101fe3:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101fe6:	c7 05 60 37 12 c0 01 	movl   $0x1,0xc0123760
c0101fed:	00 00 00 
c0101ff0:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101ff6:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101ffa:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101ffe:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102002:	ee                   	out    %al,(%dx)
c0102003:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102009:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010200d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102011:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102015:	ee                   	out    %al,(%dx)
c0102016:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010201c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102020:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102024:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102028:	ee                   	out    %al,(%dx)
c0102029:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010202f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0102033:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102037:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010203b:	ee                   	out    %al,(%dx)
c010203c:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0102042:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c0102046:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010204a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010204e:	ee                   	out    %al,(%dx)
c010204f:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0102055:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102059:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010205d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102061:	ee                   	out    %al,(%dx)
c0102062:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102068:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c010206c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102070:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102074:	ee                   	out    %al,(%dx)
c0102075:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c010207b:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c010207f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102083:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102087:	ee                   	out    %al,(%dx)
c0102088:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010208e:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0102092:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102096:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010209a:	ee                   	out    %al,(%dx)
c010209b:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c01020a1:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01020a5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020a9:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020ad:	ee                   	out    %al,(%dx)
c01020ae:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01020b4:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01020b8:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020bc:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020c0:	ee                   	out    %al,(%dx)
c01020c1:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020c7:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01020cb:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020cf:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020d3:	ee                   	out    %al,(%dx)
c01020d4:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01020da:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01020de:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020e2:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020e6:	ee                   	out    %al,(%dx)
c01020e7:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01020ed:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01020f1:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01020f5:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01020f9:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020fa:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0102101:	66 83 f8 ff          	cmp    $0xffff,%ax
c0102105:	74 12                	je     c0102119 <pic_init+0x139>
        pic_setmask(irq_mask);
c0102107:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c010210e:	0f b7 c0             	movzwl %ax,%eax
c0102111:	89 04 24             	mov    %eax,(%esp)
c0102114:	e8 41 fe ff ff       	call   c0101f5a <pic_setmask>
    }
}
c0102119:	c9                   	leave  
c010211a:	c3                   	ret    

c010211b <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010211b:	55                   	push   %ebp
c010211c:	89 e5                	mov    %esp,%ebp
c010211e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102121:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102128:	00 
c0102129:	c7 04 24 e0 95 10 c0 	movl   $0xc01095e0,(%esp)
c0102130:	e8 22 e2 ff ff       	call   c0100357 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102135:	c9                   	leave  
c0102136:	c3                   	ret    

c0102137 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102137:	55                   	push   %ebp
c0102138:	89 e5                	mov    %esp,%ebp
c010213a:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c010213d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102144:	e9 c3 00 00 00       	jmp    c010220c <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102149:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010214c:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c0102153:	89 c2                	mov    %eax,%edx
c0102155:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102158:	66 89 14 c5 80 37 12 	mov    %dx,-0x3fedc880(,%eax,8)
c010215f:	c0 
c0102160:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102163:	66 c7 04 c5 82 37 12 	movw   $0x8,-0x3fedc87e(,%eax,8)
c010216a:	c0 08 00 
c010216d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102170:	0f b6 14 c5 84 37 12 	movzbl -0x3fedc87c(,%eax,8),%edx
c0102177:	c0 
c0102178:	83 e2 e0             	and    $0xffffffe0,%edx
c010217b:	88 14 c5 84 37 12 c0 	mov    %dl,-0x3fedc87c(,%eax,8)
c0102182:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102185:	0f b6 14 c5 84 37 12 	movzbl -0x3fedc87c(,%eax,8),%edx
c010218c:	c0 
c010218d:	83 e2 1f             	and    $0x1f,%edx
c0102190:	88 14 c5 84 37 12 c0 	mov    %dl,-0x3fedc87c(,%eax,8)
c0102197:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010219a:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021a1:	c0 
c01021a2:	83 e2 f0             	and    $0xfffffff0,%edx
c01021a5:	83 ca 0e             	or     $0xe,%edx
c01021a8:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c01021af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021b2:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021b9:	c0 
c01021ba:	83 e2 ef             	and    $0xffffffef,%edx
c01021bd:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c01021c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c7:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021ce:	c0 
c01021cf:	83 e2 9f             	and    $0xffffff9f,%edx
c01021d2:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c01021d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021dc:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021e3:	c0 
c01021e4:	83 ca 80             	or     $0xffffff80,%edx
c01021e7:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c01021ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021f1:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c01021f8:	c1 e8 10             	shr    $0x10,%eax
c01021fb:	89 c2                	mov    %eax,%edx
c01021fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102200:	66 89 14 c5 86 37 12 	mov    %dx,-0x3fedc87a(,%eax,8)
c0102207:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c0102208:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010220c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010220f:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102214:	0f 86 2f ff ff ff    	jbe    c0102149 <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
	}
	//SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], 3);
c010221a:	a1 c4 07 12 c0       	mov    0xc01207c4,%eax
c010221f:	66 a3 48 3b 12 c0    	mov    %ax,0xc0123b48
c0102225:	66 c7 05 4a 3b 12 c0 	movw   $0x8,0xc0123b4a
c010222c:	08 00 
c010222e:	0f b6 05 4c 3b 12 c0 	movzbl 0xc0123b4c,%eax
c0102235:	83 e0 e0             	and    $0xffffffe0,%eax
c0102238:	a2 4c 3b 12 c0       	mov    %al,0xc0123b4c
c010223d:	0f b6 05 4c 3b 12 c0 	movzbl 0xc0123b4c,%eax
c0102244:	83 e0 1f             	and    $0x1f,%eax
c0102247:	a2 4c 3b 12 c0       	mov    %al,0xc0123b4c
c010224c:	0f b6 05 4d 3b 12 c0 	movzbl 0xc0123b4d,%eax
c0102253:	83 c8 0f             	or     $0xf,%eax
c0102256:	a2 4d 3b 12 c0       	mov    %al,0xc0123b4d
c010225b:	0f b6 05 4d 3b 12 c0 	movzbl 0xc0123b4d,%eax
c0102262:	83 e0 ef             	and    $0xffffffef,%eax
c0102265:	a2 4d 3b 12 c0       	mov    %al,0xc0123b4d
c010226a:	0f b6 05 4d 3b 12 c0 	movzbl 0xc0123b4d,%eax
c0102271:	83 c8 60             	or     $0x60,%eax
c0102274:	a2 4d 3b 12 c0       	mov    %al,0xc0123b4d
c0102279:	0f b6 05 4d 3b 12 c0 	movzbl 0xc0123b4d,%eax
c0102280:	83 c8 80             	or     $0xffffff80,%eax
c0102283:	a2 4d 3b 12 c0       	mov    %al,0xc0123b4d
c0102288:	a1 c4 07 12 c0       	mov    0xc01207c4,%eax
c010228d:	c1 e8 10             	shr    $0x10,%eax
c0102290:	66 a3 4e 3b 12 c0    	mov    %ax,0xc0123b4e
c0102296:	c7 45 f8 60 05 12 c0 	movl   $0xc0120560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010229d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01022a0:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
c01022a3:	c9                   	leave  
c01022a4:	c3                   	ret    

c01022a5 <trapname>:

static const char *
trapname(int trapno) {
c01022a5:	55                   	push   %ebp
c01022a6:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01022a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022ab:	83 f8 13             	cmp    $0x13,%eax
c01022ae:	77 0c                	ja     c01022bc <trapname+0x17>
        return excnames[trapno];
c01022b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022b3:	8b 04 85 a0 99 10 c0 	mov    -0x3fef6660(,%eax,4),%eax
c01022ba:	eb 18                	jmp    c01022d4 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01022bc:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01022c0:	7e 0d                	jle    c01022cf <trapname+0x2a>
c01022c2:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01022c6:	7f 07                	jg     c01022cf <trapname+0x2a>
        return "Hardware Interrupt";
c01022c8:	b8 ea 95 10 c0       	mov    $0xc01095ea,%eax
c01022cd:	eb 05                	jmp    c01022d4 <trapname+0x2f>
    }
    return "(unknown trap)";
c01022cf:	b8 fd 95 10 c0       	mov    $0xc01095fd,%eax
}
c01022d4:	5d                   	pop    %ebp
c01022d5:	c3                   	ret    

c01022d6 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01022d6:	55                   	push   %ebp
c01022d7:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01022d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01022dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022e0:	66 83 f8 08          	cmp    $0x8,%ax
c01022e4:	0f 94 c0             	sete   %al
c01022e7:	0f b6 c0             	movzbl %al,%eax
}
c01022ea:	5d                   	pop    %ebp
c01022eb:	c3                   	ret    

c01022ec <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01022ec:	55                   	push   %ebp
c01022ed:	89 e5                	mov    %esp,%ebp
c01022ef:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01022f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01022f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022f9:	c7 04 24 3e 96 10 c0 	movl   $0xc010963e,(%esp)
c0102300:	e8 52 e0 ff ff       	call   c0100357 <cprintf>
    print_regs(&tf->tf_regs);
c0102305:	8b 45 08             	mov    0x8(%ebp),%eax
c0102308:	89 04 24             	mov    %eax,(%esp)
c010230b:	e8 a1 01 00 00       	call   c01024b1 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102310:	8b 45 08             	mov    0x8(%ebp),%eax
c0102313:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102317:	0f b7 c0             	movzwl %ax,%eax
c010231a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010231e:	c7 04 24 4f 96 10 c0 	movl   $0xc010964f,(%esp)
c0102325:	e8 2d e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010232a:	8b 45 08             	mov    0x8(%ebp),%eax
c010232d:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102331:	0f b7 c0             	movzwl %ax,%eax
c0102334:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102338:	c7 04 24 62 96 10 c0 	movl   $0xc0109662,(%esp)
c010233f:	e8 13 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102344:	8b 45 08             	mov    0x8(%ebp),%eax
c0102347:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010234b:	0f b7 c0             	movzwl %ax,%eax
c010234e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102352:	c7 04 24 75 96 10 c0 	movl   $0xc0109675,(%esp)
c0102359:	e8 f9 df ff ff       	call   c0100357 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010235e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102361:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102365:	0f b7 c0             	movzwl %ax,%eax
c0102368:	89 44 24 04          	mov    %eax,0x4(%esp)
c010236c:	c7 04 24 88 96 10 c0 	movl   $0xc0109688,(%esp)
c0102373:	e8 df df ff ff       	call   c0100357 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102378:	8b 45 08             	mov    0x8(%ebp),%eax
c010237b:	8b 40 30             	mov    0x30(%eax),%eax
c010237e:	89 04 24             	mov    %eax,(%esp)
c0102381:	e8 1f ff ff ff       	call   c01022a5 <trapname>
c0102386:	8b 55 08             	mov    0x8(%ebp),%edx
c0102389:	8b 52 30             	mov    0x30(%edx),%edx
c010238c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102390:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102394:	c7 04 24 9b 96 10 c0 	movl   $0xc010969b,(%esp)
c010239b:	e8 b7 df ff ff       	call   c0100357 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01023a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a3:	8b 40 34             	mov    0x34(%eax),%eax
c01023a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023aa:	c7 04 24 ad 96 10 c0 	movl   $0xc01096ad,(%esp)
c01023b1:	e8 a1 df ff ff       	call   c0100357 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01023b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b9:	8b 40 38             	mov    0x38(%eax),%eax
c01023bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023c0:	c7 04 24 bc 96 10 c0 	movl   $0xc01096bc,(%esp)
c01023c7:	e8 8b df ff ff       	call   c0100357 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01023cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01023cf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023d3:	0f b7 c0             	movzwl %ax,%eax
c01023d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023da:	c7 04 24 cb 96 10 c0 	movl   $0xc01096cb,(%esp)
c01023e1:	e8 71 df ff ff       	call   c0100357 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01023e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e9:	8b 40 40             	mov    0x40(%eax),%eax
c01023ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023f0:	c7 04 24 de 96 10 c0 	movl   $0xc01096de,(%esp)
c01023f7:	e8 5b df ff ff       	call   c0100357 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01023fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102403:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c010240a:	eb 3e                	jmp    c010244a <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010240c:	8b 45 08             	mov    0x8(%ebp),%eax
c010240f:	8b 50 40             	mov    0x40(%eax),%edx
c0102412:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102415:	21 d0                	and    %edx,%eax
c0102417:	85 c0                	test   %eax,%eax
c0102419:	74 28                	je     c0102443 <print_trapframe+0x157>
c010241b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010241e:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c0102425:	85 c0                	test   %eax,%eax
c0102427:	74 1a                	je     c0102443 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0102429:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010242c:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c0102433:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102437:	c7 04 24 ed 96 10 c0 	movl   $0xc01096ed,(%esp)
c010243e:	e8 14 df ff ff       	call   c0100357 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102443:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102447:	d1 65 f0             	shll   -0x10(%ebp)
c010244a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010244d:	83 f8 17             	cmp    $0x17,%eax
c0102450:	76 ba                	jbe    c010240c <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102452:	8b 45 08             	mov    0x8(%ebp),%eax
c0102455:	8b 40 40             	mov    0x40(%eax),%eax
c0102458:	25 00 30 00 00       	and    $0x3000,%eax
c010245d:	c1 e8 0c             	shr    $0xc,%eax
c0102460:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102464:	c7 04 24 f1 96 10 c0 	movl   $0xc01096f1,(%esp)
c010246b:	e8 e7 de ff ff       	call   c0100357 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102470:	8b 45 08             	mov    0x8(%ebp),%eax
c0102473:	89 04 24             	mov    %eax,(%esp)
c0102476:	e8 5b fe ff ff       	call   c01022d6 <trap_in_kernel>
c010247b:	85 c0                	test   %eax,%eax
c010247d:	75 30                	jne    c01024af <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010247f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102482:	8b 40 44             	mov    0x44(%eax),%eax
c0102485:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102489:	c7 04 24 fa 96 10 c0 	movl   $0xc01096fa,(%esp)
c0102490:	e8 c2 de ff ff       	call   c0100357 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102495:	8b 45 08             	mov    0x8(%ebp),%eax
c0102498:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010249c:	0f b7 c0             	movzwl %ax,%eax
c010249f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024a3:	c7 04 24 09 97 10 c0 	movl   $0xc0109709,(%esp)
c01024aa:	e8 a8 de ff ff       	call   c0100357 <cprintf>
    }
}
c01024af:	c9                   	leave  
c01024b0:	c3                   	ret    

c01024b1 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01024b1:	55                   	push   %ebp
c01024b2:	89 e5                	mov    %esp,%ebp
c01024b4:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01024b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ba:	8b 00                	mov    (%eax),%eax
c01024bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c0:	c7 04 24 1c 97 10 c0 	movl   $0xc010971c,(%esp)
c01024c7:	e8 8b de ff ff       	call   c0100357 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01024cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01024cf:	8b 40 04             	mov    0x4(%eax),%eax
c01024d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d6:	c7 04 24 2b 97 10 c0 	movl   $0xc010972b,(%esp)
c01024dd:	e8 75 de ff ff       	call   c0100357 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01024e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e5:	8b 40 08             	mov    0x8(%eax),%eax
c01024e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ec:	c7 04 24 3a 97 10 c0 	movl   $0xc010973a,(%esp)
c01024f3:	e8 5f de ff ff       	call   c0100357 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01024f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fb:	8b 40 0c             	mov    0xc(%eax),%eax
c01024fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102502:	c7 04 24 49 97 10 c0 	movl   $0xc0109749,(%esp)
c0102509:	e8 49 de ff ff       	call   c0100357 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c010250e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102511:	8b 40 10             	mov    0x10(%eax),%eax
c0102514:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102518:	c7 04 24 58 97 10 c0 	movl   $0xc0109758,(%esp)
c010251f:	e8 33 de ff ff       	call   c0100357 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102524:	8b 45 08             	mov    0x8(%ebp),%eax
c0102527:	8b 40 14             	mov    0x14(%eax),%eax
c010252a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010252e:	c7 04 24 67 97 10 c0 	movl   $0xc0109767,(%esp)
c0102535:	e8 1d de ff ff       	call   c0100357 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010253a:	8b 45 08             	mov    0x8(%ebp),%eax
c010253d:	8b 40 18             	mov    0x18(%eax),%eax
c0102540:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102544:	c7 04 24 76 97 10 c0 	movl   $0xc0109776,(%esp)
c010254b:	e8 07 de ff ff       	call   c0100357 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102550:	8b 45 08             	mov    0x8(%ebp),%eax
c0102553:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102556:	89 44 24 04          	mov    %eax,0x4(%esp)
c010255a:	c7 04 24 85 97 10 c0 	movl   $0xc0109785,(%esp)
c0102561:	e8 f1 dd ff ff       	call   c0100357 <cprintf>
}
c0102566:	c9                   	leave  
c0102567:	c3                   	ret    

c0102568 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102568:	55                   	push   %ebp
c0102569:	89 e5                	mov    %esp,%ebp
c010256b:	53                   	push   %ebx
c010256c:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010256f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102572:	8b 40 34             	mov    0x34(%eax),%eax
c0102575:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102578:	85 c0                	test   %eax,%eax
c010257a:	74 07                	je     c0102583 <print_pgfault+0x1b>
c010257c:	b9 94 97 10 c0       	mov    $0xc0109794,%ecx
c0102581:	eb 05                	jmp    c0102588 <print_pgfault+0x20>
c0102583:	b9 a5 97 10 c0       	mov    $0xc01097a5,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0102588:	8b 45 08             	mov    0x8(%ebp),%eax
c010258b:	8b 40 34             	mov    0x34(%eax),%eax
c010258e:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102591:	85 c0                	test   %eax,%eax
c0102593:	74 07                	je     c010259c <print_pgfault+0x34>
c0102595:	ba 57 00 00 00       	mov    $0x57,%edx
c010259a:	eb 05                	jmp    c01025a1 <print_pgfault+0x39>
c010259c:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01025a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a4:	8b 40 34             	mov    0x34(%eax),%eax
c01025a7:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025aa:	85 c0                	test   %eax,%eax
c01025ac:	74 07                	je     c01025b5 <print_pgfault+0x4d>
c01025ae:	b8 55 00 00 00       	mov    $0x55,%eax
c01025b3:	eb 05                	jmp    c01025ba <print_pgfault+0x52>
c01025b5:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025ba:	0f 20 d3             	mov    %cr2,%ebx
c01025bd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01025c0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01025c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01025c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01025cb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01025cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01025d3:	c7 04 24 b4 97 10 c0 	movl   $0xc01097b4,(%esp)
c01025da:	e8 78 dd ff ff       	call   c0100357 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01025df:	83 c4 34             	add    $0x34,%esp
c01025e2:	5b                   	pop    %ebx
c01025e3:	5d                   	pop    %ebp
c01025e4:	c3                   	ret    

c01025e5 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01025e5:	55                   	push   %ebp
c01025e6:	89 e5                	mov    %esp,%ebp
c01025e8:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01025eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ee:	89 04 24             	mov    %eax,(%esp)
c01025f1:	e8 72 ff ff ff       	call   c0102568 <print_pgfault>
    if (check_mm_struct != NULL) {
c01025f6:	a1 8c 41 12 c0       	mov    0xc012418c,%eax
c01025fb:	85 c0                	test   %eax,%eax
c01025fd:	74 28                	je     c0102627 <pgfault_handler+0x42>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025ff:	0f 20 d0             	mov    %cr2,%eax
c0102602:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102608:	89 c1                	mov    %eax,%ecx
c010260a:	8b 45 08             	mov    0x8(%ebp),%eax
c010260d:	8b 50 34             	mov    0x34(%eax),%edx
c0102610:	a1 8c 41 12 c0       	mov    0xc012418c,%eax
c0102615:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102619:	89 54 24 04          	mov    %edx,0x4(%esp)
c010261d:	89 04 24             	mov    %eax,(%esp)
c0102620:	e8 5e 5b 00 00       	call   c0108183 <do_pgfault>
c0102625:	eb 1c                	jmp    c0102643 <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c0102627:	c7 44 24 08 d7 97 10 	movl   $0xc01097d7,0x8(%esp)
c010262e:	c0 
c010262f:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c0102636:	00 
c0102637:	c7 04 24 ee 97 10 c0 	movl   $0xc01097ee,(%esp)
c010263e:	e8 a8 e6 ff ff       	call   c0100ceb <__panic>
}
c0102643:	c9                   	leave  
c0102644:	c3                   	ret    

c0102645 <trap_dispatch>:

/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

static void
trap_dispatch(struct trapframe *tf) {
c0102645:	55                   	push   %ebp
c0102646:	89 e5                	mov    %esp,%ebp
c0102648:	57                   	push   %edi
c0102649:	56                   	push   %esi
c010264a:	53                   	push   %ebx
c010264b:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c010264e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102651:	8b 40 30             	mov    0x30(%eax),%eax
c0102654:	83 f8 24             	cmp    $0x24,%eax
c0102657:	0f 84 d0 00 00 00    	je     c010272d <trap_dispatch+0xe8>
c010265d:	83 f8 24             	cmp    $0x24,%eax
c0102660:	77 1c                	ja     c010267e <trap_dispatch+0x39>
c0102662:	83 f8 20             	cmp    $0x20,%eax
c0102665:	0f 84 87 00 00 00    	je     c01026f2 <trap_dispatch+0xad>
c010266b:	83 f8 21             	cmp    $0x21,%eax
c010266e:	0f 84 e2 00 00 00    	je     c0102756 <trap_dispatch+0x111>
c0102674:	83 f8 0e             	cmp    $0xe,%eax
c0102677:	74 32                	je     c01026ab <trap_dispatch+0x66>
c0102679:	e9 f9 01 00 00       	jmp    c0102877 <trap_dispatch+0x232>
c010267e:	83 f8 78             	cmp    $0x78,%eax
c0102681:	0f 84 f8 00 00 00    	je     c010277f <trap_dispatch+0x13a>
c0102687:	83 f8 78             	cmp    $0x78,%eax
c010268a:	77 11                	ja     c010269d <trap_dispatch+0x58>
c010268c:	83 e8 2e             	sub    $0x2e,%eax
c010268f:	83 f8 01             	cmp    $0x1,%eax
c0102692:	0f 87 df 01 00 00    	ja     c0102877 <trap_dispatch+0x232>
	tf->tf_es = KERNEL_DS;
        break;*/
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0102698:	e9 12 02 00 00       	jmp    c01028af <trap_dispatch+0x26a>
trap_dispatch(struct trapframe *tf) {
    char c;

    int ret;

    switch (tf->tf_trapno) {
c010269d:	83 f8 79             	cmp    $0x79,%eax
c01026a0:	0f 84 58 01 00 00    	je     c01027fe <trap_dispatch+0x1b9>
c01026a6:	e9 cc 01 00 00       	jmp    c0102877 <trap_dispatch+0x232>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01026ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01026ae:	89 04 24             	mov    %eax,(%esp)
c01026b1:	e8 2f ff ff ff       	call   c01025e5 <pgfault_handler>
c01026b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01026b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01026bd:	74 2e                	je     c01026ed <trap_dispatch+0xa8>
            print_trapframe(tf);
c01026bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01026c2:	89 04 24             	mov    %eax,(%esp)
c01026c5:	e8 22 fc ff ff       	call   c01022ec <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c01026ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01026cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01026d1:	c7 44 24 08 ff 97 10 	movl   $0xc01097ff,0x8(%esp)
c01026d8:	c0 
c01026d9:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c01026e0:	00 
c01026e1:	c7 04 24 ee 97 10 c0 	movl   $0xc01097ee,(%esp)
c01026e8:	e8 fe e5 ff ff       	call   c0100ceb <__panic>
        }
        break;
c01026ed:	e9 bd 01 00 00       	jmp    c01028af <trap_dispatch+0x26a>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks++;
c01026f2:	a1 3c 40 12 c0       	mov    0xc012403c,%eax
c01026f7:	83 c0 01             	add    $0x1,%eax
c01026fa:	a3 3c 40 12 c0       	mov    %eax,0xc012403c
	if(ticks % TICK_NUM == 0){
c01026ff:	8b 0d 3c 40 12 c0    	mov    0xc012403c,%ecx
c0102705:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010270a:	89 c8                	mov    %ecx,%eax
c010270c:	f7 e2                	mul    %edx
c010270e:	89 d0                	mov    %edx,%eax
c0102710:	c1 e8 05             	shr    $0x5,%eax
c0102713:	6b c0 64             	imul   $0x64,%eax,%eax
c0102716:	29 c1                	sub    %eax,%ecx
c0102718:	89 c8                	mov    %ecx,%eax
c010271a:	85 c0                	test   %eax,%eax
c010271c:	75 0a                	jne    c0102728 <trap_dispatch+0xe3>
		print_ticks();	
c010271e:	e8 f8 f9 ff ff       	call   c010211b <print_ticks>
	}
        break;
c0102723:	e9 87 01 00 00       	jmp    c01028af <trap_dispatch+0x26a>
c0102728:	e9 82 01 00 00       	jmp    c01028af <trap_dispatch+0x26a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c010272d:	e8 38 ef ff ff       	call   c010166a <cons_getc>
c0102732:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102735:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0102739:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c010273d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102741:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102745:	c7 04 24 1a 98 10 c0 	movl   $0xc010981a,(%esp)
c010274c:	e8 06 dc ff ff       	call   c0100357 <cprintf>
        break;
c0102751:	e9 59 01 00 00       	jmp    c01028af <trap_dispatch+0x26a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102756:	e8 0f ef ff ff       	call   c010166a <cons_getc>
c010275b:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c010275e:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0102762:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c0102766:	89 54 24 08          	mov    %edx,0x8(%esp)
c010276a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010276e:	c7 04 24 2c 98 10 c0 	movl   $0xc010982c,(%esp)
c0102775:	e8 dd db ff ff       	call   c0100357 <cprintf>
        break;
c010277a:	e9 30 01 00 00       	jmp    c01028af <trap_dispatch+0x26a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
	if (tf->tf_cs != USER_CS) {
c010277f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102782:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102786:	66 83 f8 1b          	cmp    $0x1b,%ax
c010278a:	74 6d                	je     c01027f9 <trap_dispatch+0x1b4>
            switchk2u = *tf;
c010278c:	8b 45 08             	mov    0x8(%ebp),%eax
c010278f:	ba 40 40 12 c0       	mov    $0xc0124040,%edx
c0102794:	89 c3                	mov    %eax,%ebx
c0102796:	b8 13 00 00 00       	mov    $0x13,%eax
c010279b:	89 d7                	mov    %edx,%edi
c010279d:	89 de                	mov    %ebx,%esi
c010279f:	89 c1                	mov    %eax,%ecx
c01027a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
c01027a3:	66 c7 05 7c 40 12 c0 	movw   $0x1b,0xc012407c
c01027aa:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c01027ac:	66 c7 05 88 40 12 c0 	movw   $0x23,0xc0124088
c01027b3:	23 00 
c01027b5:	0f b7 05 88 40 12 c0 	movzwl 0xc0124088,%eax
c01027bc:	66 a3 68 40 12 c0    	mov    %ax,0xc0124068
c01027c2:	0f b7 05 68 40 12 c0 	movzwl 0xc0124068,%eax
c01027c9:	66 a3 6c 40 12 c0    	mov    %ax,0xc012406c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c01027cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01027d2:	83 c0 44             	add    $0x44,%eax
c01027d5:	a3 84 40 12 c0       	mov    %eax,0xc0124084
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c01027da:	a1 80 40 12 c0       	mov    0xc0124080,%eax
c01027df:	80 cc 30             	or     $0x30,%ah
c01027e2:	a3 80 40 12 c0       	mov    %eax,0xc0124080
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c01027e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01027ea:	8d 50 fc             	lea    -0x4(%eax),%edx
c01027ed:	b8 40 40 12 c0       	mov    $0xc0124040,%eax
c01027f2:	89 02                	mov    %eax,(%edx)
        }
        break;
c01027f4:	e9 b6 00 00 00       	jmp    c01028af <trap_dispatch+0x26a>
c01027f9:	e9 b1 00 00 00       	jmp    c01028af <trap_dispatch+0x26a>
	tf->tf_ds = USER_DS;
	tf->tf_es = USER_DS;
	tf->tf_ss = USER_DS;
	break;*/
    case T_SWITCH_TOK:
	if (tf->tf_cs != KERNEL_CS) {
c01027fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102801:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102805:	66 83 f8 08          	cmp    $0x8,%ax
c0102809:	74 6a                	je     c0102875 <trap_dispatch+0x230>
            tf->tf_cs = KERNEL_CS;
c010280b:	8b 45 08             	mov    0x8(%ebp),%eax
c010280e:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0102814:	8b 45 08             	mov    0x8(%ebp),%eax
c0102817:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c010281d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102820:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102824:	8b 45 08             	mov    0x8(%ebp),%eax
c0102827:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c010282b:	8b 45 08             	mov    0x8(%ebp),%eax
c010282e:	8b 40 40             	mov    0x40(%eax),%eax
c0102831:	80 e4 cf             	and    $0xcf,%ah
c0102834:	89 c2                	mov    %eax,%edx
c0102836:	8b 45 08             	mov    0x8(%ebp),%eax
c0102839:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c010283c:	8b 45 08             	mov    0x8(%ebp),%eax
c010283f:	8b 40 44             	mov    0x44(%eax),%eax
c0102842:	83 e8 44             	sub    $0x44,%eax
c0102845:	a3 8c 40 12 c0       	mov    %eax,0xc012408c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c010284a:	a1 8c 40 12 c0       	mov    0xc012408c,%eax
c010284f:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0102856:	00 
c0102857:	8b 55 08             	mov    0x8(%ebp),%edx
c010285a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010285e:	89 04 24             	mov    %eax,(%esp)
c0102861:	e8 a6 67 00 00       	call   c010900c <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0102866:	8b 45 08             	mov    0x8(%ebp),%eax
c0102869:	8d 50 fc             	lea    -0x4(%eax),%edx
c010286c:	a1 8c 40 12 c0       	mov    0xc012408c,%eax
c0102871:	89 02                	mov    %eax,(%edx)
        }
        break;
c0102873:	eb 3a                	jmp    c01028af <trap_dispatch+0x26a>
c0102875:	eb 38                	jmp    c01028af <trap_dispatch+0x26a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102877:	8b 45 08             	mov    0x8(%ebp),%eax
c010287a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010287e:	0f b7 c0             	movzwl %ax,%eax
c0102881:	83 e0 03             	and    $0x3,%eax
c0102884:	85 c0                	test   %eax,%eax
c0102886:	75 27                	jne    c01028af <trap_dispatch+0x26a>
            print_trapframe(tf);
c0102888:	8b 45 08             	mov    0x8(%ebp),%eax
c010288b:	89 04 24             	mov    %eax,(%esp)
c010288e:	e8 59 fa ff ff       	call   c01022ec <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102893:	c7 44 24 08 3b 98 10 	movl   $0xc010983b,0x8(%esp)
c010289a:	c0 
c010289b:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01028a2:	00 
c01028a3:	c7 04 24 ee 97 10 c0 	movl   $0xc01097ee,(%esp)
c01028aa:	e8 3c e4 ff ff       	call   c0100ceb <__panic>
        }
    }
}
c01028af:	83 c4 2c             	add    $0x2c,%esp
c01028b2:	5b                   	pop    %ebx
c01028b3:	5e                   	pop    %esi
c01028b4:	5f                   	pop    %edi
c01028b5:	5d                   	pop    %ebp
c01028b6:	c3                   	ret    

c01028b7 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01028b7:	55                   	push   %ebp
c01028b8:	89 e5                	mov    %esp,%ebp
c01028ba:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01028bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01028c0:	89 04 24             	mov    %eax,(%esp)
c01028c3:	e8 7d fd ff ff       	call   c0102645 <trap_dispatch>
}
c01028c8:	c9                   	leave  
c01028c9:	c3                   	ret    

c01028ca <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01028ca:	1e                   	push   %ds
    pushl %es
c01028cb:	06                   	push   %es
    pushl %fs
c01028cc:	0f a0                	push   %fs
    pushl %gs
c01028ce:	0f a8                	push   %gs
    pushal
c01028d0:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01028d1:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01028d6:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01028d8:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01028da:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01028db:	e8 d7 ff ff ff       	call   c01028b7 <trap>

    # pop the pushed stack pointer
    popl %esp
c01028e0:	5c                   	pop    %esp

c01028e1 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01028e1:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01028e2:	0f a9                	pop    %gs
    popl %fs
c01028e4:	0f a1                	pop    %fs
    popl %es
c01028e6:	07                   	pop    %es
    popl %ds
c01028e7:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01028e8:	83 c4 08             	add    $0x8,%esp
    iret
c01028eb:	cf                   	iret   

c01028ec <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $0
c01028ee:	6a 00                	push   $0x0
  jmp __alltraps
c01028f0:	e9 d5 ff ff ff       	jmp    c01028ca <__alltraps>

c01028f5 <vector1>:
.globl vector1
vector1:
  pushl $0
c01028f5:	6a 00                	push   $0x0
  pushl $1
c01028f7:	6a 01                	push   $0x1
  jmp __alltraps
c01028f9:	e9 cc ff ff ff       	jmp    c01028ca <__alltraps>

c01028fe <vector2>:
.globl vector2
vector2:
  pushl $0
c01028fe:	6a 00                	push   $0x0
  pushl $2
c0102900:	6a 02                	push   $0x2
  jmp __alltraps
c0102902:	e9 c3 ff ff ff       	jmp    c01028ca <__alltraps>

c0102907 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102907:	6a 00                	push   $0x0
  pushl $3
c0102909:	6a 03                	push   $0x3
  jmp __alltraps
c010290b:	e9 ba ff ff ff       	jmp    c01028ca <__alltraps>

c0102910 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $4
c0102912:	6a 04                	push   $0x4
  jmp __alltraps
c0102914:	e9 b1 ff ff ff       	jmp    c01028ca <__alltraps>

c0102919 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $5
c010291b:	6a 05                	push   $0x5
  jmp __alltraps
c010291d:	e9 a8 ff ff ff       	jmp    c01028ca <__alltraps>

c0102922 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $6
c0102924:	6a 06                	push   $0x6
  jmp __alltraps
c0102926:	e9 9f ff ff ff       	jmp    c01028ca <__alltraps>

c010292b <vector7>:
.globl vector7
vector7:
  pushl $0
c010292b:	6a 00                	push   $0x0
  pushl $7
c010292d:	6a 07                	push   $0x7
  jmp __alltraps
c010292f:	e9 96 ff ff ff       	jmp    c01028ca <__alltraps>

c0102934 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102934:	6a 08                	push   $0x8
  jmp __alltraps
c0102936:	e9 8f ff ff ff       	jmp    c01028ca <__alltraps>

c010293b <vector9>:
.globl vector9
vector9:
  pushl $0
c010293b:	6a 00                	push   $0x0
  pushl $9
c010293d:	6a 09                	push   $0x9
  jmp __alltraps
c010293f:	e9 86 ff ff ff       	jmp    c01028ca <__alltraps>

c0102944 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102944:	6a 0a                	push   $0xa
  jmp __alltraps
c0102946:	e9 7f ff ff ff       	jmp    c01028ca <__alltraps>

c010294b <vector11>:
.globl vector11
vector11:
  pushl $11
c010294b:	6a 0b                	push   $0xb
  jmp __alltraps
c010294d:	e9 78 ff ff ff       	jmp    c01028ca <__alltraps>

c0102952 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102952:	6a 0c                	push   $0xc
  jmp __alltraps
c0102954:	e9 71 ff ff ff       	jmp    c01028ca <__alltraps>

c0102959 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102959:	6a 0d                	push   $0xd
  jmp __alltraps
c010295b:	e9 6a ff ff ff       	jmp    c01028ca <__alltraps>

c0102960 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102960:	6a 0e                	push   $0xe
  jmp __alltraps
c0102962:	e9 63 ff ff ff       	jmp    c01028ca <__alltraps>

c0102967 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102967:	6a 00                	push   $0x0
  pushl $15
c0102969:	6a 0f                	push   $0xf
  jmp __alltraps
c010296b:	e9 5a ff ff ff       	jmp    c01028ca <__alltraps>

c0102970 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102970:	6a 00                	push   $0x0
  pushl $16
c0102972:	6a 10                	push   $0x10
  jmp __alltraps
c0102974:	e9 51 ff ff ff       	jmp    c01028ca <__alltraps>

c0102979 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102979:	6a 11                	push   $0x11
  jmp __alltraps
c010297b:	e9 4a ff ff ff       	jmp    c01028ca <__alltraps>

c0102980 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102980:	6a 00                	push   $0x0
  pushl $18
c0102982:	6a 12                	push   $0x12
  jmp __alltraps
c0102984:	e9 41 ff ff ff       	jmp    c01028ca <__alltraps>

c0102989 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102989:	6a 00                	push   $0x0
  pushl $19
c010298b:	6a 13                	push   $0x13
  jmp __alltraps
c010298d:	e9 38 ff ff ff       	jmp    c01028ca <__alltraps>

c0102992 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102992:	6a 00                	push   $0x0
  pushl $20
c0102994:	6a 14                	push   $0x14
  jmp __alltraps
c0102996:	e9 2f ff ff ff       	jmp    c01028ca <__alltraps>

c010299b <vector21>:
.globl vector21
vector21:
  pushl $0
c010299b:	6a 00                	push   $0x0
  pushl $21
c010299d:	6a 15                	push   $0x15
  jmp __alltraps
c010299f:	e9 26 ff ff ff       	jmp    c01028ca <__alltraps>

c01029a4 <vector22>:
.globl vector22
vector22:
  pushl $0
c01029a4:	6a 00                	push   $0x0
  pushl $22
c01029a6:	6a 16                	push   $0x16
  jmp __alltraps
c01029a8:	e9 1d ff ff ff       	jmp    c01028ca <__alltraps>

c01029ad <vector23>:
.globl vector23
vector23:
  pushl $0
c01029ad:	6a 00                	push   $0x0
  pushl $23
c01029af:	6a 17                	push   $0x17
  jmp __alltraps
c01029b1:	e9 14 ff ff ff       	jmp    c01028ca <__alltraps>

c01029b6 <vector24>:
.globl vector24
vector24:
  pushl $0
c01029b6:	6a 00                	push   $0x0
  pushl $24
c01029b8:	6a 18                	push   $0x18
  jmp __alltraps
c01029ba:	e9 0b ff ff ff       	jmp    c01028ca <__alltraps>

c01029bf <vector25>:
.globl vector25
vector25:
  pushl $0
c01029bf:	6a 00                	push   $0x0
  pushl $25
c01029c1:	6a 19                	push   $0x19
  jmp __alltraps
c01029c3:	e9 02 ff ff ff       	jmp    c01028ca <__alltraps>

c01029c8 <vector26>:
.globl vector26
vector26:
  pushl $0
c01029c8:	6a 00                	push   $0x0
  pushl $26
c01029ca:	6a 1a                	push   $0x1a
  jmp __alltraps
c01029cc:	e9 f9 fe ff ff       	jmp    c01028ca <__alltraps>

c01029d1 <vector27>:
.globl vector27
vector27:
  pushl $0
c01029d1:	6a 00                	push   $0x0
  pushl $27
c01029d3:	6a 1b                	push   $0x1b
  jmp __alltraps
c01029d5:	e9 f0 fe ff ff       	jmp    c01028ca <__alltraps>

c01029da <vector28>:
.globl vector28
vector28:
  pushl $0
c01029da:	6a 00                	push   $0x0
  pushl $28
c01029dc:	6a 1c                	push   $0x1c
  jmp __alltraps
c01029de:	e9 e7 fe ff ff       	jmp    c01028ca <__alltraps>

c01029e3 <vector29>:
.globl vector29
vector29:
  pushl $0
c01029e3:	6a 00                	push   $0x0
  pushl $29
c01029e5:	6a 1d                	push   $0x1d
  jmp __alltraps
c01029e7:	e9 de fe ff ff       	jmp    c01028ca <__alltraps>

c01029ec <vector30>:
.globl vector30
vector30:
  pushl $0
c01029ec:	6a 00                	push   $0x0
  pushl $30
c01029ee:	6a 1e                	push   $0x1e
  jmp __alltraps
c01029f0:	e9 d5 fe ff ff       	jmp    c01028ca <__alltraps>

c01029f5 <vector31>:
.globl vector31
vector31:
  pushl $0
c01029f5:	6a 00                	push   $0x0
  pushl $31
c01029f7:	6a 1f                	push   $0x1f
  jmp __alltraps
c01029f9:	e9 cc fe ff ff       	jmp    c01028ca <__alltraps>

c01029fe <vector32>:
.globl vector32
vector32:
  pushl $0
c01029fe:	6a 00                	push   $0x0
  pushl $32
c0102a00:	6a 20                	push   $0x20
  jmp __alltraps
c0102a02:	e9 c3 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a07 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102a07:	6a 00                	push   $0x0
  pushl $33
c0102a09:	6a 21                	push   $0x21
  jmp __alltraps
c0102a0b:	e9 ba fe ff ff       	jmp    c01028ca <__alltraps>

c0102a10 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102a10:	6a 00                	push   $0x0
  pushl $34
c0102a12:	6a 22                	push   $0x22
  jmp __alltraps
c0102a14:	e9 b1 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a19 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102a19:	6a 00                	push   $0x0
  pushl $35
c0102a1b:	6a 23                	push   $0x23
  jmp __alltraps
c0102a1d:	e9 a8 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a22 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102a22:	6a 00                	push   $0x0
  pushl $36
c0102a24:	6a 24                	push   $0x24
  jmp __alltraps
c0102a26:	e9 9f fe ff ff       	jmp    c01028ca <__alltraps>

c0102a2b <vector37>:
.globl vector37
vector37:
  pushl $0
c0102a2b:	6a 00                	push   $0x0
  pushl $37
c0102a2d:	6a 25                	push   $0x25
  jmp __alltraps
c0102a2f:	e9 96 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a34 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102a34:	6a 00                	push   $0x0
  pushl $38
c0102a36:	6a 26                	push   $0x26
  jmp __alltraps
c0102a38:	e9 8d fe ff ff       	jmp    c01028ca <__alltraps>

c0102a3d <vector39>:
.globl vector39
vector39:
  pushl $0
c0102a3d:	6a 00                	push   $0x0
  pushl $39
c0102a3f:	6a 27                	push   $0x27
  jmp __alltraps
c0102a41:	e9 84 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a46 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102a46:	6a 00                	push   $0x0
  pushl $40
c0102a48:	6a 28                	push   $0x28
  jmp __alltraps
c0102a4a:	e9 7b fe ff ff       	jmp    c01028ca <__alltraps>

c0102a4f <vector41>:
.globl vector41
vector41:
  pushl $0
c0102a4f:	6a 00                	push   $0x0
  pushl $41
c0102a51:	6a 29                	push   $0x29
  jmp __alltraps
c0102a53:	e9 72 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a58 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102a58:	6a 00                	push   $0x0
  pushl $42
c0102a5a:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102a5c:	e9 69 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a61 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102a61:	6a 00                	push   $0x0
  pushl $43
c0102a63:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102a65:	e9 60 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a6a <vector44>:
.globl vector44
vector44:
  pushl $0
c0102a6a:	6a 00                	push   $0x0
  pushl $44
c0102a6c:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102a6e:	e9 57 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a73 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102a73:	6a 00                	push   $0x0
  pushl $45
c0102a75:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102a77:	e9 4e fe ff ff       	jmp    c01028ca <__alltraps>

c0102a7c <vector46>:
.globl vector46
vector46:
  pushl $0
c0102a7c:	6a 00                	push   $0x0
  pushl $46
c0102a7e:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102a80:	e9 45 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a85 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102a85:	6a 00                	push   $0x0
  pushl $47
c0102a87:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102a89:	e9 3c fe ff ff       	jmp    c01028ca <__alltraps>

c0102a8e <vector48>:
.globl vector48
vector48:
  pushl $0
c0102a8e:	6a 00                	push   $0x0
  pushl $48
c0102a90:	6a 30                	push   $0x30
  jmp __alltraps
c0102a92:	e9 33 fe ff ff       	jmp    c01028ca <__alltraps>

c0102a97 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102a97:	6a 00                	push   $0x0
  pushl $49
c0102a99:	6a 31                	push   $0x31
  jmp __alltraps
c0102a9b:	e9 2a fe ff ff       	jmp    c01028ca <__alltraps>

c0102aa0 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102aa0:	6a 00                	push   $0x0
  pushl $50
c0102aa2:	6a 32                	push   $0x32
  jmp __alltraps
c0102aa4:	e9 21 fe ff ff       	jmp    c01028ca <__alltraps>

c0102aa9 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102aa9:	6a 00                	push   $0x0
  pushl $51
c0102aab:	6a 33                	push   $0x33
  jmp __alltraps
c0102aad:	e9 18 fe ff ff       	jmp    c01028ca <__alltraps>

c0102ab2 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102ab2:	6a 00                	push   $0x0
  pushl $52
c0102ab4:	6a 34                	push   $0x34
  jmp __alltraps
c0102ab6:	e9 0f fe ff ff       	jmp    c01028ca <__alltraps>

c0102abb <vector53>:
.globl vector53
vector53:
  pushl $0
c0102abb:	6a 00                	push   $0x0
  pushl $53
c0102abd:	6a 35                	push   $0x35
  jmp __alltraps
c0102abf:	e9 06 fe ff ff       	jmp    c01028ca <__alltraps>

c0102ac4 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102ac4:	6a 00                	push   $0x0
  pushl $54
c0102ac6:	6a 36                	push   $0x36
  jmp __alltraps
c0102ac8:	e9 fd fd ff ff       	jmp    c01028ca <__alltraps>

c0102acd <vector55>:
.globl vector55
vector55:
  pushl $0
c0102acd:	6a 00                	push   $0x0
  pushl $55
c0102acf:	6a 37                	push   $0x37
  jmp __alltraps
c0102ad1:	e9 f4 fd ff ff       	jmp    c01028ca <__alltraps>

c0102ad6 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102ad6:	6a 00                	push   $0x0
  pushl $56
c0102ad8:	6a 38                	push   $0x38
  jmp __alltraps
c0102ada:	e9 eb fd ff ff       	jmp    c01028ca <__alltraps>

c0102adf <vector57>:
.globl vector57
vector57:
  pushl $0
c0102adf:	6a 00                	push   $0x0
  pushl $57
c0102ae1:	6a 39                	push   $0x39
  jmp __alltraps
c0102ae3:	e9 e2 fd ff ff       	jmp    c01028ca <__alltraps>

c0102ae8 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $58
c0102aea:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102aec:	e9 d9 fd ff ff       	jmp    c01028ca <__alltraps>

c0102af1 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102af1:	6a 00                	push   $0x0
  pushl $59
c0102af3:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102af5:	e9 d0 fd ff ff       	jmp    c01028ca <__alltraps>

c0102afa <vector60>:
.globl vector60
vector60:
  pushl $0
c0102afa:	6a 00                	push   $0x0
  pushl $60
c0102afc:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102afe:	e9 c7 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b03 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102b03:	6a 00                	push   $0x0
  pushl $61
c0102b05:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102b07:	e9 be fd ff ff       	jmp    c01028ca <__alltraps>

c0102b0c <vector62>:
.globl vector62
vector62:
  pushl $0
c0102b0c:	6a 00                	push   $0x0
  pushl $62
c0102b0e:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102b10:	e9 b5 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b15 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102b15:	6a 00                	push   $0x0
  pushl $63
c0102b17:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102b19:	e9 ac fd ff ff       	jmp    c01028ca <__alltraps>

c0102b1e <vector64>:
.globl vector64
vector64:
  pushl $0
c0102b1e:	6a 00                	push   $0x0
  pushl $64
c0102b20:	6a 40                	push   $0x40
  jmp __alltraps
c0102b22:	e9 a3 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b27 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102b27:	6a 00                	push   $0x0
  pushl $65
c0102b29:	6a 41                	push   $0x41
  jmp __alltraps
c0102b2b:	e9 9a fd ff ff       	jmp    c01028ca <__alltraps>

c0102b30 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102b30:	6a 00                	push   $0x0
  pushl $66
c0102b32:	6a 42                	push   $0x42
  jmp __alltraps
c0102b34:	e9 91 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b39 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102b39:	6a 00                	push   $0x0
  pushl $67
c0102b3b:	6a 43                	push   $0x43
  jmp __alltraps
c0102b3d:	e9 88 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b42 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102b42:	6a 00                	push   $0x0
  pushl $68
c0102b44:	6a 44                	push   $0x44
  jmp __alltraps
c0102b46:	e9 7f fd ff ff       	jmp    c01028ca <__alltraps>

c0102b4b <vector69>:
.globl vector69
vector69:
  pushl $0
c0102b4b:	6a 00                	push   $0x0
  pushl $69
c0102b4d:	6a 45                	push   $0x45
  jmp __alltraps
c0102b4f:	e9 76 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b54 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102b54:	6a 00                	push   $0x0
  pushl $70
c0102b56:	6a 46                	push   $0x46
  jmp __alltraps
c0102b58:	e9 6d fd ff ff       	jmp    c01028ca <__alltraps>

c0102b5d <vector71>:
.globl vector71
vector71:
  pushl $0
c0102b5d:	6a 00                	push   $0x0
  pushl $71
c0102b5f:	6a 47                	push   $0x47
  jmp __alltraps
c0102b61:	e9 64 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b66 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $72
c0102b68:	6a 48                	push   $0x48
  jmp __alltraps
c0102b6a:	e9 5b fd ff ff       	jmp    c01028ca <__alltraps>

c0102b6f <vector73>:
.globl vector73
vector73:
  pushl $0
c0102b6f:	6a 00                	push   $0x0
  pushl $73
c0102b71:	6a 49                	push   $0x49
  jmp __alltraps
c0102b73:	e9 52 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b78 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102b78:	6a 00                	push   $0x0
  pushl $74
c0102b7a:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102b7c:	e9 49 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b81 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102b81:	6a 00                	push   $0x0
  pushl $75
c0102b83:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102b85:	e9 40 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b8a <vector76>:
.globl vector76
vector76:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $76
c0102b8c:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102b8e:	e9 37 fd ff ff       	jmp    c01028ca <__alltraps>

c0102b93 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102b93:	6a 00                	push   $0x0
  pushl $77
c0102b95:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102b97:	e9 2e fd ff ff       	jmp    c01028ca <__alltraps>

c0102b9c <vector78>:
.globl vector78
vector78:
  pushl $0
c0102b9c:	6a 00                	push   $0x0
  pushl $78
c0102b9e:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102ba0:	e9 25 fd ff ff       	jmp    c01028ca <__alltraps>

c0102ba5 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102ba5:	6a 00                	push   $0x0
  pushl $79
c0102ba7:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102ba9:	e9 1c fd ff ff       	jmp    c01028ca <__alltraps>

c0102bae <vector80>:
.globl vector80
vector80:
  pushl $0
c0102bae:	6a 00                	push   $0x0
  pushl $80
c0102bb0:	6a 50                	push   $0x50
  jmp __alltraps
c0102bb2:	e9 13 fd ff ff       	jmp    c01028ca <__alltraps>

c0102bb7 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102bb7:	6a 00                	push   $0x0
  pushl $81
c0102bb9:	6a 51                	push   $0x51
  jmp __alltraps
c0102bbb:	e9 0a fd ff ff       	jmp    c01028ca <__alltraps>

c0102bc0 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102bc0:	6a 00                	push   $0x0
  pushl $82
c0102bc2:	6a 52                	push   $0x52
  jmp __alltraps
c0102bc4:	e9 01 fd ff ff       	jmp    c01028ca <__alltraps>

c0102bc9 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102bc9:	6a 00                	push   $0x0
  pushl $83
c0102bcb:	6a 53                	push   $0x53
  jmp __alltraps
c0102bcd:	e9 f8 fc ff ff       	jmp    c01028ca <__alltraps>

c0102bd2 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102bd2:	6a 00                	push   $0x0
  pushl $84
c0102bd4:	6a 54                	push   $0x54
  jmp __alltraps
c0102bd6:	e9 ef fc ff ff       	jmp    c01028ca <__alltraps>

c0102bdb <vector85>:
.globl vector85
vector85:
  pushl $0
c0102bdb:	6a 00                	push   $0x0
  pushl $85
c0102bdd:	6a 55                	push   $0x55
  jmp __alltraps
c0102bdf:	e9 e6 fc ff ff       	jmp    c01028ca <__alltraps>

c0102be4 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102be4:	6a 00                	push   $0x0
  pushl $86
c0102be6:	6a 56                	push   $0x56
  jmp __alltraps
c0102be8:	e9 dd fc ff ff       	jmp    c01028ca <__alltraps>

c0102bed <vector87>:
.globl vector87
vector87:
  pushl $0
c0102bed:	6a 00                	push   $0x0
  pushl $87
c0102bef:	6a 57                	push   $0x57
  jmp __alltraps
c0102bf1:	e9 d4 fc ff ff       	jmp    c01028ca <__alltraps>

c0102bf6 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102bf6:	6a 00                	push   $0x0
  pushl $88
c0102bf8:	6a 58                	push   $0x58
  jmp __alltraps
c0102bfa:	e9 cb fc ff ff       	jmp    c01028ca <__alltraps>

c0102bff <vector89>:
.globl vector89
vector89:
  pushl $0
c0102bff:	6a 00                	push   $0x0
  pushl $89
c0102c01:	6a 59                	push   $0x59
  jmp __alltraps
c0102c03:	e9 c2 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c08 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102c08:	6a 00                	push   $0x0
  pushl $90
c0102c0a:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102c0c:	e9 b9 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c11 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $91
c0102c13:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102c15:	e9 b0 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c1a <vector92>:
.globl vector92
vector92:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $92
c0102c1c:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102c1e:	e9 a7 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c23 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $93
c0102c25:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102c27:	e9 9e fc ff ff       	jmp    c01028ca <__alltraps>

c0102c2c <vector94>:
.globl vector94
vector94:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $94
c0102c2e:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102c30:	e9 95 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c35 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $95
c0102c37:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102c39:	e9 8c fc ff ff       	jmp    c01028ca <__alltraps>

c0102c3e <vector96>:
.globl vector96
vector96:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $96
c0102c40:	6a 60                	push   $0x60
  jmp __alltraps
c0102c42:	e9 83 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c47 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $97
c0102c49:	6a 61                	push   $0x61
  jmp __alltraps
c0102c4b:	e9 7a fc ff ff       	jmp    c01028ca <__alltraps>

c0102c50 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $98
c0102c52:	6a 62                	push   $0x62
  jmp __alltraps
c0102c54:	e9 71 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c59 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $99
c0102c5b:	6a 63                	push   $0x63
  jmp __alltraps
c0102c5d:	e9 68 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c62 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $100
c0102c64:	6a 64                	push   $0x64
  jmp __alltraps
c0102c66:	e9 5f fc ff ff       	jmp    c01028ca <__alltraps>

c0102c6b <vector101>:
.globl vector101
vector101:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $101
c0102c6d:	6a 65                	push   $0x65
  jmp __alltraps
c0102c6f:	e9 56 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c74 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $102
c0102c76:	6a 66                	push   $0x66
  jmp __alltraps
c0102c78:	e9 4d fc ff ff       	jmp    c01028ca <__alltraps>

c0102c7d <vector103>:
.globl vector103
vector103:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $103
c0102c7f:	6a 67                	push   $0x67
  jmp __alltraps
c0102c81:	e9 44 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c86 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $104
c0102c88:	6a 68                	push   $0x68
  jmp __alltraps
c0102c8a:	e9 3b fc ff ff       	jmp    c01028ca <__alltraps>

c0102c8f <vector105>:
.globl vector105
vector105:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $105
c0102c91:	6a 69                	push   $0x69
  jmp __alltraps
c0102c93:	e9 32 fc ff ff       	jmp    c01028ca <__alltraps>

c0102c98 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $106
c0102c9a:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102c9c:	e9 29 fc ff ff       	jmp    c01028ca <__alltraps>

c0102ca1 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $107
c0102ca3:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102ca5:	e9 20 fc ff ff       	jmp    c01028ca <__alltraps>

c0102caa <vector108>:
.globl vector108
vector108:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $108
c0102cac:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102cae:	e9 17 fc ff ff       	jmp    c01028ca <__alltraps>

c0102cb3 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $109
c0102cb5:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102cb7:	e9 0e fc ff ff       	jmp    c01028ca <__alltraps>

c0102cbc <vector110>:
.globl vector110
vector110:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $110
c0102cbe:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102cc0:	e9 05 fc ff ff       	jmp    c01028ca <__alltraps>

c0102cc5 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $111
c0102cc7:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102cc9:	e9 fc fb ff ff       	jmp    c01028ca <__alltraps>

c0102cce <vector112>:
.globl vector112
vector112:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $112
c0102cd0:	6a 70                	push   $0x70
  jmp __alltraps
c0102cd2:	e9 f3 fb ff ff       	jmp    c01028ca <__alltraps>

c0102cd7 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102cd7:	6a 00                	push   $0x0
  pushl $113
c0102cd9:	6a 71                	push   $0x71
  jmp __alltraps
c0102cdb:	e9 ea fb ff ff       	jmp    c01028ca <__alltraps>

c0102ce0 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102ce0:	6a 00                	push   $0x0
  pushl $114
c0102ce2:	6a 72                	push   $0x72
  jmp __alltraps
c0102ce4:	e9 e1 fb ff ff       	jmp    c01028ca <__alltraps>

c0102ce9 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $115
c0102ceb:	6a 73                	push   $0x73
  jmp __alltraps
c0102ced:	e9 d8 fb ff ff       	jmp    c01028ca <__alltraps>

c0102cf2 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $116
c0102cf4:	6a 74                	push   $0x74
  jmp __alltraps
c0102cf6:	e9 cf fb ff ff       	jmp    c01028ca <__alltraps>

c0102cfb <vector117>:
.globl vector117
vector117:
  pushl $0
c0102cfb:	6a 00                	push   $0x0
  pushl $117
c0102cfd:	6a 75                	push   $0x75
  jmp __alltraps
c0102cff:	e9 c6 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d04 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102d04:	6a 00                	push   $0x0
  pushl $118
c0102d06:	6a 76                	push   $0x76
  jmp __alltraps
c0102d08:	e9 bd fb ff ff       	jmp    c01028ca <__alltraps>

c0102d0d <vector119>:
.globl vector119
vector119:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $119
c0102d0f:	6a 77                	push   $0x77
  jmp __alltraps
c0102d11:	e9 b4 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d16 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $120
c0102d18:	6a 78                	push   $0x78
  jmp __alltraps
c0102d1a:	e9 ab fb ff ff       	jmp    c01028ca <__alltraps>

c0102d1f <vector121>:
.globl vector121
vector121:
  pushl $0
c0102d1f:	6a 00                	push   $0x0
  pushl $121
c0102d21:	6a 79                	push   $0x79
  jmp __alltraps
c0102d23:	e9 a2 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d28 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102d28:	6a 00                	push   $0x0
  pushl $122
c0102d2a:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102d2c:	e9 99 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d31 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $123
c0102d33:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102d35:	e9 90 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d3a <vector124>:
.globl vector124
vector124:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $124
c0102d3c:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102d3e:	e9 87 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d43 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102d43:	6a 00                	push   $0x0
  pushl $125
c0102d45:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102d47:	e9 7e fb ff ff       	jmp    c01028ca <__alltraps>

c0102d4c <vector126>:
.globl vector126
vector126:
  pushl $0
c0102d4c:	6a 00                	push   $0x0
  pushl $126
c0102d4e:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102d50:	e9 75 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d55 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $127
c0102d57:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102d59:	e9 6c fb ff ff       	jmp    c01028ca <__alltraps>

c0102d5e <vector128>:
.globl vector128
vector128:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $128
c0102d60:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102d65:	e9 60 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d6a <vector129>:
.globl vector129
vector129:
  pushl $0
c0102d6a:	6a 00                	push   $0x0
  pushl $129
c0102d6c:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102d71:	e9 54 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d76 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102d76:	6a 00                	push   $0x0
  pushl $130
c0102d78:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102d7d:	e9 48 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d82 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $131
c0102d84:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102d89:	e9 3c fb ff ff       	jmp    c01028ca <__alltraps>

c0102d8e <vector132>:
.globl vector132
vector132:
  pushl $0
c0102d8e:	6a 00                	push   $0x0
  pushl $132
c0102d90:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102d95:	e9 30 fb ff ff       	jmp    c01028ca <__alltraps>

c0102d9a <vector133>:
.globl vector133
vector133:
  pushl $0
c0102d9a:	6a 00                	push   $0x0
  pushl $133
c0102d9c:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102da1:	e9 24 fb ff ff       	jmp    c01028ca <__alltraps>

c0102da6 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $134
c0102da8:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102dad:	e9 18 fb ff ff       	jmp    c01028ca <__alltraps>

c0102db2 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102db2:	6a 00                	push   $0x0
  pushl $135
c0102db4:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102db9:	e9 0c fb ff ff       	jmp    c01028ca <__alltraps>

c0102dbe <vector136>:
.globl vector136
vector136:
  pushl $0
c0102dbe:	6a 00                	push   $0x0
  pushl $136
c0102dc0:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102dc5:	e9 00 fb ff ff       	jmp    c01028ca <__alltraps>

c0102dca <vector137>:
.globl vector137
vector137:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $137
c0102dcc:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102dd1:	e9 f4 fa ff ff       	jmp    c01028ca <__alltraps>

c0102dd6 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102dd6:	6a 00                	push   $0x0
  pushl $138
c0102dd8:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102ddd:	e9 e8 fa ff ff       	jmp    c01028ca <__alltraps>

c0102de2 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102de2:	6a 00                	push   $0x0
  pushl $139
c0102de4:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102de9:	e9 dc fa ff ff       	jmp    c01028ca <__alltraps>

c0102dee <vector140>:
.globl vector140
vector140:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $140
c0102df0:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102df5:	e9 d0 fa ff ff       	jmp    c01028ca <__alltraps>

c0102dfa <vector141>:
.globl vector141
vector141:
  pushl $0
c0102dfa:	6a 00                	push   $0x0
  pushl $141
c0102dfc:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102e01:	e9 c4 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e06 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102e06:	6a 00                	push   $0x0
  pushl $142
c0102e08:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102e0d:	e9 b8 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e12 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $143
c0102e14:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102e19:	e9 ac fa ff ff       	jmp    c01028ca <__alltraps>

c0102e1e <vector144>:
.globl vector144
vector144:
  pushl $0
c0102e1e:	6a 00                	push   $0x0
  pushl $144
c0102e20:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102e25:	e9 a0 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e2a <vector145>:
.globl vector145
vector145:
  pushl $0
c0102e2a:	6a 00                	push   $0x0
  pushl $145
c0102e2c:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102e31:	e9 94 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e36 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $146
c0102e38:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102e3d:	e9 88 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e42 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102e42:	6a 00                	push   $0x0
  pushl $147
c0102e44:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102e49:	e9 7c fa ff ff       	jmp    c01028ca <__alltraps>

c0102e4e <vector148>:
.globl vector148
vector148:
  pushl $0
c0102e4e:	6a 00                	push   $0x0
  pushl $148
c0102e50:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102e55:	e9 70 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e5a <vector149>:
.globl vector149
vector149:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $149
c0102e5c:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102e61:	e9 64 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e66 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102e66:	6a 00                	push   $0x0
  pushl $150
c0102e68:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102e6d:	e9 58 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e72 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102e72:	6a 00                	push   $0x0
  pushl $151
c0102e74:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102e79:	e9 4c fa ff ff       	jmp    c01028ca <__alltraps>

c0102e7e <vector152>:
.globl vector152
vector152:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $152
c0102e80:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102e85:	e9 40 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e8a <vector153>:
.globl vector153
vector153:
  pushl $0
c0102e8a:	6a 00                	push   $0x0
  pushl $153
c0102e8c:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102e91:	e9 34 fa ff ff       	jmp    c01028ca <__alltraps>

c0102e96 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102e96:	6a 00                	push   $0x0
  pushl $154
c0102e98:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102e9d:	e9 28 fa ff ff       	jmp    c01028ca <__alltraps>

c0102ea2 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $155
c0102ea4:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102ea9:	e9 1c fa ff ff       	jmp    c01028ca <__alltraps>

c0102eae <vector156>:
.globl vector156
vector156:
  pushl $0
c0102eae:	6a 00                	push   $0x0
  pushl $156
c0102eb0:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102eb5:	e9 10 fa ff ff       	jmp    c01028ca <__alltraps>

c0102eba <vector157>:
.globl vector157
vector157:
  pushl $0
c0102eba:	6a 00                	push   $0x0
  pushl $157
c0102ebc:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102ec1:	e9 04 fa ff ff       	jmp    c01028ca <__alltraps>

c0102ec6 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102ec6:	6a 00                	push   $0x0
  pushl $158
c0102ec8:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102ecd:	e9 f8 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102ed2 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102ed2:	6a 00                	push   $0x0
  pushl $159
c0102ed4:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102ed9:	e9 ec f9 ff ff       	jmp    c01028ca <__alltraps>

c0102ede <vector160>:
.globl vector160
vector160:
  pushl $0
c0102ede:	6a 00                	push   $0x0
  pushl $160
c0102ee0:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102ee5:	e9 e0 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102eea <vector161>:
.globl vector161
vector161:
  pushl $0
c0102eea:	6a 00                	push   $0x0
  pushl $161
c0102eec:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102ef1:	e9 d4 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102ef6 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102ef6:	6a 00                	push   $0x0
  pushl $162
c0102ef8:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102efd:	e9 c8 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f02 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102f02:	6a 00                	push   $0x0
  pushl $163
c0102f04:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102f09:	e9 bc f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f0e <vector164>:
.globl vector164
vector164:
  pushl $0
c0102f0e:	6a 00                	push   $0x0
  pushl $164
c0102f10:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102f15:	e9 b0 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f1a <vector165>:
.globl vector165
vector165:
  pushl $0
c0102f1a:	6a 00                	push   $0x0
  pushl $165
c0102f1c:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102f21:	e9 a4 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f26 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102f26:	6a 00                	push   $0x0
  pushl $166
c0102f28:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102f2d:	e9 98 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f32 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102f32:	6a 00                	push   $0x0
  pushl $167
c0102f34:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102f39:	e9 8c f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f3e <vector168>:
.globl vector168
vector168:
  pushl $0
c0102f3e:	6a 00                	push   $0x0
  pushl $168
c0102f40:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102f45:	e9 80 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f4a <vector169>:
.globl vector169
vector169:
  pushl $0
c0102f4a:	6a 00                	push   $0x0
  pushl $169
c0102f4c:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102f51:	e9 74 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f56 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102f56:	6a 00                	push   $0x0
  pushl $170
c0102f58:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102f5d:	e9 68 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f62 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102f62:	6a 00                	push   $0x0
  pushl $171
c0102f64:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102f69:	e9 5c f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f6e <vector172>:
.globl vector172
vector172:
  pushl $0
c0102f6e:	6a 00                	push   $0x0
  pushl $172
c0102f70:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102f75:	e9 50 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f7a <vector173>:
.globl vector173
vector173:
  pushl $0
c0102f7a:	6a 00                	push   $0x0
  pushl $173
c0102f7c:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102f81:	e9 44 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f86 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102f86:	6a 00                	push   $0x0
  pushl $174
c0102f88:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102f8d:	e9 38 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f92 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102f92:	6a 00                	push   $0x0
  pushl $175
c0102f94:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102f99:	e9 2c f9 ff ff       	jmp    c01028ca <__alltraps>

c0102f9e <vector176>:
.globl vector176
vector176:
  pushl $0
c0102f9e:	6a 00                	push   $0x0
  pushl $176
c0102fa0:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102fa5:	e9 20 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102faa <vector177>:
.globl vector177
vector177:
  pushl $0
c0102faa:	6a 00                	push   $0x0
  pushl $177
c0102fac:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102fb1:	e9 14 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102fb6 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102fb6:	6a 00                	push   $0x0
  pushl $178
c0102fb8:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102fbd:	e9 08 f9 ff ff       	jmp    c01028ca <__alltraps>

c0102fc2 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102fc2:	6a 00                	push   $0x0
  pushl $179
c0102fc4:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102fc9:	e9 fc f8 ff ff       	jmp    c01028ca <__alltraps>

c0102fce <vector180>:
.globl vector180
vector180:
  pushl $0
c0102fce:	6a 00                	push   $0x0
  pushl $180
c0102fd0:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102fd5:	e9 f0 f8 ff ff       	jmp    c01028ca <__alltraps>

c0102fda <vector181>:
.globl vector181
vector181:
  pushl $0
c0102fda:	6a 00                	push   $0x0
  pushl $181
c0102fdc:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102fe1:	e9 e4 f8 ff ff       	jmp    c01028ca <__alltraps>

c0102fe6 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102fe6:	6a 00                	push   $0x0
  pushl $182
c0102fe8:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102fed:	e9 d8 f8 ff ff       	jmp    c01028ca <__alltraps>

c0102ff2 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102ff2:	6a 00                	push   $0x0
  pushl $183
c0102ff4:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102ff9:	e9 cc f8 ff ff       	jmp    c01028ca <__alltraps>

c0102ffe <vector184>:
.globl vector184
vector184:
  pushl $0
c0102ffe:	6a 00                	push   $0x0
  pushl $184
c0103000:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103005:	e9 c0 f8 ff ff       	jmp    c01028ca <__alltraps>

c010300a <vector185>:
.globl vector185
vector185:
  pushl $0
c010300a:	6a 00                	push   $0x0
  pushl $185
c010300c:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103011:	e9 b4 f8 ff ff       	jmp    c01028ca <__alltraps>

c0103016 <vector186>:
.globl vector186
vector186:
  pushl $0
c0103016:	6a 00                	push   $0x0
  pushl $186
c0103018:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010301d:	e9 a8 f8 ff ff       	jmp    c01028ca <__alltraps>

c0103022 <vector187>:
.globl vector187
vector187:
  pushl $0
c0103022:	6a 00                	push   $0x0
  pushl $187
c0103024:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0103029:	e9 9c f8 ff ff       	jmp    c01028ca <__alltraps>

c010302e <vector188>:
.globl vector188
vector188:
  pushl $0
c010302e:	6a 00                	push   $0x0
  pushl $188
c0103030:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0103035:	e9 90 f8 ff ff       	jmp    c01028ca <__alltraps>

c010303a <vector189>:
.globl vector189
vector189:
  pushl $0
c010303a:	6a 00                	push   $0x0
  pushl $189
c010303c:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0103041:	e9 84 f8 ff ff       	jmp    c01028ca <__alltraps>

c0103046 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103046:	6a 00                	push   $0x0
  pushl $190
c0103048:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010304d:	e9 78 f8 ff ff       	jmp    c01028ca <__alltraps>

c0103052 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103052:	6a 00                	push   $0x0
  pushl $191
c0103054:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0103059:	e9 6c f8 ff ff       	jmp    c01028ca <__alltraps>

c010305e <vector192>:
.globl vector192
vector192:
  pushl $0
c010305e:	6a 00                	push   $0x0
  pushl $192
c0103060:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103065:	e9 60 f8 ff ff       	jmp    c01028ca <__alltraps>

c010306a <vector193>:
.globl vector193
vector193:
  pushl $0
c010306a:	6a 00                	push   $0x0
  pushl $193
c010306c:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103071:	e9 54 f8 ff ff       	jmp    c01028ca <__alltraps>

c0103076 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103076:	6a 00                	push   $0x0
  pushl $194
c0103078:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010307d:	e9 48 f8 ff ff       	jmp    c01028ca <__alltraps>

c0103082 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103082:	6a 00                	push   $0x0
  pushl $195
c0103084:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103089:	e9 3c f8 ff ff       	jmp    c01028ca <__alltraps>

c010308e <vector196>:
.globl vector196
vector196:
  pushl $0
c010308e:	6a 00                	push   $0x0
  pushl $196
c0103090:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103095:	e9 30 f8 ff ff       	jmp    c01028ca <__alltraps>

c010309a <vector197>:
.globl vector197
vector197:
  pushl $0
c010309a:	6a 00                	push   $0x0
  pushl $197
c010309c:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01030a1:	e9 24 f8 ff ff       	jmp    c01028ca <__alltraps>

c01030a6 <vector198>:
.globl vector198
vector198:
  pushl $0
c01030a6:	6a 00                	push   $0x0
  pushl $198
c01030a8:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01030ad:	e9 18 f8 ff ff       	jmp    c01028ca <__alltraps>

c01030b2 <vector199>:
.globl vector199
vector199:
  pushl $0
c01030b2:	6a 00                	push   $0x0
  pushl $199
c01030b4:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01030b9:	e9 0c f8 ff ff       	jmp    c01028ca <__alltraps>

c01030be <vector200>:
.globl vector200
vector200:
  pushl $0
c01030be:	6a 00                	push   $0x0
  pushl $200
c01030c0:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01030c5:	e9 00 f8 ff ff       	jmp    c01028ca <__alltraps>

c01030ca <vector201>:
.globl vector201
vector201:
  pushl $0
c01030ca:	6a 00                	push   $0x0
  pushl $201
c01030cc:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01030d1:	e9 f4 f7 ff ff       	jmp    c01028ca <__alltraps>

c01030d6 <vector202>:
.globl vector202
vector202:
  pushl $0
c01030d6:	6a 00                	push   $0x0
  pushl $202
c01030d8:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01030dd:	e9 e8 f7 ff ff       	jmp    c01028ca <__alltraps>

c01030e2 <vector203>:
.globl vector203
vector203:
  pushl $0
c01030e2:	6a 00                	push   $0x0
  pushl $203
c01030e4:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01030e9:	e9 dc f7 ff ff       	jmp    c01028ca <__alltraps>

c01030ee <vector204>:
.globl vector204
vector204:
  pushl $0
c01030ee:	6a 00                	push   $0x0
  pushl $204
c01030f0:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01030f5:	e9 d0 f7 ff ff       	jmp    c01028ca <__alltraps>

c01030fa <vector205>:
.globl vector205
vector205:
  pushl $0
c01030fa:	6a 00                	push   $0x0
  pushl $205
c01030fc:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103101:	e9 c4 f7 ff ff       	jmp    c01028ca <__alltraps>

c0103106 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103106:	6a 00                	push   $0x0
  pushl $206
c0103108:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010310d:	e9 b8 f7 ff ff       	jmp    c01028ca <__alltraps>

c0103112 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103112:	6a 00                	push   $0x0
  pushl $207
c0103114:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0103119:	e9 ac f7 ff ff       	jmp    c01028ca <__alltraps>

c010311e <vector208>:
.globl vector208
vector208:
  pushl $0
c010311e:	6a 00                	push   $0x0
  pushl $208
c0103120:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103125:	e9 a0 f7 ff ff       	jmp    c01028ca <__alltraps>

c010312a <vector209>:
.globl vector209
vector209:
  pushl $0
c010312a:	6a 00                	push   $0x0
  pushl $209
c010312c:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0103131:	e9 94 f7 ff ff       	jmp    c01028ca <__alltraps>

c0103136 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103136:	6a 00                	push   $0x0
  pushl $210
c0103138:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010313d:	e9 88 f7 ff ff       	jmp    c01028ca <__alltraps>

c0103142 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103142:	6a 00                	push   $0x0
  pushl $211
c0103144:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103149:	e9 7c f7 ff ff       	jmp    c01028ca <__alltraps>

c010314e <vector212>:
.globl vector212
vector212:
  pushl $0
c010314e:	6a 00                	push   $0x0
  pushl $212
c0103150:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103155:	e9 70 f7 ff ff       	jmp    c01028ca <__alltraps>

c010315a <vector213>:
.globl vector213
vector213:
  pushl $0
c010315a:	6a 00                	push   $0x0
  pushl $213
c010315c:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103161:	e9 64 f7 ff ff       	jmp    c01028ca <__alltraps>

c0103166 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103166:	6a 00                	push   $0x0
  pushl $214
c0103168:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010316d:	e9 58 f7 ff ff       	jmp    c01028ca <__alltraps>

c0103172 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103172:	6a 00                	push   $0x0
  pushl $215
c0103174:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103179:	e9 4c f7 ff ff       	jmp    c01028ca <__alltraps>

c010317e <vector216>:
.globl vector216
vector216:
  pushl $0
c010317e:	6a 00                	push   $0x0
  pushl $216
c0103180:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103185:	e9 40 f7 ff ff       	jmp    c01028ca <__alltraps>

c010318a <vector217>:
.globl vector217
vector217:
  pushl $0
c010318a:	6a 00                	push   $0x0
  pushl $217
c010318c:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103191:	e9 34 f7 ff ff       	jmp    c01028ca <__alltraps>

c0103196 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103196:	6a 00                	push   $0x0
  pushl $218
c0103198:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010319d:	e9 28 f7 ff ff       	jmp    c01028ca <__alltraps>

c01031a2 <vector219>:
.globl vector219
vector219:
  pushl $0
c01031a2:	6a 00                	push   $0x0
  pushl $219
c01031a4:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01031a9:	e9 1c f7 ff ff       	jmp    c01028ca <__alltraps>

c01031ae <vector220>:
.globl vector220
vector220:
  pushl $0
c01031ae:	6a 00                	push   $0x0
  pushl $220
c01031b0:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01031b5:	e9 10 f7 ff ff       	jmp    c01028ca <__alltraps>

c01031ba <vector221>:
.globl vector221
vector221:
  pushl $0
c01031ba:	6a 00                	push   $0x0
  pushl $221
c01031bc:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01031c1:	e9 04 f7 ff ff       	jmp    c01028ca <__alltraps>

c01031c6 <vector222>:
.globl vector222
vector222:
  pushl $0
c01031c6:	6a 00                	push   $0x0
  pushl $222
c01031c8:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01031cd:	e9 f8 f6 ff ff       	jmp    c01028ca <__alltraps>

c01031d2 <vector223>:
.globl vector223
vector223:
  pushl $0
c01031d2:	6a 00                	push   $0x0
  pushl $223
c01031d4:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01031d9:	e9 ec f6 ff ff       	jmp    c01028ca <__alltraps>

c01031de <vector224>:
.globl vector224
vector224:
  pushl $0
c01031de:	6a 00                	push   $0x0
  pushl $224
c01031e0:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01031e5:	e9 e0 f6 ff ff       	jmp    c01028ca <__alltraps>

c01031ea <vector225>:
.globl vector225
vector225:
  pushl $0
c01031ea:	6a 00                	push   $0x0
  pushl $225
c01031ec:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01031f1:	e9 d4 f6 ff ff       	jmp    c01028ca <__alltraps>

c01031f6 <vector226>:
.globl vector226
vector226:
  pushl $0
c01031f6:	6a 00                	push   $0x0
  pushl $226
c01031f8:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01031fd:	e9 c8 f6 ff ff       	jmp    c01028ca <__alltraps>

c0103202 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103202:	6a 00                	push   $0x0
  pushl $227
c0103204:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103209:	e9 bc f6 ff ff       	jmp    c01028ca <__alltraps>

c010320e <vector228>:
.globl vector228
vector228:
  pushl $0
c010320e:	6a 00                	push   $0x0
  pushl $228
c0103210:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103215:	e9 b0 f6 ff ff       	jmp    c01028ca <__alltraps>

c010321a <vector229>:
.globl vector229
vector229:
  pushl $0
c010321a:	6a 00                	push   $0x0
  pushl $229
c010321c:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103221:	e9 a4 f6 ff ff       	jmp    c01028ca <__alltraps>

c0103226 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103226:	6a 00                	push   $0x0
  pushl $230
c0103228:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010322d:	e9 98 f6 ff ff       	jmp    c01028ca <__alltraps>

c0103232 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103232:	6a 00                	push   $0x0
  pushl $231
c0103234:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103239:	e9 8c f6 ff ff       	jmp    c01028ca <__alltraps>

c010323e <vector232>:
.globl vector232
vector232:
  pushl $0
c010323e:	6a 00                	push   $0x0
  pushl $232
c0103240:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103245:	e9 80 f6 ff ff       	jmp    c01028ca <__alltraps>

c010324a <vector233>:
.globl vector233
vector233:
  pushl $0
c010324a:	6a 00                	push   $0x0
  pushl $233
c010324c:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103251:	e9 74 f6 ff ff       	jmp    c01028ca <__alltraps>

c0103256 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103256:	6a 00                	push   $0x0
  pushl $234
c0103258:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010325d:	e9 68 f6 ff ff       	jmp    c01028ca <__alltraps>

c0103262 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103262:	6a 00                	push   $0x0
  pushl $235
c0103264:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103269:	e9 5c f6 ff ff       	jmp    c01028ca <__alltraps>

c010326e <vector236>:
.globl vector236
vector236:
  pushl $0
c010326e:	6a 00                	push   $0x0
  pushl $236
c0103270:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103275:	e9 50 f6 ff ff       	jmp    c01028ca <__alltraps>

c010327a <vector237>:
.globl vector237
vector237:
  pushl $0
c010327a:	6a 00                	push   $0x0
  pushl $237
c010327c:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103281:	e9 44 f6 ff ff       	jmp    c01028ca <__alltraps>

c0103286 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103286:	6a 00                	push   $0x0
  pushl $238
c0103288:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010328d:	e9 38 f6 ff ff       	jmp    c01028ca <__alltraps>

c0103292 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103292:	6a 00                	push   $0x0
  pushl $239
c0103294:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103299:	e9 2c f6 ff ff       	jmp    c01028ca <__alltraps>

c010329e <vector240>:
.globl vector240
vector240:
  pushl $0
c010329e:	6a 00                	push   $0x0
  pushl $240
c01032a0:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01032a5:	e9 20 f6 ff ff       	jmp    c01028ca <__alltraps>

c01032aa <vector241>:
.globl vector241
vector241:
  pushl $0
c01032aa:	6a 00                	push   $0x0
  pushl $241
c01032ac:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01032b1:	e9 14 f6 ff ff       	jmp    c01028ca <__alltraps>

c01032b6 <vector242>:
.globl vector242
vector242:
  pushl $0
c01032b6:	6a 00                	push   $0x0
  pushl $242
c01032b8:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01032bd:	e9 08 f6 ff ff       	jmp    c01028ca <__alltraps>

c01032c2 <vector243>:
.globl vector243
vector243:
  pushl $0
c01032c2:	6a 00                	push   $0x0
  pushl $243
c01032c4:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01032c9:	e9 fc f5 ff ff       	jmp    c01028ca <__alltraps>

c01032ce <vector244>:
.globl vector244
vector244:
  pushl $0
c01032ce:	6a 00                	push   $0x0
  pushl $244
c01032d0:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01032d5:	e9 f0 f5 ff ff       	jmp    c01028ca <__alltraps>

c01032da <vector245>:
.globl vector245
vector245:
  pushl $0
c01032da:	6a 00                	push   $0x0
  pushl $245
c01032dc:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01032e1:	e9 e4 f5 ff ff       	jmp    c01028ca <__alltraps>

c01032e6 <vector246>:
.globl vector246
vector246:
  pushl $0
c01032e6:	6a 00                	push   $0x0
  pushl $246
c01032e8:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01032ed:	e9 d8 f5 ff ff       	jmp    c01028ca <__alltraps>

c01032f2 <vector247>:
.globl vector247
vector247:
  pushl $0
c01032f2:	6a 00                	push   $0x0
  pushl $247
c01032f4:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01032f9:	e9 cc f5 ff ff       	jmp    c01028ca <__alltraps>

c01032fe <vector248>:
.globl vector248
vector248:
  pushl $0
c01032fe:	6a 00                	push   $0x0
  pushl $248
c0103300:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103305:	e9 c0 f5 ff ff       	jmp    c01028ca <__alltraps>

c010330a <vector249>:
.globl vector249
vector249:
  pushl $0
c010330a:	6a 00                	push   $0x0
  pushl $249
c010330c:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103311:	e9 b4 f5 ff ff       	jmp    c01028ca <__alltraps>

c0103316 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103316:	6a 00                	push   $0x0
  pushl $250
c0103318:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010331d:	e9 a8 f5 ff ff       	jmp    c01028ca <__alltraps>

c0103322 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103322:	6a 00                	push   $0x0
  pushl $251
c0103324:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103329:	e9 9c f5 ff ff       	jmp    c01028ca <__alltraps>

c010332e <vector252>:
.globl vector252
vector252:
  pushl $0
c010332e:	6a 00                	push   $0x0
  pushl $252
c0103330:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103335:	e9 90 f5 ff ff       	jmp    c01028ca <__alltraps>

c010333a <vector253>:
.globl vector253
vector253:
  pushl $0
c010333a:	6a 00                	push   $0x0
  pushl $253
c010333c:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103341:	e9 84 f5 ff ff       	jmp    c01028ca <__alltraps>

c0103346 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103346:	6a 00                	push   $0x0
  pushl $254
c0103348:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010334d:	e9 78 f5 ff ff       	jmp    c01028ca <__alltraps>

c0103352 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103352:	6a 00                	push   $0x0
  pushl $255
c0103354:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103359:	e9 6c f5 ff ff       	jmp    c01028ca <__alltraps>

c010335e <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010335e:	55                   	push   %ebp
c010335f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103361:	8b 55 08             	mov    0x8(%ebp),%edx
c0103364:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c0103369:	29 c2                	sub    %eax,%edx
c010336b:	89 d0                	mov    %edx,%eax
c010336d:	c1 f8 05             	sar    $0x5,%eax
}
c0103370:	5d                   	pop    %ebp
c0103371:	c3                   	ret    

c0103372 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103372:	55                   	push   %ebp
c0103373:	89 e5                	mov    %esp,%ebp
c0103375:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103378:	8b 45 08             	mov    0x8(%ebp),%eax
c010337b:	89 04 24             	mov    %eax,(%esp)
c010337e:	e8 db ff ff ff       	call   c010335e <page2ppn>
c0103383:	c1 e0 0c             	shl    $0xc,%eax
}
c0103386:	c9                   	leave  
c0103387:	c3                   	ret    

c0103388 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103388:	55                   	push   %ebp
c0103389:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010338b:	8b 45 08             	mov    0x8(%ebp),%eax
c010338e:	8b 00                	mov    (%eax),%eax
}
c0103390:	5d                   	pop    %ebp
c0103391:	c3                   	ret    

c0103392 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103392:	55                   	push   %ebp
c0103393:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103395:	8b 45 08             	mov    0x8(%ebp),%eax
c0103398:	8b 55 0c             	mov    0xc(%ebp),%edx
c010339b:	89 10                	mov    %edx,(%eax)
}
c010339d:	5d                   	pop    %ebp
c010339e:	c3                   	ret    

c010339f <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010339f:	55                   	push   %ebp
c01033a0:	89 e5                	mov    %esp,%ebp
c01033a2:	83 ec 10             	sub    $0x10,%esp
c01033a5:	c7 45 fc 90 40 12 c0 	movl   $0xc0124090,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01033ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033af:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01033b2:	89 50 04             	mov    %edx,0x4(%eax)
c01033b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033b8:	8b 50 04             	mov    0x4(%eax),%edx
c01033bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033be:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01033c0:	c7 05 98 40 12 c0 00 	movl   $0x0,0xc0124098
c01033c7:	00 00 00 
}
c01033ca:	c9                   	leave  
c01033cb:	c3                   	ret    

c01033cc <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01033cc:	55                   	push   %ebp
c01033cd:	89 e5                	mov    %esp,%ebp
c01033cf:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01033d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01033d6:	75 24                	jne    c01033fc <default_init_memmap+0x30>
c01033d8:	c7 44 24 0c f0 99 10 	movl   $0xc01099f0,0xc(%esp)
c01033df:	c0 
c01033e0:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01033e7:	c0 
c01033e8:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01033ef:	00 
c01033f0:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01033f7:	e8 ef d8 ff ff       	call   c0100ceb <__panic>
    struct Page *p = base;
c01033fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01033ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103402:	eb 7d                	jmp    c0103481 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0103404:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103407:	83 c0 04             	add    $0x4,%eax
c010340a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103411:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103414:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103417:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010341a:	0f a3 10             	bt     %edx,(%eax)
c010341d:	19 c0                	sbb    %eax,%eax
c010341f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103422:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103426:	0f 95 c0             	setne  %al
c0103429:	0f b6 c0             	movzbl %al,%eax
c010342c:	85 c0                	test   %eax,%eax
c010342e:	75 24                	jne    c0103454 <default_init_memmap+0x88>
c0103430:	c7 44 24 0c 21 9a 10 	movl   $0xc0109a21,0xc(%esp)
c0103437:	c0 
c0103438:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010343f:	c0 
c0103440:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103447:	00 
c0103448:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010344f:	e8 97 d8 ff ff       	call   c0100ceb <__panic>
        p->flags = p->property = 0;
c0103454:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103457:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010345e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103461:	8b 50 08             	mov    0x8(%eax),%edx
c0103464:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103467:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010346a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103471:	00 
c0103472:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103475:	89 04 24             	mov    %eax,(%esp)
c0103478:	e8 15 ff ff ff       	call   c0103392 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010347d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103481:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103484:	c1 e0 05             	shl    $0x5,%eax
c0103487:	89 c2                	mov    %eax,%edx
c0103489:	8b 45 08             	mov    0x8(%ebp),%eax
c010348c:	01 d0                	add    %edx,%eax
c010348e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103491:	0f 85 6d ff ff ff    	jne    c0103404 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103497:	8b 45 08             	mov    0x8(%ebp),%eax
c010349a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010349d:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01034a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01034a3:	83 c0 04             	add    $0x4,%eax
c01034a6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01034ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01034b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01034b6:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01034b9:	8b 15 98 40 12 c0    	mov    0xc0124098,%edx
c01034bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034c2:	01 d0                	add    %edx,%eax
c01034c4:	a3 98 40 12 c0       	mov    %eax,0xc0124098
    list_add_before(&free_list, &(base->page_link));
c01034c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01034cc:	83 c0 0c             	add    $0xc,%eax
c01034cf:	c7 45 dc 90 40 12 c0 	movl   $0xc0124090,-0x24(%ebp)
c01034d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01034d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01034dc:	8b 00                	mov    (%eax),%eax
c01034de:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01034e1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01034e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01034e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01034ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01034ed:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01034f3:	89 10                	mov    %edx,(%eax)
c01034f5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034f8:	8b 10                	mov    (%eax),%edx
c01034fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01034fd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103500:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103503:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103506:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103509:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010350c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010350f:	89 10                	mov    %edx,(%eax)
}
c0103511:	c9                   	leave  
c0103512:	c3                   	ret    

c0103513 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0103513:	55                   	push   %ebp
c0103514:	89 e5                	mov    %esp,%ebp
c0103516:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103519:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010351d:	75 24                	jne    c0103543 <default_alloc_pages+0x30>
c010351f:	c7 44 24 0c f0 99 10 	movl   $0xc01099f0,0xc(%esp)
c0103526:	c0 
c0103527:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010352e:	c0 
c010352f:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0103536:	00 
c0103537:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010353e:	e8 a8 d7 ff ff       	call   c0100ceb <__panic>
    if (n > nr_free) {
c0103543:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0103548:	3b 45 08             	cmp    0x8(%ebp),%eax
c010354b:	73 0a                	jae    c0103557 <default_alloc_pages+0x44>
        return NULL;
c010354d:	b8 00 00 00 00       	mov    $0x0,%eax
c0103552:	e9 36 01 00 00       	jmp    c010368d <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c0103557:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010355e:	c7 45 f0 90 40 12 c0 	movl   $0xc0124090,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103565:	eb 1c                	jmp    c0103583 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103567:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010356a:	83 e8 0c             	sub    $0xc,%eax
c010356d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0103570:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103573:	8b 40 08             	mov    0x8(%eax),%eax
c0103576:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103579:	72 08                	jb     c0103583 <default_alloc_pages+0x70>
            page = p;
c010357b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010357e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0103581:	eb 18                	jmp    c010359b <default_alloc_pages+0x88>
c0103583:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103586:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010358c:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010358f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103592:	81 7d f0 90 40 12 c0 	cmpl   $0xc0124090,-0x10(%ebp)
c0103599:	75 cc                	jne    c0103567 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c010359b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010359f:	0f 84 e5 00 00 00    	je     c010368a <default_alloc_pages+0x177>
        if (page->property > n) {
c01035a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a8:	8b 40 08             	mov    0x8(%eax),%eax
c01035ab:	3b 45 08             	cmp    0x8(%ebp),%eax
c01035ae:	0f 86 85 00 00 00    	jbe    c0103639 <default_alloc_pages+0x126>
            struct Page *p = page + n;
c01035b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01035b7:	c1 e0 05             	shl    $0x5,%eax
c01035ba:	89 c2                	mov    %eax,%edx
c01035bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035bf:	01 d0                	add    %edx,%eax
c01035c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
			SetPageProperty(p);
c01035c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035c7:	83 c0 04             	add    $0x4,%eax
c01035ca:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01035d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01035d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01035d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01035da:	0f ab 10             	bts    %edx,(%eax)
            p->property = page->property - n;
c01035dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e0:	8b 40 08             	mov    0x8(%eax),%eax
c01035e3:	2b 45 08             	sub    0x8(%ebp),%eax
c01035e6:	89 c2                	mov    %eax,%edx
c01035e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035eb:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c01035ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035f1:	83 c0 0c             	add    $0xc,%eax
c01035f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035f7:	83 c2 0c             	add    $0xc,%edx
c01035fa:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01035fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103600:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103603:	8b 40 04             	mov    0x4(%eax),%eax
c0103606:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103609:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010360c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010360f:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103612:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103615:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103618:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010361b:	89 10                	mov    %edx,(%eax)
c010361d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103620:	8b 10                	mov    (%eax),%edx
c0103622:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103625:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103628:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010362b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010362e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103631:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103634:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103637:	89 10                	mov    %edx,(%eax)
    }
	list_del(&(page->page_link));
c0103639:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363c:	83 c0 0c             	add    $0xc,%eax
c010363f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103642:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103645:	8b 40 04             	mov    0x4(%eax),%eax
c0103648:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010364b:	8b 12                	mov    (%edx),%edx
c010364d:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0103650:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103653:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103656:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103659:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010365c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010365f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103662:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0103664:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0103669:	2b 45 08             	sub    0x8(%ebp),%eax
c010366c:	a3 98 40 12 c0       	mov    %eax,0xc0124098
        ClearPageProperty(page);
c0103671:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103674:	83 c0 04             	add    $0x4,%eax
c0103677:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010367e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103681:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103684:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103687:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c010368a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010368d:	c9                   	leave  
c010368e:	c3                   	ret    

c010368f <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010368f:	55                   	push   %ebp
c0103690:	89 e5                	mov    %esp,%ebp
c0103692:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0103698:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010369c:	75 24                	jne    c01036c2 <default_free_pages+0x33>
c010369e:	c7 44 24 0c f0 99 10 	movl   $0xc01099f0,0xc(%esp)
c01036a5:	c0 
c01036a6:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01036ad:	c0 
c01036ae:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c01036b5:	00 
c01036b6:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01036bd:	e8 29 d6 ff ff       	call   c0100ceb <__panic>
    struct Page *p = base;
c01036c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01036c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01036c8:	e9 9d 00 00 00       	jmp    c010376a <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01036cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036d0:	83 c0 04             	add    $0x4,%eax
c01036d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01036da:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01036e3:	0f a3 10             	bt     %edx,(%eax)
c01036e6:	19 c0                	sbb    %eax,%eax
c01036e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01036eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01036ef:	0f 95 c0             	setne  %al
c01036f2:	0f b6 c0             	movzbl %al,%eax
c01036f5:	85 c0                	test   %eax,%eax
c01036f7:	75 2c                	jne    c0103725 <default_free_pages+0x96>
c01036f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036fc:	83 c0 04             	add    $0x4,%eax
c01036ff:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0103706:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103709:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010370c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010370f:	0f a3 10             	bt     %edx,(%eax)
c0103712:	19 c0                	sbb    %eax,%eax
c0103714:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0103717:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010371b:	0f 95 c0             	setne  %al
c010371e:	0f b6 c0             	movzbl %al,%eax
c0103721:	85 c0                	test   %eax,%eax
c0103723:	74 24                	je     c0103749 <default_free_pages+0xba>
c0103725:	c7 44 24 0c 34 9a 10 	movl   $0xc0109a34,0xc(%esp)
c010372c:	c0 
c010372d:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103734:	c0 
c0103735:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010373c:	00 
c010373d:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103744:	e8 a2 d5 ff ff       	call   c0100ceb <__panic>
        p->flags = 0;
c0103749:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010374c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103753:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010375a:	00 
c010375b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010375e:	89 04 24             	mov    %eax,(%esp)
c0103761:	e8 2c fc ff ff       	call   c0103392 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103766:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010376a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010376d:	c1 e0 05             	shl    $0x5,%eax
c0103770:	89 c2                	mov    %eax,%edx
c0103772:	8b 45 08             	mov    0x8(%ebp),%eax
c0103775:	01 d0                	add    %edx,%eax
c0103777:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010377a:	0f 85 4d ff ff ff    	jne    c01036cd <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103780:	8b 45 08             	mov    0x8(%ebp),%eax
c0103783:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103786:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103789:	8b 45 08             	mov    0x8(%ebp),%eax
c010378c:	83 c0 04             	add    $0x4,%eax
c010378f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103796:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103799:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010379c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010379f:	0f ab 10             	bts    %edx,(%eax)
c01037a2:	c7 45 cc 90 40 12 c0 	movl   $0xc0124090,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01037a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01037ac:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01037af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01037b2:	e9 fa 00 00 00       	jmp    c01038b1 <default_free_pages+0x222>
        p = le2page(le, page_link);
c01037b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037ba:	83 e8 0c             	sub    $0xc,%eax
c01037bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01037c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037c3:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01037c6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01037c9:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01037cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c01037cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01037d2:	8b 40 08             	mov    0x8(%eax),%eax
c01037d5:	c1 e0 05             	shl    $0x5,%eax
c01037d8:	89 c2                	mov    %eax,%edx
c01037da:	8b 45 08             	mov    0x8(%ebp),%eax
c01037dd:	01 d0                	add    %edx,%eax
c01037df:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01037e2:	75 5a                	jne    c010383e <default_free_pages+0x1af>
            base->property += p->property;
c01037e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e7:	8b 50 08             	mov    0x8(%eax),%edx
c01037ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037ed:	8b 40 08             	mov    0x8(%eax),%eax
c01037f0:	01 c2                	add    %eax,%edx
c01037f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01037f5:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01037f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037fb:	83 c0 04             	add    $0x4,%eax
c01037fe:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103805:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103808:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010380b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010380e:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0103811:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103814:	83 c0 0c             	add    $0xc,%eax
c0103817:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010381a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010381d:	8b 40 04             	mov    0x4(%eax),%eax
c0103820:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103823:	8b 12                	mov    (%edx),%edx
c0103825:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0103828:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010382b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010382e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103831:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103834:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103837:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010383a:	89 10                	mov    %edx,(%eax)
c010383c:	eb 73                	jmp    c01038b1 <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c010383e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103841:	8b 40 08             	mov    0x8(%eax),%eax
c0103844:	c1 e0 05             	shl    $0x5,%eax
c0103847:	89 c2                	mov    %eax,%edx
c0103849:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010384c:	01 d0                	add    %edx,%eax
c010384e:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103851:	75 5e                	jne    c01038b1 <default_free_pages+0x222>
            p->property += base->property;
c0103853:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103856:	8b 50 08             	mov    0x8(%eax),%edx
c0103859:	8b 45 08             	mov    0x8(%ebp),%eax
c010385c:	8b 40 08             	mov    0x8(%eax),%eax
c010385f:	01 c2                	add    %eax,%edx
c0103861:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103864:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103867:	8b 45 08             	mov    0x8(%ebp),%eax
c010386a:	83 c0 04             	add    $0x4,%eax
c010386d:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0103874:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103877:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010387a:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010387d:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0103880:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103883:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103886:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103889:	83 c0 0c             	add    $0xc,%eax
c010388c:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010388f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103892:	8b 40 04             	mov    0x4(%eax),%eax
c0103895:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103898:	8b 12                	mov    (%edx),%edx
c010389a:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010389d:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01038a0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01038a3:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01038a6:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01038a9:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01038ac:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01038af:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c01038b1:	81 7d f0 90 40 12 c0 	cmpl   $0xc0124090,-0x10(%ebp)
c01038b8:	0f 85 f9 fe ff ff    	jne    c01037b7 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c01038be:	8b 15 98 40 12 c0    	mov    0xc0124098,%edx
c01038c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038c7:	01 d0                	add    %edx,%eax
c01038c9:	a3 98 40 12 c0       	mov    %eax,0xc0124098
c01038ce:	c7 45 9c 90 40 12 c0 	movl   $0xc0124090,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01038d5:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01038d8:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c01038db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01038de:	eb 68                	jmp    c0103948 <default_free_pages+0x2b9>
        p = le2page(le, page_link);
c01038e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038e3:	83 e8 0c             	sub    $0xc,%eax
c01038e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c01038e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01038ec:	8b 40 08             	mov    0x8(%eax),%eax
c01038ef:	c1 e0 05             	shl    $0x5,%eax
c01038f2:	89 c2                	mov    %eax,%edx
c01038f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f7:	01 d0                	add    %edx,%eax
c01038f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01038fc:	77 3b                	ja     c0103939 <default_free_pages+0x2aa>
            assert(base + base->property != p);
c01038fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103901:	8b 40 08             	mov    0x8(%eax),%eax
c0103904:	c1 e0 05             	shl    $0x5,%eax
c0103907:	89 c2                	mov    %eax,%edx
c0103909:	8b 45 08             	mov    0x8(%ebp),%eax
c010390c:	01 d0                	add    %edx,%eax
c010390e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103911:	75 24                	jne    c0103937 <default_free_pages+0x2a8>
c0103913:	c7 44 24 0c 59 9a 10 	movl   $0xc0109a59,0xc(%esp)
c010391a:	c0 
c010391b:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103922:	c0 
c0103923:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c010392a:	00 
c010392b:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103932:	e8 b4 d3 ff ff       	call   c0100ceb <__panic>
            break;
c0103937:	eb 18                	jmp    c0103951 <default_free_pages+0x2c2>
c0103939:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010393c:	89 45 98             	mov    %eax,-0x68(%ebp)
c010393f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103942:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0103945:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0103948:	81 7d f0 90 40 12 c0 	cmpl   $0xc0124090,-0x10(%ebp)
c010394f:	75 8f                	jne    c01038e0 <default_free_pages+0x251>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0103951:	8b 45 08             	mov    0x8(%ebp),%eax
c0103954:	8d 50 0c             	lea    0xc(%eax),%edx
c0103957:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010395a:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010395d:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103960:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103963:	8b 00                	mov    (%eax),%eax
c0103965:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103968:	89 55 8c             	mov    %edx,-0x74(%ebp)
c010396b:	89 45 88             	mov    %eax,-0x78(%ebp)
c010396e:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103971:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103974:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103977:	8b 55 8c             	mov    -0x74(%ebp),%edx
c010397a:	89 10                	mov    %edx,(%eax)
c010397c:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010397f:	8b 10                	mov    (%eax),%edx
c0103981:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103984:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103987:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010398a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010398d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103990:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103993:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103996:	89 10                	mov    %edx,(%eax)
}
c0103998:	c9                   	leave  
c0103999:	c3                   	ret    

c010399a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c010399a:	55                   	push   %ebp
c010399b:	89 e5                	mov    %esp,%ebp
    return nr_free;
c010399d:	a1 98 40 12 c0       	mov    0xc0124098,%eax
}
c01039a2:	5d                   	pop    %ebp
c01039a3:	c3                   	ret    

c01039a4 <basic_check>:

static void
basic_check(void) {
c01039a4:	55                   	push   %ebp
c01039a5:	89 e5                	mov    %esp,%ebp
c01039a7:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01039aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01039b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01039bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039c4:	e8 d7 0e 00 00       	call   c01048a0 <alloc_pages>
c01039c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01039d0:	75 24                	jne    c01039f6 <basic_check+0x52>
c01039d2:	c7 44 24 0c 74 9a 10 	movl   $0xc0109a74,0xc(%esp)
c01039d9:	c0 
c01039da:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01039e1:	c0 
c01039e2:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01039e9:	00 
c01039ea:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01039f1:	e8 f5 d2 ff ff       	call   c0100ceb <__panic>
    assert((p1 = alloc_page()) != NULL);
c01039f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039fd:	e8 9e 0e 00 00       	call   c01048a0 <alloc_pages>
c0103a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a09:	75 24                	jne    c0103a2f <basic_check+0x8b>
c0103a0b:	c7 44 24 0c 90 9a 10 	movl   $0xc0109a90,0xc(%esp)
c0103a12:	c0 
c0103a13:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103a1a:	c0 
c0103a1b:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103a22:	00 
c0103a23:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103a2a:	e8 bc d2 ff ff       	call   c0100ceb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103a2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a36:	e8 65 0e 00 00       	call   c01048a0 <alloc_pages>
c0103a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a42:	75 24                	jne    c0103a68 <basic_check+0xc4>
c0103a44:	c7 44 24 0c ac 9a 10 	movl   $0xc0109aac,0xc(%esp)
c0103a4b:	c0 
c0103a4c:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103a53:	c0 
c0103a54:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0103a5b:	00 
c0103a5c:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103a63:	e8 83 d2 ff ff       	call   c0100ceb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103a68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a6b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103a6e:	74 10                	je     c0103a80 <basic_check+0xdc>
c0103a70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a73:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a76:	74 08                	je     c0103a80 <basic_check+0xdc>
c0103a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a7b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a7e:	75 24                	jne    c0103aa4 <basic_check+0x100>
c0103a80:	c7 44 24 0c c8 9a 10 	movl   $0xc0109ac8,0xc(%esp)
c0103a87:	c0 
c0103a88:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103a8f:	c0 
c0103a90:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103a97:	00 
c0103a98:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103a9f:	e8 47 d2 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103aa7:	89 04 24             	mov    %eax,(%esp)
c0103aaa:	e8 d9 f8 ff ff       	call   c0103388 <page_ref>
c0103aaf:	85 c0                	test   %eax,%eax
c0103ab1:	75 1e                	jne    c0103ad1 <basic_check+0x12d>
c0103ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ab6:	89 04 24             	mov    %eax,(%esp)
c0103ab9:	e8 ca f8 ff ff       	call   c0103388 <page_ref>
c0103abe:	85 c0                	test   %eax,%eax
c0103ac0:	75 0f                	jne    c0103ad1 <basic_check+0x12d>
c0103ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ac5:	89 04 24             	mov    %eax,(%esp)
c0103ac8:	e8 bb f8 ff ff       	call   c0103388 <page_ref>
c0103acd:	85 c0                	test   %eax,%eax
c0103acf:	74 24                	je     c0103af5 <basic_check+0x151>
c0103ad1:	c7 44 24 0c ec 9a 10 	movl   $0xc0109aec,0xc(%esp)
c0103ad8:	c0 
c0103ad9:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103ae0:	c0 
c0103ae1:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103ae8:	00 
c0103ae9:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103af0:	e8 f6 d1 ff ff       	call   c0100ceb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103af8:	89 04 24             	mov    %eax,(%esp)
c0103afb:	e8 72 f8 ff ff       	call   c0103372 <page2pa>
c0103b00:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c0103b06:	c1 e2 0c             	shl    $0xc,%edx
c0103b09:	39 d0                	cmp    %edx,%eax
c0103b0b:	72 24                	jb     c0103b31 <basic_check+0x18d>
c0103b0d:	c7 44 24 0c 28 9b 10 	movl   $0xc0109b28,0xc(%esp)
c0103b14:	c0 
c0103b15:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103b1c:	c0 
c0103b1d:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103b24:	00 
c0103b25:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103b2c:	e8 ba d1 ff ff       	call   c0100ceb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b34:	89 04 24             	mov    %eax,(%esp)
c0103b37:	e8 36 f8 ff ff       	call   c0103372 <page2pa>
c0103b3c:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c0103b42:	c1 e2 0c             	shl    $0xc,%edx
c0103b45:	39 d0                	cmp    %edx,%eax
c0103b47:	72 24                	jb     c0103b6d <basic_check+0x1c9>
c0103b49:	c7 44 24 0c 45 9b 10 	movl   $0xc0109b45,0xc(%esp)
c0103b50:	c0 
c0103b51:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103b58:	c0 
c0103b59:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103b60:	00 
c0103b61:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103b68:	e8 7e d1 ff ff       	call   c0100ceb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b70:	89 04 24             	mov    %eax,(%esp)
c0103b73:	e8 fa f7 ff ff       	call   c0103372 <page2pa>
c0103b78:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c0103b7e:	c1 e2 0c             	shl    $0xc,%edx
c0103b81:	39 d0                	cmp    %edx,%eax
c0103b83:	72 24                	jb     c0103ba9 <basic_check+0x205>
c0103b85:	c7 44 24 0c 62 9b 10 	movl   $0xc0109b62,0xc(%esp)
c0103b8c:	c0 
c0103b8d:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103b94:	c0 
c0103b95:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103b9c:	00 
c0103b9d:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103ba4:	e8 42 d1 ff ff       	call   c0100ceb <__panic>

    list_entry_t free_list_store = free_list;
c0103ba9:	a1 90 40 12 c0       	mov    0xc0124090,%eax
c0103bae:	8b 15 94 40 12 c0    	mov    0xc0124094,%edx
c0103bb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103bb7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103bba:	c7 45 e0 90 40 12 c0 	movl   $0xc0124090,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103bc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bc4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103bc7:	89 50 04             	mov    %edx,0x4(%eax)
c0103bca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bcd:	8b 50 04             	mov    0x4(%eax),%edx
c0103bd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bd3:	89 10                	mov    %edx,(%eax)
c0103bd5:	c7 45 dc 90 40 12 c0 	movl   $0xc0124090,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103bdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103bdf:	8b 40 04             	mov    0x4(%eax),%eax
c0103be2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103be5:	0f 94 c0             	sete   %al
c0103be8:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103beb:	85 c0                	test   %eax,%eax
c0103bed:	75 24                	jne    c0103c13 <basic_check+0x26f>
c0103bef:	c7 44 24 0c 7f 9b 10 	movl   $0xc0109b7f,0xc(%esp)
c0103bf6:	c0 
c0103bf7:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103bfe:	c0 
c0103bff:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103c06:	00 
c0103c07:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103c0e:	e8 d8 d0 ff ff       	call   c0100ceb <__panic>

    unsigned int nr_free_store = nr_free;
c0103c13:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0103c18:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103c1b:	c7 05 98 40 12 c0 00 	movl   $0x0,0xc0124098
c0103c22:	00 00 00 

    assert(alloc_page() == NULL);
c0103c25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c2c:	e8 6f 0c 00 00       	call   c01048a0 <alloc_pages>
c0103c31:	85 c0                	test   %eax,%eax
c0103c33:	74 24                	je     c0103c59 <basic_check+0x2b5>
c0103c35:	c7 44 24 0c 96 9b 10 	movl   $0xc0109b96,0xc(%esp)
c0103c3c:	c0 
c0103c3d:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103c44:	c0 
c0103c45:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103c4c:	00 
c0103c4d:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103c54:	e8 92 d0 ff ff       	call   c0100ceb <__panic>

    free_page(p0);
c0103c59:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c60:	00 
c0103c61:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c64:	89 04 24             	mov    %eax,(%esp)
c0103c67:	e8 9f 0c 00 00       	call   c010490b <free_pages>
    free_page(p1);
c0103c6c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c73:	00 
c0103c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c77:	89 04 24             	mov    %eax,(%esp)
c0103c7a:	e8 8c 0c 00 00       	call   c010490b <free_pages>
    free_page(p2);
c0103c7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c86:	00 
c0103c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c8a:	89 04 24             	mov    %eax,(%esp)
c0103c8d:	e8 79 0c 00 00       	call   c010490b <free_pages>
    assert(nr_free == 3);
c0103c92:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0103c97:	83 f8 03             	cmp    $0x3,%eax
c0103c9a:	74 24                	je     c0103cc0 <basic_check+0x31c>
c0103c9c:	c7 44 24 0c ab 9b 10 	movl   $0xc0109bab,0xc(%esp)
c0103ca3:	c0 
c0103ca4:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103cab:	c0 
c0103cac:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103cb3:	00 
c0103cb4:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103cbb:	e8 2b d0 ff ff       	call   c0100ceb <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103cc0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cc7:	e8 d4 0b 00 00       	call   c01048a0 <alloc_pages>
c0103ccc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103ccf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103cd3:	75 24                	jne    c0103cf9 <basic_check+0x355>
c0103cd5:	c7 44 24 0c 74 9a 10 	movl   $0xc0109a74,0xc(%esp)
c0103cdc:	c0 
c0103cdd:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103ce4:	c0 
c0103ce5:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103cec:	00 
c0103ced:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103cf4:	e8 f2 cf ff ff       	call   c0100ceb <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103cf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d00:	e8 9b 0b 00 00       	call   c01048a0 <alloc_pages>
c0103d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d0c:	75 24                	jne    c0103d32 <basic_check+0x38e>
c0103d0e:	c7 44 24 0c 90 9a 10 	movl   $0xc0109a90,0xc(%esp)
c0103d15:	c0 
c0103d16:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103d1d:	c0 
c0103d1e:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103d25:	00 
c0103d26:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103d2d:	e8 b9 cf ff ff       	call   c0100ceb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103d32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d39:	e8 62 0b 00 00       	call   c01048a0 <alloc_pages>
c0103d3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d45:	75 24                	jne    c0103d6b <basic_check+0x3c7>
c0103d47:	c7 44 24 0c ac 9a 10 	movl   $0xc0109aac,0xc(%esp)
c0103d4e:	c0 
c0103d4f:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103d56:	c0 
c0103d57:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103d5e:	00 
c0103d5f:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103d66:	e8 80 cf ff ff       	call   c0100ceb <__panic>

    assert(alloc_page() == NULL);
c0103d6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d72:	e8 29 0b 00 00       	call   c01048a0 <alloc_pages>
c0103d77:	85 c0                	test   %eax,%eax
c0103d79:	74 24                	je     c0103d9f <basic_check+0x3fb>
c0103d7b:	c7 44 24 0c 96 9b 10 	movl   $0xc0109b96,0xc(%esp)
c0103d82:	c0 
c0103d83:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103d8a:	c0 
c0103d8b:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0103d92:	00 
c0103d93:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103d9a:	e8 4c cf ff ff       	call   c0100ceb <__panic>

    free_page(p0);
c0103d9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103da6:	00 
c0103da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103daa:	89 04 24             	mov    %eax,(%esp)
c0103dad:	e8 59 0b 00 00       	call   c010490b <free_pages>
c0103db2:	c7 45 d8 90 40 12 c0 	movl   $0xc0124090,-0x28(%ebp)
c0103db9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103dbc:	8b 40 04             	mov    0x4(%eax),%eax
c0103dbf:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103dc2:	0f 94 c0             	sete   %al
c0103dc5:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103dc8:	85 c0                	test   %eax,%eax
c0103dca:	74 24                	je     c0103df0 <basic_check+0x44c>
c0103dcc:	c7 44 24 0c b8 9b 10 	movl   $0xc0109bb8,0xc(%esp)
c0103dd3:	c0 
c0103dd4:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103ddb:	c0 
c0103ddc:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0103de3:	00 
c0103de4:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103deb:	e8 fb ce ff ff       	call   c0100ceb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103df0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103df7:	e8 a4 0a 00 00       	call   c01048a0 <alloc_pages>
c0103dfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e02:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103e05:	74 24                	je     c0103e2b <basic_check+0x487>
c0103e07:	c7 44 24 0c d0 9b 10 	movl   $0xc0109bd0,0xc(%esp)
c0103e0e:	c0 
c0103e0f:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103e16:	c0 
c0103e17:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0103e1e:	00 
c0103e1f:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103e26:	e8 c0 ce ff ff       	call   c0100ceb <__panic>
    assert(alloc_page() == NULL);
c0103e2b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e32:	e8 69 0a 00 00       	call   c01048a0 <alloc_pages>
c0103e37:	85 c0                	test   %eax,%eax
c0103e39:	74 24                	je     c0103e5f <basic_check+0x4bb>
c0103e3b:	c7 44 24 0c 96 9b 10 	movl   $0xc0109b96,0xc(%esp)
c0103e42:	c0 
c0103e43:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103e4a:	c0 
c0103e4b:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103e52:	00 
c0103e53:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103e5a:	e8 8c ce ff ff       	call   c0100ceb <__panic>

    assert(nr_free == 0);
c0103e5f:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0103e64:	85 c0                	test   %eax,%eax
c0103e66:	74 24                	je     c0103e8c <basic_check+0x4e8>
c0103e68:	c7 44 24 0c e9 9b 10 	movl   $0xc0109be9,0xc(%esp)
c0103e6f:	c0 
c0103e70:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103e77:	c0 
c0103e78:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0103e7f:	00 
c0103e80:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103e87:	e8 5f ce ff ff       	call   c0100ceb <__panic>
    free_list = free_list_store;
c0103e8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103e8f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103e92:	a3 90 40 12 c0       	mov    %eax,0xc0124090
c0103e97:	89 15 94 40 12 c0    	mov    %edx,0xc0124094
    nr_free = nr_free_store;
c0103e9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ea0:	a3 98 40 12 c0       	mov    %eax,0xc0124098

    free_page(p);
c0103ea5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103eac:	00 
c0103ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103eb0:	89 04 24             	mov    %eax,(%esp)
c0103eb3:	e8 53 0a 00 00       	call   c010490b <free_pages>
    free_page(p1);
c0103eb8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ebf:	00 
c0103ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ec3:	89 04 24             	mov    %eax,(%esp)
c0103ec6:	e8 40 0a 00 00       	call   c010490b <free_pages>
    free_page(p2);
c0103ecb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ed2:	00 
c0103ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ed6:	89 04 24             	mov    %eax,(%esp)
c0103ed9:	e8 2d 0a 00 00       	call   c010490b <free_pages>
}
c0103ede:	c9                   	leave  
c0103edf:	c3                   	ret    

c0103ee0 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103ee0:	55                   	push   %ebp
c0103ee1:	89 e5                	mov    %esp,%ebp
c0103ee3:	53                   	push   %ebx
c0103ee4:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103eea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103ef1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103ef8:	c7 45 ec 90 40 12 c0 	movl   $0xc0124090,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103eff:	eb 6b                	jmp    c0103f6c <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103f01:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f04:	83 e8 0c             	sub    $0xc,%eax
c0103f07:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103f0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f0d:	83 c0 04             	add    $0x4,%eax
c0103f10:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103f17:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f1a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103f1d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103f20:	0f a3 10             	bt     %edx,(%eax)
c0103f23:	19 c0                	sbb    %eax,%eax
c0103f25:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103f28:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103f2c:	0f 95 c0             	setne  %al
c0103f2f:	0f b6 c0             	movzbl %al,%eax
c0103f32:	85 c0                	test   %eax,%eax
c0103f34:	75 24                	jne    c0103f5a <default_check+0x7a>
c0103f36:	c7 44 24 0c f6 9b 10 	movl   $0xc0109bf6,0xc(%esp)
c0103f3d:	c0 
c0103f3e:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103f45:	c0 
c0103f46:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103f4d:	00 
c0103f4e:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103f55:	e8 91 cd ff ff       	call   c0100ceb <__panic>
        count ++, total += p->property;
c0103f5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103f5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f61:	8b 50 08             	mov    0x8(%eax),%edx
c0103f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f67:	01 d0                	add    %edx,%eax
c0103f69:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f6f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103f72:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103f75:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103f78:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f7b:	81 7d ec 90 40 12 c0 	cmpl   $0xc0124090,-0x14(%ebp)
c0103f82:	0f 85 79 ff ff ff    	jne    c0103f01 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103f88:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0103f8b:	e8 ad 09 00 00       	call   c010493d <nr_free_pages>
c0103f90:	39 c3                	cmp    %eax,%ebx
c0103f92:	74 24                	je     c0103fb8 <default_check+0xd8>
c0103f94:	c7 44 24 0c 06 9c 10 	movl   $0xc0109c06,0xc(%esp)
c0103f9b:	c0 
c0103f9c:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103fa3:	c0 
c0103fa4:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0103fab:	00 
c0103fac:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103fb3:	e8 33 cd ff ff       	call   c0100ceb <__panic>

    basic_check();
c0103fb8:	e8 e7 f9 ff ff       	call   c01039a4 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103fbd:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103fc4:	e8 d7 08 00 00       	call   c01048a0 <alloc_pages>
c0103fc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103fcc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103fd0:	75 24                	jne    c0103ff6 <default_check+0x116>
c0103fd2:	c7 44 24 0c 1f 9c 10 	movl   $0xc0109c1f,0xc(%esp)
c0103fd9:	c0 
c0103fda:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0103fe1:	c0 
c0103fe2:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0103fe9:	00 
c0103fea:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0103ff1:	e8 f5 cc ff ff       	call   c0100ceb <__panic>
    assert(!PageProperty(p0));
c0103ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ff9:	83 c0 04             	add    $0x4,%eax
c0103ffc:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104003:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104006:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104009:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010400c:	0f a3 10             	bt     %edx,(%eax)
c010400f:	19 c0                	sbb    %eax,%eax
c0104011:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104014:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104018:	0f 95 c0             	setne  %al
c010401b:	0f b6 c0             	movzbl %al,%eax
c010401e:	85 c0                	test   %eax,%eax
c0104020:	74 24                	je     c0104046 <default_check+0x166>
c0104022:	c7 44 24 0c 2a 9c 10 	movl   $0xc0109c2a,0xc(%esp)
c0104029:	c0 
c010402a:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0104031:	c0 
c0104032:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104039:	00 
c010403a:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0104041:	e8 a5 cc ff ff       	call   c0100ceb <__panic>

    list_entry_t free_list_store = free_list;
c0104046:	a1 90 40 12 c0       	mov    0xc0124090,%eax
c010404b:	8b 15 94 40 12 c0    	mov    0xc0124094,%edx
c0104051:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104054:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104057:	c7 45 b4 90 40 12 c0 	movl   $0xc0124090,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010405e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104061:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104064:	89 50 04             	mov    %edx,0x4(%eax)
c0104067:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010406a:	8b 50 04             	mov    0x4(%eax),%edx
c010406d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104070:	89 10                	mov    %edx,(%eax)
c0104072:	c7 45 b0 90 40 12 c0 	movl   $0xc0124090,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104079:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010407c:	8b 40 04             	mov    0x4(%eax),%eax
c010407f:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104082:	0f 94 c0             	sete   %al
c0104085:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104088:	85 c0                	test   %eax,%eax
c010408a:	75 24                	jne    c01040b0 <default_check+0x1d0>
c010408c:	c7 44 24 0c 7f 9b 10 	movl   $0xc0109b7f,0xc(%esp)
c0104093:	c0 
c0104094:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010409b:	c0 
c010409c:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01040a3:	00 
c01040a4:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01040ab:	e8 3b cc ff ff       	call   c0100ceb <__panic>
    assert(alloc_page() == NULL);
c01040b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040b7:	e8 e4 07 00 00       	call   c01048a0 <alloc_pages>
c01040bc:	85 c0                	test   %eax,%eax
c01040be:	74 24                	je     c01040e4 <default_check+0x204>
c01040c0:	c7 44 24 0c 96 9b 10 	movl   $0xc0109b96,0xc(%esp)
c01040c7:	c0 
c01040c8:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01040cf:	c0 
c01040d0:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01040d7:	00 
c01040d8:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01040df:	e8 07 cc ff ff       	call   c0100ceb <__panic>

    unsigned int nr_free_store = nr_free;
c01040e4:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c01040e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01040ec:	c7 05 98 40 12 c0 00 	movl   $0x0,0xc0124098
c01040f3:	00 00 00 

    free_pages(p0 + 2, 3);
c01040f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040f9:	83 c0 40             	add    $0x40,%eax
c01040fc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104103:	00 
c0104104:	89 04 24             	mov    %eax,(%esp)
c0104107:	e8 ff 07 00 00       	call   c010490b <free_pages>
    assert(alloc_pages(4) == NULL);
c010410c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104113:	e8 88 07 00 00       	call   c01048a0 <alloc_pages>
c0104118:	85 c0                	test   %eax,%eax
c010411a:	74 24                	je     c0104140 <default_check+0x260>
c010411c:	c7 44 24 0c 3c 9c 10 	movl   $0xc0109c3c,0xc(%esp)
c0104123:	c0 
c0104124:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010412b:	c0 
c010412c:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0104133:	00 
c0104134:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010413b:	e8 ab cb ff ff       	call   c0100ceb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104143:	83 c0 40             	add    $0x40,%eax
c0104146:	83 c0 04             	add    $0x4,%eax
c0104149:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104150:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104153:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104156:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104159:	0f a3 10             	bt     %edx,(%eax)
c010415c:	19 c0                	sbb    %eax,%eax
c010415e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104161:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104165:	0f 95 c0             	setne  %al
c0104168:	0f b6 c0             	movzbl %al,%eax
c010416b:	85 c0                	test   %eax,%eax
c010416d:	74 0e                	je     c010417d <default_check+0x29d>
c010416f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104172:	83 c0 40             	add    $0x40,%eax
c0104175:	8b 40 08             	mov    0x8(%eax),%eax
c0104178:	83 f8 03             	cmp    $0x3,%eax
c010417b:	74 24                	je     c01041a1 <default_check+0x2c1>
c010417d:	c7 44 24 0c 54 9c 10 	movl   $0xc0109c54,0xc(%esp)
c0104184:	c0 
c0104185:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010418c:	c0 
c010418d:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104194:	00 
c0104195:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010419c:	e8 4a cb ff ff       	call   c0100ceb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01041a1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01041a8:	e8 f3 06 00 00       	call   c01048a0 <alloc_pages>
c01041ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01041b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01041b4:	75 24                	jne    c01041da <default_check+0x2fa>
c01041b6:	c7 44 24 0c 80 9c 10 	movl   $0xc0109c80,0xc(%esp)
c01041bd:	c0 
c01041be:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01041c5:	c0 
c01041c6:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01041cd:	00 
c01041ce:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01041d5:	e8 11 cb ff ff       	call   c0100ceb <__panic>
    assert(alloc_page() == NULL);
c01041da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01041e1:	e8 ba 06 00 00       	call   c01048a0 <alloc_pages>
c01041e6:	85 c0                	test   %eax,%eax
c01041e8:	74 24                	je     c010420e <default_check+0x32e>
c01041ea:	c7 44 24 0c 96 9b 10 	movl   $0xc0109b96,0xc(%esp)
c01041f1:	c0 
c01041f2:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01041f9:	c0 
c01041fa:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0104201:	00 
c0104202:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0104209:	e8 dd ca ff ff       	call   c0100ceb <__panic>
    assert(p0 + 2 == p1);
c010420e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104211:	83 c0 40             	add    $0x40,%eax
c0104214:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104217:	74 24                	je     c010423d <default_check+0x35d>
c0104219:	c7 44 24 0c 9e 9c 10 	movl   $0xc0109c9e,0xc(%esp)
c0104220:	c0 
c0104221:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c0104228:	c0 
c0104229:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0104230:	00 
c0104231:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0104238:	e8 ae ca ff ff       	call   c0100ceb <__panic>

    p2 = p0 + 1;
c010423d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104240:	83 c0 20             	add    $0x20,%eax
c0104243:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104246:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010424d:	00 
c010424e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104251:	89 04 24             	mov    %eax,(%esp)
c0104254:	e8 b2 06 00 00       	call   c010490b <free_pages>
    free_pages(p1, 3);
c0104259:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104260:	00 
c0104261:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104264:	89 04 24             	mov    %eax,(%esp)
c0104267:	e8 9f 06 00 00       	call   c010490b <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010426c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010426f:	83 c0 04             	add    $0x4,%eax
c0104272:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104279:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010427c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010427f:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104282:	0f a3 10             	bt     %edx,(%eax)
c0104285:	19 c0                	sbb    %eax,%eax
c0104287:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010428a:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010428e:	0f 95 c0             	setne  %al
c0104291:	0f b6 c0             	movzbl %al,%eax
c0104294:	85 c0                	test   %eax,%eax
c0104296:	74 0b                	je     c01042a3 <default_check+0x3c3>
c0104298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010429b:	8b 40 08             	mov    0x8(%eax),%eax
c010429e:	83 f8 01             	cmp    $0x1,%eax
c01042a1:	74 24                	je     c01042c7 <default_check+0x3e7>
c01042a3:	c7 44 24 0c ac 9c 10 	movl   $0xc0109cac,0xc(%esp)
c01042aa:	c0 
c01042ab:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01042b2:	c0 
c01042b3:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01042ba:	00 
c01042bb:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01042c2:	e8 24 ca ff ff       	call   c0100ceb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01042c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042ca:	83 c0 04             	add    $0x4,%eax
c01042cd:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01042d4:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042d7:	8b 45 90             	mov    -0x70(%ebp),%eax
c01042da:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01042dd:	0f a3 10             	bt     %edx,(%eax)
c01042e0:	19 c0                	sbb    %eax,%eax
c01042e2:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01042e5:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01042e9:	0f 95 c0             	setne  %al
c01042ec:	0f b6 c0             	movzbl %al,%eax
c01042ef:	85 c0                	test   %eax,%eax
c01042f1:	74 0b                	je     c01042fe <default_check+0x41e>
c01042f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042f6:	8b 40 08             	mov    0x8(%eax),%eax
c01042f9:	83 f8 03             	cmp    $0x3,%eax
c01042fc:	74 24                	je     c0104322 <default_check+0x442>
c01042fe:	c7 44 24 0c d4 9c 10 	movl   $0xc0109cd4,0xc(%esp)
c0104305:	c0 
c0104306:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010430d:	c0 
c010430e:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0104315:	00 
c0104316:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010431d:	e8 c9 c9 ff ff       	call   c0100ceb <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104322:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104329:	e8 72 05 00 00       	call   c01048a0 <alloc_pages>
c010432e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104331:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104334:	83 e8 20             	sub    $0x20,%eax
c0104337:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010433a:	74 24                	je     c0104360 <default_check+0x480>
c010433c:	c7 44 24 0c fa 9c 10 	movl   $0xc0109cfa,0xc(%esp)
c0104343:	c0 
c0104344:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010434b:	c0 
c010434c:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0104353:	00 
c0104354:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010435b:	e8 8b c9 ff ff       	call   c0100ceb <__panic>
    free_page(p0);
c0104360:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104367:	00 
c0104368:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010436b:	89 04 24             	mov    %eax,(%esp)
c010436e:	e8 98 05 00 00       	call   c010490b <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104373:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010437a:	e8 21 05 00 00       	call   c01048a0 <alloc_pages>
c010437f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104382:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104385:	83 c0 20             	add    $0x20,%eax
c0104388:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010438b:	74 24                	je     c01043b1 <default_check+0x4d1>
c010438d:	c7 44 24 0c 18 9d 10 	movl   $0xc0109d18,0xc(%esp)
c0104394:	c0 
c0104395:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010439c:	c0 
c010439d:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01043a4:	00 
c01043a5:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01043ac:	e8 3a c9 ff ff       	call   c0100ceb <__panic>

    free_pages(p0, 2);
c01043b1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01043b8:	00 
c01043b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043bc:	89 04 24             	mov    %eax,(%esp)
c01043bf:	e8 47 05 00 00       	call   c010490b <free_pages>
    free_page(p2);
c01043c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043cb:	00 
c01043cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043cf:	89 04 24             	mov    %eax,(%esp)
c01043d2:	e8 34 05 00 00       	call   c010490b <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01043d7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01043de:	e8 bd 04 00 00       	call   c01048a0 <alloc_pages>
c01043e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01043ea:	75 24                	jne    c0104410 <default_check+0x530>
c01043ec:	c7 44 24 0c 38 9d 10 	movl   $0xc0109d38,0xc(%esp)
c01043f3:	c0 
c01043f4:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01043fb:	c0 
c01043fc:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0104403:	00 
c0104404:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010440b:	e8 db c8 ff ff       	call   c0100ceb <__panic>
    assert(alloc_page() == NULL);
c0104410:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104417:	e8 84 04 00 00       	call   c01048a0 <alloc_pages>
c010441c:	85 c0                	test   %eax,%eax
c010441e:	74 24                	je     c0104444 <default_check+0x564>
c0104420:	c7 44 24 0c 96 9b 10 	movl   $0xc0109b96,0xc(%esp)
c0104427:	c0 
c0104428:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010442f:	c0 
c0104430:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0104437:	00 
c0104438:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010443f:	e8 a7 c8 ff ff       	call   c0100ceb <__panic>

    assert(nr_free == 0);
c0104444:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0104449:	85 c0                	test   %eax,%eax
c010444b:	74 24                	je     c0104471 <default_check+0x591>
c010444d:	c7 44 24 0c e9 9b 10 	movl   $0xc0109be9,0xc(%esp)
c0104454:	c0 
c0104455:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010445c:	c0 
c010445d:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0104464:	00 
c0104465:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010446c:	e8 7a c8 ff ff       	call   c0100ceb <__panic>
    nr_free = nr_free_store;
c0104471:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104474:	a3 98 40 12 c0       	mov    %eax,0xc0124098

    free_list = free_list_store;
c0104479:	8b 45 80             	mov    -0x80(%ebp),%eax
c010447c:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010447f:	a3 90 40 12 c0       	mov    %eax,0xc0124090
c0104484:	89 15 94 40 12 c0    	mov    %edx,0xc0124094
    free_pages(p0, 5);
c010448a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104491:	00 
c0104492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104495:	89 04 24             	mov    %eax,(%esp)
c0104498:	e8 6e 04 00 00       	call   c010490b <free_pages>

    le = &free_list;
c010449d:	c7 45 ec 90 40 12 c0 	movl   $0xc0124090,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01044a4:	eb 1d                	jmp    c01044c3 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c01044a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044a9:	83 e8 0c             	sub    $0xc,%eax
c01044ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01044af:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01044b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01044b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01044b9:	8b 40 08             	mov    0x8(%eax),%eax
c01044bc:	29 c2                	sub    %eax,%edx
c01044be:	89 d0                	mov    %edx,%eax
c01044c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044c6:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01044c9:	8b 45 88             	mov    -0x78(%ebp),%eax
c01044cc:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01044cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01044d2:	81 7d ec 90 40 12 c0 	cmpl   $0xc0124090,-0x14(%ebp)
c01044d9:	75 cb                	jne    c01044a6 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01044db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044df:	74 24                	je     c0104505 <default_check+0x625>
c01044e1:	c7 44 24 0c 56 9d 10 	movl   $0xc0109d56,0xc(%esp)
c01044e8:	c0 
c01044e9:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c01044f0:	c0 
c01044f1:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c01044f8:	00 
c01044f9:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c0104500:	e8 e6 c7 ff ff       	call   c0100ceb <__panic>
    assert(total == 0);
c0104505:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104509:	74 24                	je     c010452f <default_check+0x64f>
c010450b:	c7 44 24 0c 61 9d 10 	movl   $0xc0109d61,0xc(%esp)
c0104512:	c0 
c0104513:	c7 44 24 08 f6 99 10 	movl   $0xc01099f6,0x8(%esp)
c010451a:	c0 
c010451b:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0104522:	00 
c0104523:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c010452a:	e8 bc c7 ff ff       	call   c0100ceb <__panic>
}
c010452f:	81 c4 94 00 00 00    	add    $0x94,%esp
c0104535:	5b                   	pop    %ebx
c0104536:	5d                   	pop    %ebp
c0104537:	c3                   	ret    

c0104538 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104538:	55                   	push   %ebp
c0104539:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010453b:	8b 55 08             	mov    0x8(%ebp),%edx
c010453e:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c0104543:	29 c2                	sub    %eax,%edx
c0104545:	89 d0                	mov    %edx,%eax
c0104547:	c1 f8 05             	sar    $0x5,%eax
}
c010454a:	5d                   	pop    %ebp
c010454b:	c3                   	ret    

c010454c <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010454c:	55                   	push   %ebp
c010454d:	89 e5                	mov    %esp,%ebp
c010454f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104552:	8b 45 08             	mov    0x8(%ebp),%eax
c0104555:	89 04 24             	mov    %eax,(%esp)
c0104558:	e8 db ff ff ff       	call   c0104538 <page2ppn>
c010455d:	c1 e0 0c             	shl    $0xc,%eax
}
c0104560:	c9                   	leave  
c0104561:	c3                   	ret    

c0104562 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104562:	55                   	push   %ebp
c0104563:	89 e5                	mov    %esp,%ebp
c0104565:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104568:	8b 45 08             	mov    0x8(%ebp),%eax
c010456b:	c1 e8 0c             	shr    $0xc,%eax
c010456e:	89 c2                	mov    %eax,%edx
c0104570:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104575:	39 c2                	cmp    %eax,%edx
c0104577:	72 1c                	jb     c0104595 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104579:	c7 44 24 08 9c 9d 10 	movl   $0xc0109d9c,0x8(%esp)
c0104580:	c0 
c0104581:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104588:	00 
c0104589:	c7 04 24 bb 9d 10 c0 	movl   $0xc0109dbb,(%esp)
c0104590:	e8 56 c7 ff ff       	call   c0100ceb <__panic>
    }
    return &pages[PPN(pa)];
c0104595:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c010459a:	8b 55 08             	mov    0x8(%ebp),%edx
c010459d:	c1 ea 0c             	shr    $0xc,%edx
c01045a0:	c1 e2 05             	shl    $0x5,%edx
c01045a3:	01 d0                	add    %edx,%eax
}
c01045a5:	c9                   	leave  
c01045a6:	c3                   	ret    

c01045a7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01045a7:	55                   	push   %ebp
c01045a8:	89 e5                	mov    %esp,%ebp
c01045aa:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01045ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b0:	89 04 24             	mov    %eax,(%esp)
c01045b3:	e8 94 ff ff ff       	call   c010454c <page2pa>
c01045b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045be:	c1 e8 0c             	shr    $0xc,%eax
c01045c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045c4:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c01045c9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01045cc:	72 23                	jb     c01045f1 <page2kva+0x4a>
c01045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01045d5:	c7 44 24 08 cc 9d 10 	movl   $0xc0109dcc,0x8(%esp)
c01045dc:	c0 
c01045dd:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01045e4:	00 
c01045e5:	c7 04 24 bb 9d 10 c0 	movl   $0xc0109dbb,(%esp)
c01045ec:	e8 fa c6 ff ff       	call   c0100ceb <__panic>
c01045f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f4:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01045f9:	c9                   	leave  
c01045fa:	c3                   	ret    

c01045fb <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01045fb:	55                   	push   %ebp
c01045fc:	89 e5                	mov    %esp,%ebp
c01045fe:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104601:	8b 45 08             	mov    0x8(%ebp),%eax
c0104604:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104607:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010460e:	77 23                	ja     c0104633 <kva2page+0x38>
c0104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104613:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104617:	c7 44 24 08 f0 9d 10 	movl   $0xc0109df0,0x8(%esp)
c010461e:	c0 
c010461f:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104626:	00 
c0104627:	c7 04 24 bb 9d 10 c0 	movl   $0xc0109dbb,(%esp)
c010462e:	e8 b8 c6 ff ff       	call   c0100ceb <__panic>
c0104633:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104636:	05 00 00 00 40       	add    $0x40000000,%eax
c010463b:	89 04 24             	mov    %eax,(%esp)
c010463e:	e8 1f ff ff ff       	call   c0104562 <pa2page>
}
c0104643:	c9                   	leave  
c0104644:	c3                   	ret    

c0104645 <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c0104645:	55                   	push   %ebp
c0104646:	89 e5                	mov    %esp,%ebp
c0104648:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010464b:	8b 45 08             	mov    0x8(%ebp),%eax
c010464e:	83 e0 01             	and    $0x1,%eax
c0104651:	85 c0                	test   %eax,%eax
c0104653:	75 1c                	jne    c0104671 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104655:	c7 44 24 08 14 9e 10 	movl   $0xc0109e14,0x8(%esp)
c010465c:	c0 
c010465d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104664:	00 
c0104665:	c7 04 24 bb 9d 10 c0 	movl   $0xc0109dbb,(%esp)
c010466c:	e8 7a c6 ff ff       	call   c0100ceb <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104671:	8b 45 08             	mov    0x8(%ebp),%eax
c0104674:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104679:	89 04 24             	mov    %eax,(%esp)
c010467c:	e8 e1 fe ff ff       	call   c0104562 <pa2page>
}
c0104681:	c9                   	leave  
c0104682:	c3                   	ret    

c0104683 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104683:	55                   	push   %ebp
c0104684:	89 e5                	mov    %esp,%ebp
c0104686:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104689:	8b 45 08             	mov    0x8(%ebp),%eax
c010468c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104691:	89 04 24             	mov    %eax,(%esp)
c0104694:	e8 c9 fe ff ff       	call   c0104562 <pa2page>
}
c0104699:	c9                   	leave  
c010469a:	c3                   	ret    

c010469b <page_ref>:

static inline int
page_ref(struct Page *page) {
c010469b:	55                   	push   %ebp
c010469c:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010469e:	8b 45 08             	mov    0x8(%ebp),%eax
c01046a1:	8b 00                	mov    (%eax),%eax
}
c01046a3:	5d                   	pop    %ebp
c01046a4:	c3                   	ret    

c01046a5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01046a5:	55                   	push   %ebp
c01046a6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01046a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ab:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046ae:	89 10                	mov    %edx,(%eax)
}
c01046b0:	5d                   	pop    %ebp
c01046b1:	c3                   	ret    

c01046b2 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01046b2:	55                   	push   %ebp
c01046b3:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01046b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b8:	8b 00                	mov    (%eax),%eax
c01046ba:	8d 50 01             	lea    0x1(%eax),%edx
c01046bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c0:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01046c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c5:	8b 00                	mov    (%eax),%eax
}
c01046c7:	5d                   	pop    %ebp
c01046c8:	c3                   	ret    

c01046c9 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01046c9:	55                   	push   %ebp
c01046ca:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01046cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01046cf:	8b 00                	mov    (%eax),%eax
c01046d1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01046d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d7:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01046d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01046dc:	8b 00                	mov    (%eax),%eax
}
c01046de:	5d                   	pop    %ebp
c01046df:	c3                   	ret    

c01046e0 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01046e0:	55                   	push   %ebp
c01046e1:	89 e5                	mov    %esp,%ebp
c01046e3:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01046e6:	9c                   	pushf  
c01046e7:	58                   	pop    %eax
c01046e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01046eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01046ee:	25 00 02 00 00       	and    $0x200,%eax
c01046f3:	85 c0                	test   %eax,%eax
c01046f5:	74 0c                	je     c0104703 <__intr_save+0x23>
        intr_disable();
c01046f7:	e8 58 d8 ff ff       	call   c0101f54 <intr_disable>
        return 1;
c01046fc:	b8 01 00 00 00       	mov    $0x1,%eax
c0104701:	eb 05                	jmp    c0104708 <__intr_save+0x28>
    }
    return 0;
c0104703:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104708:	c9                   	leave  
c0104709:	c3                   	ret    

c010470a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010470a:	55                   	push   %ebp
c010470b:	89 e5                	mov    %esp,%ebp
c010470d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104710:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104714:	74 05                	je     c010471b <__intr_restore+0x11>
        intr_enable();
c0104716:	e8 33 d8 ff ff       	call   c0101f4e <intr_enable>
    }
}
c010471b:	c9                   	leave  
c010471c:	c3                   	ret    

c010471d <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c010471d:	55                   	push   %ebp
c010471e:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104720:	8b 45 08             	mov    0x8(%ebp),%eax
c0104723:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104726:	b8 23 00 00 00       	mov    $0x23,%eax
c010472b:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c010472d:	b8 23 00 00 00       	mov    $0x23,%eax
c0104732:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104734:	b8 10 00 00 00       	mov    $0x10,%eax
c0104739:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c010473b:	b8 10 00 00 00       	mov    $0x10,%eax
c0104740:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104742:	b8 10 00 00 00       	mov    $0x10,%eax
c0104747:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104749:	ea 50 47 10 c0 08 00 	ljmp   $0x8,$0xc0104750
}
c0104750:	5d                   	pop    %ebp
c0104751:	c3                   	ret    

c0104752 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104752:	55                   	push   %ebp
c0104753:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104755:	8b 45 08             	mov    0x8(%ebp),%eax
c0104758:	a3 c4 3f 12 c0       	mov    %eax,0xc0123fc4
}
c010475d:	5d                   	pop    %ebp
c010475e:	c3                   	ret    

c010475f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c010475f:	55                   	push   %ebp
c0104760:	89 e5                	mov    %esp,%ebp
c0104762:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104765:	b8 00 00 12 c0       	mov    $0xc0120000,%eax
c010476a:	89 04 24             	mov    %eax,(%esp)
c010476d:	e8 e0 ff ff ff       	call   c0104752 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104772:	66 c7 05 c8 3f 12 c0 	movw   $0x10,0xc0123fc8
c0104779:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010477b:	66 c7 05 28 0a 12 c0 	movw   $0x68,0xc0120a28
c0104782:	68 00 
c0104784:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c0104789:	66 a3 2a 0a 12 c0    	mov    %ax,0xc0120a2a
c010478f:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c0104794:	c1 e8 10             	shr    $0x10,%eax
c0104797:	a2 2c 0a 12 c0       	mov    %al,0xc0120a2c
c010479c:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c01047a3:	83 e0 f0             	and    $0xfffffff0,%eax
c01047a6:	83 c8 09             	or     $0x9,%eax
c01047a9:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c01047ae:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c01047b5:	83 e0 ef             	and    $0xffffffef,%eax
c01047b8:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c01047bd:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c01047c4:	83 e0 9f             	and    $0xffffff9f,%eax
c01047c7:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c01047cc:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c01047d3:	83 c8 80             	or     $0xffffff80,%eax
c01047d6:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c01047db:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01047e2:	83 e0 f0             	and    $0xfffffff0,%eax
c01047e5:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01047ea:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01047f1:	83 e0 ef             	and    $0xffffffef,%eax
c01047f4:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01047f9:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c0104800:	83 e0 df             	and    $0xffffffdf,%eax
c0104803:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c0104808:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c010480f:	83 c8 40             	or     $0x40,%eax
c0104812:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c0104817:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c010481e:	83 e0 7f             	and    $0x7f,%eax
c0104821:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c0104826:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c010482b:	c1 e8 18             	shr    $0x18,%eax
c010482e:	a2 2f 0a 12 c0       	mov    %al,0xc0120a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104833:	c7 04 24 30 0a 12 c0 	movl   $0xc0120a30,(%esp)
c010483a:	e8 de fe ff ff       	call   c010471d <lgdt>
c010483f:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104845:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104849:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c010484c:	c9                   	leave  
c010484d:	c3                   	ret    

c010484e <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010484e:	55                   	push   %ebp
c010484f:	89 e5                	mov    %esp,%ebp
c0104851:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0104854:	c7 05 9c 40 12 c0 80 	movl   $0xc0109d80,0xc012409c
c010485b:	9d 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010485e:	a1 9c 40 12 c0       	mov    0xc012409c,%eax
c0104863:	8b 00                	mov    (%eax),%eax
c0104865:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104869:	c7 04 24 40 9e 10 c0 	movl   $0xc0109e40,(%esp)
c0104870:	e8 e2 ba ff ff       	call   c0100357 <cprintf>
    pmm_manager->init();
c0104875:	a1 9c 40 12 c0       	mov    0xc012409c,%eax
c010487a:	8b 40 04             	mov    0x4(%eax),%eax
c010487d:	ff d0                	call   *%eax
}
c010487f:	c9                   	leave  
c0104880:	c3                   	ret    

c0104881 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104881:	55                   	push   %ebp
c0104882:	89 e5                	mov    %esp,%ebp
c0104884:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104887:	a1 9c 40 12 c0       	mov    0xc012409c,%eax
c010488c:	8b 40 08             	mov    0x8(%eax),%eax
c010488f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104892:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104896:	8b 55 08             	mov    0x8(%ebp),%edx
c0104899:	89 14 24             	mov    %edx,(%esp)
c010489c:	ff d0                	call   *%eax
}
c010489e:	c9                   	leave  
c010489f:	c3                   	ret    

c01048a0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01048a0:	55                   	push   %ebp
c01048a1:	89 e5                	mov    %esp,%ebp
c01048a3:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c01048a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c01048ad:	e8 2e fe ff ff       	call   c01046e0 <__intr_save>
c01048b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01048b5:	a1 9c 40 12 c0       	mov    0xc012409c,%eax
c01048ba:	8b 40 0c             	mov    0xc(%eax),%eax
c01048bd:	8b 55 08             	mov    0x8(%ebp),%edx
c01048c0:	89 14 24             	mov    %edx,(%esp)
c01048c3:	ff d0                	call   *%eax
c01048c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01048c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048cb:	89 04 24             	mov    %eax,(%esp)
c01048ce:	e8 37 fe ff ff       	call   c010470a <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01048d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048d7:	75 2d                	jne    c0104906 <alloc_pages+0x66>
c01048d9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01048dd:	77 27                	ja     c0104906 <alloc_pages+0x66>
c01048df:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c01048e4:	85 c0                	test   %eax,%eax
c01048e6:	74 1e                	je     c0104906 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01048e8:	8b 55 08             	mov    0x8(%ebp),%edx
c01048eb:	a1 8c 41 12 c0       	mov    0xc012418c,%eax
c01048f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048f7:	00 
c01048f8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048fc:	89 04 24             	mov    %eax,(%esp)
c01048ff:	e8 0f 1a 00 00       	call   c0106313 <swap_out>
    }
c0104904:	eb a7                	jmp    c01048ad <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104909:	c9                   	leave  
c010490a:	c3                   	ret    

c010490b <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c010490b:	55                   	push   %ebp
c010490c:	89 e5                	mov    %esp,%ebp
c010490e:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104911:	e8 ca fd ff ff       	call   c01046e0 <__intr_save>
c0104916:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104919:	a1 9c 40 12 c0       	mov    0xc012409c,%eax
c010491e:	8b 40 10             	mov    0x10(%eax),%eax
c0104921:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104924:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104928:	8b 55 08             	mov    0x8(%ebp),%edx
c010492b:	89 14 24             	mov    %edx,(%esp)
c010492e:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0104930:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104933:	89 04 24             	mov    %eax,(%esp)
c0104936:	e8 cf fd ff ff       	call   c010470a <__intr_restore>
}
c010493b:	c9                   	leave  
c010493c:	c3                   	ret    

c010493d <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010493d:	55                   	push   %ebp
c010493e:	89 e5                	mov    %esp,%ebp
c0104940:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104943:	e8 98 fd ff ff       	call   c01046e0 <__intr_save>
c0104948:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010494b:	a1 9c 40 12 c0       	mov    0xc012409c,%eax
c0104950:	8b 40 14             	mov    0x14(%eax),%eax
c0104953:	ff d0                	call   *%eax
c0104955:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010495b:	89 04 24             	mov    %eax,(%esp)
c010495e:	e8 a7 fd ff ff       	call   c010470a <__intr_restore>
    return ret;
c0104963:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104966:	c9                   	leave  
c0104967:	c3                   	ret    

c0104968 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104968:	55                   	push   %ebp
c0104969:	89 e5                	mov    %esp,%ebp
c010496b:	57                   	push   %edi
c010496c:	56                   	push   %esi
c010496d:	53                   	push   %ebx
c010496e:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104974:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010497b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104982:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104989:	c7 04 24 57 9e 10 c0 	movl   $0xc0109e57,(%esp)
c0104990:	e8 c2 b9 ff ff       	call   c0100357 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104995:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010499c:	e9 15 01 00 00       	jmp    c0104ab6 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01049a1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01049a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049a7:	89 d0                	mov    %edx,%eax
c01049a9:	c1 e0 02             	shl    $0x2,%eax
c01049ac:	01 d0                	add    %edx,%eax
c01049ae:	c1 e0 02             	shl    $0x2,%eax
c01049b1:	01 c8                	add    %ecx,%eax
c01049b3:	8b 50 08             	mov    0x8(%eax),%edx
c01049b6:	8b 40 04             	mov    0x4(%eax),%eax
c01049b9:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01049bc:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01049bf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01049c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049c5:	89 d0                	mov    %edx,%eax
c01049c7:	c1 e0 02             	shl    $0x2,%eax
c01049ca:	01 d0                	add    %edx,%eax
c01049cc:	c1 e0 02             	shl    $0x2,%eax
c01049cf:	01 c8                	add    %ecx,%eax
c01049d1:	8b 48 0c             	mov    0xc(%eax),%ecx
c01049d4:	8b 58 10             	mov    0x10(%eax),%ebx
c01049d7:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01049da:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01049dd:	01 c8                	add    %ecx,%eax
c01049df:	11 da                	adc    %ebx,%edx
c01049e1:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01049e4:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01049e7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01049ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049ed:	89 d0                	mov    %edx,%eax
c01049ef:	c1 e0 02             	shl    $0x2,%eax
c01049f2:	01 d0                	add    %edx,%eax
c01049f4:	c1 e0 02             	shl    $0x2,%eax
c01049f7:	01 c8                	add    %ecx,%eax
c01049f9:	83 c0 14             	add    $0x14,%eax
c01049fc:	8b 00                	mov    (%eax),%eax
c01049fe:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104a04:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104a07:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104a0a:	83 c0 ff             	add    $0xffffffff,%eax
c0104a0d:	83 d2 ff             	adc    $0xffffffff,%edx
c0104a10:	89 c6                	mov    %eax,%esi
c0104a12:	89 d7                	mov    %edx,%edi
c0104a14:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a17:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a1a:	89 d0                	mov    %edx,%eax
c0104a1c:	c1 e0 02             	shl    $0x2,%eax
c0104a1f:	01 d0                	add    %edx,%eax
c0104a21:	c1 e0 02             	shl    $0x2,%eax
c0104a24:	01 c8                	add    %ecx,%eax
c0104a26:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104a29:	8b 58 10             	mov    0x10(%eax),%ebx
c0104a2c:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104a32:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104a36:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104a3a:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104a3e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104a41:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104a44:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104a48:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104a4c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104a50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104a54:	c7 04 24 64 9e 10 c0 	movl   $0xc0109e64,(%esp)
c0104a5b:	e8 f7 b8 ff ff       	call   c0100357 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104a60:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a63:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a66:	89 d0                	mov    %edx,%eax
c0104a68:	c1 e0 02             	shl    $0x2,%eax
c0104a6b:	01 d0                	add    %edx,%eax
c0104a6d:	c1 e0 02             	shl    $0x2,%eax
c0104a70:	01 c8                	add    %ecx,%eax
c0104a72:	83 c0 14             	add    $0x14,%eax
c0104a75:	8b 00                	mov    (%eax),%eax
c0104a77:	83 f8 01             	cmp    $0x1,%eax
c0104a7a:	75 36                	jne    c0104ab2 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0104a7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104a82:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104a85:	77 2b                	ja     c0104ab2 <page_init+0x14a>
c0104a87:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104a8a:	72 05                	jb     c0104a91 <page_init+0x129>
c0104a8c:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0104a8f:	73 21                	jae    c0104ab2 <page_init+0x14a>
c0104a91:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104a95:	77 1b                	ja     c0104ab2 <page_init+0x14a>
c0104a97:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104a9b:	72 09                	jb     c0104aa6 <page_init+0x13e>
c0104a9d:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0104aa4:	77 0c                	ja     c0104ab2 <page_init+0x14a>
                maxpa = end;
c0104aa6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104aa9:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104aac:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104aaf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104ab2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104ab6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104ab9:	8b 00                	mov    (%eax),%eax
c0104abb:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104abe:	0f 8f dd fe ff ff    	jg     c01049a1 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104ac4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104ac8:	72 1d                	jb     c0104ae7 <page_init+0x17f>
c0104aca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104ace:	77 09                	ja     c0104ad9 <page_init+0x171>
c0104ad0:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0104ad7:	76 0e                	jbe    c0104ae7 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0104ad9:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104ae0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104ae7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104aea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104aed:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104af1:	c1 ea 0c             	shr    $0xc,%edx
c0104af4:	a3 a0 3f 12 c0       	mov    %eax,0xc0123fa0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104af9:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0104b00:	b8 90 41 12 c0       	mov    $0xc0124190,%eax
c0104b05:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104b08:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104b0b:	01 d0                	add    %edx,%eax
c0104b0d:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104b10:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104b13:	ba 00 00 00 00       	mov    $0x0,%edx
c0104b18:	f7 75 ac             	divl   -0x54(%ebp)
c0104b1b:	89 d0                	mov    %edx,%eax
c0104b1d:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104b20:	29 c2                	sub    %eax,%edx
c0104b22:	89 d0                	mov    %edx,%eax
c0104b24:	a3 a4 40 12 c0       	mov    %eax,0xc01240a4

    for (i = 0; i < npage; i ++) {
c0104b29:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104b30:	eb 27                	jmp    c0104b59 <page_init+0x1f1>
        SetPageReserved(pages + i);
c0104b32:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c0104b37:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b3a:	c1 e2 05             	shl    $0x5,%edx
c0104b3d:	01 d0                	add    %edx,%eax
c0104b3f:	83 c0 04             	add    $0x4,%eax
c0104b42:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104b49:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b4c:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104b4f:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104b52:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0104b55:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104b59:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b5c:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104b61:	39 c2                	cmp    %eax,%edx
c0104b63:	72 cd                	jb     c0104b32 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104b65:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104b6a:	c1 e0 05             	shl    $0x5,%eax
c0104b6d:	89 c2                	mov    %eax,%edx
c0104b6f:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c0104b74:	01 d0                	add    %edx,%eax
c0104b76:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0104b79:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104b80:	77 23                	ja     c0104ba5 <page_init+0x23d>
c0104b82:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104b85:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104b89:	c7 44 24 08 f0 9d 10 	movl   $0xc0109df0,0x8(%esp)
c0104b90:	c0 
c0104b91:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104b98:	00 
c0104b99:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0104ba0:	e8 46 c1 ff ff       	call   c0100ceb <__panic>
c0104ba5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104ba8:	05 00 00 00 40       	add    $0x40000000,%eax
c0104bad:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104bb0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104bb7:	e9 74 01 00 00       	jmp    c0104d30 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104bbc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104bbf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104bc2:	89 d0                	mov    %edx,%eax
c0104bc4:	c1 e0 02             	shl    $0x2,%eax
c0104bc7:	01 d0                	add    %edx,%eax
c0104bc9:	c1 e0 02             	shl    $0x2,%eax
c0104bcc:	01 c8                	add    %ecx,%eax
c0104bce:	8b 50 08             	mov    0x8(%eax),%edx
c0104bd1:	8b 40 04             	mov    0x4(%eax),%eax
c0104bd4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104bd7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104bda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104bdd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104be0:	89 d0                	mov    %edx,%eax
c0104be2:	c1 e0 02             	shl    $0x2,%eax
c0104be5:	01 d0                	add    %edx,%eax
c0104be7:	c1 e0 02             	shl    $0x2,%eax
c0104bea:	01 c8                	add    %ecx,%eax
c0104bec:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104bef:	8b 58 10             	mov    0x10(%eax),%ebx
c0104bf2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104bf5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104bf8:	01 c8                	add    %ecx,%eax
c0104bfa:	11 da                	adc    %ebx,%edx
c0104bfc:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104bff:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104c02:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c05:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c08:	89 d0                	mov    %edx,%eax
c0104c0a:	c1 e0 02             	shl    $0x2,%eax
c0104c0d:	01 d0                	add    %edx,%eax
c0104c0f:	c1 e0 02             	shl    $0x2,%eax
c0104c12:	01 c8                	add    %ecx,%eax
c0104c14:	83 c0 14             	add    $0x14,%eax
c0104c17:	8b 00                	mov    (%eax),%eax
c0104c19:	83 f8 01             	cmp    $0x1,%eax
c0104c1c:	0f 85 0a 01 00 00    	jne    c0104d2c <page_init+0x3c4>
            if (begin < freemem) {
c0104c22:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104c25:	ba 00 00 00 00       	mov    $0x0,%edx
c0104c2a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104c2d:	72 17                	jb     c0104c46 <page_init+0x2de>
c0104c2f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104c32:	77 05                	ja     c0104c39 <page_init+0x2d1>
c0104c34:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104c37:	76 0d                	jbe    c0104c46 <page_init+0x2de>
                begin = freemem;
c0104c39:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104c3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c3f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104c46:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104c4a:	72 1d                	jb     c0104c69 <page_init+0x301>
c0104c4c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104c50:	77 09                	ja     c0104c5b <page_init+0x2f3>
c0104c52:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104c59:	76 0e                	jbe    c0104c69 <page_init+0x301>
                end = KMEMSIZE;
c0104c5b:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104c62:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104c69:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104c6c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104c6f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104c72:	0f 87 b4 00 00 00    	ja     c0104d2c <page_init+0x3c4>
c0104c78:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104c7b:	72 09                	jb     c0104c86 <page_init+0x31e>
c0104c7d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104c80:	0f 83 a6 00 00 00    	jae    c0104d2c <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0104c86:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104c8d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104c90:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104c93:	01 d0                	add    %edx,%eax
c0104c95:	83 e8 01             	sub    $0x1,%eax
c0104c98:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104c9b:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104c9e:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ca3:	f7 75 9c             	divl   -0x64(%ebp)
c0104ca6:	89 d0                	mov    %edx,%eax
c0104ca8:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104cab:	29 c2                	sub    %eax,%edx
c0104cad:	89 d0                	mov    %edx,%eax
c0104caf:	ba 00 00 00 00       	mov    $0x0,%edx
c0104cb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104cb7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104cba:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104cbd:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104cc0:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104cc3:	ba 00 00 00 00       	mov    $0x0,%edx
c0104cc8:	89 c7                	mov    %eax,%edi
c0104cca:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104cd0:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104cd3:	89 d0                	mov    %edx,%eax
c0104cd5:	83 e0 00             	and    $0x0,%eax
c0104cd8:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104cdb:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104cde:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104ce1:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104ce4:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104ce7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104cea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104ced:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104cf0:	77 3a                	ja     c0104d2c <page_init+0x3c4>
c0104cf2:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104cf5:	72 05                	jb     c0104cfc <page_init+0x394>
c0104cf7:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104cfa:	73 30                	jae    c0104d2c <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104cfc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104cff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104d02:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d05:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104d08:	29 c8                	sub    %ecx,%eax
c0104d0a:	19 da                	sbb    %ebx,%edx
c0104d0c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104d10:	c1 ea 0c             	shr    $0xc,%edx
c0104d13:	89 c3                	mov    %eax,%ebx
c0104d15:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d18:	89 04 24             	mov    %eax,(%esp)
c0104d1b:	e8 42 f8 ff ff       	call   c0104562 <pa2page>
c0104d20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104d24:	89 04 24             	mov    %eax,(%esp)
c0104d27:	e8 55 fb ff ff       	call   c0104881 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104d2c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104d30:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104d33:	8b 00                	mov    (%eax),%eax
c0104d35:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104d38:	0f 8f 7e fe ff ff    	jg     c0104bbc <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104d3e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104d44:	5b                   	pop    %ebx
c0104d45:	5e                   	pop    %esi
c0104d46:	5f                   	pop    %edi
c0104d47:	5d                   	pop    %ebp
c0104d48:	c3                   	ret    

c0104d49 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104d49:	55                   	push   %ebp
c0104d4a:	89 e5                	mov    %esp,%ebp
c0104d4c:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104d4f:	8b 45 14             	mov    0x14(%ebp),%eax
c0104d52:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104d55:	31 d0                	xor    %edx,%eax
c0104d57:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104d5c:	85 c0                	test   %eax,%eax
c0104d5e:	74 24                	je     c0104d84 <boot_map_segment+0x3b>
c0104d60:	c7 44 24 0c a2 9e 10 	movl   $0xc0109ea2,0xc(%esp)
c0104d67:	c0 
c0104d68:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0104d6f:	c0 
c0104d70:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104d77:	00 
c0104d78:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0104d7f:	e8 67 bf ff ff       	call   c0100ceb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104d84:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d8e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104d93:	89 c2                	mov    %eax,%edx
c0104d95:	8b 45 10             	mov    0x10(%ebp),%eax
c0104d98:	01 c2                	add    %eax,%edx
c0104d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d9d:	01 d0                	add    %edx,%eax
c0104d9f:	83 e8 01             	sub    $0x1,%eax
c0104da2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104da5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104da8:	ba 00 00 00 00       	mov    $0x0,%edx
c0104dad:	f7 75 f0             	divl   -0x10(%ebp)
c0104db0:	89 d0                	mov    %edx,%eax
c0104db2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104db5:	29 c2                	sub    %eax,%edx
c0104db7:	89 d0                	mov    %edx,%eax
c0104db9:	c1 e8 0c             	shr    $0xc,%eax
c0104dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104dcd:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104dd0:	8b 45 14             	mov    0x14(%ebp),%eax
c0104dd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104dde:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104de1:	eb 6b                	jmp    c0104e4e <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104de3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104dea:	00 
c0104deb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dee:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104df2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104df5:	89 04 24             	mov    %eax,(%esp)
c0104df8:	e8 82 01 00 00       	call   c0104f7f <get_pte>
c0104dfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104e00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104e04:	75 24                	jne    c0104e2a <boot_map_segment+0xe1>
c0104e06:	c7 44 24 0c ce 9e 10 	movl   $0xc0109ece,0xc(%esp)
c0104e0d:	c0 
c0104e0e:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0104e15:	c0 
c0104e16:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104e1d:	00 
c0104e1e:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0104e25:	e8 c1 be ff ff       	call   c0100ceb <__panic>
        *ptep = pa | PTE_P | perm;
c0104e2a:	8b 45 18             	mov    0x18(%ebp),%eax
c0104e2d:	8b 55 14             	mov    0x14(%ebp),%edx
c0104e30:	09 d0                	or     %edx,%eax
c0104e32:	83 c8 01             	or     $0x1,%eax
c0104e35:	89 c2                	mov    %eax,%edx
c0104e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e3a:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104e3c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104e40:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104e47:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104e4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e52:	75 8f                	jne    c0104de3 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104e54:	c9                   	leave  
c0104e55:	c3                   	ret    

c0104e56 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104e56:	55                   	push   %ebp
c0104e57:	89 e5                	mov    %esp,%ebp
c0104e59:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104e5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e63:	e8 38 fa ff ff       	call   c01048a0 <alloc_pages>
c0104e68:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104e6b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e6f:	75 1c                	jne    c0104e8d <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104e71:	c7 44 24 08 db 9e 10 	movl   $0xc0109edb,0x8(%esp)
c0104e78:	c0 
c0104e79:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104e80:	00 
c0104e81:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0104e88:	e8 5e be ff ff       	call   c0100ceb <__panic>
    }
    return page2kva(p);
c0104e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e90:	89 04 24             	mov    %eax,(%esp)
c0104e93:	e8 0f f7 ff ff       	call   c01045a7 <page2kva>
}
c0104e98:	c9                   	leave  
c0104e99:	c3                   	ret    

c0104e9a <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104e9a:	55                   	push   %ebp
c0104e9b:	89 e5                	mov    %esp,%ebp
c0104e9d:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104ea0:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104ea5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ea8:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104eaf:	77 23                	ja     c0104ed4 <pmm_init+0x3a>
c0104eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104eb8:	c7 44 24 08 f0 9d 10 	movl   $0xc0109df0,0x8(%esp)
c0104ebf:	c0 
c0104ec0:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104ec7:	00 
c0104ec8:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0104ecf:	e8 17 be ff ff       	call   c0100ceb <__panic>
c0104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ed7:	05 00 00 00 40       	add    $0x40000000,%eax
c0104edc:	a3 a0 40 12 c0       	mov    %eax,0xc01240a0
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104ee1:	e8 68 f9 ff ff       	call   c010484e <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104ee6:	e8 7d fa ff ff       	call   c0104968 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104eeb:	e8 a6 04 00 00       	call   c0105396 <check_alloc_page>

    check_pgdir();
c0104ef0:	e8 bf 04 00 00       	call   c01053b4 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104ef5:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104efa:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0104f00:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f08:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104f0f:	77 23                	ja     c0104f34 <pmm_init+0x9a>
c0104f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f14:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f18:	c7 44 24 08 f0 9d 10 	movl   $0xc0109df0,0x8(%esp)
c0104f1f:	c0 
c0104f20:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0104f27:	00 
c0104f28:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0104f2f:	e8 b7 bd ff ff       	call   c0100ceb <__panic>
c0104f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f37:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f3c:	83 c8 03             	or     $0x3,%eax
c0104f3f:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104f41:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104f46:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104f4d:	00 
c0104f4e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104f55:	00 
c0104f56:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104f5d:	38 
c0104f5e:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104f65:	c0 
c0104f66:	89 04 24             	mov    %eax,(%esp)
c0104f69:	e8 db fd ff ff       	call   c0104d49 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104f6e:	e8 ec f7 ff ff       	call   c010475f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104f73:	e8 d7 0a 00 00       	call   c0105a4f <check_boot_pgdir>

    print_pgdir();
c0104f78:	e8 5f 0f 00 00       	call   c0105edc <print_pgdir>

}
c0104f7d:	c9                   	leave  
c0104f7e:	c3                   	ret    

c0104f7f <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104f7f:	55                   	push   %ebp
c0104f80:	89 e5                	mov    %esp,%ebp
c0104f82:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0104f85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f88:	c1 e8 16             	shr    $0x16,%eax
c0104f8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104f92:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f95:	01 d0                	add    %edx,%eax
c0104f97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0104f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f9d:	8b 00                	mov    (%eax),%eax
c0104f9f:	83 e0 01             	and    $0x1,%eax
c0104fa2:	85 c0                	test   %eax,%eax
c0104fa4:	0f 85 af 00 00 00    	jne    c0105059 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0104faa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104fae:	74 15                	je     c0104fc5 <get_pte+0x46>
c0104fb0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104fb7:	e8 e4 f8 ff ff       	call   c01048a0 <alloc_pages>
c0104fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104fbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104fc3:	75 0a                	jne    c0104fcf <get_pte+0x50>
            return NULL;
c0104fc5:	b8 00 00 00 00       	mov    $0x0,%eax
c0104fca:	e9 e6 00 00 00       	jmp    c01050b5 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c0104fcf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104fd6:	00 
c0104fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fda:	89 04 24             	mov    %eax,(%esp)
c0104fdd:	e8 c3 f6 ff ff       	call   c01046a5 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0104fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fe5:	89 04 24             	mov    %eax,(%esp)
c0104fe8:	e8 5f f5 ff ff       	call   c010454c <page2pa>
c0104fed:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0104ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ff3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104ff6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ff9:	c1 e8 0c             	shr    $0xc,%eax
c0104ffc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104fff:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105004:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105007:	72 23                	jb     c010502c <get_pte+0xad>
c0105009:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010500c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105010:	c7 44 24 08 cc 9d 10 	movl   $0xc0109dcc,0x8(%esp)
c0105017:	c0 
c0105018:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c010501f:	00 
c0105020:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105027:	e8 bf bc ff ff       	call   c0100ceb <__panic>
c010502c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010502f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105034:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010503b:	00 
c010503c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105043:	00 
c0105044:	89 04 24             	mov    %eax,(%esp)
c0105047:	e8 81 3f 00 00       	call   c0108fcd <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c010504c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010504f:	83 c8 07             	or     $0x7,%eax
c0105052:	89 c2                	mov    %eax,%edx
c0105054:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105057:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0105059:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010505c:	8b 00                	mov    (%eax),%eax
c010505e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105063:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105066:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105069:	c1 e8 0c             	shr    $0xc,%eax
c010506c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010506f:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105074:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105077:	72 23                	jb     c010509c <get_pte+0x11d>
c0105079:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010507c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105080:	c7 44 24 08 cc 9d 10 	movl   $0xc0109dcc,0x8(%esp)
c0105087:	c0 
c0105088:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c010508f:	00 
c0105090:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105097:	e8 4f bc ff ff       	call   c0100ceb <__panic>
c010509c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010509f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01050a4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01050a7:	c1 ea 0c             	shr    $0xc,%edx
c01050aa:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01050b0:	c1 e2 02             	shl    $0x2,%edx
c01050b3:	01 d0                	add    %edx,%eax
}
c01050b5:	c9                   	leave  
c01050b6:	c3                   	ret    

c01050b7 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01050b7:	55                   	push   %ebp
c01050b8:	89 e5                	mov    %esp,%ebp
c01050ba:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01050bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050c4:	00 
c01050c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01050cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01050cf:	89 04 24             	mov    %eax,(%esp)
c01050d2:	e8 a8 fe ff ff       	call   c0104f7f <get_pte>
c01050d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01050da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01050de:	74 08                	je     c01050e8 <get_page+0x31>
        *ptep_store = ptep;
c01050e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01050e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01050e6:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01050e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050ec:	74 1b                	je     c0105109 <get_page+0x52>
c01050ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050f1:	8b 00                	mov    (%eax),%eax
c01050f3:	83 e0 01             	and    $0x1,%eax
c01050f6:	85 c0                	test   %eax,%eax
c01050f8:	74 0f                	je     c0105109 <get_page+0x52>
        return pte2page(*ptep);
c01050fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050fd:	8b 00                	mov    (%eax),%eax
c01050ff:	89 04 24             	mov    %eax,(%esp)
c0105102:	e8 3e f5 ff ff       	call   c0104645 <pte2page>
c0105107:	eb 05                	jmp    c010510e <get_page+0x57>
    }
    return NULL;
c0105109:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010510e:	c9                   	leave  
c010510f:	c3                   	ret    

c0105110 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105110:	55                   	push   %ebp
c0105111:	89 e5                	mov    %esp,%ebp
c0105113:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0105116:	8b 45 10             	mov    0x10(%ebp),%eax
c0105119:	8b 00                	mov    (%eax),%eax
c010511b:	83 e0 01             	and    $0x1,%eax
c010511e:	85 c0                	test   %eax,%eax
c0105120:	74 4d                	je     c010516f <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0105122:	8b 45 10             	mov    0x10(%ebp),%eax
c0105125:	8b 00                	mov    (%eax),%eax
c0105127:	89 04 24             	mov    %eax,(%esp)
c010512a:	e8 16 f5 ff ff       	call   c0104645 <pte2page>
c010512f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0105132:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105135:	89 04 24             	mov    %eax,(%esp)
c0105138:	e8 8c f5 ff ff       	call   c01046c9 <page_ref_dec>
c010513d:	85 c0                	test   %eax,%eax
c010513f:	75 13                	jne    c0105154 <page_remove_pte+0x44>
            free_page(page);
c0105141:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105148:	00 
c0105149:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010514c:	89 04 24             	mov    %eax,(%esp)
c010514f:	e8 b7 f7 ff ff       	call   c010490b <free_pages>
        }
        *ptep = 0;
c0105154:	8b 45 10             	mov    0x10(%ebp),%eax
c0105157:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c010515d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105160:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105164:	8b 45 08             	mov    0x8(%ebp),%eax
c0105167:	89 04 24             	mov    %eax,(%esp)
c010516a:	e8 ff 00 00 00       	call   c010526e <tlb_invalidate>
    }
}
c010516f:	c9                   	leave  
c0105170:	c3                   	ret    

c0105171 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105171:	55                   	push   %ebp
c0105172:	89 e5                	mov    %esp,%ebp
c0105174:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105177:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010517e:	00 
c010517f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105186:	8b 45 08             	mov    0x8(%ebp),%eax
c0105189:	89 04 24             	mov    %eax,(%esp)
c010518c:	e8 ee fd ff ff       	call   c0104f7f <get_pte>
c0105191:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105194:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105198:	74 19                	je     c01051b3 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010519a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010519d:	89 44 24 08          	mov    %eax,0x8(%esp)
c01051a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01051a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01051ab:	89 04 24             	mov    %eax,(%esp)
c01051ae:	e8 5d ff ff ff       	call   c0105110 <page_remove_pte>
    }
}
c01051b3:	c9                   	leave  
c01051b4:	c3                   	ret    

c01051b5 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01051b5:	55                   	push   %ebp
c01051b6:	89 e5                	mov    %esp,%ebp
c01051b8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01051bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01051c2:	00 
c01051c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01051c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01051cd:	89 04 24             	mov    %eax,(%esp)
c01051d0:	e8 aa fd ff ff       	call   c0104f7f <get_pte>
c01051d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01051d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01051dc:	75 0a                	jne    c01051e8 <page_insert+0x33>
        return -E_NO_MEM;
c01051de:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01051e3:	e9 84 00 00 00       	jmp    c010526c <page_insert+0xb7>
    }
    page_ref_inc(page);
c01051e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01051eb:	89 04 24             	mov    %eax,(%esp)
c01051ee:	e8 bf f4 ff ff       	call   c01046b2 <page_ref_inc>
    if (*ptep & PTE_P) {
c01051f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051f6:	8b 00                	mov    (%eax),%eax
c01051f8:	83 e0 01             	and    $0x1,%eax
c01051fb:	85 c0                	test   %eax,%eax
c01051fd:	74 3e                	je     c010523d <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01051ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105202:	8b 00                	mov    (%eax),%eax
c0105204:	89 04 24             	mov    %eax,(%esp)
c0105207:	e8 39 f4 ff ff       	call   c0104645 <pte2page>
c010520c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010520f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105212:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105215:	75 0d                	jne    c0105224 <page_insert+0x6f>
            page_ref_dec(page);
c0105217:	8b 45 0c             	mov    0xc(%ebp),%eax
c010521a:	89 04 24             	mov    %eax,(%esp)
c010521d:	e8 a7 f4 ff ff       	call   c01046c9 <page_ref_dec>
c0105222:	eb 19                	jmp    c010523d <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105224:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105227:	89 44 24 08          	mov    %eax,0x8(%esp)
c010522b:	8b 45 10             	mov    0x10(%ebp),%eax
c010522e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105232:	8b 45 08             	mov    0x8(%ebp),%eax
c0105235:	89 04 24             	mov    %eax,(%esp)
c0105238:	e8 d3 fe ff ff       	call   c0105110 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010523d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105240:	89 04 24             	mov    %eax,(%esp)
c0105243:	e8 04 f3 ff ff       	call   c010454c <page2pa>
c0105248:	0b 45 14             	or     0x14(%ebp),%eax
c010524b:	83 c8 01             	or     $0x1,%eax
c010524e:	89 c2                	mov    %eax,%edx
c0105250:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105253:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105255:	8b 45 10             	mov    0x10(%ebp),%eax
c0105258:	89 44 24 04          	mov    %eax,0x4(%esp)
c010525c:	8b 45 08             	mov    0x8(%ebp),%eax
c010525f:	89 04 24             	mov    %eax,(%esp)
c0105262:	e8 07 00 00 00       	call   c010526e <tlb_invalidate>
    return 0;
c0105267:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010526c:	c9                   	leave  
c010526d:	c3                   	ret    

c010526e <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010526e:	55                   	push   %ebp
c010526f:	89 e5                	mov    %esp,%ebp
c0105271:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105274:	0f 20 d8             	mov    %cr3,%eax
c0105277:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010527a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c010527d:	89 c2                	mov    %eax,%edx
c010527f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105282:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105285:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010528c:	77 23                	ja     c01052b1 <tlb_invalidate+0x43>
c010528e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105291:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105295:	c7 44 24 08 f0 9d 10 	movl   $0xc0109df0,0x8(%esp)
c010529c:	c0 
c010529d:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c01052a4:	00 
c01052a5:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01052ac:	e8 3a ba ff ff       	call   c0100ceb <__panic>
c01052b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052b4:	05 00 00 00 40       	add    $0x40000000,%eax
c01052b9:	39 c2                	cmp    %eax,%edx
c01052bb:	75 0c                	jne    c01052c9 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01052bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01052c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052c6:	0f 01 38             	invlpg (%eax)
    }
}
c01052c9:	c9                   	leave  
c01052ca:	c3                   	ret    

c01052cb <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01052cb:	55                   	push   %ebp
c01052cc:	89 e5                	mov    %esp,%ebp
c01052ce:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01052d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01052d8:	e8 c3 f5 ff ff       	call   c01048a0 <alloc_pages>
c01052dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01052e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052e4:	0f 84 a7 00 00 00    	je     c0105391 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01052ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01052ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01052f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01052f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0105302:	89 04 24             	mov    %eax,(%esp)
c0105305:	e8 ab fe ff ff       	call   c01051b5 <page_insert>
c010530a:	85 c0                	test   %eax,%eax
c010530c:	74 1a                	je     c0105328 <pgdir_alloc_page+0x5d>
            free_page(page);
c010530e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105315:	00 
c0105316:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105319:	89 04 24             	mov    %eax,(%esp)
c010531c:	e8 ea f5 ff ff       	call   c010490b <free_pages>
            return NULL;
c0105321:	b8 00 00 00 00       	mov    $0x0,%eax
c0105326:	eb 6c                	jmp    c0105394 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105328:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c010532d:	85 c0                	test   %eax,%eax
c010532f:	74 60                	je     c0105391 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0105331:	a1 8c 41 12 c0       	mov    0xc012418c,%eax
c0105336:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010533d:	00 
c010533e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105341:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105345:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105348:	89 54 24 04          	mov    %edx,0x4(%esp)
c010534c:	89 04 24             	mov    %eax,(%esp)
c010534f:	e8 73 0f 00 00       	call   c01062c7 <swap_map_swappable>
            page->pra_vaddr=la;
c0105354:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105357:	8b 55 0c             	mov    0xc(%ebp),%edx
c010535a:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c010535d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105360:	89 04 24             	mov    %eax,(%esp)
c0105363:	e8 33 f3 ff ff       	call   c010469b <page_ref>
c0105368:	83 f8 01             	cmp    $0x1,%eax
c010536b:	74 24                	je     c0105391 <pgdir_alloc_page+0xc6>
c010536d:	c7 44 24 0c f4 9e 10 	movl   $0xc0109ef4,0xc(%esp)
c0105374:	c0 
c0105375:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c010537c:	c0 
c010537d:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0105384:	00 
c0105385:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c010538c:	e8 5a b9 ff ff       	call   c0100ceb <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0105391:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105394:	c9                   	leave  
c0105395:	c3                   	ret    

c0105396 <check_alloc_page>:

static void
check_alloc_page(void) {
c0105396:	55                   	push   %ebp
c0105397:	89 e5                	mov    %esp,%ebp
c0105399:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010539c:	a1 9c 40 12 c0       	mov    0xc012409c,%eax
c01053a1:	8b 40 18             	mov    0x18(%eax),%eax
c01053a4:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01053a6:	c7 04 24 08 9f 10 c0 	movl   $0xc0109f08,(%esp)
c01053ad:	e8 a5 af ff ff       	call   c0100357 <cprintf>
}
c01053b2:	c9                   	leave  
c01053b3:	c3                   	ret    

c01053b4 <check_pgdir>:

static void
check_pgdir(void) {
c01053b4:	55                   	push   %ebp
c01053b5:	89 e5                	mov    %esp,%ebp
c01053b7:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01053ba:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c01053bf:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01053c4:	76 24                	jbe    c01053ea <check_pgdir+0x36>
c01053c6:	c7 44 24 0c 27 9f 10 	movl   $0xc0109f27,0xc(%esp)
c01053cd:	c0 
c01053ce:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01053d5:	c0 
c01053d6:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c01053dd:	00 
c01053de:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01053e5:	e8 01 b9 ff ff       	call   c0100ceb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01053ea:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01053ef:	85 c0                	test   %eax,%eax
c01053f1:	74 0e                	je     c0105401 <check_pgdir+0x4d>
c01053f3:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01053f8:	25 ff 0f 00 00       	and    $0xfff,%eax
c01053fd:	85 c0                	test   %eax,%eax
c01053ff:	74 24                	je     c0105425 <check_pgdir+0x71>
c0105401:	c7 44 24 0c 44 9f 10 	movl   $0xc0109f44,0xc(%esp)
c0105408:	c0 
c0105409:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105410:	c0 
c0105411:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0105418:	00 
c0105419:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105420:	e8 c6 b8 ff ff       	call   c0100ceb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105425:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010542a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105431:	00 
c0105432:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105439:	00 
c010543a:	89 04 24             	mov    %eax,(%esp)
c010543d:	e8 75 fc ff ff       	call   c01050b7 <get_page>
c0105442:	85 c0                	test   %eax,%eax
c0105444:	74 24                	je     c010546a <check_pgdir+0xb6>
c0105446:	c7 44 24 0c 7c 9f 10 	movl   $0xc0109f7c,0xc(%esp)
c010544d:	c0 
c010544e:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105455:	c0 
c0105456:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c010545d:	00 
c010545e:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105465:	e8 81 b8 ff ff       	call   c0100ceb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010546a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105471:	e8 2a f4 ff ff       	call   c01048a0 <alloc_pages>
c0105476:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105479:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010547e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105485:	00 
c0105486:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010548d:	00 
c010548e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105491:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105495:	89 04 24             	mov    %eax,(%esp)
c0105498:	e8 18 fd ff ff       	call   c01051b5 <page_insert>
c010549d:	85 c0                	test   %eax,%eax
c010549f:	74 24                	je     c01054c5 <check_pgdir+0x111>
c01054a1:	c7 44 24 0c a4 9f 10 	movl   $0xc0109fa4,0xc(%esp)
c01054a8:	c0 
c01054a9:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01054b0:	c0 
c01054b1:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c01054b8:	00 
c01054b9:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01054c0:	e8 26 b8 ff ff       	call   c0100ceb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01054c5:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01054ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01054d1:	00 
c01054d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01054d9:	00 
c01054da:	89 04 24             	mov    %eax,(%esp)
c01054dd:	e8 9d fa ff ff       	call   c0104f7f <get_pte>
c01054e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01054e9:	75 24                	jne    c010550f <check_pgdir+0x15b>
c01054eb:	c7 44 24 0c d0 9f 10 	movl   $0xc0109fd0,0xc(%esp)
c01054f2:	c0 
c01054f3:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01054fa:	c0 
c01054fb:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0105502:	00 
c0105503:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c010550a:	e8 dc b7 ff ff       	call   c0100ceb <__panic>
    assert(pte2page(*ptep) == p1);
c010550f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105512:	8b 00                	mov    (%eax),%eax
c0105514:	89 04 24             	mov    %eax,(%esp)
c0105517:	e8 29 f1 ff ff       	call   c0104645 <pte2page>
c010551c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010551f:	74 24                	je     c0105545 <check_pgdir+0x191>
c0105521:	c7 44 24 0c fd 9f 10 	movl   $0xc0109ffd,0xc(%esp)
c0105528:	c0 
c0105529:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105530:	c0 
c0105531:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105538:	00 
c0105539:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105540:	e8 a6 b7 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p1) == 1);
c0105545:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105548:	89 04 24             	mov    %eax,(%esp)
c010554b:	e8 4b f1 ff ff       	call   c010469b <page_ref>
c0105550:	83 f8 01             	cmp    $0x1,%eax
c0105553:	74 24                	je     c0105579 <check_pgdir+0x1c5>
c0105555:	c7 44 24 0c 13 a0 10 	movl   $0xc010a013,0xc(%esp)
c010555c:	c0 
c010555d:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105564:	c0 
c0105565:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c010556c:	00 
c010556d:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105574:	e8 72 b7 ff ff       	call   c0100ceb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105579:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010557e:	8b 00                	mov    (%eax),%eax
c0105580:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105585:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105588:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010558b:	c1 e8 0c             	shr    $0xc,%eax
c010558e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105591:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105596:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105599:	72 23                	jb     c01055be <check_pgdir+0x20a>
c010559b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010559e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01055a2:	c7 44 24 08 cc 9d 10 	movl   $0xc0109dcc,0x8(%esp)
c01055a9:	c0 
c01055aa:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c01055b1:	00 
c01055b2:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01055b9:	e8 2d b7 ff ff       	call   c0100ceb <__panic>
c01055be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055c1:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01055c6:	83 c0 04             	add    $0x4,%eax
c01055c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01055cc:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01055d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01055d8:	00 
c01055d9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01055e0:	00 
c01055e1:	89 04 24             	mov    %eax,(%esp)
c01055e4:	e8 96 f9 ff ff       	call   c0104f7f <get_pte>
c01055e9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01055ec:	74 24                	je     c0105612 <check_pgdir+0x25e>
c01055ee:	c7 44 24 0c 28 a0 10 	movl   $0xc010a028,0xc(%esp)
c01055f5:	c0 
c01055f6:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01055fd:	c0 
c01055fe:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0105605:	00 
c0105606:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c010560d:	e8 d9 b6 ff ff       	call   c0100ceb <__panic>

    p2 = alloc_page();
c0105612:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105619:	e8 82 f2 ff ff       	call   c01048a0 <alloc_pages>
c010561e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105621:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105626:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010562d:	00 
c010562e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105635:	00 
c0105636:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105639:	89 54 24 04          	mov    %edx,0x4(%esp)
c010563d:	89 04 24             	mov    %eax,(%esp)
c0105640:	e8 70 fb ff ff       	call   c01051b5 <page_insert>
c0105645:	85 c0                	test   %eax,%eax
c0105647:	74 24                	je     c010566d <check_pgdir+0x2b9>
c0105649:	c7 44 24 0c 50 a0 10 	movl   $0xc010a050,0xc(%esp)
c0105650:	c0 
c0105651:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105658:	c0 
c0105659:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105660:	00 
c0105661:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105668:	e8 7e b6 ff ff       	call   c0100ceb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010566d:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105672:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105679:	00 
c010567a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105681:	00 
c0105682:	89 04 24             	mov    %eax,(%esp)
c0105685:	e8 f5 f8 ff ff       	call   c0104f7f <get_pte>
c010568a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010568d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105691:	75 24                	jne    c01056b7 <check_pgdir+0x303>
c0105693:	c7 44 24 0c 88 a0 10 	movl   $0xc010a088,0xc(%esp)
c010569a:	c0 
c010569b:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01056a2:	c0 
c01056a3:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c01056aa:	00 
c01056ab:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01056b2:	e8 34 b6 ff ff       	call   c0100ceb <__panic>
    assert(*ptep & PTE_U);
c01056b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056ba:	8b 00                	mov    (%eax),%eax
c01056bc:	83 e0 04             	and    $0x4,%eax
c01056bf:	85 c0                	test   %eax,%eax
c01056c1:	75 24                	jne    c01056e7 <check_pgdir+0x333>
c01056c3:	c7 44 24 0c b8 a0 10 	movl   $0xc010a0b8,0xc(%esp)
c01056ca:	c0 
c01056cb:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01056d2:	c0 
c01056d3:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c01056da:	00 
c01056db:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01056e2:	e8 04 b6 ff ff       	call   c0100ceb <__panic>
    assert(*ptep & PTE_W);
c01056e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056ea:	8b 00                	mov    (%eax),%eax
c01056ec:	83 e0 02             	and    $0x2,%eax
c01056ef:	85 c0                	test   %eax,%eax
c01056f1:	75 24                	jne    c0105717 <check_pgdir+0x363>
c01056f3:	c7 44 24 0c c6 a0 10 	movl   $0xc010a0c6,0xc(%esp)
c01056fa:	c0 
c01056fb:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105702:	c0 
c0105703:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c010570a:	00 
c010570b:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105712:	e8 d4 b5 ff ff       	call   c0100ceb <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105717:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010571c:	8b 00                	mov    (%eax),%eax
c010571e:	83 e0 04             	and    $0x4,%eax
c0105721:	85 c0                	test   %eax,%eax
c0105723:	75 24                	jne    c0105749 <check_pgdir+0x395>
c0105725:	c7 44 24 0c d4 a0 10 	movl   $0xc010a0d4,0xc(%esp)
c010572c:	c0 
c010572d:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105734:	c0 
c0105735:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010573c:	00 
c010573d:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105744:	e8 a2 b5 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p2) == 1);
c0105749:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010574c:	89 04 24             	mov    %eax,(%esp)
c010574f:	e8 47 ef ff ff       	call   c010469b <page_ref>
c0105754:	83 f8 01             	cmp    $0x1,%eax
c0105757:	74 24                	je     c010577d <check_pgdir+0x3c9>
c0105759:	c7 44 24 0c ea a0 10 	movl   $0xc010a0ea,0xc(%esp)
c0105760:	c0 
c0105761:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105768:	c0 
c0105769:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105770:	00 
c0105771:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105778:	e8 6e b5 ff ff       	call   c0100ceb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010577d:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105782:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105789:	00 
c010578a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105791:	00 
c0105792:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105795:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105799:	89 04 24             	mov    %eax,(%esp)
c010579c:	e8 14 fa ff ff       	call   c01051b5 <page_insert>
c01057a1:	85 c0                	test   %eax,%eax
c01057a3:	74 24                	je     c01057c9 <check_pgdir+0x415>
c01057a5:	c7 44 24 0c fc a0 10 	movl   $0xc010a0fc,0xc(%esp)
c01057ac:	c0 
c01057ad:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01057b4:	c0 
c01057b5:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c01057bc:	00 
c01057bd:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01057c4:	e8 22 b5 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p1) == 2);
c01057c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057cc:	89 04 24             	mov    %eax,(%esp)
c01057cf:	e8 c7 ee ff ff       	call   c010469b <page_ref>
c01057d4:	83 f8 02             	cmp    $0x2,%eax
c01057d7:	74 24                	je     c01057fd <check_pgdir+0x449>
c01057d9:	c7 44 24 0c 28 a1 10 	movl   $0xc010a128,0xc(%esp)
c01057e0:	c0 
c01057e1:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01057e8:	c0 
c01057e9:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c01057f0:	00 
c01057f1:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01057f8:	e8 ee b4 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p2) == 0);
c01057fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105800:	89 04 24             	mov    %eax,(%esp)
c0105803:	e8 93 ee ff ff       	call   c010469b <page_ref>
c0105808:	85 c0                	test   %eax,%eax
c010580a:	74 24                	je     c0105830 <check_pgdir+0x47c>
c010580c:	c7 44 24 0c 3a a1 10 	movl   $0xc010a13a,0xc(%esp)
c0105813:	c0 
c0105814:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c010581b:	c0 
c010581c:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0105823:	00 
c0105824:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c010582b:	e8 bb b4 ff ff       	call   c0100ceb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105830:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105835:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010583c:	00 
c010583d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105844:	00 
c0105845:	89 04 24             	mov    %eax,(%esp)
c0105848:	e8 32 f7 ff ff       	call   c0104f7f <get_pte>
c010584d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105850:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105854:	75 24                	jne    c010587a <check_pgdir+0x4c6>
c0105856:	c7 44 24 0c 88 a0 10 	movl   $0xc010a088,0xc(%esp)
c010585d:	c0 
c010585e:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105865:	c0 
c0105866:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c010586d:	00 
c010586e:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105875:	e8 71 b4 ff ff       	call   c0100ceb <__panic>
    assert(pte2page(*ptep) == p1);
c010587a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010587d:	8b 00                	mov    (%eax),%eax
c010587f:	89 04 24             	mov    %eax,(%esp)
c0105882:	e8 be ed ff ff       	call   c0104645 <pte2page>
c0105887:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010588a:	74 24                	je     c01058b0 <check_pgdir+0x4fc>
c010588c:	c7 44 24 0c fd 9f 10 	movl   $0xc0109ffd,0xc(%esp)
c0105893:	c0 
c0105894:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c010589b:	c0 
c010589c:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c01058a3:	00 
c01058a4:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01058ab:	e8 3b b4 ff ff       	call   c0100ceb <__panic>
    assert((*ptep & PTE_U) == 0);
c01058b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058b3:	8b 00                	mov    (%eax),%eax
c01058b5:	83 e0 04             	and    $0x4,%eax
c01058b8:	85 c0                	test   %eax,%eax
c01058ba:	74 24                	je     c01058e0 <check_pgdir+0x52c>
c01058bc:	c7 44 24 0c 4c a1 10 	movl   $0xc010a14c,0xc(%esp)
c01058c3:	c0 
c01058c4:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01058cb:	c0 
c01058cc:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c01058d3:	00 
c01058d4:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01058db:	e8 0b b4 ff ff       	call   c0100ceb <__panic>

    page_remove(boot_pgdir, 0x0);
c01058e0:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01058e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01058ec:	00 
c01058ed:	89 04 24             	mov    %eax,(%esp)
c01058f0:	e8 7c f8 ff ff       	call   c0105171 <page_remove>
    assert(page_ref(p1) == 1);
c01058f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058f8:	89 04 24             	mov    %eax,(%esp)
c01058fb:	e8 9b ed ff ff       	call   c010469b <page_ref>
c0105900:	83 f8 01             	cmp    $0x1,%eax
c0105903:	74 24                	je     c0105929 <check_pgdir+0x575>
c0105905:	c7 44 24 0c 13 a0 10 	movl   $0xc010a013,0xc(%esp)
c010590c:	c0 
c010590d:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105914:	c0 
c0105915:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c010591c:	00 
c010591d:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105924:	e8 c2 b3 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p2) == 0);
c0105929:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010592c:	89 04 24             	mov    %eax,(%esp)
c010592f:	e8 67 ed ff ff       	call   c010469b <page_ref>
c0105934:	85 c0                	test   %eax,%eax
c0105936:	74 24                	je     c010595c <check_pgdir+0x5a8>
c0105938:	c7 44 24 0c 3a a1 10 	movl   $0xc010a13a,0xc(%esp)
c010593f:	c0 
c0105940:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105947:	c0 
c0105948:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c010594f:	00 
c0105950:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105957:	e8 8f b3 ff ff       	call   c0100ceb <__panic>

    page_remove(boot_pgdir, PGSIZE);
c010595c:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105961:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105968:	00 
c0105969:	89 04 24             	mov    %eax,(%esp)
c010596c:	e8 00 f8 ff ff       	call   c0105171 <page_remove>
    assert(page_ref(p1) == 0);
c0105971:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105974:	89 04 24             	mov    %eax,(%esp)
c0105977:	e8 1f ed ff ff       	call   c010469b <page_ref>
c010597c:	85 c0                	test   %eax,%eax
c010597e:	74 24                	je     c01059a4 <check_pgdir+0x5f0>
c0105980:	c7 44 24 0c 61 a1 10 	movl   $0xc010a161,0xc(%esp)
c0105987:	c0 
c0105988:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c010598f:	c0 
c0105990:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0105997:	00 
c0105998:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c010599f:	e8 47 b3 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p2) == 0);
c01059a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01059a7:	89 04 24             	mov    %eax,(%esp)
c01059aa:	e8 ec ec ff ff       	call   c010469b <page_ref>
c01059af:	85 c0                	test   %eax,%eax
c01059b1:	74 24                	je     c01059d7 <check_pgdir+0x623>
c01059b3:	c7 44 24 0c 3a a1 10 	movl   $0xc010a13a,0xc(%esp)
c01059ba:	c0 
c01059bb:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01059c2:	c0 
c01059c3:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c01059ca:	00 
c01059cb:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01059d2:	e8 14 b3 ff ff       	call   c0100ceb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01059d7:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01059dc:	8b 00                	mov    (%eax),%eax
c01059de:	89 04 24             	mov    %eax,(%esp)
c01059e1:	e8 9d ec ff ff       	call   c0104683 <pde2page>
c01059e6:	89 04 24             	mov    %eax,(%esp)
c01059e9:	e8 ad ec ff ff       	call   c010469b <page_ref>
c01059ee:	83 f8 01             	cmp    $0x1,%eax
c01059f1:	74 24                	je     c0105a17 <check_pgdir+0x663>
c01059f3:	c7 44 24 0c 74 a1 10 	movl   $0xc010a174,0xc(%esp)
c01059fa:	c0 
c01059fb:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105a02:	c0 
c0105a03:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0105a0a:	00 
c0105a0b:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105a12:	e8 d4 b2 ff ff       	call   c0100ceb <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105a17:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105a1c:	8b 00                	mov    (%eax),%eax
c0105a1e:	89 04 24             	mov    %eax,(%esp)
c0105a21:	e8 5d ec ff ff       	call   c0104683 <pde2page>
c0105a26:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a2d:	00 
c0105a2e:	89 04 24             	mov    %eax,(%esp)
c0105a31:	e8 d5 ee ff ff       	call   c010490b <free_pages>
    boot_pgdir[0] = 0;
c0105a36:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105a3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105a41:	c7 04 24 9b a1 10 c0 	movl   $0xc010a19b,(%esp)
c0105a48:	e8 0a a9 ff ff       	call   c0100357 <cprintf>
}
c0105a4d:	c9                   	leave  
c0105a4e:	c3                   	ret    

c0105a4f <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105a4f:	55                   	push   %ebp
c0105a50:	89 e5                	mov    %esp,%ebp
c0105a52:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105a55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105a5c:	e9 ca 00 00 00       	jmp    c0105b2b <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a6a:	c1 e8 0c             	shr    $0xc,%eax
c0105a6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a70:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105a75:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105a78:	72 23                	jb     c0105a9d <check_boot_pgdir+0x4e>
c0105a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a81:	c7 44 24 08 cc 9d 10 	movl   $0xc0109dcc,0x8(%esp)
c0105a88:	c0 
c0105a89:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c0105a90:	00 
c0105a91:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105a98:	e8 4e b2 ff ff       	call   c0100ceb <__panic>
c0105a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aa0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105aa5:	89 c2                	mov    %eax,%edx
c0105aa7:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105aac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105ab3:	00 
c0105ab4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ab8:	89 04 24             	mov    %eax,(%esp)
c0105abb:	e8 bf f4 ff ff       	call   c0104f7f <get_pte>
c0105ac0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ac3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ac7:	75 24                	jne    c0105aed <check_boot_pgdir+0x9e>
c0105ac9:	c7 44 24 0c b8 a1 10 	movl   $0xc010a1b8,0xc(%esp)
c0105ad0:	c0 
c0105ad1:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105ad8:	c0 
c0105ad9:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c0105ae0:	00 
c0105ae1:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105ae8:	e8 fe b1 ff ff       	call   c0100ceb <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105aed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105af0:	8b 00                	mov    (%eax),%eax
c0105af2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105af7:	89 c2                	mov    %eax,%edx
c0105af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105afc:	39 c2                	cmp    %eax,%edx
c0105afe:	74 24                	je     c0105b24 <check_boot_pgdir+0xd5>
c0105b00:	c7 44 24 0c f5 a1 10 	movl   $0xc010a1f5,0xc(%esp)
c0105b07:	c0 
c0105b08:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105b0f:	c0 
c0105b10:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c0105b17:	00 
c0105b18:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105b1f:	e8 c7 b1 ff ff       	call   c0100ceb <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105b24:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105b2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b2e:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105b33:	39 c2                	cmp    %eax,%edx
c0105b35:	0f 82 26 ff ff ff    	jb     c0105a61 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105b3b:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105b40:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105b45:	8b 00                	mov    (%eax),%eax
c0105b47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105b4c:	89 c2                	mov    %eax,%edx
c0105b4e:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105b53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105b56:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0105b5d:	77 23                	ja     c0105b82 <check_boot_pgdir+0x133>
c0105b5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b62:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b66:	c7 44 24 08 f0 9d 10 	movl   $0xc0109df0,0x8(%esp)
c0105b6d:	c0 
c0105b6e:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105b75:	00 
c0105b76:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105b7d:	e8 69 b1 ff ff       	call   c0100ceb <__panic>
c0105b82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b85:	05 00 00 00 40       	add    $0x40000000,%eax
c0105b8a:	39 c2                	cmp    %eax,%edx
c0105b8c:	74 24                	je     c0105bb2 <check_boot_pgdir+0x163>
c0105b8e:	c7 44 24 0c 0c a2 10 	movl   $0xc010a20c,0xc(%esp)
c0105b95:	c0 
c0105b96:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105b9d:	c0 
c0105b9e:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105ba5:	00 
c0105ba6:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105bad:	e8 39 b1 ff ff       	call   c0100ceb <__panic>

    assert(boot_pgdir[0] == 0);
c0105bb2:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105bb7:	8b 00                	mov    (%eax),%eax
c0105bb9:	85 c0                	test   %eax,%eax
c0105bbb:	74 24                	je     c0105be1 <check_boot_pgdir+0x192>
c0105bbd:	c7 44 24 0c 40 a2 10 	movl   $0xc010a240,0xc(%esp)
c0105bc4:	c0 
c0105bc5:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105bcc:	c0 
c0105bcd:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0105bd4:	00 
c0105bd5:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105bdc:	e8 0a b1 ff ff       	call   c0100ceb <__panic>

    struct Page *p;
    p = alloc_page();
c0105be1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105be8:	e8 b3 ec ff ff       	call   c01048a0 <alloc_pages>
c0105bed:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105bf0:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105bf5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105bfc:	00 
c0105bfd:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105c04:	00 
c0105c05:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105c08:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c0c:	89 04 24             	mov    %eax,(%esp)
c0105c0f:	e8 a1 f5 ff ff       	call   c01051b5 <page_insert>
c0105c14:	85 c0                	test   %eax,%eax
c0105c16:	74 24                	je     c0105c3c <check_boot_pgdir+0x1ed>
c0105c18:	c7 44 24 0c 54 a2 10 	movl   $0xc010a254,0xc(%esp)
c0105c1f:	c0 
c0105c20:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105c27:	c0 
c0105c28:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c0105c2f:	00 
c0105c30:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105c37:	e8 af b0 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p) == 1);
c0105c3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c3f:	89 04 24             	mov    %eax,(%esp)
c0105c42:	e8 54 ea ff ff       	call   c010469b <page_ref>
c0105c47:	83 f8 01             	cmp    $0x1,%eax
c0105c4a:	74 24                	je     c0105c70 <check_boot_pgdir+0x221>
c0105c4c:	c7 44 24 0c 82 a2 10 	movl   $0xc010a282,0xc(%esp)
c0105c53:	c0 
c0105c54:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105c5b:	c0 
c0105c5c:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c0105c63:	00 
c0105c64:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105c6b:	e8 7b b0 ff ff       	call   c0100ceb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105c70:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105c75:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105c7c:	00 
c0105c7d:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105c84:	00 
c0105c85:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105c88:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c8c:	89 04 24             	mov    %eax,(%esp)
c0105c8f:	e8 21 f5 ff ff       	call   c01051b5 <page_insert>
c0105c94:	85 c0                	test   %eax,%eax
c0105c96:	74 24                	je     c0105cbc <check_boot_pgdir+0x26d>
c0105c98:	c7 44 24 0c 94 a2 10 	movl   $0xc010a294,0xc(%esp)
c0105c9f:	c0 
c0105ca0:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105ca7:	c0 
c0105ca8:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c0105caf:	00 
c0105cb0:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105cb7:	e8 2f b0 ff ff       	call   c0100ceb <__panic>
    assert(page_ref(p) == 2);
c0105cbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105cbf:	89 04 24             	mov    %eax,(%esp)
c0105cc2:	e8 d4 e9 ff ff       	call   c010469b <page_ref>
c0105cc7:	83 f8 02             	cmp    $0x2,%eax
c0105cca:	74 24                	je     c0105cf0 <check_boot_pgdir+0x2a1>
c0105ccc:	c7 44 24 0c cb a2 10 	movl   $0xc010a2cb,0xc(%esp)
c0105cd3:	c0 
c0105cd4:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105cdb:	c0 
c0105cdc:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0105ce3:	00 
c0105ce4:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105ceb:	e8 fb af ff ff       	call   c0100ceb <__panic>

    const char *str = "ucore: Hello world!!";
c0105cf0:	c7 45 dc dc a2 10 c0 	movl   $0xc010a2dc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105cf7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cfe:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105d05:	e8 ec 2f 00 00       	call   c0108cf6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105d0a:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105d11:	00 
c0105d12:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105d19:	e8 51 30 00 00       	call   c0108d6f <strcmp>
c0105d1e:	85 c0                	test   %eax,%eax
c0105d20:	74 24                	je     c0105d46 <check_boot_pgdir+0x2f7>
c0105d22:	c7 44 24 0c f4 a2 10 	movl   $0xc010a2f4,0xc(%esp)
c0105d29:	c0 
c0105d2a:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105d31:	c0 
c0105d32:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c0105d39:	00 
c0105d3a:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105d41:	e8 a5 af ff ff       	call   c0100ceb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105d46:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d49:	89 04 24             	mov    %eax,(%esp)
c0105d4c:	e8 56 e8 ff ff       	call   c01045a7 <page2kva>
c0105d51:	05 00 01 00 00       	add    $0x100,%eax
c0105d56:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105d59:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105d60:	e8 39 2f 00 00       	call   c0108c9e <strlen>
c0105d65:	85 c0                	test   %eax,%eax
c0105d67:	74 24                	je     c0105d8d <check_boot_pgdir+0x33e>
c0105d69:	c7 44 24 0c 2c a3 10 	movl   $0xc010a32c,0xc(%esp)
c0105d70:	c0 
c0105d71:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0105d78:	c0 
c0105d79:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0105d80:	00 
c0105d81:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0105d88:	e8 5e af ff ff       	call   c0100ceb <__panic>

    free_page(p);
c0105d8d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105d94:	00 
c0105d95:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d98:	89 04 24             	mov    %eax,(%esp)
c0105d9b:	e8 6b eb ff ff       	call   c010490b <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105da0:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105da5:	8b 00                	mov    (%eax),%eax
c0105da7:	89 04 24             	mov    %eax,(%esp)
c0105daa:	e8 d4 e8 ff ff       	call   c0104683 <pde2page>
c0105daf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105db6:	00 
c0105db7:	89 04 24             	mov    %eax,(%esp)
c0105dba:	e8 4c eb ff ff       	call   c010490b <free_pages>
    boot_pgdir[0] = 0;
c0105dbf:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105dc4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105dca:	c7 04 24 50 a3 10 c0 	movl   $0xc010a350,(%esp)
c0105dd1:	e8 81 a5 ff ff       	call   c0100357 <cprintf>
}
c0105dd6:	c9                   	leave  
c0105dd7:	c3                   	ret    

c0105dd8 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105dd8:	55                   	push   %ebp
c0105dd9:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105ddb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dde:	83 e0 04             	and    $0x4,%eax
c0105de1:	85 c0                	test   %eax,%eax
c0105de3:	74 07                	je     c0105dec <perm2str+0x14>
c0105de5:	b8 75 00 00 00       	mov    $0x75,%eax
c0105dea:	eb 05                	jmp    c0105df1 <perm2str+0x19>
c0105dec:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105df1:	a2 28 40 12 c0       	mov    %al,0xc0124028
    str[1] = 'r';
c0105df6:	c6 05 29 40 12 c0 72 	movb   $0x72,0xc0124029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e00:	83 e0 02             	and    $0x2,%eax
c0105e03:	85 c0                	test   %eax,%eax
c0105e05:	74 07                	je     c0105e0e <perm2str+0x36>
c0105e07:	b8 77 00 00 00       	mov    $0x77,%eax
c0105e0c:	eb 05                	jmp    c0105e13 <perm2str+0x3b>
c0105e0e:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105e13:	a2 2a 40 12 c0       	mov    %al,0xc012402a
    str[3] = '\0';
c0105e18:	c6 05 2b 40 12 c0 00 	movb   $0x0,0xc012402b
    return str;
c0105e1f:	b8 28 40 12 c0       	mov    $0xc0124028,%eax
}
c0105e24:	5d                   	pop    %ebp
c0105e25:	c3                   	ret    

c0105e26 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105e26:	55                   	push   %ebp
c0105e27:	89 e5                	mov    %esp,%ebp
c0105e29:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105e2c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e2f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e32:	72 0a                	jb     c0105e3e <get_pgtable_items+0x18>
        return 0;
c0105e34:	b8 00 00 00 00       	mov    $0x0,%eax
c0105e39:	e9 9c 00 00 00       	jmp    c0105eda <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105e3e:	eb 04                	jmp    c0105e44 <get_pgtable_items+0x1e>
        start ++;
c0105e40:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105e44:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e47:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e4a:	73 18                	jae    c0105e64 <get_pgtable_items+0x3e>
c0105e4c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105e56:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e59:	01 d0                	add    %edx,%eax
c0105e5b:	8b 00                	mov    (%eax),%eax
c0105e5d:	83 e0 01             	and    $0x1,%eax
c0105e60:	85 c0                	test   %eax,%eax
c0105e62:	74 dc                	je     c0105e40 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105e64:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e67:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e6a:	73 69                	jae    c0105ed5 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0105e6c:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105e70:	74 08                	je     c0105e7a <get_pgtable_items+0x54>
            *left_store = start;
c0105e72:	8b 45 18             	mov    0x18(%ebp),%eax
c0105e75:	8b 55 10             	mov    0x10(%ebp),%edx
c0105e78:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105e7a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e7d:	8d 50 01             	lea    0x1(%eax),%edx
c0105e80:	89 55 10             	mov    %edx,0x10(%ebp)
c0105e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105e8a:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e8d:	01 d0                	add    %edx,%eax
c0105e8f:	8b 00                	mov    (%eax),%eax
c0105e91:	83 e0 07             	and    $0x7,%eax
c0105e94:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105e97:	eb 04                	jmp    c0105e9d <get_pgtable_items+0x77>
            start ++;
c0105e99:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105e9d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ea3:	73 1d                	jae    c0105ec2 <get_pgtable_items+0x9c>
c0105ea5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105eaf:	8b 45 14             	mov    0x14(%ebp),%eax
c0105eb2:	01 d0                	add    %edx,%eax
c0105eb4:	8b 00                	mov    (%eax),%eax
c0105eb6:	83 e0 07             	and    $0x7,%eax
c0105eb9:	89 c2                	mov    %eax,%edx
c0105ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105ebe:	39 c2                	cmp    %eax,%edx
c0105ec0:	74 d7                	je     c0105e99 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105ec2:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105ec6:	74 08                	je     c0105ed0 <get_pgtable_items+0xaa>
            *right_store = start;
c0105ec8:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105ecb:	8b 55 10             	mov    0x10(%ebp),%edx
c0105ece:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105ed0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105ed3:	eb 05                	jmp    c0105eda <get_pgtable_items+0xb4>
    }
    return 0;
c0105ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105eda:	c9                   	leave  
c0105edb:	c3                   	ret    

c0105edc <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105edc:	55                   	push   %ebp
c0105edd:	89 e5                	mov    %esp,%ebp
c0105edf:	57                   	push   %edi
c0105ee0:	56                   	push   %esi
c0105ee1:	53                   	push   %ebx
c0105ee2:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105ee5:	c7 04 24 70 a3 10 c0 	movl   $0xc010a370,(%esp)
c0105eec:	e8 66 a4 ff ff       	call   c0100357 <cprintf>
    size_t left, right = 0, perm;
c0105ef1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105ef8:	e9 fa 00 00 00       	jmp    c0105ff7 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f00:	89 04 24             	mov    %eax,(%esp)
c0105f03:	e8 d0 fe ff ff       	call   c0105dd8 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105f08:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105f0b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f0e:	29 d1                	sub    %edx,%ecx
c0105f10:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105f12:	89 d6                	mov    %edx,%esi
c0105f14:	c1 e6 16             	shl    $0x16,%esi
c0105f17:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105f1a:	89 d3                	mov    %edx,%ebx
c0105f1c:	c1 e3 16             	shl    $0x16,%ebx
c0105f1f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f22:	89 d1                	mov    %edx,%ecx
c0105f24:	c1 e1 16             	shl    $0x16,%ecx
c0105f27:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105f2a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f2d:	29 d7                	sub    %edx,%edi
c0105f2f:	89 fa                	mov    %edi,%edx
c0105f31:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105f35:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105f39:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105f3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105f41:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f45:	c7 04 24 a1 a3 10 c0 	movl   $0xc010a3a1,(%esp)
c0105f4c:	e8 06 a4 ff ff       	call   c0100357 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f54:	c1 e0 0a             	shl    $0xa,%eax
c0105f57:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105f5a:	eb 54                	jmp    c0105fb0 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105f5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f5f:	89 04 24             	mov    %eax,(%esp)
c0105f62:	e8 71 fe ff ff       	call   c0105dd8 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105f67:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105f6a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105f6d:	29 d1                	sub    %edx,%ecx
c0105f6f:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105f71:	89 d6                	mov    %edx,%esi
c0105f73:	c1 e6 0c             	shl    $0xc,%esi
c0105f76:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105f79:	89 d3                	mov    %edx,%ebx
c0105f7b:	c1 e3 0c             	shl    $0xc,%ebx
c0105f7e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105f81:	c1 e2 0c             	shl    $0xc,%edx
c0105f84:	89 d1                	mov    %edx,%ecx
c0105f86:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105f89:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105f8c:	29 d7                	sub    %edx,%edi
c0105f8e:	89 fa                	mov    %edi,%edx
c0105f90:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105f94:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105f98:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105f9c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105fa0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105fa4:	c7 04 24 c0 a3 10 c0 	movl   $0xc010a3c0,(%esp)
c0105fab:	e8 a7 a3 ff ff       	call   c0100357 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105fb0:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105fb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105fb8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105fbb:	89 ce                	mov    %ecx,%esi
c0105fbd:	c1 e6 0a             	shl    $0xa,%esi
c0105fc0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105fc3:	89 cb                	mov    %ecx,%ebx
c0105fc5:	c1 e3 0a             	shl    $0xa,%ebx
c0105fc8:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105fcb:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105fcf:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0105fd2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105fd6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105fda:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105fde:	89 74 24 04          	mov    %esi,0x4(%esp)
c0105fe2:	89 1c 24             	mov    %ebx,(%esp)
c0105fe5:	e8 3c fe ff ff       	call   c0105e26 <get_pgtable_items>
c0105fea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105fed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ff1:	0f 85 65 ff ff ff    	jne    c0105f5c <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105ff7:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0105ffc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105fff:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0106002:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106006:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106009:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010600d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106011:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106015:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010601c:	00 
c010601d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106024:	e8 fd fd ff ff       	call   c0105e26 <get_pgtable_items>
c0106029:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010602c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106030:	0f 85 c7 fe ff ff    	jne    c0105efd <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106036:	c7 04 24 e4 a3 10 c0 	movl   $0xc010a3e4,(%esp)
c010603d:	e8 15 a3 ff ff       	call   c0100357 <cprintf>
}
c0106042:	83 c4 4c             	add    $0x4c,%esp
c0106045:	5b                   	pop    %ebx
c0106046:	5e                   	pop    %esi
c0106047:	5f                   	pop    %edi
c0106048:	5d                   	pop    %ebp
c0106049:	c3                   	ret    

c010604a <kmalloc>:

void *
kmalloc(size_t n) {
c010604a:	55                   	push   %ebp
c010604b:	89 e5                	mov    %esp,%ebp
c010604d:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0106050:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0106057:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c010605e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106062:	74 09                	je     c010606d <kmalloc+0x23>
c0106064:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c010606b:	76 24                	jbe    c0106091 <kmalloc+0x47>
c010606d:	c7 44 24 0c 15 a4 10 	movl   $0xc010a415,0xc(%esp)
c0106074:	c0 
c0106075:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c010607c:	c0 
c010607d:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
c0106084:	00 
c0106085:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c010608c:	e8 5a ac ff ff       	call   c0100ceb <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0106091:	8b 45 08             	mov    0x8(%ebp),%eax
c0106094:	05 ff 0f 00 00       	add    $0xfff,%eax
c0106099:	c1 e8 0c             	shr    $0xc,%eax
c010609c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c010609f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060a2:	89 04 24             	mov    %eax,(%esp)
c01060a5:	e8 f6 e7 ff ff       	call   c01048a0 <alloc_pages>
c01060aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c01060ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01060b1:	75 24                	jne    c01060d7 <kmalloc+0x8d>
c01060b3:	c7 44 24 0c 2c a4 10 	movl   $0xc010a42c,0xc(%esp)
c01060ba:	c0 
c01060bb:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c01060c2:	c0 
c01060c3:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
c01060ca:	00 
c01060cb:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c01060d2:	e8 14 ac ff ff       	call   c0100ceb <__panic>
    ptr=page2kva(base);
c01060d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060da:	89 04 24             	mov    %eax,(%esp)
c01060dd:	e8 c5 e4 ff ff       	call   c01045a7 <page2kva>
c01060e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c01060e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01060e8:	c9                   	leave  
c01060e9:	c3                   	ret    

c01060ea <kfree>:

void 
kfree(void *ptr, size_t n) {
c01060ea:	55                   	push   %ebp
c01060eb:	89 e5                	mov    %esp,%ebp
c01060ed:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c01060f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01060f4:	74 09                	je     c01060ff <kfree+0x15>
c01060f6:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c01060fd:	76 24                	jbe    c0106123 <kfree+0x39>
c01060ff:	c7 44 24 0c 15 a4 10 	movl   $0xc010a415,0xc(%esp)
c0106106:	c0 
c0106107:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c010610e:	c0 
c010610f:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c0106116:	00 
c0106117:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c010611e:	e8 c8 ab ff ff       	call   c0100ceb <__panic>
    assert(ptr != NULL);
c0106123:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106127:	75 24                	jne    c010614d <kfree+0x63>
c0106129:	c7 44 24 0c 39 a4 10 	movl   $0xc010a439,0xc(%esp)
c0106130:	c0 
c0106131:	c7 44 24 08 b9 9e 10 	movl   $0xc0109eb9,0x8(%esp)
c0106138:	c0 
c0106139:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0106140:	00 
c0106141:	c7 04 24 94 9e 10 c0 	movl   $0xc0109e94,(%esp)
c0106148:	e8 9e ab ff ff       	call   c0100ceb <__panic>
    struct Page *base=NULL;
c010614d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0106154:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106157:	05 ff 0f 00 00       	add    $0xfff,%eax
c010615c:	c1 e8 0c             	shr    $0xc,%eax
c010615f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0106162:	8b 45 08             	mov    0x8(%ebp),%eax
c0106165:	89 04 24             	mov    %eax,(%esp)
c0106168:	e8 8e e4 ff ff       	call   c01045fb <kva2page>
c010616d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0106170:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106173:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106177:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010617a:	89 04 24             	mov    %eax,(%esp)
c010617d:	e8 89 e7 ff ff       	call   c010490b <free_pages>
}
c0106182:	c9                   	leave  
c0106183:	c3                   	ret    

c0106184 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0106184:	55                   	push   %ebp
c0106185:	89 e5                	mov    %esp,%ebp
c0106187:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010618a:	8b 45 08             	mov    0x8(%ebp),%eax
c010618d:	c1 e8 0c             	shr    $0xc,%eax
c0106190:	89 c2                	mov    %eax,%edx
c0106192:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0106197:	39 c2                	cmp    %eax,%edx
c0106199:	72 1c                	jb     c01061b7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010619b:	c7 44 24 08 48 a4 10 	movl   $0xc010a448,0x8(%esp)
c01061a2:	c0 
c01061a3:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01061aa:	00 
c01061ab:	c7 04 24 67 a4 10 c0 	movl   $0xc010a467,(%esp)
c01061b2:	e8 34 ab ff ff       	call   c0100ceb <__panic>
    }
    return &pages[PPN(pa)];
c01061b7:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c01061bc:	8b 55 08             	mov    0x8(%ebp),%edx
c01061bf:	c1 ea 0c             	shr    $0xc,%edx
c01061c2:	c1 e2 05             	shl    $0x5,%edx
c01061c5:	01 d0                	add    %edx,%eax
}
c01061c7:	c9                   	leave  
c01061c8:	c3                   	ret    

c01061c9 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01061c9:	55                   	push   %ebp
c01061ca:	89 e5                	mov    %esp,%ebp
c01061cc:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01061cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01061d2:	83 e0 01             	and    $0x1,%eax
c01061d5:	85 c0                	test   %eax,%eax
c01061d7:	75 1c                	jne    c01061f5 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01061d9:	c7 44 24 08 78 a4 10 	movl   $0xc010a478,0x8(%esp)
c01061e0:	c0 
c01061e1:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01061e8:	00 
c01061e9:	c7 04 24 67 a4 10 c0 	movl   $0xc010a467,(%esp)
c01061f0:	e8 f6 aa ff ff       	call   c0100ceb <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01061f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01061f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01061fd:	89 04 24             	mov    %eax,(%esp)
c0106200:	e8 7f ff ff ff       	call   c0106184 <pa2page>
}
c0106205:	c9                   	leave  
c0106206:	c3                   	ret    

c0106207 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106207:	55                   	push   %ebp
c0106208:	89 e5                	mov    %esp,%ebp
c010620a:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c010620d:	e8 07 22 00 00       	call   c0108419 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106212:	a1 5c 41 12 c0       	mov    0xc012415c,%eax
c0106217:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c010621c:	76 0c                	jbe    c010622a <swap_init+0x23>
c010621e:	a1 5c 41 12 c0       	mov    0xc012415c,%eax
c0106223:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106228:	76 25                	jbe    c010624f <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c010622a:	a1 5c 41 12 c0       	mov    0xc012415c,%eax
c010622f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106233:	c7 44 24 08 99 a4 10 	movl   $0xc010a499,0x8(%esp)
c010623a:	c0 
c010623b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0106242:	00 
c0106243:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c010624a:	e8 9c aa ff ff       	call   c0100ceb <__panic>
     }
     

     sm = &swap_manager_fifo;
c010624f:	c7 05 34 40 12 c0 40 	movl   $0xc0120a40,0xc0124034
c0106256:	0a 12 c0 
     int r = sm->init();
c0106259:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c010625e:	8b 40 04             	mov    0x4(%eax),%eax
c0106261:	ff d0                	call   *%eax
c0106263:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106266:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010626a:	75 26                	jne    c0106292 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c010626c:	c7 05 2c 40 12 c0 01 	movl   $0x1,0xc012402c
c0106273:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106276:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c010627b:	8b 00                	mov    (%eax),%eax
c010627d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106281:	c7 04 24 c3 a4 10 c0 	movl   $0xc010a4c3,(%esp)
c0106288:	e8 ca a0 ff ff       	call   c0100357 <cprintf>
          check_swap();
c010628d:	e8 a4 04 00 00       	call   c0106736 <check_swap>
     }

     return r;
c0106292:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106295:	c9                   	leave  
c0106296:	c3                   	ret    

c0106297 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106297:	55                   	push   %ebp
c0106298:	89 e5                	mov    %esp,%ebp
c010629a:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c010629d:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01062a2:	8b 40 08             	mov    0x8(%eax),%eax
c01062a5:	8b 55 08             	mov    0x8(%ebp),%edx
c01062a8:	89 14 24             	mov    %edx,(%esp)
c01062ab:	ff d0                	call   *%eax
}
c01062ad:	c9                   	leave  
c01062ae:	c3                   	ret    

c01062af <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01062af:	55                   	push   %ebp
c01062b0:	89 e5                	mov    %esp,%ebp
c01062b2:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01062b5:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01062ba:	8b 40 0c             	mov    0xc(%eax),%eax
c01062bd:	8b 55 08             	mov    0x8(%ebp),%edx
c01062c0:	89 14 24             	mov    %edx,(%esp)
c01062c3:	ff d0                	call   *%eax
}
c01062c5:	c9                   	leave  
c01062c6:	c3                   	ret    

c01062c7 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01062c7:	55                   	push   %ebp
c01062c8:	89 e5                	mov    %esp,%ebp
c01062ca:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01062cd:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01062d2:	8b 40 10             	mov    0x10(%eax),%eax
c01062d5:	8b 55 14             	mov    0x14(%ebp),%edx
c01062d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01062dc:	8b 55 10             	mov    0x10(%ebp),%edx
c01062df:	89 54 24 08          	mov    %edx,0x8(%esp)
c01062e3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01062e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062ea:	8b 55 08             	mov    0x8(%ebp),%edx
c01062ed:	89 14 24             	mov    %edx,(%esp)
c01062f0:	ff d0                	call   *%eax
}
c01062f2:	c9                   	leave  
c01062f3:	c3                   	ret    

c01062f4 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01062f4:	55                   	push   %ebp
c01062f5:	89 e5                	mov    %esp,%ebp
c01062f7:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01062fa:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01062ff:	8b 40 14             	mov    0x14(%eax),%eax
c0106302:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106305:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106309:	8b 55 08             	mov    0x8(%ebp),%edx
c010630c:	89 14 24             	mov    %edx,(%esp)
c010630f:	ff d0                	call   *%eax
}
c0106311:	c9                   	leave  
c0106312:	c3                   	ret    

c0106313 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106313:	55                   	push   %ebp
c0106314:	89 e5                	mov    %esp,%ebp
c0106316:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106319:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106320:	e9 5a 01 00 00       	jmp    c010647f <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106325:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c010632a:	8b 40 18             	mov    0x18(%eax),%eax
c010632d:	8b 55 10             	mov    0x10(%ebp),%edx
c0106330:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106334:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106337:	89 54 24 04          	mov    %edx,0x4(%esp)
c010633b:	8b 55 08             	mov    0x8(%ebp),%edx
c010633e:	89 14 24             	mov    %edx,(%esp)
c0106341:	ff d0                	call   *%eax
c0106343:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106346:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010634a:	74 18                	je     c0106364 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c010634c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010634f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106353:	c7 04 24 d8 a4 10 c0 	movl   $0xc010a4d8,(%esp)
c010635a:	e8 f8 9f ff ff       	call   c0100357 <cprintf>
c010635f:	e9 27 01 00 00       	jmp    c010648b <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106367:	8b 40 1c             	mov    0x1c(%eax),%eax
c010636a:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010636d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106370:	8b 40 0c             	mov    0xc(%eax),%eax
c0106373:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010637a:	00 
c010637b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010637e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106382:	89 04 24             	mov    %eax,(%esp)
c0106385:	e8 f5 eb ff ff       	call   c0104f7f <get_pte>
c010638a:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010638d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106390:	8b 00                	mov    (%eax),%eax
c0106392:	83 e0 01             	and    $0x1,%eax
c0106395:	85 c0                	test   %eax,%eax
c0106397:	75 24                	jne    c01063bd <swap_out+0xaa>
c0106399:	c7 44 24 0c 05 a5 10 	movl   $0xc010a505,0xc(%esp)
c01063a0:	c0 
c01063a1:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01063a8:	c0 
c01063a9:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01063b0:	00 
c01063b1:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01063b8:	e8 2e a9 ff ff       	call   c0100ceb <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01063bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01063c3:	8b 52 1c             	mov    0x1c(%edx),%edx
c01063c6:	c1 ea 0c             	shr    $0xc,%edx
c01063c9:	83 c2 01             	add    $0x1,%edx
c01063cc:	c1 e2 08             	shl    $0x8,%edx
c01063cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01063d3:	89 14 24             	mov    %edx,(%esp)
c01063d6:	e8 f8 20 00 00       	call   c01084d3 <swapfs_write>
c01063db:	85 c0                	test   %eax,%eax
c01063dd:	74 34                	je     c0106413 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c01063df:	c7 04 24 2f a5 10 c0 	movl   $0xc010a52f,(%esp)
c01063e6:	e8 6c 9f ff ff       	call   c0100357 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01063eb:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01063f0:	8b 40 10             	mov    0x10(%eax),%eax
c01063f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01063f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01063fd:	00 
c01063fe:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106402:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106405:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106409:	8b 55 08             	mov    0x8(%ebp),%edx
c010640c:	89 14 24             	mov    %edx,(%esp)
c010640f:	ff d0                	call   *%eax
c0106411:	eb 68                	jmp    c010647b <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106413:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106416:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106419:	c1 e8 0c             	shr    $0xc,%eax
c010641c:	83 c0 01             	add    $0x1,%eax
c010641f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106423:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106426:	89 44 24 08          	mov    %eax,0x8(%esp)
c010642a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010642d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106431:	c7 04 24 48 a5 10 c0 	movl   $0xc010a548,(%esp)
c0106438:	e8 1a 9f ff ff       	call   c0100357 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010643d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106440:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106443:	c1 e8 0c             	shr    $0xc,%eax
c0106446:	83 c0 01             	add    $0x1,%eax
c0106449:	c1 e0 08             	shl    $0x8,%eax
c010644c:	89 c2                	mov    %eax,%edx
c010644e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106451:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106453:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106456:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010645d:	00 
c010645e:	89 04 24             	mov    %eax,(%esp)
c0106461:	e8 a5 e4 ff ff       	call   c010490b <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106466:	8b 45 08             	mov    0x8(%ebp),%eax
c0106469:	8b 40 0c             	mov    0xc(%eax),%eax
c010646c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010646f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106473:	89 04 24             	mov    %eax,(%esp)
c0106476:	e8 f3 ed ff ff       	call   c010526e <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c010647b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010647f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106482:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106485:	0f 85 9a fe ff ff    	jne    c0106325 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c010648b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010648e:	c9                   	leave  
c010648f:	c3                   	ret    

c0106490 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106490:	55                   	push   %ebp
c0106491:	89 e5                	mov    %esp,%ebp
c0106493:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106496:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010649d:	e8 fe e3 ff ff       	call   c01048a0 <alloc_pages>
c01064a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01064a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01064a9:	75 24                	jne    c01064cf <swap_in+0x3f>
c01064ab:	c7 44 24 0c 88 a5 10 	movl   $0xc010a588,0xc(%esp)
c01064b2:	c0 
c01064b3:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01064ba:	c0 
c01064bb:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c01064c2:	00 
c01064c3:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01064ca:	e8 1c a8 ff ff       	call   c0100ceb <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01064cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01064d2:	8b 40 0c             	mov    0xc(%eax),%eax
c01064d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01064dc:	00 
c01064dd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01064e0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064e4:	89 04 24             	mov    %eax,(%esp)
c01064e7:	e8 93 ea ff ff       	call   c0104f7f <get_pte>
c01064ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01064ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064f2:	8b 00                	mov    (%eax),%eax
c01064f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01064f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064fb:	89 04 24             	mov    %eax,(%esp)
c01064fe:	e8 5e 1f 00 00       	call   c0108461 <swapfs_read>
c0106503:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106506:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010650a:	74 2a                	je     c0106536 <swap_in+0xa6>
     {
        assert(r!=0);
c010650c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106510:	75 24                	jne    c0106536 <swap_in+0xa6>
c0106512:	c7 44 24 0c 95 a5 10 	movl   $0xc010a595,0xc(%esp)
c0106519:	c0 
c010651a:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106521:	c0 
c0106522:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0106529:	00 
c010652a:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106531:	e8 b5 a7 ff ff       	call   c0100ceb <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106536:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106539:	8b 00                	mov    (%eax),%eax
c010653b:	c1 e8 08             	shr    $0x8,%eax
c010653e:	89 c2                	mov    %eax,%edx
c0106540:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106543:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106547:	89 54 24 04          	mov    %edx,0x4(%esp)
c010654b:	c7 04 24 9c a5 10 c0 	movl   $0xc010a59c,(%esp)
c0106552:	e8 00 9e ff ff       	call   c0100357 <cprintf>
     *ptr_result=result;
c0106557:	8b 45 10             	mov    0x10(%ebp),%eax
c010655a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010655d:	89 10                	mov    %edx,(%eax)
     return 0;
c010655f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106564:	c9                   	leave  
c0106565:	c3                   	ret    

c0106566 <check_content_set>:



static inline void
check_content_set(void)
{
c0106566:	55                   	push   %ebp
c0106567:	89 e5                	mov    %esp,%ebp
c0106569:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010656c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106571:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106574:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106579:	83 f8 01             	cmp    $0x1,%eax
c010657c:	74 24                	je     c01065a2 <check_content_set+0x3c>
c010657e:	c7 44 24 0c da a5 10 	movl   $0xc010a5da,0xc(%esp)
c0106585:	c0 
c0106586:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c010658d:	c0 
c010658e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0106595:	00 
c0106596:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c010659d:	e8 49 a7 ff ff       	call   c0100ceb <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01065a2:	b8 10 10 00 00       	mov    $0x1010,%eax
c01065a7:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01065aa:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01065af:	83 f8 01             	cmp    $0x1,%eax
c01065b2:	74 24                	je     c01065d8 <check_content_set+0x72>
c01065b4:	c7 44 24 0c da a5 10 	movl   $0xc010a5da,0xc(%esp)
c01065bb:	c0 
c01065bc:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01065c3:	c0 
c01065c4:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01065cb:	00 
c01065cc:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01065d3:	e8 13 a7 ff ff       	call   c0100ceb <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01065d8:	b8 00 20 00 00       	mov    $0x2000,%eax
c01065dd:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01065e0:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01065e5:	83 f8 02             	cmp    $0x2,%eax
c01065e8:	74 24                	je     c010660e <check_content_set+0xa8>
c01065ea:	c7 44 24 0c e9 a5 10 	movl   $0xc010a5e9,0xc(%esp)
c01065f1:	c0 
c01065f2:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01065f9:	c0 
c01065fa:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0106601:	00 
c0106602:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106609:	e8 dd a6 ff ff       	call   c0100ceb <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c010660e:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106613:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106616:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010661b:	83 f8 02             	cmp    $0x2,%eax
c010661e:	74 24                	je     c0106644 <check_content_set+0xde>
c0106620:	c7 44 24 0c e9 a5 10 	movl   $0xc010a5e9,0xc(%esp)
c0106627:	c0 
c0106628:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c010662f:	c0 
c0106630:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106637:	00 
c0106638:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c010663f:	e8 a7 a6 ff ff       	call   c0100ceb <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106644:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106649:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010664c:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106651:	83 f8 03             	cmp    $0x3,%eax
c0106654:	74 24                	je     c010667a <check_content_set+0x114>
c0106656:	c7 44 24 0c f8 a5 10 	movl   $0xc010a5f8,0xc(%esp)
c010665d:	c0 
c010665e:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106665:	c0 
c0106666:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c010666d:	00 
c010666e:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106675:	e8 71 a6 ff ff       	call   c0100ceb <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c010667a:	b8 10 30 00 00       	mov    $0x3010,%eax
c010667f:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106682:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106687:	83 f8 03             	cmp    $0x3,%eax
c010668a:	74 24                	je     c01066b0 <check_content_set+0x14a>
c010668c:	c7 44 24 0c f8 a5 10 	movl   $0xc010a5f8,0xc(%esp)
c0106693:	c0 
c0106694:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c010669b:	c0 
c010669c:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01066a3:	00 
c01066a4:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01066ab:	e8 3b a6 ff ff       	call   c0100ceb <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01066b0:	b8 00 40 00 00       	mov    $0x4000,%eax
c01066b5:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01066b8:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01066bd:	83 f8 04             	cmp    $0x4,%eax
c01066c0:	74 24                	je     c01066e6 <check_content_set+0x180>
c01066c2:	c7 44 24 0c 07 a6 10 	movl   $0xc010a607,0xc(%esp)
c01066c9:	c0 
c01066ca:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01066d1:	c0 
c01066d2:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01066d9:	00 
c01066da:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01066e1:	e8 05 a6 ff ff       	call   c0100ceb <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01066e6:	b8 10 40 00 00       	mov    $0x4010,%eax
c01066eb:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01066ee:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01066f3:	83 f8 04             	cmp    $0x4,%eax
c01066f6:	74 24                	je     c010671c <check_content_set+0x1b6>
c01066f8:	c7 44 24 0c 07 a6 10 	movl   $0xc010a607,0xc(%esp)
c01066ff:	c0 
c0106700:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106707:	c0 
c0106708:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c010670f:	00 
c0106710:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106717:	e8 cf a5 ff ff       	call   c0100ceb <__panic>
}
c010671c:	c9                   	leave  
c010671d:	c3                   	ret    

c010671e <check_content_access>:

static inline int
check_content_access(void)
{
c010671e:	55                   	push   %ebp
c010671f:	89 e5                	mov    %esp,%ebp
c0106721:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106724:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106729:	8b 40 1c             	mov    0x1c(%eax),%eax
c010672c:	ff d0                	call   *%eax
c010672e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106731:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106734:	c9                   	leave  
c0106735:	c3                   	ret    

c0106736 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106736:	55                   	push   %ebp
c0106737:	89 e5                	mov    %esp,%ebp
c0106739:	53                   	push   %ebx
c010673a:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010673d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106744:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010674b:	c7 45 e8 90 40 12 c0 	movl   $0xc0124090,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106752:	eb 6b                	jmp    c01067bf <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0106754:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106757:	83 e8 0c             	sub    $0xc,%eax
c010675a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c010675d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106760:	83 c0 04             	add    $0x4,%eax
c0106763:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010676a:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010676d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106770:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106773:	0f a3 10             	bt     %edx,(%eax)
c0106776:	19 c0                	sbb    %eax,%eax
c0106778:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c010677b:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010677f:	0f 95 c0             	setne  %al
c0106782:	0f b6 c0             	movzbl %al,%eax
c0106785:	85 c0                	test   %eax,%eax
c0106787:	75 24                	jne    c01067ad <check_swap+0x77>
c0106789:	c7 44 24 0c 16 a6 10 	movl   $0xc010a616,0xc(%esp)
c0106790:	c0 
c0106791:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106798:	c0 
c0106799:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c01067a0:	00 
c01067a1:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01067a8:	e8 3e a5 ff ff       	call   c0100ceb <__panic>
        count ++, total += p->property;
c01067ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01067b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067b4:	8b 50 08             	mov    0x8(%eax),%edx
c01067b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01067ba:	01 d0                	add    %edx,%eax
c01067bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01067bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01067c2:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01067c5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01067c8:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01067cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01067ce:	81 7d e8 90 40 12 c0 	cmpl   $0xc0124090,-0x18(%ebp)
c01067d5:	0f 85 79 ff ff ff    	jne    c0106754 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01067db:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01067de:	e8 5a e1 ff ff       	call   c010493d <nr_free_pages>
c01067e3:	39 c3                	cmp    %eax,%ebx
c01067e5:	74 24                	je     c010680b <check_swap+0xd5>
c01067e7:	c7 44 24 0c 26 a6 10 	movl   $0xc010a626,0xc(%esp)
c01067ee:	c0 
c01067ef:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01067f6:	c0 
c01067f7:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01067fe:	00 
c01067ff:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106806:	e8 e0 a4 ff ff       	call   c0100ceb <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c010680b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010680e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106812:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106815:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106819:	c7 04 24 40 a6 10 c0 	movl   $0xc010a640,(%esp)
c0106820:	e8 32 9b ff ff       	call   c0100357 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106825:	e8 35 0e 00 00       	call   c010765f <mm_create>
c010682a:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c010682d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106831:	75 24                	jne    c0106857 <check_swap+0x121>
c0106833:	c7 44 24 0c 66 a6 10 	movl   $0xc010a666,0xc(%esp)
c010683a:	c0 
c010683b:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106842:	c0 
c0106843:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c010684a:	00 
c010684b:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106852:	e8 94 a4 ff ff       	call   c0100ceb <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106857:	a1 8c 41 12 c0       	mov    0xc012418c,%eax
c010685c:	85 c0                	test   %eax,%eax
c010685e:	74 24                	je     c0106884 <check_swap+0x14e>
c0106860:	c7 44 24 0c 71 a6 10 	movl   $0xc010a671,0xc(%esp)
c0106867:	c0 
c0106868:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c010686f:	c0 
c0106870:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0106877:	00 
c0106878:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c010687f:	e8 67 a4 ff ff       	call   c0100ceb <__panic>

     check_mm_struct = mm;
c0106884:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106887:	a3 8c 41 12 c0       	mov    %eax,0xc012418c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c010688c:	8b 15 e0 09 12 c0    	mov    0xc01209e0,%edx
c0106892:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106895:	89 50 0c             	mov    %edx,0xc(%eax)
c0106898:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010689b:	8b 40 0c             	mov    0xc(%eax),%eax
c010689e:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c01068a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01068a4:	8b 00                	mov    (%eax),%eax
c01068a6:	85 c0                	test   %eax,%eax
c01068a8:	74 24                	je     c01068ce <check_swap+0x198>
c01068aa:	c7 44 24 0c 89 a6 10 	movl   $0xc010a689,0xc(%esp)
c01068b1:	c0 
c01068b2:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01068b9:	c0 
c01068ba:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01068c1:	00 
c01068c2:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01068c9:	e8 1d a4 ff ff       	call   c0100ceb <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01068ce:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01068d5:	00 
c01068d6:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01068dd:	00 
c01068de:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01068e5:	e8 ed 0d 00 00       	call   c01076d7 <vma_create>
c01068ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c01068ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01068f1:	75 24                	jne    c0106917 <check_swap+0x1e1>
c01068f3:	c7 44 24 0c 97 a6 10 	movl   $0xc010a697,0xc(%esp)
c01068fa:	c0 
c01068fb:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106902:	c0 
c0106903:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010690a:	00 
c010690b:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106912:	e8 d4 a3 ff ff       	call   c0100ceb <__panic>

     insert_vma_struct(mm, vma);
c0106917:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010691a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010691e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106921:	89 04 24             	mov    %eax,(%esp)
c0106924:	e8 3e 0f 00 00       	call   c0107867 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106929:	c7 04 24 a4 a6 10 c0 	movl   $0xc010a6a4,(%esp)
c0106930:	e8 22 9a ff ff       	call   c0100357 <cprintf>
     pte_t *temp_ptep=NULL;
c0106935:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c010693c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010693f:	8b 40 0c             	mov    0xc(%eax),%eax
c0106942:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106949:	00 
c010694a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106951:	00 
c0106952:	89 04 24             	mov    %eax,(%esp)
c0106955:	e8 25 e6 ff ff       	call   c0104f7f <get_pte>
c010695a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c010695d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0106961:	75 24                	jne    c0106987 <check_swap+0x251>
c0106963:	c7 44 24 0c d8 a6 10 	movl   $0xc010a6d8,0xc(%esp)
c010696a:	c0 
c010696b:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106972:	c0 
c0106973:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c010697a:	00 
c010697b:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106982:	e8 64 a3 ff ff       	call   c0100ceb <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106987:	c7 04 24 ec a6 10 c0 	movl   $0xc010a6ec,(%esp)
c010698e:	e8 c4 99 ff ff       	call   c0100357 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106993:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010699a:	e9 a3 00 00 00       	jmp    c0106a42 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c010699f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069a6:	e8 f5 de ff ff       	call   c01048a0 <alloc_pages>
c01069ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01069ae:	89 04 95 c0 40 12 c0 	mov    %eax,-0x3fedbf40(,%edx,4)
          assert(check_rp[i] != NULL );
c01069b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01069b8:	8b 04 85 c0 40 12 c0 	mov    -0x3fedbf40(,%eax,4),%eax
c01069bf:	85 c0                	test   %eax,%eax
c01069c1:	75 24                	jne    c01069e7 <check_swap+0x2b1>
c01069c3:	c7 44 24 0c 10 a7 10 	movl   $0xc010a710,0xc(%esp)
c01069ca:	c0 
c01069cb:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c01069d2:	c0 
c01069d3:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01069da:	00 
c01069db:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c01069e2:	e8 04 a3 ff ff       	call   c0100ceb <__panic>
          assert(!PageProperty(check_rp[i]));
c01069e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01069ea:	8b 04 85 c0 40 12 c0 	mov    -0x3fedbf40(,%eax,4),%eax
c01069f1:	83 c0 04             	add    $0x4,%eax
c01069f4:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01069fb:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01069fe:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106a01:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106a04:	0f a3 10             	bt     %edx,(%eax)
c0106a07:	19 c0                	sbb    %eax,%eax
c0106a09:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106a0c:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106a10:	0f 95 c0             	setne  %al
c0106a13:	0f b6 c0             	movzbl %al,%eax
c0106a16:	85 c0                	test   %eax,%eax
c0106a18:	74 24                	je     c0106a3e <check_swap+0x308>
c0106a1a:	c7 44 24 0c 24 a7 10 	movl   $0xc010a724,0xc(%esp)
c0106a21:	c0 
c0106a22:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106a29:	c0 
c0106a2a:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0106a31:	00 
c0106a32:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106a39:	e8 ad a2 ff ff       	call   c0100ceb <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106a3e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106a42:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106a46:	0f 8e 53 ff ff ff    	jle    c010699f <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c0106a4c:	a1 90 40 12 c0       	mov    0xc0124090,%eax
c0106a51:	8b 15 94 40 12 c0    	mov    0xc0124094,%edx
c0106a57:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106a5a:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106a5d:	c7 45 a8 90 40 12 c0 	movl   $0xc0124090,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106a64:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106a67:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106a6a:	89 50 04             	mov    %edx,0x4(%eax)
c0106a6d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106a70:	8b 50 04             	mov    0x4(%eax),%edx
c0106a73:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106a76:	89 10                	mov    %edx,(%eax)
c0106a78:	c7 45 a4 90 40 12 c0 	movl   $0xc0124090,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0106a7f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106a82:	8b 40 04             	mov    0x4(%eax),%eax
c0106a85:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0106a88:	0f 94 c0             	sete   %al
c0106a8b:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106a8e:	85 c0                	test   %eax,%eax
c0106a90:	75 24                	jne    c0106ab6 <check_swap+0x380>
c0106a92:	c7 44 24 0c 3f a7 10 	movl   $0xc010a73f,0xc(%esp)
c0106a99:	c0 
c0106a9a:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106aa1:	c0 
c0106aa2:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0106aa9:	00 
c0106aaa:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106ab1:	e8 35 a2 ff ff       	call   c0100ceb <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106ab6:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0106abb:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0106abe:	c7 05 98 40 12 c0 00 	movl   $0x0,0xc0124098
c0106ac5:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ac8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106acf:	eb 1e                	jmp    c0106aef <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0106ad1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ad4:	8b 04 85 c0 40 12 c0 	mov    -0x3fedbf40(,%eax,4),%eax
c0106adb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ae2:	00 
c0106ae3:	89 04 24             	mov    %eax,(%esp)
c0106ae6:	e8 20 de ff ff       	call   c010490b <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106aeb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106aef:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106af3:	7e dc                	jle    c0106ad1 <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0106af5:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0106afa:	83 f8 04             	cmp    $0x4,%eax
c0106afd:	74 24                	je     c0106b23 <check_swap+0x3ed>
c0106aff:	c7 44 24 0c 58 a7 10 	movl   $0xc010a758,0xc(%esp)
c0106b06:	c0 
c0106b07:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106b0e:	c0 
c0106b0f:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0106b16:	00 
c0106b17:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106b1e:	e8 c8 a1 ff ff       	call   c0100ceb <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106b23:	c7 04 24 7c a7 10 c0 	movl   $0xc010a77c,(%esp)
c0106b2a:	e8 28 98 ff ff       	call   c0100357 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106b2f:	c7 05 38 40 12 c0 00 	movl   $0x0,0xc0124038
c0106b36:	00 00 00 
     
     check_content_set();
c0106b39:	e8 28 fa ff ff       	call   c0106566 <check_content_set>
     assert( nr_free == 0);         
c0106b3e:	a1 98 40 12 c0       	mov    0xc0124098,%eax
c0106b43:	85 c0                	test   %eax,%eax
c0106b45:	74 24                	je     c0106b6b <check_swap+0x435>
c0106b47:	c7 44 24 0c a3 a7 10 	movl   $0xc010a7a3,0xc(%esp)
c0106b4e:	c0 
c0106b4f:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106b56:	c0 
c0106b57:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106b5e:	00 
c0106b5f:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106b66:	e8 80 a1 ff ff       	call   c0100ceb <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106b6b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106b72:	eb 26                	jmp    c0106b9a <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106b74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b77:	c7 04 85 e0 40 12 c0 	movl   $0xffffffff,-0x3fedbf20(,%eax,4)
c0106b7e:	ff ff ff ff 
c0106b82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b85:	8b 14 85 e0 40 12 c0 	mov    -0x3fedbf20(,%eax,4),%edx
c0106b8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b8f:	89 14 85 20 41 12 c0 	mov    %edx,-0x3fedbee0(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106b96:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106b9a:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106b9e:	7e d4                	jle    c0106b74 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ba0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ba7:	e9 eb 00 00 00       	jmp    c0106c97 <check_swap+0x561>
         check_ptep[i]=0;
c0106bac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106baf:	c7 04 85 74 41 12 c0 	movl   $0x0,-0x3fedbe8c(,%eax,4)
c0106bb6:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106bba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bbd:	83 c0 01             	add    $0x1,%eax
c0106bc0:	c1 e0 0c             	shl    $0xc,%eax
c0106bc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106bca:	00 
c0106bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bcf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106bd2:	89 04 24             	mov    %eax,(%esp)
c0106bd5:	e8 a5 e3 ff ff       	call   c0104f7f <get_pte>
c0106bda:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106bdd:	89 04 95 74 41 12 c0 	mov    %eax,-0x3fedbe8c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106be7:	8b 04 85 74 41 12 c0 	mov    -0x3fedbe8c(,%eax,4),%eax
c0106bee:	85 c0                	test   %eax,%eax
c0106bf0:	75 24                	jne    c0106c16 <check_swap+0x4e0>
c0106bf2:	c7 44 24 0c b0 a7 10 	movl   $0xc010a7b0,0xc(%esp)
c0106bf9:	c0 
c0106bfa:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106c01:	c0 
c0106c02:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0106c09:	00 
c0106c0a:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106c11:	e8 d5 a0 ff ff       	call   c0100ceb <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106c16:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c19:	8b 04 85 74 41 12 c0 	mov    -0x3fedbe8c(,%eax,4),%eax
c0106c20:	8b 00                	mov    (%eax),%eax
c0106c22:	89 04 24             	mov    %eax,(%esp)
c0106c25:	e8 9f f5 ff ff       	call   c01061c9 <pte2page>
c0106c2a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106c2d:	8b 14 95 c0 40 12 c0 	mov    -0x3fedbf40(,%edx,4),%edx
c0106c34:	39 d0                	cmp    %edx,%eax
c0106c36:	74 24                	je     c0106c5c <check_swap+0x526>
c0106c38:	c7 44 24 0c c8 a7 10 	movl   $0xc010a7c8,0xc(%esp)
c0106c3f:	c0 
c0106c40:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106c47:	c0 
c0106c48:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106c4f:	00 
c0106c50:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106c57:	e8 8f a0 ff ff       	call   c0100ceb <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c5f:	8b 04 85 74 41 12 c0 	mov    -0x3fedbe8c(,%eax,4),%eax
c0106c66:	8b 00                	mov    (%eax),%eax
c0106c68:	83 e0 01             	and    $0x1,%eax
c0106c6b:	85 c0                	test   %eax,%eax
c0106c6d:	75 24                	jne    c0106c93 <check_swap+0x55d>
c0106c6f:	c7 44 24 0c f0 a7 10 	movl   $0xc010a7f0,0xc(%esp)
c0106c76:	c0 
c0106c77:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106c7e:	c0 
c0106c7f:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106c86:	00 
c0106c87:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106c8e:	e8 58 a0 ff ff       	call   c0100ceb <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106c93:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106c97:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106c9b:	0f 8e 0b ff ff ff    	jle    c0106bac <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0106ca1:	c7 04 24 0c a8 10 c0 	movl   $0xc010a80c,(%esp)
c0106ca8:	e8 aa 96 ff ff       	call   c0100357 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106cad:	e8 6c fa ff ff       	call   c010671e <check_content_access>
c0106cb2:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0106cb5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106cb9:	74 24                	je     c0106cdf <check_swap+0x5a9>
c0106cbb:	c7 44 24 0c 32 a8 10 	movl   $0xc010a832,0xc(%esp)
c0106cc2:	c0 
c0106cc3:	c7 44 24 08 1a a5 10 	movl   $0xc010a51a,0x8(%esp)
c0106cca:	c0 
c0106ccb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106cd2:	00 
c0106cd3:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c0106cda:	e8 0c a0 ff ff       	call   c0100ceb <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106cdf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ce6:	eb 1e                	jmp    c0106d06 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c0106ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ceb:	8b 04 85 c0 40 12 c0 	mov    -0x3fedbf40(,%eax,4),%eax
c0106cf2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106cf9:	00 
c0106cfa:	89 04 24             	mov    %eax,(%esp)
c0106cfd:	e8 09 dc ff ff       	call   c010490b <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106d02:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106d06:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106d0a:	7e dc                	jle    c0106ce8 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0106d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d0f:	89 04 24             	mov    %eax,(%esp)
c0106d12:	e8 80 0c 00 00       	call   c0107997 <mm_destroy>
         
     nr_free = nr_free_store;
c0106d17:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106d1a:	a3 98 40 12 c0       	mov    %eax,0xc0124098
     free_list = free_list_store;
c0106d1f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106d22:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106d25:	a3 90 40 12 c0       	mov    %eax,0xc0124090
c0106d2a:	89 15 94 40 12 c0    	mov    %edx,0xc0124094

     
     le = &free_list;
c0106d30:	c7 45 e8 90 40 12 c0 	movl   $0xc0124090,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106d37:	eb 1d                	jmp    c0106d56 <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c0106d39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d3c:	83 e8 0c             	sub    $0xc,%eax
c0106d3f:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0106d42:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106d46:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106d49:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106d4c:	8b 40 08             	mov    0x8(%eax),%eax
c0106d4f:	29 c2                	sub    %eax,%edx
c0106d51:	89 d0                	mov    %edx,%eax
c0106d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d59:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106d5c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106d5f:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0106d62:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106d65:	81 7d e8 90 40 12 c0 	cmpl   $0xc0124090,-0x18(%ebp)
c0106d6c:	75 cb                	jne    c0106d39 <check_swap+0x603>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d71:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d7c:	c7 04 24 39 a8 10 c0 	movl   $0xc010a839,(%esp)
c0106d83:	e8 cf 95 ff ff       	call   c0100357 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106d88:	c7 04 24 53 a8 10 c0 	movl   $0xc010a853,(%esp)
c0106d8f:	e8 c3 95 ff ff       	call   c0100357 <cprintf>
}
c0106d94:	83 c4 74             	add    $0x74,%esp
c0106d97:	5b                   	pop    %ebx
c0106d98:	5d                   	pop    %ebp
c0106d99:	c3                   	ret    

c0106d9a <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0106d9a:	55                   	push   %ebp
c0106d9b:	89 e5                	mov    %esp,%ebp
c0106d9d:	83 ec 10             	sub    $0x10,%esp
c0106da0:	c7 45 fc 84 41 12 c0 	movl   $0xc0124184,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106daa:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106dad:	89 50 04             	mov    %edx,0x4(%eax)
c0106db0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106db3:	8b 50 04             	mov    0x4(%eax),%edx
c0106db6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106db9:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0106dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dbe:	c7 40 14 84 41 12 c0 	movl   $0xc0124184,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0106dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106dca:	c9                   	leave  
c0106dcb:	c3                   	ret    

c0106dcc <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106dcc:	55                   	push   %ebp
c0106dcd:	89 e5                	mov    %esp,%ebp
c0106dcf:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dd5:	8b 40 14             	mov    0x14(%eax),%eax
c0106dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0106ddb:	8b 45 10             	mov    0x10(%ebp),%eax
c0106dde:	83 c0 14             	add    $0x14,%eax
c0106de1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0106de4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106de8:	74 06                	je     c0106df0 <_fifo_map_swappable+0x24>
c0106dea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106dee:	75 24                	jne    c0106e14 <_fifo_map_swappable+0x48>
c0106df0:	c7 44 24 0c 6c a8 10 	movl   $0xc010a86c,0xc(%esp)
c0106df7:	c0 
c0106df8:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0106dff:	c0 
c0106e00:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0106e07:	00 
c0106e08:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0106e0f:	e8 d7 9e ff ff       	call   c0100ceb <__panic>
c0106e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e17:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e1d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106e26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e29:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e2f:	8b 40 04             	mov    0x4(%eax),%eax
c0106e32:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106e35:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106e38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106e3b:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0106e3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106e41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e44:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e47:	89 10                	mov    %edx,(%eax)
c0106e49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e4c:	8b 10                	mov    (%eax),%edx
c0106e4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106e51:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106e54:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e57:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e5a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106e5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e60:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106e63:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
	list_add(head, entry);
    return 0;
c0106e65:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106e6a:	c9                   	leave  
c0106e6b:	c3                   	ret    

c0106e6c <_fifo_swap_out_victim>:
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==11);
    return 0;
}*/
static int _fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0106e6c:	55                   	push   %ebp
c0106e6d:	89 e5                	mov    %esp,%ebp
c0106e6f:	83 ec 78             	sub    $0x78,%esp
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
c0106e72:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e75:	8b 40 14             	mov    0x14(%eax),%eax
c0106e78:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head != NULL);
c0106e7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106e7f:	75 24                	jne    c0106ea5 <_fifo_swap_out_victim+0x39>
c0106e81:	c7 44 24 0c b3 a8 10 	movl   $0xc010a8b3,0xc(%esp)
c0106e88:	c0 
c0106e89:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0106e90:	c0 
c0106e91:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0106e98:	00 
c0106e99:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0106ea0:	e8 46 9e ff ff       	call   c0100ceb <__panic>
    assert(in_tick == 0);
c0106ea5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106ea9:	74 24                	je     c0106ecf <_fifo_swap_out_victim+0x63>
c0106eab:	c7 44 24 0c c0 a8 10 	movl   $0xc010a8c0,0xc(%esp)
c0106eb2:	c0 
c0106eb3:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0106eba:	c0 
c0106ebb:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c0106ec2:	00 
c0106ec3:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0106eca:	e8 1c 9e ff ff       	call   c0100ceb <__panic>
    // 将 head 指针指向最先进入的页面
    list_entry_t *le = head->next;
c0106ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ed2:	8b 40 04             	mov    0x4(%eax),%eax
c0106ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != le);
c0106ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106edb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106ede:	75 24                	jne    c0106f04 <_fifo_swap_out_victim+0x98>
c0106ee0:	c7 44 24 0c cd a8 10 	movl   $0xc010a8cd,0xc(%esp)
c0106ee7:	c0 
c0106ee8:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0106eef:	c0 
c0106ef0:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
c0106ef7:	00 
c0106ef8:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0106eff:	e8 e7 9d ff ff       	call   c0100ceb <__panic>
    // 查找最先进入并且未被修改的页面
    while(le != head) {
c0106f04:	e9 bd 00 00 00       	jmp    c0106fc6 <_fifo_swap_out_victim+0x15a>
        struct Page *p = le2page(le, pra_page_link);
c0106f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f0c:	83 e8 14             	sub    $0x14,%eax
c0106f0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 获取页表项
        pte_t *ptep = get_pte(mm->pgdir, p->pra_vaddr, 0);  
c0106f12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f15:	8b 50 1c             	mov    0x1c(%eax),%edx
c0106f18:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f1b:	8b 40 0c             	mov    0xc(%eax),%eax
c0106f1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106f25:	00 
c0106f26:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f2a:	89 04 24             	mov    %eax,(%esp)
c0106f2d:	e8 4d e0 ff ff       	call   c0104f7f <get_pte>
c0106f32:	89 45 e8             	mov    %eax,-0x18(%ebp)
        
        // 判断获得的页表项是否正确  
        if(!(*ptep & PTE_A) && !(*ptep & PTE_D)) {      // 未被访问，未被修改
c0106f35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f38:	8b 00                	mov    (%eax),%eax
c0106f3a:	83 e0 20             	and    $0x20,%eax
c0106f3d:	85 c0                	test   %eax,%eax
c0106f3f:	75 7c                	jne    c0106fbd <_fifo_swap_out_victim+0x151>
c0106f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f44:	8b 00                	mov    (%eax),%eax
c0106f46:	83 e0 40             	and    $0x40,%eax
c0106f49:	85 c0                	test   %eax,%eax
c0106f4b:	75 70                	jne    c0106fbd <_fifo_swap_out_victim+0x151>
c0106f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f50:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106f53:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106f56:	8b 40 04             	mov    0x4(%eax),%eax
c0106f59:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106f5c:	8b 12                	mov    (%edx),%edx
c0106f5e:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106f61:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106f64:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106f67:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106f6a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106f6d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106f70:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106f73:	89 10                	mov    %edx,(%eax)
        // 如果 dirty bit 为 0 ，换出
        // 将页面从队列中删除
        list_del(le);
        
        assert(p != NULL);
c0106f75:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106f79:	75 24                	jne    c0106f9f <_fifo_swap_out_victim+0x133>
c0106f7b:	c7 44 24 0c d8 a8 10 	movl   $0xc010a8d8,0xc(%esp)
c0106f82:	c0 
c0106f83:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0106f8a:	c0 
c0106f8b:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
c0106f92:	00 
c0106f93:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0106f9a:	e8 4c 9d ff ff       	call   c0100ceb <__panic>
        // 将这一页的地址存储在 prt_page 中
            *ptr_page = p;
c0106f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106fa2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106fa5:	89 10                	mov    %edx,(%eax)
	cprintf("(0,0)\n");
c0106fa7:	c7 04 24 e2 a8 10 c0 	movl   $0xc010a8e2,(%esp)
c0106fae:	e8 a4 93 ff ff       	call   c0100357 <cprintf>
            return 0;
c0106fb3:	b8 00 00 00 00       	mov    $0x0,%eax
c0106fb8:	e9 8e 02 00 00       	jmp    c010724b <_fifo_swap_out_victim+0x3df>
        }
        le = le->next;
c0106fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fc0:	8b 40 04             	mov    0x4(%eax),%eax
c0106fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(in_tick == 0);
    // 将 head 指针指向最先进入的页面
    list_entry_t *le = head->next;
    assert(head != le);
    // 查找最先进入并且未被修改的页面
    while(le != head) {
c0106fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fc9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106fcc:	0f 85 37 ff ff ff    	jne    c0106f09 <_fifo_swap_out_victim+0x9d>
	cprintf("(0,0)\n");
            return 0;
        }
        le = le->next;
    }
    le = le->next;
c0106fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fd5:	8b 40 04             	mov    0x4(%eax),%eax
c0106fd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(le != head) {
c0106fdb:	e9 cc 00 00 00       	jmp    c01070ac <_fifo_swap_out_victim+0x240>
        struct Page *p = le2page(le, pra_page_link);
c0106fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fe3:	83 e8 14             	sub    $0x14,%eax
c0106fe6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        pte_t *ptep = get_pte(mm->pgdir, p->pra_vaddr, 0);    
c0106fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fec:	8b 50 1c             	mov    0x1c(%eax),%edx
c0106fef:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ff2:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ff5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ffc:	00 
c0106ffd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107001:	89 04 24             	mov    %eax,(%esp)
c0107004:	e8 76 df ff ff       	call   c0104f7f <get_pte>
c0107009:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(!(*ptep & PTE_A) && (*ptep & PTE_D)) {       // 未被访问，已被修改
c010700c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010700f:	8b 00                	mov    (%eax),%eax
c0107011:	83 e0 20             	and    $0x20,%eax
c0107014:	85 c0                	test   %eax,%eax
c0107016:	75 7c                	jne    c0107094 <_fifo_swap_out_victim+0x228>
c0107018:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010701b:	8b 00                	mov    (%eax),%eax
c010701d:	83 e0 40             	and    $0x40,%eax
c0107020:	85 c0                	test   %eax,%eax
c0107022:	74 70                	je     c0107094 <_fifo_swap_out_victim+0x228>
c0107024:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107027:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010702a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010702d:	8b 40 04             	mov    0x4(%eax),%eax
c0107030:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107033:	8b 12                	mov    (%edx),%edx
c0107035:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0107038:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010703b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010703e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0107041:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107044:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107047:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010704a:	89 10                	mov    %edx,(%eax)
            list_del(le);
            assert(p != NULL);
c010704c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107050:	75 24                	jne    c0107076 <_fifo_swap_out_victim+0x20a>
c0107052:	c7 44 24 0c d8 a8 10 	movl   $0xc010a8d8,0xc(%esp)
c0107059:	c0 
c010705a:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107061:	c0 
c0107062:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0107069:	00 
c010706a:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107071:	e8 75 9c ff ff       	call   c0100ceb <__panic>
            *ptr_page = p;
c0107076:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107079:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010707c:	89 10                	mov    %edx,(%eax)
	    cprintf("(0,1)\n");
c010707e:	c7 04 24 e9 a8 10 c0 	movl   $0xc010a8e9,(%esp)
c0107085:	e8 cd 92 ff ff       	call   c0100357 <cprintf>
            return 0;
c010708a:	b8 00 00 00 00       	mov    $0x0,%eax
c010708f:	e9 b7 01 00 00       	jmp    c010724b <_fifo_swap_out_victim+0x3df>
        }
        *ptep ^= PTE_A;                                 // 页被访问过则将 PTE_A 位置 0
c0107094:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107097:	8b 00                	mov    (%eax),%eax
c0107099:	83 f0 20             	xor    $0x20,%eax
c010709c:	89 c2                	mov    %eax,%edx
c010709e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01070a1:	89 10                	mov    %edx,(%eax)
        le = le->next;
c01070a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070a6:	8b 40 04             	mov    0x4(%eax),%eax
c01070a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            return 0;
        }
        le = le->next;
    }
    le = le->next;
    while(le != head) {
c01070ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070af:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01070b2:	0f 85 28 ff ff ff    	jne    c0106fe0 <_fifo_swap_out_victim+0x174>
            return 0;
        }
        *ptep ^= PTE_A;                                 // 页被访问过则将 PTE_A 位置 0
        le = le->next;
    }
    le = le->next;
c01070b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070bb:	8b 40 04             	mov    0x4(%eax),%eax
c01070be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(le != head) {
c01070c1:	e9 b1 00 00 00       	jmp    c0107177 <_fifo_swap_out_victim+0x30b>
    struct Page *p = le2page(le, pra_page_link);
c01070c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070c9:	83 e8 14             	sub    $0x14,%eax
c01070cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    pte_t *ptep = get_pte(mm->pgdir, p->pra_vaddr, 0);    
c01070cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01070d2:	8b 50 1c             	mov    0x1c(%eax),%edx
c01070d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01070d8:	8b 40 0c             	mov    0xc(%eax),%eax
c01070db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01070e2:	00 
c01070e3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070e7:	89 04 24             	mov    %eax,(%esp)
c01070ea:	e8 90 de ff ff       	call   c0104f7f <get_pte>
c01070ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if(!(*ptep & PTE_D)) {               // 未被修改，此时所有页均被访问过，即 PTE_A 位为 0
c01070f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01070f5:	8b 00                	mov    (%eax),%eax
c01070f7:	83 e0 40             	and    $0x40,%eax
c01070fa:	85 c0                	test   %eax,%eax
c01070fc:	75 70                	jne    c010716e <_fifo_swap_out_victim+0x302>
c01070fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107101:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107104:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107107:	8b 40 04             	mov    0x4(%eax),%eax
c010710a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010710d:	8b 12                	mov    (%edx),%edx
c010710f:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0107112:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107115:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107118:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010711b:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010711e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0107121:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0107124:	89 10                	mov    %edx,(%eax)
        list_del(le);
        assert(p != NULL);
c0107126:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010712a:	75 24                	jne    c0107150 <_fifo_swap_out_victim+0x2e4>
c010712c:	c7 44 24 0c d8 a8 10 	movl   $0xc010a8d8,0xc(%esp)
c0107133:	c0 
c0107134:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c010713b:	c0 
c010713c:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
c0107143:	00 
c0107144:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c010714b:	e8 9b 9b ff ff       	call   c0100ceb <__panic>
        *ptr_page = p;
c0107150:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107153:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107156:	89 10                	mov    %edx,(%eax)
	cprintf("(1,0)\n");
c0107158:	c7 04 24 f0 a8 10 c0 	movl   $0xc010a8f0,(%esp)
c010715f:	e8 f3 91 ff ff       	call   c0100357 <cprintf>
        return 0;
c0107164:	b8 00 00 00 00       	mov    $0x0,%eax
c0107169:	e9 dd 00 00 00       	jmp    c010724b <_fifo_swap_out_victim+0x3df>
    }
    le = le->next;
c010716e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107171:	8b 40 04             	mov    0x4(%eax),%eax
c0107174:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        *ptep ^= PTE_A;                                 // 页被访问过则将 PTE_A 位置 0
        le = le->next;
    }
    le = le->next;
    while(le != head) {
c0107177:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010717a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010717d:	0f 85 43 ff ff ff    	jne    c01070c6 <_fifo_swap_out_victim+0x25a>
    }
    le = le->next;
    }
    // 如果这行到这里证明找完一圈，所有页面都不符合换出条件
    // 那么强行换出最先进入的页面
    le = le->next;
c0107183:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107186:	8b 40 04             	mov    0x4(%eax),%eax
c0107189:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(le != head) {
c010718c:	e9 ae 00 00 00       	jmp    c010723f <_fifo_swap_out_victim+0x3d3>
        struct Page *p = le2page(le, pra_page_link);
c0107191:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107194:	83 e8 14             	sub    $0x14,%eax
c0107197:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        pte_t *ptep = get_pte(mm->pgdir, p->pra_vaddr, 0);    
c010719a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010719d:	8b 50 1c             	mov    0x1c(%eax),%edx
c01071a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01071a3:	8b 40 0c             	mov    0xc(%eax),%eax
c01071a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01071ad:	00 
c01071ae:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071b2:	89 04 24             	mov    %eax,(%esp)
c01071b5:	e8 c5 dd ff ff       	call   c0104f7f <get_pte>
c01071ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(*ptep & PTE_D) {                                 // 已被修改
c01071bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01071c0:	8b 00                	mov    (%eax),%eax
c01071c2:	83 e0 40             	and    $0x40,%eax
c01071c5:	85 c0                	test   %eax,%eax
c01071c7:	74 6d                	je     c0107236 <_fifo_swap_out_victim+0x3ca>
c01071c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071cc:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01071cf:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01071d2:	8b 40 04             	mov    0x4(%eax),%eax
c01071d5:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01071d8:	8b 12                	mov    (%edx),%edx
c01071da:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01071dd:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01071e0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01071e3:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01071e6:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01071e9:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01071ec:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01071ef:	89 10                	mov    %edx,(%eax)
            list_del(le);
            assert(p != NULL);
c01071f1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01071f5:	75 24                	jne    c010721b <_fifo_swap_out_victim+0x3af>
c01071f7:	c7 44 24 0c d8 a8 10 	movl   $0xc010a8d8,0xc(%esp)
c01071fe:	c0 
c01071ff:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107206:	c0 
c0107207:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c010720e:	00 
c010720f:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107216:	e8 d0 9a ff ff       	call   c0100ceb <__panic>
            //将这一页的地址存储在 ptr_page 中
            *ptr_page = p;
c010721b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010721e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107221:	89 10                	mov    %edx,(%eax)
	    cprintf("(1,1)\n");
c0107223:	c7 04 24 f7 a8 10 c0 	movl   $0xc010a8f7,(%esp)
c010722a:	e8 28 91 ff ff       	call   c0100357 <cprintf>
            return 0;
c010722f:	b8 00 00 00 00       	mov    $0x0,%eax
c0107234:	eb 15                	jmp    c010724b <_fifo_swap_out_victim+0x3df>
        }
        le = le->next;
c0107236:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107239:	8b 40 04             	mov    0x4(%eax),%eax
c010723c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    le = le->next;
    }
    // 如果这行到这里证明找完一圈，所有页面都不符合换出条件
    // 那么强行换出最先进入的页面
    le = le->next;
    while(le != head) {
c010723f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107242:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107245:	0f 85 46 ff ff ff    	jne    c0107191 <_fifo_swap_out_victim+0x325>
	    cprintf("(1,1)\n");
            return 0;
        }
        le = le->next;
    }
}
c010724b:	c9                   	leave  
c010724c:	c3                   	ret    

c010724d <_fifo_check_swap>:
static int
_fifo_check_swap(void) {
c010724d:	55                   	push   %ebp
c010724e:	89 e5                	mov    %esp,%ebp
c0107250:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107253:	c7 04 24 00 a9 10 c0 	movl   $0xc010a900,(%esp)
c010725a:	e8 f8 90 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010725f:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107264:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107267:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010726c:	83 f8 04             	cmp    $0x4,%eax
c010726f:	74 24                	je     c0107295 <_fifo_check_swap+0x48>
c0107271:	c7 44 24 0c 26 a9 10 	movl   $0xc010a926,0xc(%esp)
c0107278:	c0 
c0107279:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107280:	c0 
c0107281:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0107288:	00 
c0107289:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107290:	e8 56 9a ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107295:	c7 04 24 38 a9 10 c0 	movl   $0xc010a938,(%esp)
c010729c:	e8 b6 90 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01072a1:	b8 00 10 00 00       	mov    $0x1000,%eax
c01072a6:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01072a9:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01072ae:	83 f8 04             	cmp    $0x4,%eax
c01072b1:	74 24                	je     c01072d7 <_fifo_check_swap+0x8a>
c01072b3:	c7 44 24 0c 26 a9 10 	movl   $0xc010a926,0xc(%esp)
c01072ba:	c0 
c01072bb:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c01072c2:	c0 
c01072c3:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01072ca:	00 
c01072cb:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c01072d2:	e8 14 9a ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01072d7:	c7 04 24 60 a9 10 c0 	movl   $0xc010a960,(%esp)
c01072de:	e8 74 90 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01072e3:	b8 00 40 00 00       	mov    $0x4000,%eax
c01072e8:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c01072eb:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01072f0:	83 f8 04             	cmp    $0x4,%eax
c01072f3:	74 24                	je     c0107319 <_fifo_check_swap+0xcc>
c01072f5:	c7 44 24 0c 26 a9 10 	movl   $0xc010a926,0xc(%esp)
c01072fc:	c0 
c01072fd:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107304:	c0 
c0107305:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010730c:	00 
c010730d:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107314:	e8 d2 99 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107319:	c7 04 24 88 a9 10 c0 	movl   $0xc010a988,(%esp)
c0107320:	e8 32 90 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107325:	b8 00 20 00 00       	mov    $0x2000,%eax
c010732a:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010732d:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107332:	83 f8 04             	cmp    $0x4,%eax
c0107335:	74 24                	je     c010735b <_fifo_check_swap+0x10e>
c0107337:	c7 44 24 0c 26 a9 10 	movl   $0xc010a926,0xc(%esp)
c010733e:	c0 
c010733f:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107346:	c0 
c0107347:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c010734e:	00 
c010734f:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107356:	e8 90 99 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010735b:	c7 04 24 b0 a9 10 c0 	movl   $0xc010a9b0,(%esp)
c0107362:	e8 f0 8f ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107367:	b8 00 50 00 00       	mov    $0x5000,%eax
c010736c:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c010736f:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107374:	83 f8 05             	cmp    $0x5,%eax
c0107377:	74 24                	je     c010739d <_fifo_check_swap+0x150>
c0107379:	c7 44 24 0c d6 a9 10 	movl   $0xc010a9d6,0xc(%esp)
c0107380:	c0 
c0107381:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107388:	c0 
c0107389:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0107390:	00 
c0107391:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107398:	e8 4e 99 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010739d:	c7 04 24 88 a9 10 c0 	movl   $0xc010a988,(%esp)
c01073a4:	e8 ae 8f ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01073a9:	b8 00 20 00 00       	mov    $0x2000,%eax
c01073ae:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01073b1:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01073b6:	83 f8 05             	cmp    $0x5,%eax
c01073b9:	74 24                	je     c01073df <_fifo_check_swap+0x192>
c01073bb:	c7 44 24 0c d6 a9 10 	movl   $0xc010a9d6,0xc(%esp)
c01073c2:	c0 
c01073c3:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c01073ca:	c0 
c01073cb:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c01073d2:	00 
c01073d3:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c01073da:	e8 0c 99 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01073df:	c7 04 24 38 a9 10 c0 	movl   $0xc010a938,(%esp)
c01073e6:	e8 6c 8f ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01073eb:	b8 00 10 00 00       	mov    $0x1000,%eax
c01073f0:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==5);
c01073f3:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01073f8:	83 f8 05             	cmp    $0x5,%eax
c01073fb:	74 24                	je     c0107421 <_fifo_check_swap+0x1d4>
c01073fd:	c7 44 24 0c d6 a9 10 	movl   $0xc010a9d6,0xc(%esp)
c0107404:	c0 
c0107405:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c010740c:	c0 
c010740d:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0107414:	00 
c0107415:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c010741c:	e8 ca 98 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107421:	c7 04 24 88 a9 10 c0 	movl   $0xc010a988,(%esp)
c0107428:	e8 2a 8f ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010742d:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107432:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107435:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010743a:	83 f8 05             	cmp    $0x5,%eax
c010743d:	74 24                	je     c0107463 <_fifo_check_swap+0x216>
c010743f:	c7 44 24 0c d6 a9 10 	movl   $0xc010a9d6,0xc(%esp)
c0107446:	c0 
c0107447:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c010744e:	c0 
c010744f:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0107456:	00 
c0107457:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c010745e:	e8 88 98 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107463:	c7 04 24 00 a9 10 c0 	movl   $0xc010a900,(%esp)
c010746a:	e8 e8 8e ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010746f:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107474:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==5);
c0107477:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010747c:	83 f8 05             	cmp    $0x5,%eax
c010747f:	74 24                	je     c01074a5 <_fifo_check_swap+0x258>
c0107481:	c7 44 24 0c d6 a9 10 	movl   $0xc010a9d6,0xc(%esp)
c0107488:	c0 
c0107489:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107490:	c0 
c0107491:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0107498:	00 
c0107499:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c01074a0:	e8 46 98 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01074a5:	c7 04 24 60 a9 10 c0 	movl   $0xc010a960,(%esp)
c01074ac:	e8 a6 8e ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01074b1:	b8 00 40 00 00       	mov    $0x4000,%eax
c01074b6:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==6);
c01074b9:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01074be:	83 f8 06             	cmp    $0x6,%eax
c01074c1:	74 24                	je     c01074e7 <_fifo_check_swap+0x29a>
c01074c3:	c7 44 24 0c e5 a9 10 	movl   $0xc010a9e5,0xc(%esp)
c01074ca:	c0 
c01074cb:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c01074d2:	c0 
c01074d3:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c01074da:	00 
c01074db:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c01074e2:	e8 04 98 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01074e7:	c7 04 24 b0 a9 10 c0 	movl   $0xc010a9b0,(%esp)
c01074ee:	e8 64 8e ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01074f3:	b8 00 50 00 00       	mov    $0x5000,%eax
c01074f8:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==6);
c01074fb:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107500:	83 f8 06             	cmp    $0x6,%eax
c0107503:	74 24                	je     c0107529 <_fifo_check_swap+0x2dc>
c0107505:	c7 44 24 0c e5 a9 10 	movl   $0xc010a9e5,0xc(%esp)
c010750c:	c0 
c010750d:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107514:	c0 
c0107515:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c010751c:	00 
c010751d:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107524:	e8 c2 97 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107529:	c7 04 24 00 a9 10 c0 	movl   $0xc010a900,(%esp)
c0107530:	e8 22 8e ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107535:	b8 00 30 00 00       	mov    $0x3000,%eax
c010753a:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==7);
c010753d:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107542:	83 f8 07             	cmp    $0x7,%eax
c0107545:	74 24                	je     c010756b <_fifo_check_swap+0x31e>
c0107547:	c7 44 24 0c f4 a9 10 	movl   $0xc010a9f4,0xc(%esp)
c010754e:	c0 
c010754f:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107556:	c0 
c0107557:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010755e:	00 
c010755f:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c0107566:	e8 80 97 ff ff       	call   c0100ceb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010756b:	c7 04 24 38 a9 10 c0 	movl   $0xc010a938,(%esp)
c0107572:	e8 e0 8d ff ff       	call   c0100357 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107577:	b8 00 10 00 00       	mov    $0x1000,%eax
c010757c:	0f b6 00             	movzbl (%eax),%eax
c010757f:	3c 0a                	cmp    $0xa,%al
c0107581:	74 24                	je     c01075a7 <_fifo_check_swap+0x35a>
c0107583:	c7 44 24 0c 04 aa 10 	movl   $0xc010aa04,0xc(%esp)
c010758a:	c0 
c010758b:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c0107592:	c0 
c0107593:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010759a:	00 
c010759b:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c01075a2:	e8 44 97 ff ff       	call   c0100ceb <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01075a7:	b8 00 10 00 00       	mov    $0x1000,%eax
c01075ac:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==7);
c01075af:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01075b4:	83 f8 07             	cmp    $0x7,%eax
c01075b7:	74 24                	je     c01075dd <_fifo_check_swap+0x390>
c01075b9:	c7 44 24 0c f4 a9 10 	movl   $0xc010a9f4,0xc(%esp)
c01075c0:	c0 
c01075c1:	c7 44 24 08 8a a8 10 	movl   $0xc010a88a,0x8(%esp)
c01075c8:	c0 
c01075c9:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01075d0:	00 
c01075d1:	c7 04 24 9f a8 10 c0 	movl   $0xc010a89f,(%esp)
c01075d8:	e8 0e 97 ff ff       	call   c0100ceb <__panic>
    return 0;
c01075dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075e2:	c9                   	leave  
c01075e3:	c3                   	ret    

c01075e4 <_fifo_init>:

static int
_fifo_init(void)
{
c01075e4:	55                   	push   %ebp
c01075e5:	89 e5                	mov    %esp,%ebp
    return 0;
c01075e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075ec:	5d                   	pop    %ebp
c01075ed:	c3                   	ret    

c01075ee <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01075ee:	55                   	push   %ebp
c01075ef:	89 e5                	mov    %esp,%ebp
    return 0;
c01075f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075f6:	5d                   	pop    %ebp
c01075f7:	c3                   	ret    

c01075f8 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01075f8:	55                   	push   %ebp
c01075f9:	89 e5                	mov    %esp,%ebp
c01075fb:	b8 00 00 00 00       	mov    $0x0,%eax
c0107600:	5d                   	pop    %ebp
c0107601:	c3                   	ret    

c0107602 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107602:	55                   	push   %ebp
c0107603:	89 e5                	mov    %esp,%ebp
c0107605:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107608:	8b 45 08             	mov    0x8(%ebp),%eax
c010760b:	c1 e8 0c             	shr    $0xc,%eax
c010760e:	89 c2                	mov    %eax,%edx
c0107610:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0107615:	39 c2                	cmp    %eax,%edx
c0107617:	72 1c                	jb     c0107635 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107619:	c7 44 24 08 38 aa 10 	movl   $0xc010aa38,0x8(%esp)
c0107620:	c0 
c0107621:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0107628:	00 
c0107629:	c7 04 24 57 aa 10 c0 	movl   $0xc010aa57,(%esp)
c0107630:	e8 b6 96 ff ff       	call   c0100ceb <__panic>
    }
    return &pages[PPN(pa)];
c0107635:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c010763a:	8b 55 08             	mov    0x8(%ebp),%edx
c010763d:	c1 ea 0c             	shr    $0xc,%edx
c0107640:	c1 e2 05             	shl    $0x5,%edx
c0107643:	01 d0                	add    %edx,%eax
}
c0107645:	c9                   	leave  
c0107646:	c3                   	ret    

c0107647 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0107647:	55                   	push   %ebp
c0107648:	89 e5                	mov    %esp,%ebp
c010764a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010764d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107650:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107655:	89 04 24             	mov    %eax,(%esp)
c0107658:	e8 a5 ff ff ff       	call   c0107602 <pa2page>
}
c010765d:	c9                   	leave  
c010765e:	c3                   	ret    

c010765f <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010765f:	55                   	push   %ebp
c0107660:	89 e5                	mov    %esp,%ebp
c0107662:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107665:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010766c:	e8 d9 e9 ff ff       	call   c010604a <kmalloc>
c0107671:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107674:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107678:	74 58                	je     c01076d2 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c010767a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010767d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107680:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107683:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107686:	89 50 04             	mov    %edx,0x4(%eax)
c0107689:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010768c:	8b 50 04             	mov    0x4(%eax),%edx
c010768f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107692:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0107694:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107697:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c010769e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076a1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01076a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076ab:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01076b2:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c01076b7:	85 c0                	test   %eax,%eax
c01076b9:	74 0d                	je     c01076c8 <mm_create+0x69>
c01076bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076be:	89 04 24             	mov    %eax,(%esp)
c01076c1:	e8 d1 eb ff ff       	call   c0106297 <swap_init_mm>
c01076c6:	eb 0a                	jmp    c01076d2 <mm_create+0x73>
        else mm->sm_priv = NULL;
c01076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076cb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01076d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01076d5:	c9                   	leave  
c01076d6:	c3                   	ret    

c01076d7 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01076d7:	55                   	push   %ebp
c01076d8:	89 e5                	mov    %esp,%ebp
c01076da:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01076dd:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01076e4:	e8 61 e9 ff ff       	call   c010604a <kmalloc>
c01076e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01076ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01076f0:	74 1b                	je     c010770d <vma_create+0x36>
        vma->vm_start = vm_start;
c01076f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076f5:	8b 55 08             	mov    0x8(%ebp),%edx
c01076f8:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01076fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107701:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107707:	8b 55 10             	mov    0x10(%ebp),%edx
c010770a:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010770d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107710:	c9                   	leave  
c0107711:	c3                   	ret    

c0107712 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107712:	55                   	push   %ebp
c0107713:	89 e5                	mov    %esp,%ebp
c0107715:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107718:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010771f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107723:	0f 84 95 00 00 00    	je     c01077be <find_vma+0xac>
        vma = mm->mmap_cache;
c0107729:	8b 45 08             	mov    0x8(%ebp),%eax
c010772c:	8b 40 08             	mov    0x8(%eax),%eax
c010772f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107732:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107736:	74 16                	je     c010774e <find_vma+0x3c>
c0107738:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010773b:	8b 40 04             	mov    0x4(%eax),%eax
c010773e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107741:	77 0b                	ja     c010774e <find_vma+0x3c>
c0107743:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107746:	8b 40 08             	mov    0x8(%eax),%eax
c0107749:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010774c:	77 61                	ja     c01077af <find_vma+0x9d>
                bool found = 0;
c010774e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0107755:	8b 45 08             	mov    0x8(%ebp),%eax
c0107758:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010775b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010775e:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0107761:	eb 28                	jmp    c010778b <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0107763:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107766:	83 e8 10             	sub    $0x10,%eax
c0107769:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010776c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010776f:	8b 40 04             	mov    0x4(%eax),%eax
c0107772:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107775:	77 14                	ja     c010778b <find_vma+0x79>
c0107777:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010777a:	8b 40 08             	mov    0x8(%eax),%eax
c010777d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107780:	76 09                	jbe    c010778b <find_vma+0x79>
                        found = 1;
c0107782:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107789:	eb 17                	jmp    c01077a2 <find_vma+0x90>
c010778b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010778e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107791:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107794:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0107797:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010779a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010779d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01077a0:	75 c1                	jne    c0107763 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01077a2:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01077a6:	75 07                	jne    c01077af <find_vma+0x9d>
                    vma = NULL;
c01077a8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01077af:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01077b3:	74 09                	je     c01077be <find_vma+0xac>
            mm->mmap_cache = vma;
c01077b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01077b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01077bb:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01077be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01077c1:	c9                   	leave  
c01077c2:	c3                   	ret    

c01077c3 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01077c3:	55                   	push   %ebp
c01077c4:	89 e5                	mov    %esp,%ebp
c01077c6:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01077c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01077cc:	8b 50 04             	mov    0x4(%eax),%edx
c01077cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01077d2:	8b 40 08             	mov    0x8(%eax),%eax
c01077d5:	39 c2                	cmp    %eax,%edx
c01077d7:	72 24                	jb     c01077fd <check_vma_overlap+0x3a>
c01077d9:	c7 44 24 0c 65 aa 10 	movl   $0xc010aa65,0xc(%esp)
c01077e0:	c0 
c01077e1:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c01077e8:	c0 
c01077e9:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01077f0:	00 
c01077f1:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c01077f8:	e8 ee 94 ff ff       	call   c0100ceb <__panic>
    assert(prev->vm_end <= next->vm_start);
c01077fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0107800:	8b 50 08             	mov    0x8(%eax),%edx
c0107803:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107806:	8b 40 04             	mov    0x4(%eax),%eax
c0107809:	39 c2                	cmp    %eax,%edx
c010780b:	76 24                	jbe    c0107831 <check_vma_overlap+0x6e>
c010780d:	c7 44 24 0c a8 aa 10 	movl   $0xc010aaa8,0xc(%esp)
c0107814:	c0 
c0107815:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c010781c:	c0 
c010781d:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0107824:	00 
c0107825:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c010782c:	e8 ba 94 ff ff       	call   c0100ceb <__panic>
    assert(next->vm_start < next->vm_end);
c0107831:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107834:	8b 50 04             	mov    0x4(%eax),%edx
c0107837:	8b 45 0c             	mov    0xc(%ebp),%eax
c010783a:	8b 40 08             	mov    0x8(%eax),%eax
c010783d:	39 c2                	cmp    %eax,%edx
c010783f:	72 24                	jb     c0107865 <check_vma_overlap+0xa2>
c0107841:	c7 44 24 0c c7 aa 10 	movl   $0xc010aac7,0xc(%esp)
c0107848:	c0 
c0107849:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107850:	c0 
c0107851:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107858:	00 
c0107859:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107860:	e8 86 94 ff ff       	call   c0100ceb <__panic>
}
c0107865:	c9                   	leave  
c0107866:	c3                   	ret    

c0107867 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107867:	55                   	push   %ebp
c0107868:	89 e5                	mov    %esp,%ebp
c010786a:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c010786d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107870:	8b 50 04             	mov    0x4(%eax),%edx
c0107873:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107876:	8b 40 08             	mov    0x8(%eax),%eax
c0107879:	39 c2                	cmp    %eax,%edx
c010787b:	72 24                	jb     c01078a1 <insert_vma_struct+0x3a>
c010787d:	c7 44 24 0c e5 aa 10 	movl   $0xc010aae5,0xc(%esp)
c0107884:	c0 
c0107885:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c010788c:	c0 
c010788d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0107894:	00 
c0107895:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c010789c:	e8 4a 94 ff ff       	call   c0100ceb <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01078a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01078a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01078a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01078ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01078b3:	eb 21                	jmp    c01078d6 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01078b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078b8:	83 e8 10             	sub    $0x10,%eax
c01078bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01078be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078c1:	8b 50 04             	mov    0x4(%eax),%edx
c01078c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01078c7:	8b 40 04             	mov    0x4(%eax),%eax
c01078ca:	39 c2                	cmp    %eax,%edx
c01078cc:	76 02                	jbe    c01078d0 <insert_vma_struct+0x69>
                break;
c01078ce:	eb 1d                	jmp    c01078ed <insert_vma_struct+0x86>
            }
            le_prev = le;
c01078d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01078d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01078dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078df:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01078e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01078e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078e8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01078eb:	75 c8                	jne    c01078b5 <insert_vma_struct+0x4e>
c01078ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01078f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01078f6:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01078f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01078fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078ff:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107902:	74 15                	je     c0107919 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107904:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107907:	8d 50 f0             	lea    -0x10(%eax),%edx
c010790a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010790d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107911:	89 14 24             	mov    %edx,(%esp)
c0107914:	e8 aa fe ff ff       	call   c01077c3 <check_vma_overlap>
    }
    if (le_next != list) {
c0107919:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010791c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010791f:	74 15                	je     c0107936 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0107921:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107924:	83 e8 10             	sub    $0x10,%eax
c0107927:	89 44 24 04          	mov    %eax,0x4(%esp)
c010792b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010792e:	89 04 24             	mov    %eax,(%esp)
c0107931:	e8 8d fe ff ff       	call   c01077c3 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0107936:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107939:	8b 55 08             	mov    0x8(%ebp),%edx
c010793c:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010793e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107941:	8d 50 10             	lea    0x10(%eax),%edx
c0107944:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107947:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010794a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010794d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107950:	8b 40 04             	mov    0x4(%eax),%eax
c0107953:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107956:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107959:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010795c:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010795f:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0107962:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107965:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107968:	89 10                	mov    %edx,(%eax)
c010796a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010796d:	8b 10                	mov    (%eax),%edx
c010796f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107972:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107975:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107978:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010797b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010797e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107981:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107984:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0107986:	8b 45 08             	mov    0x8(%ebp),%eax
c0107989:	8b 40 10             	mov    0x10(%eax),%eax
c010798c:	8d 50 01             	lea    0x1(%eax),%edx
c010798f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107992:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107995:	c9                   	leave  
c0107996:	c3                   	ret    

c0107997 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107997:	55                   	push   %ebp
c0107998:	89 e5                	mov    %esp,%ebp
c010799a:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010799d:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01079a3:	eb 3e                	jmp    c01079e3 <mm_destroy+0x4c>
c01079a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01079ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079ae:	8b 40 04             	mov    0x4(%eax),%eax
c01079b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01079b4:	8b 12                	mov    (%edx),%edx
c01079b6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01079b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01079bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01079c2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01079c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079c8:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01079cb:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c01079cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079d0:	83 e8 10             	sub    $0x10,%eax
c01079d3:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01079da:	00 
c01079db:	89 04 24             	mov    %eax,(%esp)
c01079de:	e8 07 e7 ff ff       	call   c01060ea <kfree>
c01079e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01079e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01079ec:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01079ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01079f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01079f8:	75 ab                	jne    c01079a5 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c01079fa:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0107a01:	00 
c0107a02:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a05:	89 04 24             	mov    %eax,(%esp)
c0107a08:	e8 dd e6 ff ff       	call   c01060ea <kfree>
    mm=NULL;
c0107a0d:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107a14:	c9                   	leave  
c0107a15:	c3                   	ret    

c0107a16 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107a16:	55                   	push   %ebp
c0107a17:	89 e5                	mov    %esp,%ebp
c0107a19:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0107a1c:	e8 02 00 00 00       	call   c0107a23 <check_vmm>
}
c0107a21:	c9                   	leave  
c0107a22:	c3                   	ret    

c0107a23 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107a23:	55                   	push   %ebp
c0107a24:	89 e5                	mov    %esp,%ebp
c0107a26:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107a29:	e8 0f cf ff ff       	call   c010493d <nr_free_pages>
c0107a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0107a31:	e8 41 00 00 00       	call   c0107a77 <check_vma_struct>
    check_pgfault();
c0107a36:	e8 03 05 00 00       	call   c0107f3e <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0107a3b:	e8 fd ce ff ff       	call   c010493d <nr_free_pages>
c0107a40:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107a43:	74 24                	je     c0107a69 <check_vmm+0x46>
c0107a45:	c7 44 24 0c 04 ab 10 	movl   $0xc010ab04,0xc(%esp)
c0107a4c:	c0 
c0107a4d:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107a54:	c0 
c0107a55:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0107a5c:	00 
c0107a5d:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107a64:	e8 82 92 ff ff       	call   c0100ceb <__panic>

    cprintf("check_vmm() succeeded.\n");
c0107a69:	c7 04 24 2b ab 10 c0 	movl   $0xc010ab2b,(%esp)
c0107a70:	e8 e2 88 ff ff       	call   c0100357 <cprintf>
}
c0107a75:	c9                   	leave  
c0107a76:	c3                   	ret    

c0107a77 <check_vma_struct>:

static void
check_vma_struct(void) {
c0107a77:	55                   	push   %ebp
c0107a78:	89 e5                	mov    %esp,%ebp
c0107a7a:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107a7d:	e8 bb ce ff ff       	call   c010493d <nr_free_pages>
c0107a82:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107a85:	e8 d5 fb ff ff       	call   c010765f <mm_create>
c0107a8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107a8d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107a91:	75 24                	jne    c0107ab7 <check_vma_struct+0x40>
c0107a93:	c7 44 24 0c 43 ab 10 	movl   $0xc010ab43,0xc(%esp)
c0107a9a:	c0 
c0107a9b:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107aa2:	c0 
c0107aa3:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c0107aaa:	00 
c0107aab:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107ab2:	e8 34 92 ff ff       	call   c0100ceb <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107ab7:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107abe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107ac1:	89 d0                	mov    %edx,%eax
c0107ac3:	c1 e0 02             	shl    $0x2,%eax
c0107ac6:	01 d0                	add    %edx,%eax
c0107ac8:	01 c0                	add    %eax,%eax
c0107aca:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107acd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ad3:	eb 70                	jmp    c0107b45 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107ad5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ad8:	89 d0                	mov    %edx,%eax
c0107ada:	c1 e0 02             	shl    $0x2,%eax
c0107add:	01 d0                	add    %edx,%eax
c0107adf:	83 c0 02             	add    $0x2,%eax
c0107ae2:	89 c1                	mov    %eax,%ecx
c0107ae4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ae7:	89 d0                	mov    %edx,%eax
c0107ae9:	c1 e0 02             	shl    $0x2,%eax
c0107aec:	01 d0                	add    %edx,%eax
c0107aee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107af5:	00 
c0107af6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107afa:	89 04 24             	mov    %eax,(%esp)
c0107afd:	e8 d5 fb ff ff       	call   c01076d7 <vma_create>
c0107b02:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0107b05:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107b09:	75 24                	jne    c0107b2f <check_vma_struct+0xb8>
c0107b0b:	c7 44 24 0c 4e ab 10 	movl   $0xc010ab4e,0xc(%esp)
c0107b12:	c0 
c0107b13:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107b1a:	c0 
c0107b1b:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0107b22:	00 
c0107b23:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107b2a:	e8 bc 91 ff ff       	call   c0100ceb <__panic>
        insert_vma_struct(mm, vma);
c0107b2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b39:	89 04 24             	mov    %eax,(%esp)
c0107b3c:	e8 26 fd ff ff       	call   c0107867 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c0107b41:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b49:	7f 8a                	jg     c0107ad5 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107b4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b4e:	83 c0 01             	add    $0x1,%eax
c0107b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b54:	eb 70                	jmp    c0107bc6 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107b56:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b59:	89 d0                	mov    %edx,%eax
c0107b5b:	c1 e0 02             	shl    $0x2,%eax
c0107b5e:	01 d0                	add    %edx,%eax
c0107b60:	83 c0 02             	add    $0x2,%eax
c0107b63:	89 c1                	mov    %eax,%ecx
c0107b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b68:	89 d0                	mov    %edx,%eax
c0107b6a:	c1 e0 02             	shl    $0x2,%eax
c0107b6d:	01 d0                	add    %edx,%eax
c0107b6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107b76:	00 
c0107b77:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107b7b:	89 04 24             	mov    %eax,(%esp)
c0107b7e:	e8 54 fb ff ff       	call   c01076d7 <vma_create>
c0107b83:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0107b86:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107b8a:	75 24                	jne    c0107bb0 <check_vma_struct+0x139>
c0107b8c:	c7 44 24 0c 4e ab 10 	movl   $0xc010ab4e,0xc(%esp)
c0107b93:	c0 
c0107b94:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107b9b:	c0 
c0107b9c:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0107ba3:	00 
c0107ba4:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107bab:	e8 3b 91 ff ff       	call   c0100ceb <__panic>
        insert_vma_struct(mm, vma);
c0107bb0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107bb3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bba:	89 04 24             	mov    %eax,(%esp)
c0107bbd:	e8 a5 fc ff ff       	call   c0107867 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107bc2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bc9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107bcc:	7e 88                	jle    c0107b56 <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107bce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bd1:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107bd4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107bd7:	8b 40 04             	mov    0x4(%eax),%eax
c0107bda:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107bdd:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107be4:	e9 97 00 00 00       	jmp    c0107c80 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c0107be9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107bef:	75 24                	jne    c0107c15 <check_vma_struct+0x19e>
c0107bf1:	c7 44 24 0c 5a ab 10 	movl   $0xc010ab5a,0xc(%esp)
c0107bf8:	c0 
c0107bf9:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107c00:	c0 
c0107c01:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0107c08:	00 
c0107c09:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107c10:	e8 d6 90 ff ff       	call   c0100ceb <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c18:	83 e8 10             	sub    $0x10,%eax
c0107c1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107c1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c21:	8b 48 04             	mov    0x4(%eax),%ecx
c0107c24:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c27:	89 d0                	mov    %edx,%eax
c0107c29:	c1 e0 02             	shl    $0x2,%eax
c0107c2c:	01 d0                	add    %edx,%eax
c0107c2e:	39 c1                	cmp    %eax,%ecx
c0107c30:	75 17                	jne    c0107c49 <check_vma_struct+0x1d2>
c0107c32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c35:	8b 48 08             	mov    0x8(%eax),%ecx
c0107c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c3b:	89 d0                	mov    %edx,%eax
c0107c3d:	c1 e0 02             	shl    $0x2,%eax
c0107c40:	01 d0                	add    %edx,%eax
c0107c42:	83 c0 02             	add    $0x2,%eax
c0107c45:	39 c1                	cmp    %eax,%ecx
c0107c47:	74 24                	je     c0107c6d <check_vma_struct+0x1f6>
c0107c49:	c7 44 24 0c 74 ab 10 	movl   $0xc010ab74,0xc(%esp)
c0107c50:	c0 
c0107c51:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107c58:	c0 
c0107c59:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0107c60:	00 
c0107c61:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107c68:	e8 7e 90 ff ff       	call   c0100ceb <__panic>
c0107c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c70:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107c73:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107c76:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107c79:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0107c7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c83:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107c86:	0f 8e 5d ff ff ff    	jle    c0107be9 <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107c8c:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107c93:	e9 cd 01 00 00       	jmp    c0107e65 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ca2:	89 04 24             	mov    %eax,(%esp)
c0107ca5:	e8 68 fa ff ff       	call   c0107712 <find_vma>
c0107caa:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0107cad:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107cb1:	75 24                	jne    c0107cd7 <check_vma_struct+0x260>
c0107cb3:	c7 44 24 0c a9 ab 10 	movl   $0xc010aba9,0xc(%esp)
c0107cba:	c0 
c0107cbb:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107cc2:	c0 
c0107cc3:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0107cca:	00 
c0107ccb:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107cd2:	e8 14 90 ff ff       	call   c0100ceb <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0107cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cda:	83 c0 01             	add    $0x1,%eax
c0107cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ce4:	89 04 24             	mov    %eax,(%esp)
c0107ce7:	e8 26 fa ff ff       	call   c0107712 <find_vma>
c0107cec:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0107cef:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107cf3:	75 24                	jne    c0107d19 <check_vma_struct+0x2a2>
c0107cf5:	c7 44 24 0c b6 ab 10 	movl   $0xc010abb6,0xc(%esp)
c0107cfc:	c0 
c0107cfd:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107d04:	c0 
c0107d05:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0107d0c:	00 
c0107d0d:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107d14:	e8 d2 8f ff ff       	call   c0100ceb <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0107d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d1c:	83 c0 02             	add    $0x2,%eax
c0107d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d23:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d26:	89 04 24             	mov    %eax,(%esp)
c0107d29:	e8 e4 f9 ff ff       	call   c0107712 <find_vma>
c0107d2e:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0107d31:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107d35:	74 24                	je     c0107d5b <check_vma_struct+0x2e4>
c0107d37:	c7 44 24 0c c3 ab 10 	movl   $0xc010abc3,0xc(%esp)
c0107d3e:	c0 
c0107d3f:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107d46:	c0 
c0107d47:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0107d4e:	00 
c0107d4f:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107d56:	e8 90 8f ff ff       	call   c0100ceb <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d5e:	83 c0 03             	add    $0x3,%eax
c0107d61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d68:	89 04 24             	mov    %eax,(%esp)
c0107d6b:	e8 a2 f9 ff ff       	call   c0107712 <find_vma>
c0107d70:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0107d73:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0107d77:	74 24                	je     c0107d9d <check_vma_struct+0x326>
c0107d79:	c7 44 24 0c d0 ab 10 	movl   $0xc010abd0,0xc(%esp)
c0107d80:	c0 
c0107d81:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107d88:	c0 
c0107d89:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0107d90:	00 
c0107d91:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107d98:	e8 4e 8f ff ff       	call   c0100ceb <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107da0:	83 c0 04             	add    $0x4,%eax
c0107da3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107daa:	89 04 24             	mov    %eax,(%esp)
c0107dad:	e8 60 f9 ff ff       	call   c0107712 <find_vma>
c0107db2:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0107db5:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0107db9:	74 24                	je     c0107ddf <check_vma_struct+0x368>
c0107dbb:	c7 44 24 0c dd ab 10 	movl   $0xc010abdd,0xc(%esp)
c0107dc2:	c0 
c0107dc3:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107dca:	c0 
c0107dcb:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0107dd2:	00 
c0107dd3:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107dda:	e8 0c 8f ff ff       	call   c0100ceb <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0107ddf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107de2:	8b 50 04             	mov    0x4(%eax),%edx
c0107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107de8:	39 c2                	cmp    %eax,%edx
c0107dea:	75 10                	jne    c0107dfc <check_vma_struct+0x385>
c0107dec:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107def:	8b 50 08             	mov    0x8(%eax),%edx
c0107df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107df5:	83 c0 02             	add    $0x2,%eax
c0107df8:	39 c2                	cmp    %eax,%edx
c0107dfa:	74 24                	je     c0107e20 <check_vma_struct+0x3a9>
c0107dfc:	c7 44 24 0c ec ab 10 	movl   $0xc010abec,0xc(%esp)
c0107e03:	c0 
c0107e04:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107e0b:	c0 
c0107e0c:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0107e13:	00 
c0107e14:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107e1b:	e8 cb 8e ff ff       	call   c0100ceb <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0107e20:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107e23:	8b 50 04             	mov    0x4(%eax),%edx
c0107e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e29:	39 c2                	cmp    %eax,%edx
c0107e2b:	75 10                	jne    c0107e3d <check_vma_struct+0x3c6>
c0107e2d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107e30:	8b 50 08             	mov    0x8(%eax),%edx
c0107e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e36:	83 c0 02             	add    $0x2,%eax
c0107e39:	39 c2                	cmp    %eax,%edx
c0107e3b:	74 24                	je     c0107e61 <check_vma_struct+0x3ea>
c0107e3d:	c7 44 24 0c 1c ac 10 	movl   $0xc010ac1c,0xc(%esp)
c0107e44:	c0 
c0107e45:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107e4c:	c0 
c0107e4d:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0107e54:	00 
c0107e55:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107e5c:	e8 8a 8e ff ff       	call   c0100ceb <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107e61:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0107e65:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107e68:	89 d0                	mov    %edx,%eax
c0107e6a:	c1 e0 02             	shl    $0x2,%eax
c0107e6d:	01 d0                	add    %edx,%eax
c0107e6f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107e72:	0f 8d 20 fe ff ff    	jge    c0107c98 <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0107e78:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0107e7f:	eb 70                	jmp    c0107ef1 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0107e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e88:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e8b:	89 04 24             	mov    %eax,(%esp)
c0107e8e:	e8 7f f8 ff ff       	call   c0107712 <find_vma>
c0107e93:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0107e96:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107e9a:	74 27                	je     c0107ec3 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0107e9c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107e9f:	8b 50 08             	mov    0x8(%eax),%edx
c0107ea2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107ea5:	8b 40 04             	mov    0x4(%eax),%eax
c0107ea8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107eac:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107eb7:	c7 04 24 4c ac 10 c0 	movl   $0xc010ac4c,(%esp)
c0107ebe:	e8 94 84 ff ff       	call   c0100357 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0107ec3:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107ec7:	74 24                	je     c0107eed <check_vma_struct+0x476>
c0107ec9:	c7 44 24 0c 71 ac 10 	movl   $0xc010ac71,0xc(%esp)
c0107ed0:	c0 
c0107ed1:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107ed8:	c0 
c0107ed9:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0107ee0:	00 
c0107ee1:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107ee8:	e8 fe 8d ff ff       	call   c0100ceb <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0107eed:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107ef1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ef5:	79 8a                	jns    c0107e81 <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0107ef7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107efa:	89 04 24             	mov    %eax,(%esp)
c0107efd:	e8 95 fa ff ff       	call   c0107997 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0107f02:	e8 36 ca ff ff       	call   c010493d <nr_free_pages>
c0107f07:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107f0a:	74 24                	je     c0107f30 <check_vma_struct+0x4b9>
c0107f0c:	c7 44 24 0c 04 ab 10 	movl   $0xc010ab04,0xc(%esp)
c0107f13:	c0 
c0107f14:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107f1b:	c0 
c0107f1c:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107f23:	00 
c0107f24:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107f2b:	e8 bb 8d ff ff       	call   c0100ceb <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0107f30:	c7 04 24 88 ac 10 c0 	movl   $0xc010ac88,(%esp)
c0107f37:	e8 1b 84 ff ff       	call   c0100357 <cprintf>
}
c0107f3c:	c9                   	leave  
c0107f3d:	c3                   	ret    

c0107f3e <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0107f3e:	55                   	push   %ebp
c0107f3f:	89 e5                	mov    %esp,%ebp
c0107f41:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107f44:	e8 f4 c9 ff ff       	call   c010493d <nr_free_pages>
c0107f49:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0107f4c:	e8 0e f7 ff ff       	call   c010765f <mm_create>
c0107f51:	a3 8c 41 12 c0       	mov    %eax,0xc012418c
    assert(check_mm_struct != NULL);
c0107f56:	a1 8c 41 12 c0       	mov    0xc012418c,%eax
c0107f5b:	85 c0                	test   %eax,%eax
c0107f5d:	75 24                	jne    c0107f83 <check_pgfault+0x45>
c0107f5f:	c7 44 24 0c a7 ac 10 	movl   $0xc010aca7,0xc(%esp)
c0107f66:	c0 
c0107f67:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107f6e:	c0 
c0107f6f:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0107f76:	00 
c0107f77:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107f7e:	e8 68 8d ff ff       	call   c0100ceb <__panic>

    struct mm_struct *mm = check_mm_struct;
c0107f83:	a1 8c 41 12 c0       	mov    0xc012418c,%eax
c0107f88:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107f8b:	8b 15 e0 09 12 c0    	mov    0xc01209e0,%edx
c0107f91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f94:	89 50 0c             	mov    %edx,0xc(%eax)
c0107f97:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f9a:	8b 40 0c             	mov    0xc(%eax),%eax
c0107f9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0107fa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107fa3:	8b 00                	mov    (%eax),%eax
c0107fa5:	85 c0                	test   %eax,%eax
c0107fa7:	74 24                	je     c0107fcd <check_pgfault+0x8f>
c0107fa9:	c7 44 24 0c bf ac 10 	movl   $0xc010acbf,0xc(%esp)
c0107fb0:	c0 
c0107fb1:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0107fb8:	c0 
c0107fb9:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0107fc0:	00 
c0107fc1:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0107fc8:	e8 1e 8d ff ff       	call   c0100ceb <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0107fcd:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0107fd4:	00 
c0107fd5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0107fdc:	00 
c0107fdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107fe4:	e8 ee f6 ff ff       	call   c01076d7 <vma_create>
c0107fe9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0107fec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107ff0:	75 24                	jne    c0108016 <check_pgfault+0xd8>
c0107ff2:	c7 44 24 0c 4e ab 10 	movl   $0xc010ab4e,0xc(%esp)
c0107ff9:	c0 
c0107ffa:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0108001:	c0 
c0108002:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0108009:	00 
c010800a:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0108011:	e8 d5 8c ff ff       	call   c0100ceb <__panic>

    insert_vma_struct(mm, vma);
c0108016:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108019:	89 44 24 04          	mov    %eax,0x4(%esp)
c010801d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108020:	89 04 24             	mov    %eax,(%esp)
c0108023:	e8 3f f8 ff ff       	call   c0107867 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108028:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c010802f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108032:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108036:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108039:	89 04 24             	mov    %eax,(%esp)
c010803c:	e8 d1 f6 ff ff       	call   c0107712 <find_vma>
c0108041:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108044:	74 24                	je     c010806a <check_pgfault+0x12c>
c0108046:	c7 44 24 0c cd ac 10 	movl   $0xc010accd,0xc(%esp)
c010804d:	c0 
c010804e:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0108055:	c0 
c0108056:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010805d:	00 
c010805e:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0108065:	e8 81 8c ff ff       	call   c0100ceb <__panic>

    int i, sum = 0;
c010806a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108071:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108078:	eb 17                	jmp    c0108091 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c010807a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010807d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108080:	01 d0                	add    %edx,%eax
c0108082:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108085:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108087:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010808a:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c010808d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108091:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108095:	7e e3                	jle    c010807a <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108097:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010809e:	eb 15                	jmp    c01080b5 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c01080a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01080a6:	01 d0                	add    %edx,%eax
c01080a8:	0f b6 00             	movzbl (%eax),%eax
c01080ab:	0f be c0             	movsbl %al,%eax
c01080ae:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c01080b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01080b5:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01080b9:	7e e5                	jle    c01080a0 <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c01080bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01080bf:	74 24                	je     c01080e5 <check_pgfault+0x1a7>
c01080c1:	c7 44 24 0c e7 ac 10 	movl   $0xc010ace7,0xc(%esp)
c01080c8:	c0 
c01080c9:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c01080d0:	c0 
c01080d1:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01080d8:	00 
c01080d9:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c01080e0:	e8 06 8c ff ff       	call   c0100ceb <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01080e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01080e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01080eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01080ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01080f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01080fa:	89 04 24             	mov    %eax,(%esp)
c01080fd:	e8 6f d0 ff ff       	call   c0105171 <page_remove>
    free_page(pde2page(pgdir[0]));
c0108102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108105:	8b 00                	mov    (%eax),%eax
c0108107:	89 04 24             	mov    %eax,(%esp)
c010810a:	e8 38 f5 ff ff       	call   c0107647 <pde2page>
c010810f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108116:	00 
c0108117:	89 04 24             	mov    %eax,(%esp)
c010811a:	e8 ec c7 ff ff       	call   c010490b <free_pages>
    pgdir[0] = 0;
c010811f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108122:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108128:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010812b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108132:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108135:	89 04 24             	mov    %eax,(%esp)
c0108138:	e8 5a f8 ff ff       	call   c0107997 <mm_destroy>
    check_mm_struct = NULL;
c010813d:	c7 05 8c 41 12 c0 00 	movl   $0x0,0xc012418c
c0108144:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108147:	e8 f1 c7 ff ff       	call   c010493d <nr_free_pages>
c010814c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010814f:	74 24                	je     c0108175 <check_pgfault+0x237>
c0108151:	c7 44 24 0c 04 ab 10 	movl   $0xc010ab04,0xc(%esp)
c0108158:	c0 
c0108159:	c7 44 24 08 83 aa 10 	movl   $0xc010aa83,0x8(%esp)
c0108160:	c0 
c0108161:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0108168:	00 
c0108169:	c7 04 24 98 aa 10 c0 	movl   $0xc010aa98,(%esp)
c0108170:	e8 76 8b ff ff       	call   c0100ceb <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108175:	c7 04 24 f0 ac 10 c0 	movl   $0xc010acf0,(%esp)
c010817c:	e8 d6 81 ff ff       	call   c0100357 <cprintf>
}
c0108181:	c9                   	leave  
c0108182:	c3                   	ret    

c0108183 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0108183:	55                   	push   %ebp
c0108184:	89 e5                	mov    %esp,%ebp
c0108186:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108189:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108190:	8b 45 10             	mov    0x10(%ebp),%eax
c0108193:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108197:	8b 45 08             	mov    0x8(%ebp),%eax
c010819a:	89 04 24             	mov    %eax,(%esp)
c010819d:	e8 70 f5 ff ff       	call   c0107712 <find_vma>
c01081a2:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01081a5:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01081aa:	83 c0 01             	add    $0x1,%eax
c01081ad:	a3 38 40 12 c0       	mov    %eax,0xc0124038
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01081b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01081b6:	74 0b                	je     c01081c3 <do_pgfault+0x40>
c01081b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081bb:	8b 40 04             	mov    0x4(%eax),%eax
c01081be:	3b 45 10             	cmp    0x10(%ebp),%eax
c01081c1:	76 18                	jbe    c01081db <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01081c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01081c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081ca:	c7 04 24 0c ad 10 c0 	movl   $0xc010ad0c,(%esp)
c01081d1:	e8 81 81 ff ff       	call   c0100357 <cprintf>
        goto failed;
c01081d6:	e9 bb 01 00 00       	jmp    c0108396 <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c01081db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081de:	83 e0 03             	and    $0x3,%eax
c01081e1:	85 c0                	test   %eax,%eax
c01081e3:	74 36                	je     c010821b <do_pgfault+0x98>
c01081e5:	83 f8 01             	cmp    $0x1,%eax
c01081e8:	74 20                	je     c010820a <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c01081ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081ed:	8b 40 0c             	mov    0xc(%eax),%eax
c01081f0:	83 e0 02             	and    $0x2,%eax
c01081f3:	85 c0                	test   %eax,%eax
c01081f5:	75 11                	jne    c0108208 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01081f7:	c7 04 24 3c ad 10 c0 	movl   $0xc010ad3c,(%esp)
c01081fe:	e8 54 81 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0108203:	e9 8e 01 00 00       	jmp    c0108396 <do_pgfault+0x213>
        }
        break;
c0108208:	eb 2f                	jmp    c0108239 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c010820a:	c7 04 24 9c ad 10 c0 	movl   $0xc010ad9c,(%esp)
c0108211:	e8 41 81 ff ff       	call   c0100357 <cprintf>
        goto failed;
c0108216:	e9 7b 01 00 00       	jmp    c0108396 <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c010821b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010821e:	8b 40 0c             	mov    0xc(%eax),%eax
c0108221:	83 e0 05             	and    $0x5,%eax
c0108224:	85 c0                	test   %eax,%eax
c0108226:	75 11                	jne    c0108239 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108228:	c7 04 24 d4 ad 10 c0 	movl   $0xc010add4,(%esp)
c010822f:	e8 23 81 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0108234:	e9 5d 01 00 00       	jmp    c0108396 <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108239:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108240:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108243:	8b 40 0c             	mov    0xc(%eax),%eax
c0108246:	83 e0 02             	and    $0x2,%eax
c0108249:	85 c0                	test   %eax,%eax
c010824b:	74 04                	je     c0108251 <do_pgfault+0xce>
        perm |= PTE_W;
c010824d:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108251:	8b 45 10             	mov    0x10(%ebp),%eax
c0108254:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108257:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010825a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010825f:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0108262:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108269:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0108270:	8b 45 08             	mov    0x8(%ebp),%eax
c0108273:	8b 40 0c             	mov    0xc(%eax),%eax
c0108276:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010827d:	00 
c010827e:	8b 55 10             	mov    0x10(%ebp),%edx
c0108281:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108285:	89 04 24             	mov    %eax,(%esp)
c0108288:	e8 f2 cc ff ff       	call   c0104f7f <get_pte>
c010828d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108290:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108294:	75 11                	jne    c01082a7 <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0108296:	c7 04 24 37 ae 10 c0 	movl   $0xc010ae37,(%esp)
c010829d:	e8 b5 80 ff ff       	call   c0100357 <cprintf>
        goto failed;
c01082a2:	e9 ef 00 00 00       	jmp    c0108396 <do_pgfault+0x213>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c01082a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082aa:	8b 00                	mov    (%eax),%eax
c01082ac:	85 c0                	test   %eax,%eax
c01082ae:	75 35                	jne    c01082e5 <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01082b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b3:	8b 40 0c             	mov    0xc(%eax),%eax
c01082b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01082b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01082bd:	8b 55 10             	mov    0x10(%ebp),%edx
c01082c0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01082c4:	89 04 24             	mov    %eax,(%esp)
c01082c7:	e8 ff cf ff ff       	call   c01052cb <pgdir_alloc_page>
c01082cc:	85 c0                	test   %eax,%eax
c01082ce:	0f 85 bb 00 00 00    	jne    c010838f <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01082d4:	c7 04 24 58 ae 10 c0 	movl   $0xc010ae58,(%esp)
c01082db:	e8 77 80 ff ff       	call   c0100357 <cprintf>
            goto failed;
c01082e0:	e9 b1 00 00 00       	jmp    c0108396 <do_pgfault+0x213>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c01082e5:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c01082ea:	85 c0                	test   %eax,%eax
c01082ec:	0f 84 86 00 00 00    	je     c0108378 <do_pgfault+0x1f5>
            struct Page *page=NULL;
c01082f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01082f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01082fc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108300:	8b 45 10             	mov    0x10(%ebp),%eax
c0108303:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108307:	8b 45 08             	mov    0x8(%ebp),%eax
c010830a:	89 04 24             	mov    %eax,(%esp)
c010830d:	e8 7e e1 ff ff       	call   c0106490 <swap_in>
c0108312:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108315:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108319:	74 0e                	je     c0108329 <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c010831b:	c7 04 24 7f ae 10 c0 	movl   $0xc010ae7f,(%esp)
c0108322:	e8 30 80 ff ff       	call   c0100357 <cprintf>
c0108327:	eb 6d                	jmp    c0108396 <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0108329:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010832c:	8b 45 08             	mov    0x8(%ebp),%eax
c010832f:	8b 40 0c             	mov    0xc(%eax),%eax
c0108332:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108335:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108339:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010833c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108340:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108344:	89 04 24             	mov    %eax,(%esp)
c0108347:	e8 69 ce ff ff       	call   c01051b5 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c010834c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010834f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108356:	00 
c0108357:	89 44 24 08          	mov    %eax,0x8(%esp)
c010835b:	8b 45 10             	mov    0x10(%ebp),%eax
c010835e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108362:	8b 45 08             	mov    0x8(%ebp),%eax
c0108365:	89 04 24             	mov    %eax,(%esp)
c0108368:	e8 5a df ff ff       	call   c01062c7 <swap_map_swappable>
            page->pra_vaddr = addr;
c010836d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108370:	8b 55 10             	mov    0x10(%ebp),%edx
c0108373:	89 50 1c             	mov    %edx,0x1c(%eax)
c0108376:	eb 17                	jmp    c010838f <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0108378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010837b:	8b 00                	mov    (%eax),%eax
c010837d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108381:	c7 04 24 a0 ae 10 c0 	movl   $0xc010aea0,(%esp)
c0108388:	e8 ca 7f ff ff       	call   c0100357 <cprintf>
            goto failed;
c010838d:	eb 07                	jmp    c0108396 <do_pgfault+0x213>
        }
   }
   ret = 0;
c010838f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0108396:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108399:	c9                   	leave  
c010839a:	c3                   	ret    

c010839b <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010839b:	55                   	push   %ebp
c010839c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010839e:	8b 55 08             	mov    0x8(%ebp),%edx
c01083a1:	a1 a4 40 12 c0       	mov    0xc01240a4,%eax
c01083a6:	29 c2                	sub    %eax,%edx
c01083a8:	89 d0                	mov    %edx,%eax
c01083aa:	c1 f8 05             	sar    $0x5,%eax
}
c01083ad:	5d                   	pop    %ebp
c01083ae:	c3                   	ret    

c01083af <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01083af:	55                   	push   %ebp
c01083b0:	89 e5                	mov    %esp,%ebp
c01083b2:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01083b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01083b8:	89 04 24             	mov    %eax,(%esp)
c01083bb:	e8 db ff ff ff       	call   c010839b <page2ppn>
c01083c0:	c1 e0 0c             	shl    $0xc,%eax
}
c01083c3:	c9                   	leave  
c01083c4:	c3                   	ret    

c01083c5 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c01083c5:	55                   	push   %ebp
c01083c6:	89 e5                	mov    %esp,%ebp
c01083c8:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01083cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ce:	89 04 24             	mov    %eax,(%esp)
c01083d1:	e8 d9 ff ff ff       	call   c01083af <page2pa>
c01083d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083dc:	c1 e8 0c             	shr    $0xc,%eax
c01083df:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01083e2:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c01083e7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01083ea:	72 23                	jb     c010840f <page2kva+0x4a>
c01083ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01083f3:	c7 44 24 08 c8 ae 10 	movl   $0xc010aec8,0x8(%esp)
c01083fa:	c0 
c01083fb:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0108402:	00 
c0108403:	c7 04 24 eb ae 10 c0 	movl   $0xc010aeeb,(%esp)
c010840a:	e8 dc 88 ff ff       	call   c0100ceb <__panic>
c010840f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108412:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108417:	c9                   	leave  
c0108418:	c3                   	ret    

c0108419 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0108419:	55                   	push   %ebp
c010841a:	89 e5                	mov    %esp,%ebp
c010841c:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010841f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108426:	e8 21 96 ff ff       	call   c0101a4c <ide_device_valid>
c010842b:	85 c0                	test   %eax,%eax
c010842d:	75 1c                	jne    c010844b <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c010842f:	c7 44 24 08 f9 ae 10 	movl   $0xc010aef9,0x8(%esp)
c0108436:	c0 
c0108437:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c010843e:	00 
c010843f:	c7 04 24 13 af 10 c0 	movl   $0xc010af13,(%esp)
c0108446:	e8 a0 88 ff ff       	call   c0100ceb <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c010844b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108452:	e8 34 96 ff ff       	call   c0101a8b <ide_device_size>
c0108457:	c1 e8 03             	shr    $0x3,%eax
c010845a:	a3 5c 41 12 c0       	mov    %eax,0xc012415c
}
c010845f:	c9                   	leave  
c0108460:	c3                   	ret    

c0108461 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0108461:	55                   	push   %ebp
c0108462:	89 e5                	mov    %esp,%ebp
c0108464:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108467:	8b 45 0c             	mov    0xc(%ebp),%eax
c010846a:	89 04 24             	mov    %eax,(%esp)
c010846d:	e8 53 ff ff ff       	call   c01083c5 <page2kva>
c0108472:	8b 55 08             	mov    0x8(%ebp),%edx
c0108475:	c1 ea 08             	shr    $0x8,%edx
c0108478:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010847b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010847f:	74 0b                	je     c010848c <swapfs_read+0x2b>
c0108481:	8b 15 5c 41 12 c0    	mov    0xc012415c,%edx
c0108487:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010848a:	72 23                	jb     c01084af <swapfs_read+0x4e>
c010848c:	8b 45 08             	mov    0x8(%ebp),%eax
c010848f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108493:	c7 44 24 08 24 af 10 	movl   $0xc010af24,0x8(%esp)
c010849a:	c0 
c010849b:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01084a2:	00 
c01084a3:	c7 04 24 13 af 10 c0 	movl   $0xc010af13,(%esp)
c01084aa:	e8 3c 88 ff ff       	call   c0100ceb <__panic>
c01084af:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084b2:	c1 e2 03             	shl    $0x3,%edx
c01084b5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01084bc:	00 
c01084bd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01084c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084cc:	e8 f9 95 ff ff       	call   c0101aca <ide_read_secs>
}
c01084d1:	c9                   	leave  
c01084d2:	c3                   	ret    

c01084d3 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01084d3:	55                   	push   %ebp
c01084d4:	89 e5                	mov    %esp,%ebp
c01084d6:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01084d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084dc:	89 04 24             	mov    %eax,(%esp)
c01084df:	e8 e1 fe ff ff       	call   c01083c5 <page2kva>
c01084e4:	8b 55 08             	mov    0x8(%ebp),%edx
c01084e7:	c1 ea 08             	shr    $0x8,%edx
c01084ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01084ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01084f1:	74 0b                	je     c01084fe <swapfs_write+0x2b>
c01084f3:	8b 15 5c 41 12 c0    	mov    0xc012415c,%edx
c01084f9:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01084fc:	72 23                	jb     c0108521 <swapfs_write+0x4e>
c01084fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108501:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108505:	c7 44 24 08 24 af 10 	movl   $0xc010af24,0x8(%esp)
c010850c:	c0 
c010850d:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0108514:	00 
c0108515:	c7 04 24 13 af 10 c0 	movl   $0xc010af13,(%esp)
c010851c:	e8 ca 87 ff ff       	call   c0100ceb <__panic>
c0108521:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108524:	c1 e2 03             	shl    $0x3,%edx
c0108527:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010852e:	00 
c010852f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108533:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108537:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010853e:	e8 c9 97 ff ff       	call   c0101d0c <ide_write_secs>
}
c0108543:	c9                   	leave  
c0108544:	c3                   	ret    

c0108545 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0108545:	55                   	push   %ebp
c0108546:	89 e5                	mov    %esp,%ebp
c0108548:	83 ec 58             	sub    $0x58,%esp
c010854b:	8b 45 10             	mov    0x10(%ebp),%eax
c010854e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108551:	8b 45 14             	mov    0x14(%ebp),%eax
c0108554:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108557:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010855a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010855d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108560:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108563:	8b 45 18             	mov    0x18(%ebp),%eax
c0108566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108569:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010856c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010856f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108572:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108575:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108578:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010857b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010857f:	74 1c                	je     c010859d <printnum+0x58>
c0108581:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108584:	ba 00 00 00 00       	mov    $0x0,%edx
c0108589:	f7 75 e4             	divl   -0x1c(%ebp)
c010858c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010858f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108592:	ba 00 00 00 00       	mov    $0x0,%edx
c0108597:	f7 75 e4             	divl   -0x1c(%ebp)
c010859a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010859d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085a3:	f7 75 e4             	divl   -0x1c(%ebp)
c01085a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01085a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01085ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085af:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01085b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01085b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01085b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085bb:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01085be:	8b 45 18             	mov    0x18(%ebp),%eax
c01085c1:	ba 00 00 00 00       	mov    $0x0,%edx
c01085c6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01085c9:	77 56                	ja     c0108621 <printnum+0xdc>
c01085cb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01085ce:	72 05                	jb     c01085d5 <printnum+0x90>
c01085d0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01085d3:	77 4c                	ja     c0108621 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01085d5:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01085d8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01085db:	8b 45 20             	mov    0x20(%ebp),%eax
c01085de:	89 44 24 18          	mov    %eax,0x18(%esp)
c01085e2:	89 54 24 14          	mov    %edx,0x14(%esp)
c01085e6:	8b 45 18             	mov    0x18(%ebp),%eax
c01085e9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01085ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01085f3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01085f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01085fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108602:	8b 45 08             	mov    0x8(%ebp),%eax
c0108605:	89 04 24             	mov    %eax,(%esp)
c0108608:	e8 38 ff ff ff       	call   c0108545 <printnum>
c010860d:	eb 1c                	jmp    c010862b <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010860f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108612:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108616:	8b 45 20             	mov    0x20(%ebp),%eax
c0108619:	89 04 24             	mov    %eax,(%esp)
c010861c:	8b 45 08             	mov    0x8(%ebp),%eax
c010861f:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0108621:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0108625:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108629:	7f e4                	jg     c010860f <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010862b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010862e:	05 c4 af 10 c0       	add    $0xc010afc4,%eax
c0108633:	0f b6 00             	movzbl (%eax),%eax
c0108636:	0f be c0             	movsbl %al,%eax
c0108639:	8b 55 0c             	mov    0xc(%ebp),%edx
c010863c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108640:	89 04 24             	mov    %eax,(%esp)
c0108643:	8b 45 08             	mov    0x8(%ebp),%eax
c0108646:	ff d0                	call   *%eax
}
c0108648:	c9                   	leave  
c0108649:	c3                   	ret    

c010864a <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010864a:	55                   	push   %ebp
c010864b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010864d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108651:	7e 14                	jle    c0108667 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108653:	8b 45 08             	mov    0x8(%ebp),%eax
c0108656:	8b 00                	mov    (%eax),%eax
c0108658:	8d 48 08             	lea    0x8(%eax),%ecx
c010865b:	8b 55 08             	mov    0x8(%ebp),%edx
c010865e:	89 0a                	mov    %ecx,(%edx)
c0108660:	8b 50 04             	mov    0x4(%eax),%edx
c0108663:	8b 00                	mov    (%eax),%eax
c0108665:	eb 30                	jmp    c0108697 <getuint+0x4d>
    }
    else if (lflag) {
c0108667:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010866b:	74 16                	je     c0108683 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010866d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108670:	8b 00                	mov    (%eax),%eax
c0108672:	8d 48 04             	lea    0x4(%eax),%ecx
c0108675:	8b 55 08             	mov    0x8(%ebp),%edx
c0108678:	89 0a                	mov    %ecx,(%edx)
c010867a:	8b 00                	mov    (%eax),%eax
c010867c:	ba 00 00 00 00       	mov    $0x0,%edx
c0108681:	eb 14                	jmp    c0108697 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108683:	8b 45 08             	mov    0x8(%ebp),%eax
c0108686:	8b 00                	mov    (%eax),%eax
c0108688:	8d 48 04             	lea    0x4(%eax),%ecx
c010868b:	8b 55 08             	mov    0x8(%ebp),%edx
c010868e:	89 0a                	mov    %ecx,(%edx)
c0108690:	8b 00                	mov    (%eax),%eax
c0108692:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0108697:	5d                   	pop    %ebp
c0108698:	c3                   	ret    

c0108699 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0108699:	55                   	push   %ebp
c010869a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010869c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01086a0:	7e 14                	jle    c01086b6 <getint+0x1d>
        return va_arg(*ap, long long);
c01086a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01086a5:	8b 00                	mov    (%eax),%eax
c01086a7:	8d 48 08             	lea    0x8(%eax),%ecx
c01086aa:	8b 55 08             	mov    0x8(%ebp),%edx
c01086ad:	89 0a                	mov    %ecx,(%edx)
c01086af:	8b 50 04             	mov    0x4(%eax),%edx
c01086b2:	8b 00                	mov    (%eax),%eax
c01086b4:	eb 28                	jmp    c01086de <getint+0x45>
    }
    else if (lflag) {
c01086b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01086ba:	74 12                	je     c01086ce <getint+0x35>
        return va_arg(*ap, long);
c01086bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01086bf:	8b 00                	mov    (%eax),%eax
c01086c1:	8d 48 04             	lea    0x4(%eax),%ecx
c01086c4:	8b 55 08             	mov    0x8(%ebp),%edx
c01086c7:	89 0a                	mov    %ecx,(%edx)
c01086c9:	8b 00                	mov    (%eax),%eax
c01086cb:	99                   	cltd   
c01086cc:	eb 10                	jmp    c01086de <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01086ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01086d1:	8b 00                	mov    (%eax),%eax
c01086d3:	8d 48 04             	lea    0x4(%eax),%ecx
c01086d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01086d9:	89 0a                	mov    %ecx,(%edx)
c01086db:	8b 00                	mov    (%eax),%eax
c01086dd:	99                   	cltd   
    }
}
c01086de:	5d                   	pop    %ebp
c01086df:	c3                   	ret    

c01086e0 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01086e0:	55                   	push   %ebp
c01086e1:	89 e5                	mov    %esp,%ebp
c01086e3:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01086e6:	8d 45 14             	lea    0x14(%ebp),%eax
c01086e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01086ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01086f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01086f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108701:	8b 45 08             	mov    0x8(%ebp),%eax
c0108704:	89 04 24             	mov    %eax,(%esp)
c0108707:	e8 02 00 00 00       	call   c010870e <vprintfmt>
    va_end(ap);
}
c010870c:	c9                   	leave  
c010870d:	c3                   	ret    

c010870e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010870e:	55                   	push   %ebp
c010870f:	89 e5                	mov    %esp,%ebp
c0108711:	56                   	push   %esi
c0108712:	53                   	push   %ebx
c0108713:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108716:	eb 18                	jmp    c0108730 <vprintfmt+0x22>
            if (ch == '\0') {
c0108718:	85 db                	test   %ebx,%ebx
c010871a:	75 05                	jne    c0108721 <vprintfmt+0x13>
                return;
c010871c:	e9 d1 03 00 00       	jmp    c0108af2 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0108721:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108724:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108728:	89 1c 24             	mov    %ebx,(%esp)
c010872b:	8b 45 08             	mov    0x8(%ebp),%eax
c010872e:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108730:	8b 45 10             	mov    0x10(%ebp),%eax
c0108733:	8d 50 01             	lea    0x1(%eax),%edx
c0108736:	89 55 10             	mov    %edx,0x10(%ebp)
c0108739:	0f b6 00             	movzbl (%eax),%eax
c010873c:	0f b6 d8             	movzbl %al,%ebx
c010873f:	83 fb 25             	cmp    $0x25,%ebx
c0108742:	75 d4                	jne    c0108718 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108744:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108748:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010874f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108752:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0108755:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010875c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010875f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108762:	8b 45 10             	mov    0x10(%ebp),%eax
c0108765:	8d 50 01             	lea    0x1(%eax),%edx
c0108768:	89 55 10             	mov    %edx,0x10(%ebp)
c010876b:	0f b6 00             	movzbl (%eax),%eax
c010876e:	0f b6 d8             	movzbl %al,%ebx
c0108771:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108774:	83 f8 55             	cmp    $0x55,%eax
c0108777:	0f 87 44 03 00 00    	ja     c0108ac1 <vprintfmt+0x3b3>
c010877d:	8b 04 85 e8 af 10 c0 	mov    -0x3fef5018(,%eax,4),%eax
c0108784:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0108786:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010878a:	eb d6                	jmp    c0108762 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010878c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0108790:	eb d0                	jmp    c0108762 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108792:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0108799:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010879c:	89 d0                	mov    %edx,%eax
c010879e:	c1 e0 02             	shl    $0x2,%eax
c01087a1:	01 d0                	add    %edx,%eax
c01087a3:	01 c0                	add    %eax,%eax
c01087a5:	01 d8                	add    %ebx,%eax
c01087a7:	83 e8 30             	sub    $0x30,%eax
c01087aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01087ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01087b0:	0f b6 00             	movzbl (%eax),%eax
c01087b3:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01087b6:	83 fb 2f             	cmp    $0x2f,%ebx
c01087b9:	7e 0b                	jle    c01087c6 <vprintfmt+0xb8>
c01087bb:	83 fb 39             	cmp    $0x39,%ebx
c01087be:	7f 06                	jg     c01087c6 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01087c0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01087c4:	eb d3                	jmp    c0108799 <vprintfmt+0x8b>
            goto process_precision;
c01087c6:	eb 33                	jmp    c01087fb <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c01087c8:	8b 45 14             	mov    0x14(%ebp),%eax
c01087cb:	8d 50 04             	lea    0x4(%eax),%edx
c01087ce:	89 55 14             	mov    %edx,0x14(%ebp)
c01087d1:	8b 00                	mov    (%eax),%eax
c01087d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01087d6:	eb 23                	jmp    c01087fb <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01087d8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01087dc:	79 0c                	jns    c01087ea <vprintfmt+0xdc>
                width = 0;
c01087de:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01087e5:	e9 78 ff ff ff       	jmp    c0108762 <vprintfmt+0x54>
c01087ea:	e9 73 ff ff ff       	jmp    c0108762 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01087ef:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01087f6:	e9 67 ff ff ff       	jmp    c0108762 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01087fb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01087ff:	79 12                	jns    c0108813 <vprintfmt+0x105>
                width = precision, precision = -1;
c0108801:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108804:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108807:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010880e:	e9 4f ff ff ff       	jmp    c0108762 <vprintfmt+0x54>
c0108813:	e9 4a ff ff ff       	jmp    c0108762 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108818:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010881c:	e9 41 ff ff ff       	jmp    c0108762 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108821:	8b 45 14             	mov    0x14(%ebp),%eax
c0108824:	8d 50 04             	lea    0x4(%eax),%edx
c0108827:	89 55 14             	mov    %edx,0x14(%ebp)
c010882a:	8b 00                	mov    (%eax),%eax
c010882c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010882f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108833:	89 04 24             	mov    %eax,(%esp)
c0108836:	8b 45 08             	mov    0x8(%ebp),%eax
c0108839:	ff d0                	call   *%eax
            break;
c010883b:	e9 ac 02 00 00       	jmp    c0108aec <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108840:	8b 45 14             	mov    0x14(%ebp),%eax
c0108843:	8d 50 04             	lea    0x4(%eax),%edx
c0108846:	89 55 14             	mov    %edx,0x14(%ebp)
c0108849:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010884b:	85 db                	test   %ebx,%ebx
c010884d:	79 02                	jns    c0108851 <vprintfmt+0x143>
                err = -err;
c010884f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108851:	83 fb 06             	cmp    $0x6,%ebx
c0108854:	7f 0b                	jg     c0108861 <vprintfmt+0x153>
c0108856:	8b 34 9d a8 af 10 c0 	mov    -0x3fef5058(,%ebx,4),%esi
c010885d:	85 f6                	test   %esi,%esi
c010885f:	75 23                	jne    c0108884 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0108861:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108865:	c7 44 24 08 d5 af 10 	movl   $0xc010afd5,0x8(%esp)
c010886c:	c0 
c010886d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108870:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108874:	8b 45 08             	mov    0x8(%ebp),%eax
c0108877:	89 04 24             	mov    %eax,(%esp)
c010887a:	e8 61 fe ff ff       	call   c01086e0 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010887f:	e9 68 02 00 00       	jmp    c0108aec <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0108884:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108888:	c7 44 24 08 de af 10 	movl   $0xc010afde,0x8(%esp)
c010888f:	c0 
c0108890:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108893:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108897:	8b 45 08             	mov    0x8(%ebp),%eax
c010889a:	89 04 24             	mov    %eax,(%esp)
c010889d:	e8 3e fe ff ff       	call   c01086e0 <printfmt>
            }
            break;
c01088a2:	e9 45 02 00 00       	jmp    c0108aec <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01088a7:	8b 45 14             	mov    0x14(%ebp),%eax
c01088aa:	8d 50 04             	lea    0x4(%eax),%edx
c01088ad:	89 55 14             	mov    %edx,0x14(%ebp)
c01088b0:	8b 30                	mov    (%eax),%esi
c01088b2:	85 f6                	test   %esi,%esi
c01088b4:	75 05                	jne    c01088bb <vprintfmt+0x1ad>
                p = "(null)";
c01088b6:	be e1 af 10 c0       	mov    $0xc010afe1,%esi
            }
            if (width > 0 && padc != '-') {
c01088bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01088bf:	7e 3e                	jle    c01088ff <vprintfmt+0x1f1>
c01088c1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01088c5:	74 38                	je     c01088ff <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01088c7:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c01088ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088d1:	89 34 24             	mov    %esi,(%esp)
c01088d4:	e8 ed 03 00 00       	call   c0108cc6 <strnlen>
c01088d9:	29 c3                	sub    %eax,%ebx
c01088db:	89 d8                	mov    %ebx,%eax
c01088dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01088e0:	eb 17                	jmp    c01088f9 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01088e2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01088e6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01088e9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01088ed:	89 04 24             	mov    %eax,(%esp)
c01088f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01088f3:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01088f5:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01088f9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01088fd:	7f e3                	jg     c01088e2 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01088ff:	eb 38                	jmp    c0108939 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108901:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108905:	74 1f                	je     c0108926 <vprintfmt+0x218>
c0108907:	83 fb 1f             	cmp    $0x1f,%ebx
c010890a:	7e 05                	jle    c0108911 <vprintfmt+0x203>
c010890c:	83 fb 7e             	cmp    $0x7e,%ebx
c010890f:	7e 15                	jle    c0108926 <vprintfmt+0x218>
                    putch('?', putdat);
c0108911:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108914:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108918:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010891f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108922:	ff d0                	call   *%eax
c0108924:	eb 0f                	jmp    c0108935 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0108926:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108929:	89 44 24 04          	mov    %eax,0x4(%esp)
c010892d:	89 1c 24             	mov    %ebx,(%esp)
c0108930:	8b 45 08             	mov    0x8(%ebp),%eax
c0108933:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108935:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0108939:	89 f0                	mov    %esi,%eax
c010893b:	8d 70 01             	lea    0x1(%eax),%esi
c010893e:	0f b6 00             	movzbl (%eax),%eax
c0108941:	0f be d8             	movsbl %al,%ebx
c0108944:	85 db                	test   %ebx,%ebx
c0108946:	74 10                	je     c0108958 <vprintfmt+0x24a>
c0108948:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010894c:	78 b3                	js     c0108901 <vprintfmt+0x1f3>
c010894e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0108952:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108956:	79 a9                	jns    c0108901 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0108958:	eb 17                	jmp    c0108971 <vprintfmt+0x263>
                putch(' ', putdat);
c010895a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010895d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108961:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108968:	8b 45 08             	mov    0x8(%ebp),%eax
c010896b:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010896d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0108971:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108975:	7f e3                	jg     c010895a <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c0108977:	e9 70 01 00 00       	jmp    c0108aec <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010897c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010897f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108983:	8d 45 14             	lea    0x14(%ebp),%eax
c0108986:	89 04 24             	mov    %eax,(%esp)
c0108989:	e8 0b fd ff ff       	call   c0108699 <getint>
c010898e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108991:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0108994:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108997:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010899a:	85 d2                	test   %edx,%edx
c010899c:	79 26                	jns    c01089c4 <vprintfmt+0x2b6>
                putch('-', putdat);
c010899e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089a5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01089ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01089af:	ff d0                	call   *%eax
                num = -(long long)num;
c01089b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089b7:	f7 d8                	neg    %eax
c01089b9:	83 d2 00             	adc    $0x0,%edx
c01089bc:	f7 da                	neg    %edx
c01089be:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01089c4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01089cb:	e9 a8 00 00 00       	jmp    c0108a78 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01089d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01089d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089d7:	8d 45 14             	lea    0x14(%ebp),%eax
c01089da:	89 04 24             	mov    %eax,(%esp)
c01089dd:	e8 68 fc ff ff       	call   c010864a <getuint>
c01089e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089e5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01089e8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01089ef:	e9 84 00 00 00       	jmp    c0108a78 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01089f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01089f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089fb:	8d 45 14             	lea    0x14(%ebp),%eax
c01089fe:	89 04 24             	mov    %eax,(%esp)
c0108a01:	e8 44 fc ff ff       	call   c010864a <getuint>
c0108a06:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a09:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108a0c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108a13:	eb 63                	jmp    c0108a78 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0108a15:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a1c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0108a23:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a26:	ff d0                	call   *%eax
            putch('x', putdat);
c0108a28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a2f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108a36:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a39:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108a3b:	8b 45 14             	mov    0x14(%ebp),%eax
c0108a3e:	8d 50 04             	lea    0x4(%eax),%edx
c0108a41:	89 55 14             	mov    %edx,0x14(%ebp)
c0108a44:	8b 00                	mov    (%eax),%eax
c0108a46:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108a50:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108a57:	eb 1f                	jmp    c0108a78 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108a59:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a60:	8d 45 14             	lea    0x14(%ebp),%eax
c0108a63:	89 04 24             	mov    %eax,(%esp)
c0108a66:	e8 df fb ff ff       	call   c010864a <getuint>
c0108a6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a6e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108a71:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108a78:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a7f:	89 54 24 18          	mov    %edx,0x18(%esp)
c0108a83:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108a86:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108a8a:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a91:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a94:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108a98:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108aa3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aa6:	89 04 24             	mov    %eax,(%esp)
c0108aa9:	e8 97 fa ff ff       	call   c0108545 <printnum>
            break;
c0108aae:	eb 3c                	jmp    c0108aec <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ab7:	89 1c 24             	mov    %ebx,(%esp)
c0108aba:	8b 45 08             	mov    0x8(%ebp),%eax
c0108abd:	ff d0                	call   *%eax
            break;
c0108abf:	eb 2b                	jmp    c0108aec <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ac8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0108acf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ad2:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0108ad4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108ad8:	eb 04                	jmp    c0108ade <vprintfmt+0x3d0>
c0108ada:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108ade:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ae1:	83 e8 01             	sub    $0x1,%eax
c0108ae4:	0f b6 00             	movzbl (%eax),%eax
c0108ae7:	3c 25                	cmp    $0x25,%al
c0108ae9:	75 ef                	jne    c0108ada <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0108aeb:	90                   	nop
        }
    }
c0108aec:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108aed:	e9 3e fc ff ff       	jmp    c0108730 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0108af2:	83 c4 40             	add    $0x40,%esp
c0108af5:	5b                   	pop    %ebx
c0108af6:	5e                   	pop    %esi
c0108af7:	5d                   	pop    %ebp
c0108af8:	c3                   	ret    

c0108af9 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0108af9:	55                   	push   %ebp
c0108afa:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108afc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108aff:	8b 40 08             	mov    0x8(%eax),%eax
c0108b02:	8d 50 01             	lea    0x1(%eax),%edx
c0108b05:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b08:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0108b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b0e:	8b 10                	mov    (%eax),%edx
c0108b10:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b13:	8b 40 04             	mov    0x4(%eax),%eax
c0108b16:	39 c2                	cmp    %eax,%edx
c0108b18:	73 12                	jae    c0108b2c <sprintputch+0x33>
        *b->buf ++ = ch;
c0108b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b1d:	8b 00                	mov    (%eax),%eax
c0108b1f:	8d 48 01             	lea    0x1(%eax),%ecx
c0108b22:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108b25:	89 0a                	mov    %ecx,(%edx)
c0108b27:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b2a:	88 10                	mov    %dl,(%eax)
    }
}
c0108b2c:	5d                   	pop    %ebp
c0108b2d:	c3                   	ret    

c0108b2e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108b2e:	55                   	push   %ebp
c0108b2f:	89 e5                	mov    %esp,%ebp
c0108b31:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108b34:	8d 45 14             	lea    0x14(%ebp),%eax
c0108b37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108b41:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b44:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b52:	89 04 24             	mov    %eax,(%esp)
c0108b55:	e8 08 00 00 00       	call   c0108b62 <vsnprintf>
c0108b5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0108b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108b60:	c9                   	leave  
c0108b61:	c3                   	ret    

c0108b62 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108b62:	55                   	push   %ebp
c0108b63:	89 e5                	mov    %esp,%ebp
c0108b65:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0108b68:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b71:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108b74:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b77:	01 d0                	add    %edx,%eax
c0108b79:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108b83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108b87:	74 0a                	je     c0108b93 <vsnprintf+0x31>
c0108b89:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b8f:	39 c2                	cmp    %eax,%edx
c0108b91:	76 07                	jbe    c0108b9a <vsnprintf+0x38>
        return -E_INVAL;
c0108b93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108b98:	eb 2a                	jmp    c0108bc4 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0108b9a:	8b 45 14             	mov    0x14(%ebp),%eax
c0108b9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108ba1:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ba4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108ba8:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0108bab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108baf:	c7 04 24 f9 8a 10 c0 	movl   $0xc0108af9,(%esp)
c0108bb6:	e8 53 fb ff ff       	call   c010870e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0108bbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bbe:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108bc4:	c9                   	leave  
c0108bc5:	c3                   	ret    

c0108bc6 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108bc6:	55                   	push   %ebp
c0108bc7:	89 e5                	mov    %esp,%ebp
c0108bc9:	57                   	push   %edi
c0108bca:	56                   	push   %esi
c0108bcb:	53                   	push   %ebx
c0108bcc:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108bcf:	a1 60 0a 12 c0       	mov    0xc0120a60,%eax
c0108bd4:	8b 15 64 0a 12 c0    	mov    0xc0120a64,%edx
c0108bda:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108be0:	6b f0 05             	imul   $0x5,%eax,%esi
c0108be3:	01 f7                	add    %esi,%edi
c0108be5:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c0108bea:	f7 e6                	mul    %esi
c0108bec:	8d 34 17             	lea    (%edi,%edx,1),%esi
c0108bef:	89 f2                	mov    %esi,%edx
c0108bf1:	83 c0 0b             	add    $0xb,%eax
c0108bf4:	83 d2 00             	adc    $0x0,%edx
c0108bf7:	89 c7                	mov    %eax,%edi
c0108bf9:	83 e7 ff             	and    $0xffffffff,%edi
c0108bfc:	89 f9                	mov    %edi,%ecx
c0108bfe:	0f b7 da             	movzwl %dx,%ebx
c0108c01:	89 0d 60 0a 12 c0    	mov    %ecx,0xc0120a60
c0108c07:	89 1d 64 0a 12 c0    	mov    %ebx,0xc0120a64
    unsigned long long result = (next >> 12);
c0108c0d:	a1 60 0a 12 c0       	mov    0xc0120a60,%eax
c0108c12:	8b 15 64 0a 12 c0    	mov    0xc0120a64,%edx
c0108c18:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108c1c:	c1 ea 0c             	shr    $0xc,%edx
c0108c1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0108c25:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108c2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c2f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108c32:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c35:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108c38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108c3e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108c42:	74 1c                	je     c0108c60 <rand+0x9a>
c0108c44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c47:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c4c:	f7 75 dc             	divl   -0x24(%ebp)
c0108c4f:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c55:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c5a:	f7 75 dc             	divl   -0x24(%ebp)
c0108c5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108c60:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c63:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108c66:	f7 75 dc             	divl   -0x24(%ebp)
c0108c69:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c6c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108c6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c72:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108c75:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108c7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108c7e:	83 c4 24             	add    $0x24,%esp
c0108c81:	5b                   	pop    %ebx
c0108c82:	5e                   	pop    %esi
c0108c83:	5f                   	pop    %edi
c0108c84:	5d                   	pop    %ebp
c0108c85:	c3                   	ret    

c0108c86 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108c86:	55                   	push   %ebp
c0108c87:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108c89:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c8c:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c91:	a3 60 0a 12 c0       	mov    %eax,0xc0120a60
c0108c96:	89 15 64 0a 12 c0    	mov    %edx,0xc0120a64
}
c0108c9c:	5d                   	pop    %ebp
c0108c9d:	c3                   	ret    

c0108c9e <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0108c9e:	55                   	push   %ebp
c0108c9f:	89 e5                	mov    %esp,%ebp
c0108ca1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108ca4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0108cab:	eb 04                	jmp    c0108cb1 <strlen+0x13>
        cnt ++;
c0108cad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0108cb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cb4:	8d 50 01             	lea    0x1(%eax),%edx
c0108cb7:	89 55 08             	mov    %edx,0x8(%ebp)
c0108cba:	0f b6 00             	movzbl (%eax),%eax
c0108cbd:	84 c0                	test   %al,%al
c0108cbf:	75 ec                	jne    c0108cad <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0108cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108cc4:	c9                   	leave  
c0108cc5:	c3                   	ret    

c0108cc6 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108cc6:	55                   	push   %ebp
c0108cc7:	89 e5                	mov    %esp,%ebp
c0108cc9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108ccc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108cd3:	eb 04                	jmp    c0108cd9 <strnlen+0x13>
        cnt ++;
c0108cd5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0108cd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108cdc:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108cdf:	73 10                	jae    c0108cf1 <strnlen+0x2b>
c0108ce1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce4:	8d 50 01             	lea    0x1(%eax),%edx
c0108ce7:	89 55 08             	mov    %edx,0x8(%ebp)
c0108cea:	0f b6 00             	movzbl (%eax),%eax
c0108ced:	84 c0                	test   %al,%al
c0108cef:	75 e4                	jne    c0108cd5 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0108cf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108cf4:	c9                   	leave  
c0108cf5:	c3                   	ret    

c0108cf6 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0108cf6:	55                   	push   %ebp
c0108cf7:	89 e5                	mov    %esp,%ebp
c0108cf9:	57                   	push   %edi
c0108cfa:	56                   	push   %esi
c0108cfb:	83 ec 20             	sub    $0x20,%esp
c0108cfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d07:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108d0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d10:	89 d1                	mov    %edx,%ecx
c0108d12:	89 c2                	mov    %eax,%edx
c0108d14:	89 ce                	mov    %ecx,%esi
c0108d16:	89 d7                	mov    %edx,%edi
c0108d18:	ac                   	lods   %ds:(%esi),%al
c0108d19:	aa                   	stos   %al,%es:(%edi)
c0108d1a:	84 c0                	test   %al,%al
c0108d1c:	75 fa                	jne    c0108d18 <strcpy+0x22>
c0108d1e:	89 fa                	mov    %edi,%edx
c0108d20:	89 f1                	mov    %esi,%ecx
c0108d22:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108d25:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108d28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108d2e:	83 c4 20             	add    $0x20,%esp
c0108d31:	5e                   	pop    %esi
c0108d32:	5f                   	pop    %edi
c0108d33:	5d                   	pop    %ebp
c0108d34:	c3                   	ret    

c0108d35 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108d35:	55                   	push   %ebp
c0108d36:	89 e5                	mov    %esp,%ebp
c0108d38:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108d3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108d41:	eb 21                	jmp    c0108d64 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0108d43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d46:	0f b6 10             	movzbl (%eax),%edx
c0108d49:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d4c:	88 10                	mov    %dl,(%eax)
c0108d4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d51:	0f b6 00             	movzbl (%eax),%eax
c0108d54:	84 c0                	test   %al,%al
c0108d56:	74 04                	je     c0108d5c <strncpy+0x27>
            src ++;
c0108d58:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0108d5c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0108d60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0108d64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d68:	75 d9                	jne    c0108d43 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0108d6a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108d6d:	c9                   	leave  
c0108d6e:	c3                   	ret    

c0108d6f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0108d6f:	55                   	push   %ebp
c0108d70:	89 e5                	mov    %esp,%ebp
c0108d72:	57                   	push   %edi
c0108d73:	56                   	push   %esi
c0108d74:	83 ec 20             	sub    $0x20,%esp
c0108d77:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d80:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0108d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d89:	89 d1                	mov    %edx,%ecx
c0108d8b:	89 c2                	mov    %eax,%edx
c0108d8d:	89 ce                	mov    %ecx,%esi
c0108d8f:	89 d7                	mov    %edx,%edi
c0108d91:	ac                   	lods   %ds:(%esi),%al
c0108d92:	ae                   	scas   %es:(%edi),%al
c0108d93:	75 08                	jne    c0108d9d <strcmp+0x2e>
c0108d95:	84 c0                	test   %al,%al
c0108d97:	75 f8                	jne    c0108d91 <strcmp+0x22>
c0108d99:	31 c0                	xor    %eax,%eax
c0108d9b:	eb 04                	jmp    c0108da1 <strcmp+0x32>
c0108d9d:	19 c0                	sbb    %eax,%eax
c0108d9f:	0c 01                	or     $0x1,%al
c0108da1:	89 fa                	mov    %edi,%edx
c0108da3:	89 f1                	mov    %esi,%ecx
c0108da5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108da8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108dab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0108dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108db1:	83 c4 20             	add    $0x20,%esp
c0108db4:	5e                   	pop    %esi
c0108db5:	5f                   	pop    %edi
c0108db6:	5d                   	pop    %ebp
c0108db7:	c3                   	ret    

c0108db8 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0108db8:	55                   	push   %ebp
c0108db9:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108dbb:	eb 0c                	jmp    c0108dc9 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0108dbd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108dc1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108dc5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108dc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108dcd:	74 1a                	je     c0108de9 <strncmp+0x31>
c0108dcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dd2:	0f b6 00             	movzbl (%eax),%eax
c0108dd5:	84 c0                	test   %al,%al
c0108dd7:	74 10                	je     c0108de9 <strncmp+0x31>
c0108dd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ddc:	0f b6 10             	movzbl (%eax),%edx
c0108ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108de2:	0f b6 00             	movzbl (%eax),%eax
c0108de5:	38 c2                	cmp    %al,%dl
c0108de7:	74 d4                	je     c0108dbd <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108de9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108ded:	74 18                	je     c0108e07 <strncmp+0x4f>
c0108def:	8b 45 08             	mov    0x8(%ebp),%eax
c0108df2:	0f b6 00             	movzbl (%eax),%eax
c0108df5:	0f b6 d0             	movzbl %al,%edx
c0108df8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108dfb:	0f b6 00             	movzbl (%eax),%eax
c0108dfe:	0f b6 c0             	movzbl %al,%eax
c0108e01:	29 c2                	sub    %eax,%edx
c0108e03:	89 d0                	mov    %edx,%eax
c0108e05:	eb 05                	jmp    c0108e0c <strncmp+0x54>
c0108e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e0c:	5d                   	pop    %ebp
c0108e0d:	c3                   	ret    

c0108e0e <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108e0e:	55                   	push   %ebp
c0108e0f:	89 e5                	mov    %esp,%ebp
c0108e11:	83 ec 04             	sub    $0x4,%esp
c0108e14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e17:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e1a:	eb 14                	jmp    c0108e30 <strchr+0x22>
        if (*s == c) {
c0108e1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e1f:	0f b6 00             	movzbl (%eax),%eax
c0108e22:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108e25:	75 05                	jne    c0108e2c <strchr+0x1e>
            return (char *)s;
c0108e27:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e2a:	eb 13                	jmp    c0108e3f <strchr+0x31>
        }
        s ++;
c0108e2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0108e30:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e33:	0f b6 00             	movzbl (%eax),%eax
c0108e36:	84 c0                	test   %al,%al
c0108e38:	75 e2                	jne    c0108e1c <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0108e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e3f:	c9                   	leave  
c0108e40:	c3                   	ret    

c0108e41 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108e41:	55                   	push   %ebp
c0108e42:	89 e5                	mov    %esp,%ebp
c0108e44:	83 ec 04             	sub    $0x4,%esp
c0108e47:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e4a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e4d:	eb 11                	jmp    c0108e60 <strfind+0x1f>
        if (*s == c) {
c0108e4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e52:	0f b6 00             	movzbl (%eax),%eax
c0108e55:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108e58:	75 02                	jne    c0108e5c <strfind+0x1b>
            break;
c0108e5a:	eb 0e                	jmp    c0108e6a <strfind+0x29>
        }
        s ++;
c0108e5c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0108e60:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e63:	0f b6 00             	movzbl (%eax),%eax
c0108e66:	84 c0                	test   %al,%al
c0108e68:	75 e5                	jne    c0108e4f <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0108e6a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108e6d:	c9                   	leave  
c0108e6e:	c3                   	ret    

c0108e6f <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108e6f:	55                   	push   %ebp
c0108e70:	89 e5                	mov    %esp,%ebp
c0108e72:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108e75:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108e7c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108e83:	eb 04                	jmp    c0108e89 <strtol+0x1a>
        s ++;
c0108e85:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e8c:	0f b6 00             	movzbl (%eax),%eax
c0108e8f:	3c 20                	cmp    $0x20,%al
c0108e91:	74 f2                	je     c0108e85 <strtol+0x16>
c0108e93:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e96:	0f b6 00             	movzbl (%eax),%eax
c0108e99:	3c 09                	cmp    $0x9,%al
c0108e9b:	74 e8                	je     c0108e85 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0108e9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea0:	0f b6 00             	movzbl (%eax),%eax
c0108ea3:	3c 2b                	cmp    $0x2b,%al
c0108ea5:	75 06                	jne    c0108ead <strtol+0x3e>
        s ++;
c0108ea7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108eab:	eb 15                	jmp    c0108ec2 <strtol+0x53>
    }
    else if (*s == '-') {
c0108ead:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eb0:	0f b6 00             	movzbl (%eax),%eax
c0108eb3:	3c 2d                	cmp    $0x2d,%al
c0108eb5:	75 0b                	jne    c0108ec2 <strtol+0x53>
        s ++, neg = 1;
c0108eb7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108ebb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108ec2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108ec6:	74 06                	je     c0108ece <strtol+0x5f>
c0108ec8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108ecc:	75 24                	jne    c0108ef2 <strtol+0x83>
c0108ece:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ed1:	0f b6 00             	movzbl (%eax),%eax
c0108ed4:	3c 30                	cmp    $0x30,%al
c0108ed6:	75 1a                	jne    c0108ef2 <strtol+0x83>
c0108ed8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108edb:	83 c0 01             	add    $0x1,%eax
c0108ede:	0f b6 00             	movzbl (%eax),%eax
c0108ee1:	3c 78                	cmp    $0x78,%al
c0108ee3:	75 0d                	jne    c0108ef2 <strtol+0x83>
        s += 2, base = 16;
c0108ee5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108ee9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108ef0:	eb 2a                	jmp    c0108f1c <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0108ef2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108ef6:	75 17                	jne    c0108f0f <strtol+0xa0>
c0108ef8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108efb:	0f b6 00             	movzbl (%eax),%eax
c0108efe:	3c 30                	cmp    $0x30,%al
c0108f00:	75 0d                	jne    c0108f0f <strtol+0xa0>
        s ++, base = 8;
c0108f02:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108f06:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108f0d:	eb 0d                	jmp    c0108f1c <strtol+0xad>
    }
    else if (base == 0) {
c0108f0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108f13:	75 07                	jne    c0108f1c <strtol+0xad>
        base = 10;
c0108f15:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108f1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f1f:	0f b6 00             	movzbl (%eax),%eax
c0108f22:	3c 2f                	cmp    $0x2f,%al
c0108f24:	7e 1b                	jle    c0108f41 <strtol+0xd2>
c0108f26:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f29:	0f b6 00             	movzbl (%eax),%eax
c0108f2c:	3c 39                	cmp    $0x39,%al
c0108f2e:	7f 11                	jg     c0108f41 <strtol+0xd2>
            dig = *s - '0';
c0108f30:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f33:	0f b6 00             	movzbl (%eax),%eax
c0108f36:	0f be c0             	movsbl %al,%eax
c0108f39:	83 e8 30             	sub    $0x30,%eax
c0108f3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f3f:	eb 48                	jmp    c0108f89 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108f41:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f44:	0f b6 00             	movzbl (%eax),%eax
c0108f47:	3c 60                	cmp    $0x60,%al
c0108f49:	7e 1b                	jle    c0108f66 <strtol+0xf7>
c0108f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f4e:	0f b6 00             	movzbl (%eax),%eax
c0108f51:	3c 7a                	cmp    $0x7a,%al
c0108f53:	7f 11                	jg     c0108f66 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0108f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f58:	0f b6 00             	movzbl (%eax),%eax
c0108f5b:	0f be c0             	movsbl %al,%eax
c0108f5e:	83 e8 57             	sub    $0x57,%eax
c0108f61:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f64:	eb 23                	jmp    c0108f89 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108f66:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f69:	0f b6 00             	movzbl (%eax),%eax
c0108f6c:	3c 40                	cmp    $0x40,%al
c0108f6e:	7e 3d                	jle    c0108fad <strtol+0x13e>
c0108f70:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f73:	0f b6 00             	movzbl (%eax),%eax
c0108f76:	3c 5a                	cmp    $0x5a,%al
c0108f78:	7f 33                	jg     c0108fad <strtol+0x13e>
            dig = *s - 'A' + 10;
c0108f7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f7d:	0f b6 00             	movzbl (%eax),%eax
c0108f80:	0f be c0             	movsbl %al,%eax
c0108f83:	83 e8 37             	sub    $0x37,%eax
c0108f86:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f8c:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108f8f:	7c 02                	jl     c0108f93 <strtol+0x124>
            break;
c0108f91:	eb 1a                	jmp    c0108fad <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0108f93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108f97:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108f9a:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108f9e:	89 c2                	mov    %eax,%edx
c0108fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fa3:	01 d0                	add    %edx,%eax
c0108fa5:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0108fa8:	e9 6f ff ff ff       	jmp    c0108f1c <strtol+0xad>

    if (endptr) {
c0108fad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108fb1:	74 08                	je     c0108fbb <strtol+0x14c>
        *endptr = (char *) s;
c0108fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fb6:	8b 55 08             	mov    0x8(%ebp),%edx
c0108fb9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108fbb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108fbf:	74 07                	je     c0108fc8 <strtol+0x159>
c0108fc1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108fc4:	f7 d8                	neg    %eax
c0108fc6:	eb 03                	jmp    c0108fcb <strtol+0x15c>
c0108fc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108fcb:	c9                   	leave  
c0108fcc:	c3                   	ret    

c0108fcd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108fcd:	55                   	push   %ebp
c0108fce:	89 e5                	mov    %esp,%ebp
c0108fd0:	57                   	push   %edi
c0108fd1:	83 ec 24             	sub    $0x24,%esp
c0108fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fd7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108fda:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0108fde:	8b 55 08             	mov    0x8(%ebp),%edx
c0108fe1:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108fe4:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108fe7:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fea:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108fed:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108ff0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108ff4:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108ff7:	89 d7                	mov    %edx,%edi
c0108ff9:	f3 aa                	rep stos %al,%es:(%edi)
c0108ffb:	89 fa                	mov    %edi,%edx
c0108ffd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109000:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0109003:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109006:	83 c4 24             	add    $0x24,%esp
c0109009:	5f                   	pop    %edi
c010900a:	5d                   	pop    %ebp
c010900b:	c3                   	ret    

c010900c <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010900c:	55                   	push   %ebp
c010900d:	89 e5                	mov    %esp,%ebp
c010900f:	57                   	push   %edi
c0109010:	56                   	push   %esi
c0109011:	53                   	push   %ebx
c0109012:	83 ec 30             	sub    $0x30,%esp
c0109015:	8b 45 08             	mov    0x8(%ebp),%eax
c0109018:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010901b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010901e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109021:	8b 45 10             	mov    0x10(%ebp),%eax
c0109024:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0109027:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010902a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010902d:	73 42                	jae    c0109071 <memmove+0x65>
c010902f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109032:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109035:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109038:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010903b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010903e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109041:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109044:	c1 e8 02             	shr    $0x2,%eax
c0109047:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0109049:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010904c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010904f:	89 d7                	mov    %edx,%edi
c0109051:	89 c6                	mov    %eax,%esi
c0109053:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109055:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109058:	83 e1 03             	and    $0x3,%ecx
c010905b:	74 02                	je     c010905f <memmove+0x53>
c010905d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010905f:	89 f0                	mov    %esi,%eax
c0109061:	89 fa                	mov    %edi,%edx
c0109063:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0109066:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109069:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010906c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010906f:	eb 36                	jmp    c01090a7 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0109071:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109074:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109077:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010907a:	01 c2                	add    %eax,%edx
c010907c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010907f:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0109082:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109085:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0109088:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010908b:	89 c1                	mov    %eax,%ecx
c010908d:	89 d8                	mov    %ebx,%eax
c010908f:	89 d6                	mov    %edx,%esi
c0109091:	89 c7                	mov    %eax,%edi
c0109093:	fd                   	std    
c0109094:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109096:	fc                   	cld    
c0109097:	89 f8                	mov    %edi,%eax
c0109099:	89 f2                	mov    %esi,%edx
c010909b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010909e:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01090a1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c01090a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01090a7:	83 c4 30             	add    $0x30,%esp
c01090aa:	5b                   	pop    %ebx
c01090ab:	5e                   	pop    %esi
c01090ac:	5f                   	pop    %edi
c01090ad:	5d                   	pop    %ebp
c01090ae:	c3                   	ret    

c01090af <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01090af:	55                   	push   %ebp
c01090b0:	89 e5                	mov    %esp,%ebp
c01090b2:	57                   	push   %edi
c01090b3:	56                   	push   %esi
c01090b4:	83 ec 20             	sub    $0x20,%esp
c01090b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01090ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01090c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01090c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01090c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090cc:	c1 e8 02             	shr    $0x2,%eax
c01090cf:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01090d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01090d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090d7:	89 d7                	mov    %edx,%edi
c01090d9:	89 c6                	mov    %eax,%esi
c01090db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01090dd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01090e0:	83 e1 03             	and    $0x3,%ecx
c01090e3:	74 02                	je     c01090e7 <memcpy+0x38>
c01090e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01090e7:	89 f0                	mov    %esi,%eax
c01090e9:	89 fa                	mov    %edi,%edx
c01090eb:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01090ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01090f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01090f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01090f7:	83 c4 20             	add    $0x20,%esp
c01090fa:	5e                   	pop    %esi
c01090fb:	5f                   	pop    %edi
c01090fc:	5d                   	pop    %ebp
c01090fd:	c3                   	ret    

c01090fe <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01090fe:	55                   	push   %ebp
c01090ff:	89 e5                	mov    %esp,%ebp
c0109101:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0109104:	8b 45 08             	mov    0x8(%ebp),%eax
c0109107:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010910a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010910d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0109110:	eb 30                	jmp    c0109142 <memcmp+0x44>
        if (*s1 != *s2) {
c0109112:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109115:	0f b6 10             	movzbl (%eax),%edx
c0109118:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010911b:	0f b6 00             	movzbl (%eax),%eax
c010911e:	38 c2                	cmp    %al,%dl
c0109120:	74 18                	je     c010913a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109122:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109125:	0f b6 00             	movzbl (%eax),%eax
c0109128:	0f b6 d0             	movzbl %al,%edx
c010912b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010912e:	0f b6 00             	movzbl (%eax),%eax
c0109131:	0f b6 c0             	movzbl %al,%eax
c0109134:	29 c2                	sub    %eax,%edx
c0109136:	89 d0                	mov    %edx,%eax
c0109138:	eb 1a                	jmp    c0109154 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010913a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010913e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0109142:	8b 45 10             	mov    0x10(%ebp),%eax
c0109145:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109148:	89 55 10             	mov    %edx,0x10(%ebp)
c010914b:	85 c0                	test   %eax,%eax
c010914d:	75 c3                	jne    c0109112 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010914f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109154:	c9                   	leave  
c0109155:	c3                   	ret    
