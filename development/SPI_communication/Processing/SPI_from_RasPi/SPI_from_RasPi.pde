import processing.io.*;
SPI ard;
byte out1, out2;

void setup() {
  //printArray(SPI.list());
  ard = new SPI(SPI.list()[0]);
  ard.settings(500000, SPI.MSBFIRST, SPI.MODE0);
}

void draw() {
  out1++;
  out2++;

  byte[] out = { out1, out2 };

  byte[] in = ard.transfer(out);

  // val is between 0 and 1023
  printArray(in);
}     
