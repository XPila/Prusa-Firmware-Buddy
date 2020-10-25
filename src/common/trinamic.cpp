// trinamic.cpp
#include "trinamic.h"
#include "dbg.h"
#include "config.h"

#ifdef NEW_TMC2209
    #include "../lib/TMC2209/tmc2209.h"
#else //NEW_TMC2209
    #include "TMCStepper.h"
#endif //NEW_TMC2209

#include "gpio.h"
#include "bsod.h"
#include "hwio_pindef.h"
#include "../Marlin/src/module/stepper.h"

#define DBG _dbg0 //debug level 0
//#define DBG(...)  //disable debug

#if ((MOTHERBOARD == 1823))

using namespace buddy::hw;
    #ifdef NEW_TMC2209

    #else  //NEW_TMC2209
static TMC2209Stepper *pStep[4] = { nullptr, nullptr, nullptr, nullptr };
    #endif //NEW_TMC2209

static const uint8_t tmc_id[4] = { TMC2209_ID_X, TMC2209_ID_Y, TMC2209_ID_Z, TMC2209_ID_E }; // axis slave ids
static const char tmc_axis_char[4] = { 'X', 'Y', 'Z', 'E' };                                 // axis chars (for BSOD)

static uint16_t tmc_sg[4];      // stallguard result for each axis
static uint8_t tmc_sg_mask = 7; // stalguard result sampling mask (bit0-x, bit1-y, ...), xyz by default
static uint8_t tmc_sg_axis = 0; // current axis for stalguard result sampling (0-x, 1-y, ...)

static tmc_sg_sample_cb_t *tmc_sg_sampe_cb = 0; // sg sample callback

