
#include "chu_init.h"
#include "gpio_cores.h"


GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));

int main() {
   
   const uint32_t led0 = 0x1;
   led.write(led0);


   led.set_blink_period_ms(500);

   while (1) {

      sleep_ms(1000);
   }

   return 0;
}