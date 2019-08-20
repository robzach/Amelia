/*
    Multiple VL53L0X sensors all read via shared I2C bus.

    Values are reported, tab delimited, via serial port.

    Each sensor's wiring:

      VCC to Arduino 5V
      GND to Arduino ground
      SCL to Arduino A5
      SDA to Arduino A4
      XSHUT incrementally starting at Arduino digital pin 2
      (first sensor wires XSHUT to Arduino pin 2, second sensor wires XSHUT to Arduino pin 3, etc.)

  Based on Pololu's VL53L0X example code; their original text below:

  "This example shows how to get single-shot range
  measurements from the VL53L0X. The sensor can optionally be
  configured with different ranging profiles, as described in
  the VL53L0X API user manual, to get better performance for
  a certain application. This code is based on the four
  "SingleRanging" examples in the VL53L0X API.
  The range readings are in units of mm."

  Robert Zacharias, 8-7-19

*/

#include <Wire.h>
#include <VL53L0X.h>

const int NUM_SENSORS = 4;
const byte START_ADDRESS = 29; // first I2C address to provision (the rest will increment)
const long SERIAL_SPEED = 9600; // serial communication baud rate

const bool DEBUG = false; // set to true for some serial debugging messages

VL53L0X sensor[NUM_SENSORS];


// Uncomment this line to use long range mode. This
// increases the sensitivity of the sensor and extends its
// potential range, but increases the likelihood of getting
// an inaccurate reading because of reflections from objects
// other than the intended target. It works best in dark
// conditions.

//#define LONG_RANGE


// Uncomment ONE of these two lines to get
// - higher speed at the cost of lower accuracy OR
// - higher accuracy at the cost of lower speed

//#define HIGH_SPEED
//#define HIGH_ACCURACY


void setup()
{
  Serial.begin(SERIAL_SPEED);
  Wire.begin();

  // set up Arduino output pins to connect with each sensor's XSHUT (shutdown) input
  for (int i = 0; i < NUM_SENSORS; i++) {
    pinMode(i + 2, OUTPUT); // start at digital pin 2 and increment from there
    digitalWrite(i + 2, LOW); // shut down all the sensors to start with
  }

  // initialize each sensor individually
  for (int i = 0; i < NUM_SENSORS; i++) {

    digitalWrite(i + 2, HIGH); // turn them on one at a time
    delay(100); // wait a bit to ensure that sensor is ready to receive an instruction

    // assign a new address to that sensor
    sensor[i].init();
    sensor[i].setTimeout(500);
    sensor[i].setAddress(i + START_ADDRESS);
    if (DEBUG) Serial.println((String)"sensor: " + i + ", address: " + (i + START_ADDRESS));

#if defined LONG_RANGE
    // lower the return signal rate limit (default is 0.25 MCPS)
    sensor[i].setSignalRateLimit(0.1);
    // increase laser pulse periods (defaults are 14 and 10 PCLKs)
    sensor[i].setVcselPulsePeriod(VL53L0X::VcselPeriodPreRange, 18);
    sensor[i].setVcselPulsePeriod(VL53L0X::VcselPeriodFinalRange, 14);
#endif

#if defined HIGH_SPEED
    // reduce timing budget to 20 ms (default is about 33 ms)
    sensor[i].setMeasurementTimingBudget(20000);
#elif defined HIGH_ACCURACY
    // increase timing budget to 200 ms
    sensor[i].setMeasurementTimingBudget(200000);
#endif
  }
}

void loop()
{
  for (int i = 0; i < NUM_SENSORS; i++) {
    Serial.print(sensor[i].readRangeSingleMillimeters());
    if (sensor[i].timeoutOccurred() && DEBUG) {
      Serial.print(" TIMEOUT");
    }
    if (i != NUM_SENSORS - 1) Serial.print('\t'); // tab delimit between values
  }
  Serial.println();
}
