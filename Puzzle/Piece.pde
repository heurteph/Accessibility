enum CHOICE { DEFAULT, LEFT, INVERSE, RIGHT };
int[] stableAngles = {0, 90, 180, 270};

class Piece
{
  private PImage img;
  private CHOICE choice;
  private int angle;
  private float scale;
  
  Piece(String path)
  {
    this.img = loadImage(path);
    if (this.img == null)
      println("image at " + path + " could not be loaded"); 
    
    int rand    = int(random(0,4));
    this.choice = CHOICE.values()[rand];
    this.angle  = stableAngles[rand];
    this.scale = 1;
  }
  
  public void rotate()
  {
    int next    = (this.choice.ordinal() + 1) % CHOICE.values().length;
    this.choice = CHOICE.values()[next];
    this.angle  = stableAngles[next];
  }
  
  public void rotateAnimation()
  {
    this.angle += animationSpeed;
    animationSpeed = constrain(animationSpeed + animationAcceleration, 1, 10);
    
    int targetAngle = stableAngles[(this.choice.ordinal() + 1) % CHOICE.values().length];
    if(targetAngle == 0) targetAngle = 360;
    
    if(this.angle >= targetAngle)
    {
      println("angle : " + angle);
      int next    = (this.choice.ordinal() + 1) % CHOICE.values().length;
      this.choice = CHOICE.values()[next];
      this.angle  = stableAngles[next];
      isAnimating = false;
    }
  }
  
  public PImage getImage()
  {
    return img; 
  }
  
  public int getAngle()
  {
    return angle; 
  }
  
  public float getScale()
  {
    return scale; 
  }
  
  public void setScale(float s)
  {
    this.scale = s; 
  }
  
  public boolean isCorrect()
  {
    // Use angle over choice for continuous rotation transition
    // Might be useless because of interruption of game logic when animating a rotation
    // return choice == CHOICE.DEFAULT;
    return angle == 0; 
  }
  
  public void command()
  {
    //if button pressed
    if(button == 1)
    {
      // rotate();
      
      // TO DO : Debug it with the controller
      isAnimating = true;
      button = 0;
    }
  }
}
