import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1410"; // for USB access to the Arduino

byte[] recdVals = new byte[6];
int [] recdInts = new int[6];

boolean newDataRecd = true;

long timer = 0;

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

  //if (checksumValid(recdInts)) redScale();

  // if data is received, write out a color instruction immediately
  // but don't write another until new data comes back
  if (newDataRecd) {
    newDataRecd = false;
    redScale();
  }

  // if no new data (perhaps missed a cycle), just send an update every 100 milliseconds
  else {
    if (millis() - timer >= 1000) {
      redScale();
      println("no new data received at " + millis());
      timer = millis();
    }
  }

  //redScale();
  updateWindow();
  //if (!newDataRecd) delay(1000);
}

void redScale() {
  int[] colors = new int[3];
  if (recdInts[0] > -1 && recdInts[0] < 255)
    colors[0] = recdInts[0]; // load received sensor 0 value into red output instruction
  transmitBytes(colors);
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

  //printArray(outBytes);

  outBytes[3] = checksum; // penultimate byte is checksum
  outBytes[4] = (byte)255; // last byte is terminator

  myPort.write(outBytes);
}

void serialEvent (Serial myPort) {
  if (myPort.available() > 0) { 
    //println(myPort.read());
    myPort.readBytesUntil((byte)255, recdVals);
    //recdVals = myPort.readBytes();

    // temporary integers to use for checksumming
    int[] tempInts = new int[recdVals.length];
    for (int i = 0; i < recdVals.length; i++) tempInts[i] = unsignedByteToInt(recdVals[i]);

    // only if checksum is valid should new values be copied to recdInts array
    if (checksumValid (tempInts) ) {
      for (int i = 0; i < recdVals.length; i++) recdInts[i] = unsignedByteToInt(recdVals[i]);
      newDataRecd = true;
    }

    //printArray(recdInts);
  }
}

boolean checksumValid (int[] arrayIn) {
  int length = arrayIn.length;
  int localChecksum = 0;

  // add zeroth through pen-penultimate element in incoming data
  for (int i = 0; i < length - 2; i++) {
    localChecksum += (arrayIn[i] * (i + 1)); 
    localChecksum = localChecksum % 256; // modulo 256 to treat as unsigned byte data
  }

  // penultimate element of array is checksum, so compare to penultimate value read in for result
  return (localChecksum == arrayIn[length-2]);
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
