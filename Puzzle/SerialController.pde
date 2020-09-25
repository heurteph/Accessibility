import processing.serial.*;
Serial port;  // Create object from Serial class
String data;  // Data received from the serial port
int button;
int joystickX;
int joystickY;

void setupSerial()
{
  try
  {
    String portName = Serial.list()[1];
    port = new Serial(this, portName, 9600);
    
    inputs = readSerial(); // purge data before starting
    inputs = readSerial(); // purge data before starting
    inputs = readSerial(); // purge data before starting
  }
  catch(Exception e)
  {
    
  }
}

void writeSerial(int value)
{
  port.write(value);
}

String readSerial()
{
  if(port != null && port.available() > 0) 
  {
    return trim(port.readStringUntil('\n'));
  }
  return null;
}

void parseInputs(String data)
{
  //println("data to be parsed: " + data);
  try
  {
      JSONObject json = parseJSONObject(data);
  
      if (json == null)
      {
        println("JSONObject could not be parsed");
      }
      else
      {
        if(json.hasKey("button"))
          button    = json.getInt("button");
        if(json.hasKey("joystickX"))
          joystickX = json.getInt("joystickX");
        if(json.hasKey("joystickY"));
          joystickY = json.getInt("joystickY");
      }
    }
    catch(Exception e)
    {
      // to avoid double trigger
      button    = 0;
      joystickX = 0;
      joystickY = 0;
      return;
    }
}

void getInputs()
{
  inputs = readSerial();
  
  if(inputs != null && inputs != "")
  {
    if(inputs.length() > 0 && inputs.charAt(0) == '{' && inputs.charAt(inputs.length()-1) == '}')
    {
      parseInputs(inputs);
    }
  }
}
