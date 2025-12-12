#include "pico/stdlib.h"
#include "pico/cyw43_arch.h"
#include "core.h" 

void PM_SetCorePointer(Protomatter_core *core);

void glue_launch_core1(void (*entry_point)(void));
void glue_fifo_push(uint32_t data);
uint32_t glue_fifo_pop(void);
bool glue_fifo_has_data(void);