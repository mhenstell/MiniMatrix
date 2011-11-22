#include <avr/pgmspace.h> 

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

unsigned int buffer[height];

int yPos = 0;
int xPos = 0;

//Frame Data


unsigned int frameCount=0;
unsigned int frames[][8] PROGMEM = {

};


/* Timer2 reload value, globally available */
unsigned int tcnt2;

void setup() {
  //set pins to output so you can control the shift register
  pinMode(latch74, OUTPUT);
  pinMode(latch6, OUTPUT);
  pinMode(clock6, OUTPUT);
  pinMode(data6, OUTPUT);
  pinMode(enable6, OUTPUT);
  pinMode(clear6, OUTPUT);

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
  
  for (int frame = 0; frame < frameCount; frame++) {
     for (int row = 0; row < height; row++) {
       buffer[row] = pgm_read_word(&frames[frame][row]);
     }

    //delay(pgm_read_byte(&frameDurations[frame]));
    delay(100);
  }

}

ISR(TIMER2_OVF_vect) {  
  /* Reload the timer */  
  TCNT2 = tcnt2;  
  /* Write to a digital pin so that we can confirm our timer */  
  display();
}  

void display() {
  yPos++;
  if (yPos == height) yPos = 0;
  
  digitalWrite(enable6, HIGH); //Turn off row
  
  selectRow(yPos);
  
  //Shift out the rows
  digitalWrite(latch74, LOW);
  
  shiftOut(data74, clock74, buffer[yPos] >> 8);
  shiftOut(data74, clock74, buffer[yPos]);
  
  digitalWrite(latch74, HIGH); 
  
  digitalWrite(enable6, LOW); //Turn on row
}

void selectRow(int row) {
  digitalWrite(latch6, LOW);
  digitalWrite(clear6, LOW);
  digitalWrite(clear6, HIGH);
  
  shiftOut(data6, clock6, MSBFIRST, 1 << row);

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
