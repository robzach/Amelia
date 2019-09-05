import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1420"; // for USB access to the Arduino


void setup () {
  // you can adjust height as wanted, and the graphs will scale appropriately
  size(1200, 500); 
  background(0);


  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
}

void draw() {

  int r = 0;
  int g = 0;
  int b = 0;

  // write out bytes, not a string, to the serial port
  for (byte i = 0; i < 255; i++) {
    if (i == 10) continue; // don't send newlines
    byte[] writeVals = new byte[4];
    writeVals[0] = i;
    writeVals[1] = i;
    writeVals[2] = i;
    writeVals[3] = '\n';
    myPort.write(writeVals);
    //myPort.write(i + "," + i + "," + i + "\n");
    delay(10);
  }
}

void keyPressed() {
  println("key pressed");
  if (key == 'r') {
    myPort.write("255,0,0\n"); // red LEDs
    println("wrote red value");
  }
  if (key == 'g') myPort.write("0,255,0\n"); // green LEDs
  if (key == 'b') myPort.write("0,0,255\n"); // blue LEDs
  if (key == 'o') myPort.write("0,0,0\n"); // turn off LEDs
}


void serialEvent (Serial myPort) {
  while (myPort.available() > 0) { 
    // load serial data into inString
    String inString = myPort.readStringUntil('\n');
    //println(inString);
  }
}
