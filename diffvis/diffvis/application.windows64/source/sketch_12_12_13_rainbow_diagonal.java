import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch_12_12_13_rainbow_diagonal extends PApplet {

public void setup()
{
   size(1280, 720);
   background(128, 12, 12);
   strokeWeight(1);
   frameRate(24); 
}

public void draw()
{
   for (int i =0; i< width; i++)
  {
     float r = random(width);
     float s = random(width);
     float t = random(width);
     stroke(r, s, t);
     line(r, s, t, height); 
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sketch_12_12_13_rainbow_diagonal" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
