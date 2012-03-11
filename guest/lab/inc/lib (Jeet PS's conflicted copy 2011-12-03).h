#ifndef VMM_INC_LIB_H
#define VMM_INC_LIB_H 1

#include<inc/x86.h>

void    sys_cputs(const char *string, uint32_t len);
int     sys_cgetc(void);
//int32_t syscall(uint32_t num, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5);
#define T_SYSCALL	0x30
#endif
