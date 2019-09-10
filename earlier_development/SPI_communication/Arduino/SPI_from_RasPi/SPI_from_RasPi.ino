#include <SPI.h>

void setup() {
  Serial.begin(9600);
  SPI.begin();
}

void loop() {
  int doubled = SPI.transfer(0) * 2;
}
