/* 
 
 Moodification Companion source sketch
 v. 0.4
 
 written for Probable Models / Bricolage production of Project Amelia in Pittsburgh, fall 2019
 
 Robert Zacharias, rz@rzach.me, 8-27-19
 
 
 7-25-19 picking up where I left off four years ago!
 
 now using this as a basis for graphing the data output from the distance sensing array
 
 The Arduino can be expected to transmit a line which is space-delimited of four different data points,
 something like:
 122 522 8190 40
 with a newline at the end. Each data point will be a bar graph to start.
 
 7-28-19
 * changed bar graphs into line graphs which move up and down inside bounded areas
 * moved all drawing operations into draw() or subroutines (doing any drawing inside
 the serial event isn't recommended and was introducing occasional errors)
 * any values of 0 (min) or 1000 (max) back from the sensor are painted red
 * added better legend, etc.
 * added array of checkboxes and x's for constant 10cm and 50cm diagnostic tests
 * started adding trials ("put your hand at 30cm") with voice prompts, *very* incomplete
 
 (multiple changes over this interval weren't recorded here in the file)
 
 8-15-19
 * added toggle to try to adjust the level of red brightness using position data. It's
 not working; lots of different LED colors are shown, seemingly randomly (?)
 * reordered code for greater legibility
 * squashed bug where last data point was consistently not being read
 
 8-19-19
 * TODOs for tonight:
 - build state machine as described below
 - add simple basic pass/fail test for hand-moving pattern grading
 - add non-blocking speech cues for user
 - allow for graceful recovery from serial failure (look into other data transmission modes?...)
 - consider adding additional UI features to the piece:
 + physical bell to ding (very Pavlov)
 + three separate LED channels, each emanating from a physically different projection location onto the screen
 
 State machine concept:
 
 introduction -> { {calming <-> disorientation} <-> interrogation } -> termination
 
 Introduction: The user is given a simple orientation to controlling the lights using the distance sensors to start.
 Calming: Moving the hands back and forth gently, breathing along with the motion.
 Disorientation: Instructions go faster and become more erratic, user is given negative feedback.
 Interrogation: User is asked questions of increasing intensity and seriousness.
 Termination: Probably pre-baked to imply user is lying, regardless of the answers they supply.
 
 Actually achieved tonight:
 * state machine begun; initial training module somewhat far along
 * pass/fail test mostly worked out (see redBreathe() function)
 
 8-20-19
 Picking up yesterday's TODOs as primary goals
 * continue state machine development for fuller demo in the morning
 * complete pass/fail test for hand movement
 
 Made some progress: 
 * state machine is further developed with non-blocking states-within-states
 * top sensor was added though still buggy (greenBreathe() is its function)
 
 
 8-27-19
 Goal for tonight is to complete the "interrogation mode":
 * waiting mode (nobody is tagged in yet)
 * orientation (train the user)
 * disorientation (give them commands more quickly than they can complete them, flash an alarm when they fail)
 * finished (a final color indicates the machine's final disposition at the end of the "lie-detecting"
 
 Next, this sketch will be run on Processing on a Raspberry Pi, with SPI instead of Serial UART communication,
 the idea being that this will be faster and more reliable for moving data back and forth
 
 
 This sketch based on "graph," found in commit 698b36c, which in turn draws from Tom Igoe's work.
 */

import processing.serial.*;
Serial myPort;
//String portName = "/dev/cu.usbserial-1420"; // for USB access to the Arduino

String portName = "/dev/serial0"; // setting for the hardware UART pins on RasPi 3
// physical pin 8 is TX, physical pin 10 is RX
// these are wired through a voltage level shifter to the RX and TX respectively on the Arduino
// note also that the system configuration may need to be changed: using Preferences-> Raspberry Pi Configuration
// select enable for Serial Port and disable for Serial Console.

String inString = "1"; // serial read string


// speech
import guru.ttslib.*;
TTS tts;

// GUI elements
import controlP5.*;
ControlP5 cp5;
boolean redAdjusterBool = false;
boolean thirtycm = false;

int NUM_OF_SENSORS = 4;

int[] positions = new int[NUM_OF_SENSORS]; // incoming position data
int[] barHeight = new int[NUM_OF_SENSORS]; // scaled data for graphing
int MINGRAPHHEIGHT, MAXGRAPHHEIGHT, GRAPHRANGE; // variables for drawing graphs

