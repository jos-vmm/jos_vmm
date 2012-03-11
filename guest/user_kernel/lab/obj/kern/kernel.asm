
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

00800020 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
  800020:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
  800026:	00 00                	add    %al,(%eax)
  800028:	fb                   	sti    
  800029:	4f                   	dec    %edi
  80002a:	52                   	push   %edx
  80002b:	e4 66                	in     $0x66,%al

0080002c <_start>:
  80002c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
  800033:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
  800035:	0f 01 15 18 b0 80 10 	lgdtl  0x1080b018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
  80003c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
  800041:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
  800043:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
  800045:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
  800047:	ea 4e 00 80 00 08 00 	ljmp   $0x8,$0x80004e

0080004e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
  80004e:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
  800053:	bc 00 b0 80 00       	mov    $0x80b000,%esp

	# now to C code
	call	i386_init
  800058:	e8 60 00 00 00       	call   8000bd <i386_init>

0080005d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
  80005d:	eb fe                	jmp    80005d <spin>
	...

00800060 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	53                   	push   %ebx
  800064:	83 ec 14             	sub    $0x14,%esp
  800067:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
  80006a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80006e:	c7 04 24 60 1b 80 00 	movl   $0x801b60,(%esp)
  800075:	e8 14 0a 00 00       	call   800a8e <cprintf>
	if (x > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 0d                	jle    80008b <test_backtrace+0x2b>
		test_backtrace(x-1);
  80007e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800081:	89 04 24             	mov    %eax,(%esp)
  800084:	e8 d7 ff ff ff       	call   800060 <test_backtrace>
  800089:	eb 1c                	jmp    8000a7 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a2:	e8 60 08 00 00       	call   800907 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
  8000a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ab:	c7 04 24 7c 1b 80 00 	movl   $0x801b7c,(%esp)
  8000b2:	e8 d7 09 00 00       	call   800a8e <cprintf>
}
  8000b7:	83 c4 14             	add    $0x14,%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <i386_init>:

void
i386_init(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
  8000c3:	b8 a0 b9 80 00       	mov    $0x80b9a0,%eax
  8000c8:	2d 24 b3 80 00       	sub    $0x80b324,%eax
  8000cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 24 b3 80 00 	movl   $0x80b324,(%esp)
  8000e0:	e8 ac 15 00 00       	call   801691 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
  8000e5:	e8 98 04 00 00       	call   800582 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
  8000ea:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
  8000f1:	00 
  8000f2:	c7 04 24 97 1b 80 00 	movl   $0x801b97,(%esp)
  8000f9:	e8 90 09 00 00       	call   800a8e <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
  8000fe:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800105:	e8 56 ff ff ff       	call   800060 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
  80010a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800111:	e8 b4 06 00 00       	call   8007ca <monitor>
  800116:	eb f2                	jmp    80010a <i386_init+0x4d>

00800118 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	83 ec 10             	sub    $0x10,%esp
  800120:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
  800123:	83 3d 40 b3 80 00 00 	cmpl   $0x0,0x80b340
  80012a:	75 3d                	jne    800169 <_panic+0x51>
		goto dead;
	panicstr = fmt;
  80012c:	89 35 40 b3 80 00    	mov    %esi,0x80b340

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
  800132:	fa                   	cli    
  800133:	fc                   	cld    

	va_start(ap, fmt);
  800134:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
  800137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013e:	8b 45 08             	mov    0x8(%ebp),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	c7 04 24 b2 1b 80 00 	movl   $0x801bb2,(%esp)
  80014c:	e8 3d 09 00 00       	call   800a8e <cprintf>
	vcprintf(fmt, ap);
  800151:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800155:	89 34 24             	mov    %esi,(%esp)
  800158:	e8 fe 08 00 00       	call   800a5b <vcprintf>
	cprintf("\n");
  80015d:	c7 04 24 ee 1b 80 00 	movl   $0x801bee,(%esp)
  800164:	e8 25 09 00 00       	call   800a8e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 55 06 00 00       	call   8007ca <monitor>
  800175:	eb f2                	jmp    800169 <_panic+0x51>

00800177 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80017e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
  800181:	8b 45 0c             	mov    0xc(%ebp),%eax
  800184:	89 44 24 08          	mov    %eax,0x8(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018f:	c7 04 24 ca 1b 80 00 	movl   $0x801bca,(%esp)
  800196:	e8 f3 08 00 00       	call   800a8e <cprintf>
	vcprintf(fmt, ap);
  80019b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019f:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a2:	89 04 24             	mov    %eax,(%esp)
  8001a5:	e8 b1 08 00 00       	call   800a5b <vcprintf>
	cprintf("\n");
  8001aa:	c7 04 24 ee 1b 80 00 	movl   $0x801bee,(%esp)
  8001b1:	e8 d8 08 00 00       	call   800a8e <cprintf>
	va_end(ap);
}
  8001b6:	83 c4 14             	add    $0x14,%esp
  8001b9:	5b                   	pop    %ebx
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    
  8001bc:	00 00                	add    %al,(%eax)
	...

008001c0 <delay>:
static void cons_intr(int (*proc)(void));
static void cons_putc(int c);
// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8001c3:	ba 84 00 00 00       	mov    $0x84,%edx
  8001c8:	ec                   	in     (%dx),%al
  8001c9:	ec                   	in     (%dx),%al
  8001ca:	ec                   	in     (%dx),%al
  8001cb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    

008001ce <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8001d6:	ec                   	in     (%dx),%al
  8001d7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
  8001d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
  8001de:	f6 c2 01             	test   $0x1,%dl
  8001e1:	74 09                	je     8001ec <serial_proc_data+0x1e>
  8001e3:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8001e8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
  8001e9:	0f b6 c0             	movzbl %al,%eax
}
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 04             	sub    $0x4,%esp
  8001f5:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
  8001f7:	eb 25                	jmp    80021e <cons_intr+0x30>
		if (c == 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	74 21                	je     80021e <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
  8001fd:	8b 15 84 b5 80 00    	mov    0x80b584,%edx
  800203:	88 82 80 b3 80 00    	mov    %al,0x80b380(%edx)
  800209:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
  80020c:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
  800211:	ba 00 00 00 00       	mov    $0x0,%edx
  800216:	0f 44 c2             	cmove  %edx,%eax
  800219:	a3 84 b5 80 00       	mov    %eax,0x80b584
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  80021e:	ff d3                	call   *%ebx
  800220:	83 f8 ff             	cmp    $0xffffffff,%eax
  800223:	75 d4                	jne    8001f9 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
  800225:	83 c4 04             	add    $0x4,%esp
  800228:	5b                   	pop    %ebx
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 2c             	sub    $0x2c,%esp
  800234:	89 c7                	mov    %eax,%edi
  800236:	ba fd 03 00 00       	mov    $0x3fd,%edx
  80023b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
  80023c:	a8 20                	test   $0x20,%al
  80023e:	75 1b                	jne    80025b <cons_putc+0x30>
  800240:	bb 00 32 00 00       	mov    $0x3200,%ebx
  800245:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
  80024a:	e8 71 ff ff ff       	call   8001c0 <delay>
  80024f:	89 f2                	mov    %esi,%edx
  800251:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
  800252:	a8 20                	test   $0x20,%al
  800254:	75 05                	jne    80025b <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  800256:	83 eb 01             	sub    $0x1,%ebx
  800259:	75 ef                	jne    80024a <cons_putc+0x1f>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
  80025b:	89 fa                	mov    %edi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800262:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800267:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800268:	b2 79                	mov    $0x79,%dl
  80026a:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
  80026b:	84 c0                	test   %al,%al
  80026d:	78 21                	js     800290 <cons_putc+0x65>
  80026f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800274:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
  800279:	e8 42 ff ff ff       	call   8001c0 <delay>
  80027e:	89 f2                	mov    %esi,%edx
  800280:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
  800281:	84 c0                	test   %al,%al
  800283:	78 0b                	js     800290 <cons_putc+0x65>
  800285:	83 c3 01             	add    $0x1,%ebx
  800288:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
  80028e:	75 e9                	jne    800279 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800290:	ba 78 03 00 00       	mov    $0x378,%edx
  800295:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  800299:	ee                   	out    %al,(%dx)
  80029a:	b2 7a                	mov    $0x7a,%dl
  80029c:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002a1:	ee                   	out    %al,(%dx)
  8002a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8002a7:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if(!(c & ~0xFF))
  8002a8:	89 fa                	mov    %edi,%edx
  8002aa:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x700;
  8002b0:	89 f8                	mov    %edi,%eax
  8002b2:	80 cc 07             	or     $0x7,%ah
  8002b5:	85 d2                	test   %edx,%edx
  8002b7:	0f 44 f8             	cmove  %eax,%edi
	//cprintf("%d\n", COLOR);

	switch (c & 0xff) {
  8002ba:	89 f8                	mov    %edi,%eax
  8002bc:	25 ff 00 00 00       	and    $0xff,%eax
  8002c1:	83 f8 09             	cmp    $0x9,%eax
  8002c4:	74 78                	je     80033e <cons_putc+0x113>
  8002c6:	83 f8 09             	cmp    $0x9,%eax
  8002c9:	7f 0b                	jg     8002d6 <cons_putc+0xab>
  8002cb:	83 f8 08             	cmp    $0x8,%eax
  8002ce:	0f 85 9e 00 00 00    	jne    800372 <cons_putc+0x147>
  8002d4:	eb 12                	jmp    8002e8 <cons_putc+0xbd>
  8002d6:	83 f8 0a             	cmp    $0xa,%eax
  8002d9:	74 3d                	je     800318 <cons_putc+0xed>
  8002db:	83 f8 0d             	cmp    $0xd,%eax
  8002de:	66 90                	xchg   %ax,%ax
  8002e0:	0f 85 8c 00 00 00    	jne    800372 <cons_putc+0x147>
  8002e6:	eb 38                	jmp    800320 <cons_putc+0xf5>
	case '\b':
		if (crt_pos > 0) {
  8002e8:	0f b7 05 60 b3 80 00 	movzwl 0x80b360,%eax
  8002ef:	66 85 c0             	test   %ax,%ax
  8002f2:	0f 84 e4 00 00 00    	je     8003dc <cons_putc+0x1b1>
			crt_pos--;
  8002f8:	83 e8 01             	sub    $0x1,%eax
  8002fb:	66 a3 60 b3 80 00    	mov    %ax,0x80b360
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
  800301:	0f b7 c0             	movzwl %ax,%eax
  800304:	66 81 e7 00 ff       	and    $0xff00,%di
  800309:	83 cf 20             	or     $0x20,%edi
  80030c:	8b 15 64 b3 80 00    	mov    0x80b364,%edx
  800312:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
  800316:	eb 77                	jmp    80038f <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
  800318:	66 83 05 60 b3 80 00 	addw   $0x50,0x80b360
  80031f:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
  800320:	0f b7 05 60 b3 80 00 	movzwl 0x80b360,%eax
  800327:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  80032d:	c1 e8 16             	shr    $0x16,%eax
  800330:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800333:	c1 e0 04             	shl    $0x4,%eax
  800336:	66 a3 60 b3 80 00    	mov    %ax,0x80b360
  80033c:	eb 51                	jmp    80038f <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
  80033e:	b8 20 00 00 00       	mov    $0x20,%eax
  800343:	e8 e3 fe ff ff       	call   80022b <cons_putc>
		cons_putc(' ');
  800348:	b8 20 00 00 00       	mov    $0x20,%eax
  80034d:	e8 d9 fe ff ff       	call   80022b <cons_putc>
		cons_putc(' ');
  800352:	b8 20 00 00 00       	mov    $0x20,%eax
  800357:	e8 cf fe ff ff       	call   80022b <cons_putc>
		cons_putc(' ');
  80035c:	b8 20 00 00 00       	mov    $0x20,%eax
  800361:	e8 c5 fe ff ff       	call   80022b <cons_putc>
		cons_putc(' ');
  800366:	b8 20 00 00 00       	mov    $0x20,%eax
  80036b:	e8 bb fe ff ff       	call   80022b <cons_putc>
  800370:	eb 1d                	jmp    80038f <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
  800372:	0f b7 05 60 b3 80 00 	movzwl 0x80b360,%eax
  800379:	0f b7 c8             	movzwl %ax,%ecx
  80037c:	8b 15 64 b3 80 00    	mov    0x80b364,%edx
  800382:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
  800386:	83 c0 01             	add    $0x1,%eax
  800389:	66 a3 60 b3 80 00    	mov    %ax,0x80b360
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
  80038f:	66 81 3d 60 b3 80 00 	cmpw   $0x7cf,0x80b360
  800396:	cf 07 
  800398:	76 42                	jbe    8003dc <cons_putc+0x1b1>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  80039a:	a1 64 b3 80 00       	mov    0x80b364,%eax
  80039f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  8003a6:	00 
  8003a7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  8003ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b1:	89 04 24             	mov    %eax,(%esp)
  8003b4:	e8 37 13 00 00       	call   8016f0 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
  8003b9:	8b 15 64 b3 80 00    	mov    0x80b364,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  8003bf:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
  8003c4:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  8003ca:	83 c0 01             	add    $0x1,%eax
  8003cd:	3d d0 07 00 00       	cmp    $0x7d0,%eax
  8003d2:	75 f0                	jne    8003c4 <cons_putc+0x199>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
  8003d4:	66 83 2d 60 b3 80 00 	subw   $0x50,0x80b360
  8003db:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
  8003dc:	8b 0d 68 b3 80 00    	mov    0x80b368,%ecx
  8003e2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003e7:	89 ca                	mov    %ecx,%edx
  8003e9:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
  8003ea:	0f b7 35 60 b3 80 00 	movzwl 0x80b360,%esi
  8003f1:	8d 59 01             	lea    0x1(%ecx),%ebx
  8003f4:	89 f0                	mov    %esi,%eax
  8003f6:	66 c1 e8 08          	shr    $0x8,%ax
  8003fa:	89 da                	mov    %ebx,%edx
  8003fc:	ee                   	out    %al,(%dx)
  8003fd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800402:	89 ca                	mov    %ecx,%edx
  800404:	ee                   	out    %al,(%dx)
  800405:	89 f0                	mov    %esi,%eax
  800407:	89 da                	mov    %ebx,%edx
  800409:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
  80040a:	83 c4 2c             	add    $0x2c,%esp
  80040d:	5b                   	pop    %ebx
  80040e:	5e                   	pop    %esi
  80040f:	5f                   	pop    %edi
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	53                   	push   %ebx
  800416:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800419:	ba 64 00 00 00       	mov    $0x64,%edx
  80041e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
  80041f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
  800424:	a8 01                	test   $0x1,%al
  800426:	0f 84 de 00 00 00    	je     80050a <kbd_proc_data+0xf8>
  80042c:	b2 60                	mov    $0x60,%dl
  80042e:	ec                   	in     (%dx),%al
  80042f:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
  800431:	3c e0                	cmp    $0xe0,%al
  800433:	75 11                	jne    800446 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
  800435:	83 0d 88 b5 80 00 40 	orl    $0x40,0x80b588
		return 0;
  80043c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800441:	e9 c4 00 00 00       	jmp    80050a <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
  800446:	84 c0                	test   %al,%al
  800448:	79 37                	jns    800481 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  80044a:	8b 0d 88 b5 80 00    	mov    0x80b588,%ecx
  800450:	89 cb                	mov    %ecx,%ebx
  800452:	83 e3 40             	and    $0x40,%ebx
  800455:	83 e0 7f             	and    $0x7f,%eax
  800458:	85 db                	test   %ebx,%ebx
  80045a:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
  80045d:	0f b6 d2             	movzbl %dl,%edx
  800460:	0f b6 82 20 1c 80 00 	movzbl 0x801c20(%edx),%eax
  800467:	83 c8 40             	or     $0x40,%eax
  80046a:	0f b6 c0             	movzbl %al,%eax
  80046d:	f7 d0                	not    %eax
  80046f:	21 c1                	and    %eax,%ecx
  800471:	89 0d 88 b5 80 00    	mov    %ecx,0x80b588
		return 0;
  800477:	bb 00 00 00 00       	mov    $0x0,%ebx
  80047c:	e9 89 00 00 00       	jmp    80050a <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
  800481:	8b 0d 88 b5 80 00    	mov    0x80b588,%ecx
  800487:	f6 c1 40             	test   $0x40,%cl
  80048a:	74 0e                	je     80049a <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  80048c:	89 c2                	mov    %eax,%edx
  80048e:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
  800491:	83 e1 bf             	and    $0xffffffbf,%ecx
  800494:	89 0d 88 b5 80 00    	mov    %ecx,0x80b588
	}

	shift |= shiftcode[data];
  80049a:	0f b6 d2             	movzbl %dl,%edx
  80049d:	0f b6 82 20 1c 80 00 	movzbl 0x801c20(%edx),%eax
  8004a4:	0b 05 88 b5 80 00    	or     0x80b588,%eax
	shift ^= togglecode[data];
  8004aa:	0f b6 8a 20 1d 80 00 	movzbl 0x801d20(%edx),%ecx
  8004b1:	31 c8                	xor    %ecx,%eax
  8004b3:	a3 88 b5 80 00       	mov    %eax,0x80b588

	c = charcode[shift & (CTL | SHIFT)][data];
  8004b8:	89 c1                	mov    %eax,%ecx
  8004ba:	83 e1 03             	and    $0x3,%ecx
  8004bd:	8b 0c 8d 20 1e 80 00 	mov    0x801e20(,%ecx,4),%ecx
  8004c4:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
  8004c8:	a8 08                	test   $0x8,%al
  8004ca:	74 19                	je     8004e5 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
  8004cc:	8d 53 9f             	lea    -0x61(%ebx),%edx
  8004cf:	83 fa 19             	cmp    $0x19,%edx
  8004d2:	77 05                	ja     8004d9 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
  8004d4:	83 eb 20             	sub    $0x20,%ebx
  8004d7:	eb 0c                	jmp    8004e5 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
  8004d9:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
  8004dc:	8d 53 20             	lea    0x20(%ebx),%edx
  8004df:	83 f9 19             	cmp    $0x19,%ecx
  8004e2:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8004e5:	f7 d0                	not    %eax
  8004e7:	a8 06                	test   $0x6,%al
  8004e9:	75 1f                	jne    80050a <kbd_proc_data+0xf8>
  8004eb:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  8004f1:	75 17                	jne    80050a <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
  8004f3:	c7 04 24 e4 1b 80 00 	movl   $0x801be4,(%esp)
  8004fa:	e8 8f 05 00 00       	call   800a8e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8004ff:	ba 92 00 00 00       	mov    $0x92,%edx
  800504:	b8 03 00 00 00       	mov    $0x3,%eax
  800509:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
  80050a:	89 d8                	mov    %ebx,%eax
  80050c:	83 c4 14             	add    $0x14,%esp
  80050f:	5b                   	pop    %ebx
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
  800518:	83 3d 6c b3 80 00 00 	cmpl   $0x0,0x80b36c
  80051f:	74 0a                	je     80052b <serial_intr+0x19>
		cons_intr(serial_proc_data);
  800521:	b8 ce 01 80 00       	mov    $0x8001ce,%eax
  800526:	e8 c3 fc ff ff       	call   8001ee <cons_intr>
}
  80052b:	c9                   	leave  
  80052c:	c3                   	ret    

0080052d <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
  800533:	b8 12 04 80 00       	mov    $0x800412,%eax
  800538:	e8 b1 fc ff ff       	call   8001ee <cons_intr>
}
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
  800545:	e8 c8 ff ff ff       	call   800512 <serial_intr>
	kbd_intr();
  80054a:	e8 de ff ff ff       	call   80052d <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  80054f:	8b 15 80 b5 80 00    	mov    0x80b580,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
  800555:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  80055a:	3b 15 84 b5 80 00    	cmp    0x80b584,%edx
  800560:	74 1e                	je     800580 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
  800562:	0f b6 82 80 b3 80 00 	movzbl 0x80b380(%edx),%eax
  800569:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
  80056c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
  800572:	b9 00 00 00 00       	mov    $0x0,%ecx
  800577:	0f 44 d1             	cmove  %ecx,%edx
  80057a:	89 15 80 b5 80 00    	mov    %edx,0x80b580
		return c;
	}
	return 0;
}
  800580:	c9                   	leave  
  800581:	c3                   	ret    

