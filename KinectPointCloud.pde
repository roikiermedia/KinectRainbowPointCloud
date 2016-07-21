// Daniel Shiffman
// Kinect Point Cloud example
// butchered by centro & @roikiermedia

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// Kinect Library object
Kinect kinect;

// Angle for rotation
float a = 0;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];
  
  int ranX = (int)random(0, 200);
  int ranY = (int)random(0, 200);
  int ranZ = (int)random(0, 200);


import codeanticode.syphon.*;

SyphonServer server;

void settings() {
  size(800,600, P3D);
  PJOGL.profile=1;
}  
  
void setup() {
  // Rendering in P3D
  //size(800, 600, P3D);
  //fullScreen(P3D);
  pixelDensity(1);
  kinect = new Kinect(this);
  kinect.initDepth();
  
  server = new SyphonServer(this, "Processing Syphon");

  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
    
}

void draw() {
  
  //ranX = ranX+(int)random(-1, 1);
  //ranY = ranY+(int)random(-1, 1);
  //ranZ = ranZ+(int)random(-1, 1);
  
  ranX = max(ranX, 40);
  ranX = min(ranX, 200);
  
  ranY = max(ranY, 40);
  ranY = min(ranY, 200);
  
  ranZ = max(ranZ, 40);
  ranZ = min(ranZ, 200);
  

  background(0);
  //background(255,255,255,100);

  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
  int skip = 3;

  // Translate and rotate
  translate(width/2, height/2, -50);
  //rotateY(a);
  
  // Nested for loop that initializes x and y pixels and, for those less than the
  // maximum threshold and at every skiping point, the offset is caculated to map
  // them on a plane instead of just a line
  for (int x = 0; x < kinect.width; x += skip) {
    for (int y = 0; y < kinect.height; y += skip) {
      int offset = x + y*kinect.width;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);

      stroke(255);
      pushMatrix();
      // Scale up by 200
      float factor = 1200;
      translate(v.x*factor, v.y*factor, factor-v.z*factor);
      // Draw a point
      float colourZ = map(rawDepth, 0, 2048, 0, 255);
      float colourX = map(x, 0, kinect.width, 40, 255);
      float colourY = map(y, 0, kinect.height, 40, 255);
      int strokeWeight = (int)map(rawDepth, 0, 1200, 5, 0);
      //stroke(colourZ, colourX, colourY);
      stroke(255);
      strokeWeight(strokeWeight);
      point(0, 0);
      popMatrix();
    }
  }

  // Rotate
  a += 0.0025f;
  
  server.sendScreen();
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

// Only needed to make sense of the ouput depth values from the kinect
PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

// Drawing the result vector to give each point its three-dimensional space
  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}

void keyPressed() {
  
  if (key == CODED) {
    if (keyCode == UP) {
      tilt = tilt + 1;
    } else if (keyCode == DOWN) {
      tilt = tilt - 1;
    } 
  } else {
    
  }
  kinect.setTilt(tilt);
}