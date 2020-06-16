import processing.video.*;
import processing.serial.*;


/*

 Checar conexão do rádio com a serial do TX e também do receptor. Aparentemente está perdendo por mal contato do rádio.
  
 Por algum motivo os blobs não tão reconhecendo. Não to entendendo o porque o b.show() tá mostrando os blobs. Debugar a visão inteira e debugar a parte dos id's.
 Printar os id's e colocar robô por robô no campo e tentar separadamente para depois juntá-los. Garantir que estão na posição certa da array
 
 */

// Flags de debug
boolean debug = true;

// Controla a entrada da imagem
// 0 - camera
// 1 - video 
// 2 - simulador
int inputVideo = 2;

boolean calibra = true;  //Flag de controle se deve ou não calibrar as cores
boolean visao = false;  //Flag de controle para parar o código logo após jogar a imagem no canvas (visão) a visão ou não
boolean controle = true;  // Flag para rodar o bloco de controle
boolean estrategia = true; // Flag para rodar o bloco de estratégia
boolean radio = true; //Flag de controle para emitir ou não sinais ao rádio (ultimo passo da checagem)
boolean gameplay = false;  //Flag de controle que diz se o jogo está no automático ou no manual (apenas do robô 0 por enquanto)
boolean simManual = true;

// estretagia usada quando estrategia = false;
int estFixa = 0;

//Variavel para contar frames
int qtdFrames = 0;

// variaveis pro controle do arrasto do mouse
PVector clique = new PVector();
int dragged = 0;

// Verifica se ainda estamos configurando o robo
//boolean configRobo = false;

boolean pausado = false;

//boolean andaReto = false; //DENTRO DE INERCIA()

Serial myPort;

// Salvar as cores num txt pra poupar tempo na hora de calibrar (?)
// Cores
color cores[] = { 
  color(245, 166, 73), // Laranja
  color(16, 148, 238), // Azul
  color(238, 96, 119) // Vermelho
};

// id de cada objeto
// 0 - Bola
// 1 - Meio Robo 0 (vermelho maior)
// 2 - Meio Robo 1 (robo xadrez)
// 3 - Meio Robo 2 (vermelho na direita)
// 4 - Quina Robo 0
// 5 - Quina Robo 1
// 6 - Quina Robo 2

// 6 - Quina 1 Robo 1
// 7 - Quina 0 Robo 2
// 8 - Quina 1 Robo 2
// 9 - Quina 2 Robo 2
// 10 - Inimigo

// campo[i]
// 0        1
// 3        2

color trackColor;  //Qual cor estou procurando
color mouseColor;  //Ultima cor selecionada no clique do mouse

// current color sendo calibrada
int calColor = -1;

// Numero de pixels do maior blob da cor vermelha, usado para distinguir o goleiro dos outros dois robôs (robo 0)
int pxMaiorBlobVermelho = 0;

// Numero de pixels do menor blob da cor verde, usado para distinguir do outro robô com verde (robo 1)
int pxMenorBlobVerde = 0;

// Conta o tempo de execucao
double tempo = millis();
double antes = millis();

// Quantidade de quadros para vencer a inercia no controle alinhandando
//int contagemAlinhandando = 0;


// Propriedades do campo
int Y_AREA = 120;

// define o campo como dois pontos
//PVector shapeCampo.getVertex(0) = new PVector();
//PVector shapeCampo.getVertex(2) = new PVector();

// define o campo como quatro pontos
//PVector campo[] = {new PVector(), new PVector(), new PVector(), new PVector()};


//Movie mov;
Capture cam;
//PImage screenshot;

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Azul
// 2 - Vermelho
int[] quantCor = {1, 3, 3};
int elementos = 0;

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Blob> oldBlobs = new ArrayList<Blob>();
ArrayList<Robo> robos = new ArrayList<Robo>();
ArrayList<Robo> oldRobos = new ArrayList<Robo>();
ArrayList<Robo> robosSimulados = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();
PVector bola = new PVector();