00800582 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	57                   	push   %edi
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
  80058b:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
  800592:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
  800599:	5a a5 
	if (*cp != 0xA55A) {
  80059b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
  8005a2:	66 3d 5a a5          	cmp    $0xa55a,%ax
  8005a6:	74 11                	je     8005b9 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
  8005a8:	c7 05 68 b3 80 00 b4 	movl   $0x3b4,0x80b368
  8005af:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
  8005b2:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
  8005b7:	eb 16                	jmp    8005cf <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
  8005b9:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
  8005c0:	c7 05 68 b3 80 00 d4 	movl   $0x3d4,0x80b368
  8005c7:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
  8005ca:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
  8005cf:	8b 0d 68 b3 80 00    	mov    0x80b368,%ecx
  8005d5:	b8 0e 00 00 00       	mov    $0xe,%eax
  8005da:	89 ca                	mov    %ecx,%edx
  8005dc:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
  8005dd:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8005e0:	89 da                	mov    %ebx,%edx
  8005e2:	ec                   	in     (%dx),%al
  8005e3:	0f b6 f8             	movzbl %al,%edi
  8005e6:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8005e9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8005ee:	89 ca                	mov    %ecx,%edx
  8005f0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8005f1:	89 da                	mov    %ebx,%edx
  8005f3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
  8005f4:	89 35 64 b3 80 00    	mov    %esi,0x80b364
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
  8005fa:	0f b6 d8             	movzbl %al,%ebx
  8005fd:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
  8005ff:	66 89 3d 60 b3 80 00 	mov    %di,0x80b360
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800606:	bb fa 03 00 00       	mov    $0x3fa,%ebx
  80060b:	b8 00 00 00 00       	mov    $0x0,%eax
  800610:	89 da                	mov    %ebx,%edx
  800612:	ee                   	out    %al,(%dx)
  800613:	b2 fb                	mov    $0xfb,%dl
  800615:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  80061a:	ee                   	out    %al,(%dx)
  80061b:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
  800620:	b8 0c 00 00 00       	mov    $0xc,%eax
  800625:	89 ca                	mov    %ecx,%edx
  800627:	ee                   	out    %al,(%dx)
  800628:	b2 f9                	mov    $0xf9,%dl
  80062a:	b8 00 00 00 00       	mov    $0x0,%eax
  80062f:	ee                   	out    %al,(%dx)
  800630:	b2 fb                	mov    $0xfb,%dl
  800632:	b8 03 00 00 00       	mov    $0x3,%eax
  800637:	ee                   	out    %al,(%dx)
  800638:	b2 fc                	mov    $0xfc,%dl
  80063a:	b8 00 00 00 00       	mov    $0x0,%eax
  80063f:	ee                   	out    %al,(%dx)
  800640:	b2 f9                	mov    $0xf9,%dl
  800642:	b8 01 00 00 00       	mov    $0x1,%eax
  800647:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800648:	b2 fd                	mov    $0xfd,%dl
  80064a:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
  80064b:	3c ff                	cmp    $0xff,%al
  80064d:	0f 95 c0             	setne  %al
  800650:	0f b6 c0             	movzbl %al,%eax
  800653:	89 c6                	mov    %eax,%esi
  800655:	a3 6c b3 80 00       	mov    %eax,0x80b36c
  80065a:	89 da                	mov    %ebx,%edx
  80065c:	ec                   	in     (%dx),%al
  80065d:	89 ca                	mov    %ecx,%edx
  80065f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
  800660:	85 f6                	test   %esi,%esi
  800662:	75 0c                	jne    800670 <cons_init+0xee>
		cprintf("Serial port does not exist!\n");
  800664:	c7 04 24 f0 1b 80 00 	movl   $0x801bf0,(%esp)
  80066b:	e8 1e 04 00 00       	call   800a8e <cprintf>
}
  800670:	83 c4 1c             	add    $0x1c,%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	e8 a5 fb ff ff       	call   80022b <cons_putc>
}
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <getchar>:

int
getchar(void)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
  80068e:	e8 ac fe ff ff       	call   80053f <cons_getc>
  800693:	85 c0                	test   %eax,%eax
  800695:	74 f7                	je     80068e <getchar+0x6>
		/* do nothing */;
	return c;
}
  800697:	c9                   	leave  
  800698:	c3                   	ret    

00800699 <iscons>:

int
iscons(int fdnum)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
  80069c:	b8 01 00 00 00       	mov    $0x1,%eax
  8006a1:	5d                   	pop    %ebp
  8006a2:	c3                   	ret    
	...

