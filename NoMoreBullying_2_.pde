
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import processing.sound.*;


ArrayList<PerfilJugador> perfiles = new ArrayList<PerfilJugador>();


SoundFile musicaMenu, musicaNivel1, musicaNivel2;
SoundFile sfxGameOver, sfxBoton, sfxDanio;
int estadoMusicaAnterior = -2;

PerfilJugador perfilActual = null;
int estadoJuego = -1;
String nombreArchivoPerfiles = "perfiles.txt";
String entradaTextoPerfil = "";
boolean creandoPerfil = false;
int botonYCrear;



int puntuacionTotal = 0, nivelActual = 1;
int puntuacionSesionNivel1 = 0, puntuacionSesionNivel2 = 0;
int botonX, botonY, botonW, botonH;

color colorPrimario   = color(100, 200, 255);  
color colorSecundario = color(255, 160,  60);  
color colorPeligro    = color(220,  50,  80);  
color colorTexto      = color(240, 240, 255);
color colorFondo      = color( 10,  12,  28);
color colorPanel      = color( 15,  25,  50, 230);
color colorPositivo   = color( 80, 220, 120);  

int velocidadSalto = -22, velY = 0;
float velX = 0, aceleracion = 2.5, friccion = 0.8, maxVelX = 11;
int gravedad = 2, salto = 0, puedeSaltar = 1;
int saltosDisponibles = 2, saltosActuales = 0;
int teclaDerecha = 0, teclaIzquierda = 0, teclaArriba = 0;
int movex = 200, movey = 410;
float velocidad = 6;
int imageIndex = 0, juegoTerminado = 0;
int vidas = 3, recolectados = 0, tiempo = 0;
int tiempoObjetivo = 1200;
int distanciaRecorrida = 0, combo = 0, comboTimer = 0;
float velocidadMaxima = 10;
boolean escudoActivo = false;
int tiempoEscudo = 0, ultimoTipoObstaculo = 0;
int misionesCompletadas = 0;
boolean mision1 = false, mision2 = false, mision3 = false;
int tiempoSinDanio = 0, mensajeActual = 0, tiempoMensaje = 0;
int puntosDanioJefe = 0;

ArrayList<QuizGate> gates = new ArrayList<QuizGate>();

class ConceptoConvivencia {
  String mensaje;
  Pregunta pregunta;
  boolean desbloqueado;

  ConceptoConvivencia(String m, String pTexto, String opA, String opB, boolean aCorrecta) {
    mensaje = m;
    pregunta = new Pregunta(pTexto, opA, opB, aCorrecta);
    desbloqueado = false;
  }
}

ArrayList<ConceptoConvivencia> baseConocimiento = new ArrayList<ConceptoConvivencia>();

class Pregunta {
  String texto, opArriba, opAbajo;
  boolean arribaEsCorrecta;
  Pregunta(String t, String a, String b, boolean c) {
    texto=t; opArriba=a; opAbajo=b; arribaEsCorrecta=c;
  }
}


class QuizGate {
  float x;
  Pregunta pregunta;
  boolean resuelta = false;

  QuizGate(float x) {
    this.x = x;
    ArrayList<Pregunta> disp = new ArrayList<Pregunta>();
    for (ConceptoConvivencia c : baseConocimiento)
      if (c.desbloqueado) disp.add(c.pregunta);
    if (disp.size() > 0)
      this.pregunta = disp.get(int(random(disp.size())));
    else
      this.pregunta = new Pregunta("Tutorial: Salta para elegir", "Arriba", "Abajo", true);
  }

  void actualizar(float vel) { x -= vel; }

  void dibujar() {
    stroke(colorSecundario, 150); strokeWeight(2);
    for (int i = 0; i < height; i += 20) line(x, i, x, i+10);

    if (x > -300 && x < width+300) {
      float pW=720, pH=50, pX=width/2-pW/2, pY=70;
      pushStyle();
      fill(10,15,30,240); stroke(colorPrimario); strokeWeight(2);
      rect(pX, pY, pW, pH, 15);
      fill(255,215,0); textSize(22); textAlign(LEFT,CENTER);
      text("?", pX+18, pY+pH/2-2);
      fill(255); textSize(17); textAlign(CENTER,CENTER);
      text("?" + pregunta.texto + "?", width/2, pY+pH/2-2);
      popStyle();
    }

    fill(100,200,255,180); stroke(colorPrimario);
    rect(x-250, 280, 500, 25, 5);
    fill(255); textSize(10); textAlign(CENTER);
    text("ACTUAR - SALTAR", x, 295);
    fill(100,100,100); rect(x-250, 305, 500, 5);
    fill(255); textSize(16); text(pregunta.opArriba, x, 242);

    fill(colorPanel); rect(x-60, 430, 120, 40, 10);
    fill(255); text(pregunta.opAbajo, x, 455);
  }

  int verificarColision(float px, float py) {
    if (resuelta) return 0;
    if (px > x-20 && px < x+20) {
      resuelta = true;
      return ((py < 380) == pregunta.arribaEsCorrecta) ? 1 : -1;
    }
    return 0;
  }
}


