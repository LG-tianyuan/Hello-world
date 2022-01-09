
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 80 fd 10 00       	mov    $0x10fd80,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 fd 33 00 00       	call   103429 <memset>

    cons_init();                // init the console
  10002c:	e8 5f 15 00 00       	call   101590 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 c0 35 10 00 	movl   $0x1035c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 dc 35 10 00 	movl   $0x1035dc,(%esp)
  100046:	e8 d7 02 00 00       	call   100322 <cprintf>

    print_kerninfo();
  10004b:	e8 06 08 00 00       	call   100856 <print_kerninfo>

    grade_backtrace();
  100050:	e8 8b 00 00 00       	call   1000e0 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 15 2a 00 00       	call   102a6f <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 74 16 00 00       	call   1016d3 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 ec 17 00 00       	call   101850 <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 1a 0d 00 00       	call   100d83 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 d3 15 00 00       	call   101641 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006e:	e8 6d 01 00 00       	call   1001e0 <lab1_switch_test>

    /* do nothing */
    while (1);
  100073:	eb fe                	jmp    100073 <kern_init+0x73>

00100075 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100075:	55                   	push   %ebp
  100076:	89 e5                	mov    %esp,%ebp
  100078:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  10007b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100082:	00 
  100083:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10008a:	00 
  10008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100092:	e8 0d 0c 00 00       	call   100ca4 <mon_backtrace>
}
  100097:	c9                   	leave  
  100098:	c3                   	ret    

00100099 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100099:	55                   	push   %ebp
  10009a:	89 e5                	mov    %esp,%ebp
  10009c:	53                   	push   %ebx
  10009d:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a0:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000a6:	8d 55 08             	lea    0x8(%ebp),%edx
  1000a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000b8:	89 04 24             	mov    %eax,(%esp)
  1000bb:	e8 b5 ff ff ff       	call   100075 <grade_backtrace2>
}
  1000c0:	83 c4 14             	add    $0x14,%esp
  1000c3:	5b                   	pop    %ebx
  1000c4:	5d                   	pop    %ebp
  1000c5:	c3                   	ret    

001000c6 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c6:	55                   	push   %ebp
  1000c7:	89 e5                	mov    %esp,%ebp
  1000c9:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d6:	89 04 24             	mov    %eax,(%esp)
  1000d9:	e8 bb ff ff ff       	call   100099 <grade_backtrace1>
}
  1000de:	c9                   	leave  
  1000df:	c3                   	ret    

001000e0 <grade_backtrace>:

void
grade_backtrace(void) {
  1000e0:	55                   	push   %ebp
  1000e1:	89 e5                	mov    %esp,%ebp
  1000e3:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e6:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000eb:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f2:	ff 
  1000f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000fe:	e8 c3 ff ff ff       	call   1000c6 <grade_backtrace0>
}
  100103:	c9                   	leave  
  100104:	c3                   	ret    

00100105 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100105:	55                   	push   %ebp
  100106:	89 e5                	mov    %esp,%ebp
  100108:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10010e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100111:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100114:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100117:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011b:	0f b7 c0             	movzwl %ax,%eax
  10011e:	83 e0 03             	and    $0x3,%eax
  100121:	89 c2                	mov    %eax,%edx
  100123:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100128:	89 54 24 08          	mov    %edx,0x8(%esp)
  10012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100130:	c7 04 24 e1 35 10 00 	movl   $0x1035e1,(%esp)
  100137:	e8 e6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100140:	0f b7 d0             	movzwl %ax,%edx
  100143:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100148:	89 54 24 08          	mov    %edx,0x8(%esp)
  10014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100150:	c7 04 24 ef 35 10 00 	movl   $0x1035ef,(%esp)
  100157:	e8 c6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10015c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100160:	0f b7 d0             	movzwl %ax,%edx
  100163:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100168:	89 54 24 08          	mov    %edx,0x8(%esp)
  10016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100170:	c7 04 24 fd 35 10 00 	movl   $0x1035fd,(%esp)
  100177:	e8 a6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10017c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100180:	0f b7 d0             	movzwl %ax,%edx
  100183:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100188:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100190:	c7 04 24 0b 36 10 00 	movl   $0x10360b,(%esp)
  100197:	e8 86 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019c:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001a0:	0f b7 d0             	movzwl %ax,%edx
  1001a3:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b0:	c7 04 24 19 36 10 00 	movl   $0x103619,(%esp)
  1001b7:	e8 66 01 00 00       	call   100322 <cprintf>
    round ++;
  1001bc:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001c1:	83 c0 01             	add    $0x1,%eax
  1001c4:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001c9:	c9                   	leave  
  1001ca:	c3                   	ret    

001001cb <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001cb:	55                   	push   %ebp
  1001cc:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  1001ce:	83 ec 08             	sub    $0x8,%esp
  1001d1:	cd 78                	int    $0x78
  1001d3:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001d5:	5d                   	pop    %ebp
  1001d6:	c3                   	ret    

001001d7 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001d7:	55                   	push   %ebp
  1001d8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  1001da:	cd 79                	int    $0x79
  1001dc:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  1001de:	5d                   	pop    %ebp
  1001df:	c3                   	ret    

001001e0 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001e0:	55                   	push   %ebp
  1001e1:	89 e5                	mov    %esp,%ebp
  1001e3:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001e6:	e8 1a ff ff ff       	call   100105 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001eb:	c7 04 24 28 36 10 00 	movl   $0x103628,(%esp)
  1001f2:	e8 2b 01 00 00       	call   100322 <cprintf>
    lab1_switch_to_user();
  1001f7:	e8 cf ff ff ff       	call   1001cb <lab1_switch_to_user>
    lab1_print_cur_status();
  1001fc:	e8 04 ff ff ff       	call   100105 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100201:	c7 04 24 48 36 10 00 	movl   $0x103648,(%esp)
  100208:	e8 15 01 00 00       	call   100322 <cprintf>
    lab1_switch_to_kernel();
  10020d:	e8 c5 ff ff ff       	call   1001d7 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100212:	e8 ee fe ff ff       	call   100105 <lab1_print_cur_status>
}
  100217:	c9                   	leave  
  100218:	c3                   	ret    

00100219 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100219:	55                   	push   %ebp
  10021a:	89 e5                	mov    %esp,%ebp
  10021c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10021f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100223:	74 13                	je     100238 <readline+0x1f>
        cprintf("%s", prompt);
  100225:	8b 45 08             	mov    0x8(%ebp),%eax
  100228:	89 44 24 04          	mov    %eax,0x4(%esp)
  10022c:	c7 04 24 67 36 10 00 	movl   $0x103667,(%esp)
  100233:	e8 ea 00 00 00       	call   100322 <cprintf>
    }
    int i = 0, c;
  100238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10023f:	e8 66 01 00 00       	call   1003aa <getchar>
  100244:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100247:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10024b:	79 07                	jns    100254 <readline+0x3b>
            return NULL;
  10024d:	b8 00 00 00 00       	mov    $0x0,%eax
  100252:	eb 79                	jmp    1002cd <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100254:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100258:	7e 28                	jle    100282 <readline+0x69>
  10025a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100261:	7f 1f                	jg     100282 <readline+0x69>
            cputchar(c);
  100263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100266:	89 04 24             	mov    %eax,(%esp)
  100269:	e8 da 00 00 00       	call   100348 <cputchar>
            buf[i ++] = c;
  10026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100271:	8d 50 01             	lea    0x1(%eax),%edx
  100274:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100277:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10027a:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100280:	eb 46                	jmp    1002c8 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  100282:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100286:	75 17                	jne    10029f <readline+0x86>
  100288:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10028c:	7e 11                	jle    10029f <readline+0x86>
            cputchar(c);
  10028e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100291:	89 04 24             	mov    %eax,(%esp)
  100294:	e8 af 00 00 00       	call   100348 <cputchar>
            i --;
  100299:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10029d:	eb 29                	jmp    1002c8 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  10029f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002a3:	74 06                	je     1002ab <readline+0x92>
  1002a5:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002a9:	75 1d                	jne    1002c8 <readline+0xaf>
            cputchar(c);
  1002ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002ae:	89 04 24             	mov    %eax,(%esp)
  1002b1:	e8 92 00 00 00       	call   100348 <cputchar>
            buf[i] = '\0';
  1002b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002b9:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1002be:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002c1:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1002c6:	eb 05                	jmp    1002cd <readline+0xb4>
        }
    }
  1002c8:	e9 72 ff ff ff       	jmp    10023f <readline+0x26>
}
  1002cd:	c9                   	leave  
  1002ce:	c3                   	ret    

001002cf <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002cf:	55                   	push   %ebp
  1002d0:	89 e5                	mov    %esp,%ebp
  1002d2:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d8:	89 04 24             	mov    %eax,(%esp)
  1002db:	e8 dc 12 00 00       	call   1015bc <cons_putc>
    (*cnt) ++;
  1002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002e3:	8b 00                	mov    (%eax),%eax
  1002e5:	8d 50 01             	lea    0x1(%eax),%edx
  1002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002eb:	89 10                	mov    %edx,(%eax)
}
  1002ed:	c9                   	leave  
  1002ee:	c3                   	ret    

001002ef <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  1002ef:	55                   	push   %ebp
  1002f0:	89 e5                	mov    %esp,%ebp
  1002f2:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100303:	8b 45 08             	mov    0x8(%ebp),%eax
  100306:	89 44 24 08          	mov    %eax,0x8(%esp)
  10030a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10030d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100311:	c7 04 24 cf 02 10 00 	movl   $0x1002cf,(%esp)
  100318:	e8 25 29 00 00       	call   102c42 <vprintfmt>
    return cnt;
  10031d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100320:	c9                   	leave  
  100321:	c3                   	ret    

00100322 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100322:	55                   	push   %ebp
  100323:	89 e5                	mov    %esp,%ebp
  100325:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100328:	8d 45 0c             	lea    0xc(%ebp),%eax
  10032b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10032e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100331:	89 44 24 04          	mov    %eax,0x4(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 04 24             	mov    %eax,(%esp)
  10033b:	e8 af ff ff ff       	call   1002ef <vcprintf>
  100340:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100346:	c9                   	leave  
  100347:	c3                   	ret    

00100348 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10034e:	8b 45 08             	mov    0x8(%ebp),%eax
  100351:	89 04 24             	mov    %eax,(%esp)
  100354:	e8 63 12 00 00       	call   1015bc <cons_putc>
}
  100359:	c9                   	leave  
  10035a:	c3                   	ret    

0010035b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10035b:	55                   	push   %ebp
  10035c:	89 e5                	mov    %esp,%ebp
  10035e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100361:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100368:	eb 13                	jmp    10037d <cputs+0x22>
        cputch(c, &cnt);
  10036a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10036e:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100371:	89 54 24 04          	mov    %edx,0x4(%esp)
  100375:	89 04 24             	mov    %eax,(%esp)
  100378:	e8 52 ff ff ff       	call   1002cf <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  10037d:	8b 45 08             	mov    0x8(%ebp),%eax
  100380:	8d 50 01             	lea    0x1(%eax),%edx
  100383:	89 55 08             	mov    %edx,0x8(%ebp)
  100386:	0f b6 00             	movzbl (%eax),%eax
  100389:	88 45 f7             	mov    %al,-0x9(%ebp)
  10038c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100390:	75 d8                	jne    10036a <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  100392:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100395:	89 44 24 04          	mov    %eax,0x4(%esp)
  100399:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003a0:	e8 2a ff ff ff       	call   1002cf <cputch>
    return cnt;
  1003a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003a8:	c9                   	leave  
  1003a9:	c3                   	ret    

001003aa <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003aa:	55                   	push   %ebp
  1003ab:	89 e5                	mov    %esp,%ebp
  1003ad:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003b0:	e8 30 12 00 00       	call   1015e5 <cons_getc>
  1003b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003bc:	74 f2                	je     1003b0 <getchar+0x6>
        /* do nothing */;
    return c;
  1003be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003c1:	c9                   	leave  
  1003c2:	c3                   	ret    

001003c3 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003c3:	55                   	push   %ebp
  1003c4:	89 e5                	mov    %esp,%ebp
  1003c6:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003cc:	8b 00                	mov    (%eax),%eax
  1003ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1003d4:	8b 00                	mov    (%eax),%eax
  1003d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1003e0:	e9 d2 00 00 00       	jmp    1004b7 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1003e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1003e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1003eb:	01 d0                	add    %edx,%eax
  1003ed:	89 c2                	mov    %eax,%edx
  1003ef:	c1 ea 1f             	shr    $0x1f,%edx
  1003f2:	01 d0                	add    %edx,%eax
  1003f4:	d1 f8                	sar    %eax
  1003f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1003f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1003ff:	eb 04                	jmp    100405 <stab_binsearch+0x42>
            m --;
  100401:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100405:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100408:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10040b:	7c 1f                	jl     10042c <stab_binsearch+0x69>
  10040d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100410:	89 d0                	mov    %edx,%eax
  100412:	01 c0                	add    %eax,%eax
  100414:	01 d0                	add    %edx,%eax
  100416:	c1 e0 02             	shl    $0x2,%eax
  100419:	89 c2                	mov    %eax,%edx
  10041b:	8b 45 08             	mov    0x8(%ebp),%eax
  10041e:	01 d0                	add    %edx,%eax
  100420:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100424:	0f b6 c0             	movzbl %al,%eax
  100427:	3b 45 14             	cmp    0x14(%ebp),%eax
  10042a:	75 d5                	jne    100401 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  10042c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100432:	7d 0b                	jge    10043f <stab_binsearch+0x7c>
            l = true_m + 1;
  100434:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100437:	83 c0 01             	add    $0x1,%eax
  10043a:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10043d:	eb 78                	jmp    1004b7 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  10043f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100446:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100449:	89 d0                	mov    %edx,%eax
  10044b:	01 c0                	add    %eax,%eax
  10044d:	01 d0                	add    %edx,%eax
  10044f:	c1 e0 02             	shl    $0x2,%eax
  100452:	89 c2                	mov    %eax,%edx
  100454:	8b 45 08             	mov    0x8(%ebp),%eax
  100457:	01 d0                	add    %edx,%eax
  100459:	8b 40 08             	mov    0x8(%eax),%eax
  10045c:	3b 45 18             	cmp    0x18(%ebp),%eax
  10045f:	73 13                	jae    100474 <stab_binsearch+0xb1>
            *region_left = m;
  100461:	8b 45 0c             	mov    0xc(%ebp),%eax
  100464:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100467:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100469:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10046c:	83 c0 01             	add    $0x1,%eax
  10046f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100472:	eb 43                	jmp    1004b7 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100474:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100477:	89 d0                	mov    %edx,%eax
  100479:	01 c0                	add    %eax,%eax
  10047b:	01 d0                	add    %edx,%eax
  10047d:	c1 e0 02             	shl    $0x2,%eax
  100480:	89 c2                	mov    %eax,%edx
  100482:	8b 45 08             	mov    0x8(%ebp),%eax
  100485:	01 d0                	add    %edx,%eax
  100487:	8b 40 08             	mov    0x8(%eax),%eax
  10048a:	3b 45 18             	cmp    0x18(%ebp),%eax
  10048d:	76 16                	jbe    1004a5 <stab_binsearch+0xe2>
            *region_right = m - 1;
  10048f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100492:	8d 50 ff             	lea    -0x1(%eax),%edx
  100495:	8b 45 10             	mov    0x10(%ebp),%eax
  100498:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10049a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10049d:	83 e8 01             	sub    $0x1,%eax
  1004a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a3:	eb 12                	jmp    1004b7 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004ab:	89 10                	mov    %edx,(%eax)
            l = m;
  1004ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004b3:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004bd:	0f 8e 22 ff ff ff    	jle    1003e5 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004c7:	75 0f                	jne    1004d8 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004cc:	8b 00                	mov    (%eax),%eax
  1004ce:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d4:	89 10                	mov    %edx,(%eax)
  1004d6:	eb 3f                	jmp    100517 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004d8:	8b 45 10             	mov    0x10(%ebp),%eax
  1004db:	8b 00                	mov    (%eax),%eax
  1004dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1004e0:	eb 04                	jmp    1004e6 <stab_binsearch+0x123>
  1004e2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004e9:	8b 00                	mov    (%eax),%eax
  1004eb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ee:	7d 1f                	jge    10050f <stab_binsearch+0x14c>
  1004f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004f3:	89 d0                	mov    %edx,%eax
  1004f5:	01 c0                	add    %eax,%eax
  1004f7:	01 d0                	add    %edx,%eax
  1004f9:	c1 e0 02             	shl    $0x2,%eax
  1004fc:	89 c2                	mov    %eax,%edx
  1004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100501:	01 d0                	add    %edx,%eax
  100503:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100507:	0f b6 c0             	movzbl %al,%eax
  10050a:	3b 45 14             	cmp    0x14(%ebp),%eax
  10050d:	75 d3                	jne    1004e2 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  10050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100512:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100515:	89 10                	mov    %edx,(%eax)
    }
}
  100517:	c9                   	leave  
  100518:	c3                   	ret    

