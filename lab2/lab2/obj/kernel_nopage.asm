
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba a8 cf 11 00       	mov    $0x11cfa8,%edx
  100041:	b8 36 9a 11 00       	mov    $0x119a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  10005d:	e8 f1 69 00 00       	call   106a53 <memset>

    cons_init();                // init the console
  100062:	e8 97 15 00 00       	call   1015fe <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 e0 6b 10 00 	movl   $0x106be0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 fc 6b 10 00 	movl   $0x106bfc,(%esp)
  10007c:	e8 d2 02 00 00       	call   100353 <cprintf>

    print_kerninfo();
  100081:	e8 01 08 00 00       	call   100887 <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 2e 4f 00 00       	call   104fbe <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 d2 16 00 00       	call   101767 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 4a 18 00 00       	call   1018e4 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 15 0d 00 00       	call   100db4 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 31 16 00 00       	call   1016d5 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 0d 0c 00 00       	call   100cd5 <mon_backtrace>
}
  1000c8:	c9                   	leave  
  1000c9:	c3                   	ret    

001000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ca:	55                   	push   %ebp
  1000cb:	89 e5                	mov    %esp,%ebp
  1000cd:	53                   	push   %ebx
  1000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000d7:	8d 55 08             	lea    0x8(%ebp),%edx
  1000da:	8b 45 08             	mov    0x8(%ebp),%eax
  1000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000e9:	89 04 24             	mov    %eax,(%esp)
  1000ec:	e8 b5 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f1:	83 c4 14             	add    $0x14,%esp
  1000f4:	5b                   	pop    %ebx
  1000f5:	5d                   	pop    %ebp
  1000f6:	c3                   	ret    

001000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f7:	55                   	push   %ebp
  1000f8:	89 e5                	mov    %esp,%ebp
  1000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100100:	89 44 24 04          	mov    %eax,0x4(%esp)
  100104:	8b 45 08             	mov    0x8(%ebp),%eax
  100107:	89 04 24             	mov    %eax,(%esp)
  10010a:	e8 bb ff ff ff       	call   1000ca <grade_backtrace1>
}
  10010f:	c9                   	leave  
  100110:	c3                   	ret    

00100111 <grade_backtrace>:

void
grade_backtrace(void) {
  100111:	55                   	push   %ebp
  100112:	89 e5                	mov    %esp,%ebp
  100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100117:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100123:	ff 
  100124:	89 44 24 04          	mov    %eax,0x4(%esp)
  100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10012f:	e8 c3 ff ff ff       	call   1000f7 <grade_backtrace0>
}
  100134:	c9                   	leave  
  100135:	c3                   	ret    

00100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100136:	55                   	push   %ebp
  100137:	89 e5                	mov    %esp,%ebp
  100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 01 6c 10 00 	movl   $0x106c01,(%esp)
  100168:	e8 e6 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 0f 6c 10 00 	movl   $0x106c0f,(%esp)
  100188:	e8 c6 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 1d 6c 10 00 	movl   $0x106c1d,(%esp)
  1001a8:	e8 a6 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 2b 6c 10 00 	movl   $0x106c2b,(%esp)
  1001c8:	e8 86 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 39 6c 10 00 	movl   $0x106c39,(%esp)
  1001e8:	e8 66 01 00 00       	call   100353 <cprintf>
    round ++;
  1001ed:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 c0 11 00       	mov    %eax,0x11c000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  1001ff:	83 ec 08             	sub    $0x8,%esp
  100202:	cd 78                	int    $0x78
  100204:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  100206:	5d                   	pop    %ebp
  100207:	c3                   	ret    

00100208 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100208:	55                   	push   %ebp
  100209:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  10020b:	cd 79                	int    $0x79
  10020d:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  10020f:	5d                   	pop    %ebp
  100210:	c3                   	ret    

00100211 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100211:	55                   	push   %ebp
  100212:	89 e5                	mov    %esp,%ebp
  100214:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100217:	e8 1a ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10021c:	c7 04 24 48 6c 10 00 	movl   $0x106c48,(%esp)
  100223:	e8 2b 01 00 00       	call   100353 <cprintf>
    lab1_switch_to_user();
  100228:	e8 cf ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  10022d:	e8 04 ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100232:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  100239:	e8 15 01 00 00       	call   100353 <cprintf>
    lab1_switch_to_kernel();
  10023e:	e8 c5 ff ff ff       	call   100208 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100243:	e8 ee fe ff ff       	call   100136 <lab1_print_cur_status>
}
  100248:	c9                   	leave  
  100249:	c3                   	ret    

0010024a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10024a:	55                   	push   %ebp
  10024b:	89 e5                	mov    %esp,%ebp
  10024d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100250:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100254:	74 13                	je     100269 <readline+0x1f>
        cprintf("%s", prompt);
  100256:	8b 45 08             	mov    0x8(%ebp),%eax
  100259:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025d:	c7 04 24 87 6c 10 00 	movl   $0x106c87,(%esp)
  100264:	e8 ea 00 00 00       	call   100353 <cprintf>
    }
    int i = 0, c;
  100269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100270:	e8 66 01 00 00       	call   1003db <getchar>
  100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100278:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10027c:	79 07                	jns    100285 <readline+0x3b>
            return NULL;
  10027e:	b8 00 00 00 00       	mov    $0x0,%eax
  100283:	eb 79                	jmp    1002fe <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100285:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100289:	7e 28                	jle    1002b3 <readline+0x69>
  10028b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100292:	7f 1f                	jg     1002b3 <readline+0x69>
            cputchar(c);
  100294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100297:	89 04 24             	mov    %eax,(%esp)
  10029a:	e8 da 00 00 00       	call   100379 <cputchar>
            buf[i ++] = c;
  10029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002a2:	8d 50 01             	lea    0x1(%eax),%edx
  1002a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002ab:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
  1002b1:	eb 46                	jmp    1002f9 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b7:	75 17                	jne    1002d0 <readline+0x86>
  1002b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002bd:	7e 11                	jle    1002d0 <readline+0x86>
            cputchar(c);
  1002bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002c2:	89 04 24             	mov    %eax,(%esp)
  1002c5:	e8 af 00 00 00       	call   100379 <cputchar>
            i --;
  1002ca:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002ce:	eb 29                	jmp    1002f9 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d4:	74 06                	je     1002dc <readline+0x92>
  1002d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002da:	75 1d                	jne    1002f9 <readline+0xaf>
            cputchar(c);
  1002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002df:	89 04 24             	mov    %eax,(%esp)
  1002e2:	e8 92 00 00 00       	call   100379 <cputchar>
            buf[i] = '\0';
  1002e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002ea:	05 20 c0 11 00       	add    $0x11c020,%eax
  1002ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002f2:	b8 20 c0 11 00       	mov    $0x11c020,%eax
  1002f7:	eb 05                	jmp    1002fe <readline+0xb4>
        }
    }
  1002f9:	e9 72 ff ff ff       	jmp    100270 <readline+0x26>
}
  1002fe:	c9                   	leave  
  1002ff:	c3                   	ret    

00100300 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100300:	55                   	push   %ebp
  100301:	89 e5                	mov    %esp,%ebp
  100303:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100306:	8b 45 08             	mov    0x8(%ebp),%eax
  100309:	89 04 24             	mov    %eax,(%esp)
  10030c:	e8 19 13 00 00       	call   10162a <cons_putc>
    (*cnt) ++;
  100311:	8b 45 0c             	mov    0xc(%ebp),%eax
  100314:	8b 00                	mov    (%eax),%eax
  100316:	8d 50 01             	lea    0x1(%eax),%edx
  100319:	8b 45 0c             	mov    0xc(%ebp),%eax
  10031c:	89 10                	mov    %edx,(%eax)
}
  10031e:	c9                   	leave  
  10031f:	c3                   	ret    

00100320 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100320:	55                   	push   %ebp
  100321:	89 e5                	mov    %esp,%ebp
  100323:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100330:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100334:	8b 45 08             	mov    0x8(%ebp),%eax
  100337:	89 44 24 08          	mov    %eax,0x8(%esp)
  10033b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100342:	c7 04 24 00 03 10 00 	movl   $0x100300,(%esp)
  100349:	e8 1e 5f 00 00       	call   10626c <vprintfmt>
    return cnt;
  10034e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100351:	c9                   	leave  
  100352:	c3                   	ret    

00100353 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100353:	55                   	push   %ebp
  100354:	89 e5                	mov    %esp,%ebp
  100356:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100359:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10035f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100362:	89 44 24 04          	mov    %eax,0x4(%esp)
  100366:	8b 45 08             	mov    0x8(%ebp),%eax
  100369:	89 04 24             	mov    %eax,(%esp)
  10036c:	e8 af ff ff ff       	call   100320 <vcprintf>
  100371:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100377:	c9                   	leave  
  100378:	c3                   	ret    

00100379 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100379:	55                   	push   %ebp
  10037a:	89 e5                	mov    %esp,%ebp
  10037c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10037f:	8b 45 08             	mov    0x8(%ebp),%eax
  100382:	89 04 24             	mov    %eax,(%esp)
  100385:	e8 a0 12 00 00       	call   10162a <cons_putc>
}
  10038a:	c9                   	leave  
  10038b:	c3                   	ret    

0010038c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10038c:	55                   	push   %ebp
  10038d:	89 e5                	mov    %esp,%ebp
  10038f:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100399:	eb 13                	jmp    1003ae <cputs+0x22>
        cputch(c, &cnt);
  10039b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10039f:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003a6:	89 04 24             	mov    %eax,(%esp)
  1003a9:	e8 52 ff ff ff       	call   100300 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b1:	8d 50 01             	lea    0x1(%eax),%edx
  1003b4:	89 55 08             	mov    %edx,0x8(%ebp)
  1003b7:	0f b6 00             	movzbl (%eax),%eax
  1003ba:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003bd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c1:	75 d8                	jne    10039b <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d1:	e8 2a ff ff ff       	call   100300 <cputch>
    return cnt;
  1003d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003d9:	c9                   	leave  
  1003da:	c3                   	ret    

001003db <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003db:	55                   	push   %ebp
  1003dc:	89 e5                	mov    %esp,%ebp
  1003de:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003e1:	e8 80 12 00 00       	call   101666 <cons_getc>
  1003e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003ed:	74 f2                	je     1003e1 <getchar+0x6>
        /* do nothing */;
    return c;
  1003ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003f2:	c9                   	leave  
  1003f3:	c3                   	ret    

001003f4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003f4:	55                   	push   %ebp
  1003f5:	89 e5                	mov    %esp,%ebp
  1003f7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003fd:	8b 00                	mov    (%eax),%eax
  1003ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100402:	8b 45 10             	mov    0x10(%ebp),%eax
  100405:	8b 00                	mov    (%eax),%eax
  100407:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10040a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100411:	e9 d2 00 00 00       	jmp    1004e8 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  100416:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100419:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10041c:	01 d0                	add    %edx,%eax
  10041e:	89 c2                	mov    %eax,%edx
  100420:	c1 ea 1f             	shr    $0x1f,%edx
  100423:	01 d0                	add    %edx,%eax
  100425:	d1 f8                	sar    %eax
  100427:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10042a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10042d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100430:	eb 04                	jmp    100436 <stab_binsearch+0x42>
            m --;
  100432:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100439:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10043c:	7c 1f                	jl     10045d <stab_binsearch+0x69>
  10043e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100441:	89 d0                	mov    %edx,%eax
  100443:	01 c0                	add    %eax,%eax
  100445:	01 d0                	add    %edx,%eax
  100447:	c1 e0 02             	shl    $0x2,%eax
  10044a:	89 c2                	mov    %eax,%edx
  10044c:	8b 45 08             	mov    0x8(%ebp),%eax
  10044f:	01 d0                	add    %edx,%eax
  100451:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100455:	0f b6 c0             	movzbl %al,%eax
  100458:	3b 45 14             	cmp    0x14(%ebp),%eax
  10045b:	75 d5                	jne    100432 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  10045d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100460:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100463:	7d 0b                	jge    100470 <stab_binsearch+0x7c>
            l = true_m + 1;
  100465:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100468:	83 c0 01             	add    $0x1,%eax
  10046b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10046e:	eb 78                	jmp    1004e8 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100470:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100477:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10047a:	89 d0                	mov    %edx,%eax
  10047c:	01 c0                	add    %eax,%eax
  10047e:	01 d0                	add    %edx,%eax
  100480:	c1 e0 02             	shl    $0x2,%eax
  100483:	89 c2                	mov    %eax,%edx
  100485:	8b 45 08             	mov    0x8(%ebp),%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	8b 40 08             	mov    0x8(%eax),%eax
  10048d:	3b 45 18             	cmp    0x18(%ebp),%eax
  100490:	73 13                	jae    1004a5 <stab_binsearch+0xb1>
            *region_left = m;
  100492:	8b 45 0c             	mov    0xc(%ebp),%eax
  100495:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100498:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10049a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10049d:	83 c0 01             	add    $0x1,%eax
  1004a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a3:	eb 43                	jmp    1004e8 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  1004a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004a8:	89 d0                	mov    %edx,%eax
  1004aa:	01 c0                	add    %eax,%eax
  1004ac:	01 d0                	add    %edx,%eax
  1004ae:	c1 e0 02             	shl    $0x2,%eax
  1004b1:	89 c2                	mov    %eax,%edx
  1004b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1004b6:	01 d0                	add    %edx,%eax
  1004b8:	8b 40 08             	mov    0x8(%eax),%eax
  1004bb:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004be:	76 16                	jbe    1004d6 <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c3:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c9:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004ce:	83 e8 01             	sub    $0x1,%eax
  1004d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004d4:	eb 12                	jmp    1004e8 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004dc:	89 10                	mov    %edx,(%eax)
            l = m;
  1004de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004e4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004ee:	0f 8e 22 ff ff ff    	jle    100416 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004f8:	75 0f                	jne    100509 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004fd:	8b 00                	mov    (%eax),%eax
  1004ff:	8d 50 ff             	lea    -0x1(%eax),%edx
  100502:	8b 45 10             	mov    0x10(%ebp),%eax
  100505:	89 10                	mov    %edx,(%eax)
  100507:	eb 3f                	jmp    100548 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  100509:	8b 45 10             	mov    0x10(%ebp),%eax
  10050c:	8b 00                	mov    (%eax),%eax
  10050e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100511:	eb 04                	jmp    100517 <stab_binsearch+0x123>
  100513:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  100517:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051a:	8b 00                	mov    (%eax),%eax
  10051c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10051f:	7d 1f                	jge    100540 <stab_binsearch+0x14c>
  100521:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100524:	89 d0                	mov    %edx,%eax
  100526:	01 c0                	add    %eax,%eax
  100528:	01 d0                	add    %edx,%eax
  10052a:	c1 e0 02             	shl    $0x2,%eax
  10052d:	89 c2                	mov    %eax,%edx
  10052f:	8b 45 08             	mov    0x8(%ebp),%eax
  100532:	01 d0                	add    %edx,%eax
  100534:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100538:	0f b6 c0             	movzbl %al,%eax
  10053b:	3b 45 14             	cmp    0x14(%ebp),%eax
  10053e:	75 d3                	jne    100513 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100540:	8b 45 0c             	mov    0xc(%ebp),%eax
  100543:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100546:	89 10                	mov    %edx,(%eax)
    }
}
  100548:	c9                   	leave  
  100549:	c3                   	ret    

0010054a <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10054a:	55                   	push   %ebp
  10054b:	89 e5                	mov    %esp,%ebp
  10054d:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100550:	8b 45 0c             	mov    0xc(%ebp),%eax
  100553:	c7 00 8c 6c 10 00    	movl   $0x106c8c,(%eax)
    info->eip_line = 0;
  100559:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100563:	8b 45 0c             	mov    0xc(%ebp),%eax
  100566:	c7 40 08 8c 6c 10 00 	movl   $0x106c8c,0x8(%eax)
    info->eip_fn_namelen = 9;
  10056d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100570:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100577:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057a:	8b 55 08             	mov    0x8(%ebp),%edx
  10057d:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100580:	8b 45 0c             	mov    0xc(%ebp),%eax
  100583:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10058a:	c7 45 f4 a4 81 10 00 	movl   $0x1081a4,-0xc(%ebp)
    stab_end = __STAB_END__;
  100591:	c7 45 f0 f8 3b 11 00 	movl   $0x113bf8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100598:	c7 45 ec f9 3b 11 00 	movl   $0x113bf9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10059f:	c7 45 e8 bb 67 11 00 	movl   $0x1167bb,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005a9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005ac:	76 0d                	jbe    1005bb <debuginfo_eip+0x71>
  1005ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b1:	83 e8 01             	sub    $0x1,%eax
  1005b4:	0f b6 00             	movzbl (%eax),%eax
  1005b7:	84 c0                	test   %al,%al
  1005b9:	74 0a                	je     1005c5 <debuginfo_eip+0x7b>
        return -1;
  1005bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c0:	e9 c0 02 00 00       	jmp    100885 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005d2:	29 c2                	sub    %eax,%edx
  1005d4:	89 d0                	mov    %edx,%eax
  1005d6:	c1 f8 02             	sar    $0x2,%eax
  1005d9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005df:	83 e8 01             	sub    $0x1,%eax
  1005e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005ec:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f3:	00 
  1005f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100602:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100605:	89 04 24             	mov    %eax,(%esp)
  100608:	e8 e7 fd ff ff       	call   1003f4 <stab_binsearch>
    if (lfile == 0)
  10060d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100610:	85 c0                	test   %eax,%eax
  100612:	75 0a                	jne    10061e <debuginfo_eip+0xd4>
        return -1;
  100614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100619:	e9 67 02 00 00       	jmp    100885 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10061e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100621:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100624:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100627:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10062a:	8b 45 08             	mov    0x8(%ebp),%eax
  10062d:	89 44 24 10          	mov    %eax,0x10(%esp)
  100631:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100638:	00 
  100639:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10063c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100640:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100643:	89 44 24 04          	mov    %eax,0x4(%esp)
  100647:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10064a:	89 04 24             	mov    %eax,(%esp)
  10064d:	e8 a2 fd ff ff       	call   1003f4 <stab_binsearch>

    if (lfun <= rfun) {
  100652:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100655:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100658:	39 c2                	cmp    %eax,%edx
  10065a:	7f 7c                	jg     1006d8 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10065c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065f:	89 c2                	mov    %eax,%edx
  100661:	89 d0                	mov    %edx,%eax
  100663:	01 c0                	add    %eax,%eax
  100665:	01 d0                	add    %edx,%eax
  100667:	c1 e0 02             	shl    $0x2,%eax
  10066a:	89 c2                	mov    %eax,%edx
  10066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066f:	01 d0                	add    %edx,%eax
  100671:	8b 10                	mov    (%eax),%edx
  100673:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100676:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100679:	29 c1                	sub    %eax,%ecx
  10067b:	89 c8                	mov    %ecx,%eax
  10067d:	39 c2                	cmp    %eax,%edx
  10067f:	73 22                	jae    1006a3 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100681:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100684:	89 c2                	mov    %eax,%edx
  100686:	89 d0                	mov    %edx,%eax
  100688:	01 c0                	add    %eax,%eax
  10068a:	01 d0                	add    %edx,%eax
  10068c:	c1 e0 02             	shl    $0x2,%eax
  10068f:	89 c2                	mov    %eax,%edx
  100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100694:	01 d0                	add    %edx,%eax
  100696:	8b 10                	mov    (%eax),%edx
  100698:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10069b:	01 c2                	add    %eax,%edx
  10069d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006a0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  1006a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a6:	89 c2                	mov    %eax,%edx
  1006a8:	89 d0                	mov    %edx,%eax
  1006aa:	01 c0                	add    %eax,%eax
  1006ac:	01 d0                	add    %edx,%eax
  1006ae:	c1 e0 02             	shl    $0x2,%eax
  1006b1:	89 c2                	mov    %eax,%edx
  1006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b6:	01 d0                	add    %edx,%eax
  1006b8:	8b 50 08             	mov    0x8(%eax),%edx
  1006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006be:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006c4:	8b 40 10             	mov    0x10(%eax),%eax
  1006c7:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006d6:	eb 15                	jmp    1006ed <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006db:	8b 55 08             	mov    0x8(%ebp),%edx
  1006de:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006f0:	8b 40 08             	mov    0x8(%eax),%eax
  1006f3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006fa:	00 
  1006fb:	89 04 24             	mov    %eax,(%esp)
  1006fe:	e8 c4 61 00 00       	call   1068c7 <strfind>
  100703:	89 c2                	mov    %eax,%edx
  100705:	8b 45 0c             	mov    0xc(%ebp),%eax
  100708:	8b 40 08             	mov    0x8(%eax),%eax
  10070b:	29 c2                	sub    %eax,%edx
  10070d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100710:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100713:	8b 45 08             	mov    0x8(%ebp),%eax
  100716:	89 44 24 10          	mov    %eax,0x10(%esp)
  10071a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100721:	00 
  100722:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100725:	89 44 24 08          	mov    %eax,0x8(%esp)
  100729:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  10072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100733:	89 04 24             	mov    %eax,(%esp)
  100736:	e8 b9 fc ff ff       	call   1003f4 <stab_binsearch>
    if (lline <= rline) {
  10073b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10073e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100741:	39 c2                	cmp    %eax,%edx
  100743:	7f 24                	jg     100769 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100745:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	89 d0                	mov    %edx,%eax
  10074c:	01 c0                	add    %eax,%eax
  10074e:	01 d0                	add    %edx,%eax
  100750:	c1 e0 02             	shl    $0x2,%eax
  100753:	89 c2                	mov    %eax,%edx
  100755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100758:	01 d0                	add    %edx,%eax
  10075a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10075e:	0f b7 d0             	movzwl %ax,%edx
  100761:	8b 45 0c             	mov    0xc(%ebp),%eax
  100764:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100767:	eb 13                	jmp    10077c <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10076e:	e9 12 01 00 00       	jmp    100885 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100773:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100776:	83 e8 01             	sub    $0x1,%eax
  100779:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10077c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10077f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100782:	39 c2                	cmp    %eax,%edx
  100784:	7c 56                	jl     1007dc <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100786:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100789:	89 c2                	mov    %eax,%edx
  10078b:	89 d0                	mov    %edx,%eax
  10078d:	01 c0                	add    %eax,%eax
  10078f:	01 d0                	add    %edx,%eax
  100791:	c1 e0 02             	shl    $0x2,%eax
  100794:	89 c2                	mov    %eax,%edx
  100796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100799:	01 d0                	add    %edx,%eax
  10079b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10079f:	3c 84                	cmp    $0x84,%al
  1007a1:	74 39                	je     1007dc <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1007a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007a6:	89 c2                	mov    %eax,%edx
  1007a8:	89 d0                	mov    %edx,%eax
  1007aa:	01 c0                	add    %eax,%eax
  1007ac:	01 d0                	add    %edx,%eax
  1007ae:	c1 e0 02             	shl    $0x2,%eax
  1007b1:	89 c2                	mov    %eax,%edx
  1007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007b6:	01 d0                	add    %edx,%eax
  1007b8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007bc:	3c 64                	cmp    $0x64,%al
  1007be:	75 b3                	jne    100773 <debuginfo_eip+0x229>
  1007c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	89 d0                	mov    %edx,%eax
  1007c7:	01 c0                	add    %eax,%eax
  1007c9:	01 d0                	add    %edx,%eax
  1007cb:	c1 e0 02             	shl    $0x2,%eax
  1007ce:	89 c2                	mov    %eax,%edx
  1007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007d3:	01 d0                	add    %edx,%eax
  1007d5:	8b 40 08             	mov    0x8(%eax),%eax
  1007d8:	85 c0                	test   %eax,%eax
  1007da:	74 97                	je     100773 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007e2:	39 c2                	cmp    %eax,%edx
  1007e4:	7c 46                	jl     10082c <debuginfo_eip+0x2e2>
  1007e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e9:	89 c2                	mov    %eax,%edx
  1007eb:	89 d0                	mov    %edx,%eax
  1007ed:	01 c0                	add    %eax,%eax
  1007ef:	01 d0                	add    %edx,%eax
  1007f1:	c1 e0 02             	shl    $0x2,%eax
  1007f4:	89 c2                	mov    %eax,%edx
  1007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f9:	01 d0                	add    %edx,%eax
  1007fb:	8b 10                	mov    (%eax),%edx
  1007fd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100800:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100803:	29 c1                	sub    %eax,%ecx
  100805:	89 c8                	mov    %ecx,%eax
  100807:	39 c2                	cmp    %eax,%edx
  100809:	73 21                	jae    10082c <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  10080b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10080e:	89 c2                	mov    %eax,%edx
  100810:	89 d0                	mov    %edx,%eax
  100812:	01 c0                	add    %eax,%eax
  100814:	01 d0                	add    %edx,%eax
  100816:	c1 e0 02             	shl    $0x2,%eax
  100819:	89 c2                	mov    %eax,%edx
  10081b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10081e:	01 d0                	add    %edx,%eax
  100820:	8b 10                	mov    (%eax),%edx
  100822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100825:	01 c2                	add    %eax,%edx
  100827:	8b 45 0c             	mov    0xc(%ebp),%eax
  10082a:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  10082c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10082f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100832:	39 c2                	cmp    %eax,%edx
  100834:	7d 4a                	jge    100880 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  100836:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100839:	83 c0 01             	add    $0x1,%eax
  10083c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10083f:	eb 18                	jmp    100859 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100841:	8b 45 0c             	mov    0xc(%ebp),%eax
  100844:	8b 40 14             	mov    0x14(%eax),%eax
  100847:	8d 50 01             	lea    0x1(%eax),%edx
  10084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10084d:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100850:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100853:	83 c0 01             	add    $0x1,%eax
  100856:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100859:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10085c:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  10085f:	39 c2                	cmp    %eax,%edx
  100861:	7d 1d                	jge    100880 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	89 d0                	mov    %edx,%eax
  10086a:	01 c0                	add    %eax,%eax
  10086c:	01 d0                	add    %edx,%eax
  10086e:	c1 e0 02             	shl    $0x2,%eax
  100871:	89 c2                	mov    %eax,%edx
  100873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100876:	01 d0                	add    %edx,%eax
  100878:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10087c:	3c a0                	cmp    $0xa0,%al
  10087e:	74 c1                	je     100841 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100880:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100885:	c9                   	leave  
  100886:	c3                   	ret    

00100887 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100887:	55                   	push   %ebp
  100888:	89 e5                	mov    %esp,%ebp
  10088a:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10088d:	c7 04 24 96 6c 10 00 	movl   $0x106c96,(%esp)
  100894:	e8 ba fa ff ff       	call   100353 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100899:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  1008a0:	00 
  1008a1:	c7 04 24 af 6c 10 00 	movl   $0x106caf,(%esp)
  1008a8:	e8 a6 fa ff ff       	call   100353 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008ad:	c7 44 24 04 dc 6b 10 	movl   $0x106bdc,0x4(%esp)
  1008b4:	00 
  1008b5:	c7 04 24 c7 6c 10 00 	movl   $0x106cc7,(%esp)
  1008bc:	e8 92 fa ff ff       	call   100353 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008c1:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  1008c8:	00 
  1008c9:	c7 04 24 df 6c 10 00 	movl   $0x106cdf,(%esp)
  1008d0:	e8 7e fa ff ff       	call   100353 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008d5:	c7 44 24 04 a8 cf 11 	movl   $0x11cfa8,0x4(%esp)
  1008dc:	00 
  1008dd:	c7 04 24 f7 6c 10 00 	movl   $0x106cf7,(%esp)
  1008e4:	e8 6a fa ff ff       	call   100353 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008e9:	b8 a8 cf 11 00       	mov    $0x11cfa8,%eax
  1008ee:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f4:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008f9:	29 c2                	sub    %eax,%edx
  1008fb:	89 d0                	mov    %edx,%eax
  1008fd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100903:	85 c0                	test   %eax,%eax
  100905:	0f 48 c2             	cmovs  %edx,%eax
  100908:	c1 f8 0a             	sar    $0xa,%eax
  10090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10090f:	c7 04 24 10 6d 10 00 	movl   $0x106d10,(%esp)
  100916:	e8 38 fa ff ff       	call   100353 <cprintf>
}
  10091b:	c9                   	leave  
  10091c:	c3                   	ret    

0010091d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10091d:	55                   	push   %ebp
  10091e:	89 e5                	mov    %esp,%ebp
  100920:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100926:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100929:	89 44 24 04          	mov    %eax,0x4(%esp)
  10092d:	8b 45 08             	mov    0x8(%ebp),%eax
  100930:	89 04 24             	mov    %eax,(%esp)
  100933:	e8 12 fc ff ff       	call   10054a <debuginfo_eip>
  100938:	85 c0                	test   %eax,%eax
  10093a:	74 15                	je     100951 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10093c:	8b 45 08             	mov    0x8(%ebp),%eax
  10093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100943:	c7 04 24 3a 6d 10 00 	movl   $0x106d3a,(%esp)
  10094a:	e8 04 fa ff ff       	call   100353 <cprintf>
  10094f:	eb 6d                	jmp    1009be <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100958:	eb 1c                	jmp    100976 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10095a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10095d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100960:	01 d0                	add    %edx,%eax
  100962:	0f b6 00             	movzbl (%eax),%eax
  100965:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10096b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10096e:	01 ca                	add    %ecx,%edx
  100970:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100972:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100976:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100979:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10097c:	7f dc                	jg     10095a <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  10097e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100987:	01 d0                	add    %edx,%eax
  100989:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  10098c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10098f:	8b 55 08             	mov    0x8(%ebp),%edx
  100992:	89 d1                	mov    %edx,%ecx
  100994:	29 c1                	sub    %eax,%ecx
  100996:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100999:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10099c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1009a0:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1009aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b2:	c7 04 24 56 6d 10 00 	movl   $0x106d56,(%esp)
  1009b9:	e8 95 f9 ff ff       	call   100353 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009be:	c9                   	leave  
  1009bf:	c3                   	ret    

001009c0 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009c0:	55                   	push   %ebp
  1009c1:	89 e5                	mov    %esp,%ebp
  1009c3:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009c6:	8b 45 04             	mov    0x4(%ebp),%eax
  1009c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009cf:	c9                   	leave  
  1009d0:	c3                   	ret    

001009d1 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009d1:	55                   	push   %ebp
  1009d2:	89 e5                	mov    %esp,%ebp
  1009d4:	53                   	push   %ebx
  1009d5:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009d8:	89 e8                	mov    %ebp,%eax
  1009da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
  1009e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
  1009e3:	e8 d8 ff ff ff       	call   1009c0 <read_eip>
  1009e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  1009eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009f2:	e9 8d 00 00 00       	jmp    100a84 <print_stackframe+0xb3>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
  1009f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a05:	c7 04 24 68 6d 10 00 	movl   $0x106d68,(%esp)
  100a0c:	e8 42 f9 ff ff       	call   100353 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
  100a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a14:	83 c0 08             	add    $0x8,%eax
  100a17:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("0x%08x 0x%08x 0x%08x 0x%08x",*args,*(args+1),*(args+2),*(args+3));
  100a1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a1d:	83 c0 0c             	add    $0xc,%eax
  100a20:	8b 18                	mov    (%eax),%ebx
  100a22:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a25:	83 c0 08             	add    $0x8,%eax
  100a28:	8b 08                	mov    (%eax),%ecx
  100a2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2d:	83 c0 04             	add    $0x4,%eax
  100a30:	8b 10                	mov    (%eax),%edx
  100a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a35:	8b 00                	mov    (%eax),%eax
  100a37:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100a3b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a47:	c7 04 24 84 6d 10 00 	movl   $0x106d84,(%esp)
  100a4e:	e8 00 f9 ff ff       	call   100353 <cprintf>
		cprintf("\n");
  100a53:	c7 04 24 a0 6d 10 00 	movl   $0x106da0,(%esp)
  100a5a:	e8 f4 f8 ff ff       	call   100353 <cprintf>
		print_debuginfo(eip-1);
  100a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a62:	83 e8 01             	sub    $0x1,%eax
  100a65:	89 04 24             	mov    %eax,(%esp)
  100a68:	e8 b0 fe ff ff       	call   10091d <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
  100a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a70:	83 c0 04             	add    $0x4,%eax
  100a73:	8b 00                	mov    (%eax),%eax
  100a75:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
  100a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a7b:	8b 00                	mov    (%eax),%eax
  100a7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  100a80:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a88:	74 0a                	je     100a94 <print_stackframe+0xc3>
  100a8a:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a8e:	0f 8e 63 ff ff ff    	jle    1009f7 <print_stackframe+0x26>
		cprintf("\n");
		print_debuginfo(eip-1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
  100a94:	83 c4 44             	add    $0x44,%esp
  100a97:	5b                   	pop    %ebx
  100a98:	5d                   	pop    %ebp
  100a99:	c3                   	ret    

00100a9a <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a9a:	55                   	push   %ebp
  100a9b:	89 e5                	mov    %esp,%ebp
  100a9d:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100aa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aa7:	eb 0c                	jmp    100ab5 <parse+0x1b>
            *buf ++ = '\0';
  100aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  100aac:	8d 50 01             	lea    0x1(%eax),%edx
  100aaf:	89 55 08             	mov    %edx,0x8(%ebp)
  100ab2:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  100ab8:	0f b6 00             	movzbl (%eax),%eax
  100abb:	84 c0                	test   %al,%al
  100abd:	74 1d                	je     100adc <parse+0x42>
  100abf:	8b 45 08             	mov    0x8(%ebp),%eax
  100ac2:	0f b6 00             	movzbl (%eax),%eax
  100ac5:	0f be c0             	movsbl %al,%eax
  100ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  100acc:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  100ad3:	e8 bc 5d 00 00       	call   106894 <strchr>
  100ad8:	85 c0                	test   %eax,%eax
  100ada:	75 cd                	jne    100aa9 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100adc:	8b 45 08             	mov    0x8(%ebp),%eax
  100adf:	0f b6 00             	movzbl (%eax),%eax
  100ae2:	84 c0                	test   %al,%al
  100ae4:	75 02                	jne    100ae8 <parse+0x4e>
            break;
  100ae6:	eb 67                	jmp    100b4f <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ae8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100aec:	75 14                	jne    100b02 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100aee:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100af5:	00 
  100af6:	c7 04 24 29 6e 10 00 	movl   $0x106e29,(%esp)
  100afd:	e8 51 f8 ff ff       	call   100353 <cprintf>
        }
        argv[argc ++] = buf;
  100b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b05:	8d 50 01             	lea    0x1(%eax),%edx
  100b08:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b0b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b15:	01 c2                	add    %eax,%edx
  100b17:	8b 45 08             	mov    0x8(%ebp),%eax
  100b1a:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b1c:	eb 04                	jmp    100b22 <parse+0x88>
            buf ++;
  100b1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b22:	8b 45 08             	mov    0x8(%ebp),%eax
  100b25:	0f b6 00             	movzbl (%eax),%eax
  100b28:	84 c0                	test   %al,%al
  100b2a:	74 1d                	je     100b49 <parse+0xaf>
  100b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b2f:	0f b6 00             	movzbl (%eax),%eax
  100b32:	0f be c0             	movsbl %al,%eax
  100b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b39:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  100b40:	e8 4f 5d 00 00       	call   106894 <strchr>
  100b45:	85 c0                	test   %eax,%eax
  100b47:	74 d5                	je     100b1e <parse+0x84>
            buf ++;
        }
    }
  100b49:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4a:	e9 66 ff ff ff       	jmp    100ab5 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b52:	c9                   	leave  
  100b53:	c3                   	ret    

00100b54 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b54:	55                   	push   %ebp
  100b55:	89 e5                	mov    %esp,%ebp
  100b57:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b5a:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b61:	8b 45 08             	mov    0x8(%ebp),%eax
  100b64:	89 04 24             	mov    %eax,(%esp)
  100b67:	e8 2e ff ff ff       	call   100a9a <parse>
  100b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b73:	75 0a                	jne    100b7f <runcmd+0x2b>
        return 0;
  100b75:	b8 00 00 00 00       	mov    $0x0,%eax
  100b7a:	e9 85 00 00 00       	jmp    100c04 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b86:	eb 5c                	jmp    100be4 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b88:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b8e:	89 d0                	mov    %edx,%eax
  100b90:	01 c0                	add    %eax,%eax
  100b92:	01 d0                	add    %edx,%eax
  100b94:	c1 e0 02             	shl    $0x2,%eax
  100b97:	05 00 90 11 00       	add    $0x119000,%eax
  100b9c:	8b 00                	mov    (%eax),%eax
  100b9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100ba2:	89 04 24             	mov    %eax,(%esp)
  100ba5:	e8 4b 5c 00 00       	call   1067f5 <strcmp>
  100baa:	85 c0                	test   %eax,%eax
  100bac:	75 32                	jne    100be0 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100bae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bb1:	89 d0                	mov    %edx,%eax
  100bb3:	01 c0                	add    %eax,%eax
  100bb5:	01 d0                	add    %edx,%eax
  100bb7:	c1 e0 02             	shl    $0x2,%eax
  100bba:	05 00 90 11 00       	add    $0x119000,%eax
  100bbf:	8b 40 08             	mov    0x8(%eax),%eax
  100bc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100bc5:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bcf:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bd2:	83 c2 04             	add    $0x4,%edx
  100bd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bd9:	89 0c 24             	mov    %ecx,(%esp)
  100bdc:	ff d0                	call   *%eax
  100bde:	eb 24                	jmp    100c04 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100be0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100be7:	83 f8 02             	cmp    $0x2,%eax
  100bea:	76 9c                	jbe    100b88 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bec:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bf3:	c7 04 24 47 6e 10 00 	movl   $0x106e47,(%esp)
  100bfa:	e8 54 f7 ff ff       	call   100353 <cprintf>
    return 0;
  100bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c04:	c9                   	leave  
  100c05:	c3                   	ret    

00100c06 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c06:	55                   	push   %ebp
  100c07:	89 e5                	mov    %esp,%ebp
  100c09:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c0c:	c7 04 24 60 6e 10 00 	movl   $0x106e60,(%esp)
  100c13:	e8 3b f7 ff ff       	call   100353 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c18:	c7 04 24 88 6e 10 00 	movl   $0x106e88,(%esp)
  100c1f:	e8 2f f7 ff ff       	call   100353 <cprintf>

    if (tf != NULL) {
  100c24:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c28:	74 0b                	je     100c35 <kmonitor+0x2f>
        print_trapframe(tf);
  100c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  100c2d:	89 04 24             	mov    %eax,(%esp)
  100c30:	e8 64 0e 00 00       	call   101a99 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c35:	c7 04 24 ad 6e 10 00 	movl   $0x106ead,(%esp)
  100c3c:	e8 09 f6 ff ff       	call   10024a <readline>
  100c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c48:	74 18                	je     100c62 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  100c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c54:	89 04 24             	mov    %eax,(%esp)
  100c57:	e8 f8 fe ff ff       	call   100b54 <runcmd>
  100c5c:	85 c0                	test   %eax,%eax
  100c5e:	79 02                	jns    100c62 <kmonitor+0x5c>
                break;
  100c60:	eb 02                	jmp    100c64 <kmonitor+0x5e>
            }
        }
    }
  100c62:	eb d1                	jmp    100c35 <kmonitor+0x2f>
}
  100c64:	c9                   	leave  
  100c65:	c3                   	ret    

00100c66 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c66:	55                   	push   %ebp
  100c67:	89 e5                	mov    %esp,%ebp
  100c69:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c73:	eb 3f                	jmp    100cb4 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c78:	89 d0                	mov    %edx,%eax
  100c7a:	01 c0                	add    %eax,%eax
  100c7c:	01 d0                	add    %edx,%eax
  100c7e:	c1 e0 02             	shl    $0x2,%eax
  100c81:	05 00 90 11 00       	add    $0x119000,%eax
  100c86:	8b 48 04             	mov    0x4(%eax),%ecx
  100c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c8c:	89 d0                	mov    %edx,%eax
  100c8e:	01 c0                	add    %eax,%eax
  100c90:	01 d0                	add    %edx,%eax
  100c92:	c1 e0 02             	shl    $0x2,%eax
  100c95:	05 00 90 11 00       	add    $0x119000,%eax
  100c9a:	8b 00                	mov    (%eax),%eax
  100c9c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ca4:	c7 04 24 b1 6e 10 00 	movl   $0x106eb1,(%esp)
  100cab:	e8 a3 f6 ff ff       	call   100353 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100cb0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cb7:	83 f8 02             	cmp    $0x2,%eax
  100cba:	76 b9                	jbe    100c75 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100cbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc1:	c9                   	leave  
  100cc2:	c3                   	ret    

00100cc3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cc3:	55                   	push   %ebp
  100cc4:	89 e5                	mov    %esp,%ebp
  100cc6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cc9:	e8 b9 fb ff ff       	call   100887 <print_kerninfo>
    return 0;
  100cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd3:	c9                   	leave  
  100cd4:	c3                   	ret    

00100cd5 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cd5:	55                   	push   %ebp
  100cd6:	89 e5                	mov    %esp,%ebp
  100cd8:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cdb:	e8 f1 fc ff ff       	call   1009d1 <print_stackframe>
    return 0;
  100ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ce5:	c9                   	leave  
  100ce6:	c3                   	ret    

00100ce7 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100ce7:	55                   	push   %ebp
  100ce8:	89 e5                	mov    %esp,%ebp
  100cea:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ced:	a1 20 c4 11 00       	mov    0x11c420,%eax
  100cf2:	85 c0                	test   %eax,%eax
  100cf4:	74 02                	je     100cf8 <__panic+0x11>
        goto panic_dead;
  100cf6:	eb 59                	jmp    100d51 <__panic+0x6a>
    }
    is_panic = 1;
  100cf8:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
  100cff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100d02:	8d 45 14             	lea    0x14(%ebp),%eax
  100d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  100d12:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d16:	c7 04 24 ba 6e 10 00 	movl   $0x106eba,(%esp)
  100d1d:	e8 31 f6 ff ff       	call   100353 <cprintf>
    vcprintf(fmt, ap);
  100d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d25:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d29:	8b 45 10             	mov    0x10(%ebp),%eax
  100d2c:	89 04 24             	mov    %eax,(%esp)
  100d2f:	e8 ec f5 ff ff       	call   100320 <vcprintf>
    cprintf("\n");
  100d34:	c7 04 24 d6 6e 10 00 	movl   $0x106ed6,(%esp)
  100d3b:	e8 13 f6 ff ff       	call   100353 <cprintf>
    
    cprintf("stack trackback:\n");
  100d40:	c7 04 24 d8 6e 10 00 	movl   $0x106ed8,(%esp)
  100d47:	e8 07 f6 ff ff       	call   100353 <cprintf>
    print_stackframe();
  100d4c:	e8 80 fc ff ff       	call   1009d1 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d51:	e8 85 09 00 00       	call   1016db <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d5d:	e8 a4 fe ff ff       	call   100c06 <kmonitor>
    }
  100d62:	eb f2                	jmp    100d56 <__panic+0x6f>

00100d64 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d64:	55                   	push   %ebp
  100d65:	89 e5                	mov    %esp,%ebp
  100d67:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d6a:	8d 45 14             	lea    0x14(%ebp),%eax
  100d6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d70:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d73:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d77:	8b 45 08             	mov    0x8(%ebp),%eax
  100d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7e:	c7 04 24 ea 6e 10 00 	movl   $0x106eea,(%esp)
  100d85:	e8 c9 f5 ff ff       	call   100353 <cprintf>
    vcprintf(fmt, ap);
  100d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d91:	8b 45 10             	mov    0x10(%ebp),%eax
  100d94:	89 04 24             	mov    %eax,(%esp)
  100d97:	e8 84 f5 ff ff       	call   100320 <vcprintf>
    cprintf("\n");
  100d9c:	c7 04 24 d6 6e 10 00 	movl   $0x106ed6,(%esp)
  100da3:	e8 ab f5 ff ff       	call   100353 <cprintf>
    va_end(ap);
}
  100da8:	c9                   	leave  
  100da9:	c3                   	ret    

00100daa <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100daa:	55                   	push   %ebp
  100dab:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100dad:	a1 20 c4 11 00       	mov    0x11c420,%eax
}
  100db2:	5d                   	pop    %ebp
  100db3:	c3                   	ret    

00100db4 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100db4:	55                   	push   %ebp
  100db5:	89 e5                	mov    %esp,%ebp
  100db7:	83 ec 28             	sub    $0x28,%esp
  100dba:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100dc0:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dc4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dc8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dcc:	ee                   	out    %al,(%dx)
  100dcd:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dd3:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dd7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100ddb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ddf:	ee                   	out    %al,(%dx)
  100de0:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100de6:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100dea:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dee:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100df2:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100df3:	c7 05 2c cf 11 00 00 	movl   $0x0,0x11cf2c
  100dfa:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dfd:	c7 04 24 08 6f 10 00 	movl   $0x106f08,(%esp)
  100e04:	e8 4a f5 ff ff       	call   100353 <cprintf>
    pic_enable(IRQ_TIMER);
  100e09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e10:	e8 24 09 00 00       	call   101739 <pic_enable>
}
  100e15:	c9                   	leave  
  100e16:	c3                   	ret    

00100e17 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e17:	55                   	push   %ebp
  100e18:	89 e5                	mov    %esp,%ebp
  100e1a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e1d:	9c                   	pushf  
  100e1e:	58                   	pop    %eax
  100e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e25:	25 00 02 00 00       	and    $0x200,%eax
  100e2a:	85 c0                	test   %eax,%eax
  100e2c:	74 0c                	je     100e3a <__intr_save+0x23>
        intr_disable();
  100e2e:	e8 a8 08 00 00       	call   1016db <intr_disable>
        return 1;
  100e33:	b8 01 00 00 00       	mov    $0x1,%eax
  100e38:	eb 05                	jmp    100e3f <__intr_save+0x28>
    }
    return 0;
  100e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e3f:	c9                   	leave  
  100e40:	c3                   	ret    

00100e41 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e41:	55                   	push   %ebp
  100e42:	89 e5                	mov    %esp,%ebp
  100e44:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e4b:	74 05                	je     100e52 <__intr_restore+0x11>
        intr_enable();
  100e4d:	e8 83 08 00 00       	call   1016d5 <intr_enable>
    }
}
  100e52:	c9                   	leave  
  100e53:	c3                   	ret    

00100e54 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e54:	55                   	push   %ebp
  100e55:	89 e5                	mov    %esp,%ebp
  100e57:	83 ec 10             	sub    $0x10,%esp
  100e5a:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e60:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e64:	89 c2                	mov    %eax,%edx
  100e66:	ec                   	in     (%dx),%al
  100e67:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e6a:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e70:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e74:	89 c2                	mov    %eax,%edx
  100e76:	ec                   	in     (%dx),%al
  100e77:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e7a:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e80:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e84:	89 c2                	mov    %eax,%edx
  100e86:	ec                   	in     (%dx),%al
  100e87:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e8a:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e90:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e94:	89 c2                	mov    %eax,%edx
  100e96:	ec                   	in     (%dx),%al
  100e97:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e9a:	c9                   	leave  
  100e9b:	c3                   	ret    

00100e9c <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e9c:	55                   	push   %ebp
  100e9d:	89 e5                	mov    %esp,%ebp
  100e9f:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100ea2:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ea9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eac:	0f b7 00             	movzwl (%eax),%eax
  100eaf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb6:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebe:	0f b7 00             	movzwl (%eax),%eax
  100ec1:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100ec5:	74 12                	je     100ed9 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ec7:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ece:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100ed5:	b4 03 
  100ed7:	eb 13                	jmp    100eec <cga_init+0x50>
    } else {
        *cp = was;
  100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ee3:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100eea:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100eec:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100ef3:	0f b7 c0             	movzwl %ax,%eax
  100ef6:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100efa:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100efe:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f02:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f06:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100f07:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f0e:	83 c0 01             	add    $0x1,%eax
  100f11:	0f b7 c0             	movzwl %ax,%eax
  100f14:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f18:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f1c:	89 c2                	mov    %eax,%edx
  100f1e:	ec                   	in     (%dx),%al
  100f1f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f22:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f26:	0f b6 c0             	movzbl %al,%eax
  100f29:	c1 e0 08             	shl    $0x8,%eax
  100f2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f2f:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f36:	0f b7 c0             	movzwl %ax,%eax
  100f39:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f3d:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f41:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f45:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f49:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f4a:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f51:	83 c0 01             	add    $0x1,%eax
  100f54:	0f b7 c0             	movzwl %ax,%eax
  100f57:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f5b:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f5f:	89 c2                	mov    %eax,%edx
  100f61:	ec                   	in     (%dx),%al
  100f62:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f65:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f69:	0f b6 c0             	movzbl %al,%eax
  100f6c:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f72:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f7a:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
}
  100f80:	c9                   	leave  
  100f81:	c3                   	ret    

00100f82 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f82:	55                   	push   %ebp
  100f83:	89 e5                	mov    %esp,%ebp
  100f85:	83 ec 48             	sub    $0x48,%esp
  100f88:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f8e:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f92:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f96:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f9a:	ee                   	out    %al,(%dx)
  100f9b:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100fa1:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100fa5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100fa9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100fad:	ee                   	out    %al,(%dx)
  100fae:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100fb4:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fb8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fbc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fc0:	ee                   	out    %al,(%dx)
  100fc1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fc7:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fcb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fcf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fd3:	ee                   	out    %al,(%dx)
  100fd4:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fda:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fde:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fe2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fe6:	ee                   	out    %al,(%dx)
  100fe7:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fed:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100ff1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100ff5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100ff9:	ee                   	out    %al,(%dx)
  100ffa:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  101000:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  101004:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101008:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10100c:	ee                   	out    %al,(%dx)
  10100d:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101013:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  101017:	89 c2                	mov    %eax,%edx
  101019:	ec                   	in     (%dx),%al
  10101a:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  10101d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101021:	3c ff                	cmp    $0xff,%al
  101023:	0f 95 c0             	setne  %al
  101026:	0f b6 c0             	movzbl %al,%eax
  101029:	a3 48 c4 11 00       	mov    %eax,0x11c448
  10102e:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101034:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101038:	89 c2                	mov    %eax,%edx
  10103a:	ec                   	in     (%dx),%al
  10103b:	88 45 d5             	mov    %al,-0x2b(%ebp)
  10103e:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  101044:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  101048:	89 c2                	mov    %eax,%edx
  10104a:	ec                   	in     (%dx),%al
  10104b:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10104e:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101053:	85 c0                	test   %eax,%eax
  101055:	74 0c                	je     101063 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101057:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10105e:	e8 d6 06 00 00       	call   101739 <pic_enable>
    }
}
  101063:	c9                   	leave  
  101064:	c3                   	ret    

00101065 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101065:	55                   	push   %ebp
  101066:	89 e5                	mov    %esp,%ebp
  101068:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10106b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101072:	eb 09                	jmp    10107d <lpt_putc_sub+0x18>
        delay();
  101074:	e8 db fd ff ff       	call   100e54 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101079:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10107d:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101083:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101087:	89 c2                	mov    %eax,%edx
  101089:	ec                   	in     (%dx),%al
  10108a:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10108d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101091:	84 c0                	test   %al,%al
  101093:	78 09                	js     10109e <lpt_putc_sub+0x39>
  101095:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10109c:	7e d6                	jle    101074 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  10109e:	8b 45 08             	mov    0x8(%ebp),%eax
  1010a1:	0f b6 c0             	movzbl %al,%eax
  1010a4:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  1010aa:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010ad:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010b1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010b5:	ee                   	out    %al,(%dx)
  1010b6:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010bc:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010c0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010c4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010c8:	ee                   	out    %al,(%dx)
  1010c9:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010cf:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010d3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010d7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010db:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010dc:	c9                   	leave  
  1010dd:	c3                   	ret    

001010de <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010de:	55                   	push   %ebp
  1010df:	89 e5                	mov    %esp,%ebp
  1010e1:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010e4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010e8:	74 0d                	je     1010f7 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ed:	89 04 24             	mov    %eax,(%esp)
  1010f0:	e8 70 ff ff ff       	call   101065 <lpt_putc_sub>
  1010f5:	eb 24                	jmp    10111b <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010f7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010fe:	e8 62 ff ff ff       	call   101065 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101103:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10110a:	e8 56 ff ff ff       	call   101065 <lpt_putc_sub>
        lpt_putc_sub('\b');
  10110f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101116:	e8 4a ff ff ff       	call   101065 <lpt_putc_sub>
    }
}
  10111b:	c9                   	leave  
  10111c:	c3                   	ret    

0010111d <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10111d:	55                   	push   %ebp
  10111e:	89 e5                	mov    %esp,%ebp
  101120:	53                   	push   %ebx
  101121:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101124:	8b 45 08             	mov    0x8(%ebp),%eax
  101127:	b0 00                	mov    $0x0,%al
  101129:	85 c0                	test   %eax,%eax
  10112b:	75 07                	jne    101134 <cga_putc+0x17>
        c |= 0x0700;
  10112d:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101134:	8b 45 08             	mov    0x8(%ebp),%eax
  101137:	0f b6 c0             	movzbl %al,%eax
  10113a:	83 f8 0a             	cmp    $0xa,%eax
  10113d:	74 4c                	je     10118b <cga_putc+0x6e>
  10113f:	83 f8 0d             	cmp    $0xd,%eax
  101142:	74 57                	je     10119b <cga_putc+0x7e>
  101144:	83 f8 08             	cmp    $0x8,%eax
  101147:	0f 85 88 00 00 00    	jne    1011d5 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  10114d:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101154:	66 85 c0             	test   %ax,%ax
  101157:	74 30                	je     101189 <cga_putc+0x6c>
            crt_pos --;
  101159:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101160:	83 e8 01             	sub    $0x1,%eax
  101163:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101169:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10116e:	0f b7 15 44 c4 11 00 	movzwl 0x11c444,%edx
  101175:	0f b7 d2             	movzwl %dx,%edx
  101178:	01 d2                	add    %edx,%edx
  10117a:	01 c2                	add    %eax,%edx
  10117c:	8b 45 08             	mov    0x8(%ebp),%eax
  10117f:	b0 00                	mov    $0x0,%al
  101181:	83 c8 20             	or     $0x20,%eax
  101184:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101187:	eb 72                	jmp    1011fb <cga_putc+0xde>
  101189:	eb 70                	jmp    1011fb <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  10118b:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101192:	83 c0 50             	add    $0x50,%eax
  101195:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10119b:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  1011a2:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  1011a9:	0f b7 c1             	movzwl %cx,%eax
  1011ac:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1011b2:	c1 e8 10             	shr    $0x10,%eax
  1011b5:	89 c2                	mov    %eax,%edx
  1011b7:	66 c1 ea 06          	shr    $0x6,%dx
  1011bb:	89 d0                	mov    %edx,%eax
  1011bd:	c1 e0 02             	shl    $0x2,%eax
  1011c0:	01 d0                	add    %edx,%eax
  1011c2:	c1 e0 04             	shl    $0x4,%eax
  1011c5:	29 c1                	sub    %eax,%ecx
  1011c7:	89 ca                	mov    %ecx,%edx
  1011c9:	89 d8                	mov    %ebx,%eax
  1011cb:	29 d0                	sub    %edx,%eax
  1011cd:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  1011d3:	eb 26                	jmp    1011fb <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011d5:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  1011db:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011e2:	8d 50 01             	lea    0x1(%eax),%edx
  1011e5:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
  1011ec:	0f b7 c0             	movzwl %ax,%eax
  1011ef:	01 c0                	add    %eax,%eax
  1011f1:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1011f7:	66 89 02             	mov    %ax,(%edx)
        break;
  1011fa:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011fb:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101202:	66 3d cf 07          	cmp    $0x7cf,%ax
  101206:	76 5b                	jbe    101263 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101208:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10120d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101213:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101218:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10121f:	00 
  101220:	89 54 24 04          	mov    %edx,0x4(%esp)
  101224:	89 04 24             	mov    %eax,(%esp)
  101227:	e8 66 58 00 00       	call   106a92 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10122c:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101233:	eb 15                	jmp    10124a <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  101235:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10123a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10123d:	01 d2                	add    %edx,%edx
  10123f:	01 d0                	add    %edx,%eax
  101241:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101246:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10124a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101251:	7e e2                	jle    101235 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101253:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10125a:	83 e8 50             	sub    $0x50,%eax
  10125d:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101263:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  10126a:	0f b7 c0             	movzwl %ax,%eax
  10126d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101271:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  101275:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101279:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10127d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10127e:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101285:	66 c1 e8 08          	shr    $0x8,%ax
  101289:	0f b6 c0             	movzbl %al,%eax
  10128c:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  101293:	83 c2 01             	add    $0x1,%edx
  101296:	0f b7 d2             	movzwl %dx,%edx
  101299:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  10129d:	88 45 ed             	mov    %al,-0x13(%ebp)
  1012a0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012a4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012a8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1012a9:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1012b0:	0f b7 c0             	movzwl %ax,%eax
  1012b3:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012b7:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012bb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012bf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012c3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012c4:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012cb:	0f b6 c0             	movzbl %al,%eax
  1012ce:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  1012d5:	83 c2 01             	add    $0x1,%edx
  1012d8:	0f b7 d2             	movzwl %dx,%edx
  1012db:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012df:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012e2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012e6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012ea:	ee                   	out    %al,(%dx)
}
  1012eb:	83 c4 34             	add    $0x34,%esp
  1012ee:	5b                   	pop    %ebx
  1012ef:	5d                   	pop    %ebp
  1012f0:	c3                   	ret    

001012f1 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012f1:	55                   	push   %ebp
  1012f2:	89 e5                	mov    %esp,%ebp
  1012f4:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012fe:	eb 09                	jmp    101309 <serial_putc_sub+0x18>
        delay();
  101300:	e8 4f fb ff ff       	call   100e54 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101305:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101309:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10130f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101313:	89 c2                	mov    %eax,%edx
  101315:	ec                   	in     (%dx),%al
  101316:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101319:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10131d:	0f b6 c0             	movzbl %al,%eax
  101320:	83 e0 20             	and    $0x20,%eax
  101323:	85 c0                	test   %eax,%eax
  101325:	75 09                	jne    101330 <serial_putc_sub+0x3f>
  101327:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10132e:	7e d0                	jle    101300 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101330:	8b 45 08             	mov    0x8(%ebp),%eax
  101333:	0f b6 c0             	movzbl %al,%eax
  101336:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10133c:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10133f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101343:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101347:	ee                   	out    %al,(%dx)
}
  101348:	c9                   	leave  
  101349:	c3                   	ret    

0010134a <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10134a:	55                   	push   %ebp
  10134b:	89 e5                	mov    %esp,%ebp
  10134d:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101350:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101354:	74 0d                	je     101363 <serial_putc+0x19>
        serial_putc_sub(c);
  101356:	8b 45 08             	mov    0x8(%ebp),%eax
  101359:	89 04 24             	mov    %eax,(%esp)
  10135c:	e8 90 ff ff ff       	call   1012f1 <serial_putc_sub>
  101361:	eb 24                	jmp    101387 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  101363:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136a:	e8 82 ff ff ff       	call   1012f1 <serial_putc_sub>
        serial_putc_sub(' ');
  10136f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101376:	e8 76 ff ff ff       	call   1012f1 <serial_putc_sub>
        serial_putc_sub('\b');
  10137b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101382:	e8 6a ff ff ff       	call   1012f1 <serial_putc_sub>
    }
}
  101387:	c9                   	leave  
  101388:	c3                   	ret    

00101389 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101389:	55                   	push   %ebp
  10138a:	89 e5                	mov    %esp,%ebp
  10138c:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10138f:	eb 33                	jmp    1013c4 <cons_intr+0x3b>
        if (c != 0) {
  101391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101395:	74 2d                	je     1013c4 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101397:	a1 64 c6 11 00       	mov    0x11c664,%eax
  10139c:	8d 50 01             	lea    0x1(%eax),%edx
  10139f:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  1013a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013a8:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013ae:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1013b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013b8:	75 0a                	jne    1013c4 <cons_intr+0x3b>
                cons.wpos = 0;
  1013ba:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
  1013c1:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1013c7:	ff d0                	call   *%eax
  1013c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013cc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013d0:	75 bf                	jne    101391 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013d2:	c9                   	leave  
  1013d3:	c3                   	ret    

001013d4 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013d4:	55                   	push   %ebp
  1013d5:	89 e5                	mov    %esp,%ebp
  1013d7:	83 ec 10             	sub    $0x10,%esp
  1013da:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013e0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013e4:	89 c2                	mov    %eax,%edx
  1013e6:	ec                   	in     (%dx),%al
  1013e7:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013ea:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013ee:	0f b6 c0             	movzbl %al,%eax
  1013f1:	83 e0 01             	and    $0x1,%eax
  1013f4:	85 c0                	test   %eax,%eax
  1013f6:	75 07                	jne    1013ff <serial_proc_data+0x2b>
        return -1;
  1013f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013fd:	eb 2a                	jmp    101429 <serial_proc_data+0x55>
  1013ff:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101405:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101409:	89 c2                	mov    %eax,%edx
  10140b:	ec                   	in     (%dx),%al
  10140c:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  10140f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101413:	0f b6 c0             	movzbl %al,%eax
  101416:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101419:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10141d:	75 07                	jne    101426 <serial_proc_data+0x52>
        c = '\b';
  10141f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101426:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101429:	c9                   	leave  
  10142a:	c3                   	ret    

0010142b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10142b:	55                   	push   %ebp
  10142c:	89 e5                	mov    %esp,%ebp
  10142e:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101431:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101436:	85 c0                	test   %eax,%eax
  101438:	74 0c                	je     101446 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10143a:	c7 04 24 d4 13 10 00 	movl   $0x1013d4,(%esp)
  101441:	e8 43 ff ff ff       	call   101389 <cons_intr>
    }
}
  101446:	c9                   	leave  
  101447:	c3                   	ret    

00101448 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101448:	55                   	push   %ebp
  101449:	89 e5                	mov    %esp,%ebp
  10144b:	83 ec 38             	sub    $0x38,%esp
  10144e:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101454:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101458:	89 c2                	mov    %eax,%edx
  10145a:	ec                   	in     (%dx),%al
  10145b:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10145e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101462:	0f b6 c0             	movzbl %al,%eax
  101465:	83 e0 01             	and    $0x1,%eax
  101468:	85 c0                	test   %eax,%eax
  10146a:	75 0a                	jne    101476 <kbd_proc_data+0x2e>
        return -1;
  10146c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101471:	e9 59 01 00 00       	jmp    1015cf <kbd_proc_data+0x187>
  101476:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10147c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101480:	89 c2                	mov    %eax,%edx
  101482:	ec                   	in     (%dx),%al
  101483:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101486:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10148a:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10148d:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101491:	75 17                	jne    1014aa <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101493:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101498:	83 c8 40             	or     $0x40,%eax
  10149b:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  1014a0:	b8 00 00 00 00       	mov    $0x0,%eax
  1014a5:	e9 25 01 00 00       	jmp    1015cf <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  1014aa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ae:	84 c0                	test   %al,%al
  1014b0:	79 47                	jns    1014f9 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014b2:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014b7:	83 e0 40             	and    $0x40,%eax
  1014ba:	85 c0                	test   %eax,%eax
  1014bc:	75 09                	jne    1014c7 <kbd_proc_data+0x7f>
  1014be:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c2:	83 e0 7f             	and    $0x7f,%eax
  1014c5:	eb 04                	jmp    1014cb <kbd_proc_data+0x83>
  1014c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014cb:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014ce:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d2:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  1014d9:	83 c8 40             	or     $0x40,%eax
  1014dc:	0f b6 c0             	movzbl %al,%eax
  1014df:	f7 d0                	not    %eax
  1014e1:	89 c2                	mov    %eax,%edx
  1014e3:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014e8:	21 d0                	and    %edx,%eax
  1014ea:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  1014ef:	b8 00 00 00 00       	mov    $0x0,%eax
  1014f4:	e9 d6 00 00 00       	jmp    1015cf <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014f9:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014fe:	83 e0 40             	and    $0x40,%eax
  101501:	85 c0                	test   %eax,%eax
  101503:	74 11                	je     101516 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101505:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101509:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10150e:	83 e0 bf             	and    $0xffffffbf,%eax
  101511:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  101516:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151a:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101521:	0f b6 d0             	movzbl %al,%edx
  101524:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101529:	09 d0                	or     %edx,%eax
  10152b:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  101530:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101534:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  10153b:	0f b6 d0             	movzbl %al,%edx
  10153e:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101543:	31 d0                	xor    %edx,%eax
  101545:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  10154a:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10154f:	83 e0 03             	and    $0x3,%eax
  101552:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  101559:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10155d:	01 d0                	add    %edx,%eax
  10155f:	0f b6 00             	movzbl (%eax),%eax
  101562:	0f b6 c0             	movzbl %al,%eax
  101565:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101568:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10156d:	83 e0 08             	and    $0x8,%eax
  101570:	85 c0                	test   %eax,%eax
  101572:	74 22                	je     101596 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101574:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101578:	7e 0c                	jle    101586 <kbd_proc_data+0x13e>
  10157a:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10157e:	7f 06                	jg     101586 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101580:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101584:	eb 10                	jmp    101596 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101586:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10158a:	7e 0a                	jle    101596 <kbd_proc_data+0x14e>
  10158c:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101590:	7f 04                	jg     101596 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101592:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101596:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10159b:	f7 d0                	not    %eax
  10159d:	83 e0 06             	and    $0x6,%eax
  1015a0:	85 c0                	test   %eax,%eax
  1015a2:	75 28                	jne    1015cc <kbd_proc_data+0x184>
  1015a4:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015ab:	75 1f                	jne    1015cc <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  1015ad:	c7 04 24 23 6f 10 00 	movl   $0x106f23,(%esp)
  1015b4:	e8 9a ed ff ff       	call   100353 <cprintf>
  1015b9:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015bf:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015c3:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015c7:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015cb:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015cf:	c9                   	leave  
  1015d0:	c3                   	ret    

001015d1 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015d1:	55                   	push   %ebp
  1015d2:	89 e5                	mov    %esp,%ebp
  1015d4:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015d7:	c7 04 24 48 14 10 00 	movl   $0x101448,(%esp)
  1015de:	e8 a6 fd ff ff       	call   101389 <cons_intr>
}
  1015e3:	c9                   	leave  
  1015e4:	c3                   	ret    

001015e5 <kbd_init>:

static void
kbd_init(void) {
  1015e5:	55                   	push   %ebp
  1015e6:	89 e5                	mov    %esp,%ebp
  1015e8:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015eb:	e8 e1 ff ff ff       	call   1015d1 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015f7:	e8 3d 01 00 00       	call   101739 <pic_enable>
}
  1015fc:	c9                   	leave  
  1015fd:	c3                   	ret    

001015fe <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015fe:	55                   	push   %ebp
  1015ff:	89 e5                	mov    %esp,%ebp
  101601:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101604:	e8 93 f8 ff ff       	call   100e9c <cga_init>
    serial_init();
  101609:	e8 74 f9 ff ff       	call   100f82 <serial_init>
    kbd_init();
  10160e:	e8 d2 ff ff ff       	call   1015e5 <kbd_init>
    if (!serial_exists) {
  101613:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101618:	85 c0                	test   %eax,%eax
  10161a:	75 0c                	jne    101628 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10161c:	c7 04 24 2f 6f 10 00 	movl   $0x106f2f,(%esp)
  101623:	e8 2b ed ff ff       	call   100353 <cprintf>
    }
}
  101628:	c9                   	leave  
  101629:	c3                   	ret    

0010162a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10162a:	55                   	push   %ebp
  10162b:	89 e5                	mov    %esp,%ebp
  10162d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101630:	e8 e2 f7 ff ff       	call   100e17 <__intr_save>
  101635:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101638:	8b 45 08             	mov    0x8(%ebp),%eax
  10163b:	89 04 24             	mov    %eax,(%esp)
  10163e:	e8 9b fa ff ff       	call   1010de <lpt_putc>
        cga_putc(c);
  101643:	8b 45 08             	mov    0x8(%ebp),%eax
  101646:	89 04 24             	mov    %eax,(%esp)
  101649:	e8 cf fa ff ff       	call   10111d <cga_putc>
        serial_putc(c);
  10164e:	8b 45 08             	mov    0x8(%ebp),%eax
  101651:	89 04 24             	mov    %eax,(%esp)
  101654:	e8 f1 fc ff ff       	call   10134a <serial_putc>
    }
    local_intr_restore(intr_flag);
  101659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10165c:	89 04 24             	mov    %eax,(%esp)
  10165f:	e8 dd f7 ff ff       	call   100e41 <__intr_restore>
}
  101664:	c9                   	leave  
  101665:	c3                   	ret    

00101666 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101666:	55                   	push   %ebp
  101667:	89 e5                	mov    %esp,%ebp
  101669:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  10166c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101673:	e8 9f f7 ff ff       	call   100e17 <__intr_save>
  101678:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  10167b:	e8 ab fd ff ff       	call   10142b <serial_intr>
        kbd_intr();
  101680:	e8 4c ff ff ff       	call   1015d1 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101685:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  10168b:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101690:	39 c2                	cmp    %eax,%edx
  101692:	74 31                	je     1016c5 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  101694:	a1 60 c6 11 00       	mov    0x11c660,%eax
  101699:	8d 50 01             	lea    0x1(%eax),%edx
  10169c:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  1016a2:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  1016a9:	0f b6 c0             	movzbl %al,%eax
  1016ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016af:	a1 60 c6 11 00       	mov    0x11c660,%eax
  1016b4:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016b9:	75 0a                	jne    1016c5 <cons_getc+0x5f>
                cons.rpos = 0;
  1016bb:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
  1016c2:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016c8:	89 04 24             	mov    %eax,(%esp)
  1016cb:	e8 71 f7 ff ff       	call   100e41 <__intr_restore>
    return c;
  1016d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016d3:	c9                   	leave  
  1016d4:	c3                   	ret    

001016d5 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016d5:	55                   	push   %ebp
  1016d6:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016d8:	fb                   	sti    
    sti();
}
  1016d9:	5d                   	pop    %ebp
  1016da:	c3                   	ret    

001016db <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016db:	55                   	push   %ebp
  1016dc:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016de:	fa                   	cli    
    cli();
}
  1016df:	5d                   	pop    %ebp
  1016e0:	c3                   	ret    

001016e1 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016e1:	55                   	push   %ebp
  1016e2:	89 e5                	mov    %esp,%ebp
  1016e4:	83 ec 14             	sub    $0x14,%esp
  1016e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1016ea:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016ee:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f2:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  1016f8:	a1 6c c6 11 00       	mov    0x11c66c,%eax
  1016fd:	85 c0                	test   %eax,%eax
  1016ff:	74 36                	je     101737 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101701:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101705:	0f b6 c0             	movzbl %al,%eax
  101708:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10170e:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101711:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101715:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101719:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10171a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10171e:	66 c1 e8 08          	shr    $0x8,%ax
  101722:	0f b6 c0             	movzbl %al,%eax
  101725:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10172b:	88 45 f9             	mov    %al,-0x7(%ebp)
  10172e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101732:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101736:	ee                   	out    %al,(%dx)
    }
}
  101737:	c9                   	leave  
  101738:	c3                   	ret    

00101739 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101739:	55                   	push   %ebp
  10173a:	89 e5                	mov    %esp,%ebp
  10173c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10173f:	8b 45 08             	mov    0x8(%ebp),%eax
  101742:	ba 01 00 00 00       	mov    $0x1,%edx
  101747:	89 c1                	mov    %eax,%ecx
  101749:	d3 e2                	shl    %cl,%edx
  10174b:	89 d0                	mov    %edx,%eax
  10174d:	f7 d0                	not    %eax
  10174f:	89 c2                	mov    %eax,%edx
  101751:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101758:	21 d0                	and    %edx,%eax
  10175a:	0f b7 c0             	movzwl %ax,%eax
  10175d:	89 04 24             	mov    %eax,(%esp)
  101760:	e8 7c ff ff ff       	call   1016e1 <pic_setmask>
}
  101765:	c9                   	leave  
  101766:	c3                   	ret    

00101767 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101767:	55                   	push   %ebp
  101768:	89 e5                	mov    %esp,%ebp
  10176a:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  10176d:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
  101774:	00 00 00 
  101777:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10177d:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  101781:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101785:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101789:	ee                   	out    %al,(%dx)
  10178a:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101790:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  101794:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101798:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10179c:	ee                   	out    %al,(%dx)
  10179d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1017a3:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  1017a7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1017ab:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017af:	ee                   	out    %al,(%dx)
  1017b0:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1017b6:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017ba:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017be:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017c2:	ee                   	out    %al,(%dx)
  1017c3:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017c9:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017cd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017d1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017d5:	ee                   	out    %al,(%dx)
  1017d6:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017dc:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017e0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017e4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017e8:	ee                   	out    %al,(%dx)
  1017e9:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017ef:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017f3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017f7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017fb:	ee                   	out    %al,(%dx)
  1017fc:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101802:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101806:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10180a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10180e:	ee                   	out    %al,(%dx)
  10180f:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101815:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101819:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10181d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101821:	ee                   	out    %al,(%dx)
  101822:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101828:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  10182c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101830:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101834:	ee                   	out    %al,(%dx)
  101835:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  10183b:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  10183f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101843:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101847:	ee                   	out    %al,(%dx)
  101848:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10184e:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  101852:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101856:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10185a:	ee                   	out    %al,(%dx)
  10185b:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  101861:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  101865:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101869:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10186d:	ee                   	out    %al,(%dx)
  10186e:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  101874:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101878:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  10187c:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101880:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101881:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101888:	66 83 f8 ff          	cmp    $0xffff,%ax
  10188c:	74 12                	je     1018a0 <pic_init+0x139>
        pic_setmask(irq_mask);
  10188e:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101895:	0f b7 c0             	movzwl %ax,%eax
  101898:	89 04 24             	mov    %eax,(%esp)
  10189b:	e8 41 fe ff ff       	call   1016e1 <pic_setmask>
    }
}
  1018a0:	c9                   	leave  
  1018a1:	c3                   	ret    

001018a2 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1018a2:	55                   	push   %ebp
  1018a3:	89 e5                	mov    %esp,%ebp
  1018a5:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1018a8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018af:	00 
  1018b0:	c7 04 24 60 6f 10 00 	movl   $0x106f60,(%esp)
  1018b7:	e8 97 ea ff ff       	call   100353 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018bc:	c7 04 24 6a 6f 10 00 	movl   $0x106f6a,(%esp)
  1018c3:	e8 8b ea ff ff       	call   100353 <cprintf>
    panic("EOT: kernel seems ok.");
  1018c8:	c7 44 24 08 78 6f 10 	movl   $0x106f78,0x8(%esp)
  1018cf:	00 
  1018d0:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018d7:	00 
  1018d8:	c7 04 24 8e 6f 10 00 	movl   $0x106f8e,(%esp)
  1018df:	e8 03 f4 ff ff       	call   100ce7 <__panic>

001018e4 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018e4:	55                   	push   %ebp
  1018e5:	89 e5                	mov    %esp,%ebp
  1018e7:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
  1018ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018f1:	e9 c3 00 00 00       	jmp    1019b9 <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f9:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101900:	89 c2                	mov    %eax,%edx
  101902:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101905:	66 89 14 c5 80 c6 11 	mov    %dx,0x11c680(,%eax,8)
  10190c:	00 
  10190d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101910:	66 c7 04 c5 82 c6 11 	movw   $0x8,0x11c682(,%eax,8)
  101917:	00 08 00 
  10191a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191d:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  101924:	00 
  101925:	83 e2 e0             	and    $0xffffffe0,%edx
  101928:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  10192f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101932:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  101939:	00 
  10193a:	83 e2 1f             	and    $0x1f,%edx
  10193d:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  101944:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101947:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  10194e:	00 
  10194f:	83 e2 f0             	and    $0xfffffff0,%edx
  101952:	83 ca 0e             	or     $0xe,%edx
  101955:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  10195c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10195f:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101966:	00 
  101967:	83 e2 ef             	and    $0xffffffef,%edx
  10196a:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101971:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101974:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  10197b:	00 
  10197c:	83 e2 9f             	and    $0xffffff9f,%edx
  10197f:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101986:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101989:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101990:	00 
  101991:	83 ca 80             	or     $0xffffff80,%edx
  101994:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  10199b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10199e:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  1019a5:	c1 e8 10             	shr    $0x10,%eax
  1019a8:	89 c2                	mov    %eax,%edx
  1019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ad:	66 89 14 c5 86 c6 11 	mov    %dx,0x11c686(,%eax,8)
  1019b4:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
  1019b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1019b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019bc:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019c1:	0f 86 2f ff ff ff    	jbe    1018f6 <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
	}
	//SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], 3);
  1019c7:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  1019cc:	66 a3 48 ca 11 00    	mov    %ax,0x11ca48
  1019d2:	66 c7 05 4a ca 11 00 	movw   $0x8,0x11ca4a
  1019d9:	08 00 
  1019db:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  1019e2:	83 e0 e0             	and    $0xffffffe0,%eax
  1019e5:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  1019ea:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  1019f1:	83 e0 1f             	and    $0x1f,%eax
  1019f4:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  1019f9:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a00:	83 c8 0f             	or     $0xf,%eax
  101a03:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101a08:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a0f:	83 e0 ef             	and    $0xffffffef,%eax
  101a12:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101a17:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a1e:	83 c8 60             	or     $0x60,%eax
  101a21:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101a26:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101a2d:	83 c8 80             	or     $0xffffff80,%eax
  101a30:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101a35:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101a3a:	c1 e8 10             	shr    $0x10,%eax
  101a3d:	66 a3 4e ca 11 00    	mov    %ax,0x11ca4e
  101a43:	c7 45 f8 60 95 11 00 	movl   $0x119560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a4d:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
  101a50:	c9                   	leave  
  101a51:	c3                   	ret    

00101a52 <trapname>:

static const char *
trapname(int trapno) {
  101a52:	55                   	push   %ebp
  101a53:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a55:	8b 45 08             	mov    0x8(%ebp),%eax
  101a58:	83 f8 13             	cmp    $0x13,%eax
  101a5b:	77 0c                	ja     101a69 <trapname+0x17>
        return excnames[trapno];
  101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a60:	8b 04 85 e0 72 10 00 	mov    0x1072e0(,%eax,4),%eax
  101a67:	eb 18                	jmp    101a81 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a69:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a6d:	7e 0d                	jle    101a7c <trapname+0x2a>
  101a6f:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a73:	7f 07                	jg     101a7c <trapname+0x2a>
        return "Hardware Interrupt";
  101a75:	b8 9f 6f 10 00       	mov    $0x106f9f,%eax
  101a7a:	eb 05                	jmp    101a81 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a7c:	b8 b2 6f 10 00       	mov    $0x106fb2,%eax
}
  101a81:	5d                   	pop    %ebp
  101a82:	c3                   	ret    

00101a83 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a83:	55                   	push   %ebp
  101a84:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a86:	8b 45 08             	mov    0x8(%ebp),%eax
  101a89:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a8d:	66 83 f8 08          	cmp    $0x8,%ax
  101a91:	0f 94 c0             	sete   %al
  101a94:	0f b6 c0             	movzbl %al,%eax
}
  101a97:	5d                   	pop    %ebp
  101a98:	c3                   	ret    

00101a99 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a99:	55                   	push   %ebp
  101a9a:	89 e5                	mov    %esp,%ebp
  101a9c:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa6:	c7 04 24 f3 6f 10 00 	movl   $0x106ff3,(%esp)
  101aad:	e8 a1 e8 ff ff       	call   100353 <cprintf>
    print_regs(&tf->tf_regs);
  101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab5:	89 04 24             	mov    %eax,(%esp)
  101ab8:	e8 a1 01 00 00       	call   101c5e <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101abd:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac0:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101ac4:	0f b7 c0             	movzwl %ax,%eax
  101ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acb:	c7 04 24 04 70 10 00 	movl   $0x107004,(%esp)
  101ad2:	e8 7c e8 ff ff       	call   100353 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  101ada:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ade:	0f b7 c0             	movzwl %ax,%eax
  101ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae5:	c7 04 24 17 70 10 00 	movl   $0x107017,(%esp)
  101aec:	e8 62 e8 ff ff       	call   100353 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101af1:	8b 45 08             	mov    0x8(%ebp),%eax
  101af4:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101af8:	0f b7 c0             	movzwl %ax,%eax
  101afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aff:	c7 04 24 2a 70 10 00 	movl   $0x10702a,(%esp)
  101b06:	e8 48 e8 ff ff       	call   100353 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b0e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b12:	0f b7 c0             	movzwl %ax,%eax
  101b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b19:	c7 04 24 3d 70 10 00 	movl   $0x10703d,(%esp)
  101b20:	e8 2e e8 ff ff       	call   100353 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b25:	8b 45 08             	mov    0x8(%ebp),%eax
  101b28:	8b 40 30             	mov    0x30(%eax),%eax
  101b2b:	89 04 24             	mov    %eax,(%esp)
  101b2e:	e8 1f ff ff ff       	call   101a52 <trapname>
  101b33:	8b 55 08             	mov    0x8(%ebp),%edx
  101b36:	8b 52 30             	mov    0x30(%edx),%edx
  101b39:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b41:	c7 04 24 50 70 10 00 	movl   $0x107050,(%esp)
  101b48:	e8 06 e8 ff ff       	call   100353 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b50:	8b 40 34             	mov    0x34(%eax),%eax
  101b53:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b57:	c7 04 24 62 70 10 00 	movl   $0x107062,(%esp)
  101b5e:	e8 f0 e7 ff ff       	call   100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b63:	8b 45 08             	mov    0x8(%ebp),%eax
  101b66:	8b 40 38             	mov    0x38(%eax),%eax
  101b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b6d:	c7 04 24 71 70 10 00 	movl   $0x107071,(%esp)
  101b74:	e8 da e7 ff ff       	call   100353 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b79:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b80:	0f b7 c0             	movzwl %ax,%eax
  101b83:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b87:	c7 04 24 80 70 10 00 	movl   $0x107080,(%esp)
  101b8e:	e8 c0 e7 ff ff       	call   100353 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b93:	8b 45 08             	mov    0x8(%ebp),%eax
  101b96:	8b 40 40             	mov    0x40(%eax),%eax
  101b99:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b9d:	c7 04 24 93 70 10 00 	movl   $0x107093,(%esp)
  101ba4:	e8 aa e7 ff ff       	call   100353 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ba9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101bb0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101bb7:	eb 3e                	jmp    101bf7 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbc:	8b 50 40             	mov    0x40(%eax),%edx
  101bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bc2:	21 d0                	and    %edx,%eax
  101bc4:	85 c0                	test   %eax,%eax
  101bc6:	74 28                	je     101bf0 <print_trapframe+0x157>
  101bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bcb:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101bd2:	85 c0                	test   %eax,%eax
  101bd4:	74 1a                	je     101bf0 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bd9:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be4:	c7 04 24 a2 70 10 00 	movl   $0x1070a2,(%esp)
  101beb:	e8 63 e7 ff ff       	call   100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bf0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101bf4:	d1 65 f0             	shll   -0x10(%ebp)
  101bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bfa:	83 f8 17             	cmp    $0x17,%eax
  101bfd:	76 ba                	jbe    101bb9 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bff:	8b 45 08             	mov    0x8(%ebp),%eax
  101c02:	8b 40 40             	mov    0x40(%eax),%eax
  101c05:	25 00 30 00 00       	and    $0x3000,%eax
  101c0a:	c1 e8 0c             	shr    $0xc,%eax
  101c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c11:	c7 04 24 a6 70 10 00 	movl   $0x1070a6,(%esp)
  101c18:	e8 36 e7 ff ff       	call   100353 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c20:	89 04 24             	mov    %eax,(%esp)
  101c23:	e8 5b fe ff ff       	call   101a83 <trap_in_kernel>
  101c28:	85 c0                	test   %eax,%eax
  101c2a:	75 30                	jne    101c5c <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2f:	8b 40 44             	mov    0x44(%eax),%eax
  101c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c36:	c7 04 24 af 70 10 00 	movl   $0x1070af,(%esp)
  101c3d:	e8 11 e7 ff ff       	call   100353 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c42:	8b 45 08             	mov    0x8(%ebp),%eax
  101c45:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c49:	0f b7 c0             	movzwl %ax,%eax
  101c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c50:	c7 04 24 be 70 10 00 	movl   $0x1070be,(%esp)
  101c57:	e8 f7 e6 ff ff       	call   100353 <cprintf>
    }
}
  101c5c:	c9                   	leave  
  101c5d:	c3                   	ret    

00101c5e <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c5e:	55                   	push   %ebp
  101c5f:	89 e5                	mov    %esp,%ebp
  101c61:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c64:	8b 45 08             	mov    0x8(%ebp),%eax
  101c67:	8b 00                	mov    (%eax),%eax
  101c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6d:	c7 04 24 d1 70 10 00 	movl   $0x1070d1,(%esp)
  101c74:	e8 da e6 ff ff       	call   100353 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c79:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7c:	8b 40 04             	mov    0x4(%eax),%eax
  101c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c83:	c7 04 24 e0 70 10 00 	movl   $0x1070e0,(%esp)
  101c8a:	e8 c4 e6 ff ff       	call   100353 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c92:	8b 40 08             	mov    0x8(%eax),%eax
  101c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c99:	c7 04 24 ef 70 10 00 	movl   $0x1070ef,(%esp)
  101ca0:	e8 ae e6 ff ff       	call   100353 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca8:	8b 40 0c             	mov    0xc(%eax),%eax
  101cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101caf:	c7 04 24 fe 70 10 00 	movl   $0x1070fe,(%esp)
  101cb6:	e8 98 e6 ff ff       	call   100353 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbe:	8b 40 10             	mov    0x10(%eax),%eax
  101cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc5:	c7 04 24 0d 71 10 00 	movl   $0x10710d,(%esp)
  101ccc:	e8 82 e6 ff ff       	call   100353 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd4:	8b 40 14             	mov    0x14(%eax),%eax
  101cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cdb:	c7 04 24 1c 71 10 00 	movl   $0x10711c,(%esp)
  101ce2:	e8 6c e6 ff ff       	call   100353 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  101cea:	8b 40 18             	mov    0x18(%eax),%eax
  101ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf1:	c7 04 24 2b 71 10 00 	movl   $0x10712b,(%esp)
  101cf8:	e8 56 e6 ff ff       	call   100353 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  101d00:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d07:	c7 04 24 3a 71 10 00 	movl   $0x10713a,(%esp)
  101d0e:	e8 40 e6 ff ff       	call   100353 <cprintf>
}
  101d13:	c9                   	leave  
  101d14:	c3                   	ret    

00101d15 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d15:	55                   	push   %ebp
  101d16:	89 e5                	mov    %esp,%ebp
  101d18:	57                   	push   %edi
  101d19:	56                   	push   %esi
  101d1a:	53                   	push   %ebx
  101d1b:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
  101d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  101d21:	8b 40 30             	mov    0x30(%eax),%eax
  101d24:	83 f8 2f             	cmp    $0x2f,%eax
  101d27:	77 21                	ja     101d4a <trap_dispatch+0x35>
  101d29:	83 f8 2e             	cmp    $0x2e,%eax
  101d2c:	0f 83 ec 01 00 00    	jae    101f1e <trap_dispatch+0x209>
  101d32:	83 f8 21             	cmp    $0x21,%eax
  101d35:	0f 84 8a 00 00 00    	je     101dc5 <trap_dispatch+0xb0>
  101d3b:	83 f8 24             	cmp    $0x24,%eax
  101d3e:	74 5c                	je     101d9c <trap_dispatch+0x87>
  101d40:	83 f8 20             	cmp    $0x20,%eax
  101d43:	74 1c                	je     101d61 <trap_dispatch+0x4c>
  101d45:	e9 9c 01 00 00       	jmp    101ee6 <trap_dispatch+0x1d1>
  101d4a:	83 f8 78             	cmp    $0x78,%eax
  101d4d:	0f 84 9b 00 00 00    	je     101dee <trap_dispatch+0xd9>
  101d53:	83 f8 79             	cmp    $0x79,%eax
  101d56:	0f 84 11 01 00 00    	je     101e6d <trap_dispatch+0x158>
  101d5c:	e9 85 01 00 00       	jmp    101ee6 <trap_dispatch+0x1d1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101d61:	a1 2c cf 11 00       	mov    0x11cf2c,%eax
  101d66:	83 c0 01             	add    $0x1,%eax
  101d69:	a3 2c cf 11 00       	mov    %eax,0x11cf2c
        if (ticks % TICK_NUM == 0) {
  101d6e:	8b 0d 2c cf 11 00    	mov    0x11cf2c,%ecx
  101d74:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d79:	89 c8                	mov    %ecx,%eax
  101d7b:	f7 e2                	mul    %edx
  101d7d:	89 d0                	mov    %edx,%eax
  101d7f:	c1 e8 05             	shr    $0x5,%eax
  101d82:	6b c0 64             	imul   $0x64,%eax,%eax
  101d85:	29 c1                	sub    %eax,%ecx
  101d87:	89 c8                	mov    %ecx,%eax
  101d89:	85 c0                	test   %eax,%eax
  101d8b:	75 0a                	jne    101d97 <trap_dispatch+0x82>
            print_ticks();
  101d8d:	e8 10 fb ff ff       	call   1018a2 <print_ticks>
        }
        break;
  101d92:	e9 88 01 00 00       	jmp    101f1f <trap_dispatch+0x20a>
  101d97:	e9 83 01 00 00       	jmp    101f1f <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d9c:	e8 c5 f8 ff ff       	call   101666 <cons_getc>
  101da1:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101da4:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101da8:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101dac:	89 54 24 08          	mov    %edx,0x8(%esp)
  101db0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101db4:	c7 04 24 49 71 10 00 	movl   $0x107149,(%esp)
  101dbb:	e8 93 e5 ff ff       	call   100353 <cprintf>
        break;
  101dc0:	e9 5a 01 00 00       	jmp    101f1f <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101dc5:	e8 9c f8 ff ff       	call   101666 <cons_getc>
  101dca:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101dcd:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101dd1:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101dd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ddd:	c7 04 24 5b 71 10 00 	movl   $0x10715b,(%esp)
  101de4:	e8 6a e5 ff ff       	call   100353 <cprintf>
        break;
  101de9:	e9 31 01 00 00       	jmp    101f1f <trap_dispatch+0x20a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
		if (tf->tf_cs != USER_CS) {
  101dee:	8b 45 08             	mov    0x8(%ebp),%eax
  101df1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101df5:	66 83 f8 1b          	cmp    $0x1b,%ax
  101df9:	74 6d                	je     101e68 <trap_dispatch+0x153>
            switchk2u = *tf;
  101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfe:	ba 40 cf 11 00       	mov    $0x11cf40,%edx
  101e03:	89 c3                	mov    %eax,%ebx
  101e05:	b8 13 00 00 00       	mov    $0x13,%eax
  101e0a:	89 d7                	mov    %edx,%edi
  101e0c:	89 de                	mov    %ebx,%esi
  101e0e:	89 c1                	mov    %eax,%ecx
  101e10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101e12:	66 c7 05 7c cf 11 00 	movw   $0x1b,0x11cf7c
  101e19:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101e1b:	66 c7 05 88 cf 11 00 	movw   $0x23,0x11cf88
  101e22:	23 00 
  101e24:	0f b7 05 88 cf 11 00 	movzwl 0x11cf88,%eax
  101e2b:	66 a3 68 cf 11 00    	mov    %ax,0x11cf68
  101e31:	0f b7 05 68 cf 11 00 	movzwl 0x11cf68,%eax
  101e38:	66 a3 6c cf 11 00    	mov    %ax,0x11cf6c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  101e41:	83 c0 44             	add    $0x44,%eax
  101e44:	a3 84 cf 11 00       	mov    %eax,0x11cf84
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101e49:	a1 80 cf 11 00       	mov    0x11cf80,%eax
  101e4e:	80 cc 30             	or     $0x30,%ah
  101e51:	a3 80 cf 11 00       	mov    %eax,0x11cf80
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101e56:	8b 45 08             	mov    0x8(%ebp),%eax
  101e59:	8d 50 fc             	lea    -0x4(%eax),%edx
  101e5c:	b8 40 cf 11 00       	mov    $0x11cf40,%eax
  101e61:	89 02                	mov    %eax,(%edx)
        }
        break;
  101e63:	e9 b7 00 00 00       	jmp    101f1f <trap_dispatch+0x20a>
  101e68:	e9 b2 00 00 00       	jmp    101f1f <trap_dispatch+0x20a>
    case T_SWITCH_TOK:
		if (tf->tf_cs != KERNEL_CS) {
  101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e70:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e74:	66 83 f8 08          	cmp    $0x8,%ax
  101e78:	74 6a                	je     101ee4 <trap_dispatch+0x1cf>
            tf->tf_cs = KERNEL_CS;
  101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e7d:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101e83:	8b 45 08             	mov    0x8(%ebp),%eax
  101e86:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8f:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101e93:	8b 45 08             	mov    0x8(%ebp),%eax
  101e96:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9d:	8b 40 40             	mov    0x40(%eax),%eax
  101ea0:	80 e4 cf             	and    $0xcf,%ah
  101ea3:	89 c2                	mov    %eax,%edx
  101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea8:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101eab:	8b 45 08             	mov    0x8(%ebp),%eax
  101eae:	8b 40 44             	mov    0x44(%eax),%eax
  101eb1:	83 e8 44             	sub    $0x44,%eax
  101eb4:	a3 8c cf 11 00       	mov    %eax,0x11cf8c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101eb9:	a1 8c cf 11 00       	mov    0x11cf8c,%eax
  101ebe:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101ec5:	00 
  101ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  101ec9:	89 54 24 04          	mov    %edx,0x4(%esp)
  101ecd:	89 04 24             	mov    %eax,(%esp)
  101ed0:	e8 bd 4b 00 00       	call   106a92 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ed8:	8d 50 fc             	lea    -0x4(%eax),%edx
  101edb:	a1 8c cf 11 00       	mov    0x11cf8c,%eax
  101ee0:	89 02                	mov    %eax,(%edx)
        }
        break;
  101ee2:	eb 3b                	jmp    101f1f <trap_dispatch+0x20a>
  101ee4:	eb 39                	jmp    101f1f <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101eed:	0f b7 c0             	movzwl %ax,%eax
  101ef0:	83 e0 03             	and    $0x3,%eax
  101ef3:	85 c0                	test   %eax,%eax
  101ef5:	75 28                	jne    101f1f <trap_dispatch+0x20a>
            print_trapframe(tf);
  101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  101efa:	89 04 24             	mov    %eax,(%esp)
  101efd:	e8 97 fb ff ff       	call   101a99 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101f02:	c7 44 24 08 6a 71 10 	movl   $0x10716a,0x8(%esp)
  101f09:	00 
  101f0a:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  101f11:	00 
  101f12:	c7 04 24 8e 6f 10 00 	movl   $0x106f8e,(%esp)
  101f19:	e8 c9 ed ff ff       	call   100ce7 <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101f1e:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101f1f:	83 c4 2c             	add    $0x2c,%esp
  101f22:	5b                   	pop    %ebx
  101f23:	5e                   	pop    %esi
  101f24:	5f                   	pop    %edi
  101f25:	5d                   	pop    %ebp
  101f26:	c3                   	ret    

00101f27 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101f27:	55                   	push   %ebp
  101f28:	89 e5                	mov    %esp,%ebp
  101f2a:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  101f30:	89 04 24             	mov    %eax,(%esp)
  101f33:	e8 dd fd ff ff       	call   101d15 <trap_dispatch>
}
  101f38:	c9                   	leave  
  101f39:	c3                   	ret    

00101f3a <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101f3a:	1e                   	push   %ds
    pushl %es
  101f3b:	06                   	push   %es
    pushl %fs
  101f3c:	0f a0                	push   %fs
    pushl %gs
  101f3e:	0f a8                	push   %gs
    pushal
  101f40:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101f41:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101f46:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101f48:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101f4a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101f4b:	e8 d7 ff ff ff       	call   101f27 <trap>

    # pop the pushed stack pointer
    popl %esp
  101f50:	5c                   	pop    %esp

00101f51 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101f51:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101f52:	0f a9                	pop    %gs
    popl %fs
  101f54:	0f a1                	pop    %fs
    popl %es
  101f56:	07                   	pop    %es
    popl %ds
  101f57:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101f58:	83 c4 08             	add    $0x8,%esp
    iret
  101f5b:	cf                   	iret   

00101f5c <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f5c:	6a 00                	push   $0x0
  pushl $0
  101f5e:	6a 00                	push   $0x0
  jmp __alltraps
  101f60:	e9 d5 ff ff ff       	jmp    101f3a <__alltraps>

00101f65 <vector1>:
.globl vector1
vector1:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $1
  101f67:	6a 01                	push   $0x1
  jmp __alltraps
  101f69:	e9 cc ff ff ff       	jmp    101f3a <__alltraps>

00101f6e <vector2>:
.globl vector2
vector2:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $2
  101f70:	6a 02                	push   $0x2
  jmp __alltraps
  101f72:	e9 c3 ff ff ff       	jmp    101f3a <__alltraps>

00101f77 <vector3>:
.globl vector3
vector3:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $3
  101f79:	6a 03                	push   $0x3
  jmp __alltraps
  101f7b:	e9 ba ff ff ff       	jmp    101f3a <__alltraps>

00101f80 <vector4>:
.globl vector4
vector4:
  pushl $0
  101f80:	6a 00                	push   $0x0
  pushl $4
  101f82:	6a 04                	push   $0x4
  jmp __alltraps
  101f84:	e9 b1 ff ff ff       	jmp    101f3a <__alltraps>

00101f89 <vector5>:
.globl vector5
vector5:
  pushl $0
  101f89:	6a 00                	push   $0x0
  pushl $5
  101f8b:	6a 05                	push   $0x5
  jmp __alltraps
  101f8d:	e9 a8 ff ff ff       	jmp    101f3a <__alltraps>

00101f92 <vector6>:
.globl vector6
vector6:
  pushl $0
  101f92:	6a 00                	push   $0x0
  pushl $6
  101f94:	6a 06                	push   $0x6
  jmp __alltraps
  101f96:	e9 9f ff ff ff       	jmp    101f3a <__alltraps>

00101f9b <vector7>:
.globl vector7
vector7:
  pushl $0
  101f9b:	6a 00                	push   $0x0
  pushl $7
  101f9d:	6a 07                	push   $0x7
  jmp __alltraps
  101f9f:	e9 96 ff ff ff       	jmp    101f3a <__alltraps>

00101fa4 <vector8>:
.globl vector8
vector8:
  pushl $8
  101fa4:	6a 08                	push   $0x8
  jmp __alltraps
  101fa6:	e9 8f ff ff ff       	jmp    101f3a <__alltraps>

00101fab <vector9>:
.globl vector9
vector9:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $9
  101fad:	6a 09                	push   $0x9
  jmp __alltraps
  101faf:	e9 86 ff ff ff       	jmp    101f3a <__alltraps>

00101fb4 <vector10>:
.globl vector10
vector10:
  pushl $10
  101fb4:	6a 0a                	push   $0xa
  jmp __alltraps
  101fb6:	e9 7f ff ff ff       	jmp    101f3a <__alltraps>

00101fbb <vector11>:
.globl vector11
vector11:
  pushl $11
  101fbb:	6a 0b                	push   $0xb
  jmp __alltraps
  101fbd:	e9 78 ff ff ff       	jmp    101f3a <__alltraps>

00101fc2 <vector12>:
.globl vector12
vector12:
  pushl $12
  101fc2:	6a 0c                	push   $0xc
  jmp __alltraps
  101fc4:	e9 71 ff ff ff       	jmp    101f3a <__alltraps>

00101fc9 <vector13>:
.globl vector13
vector13:
  pushl $13
  101fc9:	6a 0d                	push   $0xd
  jmp __alltraps
  101fcb:	e9 6a ff ff ff       	jmp    101f3a <__alltraps>

00101fd0 <vector14>:
.globl vector14
vector14:
  pushl $14
  101fd0:	6a 0e                	push   $0xe
  jmp __alltraps
  101fd2:	e9 63 ff ff ff       	jmp    101f3a <__alltraps>

00101fd7 <vector15>:
.globl vector15
vector15:
  pushl $0
  101fd7:	6a 00                	push   $0x0
  pushl $15
  101fd9:	6a 0f                	push   $0xf
  jmp __alltraps
  101fdb:	e9 5a ff ff ff       	jmp    101f3a <__alltraps>

00101fe0 <vector16>:
.globl vector16
vector16:
  pushl $0
  101fe0:	6a 00                	push   $0x0
  pushl $16
  101fe2:	6a 10                	push   $0x10
  jmp __alltraps
  101fe4:	e9 51 ff ff ff       	jmp    101f3a <__alltraps>

00101fe9 <vector17>:
.globl vector17
vector17:
  pushl $17
  101fe9:	6a 11                	push   $0x11
  jmp __alltraps
  101feb:	e9 4a ff ff ff       	jmp    101f3a <__alltraps>

00101ff0 <vector18>:
.globl vector18
vector18:
  pushl $0
  101ff0:	6a 00                	push   $0x0
  pushl $18
  101ff2:	6a 12                	push   $0x12
  jmp __alltraps
  101ff4:	e9 41 ff ff ff       	jmp    101f3a <__alltraps>

00101ff9 <vector19>:
.globl vector19
vector19:
  pushl $0
  101ff9:	6a 00                	push   $0x0
  pushl $19
  101ffb:	6a 13                	push   $0x13
  jmp __alltraps
  101ffd:	e9 38 ff ff ff       	jmp    101f3a <__alltraps>

00102002 <vector20>:
.globl vector20
vector20:
  pushl $0
  102002:	6a 00                	push   $0x0
  pushl $20
  102004:	6a 14                	push   $0x14
  jmp __alltraps
  102006:	e9 2f ff ff ff       	jmp    101f3a <__alltraps>

0010200b <vector21>:
.globl vector21
vector21:
  pushl $0
  10200b:	6a 00                	push   $0x0
  pushl $21
  10200d:	6a 15                	push   $0x15
  jmp __alltraps
  10200f:	e9 26 ff ff ff       	jmp    101f3a <__alltraps>

00102014 <vector22>:
.globl vector22
vector22:
  pushl $0
  102014:	6a 00                	push   $0x0
  pushl $22
  102016:	6a 16                	push   $0x16
  jmp __alltraps
  102018:	e9 1d ff ff ff       	jmp    101f3a <__alltraps>

0010201d <vector23>:
.globl vector23
vector23:
  pushl $0
  10201d:	6a 00                	push   $0x0
  pushl $23
  10201f:	6a 17                	push   $0x17
  jmp __alltraps
  102021:	e9 14 ff ff ff       	jmp    101f3a <__alltraps>

00102026 <vector24>:
.globl vector24
vector24:
  pushl $0
  102026:	6a 00                	push   $0x0
  pushl $24
  102028:	6a 18                	push   $0x18
  jmp __alltraps
  10202a:	e9 0b ff ff ff       	jmp    101f3a <__alltraps>

0010202f <vector25>:
.globl vector25
vector25:
  pushl $0
  10202f:	6a 00                	push   $0x0
  pushl $25
  102031:	6a 19                	push   $0x19
  jmp __alltraps
  102033:	e9 02 ff ff ff       	jmp    101f3a <__alltraps>

00102038 <vector26>:
.globl vector26
vector26:
  pushl $0
  102038:	6a 00                	push   $0x0
  pushl $26
  10203a:	6a 1a                	push   $0x1a
  jmp __alltraps
  10203c:	e9 f9 fe ff ff       	jmp    101f3a <__alltraps>

00102041 <vector27>:
.globl vector27
vector27:
  pushl $0
  102041:	6a 00                	push   $0x0
  pushl $27
  102043:	6a 1b                	push   $0x1b
  jmp __alltraps
  102045:	e9 f0 fe ff ff       	jmp    101f3a <__alltraps>

0010204a <vector28>:
.globl vector28
vector28:
  pushl $0
  10204a:	6a 00                	push   $0x0
  pushl $28
  10204c:	6a 1c                	push   $0x1c
  jmp __alltraps
  10204e:	e9 e7 fe ff ff       	jmp    101f3a <__alltraps>

00102053 <vector29>:
.globl vector29
vector29:
  pushl $0
  102053:	6a 00                	push   $0x0
  pushl $29
  102055:	6a 1d                	push   $0x1d
  jmp __alltraps
  102057:	e9 de fe ff ff       	jmp    101f3a <__alltraps>

0010205c <vector30>:
.globl vector30
vector30:
  pushl $0
  10205c:	6a 00                	push   $0x0
  pushl $30
  10205e:	6a 1e                	push   $0x1e
  jmp __alltraps
  102060:	e9 d5 fe ff ff       	jmp    101f3a <__alltraps>

00102065 <vector31>:
.globl vector31
vector31:
  pushl $0
  102065:	6a 00                	push   $0x0
  pushl $31
  102067:	6a 1f                	push   $0x1f
  jmp __alltraps
  102069:	e9 cc fe ff ff       	jmp    101f3a <__alltraps>

0010206e <vector32>:
.globl vector32
vector32:
  pushl $0
  10206e:	6a 00                	push   $0x0
  pushl $32
  102070:	6a 20                	push   $0x20
  jmp __alltraps
  102072:	e9 c3 fe ff ff       	jmp    101f3a <__alltraps>

00102077 <vector33>:
.globl vector33
vector33:
  pushl $0
  102077:	6a 00                	push   $0x0
  pushl $33
  102079:	6a 21                	push   $0x21
  jmp __alltraps
  10207b:	e9 ba fe ff ff       	jmp    101f3a <__alltraps>

00102080 <vector34>:
.globl vector34
vector34:
  pushl $0
  102080:	6a 00                	push   $0x0
  pushl $34
  102082:	6a 22                	push   $0x22
  jmp __alltraps
  102084:	e9 b1 fe ff ff       	jmp    101f3a <__alltraps>

00102089 <vector35>:
.globl vector35
vector35:
  pushl $0
  102089:	6a 00                	push   $0x0
  pushl $35
  10208b:	6a 23                	push   $0x23
  jmp __alltraps
  10208d:	e9 a8 fe ff ff       	jmp    101f3a <__alltraps>

00102092 <vector36>:
.globl vector36
vector36:
  pushl $0
  102092:	6a 00                	push   $0x0
  pushl $36
  102094:	6a 24                	push   $0x24
  jmp __alltraps
  102096:	e9 9f fe ff ff       	jmp    101f3a <__alltraps>

0010209b <vector37>:
.globl vector37
vector37:
  pushl $0
  10209b:	6a 00                	push   $0x0
  pushl $37
  10209d:	6a 25                	push   $0x25
  jmp __alltraps
  10209f:	e9 96 fe ff ff       	jmp    101f3a <__alltraps>

001020a4 <vector38>:
.globl vector38
vector38:
  pushl $0
  1020a4:	6a 00                	push   $0x0
  pushl $38
  1020a6:	6a 26                	push   $0x26
  jmp __alltraps
  1020a8:	e9 8d fe ff ff       	jmp    101f3a <__alltraps>

001020ad <vector39>:
.globl vector39
vector39:
  pushl $0
  1020ad:	6a 00                	push   $0x0
  pushl $39
  1020af:	6a 27                	push   $0x27
  jmp __alltraps
  1020b1:	e9 84 fe ff ff       	jmp    101f3a <__alltraps>

001020b6 <vector40>:
.globl vector40
vector40:
  pushl $0
  1020b6:	6a 00                	push   $0x0
  pushl $40
  1020b8:	6a 28                	push   $0x28
  jmp __alltraps
  1020ba:	e9 7b fe ff ff       	jmp    101f3a <__alltraps>

001020bf <vector41>:
.globl vector41
vector41:
  pushl $0
  1020bf:	6a 00                	push   $0x0
  pushl $41
  1020c1:	6a 29                	push   $0x29
  jmp __alltraps
  1020c3:	e9 72 fe ff ff       	jmp    101f3a <__alltraps>

001020c8 <vector42>:
.globl vector42
vector42:
  pushl $0
  1020c8:	6a 00                	push   $0x0
  pushl $42
  1020ca:	6a 2a                	push   $0x2a
  jmp __alltraps
  1020cc:	e9 69 fe ff ff       	jmp    101f3a <__alltraps>

001020d1 <vector43>:
.globl vector43
vector43:
  pushl $0
  1020d1:	6a 00                	push   $0x0
  pushl $43
  1020d3:	6a 2b                	push   $0x2b
  jmp __alltraps
  1020d5:	e9 60 fe ff ff       	jmp    101f3a <__alltraps>

001020da <vector44>:
.globl vector44
vector44:
  pushl $0
  1020da:	6a 00                	push   $0x0
  pushl $44
  1020dc:	6a 2c                	push   $0x2c
  jmp __alltraps
  1020de:	e9 57 fe ff ff       	jmp    101f3a <__alltraps>

001020e3 <vector45>:
.globl vector45
vector45:
  pushl $0
  1020e3:	6a 00                	push   $0x0
  pushl $45
  1020e5:	6a 2d                	push   $0x2d
  jmp __alltraps
  1020e7:	e9 4e fe ff ff       	jmp    101f3a <__alltraps>

001020ec <vector46>:
.globl vector46
vector46:
  pushl $0
  1020ec:	6a 00                	push   $0x0
  pushl $46
  1020ee:	6a 2e                	push   $0x2e
  jmp __alltraps
  1020f0:	e9 45 fe ff ff       	jmp    101f3a <__alltraps>

001020f5 <vector47>:
.globl vector47
vector47:
  pushl $0
  1020f5:	6a 00                	push   $0x0
  pushl $47
  1020f7:	6a 2f                	push   $0x2f
  jmp __alltraps
  1020f9:	e9 3c fe ff ff       	jmp    101f3a <__alltraps>

001020fe <vector48>:
.globl vector48
vector48:
  pushl $0
  1020fe:	6a 00                	push   $0x0
  pushl $48
  102100:	6a 30                	push   $0x30
  jmp __alltraps
  102102:	e9 33 fe ff ff       	jmp    101f3a <__alltraps>

00102107 <vector49>:
.globl vector49
vector49:
  pushl $0
  102107:	6a 00                	push   $0x0
  pushl $49
  102109:	6a 31                	push   $0x31
  jmp __alltraps
  10210b:	e9 2a fe ff ff       	jmp    101f3a <__alltraps>

00102110 <vector50>:
.globl vector50
vector50:
  pushl $0
  102110:	6a 00                	push   $0x0
  pushl $50
  102112:	6a 32                	push   $0x32
  jmp __alltraps
  102114:	e9 21 fe ff ff       	jmp    101f3a <__alltraps>

00102119 <vector51>:
.globl vector51
vector51:
  pushl $0
  102119:	6a 00                	push   $0x0
  pushl $51
  10211b:	6a 33                	push   $0x33
  jmp __alltraps
  10211d:	e9 18 fe ff ff       	jmp    101f3a <__alltraps>

00102122 <vector52>:
.globl vector52
vector52:
  pushl $0
  102122:	6a 00                	push   $0x0
  pushl $52
  102124:	6a 34                	push   $0x34
  jmp __alltraps
  102126:	e9 0f fe ff ff       	jmp    101f3a <__alltraps>

0010212b <vector53>:
.globl vector53
vector53:
  pushl $0
  10212b:	6a 00                	push   $0x0
  pushl $53
  10212d:	6a 35                	push   $0x35
  jmp __alltraps
  10212f:	e9 06 fe ff ff       	jmp    101f3a <__alltraps>

00102134 <vector54>:
.globl vector54
vector54:
  pushl $0
  102134:	6a 00                	push   $0x0
  pushl $54
  102136:	6a 36                	push   $0x36
  jmp __alltraps
  102138:	e9 fd fd ff ff       	jmp    101f3a <__alltraps>

0010213d <vector55>:
.globl vector55
vector55:
  pushl $0
  10213d:	6a 00                	push   $0x0
  pushl $55
  10213f:	6a 37                	push   $0x37
  jmp __alltraps
  102141:	e9 f4 fd ff ff       	jmp    101f3a <__alltraps>

00102146 <vector56>:
.globl vector56
vector56:
  pushl $0
  102146:	6a 00                	push   $0x0
  pushl $56
  102148:	6a 38                	push   $0x38
  jmp __alltraps
  10214a:	e9 eb fd ff ff       	jmp    101f3a <__alltraps>

0010214f <vector57>:
.globl vector57
vector57:
  pushl $0
  10214f:	6a 00                	push   $0x0
  pushl $57
  102151:	6a 39                	push   $0x39
  jmp __alltraps
  102153:	e9 e2 fd ff ff       	jmp    101f3a <__alltraps>

00102158 <vector58>:
.globl vector58
vector58:
  pushl $0
  102158:	6a 00                	push   $0x0
  pushl $58
  10215a:	6a 3a                	push   $0x3a
  jmp __alltraps
  10215c:	e9 d9 fd ff ff       	jmp    101f3a <__alltraps>

00102161 <vector59>:
.globl vector59
vector59:
  pushl $0
  102161:	6a 00                	push   $0x0
  pushl $59
  102163:	6a 3b                	push   $0x3b
  jmp __alltraps
  102165:	e9 d0 fd ff ff       	jmp    101f3a <__alltraps>

0010216a <vector60>:
.globl vector60
vector60:
  pushl $0
  10216a:	6a 00                	push   $0x0
  pushl $60
  10216c:	6a 3c                	push   $0x3c
  jmp __alltraps
  10216e:	e9 c7 fd ff ff       	jmp    101f3a <__alltraps>

00102173 <vector61>:
.globl vector61
vector61:
  pushl $0
  102173:	6a 00                	push   $0x0
  pushl $61
  102175:	6a 3d                	push   $0x3d
  jmp __alltraps
  102177:	e9 be fd ff ff       	jmp    101f3a <__alltraps>

0010217c <vector62>:
.globl vector62
vector62:
  pushl $0
  10217c:	6a 00                	push   $0x0
  pushl $62
  10217e:	6a 3e                	push   $0x3e
  jmp __alltraps
  102180:	e9 b5 fd ff ff       	jmp    101f3a <__alltraps>

00102185 <vector63>:
.globl vector63
vector63:
  pushl $0
  102185:	6a 00                	push   $0x0
  pushl $63
  102187:	6a 3f                	push   $0x3f
  jmp __alltraps
  102189:	e9 ac fd ff ff       	jmp    101f3a <__alltraps>

0010218e <vector64>:
.globl vector64
vector64:
  pushl $0
  10218e:	6a 00                	push   $0x0
  pushl $64
  102190:	6a 40                	push   $0x40
  jmp __alltraps
  102192:	e9 a3 fd ff ff       	jmp    101f3a <__alltraps>

00102197 <vector65>:
.globl vector65
vector65:
  pushl $0
  102197:	6a 00                	push   $0x0
  pushl $65
  102199:	6a 41                	push   $0x41
  jmp __alltraps
  10219b:	e9 9a fd ff ff       	jmp    101f3a <__alltraps>

001021a0 <vector66>:
.globl vector66
vector66:
  pushl $0
  1021a0:	6a 00                	push   $0x0
  pushl $66
  1021a2:	6a 42                	push   $0x42
  jmp __alltraps
  1021a4:	e9 91 fd ff ff       	jmp    101f3a <__alltraps>

001021a9 <vector67>:
.globl vector67
vector67:
  pushl $0
  1021a9:	6a 00                	push   $0x0
  pushl $67
  1021ab:	6a 43                	push   $0x43
  jmp __alltraps
  1021ad:	e9 88 fd ff ff       	jmp    101f3a <__alltraps>

001021b2 <vector68>:
.globl vector68
vector68:
  pushl $0
  1021b2:	6a 00                	push   $0x0
  pushl $68
  1021b4:	6a 44                	push   $0x44
  jmp __alltraps
  1021b6:	e9 7f fd ff ff       	jmp    101f3a <__alltraps>

001021bb <vector69>:
.globl vector69
vector69:
  pushl $0
  1021bb:	6a 00                	push   $0x0
  pushl $69
  1021bd:	6a 45                	push   $0x45
  jmp __alltraps
  1021bf:	e9 76 fd ff ff       	jmp    101f3a <__alltraps>

001021c4 <vector70>:
.globl vector70
vector70:
  pushl $0
  1021c4:	6a 00                	push   $0x0
  pushl $70
  1021c6:	6a 46                	push   $0x46
  jmp __alltraps
  1021c8:	e9 6d fd ff ff       	jmp    101f3a <__alltraps>

001021cd <vector71>:
.globl vector71
vector71:
  pushl $0
  1021cd:	6a 00                	push   $0x0
  pushl $71
  1021cf:	6a 47                	push   $0x47
  jmp __alltraps
  1021d1:	e9 64 fd ff ff       	jmp    101f3a <__alltraps>

001021d6 <vector72>:
.globl vector72
vector72:
  pushl $0
  1021d6:	6a 00                	push   $0x0
  pushl $72
  1021d8:	6a 48                	push   $0x48
  jmp __alltraps
  1021da:	e9 5b fd ff ff       	jmp    101f3a <__alltraps>

001021df <vector73>:
.globl vector73
vector73:
  pushl $0
  1021df:	6a 00                	push   $0x0
  pushl $73
  1021e1:	6a 49                	push   $0x49
  jmp __alltraps
  1021e3:	e9 52 fd ff ff       	jmp    101f3a <__alltraps>

001021e8 <vector74>:
.globl vector74
vector74:
  pushl $0
  1021e8:	6a 00                	push   $0x0
  pushl $74
  1021ea:	6a 4a                	push   $0x4a
  jmp __alltraps
  1021ec:	e9 49 fd ff ff       	jmp    101f3a <__alltraps>

001021f1 <vector75>:
.globl vector75
vector75:
  pushl $0
  1021f1:	6a 00                	push   $0x0
  pushl $75
  1021f3:	6a 4b                	push   $0x4b
  jmp __alltraps
  1021f5:	e9 40 fd ff ff       	jmp    101f3a <__alltraps>

001021fa <vector76>:
.globl vector76
vector76:
  pushl $0
  1021fa:	6a 00                	push   $0x0
  pushl $76
  1021fc:	6a 4c                	push   $0x4c
  jmp __alltraps
  1021fe:	e9 37 fd ff ff       	jmp    101f3a <__alltraps>

00102203 <vector77>:
.globl vector77
vector77:
  pushl $0
  102203:	6a 00                	push   $0x0
  pushl $77
  102205:	6a 4d                	push   $0x4d
  jmp __alltraps
  102207:	e9 2e fd ff ff       	jmp    101f3a <__alltraps>

0010220c <vector78>:
.globl vector78
vector78:
  pushl $0
  10220c:	6a 00                	push   $0x0
  pushl $78
  10220e:	6a 4e                	push   $0x4e
  jmp __alltraps
  102210:	e9 25 fd ff ff       	jmp    101f3a <__alltraps>

00102215 <vector79>:
.globl vector79
vector79:
  pushl $0
  102215:	6a 00                	push   $0x0
  pushl $79
  102217:	6a 4f                	push   $0x4f
  jmp __alltraps
  102219:	e9 1c fd ff ff       	jmp    101f3a <__alltraps>

0010221e <vector80>:
.globl vector80
vector80:
  pushl $0
  10221e:	6a 00                	push   $0x0
  pushl $80
  102220:	6a 50                	push   $0x50
  jmp __alltraps
  102222:	e9 13 fd ff ff       	jmp    101f3a <__alltraps>

00102227 <vector81>:
.globl vector81
vector81:
  pushl $0
  102227:	6a 00                	push   $0x0
  pushl $81
  102229:	6a 51                	push   $0x51
  jmp __alltraps
  10222b:	e9 0a fd ff ff       	jmp    101f3a <__alltraps>

00102230 <vector82>:
.globl vector82
vector82:
  pushl $0
  102230:	6a 00                	push   $0x0
  pushl $82
  102232:	6a 52                	push   $0x52
  jmp __alltraps
  102234:	e9 01 fd ff ff       	jmp    101f3a <__alltraps>

00102239 <vector83>:
.globl vector83
vector83:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $83
  10223b:	6a 53                	push   $0x53
  jmp __alltraps
  10223d:	e9 f8 fc ff ff       	jmp    101f3a <__alltraps>

00102242 <vector84>:
.globl vector84
vector84:
  pushl $0
  102242:	6a 00                	push   $0x0
  pushl $84
  102244:	6a 54                	push   $0x54
  jmp __alltraps
  102246:	e9 ef fc ff ff       	jmp    101f3a <__alltraps>

0010224b <vector85>:
.globl vector85
vector85:
  pushl $0
  10224b:	6a 00                	push   $0x0
  pushl $85
  10224d:	6a 55                	push   $0x55
  jmp __alltraps
  10224f:	e9 e6 fc ff ff       	jmp    101f3a <__alltraps>

00102254 <vector86>:
.globl vector86
vector86:
  pushl $0
  102254:	6a 00                	push   $0x0
  pushl $86
  102256:	6a 56                	push   $0x56
  jmp __alltraps
  102258:	e9 dd fc ff ff       	jmp    101f3a <__alltraps>

0010225d <vector87>:
.globl vector87
vector87:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $87
  10225f:	6a 57                	push   $0x57
  jmp __alltraps
  102261:	e9 d4 fc ff ff       	jmp    101f3a <__alltraps>

00102266 <vector88>:
.globl vector88
vector88:
  pushl $0
  102266:	6a 00                	push   $0x0
  pushl $88
  102268:	6a 58                	push   $0x58
  jmp __alltraps
  10226a:	e9 cb fc ff ff       	jmp    101f3a <__alltraps>

0010226f <vector89>:
.globl vector89
vector89:
  pushl $0
  10226f:	6a 00                	push   $0x0
  pushl $89
  102271:	6a 59                	push   $0x59
  jmp __alltraps
  102273:	e9 c2 fc ff ff       	jmp    101f3a <__alltraps>

00102278 <vector90>:
.globl vector90
vector90:
  pushl $0
  102278:	6a 00                	push   $0x0
  pushl $90
  10227a:	6a 5a                	push   $0x5a
  jmp __alltraps
  10227c:	e9 b9 fc ff ff       	jmp    101f3a <__alltraps>

00102281 <vector91>:
.globl vector91
vector91:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $91
  102283:	6a 5b                	push   $0x5b
  jmp __alltraps
  102285:	e9 b0 fc ff ff       	jmp    101f3a <__alltraps>

0010228a <vector92>:
.globl vector92
vector92:
  pushl $0
  10228a:	6a 00                	push   $0x0
  pushl $92
  10228c:	6a 5c                	push   $0x5c
  jmp __alltraps
  10228e:	e9 a7 fc ff ff       	jmp    101f3a <__alltraps>

00102293 <vector93>:
.globl vector93
vector93:
  pushl $0
  102293:	6a 00                	push   $0x0
  pushl $93
  102295:	6a 5d                	push   $0x5d
  jmp __alltraps
  102297:	e9 9e fc ff ff       	jmp    101f3a <__alltraps>

0010229c <vector94>:
.globl vector94
vector94:
  pushl $0
  10229c:	6a 00                	push   $0x0
  pushl $94
  10229e:	6a 5e                	push   $0x5e
  jmp __alltraps
  1022a0:	e9 95 fc ff ff       	jmp    101f3a <__alltraps>

001022a5 <vector95>:
.globl vector95
vector95:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $95
  1022a7:	6a 5f                	push   $0x5f
  jmp __alltraps
  1022a9:	e9 8c fc ff ff       	jmp    101f3a <__alltraps>

001022ae <vector96>:
.globl vector96
vector96:
  pushl $0
  1022ae:	6a 00                	push   $0x0
  pushl $96
  1022b0:	6a 60                	push   $0x60
  jmp __alltraps
  1022b2:	e9 83 fc ff ff       	jmp    101f3a <__alltraps>

001022b7 <vector97>:
.globl vector97
vector97:
  pushl $0
  1022b7:	6a 00                	push   $0x0
  pushl $97
  1022b9:	6a 61                	push   $0x61
  jmp __alltraps
  1022bb:	e9 7a fc ff ff       	jmp    101f3a <__alltraps>

001022c0 <vector98>:
.globl vector98
vector98:
  pushl $0
  1022c0:	6a 00                	push   $0x0
  pushl $98
  1022c2:	6a 62                	push   $0x62
  jmp __alltraps
  1022c4:	e9 71 fc ff ff       	jmp    101f3a <__alltraps>

001022c9 <vector99>:
.globl vector99
vector99:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $99
  1022cb:	6a 63                	push   $0x63
  jmp __alltraps
  1022cd:	e9 68 fc ff ff       	jmp    101f3a <__alltraps>

001022d2 <vector100>:
.globl vector100
vector100:
  pushl $0
  1022d2:	6a 00                	push   $0x0
  pushl $100
  1022d4:	6a 64                	push   $0x64
  jmp __alltraps
  1022d6:	e9 5f fc ff ff       	jmp    101f3a <__alltraps>

001022db <vector101>:
.globl vector101
vector101:
  pushl $0
  1022db:	6a 00                	push   $0x0
  pushl $101
  1022dd:	6a 65                	push   $0x65
  jmp __alltraps
  1022df:	e9 56 fc ff ff       	jmp    101f3a <__alltraps>

001022e4 <vector102>:
.globl vector102
vector102:
  pushl $0
  1022e4:	6a 00                	push   $0x0
  pushl $102
  1022e6:	6a 66                	push   $0x66
  jmp __alltraps
  1022e8:	e9 4d fc ff ff       	jmp    101f3a <__alltraps>

001022ed <vector103>:
.globl vector103
vector103:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $103
  1022ef:	6a 67                	push   $0x67
  jmp __alltraps
  1022f1:	e9 44 fc ff ff       	jmp    101f3a <__alltraps>

001022f6 <vector104>:
.globl vector104
vector104:
  pushl $0
  1022f6:	6a 00                	push   $0x0
  pushl $104
  1022f8:	6a 68                	push   $0x68
  jmp __alltraps
  1022fa:	e9 3b fc ff ff       	jmp    101f3a <__alltraps>

001022ff <vector105>:
.globl vector105
vector105:
  pushl $0
  1022ff:	6a 00                	push   $0x0
  pushl $105
  102301:	6a 69                	push   $0x69
  jmp __alltraps
  102303:	e9 32 fc ff ff       	jmp    101f3a <__alltraps>

00102308 <vector106>:
.globl vector106
vector106:
  pushl $0
  102308:	6a 00                	push   $0x0
  pushl $106
  10230a:	6a 6a                	push   $0x6a
  jmp __alltraps
  10230c:	e9 29 fc ff ff       	jmp    101f3a <__alltraps>

00102311 <vector107>:
.globl vector107
vector107:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $107
  102313:	6a 6b                	push   $0x6b
  jmp __alltraps
  102315:	e9 20 fc ff ff       	jmp    101f3a <__alltraps>

0010231a <vector108>:
.globl vector108
vector108:
  pushl $0
  10231a:	6a 00                	push   $0x0
  pushl $108
  10231c:	6a 6c                	push   $0x6c
  jmp __alltraps
  10231e:	e9 17 fc ff ff       	jmp    101f3a <__alltraps>

00102323 <vector109>:
.globl vector109
vector109:
  pushl $0
  102323:	6a 00                	push   $0x0
  pushl $109
  102325:	6a 6d                	push   $0x6d
  jmp __alltraps
  102327:	e9 0e fc ff ff       	jmp    101f3a <__alltraps>

0010232c <vector110>:
.globl vector110
vector110:
  pushl $0
  10232c:	6a 00                	push   $0x0
  pushl $110
  10232e:	6a 6e                	push   $0x6e
  jmp __alltraps
  102330:	e9 05 fc ff ff       	jmp    101f3a <__alltraps>

00102335 <vector111>:
.globl vector111
vector111:
  pushl $0
  102335:	6a 00                	push   $0x0
  pushl $111
  102337:	6a 6f                	push   $0x6f
  jmp __alltraps
  102339:	e9 fc fb ff ff       	jmp    101f3a <__alltraps>

0010233e <vector112>:
.globl vector112
vector112:
  pushl $0
  10233e:	6a 00                	push   $0x0
  pushl $112
  102340:	6a 70                	push   $0x70
  jmp __alltraps
  102342:	e9 f3 fb ff ff       	jmp    101f3a <__alltraps>

00102347 <vector113>:
.globl vector113
vector113:
  pushl $0
  102347:	6a 00                	push   $0x0
  pushl $113
  102349:	6a 71                	push   $0x71
  jmp __alltraps
  10234b:	e9 ea fb ff ff       	jmp    101f3a <__alltraps>

00102350 <vector114>:
.globl vector114
vector114:
  pushl $0
  102350:	6a 00                	push   $0x0
  pushl $114
  102352:	6a 72                	push   $0x72
  jmp __alltraps
  102354:	e9 e1 fb ff ff       	jmp    101f3a <__alltraps>

00102359 <vector115>:
.globl vector115
vector115:
  pushl $0
  102359:	6a 00                	push   $0x0
  pushl $115
  10235b:	6a 73                	push   $0x73
  jmp __alltraps
  10235d:	e9 d8 fb ff ff       	jmp    101f3a <__alltraps>

00102362 <vector116>:
.globl vector116
vector116:
  pushl $0
  102362:	6a 00                	push   $0x0
  pushl $116
  102364:	6a 74                	push   $0x74
  jmp __alltraps
  102366:	e9 cf fb ff ff       	jmp    101f3a <__alltraps>

0010236b <vector117>:
.globl vector117
vector117:
  pushl $0
  10236b:	6a 00                	push   $0x0
  pushl $117
  10236d:	6a 75                	push   $0x75
  jmp __alltraps
  10236f:	e9 c6 fb ff ff       	jmp    101f3a <__alltraps>

00102374 <vector118>:
.globl vector118
vector118:
  pushl $0
  102374:	6a 00                	push   $0x0
  pushl $118
  102376:	6a 76                	push   $0x76
  jmp __alltraps
  102378:	e9 bd fb ff ff       	jmp    101f3a <__alltraps>

0010237d <vector119>:
.globl vector119
vector119:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $119
  10237f:	6a 77                	push   $0x77
  jmp __alltraps
  102381:	e9 b4 fb ff ff       	jmp    101f3a <__alltraps>

00102386 <vector120>:
.globl vector120
vector120:
  pushl $0
  102386:	6a 00                	push   $0x0
  pushl $120
  102388:	6a 78                	push   $0x78
  jmp __alltraps
  10238a:	e9 ab fb ff ff       	jmp    101f3a <__alltraps>

0010238f <vector121>:
.globl vector121
vector121:
  pushl $0
  10238f:	6a 00                	push   $0x0
  pushl $121
  102391:	6a 79                	push   $0x79
  jmp __alltraps
  102393:	e9 a2 fb ff ff       	jmp    101f3a <__alltraps>

00102398 <vector122>:
.globl vector122
vector122:
  pushl $0
  102398:	6a 00                	push   $0x0
  pushl $122
  10239a:	6a 7a                	push   $0x7a
  jmp __alltraps
  10239c:	e9 99 fb ff ff       	jmp    101f3a <__alltraps>

001023a1 <vector123>:
.globl vector123
vector123:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $123
  1023a3:	6a 7b                	push   $0x7b
  jmp __alltraps
  1023a5:	e9 90 fb ff ff       	jmp    101f3a <__alltraps>

001023aa <vector124>:
.globl vector124
vector124:
  pushl $0
  1023aa:	6a 00                	push   $0x0
  pushl $124
  1023ac:	6a 7c                	push   $0x7c
  jmp __alltraps
  1023ae:	e9 87 fb ff ff       	jmp    101f3a <__alltraps>

001023b3 <vector125>:
.globl vector125
vector125:
  pushl $0
  1023b3:	6a 00                	push   $0x0
  pushl $125
  1023b5:	6a 7d                	push   $0x7d
  jmp __alltraps
  1023b7:	e9 7e fb ff ff       	jmp    101f3a <__alltraps>

001023bc <vector126>:
.globl vector126
vector126:
  pushl $0
  1023bc:	6a 00                	push   $0x0
  pushl $126
  1023be:	6a 7e                	push   $0x7e
  jmp __alltraps
  1023c0:	e9 75 fb ff ff       	jmp    101f3a <__alltraps>

001023c5 <vector127>:
.globl vector127
vector127:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $127
  1023c7:	6a 7f                	push   $0x7f
  jmp __alltraps
  1023c9:	e9 6c fb ff ff       	jmp    101f3a <__alltraps>

001023ce <vector128>:
.globl vector128
vector128:
  pushl $0
  1023ce:	6a 00                	push   $0x0
  pushl $128
  1023d0:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1023d5:	e9 60 fb ff ff       	jmp    101f3a <__alltraps>

001023da <vector129>:
.globl vector129
vector129:
  pushl $0
  1023da:	6a 00                	push   $0x0
  pushl $129
  1023dc:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1023e1:	e9 54 fb ff ff       	jmp    101f3a <__alltraps>

001023e6 <vector130>:
.globl vector130
vector130:
  pushl $0
  1023e6:	6a 00                	push   $0x0
  pushl $130
  1023e8:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1023ed:	e9 48 fb ff ff       	jmp    101f3a <__alltraps>

001023f2 <vector131>:
.globl vector131
vector131:
  pushl $0
  1023f2:	6a 00                	push   $0x0
  pushl $131
  1023f4:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1023f9:	e9 3c fb ff ff       	jmp    101f3a <__alltraps>

001023fe <vector132>:
.globl vector132
vector132:
  pushl $0
  1023fe:	6a 00                	push   $0x0
  pushl $132
  102400:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102405:	e9 30 fb ff ff       	jmp    101f3a <__alltraps>

0010240a <vector133>:
.globl vector133
vector133:
  pushl $0
  10240a:	6a 00                	push   $0x0
  pushl $133
  10240c:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102411:	e9 24 fb ff ff       	jmp    101f3a <__alltraps>

00102416 <vector134>:
.globl vector134
vector134:
  pushl $0
  102416:	6a 00                	push   $0x0
  pushl $134
  102418:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10241d:	e9 18 fb ff ff       	jmp    101f3a <__alltraps>

00102422 <vector135>:
.globl vector135
vector135:
  pushl $0
  102422:	6a 00                	push   $0x0
  pushl $135
  102424:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102429:	e9 0c fb ff ff       	jmp    101f3a <__alltraps>

0010242e <vector136>:
.globl vector136
vector136:
  pushl $0
  10242e:	6a 00                	push   $0x0
  pushl $136
  102430:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102435:	e9 00 fb ff ff       	jmp    101f3a <__alltraps>

0010243a <vector137>:
.globl vector137
vector137:
  pushl $0
  10243a:	6a 00                	push   $0x0
  pushl $137
  10243c:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102441:	e9 f4 fa ff ff       	jmp    101f3a <__alltraps>

00102446 <vector138>:
.globl vector138
vector138:
  pushl $0
  102446:	6a 00                	push   $0x0
  pushl $138
  102448:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  10244d:	e9 e8 fa ff ff       	jmp    101f3a <__alltraps>

00102452 <vector139>:
.globl vector139
vector139:
  pushl $0
  102452:	6a 00                	push   $0x0
  pushl $139
  102454:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102459:	e9 dc fa ff ff       	jmp    101f3a <__alltraps>

0010245e <vector140>:
.globl vector140
vector140:
  pushl $0
  10245e:	6a 00                	push   $0x0
  pushl $140
  102460:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102465:	e9 d0 fa ff ff       	jmp    101f3a <__alltraps>

0010246a <vector141>:
.globl vector141
vector141:
  pushl $0
  10246a:	6a 00                	push   $0x0
  pushl $141
  10246c:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102471:	e9 c4 fa ff ff       	jmp    101f3a <__alltraps>

00102476 <vector142>:
.globl vector142
vector142:
  pushl $0
  102476:	6a 00                	push   $0x0
  pushl $142
  102478:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10247d:	e9 b8 fa ff ff       	jmp    101f3a <__alltraps>

00102482 <vector143>:
.globl vector143
vector143:
  pushl $0
  102482:	6a 00                	push   $0x0
  pushl $143
  102484:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102489:	e9 ac fa ff ff       	jmp    101f3a <__alltraps>

0010248e <vector144>:
.globl vector144
vector144:
  pushl $0
  10248e:	6a 00                	push   $0x0
  pushl $144
  102490:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102495:	e9 a0 fa ff ff       	jmp    101f3a <__alltraps>

0010249a <vector145>:
.globl vector145
vector145:
  pushl $0
  10249a:	6a 00                	push   $0x0
  pushl $145
  10249c:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1024a1:	e9 94 fa ff ff       	jmp    101f3a <__alltraps>

001024a6 <vector146>:
.globl vector146
vector146:
  pushl $0
  1024a6:	6a 00                	push   $0x0
  pushl $146
  1024a8:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1024ad:	e9 88 fa ff ff       	jmp    101f3a <__alltraps>

001024b2 <vector147>:
.globl vector147
vector147:
  pushl $0
  1024b2:	6a 00                	push   $0x0
  pushl $147
  1024b4:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1024b9:	e9 7c fa ff ff       	jmp    101f3a <__alltraps>

001024be <vector148>:
.globl vector148
vector148:
  pushl $0
  1024be:	6a 00                	push   $0x0
  pushl $148
  1024c0:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1024c5:	e9 70 fa ff ff       	jmp    101f3a <__alltraps>

001024ca <vector149>:
.globl vector149
vector149:
  pushl $0
  1024ca:	6a 00                	push   $0x0
  pushl $149
  1024cc:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1024d1:	e9 64 fa ff ff       	jmp    101f3a <__alltraps>

001024d6 <vector150>:
.globl vector150
vector150:
  pushl $0
  1024d6:	6a 00                	push   $0x0
  pushl $150
  1024d8:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1024dd:	e9 58 fa ff ff       	jmp    101f3a <__alltraps>

001024e2 <vector151>:
.globl vector151
vector151:
  pushl $0
  1024e2:	6a 00                	push   $0x0
  pushl $151
  1024e4:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1024e9:	e9 4c fa ff ff       	jmp    101f3a <__alltraps>

001024ee <vector152>:
.globl vector152
vector152:
  pushl $0
  1024ee:	6a 00                	push   $0x0
  pushl $152
  1024f0:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1024f5:	e9 40 fa ff ff       	jmp    101f3a <__alltraps>

001024fa <vector153>:
.globl vector153
vector153:
  pushl $0
  1024fa:	6a 00                	push   $0x0
  pushl $153
  1024fc:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102501:	e9 34 fa ff ff       	jmp    101f3a <__alltraps>

00102506 <vector154>:
.globl vector154
vector154:
  pushl $0
  102506:	6a 00                	push   $0x0
  pushl $154
  102508:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10250d:	e9 28 fa ff ff       	jmp    101f3a <__alltraps>

00102512 <vector155>:
.globl vector155
vector155:
  pushl $0
  102512:	6a 00                	push   $0x0
  pushl $155
  102514:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102519:	e9 1c fa ff ff       	jmp    101f3a <__alltraps>

0010251e <vector156>:
.globl vector156
vector156:
  pushl $0
  10251e:	6a 00                	push   $0x0
  pushl $156
  102520:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102525:	e9 10 fa ff ff       	jmp    101f3a <__alltraps>

0010252a <vector157>:
.globl vector157
vector157:
  pushl $0
  10252a:	6a 00                	push   $0x0
  pushl $157
  10252c:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102531:	e9 04 fa ff ff       	jmp    101f3a <__alltraps>

00102536 <vector158>:
.globl vector158
vector158:
  pushl $0
  102536:	6a 00                	push   $0x0
  pushl $158
  102538:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  10253d:	e9 f8 f9 ff ff       	jmp    101f3a <__alltraps>

00102542 <vector159>:
.globl vector159
vector159:
  pushl $0
  102542:	6a 00                	push   $0x0
  pushl $159
  102544:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102549:	e9 ec f9 ff ff       	jmp    101f3a <__alltraps>

0010254e <vector160>:
.globl vector160
vector160:
  pushl $0
  10254e:	6a 00                	push   $0x0
  pushl $160
  102550:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102555:	e9 e0 f9 ff ff       	jmp    101f3a <__alltraps>

0010255a <vector161>:
.globl vector161
vector161:
  pushl $0
  10255a:	6a 00                	push   $0x0
  pushl $161
  10255c:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102561:	e9 d4 f9 ff ff       	jmp    101f3a <__alltraps>

00102566 <vector162>:
.globl vector162
vector162:
  pushl $0
  102566:	6a 00                	push   $0x0
  pushl $162
  102568:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10256d:	e9 c8 f9 ff ff       	jmp    101f3a <__alltraps>

00102572 <vector163>:
.globl vector163
vector163:
  pushl $0
  102572:	6a 00                	push   $0x0
  pushl $163
  102574:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102579:	e9 bc f9 ff ff       	jmp    101f3a <__alltraps>

0010257e <vector164>:
.globl vector164
vector164:
  pushl $0
  10257e:	6a 00                	push   $0x0
  pushl $164
  102580:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102585:	e9 b0 f9 ff ff       	jmp    101f3a <__alltraps>

0010258a <vector165>:
.globl vector165
vector165:
  pushl $0
  10258a:	6a 00                	push   $0x0
  pushl $165
  10258c:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102591:	e9 a4 f9 ff ff       	jmp    101f3a <__alltraps>

00102596 <vector166>:
.globl vector166
vector166:
  pushl $0
  102596:	6a 00                	push   $0x0
  pushl $166
  102598:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10259d:	e9 98 f9 ff ff       	jmp    101f3a <__alltraps>

001025a2 <vector167>:
.globl vector167
vector167:
  pushl $0
  1025a2:	6a 00                	push   $0x0
  pushl $167
  1025a4:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1025a9:	e9 8c f9 ff ff       	jmp    101f3a <__alltraps>

001025ae <vector168>:
.globl vector168
vector168:
  pushl $0
  1025ae:	6a 00                	push   $0x0
  pushl $168
  1025b0:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1025b5:	e9 80 f9 ff ff       	jmp    101f3a <__alltraps>

001025ba <vector169>:
.globl vector169
vector169:
  pushl $0
  1025ba:	6a 00                	push   $0x0
  pushl $169
  1025bc:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1025c1:	e9 74 f9 ff ff       	jmp    101f3a <__alltraps>

001025c6 <vector170>:
.globl vector170
vector170:
  pushl $0
  1025c6:	6a 00                	push   $0x0
  pushl $170
  1025c8:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1025cd:	e9 68 f9 ff ff       	jmp    101f3a <__alltraps>

001025d2 <vector171>:
.globl vector171
vector171:
  pushl $0
  1025d2:	6a 00                	push   $0x0
  pushl $171
  1025d4:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1025d9:	e9 5c f9 ff ff       	jmp    101f3a <__alltraps>

001025de <vector172>:
.globl vector172
vector172:
  pushl $0
  1025de:	6a 00                	push   $0x0
  pushl $172
  1025e0:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1025e5:	e9 50 f9 ff ff       	jmp    101f3a <__alltraps>

001025ea <vector173>:
.globl vector173
vector173:
  pushl $0
  1025ea:	6a 00                	push   $0x0
  pushl $173
  1025ec:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1025f1:	e9 44 f9 ff ff       	jmp    101f3a <__alltraps>

001025f6 <vector174>:
.globl vector174
vector174:
  pushl $0
  1025f6:	6a 00                	push   $0x0
  pushl $174
  1025f8:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1025fd:	e9 38 f9 ff ff       	jmp    101f3a <__alltraps>

00102602 <vector175>:
.globl vector175
vector175:
  pushl $0
  102602:	6a 00                	push   $0x0
  pushl $175
  102604:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102609:	e9 2c f9 ff ff       	jmp    101f3a <__alltraps>

0010260e <vector176>:
.globl vector176
vector176:
  pushl $0
  10260e:	6a 00                	push   $0x0
  pushl $176
  102610:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102615:	e9 20 f9 ff ff       	jmp    101f3a <__alltraps>

0010261a <vector177>:
.globl vector177
vector177:
  pushl $0
  10261a:	6a 00                	push   $0x0
  pushl $177
  10261c:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102621:	e9 14 f9 ff ff       	jmp    101f3a <__alltraps>

00102626 <vector178>:
.globl vector178
vector178:
  pushl $0
  102626:	6a 00                	push   $0x0
  pushl $178
  102628:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10262d:	e9 08 f9 ff ff       	jmp    101f3a <__alltraps>

00102632 <vector179>:
.globl vector179
vector179:
  pushl $0
  102632:	6a 00                	push   $0x0
  pushl $179
  102634:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102639:	e9 fc f8 ff ff       	jmp    101f3a <__alltraps>

0010263e <vector180>:
.globl vector180
vector180:
  pushl $0
  10263e:	6a 00                	push   $0x0
  pushl $180
  102640:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102645:	e9 f0 f8 ff ff       	jmp    101f3a <__alltraps>

0010264a <vector181>:
.globl vector181
vector181:
  pushl $0
  10264a:	6a 00                	push   $0x0
  pushl $181
  10264c:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102651:	e9 e4 f8 ff ff       	jmp    101f3a <__alltraps>

00102656 <vector182>:
.globl vector182
vector182:
  pushl $0
  102656:	6a 00                	push   $0x0
  pushl $182
  102658:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10265d:	e9 d8 f8 ff ff       	jmp    101f3a <__alltraps>

00102662 <vector183>:
.globl vector183
vector183:
  pushl $0
  102662:	6a 00                	push   $0x0
  pushl $183
  102664:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102669:	e9 cc f8 ff ff       	jmp    101f3a <__alltraps>

0010266e <vector184>:
.globl vector184
vector184:
  pushl $0
  10266e:	6a 00                	push   $0x0
  pushl $184
  102670:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102675:	e9 c0 f8 ff ff       	jmp    101f3a <__alltraps>

0010267a <vector185>:
.globl vector185
vector185:
  pushl $0
  10267a:	6a 00                	push   $0x0
  pushl $185
  10267c:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102681:	e9 b4 f8 ff ff       	jmp    101f3a <__alltraps>

00102686 <vector186>:
.globl vector186
vector186:
  pushl $0
  102686:	6a 00                	push   $0x0
  pushl $186
  102688:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10268d:	e9 a8 f8 ff ff       	jmp    101f3a <__alltraps>

00102692 <vector187>:
.globl vector187
vector187:
  pushl $0
  102692:	6a 00                	push   $0x0
  pushl $187
  102694:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102699:	e9 9c f8 ff ff       	jmp    101f3a <__alltraps>

0010269e <vector188>:
.globl vector188
vector188:
  pushl $0
  10269e:	6a 00                	push   $0x0
  pushl $188
  1026a0:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1026a5:	e9 90 f8 ff ff       	jmp    101f3a <__alltraps>

001026aa <vector189>:
.globl vector189
vector189:
  pushl $0
  1026aa:	6a 00                	push   $0x0
  pushl $189
  1026ac:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1026b1:	e9 84 f8 ff ff       	jmp    101f3a <__alltraps>

001026b6 <vector190>:
.globl vector190
vector190:
  pushl $0
  1026b6:	6a 00                	push   $0x0
  pushl $190
  1026b8:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1026bd:	e9 78 f8 ff ff       	jmp    101f3a <__alltraps>

001026c2 <vector191>:
.globl vector191
vector191:
  pushl $0
  1026c2:	6a 00                	push   $0x0
  pushl $191
  1026c4:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1026c9:	e9 6c f8 ff ff       	jmp    101f3a <__alltraps>

001026ce <vector192>:
.globl vector192
vector192:
  pushl $0
  1026ce:	6a 00                	push   $0x0
  pushl $192
  1026d0:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1026d5:	e9 60 f8 ff ff       	jmp    101f3a <__alltraps>

001026da <vector193>:
.globl vector193
vector193:
  pushl $0
  1026da:	6a 00                	push   $0x0
  pushl $193
  1026dc:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1026e1:	e9 54 f8 ff ff       	jmp    101f3a <__alltraps>

001026e6 <vector194>:
.globl vector194
vector194:
  pushl $0
  1026e6:	6a 00                	push   $0x0
  pushl $194
  1026e8:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1026ed:	e9 48 f8 ff ff       	jmp    101f3a <__alltraps>

001026f2 <vector195>:
.globl vector195
vector195:
  pushl $0
  1026f2:	6a 00                	push   $0x0
  pushl $195
  1026f4:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1026f9:	e9 3c f8 ff ff       	jmp    101f3a <__alltraps>

001026fe <vector196>:
.globl vector196
vector196:
  pushl $0
  1026fe:	6a 00                	push   $0x0
  pushl $196
  102700:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102705:	e9 30 f8 ff ff       	jmp    101f3a <__alltraps>

0010270a <vector197>:
.globl vector197
vector197:
  pushl $0
  10270a:	6a 00                	push   $0x0
  pushl $197
  10270c:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102711:	e9 24 f8 ff ff       	jmp    101f3a <__alltraps>

00102716 <vector198>:
.globl vector198
vector198:
  pushl $0
  102716:	6a 00                	push   $0x0
  pushl $198
  102718:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10271d:	e9 18 f8 ff ff       	jmp    101f3a <__alltraps>

00102722 <vector199>:
.globl vector199
vector199:
  pushl $0
  102722:	6a 00                	push   $0x0
  pushl $199
  102724:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102729:	e9 0c f8 ff ff       	jmp    101f3a <__alltraps>

0010272e <vector200>:
.globl vector200
vector200:
  pushl $0
  10272e:	6a 00                	push   $0x0
  pushl $200
  102730:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102735:	e9 00 f8 ff ff       	jmp    101f3a <__alltraps>

0010273a <vector201>:
.globl vector201
vector201:
  pushl $0
  10273a:	6a 00                	push   $0x0
  pushl $201
  10273c:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102741:	e9 f4 f7 ff ff       	jmp    101f3a <__alltraps>

00102746 <vector202>:
.globl vector202
vector202:
  pushl $0
  102746:	6a 00                	push   $0x0
  pushl $202
  102748:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  10274d:	e9 e8 f7 ff ff       	jmp    101f3a <__alltraps>

00102752 <vector203>:
.globl vector203
vector203:
  pushl $0
  102752:	6a 00                	push   $0x0
  pushl $203
  102754:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102759:	e9 dc f7 ff ff       	jmp    101f3a <__alltraps>

0010275e <vector204>:
.globl vector204
vector204:
  pushl $0
  10275e:	6a 00                	push   $0x0
  pushl $204
  102760:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102765:	e9 d0 f7 ff ff       	jmp    101f3a <__alltraps>

0010276a <vector205>:
.globl vector205
vector205:
  pushl $0
  10276a:	6a 00                	push   $0x0
  pushl $205
  10276c:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102771:	e9 c4 f7 ff ff       	jmp    101f3a <__alltraps>

00102776 <vector206>:
.globl vector206
vector206:
  pushl $0
  102776:	6a 00                	push   $0x0
  pushl $206
  102778:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10277d:	e9 b8 f7 ff ff       	jmp    101f3a <__alltraps>

00102782 <vector207>:
.globl vector207
vector207:
  pushl $0
  102782:	6a 00                	push   $0x0
  pushl $207
  102784:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102789:	e9 ac f7 ff ff       	jmp    101f3a <__alltraps>

0010278e <vector208>:
.globl vector208
vector208:
  pushl $0
  10278e:	6a 00                	push   $0x0
  pushl $208
  102790:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102795:	e9 a0 f7 ff ff       	jmp    101f3a <__alltraps>

0010279a <vector209>:
.globl vector209
vector209:
  pushl $0
  10279a:	6a 00                	push   $0x0
  pushl $209
  10279c:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1027a1:	e9 94 f7 ff ff       	jmp    101f3a <__alltraps>

001027a6 <vector210>:
.globl vector210
vector210:
  pushl $0
  1027a6:	6a 00                	push   $0x0
  pushl $210
  1027a8:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1027ad:	e9 88 f7 ff ff       	jmp    101f3a <__alltraps>

001027b2 <vector211>:
.globl vector211
vector211:
  pushl $0
  1027b2:	6a 00                	push   $0x0
  pushl $211
  1027b4:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1027b9:	e9 7c f7 ff ff       	jmp    101f3a <__alltraps>

001027be <vector212>:
.globl vector212
vector212:
  pushl $0
  1027be:	6a 00                	push   $0x0
  pushl $212
  1027c0:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1027c5:	e9 70 f7 ff ff       	jmp    101f3a <__alltraps>

001027ca <vector213>:
.globl vector213
vector213:
  pushl $0
  1027ca:	6a 00                	push   $0x0
  pushl $213
  1027cc:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1027d1:	e9 64 f7 ff ff       	jmp    101f3a <__alltraps>

001027d6 <vector214>:
.globl vector214
vector214:
  pushl $0
  1027d6:	6a 00                	push   $0x0
  pushl $214
  1027d8:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1027dd:	e9 58 f7 ff ff       	jmp    101f3a <__alltraps>

001027e2 <vector215>:
.globl vector215
vector215:
  pushl $0
  1027e2:	6a 00                	push   $0x0
  pushl $215
  1027e4:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1027e9:	e9 4c f7 ff ff       	jmp    101f3a <__alltraps>

001027ee <vector216>:
.globl vector216
vector216:
  pushl $0
  1027ee:	6a 00                	push   $0x0
  pushl $216
  1027f0:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1027f5:	e9 40 f7 ff ff       	jmp    101f3a <__alltraps>

001027fa <vector217>:
.globl vector217
vector217:
  pushl $0
  1027fa:	6a 00                	push   $0x0
  pushl $217
  1027fc:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102801:	e9 34 f7 ff ff       	jmp    101f3a <__alltraps>

00102806 <vector218>:
.globl vector218
vector218:
  pushl $0
  102806:	6a 00                	push   $0x0
  pushl $218
  102808:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10280d:	e9 28 f7 ff ff       	jmp    101f3a <__alltraps>

00102812 <vector219>:
.globl vector219
vector219:
  pushl $0
  102812:	6a 00                	push   $0x0
  pushl $219
  102814:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102819:	e9 1c f7 ff ff       	jmp    101f3a <__alltraps>

0010281e <vector220>:
.globl vector220
vector220:
  pushl $0
  10281e:	6a 00                	push   $0x0
  pushl $220
  102820:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102825:	e9 10 f7 ff ff       	jmp    101f3a <__alltraps>

0010282a <vector221>:
.globl vector221
vector221:
  pushl $0
  10282a:	6a 00                	push   $0x0
  pushl $221
  10282c:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102831:	e9 04 f7 ff ff       	jmp    101f3a <__alltraps>

00102836 <vector222>:
.globl vector222
vector222:
  pushl $0
  102836:	6a 00                	push   $0x0
  pushl $222
  102838:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  10283d:	e9 f8 f6 ff ff       	jmp    101f3a <__alltraps>

00102842 <vector223>:
.globl vector223
vector223:
  pushl $0
  102842:	6a 00                	push   $0x0
  pushl $223
  102844:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102849:	e9 ec f6 ff ff       	jmp    101f3a <__alltraps>

0010284e <vector224>:
.globl vector224
vector224:
  pushl $0
  10284e:	6a 00                	push   $0x0
  pushl $224
  102850:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102855:	e9 e0 f6 ff ff       	jmp    101f3a <__alltraps>

0010285a <vector225>:
.globl vector225
vector225:
  pushl $0
  10285a:	6a 00                	push   $0x0
  pushl $225
  10285c:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102861:	e9 d4 f6 ff ff       	jmp    101f3a <__alltraps>

00102866 <vector226>:
.globl vector226
vector226:
  pushl $0
  102866:	6a 00                	push   $0x0
  pushl $226
  102868:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  10286d:	e9 c8 f6 ff ff       	jmp    101f3a <__alltraps>

00102872 <vector227>:
.globl vector227
vector227:
  pushl $0
  102872:	6a 00                	push   $0x0
  pushl $227
  102874:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102879:	e9 bc f6 ff ff       	jmp    101f3a <__alltraps>

0010287e <vector228>:
.globl vector228
vector228:
  pushl $0
  10287e:	6a 00                	push   $0x0
  pushl $228
  102880:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102885:	e9 b0 f6 ff ff       	jmp    101f3a <__alltraps>

0010288a <vector229>:
.globl vector229
vector229:
  pushl $0
  10288a:	6a 00                	push   $0x0
  pushl $229
  10288c:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102891:	e9 a4 f6 ff ff       	jmp    101f3a <__alltraps>

00102896 <vector230>:
.globl vector230
vector230:
  pushl $0
  102896:	6a 00                	push   $0x0
  pushl $230
  102898:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10289d:	e9 98 f6 ff ff       	jmp    101f3a <__alltraps>

001028a2 <vector231>:
.globl vector231
vector231:
  pushl $0
  1028a2:	6a 00                	push   $0x0
  pushl $231
  1028a4:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1028a9:	e9 8c f6 ff ff       	jmp    101f3a <__alltraps>

001028ae <vector232>:
.globl vector232
vector232:
  pushl $0
  1028ae:	6a 00                	push   $0x0
  pushl $232
  1028b0:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1028b5:	e9 80 f6 ff ff       	jmp    101f3a <__alltraps>

001028ba <vector233>:
.globl vector233
vector233:
  pushl $0
  1028ba:	6a 00                	push   $0x0
  pushl $233
  1028bc:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1028c1:	e9 74 f6 ff ff       	jmp    101f3a <__alltraps>

001028c6 <vector234>:
.globl vector234
vector234:
  pushl $0
  1028c6:	6a 00                	push   $0x0
  pushl $234
  1028c8:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1028cd:	e9 68 f6 ff ff       	jmp    101f3a <__alltraps>

001028d2 <vector235>:
.globl vector235
vector235:
  pushl $0
  1028d2:	6a 00                	push   $0x0
  pushl $235
  1028d4:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1028d9:	e9 5c f6 ff ff       	jmp    101f3a <__alltraps>

001028de <vector236>:
.globl vector236
vector236:
  pushl $0
  1028de:	6a 00                	push   $0x0
  pushl $236
  1028e0:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1028e5:	e9 50 f6 ff ff       	jmp    101f3a <__alltraps>

001028ea <vector237>:
.globl vector237
vector237:
  pushl $0
  1028ea:	6a 00                	push   $0x0
  pushl $237
  1028ec:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1028f1:	e9 44 f6 ff ff       	jmp    101f3a <__alltraps>

001028f6 <vector238>:
.globl vector238
vector238:
  pushl $0
  1028f6:	6a 00                	push   $0x0
  pushl $238
  1028f8:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1028fd:	e9 38 f6 ff ff       	jmp    101f3a <__alltraps>

00102902 <vector239>:
.globl vector239
vector239:
  pushl $0
  102902:	6a 00                	push   $0x0
  pushl $239
  102904:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102909:	e9 2c f6 ff ff       	jmp    101f3a <__alltraps>

0010290e <vector240>:
.globl vector240
vector240:
  pushl $0
  10290e:	6a 00                	push   $0x0
  pushl $240
  102910:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102915:	e9 20 f6 ff ff       	jmp    101f3a <__alltraps>

0010291a <vector241>:
.globl vector241
vector241:
  pushl $0
  10291a:	6a 00                	push   $0x0
  pushl $241
  10291c:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102921:	e9 14 f6 ff ff       	jmp    101f3a <__alltraps>

00102926 <vector242>:
.globl vector242
vector242:
  pushl $0
  102926:	6a 00                	push   $0x0
  pushl $242
  102928:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10292d:	e9 08 f6 ff ff       	jmp    101f3a <__alltraps>

00102932 <vector243>:
.globl vector243
vector243:
  pushl $0
  102932:	6a 00                	push   $0x0
  pushl $243
  102934:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102939:	e9 fc f5 ff ff       	jmp    101f3a <__alltraps>

0010293e <vector244>:
.globl vector244
vector244:
  pushl $0
  10293e:	6a 00                	push   $0x0
  pushl $244
  102940:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102945:	e9 f0 f5 ff ff       	jmp    101f3a <__alltraps>

0010294a <vector245>:
.globl vector245
vector245:
  pushl $0
  10294a:	6a 00                	push   $0x0
  pushl $245
  10294c:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102951:	e9 e4 f5 ff ff       	jmp    101f3a <__alltraps>

00102956 <vector246>:
.globl vector246
vector246:
  pushl $0
  102956:	6a 00                	push   $0x0
  pushl $246
  102958:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  10295d:	e9 d8 f5 ff ff       	jmp    101f3a <__alltraps>

00102962 <vector247>:
.globl vector247
vector247:
  pushl $0
  102962:	6a 00                	push   $0x0
  pushl $247
  102964:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102969:	e9 cc f5 ff ff       	jmp    101f3a <__alltraps>

0010296e <vector248>:
.globl vector248
vector248:
  pushl $0
  10296e:	6a 00                	push   $0x0
  pushl $248
  102970:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102975:	e9 c0 f5 ff ff       	jmp    101f3a <__alltraps>

0010297a <vector249>:
.globl vector249
vector249:
  pushl $0
  10297a:	6a 00                	push   $0x0
  pushl $249
  10297c:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102981:	e9 b4 f5 ff ff       	jmp    101f3a <__alltraps>

00102986 <vector250>:
.globl vector250
vector250:
  pushl $0
  102986:	6a 00                	push   $0x0
  pushl $250
  102988:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  10298d:	e9 a8 f5 ff ff       	jmp    101f3a <__alltraps>

00102992 <vector251>:
.globl vector251
vector251:
  pushl $0
  102992:	6a 00                	push   $0x0
  pushl $251
  102994:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102999:	e9 9c f5 ff ff       	jmp    101f3a <__alltraps>

0010299e <vector252>:
.globl vector252
vector252:
  pushl $0
  10299e:	6a 00                	push   $0x0
  pushl $252
  1029a0:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1029a5:	e9 90 f5 ff ff       	jmp    101f3a <__alltraps>

001029aa <vector253>:
.globl vector253
vector253:
  pushl $0
  1029aa:	6a 00                	push   $0x0
  pushl $253
  1029ac:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1029b1:	e9 84 f5 ff ff       	jmp    101f3a <__alltraps>

001029b6 <vector254>:
.globl vector254
vector254:
  pushl $0
  1029b6:	6a 00                	push   $0x0
  pushl $254
  1029b8:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1029bd:	e9 78 f5 ff ff       	jmp    101f3a <__alltraps>

001029c2 <vector255>:
.globl vector255
vector255:
  pushl $0
  1029c2:	6a 00                	push   $0x0
  pushl $255
  1029c4:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1029c9:	e9 6c f5 ff ff       	jmp    101f3a <__alltraps>

001029ce <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1029ce:	55                   	push   %ebp
  1029cf:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1029d1:	8b 55 08             	mov    0x8(%ebp),%edx
  1029d4:	a1 a4 cf 11 00       	mov    0x11cfa4,%eax
  1029d9:	29 c2                	sub    %eax,%edx
  1029db:	89 d0                	mov    %edx,%eax
  1029dd:	c1 f8 02             	sar    $0x2,%eax
  1029e0:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1029e6:	5d                   	pop    %ebp
  1029e7:	c3                   	ret    

001029e8 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1029e8:	55                   	push   %ebp
  1029e9:	89 e5                	mov    %esp,%ebp
  1029eb:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1029ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f1:	89 04 24             	mov    %eax,(%esp)
  1029f4:	e8 d5 ff ff ff       	call   1029ce <page2ppn>
  1029f9:	c1 e0 0c             	shl    $0xc,%eax
}
  1029fc:	c9                   	leave  
  1029fd:	c3                   	ret    

001029fe <set_page_ref>:
page_ref(struct Page *page) {
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
  1029fe:	55                   	push   %ebp
  1029ff:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102a01:	8b 45 08             	mov    0x8(%ebp),%eax
  102a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a07:	89 10                	mov    %edx,(%eax)
}
  102a09:	5d                   	pop    %ebp
  102a0a:	c3                   	ret    

00102a0b <buddy_init>:
static unsigned int max_pages; // maintained by buddy
static struct Page* buddy_allocatable_base;

#define max(a, b) ((a) > (b) ? (a) : (b))
 
static void buddy_init(void) {}
  102a0b:	55                   	push   %ebp
  102a0c:	89 e5                	mov    %esp,%ebp
  102a0e:	5d                   	pop    %ebp
  102a0f:	c3                   	ret    

00102a10 <buddy_init_memmap>:

static void buddy_init_memmap(struct Page *base, size_t n) {
  102a10:	55                   	push   %ebp
  102a11:	89 e5                	mov    %esp,%ebp
  102a13:	83 ec 48             	sub    $0x48,%esp
	int i=0;
  102a16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    assert(n > 0);
  102a1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102a21:	75 24                	jne    102a47 <buddy_init_memmap+0x37>
  102a23:	c7 44 24 0c 30 73 10 	movl   $0x107330,0xc(%esp)
  102a2a:	00 
  102a2b:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  102a32:	00 
  102a33:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  102a3a:	00 
  102a3b:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  102a42:	e8 a0 e2 ff ff       	call   100ce7 <__panic>
    // calc buddy alloc page number
    max_pages = 1;
  102a47:	c7 05 88 ce 11 00 01 	movl   $0x1,0x11ce88
  102a4e:	00 00 00 
    for (i = 1; i < BUDDY_MAX_DEPTH; ++i, max_pages <<= 1)
  102a51:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  102a58:	eb 28                	jmp    102a82 <buddy_init_memmap+0x72>
        if (max_pages + (max_pages >> 9) >= n)
  102a5a:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102a5f:	c1 e8 09             	shr    $0x9,%eax
  102a62:	89 c2                	mov    %eax,%edx
  102a64:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102a69:	01 d0                	add    %edx,%eax
  102a6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102a6e:	72 02                	jb     102a72 <buddy_init_memmap+0x62>
            break;
  102a70:	eb 16                	jmp    102a88 <buddy_init_memmap+0x78>
static void buddy_init_memmap(struct Page *base, size_t n) {
	int i=0;
    assert(n > 0);
    // calc buddy alloc page number
    max_pages = 1;
    for (i = 1; i < BUDDY_MAX_DEPTH; ++i, max_pages <<= 1)
  102a72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  102a76:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102a7b:	01 c0                	add    %eax,%eax
  102a7d:	a3 88 ce 11 00       	mov    %eax,0x11ce88
  102a82:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
  102a86:	7e d2                	jle    102a5a <buddy_init_memmap+0x4a>
        if (max_pages + (max_pages >> 9) >= n)
            break;
    max_pages >>= 1;
  102a88:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102a8d:	d1 e8                	shr    %eax
  102a8f:	a3 88 ce 11 00       	mov    %eax,0x11ce88
    buddy_page_num = (max_pages >> 9) + 1;
  102a94:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102a99:	c1 e8 09             	shr    $0x9,%eax
  102a9c:	83 c0 01             	add    $0x1,%eax
  102a9f:	a3 84 ce 11 00       	mov    %eax,0x11ce84
    cprintf("buddy init: total %d, use %d, free %d\n", n, buddy_page_num, max_pages);
  102aa4:	8b 15 88 ce 11 00    	mov    0x11ce88,%edx
  102aaa:	a1 84 ce 11 00       	mov    0x11ce84,%eax
  102aaf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
  102ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102aba:	89 44 24 04          	mov    %eax,0x4(%esp)
  102abe:	c7 04 24 60 73 10 00 	movl   $0x107360,(%esp)
  102ac5:	e8 89 d8 ff ff       	call   100353 <cprintf>
    // set these pages to reserved
    for (i = 0; i < buddy_page_num; ++i)
  102aca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102ad1:	eb 2e                	jmp    102b01 <buddy_init_memmap+0xf1>
        SetPageReserved(base + i);
  102ad3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ad6:	89 d0                	mov    %edx,%eax
  102ad8:	c1 e0 02             	shl    $0x2,%eax
  102adb:	01 d0                	add    %edx,%eax
  102add:	c1 e0 02             	shl    $0x2,%eax
  102ae0:	89 c2                	mov    %eax,%edx
  102ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae5:	01 d0                	add    %edx,%eax
  102ae7:	83 c0 04             	add    $0x4,%eax
  102aea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102af1:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102af4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102af7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102afa:	0f ab 10             	bts    %edx,(%eax)
            break;
    max_pages >>= 1;
    buddy_page_num = (max_pages >> 9) + 1;
    cprintf("buddy init: total %d, use %d, free %d\n", n, buddy_page_num, max_pages);
    // set these pages to reserved
    for (i = 0; i < buddy_page_num; ++i)
  102afd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  102b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b04:	a1 84 ce 11 00       	mov    0x11ce84,%eax
  102b09:	39 c2                	cmp    %eax,%edx
  102b0b:	72 c6                	jb     102ad3 <buddy_init_memmap+0xc3>
        SetPageReserved(base + i);
    // set non-buddy page to be allocatable
    buddy_allocatable_base = base + buddy_page_num;
  102b0d:	8b 15 84 ce 11 00    	mov    0x11ce84,%edx
  102b13:	89 d0                	mov    %edx,%eax
  102b15:	c1 e0 02             	shl    $0x2,%eax
  102b18:	01 d0                	add    %edx,%eax
  102b1a:	c1 e0 02             	shl    $0x2,%eax
  102b1d:	89 c2                	mov    %eax,%edx
  102b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  102b22:	01 d0                	add    %edx,%eax
  102b24:	a3 8c ce 11 00       	mov    %eax,0x11ce8c
	struct Page* p;
    for (p = buddy_allocatable_base; p != base + n; ++p) {
  102b29:	a1 8c ce 11 00       	mov    0x11ce8c,%eax
  102b2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102b31:	eb 49                	jmp    102b7c <buddy_init_memmap+0x16c>
        ClearPageReserved(p);
  102b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b36:	83 c0 04             	add    $0x4,%eax
  102b39:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102b40:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b43:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b46:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102b49:	0f b3 10             	btr    %edx,(%eax)
        SetPageProperty(p);
  102b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b4f:	83 c0 04             	add    $0x4,%eax
  102b52:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102b59:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b5f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b62:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);
  102b65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102b6c:	00 
  102b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b70:	89 04 24             	mov    %eax,(%esp)
  102b73:	e8 86 fe ff ff       	call   1029fe <set_page_ref>
    for (i = 0; i < buddy_page_num; ++i)
        SetPageReserved(base + i);
    // set non-buddy page to be allocatable
    buddy_allocatable_base = base + buddy_page_num;
	struct Page* p;
    for (p = buddy_allocatable_base; p != base + n; ++p) {
  102b78:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
  102b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b7f:	89 d0                	mov    %edx,%eax
  102b81:	c1 e0 02             	shl    $0x2,%eax
  102b84:	01 d0                	add    %edx,%eax
  102b86:	c1 e0 02             	shl    $0x2,%eax
  102b89:	89 c2                	mov    %eax,%edx
  102b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b8e:	01 d0                	add    %edx,%eax
  102b90:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102b93:	75 9e                	jne    102b33 <buddy_init_memmap+0x123>
        ClearPageReserved(p);
        SetPageProperty(p);
        set_page_ref(p, 0);
    }
    // init buddy page
    buddy_page = (unsigned int*)KADDR(page2pa(base));
  102b95:	8b 45 08             	mov    0x8(%ebp),%eax
  102b98:	89 04 24             	mov    %eax,(%esp)
  102b9b:	e8 48 fe ff ff       	call   1029e8 <page2pa>
  102ba0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ba6:	c1 e8 0c             	shr    $0xc,%eax
  102ba9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102bac:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  102bb1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  102bb4:	72 23                	jb     102bd9 <buddy_init_memmap+0x1c9>
  102bb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102bbd:	c7 44 24 08 88 73 10 	movl   $0x107388,0x8(%esp)
  102bc4:	00 
  102bc5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  102bcc:	00 
  102bcd:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  102bd4:	e8 0e e1 ff ff       	call   100ce7 <__panic>
  102bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bdc:	2d 00 00 00 40       	sub    $0x40000000,%eax
  102be1:	a3 80 ce 11 00       	mov    %eax,0x11ce80
    for (i = max_pages; i < max_pages << 1; ++i)
  102be6:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102bee:	eb 17                	jmp    102c07 <buddy_init_memmap+0x1f7>
        buddy_page[i] = 1;
  102bf0:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102bf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102bf8:	c1 e2 02             	shl    $0x2,%edx
  102bfb:	01 d0                	add    %edx,%eax
  102bfd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        SetPageProperty(p);
        set_page_ref(p, 0);
    }
    // init buddy page
    buddy_page = (unsigned int*)KADDR(page2pa(base));
    for (i = max_pages; i < max_pages << 1; ++i)
  102c03:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  102c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c0a:	8b 15 88 ce 11 00    	mov    0x11ce88,%edx
  102c10:	01 d2                	add    %edx,%edx
  102c12:	39 d0                	cmp    %edx,%eax
  102c14:	72 da                	jb     102bf0 <buddy_init_memmap+0x1e0>
        buddy_page[i] = 1;
    for (i = max_pages - 1; i > 0; --i)
  102c16:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102c1b:	83 e8 01             	sub    $0x1,%eax
  102c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102c21:	eb 27                	jmp    102c4a <buddy_init_memmap+0x23a>
        buddy_page[i] = buddy_page[i << 1] << 1;
  102c23:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102c28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102c2b:	c1 e2 02             	shl    $0x2,%edx
  102c2e:	01 d0                	add    %edx,%eax
  102c30:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  102c36:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  102c39:	01 c9                	add    %ecx,%ecx
  102c3b:	c1 e1 02             	shl    $0x2,%ecx
  102c3e:	01 ca                	add    %ecx,%edx
  102c40:	8b 12                	mov    (%edx),%edx
  102c42:	01 d2                	add    %edx,%edx
  102c44:	89 10                	mov    %edx,(%eax)
    }
    // init buddy page
    buddy_page = (unsigned int*)KADDR(page2pa(base));
    for (i = max_pages; i < max_pages << 1; ++i)
        buddy_page[i] = 1;
    for (i = max_pages - 1; i > 0; --i)
  102c46:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  102c4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102c4e:	7f d3                	jg     102c23 <buddy_init_memmap+0x213>
        buddy_page[i] = buddy_page[i << 1] << 1;
}
  102c50:	c9                   	leave  
  102c51:	c3                   	ret    

00102c52 <buddy_alloc_pages>:

static struct Page* buddy_alloc_pages(size_t n) {
  102c52:	55                   	push   %ebp
  102c53:	89 e5                	mov    %esp,%ebp
  102c55:	53                   	push   %ebx
  102c56:	83 ec 34             	sub    $0x34,%esp
    assert(n > 0);
  102c59:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102c5d:	75 24                	jne    102c83 <buddy_alloc_pages+0x31>
  102c5f:	c7 44 24 0c 30 73 10 	movl   $0x107330,0xc(%esp)
  102c66:	00 
  102c67:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  102c6e:	00 
  102c6f:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  102c76:	00 
  102c77:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  102c7e:	e8 64 e0 ff ff       	call   100ce7 <__panic>
    if (n > buddy_page[1]) return NULL;
  102c83:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102c88:	83 c0 04             	add    $0x4,%eax
  102c8b:	8b 00                	mov    (%eax),%eax
  102c8d:	3b 45 08             	cmp    0x8(%ebp),%eax
  102c90:	73 0a                	jae    102c9c <buddy_alloc_pages+0x4a>
  102c92:	b8 00 00 00 00       	mov    $0x0,%eax
  102c97:	e9 2c 01 00 00       	jmp    102dc8 <buddy_alloc_pages+0x176>
    unsigned int index = 1, size = max_pages;
  102c9c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  102ca3:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (; size >= n; size >>= 1) {
  102cab:	eb 44                	jmp    102cf1 <buddy_alloc_pages+0x9f>
        if (buddy_page[index << 1] >= n) index <<= 1;
  102cad:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102cb5:	c1 e2 03             	shl    $0x3,%edx
  102cb8:	01 d0                	add    %edx,%eax
  102cba:	8b 00                	mov    (%eax),%eax
  102cbc:	3b 45 08             	cmp    0x8(%ebp),%eax
  102cbf:	72 05                	jb     102cc6 <buddy_alloc_pages+0x74>
  102cc1:	d1 65 f4             	shll   -0xc(%ebp)
  102cc4:	eb 28                	jmp    102cee <buddy_alloc_pages+0x9c>
        else if (buddy_page[index << 1 | 1] >= n) index = index << 1 | 1;
  102cc6:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102ccb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102cce:	01 d2                	add    %edx,%edx
  102cd0:	83 ca 01             	or     $0x1,%edx
  102cd3:	c1 e2 02             	shl    $0x2,%edx
  102cd6:	01 d0                	add    %edx,%eax
  102cd8:	8b 00                	mov    (%eax),%eax
  102cda:	3b 45 08             	cmp    0x8(%ebp),%eax
  102cdd:	72 0d                	jb     102cec <buddy_alloc_pages+0x9a>
  102cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ce2:	01 c0                	add    %eax,%eax
  102ce4:	83 c8 01             	or     $0x1,%eax
  102ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102cea:	eb 02                	jmp    102cee <buddy_alloc_pages+0x9c>
        else break;
  102cec:	eb 0b                	jmp    102cf9 <buddy_alloc_pages+0xa7>

static struct Page* buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > buddy_page[1]) return NULL;
    unsigned int index = 1, size = max_pages;
    for (; size >= n; size >>= 1) {
  102cee:	d1 6d f0             	shrl   -0x10(%ebp)
  102cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cf4:	3b 45 08             	cmp    0x8(%ebp),%eax
  102cf7:	73 b4                	jae    102cad <buddy_alloc_pages+0x5b>
        if (buddy_page[index << 1] >= n) index <<= 1;
        else if (buddy_page[index << 1 | 1] >= n) index = index << 1 | 1;
        else break;
    }
    buddy_page[index] = 0;
  102cf9:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d01:	c1 e2 02             	shl    $0x2,%edx
  102d04:	01 d0                	add    %edx,%eax
  102d06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    // allocate all pages under node[index]
    struct Page* new_page = buddy_allocatable_base + index * size - max_pages;
  102d0c:	8b 0d 8c ce 11 00    	mov    0x11ce8c,%ecx
  102d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d15:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  102d19:	89 c2                	mov    %eax,%edx
  102d1b:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102d20:	29 c2                	sub    %eax,%edx
  102d22:	89 d0                	mov    %edx,%eax
  102d24:	c1 e0 02             	shl    $0x2,%eax
  102d27:	01 d0                	add    %edx,%eax
  102d29:	c1 e0 02             	shl    $0x2,%eax
  102d2c:	01 c8                	add    %ecx,%eax
  102d2e:	89 45 e8             	mov    %eax,-0x18(%ebp)
	struct Page* p;
    for (p = new_page; p != new_page + size; ++p)
  102d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d34:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102d37:	eb 30                	jmp    102d69 <buddy_alloc_pages+0x117>
        set_page_ref(p, 0), ClearPageProperty(p);
  102d39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102d40:	00 
  102d41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d44:	89 04 24             	mov    %eax,(%esp)
  102d47:	e8 b2 fc ff ff       	call   1029fe <set_page_ref>
  102d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d4f:	83 c0 04             	add    $0x4,%eax
  102d52:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102d59:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d62:	0f b3 10             	btr    %edx,(%eax)
    }
    buddy_page[index] = 0;
    // allocate all pages under node[index]
    struct Page* new_page = buddy_allocatable_base + index * size - max_pages;
	struct Page* p;
    for (p = new_page; p != new_page + size; ++p)
  102d65:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
  102d69:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102d6c:	89 d0                	mov    %edx,%eax
  102d6e:	c1 e0 02             	shl    $0x2,%eax
  102d71:	01 d0                	add    %edx,%eax
  102d73:	c1 e0 02             	shl    $0x2,%eax
  102d76:	89 c2                	mov    %eax,%edx
  102d78:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d7b:	01 d0                	add    %edx,%eax
  102d7d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102d80:	75 b7                	jne    102d39 <buddy_alloc_pages+0xe7>
        set_page_ref(p, 0), ClearPageProperty(p);
    for (; (index >>= 1) > 0; ) // since destory continuous, use MAX instead of SUM
  102d82:	eb 38                	jmp    102dbc <buddy_alloc_pages+0x16a>
        buddy_page[index] = max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
  102d84:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102d89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d8c:	c1 e2 02             	shl    $0x2,%edx
  102d8f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  102d92:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102d97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d9a:	01 d2                	add    %edx,%edx
  102d9c:	83 ca 01             	or     $0x1,%edx
  102d9f:	c1 e2 02             	shl    $0x2,%edx
  102da2:	01 d0                	add    %edx,%eax
  102da4:	8b 10                	mov    (%eax),%edx
  102da6:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102dab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  102dae:	c1 e3 03             	shl    $0x3,%ebx
  102db1:	01 d8                	add    %ebx,%eax
  102db3:	8b 00                	mov    (%eax),%eax
  102db5:	39 c2                	cmp    %eax,%edx
  102db7:	0f 43 c2             	cmovae %edx,%eax
  102dba:	89 01                	mov    %eax,(%ecx)
    // allocate all pages under node[index]
    struct Page* new_page = buddy_allocatable_base + index * size - max_pages;
	struct Page* p;
    for (p = new_page; p != new_page + size; ++p)
        set_page_ref(p, 0), ClearPageProperty(p);
    for (; (index >>= 1) > 0; ) // since destory continuous, use MAX instead of SUM
  102dbc:	d1 6d f4             	shrl   -0xc(%ebp)
  102dbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102dc3:	75 bf                	jne    102d84 <buddy_alloc_pages+0x132>
        buddy_page[index] = max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
    return new_page;
  102dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  102dc8:	83 c4 34             	add    $0x34,%esp
  102dcb:	5b                   	pop    %ebx
  102dcc:	5d                   	pop    %ebp
  102dcd:	c3                   	ret    

00102dce <buddy_free_pages>:

static void buddy_free_pages(struct Page *base, size_t n) {
  102dce:	55                   	push   %ebp
  102dcf:	89 e5                	mov    %esp,%ebp
  102dd1:	53                   	push   %ebx
  102dd2:	83 ec 44             	sub    $0x44,%esp
    assert(n > 0);
  102dd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102dd9:	75 24                	jne    102dff <buddy_free_pages+0x31>
  102ddb:	c7 44 24 0c 30 73 10 	movl   $0x107330,0xc(%esp)
  102de2:	00 
  102de3:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  102dea:	00 
  102deb:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  102df2:	00 
  102df3:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  102dfa:	e8 e8 de ff ff       	call   100ce7 <__panic>
    unsigned int index = (unsigned int)(base - buddy_allocatable_base) + max_pages, size = 1;
  102dff:	8b 55 08             	mov    0x8(%ebp),%edx
  102e02:	a1 8c ce 11 00       	mov    0x11ce8c,%eax
  102e07:	29 c2                	sub    %eax,%edx
  102e09:	89 d0                	mov    %edx,%eax
  102e0b:	c1 f8 02             	sar    $0x2,%eax
  102e0e:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
  102e14:	89 c2                	mov    %eax,%edx
  102e16:	a1 88 ce 11 00       	mov    0x11ce88,%eax
  102e1b:	01 d0                	add    %edx,%eax
  102e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e20:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // find first buddy node which has buddy_page[index] == 0
    for (; buddy_page[index] > 0; index >>= 1, size <<= 1);
  102e27:	eb 06                	jmp    102e2f <buddy_free_pages+0x61>
  102e29:	d1 6d f4             	shrl   -0xc(%ebp)
  102e2c:	d1 65 f0             	shll   -0x10(%ebp)
  102e2f:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102e34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e37:	c1 e2 02             	shl    $0x2,%edx
  102e3a:	01 d0                	add    %edx,%eax
  102e3c:	8b 00                	mov    (%eax),%eax
  102e3e:	85 c0                	test   %eax,%eax
  102e40:	75 e7                	jne    102e29 <buddy_free_pages+0x5b>
    // free all pages
	struct Page* p;
    for (p = base; p != base + n; ++p) {
  102e42:	8b 45 08             	mov    0x8(%ebp),%eax
  102e45:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e48:	e9 ac 00 00 00       	jmp    102ef9 <buddy_free_pages+0x12b>
        assert(!PageReserved(p) && !PageProperty(p));
  102e4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e50:	83 c0 04             	add    $0x4,%eax
  102e53:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  102e5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102e5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e60:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102e63:	0f a3 10             	bt     %edx,(%eax)
  102e66:	19 c0                	sbb    %eax,%eax
  102e68:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
  102e6b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  102e6f:	0f 95 c0             	setne  %al
  102e72:	0f b6 c0             	movzbl %al,%eax
  102e75:	85 c0                	test   %eax,%eax
  102e77:	75 2c                	jne    102ea5 <buddy_free_pages+0xd7>
  102e79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e7c:	83 c0 04             	add    $0x4,%eax
  102e7f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  102e86:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102e89:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102e8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e8f:	0f a3 10             	bt     %edx,(%eax)
  102e92:	19 c0                	sbb    %eax,%eax
  102e94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
  102e97:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  102e9b:	0f 95 c0             	setne  %al
  102e9e:	0f b6 c0             	movzbl %al,%eax
  102ea1:	85 c0                	test   %eax,%eax
  102ea3:	74 24                	je     102ec9 <buddy_free_pages+0xfb>
  102ea5:	c7 44 24 0c ac 73 10 	movl   $0x1073ac,0xc(%esp)
  102eac:	00 
  102ead:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  102eb4:	00 
  102eb5:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  102ebc:	00 
  102ebd:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  102ec4:	e8 1e de ff ff       	call   100ce7 <__panic>
        SetPageProperty(p), set_page_ref(p, 0);
  102ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ecc:	83 c0 04             	add    $0x4,%eax
  102ecf:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  102ed6:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ed9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102edc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102edf:	0f ab 10             	bts    %edx,(%eax)
  102ee2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102ee9:	00 
  102eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102eed:	89 04 24             	mov    %eax,(%esp)
  102ef0:	e8 09 fb ff ff       	call   1029fe <set_page_ref>
    unsigned int index = (unsigned int)(base - buddy_allocatable_base) + max_pages, size = 1;
    // find first buddy node which has buddy_page[index] == 0
    for (; buddy_page[index] > 0; index >>= 1, size <<= 1);
    // free all pages
	struct Page* p;
    for (p = base; p != base + n; ++p) {
  102ef5:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
  102ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
  102efc:	89 d0                	mov    %edx,%eax
  102efe:	c1 e0 02             	shl    $0x2,%eax
  102f01:	01 d0                	add    %edx,%eax
  102f03:	c1 e0 02             	shl    $0x2,%eax
  102f06:	89 c2                	mov    %eax,%edx
  102f08:	8b 45 08             	mov    0x8(%ebp),%eax
  102f0b:	01 d0                	add    %edx,%eax
  102f0d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102f10:	0f 85 37 ff ff ff    	jne    102e4d <buddy_free_pages+0x7f>
        assert(!PageReserved(p) && !PageProperty(p));
        SetPageProperty(p), set_page_ref(p, 0);
    }
    // modify buddy_page
    for (buddy_page[index] = size; size <<= 1, (index >>= 1) > 0;)
  102f16:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102f1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f1e:	c1 e2 02             	shl    $0x2,%edx
  102f21:	01 c2                	add    %eax,%edx
  102f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f26:	89 02                	mov    %eax,(%edx)
  102f28:	eb 67                	jmp    102f91 <buddy_free_pages+0x1c3>
        buddy_page[index] = (buddy_page[index << 1] + buddy_page[index << 1 | 1] == size) ? size : max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
  102f2a:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102f2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f32:	c1 e2 02             	shl    $0x2,%edx
  102f35:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  102f38:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102f3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f40:	c1 e2 03             	shl    $0x3,%edx
  102f43:	01 d0                	add    %edx,%eax
  102f45:	8b 10                	mov    (%eax),%edx
  102f47:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102f4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  102f4f:	01 db                	add    %ebx,%ebx
  102f51:	83 cb 01             	or     $0x1,%ebx
  102f54:	c1 e3 02             	shl    $0x2,%ebx
  102f57:	01 d8                	add    %ebx,%eax
  102f59:	8b 00                	mov    (%eax),%eax
  102f5b:	01 d0                	add    %edx,%eax
  102f5d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102f60:	74 2a                	je     102f8c <buddy_free_pages+0x1be>
  102f62:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102f67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f6a:	01 d2                	add    %edx,%edx
  102f6c:	83 ca 01             	or     $0x1,%edx
  102f6f:	c1 e2 02             	shl    $0x2,%edx
  102f72:	01 d0                	add    %edx,%eax
  102f74:	8b 10                	mov    (%eax),%edx
  102f76:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102f7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  102f7e:	c1 e3 03             	shl    $0x3,%ebx
  102f81:	01 d8                	add    %ebx,%eax
  102f83:	8b 00                	mov    (%eax),%eax
  102f85:	39 c2                	cmp    %eax,%edx
  102f87:	0f 43 c2             	cmovae %edx,%eax
  102f8a:	eb 03                	jmp    102f8f <buddy_free_pages+0x1c1>
  102f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f8f:	89 01                	mov    %eax,(%ecx)
    for (p = base; p != base + n; ++p) {
        assert(!PageReserved(p) && !PageProperty(p));
        SetPageProperty(p), set_page_ref(p, 0);
    }
    // modify buddy_page
    for (buddy_page[index] = size; size <<= 1, (index >>= 1) > 0;)
  102f91:	d1 65 f0             	shll   -0x10(%ebp)
  102f94:	d1 6d f4             	shrl   -0xc(%ebp)
  102f97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102f9b:	75 8d                	jne    102f2a <buddy_free_pages+0x15c>
        buddy_page[index] = (buddy_page[index << 1] + buddy_page[index << 1 | 1] == size) ? size : max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
}
  102f9d:	83 c4 44             	add    $0x44,%esp
  102fa0:	5b                   	pop    %ebx
  102fa1:	5d                   	pop    %ebp
  102fa2:	c3                   	ret    

00102fa3 <buddy_nr_free_pages>:

static size_t buddy_nr_free_pages(void) { return buddy_page[1]; }
  102fa3:	55                   	push   %ebp
  102fa4:	89 e5                	mov    %esp,%ebp
  102fa6:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102fab:	83 c0 04             	add    $0x4,%eax
  102fae:	8b 00                	mov    (%eax),%eax
  102fb0:	5d                   	pop    %ebp
  102fb1:	c3                   	ret    

00102fb2 <buddy_check>:

static void buddy_check(void) {
  102fb2:	55                   	push   %ebp
  102fb3:	89 e5                	mov    %esp,%ebp
  102fb5:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int all_pages = nr_free_pages();
  102fbb:	e8 91 1a 00 00       	call   104a51 <nr_free_pages>
  102fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page* p0, *p1, *p2, *p3;
    assert(alloc_pages(all_pages + 1) == NULL);
  102fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fc6:	83 c0 01             	add    $0x1,%eax
  102fc9:	89 04 24             	mov    %eax,(%esp)
  102fcc:	e8 16 1a 00 00       	call   1049e7 <alloc_pages>
  102fd1:	85 c0                	test   %eax,%eax
  102fd3:	74 24                	je     102ff9 <buddy_check+0x47>
  102fd5:	c7 44 24 0c d4 73 10 	movl   $0x1073d4,0xc(%esp)
  102fdc:	00 
  102fdd:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  102fe4:	00 
  102fe5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  102fec:	00 
  102fed:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  102ff4:	e8 ee dc ff ff       	call   100ce7 <__panic>

    p0 = alloc_pages(1);
  102ff9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103000:	e8 e2 19 00 00       	call   1049e7 <alloc_pages>
  103005:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(p0 != NULL);
  103008:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10300c:	75 24                	jne    103032 <buddy_check+0x80>
  10300e:	c7 44 24 0c f7 73 10 	movl   $0x1073f7,0xc(%esp)
  103015:	00 
  103016:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  10301d:	00 
  10301e:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103025:	00 
  103026:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  10302d:	e8 b5 dc ff ff       	call   100ce7 <__panic>
    p1 = alloc_pages(2);
  103032:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103039:	e8 a9 19 00 00       	call   1049e7 <alloc_pages>
  10303e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(p1 == p0 + 2);
  103041:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103044:	83 c0 28             	add    $0x28,%eax
  103047:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10304a:	74 24                	je     103070 <buddy_check+0xbe>
  10304c:	c7 44 24 0c 02 74 10 	movl   $0x107402,0xc(%esp)
  103053:	00 
  103054:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  10305b:	00 
  10305c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  103063:	00 
  103064:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  10306b:	e8 77 dc ff ff       	call   100ce7 <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0));
  103070:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103073:	83 c0 04             	add    $0x4,%eax
  103076:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  10307d:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103080:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103083:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103086:	0f a3 10             	bt     %edx,(%eax)
  103089:	19 c0                	sbb    %eax,%eax
  10308b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10308e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  103092:	0f 95 c0             	setne  %al
  103095:	0f b6 c0             	movzbl %al,%eax
  103098:	85 c0                	test   %eax,%eax
  10309a:	75 2c                	jne    1030c8 <buddy_check+0x116>
  10309c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10309f:	83 c0 04             	add    $0x4,%eax
  1030a2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  1030a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1030ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1030af:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1030b2:	0f a3 10             	bt     %edx,(%eax)
  1030b5:	19 c0                	sbb    %eax,%eax
  1030b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return oldbit != 0;
  1030ba:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030be:	0f 95 c0             	setne  %al
  1030c1:	0f b6 c0             	movzbl %al,%eax
  1030c4:	85 c0                	test   %eax,%eax
  1030c6:	74 24                	je     1030ec <buddy_check+0x13a>
  1030c8:	c7 44 24 0c 10 74 10 	movl   $0x107410,0xc(%esp)
  1030cf:	00 
  1030d0:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  1030d7:	00 
  1030d8:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  1030df:	00 
  1030e0:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  1030e7:	e8 fb db ff ff       	call   100ce7 <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
  1030ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030ef:	83 c0 04             	add    $0x4,%eax
  1030f2:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  1030f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1030fc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1030ff:	8b 55 c8             	mov    -0x38(%ebp),%edx
  103102:	0f a3 10             	bt     %edx,(%eax)
  103105:	19 c0                	sbb    %eax,%eax
  103107:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
  10310a:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  10310e:	0f 95 c0             	setne  %al
  103111:	0f b6 c0             	movzbl %al,%eax
  103114:	85 c0                	test   %eax,%eax
  103116:	75 2c                	jne    103144 <buddy_check+0x192>
  103118:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10311b:	83 c0 04             	add    $0x4,%eax
  10311e:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  103125:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103128:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10312b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10312e:	0f a3 10             	bt     %edx,(%eax)
  103131:	19 c0                	sbb    %eax,%eax
  103133:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    return oldbit != 0;
  103136:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  10313a:	0f 95 c0             	setne  %al
  10313d:	0f b6 c0             	movzbl %al,%eax
  103140:	85 c0                	test   %eax,%eax
  103142:	74 24                	je     103168 <buddy_check+0x1b6>
  103144:	c7 44 24 0c 38 74 10 	movl   $0x107438,0xc(%esp)
  10314b:	00 
  10314c:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  103153:	00 
  103154:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  10315b:	00 
  10315c:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  103163:	e8 7f db ff ff       	call   100ce7 <__panic>

    p2 = alloc_pages(1);
  103168:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10316f:	e8 73 18 00 00       	call   1049e7 <alloc_pages>
  103174:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p2 == p0 + 1);
  103177:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10317a:	83 c0 14             	add    $0x14,%eax
  10317d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  103180:	74 24                	je     1031a6 <buddy_check+0x1f4>
  103182:	c7 44 24 0c 5f 74 10 	movl   $0x10745f,0xc(%esp)
  103189:	00 
  10318a:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  103191:	00 
  103192:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103199:	00 
  10319a:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  1031a1:	e8 41 db ff ff       	call   100ce7 <__panic>
    p3 = alloc_pages(2);
  1031a6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1031ad:	e8 35 18 00 00       	call   1049e7 <alloc_pages>
  1031b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p3 == p0 + 4);
  1031b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031b8:	83 c0 50             	add    $0x50,%eax
  1031bb:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  1031be:	74 24                	je     1031e4 <buddy_check+0x232>
  1031c0:	c7 44 24 0c 6c 74 10 	movl   $0x10746c,0xc(%esp)
  1031c7:	00 
  1031c8:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  1031cf:	00 
  1031d0:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  1031d7:	00 
  1031d8:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  1031df:	e8 03 db ff ff       	call   100ce7 <__panic>
    assert(!PageProperty(p3) && !PageProperty(p3 + 1) && PageProperty(p3 + 2));
  1031e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1031e7:	83 c0 04             	add    $0x4,%eax
  1031ea:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  1031f1:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1031f4:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1031f7:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1031fa:	0f a3 10             	bt     %edx,(%eax)
  1031fd:	19 c0                	sbb    %eax,%eax
  1031ff:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
  103202:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
  103206:	0f 95 c0             	setne  %al
  103209:	0f b6 c0             	movzbl %al,%eax
  10320c:	85 c0                	test   %eax,%eax
  10320e:	75 5e                	jne    10326e <buddy_check+0x2bc>
  103210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103213:	83 c0 14             	add    $0x14,%eax
  103216:	83 c0 04             	add    $0x4,%eax
  103219:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  103220:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103223:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103226:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103229:	0f a3 10             	bt     %edx,(%eax)
  10322c:	19 c0                	sbb    %eax,%eax
  10322e:	89 45 9c             	mov    %eax,-0x64(%ebp)
    return oldbit != 0;
  103231:	83 7d 9c 00          	cmpl   $0x0,-0x64(%ebp)
  103235:	0f 95 c0             	setne  %al
  103238:	0f b6 c0             	movzbl %al,%eax
  10323b:	85 c0                	test   %eax,%eax
  10323d:	75 2f                	jne    10326e <buddy_check+0x2bc>
  10323f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103242:	83 c0 28             	add    $0x28,%eax
  103245:	83 c0 04             	add    $0x4,%eax
  103248:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
  10324f:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103252:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103255:	8b 55 98             	mov    -0x68(%ebp),%edx
  103258:	0f a3 10             	bt     %edx,(%eax)
  10325b:	19 c0                	sbb    %eax,%eax
  10325d:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
  103260:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
  103264:	0f 95 c0             	setne  %al
  103267:	0f b6 c0             	movzbl %al,%eax
  10326a:	85 c0                	test   %eax,%eax
  10326c:	75 24                	jne    103292 <buddy_check+0x2e0>
  10326e:	c7 44 24 0c 7c 74 10 	movl   $0x10747c,0xc(%esp)
  103275:	00 
  103276:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  10327d:	00 
  10327e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  103285:	00 
  103286:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  10328d:	e8 55 da ff ff       	call   100ce7 <__panic>

    free_pages(p1, 2);
  103292:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103299:	00 
  10329a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10329d:	89 04 24             	mov    %eax,(%esp)
  1032a0:	e8 7a 17 00 00       	call   104a1f <free_pages>
    assert(PageProperty(p1) && PageProperty(p1 + 1));
  1032a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032a8:	83 c0 04             	add    $0x4,%eax
  1032ab:	c7 45 8c 01 00 00 00 	movl   $0x1,-0x74(%ebp)
  1032b2:	89 45 88             	mov    %eax,-0x78(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1032b5:	8b 45 88             	mov    -0x78(%ebp),%eax
  1032b8:	8b 55 8c             	mov    -0x74(%ebp),%edx
  1032bb:	0f a3 10             	bt     %edx,(%eax)
  1032be:	19 c0                	sbb    %eax,%eax
  1032c0:	89 45 84             	mov    %eax,-0x7c(%ebp)
    return oldbit != 0;
  1032c3:	83 7d 84 00          	cmpl   $0x0,-0x7c(%ebp)
  1032c7:	0f 95 c0             	setne  %al
  1032ca:	0f b6 c0             	movzbl %al,%eax
  1032cd:	85 c0                	test   %eax,%eax
  1032cf:	74 3b                	je     10330c <buddy_check+0x35a>
  1032d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032d4:	83 c0 14             	add    $0x14,%eax
  1032d7:	83 c0 04             	add    $0x4,%eax
  1032da:	c7 45 80 01 00 00 00 	movl   $0x1,-0x80(%ebp)
  1032e1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1032e7:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  1032ed:	8b 55 80             	mov    -0x80(%ebp),%edx
  1032f0:	0f a3 10             	bt     %edx,(%eax)
  1032f3:	19 c0                	sbb    %eax,%eax
  1032f5:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    return oldbit != 0;
  1032fb:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
  103302:	0f 95 c0             	setne  %al
  103305:	0f b6 c0             	movzbl %al,%eax
  103308:	85 c0                	test   %eax,%eax
  10330a:	75 24                	jne    103330 <buddy_check+0x37e>
  10330c:	c7 44 24 0c c0 74 10 	movl   $0x1074c0,0xc(%esp)
  103313:	00 
  103314:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  10331b:	00 
  10331c:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  103323:	00 
  103324:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  10332b:	e8 b7 d9 ff ff       	call   100ce7 <__panic>
    assert(p1->ref == 0);
  103330:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103333:	8b 00                	mov    (%eax),%eax
  103335:	85 c0                	test   %eax,%eax
  103337:	74 24                	je     10335d <buddy_check+0x3ab>
  103339:	c7 44 24 0c e9 74 10 	movl   $0x1074e9,0xc(%esp)
  103340:	00 
  103341:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  103348:	00 
  103349:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  103350:	00 
  103351:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  103358:	e8 8a d9 ff ff       	call   100ce7 <__panic>

    free_pages(p0, 1);
  10335d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103364:	00 
  103365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103368:	89 04 24             	mov    %eax,(%esp)
  10336b:	e8 af 16 00 00       	call   104a1f <free_pages>
    free_pages(p2, 1);
  103370:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103377:	00 
  103378:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10337b:	89 04 24             	mov    %eax,(%esp)
  10337e:	e8 9c 16 00 00       	call   104a1f <free_pages>

    p2 = alloc_pages(2);
  103383:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10338a:	e8 58 16 00 00       	call   1049e7 <alloc_pages>
  10338f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p2 == p0);
  103392:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103395:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103398:	74 24                	je     1033be <buddy_check+0x40c>
  10339a:	c7 44 24 0c f6 74 10 	movl   $0x1074f6,0xc(%esp)
  1033a1:	00 
  1033a2:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  1033a9:	00 
  1033aa:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  1033b1:	00 
  1033b2:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  1033b9:	e8 29 d9 ff ff       	call   100ce7 <__panic>
    free_pages(p2, 2);
  1033be:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1033c5:	00 
  1033c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033c9:	89 04 24             	mov    %eax,(%esp)
  1033cc:	e8 4e 16 00 00       	call   104a1f <free_pages>
    assert((*(p2 + 1)).ref == 0);
  1033d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033d4:	83 c0 14             	add    $0x14,%eax
  1033d7:	8b 00                	mov    (%eax),%eax
  1033d9:	85 c0                	test   %eax,%eax
  1033db:	74 24                	je     103401 <buddy_check+0x44f>
  1033dd:	c7 44 24 0c ff 74 10 	movl   $0x1074ff,0xc(%esp)
  1033e4:	00 
  1033e5:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  1033ec:	00 
  1033ed:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1033f4:	00 
  1033f5:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  1033fc:	e8 e6 d8 ff ff       	call   100ce7 <__panic>
    assert(nr_free_pages() == all_pages >> 1);
  103401:	e8 4b 16 00 00       	call   104a51 <nr_free_pages>
  103406:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103409:	d1 fa                	sar    %edx
  10340b:	39 d0                	cmp    %edx,%eax
  10340d:	74 24                	je     103433 <buddy_check+0x481>
  10340f:	c7 44 24 0c 14 75 10 	movl   $0x107514,0xc(%esp)
  103416:	00 
  103417:	c7 44 24 08 36 73 10 	movl   $0x107336,0x8(%esp)
  10341e:	00 
  10341f:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  103426:	00 
  103427:	c7 04 24 4b 73 10 00 	movl   $0x10734b,(%esp)
  10342e:	e8 b4 d8 ff ff       	call   100ce7 <__panic>

    free_pages(p3, 2);
  103433:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10343a:	00 
  10343b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10343e:	89 04 24             	mov    %eax,(%esp)
  103441:	e8 d9 15 00 00       	call   104a1f <free_pages>
    p1 = alloc_pages(129);
  103446:	c7 04 24 81 00 00 00 	movl   $0x81,(%esp)
  10344d:	e8 95 15 00 00       	call   1049e7 <alloc_pages>
  103452:	89 45 ec             	mov    %eax,-0x14(%ebp)
    free_pages(p1, 256);
  103455:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  10345c:	00 
  10345d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103460:	89 04 24             	mov    %eax,(%esp)
  103463:	e8 b7 15 00 00       	call   104a1f <free_pages>
}
  103468:	c9                   	leave  
  103469:	c3                   	ret    

0010346a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10346a:	55                   	push   %ebp
  10346b:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10346d:	8b 55 08             	mov    0x8(%ebp),%edx
  103470:	a1 a4 cf 11 00       	mov    0x11cfa4,%eax
  103475:	29 c2                	sub    %eax,%edx
  103477:	89 d0                	mov    %edx,%eax
  103479:	c1 f8 02             	sar    $0x2,%eax
  10347c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103482:	5d                   	pop    %ebp
  103483:	c3                   	ret    

00103484 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103484:	55                   	push   %ebp
  103485:	89 e5                	mov    %esp,%ebp
  103487:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  10348a:	8b 45 08             	mov    0x8(%ebp),%eax
  10348d:	89 04 24             	mov    %eax,(%esp)
  103490:	e8 d5 ff ff ff       	call   10346a <page2ppn>
  103495:	c1 e0 0c             	shl    $0xc,%eax
}
  103498:	c9                   	leave  
  103499:	c3                   	ret    

0010349a <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  10349a:	55                   	push   %ebp
  10349b:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10349d:	8b 45 08             	mov    0x8(%ebp),%eax
  1034a0:	8b 00                	mov    (%eax),%eax
}
  1034a2:	5d                   	pop    %ebp
  1034a3:	c3                   	ret    

001034a4 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1034a4:	55                   	push   %ebp
  1034a5:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1034a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1034aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  1034ad:	89 10                	mov    %edx,(%eax)
}
  1034af:	5d                   	pop    %ebp
  1034b0:	c3                   	ret    

001034b1 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1034b1:	55                   	push   %ebp
  1034b2:	89 e5                	mov    %esp,%ebp
  1034b4:	83 ec 10             	sub    $0x10,%esp
  1034b7:	c7 45 fc 90 cf 11 00 	movl   $0x11cf90,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1034be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1034c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1034c4:	89 50 04             	mov    %edx,0x4(%eax)
  1034c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1034ca:	8b 50 04             	mov    0x4(%eax),%edx
  1034cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1034d0:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1034d2:	c7 05 98 cf 11 00 00 	movl   $0x0,0x11cf98
  1034d9:	00 00 00 
}
  1034dc:	c9                   	leave  
  1034dd:	c3                   	ret    

001034de <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1034de:	55                   	push   %ebp
  1034df:	89 e5                	mov    %esp,%ebp
  1034e1:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1034e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1034e8:	75 24                	jne    10350e <default_init_memmap+0x30>
  1034ea:	c7 44 24 0c 64 75 10 	movl   $0x107564,0xc(%esp)
  1034f1:	00 
  1034f2:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  1034f9:	00 
  1034fa:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  103501:	00 
  103502:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103509:	e8 d9 d7 ff ff       	call   100ce7 <__panic>
    struct Page *p = base;
  10350e:	8b 45 08             	mov    0x8(%ebp),%eax
  103511:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  103514:	eb 7d                	jmp    103593 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  103516:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103519:	83 c0 04             	add    $0x4,%eax
  10351c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  103523:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103526:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103529:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10352c:	0f a3 10             	bt     %edx,(%eax)
  10352f:	19 c0                	sbb    %eax,%eax
  103531:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  103534:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103538:	0f 95 c0             	setne  %al
  10353b:	0f b6 c0             	movzbl %al,%eax
  10353e:	85 c0                	test   %eax,%eax
  103540:	75 24                	jne    103566 <default_init_memmap+0x88>
  103542:	c7 44 24 0c 95 75 10 	movl   $0x107595,0xc(%esp)
  103549:	00 
  10354a:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103551:	00 
  103552:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  103559:	00 
  10355a:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103561:	e8 81 d7 ff ff       	call   100ce7 <__panic>
        p->flags = p->property = 0;
  103566:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103569:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  103570:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103573:	8b 50 08             	mov    0x8(%eax),%edx
  103576:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103579:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  10357c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103583:	00 
  103584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103587:	89 04 24             	mov    %eax,(%esp)
  10358a:	e8 15 ff ff ff       	call   1034a4 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  10358f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  103593:	8b 55 0c             	mov    0xc(%ebp),%edx
  103596:	89 d0                	mov    %edx,%eax
  103598:	c1 e0 02             	shl    $0x2,%eax
  10359b:	01 d0                	add    %edx,%eax
  10359d:	c1 e0 02             	shl    $0x2,%eax
  1035a0:	89 c2                	mov    %eax,%edx
  1035a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1035a5:	01 d0                	add    %edx,%eax
  1035a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1035aa:	0f 85 66 ff ff ff    	jne    103516 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  1035b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1035b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1035b6:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1035b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1035bc:	83 c0 04             	add    $0x4,%eax
  1035bf:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1035c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1035c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1035cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1035cf:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1035d2:	8b 15 98 cf 11 00    	mov    0x11cf98,%edx
  1035d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035db:	01 d0                	add    %edx,%eax
  1035dd:	a3 98 cf 11 00       	mov    %eax,0x11cf98
    list_add_before(&free_list, &(base->page_link));
  1035e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1035e5:	83 c0 0c             	add    $0xc,%eax
  1035e8:	c7 45 dc 90 cf 11 00 	movl   $0x11cf90,-0x24(%ebp)
  1035ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1035f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1035f5:	8b 00                	mov    (%eax),%eax
  1035f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1035fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1035fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103600:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103603:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  103606:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103609:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10360c:	89 10                	mov    %edx,(%eax)
  10360e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103611:	8b 10                	mov    (%eax),%edx
  103613:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103616:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103619:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10361c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10361f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103622:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103625:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103628:	89 10                	mov    %edx,(%eax)
}
  10362a:	c9                   	leave  
  10362b:	c3                   	ret    

0010362c <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  10362c:	55                   	push   %ebp
  10362d:	89 e5                	mov    %esp,%ebp
  10362f:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  103632:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103636:	75 24                	jne    10365c <default_alloc_pages+0x30>
  103638:	c7 44 24 0c 64 75 10 	movl   $0x107564,0xc(%esp)
  10363f:	00 
  103640:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103647:	00 
  103648:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  10364f:	00 
  103650:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103657:	e8 8b d6 ff ff       	call   100ce7 <__panic>
    if (n > nr_free) {
  10365c:	a1 98 cf 11 00       	mov    0x11cf98,%eax
  103661:	3b 45 08             	cmp    0x8(%ebp),%eax
  103664:	73 0a                	jae    103670 <default_alloc_pages+0x44>
        return NULL;
  103666:	b8 00 00 00 00       	mov    $0x0,%eax
  10366b:	e9 3d 01 00 00       	jmp    1037ad <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  103670:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  103677:	c7 45 f0 90 cf 11 00 	movl   $0x11cf90,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10367e:	eb 1c                	jmp    10369c <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  103680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103683:	83 e8 0c             	sub    $0xc,%eax
  103686:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  103689:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10368c:	8b 40 08             	mov    0x8(%eax),%eax
  10368f:	3b 45 08             	cmp    0x8(%ebp),%eax
  103692:	72 08                	jb     10369c <default_alloc_pages+0x70>
            page = p;
  103694:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  10369a:	eb 18                	jmp    1036b4 <default_alloc_pages+0x88>
  10369c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10369f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1036a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036a5:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1036a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036ab:	81 7d f0 90 cf 11 00 	cmpl   $0x11cf90,-0x10(%ebp)
  1036b2:	75 cc                	jne    103680 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  1036b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1036b8:	0f 84 ec 00 00 00    	je     1037aa <default_alloc_pages+0x17e>
        if (page->property > n) {
  1036be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036c1:	8b 40 08             	mov    0x8(%eax),%eax
  1036c4:	3b 45 08             	cmp    0x8(%ebp),%eax
  1036c7:	0f 86 8c 00 00 00    	jbe    103759 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
  1036cd:	8b 55 08             	mov    0x8(%ebp),%edx
  1036d0:	89 d0                	mov    %edx,%eax
  1036d2:	c1 e0 02             	shl    $0x2,%eax
  1036d5:	01 d0                	add    %edx,%eax
  1036d7:	c1 e0 02             	shl    $0x2,%eax
  1036da:	89 c2                	mov    %eax,%edx
  1036dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036df:	01 d0                	add    %edx,%eax
  1036e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
			SetPageProperty(p);
  1036e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1036e7:	83 c0 04             	add    $0x4,%eax
  1036ea:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1036f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1036f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1036f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1036fa:	0f ab 10             	bts    %edx,(%eax)
            p->property = page->property - n;
  1036fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103700:	8b 40 08             	mov    0x8(%eax),%eax
  103703:	2b 45 08             	sub    0x8(%ebp),%eax
  103706:	89 c2                	mov    %eax,%edx
  103708:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10370b:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
  10370e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103711:	83 c0 0c             	add    $0xc,%eax
  103714:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103717:	83 c2 0c             	add    $0xc,%edx
  10371a:	89 55 d8             	mov    %edx,-0x28(%ebp)
  10371d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  103720:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103723:	8b 40 04             	mov    0x4(%eax),%eax
  103726:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103729:	89 55 d0             	mov    %edx,-0x30(%ebp)
  10372c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10372f:	89 55 cc             	mov    %edx,-0x34(%ebp)
  103732:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  103735:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103738:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10373b:	89 10                	mov    %edx,(%eax)
  10373d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103740:	8b 10                	mov    (%eax),%edx
  103742:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103745:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103748:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10374b:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10374e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103751:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103754:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103757:	89 10                	mov    %edx,(%eax)
    }
	list_del(&(page->page_link));
  103759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10375c:	83 c0 0c             	add    $0xc,%eax
  10375f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  103762:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103765:	8b 40 04             	mov    0x4(%eax),%eax
  103768:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10376b:	8b 12                	mov    (%edx),%edx
  10376d:	89 55 c0             	mov    %edx,-0x40(%ebp)
  103770:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  103773:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103776:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103779:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10377c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10377f:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103782:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  103784:	a1 98 cf 11 00       	mov    0x11cf98,%eax
  103789:	2b 45 08             	sub    0x8(%ebp),%eax
  10378c:	a3 98 cf 11 00       	mov    %eax,0x11cf98
        ClearPageProperty(page);
  103791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103794:	83 c0 04             	add    $0x4,%eax
  103797:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  10379e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1037a1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1037a4:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1037a7:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  1037aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1037ad:	c9                   	leave  
  1037ae:	c3                   	ret    

001037af <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  1037af:	55                   	push   %ebp
  1037b0:	89 e5                	mov    %esp,%ebp
  1037b2:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  1037b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1037bc:	75 24                	jne    1037e2 <default_free_pages+0x33>
  1037be:	c7 44 24 0c 64 75 10 	movl   $0x107564,0xc(%esp)
  1037c5:	00 
  1037c6:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  1037cd:	00 
  1037ce:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  1037d5:	00 
  1037d6:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  1037dd:	e8 05 d5 ff ff       	call   100ce7 <__panic>
    struct Page *p = base;
  1037e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1037e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1037e8:	e9 9d 00 00 00       	jmp    10388a <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  1037ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037f0:	83 c0 04             	add    $0x4,%eax
  1037f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1037fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103800:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103803:	0f a3 10             	bt     %edx,(%eax)
  103806:	19 c0                	sbb    %eax,%eax
  103808:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10380b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10380f:	0f 95 c0             	setne  %al
  103812:	0f b6 c0             	movzbl %al,%eax
  103815:	85 c0                	test   %eax,%eax
  103817:	75 2c                	jne    103845 <default_free_pages+0x96>
  103819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10381c:	83 c0 04             	add    $0x4,%eax
  10381f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  103826:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103829:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10382c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10382f:	0f a3 10             	bt     %edx,(%eax)
  103832:	19 c0                	sbb    %eax,%eax
  103834:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  103837:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  10383b:	0f 95 c0             	setne  %al
  10383e:	0f b6 c0             	movzbl %al,%eax
  103841:	85 c0                	test   %eax,%eax
  103843:	74 24                	je     103869 <default_free_pages+0xba>
  103845:	c7 44 24 0c a8 75 10 	movl   $0x1075a8,0xc(%esp)
  10384c:	00 
  10384d:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103854:	00 
  103855:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  10385c:	00 
  10385d:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103864:	e8 7e d4 ff ff       	call   100ce7 <__panic>
        p->flags = 0;
  103869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10386c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  103873:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10387a:	00 
  10387b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10387e:	89 04 24             	mov    %eax,(%esp)
  103881:	e8 1e fc ff ff       	call   1034a4 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  103886:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10388a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10388d:	89 d0                	mov    %edx,%eax
  10388f:	c1 e0 02             	shl    $0x2,%eax
  103892:	01 d0                	add    %edx,%eax
  103894:	c1 e0 02             	shl    $0x2,%eax
  103897:	89 c2                	mov    %eax,%edx
  103899:	8b 45 08             	mov    0x8(%ebp),%eax
  10389c:	01 d0                	add    %edx,%eax
  10389e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1038a1:	0f 85 46 ff ff ff    	jne    1037ed <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  1038a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1038aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  1038ad:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1038b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1038b3:	83 c0 04             	add    $0x4,%eax
  1038b6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  1038bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1038c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1038c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1038c6:	0f ab 10             	bts    %edx,(%eax)
  1038c9:	c7 45 cc 90 cf 11 00 	movl   $0x11cf90,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1038d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1038d3:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  1038d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1038d9:	e9 08 01 00 00       	jmp    1039e6 <default_free_pages+0x237>
        p = le2page(le, page_link);
  1038de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038e1:	83 e8 0c             	sub    $0xc,%eax
  1038e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1038e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1038ed:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1038f0:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  1038f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
  1038f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1038f9:	8b 50 08             	mov    0x8(%eax),%edx
  1038fc:	89 d0                	mov    %edx,%eax
  1038fe:	c1 e0 02             	shl    $0x2,%eax
  103901:	01 d0                	add    %edx,%eax
  103903:	c1 e0 02             	shl    $0x2,%eax
  103906:	89 c2                	mov    %eax,%edx
  103908:	8b 45 08             	mov    0x8(%ebp),%eax
  10390b:	01 d0                	add    %edx,%eax
  10390d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103910:	75 5a                	jne    10396c <default_free_pages+0x1bd>
            base->property += p->property;
  103912:	8b 45 08             	mov    0x8(%ebp),%eax
  103915:	8b 50 08             	mov    0x8(%eax),%edx
  103918:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10391b:	8b 40 08             	mov    0x8(%eax),%eax
  10391e:	01 c2                	add    %eax,%edx
  103920:	8b 45 08             	mov    0x8(%ebp),%eax
  103923:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  103926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103929:	83 c0 04             	add    $0x4,%eax
  10392c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  103933:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103936:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103939:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10393c:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  10393f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103942:	83 c0 0c             	add    $0xc,%eax
  103945:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  103948:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10394b:	8b 40 04             	mov    0x4(%eax),%eax
  10394e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103951:	8b 12                	mov    (%edx),%edx
  103953:	89 55 b8             	mov    %edx,-0x48(%ebp)
  103956:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  103959:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10395c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10395f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103962:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103965:	8b 55 b8             	mov    -0x48(%ebp),%edx
  103968:	89 10                	mov    %edx,(%eax)
  10396a:	eb 7a                	jmp    1039e6 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  10396c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10396f:	8b 50 08             	mov    0x8(%eax),%edx
  103972:	89 d0                	mov    %edx,%eax
  103974:	c1 e0 02             	shl    $0x2,%eax
  103977:	01 d0                	add    %edx,%eax
  103979:	c1 e0 02             	shl    $0x2,%eax
  10397c:	89 c2                	mov    %eax,%edx
  10397e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103981:	01 d0                	add    %edx,%eax
  103983:	3b 45 08             	cmp    0x8(%ebp),%eax
  103986:	75 5e                	jne    1039e6 <default_free_pages+0x237>
            p->property += base->property;
  103988:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10398b:	8b 50 08             	mov    0x8(%eax),%edx
  10398e:	8b 45 08             	mov    0x8(%ebp),%eax
  103991:	8b 40 08             	mov    0x8(%eax),%eax
  103994:	01 c2                	add    %eax,%edx
  103996:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103999:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  10399c:	8b 45 08             	mov    0x8(%ebp),%eax
  10399f:	83 c0 04             	add    $0x4,%eax
  1039a2:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  1039a9:	89 45 ac             	mov    %eax,-0x54(%ebp)
  1039ac:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1039af:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1039b2:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  1039b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039b8:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  1039bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039be:	83 c0 0c             	add    $0xc,%eax
  1039c1:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1039c4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1039c7:	8b 40 04             	mov    0x4(%eax),%eax
  1039ca:	8b 55 a8             	mov    -0x58(%ebp),%edx
  1039cd:	8b 12                	mov    (%edx),%edx
  1039cf:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  1039d2:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1039d5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1039d8:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1039db:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1039de:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1039e1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1039e4:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  1039e6:	81 7d f0 90 cf 11 00 	cmpl   $0x11cf90,-0x10(%ebp)
  1039ed:	0f 85 eb fe ff ff    	jne    1038de <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  1039f3:	8b 15 98 cf 11 00    	mov    0x11cf98,%edx
  1039f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1039fc:	01 d0                	add    %edx,%eax
  1039fe:	a3 98 cf 11 00       	mov    %eax,0x11cf98
  103a03:	c7 45 9c 90 cf 11 00 	movl   $0x11cf90,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103a0a:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103a0d:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  103a10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  103a13:	eb 76                	jmp    103a8b <default_free_pages+0x2dc>
        p = le2page(le, page_link);
  103a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a18:	83 e8 0c             	sub    $0xc,%eax
  103a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  103a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  103a21:	8b 50 08             	mov    0x8(%eax),%edx
  103a24:	89 d0                	mov    %edx,%eax
  103a26:	c1 e0 02             	shl    $0x2,%eax
  103a29:	01 d0                	add    %edx,%eax
  103a2b:	c1 e0 02             	shl    $0x2,%eax
  103a2e:	89 c2                	mov    %eax,%edx
  103a30:	8b 45 08             	mov    0x8(%ebp),%eax
  103a33:	01 d0                	add    %edx,%eax
  103a35:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103a38:	77 42                	ja     103a7c <default_free_pages+0x2cd>
            assert(base + base->property != p);
  103a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  103a3d:	8b 50 08             	mov    0x8(%eax),%edx
  103a40:	89 d0                	mov    %edx,%eax
  103a42:	c1 e0 02             	shl    $0x2,%eax
  103a45:	01 d0                	add    %edx,%eax
  103a47:	c1 e0 02             	shl    $0x2,%eax
  103a4a:	89 c2                	mov    %eax,%edx
  103a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  103a4f:	01 d0                	add    %edx,%eax
  103a51:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103a54:	75 24                	jne    103a7a <default_free_pages+0x2cb>
  103a56:	c7 44 24 0c cd 75 10 	movl   $0x1075cd,0xc(%esp)
  103a5d:	00 
  103a5e:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103a65:	00 
  103a66:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
  103a6d:	00 
  103a6e:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103a75:	e8 6d d2 ff ff       	call   100ce7 <__panic>
            break;
  103a7a:	eb 18                	jmp    103a94 <default_free_pages+0x2e5>
  103a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a7f:	89 45 98             	mov    %eax,-0x68(%ebp)
  103a82:	8b 45 98             	mov    -0x68(%ebp),%eax
  103a85:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
  103a88:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
  103a8b:	81 7d f0 90 cf 11 00 	cmpl   $0x11cf90,-0x10(%ebp)
  103a92:	75 81                	jne    103a15 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
  103a94:	8b 45 08             	mov    0x8(%ebp),%eax
  103a97:	8d 50 0c             	lea    0xc(%eax),%edx
  103a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a9d:	89 45 94             	mov    %eax,-0x6c(%ebp)
  103aa0:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  103aa3:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103aa6:	8b 00                	mov    (%eax),%eax
  103aa8:	8b 55 90             	mov    -0x70(%ebp),%edx
  103aab:	89 55 8c             	mov    %edx,-0x74(%ebp)
  103aae:	89 45 88             	mov    %eax,-0x78(%ebp)
  103ab1:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103ab4:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  103ab7:	8b 45 84             	mov    -0x7c(%ebp),%eax
  103aba:	8b 55 8c             	mov    -0x74(%ebp),%edx
  103abd:	89 10                	mov    %edx,(%eax)
  103abf:	8b 45 84             	mov    -0x7c(%ebp),%eax
  103ac2:	8b 10                	mov    (%eax),%edx
  103ac4:	8b 45 88             	mov    -0x78(%ebp),%eax
  103ac7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103aca:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103acd:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103ad0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103ad3:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103ad6:	8b 55 88             	mov    -0x78(%ebp),%edx
  103ad9:	89 10                	mov    %edx,(%eax)
}
  103adb:	c9                   	leave  
  103adc:	c3                   	ret    

00103add <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  103add:	55                   	push   %ebp
  103ade:	89 e5                	mov    %esp,%ebp
    return nr_free;
  103ae0:	a1 98 cf 11 00       	mov    0x11cf98,%eax
}
  103ae5:	5d                   	pop    %ebp
  103ae6:	c3                   	ret    

00103ae7 <basic_check>:

static void
basic_check(void) {
  103ae7:	55                   	push   %ebp
  103ae8:	89 e5                	mov    %esp,%ebp
  103aea:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  103aed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103af7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  103b00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103b07:	e8 db 0e 00 00       	call   1049e7 <alloc_pages>
  103b0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103b0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103b13:	75 24                	jne    103b39 <basic_check+0x52>
  103b15:	c7 44 24 0c e8 75 10 	movl   $0x1075e8,0xc(%esp)
  103b1c:	00 
  103b1d:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103b24:	00 
  103b25:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  103b2c:	00 
  103b2d:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103b34:	e8 ae d1 ff ff       	call   100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103b39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103b40:	e8 a2 0e 00 00       	call   1049e7 <alloc_pages>
  103b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103b4c:	75 24                	jne    103b72 <basic_check+0x8b>
  103b4e:	c7 44 24 0c 04 76 10 	movl   $0x107604,0xc(%esp)
  103b55:	00 
  103b56:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103b5d:	00 
  103b5e:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  103b65:	00 
  103b66:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103b6d:	e8 75 d1 ff ff       	call   100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
  103b72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103b79:	e8 69 0e 00 00       	call   1049e7 <alloc_pages>
  103b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103b81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103b85:	75 24                	jne    103bab <basic_check+0xc4>
  103b87:	c7 44 24 0c 20 76 10 	movl   $0x107620,0xc(%esp)
  103b8e:	00 
  103b8f:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103b96:	00 
  103b97:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  103b9e:	00 
  103b9f:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103ba6:	e8 3c d1 ff ff       	call   100ce7 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  103bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103bae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103bb1:	74 10                	je     103bc3 <basic_check+0xdc>
  103bb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103bb6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103bb9:	74 08                	je     103bc3 <basic_check+0xdc>
  103bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103bbe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103bc1:	75 24                	jne    103be7 <basic_check+0x100>
  103bc3:	c7 44 24 0c 3c 76 10 	movl   $0x10763c,0xc(%esp)
  103bca:	00 
  103bcb:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103bd2:	00 
  103bd3:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  103bda:	00 
  103bdb:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103be2:	e8 00 d1 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  103be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103bea:	89 04 24             	mov    %eax,(%esp)
  103bed:	e8 a8 f8 ff ff       	call   10349a <page_ref>
  103bf2:	85 c0                	test   %eax,%eax
  103bf4:	75 1e                	jne    103c14 <basic_check+0x12d>
  103bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103bf9:	89 04 24             	mov    %eax,(%esp)
  103bfc:	e8 99 f8 ff ff       	call   10349a <page_ref>
  103c01:	85 c0                	test   %eax,%eax
  103c03:	75 0f                	jne    103c14 <basic_check+0x12d>
  103c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c08:	89 04 24             	mov    %eax,(%esp)
  103c0b:	e8 8a f8 ff ff       	call   10349a <page_ref>
  103c10:	85 c0                	test   %eax,%eax
  103c12:	74 24                	je     103c38 <basic_check+0x151>
  103c14:	c7 44 24 0c 60 76 10 	movl   $0x107660,0xc(%esp)
  103c1b:	00 
  103c1c:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103c23:	00 
  103c24:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  103c2b:	00 
  103c2c:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103c33:	e8 af d0 ff ff       	call   100ce7 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c3b:	89 04 24             	mov    %eax,(%esp)
  103c3e:	e8 41 f8 ff ff       	call   103484 <page2pa>
  103c43:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
  103c49:	c1 e2 0c             	shl    $0xc,%edx
  103c4c:	39 d0                	cmp    %edx,%eax
  103c4e:	72 24                	jb     103c74 <basic_check+0x18d>
  103c50:	c7 44 24 0c 9c 76 10 	movl   $0x10769c,0xc(%esp)
  103c57:	00 
  103c58:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103c5f:	00 
  103c60:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  103c67:	00 
  103c68:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103c6f:	e8 73 d0 ff ff       	call   100ce7 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  103c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c77:	89 04 24             	mov    %eax,(%esp)
  103c7a:	e8 05 f8 ff ff       	call   103484 <page2pa>
  103c7f:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
  103c85:	c1 e2 0c             	shl    $0xc,%edx
  103c88:	39 d0                	cmp    %edx,%eax
  103c8a:	72 24                	jb     103cb0 <basic_check+0x1c9>
  103c8c:	c7 44 24 0c b9 76 10 	movl   $0x1076b9,0xc(%esp)
  103c93:	00 
  103c94:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103c9b:	00 
  103c9c:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  103ca3:	00 
  103ca4:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103cab:	e8 37 d0 ff ff       	call   100ce7 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cb3:	89 04 24             	mov    %eax,(%esp)
  103cb6:	e8 c9 f7 ff ff       	call   103484 <page2pa>
  103cbb:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
  103cc1:	c1 e2 0c             	shl    $0xc,%edx
  103cc4:	39 d0                	cmp    %edx,%eax
  103cc6:	72 24                	jb     103cec <basic_check+0x205>
  103cc8:	c7 44 24 0c d6 76 10 	movl   $0x1076d6,0xc(%esp)
  103ccf:	00 
  103cd0:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103cd7:	00 
  103cd8:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  103cdf:	00 
  103ce0:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103ce7:	e8 fb cf ff ff       	call   100ce7 <__panic>

    list_entry_t free_list_store = free_list;
  103cec:	a1 90 cf 11 00       	mov    0x11cf90,%eax
  103cf1:	8b 15 94 cf 11 00    	mov    0x11cf94,%edx
  103cf7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103cfa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103cfd:	c7 45 e0 90 cf 11 00 	movl   $0x11cf90,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103d07:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103d0a:	89 50 04             	mov    %edx,0x4(%eax)
  103d0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103d10:	8b 50 04             	mov    0x4(%eax),%edx
  103d13:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103d16:	89 10                	mov    %edx,(%eax)
  103d18:	c7 45 dc 90 cf 11 00 	movl   $0x11cf90,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103d1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103d22:	8b 40 04             	mov    0x4(%eax),%eax
  103d25:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103d28:	0f 94 c0             	sete   %al
  103d2b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103d2e:	85 c0                	test   %eax,%eax
  103d30:	75 24                	jne    103d56 <basic_check+0x26f>
  103d32:	c7 44 24 0c f3 76 10 	movl   $0x1076f3,0xc(%esp)
  103d39:	00 
  103d3a:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103d41:	00 
  103d42:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  103d49:	00 
  103d4a:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103d51:	e8 91 cf ff ff       	call   100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
  103d56:	a1 98 cf 11 00       	mov    0x11cf98,%eax
  103d5b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  103d5e:	c7 05 98 cf 11 00 00 	movl   $0x0,0x11cf98
  103d65:	00 00 00 

    assert(alloc_page() == NULL);
  103d68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103d6f:	e8 73 0c 00 00       	call   1049e7 <alloc_pages>
  103d74:	85 c0                	test   %eax,%eax
  103d76:	74 24                	je     103d9c <basic_check+0x2b5>
  103d78:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  103d7f:	00 
  103d80:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103d87:	00 
  103d88:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  103d8f:	00 
  103d90:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103d97:	e8 4b cf ff ff       	call   100ce7 <__panic>

    free_page(p0);
  103d9c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103da3:	00 
  103da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103da7:	89 04 24             	mov    %eax,(%esp)
  103daa:	e8 70 0c 00 00       	call   104a1f <free_pages>
    free_page(p1);
  103daf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103db6:	00 
  103db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103dba:	89 04 24             	mov    %eax,(%esp)
  103dbd:	e8 5d 0c 00 00       	call   104a1f <free_pages>
    free_page(p2);
  103dc2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103dc9:	00 
  103dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103dcd:	89 04 24             	mov    %eax,(%esp)
  103dd0:	e8 4a 0c 00 00       	call   104a1f <free_pages>
    assert(nr_free == 3);
  103dd5:	a1 98 cf 11 00       	mov    0x11cf98,%eax
  103dda:	83 f8 03             	cmp    $0x3,%eax
  103ddd:	74 24                	je     103e03 <basic_check+0x31c>
  103ddf:	c7 44 24 0c 1f 77 10 	movl   $0x10771f,0xc(%esp)
  103de6:	00 
  103de7:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103dee:	00 
  103def:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  103df6:	00 
  103df7:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103dfe:	e8 e4 ce ff ff       	call   100ce7 <__panic>

    assert((p0 = alloc_page()) != NULL);
  103e03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103e0a:	e8 d8 0b 00 00       	call   1049e7 <alloc_pages>
  103e0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103e12:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103e16:	75 24                	jne    103e3c <basic_check+0x355>
  103e18:	c7 44 24 0c e8 75 10 	movl   $0x1075e8,0xc(%esp)
  103e1f:	00 
  103e20:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103e27:	00 
  103e28:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  103e2f:	00 
  103e30:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103e37:	e8 ab ce ff ff       	call   100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103e3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103e43:	e8 9f 0b 00 00       	call   1049e7 <alloc_pages>
  103e48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103e4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103e4f:	75 24                	jne    103e75 <basic_check+0x38e>
  103e51:	c7 44 24 0c 04 76 10 	movl   $0x107604,0xc(%esp)
  103e58:	00 
  103e59:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103e60:	00 
  103e61:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  103e68:	00 
  103e69:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103e70:	e8 72 ce ff ff       	call   100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
  103e75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103e7c:	e8 66 0b 00 00       	call   1049e7 <alloc_pages>
  103e81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103e84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103e88:	75 24                	jne    103eae <basic_check+0x3c7>
  103e8a:	c7 44 24 0c 20 76 10 	movl   $0x107620,0xc(%esp)
  103e91:	00 
  103e92:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103e99:	00 
  103e9a:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  103ea1:	00 
  103ea2:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103ea9:	e8 39 ce ff ff       	call   100ce7 <__panic>

    assert(alloc_page() == NULL);
  103eae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103eb5:	e8 2d 0b 00 00       	call   1049e7 <alloc_pages>
  103eba:	85 c0                	test   %eax,%eax
  103ebc:	74 24                	je     103ee2 <basic_check+0x3fb>
  103ebe:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  103ec5:	00 
  103ec6:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103ecd:	00 
  103ece:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  103ed5:	00 
  103ed6:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103edd:	e8 05 ce ff ff       	call   100ce7 <__panic>

    free_page(p0);
  103ee2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103ee9:	00 
  103eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103eed:	89 04 24             	mov    %eax,(%esp)
  103ef0:	e8 2a 0b 00 00       	call   104a1f <free_pages>
  103ef5:	c7 45 d8 90 cf 11 00 	movl   $0x11cf90,-0x28(%ebp)
  103efc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103eff:	8b 40 04             	mov    0x4(%eax),%eax
  103f02:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103f05:	0f 94 c0             	sete   %al
  103f08:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103f0b:	85 c0                	test   %eax,%eax
  103f0d:	74 24                	je     103f33 <basic_check+0x44c>
  103f0f:	c7 44 24 0c 2c 77 10 	movl   $0x10772c,0xc(%esp)
  103f16:	00 
  103f17:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103f1e:	00 
  103f1f:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  103f26:	00 
  103f27:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103f2e:	e8 b4 cd ff ff       	call   100ce7 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103f33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f3a:	e8 a8 0a 00 00       	call   1049e7 <alloc_pages>
  103f3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103f45:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103f48:	74 24                	je     103f6e <basic_check+0x487>
  103f4a:	c7 44 24 0c 44 77 10 	movl   $0x107744,0xc(%esp)
  103f51:	00 
  103f52:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103f59:	00 
  103f5a:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  103f61:	00 
  103f62:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103f69:	e8 79 cd ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  103f6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f75:	e8 6d 0a 00 00       	call   1049e7 <alloc_pages>
  103f7a:	85 c0                	test   %eax,%eax
  103f7c:	74 24                	je     103fa2 <basic_check+0x4bb>
  103f7e:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  103f85:	00 
  103f86:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103f8d:	00 
  103f8e:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  103f95:	00 
  103f96:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103f9d:	e8 45 cd ff ff       	call   100ce7 <__panic>

    assert(nr_free == 0);
  103fa2:	a1 98 cf 11 00       	mov    0x11cf98,%eax
  103fa7:	85 c0                	test   %eax,%eax
  103fa9:	74 24                	je     103fcf <basic_check+0x4e8>
  103fab:	c7 44 24 0c 5d 77 10 	movl   $0x10775d,0xc(%esp)
  103fb2:	00 
  103fb3:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  103fba:	00 
  103fbb:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  103fc2:	00 
  103fc3:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  103fca:	e8 18 cd ff ff       	call   100ce7 <__panic>
    free_list = free_list_store;
  103fcf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103fd2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103fd5:	a3 90 cf 11 00       	mov    %eax,0x11cf90
  103fda:	89 15 94 cf 11 00    	mov    %edx,0x11cf94
    nr_free = nr_free_store;
  103fe0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103fe3:	a3 98 cf 11 00       	mov    %eax,0x11cf98

    free_page(p);
  103fe8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fef:	00 
  103ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ff3:	89 04 24             	mov    %eax,(%esp)
  103ff6:	e8 24 0a 00 00       	call   104a1f <free_pages>
    free_page(p1);
  103ffb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104002:	00 
  104003:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104006:	89 04 24             	mov    %eax,(%esp)
  104009:	e8 11 0a 00 00       	call   104a1f <free_pages>
    free_page(p2);
  10400e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104015:	00 
  104016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104019:	89 04 24             	mov    %eax,(%esp)
  10401c:	e8 fe 09 00 00       	call   104a1f <free_pages>
}
  104021:	c9                   	leave  
  104022:	c3                   	ret    

00104023 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104023:	55                   	push   %ebp
  104024:	89 e5                	mov    %esp,%ebp
  104026:	53                   	push   %ebx
  104027:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  10402d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104034:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  10403b:	c7 45 ec 90 cf 11 00 	movl   $0x11cf90,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104042:	eb 6b                	jmp    1040af <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  104044:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104047:	83 e8 0c             	sub    $0xc,%eax
  10404a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  10404d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104050:	83 c0 04             	add    $0x4,%eax
  104053:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  10405a:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10405d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104060:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104063:	0f a3 10             	bt     %edx,(%eax)
  104066:	19 c0                	sbb    %eax,%eax
  104068:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  10406b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  10406f:	0f 95 c0             	setne  %al
  104072:	0f b6 c0             	movzbl %al,%eax
  104075:	85 c0                	test   %eax,%eax
  104077:	75 24                	jne    10409d <default_check+0x7a>
  104079:	c7 44 24 0c 6a 77 10 	movl   $0x10776a,0xc(%esp)
  104080:	00 
  104081:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104088:	00 
  104089:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104090:	00 
  104091:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104098:	e8 4a cc ff ff       	call   100ce7 <__panic>
        count ++, total += p->property;
  10409d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1040a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1040a4:	8b 50 08             	mov    0x8(%eax),%edx
  1040a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1040aa:	01 d0                	add    %edx,%eax
  1040ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1040af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1040b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1040b5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1040b8:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1040bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1040be:	81 7d ec 90 cf 11 00 	cmpl   $0x11cf90,-0x14(%ebp)
  1040c5:	0f 85 79 ff ff ff    	jne    104044 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  1040cb:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  1040ce:	e8 7e 09 00 00       	call   104a51 <nr_free_pages>
  1040d3:	39 c3                	cmp    %eax,%ebx
  1040d5:	74 24                	je     1040fb <default_check+0xd8>
  1040d7:	c7 44 24 0c 7a 77 10 	movl   $0x10777a,0xc(%esp)
  1040de:	00 
  1040df:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  1040e6:	00 
  1040e7:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  1040ee:	00 
  1040ef:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  1040f6:	e8 ec cb ff ff       	call   100ce7 <__panic>

    basic_check();
  1040fb:	e8 e7 f9 ff ff       	call   103ae7 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104100:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104107:	e8 db 08 00 00       	call   1049e7 <alloc_pages>
  10410c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  10410f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104113:	75 24                	jne    104139 <default_check+0x116>
  104115:	c7 44 24 0c 93 77 10 	movl   $0x107793,0xc(%esp)
  10411c:	00 
  10411d:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104124:	00 
  104125:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  10412c:	00 
  10412d:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104134:	e8 ae cb ff ff       	call   100ce7 <__panic>
    assert(!PageProperty(p0));
  104139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10413c:	83 c0 04             	add    $0x4,%eax
  10413f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104146:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104149:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10414c:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10414f:	0f a3 10             	bt     %edx,(%eax)
  104152:	19 c0                	sbb    %eax,%eax
  104154:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104157:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  10415b:	0f 95 c0             	setne  %al
  10415e:	0f b6 c0             	movzbl %al,%eax
  104161:	85 c0                	test   %eax,%eax
  104163:	74 24                	je     104189 <default_check+0x166>
  104165:	c7 44 24 0c 9e 77 10 	movl   $0x10779e,0xc(%esp)
  10416c:	00 
  10416d:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104174:	00 
  104175:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  10417c:	00 
  10417d:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104184:	e8 5e cb ff ff       	call   100ce7 <__panic>

    list_entry_t free_list_store = free_list;
  104189:	a1 90 cf 11 00       	mov    0x11cf90,%eax
  10418e:	8b 15 94 cf 11 00    	mov    0x11cf94,%edx
  104194:	89 45 80             	mov    %eax,-0x80(%ebp)
  104197:	89 55 84             	mov    %edx,-0x7c(%ebp)
  10419a:	c7 45 b4 90 cf 11 00 	movl   $0x11cf90,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1041a1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1041a4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1041a7:	89 50 04             	mov    %edx,0x4(%eax)
  1041aa:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1041ad:	8b 50 04             	mov    0x4(%eax),%edx
  1041b0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1041b3:	89 10                	mov    %edx,(%eax)
  1041b5:	c7 45 b0 90 cf 11 00 	movl   $0x11cf90,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1041bc:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1041bf:	8b 40 04             	mov    0x4(%eax),%eax
  1041c2:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  1041c5:	0f 94 c0             	sete   %al
  1041c8:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1041cb:	85 c0                	test   %eax,%eax
  1041cd:	75 24                	jne    1041f3 <default_check+0x1d0>
  1041cf:	c7 44 24 0c f3 76 10 	movl   $0x1076f3,0xc(%esp)
  1041d6:	00 
  1041d7:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  1041de:	00 
  1041df:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  1041e6:	00 
  1041e7:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  1041ee:	e8 f4 ca ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  1041f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1041fa:	e8 e8 07 00 00       	call   1049e7 <alloc_pages>
  1041ff:	85 c0                	test   %eax,%eax
  104201:	74 24                	je     104227 <default_check+0x204>
  104203:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  10420a:	00 
  10420b:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104212:	00 
  104213:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  10421a:	00 
  10421b:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104222:	e8 c0 ca ff ff       	call   100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
  104227:	a1 98 cf 11 00       	mov    0x11cf98,%eax
  10422c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  10422f:	c7 05 98 cf 11 00 00 	movl   $0x0,0x11cf98
  104236:	00 00 00 

    free_pages(p0 + 2, 3);
  104239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10423c:	83 c0 28             	add    $0x28,%eax
  10423f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104246:	00 
  104247:	89 04 24             	mov    %eax,(%esp)
  10424a:	e8 d0 07 00 00       	call   104a1f <free_pages>
    assert(alloc_pages(4) == NULL);
  10424f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104256:	e8 8c 07 00 00       	call   1049e7 <alloc_pages>
  10425b:	85 c0                	test   %eax,%eax
  10425d:	74 24                	je     104283 <default_check+0x260>
  10425f:	c7 44 24 0c b0 77 10 	movl   $0x1077b0,0xc(%esp)
  104266:	00 
  104267:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  10426e:	00 
  10426f:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  104276:	00 
  104277:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  10427e:	e8 64 ca ff ff       	call   100ce7 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104286:	83 c0 28             	add    $0x28,%eax
  104289:	83 c0 04             	add    $0x4,%eax
  10428c:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  104293:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104296:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104299:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10429c:	0f a3 10             	bt     %edx,(%eax)
  10429f:	19 c0                	sbb    %eax,%eax
  1042a1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1042a4:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1042a8:	0f 95 c0             	setne  %al
  1042ab:	0f b6 c0             	movzbl %al,%eax
  1042ae:	85 c0                	test   %eax,%eax
  1042b0:	74 0e                	je     1042c0 <default_check+0x29d>
  1042b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042b5:	83 c0 28             	add    $0x28,%eax
  1042b8:	8b 40 08             	mov    0x8(%eax),%eax
  1042bb:	83 f8 03             	cmp    $0x3,%eax
  1042be:	74 24                	je     1042e4 <default_check+0x2c1>
  1042c0:	c7 44 24 0c c8 77 10 	movl   $0x1077c8,0xc(%esp)
  1042c7:	00 
  1042c8:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  1042cf:	00 
  1042d0:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1042d7:	00 
  1042d8:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  1042df:	e8 03 ca ff ff       	call   100ce7 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1042e4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  1042eb:	e8 f7 06 00 00       	call   1049e7 <alloc_pages>
  1042f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1042f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1042f7:	75 24                	jne    10431d <default_check+0x2fa>
  1042f9:	c7 44 24 0c f4 77 10 	movl   $0x1077f4,0xc(%esp)
  104300:	00 
  104301:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104308:	00 
  104309:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104310:	00 
  104311:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104318:	e8 ca c9 ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  10431d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104324:	e8 be 06 00 00       	call   1049e7 <alloc_pages>
  104329:	85 c0                	test   %eax,%eax
  10432b:	74 24                	je     104351 <default_check+0x32e>
  10432d:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  104334:	00 
  104335:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  10433c:	00 
  10433d:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  104344:	00 
  104345:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  10434c:	e8 96 c9 ff ff       	call   100ce7 <__panic>
    assert(p0 + 2 == p1);
  104351:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104354:	83 c0 28             	add    $0x28,%eax
  104357:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10435a:	74 24                	je     104380 <default_check+0x35d>
  10435c:	c7 44 24 0c 12 78 10 	movl   $0x107812,0xc(%esp)
  104363:	00 
  104364:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  10436b:	00 
  10436c:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  104373:	00 
  104374:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  10437b:	e8 67 c9 ff ff       	call   100ce7 <__panic>

    p2 = p0 + 1;
  104380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104383:	83 c0 14             	add    $0x14,%eax
  104386:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  104389:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104390:	00 
  104391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104394:	89 04 24             	mov    %eax,(%esp)
  104397:	e8 83 06 00 00       	call   104a1f <free_pages>
    free_pages(p1, 3);
  10439c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1043a3:	00 
  1043a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043a7:	89 04 24             	mov    %eax,(%esp)
  1043aa:	e8 70 06 00 00       	call   104a1f <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1043af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043b2:	83 c0 04             	add    $0x4,%eax
  1043b5:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1043bc:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1043bf:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1043c2:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1043c5:	0f a3 10             	bt     %edx,(%eax)
  1043c8:	19 c0                	sbb    %eax,%eax
  1043ca:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1043cd:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1043d1:	0f 95 c0             	setne  %al
  1043d4:	0f b6 c0             	movzbl %al,%eax
  1043d7:	85 c0                	test   %eax,%eax
  1043d9:	74 0b                	je     1043e6 <default_check+0x3c3>
  1043db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043de:	8b 40 08             	mov    0x8(%eax),%eax
  1043e1:	83 f8 01             	cmp    $0x1,%eax
  1043e4:	74 24                	je     10440a <default_check+0x3e7>
  1043e6:	c7 44 24 0c 20 78 10 	movl   $0x107820,0xc(%esp)
  1043ed:	00 
  1043ee:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  1043f5:	00 
  1043f6:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1043fd:	00 
  1043fe:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104405:	e8 dd c8 ff ff       	call   100ce7 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10440a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10440d:	83 c0 04             	add    $0x4,%eax
  104410:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  104417:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10441a:	8b 45 90             	mov    -0x70(%ebp),%eax
  10441d:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104420:	0f a3 10             	bt     %edx,(%eax)
  104423:	19 c0                	sbb    %eax,%eax
  104425:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  104428:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  10442c:	0f 95 c0             	setne  %al
  10442f:	0f b6 c0             	movzbl %al,%eax
  104432:	85 c0                	test   %eax,%eax
  104434:	74 0b                	je     104441 <default_check+0x41e>
  104436:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104439:	8b 40 08             	mov    0x8(%eax),%eax
  10443c:	83 f8 03             	cmp    $0x3,%eax
  10443f:	74 24                	je     104465 <default_check+0x442>
  104441:	c7 44 24 0c 48 78 10 	movl   $0x107848,0xc(%esp)
  104448:	00 
  104449:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104450:	00 
  104451:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  104458:	00 
  104459:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104460:	e8 82 c8 ff ff       	call   100ce7 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  104465:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10446c:	e8 76 05 00 00       	call   1049e7 <alloc_pages>
  104471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104474:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104477:	83 e8 14             	sub    $0x14,%eax
  10447a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10447d:	74 24                	je     1044a3 <default_check+0x480>
  10447f:	c7 44 24 0c 6e 78 10 	movl   $0x10786e,0xc(%esp)
  104486:	00 
  104487:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  10448e:	00 
  10448f:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  104496:	00 
  104497:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  10449e:	e8 44 c8 ff ff       	call   100ce7 <__panic>
    free_page(p0);
  1044a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1044aa:	00 
  1044ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1044ae:	89 04 24             	mov    %eax,(%esp)
  1044b1:	e8 69 05 00 00       	call   104a1f <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1044b6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1044bd:	e8 25 05 00 00       	call   1049e7 <alloc_pages>
  1044c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1044c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1044c8:	83 c0 14             	add    $0x14,%eax
  1044cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1044ce:	74 24                	je     1044f4 <default_check+0x4d1>
  1044d0:	c7 44 24 0c 8c 78 10 	movl   $0x10788c,0xc(%esp)
  1044d7:	00 
  1044d8:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  1044df:	00 
  1044e0:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  1044e7:	00 
  1044e8:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  1044ef:	e8 f3 c7 ff ff       	call   100ce7 <__panic>

    free_pages(p0, 2);
  1044f4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1044fb:	00 
  1044fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1044ff:	89 04 24             	mov    %eax,(%esp)
  104502:	e8 18 05 00 00       	call   104a1f <free_pages>
    free_page(p2);
  104507:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10450e:	00 
  10450f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104512:	89 04 24             	mov    %eax,(%esp)
  104515:	e8 05 05 00 00       	call   104a1f <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  10451a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104521:	e8 c1 04 00 00       	call   1049e7 <alloc_pages>
  104526:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104529:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10452d:	75 24                	jne    104553 <default_check+0x530>
  10452f:	c7 44 24 0c ac 78 10 	movl   $0x1078ac,0xc(%esp)
  104536:	00 
  104537:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  10453e:	00 
  10453f:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  104546:	00 
  104547:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  10454e:	e8 94 c7 ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  104553:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10455a:	e8 88 04 00 00       	call   1049e7 <alloc_pages>
  10455f:	85 c0                	test   %eax,%eax
  104561:	74 24                	je     104587 <default_check+0x564>
  104563:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  10456a:	00 
  10456b:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104572:	00 
  104573:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  10457a:	00 
  10457b:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104582:	e8 60 c7 ff ff       	call   100ce7 <__panic>

    assert(nr_free == 0);
  104587:	a1 98 cf 11 00       	mov    0x11cf98,%eax
  10458c:	85 c0                	test   %eax,%eax
  10458e:	74 24                	je     1045b4 <default_check+0x591>
  104590:	c7 44 24 0c 5d 77 10 	movl   $0x10775d,0xc(%esp)
  104597:	00 
  104598:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  10459f:	00 
  1045a0:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  1045a7:	00 
  1045a8:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  1045af:	e8 33 c7 ff ff       	call   100ce7 <__panic>
    nr_free = nr_free_store;
  1045b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045b7:	a3 98 cf 11 00       	mov    %eax,0x11cf98

    free_list = free_list_store;
  1045bc:	8b 45 80             	mov    -0x80(%ebp),%eax
  1045bf:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1045c2:	a3 90 cf 11 00       	mov    %eax,0x11cf90
  1045c7:	89 15 94 cf 11 00    	mov    %edx,0x11cf94
    free_pages(p0, 5);
  1045cd:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1045d4:	00 
  1045d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1045d8:	89 04 24             	mov    %eax,(%esp)
  1045db:	e8 3f 04 00 00       	call   104a1f <free_pages>

    le = &free_list;
  1045e0:	c7 45 ec 90 cf 11 00 	movl   $0x11cf90,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1045e7:	eb 5b                	jmp    104644 <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
  1045e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045ec:	8b 40 04             	mov    0x4(%eax),%eax
  1045ef:	8b 00                	mov    (%eax),%eax
  1045f1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1045f4:	75 0d                	jne    104603 <default_check+0x5e0>
  1045f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045f9:	8b 00                	mov    (%eax),%eax
  1045fb:	8b 40 04             	mov    0x4(%eax),%eax
  1045fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104601:	74 24                	je     104627 <default_check+0x604>
  104603:	c7 44 24 0c cc 78 10 	movl   $0x1078cc,0xc(%esp)
  10460a:	00 
  10460b:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104612:	00 
  104613:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  10461a:	00 
  10461b:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104622:	e8 c0 c6 ff ff       	call   100ce7 <__panic>
        struct Page *p = le2page(le, page_link);
  104627:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10462a:	83 e8 0c             	sub    $0xc,%eax
  10462d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  104630:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  104634:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104637:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10463a:	8b 40 08             	mov    0x8(%eax),%eax
  10463d:	29 c2                	sub    %eax,%edx
  10463f:	89 d0                	mov    %edx,%eax
  104641:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104644:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104647:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10464a:	8b 45 88             	mov    -0x78(%ebp),%eax
  10464d:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  104650:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104653:	81 7d ec 90 cf 11 00 	cmpl   $0x11cf90,-0x14(%ebp)
  10465a:	75 8d                	jne    1045e9 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  10465c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104660:	74 24                	je     104686 <default_check+0x663>
  104662:	c7 44 24 0c f9 78 10 	movl   $0x1078f9,0xc(%esp)
  104669:	00 
  10466a:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  104671:	00 
  104672:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
  104679:	00 
  10467a:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  104681:	e8 61 c6 ff ff       	call   100ce7 <__panic>
    assert(total == 0);
  104686:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10468a:	74 24                	je     1046b0 <default_check+0x68d>
  10468c:	c7 44 24 0c 04 79 10 	movl   $0x107904,0xc(%esp)
  104693:	00 
  104694:	c7 44 24 08 6a 75 10 	movl   $0x10756a,0x8(%esp)
  10469b:	00 
  10469c:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
  1046a3:	00 
  1046a4:	c7 04 24 7f 75 10 00 	movl   $0x10757f,(%esp)
  1046ab:	e8 37 c6 ff ff       	call   100ce7 <__panic>
}
  1046b0:	81 c4 94 00 00 00    	add    $0x94,%esp
  1046b6:	5b                   	pop    %ebx
  1046b7:	5d                   	pop    %ebp
  1046b8:	c3                   	ret    

001046b9 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1046b9:	55                   	push   %ebp
  1046ba:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1046bc:	8b 55 08             	mov    0x8(%ebp),%edx
  1046bf:	a1 a4 cf 11 00       	mov    0x11cfa4,%eax
  1046c4:	29 c2                	sub    %eax,%edx
  1046c6:	89 d0                	mov    %edx,%eax
  1046c8:	c1 f8 02             	sar    $0x2,%eax
  1046cb:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1046d1:	5d                   	pop    %ebp
  1046d2:	c3                   	ret    

001046d3 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1046d3:	55                   	push   %ebp
  1046d4:	89 e5                	mov    %esp,%ebp
  1046d6:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1046d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1046dc:	89 04 24             	mov    %eax,(%esp)
  1046df:	e8 d5 ff ff ff       	call   1046b9 <page2ppn>
  1046e4:	c1 e0 0c             	shl    $0xc,%eax
}
  1046e7:	c9                   	leave  
  1046e8:	c3                   	ret    

001046e9 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  1046e9:	55                   	push   %ebp
  1046ea:	89 e5                	mov    %esp,%ebp
  1046ec:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  1046ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1046f2:	c1 e8 0c             	shr    $0xc,%eax
  1046f5:	89 c2                	mov    %eax,%edx
  1046f7:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  1046fc:	39 c2                	cmp    %eax,%edx
  1046fe:	72 1c                	jb     10471c <pa2page+0x33>
        panic("pa2page called with invalid pa");
  104700:	c7 44 24 08 40 79 10 	movl   $0x107940,0x8(%esp)
  104707:	00 
  104708:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  10470f:	00 
  104710:	c7 04 24 5f 79 10 00 	movl   $0x10795f,(%esp)
  104717:	e8 cb c5 ff ff       	call   100ce7 <__panic>
    }
    return &pages[PPN(pa)];
  10471c:	8b 0d a4 cf 11 00    	mov    0x11cfa4,%ecx
  104722:	8b 45 08             	mov    0x8(%ebp),%eax
  104725:	c1 e8 0c             	shr    $0xc,%eax
  104728:	89 c2                	mov    %eax,%edx
  10472a:	89 d0                	mov    %edx,%eax
  10472c:	c1 e0 02             	shl    $0x2,%eax
  10472f:	01 d0                	add    %edx,%eax
  104731:	c1 e0 02             	shl    $0x2,%eax
  104734:	01 c8                	add    %ecx,%eax
}
  104736:	c9                   	leave  
  104737:	c3                   	ret    

00104738 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  104738:	55                   	push   %ebp
  104739:	89 e5                	mov    %esp,%ebp
  10473b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  10473e:	8b 45 08             	mov    0x8(%ebp),%eax
  104741:	89 04 24             	mov    %eax,(%esp)
  104744:	e8 8a ff ff ff       	call   1046d3 <page2pa>
  104749:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10474c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10474f:	c1 e8 0c             	shr    $0xc,%eax
  104752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104755:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  10475a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  10475d:	72 23                	jb     104782 <page2kva+0x4a>
  10475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104766:	c7 44 24 08 70 79 10 	movl   $0x107970,0x8(%esp)
  10476d:	00 
  10476e:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  104775:	00 
  104776:	c7 04 24 5f 79 10 00 	movl   $0x10795f,(%esp)
  10477d:	e8 65 c5 ff ff       	call   100ce7 <__panic>
  104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104785:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  10478a:	c9                   	leave  
  10478b:	c3                   	ret    

0010478c <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  10478c:	55                   	push   %ebp
  10478d:	89 e5                	mov    %esp,%ebp
  10478f:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  104792:	8b 45 08             	mov    0x8(%ebp),%eax
  104795:	83 e0 01             	and    $0x1,%eax
  104798:	85 c0                	test   %eax,%eax
  10479a:	75 1c                	jne    1047b8 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  10479c:	c7 44 24 08 94 79 10 	movl   $0x107994,0x8(%esp)
  1047a3:	00 
  1047a4:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1047ab:	00 
  1047ac:	c7 04 24 5f 79 10 00 	movl   $0x10795f,(%esp)
  1047b3:	e8 2f c5 ff ff       	call   100ce7 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  1047b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1047bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1047c0:	89 04 24             	mov    %eax,(%esp)
  1047c3:	e8 21 ff ff ff       	call   1046e9 <pa2page>
}
  1047c8:	c9                   	leave  
  1047c9:	c3                   	ret    

001047ca <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  1047ca:	55                   	push   %ebp
  1047cb:	89 e5                	mov    %esp,%ebp
  1047cd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  1047d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1047d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1047d8:	89 04 24             	mov    %eax,(%esp)
  1047db:	e8 09 ff ff ff       	call   1046e9 <pa2page>
}
  1047e0:	c9                   	leave  
  1047e1:	c3                   	ret    

001047e2 <page_ref>:

static inline int
page_ref(struct Page *page) {
  1047e2:	55                   	push   %ebp
  1047e3:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1047e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1047e8:	8b 00                	mov    (%eax),%eax
}
  1047ea:	5d                   	pop    %ebp
  1047eb:	c3                   	ret    

001047ec <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1047ec:	55                   	push   %ebp
  1047ed:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1047ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1047f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1047f5:	89 10                	mov    %edx,(%eax)
}
  1047f7:	5d                   	pop    %ebp
  1047f8:	c3                   	ret    

001047f9 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  1047f9:	55                   	push   %ebp
  1047fa:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1047fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1047ff:	8b 00                	mov    (%eax),%eax
  104801:	8d 50 01             	lea    0x1(%eax),%edx
  104804:	8b 45 08             	mov    0x8(%ebp),%eax
  104807:	89 10                	mov    %edx,(%eax)
    return page->ref;
  104809:	8b 45 08             	mov    0x8(%ebp),%eax
  10480c:	8b 00                	mov    (%eax),%eax
}
  10480e:	5d                   	pop    %ebp
  10480f:	c3                   	ret    

00104810 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  104810:	55                   	push   %ebp
  104811:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  104813:	8b 45 08             	mov    0x8(%ebp),%eax
  104816:	8b 00                	mov    (%eax),%eax
  104818:	8d 50 ff             	lea    -0x1(%eax),%edx
  10481b:	8b 45 08             	mov    0x8(%ebp),%eax
  10481e:	89 10                	mov    %edx,(%eax)
    return page->ref;
  104820:	8b 45 08             	mov    0x8(%ebp),%eax
  104823:	8b 00                	mov    (%eax),%eax
}
  104825:	5d                   	pop    %ebp
  104826:	c3                   	ret    

00104827 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  104827:	55                   	push   %ebp
  104828:	89 e5                	mov    %esp,%ebp
  10482a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  10482d:	9c                   	pushf  
  10482e:	58                   	pop    %eax
  10482f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  104832:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  104835:	25 00 02 00 00       	and    $0x200,%eax
  10483a:	85 c0                	test   %eax,%eax
  10483c:	74 0c                	je     10484a <__intr_save+0x23>
        intr_disable();
  10483e:	e8 98 ce ff ff       	call   1016db <intr_disable>
        return 1;
  104843:	b8 01 00 00 00       	mov    $0x1,%eax
  104848:	eb 05                	jmp    10484f <__intr_save+0x28>
    }
    return 0;
  10484a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10484f:	c9                   	leave  
  104850:	c3                   	ret    

00104851 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  104851:	55                   	push   %ebp
  104852:	89 e5                	mov    %esp,%ebp
  104854:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  104857:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10485b:	74 05                	je     104862 <__intr_restore+0x11>
        intr_enable();
  10485d:	e8 73 ce ff ff       	call   1016d5 <intr_enable>
    }
}
  104862:	c9                   	leave  
  104863:	c3                   	ret    

00104864 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  104864:	55                   	push   %ebp
  104865:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  104867:	8b 45 08             	mov    0x8(%ebp),%eax
  10486a:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  10486d:	b8 23 00 00 00       	mov    $0x23,%eax
  104872:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  104874:	b8 23 00 00 00       	mov    $0x23,%eax
  104879:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  10487b:	b8 10 00 00 00       	mov    $0x10,%eax
  104880:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  104882:	b8 10 00 00 00       	mov    $0x10,%eax
  104887:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  104889:	b8 10 00 00 00       	mov    $0x10,%eax
  10488e:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  104890:	ea 97 48 10 00 08 00 	ljmp   $0x8,$0x104897
}
  104897:	5d                   	pop    %ebp
  104898:	c3                   	ret    

00104899 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  104899:	55                   	push   %ebp
  10489a:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  10489c:	8b 45 08             	mov    0x8(%ebp),%eax
  10489f:	a3 c4 ce 11 00       	mov    %eax,0x11cec4
}
  1048a4:	5d                   	pop    %ebp
  1048a5:	c3                   	ret    

001048a6 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  1048a6:	55                   	push   %ebp
  1048a7:	89 e5                	mov    %esp,%ebp
  1048a9:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  1048ac:	b8 00 90 11 00       	mov    $0x119000,%eax
  1048b1:	89 04 24             	mov    %eax,(%esp)
  1048b4:	e8 e0 ff ff ff       	call   104899 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  1048b9:	66 c7 05 c8 ce 11 00 	movw   $0x10,0x11cec8
  1048c0:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  1048c2:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  1048c9:	68 00 
  1048cb:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  1048d0:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  1048d6:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  1048db:	c1 e8 10             	shr    $0x10,%eax
  1048de:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  1048e3:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  1048ea:	83 e0 f0             	and    $0xfffffff0,%eax
  1048ed:	83 c8 09             	or     $0x9,%eax
  1048f0:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  1048f5:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  1048fc:	83 e0 ef             	and    $0xffffffef,%eax
  1048ff:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  104904:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  10490b:	83 e0 9f             	and    $0xffffff9f,%eax
  10490e:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  104913:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  10491a:	83 c8 80             	or     $0xffffff80,%eax
  10491d:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  104922:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  104929:	83 e0 f0             	and    $0xfffffff0,%eax
  10492c:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  104931:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  104938:	83 e0 ef             	and    $0xffffffef,%eax
  10493b:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  104940:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  104947:	83 e0 df             	and    $0xffffffdf,%eax
  10494a:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  10494f:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  104956:	83 c8 40             	or     $0x40,%eax
  104959:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  10495e:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  104965:	83 e0 7f             	and    $0x7f,%eax
  104968:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  10496d:	b8 c0 ce 11 00       	mov    $0x11cec0,%eax
  104972:	c1 e8 18             	shr    $0x18,%eax
  104975:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  10497a:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  104981:	e8 de fe ff ff       	call   104864 <lgdt>
  104986:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  10498c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  104990:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  104993:	c9                   	leave  
  104994:	c3                   	ret    

00104995 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  104995:	55                   	push   %ebp
  104996:	89 e5                	mov    %esp,%ebp
  104998:	83 ec 18             	sub    $0x18,%esp
	//pmm_manager=&buddy_pmm_manager;
    pmm_manager = &default_pmm_manager;
  10499b:	c7 05 9c cf 11 00 24 	movl   $0x107924,0x11cf9c
  1049a2:	79 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  1049a5:	a1 9c cf 11 00       	mov    0x11cf9c,%eax
  1049aa:	8b 00                	mov    (%eax),%eax
  1049ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1049b0:	c7 04 24 c0 79 10 00 	movl   $0x1079c0,(%esp)
  1049b7:	e8 97 b9 ff ff       	call   100353 <cprintf>
    pmm_manager->init();
  1049bc:	a1 9c cf 11 00       	mov    0x11cf9c,%eax
  1049c1:	8b 40 04             	mov    0x4(%eax),%eax
  1049c4:	ff d0                	call   *%eax
}
  1049c6:	c9                   	leave  
  1049c7:	c3                   	ret    

001049c8 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  1049c8:	55                   	push   %ebp
  1049c9:	89 e5                	mov    %esp,%ebp
  1049cb:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  1049ce:	a1 9c cf 11 00       	mov    0x11cf9c,%eax
  1049d3:	8b 40 08             	mov    0x8(%eax),%eax
  1049d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1049d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1049dd:	8b 55 08             	mov    0x8(%ebp),%edx
  1049e0:	89 14 24             	mov    %edx,(%esp)
  1049e3:	ff d0                	call   *%eax
}
  1049e5:	c9                   	leave  
  1049e6:	c3                   	ret    

001049e7 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  1049e7:	55                   	push   %ebp
  1049e8:	89 e5                	mov    %esp,%ebp
  1049ea:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  1049ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1049f4:	e8 2e fe ff ff       	call   104827 <__intr_save>
  1049f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  1049fc:	a1 9c cf 11 00       	mov    0x11cf9c,%eax
  104a01:	8b 40 0c             	mov    0xc(%eax),%eax
  104a04:	8b 55 08             	mov    0x8(%ebp),%edx
  104a07:	89 14 24             	mov    %edx,(%esp)
  104a0a:	ff d0                	call   *%eax
  104a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  104a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a12:	89 04 24             	mov    %eax,(%esp)
  104a15:	e8 37 fe ff ff       	call   104851 <__intr_restore>
    return page;
  104a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104a1d:	c9                   	leave  
  104a1e:	c3                   	ret    

00104a1f <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  104a1f:	55                   	push   %ebp
  104a20:	89 e5                	mov    %esp,%ebp
  104a22:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  104a25:	e8 fd fd ff ff       	call   104827 <__intr_save>
  104a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  104a2d:	a1 9c cf 11 00       	mov    0x11cf9c,%eax
  104a32:	8b 40 10             	mov    0x10(%eax),%eax
  104a35:	8b 55 0c             	mov    0xc(%ebp),%edx
  104a38:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  104a3f:	89 14 24             	mov    %edx,(%esp)
  104a42:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  104a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a47:	89 04 24             	mov    %eax,(%esp)
  104a4a:	e8 02 fe ff ff       	call   104851 <__intr_restore>
}
  104a4f:	c9                   	leave  
  104a50:	c3                   	ret    

00104a51 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  104a51:	55                   	push   %ebp
  104a52:	89 e5                	mov    %esp,%ebp
  104a54:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  104a57:	e8 cb fd ff ff       	call   104827 <__intr_save>
  104a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  104a5f:	a1 9c cf 11 00       	mov    0x11cf9c,%eax
  104a64:	8b 40 14             	mov    0x14(%eax),%eax
  104a67:	ff d0                	call   *%eax
  104a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  104a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a6f:	89 04 24             	mov    %eax,(%esp)
  104a72:	e8 da fd ff ff       	call   104851 <__intr_restore>
    return ret;
  104a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  104a7a:	c9                   	leave  
  104a7b:	c3                   	ret    

00104a7c <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  104a7c:	55                   	push   %ebp
  104a7d:	89 e5                	mov    %esp,%ebp
  104a7f:	57                   	push   %edi
  104a80:	56                   	push   %esi
  104a81:	53                   	push   %ebx
  104a82:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  104a88:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  104a8f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  104a96:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  104a9d:	c7 04 24 d7 79 10 00 	movl   $0x1079d7,(%esp)
  104aa4:	e8 aa b8 ff ff       	call   100353 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104aa9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104ab0:	e9 15 01 00 00       	jmp    104bca <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104ab5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104ab8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104abb:	89 d0                	mov    %edx,%eax
  104abd:	c1 e0 02             	shl    $0x2,%eax
  104ac0:	01 d0                	add    %edx,%eax
  104ac2:	c1 e0 02             	shl    $0x2,%eax
  104ac5:	01 c8                	add    %ecx,%eax
  104ac7:	8b 50 08             	mov    0x8(%eax),%edx
  104aca:	8b 40 04             	mov    0x4(%eax),%eax
  104acd:	89 45 b8             	mov    %eax,-0x48(%ebp)
  104ad0:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104ad3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104ad6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104ad9:	89 d0                	mov    %edx,%eax
  104adb:	c1 e0 02             	shl    $0x2,%eax
  104ade:	01 d0                	add    %edx,%eax
  104ae0:	c1 e0 02             	shl    $0x2,%eax
  104ae3:	01 c8                	add    %ecx,%eax
  104ae5:	8b 48 0c             	mov    0xc(%eax),%ecx
  104ae8:	8b 58 10             	mov    0x10(%eax),%ebx
  104aeb:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104aee:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104af1:	01 c8                	add    %ecx,%eax
  104af3:	11 da                	adc    %ebx,%edx
  104af5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  104af8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  104afb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104afe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104b01:	89 d0                	mov    %edx,%eax
  104b03:	c1 e0 02             	shl    $0x2,%eax
  104b06:	01 d0                	add    %edx,%eax
  104b08:	c1 e0 02             	shl    $0x2,%eax
  104b0b:	01 c8                	add    %ecx,%eax
  104b0d:	83 c0 14             	add    $0x14,%eax
  104b10:	8b 00                	mov    (%eax),%eax
  104b12:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  104b18:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104b1b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104b1e:	83 c0 ff             	add    $0xffffffff,%eax
  104b21:	83 d2 ff             	adc    $0xffffffff,%edx
  104b24:	89 c6                	mov    %eax,%esi
  104b26:	89 d7                	mov    %edx,%edi
  104b28:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104b2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104b2e:	89 d0                	mov    %edx,%eax
  104b30:	c1 e0 02             	shl    $0x2,%eax
  104b33:	01 d0                	add    %edx,%eax
  104b35:	c1 e0 02             	shl    $0x2,%eax
  104b38:	01 c8                	add    %ecx,%eax
  104b3a:	8b 48 0c             	mov    0xc(%eax),%ecx
  104b3d:	8b 58 10             	mov    0x10(%eax),%ebx
  104b40:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104b46:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  104b4a:	89 74 24 14          	mov    %esi,0x14(%esp)
  104b4e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  104b52:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104b55:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104b58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104b5c:	89 54 24 10          	mov    %edx,0x10(%esp)
  104b60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104b64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  104b68:	c7 04 24 e4 79 10 00 	movl   $0x1079e4,(%esp)
  104b6f:	e8 df b7 ff ff       	call   100353 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  104b74:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104b77:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104b7a:	89 d0                	mov    %edx,%eax
  104b7c:	c1 e0 02             	shl    $0x2,%eax
  104b7f:	01 d0                	add    %edx,%eax
  104b81:	c1 e0 02             	shl    $0x2,%eax
  104b84:	01 c8                	add    %ecx,%eax
  104b86:	83 c0 14             	add    $0x14,%eax
  104b89:	8b 00                	mov    (%eax),%eax
  104b8b:	83 f8 01             	cmp    $0x1,%eax
  104b8e:	75 36                	jne    104bc6 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  104b90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104b93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104b96:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  104b99:	77 2b                	ja     104bc6 <page_init+0x14a>
  104b9b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  104b9e:	72 05                	jb     104ba5 <page_init+0x129>
  104ba0:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  104ba3:	73 21                	jae    104bc6 <page_init+0x14a>
  104ba5:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  104ba9:	77 1b                	ja     104bc6 <page_init+0x14a>
  104bab:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  104baf:	72 09                	jb     104bba <page_init+0x13e>
  104bb1:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  104bb8:	77 0c                	ja     104bc6 <page_init+0x14a>
                maxpa = end;
  104bba:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104bbd:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104bc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104bc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104bc6:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104bca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104bcd:	8b 00                	mov    (%eax),%eax
  104bcf:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104bd2:	0f 8f dd fe ff ff    	jg     104ab5 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  104bd8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104bdc:	72 1d                	jb     104bfb <page_init+0x17f>
  104bde:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104be2:	77 09                	ja     104bed <page_init+0x171>
  104be4:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  104beb:	76 0e                	jbe    104bfb <page_init+0x17f>
        maxpa = KMEMSIZE;
  104bed:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  104bf4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  104bfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104bfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104c01:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104c05:	c1 ea 0c             	shr    $0xc,%edx
  104c08:	a3 a0 ce 11 00       	mov    %eax,0x11cea0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  104c0d:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  104c14:	b8 a8 cf 11 00       	mov    $0x11cfa8,%eax
  104c19:	8d 50 ff             	lea    -0x1(%eax),%edx
  104c1c:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104c1f:	01 d0                	add    %edx,%eax
  104c21:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104c24:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104c27:	ba 00 00 00 00       	mov    $0x0,%edx
  104c2c:	f7 75 ac             	divl   -0x54(%ebp)
  104c2f:	89 d0                	mov    %edx,%eax
  104c31:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104c34:	29 c2                	sub    %eax,%edx
  104c36:	89 d0                	mov    %edx,%eax
  104c38:	a3 a4 cf 11 00       	mov    %eax,0x11cfa4

    for (i = 0; i < npage; i ++) {
  104c3d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104c44:	eb 2f                	jmp    104c75 <page_init+0x1f9>
        SetPageReserved(pages + i);
  104c46:	8b 0d a4 cf 11 00    	mov    0x11cfa4,%ecx
  104c4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104c4f:	89 d0                	mov    %edx,%eax
  104c51:	c1 e0 02             	shl    $0x2,%eax
  104c54:	01 d0                	add    %edx,%eax
  104c56:	c1 e0 02             	shl    $0x2,%eax
  104c59:	01 c8                	add    %ecx,%eax
  104c5b:	83 c0 04             	add    $0x4,%eax
  104c5e:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  104c65:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104c68:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104c6b:	8b 55 90             	mov    -0x70(%ebp),%edx
  104c6e:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  104c71:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104c75:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104c78:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  104c7d:	39 c2                	cmp    %eax,%edx
  104c7f:	72 c5                	jb     104c46 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104c81:	8b 15 a0 ce 11 00    	mov    0x11cea0,%edx
  104c87:	89 d0                	mov    %edx,%eax
  104c89:	c1 e0 02             	shl    $0x2,%eax
  104c8c:	01 d0                	add    %edx,%eax
  104c8e:	c1 e0 02             	shl    $0x2,%eax
  104c91:	89 c2                	mov    %eax,%edx
  104c93:	a1 a4 cf 11 00       	mov    0x11cfa4,%eax
  104c98:	01 d0                	add    %edx,%eax
  104c9a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  104c9d:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  104ca4:	77 23                	ja     104cc9 <page_init+0x24d>
  104ca6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104ca9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104cad:	c7 44 24 08 14 7a 10 	movl   $0x107a14,0x8(%esp)
  104cb4:	00 
  104cb5:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104cbc:	00 
  104cbd:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  104cc4:	e8 1e c0 ff ff       	call   100ce7 <__panic>
  104cc9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104ccc:	05 00 00 00 40       	add    $0x40000000,%eax
  104cd1:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104cd4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104cdb:	e9 74 01 00 00       	jmp    104e54 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104ce0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104ce3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104ce6:	89 d0                	mov    %edx,%eax
  104ce8:	c1 e0 02             	shl    $0x2,%eax
  104ceb:	01 d0                	add    %edx,%eax
  104ced:	c1 e0 02             	shl    $0x2,%eax
  104cf0:	01 c8                	add    %ecx,%eax
  104cf2:	8b 50 08             	mov    0x8(%eax),%edx
  104cf5:	8b 40 04             	mov    0x4(%eax),%eax
  104cf8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104cfb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104cfe:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104d01:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104d04:	89 d0                	mov    %edx,%eax
  104d06:	c1 e0 02             	shl    $0x2,%eax
  104d09:	01 d0                	add    %edx,%eax
  104d0b:	c1 e0 02             	shl    $0x2,%eax
  104d0e:	01 c8                	add    %ecx,%eax
  104d10:	8b 48 0c             	mov    0xc(%eax),%ecx
  104d13:	8b 58 10             	mov    0x10(%eax),%ebx
  104d16:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d19:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d1c:	01 c8                	add    %ecx,%eax
  104d1e:	11 da                	adc    %ebx,%edx
  104d20:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104d23:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104d26:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104d29:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104d2c:	89 d0                	mov    %edx,%eax
  104d2e:	c1 e0 02             	shl    $0x2,%eax
  104d31:	01 d0                	add    %edx,%eax
  104d33:	c1 e0 02             	shl    $0x2,%eax
  104d36:	01 c8                	add    %ecx,%eax
  104d38:	83 c0 14             	add    $0x14,%eax
  104d3b:	8b 00                	mov    (%eax),%eax
  104d3d:	83 f8 01             	cmp    $0x1,%eax
  104d40:	0f 85 0a 01 00 00    	jne    104e50 <page_init+0x3d4>
            if (begin < freemem) {
  104d46:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104d49:	ba 00 00 00 00       	mov    $0x0,%edx
  104d4e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104d51:	72 17                	jb     104d6a <page_init+0x2ee>
  104d53:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104d56:	77 05                	ja     104d5d <page_init+0x2e1>
  104d58:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  104d5b:	76 0d                	jbe    104d6a <page_init+0x2ee>
                begin = freemem;
  104d5d:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104d60:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104d63:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  104d6a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104d6e:	72 1d                	jb     104d8d <page_init+0x311>
  104d70:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104d74:	77 09                	ja     104d7f <page_init+0x303>
  104d76:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  104d7d:	76 0e                	jbe    104d8d <page_init+0x311>
                end = KMEMSIZE;
  104d7f:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104d86:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  104d8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d93:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104d96:	0f 87 b4 00 00 00    	ja     104e50 <page_init+0x3d4>
  104d9c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104d9f:	72 09                	jb     104daa <page_init+0x32e>
  104da1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104da4:	0f 83 a6 00 00 00    	jae    104e50 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  104daa:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  104db1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104db4:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104db7:	01 d0                	add    %edx,%eax
  104db9:	83 e8 01             	sub    $0x1,%eax
  104dbc:	89 45 98             	mov    %eax,-0x68(%ebp)
  104dbf:	8b 45 98             	mov    -0x68(%ebp),%eax
  104dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  104dc7:	f7 75 9c             	divl   -0x64(%ebp)
  104dca:	89 d0                	mov    %edx,%eax
  104dcc:	8b 55 98             	mov    -0x68(%ebp),%edx
  104dcf:	29 c2                	sub    %eax,%edx
  104dd1:	89 d0                	mov    %edx,%eax
  104dd3:	ba 00 00 00 00       	mov    $0x0,%edx
  104dd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104ddb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  104dde:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104de1:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104de4:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104de7:	ba 00 00 00 00       	mov    $0x0,%edx
  104dec:	89 c7                	mov    %eax,%edi
  104dee:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104df4:	89 7d 80             	mov    %edi,-0x80(%ebp)
  104df7:	89 d0                	mov    %edx,%eax
  104df9:	83 e0 00             	and    $0x0,%eax
  104dfc:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104dff:	8b 45 80             	mov    -0x80(%ebp),%eax
  104e02:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104e05:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104e08:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104e0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104e0e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104e11:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104e14:	77 3a                	ja     104e50 <page_init+0x3d4>
  104e16:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104e19:	72 05                	jb     104e20 <page_init+0x3a4>
  104e1b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104e1e:	73 30                	jae    104e50 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104e20:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  104e23:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  104e26:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104e29:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104e2c:	29 c8                	sub    %ecx,%eax
  104e2e:	19 da                	sbb    %ebx,%edx
  104e30:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104e34:	c1 ea 0c             	shr    $0xc,%edx
  104e37:	89 c3                	mov    %eax,%ebx
  104e39:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104e3c:	89 04 24             	mov    %eax,(%esp)
  104e3f:	e8 a5 f8 ff ff       	call   1046e9 <pa2page>
  104e44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104e48:	89 04 24             	mov    %eax,(%esp)
  104e4b:	e8 78 fb ff ff       	call   1049c8 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  104e50:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104e54:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104e57:	8b 00                	mov    (%eax),%eax
  104e59:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104e5c:	0f 8f 7e fe ff ff    	jg     104ce0 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  104e62:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104e68:	5b                   	pop    %ebx
  104e69:	5e                   	pop    %esi
  104e6a:	5f                   	pop    %edi
  104e6b:	5d                   	pop    %ebp
  104e6c:	c3                   	ret    

00104e6d <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104e6d:	55                   	push   %ebp
  104e6e:	89 e5                	mov    %esp,%ebp
  104e70:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  104e73:	8b 45 14             	mov    0x14(%ebp),%eax
  104e76:	8b 55 0c             	mov    0xc(%ebp),%edx
  104e79:	31 d0                	xor    %edx,%eax
  104e7b:	25 ff 0f 00 00       	and    $0xfff,%eax
  104e80:	85 c0                	test   %eax,%eax
  104e82:	74 24                	je     104ea8 <boot_map_segment+0x3b>
  104e84:	c7 44 24 0c 46 7a 10 	movl   $0x107a46,0xc(%esp)
  104e8b:	00 
  104e8c:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  104e93:	00 
  104e94:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  104e9b:	00 
  104e9c:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  104ea3:	e8 3f be ff ff       	call   100ce7 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104ea8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  104eb2:	25 ff 0f 00 00       	and    $0xfff,%eax
  104eb7:	89 c2                	mov    %eax,%edx
  104eb9:	8b 45 10             	mov    0x10(%ebp),%eax
  104ebc:	01 c2                	add    %eax,%edx
  104ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ec1:	01 d0                	add    %edx,%eax
  104ec3:	83 e8 01             	sub    $0x1,%eax
  104ec6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ecc:	ba 00 00 00 00       	mov    $0x0,%edx
  104ed1:	f7 75 f0             	divl   -0x10(%ebp)
  104ed4:	89 d0                	mov    %edx,%eax
  104ed6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104ed9:	29 c2                	sub    %eax,%edx
  104edb:	89 d0                	mov    %edx,%eax
  104edd:	c1 e8 0c             	shr    $0xc,%eax
  104ee0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  104ee6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104ee9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104eec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104ef1:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104ef4:	8b 45 14             	mov    0x14(%ebp),%eax
  104ef7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104efd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f02:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104f05:	eb 6b                	jmp    104f72 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  104f07:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104f0e:	00 
  104f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104f12:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f16:	8b 45 08             	mov    0x8(%ebp),%eax
  104f19:	89 04 24             	mov    %eax,(%esp)
  104f1c:	e8 82 01 00 00       	call   1050a3 <get_pte>
  104f21:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  104f24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104f28:	75 24                	jne    104f4e <boot_map_segment+0xe1>
  104f2a:	c7 44 24 0c 72 7a 10 	movl   $0x107a72,0xc(%esp)
  104f31:	00 
  104f32:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  104f39:	00 
  104f3a:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104f41:	00 
  104f42:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  104f49:	e8 99 bd ff ff       	call   100ce7 <__panic>
        *ptep = pa | PTE_P | perm;
  104f4e:	8b 45 18             	mov    0x18(%ebp),%eax
  104f51:	8b 55 14             	mov    0x14(%ebp),%edx
  104f54:	09 d0                	or     %edx,%eax
  104f56:	83 c8 01             	or     $0x1,%eax
  104f59:	89 c2                	mov    %eax,%edx
  104f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f5e:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104f60:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  104f64:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  104f6b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  104f72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104f76:	75 8f                	jne    104f07 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  104f78:	c9                   	leave  
  104f79:	c3                   	ret    

00104f7a <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  104f7a:	55                   	push   %ebp
  104f7b:	89 e5                	mov    %esp,%ebp
  104f7d:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  104f80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f87:	e8 5b fa ff ff       	call   1049e7 <alloc_pages>
  104f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  104f8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104f93:	75 1c                	jne    104fb1 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  104f95:	c7 44 24 08 7f 7a 10 	movl   $0x107a7f,0x8(%esp)
  104f9c:	00 
  104f9d:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  104fa4:	00 
  104fa5:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  104fac:	e8 36 bd ff ff       	call   100ce7 <__panic>
    }
    return page2kva(p);
  104fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104fb4:	89 04 24             	mov    %eax,(%esp)
  104fb7:	e8 7c f7 ff ff       	call   104738 <page2kva>
}
  104fbc:	c9                   	leave  
  104fbd:	c3                   	ret    

00104fbe <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  104fbe:	55                   	push   %ebp
  104fbf:	89 e5                	mov    %esp,%ebp
  104fc1:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  104fc4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104fc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104fcc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104fd3:	77 23                	ja     104ff8 <pmm_init+0x3a>
  104fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104fdc:	c7 44 24 08 14 7a 10 	movl   $0x107a14,0x8(%esp)
  104fe3:	00 
  104fe4:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  104feb:	00 
  104fec:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  104ff3:	e8 ef bc ff ff       	call   100ce7 <__panic>
  104ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ffb:	05 00 00 00 40       	add    $0x40000000,%eax
  105000:	a3 a0 cf 11 00       	mov    %eax,0x11cfa0
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  105005:	e8 8b f9 ff ff       	call   104995 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10500a:	e8 6d fa ff ff       	call   104a7c <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10500f:	e8 db 03 00 00       	call   1053ef <check_alloc_page>

    check_pgdir();
  105014:	e8 f4 03 00 00       	call   10540d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  105019:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10501e:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  105024:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105029:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10502c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  105033:	77 23                	ja     105058 <pmm_init+0x9a>
  105035:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105038:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10503c:	c7 44 24 08 14 7a 10 	movl   $0x107a14,0x8(%esp)
  105043:	00 
  105044:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
  10504b:	00 
  10504c:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105053:	e8 8f bc ff ff       	call   100ce7 <__panic>
  105058:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10505b:	05 00 00 00 40       	add    $0x40000000,%eax
  105060:	83 c8 03             	or     $0x3,%eax
  105063:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  105065:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10506a:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  105071:	00 
  105072:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  105079:	00 
  10507a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  105081:	38 
  105082:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  105089:	c0 
  10508a:	89 04 24             	mov    %eax,(%esp)
  10508d:	e8 db fd ff ff       	call   104e6d <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  105092:	e8 0f f8 ff ff       	call   1048a6 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  105097:	e8 0c 0a 00 00       	call   105aa8 <check_boot_pgdir>

    print_pgdir();
  10509c:	e8 94 0e 00 00       	call   105f35 <print_pgdir>

}
  1050a1:	c9                   	leave  
  1050a2:	c3                   	ret    

001050a3 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1050a3:	55                   	push   %ebp
  1050a4:	89 e5                	mov    %esp,%ebp
  1050a6:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
  1050a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1050ac:	c1 e8 16             	shr    $0x16,%eax
  1050af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1050b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1050b9:	01 d0                	add    %edx,%eax
  1050bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  1050be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050c1:	8b 00                	mov    (%eax),%eax
  1050c3:	83 e0 01             	and    $0x1,%eax
  1050c6:	85 c0                	test   %eax,%eax
  1050c8:	0f 85 af 00 00 00    	jne    10517d <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  1050ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1050d2:	74 15                	je     1050e9 <get_pte+0x46>
  1050d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050db:	e8 07 f9 ff ff       	call   1049e7 <alloc_pages>
  1050e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1050e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1050e7:	75 0a                	jne    1050f3 <get_pte+0x50>
            return NULL;
  1050e9:	b8 00 00 00 00       	mov    $0x0,%eax
  1050ee:	e9 e6 00 00 00       	jmp    1051d9 <get_pte+0x136>
        }
        set_page_ref(page, 1);
  1050f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050fa:	00 
  1050fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1050fe:	89 04 24             	mov    %eax,(%esp)
  105101:	e8 e6 f6 ff ff       	call   1047ec <set_page_ref>
        uintptr_t pa = page2pa(page);
  105106:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105109:	89 04 24             	mov    %eax,(%esp)
  10510c:	e8 c2 f5 ff ff       	call   1046d3 <page2pa>
  105111:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  105114:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105117:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10511a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10511d:	c1 e8 0c             	shr    $0xc,%eax
  105120:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105123:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  105128:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10512b:	72 23                	jb     105150 <get_pte+0xad>
  10512d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105130:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105134:	c7 44 24 08 70 79 10 	movl   $0x107970,0x8(%esp)
  10513b:	00 
  10513c:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
  105143:	00 
  105144:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10514b:	e8 97 bb ff ff       	call   100ce7 <__panic>
  105150:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105153:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105158:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10515f:	00 
  105160:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105167:	00 
  105168:	89 04 24             	mov    %eax,(%esp)
  10516b:	e8 e3 18 00 00       	call   106a53 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  105170:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105173:	83 c8 07             	or     $0x7,%eax
  105176:	89 c2                	mov    %eax,%edx
  105178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10517b:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  10517d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105180:	8b 00                	mov    (%eax),%eax
  105182:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105187:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10518a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10518d:	c1 e8 0c             	shr    $0xc,%eax
  105190:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105193:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  105198:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10519b:	72 23                	jb     1051c0 <get_pte+0x11d>
  10519d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1051a4:	c7 44 24 08 70 79 10 	movl   $0x107970,0x8(%esp)
  1051ab:	00 
  1051ac:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
  1051b3:	00 
  1051b4:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1051bb:	e8 27 bb ff ff       	call   100ce7 <__panic>
  1051c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051c3:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1051c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1051cb:	c1 ea 0c             	shr    $0xc,%edx
  1051ce:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  1051d4:	c1 e2 02             	shl    $0x2,%edx
  1051d7:	01 d0                	add    %edx,%eax
}
  1051d9:	c9                   	leave  
  1051da:	c3                   	ret    

001051db <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1051db:	55                   	push   %ebp
  1051dc:	89 e5                	mov    %esp,%ebp
  1051de:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1051e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1051e8:	00 
  1051e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1051ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1051f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1051f3:	89 04 24             	mov    %eax,(%esp)
  1051f6:	e8 a8 fe ff ff       	call   1050a3 <get_pte>
  1051fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1051fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105202:	74 08                	je     10520c <get_page+0x31>
        *ptep_store = ptep;
  105204:	8b 45 10             	mov    0x10(%ebp),%eax
  105207:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10520a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10520c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105210:	74 1b                	je     10522d <get_page+0x52>
  105212:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105215:	8b 00                	mov    (%eax),%eax
  105217:	83 e0 01             	and    $0x1,%eax
  10521a:	85 c0                	test   %eax,%eax
  10521c:	74 0f                	je     10522d <get_page+0x52>
        return pte2page(*ptep);
  10521e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105221:	8b 00                	mov    (%eax),%eax
  105223:	89 04 24             	mov    %eax,(%esp)
  105226:	e8 61 f5 ff ff       	call   10478c <pte2page>
  10522b:	eb 05                	jmp    105232 <get_page+0x57>
    }
    return NULL;
  10522d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105232:	c9                   	leave  
  105233:	c3                   	ret    

00105234 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  105234:	55                   	push   %ebp
  105235:	89 e5                	mov    %esp,%ebp
  105237:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  10523a:	8b 45 10             	mov    0x10(%ebp),%eax
  10523d:	8b 00                	mov    (%eax),%eax
  10523f:	83 e0 01             	and    $0x1,%eax
  105242:	85 c0                	test   %eax,%eax
  105244:	74 4d                	je     105293 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  105246:	8b 45 10             	mov    0x10(%ebp),%eax
  105249:	8b 00                	mov    (%eax),%eax
  10524b:	89 04 24             	mov    %eax,(%esp)
  10524e:	e8 39 f5 ff ff       	call   10478c <pte2page>
  105253:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  105256:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105259:	89 04 24             	mov    %eax,(%esp)
  10525c:	e8 af f5 ff ff       	call   104810 <page_ref_dec>
  105261:	85 c0                	test   %eax,%eax
  105263:	75 13                	jne    105278 <page_remove_pte+0x44>
            free_page(page);
  105265:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10526c:	00 
  10526d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105270:	89 04 24             	mov    %eax,(%esp)
  105273:	e8 a7 f7 ff ff       	call   104a1f <free_pages>
        }
        *ptep = 0;
  105278:	8b 45 10             	mov    0x10(%ebp),%eax
  10527b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  105281:	8b 45 0c             	mov    0xc(%ebp),%eax
  105284:	89 44 24 04          	mov    %eax,0x4(%esp)
  105288:	8b 45 08             	mov    0x8(%ebp),%eax
  10528b:	89 04 24             	mov    %eax,(%esp)
  10528e:	e8 ff 00 00 00       	call   105392 <tlb_invalidate>
    }
}
  105293:	c9                   	leave  
  105294:	c3                   	ret    

00105295 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  105295:	55                   	push   %ebp
  105296:	89 e5                	mov    %esp,%ebp
  105298:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10529b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1052a2:	00 
  1052a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1052aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1052ad:	89 04 24             	mov    %eax,(%esp)
  1052b0:	e8 ee fd ff ff       	call   1050a3 <get_pte>
  1052b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1052b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1052bc:	74 19                	je     1052d7 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1052be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1052c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1052cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1052cf:	89 04 24             	mov    %eax,(%esp)
  1052d2:	e8 5d ff ff ff       	call   105234 <page_remove_pte>
    }
}
  1052d7:	c9                   	leave  
  1052d8:	c3                   	ret    

001052d9 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1052d9:	55                   	push   %ebp
  1052da:	89 e5                	mov    %esp,%ebp
  1052dc:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1052df:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1052e6:	00 
  1052e7:	8b 45 10             	mov    0x10(%ebp),%eax
  1052ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  1052ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1052f1:	89 04 24             	mov    %eax,(%esp)
  1052f4:	e8 aa fd ff ff       	call   1050a3 <get_pte>
  1052f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1052fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105300:	75 0a                	jne    10530c <page_insert+0x33>
        return -E_NO_MEM;
  105302:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  105307:	e9 84 00 00 00       	jmp    105390 <page_insert+0xb7>
    }
    page_ref_inc(page);
  10530c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10530f:	89 04 24             	mov    %eax,(%esp)
  105312:	e8 e2 f4 ff ff       	call   1047f9 <page_ref_inc>
    if (*ptep & PTE_P) {
  105317:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10531a:	8b 00                	mov    (%eax),%eax
  10531c:	83 e0 01             	and    $0x1,%eax
  10531f:	85 c0                	test   %eax,%eax
  105321:	74 3e                	je     105361 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  105323:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105326:	8b 00                	mov    (%eax),%eax
  105328:	89 04 24             	mov    %eax,(%esp)
  10532b:	e8 5c f4 ff ff       	call   10478c <pte2page>
  105330:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  105333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105336:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105339:	75 0d                	jne    105348 <page_insert+0x6f>
            page_ref_dec(page);
  10533b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10533e:	89 04 24             	mov    %eax,(%esp)
  105341:	e8 ca f4 ff ff       	call   104810 <page_ref_dec>
  105346:	eb 19                	jmp    105361 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  105348:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10534b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10534f:	8b 45 10             	mov    0x10(%ebp),%eax
  105352:	89 44 24 04          	mov    %eax,0x4(%esp)
  105356:	8b 45 08             	mov    0x8(%ebp),%eax
  105359:	89 04 24             	mov    %eax,(%esp)
  10535c:	e8 d3 fe ff ff       	call   105234 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  105361:	8b 45 0c             	mov    0xc(%ebp),%eax
  105364:	89 04 24             	mov    %eax,(%esp)
  105367:	e8 67 f3 ff ff       	call   1046d3 <page2pa>
  10536c:	0b 45 14             	or     0x14(%ebp),%eax
  10536f:	83 c8 01             	or     $0x1,%eax
  105372:	89 c2                	mov    %eax,%edx
  105374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105377:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  105379:	8b 45 10             	mov    0x10(%ebp),%eax
  10537c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105380:	8b 45 08             	mov    0x8(%ebp),%eax
  105383:	89 04 24             	mov    %eax,(%esp)
  105386:	e8 07 00 00 00       	call   105392 <tlb_invalidate>
    return 0;
  10538b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105390:	c9                   	leave  
  105391:	c3                   	ret    

00105392 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  105392:	55                   	push   %ebp
  105393:	89 e5                	mov    %esp,%ebp
  105395:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  105398:	0f 20 d8             	mov    %cr3,%eax
  10539b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10539e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  1053a1:	89 c2                	mov    %eax,%edx
  1053a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1053a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1053a9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1053b0:	77 23                	ja     1053d5 <tlb_invalidate+0x43>
  1053b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1053b9:	c7 44 24 08 14 7a 10 	movl   $0x107a14,0x8(%esp)
  1053c0:	00 
  1053c1:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  1053c8:	00 
  1053c9:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1053d0:	e8 12 b9 ff ff       	call   100ce7 <__panic>
  1053d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053d8:	05 00 00 00 40       	add    $0x40000000,%eax
  1053dd:	39 c2                	cmp    %eax,%edx
  1053df:	75 0c                	jne    1053ed <tlb_invalidate+0x5b>
        invlpg((void *)la);
  1053e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1053e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053ea:	0f 01 38             	invlpg (%eax)
    }
}
  1053ed:	c9                   	leave  
  1053ee:	c3                   	ret    

001053ef <check_alloc_page>:

static void
check_alloc_page(void) {
  1053ef:	55                   	push   %ebp
  1053f0:	89 e5                	mov    %esp,%ebp
  1053f2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1053f5:	a1 9c cf 11 00       	mov    0x11cf9c,%eax
  1053fa:	8b 40 18             	mov    0x18(%eax),%eax
  1053fd:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1053ff:	c7 04 24 98 7a 10 00 	movl   $0x107a98,(%esp)
  105406:	e8 48 af ff ff       	call   100353 <cprintf>
}
  10540b:	c9                   	leave  
  10540c:	c3                   	ret    

0010540d <check_pgdir>:

static void
check_pgdir(void) {
  10540d:	55                   	push   %ebp
  10540e:	89 e5                	mov    %esp,%ebp
  105410:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  105413:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  105418:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10541d:	76 24                	jbe    105443 <check_pgdir+0x36>
  10541f:	c7 44 24 0c b7 7a 10 	movl   $0x107ab7,0xc(%esp)
  105426:	00 
  105427:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  10542e:	00 
  10542f:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  105436:	00 
  105437:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10543e:	e8 a4 b8 ff ff       	call   100ce7 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  105443:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105448:	85 c0                	test   %eax,%eax
  10544a:	74 0e                	je     10545a <check_pgdir+0x4d>
  10544c:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105451:	25 ff 0f 00 00       	and    $0xfff,%eax
  105456:	85 c0                	test   %eax,%eax
  105458:	74 24                	je     10547e <check_pgdir+0x71>
  10545a:	c7 44 24 0c d4 7a 10 	movl   $0x107ad4,0xc(%esp)
  105461:	00 
  105462:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105469:	00 
  10546a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  105471:	00 
  105472:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105479:	e8 69 b8 ff ff       	call   100ce7 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10547e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105483:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10548a:	00 
  10548b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105492:	00 
  105493:	89 04 24             	mov    %eax,(%esp)
  105496:	e8 40 fd ff ff       	call   1051db <get_page>
  10549b:	85 c0                	test   %eax,%eax
  10549d:	74 24                	je     1054c3 <check_pgdir+0xb6>
  10549f:	c7 44 24 0c 0c 7b 10 	movl   $0x107b0c,0xc(%esp)
  1054a6:	00 
  1054a7:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1054ae:	00 
  1054af:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  1054b6:	00 
  1054b7:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1054be:	e8 24 b8 ff ff       	call   100ce7 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1054c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1054ca:	e8 18 f5 ff ff       	call   1049e7 <alloc_pages>
  1054cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1054d2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1054d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1054de:	00 
  1054df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1054e6:	00 
  1054e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  1054ee:	89 04 24             	mov    %eax,(%esp)
  1054f1:	e8 e3 fd ff ff       	call   1052d9 <page_insert>
  1054f6:	85 c0                	test   %eax,%eax
  1054f8:	74 24                	je     10551e <check_pgdir+0x111>
  1054fa:	c7 44 24 0c 34 7b 10 	movl   $0x107b34,0xc(%esp)
  105501:	00 
  105502:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105509:	00 
  10550a:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  105511:	00 
  105512:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105519:	e8 c9 b7 ff ff       	call   100ce7 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  10551e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105523:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10552a:	00 
  10552b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105532:	00 
  105533:	89 04 24             	mov    %eax,(%esp)
  105536:	e8 68 fb ff ff       	call   1050a3 <get_pte>
  10553b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10553e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105542:	75 24                	jne    105568 <check_pgdir+0x15b>
  105544:	c7 44 24 0c 60 7b 10 	movl   $0x107b60,0xc(%esp)
  10554b:	00 
  10554c:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105553:	00 
  105554:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  10555b:	00 
  10555c:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105563:	e8 7f b7 ff ff       	call   100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
  105568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10556b:	8b 00                	mov    (%eax),%eax
  10556d:	89 04 24             	mov    %eax,(%esp)
  105570:	e8 17 f2 ff ff       	call   10478c <pte2page>
  105575:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  105578:	74 24                	je     10559e <check_pgdir+0x191>
  10557a:	c7 44 24 0c 8d 7b 10 	movl   $0x107b8d,0xc(%esp)
  105581:	00 
  105582:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105589:	00 
  10558a:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  105591:	00 
  105592:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105599:	e8 49 b7 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p1) == 1);
  10559e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055a1:	89 04 24             	mov    %eax,(%esp)
  1055a4:	e8 39 f2 ff ff       	call   1047e2 <page_ref>
  1055a9:	83 f8 01             	cmp    $0x1,%eax
  1055ac:	74 24                	je     1055d2 <check_pgdir+0x1c5>
  1055ae:	c7 44 24 0c a3 7b 10 	movl   $0x107ba3,0xc(%esp)
  1055b5:	00 
  1055b6:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1055bd:	00 
  1055be:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  1055c5:	00 
  1055c6:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1055cd:	e8 15 b7 ff ff       	call   100ce7 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1055d2:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1055d7:	8b 00                	mov    (%eax),%eax
  1055d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1055de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1055e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055e4:	c1 e8 0c             	shr    $0xc,%eax
  1055e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1055ea:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  1055ef:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1055f2:	72 23                	jb     105617 <check_pgdir+0x20a>
  1055f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1055fb:	c7 44 24 08 70 79 10 	movl   $0x107970,0x8(%esp)
  105602:	00 
  105603:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  10560a:	00 
  10560b:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105612:	e8 d0 b6 ff ff       	call   100ce7 <__panic>
  105617:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10561a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10561f:	83 c0 04             	add    $0x4,%eax
  105622:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  105625:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10562a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105631:	00 
  105632:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105639:	00 
  10563a:	89 04 24             	mov    %eax,(%esp)
  10563d:	e8 61 fa ff ff       	call   1050a3 <get_pte>
  105642:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  105645:	74 24                	je     10566b <check_pgdir+0x25e>
  105647:	c7 44 24 0c b8 7b 10 	movl   $0x107bb8,0xc(%esp)
  10564e:	00 
  10564f:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105656:	00 
  105657:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  10565e:	00 
  10565f:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105666:	e8 7c b6 ff ff       	call   100ce7 <__panic>

    p2 = alloc_page();
  10566b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105672:	e8 70 f3 ff ff       	call   1049e7 <alloc_pages>
  105677:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  10567a:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10567f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  105686:	00 
  105687:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10568e:	00 
  10568f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105692:	89 54 24 04          	mov    %edx,0x4(%esp)
  105696:	89 04 24             	mov    %eax,(%esp)
  105699:	e8 3b fc ff ff       	call   1052d9 <page_insert>
  10569e:	85 c0                	test   %eax,%eax
  1056a0:	74 24                	je     1056c6 <check_pgdir+0x2b9>
  1056a2:	c7 44 24 0c e0 7b 10 	movl   $0x107be0,0xc(%esp)
  1056a9:	00 
  1056aa:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1056b1:	00 
  1056b2:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  1056b9:	00 
  1056ba:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1056c1:	e8 21 b6 ff ff       	call   100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1056c6:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1056cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1056d2:	00 
  1056d3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1056da:	00 
  1056db:	89 04 24             	mov    %eax,(%esp)
  1056de:	e8 c0 f9 ff ff       	call   1050a3 <get_pte>
  1056e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1056e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1056ea:	75 24                	jne    105710 <check_pgdir+0x303>
  1056ec:	c7 44 24 0c 18 7c 10 	movl   $0x107c18,0xc(%esp)
  1056f3:	00 
  1056f4:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1056fb:	00 
  1056fc:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  105703:	00 
  105704:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10570b:	e8 d7 b5 ff ff       	call   100ce7 <__panic>
    assert(*ptep & PTE_U);
  105710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105713:	8b 00                	mov    (%eax),%eax
  105715:	83 e0 04             	and    $0x4,%eax
  105718:	85 c0                	test   %eax,%eax
  10571a:	75 24                	jne    105740 <check_pgdir+0x333>
  10571c:	c7 44 24 0c 48 7c 10 	movl   $0x107c48,0xc(%esp)
  105723:	00 
  105724:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  10572b:	00 
  10572c:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  105733:	00 
  105734:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10573b:	e8 a7 b5 ff ff       	call   100ce7 <__panic>
    assert(*ptep & PTE_W);
  105740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105743:	8b 00                	mov    (%eax),%eax
  105745:	83 e0 02             	and    $0x2,%eax
  105748:	85 c0                	test   %eax,%eax
  10574a:	75 24                	jne    105770 <check_pgdir+0x363>
  10574c:	c7 44 24 0c 56 7c 10 	movl   $0x107c56,0xc(%esp)
  105753:	00 
  105754:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  10575b:	00 
  10575c:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  105763:	00 
  105764:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10576b:	e8 77 b5 ff ff       	call   100ce7 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  105770:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105775:	8b 00                	mov    (%eax),%eax
  105777:	83 e0 04             	and    $0x4,%eax
  10577a:	85 c0                	test   %eax,%eax
  10577c:	75 24                	jne    1057a2 <check_pgdir+0x395>
  10577e:	c7 44 24 0c 64 7c 10 	movl   $0x107c64,0xc(%esp)
  105785:	00 
  105786:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  10578d:	00 
  10578e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  105795:	00 
  105796:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10579d:	e8 45 b5 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 1);
  1057a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057a5:	89 04 24             	mov    %eax,(%esp)
  1057a8:	e8 35 f0 ff ff       	call   1047e2 <page_ref>
  1057ad:	83 f8 01             	cmp    $0x1,%eax
  1057b0:	74 24                	je     1057d6 <check_pgdir+0x3c9>
  1057b2:	c7 44 24 0c 7a 7c 10 	movl   $0x107c7a,0xc(%esp)
  1057b9:	00 
  1057ba:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1057c1:	00 
  1057c2:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  1057c9:	00 
  1057ca:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1057d1:	e8 11 b5 ff ff       	call   100ce7 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  1057d6:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1057db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1057e2:	00 
  1057e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1057ea:	00 
  1057eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1057ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057f2:	89 04 24             	mov    %eax,(%esp)
  1057f5:	e8 df fa ff ff       	call   1052d9 <page_insert>
  1057fa:	85 c0                	test   %eax,%eax
  1057fc:	74 24                	je     105822 <check_pgdir+0x415>
  1057fe:	c7 44 24 0c 8c 7c 10 	movl   $0x107c8c,0xc(%esp)
  105805:	00 
  105806:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  10580d:	00 
  10580e:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  105815:	00 
  105816:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10581d:	e8 c5 b4 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p1) == 2);
  105822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105825:	89 04 24             	mov    %eax,(%esp)
  105828:	e8 b5 ef ff ff       	call   1047e2 <page_ref>
  10582d:	83 f8 02             	cmp    $0x2,%eax
  105830:	74 24                	je     105856 <check_pgdir+0x449>
  105832:	c7 44 24 0c b8 7c 10 	movl   $0x107cb8,0xc(%esp)
  105839:	00 
  10583a:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105841:	00 
  105842:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  105849:	00 
  10584a:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105851:	e8 91 b4 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 0);
  105856:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105859:	89 04 24             	mov    %eax,(%esp)
  10585c:	e8 81 ef ff ff       	call   1047e2 <page_ref>
  105861:	85 c0                	test   %eax,%eax
  105863:	74 24                	je     105889 <check_pgdir+0x47c>
  105865:	c7 44 24 0c ca 7c 10 	movl   $0x107cca,0xc(%esp)
  10586c:	00 
  10586d:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105874:	00 
  105875:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  10587c:	00 
  10587d:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105884:	e8 5e b4 ff ff       	call   100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  105889:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10588e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105895:	00 
  105896:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10589d:	00 
  10589e:	89 04 24             	mov    %eax,(%esp)
  1058a1:	e8 fd f7 ff ff       	call   1050a3 <get_pte>
  1058a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1058ad:	75 24                	jne    1058d3 <check_pgdir+0x4c6>
  1058af:	c7 44 24 0c 18 7c 10 	movl   $0x107c18,0xc(%esp)
  1058b6:	00 
  1058b7:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1058be:	00 
  1058bf:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  1058c6:	00 
  1058c7:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1058ce:	e8 14 b4 ff ff       	call   100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
  1058d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058d6:	8b 00                	mov    (%eax),%eax
  1058d8:	89 04 24             	mov    %eax,(%esp)
  1058db:	e8 ac ee ff ff       	call   10478c <pte2page>
  1058e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1058e3:	74 24                	je     105909 <check_pgdir+0x4fc>
  1058e5:	c7 44 24 0c 8d 7b 10 	movl   $0x107b8d,0xc(%esp)
  1058ec:	00 
  1058ed:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1058f4:	00 
  1058f5:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  1058fc:	00 
  1058fd:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105904:	e8 de b3 ff ff       	call   100ce7 <__panic>
    assert((*ptep & PTE_U) == 0);
  105909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10590c:	8b 00                	mov    (%eax),%eax
  10590e:	83 e0 04             	and    $0x4,%eax
  105911:	85 c0                	test   %eax,%eax
  105913:	74 24                	je     105939 <check_pgdir+0x52c>
  105915:	c7 44 24 0c dc 7c 10 	movl   $0x107cdc,0xc(%esp)
  10591c:	00 
  10591d:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105924:	00 
  105925:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  10592c:	00 
  10592d:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105934:	e8 ae b3 ff ff       	call   100ce7 <__panic>

    page_remove(boot_pgdir, 0x0);
  105939:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10593e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105945:	00 
  105946:	89 04 24             	mov    %eax,(%esp)
  105949:	e8 47 f9 ff ff       	call   105295 <page_remove>
    assert(page_ref(p1) == 1);
  10594e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105951:	89 04 24             	mov    %eax,(%esp)
  105954:	e8 89 ee ff ff       	call   1047e2 <page_ref>
  105959:	83 f8 01             	cmp    $0x1,%eax
  10595c:	74 24                	je     105982 <check_pgdir+0x575>
  10595e:	c7 44 24 0c a3 7b 10 	movl   $0x107ba3,0xc(%esp)
  105965:	00 
  105966:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  10596d:	00 
  10596e:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  105975:	00 
  105976:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  10597d:	e8 65 b3 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 0);
  105982:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105985:	89 04 24             	mov    %eax,(%esp)
  105988:	e8 55 ee ff ff       	call   1047e2 <page_ref>
  10598d:	85 c0                	test   %eax,%eax
  10598f:	74 24                	je     1059b5 <check_pgdir+0x5a8>
  105991:	c7 44 24 0c ca 7c 10 	movl   $0x107cca,0xc(%esp)
  105998:	00 
  105999:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1059a0:	00 
  1059a1:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  1059a8:	00 
  1059a9:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1059b0:	e8 32 b3 ff ff       	call   100ce7 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  1059b5:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1059ba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1059c1:	00 
  1059c2:	89 04 24             	mov    %eax,(%esp)
  1059c5:	e8 cb f8 ff ff       	call   105295 <page_remove>
    assert(page_ref(p1) == 0);
  1059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059cd:	89 04 24             	mov    %eax,(%esp)
  1059d0:	e8 0d ee ff ff       	call   1047e2 <page_ref>
  1059d5:	85 c0                	test   %eax,%eax
  1059d7:	74 24                	je     1059fd <check_pgdir+0x5f0>
  1059d9:	c7 44 24 0c f1 7c 10 	movl   $0x107cf1,0xc(%esp)
  1059e0:	00 
  1059e1:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  1059e8:	00 
  1059e9:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  1059f0:	00 
  1059f1:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  1059f8:	e8 ea b2 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 0);
  1059fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a00:	89 04 24             	mov    %eax,(%esp)
  105a03:	e8 da ed ff ff       	call   1047e2 <page_ref>
  105a08:	85 c0                	test   %eax,%eax
  105a0a:	74 24                	je     105a30 <check_pgdir+0x623>
  105a0c:	c7 44 24 0c ca 7c 10 	movl   $0x107cca,0xc(%esp)
  105a13:	00 
  105a14:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105a1b:	00 
  105a1c:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  105a23:	00 
  105a24:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105a2b:	e8 b7 b2 ff ff       	call   100ce7 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  105a30:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105a35:	8b 00                	mov    (%eax),%eax
  105a37:	89 04 24             	mov    %eax,(%esp)
  105a3a:	e8 8b ed ff ff       	call   1047ca <pde2page>
  105a3f:	89 04 24             	mov    %eax,(%esp)
  105a42:	e8 9b ed ff ff       	call   1047e2 <page_ref>
  105a47:	83 f8 01             	cmp    $0x1,%eax
  105a4a:	74 24                	je     105a70 <check_pgdir+0x663>
  105a4c:	c7 44 24 0c 04 7d 10 	movl   $0x107d04,0xc(%esp)
  105a53:	00 
  105a54:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105a5b:	00 
  105a5c:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  105a63:	00 
  105a64:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105a6b:	e8 77 b2 ff ff       	call   100ce7 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  105a70:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105a75:	8b 00                	mov    (%eax),%eax
  105a77:	89 04 24             	mov    %eax,(%esp)
  105a7a:	e8 4b ed ff ff       	call   1047ca <pde2page>
  105a7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105a86:	00 
  105a87:	89 04 24             	mov    %eax,(%esp)
  105a8a:	e8 90 ef ff ff       	call   104a1f <free_pages>
    boot_pgdir[0] = 0;
  105a8f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105a94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  105a9a:	c7 04 24 2b 7d 10 00 	movl   $0x107d2b,(%esp)
  105aa1:	e8 ad a8 ff ff       	call   100353 <cprintf>
}
  105aa6:	c9                   	leave  
  105aa7:	c3                   	ret    

00105aa8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  105aa8:	55                   	push   %ebp
  105aa9:	89 e5                	mov    %esp,%ebp
  105aab:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  105aae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105ab5:	e9 ca 00 00 00       	jmp    105b84 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  105aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ac3:	c1 e8 0c             	shr    $0xc,%eax
  105ac6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ac9:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  105ace:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105ad1:	72 23                	jb     105af6 <check_boot_pgdir+0x4e>
  105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ad6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ada:	c7 44 24 08 70 79 10 	movl   $0x107970,0x8(%esp)
  105ae1:	00 
  105ae2:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  105ae9:	00 
  105aea:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105af1:	e8 f1 b1 ff ff       	call   100ce7 <__panic>
  105af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105af9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105afe:	89 c2                	mov    %eax,%edx
  105b00:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105b05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105b0c:	00 
  105b0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b11:	89 04 24             	mov    %eax,(%esp)
  105b14:	e8 8a f5 ff ff       	call   1050a3 <get_pte>
  105b19:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b1c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b20:	75 24                	jne    105b46 <check_boot_pgdir+0x9e>
  105b22:	c7 44 24 0c 48 7d 10 	movl   $0x107d48,0xc(%esp)
  105b29:	00 
  105b2a:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105b31:	00 
  105b32:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  105b39:	00 
  105b3a:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105b41:	e8 a1 b1 ff ff       	call   100ce7 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  105b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105b49:	8b 00                	mov    (%eax),%eax
  105b4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105b50:	89 c2                	mov    %eax,%edx
  105b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b55:	39 c2                	cmp    %eax,%edx
  105b57:	74 24                	je     105b7d <check_boot_pgdir+0xd5>
  105b59:	c7 44 24 0c 85 7d 10 	movl   $0x107d85,0xc(%esp)
  105b60:	00 
  105b61:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105b68:	00 
  105b69:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  105b70:	00 
  105b71:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105b78:	e8 6a b1 ff ff       	call   100ce7 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  105b7d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  105b84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b87:	a1 a0 ce 11 00       	mov    0x11cea0,%eax
  105b8c:	39 c2                	cmp    %eax,%edx
  105b8e:	0f 82 26 ff ff ff    	jb     105aba <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  105b94:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105b99:	05 ac 0f 00 00       	add    $0xfac,%eax
  105b9e:	8b 00                	mov    (%eax),%eax
  105ba0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105ba5:	89 c2                	mov    %eax,%edx
  105ba7:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105bac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105baf:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  105bb6:	77 23                	ja     105bdb <check_boot_pgdir+0x133>
  105bb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105bbf:	c7 44 24 08 14 7a 10 	movl   $0x107a14,0x8(%esp)
  105bc6:	00 
  105bc7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  105bce:	00 
  105bcf:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105bd6:	e8 0c b1 ff ff       	call   100ce7 <__panic>
  105bdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105bde:	05 00 00 00 40       	add    $0x40000000,%eax
  105be3:	39 c2                	cmp    %eax,%edx
  105be5:	74 24                	je     105c0b <check_boot_pgdir+0x163>
  105be7:	c7 44 24 0c 9c 7d 10 	movl   $0x107d9c,0xc(%esp)
  105bee:	00 
  105bef:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105bf6:	00 
  105bf7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  105bfe:	00 
  105bff:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105c06:	e8 dc b0 ff ff       	call   100ce7 <__panic>

    assert(boot_pgdir[0] == 0);
  105c0b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105c10:	8b 00                	mov    (%eax),%eax
  105c12:	85 c0                	test   %eax,%eax
  105c14:	74 24                	je     105c3a <check_boot_pgdir+0x192>
  105c16:	c7 44 24 0c d0 7d 10 	movl   $0x107dd0,0xc(%esp)
  105c1d:	00 
  105c1e:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105c25:	00 
  105c26:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  105c2d:	00 
  105c2e:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105c35:	e8 ad b0 ff ff       	call   100ce7 <__panic>

    struct Page *p;
    p = alloc_page();
  105c3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105c41:	e8 a1 ed ff ff       	call   1049e7 <alloc_pages>
  105c46:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  105c49:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105c4e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105c55:	00 
  105c56:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  105c5d:	00 
  105c5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105c61:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c65:	89 04 24             	mov    %eax,(%esp)
  105c68:	e8 6c f6 ff ff       	call   1052d9 <page_insert>
  105c6d:	85 c0                	test   %eax,%eax
  105c6f:	74 24                	je     105c95 <check_boot_pgdir+0x1ed>
  105c71:	c7 44 24 0c e4 7d 10 	movl   $0x107de4,0xc(%esp)
  105c78:	00 
  105c79:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105c80:	00 
  105c81:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  105c88:	00 
  105c89:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105c90:	e8 52 b0 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p) == 1);
  105c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c98:	89 04 24             	mov    %eax,(%esp)
  105c9b:	e8 42 eb ff ff       	call   1047e2 <page_ref>
  105ca0:	83 f8 01             	cmp    $0x1,%eax
  105ca3:	74 24                	je     105cc9 <check_boot_pgdir+0x221>
  105ca5:	c7 44 24 0c 12 7e 10 	movl   $0x107e12,0xc(%esp)
  105cac:	00 
  105cad:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105cb4:	00 
  105cb5:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  105cbc:	00 
  105cbd:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105cc4:	e8 1e b0 ff ff       	call   100ce7 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105cc9:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105cce:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105cd5:	00 
  105cd6:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  105cdd:	00 
  105cde:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105ce1:	89 54 24 04          	mov    %edx,0x4(%esp)
  105ce5:	89 04 24             	mov    %eax,(%esp)
  105ce8:	e8 ec f5 ff ff       	call   1052d9 <page_insert>
  105ced:	85 c0                	test   %eax,%eax
  105cef:	74 24                	je     105d15 <check_boot_pgdir+0x26d>
  105cf1:	c7 44 24 0c 24 7e 10 	movl   $0x107e24,0xc(%esp)
  105cf8:	00 
  105cf9:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105d00:	00 
  105d01:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  105d08:	00 
  105d09:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105d10:	e8 d2 af ff ff       	call   100ce7 <__panic>
    assert(page_ref(p) == 2);
  105d15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d18:	89 04 24             	mov    %eax,(%esp)
  105d1b:	e8 c2 ea ff ff       	call   1047e2 <page_ref>
  105d20:	83 f8 02             	cmp    $0x2,%eax
  105d23:	74 24                	je     105d49 <check_boot_pgdir+0x2a1>
  105d25:	c7 44 24 0c 5b 7e 10 	movl   $0x107e5b,0xc(%esp)
  105d2c:	00 
  105d2d:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105d34:	00 
  105d35:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  105d3c:	00 
  105d3d:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105d44:	e8 9e af ff ff       	call   100ce7 <__panic>

    const char *str = "ucore: Hello world!!";
  105d49:	c7 45 dc 6c 7e 10 00 	movl   $0x107e6c,-0x24(%ebp)
    strcpy((void *)0x100, str);
  105d50:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d57:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105d5e:	e8 19 0a 00 00       	call   10677c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105d63:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  105d6a:	00 
  105d6b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105d72:	e8 7e 0a 00 00       	call   1067f5 <strcmp>
  105d77:	85 c0                	test   %eax,%eax
  105d79:	74 24                	je     105d9f <check_boot_pgdir+0x2f7>
  105d7b:	c7 44 24 0c 84 7e 10 	movl   $0x107e84,0xc(%esp)
  105d82:	00 
  105d83:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105d8a:	00 
  105d8b:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  105d92:	00 
  105d93:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105d9a:	e8 48 af ff ff       	call   100ce7 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105d9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105da2:	89 04 24             	mov    %eax,(%esp)
  105da5:	e8 8e e9 ff ff       	call   104738 <page2kva>
  105daa:	05 00 01 00 00       	add    $0x100,%eax
  105daf:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  105db2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105db9:	e8 66 09 00 00       	call   106724 <strlen>
  105dbe:	85 c0                	test   %eax,%eax
  105dc0:	74 24                	je     105de6 <check_boot_pgdir+0x33e>
  105dc2:	c7 44 24 0c bc 7e 10 	movl   $0x107ebc,0xc(%esp)
  105dc9:	00 
  105dca:	c7 44 24 08 5d 7a 10 	movl   $0x107a5d,0x8(%esp)
  105dd1:	00 
  105dd2:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  105dd9:	00 
  105dda:	c7 04 24 38 7a 10 00 	movl   $0x107a38,(%esp)
  105de1:	e8 01 af ff ff       	call   100ce7 <__panic>

    free_page(p);
  105de6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105ded:	00 
  105dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105df1:	89 04 24             	mov    %eax,(%esp)
  105df4:	e8 26 ec ff ff       	call   104a1f <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  105df9:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105dfe:	8b 00                	mov    (%eax),%eax
  105e00:	89 04 24             	mov    %eax,(%esp)
  105e03:	e8 c2 e9 ff ff       	call   1047ca <pde2page>
  105e08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105e0f:	00 
  105e10:	89 04 24             	mov    %eax,(%esp)
  105e13:	e8 07 ec ff ff       	call   104a1f <free_pages>
    boot_pgdir[0] = 0;
  105e18:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105e1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105e23:	c7 04 24 e0 7e 10 00 	movl   $0x107ee0,(%esp)
  105e2a:	e8 24 a5 ff ff       	call   100353 <cprintf>
}
  105e2f:	c9                   	leave  
  105e30:	c3                   	ret    

00105e31 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105e31:	55                   	push   %ebp
  105e32:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105e34:	8b 45 08             	mov    0x8(%ebp),%eax
  105e37:	83 e0 04             	and    $0x4,%eax
  105e3a:	85 c0                	test   %eax,%eax
  105e3c:	74 07                	je     105e45 <perm2str+0x14>
  105e3e:	b8 75 00 00 00       	mov    $0x75,%eax
  105e43:	eb 05                	jmp    105e4a <perm2str+0x19>
  105e45:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105e4a:	a2 28 cf 11 00       	mov    %al,0x11cf28
    str[1] = 'r';
  105e4f:	c6 05 29 cf 11 00 72 	movb   $0x72,0x11cf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105e56:	8b 45 08             	mov    0x8(%ebp),%eax
  105e59:	83 e0 02             	and    $0x2,%eax
  105e5c:	85 c0                	test   %eax,%eax
  105e5e:	74 07                	je     105e67 <perm2str+0x36>
  105e60:	b8 77 00 00 00       	mov    $0x77,%eax
  105e65:	eb 05                	jmp    105e6c <perm2str+0x3b>
  105e67:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105e6c:	a2 2a cf 11 00       	mov    %al,0x11cf2a
    str[3] = '\0';
  105e71:	c6 05 2b cf 11 00 00 	movb   $0x0,0x11cf2b
    return str;
  105e78:	b8 28 cf 11 00       	mov    $0x11cf28,%eax
}
  105e7d:	5d                   	pop    %ebp
  105e7e:	c3                   	ret    

00105e7f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105e7f:	55                   	push   %ebp
  105e80:	89 e5                	mov    %esp,%ebp
  105e82:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  105e85:	8b 45 10             	mov    0x10(%ebp),%eax
  105e88:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105e8b:	72 0a                	jb     105e97 <get_pgtable_items+0x18>
        return 0;
  105e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  105e92:	e9 9c 00 00 00       	jmp    105f33 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  105e97:	eb 04                	jmp    105e9d <get_pgtable_items+0x1e>
        start ++;
  105e99:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  105e9d:	8b 45 10             	mov    0x10(%ebp),%eax
  105ea0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105ea3:	73 18                	jae    105ebd <get_pgtable_items+0x3e>
  105ea5:	8b 45 10             	mov    0x10(%ebp),%eax
  105ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105eaf:	8b 45 14             	mov    0x14(%ebp),%eax
  105eb2:	01 d0                	add    %edx,%eax
  105eb4:	8b 00                	mov    (%eax),%eax
  105eb6:	83 e0 01             	and    $0x1,%eax
  105eb9:	85 c0                	test   %eax,%eax
  105ebb:	74 dc                	je     105e99 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  105ebd:	8b 45 10             	mov    0x10(%ebp),%eax
  105ec0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105ec3:	73 69                	jae    105f2e <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  105ec5:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  105ec9:	74 08                	je     105ed3 <get_pgtable_items+0x54>
            *left_store = start;
  105ecb:	8b 45 18             	mov    0x18(%ebp),%eax
  105ece:	8b 55 10             	mov    0x10(%ebp),%edx
  105ed1:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105ed3:	8b 45 10             	mov    0x10(%ebp),%eax
  105ed6:	8d 50 01             	lea    0x1(%eax),%edx
  105ed9:	89 55 10             	mov    %edx,0x10(%ebp)
  105edc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105ee3:	8b 45 14             	mov    0x14(%ebp),%eax
  105ee6:	01 d0                	add    %edx,%eax
  105ee8:	8b 00                	mov    (%eax),%eax
  105eea:	83 e0 07             	and    $0x7,%eax
  105eed:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105ef0:	eb 04                	jmp    105ef6 <get_pgtable_items+0x77>
            start ++;
  105ef2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  105ef6:	8b 45 10             	mov    0x10(%ebp),%eax
  105ef9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105efc:	73 1d                	jae    105f1b <get_pgtable_items+0x9c>
  105efe:	8b 45 10             	mov    0x10(%ebp),%eax
  105f01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105f08:	8b 45 14             	mov    0x14(%ebp),%eax
  105f0b:	01 d0                	add    %edx,%eax
  105f0d:	8b 00                	mov    (%eax),%eax
  105f0f:	83 e0 07             	and    $0x7,%eax
  105f12:	89 c2                	mov    %eax,%edx
  105f14:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f17:	39 c2                	cmp    %eax,%edx
  105f19:	74 d7                	je     105ef2 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  105f1b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105f1f:	74 08                	je     105f29 <get_pgtable_items+0xaa>
            *right_store = start;
  105f21:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105f24:	8b 55 10             	mov    0x10(%ebp),%edx
  105f27:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f2c:	eb 05                	jmp    105f33 <get_pgtable_items+0xb4>
    }
    return 0;
  105f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105f33:	c9                   	leave  
  105f34:	c3                   	ret    

00105f35 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  105f35:	55                   	push   %ebp
  105f36:	89 e5                	mov    %esp,%ebp
  105f38:	57                   	push   %edi
  105f39:	56                   	push   %esi
  105f3a:	53                   	push   %ebx
  105f3b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105f3e:	c7 04 24 00 7f 10 00 	movl   $0x107f00,(%esp)
  105f45:	e8 09 a4 ff ff       	call   100353 <cprintf>
    size_t left, right = 0, perm;
  105f4a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105f51:	e9 fa 00 00 00       	jmp    106050 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f59:	89 04 24             	mov    %eax,(%esp)
  105f5c:	e8 d0 fe ff ff       	call   105e31 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  105f61:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105f64:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105f67:	29 d1                	sub    %edx,%ecx
  105f69:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105f6b:	89 d6                	mov    %edx,%esi
  105f6d:	c1 e6 16             	shl    $0x16,%esi
  105f70:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105f73:	89 d3                	mov    %edx,%ebx
  105f75:	c1 e3 16             	shl    $0x16,%ebx
  105f78:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105f7b:	89 d1                	mov    %edx,%ecx
  105f7d:	c1 e1 16             	shl    $0x16,%ecx
  105f80:	8b 7d dc             	mov    -0x24(%ebp),%edi
  105f83:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105f86:	29 d7                	sub    %edx,%edi
  105f88:	89 fa                	mov    %edi,%edx
  105f8a:	89 44 24 14          	mov    %eax,0x14(%esp)
  105f8e:	89 74 24 10          	mov    %esi,0x10(%esp)
  105f92:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105f96:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105f9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  105f9e:	c7 04 24 31 7f 10 00 	movl   $0x107f31,(%esp)
  105fa5:	e8 a9 a3 ff ff       	call   100353 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  105faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105fad:	c1 e0 0a             	shl    $0xa,%eax
  105fb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105fb3:	eb 54                	jmp    106009 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105fb8:	89 04 24             	mov    %eax,(%esp)
  105fbb:	e8 71 fe ff ff       	call   105e31 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  105fc0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105fc3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105fc6:	29 d1                	sub    %edx,%ecx
  105fc8:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105fca:	89 d6                	mov    %edx,%esi
  105fcc:	c1 e6 0c             	shl    $0xc,%esi
  105fcf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105fd2:	89 d3                	mov    %edx,%ebx
  105fd4:	c1 e3 0c             	shl    $0xc,%ebx
  105fd7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105fda:	c1 e2 0c             	shl    $0xc,%edx
  105fdd:	89 d1                	mov    %edx,%ecx
  105fdf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  105fe2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105fe5:	29 d7                	sub    %edx,%edi
  105fe7:	89 fa                	mov    %edi,%edx
  105fe9:	89 44 24 14          	mov    %eax,0x14(%esp)
  105fed:	89 74 24 10          	mov    %esi,0x10(%esp)
  105ff1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105ff5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105ff9:	89 54 24 04          	mov    %edx,0x4(%esp)
  105ffd:	c7 04 24 50 7f 10 00 	movl   $0x107f50,(%esp)
  106004:	e8 4a a3 ff ff       	call   100353 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  106009:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  10600e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  106011:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  106014:	89 ce                	mov    %ecx,%esi
  106016:	c1 e6 0a             	shl    $0xa,%esi
  106019:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  10601c:	89 cb                	mov    %ecx,%ebx
  10601e:	c1 e3 0a             	shl    $0xa,%ebx
  106021:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  106024:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  106028:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  10602b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10602f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106033:	89 44 24 08          	mov    %eax,0x8(%esp)
  106037:	89 74 24 04          	mov    %esi,0x4(%esp)
  10603b:	89 1c 24             	mov    %ebx,(%esp)
  10603e:	e8 3c fe ff ff       	call   105e7f <get_pgtable_items>
  106043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106046:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10604a:	0f 85 65 ff ff ff    	jne    105fb5 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  106050:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  106055:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106058:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  10605b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  10605f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  106062:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  106066:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10606a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10606e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  106075:	00 
  106076:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10607d:	e8 fd fd ff ff       	call   105e7f <get_pgtable_items>
  106082:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106085:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106089:	0f 85 c7 fe ff ff    	jne    105f56 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  10608f:	c7 04 24 74 7f 10 00 	movl   $0x107f74,(%esp)
  106096:	e8 b8 a2 ff ff       	call   100353 <cprintf>
}
  10609b:	83 c4 4c             	add    $0x4c,%esp
  10609e:	5b                   	pop    %ebx
  10609f:	5e                   	pop    %esi
  1060a0:	5f                   	pop    %edi
  1060a1:	5d                   	pop    %ebp
  1060a2:	c3                   	ret    

001060a3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1060a3:	55                   	push   %ebp
  1060a4:	89 e5                	mov    %esp,%ebp
  1060a6:	83 ec 58             	sub    $0x58,%esp
  1060a9:	8b 45 10             	mov    0x10(%ebp),%eax
  1060ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1060af:	8b 45 14             	mov    0x14(%ebp),%eax
  1060b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1060b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1060b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1060bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1060be:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1060c1:	8b 45 18             	mov    0x18(%ebp),%eax
  1060c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1060c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1060ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1060cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1060d0:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1060d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1060d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1060dd:	74 1c                	je     1060fb <printnum+0x58>
  1060df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060e2:	ba 00 00 00 00       	mov    $0x0,%edx
  1060e7:	f7 75 e4             	divl   -0x1c(%ebp)
  1060ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1060ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060f0:	ba 00 00 00 00       	mov    $0x0,%edx
  1060f5:	f7 75 e4             	divl   -0x1c(%ebp)
  1060f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1060fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1060fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106101:	f7 75 e4             	divl   -0x1c(%ebp)
  106104:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106107:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10610a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10610d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106110:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106113:	89 55 ec             	mov    %edx,-0x14(%ebp)
  106116:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106119:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10611c:	8b 45 18             	mov    0x18(%ebp),%eax
  10611f:	ba 00 00 00 00       	mov    $0x0,%edx
  106124:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  106127:	77 56                	ja     10617f <printnum+0xdc>
  106129:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10612c:	72 05                	jb     106133 <printnum+0x90>
  10612e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  106131:	77 4c                	ja     10617f <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  106133:	8b 45 1c             	mov    0x1c(%ebp),%eax
  106136:	8d 50 ff             	lea    -0x1(%eax),%edx
  106139:	8b 45 20             	mov    0x20(%ebp),%eax
  10613c:	89 44 24 18          	mov    %eax,0x18(%esp)
  106140:	89 54 24 14          	mov    %edx,0x14(%esp)
  106144:	8b 45 18             	mov    0x18(%ebp),%eax
  106147:	89 44 24 10          	mov    %eax,0x10(%esp)
  10614b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10614e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106151:	89 44 24 08          	mov    %eax,0x8(%esp)
  106155:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106159:	8b 45 0c             	mov    0xc(%ebp),%eax
  10615c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106160:	8b 45 08             	mov    0x8(%ebp),%eax
  106163:	89 04 24             	mov    %eax,(%esp)
  106166:	e8 38 ff ff ff       	call   1060a3 <printnum>
  10616b:	eb 1c                	jmp    106189 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10616d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106170:	89 44 24 04          	mov    %eax,0x4(%esp)
  106174:	8b 45 20             	mov    0x20(%ebp),%eax
  106177:	89 04 24             	mov    %eax,(%esp)
  10617a:	8b 45 08             	mov    0x8(%ebp),%eax
  10617d:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  10617f:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  106183:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  106187:	7f e4                	jg     10616d <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  106189:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10618c:	05 28 80 10 00       	add    $0x108028,%eax
  106191:	0f b6 00             	movzbl (%eax),%eax
  106194:	0f be c0             	movsbl %al,%eax
  106197:	8b 55 0c             	mov    0xc(%ebp),%edx
  10619a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10619e:	89 04 24             	mov    %eax,(%esp)
  1061a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1061a4:	ff d0                	call   *%eax
}
  1061a6:	c9                   	leave  
  1061a7:	c3                   	ret    

001061a8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1061a8:	55                   	push   %ebp
  1061a9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1061ab:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1061af:	7e 14                	jle    1061c5 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1061b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1061b4:	8b 00                	mov    (%eax),%eax
  1061b6:	8d 48 08             	lea    0x8(%eax),%ecx
  1061b9:	8b 55 08             	mov    0x8(%ebp),%edx
  1061bc:	89 0a                	mov    %ecx,(%edx)
  1061be:	8b 50 04             	mov    0x4(%eax),%edx
  1061c1:	8b 00                	mov    (%eax),%eax
  1061c3:	eb 30                	jmp    1061f5 <getuint+0x4d>
    }
    else if (lflag) {
  1061c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1061c9:	74 16                	je     1061e1 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1061cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1061ce:	8b 00                	mov    (%eax),%eax
  1061d0:	8d 48 04             	lea    0x4(%eax),%ecx
  1061d3:	8b 55 08             	mov    0x8(%ebp),%edx
  1061d6:	89 0a                	mov    %ecx,(%edx)
  1061d8:	8b 00                	mov    (%eax),%eax
  1061da:	ba 00 00 00 00       	mov    $0x0,%edx
  1061df:	eb 14                	jmp    1061f5 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1061e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1061e4:	8b 00                	mov    (%eax),%eax
  1061e6:	8d 48 04             	lea    0x4(%eax),%ecx
  1061e9:	8b 55 08             	mov    0x8(%ebp),%edx
  1061ec:	89 0a                	mov    %ecx,(%edx)
  1061ee:	8b 00                	mov    (%eax),%eax
  1061f0:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1061f5:	5d                   	pop    %ebp
  1061f6:	c3                   	ret    

001061f7 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1061f7:	55                   	push   %ebp
  1061f8:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1061fa:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1061fe:	7e 14                	jle    106214 <getint+0x1d>
        return va_arg(*ap, long long);
  106200:	8b 45 08             	mov    0x8(%ebp),%eax
  106203:	8b 00                	mov    (%eax),%eax
  106205:	8d 48 08             	lea    0x8(%eax),%ecx
  106208:	8b 55 08             	mov    0x8(%ebp),%edx
  10620b:	89 0a                	mov    %ecx,(%edx)
  10620d:	8b 50 04             	mov    0x4(%eax),%edx
  106210:	8b 00                	mov    (%eax),%eax
  106212:	eb 28                	jmp    10623c <getint+0x45>
    }
    else if (lflag) {
  106214:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106218:	74 12                	je     10622c <getint+0x35>
        return va_arg(*ap, long);
  10621a:	8b 45 08             	mov    0x8(%ebp),%eax
  10621d:	8b 00                	mov    (%eax),%eax
  10621f:	8d 48 04             	lea    0x4(%eax),%ecx
  106222:	8b 55 08             	mov    0x8(%ebp),%edx
  106225:	89 0a                	mov    %ecx,(%edx)
  106227:	8b 00                	mov    (%eax),%eax
  106229:	99                   	cltd   
  10622a:	eb 10                	jmp    10623c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10622c:	8b 45 08             	mov    0x8(%ebp),%eax
  10622f:	8b 00                	mov    (%eax),%eax
  106231:	8d 48 04             	lea    0x4(%eax),%ecx
  106234:	8b 55 08             	mov    0x8(%ebp),%edx
  106237:	89 0a                	mov    %ecx,(%edx)
  106239:	8b 00                	mov    (%eax),%eax
  10623b:	99                   	cltd   
    }
}
  10623c:	5d                   	pop    %ebp
  10623d:	c3                   	ret    

0010623e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10623e:	55                   	push   %ebp
  10623f:	89 e5                	mov    %esp,%ebp
  106241:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  106244:	8d 45 14             	lea    0x14(%ebp),%eax
  106247:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10624a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10624d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106251:	8b 45 10             	mov    0x10(%ebp),%eax
  106254:	89 44 24 08          	mov    %eax,0x8(%esp)
  106258:	8b 45 0c             	mov    0xc(%ebp),%eax
  10625b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10625f:	8b 45 08             	mov    0x8(%ebp),%eax
  106262:	89 04 24             	mov    %eax,(%esp)
  106265:	e8 02 00 00 00       	call   10626c <vprintfmt>
    va_end(ap);
}
  10626a:	c9                   	leave  
  10626b:	c3                   	ret    

0010626c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10626c:	55                   	push   %ebp
  10626d:	89 e5                	mov    %esp,%ebp
  10626f:	56                   	push   %esi
  106270:	53                   	push   %ebx
  106271:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  106274:	eb 18                	jmp    10628e <vprintfmt+0x22>
            if (ch == '\0') {
  106276:	85 db                	test   %ebx,%ebx
  106278:	75 05                	jne    10627f <vprintfmt+0x13>
                return;
  10627a:	e9 d1 03 00 00       	jmp    106650 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  10627f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106282:	89 44 24 04          	mov    %eax,0x4(%esp)
  106286:	89 1c 24             	mov    %ebx,(%esp)
  106289:	8b 45 08             	mov    0x8(%ebp),%eax
  10628c:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10628e:	8b 45 10             	mov    0x10(%ebp),%eax
  106291:	8d 50 01             	lea    0x1(%eax),%edx
  106294:	89 55 10             	mov    %edx,0x10(%ebp)
  106297:	0f b6 00             	movzbl (%eax),%eax
  10629a:	0f b6 d8             	movzbl %al,%ebx
  10629d:	83 fb 25             	cmp    $0x25,%ebx
  1062a0:	75 d4                	jne    106276 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  1062a2:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1062a6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1062ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1062b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1062b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1062ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1062bd:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1062c0:	8b 45 10             	mov    0x10(%ebp),%eax
  1062c3:	8d 50 01             	lea    0x1(%eax),%edx
  1062c6:	89 55 10             	mov    %edx,0x10(%ebp)
  1062c9:	0f b6 00             	movzbl (%eax),%eax
  1062cc:	0f b6 d8             	movzbl %al,%ebx
  1062cf:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1062d2:	83 f8 55             	cmp    $0x55,%eax
  1062d5:	0f 87 44 03 00 00    	ja     10661f <vprintfmt+0x3b3>
  1062db:	8b 04 85 4c 80 10 00 	mov    0x10804c(,%eax,4),%eax
  1062e2:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1062e4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1062e8:	eb d6                	jmp    1062c0 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1062ea:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1062ee:	eb d0                	jmp    1062c0 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1062f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1062f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1062fa:	89 d0                	mov    %edx,%eax
  1062fc:	c1 e0 02             	shl    $0x2,%eax
  1062ff:	01 d0                	add    %edx,%eax
  106301:	01 c0                	add    %eax,%eax
  106303:	01 d8                	add    %ebx,%eax
  106305:	83 e8 30             	sub    $0x30,%eax
  106308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10630b:	8b 45 10             	mov    0x10(%ebp),%eax
  10630e:	0f b6 00             	movzbl (%eax),%eax
  106311:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  106314:	83 fb 2f             	cmp    $0x2f,%ebx
  106317:	7e 0b                	jle    106324 <vprintfmt+0xb8>
  106319:	83 fb 39             	cmp    $0x39,%ebx
  10631c:	7f 06                	jg     106324 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10631e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  106322:	eb d3                	jmp    1062f7 <vprintfmt+0x8b>
            goto process_precision;
  106324:	eb 33                	jmp    106359 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  106326:	8b 45 14             	mov    0x14(%ebp),%eax
  106329:	8d 50 04             	lea    0x4(%eax),%edx
  10632c:	89 55 14             	mov    %edx,0x14(%ebp)
  10632f:	8b 00                	mov    (%eax),%eax
  106331:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  106334:	eb 23                	jmp    106359 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  106336:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10633a:	79 0c                	jns    106348 <vprintfmt+0xdc>
                width = 0;
  10633c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  106343:	e9 78 ff ff ff       	jmp    1062c0 <vprintfmt+0x54>
  106348:	e9 73 ff ff ff       	jmp    1062c0 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  10634d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  106354:	e9 67 ff ff ff       	jmp    1062c0 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  106359:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10635d:	79 12                	jns    106371 <vprintfmt+0x105>
                width = precision, precision = -1;
  10635f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106362:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106365:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10636c:	e9 4f ff ff ff       	jmp    1062c0 <vprintfmt+0x54>
  106371:	e9 4a ff ff ff       	jmp    1062c0 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  106376:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  10637a:	e9 41 ff ff ff       	jmp    1062c0 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  10637f:	8b 45 14             	mov    0x14(%ebp),%eax
  106382:	8d 50 04             	lea    0x4(%eax),%edx
  106385:	89 55 14             	mov    %edx,0x14(%ebp)
  106388:	8b 00                	mov    (%eax),%eax
  10638a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10638d:	89 54 24 04          	mov    %edx,0x4(%esp)
  106391:	89 04 24             	mov    %eax,(%esp)
  106394:	8b 45 08             	mov    0x8(%ebp),%eax
  106397:	ff d0                	call   *%eax
            break;
  106399:	e9 ac 02 00 00       	jmp    10664a <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  10639e:	8b 45 14             	mov    0x14(%ebp),%eax
  1063a1:	8d 50 04             	lea    0x4(%eax),%edx
  1063a4:	89 55 14             	mov    %edx,0x14(%ebp)
  1063a7:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1063a9:	85 db                	test   %ebx,%ebx
  1063ab:	79 02                	jns    1063af <vprintfmt+0x143>
                err = -err;
  1063ad:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1063af:	83 fb 06             	cmp    $0x6,%ebx
  1063b2:	7f 0b                	jg     1063bf <vprintfmt+0x153>
  1063b4:	8b 34 9d 0c 80 10 00 	mov    0x10800c(,%ebx,4),%esi
  1063bb:	85 f6                	test   %esi,%esi
  1063bd:	75 23                	jne    1063e2 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  1063bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1063c3:	c7 44 24 08 39 80 10 	movl   $0x108039,0x8(%esp)
  1063ca:	00 
  1063cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1063d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1063d5:	89 04 24             	mov    %eax,(%esp)
  1063d8:	e8 61 fe ff ff       	call   10623e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1063dd:	e9 68 02 00 00       	jmp    10664a <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  1063e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1063e6:	c7 44 24 08 42 80 10 	movl   $0x108042,0x8(%esp)
  1063ed:	00 
  1063ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1063f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1063f8:	89 04 24             	mov    %eax,(%esp)
  1063fb:	e8 3e fe ff ff       	call   10623e <printfmt>
            }
            break;
  106400:	e9 45 02 00 00       	jmp    10664a <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  106405:	8b 45 14             	mov    0x14(%ebp),%eax
  106408:	8d 50 04             	lea    0x4(%eax),%edx
  10640b:	89 55 14             	mov    %edx,0x14(%ebp)
  10640e:	8b 30                	mov    (%eax),%esi
  106410:	85 f6                	test   %esi,%esi
  106412:	75 05                	jne    106419 <vprintfmt+0x1ad>
                p = "(null)";
  106414:	be 45 80 10 00       	mov    $0x108045,%esi
            }
            if (width > 0 && padc != '-') {
  106419:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10641d:	7e 3e                	jle    10645d <vprintfmt+0x1f1>
  10641f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  106423:	74 38                	je     10645d <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  106425:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  106428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10642b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10642f:	89 34 24             	mov    %esi,(%esp)
  106432:	e8 15 03 00 00       	call   10674c <strnlen>
  106437:	29 c3                	sub    %eax,%ebx
  106439:	89 d8                	mov    %ebx,%eax
  10643b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10643e:	eb 17                	jmp    106457 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  106440:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  106444:	8b 55 0c             	mov    0xc(%ebp),%edx
  106447:	89 54 24 04          	mov    %edx,0x4(%esp)
  10644b:	89 04 24             	mov    %eax,(%esp)
  10644e:	8b 45 08             	mov    0x8(%ebp),%eax
  106451:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  106453:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  106457:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10645b:	7f e3                	jg     106440 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10645d:	eb 38                	jmp    106497 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  10645f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106463:	74 1f                	je     106484 <vprintfmt+0x218>
  106465:	83 fb 1f             	cmp    $0x1f,%ebx
  106468:	7e 05                	jle    10646f <vprintfmt+0x203>
  10646a:	83 fb 7e             	cmp    $0x7e,%ebx
  10646d:	7e 15                	jle    106484 <vprintfmt+0x218>
                    putch('?', putdat);
  10646f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106472:	89 44 24 04          	mov    %eax,0x4(%esp)
  106476:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  10647d:	8b 45 08             	mov    0x8(%ebp),%eax
  106480:	ff d0                	call   *%eax
  106482:	eb 0f                	jmp    106493 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  106484:	8b 45 0c             	mov    0xc(%ebp),%eax
  106487:	89 44 24 04          	mov    %eax,0x4(%esp)
  10648b:	89 1c 24             	mov    %ebx,(%esp)
  10648e:	8b 45 08             	mov    0x8(%ebp),%eax
  106491:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106493:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  106497:	89 f0                	mov    %esi,%eax
  106499:	8d 70 01             	lea    0x1(%eax),%esi
  10649c:	0f b6 00             	movzbl (%eax),%eax
  10649f:	0f be d8             	movsbl %al,%ebx
  1064a2:	85 db                	test   %ebx,%ebx
  1064a4:	74 10                	je     1064b6 <vprintfmt+0x24a>
  1064a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1064aa:	78 b3                	js     10645f <vprintfmt+0x1f3>
  1064ac:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  1064b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1064b4:	79 a9                	jns    10645f <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1064b6:	eb 17                	jmp    1064cf <vprintfmt+0x263>
                putch(' ', putdat);
  1064b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1064bf:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1064c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1064c9:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1064cb:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1064cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1064d3:	7f e3                	jg     1064b8 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  1064d5:	e9 70 01 00 00       	jmp    10664a <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1064da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1064dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1064e1:	8d 45 14             	lea    0x14(%ebp),%eax
  1064e4:	89 04 24             	mov    %eax,(%esp)
  1064e7:	e8 0b fd ff ff       	call   1061f7 <getint>
  1064ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1064ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1064f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1064f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1064f8:	85 d2                	test   %edx,%edx
  1064fa:	79 26                	jns    106522 <vprintfmt+0x2b6>
                putch('-', putdat);
  1064fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  106503:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  10650a:	8b 45 08             	mov    0x8(%ebp),%eax
  10650d:	ff d0                	call   *%eax
                num = -(long long)num;
  10650f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106512:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106515:	f7 d8                	neg    %eax
  106517:	83 d2 00             	adc    $0x0,%edx
  10651a:	f7 da                	neg    %edx
  10651c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10651f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106522:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106529:	e9 a8 00 00 00       	jmp    1065d6 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  10652e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106531:	89 44 24 04          	mov    %eax,0x4(%esp)
  106535:	8d 45 14             	lea    0x14(%ebp),%eax
  106538:	89 04 24             	mov    %eax,(%esp)
  10653b:	e8 68 fc ff ff       	call   1061a8 <getuint>
  106540:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106543:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  106546:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10654d:	e9 84 00 00 00       	jmp    1065d6 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106555:	89 44 24 04          	mov    %eax,0x4(%esp)
  106559:	8d 45 14             	lea    0x14(%ebp),%eax
  10655c:	89 04 24             	mov    %eax,(%esp)
  10655f:	e8 44 fc ff ff       	call   1061a8 <getuint>
  106564:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106567:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  10656a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106571:	eb 63                	jmp    1065d6 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  106573:	8b 45 0c             	mov    0xc(%ebp),%eax
  106576:	89 44 24 04          	mov    %eax,0x4(%esp)
  10657a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106581:	8b 45 08             	mov    0x8(%ebp),%eax
  106584:	ff d0                	call   *%eax
            putch('x', putdat);
  106586:	8b 45 0c             	mov    0xc(%ebp),%eax
  106589:	89 44 24 04          	mov    %eax,0x4(%esp)
  10658d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  106594:	8b 45 08             	mov    0x8(%ebp),%eax
  106597:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106599:	8b 45 14             	mov    0x14(%ebp),%eax
  10659c:	8d 50 04             	lea    0x4(%eax),%edx
  10659f:	89 55 14             	mov    %edx,0x14(%ebp)
  1065a2:	8b 00                	mov    (%eax),%eax
  1065a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1065a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1065ae:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1065b5:	eb 1f                	jmp    1065d6 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1065b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1065ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  1065be:	8d 45 14             	lea    0x14(%ebp),%eax
  1065c1:	89 04 24             	mov    %eax,(%esp)
  1065c4:	e8 df fb ff ff       	call   1061a8 <getuint>
  1065c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1065cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1065cf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1065d6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1065da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1065dd:	89 54 24 18          	mov    %edx,0x18(%esp)
  1065e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1065e4:	89 54 24 14          	mov    %edx,0x14(%esp)
  1065e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1065ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1065f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1065f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1065fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1065fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  106601:	8b 45 08             	mov    0x8(%ebp),%eax
  106604:	89 04 24             	mov    %eax,(%esp)
  106607:	e8 97 fa ff ff       	call   1060a3 <printnum>
            break;
  10660c:	eb 3c                	jmp    10664a <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10660e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106611:	89 44 24 04          	mov    %eax,0x4(%esp)
  106615:	89 1c 24             	mov    %ebx,(%esp)
  106618:	8b 45 08             	mov    0x8(%ebp),%eax
  10661b:	ff d0                	call   *%eax
            break;
  10661d:	eb 2b                	jmp    10664a <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10661f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106622:	89 44 24 04          	mov    %eax,0x4(%esp)
  106626:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  10662d:	8b 45 08             	mov    0x8(%ebp),%eax
  106630:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106632:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  106636:	eb 04                	jmp    10663c <vprintfmt+0x3d0>
  106638:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10663c:	8b 45 10             	mov    0x10(%ebp),%eax
  10663f:	83 e8 01             	sub    $0x1,%eax
  106642:	0f b6 00             	movzbl (%eax),%eax
  106645:	3c 25                	cmp    $0x25,%al
  106647:	75 ef                	jne    106638 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  106649:	90                   	nop
        }
    }
  10664a:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10664b:	e9 3e fc ff ff       	jmp    10628e <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  106650:	83 c4 40             	add    $0x40,%esp
  106653:	5b                   	pop    %ebx
  106654:	5e                   	pop    %esi
  106655:	5d                   	pop    %ebp
  106656:	c3                   	ret    

00106657 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106657:	55                   	push   %ebp
  106658:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  10665a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10665d:	8b 40 08             	mov    0x8(%eax),%eax
  106660:	8d 50 01             	lea    0x1(%eax),%edx
  106663:	8b 45 0c             	mov    0xc(%ebp),%eax
  106666:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106669:	8b 45 0c             	mov    0xc(%ebp),%eax
  10666c:	8b 10                	mov    (%eax),%edx
  10666e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106671:	8b 40 04             	mov    0x4(%eax),%eax
  106674:	39 c2                	cmp    %eax,%edx
  106676:	73 12                	jae    10668a <sprintputch+0x33>
        *b->buf ++ = ch;
  106678:	8b 45 0c             	mov    0xc(%ebp),%eax
  10667b:	8b 00                	mov    (%eax),%eax
  10667d:	8d 48 01             	lea    0x1(%eax),%ecx
  106680:	8b 55 0c             	mov    0xc(%ebp),%edx
  106683:	89 0a                	mov    %ecx,(%edx)
  106685:	8b 55 08             	mov    0x8(%ebp),%edx
  106688:	88 10                	mov    %dl,(%eax)
    }
}
  10668a:	5d                   	pop    %ebp
  10668b:	c3                   	ret    

0010668c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  10668c:	55                   	push   %ebp
  10668d:	89 e5                	mov    %esp,%ebp
  10668f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106692:	8d 45 14             	lea    0x14(%ebp),%eax
  106695:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10669b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10669f:	8b 45 10             	mov    0x10(%ebp),%eax
  1066a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1066a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1066ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1066b0:	89 04 24             	mov    %eax,(%esp)
  1066b3:	e8 08 00 00 00       	call   1066c0 <vsnprintf>
  1066b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1066bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1066be:	c9                   	leave  
  1066bf:	c3                   	ret    

001066c0 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1066c0:	55                   	push   %ebp
  1066c1:	89 e5                	mov    %esp,%ebp
  1066c3:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1066c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1066c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1066cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066cf:	8d 50 ff             	lea    -0x1(%eax),%edx
  1066d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1066d5:	01 d0                	add    %edx,%eax
  1066d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1066da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1066e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1066e5:	74 0a                	je     1066f1 <vsnprintf+0x31>
  1066e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1066ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1066ed:	39 c2                	cmp    %eax,%edx
  1066ef:	76 07                	jbe    1066f8 <vsnprintf+0x38>
        return -E_INVAL;
  1066f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1066f6:	eb 2a                	jmp    106722 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1066f8:	8b 45 14             	mov    0x14(%ebp),%eax
  1066fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1066ff:	8b 45 10             	mov    0x10(%ebp),%eax
  106702:	89 44 24 08          	mov    %eax,0x8(%esp)
  106706:	8d 45 ec             	lea    -0x14(%ebp),%eax
  106709:	89 44 24 04          	mov    %eax,0x4(%esp)
  10670d:	c7 04 24 57 66 10 00 	movl   $0x106657,(%esp)
  106714:	e8 53 fb ff ff       	call   10626c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  106719:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10671c:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  10671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106722:	c9                   	leave  
  106723:	c3                   	ret    

00106724 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  106724:	55                   	push   %ebp
  106725:	89 e5                	mov    %esp,%ebp
  106727:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10672a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  106731:	eb 04                	jmp    106737 <strlen+0x13>
        cnt ++;
  106733:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  106737:	8b 45 08             	mov    0x8(%ebp),%eax
  10673a:	8d 50 01             	lea    0x1(%eax),%edx
  10673d:	89 55 08             	mov    %edx,0x8(%ebp)
  106740:	0f b6 00             	movzbl (%eax),%eax
  106743:	84 c0                	test   %al,%al
  106745:	75 ec                	jne    106733 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  106747:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10674a:	c9                   	leave  
  10674b:	c3                   	ret    

0010674c <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10674c:	55                   	push   %ebp
  10674d:	89 e5                	mov    %esp,%ebp
  10674f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106752:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106759:	eb 04                	jmp    10675f <strnlen+0x13>
        cnt ++;
  10675b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  10675f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106762:	3b 45 0c             	cmp    0xc(%ebp),%eax
  106765:	73 10                	jae    106777 <strnlen+0x2b>
  106767:	8b 45 08             	mov    0x8(%ebp),%eax
  10676a:	8d 50 01             	lea    0x1(%eax),%edx
  10676d:	89 55 08             	mov    %edx,0x8(%ebp)
  106770:	0f b6 00             	movzbl (%eax),%eax
  106773:	84 c0                	test   %al,%al
  106775:	75 e4                	jne    10675b <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  106777:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10677a:	c9                   	leave  
  10677b:	c3                   	ret    

0010677c <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10677c:	55                   	push   %ebp
  10677d:	89 e5                	mov    %esp,%ebp
  10677f:	57                   	push   %edi
  106780:	56                   	push   %esi
  106781:	83 ec 20             	sub    $0x20,%esp
  106784:	8b 45 08             	mov    0x8(%ebp),%eax
  106787:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10678a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10678d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  106790:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106796:	89 d1                	mov    %edx,%ecx
  106798:	89 c2                	mov    %eax,%edx
  10679a:	89 ce                	mov    %ecx,%esi
  10679c:	89 d7                	mov    %edx,%edi
  10679e:	ac                   	lods   %ds:(%esi),%al
  10679f:	aa                   	stos   %al,%es:(%edi)
  1067a0:	84 c0                	test   %al,%al
  1067a2:	75 fa                	jne    10679e <strcpy+0x22>
  1067a4:	89 fa                	mov    %edi,%edx
  1067a6:	89 f1                	mov    %esi,%ecx
  1067a8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1067ab:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1067ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1067b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1067b4:	83 c4 20             	add    $0x20,%esp
  1067b7:	5e                   	pop    %esi
  1067b8:	5f                   	pop    %edi
  1067b9:	5d                   	pop    %ebp
  1067ba:	c3                   	ret    

001067bb <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1067bb:	55                   	push   %ebp
  1067bc:	89 e5                	mov    %esp,%ebp
  1067be:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1067c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1067c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1067c7:	eb 21                	jmp    1067ea <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  1067c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1067cc:	0f b6 10             	movzbl (%eax),%edx
  1067cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1067d2:	88 10                	mov    %dl,(%eax)
  1067d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1067d7:	0f b6 00             	movzbl (%eax),%eax
  1067da:	84 c0                	test   %al,%al
  1067dc:	74 04                	je     1067e2 <strncpy+0x27>
            src ++;
  1067de:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  1067e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1067e6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  1067ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1067ee:	75 d9                	jne    1067c9 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  1067f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1067f3:	c9                   	leave  
  1067f4:	c3                   	ret    

001067f5 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1067f5:	55                   	push   %ebp
  1067f6:	89 e5                	mov    %esp,%ebp
  1067f8:	57                   	push   %edi
  1067f9:	56                   	push   %esi
  1067fa:	83 ec 20             	sub    $0x20,%esp
  1067fd:	8b 45 08             	mov    0x8(%ebp),%eax
  106800:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106803:	8b 45 0c             	mov    0xc(%ebp),%eax
  106806:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  106809:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10680c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10680f:	89 d1                	mov    %edx,%ecx
  106811:	89 c2                	mov    %eax,%edx
  106813:	89 ce                	mov    %ecx,%esi
  106815:	89 d7                	mov    %edx,%edi
  106817:	ac                   	lods   %ds:(%esi),%al
  106818:	ae                   	scas   %es:(%edi),%al
  106819:	75 08                	jne    106823 <strcmp+0x2e>
  10681b:	84 c0                	test   %al,%al
  10681d:	75 f8                	jne    106817 <strcmp+0x22>
  10681f:	31 c0                	xor    %eax,%eax
  106821:	eb 04                	jmp    106827 <strcmp+0x32>
  106823:	19 c0                	sbb    %eax,%eax
  106825:	0c 01                	or     $0x1,%al
  106827:	89 fa                	mov    %edi,%edx
  106829:	89 f1                	mov    %esi,%ecx
  10682b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10682e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106831:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  106834:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  106837:	83 c4 20             	add    $0x20,%esp
  10683a:	5e                   	pop    %esi
  10683b:	5f                   	pop    %edi
  10683c:	5d                   	pop    %ebp
  10683d:	c3                   	ret    

0010683e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  10683e:	55                   	push   %ebp
  10683f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106841:	eb 0c                	jmp    10684f <strncmp+0x11>
        n --, s1 ++, s2 ++;
  106843:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  106847:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10684b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10684f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106853:	74 1a                	je     10686f <strncmp+0x31>
  106855:	8b 45 08             	mov    0x8(%ebp),%eax
  106858:	0f b6 00             	movzbl (%eax),%eax
  10685b:	84 c0                	test   %al,%al
  10685d:	74 10                	je     10686f <strncmp+0x31>
  10685f:	8b 45 08             	mov    0x8(%ebp),%eax
  106862:	0f b6 10             	movzbl (%eax),%edx
  106865:	8b 45 0c             	mov    0xc(%ebp),%eax
  106868:	0f b6 00             	movzbl (%eax),%eax
  10686b:	38 c2                	cmp    %al,%dl
  10686d:	74 d4                	je     106843 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  10686f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106873:	74 18                	je     10688d <strncmp+0x4f>
  106875:	8b 45 08             	mov    0x8(%ebp),%eax
  106878:	0f b6 00             	movzbl (%eax),%eax
  10687b:	0f b6 d0             	movzbl %al,%edx
  10687e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106881:	0f b6 00             	movzbl (%eax),%eax
  106884:	0f b6 c0             	movzbl %al,%eax
  106887:	29 c2                	sub    %eax,%edx
  106889:	89 d0                	mov    %edx,%eax
  10688b:	eb 05                	jmp    106892 <strncmp+0x54>
  10688d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106892:	5d                   	pop    %ebp
  106893:	c3                   	ret    

00106894 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  106894:	55                   	push   %ebp
  106895:	89 e5                	mov    %esp,%ebp
  106897:	83 ec 04             	sub    $0x4,%esp
  10689a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10689d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1068a0:	eb 14                	jmp    1068b6 <strchr+0x22>
        if (*s == c) {
  1068a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1068a5:	0f b6 00             	movzbl (%eax),%eax
  1068a8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1068ab:	75 05                	jne    1068b2 <strchr+0x1e>
            return (char *)s;
  1068ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1068b0:	eb 13                	jmp    1068c5 <strchr+0x31>
        }
        s ++;
  1068b2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  1068b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1068b9:	0f b6 00             	movzbl (%eax),%eax
  1068bc:	84 c0                	test   %al,%al
  1068be:	75 e2                	jne    1068a2 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  1068c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1068c5:	c9                   	leave  
  1068c6:	c3                   	ret    

001068c7 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1068c7:	55                   	push   %ebp
  1068c8:	89 e5                	mov    %esp,%ebp
  1068ca:	83 ec 04             	sub    $0x4,%esp
  1068cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068d0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1068d3:	eb 11                	jmp    1068e6 <strfind+0x1f>
        if (*s == c) {
  1068d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1068d8:	0f b6 00             	movzbl (%eax),%eax
  1068db:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1068de:	75 02                	jne    1068e2 <strfind+0x1b>
            break;
  1068e0:	eb 0e                	jmp    1068f0 <strfind+0x29>
        }
        s ++;
  1068e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  1068e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1068e9:	0f b6 00             	movzbl (%eax),%eax
  1068ec:	84 c0                	test   %al,%al
  1068ee:	75 e5                	jne    1068d5 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  1068f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1068f3:	c9                   	leave  
  1068f4:	c3                   	ret    

001068f5 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1068f5:	55                   	push   %ebp
  1068f6:	89 e5                	mov    %esp,%ebp
  1068f8:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1068fb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  106902:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  106909:	eb 04                	jmp    10690f <strtol+0x1a>
        s ++;
  10690b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10690f:	8b 45 08             	mov    0x8(%ebp),%eax
  106912:	0f b6 00             	movzbl (%eax),%eax
  106915:	3c 20                	cmp    $0x20,%al
  106917:	74 f2                	je     10690b <strtol+0x16>
  106919:	8b 45 08             	mov    0x8(%ebp),%eax
  10691c:	0f b6 00             	movzbl (%eax),%eax
  10691f:	3c 09                	cmp    $0x9,%al
  106921:	74 e8                	je     10690b <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  106923:	8b 45 08             	mov    0x8(%ebp),%eax
  106926:	0f b6 00             	movzbl (%eax),%eax
  106929:	3c 2b                	cmp    $0x2b,%al
  10692b:	75 06                	jne    106933 <strtol+0x3e>
        s ++;
  10692d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  106931:	eb 15                	jmp    106948 <strtol+0x53>
    }
    else if (*s == '-') {
  106933:	8b 45 08             	mov    0x8(%ebp),%eax
  106936:	0f b6 00             	movzbl (%eax),%eax
  106939:	3c 2d                	cmp    $0x2d,%al
  10693b:	75 0b                	jne    106948 <strtol+0x53>
        s ++, neg = 1;
  10693d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  106941:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  106948:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10694c:	74 06                	je     106954 <strtol+0x5f>
  10694e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  106952:	75 24                	jne    106978 <strtol+0x83>
  106954:	8b 45 08             	mov    0x8(%ebp),%eax
  106957:	0f b6 00             	movzbl (%eax),%eax
  10695a:	3c 30                	cmp    $0x30,%al
  10695c:	75 1a                	jne    106978 <strtol+0x83>
  10695e:	8b 45 08             	mov    0x8(%ebp),%eax
  106961:	83 c0 01             	add    $0x1,%eax
  106964:	0f b6 00             	movzbl (%eax),%eax
  106967:	3c 78                	cmp    $0x78,%al
  106969:	75 0d                	jne    106978 <strtol+0x83>
        s += 2, base = 16;
  10696b:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  10696f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  106976:	eb 2a                	jmp    1069a2 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  106978:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10697c:	75 17                	jne    106995 <strtol+0xa0>
  10697e:	8b 45 08             	mov    0x8(%ebp),%eax
  106981:	0f b6 00             	movzbl (%eax),%eax
  106984:	3c 30                	cmp    $0x30,%al
  106986:	75 0d                	jne    106995 <strtol+0xa0>
        s ++, base = 8;
  106988:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10698c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  106993:	eb 0d                	jmp    1069a2 <strtol+0xad>
    }
    else if (base == 0) {
  106995:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106999:	75 07                	jne    1069a2 <strtol+0xad>
        base = 10;
  10699b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1069a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1069a5:	0f b6 00             	movzbl (%eax),%eax
  1069a8:	3c 2f                	cmp    $0x2f,%al
  1069aa:	7e 1b                	jle    1069c7 <strtol+0xd2>
  1069ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1069af:	0f b6 00             	movzbl (%eax),%eax
  1069b2:	3c 39                	cmp    $0x39,%al
  1069b4:	7f 11                	jg     1069c7 <strtol+0xd2>
            dig = *s - '0';
  1069b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1069b9:	0f b6 00             	movzbl (%eax),%eax
  1069bc:	0f be c0             	movsbl %al,%eax
  1069bf:	83 e8 30             	sub    $0x30,%eax
  1069c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1069c5:	eb 48                	jmp    106a0f <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1069c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1069ca:	0f b6 00             	movzbl (%eax),%eax
  1069cd:	3c 60                	cmp    $0x60,%al
  1069cf:	7e 1b                	jle    1069ec <strtol+0xf7>
  1069d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1069d4:	0f b6 00             	movzbl (%eax),%eax
  1069d7:	3c 7a                	cmp    $0x7a,%al
  1069d9:	7f 11                	jg     1069ec <strtol+0xf7>
            dig = *s - 'a' + 10;
  1069db:	8b 45 08             	mov    0x8(%ebp),%eax
  1069de:	0f b6 00             	movzbl (%eax),%eax
  1069e1:	0f be c0             	movsbl %al,%eax
  1069e4:	83 e8 57             	sub    $0x57,%eax
  1069e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1069ea:	eb 23                	jmp    106a0f <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1069ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1069ef:	0f b6 00             	movzbl (%eax),%eax
  1069f2:	3c 40                	cmp    $0x40,%al
  1069f4:	7e 3d                	jle    106a33 <strtol+0x13e>
  1069f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1069f9:	0f b6 00             	movzbl (%eax),%eax
  1069fc:	3c 5a                	cmp    $0x5a,%al
  1069fe:	7f 33                	jg     106a33 <strtol+0x13e>
            dig = *s - 'A' + 10;
  106a00:	8b 45 08             	mov    0x8(%ebp),%eax
  106a03:	0f b6 00             	movzbl (%eax),%eax
  106a06:	0f be c0             	movsbl %al,%eax
  106a09:	83 e8 37             	sub    $0x37,%eax
  106a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  106a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106a12:	3b 45 10             	cmp    0x10(%ebp),%eax
  106a15:	7c 02                	jl     106a19 <strtol+0x124>
            break;
  106a17:	eb 1a                	jmp    106a33 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  106a19:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  106a1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106a20:	0f af 45 10          	imul   0x10(%ebp),%eax
  106a24:	89 c2                	mov    %eax,%edx
  106a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106a29:	01 d0                	add    %edx,%eax
  106a2b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  106a2e:	e9 6f ff ff ff       	jmp    1069a2 <strtol+0xad>

    if (endptr) {
  106a33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106a37:	74 08                	je     106a41 <strtol+0x14c>
        *endptr = (char *) s;
  106a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  106a3f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  106a41:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  106a45:	74 07                	je     106a4e <strtol+0x159>
  106a47:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106a4a:	f7 d8                	neg    %eax
  106a4c:	eb 03                	jmp    106a51 <strtol+0x15c>
  106a4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  106a51:	c9                   	leave  
  106a52:	c3                   	ret    

00106a53 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  106a53:	55                   	push   %ebp
  106a54:	89 e5                	mov    %esp,%ebp
  106a56:	57                   	push   %edi
  106a57:	83 ec 24             	sub    $0x24,%esp
  106a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a5d:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106a60:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  106a64:	8b 55 08             	mov    0x8(%ebp),%edx
  106a67:	89 55 f8             	mov    %edx,-0x8(%ebp)
  106a6a:	88 45 f7             	mov    %al,-0x9(%ebp)
  106a6d:	8b 45 10             	mov    0x10(%ebp),%eax
  106a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  106a73:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  106a76:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  106a7a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  106a7d:	89 d7                	mov    %edx,%edi
  106a7f:	f3 aa                	rep stos %al,%es:(%edi)
  106a81:	89 fa                	mov    %edi,%edx
  106a83:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  106a86:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  106a89:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  106a8c:	83 c4 24             	add    $0x24,%esp
  106a8f:	5f                   	pop    %edi
  106a90:	5d                   	pop    %ebp
  106a91:	c3                   	ret    

00106a92 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  106a92:	55                   	push   %ebp
  106a93:	89 e5                	mov    %esp,%ebp
  106a95:	57                   	push   %edi
  106a96:	56                   	push   %esi
  106a97:	53                   	push   %ebx
  106a98:	83 ec 30             	sub    $0x30,%esp
  106a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  106a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  106aa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106aa7:	8b 45 10             	mov    0x10(%ebp),%eax
  106aaa:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  106aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106ab0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  106ab3:	73 42                	jae    106af7 <memmove+0x65>
  106ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106ab8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106abb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106abe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106ac4:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106ac7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106aca:	c1 e8 02             	shr    $0x2,%eax
  106acd:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  106acf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106ad5:	89 d7                	mov    %edx,%edi
  106ad7:	89 c6                	mov    %eax,%esi
  106ad9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106adb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  106ade:	83 e1 03             	and    $0x3,%ecx
  106ae1:	74 02                	je     106ae5 <memmove+0x53>
  106ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106ae5:	89 f0                	mov    %esi,%eax
  106ae7:	89 fa                	mov    %edi,%edx
  106ae9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  106aec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  106aef:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  106af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106af5:	eb 36                	jmp    106b2d <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106af7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106afa:	8d 50 ff             	lea    -0x1(%eax),%edx
  106afd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106b00:	01 c2                	add    %eax,%edx
  106b02:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106b05:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b0b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  106b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106b11:	89 c1                	mov    %eax,%ecx
  106b13:	89 d8                	mov    %ebx,%eax
  106b15:	89 d6                	mov    %edx,%esi
  106b17:	89 c7                	mov    %eax,%edi
  106b19:	fd                   	std    
  106b1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106b1c:	fc                   	cld    
  106b1d:	89 f8                	mov    %edi,%eax
  106b1f:	89 f2                	mov    %esi,%edx
  106b21:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106b24:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106b27:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  106b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106b2d:	83 c4 30             	add    $0x30,%esp
  106b30:	5b                   	pop    %ebx
  106b31:	5e                   	pop    %esi
  106b32:	5f                   	pop    %edi
  106b33:	5d                   	pop    %ebp
  106b34:	c3                   	ret    

00106b35 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106b35:	55                   	push   %ebp
  106b36:	89 e5                	mov    %esp,%ebp
  106b38:	57                   	push   %edi
  106b39:	56                   	push   %esi
  106b3a:	83 ec 20             	sub    $0x20,%esp
  106b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  106b40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b49:	8b 45 10             	mov    0x10(%ebp),%eax
  106b4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106b4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106b52:	c1 e8 02             	shr    $0x2,%eax
  106b55:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  106b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b5d:	89 d7                	mov    %edx,%edi
  106b5f:	89 c6                	mov    %eax,%esi
  106b61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106b63:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  106b66:	83 e1 03             	and    $0x3,%ecx
  106b69:	74 02                	je     106b6d <memcpy+0x38>
  106b6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106b6d:	89 f0                	mov    %esi,%eax
  106b6f:	89 fa                	mov    %edi,%edx
  106b71:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106b74:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106b77:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  106b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106b7d:	83 c4 20             	add    $0x20,%esp
  106b80:	5e                   	pop    %esi
  106b81:	5f                   	pop    %edi
  106b82:	5d                   	pop    %ebp
  106b83:	c3                   	ret    

00106b84 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  106b84:	55                   	push   %ebp
  106b85:	89 e5                	mov    %esp,%ebp
  106b87:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  106b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  106b8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  106b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b93:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  106b96:	eb 30                	jmp    106bc8 <memcmp+0x44>
        if (*s1 != *s2) {
  106b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106b9b:	0f b6 10             	movzbl (%eax),%edx
  106b9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106ba1:	0f b6 00             	movzbl (%eax),%eax
  106ba4:	38 c2                	cmp    %al,%dl
  106ba6:	74 18                	je     106bc0 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  106ba8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106bab:	0f b6 00             	movzbl (%eax),%eax
  106bae:	0f b6 d0             	movzbl %al,%edx
  106bb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106bb4:	0f b6 00             	movzbl (%eax),%eax
  106bb7:	0f b6 c0             	movzbl %al,%eax
  106bba:	29 c2                	sub    %eax,%edx
  106bbc:	89 d0                	mov    %edx,%eax
  106bbe:	eb 1a                	jmp    106bda <memcmp+0x56>
        }
        s1 ++, s2 ++;
  106bc0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  106bc4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  106bc8:	8b 45 10             	mov    0x10(%ebp),%eax
  106bcb:	8d 50 ff             	lea    -0x1(%eax),%edx
  106bce:	89 55 10             	mov    %edx,0x10(%ebp)
  106bd1:	85 c0                	test   %eax,%eax
  106bd3:	75 c3                	jne    106b98 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  106bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106bda:	c9                   	leave  
  106bdb:	c3                   	ret    