boolean modoGlitch = false;
int tiempoGlitch = 0, tipoGlitch = 0;
float intensidadGlitch = 0;

PImage fondo1, fondo2;
float fondoX1 = 0, fondoX2;
PImage[] correr = new PImage[8];
PImage obstaculo, item;

PImage imgBoss1, imgBoss2, imgDisparoPlayer, imgDisparoBoss;
PImage imgMensaje1, imgMensaje2, imgMensaje2True, imgMensaje3, imgMensaje3True;

boolean modoJefe = false;
Boss jefeActual;
ArrayList<Proyectil> proyectilesJugador = new ArrayList<Proyectil>();
ArrayList<Proyectil> proyectilesJefe    = new ArrayList<Proyectil>();
int municion = 5, tiempoRecarga = 0;
boolean fasePhishing = false;
PhishingChallenge desafioActual = null;
int tiempoDesafio = 0;

String mensajeFinal = "", textoEscribiendose = "";
int indiceEscritura = 0;
boolean murioPorPhishing = false;

PFont cyberFont;

void setup() {
  size(1200, 600);
  pixelDensity(1);
  cyberFont = createFont("Courier New Bold", 32);
  textFont(cyberFont);

  baseConocimiento.clear();
  baseConocimiento.add(new ConceptoConvivencia(
    "El respeto en internet es tan importante como en la vida real.",
    "Ves comentarios ofensivos hacia un companero en redes sociales",
    "Reportar los comentarios y apoyar al companero",
    "Compartirlos para burlarte tambien",
    true));
  baseConocimiento.add(new ConceptoConvivencia(
    "El ciberacoso puede afectar emocionalmente a una persona.",
    "Un estudiante recibe mensajes amenazantes por chat",
    "Hablar con un adulto y guardar evidencias",
    "Responder con mas insultos",
    true));
  baseConocimiento.add(new ConceptoConvivencia(
    "Hablar con un adulto de confianza siempre ayuda.",
    "Tu amigo recibe burlas todos los dias",
    "Acompanarlo al orientador",
    "Decirle que lo ignore",
    true));
  baseConocimiento.add(new ConceptoConvivencia(
    "Compartir informacion privada sin permiso esta mal.",
    "Un amigo quiere publicar fotos vergonzosas de otra persona",
    "Decirle que no lo haga",
    "Ayudarle a subirlas",
    true));
  baseConocimiento.add(new ConceptoConvivencia(
    "Nadie merece ser excluido por como es.",
    "Hay un alumno nuevo que no conoce a nadie",
    "Presentarte y darle la bienvenida",
    "Dejarlo solo hasta que se adapte",
    true));
  baseConocimiento.add(new ConceptoConvivencia(
    "Las palabras en internet tambien pueden herir.",
    "En un grupo hacen memes humillando a alguien",
    "Defender a la persona y reportar",
    "Reirte y compartir los memes",
    true));
  baseConocimiento.add(new ConceptoConvivencia(
    "Actuar, no solo mirar: los testigos detienen el acoso.",
    "Ves a un grupo intimidando a alguien en el patio",
    "Pedir ayuda a un profesor",
    "Grabarlo y subirlo a redes sociales",
    true));

  botonX=width/2-120; botonY=height/2+50; botonW=240; botonH=50;
  botonYCrear = height-150;

  cargarPerfiles();
  ordenarPerfiles();
  cargarMusica();

  imgBoss1 = loadImage("boss1.png");
  if (imgBoss1!=null) imgBoss1.resize(250,250);
  imgBoss2 = loadImage("boss2.png");
  if (imgBoss2!=null) imgBoss2.resize(280,280);
  imgDisparoPlayer = loadImage("disparo_player.png");
  if (imgDisparoPlayer!=null) imgDisparoPlayer.resize(40,40);
  imgDisparoBoss = loadImage("disparo_boss.png");
  if (imgDisparoBoss!=null) imgDisparoBoss.resize(50,50);

  imgMensaje1     = cargarImagenSegura("bancolombia_email.png");
  imgMensaje2     = cargarImagenSegura("apple_email.png");
  imgMensaje2True = cargarImagenSegura("apple_email_verdadero.png");
  imgMensaje3     = cargarImagenSegura("google_email.png");
  imgMensaje3True = cargarImagenSegura("google_email_verdadero.png");

  nivel1Setup();
}

PImage cargarImagenSegura(String nombre) {
  PImage img = loadImage(nombre);
  if (img==null) {
    img = createImage(400,300,RGB);
    img.loadPixels();
    for (int i=0;i<img.pixels.length;i++) img.pixels[i]=color(80,80,100);
    img.updatePixels();
  }
  return img;
}

void cargarMusica() {
  try {
    musicaMenu   = new SoundFile(this,"drum-or-bass-ryan-stasik-413932 (mp3cut.net).mp3");
    musicaNivel1 = new SoundFile(this,"Pixel-City-Cruising.ogg");
    musicaNivel2 = new SoundFile(this,"Endless-Cyber-Runner-2.ogg");
    sfxGameOver  = new SoundFile(this,"fail-144746.mp3");
    sfxBoton     = new SoundFile(this,"button-press-382713.mp3");
    sfxDanio     = new SoundFile(this,"cough-gag-80393.mp3");
  } catch (Exception e) { println("Audio: "+e.getMessage()); }
}


