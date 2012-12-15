import SimpleOpenNI.*;
SimpleOpenNI  context;
PImage DiffBaseDepthImage;
PImage BlurredDepthImage;
PImage DiffDepthImage;
color DiffThreshold;

int RINGNUM = 0;

void setup()
{
  //set param
  DiffThreshold = color(50, 50, 50);
  RINGNUM = 10;

  //kinect obj
  context = new SimpleOpenNI(this);
  context.openFileRecording("straight.oni");

  // enable depthMap generation 
  context.enableDepth();

  // enable camera image generation
  context.enableRGB();

  context.update();

  DiffBaseDepthImage = new PImage(context.depthWidth(), context.depthHeight());
  DiffDepthImage = new PImage(context.depthWidth(), context.depthHeight());

  DiffBaseDepthImage = context.depthImage().get();

  background(200, 0, 0);
  size(context.depthWidth() + 10, 
  context.depthHeight()+ 10);
}

void keyPressed()
{
  if (keyCode == ' ')
  {
    println("SPACE KEY :update background");
    context.update();
    DiffBaseDepthImage = context.depthImage().get();
  }
}

void draw()
{
  // update the cam
  context.update();

  for (int i = 0 ; i < context.depthWidth(); i++)
  {
    for (int j = 0 ; j < context.depthHeight(); j++)
    {
      if (
      abs(  red(DiffBaseDepthImage.get(i, j)) -   red(context.depthImage().get(i, j))) >   red(DiffThreshold)||
        abs( blue(DiffBaseDepthImage.get(i, j)) -  blue(context.depthImage().get(i, j))) >  blue(DiffThreshold)||  
        abs(green(DiffBaseDepthImage.get(i, j)) - green(context.depthImage().get(i, j))) > green(DiffThreshold)
        )
      {
        DiffDepthImage.set(i, j, color(255, 255, 255));
      }
      else
      {
        DiffDepthImage.set(i, j, color(0, 0, 0));
      }
    }
  }

  DiffDepthImage = DilateWhite(DiffDepthImage,5);//DilateElode(DiffDepthImage,2);

  // draw depthImageMap
  image(context.depthImage(), 
  0, 0, 
  context.depthWidth()/2, context.depthHeight()/2);
  text("depth", 0, 10);

  // draw camera
  image(context.rgbImage(), 
  context.depthWidth()/2 + 10, 0, context.depthWidth()/2, 
  context.depthHeight()/2);
  text("image", context.depthWidth()/2 + 10, 10);


  // draw init depth
  image(DiffBaseDepthImage, 
  0, context.depthHeight()/2 +10, 
  context.depthWidth()/2, context.depthHeight()/2+10);
  text("depth base for diff( Press space key to update )", 0, context.depthHeight()/2 +20);

  // draw diff depth
  image(DiffDepthImage, 
  context.depthWidth()/2+10, 
  context.depthHeight()/2+10, 
  context.depthWidth()/2+10, context.depthHeight()/2+10);
  text("depth diff", context.depthWidth()/2+10, context.depthHeight()/2+20);
}

PImage DilateElode(PImage in, int times)
{

  in = DilateWhite(in, times);
  in = ElodeWhite(in, times);

  return in;
}

PImage DilateWhite(PImage in, int times)
{
  color BLACK = color(0, 0, 0);
  color WHITE = color(255, 255, 255);
  PImage out;
  out = in.get();

  for (int t=0; t<times;t++)
  {
    //
    for(int i=0;i<in.width;i++)
    {
      out.set(i,0,BLACK);
      out.set(i,in.height,BLACK);
    }
    for(int j=0;j<in.height;j++)
    {
      out.set(0,j,BLACK);
      out.set(in.width,j,BLACK);
    }
    
    for (int i = 1 ; i < in.width-1 ; i++)
    {
      for (int j = 1 ; j < in.height-1 ; j++ )
      {
        if (
        in.get(i-1, j-1) == WHITE &&
          in.get(i, j-1) == WHITE &&
          in.get(i+1, j-1) == WHITE &&
          in.get(i-1, j) == WHITE &&
          in.get(i+1, j) == WHITE &&
          in.get(i-1, j+1) == WHITE &&
          in.get(i, j+1) == WHITE &&
          in.get(i+1, j+1) == WHITE 
          )
        {
          out.set(i, j, WHITE);
        }
        else
        { 
          out.set(i, j, BLACK);
        }
      }
    }
  }
  return out;
}

PImage ElodeWhite(PImage in, int times)
{
  color BLACK = color(0, 0, 0);
  color WHITE = color(255, 255, 255);

  PImage out;
  out = in.get();

  for (int t=0;t<times;t++)
  {
    for (int i = 1 ; i < in.width-1 ; i++)
    {
      for (int j = 1 ; j < in.height-1 ; j++ )
      {
        if (
        in.get(i-1, j-1) == WHITE ||
          in.get(i, j-1) == WHITE ||
          in.get(i+1, j-1) == WHITE ||
          in.get(i-1, j) == WHITE ||
          in.get(i+1, j) == WHITE ||
          in.get(i-1, j+1) == WHITE ||
          in.get(i, j+1) == WHITE ||
          in.get(i+1, j+1) == WHITE 
          )
        {
          out.set(i, j, WHITE);
        }
        else
        { 
          out.set(i, j, BLACK);
        }
      }
    }
  }
  return out;
}

