//tmc2209_regs.h
#ifndef _TMC2209_REGS_H
#define _TMC2209_REGS_H

#include <inttypes.h>


// enumeration of all tmc2209 register addresses
typedef enum _tmc2209_reg_addr_t
{
	TMC2209_REG_GCONF       = 0x00,  // RW
	TMC2209_REG_GSTAT       = 0x01,  // R+WC
	TMC2209_REG_IFCNT       = 0x02,  // R
	TMC2209_REG_SLAVECONF   = 0x03,  // W
	TMC2209_REG_OTP_PROG    = 0x04,  // W
	TMC2209_REG_OTP_READ    = 0x05,  // R
	TMC2209_REG_IOIN        = 0x06,  // R
	TMC2209_REG_FACTORY_CONF= 0x07,  // RW
	TMC2209_REG_IHOLD_IRUN  = 0x10,  // W
	TMC2209_REG_TPOWERDOWN  = 0x11,  // W
	TMC2209_REG_TSTEP       = 0x12,  // R
	TMC2209_REG_TPWMTHRS    = 0x13,  // W
	TMC2209_REG_TCOOLTHRS   = 0x14,  // W
	TMC2209_REG_VACTUAL     = 0x22,  // W
	TMC2209_REG_SGTHRS      = 0x40,  // W
	TMC2209_REG_SG_RESULT   = 0x41,  // R
	TMC2209_REG_COOLCONF    = 0x42,  // W
	TMC2209_REG_MSCNT       = 0x6a,  // R
	TMC2209_REG_MSCURACT    = 0x6b,  // R
	TMC2209_REG_CHOPCONF    = 0x6c,  // RW
	TMC2209_REG_DRV_STATUS  = 0x6f,  // R
	TMC2209_REG_PWMCONF     = 0x70,  // RW
	TMC2209_REG_PWM_SCALE   = 0x71,  // R
	TMC2209_REG_PWM_AUTO    = 0x72,  // R
} tmc2209_reg_addr_t;


//------------------------------------------------------------------------------
// TMC2209 register structures (litle-endian)

