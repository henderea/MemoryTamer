#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <getopt.h>
#include <string.h>
#include <mach/i386/vm_param.h>
#include <sys/kern_memorystatus.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/task.h>
#include <mach/thread_act.h>
#include <mach/thread_policy.h>
#include <sys/mman.h>
#include <pthread.h>
#include <assert.h>
#include <dispatch/private.h>

static unsigned int
read_sysctl_int(const char* name) 
{
    unsigned int var;
    size_t var_size;
    int error;

    var_size = sizeof(var);
    error = sysctlbyname(name, &var, &var_size, NULL, 0);
    if(error)
    {
        perror(name);
        exit(-1);
    }
    return var;
}

static int
get_percent_free(unsigned int* level) 
{
    int error;

    error = memorystatus_get_level((user_addr_t) level);

    if(error)
    {
        perror("memorystatus_get_level failed:");
        exit(-1);
    }
    return error;
}

int main (int argc, char * argv[])
{
    if(argc < 2)
    {
        fprintf(stderr, "%s\n", "You must specify a level");
        exit(-1);
    }

    int target_level, target_percent, current_percent, phys_mem, phys_pages;

    target_level = atoi(argv[1]);

    if(target_level == 2)
    {
        target_percent = 60;
    }
    else if(target_level == 4)
    {
        target_percent = 30;
    }
    else
    {
        fprintf(stderr, "%d%s\n", target_level, " is not a valid level");
        exit(-1);
    }

    phys_mem   = read_sysctl_int("hw.physmem");
    phys_pages = (unsigned int) (phys_mem / PAGE_SIZE);

    get_percent_free(&current_percent);

    
}