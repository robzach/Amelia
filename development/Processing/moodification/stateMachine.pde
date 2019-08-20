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

  // graduate to the next mode once this sequence is complete
  mode = Mode.CALMING;
}

void calming() {
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
  
  
  
}

void disorientation() {
}

void interrogation() {
}

void termination() {
}
