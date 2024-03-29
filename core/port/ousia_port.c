/* *****************************************************************************
 * @file    platform/stm32/port/ousia_port.c
 *
 * @brief   ousia system utilities
 *
 * @log     2011-08-14 Initial revision
 *
 * *****************************************************************************
 * COPYRIGHT (C) LEAFGRASS - Librae (g.leafgrass@gmail.com)
 *
 * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
 * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 * ****************************************************************************/

#include <stm32/libmaple/systick.h>
#include <stm32/stm32utils/stm32utils.h>
#include <port/ousia_port.h>

static uint32 critical_nest;

static void __systick_register_callback(void (*callback)(void));
static void __port_systick_handler(void);

/*
 * @brief   porting related init
 * @param   none
 * @return  none
 * @note    none
 */
void _os_port_init(void)
{
    __systick_register_callback(&__port_systick_handler);
}

/*
 * @brief   enter critical
 * @param   none
 * @return  none
 * @note    none
 */
void _os_enter_critical(void)
{
    OS_DISABLE_INTERRUPTS();
    critical_nest++;
}

/*
 * @brief   exit critical
 * @param   none
 * @return  none
 * @note    none
 */
void _os_exit_critical(void)
{
    critical_nest--;
    if (critical_nest == 0)
    {
        OS_ENABLE_INTERRUPTS();
    }
}

/*
 * @brief   band printf callback to low-level io control
 * @param   stdout_putp -i/o- generally none
 *          stdout_putf -i/o- low-level printf specific io implementation
 * @return  none
 * @note    none
 */
void _port_init_printf(void **stdout_putp, void (**stdout_putf)(void *dev, char ch))
{
    *stdout_putp = NULL;
    *stdout_putf = stm32utils_io_putc;
}

/*
 * @brief   register callback function of system tick handler
 * @param   pointer to callback function
 * @return  none
 * @note    WARNING if libmaple for stm32 is used, this function must be called
 */
static void __systick_register_callback(void (*callback)(void))
{
    systick_attach_callback(callback);
}

/*
 * @brief   systick timer interrupt user handler
 * @param   none
 * @return  none
 * @note    none
 */
static void __port_systick_handler(void)
{
    return;
}