00100519 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100519:	55                   	push   %ebp
  10051a:	89 e5                	mov    %esp,%ebp
  10051c:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10051f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100522:	c7 00 6c 36 10 00    	movl   $0x10366c,(%eax)
    info->eip_line = 0;
  100528:	8b 45 0c             	mov    0xc(%ebp),%eax
  10052b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100532:	8b 45 0c             	mov    0xc(%ebp),%eax
  100535:	c7 40 08 6c 36 10 00 	movl   $0x10366c,0x8(%eax)
    info->eip_fn_namelen = 9;
  10053c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10053f:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100546:	8b 45 0c             	mov    0xc(%ebp),%eax
  100549:	8b 55 08             	mov    0x8(%ebp),%edx
  10054c:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10054f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100552:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100559:	c7 45 f4 0c 3f 10 00 	movl   $0x103f0c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100560:	c7 45 f0 18 b7 10 00 	movl   $0x10b718,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100567:	c7 45 ec 19 b7 10 00 	movl   $0x10b719,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10056e:	c7 45 e8 27 d7 10 00 	movl   $0x10d727,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100575:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100578:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10057b:	76 0d                	jbe    10058a <debuginfo_eip+0x71>
  10057d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100580:	83 e8 01             	sub    $0x1,%eax
  100583:	0f b6 00             	movzbl (%eax),%eax
  100586:	84 c0                	test   %al,%al
  100588:	74 0a                	je     100594 <debuginfo_eip+0x7b>
        return -1;
  10058a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10058f:	e9 c0 02 00 00       	jmp    100854 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100594:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10059b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10059e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005a1:	29 c2                	sub    %eax,%edx
  1005a3:	89 d0                	mov    %edx,%eax
  1005a5:	c1 f8 02             	sar    $0x2,%eax
  1005a8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005ae:	83 e8 01             	sub    $0x1,%eax
  1005b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005bb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005c2:	00 
  1005c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005d4:	89 04 24             	mov    %eax,(%esp)
  1005d7:	e8 e7 fd ff ff       	call   1003c3 <stab_binsearch>
    if (lfile == 0)
  1005dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005df:	85 c0                	test   %eax,%eax
  1005e1:	75 0a                	jne    1005ed <debuginfo_eip+0xd4>
        return -1;
  1005e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005e8:	e9 67 02 00 00       	jmp    100854 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1005ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1005f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1005fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  100600:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100607:	00 
  100608:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10060f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100612:	89 44 24 04          	mov    %eax,0x4(%esp)
  100616:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100619:	89 04 24             	mov    %eax,(%esp)
  10061c:	e8 a2 fd ff ff       	call   1003c3 <stab_binsearch>

    if (lfun <= rfun) {
  100621:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100624:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100627:	39 c2                	cmp    %eax,%edx
  100629:	7f 7c                	jg     1006a7 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10062b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10062e:	89 c2                	mov    %eax,%edx
  100630:	89 d0                	mov    %edx,%eax
  100632:	01 c0                	add    %eax,%eax
  100634:	01 d0                	add    %edx,%eax
  100636:	c1 e0 02             	shl    $0x2,%eax
  100639:	89 c2                	mov    %eax,%edx
  10063b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063e:	01 d0                	add    %edx,%eax
  100640:	8b 10                	mov    (%eax),%edx
  100642:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100645:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100648:	29 c1                	sub    %eax,%ecx
  10064a:	89 c8                	mov    %ecx,%eax
  10064c:	39 c2                	cmp    %eax,%edx
  10064e:	73 22                	jae    100672 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100650:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100653:	89 c2                	mov    %eax,%edx
  100655:	89 d0                	mov    %edx,%eax
  100657:	01 c0                	add    %eax,%eax
  100659:	01 d0                	add    %edx,%eax
  10065b:	c1 e0 02             	shl    $0x2,%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100663:	01 d0                	add    %edx,%eax
  100665:	8b 10                	mov    (%eax),%edx
  100667:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066a:	01 c2                	add    %eax,%edx
  10066c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10066f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100672:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100675:	89 c2                	mov    %eax,%edx
  100677:	89 d0                	mov    %edx,%eax
  100679:	01 c0                	add    %eax,%eax
  10067b:	01 d0                	add    %edx,%eax
  10067d:	c1 e0 02             	shl    $0x2,%eax
  100680:	89 c2                	mov    %eax,%edx
  100682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	8b 50 08             	mov    0x8(%eax),%edx
  10068a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10068d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100690:	8b 45 0c             	mov    0xc(%ebp),%eax
  100693:	8b 40 10             	mov    0x10(%eax),%eax
  100696:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100699:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10069f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006a5:	eb 15                	jmp    1006bc <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006aa:	8b 55 08             	mov    0x8(%ebp),%edx
  1006ad:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 08             	mov    0x8(%eax),%eax
  1006c2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006c9:	00 
  1006ca:	89 04 24             	mov    %eax,(%esp)
  1006cd:	e8 cb 2b 00 00       	call   10329d <strfind>
  1006d2:	89 c2                	mov    %eax,%edx
  1006d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d7:	8b 40 08             	mov    0x8(%eax),%eax
  1006da:	29 c2                	sub    %eax,%edx
  1006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006df:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006e9:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1006f0:	00 
  1006f1:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006f8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100702:	89 04 24             	mov    %eax,(%esp)
  100705:	e8 b9 fc ff ff       	call   1003c3 <stab_binsearch>
    if (lline <= rline) {
  10070a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10070d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100710:	39 c2                	cmp    %eax,%edx
  100712:	7f 24                	jg     100738 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100714:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100717:	89 c2                	mov    %eax,%edx
  100719:	89 d0                	mov    %edx,%eax
  10071b:	01 c0                	add    %eax,%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	c1 e0 02             	shl    $0x2,%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10072d:	0f b7 d0             	movzwl %ax,%edx
  100730:	8b 45 0c             	mov    0xc(%ebp),%eax
  100733:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100736:	eb 13                	jmp    10074b <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10073d:	e9 12 01 00 00       	jmp    100854 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100742:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100745:	83 e8 01             	sub    $0x1,%eax
  100748:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10074b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10074e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100751:	39 c2                	cmp    %eax,%edx
  100753:	7c 56                	jl     1007ab <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100755:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100758:	89 c2                	mov    %eax,%edx
  10075a:	89 d0                	mov    %edx,%eax
  10075c:	01 c0                	add    %eax,%eax
  10075e:	01 d0                	add    %edx,%eax
  100760:	c1 e0 02             	shl    $0x2,%eax
  100763:	89 c2                	mov    %eax,%edx
  100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100768:	01 d0                	add    %edx,%eax
  10076a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10076e:	3c 84                	cmp    $0x84,%al
  100770:	74 39                	je     1007ab <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100772:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100775:	89 c2                	mov    %eax,%edx
  100777:	89 d0                	mov    %edx,%eax
  100779:	01 c0                	add    %eax,%eax
  10077b:	01 d0                	add    %edx,%eax
  10077d:	c1 e0 02             	shl    $0x2,%eax
  100780:	89 c2                	mov    %eax,%edx
  100782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100785:	01 d0                	add    %edx,%eax
  100787:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10078b:	3c 64                	cmp    $0x64,%al
  10078d:	75 b3                	jne    100742 <debuginfo_eip+0x229>
  10078f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100792:	89 c2                	mov    %eax,%edx
  100794:	89 d0                	mov    %edx,%eax
  100796:	01 c0                	add    %eax,%eax
  100798:	01 d0                	add    %edx,%eax
  10079a:	c1 e0 02             	shl    $0x2,%eax
  10079d:	89 c2                	mov    %eax,%edx
  10079f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007a2:	01 d0                	add    %edx,%eax
  1007a4:	8b 40 08             	mov    0x8(%eax),%eax
  1007a7:	85 c0                	test   %eax,%eax
  1007a9:	74 97                	je     100742 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007b1:	39 c2                	cmp    %eax,%edx
  1007b3:	7c 46                	jl     1007fb <debuginfo_eip+0x2e2>
  1007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	89 d0                	mov    %edx,%eax
  1007bc:	01 c0                	add    %eax,%eax
  1007be:	01 d0                	add    %edx,%eax
  1007c0:	c1 e0 02             	shl    $0x2,%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c8:	01 d0                	add    %edx,%eax
  1007ca:	8b 10                	mov    (%eax),%edx
  1007cc:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007d2:	29 c1                	sub    %eax,%ecx
  1007d4:	89 c8                	mov    %ecx,%eax
  1007d6:	39 c2                	cmp    %eax,%edx
  1007d8:	73 21                	jae    1007fb <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007dd:	89 c2                	mov    %eax,%edx
  1007df:	89 d0                	mov    %edx,%eax
  1007e1:	01 c0                	add    %eax,%eax
  1007e3:	01 d0                	add    %edx,%eax
  1007e5:	c1 e0 02             	shl    $0x2,%eax
  1007e8:	89 c2                	mov    %eax,%edx
  1007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ed:	01 d0                	add    %edx,%eax
  1007ef:	8b 10                	mov    (%eax),%edx
  1007f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f4:	01 c2                	add    %eax,%edx
  1007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1007fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1007fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100801:	39 c2                	cmp    %eax,%edx
  100803:	7d 4a                	jge    10084f <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  100805:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100808:	83 c0 01             	add    $0x1,%eax
  10080b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10080e:	eb 18                	jmp    100828 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100810:	8b 45 0c             	mov    0xc(%ebp),%eax
  100813:	8b 40 14             	mov    0x14(%eax),%eax
  100816:	8d 50 01             	lea    0x1(%eax),%edx
  100819:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081c:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  10081f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100822:	83 c0 01             	add    $0x1,%eax
  100825:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100828:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10082b:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  10082e:	39 c2                	cmp    %eax,%edx
  100830:	7d 1d                	jge    10084f <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100835:	89 c2                	mov    %eax,%edx
  100837:	89 d0                	mov    %edx,%eax
  100839:	01 c0                	add    %eax,%eax
  10083b:	01 d0                	add    %edx,%eax
  10083d:	c1 e0 02             	shl    $0x2,%eax
  100840:	89 c2                	mov    %eax,%edx
  100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100845:	01 d0                	add    %edx,%eax
  100847:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10084b:	3c a0                	cmp    $0xa0,%al
  10084d:	74 c1                	je     100810 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  10084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100854:	c9                   	leave  
  100855:	c3                   	ret    

00100856 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100856:	55                   	push   %ebp
  100857:	89 e5                	mov    %esp,%ebp
  100859:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10085c:	c7 04 24 76 36 10 00 	movl   $0x103676,(%esp)
  100863:	e8 ba fa ff ff       	call   100322 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100868:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10086f:	00 
  100870:	c7 04 24 8f 36 10 00 	movl   $0x10368f,(%esp)
  100877:	e8 a6 fa ff ff       	call   100322 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10087c:	c7 44 24 04 b2 35 10 	movl   $0x1035b2,0x4(%esp)
  100883:	00 
  100884:	c7 04 24 a7 36 10 00 	movl   $0x1036a7,(%esp)
  10088b:	e8 92 fa ff ff       	call   100322 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100890:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100897:	00 
  100898:	c7 04 24 bf 36 10 00 	movl   $0x1036bf,(%esp)
  10089f:	e8 7e fa ff ff       	call   100322 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008a4:	c7 44 24 04 80 fd 10 	movl   $0x10fd80,0x4(%esp)
  1008ab:	00 
  1008ac:	c7 04 24 d7 36 10 00 	movl   $0x1036d7,(%esp)
  1008b3:	e8 6a fa ff ff       	call   100322 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008b8:	b8 80 fd 10 00       	mov    $0x10fd80,%eax
  1008bd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008c3:	b8 00 00 10 00       	mov    $0x100000,%eax
  1008c8:	29 c2                	sub    %eax,%edx
  1008ca:	89 d0                	mov    %edx,%eax
  1008cc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008d2:	85 c0                	test   %eax,%eax
  1008d4:	0f 48 c2             	cmovs  %edx,%eax
  1008d7:	c1 f8 0a             	sar    $0xa,%eax
  1008da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008de:	c7 04 24 f0 36 10 00 	movl   $0x1036f0,(%esp)
  1008e5:	e8 38 fa ff ff       	call   100322 <cprintf>
}
  1008ea:	c9                   	leave  
  1008eb:	c3                   	ret    

001008ec <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1008ec:	55                   	push   %ebp
  1008ed:	89 e5                	mov    %esp,%ebp
  1008ef:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1008f5:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1008ff:	89 04 24             	mov    %eax,(%esp)
  100902:	e8 12 fc ff ff       	call   100519 <debuginfo_eip>
  100907:	85 c0                	test   %eax,%eax
  100909:	74 15                	je     100920 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10090b:	8b 45 08             	mov    0x8(%ebp),%eax
  10090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100912:	c7 04 24 1a 37 10 00 	movl   $0x10371a,(%esp)
  100919:	e8 04 fa ff ff       	call   100322 <cprintf>
  10091e:	eb 6d                	jmp    10098d <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100927:	eb 1c                	jmp    100945 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  100929:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10092c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10092f:	01 d0                	add    %edx,%eax
  100931:	0f b6 00             	movzbl (%eax),%eax
  100934:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10093a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10093d:	01 ca                	add    %ecx,%edx
  10093f:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100945:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100948:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10094b:	7f dc                	jg     100929 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  10094d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100956:	01 d0                	add    %edx,%eax
  100958:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  10095b:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10095e:	8b 55 08             	mov    0x8(%ebp),%edx
  100961:	89 d1                	mov    %edx,%ecx
  100963:	29 c1                	sub    %eax,%ecx
  100965:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100968:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10096b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10096f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100975:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100979:	89 54 24 08          	mov    %edx,0x8(%esp)
  10097d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100981:	c7 04 24 36 37 10 00 	movl   $0x103736,(%esp)
  100988:	e8 95 f9 ff ff       	call   100322 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  10098d:	c9                   	leave  
  10098e:	c3                   	ret    

0010098f <read_eip>:

static __noinline uint32_t
read_eip(void) {
  10098f:	55                   	push   %ebp
  100990:	89 e5                	mov    %esp,%ebp
  100992:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100995:	8b 45 04             	mov    0x4(%ebp),%eax
  100998:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  10099b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10099e:	c9                   	leave  
  10099f:	c3                   	ret    

001009a0 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009a0:	55                   	push   %ebp
  1009a1:	89 e5                	mov    %esp,%ebp
  1009a3:	53                   	push   %ebx
  1009a4:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009a7:	89 e8                	mov    %ebp,%eax
  1009a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
  1009af:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
  1009b2:	e8 d8 ff ff ff       	call   10098f <read_eip>
  1009b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  1009ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009c1:	e9 8d 00 00 00       	jmp    100a53 <print_stackframe+0xb3>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
  1009c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d4:	c7 04 24 48 37 10 00 	movl   $0x103748,(%esp)
  1009db:	e8 42 f9 ff ff       	call   100322 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
  1009e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009e3:	83 c0 08             	add    $0x8,%eax
  1009e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("0x%08x 0x%08x 0x%08x 0x%08x",*args,*(args+1),*(args+2),*(args+3));
  1009e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009ec:	83 c0 0c             	add    $0xc,%eax
  1009ef:	8b 18                	mov    (%eax),%ebx
  1009f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009f4:	83 c0 08             	add    $0x8,%eax
  1009f7:	8b 08                	mov    (%eax),%ecx
  1009f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009fc:	83 c0 04             	add    $0x4,%eax
  1009ff:	8b 10                	mov    (%eax),%edx
  100a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a04:	8b 00                	mov    (%eax),%eax
  100a06:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100a0a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a0e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a16:	c7 04 24 64 37 10 00 	movl   $0x103764,(%esp)
  100a1d:	e8 00 f9 ff ff       	call   100322 <cprintf>
		cprintf("\n");
  100a22:	c7 04 24 80 37 10 00 	movl   $0x103780,(%esp)
  100a29:	e8 f4 f8 ff ff       	call   100322 <cprintf>
		print_debuginfo(eip-1);
  100a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a31:	83 e8 01             	sub    $0x1,%eax
  100a34:	89 04 24             	mov    %eax,(%esp)
  100a37:	e8 b0 fe ff ff       	call   1008ec <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
  100a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a3f:	83 c0 04             	add    $0x4,%eax
  100a42:	8b 00                	mov    (%eax),%eax
  100a44:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
  100a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a4a:	8b 00                	mov    (%eax),%eax
  100a4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	int i;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  100a4f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a57:	74 0a                	je     100a63 <print_stackframe+0xc3>
  100a59:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a5d:	0f 8e 63 ff ff ff    	jle    1009c6 <print_stackframe+0x26>
		cprintf("\n");
		print_debuginfo(eip-1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
  100a63:	83 c4 44             	add    $0x44,%esp
  100a66:	5b                   	pop    %ebx
  100a67:	5d                   	pop    %ebp
  100a68:	c3                   	ret    

00100a69 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a69:	55                   	push   %ebp
  100a6a:	89 e5                	mov    %esp,%ebp
  100a6c:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a76:	eb 0c                	jmp    100a84 <parse+0x1b>
            *buf ++ = '\0';
  100a78:	8b 45 08             	mov    0x8(%ebp),%eax
  100a7b:	8d 50 01             	lea    0x1(%eax),%edx
  100a7e:	89 55 08             	mov    %edx,0x8(%ebp)
  100a81:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a84:	8b 45 08             	mov    0x8(%ebp),%eax
  100a87:	0f b6 00             	movzbl (%eax),%eax
  100a8a:	84 c0                	test   %al,%al
  100a8c:	74 1d                	je     100aab <parse+0x42>
  100a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  100a91:	0f b6 00             	movzbl (%eax),%eax
  100a94:	0f be c0             	movsbl %al,%eax
  100a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a9b:	c7 04 24 04 38 10 00 	movl   $0x103804,(%esp)
  100aa2:	e8 c3 27 00 00       	call   10326a <strchr>
  100aa7:	85 c0                	test   %eax,%eax
  100aa9:	75 cd                	jne    100a78 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100aab:	8b 45 08             	mov    0x8(%ebp),%eax
  100aae:	0f b6 00             	movzbl (%eax),%eax
  100ab1:	84 c0                	test   %al,%al
  100ab3:	75 02                	jne    100ab7 <parse+0x4e>
            break;
  100ab5:	eb 67                	jmp    100b1e <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ab7:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100abb:	75 14                	jne    100ad1 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100abd:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ac4:	00 
  100ac5:	c7 04 24 09 38 10 00 	movl   $0x103809,(%esp)
  100acc:	e8 51 f8 ff ff       	call   100322 <cprintf>
        }
        argv[argc ++] = buf;
  100ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ad4:	8d 50 01             	lea    0x1(%eax),%edx
  100ad7:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100ada:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ae4:	01 c2                	add    %eax,%edx
  100ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  100ae9:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100aeb:	eb 04                	jmp    100af1 <parse+0x88>
            buf ++;
  100aed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100af1:	8b 45 08             	mov    0x8(%ebp),%eax
  100af4:	0f b6 00             	movzbl (%eax),%eax
  100af7:	84 c0                	test   %al,%al
  100af9:	74 1d                	je     100b18 <parse+0xaf>
  100afb:	8b 45 08             	mov    0x8(%ebp),%eax
  100afe:	0f b6 00             	movzbl (%eax),%eax
  100b01:	0f be c0             	movsbl %al,%eax
  100b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b08:	c7 04 24 04 38 10 00 	movl   $0x103804,(%esp)
  100b0f:	e8 56 27 00 00       	call   10326a <strchr>
  100b14:	85 c0                	test   %eax,%eax
  100b16:	74 d5                	je     100aed <parse+0x84>
            buf ++;
        }
    }
  100b18:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b19:	e9 66 ff ff ff       	jmp    100a84 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b21:	c9                   	leave  
  100b22:	c3                   	ret    

00100b23 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b23:	55                   	push   %ebp
  100b24:	89 e5                	mov    %esp,%ebp
  100b26:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b29:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b30:	8b 45 08             	mov    0x8(%ebp),%eax
  100b33:	89 04 24             	mov    %eax,(%esp)
  100b36:	e8 2e ff ff ff       	call   100a69 <parse>
  100b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b42:	75 0a                	jne    100b4e <runcmd+0x2b>
        return 0;
  100b44:	b8 00 00 00 00       	mov    $0x0,%eax
  100b49:	e9 85 00 00 00       	jmp    100bd3 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b55:	eb 5c                	jmp    100bb3 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b57:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b5d:	89 d0                	mov    %edx,%eax
  100b5f:	01 c0                	add    %eax,%eax
  100b61:	01 d0                	add    %edx,%eax
  100b63:	c1 e0 02             	shl    $0x2,%eax
  100b66:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b6b:	8b 00                	mov    (%eax),%eax
  100b6d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b71:	89 04 24             	mov    %eax,(%esp)
  100b74:	e8 52 26 00 00       	call   1031cb <strcmp>
  100b79:	85 c0                	test   %eax,%eax
  100b7b:	75 32                	jne    100baf <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b80:	89 d0                	mov    %edx,%eax
  100b82:	01 c0                	add    %eax,%eax
  100b84:	01 d0                	add    %edx,%eax
  100b86:	c1 e0 02             	shl    $0x2,%eax
  100b89:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b8e:	8b 40 08             	mov    0x8(%eax),%eax
  100b91:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100b94:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  100b9a:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b9e:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100ba1:	83 c2 04             	add    $0x4,%edx
  100ba4:	89 54 24 04          	mov    %edx,0x4(%esp)
  100ba8:	89 0c 24             	mov    %ecx,(%esp)
  100bab:	ff d0                	call   *%eax
  100bad:	eb 24                	jmp    100bd3 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100baf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bb6:	83 f8 02             	cmp    $0x2,%eax
  100bb9:	76 9c                	jbe    100b57 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bbb:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bc2:	c7 04 24 27 38 10 00 	movl   $0x103827,(%esp)
  100bc9:	e8 54 f7 ff ff       	call   100322 <cprintf>
    return 0;
  100bce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bd3:	c9                   	leave  
  100bd4:	c3                   	ret    

00100bd5 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bd5:	55                   	push   %ebp
  100bd6:	89 e5                	mov    %esp,%ebp
  100bd8:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bdb:	c7 04 24 40 38 10 00 	movl   $0x103840,(%esp)
  100be2:	e8 3b f7 ff ff       	call   100322 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100be7:	c7 04 24 68 38 10 00 	movl   $0x103868,(%esp)
  100bee:	e8 2f f7 ff ff       	call   100322 <cprintf>

    if (tf != NULL) {
  100bf3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100bf7:	74 0b                	je     100c04 <kmonitor+0x2f>
        print_trapframe(tf);
  100bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  100bfc:	89 04 24             	mov    %eax,(%esp)
  100bff:	e8 01 0e 00 00       	call   101a05 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c04:	c7 04 24 8d 38 10 00 	movl   $0x10388d,(%esp)
  100c0b:	e8 09 f6 ff ff       	call   100219 <readline>
  100c10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c13:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c17:	74 18                	je     100c31 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c19:	8b 45 08             	mov    0x8(%ebp),%eax
  100c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c23:	89 04 24             	mov    %eax,(%esp)
  100c26:	e8 f8 fe ff ff       	call   100b23 <runcmd>
  100c2b:	85 c0                	test   %eax,%eax
  100c2d:	79 02                	jns    100c31 <kmonitor+0x5c>
                break;
  100c2f:	eb 02                	jmp    100c33 <kmonitor+0x5e>
            }
        }
    }
  100c31:	eb d1                	jmp    100c04 <kmonitor+0x2f>
}
  100c33:	c9                   	leave  
  100c34:	c3                   	ret    

00100c35 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c35:	55                   	push   %ebp
  100c36:	89 e5                	mov    %esp,%ebp
  100c38:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c42:	eb 3f                	jmp    100c83 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c47:	89 d0                	mov    %edx,%eax
  100c49:	01 c0                	add    %eax,%eax
  100c4b:	01 d0                	add    %edx,%eax
  100c4d:	c1 e0 02             	shl    $0x2,%eax
  100c50:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c55:	8b 48 04             	mov    0x4(%eax),%ecx
  100c58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c5b:	89 d0                	mov    %edx,%eax
  100c5d:	01 c0                	add    %eax,%eax
  100c5f:	01 d0                	add    %edx,%eax
  100c61:	c1 e0 02             	shl    $0x2,%eax
  100c64:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c69:	8b 00                	mov    (%eax),%eax
  100c6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c73:	c7 04 24 91 38 10 00 	movl   $0x103891,(%esp)
  100c7a:	e8 a3 f6 ff ff       	call   100322 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c86:	83 f8 02             	cmp    $0x2,%eax
  100c89:	76 b9                	jbe    100c44 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100c8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c90:	c9                   	leave  
  100c91:	c3                   	ret    

00100c92 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100c92:	55                   	push   %ebp
  100c93:	89 e5                	mov    %esp,%ebp
  100c95:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100c98:	e8 b9 fb ff ff       	call   100856 <print_kerninfo>
    return 0;
  100c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ca2:	c9                   	leave  
  100ca3:	c3                   	ret    

00100ca4 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100ca4:	55                   	push   %ebp
  100ca5:	89 e5                	mov    %esp,%ebp
  100ca7:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100caa:	e8 f1 fc ff ff       	call   1009a0 <print_stackframe>
    return 0;
  100caf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cb4:	c9                   	leave  
  100cb5:	c3                   	ret    

00100cb6 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cb6:	55                   	push   %ebp
  100cb7:	89 e5                	mov    %esp,%ebp
  100cb9:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cbc:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  100cc1:	85 c0                	test   %eax,%eax
  100cc3:	74 02                	je     100cc7 <__panic+0x11>
        goto panic_dead;
  100cc5:	eb 59                	jmp    100d20 <__panic+0x6a>
    }
    is_panic = 1;
  100cc7:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  100cce:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100cd1:	8d 45 14             	lea    0x14(%ebp),%eax
  100cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cda:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cde:	8b 45 08             	mov    0x8(%ebp),%eax
  100ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ce5:	c7 04 24 9a 38 10 00 	movl   $0x10389a,(%esp)
  100cec:	e8 31 f6 ff ff       	call   100322 <cprintf>
    vcprintf(fmt, ap);
  100cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cf8:	8b 45 10             	mov    0x10(%ebp),%eax
  100cfb:	89 04 24             	mov    %eax,(%esp)
  100cfe:	e8 ec f5 ff ff       	call   1002ef <vcprintf>
    cprintf("\n");
  100d03:	c7 04 24 b6 38 10 00 	movl   $0x1038b6,(%esp)
  100d0a:	e8 13 f6 ff ff       	call   100322 <cprintf>
    
    cprintf("stack trackback:\n");
  100d0f:	c7 04 24 b8 38 10 00 	movl   $0x1038b8,(%esp)
  100d16:	e8 07 f6 ff ff       	call   100322 <cprintf>
    print_stackframe();
  100d1b:	e8 80 fc ff ff       	call   1009a0 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d20:	e8 22 09 00 00       	call   101647 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d2c:	e8 a4 fe ff ff       	call   100bd5 <kmonitor>
    }
  100d31:	eb f2                	jmp    100d25 <__panic+0x6f>

00100d33 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d33:	55                   	push   %ebp
  100d34:	89 e5                	mov    %esp,%ebp
  100d36:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d39:	8d 45 14             	lea    0x14(%ebp),%eax
  100d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d42:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d46:	8b 45 08             	mov    0x8(%ebp),%eax
  100d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d4d:	c7 04 24 ca 38 10 00 	movl   $0x1038ca,(%esp)
  100d54:	e8 c9 f5 ff ff       	call   100322 <cprintf>
    vcprintf(fmt, ap);
  100d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d60:	8b 45 10             	mov    0x10(%ebp),%eax
  100d63:	89 04 24             	mov    %eax,(%esp)
  100d66:	e8 84 f5 ff ff       	call   1002ef <vcprintf>
    cprintf("\n");
  100d6b:	c7 04 24 b6 38 10 00 	movl   $0x1038b6,(%esp)
  100d72:	e8 ab f5 ff ff       	call   100322 <cprintf>
    va_end(ap);
}
  100d77:	c9                   	leave  
  100d78:	c3                   	ret    

00100d79 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d79:	55                   	push   %ebp
  100d7a:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d7c:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100d81:	5d                   	pop    %ebp
  100d82:	c3                   	ret    

00100d83 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d83:	55                   	push   %ebp
  100d84:	89 e5                	mov    %esp,%ebp
  100d86:	83 ec 28             	sub    $0x28,%esp
  100d89:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d8f:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d93:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100d97:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d9b:	ee                   	out    %al,(%dx)
  100d9c:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100da2:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100da6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100daa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dae:	ee                   	out    %al,(%dx)
  100daf:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100db5:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100db9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dbd:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dc1:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dc2:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100dc9:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dcc:	c7 04 24 e8 38 10 00 	movl   $0x1038e8,(%esp)
  100dd3:	e8 4a f5 ff ff       	call   100322 <cprintf>
    pic_enable(IRQ_TIMER);
  100dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100ddf:	e8 c1 08 00 00       	call   1016a5 <pic_enable>
}
  100de4:	c9                   	leave  
  100de5:	c3                   	ret    

00100de6 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100de6:	55                   	push   %ebp
  100de7:	89 e5                	mov    %esp,%ebp
  100de9:	83 ec 10             	sub    $0x10,%esp
  100dec:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100df2:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100df6:	89 c2                	mov    %eax,%edx
  100df8:	ec                   	in     (%dx),%al
  100df9:	88 45 fd             	mov    %al,-0x3(%ebp)
  100dfc:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e02:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e06:	89 c2                	mov    %eax,%edx
  100e08:	ec                   	in     (%dx),%al
  100e09:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e0c:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e12:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e16:	89 c2                	mov    %eax,%edx
  100e18:	ec                   	in     (%dx),%al
  100e19:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e1c:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e22:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e26:	89 c2                	mov    %eax,%edx
  100e28:	ec                   	in     (%dx),%al
  100e29:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e2c:	c9                   	leave  
  100e2d:	c3                   	ret    

00100e2e <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e2e:	55                   	push   %ebp
  100e2f:	89 e5                	mov    %esp,%ebp
  100e31:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e34:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e3e:	0f b7 00             	movzwl (%eax),%eax
  100e41:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e48:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e50:	0f b7 00             	movzwl (%eax),%eax
  100e53:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e57:	74 12                	je     100e6b <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e59:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e60:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e67:	b4 03 
  100e69:	eb 13                	jmp    100e7e <cga_init+0x50>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e6e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e72:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e75:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e7c:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e7e:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e85:	0f b7 c0             	movzwl %ax,%eax
  100e88:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100e8c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e98:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e99:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ea0:	83 c0 01             	add    $0x1,%eax
  100ea3:	0f b7 c0             	movzwl %ax,%eax
  100ea6:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100eaa:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100eae:	89 c2                	mov    %eax,%edx
  100eb0:	ec                   	in     (%dx),%al
  100eb1:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100eb4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eb8:	0f b6 c0             	movzbl %al,%eax
  100ebb:	c1 e0 08             	shl    $0x8,%eax
  100ebe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100ec1:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ec8:	0f b7 c0             	movzwl %ax,%eax
  100ecb:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100ecf:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ed3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ed7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100edb:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100edc:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ee3:	83 c0 01             	add    $0x1,%eax
  100ee6:	0f b7 c0             	movzwl %ax,%eax
  100ee9:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100eed:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100ef1:	89 c2                	mov    %eax,%edx
  100ef3:	ec                   	in     (%dx),%al
  100ef4:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100ef7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100efb:	0f b6 c0             	movzbl %al,%eax
  100efe:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100f01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f04:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f0c:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100f12:	c9                   	leave  
  100f13:	c3                   	ret    

00100f14 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f14:	55                   	push   %ebp
  100f15:	89 e5                	mov    %esp,%ebp
  100f17:	83 ec 48             	sub    $0x48,%esp
  100f1a:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f20:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f24:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f28:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f2c:	ee                   	out    %al,(%dx)
  100f2d:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f33:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f37:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f3b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f3f:	ee                   	out    %al,(%dx)
  100f40:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f46:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100f4a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f4e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f52:	ee                   	out    %al,(%dx)
  100f53:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f59:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100f5d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f61:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f65:	ee                   	out    %al,(%dx)
  100f66:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100f6c:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100f70:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f74:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f78:	ee                   	out    %al,(%dx)
  100f79:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100f7f:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100f83:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f87:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f8b:	ee                   	out    %al,(%dx)
  100f8c:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f92:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100f96:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f9a:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f9e:	ee                   	out    %al,(%dx)
  100f9f:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fa5:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100fa9:	89 c2                	mov    %eax,%edx
  100fab:	ec                   	in     (%dx),%al
  100fac:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100faf:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fb3:	3c ff                	cmp    $0xff,%al
  100fb5:	0f 95 c0             	setne  %al
  100fb8:	0f b6 c0             	movzbl %al,%eax
  100fbb:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100fc0:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fc6:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100fca:	89 c2                	mov    %eax,%edx
  100fcc:	ec                   	in     (%dx),%al
  100fcd:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100fd0:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100fd6:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100fda:	89 c2                	mov    %eax,%edx
  100fdc:	ec                   	in     (%dx),%al
  100fdd:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fe0:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fe5:	85 c0                	test   %eax,%eax
  100fe7:	74 0c                	je     100ff5 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100fe9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100ff0:	e8 b0 06 00 00       	call   1016a5 <pic_enable>
    }
}
  100ff5:	c9                   	leave  
  100ff6:	c3                   	ret    

00100ff7 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100ff7:	55                   	push   %ebp
  100ff8:	89 e5                	mov    %esp,%ebp
  100ffa:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100ffd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101004:	eb 09                	jmp    10100f <lpt_putc_sub+0x18>
        delay();
  101006:	e8 db fd ff ff       	call   100de6 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10100b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10100f:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101015:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101019:	89 c2                	mov    %eax,%edx
  10101b:	ec                   	in     (%dx),%al
  10101c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10101f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101023:	84 c0                	test   %al,%al
  101025:	78 09                	js     101030 <lpt_putc_sub+0x39>
  101027:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10102e:	7e d6                	jle    101006 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101030:	8b 45 08             	mov    0x8(%ebp),%eax
  101033:	0f b6 c0             	movzbl %al,%eax
  101036:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  10103c:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10103f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101043:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101047:	ee                   	out    %al,(%dx)
  101048:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  10104e:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101052:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101056:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10105a:	ee                   	out    %al,(%dx)
  10105b:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  101061:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  101065:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101069:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10106d:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10106e:	c9                   	leave  
  10106f:	c3                   	ret    

00101070 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101070:	55                   	push   %ebp
  101071:	89 e5                	mov    %esp,%ebp
  101073:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101076:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10107a:	74 0d                	je     101089 <lpt_putc+0x19>
        lpt_putc_sub(c);
  10107c:	8b 45 08             	mov    0x8(%ebp),%eax
  10107f:	89 04 24             	mov    %eax,(%esp)
  101082:	e8 70 ff ff ff       	call   100ff7 <lpt_putc_sub>
  101087:	eb 24                	jmp    1010ad <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  101089:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101090:	e8 62 ff ff ff       	call   100ff7 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101095:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10109c:	e8 56 ff ff ff       	call   100ff7 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010a1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010a8:	e8 4a ff ff ff       	call   100ff7 <lpt_putc_sub>
    }
}
  1010ad:	c9                   	leave  
  1010ae:	c3                   	ret    

