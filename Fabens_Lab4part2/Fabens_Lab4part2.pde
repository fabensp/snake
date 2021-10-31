import processing.sound.*;

//SIZE PARAMETERS
int X = 500;
int Y = 500;

static int SEGMENTS = 0; // counts segments of snake
PVector dir = new PVector(0, 0); //direction vector for where the snake should move, when it's 0,0 the snake doesnt move
boolean gameover, goEvent;
boolean acceptInput = true;
int hiscore, difficulty;
boolean mouse;// since the game runs at 5fps, the mousePressed variable only works if you're pressing the mouse while draw is run. by making a separate bool controlled by void mousePressed() it tracks clicks between frames
PImage apl; // apple picture
SoundFile eat;
SoundFile turn;
SoundFile lose;
int trueWidth = X - X%20;
int trueHeight = Y - Y%20;
Food apple = new Food();

Segment[] snake = { // actual snake array. all the variable manipulation is just to make sure the snake starts out aligned right with the grid
  new Segment(((trueWidth/2)-(trueWidth/2)%20)+10, ((trueHeight/2)-(trueHeight/2)%20)+10, 0), 
  new Segment(((trueWidth/2)-(trueWidth/2)%20)+10, ((trueHeight/2)-(trueHeight/2)%20)+30, 1), 
  new Segment(((trueWidth/2)-(trueWidth/2)%20)+10, ((trueHeight/2)-(trueHeight/2)%20)+50, 2)
};

void settings() {
  size(X, Y);
}

void setup() { //WINDOW SIZE CAN BE CHANGED TO ANYTHING WITHOUT BREAKING BUT WORKS BEST WITH MULTIPLES OF 20 AND UI ELEMENTS MIGHT OVERLAP BELOW 500x500
  frameRate(5);
  noStroke();
  textAlign(CENTER);
  fill(255);
  apl = loadImage("apple.png"); // load apple picture
  apl.resize(30, 0);//resize to tiny size
  eat = new SoundFile(this, "eat.wav");
  turn = new SoundFile(this, "turn.wav");
  lose = new SoundFile(this, "lose.wav");
  println(X + ", " + (X - X%20));
}

void draw() {
  background(255);
  rectMode(CORNER);
  fill(0);
  rect(0, 0, trueWidth, trueHeight);
  rectMode(CENTER);
  if (difficulty != 0) { // if difficulty or quit button has been clicked, play/quit, otherwise show rules screen
    game();
  } else {
    textAlign(CENTER);
    fill(255);
    textSize(30);
    text("SNAKE", trueWidth/2, trueHeight/5);
    textSize(20);
    text("Collect apples\n Don't run in to yourself or the wall.\nHigher difficulty makes the snake grow faster.\nSelect difficulty below to start.", trueWidth/2, trueHeight/3-30);
    if (mouse) {
      mouse = false;
      if (mouseX > trueWidth/2-40 && mouseX < trueWidth/2+40 && mouseY > trueHeight*3/5-37.5 && mouseY < trueHeight*3/5+37.5) {
        difficulty = 1;
      } else if (mouseX > trueWidth/2-130 && mouseX < trueWidth/2-50 && mouseY > trueHeight*3/5-37.5 && mouseY < trueHeight*3/5+37.5) {
        difficulty = 2;
      } else if (mouseX > trueWidth/2+50 && mouseX < trueWidth/2+130 && mouseY > trueHeight*3/5-37.5 && mouseY < trueHeight*3/5+37.5) {
        difficulty = 3;
      } else if (mouseX > trueWidth/2-40 && mouseX < trueWidth/2+40 && mouseY > trueHeight*4/5-37.5 && mouseY < trueHeight*4/5+37.5) {
        exit();
      }
    }
    rect(trueWidth/2, trueHeight*3/5, 80, 75);
    rect(trueWidth/2-90, trueHeight*3/5, 80, 75);
    rect(trueWidth/2+90, trueHeight*3/5, 80, 75);
    rect(trueWidth/2, trueHeight*4/5, 80, 75); 
    fill(0);
    text("1", trueWidth/2-90, trueHeight*3/5+5); 
    text("2", trueWidth/2, trueHeight*3/5+5); 
    text("3", trueWidth/2+90, trueHeight*3/5+5); 
    text("EXIT", trueWidth/2, trueHeight*4/5+5);
  }
}

