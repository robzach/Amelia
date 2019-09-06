//char buf[50];

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  char buf[50];
  char vals[4][3];
  if (Serial.readBytesUntil('\n', buf, 50) > 0) {
    //    char * res = NULL;
    //    char res[50] = {' '};
    //
    //    uint8_t *tmpbuf;
    //    tmpbuf = strtok(buf, " ");
    //    while (tmpbuf != NULL) {
    //      Serial.println((char *) tmpbuf);
    //      strtok(NULL, " ");
    //    }

    //char * ptr = NULL;
    //ptr = buf;
    //    ptr = strtok(buf, " ");
    //    Serial.println(ptr);

    for (int i = 0; i < 3; i++) {
      vals[i] = strtok(buf, " ");
    }

    for (int i = 0; i < 3; i++) {
      Serial.print(vals[i] + ",");
    }
    Serial.println();



      //    char * first = strtok(buf, " ");
      //    char * second = strtok(NULL, " ");
      //    char * third = strtok(NULL, " ");
      //
      //    int f = atoi(first);
      //    int s = atoi(second);
      //    int t = atoi(third);
      //
      //    Serial.println(f);
      //    Serial.println(s);
      //    Serial.println(t);


    }


    /*
        char * ptr;
        //    ptr = res;
        while (ptr != NULL) {
          Serial.println(ptr);
          ptr = strtok(buf, " ");
        }
        //    for (int i = 0; i < sizeof(ptr) / sizeof(ptr[0]); i++) {
        //      Serial.print(ptr[i]);
        //      Serial.print(", ");
        //    }
        //    Serial.println(ptr);
      }
    */
  }
