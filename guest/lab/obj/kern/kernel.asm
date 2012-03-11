
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

00800020 <_start-0xc>:

	# Set the stack pointer
#	movl	$(bootstacktop),%esp

	# now to C code
	push $0
  800020:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
  800026:	00 00                	add    %al,(%eax)
  800028:	fb                   	sti    
  800029:	4f                   	dec    %edi
  80002a:	52                   	push   %edx
  80002b:	e4 6a                	in     $0x6a,%al

0080002c <_start>:
  80002c:	6a 00                	push   $0x0
	push $0
  80002e:	6a 00                	push   $0x0
	call	i386_init
  800030:	e8 60 00 00 00       	call   800095 <i386_init>
  800035:	00 00                	add    %al,(%eax)
	...

00800038 <test_backtrace>:
#include <kern/env.h>

// Test the stack backtrace function (lab 1 only/)
void
test_backtrace(int x)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	53                   	push   %ebx
  80003c:	83 ec 14             	sub    $0x14,%esp
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
  800042:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800046:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80004d:	e8 60 15 00 00       	call   8015b2 <cprintf>
	if (x > 0)
  800052:	85 db                	test   %ebx,%ebx
  800054:	7e 0d                	jle    800063 <test_backtrace+0x2b>
		test_backtrace(x-1);
  800056:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800059:	89 04 24             	mov    %eax,(%esp)
  80005c:	e8 d7 ff ff ff       	call   800038 <test_backtrace>
  800061:	eb 1c                	jmp    80007f <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
  800063:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80006a:	00 
  80006b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007a:	e8 78 03 00 00       	call   8003f7 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
  80007f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800083:	c7 04 24 7c 1d 80 00 	movl   $0x801d7c,(%esp)
  80008a:	e8 23 15 00 00       	call   8015b2 <cprintf>
}
  80008f:	83 c4 14             	add    $0x14,%esp
  800092:	5b                   	pop    %ebx
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    

00800095 <i386_init>:


void
i386_init(void)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 18             	sub    $0x18,%esp
//	while(1)
//	{
		int k = 2;
		k = k + 2;
		cprintf("hello i386 init.. hee haw!! ukhaar lo saale jo ukhar sakte ho :P\n");
  80009b:	c7 04 24 cc 1d 80 00 	movl   $0x801dcc,(%esp)
  8000a2:	e8 0b 15 00 00       	call   8015b2 <cprintf>
	//	extern int _binary_abc_size[];
	//	cprintf("obj: %x", _binary_abc_size);
		env_init();
  8000a7:	e8 ac 15 00 00       	call   801658 <env_init>
		ENV_CREATE(abc);
  8000ac:	c7 44 24 04 89 cc 00 	movl   $0xcc89,0x4(%esp)
  8000b3:	00 
  8000b4:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8000bb:	e8 48 19 00 00       	call   801a08 <env_create>
//	test_backtrace(5);

	// Drop into the kernel monitor.
//	while (1)
//		monitor(NULL);
}
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 10             	sub    $0x10,%esp
  8000ca:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
  8000cd:	83 3d a0 fc 80 00 00 	cmpl   $0x0,0x80fca0
  8000d4:	75 3d                	jne    800113 <_panic+0x51>
		goto dead;
	panicstr = fmt;
  8000d6:	89 35 a0 fc 80 00    	mov    %esi,0x80fca0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
  8000dc:	fa                   	cli    
  8000dd:	fc                   	cld    

	va_start(ap, fmt);
  8000de:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ef:	c7 04 24 97 1d 80 00 	movl   $0x801d97,(%esp)
  8000f6:	e8 b7 14 00 00       	call   8015b2 <cprintf>
	vcprintf(fmt, ap);
  8000fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ff:	89 34 24             	mov    %esi,(%esp)
  800102:	e8 4a 14 00 00       	call   801551 <vcprintf>
	cprintf("\n");
  800107:	c7 04 24 6a 1e 80 00 	movl   $0x801e6a,(%esp)
  80010e:	e8 9f 14 00 00       	call   8015b2 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
  800113:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011a:	e8 9b 01 00 00       	call   8002ba <monitor>
  80011f:	eb f2                	jmp    800113 <_panic+0x51>

00800121 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800128:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	c7 04 24 af 1d 80 00 	movl   $0x801daf,(%esp)
  800140:	e8 6d 14 00 00       	call   8015b2 <cprintf>
	vcprintf(fmt, ap);
  800145:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800149:	8b 45 10             	mov    0x10(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 fd 13 00 00       	call   801551 <vcprintf>
	cprintf("\n");
  800154:	c7 04 24 6a 1e 80 00 	movl   $0x801e6a,(%esp)
  80015b:	e8 52 14 00 00       	call   8015b2 <cprintf>
	va_end(ap);
}
  800160:	83 c4 14             	add    $0x14,%esp
  800163:	5b                   	pop    %ebx
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    
	...

00800168 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 28             	sub    $0x28,%esp
        char c = ch;
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	88 45 f7             	mov    %al,-0x9(%ebp)

        // Unlike standard Unix's putchar,
        // the cputchar function _always_ outputs to the system console.
        sys_cputs(&c, 1);
  800174:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80017b:	00 
  80017c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 3e 07 00 00       	call   8008c5 <sys_cputs>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <getchar>:

int
getchar(void)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
        int r = 0;
        // sys_cgetc does not block, but getchar should.
        //while ((r = sys_cgetc()) == 0);
                //sys_yield();
        return r;
}
  80018c:	b8 00 00 00 00       	mov    $0x0,%eax
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    
	...

