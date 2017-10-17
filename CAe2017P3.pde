// Base code for Cae 2017 Project 3 on Animation Aesthetics

// variables to control display
boolean showConstruction=true; // show construction edges and circles
boolean showControlFrames=true;  // show start and end poses
boolean showStrobeFrames=false; // shows 5 frames of animation
boolean computingBlendRadii=false; // toggles whether blend radii are computed or adjusted with mouse ('b' or 'd' with vertical mouse moves)

// Variables that control the shape
float g = 350;            // ground height measured downward from top of canvas
float x0 = 160, x1 = 850; // initial & final coordinate of disk center 
float y0 = 200;           // initial & final vertical coordinate of disk center above ground (y is up)
float x = x0, y = y0;     // current coordinates of disk center 
float r0 = 50;            // initial & final disk radius
float r = r0;             // current disk radius
float b0 = 100, d0 = 130;   // initial & final values of the width of bottom of dress (on both sides of x)
float b = b0, d = d0;     // current values of the width of bottom of dress (on both sides of x)
float _p = b0, _q = d0;     // global values of the radii of the left and right arcs of the dress (user edited)

// Animation
boolean animating = true; // animation status: running/stopped
float t=0.1;               // current animaiton time

// snapping a picture
import processing.pdf.*;    // to save screen shots as PDFs
boolean snapPic=false;
String PicturesOutputPath="data/PDFimages";
int pictureCounter=0;
//void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); }

// Filming
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse


void setup()              // run once
  {
  size(1000, 400, P2D); 
  frameRate(30);        // draws new frame 30 times a second
    int n = 7;
    for(int i=0; i<n; i++) println("i="+i);
  }
 
void draw()             // loops forever
  {
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf"); // start recording for PDF image capture
  if(animating) computeParametersForAnimationTime(t);
  background(255);      // erase canvas at each frame
  stroke(0);            // change drawing color to black
  line(0, g, width, g); // draws gound
  noStroke(); 
  if(showControlFrames) {fill(0,255,255); paintShape(x0,y0,r0,b0,d0); fill(255,0,255); paintShape(x1,y0,r0,b0,d0);}
  if(showStrobeFrames) 
    {
    float xx=x, yy=y, rr=r, bb=b, dd=d;
    int n = 7;
    for(int j=0; j<n; j++)
      {
      fill(255-(200.*j)/n,(200.*j)/n,155); 
      float tt = (float)j / (n-1); // println("j="+j+", t="+t);
      computeParametersForAnimationTime(tt);
      paintShape(x,y,r,b,d); 
      }
    println();
    x=xx; y=yy; r=rr; b=bb; d=dd;
    }
  fill(0); paintShape(x,y,r,b,d); // displays current shape
  if(showConstruction) {noFill(); showConstruction(x,y,r,b,d);} // displays blend construction lines and circles
  showGUI(); // shows mouse location and key pressed
  if(snapPic) {endRecord(); snapPic=false;} // end saving a .pdf of the screen
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif"); // saves a movie frame 
  if(animating) {t+=0.01; if(t>=1) {t=1; animating=false;}} // increments timing and stops when animation is complete
  change=false; // reset to avoid rendering movie frames for which nothing changes
  }

void keyPressed()
  {
  if(key=='`') snapPic=true; // to snap an image of the canvas and save as zoomable a PDF
  if(key=='~') filming=!filming;  // filming on/off capture frames into folder FRAMES 
  if(key=='.') computingBlendRadii=!computingBlendRadii; // toggles computing radii automatically
  if(key=='f') showControlFrames=!showControlFrames;
  if(key=='c') showConstruction=!showConstruction;
  if(key=='s') showStrobeFrames=!showStrobeFrames;
  if(key=='a') {animating=true; t=0;}  // start animation
  change=true; // reset to render movie frames for which something changes
  }
  
