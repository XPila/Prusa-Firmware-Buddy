// tmc2209_regs.c
#include "tmc2209_regs.h"


const char* tmc2209_regname(tmc2209_reg_addr_t reg)
{
	switch (reg)
	{
	case TMC2209_REG_GCONF:        return "GCONF";
	case TMC2209_REG_GSTAT:        return "GSTAT";
	case TMC2209_REG_IFCNT:        return "IFCNT";
	case TMC2209_REG_SLAVECONF:    return "SLAVECONF";
	case TMC2209_REG_OTP_PROG:     return "OTP_PROG";
	case TMC2209_REG_OTP_READ:     return "OTP_READ";
	case TMC2209_REG_IOIN:         return "IOIN";
	case TMC2209_REG_FACTORY_CONF: return "FACTORY_CONF";
	case TMC2209_REG_IHOLD_IRUN:   return "IHOLD_IRUN";
	case TMC2209_REG_TPOWERDOWN:   return "TPOWERDOWN";
	case TMC2209_REG_TSTEP:        return "TSTEP";
	case TMC2209_REG_TPWMTHRS:     return "TPWMTHRS";
	case TMC2209_REG_TCOOLTHRS:    return "TCOOLTHRS";
	case TMC2209_REG_VACTUAL:      return "VACTUAL";
	case TMC2209_REG_SGTHRS:       return "SGTHRS";
	case TMC2209_REG_SG_RESULT:    return "SG_RESULT";
	case TMC2209_REG_COOLCONF:     return "COOLCONF";
	case TMC2209_REG_MSCNT:        return "MSCNT";
	case TMC2209_REG_MSCURACT:     return "MSCURACT";
	case TMC2209_REG_CHOPCONF:     return "CHOPCONF";
	case TMC2209_REG_DRV_STATUS:   return "DRV_STATUS";
	case TMC2209_REG_PWMCONF:      return "PWMCONF";
	case TMC2209_REG_PWM_SCALE:    return "PWM_SCALE";
	case TMC2209_REG_PWM_AUTO:     return "PWM_AUTO";
	}
	return "";
}
