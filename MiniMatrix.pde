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

unsigned int frameCount = 29;

unsigned int frames[100][8] PROGMEM = {
{0,0,0,0,0,0,0,0,},
{0,0,0,0,0,0,0,0,},
{256,0,0,0,0,0,0,0,},
{512,256,0,0,0,0,0,0,},
{1024,512,256,0,0,0,0,0,},
{264,1024,512,256,0,0,0,0,},
{528,264,1024,512,256,0,0,0,},
{8196,528,264,1024,512,256,0,0,},
{16648,8196,528,264,1024,512,256,0,},
{32786,16648,8196,528,264,1024,512,256,},
{8196,32786,16648,8196,528,264,1024,768,},
{16393,8196,32786,16648,8196,528,264,1792,},
{32786,16393,8196,32786,16648,8196,784,1800,},
{36,32786,16393,36,32786,16648,8964,1816,},
{73,36,32786,16393,36,33042,17164,10008,},
{32786,73,36,32786,16393,294,33564,26392,},
{36,32786,73,36,32787,16654,828,59160,},
{73,36,32786,73,39,33054,17212,59160,},
{146,73,36,32787,79,318,49980,59160,},
{36,146,73,39,32799,382,49980,59160,},
{328,36,147,79,63,33150,49980,59160,},
{146,328,39,159,127,33150,49980,59160,},
{36,402,79,63,255,33150,49980,59160,},
{2368,294,159,127,255,33150,49980,59160,},
{4992,2374,63,255,255,33150,49980,59160,},
{1824,6534,127,255,255,33150,49980,59160,},
{3904,6438,255,255,255,33150,49980,59160,},
{40704,6502,255,255,255,33150,49980,59160,},
{16128,39270,255,255,255,33150,49980,59160,},
{32512,39270,255,255,255,33150,49980,59160,},
{65280,39270,255,255,255,33150,49980,59160,},
{65280,39270,255,255,255,33150,49980,59160,},
{65280,39270,255,255,255,33150,49980,59160,},
{65280,39270,255,255,255,33150,49980,59160,},
{65280,39270,255,6399,6399,33150,49980,59160,},
{65280,39270,6399,15615,15615,39294,49980,59160,},
{65280,39270,15615,32511,32511,48510,56124,59160,},
{65280,48486,32511,65535,65535,65406,65340,65304,},
{65280,65382,65535,59391,59391,65406,65340,65304,},
{65280,65382,59391,50175,50175,59262,65340,65304,},
{65280,65382,50175,33279,33279,50046,59196,65304,},
{65280,56166,33279,255,255,33150,49980,59160,},
{65280,39270,255,255,255,33150,49980,59160,},
{65280,39270,255,6399,6399,33150,49980,59160,},
{65280,39270,6399,15615,15615,39294,49980,59160,},
{65280,39270,15615,32511,32511,48510,56124,59160,},
{65280,48486,32511,65535,65535,65406,65340,65304,},
{65280,65382,65535,59391,59391,65406,65340,65304,},
{65280,65382,59391,50175,50175,59262,65340,65304,},
{65280,65382,50175,33279,33279,50046,59196,65304,},
{65280,56166,33279,255,255,33150,49980,59160,},
{65280,65382,65535,65535,65535,65406,65340,65304,},
{65280,39270,255,6375,6375,33150,49980,59160,},
{65280,39270,6375,15555,15555,39270,49980,59160,},
{65280,39270,15555,32385,32385,48450,56100,59160,},
{65280,48450,32385,65280,65280,65280,65280,65280,},
{65280,65280,65280,65280,65280,65280,65280,65280,},
{65280,65280,65280,65280,65280,65280,65280,65280,},
{65024,65280,65280,65280,65280,65280,65280,65280,},
{64768,65024,65280,65280,65280,65280,65280,65280,},
{64000,64768,65024,65280,65280,65280,65280,65280,},
{62720,64000,64768,65024,65280,65280,65280,65280,},
{59904,62720,64000,64768,65024,65280,65280,65280,},
{54528,59904,62720,64000,64768,65024,65280,65280,},
{43520,54528,59904,62720,64000,64768,65024,65280,},
{21504,43520,54528,59904,62720,64000,64768,65024,},
{43264,21504,43520,54528,59904,62720,64000,64768,},
{20992,43264,21504,43520,54528,59904,62720,64000,},
{41984,20992,43264,21504,43520,54528,59904,62720,},
{18688,41984,20992,43264,21504,43520,54528,59904,},
{37376,18688,41984,20992,43264,21504,43520,54528,},
{9216,37376,18688,41984,20992,43264,21504,43520,},
{18688,9216,37376,18688,41984,20992,43264,21504,},
{37376,18688,9216,37376,18688,41984,20992,43264,},
{9216,37376,18688,9216,37376,18688,41984,20992,},
{18432,9216,37376,18688,9216,37376,18688,41984,},
{37120,18432,9216,37376,18688,9216,37376,18688,},
{8704,37120,18432,9216,37376,18688,9216,37376,},
{17408,8704,37120,18432,9216,37376,18688,9216,},
{34816,17408,8704,37120,18432,9216,37376,18688,},
{4352,34816,17408,8704,37120,18432,9216,37376,},
{8704,4352,34816,17408,8704,37120,18432,9216,},
{17408,8704,4352,34816,17408,8704,37120,18432,},
{34816,17408,8704,4352,34816,17408,8704,37120,},
{4096,34816,17408,8704,4352,34816,17408,8704,},
{8448,4096,34816,17408,8704,4352,34816,17408,},
{16896,8448,4096,34816,17408,8704,4352,34816,},
{33792,16896,8448,4096,34816,17408,8704,4352,},
{2048,33792,16896,8448,4096,34816,17408,8704,},
{4096,2048,33792,16896,8448,4096,34816,17408,},
{8192,4096,2048,33792,16896,8448,4096,34816,},
{16384,8192,4096,2048,33792,16896,8448,4096,},
{32768,16384,8192,4096,2048,33792,16896,8448,},
{0,32768,16384,8192,4096,2048,33792,16896,},
{0,0,32768,16384,8192,4096,2048,33792,},
{0,0,0,32768,16384,8192,4096,2048,},
{0,0,0,0,32768,16384,8192,4096,},
{0,0,0,0,0,32768,16384,8192,},
{0,0,0,0,0,0,32768,16384,},
{0,0,0,0,0,0,0,32768,},
};

unsigned long frameDurations[] = {100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,};


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
  
  Serial.begin(9600);
  Serial.println("Begin.\n");

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
       buffer[row] = pgm_read_word(&frames[frame][row]);
     }

    delay(frameDurations[frame]);
  }
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
