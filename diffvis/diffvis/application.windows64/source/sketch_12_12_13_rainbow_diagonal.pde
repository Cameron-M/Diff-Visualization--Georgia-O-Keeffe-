void setup()
{
   size(1280, 720);
   background(128, 12, 12);
   strokeWeight(1);
   frameRate(24); 
}

void draw()
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
