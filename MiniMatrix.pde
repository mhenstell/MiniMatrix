#include <FrequencyTimer2.h>

int latch74 = 8; //ST_CP of 74HC595 14
int clock74 = 12; //SH_CP of 74HC595 18
int data74 = 11; //DS of 74HC595 17

int latch6 = 13; //RCK of TPIC6B595 19
int clock6 = 9; //SRCK of TPIC6B595 15
int data6 = 10; //SER IN of TPIC6B595 16
int enable6 = 7; //G of TPIC6B595 13
int clear6 = 6; //SRCLR of TPIC6B595 12

#define height 8
#define width 8
#define RED 0
#define GREEN 1

uint8_t buffer[2][height];

int yPos = 0;
int xPos = 0;

unsigned int frameCount=29;
uint8_t redFrames[29][8]={
{1,0,0,0,0,0,0,0,},
{1,2,0,0,0,0,0,0,},
{1,2,4,0,0,0,0,0,},
{1,2,4,8,0,0,0,0,},
{1,2,4,8,16,0,0,0,},
{1,2,4,8,16,32,0,0,},
{1,2,4,8,16,32,64,0,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{1,2,4,8,16,32,64,128,},
{129,2,4,8,16,32,64,129,},
{129,66,4,8,16,32,66,129,},
{129,66,36,8,16,36,66,129,},
{129,66,36,24,24,36,66,129,},
{129,66,36,16,8,36,66,129,},
{129,66,32,16,8,4,66,129,},
{129,64,32,16,8,4,2,129,},
{128,64,32,16,8,4,2,1,},
{128,64,32,24,24,4,2,1,},
{128,64,36,0,0,36,2,1,},
{128,66,0,0,0,0,66,1,},
{129,0,0,0,0,0,0,129,},
{0,0,0,0,0,0,0,0,},
};

uint8_t greenFrames[29][8]={
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{128,0,0,0,0,0,0,0,},
{128,64,0,0,0,0,0,0,},
{128,64,32,0,0,0,0,0,},
{128,64,32,16,0,0,0,0,},
{128,64,32,16,8,0,0,0,},
{128,64,32,16,8,4,0,0,},
{128,64,32,16,8,4,2,0,},
{128,64,32,16,8,4,2,1,},
{129,64,32,16,8,4,2,129,},
{129,66,32,16,8,4,66,129,},
{129,66,36,16,8,36,66,129,},
{129,66,36,24,24,36,66,129,},
{129,66,36,8,16,36,66,129,},
{129,66,4,8,16,32,66,129,},
{129,2,4,8,16,32,64,129,},
{1,2,4,8,16,32,64,128,},
{1,2,4,24,24,32,64,128,},
{1,2,36,0,0,36,64,128,},
{1,66,0,0,0,0,66,128,},
{129,0,0,0,0,0,0,129,},
{0,0,0,0,0,0,0,0,},
};

unsigned long frameDurations[] = {100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,};


/* Timer2 reload value, globally available */
unsigned int tcnt2;

void setup() {
  //set pins to output so you can control the shift register
  pinMode(latch74, OUTPUT);
  //pinMode(clock74, OUTPUT);
  //pinMode(data74, OUTPUT);
  pinMode(latch6, OUTPUT);
  pinMode(clock6, OUTPUT);
  pinMode(data6, OUTPUT);
  pinMode(enable6, OUTPUT);
  pinMode(clear6, OUTPUT);
  
  Serial.begin(9600);
  Serial.println("Begin.\n");
  
//  TIMSK1=0x01; // enabled global and timer overflow interrupt;
//  TCCR1A = 0x00; // normal operation page 148 (mode0);
//  TCNT1=0x0000; // 16bit counter register
//  TCCR1B = 0x04; // start timer/ set clock


 /* First disable the timer overflow interrupt while we're configuring */  
  TIMSK2 &= ~(1<<TOIE2);  
  
  /* Configure timer2 in normal mode (pure counting, no PWM etc.) */  
  TCCR2A &= ~((1<<WGM21) | (1<<WGM20));  
  TCCR2B &= ~(1<<WGM22);  
  
  /* Select clock source: internal I/O clock */  
  ASSR &= ~(1<<AS2);  
  
  /* Disable Compare Match A interrupt enable (only want overflow) */  
  TIMSK2 &= ~(1<<OCIE2A);  
  
  /* Now configure the prescaler to CPU clock divided by 128 */  
  TCCR2B |= (1<<CS22)  | (1<<CS20); // Set bits  
  TCCR2B &= ~(1<<CS21);             // Clear bit  
  
  /* We need to calculate a proper value to load the timer counter. 
   * The following loads the value 131 into the Timer 2 counter register 
   * The math behind this is: 
   * (CPU frequency) / (prescaler value) = 125000 Hz = 8us. 
   * (desired period) / 8us = 125. 
   * MAX(uint8) + 1 - 125 = 131; 
   */  
  /* Save value globally for later reload in ISR */  
  tcnt2 = 131;   
  
  /* Finally load end enable the timer */  
  TCNT2 = tcnt2;  
  TIMSK2 |= (1<<TOIE2); 

  
}

void loop() {
  

  playAnimation();


}

void playAnimation() {
  
  for (int frame = 0; frame < frameCount; frame++) {
     for (int row = 0; row < height; row++) {
       //redBuffer[row] = redFrames[frame][row];
       //greenBuffer[row] = greenFrames[frame][row];
       buffer[RED][row] = redFrames[frame][row];
       buffer[GREEN][row] = greenFrames[frame][row];
     }
     
     
    delay(frameDurations[frame]);
  }

  
  
}





void counter() {
  for (int color = 0; color < 2; color++) {
    for (int y = 0; y < width; y++) {
      for (int numberToDisplay = 0; numberToDisplay < 256; numberToDisplay++) {
        //buffer[color][y] = numberToDisplay;
        delay(10);
      }
    }
  }
}

void staticImage() {
//  buffer[0][0] = B10101010;
//  buffer[0][1] = B01010101;
//  buffer[0][2] = B10101010;
//  buffer[0][3] = B01010101;
//  buffer[0][4] = B10101010;
//  buffer[0][5] = B01010101;
//  buffer[0][6] = B10101010;
//  buffer[0][7] = B01010101;
//  
//
//  buffer[1][0] = B01010101;
//  buffer[1][1] = B10101010;
//  buffer[1][2] = B01010101;
//  buffer[1][3] = B10101010;
//  buffer[1][4] = B01010101;
//  buffer[1][5] = B10101010;
//  buffer[1][6] = B01010101;
//  buffer[1][7] = B10101010;
}

ISR(TIMER2_OVF_vect) {  
  /* Reload the timer */  
  TCNT2 = tcnt2;  
  /* Write to a digital pin so that we can confirm our timer */  
  display();
}  

void display() {
   
  digitalWrite(enable6, HIGH); //Turn off row
  
  yPos++;
  if (yPos == height) yPos = 0;
  
  selectRow(yPos);
  
  //Shift out the rows
  digitalWrite(latch74, LOW);
  shiftOut(data74, clock74, buffer[RED][yPos]);
  shiftOut(data74, clock74, buffer[GREEN][yPos]);
  //shiftOut(data74, clock74, redBuffer[yPos]);
  //shiftOut(data74, clock74, greenBuffer[yPos]);
  digitalWrite(latch74, HIGH); 
  
  digitalWrite(enable6, LOW); //Turn on row
  
  //dump();

}

void selectRow(int row) {
  digitalWrite(latch6, LOW);
  digitalWrite(clear6, LOW);
  digitalWrite(clear6, HIGH);
   
  shiftOut(data6, clock6, MSBFIRST, 1 << row);
  //shiftOut(data6, clock6, MSBFIRST, 0x01);

  digitalWrite(latch6, HIGH);
}



void shiftOut(int myDataPin, int myClockPin, byte myDataOut) {
  // This shifts 8 bits out MSB first, 
  //on the rising edge of the clock,
  //clock idles low

  //internal function setup
  int i=0;
  int pinState;
  pinMode(myClockPin, OUTPUT);
  pinMode(myDataPin, OUTPUT);

  //clear everything out just in case to
  //prepare shift register for bit shifting
  digitalWrite(myDataPin, 0);
  digitalWrite(myClockPin, 0);

  //for each bit in the byte myDataOut
  //NOTICE THAT WE ARE COUNTING DOWN in our for loop
  //This means that %00000001 or "1" will go through such
  //that it will be pin Q0 that lights. 
  for (i=7; i>=0; i--)  {
    digitalWrite(myClockPin, 0);

    //if the value passed to myDataOut and a bitmask result 
    // true then... so if we are at i=6 and our value is
    // %11010100 it would the code compares it to %01000000 
    // and proceeds to set pinState to 1.
    if ( myDataOut & (1<<i) ) {
      pinState= 1;
    }
    else {	
      pinState= 0;
    }

    //Sets the pin to HIGH or LOW depending on pinState
    digitalWrite(myDataPin, pinState);
    //register shifts bits on upstroke of clock pin  
    digitalWrite(myClockPin, 1);
    //zero the data pin after shift to prevent bleed through
    digitalWrite(myDataPin, 0);
  }

  //stop shifting
  digitalWrite(myClockPin, 0);
}






void dump() {
 
 for (int y=0; y < height; y++) {
   for (int color = 0; color < 2; color++) {
     for (int bit=0; bit < 7; bit++) {
       //Serial.print((buffer[color][y] & (1<<bit)) > 0);
     }
   
   Serial.print("  ");
   }
   Serial.println("");
 }
 
 Serial.println(" - - - ");
  
}