001010af <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010af:	55                   	push   %ebp
  1010b0:	89 e5                	mov    %esp,%ebp
  1010b2:	53                   	push   %ebx
  1010b3:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b9:	b0 00                	mov    $0x0,%al
  1010bb:	85 c0                	test   %eax,%eax
  1010bd:	75 07                	jne    1010c6 <cga_putc+0x17>
        c |= 0x0700;
  1010bf:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c9:	0f b6 c0             	movzbl %al,%eax
  1010cc:	83 f8 0a             	cmp    $0xa,%eax
  1010cf:	74 4c                	je     10111d <cga_putc+0x6e>
  1010d1:	83 f8 0d             	cmp    $0xd,%eax
  1010d4:	74 57                	je     10112d <cga_putc+0x7e>
  1010d6:	83 f8 08             	cmp    $0x8,%eax
  1010d9:	0f 85 88 00 00 00    	jne    101167 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  1010df:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010e6:	66 85 c0             	test   %ax,%ax
  1010e9:	74 30                	je     10111b <cga_putc+0x6c>
            crt_pos --;
  1010eb:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010f2:	83 e8 01             	sub    $0x1,%eax
  1010f5:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010fb:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101100:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  101107:	0f b7 d2             	movzwl %dx,%edx
  10110a:	01 d2                	add    %edx,%edx
  10110c:	01 c2                	add    %eax,%edx
  10110e:	8b 45 08             	mov    0x8(%ebp),%eax
  101111:	b0 00                	mov    $0x0,%al
  101113:	83 c8 20             	or     $0x20,%eax
  101116:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101119:	eb 72                	jmp    10118d <cga_putc+0xde>
  10111b:	eb 70                	jmp    10118d <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  10111d:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101124:	83 c0 50             	add    $0x50,%eax
  101127:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10112d:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101134:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  10113b:	0f b7 c1             	movzwl %cx,%eax
  10113e:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101144:	c1 e8 10             	shr    $0x10,%eax
  101147:	89 c2                	mov    %eax,%edx
  101149:	66 c1 ea 06          	shr    $0x6,%dx
  10114d:	89 d0                	mov    %edx,%eax
  10114f:	c1 e0 02             	shl    $0x2,%eax
  101152:	01 d0                	add    %edx,%eax
  101154:	c1 e0 04             	shl    $0x4,%eax
  101157:	29 c1                	sub    %eax,%ecx
  101159:	89 ca                	mov    %ecx,%edx
  10115b:	89 d8                	mov    %ebx,%eax
  10115d:	29 d0                	sub    %edx,%eax
  10115f:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  101165:	eb 26                	jmp    10118d <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101167:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  10116d:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101174:	8d 50 01             	lea    0x1(%eax),%edx
  101177:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  10117e:	0f b7 c0             	movzwl %ax,%eax
  101181:	01 c0                	add    %eax,%eax
  101183:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101186:	8b 45 08             	mov    0x8(%ebp),%eax
  101189:	66 89 02             	mov    %ax,(%edx)
        break;
  10118c:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10118d:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101194:	66 3d cf 07          	cmp    $0x7cf,%ax
  101198:	76 5b                	jbe    1011f5 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  10119a:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  10119f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011a5:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011aa:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011b1:	00 
  1011b2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011b6:	89 04 24             	mov    %eax,(%esp)
  1011b9:	e8 aa 22 00 00       	call   103468 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011be:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011c5:	eb 15                	jmp    1011dc <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  1011c7:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011cf:	01 d2                	add    %edx,%edx
  1011d1:	01 d0                	add    %edx,%eax
  1011d3:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011dc:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011e3:	7e e2                	jle    1011c7 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011e5:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011ec:	83 e8 50             	sub    $0x50,%eax
  1011ef:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011f5:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011fc:	0f b7 c0             	movzwl %ax,%eax
  1011ff:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101203:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  101207:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10120b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10120f:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101210:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101217:	66 c1 e8 08          	shr    $0x8,%ax
  10121b:	0f b6 c0             	movzbl %al,%eax
  10121e:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101225:	83 c2 01             	add    $0x1,%edx
  101228:	0f b7 d2             	movzwl %dx,%edx
  10122b:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  10122f:	88 45 ed             	mov    %al,-0x13(%ebp)
  101232:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101236:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10123a:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10123b:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101242:	0f b7 c0             	movzwl %ax,%eax
  101245:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  101249:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  10124d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101251:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101255:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  101256:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10125d:	0f b6 c0             	movzbl %al,%eax
  101260:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101267:	83 c2 01             	add    $0x1,%edx
  10126a:	0f b7 d2             	movzwl %dx,%edx
  10126d:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  101271:	88 45 e5             	mov    %al,-0x1b(%ebp)
  101274:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101278:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10127c:	ee                   	out    %al,(%dx)
}
  10127d:	83 c4 34             	add    $0x34,%esp
  101280:	5b                   	pop    %ebx
  101281:	5d                   	pop    %ebp
  101282:	c3                   	ret    

00101283 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101283:	55                   	push   %ebp
  101284:	89 e5                	mov    %esp,%ebp
  101286:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101289:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101290:	eb 09                	jmp    10129b <serial_putc_sub+0x18>
        delay();
  101292:	e8 4f fb ff ff       	call   100de6 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101297:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10129b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1012a1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012a5:	89 c2                	mov    %eax,%edx
  1012a7:	ec                   	in     (%dx),%al
  1012a8:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1012ab:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1012af:	0f b6 c0             	movzbl %al,%eax
  1012b2:	83 e0 20             	and    $0x20,%eax
  1012b5:	85 c0                	test   %eax,%eax
  1012b7:	75 09                	jne    1012c2 <serial_putc_sub+0x3f>
  1012b9:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012c0:	7e d0                	jle    101292 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  1012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1012c5:	0f b6 c0             	movzbl %al,%eax
  1012c8:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012ce:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012d1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012d5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012d9:	ee                   	out    %al,(%dx)
}
  1012da:	c9                   	leave  
  1012db:	c3                   	ret    

001012dc <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012dc:	55                   	push   %ebp
  1012dd:	89 e5                	mov    %esp,%ebp
  1012df:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012e2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012e6:	74 0d                	je     1012f5 <serial_putc+0x19>
        serial_putc_sub(c);
  1012e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1012eb:	89 04 24             	mov    %eax,(%esp)
  1012ee:	e8 90 ff ff ff       	call   101283 <serial_putc_sub>
  1012f3:	eb 24                	jmp    101319 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  1012f5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012fc:	e8 82 ff ff ff       	call   101283 <serial_putc_sub>
        serial_putc_sub(' ');
  101301:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101308:	e8 76 ff ff ff       	call   101283 <serial_putc_sub>
        serial_putc_sub('\b');
  10130d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101314:	e8 6a ff ff ff       	call   101283 <serial_putc_sub>
    }
}
  101319:	c9                   	leave  
  10131a:	c3                   	ret    

0010131b <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10131b:	55                   	push   %ebp
  10131c:	89 e5                	mov    %esp,%ebp
  10131e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101321:	eb 33                	jmp    101356 <cons_intr+0x3b>
        if (c != 0) {
  101323:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101327:	74 2d                	je     101356 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101329:	a1 84 f0 10 00       	mov    0x10f084,%eax
  10132e:	8d 50 01             	lea    0x1(%eax),%edx
  101331:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  101337:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10133a:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101340:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101345:	3d 00 02 00 00       	cmp    $0x200,%eax
  10134a:	75 0a                	jne    101356 <cons_intr+0x3b>
                cons.wpos = 0;
  10134c:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101353:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  101356:	8b 45 08             	mov    0x8(%ebp),%eax
  101359:	ff d0                	call   *%eax
  10135b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10135e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101362:	75 bf                	jne    101323 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101364:	c9                   	leave  
  101365:	c3                   	ret    

00101366 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101366:	55                   	push   %ebp
  101367:	89 e5                	mov    %esp,%ebp
  101369:	83 ec 10             	sub    $0x10,%esp
  10136c:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101372:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101376:	89 c2                	mov    %eax,%edx
  101378:	ec                   	in     (%dx),%al
  101379:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10137c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101380:	0f b6 c0             	movzbl %al,%eax
  101383:	83 e0 01             	and    $0x1,%eax
  101386:	85 c0                	test   %eax,%eax
  101388:	75 07                	jne    101391 <serial_proc_data+0x2b>
        return -1;
  10138a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10138f:	eb 2a                	jmp    1013bb <serial_proc_data+0x55>
  101391:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101397:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10139b:	89 c2                	mov    %eax,%edx
  10139d:	ec                   	in     (%dx),%al
  10139e:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013a1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013a5:	0f b6 c0             	movzbl %al,%eax
  1013a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013ab:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013af:	75 07                	jne    1013b8 <serial_proc_data+0x52>
        c = '\b';
  1013b1:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013bb:	c9                   	leave  
  1013bc:	c3                   	ret    

001013bd <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013bd:	55                   	push   %ebp
  1013be:	89 e5                	mov    %esp,%ebp
  1013c0:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013c3:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013c8:	85 c0                	test   %eax,%eax
  1013ca:	74 0c                	je     1013d8 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013cc:	c7 04 24 66 13 10 00 	movl   $0x101366,(%esp)
  1013d3:	e8 43 ff ff ff       	call   10131b <cons_intr>
    }
}
  1013d8:	c9                   	leave  
  1013d9:	c3                   	ret    

001013da <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013da:	55                   	push   %ebp
  1013db:	89 e5                	mov    %esp,%ebp
  1013dd:	83 ec 38             	sub    $0x38,%esp
  1013e0:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013e6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013ea:	89 c2                	mov    %eax,%edx
  1013ec:	ec                   	in     (%dx),%al
  1013ed:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013f0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013f4:	0f b6 c0             	movzbl %al,%eax
  1013f7:	83 e0 01             	and    $0x1,%eax
  1013fa:	85 c0                	test   %eax,%eax
  1013fc:	75 0a                	jne    101408 <kbd_proc_data+0x2e>
        return -1;
  1013fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101403:	e9 59 01 00 00       	jmp    101561 <kbd_proc_data+0x187>
  101408:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10140e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101412:	89 c2                	mov    %eax,%edx
  101414:	ec                   	in     (%dx),%al
  101415:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101418:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10141c:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10141f:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101423:	75 17                	jne    10143c <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101425:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10142a:	83 c8 40             	or     $0x40,%eax
  10142d:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101432:	b8 00 00 00 00       	mov    $0x0,%eax
  101437:	e9 25 01 00 00       	jmp    101561 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  10143c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101440:	84 c0                	test   %al,%al
  101442:	79 47                	jns    10148b <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101444:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101449:	83 e0 40             	and    $0x40,%eax
  10144c:	85 c0                	test   %eax,%eax
  10144e:	75 09                	jne    101459 <kbd_proc_data+0x7f>
  101450:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101454:	83 e0 7f             	and    $0x7f,%eax
  101457:	eb 04                	jmp    10145d <kbd_proc_data+0x83>
  101459:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10145d:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101460:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101464:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10146b:	83 c8 40             	or     $0x40,%eax
  10146e:	0f b6 c0             	movzbl %al,%eax
  101471:	f7 d0                	not    %eax
  101473:	89 c2                	mov    %eax,%edx
  101475:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10147a:	21 d0                	and    %edx,%eax
  10147c:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101481:	b8 00 00 00 00       	mov    $0x0,%eax
  101486:	e9 d6 00 00 00       	jmp    101561 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  10148b:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101490:	83 e0 40             	and    $0x40,%eax
  101493:	85 c0                	test   %eax,%eax
  101495:	74 11                	je     1014a8 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101497:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10149b:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014a0:	83 e0 bf             	and    $0xffffffbf,%eax
  1014a3:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  1014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ac:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  1014b3:	0f b6 d0             	movzbl %al,%edx
  1014b6:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014bb:	09 d0                	or     %edx,%eax
  1014bd:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014c2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c6:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014cd:	0f b6 d0             	movzbl %al,%edx
  1014d0:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014d5:	31 d0                	xor    %edx,%eax
  1014d7:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014dc:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014e1:	83 e0 03             	and    $0x3,%eax
  1014e4:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014eb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ef:	01 d0                	add    %edx,%eax
  1014f1:	0f b6 00             	movzbl (%eax),%eax
  1014f4:	0f b6 c0             	movzbl %al,%eax
  1014f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014fa:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014ff:	83 e0 08             	and    $0x8,%eax
  101502:	85 c0                	test   %eax,%eax
  101504:	74 22                	je     101528 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101506:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  10150a:	7e 0c                	jle    101518 <kbd_proc_data+0x13e>
  10150c:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101510:	7f 06                	jg     101518 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101512:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101516:	eb 10                	jmp    101528 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101518:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10151c:	7e 0a                	jle    101528 <kbd_proc_data+0x14e>
  10151e:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101522:	7f 04                	jg     101528 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101524:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101528:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10152d:	f7 d0                	not    %eax
  10152f:	83 e0 06             	and    $0x6,%eax
  101532:	85 c0                	test   %eax,%eax
  101534:	75 28                	jne    10155e <kbd_proc_data+0x184>
  101536:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  10153d:	75 1f                	jne    10155e <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  10153f:	c7 04 24 03 39 10 00 	movl   $0x103903,(%esp)
  101546:	e8 d7 ed ff ff       	call   100322 <cprintf>
  10154b:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101551:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101555:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101559:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  10155d:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101561:	c9                   	leave  
  101562:	c3                   	ret    

00101563 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101563:	55                   	push   %ebp
  101564:	89 e5                	mov    %esp,%ebp
  101566:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101569:	c7 04 24 da 13 10 00 	movl   $0x1013da,(%esp)
  101570:	e8 a6 fd ff ff       	call   10131b <cons_intr>
}
  101575:	c9                   	leave  
  101576:	c3                   	ret    

00101577 <kbd_init>:

static void
kbd_init(void) {
  101577:	55                   	push   %ebp
  101578:	89 e5                	mov    %esp,%ebp
  10157a:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10157d:	e8 e1 ff ff ff       	call   101563 <kbd_intr>
    pic_enable(IRQ_KBD);
  101582:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101589:	e8 17 01 00 00       	call   1016a5 <pic_enable>
}
  10158e:	c9                   	leave  
  10158f:	c3                   	ret    

00101590 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101590:	55                   	push   %ebp
  101591:	89 e5                	mov    %esp,%ebp
  101593:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101596:	e8 93 f8 ff ff       	call   100e2e <cga_init>
    serial_init();
  10159b:	e8 74 f9 ff ff       	call   100f14 <serial_init>
    kbd_init();
  1015a0:	e8 d2 ff ff ff       	call   101577 <kbd_init>
    if (!serial_exists) {
  1015a5:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1015aa:	85 c0                	test   %eax,%eax
  1015ac:	75 0c                	jne    1015ba <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015ae:	c7 04 24 0f 39 10 00 	movl   $0x10390f,(%esp)
  1015b5:	e8 68 ed ff ff       	call   100322 <cprintf>
    }
}
  1015ba:	c9                   	leave  
  1015bb:	c3                   	ret    

001015bc <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015bc:	55                   	push   %ebp
  1015bd:	89 e5                	mov    %esp,%ebp
  1015bf:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1015c5:	89 04 24             	mov    %eax,(%esp)
  1015c8:	e8 a3 fa ff ff       	call   101070 <lpt_putc>
    cga_putc(c);
  1015cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1015d0:	89 04 24             	mov    %eax,(%esp)
  1015d3:	e8 d7 fa ff ff       	call   1010af <cga_putc>
    serial_putc(c);
  1015d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1015db:	89 04 24             	mov    %eax,(%esp)
  1015de:	e8 f9 fc ff ff       	call   1012dc <serial_putc>
}
  1015e3:	c9                   	leave  
  1015e4:	c3                   	ret    

001015e5 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015e5:	55                   	push   %ebp
  1015e6:	89 e5                	mov    %esp,%ebp
  1015e8:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015eb:	e8 cd fd ff ff       	call   1013bd <serial_intr>
    kbd_intr();
  1015f0:	e8 6e ff ff ff       	call   101563 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015f5:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015fb:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101600:	39 c2                	cmp    %eax,%edx
  101602:	74 36                	je     10163a <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  101604:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101609:	8d 50 01             	lea    0x1(%eax),%edx
  10160c:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  101612:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  101619:	0f b6 c0             	movzbl %al,%eax
  10161c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  10161f:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101624:	3d 00 02 00 00       	cmp    $0x200,%eax
  101629:	75 0a                	jne    101635 <cons_getc+0x50>
            cons.rpos = 0;
  10162b:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  101632:	00 00 00 
        }
        return c;
  101635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101638:	eb 05                	jmp    10163f <cons_getc+0x5a>
    }
    return 0;
  10163a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10163f:	c9                   	leave  
  101640:	c3                   	ret    

00101641 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101641:	55                   	push   %ebp
  101642:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  101644:	fb                   	sti    
    sti();
}
  101645:	5d                   	pop    %ebp
  101646:	c3                   	ret    

00101647 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101647:	55                   	push   %ebp
  101648:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  10164a:	fa                   	cli    
    cli();
}
  10164b:	5d                   	pop    %ebp
  10164c:	c3                   	ret    

0010164d <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10164d:	55                   	push   %ebp
  10164e:	89 e5                	mov    %esp,%ebp
  101650:	83 ec 14             	sub    $0x14,%esp
  101653:	8b 45 08             	mov    0x8(%ebp),%eax
  101656:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10165a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10165e:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  101664:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101669:	85 c0                	test   %eax,%eax
  10166b:	74 36                	je     1016a3 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  10166d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101671:	0f b6 c0             	movzbl %al,%eax
  101674:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10167a:	88 45 fd             	mov    %al,-0x3(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10167d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101681:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101685:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101686:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10168a:	66 c1 e8 08          	shr    $0x8,%ax
  10168e:	0f b6 c0             	movzbl %al,%eax
  101691:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101697:	88 45 f9             	mov    %al,-0x7(%ebp)
  10169a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10169e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016a2:	ee                   	out    %al,(%dx)
    }
}
  1016a3:	c9                   	leave  
  1016a4:	c3                   	ret    

001016a5 <pic_enable>:

void
pic_enable(unsigned int irq) {
  1016a5:	55                   	push   %ebp
  1016a6:	89 e5                	mov    %esp,%ebp
  1016a8:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1016ae:	ba 01 00 00 00       	mov    $0x1,%edx
  1016b3:	89 c1                	mov    %eax,%ecx
  1016b5:	d3 e2                	shl    %cl,%edx
  1016b7:	89 d0                	mov    %edx,%eax
  1016b9:	f7 d0                	not    %eax
  1016bb:	89 c2                	mov    %eax,%edx
  1016bd:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016c4:	21 d0                	and    %edx,%eax
  1016c6:	0f b7 c0             	movzwl %ax,%eax
  1016c9:	89 04 24             	mov    %eax,(%esp)
  1016cc:	e8 7c ff ff ff       	call   10164d <pic_setmask>
}
  1016d1:	c9                   	leave  
  1016d2:	c3                   	ret    

001016d3 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016d3:	55                   	push   %ebp
  1016d4:	89 e5                	mov    %esp,%ebp
  1016d6:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1016d9:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016e0:	00 00 00 
  1016e3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016e9:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  1016ed:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016f1:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016f5:	ee                   	out    %al,(%dx)
  1016f6:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016fc:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  101700:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101704:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101708:	ee                   	out    %al,(%dx)
  101709:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10170f:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101713:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101717:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10171b:	ee                   	out    %al,(%dx)
  10171c:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  101722:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  101726:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10172a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10172e:	ee                   	out    %al,(%dx)
  10172f:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  101735:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  101739:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10173d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101741:	ee                   	out    %al,(%dx)
  101742:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  101748:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  10174c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101750:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101754:	ee                   	out    %al,(%dx)
  101755:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  10175b:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  10175f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101763:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101767:	ee                   	out    %al,(%dx)
  101768:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  10176e:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101772:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101776:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10177a:	ee                   	out    %al,(%dx)
  10177b:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101781:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101785:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101789:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10178d:	ee                   	out    %al,(%dx)
  10178e:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101794:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101798:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10179c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017a0:	ee                   	out    %al,(%dx)
  1017a1:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  1017a7:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  1017ab:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017af:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017b3:	ee                   	out    %al,(%dx)
  1017b4:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1017ba:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  1017be:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017c2:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017c6:	ee                   	out    %al,(%dx)
  1017c7:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  1017cd:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  1017d1:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017d5:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017d9:	ee                   	out    %al,(%dx)
  1017da:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  1017e0:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  1017e4:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017e8:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017ec:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017ed:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017f4:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017f8:	74 12                	je     10180c <pic_init+0x139>
        pic_setmask(irq_mask);
  1017fa:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  101801:	0f b7 c0             	movzwl %ax,%eax
  101804:	89 04 24             	mov    %eax,(%esp)
  101807:	e8 41 fe ff ff       	call   10164d <pic_setmask>
    }
}
  10180c:	c9                   	leave  
  10180d:	c3                   	ret    

0010180e <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10180e:	55                   	push   %ebp
  10180f:	89 e5                	mov    %esp,%ebp
  101811:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101814:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10181b:	00 
  10181c:	c7 04 24 40 39 10 00 	movl   $0x103940,(%esp)
  101823:	e8 fa ea ff ff       	call   100322 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101828:	c7 04 24 4a 39 10 00 	movl   $0x10394a,(%esp)
  10182f:	e8 ee ea ff ff       	call   100322 <cprintf>
    panic("EOT: kernel seems ok.");
  101834:	c7 44 24 08 58 39 10 	movl   $0x103958,0x8(%esp)
  10183b:	00 
  10183c:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  101843:	00 
  101844:	c7 04 24 6e 39 10 00 	movl   $0x10396e,(%esp)
  10184b:	e8 66 f4 ff ff       	call   100cb6 <__panic>

00101850 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101850:	55                   	push   %ebp
  101851:	89 e5                	mov    %esp,%ebp
  101853:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
  101856:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10185d:	e9 c3 00 00 00       	jmp    101925 <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101862:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101865:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  10186c:	89 c2                	mov    %eax,%edx
  10186e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101871:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  101878:	00 
  101879:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10187c:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  101883:	00 08 00 
  101886:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101889:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101890:	00 
  101891:	83 e2 e0             	and    $0xffffffe0,%edx
  101894:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  10189b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10189e:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  1018a5:	00 
  1018a6:	83 e2 1f             	and    $0x1f,%edx
  1018a9:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  1018b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b3:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018ba:	00 
  1018bb:	83 e2 f0             	and    $0xfffffff0,%edx
  1018be:	83 ca 0e             	or     $0xe,%edx
  1018c1:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018cb:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018d2:	00 
  1018d3:	83 e2 ef             	and    $0xffffffef,%edx
  1018d6:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e0:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018e7:	00 
  1018e8:	83 e2 9f             	and    $0xffffff9f,%edx
  1018eb:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f5:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018fc:	00 
  1018fd:	83 ca 80             	or     $0xffffff80,%edx
  101900:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  101907:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190a:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101911:	c1 e8 10             	shr    $0x10,%eax
  101914:	89 c2                	mov    %eax,%edx
  101916:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101919:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  101920:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0;i < sizeof(idt) / sizeof(struct gatedesc); i++){
  101921:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101925:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101928:	3d ff 00 00 00       	cmp    $0xff,%eax
  10192d:	0f 86 2f ff ff ff    	jbe    101862 <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
	}
	//SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], 3);
  101933:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101938:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  10193e:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  101945:	08 00 
  101947:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10194e:	83 e0 e0             	and    $0xffffffe0,%eax
  101951:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101956:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10195d:	83 e0 1f             	and    $0x1f,%eax
  101960:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101965:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10196c:	83 c8 0f             	or     $0xf,%eax
  10196f:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101974:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10197b:	83 e0 ef             	and    $0xffffffef,%eax
  10197e:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101983:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10198a:	83 c8 60             	or     $0x60,%eax
  10198d:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101992:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101999:	83 c8 80             	or     $0xffffff80,%eax
  10199c:	a2 6d f4 10 00       	mov    %al,0x10f46d
  1019a1:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  1019a6:	c1 e8 10             	shr    $0x10,%eax
  1019a9:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  1019af:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  1019b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019b9:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);

}
  1019bc:	c9                   	leave  
  1019bd:	c3                   	ret    

001019be <trapname>:

static const char *
trapname(int trapno) {
  1019be:	55                   	push   %ebp
  1019bf:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c4:	83 f8 13             	cmp    $0x13,%eax
  1019c7:	77 0c                	ja     1019d5 <trapname+0x17>
        return excnames[trapno];
  1019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1019cc:	8b 04 85 c0 3c 10 00 	mov    0x103cc0(,%eax,4),%eax
  1019d3:	eb 18                	jmp    1019ed <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019d5:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019d9:	7e 0d                	jle    1019e8 <trapname+0x2a>
  1019db:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019df:	7f 07                	jg     1019e8 <trapname+0x2a>
        return "Hardware Interrupt";
  1019e1:	b8 7f 39 10 00       	mov    $0x10397f,%eax
  1019e6:	eb 05                	jmp    1019ed <trapname+0x2f>
    }
    return "(unknown trap)";
  1019e8:	b8 92 39 10 00       	mov    $0x103992,%eax
}
  1019ed:	5d                   	pop    %ebp
  1019ee:	c3                   	ret    

001019ef <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019ef:	55                   	push   %ebp
  1019f0:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019f9:	66 83 f8 08          	cmp    $0x8,%ax
  1019fd:	0f 94 c0             	sete   %al
  101a00:	0f b6 c0             	movzbl %al,%eax
}
  101a03:	5d                   	pop    %ebp
  101a04:	c3                   	ret    

