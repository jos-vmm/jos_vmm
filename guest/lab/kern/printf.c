// Simple implementation of cprintf console output for the kernel,
// based on printfmt() and the kernel console's cputchar().

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>
#include <inc/lib.h>

struct printbuf {
        int idx;        // current buffer index
        int cnt;        // total bytes printed so far
        char buf[256];
};

static void
putch(int ch, void* b1)
{
	//cputchar(ch);
	//*cnt++;
	struct printbuf* b = (struct printbuf*) b1;
        b->buf[b->idx++] = ch;
        if (b->idx == 256-1) {
                sys_cputs(b->buf, b->idx);
                b->idx = 0;
        }
        b->cnt++;
}
/*
int
vcprintf(const char *fmt, va_list ap)
{
	int cnt = 0;

	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}
*/

int
vcprintf(const char *fmt, va_list ap)
{
        struct printbuf b;

        b.idx = 0;
        b.cnt = 0;
        vprintfmt((void*)putch, &b, fmt, ap);
        sys_cputs(b.buf, b.idx);

        return b.cnt;
}


int
cprintf(const char *fmt, ...)
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
	va_end(ap);

	return cnt;
}

