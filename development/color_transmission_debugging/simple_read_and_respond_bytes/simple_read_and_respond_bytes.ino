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
    //    if (readIn[counter] < 255) readIn[counter] ++; // add one to each value, for debugging
  }

  if (readIn[counter] == 255) { // terminator received

    // reply with checksum result followed by terminator
    Serial.write(checksumValid(readIn)); Serial.write(255);

    //    digitalWrite(DEBUG_PIN, HIGH);
    //    Serial.write(readIn, counter); // write values prior to terminator
    //    Serial.write(255); // and write a terminator at the end
    //    digitalWrite(DEBUG_PIN, LOW);

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

boolean checksumValid (byte * arrayIn) {
  int length = sizeof(arrayIn) / sizeof(arrayIn[0]); // this isn't working, don't know why
  byte localChecksum = 0;

  // add zeroth through pen-penultimate element in incoming data
  //    for (int i = 0; i < length - 2; i++) {
  //      localChecksum += (arrayIn[i] * (i + 1));
  //    }

  localChecksum = arrayIn[0] + (arrayIn[1] * 2) + (arrayIn[2] * 3);

  // penultimate element of array is checksum, so compare to penultimate value read in for result
  return (localChecksum == arrayIn[3]);
}
