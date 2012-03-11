#ifndef VMM_INC_LIB_H
#define VMM_INC_LIB_H 1

#include<inc/x86.h>
#include<kern/env.h>


#define T_SYSCALL	0x30
#define VMM_SYSCALL	0x80
#define VMM_PGFAULT	14	

void    sys_cputs(const char* string, uint32_t len);
int     sys_cgetc(void);
int	sys_env_setup_vm(void*);
int	sys_page_alloc(int, struct Env*, void*, int);
int	sys_lcr3(uint32_t);
int	sys_load_icode(void*, void*, int);
int	sys_env_pop_tf(uint32_t);
#endif
