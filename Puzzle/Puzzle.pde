import java.util.*;

int puzzleWidth, puzzleHeight;
int divHorizontal, divVertical, divTotal;
int wPiece, hPiece;
int backgroundWidth, backgroundHeight;
int marginWidth, marginHeight;
int offsetWidth, offsetHeight;

String path, extension;
String inputs;

PFont font;

String[] puzzles;
Piece[] pieces;
Selector selector;
PImage[] fullPictures;

PImage background_img;
PImage background_top;
PImage background_left;
PImage background_bottom;
PImage background_right;

PImage foreground;

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

int shortVibrationDuration;
int mediumVibrationDuration;
int longVibrationDuration;
int extraVibrationDuration;

float downscaleFactors[] = {0.6, 0.8};
String winningNumber[] = {"2", "4"};

int puzzleNumber;

/* Set the screen dimensions */
void settings()
{
  //fullScreen();
  // backgroundWidth = background.width;
  // backgroundHeight = background.height;
  // make sure the background is wider and higher than the puzzle
  //backgroundWidth  = 1250;
  //backgroundHeight = 1000;
  backgroundWidth  = 1920;
  backgroundHeight = 1200;
  
  size(backgroundWidth, backgroundHeight, P3D);
}

void setup()
{
  surface.setTitle("Puzzle");
  //frameRate(10);
  
  Date d = new Date();
  randomSeed(d.getTime());
  
  setupSerial();
  
  divHorizontal = 4;
  divVertical = 3;
  divTotal = divHorizontal * divVertical;
  
  baseAnimationSpeed = 4;
  animationSpeed = baseAnimationSpeed;
  animationAcceleration = 0;
  transitionSpeed = 0.05;
  selectionScale = 1.1;
  
  glowMin = 64;
  glowMax = 100;
  glowSpeed = 0.5;
  
  shortVibrationDuration  = 100;  // ms
  mediumVibrationDuration = 250;  // ms
  longVibrationDuration   = 500; // ms
  extraVibrationDuration  = 4000; // ms
  
  font = createFont("soria-font.ttf", 800);
  textFont(font);
  
  puzzles = new String[2];
  puzzles[0] = "vitrail_";
  puzzles[1] = "mucha_";
  
  fullPictures = new PImage[2];
  fullPictures[0] = loadImage("images\\vitrail.png");
  fullPictures[1] = loadImage("images\\mucha.png");
  fullPictureMaxScale = 1.2;
  fullPictureSpeed = 0.01;
  
  background_img = loadImage("images\\background2.jpg");
  background_top = loadImage("images\\background2_top.jpg");
  background_left = loadImage("images\\background2_left.jpg");
  background_bottom = loadImage("images\\background2_bottom.jpg");
  background_right = loadImage("images\\background2_right.jpg");
  //foreground = loadImage("images\\foreground.png");
  
  fadingSpeed = 15;
  
  // puzzleNumber = 1;
  puzzleNumber = int(random(0,2));
  restartGame(puzzleNumber);
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
      puzzleNumber = (puzzleNumber + 1) % 2;
      restartGame(puzzleNumber);
    }
  }
  
  /* Display */
  
  clear();
  
  //background(background_img);
  
  for(int i = 0; i < divHorizontal; i++)
  {
    for(int j = 0; j < divVertical; j++)
    {
      int x = i * wPiece;
      int y = j * hPiece;
      
      int index = j * divHorizontal + i;

     imageMode(CORNER);
      
     pushMatrix();
        translate(0, 0, -5); // behind the puzzle
        fill(238,207,160);
        rect(0,0,width,height);
        image(background_top, 0, 0);
        image(background_left, 0, 0);
        image(background_right, backgroundWidth - marginWidth, 0);
        image(background_bottom, 0, backgroundHeight - marginHeight);
      popMatrix();

      imageMode(CENTER);
      
      // image(background_top,    width / 2, marginHeight / 2, width, marginHeight);
      // image(background_bottom, width / 2, height - marginHeight / 2, width, marginHeight);
      // image(background_left, marginWidth / 2, height / 2, marginWidth, height);
      // image(background_right, width - marginWidth / 2, height / 2, marginWidth, height);
      
      pushMatrix();
        strokeWeight(3);
        translate(offsetWidth + x + wPiece * 0.5, offsetHeight + y + hPiece * 0.5);
        
        //noStroke();
        fill(0,0,0);
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // black background seen when rotating
        
        rotate(radians(pieces[index].getAngle()));
        image(pieces[index].getImage(), 0, 0, wPiece, hPiece);
        //noStroke();
        noFill();
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // outline piece
        
        //tint(255, 255 - fade);
      popMatrix();
      
      //image(foreground, width/2, height/2, width, height);
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
        //noStroke();
        translate(offsetWidth + (selector.getCurrentPos() % divHorizontal) * wPiece + wPiece * 0.5, offsetHeight + (selector.getCurrentPos() / divHorizontal) * hPiece + hPiece * 0.5, 1);
        scale(pieces[selector.getCurrentPos()].getScale());
        rotate(radians(pieces[selector.getCurrentPos()].getAngle()));
        //noStroke();
        //fill(0,0,0,64);
        //rect(-wPiece * 0.5, -hPiece * 0.5, wPiece * pow(pieces[selector.getCurrentPos()].getScale(), 2), hPiece * pow(pieces[selector.getCurrentPos()].getScale(), 2)); // shadow cast all around the piece
        //rect(-wPiece * 0.5, -hPiece * 0.5, wPiece * 1.2, hPiece * 1.2); // shadow cast all around the piece
        image(pieces[selector.getCurrentPos()].getImage(), 0, 0, wPiece, hPiece);
        
        fill(255,255,255,glow);
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // glowing
        
        strokeWeight(6);
        stroke(0, 255 - fade);
        noFill();
        rect(-wPiece * 0.5, -hPiece * 0.5, wPiece, hPiece); // outline piece
        //tint(255, 255 - fade);
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
  
  giveExtraVibration();
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
    noStroke();
    fill(255, fade);
    rect(0,0,width,height);
    fade = min(fade + fadingSpeed, 255);
    if (fade >= 255)
    {
      fade = 255;
      isFading = false;
    }
  }
  else
  {
    //fullPictureScale = min(fullPictureScale + fullPictureSpeed, fullPictureMaxScale);
    fill(255, fade);
    fade = max(fade - fadingSpeed, 0);
    rect(0,0,width,height);
    
    pushMatrix();
            translate(width / 2.0, height / 2.0, 2);
            //scale(fullPictureScale);
            image(fullPictures[puzzleNumber], 0, 0, puzzleWidth, puzzleHeight);
            tint(255, 255 - fade);
    popMatrix();
    
    // Display winning number
    textAlign(CENTER, CENTER);
    fill(255,0,0);
    text(winningNumber[puzzleNumber], backgroundWidth / 2, backgroundHeight / 2, 10);
  }
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
  puzzleWidth  = int(fullPictures[number].width  * downscaleFactors[number]);
  puzzleHeight = int(fullPictures[number].height * downscaleFactors[number]);
  wPiece = puzzleWidth / divHorizontal;
  hPiece = puzzleHeight / divVertical;
  offsetWidth = (backgroundWidth - puzzleWidth) / 2;
  offsetHeight = (backgroundHeight - puzzleHeight) / 2;
  marginWidth = 210;
  marginHeight = 197;
  
  selector = new Selector("images\\selection.png", divHorizontal, divVertical);
  glow = glowMax;
  glowDir = -1;
  fullPictureScale = 1;
  isFading = false;
  fade = 0;
}

/* Vibration functions */

void giveShortVibration()
{
  outputVibration(shortVibrationDuration);
}

void giveMediumVibration()
{
  outputVibration(mediumVibrationDuration);
}

void giveLongVibration()
{
  outputVibration(longVibrationDuration);
}

void giveExtraVibration()
{
  outputVibration(extraVibrationDuration);
}

void outputVibration(int duration)
{
  writeSerial(duration); 
}