// named variables to store positions[0,1,2,3] in that order
// perspective is from the user's side of the cube
int left, front, right, top; 

// used in steady test
public long timer;
int cycleCounter = 0;

// other globals
boolean VOCALFEEDBACK = false;
float SLOP = 0.05; // factor by which a distance can be ± and still be acceptable
int TASKAREALEFTEDGE = ((NUM_OF_SENSORS+1)*75); // right edge of graphs = left edge of task area
float runningAverageDelta; // used in calculating how well the user is matching a specified breathing rate

// breathing tempo (milliseconds between breaths)
float breathingTempo = 8000;
long lastBreathTime;

// timing variables for throttling rate of writing out to serial port (milliseconds)
long WRITE_INTERVAL = 400; // at or below 200 it creates garbage output from the Arduino…something is wrong
// consider rewiting Processing->Arduino data flow so it always sends three three-digit values for parsing,
// in the style of this useful sample code https://arduino.stackexchange.com/questions/46008/what-is-a-faster-alternative-to-parseint
long lastWriteTime;

// enumerated variable to track state machine mode
enum Mode { 
  INTRO, CALMING, DISORIENTATION, INTERROGATION, TERMINATION, IDLE
};

Mode mode = Mode.INTRO; // initial state
Mode prevMode; // to track changes

int stageCounter = 0; // for tracking within modes


// used in bouncing ball
public float speedDivisor = 50;
int BALLBOUNCELEFTEDGE = TASKAREALEFTEDGE + 400;
int counter = 0;


void setup () {

  // you can adjust height as wanted, and the graphs will scale appropriately
  size(1200, 500); 

  // set graph heights
  MINGRAPHHEIGHT = 20;
  MAXGRAPHHEIGHT = height - 20;
  GRAPHRANGE = MAXGRAPHHEIGHT - MINGRAPHHEIGHT;

  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');


  // this didn't stop the serialEvent error from happening:
  while (myPort.available() < 1) {
    ;
  }; // wait until port is available before proceeding


  // text to speech object
  tts = new TTS();

  // add GUI control elements
  cp5 = new ControlP5(this);

  cp5.addToggle("redAdjusterBool")
    .setValue(0)
    .setPosition(TASKAREALEFTEDGE, 200)
    .setSize(25, 25)
    ;

  cp5.addNumberbox("speedDivisor")
    .setPosition(BALLBOUNCELEFTEDGE-10, 20)
    .setSize(50, 25)
    .setScrollSensitivity(0.5)
    .setValue(50)
    ;

  background(0);
  fill(255);
}

void draw () {
  background(0);

  drawLegend();
  drawGraphLines();
  drawTaskArea();
  //bounceBall();
  tests();
  drawSerialStream();

  if (redAdjusterBool) redAdjuster();

  stateMachine();
}

