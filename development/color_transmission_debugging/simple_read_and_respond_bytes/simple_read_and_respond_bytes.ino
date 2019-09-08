const int DEBUG_PIN = 10;

int counter = 0;
byte readIn[5];

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(DEBUG_PIN, OUTPUT);
  digitalWrite(DEBUG_PIN, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  //  if (Serial.available()) {
  //    byte readIn[5];
  //    digitalWrite(DEBUG_PIN, LOW);
  //    Serial.readBytesUntil((char)255, readIn, 5);
  //    digitalWrite(DEBUG_PIN, HIGH);
  //
  //
  //
  //    //    Serial.readBytes(readIn, 5);
  //    //    for (int i = 0; i < sizeof(readIn) / sizeof(readIn[0]); i++) {
  //    //      if (readIn[i] == 255)     Serial.write(readIn, sizeof(readIn) / sizeof(readIn[0]));
  //    //
  //    //    }
  //
  //
  //    // echo complete data back to sender
  //    //    if (readIn[4] == 255)
  //    //      Serial.write(readIn, sizeof(readIn) / sizeof(readIn[0]));
  //    //    else Serial.write(10);
  //  }
}

void serialEvent() {
  while (Serial.available()) {
    readIn[counter] = Serial.read();
    if (readIn[counter] < 255) readIn[counter] ++;

    //    byte readIn[5];
    //    digitalWrite(DEBUG_PIN, HIGH);
    //    Serial.readBytesUntil(100, readIn, 5);
    //    digitalWrite(DEBUG_PIN, LOW);
  }

  if (readIn[counter] == 255) { // terminator received
    digitalWrite(DEBUG_PIN, HIGH);

    //    for (int i = 0; i < counter; i++) {
    //      Serial.write(readIn[counter]); //echo only data prior to terminator
    //    }

    Serial.write(readIn, counter); // write values prior to terminator
    Serial.write(255); // and write a terminator at the end
    digitalWrite(DEBUG_PIN, LOW);

    //    Serial.write(readIn, 5); // echo back
    counter = 0; // and reset counter
  }

  else counter++; // otherwise, proceed through loop


  //  counter++;
  //  if (counter == 4) {
  //    Serial.write(readIn, 5);
  //    counter = 0;
  //  }
}
