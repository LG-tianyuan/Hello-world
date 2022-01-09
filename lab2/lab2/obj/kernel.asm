
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
c0100020:	a3 00 a0 11 c0       	mov    %eax,0xc011a000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 90 11 c0       	mov    $0xc0119000,%esp
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
c010003c:	ba a8 cf 11 c0       	mov    $0xc011cfa8,%edx
c0100041:	b8 00 c0 11 c0       	mov    $0xc011c000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 c0 11 c0 	movl   $0xc011c000,(%esp)
c010005d:	e8 f1 69 00 00       	call   c0106a53 <memset>

    cons_init();                // init the console
c0100062:	e8 97 15 00 00       	call   c01015fe <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 6b 10 c0 	movl   $0xc0106be0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 6b 10 c0 	movl   $0xc0106bfc,(%esp)
c010007c:	e8 d2 02 00 00       	call   c0100353 <cprintf>

    print_kerninfo();
c0100081:	e8 01 08 00 00       	call   c0100887 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 2e 4f 00 00       	call   c0104fbe <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 d2 16 00 00       	call   c0101767 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 4a 18 00 00       	call   c01018e4 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 15 0d 00 00       	call   c0100db4 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 31 16 00 00       	call   c01016d5 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 0d 0c 00 00       	call   c0100cd5 <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 01 6c 10 c0 	movl   $0xc0106c01,(%esp)
c0100168:	e8 e6 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 0f 6c 10 c0 	movl   $0xc0106c0f,(%esp)
c0100188:	e8 c6 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 1d 6c 10 c0 	movl   $0xc0106c1d,(%esp)
c01001a8:	e8 a6 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 2b 6c 10 c0 	movl   $0xc0106c2b,(%esp)
c01001c8:	e8 86 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 39 6c 10 c0 	movl   $0xc0106c39,(%esp)
c01001e8:	e8 66 01 00 00       	call   c0100353 <cprintf>
    round ++;
c01001ed:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 c0 11 c0       	mov    %eax,0xc011c000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
c01001ff:	83 ec 08             	sub    $0x8,%esp
c0100202:	cd 78                	int    $0x78
c0100204:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
c0100206:	5d                   	pop    %ebp
c0100207:	c3                   	ret    

c0100208 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100208:	55                   	push   %ebp
c0100209:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
c010020b:	cd 79                	int    $0x79
c010020d:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
c010020f:	5d                   	pop    %ebp
c0100210:	c3                   	ret    

c0100211 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100211:	55                   	push   %ebp
c0100212:	89 e5                	mov    %esp,%ebp
c0100214:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100217:	e8 1a ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021c:	c7 04 24 48 6c 10 c0 	movl   $0xc0106c48,(%esp)
c0100223:	e8 2b 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_user();
c0100228:	e8 cf ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c010022d:	e8 04 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100232:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0100239:	e8 15 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_kernel();
c010023e:	e8 c5 ff ff ff       	call   c0100208 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100243:	e8 ee fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c0100248:	c9                   	leave  
c0100249:	c3                   	ret    

c010024a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024a:	55                   	push   %ebp
c010024b:	89 e5                	mov    %esp,%ebp
c010024d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100250:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100254:	74 13                	je     c0100269 <readline+0x1f>
        cprintf("%s", prompt);
c0100256:	8b 45 08             	mov    0x8(%ebp),%eax
c0100259:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025d:	c7 04 24 87 6c 10 c0 	movl   $0xc0106c87,(%esp)
c0100264:	e8 ea 00 00 00       	call   c0100353 <cprintf>
    }
    int i = 0, c;
c0100269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100270:	e8 66 01 00 00       	call   c01003db <getchar>
c0100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100278:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010027c:	79 07                	jns    c0100285 <readline+0x3b>
            return NULL;
c010027e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100283:	eb 79                	jmp    c01002fe <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100285:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100289:	7e 28                	jle    c01002b3 <readline+0x69>
c010028b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100292:	7f 1f                	jg     c01002b3 <readline+0x69>
            cputchar(c);
c0100294:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100297:	89 04 24             	mov    %eax,(%esp)
c010029a:	e8 da 00 00 00       	call   c0100379 <cputchar>
            buf[i ++] = c;
c010029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a2:	8d 50 01             	lea    0x1(%eax),%edx
c01002a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002ab:	88 90 20 c0 11 c0    	mov    %dl,-0x3fee3fe0(%eax)
c01002b1:	eb 46                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b7:	75 17                	jne    c01002d0 <readline+0x86>
c01002b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002bd:	7e 11                	jle    c01002d0 <readline+0x86>
            cputchar(c);
c01002bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c2:	89 04 24             	mov    %eax,(%esp)
c01002c5:	e8 af 00 00 00       	call   c0100379 <cputchar>
            i --;
c01002ca:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002ce:	eb 29                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d4:	74 06                	je     c01002dc <readline+0x92>
c01002d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002da:	75 1d                	jne    c01002f9 <readline+0xaf>
            cputchar(c);
c01002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002df:	89 04 24             	mov    %eax,(%esp)
c01002e2:	e8 92 00 00 00       	call   c0100379 <cputchar>
            buf[i] = '\0';
c01002e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ea:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c01002ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f2:	b8 20 c0 11 c0       	mov    $0xc011c020,%eax
c01002f7:	eb 05                	jmp    c01002fe <readline+0xb4>
        }
    }
c01002f9:	e9 72 ff ff ff       	jmp    c0100270 <readline+0x26>
}
c01002fe:	c9                   	leave  
c01002ff:	c3                   	ret    

c0100300 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100300:	55                   	push   %ebp
c0100301:	89 e5                	mov    %esp,%ebp
c0100303:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100306:	8b 45 08             	mov    0x8(%ebp),%eax
c0100309:	89 04 24             	mov    %eax,(%esp)
c010030c:	e8 19 13 00 00       	call   c010162a <cons_putc>
    (*cnt) ++;
c0100311:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100314:	8b 00                	mov    (%eax),%eax
c0100316:	8d 50 01             	lea    0x1(%eax),%edx
c0100319:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031c:	89 10                	mov    %edx,(%eax)
}
c010031e:	c9                   	leave  
c010031f:	c3                   	ret    

c0100320 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100320:	55                   	push   %ebp
c0100321:	89 e5                	mov    %esp,%ebp
c0100323:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100330:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100334:	8b 45 08             	mov    0x8(%ebp),%eax
c0100337:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033b:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100342:	c7 04 24 00 03 10 c0 	movl   $0xc0100300,(%esp)
c0100349:	e8 1e 5f 00 00       	call   c010626c <vprintfmt>
    return cnt;
c010034e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100351:	c9                   	leave  
c0100352:	c3                   	ret    

c0100353 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100353:	55                   	push   %ebp
c0100354:	89 e5                	mov    %esp,%ebp
c0100356:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100359:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010035f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100362:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100366:	8b 45 08             	mov    0x8(%ebp),%eax
c0100369:	89 04 24             	mov    %eax,(%esp)
c010036c:	e8 af ff ff ff       	call   c0100320 <vcprintf>
c0100371:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100377:	c9                   	leave  
c0100378:	c3                   	ret    

c0100379 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100379:	55                   	push   %ebp
c010037a:	89 e5                	mov    %esp,%ebp
c010037c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010037f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100382:	89 04 24             	mov    %eax,(%esp)
c0100385:	e8 a0 12 00 00       	call   c010162a <cons_putc>
}
c010038a:	c9                   	leave  
c010038b:	c3                   	ret    

c010038c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010038c:	55                   	push   %ebp
c010038d:	89 e5                	mov    %esp,%ebp
c010038f:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100399:	eb 13                	jmp    c01003ae <cputs+0x22>
        cputch(c, &cnt);
c010039b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010039f:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003a6:	89 04 24             	mov    %eax,(%esp)
c01003a9:	e8 52 ff ff ff       	call   c0100300 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b1:	8d 50 01             	lea    0x1(%eax),%edx
c01003b4:	89 55 08             	mov    %edx,0x8(%ebp)
c01003b7:	0f b6 00             	movzbl (%eax),%eax
c01003ba:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003bd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c1:	75 d8                	jne    c010039b <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d1:	e8 2a ff ff ff       	call   c0100300 <cputch>
    return cnt;
c01003d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003d9:	c9                   	leave  
c01003da:	c3                   	ret    

c01003db <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003db:	55                   	push   %ebp
c01003dc:	89 e5                	mov    %esp,%ebp
c01003de:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e1:	e8 80 12 00 00       	call   c0101666 <cons_getc>
c01003e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003ed:	74 f2                	je     c01003e1 <getchar+0x6>
        /* do nothing */;
    return c;
c01003ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f2:	c9                   	leave  
c01003f3:	c3                   	ret    

c01003f4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f4:	55                   	push   %ebp
c01003f5:	89 e5                	mov    %esp,%ebp
c01003f7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003fd:	8b 00                	mov    (%eax),%eax
c01003ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100402:	8b 45 10             	mov    0x10(%ebp),%eax
c0100405:	8b 00                	mov    (%eax),%eax
c0100407:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100411:	e9 d2 00 00 00       	jmp    c01004e8 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c0100416:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100419:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010041c:	01 d0                	add    %edx,%eax
c010041e:	89 c2                	mov    %eax,%edx
c0100420:	c1 ea 1f             	shr    $0x1f,%edx
c0100423:	01 d0                	add    %edx,%eax
c0100425:	d1 f8                	sar    %eax
c0100427:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010042d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100430:	eb 04                	jmp    c0100436 <stab_binsearch+0x42>
            m --;
c0100432:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100436:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100439:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010043c:	7c 1f                	jl     c010045d <stab_binsearch+0x69>
c010043e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100441:	89 d0                	mov    %edx,%eax
c0100443:	01 c0                	add    %eax,%eax
c0100445:	01 d0                	add    %edx,%eax
c0100447:	c1 e0 02             	shl    $0x2,%eax
c010044a:	89 c2                	mov    %eax,%edx
c010044c:	8b 45 08             	mov    0x8(%ebp),%eax
c010044f:	01 d0                	add    %edx,%eax
c0100451:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100455:	0f b6 c0             	movzbl %al,%eax
c0100458:	3b 45 14             	cmp    0x14(%ebp),%eax
c010045b:	75 d5                	jne    c0100432 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010045d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100460:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100463:	7d 0b                	jge    c0100470 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100465:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100468:	83 c0 01             	add    $0x1,%eax
c010046b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010046e:	eb 78                	jmp    c01004e8 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100470:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100477:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047a:	89 d0                	mov    %edx,%eax
c010047c:	01 c0                	add    %eax,%eax
c010047e:	01 d0                	add    %edx,%eax
c0100480:	c1 e0 02             	shl    $0x2,%eax
c0100483:	89 c2                	mov    %eax,%edx
c0100485:	8b 45 08             	mov    0x8(%ebp),%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	8b 40 08             	mov    0x8(%eax),%eax
c010048d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100490:	73 13                	jae    c01004a5 <stab_binsearch+0xb1>
            *region_left = m;
c0100492:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100495:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100498:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010049d:	83 c0 01             	add    $0x1,%eax
c01004a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a3:	eb 43                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a8:	89 d0                	mov    %edx,%eax
c01004aa:	01 c0                	add    %eax,%eax
c01004ac:	01 d0                	add    %edx,%eax
c01004ae:	c1 e0 02             	shl    $0x2,%eax
c01004b1:	89 c2                	mov    %eax,%edx
c01004b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01004b6:	01 d0                	add    %edx,%eax
c01004b8:	8b 40 08             	mov    0x8(%eax),%eax
c01004bb:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004be:	76 16                	jbe    c01004d6 <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ce:	83 e8 01             	sub    $0x1,%eax
c01004d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d4:	eb 12                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004dc:	89 10                	mov    %edx,(%eax)
            l = m;
c01004de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004ee:	0f 8e 22 ff ff ff    	jle    c0100416 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004f8:	75 0f                	jne    c0100509 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fd:	8b 00                	mov    (%eax),%eax
c01004ff:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100502:	8b 45 10             	mov    0x10(%ebp),%eax
c0100505:	89 10                	mov    %edx,(%eax)
c0100507:	eb 3f                	jmp    c0100548 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0100509:	8b 45 10             	mov    0x10(%ebp),%eax
c010050c:	8b 00                	mov    (%eax),%eax
c010050e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100511:	eb 04                	jmp    c0100517 <stab_binsearch+0x123>
c0100513:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100517:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051a:	8b 00                	mov    (%eax),%eax
c010051c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051f:	7d 1f                	jge    c0100540 <stab_binsearch+0x14c>
c0100521:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100524:	89 d0                	mov    %edx,%eax
c0100526:	01 c0                	add    %eax,%eax
c0100528:	01 d0                	add    %edx,%eax
c010052a:	c1 e0 02             	shl    $0x2,%eax
c010052d:	89 c2                	mov    %eax,%edx
c010052f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100532:	01 d0                	add    %edx,%eax
c0100534:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100538:	0f b6 c0             	movzbl %al,%eax
c010053b:	3b 45 14             	cmp    0x14(%ebp),%eax
c010053e:	75 d3                	jne    c0100513 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100540:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100543:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100546:	89 10                	mov    %edx,(%eax)
    }
}
c0100548:	c9                   	leave  
c0100549:	c3                   	ret    

c010054a <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054a:	55                   	push   %ebp
c010054b:	89 e5                	mov    %esp,%ebp
c010054d:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100550:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100553:	c7 00 8c 6c 10 c0    	movl   $0xc0106c8c,(%eax)
    info->eip_line = 0;
c0100559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100566:	c7 40 08 8c 6c 10 c0 	movl   $0xc0106c8c,0x8(%eax)
    info->eip_fn_namelen = 9;
c010056d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100570:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100577:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057a:	8b 55 08             	mov    0x8(%ebp),%edx
c010057d:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100580:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100583:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010058a:	c7 45 f4 a4 81 10 c0 	movl   $0xc01081a4,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100591:	c7 45 f0 f8 3b 11 c0 	movl   $0xc0113bf8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100598:	c7 45 ec f9 3b 11 c0 	movl   $0xc0113bf9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010059f:	c7 45 e8 bb 67 11 c0 	movl   $0xc01167bb,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005ac:	76 0d                	jbe    c01005bb <debuginfo_eip+0x71>
c01005ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b1:	83 e8 01             	sub    $0x1,%eax
c01005b4:	0f b6 00             	movzbl (%eax),%eax
c01005b7:	84 c0                	test   %al,%al
c01005b9:	74 0a                	je     c01005c5 <debuginfo_eip+0x7b>
        return -1;
c01005bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c0:	e9 c0 02 00 00       	jmp    c0100885 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d2:	29 c2                	sub    %eax,%edx
c01005d4:	89 d0                	mov    %edx,%eax
c01005d6:	c1 f8 02             	sar    $0x2,%eax
c01005d9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005df:	83 e8 01             	sub    $0x1,%eax
c01005e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01005e8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005ec:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f3:	00 
c01005f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100602:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100605:	89 04 24             	mov    %eax,(%esp)
c0100608:	e8 e7 fd ff ff       	call   c01003f4 <stab_binsearch>
    if (lfile == 0)
c010060d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100610:	85 c0                	test   %eax,%eax
c0100612:	75 0a                	jne    c010061e <debuginfo_eip+0xd4>
        return -1;
c0100614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100619:	e9 67 02 00 00       	jmp    c0100885 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010061e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100621:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100624:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100627:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010062a:	8b 45 08             	mov    0x8(%ebp),%eax
c010062d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100631:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100638:	00 
c0100639:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010063c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100640:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100643:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100647:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064a:	89 04 24             	mov    %eax,(%esp)
c010064d:	e8 a2 fd ff ff       	call   c01003f4 <stab_binsearch>

    if (lfun <= rfun) {
c0100652:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100655:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100658:	39 c2                	cmp    %eax,%edx
c010065a:	7f 7c                	jg     c01006d8 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010065c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010065f:	89 c2                	mov    %eax,%edx
c0100661:	89 d0                	mov    %edx,%eax
c0100663:	01 c0                	add    %eax,%eax
c0100665:	01 d0                	add    %edx,%eax
c0100667:	c1 e0 02             	shl    $0x2,%eax
c010066a:	89 c2                	mov    %eax,%edx
c010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066f:	01 d0                	add    %edx,%eax
c0100671:	8b 10                	mov    (%eax),%edx
c0100673:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100676:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100679:	29 c1                	sub    %eax,%ecx
c010067b:	89 c8                	mov    %ecx,%eax
c010067d:	39 c2                	cmp    %eax,%edx
c010067f:	73 22                	jae    c01006a3 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100681:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100684:	89 c2                	mov    %eax,%edx
c0100686:	89 d0                	mov    %edx,%eax
c0100688:	01 c0                	add    %eax,%eax
c010068a:	01 d0                	add    %edx,%eax
c010068c:	c1 e0 02             	shl    $0x2,%eax
c010068f:	89 c2                	mov    %eax,%edx
c0100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100694:	01 d0                	add    %edx,%eax
c0100696:	8b 10                	mov    (%eax),%edx
c0100698:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010069b:	01 c2                	add    %eax,%edx
c010069d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a6:	89 c2                	mov    %eax,%edx
c01006a8:	89 d0                	mov    %edx,%eax
c01006aa:	01 c0                	add    %eax,%eax
c01006ac:	01 d0                	add    %edx,%eax
c01006ae:	c1 e0 02             	shl    $0x2,%eax
c01006b1:	89 c2                	mov    %eax,%edx
c01006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b6:	01 d0                	add    %edx,%eax
c01006b8:	8b 50 08             	mov    0x8(%eax),%edx
c01006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006be:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c4:	8b 40 10             	mov    0x10(%eax),%eax
c01006c7:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006d6:	eb 15                	jmp    c01006ed <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006db:	8b 55 08             	mov    0x8(%ebp),%edx
c01006de:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f0:	8b 40 08             	mov    0x8(%eax),%eax
c01006f3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006fa:	00 
c01006fb:	89 04 24             	mov    %eax,(%esp)
c01006fe:	e8 c4 61 00 00       	call   c01068c7 <strfind>
c0100703:	89 c2                	mov    %eax,%edx
c0100705:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100708:	8b 40 08             	mov    0x8(%eax),%eax
c010070b:	29 c2                	sub    %eax,%edx
c010070d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100710:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100713:	8b 45 08             	mov    0x8(%ebp),%eax
c0100716:	89 44 24 10          	mov    %eax,0x10(%esp)
c010071a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100721:	00 
c0100722:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100725:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100729:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010072c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100730:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100733:	89 04 24             	mov    %eax,(%esp)
c0100736:	e8 b9 fc ff ff       	call   c01003f4 <stab_binsearch>
    if (lline <= rline) {
c010073b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010073e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100741:	39 c2                	cmp    %eax,%edx
c0100743:	7f 24                	jg     c0100769 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100745:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	89 d0                	mov    %edx,%eax
c010074c:	01 c0                	add    %eax,%eax
c010074e:	01 d0                	add    %edx,%eax
c0100750:	c1 e0 02             	shl    $0x2,%eax
c0100753:	89 c2                	mov    %eax,%edx
c0100755:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100758:	01 d0                	add    %edx,%eax
c010075a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010075e:	0f b7 d0             	movzwl %ax,%edx
c0100761:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100764:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100767:	eb 13                	jmp    c010077c <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010076e:	e9 12 01 00 00       	jmp    c0100885 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100773:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100776:	83 e8 01             	sub    $0x1,%eax
c0100779:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010077c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010077f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100782:	39 c2                	cmp    %eax,%edx
c0100784:	7c 56                	jl     c01007dc <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c0100786:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100789:	89 c2                	mov    %eax,%edx
c010078b:	89 d0                	mov    %edx,%eax
c010078d:	01 c0                	add    %eax,%eax
c010078f:	01 d0                	add    %edx,%eax
c0100791:	c1 e0 02             	shl    $0x2,%eax
c0100794:	89 c2                	mov    %eax,%edx
c0100796:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100799:	01 d0                	add    %edx,%eax
c010079b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010079f:	3c 84                	cmp    $0x84,%al
c01007a1:	74 39                	je     c01007dc <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007a6:	89 c2                	mov    %eax,%edx
c01007a8:	89 d0                	mov    %edx,%eax
c01007aa:	01 c0                	add    %eax,%eax
c01007ac:	01 d0                	add    %edx,%eax
c01007ae:	c1 e0 02             	shl    $0x2,%eax
c01007b1:	89 c2                	mov    %eax,%edx
c01007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007b6:	01 d0                	add    %edx,%eax
c01007b8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007bc:	3c 64                	cmp    $0x64,%al
c01007be:	75 b3                	jne    c0100773 <debuginfo_eip+0x229>
c01007c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c3:	89 c2                	mov    %eax,%edx
c01007c5:	89 d0                	mov    %edx,%eax
c01007c7:	01 c0                	add    %eax,%eax
c01007c9:	01 d0                	add    %edx,%eax
c01007cb:	c1 e0 02             	shl    $0x2,%eax
c01007ce:	89 c2                	mov    %eax,%edx
c01007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d3:	01 d0                	add    %edx,%eax
c01007d5:	8b 40 08             	mov    0x8(%eax),%eax
c01007d8:	85 c0                	test   %eax,%eax
c01007da:	74 97                	je     c0100773 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e2:	39 c2                	cmp    %eax,%edx
c01007e4:	7c 46                	jl     c010082c <debuginfo_eip+0x2e2>
c01007e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e9:	89 c2                	mov    %eax,%edx
c01007eb:	89 d0                	mov    %edx,%eax
c01007ed:	01 c0                	add    %eax,%eax
c01007ef:	01 d0                	add    %edx,%eax
c01007f1:	c1 e0 02             	shl    $0x2,%eax
c01007f4:	89 c2                	mov    %eax,%edx
c01007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f9:	01 d0                	add    %edx,%eax
c01007fb:	8b 10                	mov    (%eax),%edx
c01007fd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100800:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100803:	29 c1                	sub    %eax,%ecx
c0100805:	89 c8                	mov    %ecx,%eax
c0100807:	39 c2                	cmp    %eax,%edx
c0100809:	73 21                	jae    c010082c <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010080b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	89 d0                	mov    %edx,%eax
c0100812:	01 c0                	add    %eax,%eax
c0100814:	01 d0                	add    %edx,%eax
c0100816:	c1 e0 02             	shl    $0x2,%eax
c0100819:	89 c2                	mov    %eax,%edx
c010081b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081e:	01 d0                	add    %edx,%eax
c0100820:	8b 10                	mov    (%eax),%edx
c0100822:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100825:	01 c2                	add    %eax,%edx
c0100827:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082a:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c010082c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010082f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100832:	39 c2                	cmp    %eax,%edx
c0100834:	7d 4a                	jge    c0100880 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c0100836:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100839:	83 c0 01             	add    $0x1,%eax
c010083c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010083f:	eb 18                	jmp    c0100859 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100841:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100844:	8b 40 14             	mov    0x14(%eax),%eax
c0100847:	8d 50 01             	lea    0x1(%eax),%edx
c010084a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010084d:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100850:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100853:	83 c0 01             	add    $0x1,%eax
c0100856:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100859:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010085c:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c010085f:	39 c2                	cmp    %eax,%edx
c0100861:	7d 1d                	jge    c0100880 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	89 d0                	mov    %edx,%eax
c010086a:	01 c0                	add    %eax,%eax
c010086c:	01 d0                	add    %edx,%eax
c010086e:	c1 e0 02             	shl    $0x2,%eax
c0100871:	89 c2                	mov    %eax,%edx
c0100873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100876:	01 d0                	add    %edx,%eax
c0100878:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010087c:	3c a0                	cmp    $0xa0,%al
c010087e:	74 c1                	je     c0100841 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100880:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100885:	c9                   	leave  
c0100886:	c3                   	ret    

c0100887 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100887:	55                   	push   %ebp
c0100888:	89 e5                	mov    %esp,%ebp
c010088a:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010088d:	c7 04 24 96 6c 10 c0 	movl   $0xc0106c96,(%esp)
c0100894:	e8 ba fa ff ff       	call   c0100353 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100899:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a0:	c0 
c01008a1:	c7 04 24 af 6c 10 c0 	movl   $0xc0106caf,(%esp)
c01008a8:	e8 a6 fa ff ff       	call   c0100353 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008ad:	c7 44 24 04 dc 6b 10 	movl   $0xc0106bdc,0x4(%esp)
c01008b4:	c0 
c01008b5:	c7 04 24 c7 6c 10 c0 	movl   $0xc0106cc7,(%esp)
c01008bc:	e8 92 fa ff ff       	call   c0100353 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c1:	c7 44 24 04 00 c0 11 	movl   $0xc011c000,0x4(%esp)
c01008c8:	c0 
c01008c9:	c7 04 24 df 6c 10 c0 	movl   $0xc0106cdf,(%esp)
c01008d0:	e8 7e fa ff ff       	call   c0100353 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d5:	c7 44 24 04 a8 cf 11 	movl   $0xc011cfa8,0x4(%esp)
c01008dc:	c0 
c01008dd:	c7 04 24 f7 6c 10 c0 	movl   $0xc0106cf7,(%esp)
c01008e4:	e8 6a fa ff ff       	call   c0100353 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008e9:	b8 a8 cf 11 c0       	mov    $0xc011cfa8,%eax
c01008ee:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f4:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008f9:	29 c2                	sub    %eax,%edx
c01008fb:	89 d0                	mov    %edx,%eax
c01008fd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100903:	85 c0                	test   %eax,%eax
c0100905:	0f 48 c2             	cmovs  %edx,%eax
c0100908:	c1 f8 0a             	sar    $0xa,%eax
c010090b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010090f:	c7 04 24 10 6d 10 c0 	movl   $0xc0106d10,(%esp)
c0100916:	e8 38 fa ff ff       	call   c0100353 <cprintf>
}
c010091b:	c9                   	leave  
c010091c:	c3                   	ret    

c010091d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010091d:	55                   	push   %ebp
c010091e:	89 e5                	mov    %esp,%ebp
c0100920:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100926:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100929:	89 44 24 04          	mov    %eax,0x4(%esp)
c010092d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100930:	89 04 24             	mov    %eax,(%esp)
c0100933:	e8 12 fc ff ff       	call   c010054a <debuginfo_eip>
c0100938:	85 c0                	test   %eax,%eax
c010093a:	74 15                	je     c0100951 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010093c:	8b 45 08             	mov    0x8(%ebp),%eax
c010093f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100943:	c7 04 24 3a 6d 10 c0 	movl   $0xc0106d3a,(%esp)
c010094a:	e8 04 fa ff ff       	call   c0100353 <cprintf>
c010094f:	eb 6d                	jmp    c01009be <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100958:	eb 1c                	jmp    c0100976 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010095a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010095d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100960:	01 d0                	add    %edx,%eax
c0100962:	0f b6 00             	movzbl (%eax),%eax
c0100965:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010096b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010096e:	01 ca                	add    %ecx,%edx
c0100970:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100972:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100976:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100979:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010097c:	7f dc                	jg     c010095a <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c010097e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100984:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100987:	01 d0                	add    %edx,%eax
c0100989:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c010098c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010098f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100992:	89 d1                	mov    %edx,%ecx
c0100994:	29 c1                	sub    %eax,%ecx
c0100996:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100999:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010099c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009a0:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009aa:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b2:	c7 04 24 56 6d 10 c0 	movl   $0xc0106d56,(%esp)
c01009b9:	e8 95 f9 ff ff       	call   c0100353 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009be:	c9                   	leave  
c01009bf:	c3                   	ret    

c01009c0 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c0:	55                   	push   %ebp
c01009c1:	89 e5                	mov    %esp,%ebp
c01009c3:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009c6:	8b 45 04             	mov    0x4(%ebp),%eax
c01009c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009cf:	c9                   	leave  
c01009d0:	c3                   	ret    

c01009d1 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d1:	55                   	push   %ebp
c01009d2:	89 e5                	mov    %esp,%ebp
c01009d4:	53                   	push   %ebx
c01009d5:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009d8:	89 e8                	mov    %ebp,%eax
c01009da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c01009e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
c01009e3:	e8 d8 ff ff ff       	call   c01009c0 <read_eip>
c01009e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c01009eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009f2:	e9 8d 00 00 00       	jmp    c0100a84 <print_stackframe+0xb3>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c01009f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009fa:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a05:	c7 04 24 68 6d 10 c0 	movl   $0xc0106d68,(%esp)
c0100a0c:	e8 42 f9 ff ff       	call   c0100353 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
c0100a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a14:	83 c0 08             	add    $0x8,%eax
c0100a17:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("0x%08x 0x%08x 0x%08x 0x%08x",*args,*(args+1),*(args+2),*(args+3));
c0100a1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1d:	83 c0 0c             	add    $0xc,%eax
c0100a20:	8b 18                	mov    (%eax),%ebx
c0100a22:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a25:	83 c0 08             	add    $0x8,%eax
c0100a28:	8b 08                	mov    (%eax),%ecx
c0100a2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2d:	83 c0 04             	add    $0x4,%eax
c0100a30:	8b 10                	mov    (%eax),%edx
c0100a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a35:	8b 00                	mov    (%eax),%eax
c0100a37:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100a3b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a3f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a47:	c7 04 24 84 6d 10 c0 	movl   $0xc0106d84,(%esp)
c0100a4e:	e8 00 f9 ff ff       	call   c0100353 <cprintf>
		cprintf("\n");
c0100a53:	c7 04 24 a0 6d 10 c0 	movl   $0xc0106da0,(%esp)
c0100a5a:	e8 f4 f8 ff ff       	call   c0100353 <cprintf>
		print_debuginfo(eip-1);
c0100a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a62:	83 e8 01             	sub    $0x1,%eax
c0100a65:	89 04 24             	mov    %eax,(%esp)
c0100a68:	e8 b0 fe ff ff       	call   c010091d <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a70:	83 c0 04             	add    $0x4,%eax
c0100a73:	8b 00                	mov    (%eax),%eax
c0100a75:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
c0100a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a7b:	8b 00                	mov    (%eax),%eax
c0100a7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100a80:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a88:	74 0a                	je     c0100a94 <print_stackframe+0xc3>
c0100a8a:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a8e:	0f 8e 63 ff ff ff    	jle    c01009f7 <print_stackframe+0x26>
		cprintf("\n");
		print_debuginfo(eip-1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
c0100a94:	83 c4 44             	add    $0x44,%esp
c0100a97:	5b                   	pop    %ebx
c0100a98:	5d                   	pop    %ebp
c0100a99:	c3                   	ret    

c0100a9a <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a9a:	55                   	push   %ebp
c0100a9b:	89 e5                	mov    %esp,%ebp
c0100a9d:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100aa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aa7:	eb 0c                	jmp    c0100ab5 <parse+0x1b>
            *buf ++ = '\0';
c0100aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aac:	8d 50 01             	lea    0x1(%eax),%edx
c0100aaf:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ab2:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab8:	0f b6 00             	movzbl (%eax),%eax
c0100abb:	84 c0                	test   %al,%al
c0100abd:	74 1d                	je     c0100adc <parse+0x42>
c0100abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac2:	0f b6 00             	movzbl (%eax),%eax
c0100ac5:	0f be c0             	movsbl %al,%eax
c0100ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100acc:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0100ad3:	e8 bc 5d 00 00       	call   c0106894 <strchr>
c0100ad8:	85 c0                	test   %eax,%eax
c0100ada:	75 cd                	jne    c0100aa9 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100adc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100adf:	0f b6 00             	movzbl (%eax),%eax
c0100ae2:	84 c0                	test   %al,%al
c0100ae4:	75 02                	jne    c0100ae8 <parse+0x4e>
            break;
c0100ae6:	eb 67                	jmp    c0100b4f <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ae8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100aec:	75 14                	jne    c0100b02 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100aee:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100af5:	00 
c0100af6:	c7 04 24 29 6e 10 c0 	movl   $0xc0106e29,(%esp)
c0100afd:	e8 51 f8 ff ff       	call   c0100353 <cprintf>
        }
        argv[argc ++] = buf;
c0100b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b05:	8d 50 01             	lea    0x1(%eax),%edx
c0100b08:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b0b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b15:	01 c2                	add    %eax,%edx
c0100b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1a:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b1c:	eb 04                	jmp    c0100b22 <parse+0x88>
            buf ++;
c0100b1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b22:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b25:	0f b6 00             	movzbl (%eax),%eax
c0100b28:	84 c0                	test   %al,%al
c0100b2a:	74 1d                	je     c0100b49 <parse+0xaf>
c0100b2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b2f:	0f b6 00             	movzbl (%eax),%eax
c0100b32:	0f be c0             	movsbl %al,%eax
c0100b35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b39:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0100b40:	e8 4f 5d 00 00       	call   c0106894 <strchr>
c0100b45:	85 c0                	test   %eax,%eax
c0100b47:	74 d5                	je     c0100b1e <parse+0x84>
            buf ++;
        }
    }
c0100b49:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4a:	e9 66 ff ff ff       	jmp    c0100ab5 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b52:	c9                   	leave  
c0100b53:	c3                   	ret    

c0100b54 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b54:	55                   	push   %ebp
c0100b55:	89 e5                	mov    %esp,%ebp
c0100b57:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b5a:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b64:	89 04 24             	mov    %eax,(%esp)
c0100b67:	e8 2e ff ff ff       	call   c0100a9a <parse>
c0100b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b73:	75 0a                	jne    c0100b7f <runcmd+0x2b>
        return 0;
c0100b75:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b7a:	e9 85 00 00 00       	jmp    c0100c04 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b86:	eb 5c                	jmp    c0100be4 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b88:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b8e:	89 d0                	mov    %edx,%eax
c0100b90:	01 c0                	add    %eax,%eax
c0100b92:	01 d0                	add    %edx,%eax
c0100b94:	c1 e0 02             	shl    $0x2,%eax
c0100b97:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100b9c:	8b 00                	mov    (%eax),%eax
c0100b9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ba2:	89 04 24             	mov    %eax,(%esp)
c0100ba5:	e8 4b 5c 00 00       	call   c01067f5 <strcmp>
c0100baa:	85 c0                	test   %eax,%eax
c0100bac:	75 32                	jne    c0100be0 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bae:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bb1:	89 d0                	mov    %edx,%eax
c0100bb3:	01 c0                	add    %eax,%eax
c0100bb5:	01 d0                	add    %edx,%eax
c0100bb7:	c1 e0 02             	shl    $0x2,%eax
c0100bba:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100bbf:	8b 40 08             	mov    0x8(%eax),%eax
c0100bc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bc5:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bcb:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bcf:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bd2:	83 c2 04             	add    $0x4,%edx
c0100bd5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bd9:	89 0c 24             	mov    %ecx,(%esp)
c0100bdc:	ff d0                	call   *%eax
c0100bde:	eb 24                	jmp    c0100c04 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100be0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be7:	83 f8 02             	cmp    $0x2,%eax
c0100bea:	76 9c                	jbe    c0100b88 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bec:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf3:	c7 04 24 47 6e 10 c0 	movl   $0xc0106e47,(%esp)
c0100bfa:	e8 54 f7 ff ff       	call   c0100353 <cprintf>
    return 0;
c0100bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c04:	c9                   	leave  
c0100c05:	c3                   	ret    

c0100c06 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c06:	55                   	push   %ebp
c0100c07:	89 e5                	mov    %esp,%ebp
c0100c09:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c0c:	c7 04 24 60 6e 10 c0 	movl   $0xc0106e60,(%esp)
c0100c13:	e8 3b f7 ff ff       	call   c0100353 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c18:	c7 04 24 88 6e 10 c0 	movl   $0xc0106e88,(%esp)
c0100c1f:	e8 2f f7 ff ff       	call   c0100353 <cprintf>

    if (tf != NULL) {
c0100c24:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c28:	74 0b                	je     c0100c35 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2d:	89 04 24             	mov    %eax,(%esp)
c0100c30:	e8 64 0e 00 00       	call   c0101a99 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c35:	c7 04 24 ad 6e 10 c0 	movl   $0xc0106ead,(%esp)
c0100c3c:	e8 09 f6 ff ff       	call   c010024a <readline>
c0100c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c48:	74 18                	je     c0100c62 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c54:	89 04 24             	mov    %eax,(%esp)
c0100c57:	e8 f8 fe ff ff       	call   c0100b54 <runcmd>
c0100c5c:	85 c0                	test   %eax,%eax
c0100c5e:	79 02                	jns    c0100c62 <kmonitor+0x5c>
                break;
c0100c60:	eb 02                	jmp    c0100c64 <kmonitor+0x5e>
            }
        }
    }
c0100c62:	eb d1                	jmp    c0100c35 <kmonitor+0x2f>
}
c0100c64:	c9                   	leave  
c0100c65:	c3                   	ret    

c0100c66 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c66:	55                   	push   %ebp
c0100c67:	89 e5                	mov    %esp,%ebp
c0100c69:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c73:	eb 3f                	jmp    c0100cb4 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c78:	89 d0                	mov    %edx,%eax
c0100c7a:	01 c0                	add    %eax,%eax
c0100c7c:	01 d0                	add    %edx,%eax
c0100c7e:	c1 e0 02             	shl    $0x2,%eax
c0100c81:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100c86:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c8c:	89 d0                	mov    %edx,%eax
c0100c8e:	01 c0                	add    %eax,%eax
c0100c90:	01 d0                	add    %edx,%eax
c0100c92:	c1 e0 02             	shl    $0x2,%eax
c0100c95:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100c9a:	8b 00                	mov    (%eax),%eax
c0100c9c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca4:	c7 04 24 b1 6e 10 c0 	movl   $0xc0106eb1,(%esp)
c0100cab:	e8 a3 f6 ff ff       	call   c0100353 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cb0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb7:	83 f8 02             	cmp    $0x2,%eax
c0100cba:	76 b9                	jbe    c0100c75 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100cbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc1:	c9                   	leave  
c0100cc2:	c3                   	ret    

c0100cc3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cc3:	55                   	push   %ebp
c0100cc4:	89 e5                	mov    %esp,%ebp
c0100cc6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cc9:	e8 b9 fb ff ff       	call   c0100887 <print_kerninfo>
    return 0;
c0100cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd3:	c9                   	leave  
c0100cd4:	c3                   	ret    

c0100cd5 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cd5:	55                   	push   %ebp
c0100cd6:	89 e5                	mov    %esp,%ebp
c0100cd8:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cdb:	e8 f1 fc ff ff       	call   c01009d1 <print_stackframe>
    return 0;
c0100ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ce5:	c9                   	leave  
c0100ce6:	c3                   	ret    

c0100ce7 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100ce7:	55                   	push   %ebp
c0100ce8:	89 e5                	mov    %esp,%ebp
c0100cea:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ced:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
c0100cf2:	85 c0                	test   %eax,%eax
c0100cf4:	74 02                	je     c0100cf8 <__panic+0x11>
        goto panic_dead;
c0100cf6:	eb 59                	jmp    c0100d51 <__panic+0x6a>
    }
    is_panic = 1;
c0100cf8:	c7 05 20 c4 11 c0 01 	movl   $0x1,0xc011c420
c0100cff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d02:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d0b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d16:	c7 04 24 ba 6e 10 c0 	movl   $0xc0106eba,(%esp)
c0100d1d:	e8 31 f6 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d29:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d2c:	89 04 24             	mov    %eax,(%esp)
c0100d2f:	e8 ec f5 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100d34:	c7 04 24 d6 6e 10 c0 	movl   $0xc0106ed6,(%esp)
c0100d3b:	e8 13 f6 ff ff       	call   c0100353 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d40:	c7 04 24 d8 6e 10 c0 	movl   $0xc0106ed8,(%esp)
c0100d47:	e8 07 f6 ff ff       	call   c0100353 <cprintf>
    print_stackframe();
c0100d4c:	e8 80 fc ff ff       	call   c01009d1 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d51:	e8 85 09 00 00       	call   c01016db <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d5d:	e8 a4 fe ff ff       	call   c0100c06 <kmonitor>
    }
c0100d62:	eb f2                	jmp    c0100d56 <__panic+0x6f>

c0100d64 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d64:	55                   	push   %ebp
c0100d65:	89 e5                	mov    %esp,%ebp
c0100d67:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d6a:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d70:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d73:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d77:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7e:	c7 04 24 ea 6e 10 c0 	movl   $0xc0106eea,(%esp)
c0100d85:	e8 c9 f5 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d91:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d94:	89 04 24             	mov    %eax,(%esp)
c0100d97:	e8 84 f5 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100d9c:	c7 04 24 d6 6e 10 c0 	movl   $0xc0106ed6,(%esp)
c0100da3:	e8 ab f5 ff ff       	call   c0100353 <cprintf>
    va_end(ap);
}
c0100da8:	c9                   	leave  
c0100da9:	c3                   	ret    

c0100daa <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100daa:	55                   	push   %ebp
c0100dab:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100dad:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
}
c0100db2:	5d                   	pop    %ebp
c0100db3:	c3                   	ret    

c0100db4 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100db4:	55                   	push   %ebp
c0100db5:	89 e5                	mov    %esp,%ebp
c0100db7:	83 ec 28             	sub    $0x28,%esp
c0100dba:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dc0:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dc4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dc8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dcc:	ee                   	out    %al,(%dx)
c0100dcd:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dd3:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dd7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ddb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ddf:	ee                   	out    %al,(%dx)
c0100de0:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100de6:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dea:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dee:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100df2:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100df3:	c7 05 2c cf 11 c0 00 	movl   $0x0,0xc011cf2c
c0100dfa:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dfd:	c7 04 24 08 6f 10 c0 	movl   $0xc0106f08,(%esp)
c0100e04:	e8 4a f5 ff ff       	call   c0100353 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e10:	e8 24 09 00 00       	call   c0101739 <pic_enable>
}
c0100e15:	c9                   	leave  
c0100e16:	c3                   	ret    

c0100e17 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e17:	55                   	push   %ebp
c0100e18:	89 e5                	mov    %esp,%ebp
c0100e1a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e1d:	9c                   	pushf  
c0100e1e:	58                   	pop    %eax
c0100e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e25:	25 00 02 00 00       	and    $0x200,%eax
c0100e2a:	85 c0                	test   %eax,%eax
c0100e2c:	74 0c                	je     c0100e3a <__intr_save+0x23>
        intr_disable();
c0100e2e:	e8 a8 08 00 00       	call   c01016db <intr_disable>
        return 1;
c0100e33:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e38:	eb 05                	jmp    c0100e3f <__intr_save+0x28>
    }
    return 0;
c0100e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e3f:	c9                   	leave  
c0100e40:	c3                   	ret    

c0100e41 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e41:	55                   	push   %ebp
c0100e42:	89 e5                	mov    %esp,%ebp
c0100e44:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e4b:	74 05                	je     c0100e52 <__intr_restore+0x11>
        intr_enable();
c0100e4d:	e8 83 08 00 00       	call   c01016d5 <intr_enable>
    }
}
c0100e52:	c9                   	leave  
c0100e53:	c3                   	ret    

c0100e54 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e54:	55                   	push   %ebp
c0100e55:	89 e5                	mov    %esp,%ebp
c0100e57:	83 ec 10             	sub    $0x10,%esp
c0100e5a:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e60:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e64:	89 c2                	mov    %eax,%edx
c0100e66:	ec                   	in     (%dx),%al
c0100e67:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e6a:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e70:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e74:	89 c2                	mov    %eax,%edx
c0100e76:	ec                   	in     (%dx),%al
c0100e77:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e7a:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e80:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e84:	89 c2                	mov    %eax,%edx
c0100e86:	ec                   	in     (%dx),%al
c0100e87:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e8a:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e90:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e94:	89 c2                	mov    %eax,%edx
c0100e96:	ec                   	in     (%dx),%al
c0100e97:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e9a:	c9                   	leave  
c0100e9b:	c3                   	ret    

c0100e9c <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e9c:	55                   	push   %ebp
c0100e9d:	89 e5                	mov    %esp,%ebp
c0100e9f:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ea2:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ea9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eac:	0f b7 00             	movzwl (%eax),%eax
c0100eaf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb6:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ebe:	0f b7 00             	movzwl (%eax),%eax
c0100ec1:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100ec5:	74 12                	je     c0100ed9 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ec7:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ece:	66 c7 05 46 c4 11 c0 	movw   $0x3b4,0xc011c446
c0100ed5:	b4 03 
c0100ed7:	eb 13                	jmp    c0100eec <cga_init+0x50>
    } else {
        *cp = was;
c0100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ee3:	66 c7 05 46 c4 11 c0 	movw   $0x3d4,0xc011c446
c0100eea:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100eec:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100ef3:	0f b7 c0             	movzwl %ax,%eax
c0100ef6:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100efa:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100efe:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f02:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f06:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f07:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f0e:	83 c0 01             	add    $0x1,%eax
c0100f11:	0f b7 c0             	movzwl %ax,%eax
c0100f14:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f18:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f1c:	89 c2                	mov    %eax,%edx
c0100f1e:	ec                   	in     (%dx),%al
c0100f1f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f22:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f26:	0f b6 c0             	movzbl %al,%eax
c0100f29:	c1 e0 08             	shl    $0x8,%eax
c0100f2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f2f:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f36:	0f b7 c0             	movzwl %ax,%eax
c0100f39:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f3d:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f41:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f45:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f49:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f4a:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f51:	83 c0 01             	add    $0x1,%eax
c0100f54:	0f b7 c0             	movzwl %ax,%eax
c0100f57:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f5b:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f5f:	89 c2                	mov    %eax,%edx
c0100f61:	ec                   	in     (%dx),%al
c0100f62:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f65:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f69:	0f b6 c0             	movzbl %al,%eax
c0100f6c:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f72:	a3 40 c4 11 c0       	mov    %eax,0xc011c440
    crt_pos = pos;
c0100f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f7a:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
}
c0100f80:	c9                   	leave  
c0100f81:	c3                   	ret    

c0100f82 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f82:	55                   	push   %ebp
c0100f83:	89 e5                	mov    %esp,%ebp
c0100f85:	83 ec 48             	sub    $0x48,%esp
c0100f88:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f8e:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f92:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f96:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f9a:	ee                   	out    %al,(%dx)
c0100f9b:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100fa1:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100fa5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fa9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fad:	ee                   	out    %al,(%dx)
c0100fae:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100fb4:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fb8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fbc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fc0:	ee                   	out    %al,(%dx)
c0100fc1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fc7:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fcb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fcf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fd3:	ee                   	out    %al,(%dx)
c0100fd4:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fda:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fde:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fe2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fe6:	ee                   	out    %al,(%dx)
c0100fe7:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fed:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100ff1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100ff5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100ff9:	ee                   	out    %al,(%dx)
c0100ffa:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101000:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101004:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101008:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010100c:	ee                   	out    %al,(%dx)
c010100d:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101013:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101017:	89 c2                	mov    %eax,%edx
c0101019:	ec                   	in     (%dx),%al
c010101a:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c010101d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101021:	3c ff                	cmp    $0xff,%al
c0101023:	0f 95 c0             	setne  %al
c0101026:	0f b6 c0             	movzbl %al,%eax
c0101029:	a3 48 c4 11 c0       	mov    %eax,0xc011c448
c010102e:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101034:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101038:	89 c2                	mov    %eax,%edx
c010103a:	ec                   	in     (%dx),%al
c010103b:	88 45 d5             	mov    %al,-0x2b(%ebp)
c010103e:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101044:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101048:	89 c2                	mov    %eax,%edx
c010104a:	ec                   	in     (%dx),%al
c010104b:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010104e:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101053:	85 c0                	test   %eax,%eax
c0101055:	74 0c                	je     c0101063 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101057:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010105e:	e8 d6 06 00 00       	call   c0101739 <pic_enable>
    }
}
c0101063:	c9                   	leave  
c0101064:	c3                   	ret    

c0101065 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101065:	55                   	push   %ebp
c0101066:	89 e5                	mov    %esp,%ebp
c0101068:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010106b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101072:	eb 09                	jmp    c010107d <lpt_putc_sub+0x18>
        delay();
c0101074:	e8 db fd ff ff       	call   c0100e54 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101079:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010107d:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101083:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101087:	89 c2                	mov    %eax,%edx
c0101089:	ec                   	in     (%dx),%al
c010108a:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010108d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101091:	84 c0                	test   %al,%al
c0101093:	78 09                	js     c010109e <lpt_putc_sub+0x39>
c0101095:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010109c:	7e d6                	jle    c0101074 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c010109e:	8b 45 08             	mov    0x8(%ebp),%eax
c01010a1:	0f b6 c0             	movzbl %al,%eax
c01010a4:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01010aa:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010ad:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010b1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010b5:	ee                   	out    %al,(%dx)
c01010b6:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010bc:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010c0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010c4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010c8:	ee                   	out    %al,(%dx)
c01010c9:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010cf:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010d3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010d7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010db:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010dc:	c9                   	leave  
c01010dd:	c3                   	ret    

c01010de <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010de:	55                   	push   %ebp
c01010df:	89 e5                	mov    %esp,%ebp
c01010e1:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010e4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010e8:	74 0d                	je     c01010f7 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01010ed:	89 04 24             	mov    %eax,(%esp)
c01010f0:	e8 70 ff ff ff       	call   c0101065 <lpt_putc_sub>
c01010f5:	eb 24                	jmp    c010111b <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010f7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010fe:	e8 62 ff ff ff       	call   c0101065 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101103:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010110a:	e8 56 ff ff ff       	call   c0101065 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010110f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101116:	e8 4a ff ff ff       	call   c0101065 <lpt_putc_sub>
    }
}
c010111b:	c9                   	leave  
c010111c:	c3                   	ret    

c010111d <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010111d:	55                   	push   %ebp
c010111e:	89 e5                	mov    %esp,%ebp
c0101120:	53                   	push   %ebx
c0101121:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101124:	8b 45 08             	mov    0x8(%ebp),%eax
c0101127:	b0 00                	mov    $0x0,%al
c0101129:	85 c0                	test   %eax,%eax
c010112b:	75 07                	jne    c0101134 <cga_putc+0x17>
        c |= 0x0700;
c010112d:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101134:	8b 45 08             	mov    0x8(%ebp),%eax
c0101137:	0f b6 c0             	movzbl %al,%eax
c010113a:	83 f8 0a             	cmp    $0xa,%eax
c010113d:	74 4c                	je     c010118b <cga_putc+0x6e>
c010113f:	83 f8 0d             	cmp    $0xd,%eax
c0101142:	74 57                	je     c010119b <cga_putc+0x7e>
c0101144:	83 f8 08             	cmp    $0x8,%eax
c0101147:	0f 85 88 00 00 00    	jne    c01011d5 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010114d:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101154:	66 85 c0             	test   %ax,%ax
c0101157:	74 30                	je     c0101189 <cga_putc+0x6c>
            crt_pos --;
c0101159:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101160:	83 e8 01             	sub    $0x1,%eax
c0101163:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101169:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010116e:	0f b7 15 44 c4 11 c0 	movzwl 0xc011c444,%edx
c0101175:	0f b7 d2             	movzwl %dx,%edx
c0101178:	01 d2                	add    %edx,%edx
c010117a:	01 c2                	add    %eax,%edx
c010117c:	8b 45 08             	mov    0x8(%ebp),%eax
c010117f:	b0 00                	mov    $0x0,%al
c0101181:	83 c8 20             	or     $0x20,%eax
c0101184:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101187:	eb 72                	jmp    c01011fb <cga_putc+0xde>
c0101189:	eb 70                	jmp    c01011fb <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c010118b:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101192:	83 c0 50             	add    $0x50,%eax
c0101195:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010119b:	0f b7 1d 44 c4 11 c0 	movzwl 0xc011c444,%ebx
c01011a2:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c01011a9:	0f b7 c1             	movzwl %cx,%eax
c01011ac:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01011b2:	c1 e8 10             	shr    $0x10,%eax
c01011b5:	89 c2                	mov    %eax,%edx
c01011b7:	66 c1 ea 06          	shr    $0x6,%dx
c01011bb:	89 d0                	mov    %edx,%eax
c01011bd:	c1 e0 02             	shl    $0x2,%eax
c01011c0:	01 d0                	add    %edx,%eax
c01011c2:	c1 e0 04             	shl    $0x4,%eax
c01011c5:	29 c1                	sub    %eax,%ecx
c01011c7:	89 ca                	mov    %ecx,%edx
c01011c9:	89 d8                	mov    %ebx,%eax
c01011cb:	29 d0                	sub    %edx,%eax
c01011cd:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
        break;
c01011d3:	eb 26                	jmp    c01011fb <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011d5:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c01011db:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011e2:	8d 50 01             	lea    0x1(%eax),%edx
c01011e5:	66 89 15 44 c4 11 c0 	mov    %dx,0xc011c444
c01011ec:	0f b7 c0             	movzwl %ax,%eax
c01011ef:	01 c0                	add    %eax,%eax
c01011f1:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f7:	66 89 02             	mov    %ax,(%edx)
        break;
c01011fa:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011fb:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101202:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101206:	76 5b                	jbe    c0101263 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101208:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010120d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101213:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c0101218:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010121f:	00 
c0101220:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101224:	89 04 24             	mov    %eax,(%esp)
c0101227:	e8 66 58 00 00       	call   c0106a92 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010122c:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101233:	eb 15                	jmp    c010124a <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101235:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010123a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010123d:	01 d2                	add    %edx,%edx
c010123f:	01 d0                	add    %edx,%eax
c0101241:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101246:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010124a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101251:	7e e2                	jle    c0101235 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101253:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010125a:	83 e8 50             	sub    $0x50,%eax
c010125d:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101263:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c010126a:	0f b7 c0             	movzwl %ax,%eax
c010126d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101271:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101275:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101279:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010127d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010127e:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101285:	66 c1 e8 08          	shr    $0x8,%ax
c0101289:	0f b6 c0             	movzbl %al,%eax
c010128c:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c0101293:	83 c2 01             	add    $0x1,%edx
c0101296:	0f b7 d2             	movzwl %dx,%edx
c0101299:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c010129d:	88 45 ed             	mov    %al,-0x13(%ebp)
c01012a0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012a4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012a8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012a9:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c01012b0:	0f b7 c0             	movzwl %ax,%eax
c01012b3:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012b7:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012bb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012bf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012c3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012c4:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012cb:	0f b6 c0             	movzbl %al,%eax
c01012ce:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c01012d5:	83 c2 01             	add    $0x1,%edx
c01012d8:	0f b7 d2             	movzwl %dx,%edx
c01012db:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012df:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012e2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012e6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ea:	ee                   	out    %al,(%dx)
}
c01012eb:	83 c4 34             	add    $0x34,%esp
c01012ee:	5b                   	pop    %ebx
c01012ef:	5d                   	pop    %ebp
c01012f0:	c3                   	ret    

c01012f1 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012f1:	55                   	push   %ebp
c01012f2:	89 e5                	mov    %esp,%ebp
c01012f4:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012fe:	eb 09                	jmp    c0101309 <serial_putc_sub+0x18>
        delay();
c0101300:	e8 4f fb ff ff       	call   c0100e54 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101305:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101309:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010130f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101313:	89 c2                	mov    %eax,%edx
c0101315:	ec                   	in     (%dx),%al
c0101316:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101319:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010131d:	0f b6 c0             	movzbl %al,%eax
c0101320:	83 e0 20             	and    $0x20,%eax
c0101323:	85 c0                	test   %eax,%eax
c0101325:	75 09                	jne    c0101330 <serial_putc_sub+0x3f>
c0101327:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010132e:	7e d0                	jle    c0101300 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101330:	8b 45 08             	mov    0x8(%ebp),%eax
c0101333:	0f b6 c0             	movzbl %al,%eax
c0101336:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010133c:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010133f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101343:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101347:	ee                   	out    %al,(%dx)
}
c0101348:	c9                   	leave  
c0101349:	c3                   	ret    

c010134a <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010134a:	55                   	push   %ebp
c010134b:	89 e5                	mov    %esp,%ebp
c010134d:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101350:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101354:	74 0d                	je     c0101363 <serial_putc+0x19>
        serial_putc_sub(c);
c0101356:	8b 45 08             	mov    0x8(%ebp),%eax
c0101359:	89 04 24             	mov    %eax,(%esp)
c010135c:	e8 90 ff ff ff       	call   c01012f1 <serial_putc_sub>
c0101361:	eb 24                	jmp    c0101387 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101363:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136a:	e8 82 ff ff ff       	call   c01012f1 <serial_putc_sub>
        serial_putc_sub(' ');
c010136f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101376:	e8 76 ff ff ff       	call   c01012f1 <serial_putc_sub>
        serial_putc_sub('\b');
c010137b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101382:	e8 6a ff ff ff       	call   c01012f1 <serial_putc_sub>
    }
}
c0101387:	c9                   	leave  
c0101388:	c3                   	ret    

c0101389 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101389:	55                   	push   %ebp
c010138a:	89 e5                	mov    %esp,%ebp
c010138c:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010138f:	eb 33                	jmp    c01013c4 <cons_intr+0x3b>
        if (c != 0) {
c0101391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101395:	74 2d                	je     c01013c4 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101397:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c010139c:	8d 50 01             	lea    0x1(%eax),%edx
c010139f:	89 15 64 c6 11 c0    	mov    %edx,0xc011c664
c01013a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013a8:	88 90 60 c4 11 c0    	mov    %dl,-0x3fee3ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013ae:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c01013b3:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013b8:	75 0a                	jne    c01013c4 <cons_intr+0x3b>
                cons.wpos = 0;
c01013ba:	c7 05 64 c6 11 c0 00 	movl   $0x0,0xc011c664
c01013c1:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01013c7:	ff d0                	call   *%eax
c01013c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013cc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013d0:	75 bf                	jne    c0101391 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013d2:	c9                   	leave  
c01013d3:	c3                   	ret    

c01013d4 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013d4:	55                   	push   %ebp
c01013d5:	89 e5                	mov    %esp,%ebp
c01013d7:	83 ec 10             	sub    $0x10,%esp
c01013da:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013e0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013e4:	89 c2                	mov    %eax,%edx
c01013e6:	ec                   	in     (%dx),%al
c01013e7:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013ea:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013ee:	0f b6 c0             	movzbl %al,%eax
c01013f1:	83 e0 01             	and    $0x1,%eax
c01013f4:	85 c0                	test   %eax,%eax
c01013f6:	75 07                	jne    c01013ff <serial_proc_data+0x2b>
        return -1;
c01013f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013fd:	eb 2a                	jmp    c0101429 <serial_proc_data+0x55>
c01013ff:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101405:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101409:	89 c2                	mov    %eax,%edx
c010140b:	ec                   	in     (%dx),%al
c010140c:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010140f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101413:	0f b6 c0             	movzbl %al,%eax
c0101416:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101419:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010141d:	75 07                	jne    c0101426 <serial_proc_data+0x52>
        c = '\b';
c010141f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101426:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101429:	c9                   	leave  
c010142a:	c3                   	ret    

c010142b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010142b:	55                   	push   %ebp
c010142c:	89 e5                	mov    %esp,%ebp
c010142e:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101431:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101436:	85 c0                	test   %eax,%eax
c0101438:	74 0c                	je     c0101446 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010143a:	c7 04 24 d4 13 10 c0 	movl   $0xc01013d4,(%esp)
c0101441:	e8 43 ff ff ff       	call   c0101389 <cons_intr>
    }
}
c0101446:	c9                   	leave  
c0101447:	c3                   	ret    

c0101448 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101448:	55                   	push   %ebp
c0101449:	89 e5                	mov    %esp,%ebp
c010144b:	83 ec 38             	sub    $0x38,%esp
c010144e:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101454:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101458:	89 c2                	mov    %eax,%edx
c010145a:	ec                   	in     (%dx),%al
c010145b:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010145e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101462:	0f b6 c0             	movzbl %al,%eax
c0101465:	83 e0 01             	and    $0x1,%eax
c0101468:	85 c0                	test   %eax,%eax
c010146a:	75 0a                	jne    c0101476 <kbd_proc_data+0x2e>
        return -1;
c010146c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101471:	e9 59 01 00 00       	jmp    c01015cf <kbd_proc_data+0x187>
c0101476:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010147c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101480:	89 c2                	mov    %eax,%edx
c0101482:	ec                   	in     (%dx),%al
c0101483:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101486:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010148a:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010148d:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101491:	75 17                	jne    c01014aa <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101493:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101498:	83 c8 40             	or     $0x40,%eax
c010149b:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c01014a0:	b8 00 00 00 00       	mov    $0x0,%eax
c01014a5:	e9 25 01 00 00       	jmp    c01015cf <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01014aa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ae:	84 c0                	test   %al,%al
c01014b0:	79 47                	jns    c01014f9 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014b2:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014b7:	83 e0 40             	and    $0x40,%eax
c01014ba:	85 c0                	test   %eax,%eax
c01014bc:	75 09                	jne    c01014c7 <kbd_proc_data+0x7f>
c01014be:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c2:	83 e0 7f             	and    $0x7f,%eax
c01014c5:	eb 04                	jmp    c01014cb <kbd_proc_data+0x83>
c01014c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014cb:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014ce:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014d2:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c01014d9:	83 c8 40             	or     $0x40,%eax
c01014dc:	0f b6 c0             	movzbl %al,%eax
c01014df:	f7 d0                	not    %eax
c01014e1:	89 c2                	mov    %eax,%edx
c01014e3:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014e8:	21 d0                	and    %edx,%eax
c01014ea:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c01014ef:	b8 00 00 00 00       	mov    $0x0,%eax
c01014f4:	e9 d6 00 00 00       	jmp    c01015cf <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014f9:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014fe:	83 e0 40             	and    $0x40,%eax
c0101501:	85 c0                	test   %eax,%eax
c0101503:	74 11                	je     c0101516 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101505:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101509:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010150e:	83 e0 bf             	and    $0xffffffbf,%eax
c0101511:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    }

    shift |= shiftcode[data];
c0101516:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151a:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c0101521:	0f b6 d0             	movzbl %al,%edx
c0101524:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101529:	09 d0                	or     %edx,%eax
c010152b:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    shift ^= togglecode[data];
c0101530:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101534:	0f b6 80 40 91 11 c0 	movzbl -0x3fee6ec0(%eax),%eax
c010153b:	0f b6 d0             	movzbl %al,%edx
c010153e:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101543:	31 d0                	xor    %edx,%eax
c0101545:	a3 68 c6 11 c0       	mov    %eax,0xc011c668

    c = charcode[shift & (CTL | SHIFT)][data];
c010154a:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010154f:	83 e0 03             	and    $0x3,%eax
c0101552:	8b 14 85 40 95 11 c0 	mov    -0x3fee6ac0(,%eax,4),%edx
c0101559:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010155d:	01 d0                	add    %edx,%eax
c010155f:	0f b6 00             	movzbl (%eax),%eax
c0101562:	0f b6 c0             	movzbl %al,%eax
c0101565:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101568:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010156d:	83 e0 08             	and    $0x8,%eax
c0101570:	85 c0                	test   %eax,%eax
c0101572:	74 22                	je     c0101596 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101574:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101578:	7e 0c                	jle    c0101586 <kbd_proc_data+0x13e>
c010157a:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010157e:	7f 06                	jg     c0101586 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101580:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101584:	eb 10                	jmp    c0101596 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101586:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010158a:	7e 0a                	jle    c0101596 <kbd_proc_data+0x14e>
c010158c:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101590:	7f 04                	jg     c0101596 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101592:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101596:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010159b:	f7 d0                	not    %eax
c010159d:	83 e0 06             	and    $0x6,%eax
c01015a0:	85 c0                	test   %eax,%eax
c01015a2:	75 28                	jne    c01015cc <kbd_proc_data+0x184>
c01015a4:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015ab:	75 1f                	jne    c01015cc <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01015ad:	c7 04 24 23 6f 10 c0 	movl   $0xc0106f23,(%esp)
c01015b4:	e8 9a ed ff ff       	call   c0100353 <cprintf>
c01015b9:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015bf:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015c3:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015c7:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015cb:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015cf:	c9                   	leave  
c01015d0:	c3                   	ret    

c01015d1 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015d1:	55                   	push   %ebp
c01015d2:	89 e5                	mov    %esp,%ebp
c01015d4:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015d7:	c7 04 24 48 14 10 c0 	movl   $0xc0101448,(%esp)
c01015de:	e8 a6 fd ff ff       	call   c0101389 <cons_intr>
}
c01015e3:	c9                   	leave  
c01015e4:	c3                   	ret    

c01015e5 <kbd_init>:

static void
kbd_init(void) {
c01015e5:	55                   	push   %ebp
c01015e6:	89 e5                	mov    %esp,%ebp
c01015e8:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015eb:	e8 e1 ff ff ff       	call   c01015d1 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015f7:	e8 3d 01 00 00       	call   c0101739 <pic_enable>
}
c01015fc:	c9                   	leave  
c01015fd:	c3                   	ret    

c01015fe <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015fe:	55                   	push   %ebp
c01015ff:	89 e5                	mov    %esp,%ebp
c0101601:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101604:	e8 93 f8 ff ff       	call   c0100e9c <cga_init>
    serial_init();
c0101609:	e8 74 f9 ff ff       	call   c0100f82 <serial_init>
    kbd_init();
c010160e:	e8 d2 ff ff ff       	call   c01015e5 <kbd_init>
    if (!serial_exists) {
c0101613:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101618:	85 c0                	test   %eax,%eax
c010161a:	75 0c                	jne    c0101628 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010161c:	c7 04 24 2f 6f 10 c0 	movl   $0xc0106f2f,(%esp)
c0101623:	e8 2b ed ff ff       	call   c0100353 <cprintf>
    }
}
c0101628:	c9                   	leave  
c0101629:	c3                   	ret    

c010162a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010162a:	55                   	push   %ebp
c010162b:	89 e5                	mov    %esp,%ebp
c010162d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101630:	e8 e2 f7 ff ff       	call   c0100e17 <__intr_save>
c0101635:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101638:	8b 45 08             	mov    0x8(%ebp),%eax
c010163b:	89 04 24             	mov    %eax,(%esp)
c010163e:	e8 9b fa ff ff       	call   c01010de <lpt_putc>
        cga_putc(c);
c0101643:	8b 45 08             	mov    0x8(%ebp),%eax
c0101646:	89 04 24             	mov    %eax,(%esp)
c0101649:	e8 cf fa ff ff       	call   c010111d <cga_putc>
        serial_putc(c);
c010164e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101651:	89 04 24             	mov    %eax,(%esp)
c0101654:	e8 f1 fc ff ff       	call   c010134a <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101659:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010165c:	89 04 24             	mov    %eax,(%esp)
c010165f:	e8 dd f7 ff ff       	call   c0100e41 <__intr_restore>
}
c0101664:	c9                   	leave  
c0101665:	c3                   	ret    

c0101666 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101666:	55                   	push   %ebp
c0101667:	89 e5                	mov    %esp,%ebp
c0101669:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010166c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101673:	e8 9f f7 ff ff       	call   c0100e17 <__intr_save>
c0101678:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010167b:	e8 ab fd ff ff       	call   c010142b <serial_intr>
        kbd_intr();
c0101680:	e8 4c ff ff ff       	call   c01015d1 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101685:	8b 15 60 c6 11 c0    	mov    0xc011c660,%edx
c010168b:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101690:	39 c2                	cmp    %eax,%edx
c0101692:	74 31                	je     c01016c5 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101694:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c0101699:	8d 50 01             	lea    0x1(%eax),%edx
c010169c:	89 15 60 c6 11 c0    	mov    %edx,0xc011c660
c01016a2:	0f b6 80 60 c4 11 c0 	movzbl -0x3fee3ba0(%eax),%eax
c01016a9:	0f b6 c0             	movzbl %al,%eax
c01016ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016af:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c01016b4:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016b9:	75 0a                	jne    c01016c5 <cons_getc+0x5f>
                cons.rpos = 0;
c01016bb:	c7 05 60 c6 11 c0 00 	movl   $0x0,0xc011c660
c01016c2:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016c8:	89 04 24             	mov    %eax,(%esp)
c01016cb:	e8 71 f7 ff ff       	call   c0100e41 <__intr_restore>
    return c;
c01016d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016d3:	c9                   	leave  
c01016d4:	c3                   	ret    

c01016d5 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016d5:	55                   	push   %ebp
c01016d6:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016d8:	fb                   	sti    
    sti();
}
c01016d9:	5d                   	pop    %ebp
c01016da:	c3                   	ret    

c01016db <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016db:	55                   	push   %ebp
c01016dc:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016de:	fa                   	cli    
    cli();
}
c01016df:	5d                   	pop    %ebp
c01016e0:	c3                   	ret    

c01016e1 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016e1:	55                   	push   %ebp
c01016e2:	89 e5                	mov    %esp,%ebp
c01016e4:	83 ec 14             	sub    $0x14,%esp
c01016e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01016ea:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016ee:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f2:	66 a3 50 95 11 c0    	mov    %ax,0xc0119550
    if (did_init) {
c01016f8:	a1 6c c6 11 c0       	mov    0xc011c66c,%eax
c01016fd:	85 c0                	test   %eax,%eax
c01016ff:	74 36                	je     c0101737 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101701:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101705:	0f b6 c0             	movzbl %al,%eax
c0101708:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010170e:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101711:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101715:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101719:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010171a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010171e:	66 c1 e8 08          	shr    $0x8,%ax
c0101722:	0f b6 c0             	movzbl %al,%eax
c0101725:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010172b:	88 45 f9             	mov    %al,-0x7(%ebp)
c010172e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101732:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101736:	ee                   	out    %al,(%dx)
    }
}
c0101737:	c9                   	leave  
c0101738:	c3                   	ret    

c0101739 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101739:	55                   	push   %ebp
c010173a:	89 e5                	mov    %esp,%ebp
c010173c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010173f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101742:	ba 01 00 00 00       	mov    $0x1,%edx
c0101747:	89 c1                	mov    %eax,%ecx
c0101749:	d3 e2                	shl    %cl,%edx
c010174b:	89 d0                	mov    %edx,%eax
c010174d:	f7 d0                	not    %eax
c010174f:	89 c2                	mov    %eax,%edx
c0101751:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101758:	21 d0                	and    %edx,%eax
c010175a:	0f b7 c0             	movzwl %ax,%eax
c010175d:	89 04 24             	mov    %eax,(%esp)
c0101760:	e8 7c ff ff ff       	call   c01016e1 <pic_setmask>
}
c0101765:	c9                   	leave  
c0101766:	c3                   	ret    

c0101767 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101767:	55                   	push   %ebp
c0101768:	89 e5                	mov    %esp,%ebp
c010176a:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010176d:	c7 05 6c c6 11 c0 01 	movl   $0x1,0xc011c66c
c0101774:	00 00 00 
c0101777:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010177d:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101781:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101785:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101789:	ee                   	out    %al,(%dx)
c010178a:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101790:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0101794:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101798:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010179c:	ee                   	out    %al,(%dx)
c010179d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01017a3:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c01017a7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01017ab:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017af:	ee                   	out    %al,(%dx)
c01017b0:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01017b6:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017ba:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017be:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017c2:	ee                   	out    %al,(%dx)
c01017c3:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017c9:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017cd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017d1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017d5:	ee                   	out    %al,(%dx)
c01017d6:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017dc:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017e0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017e4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017e8:	ee                   	out    %al,(%dx)
c01017e9:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017ef:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017f3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017f7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017fb:	ee                   	out    %al,(%dx)
c01017fc:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0101802:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0101806:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010180a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010180e:	ee                   	out    %al,(%dx)
c010180f:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101815:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101819:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010181d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101821:	ee                   	out    %al,(%dx)
c0101822:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101828:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c010182c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101830:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101834:	ee                   	out    %al,(%dx)
c0101835:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c010183b:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010183f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101843:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101847:	ee                   	out    %al,(%dx)
c0101848:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010184e:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0101852:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101856:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010185a:	ee                   	out    %al,(%dx)
c010185b:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c0101861:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101865:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101869:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010186d:	ee                   	out    %al,(%dx)
c010186e:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c0101874:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101878:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010187c:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101880:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101881:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101888:	66 83 f8 ff          	cmp    $0xffff,%ax
c010188c:	74 12                	je     c01018a0 <pic_init+0x139>
        pic_setmask(irq_mask);
c010188e:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101895:	0f b7 c0             	movzwl %ax,%eax
c0101898:	89 04 24             	mov    %eax,(%esp)
c010189b:	e8 41 fe ff ff       	call   c01016e1 <pic_setmask>
    }
}
c01018a0:	c9                   	leave  
c01018a1:	c3                   	ret    

c01018a2 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01018a2:	55                   	push   %ebp
c01018a3:	89 e5                	mov    %esp,%ebp
c01018a5:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01018a8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018af:	00 
c01018b0:	c7 04 24 60 6f 10 c0 	movl   $0xc0106f60,(%esp)
c01018b7:	e8 97 ea ff ff       	call   c0100353 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018bc:	c7 04 24 6a 6f 10 c0 	movl   $0xc0106f6a,(%esp)
c01018c3:	e8 8b ea ff ff       	call   c0100353 <cprintf>
    panic("EOT: kernel seems ok.");
c01018c8:	c7 44 24 08 78 6f 10 	movl   $0xc0106f78,0x8(%esp)
c01018cf:	c0 
c01018d0:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018d7:	00 
c01018d8:	c7 04 24 8e 6f 10 c0 	movl   $0xc0106f8e,(%esp)
c01018df:	e8 03 f4 ff ff       	call   c0100ce7 <__panic>

c01018e4 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018e4:	55                   	push   %ebp
c01018e5:	89 e5                	mov    %esp,%ebp
c01018e7:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c01018ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018f1:	e9 c3 00 00 00       	jmp    c01019b9 <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f9:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c0101900:	89 c2                	mov    %eax,%edx
c0101902:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101905:	66 89 14 c5 80 c6 11 	mov    %dx,-0x3fee3980(,%eax,8)
c010190c:	c0 
c010190d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101910:	66 c7 04 c5 82 c6 11 	movw   $0x8,-0x3fee397e(,%eax,8)
c0101917:	c0 08 00 
c010191a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010191d:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c0101924:	c0 
c0101925:	83 e2 e0             	and    $0xffffffe0,%edx
c0101928:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c010192f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101932:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c0101939:	c0 
c010193a:	83 e2 1f             	and    $0x1f,%edx
c010193d:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c0101944:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101947:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c010194e:	c0 
c010194f:	83 e2 f0             	and    $0xfffffff0,%edx
c0101952:	83 ca 0e             	or     $0xe,%edx
c0101955:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c010195c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010195f:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101966:	c0 
c0101967:	83 e2 ef             	and    $0xffffffef,%edx
c010196a:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101971:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101974:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c010197b:	c0 
c010197c:	83 e2 9f             	and    $0xffffff9f,%edx
c010197f:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101986:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101989:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101990:	c0 
c0101991:	83 ca 80             	or     $0xffffff80,%edx
c0101994:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c010199b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010199e:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c01019a5:	c1 e8 10             	shr    $0x10,%eax
c01019a8:	89 c2                	mov    %eax,%edx
c01019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019ad:	66 89 14 c5 86 c6 11 	mov    %dx,-0x3fee397a(,%eax,8)
c01019b4:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
c01019b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019bc:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019c1:	0f 86 2f ff ff ff    	jbe    c01018f6 <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
	}
	//SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], 3);
c01019c7:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c01019cc:	66 a3 48 ca 11 c0    	mov    %ax,0xc011ca48
c01019d2:	66 c7 05 4a ca 11 c0 	movw   $0x8,0xc011ca4a
c01019d9:	08 00 
c01019db:	0f b6 05 4c ca 11 c0 	movzbl 0xc011ca4c,%eax
c01019e2:	83 e0 e0             	and    $0xffffffe0,%eax
c01019e5:	a2 4c ca 11 c0       	mov    %al,0xc011ca4c
c01019ea:	0f b6 05 4c ca 11 c0 	movzbl 0xc011ca4c,%eax
c01019f1:	83 e0 1f             	and    $0x1f,%eax
c01019f4:	a2 4c ca 11 c0       	mov    %al,0xc011ca4c
c01019f9:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101a00:	83 c8 0f             	or     $0xf,%eax
c0101a03:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101a08:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101a0f:	83 e0 ef             	and    $0xffffffef,%eax
c0101a12:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101a17:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101a1e:	83 c8 60             	or     $0x60,%eax
c0101a21:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101a26:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101a2d:	83 c8 80             	or     $0xffffff80,%eax
c0101a30:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101a35:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101a3a:	c1 e8 10             	shr    $0x10,%eax
c0101a3d:	66 a3 4e ca 11 c0    	mov    %ax,0xc011ca4e
c0101a43:	c7 45 f8 60 95 11 c0 	movl   $0xc0119560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a4d:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
c0101a50:	c9                   	leave  
c0101a51:	c3                   	ret    

c0101a52 <trapname>:

static const char *
trapname(int trapno) {
c0101a52:	55                   	push   %ebp
c0101a53:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a58:	83 f8 13             	cmp    $0x13,%eax
c0101a5b:	77 0c                	ja     c0101a69 <trapname+0x17>
        return excnames[trapno];
c0101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a60:	8b 04 85 e0 72 10 c0 	mov    -0x3fef8d20(,%eax,4),%eax
c0101a67:	eb 18                	jmp    c0101a81 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a69:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a6d:	7e 0d                	jle    c0101a7c <trapname+0x2a>
c0101a6f:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a73:	7f 07                	jg     c0101a7c <trapname+0x2a>
        return "Hardware Interrupt";
c0101a75:	b8 9f 6f 10 c0       	mov    $0xc0106f9f,%eax
c0101a7a:	eb 05                	jmp    c0101a81 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a7c:	b8 b2 6f 10 c0       	mov    $0xc0106fb2,%eax
}
c0101a81:	5d                   	pop    %ebp
c0101a82:	c3                   	ret    

c0101a83 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a83:	55                   	push   %ebp
c0101a84:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a86:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a89:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a8d:	66 83 f8 08          	cmp    $0x8,%ax
c0101a91:	0f 94 c0             	sete   %al
c0101a94:	0f b6 c0             	movzbl %al,%eax
}
c0101a97:	5d                   	pop    %ebp
c0101a98:	c3                   	ret    

c0101a99 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a99:	55                   	push   %ebp
c0101a9a:	89 e5                	mov    %esp,%ebp
c0101a9c:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aa6:	c7 04 24 f3 6f 10 c0 	movl   $0xc0106ff3,(%esp)
c0101aad:	e8 a1 e8 ff ff       	call   c0100353 <cprintf>
    print_regs(&tf->tf_regs);
c0101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab5:	89 04 24             	mov    %eax,(%esp)
c0101ab8:	e8 a1 01 00 00       	call   c0101c5e <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101abd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac0:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101ac4:	0f b7 c0             	movzwl %ax,%eax
c0101ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101acb:	c7 04 24 04 70 10 c0 	movl   $0xc0107004,(%esp)
c0101ad2:	e8 7c e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ada:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101ade:	0f b7 c0             	movzwl %ax,%eax
c0101ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae5:	c7 04 24 17 70 10 c0 	movl   $0xc0107017,(%esp)
c0101aec:	e8 62 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101af1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af4:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101af8:	0f b7 c0             	movzwl %ax,%eax
c0101afb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aff:	c7 04 24 2a 70 10 c0 	movl   $0xc010702a,(%esp)
c0101b06:	e8 48 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b0e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b12:	0f b7 c0             	movzwl %ax,%eax
c0101b15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b19:	c7 04 24 3d 70 10 c0 	movl   $0xc010703d,(%esp)
c0101b20:	e8 2e e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b28:	8b 40 30             	mov    0x30(%eax),%eax
c0101b2b:	89 04 24             	mov    %eax,(%esp)
c0101b2e:	e8 1f ff ff ff       	call   c0101a52 <trapname>
c0101b33:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b36:	8b 52 30             	mov    0x30(%edx),%edx
c0101b39:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101b3d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b41:	c7 04 24 50 70 10 c0 	movl   $0xc0107050,(%esp)
c0101b48:	e8 06 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b50:	8b 40 34             	mov    0x34(%eax),%eax
c0101b53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b57:	c7 04 24 62 70 10 c0 	movl   $0xc0107062,(%esp)
c0101b5e:	e8 f0 e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b66:	8b 40 38             	mov    0x38(%eax),%eax
c0101b69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b6d:	c7 04 24 71 70 10 c0 	movl   $0xc0107071,(%esp)
c0101b74:	e8 da e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b7c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b80:	0f b7 c0             	movzwl %ax,%eax
c0101b83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b87:	c7 04 24 80 70 10 c0 	movl   $0xc0107080,(%esp)
c0101b8e:	e8 c0 e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b93:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b96:	8b 40 40             	mov    0x40(%eax),%eax
c0101b99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b9d:	c7 04 24 93 70 10 c0 	movl   $0xc0107093,(%esp)
c0101ba4:	e8 aa e7 ff ff       	call   c0100353 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ba9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101bb0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101bb7:	eb 3e                	jmp    c0101bf7 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbc:	8b 50 40             	mov    0x40(%eax),%edx
c0101bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bc2:	21 d0                	and    %edx,%eax
c0101bc4:	85 c0                	test   %eax,%eax
c0101bc6:	74 28                	je     c0101bf0 <print_trapframe+0x157>
c0101bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bcb:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101bd2:	85 c0                	test   %eax,%eax
c0101bd4:	74 1a                	je     c0101bf0 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bd9:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101be0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be4:	c7 04 24 a2 70 10 c0 	movl   $0xc01070a2,(%esp)
c0101beb:	e8 63 e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bf0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bf4:	d1 65 f0             	shll   -0x10(%ebp)
c0101bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bfa:	83 f8 17             	cmp    $0x17,%eax
c0101bfd:	76 ba                	jbe    c0101bb9 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bff:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c02:	8b 40 40             	mov    0x40(%eax),%eax
c0101c05:	25 00 30 00 00       	and    $0x3000,%eax
c0101c0a:	c1 e8 0c             	shr    $0xc,%eax
c0101c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c11:	c7 04 24 a6 70 10 c0 	movl   $0xc01070a6,(%esp)
c0101c18:	e8 36 e7 ff ff       	call   c0100353 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c20:	89 04 24             	mov    %eax,(%esp)
c0101c23:	e8 5b fe ff ff       	call   c0101a83 <trap_in_kernel>
c0101c28:	85 c0                	test   %eax,%eax
c0101c2a:	75 30                	jne    c0101c5c <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2f:	8b 40 44             	mov    0x44(%eax),%eax
c0101c32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c36:	c7 04 24 af 70 10 c0 	movl   $0xc01070af,(%esp)
c0101c3d:	e8 11 e7 ff ff       	call   c0100353 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c45:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c49:	0f b7 c0             	movzwl %ax,%eax
c0101c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c50:	c7 04 24 be 70 10 c0 	movl   $0xc01070be,(%esp)
c0101c57:	e8 f7 e6 ff ff       	call   c0100353 <cprintf>
    }
}
c0101c5c:	c9                   	leave  
c0101c5d:	c3                   	ret    

c0101c5e <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c5e:	55                   	push   %ebp
c0101c5f:	89 e5                	mov    %esp,%ebp
c0101c61:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c64:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c67:	8b 00                	mov    (%eax),%eax
c0101c69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c6d:	c7 04 24 d1 70 10 c0 	movl   $0xc01070d1,(%esp)
c0101c74:	e8 da e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7c:	8b 40 04             	mov    0x4(%eax),%eax
c0101c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c83:	c7 04 24 e0 70 10 c0 	movl   $0xc01070e0,(%esp)
c0101c8a:	e8 c4 e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c92:	8b 40 08             	mov    0x8(%eax),%eax
c0101c95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c99:	c7 04 24 ef 70 10 c0 	movl   $0xc01070ef,(%esp)
c0101ca0:	e8 ae e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca8:	8b 40 0c             	mov    0xc(%eax),%eax
c0101cab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101caf:	c7 04 24 fe 70 10 c0 	movl   $0xc01070fe,(%esp)
c0101cb6:	e8 98 e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cbe:	8b 40 10             	mov    0x10(%eax),%eax
c0101cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc5:	c7 04 24 0d 71 10 c0 	movl   $0xc010710d,(%esp)
c0101ccc:	e8 82 e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd4:	8b 40 14             	mov    0x14(%eax),%eax
c0101cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cdb:	c7 04 24 1c 71 10 c0 	movl   $0xc010711c,(%esp)
c0101ce2:	e8 6c e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cea:	8b 40 18             	mov    0x18(%eax),%eax
c0101ced:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf1:	c7 04 24 2b 71 10 c0 	movl   $0xc010712b,(%esp)
c0101cf8:	e8 56 e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d00:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d07:	c7 04 24 3a 71 10 c0 	movl   $0xc010713a,(%esp)
c0101d0e:	e8 40 e6 ff ff       	call   c0100353 <cprintf>
}
c0101d13:	c9                   	leave  
c0101d14:	c3                   	ret    

c0101d15 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d15:	55                   	push   %ebp
c0101d16:	89 e5                	mov    %esp,%ebp
c0101d18:	57                   	push   %edi
c0101d19:	56                   	push   %esi
c0101d1a:	53                   	push   %ebx
c0101d1b:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d21:	8b 40 30             	mov    0x30(%eax),%eax
c0101d24:	83 f8 2f             	cmp    $0x2f,%eax
c0101d27:	77 21                	ja     c0101d4a <trap_dispatch+0x35>
c0101d29:	83 f8 2e             	cmp    $0x2e,%eax
c0101d2c:	0f 83 ec 01 00 00    	jae    c0101f1e <trap_dispatch+0x209>
c0101d32:	83 f8 21             	cmp    $0x21,%eax
c0101d35:	0f 84 8a 00 00 00    	je     c0101dc5 <trap_dispatch+0xb0>
c0101d3b:	83 f8 24             	cmp    $0x24,%eax
c0101d3e:	74 5c                	je     c0101d9c <trap_dispatch+0x87>
c0101d40:	83 f8 20             	cmp    $0x20,%eax
c0101d43:	74 1c                	je     c0101d61 <trap_dispatch+0x4c>
c0101d45:	e9 9c 01 00 00       	jmp    c0101ee6 <trap_dispatch+0x1d1>
c0101d4a:	83 f8 78             	cmp    $0x78,%eax
c0101d4d:	0f 84 9b 00 00 00    	je     c0101dee <trap_dispatch+0xd9>
c0101d53:	83 f8 79             	cmp    $0x79,%eax
c0101d56:	0f 84 11 01 00 00    	je     c0101e6d <trap_dispatch+0x158>
c0101d5c:	e9 85 01 00 00       	jmp    c0101ee6 <trap_dispatch+0x1d1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101d61:	a1 2c cf 11 c0       	mov    0xc011cf2c,%eax
c0101d66:	83 c0 01             	add    $0x1,%eax
c0101d69:	a3 2c cf 11 c0       	mov    %eax,0xc011cf2c
        if (ticks % TICK_NUM == 0) {
c0101d6e:	8b 0d 2c cf 11 c0    	mov    0xc011cf2c,%ecx
c0101d74:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d79:	89 c8                	mov    %ecx,%eax
c0101d7b:	f7 e2                	mul    %edx
c0101d7d:	89 d0                	mov    %edx,%eax
c0101d7f:	c1 e8 05             	shr    $0x5,%eax
c0101d82:	6b c0 64             	imul   $0x64,%eax,%eax
c0101d85:	29 c1                	sub    %eax,%ecx
c0101d87:	89 c8                	mov    %ecx,%eax
c0101d89:	85 c0                	test   %eax,%eax
c0101d8b:	75 0a                	jne    c0101d97 <trap_dispatch+0x82>
            print_ticks();
c0101d8d:	e8 10 fb ff ff       	call   c01018a2 <print_ticks>
        }
        break;
c0101d92:	e9 88 01 00 00       	jmp    c0101f1f <trap_dispatch+0x20a>
c0101d97:	e9 83 01 00 00       	jmp    c0101f1f <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d9c:	e8 c5 f8 ff ff       	call   c0101666 <cons_getc>
c0101da1:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101da4:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101da8:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101dac:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101db0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101db4:	c7 04 24 49 71 10 c0 	movl   $0xc0107149,(%esp)
c0101dbb:	e8 93 e5 ff ff       	call   c0100353 <cprintf>
        break;
c0101dc0:	e9 5a 01 00 00       	jmp    c0101f1f <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101dc5:	e8 9c f8 ff ff       	call   c0101666 <cons_getc>
c0101dca:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101dcd:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101dd1:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101dd5:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ddd:	c7 04 24 5b 71 10 c0 	movl   $0xc010715b,(%esp)
c0101de4:	e8 6a e5 ff ff       	call   c0100353 <cprintf>
        break;
c0101de9:	e9 31 01 00 00       	jmp    c0101f1f <trap_dispatch+0x20a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
		if (tf->tf_cs != USER_CS) {
c0101dee:	8b 45 08             	mov    0x8(%ebp),%eax
c0101df1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101df5:	66 83 f8 1b          	cmp    $0x1b,%ax
c0101df9:	74 6d                	je     c0101e68 <trap_dispatch+0x153>
            switchk2u = *tf;
c0101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dfe:	ba 40 cf 11 c0       	mov    $0xc011cf40,%edx
c0101e03:	89 c3                	mov    %eax,%ebx
c0101e05:	b8 13 00 00 00       	mov    $0x13,%eax
c0101e0a:	89 d7                	mov    %edx,%edi
c0101e0c:	89 de                	mov    %ebx,%esi
c0101e0e:	89 c1                	mov    %eax,%ecx
c0101e10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
c0101e12:	66 c7 05 7c cf 11 c0 	movw   $0x1b,0xc011cf7c
c0101e19:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0101e1b:	66 c7 05 88 cf 11 c0 	movw   $0x23,0xc011cf88
c0101e22:	23 00 
c0101e24:	0f b7 05 88 cf 11 c0 	movzwl 0xc011cf88,%eax
c0101e2b:	66 a3 68 cf 11 c0    	mov    %ax,0xc011cf68
c0101e31:	0f b7 05 68 cf 11 c0 	movzwl 0xc011cf68,%eax
c0101e38:	66 a3 6c cf 11 c0    	mov    %ax,0xc011cf6c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c0101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e41:	83 c0 44             	add    $0x44,%eax
c0101e44:	a3 84 cf 11 c0       	mov    %eax,0xc011cf84
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c0101e49:	a1 80 cf 11 c0       	mov    0xc011cf80,%eax
c0101e4e:	80 cc 30             	or     $0x30,%ah
c0101e51:	a3 80 cf 11 c0       	mov    %eax,0xc011cf80
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0101e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e59:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101e5c:	b8 40 cf 11 c0       	mov    $0xc011cf40,%eax
c0101e61:	89 02                	mov    %eax,(%edx)
        }
        break;
c0101e63:	e9 b7 00 00 00       	jmp    c0101f1f <trap_dispatch+0x20a>
c0101e68:	e9 b2 00 00 00       	jmp    c0101f1f <trap_dispatch+0x20a>
    case T_SWITCH_TOK:
		if (tf->tf_cs != KERNEL_CS) {
c0101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e70:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e74:	66 83 f8 08          	cmp    $0x8,%ax
c0101e78:	74 6a                	je     c0101ee4 <trap_dispatch+0x1cf>
            tf->tf_cs = KERNEL_CS;
c0101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e7d:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101e83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e86:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e8f:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101e93:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e96:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0101e9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e9d:	8b 40 40             	mov    0x40(%eax),%eax
c0101ea0:	80 e4 cf             	and    $0xcf,%ah
c0101ea3:	89 c2                	mov    %eax,%edx
c0101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea8:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101eab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eae:	8b 40 44             	mov    0x44(%eax),%eax
c0101eb1:	83 e8 44             	sub    $0x44,%eax
c0101eb4:	a3 8c cf 11 c0       	mov    %eax,0xc011cf8c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0101eb9:	a1 8c cf 11 c0       	mov    0xc011cf8c,%eax
c0101ebe:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0101ec5:	00 
c0101ec6:	8b 55 08             	mov    0x8(%ebp),%edx
c0101ec9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101ecd:	89 04 24             	mov    %eax,(%esp)
c0101ed0:	e8 bd 4b 00 00       	call   c0106a92 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed8:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101edb:	a1 8c cf 11 c0       	mov    0xc011cf8c,%eax
c0101ee0:	89 02                	mov    %eax,(%edx)
        }
        break;
c0101ee2:	eb 3b                	jmp    c0101f1f <trap_dispatch+0x20a>
c0101ee4:	eb 39                	jmp    c0101f1f <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101eed:	0f b7 c0             	movzwl %ax,%eax
c0101ef0:	83 e0 03             	and    $0x3,%eax
c0101ef3:	85 c0                	test   %eax,%eax
c0101ef5:	75 28                	jne    c0101f1f <trap_dispatch+0x20a>
            print_trapframe(tf);
c0101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101efa:	89 04 24             	mov    %eax,(%esp)
c0101efd:	e8 97 fb ff ff       	call   c0101a99 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101f02:	c7 44 24 08 6a 71 10 	movl   $0xc010716a,0x8(%esp)
c0101f09:	c0 
c0101f0a:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0101f11:	00 
c0101f12:	c7 04 24 8e 6f 10 c0 	movl   $0xc0106f8e,(%esp)
c0101f19:	e8 c9 ed ff ff       	call   c0100ce7 <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101f1e:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101f1f:	83 c4 2c             	add    $0x2c,%esp
c0101f22:	5b                   	pop    %ebx
c0101f23:	5e                   	pop    %esi
c0101f24:	5f                   	pop    %edi
c0101f25:	5d                   	pop    %ebp
c0101f26:	c3                   	ret    

c0101f27 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101f27:	55                   	push   %ebp
c0101f28:	89 e5                	mov    %esp,%ebp
c0101f2a:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f30:	89 04 24             	mov    %eax,(%esp)
c0101f33:	e8 dd fd ff ff       	call   c0101d15 <trap_dispatch>
}
c0101f38:	c9                   	leave  
c0101f39:	c3                   	ret    

c0101f3a <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101f3a:	1e                   	push   %ds
    pushl %es
c0101f3b:	06                   	push   %es
    pushl %fs
c0101f3c:	0f a0                	push   %fs
    pushl %gs
c0101f3e:	0f a8                	push   %gs
    pushal
c0101f40:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101f41:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101f46:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101f48:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101f4a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101f4b:	e8 d7 ff ff ff       	call   c0101f27 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101f50:	5c                   	pop    %esp

c0101f51 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101f51:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101f52:	0f a9                	pop    %gs
    popl %fs
c0101f54:	0f a1                	pop    %fs
    popl %es
c0101f56:	07                   	pop    %es
    popl %ds
c0101f57:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101f58:	83 c4 08             	add    $0x8,%esp
    iret
c0101f5b:	cf                   	iret   

c0101f5c <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101f5c:	6a 00                	push   $0x0
  pushl $0
c0101f5e:	6a 00                	push   $0x0
  jmp __alltraps
c0101f60:	e9 d5 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101f65 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101f65:	6a 00                	push   $0x0
  pushl $1
c0101f67:	6a 01                	push   $0x1
  jmp __alltraps
c0101f69:	e9 cc ff ff ff       	jmp    c0101f3a <__alltraps>

c0101f6e <vector2>:
.globl vector2
vector2:
  pushl $0
c0101f6e:	6a 00                	push   $0x0
  pushl $2
c0101f70:	6a 02                	push   $0x2
  jmp __alltraps
c0101f72:	e9 c3 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101f77 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101f77:	6a 00                	push   $0x0
  pushl $3
c0101f79:	6a 03                	push   $0x3
  jmp __alltraps
c0101f7b:	e9 ba ff ff ff       	jmp    c0101f3a <__alltraps>

c0101f80 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101f80:	6a 00                	push   $0x0
  pushl $4
c0101f82:	6a 04                	push   $0x4
  jmp __alltraps
c0101f84:	e9 b1 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101f89 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101f89:	6a 00                	push   $0x0
  pushl $5
c0101f8b:	6a 05                	push   $0x5
  jmp __alltraps
c0101f8d:	e9 a8 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101f92 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101f92:	6a 00                	push   $0x0
  pushl $6
c0101f94:	6a 06                	push   $0x6
  jmp __alltraps
c0101f96:	e9 9f ff ff ff       	jmp    c0101f3a <__alltraps>

c0101f9b <vector7>:
.globl vector7
vector7:
  pushl $0
c0101f9b:	6a 00                	push   $0x0
  pushl $7
c0101f9d:	6a 07                	push   $0x7
  jmp __alltraps
c0101f9f:	e9 96 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fa4 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101fa4:	6a 08                	push   $0x8
  jmp __alltraps
c0101fa6:	e9 8f ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fab <vector9>:
.globl vector9
vector9:
  pushl $0
c0101fab:	6a 00                	push   $0x0
  pushl $9
c0101fad:	6a 09                	push   $0x9
  jmp __alltraps
c0101faf:	e9 86 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fb4 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101fb4:	6a 0a                	push   $0xa
  jmp __alltraps
c0101fb6:	e9 7f ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fbb <vector11>:
.globl vector11
vector11:
  pushl $11
c0101fbb:	6a 0b                	push   $0xb
  jmp __alltraps
c0101fbd:	e9 78 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fc2 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101fc2:	6a 0c                	push   $0xc
  jmp __alltraps
c0101fc4:	e9 71 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fc9 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101fc9:	6a 0d                	push   $0xd
  jmp __alltraps
c0101fcb:	e9 6a ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fd0 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101fd0:	6a 0e                	push   $0xe
  jmp __alltraps
c0101fd2:	e9 63 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fd7 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101fd7:	6a 00                	push   $0x0
  pushl $15
c0101fd9:	6a 0f                	push   $0xf
  jmp __alltraps
c0101fdb:	e9 5a ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fe0 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101fe0:	6a 00                	push   $0x0
  pushl $16
c0101fe2:	6a 10                	push   $0x10
  jmp __alltraps
c0101fe4:	e9 51 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101fe9 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101fe9:	6a 11                	push   $0x11
  jmp __alltraps
c0101feb:	e9 4a ff ff ff       	jmp    c0101f3a <__alltraps>

c0101ff0 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101ff0:	6a 00                	push   $0x0
  pushl $18
c0101ff2:	6a 12                	push   $0x12
  jmp __alltraps
c0101ff4:	e9 41 ff ff ff       	jmp    c0101f3a <__alltraps>

c0101ff9 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101ff9:	6a 00                	push   $0x0
  pushl $19
c0101ffb:	6a 13                	push   $0x13
  jmp __alltraps
c0101ffd:	e9 38 ff ff ff       	jmp    c0101f3a <__alltraps>

c0102002 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102002:	6a 00                	push   $0x0
  pushl $20
c0102004:	6a 14                	push   $0x14
  jmp __alltraps
c0102006:	e9 2f ff ff ff       	jmp    c0101f3a <__alltraps>

c010200b <vector21>:
.globl vector21
vector21:
  pushl $0
c010200b:	6a 00                	push   $0x0
  pushl $21
c010200d:	6a 15                	push   $0x15
  jmp __alltraps
c010200f:	e9 26 ff ff ff       	jmp    c0101f3a <__alltraps>

c0102014 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102014:	6a 00                	push   $0x0
  pushl $22
c0102016:	6a 16                	push   $0x16
  jmp __alltraps
c0102018:	e9 1d ff ff ff       	jmp    c0101f3a <__alltraps>

c010201d <vector23>:
.globl vector23
vector23:
  pushl $0
c010201d:	6a 00                	push   $0x0
  pushl $23
c010201f:	6a 17                	push   $0x17
  jmp __alltraps
c0102021:	e9 14 ff ff ff       	jmp    c0101f3a <__alltraps>

c0102026 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102026:	6a 00                	push   $0x0
  pushl $24
c0102028:	6a 18                	push   $0x18
  jmp __alltraps
c010202a:	e9 0b ff ff ff       	jmp    c0101f3a <__alltraps>

c010202f <vector25>:
.globl vector25
vector25:
  pushl $0
c010202f:	6a 00                	push   $0x0
  pushl $25
c0102031:	6a 19                	push   $0x19
  jmp __alltraps
c0102033:	e9 02 ff ff ff       	jmp    c0101f3a <__alltraps>

c0102038 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102038:	6a 00                	push   $0x0
  pushl $26
c010203a:	6a 1a                	push   $0x1a
  jmp __alltraps
c010203c:	e9 f9 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102041 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102041:	6a 00                	push   $0x0
  pushl $27
c0102043:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102045:	e9 f0 fe ff ff       	jmp    c0101f3a <__alltraps>

c010204a <vector28>:
.globl vector28
vector28:
  pushl $0
c010204a:	6a 00                	push   $0x0
  pushl $28
c010204c:	6a 1c                	push   $0x1c
  jmp __alltraps
c010204e:	e9 e7 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102053 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102053:	6a 00                	push   $0x0
  pushl $29
c0102055:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102057:	e9 de fe ff ff       	jmp    c0101f3a <__alltraps>

c010205c <vector30>:
.globl vector30
vector30:
  pushl $0
c010205c:	6a 00                	push   $0x0
  pushl $30
c010205e:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102060:	e9 d5 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102065 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102065:	6a 00                	push   $0x0
  pushl $31
c0102067:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102069:	e9 cc fe ff ff       	jmp    c0101f3a <__alltraps>

c010206e <vector32>:
.globl vector32
vector32:
  pushl $0
c010206e:	6a 00                	push   $0x0
  pushl $32
c0102070:	6a 20                	push   $0x20
  jmp __alltraps
c0102072:	e9 c3 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102077 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102077:	6a 00                	push   $0x0
  pushl $33
c0102079:	6a 21                	push   $0x21
  jmp __alltraps
c010207b:	e9 ba fe ff ff       	jmp    c0101f3a <__alltraps>

c0102080 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102080:	6a 00                	push   $0x0
  pushl $34
c0102082:	6a 22                	push   $0x22
  jmp __alltraps
c0102084:	e9 b1 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102089 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102089:	6a 00                	push   $0x0
  pushl $35
c010208b:	6a 23                	push   $0x23
  jmp __alltraps
c010208d:	e9 a8 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102092 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102092:	6a 00                	push   $0x0
  pushl $36
c0102094:	6a 24                	push   $0x24
  jmp __alltraps
c0102096:	e9 9f fe ff ff       	jmp    c0101f3a <__alltraps>

c010209b <vector37>:
.globl vector37
vector37:
  pushl $0
c010209b:	6a 00                	push   $0x0
  pushl $37
c010209d:	6a 25                	push   $0x25
  jmp __alltraps
c010209f:	e9 96 fe ff ff       	jmp    c0101f3a <__alltraps>

c01020a4 <vector38>:
.globl vector38
vector38:
  pushl $0
c01020a4:	6a 00                	push   $0x0
  pushl $38
c01020a6:	6a 26                	push   $0x26
  jmp __alltraps
c01020a8:	e9 8d fe ff ff       	jmp    c0101f3a <__alltraps>

c01020ad <vector39>:
.globl vector39
vector39:
  pushl $0
c01020ad:	6a 00                	push   $0x0
  pushl $39
c01020af:	6a 27                	push   $0x27
  jmp __alltraps
c01020b1:	e9 84 fe ff ff       	jmp    c0101f3a <__alltraps>

c01020b6 <vector40>:
.globl vector40
vector40:
  pushl $0
c01020b6:	6a 00                	push   $0x0
  pushl $40
c01020b8:	6a 28                	push   $0x28
  jmp __alltraps
c01020ba:	e9 7b fe ff ff       	jmp    c0101f3a <__alltraps>

c01020bf <vector41>:
.globl vector41
vector41:
  pushl $0
c01020bf:	6a 00                	push   $0x0
  pushl $41
c01020c1:	6a 29                	push   $0x29
  jmp __alltraps
c01020c3:	e9 72 fe ff ff       	jmp    c0101f3a <__alltraps>

c01020c8 <vector42>:
.globl vector42
vector42:
  pushl $0
c01020c8:	6a 00                	push   $0x0
  pushl $42
c01020ca:	6a 2a                	push   $0x2a
  jmp __alltraps
c01020cc:	e9 69 fe ff ff       	jmp    c0101f3a <__alltraps>

c01020d1 <vector43>:
.globl vector43
vector43:
  pushl $0
c01020d1:	6a 00                	push   $0x0
  pushl $43
c01020d3:	6a 2b                	push   $0x2b
  jmp __alltraps
c01020d5:	e9 60 fe ff ff       	jmp    c0101f3a <__alltraps>

c01020da <vector44>:
.globl vector44
vector44:
  pushl $0
c01020da:	6a 00                	push   $0x0
  pushl $44
c01020dc:	6a 2c                	push   $0x2c
  jmp __alltraps
c01020de:	e9 57 fe ff ff       	jmp    c0101f3a <__alltraps>

c01020e3 <vector45>:
.globl vector45
vector45:
  pushl $0
c01020e3:	6a 00                	push   $0x0
  pushl $45
c01020e5:	6a 2d                	push   $0x2d
  jmp __alltraps
c01020e7:	e9 4e fe ff ff       	jmp    c0101f3a <__alltraps>

c01020ec <vector46>:
.globl vector46
vector46:
  pushl $0
c01020ec:	6a 00                	push   $0x0
  pushl $46
c01020ee:	6a 2e                	push   $0x2e
  jmp __alltraps
c01020f0:	e9 45 fe ff ff       	jmp    c0101f3a <__alltraps>

c01020f5 <vector47>:
.globl vector47
vector47:
  pushl $0
c01020f5:	6a 00                	push   $0x0
  pushl $47
c01020f7:	6a 2f                	push   $0x2f
  jmp __alltraps
c01020f9:	e9 3c fe ff ff       	jmp    c0101f3a <__alltraps>

c01020fe <vector48>:
.globl vector48
vector48:
  pushl $0
c01020fe:	6a 00                	push   $0x0
  pushl $48
c0102100:	6a 30                	push   $0x30
  jmp __alltraps
c0102102:	e9 33 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102107 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102107:	6a 00                	push   $0x0
  pushl $49
c0102109:	6a 31                	push   $0x31
  jmp __alltraps
c010210b:	e9 2a fe ff ff       	jmp    c0101f3a <__alltraps>

c0102110 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102110:	6a 00                	push   $0x0
  pushl $50
c0102112:	6a 32                	push   $0x32
  jmp __alltraps
c0102114:	e9 21 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102119 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102119:	6a 00                	push   $0x0
  pushl $51
c010211b:	6a 33                	push   $0x33
  jmp __alltraps
c010211d:	e9 18 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102122 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102122:	6a 00                	push   $0x0
  pushl $52
c0102124:	6a 34                	push   $0x34
  jmp __alltraps
c0102126:	e9 0f fe ff ff       	jmp    c0101f3a <__alltraps>

c010212b <vector53>:
.globl vector53
vector53:
  pushl $0
c010212b:	6a 00                	push   $0x0
  pushl $53
c010212d:	6a 35                	push   $0x35
  jmp __alltraps
c010212f:	e9 06 fe ff ff       	jmp    c0101f3a <__alltraps>

c0102134 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102134:	6a 00                	push   $0x0
  pushl $54
c0102136:	6a 36                	push   $0x36
  jmp __alltraps
c0102138:	e9 fd fd ff ff       	jmp    c0101f3a <__alltraps>

c010213d <vector55>:
.globl vector55
vector55:
  pushl $0
c010213d:	6a 00                	push   $0x0
  pushl $55
c010213f:	6a 37                	push   $0x37
  jmp __alltraps
c0102141:	e9 f4 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102146 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102146:	6a 00                	push   $0x0
  pushl $56
c0102148:	6a 38                	push   $0x38
  jmp __alltraps
c010214a:	e9 eb fd ff ff       	jmp    c0101f3a <__alltraps>

c010214f <vector57>:
.globl vector57
vector57:
  pushl $0
c010214f:	6a 00                	push   $0x0
  pushl $57
c0102151:	6a 39                	push   $0x39
  jmp __alltraps
c0102153:	e9 e2 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102158 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102158:	6a 00                	push   $0x0
  pushl $58
c010215a:	6a 3a                	push   $0x3a
  jmp __alltraps
c010215c:	e9 d9 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102161 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102161:	6a 00                	push   $0x0
  pushl $59
c0102163:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102165:	e9 d0 fd ff ff       	jmp    c0101f3a <__alltraps>

c010216a <vector60>:
.globl vector60
vector60:
  pushl $0
c010216a:	6a 00                	push   $0x0
  pushl $60
c010216c:	6a 3c                	push   $0x3c
  jmp __alltraps
c010216e:	e9 c7 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102173 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102173:	6a 00                	push   $0x0
  pushl $61
c0102175:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102177:	e9 be fd ff ff       	jmp    c0101f3a <__alltraps>

c010217c <vector62>:
.globl vector62
vector62:
  pushl $0
c010217c:	6a 00                	push   $0x0
  pushl $62
c010217e:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102180:	e9 b5 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102185 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102185:	6a 00                	push   $0x0
  pushl $63
c0102187:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102189:	e9 ac fd ff ff       	jmp    c0101f3a <__alltraps>

c010218e <vector64>:
.globl vector64
vector64:
  pushl $0
c010218e:	6a 00                	push   $0x0
  pushl $64
c0102190:	6a 40                	push   $0x40
  jmp __alltraps
c0102192:	e9 a3 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102197 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102197:	6a 00                	push   $0x0
  pushl $65
c0102199:	6a 41                	push   $0x41
  jmp __alltraps
c010219b:	e9 9a fd ff ff       	jmp    c0101f3a <__alltraps>

c01021a0 <vector66>:
.globl vector66
vector66:
  pushl $0
c01021a0:	6a 00                	push   $0x0
  pushl $66
c01021a2:	6a 42                	push   $0x42
  jmp __alltraps
c01021a4:	e9 91 fd ff ff       	jmp    c0101f3a <__alltraps>

c01021a9 <vector67>:
.globl vector67
vector67:
  pushl $0
c01021a9:	6a 00                	push   $0x0
  pushl $67
c01021ab:	6a 43                	push   $0x43
  jmp __alltraps
c01021ad:	e9 88 fd ff ff       	jmp    c0101f3a <__alltraps>

c01021b2 <vector68>:
.globl vector68
vector68:
  pushl $0
c01021b2:	6a 00                	push   $0x0
  pushl $68
c01021b4:	6a 44                	push   $0x44
  jmp __alltraps
c01021b6:	e9 7f fd ff ff       	jmp    c0101f3a <__alltraps>

c01021bb <vector69>:
.globl vector69
vector69:
  pushl $0
c01021bb:	6a 00                	push   $0x0
  pushl $69
c01021bd:	6a 45                	push   $0x45
  jmp __alltraps
c01021bf:	e9 76 fd ff ff       	jmp    c0101f3a <__alltraps>

c01021c4 <vector70>:
.globl vector70
vector70:
  pushl $0
c01021c4:	6a 00                	push   $0x0
  pushl $70
c01021c6:	6a 46                	push   $0x46
  jmp __alltraps
c01021c8:	e9 6d fd ff ff       	jmp    c0101f3a <__alltraps>

c01021cd <vector71>:
.globl vector71
vector71:
  pushl $0
c01021cd:	6a 00                	push   $0x0
  pushl $71
c01021cf:	6a 47                	push   $0x47
  jmp __alltraps
c01021d1:	e9 64 fd ff ff       	jmp    c0101f3a <__alltraps>

c01021d6 <vector72>:
.globl vector72
vector72:
  pushl $0
c01021d6:	6a 00                	push   $0x0
  pushl $72
c01021d8:	6a 48                	push   $0x48
  jmp __alltraps
c01021da:	e9 5b fd ff ff       	jmp    c0101f3a <__alltraps>

c01021df <vector73>:
.globl vector73
vector73:
  pushl $0
c01021df:	6a 00                	push   $0x0
  pushl $73
c01021e1:	6a 49                	push   $0x49
  jmp __alltraps
c01021e3:	e9 52 fd ff ff       	jmp    c0101f3a <__alltraps>

c01021e8 <vector74>:
.globl vector74
vector74:
  pushl $0
c01021e8:	6a 00                	push   $0x0
  pushl $74
c01021ea:	6a 4a                	push   $0x4a
  jmp __alltraps
c01021ec:	e9 49 fd ff ff       	jmp    c0101f3a <__alltraps>

c01021f1 <vector75>:
.globl vector75
vector75:
  pushl $0
c01021f1:	6a 00                	push   $0x0
  pushl $75
c01021f3:	6a 4b                	push   $0x4b
  jmp __alltraps
c01021f5:	e9 40 fd ff ff       	jmp    c0101f3a <__alltraps>

c01021fa <vector76>:
.globl vector76
vector76:
  pushl $0
c01021fa:	6a 00                	push   $0x0
  pushl $76
c01021fc:	6a 4c                	push   $0x4c
  jmp __alltraps
c01021fe:	e9 37 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102203 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102203:	6a 00                	push   $0x0
  pushl $77
c0102205:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102207:	e9 2e fd ff ff       	jmp    c0101f3a <__alltraps>

c010220c <vector78>:
.globl vector78
vector78:
  pushl $0
c010220c:	6a 00                	push   $0x0
  pushl $78
c010220e:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102210:	e9 25 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102215 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102215:	6a 00                	push   $0x0
  pushl $79
c0102217:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102219:	e9 1c fd ff ff       	jmp    c0101f3a <__alltraps>

c010221e <vector80>:
.globl vector80
vector80:
  pushl $0
c010221e:	6a 00                	push   $0x0
  pushl $80
c0102220:	6a 50                	push   $0x50
  jmp __alltraps
c0102222:	e9 13 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102227 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102227:	6a 00                	push   $0x0
  pushl $81
c0102229:	6a 51                	push   $0x51
  jmp __alltraps
c010222b:	e9 0a fd ff ff       	jmp    c0101f3a <__alltraps>

c0102230 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102230:	6a 00                	push   $0x0
  pushl $82
c0102232:	6a 52                	push   $0x52
  jmp __alltraps
c0102234:	e9 01 fd ff ff       	jmp    c0101f3a <__alltraps>

c0102239 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102239:	6a 00                	push   $0x0
  pushl $83
c010223b:	6a 53                	push   $0x53
  jmp __alltraps
c010223d:	e9 f8 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102242 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102242:	6a 00                	push   $0x0
  pushl $84
c0102244:	6a 54                	push   $0x54
  jmp __alltraps
c0102246:	e9 ef fc ff ff       	jmp    c0101f3a <__alltraps>

c010224b <vector85>:
.globl vector85
vector85:
  pushl $0
c010224b:	6a 00                	push   $0x0
  pushl $85
c010224d:	6a 55                	push   $0x55
  jmp __alltraps
c010224f:	e9 e6 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102254 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102254:	6a 00                	push   $0x0
  pushl $86
c0102256:	6a 56                	push   $0x56
  jmp __alltraps
c0102258:	e9 dd fc ff ff       	jmp    c0101f3a <__alltraps>

c010225d <vector87>:
.globl vector87
vector87:
  pushl $0
c010225d:	6a 00                	push   $0x0
  pushl $87
c010225f:	6a 57                	push   $0x57
  jmp __alltraps
c0102261:	e9 d4 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102266 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102266:	6a 00                	push   $0x0
  pushl $88
c0102268:	6a 58                	push   $0x58
  jmp __alltraps
c010226a:	e9 cb fc ff ff       	jmp    c0101f3a <__alltraps>

c010226f <vector89>:
.globl vector89
vector89:
  pushl $0
c010226f:	6a 00                	push   $0x0
  pushl $89
c0102271:	6a 59                	push   $0x59
  jmp __alltraps
c0102273:	e9 c2 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102278 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102278:	6a 00                	push   $0x0
  pushl $90
c010227a:	6a 5a                	push   $0x5a
  jmp __alltraps
c010227c:	e9 b9 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102281 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102281:	6a 00                	push   $0x0
  pushl $91
c0102283:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102285:	e9 b0 fc ff ff       	jmp    c0101f3a <__alltraps>

c010228a <vector92>:
.globl vector92
vector92:
  pushl $0
c010228a:	6a 00                	push   $0x0
  pushl $92
c010228c:	6a 5c                	push   $0x5c
  jmp __alltraps
c010228e:	e9 a7 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102293 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102293:	6a 00                	push   $0x0
  pushl $93
c0102295:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102297:	e9 9e fc ff ff       	jmp    c0101f3a <__alltraps>

c010229c <vector94>:
.globl vector94
vector94:
  pushl $0
c010229c:	6a 00                	push   $0x0
  pushl $94
c010229e:	6a 5e                	push   $0x5e
  jmp __alltraps
c01022a0:	e9 95 fc ff ff       	jmp    c0101f3a <__alltraps>

c01022a5 <vector95>:
.globl vector95
vector95:
  pushl $0
c01022a5:	6a 00                	push   $0x0
  pushl $95
c01022a7:	6a 5f                	push   $0x5f
  jmp __alltraps
c01022a9:	e9 8c fc ff ff       	jmp    c0101f3a <__alltraps>

c01022ae <vector96>:
.globl vector96
vector96:
  pushl $0
c01022ae:	6a 00                	push   $0x0
  pushl $96
c01022b0:	6a 60                	push   $0x60
  jmp __alltraps
c01022b2:	e9 83 fc ff ff       	jmp    c0101f3a <__alltraps>

c01022b7 <vector97>:
.globl vector97
vector97:
  pushl $0
c01022b7:	6a 00                	push   $0x0
  pushl $97
c01022b9:	6a 61                	push   $0x61
  jmp __alltraps
c01022bb:	e9 7a fc ff ff       	jmp    c0101f3a <__alltraps>

c01022c0 <vector98>:
.globl vector98
vector98:
  pushl $0
c01022c0:	6a 00                	push   $0x0
  pushl $98
c01022c2:	6a 62                	push   $0x62
  jmp __alltraps
c01022c4:	e9 71 fc ff ff       	jmp    c0101f3a <__alltraps>

c01022c9 <vector99>:
.globl vector99
vector99:
  pushl $0
c01022c9:	6a 00                	push   $0x0
  pushl $99
c01022cb:	6a 63                	push   $0x63
  jmp __alltraps
c01022cd:	e9 68 fc ff ff       	jmp    c0101f3a <__alltraps>

c01022d2 <vector100>:
.globl vector100
vector100:
  pushl $0
c01022d2:	6a 00                	push   $0x0
  pushl $100
c01022d4:	6a 64                	push   $0x64
  jmp __alltraps
c01022d6:	e9 5f fc ff ff       	jmp    c0101f3a <__alltraps>

c01022db <vector101>:
.globl vector101
vector101:
  pushl $0
c01022db:	6a 00                	push   $0x0
  pushl $101
c01022dd:	6a 65                	push   $0x65
  jmp __alltraps
c01022df:	e9 56 fc ff ff       	jmp    c0101f3a <__alltraps>

c01022e4 <vector102>:
.globl vector102
vector102:
  pushl $0
c01022e4:	6a 00                	push   $0x0
  pushl $102
c01022e6:	6a 66                	push   $0x66
  jmp __alltraps
c01022e8:	e9 4d fc ff ff       	jmp    c0101f3a <__alltraps>

c01022ed <vector103>:
.globl vector103
vector103:
  pushl $0
c01022ed:	6a 00                	push   $0x0
  pushl $103
c01022ef:	6a 67                	push   $0x67
  jmp __alltraps
c01022f1:	e9 44 fc ff ff       	jmp    c0101f3a <__alltraps>

c01022f6 <vector104>:
.globl vector104
vector104:
  pushl $0
c01022f6:	6a 00                	push   $0x0
  pushl $104
c01022f8:	6a 68                	push   $0x68
  jmp __alltraps
c01022fa:	e9 3b fc ff ff       	jmp    c0101f3a <__alltraps>

c01022ff <vector105>:
.globl vector105
vector105:
  pushl $0
c01022ff:	6a 00                	push   $0x0
  pushl $105
c0102301:	6a 69                	push   $0x69
  jmp __alltraps
c0102303:	e9 32 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102308 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102308:	6a 00                	push   $0x0
  pushl $106
c010230a:	6a 6a                	push   $0x6a
  jmp __alltraps
c010230c:	e9 29 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102311 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102311:	6a 00                	push   $0x0
  pushl $107
c0102313:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102315:	e9 20 fc ff ff       	jmp    c0101f3a <__alltraps>

c010231a <vector108>:
.globl vector108
vector108:
  pushl $0
c010231a:	6a 00                	push   $0x0
  pushl $108
c010231c:	6a 6c                	push   $0x6c
  jmp __alltraps
c010231e:	e9 17 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102323 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102323:	6a 00                	push   $0x0
  pushl $109
c0102325:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102327:	e9 0e fc ff ff       	jmp    c0101f3a <__alltraps>

c010232c <vector110>:
.globl vector110
vector110:
  pushl $0
c010232c:	6a 00                	push   $0x0
  pushl $110
c010232e:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102330:	e9 05 fc ff ff       	jmp    c0101f3a <__alltraps>

c0102335 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102335:	6a 00                	push   $0x0
  pushl $111
c0102337:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102339:	e9 fc fb ff ff       	jmp    c0101f3a <__alltraps>

c010233e <vector112>:
.globl vector112
vector112:
  pushl $0
c010233e:	6a 00                	push   $0x0
  pushl $112
c0102340:	6a 70                	push   $0x70
  jmp __alltraps
c0102342:	e9 f3 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102347 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102347:	6a 00                	push   $0x0
  pushl $113
c0102349:	6a 71                	push   $0x71
  jmp __alltraps
c010234b:	e9 ea fb ff ff       	jmp    c0101f3a <__alltraps>

c0102350 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102350:	6a 00                	push   $0x0
  pushl $114
c0102352:	6a 72                	push   $0x72
  jmp __alltraps
c0102354:	e9 e1 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102359 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102359:	6a 00                	push   $0x0
  pushl $115
c010235b:	6a 73                	push   $0x73
  jmp __alltraps
c010235d:	e9 d8 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102362 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102362:	6a 00                	push   $0x0
  pushl $116
c0102364:	6a 74                	push   $0x74
  jmp __alltraps
c0102366:	e9 cf fb ff ff       	jmp    c0101f3a <__alltraps>

c010236b <vector117>:
.globl vector117
vector117:
  pushl $0
c010236b:	6a 00                	push   $0x0
  pushl $117
c010236d:	6a 75                	push   $0x75
  jmp __alltraps
c010236f:	e9 c6 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102374 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102374:	6a 00                	push   $0x0
  pushl $118
c0102376:	6a 76                	push   $0x76
  jmp __alltraps
c0102378:	e9 bd fb ff ff       	jmp    c0101f3a <__alltraps>

c010237d <vector119>:
.globl vector119
vector119:
  pushl $0
c010237d:	6a 00                	push   $0x0
  pushl $119
c010237f:	6a 77                	push   $0x77
  jmp __alltraps
c0102381:	e9 b4 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102386 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102386:	6a 00                	push   $0x0
  pushl $120
c0102388:	6a 78                	push   $0x78
  jmp __alltraps
c010238a:	e9 ab fb ff ff       	jmp    c0101f3a <__alltraps>

c010238f <vector121>:
.globl vector121
vector121:
  pushl $0
c010238f:	6a 00                	push   $0x0
  pushl $121
c0102391:	6a 79                	push   $0x79
  jmp __alltraps
c0102393:	e9 a2 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102398 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102398:	6a 00                	push   $0x0
  pushl $122
c010239a:	6a 7a                	push   $0x7a
  jmp __alltraps
c010239c:	e9 99 fb ff ff       	jmp    c0101f3a <__alltraps>

c01023a1 <vector123>:
.globl vector123
vector123:
  pushl $0
c01023a1:	6a 00                	push   $0x0
  pushl $123
c01023a3:	6a 7b                	push   $0x7b
  jmp __alltraps
c01023a5:	e9 90 fb ff ff       	jmp    c0101f3a <__alltraps>

c01023aa <vector124>:
.globl vector124
vector124:
  pushl $0
c01023aa:	6a 00                	push   $0x0
  pushl $124
c01023ac:	6a 7c                	push   $0x7c
  jmp __alltraps
c01023ae:	e9 87 fb ff ff       	jmp    c0101f3a <__alltraps>

c01023b3 <vector125>:
.globl vector125
vector125:
  pushl $0
c01023b3:	6a 00                	push   $0x0
  pushl $125
c01023b5:	6a 7d                	push   $0x7d
  jmp __alltraps
c01023b7:	e9 7e fb ff ff       	jmp    c0101f3a <__alltraps>

c01023bc <vector126>:
.globl vector126
vector126:
  pushl $0
c01023bc:	6a 00                	push   $0x0
  pushl $126
c01023be:	6a 7e                	push   $0x7e
  jmp __alltraps
c01023c0:	e9 75 fb ff ff       	jmp    c0101f3a <__alltraps>

c01023c5 <vector127>:
.globl vector127
vector127:
  pushl $0
c01023c5:	6a 00                	push   $0x0
  pushl $127
c01023c7:	6a 7f                	push   $0x7f
  jmp __alltraps
c01023c9:	e9 6c fb ff ff       	jmp    c0101f3a <__alltraps>

c01023ce <vector128>:
.globl vector128
vector128:
  pushl $0
c01023ce:	6a 00                	push   $0x0
  pushl $128
c01023d0:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01023d5:	e9 60 fb ff ff       	jmp    c0101f3a <__alltraps>

c01023da <vector129>:
.globl vector129
vector129:
  pushl $0
c01023da:	6a 00                	push   $0x0
  pushl $129
c01023dc:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01023e1:	e9 54 fb ff ff       	jmp    c0101f3a <__alltraps>

c01023e6 <vector130>:
.globl vector130
vector130:
  pushl $0
c01023e6:	6a 00                	push   $0x0
  pushl $130
c01023e8:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01023ed:	e9 48 fb ff ff       	jmp    c0101f3a <__alltraps>

c01023f2 <vector131>:
.globl vector131
vector131:
  pushl $0
c01023f2:	6a 00                	push   $0x0
  pushl $131
c01023f4:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01023f9:	e9 3c fb ff ff       	jmp    c0101f3a <__alltraps>

c01023fe <vector132>:
.globl vector132
vector132:
  pushl $0
c01023fe:	6a 00                	push   $0x0
  pushl $132
c0102400:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102405:	e9 30 fb ff ff       	jmp    c0101f3a <__alltraps>

c010240a <vector133>:
.globl vector133
vector133:
  pushl $0
c010240a:	6a 00                	push   $0x0
  pushl $133
c010240c:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102411:	e9 24 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102416 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102416:	6a 00                	push   $0x0
  pushl $134
c0102418:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010241d:	e9 18 fb ff ff       	jmp    c0101f3a <__alltraps>

c0102422 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102422:	6a 00                	push   $0x0
  pushl $135
c0102424:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102429:	e9 0c fb ff ff       	jmp    c0101f3a <__alltraps>

c010242e <vector136>:
.globl vector136
vector136:
  pushl $0
c010242e:	6a 00                	push   $0x0
  pushl $136
c0102430:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102435:	e9 00 fb ff ff       	jmp    c0101f3a <__alltraps>

c010243a <vector137>:
.globl vector137
vector137:
  pushl $0
c010243a:	6a 00                	push   $0x0
  pushl $137
c010243c:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102441:	e9 f4 fa ff ff       	jmp    c0101f3a <__alltraps>

c0102446 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102446:	6a 00                	push   $0x0
  pushl $138
c0102448:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010244d:	e9 e8 fa ff ff       	jmp    c0101f3a <__alltraps>

c0102452 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102452:	6a 00                	push   $0x0
  pushl $139
c0102454:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102459:	e9 dc fa ff ff       	jmp    c0101f3a <__alltraps>

c010245e <vector140>:
.globl vector140
vector140:
  pushl $0
c010245e:	6a 00                	push   $0x0
  pushl $140
c0102460:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102465:	e9 d0 fa ff ff       	jmp    c0101f3a <__alltraps>

c010246a <vector141>:
.globl vector141
vector141:
  pushl $0
c010246a:	6a 00                	push   $0x0
  pushl $141
c010246c:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102471:	e9 c4 fa ff ff       	jmp    c0101f3a <__alltraps>

c0102476 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102476:	6a 00                	push   $0x0
  pushl $142
c0102478:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010247d:	e9 b8 fa ff ff       	jmp    c0101f3a <__alltraps>

c0102482 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102482:	6a 00                	push   $0x0
  pushl $143
c0102484:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102489:	e9 ac fa ff ff       	jmp    c0101f3a <__alltraps>

c010248e <vector144>:
.globl vector144
vector144:
  pushl $0
c010248e:	6a 00                	push   $0x0
  pushl $144
c0102490:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102495:	e9 a0 fa ff ff       	jmp    c0101f3a <__alltraps>

c010249a <vector145>:
.globl vector145
vector145:
  pushl $0
c010249a:	6a 00                	push   $0x0
  pushl $145
c010249c:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01024a1:	e9 94 fa ff ff       	jmp    c0101f3a <__alltraps>

c01024a6 <vector146>:
.globl vector146
vector146:
  pushl $0
c01024a6:	6a 00                	push   $0x0
  pushl $146
c01024a8:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01024ad:	e9 88 fa ff ff       	jmp    c0101f3a <__alltraps>

c01024b2 <vector147>:
.globl vector147
vector147:
  pushl $0
c01024b2:	6a 00                	push   $0x0
  pushl $147
c01024b4:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01024b9:	e9 7c fa ff ff       	jmp    c0101f3a <__alltraps>

c01024be <vector148>:
.globl vector148
vector148:
  pushl $0
c01024be:	6a 00                	push   $0x0
  pushl $148
c01024c0:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01024c5:	e9 70 fa ff ff       	jmp    c0101f3a <__alltraps>

c01024ca <vector149>:
.globl vector149
vector149:
  pushl $0
c01024ca:	6a 00                	push   $0x0
  pushl $149
c01024cc:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01024d1:	e9 64 fa ff ff       	jmp    c0101f3a <__alltraps>

c01024d6 <vector150>:
.globl vector150
vector150:
  pushl $0
c01024d6:	6a 00                	push   $0x0
  pushl $150
c01024d8:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01024dd:	e9 58 fa ff ff       	jmp    c0101f3a <__alltraps>

c01024e2 <vector151>:
.globl vector151
vector151:
  pushl $0
c01024e2:	6a 00                	push   $0x0
  pushl $151
c01024e4:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01024e9:	e9 4c fa ff ff       	jmp    c0101f3a <__alltraps>

c01024ee <vector152>:
.globl vector152
vector152:
  pushl $0
c01024ee:	6a 00                	push   $0x0
  pushl $152
c01024f0:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01024f5:	e9 40 fa ff ff       	jmp    c0101f3a <__alltraps>

c01024fa <vector153>:
.globl vector153
vector153:
  pushl $0
c01024fa:	6a 00                	push   $0x0
  pushl $153
c01024fc:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102501:	e9 34 fa ff ff       	jmp    c0101f3a <__alltraps>

c0102506 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102506:	6a 00                	push   $0x0
  pushl $154
c0102508:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010250d:	e9 28 fa ff ff       	jmp    c0101f3a <__alltraps>

c0102512 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102512:	6a 00                	push   $0x0
  pushl $155
c0102514:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102519:	e9 1c fa ff ff       	jmp    c0101f3a <__alltraps>

c010251e <vector156>:
.globl vector156
vector156:
  pushl $0
c010251e:	6a 00                	push   $0x0
  pushl $156
c0102520:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102525:	e9 10 fa ff ff       	jmp    c0101f3a <__alltraps>

c010252a <vector157>:
.globl vector157
vector157:
  pushl $0
c010252a:	6a 00                	push   $0x0
  pushl $157
c010252c:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102531:	e9 04 fa ff ff       	jmp    c0101f3a <__alltraps>

c0102536 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102536:	6a 00                	push   $0x0
  pushl $158
c0102538:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010253d:	e9 f8 f9 ff ff       	jmp    c0101f3a <__alltraps>

c0102542 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102542:	6a 00                	push   $0x0
  pushl $159
c0102544:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102549:	e9 ec f9 ff ff       	jmp    c0101f3a <__alltraps>

c010254e <vector160>:
.globl vector160
vector160:
  pushl $0
c010254e:	6a 00                	push   $0x0
  pushl $160
c0102550:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102555:	e9 e0 f9 ff ff       	jmp    c0101f3a <__alltraps>

c010255a <vector161>:
.globl vector161
vector161:
  pushl $0
c010255a:	6a 00                	push   $0x0
  pushl $161
c010255c:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102561:	e9 d4 f9 ff ff       	jmp    c0101f3a <__alltraps>

c0102566 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102566:	6a 00                	push   $0x0
  pushl $162
c0102568:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010256d:	e9 c8 f9 ff ff       	jmp    c0101f3a <__alltraps>

c0102572 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102572:	6a 00                	push   $0x0
  pushl $163
c0102574:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102579:	e9 bc f9 ff ff       	jmp    c0101f3a <__alltraps>

c010257e <vector164>:
.globl vector164
vector164:
  pushl $0
c010257e:	6a 00                	push   $0x0
  pushl $164
c0102580:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102585:	e9 b0 f9 ff ff       	jmp    c0101f3a <__alltraps>

c010258a <vector165>:
.globl vector165
vector165:
  pushl $0
c010258a:	6a 00                	push   $0x0
  pushl $165
c010258c:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102591:	e9 a4 f9 ff ff       	jmp    c0101f3a <__alltraps>

c0102596 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102596:	6a 00                	push   $0x0
  pushl $166
c0102598:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010259d:	e9 98 f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025a2 <vector167>:
.globl vector167
vector167:
  pushl $0
c01025a2:	6a 00                	push   $0x0
  pushl $167
c01025a4:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01025a9:	e9 8c f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025ae <vector168>:
.globl vector168
vector168:
  pushl $0
c01025ae:	6a 00                	push   $0x0
  pushl $168
c01025b0:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01025b5:	e9 80 f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025ba <vector169>:
.globl vector169
vector169:
  pushl $0
c01025ba:	6a 00                	push   $0x0
  pushl $169
c01025bc:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01025c1:	e9 74 f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025c6 <vector170>:
.globl vector170
vector170:
  pushl $0
c01025c6:	6a 00                	push   $0x0
  pushl $170
c01025c8:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01025cd:	e9 68 f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025d2 <vector171>:
.globl vector171
vector171:
  pushl $0
c01025d2:	6a 00                	push   $0x0
  pushl $171
c01025d4:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01025d9:	e9 5c f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025de <vector172>:
.globl vector172
vector172:
  pushl $0
c01025de:	6a 00                	push   $0x0
  pushl $172
c01025e0:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01025e5:	e9 50 f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025ea <vector173>:
.globl vector173
vector173:
  pushl $0
c01025ea:	6a 00                	push   $0x0
  pushl $173
c01025ec:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01025f1:	e9 44 f9 ff ff       	jmp    c0101f3a <__alltraps>

c01025f6 <vector174>:
.globl vector174
vector174:
  pushl $0
c01025f6:	6a 00                	push   $0x0
  pushl $174
c01025f8:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01025fd:	e9 38 f9 ff ff       	jmp    c0101f3a <__alltraps>

c0102602 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102602:	6a 00                	push   $0x0
  pushl $175
c0102604:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102609:	e9 2c f9 ff ff       	jmp    c0101f3a <__alltraps>

c010260e <vector176>:
.globl vector176
vector176:
  pushl $0
c010260e:	6a 00                	push   $0x0
  pushl $176
c0102610:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102615:	e9 20 f9 ff ff       	jmp    c0101f3a <__alltraps>

c010261a <vector177>:
.globl vector177
vector177:
  pushl $0
c010261a:	6a 00                	push   $0x0
  pushl $177
c010261c:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102621:	e9 14 f9 ff ff       	jmp    c0101f3a <__alltraps>

c0102626 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102626:	6a 00                	push   $0x0
  pushl $178
c0102628:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010262d:	e9 08 f9 ff ff       	jmp    c0101f3a <__alltraps>

c0102632 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102632:	6a 00                	push   $0x0
  pushl $179
c0102634:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102639:	e9 fc f8 ff ff       	jmp    c0101f3a <__alltraps>

c010263e <vector180>:
.globl vector180
vector180:
  pushl $0
c010263e:	6a 00                	push   $0x0
  pushl $180
c0102640:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102645:	e9 f0 f8 ff ff       	jmp    c0101f3a <__alltraps>

c010264a <vector181>:
.globl vector181
vector181:
  pushl $0
c010264a:	6a 00                	push   $0x0
  pushl $181
c010264c:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102651:	e9 e4 f8 ff ff       	jmp    c0101f3a <__alltraps>

c0102656 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102656:	6a 00                	push   $0x0
  pushl $182
c0102658:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010265d:	e9 d8 f8 ff ff       	jmp    c0101f3a <__alltraps>

c0102662 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102662:	6a 00                	push   $0x0
  pushl $183
c0102664:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102669:	e9 cc f8 ff ff       	jmp    c0101f3a <__alltraps>

c010266e <vector184>:
.globl vector184
vector184:
  pushl $0
c010266e:	6a 00                	push   $0x0
  pushl $184
c0102670:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102675:	e9 c0 f8 ff ff       	jmp    c0101f3a <__alltraps>

c010267a <vector185>:
.globl vector185
vector185:
  pushl $0
c010267a:	6a 00                	push   $0x0
  pushl $185
c010267c:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102681:	e9 b4 f8 ff ff       	jmp    c0101f3a <__alltraps>

c0102686 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102686:	6a 00                	push   $0x0
  pushl $186
c0102688:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010268d:	e9 a8 f8 ff ff       	jmp    c0101f3a <__alltraps>

c0102692 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102692:	6a 00                	push   $0x0
  pushl $187
c0102694:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102699:	e9 9c f8 ff ff       	jmp    c0101f3a <__alltraps>

c010269e <vector188>:
.globl vector188
vector188:
  pushl $0
c010269e:	6a 00                	push   $0x0
  pushl $188
c01026a0:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01026a5:	e9 90 f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026aa <vector189>:
.globl vector189
vector189:
  pushl $0
c01026aa:	6a 00                	push   $0x0
  pushl $189
c01026ac:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01026b1:	e9 84 f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026b6 <vector190>:
.globl vector190
vector190:
  pushl $0
c01026b6:	6a 00                	push   $0x0
  pushl $190
c01026b8:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01026bd:	e9 78 f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026c2 <vector191>:
.globl vector191
vector191:
  pushl $0
c01026c2:	6a 00                	push   $0x0
  pushl $191
c01026c4:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01026c9:	e9 6c f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026ce <vector192>:
.globl vector192
vector192:
  pushl $0
c01026ce:	6a 00                	push   $0x0
  pushl $192
c01026d0:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01026d5:	e9 60 f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026da <vector193>:
.globl vector193
vector193:
  pushl $0
c01026da:	6a 00                	push   $0x0
  pushl $193
c01026dc:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01026e1:	e9 54 f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026e6 <vector194>:
.globl vector194
vector194:
  pushl $0
c01026e6:	6a 00                	push   $0x0
  pushl $194
c01026e8:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01026ed:	e9 48 f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026f2 <vector195>:
.globl vector195
vector195:
  pushl $0
c01026f2:	6a 00                	push   $0x0
  pushl $195
c01026f4:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01026f9:	e9 3c f8 ff ff       	jmp    c0101f3a <__alltraps>

c01026fe <vector196>:
.globl vector196
vector196:
  pushl $0
c01026fe:	6a 00                	push   $0x0
  pushl $196
c0102700:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102705:	e9 30 f8 ff ff       	jmp    c0101f3a <__alltraps>

c010270a <vector197>:
.globl vector197
vector197:
  pushl $0
c010270a:	6a 00                	push   $0x0
  pushl $197
c010270c:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102711:	e9 24 f8 ff ff       	jmp    c0101f3a <__alltraps>

c0102716 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102716:	6a 00                	push   $0x0
  pushl $198
c0102718:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010271d:	e9 18 f8 ff ff       	jmp    c0101f3a <__alltraps>

c0102722 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102722:	6a 00                	push   $0x0
  pushl $199
c0102724:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102729:	e9 0c f8 ff ff       	jmp    c0101f3a <__alltraps>

c010272e <vector200>:
.globl vector200
vector200:
  pushl $0
c010272e:	6a 00                	push   $0x0
  pushl $200
c0102730:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102735:	e9 00 f8 ff ff       	jmp    c0101f3a <__alltraps>

c010273a <vector201>:
.globl vector201
vector201:
  pushl $0
c010273a:	6a 00                	push   $0x0
  pushl $201
c010273c:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102741:	e9 f4 f7 ff ff       	jmp    c0101f3a <__alltraps>

c0102746 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102746:	6a 00                	push   $0x0
  pushl $202
c0102748:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010274d:	e9 e8 f7 ff ff       	jmp    c0101f3a <__alltraps>

c0102752 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102752:	6a 00                	push   $0x0
  pushl $203
c0102754:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102759:	e9 dc f7 ff ff       	jmp    c0101f3a <__alltraps>

c010275e <vector204>:
.globl vector204
vector204:
  pushl $0
c010275e:	6a 00                	push   $0x0
  pushl $204
c0102760:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102765:	e9 d0 f7 ff ff       	jmp    c0101f3a <__alltraps>

c010276a <vector205>:
.globl vector205
vector205:
  pushl $0
c010276a:	6a 00                	push   $0x0
  pushl $205
c010276c:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102771:	e9 c4 f7 ff ff       	jmp    c0101f3a <__alltraps>

c0102776 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102776:	6a 00                	push   $0x0
  pushl $206
c0102778:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010277d:	e9 b8 f7 ff ff       	jmp    c0101f3a <__alltraps>

c0102782 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102782:	6a 00                	push   $0x0
  pushl $207
c0102784:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102789:	e9 ac f7 ff ff       	jmp    c0101f3a <__alltraps>

c010278e <vector208>:
.globl vector208
vector208:
  pushl $0
c010278e:	6a 00                	push   $0x0
  pushl $208
c0102790:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102795:	e9 a0 f7 ff ff       	jmp    c0101f3a <__alltraps>

c010279a <vector209>:
.globl vector209
vector209:
  pushl $0
c010279a:	6a 00                	push   $0x0
  pushl $209
c010279c:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01027a1:	e9 94 f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027a6 <vector210>:
.globl vector210
vector210:
  pushl $0
c01027a6:	6a 00                	push   $0x0
  pushl $210
c01027a8:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01027ad:	e9 88 f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027b2 <vector211>:
.globl vector211
vector211:
  pushl $0
c01027b2:	6a 00                	push   $0x0
  pushl $211
c01027b4:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01027b9:	e9 7c f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027be <vector212>:
.globl vector212
vector212:
  pushl $0
c01027be:	6a 00                	push   $0x0
  pushl $212
c01027c0:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01027c5:	e9 70 f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027ca <vector213>:
.globl vector213
vector213:
  pushl $0
c01027ca:	6a 00                	push   $0x0
  pushl $213
c01027cc:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01027d1:	e9 64 f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027d6 <vector214>:
.globl vector214
vector214:
  pushl $0
c01027d6:	6a 00                	push   $0x0
  pushl $214
c01027d8:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01027dd:	e9 58 f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027e2 <vector215>:
.globl vector215
vector215:
  pushl $0
c01027e2:	6a 00                	push   $0x0
  pushl $215
c01027e4:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01027e9:	e9 4c f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027ee <vector216>:
.globl vector216
vector216:
  pushl $0
c01027ee:	6a 00                	push   $0x0
  pushl $216
c01027f0:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01027f5:	e9 40 f7 ff ff       	jmp    c0101f3a <__alltraps>

c01027fa <vector217>:
.globl vector217
vector217:
  pushl $0
c01027fa:	6a 00                	push   $0x0
  pushl $217
c01027fc:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102801:	e9 34 f7 ff ff       	jmp    c0101f3a <__alltraps>

c0102806 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102806:	6a 00                	push   $0x0
  pushl $218
c0102808:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010280d:	e9 28 f7 ff ff       	jmp    c0101f3a <__alltraps>

c0102812 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102812:	6a 00                	push   $0x0
  pushl $219
c0102814:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102819:	e9 1c f7 ff ff       	jmp    c0101f3a <__alltraps>

c010281e <vector220>:
.globl vector220
vector220:
  pushl $0
c010281e:	6a 00                	push   $0x0
  pushl $220
c0102820:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102825:	e9 10 f7 ff ff       	jmp    c0101f3a <__alltraps>

c010282a <vector221>:
.globl vector221
vector221:
  pushl $0
c010282a:	6a 00                	push   $0x0
  pushl $221
c010282c:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102831:	e9 04 f7 ff ff       	jmp    c0101f3a <__alltraps>

c0102836 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102836:	6a 00                	push   $0x0
  pushl $222
c0102838:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010283d:	e9 f8 f6 ff ff       	jmp    c0101f3a <__alltraps>

c0102842 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102842:	6a 00                	push   $0x0
  pushl $223
c0102844:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102849:	e9 ec f6 ff ff       	jmp    c0101f3a <__alltraps>

c010284e <vector224>:
.globl vector224
vector224:
  pushl $0
c010284e:	6a 00                	push   $0x0
  pushl $224
c0102850:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102855:	e9 e0 f6 ff ff       	jmp    c0101f3a <__alltraps>

c010285a <vector225>:
.globl vector225
vector225:
  pushl $0
c010285a:	6a 00                	push   $0x0
  pushl $225
c010285c:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102861:	e9 d4 f6 ff ff       	jmp    c0101f3a <__alltraps>

c0102866 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102866:	6a 00                	push   $0x0
  pushl $226
c0102868:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010286d:	e9 c8 f6 ff ff       	jmp    c0101f3a <__alltraps>

c0102872 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102872:	6a 00                	push   $0x0
  pushl $227
c0102874:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102879:	e9 bc f6 ff ff       	jmp    c0101f3a <__alltraps>

c010287e <vector228>:
.globl vector228
vector228:
  pushl $0
c010287e:	6a 00                	push   $0x0
  pushl $228
c0102880:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102885:	e9 b0 f6 ff ff       	jmp    c0101f3a <__alltraps>

c010288a <vector229>:
.globl vector229
vector229:
  pushl $0
c010288a:	6a 00                	push   $0x0
  pushl $229
c010288c:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102891:	e9 a4 f6 ff ff       	jmp    c0101f3a <__alltraps>

c0102896 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102896:	6a 00                	push   $0x0
  pushl $230
c0102898:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010289d:	e9 98 f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028a2 <vector231>:
.globl vector231
vector231:
  pushl $0
c01028a2:	6a 00                	push   $0x0
  pushl $231
c01028a4:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01028a9:	e9 8c f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028ae <vector232>:
.globl vector232
vector232:
  pushl $0
c01028ae:	6a 00                	push   $0x0
  pushl $232
c01028b0:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01028b5:	e9 80 f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028ba <vector233>:
.globl vector233
vector233:
  pushl $0
c01028ba:	6a 00                	push   $0x0
  pushl $233
c01028bc:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01028c1:	e9 74 f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028c6 <vector234>:
.globl vector234
vector234:
  pushl $0
c01028c6:	6a 00                	push   $0x0
  pushl $234
c01028c8:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01028cd:	e9 68 f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028d2 <vector235>:
.globl vector235
vector235:
  pushl $0
c01028d2:	6a 00                	push   $0x0
  pushl $235
c01028d4:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01028d9:	e9 5c f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028de <vector236>:
.globl vector236
vector236:
  pushl $0
c01028de:	6a 00                	push   $0x0
  pushl $236
c01028e0:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01028e5:	e9 50 f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028ea <vector237>:
.globl vector237
vector237:
  pushl $0
c01028ea:	6a 00                	push   $0x0
  pushl $237
c01028ec:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01028f1:	e9 44 f6 ff ff       	jmp    c0101f3a <__alltraps>

c01028f6 <vector238>:
.globl vector238
vector238:
  pushl $0
c01028f6:	6a 00                	push   $0x0
  pushl $238
c01028f8:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01028fd:	e9 38 f6 ff ff       	jmp    c0101f3a <__alltraps>

c0102902 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102902:	6a 00                	push   $0x0
  pushl $239
c0102904:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102909:	e9 2c f6 ff ff       	jmp    c0101f3a <__alltraps>

c010290e <vector240>:
.globl vector240
vector240:
  pushl $0
c010290e:	6a 00                	push   $0x0
  pushl $240
c0102910:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102915:	e9 20 f6 ff ff       	jmp    c0101f3a <__alltraps>

c010291a <vector241>:
.globl vector241
vector241:
  pushl $0
c010291a:	6a 00                	push   $0x0
  pushl $241
c010291c:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102921:	e9 14 f6 ff ff       	jmp    c0101f3a <__alltraps>

c0102926 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102926:	6a 00                	push   $0x0
  pushl $242
c0102928:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010292d:	e9 08 f6 ff ff       	jmp    c0101f3a <__alltraps>

c0102932 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102932:	6a 00                	push   $0x0
  pushl $243
c0102934:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102939:	e9 fc f5 ff ff       	jmp    c0101f3a <__alltraps>

c010293e <vector244>:
.globl vector244
vector244:
  pushl $0
c010293e:	6a 00                	push   $0x0
  pushl $244
c0102940:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102945:	e9 f0 f5 ff ff       	jmp    c0101f3a <__alltraps>

c010294a <vector245>:
.globl vector245
vector245:
  pushl $0
c010294a:	6a 00                	push   $0x0
  pushl $245
c010294c:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102951:	e9 e4 f5 ff ff       	jmp    c0101f3a <__alltraps>

c0102956 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102956:	6a 00                	push   $0x0
  pushl $246
c0102958:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010295d:	e9 d8 f5 ff ff       	jmp    c0101f3a <__alltraps>

c0102962 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102962:	6a 00                	push   $0x0
  pushl $247
c0102964:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102969:	e9 cc f5 ff ff       	jmp    c0101f3a <__alltraps>

c010296e <vector248>:
.globl vector248
vector248:
  pushl $0
c010296e:	6a 00                	push   $0x0
  pushl $248
c0102970:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102975:	e9 c0 f5 ff ff       	jmp    c0101f3a <__alltraps>

c010297a <vector249>:
.globl vector249
vector249:
  pushl $0
c010297a:	6a 00                	push   $0x0
  pushl $249
c010297c:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102981:	e9 b4 f5 ff ff       	jmp    c0101f3a <__alltraps>

c0102986 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102986:	6a 00                	push   $0x0
  pushl $250
c0102988:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010298d:	e9 a8 f5 ff ff       	jmp    c0101f3a <__alltraps>

c0102992 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102992:	6a 00                	push   $0x0
  pushl $251
c0102994:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102999:	e9 9c f5 ff ff       	jmp    c0101f3a <__alltraps>

c010299e <vector252>:
.globl vector252
vector252:
  pushl $0
c010299e:	6a 00                	push   $0x0
  pushl $252
c01029a0:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01029a5:	e9 90 f5 ff ff       	jmp    c0101f3a <__alltraps>

c01029aa <vector253>:
.globl vector253
vector253:
  pushl $0
c01029aa:	6a 00                	push   $0x0
  pushl $253
c01029ac:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01029b1:	e9 84 f5 ff ff       	jmp    c0101f3a <__alltraps>

c01029b6 <vector254>:
.globl vector254
vector254:
  pushl $0
c01029b6:	6a 00                	push   $0x0
  pushl $254
c01029b8:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01029bd:	e9 78 f5 ff ff       	jmp    c0101f3a <__alltraps>

c01029c2 <vector255>:
.globl vector255
vector255:
  pushl $0
c01029c2:	6a 00                	push   $0x0
  pushl $255
c01029c4:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01029c9:	e9 6c f5 ff ff       	jmp    c0101f3a <__alltraps>

c01029ce <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01029ce:	55                   	push   %ebp
c01029cf:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01029d1:	8b 55 08             	mov    0x8(%ebp),%edx
c01029d4:	a1 a4 cf 11 c0       	mov    0xc011cfa4,%eax
c01029d9:	29 c2                	sub    %eax,%edx
c01029db:	89 d0                	mov    %edx,%eax
c01029dd:	c1 f8 02             	sar    $0x2,%eax
c01029e0:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01029e6:	5d                   	pop    %ebp
c01029e7:	c3                   	ret    

c01029e8 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01029e8:	55                   	push   %ebp
c01029e9:	89 e5                	mov    %esp,%ebp
c01029eb:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01029ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f1:	89 04 24             	mov    %eax,(%esp)
c01029f4:	e8 d5 ff ff ff       	call   c01029ce <page2ppn>
c01029f9:	c1 e0 0c             	shl    $0xc,%eax
}
c01029fc:	c9                   	leave  
c01029fd:	c3                   	ret    

c01029fe <set_page_ref>:
page_ref(struct Page *page) {
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
c01029fe:	55                   	push   %ebp
c01029ff:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102a01:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a04:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102a07:	89 10                	mov    %edx,(%eax)
}
c0102a09:	5d                   	pop    %ebp
c0102a0a:	c3                   	ret    

c0102a0b <buddy_init>:
static unsigned int max_pages; // maintained by buddy
static struct Page* buddy_allocatable_base;

#define max(a, b) ((a) > (b) ? (a) : (b))
 
static void buddy_init(void) {}
c0102a0b:	55                   	push   %ebp
c0102a0c:	89 e5                	mov    %esp,%ebp
c0102a0e:	5d                   	pop    %ebp
c0102a0f:	c3                   	ret    

c0102a10 <buddy_init_memmap>:

static void buddy_init_memmap(struct Page *base, size_t n) {
c0102a10:	55                   	push   %ebp
c0102a11:	89 e5                	mov    %esp,%ebp
c0102a13:	83 ec 48             	sub    $0x48,%esp
	int i=0;
c0102a16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    assert(n > 0);
c0102a1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102a21:	75 24                	jne    c0102a47 <buddy_init_memmap+0x37>
c0102a23:	c7 44 24 0c 30 73 10 	movl   $0xc0107330,0xc(%esp)
c0102a2a:	c0 
c0102a2b:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0102a32:	c0 
c0102a33:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c0102a3a:	00 
c0102a3b:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0102a42:	e8 a0 e2 ff ff       	call   c0100ce7 <__panic>
    // calc buddy alloc page number
    max_pages = 1;
c0102a47:	c7 05 88 ce 11 c0 01 	movl   $0x1,0xc011ce88
c0102a4e:	00 00 00 
    for (i = 1; i < BUDDY_MAX_DEPTH; ++i, max_pages <<= 1)
c0102a51:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0102a58:	eb 28                	jmp    c0102a82 <buddy_init_memmap+0x72>
        if (max_pages + (max_pages >> 9) >= n)
c0102a5a:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102a5f:	c1 e8 09             	shr    $0x9,%eax
c0102a62:	89 c2                	mov    %eax,%edx
c0102a64:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102a69:	01 d0                	add    %edx,%eax
c0102a6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0102a6e:	72 02                	jb     c0102a72 <buddy_init_memmap+0x62>
            break;
c0102a70:	eb 16                	jmp    c0102a88 <buddy_init_memmap+0x78>
static void buddy_init_memmap(struct Page *base, size_t n) {
	int i=0;
    assert(n > 0);
    // calc buddy alloc page number
    max_pages = 1;
    for (i = 1; i < BUDDY_MAX_DEPTH; ++i, max_pages <<= 1)
c0102a72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102a76:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102a7b:	01 c0                	add    %eax,%eax
c0102a7d:	a3 88 ce 11 c0       	mov    %eax,0xc011ce88
c0102a82:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
c0102a86:	7e d2                	jle    c0102a5a <buddy_init_memmap+0x4a>
        if (max_pages + (max_pages >> 9) >= n)
            break;
    max_pages >>= 1;
c0102a88:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102a8d:	d1 e8                	shr    %eax
c0102a8f:	a3 88 ce 11 c0       	mov    %eax,0xc011ce88
    buddy_page_num = (max_pages >> 9) + 1;
c0102a94:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102a99:	c1 e8 09             	shr    $0x9,%eax
c0102a9c:	83 c0 01             	add    $0x1,%eax
c0102a9f:	a3 84 ce 11 c0       	mov    %eax,0xc011ce84
    cprintf("buddy init: total %d, use %d, free %d\n", n, buddy_page_num, max_pages);
c0102aa4:	8b 15 88 ce 11 c0    	mov    0xc011ce88,%edx
c0102aaa:	a1 84 ce 11 c0       	mov    0xc011ce84,%eax
c0102aaf:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0102ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102aba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102abe:	c7 04 24 60 73 10 c0 	movl   $0xc0107360,(%esp)
c0102ac5:	e8 89 d8 ff ff       	call   c0100353 <cprintf>
    // set these pages to reserved
    for (i = 0; i < buddy_page_num; ++i)
c0102aca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102ad1:	eb 2e                	jmp    c0102b01 <buddy_init_memmap+0xf1>
        SetPageReserved(base + i);
c0102ad3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102ad6:	89 d0                	mov    %edx,%eax
c0102ad8:	c1 e0 02             	shl    $0x2,%eax
c0102adb:	01 d0                	add    %edx,%eax
c0102add:	c1 e0 02             	shl    $0x2,%eax
c0102ae0:	89 c2                	mov    %eax,%edx
c0102ae2:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ae5:	01 d0                	add    %edx,%eax
c0102ae7:	83 c0 04             	add    $0x4,%eax
c0102aea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0102af1:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102af4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102af7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102afa:	0f ab 10             	bts    %edx,(%eax)
            break;
    max_pages >>= 1;
    buddy_page_num = (max_pages >> 9) + 1;
    cprintf("buddy init: total %d, use %d, free %d\n", n, buddy_page_num, max_pages);
    // set these pages to reserved
    for (i = 0; i < buddy_page_num; ++i)
c0102afd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b04:	a1 84 ce 11 c0       	mov    0xc011ce84,%eax
c0102b09:	39 c2                	cmp    %eax,%edx
c0102b0b:	72 c6                	jb     c0102ad3 <buddy_init_memmap+0xc3>
        SetPageReserved(base + i);
    // set non-buddy page to be allocatable
    buddy_allocatable_base = base + buddy_page_num;
c0102b0d:	8b 15 84 ce 11 c0    	mov    0xc011ce84,%edx
c0102b13:	89 d0                	mov    %edx,%eax
c0102b15:	c1 e0 02             	shl    $0x2,%eax
c0102b18:	01 d0                	add    %edx,%eax
c0102b1a:	c1 e0 02             	shl    $0x2,%eax
c0102b1d:	89 c2                	mov    %eax,%edx
c0102b1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b22:	01 d0                	add    %edx,%eax
c0102b24:	a3 8c ce 11 c0       	mov    %eax,0xc011ce8c
	struct Page* p;
    for (p = buddy_allocatable_base; p != base + n; ++p) {
c0102b29:	a1 8c ce 11 c0       	mov    0xc011ce8c,%eax
c0102b2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102b31:	eb 49                	jmp    c0102b7c <buddy_init_memmap+0x16c>
        ClearPageReserved(p);
c0102b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b36:	83 c0 04             	add    $0x4,%eax
c0102b39:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102b40:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b43:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b46:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102b49:	0f b3 10             	btr    %edx,(%eax)
        SetPageProperty(p);
c0102b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b4f:	83 c0 04             	add    $0x4,%eax
c0102b52:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102b59:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b5f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b62:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);
c0102b65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102b6c:	00 
c0102b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b70:	89 04 24             	mov    %eax,(%esp)
c0102b73:	e8 86 fe ff ff       	call   c01029fe <set_page_ref>
    for (i = 0; i < buddy_page_num; ++i)
        SetPageReserved(base + i);
    // set non-buddy page to be allocatable
    buddy_allocatable_base = base + buddy_page_num;
	struct Page* p;
    for (p = buddy_allocatable_base; p != base + n; ++p) {
c0102b78:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
c0102b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b7f:	89 d0                	mov    %edx,%eax
c0102b81:	c1 e0 02             	shl    $0x2,%eax
c0102b84:	01 d0                	add    %edx,%eax
c0102b86:	c1 e0 02             	shl    $0x2,%eax
c0102b89:	89 c2                	mov    %eax,%edx
c0102b8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b8e:	01 d0                	add    %edx,%eax
c0102b90:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102b93:	75 9e                	jne    c0102b33 <buddy_init_memmap+0x123>
        ClearPageReserved(p);
        SetPageProperty(p);
        set_page_ref(p, 0);
    }
    // init buddy page
    buddy_page = (unsigned int*)KADDR(page2pa(base));
c0102b95:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b98:	89 04 24             	mov    %eax,(%esp)
c0102b9b:	e8 48 fe ff ff       	call   c01029e8 <page2pa>
c0102ba0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ba6:	c1 e8 0c             	shr    $0xc,%eax
c0102ba9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0102bac:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0102bb1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0102bb4:	72 23                	jb     c0102bd9 <buddy_init_memmap+0x1c9>
c0102bb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102bbd:	c7 44 24 08 88 73 10 	movl   $0xc0107388,0x8(%esp)
c0102bc4:	c0 
c0102bc5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0102bcc:	00 
c0102bcd:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0102bd4:	e8 0e e1 ff ff       	call   c0100ce7 <__panic>
c0102bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bdc:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0102be1:	a3 80 ce 11 c0       	mov    %eax,0xc011ce80
    for (i = max_pages; i < max_pages << 1; ++i)
c0102be6:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102bee:	eb 17                	jmp    c0102c07 <buddy_init_memmap+0x1f7>
        buddy_page[i] = 1;
c0102bf0:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102bf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102bf8:	c1 e2 02             	shl    $0x2,%edx
c0102bfb:	01 d0                	add    %edx,%eax
c0102bfd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        SetPageProperty(p);
        set_page_ref(p, 0);
    }
    // init buddy page
    buddy_page = (unsigned int*)KADDR(page2pa(base));
    for (i = max_pages; i < max_pages << 1; ++i)
c0102c03:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c0a:	8b 15 88 ce 11 c0    	mov    0xc011ce88,%edx
c0102c10:	01 d2                	add    %edx,%edx
c0102c12:	39 d0                	cmp    %edx,%eax
c0102c14:	72 da                	jb     c0102bf0 <buddy_init_memmap+0x1e0>
        buddy_page[i] = 1;
    for (i = max_pages - 1; i > 0; --i)
c0102c16:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102c1b:	83 e8 01             	sub    $0x1,%eax
c0102c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102c21:	eb 27                	jmp    c0102c4a <buddy_init_memmap+0x23a>
        buddy_page[i] = buddy_page[i << 1] << 1;
c0102c23:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102c28:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102c2b:	c1 e2 02             	shl    $0x2,%edx
c0102c2e:	01 d0                	add    %edx,%eax
c0102c30:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c0102c36:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0102c39:	01 c9                	add    %ecx,%ecx
c0102c3b:	c1 e1 02             	shl    $0x2,%ecx
c0102c3e:	01 ca                	add    %ecx,%edx
c0102c40:	8b 12                	mov    (%edx),%edx
c0102c42:	01 d2                	add    %edx,%edx
c0102c44:	89 10                	mov    %edx,(%eax)
    }
    // init buddy page
    buddy_page = (unsigned int*)KADDR(page2pa(base));
    for (i = max_pages; i < max_pages << 1; ++i)
        buddy_page[i] = 1;
    for (i = max_pages - 1; i > 0; --i)
c0102c46:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0102c4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102c4e:	7f d3                	jg     c0102c23 <buddy_init_memmap+0x213>
        buddy_page[i] = buddy_page[i << 1] << 1;
}
c0102c50:	c9                   	leave  
c0102c51:	c3                   	ret    

c0102c52 <buddy_alloc_pages>:

static struct Page* buddy_alloc_pages(size_t n) {
c0102c52:	55                   	push   %ebp
c0102c53:	89 e5                	mov    %esp,%ebp
c0102c55:	53                   	push   %ebx
c0102c56:	83 ec 34             	sub    $0x34,%esp
    assert(n > 0);
c0102c59:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102c5d:	75 24                	jne    c0102c83 <buddy_alloc_pages+0x31>
c0102c5f:	c7 44 24 0c 30 73 10 	movl   $0xc0107330,0xc(%esp)
c0102c66:	c0 
c0102c67:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0102c6e:	c0 
c0102c6f:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
c0102c76:	00 
c0102c77:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0102c7e:	e8 64 e0 ff ff       	call   c0100ce7 <__panic>
    if (n > buddy_page[1]) return NULL;
c0102c83:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102c88:	83 c0 04             	add    $0x4,%eax
c0102c8b:	8b 00                	mov    (%eax),%eax
c0102c8d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102c90:	73 0a                	jae    c0102c9c <buddy_alloc_pages+0x4a>
c0102c92:	b8 00 00 00 00       	mov    $0x0,%eax
c0102c97:	e9 2c 01 00 00       	jmp    c0102dc8 <buddy_alloc_pages+0x176>
    unsigned int index = 1, size = max_pages;
c0102c9c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0102ca3:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (; size >= n; size >>= 1) {
c0102cab:	eb 44                	jmp    c0102cf1 <buddy_alloc_pages+0x9f>
        if (buddy_page[index << 1] >= n) index <<= 1;
c0102cad:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102cb5:	c1 e2 03             	shl    $0x3,%edx
c0102cb8:	01 d0                	add    %edx,%eax
c0102cba:	8b 00                	mov    (%eax),%eax
c0102cbc:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102cbf:	72 05                	jb     c0102cc6 <buddy_alloc_pages+0x74>
c0102cc1:	d1 65 f4             	shll   -0xc(%ebp)
c0102cc4:	eb 28                	jmp    c0102cee <buddy_alloc_pages+0x9c>
        else if (buddy_page[index << 1 | 1] >= n) index = index << 1 | 1;
c0102cc6:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102ccb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102cce:	01 d2                	add    %edx,%edx
c0102cd0:	83 ca 01             	or     $0x1,%edx
c0102cd3:	c1 e2 02             	shl    $0x2,%edx
c0102cd6:	01 d0                	add    %edx,%eax
c0102cd8:	8b 00                	mov    (%eax),%eax
c0102cda:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102cdd:	72 0d                	jb     c0102cec <buddy_alloc_pages+0x9a>
c0102cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ce2:	01 c0                	add    %eax,%eax
c0102ce4:	83 c8 01             	or     $0x1,%eax
c0102ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102cea:	eb 02                	jmp    c0102cee <buddy_alloc_pages+0x9c>
        else break;
c0102cec:	eb 0b                	jmp    c0102cf9 <buddy_alloc_pages+0xa7>

static struct Page* buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > buddy_page[1]) return NULL;
    unsigned int index = 1, size = max_pages;
    for (; size >= n; size >>= 1) {
c0102cee:	d1 6d f0             	shrl   -0x10(%ebp)
c0102cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cf4:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102cf7:	73 b4                	jae    c0102cad <buddy_alloc_pages+0x5b>
        if (buddy_page[index << 1] >= n) index <<= 1;
        else if (buddy_page[index << 1 | 1] >= n) index = index << 1 | 1;
        else break;
    }
    buddy_page[index] = 0;
c0102cf9:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102d01:	c1 e2 02             	shl    $0x2,%edx
c0102d04:	01 d0                	add    %edx,%eax
c0102d06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    // allocate all pages under node[index]
    struct Page* new_page = buddy_allocatable_base + index * size - max_pages;
c0102d0c:	8b 0d 8c ce 11 c0    	mov    0xc011ce8c,%ecx
c0102d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d15:	0f af 45 f0          	imul   -0x10(%ebp),%eax
c0102d19:	89 c2                	mov    %eax,%edx
c0102d1b:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102d20:	29 c2                	sub    %eax,%edx
c0102d22:	89 d0                	mov    %edx,%eax
c0102d24:	c1 e0 02             	shl    $0x2,%eax
c0102d27:	01 d0                	add    %edx,%eax
c0102d29:	c1 e0 02             	shl    $0x2,%eax
c0102d2c:	01 c8                	add    %ecx,%eax
c0102d2e:	89 45 e8             	mov    %eax,-0x18(%ebp)
	struct Page* p;
    for (p = new_page; p != new_page + size; ++p)
c0102d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d34:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102d37:	eb 30                	jmp    c0102d69 <buddy_alloc_pages+0x117>
        set_page_ref(p, 0), ClearPageProperty(p);
c0102d39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102d40:	00 
c0102d41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102d44:	89 04 24             	mov    %eax,(%esp)
c0102d47:	e8 b2 fc ff ff       	call   c01029fe <set_page_ref>
c0102d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102d4f:	83 c0 04             	add    $0x4,%eax
c0102d52:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102d59:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d62:	0f b3 10             	btr    %edx,(%eax)
    }
    buddy_page[index] = 0;
    // allocate all pages under node[index]
    struct Page* new_page = buddy_allocatable_base + index * size - max_pages;
	struct Page* p;
    for (p = new_page; p != new_page + size; ++p)
c0102d65:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
c0102d69:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102d6c:	89 d0                	mov    %edx,%eax
c0102d6e:	c1 e0 02             	shl    $0x2,%eax
c0102d71:	01 d0                	add    %edx,%eax
c0102d73:	c1 e0 02             	shl    $0x2,%eax
c0102d76:	89 c2                	mov    %eax,%edx
c0102d78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d7b:	01 d0                	add    %edx,%eax
c0102d7d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0102d80:	75 b7                	jne    c0102d39 <buddy_alloc_pages+0xe7>
        set_page_ref(p, 0), ClearPageProperty(p);
    for (; (index >>= 1) > 0; ) // since destory continuous, use MAX instead of SUM
c0102d82:	eb 38                	jmp    c0102dbc <buddy_alloc_pages+0x16a>
        buddy_page[index] = max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
c0102d84:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102d89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102d8c:	c1 e2 02             	shl    $0x2,%edx
c0102d8f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
c0102d92:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102d97:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102d9a:	01 d2                	add    %edx,%edx
c0102d9c:	83 ca 01             	or     $0x1,%edx
c0102d9f:	c1 e2 02             	shl    $0x2,%edx
c0102da2:	01 d0                	add    %edx,%eax
c0102da4:	8b 10                	mov    (%eax),%edx
c0102da6:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102dab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c0102dae:	c1 e3 03             	shl    $0x3,%ebx
c0102db1:	01 d8                	add    %ebx,%eax
c0102db3:	8b 00                	mov    (%eax),%eax
c0102db5:	39 c2                	cmp    %eax,%edx
c0102db7:	0f 43 c2             	cmovae %edx,%eax
c0102dba:	89 01                	mov    %eax,(%ecx)
    // allocate all pages under node[index]
    struct Page* new_page = buddy_allocatable_base + index * size - max_pages;
	struct Page* p;
    for (p = new_page; p != new_page + size; ++p)
        set_page_ref(p, 0), ClearPageProperty(p);
    for (; (index >>= 1) > 0; ) // since destory continuous, use MAX instead of SUM
c0102dbc:	d1 6d f4             	shrl   -0xc(%ebp)
c0102dbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102dc3:	75 bf                	jne    c0102d84 <buddy_alloc_pages+0x132>
        buddy_page[index] = max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
    return new_page;
c0102dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0102dc8:	83 c4 34             	add    $0x34,%esp
c0102dcb:	5b                   	pop    %ebx
c0102dcc:	5d                   	pop    %ebp
c0102dcd:	c3                   	ret    

c0102dce <buddy_free_pages>:

static void buddy_free_pages(struct Page *base, size_t n) {
c0102dce:	55                   	push   %ebp
c0102dcf:	89 e5                	mov    %esp,%ebp
c0102dd1:	53                   	push   %ebx
c0102dd2:	83 ec 44             	sub    $0x44,%esp
    assert(n > 0);
c0102dd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102dd9:	75 24                	jne    c0102dff <buddy_free_pages+0x31>
c0102ddb:	c7 44 24 0c 30 73 10 	movl   $0xc0107330,0xc(%esp)
c0102de2:	c0 
c0102de3:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0102dea:	c0 
c0102deb:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
c0102df2:	00 
c0102df3:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0102dfa:	e8 e8 de ff ff       	call   c0100ce7 <__panic>
    unsigned int index = (unsigned int)(base - buddy_allocatable_base) + max_pages, size = 1;
c0102dff:	8b 55 08             	mov    0x8(%ebp),%edx
c0102e02:	a1 8c ce 11 c0       	mov    0xc011ce8c,%eax
c0102e07:	29 c2                	sub    %eax,%edx
c0102e09:	89 d0                	mov    %edx,%eax
c0102e0b:	c1 f8 02             	sar    $0x2,%eax
c0102e0e:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
c0102e14:	89 c2                	mov    %eax,%edx
c0102e16:	a1 88 ce 11 c0       	mov    0xc011ce88,%eax
c0102e1b:	01 d0                	add    %edx,%eax
c0102e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102e20:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // find first buddy node which has buddy_page[index] == 0
    for (; buddy_page[index] > 0; index >>= 1, size <<= 1);
c0102e27:	eb 06                	jmp    c0102e2f <buddy_free_pages+0x61>
c0102e29:	d1 6d f4             	shrl   -0xc(%ebp)
c0102e2c:	d1 65 f0             	shll   -0x10(%ebp)
c0102e2f:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102e34:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102e37:	c1 e2 02             	shl    $0x2,%edx
c0102e3a:	01 d0                	add    %edx,%eax
c0102e3c:	8b 00                	mov    (%eax),%eax
c0102e3e:	85 c0                	test   %eax,%eax
c0102e40:	75 e7                	jne    c0102e29 <buddy_free_pages+0x5b>
    // free all pages
	struct Page* p;
    for (p = base; p != base + n; ++p) {
c0102e42:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e45:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102e48:	e9 ac 00 00 00       	jmp    c0102ef9 <buddy_free_pages+0x12b>
        assert(!PageReserved(p) && !PageProperty(p));
c0102e4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e50:	83 c0 04             	add    $0x4,%eax
c0102e53:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0102e5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102e5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102e60:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0102e63:	0f a3 10             	bt     %edx,(%eax)
c0102e66:	19 c0                	sbb    %eax,%eax
c0102e68:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0102e6b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0102e6f:	0f 95 c0             	setne  %al
c0102e72:	0f b6 c0             	movzbl %al,%eax
c0102e75:	85 c0                	test   %eax,%eax
c0102e77:	75 2c                	jne    c0102ea5 <buddy_free_pages+0xd7>
c0102e79:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e7c:	83 c0 04             	add    $0x4,%eax
c0102e7f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0102e86:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102e89:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102e8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e8f:	0f a3 10             	bt     %edx,(%eax)
c0102e92:	19 c0                	sbb    %eax,%eax
c0102e94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
c0102e97:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0102e9b:	0f 95 c0             	setne  %al
c0102e9e:	0f b6 c0             	movzbl %al,%eax
c0102ea1:	85 c0                	test   %eax,%eax
c0102ea3:	74 24                	je     c0102ec9 <buddy_free_pages+0xfb>
c0102ea5:	c7 44 24 0c ac 73 10 	movl   $0xc01073ac,0xc(%esp)
c0102eac:	c0 
c0102ead:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0102eb4:	c0 
c0102eb5:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
c0102ebc:	00 
c0102ebd:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0102ec4:	e8 1e de ff ff       	call   c0100ce7 <__panic>
        SetPageProperty(p), set_page_ref(p, 0);
c0102ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ecc:	83 c0 04             	add    $0x4,%eax
c0102ecf:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0102ed6:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102ed9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102edc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102edf:	0f ab 10             	bts    %edx,(%eax)
c0102ee2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102ee9:	00 
c0102eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102eed:	89 04 24             	mov    %eax,(%esp)
c0102ef0:	e8 09 fb ff ff       	call   c01029fe <set_page_ref>
    unsigned int index = (unsigned int)(base - buddy_allocatable_base) + max_pages, size = 1;
    // find first buddy node which has buddy_page[index] == 0
    for (; buddy_page[index] > 0; index >>= 1, size <<= 1);
    // free all pages
	struct Page* p;
    for (p = base; p != base + n; ++p) {
c0102ef5:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
c0102ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102efc:	89 d0                	mov    %edx,%eax
c0102efe:	c1 e0 02             	shl    $0x2,%eax
c0102f01:	01 d0                	add    %edx,%eax
c0102f03:	c1 e0 02             	shl    $0x2,%eax
c0102f06:	89 c2                	mov    %eax,%edx
c0102f08:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f0b:	01 d0                	add    %edx,%eax
c0102f0d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0102f10:	0f 85 37 ff ff ff    	jne    c0102e4d <buddy_free_pages+0x7f>
        assert(!PageReserved(p) && !PageProperty(p));
        SetPageProperty(p), set_page_ref(p, 0);
    }
    // modify buddy_page
    for (buddy_page[index] = size; size <<= 1, (index >>= 1) > 0;)
c0102f16:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102f1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102f1e:	c1 e2 02             	shl    $0x2,%edx
c0102f21:	01 c2                	add    %eax,%edx
c0102f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f26:	89 02                	mov    %eax,(%edx)
c0102f28:	eb 67                	jmp    c0102f91 <buddy_free_pages+0x1c3>
        buddy_page[index] = (buddy_page[index << 1] + buddy_page[index << 1 | 1] == size) ? size : max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
c0102f2a:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102f2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102f32:	c1 e2 02             	shl    $0x2,%edx
c0102f35:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
c0102f38:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102f3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102f40:	c1 e2 03             	shl    $0x3,%edx
c0102f43:	01 d0                	add    %edx,%eax
c0102f45:	8b 10                	mov    (%eax),%edx
c0102f47:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102f4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c0102f4f:	01 db                	add    %ebx,%ebx
c0102f51:	83 cb 01             	or     $0x1,%ebx
c0102f54:	c1 e3 02             	shl    $0x2,%ebx
c0102f57:	01 d8                	add    %ebx,%eax
c0102f59:	8b 00                	mov    (%eax),%eax
c0102f5b:	01 d0                	add    %edx,%eax
c0102f5d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102f60:	74 2a                	je     c0102f8c <buddy_free_pages+0x1be>
c0102f62:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102f67:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102f6a:	01 d2                	add    %edx,%edx
c0102f6c:	83 ca 01             	or     $0x1,%edx
c0102f6f:	c1 e2 02             	shl    $0x2,%edx
c0102f72:	01 d0                	add    %edx,%eax
c0102f74:	8b 10                	mov    (%eax),%edx
c0102f76:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102f7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c0102f7e:	c1 e3 03             	shl    $0x3,%ebx
c0102f81:	01 d8                	add    %ebx,%eax
c0102f83:	8b 00                	mov    (%eax),%eax
c0102f85:	39 c2                	cmp    %eax,%edx
c0102f87:	0f 43 c2             	cmovae %edx,%eax
c0102f8a:	eb 03                	jmp    c0102f8f <buddy_free_pages+0x1c1>
c0102f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f8f:	89 01                	mov    %eax,(%ecx)
    for (p = base; p != base + n; ++p) {
        assert(!PageReserved(p) && !PageProperty(p));
        SetPageProperty(p), set_page_ref(p, 0);
    }
    // modify buddy_page
    for (buddy_page[index] = size; size <<= 1, (index >>= 1) > 0;)
c0102f91:	d1 65 f0             	shll   -0x10(%ebp)
c0102f94:	d1 6d f4             	shrl   -0xc(%ebp)
c0102f97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102f9b:	75 8d                	jne    c0102f2a <buddy_free_pages+0x15c>
        buddy_page[index] = (buddy_page[index << 1] + buddy_page[index << 1 | 1] == size) ? size : max(buddy_page[index << 1], buddy_page[index << 1 | 1]);
}
c0102f9d:	83 c4 44             	add    $0x44,%esp
c0102fa0:	5b                   	pop    %ebx
c0102fa1:	5d                   	pop    %ebp
c0102fa2:	c3                   	ret    

c0102fa3 <buddy_nr_free_pages>:

static size_t buddy_nr_free_pages(void) { return buddy_page[1]; }
c0102fa3:	55                   	push   %ebp
c0102fa4:	89 e5                	mov    %esp,%ebp
c0102fa6:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102fab:	83 c0 04             	add    $0x4,%eax
c0102fae:	8b 00                	mov    (%eax),%eax
c0102fb0:	5d                   	pop    %ebp
c0102fb1:	c3                   	ret    

c0102fb2 <buddy_check>:

static void buddy_check(void) {
c0102fb2:	55                   	push   %ebp
c0102fb3:	89 e5                	mov    %esp,%ebp
c0102fb5:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int all_pages = nr_free_pages();
c0102fbb:	e8 91 1a 00 00       	call   c0104a51 <nr_free_pages>
c0102fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page* p0, *p1, *p2, *p3;
    assert(alloc_pages(all_pages + 1) == NULL);
c0102fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fc6:	83 c0 01             	add    $0x1,%eax
c0102fc9:	89 04 24             	mov    %eax,(%esp)
c0102fcc:	e8 16 1a 00 00       	call   c01049e7 <alloc_pages>
c0102fd1:	85 c0                	test   %eax,%eax
c0102fd3:	74 24                	je     c0102ff9 <buddy_check+0x47>
c0102fd5:	c7 44 24 0c d4 73 10 	movl   $0xc01073d4,0xc(%esp)
c0102fdc:	c0 
c0102fdd:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0102fe4:	c0 
c0102fe5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0102fec:	00 
c0102fed:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0102ff4:	e8 ee dc ff ff       	call   c0100ce7 <__panic>

    p0 = alloc_pages(1);
c0102ff9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103000:	e8 e2 19 00 00       	call   c01049e7 <alloc_pages>
c0103005:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(p0 != NULL);
c0103008:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010300c:	75 24                	jne    c0103032 <buddy_check+0x80>
c010300e:	c7 44 24 0c f7 73 10 	movl   $0xc01073f7,0xc(%esp)
c0103015:	c0 
c0103016:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c010301d:	c0 
c010301e:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103025:	00 
c0103026:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c010302d:	e8 b5 dc ff ff       	call   c0100ce7 <__panic>
    p1 = alloc_pages(2);
c0103032:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103039:	e8 a9 19 00 00       	call   c01049e7 <alloc_pages>
c010303e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(p1 == p0 + 2);
c0103041:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103044:	83 c0 28             	add    $0x28,%eax
c0103047:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010304a:	74 24                	je     c0103070 <buddy_check+0xbe>
c010304c:	c7 44 24 0c 02 74 10 	movl   $0xc0107402,0xc(%esp)
c0103053:	c0 
c0103054:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c010305b:	c0 
c010305c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0103063:	00 
c0103064:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c010306b:	e8 77 dc ff ff       	call   c0100ce7 <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0));
c0103070:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103073:	83 c0 04             	add    $0x4,%eax
c0103076:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010307d:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103080:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103083:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103086:	0f a3 10             	bt     %edx,(%eax)
c0103089:	19 c0                	sbb    %eax,%eax
c010308b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010308e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103092:	0f 95 c0             	setne  %al
c0103095:	0f b6 c0             	movzbl %al,%eax
c0103098:	85 c0                	test   %eax,%eax
c010309a:	75 2c                	jne    c01030c8 <buddy_check+0x116>
c010309c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010309f:	83 c0 04             	add    $0x4,%eax
c01030a2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01030a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01030ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01030af:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01030b2:	0f a3 10             	bt     %edx,(%eax)
c01030b5:	19 c0                	sbb    %eax,%eax
c01030b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return oldbit != 0;
c01030ba:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030be:	0f 95 c0             	setne  %al
c01030c1:	0f b6 c0             	movzbl %al,%eax
c01030c4:	85 c0                	test   %eax,%eax
c01030c6:	74 24                	je     c01030ec <buddy_check+0x13a>
c01030c8:	c7 44 24 0c 10 74 10 	movl   $0xc0107410,0xc(%esp)
c01030cf:	c0 
c01030d0:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c01030d7:	c0 
c01030d8:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c01030df:	00 
c01030e0:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c01030e7:	e8 fb db ff ff       	call   c0100ce7 <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
c01030ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030ef:	83 c0 04             	add    $0x4,%eax
c01030f2:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c01030f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01030fc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01030ff:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103102:	0f a3 10             	bt     %edx,(%eax)
c0103105:	19 c0                	sbb    %eax,%eax
c0103107:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
c010310a:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010310e:	0f 95 c0             	setne  %al
c0103111:	0f b6 c0             	movzbl %al,%eax
c0103114:	85 c0                	test   %eax,%eax
c0103116:	75 2c                	jne    c0103144 <buddy_check+0x192>
c0103118:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010311b:	83 c0 04             	add    $0x4,%eax
c010311e:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0103125:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103128:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010312b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010312e:	0f a3 10             	bt     %edx,(%eax)
c0103131:	19 c0                	sbb    %eax,%eax
c0103133:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    return oldbit != 0;
c0103136:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
c010313a:	0f 95 c0             	setne  %al
c010313d:	0f b6 c0             	movzbl %al,%eax
c0103140:	85 c0                	test   %eax,%eax
c0103142:	74 24                	je     c0103168 <buddy_check+0x1b6>
c0103144:	c7 44 24 0c 38 74 10 	movl   $0xc0107438,0xc(%esp)
c010314b:	c0 
c010314c:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0103153:	c0 
c0103154:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010315b:	00 
c010315c:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0103163:	e8 7f db ff ff       	call   c0100ce7 <__panic>

    p2 = alloc_pages(1);
c0103168:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010316f:	e8 73 18 00 00       	call   c01049e7 <alloc_pages>
c0103174:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p2 == p0 + 1);
c0103177:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010317a:	83 c0 14             	add    $0x14,%eax
c010317d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0103180:	74 24                	je     c01031a6 <buddy_check+0x1f4>
c0103182:	c7 44 24 0c 5f 74 10 	movl   $0xc010745f,0xc(%esp)
c0103189:	c0 
c010318a:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0103191:	c0 
c0103192:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103199:	00 
c010319a:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c01031a1:	e8 41 db ff ff       	call   c0100ce7 <__panic>
    p3 = alloc_pages(2);
c01031a6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01031ad:	e8 35 18 00 00       	call   c01049e7 <alloc_pages>
c01031b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p3 == p0 + 4);
c01031b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031b8:	83 c0 50             	add    $0x50,%eax
c01031bb:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c01031be:	74 24                	je     c01031e4 <buddy_check+0x232>
c01031c0:	c7 44 24 0c 6c 74 10 	movl   $0xc010746c,0xc(%esp)
c01031c7:	c0 
c01031c8:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c01031cf:	c0 
c01031d0:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c01031d7:	00 
c01031d8:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c01031df:	e8 03 db ff ff       	call   c0100ce7 <__panic>
    assert(!PageProperty(p3) && !PageProperty(p3 + 1) && PageProperty(p3 + 2));
c01031e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01031e7:	83 c0 04             	add    $0x4,%eax
c01031ea:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01031f1:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01031f4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01031f7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01031fa:	0f a3 10             	bt     %edx,(%eax)
c01031fd:	19 c0                	sbb    %eax,%eax
c01031ff:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0103202:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0103206:	0f 95 c0             	setne  %al
c0103209:	0f b6 c0             	movzbl %al,%eax
c010320c:	85 c0                	test   %eax,%eax
c010320e:	75 5e                	jne    c010326e <buddy_check+0x2bc>
c0103210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103213:	83 c0 14             	add    $0x14,%eax
c0103216:	83 c0 04             	add    $0x4,%eax
c0103219:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0103220:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103223:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103226:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103229:	0f a3 10             	bt     %edx,(%eax)
c010322c:	19 c0                	sbb    %eax,%eax
c010322e:	89 45 9c             	mov    %eax,-0x64(%ebp)
    return oldbit != 0;
c0103231:	83 7d 9c 00          	cmpl   $0x0,-0x64(%ebp)
c0103235:	0f 95 c0             	setne  %al
c0103238:	0f b6 c0             	movzbl %al,%eax
c010323b:	85 c0                	test   %eax,%eax
c010323d:	75 2f                	jne    c010326e <buddy_check+0x2bc>
c010323f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103242:	83 c0 28             	add    $0x28,%eax
c0103245:	83 c0 04             	add    $0x4,%eax
c0103248:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
c010324f:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103252:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103255:	8b 55 98             	mov    -0x68(%ebp),%edx
c0103258:	0f a3 10             	bt     %edx,(%eax)
c010325b:	19 c0                	sbb    %eax,%eax
c010325d:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0103260:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0103264:	0f 95 c0             	setne  %al
c0103267:	0f b6 c0             	movzbl %al,%eax
c010326a:	85 c0                	test   %eax,%eax
c010326c:	75 24                	jne    c0103292 <buddy_check+0x2e0>
c010326e:	c7 44 24 0c 7c 74 10 	movl   $0xc010747c,0xc(%esp)
c0103275:	c0 
c0103276:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c010327d:	c0 
c010327e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0103285:	00 
c0103286:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c010328d:	e8 55 da ff ff       	call   c0100ce7 <__panic>

    free_pages(p1, 2);
c0103292:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103299:	00 
c010329a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010329d:	89 04 24             	mov    %eax,(%esp)
c01032a0:	e8 7a 17 00 00       	call   c0104a1f <free_pages>
    assert(PageProperty(p1) && PageProperty(p1 + 1));
c01032a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032a8:	83 c0 04             	add    $0x4,%eax
c01032ab:	c7 45 8c 01 00 00 00 	movl   $0x1,-0x74(%ebp)
c01032b2:	89 45 88             	mov    %eax,-0x78(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01032b5:	8b 45 88             	mov    -0x78(%ebp),%eax
c01032b8:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01032bb:	0f a3 10             	bt     %edx,(%eax)
c01032be:	19 c0                	sbb    %eax,%eax
c01032c0:	89 45 84             	mov    %eax,-0x7c(%ebp)
    return oldbit != 0;
c01032c3:	83 7d 84 00          	cmpl   $0x0,-0x7c(%ebp)
c01032c7:	0f 95 c0             	setne  %al
c01032ca:	0f b6 c0             	movzbl %al,%eax
c01032cd:	85 c0                	test   %eax,%eax
c01032cf:	74 3b                	je     c010330c <buddy_check+0x35a>
c01032d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032d4:	83 c0 14             	add    $0x14,%eax
c01032d7:	83 c0 04             	add    $0x4,%eax
c01032da:	c7 45 80 01 00 00 00 	movl   $0x1,-0x80(%ebp)
c01032e1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01032e7:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01032ed:	8b 55 80             	mov    -0x80(%ebp),%edx
c01032f0:	0f a3 10             	bt     %edx,(%eax)
c01032f3:	19 c0                	sbb    %eax,%eax
c01032f5:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    return oldbit != 0;
c01032fb:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
c0103302:	0f 95 c0             	setne  %al
c0103305:	0f b6 c0             	movzbl %al,%eax
c0103308:	85 c0                	test   %eax,%eax
c010330a:	75 24                	jne    c0103330 <buddy_check+0x37e>
c010330c:	c7 44 24 0c c0 74 10 	movl   $0xc01074c0,0xc(%esp)
c0103313:	c0 
c0103314:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c010331b:	c0 
c010331c:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0103323:	00 
c0103324:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c010332b:	e8 b7 d9 ff ff       	call   c0100ce7 <__panic>
    assert(p1->ref == 0);
c0103330:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103333:	8b 00                	mov    (%eax),%eax
c0103335:	85 c0                	test   %eax,%eax
c0103337:	74 24                	je     c010335d <buddy_check+0x3ab>
c0103339:	c7 44 24 0c e9 74 10 	movl   $0xc01074e9,0xc(%esp)
c0103340:	c0 
c0103341:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c0103348:	c0 
c0103349:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0103350:	00 
c0103351:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c0103358:	e8 8a d9 ff ff       	call   c0100ce7 <__panic>

    free_pages(p0, 1);
c010335d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103364:	00 
c0103365:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103368:	89 04 24             	mov    %eax,(%esp)
c010336b:	e8 af 16 00 00       	call   c0104a1f <free_pages>
    free_pages(p2, 1);
c0103370:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103377:	00 
c0103378:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010337b:	89 04 24             	mov    %eax,(%esp)
c010337e:	e8 9c 16 00 00       	call   c0104a1f <free_pages>

    p2 = alloc_pages(2);
c0103383:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010338a:	e8 58 16 00 00       	call   c01049e7 <alloc_pages>
c010338f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p2 == p0);
c0103392:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103395:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103398:	74 24                	je     c01033be <buddy_check+0x40c>
c010339a:	c7 44 24 0c f6 74 10 	movl   $0xc01074f6,0xc(%esp)
c01033a1:	c0 
c01033a2:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c01033a9:	c0 
c01033aa:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c01033b1:	00 
c01033b2:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c01033b9:	e8 29 d9 ff ff       	call   c0100ce7 <__panic>
    free_pages(p2, 2);
c01033be:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01033c5:	00 
c01033c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033c9:	89 04 24             	mov    %eax,(%esp)
c01033cc:	e8 4e 16 00 00       	call   c0104a1f <free_pages>
    assert((*(p2 + 1)).ref == 0);
c01033d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033d4:	83 c0 14             	add    $0x14,%eax
c01033d7:	8b 00                	mov    (%eax),%eax
c01033d9:	85 c0                	test   %eax,%eax
c01033db:	74 24                	je     c0103401 <buddy_check+0x44f>
c01033dd:	c7 44 24 0c ff 74 10 	movl   $0xc01074ff,0xc(%esp)
c01033e4:	c0 
c01033e5:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c01033ec:	c0 
c01033ed:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01033f4:	00 
c01033f5:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c01033fc:	e8 e6 d8 ff ff       	call   c0100ce7 <__panic>
    assert(nr_free_pages() == all_pages >> 1);
c0103401:	e8 4b 16 00 00       	call   c0104a51 <nr_free_pages>
c0103406:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103409:	d1 fa                	sar    %edx
c010340b:	39 d0                	cmp    %edx,%eax
c010340d:	74 24                	je     c0103433 <buddy_check+0x481>
c010340f:	c7 44 24 0c 14 75 10 	movl   $0xc0107514,0xc(%esp)
c0103416:	c0 
c0103417:	c7 44 24 08 36 73 10 	movl   $0xc0107336,0x8(%esp)
c010341e:	c0 
c010341f:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0103426:	00 
c0103427:	c7 04 24 4b 73 10 c0 	movl   $0xc010734b,(%esp)
c010342e:	e8 b4 d8 ff ff       	call   c0100ce7 <__panic>

    free_pages(p3, 2);
c0103433:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010343a:	00 
c010343b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010343e:	89 04 24             	mov    %eax,(%esp)
c0103441:	e8 d9 15 00 00       	call   c0104a1f <free_pages>
    p1 = alloc_pages(129);
c0103446:	c7 04 24 81 00 00 00 	movl   $0x81,(%esp)
c010344d:	e8 95 15 00 00       	call   c01049e7 <alloc_pages>
c0103452:	89 45 ec             	mov    %eax,-0x14(%ebp)
    free_pages(p1, 256);
c0103455:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010345c:	00 
c010345d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103460:	89 04 24             	mov    %eax,(%esp)
c0103463:	e8 b7 15 00 00       	call   c0104a1f <free_pages>
}
c0103468:	c9                   	leave  
c0103469:	c3                   	ret    

c010346a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010346a:	55                   	push   %ebp
c010346b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010346d:	8b 55 08             	mov    0x8(%ebp),%edx
c0103470:	a1 a4 cf 11 c0       	mov    0xc011cfa4,%eax
c0103475:	29 c2                	sub    %eax,%edx
c0103477:	89 d0                	mov    %edx,%eax
c0103479:	c1 f8 02             	sar    $0x2,%eax
c010347c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103482:	5d                   	pop    %ebp
c0103483:	c3                   	ret    

c0103484 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103484:	55                   	push   %ebp
c0103485:	89 e5                	mov    %esp,%ebp
c0103487:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010348a:	8b 45 08             	mov    0x8(%ebp),%eax
c010348d:	89 04 24             	mov    %eax,(%esp)
c0103490:	e8 d5 ff ff ff       	call   c010346a <page2ppn>
c0103495:	c1 e0 0c             	shl    $0xc,%eax
}
c0103498:	c9                   	leave  
c0103499:	c3                   	ret    

c010349a <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010349a:	55                   	push   %ebp
c010349b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010349d:	8b 45 08             	mov    0x8(%ebp),%eax
c01034a0:	8b 00                	mov    (%eax),%eax
}
c01034a2:	5d                   	pop    %ebp
c01034a3:	c3                   	ret    

c01034a4 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01034a4:	55                   	push   %ebp
c01034a5:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01034a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01034aa:	8b 55 0c             	mov    0xc(%ebp),%edx
c01034ad:	89 10                	mov    %edx,(%eax)
}
c01034af:	5d                   	pop    %ebp
c01034b0:	c3                   	ret    

c01034b1 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01034b1:	55                   	push   %ebp
c01034b2:	89 e5                	mov    %esp,%ebp
c01034b4:	83 ec 10             	sub    $0x10,%esp
c01034b7:	c7 45 fc 90 cf 11 c0 	movl   $0xc011cf90,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01034be:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01034c4:	89 50 04             	mov    %edx,0x4(%eax)
c01034c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034ca:	8b 50 04             	mov    0x4(%eax),%edx
c01034cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034d0:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01034d2:	c7 05 98 cf 11 c0 00 	movl   $0x0,0xc011cf98
c01034d9:	00 00 00 
}
c01034dc:	c9                   	leave  
c01034dd:	c3                   	ret    

c01034de <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01034de:	55                   	push   %ebp
c01034df:	89 e5                	mov    %esp,%ebp
c01034e1:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01034e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01034e8:	75 24                	jne    c010350e <default_init_memmap+0x30>
c01034ea:	c7 44 24 0c 64 75 10 	movl   $0xc0107564,0xc(%esp)
c01034f1:	c0 
c01034f2:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c01034f9:	c0 
c01034fa:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103501:	00 
c0103502:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103509:	e8 d9 d7 ff ff       	call   c0100ce7 <__panic>
    struct Page *p = base;
c010350e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103511:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103514:	eb 7d                	jmp    c0103593 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0103516:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103519:	83 c0 04             	add    $0x4,%eax
c010351c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103523:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103526:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103529:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010352c:	0f a3 10             	bt     %edx,(%eax)
c010352f:	19 c0                	sbb    %eax,%eax
c0103531:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103534:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103538:	0f 95 c0             	setne  %al
c010353b:	0f b6 c0             	movzbl %al,%eax
c010353e:	85 c0                	test   %eax,%eax
c0103540:	75 24                	jne    c0103566 <default_init_memmap+0x88>
c0103542:	c7 44 24 0c 95 75 10 	movl   $0xc0107595,0xc(%esp)
c0103549:	c0 
c010354a:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103551:	c0 
c0103552:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103559:	00 
c010355a:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103561:	e8 81 d7 ff ff       	call   c0100ce7 <__panic>
        p->flags = p->property = 0;
c0103566:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103569:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103570:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103573:	8b 50 08             	mov    0x8(%eax),%edx
c0103576:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103579:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010357c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103583:	00 
c0103584:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103587:	89 04 24             	mov    %eax,(%esp)
c010358a:	e8 15 ff ff ff       	call   c01034a4 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010358f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0103593:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103596:	89 d0                	mov    %edx,%eax
c0103598:	c1 e0 02             	shl    $0x2,%eax
c010359b:	01 d0                	add    %edx,%eax
c010359d:	c1 e0 02             	shl    $0x2,%eax
c01035a0:	89 c2                	mov    %eax,%edx
c01035a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01035a5:	01 d0                	add    %edx,%eax
c01035a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01035aa:	0f 85 66 ff ff ff    	jne    c0103516 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01035b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01035b3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01035b6:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01035b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01035bc:	83 c0 04             	add    $0x4,%eax
c01035bf:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01035c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01035cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01035cf:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01035d2:	8b 15 98 cf 11 c0    	mov    0xc011cf98,%edx
c01035d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035db:	01 d0                	add    %edx,%eax
c01035dd:	a3 98 cf 11 c0       	mov    %eax,0xc011cf98
    list_add_before(&free_list, &(base->page_link));
c01035e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01035e5:	83 c0 0c             	add    $0xc,%eax
c01035e8:	c7 45 dc 90 cf 11 c0 	movl   $0xc011cf90,-0x24(%ebp)
c01035ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01035f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01035f5:	8b 00                	mov    (%eax),%eax
c01035f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01035fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01035fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103600:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103603:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103606:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103609:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010360c:	89 10                	mov    %edx,(%eax)
c010360e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103611:	8b 10                	mov    (%eax),%edx
c0103613:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103616:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103619:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010361c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010361f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103622:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103625:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103628:	89 10                	mov    %edx,(%eax)
}
c010362a:	c9                   	leave  
c010362b:	c3                   	ret    

c010362c <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c010362c:	55                   	push   %ebp
c010362d:	89 e5                	mov    %esp,%ebp
c010362f:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103632:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103636:	75 24                	jne    c010365c <default_alloc_pages+0x30>
c0103638:	c7 44 24 0c 64 75 10 	movl   $0xc0107564,0xc(%esp)
c010363f:	c0 
c0103640:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103647:	c0 
c0103648:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c010364f:	00 
c0103650:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103657:	e8 8b d6 ff ff       	call   c0100ce7 <__panic>
    if (n > nr_free) {
c010365c:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
c0103661:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103664:	73 0a                	jae    c0103670 <default_alloc_pages+0x44>
        return NULL;
c0103666:	b8 00 00 00 00       	mov    $0x0,%eax
c010366b:	e9 3d 01 00 00       	jmp    c01037ad <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c0103670:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0103677:	c7 45 f0 90 cf 11 c0 	movl   $0xc011cf90,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010367e:	eb 1c                	jmp    c010369c <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103680:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103683:	83 e8 0c             	sub    $0xc,%eax
c0103686:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0103689:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010368c:	8b 40 08             	mov    0x8(%eax),%eax
c010368f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103692:	72 08                	jb     c010369c <default_alloc_pages+0x70>
            page = p;
c0103694:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010369a:	eb 18                	jmp    c01036b4 <default_alloc_pages+0x88>
c010369c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010369f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01036a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036a5:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01036a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036ab:	81 7d f0 90 cf 11 c0 	cmpl   $0xc011cf90,-0x10(%ebp)
c01036b2:	75 cc                	jne    c0103680 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c01036b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01036b8:	0f 84 ec 00 00 00    	je     c01037aa <default_alloc_pages+0x17e>
        if (page->property > n) {
c01036be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036c1:	8b 40 08             	mov    0x8(%eax),%eax
c01036c4:	3b 45 08             	cmp    0x8(%ebp),%eax
c01036c7:	0f 86 8c 00 00 00    	jbe    c0103759 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
c01036cd:	8b 55 08             	mov    0x8(%ebp),%edx
c01036d0:	89 d0                	mov    %edx,%eax
c01036d2:	c1 e0 02             	shl    $0x2,%eax
c01036d5:	01 d0                	add    %edx,%eax
c01036d7:	c1 e0 02             	shl    $0x2,%eax
c01036da:	89 c2                	mov    %eax,%edx
c01036dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036df:	01 d0                	add    %edx,%eax
c01036e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
			SetPageProperty(p);
c01036e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036e7:	83 c0 04             	add    $0x4,%eax
c01036ea:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01036f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01036f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01036f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01036fa:	0f ab 10             	bts    %edx,(%eax)
            p->property = page->property - n;
c01036fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103700:	8b 40 08             	mov    0x8(%eax),%eax
c0103703:	2b 45 08             	sub    0x8(%ebp),%eax
c0103706:	89 c2                	mov    %eax,%edx
c0103708:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010370b:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c010370e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103711:	83 c0 0c             	add    $0xc,%eax
c0103714:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103717:	83 c2 0c             	add    $0xc,%edx
c010371a:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010371d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103720:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103723:	8b 40 04             	mov    0x4(%eax),%eax
c0103726:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103729:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010372c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010372f:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103732:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103735:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103738:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010373b:	89 10                	mov    %edx,(%eax)
c010373d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103740:	8b 10                	mov    (%eax),%edx
c0103742:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103745:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103748:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010374b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010374e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103751:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103754:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103757:	89 10                	mov    %edx,(%eax)
    }
	list_del(&(page->page_link));
c0103759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010375c:	83 c0 0c             	add    $0xc,%eax
c010375f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103762:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103765:	8b 40 04             	mov    0x4(%eax),%eax
c0103768:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010376b:	8b 12                	mov    (%edx),%edx
c010376d:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0103770:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103773:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103776:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103779:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010377c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010377f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103782:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0103784:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
c0103789:	2b 45 08             	sub    0x8(%ebp),%eax
c010378c:	a3 98 cf 11 c0       	mov    %eax,0xc011cf98
        ClearPageProperty(page);
c0103791:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103794:	83 c0 04             	add    $0x4,%eax
c0103797:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010379e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037a1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01037a4:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01037a7:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01037aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01037ad:	c9                   	leave  
c01037ae:	c3                   	ret    

c01037af <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01037af:	55                   	push   %ebp
c01037b0:	89 e5                	mov    %esp,%ebp
c01037b2:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01037b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01037bc:	75 24                	jne    c01037e2 <default_free_pages+0x33>
c01037be:	c7 44 24 0c 64 75 10 	movl   $0xc0107564,0xc(%esp)
c01037c5:	c0 
c01037c6:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c01037cd:	c0 
c01037ce:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c01037d5:	00 
c01037d6:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c01037dd:	e8 05 d5 ff ff       	call   c0100ce7 <__panic>
    struct Page *p = base;
c01037e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01037e8:	e9 9d 00 00 00       	jmp    c010388a <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01037ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037f0:	83 c0 04             	add    $0x4,%eax
c01037f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01037fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103800:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103803:	0f a3 10             	bt     %edx,(%eax)
c0103806:	19 c0                	sbb    %eax,%eax
c0103808:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010380b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010380f:	0f 95 c0             	setne  %al
c0103812:	0f b6 c0             	movzbl %al,%eax
c0103815:	85 c0                	test   %eax,%eax
c0103817:	75 2c                	jne    c0103845 <default_free_pages+0x96>
c0103819:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010381c:	83 c0 04             	add    $0x4,%eax
c010381f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0103826:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103829:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010382c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010382f:	0f a3 10             	bt     %edx,(%eax)
c0103832:	19 c0                	sbb    %eax,%eax
c0103834:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0103837:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010383b:	0f 95 c0             	setne  %al
c010383e:	0f b6 c0             	movzbl %al,%eax
c0103841:	85 c0                	test   %eax,%eax
c0103843:	74 24                	je     c0103869 <default_free_pages+0xba>
c0103845:	c7 44 24 0c a8 75 10 	movl   $0xc01075a8,0xc(%esp)
c010384c:	c0 
c010384d:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103854:	c0 
c0103855:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010385c:	00 
c010385d:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103864:	e8 7e d4 ff ff       	call   c0100ce7 <__panic>
        p->flags = 0;
c0103869:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010386c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103873:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010387a:	00 
c010387b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010387e:	89 04 24             	mov    %eax,(%esp)
c0103881:	e8 1e fc ff ff       	call   c01034a4 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103886:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010388a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010388d:	89 d0                	mov    %edx,%eax
c010388f:	c1 e0 02             	shl    $0x2,%eax
c0103892:	01 d0                	add    %edx,%eax
c0103894:	c1 e0 02             	shl    $0x2,%eax
c0103897:	89 c2                	mov    %eax,%edx
c0103899:	8b 45 08             	mov    0x8(%ebp),%eax
c010389c:	01 d0                	add    %edx,%eax
c010389e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01038a1:	0f 85 46 ff ff ff    	jne    c01037ed <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01038a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01038aa:	8b 55 0c             	mov    0xc(%ebp),%edx
c01038ad:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01038b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01038b3:	83 c0 04             	add    $0x4,%eax
c01038b6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01038bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01038c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038c6:	0f ab 10             	bts    %edx,(%eax)
c01038c9:	c7 45 cc 90 cf 11 c0 	movl   $0xc011cf90,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01038d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038d3:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01038d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01038d9:	e9 08 01 00 00       	jmp    c01039e6 <default_free_pages+0x237>
        p = le2page(le, page_link);
c01038de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038e1:	83 e8 0c             	sub    $0xc,%eax
c01038e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01038e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01038ed:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038f0:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01038f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c01038f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f9:	8b 50 08             	mov    0x8(%eax),%edx
c01038fc:	89 d0                	mov    %edx,%eax
c01038fe:	c1 e0 02             	shl    $0x2,%eax
c0103901:	01 d0                	add    %edx,%eax
c0103903:	c1 e0 02             	shl    $0x2,%eax
c0103906:	89 c2                	mov    %eax,%edx
c0103908:	8b 45 08             	mov    0x8(%ebp),%eax
c010390b:	01 d0                	add    %edx,%eax
c010390d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103910:	75 5a                	jne    c010396c <default_free_pages+0x1bd>
            base->property += p->property;
c0103912:	8b 45 08             	mov    0x8(%ebp),%eax
c0103915:	8b 50 08             	mov    0x8(%eax),%edx
c0103918:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010391b:	8b 40 08             	mov    0x8(%eax),%eax
c010391e:	01 c2                	add    %eax,%edx
c0103920:	8b 45 08             	mov    0x8(%ebp),%eax
c0103923:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103926:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103929:	83 c0 04             	add    $0x4,%eax
c010392c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103933:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103936:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103939:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010393c:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c010393f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103942:	83 c0 0c             	add    $0xc,%eax
c0103945:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103948:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010394b:	8b 40 04             	mov    0x4(%eax),%eax
c010394e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103951:	8b 12                	mov    (%edx),%edx
c0103953:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0103956:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103959:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010395c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010395f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103962:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103965:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103968:	89 10                	mov    %edx,(%eax)
c010396a:	eb 7a                	jmp    c01039e6 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c010396c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010396f:	8b 50 08             	mov    0x8(%eax),%edx
c0103972:	89 d0                	mov    %edx,%eax
c0103974:	c1 e0 02             	shl    $0x2,%eax
c0103977:	01 d0                	add    %edx,%eax
c0103979:	c1 e0 02             	shl    $0x2,%eax
c010397c:	89 c2                	mov    %eax,%edx
c010397e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103981:	01 d0                	add    %edx,%eax
c0103983:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103986:	75 5e                	jne    c01039e6 <default_free_pages+0x237>
            p->property += base->property;
c0103988:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010398b:	8b 50 08             	mov    0x8(%eax),%edx
c010398e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103991:	8b 40 08             	mov    0x8(%eax),%eax
c0103994:	01 c2                	add    %eax,%edx
c0103996:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103999:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c010399c:	8b 45 08             	mov    0x8(%ebp),%eax
c010399f:	83 c0 04             	add    $0x4,%eax
c01039a2:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01039a9:	89 45 ac             	mov    %eax,-0x54(%ebp)
c01039ac:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01039af:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01039b2:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c01039b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039b8:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01039bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039be:	83 c0 0c             	add    $0xc,%eax
c01039c1:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01039c4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01039c7:	8b 40 04             	mov    0x4(%eax),%eax
c01039ca:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01039cd:	8b 12                	mov    (%edx),%edx
c01039cf:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01039d2:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01039d5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01039d8:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01039db:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01039de:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01039e1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01039e4:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c01039e6:	81 7d f0 90 cf 11 c0 	cmpl   $0xc011cf90,-0x10(%ebp)
c01039ed:	0f 85 eb fe ff ff    	jne    c01038de <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c01039f3:	8b 15 98 cf 11 c0    	mov    0xc011cf98,%edx
c01039f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039fc:	01 d0                	add    %edx,%eax
c01039fe:	a3 98 cf 11 c0       	mov    %eax,0xc011cf98
c0103a03:	c7 45 9c 90 cf 11 c0 	movl   $0xc011cf90,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103a0a:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103a0d:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0103a10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103a13:	eb 76                	jmp    c0103a8b <default_free_pages+0x2dc>
        p = le2page(le, page_link);
c0103a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a18:	83 e8 0c             	sub    $0xc,%eax
c0103a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0103a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a21:	8b 50 08             	mov    0x8(%eax),%edx
c0103a24:	89 d0                	mov    %edx,%eax
c0103a26:	c1 e0 02             	shl    $0x2,%eax
c0103a29:	01 d0                	add    %edx,%eax
c0103a2b:	c1 e0 02             	shl    $0x2,%eax
c0103a2e:	89 c2                	mov    %eax,%edx
c0103a30:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a33:	01 d0                	add    %edx,%eax
c0103a35:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a38:	77 42                	ja     c0103a7c <default_free_pages+0x2cd>
            assert(base + base->property != p);
c0103a3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a3d:	8b 50 08             	mov    0x8(%eax),%edx
c0103a40:	89 d0                	mov    %edx,%eax
c0103a42:	c1 e0 02             	shl    $0x2,%eax
c0103a45:	01 d0                	add    %edx,%eax
c0103a47:	c1 e0 02             	shl    $0x2,%eax
c0103a4a:	89 c2                	mov    %eax,%edx
c0103a4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a4f:	01 d0                	add    %edx,%eax
c0103a51:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a54:	75 24                	jne    c0103a7a <default_free_pages+0x2cb>
c0103a56:	c7 44 24 0c cd 75 10 	movl   $0xc01075cd,0xc(%esp)
c0103a5d:	c0 
c0103a5e:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103a65:	c0 
c0103a66:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0103a6d:	00 
c0103a6e:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103a75:	e8 6d d2 ff ff       	call   c0100ce7 <__panic>
            break;
c0103a7a:	eb 18                	jmp    c0103a94 <default_free_pages+0x2e5>
c0103a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a7f:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103a82:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103a85:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0103a88:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0103a8b:	81 7d f0 90 cf 11 c0 	cmpl   $0xc011cf90,-0x10(%ebp)
c0103a92:	75 81                	jne    c0103a15 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0103a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a97:	8d 50 0c             	lea    0xc(%eax),%edx
c0103a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a9d:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103aa0:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103aa3:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103aa6:	8b 00                	mov    (%eax),%eax
c0103aa8:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103aab:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103aae:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103ab1:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103ab4:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103ab7:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103aba:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103abd:	89 10                	mov    %edx,(%eax)
c0103abf:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103ac2:	8b 10                	mov    (%eax),%edx
c0103ac4:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103ac7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103aca:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103acd:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103ad0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103ad3:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103ad6:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103ad9:	89 10                	mov    %edx,(%eax)
}
c0103adb:	c9                   	leave  
c0103adc:	c3                   	ret    

c0103add <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103add:	55                   	push   %ebp
c0103ade:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103ae0:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
}
c0103ae5:	5d                   	pop    %ebp
c0103ae6:	c3                   	ret    

c0103ae7 <basic_check>:

static void
basic_check(void) {
c0103ae7:	55                   	push   %ebp
c0103ae8:	89 e5                	mov    %esp,%ebp
c0103aea:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103aed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103af7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103b00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b07:	e8 db 0e 00 00       	call   c01049e7 <alloc_pages>
c0103b0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103b13:	75 24                	jne    c0103b39 <basic_check+0x52>
c0103b15:	c7 44 24 0c e8 75 10 	movl   $0xc01075e8,0xc(%esp)
c0103b1c:	c0 
c0103b1d:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103b24:	c0 
c0103b25:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0103b2c:	00 
c0103b2d:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103b34:	e8 ae d1 ff ff       	call   c0100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103b39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b40:	e8 a2 0e 00 00       	call   c01049e7 <alloc_pages>
c0103b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103b4c:	75 24                	jne    c0103b72 <basic_check+0x8b>
c0103b4e:	c7 44 24 0c 04 76 10 	movl   $0xc0107604,0xc(%esp)
c0103b55:	c0 
c0103b56:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103b5d:	c0 
c0103b5e:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103b65:	00 
c0103b66:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103b6d:	e8 75 d1 ff ff       	call   c0100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103b72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b79:	e8 69 0e 00 00       	call   c01049e7 <alloc_pages>
c0103b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b85:	75 24                	jne    c0103bab <basic_check+0xc4>
c0103b87:	c7 44 24 0c 20 76 10 	movl   $0xc0107620,0xc(%esp)
c0103b8e:	c0 
c0103b8f:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103b96:	c0 
c0103b97:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0103b9e:	00 
c0103b9f:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103ba6:	e8 3c d1 ff ff       	call   c0100ce7 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103bb1:	74 10                	je     c0103bc3 <basic_check+0xdc>
c0103bb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bb6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103bb9:	74 08                	je     c0103bc3 <basic_check+0xdc>
c0103bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bbe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103bc1:	75 24                	jne    c0103be7 <basic_check+0x100>
c0103bc3:	c7 44 24 0c 3c 76 10 	movl   $0xc010763c,0xc(%esp)
c0103bca:	c0 
c0103bcb:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103bd2:	c0 
c0103bd3:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103bda:	00 
c0103bdb:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103be2:	e8 00 d1 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bea:	89 04 24             	mov    %eax,(%esp)
c0103bed:	e8 a8 f8 ff ff       	call   c010349a <page_ref>
c0103bf2:	85 c0                	test   %eax,%eax
c0103bf4:	75 1e                	jne    c0103c14 <basic_check+0x12d>
c0103bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bf9:	89 04 24             	mov    %eax,(%esp)
c0103bfc:	e8 99 f8 ff ff       	call   c010349a <page_ref>
c0103c01:	85 c0                	test   %eax,%eax
c0103c03:	75 0f                	jne    c0103c14 <basic_check+0x12d>
c0103c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c08:	89 04 24             	mov    %eax,(%esp)
c0103c0b:	e8 8a f8 ff ff       	call   c010349a <page_ref>
c0103c10:	85 c0                	test   %eax,%eax
c0103c12:	74 24                	je     c0103c38 <basic_check+0x151>
c0103c14:	c7 44 24 0c 60 76 10 	movl   $0xc0107660,0xc(%esp)
c0103c1b:	c0 
c0103c1c:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103c23:	c0 
c0103c24:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103c2b:	00 
c0103c2c:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103c33:	e8 af d0 ff ff       	call   c0100ce7 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c3b:	89 04 24             	mov    %eax,(%esp)
c0103c3e:	e8 41 f8 ff ff       	call   c0103484 <page2pa>
c0103c43:	8b 15 a0 ce 11 c0    	mov    0xc011cea0,%edx
c0103c49:	c1 e2 0c             	shl    $0xc,%edx
c0103c4c:	39 d0                	cmp    %edx,%eax
c0103c4e:	72 24                	jb     c0103c74 <basic_check+0x18d>
c0103c50:	c7 44 24 0c 9c 76 10 	movl   $0xc010769c,0xc(%esp)
c0103c57:	c0 
c0103c58:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103c5f:	c0 
c0103c60:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103c67:	00 
c0103c68:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103c6f:	e8 73 d0 ff ff       	call   c0100ce7 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c77:	89 04 24             	mov    %eax,(%esp)
c0103c7a:	e8 05 f8 ff ff       	call   c0103484 <page2pa>
c0103c7f:	8b 15 a0 ce 11 c0    	mov    0xc011cea0,%edx
c0103c85:	c1 e2 0c             	shl    $0xc,%edx
c0103c88:	39 d0                	cmp    %edx,%eax
c0103c8a:	72 24                	jb     c0103cb0 <basic_check+0x1c9>
c0103c8c:	c7 44 24 0c b9 76 10 	movl   $0xc01076b9,0xc(%esp)
c0103c93:	c0 
c0103c94:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103c9b:	c0 
c0103c9c:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103ca3:	00 
c0103ca4:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103cab:	e8 37 d0 ff ff       	call   c0100ce7 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cb3:	89 04 24             	mov    %eax,(%esp)
c0103cb6:	e8 c9 f7 ff ff       	call   c0103484 <page2pa>
c0103cbb:	8b 15 a0 ce 11 c0    	mov    0xc011cea0,%edx
c0103cc1:	c1 e2 0c             	shl    $0xc,%edx
c0103cc4:	39 d0                	cmp    %edx,%eax
c0103cc6:	72 24                	jb     c0103cec <basic_check+0x205>
c0103cc8:	c7 44 24 0c d6 76 10 	movl   $0xc01076d6,0xc(%esp)
c0103ccf:	c0 
c0103cd0:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103cd7:	c0 
c0103cd8:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103cdf:	00 
c0103ce0:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103ce7:	e8 fb cf ff ff       	call   c0100ce7 <__panic>

    list_entry_t free_list_store = free_list;
c0103cec:	a1 90 cf 11 c0       	mov    0xc011cf90,%eax
c0103cf1:	8b 15 94 cf 11 c0    	mov    0xc011cf94,%edx
c0103cf7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103cfa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103cfd:	c7 45 e0 90 cf 11 c0 	movl   $0xc011cf90,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d07:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103d0a:	89 50 04             	mov    %edx,0x4(%eax)
c0103d0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d10:	8b 50 04             	mov    0x4(%eax),%edx
c0103d13:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d16:	89 10                	mov    %edx,(%eax)
c0103d18:	c7 45 dc 90 cf 11 c0 	movl   $0xc011cf90,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103d1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d22:	8b 40 04             	mov    0x4(%eax),%eax
c0103d25:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103d28:	0f 94 c0             	sete   %al
c0103d2b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103d2e:	85 c0                	test   %eax,%eax
c0103d30:	75 24                	jne    c0103d56 <basic_check+0x26f>
c0103d32:	c7 44 24 0c f3 76 10 	movl   $0xc01076f3,0xc(%esp)
c0103d39:	c0 
c0103d3a:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103d41:	c0 
c0103d42:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103d49:	00 
c0103d4a:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103d51:	e8 91 cf ff ff       	call   c0100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
c0103d56:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
c0103d5b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103d5e:	c7 05 98 cf 11 c0 00 	movl   $0x0,0xc011cf98
c0103d65:	00 00 00 

    assert(alloc_page() == NULL);
c0103d68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d6f:	e8 73 0c 00 00       	call   c01049e7 <alloc_pages>
c0103d74:	85 c0                	test   %eax,%eax
c0103d76:	74 24                	je     c0103d9c <basic_check+0x2b5>
c0103d78:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c0103d7f:	c0 
c0103d80:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103d87:	c0 
c0103d88:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103d8f:	00 
c0103d90:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103d97:	e8 4b cf ff ff       	call   c0100ce7 <__panic>

    free_page(p0);
c0103d9c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103da3:	00 
c0103da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103da7:	89 04 24             	mov    %eax,(%esp)
c0103daa:	e8 70 0c 00 00       	call   c0104a1f <free_pages>
    free_page(p1);
c0103daf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103db6:	00 
c0103db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103dba:	89 04 24             	mov    %eax,(%esp)
c0103dbd:	e8 5d 0c 00 00       	call   c0104a1f <free_pages>
    free_page(p2);
c0103dc2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103dc9:	00 
c0103dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dcd:	89 04 24             	mov    %eax,(%esp)
c0103dd0:	e8 4a 0c 00 00       	call   c0104a1f <free_pages>
    assert(nr_free == 3);
c0103dd5:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
c0103dda:	83 f8 03             	cmp    $0x3,%eax
c0103ddd:	74 24                	je     c0103e03 <basic_check+0x31c>
c0103ddf:	c7 44 24 0c 1f 77 10 	movl   $0xc010771f,0xc(%esp)
c0103de6:	c0 
c0103de7:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103dee:	c0 
c0103def:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103df6:	00 
c0103df7:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103dfe:	e8 e4 ce ff ff       	call   c0100ce7 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103e03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e0a:	e8 d8 0b 00 00       	call   c01049e7 <alloc_pages>
c0103e0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103e12:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103e16:	75 24                	jne    c0103e3c <basic_check+0x355>
c0103e18:	c7 44 24 0c e8 75 10 	movl   $0xc01075e8,0xc(%esp)
c0103e1f:	c0 
c0103e20:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103e27:	c0 
c0103e28:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103e2f:	00 
c0103e30:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103e37:	e8 ab ce ff ff       	call   c0100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103e3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e43:	e8 9f 0b 00 00       	call   c01049e7 <alloc_pages>
c0103e48:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103e4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103e4f:	75 24                	jne    c0103e75 <basic_check+0x38e>
c0103e51:	c7 44 24 0c 04 76 10 	movl   $0xc0107604,0xc(%esp)
c0103e58:	c0 
c0103e59:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103e60:	c0 
c0103e61:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103e68:	00 
c0103e69:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103e70:	e8 72 ce ff ff       	call   c0100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103e75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e7c:	e8 66 0b 00 00       	call   c01049e7 <alloc_pages>
c0103e81:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103e84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e88:	75 24                	jne    c0103eae <basic_check+0x3c7>
c0103e8a:	c7 44 24 0c 20 76 10 	movl   $0xc0107620,0xc(%esp)
c0103e91:	c0 
c0103e92:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103e99:	c0 
c0103e9a:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103ea1:	00 
c0103ea2:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103ea9:	e8 39 ce ff ff       	call   c0100ce7 <__panic>

    assert(alloc_page() == NULL);
c0103eae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103eb5:	e8 2d 0b 00 00       	call   c01049e7 <alloc_pages>
c0103eba:	85 c0                	test   %eax,%eax
c0103ebc:	74 24                	je     c0103ee2 <basic_check+0x3fb>
c0103ebe:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c0103ec5:	c0 
c0103ec6:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103ecd:	c0 
c0103ece:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0103ed5:	00 
c0103ed6:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103edd:	e8 05 ce ff ff       	call   c0100ce7 <__panic>

    free_page(p0);
c0103ee2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ee9:	00 
c0103eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103eed:	89 04 24             	mov    %eax,(%esp)
c0103ef0:	e8 2a 0b 00 00       	call   c0104a1f <free_pages>
c0103ef5:	c7 45 d8 90 cf 11 c0 	movl   $0xc011cf90,-0x28(%ebp)
c0103efc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103eff:	8b 40 04             	mov    0x4(%eax),%eax
c0103f02:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103f05:	0f 94 c0             	sete   %al
c0103f08:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103f0b:	85 c0                	test   %eax,%eax
c0103f0d:	74 24                	je     c0103f33 <basic_check+0x44c>
c0103f0f:	c7 44 24 0c 2c 77 10 	movl   $0xc010772c,0xc(%esp)
c0103f16:	c0 
c0103f17:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103f1e:	c0 
c0103f1f:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0103f26:	00 
c0103f27:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103f2e:	e8 b4 cd ff ff       	call   c0100ce7 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103f33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f3a:	e8 a8 0a 00 00       	call   c01049e7 <alloc_pages>
c0103f3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f45:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103f48:	74 24                	je     c0103f6e <basic_check+0x487>
c0103f4a:	c7 44 24 0c 44 77 10 	movl   $0xc0107744,0xc(%esp)
c0103f51:	c0 
c0103f52:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103f59:	c0 
c0103f5a:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0103f61:	00 
c0103f62:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103f69:	e8 79 cd ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c0103f6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f75:	e8 6d 0a 00 00       	call   c01049e7 <alloc_pages>
c0103f7a:	85 c0                	test   %eax,%eax
c0103f7c:	74 24                	je     c0103fa2 <basic_check+0x4bb>
c0103f7e:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c0103f85:	c0 
c0103f86:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103f8d:	c0 
c0103f8e:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103f95:	00 
c0103f96:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103f9d:	e8 45 cd ff ff       	call   c0100ce7 <__panic>

    assert(nr_free == 0);
c0103fa2:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
c0103fa7:	85 c0                	test   %eax,%eax
c0103fa9:	74 24                	je     c0103fcf <basic_check+0x4e8>
c0103fab:	c7 44 24 0c 5d 77 10 	movl   $0xc010775d,0xc(%esp)
c0103fb2:	c0 
c0103fb3:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0103fba:	c0 
c0103fbb:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0103fc2:	00 
c0103fc3:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0103fca:	e8 18 cd ff ff       	call   c0100ce7 <__panic>
    free_list = free_list_store;
c0103fcf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103fd2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103fd5:	a3 90 cf 11 c0       	mov    %eax,0xc011cf90
c0103fda:	89 15 94 cf 11 c0    	mov    %edx,0xc011cf94
    nr_free = nr_free_store;
c0103fe0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fe3:	a3 98 cf 11 c0       	mov    %eax,0xc011cf98

    free_page(p);
c0103fe8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103fef:	00 
c0103ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ff3:	89 04 24             	mov    %eax,(%esp)
c0103ff6:	e8 24 0a 00 00       	call   c0104a1f <free_pages>
    free_page(p1);
c0103ffb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104002:	00 
c0104003:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104006:	89 04 24             	mov    %eax,(%esp)
c0104009:	e8 11 0a 00 00       	call   c0104a1f <free_pages>
    free_page(p2);
c010400e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104015:	00 
c0104016:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104019:	89 04 24             	mov    %eax,(%esp)
c010401c:	e8 fe 09 00 00       	call   c0104a1f <free_pages>
}
c0104021:	c9                   	leave  
c0104022:	c3                   	ret    

c0104023 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104023:	55                   	push   %ebp
c0104024:	89 e5                	mov    %esp,%ebp
c0104026:	53                   	push   %ebx
c0104027:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c010402d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104034:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010403b:	c7 45 ec 90 cf 11 c0 	movl   $0xc011cf90,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104042:	eb 6b                	jmp    c01040af <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0104044:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104047:	83 e8 0c             	sub    $0xc,%eax
c010404a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c010404d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104050:	83 c0 04             	add    $0x4,%eax
c0104053:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010405a:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010405d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104060:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104063:	0f a3 10             	bt     %edx,(%eax)
c0104066:	19 c0                	sbb    %eax,%eax
c0104068:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010406b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010406f:	0f 95 c0             	setne  %al
c0104072:	0f b6 c0             	movzbl %al,%eax
c0104075:	85 c0                	test   %eax,%eax
c0104077:	75 24                	jne    c010409d <default_check+0x7a>
c0104079:	c7 44 24 0c 6a 77 10 	movl   $0xc010776a,0xc(%esp)
c0104080:	c0 
c0104081:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104088:	c0 
c0104089:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0104090:	00 
c0104091:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104098:	e8 4a cc ff ff       	call   c0100ce7 <__panic>
        count ++, total += p->property;
c010409d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01040a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040a4:	8b 50 08             	mov    0x8(%eax),%edx
c01040a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040aa:	01 d0                	add    %edx,%eax
c01040ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01040af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01040b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01040b5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01040b8:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01040bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01040be:	81 7d ec 90 cf 11 c0 	cmpl   $0xc011cf90,-0x14(%ebp)
c01040c5:	0f 85 79 ff ff ff    	jne    c0104044 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01040cb:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01040ce:	e8 7e 09 00 00       	call   c0104a51 <nr_free_pages>
c01040d3:	39 c3                	cmp    %eax,%ebx
c01040d5:	74 24                	je     c01040fb <default_check+0xd8>
c01040d7:	c7 44 24 0c 7a 77 10 	movl   $0xc010777a,0xc(%esp)
c01040de:	c0 
c01040df:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c01040e6:	c0 
c01040e7:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c01040ee:	00 
c01040ef:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c01040f6:	e8 ec cb ff ff       	call   c0100ce7 <__panic>

    basic_check();
c01040fb:	e8 e7 f9 ff ff       	call   c0103ae7 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104100:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104107:	e8 db 08 00 00       	call   c01049e7 <alloc_pages>
c010410c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c010410f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104113:	75 24                	jne    c0104139 <default_check+0x116>
c0104115:	c7 44 24 0c 93 77 10 	movl   $0xc0107793,0xc(%esp)
c010411c:	c0 
c010411d:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104124:	c0 
c0104125:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c010412c:	00 
c010412d:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104134:	e8 ae cb ff ff       	call   c0100ce7 <__panic>
    assert(!PageProperty(p0));
c0104139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010413c:	83 c0 04             	add    $0x4,%eax
c010413f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104146:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104149:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010414c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010414f:	0f a3 10             	bt     %edx,(%eax)
c0104152:	19 c0                	sbb    %eax,%eax
c0104154:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104157:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010415b:	0f 95 c0             	setne  %al
c010415e:	0f b6 c0             	movzbl %al,%eax
c0104161:	85 c0                	test   %eax,%eax
c0104163:	74 24                	je     c0104189 <default_check+0x166>
c0104165:	c7 44 24 0c 9e 77 10 	movl   $0xc010779e,0xc(%esp)
c010416c:	c0 
c010416d:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104174:	c0 
c0104175:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c010417c:	00 
c010417d:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104184:	e8 5e cb ff ff       	call   c0100ce7 <__panic>

    list_entry_t free_list_store = free_list;
c0104189:	a1 90 cf 11 c0       	mov    0xc011cf90,%eax
c010418e:	8b 15 94 cf 11 c0    	mov    0xc011cf94,%edx
c0104194:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104197:	89 55 84             	mov    %edx,-0x7c(%ebp)
c010419a:	c7 45 b4 90 cf 11 c0 	movl   $0xc011cf90,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01041a1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041a4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01041a7:	89 50 04             	mov    %edx,0x4(%eax)
c01041aa:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041ad:	8b 50 04             	mov    0x4(%eax),%edx
c01041b0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041b3:	89 10                	mov    %edx,(%eax)
c01041b5:	c7 45 b0 90 cf 11 c0 	movl   $0xc011cf90,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01041bc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01041bf:	8b 40 04             	mov    0x4(%eax),%eax
c01041c2:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01041c5:	0f 94 c0             	sete   %al
c01041c8:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01041cb:	85 c0                	test   %eax,%eax
c01041cd:	75 24                	jne    c01041f3 <default_check+0x1d0>
c01041cf:	c7 44 24 0c f3 76 10 	movl   $0xc01076f3,0xc(%esp)
c01041d6:	c0 
c01041d7:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c01041de:	c0 
c01041df:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01041e6:	00 
c01041e7:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c01041ee:	e8 f4 ca ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c01041f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01041fa:	e8 e8 07 00 00       	call   c01049e7 <alloc_pages>
c01041ff:	85 c0                	test   %eax,%eax
c0104201:	74 24                	je     c0104227 <default_check+0x204>
c0104203:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c010420a:	c0 
c010420b:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104212:	c0 
c0104213:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c010421a:	00 
c010421b:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104222:	e8 c0 ca ff ff       	call   c0100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
c0104227:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
c010422c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010422f:	c7 05 98 cf 11 c0 00 	movl   $0x0,0xc011cf98
c0104236:	00 00 00 

    free_pages(p0 + 2, 3);
c0104239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010423c:	83 c0 28             	add    $0x28,%eax
c010423f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104246:	00 
c0104247:	89 04 24             	mov    %eax,(%esp)
c010424a:	e8 d0 07 00 00       	call   c0104a1f <free_pages>
    assert(alloc_pages(4) == NULL);
c010424f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104256:	e8 8c 07 00 00       	call   c01049e7 <alloc_pages>
c010425b:	85 c0                	test   %eax,%eax
c010425d:	74 24                	je     c0104283 <default_check+0x260>
c010425f:	c7 44 24 0c b0 77 10 	movl   $0xc01077b0,0xc(%esp)
c0104266:	c0 
c0104267:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c010426e:	c0 
c010426f:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0104276:	00 
c0104277:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c010427e:	e8 64 ca ff ff       	call   c0100ce7 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104286:	83 c0 28             	add    $0x28,%eax
c0104289:	83 c0 04             	add    $0x4,%eax
c010428c:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104293:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104296:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104299:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010429c:	0f a3 10             	bt     %edx,(%eax)
c010429f:	19 c0                	sbb    %eax,%eax
c01042a1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01042a4:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01042a8:	0f 95 c0             	setne  %al
c01042ab:	0f b6 c0             	movzbl %al,%eax
c01042ae:	85 c0                	test   %eax,%eax
c01042b0:	74 0e                	je     c01042c0 <default_check+0x29d>
c01042b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042b5:	83 c0 28             	add    $0x28,%eax
c01042b8:	8b 40 08             	mov    0x8(%eax),%eax
c01042bb:	83 f8 03             	cmp    $0x3,%eax
c01042be:	74 24                	je     c01042e4 <default_check+0x2c1>
c01042c0:	c7 44 24 0c c8 77 10 	movl   $0xc01077c8,0xc(%esp)
c01042c7:	c0 
c01042c8:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c01042cf:	c0 
c01042d0:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01042d7:	00 
c01042d8:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c01042df:	e8 03 ca ff ff       	call   c0100ce7 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01042e4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01042eb:	e8 f7 06 00 00       	call   c01049e7 <alloc_pages>
c01042f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01042f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01042f7:	75 24                	jne    c010431d <default_check+0x2fa>
c01042f9:	c7 44 24 0c f4 77 10 	movl   $0xc01077f4,0xc(%esp)
c0104300:	c0 
c0104301:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104308:	c0 
c0104309:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104310:	00 
c0104311:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104318:	e8 ca c9 ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c010431d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104324:	e8 be 06 00 00       	call   c01049e7 <alloc_pages>
c0104329:	85 c0                	test   %eax,%eax
c010432b:	74 24                	je     c0104351 <default_check+0x32e>
c010432d:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c0104334:	c0 
c0104335:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c010433c:	c0 
c010433d:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0104344:	00 
c0104345:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c010434c:	e8 96 c9 ff ff       	call   c0100ce7 <__panic>
    assert(p0 + 2 == p1);
c0104351:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104354:	83 c0 28             	add    $0x28,%eax
c0104357:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010435a:	74 24                	je     c0104380 <default_check+0x35d>
c010435c:	c7 44 24 0c 12 78 10 	movl   $0xc0107812,0xc(%esp)
c0104363:	c0 
c0104364:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c010436b:	c0 
c010436c:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0104373:	00 
c0104374:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c010437b:	e8 67 c9 ff ff       	call   c0100ce7 <__panic>

    p2 = p0 + 1;
c0104380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104383:	83 c0 14             	add    $0x14,%eax
c0104386:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104389:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104390:	00 
c0104391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104394:	89 04 24             	mov    %eax,(%esp)
c0104397:	e8 83 06 00 00       	call   c0104a1f <free_pages>
    free_pages(p1, 3);
c010439c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01043a3:	00 
c01043a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043a7:	89 04 24             	mov    %eax,(%esp)
c01043aa:	e8 70 06 00 00       	call   c0104a1f <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01043af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043b2:	83 c0 04             	add    $0x4,%eax
c01043b5:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01043bc:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01043bf:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01043c2:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01043c5:	0f a3 10             	bt     %edx,(%eax)
c01043c8:	19 c0                	sbb    %eax,%eax
c01043ca:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01043cd:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01043d1:	0f 95 c0             	setne  %al
c01043d4:	0f b6 c0             	movzbl %al,%eax
c01043d7:	85 c0                	test   %eax,%eax
c01043d9:	74 0b                	je     c01043e6 <default_check+0x3c3>
c01043db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043de:	8b 40 08             	mov    0x8(%eax),%eax
c01043e1:	83 f8 01             	cmp    $0x1,%eax
c01043e4:	74 24                	je     c010440a <default_check+0x3e7>
c01043e6:	c7 44 24 0c 20 78 10 	movl   $0xc0107820,0xc(%esp)
c01043ed:	c0 
c01043ee:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c01043f5:	c0 
c01043f6:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01043fd:	00 
c01043fe:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104405:	e8 dd c8 ff ff       	call   c0100ce7 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010440a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010440d:	83 c0 04             	add    $0x4,%eax
c0104410:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104417:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010441a:	8b 45 90             	mov    -0x70(%ebp),%eax
c010441d:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104420:	0f a3 10             	bt     %edx,(%eax)
c0104423:	19 c0                	sbb    %eax,%eax
c0104425:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104428:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010442c:	0f 95 c0             	setne  %al
c010442f:	0f b6 c0             	movzbl %al,%eax
c0104432:	85 c0                	test   %eax,%eax
c0104434:	74 0b                	je     c0104441 <default_check+0x41e>
c0104436:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104439:	8b 40 08             	mov    0x8(%eax),%eax
c010443c:	83 f8 03             	cmp    $0x3,%eax
c010443f:	74 24                	je     c0104465 <default_check+0x442>
c0104441:	c7 44 24 0c 48 78 10 	movl   $0xc0107848,0xc(%esp)
c0104448:	c0 
c0104449:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104450:	c0 
c0104451:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0104458:	00 
c0104459:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104460:	e8 82 c8 ff ff       	call   c0100ce7 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104465:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010446c:	e8 76 05 00 00       	call   c01049e7 <alloc_pages>
c0104471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104474:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104477:	83 e8 14             	sub    $0x14,%eax
c010447a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010447d:	74 24                	je     c01044a3 <default_check+0x480>
c010447f:	c7 44 24 0c 6e 78 10 	movl   $0xc010786e,0xc(%esp)
c0104486:	c0 
c0104487:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c010448e:	c0 
c010448f:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0104496:	00 
c0104497:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c010449e:	e8 44 c8 ff ff       	call   c0100ce7 <__panic>
    free_page(p0);
c01044a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01044aa:	00 
c01044ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044ae:	89 04 24             	mov    %eax,(%esp)
c01044b1:	e8 69 05 00 00       	call   c0104a1f <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01044b6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01044bd:	e8 25 05 00 00       	call   c01049e7 <alloc_pages>
c01044c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01044c8:	83 c0 14             	add    $0x14,%eax
c01044cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01044ce:	74 24                	je     c01044f4 <default_check+0x4d1>
c01044d0:	c7 44 24 0c 8c 78 10 	movl   $0xc010788c,0xc(%esp)
c01044d7:	c0 
c01044d8:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c01044df:	c0 
c01044e0:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01044e7:	00 
c01044e8:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c01044ef:	e8 f3 c7 ff ff       	call   c0100ce7 <__panic>

    free_pages(p0, 2);
c01044f4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01044fb:	00 
c01044fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044ff:	89 04 24             	mov    %eax,(%esp)
c0104502:	e8 18 05 00 00       	call   c0104a1f <free_pages>
    free_page(p2);
c0104507:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010450e:	00 
c010450f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104512:	89 04 24             	mov    %eax,(%esp)
c0104515:	e8 05 05 00 00       	call   c0104a1f <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010451a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104521:	e8 c1 04 00 00       	call   c01049e7 <alloc_pages>
c0104526:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104529:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010452d:	75 24                	jne    c0104553 <default_check+0x530>
c010452f:	c7 44 24 0c ac 78 10 	movl   $0xc01078ac,0xc(%esp)
c0104536:	c0 
c0104537:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c010453e:	c0 
c010453f:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0104546:	00 
c0104547:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c010454e:	e8 94 c7 ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c0104553:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010455a:	e8 88 04 00 00       	call   c01049e7 <alloc_pages>
c010455f:	85 c0                	test   %eax,%eax
c0104561:	74 24                	je     c0104587 <default_check+0x564>
c0104563:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c010456a:	c0 
c010456b:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104572:	c0 
c0104573:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c010457a:	00 
c010457b:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104582:	e8 60 c7 ff ff       	call   c0100ce7 <__panic>

    assert(nr_free == 0);
c0104587:	a1 98 cf 11 c0       	mov    0xc011cf98,%eax
c010458c:	85 c0                	test   %eax,%eax
c010458e:	74 24                	je     c01045b4 <default_check+0x591>
c0104590:	c7 44 24 0c 5d 77 10 	movl   $0xc010775d,0xc(%esp)
c0104597:	c0 
c0104598:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c010459f:	c0 
c01045a0:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01045a7:	00 
c01045a8:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c01045af:	e8 33 c7 ff ff       	call   c0100ce7 <__panic>
    nr_free = nr_free_store;
c01045b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045b7:	a3 98 cf 11 c0       	mov    %eax,0xc011cf98

    free_list = free_list_store;
c01045bc:	8b 45 80             	mov    -0x80(%ebp),%eax
c01045bf:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01045c2:	a3 90 cf 11 c0       	mov    %eax,0xc011cf90
c01045c7:	89 15 94 cf 11 c0    	mov    %edx,0xc011cf94
    free_pages(p0, 5);
c01045cd:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01045d4:	00 
c01045d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045d8:	89 04 24             	mov    %eax,(%esp)
c01045db:	e8 3f 04 00 00       	call   c0104a1f <free_pages>

    le = &free_list;
c01045e0:	c7 45 ec 90 cf 11 c0 	movl   $0xc011cf90,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01045e7:	eb 5b                	jmp    c0104644 <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
c01045e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01045ec:	8b 40 04             	mov    0x4(%eax),%eax
c01045ef:	8b 00                	mov    (%eax),%eax
c01045f1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01045f4:	75 0d                	jne    c0104603 <default_check+0x5e0>
c01045f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01045f9:	8b 00                	mov    (%eax),%eax
c01045fb:	8b 40 04             	mov    0x4(%eax),%eax
c01045fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104601:	74 24                	je     c0104627 <default_check+0x604>
c0104603:	c7 44 24 0c cc 78 10 	movl   $0xc01078cc,0xc(%esp)
c010460a:	c0 
c010460b:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104612:	c0 
c0104613:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c010461a:	00 
c010461b:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104622:	e8 c0 c6 ff ff       	call   c0100ce7 <__panic>
        struct Page *p = le2page(le, page_link);
c0104627:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010462a:	83 e8 0c             	sub    $0xc,%eax
c010462d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0104630:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104634:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104637:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010463a:	8b 40 08             	mov    0x8(%eax),%eax
c010463d:	29 c2                	sub    %eax,%edx
c010463f:	89 d0                	mov    %edx,%eax
c0104641:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104644:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104647:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010464a:	8b 45 88             	mov    -0x78(%ebp),%eax
c010464d:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104650:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104653:	81 7d ec 90 cf 11 c0 	cmpl   $0xc011cf90,-0x14(%ebp)
c010465a:	75 8d                	jne    c01045e9 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010465c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104660:	74 24                	je     c0104686 <default_check+0x663>
c0104662:	c7 44 24 0c f9 78 10 	movl   $0xc01078f9,0xc(%esp)
c0104669:	c0 
c010466a:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c0104671:	c0 
c0104672:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0104679:	00 
c010467a:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c0104681:	e8 61 c6 ff ff       	call   c0100ce7 <__panic>
    assert(total == 0);
c0104686:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010468a:	74 24                	je     c01046b0 <default_check+0x68d>
c010468c:	c7 44 24 0c 04 79 10 	movl   $0xc0107904,0xc(%esp)
c0104693:	c0 
c0104694:	c7 44 24 08 6a 75 10 	movl   $0xc010756a,0x8(%esp)
c010469b:	c0 
c010469c:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c01046a3:	00 
c01046a4:	c7 04 24 7f 75 10 c0 	movl   $0xc010757f,(%esp)
c01046ab:	e8 37 c6 ff ff       	call   c0100ce7 <__panic>
}
c01046b0:	81 c4 94 00 00 00    	add    $0x94,%esp
c01046b6:	5b                   	pop    %ebx
c01046b7:	5d                   	pop    %ebp
c01046b8:	c3                   	ret    

c01046b9 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01046b9:	55                   	push   %ebp
c01046ba:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01046bc:	8b 55 08             	mov    0x8(%ebp),%edx
c01046bf:	a1 a4 cf 11 c0       	mov    0xc011cfa4,%eax
c01046c4:	29 c2                	sub    %eax,%edx
c01046c6:	89 d0                	mov    %edx,%eax
c01046c8:	c1 f8 02             	sar    $0x2,%eax
c01046cb:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01046d1:	5d                   	pop    %ebp
c01046d2:	c3                   	ret    

c01046d3 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01046d3:	55                   	push   %ebp
c01046d4:	89 e5                	mov    %esp,%ebp
c01046d6:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01046d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01046dc:	89 04 24             	mov    %eax,(%esp)
c01046df:	e8 d5 ff ff ff       	call   c01046b9 <page2ppn>
c01046e4:	c1 e0 0c             	shl    $0xc,%eax
}
c01046e7:	c9                   	leave  
c01046e8:	c3                   	ret    

c01046e9 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01046e9:	55                   	push   %ebp
c01046ea:	89 e5                	mov    %esp,%ebp
c01046ec:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01046ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01046f2:	c1 e8 0c             	shr    $0xc,%eax
c01046f5:	89 c2                	mov    %eax,%edx
c01046f7:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c01046fc:	39 c2                	cmp    %eax,%edx
c01046fe:	72 1c                	jb     c010471c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104700:	c7 44 24 08 40 79 10 	movl   $0xc0107940,0x8(%esp)
c0104707:	c0 
c0104708:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c010470f:	00 
c0104710:	c7 04 24 5f 79 10 c0 	movl   $0xc010795f,(%esp)
c0104717:	e8 cb c5 ff ff       	call   c0100ce7 <__panic>
    }
    return &pages[PPN(pa)];
c010471c:	8b 0d a4 cf 11 c0    	mov    0xc011cfa4,%ecx
c0104722:	8b 45 08             	mov    0x8(%ebp),%eax
c0104725:	c1 e8 0c             	shr    $0xc,%eax
c0104728:	89 c2                	mov    %eax,%edx
c010472a:	89 d0                	mov    %edx,%eax
c010472c:	c1 e0 02             	shl    $0x2,%eax
c010472f:	01 d0                	add    %edx,%eax
c0104731:	c1 e0 02             	shl    $0x2,%eax
c0104734:	01 c8                	add    %ecx,%eax
}
c0104736:	c9                   	leave  
c0104737:	c3                   	ret    

c0104738 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104738:	55                   	push   %ebp
c0104739:	89 e5                	mov    %esp,%ebp
c010473b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010473e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104741:	89 04 24             	mov    %eax,(%esp)
c0104744:	e8 8a ff ff ff       	call   c01046d3 <page2pa>
c0104749:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010474c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010474f:	c1 e8 0c             	shr    $0xc,%eax
c0104752:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104755:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c010475a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010475d:	72 23                	jb     c0104782 <page2kva+0x4a>
c010475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104762:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104766:	c7 44 24 08 70 79 10 	movl   $0xc0107970,0x8(%esp)
c010476d:	c0 
c010476e:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0104775:	00 
c0104776:	c7 04 24 5f 79 10 c0 	movl   $0xc010795f,(%esp)
c010477d:	e8 65 c5 ff ff       	call   c0100ce7 <__panic>
c0104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104785:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010478a:	c9                   	leave  
c010478b:	c3                   	ret    

c010478c <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c010478c:	55                   	push   %ebp
c010478d:	89 e5                	mov    %esp,%ebp
c010478f:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104792:	8b 45 08             	mov    0x8(%ebp),%eax
c0104795:	83 e0 01             	and    $0x1,%eax
c0104798:	85 c0                	test   %eax,%eax
c010479a:	75 1c                	jne    c01047b8 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010479c:	c7 44 24 08 94 79 10 	movl   $0xc0107994,0x8(%esp)
c01047a3:	c0 
c01047a4:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01047ab:	00 
c01047ac:	c7 04 24 5f 79 10 c0 	movl   $0xc010795f,(%esp)
c01047b3:	e8 2f c5 ff ff       	call   c0100ce7 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01047b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01047bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047c0:	89 04 24             	mov    %eax,(%esp)
c01047c3:	e8 21 ff ff ff       	call   c01046e9 <pa2page>
}
c01047c8:	c9                   	leave  
c01047c9:	c3                   	ret    

c01047ca <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01047ca:	55                   	push   %ebp
c01047cb:	89 e5                	mov    %esp,%ebp
c01047cd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01047d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01047d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047d8:	89 04 24             	mov    %eax,(%esp)
c01047db:	e8 09 ff ff ff       	call   c01046e9 <pa2page>
}
c01047e0:	c9                   	leave  
c01047e1:	c3                   	ret    

c01047e2 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01047e2:	55                   	push   %ebp
c01047e3:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01047e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01047e8:	8b 00                	mov    (%eax),%eax
}
c01047ea:	5d                   	pop    %ebp
c01047eb:	c3                   	ret    

c01047ec <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01047ec:	55                   	push   %ebp
c01047ed:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01047ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01047f2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047f5:	89 10                	mov    %edx,(%eax)
}
c01047f7:	5d                   	pop    %ebp
c01047f8:	c3                   	ret    

c01047f9 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01047f9:	55                   	push   %ebp
c01047fa:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01047fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ff:	8b 00                	mov    (%eax),%eax
c0104801:	8d 50 01             	lea    0x1(%eax),%edx
c0104804:	8b 45 08             	mov    0x8(%ebp),%eax
c0104807:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104809:	8b 45 08             	mov    0x8(%ebp),%eax
c010480c:	8b 00                	mov    (%eax),%eax
}
c010480e:	5d                   	pop    %ebp
c010480f:	c3                   	ret    

c0104810 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104810:	55                   	push   %ebp
c0104811:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104813:	8b 45 08             	mov    0x8(%ebp),%eax
c0104816:	8b 00                	mov    (%eax),%eax
c0104818:	8d 50 ff             	lea    -0x1(%eax),%edx
c010481b:	8b 45 08             	mov    0x8(%ebp),%eax
c010481e:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104820:	8b 45 08             	mov    0x8(%ebp),%eax
c0104823:	8b 00                	mov    (%eax),%eax
}
c0104825:	5d                   	pop    %ebp
c0104826:	c3                   	ret    

c0104827 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0104827:	55                   	push   %ebp
c0104828:	89 e5                	mov    %esp,%ebp
c010482a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010482d:	9c                   	pushf  
c010482e:	58                   	pop    %eax
c010482f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104832:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104835:	25 00 02 00 00       	and    $0x200,%eax
c010483a:	85 c0                	test   %eax,%eax
c010483c:	74 0c                	je     c010484a <__intr_save+0x23>
        intr_disable();
c010483e:	e8 98 ce ff ff       	call   c01016db <intr_disable>
        return 1;
c0104843:	b8 01 00 00 00       	mov    $0x1,%eax
c0104848:	eb 05                	jmp    c010484f <__intr_save+0x28>
    }
    return 0;
c010484a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010484f:	c9                   	leave  
c0104850:	c3                   	ret    

c0104851 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104851:	55                   	push   %ebp
c0104852:	89 e5                	mov    %esp,%ebp
c0104854:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104857:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010485b:	74 05                	je     c0104862 <__intr_restore+0x11>
        intr_enable();
c010485d:	e8 73 ce ff ff       	call   c01016d5 <intr_enable>
    }
}
c0104862:	c9                   	leave  
c0104863:	c3                   	ret    

c0104864 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104864:	55                   	push   %ebp
c0104865:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104867:	8b 45 08             	mov    0x8(%ebp),%eax
c010486a:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c010486d:	b8 23 00 00 00       	mov    $0x23,%eax
c0104872:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104874:	b8 23 00 00 00       	mov    $0x23,%eax
c0104879:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010487b:	b8 10 00 00 00       	mov    $0x10,%eax
c0104880:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104882:	b8 10 00 00 00       	mov    $0x10,%eax
c0104887:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104889:	b8 10 00 00 00       	mov    $0x10,%eax
c010488e:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104890:	ea 97 48 10 c0 08 00 	ljmp   $0x8,$0xc0104897
}
c0104897:	5d                   	pop    %ebp
c0104898:	c3                   	ret    

c0104899 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104899:	55                   	push   %ebp
c010489a:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c010489c:	8b 45 08             	mov    0x8(%ebp),%eax
c010489f:	a3 c4 ce 11 c0       	mov    %eax,0xc011cec4
}
c01048a4:	5d                   	pop    %ebp
c01048a5:	c3                   	ret    

c01048a6 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01048a6:	55                   	push   %ebp
c01048a7:	89 e5                	mov    %esp,%ebp
c01048a9:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01048ac:	b8 00 90 11 c0       	mov    $0xc0119000,%eax
c01048b1:	89 04 24             	mov    %eax,(%esp)
c01048b4:	e8 e0 ff ff ff       	call   c0104899 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01048b9:	66 c7 05 c8 ce 11 c0 	movw   $0x10,0xc011cec8
c01048c0:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01048c2:	66 c7 05 28 9a 11 c0 	movw   $0x68,0xc0119a28
c01048c9:	68 00 
c01048cb:	b8 c0 ce 11 c0       	mov    $0xc011cec0,%eax
c01048d0:	66 a3 2a 9a 11 c0    	mov    %ax,0xc0119a2a
c01048d6:	b8 c0 ce 11 c0       	mov    $0xc011cec0,%eax
c01048db:	c1 e8 10             	shr    $0x10,%eax
c01048de:	a2 2c 9a 11 c0       	mov    %al,0xc0119a2c
c01048e3:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c01048ea:	83 e0 f0             	and    $0xfffffff0,%eax
c01048ed:	83 c8 09             	or     $0x9,%eax
c01048f0:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c01048f5:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c01048fc:	83 e0 ef             	and    $0xffffffef,%eax
c01048ff:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0104904:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c010490b:	83 e0 9f             	and    $0xffffff9f,%eax
c010490e:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0104913:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c010491a:	83 c8 80             	or     $0xffffff80,%eax
c010491d:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0104922:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0104929:	83 e0 f0             	and    $0xfffffff0,%eax
c010492c:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0104931:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0104938:	83 e0 ef             	and    $0xffffffef,%eax
c010493b:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0104940:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0104947:	83 e0 df             	and    $0xffffffdf,%eax
c010494a:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c010494f:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0104956:	83 c8 40             	or     $0x40,%eax
c0104959:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c010495e:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0104965:	83 e0 7f             	and    $0x7f,%eax
c0104968:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c010496d:	b8 c0 ce 11 c0       	mov    $0xc011cec0,%eax
c0104972:	c1 e8 18             	shr    $0x18,%eax
c0104975:	a2 2f 9a 11 c0       	mov    %al,0xc0119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c010497a:	c7 04 24 30 9a 11 c0 	movl   $0xc0119a30,(%esp)
c0104981:	e8 de fe ff ff       	call   c0104864 <lgdt>
c0104986:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010498c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104990:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0104993:	c9                   	leave  
c0104994:	c3                   	ret    

c0104995 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104995:	55                   	push   %ebp
c0104996:	89 e5                	mov    %esp,%ebp
c0104998:	83 ec 18             	sub    $0x18,%esp
	//pmm_manager=&buddy_pmm_manager;
    pmm_manager = &default_pmm_manager;
c010499b:	c7 05 9c cf 11 c0 24 	movl   $0xc0107924,0xc011cf9c
c01049a2:	79 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01049a5:	a1 9c cf 11 c0       	mov    0xc011cf9c,%eax
c01049aa:	8b 00                	mov    (%eax),%eax
c01049ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01049b0:	c7 04 24 c0 79 10 c0 	movl   $0xc01079c0,(%esp)
c01049b7:	e8 97 b9 ff ff       	call   c0100353 <cprintf>
    pmm_manager->init();
c01049bc:	a1 9c cf 11 c0       	mov    0xc011cf9c,%eax
c01049c1:	8b 40 04             	mov    0x4(%eax),%eax
c01049c4:	ff d0                	call   *%eax
}
c01049c6:	c9                   	leave  
c01049c7:	c3                   	ret    

c01049c8 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01049c8:	55                   	push   %ebp
c01049c9:	89 e5                	mov    %esp,%ebp
c01049cb:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01049ce:	a1 9c cf 11 c0       	mov    0xc011cf9c,%eax
c01049d3:	8b 40 08             	mov    0x8(%eax),%eax
c01049d6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01049d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049dd:	8b 55 08             	mov    0x8(%ebp),%edx
c01049e0:	89 14 24             	mov    %edx,(%esp)
c01049e3:	ff d0                	call   *%eax
}
c01049e5:	c9                   	leave  
c01049e6:	c3                   	ret    

c01049e7 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01049e7:	55                   	push   %ebp
c01049e8:	89 e5                	mov    %esp,%ebp
c01049ea:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c01049ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01049f4:	e8 2e fe ff ff       	call   c0104827 <__intr_save>
c01049f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c01049fc:	a1 9c cf 11 c0       	mov    0xc011cf9c,%eax
c0104a01:	8b 40 0c             	mov    0xc(%eax),%eax
c0104a04:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a07:	89 14 24             	mov    %edx,(%esp)
c0104a0a:	ff d0                	call   *%eax
c0104a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0104a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a12:	89 04 24             	mov    %eax,(%esp)
c0104a15:	e8 37 fe ff ff       	call   c0104851 <__intr_restore>
    return page;
c0104a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104a1d:	c9                   	leave  
c0104a1e:	c3                   	ret    

c0104a1f <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0104a1f:	55                   	push   %ebp
c0104a20:	89 e5                	mov    %esp,%ebp
c0104a22:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104a25:	e8 fd fd ff ff       	call   c0104827 <__intr_save>
c0104a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104a2d:	a1 9c cf 11 c0       	mov    0xc011cf9c,%eax
c0104a32:	8b 40 10             	mov    0x10(%eax),%eax
c0104a35:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104a38:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a3c:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a3f:	89 14 24             	mov    %edx,(%esp)
c0104a42:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0104a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a47:	89 04 24             	mov    %eax,(%esp)
c0104a4a:	e8 02 fe ff ff       	call   c0104851 <__intr_restore>
}
c0104a4f:	c9                   	leave  
c0104a50:	c3                   	ret    

c0104a51 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0104a51:	55                   	push   %ebp
c0104a52:	89 e5                	mov    %esp,%ebp
c0104a54:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104a57:	e8 cb fd ff ff       	call   c0104827 <__intr_save>
c0104a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0104a5f:	a1 9c cf 11 c0       	mov    0xc011cf9c,%eax
c0104a64:	8b 40 14             	mov    0x14(%eax),%eax
c0104a67:	ff d0                	call   *%eax
c0104a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a6f:	89 04 24             	mov    %eax,(%esp)
c0104a72:	e8 da fd ff ff       	call   c0104851 <__intr_restore>
    return ret;
c0104a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104a7a:	c9                   	leave  
c0104a7b:	c3                   	ret    

c0104a7c <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104a7c:	55                   	push   %ebp
c0104a7d:	89 e5                	mov    %esp,%ebp
c0104a7f:	57                   	push   %edi
c0104a80:	56                   	push   %esi
c0104a81:	53                   	push   %ebx
c0104a82:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104a88:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104a8f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104a96:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104a9d:	c7 04 24 d7 79 10 c0 	movl   $0xc01079d7,(%esp)
c0104aa4:	e8 aa b8 ff ff       	call   c0100353 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104aa9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104ab0:	e9 15 01 00 00       	jmp    c0104bca <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104ab5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ab8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104abb:	89 d0                	mov    %edx,%eax
c0104abd:	c1 e0 02             	shl    $0x2,%eax
c0104ac0:	01 d0                	add    %edx,%eax
c0104ac2:	c1 e0 02             	shl    $0x2,%eax
c0104ac5:	01 c8                	add    %ecx,%eax
c0104ac7:	8b 50 08             	mov    0x8(%eax),%edx
c0104aca:	8b 40 04             	mov    0x4(%eax),%eax
c0104acd:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104ad0:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0104ad3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ad6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ad9:	89 d0                	mov    %edx,%eax
c0104adb:	c1 e0 02             	shl    $0x2,%eax
c0104ade:	01 d0                	add    %edx,%eax
c0104ae0:	c1 e0 02             	shl    $0x2,%eax
c0104ae3:	01 c8                	add    %ecx,%eax
c0104ae5:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104ae8:	8b 58 10             	mov    0x10(%eax),%ebx
c0104aeb:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104aee:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104af1:	01 c8                	add    %ecx,%eax
c0104af3:	11 da                	adc    %ebx,%edx
c0104af5:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0104af8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104afb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104afe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b01:	89 d0                	mov    %edx,%eax
c0104b03:	c1 e0 02             	shl    $0x2,%eax
c0104b06:	01 d0                	add    %edx,%eax
c0104b08:	c1 e0 02             	shl    $0x2,%eax
c0104b0b:	01 c8                	add    %ecx,%eax
c0104b0d:	83 c0 14             	add    $0x14,%eax
c0104b10:	8b 00                	mov    (%eax),%eax
c0104b12:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104b18:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104b1b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104b1e:	83 c0 ff             	add    $0xffffffff,%eax
c0104b21:	83 d2 ff             	adc    $0xffffffff,%edx
c0104b24:	89 c6                	mov    %eax,%esi
c0104b26:	89 d7                	mov    %edx,%edi
c0104b28:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b2e:	89 d0                	mov    %edx,%eax
c0104b30:	c1 e0 02             	shl    $0x2,%eax
c0104b33:	01 d0                	add    %edx,%eax
c0104b35:	c1 e0 02             	shl    $0x2,%eax
c0104b38:	01 c8                	add    %ecx,%eax
c0104b3a:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104b3d:	8b 58 10             	mov    0x10(%eax),%ebx
c0104b40:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104b46:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104b4a:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104b4e:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104b52:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104b55:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104b58:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104b5c:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104b60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104b64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104b68:	c7 04 24 e4 79 10 c0 	movl   $0xc01079e4,(%esp)
c0104b6f:	e8 df b7 ff ff       	call   c0100353 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104b74:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b77:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b7a:	89 d0                	mov    %edx,%eax
c0104b7c:	c1 e0 02             	shl    $0x2,%eax
c0104b7f:	01 d0                	add    %edx,%eax
c0104b81:	c1 e0 02             	shl    $0x2,%eax
c0104b84:	01 c8                	add    %ecx,%eax
c0104b86:	83 c0 14             	add    $0x14,%eax
c0104b89:	8b 00                	mov    (%eax),%eax
c0104b8b:	83 f8 01             	cmp    $0x1,%eax
c0104b8e:	75 36                	jne    c0104bc6 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0104b90:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b96:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104b99:	77 2b                	ja     c0104bc6 <page_init+0x14a>
c0104b9b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104b9e:	72 05                	jb     c0104ba5 <page_init+0x129>
c0104ba0:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0104ba3:	73 21                	jae    c0104bc6 <page_init+0x14a>
c0104ba5:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104ba9:	77 1b                	ja     c0104bc6 <page_init+0x14a>
c0104bab:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104baf:	72 09                	jb     c0104bba <page_init+0x13e>
c0104bb1:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0104bb8:	77 0c                	ja     c0104bc6 <page_init+0x14a>
                maxpa = end;
c0104bba:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104bbd:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104bc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104bc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104bc6:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104bca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104bcd:	8b 00                	mov    (%eax),%eax
c0104bcf:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104bd2:	0f 8f dd fe ff ff    	jg     c0104ab5 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104bd8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104bdc:	72 1d                	jb     c0104bfb <page_init+0x17f>
c0104bde:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104be2:	77 09                	ja     c0104bed <page_init+0x171>
c0104be4:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0104beb:	76 0e                	jbe    c0104bfb <page_init+0x17f>
        maxpa = KMEMSIZE;
c0104bed:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104bf4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104bfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104bfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104c01:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104c05:	c1 ea 0c             	shr    $0xc,%edx
c0104c08:	a3 a0 ce 11 c0       	mov    %eax,0xc011cea0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104c0d:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0104c14:	b8 a8 cf 11 c0       	mov    $0xc011cfa8,%eax
c0104c19:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104c1c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104c1f:	01 d0                	add    %edx,%eax
c0104c21:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104c24:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104c27:	ba 00 00 00 00       	mov    $0x0,%edx
c0104c2c:	f7 75 ac             	divl   -0x54(%ebp)
c0104c2f:	89 d0                	mov    %edx,%eax
c0104c31:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104c34:	29 c2                	sub    %eax,%edx
c0104c36:	89 d0                	mov    %edx,%eax
c0104c38:	a3 a4 cf 11 c0       	mov    %eax,0xc011cfa4

    for (i = 0; i < npage; i ++) {
c0104c3d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104c44:	eb 2f                	jmp    c0104c75 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0104c46:	8b 0d a4 cf 11 c0    	mov    0xc011cfa4,%ecx
c0104c4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c4f:	89 d0                	mov    %edx,%eax
c0104c51:	c1 e0 02             	shl    $0x2,%eax
c0104c54:	01 d0                	add    %edx,%eax
c0104c56:	c1 e0 02             	shl    $0x2,%eax
c0104c59:	01 c8                	add    %ecx,%eax
c0104c5b:	83 c0 04             	add    $0x4,%eax
c0104c5e:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104c65:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104c68:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104c6b:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104c6e:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0104c71:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104c75:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c78:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0104c7d:	39 c2                	cmp    %eax,%edx
c0104c7f:	72 c5                	jb     c0104c46 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104c81:	8b 15 a0 ce 11 c0    	mov    0xc011cea0,%edx
c0104c87:	89 d0                	mov    %edx,%eax
c0104c89:	c1 e0 02             	shl    $0x2,%eax
c0104c8c:	01 d0                	add    %edx,%eax
c0104c8e:	c1 e0 02             	shl    $0x2,%eax
c0104c91:	89 c2                	mov    %eax,%edx
c0104c93:	a1 a4 cf 11 c0       	mov    0xc011cfa4,%eax
c0104c98:	01 d0                	add    %edx,%eax
c0104c9a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0104c9d:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104ca4:	77 23                	ja     c0104cc9 <page_init+0x24d>
c0104ca6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104ca9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104cad:	c7 44 24 08 14 7a 10 	movl   $0xc0107a14,0x8(%esp)
c0104cb4:	c0 
c0104cb5:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0104cbc:	00 
c0104cbd:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0104cc4:	e8 1e c0 ff ff       	call   c0100ce7 <__panic>
c0104cc9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104ccc:	05 00 00 00 40       	add    $0x40000000,%eax
c0104cd1:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104cd4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104cdb:	e9 74 01 00 00       	jmp    c0104e54 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104ce0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ce3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ce6:	89 d0                	mov    %edx,%eax
c0104ce8:	c1 e0 02             	shl    $0x2,%eax
c0104ceb:	01 d0                	add    %edx,%eax
c0104ced:	c1 e0 02             	shl    $0x2,%eax
c0104cf0:	01 c8                	add    %ecx,%eax
c0104cf2:	8b 50 08             	mov    0x8(%eax),%edx
c0104cf5:	8b 40 04             	mov    0x4(%eax),%eax
c0104cf8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104cfb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104cfe:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104d01:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d04:	89 d0                	mov    %edx,%eax
c0104d06:	c1 e0 02             	shl    $0x2,%eax
c0104d09:	01 d0                	add    %edx,%eax
c0104d0b:	c1 e0 02             	shl    $0x2,%eax
c0104d0e:	01 c8                	add    %ecx,%eax
c0104d10:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104d13:	8b 58 10             	mov    0x10(%eax),%ebx
c0104d16:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d19:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d1c:	01 c8                	add    %ecx,%eax
c0104d1e:	11 da                	adc    %ebx,%edx
c0104d20:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104d23:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104d26:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104d29:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d2c:	89 d0                	mov    %edx,%eax
c0104d2e:	c1 e0 02             	shl    $0x2,%eax
c0104d31:	01 d0                	add    %edx,%eax
c0104d33:	c1 e0 02             	shl    $0x2,%eax
c0104d36:	01 c8                	add    %ecx,%eax
c0104d38:	83 c0 14             	add    $0x14,%eax
c0104d3b:	8b 00                	mov    (%eax),%eax
c0104d3d:	83 f8 01             	cmp    $0x1,%eax
c0104d40:	0f 85 0a 01 00 00    	jne    c0104e50 <page_init+0x3d4>
            if (begin < freemem) {
c0104d46:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104d49:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d4e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104d51:	72 17                	jb     c0104d6a <page_init+0x2ee>
c0104d53:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104d56:	77 05                	ja     c0104d5d <page_init+0x2e1>
c0104d58:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104d5b:	76 0d                	jbe    c0104d6a <page_init+0x2ee>
                begin = freemem;
c0104d5d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104d60:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104d63:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104d6a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104d6e:	72 1d                	jb     c0104d8d <page_init+0x311>
c0104d70:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104d74:	77 09                	ja     c0104d7f <page_init+0x303>
c0104d76:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104d7d:	76 0e                	jbe    c0104d8d <page_init+0x311>
                end = KMEMSIZE;
c0104d7f:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104d86:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104d8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d93:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104d96:	0f 87 b4 00 00 00    	ja     c0104e50 <page_init+0x3d4>
c0104d9c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104d9f:	72 09                	jb     c0104daa <page_init+0x32e>
c0104da1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104da4:	0f 83 a6 00 00 00    	jae    c0104e50 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0104daa:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104db1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104db4:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104db7:	01 d0                	add    %edx,%eax
c0104db9:	83 e8 01             	sub    $0x1,%eax
c0104dbc:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104dbf:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104dc2:	ba 00 00 00 00       	mov    $0x0,%edx
c0104dc7:	f7 75 9c             	divl   -0x64(%ebp)
c0104dca:	89 d0                	mov    %edx,%eax
c0104dcc:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104dcf:	29 c2                	sub    %eax,%edx
c0104dd1:	89 d0                	mov    %edx,%eax
c0104dd3:	ba 00 00 00 00       	mov    $0x0,%edx
c0104dd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104ddb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104dde:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104de1:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104de4:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104de7:	ba 00 00 00 00       	mov    $0x0,%edx
c0104dec:	89 c7                	mov    %eax,%edi
c0104dee:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104df4:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104df7:	89 d0                	mov    %edx,%eax
c0104df9:	83 e0 00             	and    $0x0,%eax
c0104dfc:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104dff:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104e02:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104e05:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104e08:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104e0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e0e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104e11:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104e14:	77 3a                	ja     c0104e50 <page_init+0x3d4>
c0104e16:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104e19:	72 05                	jb     c0104e20 <page_init+0x3a4>
c0104e1b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104e1e:	73 30                	jae    c0104e50 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104e20:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104e23:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104e26:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104e29:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104e2c:	29 c8                	sub    %ecx,%eax
c0104e2e:	19 da                	sbb    %ebx,%edx
c0104e30:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104e34:	c1 ea 0c             	shr    $0xc,%edx
c0104e37:	89 c3                	mov    %eax,%ebx
c0104e39:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104e3c:	89 04 24             	mov    %eax,(%esp)
c0104e3f:	e8 a5 f8 ff ff       	call   c01046e9 <pa2page>
c0104e44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104e48:	89 04 24             	mov    %eax,(%esp)
c0104e4b:	e8 78 fb ff ff       	call   c01049c8 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104e50:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104e54:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104e57:	8b 00                	mov    (%eax),%eax
c0104e59:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104e5c:	0f 8f 7e fe ff ff    	jg     c0104ce0 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104e62:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104e68:	5b                   	pop    %ebx
c0104e69:	5e                   	pop    %esi
c0104e6a:	5f                   	pop    %edi
c0104e6b:	5d                   	pop    %ebp
c0104e6c:	c3                   	ret    

c0104e6d <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104e6d:	55                   	push   %ebp
c0104e6e:	89 e5                	mov    %esp,%ebp
c0104e70:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104e73:	8b 45 14             	mov    0x14(%ebp),%eax
c0104e76:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e79:	31 d0                	xor    %edx,%eax
c0104e7b:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e80:	85 c0                	test   %eax,%eax
c0104e82:	74 24                	je     c0104ea8 <boot_map_segment+0x3b>
c0104e84:	c7 44 24 0c 46 7a 10 	movl   $0xc0107a46,0xc(%esp)
c0104e8b:	c0 
c0104e8c:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0104e93:	c0 
c0104e94:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0104e9b:	00 
c0104e9c:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0104ea3:	e8 3f be ff ff       	call   c0100ce7 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104ea8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104eb2:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104eb7:	89 c2                	mov    %eax,%edx
c0104eb9:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ebc:	01 c2                	add    %eax,%edx
c0104ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ec1:	01 d0                	add    %edx,%eax
c0104ec3:	83 e8 01             	sub    $0x1,%eax
c0104ec6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ecc:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ed1:	f7 75 f0             	divl   -0x10(%ebp)
c0104ed4:	89 d0                	mov    %edx,%eax
c0104ed6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104ed9:	29 c2                	sub    %eax,%edx
c0104edb:	89 d0                	mov    %edx,%eax
c0104edd:	c1 e8 0c             	shr    $0xc,%eax
c0104ee0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ee6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104ee9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104eec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104ef1:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104ef4:	8b 45 14             	mov    0x14(%ebp),%eax
c0104ef7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104efd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f02:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104f05:	eb 6b                	jmp    c0104f72 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104f07:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104f0e:	00 
c0104f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f16:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f19:	89 04 24             	mov    %eax,(%esp)
c0104f1c:	e8 82 01 00 00       	call   c01050a3 <get_pte>
c0104f21:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104f24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104f28:	75 24                	jne    c0104f4e <boot_map_segment+0xe1>
c0104f2a:	c7 44 24 0c 72 7a 10 	movl   $0xc0107a72,0xc(%esp)
c0104f31:	c0 
c0104f32:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0104f39:	c0 
c0104f3a:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104f41:	00 
c0104f42:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0104f49:	e8 99 bd ff ff       	call   c0100ce7 <__panic>
        *ptep = pa | PTE_P | perm;
c0104f4e:	8b 45 18             	mov    0x18(%ebp),%eax
c0104f51:	8b 55 14             	mov    0x14(%ebp),%edx
c0104f54:	09 d0                	or     %edx,%eax
c0104f56:	83 c8 01             	or     $0x1,%eax
c0104f59:	89 c2                	mov    %eax,%edx
c0104f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f5e:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104f60:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104f64:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104f6b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104f72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f76:	75 8f                	jne    c0104f07 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104f78:	c9                   	leave  
c0104f79:	c3                   	ret    

c0104f7a <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104f7a:	55                   	push   %ebp
c0104f7b:	89 e5                	mov    %esp,%ebp
c0104f7d:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104f80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f87:	e8 5b fa ff ff       	call   c01049e7 <alloc_pages>
c0104f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104f8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f93:	75 1c                	jne    c0104fb1 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104f95:	c7 44 24 08 7f 7a 10 	movl   $0xc0107a7f,0x8(%esp)
c0104f9c:	c0 
c0104f9d:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104fa4:	00 
c0104fa5:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0104fac:	e8 36 bd ff ff       	call   c0100ce7 <__panic>
    }
    return page2kva(p);
c0104fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fb4:	89 04 24             	mov    %eax,(%esp)
c0104fb7:	e8 7c f7 ff ff       	call   c0104738 <page2kva>
}
c0104fbc:	c9                   	leave  
c0104fbd:	c3                   	ret    

c0104fbe <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104fbe:	55                   	push   %ebp
c0104fbf:	89 e5                	mov    %esp,%ebp
c0104fc1:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104fc4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104fc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fcc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104fd3:	77 23                	ja     c0104ff8 <pmm_init+0x3a>
c0104fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104fdc:	c7 44 24 08 14 7a 10 	movl   $0xc0107a14,0x8(%esp)
c0104fe3:	c0 
c0104fe4:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0104feb:	00 
c0104fec:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0104ff3:	e8 ef bc ff ff       	call   c0100ce7 <__panic>
c0104ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ffb:	05 00 00 00 40       	add    $0x40000000,%eax
c0105000:	a3 a0 cf 11 c0       	mov    %eax,0xc011cfa0
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0105005:	e8 8b f9 ff ff       	call   c0104995 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010500a:	e8 6d fa ff ff       	call   c0104a7c <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010500f:	e8 db 03 00 00       	call   c01053ef <check_alloc_page>

    check_pgdir();
c0105014:	e8 f4 03 00 00       	call   c010540d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0105019:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010501e:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0105024:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105029:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010502c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105033:	77 23                	ja     c0105058 <pmm_init+0x9a>
c0105035:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105038:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010503c:	c7 44 24 08 14 7a 10 	movl   $0xc0107a14,0x8(%esp)
c0105043:	c0 
c0105044:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c010504b:	00 
c010504c:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105053:	e8 8f bc ff ff       	call   c0100ce7 <__panic>
c0105058:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010505b:	05 00 00 00 40       	add    $0x40000000,%eax
c0105060:	83 c8 03             	or     $0x3,%eax
c0105063:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105065:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010506a:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105071:	00 
c0105072:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105079:	00 
c010507a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105081:	38 
c0105082:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0105089:	c0 
c010508a:	89 04 24             	mov    %eax,(%esp)
c010508d:	e8 db fd ff ff       	call   c0104e6d <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105092:	e8 0f f8 ff ff       	call   c01048a6 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0105097:	e8 0c 0a 00 00       	call   c0105aa8 <check_boot_pgdir>

    print_pgdir();
c010509c:	e8 94 0e 00 00       	call   c0105f35 <print_pgdir>

}
c01050a1:	c9                   	leave  
c01050a2:	c3                   	ret    

c01050a3 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01050a3:	55                   	push   %ebp
c01050a4:	89 e5                	mov    %esp,%ebp
c01050a6:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01050a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050ac:	c1 e8 16             	shr    $0x16,%eax
c01050af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01050b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01050b9:	01 d0                	add    %edx,%eax
c01050bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01050be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050c1:	8b 00                	mov    (%eax),%eax
c01050c3:	83 e0 01             	and    $0x1,%eax
c01050c6:	85 c0                	test   %eax,%eax
c01050c8:	0f 85 af 00 00 00    	jne    c010517d <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01050ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01050d2:	74 15                	je     c01050e9 <get_pte+0x46>
c01050d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050db:	e8 07 f9 ff ff       	call   c01049e7 <alloc_pages>
c01050e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01050e7:	75 0a                	jne    c01050f3 <get_pte+0x50>
            return NULL;
c01050e9:	b8 00 00 00 00       	mov    $0x0,%eax
c01050ee:	e9 e6 00 00 00       	jmp    c01051d9 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01050f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050fa:	00 
c01050fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050fe:	89 04 24             	mov    %eax,(%esp)
c0105101:	e8 e6 f6 ff ff       	call   c01047ec <set_page_ref>
        uintptr_t pa = page2pa(page);
c0105106:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105109:	89 04 24             	mov    %eax,(%esp)
c010510c:	e8 c2 f5 ff ff       	call   c01046d3 <page2pa>
c0105111:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0105114:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105117:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010511a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010511d:	c1 e8 0c             	shr    $0xc,%eax
c0105120:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105123:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0105128:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010512b:	72 23                	jb     c0105150 <get_pte+0xad>
c010512d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105130:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105134:	c7 44 24 08 70 79 10 	movl   $0xc0107970,0x8(%esp)
c010513b:	c0 
c010513c:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
c0105143:	00 
c0105144:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010514b:	e8 97 bb ff ff       	call   c0100ce7 <__panic>
c0105150:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105153:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105158:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010515f:	00 
c0105160:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105167:	00 
c0105168:	89 04 24             	mov    %eax,(%esp)
c010516b:	e8 e3 18 00 00       	call   c0106a53 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0105170:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105173:	83 c8 07             	or     $0x7,%eax
c0105176:	89 c2                	mov    %eax,%edx
c0105178:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010517b:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010517d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105180:	8b 00                	mov    (%eax),%eax
c0105182:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105187:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010518a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010518d:	c1 e8 0c             	shr    $0xc,%eax
c0105190:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105193:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0105198:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010519b:	72 23                	jb     c01051c0 <get_pte+0x11d>
c010519d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01051a4:	c7 44 24 08 70 79 10 	movl   $0xc0107970,0x8(%esp)
c01051ab:	c0 
c01051ac:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
c01051b3:	00 
c01051b4:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01051bb:	e8 27 bb ff ff       	call   c0100ce7 <__panic>
c01051c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051c3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01051c8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01051cb:	c1 ea 0c             	shr    $0xc,%edx
c01051ce:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01051d4:	c1 e2 02             	shl    $0x2,%edx
c01051d7:	01 d0                	add    %edx,%eax
}
c01051d9:	c9                   	leave  
c01051da:	c3                   	ret    

c01051db <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01051db:	55                   	push   %ebp
c01051dc:	89 e5                	mov    %esp,%ebp
c01051de:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01051e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01051e8:	00 
c01051e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01051ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01051f3:	89 04 24             	mov    %eax,(%esp)
c01051f6:	e8 a8 fe ff ff       	call   c01050a3 <get_pte>
c01051fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01051fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105202:	74 08                	je     c010520c <get_page+0x31>
        *ptep_store = ptep;
c0105204:	8b 45 10             	mov    0x10(%ebp),%eax
c0105207:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010520a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010520c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105210:	74 1b                	je     c010522d <get_page+0x52>
c0105212:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105215:	8b 00                	mov    (%eax),%eax
c0105217:	83 e0 01             	and    $0x1,%eax
c010521a:	85 c0                	test   %eax,%eax
c010521c:	74 0f                	je     c010522d <get_page+0x52>
        return pte2page(*ptep);
c010521e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105221:	8b 00                	mov    (%eax),%eax
c0105223:	89 04 24             	mov    %eax,(%esp)
c0105226:	e8 61 f5 ff ff       	call   c010478c <pte2page>
c010522b:	eb 05                	jmp    c0105232 <get_page+0x57>
    }
    return NULL;
c010522d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105232:	c9                   	leave  
c0105233:	c3                   	ret    

c0105234 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105234:	55                   	push   %ebp
c0105235:	89 e5                	mov    %esp,%ebp
c0105237:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010523a:	8b 45 10             	mov    0x10(%ebp),%eax
c010523d:	8b 00                	mov    (%eax),%eax
c010523f:	83 e0 01             	and    $0x1,%eax
c0105242:	85 c0                	test   %eax,%eax
c0105244:	74 4d                	je     c0105293 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0105246:	8b 45 10             	mov    0x10(%ebp),%eax
c0105249:	8b 00                	mov    (%eax),%eax
c010524b:	89 04 24             	mov    %eax,(%esp)
c010524e:	e8 39 f5 ff ff       	call   c010478c <pte2page>
c0105253:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0105256:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105259:	89 04 24             	mov    %eax,(%esp)
c010525c:	e8 af f5 ff ff       	call   c0104810 <page_ref_dec>
c0105261:	85 c0                	test   %eax,%eax
c0105263:	75 13                	jne    c0105278 <page_remove_pte+0x44>
            free_page(page);
c0105265:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010526c:	00 
c010526d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105270:	89 04 24             	mov    %eax,(%esp)
c0105273:	e8 a7 f7 ff ff       	call   c0104a1f <free_pages>
        }
        *ptep = 0;
c0105278:	8b 45 10             	mov    0x10(%ebp),%eax
c010527b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0105281:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105284:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105288:	8b 45 08             	mov    0x8(%ebp),%eax
c010528b:	89 04 24             	mov    %eax,(%esp)
c010528e:	e8 ff 00 00 00       	call   c0105392 <tlb_invalidate>
    }
}
c0105293:	c9                   	leave  
c0105294:	c3                   	ret    

c0105295 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105295:	55                   	push   %ebp
c0105296:	89 e5                	mov    %esp,%ebp
c0105298:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010529b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01052a2:	00 
c01052a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01052ad:	89 04 24             	mov    %eax,(%esp)
c01052b0:	e8 ee fd ff ff       	call   c01050a3 <get_pte>
c01052b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01052b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052bc:	74 19                	je     c01052d7 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01052be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052c1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01052c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01052cf:	89 04 24             	mov    %eax,(%esp)
c01052d2:	e8 5d ff ff ff       	call   c0105234 <page_remove_pte>
    }
}
c01052d7:	c9                   	leave  
c01052d8:	c3                   	ret    

c01052d9 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01052d9:	55                   	push   %ebp
c01052da:	89 e5                	mov    %esp,%ebp
c01052dc:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01052df:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01052e6:	00 
c01052e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01052ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01052f1:	89 04 24             	mov    %eax,(%esp)
c01052f4:	e8 aa fd ff ff       	call   c01050a3 <get_pte>
c01052f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01052fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105300:	75 0a                	jne    c010530c <page_insert+0x33>
        return -E_NO_MEM;
c0105302:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105307:	e9 84 00 00 00       	jmp    c0105390 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010530c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010530f:	89 04 24             	mov    %eax,(%esp)
c0105312:	e8 e2 f4 ff ff       	call   c01047f9 <page_ref_inc>
    if (*ptep & PTE_P) {
c0105317:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010531a:	8b 00                	mov    (%eax),%eax
c010531c:	83 e0 01             	and    $0x1,%eax
c010531f:	85 c0                	test   %eax,%eax
c0105321:	74 3e                	je     c0105361 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0105323:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105326:	8b 00                	mov    (%eax),%eax
c0105328:	89 04 24             	mov    %eax,(%esp)
c010532b:	e8 5c f4 ff ff       	call   c010478c <pte2page>
c0105330:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105333:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105336:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105339:	75 0d                	jne    c0105348 <page_insert+0x6f>
            page_ref_dec(page);
c010533b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010533e:	89 04 24             	mov    %eax,(%esp)
c0105341:	e8 ca f4 ff ff       	call   c0104810 <page_ref_dec>
c0105346:	eb 19                	jmp    c0105361 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105348:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010534b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010534f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105352:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105356:	8b 45 08             	mov    0x8(%ebp),%eax
c0105359:	89 04 24             	mov    %eax,(%esp)
c010535c:	e8 d3 fe ff ff       	call   c0105234 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105361:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105364:	89 04 24             	mov    %eax,(%esp)
c0105367:	e8 67 f3 ff ff       	call   c01046d3 <page2pa>
c010536c:	0b 45 14             	or     0x14(%ebp),%eax
c010536f:	83 c8 01             	or     $0x1,%eax
c0105372:	89 c2                	mov    %eax,%edx
c0105374:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105377:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105379:	8b 45 10             	mov    0x10(%ebp),%eax
c010537c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105380:	8b 45 08             	mov    0x8(%ebp),%eax
c0105383:	89 04 24             	mov    %eax,(%esp)
c0105386:	e8 07 00 00 00       	call   c0105392 <tlb_invalidate>
    return 0;
c010538b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105390:	c9                   	leave  
c0105391:	c3                   	ret    

c0105392 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105392:	55                   	push   %ebp
c0105393:	89 e5                	mov    %esp,%ebp
c0105395:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105398:	0f 20 d8             	mov    %cr3,%eax
c010539b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010539e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01053a1:	89 c2                	mov    %eax,%edx
c01053a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01053a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053a9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01053b0:	77 23                	ja     c01053d5 <tlb_invalidate+0x43>
c01053b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01053b9:	c7 44 24 08 14 7a 10 	movl   $0xc0107a14,0x8(%esp)
c01053c0:	c0 
c01053c1:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c01053c8:	00 
c01053c9:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01053d0:	e8 12 b9 ff ff       	call   c0100ce7 <__panic>
c01053d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053d8:	05 00 00 00 40       	add    $0x40000000,%eax
c01053dd:	39 c2                	cmp    %eax,%edx
c01053df:	75 0c                	jne    c01053ed <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01053e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01053e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053ea:	0f 01 38             	invlpg (%eax)
    }
}
c01053ed:	c9                   	leave  
c01053ee:	c3                   	ret    

c01053ef <check_alloc_page>:

static void
check_alloc_page(void) {
c01053ef:	55                   	push   %ebp
c01053f0:	89 e5                	mov    %esp,%ebp
c01053f2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01053f5:	a1 9c cf 11 c0       	mov    0xc011cf9c,%eax
c01053fa:	8b 40 18             	mov    0x18(%eax),%eax
c01053fd:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01053ff:	c7 04 24 98 7a 10 c0 	movl   $0xc0107a98,(%esp)
c0105406:	e8 48 af ff ff       	call   c0100353 <cprintf>
}
c010540b:	c9                   	leave  
c010540c:	c3                   	ret    

c010540d <check_pgdir>:

static void
check_pgdir(void) {
c010540d:	55                   	push   %ebp
c010540e:	89 e5                	mov    %esp,%ebp
c0105410:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105413:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0105418:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010541d:	76 24                	jbe    c0105443 <check_pgdir+0x36>
c010541f:	c7 44 24 0c b7 7a 10 	movl   $0xc0107ab7,0xc(%esp)
c0105426:	c0 
c0105427:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c010542e:	c0 
c010542f:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0105436:	00 
c0105437:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010543e:	e8 a4 b8 ff ff       	call   c0100ce7 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105443:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105448:	85 c0                	test   %eax,%eax
c010544a:	74 0e                	je     c010545a <check_pgdir+0x4d>
c010544c:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105451:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105456:	85 c0                	test   %eax,%eax
c0105458:	74 24                	je     c010547e <check_pgdir+0x71>
c010545a:	c7 44 24 0c d4 7a 10 	movl   $0xc0107ad4,0xc(%esp)
c0105461:	c0 
c0105462:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105469:	c0 
c010546a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0105471:	00 
c0105472:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105479:	e8 69 b8 ff ff       	call   c0100ce7 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010547e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105483:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010548a:	00 
c010548b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105492:	00 
c0105493:	89 04 24             	mov    %eax,(%esp)
c0105496:	e8 40 fd ff ff       	call   c01051db <get_page>
c010549b:	85 c0                	test   %eax,%eax
c010549d:	74 24                	je     c01054c3 <check_pgdir+0xb6>
c010549f:	c7 44 24 0c 0c 7b 10 	movl   $0xc0107b0c,0xc(%esp)
c01054a6:	c0 
c01054a7:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01054ae:	c0 
c01054af:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c01054b6:	00 
c01054b7:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01054be:	e8 24 b8 ff ff       	call   c0100ce7 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01054c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01054ca:	e8 18 f5 ff ff       	call   c01049e7 <alloc_pages>
c01054cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01054d2:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01054d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01054de:	00 
c01054df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01054e6:	00 
c01054e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054ea:	89 54 24 04          	mov    %edx,0x4(%esp)
c01054ee:	89 04 24             	mov    %eax,(%esp)
c01054f1:	e8 e3 fd ff ff       	call   c01052d9 <page_insert>
c01054f6:	85 c0                	test   %eax,%eax
c01054f8:	74 24                	je     c010551e <check_pgdir+0x111>
c01054fa:	c7 44 24 0c 34 7b 10 	movl   $0xc0107b34,0xc(%esp)
c0105501:	c0 
c0105502:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105509:	c0 
c010550a:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0105511:	00 
c0105512:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105519:	e8 c9 b7 ff ff       	call   c0100ce7 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010551e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105523:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010552a:	00 
c010552b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105532:	00 
c0105533:	89 04 24             	mov    %eax,(%esp)
c0105536:	e8 68 fb ff ff       	call   c01050a3 <get_pte>
c010553b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010553e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105542:	75 24                	jne    c0105568 <check_pgdir+0x15b>
c0105544:	c7 44 24 0c 60 7b 10 	movl   $0xc0107b60,0xc(%esp)
c010554b:	c0 
c010554c:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105553:	c0 
c0105554:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c010555b:	00 
c010555c:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105563:	e8 7f b7 ff ff       	call   c0100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
c0105568:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010556b:	8b 00                	mov    (%eax),%eax
c010556d:	89 04 24             	mov    %eax,(%esp)
c0105570:	e8 17 f2 ff ff       	call   c010478c <pte2page>
c0105575:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105578:	74 24                	je     c010559e <check_pgdir+0x191>
c010557a:	c7 44 24 0c 8d 7b 10 	movl   $0xc0107b8d,0xc(%esp)
c0105581:	c0 
c0105582:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105589:	c0 
c010558a:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0105591:	00 
c0105592:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105599:	e8 49 b7 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p1) == 1);
c010559e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055a1:	89 04 24             	mov    %eax,(%esp)
c01055a4:	e8 39 f2 ff ff       	call   c01047e2 <page_ref>
c01055a9:	83 f8 01             	cmp    $0x1,%eax
c01055ac:	74 24                	je     c01055d2 <check_pgdir+0x1c5>
c01055ae:	c7 44 24 0c a3 7b 10 	movl   $0xc0107ba3,0xc(%esp)
c01055b5:	c0 
c01055b6:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01055bd:	c0 
c01055be:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c01055c5:	00 
c01055c6:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01055cd:	e8 15 b7 ff ff       	call   c0100ce7 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01055d2:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01055d7:	8b 00                	mov    (%eax),%eax
c01055d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01055de:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055e4:	c1 e8 0c             	shr    $0xc,%eax
c01055e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01055ea:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c01055ef:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01055f2:	72 23                	jb     c0105617 <check_pgdir+0x20a>
c01055f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01055fb:	c7 44 24 08 70 79 10 	movl   $0xc0107970,0x8(%esp)
c0105602:	c0 
c0105603:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c010560a:	00 
c010560b:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105612:	e8 d0 b6 ff ff       	call   c0100ce7 <__panic>
c0105617:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010561a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010561f:	83 c0 04             	add    $0x4,%eax
c0105622:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0105625:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010562a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105631:	00 
c0105632:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105639:	00 
c010563a:	89 04 24             	mov    %eax,(%esp)
c010563d:	e8 61 fa ff ff       	call   c01050a3 <get_pte>
c0105642:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105645:	74 24                	je     c010566b <check_pgdir+0x25e>
c0105647:	c7 44 24 0c b8 7b 10 	movl   $0xc0107bb8,0xc(%esp)
c010564e:	c0 
c010564f:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105656:	c0 
c0105657:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c010565e:	00 
c010565f:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105666:	e8 7c b6 ff ff       	call   c0100ce7 <__panic>

    p2 = alloc_page();
c010566b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105672:	e8 70 f3 ff ff       	call   c01049e7 <alloc_pages>
c0105677:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010567a:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010567f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0105686:	00 
c0105687:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010568e:	00 
c010568f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105692:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105696:	89 04 24             	mov    %eax,(%esp)
c0105699:	e8 3b fc ff ff       	call   c01052d9 <page_insert>
c010569e:	85 c0                	test   %eax,%eax
c01056a0:	74 24                	je     c01056c6 <check_pgdir+0x2b9>
c01056a2:	c7 44 24 0c e0 7b 10 	movl   $0xc0107be0,0xc(%esp)
c01056a9:	c0 
c01056aa:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01056b1:	c0 
c01056b2:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c01056b9:	00 
c01056ba:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01056c1:	e8 21 b6 ff ff       	call   c0100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01056c6:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01056cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056d2:	00 
c01056d3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01056da:	00 
c01056db:	89 04 24             	mov    %eax,(%esp)
c01056de:	e8 c0 f9 ff ff       	call   c01050a3 <get_pte>
c01056e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056ea:	75 24                	jne    c0105710 <check_pgdir+0x303>
c01056ec:	c7 44 24 0c 18 7c 10 	movl   $0xc0107c18,0xc(%esp)
c01056f3:	c0 
c01056f4:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01056fb:	c0 
c01056fc:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0105703:	00 
c0105704:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010570b:	e8 d7 b5 ff ff       	call   c0100ce7 <__panic>
    assert(*ptep & PTE_U);
c0105710:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105713:	8b 00                	mov    (%eax),%eax
c0105715:	83 e0 04             	and    $0x4,%eax
c0105718:	85 c0                	test   %eax,%eax
c010571a:	75 24                	jne    c0105740 <check_pgdir+0x333>
c010571c:	c7 44 24 0c 48 7c 10 	movl   $0xc0107c48,0xc(%esp)
c0105723:	c0 
c0105724:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c010572b:	c0 
c010572c:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0105733:	00 
c0105734:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010573b:	e8 a7 b5 ff ff       	call   c0100ce7 <__panic>
    assert(*ptep & PTE_W);
c0105740:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105743:	8b 00                	mov    (%eax),%eax
c0105745:	83 e0 02             	and    $0x2,%eax
c0105748:	85 c0                	test   %eax,%eax
c010574a:	75 24                	jne    c0105770 <check_pgdir+0x363>
c010574c:	c7 44 24 0c 56 7c 10 	movl   $0xc0107c56,0xc(%esp)
c0105753:	c0 
c0105754:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c010575b:	c0 
c010575c:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0105763:	00 
c0105764:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010576b:	e8 77 b5 ff ff       	call   c0100ce7 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105770:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105775:	8b 00                	mov    (%eax),%eax
c0105777:	83 e0 04             	and    $0x4,%eax
c010577a:	85 c0                	test   %eax,%eax
c010577c:	75 24                	jne    c01057a2 <check_pgdir+0x395>
c010577e:	c7 44 24 0c 64 7c 10 	movl   $0xc0107c64,0xc(%esp)
c0105785:	c0 
c0105786:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c010578d:	c0 
c010578e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0105795:	00 
c0105796:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010579d:	e8 45 b5 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 1);
c01057a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057a5:	89 04 24             	mov    %eax,(%esp)
c01057a8:	e8 35 f0 ff ff       	call   c01047e2 <page_ref>
c01057ad:	83 f8 01             	cmp    $0x1,%eax
c01057b0:	74 24                	je     c01057d6 <check_pgdir+0x3c9>
c01057b2:	c7 44 24 0c 7a 7c 10 	movl   $0xc0107c7a,0xc(%esp)
c01057b9:	c0 
c01057ba:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01057c1:	c0 
c01057c2:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c01057c9:	00 
c01057ca:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01057d1:	e8 11 b5 ff ff       	call   c0100ce7 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01057d6:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01057db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01057e2:	00 
c01057e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01057ea:	00 
c01057eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057ee:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057f2:	89 04 24             	mov    %eax,(%esp)
c01057f5:	e8 df fa ff ff       	call   c01052d9 <page_insert>
c01057fa:	85 c0                	test   %eax,%eax
c01057fc:	74 24                	je     c0105822 <check_pgdir+0x415>
c01057fe:	c7 44 24 0c 8c 7c 10 	movl   $0xc0107c8c,0xc(%esp)
c0105805:	c0 
c0105806:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c010580d:	c0 
c010580e:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0105815:	00 
c0105816:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010581d:	e8 c5 b4 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p1) == 2);
c0105822:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105825:	89 04 24             	mov    %eax,(%esp)
c0105828:	e8 b5 ef ff ff       	call   c01047e2 <page_ref>
c010582d:	83 f8 02             	cmp    $0x2,%eax
c0105830:	74 24                	je     c0105856 <check_pgdir+0x449>
c0105832:	c7 44 24 0c b8 7c 10 	movl   $0xc0107cb8,0xc(%esp)
c0105839:	c0 
c010583a:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105841:	c0 
c0105842:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0105849:	00 
c010584a:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105851:	e8 91 b4 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 0);
c0105856:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105859:	89 04 24             	mov    %eax,(%esp)
c010585c:	e8 81 ef ff ff       	call   c01047e2 <page_ref>
c0105861:	85 c0                	test   %eax,%eax
c0105863:	74 24                	je     c0105889 <check_pgdir+0x47c>
c0105865:	c7 44 24 0c ca 7c 10 	movl   $0xc0107cca,0xc(%esp)
c010586c:	c0 
c010586d:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105874:	c0 
c0105875:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c010587c:	00 
c010587d:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105884:	e8 5e b4 ff ff       	call   c0100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105889:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010588e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105895:	00 
c0105896:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010589d:	00 
c010589e:	89 04 24             	mov    %eax,(%esp)
c01058a1:	e8 fd f7 ff ff       	call   c01050a3 <get_pte>
c01058a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01058ad:	75 24                	jne    c01058d3 <check_pgdir+0x4c6>
c01058af:	c7 44 24 0c 18 7c 10 	movl   $0xc0107c18,0xc(%esp)
c01058b6:	c0 
c01058b7:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01058be:	c0 
c01058bf:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c01058c6:	00 
c01058c7:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01058ce:	e8 14 b4 ff ff       	call   c0100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
c01058d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058d6:	8b 00                	mov    (%eax),%eax
c01058d8:	89 04 24             	mov    %eax,(%esp)
c01058db:	e8 ac ee ff ff       	call   c010478c <pte2page>
c01058e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01058e3:	74 24                	je     c0105909 <check_pgdir+0x4fc>
c01058e5:	c7 44 24 0c 8d 7b 10 	movl   $0xc0107b8d,0xc(%esp)
c01058ec:	c0 
c01058ed:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01058f4:	c0 
c01058f5:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c01058fc:	00 
c01058fd:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105904:	e8 de b3 ff ff       	call   c0100ce7 <__panic>
    assert((*ptep & PTE_U) == 0);
c0105909:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010590c:	8b 00                	mov    (%eax),%eax
c010590e:	83 e0 04             	and    $0x4,%eax
c0105911:	85 c0                	test   %eax,%eax
c0105913:	74 24                	je     c0105939 <check_pgdir+0x52c>
c0105915:	c7 44 24 0c dc 7c 10 	movl   $0xc0107cdc,0xc(%esp)
c010591c:	c0 
c010591d:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105924:	c0 
c0105925:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c010592c:	00 
c010592d:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105934:	e8 ae b3 ff ff       	call   c0100ce7 <__panic>

    page_remove(boot_pgdir, 0x0);
c0105939:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010593e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105945:	00 
c0105946:	89 04 24             	mov    %eax,(%esp)
c0105949:	e8 47 f9 ff ff       	call   c0105295 <page_remove>
    assert(page_ref(p1) == 1);
c010594e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105951:	89 04 24             	mov    %eax,(%esp)
c0105954:	e8 89 ee ff ff       	call   c01047e2 <page_ref>
c0105959:	83 f8 01             	cmp    $0x1,%eax
c010595c:	74 24                	je     c0105982 <check_pgdir+0x575>
c010595e:	c7 44 24 0c a3 7b 10 	movl   $0xc0107ba3,0xc(%esp)
c0105965:	c0 
c0105966:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c010596d:	c0 
c010596e:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0105975:	00 
c0105976:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c010597d:	e8 65 b3 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 0);
c0105982:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105985:	89 04 24             	mov    %eax,(%esp)
c0105988:	e8 55 ee ff ff       	call   c01047e2 <page_ref>
c010598d:	85 c0                	test   %eax,%eax
c010598f:	74 24                	je     c01059b5 <check_pgdir+0x5a8>
c0105991:	c7 44 24 0c ca 7c 10 	movl   $0xc0107cca,0xc(%esp)
c0105998:	c0 
c0105999:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01059a0:	c0 
c01059a1:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c01059a8:	00 
c01059a9:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01059b0:	e8 32 b3 ff ff       	call   c0100ce7 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01059b5:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01059ba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01059c1:	00 
c01059c2:	89 04 24             	mov    %eax,(%esp)
c01059c5:	e8 cb f8 ff ff       	call   c0105295 <page_remove>
    assert(page_ref(p1) == 0);
c01059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059cd:	89 04 24             	mov    %eax,(%esp)
c01059d0:	e8 0d ee ff ff       	call   c01047e2 <page_ref>
c01059d5:	85 c0                	test   %eax,%eax
c01059d7:	74 24                	je     c01059fd <check_pgdir+0x5f0>
c01059d9:	c7 44 24 0c f1 7c 10 	movl   $0xc0107cf1,0xc(%esp)
c01059e0:	c0 
c01059e1:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c01059e8:	c0 
c01059e9:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c01059f0:	00 
c01059f1:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c01059f8:	e8 ea b2 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 0);
c01059fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a00:	89 04 24             	mov    %eax,(%esp)
c0105a03:	e8 da ed ff ff       	call   c01047e2 <page_ref>
c0105a08:	85 c0                	test   %eax,%eax
c0105a0a:	74 24                	je     c0105a30 <check_pgdir+0x623>
c0105a0c:	c7 44 24 0c ca 7c 10 	movl   $0xc0107cca,0xc(%esp)
c0105a13:	c0 
c0105a14:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105a1b:	c0 
c0105a1c:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0105a23:	00 
c0105a24:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105a2b:	e8 b7 b2 ff ff       	call   c0100ce7 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105a30:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105a35:	8b 00                	mov    (%eax),%eax
c0105a37:	89 04 24             	mov    %eax,(%esp)
c0105a3a:	e8 8b ed ff ff       	call   c01047ca <pde2page>
c0105a3f:	89 04 24             	mov    %eax,(%esp)
c0105a42:	e8 9b ed ff ff       	call   c01047e2 <page_ref>
c0105a47:	83 f8 01             	cmp    $0x1,%eax
c0105a4a:	74 24                	je     c0105a70 <check_pgdir+0x663>
c0105a4c:	c7 44 24 0c 04 7d 10 	movl   $0xc0107d04,0xc(%esp)
c0105a53:	c0 
c0105a54:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105a5b:	c0 
c0105a5c:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0105a63:	00 
c0105a64:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105a6b:	e8 77 b2 ff ff       	call   c0100ce7 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105a70:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105a75:	8b 00                	mov    (%eax),%eax
c0105a77:	89 04 24             	mov    %eax,(%esp)
c0105a7a:	e8 4b ed ff ff       	call   c01047ca <pde2page>
c0105a7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a86:	00 
c0105a87:	89 04 24             	mov    %eax,(%esp)
c0105a8a:	e8 90 ef ff ff       	call   c0104a1f <free_pages>
    boot_pgdir[0] = 0;
c0105a8f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105a94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105a9a:	c7 04 24 2b 7d 10 c0 	movl   $0xc0107d2b,(%esp)
c0105aa1:	e8 ad a8 ff ff       	call   c0100353 <cprintf>
}
c0105aa6:	c9                   	leave  
c0105aa7:	c3                   	ret    

c0105aa8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105aa8:	55                   	push   %ebp
c0105aa9:	89 e5                	mov    %esp,%ebp
c0105aab:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105aae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105ab5:	e9 ca 00 00 00       	jmp    c0105b84 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ac3:	c1 e8 0c             	shr    $0xc,%eax
c0105ac6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ac9:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0105ace:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105ad1:	72 23                	jb     c0105af6 <check_boot_pgdir+0x4e>
c0105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ad6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ada:	c7 44 24 08 70 79 10 	movl   $0xc0107970,0x8(%esp)
c0105ae1:	c0 
c0105ae2:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0105ae9:	00 
c0105aea:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105af1:	e8 f1 b1 ff ff       	call   c0100ce7 <__panic>
c0105af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105af9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105afe:	89 c2                	mov    %eax,%edx
c0105b00:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105b05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b0c:	00 
c0105b0d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b11:	89 04 24             	mov    %eax,(%esp)
c0105b14:	e8 8a f5 ff ff       	call   c01050a3 <get_pte>
c0105b19:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105b1c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b20:	75 24                	jne    c0105b46 <check_boot_pgdir+0x9e>
c0105b22:	c7 44 24 0c 48 7d 10 	movl   $0xc0107d48,0xc(%esp)
c0105b29:	c0 
c0105b2a:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105b31:	c0 
c0105b32:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0105b39:	00 
c0105b3a:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105b41:	e8 a1 b1 ff ff       	call   c0100ce7 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b49:	8b 00                	mov    (%eax),%eax
c0105b4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105b50:	89 c2                	mov    %eax,%edx
c0105b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b55:	39 c2                	cmp    %eax,%edx
c0105b57:	74 24                	je     c0105b7d <check_boot_pgdir+0xd5>
c0105b59:	c7 44 24 0c 85 7d 10 	movl   $0xc0107d85,0xc(%esp)
c0105b60:	c0 
c0105b61:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105b68:	c0 
c0105b69:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105b70:	00 
c0105b71:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105b78:	e8 6a b1 ff ff       	call   c0100ce7 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105b7d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105b84:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b87:	a1 a0 ce 11 c0       	mov    0xc011cea0,%eax
c0105b8c:	39 c2                	cmp    %eax,%edx
c0105b8e:	0f 82 26 ff ff ff    	jb     c0105aba <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105b94:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105b99:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105b9e:	8b 00                	mov    (%eax),%eax
c0105ba0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105ba5:	89 c2                	mov    %eax,%edx
c0105ba7:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105bac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105baf:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0105bb6:	77 23                	ja     c0105bdb <check_boot_pgdir+0x133>
c0105bb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105bbf:	c7 44 24 08 14 7a 10 	movl   $0xc0107a14,0x8(%esp)
c0105bc6:	c0 
c0105bc7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0105bce:	00 
c0105bcf:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105bd6:	e8 0c b1 ff ff       	call   c0100ce7 <__panic>
c0105bdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bde:	05 00 00 00 40       	add    $0x40000000,%eax
c0105be3:	39 c2                	cmp    %eax,%edx
c0105be5:	74 24                	je     c0105c0b <check_boot_pgdir+0x163>
c0105be7:	c7 44 24 0c 9c 7d 10 	movl   $0xc0107d9c,0xc(%esp)
c0105bee:	c0 
c0105bef:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105bf6:	c0 
c0105bf7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0105bfe:	00 
c0105bff:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105c06:	e8 dc b0 ff ff       	call   c0100ce7 <__panic>

    assert(boot_pgdir[0] == 0);
c0105c0b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105c10:	8b 00                	mov    (%eax),%eax
c0105c12:	85 c0                	test   %eax,%eax
c0105c14:	74 24                	je     c0105c3a <check_boot_pgdir+0x192>
c0105c16:	c7 44 24 0c d0 7d 10 	movl   $0xc0107dd0,0xc(%esp)
c0105c1d:	c0 
c0105c1e:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105c25:	c0 
c0105c26:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105c2d:	00 
c0105c2e:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105c35:	e8 ad b0 ff ff       	call   c0100ce7 <__panic>

    struct Page *p;
    p = alloc_page();
c0105c3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105c41:	e8 a1 ed ff ff       	call   c01049e7 <alloc_pages>
c0105c46:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105c49:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105c4e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105c55:	00 
c0105c56:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105c5d:	00 
c0105c5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105c61:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c65:	89 04 24             	mov    %eax,(%esp)
c0105c68:	e8 6c f6 ff ff       	call   c01052d9 <page_insert>
c0105c6d:	85 c0                	test   %eax,%eax
c0105c6f:	74 24                	je     c0105c95 <check_boot_pgdir+0x1ed>
c0105c71:	c7 44 24 0c e4 7d 10 	movl   $0xc0107de4,0xc(%esp)
c0105c78:	c0 
c0105c79:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105c80:	c0 
c0105c81:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0105c88:	00 
c0105c89:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105c90:	e8 52 b0 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p) == 1);
c0105c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c98:	89 04 24             	mov    %eax,(%esp)
c0105c9b:	e8 42 eb ff ff       	call   c01047e2 <page_ref>
c0105ca0:	83 f8 01             	cmp    $0x1,%eax
c0105ca3:	74 24                	je     c0105cc9 <check_boot_pgdir+0x221>
c0105ca5:	c7 44 24 0c 12 7e 10 	movl   $0xc0107e12,0xc(%esp)
c0105cac:	c0 
c0105cad:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105cb4:	c0 
c0105cb5:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0105cbc:	00 
c0105cbd:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105cc4:	e8 1e b0 ff ff       	call   c0100ce7 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105cc9:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105cce:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105cd5:	00 
c0105cd6:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105cdd:	00 
c0105cde:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105ce1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ce5:	89 04 24             	mov    %eax,(%esp)
c0105ce8:	e8 ec f5 ff ff       	call   c01052d9 <page_insert>
c0105ced:	85 c0                	test   %eax,%eax
c0105cef:	74 24                	je     c0105d15 <check_boot_pgdir+0x26d>
c0105cf1:	c7 44 24 0c 24 7e 10 	movl   $0xc0107e24,0xc(%esp)
c0105cf8:	c0 
c0105cf9:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105d00:	c0 
c0105d01:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105d08:	00 
c0105d09:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105d10:	e8 d2 af ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p) == 2);
c0105d15:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d18:	89 04 24             	mov    %eax,(%esp)
c0105d1b:	e8 c2 ea ff ff       	call   c01047e2 <page_ref>
c0105d20:	83 f8 02             	cmp    $0x2,%eax
c0105d23:	74 24                	je     c0105d49 <check_boot_pgdir+0x2a1>
c0105d25:	c7 44 24 0c 5b 7e 10 	movl   $0xc0107e5b,0xc(%esp)
c0105d2c:	c0 
c0105d2d:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105d34:	c0 
c0105d35:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0105d3c:	00 
c0105d3d:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105d44:	e8 9e af ff ff       	call   c0100ce7 <__panic>

    const char *str = "ucore: Hello world!!";
c0105d49:	c7 45 dc 6c 7e 10 c0 	movl   $0xc0107e6c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105d50:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d57:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105d5e:	e8 19 0a 00 00       	call   c010677c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105d63:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105d6a:	00 
c0105d6b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105d72:	e8 7e 0a 00 00       	call   c01067f5 <strcmp>
c0105d77:	85 c0                	test   %eax,%eax
c0105d79:	74 24                	je     c0105d9f <check_boot_pgdir+0x2f7>
c0105d7b:	c7 44 24 0c 84 7e 10 	movl   $0xc0107e84,0xc(%esp)
c0105d82:	c0 
c0105d83:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105d8a:	c0 
c0105d8b:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0105d92:	00 
c0105d93:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105d9a:	e8 48 af ff ff       	call   c0100ce7 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105d9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105da2:	89 04 24             	mov    %eax,(%esp)
c0105da5:	e8 8e e9 ff ff       	call   c0104738 <page2kva>
c0105daa:	05 00 01 00 00       	add    $0x100,%eax
c0105daf:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105db2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105db9:	e8 66 09 00 00       	call   c0106724 <strlen>
c0105dbe:	85 c0                	test   %eax,%eax
c0105dc0:	74 24                	je     c0105de6 <check_boot_pgdir+0x33e>
c0105dc2:	c7 44 24 0c bc 7e 10 	movl   $0xc0107ebc,0xc(%esp)
c0105dc9:	c0 
c0105dca:	c7 44 24 08 5d 7a 10 	movl   $0xc0107a5d,0x8(%esp)
c0105dd1:	c0 
c0105dd2:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0105dd9:	00 
c0105dda:	c7 04 24 38 7a 10 c0 	movl   $0xc0107a38,(%esp)
c0105de1:	e8 01 af ff ff       	call   c0100ce7 <__panic>

    free_page(p);
c0105de6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ded:	00 
c0105dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105df1:	89 04 24             	mov    %eax,(%esp)
c0105df4:	e8 26 ec ff ff       	call   c0104a1f <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105df9:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105dfe:	8b 00                	mov    (%eax),%eax
c0105e00:	89 04 24             	mov    %eax,(%esp)
c0105e03:	e8 c2 e9 ff ff       	call   c01047ca <pde2page>
c0105e08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105e0f:	00 
c0105e10:	89 04 24             	mov    %eax,(%esp)
c0105e13:	e8 07 ec ff ff       	call   c0104a1f <free_pages>
    boot_pgdir[0] = 0;
c0105e18:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105e1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105e23:	c7 04 24 e0 7e 10 c0 	movl   $0xc0107ee0,(%esp)
c0105e2a:	e8 24 a5 ff ff       	call   c0100353 <cprintf>
}
c0105e2f:	c9                   	leave  
c0105e30:	c3                   	ret    

c0105e31 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105e31:	55                   	push   %ebp
c0105e32:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105e34:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e37:	83 e0 04             	and    $0x4,%eax
c0105e3a:	85 c0                	test   %eax,%eax
c0105e3c:	74 07                	je     c0105e45 <perm2str+0x14>
c0105e3e:	b8 75 00 00 00       	mov    $0x75,%eax
c0105e43:	eb 05                	jmp    c0105e4a <perm2str+0x19>
c0105e45:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105e4a:	a2 28 cf 11 c0       	mov    %al,0xc011cf28
    str[1] = 'r';
c0105e4f:	c6 05 29 cf 11 c0 72 	movb   $0x72,0xc011cf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e59:	83 e0 02             	and    $0x2,%eax
c0105e5c:	85 c0                	test   %eax,%eax
c0105e5e:	74 07                	je     c0105e67 <perm2str+0x36>
c0105e60:	b8 77 00 00 00       	mov    $0x77,%eax
c0105e65:	eb 05                	jmp    c0105e6c <perm2str+0x3b>
c0105e67:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105e6c:	a2 2a cf 11 c0       	mov    %al,0xc011cf2a
    str[3] = '\0';
c0105e71:	c6 05 2b cf 11 c0 00 	movb   $0x0,0xc011cf2b
    return str;
c0105e78:	b8 28 cf 11 c0       	mov    $0xc011cf28,%eax
}
c0105e7d:	5d                   	pop    %ebp
c0105e7e:	c3                   	ret    

c0105e7f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105e7f:	55                   	push   %ebp
c0105e80:	89 e5                	mov    %esp,%ebp
c0105e82:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105e85:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e88:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e8b:	72 0a                	jb     c0105e97 <get_pgtable_items+0x18>
        return 0;
c0105e8d:	b8 00 00 00 00       	mov    $0x0,%eax
c0105e92:	e9 9c 00 00 00       	jmp    c0105f33 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105e97:	eb 04                	jmp    c0105e9d <get_pgtable_items+0x1e>
        start ++;
c0105e99:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105e9d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ea3:	73 18                	jae    c0105ebd <get_pgtable_items+0x3e>
c0105ea5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105eaf:	8b 45 14             	mov    0x14(%ebp),%eax
c0105eb2:	01 d0                	add    %edx,%eax
c0105eb4:	8b 00                	mov    (%eax),%eax
c0105eb6:	83 e0 01             	and    $0x1,%eax
c0105eb9:	85 c0                	test   %eax,%eax
c0105ebb:	74 dc                	je     c0105e99 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105ebd:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ec0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ec3:	73 69                	jae    c0105f2e <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0105ec5:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105ec9:	74 08                	je     c0105ed3 <get_pgtable_items+0x54>
            *left_store = start;
c0105ecb:	8b 45 18             	mov    0x18(%ebp),%eax
c0105ece:	8b 55 10             	mov    0x10(%ebp),%edx
c0105ed1:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105ed3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ed6:	8d 50 01             	lea    0x1(%eax),%edx
c0105ed9:	89 55 10             	mov    %edx,0x10(%ebp)
c0105edc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105ee3:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ee6:	01 d0                	add    %edx,%eax
c0105ee8:	8b 00                	mov    (%eax),%eax
c0105eea:	83 e0 07             	and    $0x7,%eax
c0105eed:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105ef0:	eb 04                	jmp    c0105ef6 <get_pgtable_items+0x77>
            start ++;
c0105ef2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105ef6:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ef9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105efc:	73 1d                	jae    c0105f1b <get_pgtable_items+0x9c>
c0105efe:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f08:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f0b:	01 d0                	add    %edx,%eax
c0105f0d:	8b 00                	mov    (%eax),%eax
c0105f0f:	83 e0 07             	and    $0x7,%eax
c0105f12:	89 c2                	mov    %eax,%edx
c0105f14:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f17:	39 c2                	cmp    %eax,%edx
c0105f19:	74 d7                	je     c0105ef2 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105f1b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105f1f:	74 08                	je     c0105f29 <get_pgtable_items+0xaa>
            *right_store = start;
c0105f21:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105f24:	8b 55 10             	mov    0x10(%ebp),%edx
c0105f27:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f2c:	eb 05                	jmp    c0105f33 <get_pgtable_items+0xb4>
    }
    return 0;
c0105f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f33:	c9                   	leave  
c0105f34:	c3                   	ret    

c0105f35 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105f35:	55                   	push   %ebp
c0105f36:	89 e5                	mov    %esp,%ebp
c0105f38:	57                   	push   %edi
c0105f39:	56                   	push   %esi
c0105f3a:	53                   	push   %ebx
c0105f3b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105f3e:	c7 04 24 00 7f 10 c0 	movl   $0xc0107f00,(%esp)
c0105f45:	e8 09 a4 ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
c0105f4a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105f51:	e9 fa 00 00 00       	jmp    c0106050 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f59:	89 04 24             	mov    %eax,(%esp)
c0105f5c:	e8 d0 fe ff ff       	call   c0105e31 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105f61:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105f64:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f67:	29 d1                	sub    %edx,%ecx
c0105f69:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105f6b:	89 d6                	mov    %edx,%esi
c0105f6d:	c1 e6 16             	shl    $0x16,%esi
c0105f70:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105f73:	89 d3                	mov    %edx,%ebx
c0105f75:	c1 e3 16             	shl    $0x16,%ebx
c0105f78:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f7b:	89 d1                	mov    %edx,%ecx
c0105f7d:	c1 e1 16             	shl    $0x16,%ecx
c0105f80:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105f83:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f86:	29 d7                	sub    %edx,%edi
c0105f88:	89 fa                	mov    %edi,%edx
c0105f8a:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105f8e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105f92:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105f96:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105f9a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f9e:	c7 04 24 31 7f 10 c0 	movl   $0xc0107f31,(%esp)
c0105fa5:	e8 a9 a3 ff ff       	call   c0100353 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105fad:	c1 e0 0a             	shl    $0xa,%eax
c0105fb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105fb3:	eb 54                	jmp    c0106009 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fb8:	89 04 24             	mov    %eax,(%esp)
c0105fbb:	e8 71 fe ff ff       	call   c0105e31 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105fc0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105fc3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105fc6:	29 d1                	sub    %edx,%ecx
c0105fc8:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105fca:	89 d6                	mov    %edx,%esi
c0105fcc:	c1 e6 0c             	shl    $0xc,%esi
c0105fcf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105fd2:	89 d3                	mov    %edx,%ebx
c0105fd4:	c1 e3 0c             	shl    $0xc,%ebx
c0105fd7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105fda:	c1 e2 0c             	shl    $0xc,%edx
c0105fdd:	89 d1                	mov    %edx,%ecx
c0105fdf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105fe2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105fe5:	29 d7                	sub    %edx,%edi
c0105fe7:	89 fa                	mov    %edi,%edx
c0105fe9:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105fed:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105ff1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105ff5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105ff9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ffd:	c7 04 24 50 7f 10 c0 	movl   $0xc0107f50,(%esp)
c0106004:	e8 4a a3 ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106009:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c010600e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106011:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106014:	89 ce                	mov    %ecx,%esi
c0106016:	c1 e6 0a             	shl    $0xa,%esi
c0106019:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010601c:	89 cb                	mov    %ecx,%ebx
c010601e:	c1 e3 0a             	shl    $0xa,%ebx
c0106021:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0106024:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106028:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c010602b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010602f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106033:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106037:	89 74 24 04          	mov    %esi,0x4(%esp)
c010603b:	89 1c 24             	mov    %ebx,(%esp)
c010603e:	e8 3c fe ff ff       	call   c0105e7f <get_pgtable_items>
c0106043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106046:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010604a:	0f 85 65 ff ff ff    	jne    c0105fb5 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106050:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0106055:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106058:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010605b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010605f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106062:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106066:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010606a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010606e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106075:	00 
c0106076:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010607d:	e8 fd fd ff ff       	call   c0105e7f <get_pgtable_items>
c0106082:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106085:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106089:	0f 85 c7 fe ff ff    	jne    c0105f56 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010608f:	c7 04 24 74 7f 10 c0 	movl   $0xc0107f74,(%esp)
c0106096:	e8 b8 a2 ff ff       	call   c0100353 <cprintf>
}
c010609b:	83 c4 4c             	add    $0x4c,%esp
c010609e:	5b                   	pop    %ebx
c010609f:	5e                   	pop    %esi
c01060a0:	5f                   	pop    %edi
c01060a1:	5d                   	pop    %ebp
c01060a2:	c3                   	ret    

c01060a3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01060a3:	55                   	push   %ebp
c01060a4:	89 e5                	mov    %esp,%ebp
c01060a6:	83 ec 58             	sub    $0x58,%esp
c01060a9:	8b 45 10             	mov    0x10(%ebp),%eax
c01060ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01060af:	8b 45 14             	mov    0x14(%ebp),%eax
c01060b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01060b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01060b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01060bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01060be:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01060c1:	8b 45 18             	mov    0x18(%ebp),%eax
c01060c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01060c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01060cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01060d0:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01060d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01060d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01060dd:	74 1c                	je     c01060fb <printnum+0x58>
c01060df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060e2:	ba 00 00 00 00       	mov    $0x0,%edx
c01060e7:	f7 75 e4             	divl   -0x1c(%ebp)
c01060ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01060ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060f0:	ba 00 00 00 00       	mov    $0x0,%edx
c01060f5:	f7 75 e4             	divl   -0x1c(%ebp)
c01060f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01060fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106101:	f7 75 e4             	divl   -0x1c(%ebp)
c0106104:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106107:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010610a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010610d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106110:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106113:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106116:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106119:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010611c:	8b 45 18             	mov    0x18(%ebp),%eax
c010611f:	ba 00 00 00 00       	mov    $0x0,%edx
c0106124:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106127:	77 56                	ja     c010617f <printnum+0xdc>
c0106129:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010612c:	72 05                	jb     c0106133 <printnum+0x90>
c010612e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0106131:	77 4c                	ja     c010617f <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106133:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106136:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106139:	8b 45 20             	mov    0x20(%ebp),%eax
c010613c:	89 44 24 18          	mov    %eax,0x18(%esp)
c0106140:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106144:	8b 45 18             	mov    0x18(%ebp),%eax
c0106147:	89 44 24 10          	mov    %eax,0x10(%esp)
c010614b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010614e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106151:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106155:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106159:	8b 45 0c             	mov    0xc(%ebp),%eax
c010615c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106160:	8b 45 08             	mov    0x8(%ebp),%eax
c0106163:	89 04 24             	mov    %eax,(%esp)
c0106166:	e8 38 ff ff ff       	call   c01060a3 <printnum>
c010616b:	eb 1c                	jmp    c0106189 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010616d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106170:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106174:	8b 45 20             	mov    0x20(%ebp),%eax
c0106177:	89 04 24             	mov    %eax,(%esp)
c010617a:	8b 45 08             	mov    0x8(%ebp),%eax
c010617d:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010617f:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0106183:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106187:	7f e4                	jg     c010616d <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0106189:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010618c:	05 28 80 10 c0       	add    $0xc0108028,%eax
c0106191:	0f b6 00             	movzbl (%eax),%eax
c0106194:	0f be c0             	movsbl %al,%eax
c0106197:	8b 55 0c             	mov    0xc(%ebp),%edx
c010619a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010619e:	89 04 24             	mov    %eax,(%esp)
c01061a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01061a4:	ff d0                	call   *%eax
}
c01061a6:	c9                   	leave  
c01061a7:	c3                   	ret    

c01061a8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01061a8:	55                   	push   %ebp
c01061a9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01061ab:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01061af:	7e 14                	jle    c01061c5 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01061b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01061b4:	8b 00                	mov    (%eax),%eax
c01061b6:	8d 48 08             	lea    0x8(%eax),%ecx
c01061b9:	8b 55 08             	mov    0x8(%ebp),%edx
c01061bc:	89 0a                	mov    %ecx,(%edx)
c01061be:	8b 50 04             	mov    0x4(%eax),%edx
c01061c1:	8b 00                	mov    (%eax),%eax
c01061c3:	eb 30                	jmp    c01061f5 <getuint+0x4d>
    }
    else if (lflag) {
c01061c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01061c9:	74 16                	je     c01061e1 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01061cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01061ce:	8b 00                	mov    (%eax),%eax
c01061d0:	8d 48 04             	lea    0x4(%eax),%ecx
c01061d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01061d6:	89 0a                	mov    %ecx,(%edx)
c01061d8:	8b 00                	mov    (%eax),%eax
c01061da:	ba 00 00 00 00       	mov    $0x0,%edx
c01061df:	eb 14                	jmp    c01061f5 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01061e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01061e4:	8b 00                	mov    (%eax),%eax
c01061e6:	8d 48 04             	lea    0x4(%eax),%ecx
c01061e9:	8b 55 08             	mov    0x8(%ebp),%edx
c01061ec:	89 0a                	mov    %ecx,(%edx)
c01061ee:	8b 00                	mov    (%eax),%eax
c01061f0:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01061f5:	5d                   	pop    %ebp
c01061f6:	c3                   	ret    

c01061f7 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01061f7:	55                   	push   %ebp
c01061f8:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01061fa:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01061fe:	7e 14                	jle    c0106214 <getint+0x1d>
        return va_arg(*ap, long long);
c0106200:	8b 45 08             	mov    0x8(%ebp),%eax
c0106203:	8b 00                	mov    (%eax),%eax
c0106205:	8d 48 08             	lea    0x8(%eax),%ecx
c0106208:	8b 55 08             	mov    0x8(%ebp),%edx
c010620b:	89 0a                	mov    %ecx,(%edx)
c010620d:	8b 50 04             	mov    0x4(%eax),%edx
c0106210:	8b 00                	mov    (%eax),%eax
c0106212:	eb 28                	jmp    c010623c <getint+0x45>
    }
    else if (lflag) {
c0106214:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106218:	74 12                	je     c010622c <getint+0x35>
        return va_arg(*ap, long);
c010621a:	8b 45 08             	mov    0x8(%ebp),%eax
c010621d:	8b 00                	mov    (%eax),%eax
c010621f:	8d 48 04             	lea    0x4(%eax),%ecx
c0106222:	8b 55 08             	mov    0x8(%ebp),%edx
c0106225:	89 0a                	mov    %ecx,(%edx)
c0106227:	8b 00                	mov    (%eax),%eax
c0106229:	99                   	cltd   
c010622a:	eb 10                	jmp    c010623c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010622c:	8b 45 08             	mov    0x8(%ebp),%eax
c010622f:	8b 00                	mov    (%eax),%eax
c0106231:	8d 48 04             	lea    0x4(%eax),%ecx
c0106234:	8b 55 08             	mov    0x8(%ebp),%edx
c0106237:	89 0a                	mov    %ecx,(%edx)
c0106239:	8b 00                	mov    (%eax),%eax
c010623b:	99                   	cltd   
    }
}
c010623c:	5d                   	pop    %ebp
c010623d:	c3                   	ret    

c010623e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010623e:	55                   	push   %ebp
c010623f:	89 e5                	mov    %esp,%ebp
c0106241:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106244:	8d 45 14             	lea    0x14(%ebp),%eax
c0106247:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010624a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010624d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106251:	8b 45 10             	mov    0x10(%ebp),%eax
c0106254:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106258:	8b 45 0c             	mov    0xc(%ebp),%eax
c010625b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010625f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106262:	89 04 24             	mov    %eax,(%esp)
c0106265:	e8 02 00 00 00       	call   c010626c <vprintfmt>
    va_end(ap);
}
c010626a:	c9                   	leave  
c010626b:	c3                   	ret    

c010626c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010626c:	55                   	push   %ebp
c010626d:	89 e5                	mov    %esp,%ebp
c010626f:	56                   	push   %esi
c0106270:	53                   	push   %ebx
c0106271:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106274:	eb 18                	jmp    c010628e <vprintfmt+0x22>
            if (ch == '\0') {
c0106276:	85 db                	test   %ebx,%ebx
c0106278:	75 05                	jne    c010627f <vprintfmt+0x13>
                return;
c010627a:	e9 d1 03 00 00       	jmp    c0106650 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010627f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106282:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106286:	89 1c 24             	mov    %ebx,(%esp)
c0106289:	8b 45 08             	mov    0x8(%ebp),%eax
c010628c:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010628e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106291:	8d 50 01             	lea    0x1(%eax),%edx
c0106294:	89 55 10             	mov    %edx,0x10(%ebp)
c0106297:	0f b6 00             	movzbl (%eax),%eax
c010629a:	0f b6 d8             	movzbl %al,%ebx
c010629d:	83 fb 25             	cmp    $0x25,%ebx
c01062a0:	75 d4                	jne    c0106276 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01062a2:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01062a6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01062ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01062b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01062ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01062bd:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01062c0:	8b 45 10             	mov    0x10(%ebp),%eax
c01062c3:	8d 50 01             	lea    0x1(%eax),%edx
c01062c6:	89 55 10             	mov    %edx,0x10(%ebp)
c01062c9:	0f b6 00             	movzbl (%eax),%eax
c01062cc:	0f b6 d8             	movzbl %al,%ebx
c01062cf:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01062d2:	83 f8 55             	cmp    $0x55,%eax
c01062d5:	0f 87 44 03 00 00    	ja     c010661f <vprintfmt+0x3b3>
c01062db:	8b 04 85 4c 80 10 c0 	mov    -0x3fef7fb4(,%eax,4),%eax
c01062e2:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01062e4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01062e8:	eb d6                	jmp    c01062c0 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01062ea:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01062ee:	eb d0                	jmp    c01062c0 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01062f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01062f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01062fa:	89 d0                	mov    %edx,%eax
c01062fc:	c1 e0 02             	shl    $0x2,%eax
c01062ff:	01 d0                	add    %edx,%eax
c0106301:	01 c0                	add    %eax,%eax
c0106303:	01 d8                	add    %ebx,%eax
c0106305:	83 e8 30             	sub    $0x30,%eax
c0106308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010630b:	8b 45 10             	mov    0x10(%ebp),%eax
c010630e:	0f b6 00             	movzbl (%eax),%eax
c0106311:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106314:	83 fb 2f             	cmp    $0x2f,%ebx
c0106317:	7e 0b                	jle    c0106324 <vprintfmt+0xb8>
c0106319:	83 fb 39             	cmp    $0x39,%ebx
c010631c:	7f 06                	jg     c0106324 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010631e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0106322:	eb d3                	jmp    c01062f7 <vprintfmt+0x8b>
            goto process_precision;
c0106324:	eb 33                	jmp    c0106359 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0106326:	8b 45 14             	mov    0x14(%ebp),%eax
c0106329:	8d 50 04             	lea    0x4(%eax),%edx
c010632c:	89 55 14             	mov    %edx,0x14(%ebp)
c010632f:	8b 00                	mov    (%eax),%eax
c0106331:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106334:	eb 23                	jmp    c0106359 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0106336:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010633a:	79 0c                	jns    c0106348 <vprintfmt+0xdc>
                width = 0;
c010633c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0106343:	e9 78 ff ff ff       	jmp    c01062c0 <vprintfmt+0x54>
c0106348:	e9 73 ff ff ff       	jmp    c01062c0 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010634d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0106354:	e9 67 ff ff ff       	jmp    c01062c0 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0106359:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010635d:	79 12                	jns    c0106371 <vprintfmt+0x105>
                width = precision, precision = -1;
c010635f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106362:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106365:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010636c:	e9 4f ff ff ff       	jmp    c01062c0 <vprintfmt+0x54>
c0106371:	e9 4a ff ff ff       	jmp    c01062c0 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0106376:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010637a:	e9 41 ff ff ff       	jmp    c01062c0 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010637f:	8b 45 14             	mov    0x14(%ebp),%eax
c0106382:	8d 50 04             	lea    0x4(%eax),%edx
c0106385:	89 55 14             	mov    %edx,0x14(%ebp)
c0106388:	8b 00                	mov    (%eax),%eax
c010638a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010638d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106391:	89 04 24             	mov    %eax,(%esp)
c0106394:	8b 45 08             	mov    0x8(%ebp),%eax
c0106397:	ff d0                	call   *%eax
            break;
c0106399:	e9 ac 02 00 00       	jmp    c010664a <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010639e:	8b 45 14             	mov    0x14(%ebp),%eax
c01063a1:	8d 50 04             	lea    0x4(%eax),%edx
c01063a4:	89 55 14             	mov    %edx,0x14(%ebp)
c01063a7:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01063a9:	85 db                	test   %ebx,%ebx
c01063ab:	79 02                	jns    c01063af <vprintfmt+0x143>
                err = -err;
c01063ad:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01063af:	83 fb 06             	cmp    $0x6,%ebx
c01063b2:	7f 0b                	jg     c01063bf <vprintfmt+0x153>
c01063b4:	8b 34 9d 0c 80 10 c0 	mov    -0x3fef7ff4(,%ebx,4),%esi
c01063bb:	85 f6                	test   %esi,%esi
c01063bd:	75 23                	jne    c01063e2 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01063bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01063c3:	c7 44 24 08 39 80 10 	movl   $0xc0108039,0x8(%esp)
c01063ca:	c0 
c01063cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01063d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01063d5:	89 04 24             	mov    %eax,(%esp)
c01063d8:	e8 61 fe ff ff       	call   c010623e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01063dd:	e9 68 02 00 00       	jmp    c010664a <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c01063e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01063e6:	c7 44 24 08 42 80 10 	movl   $0xc0108042,0x8(%esp)
c01063ed:	c0 
c01063ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01063f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01063f8:	89 04 24             	mov    %eax,(%esp)
c01063fb:	e8 3e fe ff ff       	call   c010623e <printfmt>
            }
            break;
c0106400:	e9 45 02 00 00       	jmp    c010664a <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0106405:	8b 45 14             	mov    0x14(%ebp),%eax
c0106408:	8d 50 04             	lea    0x4(%eax),%edx
c010640b:	89 55 14             	mov    %edx,0x14(%ebp)
c010640e:	8b 30                	mov    (%eax),%esi
c0106410:	85 f6                	test   %esi,%esi
c0106412:	75 05                	jne    c0106419 <vprintfmt+0x1ad>
                p = "(null)";
c0106414:	be 45 80 10 c0       	mov    $0xc0108045,%esi
            }
            if (width > 0 && padc != '-') {
c0106419:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010641d:	7e 3e                	jle    c010645d <vprintfmt+0x1f1>
c010641f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106423:	74 38                	je     c010645d <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106425:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0106428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010642b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010642f:	89 34 24             	mov    %esi,(%esp)
c0106432:	e8 15 03 00 00       	call   c010674c <strnlen>
c0106437:	29 c3                	sub    %eax,%ebx
c0106439:	89 d8                	mov    %ebx,%eax
c010643b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010643e:	eb 17                	jmp    c0106457 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0106440:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106444:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106447:	89 54 24 04          	mov    %edx,0x4(%esp)
c010644b:	89 04 24             	mov    %eax,(%esp)
c010644e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106451:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106453:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0106457:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010645b:	7f e3                	jg     c0106440 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010645d:	eb 38                	jmp    c0106497 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010645f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106463:	74 1f                	je     c0106484 <vprintfmt+0x218>
c0106465:	83 fb 1f             	cmp    $0x1f,%ebx
c0106468:	7e 05                	jle    c010646f <vprintfmt+0x203>
c010646a:	83 fb 7e             	cmp    $0x7e,%ebx
c010646d:	7e 15                	jle    c0106484 <vprintfmt+0x218>
                    putch('?', putdat);
c010646f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106472:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106476:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010647d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106480:	ff d0                	call   *%eax
c0106482:	eb 0f                	jmp    c0106493 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0106484:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106487:	89 44 24 04          	mov    %eax,0x4(%esp)
c010648b:	89 1c 24             	mov    %ebx,(%esp)
c010648e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106491:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106493:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0106497:	89 f0                	mov    %esi,%eax
c0106499:	8d 70 01             	lea    0x1(%eax),%esi
c010649c:	0f b6 00             	movzbl (%eax),%eax
c010649f:	0f be d8             	movsbl %al,%ebx
c01064a2:	85 db                	test   %ebx,%ebx
c01064a4:	74 10                	je     c01064b6 <vprintfmt+0x24a>
c01064a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01064aa:	78 b3                	js     c010645f <vprintfmt+0x1f3>
c01064ac:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c01064b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01064b4:	79 a9                	jns    c010645f <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01064b6:	eb 17                	jmp    c01064cf <vprintfmt+0x263>
                putch(' ', putdat);
c01064b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01064bf:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01064c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01064c9:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01064cb:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01064cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01064d3:	7f e3                	jg     c01064b8 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c01064d5:	e9 70 01 00 00       	jmp    c010664a <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01064da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01064dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01064e1:	8d 45 14             	lea    0x14(%ebp),%eax
c01064e4:	89 04 24             	mov    %eax,(%esp)
c01064e7:	e8 0b fd ff ff       	call   c01061f7 <getint>
c01064ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01064ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01064f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01064f8:	85 d2                	test   %edx,%edx
c01064fa:	79 26                	jns    c0106522 <vprintfmt+0x2b6>
                putch('-', putdat);
c01064fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106503:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010650a:	8b 45 08             	mov    0x8(%ebp),%eax
c010650d:	ff d0                	call   *%eax
                num = -(long long)num;
c010650f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106512:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106515:	f7 d8                	neg    %eax
c0106517:	83 d2 00             	adc    $0x0,%edx
c010651a:	f7 da                	neg    %edx
c010651c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010651f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106522:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106529:	e9 a8 00 00 00       	jmp    c01065d6 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010652e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106531:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106535:	8d 45 14             	lea    0x14(%ebp),%eax
c0106538:	89 04 24             	mov    %eax,(%esp)
c010653b:	e8 68 fc ff ff       	call   c01061a8 <getuint>
c0106540:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106543:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106546:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010654d:	e9 84 00 00 00       	jmp    c01065d6 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106552:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106555:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106559:	8d 45 14             	lea    0x14(%ebp),%eax
c010655c:	89 04 24             	mov    %eax,(%esp)
c010655f:	e8 44 fc ff ff       	call   c01061a8 <getuint>
c0106564:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106567:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010656a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106571:	eb 63                	jmp    c01065d6 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0106573:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106576:	89 44 24 04          	mov    %eax,0x4(%esp)
c010657a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106581:	8b 45 08             	mov    0x8(%ebp),%eax
c0106584:	ff d0                	call   *%eax
            putch('x', putdat);
c0106586:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106589:	89 44 24 04          	mov    %eax,0x4(%esp)
c010658d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106594:	8b 45 08             	mov    0x8(%ebp),%eax
c0106597:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106599:	8b 45 14             	mov    0x14(%ebp),%eax
c010659c:	8d 50 04             	lea    0x4(%eax),%edx
c010659f:	89 55 14             	mov    %edx,0x14(%ebp)
c01065a2:	8b 00                	mov    (%eax),%eax
c01065a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01065ae:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01065b5:	eb 1f                	jmp    c01065d6 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01065b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01065ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065be:	8d 45 14             	lea    0x14(%ebp),%eax
c01065c1:	89 04 24             	mov    %eax,(%esp)
c01065c4:	e8 df fb ff ff       	call   c01061a8 <getuint>
c01065c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01065cf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01065d6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01065da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065dd:	89 54 24 18          	mov    %edx,0x18(%esp)
c01065e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01065e4:	89 54 24 14          	mov    %edx,0x14(%esp)
c01065e8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01065ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065f2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01065f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01065fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106601:	8b 45 08             	mov    0x8(%ebp),%eax
c0106604:	89 04 24             	mov    %eax,(%esp)
c0106607:	e8 97 fa ff ff       	call   c01060a3 <printnum>
            break;
c010660c:	eb 3c                	jmp    c010664a <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010660e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106611:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106615:	89 1c 24             	mov    %ebx,(%esp)
c0106618:	8b 45 08             	mov    0x8(%ebp),%eax
c010661b:	ff d0                	call   *%eax
            break;
c010661d:	eb 2b                	jmp    c010664a <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010661f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106622:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106626:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010662d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106630:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106632:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0106636:	eb 04                	jmp    c010663c <vprintfmt+0x3d0>
c0106638:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010663c:	8b 45 10             	mov    0x10(%ebp),%eax
c010663f:	83 e8 01             	sub    $0x1,%eax
c0106642:	0f b6 00             	movzbl (%eax),%eax
c0106645:	3c 25                	cmp    $0x25,%al
c0106647:	75 ef                	jne    c0106638 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0106649:	90                   	nop
        }
    }
c010664a:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010664b:	e9 3e fc ff ff       	jmp    c010628e <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0106650:	83 c4 40             	add    $0x40,%esp
c0106653:	5b                   	pop    %ebx
c0106654:	5e                   	pop    %esi
c0106655:	5d                   	pop    %ebp
c0106656:	c3                   	ret    

c0106657 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106657:	55                   	push   %ebp
c0106658:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010665a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010665d:	8b 40 08             	mov    0x8(%eax),%eax
c0106660:	8d 50 01             	lea    0x1(%eax),%edx
c0106663:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106666:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106669:	8b 45 0c             	mov    0xc(%ebp),%eax
c010666c:	8b 10                	mov    (%eax),%edx
c010666e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106671:	8b 40 04             	mov    0x4(%eax),%eax
c0106674:	39 c2                	cmp    %eax,%edx
c0106676:	73 12                	jae    c010668a <sprintputch+0x33>
        *b->buf ++ = ch;
c0106678:	8b 45 0c             	mov    0xc(%ebp),%eax
c010667b:	8b 00                	mov    (%eax),%eax
c010667d:	8d 48 01             	lea    0x1(%eax),%ecx
c0106680:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106683:	89 0a                	mov    %ecx,(%edx)
c0106685:	8b 55 08             	mov    0x8(%ebp),%edx
c0106688:	88 10                	mov    %dl,(%eax)
    }
}
c010668a:	5d                   	pop    %ebp
c010668b:	c3                   	ret    

c010668c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010668c:	55                   	push   %ebp
c010668d:	89 e5                	mov    %esp,%ebp
c010668f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106692:	8d 45 14             	lea    0x14(%ebp),%eax
c0106695:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106698:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010669b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010669f:	8b 45 10             	mov    0x10(%ebp),%eax
c01066a2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01066a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01066b0:	89 04 24             	mov    %eax,(%esp)
c01066b3:	e8 08 00 00 00       	call   c01066c0 <vsnprintf>
c01066b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01066bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01066be:	c9                   	leave  
c01066bf:	c3                   	ret    

c01066c0 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01066c0:	55                   	push   %ebp
c01066c1:	89 e5                	mov    %esp,%ebp
c01066c3:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01066c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01066c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01066cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066cf:	8d 50 ff             	lea    -0x1(%eax),%edx
c01066d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01066d5:	01 d0                	add    %edx,%eax
c01066d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01066e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01066e5:	74 0a                	je     c01066f1 <vsnprintf+0x31>
c01066e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01066ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066ed:	39 c2                	cmp    %eax,%edx
c01066ef:	76 07                	jbe    c01066f8 <vsnprintf+0x38>
        return -E_INVAL;
c01066f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01066f6:	eb 2a                	jmp    c0106722 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01066f8:	8b 45 14             	mov    0x14(%ebp),%eax
c01066fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01066ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0106702:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106706:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106709:	89 44 24 04          	mov    %eax,0x4(%esp)
c010670d:	c7 04 24 57 66 10 c0 	movl   $0xc0106657,(%esp)
c0106714:	e8 53 fb ff ff       	call   c010626c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106719:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010671c:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106722:	c9                   	leave  
c0106723:	c3                   	ret    

c0106724 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0106724:	55                   	push   %ebp
c0106725:	89 e5                	mov    %esp,%ebp
c0106727:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010672a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106731:	eb 04                	jmp    c0106737 <strlen+0x13>
        cnt ++;
c0106733:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0106737:	8b 45 08             	mov    0x8(%ebp),%eax
c010673a:	8d 50 01             	lea    0x1(%eax),%edx
c010673d:	89 55 08             	mov    %edx,0x8(%ebp)
c0106740:	0f b6 00             	movzbl (%eax),%eax
c0106743:	84 c0                	test   %al,%al
c0106745:	75 ec                	jne    c0106733 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0106747:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010674a:	c9                   	leave  
c010674b:	c3                   	ret    

c010674c <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010674c:	55                   	push   %ebp
c010674d:	89 e5                	mov    %esp,%ebp
c010674f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106752:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106759:	eb 04                	jmp    c010675f <strnlen+0x13>
        cnt ++;
c010675b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010675f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106762:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106765:	73 10                	jae    c0106777 <strnlen+0x2b>
c0106767:	8b 45 08             	mov    0x8(%ebp),%eax
c010676a:	8d 50 01             	lea    0x1(%eax),%edx
c010676d:	89 55 08             	mov    %edx,0x8(%ebp)
c0106770:	0f b6 00             	movzbl (%eax),%eax
c0106773:	84 c0                	test   %al,%al
c0106775:	75 e4                	jne    c010675b <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0106777:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010677a:	c9                   	leave  
c010677b:	c3                   	ret    

c010677c <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010677c:	55                   	push   %ebp
c010677d:	89 e5                	mov    %esp,%ebp
c010677f:	57                   	push   %edi
c0106780:	56                   	push   %esi
c0106781:	83 ec 20             	sub    $0x20,%esp
c0106784:	8b 45 08             	mov    0x8(%ebp),%eax
c0106787:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010678a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010678d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0106790:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106793:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106796:	89 d1                	mov    %edx,%ecx
c0106798:	89 c2                	mov    %eax,%edx
c010679a:	89 ce                	mov    %ecx,%esi
c010679c:	89 d7                	mov    %edx,%edi
c010679e:	ac                   	lods   %ds:(%esi),%al
c010679f:	aa                   	stos   %al,%es:(%edi)
c01067a0:	84 c0                	test   %al,%al
c01067a2:	75 fa                	jne    c010679e <strcpy+0x22>
c01067a4:	89 fa                	mov    %edi,%edx
c01067a6:	89 f1                	mov    %esi,%ecx
c01067a8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01067ab:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01067ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01067b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01067b4:	83 c4 20             	add    $0x20,%esp
c01067b7:	5e                   	pop    %esi
c01067b8:	5f                   	pop    %edi
c01067b9:	5d                   	pop    %ebp
c01067ba:	c3                   	ret    

c01067bb <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01067bb:	55                   	push   %ebp
c01067bc:	89 e5                	mov    %esp,%ebp
c01067be:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01067c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01067c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01067c7:	eb 21                	jmp    c01067ea <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c01067c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067cc:	0f b6 10             	movzbl (%eax),%edx
c01067cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067d2:	88 10                	mov    %dl,(%eax)
c01067d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067d7:	0f b6 00             	movzbl (%eax),%eax
c01067da:	84 c0                	test   %al,%al
c01067dc:	74 04                	je     c01067e2 <strncpy+0x27>
            src ++;
c01067de:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c01067e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01067e6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c01067ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01067ee:	75 d9                	jne    c01067c9 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c01067f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01067f3:	c9                   	leave  
c01067f4:	c3                   	ret    

c01067f5 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01067f5:	55                   	push   %ebp
c01067f6:	89 e5                	mov    %esp,%ebp
c01067f8:	57                   	push   %edi
c01067f9:	56                   	push   %esi
c01067fa:	83 ec 20             	sub    $0x20,%esp
c01067fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106800:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106803:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106806:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0106809:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010680c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010680f:	89 d1                	mov    %edx,%ecx
c0106811:	89 c2                	mov    %eax,%edx
c0106813:	89 ce                	mov    %ecx,%esi
c0106815:	89 d7                	mov    %edx,%edi
c0106817:	ac                   	lods   %ds:(%esi),%al
c0106818:	ae                   	scas   %es:(%edi),%al
c0106819:	75 08                	jne    c0106823 <strcmp+0x2e>
c010681b:	84 c0                	test   %al,%al
c010681d:	75 f8                	jne    c0106817 <strcmp+0x22>
c010681f:	31 c0                	xor    %eax,%eax
c0106821:	eb 04                	jmp    c0106827 <strcmp+0x32>
c0106823:	19 c0                	sbb    %eax,%eax
c0106825:	0c 01                	or     $0x1,%al
c0106827:	89 fa                	mov    %edi,%edx
c0106829:	89 f1                	mov    %esi,%ecx
c010682b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010682e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106831:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0106834:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0106837:	83 c4 20             	add    $0x20,%esp
c010683a:	5e                   	pop    %esi
c010683b:	5f                   	pop    %edi
c010683c:	5d                   	pop    %ebp
c010683d:	c3                   	ret    

c010683e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010683e:	55                   	push   %ebp
c010683f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106841:	eb 0c                	jmp    c010684f <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0106843:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0106847:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010684b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010684f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106853:	74 1a                	je     c010686f <strncmp+0x31>
c0106855:	8b 45 08             	mov    0x8(%ebp),%eax
c0106858:	0f b6 00             	movzbl (%eax),%eax
c010685b:	84 c0                	test   %al,%al
c010685d:	74 10                	je     c010686f <strncmp+0x31>
c010685f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106862:	0f b6 10             	movzbl (%eax),%edx
c0106865:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106868:	0f b6 00             	movzbl (%eax),%eax
c010686b:	38 c2                	cmp    %al,%dl
c010686d:	74 d4                	je     c0106843 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010686f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106873:	74 18                	je     c010688d <strncmp+0x4f>
c0106875:	8b 45 08             	mov    0x8(%ebp),%eax
c0106878:	0f b6 00             	movzbl (%eax),%eax
c010687b:	0f b6 d0             	movzbl %al,%edx
c010687e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106881:	0f b6 00             	movzbl (%eax),%eax
c0106884:	0f b6 c0             	movzbl %al,%eax
c0106887:	29 c2                	sub    %eax,%edx
c0106889:	89 d0                	mov    %edx,%eax
c010688b:	eb 05                	jmp    c0106892 <strncmp+0x54>
c010688d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106892:	5d                   	pop    %ebp
c0106893:	c3                   	ret    

c0106894 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0106894:	55                   	push   %ebp
c0106895:	89 e5                	mov    %esp,%ebp
c0106897:	83 ec 04             	sub    $0x4,%esp
c010689a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010689d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01068a0:	eb 14                	jmp    c01068b6 <strchr+0x22>
        if (*s == c) {
c01068a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01068a5:	0f b6 00             	movzbl (%eax),%eax
c01068a8:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01068ab:	75 05                	jne    c01068b2 <strchr+0x1e>
            return (char *)s;
c01068ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01068b0:	eb 13                	jmp    c01068c5 <strchr+0x31>
        }
        s ++;
c01068b2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c01068b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01068b9:	0f b6 00             	movzbl (%eax),%eax
c01068bc:	84 c0                	test   %al,%al
c01068be:	75 e2                	jne    c01068a2 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c01068c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01068c5:	c9                   	leave  
c01068c6:	c3                   	ret    

c01068c7 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01068c7:	55                   	push   %ebp
c01068c8:	89 e5                	mov    %esp,%ebp
c01068ca:	83 ec 04             	sub    $0x4,%esp
c01068cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068d0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01068d3:	eb 11                	jmp    c01068e6 <strfind+0x1f>
        if (*s == c) {
c01068d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01068d8:	0f b6 00             	movzbl (%eax),%eax
c01068db:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01068de:	75 02                	jne    c01068e2 <strfind+0x1b>
            break;
c01068e0:	eb 0e                	jmp    c01068f0 <strfind+0x29>
        }
        s ++;
c01068e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c01068e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01068e9:	0f b6 00             	movzbl (%eax),%eax
c01068ec:	84 c0                	test   %al,%al
c01068ee:	75 e5                	jne    c01068d5 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c01068f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01068f3:	c9                   	leave  
c01068f4:	c3                   	ret    

c01068f5 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01068f5:	55                   	push   %ebp
c01068f6:	89 e5                	mov    %esp,%ebp
c01068f8:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01068fb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106902:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0106909:	eb 04                	jmp    c010690f <strtol+0x1a>
        s ++;
c010690b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010690f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106912:	0f b6 00             	movzbl (%eax),%eax
c0106915:	3c 20                	cmp    $0x20,%al
c0106917:	74 f2                	je     c010690b <strtol+0x16>
c0106919:	8b 45 08             	mov    0x8(%ebp),%eax
c010691c:	0f b6 00             	movzbl (%eax),%eax
c010691f:	3c 09                	cmp    $0x9,%al
c0106921:	74 e8                	je     c010690b <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0106923:	8b 45 08             	mov    0x8(%ebp),%eax
c0106926:	0f b6 00             	movzbl (%eax),%eax
c0106929:	3c 2b                	cmp    $0x2b,%al
c010692b:	75 06                	jne    c0106933 <strtol+0x3e>
        s ++;
c010692d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0106931:	eb 15                	jmp    c0106948 <strtol+0x53>
    }
    else if (*s == '-') {
c0106933:	8b 45 08             	mov    0x8(%ebp),%eax
c0106936:	0f b6 00             	movzbl (%eax),%eax
c0106939:	3c 2d                	cmp    $0x2d,%al
c010693b:	75 0b                	jne    c0106948 <strtol+0x53>
        s ++, neg = 1;
c010693d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0106941:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106948:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010694c:	74 06                	je     c0106954 <strtol+0x5f>
c010694e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0106952:	75 24                	jne    c0106978 <strtol+0x83>
c0106954:	8b 45 08             	mov    0x8(%ebp),%eax
c0106957:	0f b6 00             	movzbl (%eax),%eax
c010695a:	3c 30                	cmp    $0x30,%al
c010695c:	75 1a                	jne    c0106978 <strtol+0x83>
c010695e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106961:	83 c0 01             	add    $0x1,%eax
c0106964:	0f b6 00             	movzbl (%eax),%eax
c0106967:	3c 78                	cmp    $0x78,%al
c0106969:	75 0d                	jne    c0106978 <strtol+0x83>
        s += 2, base = 16;
c010696b:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010696f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0106976:	eb 2a                	jmp    c01069a2 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0106978:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010697c:	75 17                	jne    c0106995 <strtol+0xa0>
c010697e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106981:	0f b6 00             	movzbl (%eax),%eax
c0106984:	3c 30                	cmp    $0x30,%al
c0106986:	75 0d                	jne    c0106995 <strtol+0xa0>
        s ++, base = 8;
c0106988:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010698c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0106993:	eb 0d                	jmp    c01069a2 <strtol+0xad>
    }
    else if (base == 0) {
c0106995:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106999:	75 07                	jne    c01069a2 <strtol+0xad>
        base = 10;
c010699b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01069a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01069a5:	0f b6 00             	movzbl (%eax),%eax
c01069a8:	3c 2f                	cmp    $0x2f,%al
c01069aa:	7e 1b                	jle    c01069c7 <strtol+0xd2>
c01069ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01069af:	0f b6 00             	movzbl (%eax),%eax
c01069b2:	3c 39                	cmp    $0x39,%al
c01069b4:	7f 11                	jg     c01069c7 <strtol+0xd2>
            dig = *s - '0';
c01069b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01069b9:	0f b6 00             	movzbl (%eax),%eax
c01069bc:	0f be c0             	movsbl %al,%eax
c01069bf:	83 e8 30             	sub    $0x30,%eax
c01069c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01069c5:	eb 48                	jmp    c0106a0f <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01069c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01069ca:	0f b6 00             	movzbl (%eax),%eax
c01069cd:	3c 60                	cmp    $0x60,%al
c01069cf:	7e 1b                	jle    c01069ec <strtol+0xf7>
c01069d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01069d4:	0f b6 00             	movzbl (%eax),%eax
c01069d7:	3c 7a                	cmp    $0x7a,%al
c01069d9:	7f 11                	jg     c01069ec <strtol+0xf7>
            dig = *s - 'a' + 10;
c01069db:	8b 45 08             	mov    0x8(%ebp),%eax
c01069de:	0f b6 00             	movzbl (%eax),%eax
c01069e1:	0f be c0             	movsbl %al,%eax
c01069e4:	83 e8 57             	sub    $0x57,%eax
c01069e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01069ea:	eb 23                	jmp    c0106a0f <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01069ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01069ef:	0f b6 00             	movzbl (%eax),%eax
c01069f2:	3c 40                	cmp    $0x40,%al
c01069f4:	7e 3d                	jle    c0106a33 <strtol+0x13e>
c01069f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01069f9:	0f b6 00             	movzbl (%eax),%eax
c01069fc:	3c 5a                	cmp    $0x5a,%al
c01069fe:	7f 33                	jg     c0106a33 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0106a00:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a03:	0f b6 00             	movzbl (%eax),%eax
c0106a06:	0f be c0             	movsbl %al,%eax
c0106a09:	83 e8 37             	sub    $0x37,%eax
c0106a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0106a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a12:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106a15:	7c 02                	jl     c0106a19 <strtol+0x124>
            break;
c0106a17:	eb 1a                	jmp    c0106a33 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0106a19:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0106a1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106a20:	0f af 45 10          	imul   0x10(%ebp),%eax
c0106a24:	89 c2                	mov    %eax,%edx
c0106a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a29:	01 d0                	add    %edx,%eax
c0106a2b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0106a2e:	e9 6f ff ff ff       	jmp    c01069a2 <strtol+0xad>

    if (endptr) {
c0106a33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106a37:	74 08                	je     c0106a41 <strtol+0x14c>
        *endptr = (char *) s;
c0106a39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a3c:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a3f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106a41:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106a45:	74 07                	je     c0106a4e <strtol+0x159>
c0106a47:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106a4a:	f7 d8                	neg    %eax
c0106a4c:	eb 03                	jmp    c0106a51 <strtol+0x15c>
c0106a4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106a51:	c9                   	leave  
c0106a52:	c3                   	ret    

c0106a53 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106a53:	55                   	push   %ebp
c0106a54:	89 e5                	mov    %esp,%ebp
c0106a56:	57                   	push   %edi
c0106a57:	83 ec 24             	sub    $0x24,%esp
c0106a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a5d:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106a60:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0106a64:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a67:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0106a6a:	88 45 f7             	mov    %al,-0x9(%ebp)
c0106a6d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106a73:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106a76:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0106a7a:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106a7d:	89 d7                	mov    %edx,%edi
c0106a7f:	f3 aa                	rep stos %al,%es:(%edi)
c0106a81:	89 fa                	mov    %edi,%edx
c0106a83:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106a86:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0106a89:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106a8c:	83 c4 24             	add    $0x24,%esp
c0106a8f:	5f                   	pop    %edi
c0106a90:	5d                   	pop    %ebp
c0106a91:	c3                   	ret    

c0106a92 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0106a92:	55                   	push   %ebp
c0106a93:	89 e5                	mov    %esp,%ebp
c0106a95:	57                   	push   %edi
c0106a96:	56                   	push   %esi
c0106a97:	53                   	push   %ebx
c0106a98:	83 ec 30             	sub    $0x30,%esp
c0106a9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106aa7:	8b 45 10             	mov    0x10(%ebp),%eax
c0106aaa:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0106aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ab0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106ab3:	73 42                	jae    c0106af7 <memmove+0x65>
c0106ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ab8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106abb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106abe:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ac4:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106ac7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106aca:	c1 e8 02             	shr    $0x2,%eax
c0106acd:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0106acf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ad5:	89 d7                	mov    %edx,%edi
c0106ad7:	89 c6                	mov    %eax,%esi
c0106ad9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106adb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106ade:	83 e1 03             	and    $0x3,%ecx
c0106ae1:	74 02                	je     c0106ae5 <memmove+0x53>
c0106ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106ae5:	89 f0                	mov    %esi,%eax
c0106ae7:	89 fa                	mov    %edi,%edx
c0106ae9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106aec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106aef:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0106af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106af5:	eb 36                	jmp    c0106b2d <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106af7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106afa:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106afd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b00:	01 c2                	add    %eax,%edx
c0106b02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b05:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b0b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0106b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b11:	89 c1                	mov    %eax,%ecx
c0106b13:	89 d8                	mov    %ebx,%eax
c0106b15:	89 d6                	mov    %edx,%esi
c0106b17:	89 c7                	mov    %eax,%edi
c0106b19:	fd                   	std    
c0106b1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106b1c:	fc                   	cld    
c0106b1d:	89 f8                	mov    %edi,%eax
c0106b1f:	89 f2                	mov    %esi,%edx
c0106b21:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106b24:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106b27:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0106b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106b2d:	83 c4 30             	add    $0x30,%esp
c0106b30:	5b                   	pop    %ebx
c0106b31:	5e                   	pop    %esi
c0106b32:	5f                   	pop    %edi
c0106b33:	5d                   	pop    %ebp
c0106b34:	c3                   	ret    

c0106b35 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106b35:	55                   	push   %ebp
c0106b36:	89 e5                	mov    %esp,%ebp
c0106b38:	57                   	push   %edi
c0106b39:	56                   	push   %esi
c0106b3a:	83 ec 20             	sub    $0x20,%esp
c0106b3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b40:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106b43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b46:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b49:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106b4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b52:	c1 e8 02             	shr    $0x2,%eax
c0106b55:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0106b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b5d:	89 d7                	mov    %edx,%edi
c0106b5f:	89 c6                	mov    %eax,%esi
c0106b61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106b63:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0106b66:	83 e1 03             	and    $0x3,%ecx
c0106b69:	74 02                	je     c0106b6d <memcpy+0x38>
c0106b6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106b6d:	89 f0                	mov    %esi,%eax
c0106b6f:	89 fa                	mov    %edi,%edx
c0106b71:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106b74:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106b77:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0106b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106b7d:	83 c4 20             	add    $0x20,%esp
c0106b80:	5e                   	pop    %esi
c0106b81:	5f                   	pop    %edi
c0106b82:	5d                   	pop    %ebp
c0106b83:	c3                   	ret    

c0106b84 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0106b84:	55                   	push   %ebp
c0106b85:	89 e5                	mov    %esp,%ebp
c0106b87:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0106b90:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b93:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0106b96:	eb 30                	jmp    c0106bc8 <memcmp+0x44>
        if (*s1 != *s2) {
c0106b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106b9b:	0f b6 10             	movzbl (%eax),%edx
c0106b9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106ba1:	0f b6 00             	movzbl (%eax),%eax
c0106ba4:	38 c2                	cmp    %al,%dl
c0106ba6:	74 18                	je     c0106bc0 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106ba8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106bab:	0f b6 00             	movzbl (%eax),%eax
c0106bae:	0f b6 d0             	movzbl %al,%edx
c0106bb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106bb4:	0f b6 00             	movzbl (%eax),%eax
c0106bb7:	0f b6 c0             	movzbl %al,%eax
c0106bba:	29 c2                	sub    %eax,%edx
c0106bbc:	89 d0                	mov    %edx,%eax
c0106bbe:	eb 1a                	jmp    c0106bda <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0106bc0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0106bc4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0106bc8:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bcb:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106bce:	89 55 10             	mov    %edx,0x10(%ebp)
c0106bd1:	85 c0                	test   %eax,%eax
c0106bd3:	75 c3                	jne    c0106b98 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0106bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106bda:	c9                   	leave  
c0106bdb:	c3                   	ret    