008006b0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
  8006b6:	c7 04 24 30 1e 80 00 	movl   $0x801e30,(%esp)
  8006bd:	e8 cc 03 00 00       	call   800a8e <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
  8006c2:	c7 44 24 08 2c 00 80 	movl   $0x1080002c,0x8(%esp)
  8006c9:	10 
  8006ca:	c7 44 24 04 2c 00 80 	movl   $0x80002c,0x4(%esp)
  8006d1:	00 
  8006d2:	c7 04 24 e8 1e 80 00 	movl   $0x801ee8,(%esp)
  8006d9:	e8 b0 03 00 00       	call   800a8e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
  8006de:	c7 44 24 08 45 1b 80 	movl   $0x10801b45,0x8(%esp)
  8006e5:	10 
  8006e6:	c7 44 24 04 45 1b 80 	movl   $0x801b45,0x4(%esp)
  8006ed:	00 
  8006ee:	c7 04 24 0c 1f 80 00 	movl   $0x801f0c,(%esp)
  8006f5:	e8 94 03 00 00       	call   800a8e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
  8006fa:	c7 44 24 08 24 b3 80 	movl   $0x1080b324,0x8(%esp)
  800701:	10 
  800702:	c7 44 24 04 24 b3 80 	movl   $0x80b324,0x4(%esp)
  800709:	00 
  80070a:	c7 04 24 30 1f 80 00 	movl   $0x801f30,(%esp)
  800711:	e8 78 03 00 00       	call   800a8e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
  800716:	c7 44 24 08 a0 b9 80 	movl   $0x1080b9a0,0x8(%esp)
  80071d:	10 
  80071e:	c7 44 24 04 a0 b9 80 	movl   $0x80b9a0,0x4(%esp)
  800725:	00 
  800726:	c7 04 24 54 1f 80 00 	movl   $0x801f54,(%esp)
  80072d:	e8 5c 03 00 00       	call   800a8e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
  800732:	b8 2c 00 80 00       	mov    $0x80002c,%eax
  800737:	f7 d8                	neg    %eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
  800739:	8d 90 9e c1 80 00    	lea    0x80c19e(%eax),%edx
		(end-_start+1023)/1024);
  80073f:	05 9f bd 80 00       	add    $0x80bd9f,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
  800744:	85 c0                	test   %eax,%eax
  800746:	0f 48 c2             	cmovs  %edx,%eax
  800749:	c1 f8 0a             	sar    $0xa,%eax
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	c7 04 24 78 1f 80 00 	movl   $0x801f78,(%esp)
  800757:	e8 32 03 00 00       	call   800a8e <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n",commands[i].name, commands[i].desc);
  800769:	a1 a4 20 80 00       	mov    0x8020a4,%eax
  80076e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800772:	a1 a0 20 80 00       	mov    0x8020a0,%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	c7 04 24 49 1e 80 00 	movl   $0x801e49,(%esp)
  800782:	e8 07 03 00 00       	call   800a8e <cprintf>
  800787:	a1 b0 20 80 00       	mov    0x8020b0,%eax
  80078c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800790:	a1 ac 20 80 00       	mov    0x8020ac,%eax
  800795:	89 44 24 04          	mov    %eax,0x4(%esp)
  800799:	c7 04 24 49 1e 80 00 	movl   $0x801e49,(%esp)
  8007a0:	e8 e9 02 00 00       	call   800a8e <cprintf>
  8007a5:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  8007aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ae:	a1 b8 20 80 00       	mov    0x8020b8,%eax
  8007b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b7:	c7 04 24 49 1e 80 00 	movl   $0x801e49,(%esp)
  8007be:	e8 cb 02 00 00       	call   800a8e <cprintf>
	return 0;
}
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	57                   	push   %edi
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
  8007d3:	c7 04 24 a4 1f 80 00 	movl   $0x801fa4,(%esp)
  8007da:	e8 af 02 00 00       	call   800a8e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
  8007df:	c7 04 24 c8 1f 80 00 	movl   $0x801fc8,(%esp)
  8007e6:	e8 a3 02 00 00       	call   800a8e <cprintf>


	while (1) {
		buf = readline("K> ");
  8007eb:	c7 04 24 52 1e 80 00 	movl   $0x801e52,(%esp)
  8007f2:	e8 29 0c 00 00       	call   801420 <readline>
  8007f7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 ee                	je     8007eb <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
  8007fd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
  800804:	be 00 00 00 00       	mov    $0x0,%esi
  800809:	eb 06                	jmp    800811 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
  80080b:	c6 03 00             	movb   $0x0,(%ebx)
  80080e:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  800811:	0f b6 03             	movzbl (%ebx),%eax
  800814:	84 c0                	test   %al,%al
  800816:	74 6a                	je     800882 <monitor+0xb8>
  800818:	0f be c0             	movsbl %al,%eax
  80081b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081f:	c7 04 24 56 1e 80 00 	movl   $0x801e56,(%esp)
  800826:	e8 0b 0e 00 00       	call   801636 <strchr>
  80082b:	85 c0                	test   %eax,%eax
  80082d:	75 dc                	jne    80080b <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
  80082f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800832:	74 4e                	je     800882 <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
  800834:	83 fe 0f             	cmp    $0xf,%esi
  800837:	75 16                	jne    80084f <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
  800839:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800840:	00 
  800841:	c7 04 24 5b 1e 80 00 	movl   $0x801e5b,(%esp)
  800848:	e8 41 02 00 00       	call   800a8e <cprintf>
  80084d:	eb 9c                	jmp    8007eb <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
  80084f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
  800853:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
  800856:	0f b6 03             	movzbl (%ebx),%eax
  800859:	84 c0                	test   %al,%al
  80085b:	75 0c                	jne    800869 <monitor+0x9f>
  80085d:	eb b2                	jmp    800811 <monitor+0x47>
			buf++;
  80085f:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
  800862:	0f b6 03             	movzbl (%ebx),%eax
  800865:	84 c0                	test   %al,%al
  800867:	74 a8                	je     800811 <monitor+0x47>
  800869:	0f be c0             	movsbl %al,%eax
  80086c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800870:	c7 04 24 56 1e 80 00 	movl   $0x801e56,(%esp)
  800877:	e8 ba 0d 00 00       	call   801636 <strchr>
  80087c:	85 c0                	test   %eax,%eax
  80087e:	74 df                	je     80085f <monitor+0x95>
  800880:	eb 8f                	jmp    800811 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
  800882:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  800889:	00 

	// Lookup and invoke the command
	if (argc == 0)
  80088a:	85 f6                	test   %esi,%esi
  80088c:	0f 84 59 ff ff ff    	je     8007eb <monitor+0x21>
  800892:	bb a0 20 80 00       	mov    $0x8020a0,%ebx
  800897:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
  80089c:	8b 03                	mov    (%ebx),%eax
  80089e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a2:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8008a5:	89 04 24             	mov    %eax,(%esp)
  8008a8:	e8 0f 0d 00 00       	call   8015bc <strcmp>
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	75 23                	jne    8008d4 <monitor+0x10a>
			return commands[i].func(argc, argv, tf);
  8008b1:	6b ff 0c             	imul   $0xc,%edi,%edi
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bb:	8d 45 a8             	lea    -0x58(%ebp),%eax
  8008be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c2:	89 34 24             	mov    %esi,(%esp)
  8008c5:	ff 97 a8 20 80 00    	call   *0x8020a8(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 28                	js     8008f7 <monitor+0x12d>
  8008cf:	e9 17 ff ff ff       	jmp    8007eb <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
  8008d4:	83 c7 01             	add    $0x1,%edi
  8008d7:	83 c3 0c             	add    $0xc,%ebx
  8008da:	83 ff 03             	cmp    $0x3,%edi
  8008dd:	75 bd                	jne    80089c <monitor+0xd2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
  8008df:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8008e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e6:	c7 04 24 78 1e 80 00 	movl   $0x801e78,(%esp)
  8008ed:	e8 9c 01 00 00       	call   800a8e <cprintf>
  8008f2:	e9 f4 fe ff ff       	jmp    8007eb <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
  8008f7:	83 c4 5c             	add    $0x5c,%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
  800902:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	81 ec 4c 01 00 00    	sub    $0x14c,%esp
	// Your code here.
	int ebp_lst, ebp_cur, ebp_prev, eip_cur, args[5];
	//__asm __volatile("movl %%ebp, %0;":"=r"(ebp_cur));
	ebp_cur = (uint32_t)read_ebp();
  800913:	89 ee                	mov    %ebp,%esi
	cprintf("Stack backtrace:\n");
  800915:	c7 04 24 8e 1e 80 00 	movl   $0x801e8e,(%esp)
  80091c:	e8 6d 01 00 00       	call   800a8e <cprintf>
	eip_cur = (uint32_t)read_eip();
  800921:	e8 d9 ff ff ff       	call   8008ff <read_eip>
  800926:	89 c7                	mov    %eax,%edi
	struct Eipdebuginfo *e = NULL;
	int k =1;
  800928:	c7 85 e4 fe ff ff 01 	movl   $0x1,-0x11c(%ebp)
  80092f:	00 00 00 
	while(k != 0)	
	{
		if(ebp_cur == 0)
			k =0;				
  800932:	bb 00 00 00 00       	mov    $0x0,%ebx
  800937:	85 f6                	test   %esi,%esi
  800939:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
  80093f:	0f 44 c3             	cmove  %ebx,%eax
  800942:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
		memset(e, 0, sizeof(struct Eipdebuginfo));
  800948:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
  80094f:	00 
  800950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800954:	89 1c 24             	mov    %ebx,(%esp)
  800957:	e8 35 0d 00 00       	call   801691 <memset>
		debuginfo_eip(eip_cur, e);
  80095c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800960:	89 3c 24             	mov    %edi,(%esp)
  800963:	e8 76 02 00 00       	call   800bde <debuginfo_eip>
		__asm __volatile("movl 8(%1), %0;":"=r"(args[0]):"r"(ebp_cur));
  800968:	8b 46 08             	mov    0x8(%esi),%eax
  80096b:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
		__asm __volatile("movl 12(%1), %0;":"=r"(args[1]):"r"(ebp_cur));
  800971:	8b 46 0c             	mov    0xc(%esi),%eax
  800974:	89 85 dc fe ff ff    	mov    %eax,-0x124(%ebp)
		__asm __volatile("movl 16(%1), %0;":"=r"(args[2]):"r"(ebp_cur));
  80097a:	8b 46 10             	mov    0x10(%esi),%eax
  80097d:	89 85 d8 fe ff ff    	mov    %eax,-0x128(%ebp)
		__asm __volatile("movl 20(%1), %0;":"=r"(args[3]):"r"(ebp_cur));
  800983:	8b 46 14             	mov    0x14(%esi),%eax
  800986:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
		__asm __volatile("movl 24(%1), %0;":"=r"(args[4]):"r"(ebp_cur));
  80098c:	8b 46 18             	mov    0x18(%esi),%eax
  80098f:	89 85 d0 fe ff ff    	mov    %eax,-0x130(%ebp)
		char s[256];
		strcpy(s, e->eip_fn_name);
  800995:	8b 43 08             	mov    0x8(%ebx),%eax
  800998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 87 0b 00 00       	call   801531 <strcpy>
		s[e->eip_fn_namelen] = '\0';
  8009aa:	8b 43 0c             	mov    0xc(%ebx),%eax
  8009ad:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
  8009b4:	00 
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n", ebp_cur, eip_cur, args[0], args[1], args[2], args[3], args[4]);
  8009b5:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
  8009bb:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8009bf:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
  8009c5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8009c9:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
  8009cf:	89 44 24 14          	mov    %eax,0x14(%esp)
  8009d3:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
  8009d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009dd:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
  8009e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e7:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ef:	c7 04 24 f0 1f 80 00 	movl   $0x801ff0,(%esp)
  8009f6:	e8 93 00 00 00       	call   800a8e <cprintf>
		cprintf("%s:%d:  %s+%d\n", e->eip_file, e->eip_line,s, eip_cur-e->eip_fn_addr);
  8009fb:	2b 7b 10             	sub    0x10(%ebx),%edi
  8009fe:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800a02:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0c:	8b 43 04             	mov    0x4(%ebx),%eax
  800a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a13:	8b 03                	mov    (%ebx),%eax
  800a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a19:	c7 04 24 a0 1e 80 00 	movl   $0x801ea0,(%esp)
  800a20:	e8 69 00 00 00       	call   800a8e <cprintf>

		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
  800a25:	8b 7e 04             	mov    0x4(%esi),%edi
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		
  800a28:	8b 36                	mov    (%esi),%esi
	ebp_cur = (uint32_t)read_ebp();
	cprintf("Stack backtrace:\n");
	eip_cur = (uint32_t)read_eip();
	struct Eipdebuginfo *e = NULL;
	int k =1;
	while(k != 0)	
  800a2a:	83 bd e4 fe ff ff 00 	cmpl   $0x0,-0x11c(%ebp)
  800a31:	0f 85 00 ff ff ff    	jne    800937 <mon_backtrace+0x30>
		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		

	} 
	return 0;
}
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	81 c4 4c 01 00 00    	add    $0x14c,%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    
	...

00800a48 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	89 04 24             	mov    %eax,(%esp)
  800a54:	e8 1f fc ff ff       	call   800678 <cputchar>
	*cnt++;
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
  800a61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7d:	c7 04 24 48 0a 80 00 	movl   $0x800a48,(%esp)
  800a84:	e8 ee 04 00 00       	call   800f77 <vprintfmt>
	return cnt;
}
  800a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a94:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	89 04 24             	mov    %eax,(%esp)
  800aa1:	e8 b5 ff ff ff       	call   800a5b <vcprintf>
	va_end(ap);

	return cnt;
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    
	...

