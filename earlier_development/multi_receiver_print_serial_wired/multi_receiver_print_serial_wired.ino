/*
   Data receiver: polls five Arduinos to gather remotely sensed ranger data

   The remote radios have addresses 0 to 4.

   Running software serial on pins 2 (receive), and 3 (transmit)

   forked from "multi_receiver_emit_MIDI," commit 36b6577, from Empathy Machine project:
      <https://github.com/robzach/Empathy_Machine/commit/36b6577669184089515cea703337ae30ae2d5122>
   which was adapted from "MultiTxAckPayload" by user Robin2 on Arduino.cc forum

   Robert Zacharias, rz@rzach.me, 7-18-19
*/

#include <SPI.h>
#include <SoftwareSerial.h>

// software serial constructor
const int RX_PIN = 2;
const int TX_PIN = 3;
SoftwareSerial wires(RX_PIN, TX_PIN);

const byte NUM_POLLED_DEVICES = 5;

int receivedData[NUM_POLLED_DEVICES] = { -1, -1, -1, -1, -1}; // to hold all read values

unsigned long prevMillis;
const unsigned long POLLING_INTERVAL = 1000; // milliseconds between polling

void setup() {
  wires.begin(9600);
  Serial.begin(9600);
}

void loop() {
  if (millis() - prevMillis >= POLLING_INTERVAL) {
    pollForData();
    SerialPrintData();
    prevMillis = millis();
  }
}

void pollForData() {
  // call each radio in turn
  for (int n = 0; n < NUM_POLLED_DEVICES; n++) {
    // transmit message "!n" where n is the number of the device to communicate with
    String msg = "!";
    msg += (String)n;
    wires.println(msg);
    Serial.println(msg);
    /*
        String inString = "";
        while (wires.available() > 0) {
          int inChar = wires.read();
          if (isDigit(inChar)) {
            // convert the incoming byte to a char and add it to the string:
            inString += (char)inChar;
          }
          // if you get a newline, print the string, then the string's value:
          if (inChar == '\n') {
            //      Serial.print("Value:");
            //      Serial.println(inString.toInt());
            int recv = inString.toInt();
            receivedData[n] = recv;
          }
        }
    */
    delay(50); // wait before transmitting next signal out
  }
}

void SerialPrintData() {
  for (int i = 0; i < NUM_POLLED_DEVICES; i++) {
    Serial.print(receivedData[i]);
    Serial.print('\t');
    if (i == (NUM_POLLED_DEVICES - 1)) Serial.println();
  }
}
