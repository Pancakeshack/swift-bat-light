/*!
 * @file rp2040.h
 *
 * Part of Adafruit's Protomatter library for HUB75-style RGB LED matrices.
 * This file contains RP2040 (Raspberry Pi Pico, etc.) SPECIFIC CODE.
 *
 * MODIFIED FOR RAW C SDK USE (No Arduino/CircuitPython dependencies)
 */

#pragma once

#include "hardware/pwm.h"
#include "hardware/irq.h"
#include "hardware/timer.h"
#include "hardware/gpio.h"
#include "hardware/structs/sio.h"
#include "pico/stdlib.h"

// RP2040 only allows full 32-bit aligned writes to GPIO.
#define _PM_STRICT_32BIT_IO 1

// Use PWM for bitplane timing (standard for Protomatter on RP2040)
#define _PM_CLOCK_PWM 1

// Forward declarations
static void _PM_PWM_ISR(void);

// -------------------------------------------------------------------------
// 1. PIN MACROS (Mapping Protomatter macros to Pico SDK functions)
// -------------------------------------------------------------------------

// 'pin' here is the GP number (0-29)

// Helper to determine byte/word offsets for 32-bit SIO writes
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define _PM_byteOffset(pin) ((pin & 31) / 8)
#define _PM_wordOffset(pin) ((pin & 31) / 16)
#else
#define _PM_byteOffset(pin) (3 - ((pin & 31) / 8))
#define _PM_wordOffset(pin) (1 - ((pin & 31) / 16))
#endif

// GPIO Access Macros
#define _PM_portBitMask(pin) (1UL << pin)

#define _PM_pinOutput(pin)       \
  {                              \
    gpio_init(pin);              \
    gpio_set_dir(pin, GPIO_OUT); \
  }

#define _PM_pinInput(pin)       \
  {                             \
    gpio_init(pin);             \
    gpio_set_dir(pin, GPIO_IN); \
  }

#define _PM_pinLow(pin) gpio_clr_mask(1UL << pin)
#define _PM_pinHigh(pin) gpio_set_mask(1UL << pin)

#define _PM_portOutRegister(pin) ((void *)&sio_hw->gpio_out)
#define _PM_portSetRegister(pin) ((volatile uint32_t *)&sio_hw->gpio_set)
#define _PM_portClearRegister(pin) ((volatile uint32_t *)&sio_hw->gpio_clr)
#define _PM_portToggleRegister(pin) ((volatile uint32_t *)&sio_hw->gpio_togl)

// Delay macro
#ifndef _PM_delayMicroseconds
#define _PM_delayMicroseconds(n) sleep_us(n)
#endif

// -------------------------------------------------------------------------
// 2. TIMER / PWM IMPLEMENTATION
// -------------------------------------------------------------------------

// In the raw SDK, we don't have a specific "timer object" passed in from Arduino.
// We will store the PWM slice index in the core struct's timer void pointer.
// We'll use a hardcoded divisor to get ~41.6 MHz clock for the timer.
#define _PM_PWM_DIV 3.0f
#define _PM_timerFreq (125000000 / 3)

// Global pointer to core (needed for ISR)
// Note: In strict C builds, this variable might be defined in core.c or cpp wrapper.
// core.c usually expects an extern Protomatter_core *_PM_protoPtr;
// We will declare it here to satisfy the ISR.
extern Protomatter_core *_PM_protoPtr;

static int _PM_pwm_slice_num = 0;

// Initialize, but do not start, timer.
// The 'timer' argument in _PM_init can be NULL, in which case we default to slice 0
void _PM_timerInit(Protomatter_core *core)
{
  // If core->timer is NULL, we pick a safe default (Slice 0)
  // If you need a specific slice, pass (void*)slice_num to _PM_init
  if (core->timer)
  {
    _PM_pwm_slice_num = (int)core->timer;
  }
  else
  {
    _PM_pwm_slice_num = 0;
    // Warning: Slice 0 uses GP0/GP1. If your matrix uses GP0/1,
    // you should use a different slice!
    // But Protomatter usually just uses the PWM hardware *timer*, not the pin output.
    // It sets the interrupt, not the pin.
  }

  // Config PWM
  pwm_config config = pwm_get_default_config();
  pwm_config_set_clkdiv(&config, _PM_PWM_DIV);
  pwm_init(_PM_pwm_slice_num, &config, false); // false = don't start yet

  // Setup Interrupts
  pwm_clear_irq(_PM_pwm_slice_num);
  pwm_set_irq_enabled(_PM_pwm_slice_num, true);

  irq_set_exclusive_handler(PWM_IRQ_WRAP, _PM_PWM_ISR);
  irq_set_enabled(PWM_IRQ_WRAP, true);
}

// Start (or restart) the timer with a specific period
inline void _PM_timerStart(Protomatter_core *core, uint32_t period)
{
  pwm_set_counter(_PM_pwm_slice_num, 0);
  pwm_set_wrap(_PM_pwm_slice_num, period);
  pwm_set_enabled(_PM_pwm_slice_num, true);
}

// Get current count
inline uint32_t _PM_timerGetCount(Protomatter_core *core)
{
  return pwm_get_counter(_PM_pwm_slice_num);
}

// Stop timer and return count
uint32_t _PM_timerStop(Protomatter_core *core)
{
  pwm_set_enabled(_PM_pwm_slice_num, false);
  return pwm_get_counter(_PM_pwm_slice_num);
}

// The Interrupt Service Routine
static void _PM_PWM_ISR(void)
{
  pwm_clear_irq(_PM_pwm_slice_num);
  if (_PM_protoPtr)
  {
    _PM_row_handler(_PM_protoPtr); // Function in core.c
  }
}

// -------------------------------------------------------------------------
// 3. MISC SETTINGS
// -------------------------------------------------------------------------

// CPU speed dependent NOPs to slow down writes if the Pico is too fast for the matrix
#define _PM_clockHoldLow asm("nop; nop; nop;");
#define _PM_clockHoldHigh asm("nop; nop; nop;");

#define _PM_chunkSize 8
#define _PM_minMinPeriod 100