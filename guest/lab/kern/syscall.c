#include<inc/syscall.h>
#include<inc/lib.h>
#include<inc/stdio.h>
#include"env.h"

//extern struct Env *curenv ;
static uint32_t VMM_ID; 

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
        int32_t ret;

        // Generic system call: pass system call number in AX,
        // up to five parameters in DX, CX, BX, DI, SI.
        // Interrupt kernel with T_SYSCALL.
        //
        // The "volatile" tells the assembler not to optimize
        // this instruction away just because we don't use the
        // return value.
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
                : "=a" (ret)
                //: "i" (VMM_SYSCALL),
                : "i" (T_SYSCALL),
                  "a" (num),
                  "d" (a1),
                  "c" (a2),
                  "b" (a3),
                  "D" (a4),
                  "S" (a5)
                : "cc", "memory");
//        if(check && ret > 0)
  //              panic("syscall %d returned %d (> 0)", num, ret);
        return ret;
}

void getEnvID(char* msg)
{
	//VMM_ID = curenv.env_id; 	
	cprintf("%s\n",msg);
	VMM_ID = -1;	
}

void
sys_cputs(const char *s, size_t len)
{
	getEnvID("sys_cputs() From Guest OS...");
        syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, VMM_ID);
}

int
sys_env_setup_vm(void *e )
{
	getEnvID("sys_env_setup() From Guest OS...");
	int r = syscall(SYS_env_setup_vm, 0, (uint32_t)e, 0, 0, 0, VMM_ID);
	return r;
}

int
sys_page_alloc(int i, struct Env* e, void* va, int perm)
{
	getEnvID("sys_page_alloc() From Guest OS...");
	int r = syscall(SYS_page_alloc, 0, i, (uint32_t)e, (uint32_t)va, perm, VMM_ID);
	return r;
}


int
sys_load_icode(void* e, void* b, int len)
{
	getEnvID("sys_load_icode() From Guest OS...");
	int r = syscall(SYS_load_icode, 0, (uint32_t)e, (uint32_t)b, len, 0, VMM_ID);
	return r;
}

int
sys_lcr3(uint32_t cr3)
{
	getEnvID("sys_lcr3() From Guest OS...");
	int r = syscall(SYS_lcr3, 0, cr3, 0, 0, 0, VMM_ID);
	return r;
}

int
sys_env_pop_tf(uint32_t e)
{
	getEnvID("sys_env_pop_tf() From Guest OS...");
	int r = syscall(SYS_run, 0, e, 0, 0, 0, VMM_ID);
	return r;
}
