PImage inputImg1;
PImage inputImg2;
PImage outputImg;
int windowWidth = 1200;//TODO: an option to change window size while running would be nice
int windowHeight = 800;
float gain = 1;// multiply by output pixels to exaggerate the differences
int threshold = 0;
boolean changedParameter = true;

//TODO: add a GUI library such as G4P http://www.lagers.org.uk/g4p/index.html
//put in sliders and text boxes like in interface I sketched up

//Executes once at beginning, like main method
void setup()
{
 size(windowWidth, windowHeight);
 background(200, 200, 200);
 frameRate(24);
 //TODO: we need more user-friendly loading if possible.
 //A step in the right direction would be textboxes to enter file urls
 //even better would be load buttons that open file explorer (don't know if this is possible with Processing)
 //TODO: support more file formats.  right now it only accepts png
 inputImg1 = loadImage("inputImg1.png");
 inputImg2 = loadImage("inputImg2.png");
 //currently, program always looks in its data folder for the images.
 //for me (Michael) that data folder is C:\Users\Michael\Documents\Processing\michael\differenceVisualization\DiffVis\data
 //when you save your own version of the program it will have a different data folder.
 //if there's no data folder, click Sketch->Add File to add images into automatically created data folder, or you can create/add manually
}

//Executes continuously, is like a repeating main method
void draw()
{
  //draw thumbnails of the input images to the left of the window
  image(inputImg1, 10, 10, windowWidth/4, windowHeight/4);
  image(inputImg2, 10, 50+windowHeight/4, windowWidth/4, windowHeight/4);
  //TODO: fix alignment of windows to make them even, use padding so that images don't get stretched out
  
  //only needs to calculate difference when a parameter is changed, otherwise it's a waste of processing power
    if(changedParameter)//TODO: once GUI is implemented, make changedParamater = true every time a parameter is changed
      //calculate difference and return it, then draw it in the output window
      outputImg = getDifference(inputImg1, inputImg2);
      
  //draw the output in the upper right    
  image(outputImg, 20 + windowWidth/4, 10, 3 * windowWidth/4, 3 * windowHeight/4);
  //TODO: make the output window navigable, with zoom and scrolling
  
  //TODO: have an option to export the output
}

//Generates the output difference
PImage getDifference(PImage input1, PImage input2)
{
  PImage output = createImage(input1.width, input1.height, RGB);//the output will be the size of the input1 for consistency
  //TODO: program crashes when images sizes are different.
  //try & catch the error (array out of bounds) and notify user.  either attempt to find difference anyway, or refuse to work with that pair
  float pixelColor;
  
  //start manipulating pixels in a for loop for every pixel
  for (int i = 0; i < output.pixels.length; i++) {
    //find difference between one pixel of each image
    float RDiff = abs(red(input1.pixels[i]) - red(input2.pixels[i]));
    float GDiff = abs(green(input1.pixels[i]) - green(input2.pixels[i]));
    float BDiff = abs(blue(input1.pixels[i]) - blue(input2.pixels[i]));
    
    //TODO: create threshold to return no difference if r/g/b diff is below a chosen value
    //TODO: if we can get thresholds working, have independent thresholds & gains to examine certain color channels more closely
    
    //multiply the colors of difference by gain factor
    color diffColor = color(RDiff * gain, GDiff * gain, BDiff * gain);
    
    //TODO: have option to make output be grayscale, or apply a gradient map, to more precisely see which pixels have more difference than others
    
    output.pixels[i] = diffColor;
  }
  //TODO: quantify the difference with some data, like number of differing pixels in the images
  
  changedParameter = false;//make the program stop calculating difference for now
  return output;
}
