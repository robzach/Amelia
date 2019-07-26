# 7/19/19: radio weirdness

Note: this is my first entry into this log but very much not the first work done on this project.

I kept running into a failure to transmit error while I was trying to run `ranger_transmitter` and `multi_receiver_print_serial`. I checked the wiring repeatedly and couldn't diagnose the problem. I disconnected the SDA and SCL lines running to the ranger, thinking perhaps they were interfering with the transmission, but that didn't help either. It was especially confusing since I'd been using only lightly modified code, with a nearly identical hardware setup, that worked very well on the Empathy Machine project only about a month ago. (That hardware has continued to work.)

The Empathy Machine code uses an acknowledge packet to return data to the requesting radio, which is a clever way of having one receiving radio that many transmitters send things to: the "receiver" actually sends out packets to one radio at a time, and the recipient of each packet responds only when called on. This prevents collisions and worked just fine the last time I tried it, as I've mentioned.

Shifting to a simpler model, I tried using the `simple_rx` and `simple_tx` sketches (found in the `examples and tests` folder) which mercifully finally worked…with a caveat. For some reason, about half of the packets seemed to be dropped. As in, the transmitter was sending one packet per second, and the receiver would only blink about half the time. Very confusing behavior, for two radios which are a foot apart from each other on a table. Perhaps this is an environment (a university campus) where there's enough 2.4GHz traffic to interfere with these attempts.

One note: I'm watching the little hardware TX lights to see when the transmitter is sending and when the receiver is receiving, and that makes it obvious when they're mismatched (because the transmitter is blinking like twice as much as the receiver). However! The blinking is perfectly in lockstep right until I open the serial connection on the computer attached to the receiver. Are `Serial.println()` executions the problem here? I don't think it's a timing issue, because even when I'm only transmitting one packet a second it's still dropping like half of them. Don't know.

## Next step: wired

I spent more time trying to get these wireless modules to work, and began investigating the strange data loss behavior, but it's a dark rabbit hole. Instead, I'm going to eschew the radio feature entirely—it was only implemented as a way of simplifying the prototyping I want to do. Instead, I'll rewrite the code so the one "receiver" and all the "transmitters" are simply wired together. I'll use software serial on all of them so that I can plug into their hardware UART via the serial monitor to update and debug as needed. And I'll just run a bunch of long wires to each module: two for power, and two for data. Hopefully the cable runs won't be so long that there's data quality problems…probably a 10 foot run won't be too much.

I could just move towards the likely final installation version of this, namely using RS485 modules since that's a safe/reasonable way to move signals over any sort of distance, with easy cabling, etc.

# 7/25/19 wires, but still not quite there

Lots of work was left out of this log, but now I've got all the devices with wired connections on the table. (I never figured out what was wrong with the radio connections.)

Currently all 5 sensors are sharing a UART bus with the data requesting unit, which is plugged into a computer. I have installed diodes on the TX lines of each sensor Arduino (facing *into* the Arduino, counterintuitively) so that the line has transmission integrity, but it's still not quite working right.

I'm only using the UART for one-directional communication. The requesting unit sends a brief pulse into a wire every 1 second, and each remote Arduino has an interrupt that's triggered by a falling voltage on pin `2`, where that's plugged in. Then each unit waits a certain amount of time before sending its data back to the requesting unit on the UART bus.

Important finding: if the remote (sensor) Arduinos aren't plugged into power, but are plugged into ground, then the voltage of the outgoing trigger signal drops unacceptably. Probably an unpowered Arduino doesn't have high impedance on a digital pin, and lets some leakage through to the ground that it *is* plugged into. In conclusion: don't simply unplug power on remote Arduinos for troubleshooting, as it will kill the trigger signal.

Transmission time for the message `#0:1234` at 9600 baud is observed as 9.36ms on the scope. That's good; it means that giving each transmission at 20ms intervals should be plenty of deadband in between.

**Found the problem!** There was a tiny, invisible electrical fault: one of the yellow wires in the UART bus appears to have been mashed into a ground pin, always holding the TX line low. I rearranged the wires and it's fixed. Now all five devices are sending their own data to the requester, reliably.

Next up: try a higher data speed, hopefully while maintaining data integrity. Have been using 9600 baud, and I'll just leap up to 115200 to see what happens. If it's transmitting good data, then the messages can be crammed into a much narrower frame, and more messages can be sent per second overall.

Results: 19200 baud is the fastest baud rate that successfully transmits data across the ~6' twisted wires; above that the inductance and/or capacitance of the wire isn't getting good data to the far end. Of course, using RS485 transmitters would solve this problem entirely and permit for much higher data transmission rates. Requests for new data should be sent no more often than every 200ms, or data from the prior request will overlap and cause errors.