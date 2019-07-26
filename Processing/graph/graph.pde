// Graphing sketch from tom igoe

/* 2/11/15 end of day progress: sketch talks to arduino, tells it to move, and then doesn't display
 anything other than a black background. 
 Tried trimming it so it would only see and parse the intended data (starting data lines with N 
 as a header for numbers to follow), but no dice so far.
 FIXED IT! Stayed late and figured out to use split() instead of parseInt(). Yeesh.
 
 */

/* 7-25-19 picking up where I left off four years ago!
 
 now using this as a basis for graphing the data output from the distance sensing array
 
 the Arduino will transmit a line which is tab delimited of five different data points,
 something like:
 122  522  6000  40  872
 with a newline at the end. Each data point will be a bar graph to start.
 
 */


// values, (will be) dynamically adjustable, to hold graph max and min.
int maxval = 8000;
int minval = 0;
String inString = "1"; // serial read string
int[] positions = {0, 0, 0, 0, 0}; // incoming data positions

import processing.serial.*;

Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph

String portName = "/dev/cu.usbserial-1410";

void setup () {

  // set the window size:
  size(1200, 400);        

  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
  // set inital background:
  background(0);
  //drawlegend();
}
void draw () {
  // everything happens in the serialEvent()
  //serialEvent(myPort);

  for (int i = 0; i<5; i++) {
    positions[i] = (int)map(positions[i], 8000, 0, 0, 200);
    rect(i*50, 40, 10, positions[i]);
  }
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  // read whole input up through newline

  while (myPort.available() > 0) { 
    inString = myPort.readStringUntil('\n');
    //println(inString);
  }

  // then parse whole input into five values
  positions = int(split(inString, '\t'));
  for (int i = 0; i<positions.length; i++) {
    print(i + ": " + positions[i] + "     ");
    if (i == positions.length - 1) println();
  }


  background(0);

  fill(255);



}
