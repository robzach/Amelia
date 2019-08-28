void calming() {
  // both hands at the same time moving oppositely for 25 seconds
  // instead of criticism, positive reinforcement of good pace
  if (millis() - startTime < 25000) {
    if ( abs(blueBreathe(0)) < 50) { // argument 0 to blueBreathe makes it move oppositely to redBreathe
      stroke(255);
      text("you're doing great", TASKAREALEFTEDGE + 250, 290);
    }
    if ( abs(redBreathe()) < 50) {
      stroke(255);
      text("you're doing great", TASKAREALEFTEDGE, 290);
    }

    // breathing reminder at 10 seconds in
    if (millis() - startTime < 15000 && millis() - startTime > 14000) {
      tts.speak("remember to breathe with your hands");
    }
  } else { // after 25 seconds, change modes
    mode = Mode.DISORIENTATION;
  }
}

void introSequence() {

  // welcome sentence
  if (stageCounter == 0) {
    println("stageCounter = " + stageCounter);
    tts.speak("welcome to this calming experience.");
    stageCounter = 1;
    println("stageCounter = " + stageCounter);
  }

  // near instruction
  if (stageCounter == 1) {
    tts.speak("Please put your left hand near the side of the cube.");
    if (left < 100) {
      tts.speak("good job");
      stageCounter = 2;
      println("stageCounter = " + stageCounter);
    }
  }

  // middle instruction
  if (stageCounter == 2) {
    tts.speak("now move your hand a bit farther away from the cube, between 10 and 20 centimeters.");
    if (left < 200 & left > 100) {
      tts.speak("good job");
      stageCounter = 3;
      println("stageCounter = " + stageCounter);
    }
  }

  // far instruction
  if (stageCounter == 3) {
    tts.speak("now move your hand even farther, between 30 and 50 centimeters from the cube.");
    if (left > 300) {
      tts.speak("good job");
      delay(500);
      tts.speak("now we will begin to use your hand's movement and your breathing to calm you down");

      stageCounter = 4;
      println("stageCounter = " + stageCounter);
    }
  }

  // first breathing exercise instruction
  if (stageCounter == 4) {
    tts.speak("Begin by putting your left hand near the side of the cube.");
    if (left < 100) {
      tts.speak("good job.");
      stageCounter = 5;
      println("stageCounter = " + stageCounter);
    }
  }

  // second breathing exercise instruction
  if (stageCounter == 5) {
    tts.speak("now move your hand far to the left, between 30 and 50 centimeters from the cube.");
    if (left < 500 && left > 300) {
      tts.speak("wonderful.");
      delay(500);
      tts.speak("notice how you can change the red brightness by moving your left hand back and forth");
      startTime = millis();
      stageCounter = 6;
      println("stageCounter = " + stageCounter);
    }
  }

  // red light adjustment demonstration for 10 seconds, and follow-on instructions
  if (stageCounter == 6) {
    if (millis() - startTime < 10000) redAdjuster();
    else {
      tts.speak("now we're going to breathe.");
      tts.speak("first, move your hand back and forth to match the brightness of the red");
      stageCounter = 7;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // red (left hand) breathing for 10 seconds, matching the indicated brightness, then test for accuracy for 10 seconds
  if (stageCounter == 7) {
    if (millis() - startTime < 10000) {
      redBreathe(); // just run it for 10 seconds to start
    } else if (millis() - startTime < 20000) { // then test for accuracy for the following 10 seconds
      if ( abs(redBreathe()) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE, 290);
      }
    } else { 
      tts.speak("the red light tells you when to breathe and how to move your hand");
      delay(500);
      tts.speak("now you'll move your right hand back and forth to match the blue light");
      stageCounter = 8;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // adding in blue (right hand) breathing
  if (stageCounter == 8) {
    if (millis() - startTime < 10000) {
      blueBreathe(0); // just run it for 10 seconds to start
    } else if (millis() - startTime < 20000) { // then test for accuracy for the following 10 seconds
      if ( abs(blueBreathe(0)) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE + 250, 290);
      }
    } else { 
      tts.speak("now let's try both together at the same time, expanding and contracting");
      stageCounter = 9;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // both hands at the same time moving oppositely
  if (stageCounter == 9) {
    if (millis() - startTime < 20000) {
      if ( abs(blueBreathe(0)) > 50) { // argument 0 to blueBreathe makes it move oppositely to redBreathe
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE + 250, 290);
      }
      if ( abs(redBreathe()) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE, 290);
      }
    } else { 
      tts.speak("now make a nice gentle wave, keeping both hands the same distance apart, swishing back and forth");
      stageCounter = 10;
      println("stageCounter = " + stageCounter);
      startTime = millis();
    }
  }

  // both hands at the same time in synchrony
  if (stageCounter == 10) {
    if (millis() - startTime < 20000) {
      if ( abs(blueBreathe(1)) > 50) { // argument 1 to blueBreathe makes it move in synchrony with redBreathe
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE + 250, 290);
      }
      if ( abs(redBreathe()) > 50) {
        stroke(255);
        //tts.speak("better!");  // speech is blocking, so messes this up
        text("DO BETTER", TASKAREALEFTEDGE, 290);
      }
    } else { 
      tts.speak("great");
      stageCounter = 11;
      println("stageCounter = " + stageCounter);
    }
  }


  /*
  tts.speak("welcome to this calming experience.");
   
   // make the user put their hand close to the cube first
   do {
   tts.speak("Please put your left hand near the side of the cube.");
   if (left < 100) tts.speak("good job");
   } while (left > 100); // while (outside of goal)
   
   // make the user move their hand a bit farther away
   do {
   tts.speak("now move your hand a bit farther away from the cube, between 10 and 20 centimeters.");
   if (left < 200 && left > 100) tts.speak("good job");
   } while (left > 200 || left < 100); // while (outside of goal)
   
   // make the user move their hand farther yet
   do {
   tts.speak("now move your hand even farther, between 30 and 50 centimeters from the cube.");
   if (left < 500 && left > 300) tts.speak("wonderful.");
   } while (left > 500 || left < 300); // while (outside of goal)
   
   
   // The below section trains the user how to use the red brightness to properly time their hand movements.
   
   tts.speak("now we will begin to use your hand's movement and your breathing to calm you down");
   
   // make the user put their hand close to the cube first
   do {
   tts.speak("Begin by putting your left hand near the side of the cube.");
   if (left < 100) tts.speak("good job");
   } while (left > 100); // while (outside of goal)
   
   // make the user move their hand far away
   do {
   tts.speak("now move your hand far to the left, between 30 and 50 centimeters from the cube.");
   if (left < 500 && left > 300) tts.speak("wonderful.");
   } while (left > 500 || left < 300); // while (outside of goal)
   
   */

  /*

   ///////// this logic still isn't written quite correctly…
   
   if (!redAdjusterStarted) {
   tts.speak("notice how you can change the red brightness by moving your left hand back and forth");
   
   redAdjusterStartTime = millis();
   redAdjusterStarted = true;
   }
   
   
   // run redAdjuster for 10 seconds
   if (millis() - redAdjusterStartTime < 10000) redAdjuster(); // run redAdjuster for 10 seconds
   else { // and then move on from it afterwards
   beginRedBreathe = true;
   tts.speak("now we're going to breathe.");
   tts.speak("first, move your hand back and forth to match the brightness of the red");
   }
   
   ///////// still not quite right
   
   
   if (beginRedBreathe) {
   if (!redBreatheStarted) { // if it hasn't started
   redBreatheStartTime = millis(); // start the timer
   redBreatheStarted = true; // and mark the flag
   }
   }
   
   
   if (millis() - redBreatheStartTime < 10000) {
   // if this is a while loop, it breaks everything; if it's an if, it works fine
   if ( abs(redBreathe()) > 50) {
   stroke(255);
   //tts.speak("better!");  // speech is blocking, so messes this up
   text("DO BETTER", TASKAREALEFTEDGE, 290);
   }
   }
   
   if ( abs(blueBreathe()) > 50) {
   stroke(255);
   //tts.speak("better!");  // speech is blocking, so messes this up
   text("DO BETTER", TASKAREALEFTEDGE+250, 290);
   }
   
   */

  //redBreathe();
  //blueBreathe();

  // graduate to the next mode once this sequence is complete
  if (stageCounter == 11) {
    mode = Mode.CALMING;
    stageCounter = 0;
    startTime = millis();
  }
}