void draw() {
  gestionarMusica();
  switch(estadoJuego) {
    case -1: dibujarSeleccionPerfil(); break;
    case  0: dibujarMenuPrincipal();   break;
    case  1: dibujarTutorial();        break;
    case  2: nivel1Draw();             break;
    case  3: dibujarVictoriaNivel1();  break;
    case  4: nivel2Draw();             break;
    case  8: dibujarVictoriaNivel2();  break;
    case  5: dibujarVictoriaFinal();   break;
    case  6: dibujarGameOver();        break;
    case  7: dibujarCreditos();        break;
  }
}

void gestionarMusica() {
  if (estadoMusicaAnterior==estadoJuego) return;
  boolean antMenu=(estadoMusicaAnterior==-1||estadoMusicaAnterior==0||estadoMusicaAnterior==1||estadoMusicaAnterior==3||estadoMusicaAnterior==5||estadoMusicaAnterior==7);
  boolean actMenu=(estadoJuego==-1||estadoJuego==0||estadoJuego==1||estadoJuego==3||estadoJuego==5||estadoJuego==7);
  if (antMenu&&actMenu) {
    if (musicaMenu!=null&&!musicaMenu.isPlaying()) musicaMenu.loop();
  } else {
    detenerTodasLasMusicas();
    if (actMenu) { if (musicaMenu!=null&&!musicaMenu.isPlaying()) musicaMenu.loop(); }
    else if (estadoJuego==2) { if (musicaNivel1!=null&&!musicaNivel1.isPlaying()) musicaNivel1.loop(); }
    else if (estadoJuego==4||estadoJuego==8) { if (musicaNivel2!=null&&!musicaNivel2.isPlaying()) musicaNivel2.loop(); }
    else if (estadoJuego==6) { if (sfxGameOver!=null) sfxGameOver.play(); }
  }
  estadoMusicaAnterior=estadoJuego;
}

void detenerTodasLasMusicas() {
  if (musicaMenu!=null&&musicaMenu.isPlaying()) musicaMenu.stop();
  if (musicaNivel1!=null&&musicaNivel1.isPlaying()) musicaNivel1.stop();
  if (musicaNivel2!=null&&musicaNivel2.isPlaying()) musicaNivel2.stop();
}

void reproducirSonidoBoton() { if(sfxBoton!=null) sfxBoton.play(); }
void reproducirSonidoDanio()  { if(sfxDanio!=null) sfxDanio.play(); }

void keyPressed() {
  if (estadoJuego==-1&&creandoPerfil) {
    if (key==ENTER||key==RETURN) {
      if (entradaTextoPerfil.length()>0) {
        reproducirSonidoBoton();
        perfilActual=new PerfilJugador(entradaTextoPerfil);
        perfiles.add(perfilActual); guardarPerfiles();
        creandoPerfil=false; entradaTextoPerfil=""; estadoJuego=0;
      }
    } else if (key==BACKSPACE||key==DELETE) {
      if (entradaTextoPerfil.length()>0)
        entradaTextoPerfil=entradaTextoPerfil.substring(0,entradaTextoPerfil.length()-1);
    } else if (key!=CODED&&entradaTextoPerfil.length()<8) {
      entradaTextoPerfil+=key;
    }
    return;
  }
  if (estadoJuego==2||estadoJuego==4) {
    if (keyCode==RIGHT) teclaDerecha=1;
    if (keyCode==LEFT)  teclaIzquierda=1;
    if (keyCode==UP)    teclaArriba=1;
    if (key==' '&&modoJefe&&!fasePhishing) dispararJugador();
    if (fasePhishing&&desafioActual!=null) {
      if (key=='f'||key=='F') resolverPhishing(true);
      if (key=='v'||key=='V') resolverPhishing(false);
    }
  }
  if (key==ENTER||key==RETURN) {
    if (estadoJuego==0)                              { reproducirSonidoBoton(); estadoJuego=1; }
    else if (estadoJuego==1)                         { reproducirSonidoBoton(); estadoJuego=2; nivel1Setup(); }
    else if (estadoJuego==3)                         { reproducirSonidoBoton(); estadoJuego=4; nivel2Setup(); }
    else if (estadoJuego==8)                         { reproducirSonidoBoton(); estadoJuego=5; }
    else if (estadoJuego==5||estadoJuego==6||estadoJuego==7) {
      reproducirSonidoBoton(); estadoJuego=0;
      puntuacionTotal=0; nivelActual=1;
      puntuacionSesionNivel1=0; puntuacionSesionNivel2=0;
      mensajeFinal=""; textoEscribiendose=""; indiceEscritura=0; murioPorPhishing=false;
    }
  }
  if (key==ESC) {
    key=0; reproducirSonidoBoton(); estadoJuego=0;
    mensajeFinal=""; textoEscribiendose=""; indiceEscritura=0; murioPorPhishing=false;
  }
}

