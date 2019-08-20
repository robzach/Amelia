/*
   Data receiver: polls five Arduinos to gather remotely sensed ranger data

   The remote radios have addresses 0 to 4.

   Running software serial on pins 2 (receive), and 3 (transmit)

   Robert Zacharias, rz@rzach.me, 7-24-19
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
  wires.begin(112500);
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

  // call each device in turn
  for (int n = 0; n < NUM_POLLED_DEVICES; n++) {
    // transmit message "!n" where n is the number of the device to communicate with
    wires.print('!'); wires.println(n);

    // until data comes, keep waiting, up to 50 milliseconds
    for (int i = 0; i < 50; i++) {
      if (wires.peek() == -1) delay(1);
      else break;
    }

    if (wires.available() > 0) {
      char buf[10];
      wires.readBytesUntil('\n', buf, 10);
      // expecting #n:1234 where n is the device address and 1234 is the distance data
      if (buf[0] == '#' && buf[1] - '0' == n && buf[2] == ':') {
        // load subset into new char array to run atoi on it
        char distanceData[7];
        for (int i = 0; i < 6; i++) {
          distanceData[i] = buf[i + 3];
        }
        Serial.print("received data = "); Serial.println(distanceData);
        receivedData[n] = atoi(distanceData);
      }
    }
        delay(200); // wait before transmitting next signal out
  }
}

void SerialPrintData() {
  for (int i = 0; i < NUM_POLLED_DEVICES; i++) {
    Serial.print(receivedData[i]);
    Serial.print('\t');
    if (i == (NUM_POLLED_DEVICES - 1)) Serial.println();
  }
}
