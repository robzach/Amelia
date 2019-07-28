// basis of Graphing sketch from tom igoe

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
 
 7-28-19
 * changed bar graphs into line graphs which move up and down inside bounded areas
 * moved all drawing operations into draw() or subroutines (doing any drawing inside
 the serial event isn't recommended and was introducing occasional errors)
 * any values of 0 (min) or 1000 (max) back from the sensor are painted red
 * added better legend, etc.
 
 */

int NUM_OF_SENSORS = 5;

String inString = "1"; // serial read string
int[] positions = new int[NUM_OF_SENSORS]; // incoming position data
int[] barHeight = new int[NUM_OF_SENSORS]; // scaled data for graphing

int MINGRAPHHEIGHT, MAXGRAPHHEIGHT, GRAPHRANGE;

import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1410";

void setup () {

  // set the window size
  // you can adjust height as wanted, and the graphs will scale appropriately
  size(1200, 500); 

  // set graph heights
  MINGRAPHHEIGHT = 20;
  MAXGRAPHHEIGHT = height - 20;
  GRAPHRANGE = MAXGRAPHHEIGHT - MINGRAPHHEIGHT;


  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
  // set inital background:
  background(0);
  fill(255);
}

void draw () {
  background(0);
  drawLegend();
  drawGraphLines();
}

void drawGraphLines() {
  for (int i = 0; i<NUM_OF_SENSORS; i++) {
    pushMatrix();
    translate(0, barHeight[i]);
    if (barHeight[i] == 0 || barHeight[i] == GRAPHRANGE) {
      stroke(255, 0, 0);
      strokeWeight(3);
    } else {
      stroke(255);
      strokeWeight(3);
    }
    line((i+1)*75, MINGRAPHHEIGHT, 50+((i+1)*75), MINGRAPHHEIGHT);
    text(positions[i], (i+1)*75, 0);
    popMatrix();
  }
}

void drawLegend() {
  text("0mm", 40, MAXGRAPHHEIGHT); // graph minimum legend (at bottom, hence "max" height)
  text("1000mm", 20, MINGRAPHHEIGHT); // graph maximum legend (at top, hence "min" height)

  // Y axis legend
  pushMatrix();
  translate(50, height/2 + 25);
  rotate(-PI/2);
  text("distance from sensor", 0, 0);
  popMatrix();

  for (int i = 0; i<NUM_OF_SENSORS; i++) {
    strokeWeight(1);
    stroke(128);
    noFill();
    rectMode(CORNERS);
    // bounding rectangles for each graph line
    rect((i+1)*75, MINGRAPHHEIGHT, 50+((i+1)*75), MAXGRAPHHEIGHT);
    fill(255);
    text("#" + i, 10+((i+1)*75), height-10); // sensor number at bottom of each rectangle
  }
}

void serialEvent (Serial myPort) {
  while (myPort.available() > 0) { 
    // load serial data into inString
    inString = myPort.readStringUntil('\n');
    //println(inString);
  }

  // then parse input into five values
  positions = int(split(inString, '\t'));

  for (int i = 0; i<NUM_OF_SENSORS; i++) {
    print(i + ": " + positions[i] + "     ");
    if (i == NUM_OF_SENSORS-1) println();
  }

  // clamp inputs to between 0 and 1000, then map those 0 to 200 for graphing
  for (int i = 0; i<NUM_OF_SENSORS; i++) {
    positions[i] = constrain(positions[i], 0, 1000);
    barHeight[i] = (int)map(positions[i], 1000, 0, 0, GRAPHRANGE);
  }
}



// unused
void drawBarGraphs() {
  for (int i = 0; i<NUM_OF_SENSORS; i++) {
    fill(255, 0, 0);
    rect((i+1)*100, 40, 40, barHeight[i]);
  }
}
