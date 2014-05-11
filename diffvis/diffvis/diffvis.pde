PImage inputImg1;
PImage inputImg2;
PImage outputImg;
int windowWidth = 1200;
int windowHeight = 800;
float gain = 1;// multiply by output pixels to exaggerate the differences
int threshold = 0;
boolean changedParameter = true;

//TODO: add a GUI library such as G4P http://www.lagers.org.uk/g4p/index.html
//put in sliders and text boxes like in interface

void setup()
{
 size(windowWidth, windowHeight);
 background(0, 0, 0);
 frameRate(24);
 //TODO: we need more user-friendly loading if possible.
 //A step in the right direction would be textboxes to enter urls
 //even better would be a load button that opens file explorer (don't know if this is possible with Processing)
 inputImg1 = loadImage("inputImg1.png");
 inputImg2 = loadImage("inputImg2.png");
}

void draw()
{
  //draw thumbnails of the input images to the left of the window
  image(inputImg1, 10, 10, windowWidth/4, windowHeight/4);
  image(inputImg2, 10, 20+windowHeight/4, windowWidth/4, windowHeight/4);
  
  //only needs to calculate difference when a parameter is changed
    if(changedParameter)
      //calculate difference and return it, then draw it in the output window
      outputImg = getDifference(inputImg1, inputImg2);
  image(outputImg, 20 + windowWidth/4, 10, 3 * windowWidth/4, 3 * windowHeight/4);
  //TODO: make the output window navigatable, with zoom and scrolling
}

//Generates the output difference
PImage getDifference(PImage input1, PImage input2)
{
  PImage output = createImage(input1.width, input1.height, RGB);//the output will be the size of the 
  float pixelColor;
  
  //start manipulating pixels
  for (int i = 0; i < output.pixels.length; i++) {
    //find difference between one pixel of each image
    float RDiff = abs(red(input1.pixels[i]) - red(input2.pixels[i]));
    float GDiff = abs(green(input1.pixels[i]) - green(input2.pixels[i]));
    float BDiff = abs(blue(input1.pixels[i]) - blue(input2.pixels[i]));
    
    //TODO: create threshold to return no difference if r/g/b diff is below a chosen value
    //TODO: if we can get thresholds working, have independent thresholds & gains to examine certain color channels more closely
    
    //multiply the colors of difference by gain factor
    color diffColor = color(RDiff * gain, GDiff * gain, BDiff * gain);
    
    output.pixels[i] = diffColor;
  }
  changedParameter = false;
  return output;
}