extern "C" {

uint8_t tmc_get_sg_mask() { return tmc_sg_mask; }
uint8_t tmc_get_sg_axis() { return tmc_sg_axis; }
tmc_sg_sample_cb_t *tmc_get_sg_sampe_cb() { return tmc_sg_sampe_cb; }

void tmc_set_sg_mask(uint8_t mask) { tmc_sg_mask = mask; }
void tmc_set_sg_axis(uint8_t axis) { tmc_sg_axis = axis; }
void tmc_set_sg_sampe_cb(tmc_sg_sample_cb_t *cb) { tmc_sg_sampe_cb = cb; }

void tmc_packet_cb(uint8_t *tx_data, uint8_t tx_size, uint8_t *rx_data, uint8_t rx_size) {
    if ((tx_size == 8) && (rx_size == 8)) {
        //DBG("tx %02x %02x %02x %02x %02x %02x %02x %02x", tx_data[0], tx_data[1], tx_data[2], tx_data[3], tx_data[4], tx_data[5], tx_data[6], tx_data[7]);
        //DBG("rx %02x %02x %02x %02x %02x %02x %02x %02x", rx_data[0], rx_data[1], rx_data[2], rx_data[3], rx_data[4], rx_data[5], rx_data[6], rx_data[7]);
        uint8_t id = tx_data[1];
        uint8_t reg = tx_data[2] & 0x7f;
        uint32_t data = (((uint32_t)tx_data[3]) << 24) | (((uint32_t)tx_data[4]) << 16) | (((uint32_t)tx_data[5]) << 8) | ((uint32_t)tx_data[6]);
        const char *regname = tmc2209_regname((tmc2209_reg_addr_t)reg);
        DBG("TMC%d WR reg %12s value=0x%08x", id, regname, data);
    } else if ((tx_size == 4) && (rx_size == 12)) {
        //DBG("tx %02x %02x %02x %02x", tx_data[0], tx_data[1], tx_data[2], tx_data[3]);
        //DBG("rx %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x", rx_data[0], rx_data[1], rx_data[2], rx_data[3], rx_data[4], rx_data[5], rx_data[6], rx_data[7], rx_data[8], rx_data[9], rx_data[10], rx_data[11]);
        uint8_t id = tx_data[1];
        uint8_t reg = rx_data[4 + 2] & 0x7f;
        uint32_t data = (((uint32_t)rx_data[4 + 3]) << 24) | (((uint32_t)rx_data[4 + 4]) << 16) | (((uint32_t)rx_data[4 + 5]) << 8) | ((uint32_t)rx_data[4 + 6]);
        const char *regname = tmc2209_regname((tmc2209_reg_addr_t)reg);
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

extern UART_HandleTypeDef huart2;

void init_tmc(void) {
    #ifdef NEW_TMC2209
    tmc2209_init(&huart2);
    tmc2209_slave_config_t cfg_X { .mres = 4, .intpol = 1, .vsense = 1, .en_SpreadCycle = 0, .IHOLD_IRUN = 20, .tcoolthrs = 400, .sgthrs = 140 };
    tmc2209_slave_config_t cfg_Y { .mres = 4, .intpol = 1, .vsense = 1, .en_SpreadCycle = 0, .IHOLD_IRUN = 20, .tcoolthrs = 400, .sgthrs = 130 };
    tmc2209_slave_config_t cfg_Z { .mres = 5, .intpol = 1, .vsense = 1, .en_SpreadCycle = 0, .IHOLD_IRUN = 20, .tcoolthrs = 400, .sgthrs = 100 };
    tmc2209_slave_config_t cfg_E { .mres = 4, .intpol = 1, .vsense = 1, .en_SpreadCycle = 1, .IHOLD_IRUN = 23, .tcoolthrs = 400, .sgthrs = 100 };
    tmc2209_err_t resX = tmc2209_init_slave(TMC2209_ID_X, &cfg_X);
    tmc2209_err_t resY = tmc2209_init_slave(TMC2209_ID_Y, &cfg_Y);
    tmc2209_err_t resZ = tmc2209_init_slave(TMC2209_ID_Z, &cfg_Z);
    tmc2209_err_t resE = tmc2209_init_slave(TMC2209_ID_E, &cfg_E);
    if ((resX != TMC2209_ERR_OK) || (resY != TMC2209_ERR_OK) || (resZ != TMC2209_ERR_OK) || (resE != TMC2209_ERR_OK)) {
        bsod("TMC init error\nX - %s\nY - %s\nZ - %s\nE - %s",
            (resX == TMC2209_ERR_OK) ? "OK" : "ERR",
            (resY == TMC2209_ERR_OK) ? "OK" : "ERR",
            (resZ == TMC2209_ERR_OK) ? "OK" : "ERR",
            (resE == TMC2209_ERR_OK) ? "OK" : "ERR");
    }
    #else //NEW_TMC2209

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
    pStep[X_AXIS]->SGTHRS(130);
    pStep[Y_AXIS]->SGTHRS(130);
    pStep[Z_AXIS]->SGTHRS(100);
    pStep[E_AXIS]->SGTHRS(100);

    #endif //NEW_TMC2209
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
    #ifdef NEW_TMC2209
            tmc2209_SG_RESULT_t sg_result;
            tmc2209_err_t res = tmc2209_rdreg(tmc_id[tmc_sg_axis], TMC2209_REG_SG_RESULT, &sg_result.ui32);
            if (res != TMC2209_ERR_OK)
                bsod("TMC %c read error (SG_RESULT).", tmc_axis_char[tmc_sg_axis]);
    #else  //NEW_TMC2209
            tmc_sg[tmc_sg_axis] = pStep[tmc_sg_axis]->SG_RESULT();
    #endif //NEW_TMC2209
        } else
            tmc_sg[tmc_sg_axis] = 0;
        if (tmc_sg_sampe_cb)
            tmc_sg_sampe_cb(tmc_sg_axis, tmc_sg[tmc_sg_axis]);
        tmc_sg_axis = (tmc_sg_axis + 1) & 0x03;
    }
    return mask;
}

void tmc_set_sgthrs(uint16_t SGT) {
    #ifdef NEW_TMC2209

    #else  //NEW_TMC2209
    pStep[0]->SGTHRS(SGT);
    pStep[1]->SGTHRS(SGT);
    pStep[2]->SGTHRS(SGT);
    pStep[3]->SGTHRS(SGT);
    #endif //NEW_TMC2209
}
void tmc_set_mres() {
    #ifdef NEW_TMC2209

    #else  //NEW_TMC2209
    pStep[0]->mres(4);
    pStep[1]->mres(4);
    pStep[2]->mres(4);
    pStep[3]->mres(4);
    #endif //NEW_TMC2209
}

uint8_t tmc_get_diag() //0 = X, 2 = Y, 4 = Z, 8 = E
{
    #ifdef NEW_TMC2209
    unsigned int diag = 0;
    return diag;
    #else  //NEW_TMC2209
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
            xStep.write(Pin::State::low);
        if (step_mask & 2)
            yStep.write(Pin::State::low);
        if (step_mask & 4)
            zStep.write(Pin::State::low);
        if (step_mask & 8)
            e0Step.write(Pin::State::low);
        //fixme why there is no delay?
        xStep.write(Pin::State::high);
        yStep.write(Pin::State::high);
        zStep.write(Pin::State::high);
        e0Step.write(Pin::State::high);
        diag |= static_cast<unsigned int>(e0Diag.read()) << 3;
        diag |= static_cast<unsigned int>(xDiag.read());
        diag |= static_cast<unsigned int>(yDiag.read()) << 1;
        diag |= static_cast<unsigned int>(zDiag.read()) << 2;

        if (diag == 15)
            break;
    }
    return diag;
    #endif //NEW_TMC2209
}

void tmc_move(uint8_t step_mask, uint16_t step, uint8_t speed) {
    uint16_t tmp_step;
    for (tmp_step = 0; tmp_step < step; step--) {
        if (step_mask & 1)
            xStep.write(Pin::State::high);
        if (step_mask & 2)
            yStep.write(Pin::State::high);
        if (step_mask & 4)
            zStep.write(Pin::State::high);
        if (step_mask & 8)
            e0Step.write(Pin::State::high);
        tmc_delay(1024 * speed);
        xStep.write(Pin::State::low);
        yStep.write(Pin::State::low);
        zStep.write(Pin::State::low);
        e0Step.write(Pin::State::low);
    }
}

void tmc_set_move(uint8_t tmc, uint32_t step, uint8_t dir, uint8_t speed) {
    xDir.write(static_cast<Pin::State>(dir));
    yDir.write(static_cast<Pin::State>(dir));
    zDir.write(static_cast<Pin::State>(dir));
    e0Dir.write(static_cast<Pin::State>(dir));
    tmc_move(tmc, step, speed);
}

} //extern "C"

#else

    #error "MOTHERBOARD not defined"

#endif
