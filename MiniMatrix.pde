#include <FrequencyTimer2.h>

int latch74 = 8; //ST_CP of 74HC595
int clock74 = 12; //SH_CP of 74HC595
int data74 = 11; //DS of 74HC595

int latch6 = 13; //RCK of TPIC6B595
int clock6 = 9; //SRCK of TPIC6B595
int data6 = 10; //SER IN of TPIC6B595
int enable6 = 7; //G of TPIC6B595
int clear6 = 6; //SRCLR of TPIC6B595

#define height 8
#define width 8

uint8_t buffer[height];

int yPos = 0;
int xPos = 0;

void setup() {
  //set pins to output so you can control the shift register
  pinMode(latch74, OUTPUT);
  pinMode(clock74, OUTPUT);
  pinMode(data74, OUTPUT);
  pinMode(latch6, OUTPUT);
  pinMode(clock6, OUTPUT);
  pinMode(data6, OUTPUT);
  pinMode(enable6, OUTPUT);
  pinMode(clear6, OUTPUT);
  
  pinMode(13, OUTPUT);
  
  Serial.begin(9600);
  Serial.println("Begin.");
  
//  for (int y=0; y < height; y++) {
//    buffer[y] = 0; 
//  }
  

}

void loop() {

  for (int y = 0; y < height; y++) {
    PORTB ^= _BV(5);
    
    for (int numberToDisplay = 0; numberToDisplay < 256; numberToDisplay++) {
      buffer[y] = numberToDisplay;

      dump();
      delay(1000);
    }
  }
  
  
}

void display() {
   
  digitalWrite(enable6, HIGH); //Turn off column
  
  yPos++;
  if (yPos == width) yPos = 0;
   
  //Shift out the rows
  digitalWrite(latch74, LOW);
  shiftOut(data74, clock74, MSBFIRST, buffer[yPos]);
  digitalWrite(latch74, HIGH); 
  
  digitalWrite(enable6, LOW); //Turn on column

}

void dump() {
 
 for (int y=0; y < height; y++) {
   Serial.println(buffer[y], HEX);
 }
 
 Serial.println(" - - - ");
  
}

void selectColumn(int col) {
  digitalWrite(latch6, LOW);
   
  digitalWrite(clear6, LOW);
  digitalWrite(clear6, HIGH);
   
  shiftOut(data6, clock6, MSBFIRST, 1 << col);
   
   
  digitalWrite(latch6, HIGH);
}
