void stateMachine() { //<>//
  // only print console feedback "entering MODE mode" if changed from prior mode (for debugging)
  boolean change = (prevMode != mode) ? true : false;

  switch (mode) {
  case INTRO:
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    rangerTrainingSequence();
    break;
  case CALMING:
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    calming(); 
    break;
  case DISORIENTATION:
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    disorientation(); 
    break;
  case INTERROGATION:
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    interrogation(); 
    break;
  case TERMINATION: 
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    termination(); 
    break;
  case IDLE: 
  default:
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    waitForStartSignal(); 
    break;
  }
}

long startTime = 0; 

void rangerTrainingSequence() {

  // start timer to begin
  if (stageCounter == 0) {
    startTime = millis();
    stageCounter = 1;
  }

  // run redAdjuster for 10 seconds
  if (stageCounter == 1) {
    if (millis() - startTime < 10000) redAdjuster();
    else {
      stageCounter = 2;
      startTime = millis();
    }
  }

  // run blueAdjuster for 10 seconds
  if (stageCounter == 2) {
    if (millis() - startTime < 10000) blueAdjuster();
    else {
      stageCounter = 3;
      startTime = millis();
    }
  }

  // run greenAdjuster for 10 seconds
  if (stageCounter == 3) {
    if (millis() - startTime < 10000) greenAdjuster();
    else {
      startTime = millis(); // reset timer
      mode = Mode.DISORIENTATION; // jump to next mode
    }
  }
}

void disorientation() {
  //greenBreathe(0);
  //redBreathe();
  //blueBreathe(0);

  if (millis() - startTime < 10000) redBounce(300); // run redBounce for 10 seconds
  else  mode = Mode.TERMINATION; // jump to next mode
}

void interrogation() {
}

void termination() {
  // fade all up to white and then back down to black
  for (int i = 0; i < 256; i++) {
    writeOut(i + "," + i + "," + i + "\n");
    delay(10);
  }
  for (int i = 255; i > 0; i--) {
    writeOut(i + "," + i + "," + i + "\n");
    delay(10);
  }
  mode = Mode.IDLE;
}

void waitForStartSignal() {
}

float redBreathe() {
  // establishes a breathing goal (driven via sine) for hand movement by left hand

  // used for running average computation; closer to 0 is longer memory and closer to 1 is faster updating
  float decayRate = 0.03; 

  float sinArgument = map(millis() % breathingTempo, 0, breathingTempo, 0, TWO_PI); // feed sine [0,2*PI] based on millis()
  float goal = map (sin(sinArgument), -1, 1, 0, 500) ; // turn sine's output to 0 to 500 (millimeters)
  float breatheDelta = goal - left;
  runningAverageDelta = (breatheDelta * decayRate) + (runningAverageDelta * (1-decayRate));
  //println("breathe goal = " + goal + ", current position = " + left + ", delta = " + breatheDelta + ", runningAverageDelta = " + runningAverageDelta);

  //demonstrate the breathing goal with the red LED output
  int redVal = int(map(goal, 0, 500, 0, 255));
  //writeOut(redVal + ",0,0\n");

  pushMatrix();
  translate(TASKAREALEFTEDGE, 300);
  fill(255);
  text("red is goal, yellow is current position\nwhite line is delta\nrunningAverageDelta = " + runningAverageDelta +
    "\nbreatheDelta = " + breatheDelta, 0, 20);
  noStroke();
  fill(255, 0, 0);
  ellipse( map(goal, 0, 500, 200, 0), 0, 20, 20); // goal dot (note flipped axis)
  fill(255, 255, 0);
  ellipse( map(left, 0, 500, 200, 0), 0, 10, 10); // current position dot (note flipped axis)
  stroke(255);

  float graphRunningAverageDelta = map(runningAverageDelta, 0, 500, 0, 200);
  line(map(left, 0, 500, 200, 0), 0, map(left, 0, 500, 200, 0) - graphRunningAverageDelta, 0); 

  popMatrix();

  return runningAverageDelta;
}


