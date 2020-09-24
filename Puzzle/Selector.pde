class Selector
{
  private int currentPos;
  private int nextPos;
  
  private int divHorizontal, divVertical;
  private PImage texture;
  
  public Selector(String filename, int divHorizontal, int divVertical)
  {
    this.divHorizontal = divHorizontal;
    this.divVertical   = divVertical;
    this.texture = loadImage(filename);
    this.currentPos    = int(random(0, divHorizontal * divVertical));
    this.nextPos       = 0;
    
    pieces[currentPos].setScale(selectionScale);
  }
  
  public void transition()
  {
     pieces[currentPos].setScale(pieces[currentPos].getScale() - transitionSpeed);
     pieces[nextPos].setScale(pieces[nextPos].getScale() + transitionSpeed);
    
    if(pieces[currentPos].getScale() <= 1 && pieces[nextPos].getScale() >= selectionScale)
    {
      this.currentPos = this.nextPos;
      isTransitioning = false;
      
      giveShortVibration();
    }
  }
  
  public void moveUp()
  {
    //nextPos = (currentPos - divHorizontal >= 0) ? currentPos - divHorizontal : currentPos;
    //isTransitioning = true;
    
    if(currentPos - divHorizontal >= 0)
    {
      nextPos = currentPos - divHorizontal;
      isTransitioning = true;
      
    }
  }
  
  public void moveDown()
  {
    //nextPos = (currentPos + divHorizontal < divHorizontal * divVertical) ? currentPos + divHorizontal : currentPos;
    //isTransitioning = true;
    
    if(currentPos + divHorizontal < divHorizontal * divVertical)
    {
      nextPos = currentPos + divHorizontal;
      isTransitioning = true;
    }
  }
  
  public void moveLeft()
  {
    //nextPos = (currentPos % divHorizontal > 0) ? currentPos - 1 : currentPos;
    //isTransitioning = true;
    
    if(currentPos % divHorizontal > 0)
    {
      nextPos = currentPos - 1;
      isTransitioning = true;
    }
  }
  
  public void moveRight()
  {
    //nextPos = (currentPos % divHorizontal < divHorizontal - 1) ? currentPos + 1 : currentPos;
    //isTransitioning = true;
    
    if(currentPos % divHorizontal < divHorizontal - 1)
    {
      nextPos = currentPos + 1;
      isTransitioning = true;
    }
  }
  
  public void command()
  {
    switch(joystickX)
    {
      case 0: //nothing
        break;
      case 1:
        moveRight();
        break;
      case -1:
        moveLeft();
        break;
    }
    joystickX = 0;
    
    switch(joystickY)
    {
      case 0: //nothing
        break;
      case 1:
        moveUp();
        break;
      case -1:
        moveDown();
        break;
    }
    joystickY = 0;
  }
  
  public int getCurrentPos()
  {
    return currentPos; 
  }
  
  public PImage getTexture()
  {
    return texture;
  }
  
  /* DEBUG ONLY */
  
  public boolean randomMove()
  {
    int rand = int(random(0, 5));
    switch(rand)
    {
      case 0 : moveUp();
      break;
      case 1 : moveDown();
      break;
      case 2 : moveLeft();
      break;
      case 3 : moveRight();
      break;
      case 4 : // stay in place
      return false;
    }
    return true;
  }
}
