#ifndef VMM_INC_SYSCALL_H
#define VMM_INC_SYSCALL_H

/* system call numbers */
enum
{
        SYS_cputs = 0,
        SYS_env_setup_vm,
        SYS_page_alloc,
	SYS_lcr3,
	SYS_load_icode,	
	SYS_run,
	SYS_envs_alloc,	
        SYS_getenvid,
        SYS_env_destroy,
        SYS_page_map,
        SYS_page_unmap,
        SYS_exofork,
        SYS_env_set_status,
        SYS_env_set_trapframe,
        SYS_env_set_pgfault_upcall,
        SYS_yield,
        SYS_ipc_try_send,
        SYS_ipc_recv,
        NSYSCALLS
};

#endif /* !VMM_INC_SYSCALL_H */
