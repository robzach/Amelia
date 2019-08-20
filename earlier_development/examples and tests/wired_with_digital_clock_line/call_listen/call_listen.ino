/*
   Data receiver: polls five Arduinos to gather remotely sensed ranger data
   sends short 10µs pulse at intervals to trigger remote devices to transmit back to it

   The remote devices have addresses 0 to 4.

   Running software serial on pins 2 (receive), and 3 (transmit)

   Robert Zacharias, rz@rzach.me, 7-25-19
*/

#include <SPI.h>
#include <SoftwareSerial.h>

// software serial constructor
const int RX_PIN = 5;
const int TX_PIN = 6;
SoftwareSerial wires(RX_PIN, TX_PIN);

const int PULSE_PIN = 2; // hardware pin to pulse to receiving units
const int PULSE_WIDTH = 10; // pulse width in microseconds
const int PULSE_INTERVAL = 200; // interval between pulses in milliseconds

const long DATA_RATE = 19200; // baud rate for serial transmissions through wire

const byte NUM_POLLED_DEVICES = 5;

int receivedData[NUM_POLLED_DEVICES] = { -1, -1, -1, -1, -1}; // to hold all read values
char out[50];

unsigned long prevMillis;
unsigned long startOfListening;

void setup() {
  wires.begin(DATA_RATE);
  wires.setTimeout(5); // wait only very briefly for a \n if one's missing
  Serial.begin(9600);
  pinMode(PULSE_PIN, OUTPUT);
  digitalWrite(PULSE_PIN, LOW);
}

void loop() {
  if (millis() - prevMillis >= PULSE_INTERVAL) {
    requestData();
    prevMillis = millis();
  }

  // "show me everything" serial feedback
  //  if (wires.available()) Serial.write(wires.read());


  char buf[50] = {0}; // buffer to hold incoming character array
  if (wires.available() > 0) {
    wires.readBytesUntil('\n', buf, 50); // read stream into buffer

    // if first character is # and third is :
    if (buf[0] == '#' && buf[2] == ':') {
      int n = buf[1] - '0'; // read character in between # and :

      // load a copy of the array, but only digits after the :
      char distanceData[7] = { -1};
      for (int i = 0; i < 6; i++) {
        if (isDigit(buf[i + 3])) distanceData[i] = buf[i + 3];
      }
      int dist = atoi(distanceData); // turn the char array into an int

      // load that dist data into the larger array in the right spot
      receivedData[n] = dist;

      SerialPrintData();
    }
  }

}

void requestData() {
  // send pulse to trigger beginning of devices' responses
  digitalWrite(PULSE_PIN, HIGH);
  delayMicroseconds(PULSE_WIDTH);
  digitalWrite(PULSE_PIN, LOW);

}

void SerialPrintData() {
  for (int i = 0; i < NUM_POLLED_DEVICES; i++) {
    Serial.print(receivedData[i]);
    Serial.print('\t');
    if (i == (NUM_POLLED_DEVICES - 1)) Serial.println();
  }
}
