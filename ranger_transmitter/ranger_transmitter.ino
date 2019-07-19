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


LOADS OF TO DOS:

  * read analog input pins to discover radio number, using this scheme:
   radio #| inputs grounded
   -------|----------------
   0      | none
   1      | A1
   2      | A2
   3      | A1 and A2
   4      | A3

   * do not do analogReads; instead use V53L0X library to read sensor
      and report that data


   a fork of "multi_transmitter" from "Empathy Machine" project, commit 5a1137e:
      <https://github.com/robzach/Empathy_Machine/commit/5a1137ec3f7dec60e37fa79feb964c7cfc244845>
   adapted from "SimpleRxAckPayload" by user Robin2 on Arduino.cc forum
   Robert Zacharias, rz@rzach.me, 7-18-19
   
*/

// comment out one of the two below to select which radio you're programming
#define TRANSMITTER_NUM 1 // transmit proximity & accelerometer data
//#define TRANSMITTER_NUM 2 // transmit force-sensitive resistor data

#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

const int SENSOR1 = A0;
const int SENSOR2 = A1;

const byte THIS_TRANSMITTER_ADDRESS[5] = {0, 0, 0, 0, TRANSMITTER_NUM}; // transmits FSR data

const int CE_PIN = 7;
const int CSN_PIN = 8;

RF24 radio(CE_PIN, CSN_PIN);

char dataReceived[2]; // size of the data to receive (only one character)
int ackData[2] = {-1, -1}; // the two values to be transmitted

void setup() {
  radio.begin();
  radio.setDataRate( RF24_250KBPS );
  radio.openReadingPipe(1, THIS_TRANSMITTER_ADDRESS);
  radio.enableAckPayload();
  radio.startListening();
  radio.writeAckPayload(1, &ackData, sizeof(ackData)); // pre-load data

  pinMode(SENSOR1, INPUT);
  pinMode(SENSOR2, INPUT);
}

void loop() {
  if ( radio.available() ) { // if incoming data received
    radio.read( &dataReceived, sizeof(dataReceived) );
    
    ackData[0] = analogRead(SENSOR1);
    ackData[1] = analogRead(SENSOR2);

    radio.writeAckPayload(1, &ackData, sizeof(ackData)); // load the payload for the next time
  }
}
