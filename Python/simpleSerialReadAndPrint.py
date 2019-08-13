"""
reads incoming serial data (tab delimited) from Arduino at 9600 baud
and prints it to the console
"""


import serial

# begin serial communication with Arduino at 9600 baud (default, no
# need to specify in the constructor)
ser = serial.Serial('/dev/cu.usbserial-1410')

print(ser.name)

# color designations for testing sending data to Arduino
red = '255,0,0'
green = '0,255,0'
blue = '0,0,255'


while(True):

    # load incoming line of binary data into variable
    line = ser.readline()

    # read from the binary, strip off any newline characters, and print
    if line!='':
        ser.write(str.encode(red+'\n'))
        print ("wrote: " + red+'\n')
        line = line.decode() # turns input from binary mode to string
        inputList = line.split('\t') # assumes tab delimited list
        values = []
        for item in inputList:
            values.append(item.rstrip('\r\n'))
        print (values)