00101a05 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a05:	55                   	push   %ebp
  101a06:	89 e5                	mov    %esp,%ebp
  101a08:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a12:	c7 04 24 d3 39 10 00 	movl   $0x1039d3,(%esp)
  101a19:	e8 04 e9 ff ff       	call   100322 <cprintf>
    print_regs(&tf->tf_regs);
  101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a21:	89 04 24             	mov    %eax,(%esp)
  101a24:	e8 a1 01 00 00       	call   101bca <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a29:	8b 45 08             	mov    0x8(%ebp),%eax
  101a2c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a30:	0f b7 c0             	movzwl %ax,%eax
  101a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a37:	c7 04 24 e4 39 10 00 	movl   $0x1039e4,(%esp)
  101a3e:	e8 df e8 ff ff       	call   100322 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a43:	8b 45 08             	mov    0x8(%ebp),%eax
  101a46:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a4a:	0f b7 c0             	movzwl %ax,%eax
  101a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a51:	c7 04 24 f7 39 10 00 	movl   $0x1039f7,(%esp)
  101a58:	e8 c5 e8 ff ff       	call   100322 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a60:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a64:	0f b7 c0             	movzwl %ax,%eax
  101a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a6b:	c7 04 24 0a 3a 10 00 	movl   $0x103a0a,(%esp)
  101a72:	e8 ab e8 ff ff       	call   100322 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a77:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7a:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a7e:	0f b7 c0             	movzwl %ax,%eax
  101a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a85:	c7 04 24 1d 3a 10 00 	movl   $0x103a1d,(%esp)
  101a8c:	e8 91 e8 ff ff       	call   100322 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a91:	8b 45 08             	mov    0x8(%ebp),%eax
  101a94:	8b 40 30             	mov    0x30(%eax),%eax
  101a97:	89 04 24             	mov    %eax,(%esp)
  101a9a:	e8 1f ff ff ff       	call   1019be <trapname>
  101a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  101aa2:	8b 52 30             	mov    0x30(%edx),%edx
  101aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  101aa9:	89 54 24 04          	mov    %edx,0x4(%esp)
  101aad:	c7 04 24 30 3a 10 00 	movl   $0x103a30,(%esp)
  101ab4:	e8 69 e8 ff ff       	call   100322 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  101abc:	8b 40 34             	mov    0x34(%eax),%eax
  101abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac3:	c7 04 24 42 3a 10 00 	movl   $0x103a42,(%esp)
  101aca:	e8 53 e8 ff ff       	call   100322 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101acf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad2:	8b 40 38             	mov    0x38(%eax),%eax
  101ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad9:	c7 04 24 51 3a 10 00 	movl   $0x103a51,(%esp)
  101ae0:	e8 3d e8 ff ff       	call   100322 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aec:	0f b7 c0             	movzwl %ax,%eax
  101aef:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af3:	c7 04 24 60 3a 10 00 	movl   $0x103a60,(%esp)
  101afa:	e8 23 e8 ff ff       	call   100322 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101aff:	8b 45 08             	mov    0x8(%ebp),%eax
  101b02:	8b 40 40             	mov    0x40(%eax),%eax
  101b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b09:	c7 04 24 73 3a 10 00 	movl   $0x103a73,(%esp)
  101b10:	e8 0d e8 ff ff       	call   100322 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b1c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b23:	eb 3e                	jmp    101b63 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b25:	8b 45 08             	mov    0x8(%ebp),%eax
  101b28:	8b 50 40             	mov    0x40(%eax),%edx
  101b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b2e:	21 d0                	and    %edx,%eax
  101b30:	85 c0                	test   %eax,%eax
  101b32:	74 28                	je     101b5c <print_trapframe+0x157>
  101b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b37:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b3e:	85 c0                	test   %eax,%eax
  101b40:	74 1a                	je     101b5c <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b45:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b50:	c7 04 24 82 3a 10 00 	movl   $0x103a82,(%esp)
  101b57:	e8 c6 e7 ff ff       	call   100322 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b60:	d1 65 f0             	shll   -0x10(%ebp)
  101b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b66:	83 f8 17             	cmp    $0x17,%eax
  101b69:	76 ba                	jbe    101b25 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6e:	8b 40 40             	mov    0x40(%eax),%eax
  101b71:	25 00 30 00 00       	and    $0x3000,%eax
  101b76:	c1 e8 0c             	shr    $0xc,%eax
  101b79:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7d:	c7 04 24 86 3a 10 00 	movl   $0x103a86,(%esp)
  101b84:	e8 99 e7 ff ff       	call   100322 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b89:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8c:	89 04 24             	mov    %eax,(%esp)
  101b8f:	e8 5b fe ff ff       	call   1019ef <trap_in_kernel>
  101b94:	85 c0                	test   %eax,%eax
  101b96:	75 30                	jne    101bc8 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b98:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9b:	8b 40 44             	mov    0x44(%eax),%eax
  101b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba2:	c7 04 24 8f 3a 10 00 	movl   $0x103a8f,(%esp)
  101ba9:	e8 74 e7 ff ff       	call   100322 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bae:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb1:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bb5:	0f b7 c0             	movzwl %ax,%eax
  101bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bbc:	c7 04 24 9e 3a 10 00 	movl   $0x103a9e,(%esp)
  101bc3:	e8 5a e7 ff ff       	call   100322 <cprintf>
    }
}
  101bc8:	c9                   	leave  
  101bc9:	c3                   	ret    

00101bca <print_regs>:

void
print_regs(struct pushregs *regs) {
  101bca:	55                   	push   %ebp
  101bcb:	89 e5                	mov    %esp,%ebp
  101bcd:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd3:	8b 00                	mov    (%eax),%eax
  101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd9:	c7 04 24 b1 3a 10 00 	movl   $0x103ab1,(%esp)
  101be0:	e8 3d e7 ff ff       	call   100322 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101be5:	8b 45 08             	mov    0x8(%ebp),%eax
  101be8:	8b 40 04             	mov    0x4(%eax),%eax
  101beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bef:	c7 04 24 c0 3a 10 00 	movl   $0x103ac0,(%esp)
  101bf6:	e8 27 e7 ff ff       	call   100322 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfe:	8b 40 08             	mov    0x8(%eax),%eax
  101c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c05:	c7 04 24 cf 3a 10 00 	movl   $0x103acf,(%esp)
  101c0c:	e8 11 e7 ff ff       	call   100322 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c11:	8b 45 08             	mov    0x8(%ebp),%eax
  101c14:	8b 40 0c             	mov    0xc(%eax),%eax
  101c17:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1b:	c7 04 24 de 3a 10 00 	movl   $0x103ade,(%esp)
  101c22:	e8 fb e6 ff ff       	call   100322 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c27:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2a:	8b 40 10             	mov    0x10(%eax),%eax
  101c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c31:	c7 04 24 ed 3a 10 00 	movl   $0x103aed,(%esp)
  101c38:	e8 e5 e6 ff ff       	call   100322 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c40:	8b 40 14             	mov    0x14(%eax),%eax
  101c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c47:	c7 04 24 fc 3a 10 00 	movl   $0x103afc,(%esp)
  101c4e:	e8 cf e6 ff ff       	call   100322 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c53:	8b 45 08             	mov    0x8(%ebp),%eax
  101c56:	8b 40 18             	mov    0x18(%eax),%eax
  101c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5d:	c7 04 24 0b 3b 10 00 	movl   $0x103b0b,(%esp)
  101c64:	e8 b9 e6 ff ff       	call   100322 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c69:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6c:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c73:	c7 04 24 1a 3b 10 00 	movl   $0x103b1a,(%esp)
  101c7a:	e8 a3 e6 ff ff       	call   100322 <cprintf>
}
  101c7f:	c9                   	leave  
  101c80:	c3                   	ret    

00101c81 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c81:	55                   	push   %ebp
  101c82:	89 e5                	mov    %esp,%ebp
  101c84:	57                   	push   %edi
  101c85:	56                   	push   %esi
  101c86:	53                   	push   %ebx
  101c87:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
  101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8d:	8b 40 30             	mov    0x30(%eax),%eax
  101c90:	83 f8 2f             	cmp    $0x2f,%eax
  101c93:	77 21                	ja     101cb6 <trap_dispatch+0x35>
  101c95:	83 f8 2e             	cmp    $0x2e,%eax
  101c98:	0f 83 ec 01 00 00    	jae    101e8a <trap_dispatch+0x209>
  101c9e:	83 f8 21             	cmp    $0x21,%eax
  101ca1:	0f 84 8a 00 00 00    	je     101d31 <trap_dispatch+0xb0>
  101ca7:	83 f8 24             	cmp    $0x24,%eax
  101caa:	74 5c                	je     101d08 <trap_dispatch+0x87>
  101cac:	83 f8 20             	cmp    $0x20,%eax
  101caf:	74 1c                	je     101ccd <trap_dispatch+0x4c>
  101cb1:	e9 9c 01 00 00       	jmp    101e52 <trap_dispatch+0x1d1>
  101cb6:	83 f8 78             	cmp    $0x78,%eax
  101cb9:	0f 84 9b 00 00 00    	je     101d5a <trap_dispatch+0xd9>
  101cbf:	83 f8 79             	cmp    $0x79,%eax
  101cc2:	0f 84 11 01 00 00    	je     101dd9 <trap_dispatch+0x158>
  101cc8:	e9 85 01 00 00       	jmp    101e52 <trap_dispatch+0x1d1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks++;
  101ccd:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101cd2:	83 c0 01             	add    $0x1,%eax
  101cd5:	a3 08 f9 10 00       	mov    %eax,0x10f908
	if(ticks % TICK_NUM == 0){
  101cda:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101ce0:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101ce5:	89 c8                	mov    %ecx,%eax
  101ce7:	f7 e2                	mul    %edx
  101ce9:	89 d0                	mov    %edx,%eax
  101ceb:	c1 e8 05             	shr    $0x5,%eax
  101cee:	6b c0 64             	imul   $0x64,%eax,%eax
  101cf1:	29 c1                	sub    %eax,%ecx
  101cf3:	89 c8                	mov    %ecx,%eax
  101cf5:	85 c0                	test   %eax,%eax
  101cf7:	75 0a                	jne    101d03 <trap_dispatch+0x82>
		print_ticks();	
  101cf9:	e8 10 fb ff ff       	call   10180e <print_ticks>
	}
        break;
  101cfe:	e9 88 01 00 00       	jmp    101e8b <trap_dispatch+0x20a>
  101d03:	e9 83 01 00 00       	jmp    101e8b <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d08:	e8 d8 f8 ff ff       	call   1015e5 <cons_getc>
  101d0d:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d10:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d14:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d18:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d20:	c7 04 24 29 3b 10 00 	movl   $0x103b29,(%esp)
  101d27:	e8 f6 e5 ff ff       	call   100322 <cprintf>
        break;
  101d2c:	e9 5a 01 00 00       	jmp    101e8b <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d31:	e8 af f8 ff ff       	call   1015e5 <cons_getc>
  101d36:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d39:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d3d:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d41:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d49:	c7 04 24 3b 3b 10 00 	movl   $0x103b3b,(%esp)
  101d50:	e8 cd e5 ff ff       	call   100322 <cprintf>
        break;
  101d55:	e9 31 01 00 00       	jmp    101e8b <trap_dispatch+0x20a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
	if (tf->tf_cs != USER_CS) {
  101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d5d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d61:	66 83 f8 1b          	cmp    $0x1b,%ax
  101d65:	74 6d                	je     101dd4 <trap_dispatch+0x153>
            switchk2u = *tf;
  101d67:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6a:	ba 20 f9 10 00       	mov    $0x10f920,%edx
  101d6f:	89 c3                	mov    %eax,%ebx
  101d71:	b8 13 00 00 00       	mov    $0x13,%eax
  101d76:	89 d7                	mov    %edx,%edi
  101d78:	89 de                	mov    %ebx,%esi
  101d7a:	89 c1                	mov    %eax,%ecx
  101d7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101d7e:	66 c7 05 5c f9 10 00 	movw   $0x1b,0x10f95c
  101d85:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101d87:	66 c7 05 68 f9 10 00 	movw   $0x23,0x10f968
  101d8e:	23 00 
  101d90:	0f b7 05 68 f9 10 00 	movzwl 0x10f968,%eax
  101d97:	66 a3 48 f9 10 00    	mov    %ax,0x10f948
  101d9d:	0f b7 05 48 f9 10 00 	movzwl 0x10f948,%eax
  101da4:	66 a3 4c f9 10 00    	mov    %ax,0x10f94c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101daa:	8b 45 08             	mov    0x8(%ebp),%eax
  101dad:	83 c0 44             	add    $0x44,%eax
  101db0:	a3 64 f9 10 00       	mov    %eax,0x10f964
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101db5:	a1 60 f9 10 00       	mov    0x10f960,%eax
  101dba:	80 cc 30             	or     $0x30,%ah
  101dbd:	a3 60 f9 10 00       	mov    %eax,0x10f960
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc5:	8d 50 fc             	lea    -0x4(%eax),%edx
  101dc8:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  101dcd:	89 02                	mov    %eax,(%edx)
        }
        break;
  101dcf:	e9 b7 00 00 00       	jmp    101e8b <trap_dispatch+0x20a>
  101dd4:	e9 b2 00 00 00       	jmp    101e8b <trap_dispatch+0x20a>
	tf->tf_ds = USER_DS;
	tf->tf_es = USER_DS;
	tf->tf_ss = USER_DS;
	break;*/
    case T_SWITCH_TOK:
	if (tf->tf_cs != KERNEL_CS) {
  101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101ddc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101de0:	66 83 f8 08          	cmp    $0x8,%ax
  101de4:	74 6a                	je     101e50 <trap_dispatch+0x1cf>
            tf->tf_cs = KERNEL_CS;
  101de6:	8b 45 08             	mov    0x8(%ebp),%eax
  101de9:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101def:	8b 45 08             	mov    0x8(%ebp),%eax
  101df2:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101df8:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfb:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101dff:	8b 45 08             	mov    0x8(%ebp),%eax
  101e02:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101e06:	8b 45 08             	mov    0x8(%ebp),%eax
  101e09:	8b 40 40             	mov    0x40(%eax),%eax
  101e0c:	80 e4 cf             	and    $0xcf,%ah
  101e0f:	89 c2                	mov    %eax,%edx
  101e11:	8b 45 08             	mov    0x8(%ebp),%eax
  101e14:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101e17:	8b 45 08             	mov    0x8(%ebp),%eax
  101e1a:	8b 40 44             	mov    0x44(%eax),%eax
  101e1d:	83 e8 44             	sub    $0x44,%eax
  101e20:	a3 6c f9 10 00       	mov    %eax,0x10f96c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101e25:	a1 6c f9 10 00       	mov    0x10f96c,%eax
  101e2a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101e31:	00 
  101e32:	8b 55 08             	mov    0x8(%ebp),%edx
  101e35:	89 54 24 04          	mov    %edx,0x4(%esp)
  101e39:	89 04 24             	mov    %eax,(%esp)
  101e3c:	e8 27 16 00 00       	call   103468 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101e41:	8b 45 08             	mov    0x8(%ebp),%eax
  101e44:	8d 50 fc             	lea    -0x4(%eax),%edx
  101e47:	a1 6c f9 10 00       	mov    0x10f96c,%eax
  101e4c:	89 02                	mov    %eax,(%edx)
        }
        break;
  101e4e:	eb 3b                	jmp    101e8b <trap_dispatch+0x20a>
  101e50:	eb 39                	jmp    101e8b <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e52:	8b 45 08             	mov    0x8(%ebp),%eax
  101e55:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e59:	0f b7 c0             	movzwl %ax,%eax
  101e5c:	83 e0 03             	and    $0x3,%eax
  101e5f:	85 c0                	test   %eax,%eax
  101e61:	75 28                	jne    101e8b <trap_dispatch+0x20a>
            print_trapframe(tf);
  101e63:	8b 45 08             	mov    0x8(%ebp),%eax
  101e66:	89 04 24             	mov    %eax,(%esp)
  101e69:	e8 97 fb ff ff       	call   101a05 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e6e:	c7 44 24 08 4a 3b 10 	movl   $0x103b4a,0x8(%esp)
  101e75:	00 
  101e76:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  101e7d:	00 
  101e7e:	c7 04 24 6e 39 10 00 	movl   $0x10396e,(%esp)
  101e85:	e8 2c ee ff ff       	call   100cb6 <__panic>
	tf->tf_es = KERNEL_DS;
        break;*/
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101e8a:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101e8b:	83 c4 2c             	add    $0x2c,%esp
  101e8e:	5b                   	pop    %ebx
  101e8f:	5e                   	pop    %esi
  101e90:	5f                   	pop    %edi
  101e91:	5d                   	pop    %ebp
  101e92:	c3                   	ret    

00101e93 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e93:	55                   	push   %ebp
  101e94:	89 e5                	mov    %esp,%ebp
  101e96:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e99:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9c:	89 04 24             	mov    %eax,(%esp)
  101e9f:	e8 dd fd ff ff       	call   101c81 <trap_dispatch>
}
  101ea4:	c9                   	leave  
  101ea5:	c3                   	ret    

00101ea6 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101ea6:	1e                   	push   %ds
    pushl %es
  101ea7:	06                   	push   %es
    pushl %fs
  101ea8:	0f a0                	push   %fs
    pushl %gs
  101eaa:	0f a8                	push   %gs
    pushal
  101eac:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101ead:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101eb2:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101eb4:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101eb6:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101eb7:	e8 d7 ff ff ff       	call   101e93 <trap>

    # pop the pushed stack pointer
    popl %esp
  101ebc:	5c                   	pop    %esp

00101ebd <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101ebd:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101ebe:	0f a9                	pop    %gs
    popl %fs
  101ec0:	0f a1                	pop    %fs
    popl %es
  101ec2:	07                   	pop    %es
    popl %ds
  101ec3:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101ec4:	83 c4 08             	add    $0x8,%esp
    iret
  101ec7:	cf                   	iret   

00101ec8 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101ec8:	6a 00                	push   $0x0
  pushl $0
  101eca:	6a 00                	push   $0x0
  jmp __alltraps
  101ecc:	e9 d5 ff ff ff       	jmp    101ea6 <__alltraps>

00101ed1 <vector1>:
.globl vector1
vector1:
  pushl $0
  101ed1:	6a 00                	push   $0x0
  pushl $1
  101ed3:	6a 01                	push   $0x1
  jmp __alltraps
  101ed5:	e9 cc ff ff ff       	jmp    101ea6 <__alltraps>

00101eda <vector2>:
.globl vector2
vector2:
  pushl $0
  101eda:	6a 00                	push   $0x0
  pushl $2
  101edc:	6a 02                	push   $0x2
  jmp __alltraps
  101ede:	e9 c3 ff ff ff       	jmp    101ea6 <__alltraps>

00101ee3 <vector3>:
.globl vector3
vector3:
  pushl $0
  101ee3:	6a 00                	push   $0x0
  pushl $3
  101ee5:	6a 03                	push   $0x3
  jmp __alltraps
  101ee7:	e9 ba ff ff ff       	jmp    101ea6 <__alltraps>

00101eec <vector4>:
.globl vector4
vector4:
  pushl $0
  101eec:	6a 00                	push   $0x0
  pushl $4
  101eee:	6a 04                	push   $0x4
  jmp __alltraps
  101ef0:	e9 b1 ff ff ff       	jmp    101ea6 <__alltraps>

00101ef5 <vector5>:
.globl vector5
vector5:
  pushl $0
  101ef5:	6a 00                	push   $0x0
  pushl $5
  101ef7:	6a 05                	push   $0x5
  jmp __alltraps
  101ef9:	e9 a8 ff ff ff       	jmp    101ea6 <__alltraps>

00101efe <vector6>:
.globl vector6
vector6:
  pushl $0
  101efe:	6a 00                	push   $0x0
  pushl $6
  101f00:	6a 06                	push   $0x6
  jmp __alltraps
  101f02:	e9 9f ff ff ff       	jmp    101ea6 <__alltraps>

00101f07 <vector7>:
.globl vector7
vector7:
  pushl $0
  101f07:	6a 00                	push   $0x0
  pushl $7
  101f09:	6a 07                	push   $0x7
  jmp __alltraps
  101f0b:	e9 96 ff ff ff       	jmp    101ea6 <__alltraps>

00101f10 <vector8>:
.globl vector8
vector8:
  pushl $8
  101f10:	6a 08                	push   $0x8
  jmp __alltraps
  101f12:	e9 8f ff ff ff       	jmp    101ea6 <__alltraps>

00101f17 <vector9>:
.globl vector9
vector9:
  pushl $0
  101f17:	6a 00                	push   $0x0
  pushl $9
  101f19:	6a 09                	push   $0x9
  jmp __alltraps
  101f1b:	e9 86 ff ff ff       	jmp    101ea6 <__alltraps>

00101f20 <vector10>:
.globl vector10
vector10:
  pushl $10
  101f20:	6a 0a                	push   $0xa
  jmp __alltraps
  101f22:	e9 7f ff ff ff       	jmp    101ea6 <__alltraps>

00101f27 <vector11>:
.globl vector11
vector11:
  pushl $11
  101f27:	6a 0b                	push   $0xb
  jmp __alltraps
  101f29:	e9 78 ff ff ff       	jmp    101ea6 <__alltraps>

00101f2e <vector12>:
.globl vector12
vector12:
  pushl $12
  101f2e:	6a 0c                	push   $0xc
  jmp __alltraps
  101f30:	e9 71 ff ff ff       	jmp    101ea6 <__alltraps>

00101f35 <vector13>:
.globl vector13
vector13:
  pushl $13
  101f35:	6a 0d                	push   $0xd
  jmp __alltraps
  101f37:	e9 6a ff ff ff       	jmp    101ea6 <__alltraps>

00101f3c <vector14>:
.globl vector14
vector14:
  pushl $14
  101f3c:	6a 0e                	push   $0xe
  jmp __alltraps
  101f3e:	e9 63 ff ff ff       	jmp    101ea6 <__alltraps>

00101f43 <vector15>:
.globl vector15
vector15:
  pushl $0
  101f43:	6a 00                	push   $0x0
  pushl $15
  101f45:	6a 0f                	push   $0xf
  jmp __alltraps
  101f47:	e9 5a ff ff ff       	jmp    101ea6 <__alltraps>

00101f4c <vector16>:
.globl vector16
vector16:
  pushl $0
  101f4c:	6a 00                	push   $0x0
  pushl $16
  101f4e:	6a 10                	push   $0x10
  jmp __alltraps
  101f50:	e9 51 ff ff ff       	jmp    101ea6 <__alltraps>

00101f55 <vector17>:
.globl vector17
vector17:
  pushl $17
  101f55:	6a 11                	push   $0x11
  jmp __alltraps
  101f57:	e9 4a ff ff ff       	jmp    101ea6 <__alltraps>

00101f5c <vector18>:
.globl vector18
vector18:
  pushl $0
  101f5c:	6a 00                	push   $0x0
  pushl $18
  101f5e:	6a 12                	push   $0x12
  jmp __alltraps
  101f60:	e9 41 ff ff ff       	jmp    101ea6 <__alltraps>

00101f65 <vector19>:
.globl vector19
vector19:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $19
  101f67:	6a 13                	push   $0x13
  jmp __alltraps
  101f69:	e9 38 ff ff ff       	jmp    101ea6 <__alltraps>

00101f6e <vector20>:
.globl vector20
vector20:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $20
  101f70:	6a 14                	push   $0x14
  jmp __alltraps
  101f72:	e9 2f ff ff ff       	jmp    101ea6 <__alltraps>

00101f77 <vector21>:
.globl vector21
vector21:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $21
  101f79:	6a 15                	push   $0x15
  jmp __alltraps
  101f7b:	e9 26 ff ff ff       	jmp    101ea6 <__alltraps>

00101f80 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f80:	6a 00                	push   $0x0
  pushl $22
  101f82:	6a 16                	push   $0x16
  jmp __alltraps
  101f84:	e9 1d ff ff ff       	jmp    101ea6 <__alltraps>

00101f89 <vector23>:
.globl vector23
vector23:
  pushl $0
  101f89:	6a 00                	push   $0x0
  pushl $23
  101f8b:	6a 17                	push   $0x17
  jmp __alltraps
  101f8d:	e9 14 ff ff ff       	jmp    101ea6 <__alltraps>

00101f92 <vector24>:
.globl vector24
vector24:
  pushl $0
  101f92:	6a 00                	push   $0x0
  pushl $24
  101f94:	6a 18                	push   $0x18
  jmp __alltraps
  101f96:	e9 0b ff ff ff       	jmp    101ea6 <__alltraps>

00101f9b <vector25>:
.globl vector25
vector25:
  pushl $0
  101f9b:	6a 00                	push   $0x0
  pushl $25
  101f9d:	6a 19                	push   $0x19
  jmp __alltraps
  101f9f:	e9 02 ff ff ff       	jmp    101ea6 <__alltraps>

00101fa4 <vector26>:
.globl vector26
vector26:
  pushl $0
  101fa4:	6a 00                	push   $0x0
  pushl $26
  101fa6:	6a 1a                	push   $0x1a
  jmp __alltraps
  101fa8:	e9 f9 fe ff ff       	jmp    101ea6 <__alltraps>

00101fad <vector27>:
.globl vector27
vector27:
  pushl $0
  101fad:	6a 00                	push   $0x0
  pushl $27
  101faf:	6a 1b                	push   $0x1b
  jmp __alltraps
  101fb1:	e9 f0 fe ff ff       	jmp    101ea6 <__alltraps>

00101fb6 <vector28>:
.globl vector28
vector28:
  pushl $0
  101fb6:	6a 00                	push   $0x0
  pushl $28
  101fb8:	6a 1c                	push   $0x1c
  jmp __alltraps
  101fba:	e9 e7 fe ff ff       	jmp    101ea6 <__alltraps>

00101fbf <vector29>:
.globl vector29
vector29:
  pushl $0
  101fbf:	6a 00                	push   $0x0
  pushl $29
  101fc1:	6a 1d                	push   $0x1d
  jmp __alltraps
  101fc3:	e9 de fe ff ff       	jmp    101ea6 <__alltraps>

00101fc8 <vector30>:
.globl vector30
vector30:
  pushl $0
  101fc8:	6a 00                	push   $0x0
  pushl $30
  101fca:	6a 1e                	push   $0x1e
  jmp __alltraps
  101fcc:	e9 d5 fe ff ff       	jmp    101ea6 <__alltraps>

00101fd1 <vector31>:
.globl vector31
vector31:
  pushl $0
  101fd1:	6a 00                	push   $0x0
  pushl $31
  101fd3:	6a 1f                	push   $0x1f
  jmp __alltraps
  101fd5:	e9 cc fe ff ff       	jmp    101ea6 <__alltraps>