008001a0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
  8001a6:	c7 04 24 0e 1e 80 00 	movl   $0x801e0e,(%esp)
  8001ad:	e8 00 14 00 00       	call   8015b2 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
  8001b2:	c7 44 24 08 2c 00 80 	movl   $0x1080002c,0x8(%esp)
  8001b9:	10 
  8001ba:	c7 44 24 04 2c 00 80 	movl   $0x80002c,0x4(%esp)
  8001c1:	00 
  8001c2:	c7 04 24 c4 1e 80 00 	movl   $0x801ec4,(%esp)
  8001c9:	e8 e4 13 00 00       	call   8015b2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
  8001ce:	c7 44 24 08 55 1d 80 	movl   $0x10801d55,0x8(%esp)
  8001d5:	10 
  8001d6:	c7 44 24 04 55 1d 80 	movl   $0x801d55,0x4(%esp)
  8001dd:	00 
  8001de:	c7 04 24 e8 1e 80 00 	movl   $0x801ee8,(%esp)
  8001e5:	e8 c8 13 00 00       	call   8015b2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
  8001ea:	c7 44 24 08 91 fc 80 	movl   $0x1080fc91,0x8(%esp)
  8001f1:	10 
  8001f2:	c7 44 24 04 91 fc 80 	movl   $0x80fc91,0x4(%esp)
  8001f9:	00 
  8001fa:	c7 04 24 0c 1f 80 00 	movl   $0x801f0c,(%esp)
  800201:	e8 ac 13 00 00       	call   8015b2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
  800206:	c7 44 24 08 a4 10 81 	movl   $0x108110a4,0x8(%esp)
  80020d:	10 
  80020e:	c7 44 24 04 a4 10 81 	movl   $0x8110a4,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 30 1f 80 00 	movl   $0x801f30,(%esp)
  80021d:	e8 90 13 00 00       	call   8015b2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
  800222:	b8 2c 00 80 00       	mov    $0x80002c,%eax
  800227:	f7 d8                	neg    %eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
  800229:	8d 90 a2 18 81 00    	lea    0x8118a2(%eax),%edx
		(end-_start+1023)/1024);
  80022f:	05 a3 14 81 00       	add    $0x8114a3,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
  800234:	85 c0                	test   %eax,%eax
  800236:	0f 48 c2             	cmovs  %edx,%eax
  800239:	c1 f8 0a             	sar    $0xa,%eax
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	c7 04 24 54 1f 80 00 	movl   $0x801f54,(%esp)
  800247:	e8 66 13 00 00       	call   8015b2 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
  80024c:	b8 00 00 00 00       	mov    $0x0,%eax
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n",commands[i].name, commands[i].desc);
  800259:	a1 64 20 80 00       	mov    0x802064,%eax
  80025e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800262:	a1 60 20 80 00       	mov    0x802060,%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 27 1e 80 00 	movl   $0x801e27,(%esp)
  800272:	e8 3b 13 00 00       	call   8015b2 <cprintf>
  800277:	a1 70 20 80 00       	mov    0x802070,%eax
  80027c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800280:	a1 6c 20 80 00       	mov    0x80206c,%eax
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	c7 04 24 27 1e 80 00 	movl   $0x801e27,(%esp)
  800290:	e8 1d 13 00 00       	call   8015b2 <cprintf>
  800295:	a1 7c 20 80 00       	mov    0x80207c,%eax
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	a1 78 20 80 00       	mov    0x802078,%eax
  8002a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a7:	c7 04 24 27 1e 80 00 	movl   $0x801e27,(%esp)
  8002ae:	e8 ff 12 00 00       	call   8015b2 <cprintf>
	return 0;
}
  8002b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
  8002c3:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  8002ca:	e8 e3 12 00 00       	call   8015b2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
  8002cf:	c7 04 24 a4 1f 80 00 	movl   $0x801fa4,(%esp)
  8002d6:	e8 d7 12 00 00       	call   8015b2 <cprintf>


	while (1) {
		buf = readline("K> ");
  8002db:	c7 04 24 30 1e 80 00 	movl   $0x801e30,(%esp)
  8002e2:	e8 79 0d 00 00       	call   801060 <readline>
  8002e7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
  8002e9:	85 c0                	test   %eax,%eax
  8002eb:	74 ee                	je     8002db <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
  8002ed:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
  8002f4:	be 00 00 00 00       	mov    $0x0,%esi
  8002f9:	eb 06                	jmp    800301 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
  8002fb:	c6 03 00             	movb   $0x0,(%ebx)
  8002fe:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  800301:	0f b6 03             	movzbl (%ebx),%eax
  800304:	84 c0                	test   %al,%al
  800306:	74 6a                	je     800372 <monitor+0xb8>
  800308:	0f be c0             	movsbl %al,%eax
  80030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030f:	c7 04 24 34 1e 80 00 	movl   $0x801e34,(%esp)
  800316:	e8 3b 0f 00 00       	call   801256 <strchr>
  80031b:	85 c0                	test   %eax,%eax
  80031d:	75 dc                	jne    8002fb <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
  80031f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800322:	74 4e                	je     800372 <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
  800324:	83 fe 0f             	cmp    $0xf,%esi
  800327:	75 16                	jne    80033f <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
  800329:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800330:	00 
  800331:	c7 04 24 39 1e 80 00 	movl   $0x801e39,(%esp)
  800338:	e8 75 12 00 00       	call   8015b2 <cprintf>
  80033d:	eb 9c                	jmp    8002db <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
  80033f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
  800343:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
  800346:	0f b6 03             	movzbl (%ebx),%eax
  800349:	84 c0                	test   %al,%al
  80034b:	75 0c                	jne    800359 <monitor+0x9f>
  80034d:	eb b2                	jmp    800301 <monitor+0x47>
			buf++;
  80034f:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
  800352:	0f b6 03             	movzbl (%ebx),%eax
  800355:	84 c0                	test   %al,%al
  800357:	74 a8                	je     800301 <monitor+0x47>
  800359:	0f be c0             	movsbl %al,%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 34 1e 80 00 	movl   $0x801e34,(%esp)
  800367:	e8 ea 0e 00 00       	call   801256 <strchr>
  80036c:	85 c0                	test   %eax,%eax
  80036e:	74 df                	je     80034f <monitor+0x95>
  800370:	eb 8f                	jmp    800301 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
  800372:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  800379:	00 

	// Lookup and invoke the command
	if (argc == 0)
  80037a:	85 f6                	test   %esi,%esi
  80037c:	0f 84 59 ff ff ff    	je     8002db <monitor+0x21>
  800382:	bb 60 20 80 00       	mov    $0x802060,%ebx
  800387:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
  80038c:	8b 03                	mov    (%ebx),%eax
  80038e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800392:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	e8 3f 0e 00 00       	call   8011dc <strcmp>
  80039d:	85 c0                	test   %eax,%eax
  80039f:	75 23                	jne    8003c4 <monitor+0x10a>
			return commands[i].func(argc, argv, tf);
  8003a1:	6b ff 0c             	imul   $0xc,%edi,%edi
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ab:	8d 45 a8             	lea    -0x58(%ebp),%eax
  8003ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b2:	89 34 24             	mov    %esi,(%esp)
  8003b5:	ff 97 68 20 80 00    	call   *0x802068(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	78 28                	js     8003e7 <monitor+0x12d>
  8003bf:	e9 17 ff ff ff       	jmp    8002db <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
  8003c4:	83 c7 01             	add    $0x1,%edi
  8003c7:	83 c3 0c             	add    $0xc,%ebx
  8003ca:	83 ff 03             	cmp    $0x3,%edi
  8003cd:	75 bd                	jne    80038c <monitor+0xd2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
  8003cf:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8003d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d6:	c7 04 24 56 1e 80 00 	movl   $0x801e56,(%esp)
  8003dd:	e8 d0 11 00 00       	call   8015b2 <cprintf>
  8003e2:	e9 f4 fe ff ff       	jmp    8002db <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
  8003e7:	83 c4 5c             	add    $0x5c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
  8003f2:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	57                   	push   %edi
  8003fb:	56                   	push   %esi
  8003fc:	53                   	push   %ebx
  8003fd:	81 ec 4c 01 00 00    	sub    $0x14c,%esp
	// Your code here.
	int ebp_lst, ebp_cur, ebp_prev, eip_cur, args[5];
	//__asm __volatile("movl %%ebp, %0;":"=r"(ebp_cur));
	ebp_cur = (uint32_t)read_ebp();
  800403:	89 ee                	mov    %ebp,%esi
	cprintf("Stack backtrace:\n");
  800405:	c7 04 24 6c 1e 80 00 	movl   $0x801e6c,(%esp)
  80040c:	e8 a1 11 00 00       	call   8015b2 <cprintf>
	eip_cur = (uint32_t)read_eip();
  800411:	e8 d9 ff ff ff       	call   8003ef <read_eip>
  800416:	89 c7                	mov    %eax,%edi
	struct Eipdebuginfo *e = NULL;
	int k =1;
  800418:	c7 85 e4 fe ff ff 01 	movl   $0x1,-0x11c(%ebp)
  80041f:	00 00 00 
	while(k != 0)	
	{
		if(ebp_cur == 0)
			k =0;				
  800422:	bb 00 00 00 00       	mov    $0x0,%ebx
  800427:	85 f6                	test   %esi,%esi
  800429:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
  80042f:	0f 44 c3             	cmove  %ebx,%eax
  800432:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
		memset(e, 0, sizeof(struct Eipdebuginfo));
  800438:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
  80043f:	00 
  800440:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800444:	89 1c 24             	mov    %ebx,(%esp)
  800447:	e8 65 0e 00 00       	call   8012b1 <memset>
		debuginfo_eip(eip_cur, e);
  80044c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800450:	89 3c 24             	mov    %edi,(%esp)
  800453:	e8 16 02 00 00       	call   80066e <debuginfo_eip>
		__asm __volatile("movl 8(%1), %0;":"=r"(args[0]):"r"(ebp_cur));
  800458:	8b 46 08             	mov    0x8(%esi),%eax
  80045b:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
		__asm __volatile("movl 12(%1), %0;":"=r"(args[1]):"r"(ebp_cur));
  800461:	8b 46 0c             	mov    0xc(%esi),%eax
  800464:	89 85 dc fe ff ff    	mov    %eax,-0x124(%ebp)
		__asm __volatile("movl 16(%1), %0;":"=r"(args[2]):"r"(ebp_cur));
  80046a:	8b 46 10             	mov    0x10(%esi),%eax
  80046d:	89 85 d8 fe ff ff    	mov    %eax,-0x128(%ebp)
		__asm __volatile("movl 20(%1), %0;":"=r"(args[3]):"r"(ebp_cur));
  800473:	8b 46 14             	mov    0x14(%esi),%eax
  800476:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
		__asm __volatile("movl 24(%1), %0;":"=r"(args[4]):"r"(ebp_cur));
  80047c:	8b 46 18             	mov    0x18(%esi),%eax
  80047f:	89 85 d0 fe ff ff    	mov    %eax,-0x130(%ebp)
		char s[256];
		strcpy(s, e->eip_fn_name);
  800485:	8b 43 08             	mov    0x8(%ebx),%eax
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800492:	89 04 24             	mov    %eax,(%esp)
  800495:	e8 b7 0c 00 00       	call   801151 <strcpy>
		s[e->eip_fn_namelen] = '\0';
  80049a:	8b 43 0c             	mov    0xc(%ebx),%eax
  80049d:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
  8004a4:	00 
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n", ebp_cur, eip_cur, args[0], args[1], args[2], args[3], args[4]);
  8004a5:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
  8004ab:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8004af:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
  8004b5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8004b9:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
  8004bf:	89 44 24 14          	mov    %eax,0x14(%esp)
  8004c3:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
  8004c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004cd:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
  8004d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d7:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8004db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004df:	c7 04 24 cc 1f 80 00 	movl   $0x801fcc,(%esp)
  8004e6:	e8 c7 10 00 00       	call   8015b2 <cprintf>
		cprintf("%s:%d:  %s+%d\n", e->eip_file, e->eip_line,s, eip_cur-e->eip_fn_addr);
  8004eb:	2b 7b 10             	sub    0x10(%ebx),%edi
  8004ee:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8004f2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8004ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800503:	8b 03                	mov    (%ebx),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	c7 04 24 7e 1e 80 00 	movl   $0x801e7e,(%esp)
  800510:	e8 9d 10 00 00       	call   8015b2 <cprintf>

		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
  800515:	8b 7e 04             	mov    0x4(%esi),%edi
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		
  800518:	8b 36                	mov    (%esi),%esi
	ebp_cur = (uint32_t)read_ebp();
	cprintf("Stack backtrace:\n");
	eip_cur = (uint32_t)read_eip();
	struct Eipdebuginfo *e = NULL;
	int k =1;
	while(k != 0)	
  80051a:	83 bd e4 fe ff ff 00 	cmpl   $0x0,-0x11c(%ebp)
  800521:	0f 85 00 ff ff ff    	jne    800427 <mon_backtrace+0x30>
		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		

	} 
	return 0;
}
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	81 c4 4c 01 00 00    	add    $0x14c,%esp
  800532:	5b                   	pop    %ebx
  800533:	5e                   	pop    %esi
  800534:	5f                   	pop    %edi
  800535:	5d                   	pop    %ebp
  800536:	c3                   	ret    
	...

00800540 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	57                   	push   %edi
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
  800546:	83 ec 14             	sub    $0x14,%esp
  800549:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80054c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80054f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
  800555:	8b 1a                	mov    (%edx),%ebx
  800557:	8b 01                	mov    (%ecx),%eax
  800559:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
  80055c:	39 c3                	cmp    %eax,%ebx
  80055e:	0f 8f 9c 00 00 00    	jg     800600 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
  800564:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
  80056b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80056e:	01 d8                	add    %ebx,%eax
  800570:	89 c7                	mov    %eax,%edi
  800572:	c1 ef 1f             	shr    $0x1f,%edi
  800575:	01 c7                	add    %eax,%edi
  800577:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
  800579:	39 df                	cmp    %ebx,%edi
  80057b:	7c 33                	jl     8005b0 <stab_binsearch+0x70>
  80057d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
  800580:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800583:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
  800588:	39 f0                	cmp    %esi,%eax
  80058a:	0f 84 bc 00 00 00    	je     80064c <stab_binsearch+0x10c>
  800590:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
  800594:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
  800598:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
  80059a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
  80059d:	39 d8                	cmp    %ebx,%eax
  80059f:	7c 0f                	jl     8005b0 <stab_binsearch+0x70>
  8005a1:	0f b6 0a             	movzbl (%edx),%ecx
  8005a4:	83 ea 0c             	sub    $0xc,%edx
  8005a7:	39 f1                	cmp    %esi,%ecx
  8005a9:	75 ef                	jne    80059a <stab_binsearch+0x5a>
  8005ab:	e9 9e 00 00 00       	jmp    80064e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
  8005b0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
  8005b3:	eb 3c                	jmp    8005f1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
  8005b5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005b8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
  8005ba:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
  8005bd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  8005c4:	eb 2b                	jmp    8005f1 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
  8005c6:	3b 55 0c             	cmp    0xc(%ebp),%edx
  8005c9:	76 14                	jbe    8005df <stab_binsearch+0x9f>
			*region_right = m - 1;
  8005cb:	83 e8 01             	sub    $0x1,%eax
  8005ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d4:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
  8005d6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  8005dd:	eb 12                	jmp    8005f1 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
  8005df:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005e2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
  8005e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  8005e8:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
  8005ea:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
  8005f1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
  8005f4:	0f 8d 71 ff ff ff    	jge    80056b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
  8005fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fe:	75 0f                	jne    80060f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
  800600:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800603:	8b 03                	mov    (%ebx),%eax
  800605:	83 e8 01             	sub    $0x1,%eax
  800608:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80060b:	89 02                	mov    %eax,(%edx)
  80060d:	eb 57                	jmp    800666 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  80060f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800612:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
  800614:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800617:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800619:	39 c1                	cmp    %eax,%ecx
  80061b:	7d 28                	jge    800645 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
  80061d:	8d 14 40             	lea    (%eax,%eax,2),%edx
  800620:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800623:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
  800628:	39 f2                	cmp    %esi,%edx
  80062a:	74 19                	je     800645 <stab_binsearch+0x105>
  80062c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
  800630:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
  800634:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800637:	39 c1                	cmp    %eax,%ecx
  800639:	7d 0a                	jge    800645 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
  80063b:	0f b6 1a             	movzbl (%edx),%ebx
  80063e:	83 ea 0c             	sub    $0xc,%edx
  800641:	39 f3                	cmp    %esi,%ebx
  800643:	75 ef                	jne    800634 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
  800645:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800648:	89 02                	mov    %eax,(%edx)
  80064a:	eb 1a                	jmp    800666 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
  80064c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
  80064e:	8d 14 40             	lea    (%eax,%eax,2),%edx
  800651:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800654:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
  800658:	3b 55 0c             	cmp    0xc(%ebp),%edx
  80065b:	0f 82 54 ff ff ff    	jb     8005b5 <stab_binsearch+0x75>
  800661:	e9 60 ff ff ff       	jmp    8005c6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
  800666:	83 c4 14             	add    $0x14,%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5f                   	pop    %edi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 58             	sub    $0x58,%esp
  800674:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800677:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80067a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80067d:	8b 75 08             	mov    0x8(%ebp),%esi
  800680:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
  800683:	c7 03 84 20 80 00    	movl   $0x802084,(%ebx)
	info->eip_line = 0;
  800689:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
  800690:	c7 43 08 84 20 80 00 	movl   $0x802084,0x8(%ebx)
	info->eip_fn_namelen = 9;
  800697:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
  80069e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
  8006a1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
  8006a8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
  8006ae:	76 12                	jbe    8006c2 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
  8006b0:	b8 04 65 20 00       	mov    $0x206504,%eax
  8006b5:	3d 2d 41 20 00       	cmp    $0x20412d,%eax
  8006ba:	0f 86 aa 01 00 00    	jbe    80086a <debuginfo_eip+0x1fc>
  8006c0:	eb 1c                	jmp    8006de <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
  8006c2:	c7 44 24 08 8e 20 80 	movl   $0x80208e,0x8(%esp)
  8006c9:	00 
  8006ca:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8006d1:	00 
  8006d2:	c7 04 24 9b 20 80 00 	movl   $0x80209b,(%esp)
  8006d9:	e8 e4 f9 ff ff       	call   8000c2 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
  8006de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
  8006e3:	80 3d 03 65 20 00 00 	cmpb   $0x0,0x206503
  8006ea:	0f 85 86 01 00 00    	jne    800876 <debuginfo_eip+0x208>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
  8006f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
  8006f7:	b8 2c 41 20 00       	mov    $0x20412c,%eax
  8006fc:	2d 10 00 20 00       	sub    $0x200010,%eax
  800701:	c1 f8 02             	sar    $0x2,%eax
  800704:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  80070a:	83 e8 01             	sub    $0x1,%eax
  80070d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  800710:	89 74 24 04          	mov    %esi,0x4(%esp)
  800714:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  80071b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  80071e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800721:	b8 10 00 20 00       	mov    $0x200010,%eax
  800726:	e8 15 fe ff ff       	call   800540 <stab_binsearch>
	if (lfile == 0)
  80072b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
  80072e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
  800733:	85 d2                	test   %edx,%edx
  800735:	0f 84 3b 01 00 00    	je     800876 <debuginfo_eip+0x208>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
  80073b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
  80073e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  800744:	89 74 24 04          	mov    %esi,0x4(%esp)
  800748:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
  80074f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  800752:	8d 55 dc             	lea    -0x24(%ebp),%edx
  800755:	b8 10 00 20 00       	mov    $0x200010,%eax
  80075a:	e8 e1 fd ff ff       	call   800540 <stab_binsearch>

	if (lfun <= rfun) {
  80075f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800762:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800765:	39 d0                	cmp    %edx,%eax
  800767:	7f 3a                	jg     8007a3 <debuginfo_eip+0x135>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
  800769:	6b c8 0c             	imul   $0xc,%eax,%ecx
  80076c:	8b 89 10 00 20 00    	mov    0x200010(%ecx),%ecx
  800772:	bf 04 65 20 00       	mov    $0x206504,%edi
  800777:	81 ef 2d 41 20 00    	sub    $0x20412d,%edi
  80077d:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800780:	39 f9                	cmp    %edi,%ecx
  800782:	73 09                	jae    80078d <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  800784:	81 c1 2d 41 20 00    	add    $0x20412d,%ecx
  80078a:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
  80078d:	6b c8 0c             	imul   $0xc,%eax,%ecx
  800790:	8b 89 18 00 20 00    	mov    0x200018(%ecx),%ecx
  800796:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
  800799:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
  80079b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
  80079e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8007a1:	eb 0f                	jmp    8007b2 <debuginfo_eip+0x144>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
  8007a3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
  8007a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  8007b2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8007b9:	00 
  8007ba:	8b 43 08             	mov    0x8(%ebx),%eax
  8007bd:	89 04 24             	mov    %eax,(%esp)
  8007c0:	e8 c5 0a 00 00       	call   80128a <strfind>
  8007c5:	2b 43 08             	sub    0x8(%ebx),%eax
  8007c8:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  8007cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007cf:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
  8007d6:	8d 4d d0             	lea    -0x30(%ebp),%ecx
  8007d9:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  8007dc:	b8 10 00 20 00       	mov    $0x200010,%eax
  8007e1:	e8 5a fd ff ff       	call   800540 <stab_binsearch>
	if(lline <= rline) {
  8007e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
		info->eip_line = rline;
  8007e9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  8007ec:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8007f1:	0f 4f c2             	cmovg  %edx,%eax
  8007f4:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
  8007f7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
  8007fd:	6b d0 0c             	imul   $0xc,%eax,%edx
  800800:	81 c2 18 00 20 00    	add    $0x200018,%edx
  800806:	eb 06                	jmp    80080e <debuginfo_eip+0x1a0>
  800808:	83 e8 01             	sub    $0x1,%eax
  80080b:	83 ea 0c             	sub    $0xc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
  80080e:	39 c6                	cmp    %eax,%esi
  800810:	7f 1c                	jg     80082e <debuginfo_eip+0x1c0>
	       && stabs[lline].n_type != N_SOL
  800812:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
  800816:	80 f9 84             	cmp    $0x84,%cl
  800819:	74 68                	je     800883 <debuginfo_eip+0x215>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
  80081b:	80 f9 64             	cmp    $0x64,%cl
  80081e:	75 e8                	jne    800808 <debuginfo_eip+0x19a>
  800820:	83 3a 00             	cmpl   $0x0,(%edx)
  800823:	74 e3                	je     800808 <debuginfo_eip+0x19a>
  800825:	eb 5c                	jmp    800883 <debuginfo_eip+0x215>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
  800827:	05 2d 41 20 00       	add    $0x20412d,%eax
  80082c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
  80082e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800831:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
  800839:	39 fa                	cmp    %edi,%edx
  80083b:	7d 39                	jge    800876 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
  80083d:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
  800840:	6b d0 0c             	imul   $0xc,%eax,%edx
  800843:	81 c2 14 00 20 00    	add    $0x200014,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
  800849:	eb 07                	jmp    800852 <debuginfo_eip+0x1e4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
  80084b:	83 43 14 01          	addl   $0x1,0x14(%ebx)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
  80084f:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
  800852:	39 c7                	cmp    %eax,%edi
  800854:	7e 1b                	jle    800871 <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
  800856:	0f b6 32             	movzbl (%edx),%esi
  800859:	83 c2 0c             	add    $0xc,%edx
  80085c:	89 f1                	mov    %esi,%ecx
  80085e:	80 f9 a0             	cmp    $0xa0,%cl
  800861:	74 e8                	je     80084b <debuginfo_eip+0x1dd>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb 0c                	jmp    800876 <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
  80086a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80086f:	eb 05                	jmp    800876 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800876:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800879:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80087c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80087f:	89 ec                	mov    %ebp,%esp
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
  800883:	6b c0 0c             	imul   $0xc,%eax,%eax
  800886:	8b 80 10 00 20 00    	mov    0x200010(%eax),%eax
  80088c:	ba 04 65 20 00       	mov    $0x206504,%edx
  800891:	81 ea 2d 41 20 00    	sub    $0x20412d,%edx
  800897:	39 d0                	cmp    %edx,%eax
  800899:	72 8c                	jb     800827 <debuginfo_eip+0x1b9>
  80089b:	eb 91                	jmp    80082e <debuginfo_eip+0x1c0>
  80089d:	00 00                	add    %al,(%eax)
	...

008008a0 <getEnvID>:
  //              panic("syscall %d returned %d (> 0)", num, ret);
        return ret;
}

void getEnvID(char* msg)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
	//VMM_ID = curenv.env_id; 	
	cprintf("%s\n",msg);
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ad:	c7 04 24 2c 1e 80 00 	movl   $0x801e2c,(%esp)
  8008b4:	e8 f9 0c 00 00       	call   8015b2 <cprintf>
	VMM_ID = -1;	
  8008b9:	c7 05 a4 fc 80 00 ff 	movl   $0xffffffff,0x80fca4
  8008c0:	ff ff ff 
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	83 ec 28             	sub    $0x28,%esp
  8008cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8008d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_cputs() From Guest OS...");
  8008d4:	c7 04 24 a9 20 80 00 	movl   $0x8020a9,(%esp)
  8008db:	e8 c0 ff ff ff       	call   8008a0 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e5:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f1:	89 c3                	mov    %eax,%ebx
  8008f3:	89 c7                	mov    %eax,%edi
  8008f5:	cd 30                	int    $0x30
void
sys_cputs(const char *s, size_t len)
{
	getEnvID("sys_cputs() From Guest OS...");
        syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, VMM_ID);
}
  8008f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8008fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8008fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800900:	89 ec                	mov    %ebp,%esp
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <sys_env_setup_vm>:

int
sys_env_setup_vm(void *e )
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 28             	sub    $0x28,%esp
  80090a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80090d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800910:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_env_setup() From Guest OS...");
  800913:	c7 04 24 e4 20 80 00 	movl   $0x8020e4,(%esp)
  80091a:	e8 81 ff ff ff       	call   8008a0 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  80091f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800924:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  80092a:	b8 01 00 00 00       	mov    $0x1,%eax
  80092f:	8b 55 08             	mov    0x8(%ebp),%edx
  800932:	89 cb                	mov    %ecx,%ebx
  800934:	89 cf                	mov    %ecx,%edi
  800936:	cd 30                	int    $0x30
sys_env_setup_vm(void *e )
{
	getEnvID("sys_env_setup() From Guest OS...");
	int r = syscall(SYS_env_setup_vm, 0, (uint32_t)e, 0, 0, 0, VMM_ID);
	return r;
}
  800938:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80093b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80093e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800941:	89 ec                	mov    %ebp,%esp
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <sys_page_alloc>:

int
sys_page_alloc(int i, struct Env* e, void* va, int perm)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 28             	sub    $0x28,%esp
  80094b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80094e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800951:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_page_alloc() From Guest OS...");
  800954:	c7 04 24 08 21 80 00 	movl   $0x802108,(%esp)
  80095b:	e8 40 ff ff ff       	call   8008a0 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  800960:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  800966:	b8 02 00 00 00       	mov    $0x2,%eax
  80096b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80096e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800974:	8b 55 08             	mov    0x8(%ebp),%edx
  800977:	cd 30                	int    $0x30
sys_page_alloc(int i, struct Env* e, void* va, int perm)
{
	getEnvID("sys_page_alloc() From Guest OS...");
	int r = syscall(SYS_page_alloc, 0, i, (uint32_t)e, (uint32_t)va, perm, VMM_ID);
	return r;
}
  800979:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80097c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80097f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800982:	89 ec                	mov    %ebp,%esp
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <sys_load_icode>:


int
sys_load_icode(void* e, void* b, int len)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 28             	sub    $0x28,%esp
  80098c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80098f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800992:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_load_icode() From Guest OS...");
  800995:	c7 04 24 2c 21 80 00 	movl   $0x80212c,(%esp)
  80099c:	e8 ff fe ff ff       	call   8008a0 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  8009a1:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  8009a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8009b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ba:	cd 30                	int    $0x30
sys_load_icode(void* e, void* b, int len)
{
	getEnvID("sys_load_icode() From Guest OS...");
	int r = syscall(SYS_load_icode, 0, (uint32_t)e, (uint32_t)b, len, 0, VMM_ID);
	return r;
}
  8009bc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009bf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009c5:	89 ec                	mov    %ebp,%esp
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <sys_lcr3>:

int
sys_lcr3(uint32_t cr3)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 28             	sub    $0x28,%esp
  8009cf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009d2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009d5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_lcr3() From Guest OS...");
  8009d8:	c7 04 24 c6 20 80 00 	movl   $0x8020c6,(%esp)
  8009df:	e8 bc fe ff ff       	call   8008a0 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  8009e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e9:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  8009ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8009f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f7:	89 cb                	mov    %ecx,%ebx
  8009f9:	89 cf                	mov    %ecx,%edi
  8009fb:	cd 30                	int    $0x30
sys_lcr3(uint32_t cr3)
{
	getEnvID("sys_lcr3() From Guest OS...");
	int r = syscall(SYS_lcr3, 0, cr3, 0, 0, 0, VMM_ID);
	return r;
}
  8009fd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a00:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a03:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a06:	89 ec                	mov    %ebp,%esp
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <sys_env_pop_tf>:

int
sys_env_pop_tf(uint32_t e)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 28             	sub    $0x28,%esp
  800a10:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a13:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a16:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_env_pop_tf() From Guest OS...");
  800a19:	c7 04 24 50 21 80 00 	movl   $0x802150,(%esp)
  800a20:	e8 7b fe ff ff       	call   8008a0 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  800a25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2a:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  800a30:	b8 05 00 00 00       	mov    $0x5,%eax
  800a35:	8b 55 08             	mov    0x8(%ebp),%edx
  800a38:	89 cb                	mov    %ecx,%ebx
  800a3a:	89 cf                	mov    %ecx,%edi
  800a3c:	cd 30                	int    $0x30
sys_env_pop_tf(uint32_t e)
{
	getEnvID("sys_env_pop_tf() From Guest OS...");
	int r = syscall(SYS_run, 0, e, 0, 0, 0, VMM_ID);
	return r;
}
  800a3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a47:	89 ec                	mov    %ebp,%esp
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    
  800a4b:	00 00                	add    %al,(%eax)
  800a4d:	00 00                	add    %al,(%eax)
	...

00800a50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	83 ec 4c             	sub    $0x4c,%esp
  800a59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a5c:	89 d6                	mov    %edx,%esi
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a67:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a6a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a6d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	72 11                	jb     800a8a <printnum+0x3a>
  800a79:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a7c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  800a7f:	76 09                	jbe    800a8a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800a81:	83 eb 01             	sub    $0x1,%ebx
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	7f 5d                	jg     800ae5 <printnum+0x95>
  800a88:	eb 6c                	jmp    800af6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a8a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800a8e:	83 eb 01             	sub    $0x1,%ebx
  800a91:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a9c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800aa0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800aa4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aa7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800aaa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ab1:	00 
  800ab2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ab5:	89 14 24             	mov    %edx,(%esp)
  800ab8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800abb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800abf:	e8 3c 10 00 00       	call   801b00 <__udivdi3>
  800ac4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ac7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800aca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ace:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ad2:	89 04 24             	mov    %eax,(%esp)
  800ad5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad9:	89 f2                	mov    %esi,%edx
  800adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ade:	e8 6d ff ff ff       	call   800a50 <printnum>
  800ae3:	eb 11                	jmp    800af6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ae5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae9:	89 3c 24             	mov    %edi,(%esp)
  800aec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800aef:	83 eb 01             	sub    $0x1,%ebx
  800af2:	85 db                	test   %ebx,%ebx
  800af4:	7f ef                	jg     800ae5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800af6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800afa:	8b 74 24 04          	mov    0x4(%esp),%esi
  800afe:	8b 45 10             	mov    0x10(%ebp),%eax
  800b01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b05:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b0c:	00 
  800b0d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b10:	89 14 24             	mov    %edx,(%esp)
  800b13:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b16:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b1a:	e8 f1 10 00 00       	call   801c10 <__umoddi3>
  800b1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b23:	0f be 80 72 21 80 00 	movsbl 0x802172(%eax),%eax
  800b2a:	89 04 24             	mov    %eax,(%esp)
  800b2d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800b30:	83 c4 4c             	add    $0x4c,%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b3b:	83 fa 01             	cmp    $0x1,%edx
  800b3e:	7e 0e                	jle    800b4e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b40:	8b 10                	mov    (%eax),%edx
  800b42:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b45:	89 08                	mov    %ecx,(%eax)
  800b47:	8b 02                	mov    (%edx),%eax
  800b49:	8b 52 04             	mov    0x4(%edx),%edx
  800b4c:	eb 22                	jmp    800b70 <getuint+0x38>
	else if (lflag)
  800b4e:	85 d2                	test   %edx,%edx
  800b50:	74 10                	je     800b62 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b52:	8b 10                	mov    (%eax),%edx
  800b54:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b57:	89 08                	mov    %ecx,(%eax)
  800b59:	8b 02                	mov    (%edx),%eax
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	eb 0e                	jmp    800b70 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b62:	8b 10                	mov    (%eax),%edx
  800b64:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b67:	89 08                	mov    %ecx,(%eax)
  800b69:	8b 02                	mov    (%edx),%eax
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b78:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800b7c:	8b 10                	mov    (%eax),%edx
  800b7e:	3b 50 04             	cmp    0x4(%eax),%edx
  800b81:	73 0a                	jae    800b8d <sprintputch+0x1b>
		*b->buf++ = ch;
  800b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b86:	88 0a                	mov    %cl,(%edx)
  800b88:	83 c2 01             	add    $0x1,%edx
  800b8b:	89 10                	mov    %edx,(%eax)
}
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b95:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	89 04 24             	mov    %eax,(%esp)
  800bb0:	e8 02 00 00 00       	call   800bb7 <vprintfmt>
	va_end(ap);
}
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 4c             	sub    $0x4c,%esp
  800bc0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc6:	eb 12                	jmp    800bda <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	0f 84 00 04 00 00    	je     800fd0 <vprintfmt+0x419>
				return;
			putch(ch, putdat);
  800bd0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd4:	89 04 24             	mov    %eax,(%esp)
  800bd7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bda:	0f b6 03             	movzbl (%ebx),%eax
  800bdd:	83 c3 01             	add    $0x1,%ebx
  800be0:	83 f8 25             	cmp    $0x25,%eax
  800be3:	75 e3                	jne    800bc8 <vprintfmt+0x11>
  800be5:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800be9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800bf0:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800bf5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800bfc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c03:	89 d8                	mov    %ebx,%eax
  800c05:	eb 23                	jmp    800c2a <vprintfmt+0x73>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c07:	89 d8                	mov    %ebx,%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800c09:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800c0d:	eb 1b                	jmp    800c2a <vprintfmt+0x73>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c0f:	89 d8                	mov    %ebx,%eax
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c11:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800c15:	eb 13                	jmp    800c2a <vprintfmt+0x73>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c17:	89 d8                	mov    %ebx,%eax
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800c19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800c20:	eb 08                	jmp    800c2a <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800c22:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800c25:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c2a:	0f b6 08             	movzbl (%eax),%ecx
  800c2d:	0f b6 d1             	movzbl %cl,%edx
  800c30:	8d 58 01             	lea    0x1(%eax),%ebx
  800c33:	83 e9 23             	sub    $0x23,%ecx
  800c36:	80 f9 55             	cmp    $0x55,%cl
  800c39:	0f 87 6f 03 00 00    	ja     800fae <vprintfmt+0x3f7>
  800c3f:	0f b6 c9             	movzbl %cl,%ecx
  800c42:	ff 24 8d 00 22 80 00 	jmp    *0x802200(,%ecx,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c49:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  800c4c:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800c4f:	8d 4a d0             	lea    -0x30(%edx),%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c52:	89 d8                	mov    %ebx,%eax
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800c54:	83 f9 09             	cmp    $0x9,%ecx
  800c57:	77 3b                	ja     800c94 <vprintfmt+0xdd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c59:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800c5c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  800c5f:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  800c63:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800c66:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c69:	83 f9 09             	cmp    $0x9,%ecx
  800c6c:	76 eb                	jbe    800c59 <vprintfmt+0xa2>
  800c6e:	eb 24                	jmp    800c94 <vprintfmt+0xdd>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c70:	8b 45 14             	mov    0x14(%ebp),%eax
  800c73:	8d 50 04             	lea    0x4(%eax),%edx
  800c76:	89 55 14             	mov    %edx,0x14(%ebp)
  800c79:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7b:	89 d8                	mov    %ebx,%eax
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c7d:	eb 15                	jmp    800c94 <vprintfmt+0xdd>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7f:	89 d8                	mov    %ebx,%eax
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800c81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c85:	79 a3                	jns    800c2a <vprintfmt+0x73>
  800c87:	eb 8e                	jmp    800c17 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c89:	89 d8                	mov    %ebx,%eax
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c8b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800c92:	eb 96                	jmp    800c2a <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  800c94:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c98:	79 90                	jns    800c2a <vprintfmt+0x73>
  800c9a:	eb 86                	jmp    800c22 <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c9c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca0:	89 d8                	mov    %ebx,%eax
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ca2:	eb 86                	jmp    800c2a <vprintfmt+0x73>
  800ca4:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ca7:	8b 45 14             	mov    0x14(%ebp),%eax
  800caa:	8d 50 04             	lea    0x4(%eax),%edx
  800cad:	89 55 14             	mov    %edx,0x14(%ebp)
  800cb0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cb4:	8b 00                	mov    (%eax),%eax
  800cb6:	89 04 24             	mov    %eax,(%esp)
  800cb9:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cbc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800cbf:	e9 16 ff ff ff       	jmp    800bda <vprintfmt+0x23>
  800cc4:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800cc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cca:	8d 50 04             	lea    0x4(%eax),%edx
  800ccd:	89 55 14             	mov    %edx,0x14(%ebp)
  800cd0:	8b 00                	mov    (%eax),%eax
  800cd2:	89 c2                	mov    %eax,%edx
  800cd4:	c1 fa 1f             	sar    $0x1f,%edx
  800cd7:	31 d0                	xor    %edx,%eax
  800cd9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800cdb:	83 f8 06             	cmp    $0x6,%eax
  800cde:	7f 0b                	jg     800ceb <vprintfmt+0x134>
  800ce0:	8b 14 85 58 23 80 00 	mov    0x802358(,%eax,4),%edx
  800ce7:	85 d2                	test   %edx,%edx
  800ce9:	75 23                	jne    800d0e <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800ceb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cef:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  800cf6:	00 
  800cf7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	89 04 24             	mov    %eax,(%esp)
  800d01:	e8 89 fe ff ff       	call   800b8f <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d06:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d09:	e9 cc fe ff ff       	jmp    800bda <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800d0e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d12:	c7 44 24 08 93 21 80 	movl   $0x802193,0x8(%esp)
  800d19:	00 
  800d1a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 14 24             	mov    %edx,(%esp)
  800d24:	e8 66 fe ff ff       	call   800b8f <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d29:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800d2c:	e9 a9 fe ff ff       	jmp    800bda <vprintfmt+0x23>
  800d31:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d37:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3d:	8d 50 04             	lea    0x4(%eax),%edx
  800d40:	89 55 14             	mov    %edx,0x14(%ebp)
  800d43:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800d45:	85 c0                	test   %eax,%eax
  800d47:	ba 83 21 80 00       	mov    $0x802183,%edx
  800d4c:	0f 45 d0             	cmovne %eax,%edx
  800d4f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if (width > 0 && padc != '-')
  800d52:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800d56:	7e 06                	jle    800d5e <vprintfmt+0x1a7>
  800d58:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d5c:	75 19                	jne    800d77 <vprintfmt+0x1c0>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d61:	0f be 02             	movsbl (%edx),%eax
  800d64:	83 c2 01             	add    $0x1,%edx
  800d67:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	0f 85 97 00 00 00    	jne    800e09 <vprintfmt+0x252>
  800d72:	e9 84 00 00 00       	jmp    800dfb <vprintfmt+0x244>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d77:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d7e:	89 04 24             	mov    %eax,(%esp)
  800d81:	e8 a5 03 00 00       	call   80112b <strnlen>
  800d86:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800d89:	29 c2                	sub    %eax,%edx
  800d8b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d8e:	85 d2                	test   %edx,%edx
  800d90:	7e cc                	jle    800d5e <vprintfmt+0x1a7>
					putch(padc, putdat);
  800d92:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800d96:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800d99:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800d9c:	89 d3                	mov    %edx,%ebx
  800d9e:	89 c6                	mov    %eax,%esi
  800da0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800da4:	89 34 24             	mov    %esi,(%esp)
  800da7:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800daa:	83 eb 01             	sub    $0x1,%ebx
  800dad:	85 db                	test   %ebx,%ebx
  800daf:	7f ef                	jg     800da0 <vprintfmt+0x1e9>
  800db1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800db4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800db7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800dbe:	eb 9e                	jmp    800d5e <vprintfmt+0x1a7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dc0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dc4:	74 18                	je     800dde <vprintfmt+0x227>
  800dc6:	8d 50 e0             	lea    -0x20(%eax),%edx
  800dc9:	83 fa 5e             	cmp    $0x5e,%edx
  800dcc:	76 10                	jbe    800dde <vprintfmt+0x227>
					putch('?', putdat);
  800dce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dd2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800dd9:	ff 55 08             	call   *0x8(%ebp)
  800ddc:	eb 0a                	jmp    800de8 <vprintfmt+0x231>
				else
					putch(ch, putdat);
  800dde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800de2:	89 04 24             	mov    %eax,(%esp)
  800de5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800de8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800dec:	0f be 03             	movsbl (%ebx),%eax
  800def:	85 c0                	test   %eax,%eax
  800df1:	74 05                	je     800df8 <vprintfmt+0x241>
  800df3:	83 c3 01             	add    $0x1,%ebx
  800df6:	eb 17                	jmp    800e0f <vprintfmt+0x258>
  800df8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800dfb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dff:	7f 1c                	jg     800e1d <vprintfmt+0x266>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e01:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e04:	e9 d1 fd ff ff       	jmp    800bda <vprintfmt+0x23>
  800e09:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800e0c:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e0f:	85 f6                	test   %esi,%esi
  800e11:	78 ad                	js     800dc0 <vprintfmt+0x209>
  800e13:	83 ee 01             	sub    $0x1,%esi
  800e16:	79 a8                	jns    800dc0 <vprintfmt+0x209>
  800e18:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800e1b:	eb de                	jmp    800dfb <vprintfmt+0x244>
  800e1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e20:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  800e23:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e26:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e2a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e31:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e33:	83 eb 01             	sub    $0x1,%ebx
  800e36:	85 db                	test   %ebx,%ebx
  800e38:	7f ec                	jg     800e26 <vprintfmt+0x26f>
  800e3a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e3d:	e9 98 fd ff ff       	jmp    800bda <vprintfmt+0x23>
  800e42:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e45:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
  800e49:	7e 10                	jle    800e5b <vprintfmt+0x2a4>
		return va_arg(*ap, long long);
  800e4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e4e:	8d 50 08             	lea    0x8(%eax),%edx
  800e51:	89 55 14             	mov    %edx,0x14(%ebp)
  800e54:	8b 18                	mov    (%eax),%ebx
  800e56:	8b 70 04             	mov    0x4(%eax),%esi
  800e59:	eb 28                	jmp    800e83 <vprintfmt+0x2cc>
	else if (lflag)
  800e5b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e5f:	74 12                	je     800e73 <vprintfmt+0x2bc>
		return va_arg(*ap, long);
  800e61:	8b 45 14             	mov    0x14(%ebp),%eax
  800e64:	8d 50 04             	lea    0x4(%eax),%edx
  800e67:	89 55 14             	mov    %edx,0x14(%ebp)
  800e6a:	8b 18                	mov    (%eax),%ebx
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	c1 fe 1f             	sar    $0x1f,%esi
  800e71:	eb 10                	jmp    800e83 <vprintfmt+0x2cc>
	else
		return va_arg(*ap, int);
  800e73:	8b 45 14             	mov    0x14(%ebp),%eax
  800e76:	8d 50 04             	lea    0x4(%eax),%edx
  800e79:	89 55 14             	mov    %edx,0x14(%ebp)
  800e7c:	8b 18                	mov    (%eax),%ebx
  800e7e:	89 de                	mov    %ebx,%esi
  800e80:	c1 fe 1f             	sar    $0x1f,%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e83:	ba 0a 00 00 00       	mov    $0xa,%edx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800e88:	85 f6                	test   %esi,%esi
  800e8a:	0f 89 dd 00 00 00    	jns    800f6d <vprintfmt+0x3b6>
				putch('-', putdat);
  800e90:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e94:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e9b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e9e:	f7 db                	neg    %ebx
  800ea0:	83 d6 00             	adc    $0x0,%esi
  800ea3:	f7 de                	neg    %esi
			}
			base = 10;
  800ea5:	ba 0a 00 00 00       	mov    $0xa,%edx
  800eaa:	e9 be 00 00 00       	jmp    800f6d <vprintfmt+0x3b6>
  800eaf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800eb2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800eb5:	8d 45 14             	lea    0x14(%ebp),%eax
  800eb8:	e8 7b fc ff ff       	call   800b38 <getuint>
  800ebd:	89 c3                	mov    %eax,%ebx
  800ebf:	89 d6                	mov    %edx,%esi
			base = 10;
  800ec1:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800ec6:	e9 a2 00 00 00       	jmp    800f6d <vprintfmt+0x3b6>

		case 'k':
			COLOR = getuint(&ap, 0);
  800ecb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ed3:	e8 60 fc ff ff       	call   800b38 <getuint>
			COLOR = COLOR | ~0xFF;
  800ed8:	0d 00 ff ff ff       	or     $0xffffff00,%eax
  800edd:	a3 00 30 80 00       	mov    %eax,0x803000
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ee2:	89 d8                	mov    %ebx,%eax
  800ee4:	e9 41 fd ff ff       	jmp    800c2a <vprintfmt+0x73>
  800ee9:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			COLOR = COLOR | ~0xFF;
			goto reswitch;
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800eec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800eef:	8d 45 14             	lea    0x14(%ebp),%eax
  800ef2:	e8 41 fc ff ff       	call   800b38 <getuint>
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800efb:	ba 08 00 00 00       	mov    $0x8,%edx
			goto reswitch;
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			if ((long long) num < 0) {
  800f00:	85 f6                	test   %esi,%esi
  800f02:	79 69                	jns    800f6d <vprintfmt+0x3b6>
				putch('-', putdat);
  800f04:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f08:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f0f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f12:	f7 db                	neg    %ebx
  800f14:	83 d6 00             	adc    $0x0,%esi
  800f17:	f7 de                	neg    %esi
			}
			base = 8;
  800f19:	ba 08 00 00 00       	mov    $0x8,%edx
  800f1e:	eb 4d                	jmp    800f6d <vprintfmt+0x3b6>
  800f20:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800f23:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f27:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f2e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f31:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f35:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f3c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f42:	8d 50 04             	lea    0x4(%eax),%edx
  800f45:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f48:	8b 18                	mov    (%eax),%ebx
  800f4a:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f4f:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800f54:	eb 17                	jmp    800f6d <vprintfmt+0x3b6>
  800f56:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f59:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f5c:	8d 45 14             	lea    0x14(%ebp),%eax
  800f5f:	e8 d4 fb ff ff       	call   800b38 <getuint>
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	89 d6                	mov    %edx,%esi
			base = 16;
  800f68:	ba 10 00 00 00       	mov    $0x10,%edx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f6d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800f71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f80:	89 1c 24             	mov    %ebx,(%esp)
  800f83:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f87:	89 fa                	mov    %edi,%edx
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	e8 bf fa ff ff       	call   800a50 <printnum>
			break;
  800f91:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800f94:	e9 41 fc ff ff       	jmp    800bda <vprintfmt+0x23>
  800f99:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fa0:	89 14 24             	mov    %edx,(%esp)
  800fa3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fa6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fa9:	e9 2c fc ff ff       	jmp    800bda <vprintfmt+0x23>
  800fae:	89 c3                	mov    %eax,%ebx
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fb0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fb4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800fbb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fbe:	eb 02                	jmp    800fc2 <vprintfmt+0x40b>
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fc5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800fc9:	75 f5                	jne    800fc0 <vprintfmt+0x409>
  800fcb:	e9 0a fc ff ff       	jmp    800bda <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800fd0:	83 c4 4c             	add    $0x4c,%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 28             	sub    $0x28,%esp
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fe4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800feb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	74 30                	je     801029 <vsnprintf+0x51>
  800ff9:	85 d2                	test   %edx,%edx
  800ffb:	7e 2c                	jle    801029 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ffd:	8b 45 14             	mov    0x14(%ebp),%eax
  801000:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801004:	8b 45 10             	mov    0x10(%ebp),%eax
  801007:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80100e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801012:	c7 04 24 72 0b 80 00 	movl   $0x800b72,(%esp)
  801019:	e8 99 fb ff ff       	call   800bb7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80101e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801021:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801027:	eb 05                	jmp    80102e <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801029:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801036:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80103d:	8b 45 10             	mov    0x10(%ebp),%eax
  801040:	89 44 24 08          	mov    %eax,0x8(%esp)
  801044:	8b 45 0c             	mov    0xc(%ebp),%eax
  801047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	89 04 24             	mov    %eax,(%esp)
  801051:	e8 82 ff ff ff       	call   800fd8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    
	...

