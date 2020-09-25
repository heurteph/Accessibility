const int buttonPin        = 8;
const int joystickRightPin = 2;
const int joystickLeftPin  = 3;
const int joystickDownPin  = 4;
const int joystickUpPin    = 5;

const int vibrationPin     = A0;
int vibrationTimer = 0;
boolean useVibration = true;

/* button vars */

enum BUTTON_STATE { PRESSED, RELEASED };
BUTTON_STATE lastButtonState = RELEASED;

/* joystick vars */

int xJoystickTrigger = 0;
int yJoystickTrigger = 0;
int joystickTimer = millis();
unsigned long joystickDelay = 500; // milliseconds

/* vibration vars */
int lastMillis;

void setup() {

  pinMode(buttonPin, INPUT_PULLUP);
  pinMode(joystickUpPin, INPUT);
  pinMode(joystickDownPin, INPUT);
  pinMode(joystickLeftPin, INPUT);
  pinMode(joystickRightPin, INPUT);
  
  pinMode(vibrationPin, OUTPUT);

  lastMillis = millis();

  Serial.begin(9600);
}

void loop() {

  /* Button */

  int buttonState = digitalRead(buttonPin); // MEMO : 1 is released, 0 is pressed

  int buttonTrigger = 0;
  if (buttonState == LOW)
  {
    if (lastButtonState == RELEASED)
    {
      buttonTrigger = 1;
    }
    lastButtonState = PRESSED;
  }
  else
  {
    lastButtonState = RELEASED;
  }

  /* New Joystick */

  xJoystickTrigger = 0;
  yJoystickTrigger = 0;
  if (millis() - joystickTimer > joystickDelay)
  {
    if (digitalRead(joystickUpPin) == LOW)
    {
      yJoystickTrigger = 1;
      joystickTimer = millis();
    }
    if (digitalRead(joystickDownPin) == LOW)
    {
      yJoystickTrigger = -1;
      joystickTimer = millis();
    }
    if (digitalRead(joystickLeftPin) == LOW)
    {
      xJoystickTrigger = -1;
      joystickTimer = millis();
    }
    if (digitalRead(joystickRightPin) == LOW)
    {
      xJoystickTrigger = 1;
      joystickTimer = millis();
    }
  }

  /* vibrations */

  if(useVibration)
  {
    if(xJoystickTrigger != 0 || yJoystickTrigger != 0)
      vibrationTimer = 100;
    
    if (vibrationTimer > 0)
    {
      //Serial.println(millis() - lastMillis);
      vibrationTimer = max(vibrationTimer - (millis() - lastMillis), 0);
      if (vibrationTimer <= 0)
        motorWrite(0);
      else
        motorWrite(128);
    }
    /*
    else
    {
      int t = Serial.parseInt(); // receive duration from Processing, do not load them during occuring vibration
      if (t != 0)
      {
        vibrationTimer = t;
      }
    }
    */
    lastMillis = millis();
  }

  String s1 = "{\"joystickX\": ";
  String s2 = (String)xJoystickTrigger;
  String s3 = ",\"joystickY\": ";
  String s4 = (String)yJoystickTrigger;
  String s5 = ",\"button\": ";
  String s6 = (String)buttonTrigger;
  String s7 = "}\n";
  String msg = s1 + s2 + s3 + s4 + s5 + s6 + s7;

  Serial.println(msg);
}

void motorWrite(int value)
{
  analogWrite(vibrationPin, value);
}