00800ab0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 14             	sub    $0x14,%esp
  800ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800abc:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800abf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800ac2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
  800ac5:	8b 1a                	mov    (%edx),%ebx
  800ac7:	8b 01                	mov    (%ecx),%eax
  800ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
  800acc:	39 c3                	cmp    %eax,%ebx
  800ace:	0f 8f 9c 00 00 00    	jg     800b70 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
  800ad4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
  800adb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ade:	01 d8                	add    %ebx,%eax
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	c1 ef 1f             	shr    $0x1f,%edi
  800ae5:	01 c7                	add    %eax,%edi
  800ae7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
  800ae9:	39 df                	cmp    %ebx,%edi
  800aeb:	7c 33                	jl     800b20 <stab_binsearch+0x70>
  800aed:	8d 04 7f             	lea    (%edi,%edi,2),%eax
  800af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800af3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
  800af8:	39 f0                	cmp    %esi,%eax
  800afa:	0f 84 bc 00 00 00    	je     800bbc <stab_binsearch+0x10c>
  800b00:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
  800b04:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
  800b08:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
  800b0a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
  800b0d:	39 d8                	cmp    %ebx,%eax
  800b0f:	7c 0f                	jl     800b20 <stab_binsearch+0x70>
  800b11:	0f b6 0a             	movzbl (%edx),%ecx
  800b14:	83 ea 0c             	sub    $0xc,%edx
  800b17:	39 f1                	cmp    %esi,%ecx
  800b19:	75 ef                	jne    800b0a <stab_binsearch+0x5a>
  800b1b:	e9 9e 00 00 00       	jmp    800bbe <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
  800b20:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
  800b23:	eb 3c                	jmp    800b61 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
  800b25:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800b28:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
  800b2a:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
  800b2d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800b34:	eb 2b                	jmp    800b61 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
  800b36:	3b 55 0c             	cmp    0xc(%ebp),%edx
  800b39:	76 14                	jbe    800b4f <stab_binsearch+0x9f>
			*region_right = m - 1;
  800b3b:	83 e8 01             	sub    $0x1,%eax
  800b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b41:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800b44:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
  800b46:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800b4d:	eb 12                	jmp    800b61 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
  800b4f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800b52:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
  800b54:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  800b58:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
  800b5a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
  800b61:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
  800b64:	0f 8d 71 ff ff ff    	jge    800adb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
  800b6a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b6e:	75 0f                	jne    800b7f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
  800b70:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800b73:	8b 03                	mov    (%ebx),%eax
  800b75:	83 e8 01             	sub    $0x1,%eax
  800b78:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800b7b:	89 02                	mov    %eax,(%edx)
  800b7d:	eb 57                	jmp    800bd6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800b7f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b82:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
  800b84:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800b87:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800b89:	39 c1                	cmp    %eax,%ecx
  800b8b:	7d 28                	jge    800bb5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
  800b8d:	8d 14 40             	lea    (%eax,%eax,2),%edx
  800b90:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800b93:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
  800b98:	39 f2                	cmp    %esi,%edx
  800b9a:	74 19                	je     800bb5 <stab_binsearch+0x105>
  800b9c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
  800ba0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
  800ba4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800ba7:	39 c1                	cmp    %eax,%ecx
  800ba9:	7d 0a                	jge    800bb5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
  800bab:	0f b6 1a             	movzbl (%edx),%ebx
  800bae:	83 ea 0c             	sub    $0xc,%edx
  800bb1:	39 f3                	cmp    %esi,%ebx
  800bb3:	75 ef                	jne    800ba4 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
  800bb5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800bb8:	89 02                	mov    %eax,(%edx)
  800bba:	eb 1a                	jmp    800bd6 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
  800bbc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
  800bbe:	8d 14 40             	lea    (%eax,%eax,2),%edx
  800bc1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800bc4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
  800bc8:	3b 55 0c             	cmp    0xc(%ebp),%edx
  800bcb:	0f 82 54 ff ff ff    	jb     800b25 <stab_binsearch+0x75>
  800bd1:	e9 60 ff ff ff       	jmp    800b36 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
  800bd6:	83 c4 14             	add    $0x14,%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 58             	sub    $0x58,%esp
  800be4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bea:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bed:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
  800bf3:	c7 03 c4 20 80 00    	movl   $0x8020c4,(%ebx)
	info->eip_line = 0;
  800bf9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
  800c00:	c7 43 08 c4 20 80 00 	movl   $0x8020c4,0x8(%ebx)
	info->eip_fn_namelen = 9;
  800c07:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
  800c0e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
  800c11:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
  800c18:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
  800c1e:	76 12                	jbe    800c32 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
  800c20:	b8 ab 54 20 00       	mov    $0x2054ab,%eax
  800c25:	3d 8d 3b 20 00       	cmp    $0x203b8d,%eax
  800c2a:	0f 86 aa 01 00 00    	jbe    800dda <debuginfo_eip+0x1fc>
  800c30:	eb 1c                	jmp    800c4e <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
  800c32:	c7 44 24 08 ce 20 80 	movl   $0x8020ce,0x8(%esp)
  800c39:	00 
  800c3a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800c41:	00 
  800c42:	c7 04 24 db 20 80 00 	movl   $0x8020db,(%esp)
  800c49:	e8 ca f4 ff ff       	call   800118 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
  800c4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
  800c53:	80 3d aa 54 20 00 00 	cmpb   $0x0,0x2054aa
  800c5a:	0f 85 86 01 00 00    	jne    800de6 <debuginfo_eip+0x208>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
  800c60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
  800c67:	b8 8c 3b 20 00       	mov    $0x203b8c,%eax
  800c6c:	2d 10 00 20 00       	sub    $0x200010,%eax
  800c71:	c1 f8 02             	sar    $0x2,%eax
  800c74:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  800c7a:	83 e8 01             	sub    $0x1,%eax
  800c7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  800c80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c84:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  800c8b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  800c8e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800c91:	b8 10 00 20 00       	mov    $0x200010,%eax
  800c96:	e8 15 fe ff ff       	call   800ab0 <stab_binsearch>
	if (lfile == 0)
  800c9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
  800c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
  800ca3:	85 d2                	test   %edx,%edx
  800ca5:	0f 84 3b 01 00 00    	je     800de6 <debuginfo_eip+0x208>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
  800cab:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
  800cae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cb1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  800cb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb8:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
  800cbf:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  800cc2:	8d 55 dc             	lea    -0x24(%ebp),%edx
  800cc5:	b8 10 00 20 00       	mov    $0x200010,%eax
  800cca:	e8 e1 fd ff ff       	call   800ab0 <stab_binsearch>

	if (lfun <= rfun) {
  800ccf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800cd2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800cd5:	39 d0                	cmp    %edx,%eax
  800cd7:	7f 3a                	jg     800d13 <debuginfo_eip+0x135>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
  800cd9:	6b c8 0c             	imul   $0xc,%eax,%ecx
  800cdc:	8b 89 10 00 20 00    	mov    0x200010(%ecx),%ecx
  800ce2:	bf ab 54 20 00       	mov    $0x2054ab,%edi
  800ce7:	81 ef 8d 3b 20 00    	sub    $0x203b8d,%edi
  800ced:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800cf0:	39 f9                	cmp    %edi,%ecx
  800cf2:	73 09                	jae    800cfd <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  800cf4:	81 c1 8d 3b 20 00    	add    $0x203b8d,%ecx
  800cfa:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
  800cfd:	6b c8 0c             	imul   $0xc,%eax,%ecx
  800d00:	8b 89 18 00 20 00    	mov    0x200018(%ecx),%ecx
  800d06:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
  800d09:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
  800d0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
  800d0e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800d11:	eb 0f                	jmp    800d22 <debuginfo_eip+0x144>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
  800d13:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
  800d16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d19:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
  800d1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d1f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  800d22:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800d29:	00 
  800d2a:	8b 43 08             	mov    0x8(%ebx),%eax
  800d2d:	89 04 24             	mov    %eax,(%esp)
  800d30:	e8 35 09 00 00       	call   80166a <strfind>
  800d35:	2b 43 08             	sub    0x8(%ebx),%eax
  800d38:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  800d3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d3f:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
  800d46:	8d 4d d0             	lea    -0x30(%ebp),%ecx
  800d49:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  800d4c:	b8 10 00 20 00       	mov    $0x200010,%eax
  800d51:	e8 5a fd ff ff       	call   800ab0 <stab_binsearch>
	if(lline <= rline) {
  800d56:	8b 45 d0             	mov    -0x30(%ebp),%eax
		info->eip_line = rline;
  800d59:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  800d5c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800d61:	0f 4f c2             	cmovg  %edx,%eax
  800d64:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
  800d67:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800d6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
  800d6d:	6b d0 0c             	imul   $0xc,%eax,%edx
  800d70:	81 c2 18 00 20 00    	add    $0x200018,%edx
  800d76:	eb 06                	jmp    800d7e <debuginfo_eip+0x1a0>
  800d78:	83 e8 01             	sub    $0x1,%eax
  800d7b:	83 ea 0c             	sub    $0xc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
  800d7e:	39 c6                	cmp    %eax,%esi
  800d80:	7f 1c                	jg     800d9e <debuginfo_eip+0x1c0>
	       && stabs[lline].n_type != N_SOL
  800d82:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
  800d86:	80 f9 84             	cmp    $0x84,%cl
  800d89:	74 68                	je     800df3 <debuginfo_eip+0x215>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
  800d8b:	80 f9 64             	cmp    $0x64,%cl
  800d8e:	75 e8                	jne    800d78 <debuginfo_eip+0x19a>
  800d90:	83 3a 00             	cmpl   $0x0,(%edx)
  800d93:	74 e3                	je     800d78 <debuginfo_eip+0x19a>
  800d95:	eb 5c                	jmp    800df3 <debuginfo_eip+0x215>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
  800d97:	05 8d 3b 20 00       	add    $0x203b8d,%eax
  800d9c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
  800d9e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800da1:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
  800da9:	39 fa                	cmp    %edi,%edx
  800dab:	7d 39                	jge    800de6 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
  800dad:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
  800db0:	6b d0 0c             	imul   $0xc,%eax,%edx
  800db3:	81 c2 14 00 20 00    	add    $0x200014,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
  800db9:	eb 07                	jmp    800dc2 <debuginfo_eip+0x1e4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
  800dbb:	83 43 14 01          	addl   $0x1,0x14(%ebx)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
  800dbf:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
  800dc2:	39 c7                	cmp    %eax,%edi
  800dc4:	7e 1b                	jle    800de1 <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
  800dc6:	0f b6 32             	movzbl (%edx),%esi
  800dc9:	83 c2 0c             	add    $0xc,%edx
  800dcc:	89 f1                	mov    %esi,%ecx
  800dce:	80 f9 a0             	cmp    $0xa0,%cl
  800dd1:	74 e8                	je     800dbb <debuginfo_eip+0x1dd>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
  800dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd8:	eb 0c                	jmp    800de6 <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
  800dda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ddf:	eb 05                	jmp    800de6 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
  800de1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800def:	89 ec                	mov    %ebp,%esp
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
  800df3:	6b c0 0c             	imul   $0xc,%eax,%eax
  800df6:	8b 80 10 00 20 00    	mov    0x200010(%eax),%eax
  800dfc:	ba ab 54 20 00       	mov    $0x2054ab,%edx
  800e01:	81 ea 8d 3b 20 00    	sub    $0x203b8d,%edx
  800e07:	39 d0                	cmp    %edx,%eax
  800e09:	72 8c                	jb     800d97 <debuginfo_eip+0x1b9>
  800e0b:	eb 91                	jmp    800d9e <debuginfo_eip+0x1c0>
  800e0d:	00 00                	add    %al,(%eax)
	...

00800e10 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 4c             	sub    $0x4c,%esp
  800e19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e1c:	89 d6                	mov    %edx,%esi
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e27:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e2a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800e2d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
  800e35:	39 d0                	cmp    %edx,%eax
  800e37:	72 11                	jb     800e4a <printnum+0x3a>
  800e39:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800e3c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  800e3f:	76 09                	jbe    800e4a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e41:	83 eb 01             	sub    $0x1,%ebx
  800e44:	85 db                	test   %ebx,%ebx
  800e46:	7f 5d                	jg     800ea5 <printnum+0x95>
  800e48:	eb 6c                	jmp    800eb6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800e4a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800e4e:	83 eb 01             	sub    $0x1,%ebx
  800e51:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e5c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e60:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800e64:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800e67:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800e6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e71:	00 
  800e72:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800e75:	89 14 24             	mov    %edx,(%esp)
  800e78:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e7b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e7f:	e8 6c 0a 00 00       	call   8018f0 <__udivdi3>
  800e84:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e87:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e8a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e92:	89 04 24             	mov    %eax,(%esp)
  800e95:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e99:	89 f2                	mov    %esi,%edx
  800e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e9e:	e8 6d ff ff ff       	call   800e10 <printnum>
  800ea3:	eb 11                	jmp    800eb6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ea5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea9:	89 3c 24             	mov    %edi,(%esp)
  800eac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800eaf:	83 eb 01             	sub    $0x1,%ebx
  800eb2:	85 db                	test   %ebx,%ebx
  800eb4:	7f ef                	jg     800ea5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800eb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eba:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ebe:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ecc:	00 
  800ecd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ed0:	89 14 24             	mov    %edx,(%esp)
  800ed3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ed6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800eda:	e8 21 0b 00 00       	call   801a00 <__umoddi3>
  800edf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee3:	0f be 80 e9 20 80 00 	movsbl 0x8020e9(%eax),%eax
  800eea:	89 04 24             	mov    %eax,(%esp)
  800eed:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800ef0:	83 c4 4c             	add    $0x4c,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800efb:	83 fa 01             	cmp    $0x1,%edx
  800efe:	7e 0e                	jle    800f0e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f00:	8b 10                	mov    (%eax),%edx
  800f02:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f05:	89 08                	mov    %ecx,(%eax)
  800f07:	8b 02                	mov    (%edx),%eax
  800f09:	8b 52 04             	mov    0x4(%edx),%edx
  800f0c:	eb 22                	jmp    800f30 <getuint+0x38>
	else if (lflag)
  800f0e:	85 d2                	test   %edx,%edx
  800f10:	74 10                	je     800f22 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f12:	8b 10                	mov    (%eax),%edx
  800f14:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f17:	89 08                	mov    %ecx,(%eax)
  800f19:	8b 02                	mov    (%edx),%eax
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	eb 0e                	jmp    800f30 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f22:	8b 10                	mov    (%eax),%edx
  800f24:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f27:	89 08                	mov    %ecx,(%eax)
  800f29:	8b 02                	mov    (%edx),%eax
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800f38:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800f3c:	8b 10                	mov    (%eax),%edx
  800f3e:	3b 50 04             	cmp    0x4(%eax),%edx
  800f41:	73 0a                	jae    800f4d <sprintputch+0x1b>
		*b->buf++ = ch;
  800f43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f46:	88 0a                	mov    %cl,(%edx)
  800f48:	83 c2 01             	add    $0x1,%edx
  800f4b:	89 10                	mov    %edx,(%eax)
}
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800f55:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800f58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6d:	89 04 24             	mov    %eax,(%esp)
  800f70:	e8 02 00 00 00       	call   800f77 <vprintfmt>
	va_end(ap);
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 4c             	sub    $0x4c,%esp
  800f80:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f86:	eb 12                	jmp    800f9a <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	0f 84 00 04 00 00    	je     801390 <vprintfmt+0x419>
				return;
			putch(ch, putdat);
  800f90:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f94:	89 04 24             	mov    %eax,(%esp)
  800f97:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800f9a:	0f b6 03             	movzbl (%ebx),%eax
  800f9d:	83 c3 01             	add    $0x1,%ebx
  800fa0:	83 f8 25             	cmp    $0x25,%eax
  800fa3:	75 e3                	jne    800f88 <vprintfmt+0x11>
  800fa5:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800fa9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800fb0:	be ff ff ff ff       	mov    $0xffffffff,%esi
  800fb5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800fbc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800fc3:	89 d8                	mov    %ebx,%eax
  800fc5:	eb 23                	jmp    800fea <vprintfmt+0x73>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fc7:	89 d8                	mov    %ebx,%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800fc9:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800fcd:	eb 1b                	jmp    800fea <vprintfmt+0x73>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fcf:	89 d8                	mov    %ebx,%eax
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800fd1:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800fd5:	eb 13                	jmp    800fea <vprintfmt+0x73>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fd7:	89 d8                	mov    %ebx,%eax
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800fd9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800fe0:	eb 08                	jmp    800fea <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800fe2:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800fe5:	be ff ff ff ff       	mov    $0xffffffff,%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fea:	0f b6 08             	movzbl (%eax),%ecx
  800fed:	0f b6 d1             	movzbl %cl,%edx
  800ff0:	8d 58 01             	lea    0x1(%eax),%ebx
  800ff3:	83 e9 23             	sub    $0x23,%ecx
  800ff6:	80 f9 55             	cmp    $0x55,%cl
  800ff9:	0f 87 6f 03 00 00    	ja     80136e <vprintfmt+0x3f7>
  800fff:	0f b6 c9             	movzbl %cl,%ecx
  801002:	ff 24 8d 78 21 80 00 	jmp    *0x802178(,%ecx,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801009:	8d 72 d0             	lea    -0x30(%edx),%esi
				ch = *fmt;
  80100c:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80100f:	8d 4a d0             	lea    -0x30(%edx),%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801012:	89 d8                	mov    %ebx,%eax
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  801014:	83 f9 09             	cmp    $0x9,%ecx
  801017:	77 3b                	ja     801054 <vprintfmt+0xdd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801019:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80101c:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
  80101f:	8d 74 4a d0          	lea    -0x30(%edx,%ecx,2),%esi
				ch = *fmt;
  801023:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801026:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801029:	83 f9 09             	cmp    $0x9,%ecx
  80102c:	76 eb                	jbe    801019 <vprintfmt+0xa2>
  80102e:	eb 24                	jmp    801054 <vprintfmt+0xdd>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801030:	8b 45 14             	mov    0x14(%ebp),%eax
  801033:	8d 50 04             	lea    0x4(%eax),%edx
  801036:	89 55 14             	mov    %edx,0x14(%ebp)
  801039:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80103b:	89 d8                	mov    %ebx,%eax
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80103d:	eb 15                	jmp    801054 <vprintfmt+0xdd>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80103f:	89 d8                	mov    %ebx,%eax
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  801041:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801045:	79 a3                	jns    800fea <vprintfmt+0x73>
  801047:	eb 8e                	jmp    800fd7 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801049:	89 d8                	mov    %ebx,%eax
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80104b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801052:	eb 96                	jmp    800fea <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  801054:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801058:	79 90                	jns    800fea <vprintfmt+0x73>
  80105a:	eb 86                	jmp    800fe2 <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80105c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801060:	89 d8                	mov    %ebx,%eax
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801062:	eb 86                	jmp    800fea <vprintfmt+0x73>
  801064:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801067:	8b 45 14             	mov    0x14(%ebp),%eax
  80106a:	8d 50 04             	lea    0x4(%eax),%edx
  80106d:	89 55 14             	mov    %edx,0x14(%ebp)
  801070:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801074:	8b 00                	mov    (%eax),%eax
  801076:	89 04 24             	mov    %eax,(%esp)
  801079:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80107c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80107f:	e9 16 ff ff ff       	jmp    800f9a <vprintfmt+0x23>
  801084:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801087:	8b 45 14             	mov    0x14(%ebp),%eax
  80108a:	8d 50 04             	lea    0x4(%eax),%edx
  80108d:	89 55 14             	mov    %edx,0x14(%ebp)
  801090:	8b 00                	mov    (%eax),%eax
  801092:	89 c2                	mov    %eax,%edx
  801094:	c1 fa 1f             	sar    $0x1f,%edx
  801097:	31 d0                	xor    %edx,%eax
  801099:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80109b:	83 f8 06             	cmp    $0x6,%eax
  80109e:	7f 0b                	jg     8010ab <vprintfmt+0x134>
  8010a0:	8b 14 85 d0 22 80 00 	mov    0x8022d0(,%eax,4),%edx
  8010a7:	85 d2                	test   %edx,%edx
  8010a9:	75 23                	jne    8010ce <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  8010ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010af:	c7 44 24 08 01 21 80 	movl   $0x802101,0x8(%esp)
  8010b6:	00 
  8010b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	89 04 24             	mov    %eax,(%esp)
  8010c1:	e8 89 fe ff ff       	call   800f4f <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8010c9:	e9 cc fe ff ff       	jmp    800f9a <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8010ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d2:	c7 44 24 08 0a 21 80 	movl   $0x80210a,0x8(%esp)
  8010d9:	00 
  8010da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010de:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e1:	89 14 24             	mov    %edx,(%esp)
  8010e4:	e8 66 fe ff ff       	call   800f4f <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8010ec:	e9 a9 fe ff ff       	jmp    800f9a <vprintfmt+0x23>
  8010f1:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8010f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8010fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8010fd:	8d 50 04             	lea    0x4(%eax),%edx
  801100:	89 55 14             	mov    %edx,0x14(%ebp)
  801103:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  801105:	85 c0                	test   %eax,%eax
  801107:	ba fa 20 80 00       	mov    $0x8020fa,%edx
  80110c:	0f 45 d0             	cmovne %eax,%edx
  80110f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if (width > 0 && padc != '-')
  801112:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801116:	7e 06                	jle    80111e <vprintfmt+0x1a7>
  801118:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80111c:	75 19                	jne    801137 <vprintfmt+0x1c0>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80111e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801121:	0f be 02             	movsbl (%edx),%eax
  801124:	83 c2 01             	add    $0x1,%edx
  801127:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80112a:	85 c0                	test   %eax,%eax
  80112c:	0f 85 97 00 00 00    	jne    8011c9 <vprintfmt+0x252>
  801132:	e9 84 00 00 00       	jmp    8011bb <vprintfmt+0x244>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801137:	89 74 24 04          	mov    %esi,0x4(%esp)
  80113b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80113e:	89 04 24             	mov    %eax,(%esp)
  801141:	e8 c5 03 00 00       	call   80150b <strnlen>
  801146:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801149:	29 c2                	sub    %eax,%edx
  80114b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80114e:	85 d2                	test   %edx,%edx
  801150:	7e cc                	jle    80111e <vprintfmt+0x1a7>
					putch(padc, putdat);
  801152:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801156:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801159:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80115c:	89 d3                	mov    %edx,%ebx
  80115e:	89 c6                	mov    %eax,%esi
  801160:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801164:	89 34 24             	mov    %esi,(%esp)
  801167:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80116a:	83 eb 01             	sub    $0x1,%ebx
  80116d:	85 db                	test   %ebx,%ebx
  80116f:	7f ef                	jg     801160 <vprintfmt+0x1e9>
  801171:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801174:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  801177:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80117e:	eb 9e                	jmp    80111e <vprintfmt+0x1a7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801180:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801184:	74 18                	je     80119e <vprintfmt+0x227>
  801186:	8d 50 e0             	lea    -0x20(%eax),%edx
  801189:	83 fa 5e             	cmp    $0x5e,%edx
  80118c:	76 10                	jbe    80119e <vprintfmt+0x227>
					putch('?', putdat);
  80118e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801192:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801199:	ff 55 08             	call   *0x8(%ebp)
  80119c:	eb 0a                	jmp    8011a8 <vprintfmt+0x231>
				else
					putch(ch, putdat);
  80119e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011a2:	89 04 24             	mov    %eax,(%esp)
  8011a5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8011a8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8011ac:	0f be 03             	movsbl (%ebx),%eax
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	74 05                	je     8011b8 <vprintfmt+0x241>
  8011b3:	83 c3 01             	add    $0x1,%ebx
  8011b6:	eb 17                	jmp    8011cf <vprintfmt+0x258>
  8011b8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8011bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011bf:	7f 1c                	jg     8011dd <vprintfmt+0x266>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8011c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8011c4:	e9 d1 fd ff ff       	jmp    800f9a <vprintfmt+0x23>
  8011c9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8011cc:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8011cf:	85 f6                	test   %esi,%esi
  8011d1:	78 ad                	js     801180 <vprintfmt+0x209>
  8011d3:	83 ee 01             	sub    $0x1,%esi
  8011d6:	79 a8                	jns    801180 <vprintfmt+0x209>
  8011d8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8011db:	eb de                	jmp    8011bb <vprintfmt+0x244>
  8011dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e0:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8011e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8011e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8011f1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8011f3:	83 eb 01             	sub    $0x1,%ebx
  8011f6:	85 db                	test   %ebx,%ebx
  8011f8:	7f ec                	jg     8011e6 <vprintfmt+0x26f>
  8011fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8011fd:	e9 98 fd ff ff       	jmp    800f9a <vprintfmt+0x23>
  801202:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801205:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
  801209:	7e 10                	jle    80121b <vprintfmt+0x2a4>
		return va_arg(*ap, long long);
  80120b:	8b 45 14             	mov    0x14(%ebp),%eax
  80120e:	8d 50 08             	lea    0x8(%eax),%edx
  801211:	89 55 14             	mov    %edx,0x14(%ebp)
  801214:	8b 18                	mov    (%eax),%ebx
  801216:	8b 70 04             	mov    0x4(%eax),%esi
  801219:	eb 28                	jmp    801243 <vprintfmt+0x2cc>
	else if (lflag)
  80121b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80121f:	74 12                	je     801233 <vprintfmt+0x2bc>
		return va_arg(*ap, long);
  801221:	8b 45 14             	mov    0x14(%ebp),%eax
  801224:	8d 50 04             	lea    0x4(%eax),%edx
  801227:	89 55 14             	mov    %edx,0x14(%ebp)
  80122a:	8b 18                	mov    (%eax),%ebx
  80122c:	89 de                	mov    %ebx,%esi
  80122e:	c1 fe 1f             	sar    $0x1f,%esi
  801231:	eb 10                	jmp    801243 <vprintfmt+0x2cc>
	else
		return va_arg(*ap, int);
  801233:	8b 45 14             	mov    0x14(%ebp),%eax
  801236:	8d 50 04             	lea    0x4(%eax),%edx
  801239:	89 55 14             	mov    %edx,0x14(%ebp)
  80123c:	8b 18                	mov    (%eax),%ebx
  80123e:	89 de                	mov    %ebx,%esi
  801240:	c1 fe 1f             	sar    $0x1f,%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801243:	ba 0a 00 00 00       	mov    $0xa,%edx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801248:	85 f6                	test   %esi,%esi
  80124a:	0f 89 dd 00 00 00    	jns    80132d <vprintfmt+0x3b6>
				putch('-', putdat);
  801250:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801254:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80125b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80125e:	f7 db                	neg    %ebx
  801260:	83 d6 00             	adc    $0x0,%esi
  801263:	f7 de                	neg    %esi
			}
			base = 10;
  801265:	ba 0a 00 00 00       	mov    $0xa,%edx
  80126a:	e9 be 00 00 00       	jmp    80132d <vprintfmt+0x3b6>
  80126f:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801272:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801275:	8d 45 14             	lea    0x14(%ebp),%eax
  801278:	e8 7b fc ff ff       	call   800ef8 <getuint>
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	89 d6                	mov    %edx,%esi
			base = 10;
  801281:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  801286:	e9 a2 00 00 00       	jmp    80132d <vprintfmt+0x3b6>

		case 'k':
			COLOR = getuint(&ap, 0);
  80128b:	ba 00 00 00 00       	mov    $0x0,%edx
  801290:	8d 45 14             	lea    0x14(%ebp),%eax
  801293:	e8 60 fc ff ff       	call   800ef8 <getuint>
			COLOR = COLOR | ~0xFF;
  801298:	0d 00 ff ff ff       	or     $0xffffff00,%eax
  80129d:	a3 20 b3 80 00       	mov    %eax,0x80b320
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	e9 41 fd ff ff       	jmp    800fea <vprintfmt+0x73>
  8012a9:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			COLOR = COLOR | ~0xFF;
			goto reswitch;
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8012ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8012af:	8d 45 14             	lea    0x14(%ebp),%eax
  8012b2:	e8 41 fc ff ff       	call   800ef8 <getuint>
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8012bb:	ba 08 00 00 00       	mov    $0x8,%edx
			goto reswitch;
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			if ((long long) num < 0) {
  8012c0:	85 f6                	test   %esi,%esi
  8012c2:	79 69                	jns    80132d <vprintfmt+0x3b6>
				putch('-', putdat);
  8012c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8012d2:	f7 db                	neg    %ebx
  8012d4:	83 d6 00             	adc    $0x0,%esi
  8012d7:	f7 de                	neg    %esi
			}
			base = 8;
  8012d9:	ba 08 00 00 00       	mov    $0x8,%edx
  8012de:	eb 4d                	jmp    80132d <vprintfmt+0x3b6>
  8012e0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8012e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012e7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8012ee:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8012f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8012fc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8012ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801302:	8d 50 04             	lea    0x4(%eax),%edx
  801305:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801308:	8b 18                	mov    (%eax),%ebx
  80130a:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80130f:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  801314:	eb 17                	jmp    80132d <vprintfmt+0x3b6>
  801316:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801319:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80131c:	8d 45 14             	lea    0x14(%ebp),%eax
  80131f:	e8 d4 fb ff ff       	call   800ef8 <getuint>
  801324:	89 c3                	mov    %eax,%ebx
  801326:	89 d6                	mov    %edx,%esi
			base = 16;
  801328:	ba 10 00 00 00       	mov    $0x10,%edx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80132d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801331:	89 44 24 10          	mov    %eax,0x10(%esp)
  801335:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801338:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133c:	89 54 24 08          	mov    %edx,0x8(%esp)
  801340:	89 1c 24             	mov    %ebx,(%esp)
  801343:	89 74 24 04          	mov    %esi,0x4(%esp)
  801347:	89 fa                	mov    %edi,%edx
  801349:	8b 45 08             	mov    0x8(%ebp),%eax
  80134c:	e8 bf fa ff ff       	call   800e10 <printnum>
			break;
  801351:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801354:	e9 41 fc ff ff       	jmp    800f9a <vprintfmt+0x23>
  801359:	89 5d d4             	mov    %ebx,-0x2c(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80135c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801360:	89 14 24             	mov    %edx,(%esp)
  801363:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801366:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801369:	e9 2c fc ff ff       	jmp    800f9a <vprintfmt+0x23>
  80136e:	89 c3                	mov    %eax,%ebx
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801370:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801374:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80137b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80137e:	eb 02                	jmp    801382 <vprintfmt+0x40b>
  801380:	89 c3                	mov    %eax,%ebx
  801382:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801385:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801389:	75 f5                	jne    801380 <vprintfmt+0x409>
  80138b:	e9 0a fc ff ff       	jmp    800f9a <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801390:	83 c4 4c             	add    $0x4c,%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 28             	sub    $0x28,%esp
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8013a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8013ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	74 30                	je     8013e9 <vsnprintf+0x51>
  8013b9:	85 d2                	test   %edx,%edx
  8013bb:	7e 2c                	jle    8013e9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8013bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	c7 04 24 32 0f 80 00 	movl   $0x800f32,(%esp)
  8013d9:	e8 99 fb ff ff       	call   800f77 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8013de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013e1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8013e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e7:	eb 05                	jmp    8013ee <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8013e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8013f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8013f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801400:	89 44 24 08          	mov    %eax,0x8(%esp)
  801404:	8b 45 0c             	mov    0xc(%ebp),%eax
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140b:	8b 45 08             	mov    0x8(%ebp),%eax
  80140e:	89 04 24             	mov    %eax,(%esp)
  801411:	e8 82 ff ff ff       	call   801398 <vsnprintf>
	va_end(ap);

	return rc;
}
  801416:	c9                   	leave  
  801417:	c3                   	ret    
	...

00801420 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	57                   	push   %edi
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
  801426:	83 ec 1c             	sub    $0x1c,%esp
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
  80142c:	85 c0                	test   %eax,%eax
  80142e:	74 10                	je     801440 <readline+0x20>
		cprintf("%s", prompt);
  801430:	89 44 24 04          	mov    %eax,0x4(%esp)
  801434:	c7 04 24 0a 21 80 00 	movl   $0x80210a,(%esp)
  80143b:	e8 4e f6 ff ff       	call   800a8e <cprintf>

	i = 0;
	echoing = iscons(0);
  801440:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801447:	e8 4d f2 ff ff       	call   800699 <iscons>
  80144c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
  80144e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801453:	e8 30 f2 ff ff       	call   800688 <getchar>
  801458:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80145a:	85 c0                	test   %eax,%eax
  80145c:	79 17                	jns    801475 <readline+0x55>
			cprintf("read error: %e\n", c);
  80145e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801462:	c7 04 24 ec 22 80 00 	movl   $0x8022ec,(%esp)
  801469:	e8 20 f6 ff ff       	call   800a8e <cprintf>
			return NULL;
  80146e:	b8 00 00 00 00       	mov    $0x0,%eax
  801473:	eb 6d                	jmp    8014e2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801475:	83 f8 08             	cmp    $0x8,%eax
  801478:	74 05                	je     80147f <readline+0x5f>
  80147a:	83 f8 7f             	cmp    $0x7f,%eax
  80147d:	75 19                	jne    801498 <readline+0x78>
  80147f:	85 f6                	test   %esi,%esi
  801481:	7e 15                	jle    801498 <readline+0x78>
			if (echoing)
  801483:	85 ff                	test   %edi,%edi
  801485:	74 0c                	je     801493 <readline+0x73>
				cputchar('\b');
  801487:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80148e:	e8 e5 f1 ff ff       	call   800678 <cputchar>
			i--;
  801493:	83 ee 01             	sub    $0x1,%esi
  801496:	eb bb                	jmp    801453 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801498:	83 fb 1f             	cmp    $0x1f,%ebx
  80149b:	7e 1f                	jle    8014bc <readline+0x9c>
  80149d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8014a3:	7f 17                	jg     8014bc <readline+0x9c>
			if (echoing)
  8014a5:	85 ff                	test   %edi,%edi
  8014a7:	74 08                	je     8014b1 <readline+0x91>
				cputchar(c);
  8014a9:	89 1c 24             	mov    %ebx,(%esp)
  8014ac:	e8 c7 f1 ff ff       	call   800678 <cputchar>
			buf[i++] = c;
  8014b1:	88 9e a0 b5 80 00    	mov    %bl,0x80b5a0(%esi)
  8014b7:	83 c6 01             	add    $0x1,%esi
  8014ba:	eb 97                	jmp    801453 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
  8014bc:	83 fb 0a             	cmp    $0xa,%ebx
  8014bf:	74 05                	je     8014c6 <readline+0xa6>
  8014c1:	83 fb 0d             	cmp    $0xd,%ebx
  8014c4:	75 8d                	jne    801453 <readline+0x33>
			if (echoing)
  8014c6:	85 ff                	test   %edi,%edi
  8014c8:	74 0c                	je     8014d6 <readline+0xb6>
				cputchar('\n');
  8014ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8014d1:	e8 a2 f1 ff ff       	call   800678 <cputchar>
			buf[i] = 0;
  8014d6:	c6 86 a0 b5 80 00 00 	movb   $0x0,0x80b5a0(%esi)
			return buf;
  8014dd:	b8 a0 b5 80 00       	mov    $0x80b5a0,%eax
		}
	}
}
  8014e2:	83 c4 1c             	add    $0x1c,%esp
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    
  8014ea:	00 00                	add    %al,(%eax)
  8014ec:	00 00                	add    %al,(%eax)
	...

