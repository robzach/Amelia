/*
   Data receiver: polls five Arduinos to gather remotely sensed ranger data
   sends short 10µs pulse at intervals to trigger remote devices to transmit back to it

   The remote devices have addresses 0 to 4.

   Running software serial on pins 5 (receive), and 6 (transmit)

   Robert Zacharias, rz@rzach.me, 7-25-19
*/

#include <SPI.h>
#include <SoftwareSerial.h>

// software serial constructor
const int RX_PIN = 5;
const int TX_PIN = 6;
SoftwareSerial wires(RX_PIN, TX_PIN);

const long DATA_RATE = 19200; // baud rate for serial transmissions through wire

const byte NUM_POLLED_DEVICES = 5;
int receivedData[NUM_POLLED_DEVICES] = { -1, -1, -1, -1, -1}; // to hold all read values
char out[50];

unsigned long prevMillis;
const unsigned long TIMEOUTWAIT = 20; // milliseconds to wait for a response from a device
unsigned long timeoutTimer;
unsigned long REQUEST_INTERVAL = 1000; // milliseconds between request cycles

void setup() {
  wires.begin(DATA_RATE);
  wires.setTimeout(5); // wait only very briefly for a \n if one's missing
  Serial.begin(9600);
}

void loop() {
  if (millis() - prevMillis >= REQUEST_INTERVAL) {
    prevMillis = millis();
  }


  for (int n = 0; n < NUM_POLLED_DEVICES; n++){
    // send out call to device n, wait for response
    // first, transmit @n
    char cmd[5] = {0};
    strcat(cmd, "@");
    char * num = itoa(n, num, 10);
    strcat(cmd, num);
    wires.println(cmd);
    // determine when listening should timeout
    timeoutTimer = millis() + TIMEOUTWAIT;
    
    // until that timeout arrives, record 
    while (millis() < 
    
    Serial.println(cmd);


    
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

void SerialPrintData() {
  for (int i = 0; i < NUM_POLLED_DEVICES; i++) {
    Serial.print(receivedData[i]);
    Serial.print('\t');
    if (i == (NUM_POLLED_DEVICES - 1)) Serial.println();
  }
}
