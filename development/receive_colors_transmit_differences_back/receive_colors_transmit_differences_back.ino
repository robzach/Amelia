// updating 9-8-19 with byte-based serial communication


#include <PololuLedStrip.h>
#include <Wire.h>
#include <VL53L0X.h>

//#define HIGH_SPEED

const int LED_STRIP_PIN = 12; // WS2801 LED strip data line is plugged into this pin

PololuLedStrip<LED_STRIP_PIN> ledStrip;
const int LED_COUNT = 60;
rgb_color colors[LED_COUNT]; // Create a buffer for holding the colors (3 bytes per color).

const int NUM_SENSORS = 3;
const byte START_ADDRESS = 29; // first I2C address to provision (the rest will increment)
const long SERIAL_SPEED = 57600; // serial communication baud rate

const int DEBUGPIN1 = 10; // used for oscope monitoring of various events

const bool DEBUG = false;

bool newDataRecd = false;
int counter = 0;

// incoming color data from Processing:
// a sensor instruction byte, three color bytes 0–254 each, a checksum, and a 255 terminator
byte readIn[6];

// data to return to Processing:
// three sensor positions, a checksum, and a 255 terminator
byte sendData[5];



VL53L0X sensor[NUM_SENSORS];
int sensorValues[NUM_SENSORS] = {}; // values to transmit


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
    scanSensorsTransmitResponse();
    newDataRecd = false;
  }
}

void serialEvent() {
  while (Serial.available()) {
    readIn[counter] = Serial.read();
  }
  if (readIn[counter] == 255) { // terminator received
    if (checksumValid(readIn)) newDataRecd = true;
    counter = 0; // and reset counter

    // reply with checksum result followed by terminator
    //    Serial.write(checksumValid(readIn)); Serial.write(255);
    //    Serial.write(readIn, counter); // write values prior to terminator
    //    Serial.write(255); // and write a terminator at the end
  }
  else counter++; // otherwise, proceed through loop
}

void writeColorsToLEDs() {
  rgb_color color;
  color.green = readIn[1];
  color.red = readIn[2];
  color.blue = readIn[3];

  for (uint16_t i = 0; i < LED_COUNT; i++) colors[i] = color;

  // Write to the LED strip.
  // time to execute this write (with 60 LEDs) measured at ~4ms
  ledStrip.write(colors, LED_COUNT);
}

void scanSensorsTransmitResponse() {
  // scan only the sensors indicated by the zeroth byte received from Processing
  bool readSensor0 = readIn[0] & 0b1; // ones bit
  bool readSensor1 = (readIn[0] >> 1) & 0b1; // twos bit
  bool readSensor2 = (readIn[0] >> 2) & 0b1; // fours bit

//  readSensor0 = readSensor1 = readSensor2 = true;

  // array to hold values prior to reducing them to bytes
  int distVals[3];
  if (readSensor0) distVals[0] = sensor[0].readRangeSingleMillimeters();
  if (readSensor1) distVals[1] = sensor[1].readRangeSingleMillimeters();
  if (readSensor2) distVals[2] = sensor[2].readRangeSingleMillimeters();

//  for (int i = 0; i < 3; i++){
//    Serial.print(distVals[i]);
//    Serial.print(" "); 
//  } Serial.println();

  // slice millimeter values into 255 bins
  // assumes max meaningful distance is 500mm = 50cm
  for (int i = 0; i < 3; i++) {
    distVals[i] = map(constrain(distVals[i], 0, 500), 0, 500, 0, 254);
  }

  // buffer to hold values to write out, plus a checksum and a terminator at the end
  byte writeBuf[3 + 2] = {}; // need this to zero all values instead of holding over!!

  // load sliced values into byte array
  for (int i = 0; i < 3; i++) {
    writeBuf[i] = distVals[i];
  }

  // add checksum to penultimate position in writeBuf array
  for (int i = 0; i < 3; i++) {
    writeBuf[3] += (writeBuf[i] * (i + 1));
  } // checksum is computed: (0th data point + (1st data point * 2) + (2nd data point * 3) + ...)

  // finally, write value 255 to final position of array to serve as terminator
  writeBuf[3 + 1] = 255;

  Serial.write(writeBuf, 5);

  //
  //  for (int i = 0; i<5; i++){
  //    sendData[i] = writeBuf[i];
  //  }
  //
//    sendData[5] = 255; // last bit is terminator
}

// checksum should be at penultimate array position, and 255 (terminator) at the end
boolean checksumValid (byte * arrayIn) {
  // you can't run sizeof(array) because you just get the size of the pointer to that array
  // instead find the passed in array's length by finding the position of the 255 terminator
  int length = 0;
  while (arrayIn[length] < 255) length++;
  length++; // after above while() exits, length contains the index of the 255 value; increment to calculate length of array

  byte localChecksum = 0;
  // add zeroth through second-to-last element in incoming data
  for (int i = 0; i < length - 2; i++) {
    localChecksum += (arrayIn[i] * (i + 1));
  }

  // special case: change 255 checksum to 254
  if (localChecksum == 255) localChecksum = 254;

  //  localChecksum = arrayIn[0] + (arrayIn[1] * 2) + (arrayIn[2] * 3);

  // penultimate element of array is checksum, so compare to penultimate value read in for result
  return (localChecksum == arrayIn[length - 2]);
}
