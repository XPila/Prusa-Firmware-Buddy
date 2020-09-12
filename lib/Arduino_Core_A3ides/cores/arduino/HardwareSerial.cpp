//HardwareSerial.cpp - A3ides/STM32
#include <Arduino.h>
#include "cmsis_os.h"

// uart2 (communication with TMC2209)

extern "C" {

extern UART_HandleTypeDef huart2;
extern DMA_HandleTypeDef hdma_usart2_rx;
extern osThreadId uart2_thread;
extern int32_t uart2_signal;

uint8_t rbuff[10];
unsigned int rbufc = 0;
unsigned int rbufi = 0;

typedef void(tmc2209_packet_cb_t)(uint8_t *tx_data, uint8_t tx_size, uint8_t *rx_data, uint8_t rx_size);

tmc2209_packet_cb_t *tmc2209_packet_cb = 0;
}

HardwareSerial::HardwareSerial(void *peripheral) {
}

void HardwareSerial::begin(unsigned long baud) {
}

void HardwareSerial::begin(unsigned long baud, byte config) {
}

int HardwareSerial::available(void) {
    return rbufc;
}

int HardwareSerial::peek(void) {
    return -1;
}

int HardwareSerial::read(void) {
    int ch = -1;
    if (rbufc) {
        ch = rbuff[rbufi++];
        rbufc--;
    }
    return ch;
}

void HardwareSerial::flush() {
}

size_t HardwareSerial::write(uint8_t c) {
    static int cnt = 0;
    static uint8_t buf[10];
    uint8_t buf2[20] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    int len = 4;
    buf[cnt++] = c;
    if ((cnt > 2) && (buf[2] & 0x80))
        len = 8;
    if (cnt >= len) {
        uart2_thread = osThreadGetId();
        int retry = 3;
        while (retry--) {
            if (len == 4)
                HAL_UART_Receive_DMA(&huart2, buf2, 12);
            else if (len == 8)
                HAL_UART_Receive_DMA(&huart2, buf2, 8);
            HAL_UART_Transmit(&huart2, buf, len, HAL_MAX_DELAY);
            if (len == 4) //
            {
                osEvent ose;
                if ((ose = osSignalWait(uart2_signal, 100)).status == osEventSignal) {
                    if (tmc2209_packet_cb)
                        tmc2209_packet_cb(buf, 4, buf2, 12);
                    memcpy(rbuff, buf2 + 4, 8);
                    rbufi = 0;
                    rbufc = 8;
                    retry = 0;
                } else if (ose.status == osEventTimeout) {
                    HAL_UART_AbortReceive(&huart2);
                    if (tmc2209_packet_cb)
                        tmc2209_packet_cb(buf, 4, 0, 0);
                }
            } else if (len == 8) //
            {
                osEvent ose;
                if ((ose = osSignalWait(uart2_signal, 100)).status == osEventSignal) {
                    if (tmc2209_packet_cb)
                        tmc2209_packet_cb(buf, 8, buf2, 8);
                    memcpy(rbuff, buf2, 8);
                    rbufi = 0;
                    rbufc = 4;
                    retry = 0;
                } else if (ose.status == osEventTimeout) {
                    HAL_UART_AbortReceive(&huart2);
                    if (tmc2209_packet_cb)
                        tmc2209_packet_cb(buf, 8, 0, 0);
                }
            } else {
                HAL_UART_AbortReceive(&huart2);
                if (tmc2209_packet_cb)
                    tmc2209_packet_cb(0, 0, 0, 0);
            }
        }
        cnt = 0;
        uart2_thread = 0;
    }
    return 1;
}

HardwareSerial::operator bool() {
    return true;
}

HardwareSerial Serial3(USART3);