00101fda <vector32>:
.globl vector32
vector32:
  pushl $0
  101fda:	6a 00                	push   $0x0
  pushl $32
  101fdc:	6a 20                	push   $0x20
  jmp __alltraps
  101fde:	e9 c3 fe ff ff       	jmp    101ea6 <__alltraps>

00101fe3 <vector33>:
.globl vector33
vector33:
  pushl $0
  101fe3:	6a 00                	push   $0x0
  pushl $33
  101fe5:	6a 21                	push   $0x21
  jmp __alltraps
  101fe7:	e9 ba fe ff ff       	jmp    101ea6 <__alltraps>

00101fec <vector34>:
.globl vector34
vector34:
  pushl $0
  101fec:	6a 00                	push   $0x0
  pushl $34
  101fee:	6a 22                	push   $0x22
  jmp __alltraps
  101ff0:	e9 b1 fe ff ff       	jmp    101ea6 <__alltraps>

00101ff5 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ff5:	6a 00                	push   $0x0
  pushl $35
  101ff7:	6a 23                	push   $0x23
  jmp __alltraps
  101ff9:	e9 a8 fe ff ff       	jmp    101ea6 <__alltraps>

00101ffe <vector36>:
.globl vector36
vector36:
  pushl $0
  101ffe:	6a 00                	push   $0x0
  pushl $36
  102000:	6a 24                	push   $0x24
  jmp __alltraps
  102002:	e9 9f fe ff ff       	jmp    101ea6 <__alltraps>

00102007 <vector37>:
.globl vector37
vector37:
  pushl $0
  102007:	6a 00                	push   $0x0
  pushl $37
  102009:	6a 25                	push   $0x25
  jmp __alltraps
  10200b:	e9 96 fe ff ff       	jmp    101ea6 <__alltraps>

00102010 <vector38>:
.globl vector38
vector38:
  pushl $0
  102010:	6a 00                	push   $0x0
  pushl $38
  102012:	6a 26                	push   $0x26
  jmp __alltraps
  102014:	e9 8d fe ff ff       	jmp    101ea6 <__alltraps>

00102019 <vector39>:
.globl vector39
vector39:
  pushl $0
  102019:	6a 00                	push   $0x0
  pushl $39
  10201b:	6a 27                	push   $0x27
  jmp __alltraps
  10201d:	e9 84 fe ff ff       	jmp    101ea6 <__alltraps>

00102022 <vector40>:
.globl vector40
vector40:
  pushl $0
  102022:	6a 00                	push   $0x0
  pushl $40
  102024:	6a 28                	push   $0x28
  jmp __alltraps
  102026:	e9 7b fe ff ff       	jmp    101ea6 <__alltraps>

0010202b <vector41>:
.globl vector41
vector41:
  pushl $0
  10202b:	6a 00                	push   $0x0
  pushl $41
  10202d:	6a 29                	push   $0x29
  jmp __alltraps
  10202f:	e9 72 fe ff ff       	jmp    101ea6 <__alltraps>

00102034 <vector42>:
.globl vector42
vector42:
  pushl $0
  102034:	6a 00                	push   $0x0
  pushl $42
  102036:	6a 2a                	push   $0x2a
  jmp __alltraps
  102038:	e9 69 fe ff ff       	jmp    101ea6 <__alltraps>

0010203d <vector43>:
.globl vector43
vector43:
  pushl $0
  10203d:	6a 00                	push   $0x0
  pushl $43
  10203f:	6a 2b                	push   $0x2b
  jmp __alltraps
  102041:	e9 60 fe ff ff       	jmp    101ea6 <__alltraps>

00102046 <vector44>:
.globl vector44
vector44:
  pushl $0
  102046:	6a 00                	push   $0x0
  pushl $44
  102048:	6a 2c                	push   $0x2c
  jmp __alltraps
  10204a:	e9 57 fe ff ff       	jmp    101ea6 <__alltraps>

0010204f <vector45>:
.globl vector45
vector45:
  pushl $0
  10204f:	6a 00                	push   $0x0
  pushl $45
  102051:	6a 2d                	push   $0x2d
  jmp __alltraps
  102053:	e9 4e fe ff ff       	jmp    101ea6 <__alltraps>

00102058 <vector46>:
.globl vector46
vector46:
  pushl $0
  102058:	6a 00                	push   $0x0
  pushl $46
  10205a:	6a 2e                	push   $0x2e
  jmp __alltraps
  10205c:	e9 45 fe ff ff       	jmp    101ea6 <__alltraps>

00102061 <vector47>:
.globl vector47
vector47:
  pushl $0
  102061:	6a 00                	push   $0x0
  pushl $47
  102063:	6a 2f                	push   $0x2f
  jmp __alltraps
  102065:	e9 3c fe ff ff       	jmp    101ea6 <__alltraps>

0010206a <vector48>:
.globl vector48
vector48:
  pushl $0
  10206a:	6a 00                	push   $0x0
  pushl $48
  10206c:	6a 30                	push   $0x30
  jmp __alltraps
  10206e:	e9 33 fe ff ff       	jmp    101ea6 <__alltraps>

00102073 <vector49>:
.globl vector49
vector49:
  pushl $0
  102073:	6a 00                	push   $0x0
  pushl $49
  102075:	6a 31                	push   $0x31
  jmp __alltraps
  102077:	e9 2a fe ff ff       	jmp    101ea6 <__alltraps>

0010207c <vector50>:
.globl vector50
vector50:
  pushl $0
  10207c:	6a 00                	push   $0x0
  pushl $50
  10207e:	6a 32                	push   $0x32
  jmp __alltraps
  102080:	e9 21 fe ff ff       	jmp    101ea6 <__alltraps>

00102085 <vector51>:
.globl vector51
vector51:
  pushl $0
  102085:	6a 00                	push   $0x0
  pushl $51
  102087:	6a 33                	push   $0x33
  jmp __alltraps
  102089:	e9 18 fe ff ff       	jmp    101ea6 <__alltraps>

0010208e <vector52>:
.globl vector52
vector52:
  pushl $0
  10208e:	6a 00                	push   $0x0
  pushl $52
  102090:	6a 34                	push   $0x34
  jmp __alltraps
  102092:	e9 0f fe ff ff       	jmp    101ea6 <__alltraps>

00102097 <vector53>:
.globl vector53
vector53:
  pushl $0
  102097:	6a 00                	push   $0x0
  pushl $53
  102099:	6a 35                	push   $0x35
  jmp __alltraps
  10209b:	e9 06 fe ff ff       	jmp    101ea6 <__alltraps>

001020a0 <vector54>:
.globl vector54
vector54:
  pushl $0
  1020a0:	6a 00                	push   $0x0
  pushl $54
  1020a2:	6a 36                	push   $0x36
  jmp __alltraps
  1020a4:	e9 fd fd ff ff       	jmp    101ea6 <__alltraps>

001020a9 <vector55>:
.globl vector55
vector55:
  pushl $0
  1020a9:	6a 00                	push   $0x0
  pushl $55
  1020ab:	6a 37                	push   $0x37
  jmp __alltraps
  1020ad:	e9 f4 fd ff ff       	jmp    101ea6 <__alltraps>

001020b2 <vector56>:
.globl vector56
vector56:
  pushl $0
  1020b2:	6a 00                	push   $0x0
  pushl $56
  1020b4:	6a 38                	push   $0x38
  jmp __alltraps
  1020b6:	e9 eb fd ff ff       	jmp    101ea6 <__alltraps>

001020bb <vector57>:
.globl vector57
vector57:
  pushl $0
  1020bb:	6a 00                	push   $0x0
  pushl $57
  1020bd:	6a 39                	push   $0x39
  jmp __alltraps
  1020bf:	e9 e2 fd ff ff       	jmp    101ea6 <__alltraps>

001020c4 <vector58>:
.globl vector58
vector58:
  pushl $0
  1020c4:	6a 00                	push   $0x0
  pushl $58
  1020c6:	6a 3a                	push   $0x3a
  jmp __alltraps
  1020c8:	e9 d9 fd ff ff       	jmp    101ea6 <__alltraps>

001020cd <vector59>:
.globl vector59
vector59:
  pushl $0
  1020cd:	6a 00                	push   $0x0
  pushl $59
  1020cf:	6a 3b                	push   $0x3b
  jmp __alltraps
  1020d1:	e9 d0 fd ff ff       	jmp    101ea6 <__alltraps>

001020d6 <vector60>:
.globl vector60
vector60:
  pushl $0
  1020d6:	6a 00                	push   $0x0
  pushl $60
  1020d8:	6a 3c                	push   $0x3c
  jmp __alltraps
  1020da:	e9 c7 fd ff ff       	jmp    101ea6 <__alltraps>

001020df <vector61>:
.globl vector61
vector61:
  pushl $0
  1020df:	6a 00                	push   $0x0
  pushl $61
  1020e1:	6a 3d                	push   $0x3d
  jmp __alltraps
  1020e3:	e9 be fd ff ff       	jmp    101ea6 <__alltraps>

001020e8 <vector62>:
.globl vector62
vector62:
  pushl $0
  1020e8:	6a 00                	push   $0x0
  pushl $62
  1020ea:	6a 3e                	push   $0x3e
  jmp __alltraps
  1020ec:	e9 b5 fd ff ff       	jmp    101ea6 <__alltraps>

001020f1 <vector63>:
.globl vector63
vector63:
  pushl $0
  1020f1:	6a 00                	push   $0x0
  pushl $63
  1020f3:	6a 3f                	push   $0x3f
  jmp __alltraps
  1020f5:	e9 ac fd ff ff       	jmp    101ea6 <__alltraps>

001020fa <vector64>:
.globl vector64
vector64:
  pushl $0
  1020fa:	6a 00                	push   $0x0
  pushl $64
  1020fc:	6a 40                	push   $0x40
  jmp __alltraps
  1020fe:	e9 a3 fd ff ff       	jmp    101ea6 <__alltraps>

00102103 <vector65>:
.globl vector65
vector65:
  pushl $0
  102103:	6a 00                	push   $0x0
  pushl $65
  102105:	6a 41                	push   $0x41
  jmp __alltraps
  102107:	e9 9a fd ff ff       	jmp    101ea6 <__alltraps>

0010210c <vector66>:
.globl vector66
vector66:
  pushl $0
  10210c:	6a 00                	push   $0x0
  pushl $66
  10210e:	6a 42                	push   $0x42
  jmp __alltraps
  102110:	e9 91 fd ff ff       	jmp    101ea6 <__alltraps>

00102115 <vector67>:
.globl vector67
vector67:
  pushl $0
  102115:	6a 00                	push   $0x0
  pushl $67
  102117:	6a 43                	push   $0x43
  jmp __alltraps
  102119:	e9 88 fd ff ff       	jmp    101ea6 <__alltraps>

0010211e <vector68>:
.globl vector68
vector68:
  pushl $0
  10211e:	6a 00                	push   $0x0
  pushl $68
  102120:	6a 44                	push   $0x44
  jmp __alltraps
  102122:	e9 7f fd ff ff       	jmp    101ea6 <__alltraps>

00102127 <vector69>:
.globl vector69
vector69:
  pushl $0
  102127:	6a 00                	push   $0x0
  pushl $69
  102129:	6a 45                	push   $0x45
  jmp __alltraps
  10212b:	e9 76 fd ff ff       	jmp    101ea6 <__alltraps>

00102130 <vector70>:
.globl vector70
vector70:
  pushl $0
  102130:	6a 00                	push   $0x0
  pushl $70
  102132:	6a 46                	push   $0x46
  jmp __alltraps
  102134:	e9 6d fd ff ff       	jmp    101ea6 <__alltraps>

00102139 <vector71>:
.globl vector71
vector71:
  pushl $0
  102139:	6a 00                	push   $0x0
  pushl $71
  10213b:	6a 47                	push   $0x47
  jmp __alltraps
  10213d:	e9 64 fd ff ff       	jmp    101ea6 <__alltraps>

00102142 <vector72>:
.globl vector72
vector72:
  pushl $0
  102142:	6a 00                	push   $0x0
  pushl $72
  102144:	6a 48                	push   $0x48
  jmp __alltraps
  102146:	e9 5b fd ff ff       	jmp    101ea6 <__alltraps>

0010214b <vector73>:
.globl vector73
vector73:
  pushl $0
  10214b:	6a 00                	push   $0x0
  pushl $73
  10214d:	6a 49                	push   $0x49
  jmp __alltraps
  10214f:	e9 52 fd ff ff       	jmp    101ea6 <__alltraps>

00102154 <vector74>:
.globl vector74
vector74:
  pushl $0
  102154:	6a 00                	push   $0x0
  pushl $74
  102156:	6a 4a                	push   $0x4a
  jmp __alltraps
  102158:	e9 49 fd ff ff       	jmp    101ea6 <__alltraps>

0010215d <vector75>:
.globl vector75
vector75:
  pushl $0
  10215d:	6a 00                	push   $0x0
  pushl $75
  10215f:	6a 4b                	push   $0x4b
  jmp __alltraps
  102161:	e9 40 fd ff ff       	jmp    101ea6 <__alltraps>

00102166 <vector76>:
.globl vector76
vector76:
  pushl $0
  102166:	6a 00                	push   $0x0
  pushl $76
  102168:	6a 4c                	push   $0x4c
  jmp __alltraps
  10216a:	e9 37 fd ff ff       	jmp    101ea6 <__alltraps>

0010216f <vector77>:
.globl vector77
vector77:
  pushl $0
  10216f:	6a 00                	push   $0x0
  pushl $77
  102171:	6a 4d                	push   $0x4d
  jmp __alltraps
  102173:	e9 2e fd ff ff       	jmp    101ea6 <__alltraps>

00102178 <vector78>:
.globl vector78
vector78:
  pushl $0
  102178:	6a 00                	push   $0x0
  pushl $78
  10217a:	6a 4e                	push   $0x4e
  jmp __alltraps
  10217c:	e9 25 fd ff ff       	jmp    101ea6 <__alltraps>

00102181 <vector79>:
.globl vector79
vector79:
  pushl $0
  102181:	6a 00                	push   $0x0
  pushl $79
  102183:	6a 4f                	push   $0x4f
  jmp __alltraps
  102185:	e9 1c fd ff ff       	jmp    101ea6 <__alltraps>

0010218a <vector80>:
.globl vector80
vector80:
  pushl $0
  10218a:	6a 00                	push   $0x0
  pushl $80
  10218c:	6a 50                	push   $0x50
  jmp __alltraps
  10218e:	e9 13 fd ff ff       	jmp    101ea6 <__alltraps>

00102193 <vector81>:
.globl vector81
vector81:
  pushl $0
  102193:	6a 00                	push   $0x0
  pushl $81
  102195:	6a 51                	push   $0x51
  jmp __alltraps
  102197:	e9 0a fd ff ff       	jmp    101ea6 <__alltraps>

0010219c <vector82>:
.globl vector82
vector82:
  pushl $0
  10219c:	6a 00                	push   $0x0
  pushl $82
  10219e:	6a 52                	push   $0x52
  jmp __alltraps
  1021a0:	e9 01 fd ff ff       	jmp    101ea6 <__alltraps>

001021a5 <vector83>:
.globl vector83
vector83:
  pushl $0
  1021a5:	6a 00                	push   $0x0
  pushl $83
  1021a7:	6a 53                	push   $0x53
  jmp __alltraps
  1021a9:	e9 f8 fc ff ff       	jmp    101ea6 <__alltraps>

001021ae <vector84>:
.globl vector84
vector84:
  pushl $0
  1021ae:	6a 00                	push   $0x0
  pushl $84
  1021b0:	6a 54                	push   $0x54
  jmp __alltraps
  1021b2:	e9 ef fc ff ff       	jmp    101ea6 <__alltraps>

001021b7 <vector85>:
.globl vector85
vector85:
  pushl $0
  1021b7:	6a 00                	push   $0x0
  pushl $85
  1021b9:	6a 55                	push   $0x55
  jmp __alltraps
  1021bb:	e9 e6 fc ff ff       	jmp    101ea6 <__alltraps>

001021c0 <vector86>:
.globl vector86
vector86:
  pushl $0
  1021c0:	6a 00                	push   $0x0
  pushl $86
  1021c2:	6a 56                	push   $0x56
  jmp __alltraps
  1021c4:	e9 dd fc ff ff       	jmp    101ea6 <__alltraps>

001021c9 <vector87>:
.globl vector87
vector87:
  pushl $0
  1021c9:	6a 00                	push   $0x0
  pushl $87
  1021cb:	6a 57                	push   $0x57
  jmp __alltraps
  1021cd:	e9 d4 fc ff ff       	jmp    101ea6 <__alltraps>

001021d2 <vector88>:
.globl vector88
vector88:
  pushl $0
  1021d2:	6a 00                	push   $0x0
  pushl $88
  1021d4:	6a 58                	push   $0x58
  jmp __alltraps
  1021d6:	e9 cb fc ff ff       	jmp    101ea6 <__alltraps>

001021db <vector89>:
.globl vector89
vector89:
  pushl $0
  1021db:	6a 00                	push   $0x0
  pushl $89
  1021dd:	6a 59                	push   $0x59
  jmp __alltraps
  1021df:	e9 c2 fc ff ff       	jmp    101ea6 <__alltraps>

001021e4 <vector90>:
.globl vector90
vector90:
  pushl $0
  1021e4:	6a 00                	push   $0x0
  pushl $90
  1021e6:	6a 5a                	push   $0x5a
  jmp __alltraps
  1021e8:	e9 b9 fc ff ff       	jmp    101ea6 <__alltraps>

001021ed <vector91>:
.globl vector91
vector91:
  pushl $0
  1021ed:	6a 00                	push   $0x0
  pushl $91
  1021ef:	6a 5b                	push   $0x5b
  jmp __alltraps
  1021f1:	e9 b0 fc ff ff       	jmp    101ea6 <__alltraps>

001021f6 <vector92>:
.globl vector92
vector92:
  pushl $0
  1021f6:	6a 00                	push   $0x0
  pushl $92
  1021f8:	6a 5c                	push   $0x5c
  jmp __alltraps
  1021fa:	e9 a7 fc ff ff       	jmp    101ea6 <__alltraps>

001021ff <vector93>:
.globl vector93
vector93:
  pushl $0
  1021ff:	6a 00                	push   $0x0
  pushl $93
  102201:	6a 5d                	push   $0x5d
  jmp __alltraps
  102203:	e9 9e fc ff ff       	jmp    101ea6 <__alltraps>

00102208 <vector94>:
.globl vector94
vector94:
  pushl $0
  102208:	6a 00                	push   $0x0
  pushl $94
  10220a:	6a 5e                	push   $0x5e
  jmp __alltraps
  10220c:	e9 95 fc ff ff       	jmp    101ea6 <__alltraps>

00102211 <vector95>:
.globl vector95
vector95:
  pushl $0
  102211:	6a 00                	push   $0x0
  pushl $95
  102213:	6a 5f                	push   $0x5f
  jmp __alltraps
  102215:	e9 8c fc ff ff       	jmp    101ea6 <__alltraps>

0010221a <vector96>:
.globl vector96
vector96:
  pushl $0
  10221a:	6a 00                	push   $0x0
  pushl $96
  10221c:	6a 60                	push   $0x60
  jmp __alltraps
  10221e:	e9 83 fc ff ff       	jmp    101ea6 <__alltraps>

00102223 <vector97>:
.globl vector97
vector97:
  pushl $0
  102223:	6a 00                	push   $0x0
  pushl $97
  102225:	6a 61                	push   $0x61
  jmp __alltraps
  102227:	e9 7a fc ff ff       	jmp    101ea6 <__alltraps>

0010222c <vector98>:
.globl vector98
vector98:
  pushl $0
  10222c:	6a 00                	push   $0x0
  pushl $98
  10222e:	6a 62                	push   $0x62
  jmp __alltraps
  102230:	e9 71 fc ff ff       	jmp    101ea6 <__alltraps>

00102235 <vector99>:
.globl vector99
vector99:
  pushl $0
  102235:	6a 00                	push   $0x0
  pushl $99
  102237:	6a 63                	push   $0x63
  jmp __alltraps
  102239:	e9 68 fc ff ff       	jmp    101ea6 <__alltraps>

0010223e <vector100>:
.globl vector100
vector100:
  pushl $0
  10223e:	6a 00                	push   $0x0
  pushl $100
  102240:	6a 64                	push   $0x64
  jmp __alltraps
  102242:	e9 5f fc ff ff       	jmp    101ea6 <__alltraps>

00102247 <vector101>:
.globl vector101
vector101:
  pushl $0
  102247:	6a 00                	push   $0x0
  pushl $101
  102249:	6a 65                	push   $0x65
  jmp __alltraps
  10224b:	e9 56 fc ff ff       	jmp    101ea6 <__alltraps>

00102250 <vector102>:
.globl vector102
vector102:
  pushl $0
  102250:	6a 00                	push   $0x0
  pushl $102
  102252:	6a 66                	push   $0x66
  jmp __alltraps
  102254:	e9 4d fc ff ff       	jmp    101ea6 <__alltraps>

00102259 <vector103>:
.globl vector103
vector103:
  pushl $0
  102259:	6a 00                	push   $0x0
  pushl $103
  10225b:	6a 67                	push   $0x67
  jmp __alltraps
  10225d:	e9 44 fc ff ff       	jmp    101ea6 <__alltraps>

00102262 <vector104>:
.globl vector104
vector104:
  pushl $0
  102262:	6a 00                	push   $0x0
  pushl $104
  102264:	6a 68                	push   $0x68
  jmp __alltraps
  102266:	e9 3b fc ff ff       	jmp    101ea6 <__alltraps>

0010226b <vector105>:
.globl vector105
vector105:
  pushl $0
  10226b:	6a 00                	push   $0x0
  pushl $105
  10226d:	6a 69                	push   $0x69
  jmp __alltraps
  10226f:	e9 32 fc ff ff       	jmp    101ea6 <__alltraps>

00102274 <vector106>:
.globl vector106
vector106:
  pushl $0
  102274:	6a 00                	push   $0x0
  pushl $106
  102276:	6a 6a                	push   $0x6a
  jmp __alltraps
  102278:	e9 29 fc ff ff       	jmp    101ea6 <__alltraps>

0010227d <vector107>:
.globl vector107
vector107:
  pushl $0
  10227d:	6a 00                	push   $0x0
  pushl $107
  10227f:	6a 6b                	push   $0x6b
  jmp __alltraps
  102281:	e9 20 fc ff ff       	jmp    101ea6 <__alltraps>

00102286 <vector108>:
.globl vector108
vector108:
  pushl $0
  102286:	6a 00                	push   $0x0
  pushl $108
  102288:	6a 6c                	push   $0x6c
  jmp __alltraps
  10228a:	e9 17 fc ff ff       	jmp    101ea6 <__alltraps>

0010228f <vector109>:
.globl vector109
vector109:
  pushl $0
  10228f:	6a 00                	push   $0x0
  pushl $109
  102291:	6a 6d                	push   $0x6d
  jmp __alltraps
  102293:	e9 0e fc ff ff       	jmp    101ea6 <__alltraps>

00102298 <vector110>:
.globl vector110
vector110:
  pushl $0
  102298:	6a 00                	push   $0x0
  pushl $110
  10229a:	6a 6e                	push   $0x6e
  jmp __alltraps
  10229c:	e9 05 fc ff ff       	jmp    101ea6 <__alltraps>

001022a1 <vector111>:
.globl vector111
vector111:
  pushl $0
  1022a1:	6a 00                	push   $0x0
  pushl $111
  1022a3:	6a 6f                	push   $0x6f
  jmp __alltraps
  1022a5:	e9 fc fb ff ff       	jmp    101ea6 <__alltraps>

001022aa <vector112>:
.globl vector112
vector112:
  pushl $0
  1022aa:	6a 00                	push   $0x0
  pushl $112
  1022ac:	6a 70                	push   $0x70
  jmp __alltraps
  1022ae:	e9 f3 fb ff ff       	jmp    101ea6 <__alltraps>

001022b3 <vector113>:
.globl vector113
vector113:
  pushl $0
  1022b3:	6a 00                	push   $0x0
  pushl $113
  1022b5:	6a 71                	push   $0x71
  jmp __alltraps
  1022b7:	e9 ea fb ff ff       	jmp    101ea6 <__alltraps>

001022bc <vector114>:
.globl vector114
vector114:
  pushl $0
  1022bc:	6a 00                	push   $0x0
  pushl $114
  1022be:	6a 72                	push   $0x72
  jmp __alltraps
  1022c0:	e9 e1 fb ff ff       	jmp    101ea6 <__alltraps>

001022c5 <vector115>:
.globl vector115
vector115:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $115
  1022c7:	6a 73                	push   $0x73
  jmp __alltraps
  1022c9:	e9 d8 fb ff ff       	jmp    101ea6 <__alltraps>

001022ce <vector116>:
.globl vector116
vector116:
  pushl $0
  1022ce:	6a 00                	push   $0x0
  pushl $116
  1022d0:	6a 74                	push   $0x74
  jmp __alltraps
  1022d2:	e9 cf fb ff ff       	jmp    101ea6 <__alltraps>

001022d7 <vector117>:
.globl vector117
vector117:
  pushl $0
  1022d7:	6a 00                	push   $0x0
  pushl $117
  1022d9:	6a 75                	push   $0x75
  jmp __alltraps
  1022db:	e9 c6 fb ff ff       	jmp    101ea6 <__alltraps>

001022e0 <vector118>:
.globl vector118
vector118:
  pushl $0
  1022e0:	6a 00                	push   $0x0
  pushl $118
  1022e2:	6a 76                	push   $0x76
  jmp __alltraps
  1022e4:	e9 bd fb ff ff       	jmp    101ea6 <__alltraps>

001022e9 <vector119>:
.globl vector119
vector119:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $119
  1022eb:	6a 77                	push   $0x77
  jmp __alltraps
  1022ed:	e9 b4 fb ff ff       	jmp    101ea6 <__alltraps>

001022f2 <vector120>:
.globl vector120
vector120:
  pushl $0
  1022f2:	6a 00                	push   $0x0
  pushl $120
  1022f4:	6a 78                	push   $0x78
  jmp __alltraps
  1022f6:	e9 ab fb ff ff       	jmp    101ea6 <__alltraps>