void mouseMoved() // press and hold the key you want and then move the mouse (do not press any mouse button)
  {
  if(keyPressed)
    {
    if(key=='r') r+=mouseX-pmouseX;
    if(key=='x') {x+=mouseX-pmouseX; y-=mouseY-pmouseY;}
    if(key=='b') {b-=mouseX-pmouseX; _p-=mouseY-pmouseY;}
    if(key=='d') {d+=mouseX-pmouseX; _q-=mouseY-pmouseY;}
    }
  change=true; // reset to render movie frames for which something changes
  }

// display shape defined by the 5 parameters (and by _p and _q when these are not to be recomputed automatically
void paintShape(float x, float y, float r, float b, float d)
  {
  float p=_p, q=_q; // use gobal values (user controlled) in case we do not want to recompute them automatically
  if(computingBlendRadii)
    {
    p=blendRadius(b,y,r);
    q=blendRadius(d,y,r);
    }

  int n = 30; // number of samples
  
  beginShape(); // starts drawing shape
 
    // sampling the left arc
    float u0=-PI/2, u1 = atan2(y-p,b); 
    float du = (u1-u0)/(n-1);
    for (int i=0; i<n; i++) // loop to sample let arc
      {
      float s=u0+du*i;
      vertex(x-b+p*cos(s),g-p-p*sin(s)); 
      }

    // sampling the right arc
    float v0=-PI/2, v1 = atan2(y-q,d); 
    float dv = (v1-v0)/(n-1);
    for (int i=n-1; i>=0; i--) // loop to sample let arc
      {
      float s=v0+dv*i;
      vertex(x+d-q*cos(s),g-q-q*sin(s));
      }

  endShape(CLOSE);  // Closes the shape 
  
  ellipse(x,g-y,r*2,r*2);  // draw disk
  }

// shows construction lines for shape defined by the 5 parameters (and by _p and _q when these are not to be recomputed automatically
void showConstruction(float x, float y, float r, float b, float d) 
  {
  // compute blend radii
  float p=_p, q=_q; // use gobal values (user controlled) in case we do not want to recompute them automatically
  if(computingBlendRadii)
    {
    p=blendRadius(b,y,r);
    q=blendRadius(d,y,r);
    }
  
  strokeWeight(2);  
  // draw left arc
  stroke(200,0,0);      // change line  color to red
  line(x-b,g,x-b,g-p);  // draw vertical edge to center of left circle
  line(x-b,g-p,x,g-y);  // draw diagonal edge from center of left circle to center of disk
  ellipse(x-b,g-p,p*2,p*2);  // draw left circle

  // draw right arc
  stroke(0,150,0);      // change line color to darker green
  line(x+d,g,x+d,g-q);  // draw vertical edge to center of right circle
  line(x+d,g-q,x,g-y);  // draw diagonal edge from center of right circle to center of disk
  ellipse(x+d,g-q,q*2,q*2);  // draw left circle
  }
  
// show Mouse and key pressed
void showGUI()
  {
  noFill(); stroke(155,155,0);
  if(mousePressed) strokeWeight(3); else strokeWeight(1);
  ellipse(mouseX,mouseY,30,30);
  if(keyPressed) {fill(155,155,0); strokeWeight(2); text(key,mouseX-6,mouseY);}
  strokeWeight(1);
  }
  
//*********** TO BE PROVIDED BY STUDENTS    
// computes current values of parameters x, y, r, b, d for animation parameter t
// so as to produce a smooth and aesthetically pleasing animation
// that conveys a specific emotion/enthusiasm of the moving shape
void computeParametersForAnimationTime(float t) // computes parameters x, y, r, b, d for current t value
  {
  x = x0 + t*(x1-x0);
  y = y0 - y0*0.3*sqrt(sin(PI*t));
  b = b0 + b0*0.8*sqrt(sin(PI*t));
  d = d0 - d0*0.4*sqrt(sin(PI*t));
  }
  
//*********** TO BE PROVIDED BY STUDENTS  
// compute blend radius tangent to x-axis at point (0,0) and circle of center (b,y) and radius r   
float blendRadius(float b, float y, float r) 
  {
  return 100; // replace with your formula
  }