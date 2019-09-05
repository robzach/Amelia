#include <PololuLedStrip.h>
#include <Wire.h>
#include <VL53L0X.h>

const int LED_STRIP_PIN = 12; // WS2801 LED strip data line is plugged into this pin

PololuLedStrip<LED_STRIP_PIN> ledStrip;
const int LED_COUNT = 60;
rgb_color colors[LED_COUNT]; // Create a buffer for holding the colors (3 bytes per color).

const int NUM_SENSORS = 4;
const byte START_ADDRESS = 29; // first I2C address to provision (the rest will increment)
const long SERIAL_SPEED = 9600; // serial communication baud rate

bool transmitNow = false;
const bool DEBUG = false;

VL53L0X sensor[NUM_SENSORS];


void setup() {
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
  }
}

void loop()
{
  if (transmitNow) writeSensorValuesOut();
  readLEDColorIn();
}

void writeSensorValuesOut() {

  //potentially replace this whole function with a delay to see where it becomes problematic

  
  for (int i = 0; i < NUM_SENSORS; i++) {
    Serial.print(sensor[i].readRangeSingleMillimeters());
    if (sensor[i].timeoutOccurred() && DEBUG) {
      Serial.print(" TIMEOUT");
    }
    if (i != NUM_SENSORS - 1) Serial.print(' '); // space delimit between values
  }
  Serial.println();
  transmitNow = false; // switch flag to not send data
}

void readLEDColorIn() {
  if (Serial.available())
  {

    // receive a four-byte array (three values, a delimiter at the end)
    byte buf[4];
    Serial.readBytesUntil('\n', buf, 4);
    rgb_color color;
    color.red = buf[0];
    color.green = buf[1];
    color.blue = buf[2];

    


    // Read the color from the computer.
    //      rgb_color color;
    //      color.red = inString.parseInt();
    //      color.green = Serial.parseInt();
    //      color.blue = Serial.parseInt();

    if (color.red != color.green || color.red != color.blue || color.green != color.blue) {
      Serial.print("unequal values, r,g,b: ");
      Serial.print(color.red);
      Serial.print(", ");
      Serial.print(color.green);
      Serial.print(", ");
      Serial.println(color.blue);
    }

    // Update the colors buffer.
    for (uint16_t i = 0; i < LED_COUNT; i++)
    {
      colors[i] = color;
    }

    // Write to the LED strip.
    ledStrip.write(colors, LED_COUNT);

    transmitNow = true; // switch flag to send data

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
