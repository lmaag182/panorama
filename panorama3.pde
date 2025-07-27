

/**
 * TexturedCube
 * by Dave Bollinger.  
 *  
 * Drag mouse to rotate cube. Demonstrates use of u/v coords in 
 * vertex() and effect on texture(). The textures get distorted using
 * the P3D renderer as you can see, but they look great using OPENGL.
 */
import processing.opengl.*;
//import processing.serial.*;
//import processing.video.*;

import mqtt.*;

int durationLastStep;   //actual duration of the last step done
int location = 0;           //location in terms of steps done
int timeStampIn = 0;        //remembers the time when the automove part tarts
int timeStampOut = 0;       //remembers the time when the automove part stops
float msPerStep = 0;        //ms per step allowed in order to reach the target in time

int steps = 500; // estimation of the ?

//simple script, turn 180 degrees within 10 seconds
int timeTarget = 10000;   //in milliseconds
float angle = 1*PI;           //in terms of pi

boolean leftPressed = false;
boolean rightPressed = false;

boolean scriptRunning = false;
int scriptStart = 0;

String myString;
int lf = 10;   

PImage tex;

float fovDivider = 2;
float rotx = 0;
float roty = 0;
float rotz = 0;

//Serial port;  

MQTTClient client;

//Movie myMovie;

void setup(){
  //myMovie = new Movie(this, "station.mov");
  //myMovie.loop();
  size(1280, 1024, OPENGL);

  tex = loadImage("Panorama3.JPG");

  textureMode(NORMAL);
  
  smooth();

  //println(Serial.list()); // List COM-ports
  //port = new Serial(this, Serial.list()[0], 19200); 
  
  client = new MQTTClient(this);
  client.connect("tcp://192.168.50.161:1883", "processing_client");
  client.subscribe("/1/toggle1");
  client.subscribe("/1/toggle2");

  //default Framerate is 60 fps
  //frameRate(4);

  //fill(255);
  //stroke(color(44,48,32));
}

void draw(){
  background(0);
  noStroke();
  translate(width/2.0, height/2.0, 0); //Specifies an amount to displace objects within the display window. 
  scale(100);                          //Increases or decreases the size of a shape by expanding and contracting vertices

  rotateX(-rotx);
  rotateY(-roty);
  rotateZ(-rotz);

  TexturedCube(tex);
  //TexturedCube(myMovie);

  autoMove();

  float fov = PI/fovDivider;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0); //allows to change the viewing angle

  camera(width/2.0, height/2.0, 0, 0,500, 0, 0.0, 1.0, 0.0); //puts the camera in the middle of the cube
  
  /*while (port.available() > 0) {
    myString = port.readStringUntil(lf);
    if (myString != null) {
      println("arduino:"+myString);
    }
  }*/
}

//void movieEvent(Movie myMovie) {
//  myMovie.read();
//}

void autoMove() {
  if (leftPressed == true){
    if (!scriptRunning){              //first run
      println("Script starting!");
      scriptRunning = true;
      fireSignal('s');
      scriptStart = millis();
      timeStampOut = 0;
      location =0;
    }
    
    //calculate last step
    timeStampIn = scriptTime(scriptStart);
    durationLastStep = timeStampIn - timeStampOut;
    
    if (location < steps){
      
      //calculate required step time
      int stepsRemaining = steps - location;
      int timeRemaining = timeTarget - timeStampIn;
      float stepTimeRequired = ( timeRemaining / stepsRemaining); //linear motion!

      //calculate speed factor
      float accelerationFactor = durationLastStep / stepTimeRequired;
      
      if (durationLastStep < stepTimeRequired){               //too quick
        println("delay:" + round(durationLastStep));
        
        delay(round(stepTimeRequired - durationLastStep));
      }
      else{            //too slow
        println("Can't do it in time! Decrease steps!");
      }

      //println("lastStep:" + durationLastStep + " time:"+scriptTime + " fc:"+ frameCount+ " loc:"+ location+ " xrot:"+ rotx+ " remSt:"+ stepsRemaining + " remTime:"+ timeRemaining+ " stepReq:"+ stepTimeRequired+ " accFac:"+ accelerationFactor);
      
      //calculate angle for next step
      float rate = angle/steps; //angle of one step
      rotx +=  rate;
      roty +=  rate;
      location = location + 1;  
      
      //remember the timestamp for next l
      timeStampOut = scriptTime(scriptStart);
      println("lastStep:" + durationLastStep+ " stepReq:"+ stepTimeRequired + " diff:"+ round(stepTimeRequired - durationLastStep) + " time:"+ scriptTime(scriptStart) + " loc:"+ location  + " remTime:"+ timeRemaining+ " xrot:"+ rotx+ " accFac:"+ accelerationFactor);

      if (location == steps){
        //last step
        println("Script stopped!");
        //leftPressed=false;
        scriptRunning = false;
        
        fireSignal('e');
        leftPressed = false;
      }
    }
  }
}