void setup() {

  shapeCampo = createShape();

  for (int i : quantCor) elementos += i;


  //mov = new Movie(this, "real.mp4");
  //mov.play();
  //mov.loop();

  //mov.frameRate(30);
  ellipseMode(RADIUS);
  size(800, 448);

  //byte[] txBuffer = {};
  //txBuffer = new byte[7];
  //txBuffer[0] = byte(128);

  frame.removeNotify();
  frameRate(30);
  //if (inputVideo == 0) {
    printArray(Serial.list());
    myPort = new Serial(this, Serial.list()[1], 115200);
    //camConfig();
  //}
}

void movieEvent(Movie m) {
  m.read();
}
void captureEvent(Capture c) {
  c.read();
}

void draw() {
  if (inputVideo == 0 && cam.available() || inputVideo == 2) {
    //loadPixels();
    background(0);
    tempo = millis();
    //println(tempo);

    //tempo = 0;
    if (inputVideo == 0) image(cam, 0, 0);



    //noFill();
    stroke(255);
    if (isCampoDimensionado) {
      // Mostra o campo na tela

      shape(shapeCampo);
      shape(shapeCampo.getChild(0));
      shape(shapeCampo.getChild(1));
      // Mostra os gols
      golInimigo = new PVector((shapeCampo.getVertex(1).x + shapeCampo.getVertex(2).x) /2, (shapeCampo.getVertex(1).y+shapeCampo.getVertex(2).y) / 2);
      golAmigo = new PVector((shapeCampo.getVertex(0).x + shapeCampo.getVertex(3).x) /2, (shapeCampo.getVertex(0).y+shapeCampo.getVertex(3).y) / 2);

      fill(0, 0);
      ellipse(golAmigo.x, golAmigo.y, 20, 20);
      ellipse(golInimigo.x, golInimigo.y, 20, 20);

      if  (inputVideo == 2) simulador();

      /*
    OBSERVAÇÕES RELACIONADAS A VISÃO PERTINENTES:
       Antes de chamar a função track(), a array blobs precisa ser resetada para se buscar novos pontos na tela. Assim não deixa o negócio "lento"
       */

      //oldBlobs.clear();
      //blobs.clear();
      //for(Robo r : robos) oldBlobs.add(new Robo(r.clone()));
      oldBlobs.clear();
      if (blobs.size() > 0)
        for (Blob b : blobs) oldBlobs.add(new Blob(b.clone()));

      oldRobos.clear();
      if (robos.size() > 0)
        for (Robo r : robos) oldRobos.add(new Robo(r.clone()));

      robos.clear();
      blobs.clear();

      if (debug) return;

      //Atualiza blobs
      track();
      id();

      for (int i = 1; i < 4; i++) {
        if (oldRobos.size() == 0) {
          if (blobs.get(i).numPixels > 0 || blobs.get(i+3).numPixels > 0) robos.add(new Robo(i-1));
          else robos.add(new Robo(-1));
        } else {
          if (blobs.get(i).numPixels > 0 || blobs.get(i+3).numPixels > 0) robos.add(new Robo(oldRobos.get(i-1).clone()));
          else robos.add(new Robo(-1));
        }
      }

      //Defino a bola
      bola = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);

      //A partir daqui pode definir os objetivos.

      //Defino as estratégias
      if (estrategia) {
        // Define as estratégias dos robos
        // 5 - seguir mouse, 6 fazer nada (por enquanto), 1 - atacante, 3 - goleiro

        if (robos.get(0).index >= 0) robos.get(0).setEstrategia(5);
        if (robos.get(1).index >= 0) robos.get(1).setEstrategia(5);
        if (robos.get(2).index >= 0) {
          robos.get(2).setEstrategia(5);
          robos.get(2).obj = new PVector(robos.get(2).obj.x, robos.get(2).obj.y + 100);
        }
        //if (robos.get(2).index >= 0) robos.get(2).setEstrategia(5);
      } // posicoes fixas
      else for (Robo r : robos) if (r.index >= 0) r.setEstrategia(estFixa);

      //r.frente() não pode vir antes da estratégia, precisa ter os objetivos definidos.
      for (Robo r : robos) if (r.index >= 0 && !r.girando) r.frente();

      //print(robos.get(0).ang);

      // Debugo as estrategias (mostra na tela)
      for (Robo r : robos) if (r.index >= 0) r.debugObj();

      //A partir daqui controle assume

      if (controle) {

        //println(robos.get(0).girando);

        if (robos.get(0).index >= 0 && !robos.get(0).girando) alinhaAnda(robos.get(0));
        if (robos.get(1).index >= 0 && !robos.get(1).girando) alinhaAnda(robos.get(1));
        if (robos.get(2).index >= 0 && !robos.get(2).girando) alinhaAnda(robos.get(2));

        if (gameplay) gameplay(robos.get(0));
      }

      //A partir daqui envia dados
      //if (inputVideo == 0) enviar();
      enviar();
    } else {
      // no simulador, o campo é o próprio canvas
      if (inputVideo == 2) {
        dimensionaCampo(0, 0);
        dimensionaCampo(width, 0);
        dimensionaCampo(width, height);
        dimensionaCampo(0, height);
        return;
      }

      //desenha as linhas na tela se formando
      for (int i = 0; i < shapeCampo.getVertexCount() - 1; i++) {
        strokeWeight(2);
        line(shapeCampo.getVertex(i).x, shapeCampo.getVertex(i).y, shapeCampo.getVertex(i+1).x, shapeCampo.getVertex(i+1).y);
      }
    }
  }
}