00801060 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	83 ec 10             	sub    $0x10,%esp
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
  80106b:	85 c0                	test   %eax,%eax
  80106d:	74 10                	je     80107f <readline+0x1f>
		cprintf("%s", prompt);
  80106f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801073:	c7 04 24 93 21 80 00 	movl   $0x802193,(%esp)
  80107a:	e8 33 05 00 00       	call   8015b2 <cprintf>
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80107f:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("%s", prompt);

	i = 0;
	echoing = 1;
	while (1) {
		c = getchar();
  801084:	e8 00 f1 ff ff       	call   800189 <getchar>
  801089:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80108b:	85 c0                	test   %eax,%eax
  80108d:	79 17                	jns    8010a6 <readline+0x46>
			cprintf("read error: %e\n", c);
  80108f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801093:	c7 04 24 74 23 80 00 	movl   $0x802374,(%esp)
  80109a:	e8 13 05 00 00       	call   8015b2 <cprintf>
			return NULL;
  80109f:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a4:	eb 61                	jmp    801107 <readline+0xa7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010a6:	83 f8 08             	cmp    $0x8,%eax
  8010a9:	74 05                	je     8010b0 <readline+0x50>
  8010ab:	83 f8 7f             	cmp    $0x7f,%eax
  8010ae:	75 15                	jne    8010c5 <readline+0x65>
  8010b0:	85 f6                	test   %esi,%esi
  8010b2:	7e 11                	jle    8010c5 <readline+0x65>
			if (echoing)
				cputchar('\b');
  8010b4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010bb:	e8 a8 f0 ff ff       	call   800168 <cputchar>
			i--;
  8010c0:	83 ee 01             	sub    $0x1,%esi
  8010c3:	eb bf                	jmp    801084 <readline+0x24>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010c5:	83 fb 1f             	cmp    $0x1f,%ebx
  8010c8:	7e 1b                	jle    8010e5 <readline+0x85>
  8010ca:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010d0:	7f 13                	jg     8010e5 <readline+0x85>
			if (echoing)
				cputchar(c);
  8010d2:	89 1c 24             	mov    %ebx,(%esp)
  8010d5:	e8 8e f0 ff ff       	call   800168 <cputchar>
			buf[i++] = c;
  8010da:	88 9e c0 fc 80 00    	mov    %bl,0x80fcc0(%esi)
  8010e0:	83 c6 01             	add    $0x1,%esi
  8010e3:	eb 9f                	jmp    801084 <readline+0x24>
		} else if (c == '\n' || c == '\r') {
  8010e5:	83 fb 0a             	cmp    $0xa,%ebx
  8010e8:	74 05                	je     8010ef <readline+0x8f>
  8010ea:	83 fb 0d             	cmp    $0xd,%ebx
  8010ed:	75 95                	jne    801084 <readline+0x24>
			if (echoing)
				cputchar('\n');
  8010ef:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8010f6:	e8 6d f0 ff ff       	call   800168 <cputchar>
			buf[i] = 0;
  8010fb:	c6 86 c0 fc 80 00 00 	movb   $0x0,0x80fcc0(%esi)
			return buf;
  801102:	b8 c0 fc 80 00       	mov    $0x80fcc0,%eax
		}
	}
}
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	5b                   	pop    %ebx
  80110b:	5e                   	pop    %esi
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    
	...

