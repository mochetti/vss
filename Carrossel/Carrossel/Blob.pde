// Classe que gerencia os objetos lidos pela camera baseado na cor

class Blob {
  // Canto superior esquerdo e inferior direito
  float minx;
  float miny;
  float maxx;
  float maxy;
  int cor;
  int id = -1;
  int numPixels = 0;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }
  Blob(float x, float y, int c) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    cor = c;
  }
  Blob(Blob b) {
    minx = b.minx;
    miny = b.miny;
    maxx = b.maxx;
    maxy = b.maxy;
    cor = b.cor;
    id = b.id;
    numPixels = b.numPixels;
  }
  Blob() {
  }
  
  Blob clone() {
    Blob b = new Blob(this);
    return b;
  }

  void show() {
    fill(cores[cor]);
    strokeWeight(2);
    // Como retangulos
    //rectMode(CORNERS);
    //rect(minx, miny, maxx, maxy);
    
    // Como elipse
    ellipse((minx+maxx)/2, (miny+maxy)/2, 15, 15) ;
  }
  void show(color c) {
    fill(c);
    strokeWeight(2);
    // Como retangulos
    //rectMode(CORNERS);
    //rect(minx, miny, maxx, maxy);
    
    // Como elipse
    ellipse((minx+maxx)/2, (miny+maxy)/2, 2.5, 2.5) ;
  }
  PVector center() {
    
    PVector centro = new PVector();
    centro.x = (minx+maxx)/2;
    centro.y = (miny+maxy)/2;
    
    return centro;
  }

  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
    numPixels++;
  }
  
  // Limpa as coordenadas do blob
  void reset() {
    minx = width;
    miny = height;
    maxx = 0;
    maxy = 0;
    numPixels = 0;
  }
 
  // Verifica se um ponto (x, y) está perto do blob
  boolean isNear(float px, float py) {
    int distancia = 25;
    // Coordenadas do centro
    float cx = (minx+maxx)/2;
    float cy = (miny+maxy)/2;
    float dd = distSq(cx, cy, px, py);
    if(dd < distancia*distancia) return true;
    return false;
  }
  
  float size() {
    return (maxx-minx)*(maxy-miny); 
  }
}