void keyReleased() {
  if (keyCode==RIGHT) teclaDerecha=0;
  if (keyCode==LEFT)  teclaIzquierda=0;
  if (keyCode==UP)    teclaArriba=0;
}


void mousePressed() {
  if (estadoJuego==-1) {
    if (creandoPerfil) {
      if (mouseX>width/2-80&&mouseX<width/2+80&&mouseY>height/2+40&&mouseY<height/2+80) {
        if (entradaTextoPerfil.length()>0) {
          reproducirSonidoBoton();
          perfilActual=new PerfilJugador(entradaTextoPerfil);
          perfiles.add(perfilActual); ordenarPerfiles(); guardarPerfiles();
          creandoPerfil=false; entradaTextoPerfil=""; estadoJuego=0;
        }
      }
      return;
    }
    int sY=160,mg=15,aP=50,pW=500,pX=width/2-pW/2;
    int maxP=min(perfiles.size(),5);
    for (int i=0;i<maxP;i++) {
      int py=sY+i*(aP+mg);
      if (mouseX>pX&&mouseX<pX+pW&&mouseY>py&&mouseY<py+aP) {
        reproducirSonidoBoton(); perfilActual=perfiles.get(i); estadoJuego=0; break;
      }
    }
    int bY=height-100;
    if (mouseX>width/2-120&&mouseX<width/2+120&&mouseY>bY&&mouseY<bY+50) {
      reproducirSonidoBoton(); creandoPerfil=true; entradaTextoPerfil="";
    }
  }
  if (estadoJuego==0) {
    int bX=width/2-150,bW=300,bH=55,yJ=350,yC=420,yCr=490;
    if (mouseX>bX&&mouseX<bX+bW&&mouseY>yJ &&mouseY<yJ +bH) { reproducirSonidoBoton(); estadoJuego=1; }
    if (mouseX>bX&&mouseX<bX+bW&&mouseY>yC &&mouseY<yC +bH) { reproducirSonidoBoton(); estadoJuego=-1; }
    if (mouseX>bX&&mouseX<bX+bW&&mouseY>yCr&&mouseY<yCr+bH) { reproducirSonidoBoton(); estadoJuego=7; }
  }
}

void cargarPerfiles() {
  perfiles.clear();
  String[] lineas = loadStrings(nombreArchivoPerfiles);
  if (lineas!=null) {
    for (String linea : lineas) {
      if (linea.contains(":")) {
        String[] p=split(linea,':');
        PerfilJugador pj=new PerfilJugador(p[0]);
        try {
          if (p.length>=2) pj.scoreNivel1=int(p[1]);
          if (p.length>=3) pj.scoreNivel2=int(p[2]);
        } catch (Exception e) { println("Error perfil: "+p[0]); }
        perfiles.add(pj);
      }
    }
  }
}

void guardarPerfiles() {
  String[] lineas=new String[perfiles.size()];
  for (int i=0;i<perfiles.size();i++) {
    PerfilJugador p=perfiles.get(i);
    lineas[i]=p.nombre+":"+p.scoreNivel1+":"+p.scoreNivel2;
  }
  saveStrings(nombreArchivoPerfiles,lineas);
}

void exit() { detenerTodasLasMusicas(); guardarPerfiles(); super.exit(); }


void dibujarSeleccionPerfil() {
  background(colorFondo); dibujarEfectoFondo();
  float pW=700,pH=500,pX=width/2-pW/2,pY=height/2-pH/2;
  fill(10,15,30,230); stroke(colorPrimario); strokeWeight(2); rect(pX,pY,pW,pH,15);
  fill(colorPrimario); textAlign(CENTER); textSize(32);
  text("BASE DE DEFENSORES", width/2, pY+50);
  textSize(14); fill(colorSecundario);
  text("SELECCIONA TU PERFIL PARA COMENZAR", width/2, pY+76);

  int sY=int(pY+116),mg=10,aP=45,lW=int(pW-100),lX=int(width/2-lW/2);
  fill(colorSecundario,50); noStroke(); rect(lX,sY-30,lW,30,5,5,0,0);
  fill(colorPrimario); textSize(13); textAlign(LEFT);
  text("RANGO",lX+20,sY-10); text("DEFENSOR",lX+100,sY-10);
  textAlign(RIGHT); text("PUNTAJE",lX+lW-20,sY-10);

  int maxP=min(perfiles.size(),5);
  for (int i=0;i<maxP;i++) {
    PerfilJugador p=perfiles.get(i);
    int py=sY+i*(aP+mg);
    boolean hov=mouseX>lX&&mouseX<lX+lW&&mouseY>py&&mouseY<py+aP;
    if (hov) { fill(colorPrimario,50); stroke(colorPrimario); }
    else     { fill(20,30,50,150); noStroke(); }
    rect(lX,py,lW,aP,5);
    textAlign(LEFT); textSize(17);
    if (i==0) text("1.",lX+20,py+27);
    else if (i==1) text("2.",lX+20,py+27);
    else if (i==2) text("3.",lX+20,py+27);
    else { fill(colorTexto,150); text("#"+(i+1),lX+20,py+27); }
    fill(colorTexto); textSize(19); text(p.nombre.toUpperCase(),lX+100,py+27);
    fill(colorPrimario); textAlign(RIGHT); textSize(17);
    text(nfc(p.obtenerPuntajeTotal())+" PTS",lX+lW-20,py+27);
  }

  int bY=int(pY+pH-70);
  dibujarBoton(width/2-120,bY,240,50,"NUEVO DEFENSOR",colorSecundario);

  if (creandoPerfil) {
    fill(0,0,0,220); rect(0,0,width,height);
    fill(20,20,40); stroke(colorPrimario); strokeWeight(3);
    rect(width/2-250,height/2-120,500,240,15);
    fill(colorPrimario); textAlign(CENTER); textSize(24);
    text("NUEVO DEFENSOR",width/2,height/2-68);
    fill(colorTexto); textSize(14);
    text("INGRESA TU NOMBRE (max 8 caracteres):",width/2,height/2-30);
    fill(10,10,20); stroke(colorSecundario);
    rect(width/2-150,height/2-10,300,50,5);
    fill(colorPrimario); textSize(26); textAlign(CENTER);
    text(entradaTextoPerfil+((frameCount%30<15)?"_":""),width/2,height/2+25);
    dibujarBoton(width/2-100,height/2+60,200,45,"CONFIRMAR",colorPrimario);
  }
}