00801110 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801116:	b8 00 00 00 00       	mov    $0x0,%eax
  80111b:	80 3a 00             	cmpb   $0x0,(%edx)
  80111e:	74 09                	je     801129 <strlen+0x19>
		n++;
  801120:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801123:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801127:	75 f7                	jne    801120 <strlen+0x10>
		n++;
	return n;
}
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801131:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801134:	b8 00 00 00 00       	mov    $0x0,%eax
  801139:	85 d2                	test   %edx,%edx
  80113b:	74 12                	je     80114f <strnlen+0x24>
  80113d:	80 39 00             	cmpb   $0x0,(%ecx)
  801140:	74 0d                	je     80114f <strnlen+0x24>
		n++;
  801142:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801145:	39 d0                	cmp    %edx,%eax
  801147:	74 06                	je     80114f <strnlen+0x24>
  801149:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80114d:	75 f3                	jne    801142 <strnlen+0x17>
		n++;
	return n;
}
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	53                   	push   %ebx
  801155:	8b 45 08             	mov    0x8(%ebp),%eax
  801158:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80115b:	ba 00 00 00 00       	mov    $0x0,%edx
  801160:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801164:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801167:	83 c2 01             	add    $0x1,%edx
  80116a:	84 c9                	test   %cl,%cl
  80116c:	75 f2                	jne    801160 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80116e:	5b                   	pop    %ebx
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
  801179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117c:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80117f:	85 f6                	test   %esi,%esi
  801181:	74 18                	je     80119b <strncpy+0x2a>
  801183:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801188:	0f b6 1a             	movzbl (%edx),%ebx
  80118b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80118e:	80 3a 01             	cmpb   $0x1,(%edx)
  801191:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801194:	83 c1 01             	add    $0x1,%ecx
  801197:	39 ce                	cmp    %ecx,%esi
  801199:	77 ed                	ja     801188 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011ad:	89 f0                	mov    %esi,%eax
  8011af:	85 c9                	test   %ecx,%ecx
  8011b1:	74 23                	je     8011d6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  8011b3:	83 e9 01             	sub    $0x1,%ecx
  8011b6:	74 1b                	je     8011d3 <strlcpy+0x34>
  8011b8:	0f b6 1a             	movzbl (%edx),%ebx
  8011bb:	84 db                	test   %bl,%bl
  8011bd:	74 14                	je     8011d3 <strlcpy+0x34>
			*dst++ = *src++;
  8011bf:	88 18                	mov    %bl,(%eax)
  8011c1:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011c4:	83 e9 01             	sub    $0x1,%ecx
  8011c7:	74 0a                	je     8011d3 <strlcpy+0x34>
			*dst++ = *src++;
  8011c9:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011cc:	0f b6 1a             	movzbl (%edx),%ebx
  8011cf:	84 db                	test   %bl,%bl
  8011d1:	75 ec                	jne    8011bf <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  8011d3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8011d6:	29 f0                	sub    %esi,%eax
}
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8011e5:	0f b6 01             	movzbl (%ecx),%eax
  8011e8:	84 c0                	test   %al,%al
  8011ea:	74 15                	je     801201 <strcmp+0x25>
  8011ec:	3a 02                	cmp    (%edx),%al
  8011ee:	75 11                	jne    801201 <strcmp+0x25>
		p++, q++;
  8011f0:	83 c1 01             	add    $0x1,%ecx
  8011f3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8011f6:	0f b6 01             	movzbl (%ecx),%eax
  8011f9:	84 c0                	test   %al,%al
  8011fb:	74 04                	je     801201 <strcmp+0x25>
  8011fd:	3a 02                	cmp    (%edx),%al
  8011ff:	74 ef                	je     8011f0 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801201:	0f b6 c0             	movzbl %al,%eax
  801204:	0f b6 12             	movzbl (%edx),%edx
  801207:	29 d0                	sub    %edx,%eax
}
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	53                   	push   %ebx
  80120f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801215:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80121d:	85 d2                	test   %edx,%edx
  80121f:	74 28                	je     801249 <strncmp+0x3e>
  801221:	0f b6 01             	movzbl (%ecx),%eax
  801224:	84 c0                	test   %al,%al
  801226:	74 24                	je     80124c <strncmp+0x41>
  801228:	3a 03                	cmp    (%ebx),%al
  80122a:	75 20                	jne    80124c <strncmp+0x41>
  80122c:	83 ea 01             	sub    $0x1,%edx
  80122f:	74 13                	je     801244 <strncmp+0x39>
		n--, p++, q++;
  801231:	83 c1 01             	add    $0x1,%ecx
  801234:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801237:	0f b6 01             	movzbl (%ecx),%eax
  80123a:	84 c0                	test   %al,%al
  80123c:	74 0e                	je     80124c <strncmp+0x41>
  80123e:	3a 03                	cmp    (%ebx),%al
  801240:	74 ea                	je     80122c <strncmp+0x21>
  801242:	eb 08                	jmp    80124c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801249:	5b                   	pop    %ebx
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80124c:	0f b6 01             	movzbl (%ecx),%eax
  80124f:	0f b6 13             	movzbl (%ebx),%edx
  801252:	29 d0                	sub    %edx,%eax
  801254:	eb f3                	jmp    801249 <strncmp+0x3e>

