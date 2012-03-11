#include<inc/lib.h>
#include<kern/env.h>
#include<kern/console.h>
#include<inc/stdio.h>
#include<inc/elf.h>
#include<inc/string.h>

struct Env envs[32];                // All environments
struct Env *curenv = NULL;              // The current env
static struct Env_list env_free_list;   // Free list
int nenv = PGSIZE/sizeof(struct Env);

struct Trapframe user_tf;

int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
        struct Env *e;

        if (envid == 0) {
                *env_store = curenv;
                return 0;
        }
        e = &envs[envid];
        if (e->env_status == ENV_FREE || e->env_id != envid) {
                *env_store = 0;
                return -E_BAD_ENV;
        }
        if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
                *env_store = 0;
                return -E_BAD_ENV;
        }
        *env_store = e;
        return 0;
}

void
env_init(void)
{

        cprintf("\n in env_init in user\n");
	cprintf("inserting\n");
        int i;
//	sys_page_alloc(envs);
	cprintf("nenv: %d %x %x\n", nenv-1, envs, envs[1]);
        for(i=nenv-1;i>=0;i--)
        {
                envs[i].env_id = 0;
                LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
        }
	cprintf("calling allloc\n");
//	struct Env *e;
//	env_alloc(&e, 0);
}

//commented for testing
/*static void
Env_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{

        int i;
        for(i =0;i<(size/PGSIZE);i++)
        {
                pte_t *pte = pgdir_walk(pgdir, (void*)la, 1);
                if(pte == NULL)
                {
                        cprintf("could not allocate page table in Env_map_segment()!!\n");
                        return;
                }
                *pte = pa | PTE_P | perm;
                la+=PGSIZE;
                pa+=PGSIZE;
        }
}
*/

static int
env_setup_vm(struct Env *e)
{
/*	int i, r;
	struct Page *p = NULL;

	if ((r = page_alloc(&p)) < 0)
		return r;
	e->env_pgdir = page2kva(p);
	e->env_cr3 = page2pa(p);
	p->pp_ref++;*/
//	memset(e->env_pgdir, 0, PGSIZE);
	
//	Env_map_segment(e->env_pgdir, UPAGES, ROUNDUP(npage*sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U | PTE_P);
//	Env_map_segment(e->env_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
//	Env_map_segment(e->env_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P| PTE_W);
//	Env_map_segment(e->env_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_P| PTE_W);
	cprintf("kool");
	cprintf("passing %x to set up vm\n", e);
	sys_env_setup_vm(e);

//	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
//	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
	return 0;

}



int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
	int32_t generation;
	int r;
	struct Env *e;
	cprintf("list: %x\n", env_free_list);
	if (!(e = LIST_FIRST(&env_free_list)))
	{
		return -E_NO_FREE_ENV;
	}

	if ((r = env_setup_vm(e)) < 0)
		return r;

	generation = ((e->env_id) & ~(1024 - 1));
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1;
	e->env_id = generation | (e - envs);
	
	e->env_parent_id = parent_id;
	e->env_status = ENV_RUNNABLE;
	e->env_runs = 0;

	//memset(&e->env_tf, 0, sizeof(e->env_tf));

//	env_setup_trapframe(e);
/*	e->env_tf.tf_ds = GD_UD | 3;
	e->env_tf.tf_es = GD_UD | 3;
	e->env_tf.tf_ss = GD_UD | 3;
	e->env_tf.tf_esp = USTACKTOP;
	e->env_tf.tf_cs = GD_UT | 3;

	e->env_tf.tf_eflags |= FL_IF;
*/
	e->env_pgfault_upcall = 0;
	e->env_ipc_recving = 0;

	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf(" pgdir: %x out of envalloc\n", e->env_pgdir);
	return 0;
}

//TO BE PRESENT IN VMM
 
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
	for(i=0;i<numPages;i++)
	{
		sys_page_alloc(-1, e, start, PTE_P|PTE_U|PTE_W);
		start += PGSIZE;
	}

}


void
load_icode(struct Env *e, uint8_t *binary, size_t size)
{
	cprintf("in load icode\n");
	sys_load_icode((void*)e, (void*)binary, size);
/*	sys_lcr3(e->env_cr3);
	cprintf("returned from lcr3\n");
        struct Proghdr *ph, *eph;
        struct Elf *ELFHDR = (struct Elf *)binary;
	cprintf("magic: %x\n",ELFHDR->e_magic);
        if(ELFHDR->e_magic != ELF_MAGIC)
        {
                cprintf("Process Load Error: Not a valid elf");
		return;
        }
        ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
        eph = ph + ELFHDR->e_phnum;

        for (; ph < eph; ph++)
	{
		cprintf("%x\n", ph);
		if(ph->p_type == ELF_PROG_LOAD)
		{
			if(ph->p_type > ph->p_memsz)
			{
			    cprintf("\n Panic in loa_icode\n");
			    return;
			}
			segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memset((void *)ROUNDDOWN(ph->p_va, PGSIZE), 0, ROUNDUP(ph->p_va+ph->p_memsz, PGSIZE)-ROUNDDOWN(ph->p_va, PGSIZE));
			memmove((void *)ph->p_va, (void *)(binary+ph->p_offset), (size_t)ph->p_filesz);
		}
	}

	e->env_tf.tf_eip = ELFHDR->e_entry;
	segment_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);*/
}

