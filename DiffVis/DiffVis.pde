import g4p_controls.*;

PImage inputImg1;
PImage inputImg2;
PImage outputImg, displayImg;
int windowWidth = 1200;//TODO: an option to change window size while running would be nice
int windowHeight = 800;
float gain = 1;// multiply by output pixels to exaggerate the differences
int threshold = 0;
boolean changedParameter = true, invoke_change = false, refresh = true, just_started = true;
float diffCounter = 0;
float diffPercent;
boolean GRAYSCALE = false;
GButton loadImage1, loadImage2, save_image, ready, recenter;
GCheckbox grayBox;
GTextField details, gain_amount, threshold_amount;
HScrollbar gain_bar, threshold_bar;
float RDiff, GDiff, BDiff, current_zoom = 1;
int current_x = 0, current_y = 0;
int previous_mouseX = 0, previous_mouseY = 0;

//Executes once at beginning, like main method
void setup()
{
  frame.setResizable(true); // Enable dynamic resizing while sketching 
  size(windowWidth, windowHeight);
  background(255, 255, 255);
  frameRate(24);

 inputImg1 = loadImage("inputImg1.png");
 inputImg2 = loadImage("inputImg2.png");
 //currently, program always looks in its data folder for the images.
 
 int button_size = windowWidth/8;
 int load_height_pos = 480;
 
 //show 2 load buttons that open a file explorer
 loadImage1 = new GButton(this, 10, load_height_pos, button_size, 50, "Select Image 1");
 loadImage2 = new GButton(this, button_size+10, load_height_pos, button_size, 50, "Select Image 2");
 ready = new GButton(this, 10, load_height_pos + 55, button_size*2, 50, "Display Difference");
 save_image = new GButton(this, 10, load_height_pos + (55*2), button_size*2, 50, "Save Difference Image");
 recenter = new GButton(this, 10, load_height_pos + (55*3), button_size*2, 50, "Reset Position of Difference Image");
 
 //Grayscale 
  grayBox = new GCheckbox(this, 50,720,200,50, "GRAYSCALE");
  grayBox.addEventHandler(this,"handleGray");
  
  //Set up our text area for output
 details = new GTextField(this, 320, 610, 878, 35, (0x1000 | 0x0002) );
 gain_amount = new GTextField(this, 600, 680, 100, 30, (0x1000 | 0x0002) );
 threshold_amount = new GTextField(this, 600, 720, 100, 30, (0x1000 | 0x0002) );
 
 //Set up our scroll bars
 gain_bar = new HScrollbar(700, 700, 300, 16, 1, 800);
 threshold_bar = new HScrollbar(700, 740, 300, 16, 1, 700);
}

