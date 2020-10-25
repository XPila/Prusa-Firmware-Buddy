// tmc2209.c

#include "tmc2209.h"
#include "cmsis_os.h"
#include "gpio.h"
#include <string.h>

#define TMC2209_TIMEOUT 100
/*
typedef struct _tmc2209_chip_t
{
	uint8_t id:8;                      // chip id
	union
	{
		struct
		{
			uint8_t f_initialized:1;   // chip is initialized
			uint8_t f_error:1;         // error
			uint8_t f_reserved:6;      // reserved
		};
		uint8_t flags:8;               // flags as 8 bit value
	};
	uint8_t ifcnt:8;                   // last ifcnt register value
	tmc2209_DRV_STATUS_t drv_status;   // cached drv_status register
	// cached write-only regiters
	tmc2209_SLAVECONF_t slaveconf;     // 0x03 W
	tmc2209_OTP_PROG_t otp_prog;       // 0x04 W
	tmc2209_IHOLD_IRUN_t ihold_irun;   // 0x10 W
	tmc2209_TPOWERDOWN_t tpowerdown;   // 0x11 W
	tmc2209_TPWMTHRS_t tpwmthrs;       // 0x13 W
	tmc2209_TCOOLTHRS_t tcoolthrs;     // 0x14 W
	tmc2209_VACTUAL_t vactual;         // 0x22 W
	tmc2209_SGTHRS_t sgthrs;           // 0x40 W
	tmc2209_COOLCONF_t coolconf;       // 0x42 W
} tmc2209_chip_t;
*/

UART_HandleTypeDef* tmc2209_phuart = 0;
volatile osThreadId tmc2209_thread_id = 0;
uint32_t tmc2209_signal = 0x00000002;
uint8_t tmc2209_ifcnt[4];
volatile uint8_t tmc2209_cnt = 0;
//tmc2209_chip_t tmc2209_chip[4];


void tmc2209_init(UART_HandleTypeDef* phuart)
{
	tmc2209_phuart = phuart;
}

uint8_t tmc2209_calc_crc(uint8_t* data, uint8_t size)
{
	int i,j;
	uint8_t crc = 0;
	uint8_t currentByte;
	for (i = 0; i < size; i++)
	{
		currentByte = data[i];
		for (j = 0; j < 8; j++)
		{
			if ((crc >> 7) ^ (currentByte & 0x01)) // update CRC based result of XOR operation
				crc = (crc << 1) ^ 0x07;
			else
				crc = (crc << 1);
			currentByte = currentByte >> 1;
		} // for CRC bit
	} // for message byte
	return crc;
}

tmc2209_err_t tmc2209_error(uint8_t id, tmc2209_err_t err)
{
	return err;
}

tmc2209_err_t tmc2209_rdreg(uint8_t id, tmc2209_reg_addr_t reg, uint32_t* pdata)
{
	osDelay(1);
	uint8_t request[4] = {0x05, id, reg, 0};
	uint8_t response[12] = {0,0,0,0,0,0,0,0,0,0,0,0};
	request[3] = tmc2209_calc_crc(request, 3);
	tmc2209_thread_id = osThreadGetId();
	tmc2209_cnt = 0;
	if (HAL_UART_Receive_DMA(tmc2209_phuart, response, 12) != HAL_OK)
		return tmc2209_error(id, TMC2209_ERR_HAL);
	if (HAL_UART_Transmit(tmc2209_phuart, request, 4, TMC2209_TIMEOUT) != HAL_OK)
	//if (HAL_UART_Transmit_DMA(tmc2209_phuart, request, 4) != HAL_OK)
	{
        HAL_UART_AbortReceive(tmc2209_phuart);
		return tmc2209_error(id, TMC2209_ERR_HAL);
	}
	osEvent event = osSignalWait(tmc2209_signal, TMC2209_TIMEOUT);
	//HAL_UART_AbortTransmit(tmc2209_phuart);
	if (event.status == osEventSignal)
	{
		if (memcmp(request, response, 4) != 0)
			return tmc2209_error(id, TMC2209_ERR_ECH);
		uint8_t crc = tmc2209_calc_crc(response + 4, 7);
		if (crc != response[4 + 7])
			return tmc2209_error(id, TMC2209_ERR_CRC);
		if (pdata)
			*pdata =
					(((uint32_t)response[4 + 3]) << 24) |
					(((uint32_t)response[4 + 4]) << 16) |
					(((uint32_t)response[4 + 5]) << 8) |
					((uint32_t)response[4 + 6]);
		return TMC2209_ERR_OK;
	}
    HAL_UART_AbortReceive(tmc2209_phuart);
	return tmc2209_error(id, TMC2209_ERR_TMO);
}