001022fb <vector121>:
.globl vector121
vector121:
  pushl $0
  1022fb:	6a 00                	push   $0x0
  pushl $121
  1022fd:	6a 79                	push   $0x79
  jmp __alltraps
  1022ff:	e9 a2 fb ff ff       	jmp    101ea6 <__alltraps>

00102304 <vector122>:
.globl vector122
vector122:
  pushl $0
  102304:	6a 00                	push   $0x0
  pushl $122
  102306:	6a 7a                	push   $0x7a
  jmp __alltraps
  102308:	e9 99 fb ff ff       	jmp    101ea6 <__alltraps>

0010230d <vector123>:
.globl vector123
vector123:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $123
  10230f:	6a 7b                	push   $0x7b
  jmp __alltraps
  102311:	e9 90 fb ff ff       	jmp    101ea6 <__alltraps>

00102316 <vector124>:
.globl vector124
vector124:
  pushl $0
  102316:	6a 00                	push   $0x0
  pushl $124
  102318:	6a 7c                	push   $0x7c
  jmp __alltraps
  10231a:	e9 87 fb ff ff       	jmp    101ea6 <__alltraps>

0010231f <vector125>:
.globl vector125
vector125:
  pushl $0
  10231f:	6a 00                	push   $0x0
  pushl $125
  102321:	6a 7d                	push   $0x7d
  jmp __alltraps
  102323:	e9 7e fb ff ff       	jmp    101ea6 <__alltraps>

00102328 <vector126>:
.globl vector126
vector126:
  pushl $0
  102328:	6a 00                	push   $0x0
  pushl $126
  10232a:	6a 7e                	push   $0x7e
  jmp __alltraps
  10232c:	e9 75 fb ff ff       	jmp    101ea6 <__alltraps>

00102331 <vector127>:
.globl vector127
vector127:
  pushl $0
  102331:	6a 00                	push   $0x0
  pushl $127
  102333:	6a 7f                	push   $0x7f
  jmp __alltraps
  102335:	e9 6c fb ff ff       	jmp    101ea6 <__alltraps>

0010233a <vector128>:
.globl vector128
vector128:
  pushl $0
  10233a:	6a 00                	push   $0x0
  pushl $128
  10233c:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102341:	e9 60 fb ff ff       	jmp    101ea6 <__alltraps>

00102346 <vector129>:
.globl vector129
vector129:
  pushl $0
  102346:	6a 00                	push   $0x0
  pushl $129
  102348:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10234d:	e9 54 fb ff ff       	jmp    101ea6 <__alltraps>

00102352 <vector130>:
.globl vector130
vector130:
  pushl $0
  102352:	6a 00                	push   $0x0
  pushl $130
  102354:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102359:	e9 48 fb ff ff       	jmp    101ea6 <__alltraps>

0010235e <vector131>:
.globl vector131
vector131:
  pushl $0
  10235e:	6a 00                	push   $0x0
  pushl $131
  102360:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102365:	e9 3c fb ff ff       	jmp    101ea6 <__alltraps>

0010236a <vector132>:
.globl vector132
vector132:
  pushl $0
  10236a:	6a 00                	push   $0x0
  pushl $132
  10236c:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102371:	e9 30 fb ff ff       	jmp    101ea6 <__alltraps>

00102376 <vector133>:
.globl vector133
vector133:
  pushl $0
  102376:	6a 00                	push   $0x0
  pushl $133
  102378:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10237d:	e9 24 fb ff ff       	jmp    101ea6 <__alltraps>

00102382 <vector134>:
.globl vector134
vector134:
  pushl $0
  102382:	6a 00                	push   $0x0
  pushl $134
  102384:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102389:	e9 18 fb ff ff       	jmp    101ea6 <__alltraps>

0010238e <vector135>:
.globl vector135
vector135:
  pushl $0
  10238e:	6a 00                	push   $0x0
  pushl $135
  102390:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102395:	e9 0c fb ff ff       	jmp    101ea6 <__alltraps>

0010239a <vector136>:
.globl vector136
vector136:
  pushl $0
  10239a:	6a 00                	push   $0x0
  pushl $136
  10239c:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1023a1:	e9 00 fb ff ff       	jmp    101ea6 <__alltraps>

001023a6 <vector137>:
.globl vector137
vector137:
  pushl $0
  1023a6:	6a 00                	push   $0x0
  pushl $137
  1023a8:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1023ad:	e9 f4 fa ff ff       	jmp    101ea6 <__alltraps>

001023b2 <vector138>:
.globl vector138
vector138:
  pushl $0
  1023b2:	6a 00                	push   $0x0
  pushl $138
  1023b4:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1023b9:	e9 e8 fa ff ff       	jmp    101ea6 <__alltraps>

001023be <vector139>:
.globl vector139
vector139:
  pushl $0
  1023be:	6a 00                	push   $0x0
  pushl $139
  1023c0:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1023c5:	e9 dc fa ff ff       	jmp    101ea6 <__alltraps>

001023ca <vector140>:
.globl vector140
vector140:
  pushl $0
  1023ca:	6a 00                	push   $0x0
  pushl $140
  1023cc:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1023d1:	e9 d0 fa ff ff       	jmp    101ea6 <__alltraps>

001023d6 <vector141>:
.globl vector141
vector141:
  pushl $0
  1023d6:	6a 00                	push   $0x0
  pushl $141
  1023d8:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1023dd:	e9 c4 fa ff ff       	jmp    101ea6 <__alltraps>

001023e2 <vector142>:
.globl vector142
vector142:
  pushl $0
  1023e2:	6a 00                	push   $0x0
  pushl $142
  1023e4:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1023e9:	e9 b8 fa ff ff       	jmp    101ea6 <__alltraps>

001023ee <vector143>:
.globl vector143
vector143:
  pushl $0
  1023ee:	6a 00                	push   $0x0
  pushl $143
  1023f0:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1023f5:	e9 ac fa ff ff       	jmp    101ea6 <__alltraps>

001023fa <vector144>:
.globl vector144
vector144:
  pushl $0
  1023fa:	6a 00                	push   $0x0
  pushl $144
  1023fc:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102401:	e9 a0 fa ff ff       	jmp    101ea6 <__alltraps>

00102406 <vector145>:
.globl vector145
vector145:
  pushl $0
  102406:	6a 00                	push   $0x0
  pushl $145
  102408:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10240d:	e9 94 fa ff ff       	jmp    101ea6 <__alltraps>

00102412 <vector146>:
.globl vector146
vector146:
  pushl $0
  102412:	6a 00                	push   $0x0
  pushl $146
  102414:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102419:	e9 88 fa ff ff       	jmp    101ea6 <__alltraps>

0010241e <vector147>:
.globl vector147
vector147:
  pushl $0
  10241e:	6a 00                	push   $0x0
  pushl $147
  102420:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102425:	e9 7c fa ff ff       	jmp    101ea6 <__alltraps>

0010242a <vector148>:
.globl vector148
vector148:
  pushl $0
  10242a:	6a 00                	push   $0x0
  pushl $148
  10242c:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102431:	e9 70 fa ff ff       	jmp    101ea6 <__alltraps>

00102436 <vector149>:
.globl vector149
vector149:
  pushl $0
  102436:	6a 00                	push   $0x0
  pushl $149
  102438:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10243d:	e9 64 fa ff ff       	jmp    101ea6 <__alltraps>

00102442 <vector150>:
.globl vector150
vector150:
  pushl $0
  102442:	6a 00                	push   $0x0
  pushl $150
  102444:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102449:	e9 58 fa ff ff       	jmp    101ea6 <__alltraps>

0010244e <vector151>:
.globl vector151
vector151:
  pushl $0
  10244e:	6a 00                	push   $0x0
  pushl $151
  102450:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102455:	e9 4c fa ff ff       	jmp    101ea6 <__alltraps>

0010245a <vector152>:
.globl vector152
vector152:
  pushl $0
  10245a:	6a 00                	push   $0x0
  pushl $152
  10245c:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102461:	e9 40 fa ff ff       	jmp    101ea6 <__alltraps>

00102466 <vector153>:
.globl vector153
vector153:
  pushl $0
  102466:	6a 00                	push   $0x0
  pushl $153
  102468:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10246d:	e9 34 fa ff ff       	jmp    101ea6 <__alltraps>

00102472 <vector154>:
.globl vector154
vector154:
  pushl $0
  102472:	6a 00                	push   $0x0
  pushl $154
  102474:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102479:	e9 28 fa ff ff       	jmp    101ea6 <__alltraps>

0010247e <vector155>:
.globl vector155
vector155:
  pushl $0
  10247e:	6a 00                	push   $0x0
  pushl $155
  102480:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102485:	e9 1c fa ff ff       	jmp    101ea6 <__alltraps>

0010248a <vector156>:
.globl vector156
vector156:
  pushl $0
  10248a:	6a 00                	push   $0x0
  pushl $156
  10248c:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102491:	e9 10 fa ff ff       	jmp    101ea6 <__alltraps>

00102496 <vector157>:
.globl vector157
vector157:
  pushl $0
  102496:	6a 00                	push   $0x0
  pushl $157
  102498:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10249d:	e9 04 fa ff ff       	jmp    101ea6 <__alltraps>

001024a2 <vector158>:
.globl vector158
vector158:
  pushl $0
  1024a2:	6a 00                	push   $0x0
  pushl $158
  1024a4:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1024a9:	e9 f8 f9 ff ff       	jmp    101ea6 <__alltraps>

001024ae <vector159>:
.globl vector159
vector159:
  pushl $0
  1024ae:	6a 00                	push   $0x0
  pushl $159
  1024b0:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1024b5:	e9 ec f9 ff ff       	jmp    101ea6 <__alltraps>

001024ba <vector160>:
.globl vector160
vector160:
  pushl $0
  1024ba:	6a 00                	push   $0x0
  pushl $160
  1024bc:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1024c1:	e9 e0 f9 ff ff       	jmp    101ea6 <__alltraps>

001024c6 <vector161>:
.globl vector161
vector161:
  pushl $0
  1024c6:	6a 00                	push   $0x0
  pushl $161
  1024c8:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1024cd:	e9 d4 f9 ff ff       	jmp    101ea6 <__alltraps>

001024d2 <vector162>:
.globl vector162
vector162:
  pushl $0
  1024d2:	6a 00                	push   $0x0
  pushl $162
  1024d4:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1024d9:	e9 c8 f9 ff ff       	jmp    101ea6 <__alltraps>

001024de <vector163>:
.globl vector163
vector163:
  pushl $0
  1024de:	6a 00                	push   $0x0
  pushl $163
  1024e0:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1024e5:	e9 bc f9 ff ff       	jmp    101ea6 <__alltraps>

001024ea <vector164>:
.globl vector164
vector164:
  pushl $0
  1024ea:	6a 00                	push   $0x0
  pushl $164
  1024ec:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1024f1:	e9 b0 f9 ff ff       	jmp    101ea6 <__alltraps>

001024f6 <vector165>:
.globl vector165
vector165:
  pushl $0
  1024f6:	6a 00                	push   $0x0
  pushl $165
  1024f8:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1024fd:	e9 a4 f9 ff ff       	jmp    101ea6 <__alltraps>

00102502 <vector166>:
.globl vector166
vector166:
  pushl $0
  102502:	6a 00                	push   $0x0
  pushl $166
  102504:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102509:	e9 98 f9 ff ff       	jmp    101ea6 <__alltraps>

0010250e <vector167>:
.globl vector167
vector167:
  pushl $0
  10250e:	6a 00                	push   $0x0
  pushl $167
  102510:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102515:	e9 8c f9 ff ff       	jmp    101ea6 <__alltraps>

0010251a <vector168>:
.globl vector168
vector168:
  pushl $0
  10251a:	6a 00                	push   $0x0
  pushl $168
  10251c:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102521:	e9 80 f9 ff ff       	jmp    101ea6 <__alltraps>

00102526 <vector169>:
.globl vector169
vector169:
  pushl $0
  102526:	6a 00                	push   $0x0
  pushl $169
  102528:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  10252d:	e9 74 f9 ff ff       	jmp    101ea6 <__alltraps>

00102532 <vector170>:
.globl vector170
vector170:
  pushl $0
  102532:	6a 00                	push   $0x0
  pushl $170
  102534:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102539:	e9 68 f9 ff ff       	jmp    101ea6 <__alltraps>

0010253e <vector171>:
.globl vector171
vector171:
  pushl $0
  10253e:	6a 00                	push   $0x0
  pushl $171
  102540:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102545:	e9 5c f9 ff ff       	jmp    101ea6 <__alltraps>

0010254a <vector172>:
.globl vector172
vector172:
  pushl $0
  10254a:	6a 00                	push   $0x0
  pushl $172
  10254c:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102551:	e9 50 f9 ff ff       	jmp    101ea6 <__alltraps>

00102556 <vector173>:
.globl vector173
vector173:
  pushl $0
  102556:	6a 00                	push   $0x0
  pushl $173
  102558:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10255d:	e9 44 f9 ff ff       	jmp    101ea6 <__alltraps>

00102562 <vector174>:
.globl vector174
vector174:
  pushl $0
  102562:	6a 00                	push   $0x0
  pushl $174
  102564:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102569:	e9 38 f9 ff ff       	jmp    101ea6 <__alltraps>

0010256e <vector175>:
.globl vector175
vector175:
  pushl $0
  10256e:	6a 00                	push   $0x0
  pushl $175
  102570:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102575:	e9 2c f9 ff ff       	jmp    101ea6 <__alltraps>

0010257a <vector176>:
.globl vector176
vector176:
  pushl $0
  10257a:	6a 00                	push   $0x0
  pushl $176
  10257c:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102581:	e9 20 f9 ff ff       	jmp    101ea6 <__alltraps>

00102586 <vector177>:
.globl vector177
vector177:
  pushl $0
  102586:	6a 00                	push   $0x0
  pushl $177
  102588:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10258d:	e9 14 f9 ff ff       	jmp    101ea6 <__alltraps>

00102592 <vector178>:
.globl vector178
vector178:
  pushl $0
  102592:	6a 00                	push   $0x0
  pushl $178
  102594:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102599:	e9 08 f9 ff ff       	jmp    101ea6 <__alltraps>

0010259e <vector179>:
.globl vector179
vector179:
  pushl $0
  10259e:	6a 00                	push   $0x0
  pushl $179
  1025a0:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1025a5:	e9 fc f8 ff ff       	jmp    101ea6 <__alltraps>

001025aa <vector180>:
.globl vector180
vector180:
  pushl $0
  1025aa:	6a 00                	push   $0x0
  pushl $180
  1025ac:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1025b1:	e9 f0 f8 ff ff       	jmp    101ea6 <__alltraps>

001025b6 <vector181>:
.globl vector181
vector181:
  pushl $0
  1025b6:	6a 00                	push   $0x0
  pushl $181
  1025b8:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1025bd:	e9 e4 f8 ff ff       	jmp    101ea6 <__alltraps>

001025c2 <vector182>:
.globl vector182
vector182:
  pushl $0
  1025c2:	6a 00                	push   $0x0
  pushl $182
  1025c4:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1025c9:	e9 d8 f8 ff ff       	jmp    101ea6 <__alltraps>

001025ce <vector183>:
.globl vector183
vector183:
  pushl $0
  1025ce:	6a 00                	push   $0x0
  pushl $183
  1025d0:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1025d5:	e9 cc f8 ff ff       	jmp    101ea6 <__alltraps>

001025da <vector184>:
.globl vector184
vector184:
  pushl $0
  1025da:	6a 00                	push   $0x0
  pushl $184
  1025dc:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1025e1:	e9 c0 f8 ff ff       	jmp    101ea6 <__alltraps>

001025e6 <vector185>:
.globl vector185
vector185:
  pushl $0
  1025e6:	6a 00                	push   $0x0
  pushl $185
  1025e8:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1025ed:	e9 b4 f8 ff ff       	jmp    101ea6 <__alltraps>

001025f2 <vector186>:
.globl vector186
vector186:
  pushl $0
  1025f2:	6a 00                	push   $0x0
  pushl $186
  1025f4:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1025f9:	e9 a8 f8 ff ff       	jmp    101ea6 <__alltraps>

001025fe <vector187>:
.globl vector187
vector187:
  pushl $0
  1025fe:	6a 00                	push   $0x0
  pushl $187
  102600:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102605:	e9 9c f8 ff ff       	jmp    101ea6 <__alltraps>

0010260a <vector188>:
.globl vector188
vector188:
  pushl $0
  10260a:	6a 00                	push   $0x0
  pushl $188
  10260c:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102611:	e9 90 f8 ff ff       	jmp    101ea6 <__alltraps>

00102616 <vector189>:
.globl vector189
vector189:
  pushl $0
  102616:	6a 00                	push   $0x0
  pushl $189
  102618:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10261d:	e9 84 f8 ff ff       	jmp    101ea6 <__alltraps>

00102622 <vector190>:
.globl vector190
vector190:
  pushl $0
  102622:	6a 00                	push   $0x0
  pushl $190
  102624:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102629:	e9 78 f8 ff ff       	jmp    101ea6 <__alltraps>

0010262e <vector191>:
.globl vector191
vector191:
  pushl $0
  10262e:	6a 00                	push   $0x0
  pushl $191
  102630:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102635:	e9 6c f8 ff ff       	jmp    101ea6 <__alltraps>

0010263a <vector192>:
.globl vector192
vector192:
  pushl $0
  10263a:	6a 00                	push   $0x0
  pushl $192
  10263c:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102641:	e9 60 f8 ff ff       	jmp    101ea6 <__alltraps>

00102646 <vector193>:
.globl vector193
vector193:
  pushl $0
  102646:	6a 00                	push   $0x0
  pushl $193
  102648:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10264d:	e9 54 f8 ff ff       	jmp    101ea6 <__alltraps>

00102652 <vector194>:
.globl vector194
vector194:
  pushl $0
  102652:	6a 00                	push   $0x0
  pushl $194
  102654:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102659:	e9 48 f8 ff ff       	jmp    101ea6 <__alltraps>

0010265e <vector195>:
.globl vector195
vector195:
  pushl $0
  10265e:	6a 00                	push   $0x0
  pushl $195
  102660:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102665:	e9 3c f8 ff ff       	jmp    101ea6 <__alltraps>

0010266a <vector196>:
.globl vector196
vector196:
  pushl $0
  10266a:	6a 00                	push   $0x0
  pushl $196
  10266c:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102671:	e9 30 f8 ff ff       	jmp    101ea6 <__alltraps>

00102676 <vector197>:
.globl vector197
vector197:
  pushl $0
  102676:	6a 00                	push   $0x0
  pushl $197
  102678:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10267d:	e9 24 f8 ff ff       	jmp    101ea6 <__alltraps>

00102682 <vector198>:
.globl vector198
vector198:
  pushl $0
  102682:	6a 00                	push   $0x0
  pushl $198
  102684:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102689:	e9 18 f8 ff ff       	jmp    101ea6 <__alltraps>

0010268e <vector199>:
.globl vector199
vector199:
  pushl $0
  10268e:	6a 00                	push   $0x0
  pushl $199
  102690:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102695:	e9 0c f8 ff ff       	jmp    101ea6 <__alltraps>

0010269a <vector200>:
.globl vector200
vector200:
  pushl $0
  10269a:	6a 00                	push   $0x0
  pushl $200
  10269c:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1026a1:	e9 00 f8 ff ff       	jmp    101ea6 <__alltraps>

001026a6 <vector201>:
.globl vector201
vector201:
  pushl $0
  1026a6:	6a 00                	push   $0x0
  pushl $201
  1026a8:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1026ad:	e9 f4 f7 ff ff       	jmp    101ea6 <__alltraps>

001026b2 <vector202>:
.globl vector202
vector202:
  pushl $0
  1026b2:	6a 00                	push   $0x0
  pushl $202
  1026b4:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1026b9:	e9 e8 f7 ff ff       	jmp    101ea6 <__alltraps>

001026be <vector203>:
.globl vector203
vector203:
  pushl $0
  1026be:	6a 00                	push   $0x0
  pushl $203
  1026c0:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1026c5:	e9 dc f7 ff ff       	jmp    101ea6 <__alltraps>

001026ca <vector204>:
.globl vector204
vector204:
  pushl $0
  1026ca:	6a 00                	push   $0x0
  pushl $204
  1026cc:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1026d1:	e9 d0 f7 ff ff       	jmp    101ea6 <__alltraps>

001026d6 <vector205>:
.globl vector205
vector205:
  pushl $0
  1026d6:	6a 00                	push   $0x0
  pushl $205
  1026d8:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1026dd:	e9 c4 f7 ff ff       	jmp    101ea6 <__alltraps>

001026e2 <vector206>:
.globl vector206
vector206:
  pushl $0
  1026e2:	6a 00                	push   $0x0
  pushl $206
  1026e4:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1026e9:	e9 b8 f7 ff ff       	jmp    101ea6 <__alltraps>

001026ee <vector207>:
.globl vector207
vector207:
  pushl $0
  1026ee:	6a 00                	push   $0x0
  pushl $207
  1026f0:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1026f5:	e9 ac f7 ff ff       	jmp    101ea6 <__alltraps>

001026fa <vector208>:
.globl vector208
vector208:
  pushl $0
  1026fa:	6a 00                	push   $0x0
  pushl $208
  1026fc:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102701:	e9 a0 f7 ff ff       	jmp    101ea6 <__alltraps>

00102706 <vector209>:
.globl vector209
vector209:
  pushl $0
  102706:	6a 00                	push   $0x0
  pushl $209
  102708:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10270d:	e9 94 f7 ff ff       	jmp    101ea6 <__alltraps>

00102712 <vector210>:
.globl vector210
vector210:
  pushl $0
  102712:	6a 00                	push   $0x0
  pushl $210
  102714:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102719:	e9 88 f7 ff ff       	jmp    101ea6 <__alltraps>

0010271e <vector211>:
.globl vector211
vector211:
  pushl $0
  10271e:	6a 00                	push   $0x0
  pushl $211
  102720:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102725:	e9 7c f7 ff ff       	jmp    101ea6 <__alltraps>

0010272a <vector212>:
.globl vector212
vector212:
  pushl $0
  10272a:	6a 00                	push   $0x0
  pushl $212
  10272c:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102731:	e9 70 f7 ff ff       	jmp    101ea6 <__alltraps>

00102736 <vector213>:
.globl vector213
vector213:
  pushl $0
  102736:	6a 00                	push   $0x0
  pushl $213
  102738:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10273d:	e9 64 f7 ff ff       	jmp    101ea6 <__alltraps>

00102742 <vector214>:
.globl vector214
vector214:
  pushl $0
  102742:	6a 00                	push   $0x0
  pushl $214
  102744:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102749:	e9 58 f7 ff ff       	jmp    101ea6 <__alltraps>

0010274e <vector215>:
.globl vector215
vector215:
  pushl $0
  10274e:	6a 00                	push   $0x0
  pushl $215
  102750:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102755:	e9 4c f7 ff ff       	jmp    101ea6 <__alltraps>

0010275a <vector216>:
.globl vector216
vector216:
  pushl $0
  10275a:	6a 00                	push   $0x0
  pushl $216
  10275c:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102761:	e9 40 f7 ff ff       	jmp    101ea6 <__alltraps>

00102766 <vector217>:
.globl vector217
vector217:
  pushl $0
  102766:	6a 00                	push   $0x0
  pushl $217
  102768:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10276d:	e9 34 f7 ff ff       	jmp    101ea6 <__alltraps>

00102772 <vector218>:
.globl vector218
vector218:
  pushl $0
  102772:	6a 00                	push   $0x0
  pushl $218
  102774:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102779:	e9 28 f7 ff ff       	jmp    101ea6 <__alltraps>

0010277e <vector219>:
.globl vector219
vector219:
  pushl $0
  10277e:	6a 00                	push   $0x0
  pushl $219
  102780:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102785:	e9 1c f7 ff ff       	jmp    101ea6 <__alltraps>

0010278a <vector220>:
.globl vector220
vector220:
  pushl $0
  10278a:	6a 00                	push   $0x0
  pushl $220
  10278c:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102791:	e9 10 f7 ff ff       	jmp    101ea6 <__alltraps>

00102796 <vector221>:
.globl vector221
vector221:
  pushl $0
  102796:	6a 00                	push   $0x0
  pushl $221
  102798:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10279d:	e9 04 f7 ff ff       	jmp    101ea6 <__alltraps>

001027a2 <vector222>:
.globl vector222
vector222:
  pushl $0
  1027a2:	6a 00                	push   $0x0
  pushl $222
  1027a4:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1027a9:	e9 f8 f6 ff ff       	jmp    101ea6 <__alltraps>

001027ae <vector223>:
.globl vector223
vector223:
  pushl $0
  1027ae:	6a 00                	push   $0x0
  pushl $223
  1027b0:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1027b5:	e9 ec f6 ff ff       	jmp    101ea6 <__alltraps>

001027ba <vector224>:
.globl vector224
vector224:
  pushl $0
  1027ba:	6a 00                	push   $0x0
  pushl $224
  1027bc:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1027c1:	e9 e0 f6 ff ff       	jmp    101ea6 <__alltraps>

001027c6 <vector225>:
.globl vector225
vector225:
  pushl $0
  1027c6:	6a 00                	push   $0x0
  pushl $225
  1027c8:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1027cd:	e9 d4 f6 ff ff       	jmp    101ea6 <__alltraps>

001027d2 <vector226>:
.globl vector226
vector226:
  pushl $0
  1027d2:	6a 00                	push   $0x0
  pushl $226
  1027d4:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1027d9:	e9 c8 f6 ff ff       	jmp    101ea6 <__alltraps>

001027de <vector227>:
.globl vector227
vector227:
  pushl $0
  1027de:	6a 00                	push   $0x0
  pushl $227
  1027e0:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1027e5:	e9 bc f6 ff ff       	jmp    101ea6 <__alltraps>

001027ea <vector228>:
.globl vector228
vector228:
  pushl $0
  1027ea:	6a 00                	push   $0x0
  pushl $228
  1027ec:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1027f1:	e9 b0 f6 ff ff       	jmp    101ea6 <__alltraps>

