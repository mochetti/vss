import processing.video.*;
import processing.serial.*;

Serial myPort;

// Cores
color cores[] = { color(223, 90, 47), // Laranja
                  color(204, 35, 45), // Vermelho
                  color(125, 240, 30)  // Verde
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

boolean pausado = false;

Movie mov;

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Vermelho
// 2 - Verde
int[] quantCor = {1, 3, 6};

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Blob> oldBlobs = new ArrayList<Blob>();
ArrayList<Robo> robos = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();

void setup() {
  size(595, 400);  
  mov = new Movie(this, "teste3.mov");
  //myPort = new Serial(this, Serial.list()[0], 9600);
  mov.loop();
  mov.speed(0.5);
  mov.jump(0);
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  image(mov, 0, 0);
  fill(255);
  text(getFrame() + " / " + (getLength() - 1), 10, 30);
  // Armazena as ultimas coordenadas de cada blob
  oldBlobs.clear();
  for(Blob b : blobs) oldBlobs.add(new Blob(b.clone()));
  blobs.clear();
  //print("MAIN: Quantidade de blobs: ");
  //println(oldBlobs.size());
  // Busca os objetos
  if(!track()) return;
  
  // Inicializa os robos
  robos.clear();
  for(int i = 0; i < quantCor.length; i++) {
    robos.add(new Robo(i));
  }
  
  velBola();
  
  noFill();
  stroke(255);
 
  // Define as estratégias dos robos
  //robos.get(0).setEstrategia(3);
  //robos.get(0).debugObj();
  
  robos.get(0).setEstrategia(3);
  robos.get(1).setEstrategia(2);
  robos.get(2).setEstrategia(1);
  for(Robo r : robos) r.debugObj();
  
  //controle(robos.get(0));
  
}
  

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  //int loc = mouseX + mouseY*mov.width;
  //mouseColor = mov.pixels[loc];
  //printArray(mouseColor);
  println("X: " + mouseX + " Y: " + mouseY);
  if(pausado) {
    pausado = false;
    mov.play();
  }
  else {
    pausado = true;
    mov.pause();
  }
}
