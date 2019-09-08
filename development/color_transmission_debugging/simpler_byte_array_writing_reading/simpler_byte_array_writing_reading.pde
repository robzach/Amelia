import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1410"; // for USB access to the Arduino

byte[] recdVals = new byte[5];
int [] recdInts = new int[5];


void setup () {
  // you can adjust height as wanted, and the graphs will scale appropriately
  size(1200, 500); 
  background(0);

  printArray(recdVals);

  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a 255 (terminator) byte:
  myPort.bufferUntil((byte)255);
}

void draw() {
  background(0);


  int[] sendVals = new int[3];
  sendVals[0] = 14;
  sendVals[1] = 200;
  sendVals[2] = 253;

  transmitBytes(sendVals);


  //int bignum = 250;
  //byte transmit = (byte)bignum;
  //myPort.write(transmit);
  //myPort.write(130); // if values are entered directly like this, no casting is needed to transmit
  //myPort.write(200);
  //myPort.write(0);
  //myPort.write(255);

  updateWindow();
  delay(100);
}

// feed this function a pointer to a 3-value integer array to transmit it as bytes
void transmitBytes ( int[] inInts) {
  if (inInts.length != 3) return;

  byte checksum = 0;

  byte[] outBytes = new byte[5];
  for (int i = 0; i<3; i++) {
    outBytes[i] = (byte)inInts[i];
    checksum += (outBytes[i] * (i+1));
    //println("checksum = " + checksum);
  }

  printArray(outBytes);

  outBytes[3] = checksum; // penultimate byte is checksum
  outBytes[4] = (byte)255; // last byte is terminator

  myPort.write(outBytes);
}

void serialEvent (Serial myPort) {
  if (myPort.available() > 0) { 
    //println(myPort.read());
    myPort.readBytesUntil((byte)255, recdVals);
    //recdVals = myPort.readBytes();
    for (int i = 0; i < recdVals.length; i++) recdInts[i] = unsignedByteToInt(recdVals[i]);

    printArray(recdInts);
  }
}

int unsignedByteToInt (byte unsigned) {
  if (unsigned < 128 && unsigned > -1) return unsigned;
  else return (unsigned + 256);
}

void updateWindow() {
  String displayData = 
    "sensor[0] value received: " + recdInts[0] + 
    "\nsensor[1] value received: " + recdInts[1] + 
    "\nsensor[2] value received: " + recdInts[2] + 
    "\nsensor[3] value received: " + recdInts[3];

  textSize(24);
  text (displayData, 50, 50);
}
