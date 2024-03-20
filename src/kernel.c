#include "kernel.h"
#include <stdint.h>

void kernel_main()
{
	uint16_t* video_mem = (uint16_t*)0xB8000;


	for(uint16_t i = 0; i < 26; i++)
	{
		video_mem[i] = i + 'A' + (uint16_t)(0xF << 8);
	}
}