void
print_regs(struct PushRegs *regs)
{
        cprintf("  edi  0x%08x\n", regs->reg_edi);
        cprintf("  esi  0x%08x\n", regs->reg_esi);
        cprintf("  ebp  0x%08x\n", regs->reg_ebp);
        cprintf("  oesp 0x%08x\n", regs->reg_oesp);
        cprintf("  ebx  0x%08x\n", regs->reg_ebx);
        cprintf("  edx  0x%08x\n", regs->reg_edx);
        cprintf("  ecx  0x%08x\n", regs->reg_ecx);
        cprintf("  eax  0x%08x\n", regs->reg_eax);
}

void
print_trapframe(struct Trapframe *tf)
{
        cprintf("TRAP frame at %p\n", tf);
        print_regs(&tf->tf_regs);
        cprintf("  es   0x----%04x\n", tf->tf_es);
        cprintf("  ds   0x----%04x\n", tf->tf_ds);
        cprintf("  trap 0x%08x\n", tf->tf_trapno);
        cprintf("  err  0x%08x\n", tf->tf_err);
        cprintf("  eip  0x%08x\n", tf->tf_eip);
        cprintf("  cs   0x----%04x\n", tf->tf_cs);
        cprintf("  flag 0x%08x\n", tf->tf_eflags);
        cprintf("  esp  0x%08x\n", tf->tf_esp);
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
}


void
env_create(uint8_t *binary, size_t size)
{
	cprintf("binary: %x %d\n", binary, size);
	struct Env *e;
	int retCode = env_alloc(&e, 0);
	cprintf("cr3: %x id: %x\n", e->env_cr3, e->env_id);
	if(retCode == -E_NO_FREE_ENV)
	{
		cprintf("Maximum numbers of processes are already running!!\n");
		return;
	}	
	if(retCode == -E_NO_MEM)
	{
		cprintf("Out Of Memory while creating environment!!");
		return;
	}	

	load_icode(e, binary, size); 
	print_trapframe(&e->env_tf);
	env_run(e);
}


/*
void
env_free(struct Env *e)
{
	pte_t *pt;
	uint32_t pdeno, pteno;
	physaddr_t pa;
	
	if (e == curenv)
		lcr3(boot_cr3);

	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		if (!(e->env_pgdir[pdeno] & PTE_P))
			continue;

		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	pa = e->env_cr3;
	e->env_pgdir = 0;
	e->env_cr3 = 0;
	page_decref(pa2page(pa));

	e->env_status = ENV_FREE;
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
}

void
env_destroy(struct Env *e) 
{
	cprintf("\nin env_destroy\n");
	env_free(e);

	if (curenv == e) {
		curenv = NULL;
		sched_yield();
	}
}
*/
/*
void
env_pop_tf(struct Trapframe *tf)
{
	asm volatile("movl %0,%%esp\n"
		"\tpopal\n"
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" skip tf_trapno and tf_errcode 
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");   mostly to placate the compiler
}

*/
void
env_run(struct Env *e)
{
/*	if(curenv != e)
	{	
		curenv = e;
		e->env_runs += 1;
		sys_lcr3(curenv->env_cr3);
	}
	return;*/
	curenv = e;
	cprintf("\n\n ***userKernel, env.c:337***** Guest Kernel to Guest User now, inside env_run().... \n\n");
	sys_env_pop_tf((uint32_t)e);

	// guest user process returned from vm monitor due to trap, runnig it again
	 //asm volatile("movl %0,%%esp\n"
	asm volatile (" call get_userTrapframe\n":::"memory");
	cprintf("\n\n ******** The HACK BEGINS..... guest kernel, inside env_run().... \n\n");
	print_trapframe(&user_tf);
	
/*
	 asm volatile("popal\n"
                "\tpopl %%es\n"
                "\tpopl %%ds\n"
                "\taddl $0x8,%%esp\n" //skip tf_trapno and tf_errcode 
                "\tiret"
                : : "g" (&tf) : "memory");
*/		
	curenv->env_tf = user_tf;
	env_run(curenv);	
	
}

void get_userTrapframe(struct Trapframe* tf)
{
	user_tf = *tf;
}
