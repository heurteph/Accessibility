int divHorizontal, divVertical, divTotal;
int wPiece, hPiece;
String path, extension;
String inputs;

PFont font;

String[] puzzles;
Piece[] pieces;
Selector selector;

boolean isAnimating;
int animationSpeed;

boolean isTransitioning;
int transitionSpeed;
float selectionScale;

int glow;
int glowDir;
int glowMin;
int glowMax;
int glowSpeed;

boolean victory;

/* Set the screen dimensions */
void settings()
{
  size(640, 480);
}

void setup()
{
  surface.setTitle("Puzzle");
  //frameRate(1);
    
  randomSeed(millis());
  
  setupSerial();
  
  divHorizontal = 4;
  divVertical = 3;
  divTotal = divHorizontal * divVertical;
  wPiece = width / divHorizontal;
  hPiece = height / divVertical;
  
  selector = new Selector("images\\selection.png", divHorizontal, divVertical);
  
  animationSpeed = 1;
  transitionSpeed = 1;
  selectionScale = 1.2;
  
  glowMin = 128;
  glowMax = 156;
  glowSpeed = 1;
  
  font = createFont("soria-font.ttf", 100);
  textFont(font);
  
  puzzles = new String[1];
  puzzles[0] = "bob_";
  
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
  
  for(int i = 0; i < divHorizontal; i++)
  {
    for(int j = 0; j < divVertical; j++)
    {
      int x = i * wPiece;
      int y = j * hPiece;
      
      int index = j * divHorizontal + i;
      
      imageMode(CENTER);
      
      pushMatrix();
        translate(x + wPiece * 0.5, y + hPiece * 0.5);
        rotate(radians(pieces[index].getAngle()));
        scale(pieces[index].getScale());
        image(pieces[index].getImage(), 0, 0, wPiece, hPiece);
      popMatrix();
    }
  }
  
  /* Game Feel and UI */
  
  if(hasWon())
  {
    displayEndMessage();
  }
  else
  {
    // Brightness for selection
    glow += glowDir * glowSpeed;
    if(glow < glowMin){ glow = glowMin; glowDir = -glowDir; }
    else
    if(glow > glowMax){ glow = glowMax; glowDir = -glowDir; }
    
    fill(255,255,255,glow);
    noStroke();
    rect((selector.getCurrentPos() % divHorizontal) * wPiece, (selector.getCurrentPos() / divHorizontal) * hPiece, wPiece, hPiece);
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
  victory = false;
  isAnimating = false;
  isTransitioning = false;
  selectPuzzle(number);
  glow = glowMax;
  glowDir = -1;
}
