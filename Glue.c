#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <malloc.h>
#include "core.h" 

Protomatter_core *_PM_protoPtr = NULL;

void PM_SetCorePointer(Protomatter_core *core) {
    _PM_protoPtr = core;
}

int posix_memalign(void **memptr, size_t alignment, size_t size) {
    void *ptr = memalign(alignment, size);
    if (!ptr) return 12; // ENOMEM
    *memptr = ptr;
    return 0;
}

uint32_t __atomic_load_4(volatile void *ptr, int model) {
    return *(volatile uint32_t *)ptr;
}

void __atomic_store_4(volatile void *ptr, uint32_t val, int model) {
    *(volatile uint32_t *)ptr = val;
}

uint32_t __atomic_fetch_add_4(volatile void *ptr, uint32_t val, int model) {
    uint32_t result = *(volatile uint32_t *)ptr;
    *(volatile uint32_t *)ptr = result + val;
    return result;
}

uint32_t __atomic_fetch_sub_4(volatile void *ptr, uint32_t val, int model) {
    uint32_t result = *(volatile uint32_t *)ptr;
    *(volatile uint32_t *)ptr = result - val;
    return result;
}

bool __atomic_compare_exchange_4(volatile void *ptr, void *expected, uint32_t desired, bool weak, int success_memorder, int failure_memorder) {
    uint32_t current = *(volatile uint32_t *)ptr;
    uint32_t exp_val = *(uint32_t *)expected;
    if (current == exp_val) {
        *(volatile uint32_t *)ptr = desired;
        return true;
    } else {
        *(uint32_t *)expected = current;
        return false;
    }
}