008014f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8014f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8014fe:	74 09                	je     801509 <strlen+0x19>
		n++;
  801500:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801503:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801507:	75 f7                	jne    801500 <strlen+0x10>
		n++;
	return n;
}
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801511:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801514:	b8 00 00 00 00       	mov    $0x0,%eax
  801519:	85 d2                	test   %edx,%edx
  80151b:	74 12                	je     80152f <strnlen+0x24>
  80151d:	80 39 00             	cmpb   $0x0,(%ecx)
  801520:	74 0d                	je     80152f <strnlen+0x24>
		n++;
  801522:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801525:	39 d0                	cmp    %edx,%eax
  801527:	74 06                	je     80152f <strnlen+0x24>
  801529:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80152d:	75 f3                	jne    801522 <strnlen+0x17>
		n++;
	return n;
}
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	8b 45 08             	mov    0x8(%ebp),%eax
  801538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801544:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801547:	83 c2 01             	add    $0x1,%edx
  80154a:	84 c9                	test   %cl,%cl
  80154c:	75 f2                	jne    801540 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80154e:	5b                   	pop    %ebx
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	56                   	push   %esi
  801555:	53                   	push   %ebx
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155c:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80155f:	85 f6                	test   %esi,%esi
  801561:	74 18                	je     80157b <strncpy+0x2a>
  801563:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801568:	0f b6 1a             	movzbl (%edx),%ebx
  80156b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80156e:	80 3a 01             	cmpb   $0x1,(%edx)
  801571:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801574:	83 c1 01             	add    $0x1,%ecx
  801577:	39 ce                	cmp    %ecx,%esi
  801579:	77 ed                	ja     801568 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80157b:	5b                   	pop    %ebx
  80157c:	5e                   	pop    %esi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    

