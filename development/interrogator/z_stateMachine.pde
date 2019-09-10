void stateMachine() {
  // only print console feedback "entering mode: MODE" if changed from prior mode (for debugging)
  boolean change = (prevMode != mode) ? true : false;

  switch (mode) {
  case IDLE:
  default:
    if (change) {
      println("entering mode: " + mode);
      prevMode = mode;
    }
    idle();
    break;
  case ORIENTATION:
    if (change) {
      println("entering mode: " + mode);
      prevMode = mode;
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
  }
}