void dibujarMenuPrincipal() {
  background(colorFondo); dibujarEfectoFondo();
  textAlign(CENTER); textSize(70);
  fill(colorSecundario,50); text("NO MORE BULLYING",width/2+4,154);
  fill(colorPrimario);      text("NO MORE BULLYING",width/2,150);
  textSize(17); fill(colorTexto);
  text("LUCHA CONTRA EL ACOSO  |  EDICION 2026",width/2,192);

  float pY=238;
  fill(colorPanel); stroke(colorPrimario,150);
  rect(width/2-250,pY,500,60,10);
  fill(colorSecundario); textSize(12);
  text("DEFENSOR ACTIVO",width/2,pY+20);
  fill(colorTexto); textSize(21);
  text(perfilActual.nombre.toUpperCase(),width/2,pY+44);

  int sY=350,gap=70;
  dibujarBoton(width/2-150,sY,      300,55,"INICIAR MISION",  colorPrimario);
  dibujarBoton(width/2-150,sY+gap,  300,55,"CAMBIAR DEFENSOR", colorSecundario);
  dibujarBoton(width/2-150,sY+gap*2,300,55,"CREDITOS",         colorTexto);
}


void dibujarTutorial() {
  background(colorFondo); dibujarEfectoFondo();
  fill(colorPrimario); textAlign(CENTER); textSize(36);
  text("GUIA DEL DEFENSOR",width/2,60);

  float pY=100,pH=350;
  fill(10,15,30,200); stroke(colorSecundario); rect(100,pY,450,pH,15);
  fill(colorSecundario); textSize(20); text("CONTROLES",325,pY+40);
  dibujarTecla(250,pY+100,"^","SALTAR");
  dibujarTecla(180,pY+180,"<","IZQUIERDA");
  dibujarTecla(320,pY+180,">","DERECHA");
  dibujarTecla(250,pY+260,"ESP","DEFENDER (JEFE)");

  fill(10,15,30,200); stroke(colorPrimario); rect(650,pY,450,pH,15);
  fill(colorPrimario); textSize(20); text("TU MISION",875,pY+40);
  textAlign(LEFT); textSize(16); fill(colorTexto);
  float tX=700,tY=pY+88,g=46;
  text("+ RECOLECTA CORAZONES DE EMPATIA",tX,tY);
  text("- ESQUIVA MENSAJES DE ACOSO",tX,tY+g);
  text("? DECIDE: ACTUAR O IGNORAR",tX,tY+g*2);
  text("! RECHAZA MENSAJES DANINOS",tX,tY+g*3);
  text("* COMPLETA MISIONES DE APOYO",tX,tY+g*4);

  fill(colorSecundario); textAlign(CENTER); textSize(19);
  if (frameCount%60<30) text("> PRESIONA ENTER PARA COMENZAR <",width/2,height-50);
}

void dibujarTecla(float x, float y, String s, String a) {
  float w=(s.length()>1)?120:60,h=60;
  fill(50); stroke(200); rect(x-w/2,y,w,h,10);
  fill(30); noStroke(); rect(x-w/2,y+h,w,5,0,0,10,10);
  fill(255); textAlign(CENTER,CENTER); textSize(17); text(s,x,y+h/2-3);
  fill(colorTexto); textSize(12); text(a,x,y+h+25);
}


