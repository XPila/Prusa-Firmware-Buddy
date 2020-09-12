// trinamic.cpp
#include "dbg.h"
#include "config.h"
#include "hwio_a3ides.h"
#include "TMCStepper.h"
#include "gpio.h"
#include "hwio_pindef.h"
#include "../Marlin/src/module/stepper.h"

#define DBG _dbg0 //debug level 0
//#define DBG(...)  //disable debug

#define TMC2209_REG_GCONF        0x00 // RW
#define TMC2209_REG_GSTAT        0x01 // R+WC
#define TMC2209_REG_IFCNT        0x02 // R
#define TMC2209_REG_SLAVECONF    0x03 // W
#define TMC2209_REG_OTP_PROG     0x04 // W
#define TMC2209_REG_OTP_READ     0x05 // R
#define TMC2209_REG_IOIN         0x06 // R
#define TMC2209_REG_FACTORY_CONF 0x07 // RW
#define TMC2209_REG_IHOLD_IRUN   0x10 // W
#define TMC2209_REG_TPOWERDOWN   0x11 // W
#define TMC2209_REG_TSTEP        0x12 // R
#define TMC2209_REG_TPWMTHRS     0x13 // W
#define TMC2209_REG_TCOOLTHRS    0x14 // W
#define TMC2209_REG_VACTUAL      0x22 // W
#define TMC2209_REG_SGTHRS       0x40 // W
#define TMC2209_REG_SG_RESULT    0x41 // R
#define TMC2209_REG_COOLCONF     0x42 // W
#define TMC2209_REG_MSCNT        0x6a // R
#define TMC2209_REG_MSCURACT     0x6b // R
#define TMC2209_REG_CHOPCONF     0x6c // RW
#define TMC2209_REG_DRV_STATUS   0x6f // R
#define TMC2209_REG_PWMCONF      0x70 // RW
#define TMC2209_REG_PWM_SCALE    0x71 // R
#define TMC2209_REG_PWM_AUTO     0x72 // R

#if ((MOTHERBOARD == 1823))

