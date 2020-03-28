// screen_test_eeprom.c

#include "gui.h"
#include "config.h"
#include "st25dv64k.h"
#include "dbg.h"
#include "cmsis_os.h"
#include "ff.h"
#include "eeprom.h"
#include "eeprom_loadsave.h"

#define _PAGE_SIZE 128
#define _PAGES     16

#pragma pack(push)
#pragma pack(1)

typedef struct
{
    window_frame_t frame;
    window_text_t tst;
    window_text_t txt_back;
    window_text_t txt_start_stop;
    window_text_t txt_pass;
    window_numb_t num_pass;
    window_text_t txt_page;
    window_numb_t num_page;
    window_text_t txt_errs;
    window_numb_t num_errs;
    int running;
    int pass;
    int page;
    int errs;
    uint8_t data_w[_PAGE_SIZE];
    uint8_t data_r[_PAGE_SIZE];
} screen_test_eeprom_data_t;

#pragma pack(pop)

#define pd ((screen_test_eeprom_data_t *)screen->pdata)

typedef enum {
	WTAG_back = 1,
	WTAG_start_stop,
} WTAG_t;



void screen_test_eeprom_init(screen_t *screen) {
    int16_t id;
    uint16_t y = 0;

    int16_t id0 = window_create_ptr(WINDOW_CLS_FRAME, -1, rect_ui16(0, 0, 0, 0), &(pd->frame));
    y += 32;

    id = window_create_ptr(WINDOW_CLS_TEXT, id0, rect_ui16(10, y, 220, 22), &(pd->tst));
    window_set_text(id, (const char *)"TEST EEPROM");
    y += 22;

    id = window_create_ptr(WINDOW_CLS_TEXT, id0, rect_ui16(10, y, 220, 22), &(pd->txt_back));
    window_set_text(id, (const char *)"back");
    window_enable(id);
    window_set_tag(id, WTAG_back);
    y += 22;

    id = window_create_ptr(WINDOW_CLS_TEXT, id0, rect_ui16(10, y, 220, 22), &(pd->txt_start_stop));
    window_set_text(id, (const char *)"Start");
    window_enable(id);
    window_set_tag(id, WTAG_start_stop);
    y += 22;

    id = window_create_ptr(WINDOW_CLS_TEXT, id0, rect_ui16(10, y, 60, 22), &(pd->txt_pass));
    window_set_text(id, (const char *)"pass:");
    id = window_create_ptr(WINDOW_CLS_NUMB, id0, rect_ui16(70, y, 220, 22), &(pd->num_pass));
    window_set_text(id, (const char *)"0");
    y += 22;

    id = window_create_ptr(WINDOW_CLS_TEXT, id0, rect_ui16(10, y, 60, 22), &(pd->txt_page));
    window_set_text(id, (const char *)"page:");
    id = window_create_ptr(WINDOW_CLS_NUMB, id0, rect_ui16(70, y, 220, 22), &(pd->num_page));
    window_set_text(id, (const char *)"0");
    y += 22;

    id = window_create_ptr(WINDOW_CLS_TEXT, id0, rect_ui16(10, y, 60, 22), &(pd->txt_errs));
    window_set_text(id, (const char *)"errs:");
    id = window_create_ptr(WINDOW_CLS_NUMB, id0, rect_ui16(70, y, 220, 22), &(pd->num_errs));
    window_set_text(id, (const char *)"0");

    pd->running = 0;
    pd->pass = 0;
    pd->page = 0;
    pd->errs = 0;

}

void screen_test_eeprom_done(screen_t *screen) {
    window_destroy(pd->frame.win.id);
}

void screen_test_eeprom_draw(screen_t *screen) {
}

int screen_test_eeprom_event(screen_t *screen, window_t *window, uint8_t event, void *param) {
	int i;
    if (event == WINDOW_EVENT_CLICK)
        switch ((int)param) {
        case WTAG_back:
            screen_close();
            return 1;
        case WTAG_start_stop:
        	if (pd->running)
        	{
				window_set_text(pd->txt_start_stop.win.id, "Start");
				pd->running = 0;
        	}
        	else
			{
				window_set_text(pd->txt_start_stop.win.id, "Stop");
				pd->running = 1;
	    		pd->pass = 0;
	    		pd->page = 0;
	    		pd->errs = 0;
	    		window_set_value(pd->num_pass.win.id,pd->pass);
	    		window_set_value(pd->num_page.win.id,pd->page);
	    		window_set_value(pd->num_errs.win.id,pd->errs);
			}
        	break;
        }
    else if (event == WINDOW_EVENT_LOOP)
	{
    	if (pd->running)
    	{
    		if (pd->page == 0)
    		{
    			switch (pd->pass)
    			{
    			case 0: //pass 0 - zero data
    				memset(pd->data_w, 0, _PAGE_SIZE);
    				break;
    			case 1: //pass 1 - 0xff data
    				memset(pd->data_w, 0xff, _PAGE_SIZE);
    				break;
    			default: //other - random data
    			    srand(pd->pass);
    				for (i = 0; i < _PAGE_SIZE; i++)
    					pd->data_w[i] = 255 * ((float)rand()) / RAND_MAX;
    				break;
    			}
    		}
    		st25dv64k_user_write_bytes(pd->page * _PAGE_SIZE, pd->data_w, _PAGE_SIZE);
			memset(pd->data_r, 0, _PAGE_SIZE);
			st25dv64k_user_read_bytes(pd->page * _PAGE_SIZE, pd->data_r, _PAGE_SIZE);
			if (memcmp(pd->data_w, pd->data_r, _PAGE_SIZE) != 0)
			{
	    		pd->errs++;
			}
    		pd->page++;
    		if (pd->page >= _PAGES)
    		{
	    		pd->page = 0;
	    		pd->pass++;
    		}
    		window_set_value(pd->num_pass.win.id,pd->pass);
    		window_set_value(pd->num_page.win.id,pd->page);
    		window_set_value(pd->num_errs.win.id,pd->errs);
    	}
	}
    return 0;
}


screen_t screen_test_eeprom = {
    0,
    0,
    screen_test_eeprom_init,
    screen_test_eeprom_done,
    screen_test_eeprom_draw,
    screen_test_eeprom_event,
    sizeof(screen_test_eeprom_data_t), //data_size
    0,                                 //pdata
};

const screen_t *pscreen_test_eeprom = &screen_test_eeprom;