00801256 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	8b 45 08             	mov    0x8(%ebp),%eax
  80125c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801260:	0f b6 10             	movzbl (%eax),%edx
  801263:	84 d2                	test   %dl,%dl
  801265:	74 1c                	je     801283 <strchr+0x2d>
		if (*s == c)
  801267:	38 ca                	cmp    %cl,%dl
  801269:	75 07                	jne    801272 <strchr+0x1c>
  80126b:	eb 1b                	jmp    801288 <strchr+0x32>
  80126d:	38 ca                	cmp    %cl,%dl
  80126f:	90                   	nop
  801270:	74 16                	je     801288 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801272:	83 c0 01             	add    $0x1,%eax
  801275:	0f b6 10             	movzbl (%eax),%edx
  801278:	84 d2                	test   %dl,%dl
  80127a:	75 f1                	jne    80126d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80127c:	b8 00 00 00 00       	mov    $0x0,%eax
  801281:	eb 05                	jmp    801288 <strchr+0x32>
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	8b 45 08             	mov    0x8(%ebp),%eax
  801290:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801294:	0f b6 10             	movzbl (%eax),%edx
  801297:	84 d2                	test   %dl,%dl
  801299:	74 14                	je     8012af <strfind+0x25>
		if (*s == c)
  80129b:	38 ca                	cmp    %cl,%dl
  80129d:	75 06                	jne    8012a5 <strfind+0x1b>
  80129f:	eb 0e                	jmp    8012af <strfind+0x25>
  8012a1:	38 ca                	cmp    %cl,%dl
  8012a3:	74 0a                	je     8012af <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012a5:	83 c0 01             	add    $0x1,%eax
  8012a8:	0f b6 10             	movzbl (%eax),%edx
  8012ab:	84 d2                	test   %dl,%dl
  8012ad:	75 f2                	jne    8012a1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	83 ec 0c             	sub    $0xc,%esp
  8012b7:	89 1c 24             	mov    %ebx,(%esp)
  8012ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012cb:	85 c9                	test   %ecx,%ecx
  8012cd:	74 30                	je     8012ff <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012d5:	75 25                	jne    8012fc <memset+0x4b>
  8012d7:	f6 c1 03             	test   $0x3,%cl
  8012da:	75 20                	jne    8012fc <memset+0x4b>
		c &= 0xFF;
  8012dc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012df:	89 d3                	mov    %edx,%ebx
  8012e1:	c1 e3 08             	shl    $0x8,%ebx
  8012e4:	89 d6                	mov    %edx,%esi
  8012e6:	c1 e6 18             	shl    $0x18,%esi
  8012e9:	89 d0                	mov    %edx,%eax
  8012eb:	c1 e0 10             	shl    $0x10,%eax
  8012ee:	09 f0                	or     %esi,%eax
  8012f0:	09 d0                	or     %edx,%eax
  8012f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8012f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8012f7:	fc                   	cld    
  8012f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8012fa:	eb 03                	jmp    8012ff <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012fc:	fc                   	cld    
  8012fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012ff:	89 f8                	mov    %edi,%eax
  801301:	8b 1c 24             	mov    (%esp),%ebx
  801304:	8b 74 24 04          	mov    0x4(%esp),%esi
  801308:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80130c:	89 ec                	mov    %ebp,%esp
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	89 34 24             	mov    %esi,(%esp)
  801319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80131d:	8b 45 08             	mov    0x8(%ebp),%eax
  801320:	8b 75 0c             	mov    0xc(%ebp),%esi
  801323:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801326:	39 c6                	cmp    %eax,%esi
  801328:	73 36                	jae    801360 <memmove+0x50>
  80132a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80132d:	39 d0                	cmp    %edx,%eax
  80132f:	73 2f                	jae    801360 <memmove+0x50>
		s += n;
		d += n;
  801331:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801334:	f6 c2 03             	test   $0x3,%dl
  801337:	75 1b                	jne    801354 <memmove+0x44>
  801339:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80133f:	75 13                	jne    801354 <memmove+0x44>
  801341:	f6 c1 03             	test   $0x3,%cl
  801344:	75 0e                	jne    801354 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801346:	83 ef 04             	sub    $0x4,%edi
  801349:	8d 72 fc             	lea    -0x4(%edx),%esi
  80134c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80134f:	fd                   	std    
  801350:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801352:	eb 09                	jmp    80135d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801354:	83 ef 01             	sub    $0x1,%edi
  801357:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80135a:	fd                   	std    
  80135b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80135d:	fc                   	cld    
  80135e:	eb 20                	jmp    801380 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801360:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801366:	75 13                	jne    80137b <memmove+0x6b>
  801368:	a8 03                	test   $0x3,%al
  80136a:	75 0f                	jne    80137b <memmove+0x6b>
  80136c:	f6 c1 03             	test   $0x3,%cl
  80136f:	75 0a                	jne    80137b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801371:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801374:	89 c7                	mov    %eax,%edi
  801376:	fc                   	cld    
  801377:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801379:	eb 05                	jmp    801380 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80137b:	89 c7                	mov    %eax,%edi
  80137d:	fc                   	cld    
  80137e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801380:	8b 34 24             	mov    (%esp),%esi
  801383:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801387:	89 ec                	mov    %ebp,%esp
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801391:	8b 45 10             	mov    0x10(%ebp),%eax
  801394:	89 44 24 08          	mov    %eax,0x8(%esp)
  801398:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a2:	89 04 24             	mov    %eax,(%esp)
  8013a5:	e8 66 ff ff ff       	call   801310 <memmove>
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	57                   	push   %edi
  8013b0:	56                   	push   %esi
  8013b1:	53                   	push   %ebx
  8013b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013c0:	85 ff                	test   %edi,%edi
  8013c2:	74 38                	je     8013fc <memcmp+0x50>
		if (*s1 != *s2)
  8013c4:	0f b6 03             	movzbl (%ebx),%eax
  8013c7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013ca:	83 ef 01             	sub    $0x1,%edi
  8013cd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8013d2:	38 c8                	cmp    %cl,%al
  8013d4:	74 1d                	je     8013f3 <memcmp+0x47>
  8013d6:	eb 11                	jmp    8013e9 <memcmp+0x3d>
  8013d8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8013dd:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  8013e2:	83 c2 01             	add    $0x1,%edx
  8013e5:	38 c8                	cmp    %cl,%al
  8013e7:	74 0a                	je     8013f3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  8013e9:	0f b6 c0             	movzbl %al,%eax
  8013ec:	0f b6 c9             	movzbl %cl,%ecx
  8013ef:	29 c8                	sub    %ecx,%eax
  8013f1:	eb 09                	jmp    8013fc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013f3:	39 fa                	cmp    %edi,%edx
  8013f5:	75 e1                	jne    8013d8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5f                   	pop    %edi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801407:	89 c2                	mov    %eax,%edx
  801409:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80140c:	39 d0                	cmp    %edx,%eax
  80140e:	73 15                	jae    801425 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801410:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801414:	38 08                	cmp    %cl,(%eax)
  801416:	75 06                	jne    80141e <memfind+0x1d>
  801418:	eb 0b                	jmp    801425 <memfind+0x24>
  80141a:	38 08                	cmp    %cl,(%eax)
  80141c:	74 07                	je     801425 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80141e:	83 c0 01             	add    $0x1,%eax
  801421:	39 c2                	cmp    %eax,%edx
  801423:	77 f5                	ja     80141a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	8b 55 08             	mov    0x8(%ebp),%edx
  801430:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801433:	0f b6 02             	movzbl (%edx),%eax
  801436:	3c 20                	cmp    $0x20,%al
  801438:	74 04                	je     80143e <strtol+0x17>
  80143a:	3c 09                	cmp    $0x9,%al
  80143c:	75 0e                	jne    80144c <strtol+0x25>
		s++;
  80143e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801441:	0f b6 02             	movzbl (%edx),%eax
  801444:	3c 20                	cmp    $0x20,%al
  801446:	74 f6                	je     80143e <strtol+0x17>
  801448:	3c 09                	cmp    $0x9,%al
  80144a:	74 f2                	je     80143e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80144c:	3c 2b                	cmp    $0x2b,%al
  80144e:	75 0a                	jne    80145a <strtol+0x33>
		s++;
  801450:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801453:	bf 00 00 00 00       	mov    $0x0,%edi
  801458:	eb 10                	jmp    80146a <strtol+0x43>
  80145a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80145f:	3c 2d                	cmp    $0x2d,%al
  801461:	75 07                	jne    80146a <strtol+0x43>
		s++, neg = 1;
  801463:	83 c2 01             	add    $0x1,%edx
  801466:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80146a:	85 db                	test   %ebx,%ebx
  80146c:	0f 94 c0             	sete   %al
  80146f:	74 05                	je     801476 <strtol+0x4f>
  801471:	83 fb 10             	cmp    $0x10,%ebx
  801474:	75 15                	jne    80148b <strtol+0x64>
  801476:	80 3a 30             	cmpb   $0x30,(%edx)
  801479:	75 10                	jne    80148b <strtol+0x64>
  80147b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80147f:	75 0a                	jne    80148b <strtol+0x64>
		s += 2, base = 16;
  801481:	83 c2 02             	add    $0x2,%edx
  801484:	bb 10 00 00 00       	mov    $0x10,%ebx
  801489:	eb 13                	jmp    80149e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  80148b:	84 c0                	test   %al,%al
  80148d:	74 0f                	je     80149e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80148f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801494:	80 3a 30             	cmpb   $0x30,(%edx)
  801497:	75 05                	jne    80149e <strtol+0x77>
		s++, base = 8;
  801499:	83 c2 01             	add    $0x1,%edx
  80149c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80149e:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014a5:	0f b6 0a             	movzbl (%edx),%ecx
  8014a8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8014ab:	80 fb 09             	cmp    $0x9,%bl
  8014ae:	77 08                	ja     8014b8 <strtol+0x91>
			dig = *s - '0';
  8014b0:	0f be c9             	movsbl %cl,%ecx
  8014b3:	83 e9 30             	sub    $0x30,%ecx
  8014b6:	eb 1e                	jmp    8014d6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  8014b8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8014bb:	80 fb 19             	cmp    $0x19,%bl
  8014be:	77 08                	ja     8014c8 <strtol+0xa1>
			dig = *s - 'a' + 10;
  8014c0:	0f be c9             	movsbl %cl,%ecx
  8014c3:	83 e9 57             	sub    $0x57,%ecx
  8014c6:	eb 0e                	jmp    8014d6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  8014c8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8014cb:	80 fb 19             	cmp    $0x19,%bl
  8014ce:	77 15                	ja     8014e5 <strtol+0xbe>
			dig = *s - 'A' + 10;
  8014d0:	0f be c9             	movsbl %cl,%ecx
  8014d3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014d6:	39 f1                	cmp    %esi,%ecx
  8014d8:	7d 0f                	jge    8014e9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  8014da:	83 c2 01             	add    $0x1,%edx
  8014dd:	0f af c6             	imul   %esi,%eax
  8014e0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8014e3:	eb c0                	jmp    8014a5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014e5:	89 c1                	mov    %eax,%ecx
  8014e7:	eb 02                	jmp    8014eb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014e9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014ef:	74 05                	je     8014f6 <strtol+0xcf>
		*endptr = (char *) s;
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8014f6:	89 ca                	mov    %ecx,%edx
  8014f8:	f7 da                	neg    %edx
  8014fa:	85 ff                	test   %edi,%edi
  8014fc:	0f 45 c2             	cmovne %edx,%eax
}
  8014ff:	5b                   	pop    %ebx
  801500:	5e                   	pop    %esi
  801501:	5f                   	pop    %edi
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <putch>:
        char buf[256];
};

