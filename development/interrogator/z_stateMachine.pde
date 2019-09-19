void stateMachine() {
  // only print console feedback "entering mode: MODE" if changed from prior mode (for debugging)
  boolean change = (prevMode != mode) ? true : false;

  switch (mode) {
  case ORIENTATION:
    if (change) {
      println("entering mode: " + mode);
      prevMode = mode;
      // when just entering mode, set counter to 0
      stageCounter = 0; // used to step through stages in orientation
    }
    orientation(); 

    // if start signal received while in Orientation, move to idle
    if (braceletTap) {
      braceletTap = false; // flip it back after acknowledge
      mode = Mode.IDLE;
    }
    break;
  case INTERROGATION:
    if (change) {
      println("entering mode: " + mode);
      prevMode = mode;
      stageCounter = 0; // reset stage counter for new mode
    }
    interrogation();

    // if start signal received while in interrogation, move to idle
    if (braceletTap) {
      braceletTap = false; // flip it back after acknowledge
      mode = Mode.IDLE;
    }
    break;
  case TERMINATION: 
    if (change) {
      println("entering mode: " + mode);
      prevMode = mode;
    }
    termination(); 
    break;
  case IDLE:
  default:
    if (change) {
      println("entering mode: " + mode);
      prevMode = mode;

      // triggers once upon entering IDLE mode
      // slow fading in and out of white
      breaths[0] = new Breathe(true, 0, 15000);  // red
      breaths[1] = new Breathe(true, 1, 15000); // green
      breaths[2] = new Breathe(true, 2, 15000); // blue
    }

    idle();

    // if start signal received, move to orientation mode
    if (braceletTap) {
      braceletTap = false; // flip it back after acknowledge
      mode = Mode.ORIENTATION;
    }

    break;
  }
}

long startTime = 0;

void idle() {
  if (millis() - startTime > 1000) {
    println("idling at millis: " + millis());
    startTime = millis();
  }

  // updates all breathing functions, only for those objects currently wanting to be run
  for (Breathe breath : breaths) {
    if (breath.getActive()) {
      breath.pollBreathe();
    }
  }
}

void orientation() {
  // start timer to begin
  if (stageCounter == 0) {
    startTime = millis(); 
    stageCounter = 1;
    for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
    transmitBytes();
  }

  // start with left-side-of-box sensor training for 10 seconds
  if (stageCounter == 1) {
    if (millis() - startTime < 10000) redScale();
    else {
      stageCounter = 2;
      startTime = millis();
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
    }
  }


  // right-side-of-box sensor training for 10 seconds
  if (stageCounter == 2) {
    if (millis() - startTime < 10000) blueScale();
    else {
      stageCounter = 3;
      startTime = millis();
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
    }
  }

  // top-side-of-box sensor training for 10 seconds
  if (stageCounter == 3) {
    if (millis() - startTime < 10000) greenScale();
    else {
      stageCounter = 4;
      startTime = millis();
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
    }
  }

  //once complete, revert to IDLE mode
  if (stageCounter == 4) mode = Mode.INTERROGATION;
}


void interrogation() {
  // pulse different lights up and down through a sequence of brightnesses
  // these are described by the switch(case) statements below (as is the 

  if (millis() > nextSingleTime) {
    int stepTime = 0;
    switch(counter) {
    case 0:
      breaths[0] = new Breathe(true, 0, 2000);  // red breathing sequence
      stepTime = 10000;
      break;
    case 1:
      breaths[0].setActive(false);
      breaths[1] = new Breathe(true, 1, 1000); // green breathing sequence
      stepTime = 10000;
      break;
    case 2:
      breaths[1].setActive(false);
      breaths[2] = new Breathe(true, 2, 750); // blue breathing sequence
      stepTime = 10000;
      break;
    case 3:
      breaths[2].setActive(false);
      breaths[1] = new Breathe(true, 0, 1000); // red breathing sequence
      stepTime = 10000;
      break;
    case 4:
      breaths[1].setActive(false);
      breaths[0] = new Breathe(true, 0, 1000); // red breathing sequence
      stepTime = 500;
      break;
    case 5:
      // note that breaths[2] is still running from the previous case
      breaths[2] = new Breathe(true, 2, 1000); // blue sequence to run concurrently with red
      stepTime = 9500;
      break;
    case 6:
      breaths[0].setActive(false); // turn everything off
      breaths[2].setActive(false); // turn everything off
      break;
    case 7:
      mode = Mode.TERMINATION;
      break;
    default:  // if it breaks, go to IDLE mode
      mode = Mode.IDLE;
      break;
    }
    counter++; // increment for next case to get called next time
    for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors in between steps
    nextSingleTime = millis() + stepTime; // set up next time this if goes true
  }

  // updates all breathing functions, only for those objects currently wanting to be run
  for (Breathe breath : breaths) {
    if (breath.getActive()) {
      breath.pollBreathe();
    }
  }
}

void termination() {

  // flashes red and blue a bunch of times quickly
  // (blocking code! Probably doesn't matter at this point, though)
  for (int i = 0; i < 20; i++) {
    colors[0] = 254; // red
    colors[2] = 0; // no blue
    transmitBytes();
    delay(100);
    colors[0] = 0; // no red
    colors[2] = 255; // blue
    transmitBytes();
    delay(100);
  }
  mode = Mode.IDLE;
}


/*
old version using individually called pollBreathe() functions
 void interrogation() {
 // pulse different lights up and down through a sequence of brighnesses
 
 if (stageCounter == 0) {
 startTime = millis(); 
 for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
 transmitBytes();
 stageCounter = 1;
 }
 
 if (stageCounter == 1) {
 breaths[0] = new Breathe(true, 0, 2000);  // begin red breathing sequence
 startTime = millis();
 stageCounter = 2;
 }
 
 if (stageCounter == 2) {
 if (millis() - startTime < 10000) { // if it's been less than 10 seconds
 breaths[0].pollBreathe(); // update that one breath command
 println(breaths[0].testBreathe());
 } else { // it's been more than 10 seconds
 breaths[1] = new Breathe(2, 1500); // begin blue breathing sequence
 for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
 startTime = millis();
 stageCounter = 3;
 }
 }
 
 if (stageCounter == 3) {
 if (millis() - startTime < 10000) { 
 breaths[1].pollBreathe(); // run breaths[1]
 } else {
 breaths[2] = new Breathe(1, 1000);
 for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
 startTime = millis();
 stageCounter = 4;
 }
 }
 
 if (stageCounter == 4) {
 if (millis() - startTime < 10000) { 
 breaths[2].pollBreathe(); // run breaths[2]
 } else {
 stageCounter = 5;
 }
 }
 
 if (stageCounter == 5) mode = Mode.IDLE;
 }
 */
