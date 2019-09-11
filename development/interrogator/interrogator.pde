/*

 "Interrogator" software for use in production of "Project Amelia"
 produced by Probable Models and Bricolage Theater
 Pittsburgh, 2019
 
 This software communicates with an Arduino-based hardware peripheral which:
 1) accepts color instructions to illuminate LEDs, and
 2) transmits back rangefinder data from three sensors
 
 much more information at https://github.com/robzach/Amelia
 
 Robert Zacharias, rz@rzach.me
 
 */


import processing.serial.*;
// printArray(Serial.list()); // will print the list of ports as needed
Serial myPort;
String portName = "/dev/ttyUSB0"; // for USB access to the Arduino

byte[] recdVals = new byte[5];
int [] recdInts = new int[5];

int[] colors = new int[3]; // colors to write out to Arduino
int sensorsToQuery = 0; // which distance sensors to query

// named variables to store positions[0,1,2,3] in that order
// perspective is from the user's side of the cube
int left, front, right, top; 

// enumerated variable to track state machine mode
enum Mode { 
  IDLE, ORIENTATION, INTERROGATION, TERMINATION
};
Mode mode = Mode.INTERROGATION; // initial state
Mode prevMode; // to track changes
int stageCounter = 0; // for tracking within modes

boolean newDataRecd = true;

boolean startSignalReceived = true; // boolean to be triggered by websocket event
boolean interrogationCompleted = false; // 

long retransmitTimer = 0;

// timer class for instantiating "breathing" light behavior
public class Breathe {
  int _color; // 0 = red, 1 = blue, 2 = green
  long period; // in milliseconds
  long startMillis;

  // constructor takes two arguments
  public Breathe(int _color, long period) {
    this._color = _color;
    this.period = period;
    this.startMillis = millis(); // constructor remembers when it was made
  }

  // poll this function as often as possible to update the lights as needed
  void pollBreathe() {
    float position = (millis() - startMillis) % period; // only use the positive half of the sine curve
    float multiplier = sin( (PI * position) / period); // 
    colors[_color] = (int)(254 * multiplier);
    println("setting color[" + _color + "]: " + colors[_color]);
  }
}
Breathe[] breaths;


void setup () {
  breaths = new Breathe[1];
  // you can adjust height as wanted, and the graphs will scale appropriately
  size(600, 500); 
  background(0);

  printArray(recdVals); // should start empty

  myPort = new Serial(this, portName, 57600);
  // don't generate a serialEvent() unless you get a 255 (terminator) byte:
  myPort.bufferUntil((byte)255);
}

void draw() {
  background(0);
  sensorsToQuery = 0; // to be incremented as needed by color-drawing functions below
  // sensor 0 = ones, sensor 1 = twos, sensor 2 = fours
  // i.e. to read sensors 0 and 2, set to value (1*1) + (0*2) + (1*4) = 5

  // if data is received, write out a color instruction immediately
  // but don't write another until new data comes back
  if (newDataRecd) {
    newDataRecd = false;    
    retransmitTimer = millis();
    stateMachine();
    transmitBytes();
  }

  // if no new data (perhaps missed a cycle), just send an update every 200 milliseconds
  else {
    if (millis() - retransmitTimer >= 200) {
      stateMachine();
      transmitBytes();
      println("no new data received at " + millis());
      retransmitTimer = millis();
    }
  }
  updateWindow();
}


// left side of box = sensor 0 = red
void redScale() {
  if (recdInts[0] > -1 && recdInts[0] < 255)
    colors[0] = recdInts[0]; // load received sensor 0 value into red output instruction
  sensorsToQuery += 1;
}

// top of box = sensor 1 = green
void greenScale() {
  if (recdInts[1] > -1 && recdInts[1] < 255)
    colors[1] = recdInts[1]; // load received sensor 1 value into green output instruction
  sensorsToQuery += 2;
}

// right side of box = sensor 2 = blue
void blueScale() {
  if (recdInts[2] > -1 && recdInts[2] < 255)
    colors[2] = recdInts[2]; // load received sensor 1 value into green output instruction
  sensorsToQuery += 4;
}


void transmitBytes () {

  // begin by copying colors to a new array that includes sensorsToQuery at the head
  int[] paddedArray = new int[4];
  paddedArray[0] = sensorsToQuery;
  for (int i = 1; i < 4; i++) 
    paddedArray[i] = colors[i-1];

  // outgoing bytes in order:
  // 0: sensorNum (which sensors Arduino should query)
  // 1: red value (0-254);
  // 2: green value (0-254)
  // 3: blue value (0-254)
  // 4: checksum (see below for calculation)
  // 5: terminator byte 255
  byte checksum = 0;
  byte[] outBytes = new byte[6];
  for (int i = 0; i<4; i++) {
    outBytes[i] = (byte)paddedArray[i];
    checksum += (outBytes[i] * (i+1));
  }

  // special case: if it's 255, change it to 254
  if (checksum == (byte)255) checksum = (byte)254;
  outBytes[4] = checksum; // penultimate byte is checksum
  outBytes[5] = (byte)255; // last byte is terminator
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
      //printArray(recdInts);
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
  //printArray(arrayIn);
  //println("localChecksum= " + localChecksum + "; arrayIn[length-2]=" + arrayIn[length-2]);
  //println("arrayIn.length= " + arrayIn.length);

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
    "\nchecksum value received: " + recdInts[3] +
    "\n\ncolors[0,1,2]: " + colors[0] + ", " + colors[1] + ", " + colors[2] +
    "\nsensorsToQuery: " + sensorsToQuery +
    "\n\nmode: " + mode +
    "\nstageCounter: " + stageCounter +
    "\nmillis(): " + millis() +
    "\nmillis() - startTime: " + (millis() - startTime);

  textSize(20);
  text (displayData, 50, 50);
}
