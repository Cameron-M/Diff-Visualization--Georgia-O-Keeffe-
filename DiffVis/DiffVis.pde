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
GButton loadImage1, loadImage2, ready;
GCheckbox grayBox;
GTextField details, gain_amount;
HScrollbar hs1, hs2;

//Executes once at beginning, like main method
void setup()
{
 size(windowWidth, windowHeight);
 background(200, 200, 200);
 frameRate(24);
 
 //TODO: support more file formats.  right now it only accepts png
 inputImg1 = loadImage("inputImg1.png");
 inputImg2 = loadImage("inputImg2.png");
 //currently, program always looks in its data folder for the images.
 
 //show 2 load buttons that open a file explorer
 loadImage1 = new GButton(this, 100, 620, 200, 50, "Load image 1");
 loadImage2 = new GButton(this, 100, 680, 200, 50, "Load image 2");
 ready = new GButton(this, 100, 740, 200, 50, "Ready");
 
 //Grayscale 
  grayBox = new GCheckbox(this, 650,650,200,50, "GRAYSCALE");
  grayBox.addEventHandler(this,"handleGray");
  
  //Set up our text area for output
 details = new GTextField(this, 600, 740, 400, 30, (0x1000 | 0x0002) );
 gain_amount = new GTextField(this, 10, 530, 200, 30, (0x1000 | 0x0002) );
 
 //Set up our scroll bars
 hs1 = new HScrollbar(0, 590, 300, 16, 1, 100);
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
      
      print("Calculating difference...");
      details.setText("Calculating difference...");
      textSize(28);
      float time = millis();
      
      //calculate difference and return it, then draw it in the output window
      outputImg = getDifference(inputImg1, inputImg2);
      outputImg.save("output.png"); //export the image as output.png
      
      //Change the diff percent after image change
      diffPercent = diffCounter/outputImg.pixels.length;
      diffPercent = diffPercent *100;
      
      println(" Calculated in " + (millis()-time)/1000 + " seconds.\n");
      details.appendText(" Calculated in " + (millis()-time)/1000 + " seconds.\n");
    }
      
  //draw the output in the upper right
  image(outputImg, 20 + windowWidth/4, 10, 3 * windowWidth/4, 3 * windowHeight/4);
  
  //prints diffPercent
  textSize(28);
  text("Pixel Difference Percentage: " +diffPercent+"%",600,635);
  fill(0, 102, 153, 51);
  
  
  hs1.update();
  hs1.display();
  
  gain = hs1.getPos()/100;
  gain_amount.setText("Gain: " + gain);
  
  //Since it can export, zoom feature isn't high priority 
  
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
   
   //If checkbox is checked, then GRAYSCALE
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
    
    //Difference pixel counter
    if(RDiff!=0 || GDiff!=0 || BDiff!=0){
      diffCounter ++;
    } 
  }

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
  } else if(BUTTON == ready){
    changedParameter = true;
  }
}

//Handle our file selection
//a bit sloppy, but we just want something that works right now
void fileSelected1(File selection) {
  if (selection == null) {
    println("User hit cancel.");
  } else {
    String temp = selection.getAbsolutePath();
    print("Loading " + temp + " ...");
    details.setText("Loading " + temp + " ...");
    inputImg1 = loadImage(temp);
    print(" Loaded.");
    details.appendText(" Loaded.\n");
  }
}

void fileSelected2(File selection) {
  if (selection == null) {
    println("User hit cancel.");
  } else {
    String temp = selection.getAbsolutePath();
    print("Loading " + temp + " ...");
    details.setText("Loading " + temp + " ...");
    inputImg2 = loadImage(temp);
    print(" Loaded.");
    details.appendText(" Loaded.\n");
  }
}

//Grayscale Checkbox handler
public void handleGray(GCheckbox grayBox,GEvent SELECTED){
  changedParameter=true;
  if(grayBox.isSelected() == true){
    GRAYSCALE=true;
  }
  if(grayBox.isSelected() == false){
    GRAYSCALE=false;
  }
}

//Copying the example on the processing website:
//http://www.processing.org/examples/scrollbar.html
class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }
  
  HScrollbar (float xp, float yp, int sw, int sh, int l, float start) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = start;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos - xpos;
  }
}