static void
putch(int ch, void* b1)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 18             	sub    $0x18,%esp
  80150a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80150d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//cputchar(ch);
	//*cnt++;
	struct printbuf* b = (struct printbuf*) b1;
  801513:	89 de                	mov    %ebx,%esi
        b->buf[b->idx++] = ch;
  801515:	8b 03                	mov    (%ebx),%eax
  801517:	8b 55 08             	mov    0x8(%ebp),%edx
  80151a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80151e:	83 c0 01             	add    $0x1,%eax
  801521:	89 03                	mov    %eax,(%ebx)
        if (b->idx == 256-1) {
  801523:	3d ff 00 00 00       	cmp    $0xff,%eax
  801528:	75 19                	jne    801543 <putch+0x3f>
                sys_cputs(b->buf, b->idx);
  80152a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801531:	00 
  801532:	8d 43 08             	lea    0x8(%ebx),%eax
  801535:	89 04 24             	mov    %eax,(%esp)
  801538:	e8 88 f3 ff ff       	call   8008c5 <sys_cputs>
                b->idx = 0;
  80153d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        }
        b->cnt++;
  801543:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  801547:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80154a:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80154d:	89 ec                	mov    %ebp,%esp
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <vcprintf>:
}
*/

int
vcprintf(const char *fmt, va_list ap)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	81 ec 28 01 00 00    	sub    $0x128,%esp
        struct printbuf b;

        b.idx = 0;
  80155a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801561:	00 00 00 
        b.cnt = 0;
  801564:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80156b:	00 00 00 
        vprintfmt((void*)putch, &b, fmt, ap);
  80156e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801571:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801575:	8b 45 08             	mov    0x8(%ebp),%eax
  801578:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801582:	89 44 24 04          	mov    %eax,0x4(%esp)
  801586:	c7 04 24 04 15 80 00 	movl   $0x801504,(%esp)
  80158d:	e8 25 f6 ff ff       	call   800bb7 <vprintfmt>
        sys_cputs(b.buf, b.idx);
  801592:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015a2:	89 04 24             	mov    %eax,(%esp)
  8015a5:	e8 1b f3 ff ff       	call   8008c5 <sys_cputs>

        return b.cnt;
}
  8015aa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <cprintf>:


int
cprintf(const char *fmt, ...)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c2:	89 04 24             	mov    %eax,(%esp)
  8015c5:	e8 87 ff ff ff       	call   801551 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <envid2env>:

struct Trapframe user_tf;

int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	89 1c 24             	mov    %ebx,(%esp)
  8015d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
        struct Env *e;

        if (envid == 0) {
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	75 0e                	jne    8015f1 <envid2env+0x25>
                *env_store = curenv;
  8015e3:	a1 c0 00 81 00       	mov    0x8100c0,%eax
  8015e8:	89 02                	mov    %eax,(%edx)
                return 0;
  8015ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ef:	eb 5c                	jmp    80164d <envid2env+0x81>
        }
        e = &envs[envid];
        if (e->env_status == ENV_FREE || e->env_id != envid) {
  8015f1:	6b c8 7c             	imul   $0x7c,%eax,%ecx
  8015f4:	83 b9 34 01 81 00 00 	cmpl   $0x0,0x810134(%ecx)
  8015fb:	74 08                	je     801605 <envid2env+0x39>
  8015fd:	39 81 2c 01 81 00    	cmp    %eax,0x81012c(%ecx)
  801603:	74 0d                	je     801612 <envid2env+0x46>
                *env_store = 0;
  801605:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
                return -E_BAD_ENV;
  80160b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  801610:	eb 3b                	jmp    80164d <envid2env+0x81>

        if (envid == 0) {
                *env_store = curenv;
                return 0;
        }
        e = &envs[envid];
  801612:	6b c8 7c             	imul   $0x7c,%eax,%ecx
  801615:	81 c1 e0 00 81 00    	add    $0x8100e0,%ecx
        if (e->env_status == ENV_FREE || e->env_id != envid) {
                *env_store = 0;
                return -E_BAD_ENV;
        }
        if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  80161b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80161f:	74 25                	je     801646 <envid2env+0x7a>
  801621:	8b 1d c0 00 81 00    	mov    0x8100c0,%ebx
  801627:	39 d9                	cmp    %ebx,%ecx
  801629:	74 1b                	je     801646 <envid2env+0x7a>
  80162b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80162e:	8b 73 4c             	mov    0x4c(%ebx),%esi
  801631:	39 b0 30 01 81 00    	cmp    %esi,0x810130(%eax)
  801637:	74 0d                	je     801646 <envid2env+0x7a>
                *env_store = 0;
  801639:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
                return -E_BAD_ENV;
  80163f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  801644:	eb 07                	jmp    80164d <envid2env+0x81>
        }
        *env_store = e;
  801646:	89 0a                	mov    %ecx,(%edx)
        return 0;
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164d:	8b 1c 24             	mov    (%esp),%ebx
  801650:	8b 74 24 04          	mov    0x4(%esp),%esi
  801654:	89 ec                	mov    %ebp,%esp
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    

00801658 <env_init>:

void
env_init(void)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	57                   	push   %edi
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	81 ec 9c 00 00 00    	sub    $0x9c,%esp

        cprintf("\n in env_init in user\n");
  801664:	c7 04 24 84 23 80 00 	movl   $0x802384,(%esp)
  80166b:	e8 42 ff ff ff       	call   8015b2 <cprintf>
	cprintf("inserting\n");
  801670:	c7 04 24 9b 23 80 00 	movl   $0x80239b,(%esp)
  801677:	e8 36 ff ff ff       	call   8015b2 <cprintf>
        int i;
//	sys_page_alloc(envs);
	cprintf("nenv: %d %x %x\n", nenv-1, envs, envs[1]);
  80167c:	be 5c 01 81 00       	mov    $0x81015c,%esi
  801681:	8d 7c 24 0c          	lea    0xc(%esp),%edi
  801685:	b9 1f 00 00 00       	mov    $0x1f,%ecx
  80168a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80168c:	c7 44 24 08 e0 00 81 	movl   $0x8100e0,0x8(%esp)
  801693:	00 
  801694:	a1 04 30 80 00       	mov    0x803004,%eax
  801699:	83 e8 01             	sub    $0x1,%eax
  80169c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a0:	c7 04 24 a6 23 80 00 	movl   $0x8023a6,(%esp)
  8016a7:	e8 06 ff ff ff       	call   8015b2 <cprintf>
        for(i=nenv-1;i>=0;i--)
  8016ac:	8b 15 04 30 80 00    	mov    0x803004,%edx
  8016b2:	83 ea 01             	sub    $0x1,%edx
  8016b5:	78 4c                	js     801703 <env_init+0xab>
  8016b7:	8b 0d c4 00 81 00    	mov    0x8100c4,%ecx
        *env_store = e;
        return 0;
}

void
env_init(void)
  8016bd:	6b c2 7c             	imul   $0x7c,%edx,%eax
  8016c0:	05 2c 01 81 00       	add    $0x81012c,%eax
  8016c5:	89 c6                	mov    %eax,%esi
        int i;
