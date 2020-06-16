//import processing.video.*;
import processing.serial.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.Rectangle;

// Flags de debug
boolean calibra = true;
boolean dimensionaCampo = true;
boolean campoDimensionado = false;
boolean buscandoCor = true;
boolean algumPonto = false;

Serial myPort;

// Cores
color cores[] = { color(220, 130, 42), // Laranja
                  color(241, 240, 50), // Amarelo
                  color(210, 120, 190) // Rosa
                };
float limites[] = { 2, 10,
                    5, 15,
                    6, 4
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

color trackColor;
color mouseColor; 

// Propriedades do campo
int Y_AREA = 200;
PVector comecoCampo = new PVector();
PVector finalCampo = new PVector();

//Movie mov;
//Capture cam;
PImage screenshot;

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

void setup() {
  size(700, 450);  
  frame.removeNotify();
  frameRate(30);
  //camConfig();

  
}

//void movieEvent(Movie m) {
//  m.read();
//}
//void captureEvent(Capture c) {
//  c.read();
//}

void draw() {
  screenshot();
  image(screenshot, 0, 0);
  //set(0, 0, cam);
  // Mostra o campo na tela
  noFill();
  rectMode(CORNERS);
  rect(comecoCampo.x, comecoCampo.y, finalCampo.x, finalCampo.y);
  fill(255);
  // Armazena as ultimas coordenadas de cada blob
  oldBlobs.clear();
  for(Blob b : blobs) oldBlobs.add(new Blob(b.clone()));
  blobs.clear();
  //print("MAIN: Quantidade de blobs: ");
  //println(oldBlobs.size());
  
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
  

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*screenshot.width;
  mouseColor = screenshot.pixels[loc];
  //print("R = " + red(mouseColor));
  //print("  G = " + green(mouseColor));
  //println("  B = " + blue(mouseColor));
  //println("X: " + mouseX + " Y: " + mouseY);
  //if(buscandoCor && campoDimensionado) println("Quantidade de pixels = " + qPixels(mouseX, mouseY, cores[2]));
  if(dimensionaCampo) dimensionaCampo();
  if(calibra) calibra();
}