void dibujarVictoriaNivel1() {
  if (puntuacionSesionNivel1>perfilActual.scoreNivel1) {
    perfilActual.scoreNivel1=puntuacionSesionNivel1;
    ordenarPerfiles(); guardarPerfiles();
  }
  fill(0,0,0,200); rect(0,0,width,height); dibujarEfectoFondo();
  float pW=600,pH=420,pX=width/2-pW/2,pY=height/2-pH/2;
  stroke(colorPrimario); strokeWeight(3); fill(10,20,40); rect(pX,pY,pW,pH,20);
  fill(colorPrimario); textAlign(CENTER); textSize(36);
  text("NIVEL 1 COMPLETADO",width/2,pY+60);
  stroke(colorPrimario); line(pX+50,pY+82,pX+pW-50,pY+82);
  fill(colorTexto); textSize(19);
  text("Defendiste el patio escolar!",width/2,pY+128);
  text("PUNTUACION OBTENIDA",width/2,pY+162);
  textSize(55); fill(255,215,0); text(nfc(puntuacionSesionNivel1),width/2,pY+232);
  fill(colorSecundario); textSize(17);
  if (frameCount%60<40) text("ENTER -> NIVEL 2: CIBERACOSO",width/2,pY+330);
}

void dibujarVictoriaNivel2() {
  if (puntuacionSesionNivel2>perfilActual.scoreNivel2) {
    perfilActual.scoreNivel2=puntuacionSesionNivel2;
    ordenarPerfiles(); guardarPerfiles();
  }
  fill(0,0,0,200); rect(0,0,width,height); dibujarEfectoFondo();
  float pW=600,pH=420,pX=width/2-pW/2,pY=height/2-pH/2;
  stroke(colorSecundario); strokeWeight(3); fill(10,20,40); rect(pX,pY,pW,pH,20);
  fill(colorSecundario); textAlign(CENTER); textSize(36);
  text("NIVEL 2 COMPLETADO",width/2,pY+60);
  stroke(colorSecundario); line(pX+50,pY+82,pX+pW-50,pY+82);
  fill(colorTexto); textSize(19);
  text("Detuviste al ciberacosador!",width/2,pY+128);
  text("PUNTUACION OBTENIDA",width/2,pY+162);
  textSize(55); fill(255,215,0); text(nfc(puntuacionSesionNivel2),width/2,pY+232);
  fill(colorPrimario); textSize(17);
  if (frameCount%60<40) text("PRESIONA ENTER PARA CONTINUAR",width/2,pY+330);
}

void dibujarVictoriaFinal() {
  background(colorFondo); dibujarEfectoFondo();
  fill(colorPrimario); textAlign(CENTER); textSize(56);
  text("MISION CUMPLIDA!",width/2,150);
  fill(colorTexto); textSize(24);
  text("EL ACOSO FUE DETENIDO GRACIAS A TI",width/2,238);
  textSize(18);
  text("\"Actuar, no solo observar, cambia vidas.\"",width/2,285);
  text("PUNTAJE TOTAL:",width/2,345);
  textSize(46); fill(255,215,0);
  text(nfc(perfilActual.obtenerPuntajeTotal()),width/2,400);
  fill(colorSecundario); textSize(19);
  if (frameCount%60<40) text("PRESIONA ENTER PARA VOLVER AL MENU",width/2,498);
}

void dibujarGameOver() {
  fill(50,0,0,200); rect(0,0,width,height);
  loadPixels();
  for (int i=0;i<pixels.length;i+=12)
    if (random(1)<0.08) pixels[i]=color(random(255));
  updatePixels();
  fill(colorPeligro); textAlign(CENTER); textSize(74);
  text("SILENCIO ROTO",width/2,175);
  textSize(26); text("EL ACOSO VENCIO ESTA VEZ",width/2,223);
  fill(colorTexto); textSize(20);
  if (murioPorPhishing) {
    if (frameCount%3==0&&indiceEscritura<mensajeFinal.length()) {
      textoEscribiendose+=mensajeFinal.charAt(indiceEscritura); indiceEscritura++;
    }
    text(textoEscribiendose,width/2,295);
  } else {
    text("No te rendiste, pero el acoso te supero esta vez.",width/2,295);
    textSize(17); fill(colorSecundario);
    text("Pedir ayuda es un acto de valentia.",width/2,328);
  }
  fill(colorSecundario); textSize(21);
  if (frameCount%60<40) text("> PRESIONA ENTER PARA INTENTARLO DE NUEVO <",width/2,450);
}

void dibujarCreditos() {
  background(colorFondo); dibujarEfectoFondo();
  fill(colorPrimario); textAlign(CENTER); textSize(40);
  text("CREDITOS",width/2,120);
  fill(colorTexto); textSize(19);
  text("Juego desarrollado como proyecto final\n"+
       "Estructura de Datos - POO  -  2026\n"+
       "Universidad del Norte\n\n"+
       "Tema: Bullying y Ciberacoso\n"+
       "Motor: Processing\n"+
       "Titulo: NO MORE BULLYING" ,width/2,248);
  fill(colorSecundario); textSize(17);
  text("\"Un mensaje puede herir o ayudar. Tu decides.\"",width/2,458);
  text("Presiona ENTER para volver",width/2,498);
}

