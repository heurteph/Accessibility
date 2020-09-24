int puzzleWidth, puzzleHeight;
int divHorizontal, divVertical, divTotal;
int wPiece, hPiece;
int backgroundWidth, backgroundHeight;
int marginWidth, marginHeight;

String path, extension;
String inputs;

PFont font;

String[] puzzles;
Piece[] pieces;
Selector selector;
PImage[] fullPictures;
PImage background;

boolean isAnimating;
float animationSpeed;
float animationAcceleration;
float baseAnimationSpeed;

boolean isTransitioning;
float transitionSpeed;
float selectionScale;

int glow;
int glowDir;
int glowMin;
int glowMax;
float glowSpeed;

boolean victory;
float fullPictureSpeed;
float fullPictureMaxScale;
float fullPictureScale;

boolean isFading;
float fadingSpeed;
float fade;

/* Set the screen dimensions */
void settings()
{
  // background = loadImage("images\\background.png");
  // backgroundWidth = background.width;
  // backgroundHeight = background.height;
  // make sure the background is wider and higher than the puzzle
  backgroundWidth = 1200;
  backgroundHeight = 1000;
  
  size(backgroundWidth, backgroundHeight, P3D);
}

void setup()
{
  surface.setTitle("Puzzle");
  //frameRate(10);
    
  randomSeed(millis());
  
  setupSerial();
  
  divHorizontal = 4;
  divVertical = 3;
  divTotal = divHorizontal * divVertical;
  
  baseAnimationSpeed = 4;
  animationSpeed = baseAnimationSpeed;
  animationAcceleration = 0;
  transitionSpeed = 0.05;
  selectionScale = 1.15;
  
  glowMin = 64;
  glowMax = 100;
  glowSpeed = 0.5;
  
  font = createFont("soria-font.ttf", 100);
  textFont(font);
  
  puzzles = new String[1];
  puzzles[0] = "inprogress_";
  
  fullPictures = new PImage[1];
  fullPictures[0] = loadImage("images\\inprogress.png");
  fullPictureMaxScale = 1.2;
  fullPictureSpeed = 0.01;
  
  fadingSpeed = 1;
  
  restartGame(0);
}

void draw()
{
    
  /* Inputs */
  
  getInputs();
  
  /* Game Logic */
  
  if(!hasWon())
  {
    if(isAnimating)
    {
      pieces[selector.getCurrentPos()].rotateAnimation();
    }
    else if(isTransitioning)
    {
      selector.transition();
    }
    else
    {  
      selector.command();
      
      pieces[selector.getCurrentPos()].command();
      
      CheckForVictory();
    }
  }
  else
  {
    /* DEBUG ONLY */
    if(button == 1)
    {
      button = 0;
      restartGame(0);
    }
  }
  
  /* Display */
  
  clear();
  
  for(int i = 0; i < divHorizontal; i++)
  {
    for(int j = 0; j < divVertical; j++)
    {
      int x = i * wPiece;
      int y = j * hPiece;
      
      int index = j * divHorizontal + i;
      
      imageMode(CENTER);
      
      pushMatrix();
        translate(marginWidth + x + wPiece * 0.5, marginHeight + y + hPiece * 0.5);
        
        //noStroke();
        fill(0,0,0);
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // black background seen when rotating
        
        rotate(radians(pieces[index].getAngle()));
        image(pieces[index].getImage(), 0, 0, wPiece, hPiece);
        strokeWeight(10);
        noFill();
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // outline piece
      popMatrix();
    }
  }
  
  /* Game Feel and UI */
  
  if(hasWon())
  {
    displayVictory();
  }
  else
  {
    // Brightness for selection
    glow += glowDir * glowSpeed;
    if(glow < glowMin){ glow = glowMin; glowDir = -glowDir; }
    else
    if(glow > glowMax){ glow = glowMax; glowDir = -glowDir; }
    
    imageMode(CENTER);
      
    pushMatrix();
        translate(marginWidth + (selector.getCurrentPos() % divHorizontal) * wPiece + wPiece * 0.5, marginHeight + (selector.getCurrentPos() / divHorizontal) * hPiece  + hPiece * 0.5, 1);
        scale(pieces[selector.getCurrentPos()].getScale());
        rotate(radians(pieces[selector.getCurrentPos()].getAngle()));
        //noStroke();
        //fill(0,0,0,64);
        //rect(-wPiece * 0.5, -hPiece * 0.5, wPiece * pow(pieces[selector.getCurrentPos()].getScale(), 2), hPiece * pow(pieces[selector.getCurrentPos()].getScale(), 2)); // shadow cast all around the piece
        //rect(-wPiece * 0.5, -hPiece * 0.5, wPiece * 1.2, hPiece * 1.2); // shadow cast all around the piece
        image(pieces[selector.getCurrentPos()].getImage(), 0, 0, wPiece, hPiece);
        
        fill(255,255,255,glow);
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // glowing
        
        strokeWeight(10);
        noFill();
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // outline piece
    popMatrix();
  }
}