void keyPressed() {
  if (key == TAB) {
    roboControlado++;
    if (roboControlado == 3) roboControlado = 0;
    println("KEY: Controlando o robo " + roboControlado);
  }
  if (key == 'd') {
    println("KEY: debug on/off");
    debug = !debug;
  }
  if (key == 'c') {
    calibra = !calibra;
    if (calibra) {
      println("KEY: calibra on");
    } else {
      println("KEY: calibra off");
    }
  }
  if (key >= '0' && key <= '9') {
    println("KEY: Cor " + key);
    calColor = key;
  }
  if (key == 'r') {
    println("KEY: radio on/off");
    radio = !radio;
  }
  if (key == 'C') {
    println("KEY: redefinir campo");
    isCampoDimensionado = false;
    shapeCampo = createShape();
  }

  //MOVIE
  if (key == ' ') {
    // chute aleatorio na bola
    bolaV.vel.set(random(10)-5, random(10)-5);
    if (pausado) {
      //mov.play();
      pausado = false;
    } else {
      //mov.pause();
      pausado = true;
    }
  }
  if (key == 'v') {
    println("KEY: debug visao on/off");
    visao = !visao;
  }
  if (key == 'S') {
    println("KEY: simulador manual/automatico");
    simManual = !simManual;
  }
  if (key == 'g') {
    println("KEY: gameplay on/off");
    gameplay = !gameplay;
  }
  // posicao inicial
  if (key == 'P') {
    println("KEY: posicao inicial");
    estFixa = 6;
    estrategia = !estrategia;
  }
}

void mouseDragged() {
}

void mouseReleased() {
  PVector mouse = new PVector(mouseX, mouseY);
  PVector tiro = PVector.sub(mouse, clique);
  tiro.setMag(sqrt(distSq(mouse, clique))/40);
  bolaV.vel = tiro;
}

void keyReleased() {
  if (robos.size() > 0) {
    robos.get(0).velE = 0;
    robos.get(0).velD = 0;
  }
}

void mousePressed() {
  clique.x = mouseX;
  clique.y = mouseY;

  print("R = " + red(mouseColor));
  print("  G = " + green(mouseColor));
  println("  B = " + blue(mouseColor));
  //println("X: " + mouseX + " Y: " + mouseY);

  if (!isCampoDimensionado) dimensionaCampo(mouseX, mouseY);
  if (calibra) calibra();
}
