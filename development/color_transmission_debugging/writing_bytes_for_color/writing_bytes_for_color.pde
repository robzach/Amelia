import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1410"; // for USB access to the Arduino


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
  //for (byte i = 0; i < 255; i++) {
  //  if (i == 10) continue; // don't send newlines
  //  byte[] writeVals = new byte[4];
  //  writeVals[0] = i;
  //  writeVals[1] = i;
  //  writeVals[2] = i;
  //  writeVals[3] = '\n';
  //  myPort.write(writeVals);
  //  //myPort.write(i + "," + i + "," + i + "\n");
  //  delay(10);
  //}



  // write out bytes, not a string, to the serial port
  // also write out a simple checksum as the last digit
  for (int i = 0; i < 255; i++) {
    if (i == 10) continue; // don't send newlines as data
    byte[] writeVals = new byte[5];
    writeVals[0] = (byte)i;
    writeVals[1] = (byte)i;
    writeVals[2] = (byte)i;
    writeVals[3] = (byte)(i + i + i);
    writeVals[4] = '\n';
    //println("writevals[0] = " + writeVals[0]);
    
    
    //writeVals[0] = i;
    //writeVals[1] = i;
    //writeVals[2] = i;
    //writeVals[3] = byte(writeVals[0] + writeVals[1] + writeVals[2]);
    //writeVals[4] = '\n';
    myPort.write(writeVals);
    //myPort.write(i + "," + i + "," + i + "\n");
    delay(50);
  }
}

byte unsignedByte( int val ) { 
  return (byte)( val > 127 ? val - 256 : val );
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
    print(inString);
  }
  
  //while (myPort.available() > 0) { 
  //  byte[] distVals = new byte[6];
  //  myPort.readBytesUntil(255, distVals);
  //  printArray(distVals);
  //}
}