boolean hasWon()
{
  return victory;
}

void CheckForVictory()
{
  for(int i = 0; i < divTotal; i++)
  {
    if(!pieces[i].isCorrect())
       return;
  }
  victory = true;
  isFading = true;
}

void displayEndMessage()
{ 
  fill(255,255,255,128);
  noStroke();
  rect(0, 0, width, height);
  fill(255,255,255);
  rect(0, hPiece, width, hPiece);
  fill(0,0,0);
  textAlign(CENTER, CENTER); // centre le texte horizontalement et verticalement
  text("Puzzle completed", 0, 0, width, height);  // fonction text avec le texte et 4 coordonnées met le texte dans un rectangle (suis le rectMode)
}

void displayVictory()
{
  if(isFading)
  {
    fade = min(fade + fadingSpeed, 255);
    if (fade >= 255)
    {
      fade = 255;
      isFading = false;
    }
  }
  
  fullPictureScale = min(fullPictureScale + fullPictureSpeed, fullPictureMaxScale);
  
  pushMatrix();
          translate(width / 2.0, height / 2.0, 2);
          scale(fullPictureScale);
          image(fullPictures[0], 0, 0, puzzleWidth, puzzleHeight);
          tint(255, fade);
  popMatrix();
}

void selectPuzzleRandom()
{
  String randPuzzle = puzzles[int(random(0, puzzles.length))];
  path = "images\\" + randPuzzle;
  extension = ".png";
  
  pieces = new Piece[divTotal];
  for(int i = 0; i < divTotal; i++)
  {
      String filename = path + nf(i+1, 2) + extension;
      pieces[i] = new Piece(filename);
  }
}

void selectPuzzle(int number)
{
  path = "images\\" + puzzles[number];
  extension = ".png";
  
  pieces = new Piece[divTotal];
  for(int i = 0; i < divTotal; i++)
  {
      String filename = path + nf(i+1, 2) + extension;
      pieces[i] = new Piece(filename);
  }
}

void restartGame(int number)
{
  // TO DO : Add visual transition
  
  victory = false;
  isAnimating = false;
  isTransitioning = false;
  animationSpeed = baseAnimationSpeed;
  selectPuzzle(number);
  puzzleWidth = fullPictures[number].width;
  puzzleHeight = fullPictures[number].height;
  wPiece = puzzleWidth / divHorizontal;
  hPiece = puzzleHeight / divVertical;
  marginWidth = (backgroundWidth - puzzleWidth) / 2;
  marginHeight = (backgroundHeight - puzzleHeight) / 2;
  
  selector = new Selector("images\\selection.png", divHorizontal, divVertical);
  glow = glowMax;
  glowDir = -1;
  fullPictureScale = 1;
  isFading = false;
  fade = 0;
}