void game() {
  textSize(20);
  fill(255);
  if (dist(90, 0, snake[0].x, snake[0].y) > 60 && dist(90, 0, apple.x, apple.y) > 60) {
    textAlign(LEFT);
    text("SCORE: " + (SEGMENTS - 3)/difficulty, 20, 30);
  } else if (dist(trueWidth - 90, 0, snake[0].x, snake[0].y) > 60 && dist(trueWidth - 90, 0, apple.x, apple.y) > 60) {
    textAlign(RIGHT);
    text("SCORE: " + (SEGMENTS - 3)/difficulty, trueWidth - 20, 30);
  } else {
    textAlign(LEFT);
    text("SCORE: " + (SEGMENTS - 3)/difficulty, 20, trueHeight - 10);
  }
  textAlign(CENTER);
  for (int i = snake.length-1; i>=0; i--) { // can't use an enhanced for loop here because it needs to iterate from the end of the array up
    snake[i].shiftSegment(); //move segments, then check if you've died or eaten an apple, then draw them
    snake[i].updateSegment();
    snake[i].renderSegment();
  }
  acceptInput = true; // acceptInput is made false at every keyboard input and reset to true after each frame so that you can't input two controls in one frame and perform illegal moves
  apple.renderFood();

  if (gameover) {
    gameover(); // if something somewhere has said you lose, start showing lose screen
  }

  mouse = false; // reset mouse bool value if it hasn't been used in the last frame so that it doesn't just sit as true
}

void keyPressed() {
  if (key == CODED && acceptInput && !gameover) { //only let the player move the snake if game is going and hasnt already done an input that frame
    acceptInput = false;//prevent further input that frame
    switch(keyCode) { // change direction vector depending on input, and don't allow turning straight backwards
    case UP: 
      if (abs(dir.y)!=1) {
        dir.set(0, -1);
        turn.jump(0); // using .jump() instead of .play() so that if the sound is playing and tries to play again itll restart
      }
      break;
    case DOWN: 
      if (abs(dir.y)!=1 && dir.mag() != 0) {//since the game starts with the worm at a standstill facing upwards, don't allow stationary snakes to go down
        dir.set(0, 1);
        turn.jump(0);
      }
      break;
    case LEFT: 
      if (abs(dir.x)!=1) {
        dir.set(-1, 0);
        turn.jump(0);
      }
      break;
    case RIGHT: 
      if (abs(dir.x)!=1) {
        dir.set(1, 0);
        turn.jump(0);
      }
      break;
    }
  }
}

void gameover() {
  if (!goEvent) {
    lose.jump(0);
  }
  goEvent = true;
  hiscore = int((SEGMENTS - 3)/difficulty) > hiscore ? int((SEGMENTS - 3)/difficulty) : hiscore;
  textSize(70);
  text("GAME OVER", 250, 200);
  textSize(50);
  text("SCORE: " + int((SEGMENTS - 3)/difficulty) + " | HI: " + hiscore, 250, 300);
  textSize(30);
  text("Click anywhere to restart", 250, 400);

  if (mouse && gameover) {
    Segment[] STARTER = { // template snake array for reseting
      new Segment(((trueWidth/2)-(trueWidth/2)%20)+10, ((trueHeight/2)-(trueHeight/2)%20)+10, 0), 
      new Segment(((trueWidth/2)-(trueWidth/2)%20)+10, ((trueHeight/2)-(trueHeight/2)%20)+30, 1), 
      new Segment(((trueWidth/2)-(trueWidth/2)%20)+10, ((trueHeight/2)-(trueHeight/2)%20)+50, 2)
    };
    SEGMENTS = 3;
    snake = STARTER;
    mouse = false;
    gameover = false;
    goEvent = false;
    difficulty = 0;
  }
}

void mousePressed() {
  mouse = true;
}
