#include <Servo.h>

const int pinLocks[] = { A0, A1, A2, A3 };
const int potentiometerMin = 0;
const int potentiometerMax = 1024;
const int potentiometerRange = potentiometerMin - potentiometerMax;
const int totalValues = 9;
int code[4];

const int pinMotor = 2;
Servo servomotor;

const int pinResetButton = 3;

boolean isCodeFound;
boolean isOver;

void setup() {
  // put your setup code here, to run once:
  pinMode(pinLocks[1], INPUT);
  pinMode(pinLocks[2], INPUT);
  pinMode(pinLocks[3], INPUT);
  pinMode(pinLocks[4], INPUT);
  
  pinMode(pinMotor, OUTPUT);
  servomotor.attach(pinMotor);

  pinMode(pinResetButton, INPUT_PULLUP);

  isCodeFound = false;
  isOver = false;

  code[0] = 1;
  code[1] = 2;
  code[2] = 3;
  code[3] = 4;
  
  // TO DO : Use resetGame() instead
  //resetGame();

  randomSeed(millis());

  Serial.begin(9600);
}

void loop()
{
  testServo();
}

void loop2() {
  // put your main code here, to run repeatedly:
  isCodeFound = true;
  for(int i = 0; i < 4; i++)
  {
    if(getCurrentNumberOnLock(i) != code[i])
    {
      isCodeFound = false;
      break;
    }
  }
  
  delay(1000); // check every 1 second
  
  if(isCodeFound)
  {
    for (int angle = 0; angle <= 180; angle++)
    {
      servomotor.write(angle);
      delay(10);
    }
    isOver = true;
  }

  // button is inside the box, so physically inaccessible, doesn't need if statement
  if(digitalRead(pinResetButton))
  {
    resetGame();
  }
}

int getCurrentNumberOnLock(int index)
{
  int x = analogRead(pinLocks[index]);
  
  for(int i = 0; i < totalValues; i++)
  {
    if(x < potentiometerMin + potentiometerRange * (i + 1) / totalValues)
      return i;
  }
  Serial.println("Error : couldn't read the number on the lock");
  exit;
}

void resetGame()
{
  openSafe(); // in case the user missed the opportunity to close the door
  
  closeSafe();
  isCodeFound = false;
  isOver = false;
  
  for(int i = 0; i < 4; i++)
  {
    code[i] = random(0,10);
  }

  // TO DO : Use Bluetooth to broadcast reset across all the games with the new values
  // ...
}

void closeSafe()
{
  for (int angle = 0; angle <= 180; angle++)
  {
    servomotor.write(angle);
    delay(10);
  }
}

void openSafe()
{
  for (int angle = 180; angle >= 0; angle--)
  {
    servomotor.write(angle);
    delay(10);
  }
}

void testServo()
{
  for (int position = 0; position <= 180; position++) {
    servomotor.write(position);
    delay(15);
  }
  
  for (int position = 180; position >= 0; position--) {
    servomotor.write(position);
    delay(15);
  }
}
