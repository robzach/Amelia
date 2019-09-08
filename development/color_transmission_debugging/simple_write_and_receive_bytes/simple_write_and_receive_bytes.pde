import processing.serial.*;
Serial myPort;
String portName = "/dev/cu.usbserial-1410"; // for USB access to the Arduino

// flag: set to true when 255 (end of transmission value) received over serial
boolean finishedListening = true;

byte [] distVals = new byte[5];

void setup() {
  size(400,400);
  myPort = new Serial(this, portName, 9600);
  
}

void draw() {
  background(0);
  byte [] sendVals = new byte[5];
  for (int i = 0; i < 3; i++) sendVals[i] = (byte)(i*10);
  sendVals[3] = (byte)(sendVals[0] + 2*sendVals[1] + 3*sendVals[2]);
  sendVals[4] = (byte)255;

  myPort.write(sendVals);
  updateWindow();
  delay(100);
}

void updateWindow() {
  String displayData = 
    "sensor[0] value received: " + distVals[0] + 
    "\nsensor[1] value received: " + distVals[1] + 
    "\nsensor[2] value received: " + distVals[2] + 
    "\nsensor[3] value received: " + distVals[3];
    
  textSize(24);
  text (displayData, 50, 50);
}

void serialEvent (Serial myPort) {
  while (myPort.available() > 0) { 
    myPort.readBytesUntil(255, distVals);
    for (int i = 0; i < distVals.length; i++){
      //println("recdVals[" + i + "] = " + (byte)recdVals[i]);
    }
    //printArray(recdVals);
  }
}
