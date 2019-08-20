/*
   Transmitter: does a local V53L0X ranging and transmits findings via software serial
   when triggered by a pulse signal

   The remote devices have addresses 0 to 4.
   Read analog input pins to discover radio number, using this scheme:
   radio #| inputs grounded
   -------|----------------
   0      | none
   1      | A1
   2      | A2
   3      | A1 and A2
   4      | A3

   V53L0X code adapted from Pololu's library examples

   Robert Zacharias, rz@rzach.me, 7-25-19

*/

#include <SPI.h>
#include <Wire.h>
#include <VL53L0X.h>
#include <SoftwareSerial.h>

const int ADDRESSPIN1 = A1;
const int ADDRESSPIN2 = A2;
const int ADDRESSPIN4 = A3;
const int PULSE_PIN = 2; // digital pulse on this pin will trigger a timed response

volatile unsigned long pulseReceivedTime; // the time when the trigger pulse was received
volatile bool alreadySent = true; // has the message already been sent?

const int WAIT_INTERVAL = 40; // gap in milliseconds between consecutive device transmissions
unsigned long waitToTransmit; // the time this device will wait before sending its data

const long DATA_RATE = 19200; // baud rate for serial transmissions through wire

// software serial constructor
const int RX_PIN = 5;
const int TX_PIN = 6;
SoftwareSerial wires(RX_PIN, TX_PIN);

VL53L0X sensor;

int address = -1; // the integer value of this device's address

void setup() {
  Serial.begin(9600);
  wires.begin(DATA_RATE);

  attachInterrupt(digitalPinToInterrupt(PULSE_PIN), markTime, FALLING);

  // detect the address of this radio based on which address pins are tied to ground
  pinMode(ADDRESSPIN1, INPUT_PULLUP);
  pinMode(ADDRESSPIN2, INPUT_PULLUP);
  pinMode(ADDRESSPIN4, INPUT_PULLUP);
  delay(5); // let the inputs settle for a moment
  address = !digitalRead(ADDRESSPIN1) + (2 * (!digitalRead(ADDRESSPIN2))) +
            (4 * (!digitalRead(ADDRESSPIN4)));

  waitToTransmit = address * WAIT_INTERVAL; // wait WAIT_INTERVAL(ms) * (address) before transmitting

  // report the address to serial monitor for debugging
  Serial.println((String)"device address: " + address);

  Wire.begin();
  sensor.init();
  sensor.setTimeout(500);

  sensor.startContinuous();
}

void loop() {
  int distance = sensor.readRangeContinuousMillimeters();

  // if a message hasn't already been sent, and it's waited long enough to send it, send it
  if (!alreadySent && (millis() >= (pulseReceivedTime + waitToTransmit))) {
    Serial.print('#'); Serial.print(address); Serial.print(':');
    Serial.println(distance);
    wires.print('#'); wires.print(address); wires.print(':');
    wires.println(distance);
    alreadySent = true;
  }
}

void markTime() {
  pulseReceivedTime = millis();
  alreadySent = false;
}


// graveyard

//    Serial.println(buf);
//    if (isDigit(inChar)) {
// convert the incoming byte to a char and add it to the string:
//    inString += inChar;
//    }
// if you get a newline, print the string, then the string's value:
//    if (inChar == '\n') {
//      Serial.print("Value:");
//      Serial.println(inString.toInt());
//      int recv = inString.toInt();
//      Serial.println(inString);


//    int res = wires.read();
//    if (res == '!') Serial.println("saw a bang");
//    Serial.println(res);

//    String inString = wires.read(); // load value into inString
//    if (inString.charAt(0) == "!") {
//      int address = inString.charAt(1).toInt();
//      Serial.println(address);
//    }
//    int address;
//    if (inChar == '!') address = wires.read(); // store next one
//    Serial.println(address);


//    if (isDigit(inChar)) {
//      // convert the incoming byte to a char and add it to the string:
//      inString += (char)inChar;
//    }
//    // if you get a newline, print the string, then the string's value:
//    if (inChar == '\n') {
//      //      Serial.print("Value:");
//      //      Serial.println(inString.toInt());
//      int recv = inString.toInt();
//      receivedData[n] = recv;
//    }
//}


//  if ( wires.available() ) { // if incoming data received
//    char recv[10]; // empty character array to hold received data
//    for (int i = 0; i<wires.available(); i++){ // in form !N where N is a value
//      recv[i] = wires.available();
//    }
//    Serial.println(recv);
//    char inVal[10] = wires.readStringUntil('\n');
//    Serial.println("inVal = " + inVal);
//    Serial.print("inVal in binary: ");
//    Serial.write(inVal);
//    Serial.print("; targetHeader in binary: ");
//    Serial.write(targetHeader);
//    Serial.println();
//    if (inVal.equals(targetHeader)) { // if this is the correct recipient
//      Serial.println("request received");
//      int distance = sensor.readRangeSingleMillimeters();
//      Serial.println("received data request, transmitting: " + (String)distance);
//      wires.println(distance);
//    }
//  }


/*
  if ( wires.available() ) { // if incoming data received
  char * inVal = wires.available().c_str();
  //    char * inVal = wires.readStringUntil('\n').c_str();
  Serial.println(inVal);
  if (inVal[0] == ADDRESSMARKER) { // if first character was !
    //      Serial.println("    atoi(inVal.charAt(1)) = " + (String)atoi(inVal.charAt(1)));
    if (inVal[1] == (char)transmitterAddress) { // if this is the device being addressed
      Serial.println("request received");
      int distance = sensor.readRangeSingleMillimeters();
      Serial.println("received data request, transmitting: " + (String)distance);
      wires.println(distance);
    }
  }
  }
*/