void messageReceived(String topic, byte[] payload) {
  String value = new String(payload);
  print("mqtt in, topic: " + topic + " value: " + value + " - ");
  
  if (topic.equals("/1/toggle1")) {
    if (value.equals("1")) {
      fireSignal('s');
      println("mqtt: motor start...");
    } else {
      fireSignal('e');
      println("mqtt: motor stop...");
    }
  }
  
  if (topic.equals("/1/toggle2")) {
    if (value.equals("1")) {
      fireSignal('c');
      println("mqtt: motor start calibrating...");
    } else {
      fireSignal('a');
      println("mqtt: motor stop calibrating...");
    }
  }
}

int scriptTime(int scriptStart){
  return millis()- scriptStart;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT){ 
      if (leftPressed == false){
        leftPressed = true;
        rightPressed = false;
      } 
      else if (leftPressed == true){
        leftPressed = false;
      }
    } 
    else if (keyCode == RIGHT){
      if (rightPressed == false){
        rightPressed = true;
        leftPressed = false;
      } 
      else if (rightPressed == true){
        rightPressed = false;
      }
    }
    if (keyCode == UP){ 
      fovDivider = fovDivider + .1;
    } 
    else if (keyCode == DOWN){
      fovDivider = fovDivider - .1;
    }
  }
}



void TexturedCube(PImage tex) {
  beginShape(QUADS);
  texture(tex);
  //image(tex);
  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)

  //contructing the room
  // +Z "front" face
  vertex(-2, -1,  2, 0, 0);
  vertex( 2, -1,  2, .25, 0);
  vertex( 2,  1,  2, .25, 1);
  vertex(-2,  1,  2, 0, 1);

  // -Z "back" face
  vertex( 2, -1, -2, .5, 0);
  vertex(-2, -1, -2, .75, 0);
  vertex(-2,  1, -2, .75, 1);
  vertex( 2,  1, -2, 0.5, 1);

  // +Y "bottom" face
  //vertex(-1,  1,  1, 0, 0);
  //vertex( 1,  1,  1, 1, 0);
  //vertex( 1,  1, -1, 1, 1);
  //vertex(-1,  1, -1, 0, 1);

  // -Y "top" face
  // vertex(-1, -1, -1, 0, 0);
  //vertex( 1, -1, -1, 1, 0);
  //vertex( 1, -1,  1, 1, 1);
  // vertex(-1, -1,  1, 0, 1);

  // +X "right" face
  vertex( 2, -1,  2, .25, 0);
  vertex( 2, -1, -2, .5, 0);
  vertex( 2,  1, -2, .5, 1);
  vertex( 2,  1,  2, .25, 1);

  // -X "left" face
  vertex(-2, -1, -2, .75, 0);
  vertex(-2, -1,  2, 1, 0);
  vertex(-2,  1,  2, 1, 1);
  vertex(-2,  1, -2, .75, 1);

  endShape();
}

void mouseDragged() {
  float rate = 0.01;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
}

void fireSignal(char c ){
  //port.write(c);
}
