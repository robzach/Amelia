/*
    Multiple VL53L0X sensors are read via shared I2C bus; this is a data input to the device.
    It also has a short length of addressable RGB LED strip on it, which is a data output.

    Distance input information:

        Distance values are reported, space-delimited, via serial port. Sample data looks like:

        263 307 144 8190

        Note that the value 8190 is what the sensor typically reports when the target surface
        is out of range.

        Each VL53L0X sensor's wiring:

          VCC to Arduino 5V (red wire)
          GND to Arduino ground (black wire)
          SCL to Arduino A5 (yellow wire)
          SDA to Arduino A4 (white wire)
          XSHUT incrementally starting at Arduino digital pin 2 (brown wire)
          (first sensor wires XSHUT to Arduino pin 2, second sensor wires XSHUT to Arduino pin 3, etc.)

        Based on Pololu's VL53L0X example code; their original text below:

        "This example shows how to get single-shot range
        measurements from the VL53L0X. The sensor can optionally be
        configured with different ranging profiles, as described in
        the VL53L0X API user manual, to get better performance for
        a certain application. This code is based on the four
        "SingleRanging" examples in the VL53L0X API.
        The range readings are in units of mm."

    LED output information:

        The LED strip is wired VCC to the Arduino's 5V; ground to the Arduino's ground; and
        the signal pin goes to Arduino pin 12.

        Incoming data comes in the form "R,G,B" and must be delimited (though it need not be
        comma delimited necessarily). The serial to int process relies on parseInt, which can be blocking,
        so I might need to work on it.

        The logic is drawn straight from Pololu's example sketch, "LedStripColorTester."

  Robert Zacharias, 8-12-19

*/

#include <Wire.h>
#include <VL53L0X.h>
#include <PololuLedStrip.h>

const int NUM_SENSORS = 4;
const byte START_ADDRESS = 29; // first I2C address to provision (the rest will increment)
const long SERIAL_SPEED = 9600; // serial communication baud rate
const int LED_STRIP_PIN = 12; // WS2801 LED strip data line is plugged into this pin

// Set this bool to true for some serial debugging messages
// (Note: these messages will clutter the serial feedback, probably making it unreadable
// to software that's parsing out the returned distance values.)
const bool DEBUG = false;

PololuLedStrip<LED_STRIP_PIN> ledStrip;
const int LED_COUNT = 60;
rgb_color colors[LED_COUNT]; // Create a buffer for holding the colors (3 bytes per color).

VL53L0X sensor[NUM_SENSORS];


// Uncomment the below #define to use long range mode. This
// increases the sensitivity of the sensor and extends its
// potential range, but increases the likelihood of getting
// an inaccurate reading because of reflections from objects
// other than the intended target. It works best in dark
// conditions.

//#define LONG_RANGE


// Uncomment ONE of these two #defines to get
// - higher speed at the cost of lower accuracy OR
// - higher accuracy at the cost of lower speed

//#define HIGH_SPEED
//#define HIGH_ACCURACY


void setup()
{
  Serial.begin(SERIAL_SPEED);
  Serial.setTimeout(100); // only wait 100 milliseconds to parse malformed input
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
  writeSensorValuesOut();
  readLEDColorIn();
}

void writeSensorValuesOut() {
  for (int i = 0; i < NUM_SENSORS; i++) {
    Serial.print(sensor[i].readRangeSingleMillimeters());
    if (sensor[i].timeoutOccurred() && DEBUG) {
      Serial.print(" TIMEOUT");
    }
    if (i != NUM_SENSORS - 1) Serial.print(' '); // space delimit between values
  }
  Serial.println();
}

void readLEDColorIn() {
  if (Serial.available())
  {
    char c = Serial.peek();
    if (!(c >= '0' && c <= '9'))
    {
      Serial.read(); // Discard non-digit character
    }
    else
    {
      // Read the color from the computer.
      rgb_color color;
      color.red = Serial.parseInt();
      color.green = Serial.parseInt();
      color.blue = Serial.parseInt();

      // Update the colors buffer.
      for (uint16_t i = 0; i < LED_COUNT; i++)
      {
        colors[i] = color;
      }

      // Write to the LED strip.
      ledStrip.write(colors, LED_COUNT);

      if (DEBUG) {
        Serial.print("Showing color: ");
        Serial.print(color.red);
        Serial.print(",");
        Serial.print(color.green);
        Serial.print(",");
        Serial.println(color.blue);
      }
    }
  }
}