001027f6 <vector229>:
.globl vector229
vector229:
  pushl $0
  1027f6:	6a 00                	push   $0x0
  pushl $229
  1027f8:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1027fd:	e9 a4 f6 ff ff       	jmp    101ea6 <__alltraps>

00102802 <vector230>:
.globl vector230
vector230:
  pushl $0
  102802:	6a 00                	push   $0x0
  pushl $230
  102804:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102809:	e9 98 f6 ff ff       	jmp    101ea6 <__alltraps>

0010280e <vector231>:
.globl vector231
vector231:
  pushl $0
  10280e:	6a 00                	push   $0x0
  pushl $231
  102810:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102815:	e9 8c f6 ff ff       	jmp    101ea6 <__alltraps>

0010281a <vector232>:
.globl vector232
vector232:
  pushl $0
  10281a:	6a 00                	push   $0x0
  pushl $232
  10281c:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102821:	e9 80 f6 ff ff       	jmp    101ea6 <__alltraps>

00102826 <vector233>:
.globl vector233
vector233:
  pushl $0
  102826:	6a 00                	push   $0x0
  pushl $233
  102828:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  10282d:	e9 74 f6 ff ff       	jmp    101ea6 <__alltraps>

00102832 <vector234>:
.globl vector234
vector234:
  pushl $0
  102832:	6a 00                	push   $0x0
  pushl $234
  102834:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102839:	e9 68 f6 ff ff       	jmp    101ea6 <__alltraps>

0010283e <vector235>:
.globl vector235
vector235:
  pushl $0
  10283e:	6a 00                	push   $0x0
  pushl $235
  102840:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102845:	e9 5c f6 ff ff       	jmp    101ea6 <__alltraps>

0010284a <vector236>:
.globl vector236
vector236:
  pushl $0
  10284a:	6a 00                	push   $0x0
  pushl $236
  10284c:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102851:	e9 50 f6 ff ff       	jmp    101ea6 <__alltraps>

00102856 <vector237>:
.globl vector237
vector237:
  pushl $0
  102856:	6a 00                	push   $0x0
  pushl $237
  102858:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10285d:	e9 44 f6 ff ff       	jmp    101ea6 <__alltraps>

00102862 <vector238>:
.globl vector238
vector238:
  pushl $0
  102862:	6a 00                	push   $0x0
  pushl $238
  102864:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102869:	e9 38 f6 ff ff       	jmp    101ea6 <__alltraps>

0010286e <vector239>:
.globl vector239
vector239:
  pushl $0
  10286e:	6a 00                	push   $0x0
  pushl $239
  102870:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102875:	e9 2c f6 ff ff       	jmp    101ea6 <__alltraps>

0010287a <vector240>:
.globl vector240
vector240:
  pushl $0
  10287a:	6a 00                	push   $0x0
  pushl $240
  10287c:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102881:	e9 20 f6 ff ff       	jmp    101ea6 <__alltraps>

00102886 <vector241>:
.globl vector241
vector241:
  pushl $0
  102886:	6a 00                	push   $0x0
  pushl $241
  102888:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10288d:	e9 14 f6 ff ff       	jmp    101ea6 <__alltraps>

00102892 <vector242>:
.globl vector242
vector242:
  pushl $0
  102892:	6a 00                	push   $0x0
  pushl $242
  102894:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102899:	e9 08 f6 ff ff       	jmp    101ea6 <__alltraps>

0010289e <vector243>:
.globl vector243
vector243:
  pushl $0
  10289e:	6a 00                	push   $0x0
  pushl $243
  1028a0:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1028a5:	e9 fc f5 ff ff       	jmp    101ea6 <__alltraps>

001028aa <vector244>:
.globl vector244
vector244:
  pushl $0
  1028aa:	6a 00                	push   $0x0
  pushl $244
  1028ac:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1028b1:	e9 f0 f5 ff ff       	jmp    101ea6 <__alltraps>

001028b6 <vector245>:
.globl vector245
vector245:
  pushl $0
  1028b6:	6a 00                	push   $0x0
  pushl $245
  1028b8:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1028bd:	e9 e4 f5 ff ff       	jmp    101ea6 <__alltraps>

001028c2 <vector246>:
.globl vector246
vector246:
  pushl $0
  1028c2:	6a 00                	push   $0x0
  pushl $246
  1028c4:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1028c9:	e9 d8 f5 ff ff       	jmp    101ea6 <__alltraps>

001028ce <vector247>:
.globl vector247
vector247:
  pushl $0
  1028ce:	6a 00                	push   $0x0
  pushl $247
  1028d0:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1028d5:	e9 cc f5 ff ff       	jmp    101ea6 <__alltraps>

001028da <vector248>:
.globl vector248
vector248:
  pushl $0
  1028da:	6a 00                	push   $0x0
  pushl $248
  1028dc:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1028e1:	e9 c0 f5 ff ff       	jmp    101ea6 <__alltraps>

001028e6 <vector249>:
.globl vector249
vector249:
  pushl $0
  1028e6:	6a 00                	push   $0x0
  pushl $249
  1028e8:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1028ed:	e9 b4 f5 ff ff       	jmp    101ea6 <__alltraps>

001028f2 <vector250>:
.globl vector250
vector250:
  pushl $0
  1028f2:	6a 00                	push   $0x0
  pushl $250
  1028f4:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1028f9:	e9 a8 f5 ff ff       	jmp    101ea6 <__alltraps>

001028fe <vector251>:
.globl vector251
vector251:
  pushl $0
  1028fe:	6a 00                	push   $0x0
  pushl $251
  102900:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102905:	e9 9c f5 ff ff       	jmp    101ea6 <__alltraps>

0010290a <vector252>:
.globl vector252
vector252:
  pushl $0
  10290a:	6a 00                	push   $0x0
  pushl $252
  10290c:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102911:	e9 90 f5 ff ff       	jmp    101ea6 <__alltraps>

00102916 <vector253>:
.globl vector253
vector253:
  pushl $0
  102916:	6a 00                	push   $0x0
  pushl $253
  102918:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10291d:	e9 84 f5 ff ff       	jmp    101ea6 <__alltraps>

00102922 <vector254>:
.globl vector254
vector254:
  pushl $0
  102922:	6a 00                	push   $0x0
  pushl $254
  102924:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102929:	e9 78 f5 ff ff       	jmp    101ea6 <__alltraps>

0010292e <vector255>:
.globl vector255
vector255:
  pushl $0
  10292e:	6a 00                	push   $0x0
  pushl $255
  102930:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102935:	e9 6c f5 ff ff       	jmp    101ea6 <__alltraps>

0010293a <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  10293a:	55                   	push   %ebp
  10293b:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  10293d:	8b 45 08             	mov    0x8(%ebp),%eax
  102940:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102943:	b8 23 00 00 00       	mov    $0x23,%eax
  102948:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  10294a:	b8 23 00 00 00       	mov    $0x23,%eax
  10294f:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102951:	b8 10 00 00 00       	mov    $0x10,%eax
  102956:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102958:	b8 10 00 00 00       	mov    $0x10,%eax
  10295d:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  10295f:	b8 10 00 00 00       	mov    $0x10,%eax
  102964:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102966:	ea 6d 29 10 00 08 00 	ljmp   $0x8,$0x10296d
}
  10296d:	5d                   	pop    %ebp
  10296e:	c3                   	ret    

0010296f <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  10296f:	55                   	push   %ebp
  102970:	89 e5                	mov    %esp,%ebp
  102972:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102975:	b8 80 f9 10 00       	mov    $0x10f980,%eax
  10297a:	05 00 04 00 00       	add    $0x400,%eax
  10297f:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  102984:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  10298b:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  10298d:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  102994:	68 00 
  102996:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10299b:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  1029a1:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029a6:	c1 e8 10             	shr    $0x10,%eax
  1029a9:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  1029ae:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029b5:	83 e0 f0             	and    $0xfffffff0,%eax
  1029b8:	83 c8 09             	or     $0x9,%eax
  1029bb:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029c0:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029c7:	83 c8 10             	or     $0x10,%eax
  1029ca:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029cf:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029d6:	83 e0 9f             	and    $0xffffff9f,%eax
  1029d9:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029de:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029e5:	83 c8 80             	or     $0xffffff80,%eax
  1029e8:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029ed:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1029f4:	83 e0 f0             	and    $0xfffffff0,%eax
  1029f7:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1029fc:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a03:	83 e0 ef             	and    $0xffffffef,%eax
  102a06:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a0b:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a12:	83 e0 df             	and    $0xffffffdf,%eax
  102a15:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a1a:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a21:	83 c8 40             	or     $0x40,%eax
  102a24:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a29:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a30:	83 e0 7f             	and    $0x7f,%eax
  102a33:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a38:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102a3d:	c1 e8 18             	shr    $0x18,%eax
  102a40:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102a45:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a4c:	83 e0 ef             	and    $0xffffffef,%eax
  102a4f:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102a54:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  102a5b:	e8 da fe ff ff       	call   10293a <lgdt>
  102a60:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102a66:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102a6a:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102a6d:	c9                   	leave  
  102a6e:	c3                   	ret    

00102a6f <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102a6f:	55                   	push   %ebp
  102a70:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102a72:	e8 f8 fe ff ff       	call   10296f <gdt_init>
}
  102a77:	5d                   	pop    %ebp
  102a78:	c3                   	ret    

00102a79 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102a79:	55                   	push   %ebp
  102a7a:	89 e5                	mov    %esp,%ebp
  102a7c:	83 ec 58             	sub    $0x58,%esp
  102a7f:	8b 45 10             	mov    0x10(%ebp),%eax
  102a82:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a85:	8b 45 14             	mov    0x14(%ebp),%eax
  102a88:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102a8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a8e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a91:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102a94:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102a97:	8b 45 18             	mov    0x18(%ebp),%eax
  102a9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102a9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102aa0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102aa3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102aa6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102aac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102aaf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102ab3:	74 1c                	je     102ad1 <printnum+0x58>
  102ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  102abd:	f7 75 e4             	divl   -0x1c(%ebp)
  102ac0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  102acb:	f7 75 e4             	divl   -0x1c(%ebp)
  102ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ad1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ad4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ad7:	f7 75 e4             	divl   -0x1c(%ebp)
  102ada:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102add:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102ae0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ae3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102ae6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102ae9:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102aec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102aef:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102af2:	8b 45 18             	mov    0x18(%ebp),%eax
  102af5:	ba 00 00 00 00       	mov    $0x0,%edx
  102afa:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102afd:	77 56                	ja     102b55 <printnum+0xdc>
  102aff:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102b02:	72 05                	jb     102b09 <printnum+0x90>
  102b04:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102b07:	77 4c                	ja     102b55 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  102b09:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102b0c:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b0f:	8b 45 20             	mov    0x20(%ebp),%eax
  102b12:	89 44 24 18          	mov    %eax,0x18(%esp)
  102b16:	89 54 24 14          	mov    %edx,0x14(%esp)
  102b1a:	8b 45 18             	mov    0x18(%ebp),%eax
  102b1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  102b21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b24:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102b27:	89 44 24 08          	mov    %eax,0x8(%esp)
  102b2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b32:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b36:	8b 45 08             	mov    0x8(%ebp),%eax
  102b39:	89 04 24             	mov    %eax,(%esp)
  102b3c:	e8 38 ff ff ff       	call   102a79 <printnum>
  102b41:	eb 1c                	jmp    102b5f <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b4a:	8b 45 20             	mov    0x20(%ebp),%eax
  102b4d:	89 04 24             	mov    %eax,(%esp)
  102b50:	8b 45 08             	mov    0x8(%ebp),%eax
  102b53:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  102b55:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  102b59:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102b5d:	7f e4                	jg     102b43 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102b5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b62:	05 90 3d 10 00       	add    $0x103d90,%eax
  102b67:	0f b6 00             	movzbl (%eax),%eax
  102b6a:	0f be c0             	movsbl %al,%eax
  102b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b70:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b74:	89 04 24             	mov    %eax,(%esp)
  102b77:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7a:	ff d0                	call   *%eax
}
  102b7c:	c9                   	leave  
  102b7d:	c3                   	ret    

00102b7e <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102b7e:	55                   	push   %ebp
  102b7f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102b81:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102b85:	7e 14                	jle    102b9b <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102b87:	8b 45 08             	mov    0x8(%ebp),%eax
  102b8a:	8b 00                	mov    (%eax),%eax
  102b8c:	8d 48 08             	lea    0x8(%eax),%ecx
  102b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  102b92:	89 0a                	mov    %ecx,(%edx)
  102b94:	8b 50 04             	mov    0x4(%eax),%edx
  102b97:	8b 00                	mov    (%eax),%eax
  102b99:	eb 30                	jmp    102bcb <getuint+0x4d>
    }
    else if (lflag) {
  102b9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b9f:	74 16                	je     102bb7 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba4:	8b 00                	mov    (%eax),%eax
  102ba6:	8d 48 04             	lea    0x4(%eax),%ecx
  102ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  102bac:	89 0a                	mov    %ecx,(%edx)
  102bae:	8b 00                	mov    (%eax),%eax
  102bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  102bb5:	eb 14                	jmp    102bcb <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  102bba:	8b 00                	mov    (%eax),%eax
  102bbc:	8d 48 04             	lea    0x4(%eax),%ecx
  102bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  102bc2:	89 0a                	mov    %ecx,(%edx)
  102bc4:	8b 00                	mov    (%eax),%eax
  102bc6:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102bcb:	5d                   	pop    %ebp
  102bcc:	c3                   	ret    

00102bcd <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102bcd:	55                   	push   %ebp
  102bce:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102bd0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102bd4:	7e 14                	jle    102bea <getint+0x1d>
        return va_arg(*ap, long long);
  102bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd9:	8b 00                	mov    (%eax),%eax
  102bdb:	8d 48 08             	lea    0x8(%eax),%ecx
  102bde:	8b 55 08             	mov    0x8(%ebp),%edx
  102be1:	89 0a                	mov    %ecx,(%edx)
  102be3:	8b 50 04             	mov    0x4(%eax),%edx
  102be6:	8b 00                	mov    (%eax),%eax
  102be8:	eb 28                	jmp    102c12 <getint+0x45>
    }
    else if (lflag) {
  102bea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102bee:	74 12                	je     102c02 <getint+0x35>
        return va_arg(*ap, long);
  102bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf3:	8b 00                	mov    (%eax),%eax
  102bf5:	8d 48 04             	lea    0x4(%eax),%ecx
  102bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  102bfb:	89 0a                	mov    %ecx,(%edx)
  102bfd:	8b 00                	mov    (%eax),%eax
  102bff:	99                   	cltd   
  102c00:	eb 10                	jmp    102c12 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102c02:	8b 45 08             	mov    0x8(%ebp),%eax
  102c05:	8b 00                	mov    (%eax),%eax
  102c07:	8d 48 04             	lea    0x4(%eax),%ecx
  102c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  102c0d:	89 0a                	mov    %ecx,(%edx)
  102c0f:	8b 00                	mov    (%eax),%eax
  102c11:	99                   	cltd   
    }
}
  102c12:	5d                   	pop    %ebp
  102c13:	c3                   	ret    

00102c14 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102c14:	55                   	push   %ebp
  102c15:	89 e5                	mov    %esp,%ebp
  102c17:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102c1a:	8d 45 14             	lea    0x14(%ebp),%eax
  102c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102c27:	8b 45 10             	mov    0x10(%ebp),%eax
  102c2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  102c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c35:	8b 45 08             	mov    0x8(%ebp),%eax
  102c38:	89 04 24             	mov    %eax,(%esp)
  102c3b:	e8 02 00 00 00       	call   102c42 <vprintfmt>
    va_end(ap);
}
  102c40:	c9                   	leave  
  102c41:	c3                   	ret    

00102c42 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102c42:	55                   	push   %ebp
  102c43:	89 e5                	mov    %esp,%ebp
  102c45:	56                   	push   %esi
  102c46:	53                   	push   %ebx
  102c47:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102c4a:	eb 18                	jmp    102c64 <vprintfmt+0x22>
            if (ch == '\0') {
  102c4c:	85 db                	test   %ebx,%ebx
  102c4e:	75 05                	jne    102c55 <vprintfmt+0x13>
                return;
  102c50:	e9 d1 03 00 00       	jmp    103026 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  102c55:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c5c:	89 1c 24             	mov    %ebx,(%esp)
  102c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  102c62:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102c64:	8b 45 10             	mov    0x10(%ebp),%eax
  102c67:	8d 50 01             	lea    0x1(%eax),%edx
  102c6a:	89 55 10             	mov    %edx,0x10(%ebp)
  102c6d:	0f b6 00             	movzbl (%eax),%eax
  102c70:	0f b6 d8             	movzbl %al,%ebx
  102c73:	83 fb 25             	cmp    $0x25,%ebx
  102c76:	75 d4                	jne    102c4c <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  102c78:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102c7c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c86:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102c89:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c90:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c93:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102c96:	8b 45 10             	mov    0x10(%ebp),%eax
  102c99:	8d 50 01             	lea    0x1(%eax),%edx
  102c9c:	89 55 10             	mov    %edx,0x10(%ebp)
  102c9f:	0f b6 00             	movzbl (%eax),%eax
  102ca2:	0f b6 d8             	movzbl %al,%ebx
  102ca5:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102ca8:	83 f8 55             	cmp    $0x55,%eax
  102cab:	0f 87 44 03 00 00    	ja     102ff5 <vprintfmt+0x3b3>
  102cb1:	8b 04 85 b4 3d 10 00 	mov    0x103db4(,%eax,4),%eax
  102cb8:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102cba:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102cbe:	eb d6                	jmp    102c96 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102cc0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102cc4:	eb d0                	jmp    102c96 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102cc6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102ccd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102cd0:	89 d0                	mov    %edx,%eax
  102cd2:	c1 e0 02             	shl    $0x2,%eax
  102cd5:	01 d0                	add    %edx,%eax
  102cd7:	01 c0                	add    %eax,%eax
  102cd9:	01 d8                	add    %ebx,%eax
  102cdb:	83 e8 30             	sub    $0x30,%eax
  102cde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102ce1:	8b 45 10             	mov    0x10(%ebp),%eax
  102ce4:	0f b6 00             	movzbl (%eax),%eax
  102ce7:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102cea:	83 fb 2f             	cmp    $0x2f,%ebx
  102ced:	7e 0b                	jle    102cfa <vprintfmt+0xb8>
  102cef:	83 fb 39             	cmp    $0x39,%ebx
  102cf2:	7f 06                	jg     102cfa <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102cf4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  102cf8:	eb d3                	jmp    102ccd <vprintfmt+0x8b>
            goto process_precision;
  102cfa:	eb 33                	jmp    102d2f <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  102cfc:	8b 45 14             	mov    0x14(%ebp),%eax
  102cff:	8d 50 04             	lea    0x4(%eax),%edx
  102d02:	89 55 14             	mov    %edx,0x14(%ebp)
  102d05:	8b 00                	mov    (%eax),%eax
  102d07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102d0a:	eb 23                	jmp    102d2f <vprintfmt+0xed>

        case '.':
            if (width < 0)
  102d0c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d10:	79 0c                	jns    102d1e <vprintfmt+0xdc>
                width = 0;
  102d12:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102d19:	e9 78 ff ff ff       	jmp    102c96 <vprintfmt+0x54>
  102d1e:	e9 73 ff ff ff       	jmp    102c96 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  102d23:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102d2a:	e9 67 ff ff ff       	jmp    102c96 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  102d2f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d33:	79 12                	jns    102d47 <vprintfmt+0x105>
                width = precision, precision = -1;
  102d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102d38:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102d3b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102d42:	e9 4f ff ff ff       	jmp    102c96 <vprintfmt+0x54>
  102d47:	e9 4a ff ff ff       	jmp    102c96 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102d4c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  102d50:	e9 41 ff ff ff       	jmp    102c96 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  102d55:	8b 45 14             	mov    0x14(%ebp),%eax
  102d58:	8d 50 04             	lea    0x4(%eax),%edx
  102d5b:	89 55 14             	mov    %edx,0x14(%ebp)
  102d5e:	8b 00                	mov    (%eax),%eax
  102d60:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d67:	89 04 24             	mov    %eax,(%esp)
  102d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  102d6d:	ff d0                	call   *%eax
            break;
  102d6f:	e9 ac 02 00 00       	jmp    103020 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  102d74:	8b 45 14             	mov    0x14(%ebp),%eax
  102d77:	8d 50 04             	lea    0x4(%eax),%edx
  102d7a:	89 55 14             	mov    %edx,0x14(%ebp)
  102d7d:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  102d7f:	85 db                	test   %ebx,%ebx
  102d81:	79 02                	jns    102d85 <vprintfmt+0x143>
                err = -err;
  102d83:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  102d85:	83 fb 06             	cmp    $0x6,%ebx
  102d88:	7f 0b                	jg     102d95 <vprintfmt+0x153>
  102d8a:	8b 34 9d 74 3d 10 00 	mov    0x103d74(,%ebx,4),%esi
  102d91:	85 f6                	test   %esi,%esi
  102d93:	75 23                	jne    102db8 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  102d95:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102d99:	c7 44 24 08 a1 3d 10 	movl   $0x103da1,0x8(%esp)
  102da0:	00 
  102da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  102da8:	8b 45 08             	mov    0x8(%ebp),%eax
  102dab:	89 04 24             	mov    %eax,(%esp)
  102dae:	e8 61 fe ff ff       	call   102c14 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  102db3:	e9 68 02 00 00       	jmp    103020 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  102db8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  102dbc:	c7 44 24 08 aa 3d 10 	movl   $0x103daa,0x8(%esp)
  102dc3:	00 
  102dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  102dce:	89 04 24             	mov    %eax,(%esp)
  102dd1:	e8 3e fe ff ff       	call   102c14 <printfmt>
            }
            break;
  102dd6:	e9 45 02 00 00       	jmp    103020 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  102ddb:	8b 45 14             	mov    0x14(%ebp),%eax
  102dde:	8d 50 04             	lea    0x4(%eax),%edx
  102de1:	89 55 14             	mov    %edx,0x14(%ebp)
  102de4:	8b 30                	mov    (%eax),%esi
  102de6:	85 f6                	test   %esi,%esi
  102de8:	75 05                	jne    102def <vprintfmt+0x1ad>
                p = "(null)";
  102dea:	be ad 3d 10 00       	mov    $0x103dad,%esi
            }
            if (width > 0 && padc != '-') {
  102def:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102df3:	7e 3e                	jle    102e33 <vprintfmt+0x1f1>
  102df5:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  102df9:	74 38                	je     102e33 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  102dfb:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  102dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e05:	89 34 24             	mov    %esi,(%esp)
  102e08:	e8 15 03 00 00       	call   103122 <strnlen>
  102e0d:	29 c3                	sub    %eax,%ebx
  102e0f:	89 d8                	mov    %ebx,%eax
  102e11:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e14:	eb 17                	jmp    102e2d <vprintfmt+0x1eb>
                    putch(padc, putdat);
  102e16:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  102e1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e21:	89 04 24             	mov    %eax,(%esp)
  102e24:	8b 45 08             	mov    0x8(%ebp),%eax
  102e27:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  102e29:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102e2d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e31:	7f e3                	jg     102e16 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102e33:	eb 38                	jmp    102e6d <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  102e35:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102e39:	74 1f                	je     102e5a <vprintfmt+0x218>
  102e3b:	83 fb 1f             	cmp    $0x1f,%ebx
  102e3e:	7e 05                	jle    102e45 <vprintfmt+0x203>
  102e40:	83 fb 7e             	cmp    $0x7e,%ebx
  102e43:	7e 15                	jle    102e5a <vprintfmt+0x218>
                    putch('?', putdat);
  102e45:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e4c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  102e53:	8b 45 08             	mov    0x8(%ebp),%eax
  102e56:	ff d0                	call   *%eax
  102e58:	eb 0f                	jmp    102e69 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  102e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e61:	89 1c 24             	mov    %ebx,(%esp)
  102e64:	8b 45 08             	mov    0x8(%ebp),%eax
  102e67:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102e69:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102e6d:	89 f0                	mov    %esi,%eax
  102e6f:	8d 70 01             	lea    0x1(%eax),%esi
  102e72:	0f b6 00             	movzbl (%eax),%eax
  102e75:	0f be d8             	movsbl %al,%ebx
  102e78:	85 db                	test   %ebx,%ebx
  102e7a:	74 10                	je     102e8c <vprintfmt+0x24a>
  102e7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e80:	78 b3                	js     102e35 <vprintfmt+0x1f3>
  102e82:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  102e86:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e8a:	79 a9                	jns    102e35 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102e8c:	eb 17                	jmp    102ea5 <vprintfmt+0x263>
                putch(' ', putdat);
  102e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e91:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e95:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  102e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e9f:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102ea1:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102ea5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102ea9:	7f e3                	jg     102e8e <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  102eab:	e9 70 01 00 00       	jmp    103020 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  102eb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eb7:	8d 45 14             	lea    0x14(%ebp),%eax
  102eba:	89 04 24             	mov    %eax,(%esp)
  102ebd:	e8 0b fd ff ff       	call   102bcd <getint>
  102ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ec5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  102ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ecb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ece:	85 d2                	test   %edx,%edx
  102ed0:	79 26                	jns    102ef8 <vprintfmt+0x2b6>
                putch('-', putdat);
  102ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ed9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  102ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ee3:	ff d0                	call   *%eax
                num = -(long long)num;
  102ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ee8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102eeb:	f7 d8                	neg    %eax
  102eed:	83 d2 00             	adc    $0x0,%edx
  102ef0:	f7 da                	neg    %edx
  102ef2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ef5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  102ef8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102eff:	e9 a8 00 00 00       	jmp    102fac <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  102f04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f07:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f0b:	8d 45 14             	lea    0x14(%ebp),%eax
  102f0e:	89 04 24             	mov    %eax,(%esp)
  102f11:	e8 68 fc ff ff       	call   102b7e <getuint>
  102f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f19:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  102f1c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102f23:	e9 84 00 00 00       	jmp    102fac <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  102f28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f2f:	8d 45 14             	lea    0x14(%ebp),%eax
  102f32:	89 04 24             	mov    %eax,(%esp)
  102f35:	e8 44 fc ff ff       	call   102b7e <getuint>
  102f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f3d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  102f40:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  102f47:	eb 63                	jmp    102fac <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  102f49:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f50:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  102f57:	8b 45 08             	mov    0x8(%ebp),%eax
  102f5a:	ff d0                	call   *%eax
            putch('x', putdat);
  102f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f63:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  102f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f6d:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  102f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  102f72:	8d 50 04             	lea    0x4(%eax),%edx
  102f75:	89 55 14             	mov    %edx,0x14(%ebp)
  102f78:	8b 00                	mov    (%eax),%eax
  102f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  102f84:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  102f8b:	eb 1f                	jmp    102fac <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  102f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f90:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f94:	8d 45 14             	lea    0x14(%ebp),%eax
  102f97:	89 04 24             	mov    %eax,(%esp)
  102f9a:	e8 df fb ff ff       	call   102b7e <getuint>
  102f9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102fa2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  102fa5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  102fac:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  102fb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fb3:	89 54 24 18          	mov    %edx,0x18(%esp)
  102fb7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102fba:	89 54 24 14          	mov    %edx,0x14(%esp)
  102fbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  102fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102fc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  102fcc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  102fda:	89 04 24             	mov    %eax,(%esp)
  102fdd:	e8 97 fa ff ff       	call   102a79 <printnum>
            break;
  102fe2:	eb 3c                	jmp    103020 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  102fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102feb:	89 1c 24             	mov    %ebx,(%esp)
  102fee:	8b 45 08             	mov    0x8(%ebp),%eax
  102ff1:	ff d0                	call   *%eax
            break;
  102ff3:	eb 2b                	jmp    103020 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  102ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ffc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  103003:	8b 45 08             	mov    0x8(%ebp),%eax
  103006:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  103008:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10300c:	eb 04                	jmp    103012 <vprintfmt+0x3d0>
  10300e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103012:	8b 45 10             	mov    0x10(%ebp),%eax
  103015:	83 e8 01             	sub    $0x1,%eax
  103018:	0f b6 00             	movzbl (%eax),%eax
  10301b:	3c 25                	cmp    $0x25,%al
  10301d:	75 ef                	jne    10300e <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  10301f:	90                   	nop
        }
    }
  103020:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103021:	e9 3e fc ff ff       	jmp    102c64 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  103026:	83 c4 40             	add    $0x40,%esp
  103029:	5b                   	pop    %ebx
  10302a:	5e                   	pop    %esi
  10302b:	5d                   	pop    %ebp
  10302c:	c3                   	ret    

