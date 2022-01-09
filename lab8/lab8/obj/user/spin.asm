
obj/__user_spin.out:     file format elf32-i386


Disassembly of section .text:

00800020 <opendir>:
#include <error.h>
#include <unistd.h>

DIR dir, *dirp=&dir;
DIR *
opendir(const char *path) {
  800020:	55                   	push   %ebp
  800021:	89 e5                	mov    %esp,%ebp
  800023:	53                   	push   %ebx
  800024:	83 ec 34             	sub    $0x34,%esp

    if ((dirp->fd = open(path, O_RDONLY)) < 0) {
  800027:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80002d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800034:	00 
  800035:	8b 45 08             	mov    0x8(%ebp),%eax
  800038:	89 04 24             	mov    %eax,(%esp)
  80003b:	e8 b8 00 00 00       	call   8000f8 <open>
  800040:	89 03                	mov    %eax,(%ebx)
  800042:	8b 03                	mov    (%ebx),%eax
  800044:	85 c0                	test   %eax,%eax
  800046:	79 02                	jns    80004a <opendir+0x2a>
        goto failed;
  800048:	eb 44                	jmp    80008e <opendir+0x6e>
    }
    struct stat __stat, *stat = &__stat;
  80004a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80004d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (fstat(dirp->fd, stat) != 0 || !S_ISDIR(stat->st_mode)) {
  800050:	a1 00 20 80 00       	mov    0x802000,%eax
  800055:	8b 00                	mov    (%eax),%eax
  800057:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80005a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 22 01 00 00       	call   800188 <fstat>
  800066:	85 c0                	test   %eax,%eax
  800068:	75 24                	jne    80008e <opendir+0x6e>
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	8b 00                	mov    (%eax),%eax
  80006f:	25 00 70 00 00       	and    $0x7000,%eax
  800074:	3d 00 20 00 00       	cmp    $0x2000,%eax
  800079:	75 13                	jne    80008e <opendir+0x6e>
        goto failed;
    }
    dirp->dirent.offset = 0;
  80007b:	a1 00 20 80 00       	mov    0x802000,%eax
  800080:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    return dirp;
  800087:	a1 00 20 80 00       	mov    0x802000,%eax
  80008c:	eb 05                	jmp    800093 <opendir+0x73>

failed:
    return NULL;
  80008e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800093:	83 c4 34             	add    $0x34,%esp
  800096:	5b                   	pop    %ebx
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <readdir>:

struct dirent *
readdir(DIR *dirp) {
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 18             	sub    $0x18,%esp
    if (sys_getdirentry(dirp->fd, &(dirp->dirent)) == 0) {
  80009f:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a2:	8d 50 04             	lea    0x4(%eax),%edx
  8000a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a8:	8b 00                	mov    (%eax),%eax
  8000aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000ae:	89 04 24             	mov    %eax,(%esp)
  8000b1:	e8 db 06 00 00       	call   800791 <sys_getdirentry>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	75 08                	jne    8000c2 <readdir+0x29>
        return &(dirp->dirent);
  8000ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8000bd:	83 c0 04             	add    $0x4,%eax
  8000c0:	eb 05                	jmp    8000c7 <readdir+0x2e>
    }
    return NULL;
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <closedir>:

void
closedir(DIR *dirp) {
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 18             	sub    $0x18,%esp
    close(dirp->fd);
  8000cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d2:	8b 00                	mov    (%eax),%eax
  8000d4:	89 04 24             	mov    %eax,(%esp)
  8000d7:	e8 36 00 00 00       	call   800112 <close>
}
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <getcwd>:

int
getcwd(char *buffer, size_t len) {
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	83 ec 18             	sub    $0x18,%esp
    return sys_getcwd(buffer, len);
  8000e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 79 06 00 00       	call   80076f <sys_getcwd>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <open>:
#include <stat.h>
#include <error.h>
#include <unistd.h>

int
open(const char *path, uint32_t open_flags) {
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
    return sys_open(path, open_flags);
  8000fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800101:	89 44 24 04          	mov    %eax,0x4(%esp)
  800105:	8b 45 08             	mov    0x8(%ebp),%eax
  800108:	89 04 24             	mov    %eax,(%esp)
  80010b:	e8 6a 05 00 00       	call   80067a <sys_open>
}
  800110:	c9                   	leave  
  800111:	c3                   	ret    

00800112 <close>:

int
close(int fd) {
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	83 ec 18             	sub    $0x18,%esp
    return sys_close(fd);
  800118:	8b 45 08             	mov    0x8(%ebp),%eax
  80011b:	89 04 24             	mov    %eax,(%esp)
  80011e:	e8 79 05 00 00       	call   80069c <sys_close>
}
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <read>:

int
read(int fd, void *base, size_t len) {
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 18             	sub    $0x18,%esp
    return sys_read(fd, base, len);
  80012b:	8b 45 10             	mov    0x10(%ebp),%eax
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	8b 45 0c             	mov    0xc(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	8b 45 08             	mov    0x8(%ebp),%eax
  80013c:	89 04 24             	mov    %eax,(%esp)
  80013f:	e8 73 05 00 00       	call   8006b7 <sys_read>
}
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <write>:

int
write(int fd, void *base, size_t len) {
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 18             	sub    $0x18,%esp
    return sys_write(fd, base, len);
  80014c:	8b 45 10             	mov    0x10(%ebp),%eax
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	8b 45 0c             	mov    0xc(%ebp),%eax
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	89 04 24             	mov    %eax,(%esp)
  800160:	e8 7b 05 00 00       	call   8006e0 <sys_write>
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <seek>:

int
seek(int fd, off_t pos, int whence) {
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 18             	sub    $0x18,%esp
    return sys_seek(fd, pos, whence);
  80016d:	8b 45 10             	mov    0x10(%ebp),%eax
  800170:	89 44 24 08          	mov    %eax,0x8(%esp)
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	89 04 24             	mov    %eax,(%esp)
  800181:	e8 83 05 00 00       	call   800709 <sys_seek>
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <fstat>:

int
fstat(int fd, struct stat *stat) {
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
    return sys_fstat(fd, stat);
  80018e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	8b 45 08             	mov    0x8(%ebp),%eax
  800198:	89 04 24             	mov    %eax,(%esp)
  80019b:	e8 92 05 00 00       	call   800732 <sys_fstat>
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <fsync>:

int
fsync(int fd) {
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 18             	sub    $0x18,%esp
    return sys_fsync(fd);
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 a1 05 00 00       	call   800754 <sys_fsync>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <dup2>:

int
dup2(int fd1, int fd2) {
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	83 ec 18             	sub    $0x18,%esp
    return sys_dup(fd1, fd2);
  8001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 04 24             	mov    %eax,(%esp)
  8001c8:	e8 e6 05 00 00       	call   8007b3 <sys_dup>
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <transmode>:

static char
transmode(struct stat *stat) {
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 10             	sub    $0x10,%esp
    uint32_t mode = stat->st_mode;
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 00                	mov    (%eax),%eax
  8001da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (S_ISREG(mode)) return 'r';
  8001dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8001e0:	25 00 70 00 00       	and    $0x7000,%eax
  8001e5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8001ea:	75 07                	jne    8001f3 <transmode+0x24>
  8001ec:	b8 72 00 00 00       	mov    $0x72,%eax
  8001f1:	eb 5d                	jmp    800250 <transmode+0x81>
    if (S_ISDIR(mode)) return 'd';
  8001f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8001f6:	25 00 70 00 00       	and    $0x7000,%eax
  8001fb:	3d 00 20 00 00       	cmp    $0x2000,%eax
  800200:	75 07                	jne    800209 <transmode+0x3a>
  800202:	b8 64 00 00 00       	mov    $0x64,%eax
  800207:	eb 47                	jmp    800250 <transmode+0x81>
    if (S_ISLNK(mode)) return 'l';
  800209:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80020c:	25 00 70 00 00       	and    $0x7000,%eax
  800211:	3d 00 30 00 00       	cmp    $0x3000,%eax
  800216:	75 07                	jne    80021f <transmode+0x50>
  800218:	b8 6c 00 00 00       	mov    $0x6c,%eax
  80021d:	eb 31                	jmp    800250 <transmode+0x81>
    if (S_ISCHR(mode)) return 'c';
  80021f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800222:	25 00 70 00 00       	and    $0x7000,%eax
  800227:	3d 00 40 00 00       	cmp    $0x4000,%eax
  80022c:	75 07                	jne    800235 <transmode+0x66>
  80022e:	b8 63 00 00 00       	mov    $0x63,%eax
  800233:	eb 1b                	jmp    800250 <transmode+0x81>
    if (S_ISBLK(mode)) return 'b';
  800235:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800238:	25 00 70 00 00       	and    $0x7000,%eax
  80023d:	3d 00 50 00 00       	cmp    $0x5000,%eax
  800242:	75 07                	jne    80024b <transmode+0x7c>
  800244:	b8 62 00 00 00       	mov    $0x62,%eax
  800249:	eb 05                	jmp    800250 <transmode+0x81>
    return '-';
  80024b:	b8 2d 00 00 00       	mov    $0x2d,%eax
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <print_stat>:

void
print_stat(const char *name, int fd, struct stat *stat) {
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 18             	sub    $0x18,%esp
    cprintf("[%03d] %s\n", fd, name);
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800262:	89 44 24 04          	mov    %eax,0x4(%esp)
  800266:	c7 04 24 c0 18 80 00 	movl   $0x8018c0,(%esp)
  80026d:	e8 6b 01 00 00       	call   8003dd <cprintf>
    cprintf("    mode    : %c\n", transmode(stat));
  800272:	8b 45 10             	mov    0x10(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	e8 52 ff ff ff       	call   8001cf <transmode>
  80027d:	0f be c0             	movsbl %al,%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 cb 18 80 00 	movl   $0x8018cb,(%esp)
  80028b:	e8 4d 01 00 00       	call   8003dd <cprintf>
    cprintf("    links   : %lu\n", stat->st_nlinks);
  800290:	8b 45 10             	mov    0x10(%ebp),%eax
  800293:	8b 40 04             	mov    0x4(%eax),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	c7 04 24 dd 18 80 00 	movl   $0x8018dd,(%esp)
  8002a1:	e8 37 01 00 00       	call   8003dd <cprintf>
    cprintf("    blocks  : %lu\n", stat->st_blocks);
  8002a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a9:	8b 40 08             	mov    0x8(%eax),%eax
  8002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b0:	c7 04 24 f0 18 80 00 	movl   $0x8018f0,(%esp)
  8002b7:	e8 21 01 00 00       	call   8003dd <cprintf>
    cprintf("    size    : %lu\n", stat->st_size);
  8002bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8002c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c6:	c7 04 24 03 19 80 00 	movl   $0x801903,(%esp)
  8002cd:	e8 0b 01 00 00       	call   8003dd <cprintf>
}
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  8002d4:	bd 00 00 00 00       	mov    $0x0,%ebp

    # load argc and argv
    movl (%esp), %ebx
  8002d9:	8b 1c 24             	mov    (%esp),%ebx
    lea 0x4(%esp), %ecx
  8002dc:	8d 4c 24 04          	lea    0x4(%esp),%ecx


    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  8002e0:	83 ec 20             	sub    $0x20,%esp

    # save argc and argv on stack
    pushl %ecx
  8002e3:	51                   	push   %ecx
    pushl %ebx
  8002e4:	53                   	push   %ebx

    # call user-program function
    call umain
  8002e5:	e8 26 07 00 00       	call   800a10 <umain>
1:  jmp 1b
  8002ea:	eb fe                	jmp    8002ea <_start+0x16>

008002ec <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  8002f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8002f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	89 44 24 04          	mov    %eax,0x4(%esp)
  800306:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  80030d:	e8 cb 00 00 00       	call   8003dd <cprintf>
    vcprintf(fmt, ap);
  800312:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800315:	89 44 24 04          	mov    %eax,0x4(%esp)
  800319:	8b 45 10             	mov    0x10(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	e8 7e 00 00 00       	call   8003a2 <vcprintf>
    cprintf("\n");
  800324:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  80032b:	e8 ad 00 00 00       	call   8003dd <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800330:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  800337:	e8 64 05 00 00       	call   8008a0 <exit>

0080033c <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  800342:	8d 45 14             	lea    0x14(%ebp),%eax
  800345:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  800348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034f:	8b 45 08             	mov    0x8(%ebp),%eax
  800352:	89 44 24 04          	mov    %eax,0x4(%esp)
  800356:	c7 04 24 32 19 80 00 	movl   $0x801932,(%esp)
  80035d:	e8 7b 00 00 00       	call   8003dd <cprintf>
    vcprintf(fmt, ap);
  800362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	e8 2e 00 00 00       	call   8003a2 <vcprintf>
    cprintf("\n");
  800374:	c7 04 24 30 19 80 00 	movl   $0x801930,(%esp)
  80037b:	e8 5d 00 00 00       	call   8003dd <cprintf>
    va_end(ap);
}
  800380:	c9                   	leave  
  800381:	c3                   	ret    

00800382 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	89 04 24             	mov    %eax,(%esp)
  80038e:	e8 45 02 00 00       	call   8005d8 <sys_putc>
    (*cnt) ++;
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
  800396:	8b 00                	mov    (%eax),%eax
  800398:	8d 50 01             	lea    0x1(%eax),%edx
  80039b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039e:	89 10                	mov    %edx,(%eax)
}
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 38             	sub    $0x38,%esp
    int cnt = 0;
  8003a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, NO_FD, &cnt, fmt, ap);
  8003af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8003c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c4:	c7 44 24 04 d9 6a ff 	movl   $0xffff6ad9,0x4(%esp)
  8003cb:	ff 
  8003cc:	c7 04 24 82 03 80 00 	movl   $0x800382,(%esp)
  8003d3:	e8 f8 08 00 00       	call   800cd0 <vprintfmt>
    return cnt;
  8003d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8003db:	c9                   	leave  
  8003dc:	c3                   	ret    

008003dd <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8003e3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8003e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  8003e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f3:	89 04 24             	mov    %eax,(%esp)
  8003f6:	e8 a7 ff ff ff       	call   8003a2 <vcprintf>
  8003fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  8003fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  800409:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800410:	eb 13                	jmp    800425 <cputs+0x22>
        cputch(c, &cnt);
  800412:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800416:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800419:	89 54 24 04          	mov    %edx,0x4(%esp)
  80041d:	89 04 24             	mov    %eax,(%esp)
  800420:	e8 5d ff ff ff       	call   800382 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	8d 50 01             	lea    0x1(%eax),%edx
  80042b:	89 55 08             	mov    %edx,0x8(%ebp)
  80042e:	0f b6 00             	movzbl (%eax),%eax
  800431:	88 45 f7             	mov    %al,-0x9(%ebp)
  800434:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800438:	75 d8                	jne    800412 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  80043a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80043d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800441:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800448:	e8 35 ff ff ff       	call   800382 <cputch>
    return cnt;
  80044d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <fputch>:


static void
fputch(char c, int *cnt, int fd) {
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	83 ec 18             	sub    $0x18,%esp
  800458:	8b 45 08             	mov    0x8(%ebp),%eax
  80045b:	88 45 f4             	mov    %al,-0xc(%ebp)
    write(fd, &c, sizeof(char));
  80045e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800465:	00 
  800466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800469:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046d:	8b 45 10             	mov    0x10(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 ce fc ff ff       	call   800146 <write>
    (*cnt) ++;
  800478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	8d 50 01             	lea    0x1(%eax),%edx
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	89 10                	mov    %edx,(%eax)
}
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap) {
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	83 ec 38             	sub    $0x38,%esp
    int cnt = 0;
  80048d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)fputch, fd, &cnt, fmt, ap);
  800494:	8b 45 10             	mov    0x10(%ebp),%eax
  800497:	89 44 24 10          	mov    %eax,0x10(%esp)
  80049b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b0:	c7 04 24 52 04 80 00 	movl   $0x800452,(%esp)
  8004b7:	e8 14 08 00 00       	call   800cd0 <vprintfmt>
    return cnt;
  8004bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8004bf:	c9                   	leave  
  8004c0:	c3                   	ret    

008004c1 <fprintf>:

int
fprintf(int fd, const char *fmt, ...) {
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8004c7:	8d 45 10             	lea    0x10(%ebp),%eax
  8004ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vfprintf(fd, fmt, ap);
  8004cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	e8 a1 ff ff ff       	call   800487 <vfprintf>
  8004e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  8004e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <syscall>:


#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	57                   	push   %edi
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8004f7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8004fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8004fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800504:	eb 16                	jmp    80051c <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  800506:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80050f:	8b 10                	mov    (%eax),%edx
  800511:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800514:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  800518:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  80051c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  800520:	7e e4                	jle    800506 <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  800522:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  800525:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  800528:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  80052b:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  80052e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    asm volatile (
  800531:	8b 45 08             	mov    0x8(%ebp),%eax
  800534:	cd 80                	int    $0x80
  800536:	89 45 ec             	mov    %eax,-0x14(%ebp)
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
  800539:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  80053c:	83 c4 20             	add    $0x20,%esp
  80053f:	5b                   	pop    %ebx
  800540:	5e                   	pop    %esi
  800541:	5f                   	pop    %edi
  800542:	5d                   	pop    %ebp
  800543:	c3                   	ret    

00800544 <sys_exit>:

int
sys_exit(int error_code) {
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  80054a:	8b 45 08             	mov    0x8(%ebp),%eax
  80054d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800551:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800558:	e8 91 ff ff ff       	call   8004ee <syscall>
}
  80055d:	c9                   	leave  
  80055e:	c3                   	ret    

0080055f <sys_fork>:

int
sys_fork(void) {
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  800565:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80056c:	e8 7d ff ff ff       	call   8004ee <syscall>
}
  800571:	c9                   	leave  
  800572:	c3                   	ret    

00800573 <sys_wait>:

int
sys_wait(int pid, int *store) {
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  800579:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800580:	8b 45 08             	mov    0x8(%ebp),%eax
  800583:	89 44 24 04          	mov    %eax,0x4(%esp)
  800587:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80058e:	e8 5b ff ff ff       	call   8004ee <syscall>
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <sys_yield>:

int
sys_yield(void) {
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  80059b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8005a2:	e8 47 ff ff ff       	call   8004ee <syscall>
}
  8005a7:	c9                   	leave  
  8005a8:	c3                   	ret    

008005a9 <sys_kill>:

int
sys_kill(int pid) {
  8005a9:	55                   	push   %ebp
  8005aa:	89 e5                	mov    %esp,%ebp
  8005ac:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  8005af:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b6:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8005bd:	e8 2c ff ff ff       	call   8004ee <syscall>
}
  8005c2:	c9                   	leave  
  8005c3:	c3                   	ret    

008005c4 <sys_getpid>:

int
sys_getpid(void) {
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  8005ca:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  8005d1:	e8 18 ff ff ff       	call   8004ee <syscall>
}
  8005d6:	c9                   	leave  
  8005d7:	c3                   	ret    

008005d8 <sys_putc>:

int
sys_putc(int c) {
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  8005ec:	e8 fd fe ff ff       	call   8004ee <syscall>
}
  8005f1:	c9                   	leave  
  8005f2:	c3                   	ret    

008005f3 <sys_pgdir>:

int
sys_pgdir(void) {
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  8005f9:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  800600:	e8 e9 fe ff ff       	call   8004ee <syscall>
}
  800605:	c9                   	leave  
  800606:	c3                   	ret    

00800607 <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	83 ec 08             	sub    $0x8,%esp
    syscall(SYS_lab6_set_priority, priority);
  80060d:	8b 45 08             	mov    0x8(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	c7 04 24 ff 00 00 00 	movl   $0xff,(%esp)
  80061b:	e8 ce fe ff ff       	call   8004ee <syscall>
}
  800620:	c9                   	leave  
  800621:	c3                   	ret    

00800622 <sys_sleep>:

int
sys_sleep(unsigned int time) {
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_sleep, time);
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062f:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  800636:	e8 b3 fe ff ff       	call   8004ee <syscall>
}
  80063b:	c9                   	leave  
  80063c:	c3                   	ret    

0080063d <sys_gettime>:

size_t
sys_gettime(void) {
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_gettime);
  800643:	c7 04 24 11 00 00 00 	movl   $0x11,(%esp)
  80064a:	e8 9f fe ff ff       	call   8004ee <syscall>
}
  80064f:	c9                   	leave  
  800650:	c3                   	ret    

00800651 <sys_exec>:

int
sys_exec(const char *name, int argc, const char **argv) {
  800651:	55                   	push   %ebp
  800652:	89 e5                	mov    %esp,%ebp
  800654:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_exec, name, argc, argv);
  800657:	8b 45 10             	mov    0x10(%ebp),%eax
  80065a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800661:	89 44 24 08          	mov    %eax,0x8(%esp)
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800673:	e8 76 fe ff ff       	call   8004ee <syscall>
}
  800678:	c9                   	leave  
  800679:	c3                   	ret    

0080067a <sys_open>:

int
sys_open(const char *path, uint32_t open_flags) {
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_open, path, open_flags);
  800680:	8b 45 0c             	mov    0xc(%ebp),%eax
  800683:	89 44 24 08          	mov    %eax,0x8(%esp)
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  800695:	e8 54 fe ff ff       	call   8004ee <syscall>
}
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <sys_close>:

int
sys_close(int fd) {
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_close, fd);
  8006a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a9:	c7 04 24 65 00 00 00 	movl   $0x65,(%esp)
  8006b0:	e8 39 fe ff ff       	call   8004ee <syscall>
}
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <sys_read>:

int
sys_read(int fd, void *base, size_t len) {
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_read, fd, base, len);
  8006bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d2:	c7 04 24 66 00 00 00 	movl   $0x66,(%esp)
  8006d9:	e8 10 fe ff ff       	call   8004ee <syscall>
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <sys_write>:

int
sys_write(int fd, void *base, size_t len) {
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_write, fd, base, len);
  8006e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fb:	c7 04 24 67 00 00 00 	movl   $0x67,(%esp)
  800702:	e8 e7 fd ff ff       	call   8004ee <syscall>
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <sys_seek>:

int
sys_seek(int fd, off_t pos, int whence) {
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	83 ec 10             	sub    $0x10,%esp
    return syscall(SYS_seek, fd, pos, whence);
  80070f:	8b 45 10             	mov    0x10(%ebp),%eax
  800712:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800716:	8b 45 0c             	mov    0xc(%ebp),%eax
  800719:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	89 44 24 04          	mov    %eax,0x4(%esp)
  800724:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
  80072b:	e8 be fd ff ff       	call   8004ee <syscall>
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <sys_fstat>:

int
sys_fstat(int fd, struct stat *stat) {
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_fstat, fd, stat);
  800738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	c7 04 24 6e 00 00 00 	movl   $0x6e,(%esp)
  80074d:	e8 9c fd ff ff       	call   8004ee <syscall>
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <sys_fsync>:

int
sys_fsync(int fd) {
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_fsync, fd);
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800761:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
  800768:	e8 81 fd ff ff       	call   8004ee <syscall>
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <sys_getcwd>:

int
sys_getcwd(char *buffer, size_t len) {
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_getcwd, buffer, len);
  800775:	8b 45 0c             	mov    0xc(%ebp),%eax
  800778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800783:	c7 04 24 79 00 00 00 	movl   $0x79,(%esp)
  80078a:	e8 5f fd ff ff       	call   8004ee <syscall>
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <sys_getdirentry>:

int
sys_getdirentry(int fd, struct dirent *dirent) {
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_getdirentry, fd, dirent);
  800797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a5:	c7 04 24 80 00 00 00 	movl   $0x80,(%esp)
  8007ac:	e8 3d fd ff ff       	call   8004ee <syscall>
}
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    

008007b3 <sys_dup>:

int
sys_dup(int fd1, int fd2) {
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_dup, fd1, fd2);
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c7:	c7 04 24 82 00 00 00 	movl   $0x82,(%esp)
  8007ce:	e8 1b fd ff ff       	call   8004ee <syscall>
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <try_lock>:
lock_init(lock_t *l) {
    *l = 0;
}

static inline bool
try_lock(lock_t *l) {
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 10             	sub    $0x10,%esp
  8007db:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  8007e8:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ee:	0f ab 02             	bts    %eax,(%edx)
  8007f1:	19 c0                	sbb    %eax,%eax
  8007f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  8007f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8007fa:	0f 95 c0             	setne  %al
  8007fd:	0f b6 c0             	movzbl %al,%eax
    return test_and_set_bit(0, l);
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <lock>:

static inline void
lock(lock_t *l) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 28             	sub    $0x28,%esp
    if (try_lock(l)) {
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	89 04 24             	mov    %eax,(%esp)
  80080e:	e8 c2 ff ff ff       	call   8007d5 <try_lock>
  800813:	85 c0                	test   %eax,%eax
  800815:	74 38                	je     80084f <lock+0x4d>
        int step = 0;
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        do {
            yield();
  80081e:	e8 df 00 00 00       	call   800902 <yield>
            if (++ step == 100) {
  800823:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800827:	83 7d f4 64          	cmpl   $0x64,-0xc(%ebp)
  80082b:	75 13                	jne    800840 <lock+0x3e>
                step = 0;
  80082d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
                sleep(10);
  800834:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80083b:	e8 0f 01 00 00       	call   80094f <sleep>
            }
        } while (try_lock(l));
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 8a ff ff ff       	call   8007d5 <try_lock>
  80084b:	85 c0                	test   %eax,%eax
  80084d:	75 cf                	jne    80081e <lock+0x1c>
    }
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <unlock>:

static inline void
unlock(lock_t *l) {
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 10             	sub    $0x10,%esp
  800857:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  800864:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800867:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80086a:	0f b3 02             	btr    %eax,(%edx)
  80086d:	19 c0                	sbb    %eax,%eax
  80086f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  800872:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    test_and_clear_bit(0, l);
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <lock_fork>:
#include <lock.h>

static lock_t fork_lock = INIT_LOCK;

void
lock_fork(void) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 18             	sub    $0x18,%esp
    lock(&fork_lock);
  80087e:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  800885:	e8 78 ff ff ff       	call   800802 <lock>
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <unlock_fork>:

void
unlock_fork(void) {
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 04             	sub    $0x4,%esp
    unlock(&fork_lock);
  800892:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  800899:	e8 b3 ff ff ff       	call   800851 <unlock>
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <exit>:

void
exit(int error_code) {
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	89 04 24             	mov    %eax,(%esp)
  8008ac:	e8 93 fc ff ff       	call   800544 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8008b1:	c7 04 24 4e 19 80 00 	movl   $0x80194e,(%esp)
  8008b8:	e8 20 fb ff ff       	call   8003dd <cprintf>
    while (1);
  8008bd:	eb fe                	jmp    8008bd <exit+0x1d>

008008bf <fork>:
}

int
fork(void) {
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8008c5:	e8 95 fc ff ff       	call   80055f <sys_fork>
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <wait>:

int
wait(void) {
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  8008d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8008d9:	00 
  8008da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008e1:	e8 8d fc ff ff       	call   800573 <sys_wait>
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <waitpid>:

int
waitpid(int pid, int *store) {
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  8008ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	89 04 24             	mov    %eax,(%esp)
  8008fb:	e8 73 fc ff ff       	call   800573 <sys_wait>
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <yield>:

void
yield(void) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800908:	e8 88 fc ff ff       	call   800595 <sys_yield>
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <kill>:

int
kill(int pid) {
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	89 04 24             	mov    %eax,(%esp)
  80091b:	e8 89 fc ff ff       	call   8005a9 <sys_kill>
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <getpid>:

int
getpid(void) {
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800928:	e8 97 fc ff ff       	call   8005c4 <sys_getpid>
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800935:	e8 b9 fc ff ff       	call   8005f3 <sys_pgdir>
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	89 04 24             	mov    %eax,(%esp)
  800948:	e8 ba fc ff ff       	call   800607 <sys_lab6_set_priority>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <sleep>:

int
sleep(unsigned int time) {
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 18             	sub    $0x18,%esp
    return sys_sleep(time);
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	89 04 24             	mov    %eax,(%esp)
  80095b:	e8 c2 fc ff ff       	call   800622 <sys_sleep>
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <gettime_msec>:

unsigned int
gettime_msec(void) {
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  800968:	e8 d0 fc ff ff       	call   80063d <sys_gettime>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <__exec>:

int
__exec(const char *name, const char **argv) {
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  800975:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (argv[argc] != NULL) {
  80097c:	eb 04                	jmp    800982 <__exec+0x13>
        argc ++;
  80097e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
}

int
__exec(const char *name, const char **argv) {
    int argc = 0;
    while (argv[argc] != NULL) {
  800982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800985:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	01 d0                	add    %edx,%eax
  800991:	8b 00                	mov    (%eax),%eax
  800993:	85 c0                	test   %eax,%eax
  800995:	75 e7                	jne    80097e <__exec+0xf>
        argc ++;
    }
    return sys_exec(name, argc, argv);
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	89 04 24             	mov    %eax,(%esp)
  8009ab:	e8 a1 fc ff ff       	call   800651 <sys_exec>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <initfd>:
#include <stat.h>

int main(int argc, char *argv[]);

static int
initfd(int fd2, const char *path, uint32_t open_flags) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 28             	sub    $0x28,%esp
    int fd1, ret;
    if ((fd1 = open(path, open_flags)) < 0) {
  8009b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	89 04 24             	mov    %eax,(%esp)
  8009c5:	e8 2e f7 ff ff       	call   8000f8 <open>
  8009ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009d1:	79 05                	jns    8009d8 <initfd+0x26>
        return fd1;
  8009d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009d6:	eb 36                	jmp    800a0e <initfd+0x5c>
    }
    if (fd1 != fd2) {
  8009d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009db:	3b 45 08             	cmp    0x8(%ebp),%eax
  8009de:	74 2b                	je     800a0b <initfd+0x59>
        close(fd2);
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	89 04 24             	mov    %eax,(%esp)
  8009e6:	e8 27 f7 ff ff       	call   800112 <close>
        ret = dup2(fd1, fd2);
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 b8 f7 ff ff       	call   8001b5 <dup2>
  8009fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        close(fd1);
  800a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 07 f7 ff ff       	call   800112 <close>
    }
    return ret;
  800a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <umain>:

void
umain(int argc, char *argv[]) {
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 28             	sub    $0x28,%esp
    int fd;
    if ((fd = initfd(0, "stdin:", O_RDONLY)) < 0) {
  800a16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a1d:	00 
  800a1e:	c7 44 24 04 61 19 80 	movl   $0x801961,0x4(%esp)
  800a25:	00 
  800a26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a2d:	e8 80 ff ff ff       	call   8009b2 <initfd>
  800a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800a39:	79 23                	jns    800a5e <umain+0x4e>
        warn("open <stdin> failed: %e.\n", fd);
  800a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a42:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  800a49:	00 
  800a4a:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800a51:	00 
  800a52:	c7 04 24 82 19 80 00 	movl   $0x801982,(%esp)
  800a59:	e8 de f8 ff ff       	call   80033c <__warn>
    }
    if ((fd = initfd(1, "stdout:", O_WRONLY)) < 0) {
  800a5e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800a65:	00 
  800a66:	c7 44 24 04 94 19 80 	movl   $0x801994,0x4(%esp)
  800a6d:	00 
  800a6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a75:	e8 38 ff ff ff       	call   8009b2 <initfd>
  800a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800a81:	79 23                	jns    800aa6 <umain+0x96>
        warn("open <stdout> failed: %e.\n", fd);
  800a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8a:	c7 44 24 08 9c 19 80 	movl   $0x80199c,0x8(%esp)
  800a91:	00 
  800a92:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800a99:	00 
  800a9a:	c7 04 24 82 19 80 00 	movl   $0x801982,(%esp)
  800aa1:	e8 96 f8 ff ff       	call   80033c <__warn>
    }
    int ret = main(argc, argv);
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	89 04 24             	mov    %eax,(%esp)
  800ab3:	e8 f1 0c 00 00       	call   8017a9 <main>
  800ab8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    exit(ret);
  800abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800abe:	89 04 24             	mov    %eax,(%esp)
  800ac1:	e8 da fd ff ff       	call   8008a0 <exit>

00800ac6 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800ad5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800ad8:	b8 20 00 00 00       	mov    $0x20,%eax
  800add:	2b 45 0c             	sub    0xc(%ebp),%eax
  800ae0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ae3:	89 c1                	mov    %eax,%ecx
  800ae5:	d3 ea                	shr    %cl,%edx
  800ae7:	89 d0                	mov    %edx,%eax
}
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    

00800aeb <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*, int), int fd, void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	83 ec 58             	sub    $0x58,%esp
  800af1:	8b 45 14             	mov    0x14(%ebp),%eax
  800af4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800af7:	8b 45 18             	mov    0x18(%ebp),%eax
  800afa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800afd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b00:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b03:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b06:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800b09:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b12:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b15:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b18:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800b21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b25:	74 1c                	je     800b43 <printnum+0x58>
  800b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	f7 75 e4             	divl   -0x1c(%ebp)
  800b32:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	f7 75 e4             	divl   -0x1c(%ebp)
  800b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b43:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b49:	f7 75 e4             	divl   -0x1c(%ebp)
  800b4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b4f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b52:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b55:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b58:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b5b:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800b5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b61:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800b64:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800b6f:	77 64                	ja     800bd5 <printnum+0xea>
  800b71:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800b74:	72 05                	jb     800b7b <printnum+0x90>
  800b76:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  800b79:	77 5a                	ja     800bd5 <printnum+0xea>
        printnum(putch, fd, putdat, result, base, width - 1, padc);
  800b7b:	8b 45 20             	mov    0x20(%ebp),%eax
  800b7e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b81:	8b 45 24             	mov    0x24(%ebp),%eax
  800b84:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800b88:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b8c:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b8f:	89 44 24 14          	mov    %eax,0x14(%esp)
  800b93:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b96:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	89 04 24             	mov    %eax,(%esp)
  800bb5:	e8 31 ff ff ff       	call   800aeb <printnum>
  800bba:	eb 23                	jmp    800bdf <printnum+0xf4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat, fd);
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bca:	8b 45 24             	mov    0x24(%ebp),%eax
  800bcd:	89 04 24             	mov    %eax,(%esp)
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd3:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, fd, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800bd5:	83 6d 20 01          	subl   $0x1,0x20(%ebp)
  800bd9:	83 7d 20 00          	cmpl   $0x0,0x20(%ebp)
  800bdd:	7f dd                	jg     800bbc <printnum+0xd1>
            putch(padc, putdat, fd);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat, fd);
  800bdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800be2:	05 c4 1b 80 00       	add    $0x801bc4,%eax
  800be7:	0f b6 00             	movzbl (%eax),%eax
  800bea:	0f be c0             	movsbl %al,%eax
  800bed:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf0:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bf4:	8b 55 10             	mov    0x10(%ebp),%edx
  800bf7:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bfb:	89 04 24             	mov    %eax,(%esp)
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	ff d0                	call   *%eax
}
  800c03:	c9                   	leave  
  800c04:	c3                   	ret    

00800c05 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800c08:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c0c:	7e 14                	jle    800c22 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	8b 00                	mov    (%eax),%eax
  800c13:	8d 48 08             	lea    0x8(%eax),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 0a                	mov    %ecx,(%edx)
  800c1b:	8b 50 04             	mov    0x4(%eax),%edx
  800c1e:	8b 00                	mov    (%eax),%eax
  800c20:	eb 30                	jmp    800c52 <getuint+0x4d>
    }
    else if (lflag) {
  800c22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c26:	74 16                	je     800c3e <getuint+0x39>
        return va_arg(*ap, unsigned long);
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2b:	8b 00                	mov    (%eax),%eax
  800c2d:	8d 48 04             	lea    0x4(%eax),%ecx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 0a                	mov    %ecx,(%edx)
  800c35:	8b 00                	mov    (%eax),%eax
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	eb 14                	jmp    800c52 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 00                	mov    (%eax),%eax
  800c43:	8d 48 04             	lea    0x4(%eax),%ecx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 0a                	mov    %ecx,(%edx)
  800c4b:	8b 00                	mov    (%eax),%eax
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800c57:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c5b:	7e 14                	jle    800c71 <getint+0x1d>
        return va_arg(*ap, long long);
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	8b 00                	mov    (%eax),%eax
  800c62:	8d 48 08             	lea    0x8(%eax),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 0a                	mov    %ecx,(%edx)
  800c6a:	8b 50 04             	mov    0x4(%eax),%edx
  800c6d:	8b 00                	mov    (%eax),%eax
  800c6f:	eb 28                	jmp    800c99 <getint+0x45>
    }
    else if (lflag) {
  800c71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c75:	74 12                	je     800c89 <getint+0x35>
        return va_arg(*ap, long);
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	8b 00                	mov    (%eax),%eax
  800c7c:	8d 48 04             	lea    0x4(%eax),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	89 0a                	mov    %ecx,(%edx)
  800c84:	8b 00                	mov    (%eax),%eax
  800c86:	99                   	cltd   
  800c87:	eb 10                	jmp    800c99 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	8b 00                	mov    (%eax),%eax
  800c8e:	8d 48 04             	lea    0x4(%eax),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 0a                	mov    %ecx,(%edx)
  800c96:	8b 00                	mov    (%eax),%eax
  800c98:	99                   	cltd   
    }
}
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <printfmt>:
 * @fd:         file descriptor
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, ...) {
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 38             	sub    $0x38,%esp
    va_list ap;

    va_start(ap, fmt);
  800ca1:	8d 45 18             	lea    0x18(%ebp),%eax
  800ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, fd, putdat, fmt, ap);
  800ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800caa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cae:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	89 04 24             	mov    %eax,(%esp)
  800cc9:	e8 02 00 00 00       	call   800cd0 <vprintfmt>
    va_end(ap);
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, va_list ap) {
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800cd8:	eb 1f                	jmp    800cf9 <vprintfmt+0x29>
            if (ch == '\0') {
  800cda:	85 db                	test   %ebx,%ebx
  800cdc:	75 05                	jne    800ce3 <vprintfmt+0x13>
                return;
  800cde:	e9 33 04 00 00       	jmp    801116 <vprintfmt+0x446>
            }
            putch(ch, putdat, fd);
  800ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cea:	8b 45 10             	mov    0x10(%ebp),%eax
  800ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf1:	89 1c 24             	mov    %ebx,(%esp)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800cf9:	8b 45 14             	mov    0x14(%ebp),%eax
  800cfc:	8d 50 01             	lea    0x1(%eax),%edx
  800cff:	89 55 14             	mov    %edx,0x14(%ebp)
  800d02:	0f b6 00             	movzbl (%eax),%eax
  800d05:	0f b6 d8             	movzbl %al,%ebx
  800d08:	83 fb 25             	cmp    $0x25,%ebx
  800d0b:	75 cd                	jne    800cda <vprintfmt+0xa>
            }
            putch(ch, putdat, fd);
        }

        // Process a %-escape sequence
        char padc = ' ';
  800d0d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800d11:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800d18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800d1e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800d25:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d28:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800d2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2e:	8d 50 01             	lea    0x1(%eax),%edx
  800d31:	89 55 14             	mov    %edx,0x14(%ebp)
  800d34:	0f b6 00             	movzbl (%eax),%eax
  800d37:	0f b6 d8             	movzbl %al,%ebx
  800d3a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800d3d:	83 f8 55             	cmp    $0x55,%eax
  800d40:	0f 87 98 03 00 00    	ja     8010de <vprintfmt+0x40e>
  800d46:	8b 04 85 e8 1b 80 00 	mov    0x801be8(,%eax,4),%eax
  800d4d:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800d4f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800d53:	eb d6                	jmp    800d2b <vprintfmt+0x5b>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800d55:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800d59:	eb d0                	jmp    800d2b <vprintfmt+0x5b>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800d5b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800d62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d65:	89 d0                	mov    %edx,%eax
  800d67:	c1 e0 02             	shl    $0x2,%eax
  800d6a:	01 d0                	add    %edx,%eax
  800d6c:	01 c0                	add    %eax,%eax
  800d6e:	01 d8                	add    %ebx,%eax
  800d70:	83 e8 30             	sub    $0x30,%eax
  800d73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800d76:	8b 45 14             	mov    0x14(%ebp),%eax
  800d79:	0f b6 00             	movzbl (%eax),%eax
  800d7c:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800d7f:	83 fb 2f             	cmp    $0x2f,%ebx
  800d82:	7e 0b                	jle    800d8f <vprintfmt+0xbf>
  800d84:	83 fb 39             	cmp    $0x39,%ebx
  800d87:	7f 06                	jg     800d8f <vprintfmt+0xbf>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800d89:	83 45 14 01          	addl   $0x1,0x14(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  800d8d:	eb d3                	jmp    800d62 <vprintfmt+0x92>
            goto process_precision;
  800d8f:	eb 33                	jmp    800dc4 <vprintfmt+0xf4>

        case '*':
            precision = va_arg(ap, int);
  800d91:	8b 45 18             	mov    0x18(%ebp),%eax
  800d94:	8d 50 04             	lea    0x4(%eax),%edx
  800d97:	89 55 18             	mov    %edx,0x18(%ebp)
  800d9a:	8b 00                	mov    (%eax),%eax
  800d9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800d9f:	eb 23                	jmp    800dc4 <vprintfmt+0xf4>

        case '.':
            if (width < 0)
  800da1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800da5:	79 0c                	jns    800db3 <vprintfmt+0xe3>
                width = 0;
  800da7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800dae:	e9 78 ff ff ff       	jmp    800d2b <vprintfmt+0x5b>
  800db3:	e9 73 ff ff ff       	jmp    800d2b <vprintfmt+0x5b>

        case '#':
            altflag = 1;
  800db8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800dbf:	e9 67 ff ff ff       	jmp    800d2b <vprintfmt+0x5b>

        process_precision:
            if (width < 0)
  800dc4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800dc8:	79 12                	jns    800ddc <vprintfmt+0x10c>
                width = precision, precision = -1;
  800dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dcd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800dd0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800dd7:	e9 4f ff ff ff       	jmp    800d2b <vprintfmt+0x5b>
  800ddc:	e9 4a ff ff ff       	jmp    800d2b <vprintfmt+0x5b>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800de1:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  800de5:	e9 41 ff ff ff       	jmp    800d2b <vprintfmt+0x5b>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat, fd);
  800dea:	8b 45 18             	mov    0x18(%ebp),%eax
  800ded:	8d 50 04             	lea    0x4(%eax),%edx
  800df0:	89 55 18             	mov    %edx,0x18(%ebp)
  800df3:	8b 00                	mov    (%eax),%eax
  800df5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df8:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dfc:	8b 55 10             	mov    0x10(%ebp),%edx
  800dff:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e03:	89 04 24             	mov    %eax,(%esp)
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	ff d0                	call   *%eax
            break;
  800e0b:	e9 00 03 00 00       	jmp    801110 <vprintfmt+0x440>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800e10:	8b 45 18             	mov    0x18(%ebp),%eax
  800e13:	8d 50 04             	lea    0x4(%eax),%edx
  800e16:	89 55 18             	mov    %edx,0x18(%ebp)
  800e19:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800e1b:	85 db                	test   %ebx,%ebx
  800e1d:	79 02                	jns    800e21 <vprintfmt+0x151>
                err = -err;
  800e1f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800e21:	83 fb 18             	cmp    $0x18,%ebx
  800e24:	7f 0b                	jg     800e31 <vprintfmt+0x161>
  800e26:	8b 34 9d 60 1b 80 00 	mov    0x801b60(,%ebx,4),%esi
  800e2d:	85 f6                	test   %esi,%esi
  800e2f:	75 2a                	jne    800e5b <vprintfmt+0x18b>
                printfmt(putch, fd, putdat, "error %d", err);
  800e31:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e35:	c7 44 24 0c d5 1b 80 	movl   $0x801bd5,0xc(%esp)
  800e3c:	00 
  800e3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e40:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	89 04 24             	mov    %eax,(%esp)
  800e51:	e8 45 fe ff ff       	call   800c9b <printfmt>
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
            }
            break;
  800e56:	e9 b5 02 00 00       	jmp    801110 <vprintfmt+0x440>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, fd, putdat, "error %d", err);
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
  800e5b:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e5f:	c7 44 24 0c de 1b 80 	movl   $0x801bde,0xc(%esp)
  800e66:	00 
  800e67:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	89 04 24             	mov    %eax,(%esp)
  800e7b:	e8 1b fe ff ff       	call   800c9b <printfmt>
            }
            break;
  800e80:	e9 8b 02 00 00       	jmp    801110 <vprintfmt+0x440>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800e85:	8b 45 18             	mov    0x18(%ebp),%eax
  800e88:	8d 50 04             	lea    0x4(%eax),%edx
  800e8b:	89 55 18             	mov    %edx,0x18(%ebp)
  800e8e:	8b 30                	mov    (%eax),%esi
  800e90:	85 f6                	test   %esi,%esi
  800e92:	75 05                	jne    800e99 <vprintfmt+0x1c9>
                p = "(null)";
  800e94:	be e1 1b 80 00       	mov    $0x801be1,%esi
            }
            if (width > 0 && padc != '-') {
  800e99:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800e9d:	7e 45                	jle    800ee4 <vprintfmt+0x214>
  800e9f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800ea3:	74 3f                	je     800ee4 <vprintfmt+0x214>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800ea5:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eaf:	89 34 24             	mov    %esi,(%esp)
  800eb2:	e8 3b 04 00 00       	call   8012f2 <strnlen>
  800eb7:	29 c3                	sub    %eax,%ebx
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ebe:	eb 1e                	jmp    800ede <vprintfmt+0x20e>
                    putch(padc, putdat, fd);
  800ec0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800ec4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ecb:	8b 55 10             	mov    0x10(%ebp),%edx
  800ece:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed2:	89 04 24             	mov    %eax,(%esp)
  800ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed8:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  800eda:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800ede:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800ee2:	7f dc                	jg     800ec0 <vprintfmt+0x1f0>
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800ee4:	eb 46                	jmp    800f2c <vprintfmt+0x25c>
                if (altflag && (ch < ' ' || ch > '~')) {
  800ee6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800eea:	74 26                	je     800f12 <vprintfmt+0x242>
  800eec:	83 fb 1f             	cmp    $0x1f,%ebx
  800eef:	7e 05                	jle    800ef6 <vprintfmt+0x226>
  800ef1:	83 fb 7e             	cmp    $0x7e,%ebx
  800ef4:	7e 1c                	jle    800f12 <vprintfmt+0x242>
                    putch('?', putdat, fd);
  800ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800efd:	8b 45 10             	mov    0x10(%ebp),%eax
  800f00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f04:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	ff d0                	call   *%eax
  800f10:	eb 16                	jmp    800f28 <vprintfmt+0x258>
                }
                else {
                    putch(ch, putdat, fd);
  800f12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f19:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f20:	89 1c 24             	mov    %ebx,(%esp)
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800f28:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f2c:	89 f0                	mov    %esi,%eax
  800f2e:	8d 70 01             	lea    0x1(%eax),%esi
  800f31:	0f b6 00             	movzbl (%eax),%eax
  800f34:	0f be d8             	movsbl %al,%ebx
  800f37:	85 db                	test   %ebx,%ebx
  800f39:	74 10                	je     800f4b <vprintfmt+0x27b>
  800f3b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f3f:	78 a5                	js     800ee6 <vprintfmt+0x216>
  800f41:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800f45:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f49:	79 9b                	jns    800ee6 <vprintfmt+0x216>
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  800f4b:	eb 1e                	jmp    800f6b <vprintfmt+0x29b>
                putch(' ', putdat, fd);
  800f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f54:	8b 45 10             	mov    0x10(%ebp),%eax
  800f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  800f67:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800f6b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f6f:	7f dc                	jg     800f4d <vprintfmt+0x27d>
                putch(' ', putdat, fd);
            }
            break;
  800f71:	e9 9a 01 00 00       	jmp    801110 <vprintfmt+0x440>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800f76:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7d:	8d 45 18             	lea    0x18(%ebp),%eax
  800f80:	89 04 24             	mov    %eax,(%esp)
  800f83:	e8 cc fc ff ff       	call   800c54 <getint>
  800f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f8b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f94:	85 d2                	test   %edx,%edx
  800f96:	79 2d                	jns    800fc5 <vprintfmt+0x2f5>
                putch('-', putdat, fd);
  800f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb0:	ff d0                	call   *%eax
                num = -(long long)num;
  800fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fb8:	f7 d8                	neg    %eax
  800fba:	83 d2 00             	adc    $0x0,%edx
  800fbd:	f7 da                	neg    %edx
  800fbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fc2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800fc5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800fcc:	e9 b6 00 00 00       	jmp    801087 <vprintfmt+0x3b7>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800fd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd8:	8d 45 18             	lea    0x18(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 22 fc ff ff       	call   800c05 <getuint>
  800fe3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fe6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800fe9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800ff0:	e9 92 00 00 00       	jmp    801087 <vprintfmt+0x3b7>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffc:	8d 45 18             	lea    0x18(%ebp),%eax
  800fff:	89 04 24             	mov    %eax,(%esp)
  801002:	e8 fe fb ff ff       	call   800c05 <getuint>
  801007:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80100a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  80100d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  801014:	eb 71                	jmp    801087 <vprintfmt+0x3b7>

        // pointer
        case 'p':
            putch('0', putdat, fd);
  801016:	8b 45 0c             	mov    0xc(%ebp),%eax
  801019:	89 44 24 08          	mov    %eax,0x8(%esp)
  80101d:	8b 45 10             	mov    0x10(%ebp),%eax
  801020:	89 44 24 04          	mov    %eax,0x4(%esp)
  801024:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	ff d0                	call   *%eax
            putch('x', putdat, fd);
  801030:	8b 45 0c             	mov    0xc(%ebp),%eax
  801033:	89 44 24 08          	mov    %eax,0x8(%esp)
  801037:	8b 45 10             	mov    0x10(%ebp),%eax
  80103a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801045:	8b 45 08             	mov    0x8(%ebp),%eax
  801048:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80104a:	8b 45 18             	mov    0x18(%ebp),%eax
  80104d:	8d 50 04             	lea    0x4(%eax),%edx
  801050:	89 55 18             	mov    %edx,0x18(%ebp)
  801053:	8b 00                	mov    (%eax),%eax
  801055:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801058:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  80105f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  801066:	eb 1f                	jmp    801087 <vprintfmt+0x3b7>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  801068:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80106b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106f:	8d 45 18             	lea    0x18(%ebp),%eax
  801072:	89 04 24             	mov    %eax,(%esp)
  801075:	e8 8b fb ff ff       	call   800c05 <getuint>
  80107a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80107d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  801080:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, fd, putdat, num, base, width, padc);
  801087:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80108b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80108e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  801092:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801095:	89 54 24 18          	mov    %edx,0x18(%esp)
  801099:	89 44 24 14          	mov    %eax,0x14(%esp)
  80109d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bc:	89 04 24             	mov    %eax,(%esp)
  8010bf:	e8 27 fa ff ff       	call   800aeb <printnum>
            break;
  8010c4:	eb 4a                	jmp    801110 <vprintfmt+0x440>

        // escaped '%' character
        case '%':
            putch(ch, putdat, fd);
  8010c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d4:	89 1c 24             	mov    %ebx,(%esp)
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	ff d0                	call   *%eax
            break;
  8010dc:	eb 32                	jmp    801110 <vprintfmt+0x440>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat, fd);
  8010de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  8010f8:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  8010fc:	eb 04                	jmp    801102 <vprintfmt+0x432>
  8010fe:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  801102:	8b 45 14             	mov    0x14(%ebp),%eax
  801105:	83 e8 01             	sub    $0x1,%eax
  801108:	0f b6 00             	movzbl (%eax),%eax
  80110b:	3c 25                	cmp    $0x25,%al
  80110d:	75 ef                	jne    8010fe <vprintfmt+0x42e>
                /* do nothing */;
            break;
  80110f:	90                   	nop
        }
    }
  801110:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  801111:	e9 e3 fb ff ff       	jmp    800cf9 <vprintfmt+0x29>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  801116:	83 c4 40             	add    $0x40,%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  801120:	8b 45 0c             	mov    0xc(%ebp),%eax
  801123:	8b 40 08             	mov    0x8(%eax),%eax
  801126:	8d 50 01             	lea    0x1(%eax),%edx
  801129:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112c:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  80112f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801132:	8b 10                	mov    (%eax),%edx
  801134:	8b 45 0c             	mov    0xc(%ebp),%eax
  801137:	8b 40 04             	mov    0x4(%eax),%eax
  80113a:	39 c2                	cmp    %eax,%edx
  80113c:	73 12                	jae    801150 <sprintputch+0x33>
        *b->buf ++ = ch;
  80113e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801141:	8b 00                	mov    (%eax),%eax
  801143:	8d 48 01             	lea    0x1(%eax),%ecx
  801146:	8b 55 0c             	mov    0xc(%ebp),%edx
  801149:	89 0a                	mov    %ecx,(%edx)
  80114b:	8b 55 08             	mov    0x8(%ebp),%edx
  80114e:	88 10                	mov    %dl,(%eax)
    }
}
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  801158:	8d 45 14             	lea    0x14(%ebp),%eax
  80115b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  80115e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801161:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801165:	8b 45 10             	mov    0x10(%ebp),%eax
  801168:	89 44 24 08          	mov    %eax,0x8(%esp)
  80116c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	89 04 24             	mov    %eax,(%esp)
  801179:	e8 08 00 00 00       	call   801186 <vsnprintf>
  80117e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  801181:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	83 ec 38             	sub    $0x38,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  80118c:	8b 45 08             	mov    0x8(%ebp),%eax
  80118f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801192:	8b 45 0c             	mov    0xc(%ebp),%eax
  801195:	8d 50 ff             	lea    -0x1(%eax),%edx
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
  80119b:	01 d0                	add    %edx,%eax
  80119d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8011a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  8011a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011ab:	74 0a                	je     8011b7 <vsnprintf+0x31>
  8011ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b3:	39 c2                	cmp    %eax,%edx
  8011b5:	76 07                	jbe    8011be <vsnprintf+0x38>
        return -E_INVAL;
  8011b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bc:	eb 32                	jmp    8011f0 <vsnprintf+0x6a>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, NO_FD, &b, fmt, ap);
  8011be:	8b 45 14             	mov    0x14(%ebp),%eax
  8011c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011cc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8011cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d3:	c7 44 24 04 d9 6a ff 	movl   $0xffff6ad9,0x4(%esp)
  8011da:	ff 
  8011db:	c7 04 24 1d 11 80 00 	movl   $0x80111d,(%esp)
  8011e2:	e8 e9 fa ff ff       	call   800cd0 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  8011e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011ea:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  8011ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  8011fb:	a1 08 20 80 00       	mov    0x802008,%eax
  801200:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  801206:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  80120c:	6b f0 05             	imul   $0x5,%eax,%esi
  80120f:	01 f7                	add    %esi,%edi
  801211:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
  801216:	f7 e6                	mul    %esi
  801218:	8d 34 17             	lea    (%edi,%edx,1),%esi
  80121b:	89 f2                	mov    %esi,%edx
  80121d:	83 c0 0b             	add    $0xb,%eax
  801220:	83 d2 00             	adc    $0x0,%edx
  801223:	89 c7                	mov    %eax,%edi
  801225:	83 e7 ff             	and    $0xffffffff,%edi
  801228:	89 f9                	mov    %edi,%ecx
  80122a:	0f b7 da             	movzwl %dx,%ebx
  80122d:	89 0d 08 20 80 00    	mov    %ecx,0x802008
  801233:	89 1d 0c 20 80 00    	mov    %ebx,0x80200c
    unsigned long long result = (next >> 12);
  801239:	a1 08 20 80 00       	mov    0x802008,%eax
  80123e:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  801244:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  801248:	c1 ea 0c             	shr    $0xc,%edx
  80124b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80124e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  801251:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  801258:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80125b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80125e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801261:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801264:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801267:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80126a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80126e:	74 1c                	je     80128c <rand+0x9a>
  801270:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801273:	ba 00 00 00 00       	mov    $0x0,%edx
  801278:	f7 75 dc             	divl   -0x24(%ebp)
  80127b:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80127e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801281:	ba 00 00 00 00       	mov    $0x0,%edx
  801286:	f7 75 dc             	divl   -0x24(%ebp)
  801289:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80128c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80128f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801292:	f7 75 dc             	divl   -0x24(%ebp)
  801295:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801298:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80129b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80129e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8012aa:	83 c4 24             	add    $0x24,%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
    next = seed;
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bd:	a3 08 20 80 00       	mov    %eax,0x802008
  8012c2:	89 15 0c 20 80 00    	mov    %edx,0x80200c
}
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8012d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  8012d7:	eb 04                	jmp    8012dd <strlen+0x13>
        cnt ++;
  8012d9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e0:	8d 50 01             	lea    0x1(%eax),%edx
  8012e3:	89 55 08             	mov    %edx,0x8(%ebp)
  8012e6:	0f b6 00             	movzbl (%eax),%eax
  8012e9:	84 c0                	test   %al,%al
  8012eb:	75 ec                	jne    8012d9 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  8012ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8012f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8012ff:	eb 04                	jmp    801305 <strnlen+0x13>
        cnt ++;
  801301:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  801305:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801308:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80130b:	73 10                	jae    80131d <strnlen+0x2b>
  80130d:	8b 45 08             	mov    0x8(%ebp),%eax
  801310:	8d 50 01             	lea    0x1(%eax),%edx
  801313:	89 55 08             	mov    %edx,0x8(%ebp)
  801316:	0f b6 00             	movzbl (%eax),%eax
  801319:	84 c0                	test   %al,%al
  80131b:	75 e4                	jne    801301 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  80131d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <strcat>:
 * @dst:    pointer to the @dst array, which should be large enough to contain the concatenated
 *          resulting string.
 * @src:    string to be appended, this should not overlap @dst
 * */
