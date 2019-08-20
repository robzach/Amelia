void stateMachine() {
  // only print console feedback "entering MODE mode" if changed from prior mode (for debugging)
  boolean change = (prevMode != mode) ? true : false;

  switch (mode) {
  case INTRO:
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    introSequence(); 
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
  default:
    if (change) {
      println("entering " + mode + " mode");
      prevMode = mode;
    }
    termination(); 
    break;
  }
}

void introSequence() {
  /*
  tts.speak("welcome to this calming experience.");
   
   // make the user put their hand close to the cube first
   do {
   tts.speak("Please put your left hand near the side of the cube.");
   if (left < 100) tts.speak("good job");
   } while (left > 100); // while (outside of goal)
   
   // make the user move their hand a bit farther away
   do {
   tts.speak("now move your hand a bit farther away from the cube, between 10 and 20 centimeters.");
   if (left < 200 && left > 100) tts.speak("good job");
   } while (left > 200 || left < 100); // while (outside of goal)
   
   // make the user move their hand farther yet
   do {
   tts.speak("now move your hand even farther, between 30 and 50 centimeters from the cube.");
   if (left < 500 && left > 300) tts.speak("wonderful.");
   } while (left > 500 || left < 300); // while (outside of goal)
   
   
   // The below section trains the user how to use the red brightness to properly time their hand movements.
   
   tts.speak("now we will begin to use your hand's movement and your breathing to calm you down");
   
   // make the user put their hand close to the cube first
   do {
   tts.speak("Begin by putting your left hand near the side of the cube.");
   if (left < 100) tts.speak("good job");
   } while (left > 100); // while (outside of goal)
   
   // make the user move their hand far away
   do {
   tts.speak("now move your hand far to the left, between 30 and 50 centimeters from the cube.");
   if (left < 500 && left > 300) tts.speak("wonderful.");
   } while (left > 500 || left < 300); // while (outside of goal)
   
   tts.speak("notice how you can change the red brightness by moving your left hand back and forth");
   
   long startTime = millis();
   while (millis() - startTime < 10000) redAdjuster(); // run redAdjuster for 10 seconds
   
   
   tts.speak("now we're going to breathe.");
   tts.speak("first, move your hand back and forth to match the brightness of the red");
   */

  redBreathe();

  // graduate to the next mode once this sequence is complete
  //mode = Mode.CALMING;
}

void calming() {
}

void disorientation() {
}

void interrogation() {
}

void termination() {
}

float redBreathe() {
  // establishes a breathing goal (driven via sine) for hand movement

  float decayRate = 0.1;

  float sinArgument = map(millis() % breathingTempo, 0, breathingTempo, 0, TWO_PI); // feed sine [0,2*PI] based on millis()
  float goal = map (sin(sinArgument), -1, 1, 0, 500) ; // turn sine's output to 0 to 500 (millimeters)
  float breatheDelta = goal - left;
  //println("breathe goal = " + goal + ", current position = " + left + ", delta = " + breatheDelta);

  runningAverageDelta = (breatheDelta * decayRate) + (runningAverageDelta * (1-decayRate));

  pushMatrix();
  translate(TASKAREALEFTEDGE, 300);
  text("red is goal, yellow is current position\nrunningAverageDelta = " + runningAverageDelta +
  "\nbreatheDelta = " + breatheDelta,0, 20);
  noStroke();
  fill(255, 0, 0);
  ellipse( map(goal, 0, 500, 0, 200), 0, 20, 20); // goal ellipse
  fill(255, 255, 0);
  ellipse( map(left, 0, 500, 200, 0), 0, 10, 10); // current position ellipse (note flipped axis)
  stroke(255);
  
  // this dumb line is totally not working
  float graphRunningAverageDelta = map(runningAverageDelta, 0, 500, 0, 200);
  line(map(left, 0, 500, 200, 0), 0, map(left, 0, 500, 200, 0) + breatheDelta, 0); 
  
  popMatrix();
  return runningAverageDelta;
}
