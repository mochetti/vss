import processing.serial.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;

// Cores
color cores[] = { color(215, 80, 80), // Laranja
                  color(206, 175, 55), // Amarelo
                  color(208, 105, 170) // Rosa
                };

// id de cada objeto
// 0 - Bola
// 1 - Meio Robo 0
// 2 - Meio Robo 1
// 3 - Meio Robo 2
// 4 - Quina 0 Robo 0
// 5 - Quina 0 Robo 1
// 6 - Quina 1 Robo 1
// 7 - Quina 0 Robo 2
// 8 - Quina 1 Robo 2
// 9 - Quina 2 Robo 2
// 10 - Inimigo

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Amarelo
// 2 - Rosa
int[] quantCor = {1, 1, 1};

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Blob> oldBlobs = new ArrayList<Blob>();
ArrayList<Robo> robos = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();

color trackColor;
color mouseColor; 

// Depth threshold
int depthThreshold = 745;
int alturaDepth = 25;
// Angulo do kinect
float kinectAng;
                
// Flags de debug
boolean dimensionar = true;
boolean second = false;
boolean calibra = true;
boolean buscandoCor = true;
boolean algumPonto = false;

Serial myPort;

// Propriedades do campo
int Y_AREA = 200;
PVector comeco = new PVector();
PVector fim = new PVector();
PImage kinectRGB;
PImage kinectDepth;

void setup() {
  
  size(1280, 520);
  kinect = new Kinect(this);
  
  kinect.initDepth();
  kinect.initVideo();
  
  kinectAng = kinect.getTilt();
  
  kinect.alternativeViewPointDepthToImage();

}

void draw() {
  
  background(0);
  
  // Display some info
  fill(255);
  text("threshold: " + depthThreshold + "    " +  "framerate: " + int(frameRate) + "    " +  "angulo: " + kinectAng, 10, 500);

  // Imagem RGB
  kinectRGB = kinect.getVideoImage();
  // Mostra a imagem pra selecionar o campo
  if(dimensionar) {
    image(kinectRGB, 640, 0);
    return;
  }
  // Imagem Depth
  kinectDepth = kinect.getDepthImage(); 
  //image(kinectDepth, 0, 0);
  
  // Retangulo de busca do campo
  noFill();
  stroke(255);
  rectMode(CORNERS);
  rect(comeco.x + 640, comeco.y, fim.x + 640, fim.y);
  
  // Armazena as ultimas coordenadas de cada blob
  oldBlobs.clear();
  for(Blob b : blobs) oldBlobs.add(new Blob(b.clone()));
  blobs.clear();
  
  // Encontra as saliencias
  saliencias();  
  
  // Busca os objetos
  //if(!track()) return;
  
  //showBola();
  
  
  //// Inicializa os robos
  //robos.clear();
  //for(int i = 0; i < quantCor.length; i++) {
  //  robos.add(new Robo(i));
  //}
  
  //velBola();
  
  //noFill();
  //stroke(255);
 
  //// Define as estratégias dos robos
  ////robos.get(0).setEstrategia(3);
  ////robos.get(0).debugObj();
  
  //robos.get(0).setEstrategia(3);
  //robos.get(1).setEstrategia(2);
  //robos.get(2).setEstrategia(1);
  //for(Robo r : robos) r.debugObj();
  
  //alinha(robos.get(0));
  
  // Envia os comandos
  //enviar();

}

// Adjust the threshold with key presses
void keyPressed() {
  if(key == 'w') {
    kinectAng++;
    kinectAng = constrain(kinectAng, 0, 30);
    kinect.setTilt(kinectAng);
  }
  if(key == 's') {
    kinectAng--;
    kinectAng = constrain(kinectAng, 0, 30);
    kinect.setTilt(kinectAng);
  }
  if (key == CODED) {
    if (keyCode == UP) {
      // Depth threshold
      depthThreshold += 5;
    } else if (keyCode == DOWN) {
      depthThreshold -= 5;
    }
    else if (keyCode == RIGHT) {
      depthThreshold ++;
    }
    else if (keyCode == LEFT) {
      depthThreshold --;
    }
  }
}

void mousePressed() {
  if(dimensionar) dimensionaCampo();
  if(calibra && !dimensionar) calibra();
}
