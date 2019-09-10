import processing.io.*;
SPI ard;
int out1; // int to transfer to Arduino
int r = 1;
int g = 2;
int b = 3;


// transfer: c 0 0 0 \n
// where the zeros are any desired value
// this is how you send the the color (0, 0, 0)

void setup() {
  //printArray(SPI.list());
  ard = new SPI(SPI.list()[0]);
  ard.settings(500000, SPI.MSBFIRST, SPI.MODE0);
}

void draw() {
  sendData();
  //out1++;
  //if (out1 == 256) out1 = 0;

  //byte[] in = ard.transfer(out1);
  //int val = in;

  // val is between 0 and 1023
  //printArray(in);
  
  delay(50);
}     

void sendData(){
  ard.transfer('c');
  delay(1);
  ard.transfer(r);
   delay(1);
  ard.transfer(g);
   delay(1);
  ard.transfer(b);
   delay(1);
  //ard.transfer('\n');
  byte[] in = ard.transfer('\n');
  printArray(in);
  r++;
  if (r == 256) r = 0;
  g++;
  if (g == 256) g = 0;
  b++;
  if (b == 256) b = 0;
}
