/* transmit V53L0X readings via serial; omit values greater
 * a threshold (seems that 8901mm means target out of range)
 * 
 * lightly modified from Pololu's "continuous" library example, 
 * based in turn on the VL53L0X API, apparently
 * 
 * rgz 7-18-19
 */

#include <Wire.h>
#include <VL53L0X.h>

VL53L0X sensor;

void setup()
{
  Serial.begin(9600);
  Wire.begin();

  sensor.init();
  sensor.setTimeout(500);

  // Start continuous back-to-back mode (take readings as
  // fast as possible).  To use continuous timed mode
  // instead, provide a desired inter-measurement period in
  // ms (e.g. sensor.startContinuous(100)).
  sensor.startContinuous();
}

void loop()
{
  int val = sensor.readRangeContinuousMillimeters();

  if (val < 7000)
    Serial.println(val);
  if (sensor.timeoutOccurred()) {
    Serial.println(" TIMEOUT");
  }

}