//	sys_page_alloc(envs);
	cprintf("nenv: %d %x %x\n", nenv-1, envs, envs[1]);
        for(i=nenv-1;i>=0;i--)
        {
                envs[i].env_id = 0;
  8016c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8016cd:	89 d7                	mov    %edx,%edi
                LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
  8016cf:	89 48 f8             	mov    %ecx,-0x8(%eax)
  8016d2:	85 c9                	test   %ecx,%ecx
  8016d4:	74 0c                	je     8016e2 <env_init+0x8a>
  8016d6:	6b da 7c             	imul   $0x7c,%edx,%ebx
  8016d9:	81 c3 24 01 81 00    	add    $0x810124,%ebx
  8016df:	89 59 48             	mov    %ebx,0x48(%ecx)
  8016e2:	6b cf 7c             	imul   $0x7c,%edi,%ecx
  8016e5:	81 c1 e0 00 81 00    	add    $0x8100e0,%ecx
  8016eb:	c7 46 fc c4 00 81 00 	movl   $0x8100c4,-0x4(%esi)
        cprintf("\n in env_init in user\n");
	cprintf("inserting\n");
        int i;
//	sys_page_alloc(envs);
	cprintf("nenv: %d %x %x\n", nenv-1, envs, envs[1]);
        for(i=nenv-1;i>=0;i--)
  8016f2:	83 ea 01             	sub    $0x1,%edx
  8016f5:	83 e8 7c             	sub    $0x7c,%eax
  8016f8:	83 fa ff             	cmp    $0xffffffff,%edx
  8016fb:	75 c8                	jne    8016c5 <env_init+0x6d>
  8016fd:	89 0d c4 00 81 00    	mov    %ecx,0x8100c4
        {
                envs[i].env_id = 0;
                LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
        }
	cprintf("calling allloc\n");
  801703:	c7 04 24 b6 23 80 00 	movl   $0x8023b6,(%esp)
  80170a:	e8 a3 fe ff ff       	call   8015b2 <cprintf>
//	struct Env *e;
//	env_alloc(&e, 0);
}
  80170f:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	5f                   	pop    %edi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <env_alloc>:



int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;
	cprintf("list: %x\n", env_free_list);
  801721:	a1 c4 00 81 00       	mov    0x8100c4,%eax
  801726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172a:	c7 04 24 c6 23 80 00 	movl   $0x8023c6,(%esp)
  801731:	e8 7c fe ff ff       	call   8015b2 <cprintf>
	if (!(e = LIST_FIRST(&env_free_list)))
  801736:	8b 1d c4 00 81 00    	mov    0x8100c4,%ebx
	{
		return -E_NO_FREE_ENV;
  80173c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
{
	int32_t generation;
	int r;
	struct Env *e;
	cprintf("list: %x\n", env_free_list);
	if (!(e = LIST_FIRST(&env_free_list)))
  801741:	85 db                	test   %ebx,%ebx
  801743:	0f 84 9e 00 00 00    	je     8017e7 <env_alloc+0xcd>
	
//	Env_map_segment(e->env_pgdir, UPAGES, ROUNDUP(npage*sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U | PTE_P);
//	Env_map_segment(e->env_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
//	Env_map_segment(e->env_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P| PTE_W);
//	Env_map_segment(e->env_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_P| PTE_W);
	cprintf("kool");
  801749:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  801750:	e8 5d fe ff ff       	call   8015b2 <cprintf>
	cprintf("passing %x to set up vm\n", e);
  801755:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801759:	c7 04 24 d5 23 80 00 	movl   $0x8023d5,(%esp)
  801760:	e8 4d fe ff ff       	call   8015b2 <cprintf>
	sys_env_setup_vm(e);
  801765:	89 1c 24             	mov    %ebx,(%esp)
  801768:	e8 97 f1 ff ff       	call   800904 <sys_env_setup_vm>
	}

	if ((r = env_setup_vm(e)) < 0)
		return r;

	generation = ((e->env_id) & ~(1024 - 1));
  80176d:	8b 43 4c             	mov    0x4c(%ebx),%eax
	if (generation <= 0)	// Don't create a negative env_id.
  801770:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1;
  801775:	ba 01 00 00 00       	mov    $0x1,%edx
  80177a:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
  80177d:	89 da                	mov    %ebx,%edx
  80177f:	81 ea e0 00 81 00    	sub    $0x8100e0,%edx
  801785:	c1 fa 02             	sar    $0x2,%edx
  801788:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
  80178e:	09 d0                	or     %edx,%eax
  801790:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	e->env_parent_id = parent_id;
  801793:	8b 45 0c             	mov    0xc(%ebp),%eax
  801796:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
  801799:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
  8017a0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
	e->env_tf.tf_cs = GD_UT | 3;

	e->env_tf.tf_eflags |= FL_IF;
*/
	e->env_pgfault_upcall = 0;
  8017a7:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
  8017ae:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	LIST_REMOVE(e, env_link);
  8017b5:	8b 43 44             	mov    0x44(%ebx),%eax
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	74 06                	je     8017c2 <env_alloc+0xa8>
  8017bc:	8b 53 48             	mov    0x48(%ebx),%edx
  8017bf:	89 50 48             	mov    %edx,0x48(%eax)
  8017c2:	8b 43 48             	mov    0x48(%ebx),%eax
  8017c5:	8b 53 44             	mov    0x44(%ebx),%edx
  8017c8:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	89 18                	mov    %ebx,(%eax)

	cprintf(" pgdir: %x out of envalloc\n", e->env_pgdir);
  8017cf:	8b 43 5c             	mov    0x5c(%ebx),%eax
  8017d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d6:	c7 04 24 ee 23 80 00 	movl   $0x8023ee,(%esp)
  8017dd:	e8 d0 fd ff ff       	call   8015b2 <cprintf>
	return 0;
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e7:	83 c4 14             	add    $0x14,%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <load_icode>:
}


void
load_icode(struct Env *e, uint8_t *binary, size_t size)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 18             	sub    $0x18,%esp
	cprintf("in load icode\n");
  8017f3:	c7 04 24 0a 24 80 00 	movl   $0x80240a,(%esp)
  8017fa:	e8 b3 fd ff ff       	call   8015b2 <cprintf>
	sys_load_icode((void*)e, (void*)binary, size);
  8017ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801802:	89 44 24 08          	mov    %eax,0x8(%esp)
  801806:	8b 45 0c             	mov    0xc(%ebp),%eax
  801809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	89 04 24             	mov    %eax,(%esp)
  801813:	e8 6e f1 ff ff       	call   800986 <sys_load_icode>
		}
	}

	e->env_tf.tf_eip = ELFHDR->e_entry;
	segment_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);*/
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <print_regs>:

void
print_regs(struct PushRegs *regs)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 14             	sub    $0x14,%esp
  801821:	8b 5d 08             	mov    0x8(%ebp),%ebx
        cprintf("  edi  0x%08x\n", regs->reg_edi);
  801824:	8b 03                	mov    (%ebx),%eax
  801826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182a:	c7 04 24 19 24 80 00 	movl   $0x802419,(%esp)
  801831:	e8 7c fd ff ff       	call   8015b2 <cprintf>
        cprintf("  esi  0x%08x\n", regs->reg_esi);
  801836:	8b 43 04             	mov    0x4(%ebx),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	c7 04 24 28 24 80 00 	movl   $0x802428,(%esp)
  801844:	e8 69 fd ff ff       	call   8015b2 <cprintf>
        cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  801849:	8b 43 08             	mov    0x8(%ebx),%eax
  80184c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801850:	c7 04 24 37 24 80 00 	movl   $0x802437,(%esp)
  801857:	e8 56 fd ff ff       	call   8015b2 <cprintf>
        cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  80185c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	c7 04 24 46 24 80 00 	movl   $0x802446,(%esp)
  80186a:	e8 43 fd ff ff       	call   8015b2 <cprintf>
        cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  80186f:	8b 43 10             	mov    0x10(%ebx),%eax
  801872:	89 44 24 04          	mov    %eax,0x4(%esp)
  801876:	c7 04 24 55 24 80 00 	movl   $0x802455,(%esp)
  80187d:	e8 30 fd ff ff       	call   8015b2 <cprintf>
        cprintf("  edx  0x%08x\n", regs->reg_edx);
  801882:	8b 43 14             	mov    0x14(%ebx),%eax
  801885:	89 44 24 04          	mov    %eax,0x4(%esp)
  801889:	c7 04 24 64 24 80 00 	movl   $0x802464,(%esp)
  801890:	e8 1d fd ff ff       	call   8015b2 <cprintf>
        cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  801895:	8b 43 18             	mov    0x18(%ebx),%eax
  801898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189c:	c7 04 24 73 24 80 00 	movl   $0x802473,(%esp)
  8018a3:	e8 0a fd ff ff       	call   8015b2 <cprintf>
        cprintf("  eax  0x%08x\n", regs->reg_eax);
  8018a8:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8018ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018af:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  8018b6:	e8 f7 fc ff ff       	call   8015b2 <cprintf>
}
  8018bb:	83 c4 14             	add    $0x14,%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5d                   	pop    %ebp
  8018c0:	c3                   	ret    

008018c1 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 14             	sub    $0x14,%esp
  8018c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
        cprintf("TRAP frame at %p\n", tf);
  8018cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018cf:	c7 04 24 91 24 80 00 	movl   $0x802491,(%esp)
  8018d6:	e8 d7 fc ff ff       	call   8015b2 <cprintf>
        print_regs(&tf->tf_regs);
  8018db:	89 1c 24             	mov    %ebx,(%esp)
  8018de:	e8 37 ff ff ff       	call   80181a <print_regs>
        cprintf("  es   0x----%04x\n", tf->tf_es);
  8018e3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
  8018e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018eb:	c7 04 24 a3 24 80 00 	movl   $0x8024a3,(%esp)
  8018f2:	e8 bb fc ff ff       	call   8015b2 <cprintf>
        cprintf("  ds   0x----%04x\n", tf->tf_ds);
  8018f7:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
  8018fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ff:	c7 04 24 b6 24 80 00 	movl   $0x8024b6,(%esp)
  801906:	e8 a7 fc ff ff       	call   8015b2 <cprintf>
        cprintf("  trap 0x%08x\n", tf->tf_trapno);
  80190b:	8b 43 28             	mov    0x28(%ebx),%eax
  80190e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801912:	c7 04 24 c9 24 80 00 	movl   $0x8024c9,(%esp)
  801919:	e8 94 fc ff ff       	call   8015b2 <cprintf>
        cprintf("  err  0x%08x\n", tf->tf_err);
  80191e:	8b 43 2c             	mov    0x2c(%ebx),%eax
  801921:	89 44 24 04          	mov    %eax,0x4(%esp)
  801925:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  80192c:	e8 81 fc ff ff       	call   8015b2 <cprintf>
        cprintf("  eip  0x%08x\n", tf->tf_eip);
  801931:	8b 43 30             	mov    0x30(%ebx),%eax
  801934:	89 44 24 04          	mov    %eax,0x4(%esp)
  801938:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  80193f:	e8 6e fc ff ff       	call   8015b2 <cprintf>
        cprintf("  cs   0x----%04x\n", tf->tf_cs);
  801944:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
  801948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194c:	c7 04 24 f6 24 80 00 	movl   $0x8024f6,(%esp)
  801953:	e8 5a fc ff ff       	call   8015b2 <cprintf>
        cprintf("  flag 0x%08x\n", tf->tf_eflags);
  801958:	8b 43 38             	mov    0x38(%ebx),%eax
  80195b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195f:	c7 04 24 09 25 80 00 	movl   $0x802509,(%esp)
  801966:	e8 47 fc ff ff       	call   8015b2 <cprintf>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  80196b:	8b 43 3c             	mov    0x3c(%ebx),%eax
  80196e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801972:	c7 04 24 18 25 80 00 	movl   $0x802518,(%esp)
  801979:	e8 34 fc ff ff       	call   8015b2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  80197e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	c7 04 24 27 25 80 00 	movl   $0x802527,(%esp)
  80198d:	e8 20 fc ff ff       	call   8015b2 <cprintf>
}
  801992:	83 c4 14             	add    $0x14,%esp
  801995:	5b                   	pop    %ebx
  801996:	5d                   	pop    %ebp
  801997:	c3                   	ret    

00801998 <env_run>:
}

*/
void
env_run(struct Env *e)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	83 ec 18             	sub    $0x18,%esp
  80199e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019a4:	8b 75 08             	mov    0x8(%ebp),%esi
		curenv = e;
		e->env_runs += 1;
		sys_lcr3(curenv->env_cr3);
	}
	return;*/
	curenv = e;
  8019a7:	89 35 c0 00 81 00    	mov    %esi,0x8100c0
	cprintf("\n\n ***userKernel, env.c:337***** Guest Kernel to Guest User now, inside env_run().... \n\n");
  8019ad:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  8019b4:	e8 f9 fb ff ff       	call   8015b2 <cprintf>
	sys_env_pop_tf((uint32_t)e);
  8019b9:	89 34 24             	mov    %esi,(%esp)
  8019bc:	e8 49 f0 ff ff       	call   800a0a <sys_env_pop_tf>

	// guest user process returned from vm monitor due to trap, runnig it again
	 //asm volatile("movl %0,%%esp\n"
	asm volatile (" call get_userTrapframe\n":::"memory");
  8019c1:	e8 f9 00 00 00       	call   801abf <get_userTrapframe>
	cprintf("\n\n ******** The HACK BEGINS..... guest kernel, inside env_run().... \n\n");
  8019c6:	c7 04 24 b8 25 80 00 	movl   $0x8025b8,(%esp)
  8019cd:	e8 e0 fb ff ff       	call   8015b2 <cprintf>
	print_trapframe(&user_tf);
  8019d2:	c7 04 24 60 10 81 00 	movl   $0x811060,(%esp)
  8019d9:	e8 e3 fe ff ff       	call   8018c1 <print_trapframe>
                "\tpopl %%ds\n"
                "\taddl $0x8,%%esp\n" //skip tf_trapno and tf_errcode 
                "\tiret"
                : : "g" (&tf) : "memory");