0010302d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10302d:	55                   	push   %ebp
  10302e:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103030:	8b 45 0c             	mov    0xc(%ebp),%eax
  103033:	8b 40 08             	mov    0x8(%eax),%eax
  103036:	8d 50 01             	lea    0x1(%eax),%edx
  103039:	8b 45 0c             	mov    0xc(%ebp),%eax
  10303c:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  10303f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103042:	8b 10                	mov    (%eax),%edx
  103044:	8b 45 0c             	mov    0xc(%ebp),%eax
  103047:	8b 40 04             	mov    0x4(%eax),%eax
  10304a:	39 c2                	cmp    %eax,%edx
  10304c:	73 12                	jae    103060 <sprintputch+0x33>
        *b->buf ++ = ch;
  10304e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103051:	8b 00                	mov    (%eax),%eax
  103053:	8d 48 01             	lea    0x1(%eax),%ecx
  103056:	8b 55 0c             	mov    0xc(%ebp),%edx
  103059:	89 0a                	mov    %ecx,(%edx)
  10305b:	8b 55 08             	mov    0x8(%ebp),%edx
  10305e:	88 10                	mov    %dl,(%eax)
    }
}
  103060:	5d                   	pop    %ebp
  103061:	c3                   	ret    

00103062 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  103062:	55                   	push   %ebp
  103063:	89 e5                	mov    %esp,%ebp
  103065:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  103068:	8d 45 14             	lea    0x14(%ebp),%eax
  10306b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  10306e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103075:	8b 45 10             	mov    0x10(%ebp),%eax
  103078:	89 44 24 08          	mov    %eax,0x8(%esp)
  10307c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10307f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103083:	8b 45 08             	mov    0x8(%ebp),%eax
  103086:	89 04 24             	mov    %eax,(%esp)
  103089:	e8 08 00 00 00       	call   103096 <vsnprintf>
  10308e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  103091:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103094:	c9                   	leave  
  103095:	c3                   	ret    

00103096 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  103096:	55                   	push   %ebp
  103097:	89 e5                	mov    %esp,%ebp
  103099:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  10309c:	8b 45 08             	mov    0x8(%ebp),%eax
  10309f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030a5:	8d 50 ff             	lea    -0x1(%eax),%edx
  1030a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ab:	01 d0                	add    %edx,%eax
  1030ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1030b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1030b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1030bb:	74 0a                	je     1030c7 <vsnprintf+0x31>
  1030bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1030c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030c3:	39 c2                	cmp    %eax,%edx
  1030c5:	76 07                	jbe    1030ce <vsnprintf+0x38>
        return -E_INVAL;
  1030c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1030cc:	eb 2a                	jmp    1030f8 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1030ce:	8b 45 14             	mov    0x14(%ebp),%eax
  1030d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1030d5:	8b 45 10             	mov    0x10(%ebp),%eax
  1030d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1030dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1030df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030e3:	c7 04 24 2d 30 10 00 	movl   $0x10302d,(%esp)
  1030ea:	e8 53 fb ff ff       	call   102c42 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1030ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030f2:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1030f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1030f8:	c9                   	leave  
  1030f9:	c3                   	ret    

001030fa <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1030fa:	55                   	push   %ebp
  1030fb:	89 e5                	mov    %esp,%ebp
  1030fd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  103100:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  103107:	eb 04                	jmp    10310d <strlen+0x13>
        cnt ++;
  103109:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  10310d:	8b 45 08             	mov    0x8(%ebp),%eax
  103110:	8d 50 01             	lea    0x1(%eax),%edx
  103113:	89 55 08             	mov    %edx,0x8(%ebp)
  103116:	0f b6 00             	movzbl (%eax),%eax
  103119:	84 c0                	test   %al,%al
  10311b:	75 ec                	jne    103109 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  10311d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  103120:	c9                   	leave  
  103121:	c3                   	ret    

00103122 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  103122:	55                   	push   %ebp
  103123:	89 e5                	mov    %esp,%ebp
  103125:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  103128:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10312f:	eb 04                	jmp    103135 <strnlen+0x13>
        cnt ++;
  103131:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  103135:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103138:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10313b:	73 10                	jae    10314d <strnlen+0x2b>
  10313d:	8b 45 08             	mov    0x8(%ebp),%eax
  103140:	8d 50 01             	lea    0x1(%eax),%edx
  103143:	89 55 08             	mov    %edx,0x8(%ebp)
  103146:	0f b6 00             	movzbl (%eax),%eax
  103149:	84 c0                	test   %al,%al
  10314b:	75 e4                	jne    103131 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  10314d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  103150:	c9                   	leave  
  103151:	c3                   	ret    

00103152 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  103152:	55                   	push   %ebp
  103153:	89 e5                	mov    %esp,%ebp
  103155:	57                   	push   %edi
  103156:	56                   	push   %esi
  103157:	83 ec 20             	sub    $0x20,%esp
  10315a:	8b 45 08             	mov    0x8(%ebp),%eax
  10315d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103160:	8b 45 0c             	mov    0xc(%ebp),%eax
  103163:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  103166:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103169:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10316c:	89 d1                	mov    %edx,%ecx
  10316e:	89 c2                	mov    %eax,%edx
  103170:	89 ce                	mov    %ecx,%esi
  103172:	89 d7                	mov    %edx,%edi
  103174:	ac                   	lods   %ds:(%esi),%al
  103175:	aa                   	stos   %al,%es:(%edi)
  103176:	84 c0                	test   %al,%al
  103178:	75 fa                	jne    103174 <strcpy+0x22>
  10317a:	89 fa                	mov    %edi,%edx
  10317c:	89 f1                	mov    %esi,%ecx
  10317e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  103181:	89 55 e8             	mov    %edx,-0x18(%ebp)
  103184:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  103187:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10318a:	83 c4 20             	add    $0x20,%esp
  10318d:	5e                   	pop    %esi
  10318e:	5f                   	pop    %edi
  10318f:	5d                   	pop    %ebp
  103190:	c3                   	ret    

00103191 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  103191:	55                   	push   %ebp
  103192:	89 e5                	mov    %esp,%ebp
  103194:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  103197:	8b 45 08             	mov    0x8(%ebp),%eax
  10319a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10319d:	eb 21                	jmp    1031c0 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  10319f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031a2:	0f b6 10             	movzbl (%eax),%edx
  1031a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031a8:	88 10                	mov    %dl,(%eax)
  1031aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031ad:	0f b6 00             	movzbl (%eax),%eax
  1031b0:	84 c0                	test   %al,%al
  1031b2:	74 04                	je     1031b8 <strncpy+0x27>
            src ++;
  1031b4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  1031b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1031bc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  1031c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1031c4:	75 d9                	jne    10319f <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  1031c6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1031c9:	c9                   	leave  
  1031ca:	c3                   	ret    

001031cb <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1031cb:	55                   	push   %ebp
  1031cc:	89 e5                	mov    %esp,%ebp
  1031ce:	57                   	push   %edi
  1031cf:	56                   	push   %esi
  1031d0:	83 ec 20             	sub    $0x20,%esp
  1031d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1031d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  1031df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1031e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031e5:	89 d1                	mov    %edx,%ecx
  1031e7:	89 c2                	mov    %eax,%edx
  1031e9:	89 ce                	mov    %ecx,%esi
  1031eb:	89 d7                	mov    %edx,%edi
  1031ed:	ac                   	lods   %ds:(%esi),%al
  1031ee:	ae                   	scas   %es:(%edi),%al
  1031ef:	75 08                	jne    1031f9 <strcmp+0x2e>
  1031f1:	84 c0                	test   %al,%al
  1031f3:	75 f8                	jne    1031ed <strcmp+0x22>
  1031f5:	31 c0                	xor    %eax,%eax
  1031f7:	eb 04                	jmp    1031fd <strcmp+0x32>
  1031f9:	19 c0                	sbb    %eax,%eax
  1031fb:	0c 01                	or     $0x1,%al
  1031fd:	89 fa                	mov    %edi,%edx
  1031ff:	89 f1                	mov    %esi,%ecx
  103201:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103204:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  103207:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  10320a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10320d:	83 c4 20             	add    $0x20,%esp
  103210:	5e                   	pop    %esi
  103211:	5f                   	pop    %edi
  103212:	5d                   	pop    %ebp
  103213:	c3                   	ret    

00103214 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  103214:	55                   	push   %ebp
  103215:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  103217:	eb 0c                	jmp    103225 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  103219:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10321d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103221:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  103225:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103229:	74 1a                	je     103245 <strncmp+0x31>
  10322b:	8b 45 08             	mov    0x8(%ebp),%eax
  10322e:	0f b6 00             	movzbl (%eax),%eax
  103231:	84 c0                	test   %al,%al
  103233:	74 10                	je     103245 <strncmp+0x31>
  103235:	8b 45 08             	mov    0x8(%ebp),%eax
  103238:	0f b6 10             	movzbl (%eax),%edx
  10323b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10323e:	0f b6 00             	movzbl (%eax),%eax
  103241:	38 c2                	cmp    %al,%dl
  103243:	74 d4                	je     103219 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  103245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103249:	74 18                	je     103263 <strncmp+0x4f>
  10324b:	8b 45 08             	mov    0x8(%ebp),%eax
  10324e:	0f b6 00             	movzbl (%eax),%eax
  103251:	0f b6 d0             	movzbl %al,%edx
  103254:	8b 45 0c             	mov    0xc(%ebp),%eax
  103257:	0f b6 00             	movzbl (%eax),%eax
  10325a:	0f b6 c0             	movzbl %al,%eax
  10325d:	29 c2                	sub    %eax,%edx
  10325f:	89 d0                	mov    %edx,%eax
  103261:	eb 05                	jmp    103268 <strncmp+0x54>
  103263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103268:	5d                   	pop    %ebp
  103269:	c3                   	ret    

0010326a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10326a:	55                   	push   %ebp
  10326b:	89 e5                	mov    %esp,%ebp
  10326d:	83 ec 04             	sub    $0x4,%esp
  103270:	8b 45 0c             	mov    0xc(%ebp),%eax
  103273:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103276:	eb 14                	jmp    10328c <strchr+0x22>
        if (*s == c) {
  103278:	8b 45 08             	mov    0x8(%ebp),%eax
  10327b:	0f b6 00             	movzbl (%eax),%eax
  10327e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  103281:	75 05                	jne    103288 <strchr+0x1e>
            return (char *)s;
  103283:	8b 45 08             	mov    0x8(%ebp),%eax
  103286:	eb 13                	jmp    10329b <strchr+0x31>
        }
        s ++;
  103288:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  10328c:	8b 45 08             	mov    0x8(%ebp),%eax
  10328f:	0f b6 00             	movzbl (%eax),%eax
  103292:	84 c0                	test   %al,%al
  103294:	75 e2                	jne    103278 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  103296:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10329b:	c9                   	leave  
  10329c:	c3                   	ret    

0010329d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10329d:	55                   	push   %ebp
  10329e:	89 e5                	mov    %esp,%ebp
  1032a0:	83 ec 04             	sub    $0x4,%esp
  1032a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032a6:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1032a9:	eb 11                	jmp    1032bc <strfind+0x1f>
        if (*s == c) {
  1032ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ae:	0f b6 00             	movzbl (%eax),%eax
  1032b1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1032b4:	75 02                	jne    1032b8 <strfind+0x1b>
            break;
  1032b6:	eb 0e                	jmp    1032c6 <strfind+0x29>
        }
        s ++;
  1032b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  1032bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1032bf:	0f b6 00             	movzbl (%eax),%eax
  1032c2:	84 c0                	test   %al,%al
  1032c4:	75 e5                	jne    1032ab <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  1032c6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1032c9:	c9                   	leave  
  1032ca:	c3                   	ret    

001032cb <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1032cb:	55                   	push   %ebp
  1032cc:	89 e5                	mov    %esp,%ebp
  1032ce:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1032d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1032d8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1032df:	eb 04                	jmp    1032e5 <strtol+0x1a>
        s ++;
  1032e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1032e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1032e8:	0f b6 00             	movzbl (%eax),%eax
  1032eb:	3c 20                	cmp    $0x20,%al
  1032ed:	74 f2                	je     1032e1 <strtol+0x16>
  1032ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f2:	0f b6 00             	movzbl (%eax),%eax
  1032f5:	3c 09                	cmp    $0x9,%al
  1032f7:	74 e8                	je     1032e1 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  1032f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1032fc:	0f b6 00             	movzbl (%eax),%eax
  1032ff:	3c 2b                	cmp    $0x2b,%al
  103301:	75 06                	jne    103309 <strtol+0x3e>
        s ++;
  103303:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103307:	eb 15                	jmp    10331e <strtol+0x53>
    }
    else if (*s == '-') {
  103309:	8b 45 08             	mov    0x8(%ebp),%eax
  10330c:	0f b6 00             	movzbl (%eax),%eax
  10330f:	3c 2d                	cmp    $0x2d,%al
  103311:	75 0b                	jne    10331e <strtol+0x53>
        s ++, neg = 1;
  103313:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103317:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  10331e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103322:	74 06                	je     10332a <strtol+0x5f>
  103324:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  103328:	75 24                	jne    10334e <strtol+0x83>
  10332a:	8b 45 08             	mov    0x8(%ebp),%eax
  10332d:	0f b6 00             	movzbl (%eax),%eax
  103330:	3c 30                	cmp    $0x30,%al
  103332:	75 1a                	jne    10334e <strtol+0x83>
  103334:	8b 45 08             	mov    0x8(%ebp),%eax
  103337:	83 c0 01             	add    $0x1,%eax
  10333a:	0f b6 00             	movzbl (%eax),%eax
  10333d:	3c 78                	cmp    $0x78,%al
  10333f:	75 0d                	jne    10334e <strtol+0x83>
        s += 2, base = 16;
  103341:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  103345:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  10334c:	eb 2a                	jmp    103378 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  10334e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103352:	75 17                	jne    10336b <strtol+0xa0>
  103354:	8b 45 08             	mov    0x8(%ebp),%eax
  103357:	0f b6 00             	movzbl (%eax),%eax
  10335a:	3c 30                	cmp    $0x30,%al
  10335c:	75 0d                	jne    10336b <strtol+0xa0>
        s ++, base = 8;
  10335e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103362:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  103369:	eb 0d                	jmp    103378 <strtol+0xad>
    }
    else if (base == 0) {
  10336b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10336f:	75 07                	jne    103378 <strtol+0xad>
        base = 10;
  103371:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  103378:	8b 45 08             	mov    0x8(%ebp),%eax
  10337b:	0f b6 00             	movzbl (%eax),%eax
  10337e:	3c 2f                	cmp    $0x2f,%al
  103380:	7e 1b                	jle    10339d <strtol+0xd2>
  103382:	8b 45 08             	mov    0x8(%ebp),%eax
  103385:	0f b6 00             	movzbl (%eax),%eax
  103388:	3c 39                	cmp    $0x39,%al
  10338a:	7f 11                	jg     10339d <strtol+0xd2>
            dig = *s - '0';
  10338c:	8b 45 08             	mov    0x8(%ebp),%eax
  10338f:	0f b6 00             	movzbl (%eax),%eax
  103392:	0f be c0             	movsbl %al,%eax
  103395:	83 e8 30             	sub    $0x30,%eax
  103398:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10339b:	eb 48                	jmp    1033e5 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  10339d:	8b 45 08             	mov    0x8(%ebp),%eax
  1033a0:	0f b6 00             	movzbl (%eax),%eax
  1033a3:	3c 60                	cmp    $0x60,%al
  1033a5:	7e 1b                	jle    1033c2 <strtol+0xf7>
  1033a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1033aa:	0f b6 00             	movzbl (%eax),%eax
  1033ad:	3c 7a                	cmp    $0x7a,%al
  1033af:	7f 11                	jg     1033c2 <strtol+0xf7>
            dig = *s - 'a' + 10;
  1033b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1033b4:	0f b6 00             	movzbl (%eax),%eax
  1033b7:	0f be c0             	movsbl %al,%eax
  1033ba:	83 e8 57             	sub    $0x57,%eax
  1033bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033c0:	eb 23                	jmp    1033e5 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1033c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1033c5:	0f b6 00             	movzbl (%eax),%eax
  1033c8:	3c 40                	cmp    $0x40,%al
  1033ca:	7e 3d                	jle    103409 <strtol+0x13e>
  1033cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1033cf:	0f b6 00             	movzbl (%eax),%eax
  1033d2:	3c 5a                	cmp    $0x5a,%al
  1033d4:	7f 33                	jg     103409 <strtol+0x13e>
            dig = *s - 'A' + 10;
  1033d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1033d9:	0f b6 00             	movzbl (%eax),%eax
  1033dc:	0f be c0             	movsbl %al,%eax
  1033df:	83 e8 37             	sub    $0x37,%eax
  1033e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1033e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033e8:	3b 45 10             	cmp    0x10(%ebp),%eax
  1033eb:	7c 02                	jl     1033ef <strtol+0x124>
            break;
  1033ed:	eb 1a                	jmp    103409 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  1033ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1033f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1033f6:	0f af 45 10          	imul   0x10(%ebp),%eax
  1033fa:	89 c2                	mov    %eax,%edx
  1033fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033ff:	01 d0                	add    %edx,%eax
  103401:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  103404:	e9 6f ff ff ff       	jmp    103378 <strtol+0xad>

    if (endptr) {
  103409:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10340d:	74 08                	je     103417 <strtol+0x14c>
        *endptr = (char *) s;
  10340f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103412:	8b 55 08             	mov    0x8(%ebp),%edx
  103415:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  103417:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10341b:	74 07                	je     103424 <strtol+0x159>
  10341d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103420:	f7 d8                	neg    %eax
  103422:	eb 03                	jmp    103427 <strtol+0x15c>
  103424:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  103427:	c9                   	leave  
  103428:	c3                   	ret    

00103429 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  103429:	55                   	push   %ebp
  10342a:	89 e5                	mov    %esp,%ebp
  10342c:	57                   	push   %edi
  10342d:	83 ec 24             	sub    $0x24,%esp
  103430:	8b 45 0c             	mov    0xc(%ebp),%eax
  103433:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  103436:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  10343a:	8b 55 08             	mov    0x8(%ebp),%edx
  10343d:	89 55 f8             	mov    %edx,-0x8(%ebp)
  103440:	88 45 f7             	mov    %al,-0x9(%ebp)
  103443:	8b 45 10             	mov    0x10(%ebp),%eax
  103446:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  103449:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10344c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  103450:	8b 55 f8             	mov    -0x8(%ebp),%edx
  103453:	89 d7                	mov    %edx,%edi
  103455:	f3 aa                	rep stos %al,%es:(%edi)
  103457:	89 fa                	mov    %edi,%edx
  103459:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10345c:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  10345f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  103462:	83 c4 24             	add    $0x24,%esp
  103465:	5f                   	pop    %edi
  103466:	5d                   	pop    %ebp
  103467:	c3                   	ret    

00103468 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  103468:	55                   	push   %ebp
  103469:	89 e5                	mov    %esp,%ebp
  10346b:	57                   	push   %edi
  10346c:	56                   	push   %esi
  10346d:	53                   	push   %ebx
  10346e:	83 ec 30             	sub    $0x30,%esp
  103471:	8b 45 08             	mov    0x8(%ebp),%eax
  103474:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103477:	8b 45 0c             	mov    0xc(%ebp),%eax
  10347a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10347d:	8b 45 10             	mov    0x10(%ebp),%eax
  103480:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  103483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103486:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103489:	73 42                	jae    1034cd <memmove+0x65>
  10348b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10348e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103491:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103494:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103497:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10349a:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10349d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1034a0:	c1 e8 02             	shr    $0x2,%eax
  1034a3:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1034a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1034a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034ab:	89 d7                	mov    %edx,%edi
  1034ad:	89 c6                	mov    %eax,%esi
  1034af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1034b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1034b4:	83 e1 03             	and    $0x3,%ecx
  1034b7:	74 02                	je     1034bb <memmove+0x53>
  1034b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1034bb:	89 f0                	mov    %esi,%eax
  1034bd:	89 fa                	mov    %edi,%edx
  1034bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1034c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1034c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  1034c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034cb:	eb 36                	jmp    103503 <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1034cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034d0:	8d 50 ff             	lea    -0x1(%eax),%edx
  1034d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034d6:	01 c2                	add    %eax,%edx
  1034d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034db:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1034de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034e1:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  1034e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034e7:	89 c1                	mov    %eax,%ecx
  1034e9:	89 d8                	mov    %ebx,%eax
  1034eb:	89 d6                	mov    %edx,%esi
  1034ed:	89 c7                	mov    %eax,%edi
  1034ef:	fd                   	std    
  1034f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1034f2:	fc                   	cld    
  1034f3:	89 f8                	mov    %edi,%eax
  1034f5:	89 f2                	mov    %esi,%edx
  1034f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1034fa:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1034fd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  103500:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  103503:	83 c4 30             	add    $0x30,%esp
  103506:	5b                   	pop    %ebx
  103507:	5e                   	pop    %esi
  103508:	5f                   	pop    %edi
  103509:	5d                   	pop    %ebp
  10350a:	c3                   	ret    

0010350b <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10350b:	55                   	push   %ebp
  10350c:	89 e5                	mov    %esp,%ebp
  10350e:	57                   	push   %edi
  10350f:	56                   	push   %esi
  103510:	83 ec 20             	sub    $0x20,%esp
  103513:	8b 45 08             	mov    0x8(%ebp),%eax
  103516:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103519:	8b 45 0c             	mov    0xc(%ebp),%eax
  10351c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10351f:	8b 45 10             	mov    0x10(%ebp),%eax
  103522:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  103525:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103528:	c1 e8 02             	shr    $0x2,%eax
  10352b:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  10352d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103533:	89 d7                	mov    %edx,%edi
  103535:	89 c6                	mov    %eax,%esi
  103537:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103539:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10353c:	83 e1 03             	and    $0x3,%ecx
  10353f:	74 02                	je     103543 <memcpy+0x38>
  103541:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103543:	89 f0                	mov    %esi,%eax
  103545:	89 fa                	mov    %edi,%edx
  103547:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10354a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10354d:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  103550:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  103553:	83 c4 20             	add    $0x20,%esp
  103556:	5e                   	pop    %esi
  103557:	5f                   	pop    %edi
  103558:	5d                   	pop    %ebp
  103559:	c3                   	ret    

0010355a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10355a:	55                   	push   %ebp
  10355b:	89 e5                	mov    %esp,%ebp
  10355d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  103560:	8b 45 08             	mov    0x8(%ebp),%eax
  103563:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  103566:	8b 45 0c             	mov    0xc(%ebp),%eax
  103569:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10356c:	eb 30                	jmp    10359e <memcmp+0x44>
        if (*s1 != *s2) {
  10356e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103571:	0f b6 10             	movzbl (%eax),%edx
  103574:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103577:	0f b6 00             	movzbl (%eax),%eax
  10357a:	38 c2                	cmp    %al,%dl
  10357c:	74 18                	je     103596 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  10357e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103581:	0f b6 00             	movzbl (%eax),%eax
  103584:	0f b6 d0             	movzbl %al,%edx
  103587:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10358a:	0f b6 00             	movzbl (%eax),%eax
  10358d:	0f b6 c0             	movzbl %al,%eax
  103590:	29 c2                	sub    %eax,%edx
  103592:	89 d0                	mov    %edx,%eax
  103594:	eb 1a                	jmp    1035b0 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  103596:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10359a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  10359e:	8b 45 10             	mov    0x10(%ebp),%eax
  1035a1:	8d 50 ff             	lea    -0x1(%eax),%edx
  1035a4:	89 55 10             	mov    %edx,0x10(%ebp)
  1035a7:	85 c0                	test   %eax,%eax
  1035a9:	75 c3                	jne    10356e <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  1035ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1035b0:	c9                   	leave  
  1035b1:	c3                   	ret    
