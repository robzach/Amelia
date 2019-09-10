void setup(){
  //for (byte i = 0; i < 256; i++){
  //  println("val: " + i + ", unsignedByte(val) = " + unsignedByte(i));
  //}
  
  //for (byte b = -127; b < 129; b++) println(byteToInt(b));
  for (int i = 0; i < 256; i++) println(intToByte(i));
}

void draw(){}

byte unsignedByte( int val ) { 
  return (byte)( val > 127 ? val - 256 : val );
}

int byteToInt(byte b){
  return ( b < 127 ? b : 255 + b);
}

byte intToByte(int i){
  return (byte)i;
}
