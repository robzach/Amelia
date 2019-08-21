void stateMachine() { //<>//
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

boolean beginRedBreathe = false;
boolean redBreatheStarted = false;
long redBreatheStartTime;

boolean redAdjusterStarted = false;
long redAdjusterStartTime; 

long startTime; 

void introSequence() {

  // welcome sentence
  if (stageCounter == 0) {
    println("stageCounter = " + stageCounter);
    tts.speak("welcome to this calming experience.");
    stageCounter = 1;
    println("stageCounter = " + stageCounter);
  }

  // near instruction
  if (stageCounter == 1) {
    tts.speak("Please put your left hand near the side of the cube.");
    if (left < 100) {
      tts.speak("good job");
      stageCounter = 2;
      println("stageCounter = " + stageCounter);
    }
  }

  // middle instruction
  if (stageCounter == 2) {
    tts.speak("now move your hand a bit farther away from the cube, between 10 and 20 centimeters.");
    if (left < 200 & left > 100) {
      tts.speak("good job");
      stageCounter = 3;
      println("stageCounter = " + stageCounter);
    }
  }

  // far instruction
  if (stageCounter == 3) {
    tts.speak("now move your hand even farther, between 30 and 50 centimeters from the cube.");
    if (left > 300) {
      tts.speak("good job");
      delay(500);
      tts.speak("now we will begin to use your hand's movement and your breathing to calm you down");

      stageCounter = 4;
      println("stageCounter = " + stageCounter);
    }
  }

  // first breathing exercise instruction
  if (stageCounter == 4) {
    tts.speak("Begin by putting your left hand near the side of the cube.");
    if (left < 100) {
      tts.speak("good job.");
      stageCounter = 5;
      println("stageCounter = " + stageCounter);
    }
  }

  // second breathing exercise instruction
  if (stageCounter == 5) {
    tts.speak("now move your hand far to the left, between 30 and 50 centimeters from the cube.");
    if (left < 500 && left > 300) {
      tts.speak("wonderful.");
      delay(500);
      tts.speak("notice how you can change the red brightness by moving your left hand back and forth");
      startTime = millis();
      stageCounter = 6;
      println("stageCounter = " + stageCounter);
    }
  }

  // red light adjustment demonstration for 10 seconds, and follow-on instructions
  if (stageCounter == 6) {
    if (millis() - startTime < 10000) redAdjuster();
    else {
      tts.speak("now we're going to breathe.");
      tts.speak("first, move your hand back and forth to match the brightness of the red");
      stageCounter = 7;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // red (left hand) breathing for 10 seconds, matching the indicated brightness, then test for accuracy for 10 seconds
  if (stageCounter == 7) {
    if (millis() - startTime < 10000) {
      redBreathe(); // just run it for 10 seconds to start
    } else if (millis() - startTime < 20000) { // then test for accuracy for the following 10 seconds
      if ( abs(redBreathe()) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE, 290);
      }
    } else { 
      tts.speak("the red light tells you when to breathe and how to move your hand");
      delay(500);
      tts.speak("now you'll move your right hand back and forth to match the blue light");
      stageCounter = 8;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // adding in blue (right hand) breathing
  if (stageCounter == 8) {
    if (millis() - startTime < 10000) {
      blueBreathe(0); // just run it for 10 seconds to start
    } else if (millis() - startTime < 20000) { // then test for accuracy for the following 10 seconds
      if ( abs(blueBreathe(0)) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE + 250, 290);
      }
    } else { 
      tts.speak("now let's try both together at the same time, expanding and contracting");
      stageCounter = 9;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // both hands at the same time moving oppositely
  if (stageCounter == 9) {
    if (millis() - startTime < 20000) {
      if ( abs(blueBreathe(0)) > 50) { // argument 0 to blueBreathe makes it move oppositely to redBreathe
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE + 250, 290);
      }
      if ( abs(redBreathe()) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE, 290);
      }
    } else { 
      tts.speak("now make a nice gentle wave, keeping both hands the same distance apart, swishing back and forth");
      stageCounter = 10;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // both hands at the same time in synchrony
  if (stageCounter == 10) {
    if (millis() - startTime < 20000) {
      if ( abs(blueBreathe(1)) > 50) { // argument 1 to blueBreathe makes it move in synchrony with redBreathe
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE + 250, 290);
      }
      if ( abs(redBreathe()) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE, 290);
      }
    } else { 
      tts.speak("great");
      stageCounter = 11;
      println("stageCounter = " + stageCounter);
    }
  }


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
   
   */

  /*

   ///////// this logic still isn't written quite correctly…
   
   if (!redAdjusterStarted) {
   tts.speak("notice how you can change the red brightness by moving your left hand back and forth");
   
   redAdjusterStartTime = millis();
   redAdjusterStarted = true;
   }
   
   
   // run redAdjuster for 10 seconds
   if (millis() - redAdjusterStartTime < 10000) redAdjuster(); // run redAdjuster for 10 seconds
   else { // and then move on from it afterwards
   beginRedBreathe = true;
   tts.speak("now we're going to breathe.");
   tts.speak("first, move your hand back and forth to match the brightness of the red");
   }
   
   ///////// still not quite right
   
   
   if (beginRedBreathe) {
   if (!redBreatheStarted) { // if it hasn't started
   redBreatheStartTime = millis(); // start the timer
   redBreatheStarted = true; // and mark the flag
   }
   }
   
   
   if (millis() - redBreatheStartTime < 10000) {
   // if this is a while loop, it breaks everything; if it's an if, it works fine
   if ( abs(redBreathe()) > 50) {
   stroke(255);
   //tts.speak("better!");  // speech is blocking, so messes this up
   text("DO BETTER", TASKAREALEFTEDGE, 290);
   }
   }
   
   if ( abs(blueBreathe()) > 50) {
   stroke(255);
   //tts.speak("better!");  // speech is blocking, so messes this up
   text("DO BETTER", TASKAREALEFTEDGE+250, 290);
   }
   
   */

  //redBreathe();
  //blueBreathe();

  // graduate to the next mode once this sequence is complete
  if (stageCounter == 11) {
    mode = Mode.CALMING;
    stageCounter = 0;
    startTime = millis();
  }
}

void calming() {
  // both hands at the same time moving oppositely for 25 seconds
  // instead of criticism, positive reinforcement of good pace
  if (millis() - startTime < 25000) {
    if ( abs(blueBreathe(0)) < 50) { // argument 0 to blueBreathe makes it move oppositely to redBreathe
      stroke(255);
      text("you're doing great", TASKAREALEFTEDGE + 250, 290);
    }
    if ( abs(redBreathe()) < 50) {
      stroke(255);
      text("you're doing great", TASKAREALEFTEDGE, 290);
    }

    // breathing reminder at 10 seconds in
    if (millis() - startTime < 15000 && millis() - startTime > 14000) {
      tts.speak("remember to breathe with your hands");
    }
  } else { // after 25 seconds, change modes
    mode = Mode.DISORIENTATION;
  }
}

void disorientation() {
  //greenBreathe(0);
  redBreathe();
  blueBreathe(0);
}

void interrogation() {
}

void termination() {
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
