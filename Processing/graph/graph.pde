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
 * added array of checkboxes and x's for constant 10cm and 50cm diagnostic tests
 * started adding trials ("put your hand at 30cm") with voice prompts, *very* incomplete
 
 */

int NUM_OF_SENSORS = 5;

String inString = "1"; // serial read string
int[] positions = new int[NUM_OF_SENSORS]; // incoming position data
int[] barHeight = new int[NUM_OF_SENSORS]; // scaled data for graphing

int MINGRAPHHEIGHT, MAXGRAPHHEIGHT, GRAPHRANGE;

int TASKAREALEFTEDGE = ((NUM_OF_SENSORS+1)*75); // right edge of graphs = left edge of task area

float SLOP = 0.05; // factor by which a distance can be ± and still be acceptable

import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1410";

// speech
import guru.ttslib.*;
TTS tts;

// GUI elements
import controlP5.*;
ControlP5 cp5;
boolean toggleValue = false;

boolean thirtycm = false;

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

  tts = new TTS();

  cp5 = new ControlP5(this);

  cp5.addToggle("toggleValue")
    .setValue(0)
    .setPosition(TASKAREALEFTEDGE, 200)
    .setSize(25, 25)
    ;

  cp5.addNumberbox("targetDistNumBox")
    .setPosition(TASKAREALEFTEDGE, 250)
    .setSize(50, 25)
    .setScrollSensitivity(0.5)
    .setValue(50)
    ;

  background(0);
  fill(255);
}

void targetDistNumBox(int targetDist) {
  println("targetDist = " + targetDist);
}

void toggleValue() {
  if (toggleValue==true) tts.speak("button pressed");
}

void draw () {
  background(0);
  drawLegend();
  drawGraphLines();
  drawTaskArea();
  tests();
}

void keyPressed() {
  if (key == '3') thirtycm = true;
}

void drawTaskArea() {
  pushMatrix();
  translate(TASKAREALEFTEDGE, 50);

  // 10cm static test
  fill(255);
  text("10cm", 0, 50);
  for (int j = 0; j < NUM_OF_SENSORS; j++) {
    if (positions[j] > 95 && positions[j] < 105) {
      fill(0, 255, 0);
      text("√", (j+1)*50, 50);
      if (j == 0) {
        tts.speak("great job at 10 centimeters");
      }
    } else {
      fill(255, 0, 0);
      text ("X", (j+1)*50, 50);
    }
  }

  pushMatrix();
  translate(0, 50);
  // 50cm static test
  fill(255);
  text("50cm", 0, 50);
  for (int j = 0; j < NUM_OF_SENSORS; j++) {
    if (positions[j] > 475 && positions[j] < 525) {
      fill(0, 255, 0);
      text("√", (j+1)*50, 50);
      if (j == 0) tts.speak("great job at 50 centimeters");
    } else {
      fill(255, 0, 0);
      text ("X", (j+1)*50, 50);
    }
  }
  popMatrix();

  pushMatrix();
  translate(0, 150);
  // up-down instruction
  popMatrix();

  popMatrix();
}

void tests() {
  if (thirtycm) {
    tts.speak("put your hand 30 centimeters above the sensor");
    delay(1000);
    if (positions[0] > (300*(1+SLOP)) && positions[0] < (300*(1-SLOP))) tts.speak("hey good job!");
    else tts.speak("nope");
    thirtycm = false;
  }
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
  fill(255);
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

  // console printing of incoming data
  /*
  for (int i = 0; i<NUM_OF_SENSORS; i++) {
    print(i + ": " + positions[i] + "     ");
    if (i == NUM_OF_SENSORS-1) println();
  }
  */

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
