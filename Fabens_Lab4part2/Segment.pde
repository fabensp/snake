class Segment {
  float x, y;
  int id;
  Segment(float x, float y, int id) {
    this.id = id; // each segment has an id, the head is 0
    SEGMENTS++; //each segment iterates the segment counter
    this.x = x;
    this.y = y;
  }

  void updateSegment() {
    if ((id > 2 && snake[0].x == x && snake[0].y == y)||(x > trueWidth-10 || x < 10 || y > trueHeight-10 || y < 10)) {
      /*
      if a segment besides the first two is in the same place as the head, you've crashed
       you can't actually collide with the first two segments because it's impossible but 
       if you don't give them an exception from crashing, during the shifting process snake kills itself
       
       also dont let the head past the borders
       */
      gameover = true; 
      dir.set(0, 0);//make snake stop if you die
    }
    if (x == apple.x && y == apple.y && id != 0) {
      apple.reset();//if apple spawns inside snake body, make it reset but don't add a segment
    }
  }

  void shiftSegment() {
    if (dir.mag() != 0) {//don't try to move if dir is 0,0
      if (id != 0) {
        x = snake[id-1].x;//if you aren't the head, move to the segment ahead of you
        y = snake[id-1].y;
      } else {
        x += dir.x * 20;// if you are the head, move according to the direction vector
        y += dir.y * 20;
      }
    }
    if (id == 0) {
      if (x == apple.x && y == apple.y) {// if head hits an apple, add a segment
        for (int j = 0; j<difficulty; j++) {
          snake = (Segment[])append(snake, new Segment(snake[SEGMENTS-1].x, snake[SEGMENTS-1].y, SEGMENTS));
        }
        apple.reset();
        eat.jump(0);//using jump in case the sounds were to somehow overlap
      }
    }
  }

  void renderSegment() {// draw segments with colors dependent on id
    fill(255*id/SEGMENTS, 255, 255 - 255*id/SEGMENTS);
    rect(x, y, 20, 20);
    if (id == 0) {
      fill(255, 0, 0, 255*dir.mag());
      rect(x + dir.y*5, y + dir.x*5, 3, 3);
      rect(x - dir.y*5, y - dir.x*5, 3, 3);
      if (dist(apple.x, apple.y, x, y) < 100) {
        rect(x + dir.x*15, y + dir.y*15, dir.y*3 + dir.x*10, dir.x*3 + dir.y*10);
      }
      fill(0);
    }
  }
}
