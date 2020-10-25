//tmc2209.h
#ifndef _TMC2209_H
#define _TMC2209_H

#include <inttypes.h>
#include "stm32f4xx_hal.h"
#include "tmc2209_regs.h"


typedef enum _tmc2209_err_t
{
	TMC2209_ERR_OK  =  0,       // success
	TMC2209_ERR_NIN = -1,       // not initialized
	TMC2209_ERR_HAL = -2,       // HAL result error
	TMC2209_ERR_TMO = -3,       // timeout error
	TMC2209_ERR_ECH = -4,       // echo error
	TMC2209_ERR_CRC = -5,       // crc error
	TMC2209_ERR_IFC = -6,       // ifcnt error
} tmc2209_err_t;


typedef struct _tmc2209_slave_config_t
{
	uint8_t mres:4;             // byte 0, bit 0-3            CHOPCONF
	uint8_t intpol:1;           // byte 0, bit 4              CHOPCONF
	uint8_t vsense:1;           // byte 0, bit 5              CHOPCONF
	uint8_t en_SpreadCycle:1;   // byte 0, bit 6              GCONF
	uint8_t :1;                 // byte 0, bit 7
	uint8_t IHOLD_IRUN:5;       // byte 1, bit 0-4            IHOLD_IRUN
	uint8_t :3;                 // byte 1, bit 5-7
	uint32_t tcoolthrs:20;      // byte 2-3; byte 4, bit 0-3  TCOOLTHRS
	uint8_t :4;                 // byte 4, bit 4-7
	uint8_t sgthrs:8;           // byte 5, bit 0-7            SGTHRS
} tmc2209_slave_config_t;


#ifdef __cplusplus
extern "C" {
#endif //__cplusplus


//
extern void tmc2209_init(UART_HandleTypeDef* phuart);

// regiter read function
extern tmc2209_err_t tmc2209_rdreg(uint8_t id, tmc2209_reg_addr_t reg, uint32_t* pdata);

// regiter write function
extern tmc2209_err_t tmc2209_wrreg(uint8_t id, tmc2209_reg_addr_t reg, uint32_t data);

// slave init function
extern tmc2209_err_t tmc2209_init_slave(uint8_t id, const tmc2209_slave_config_t* pcfg);


// rx complete callback (called from main.c, HAL_UART_RxCpltCallback)
extern void tmc2209_rxcplt_cb(void);


#ifdef __cplusplus
}
#endif //__cplusplus


#endif //_TMC2209_H
