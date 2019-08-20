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
   radio code adapted from "SimpleRxAckPayload" by user Robin2 on Arduino.cc forum
   V53L0X code adapted from Pololu's library examples

   Robert Zacharias, rz@rzach.me, 7-18-19

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
int transmitterAddress; // this device's address (0 to 4)

void setup() {
  Serial.begin(9600);
  wires.begin(9600);

  // detect the address of this radio based on which address pins are tied to ground
  pinMode(ADDRESSPIN1, INPUT_PULLUP);
  pinMode(ADDRESSPIN2, INPUT_PULLUP);
  pinMode(ADDRESSPIN4, INPUT_PULLUP);
  delay(5); // let the inputs settle for a moment
  byte address = !digitalRead(ADDRESSPIN1) + (2 * (!digitalRead(ADDRESSPIN2))) +
                 (4 * (!digitalRead(ADDRESSPIN4)));
  transmitterAddress = address; // set up transmitter

  // report the address to serial monitor for debugging
  Serial.println((String)"radio address: " + transmitterAddress);

  Wire.begin();
  sensor.init();
  sensor.setTimeout(500);
}

void loop() {
  //  if (distance < 7000) Serial.println(distance);

  if ( wires.available() ) { // if incoming data received
    String inVal = wires.readStringUntil('\n');
    Serial.println("inVal = " + inVal);
    if (inVal.charAt(0) == ADDRESSMARKER) { // if first character was !
      Serial.println("    atoi(inVal.charAt(1)) = " + (String)atoi(inVal.charAt(1)));
      if (atoi(inVal.charAt(1)) == transmitterAddress) { // if this is the device being addressed
        Serial.println("request received");
        int distance = sensor.readRangeSingleMillimeters();
        Serial.println("received data request, transmitting: " + (String)distance);
        wires.println(distance);
      }
    }
  }

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
}
