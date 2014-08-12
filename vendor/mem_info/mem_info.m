#import "mem_info.h"

static unsigned int
read_sysctl_int(const char* name)
{
	unsigned int var;
	size_t var_size;
	int error;

	var_size = sizeof(var);
	error = sysctlbyname(name, &var, &var_size, NULL, 0);
	if( error ) {
		perror(name);
		exit(-1);
	}
	return var;
}

@implementation MemInfo
+ (int) getPageSize {
    return read_sysctl_int("hw.pagesize");
}

+ (int) getPagesFree {
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;

    vm_statistics_data_t vmstat;
    if(host_statistics(mach_host_self(), HOST_VM_INFO,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.");
    }

    return vmstat.free_count;
}

+ (int) getPagesInactive {
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;

    vm_statistics_data_t vmstat;
    if(host_statistics(mach_host_self(), HOST_VM_INFO,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.");
    }

    return vmstat.inactive_count;
}

+ (int) getMemoryPressure {
    return read_sysctl_int("kern.memorystatus_vm_pressure_level");
}

+ (int) getTotalMemory {
    return read_sysctl_int("hw.memsize");
}

+ (long long) getMTMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if( kerr == KERN_SUCCESS ) {
        //NSLog(@"rs: %lld ; vs: %lld", (long long)info.resident_size, (long long)info.virtual_size);
        return info.resident_size;
    } else {
        NSLog(@"Error with task_info()");
        return -1;
    }
}
@end