tmc2209_err_t tmc2209_wrreg(uint8_t id, tmc2209_reg_addr_t reg, uint32_t data)
{
	osDelay(1);
	uint8_t request[8] = {0x05, id, reg | 0x80, data >> 24, data >> 16, data >> 8, data, 0};
	uint8_t response[8] = {0,0,0,0,0,0,0,0};
	request[7] = tmc2209_calc_crc(request, 7);
	tmc2209_thread_id = osThreadGetId();
	tmc2209_cnt = 0;
	if (HAL_UART_Receive_DMA(tmc2209_phuart, response, 8) != HAL_OK)
		return tmc2209_error(id, TMC2209_ERR_HAL);
	if (HAL_UART_Transmit(tmc2209_phuart, request, 8, TMC2209_TIMEOUT) != HAL_OK)
	//if (HAL_UART_Transmit_DMA(tmc2209_phuart, request, 8) != HAL_OK)
	{
        HAL_UART_AbortReceive(tmc2209_phuart);
		return tmc2209_error(id, TMC2209_ERR_HAL);
	}
	osEvent event = osSignalWait(tmc2209_signal, TMC2209_TIMEOUT);
	//HAL_UART_AbortTransmit(tmc2209_phuart);
	if (event.status == osEventSignal)
	{
		if (memcmp(request, response, 8) != 0)
			return tmc2209_error(id, TMC2209_ERR_ECH);
		tmc2209_ifcnt[id]++;
		tmc2209_IFCNT_t ifcnt = {.ui32 = 0};
		tmc2209_err_t res = tmc2209_rdreg(id, TMC2209_REG_IFCNT, &ifcnt.ui32);
		if (res != TMC2209_ERR_OK)
			return res;
		if ((ifcnt.value != tmc2209_ifcnt[id]))
		{
			tmc2209_ifcnt[id] = ifcnt.value;
			return tmc2209_error(id, TMC2209_ERR_IFC);
		}
		return TMC2209_ERR_OK;
	}
    HAL_UART_AbortReceive(tmc2209_phuart);
	return tmc2209_error(id, TMC2209_ERR_TMO);
}

tmc2209_err_t tmc2209_init_slave(uint8_t id, const tmc2209_slave_config_t* pcfg)
{
	tmc2209_err_t res;
	tmc2209_IFCNT_t ifcnt;
	tmc2209_GCONF_t gconf = { .pdn_disable = 1, .mstep_reg_select = 1, .en_SpreadCycle = pcfg->en_SpreadCycle };
	tmc2209_CHOPCONF_t chopconf = { .toff = 3, .hstr = 5, .hend = 1, .tbl = 1, .vsense = pcfg->vsense, .mres = pcfg->mres, .intpol = pcfg->intpol };
	tmc2209_PWMCONF_t pwmconf = { .PWM_OFS = 36, .PWM_GRAD = 14, .pwm_freq = 1, .pwm_autoscale = 1, .pwm_autograd = 1, .PWM_REG = 8, .PWM_LIM = 12 };
	tmc2209_IHOLD_IRUN_t ihold_irun = { .IHOLD = pcfg->IHOLD_IRUN, .IRUN = pcfg->IHOLD_IRUN, .IHOLDDELAY = 1 };
	tmc2209_TPOWERDOWN_t tpowerdown = { .value = 128 };
	tmc2209_TCOOLTHRS_t tcoolthrs = { .value = pcfg->tcoolthrs };
	tmc2209_SGTHRS_t sgthrs = { .value = pcfg->sgthrs };
	tmc2209_GSTAT_t gstat = { .reset = 1, .drv_err = 1, .uv_cp = 1 };
	tmc2209_DRV_STATUS_t drv_status;
	if ((res = tmc2209_rdreg(id, TMC2209_REG_IFCNT, &ifcnt.ui32)) != TMC2209_ERR_OK) return res;
	tmc2209_ifcnt[id] = ifcnt.value;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_GCONF, gconf.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_GSTAT, gstat.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_CHOPCONF, chopconf.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_PWMCONF, pwmconf.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_IHOLD_IRUN, ihold_irun.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_TPOWERDOWN, tpowerdown.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_TCOOLTHRS, tcoolthrs.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_wrreg(id, TMC2209_REG_SGTHRS, sgthrs.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_rdreg(id, TMC2209_REG_GSTAT, &gstat.ui32)) != TMC2209_ERR_OK) return res;
	if ((res = tmc2209_rdreg(id, TMC2209_REG_DRV_STATUS, &drv_status.ui32)) != TMC2209_ERR_OK) return res;
	return TMC2209_ERR_OK;
}

void tmc2209_rxcplt_cb(void)
{
	if (tmc2209_thread_id)
	{
		tmc2209_cnt++;
		osSignalSet(tmc2209_thread_id, tmc2209_signal);
	}
}
