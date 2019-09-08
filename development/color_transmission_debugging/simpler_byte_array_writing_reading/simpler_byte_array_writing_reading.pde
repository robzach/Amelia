import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1410"; // for USB access to the Arduino

byte[] recdVals = new byte[5];

void setup () {
  // you can adjust height as wanted, and the graphs will scale appropriately
  size(1200, 500); 
  background(0);

printArray(recdVals);

  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil((byte)255);
}

void draw() {
  background(0);
  // dimmingRun(100); // use for diagnostic testing
  //redProximityDimming();
  delay(100);
  //int[] intarray = new int[5];
  //byte[] distVals = new byte[5];
  //for (int i = 0; i < 4; i++) intarray[i] = (i*50);
  //intarray[4] = 255;
  //for (int i = 0; i < 5; i++) distVals[i] = (byte)intarray[i];
  //myPort.write(distVals);

  int bignum = 250;
  byte transmit = (byte)bignum;
  myPort.write(transmit);
  myPort.write(130);
  myPort.write(200);
  myPort.write(0);
  myPort.write(255);
}

void serialEvent (Serial myPort) {
  if (myPort.available() > 0) { 
    //println(myPort.read());
    myPort.readBytesUntil((byte)255, recdVals);
    //recdVals = myPort.readBytes();
    int [] recdInts = new int[5];
    for (int i = 0; i < recdVals.length; i++) recdInts[i] = unsignedByteToInt(recdVals[i]);
      
    printArray(recdInts);
  }
}

int unsignedByteToInt (byte unsigned){
  if (unsigned < 128 && unsigned > -1) return unsigned;
  else return (unsigned + 256);
}
