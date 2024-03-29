/******************************************************************************
 * The MIT License
 *
 * Copyright (c) 2010 Perry Hung.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *****************************************************************************/

/**
 * @brief System timer interrupt handler and initialization routines
 */

#include "systick.h"

#define SYSTICK_USE_CALLBACK /* Improve efficiency in __exc_systick */

static volatile uint32 systick_uptime_millis;
#ifdef SYSTICK_USE_CALLBACK
static void (*systick_user_callback)(void);
#endif

/**
 * @brief Initialize and enable SysTick.
 *
 * Clocks the system timer with the core clock, turns it on, and
 * enables interrupts.
 *
 * @param reload_val Appropriate reload counter to tick every 1 ms.
 */
void systick_init(uint32 reload_val) {
    SYSTICK_BASE->RVR = reload_val;
#ifdef SYSTICK_USE_CALLBACK
    /* make sure the systick callback has been attached */
    ASSERT(systick_user_callback != NULL);
#endif
    systick_enable();
}

/**
 * Clock the system timer with the core clock, but don't turn it
 * on or enable interrupt.
 */
void systick_disable(void) {
    SYSTICK_BASE->CSR = SYSTICK_CSR_CLKSOURCE_CORE;
}

/**
 * Clock the system timer with the core clock and turn it on;
 * interrupt every 1 ms, for systick_timer_millis.
 */
void systick_enable(void) {
    /* re-enables init registers without changing reload val */
    SYSTICK_BASE->CSR = (SYSTICK_CSR_CLKSOURCE_CORE   |
                         SYSTICK_CSR_ENABLE           |
                         SYSTICK_CSR_TICKINT_PEND);
}

/**
 * @brief Returns the system uptime, in milliseconds.
 */
uint32 systick_uptime(void) {
    return systick_uptime_millis;
}

/**
 * @brief Attach a callback to be called from the SysTick exception handler.
 *
 * To detach a callback, call this function again with a null argument.
 */
void systick_attach_callback(void (*callback)(void)) {
#ifdef SYSTICK_USE_CALLBACK
    systick_user_callback = callback;
#endif
}

/*
 * SysTick ISR
 */

void __exc_systick(void) {
    systick_uptime_millis++;
#ifdef SYSTICK_USE_CALLBACK
    systick_user_callback();
#endif
}