0080157f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	56                   	push   %esi
  801583:	53                   	push   %ebx
  801584:	8b 75 08             	mov    0x8(%ebp),%esi
  801587:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80158d:	89 f0                	mov    %esi,%eax
  80158f:	85 c9                	test   %ecx,%ecx
  801591:	74 23                	je     8015b6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  801593:	83 e9 01             	sub    $0x1,%ecx
  801596:	74 1b                	je     8015b3 <strlcpy+0x34>
  801598:	0f b6 1a             	movzbl (%edx),%ebx
  80159b:	84 db                	test   %bl,%bl
  80159d:	74 14                	je     8015b3 <strlcpy+0x34>
			*dst++ = *src++;
  80159f:	88 18                	mov    %bl,(%eax)
  8015a1:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8015a4:	83 e9 01             	sub    $0x1,%ecx
  8015a7:	74 0a                	je     8015b3 <strlcpy+0x34>
			*dst++ = *src++;
  8015a9:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8015ac:	0f b6 1a             	movzbl (%edx),%ebx
  8015af:	84 db                	test   %bl,%bl
  8015b1:	75 ec                	jne    80159f <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  8015b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8015b6:	29 f0                	sub    %esi,%eax
}
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8015c5:	0f b6 01             	movzbl (%ecx),%eax
  8015c8:	84 c0                	test   %al,%al
  8015ca:	74 15                	je     8015e1 <strcmp+0x25>
  8015cc:	3a 02                	cmp    (%edx),%al
  8015ce:	75 11                	jne    8015e1 <strcmp+0x25>
		p++, q++;
  8015d0:	83 c1 01             	add    $0x1,%ecx
  8015d3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8015d6:	0f b6 01             	movzbl (%ecx),%eax
  8015d9:	84 c0                	test   %al,%al
  8015db:	74 04                	je     8015e1 <strcmp+0x25>
  8015dd:	3a 02                	cmp    (%edx),%al
  8015df:	74 ef                	je     8015d0 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8015e1:	0f b6 c0             	movzbl %al,%eax
  8015e4:	0f b6 12             	movzbl (%edx),%edx
  8015e7:	29 d0                	sub    %edx,%eax
}
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    

