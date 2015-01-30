#import <sys/sysctl.h>
#import <sys/syscall.h>
#import <unistd.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>
#import <math.h>

#import "mem_info.h"

static unsigned long long
read_sysctl_int(const char* name)
{
	unsigned long long var;
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

static int
get_percent_free(unsigned int* level)
{
	int error;

	error = syscall(SYS_memorystatus_get_level, level);

	if( error ) {
		perror("memorystatus_get_level failed:");
		exit(-1);
	}
	return error;
}

@implementation MemInfo
+ (long long) getPageSize {
    return read_sysctl_int("hw.pagesize");
}

+ (int) getPagesFree {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    vm_statistics64_data_t vmstat;
    if(host_statistics64(mach_host_self(), HOST_VM_INFO64,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.\n");
    }

    return vmstat.free_count;
}

+ (int) getPagesInactive {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    vm_statistics64_data_t vmstat;
    if(host_statistics64(mach_host_self(), HOST_VM_INFO64,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.\n");
    }

    return vmstat.inactive_count;
}

+ (int) getPagesFileCache {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    vm_statistics64_data_t vmstat;
    if(host_statistics64(mach_host_self(), HOST_VM_INFO64,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.\n");
    }

    return vmstat.external_page_count;
}

+ (int) getPagesAppMemory {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    vm_statistics64_data_t vmstat;
    if(host_statistics64(mach_host_self(), HOST_VM_INFO64,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.\n");
    }

    return vmstat.internal_page_count;
}

+ (int) getPagesWired {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    vm_statistics64_data_t vmstat;
    if(host_statistics64(mach_host_self(), HOST_VM_INFO64,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.\n");
    }

    return vmstat.wire_count;
}

+ (int) getPagesCompressed {
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    vm_statistics64_data_t vmstat;
    if(host_statistics64(mach_host_self(), HOST_VM_INFO64,(host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf(stderr, "Failed to get VM statistics.\n");
    }

    return vmstat.compressor_page_count;
}

+ (long long) getMemoryPressure {
    return read_sysctl_int("kern.memorystatus_vm_pressure_level");
}

+ (long long) getTotalMemory {
    return read_sysctl_int("hw.memsize");
}

+ (long long) getMTMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if( kerr == KERN_SUCCESS ) {
        return info.resident_size;
    } else {
        NSLog(@"Error with task_info()");
        return -1;
    }
}

+ (NSString *) getOSVersion {
    char str[256];
    size_t size = sizeof(str);
    int ret = sysctlbyname("kern.osrelease", str, &size, NULL, 0);
    return [NSString stringWithUTF8String: str];
}

+ (int) getMemoryPressurePercent {
    unsigned int current_percent = 0;
    get_percent_free(&current_percent);
    return 100-current_percent;
}
@end