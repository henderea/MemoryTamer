#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <sys/syscall.h>
#include <sys/sysctl.h>
#include <unistd.h>
#include <sys/mman.h>

#define MAX_RANGE_SIZE	64 * 1024 * 1024 * 1024ULL

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

int main (int argc, char * argv[]) {
	unsigned long i, len, size, phys_mem, start_ind;
	unsigned int current_percent = 0;
	unsigned int current_level = 1;
	start_ind = 0;
	phys_mem   = read_sysctl_int("hw.physmem");

	unsigned int target = argc >= 2 ? atoi(argv[1]) : 4;
	if(target != 2 && target != 4) {
		return 1;
	}
	unsigned int target_percent = target == 4 ? 30 : 60;
	unsigned int target_percent_diff;
	get_percent_free(&current_percent);
	current_level =  read_sysctl_int("kern.memorystatus_vm_pressure_level");
	if(target <= current_level) {
		return 0;
	}


	char *str = "ffd8ffe000104a46494600010101002400240000ffe100744578696600004d4d002a000000080004011a0005000000010000003e011b0005000000010000004601280003000000010002000087690004000000010000004e00000000000000240000000100000024000000010002a002000400000001000003c0a003000400000001000001ff00000000ffdb00430002020202020102020202020202030306040303030307050504060807080808070808090a0d0b09090c0a08080b0f0b0c0d0e0e0e0e090b10110f0e110d0e0e0effdb004301020202030303060404060e0908090e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0effc000110801ff03c003012200021101031101ffc4001f0000010501010101010100000000000000000102030405060708090a0bffc400b5100002010303020403050504040000017d01020300041105122131410613516107227114328191a1082342b1c11552d1f02433627282090a161718191a25262728292a3435363738393a434445464748494a535455565758595a636465666768696a737475767778797a838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae1e2e3e4e5e6e7e8e9eaf1f2f3f4f5f6f7f8f9faffc4001f0100030101010101010101010000000000000102030405060708090a0bffc400b51100020102040403040705040400010277000102031104052131061241510761711322328108144291a1b1c109233352f0156272d10a162434e125f11718191a262728292a35363738393a434445464748494a535455565758595a636465666768696a737475767778797a82838485868788898a92939495969798999aa2a3a4a5a6a7a8a9aab2b3b4b5b6b7b8b9bac2c3c4c5c6c7c8c9cad2d3d4d5d6d7d8d9dae2e3e4e5e6e7e8e9eaf2f3f4f5f6f7f8f9faffda000c03010002110311003f00f9e74fbd37baa2db99e6506391f28371f9519ba67fd9fcabd46cbc1315de8d6776752d7419e049084b152a37283c1dfc8e6bc02db4af18d9df79c9e1bd59a40ae9b65b1761f32953c63ae09c7a1c57656fe24f8896da7c16c9e0bb3748a358d5a4d04b31006324f73c75a00935f7fec9f165ee98b7372e2ddc05795763f2a0f20138ebeb590bac3e70d2b6e1fed1ac6d4ecbc65aa6b973a85c7867528a6998168edec1a38c1c01c2f61c550fec1f16ff00d0bdade4f5ff00447ff0a00eaffb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe668fed76ff9eaff0099ae57fb07c5bff42f6b7ff808ff00e147f60f8b7fe85ed6ff00f011ff00c2803aafed76ff009eaff99a3fb5dbfe7abfe66b95fec1f16ffd0bdadffe023ff851fd83e2dffa17b5bffc047ff0a00eabfb5dbfe7abfe668fed76ff009eaff99ae57fb07c5bff0042f6b7ff00808ffe147f60f8b7fe85ed6fff00011ffc2803aafed76ff9eaff0099a3fb5dbfe7abfe66b95fec1f16ff00d0bdadff00e023ff00851fd83e2dff00a17b5bff00c047ff000a00eabfb5dbfe7abfe66b4f45fed1f1078bb4cd0f4bdf3ea37f7296f6d1ee3f33b1c0cfb7a9f4ae0bfb07c5bff42f6b7ff808ff00e15a9a1c5e3bf0f78c74bd774cd0f5a8751d3ee52e2ddcd9be03a9c8cfb7623d2803d5bc6fe0df11780e0d3ae354bab1bdb1bd678e1bab1b8f36312c6079b112380cac4ae3b9535e7ffdaedff3d5ff00335b3e3af177c4af1f5be9b6da8f8567d36c2c59e486d74fd35e28ccb260c92b003966605b3db71af3cfec1f16ff00d0bdadff00e023ff0085007acf83743d57c6baddd59e9d7062fb3c68d248519c0324ab120c2f3cb38c9ec013dab95b8d427b5bfb8b59a4759a195a3917278652411f98ad9f86fe30f88bf0cb57d56f348f095f5ebdfc2914ab716b200a118918c0ff0068d709a9d878cb55f12ea3aa4fe1cd6127bdba92e2455b47c06772c40e3a64d007d13f09fe1d37c41d135ad7b52d52ef4fd074eba86cff00d1537cd7171310123504e0751927d6be8ed17f65bf0aebde19b4d5ac7c5fe2236b700eddf12060558ab03ee1948fc2be41f84bf123e20fc2d1acd87fc20d77e24f0eeabb1af74cbcb4902974fbb22b0190c3fa0f4afa1748fdad3c51a1691fd9fa57c10b8b4b212bc8b0ac931542c7240c8e067271ef401e9bff000c89a07fd0dbafff00dfb4a3fe191340ff00a1b75fff00bf695c2ffc366f8e7fe88c5cff00df72ff00851ff0d9be39ff00a23173ff007dcbfe1401dd7fc322681ff436ebff00f7ed28ff008644d03fe86dd7ff00efda570bff000d9be39ffa23173ff7dcbfe147fc366f8e7fe88c5cff00df72ff008500775ff0c89a07fd0dbaff00fdfb4a3fe191340ffa1b75ff00fbf695c2ff00c366f8e7fe88c5cffdf72ff851ff000d9be39ffa23173ff7dcbfe1401dd7fc322681ff00436ebfff007ed2be52f8d1f0eeff00e11fc42b2d325d49f51d3afedccf637046d6215b6b2b0f5071f98af733fb6678eb071f062e73fefcbfe15f2a7c5af1cfc4bf8bff001262d7758f0bea76515bc1f67b1b1b7b490a4099c9edcb13c93f4a00fe891bc2fe1c672cda1e96589c92";

	len = strlen(str)+1;
	char* mem = NULL;
	char *addr = NULL;
	mem = mmap(NULL, MAX_RANGE_SIZE, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, 0, 0);

	if (mem == MAP_FAILED) {
		perror("mmap failed");
	} else {
		while(current_level < target && start_ind < MAX_RANGE_SIZE) {
			if(current_percent > target_percent) {
				target_percent_diff = current_percent - target_percent;
			} else {
				target_percent_diff = 5;
			}
			size = (target_percent_diff * phys_mem) / (100 * PAGE_SIZE);
			for (i=0; i < size && (start_ind + (i + 1) * PAGE_SIZE) < MAX_RANGE_SIZE && current_level < target; i++) {
				memcpy(mem + start_ind + (i * PAGE_SIZE), str, PAGE_SIZE);
				get_percent_free(&current_percent);
				current_level =  read_sysctl_int("kern.memorystatus_vm_pressure_level");
			}
			if(current_level >= target) {
				break;
			}
			start_ind += size * PAGE_SIZE;
			addr = mem;
			while(addr < (mem + start_ind)) {
				char p;
				p = *(char *)addr;
				addr += PAGE_SIZE;
			}
			get_percent_free(&current_percent);
			current_level =  read_sysctl_int("kern.memorystatus_vm_pressure_level");
		}
		
		// free it up. 
		munmap(mem, MAX_RANGE_SIZE);
	}
    return 0;
}
