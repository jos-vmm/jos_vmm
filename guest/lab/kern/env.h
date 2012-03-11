/* See COPYRIGHT for copyright information. */
#include<kern/queue.h>
#include<inc/types.h>
#include<inc/memlayout.h>
#include<inc/error.h>

#ifndef JOS_KERN_ENV_H
#define JOS_KERN_ENV_H

#ifndef JOS_MULTIENV
// Change this value to 1 once you're allowing multiple environments
// (for UCLA: Lab 3, Part 3; for MIT: Lab 4).
#define JOS_MULTIENV 0
#endif


#define NENV	1024;
typedef int32_t envid_t;

LIST_HEAD(Env_list, Env);		// Declares 'struct Env_list'

#define ENV_FREE		0
#define ENV_RUNNABLE		1
#define ENV_NOT_RUNNABLE	2

struct PushRegs {
        /* registers as pushed by pusha */
        uint32_t reg_edi;
        uint32_t reg_esi;
        uint32_t reg_ebp;
        uint32_t reg_oesp;              /* Useless */
        uint32_t reg_ebx;
        uint32_t reg_edx;
        uint32_t reg_ecx;
        uint32_t reg_eax;
} __attribute__((packed));


struct Trapframe {
        struct PushRegs tf_regs;
        uint16_t tf_es;
        uint16_t tf_padding1;
        uint16_t tf_ds;
        uint16_t tf_padding2;
        uint32_t tf_trapno;
        /* below here defined by x86 hardware */
        uint32_t tf_err;
        uintptr_t tf_eip;
        uint16_t tf_cs;
        uint16_t tf_padding3;
        uint32_t tf_eflags;
        /* below here only when crossing rings, such as from user to kernel */
        uintptr_t tf_esp;
        uint16_t tf_ss;
        uint16_t tf_padding4;
} __attribute__((packed));

struct Env {
	struct Trapframe env_tf;	// Saved registers
	LIST_ENTRY(Env) env_link;	// Free list link pointers
	envid_t env_id;			// Unique environment identifier
	envid_t env_parent_id;		// env_id of this env's parent
	unsigned env_status;		// Status of the environment
	uint32_t env_runs;		// Number of times environment has run

	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir
	physaddr_t env_cr3;		// Physical address of page dir

	// Exception handling
	void *env_pgfault_upcall;	// page fault upcall entry point

	// Lab 4 IPC
	bool env_ipc_recving;		// env is blocked receiving
	void *env_ipc_dstva;		// va at which to map received page
	uint32_t env_ipc_value;		// data value sent to us 
	envid_t env_ipc_from;		// envid of the sender	
	int env_ipc_perm;		// perm of page mapping received
};

void	env_init(void);
int	env_alloc(struct Env **e, envid_t parent_id);
void	env_free(struct Env *e);
void	env_create(uint8_t *binary, size_t size);
void	env_destroy(struct Env *e);	// Does not return if e == curenv

int	envid2env(envid_t envid, struct Env **env_store, bool checkperm);
// The following two functions do not return
//void	env_run(struct Env *e) __attribute__((noreturn));
void	env_run(struct Env *e);
void	env_pop_tf(struct Trapframe *tf) __attribute__((noreturn));

// For the grading script
#define ENV_CREATE2(start, size)	{		\
	extern uint8_t start[], size[];			\
	env_create(start, (int)size);			\
}

#define ENV_CREATE(x)			{		\
	extern uint8_t _binary_##x##_start[],	\
		_binary_##x##_size[];		\
	env_create(_binary_##x##_start,		\
		(int)_binary_##x##_size);		\
}

#endif // !JOS_KERN_ENV_H
