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
    for (int i = 0; i < 3; i++) colors[i] = 0;
    transmitBytes();
  }

  // start with left-side-of-box sensor training for 10 seconds
  if (stageCounter == 1) {
    if (millis() - startTime < 5000) redScale();
    else {
      stageCounter = 2;
      startTime = millis();
      for (int i = 0; i < 3; i++) colors[i] = 0;
      transmitBytes();
    }
  }


  // right-side-of-box sensor training for 10 seconds
  if (stageCounter == 2) {
    if (millis() - startTime < 5000) blueScale();
    else {
      stageCounter = 3;
      startTime = millis();
      for (int i = 0; i < 3; i++) colors[i] = 0;
      transmitBytes();
    }
  }

  // top-side-of-box sensor training for 10 seconds
  if (stageCounter == 3) {
    if (millis() - startTime < 5000) greenScale();
    else {
      stageCounter = 4;
      startTime = millis();
      for (int i = 0; i < 3; i++) colors[i] = 0;
      transmitBytes();
    }
  }

  //once complete, revert to IDLE mode
  if (stageCounter == 4) mode = Mode.IDLE;
}


void interrogation() {
}

void termination() {
}
