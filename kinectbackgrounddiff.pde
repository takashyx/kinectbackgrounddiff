import SimpleOpenNI.*;
import monclubelec.javacvPro.*;

// OpenNI
SimpleOpenNI context;
String ONI_FILE_NAME = "straight.oni";

// OpenCV
OpenCV opencv;
Blob[] blobsArray = null;
float threshold = 0.2;

int RINGNUM = 0;

void setup()
{
  //set param
  RINGNUM = 10;

  // OpenNI initialization
  context = new SimpleOpenNI(this);
  context.openFileRecording(ONI_FILE_NAME);
  context.enableDepth(); // Enable depth stream
  context.enableRGB(); // Enable RGB stream
  context.update(); // Retrieve one frame
  
  // OpenCV initialization
  opencv = new OpenCV(this);
  opencv.allocate(context.depthWidth(), context.depthHeight());
  rememberBackground();
  
  // Draw background
  background(200, 0, 0);
  size(
    context.depthWidth()*2 + 10, 
    context.depthHeight()*2 + 10);
}

void rememberBackground()
{
  opencv.copy(context.depthImage());
  opencv.remember(); // Store in the first buffer.
}

PImage retrieveDepthImage()
{
  // Retrieve depth image and raw data
  PImage depthImage = context.depthImage().get();
  int[] depthMap = context.depthMap();

  // Assume depth errors are caused by the black ball
  color white = color(255);
  for (int x = 0; x < context.depthWidth(); x ++) {
    for (int y = 0; y < context.depthHeight(); y ++) {
      if (depthMap[x + y * context.depthWidth()] <= 0) {
        depthImage.set(x, y, white);
      }
    }
  }
  return depthImage;
}

void mouseClicked()
{
  // Set threshold for binarization
  threshold = 1.0f * mouseX / width;
}

void keyPressed()
{
  if (keyCode == ' ')
  {
    println("SPACE KEY :update background");
    rememberBackground();
  }
}

void draw()
{
  // Update the camera image
  context.update();
  PImage depthImage = retrieveDepthImage();

  // Draw the original depth image
  image(depthImage, 
    0, 0, 
    context.depthWidth(), context.depthHeight());
  text("depth", 0, 10);

  // Draw the RGB camera image
  image(context.rgbImage(), 
    context.depthWidth() + 10, 0,
    context.depthWidth(), context.depthHeight());
  text("image",
    context.depthWidth() + 10,
    10);

  // Draw the background image
  image(opencv.getMemory(), 
    0, context.depthHeight() + 10, 
    context.depthWidth(), context.depthHeight());
  text("depth base for diff( Press space key to update )",
    0,
    context.depthHeight() + 20);

  // Calculate the diff image
  opencv.copy(depthImage);
  opencv.absDiff(); // result stored in the secondary memory.
  opencv.restore2(); // restore the secondary memory data to the main buffer
  opencv.blur(3);
  opencv.threshold(threshold, "BINARY");
  depthImage = opencv.getBuffer();
  depthImage = DilateWhite(depthImage, 5); //DilateElode(depthImage, 2);

  // Draw the diff image
  image(depthImage, 
    context.depthWidth() + 10, context.depthHeight() + 10, 
    context.depthWidth(), context.depthHeight());

  // Detect blobs
  opencv.copy(depthImage);
  blobsArray = opencv.blobs(25, 2000, 20, false, 100);
  opencv.drawBlobs(blobsArray, 0, 0, 0.5);
  
  text("depth diff (bin threshold: " + threshold + ")",
    context.depthWidth() + 10,
    context.depthHeight() + 20);
}

PImage DilateErode(PImage in, int times)
{

  in = DilateWhite(in, times);
  in = ErodeWhite(in, times);

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

PImage ErodeWhite(PImage in, int times)
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