char *
strcat(char *dst, const char *src) {
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 18             	sub    $0x18,%esp
    return strcpy(dst + strlen(dst), src);
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	e8 97 ff ff ff       	call   8012ca <strlen>
  801333:	8b 55 08             	mov    0x8(%ebp),%edx
  801336:	01 c2                	add    %eax,%edx
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133f:	89 14 24             	mov    %edx,(%esp)
  801342:	e8 02 00 00 00       	call   801349 <strcpy>
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	83 ec 20             	sub    $0x20,%esp
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801357:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  80135d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801363:	89 d1                	mov    %edx,%ecx
  801365:	89 c2                	mov    %eax,%edx
  801367:	89 ce                	mov    %ecx,%esi
  801369:	89 d7                	mov    %edx,%edi
  80136b:	ac                   	lods   %ds:(%esi),%al
  80136c:	aa                   	stos   %al,%es:(%edi)
  80136d:	84 c0                	test   %al,%al
  80136f:	75 fa                	jne    80136b <strcpy+0x22>
  801371:	89 fa                	mov    %edi,%edx
  801373:	89 f1                	mov    %esi,%ecx
  801375:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  801378:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80137b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  80137e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  801381:	83 c4 20             	add    $0x20,%esp
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  801394:	eb 21                	jmp    8013b7 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  801396:	8b 45 0c             	mov    0xc(%ebp),%eax
  801399:	0f b6 10             	movzbl (%eax),%edx
  80139c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80139f:	88 10                	mov    %dl,(%eax)
  8013a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013a4:	0f b6 00             	movzbl (%eax),%eax
  8013a7:	84 c0                	test   %al,%al
  8013a9:	74 04                	je     8013af <strncpy+0x27>
            src ++;
  8013ab:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  8013af:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8013b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  8013b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013bb:	75 d9                	jne    801396 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	83 ec 20             	sub    $0x20,%esp
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8013d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  8013d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dc:	89 d1                	mov    %edx,%ecx
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	89 ce                	mov    %ecx,%esi
  8013e2:	89 d7                	mov    %edx,%edi
  8013e4:	ac                   	lods   %ds:(%esi),%al
  8013e5:	ae                   	scas   %es:(%edi),%al
  8013e6:	75 08                	jne    8013f0 <strcmp+0x2e>
  8013e8:	84 c0                	test   %al,%al
  8013ea:	75 f8                	jne    8013e4 <strcmp+0x22>
  8013ec:	31 c0                	xor    %eax,%eax
  8013ee:	eb 04                	jmp    8013f4 <strcmp+0x32>
  8013f0:	19 c0                	sbb    %eax,%eax
  8013f2:	0c 01                	or     $0x1,%al
  8013f4:	89 fa                	mov    %edi,%edx
  8013f6:	89 f1                	mov    %esi,%ecx
  8013f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013fb:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8013fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  801401:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  801404:	83 c4 20             	add    $0x20,%esp
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  80140e:	eb 0c                	jmp    80141c <strncmp+0x11>
        n --, s1 ++, s2 ++;
  801410:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  801414:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801418:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  80141c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801420:	74 1a                	je     80143c <strncmp+0x31>
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	0f b6 00             	movzbl (%eax),%eax
  801428:	84 c0                	test   %al,%al
  80142a:	74 10                	je     80143c <strncmp+0x31>
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	0f b6 10             	movzbl (%eax),%edx
  801432:	8b 45 0c             	mov    0xc(%ebp),%eax
  801435:	0f b6 00             	movzbl (%eax),%eax
  801438:	38 c2                	cmp    %al,%dl
  80143a:	74 d4                	je     801410 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  80143c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801440:	74 18                	je     80145a <strncmp+0x4f>
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	0f b6 00             	movzbl (%eax),%eax
  801448:	0f b6 d0             	movzbl %al,%edx
  80144b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144e:	0f b6 00             	movzbl (%eax),%eax
  801451:	0f b6 c0             	movzbl %al,%eax
  801454:	29 c2                	sub    %eax,%edx
  801456:	89 d0                	mov    %edx,%eax
  801458:	eb 05                	jmp    80145f <strncmp+0x54>
  80145a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145f:	5d                   	pop    %ebp
  801460:	c3                   	ret    

00801461 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  80146d:	eb 14                	jmp    801483 <strchr+0x22>
        if (*s == c) {
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	0f b6 00             	movzbl (%eax),%eax
  801475:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801478:	75 05                	jne    80147f <strchr+0x1e>
            return (char *)s;
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
  80147d:	eb 13                	jmp    801492 <strchr+0x31>
        }
        s ++;
  80147f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	0f b6 00             	movzbl (%eax),%eax
  801489:	84 c0                	test   %al,%al
  80148b:	75 e2                	jne    80146f <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  80148d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  8014a0:	eb 11                	jmp    8014b3 <strfind+0x1f>
        if (*s == c) {
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	0f b6 00             	movzbl (%eax),%eax
  8014a8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8014ab:	75 02                	jne    8014af <strfind+0x1b>
            break;
  8014ad:	eb 0e                	jmp    8014bd <strfind+0x29>
        }
        s ++;
  8014af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  8014b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b6:	0f b6 00             	movzbl (%eax),%eax
  8014b9:	84 c0                	test   %al,%al
  8014bb:	75 e5                	jne    8014a2 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  8014bd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  8014c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  8014cf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  8014d6:	eb 04                	jmp    8014dc <strtol+0x1a>
        s ++;
  8014d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	0f b6 00             	movzbl (%eax),%eax
  8014e2:	3c 20                	cmp    $0x20,%al
  8014e4:	74 f2                	je     8014d8 <strtol+0x16>
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	0f b6 00             	movzbl (%eax),%eax
  8014ec:	3c 09                	cmp    $0x9,%al
  8014ee:	74 e8                	je     8014d8 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	0f b6 00             	movzbl (%eax),%eax
  8014f6:	3c 2b                	cmp    $0x2b,%al
  8014f8:	75 06                	jne    801500 <strtol+0x3e>
        s ++;
  8014fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8014fe:	eb 15                	jmp    801515 <strtol+0x53>
    }
    else if (*s == '-') {
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	0f b6 00             	movzbl (%eax),%eax
  801506:	3c 2d                	cmp    $0x2d,%al
  801508:	75 0b                	jne    801515 <strtol+0x53>
        s ++, neg = 1;
  80150a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80150e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  801515:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801519:	74 06                	je     801521 <strtol+0x5f>
  80151b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80151f:	75 24                	jne    801545 <strtol+0x83>
  801521:	8b 45 08             	mov    0x8(%ebp),%eax
  801524:	0f b6 00             	movzbl (%eax),%eax
  801527:	3c 30                	cmp    $0x30,%al
  801529:	75 1a                	jne    801545 <strtol+0x83>
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	83 c0 01             	add    $0x1,%eax
  801531:	0f b6 00             	movzbl (%eax),%eax
  801534:	3c 78                	cmp    $0x78,%al
  801536:	75 0d                	jne    801545 <strtol+0x83>
        s += 2, base = 16;
  801538:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80153c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801543:	eb 2a                	jmp    80156f <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  801545:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801549:	75 17                	jne    801562 <strtol+0xa0>
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	0f b6 00             	movzbl (%eax),%eax
  801551:	3c 30                	cmp    $0x30,%al
  801553:	75 0d                	jne    801562 <strtol+0xa0>
        s ++, base = 8;
  801555:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801559:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801560:	eb 0d                	jmp    80156f <strtol+0xad>
    }
    else if (base == 0) {
  801562:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801566:	75 07                	jne    80156f <strtol+0xad>
        base = 10;
  801568:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  80156f:	8b 45 08             	mov    0x8(%ebp),%eax
  801572:	0f b6 00             	movzbl (%eax),%eax
  801575:	3c 2f                	cmp    $0x2f,%al
  801577:	7e 1b                	jle    801594 <strtol+0xd2>
  801579:	8b 45 08             	mov    0x8(%ebp),%eax
  80157c:	0f b6 00             	movzbl (%eax),%eax
  80157f:	3c 39                	cmp    $0x39,%al
  801581:	7f 11                	jg     801594 <strtol+0xd2>
            dig = *s - '0';
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	0f b6 00             	movzbl (%eax),%eax
  801589:	0f be c0             	movsbl %al,%eax
  80158c:	83 e8 30             	sub    $0x30,%eax
  80158f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801592:	eb 48                	jmp    8015dc <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  801594:	8b 45 08             	mov    0x8(%ebp),%eax
  801597:	0f b6 00             	movzbl (%eax),%eax
  80159a:	3c 60                	cmp    $0x60,%al
  80159c:	7e 1b                	jle    8015b9 <strtol+0xf7>
  80159e:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a1:	0f b6 00             	movzbl (%eax),%eax
  8015a4:	3c 7a                	cmp    $0x7a,%al
  8015a6:	7f 11                	jg     8015b9 <strtol+0xf7>
            dig = *s - 'a' + 10;
  8015a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ab:	0f b6 00             	movzbl (%eax),%eax
  8015ae:	0f be c0             	movsbl %al,%eax
  8015b1:	83 e8 57             	sub    $0x57,%eax
  8015b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015b7:	eb 23                	jmp    8015dc <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  8015b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bc:	0f b6 00             	movzbl (%eax),%eax
  8015bf:	3c 40                	cmp    $0x40,%al
  8015c1:	7e 3d                	jle    801600 <strtol+0x13e>
  8015c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c6:	0f b6 00             	movzbl (%eax),%eax
  8015c9:	3c 5a                	cmp    $0x5a,%al
  8015cb:	7f 33                	jg     801600 <strtol+0x13e>
            dig = *s - 'A' + 10;
  8015cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d0:	0f b6 00             	movzbl (%eax),%eax
  8015d3:	0f be c0             	movsbl %al,%eax
  8015d6:	83 e8 37             	sub    $0x37,%eax
  8015d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  8015dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015df:	3b 45 10             	cmp    0x10(%ebp),%eax
  8015e2:	7c 02                	jl     8015e6 <strtol+0x124>
            break;
  8015e4:	eb 1a                	jmp    801600 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  8015e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8015ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8015ed:	0f af 45 10          	imul   0x10(%ebp),%eax
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f6:	01 d0                	add    %edx,%eax
  8015f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  8015fb:	e9 6f ff ff ff       	jmp    80156f <strtol+0xad>

    if (endptr) {
  801600:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801604:	74 08                	je     80160e <strtol+0x14c>
        *endptr = (char *) s;
  801606:	8b 45 0c             	mov    0xc(%ebp),%eax
  801609:	8b 55 08             	mov    0x8(%ebp),%edx
  80160c:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  80160e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801612:	74 07                	je     80161b <strtol+0x159>
  801614:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801617:	f7 d8                	neg    %eax
  801619:	eb 03                	jmp    80161e <strtol+0x15c>
  80161b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	83 ec 24             	sub    $0x24,%esp
  801627:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  80162d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801631:	8b 55 08             	mov    0x8(%ebp),%edx
  801634:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801637:	88 45 f7             	mov    %al,-0x9(%ebp)
  80163a:	8b 45 10             	mov    0x10(%ebp),%eax
  80163d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  801640:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801643:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801647:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80164a:	89 d7                	mov    %edx,%edi
  80164c:	f3 aa                	rep stos %al,%es:(%edi)
  80164e:	89 fa                	mov    %edi,%edx
  801650:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  801653:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  801656:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  801659:	83 c4 24             	add    $0x24,%esp
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    

0080165f <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	57                   	push   %edi
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
  801665:	83 ec 30             	sub    $0x30,%esp
  801668:	8b 45 08             	mov    0x8(%ebp),%eax
  80166b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80166e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801671:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801674:	8b 45 10             	mov    0x10(%ebp),%eax
  801677:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  801680:	73 42                	jae    8016c4 <memmove+0x65>
  801682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801685:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80168b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80168e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801691:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  801694:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801697:	c1 e8 02             	shr    $0x2,%eax
  80169a:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  80169c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80169f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016a2:	89 d7                	mov    %edx,%edi
  8016a4:	89 c6                	mov    %eax,%esi
  8016a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8016ab:	83 e1 03             	and    $0x3,%ecx
  8016ae:	74 02                	je     8016b2 <memmove+0x53>
  8016b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8016b2:	89 f0                	mov    %esi,%eax
  8016b4:	89 fa                	mov    %edi,%edx
  8016b6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8016b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8016bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  8016bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016c2:	eb 36                	jmp    8016fa <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  8016c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016c7:	8d 50 ff             	lea    -0x1(%eax),%edx
  8016ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016cd:	01 c2                	add    %eax,%edx
  8016cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016d2:	8d 48 ff             	lea    -0x1(%eax),%ecx
  8016d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d8:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  8016db:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016de:	89 c1                	mov    %eax,%ecx
  8016e0:	89 d8                	mov    %ebx,%eax
  8016e2:	89 d6                	mov    %edx,%esi
  8016e4:	89 c7                	mov    %eax,%edi
  8016e6:	fd                   	std    
  8016e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8016e9:	fc                   	cld    
  8016ea:	89 f8                	mov    %edi,%eax
  8016ec:	89 f2                	mov    %esi,%edx
  8016ee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8016f1:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8016f4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  8016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  8016fa:	83 c4 30             	add    $0x30,%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5f                   	pop    %edi
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	57                   	push   %edi
  801706:	56                   	push   %esi
  801707:	83 ec 20             	sub    $0x20,%esp
  80170a:	8b 45 08             	mov    0x8(%ebp),%eax
  80170d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801710:	8b 45 0c             	mov    0xc(%ebp),%eax
  801713:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801716:	8b 45 10             	mov    0x10(%ebp),%eax
  801719:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  80171c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80171f:	c1 e8 02             	shr    $0x2,%eax
  801722:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  801724:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801727:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172a:	89 d7                	mov    %edx,%edi
  80172c:	89 c6                	mov    %eax,%esi
  80172e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801730:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801733:	83 e1 03             	and    $0x3,%ecx
  801736:	74 02                	je     80173a <memcpy+0x38>
  801738:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  80173a:	89 f0                	mov    %esi,%eax
  80173c:	89 fa                	mov    %edi,%edx
  80173e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  801741:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801744:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  801747:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  80174a:	83 c4 20             	add    $0x20,%esp
  80174d:	5e                   	pop    %esi
  80174e:	5f                   	pop    %edi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  801757:	8b 45 08             	mov    0x8(%ebp),%eax
  80175a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  80175d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801760:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  801763:	eb 30                	jmp    801795 <memcmp+0x44>
        if (*s1 != *s2) {
  801765:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801768:	0f b6 10             	movzbl (%eax),%edx
  80176b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80176e:	0f b6 00             	movzbl (%eax),%eax
  801771:	38 c2                	cmp    %al,%dl
  801773:	74 18                	je     80178d <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  801775:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801778:	0f b6 00             	movzbl (%eax),%eax
  80177b:	0f b6 d0             	movzbl %al,%edx
  80177e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801781:	0f b6 00             	movzbl (%eax),%eax
  801784:	0f b6 c0             	movzbl %al,%eax
  801787:	29 c2                	sub    %eax,%edx
  801789:	89 d0                	mov    %edx,%eax
  80178b:	eb 1a                	jmp    8017a7 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  80178d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801791:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  801795:	8b 45 10             	mov    0x10(%ebp),%eax
  801798:	8d 50 ff             	lea    -0x1(%eax),%edx
  80179b:	89 55 10             	mov    %edx,0x10(%ebp)
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	75 c3                	jne    801765 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  8017a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 e4 f0             	and    $0xfffffff0,%esp
  8017af:	83 ec 20             	sub    $0x20,%esp
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  8017b2:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  8017b9:	e8 1f ec ff ff       	call   8003dd <cprintf>
    if ((pid = fork()) == 0) {
  8017be:	e8 fc f0 ff ff       	call   8008bf <fork>
  8017c3:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8017c7:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8017cc:	75 0e                	jne    8017dc <main+0x33>
        cprintf("I am the child. spinning ...\n");
  8017ce:	c7 04 24 67 1d 80 00 	movl   $0x801d67,(%esp)
  8017d5:	e8 03 ec ff ff       	call   8003dd <cprintf>
        while (1);
  8017da:	eb fe                	jmp    8017da <main+0x31>
    }
    cprintf("I am the parent. Running the child...\n");
  8017dc:	c7 04 24 88 1d 80 00 	movl   $0x801d88,(%esp)
  8017e3:	e8 f5 eb ff ff       	call   8003dd <cprintf>

    yield();
  8017e8:	e8 15 f1 ff ff       	call   800902 <yield>
    yield();
  8017ed:	e8 10 f1 ff ff       	call   800902 <yield>
    yield();
  8017f2:	e8 0b f1 ff ff       	call   800902 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8017f7:	c7 04 24 b0 1d 80 00 	movl   $0x801db0,(%esp)
  8017fe:	e8 da eb ff ff       	call   8003dd <cprintf>

    assert((ret = kill(pid)) == 0);
  801803:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801807:	89 04 24             	mov    %eax,(%esp)
  80180a:	e8 00 f1 ff ff       	call   80090f <kill>
  80180f:	89 44 24 18          	mov    %eax,0x18(%esp)
  801813:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  801818:	74 24                	je     80183e <main+0x95>
  80181a:	c7 44 24 0c d8 1d 80 	movl   $0x801dd8,0xc(%esp)
  801821:	00 
  801822:	c7 44 24 08 ef 1d 80 	movl   $0x801def,0x8(%esp)
  801829:	00 
  80182a:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
  801831:	00 
  801832:	c7 04 24 04 1e 80 00 	movl   $0x801e04,(%esp)
  801839:	e8 ae ea ff ff       	call   8002ec <__panic>
    cprintf("kill returns %d\n", ret);
  80183e:	8b 44 24 18          	mov    0x18(%esp),%eax
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	c7 04 24 10 1e 80 00 	movl   $0x801e10,(%esp)
  80184d:	e8 8b eb ff ff       	call   8003dd <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  801852:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801859:	00 
  80185a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80185e:	89 04 24             	mov    %eax,(%esp)
  801861:	e8 82 f0 ff ff       	call   8008e8 <waitpid>
  801866:	89 44 24 18          	mov    %eax,0x18(%esp)
  80186a:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  80186f:	74 24                	je     801895 <main+0xec>
  801871:	c7 44 24 0c 24 1e 80 	movl   $0x801e24,0xc(%esp)
  801878:	00 
  801879:	c7 44 24 08 ef 1d 80 	movl   $0x801def,0x8(%esp)
  801880:	00 
  801881:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  801888:	00 
  801889:	c7 04 24 04 1e 80 00 	movl   $0x801e04,(%esp)
  801890:	e8 57 ea ff ff       	call   8002ec <__panic>
    cprintf("wait returns %d\n", ret);
  801895:	8b 44 24 18          	mov    0x18(%esp),%eax
  801899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189d:	c7 04 24 44 1e 80 00 	movl   $0x801e44,(%esp)
  8018a4:	e8 34 eb ff ff       	call   8003dd <cprintf>

    cprintf("spin may pass.\n");
  8018a9:	c7 04 24 55 1e 80 00 	movl   $0x801e55,(%esp)
  8018b0:	e8 28 eb ff ff       	call   8003dd <cprintf>
    return 0;
  8018b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    