008015eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	53                   	push   %ebx
  8015ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015f5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8015f8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8015fd:	85 d2                	test   %edx,%edx
  8015ff:	74 28                	je     801629 <strncmp+0x3e>
  801601:	0f b6 01             	movzbl (%ecx),%eax
  801604:	84 c0                	test   %al,%al
  801606:	74 24                	je     80162c <strncmp+0x41>
  801608:	3a 03                	cmp    (%ebx),%al
  80160a:	75 20                	jne    80162c <strncmp+0x41>
  80160c:	83 ea 01             	sub    $0x1,%edx
  80160f:	74 13                	je     801624 <strncmp+0x39>
		n--, p++, q++;
  801611:	83 c1 01             	add    $0x1,%ecx
  801614:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801617:	0f b6 01             	movzbl (%ecx),%eax
  80161a:	84 c0                	test   %al,%al
  80161c:	74 0e                	je     80162c <strncmp+0x41>
  80161e:	3a 03                	cmp    (%ebx),%al
  801620:	74 ea                	je     80160c <strncmp+0x21>
  801622:	eb 08                	jmp    80162c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801629:	5b                   	pop    %ebx
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80162c:	0f b6 01             	movzbl (%ecx),%eax
  80162f:	0f b6 13             	movzbl (%ebx),%edx
  801632:	29 d0                	sub    %edx,%eax
  801634:	eb f3                	jmp    801629 <strncmp+0x3e>

00801636 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
  80163c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801640:	0f b6 10             	movzbl (%eax),%edx
  801643:	84 d2                	test   %dl,%dl
  801645:	74 1c                	je     801663 <strchr+0x2d>
		if (*s == c)
  801647:	38 ca                	cmp    %cl,%dl
  801649:	75 07                	jne    801652 <strchr+0x1c>
  80164b:	eb 1b                	jmp    801668 <strchr+0x32>
  80164d:	38 ca                	cmp    %cl,%dl
  80164f:	90                   	nop
  801650:	74 16                	je     801668 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801652:	83 c0 01             	add    $0x1,%eax
  801655:	0f b6 10             	movzbl (%eax),%edx
  801658:	84 d2                	test   %dl,%dl
  80165a:	75 f1                	jne    80164d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
  801661:	eb 05                	jmp    801668 <strchr+0x32>
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	8b 45 08             	mov    0x8(%ebp),%eax
  801670:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801674:	0f b6 10             	movzbl (%eax),%edx
  801677:	84 d2                	test   %dl,%dl
  801679:	74 14                	je     80168f <strfind+0x25>
		if (*s == c)
  80167b:	38 ca                	cmp    %cl,%dl
  80167d:	75 06                	jne    801685 <strfind+0x1b>
  80167f:	eb 0e                	jmp    80168f <strfind+0x25>
  801681:	38 ca                	cmp    %cl,%dl
  801683:	74 0a                	je     80168f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801685:	83 c0 01             	add    $0x1,%eax
  801688:	0f b6 10             	movzbl (%eax),%edx
  80168b:	84 d2                	test   %dl,%dl
  80168d:	75 f2                	jne    801681 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	89 1c 24             	mov    %ebx,(%esp)
  80169a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8016a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8016ab:	85 c9                	test   %ecx,%ecx
  8016ad:	74 30                	je     8016df <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8016af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016b5:	75 25                	jne    8016dc <memset+0x4b>
  8016b7:	f6 c1 03             	test   $0x3,%cl
  8016ba:	75 20                	jne    8016dc <memset+0x4b>
		c &= 0xFF;
  8016bc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8016bf:	89 d3                	mov    %edx,%ebx
  8016c1:	c1 e3 08             	shl    $0x8,%ebx
  8016c4:	89 d6                	mov    %edx,%esi
  8016c6:	c1 e6 18             	shl    $0x18,%esi
  8016c9:	89 d0                	mov    %edx,%eax
  8016cb:	c1 e0 10             	shl    $0x10,%eax
  8016ce:	09 f0                	or     %esi,%eax
  8016d0:	09 d0                	or     %edx,%eax
  8016d2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8016d4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8016d7:	fc                   	cld    
  8016d8:	f3 ab                	rep stos %eax,%es:(%edi)
  8016da:	eb 03                	jmp    8016df <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8016dc:	fc                   	cld    
  8016dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8016df:	89 f8                	mov    %edi,%eax
  8016e1:	8b 1c 24             	mov    (%esp),%ebx
  8016e4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8016e8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8016ec:	89 ec                	mov    %ebp,%esp
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	89 34 24             	mov    %esi,(%esp)
  8016f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	8b 75 0c             	mov    0xc(%ebp),%esi
  801703:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801706:	39 c6                	cmp    %eax,%esi
  801708:	73 36                	jae    801740 <memmove+0x50>
  80170a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80170d:	39 d0                	cmp    %edx,%eax
  80170f:	73 2f                	jae    801740 <memmove+0x50>
		s += n;
		d += n;
  801711:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801714:	f6 c2 03             	test   $0x3,%dl
  801717:	75 1b                	jne    801734 <memmove+0x44>
  801719:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80171f:	75 13                	jne    801734 <memmove+0x44>
  801721:	f6 c1 03             	test   $0x3,%cl
  801724:	75 0e                	jne    801734 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801726:	83 ef 04             	sub    $0x4,%edi
  801729:	8d 72 fc             	lea    -0x4(%edx),%esi
  80172c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80172f:	fd                   	std    
  801730:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801732:	eb 09                	jmp    80173d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801734:	83 ef 01             	sub    $0x1,%edi
  801737:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80173a:	fd                   	std    
  80173b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80173d:	fc                   	cld    
  80173e:	eb 20                	jmp    801760 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801740:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801746:	75 13                	jne    80175b <memmove+0x6b>
  801748:	a8 03                	test   $0x3,%al
  80174a:	75 0f                	jne    80175b <memmove+0x6b>
  80174c:	f6 c1 03             	test   $0x3,%cl
  80174f:	75 0a                	jne    80175b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801751:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801754:	89 c7                	mov    %eax,%edi
  801756:	fc                   	cld    
  801757:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801759:	eb 05                	jmp    801760 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80175b:	89 c7                	mov    %eax,%edi
  80175d:	fc                   	cld    
  80175e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801760:	8b 34 24             	mov    (%esp),%esi
  801763:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801767:	89 ec                	mov    %ebp,%esp
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801771:	8b 45 10             	mov    0x10(%ebp),%eax
  801774:	89 44 24 08          	mov    %eax,0x8(%esp)
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	89 04 24             	mov    %eax,(%esp)
  801785:	e8 66 ff ff ff       	call   8016f0 <memmove>
}
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	57                   	push   %edi
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
  801792:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801795:	8b 75 0c             	mov    0xc(%ebp),%esi
  801798:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80179b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017a0:	85 ff                	test   %edi,%edi
  8017a2:	74 38                	je     8017dc <memcmp+0x50>
		if (*s1 != *s2)
  8017a4:	0f b6 03             	movzbl (%ebx),%eax
  8017a7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017aa:	83 ef 01             	sub    $0x1,%edi
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8017b2:	38 c8                	cmp    %cl,%al
  8017b4:	74 1d                	je     8017d3 <memcmp+0x47>
  8017b6:	eb 11                	jmp    8017c9 <memcmp+0x3d>
  8017b8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8017bd:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  8017c2:	83 c2 01             	add    $0x1,%edx
  8017c5:	38 c8                	cmp    %cl,%al
  8017c7:	74 0a                	je     8017d3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  8017c9:	0f b6 c0             	movzbl %al,%eax
  8017cc:	0f b6 c9             	movzbl %cl,%ecx
  8017cf:	29 c8                	sub    %ecx,%eax
  8017d1:	eb 09                	jmp    8017dc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017d3:	39 fa                	cmp    %edi,%edx
  8017d5:	75 e1                	jne    8017b8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dc:	5b                   	pop    %ebx
  8017dd:	5e                   	pop    %esi
  8017de:	5f                   	pop    %edi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8017ec:	39 d0                	cmp    %edx,%eax
  8017ee:	73 15                	jae    801805 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8017f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8017f4:	38 08                	cmp    %cl,(%eax)
  8017f6:	75 06                	jne    8017fe <memfind+0x1d>
  8017f8:	eb 0b                	jmp    801805 <memfind+0x24>
  8017fa:	38 08                	cmp    %cl,(%eax)
  8017fc:	74 07                	je     801805 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8017fe:	83 c0 01             	add    $0x1,%eax
  801801:	39 c2                	cmp    %eax,%edx
  801803:	77 f5                	ja     8017fa <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	57                   	push   %edi
  80180b:	56                   	push   %esi
  80180c:	53                   	push   %ebx
  80180d:	8b 55 08             	mov    0x8(%ebp),%edx
  801810:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801813:	0f b6 02             	movzbl (%edx),%eax
  801816:	3c 20                	cmp    $0x20,%al
  801818:	74 04                	je     80181e <strtol+0x17>
  80181a:	3c 09                	cmp    $0x9,%al
  80181c:	75 0e                	jne    80182c <strtol+0x25>
		s++;
  80181e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801821:	0f b6 02             	movzbl (%edx),%eax
  801824:	3c 20                	cmp    $0x20,%al
  801826:	74 f6                	je     80181e <strtol+0x17>
  801828:	3c 09                	cmp    $0x9,%al
  80182a:	74 f2                	je     80181e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80182c:	3c 2b                	cmp    $0x2b,%al
  80182e:	75 0a                	jne    80183a <strtol+0x33>
		s++;
  801830:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801833:	bf 00 00 00 00       	mov    $0x0,%edi
  801838:	eb 10                	jmp    80184a <strtol+0x43>
  80183a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80183f:	3c 2d                	cmp    $0x2d,%al
  801841:	75 07                	jne    80184a <strtol+0x43>
		s++, neg = 1;
  801843:	83 c2 01             	add    $0x1,%edx
  801846:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80184a:	85 db                	test   %ebx,%ebx
  80184c:	0f 94 c0             	sete   %al
  80184f:	74 05                	je     801856 <strtol+0x4f>
  801851:	83 fb 10             	cmp    $0x10,%ebx
  801854:	75 15                	jne    80186b <strtol+0x64>
  801856:	80 3a 30             	cmpb   $0x30,(%edx)
  801859:	75 10                	jne    80186b <strtol+0x64>
  80185b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80185f:	75 0a                	jne    80186b <strtol+0x64>
		s += 2, base = 16;
  801861:	83 c2 02             	add    $0x2,%edx
  801864:	bb 10 00 00 00       	mov    $0x10,%ebx
  801869:	eb 13                	jmp    80187e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  80186b:	84 c0                	test   %al,%al
  80186d:	74 0f                	je     80187e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80186f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801874:	80 3a 30             	cmpb   $0x30,(%edx)
  801877:	75 05                	jne    80187e <strtol+0x77>
		s++, base = 8;
  801879:	83 c2 01             	add    $0x1,%edx
  80187c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80187e:	b8 00 00 00 00       	mov    $0x0,%eax
  801883:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801885:	0f b6 0a             	movzbl (%edx),%ecx
  801888:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80188b:	80 fb 09             	cmp    $0x9,%bl
  80188e:	77 08                	ja     801898 <strtol+0x91>
			dig = *s - '0';
  801890:	0f be c9             	movsbl %cl,%ecx
  801893:	83 e9 30             	sub    $0x30,%ecx
  801896:	eb 1e                	jmp    8018b6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801898:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80189b:	80 fb 19             	cmp    $0x19,%bl
  80189e:	77 08                	ja     8018a8 <strtol+0xa1>
			dig = *s - 'a' + 10;
  8018a0:	0f be c9             	movsbl %cl,%ecx
  8018a3:	83 e9 57             	sub    $0x57,%ecx
  8018a6:	eb 0e                	jmp    8018b6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  8018a8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8018ab:	80 fb 19             	cmp    $0x19,%bl
  8018ae:	77 15                	ja     8018c5 <strtol+0xbe>
			dig = *s - 'A' + 10;
  8018b0:	0f be c9             	movsbl %cl,%ecx
  8018b3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8018b6:	39 f1                	cmp    %esi,%ecx
  8018b8:	7d 0f                	jge    8018c9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  8018ba:	83 c2 01             	add    $0x1,%edx
  8018bd:	0f af c6             	imul   %esi,%eax
  8018c0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8018c3:	eb c0                	jmp    801885 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8018c5:	89 c1                	mov    %eax,%ecx
  8018c7:	eb 02                	jmp    8018cb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8018c9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8018cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8018cf:	74 05                	je     8018d6 <strtol+0xcf>
		*endptr = (char *) s;
  8018d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018d4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8018d6:	89 ca                	mov    %ecx,%edx
  8018d8:	f7 da                	neg    %edx
  8018da:	85 ff                	test   %edi,%edi
  8018dc:	0f 45 c2             	cmovne %edx,%eax
}
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5f                   	pop    %edi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    
	...

