/*
   Transmitter: does a local V53L0X ranging and transmits findings via software serial

   The remote radios have addresses 0 to 4.
   Read analog input pins to discover radio number, using this scheme:
   radio #| inputs grounded
   -------|----------------
   0      | none
   1      | A1
   2      | A2
   3      | A1 and A2
   4      | A3


   a fork of "multi_transmitter" from "Empathy Machine" project, commit 5a1137e:
      <https://github.com/robzach/Empathy_Machine/commit/5a1137ec3f7dec60e37fa79feb964c7cfc244845>
   V53L0X code adapted from Pololu's library examples

   Robert Zacharias, rz@rzach.me, 7-24-19

*/

#include <SPI.h>
#include <Wire.h>
#include <VL53L0X.h>
#include <SoftwareSerial.h>

const int ADDRESSPIN1 = A1;
const int ADDRESSPIN2 = A2;
const int ADDRESSPIN4 = A3;

// software serial constructor
const int RX_PIN = 2;
const int TX_PIN = 3;
SoftwareSerial wires(RX_PIN, TX_PIN);

VL53L0X sensor;

char ADDRESSMARKER = '!'; // wait to see this at the start of a signal
int address = -1; // the integer value of this device's address

void setup() {
  Serial.begin(9600);
  wires.begin(112500);

  // detect the address of this radio based on which address pins are tied to ground
  pinMode(ADDRESSPIN1, INPUT_PULLUP);
  pinMode(ADDRESSPIN2, INPUT_PULLUP);
  pinMode(ADDRESSPIN4, INPUT_PULLUP);
  delay(5); // let the inputs settle for a moment
  address = !digitalRead(ADDRESSPIN1) + (2 * (!digitalRead(ADDRESSPIN2))) +
            (4 * (!digitalRead(ADDRESSPIN4)));

  // report the address to serial monitor for debugging
  Serial.println((String)"radio address: " + address);

  Wire.begin();
  sensor.init();
  sensor.setTimeout(500);

  sensor.startContinuous();
}

void loop() {
  int distance = sensor.readRangeContinuousMillimeters();
  
  while (wires.available() > 0) {
    char buf[3];
    wires.readBytesUntil('\n', buf, 10);
    //    for (int i = 0; i < sizeof(buf) / sizeof(buf[0]); i++) {
    //      Serial.print("i, buf[i] ");
    //      Serial.print(i);
    //      Serial.print(", ");
    //      Serial.println(buf[i]);
    //    }

    // if received message starts with !N where N is this device's address
    if (buf[0] == '!' && buf[1] - '0' == address) {
      //      int distance = sensor.readRangeSingleMillimeters();
//      Serial.println("received data request, transmitting: " + (String)distance);
      Serial.print('#'); Serial.print(address); Serial.print(':');
      Serial.println(distance);
      wires.print('#'); wires.print(address); wires.print(':');
      wires.println(distance);
    }
  }
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
