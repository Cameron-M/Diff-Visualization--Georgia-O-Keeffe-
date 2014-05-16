import g4p_controls.*;

PImage inputImg1;
PImage inputImg2;
PImage outputImg;
int windowWidth = 1200;//TODO: an option to change window size while running would be nice
int windowHeight = 800;
float gain = 1;// multiply by output pixels to exaggerate the differences
int threshold = 0;
boolean changedParameter = true;
float diffCounter = 0;
float diffPercent;
boolean GRAYSCALE = false;
GButton loadImage1, loadImage2;

//TODO: add a GUI library such as G4P http://www.lagers.org.uk/g4p/index.html
//      put in sliders and text boxes like in interface I sketched up

//Executes once at beginning, like main method
void setup()
{
 size(windowWidth, windowHeight);
 background(200, 200, 200);
 frameRate(24);
 //TODO: load buttons that open up a file explorer
 //TODO: support more file formats.  right now it only accepts png
 inputImg1 = loadImage("inputImg1.png");
 inputImg2 = loadImage("inputImg2.png");
 //currently, program always looks in its data folder for the images.
 
 //show 2 load buttons that open a file explorer
 loadImage1 = new GButton(this, 100, 650, 200, 50, "Load image 1");
 loadImage2 = new GButton(this, 100, 720, 200, 50, "Load image 2");
}

//Executes continuously, is like a repeating main method
void draw()
{
   background(200, 200, 200);
  //draw thumbnails of the input images to the left of the window
  image(inputImg1, 10, 10, windowWidth/4, windowHeight/4);
  image(inputImg2, 10, 50+windowHeight/4, windowWidth/4, windowHeight/4);
  //TODO: fix alignment of windows to make them even, use padding so that images don't get stretched out
  
  //only needs to calculate difference when a parameter is changed, otherwise it's a waste of processing power
    if(changedParameter)//TODO: once GUI is implemented, make changedParamater = true every time a parameter is changed
    {
      //calculate difference and return it, then draw it in the output window
      outputImg = getDifference(inputImg1, inputImg2);
      outputImg.save("output.png"); //export the image as output.png
    }
      
  //draw the output in the upper right
  image(outputImg, 20 + windowWidth/4, 10, 3 * windowWidth/4, 3 * windowHeight/4);
  
  //prints diffPercent
  diffPercent = diffCounter/outputImg.pixels.length;
  diffPercent = diffPercent *100;
  textSize(28);
  text("Pixel Difference Percentage: " +diffPercent+"%",600,635);
  fill(0, 102, 153, 51);
  
  //TODO: make the output window navigable, with zoom and scrolling
  
}

//Generates the output difference
PImage getDifference(PImage input1, PImage input2)
{
  PImage output = createImage(input1.width, input1.height, RGB);//the output will be the size of the input1 for consistency
  diffCounter = 0;
  //TODO: program crashes when images sizes are different.
  //try & catch the error (array out of bounds) and notify user.  either attempt to find difference anyway, or refuse to work with that pair
  //if user loads inputs separately, don't diff when only one is loaded.  implement button for when user is ready
  
  //start manipulating pixels in a for loop for every pixel
  for (int i = 0; i < output.pixels.length; i++) {
    //find difference between one pixel of each image
    float RDiff = abs(red(input1.pixels[i]) - red(input2.pixels[i]));
    float GDiff = abs(green(input1.pixels[i]) - green(input2.pixels[i]));
    float BDiff = abs(blue(input1.pixels[i]) - blue(input2.pixels[i]));
    
    //threshold to return no difference if r/g/b diff is below chosen value
    if (RDiff+GDiff+BDiff < 3*threshold){
       RDiff = 0;
       GDiff = 0;
       BDiff = 0;
    }

   //TODO: independent thresholds & gains to examine certain color channels more closely
   
   //TODO: have option to make output be grayscale, or apply a gradient map, to more precisely see which pixels have more difference than others
   //needs button to switch boolean GRAYSCALE
   if(GRAYSCALE){
      float TempDiff = RDiff+GDiff+BDiff;
      float GrayDiff = TempDiff/3;
      RDiff = GrayDiff;
      GDiff = GrayDiff;
      BDiff = GrayDiff;
   }
    
    //multiply the colors of difference by gain factor
    color diffColor = color(RDiff * gain, GDiff * gain, BDiff * gain);
    

    
    output.pixels[i] = diffColor;
    
    //needs button to print diffCounter
    if(RDiff!=0 || GDiff!=0 || BDiff!=0){
      diffCounter ++;
    } 
  }
  //TODO: quantify the difference with some data, like number of differing pixels in the images
  
  changedParameter = false;//make the program stop calculating difference for now
  return output;
}


//GUI button handlers

public void handleButtonEvents(GButton BUTTON, GEvent PRESSED)
{
  if(BUTTON == loadImage1){
    selectInput("Select an image:", "fileSelected1");
  } else if(BUTTON == loadImage2){
    selectInput("Select an image:", "fileSelected2");
  }
}

//Handle our file selection
//a bit sloppy, but we just want something that works right now
void fileSelected1(File selection) {
  if (selection == null) {
    println("User hit cancel.");
  } else {
    println("Selected " + selection.getAbsolutePath());
    inputImg1 = loadImage(selection.getAbsolutePath());
    changedParameter = true;
  }
}

void fileSelected2(File selection) {
  if (selection == null) {
    println("User hit cancel.");
  } else {
    println("Selected " + selection.getAbsolutePath());
    inputImg2 = loadImage(selection.getAbsolutePath());
    changedParameter = true;
  }
}