float blueBreathe(int sync) {
  // establishes a breathing goal (driven via sine) for hand movement by right hand

  // used for running average computation; closer to 0 is longer memory and closer to 1 is faster updating
  float decayRate = 0.03; 

  // if argument "sync" is 0, run in parallel to redBreathe, otherwise run them 180º separately
  float sinArgument;
  if (sync == 0) sinArgument = map(millis() % breathingTempo, 0, breathingTempo, 0, TWO_PI); // feed sine [0,2*PI] based on millis()
  else sinArgument = map(millis() % breathingTempo, 0, breathingTempo, TWO_PI, 0); // or to put it 180º out of phase, feed it[2*PI,0]
  float goal = map (sin(sinArgument), -1, 1, 0, 500) ; // turn sine's output to 0 to 500 (millimeters)
  float breatheDelta = goal - right;
  runningAverageDelta = (breatheDelta * decayRate) + (runningAverageDelta * (1-decayRate));
  //println("breathe goal = " + goal + ", current position = " + left + ", delta = " + breatheDelta + ", runningAverageDelta = " + runningAverageDelta);

  //demonstrate the breathing goal with the blue LED output
  int blueVal = int(map(goal, 0, 500, 0, 255));
  //writeOut(redVal + ",0,0\n");

  pushMatrix();
  translate(TASKAREALEFTEDGE+250, 300);
  fill(255);
  text("blue is goal, yellow is current position\nwhite line is delta\nrunningAverageDelta = " + runningAverageDelta +
    "\nbreatheDelta = " + breatheDelta, 0, 20);
  noStroke();
  fill(0, 0, 255);
  ellipse( map(goal, 0, 500, 0, 200), 0, 20, 20); // goal dot (not flipped: moving to right)
  fill(255, 255, 0);
  ellipse( map(right, 0, 500, 0, 200), 0, 10, 10); // current position dot (not flipped: moving to right)
  stroke(255);

  float graphRunningAverageDelta = map(runningAverageDelta, 0, 500, 0, 200);
  line(map(right, 0, 500, 0, 200), 0, map(right, 0, 500, 0, 200) + graphRunningAverageDelta, 0); 

  popMatrix();

  return runningAverageDelta;
}

float greenBreathe(int sync) {
  // establishes a breathing goal (driven via sine) for hand movement over top sensor by either hand

  // used for running average computation; closer to 0 is longer memory and closer to 1 is faster updating
  float decayRate = 0.03; 

  // if argument "sync" is 0, run in parallel to redBreathe, otherwise run them 180º separately
  float sinArgument;
  if (sync == 0) sinArgument = map(millis() % breathingTempo, 0, breathingTempo, 0, TWO_PI); // feed sine [0,2*PI] based on millis()
  else sinArgument = map(millis() % breathingTempo, 0, breathingTempo, TWO_PI, 0); // or to put it 180º out of phase, feed it[2*PI,0]
  float goal = map (sin(sinArgument), -1, 1, 0, 500) ; // turn sine's output to 0 to 500 (millimeters)
  float breatheDelta = goal - top;
  runningAverageDelta = (breatheDelta * decayRate) + (runningAverageDelta * (1-decayRate));
  //println("breathe goal = " + goal + ", current position = " + left + ", delta = " + breatheDelta + ", runningAverageDelta = " + runningAverageDelta);

  //demonstrate the breathing goal with the blue LED output
  int greenVal = int(map(goal, 0, 500, 0, 255));
  //writeOut("0," + greenVal + ",0\n");

  pushMatrix();
  translate(TASKAREALEFTEDGE+250, 300);
  fill(255);
  //text("blue is goal, yellow is current position\nwhite line is delta\nrunningAverageDelta = " + runningAverageDelta +
  //"\nbreatheDelta = " + breatheDelta, 0, 20);
  noStroke();
  fill(0, 255, 0);
  ellipse(0, map(goal, 0, 500, 0, -200), 20, 20); // goal dot (moving vertically)
  fill(255, 255, 0);
  ellipse(0, map(top, 0, 500, 0, -200), 10, 10); // current position dot
  stroke(255);

  float graphRunningAverageDelta = map(runningAverageDelta, 0, 500, 0, 200);
  line(0, map(top, 0, 500, 0, -200), 0, map(top, 0, 500, 0, -200) + graphRunningAverageDelta); 

  popMatrix();

  return runningAverageDelta;
}

void redBounce(int tempo) {
  // establishes a breathing goal (driven via sine) for hand movement by left hand


  float sinArgument = map(millis() % tempo, 0, tempo, 0, TWO_PI); // feed sine [0,2*PI] based on millis()
  float goal = map (sin(sinArgument), -1, 1, 0, 500) ; // turn sine's output to 0 to 500 (millimeters)

  //demonstrate the breathing goal with the red LED output
  int redVal = int(map(goal, 0, 500, 0, 255));
  writeOut(redVal + ",0,0\n");

}