*/		
	curenv->env_tf = user_tf;
  8019de:	a1 c0 00 81 00       	mov    0x8100c0,%eax
  8019e3:	be 60 10 81 00       	mov    $0x811060,%esi
  8019e8:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019ed:	89 c7                	mov    %eax,%edi
  8019ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env_run(curenv);	
  8019f1:	a1 c0 00 81 00       	mov    0x8100c0,%eax
  8019f6:	89 04 24             	mov    %eax,(%esp)
  8019f9:	e8 9a ff ff ff       	call   801998 <env_run>
	
}
  8019fe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a04:	89 ec                	mov    %ebp,%esp
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <env_create>:
}


void
env_create(uint8_t *binary, size_t size)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 38             	sub    $0x38,%esp
  801a0e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a11:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a14:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a17:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a1a:	8b 75 0c             	mov    0xc(%ebp),%esi
	cprintf("binary: %x %d\n", binary, size);
  801a1d:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a21:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a25:	c7 04 24 3a 25 80 00 	movl   $0x80253a,(%esp)
  801a2c:	e8 81 fb ff ff       	call   8015b2 <cprintf>
	struct Env *e;
	int retCode = env_alloc(&e, 0);
  801a31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a38:	00 
  801a39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	e8 d6 fc ff ff       	call   80171a <env_alloc>
  801a44:	89 c3                	mov    %eax,%ebx
	cprintf("cr3: %x id: %x\n", e->env_cr3, e->env_id);
  801a46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a49:	8b 50 4c             	mov    0x4c(%eax),%edx
  801a4c:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a50:	8b 40 60             	mov    0x60(%eax),%eax
  801a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a57:	c7 04 24 49 25 80 00 	movl   $0x802549,(%esp)
  801a5e:	e8 4f fb ff ff       	call   8015b2 <cprintf>
	if(retCode == -E_NO_FREE_ENV)
  801a63:	83 fb fb             	cmp    $0xfffffffb,%ebx
  801a66:	75 0e                	jne    801a76 <env_create+0x6e>
	{
		cprintf("Maximum numbers of processes are already running!!\n");
  801a68:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  801a6f:	e8 3e fb ff ff       	call   8015b2 <cprintf>
		return;
  801a74:	eb 3c                	jmp    801ab2 <env_create+0xaa>
	}	
	if(retCode == -E_NO_MEM)
  801a76:	83 fb fc             	cmp    $0xfffffffc,%ebx
  801a79:	75 0e                	jne    801a89 <env_create+0x81>
	{
		cprintf("Out Of Memory while creating environment!!");
  801a7b:	c7 04 24 34 26 80 00 	movl   $0x802634,(%esp)
  801a82:	e8 2b fb ff ff       	call   8015b2 <cprintf>
		return;
  801a87:	eb 29                	jmp    801ab2 <env_create+0xaa>
	}	

	load_icode(e, binary, size); 
  801a89:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a8d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a94:	89 04 24             	mov    %eax,(%esp)
  801a97:	e8 51 fd ff ff       	call   8017ed <load_icode>
	print_trapframe(&e->env_tf);
  801a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9f:	89 04 24             	mov    %eax,(%esp)
  801aa2:	e8 1a fe ff ff       	call   8018c1 <print_trapframe>
	env_run(e);
  801aa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 e6 fe ff ff       	call   801998 <env_run>
}
  801ab2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ab5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ab8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801abb:	89 ec                	mov    %ebp,%esp
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <get_userTrapframe>:
	env_run(curenv);	
	
}

void get_userTrapframe(struct Trapframe* tf)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	89 34 24             	mov    %esi,(%esp)
  801ac8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801acc:	8b 75 08             	mov    0x8(%ebp),%esi
	user_tf = *tf;
  801acf:	bf 60 10 81 00       	mov    $0x811060,%edi
  801ad4:	b9 11 00 00 00       	mov    $0x11,%ecx
  801ad9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
}
  801adb:	8b 34 24             	mov    (%esp),%esi
  801ade:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ae2:	89 ec                	mov    %ebp,%esp
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
	...

00801ae8 <umain>:
#include <inc/lib.h>
#include <inc/stdio.h>

void
umain(void)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	83 ec 18             	sub    $0x18,%esp
        cprintf("hello, world\n");
  801aee:	c7 04 24 60 26 80 00 	movl   $0x802660,(%esp)
  801af5:	e8 b8 fa ff ff       	call   8015b2 <cprintf>
//        cprintf("i am environment %08x\n", env->env_id);
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    
  801afc:	00 00                	add    %al,(%eax)
	...

00801b00 <__udivdi3>:
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	57                   	push   %edi
  801b04:	56                   	push   %esi
  801b05:	83 ec 20             	sub    $0x20,%esp
  801b08:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b14:	85 c0                	test   %eax,%eax
  801b16:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b19:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b1c:	75 3a                	jne    801b58 <__udivdi3+0x58>
  801b1e:	39 f9                	cmp    %edi,%ecx
  801b20:	77 66                	ja     801b88 <__udivdi3+0x88>
  801b22:	85 c9                	test   %ecx,%ecx
  801b24:	75 0b                	jne    801b31 <__udivdi3+0x31>
  801b26:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2b:	31 d2                	xor    %edx,%edx
  801b2d:	f7 f1                	div    %ecx
  801b2f:	89 c1                	mov    %eax,%ecx
  801b31:	89 f8                	mov    %edi,%eax
  801b33:	31 d2                	xor    %edx,%edx
  801b35:	f7 f1                	div    %ecx
  801b37:	89 c7                	mov    %eax,%edi
  801b39:	89 f0                	mov    %esi,%eax
  801b3b:	f7 f1                	div    %ecx
  801b3d:	89 fa                	mov    %edi,%edx
  801b3f:	89 c6                	mov    %eax,%esi
  801b41:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801b44:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b4d:	83 c4 20             	add    $0x20,%esp
  801b50:	5e                   	pop    %esi
  801b51:	5f                   	pop    %edi
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    
  801b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b58:	31 d2                	xor    %edx,%edx
  801b5a:	31 f6                	xor    %esi,%esi
  801b5c:	39 f8                	cmp    %edi,%eax
  801b5e:	77 e1                	ja     801b41 <__udivdi3+0x41>
  801b60:	0f bd d0             	bsr    %eax,%edx
  801b63:	83 f2 1f             	xor    $0x1f,%edx
  801b66:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b69:	75 2d                	jne    801b98 <__udivdi3+0x98>
  801b6b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801b6e:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801b71:	76 06                	jbe    801b79 <__udivdi3+0x79>
  801b73:	39 f8                	cmp    %edi,%eax
  801b75:	89 f2                	mov    %esi,%edx
  801b77:	73 c8                	jae    801b41 <__udivdi3+0x41>
  801b79:	31 d2                	xor    %edx,%edx
  801b7b:	be 01 00 00 00       	mov    $0x1,%esi
  801b80:	eb bf                	jmp    801b41 <__udivdi3+0x41>
  801b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b88:	89 f0                	mov    %esi,%eax
  801b8a:	89 fa                	mov    %edi,%edx
  801b8c:	f7 f1                	div    %ecx
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	89 c6                	mov    %eax,%esi
  801b92:	eb ad                	jmp    801b41 <__udivdi3+0x41>
  801b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b98:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	b8 20 00 00 00       	mov    $0x20,%eax
  801ba3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ba6:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801ba9:	d3 e2                	shl    %cl,%edx
  801bab:	89 c1                	mov    %eax,%ecx
  801bad:	d3 ee                	shr    %cl,%esi
  801baf:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bb3:	09 d6                	or     %edx,%esi
  801bb5:	89 fa                	mov    %edi,%edx
  801bb7:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801bba:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801bbd:	d3 e6                	shl    %cl,%esi
  801bbf:	89 c1                	mov    %eax,%ecx
  801bc1:	d3 ea                	shr    %cl,%edx
  801bc3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bc7:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801bca:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801bcd:	d3 e7                	shl    %cl,%edi
  801bcf:	89 c1                	mov    %eax,%ecx
  801bd1:	d3 ee                	shr    %cl,%esi
  801bd3:	09 fe                	or     %edi,%esi
  801bd5:	89 f0                	mov    %esi,%eax
  801bd7:	f7 75 e4             	divl   -0x1c(%ebp)
  801bda:	89 d7                	mov    %edx,%edi
  801bdc:	89 c6                	mov    %eax,%esi
  801bde:	f7 65 f0             	mull   -0x10(%ebp)
  801be1:	39 d7                	cmp    %edx,%edi
  801be3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801be6:	72 12                	jb     801bfa <__udivdi3+0xfa>
  801be8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801beb:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bef:	d3 e2                	shl    %cl,%edx
  801bf1:	39 c2                	cmp    %eax,%edx
  801bf3:	73 08                	jae    801bfd <__udivdi3+0xfd>
  801bf5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801bf8:	75 03                	jne    801bfd <__udivdi3+0xfd>
  801bfa:	83 ee 01             	sub    $0x1,%esi
  801bfd:	31 d2                	xor    %edx,%edx
  801bff:	e9 3d ff ff ff       	jmp    801b41 <__udivdi3+0x41>
	...

00801c10 <__umoddi3>:
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	57                   	push   %edi
  801c14:	56                   	push   %esi
  801c15:	83 ec 20             	sub    $0x20,%esp
  801c18:	8b 7d 14             	mov    0x14(%ebp),%edi
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c21:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c24:	85 ff                	test   %edi,%edi
  801c26:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c29:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801c2f:	89 f2                	mov    %esi,%edx
  801c31:	75 15                	jne    801c48 <__umoddi3+0x38>
  801c33:	39 f1                	cmp    %esi,%ecx
  801c35:	76 41                	jbe    801c78 <__umoddi3+0x68>
  801c37:	f7 f1                	div    %ecx
  801c39:	89 d0                	mov    %edx,%eax
  801c3b:	31 d2                	xor    %edx,%edx
  801c3d:	83 c4 20             	add    $0x20,%esp
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 f7                	cmp    %esi,%edi
  801c4a:	77 4c                	ja     801c98 <__umoddi3+0x88>
  801c4c:	0f bd c7             	bsr    %edi,%eax
  801c4f:	83 f0 1f             	xor    $0x1f,%eax
  801c52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c55:	75 51                	jne    801ca8 <__umoddi3+0x98>
  801c57:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801c5a:	0f 87 e8 00 00 00    	ja     801d48 <__umoddi3+0x138>
  801c60:	89 f2                	mov    %esi,%edx
  801c62:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c65:	29 ce                	sub    %ecx,%esi
  801c67:	19 fa                	sbb    %edi,%edx
  801c69:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6f:	83 c4 20             	add    $0x20,%esp
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	85 c9                	test   %ecx,%ecx
  801c7a:	75 0b                	jne    801c87 <__umoddi3+0x77>
  801c7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c81:	31 d2                	xor    %edx,%edx
  801c83:	f7 f1                	div    %ecx
  801c85:	89 c1                	mov    %eax,%ecx
  801c87:	89 f0                	mov    %esi,%eax
  801c89:	31 d2                	xor    %edx,%edx
  801c8b:	f7 f1                	div    %ecx
  801c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c90:	eb a5                	jmp    801c37 <__umoddi3+0x27>
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	89 f2                	mov    %esi,%edx
  801c9a:	83 c4 20             	add    $0x20,%esp
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    
  801ca1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cb1:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801cb8:	29 45 f0             	sub    %eax,-0x10(%ebp)
  801cbb:	d3 e7                	shl    %cl,%edi
  801cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cc4:	d3 e8                	shr    %cl,%eax
  801cc6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cca:	09 f8                	or     %edi,%eax
  801ccc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	d3 e0                	shl    %cl,%eax
  801cd4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801cdb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cde:	d3 ea                	shr    %cl,%edx
  801ce0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ce4:	d3 e6                	shl    %cl,%esi
  801ce6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cea:	d3 e8                	shr    %cl,%eax
  801cec:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cf0:	09 f0                	or     %esi,%eax
  801cf2:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801cf5:	f7 75 e4             	divl   -0x1c(%ebp)
  801cf8:	d3 e6                	shl    %cl,%esi
  801cfa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801cfd:	89 d6                	mov    %edx,%esi
  801cff:	f7 65 f4             	mull   -0xc(%ebp)
  801d02:	89 d7                	mov    %edx,%edi
  801d04:	89 c2                	mov    %eax,%edx
  801d06:	39 fe                	cmp    %edi,%esi
  801d08:	89 f9                	mov    %edi,%ecx
  801d0a:	72 30                	jb     801d3c <__umoddi3+0x12c>
  801d0c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801d0f:	72 27                	jb     801d38 <__umoddi3+0x128>
  801d11:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d14:	29 d0                	sub    %edx,%eax
  801d16:	19 ce                	sbb    %ecx,%esi
  801d18:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d1c:	89 f2                	mov    %esi,%edx
  801d1e:	d3 e8                	shr    %cl,%eax
  801d20:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d24:	d3 e2                	shl    %cl,%edx
  801d26:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d2a:	09 d0                	or     %edx,%eax
  801d2c:	89 f2                	mov    %esi,%edx
  801d2e:	d3 ea                	shr    %cl,%edx
  801d30:	83 c4 20             	add    $0x20,%esp
  801d33:	5e                   	pop    %esi
  801d34:	5f                   	pop    %edi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    
  801d37:	90                   	nop
  801d38:	39 fe                	cmp    %edi,%esi
  801d3a:	75 d5                	jne    801d11 <__umoddi3+0x101>
  801d3c:	89 f9                	mov    %edi,%ecx
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801d43:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801d46:	eb c9                	jmp    801d11 <__umoddi3+0x101>
  801d48:	39 f7                	cmp    %esi,%edi
  801d4a:	0f 82 10 ff ff ff    	jb     801c60 <__umoddi3+0x50>
  801d50:	e9 17 ff ff ff       	jmp    801c6c <__umoddi3+0x5c>
