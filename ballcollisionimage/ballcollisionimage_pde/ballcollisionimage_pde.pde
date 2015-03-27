//library imports
import java.awt.Color;
import java.net.*;
import java.io.*;
import processing.video.*;
import processing.sound.*;
//create capture object
Capture video;
AudioIn audio;
Amplitude amp;
//make new balls
Ball[] balls = { 
  new Ball(200, 400, 1, int(random(0, 255)), int(random(0, 255)), int(random(0, 255)), 255, true), 
  new Ball(100, 400, 1, int(random(0, 255)), int(random(0, 255)), int(random(0, 255)), 255, true), 
  new Ball(700, 400, 8, int(random(0, 255)), int(random(0, 255)), int(random(0, 255)), 255, true)
  };

//Add more text (displayed when only the original 3 balls are on screen
promptText addmore = new promptText("Click to add more balls!");
//clear screen every frame?
boolean clear = false;
//size of frame
int[] size = {640,400};
color back = 0;
int numofballs = 900;
float audioVol;
void setup() {
  size(size[0],size[1]);
  video = new Capture(this, size[0], size[1]);
  video.start();
  audio = new AudioIn(this, 0);
  audio.start();
  amp = new Amplitude(this);
  amp.input(audio);
  //set the 
  frame.setResizable(true);
  if (!clear) {
    background(back);
  }
  for(int i=0;i<numofballs;++i){
   addBalls(); 
  }
}

void draw() {
  //if frameclear is set to true, draw the background
  if (clear) {
    background(back);
  }
  audioVol = amp.analyze();
  //if there is a new frame from the camera, read it.
  if (video.available() == true) {
    video.read();
  }
  
  //run through all of the balls and update their position, display them, and check to see if they are colliding with something
  for (Ball b : balls) {
    b.update();
    b.display();
    //check to see if the balls collide with the edge of the screen
    b.checkBoundaryCollision();
  }
  //if there are only 3 balls on screen, show the prompt saying to click and add more
  if (balls.length == 3) {
    addmore.update();
  }
  //check to see if the balls are colliding with eachother
  CheckCollision(balls);
}

//add new balls
void mousePressed() {
  addBalls();
  size(size[0],size[1]);
}
void addBalls(){
  balls=(Ball[])expand(balls, balls.length+1);
  balls[balls.length-1] = new Ball(200, random(100, width-100), random(1, 10), int(random(0, 200)), int(random(0, 200)), int(random(0, 200)), int(random(45, 255)), false); 
}
//check if balls have collided with eachother
void CheckCollision(Ball[] passed) {
  for (int x=0; x<passed.length; x++) {
    int counter = 0;
    for (Ball b : passed) {
      if (x != counter) {
        passed[x].checkCollision(b);
      }
      counter++;
    }
  }
}





String[]  convertcolour(Ball myball) {
  int _red =  myball.red ;        
  int _green =  myball.green;       
  int _blue =  myball.blue; 
  //println(String.valueOf( _red) + " " + String.valueOf(_green) + " " + String.valueOf(_blue));
  float[] hsb = Color.RGBtoHSB(_red, _green, _blue, null);
  ////println(hsb);
  String[] _HSB = new String[3];  
  _HSB[0]=String.valueOf(Math.round(hsb[0]*65535));
  _HSB[1]=String.valueOf(Math.round(hsb[1]*255));
  _HSB[2]=String.valueOf(Math.round(hsb[2]*255));
  return _HSB;
}


class promptText {
  String tekst;
  int opa, opaadd = 1;
  promptText(String tekst_) {
    tekst = tekst_;
  }
  void update() {
    if (opa<0 || opa>255) {
      opaadd*=(-1);
    }
    opa+=opaadd;
    fill(255, 255, 255, opa);
    smooth();
    text(tekst, 25, 50);
    //println(opa);
  }
}//}

class Ball {
  PVector position;
  PVector velocity;
  int red, green, blue, alpha;
  float r, m;
  boolean ameobaCheck, lit = false;

  Ball(float x, float y, float r_, int _red, int _green, int _blue, int _alpha, boolean _lit) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    velocity.mult(3);
    r = r_;
    m = r*.1;
    red=_red;
    green=_green;
    blue=_blue;
    alpha=_alpha;
    lit=_lit;
  }

  void update() {
    position.add(velocity);
  }

  void checkBoundaryCollision() {
    if (position.x > width-r) {
      position.x = width-r;
      velocity.x *= -1;
    } else if (position.x < r) {
      position.x = r;
      velocity.x *= -1;
    } else if (position.y > height-r) {
      position.y = height-r;
      velocity.y *= -1;
    } else if (position.y < r) {
      position.y = r;
      velocity.y *= -1;
    }
  }

  void checkCollision(Ball other) {



    // get distances between the balls components
    PVector bVect = PVector.sub(other.position, position);

    // calculate magnitude of the vector separating the balls
    float bVectMag = bVect.mag();

    if (bVectMag < r + other.r) {
      // get angle of bVect
      float theta  = bVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
        };

        /* this ball's position is relative to the other
         so you can use the vector between them (bVect) as the 
         reference point in the rotation expressions.
         bTemp[0].position.x and bTemp[0].position.y will initialize
         automatically to 0.0, which is what you want
         since b[1] will rotate around b[0] */
        bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
      bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
        };

        vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momenotum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
        };

        // final rotated velocity for b[0]
        vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
        };

        bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);
      if (int(random(0, 1)) == 1) {
        other.red = int(map(other.red, 0, 255, 0, 128)) + int(random(0, 128));
        other.green = int(map(other.green, 0, 255, 0, 128)) + int(random(0, 128));
        other.blue = int(map(other.blue, 0, 255, 0, 128)) + int(random(0, 128));
      }
      if (int(random(0, 3)) == 1) {
        other.red = int(random(255));
        other.blue = int(random(255));
        other.green = int(random(255));
      }

      //update colours
      red=constrain((red+other.red)/2, 0, 255);
      // other.red=abs(other.red-(int(random(-255,255))));
      green=constrain((green+other.green)/2, 0, 255);
      // other.green=abs(other.green-(int(random(-255,255))));
      blue=constrain((blue+other.blue)/2, 0, 255);
      // other.blue=abs(other.blue-(int(random(-255,255))));
      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;

      if (dist(position.x, position.y, other.position.x, other.position.y) < (r+other.r)) {
        ameobaCheck = true;
        r=constrain(r-1, 1, r);
      } else {
        ameobaCheck = false;
      }
    }
  }


  void display() {
    noStroke();
    fill(video.get((int)position.x, (int)position.y));
    float brisize = map(brightness(video.get((int)position.x, (int)position.y)),0,255,0,10) + map(audioVol, 0,1,0,10);
    
    ellipse(position.x, position.y, (r*2)+brisize, (r*2)+brisize);
  }
}
