class Food {
  float x, y;
  Food() {
    reset();
  }

  void reset() {//reset the apple
    x = (int)random(0, (trueWidth/20)-1)*20+10;
    y = (int)random(0, (trueHeight/20)-1)*20+10;
    try {
      for (Segment s : snake) {
        if (s.x == x && s.y == y) {
          reset();
        }
      }
    } 
    catch (Exception e) {
      // when this method is called in the constructor of the apple object, the snake array objects don't exist yet so it throws a NullPointerException. For this case we just need to make sure the apple isn't in the places where the snake starts out. 
      if (x == trueWidth/2) {
        reset();
      }
    }
  }

  void renderFood() {//draw the apple
    fill(255);
    imageMode(CENTER);
    image(apl, x, y);
  }
}