void keyPressed() {
  if (key == '3') thirtycm = true;
  if (key == 's') steadyTest();
  if (key == 'r') myPort.write("255,0,0\n"); // red LEDs
  if (key == 'g') myPort.write("0,255,0\n"); // green LEDs
  if (key == 'b') myPort.write("0,0,255\n"); // blue LEDs
  if (key == 'o') myPort.write("0,0,0\n"); // turn off LEDs
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
        if (VOCALFEEDBACK) tts.speak("great job at 10 centimeters");
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
      if (j == 0) {
        if (VOCALFEEDBACK) tts.speak("great job at 50 centimeters");
      }
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

void bounceBall() {
  //float speedDivisor = 50; // drives the ball speed--higher is slower
  counter++; // used to feed sine function for oscillation

  // default values
  fill(0, 0, 255);

  int maxTarget = 500;
  int minTarget = 200;

  // test at max height
  if (sin(counter/speedDivisor) < -0.999) {
    if (abs(positions[0] - maxTarget) < 30) {
      //println("good job on max");
      fill(255);
    } else fill(255, 0, 0);
  }

  // test at min height
  if (sin(counter/speedDivisor) > 0.999) {
    if (abs(positions[0] - minTarget) < 30) {
      //println("good job on min");
      fill(255);
    } else fill(255, 0, 0);
  }

  // line to show range of ball's motion
  stroke(128);
  line(BALLBOUNCELEFTEDGE, 100, BALLBOUNCELEFTEDGE, 200);

  // bouncing ball, which blinks white if you hit the max or min values at the right moment
  // or stays blue if you don't
  stroke(0, 0, 255);
  float ellipseYpos = 50*sin(counter/speedDivisor) + 150;
  ellipse(BALLBOUNCELEFTEDGE, ellipseYpos, 20, 20);
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

void drawSerialStream() {
  fill(255);
  text("inString = " + inString, TASKAREALEFTEDGE, height-70);
  text("positions [0] = " + positions[0], TASKAREALEFTEDGE, height-55);
  text("positions [1] = " + positions[1], TASKAREALEFTEDGE, height-40);
  text("positions [2] = " + positions[2], TASKAREALEFTEDGE, height-25);
  text("positions [3] = " + positions[3], TASKAREALEFTEDGE, height-10);
}


void redAdjuster() {
  // read left hand position, vary red brightness based on that value
  int constrainedPosData = constrain(left, 0, 1000);
  int redVal = int( map (constrainedPosData, 0, 1000, 0, 255));
  text("writing: " + redVal + ",0,0\n", TASKAREALEFTEDGE, 250);

  writeOut(redVal + ",0,0\n");
  //if (!writeOut(redVal + ",0,0\n")) writeOut(redVal + ",0,0\n"); // if it didn't work, try again
}

void blueAdjuster() {
  // read right hand position, vary blue brightness based on that value
  int constrainedPosData = constrain(right, 0, 1000);
  int blueVal = int( map (constrainedPosData, 0, 1000, 0, 255));
  text("writing: 0,0," + blueVal + "\n", TASKAREALEFTEDGE, 250);

  writeOut("0,0," + blueVal + "\n");
  //if (!writeOut(redVal + ",0,0\n")) writeOut(redVal + ",0,0\n"); // if it didn't work, try again
}

void greenAdjuster() {
  // read top hand position, vary blue brightness based on that value
  int constrainedPosData = constrain(top, 0, 1000);
  int greenVal = int( map (constrainedPosData, 0, 1000, 0, 255));
  text("writing: 0," + greenVal + ",0\n", TASKAREALEFTEDGE, 250);

  writeOut("0," + greenVal + ",0\n");
  //if (!writeOut(redVal + ",0,0\n")) writeOut(redVal + ",0,0\n"); // if it didn't work, try again
}

boolean writeOut(String outString) {
  // limit rate of writing out to serial port (too fast screws up the Arduino)
  // return true if write succeeded, false if not

  if (millis() - lastWriteTime >= WRITE_INTERVAL) {
    myPort.write(outString);
    lastWriteTime = millis();
    return true;
  }
  return false;
}

void steadyTest() {
  fill(255);
  text ("Steady Test\ntype \'s\' to begin", BALLBOUNCELEFTEDGE, 400);

  // load 1 second of data into an array
  int[] history = new int[10000];
  cycleCounter = 0;
  timer = millis();

  // blocking for now but to be improved
  while (millis() - timer < 1000) {
    history[cycleCounter] = positions[0];
    cycleCounter++;
  }

  int sum = 0;
  for (int i = 0; i < cycleCounter; i++) sum += history[i];

  float meanHeight = sum / cycleCounter;
  println(meanHeight);
}

void serialEvent (Serial myPort) {
  while (myPort.available() > 0) { 
    // load serial data into inString
    inString = myPort.readStringUntil('\n');
    //println(inString);
  }

  // then parse input into individual values
  inString = trim(inString); // remove trailing newline (needed for valid parsing)
  positions = int(split(inString, ' ')); // space delimited data

  // console printing of incoming data
  /*
  for (int i = 0; i<NUM_OF_SENSORS; i++) {
   print(i + ": " + positions[i] + "     ");
   if (i == NUM_OF_SENSORS-1) println();
   }
   */

  // clamp inputs to between 0 and 1000, then map those 0 to GRAPHRANGE for graphing
  for (int i = 0; i<NUM_OF_SENSORS; i++) {
    positions[i] = constrain(positions[i], 0, 1000);
    barHeight[i] = (int)map(positions[i], 1000, 0, 0, GRAPHRANGE);
  }

  // easier names for cube face distance data (named from perspective of user)
  left = positions[0];
  front = positions[1];
  right = positions[2];
  top = positions[3];
}
