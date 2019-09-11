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
    break;
  case INTERROGATION:
    if (change) {
      println("entering mode: " + mode);
      prevMode = mode;
      stageCounter = 0; // reset stage counter for new mode
    }
    interrogation();
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
    }
    idle();
    break;
  }
}

long startTime = 0;

void idle() {
  if (millis() - startTime > 1000) {
    println("idling at millis: " + millis());
    startTime = millis();
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
    if (millis() - startTime > 10000) { //10 seconds later
      breaths[0].setActive(false);
      breaths[1] = new Breathe(true, 1, 1000);
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
      startTime = millis();
      stageCounter = 3;
    }
  }

  if (stageCounter == 3) {
    if (millis() - startTime > 10000) { //10 seconds later
      breaths[1].setActive(false);
      breaths[2] = new Breathe(true, 2, 750);
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
      startTime = millis();
      stageCounter = 4;
    }
  }

  if (stageCounter == 4) {
    if (millis() - startTime > 10000) { //10 seconds later
      breaths[2].setActive(false);
      breaths[1] = new Breathe(true, 0, 1000);
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
      startTime = millis();
      stageCounter = 5;
    }
  }

  if (stageCounter == 5) {
    if (millis() - startTime > 10000) { //10 seconds later
      breaths[1].setActive(false);
      breaths[0] = new Breathe(true, 0, 1000);
      delay(500);
      breaths[2] = new Breathe(true, 2, 1000);
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
      startTime = millis();
      stageCounter = 6;
    }
  }

  if (stageCounter == 6) {
    if (millis() - startTime > 10000) { // 10 seconds later
      breaths[0].setActive(false);
      breaths[2].setActive(false);
      for (int i = 0; i < 3; i++) colors[i] = 0; // zero out colors
      stageCounter = 7;
    }
  }

  if (stageCounter == 7) mode = Mode.TERMINATION;


  // updates all breathing functions, only for those objects currently wanting to be run
  for (Breathe breath : breaths) {
    if (breath.getActive()) {
      breath.pollBreathe();
    }
  }
}

void termination() {
  
  // flashes red a bunch of times quickly
  // (blocking code! Probably doesn't matter at this point, though)
  for (int i = 0; i < 20; i++) {
    colors[0] = 254;
    transmitBytes();
    delay(50);
    colors[0] = 0;
    transmitBytes();
    delay(50);
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