// 0x00 RW GCONF
typedef union _tmc2209_GCONF_t
{
	struct
	{
		uint8_t I_scale_analog:1;   // bit 0
		uint8_t internal_Rsense:1;  // bit 1
		uint8_t en_SpreadCycle:1;   // bit 2
		uint8_t shaft:1;            // bit 3
		uint8_t index_otpw:1;       // bit 4
		uint8_t index_step:1;       // bit 5
		uint8_t pdn_disable:1;      // bit 6
		uint8_t mstep_reg_select:1; // bit 7
		uint8_t multistep_filt:1;   // bit 8
		uint8_t test_mode:1;        // bit 9
		uint32_t unused_10_31:22;   // bit 10-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_GCONF_t;

// 0x01 R+WC GSTAT
typedef union _tmc2209_GSTAT_t
{
	struct
	{
		uint8_t reset:1;            // bit 0
		uint8_t drv_err:1;          // bit 1
		uint8_t uv_cp:1;            // bit 2
		uint32_t unused_3_31:29;    // bit 3-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_GSTAT_t;

// 0x02 R IFCNT
typedef union _tmc2209_IFCNT_t
{
	struct
	{
		uint8_t value:8;            // bit 0-7
		uint32_t unused_8_31:24;    // bit 8-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_IFCNT_t;

// 0x03 W SLAVECONF
typedef union _tmc2209_SLAVECONF_t
{
	struct
	{
		uint8_t unused_0_7:8;       // bit 0-7
		uint8_t SENDDELAY:4;        // bit 8-11
		uint32_t unused_12_31:20;   // bit 12-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_SLAVECONF_t;

// 0x04 W OTP_PROG
typedef union _tmc2209_OTP_PROG_t
{
	struct
	{
		uint8_t OTPBIT:3;           // bit 0-2
		uint8_t unused_3:1;         // bit 3
		uint8_t OTPBYTE:2;          // bit 4-5
		uint8_t unused_6_7:2;       // bit 6-7
		uint8_t OTPMAGIC:8;         // bit 8-15
		uint16_t unused_16_31:16;   // bit 16-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_OTP_PROG_t;

// 0x05 R OTP_READ
typedef union _tmc2209_OTP_READ_t
{
	struct
	{
		uint8_t OTP0:8;             // bit 0-7
		uint8_t OTP1:8;             // bit 8-15
		uint8_t OTP2:8;             // bit 16-23
		uint8_t unused_24_31:8;     // bit 24-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_OTP_READ_t;

// 0x06 R IOIN
typedef union _tmc2209_IOIN_t
{
	struct
	{
		uint8_t ENN:1;              // bit 0
		uint8_t unused_1:1;         // bit 1
		uint8_t MS1:1;              // bit 2
		uint8_t MS2:1;              // bit 3
		uint8_t DIAG:1;             // bit 4
		uint8_t unused_5:1;         // bit 5
		uint8_t PDN_UART:1;         // bit 6
		uint8_t STEP:1;             // bit 7
		uint8_t SPREAD_EN:1;        // bit 8
		uint8_t DIR:1;              // bit 9
		uint32_t unused_10_31:22;   // bit 10-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_IOIN_t;

// 0x07 RW FACTORY_CONF
typedef union _tmc2209_FACTORY_CONF_t
{
	struct
	{
		uint8_t FCLKTRIM:5;         // bit 0-4
		uint8_t unused_5_7:3;       // bit 5-7
		uint8_t OTTRIM:2;           // bit 8-9
		uint32_t unused_10_31:22;   // bit 10-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_FACTORY_CONF_t;

// 0x10 W IHOLD_IRUN
typedef union _tmc2209_IHOLD_IRUN_t
{
	struct
	{
		uint8_t IHOLD:5;            // bit 0-4
		uint8_t unused5_7:3;        // bit 5-7
		uint8_t IRUN:5;             // bit 8-12
		uint8_t unused_13_15:3;     // bit 13-15
		uint8_t IHOLDDELAY:2;       // bit 16-19
		uint16_t unused_20_31:12;   // bit 20-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_IHOLD_IRUN_t;

// 0x11 W TPOWERDOWN
typedef union _tmc2209_TPOWERDOWN_t
{
	struct
	{
		uint8_t value:8;            // bit 0-7
		uint32_t unused_8_31:24;    // bit 8-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_TPOWERDOWN_t;

// 0x12 R TSTEP
typedef union _tmc2209_TSTEP_t
{
	struct
	{
		uint32_t value:20;          // bit 0-19
		uint16_t unused_20_31:12;   // bit 20-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_TSTEP_t;

// 0x13 W TPWMTHRS
typedef union _tmc2209_TPWMTHRS_t
{
	struct
	{
		uint32_t value:20;          // bit 0-19
		uint16_t unused_20_31:12;   // bit 20-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_TPWMTHRS_t;

// 0x14 W TCOOLTHRS
typedef union _tmc2209_TCOOLTHRS_t
{
	struct
	{
		uint32_t value:20;          // bit 0-19
		uint16_t unused_20_31:12;   // bit 20-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_TCOOLTHRS_t;

// 0x22 W VACTUAL
typedef union _tmc2209_VACTUAL_t
{
	struct
	{
		uint32_t value:24;          // bit 0-23
		uint8_t unused_24_31:8;     // bit 24-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_VACTUAL_t;

// 0x40 W SGTHRS
typedef union _tmc2209_SGTHRS_t
{
	struct
	{
		uint8_t value:8;            // bit 0-7
		uint32_t unused_8_31:24;    // bit 8-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_SGTHRS_t;

// 0x41 R SG_RESULT
typedef union _tmc2209_SG_RESULT_t
{
	struct
	{
		uint16_t value:10;          // bit 0-9
		uint32_t unused_10_31:22;   // bit 10-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_SG_RESULT_t;

// 0x42 W COOLCONF
typedef union _tmc2209_COOLCONF_t
{
	struct
	{
		uint8_t semin:4;            // bit 0-3
		uint8_t unused_4:1;         // bit 4
		uint8_t seup:2;             // bit 5-6
		uint8_t unused_7:1;         // bit 7
		uint8_t semax:4;            // bit 8-11
		uint8_t unused_12:1;        // bit 12
		uint8_t sedn:2;             // bit 13-14
		uint8_t seimin:1;           // bit 15
		uint16_t unused_16_31:16;   // bit 16-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_COOLCONF_t;

// 0x6a R MSCNT
typedef union _tmc2209_MSCNT_t
{
	struct
	{
		uint16_t value:10;          // bit 0-9
		uint32_t unused_10_31:22;   // bit 10-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_MSCNT_t;

// 0x6b R MSCURACT
typedef union _tmc2209_MSCURACT_t
{
	struct
	{
		int16_t cur_a:9;            // bit 0-8
		uint8_t unused_9_15:7;      // bit 9-15
		int16_t cur_b:9;            // bit 16-24
		uint8_t unused_25_31:7;     // bit 25-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_MSCURACT_t;

// 0x6c RW CHOPCONF
typedef union _tmc2209_CHOPCONF_t
{
	struct
	{
		uint8_t toff:4;             // bit 0-3
		uint8_t hstr:3;             // bit 4-6
		uint16_t hend:4;             // bit 7-10
		uint8_t unused_11_14:4;     // bit 11-14
		uint32_t tbl:2;              // bit 15-16
		uint8_t vsense:1;           // bit 17
		uint8_t unused_18_23:6;     // bit 18-23
		uint8_t mres:4;             // bit 24-27
		uint8_t intpol:1;           // bit 28
		uint8_t dedge:1;            // bit 29
		uint8_t diss2g:1;           // bit 30
		uint8_t diss2vs:1;          // bit 31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_CHOPCONF_t;

// 0x6f R DRV_STATUS
typedef union _tmc2209_DRV_STATUS_t
{
	struct
	{
		uint8_t otpw:1;             // bit 0
		uint8_t ot:1;               // bit 1
		uint8_t s2ga:1;             // bit 2
		uint8_t s2gb:1;             // bit 3
		uint8_t s2vsa:1;            // bit 4
		uint8_t s2vsb:1;            // bit 5
		uint8_t ola:1;              // bit 6
		uint8_t olb:1;              // bit 7
		uint8_t t120:1;             // bit 8
		uint8_t t143:1;             // bit 9
		uint8_t t150:1;             // bit 10
		uint8_t t157:1;             // bit 11
		uint8_t unused_12_15:4;     // bit 12-15
		uint8_t CS_ACTUAL:5;        // bit 16-20
		uint8_t unused_21_23:3;     // bit 21-23
		uint8_t unused_24_29:6;     // bit 24-29
		uint8_t stealth:1;          // bit 30
		uint8_t stst:1;             // bit 31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_DRV_STATUS_t;

// 0x70 RW PWMCONF
typedef union _tmc2209_PWMCONF_t
{
	struct
	{
		uint8_t PWM_OFS:8;          // bit 0-7
		uint8_t PWM_GRAD:8;         // bit 8-15
		uint8_t pwm_freq:2;         // bit 16-17
		uint8_t pwm_autoscale:1;    // bit 18
		uint8_t pwm_autograd:1;     // bit 19
		uint8_t freewheel:2;        // bit 20-21
		uint8_t unused_22:1;        // bit 22
		uint8_t unused_23:1;        // bit 23
		uint8_t PWM_REG:4;          // bit 24-27
		uint8_t PWM_LIM:4;          // bit 28-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_PWMCONF_t;

// 0x71 R PWM_SCALE
typedef union _tmc2209_PWM_SCALE_t
{
	struct
	{
		uint8_t PWM_SCALE_SUM:8;    // bit 0-7
		uint8_t unused_8_15:8;      // bit 8-15
		uint16_t PWM_SCALE_AUTO:9;  // bit 16-24
		uint8_t unused_25_31:7;     // bit 25-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_PWM_SCALE_t;

// 0x72 R PWM_AUTO
typedef union _tmc2209_PWM_AUTO_t
{
	struct
	{
		uint8_t PWM_OFS_AUTO:8;     // bit 0-7
		uint8_t unused_8_15:8;      // bit 8-15
		uint8_t PWM_GRAD_AUTO:8;    // bit 16-23
		uint8_t unused_24_31:8;     // bit 24-31
	};
	uint32_t ui32;                  // bit 0-31
} tmc2209_PWM_AUTO_t;

// union of all tmc2209 register data types + raw uint32_t
typedef union _tmc2209_reg_data_t
{
	tmc2209_GCONF_t gconf;               // 0x00 RW
	tmc2209_GSTAT_t gstat;               // 0x01 R+WC
	tmc2209_IFCNT_t ifcnt;               // 0x02 R
	tmc2209_SLAVECONF_t slaveconf;       // 0x03 W
	tmc2209_OTP_PROG_t otp_prog;         // 0x04 W
	tmc2209_OTP_READ_t otp_read;         // 0x05 R
	tmc2209_IOIN_t ioin;                 // 0x06 R
	tmc2209_FACTORY_CONF_t factory_conf; // 0x07 R
	tmc2209_IHOLD_IRUN_t ihold_irun;     // 0x10 W
	tmc2209_TPOWERDOWN_t tpowerdown;     // 0x11 W
	tmc2209_TSTEP_t tstep;               // 0x12 R
	tmc2209_TPWMTHRS_t tpwmthrs;         // 0x13 W
	tmc2209_TCOOLTHRS_t tcoolthrs;       // 0x14 W
	tmc2209_VACTUAL_t vactual;           // 0x22 W
	tmc2209_SGTHRS_t sgthrs;             // 0x40 W
	tmc2209_SG_RESULT_t sg_result;       // 0x41 R
	tmc2209_COOLCONF_t coolconf;         // 0x42 W
	tmc2209_MSCNT_t mscnt;               // 0x6a R
	tmc2209_MSCURACT_t mscuract;         // 0x6b R
	tmc2209_CHOPCONF_t chopconf;         // 0x6c RW
	tmc2209_DRV_STATUS_t drv_status;     // 0x6f R
	tmc2209_PWMCONF_t pwmconf;           // 0x70 RW
	tmc2209_PWM_SCALE_t pwm_scale;       // 0x71 R
	tmc2209_PWM_AUTO_t pwm_auto;         // 0x72 R
	uint32_t ui32;                       // raw uint32_t
} tmc2209_reg_data_t;


#ifdef __cplusplus
extern "C" {
#endif //__cplusplus


// returns register name from register id
extern const char* tmc2209_regname(tmc2209_reg_addr_t reg);


#ifdef __cplusplus
}
#endif //__cplusplus


#endif //_TMC2209_REGS_H
