
float[][] kernel = {{ -1, -1, -1}, 
                    { -1,  9, -1}, 
                    { -1, -1, -1}};
                    
PImage img;

ArrayList<PVector> edgeVertex = new ArrayList<PVector>();
PVector drawPos = new PVector(0,0);

final int iterNum = 5;

int threshold = 255;

float v = 1.0/9.0;

int index = 0;

int scaleFactor = 10;

void setup() { 
  fullScreen();
  img = loadImage("treeRings.jpg");
}

void draw() {
  scale(scaleFactor);
  image(img, drawPos.x, drawPos.y);
  
  iterate(iterNum);
  
  if(keyPressed)
    if(key == 'w') {
      drawPos.y -= 10;
    }
    
    if(key == 's') {
      drawPos.y += 10;
    }
    
    if(key == 'a') {
      drawPos.x -= 10;
    }
    
    if(key == 'd') {
      drawPos.x += 10;
    }
    
    if(key == 'x') {
      scaleFactor++;
    }
    
    if(key == 'c') {
      scaleFactor--;
    }
  
  //noLoop();
}

void connectEdges() {
  img.loadPixels();
  
  PImage edgeImg = createImage(img.width, img.height, RGB);

  for (int y = 1; y < img.height-1; y++) { 
    for (int x = 1; x < img.width-1; x++) { 
      float sum = 0;
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          int pos = (y + ky)*img.width + (x + kx);
          float val = red(img.pixels[pos]);
          sum += kernel[ky+1][kx+1] * val;
        }
      }
      edgeImg.pixels[y*img.width + x] = color(sum, sum, sum);
    }
  }
  
  img.updatePixels();
  
  edgeImg.loadPixels();
  
  for(int y = 0; y < edgeImg.height; y++) {
    for(int x = 0; x < edgeImg.width; x++) {
      int pos = (y*edgeImg.width) + x;
      
      float greyVal = red(edgeImg.pixels[pos]);
      
      if(greyVal >= threshold) {
        edgeVertex.add(new PVector(x, y));
        //println(x);
        //println(y);
      }
    }
  }
  
  image(edgeImg, drawPos.x, drawPos.y);
  
  stroke(255);
  for(int i = 0; i < edgeVertex.size()/2; i += 2) {
    line(edgeVertex.get(i).x, edgeVertex.get(i).y, edgeVertex.get(i + 1).x, edgeVertex.get(i + 1).y);
  }
  
  img = edgeImg;
}

void soften() {
  float[][] kernel = {{ v, v, v}, 
                      { v, v, v}, 
                      { v, v, v}};
  img.loadPixels();

  // Create an opaque image of the same size as the original
  PImage edgeImg = createImage(img.width, img.height, RGB);

  // Loop through every pixel in the image
  for (int y = 1; y < img.height-1; y++) {   // Skip top and bottom edges
    for (int x = 1; x < img.width-1; x++) {  // Skip left and right edges
      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*img.width + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = red(img.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel[ky+1][kx+1] * val;
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      edgeImg.pixels[y*img.width + x] = color(sum);
    }
  }
  // State that there are changes to edgeImg.pixels[]
  edgeImg.updatePixels();

  image(edgeImg, -width/2, -height/2); // Draw the new image
}

void iterate(int iterNum) {
  while(index < iterNum) {
    connectEdges();
    soften();
    //makeNoise();
    index++;
  }
}

void makeNoise() {
  img.loadPixels();

  // Create an opaque image of the same size as the original
  PImage edgeImg = createImage(img.width, img.height, RGB);
  
  for(int y = 0; y < edgeImg.height; y++) {
    for(int x = 0; x < edgeImg.width; x++) {
      int pos = (y*edgeImg.width) + x;
      
      edgeImg.pixels[pos] = int(red(edgeImg.pixels[pos]) * noise(x, y));
    }
  }
  
  img.updatePixels();
  
  image(edgeImg, 0, 0);
}

void keyPressed() {
    println(key);
}