extern "C" {

TMC2209Stepper *pStep[4] = { nullptr, nullptr, nullptr, nullptr };

uint16_t tmc_step = 0;
uint8_t tmc_stepper = -1;

uint16_t tmc_sg[4];      // stallguard result for each axis
uint8_t tmc_sg_mask = 7; // stalguard result sampling mask (bit0-x, bit1-y, ...), xyz by default
uint8_t tmc_sg_axis = 0; // current axis for stalguard result sampling (0-x, 1-y, ...)

uint8_t tmc2209_calc_crc(uint8_t *data, uint8_t size) {
    int i, j;
    uint8_t crc = 0; // CRC
    uint8_t currentByte;
    for (i = 0; i < (size - 1); i++) { // Execute for all bytes of a message
        currentByte = data[i];         // Retrieve a byte
        for (j = 0; j < 8; j++) {
            if ((crc >> 7) ^ (currentByte & 0x01)) // update CRC based result of XOR operation
                crc = (crc << 1) ^ 0x07;
            else
                crc = (crc << 1);
            currentByte = currentByte >> 1;
        } // for CRC bit
    }     // for message byte
    return crc;
}

const char *tmc2209_regname(uint8_t reg) {
    switch (reg) {
    case TMC2209_REG_GCONF:
        return "GCONF";
    case TMC2209_REG_GSTAT:
        return "GSTAT";
    case TMC2209_REG_IFCNT:
        return "IFCNT";
    case TMC2209_REG_SLAVECONF:
        return "SLAVECONF";
    case TMC2209_REG_OTP_PROG:
        return "OTP_PROG";
    case TMC2209_REG_OTP_READ:
        return "OTP_READ";
    case TMC2209_REG_IOIN:
        return "IOIN";
    case TMC2209_REG_FACTORY_CONF:
        return "FACTORY_CONF";
    case TMC2209_REG_IHOLD_IRUN:
        return "IHOLD_IRUN";
    case TMC2209_REG_TPOWERDOWN:
        return "TPOWERDOWN";
    case TMC2209_REG_TSTEP:
        return "TSTEP";
    case TMC2209_REG_TPWMTHRS:
        return "TPWMTHRS";
    case TMC2209_REG_TCOOLTHRS:
        return "TCOOLTHRS";
    case TMC2209_REG_VACTUAL:
        return "VACTUAL";
    case TMC2209_REG_SGTHRS:
        return "SGTHRS";
    case TMC2209_REG_SG_RESULT:
        return "SG_RESULT";
    case TMC2209_REG_COOLCONF:
        return "COOLCONF";
    case TMC2209_REG_MSCNT:
        return "MSCNT";
    case TMC2209_REG_MSCURACT:
        return "MSCURACT";
    case TMC2209_REG_CHOPCONF:
        return "CHOPCONF";
    case TMC2209_REG_DRV_STATUS:
        return "DRV_STATUS";
    case TMC2209_REG_PWMCONF:
        return "PWMCONF";
    case TMC2209_REG_PWM_SCALE:
        return "PWM_SCALE";
    case TMC2209_REG_PWM_AUTO:
        return "PWM_AUTO";
    }
    return "";
}
void tmc_packet_cb(uint8_t *tx_data, uint8_t tx_size, uint8_t *rx_data, uint8_t rx_size) {
    if ((tx_size == 8) && (rx_size == 8)) {
        //DBG("tx %02x %02x %02x %02x %02x %02x %02x %02x", tx_data[0], tx_data[1], tx_data[2], tx_data[3], tx_data[4], tx_data[5], tx_data[6], tx_data[7]);
        //DBG("rx %02x %02x %02x %02x %02x %02x %02x %02x", rx_data[0], rx_data[1], rx_data[2], rx_data[3], rx_data[4], rx_data[5], rx_data[6], rx_data[7]);
        uint8_t id = tx_data[1];
        uint8_t reg = tx_data[2] & 0x7f;
        uint32_t data = (((uint32_t)tx_data[3]) << 24) | (((uint32_t)tx_data[4]) << 16) | (((uint32_t)tx_data[5]) << 8) | ((uint32_t)tx_data[6]);
        const char *regname = tmc2209_regname(reg);
        DBG("TMC%d WR reg %12s value=0x%08x", id, regname, data);
    } else if ((tx_size == 4) && (rx_size == 12)) {
        //DBG("tx %02x %02x %02x %02x", tx_data[0], tx_data[1], tx_data[2], tx_data[3]);
        //DBG("rx %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x", rx_data[0], rx_data[1], rx_data[2], rx_data[3], rx_data[4], rx_data[5], rx_data[6], rx_data[7], rx_data[8], rx_data[9], rx_data[10], rx_data[11]);
        uint8_t id = tx_data[1];
        uint8_t reg = rx_data[4 + 2] & 0x7f;
        uint32_t data = (((uint32_t)rx_data[4 + 3]) << 24) | (((uint32_t)rx_data[4 + 4]) << 16) | (((uint32_t)rx_data[4 + 5]) << 8) | ((uint32_t)rx_data[4 + 6]);
        const char *regname = tmc2209_regname(reg);
        DBG("TMC%d RD reg %12s value=0x%08x", id, regname, data);
    }
}

typedef void(tmc2209_packet_cb_t)(uint8_t *tx_data, uint8_t tx_size, uint8_t *rx_data, uint8_t rx_size);

extern tmc2209_packet_cb_t *tmc2209_packet_cb;

void tmc_delay(uint16_t time) // delay for switching tmc step pin level
{
    volatile uint16_t tmc_delay;
    for (tmc_delay = 0; tmc_delay < time; time--) {
    }
}

void hook_tmc(void) {
    tmc2209_packet_cb = tmc_packet_cb;
}

void init_tmc(void) {

    //pointers to TMCStepper instances
    pStep[X_AXIS] = &stepperX;
    pStep[Y_AXIS] = &stepperY;
    pStep[Z_AXIS] = &stepperZ;
    pStep[E_AXIS] = &stepperE0;
    //set TCOOLTHRS
    pStep[X_AXIS]->TCOOLTHRS(400);
    pStep[Y_AXIS]->TCOOLTHRS(400);
    pStep[Z_AXIS]->TCOOLTHRS(400);
    pStep[E_AXIS]->TCOOLTHRS(400);
    //set SGTHRS
    pStep[X_AXIS]->SGTHRS(140);
    pStep[Y_AXIS]->SGTHRS(130);
    pStep[Z_AXIS]->SGTHRS(100);
    pStep[E_AXIS]->SGTHRS(100);
}

// this function performs stallguard sample for single axis
// return value contain bitmask of sampled axis, in case of nonzero return value this call take 5ms
//  Now we are using stepper.axis_is_moving and value is set to zero for stopped motor,
//  right way is reading tstep and comparing it to TCOOLTHRS, but it takes time (read register).
//  Using stepper.axis_is_moving is simple but in some cases we get bad samples (tstep > TCOOLTHRS).
//  Maybe we can improve this by calculating tstep from stepper variables.
uint8_t tmc_sample(void) {
    uint8_t mask = 0;
    if (tmc_sg_mask) {
        while ((tmc_sg_mask & (1 << tmc_sg_axis)) == 0)
            tmc_sg_axis = (tmc_sg_axis + 1) & 0x03;
        if (stepper.axis_is_moving((AxisEnum)tmc_sg_axis)) {
            mask = (1 << tmc_sg_axis);
            tmc_sg[tmc_sg_axis] = pStep[tmc_sg_axis]->SG_RESULT();
        } else
            tmc_sg[tmc_sg_axis] = 0;
        tmc_sg_axis = (tmc_sg_axis + 1) & 0x03;
    }
    return mask;
}

void tmc_set_sgthrs(uint16_t SGT) {
    pStep[0]->SGTHRS(SGT);
    pStep[1]->SGTHRS(SGT);
    pStep[2]->SGTHRS(SGT);
    pStep[3]->SGTHRS(SGT);
}
void tmc_set_mres() {
    pStep[0]->mres(4);
    pStep[1]->mres(4);
    pStep[2]->mres(4);
    pStep[3]->mres(4);
}
uint8_t tmc_get_diag() //0 = X, 2 = Y, 4 = Z, 8 = E
{
    unsigned int diag = 0;
    uint16_t tmp_step;
    uint16_t step = 3500;
    uint8_t step_mask = 15;

    uint32_t gconf = pStep[3]->GCONF();
    gconf &= ~4;
    pStep[3]->GCONF(gconf);
    diag = 0;

    for (tmp_step = 0; tmp_step < step; step--) {
        tmc_delay(1024 * 2);
        if (step_mask & 1)
            gpio_set(PIN_X_STEP, 0);
        if (step_mask & 2)
            gpio_set(PIN_Y_STEP, 0);
        if (step_mask & 4)
            gpio_set(PIN_Z_STEP, 0);
        if (step_mask & 8)
            gpio_set(PIN_E_STEP, 0);
        gpio_set(PIN_X_STEP, 1);
        gpio_set(PIN_Y_STEP, 1);
        gpio_set(PIN_Z_STEP, 1);
        gpio_set(PIN_E_STEP, 1);
        diag |= gpio_get(PIN_E_DIAG) << 3;
        diag |= gpio_get(PIN_X_DIAG);
        diag |= gpio_get(PIN_Y_DIAG) << 1;
        diag |= gpio_get(PIN_Z_DIAG) << 2;

        if (diag == 15)
            break;
    }
    return diag;
}

void tmc_move(uint8_t step_mask, uint16_t step, uint8_t speed) {
    uint16_t tmp_step;
    for (tmp_step = 0; tmp_step < step; step--) {
        if (step_mask & 1)
            gpio_set(PIN_X_STEP, 1);
        if (step_mask & 2)
            gpio_set(PIN_Y_STEP, 1);
        if (step_mask & 4)
            gpio_set(PIN_Z_STEP, 1);
        if (step_mask & 8)
            gpio_set(PIN_E_STEP, 1);
        tmc_delay(1024 * speed);
        gpio_set(PIN_X_STEP, 0);
        gpio_set(PIN_Y_STEP, 0);
        gpio_set(PIN_Z_STEP, 0);
        gpio_set(PIN_E_STEP, 0);
    }
}

void tmc_set_move(uint8_t tmc, uint16_t step, uint8_t dir, uint8_t speed) {
    gpio_set(PIN_X_DIR, dir);
    gpio_set(PIN_Y_DIR, dir);
    gpio_set(PIN_Z_DIR, dir);
    gpio_set(PIN_E_DIR, dir);
    tmc_move(tmc, step, speed);
}

} //extern "C"

#else

    #error "MOTHERBOARD not defined"

#endif
