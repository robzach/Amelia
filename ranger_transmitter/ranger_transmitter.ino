/*
   Radio transmitter: does a local V53L0X ranging and transmits findings

   The remote radios have addresses 00000 to 00004 and each will
   transmit an array of two integers in their "acknowledge payload"

   Uses NRF24L01 transceiver module to repeatedly receive remote analog data.

   radio pin    Arduino Uno/Nano pin    Arduino Micro pin
   VCC          3.3V                    3.3V
   GND          GND                     GND
   CE           7                       7
   CSN          8                       8
   MOSI         11                      MO
   MISO         12                      MI
   SCK          13                      SCK


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
#include <nRF24L01.h>
#include <RF24.h>
#include <Wire.h>
#include <VL53L0X.h>

const int ADDRESSPIN1 = A1;
const int ADDRESSPIN2 = A2;
const int ADDRESSPIN4 = A3;

const int CE_PIN = 7;
const int CSN_PIN = 8;

RF24 radio(CE_PIN, CSN_PIN);
VL53L0X sensor;

char dataReceived[2]; // size of the data to receive (only one character)
int ackData[2] = { -10, -10}; // the two values to be transmitted

void setup() {
  Serial.begin(9600);

  // detect the address of this radio based on which address pins are tied to ground
  pinMode(ADDRESSPIN1, INPUT_PULLUP);
  pinMode(ADDRESSPIN2, INPUT_PULLUP);
  pinMode(ADDRESSPIN4, INPUT_PULLUP);
  delay(5); // let the inputs settle for a moment
  byte address = !digitalRead(ADDRESSPIN1) + (2 * (!digitalRead(ADDRESSPIN2))) +
                 (4 * (!digitalRead(ADDRESSPIN4)));
  byte transmitterAddress[5] = {0, 0, 0, 0, address}; // set up transmitter

  // report the address to serial monitor for debugging
  String printableAddress = "";
  for (int i = 0; i<sizeof(transmitterAddress)/sizeof(transmitterAddress[0]); i++){
    printableAddress += transmitterAddress[i];
  }
  Serial.println((String)"radio address: " + printableAddress);

  Wire.begin();
  sensor.init();
  sensor.setTimeout(500);

  radio.begin();
  radio.setDataRate( RF24_250KBPS );
  radio.openReadingPipe(1, transmitterAddress);
  radio.enableAckPayload();
  radio.startListening();
  radio.writeAckPayload(1, &ackData, sizeof(ackData)); // pre-load data
}

void loop() {
  int distance = sensor.readRangeSingleMillimeters();
  if (distance < 7000) Serial.println(distance);
  
  if ( radio.available() ) { // if incoming data received
    radio.read( &dataReceived, sizeof(dataReceived) );

    ackData[0] = -10; // -10 will stand in for a positive ack signal for now
    ackData[1] = distance;

    radio.writeAckPayload(1, &ackData, sizeof(ackData)); // load the payload for the next time
  }
}