008018f0 <__udivdi3>:
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	57                   	push   %edi
  8018f4:	56                   	push   %esi
  8018f5:	83 ec 20             	sub    $0x20,%esp
  8018f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8018fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801901:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801904:	85 c0                	test   %eax,%eax
  801906:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801909:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80190c:	75 3a                	jne    801948 <__udivdi3+0x58>
  80190e:	39 f9                	cmp    %edi,%ecx
  801910:	77 66                	ja     801978 <__udivdi3+0x88>
  801912:	85 c9                	test   %ecx,%ecx
  801914:	75 0b                	jne    801921 <__udivdi3+0x31>
  801916:	b8 01 00 00 00       	mov    $0x1,%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	f7 f1                	div    %ecx
  80191f:	89 c1                	mov    %eax,%ecx
  801921:	89 f8                	mov    %edi,%eax
  801923:	31 d2                	xor    %edx,%edx
  801925:	f7 f1                	div    %ecx
  801927:	89 c7                	mov    %eax,%edi
  801929:	89 f0                	mov    %esi,%eax
  80192b:	f7 f1                	div    %ecx
  80192d:	89 fa                	mov    %edi,%edx
  80192f:	89 c6                	mov    %eax,%esi
  801931:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801934:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801937:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193d:	83 c4 20             	add    $0x20,%esp
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    
  801944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801948:	31 d2                	xor    %edx,%edx
  80194a:	31 f6                	xor    %esi,%esi
  80194c:	39 f8                	cmp    %edi,%eax
  80194e:	77 e1                	ja     801931 <__udivdi3+0x41>
  801950:	0f bd d0             	bsr    %eax,%edx
  801953:	83 f2 1f             	xor    $0x1f,%edx
  801956:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801959:	75 2d                	jne    801988 <__udivdi3+0x98>
  80195b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80195e:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801961:	76 06                	jbe    801969 <__udivdi3+0x79>
  801963:	39 f8                	cmp    %edi,%eax
  801965:	89 f2                	mov    %esi,%edx
  801967:	73 c8                	jae    801931 <__udivdi3+0x41>
  801969:	31 d2                	xor    %edx,%edx
  80196b:	be 01 00 00 00       	mov    $0x1,%esi
  801970:	eb bf                	jmp    801931 <__udivdi3+0x41>
  801972:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801978:	89 f0                	mov    %esi,%eax
  80197a:	89 fa                	mov    %edi,%edx
  80197c:	f7 f1                	div    %ecx
  80197e:	31 d2                	xor    %edx,%edx
  801980:	89 c6                	mov    %eax,%esi
  801982:	eb ad                	jmp    801931 <__udivdi3+0x41>
  801984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801988:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80198c:	89 c2                	mov    %eax,%edx
  80198e:	b8 20 00 00 00       	mov    $0x20,%eax
  801993:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801996:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801999:	d3 e2                	shl    %cl,%edx
  80199b:	89 c1                	mov    %eax,%ecx
  80199d:	d3 ee                	shr    %cl,%esi
  80199f:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8019a3:	09 d6                	or     %edx,%esi
  8019a5:	89 fa                	mov    %edi,%edx
  8019a7:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8019aa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8019ad:	d3 e6                	shl    %cl,%esi
  8019af:	89 c1                	mov    %eax,%ecx
  8019b1:	d3 ea                	shr    %cl,%edx
  8019b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8019b7:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8019ba:	8b 75 e8             	mov    -0x18(%ebp),%esi
  8019bd:	d3 e7                	shl    %cl,%edi
  8019bf:	89 c1                	mov    %eax,%ecx
  8019c1:	d3 ee                	shr    %cl,%esi
  8019c3:	09 fe                	or     %edi,%esi
  8019c5:	89 f0                	mov    %esi,%eax
  8019c7:	f7 75 e4             	divl   -0x1c(%ebp)
  8019ca:	89 d7                	mov    %edx,%edi
  8019cc:	89 c6                	mov    %eax,%esi
  8019ce:	f7 65 f0             	mull   -0x10(%ebp)
  8019d1:	39 d7                	cmp    %edx,%edi
  8019d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8019d6:	72 12                	jb     8019ea <__udivdi3+0xfa>
  8019d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8019db:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8019df:	d3 e2                	shl    %cl,%edx
  8019e1:	39 c2                	cmp    %eax,%edx
  8019e3:	73 08                	jae    8019ed <__udivdi3+0xfd>
  8019e5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8019e8:	75 03                	jne    8019ed <__udivdi3+0xfd>
  8019ea:	83 ee 01             	sub    $0x1,%esi
  8019ed:	31 d2                	xor    %edx,%edx
  8019ef:	e9 3d ff ff ff       	jmp    801931 <__udivdi3+0x41>
	...

00801a00 <__umoddi3>:
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	57                   	push   %edi
  801a04:	56                   	push   %esi
  801a05:	83 ec 20             	sub    $0x20,%esp
  801a08:	8b 7d 14             	mov    0x14(%ebp),%edi
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a14:	85 ff                	test   %edi,%edi
  801a16:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801a19:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a1f:	89 f2                	mov    %esi,%edx
  801a21:	75 15                	jne    801a38 <__umoddi3+0x38>
  801a23:	39 f1                	cmp    %esi,%ecx
  801a25:	76 41                	jbe    801a68 <__umoddi3+0x68>
  801a27:	f7 f1                	div    %ecx
  801a29:	89 d0                	mov    %edx,%eax
  801a2b:	31 d2                	xor    %edx,%edx
  801a2d:	83 c4 20             	add    $0x20,%esp
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    
  801a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a38:	39 f7                	cmp    %esi,%edi
  801a3a:	77 4c                	ja     801a88 <__umoddi3+0x88>
  801a3c:	0f bd c7             	bsr    %edi,%eax
  801a3f:	83 f0 1f             	xor    $0x1f,%eax
  801a42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a45:	75 51                	jne    801a98 <__umoddi3+0x98>
  801a47:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801a4a:	0f 87 e8 00 00 00    	ja     801b38 <__umoddi3+0x138>
  801a50:	89 f2                	mov    %esi,%edx
  801a52:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801a55:	29 ce                	sub    %ecx,%esi
  801a57:	19 fa                	sbb    %edi,%edx
  801a59:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5f:	83 c4 20             	add    $0x20,%esp
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    
  801a66:	66 90                	xchg   %ax,%ax
  801a68:	85 c9                	test   %ecx,%ecx
  801a6a:	75 0b                	jne    801a77 <__umoddi3+0x77>
  801a6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a71:	31 d2                	xor    %edx,%edx
  801a73:	f7 f1                	div    %ecx
  801a75:	89 c1                	mov    %eax,%ecx
  801a77:	89 f0                	mov    %esi,%eax
  801a79:	31 d2                	xor    %edx,%edx
  801a7b:	f7 f1                	div    %ecx
  801a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a80:	eb a5                	jmp    801a27 <__umoddi3+0x27>
  801a82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a88:	89 f2                	mov    %esi,%edx
  801a8a:	83 c4 20             	add    $0x20,%esp
  801a8d:	5e                   	pop    %esi
  801a8e:	5f                   	pop    %edi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    
  801a91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a98:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801a9c:	89 f2                	mov    %esi,%edx
  801a9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aa1:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801aa8:	29 45 f0             	sub    %eax,-0x10(%ebp)
  801aab:	d3 e7                	shl    %cl,%edi
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ab4:	d3 e8                	shr    %cl,%eax
  801ab6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801aba:	09 f8                	or     %edi,%eax
  801abc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	d3 e0                	shl    %cl,%eax
  801ac4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ac8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801acb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ace:	d3 ea                	shr    %cl,%edx
  801ad0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ad4:	d3 e6                	shl    %cl,%esi
  801ad6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ada:	d3 e8                	shr    %cl,%eax
  801adc:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ae0:	09 f0                	or     %esi,%eax
  801ae2:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801ae5:	f7 75 e4             	divl   -0x1c(%ebp)
  801ae8:	d3 e6                	shl    %cl,%esi
  801aea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801aed:	89 d6                	mov    %edx,%esi
  801aef:	f7 65 f4             	mull   -0xc(%ebp)
  801af2:	89 d7                	mov    %edx,%edi
  801af4:	89 c2                	mov    %eax,%edx
  801af6:	39 fe                	cmp    %edi,%esi
  801af8:	89 f9                	mov    %edi,%ecx
  801afa:	72 30                	jb     801b2c <__umoddi3+0x12c>
  801afc:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801aff:	72 27                	jb     801b28 <__umoddi3+0x128>
  801b01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801b04:	29 d0                	sub    %edx,%eax
  801b06:	19 ce                	sbb    %ecx,%esi
  801b08:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b0c:	89 f2                	mov    %esi,%edx
  801b0e:	d3 e8                	shr    %cl,%eax
  801b10:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b14:	d3 e2                	shl    %cl,%edx
  801b16:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b1a:	09 d0                	or     %edx,%eax
  801b1c:	89 f2                	mov    %esi,%edx
  801b1e:	d3 ea                	shr    %cl,%edx
  801b20:	83 c4 20             	add    $0x20,%esp
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    
  801b27:	90                   	nop
  801b28:	39 fe                	cmp    %edi,%esi
  801b2a:	75 d5                	jne    801b01 <__umoddi3+0x101>
  801b2c:	89 f9                	mov    %edi,%ecx
  801b2e:	89 c2                	mov    %eax,%edx
  801b30:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801b33:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801b36:	eb c9                	jmp    801b01 <__umoddi3+0x101>
  801b38:	39 f7                	cmp    %esi,%edi
  801b3a:	0f 82 10 ff ff ff    	jb     801a50 <__umoddi3+0x50>
  801b40:	e9 17 ff ff ff       	jmp    801a5c <__umoddi3+0x5c>
