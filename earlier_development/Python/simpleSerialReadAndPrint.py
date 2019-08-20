"""
reads incoming serial data (tab delimited) from Arduino at 9600 baud
and prints it to the console
"""


import serial
import time

# begin serial communication with Arduino at 9600 baud (default, no
# need to specify in the constructor)
ser = serial.Serial('/dev/cu.usbserial-1410')

print(ser.name)

# color designations for testing sending data to Arduino
red = '255,0,0\n'
green = '0,255,0\n'
blue = '0,0,255\n'



# send data to the port--not yet really working
ser.write(red.encode()) # encode() turns the string into binary
print('sending ' + red)
time.sleep(1)
ser.write(green.encode())
print('sending ' + green)
time.sleep(1)
ser.write(blue.encode())
print('sending ' + blue)


# a blocking loop to read the serial output from the Arduino
# (should be rewritten probably with multithreading?)
while(True):

    # load incoming line of binary data into variable
    line = ser.readline()

    # read from the binary, strip off any newline characters, and print
    if line!='':
        line = line.decode() # turns input from binary mode to string
        inputList = line.split('\t') # assumes tab delimited list
        values = []
        for item in inputList:
            values.append(item.rstrip('\r\n'))
        print (values)