void dibujarBoton(int x, int y, int w, int h, String texto, color c) {
  boolean hov=mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+h;
  pushStyle();
  if (hov) {
    fill(c,100); stroke(c); strokeWeight(3);
    for (int i=0;i<5;i++) { noFill(); stroke(c,50-i*10); rect(x-i,y-i,w+i*2,h+i*2,10); }
  } else { fill(10,10,30,200); stroke(c,150); strokeWeight(2); }
  rect(x,y,w,h,10);
  stroke(c); strokeWeight(2);
  line(x+5,y+5,x+15,y+5); line(x+5,y+5,x+5,y+15);
  line(x+w-5,y+h-5,x+w-15,y+h-5); line(x+w-5,y+h-5,x+w-5,y+h-15);
  fill(255); textAlign(CENTER,CENTER); textSize(18);
  text(texto,x+w/2,y+h/2-3);
  popStyle();
}

void dibujarEfectoFondo() {
  pushStyle();
  for (int i=0;i<45;i++) {
    fill(colorPrimario,random(15,65));
    textSize(int(random(10,20)));
    textAlign(CENTER,CENTER);
    // Simbolos de corazon y apoyo mezclados con codigo
    int r=int(random(6));
    String[] simbolos = {"<3","o/","!","?","0","1"};
    text(simbolos[r],random(width),random(height));
  }
  if (random(1)<0.04) { stroke(colorSecundario,22); line(0,random(height),width,random(height)); }
  popStyle();
}

class PerfilJugador {
  String nombre;
  int scoreNivel1, scoreNivel2;
  PerfilJugador(String n) { nombre=n; scoreNivel1=0; scoreNivel2=0; }
  int obtenerPuntajeTotal() { return scoreNivel1+scoreNivel2; }
}

void ordenarPerfiles() {
  Collections.sort(perfiles,new Comparator<PerfilJugador>() {
    public int compare(PerfilJugador a,PerfilJugador b) {
      return b.obtenerPuntajeTotal()-a.obtenerPuntajeTotal();
    }
  });
}

class Boss {
  float x,y; int vida,vidaMax,tipo;
  int cooldownAtaque=0,cooldownPhishing=600,contadorAtaques=0;
  float oscilacionY=0;

  Boss(int tipo,int vida) {
    this.tipo=tipo; this.vida=vida; this.vidaMax=vida;
    this.x=width-250; this.y=300;
  }

  void actualizar() {
    oscilacionY+=0.05; y=300+sin(oscilacionY)*70;
    if (!fasePhishing) {
      cooldownAtaque--;
      if (cooldownAtaque<=0) { atacar(); cooldownAtaque=int(random(60,100)); }
      cooldownPhishing--;
      if (cooldownPhishing<=0) { iniciarPhishing(); cooldownPhishing=750; }
    }
  }

  void dibujar() {
    pushStyle(); imageMode(CENTER);
    if (tipo==1&&imgBoss1!=null) image(imgBoss1,x,y);
    else if (tipo==2&&imgBoss2!=null) image(imgBoss2,x,y);
    else { rectMode(CENTER); fill(tipo==1?color(220,50,80):color(100,0,200)); rect(x,y,100,100); }
    popStyle();
    float por=map(vida,0,vidaMax,0,200);
    fill(50); rect(x-100,y-140,200,15);
    fill(colorPeligro); rect(x-100,y-140,por,15);
    fill(255); textSize(12); textAlign(CENTER);
    text("ACOSADOR: "+vida+"/"+vidaMax,x,y-145);
  }

  void atacar() {
    contadorAtaques++;
    boolean hom=(contadorAtaques%4==0);
    float ang=atan2(movey-y,movex-x),vel=12;
    int cant=int(random(1,3));
    if (cant==1) { proyectilesJefe.add(new Proyectil(x,y+50,cos(ang)*vel,sin(ang)*vel,false,hom)); }
    else {
      float dis=0.15;
      for (int i=0;i<cant;i++) {
        float af=ang+(i-cant/2.0)*dis;
        proyectilesJefe.add(new Proyectil(x,y+50,cos(af)*vel,sin(af)*vel,false,hom));
      }
    }
  }

  void iniciarPhishing() {
    fasePhishing=true; tiempoDesafio=240;
    proyectilesJefe.clear(); generarDesafioPhishing();
  }
}

class Proyectil {
  float x,y,vx,vy,speed;
  boolean esDelJugador,esTeledirigido;
  int tiempoHoming=45;

  Proyectil(float x,float y,float vx,float vy,boolean edj,boolean etd) {
    this.x=x;this.y=y;this.vx=vx;this.vy=vy;
    speed=dist(0,0,vx,vy);esDelJugador=edj;esTeledirigido=etd;
  }

  void actualizar() {
    if (esTeledirigido&&tiempoHoming>0&&!esDelJugador) {
      float ang=atan2((movey+30)-y,(movex+25)-x);
      vx=cos(ang)*speed; vy=sin(ang)*speed; tiempoHoming--;
    }
    x+=vx; y+=vy;
  }

