// updating 9-8-19 with byte-based serial communication


#include <PololuLedStrip.h>
#include <Wire.h>
#include <VL53L0X.h>

//#define HIGH_SPEED

const int LED_STRIP_PIN = 12; // WS2801 LED strip data line is plugged into this pin

PololuLedStrip<LED_STRIP_PIN> ledStrip;
const int LED_COUNT = 60;
rgb_color colors[LED_COUNT]; // Create a buffer for holding the colors (3 bytes per color).

const int NUM_SENSORS = 4;
const byte START_ADDRESS = 29; // first I2C address to provision (the rest will increment)
const long SERIAL_SPEED = 9600; // serial communication baud rate

const int DEBUGPIN1 = 10; // used for oscope monitoring of various events

const bool DEBUG = false;

bool newDataRecd = false;
int counter = 0;

// incoming color data from Processing:
// three color bytes 0–254 each, a checksum, and a 255 terminator
byte readIn[5];

VL53L0X sensor[NUM_SENSORS];


void setup() {
  Serial.begin(SERIAL_SPEED);
  Wire.begin();

  pinMode(DEBUGPIN1, OUTPUT);
  digitalWrite(DEBUGPIN1, LOW);

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

#if defined HIGH_SPEED
    // reduce timing budget to 20 ms (default is about 33 ms)
    sensor[i].setMeasurementTimingBudget(20000);
#elif defined HIGH_ACCURACY
    // increase timing budget to 200 ms
    sensor[i].setMeasurementTimingBudget(200000);
#endif
  }
}

void loop() {
  // the serial event catches incoming color data and flips newDataRecd true
  if (newDataRecd) {
    writeColorsToLEDs();
    writeSensorValuesOut();
    newDataRecd = false;
  }
}

void serialEvent() {
  while (Serial.available()) {
    digitalWrite(DEBUGPIN1, HIGH);
    readIn[counter] = Serial.read();
  }
  if (readIn[counter] == 255) { // terminator received
    if (checksumValid(readIn)) newDataRecd = true;

    // reply with checksum result followed by terminator
    //    Serial.write(checksumValid(readIn)); Serial.write(255);
    //    Serial.write(readIn, counter); // write values prior to terminator
    //    Serial.write(255); // and write a terminator at the end

    counter = 0; // and reset counter
  }
  else counter++; // otherwise, proceed through loop
      digitalWrite(DEBUGPIN1, LOW);

}

void writeColorsToLEDs() {
  rgb_color color;
  color.red = readIn[0];
  color.green = readIn[1];
  color.blue = readIn[2];

  for (uint16_t i = 0; i < LED_COUNT; i++) colors[i] = color;

  // Write to the LED strip.
  // time to execute this write (with 60 LEDs) measured at ~4ms
  ledStrip.write(colors, LED_COUNT);
}

void writeSensorValuesOut() {

  // array to hold values prior to reducing them to bytes
  int distVals[NUM_SENSORS];

  // time to do these four reads is consistently ~133ms!!!!! Major bottleneck located…
  // adjusting to faster I2C speed via command `Wire.setClock(400000L);` shaves only ~11ms
  // and running `#define HIGH_SPEED` only gets down to ~90ms total, which is still quite long
  // reading only 1 sensor takes ~24ms
  // reading 2 sensors takes ~47ms
  // reading 3 sensors takes ~70ms
  // and reading 4 sensors takes ~90ms, as observed previously
  // read sensors, load into integer array
  for (int i = 0; i < NUM_SENSORS; i++) {
    distVals[i] = sensor[i].readRangeSingleMillimeters();
  }

  // slice millimeter values into 255 bins
  // assumes max meaningful distance is 500mm = 50cm
  for (int i = 0; i < NUM_SENSORS; i++) {
    distVals[i] = map(constrain(distVals[i], 0, 500), 0, 500, 0, 254);
  }

  // buffer to hold values to write out, plus a checksum and a terminator at the end
  byte writeBuf[NUM_SENSORS + 2] = {}; // need this to zero all values instead of holding over!!

  // load sliced values into byte array
  for (int i = 0; i < NUM_SENSORS; i++) {
    writeBuf[i] = distVals[i];
  }

  // add checksum to penultimate position in writeBuf array
  for (int i = 0; i < NUM_SENSORS; i++) {
    writeBuf[NUM_SENSORS] += (writeBuf[i] * (i + 1));
  } // checksum is computed: (0th data point + (1st data point * 2) + (2nd data point * 3) + ...)

  // finally, write value 255 to final position of array to serve as terminator
  writeBuf[NUM_SENSORS + 1] = 255;

  // transmit array
  // this appears only to take 2ms according to the scope, though it should take ~6ms at 9600 baud
  Serial.write(writeBuf, NUM_SENSORS + 2);

  // transmit plain text for debugging
  //  for (int i = 0; i < sizeof(writeBuf) / sizeof(writeBuf[0]); i++) {
  //    Serial.print(writeBuf[i]);
  //    Serial.print(" ");
  //  }
  //  Serial.println();
}

boolean checksumValid (byte * arrayIn) {
  int length = sizeof(arrayIn) / sizeof(arrayIn[0]); // this isn't working, don't know why
  byte localChecksum = 0;

  // add zeroth through pen-penultimate element in incoming data
  //    for (int i = 0; i < length - 2; i++) {
  //      localChecksum += (arrayIn[i] * (i + 1));
  //    }

  localChecksum = arrayIn[0] + (arrayIn[1] * 2) + (arrayIn[2] * 3);

  // penultimate element of array is checksum, so compare to penultimate value read in for result
  return (localChecksum == arrayIn[3]);
}