//Executes continuously, is like a repeating main method
void draw()
{
  
  //only needs to calculate difference when a parameter is changed, otherwise it's a waste of processing power
    if(changedParameter)
    {
      
      print("Calculating difference..." + "\n");
      details.setText("Calculating difference...");
      textSize(28);
      float time = millis();
      
      //calculate difference and return it, then draw it in the output window
      displayImg = outputImg = getDifference(inputImg1, inputImg2);
      
      //Change the diff percent after image change
      diffPercent = diffCounter/outputImg.pixels.length;
      diffPercent = diffPercent *100;
      
      println(" Calculated in " + (millis()-time)/1000 + " seconds.\n");
      details.appendText(" Calculated in " + (millis()-time)/1000 + " seconds.\n");
      
      current_x = 0;
      current_y = 0;
      current_zoom = 1;
      refresh = true;
    }

    if(just_started){
      details.setText("Welcome!\n");
      just_started = false;
    }
    
   if(refresh){
     background(255, 255, 255);
    //draw thumbnails of the input images to the left of the window
    text("Image 1:", 10, 25);
    image(inputImg1, 10, 32, windowWidth/4, windowHeight/4);
    text("Image 2:", 10, 60+windowHeight/4);
    image(inputImg2, 10, 67+windowHeight/4, windowWidth/4, windowHeight/4);
    //TODO: fix alignment of windows to make them even, use padding so that images don't get stretched out
        
    //draw the output in the upper right
    //PImage disp_temp = (displayImg.get(current_x, current_y, displayImg.width, displayImg.height));
    //disp_temp.resize((int)(displayImg.width * current_zoom), (int)(displayImg.height * current_zoom));
    PImage temp = displayImg.get(current_x, current_y, (int)(displayImg.width * current_zoom), (int)(displayImg.height * current_zoom));
    image(temp, 20 + windowWidth/4, 10, 3 * windowWidth/4, 3 * windowHeight/4);
    
    //prints diffPercent
    textSize(28);
    text("Pixel Difference Percentage: " +diffPercent+"%",320,670);
    fill(0, 102, 153, 51);
    refresh = false;
   }
  
  
  gain_bar.update();
  gain_bar.display();
  threshold_bar.update();
  threshold_bar.display();
  
  //Make Gain and threshold dynamic
  float new_gain = gain_bar.getPos()*0.03;
  int new_threshold = (int)(threshold_bar.getPos()*2.55);
  //only check if relevent values have changed, makes this less of a memory hog
  if(invoke_change || new_gain != gain || new_threshold != threshold){
    gain = new_gain;
    threshold = new_threshold;
    displayImg = createImage(outputImg.width, outputImg.height, RGB);
    //need two versions of for-loops because grayscale affects how we interpret color values
    if(!GRAYSCALE){
       for(int i = 0; i < outputImg.pixels.length; i++){
         float r_value = red(outputImg.pixels[i]);
         float g_value = green(outputImg.pixels[i]);
         float b_value = blue(outputImg.pixels[i]);
         //threshold to return no difference if r/g/b diff is below chosen value
          if (r_value+g_value+b_value < 3*threshold){
             displayImg.pixels[i] = color(0,0,0);
          }else{
           displayImg.pixels[i] = color(r_value * gain, g_value  * gain, b_value  * gain);
          }
       }
     }else{
      for(int i = 0; i < outputImg.pixels.length; i++){
        float r_value = red(outputImg.pixels[i]);
        float g_value = green(outputImg.pixels[i]);
        float b_value = blue(outputImg.pixels[i]);
        if (r_value+g_value+b_value < 3*threshold){
             displayImg.pixels[i] = color(0,0,0);
          }else{
            float TempDiff = r_value * gain + g_value  * gain + b_value  * gain;
            float GrayDiff = TempDiff/3;
            displayImg.pixels[i] = color(GrayDiff, GrayDiff, GrayDiff);
          }
      }
     }
     invoke_change = false;
     refresh = true;
     
     gain_amount.setText("Gain: " + gain);
     threshold_amount.setText("Threshold: " + threshold);
  }
   
  System.gc();
  
}

//Generates the output difference
PImage getDifference(PImage input1, PImage input2)
{
  boolean input_width_diff = true;
  boolean input_height_diff = true;
  int new_width = 0;
  int new_height = 0;
  diffCounter = 0;
  
  // Get size of result image, i.e. max width and max height.
  if (input1.height < input2.height) {
    new_height =  input2.height;
  } else {
    new_height = input1.height;
    if (input1.height == input2.height) input_height_diff = false;
  }
  print("getDifference(): Inputs have different heigth, result image height set to " + new_height + "\n");

  if (input1.width < input2.width) {
    new_width =  input2.width;
    PImage temp = input1;
    input1 = input2;
    input2 = temp;
  } else {
    new_width = input1.width;
    if (input1.width == input2.width) input_width_diff = false;
  }
  print("getDifference(): Inputs have different width, result image width set to " + new_width + "\n");

  PImage temp = createImage(new_width, new_height, RGB);
  // Start manipulating pixels in a for loop for every pixel
  boolean pixel_diff = false;
  int i_max_row = 0;
  int i_row = 0;
  for (int i = 0; i < temp.pixels.length; i++) {
    // If pixel array out of bound, use zero value.
    color input1_pixel = color(0,0,0);
    color input2_pixel = color(0,0,0);
    if (i_max_row == new_width){
      i_max_row = 0;
    } 
    if (i_max_row < input2.width) {
      if (i_row < input2.pixels.length) {
        input2_pixel = input2.pixels[i_row];
      } else {
        pixel_diff = true;
      }
      i_row++;
    } else {
      pixel_diff = true;
    }
    i_max_row++;
    if (i < input1.pixels.length) {
      input1_pixel = input1.pixels[i]; 
    } else {
      pixel_diff = true;
    }

    //find difference between one pixel of each image
    RDiff = abs(red(input1_pixel) - red(input2_pixel));
    GDiff = abs(green(input1_pixel) - green(input2_pixel));
    BDiff = abs(blue(input1_pixel) - blue(input2_pixel));

   //TODO: independent thresholds & gains to examine certain color channels more closely
   
    color diffColor = color(RDiff, GDiff, BDiff);
    
    temp.pixels[i] = diffColor;
    
    //Difference pixel counter
    if(RDiff!=0 || GDiff!=0 || BDiff!=0 || pixel_diff){
      diffCounter ++;
    } 
  }

  // Make the program stop calculating difference for now
  changedParameter = false;
  // Account for gain and greyscale
  invoke_change = true; 
  System.gc();
  return temp;
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
  } else if(BUTTON == save_image){
    selectInput("Save your image:", "fileSave");
  } else if(BUTTON == recenter){
    current_x = 0;
    current_y = 0;
    current_zoom = 1;
    refresh = true;
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
    float time = millis();
    inputImg1 = loadImage(temp);
    println(" Loaded in "  + (millis()-time)/1000 + " seconds.\n");
    details.appendText(" Loaded in " + (millis()-time)/1000 + " seconds.\n");
    refresh = true;
    changedParameter = true;
  }
}