  void dibujar() {
    pushStyle(); imageMode(CENTER);
    if (esDelJugador) {
      if (imgDisparoPlayer!=null) image(imgDisparoPlayer,x,y);
      else { fill(0,255,255); circle(x,y,10); }
    } else {
      if (imgDisparoBoss!=null) {
        pushMatrix(); translate(x,y); rotate(atan2(vy,vx)+PI);
        if (esTeledirigido) tint(255,100,100);
        image(imgDisparoBoss,0,0); popMatrix();
      } else { fill(esTeledirigido?color(255,0,0):color(255,100,0)); circle(x,y,15); }
    }
    popStyle();
  }

  boolean colisiona(float ox,float oy,float w,float h) {
    return x>ox&&x<ox+w&&y>oy&&y<oy+h;
  }
}

class PhishingChallenge {
  PImage imagen; boolean esPhishing,esCritico;
  PhishingChallenge(PImage img,boolean p,boolean c) { imagen=img;esPhishing=p;esCritico=c; }
}

void dispararJugador() {
  if (municion>0) {
    proyectilesJugador.add(new Proyectil(movex+50,movey+40,25,0,true,false));
    municion--; tiempoRecarga=10;
  }
}

void generarDesafioPhishing() {
  int r=int(random(5));
  if      (r==0) desafioActual=new PhishingChallenge(imgMensaje1,    true, true);
  else if (r==1) desafioActual=new PhishingChallenge(imgMensaje2,    true, false);
  else if (r==2) desafioActual=new PhishingChallenge(imgMensaje2True,false,false);
  else if (r==3) desafioActual=new PhishingChallenge(imgMensaje3,    true, false);
  else           desafioActual=new PhishingChallenge(imgMensaje3True,false,false);
}

void resolverPhishing(boolean jugadorDiceDanino) {
  boolean acerto=(jugadorDiceDanino==desafioActual.esPhishing);
  if (acerto) {
    jefeActual.vida-=50;
    crearExplosion(jefeActual.x,jefeActual.y,colorPrimario);
  } else {
    reproducirSonidoDanio();
    if (desafioActual.esCritico) {
      vidas-=2;
      if (vidas<=0) { mensajeFinal="Caidste en la trampa!\nNunca compartas datos con desconocidos."; murioPorPhishing=true; }
    } else {
      vidas--;
      if (vidas<=0) { mensajeFinal="El mensaje de acoso te vencio.\nReportar es la mejor defensa."; murioPorPhishing=true; }
    }
  }
  fasePhishing=false; desafioActual=null;
}

void dibujarInterfazPhishing() {
  pushStyle();
  fill(0,0,0,220); rect(0,0,width,height);
  stroke(colorPrimario); strokeWeight(3); fill(10,10,30);
  rect(width/2-300,height/2-250,600,500,10);
  fill(colorPeligro); noStroke();
  rect(width/2-300,height/2-250,600,40,10,10,0,0);
  fill(255); textAlign(LEFT); textSize(17);
  text("MENSAJE ENTRANTE - ES CIBERACOSO?",width/2-278,height/2-225);

  if (desafioActual!=null&&desafioActual.imagen!=null) {
    imageMode(CENTER);
    float ratio=(float)desafioActual.imagen.width/(float)desafioActual.imagen.height;
    float dW=580,dH=dW/ratio;
    if (dH>350) { dH=350; dW=dH*ratio; }
    image(desafioActual.imagen,width/2,height/2-20,dW,dH);
  }

  textAlign(CENTER); textSize(21);
  fill(colorPeligro); text("[F] REPORTAR / RECHAZAR",width/2-150,height/2+200);
  fill(colorPrimario); text("[V] ES UN MENSAJE NORMAL",width/2+150,height/2+200);

  fill(255,215,0);
  rect(width/2-300,height/2+230,map(tiempoDesafio,0,150,0,600),10);
  tiempoDesafio--;
  if (tiempoDesafio<=0) {
    vidas--;
    if (vidas<=0) { mensajeFinal="El tiempo se acabo. El acoso continuo."; murioPorPhishing=true; }
    fasePhishing=false;
  }
  popStyle();
}

void activarModoGlitch() {
  if (!modoGlitch&&!modoJefe) {
    modoGlitch=true; tiempoGlitch=120; tipoGlitch=int(random(3)); intensidadGlitch=10;
    fill(255); rect(0,0,width,height); reproducirSonidoDanio();
  }
}

void gestionarGlitch() {
  if (modoGlitch) {
    tiempoGlitch--;
    if (frameCount%4==0) {
      copy(0,0,width,height,int(random(-5,5)),int(random(-2,2)),width,height);
      stroke(colorPeligro,150); float y=random(height); line(0,y,width,y);
    }
    if (frameCount%30<15) {
      fill(colorPeligro); textAlign(CENTER); textSize(20);
      text("ACOSO DETECTADO",width/2,100);
      String d=(tipoGlitch==1)?"CONFUSION EMOCIONAL":(tipoGlitch==2)?"BLOQUEO MENTAL":"INTERFERENCIA";
      textSize(14); text(d,width/2,126);
    }
    if (tiempoGlitch<=0) modoGlitch=false;
  }
}