void fileSelected2(File selection) {
  if (selection == null) {
    println("User hit cancel.");
  } else {
    String temp = selection.getAbsolutePath();
    print("Loading " + temp + " ...");
    details.setText("Loading " + temp + " ...");
    float time = millis();
    inputImg2 = loadImage(temp);
    println(" Loaded in " + (millis()-time)/1000 + " seconds.\n");
    details.appendText(" Loaded in " + (millis()-time)/1000 + " seconds.\n");
    refresh = true;
    changedParameter = true;
  }
}

void fileSave(File selection) {
  if (selection == null) {
    println("User hit cancel.");
  } else {
    print("Saving...");
    details.setText("Saving...");
    float time = millis();
    displayImg.save(selection.getAbsolutePath()); //export the image as output.png
    println("Saved in "  + (millis()-time)/1000 + " seconds.\n");
    details.appendText("Saved in "  + (millis()-time)/1000 + " seconds.\n");
    refresh = true;
  }
}

//Grayscale Checkbox handler
public void handleGray(GCheckbox grayBox,GEvent SELECTED){
  invoke_change=true;
  if(grayBox.isSelected() == true){
    GRAYSCALE=true;
  }
  if(grayBox.isSelected() == false){
    GRAYSCALE=false;
  }
  changedParameter = true;
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
    sposMax = xpos + swidth - (sheight/4);
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
    rect(spos, ypos, sheight/4, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return (spos - xpos)/swidth * 100;
  }
}

//for handling scrolling around images
void mouseDragged(){
  
  if(20 + windowWidth/4 <= mouseX && 10 <= mouseY && 3 * windowWidth/4 >= mouseX && 3 * windowHeight/4 >= mouseY){
    current_x = current_x - mouseX + previous_mouseX;
    current_y = current_y - mouseY + previous_mouseY;
    previous_mouseX = mouseX;
    previous_mouseY = mouseY;
    refresh = true;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  if(e < 0){
    if(current_zoom-0.1 > 0) current_zoom -= 0.1;
  } else {
    if(current_zoom+0.1 <= 1) current_zoom += 0.1;
  }
  refresh = true;
}

void mousePressed(){
  previous_mouseX = mouseX;
  previous_mouseY = mouseY;
}

void keyPressed(){

  if(keyCode == 0x6B || keyCode == 0xBB){
    if(current_zoom+0.1 <= 20) current_zoom += 0.1; refresh = true;
  } else if(keyCode == 0xBD || keyCode == 0x6D){
    if(current_zoom-0.1 > 0) current_zoom -= 0.1; refresh = true;
  } else if(keyCode ==   0x26){
    current_y += 1; refresh = true;
  } else if(keyCode ==   0x27){
    current_x -= 1; refresh = true;
  } else if(keyCode ==   0x28){
    current_y -= 1; refresh = true;
  } else if(keyCode ==   0x25){
    current_x += 1; refresh = true;
  }

}

