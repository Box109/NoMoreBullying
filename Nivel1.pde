
import java.util.ArrayList; 

ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>();
ArrayList<ItemRecolectable> items = new ArrayList<ItemRecolectable>();
ArrayList<Particula> particulas = new ArrayList<Particula>();

class Obstaculo {
  float x, y;
  int tipo; 
  PImage img;
  
  Obstaculo(float x, int tipo) {
    this.x = x;
    this.tipo = tipo;
    this.img = obstaculo; 
    
    if (tipo == 1) {
      this.y = 350; 
    } else {
      this.y = 433; 
    }
  }
  
  void actualizar(float vel) {
    x -= vel;
  }
  
  void dibujar() {
    pushMatrix();
    translate(x + 35, y + 35); 
    float pulsacion = 1.0 + 0.05 * sin(frameCount * 0.15);
    scale(pulsacion);
    rotate(radians(frameCount * 1.5));
    
    tint(255, 100 + 155 * abs(sin(frameCount * 0.1))); 
    image(img, -35, -35);
    noTint();
    popMatrix();
  }
  
  boolean colisiona(float px, float py) {
    return px + 45 > x && px + 10 < x + 55 && py + 65 > y && py + 10 < y + 55;
  }
}

void nivel1Setup() {
  frameRate(30);


  fondo1 = loadImage("fondo.jpeg");
  if (fondo1 != null) fondo1.resize(width, height); 
  
  fondo2 = loadImage("fondo.jpeg");
  if (fondo2 != null) fondo2.resize(width, height); 
  
  fondoX1 = 0;
  fondoX2 = fondo1.width;

  for (int i = 0; i < correr.length; i++) {
    correr[i] = loadImage("player" + i + ".png");
  }

  obstaculo = loadImage("virus.png");
  if (obstaculo != null) obstaculo.resize(70, 70);
  
  item = loadImage("item.png");
  if (item != null) item.resize(58, 58); 

  obstaculos.clear();
  items.clear();
  particulas.clear();
  gates.clear();
  
  
  for(ConceptoConvivencia c : baseConocimiento) {
    c.desbloqueado = false;
  }
  
  if(baseConocimiento.size() > 0) baseConocimiento.get(0).desbloqueado = true;

  vidas = 3;
  recolectados = 0;
  tiempo = 0;
  distanciaRecorrida = 0;
  movex = 200;
  movey = 410;
  velY = 0;
  velX = 0; 
  salto = 0;
  puedeSaltar = 1;
  saltosActuales = 0; 
  imageIndex = 0;
  juegoTerminado = 0;
  mensajeActual = 0;
  tiempoMensaje = 0;
  combo = 0;
  comboTimer = 0;
  velocidad = 6; 
  escudoActivo = false;
  tiempoEscudo = 0;
  ultimoTipoObstaculo = 0;
  misionesCompletadas = 0;
  mision1 = false;
  mision2 = false;
  mision3 = false;
  tiempoSinDanio = 0;
  puntuacionSesionNivel1 = 0; 
  puntosDanioJefe = 0; 
  
  modoJefe = false;
  proyectilesJugador.clear();
  proyectilesJefe.clear();
  municion = 5;
  fasePhishing = false;
  
  for (int i = 0; i < 3; i++) {
    agregarObstaculo();
  }
  for (int i = 0; i < 2; i++) {
    agregarItem();
  }
}

void nivel1Draw() {

  background(colorFondo);

  puntuacionSesionNivel1 = calcularPuntuacion();
  
  if (juegoTerminado == 1) {
    estadoJuego = 6; 
    return;
  }
  
  if (tiempo >= tiempoObjetivo && !modoJefe) {
    modoJefe = true;
    jefeActual = new Boss(1, 300); 
    obstaculos.clear(); 
    items.clear();
    
    escudoActivo = false;
    tiempoEscudo = 0;
  }
  
  if (modoJefe) {
    dibujarEscenarioJefe();
    return;
  }

  
  image(fondo1, fondoX1, 0);
  image(fondo2, fondoX2, 0);

  
  float factorVelocidad = (modoGlitch && tipoGlitch == 2) ? 0.5 : 1.0; 
  float velocidadReal = velocidad * factorVelocidad;
  
  fondoX1 -= velocidadReal;
  fondoX2 -= velocidadReal;
  distanciaRecorrida += velocidadReal;

  if (fondoX1 <= -fondo1.width) fondoX1 = fondoX2 + fondo1.width;
  if (fondoX2 <= -fondo2.width) fondoX2 = fondoX1 + fondo2.width;
  
  if (frameCount % 90 == 0) { 
    velocidad = min(velocidad + 0.5, velocidadMaxima); 
  }

  
  float dirControl = (modoGlitch && tipoGlitch == 1) ? -1.0 : 1.0; 
  
  if (teclaDerecha == 1) velX += aceleracion * dirControl;
  if (teclaIzquierda == 1) velX -= aceleracion * dirControl;
  
  velX *= friccion; 
  movex += velX;

  movex = constrain(movex, 50, width - 100);
 
  if (salto == 0 && frameCount % 5 == 0) imageIndex = (imageIndex + 1) % 6;
  tiempo++;

  if (teclaArriba == 1 && puedeSaltar == 1) {
    if (saltosActuales < saltosDisponibles) {
      velY = velocidadSalto;
      salto = 1;
      saltosActuales++;
      puedeSaltar = 0;
      crearExplosion(movex + 25, movey + 60, color(255, 255, 255, 100));
    }
  }
  if (teclaArriba == 0) puedeSaltar = 1;

  if (salto == 1) {
    movey += velY;
    velY += gravedad;

    boolean enPlataforma = false;
    for (QuizGate g : gates) {
      if (movex > g.x - 250 && movex < g.x + 250) {
        
        if (velY > 0 && movey >= 250 && movey <= 270) {
           movey = 250;
           salto = 0;
           velY = 0;
           saltosActuales = 0;
           enPlataforma = true;
           break;
        }
      }
    }

    if (!enPlataforma && movey >= 410) {
      movey = 410;
      salto = 0;
      velY = 0;
      saltosActuales = 0; 
    }
  } else {
    if (movey < 410) {
       boolean enPlataforma = false;
       for (QuizGate g : gates) {
         if (movex > g.x - 250 && movex < g.x + 250 && abs(movey - 250) < 5) {
           enPlataforma = true;
           break;
         }
       }
       if (!enPlataforma) {
         salto = 1; 
         velY = 0;
       }
    }
  }

  pushMatrix();
  if (escudoActivo) {
    noFill();
    stroke(colorPrimario, 150 + sin(frameCount * 0.2) * 100);
    strokeWeight(3);
    circle(movex + 25, movey + 30, 80 + sin(frameCount * 0.3) * 10);
    strokeWeight(1);
  }
  
  if (salto == 1) {
    pushMatrix();
    translate(movex + 25, movey + 30);
    rotate(radians(velY * 2));
    image(correr[velY < 0 ? 6 : 7], -25, -30);
    popMatrix();
  } else {
    pushMatrix();
    translate(movex + 25, movey + 30);
    rotate(radians(velX * 1.5));
    image(correr[imageIndex], -25, -30);
    popMatrix();
  }
  popMatrix();
  
  if (escudoActivo) {
    tiempoEscudo--;
    if (tiempoEscudo <= 0) escudoActivo = false;
  }

  for (int i = gates.size() - 1; i >= 0; i--) {
    QuizGate g = gates.get(i);
    g.actualizar(velocidadReal);
    g.dibujar();
    
    if (g.x < -100) {
      gates.remove(i);
      continue;
    }
    
    int resultado = g.verificarColision(movex, movey);
    if (resultado == 1) {
      recolectados += 5;
      crearExplosion(movex, movey, color(0, 255, 0));
      fill(0, 255, 0);
      textSize(20);
      text("¡CORRECTO!", movex, movey - 50);
    } else if (resultado == -1) {
      vidas--;
      reproducirSonidoDanio();
      crearExplosion(movex, movey, colorPeligro);
      fill(255, 0, 0);
      textSize(20);
      text("¡ERROR!", movex, movey - 50);
      
      if (vidas <= 0) juegoTerminado = 1;
    }
  }

  for (int i = obstaculos.size() - 1; i >= 0; i--) {
    Obstaculo obs = obstaculos.get(i);

    obs.actualizar(velocidadReal);
    
    obs.dibujar();
    
    if (obs.x < -100) {
      obstaculos.remove(i);
      continue;
    }
    
    if (!escudoActivo && obs.colisiona(movex, movey)) {
      vidas--;
      reproducirSonidoDanio();
      obstaculos.remove(i);
      crearExplosion(movex + 25, movey + 30, colorPeligro);
      combo = 0;
      comboTimer = 0;
      tiempoSinDanio = 0;
      
      if (random(1) < 0.4) {
        activarModoGlitch();
      }
      
      if (vidas <= 0) juegoTerminado = 1;
    }
  }

  float xUltimoObjeto = 0;
  if (obstaculos.size() > 0) xUltimoObjeto = obstaculos.get(obstaculos.size() - 1).x;
  if (gates.size() > 0) xUltimoObjeto = max(xUltimoObjeto, gates.get(gates.size() - 1).x);
  
  if (width - xUltimoObjeto > 300) {  
    agregarObstaculo();
  }

  for (int i = items.size() - 1; i >= 0; i--) {
    ItemRecolectable it = items.get(i);
    it.actualizar(velocidadReal);
    it.dibujar();
    
    if (it.x < -100) {
      items.remove(i);
      continue;
    }
    
    if (it.recolectar(movex, movey)) {
      items.remove(i);
      
      combo++;
      comboTimer = 60; 
      
      if (it.tipo == 1) {
        recolectados += 3;
        crearExplosion(movex + 25, movey + 30, color(255, 215, 0));
      } else if (it.tipo == 2) {
        escudoActivo = true;
        tiempoEscudo = 180; 
        crearExplosion(movex + 25, movey + 30, color(0, 255, 200));
        recolectados++;
      } else {
        recolectados++;
        crearExplosion(movex + 25, movey + 30, colorPrimario);
      }

      for(ConceptoConvivencia c : baseConocimiento) {
        if(!c.desbloqueado) {
          c.desbloqueado = true;
          mensajeActual = baseConocimiento.indexOf(c); // Mostrar este mensaje
          tiempoMensaje = 150; 
          break;
        }
      }

      if(tiempoMensaje == 0) {
         mensajeActual = int(random(baseConocimiento.size()));
         tiempoMensaje = 90;
      }
    }
  }
  
  if (items.size() > 0) {
    ItemRecolectable ultimoIt = items.get(items.size() - 1);
    if (width - ultimoIt.x > 200) {
      agregarItem();
    }
  } else {
    agregarItem();
  }
  
  if (comboTimer > 0) comboTimer--;
  else if (combo > 0) combo = 0;
  
  actualizarMisiones();

  for (int i = particulas.size() - 1; i >= 0; i--) {
    Particula p = particulas.get(i);
    p.actualizar();
    p.dibujar();
    if (p.estamuerta()) particulas.remove(i);
  }

  dibujarHUD();
  gestionarGlitch(); 
  if (tiempoMensaje > 0) {
    dibujarMensajeEducativo();
    tiempoMensaje--;
  }
  dibujarBarraProgreso();
}


void dibujarEscenarioJefe() {
  image(fondo1, fondoX1, 0);
  image(fondo2, fondoX2, 0);
  
  actualizarJugadorJefe();
  
  jefeActual.actualizar();
  jefeActual.dibujar();
  
  gestionarProyectiles();

  if (fasePhishing) {
    dibujarInterfazPhishing();
  }

  dibujarHUDJefe();
  
  if (jefeActual.vida <= 0) {
    modoJefe = false;
    estadoJuego = 3; 
  }
}

void actualizarJugadorJefe() {
  float accJefe = aceleracion * 1.5;
  
  if (teclaDerecha == 1) velX += accJefe;
  if (teclaIzquierda == 1) velX -= accJefe;
  velX *= friccion;
  movex += velX;
  movex = constrain(movex, 50, width - 400); 

  if (salto == 0 && frameCount % 5 == 0) imageIndex = (imageIndex + 1) % 6;
  
  if (teclaArriba == 1 && puedeSaltar == 1) {
    if (saltosActuales < saltosDisponibles) {
      velY = velocidadSalto;
      salto = 1;
      saltosActuales++;
      puedeSaltar = 0;
    }
  }
  if (teclaArriba == 0) puedeSaltar = 1;

  if (salto == 1) {
    movey += velY;
    velY += gravedad;
    if (movey >= 410) {
      movey = 410;
      salto = 0;
      velY = 0;
      saltosActuales = 0;
    }
  }

  pushMatrix();
  if (escudoActivo) {
    stroke(colorPrimario); noFill(); circle(movex + 25, movey + 30, 80);
  }
  image(correr[imageIndex], movex, movey);
  popMatrix();
}

void gestionarProyectiles() {
  if (municion < 5) {
    tiempoRecarga--;
    if (tiempoRecarga <= 0) {
      municion++;
      tiempoRecarga = 10;
    }
  }

  for (int i = proyectilesJugador.size() - 1; i >= 0; i--) {
    Proyectil p = proyectilesJugador.get(i);
    p.actualizar();
    p.dibujar();
  
    float hitboxSize = (jefeActual.tipo == 2) ? 240 : 200;
    float offset = hitboxSize / 2;
    
    if (p.colisiona(jefeActual.x - offset, jefeActual.y - offset, hitboxSize, hitboxSize)) {
      jefeActual.vida -= 10;
      puntosDanioJefe += 50; 
      crearExplosion(p.x, p.y, colorPrimario);
      proyectilesJugador.remove(i);
    } else if (p.x > width) {
      proyectilesJugador.remove(i);
    }
  }

  for (int i = proyectilesJefe.size() - 1; i >= 0; i--) {
    Proyectil p = proyectilesJefe.get(i);
    p.actualizar();
    p.dibujar();
   
    if (!escudoActivo && p.colisiona(movex, movey, 50, 70)) {
      vidas--;
      reproducirSonidoDanio();
      crearExplosion(movex, movey, colorPeligro);
      proyectilesJefe.remove(i);
      if (vidas <= 0) juegoTerminado = 1;
    } else if (p.x < 0) {
      proyectilesJefe.remove(i);
    }
  }
}

void dibujarHUDJefe() {
  dibujarHUD(); // Base

  fill(colorPanel);
  stroke(colorSecundario);
  rect(width/2 - 100, height - 60, 200, 40, 10);
  
  fill(colorTexto);
  textAlign(CENTER);
  text("MUNICIÓN: ", width/2 - 40, height - 35);
  
  for (int i = 0; i < 5; i++) {
    if (i < municion) fill(colorPrimario);
    else fill(50);
    rect(width/2 + 20 + i * 15, height - 45, 10, 20);
  }
  
  if (municion == 0) {
    fill(colorPeligro);
    textSize(12);
    text("RECARGANDO...", width/2, height - 10);
  }
}


void dibujarHUD() {
  fill(10, 15, 30, 240);
  noStroke();
  rect(0, 0, width, 50);
  
  stroke(colorPrimario);
  strokeWeight(2);
  line(0, 50, width, 50);
  
  float x = 20;
  fill(colorPeligro);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("❤", x, 25);
  x += 25;
  for (int i = 0; i < vidas; i++) {
    rect(x + i * 20, 18, 15, 15, 2);
  }
  
  x += 100;
  fill(colorPrimario);
  text("Apoyo: " + recolectados, x, 25);
  
  fill(colorSecundario);
  textAlign(CENTER, CENTER);
  int segundos = tiempo / 30;
  int objetivo = tiempoObjetivo / 30;
  text("⏱ " + segundos + "s / " + objetivo + "s", width/2, 25);

  fill(colorPrimario);
  textAlign(RIGHT, CENTER);
  text("SCORE: " + puntuacionSesionNivel1, width - 20, 25);

  if (combo > 1) {
    fill(255, 215, 0);
    textSize(16);
    text("COMBO x" + combo, width - 20, 65);
  }

  if (escudoActivo) {
    fill(0, 255, 255);
    textAlign(LEFT);
    textSize(14);
    int segsEscudo = tiempoEscudo / 30;
    text("ESCUDO: " + segsEscudo + "s (Proteccion)", 20, 65);
  }
 
  dibujarPanelMisiones();
}

void dibujarMensajeEducativo() {

  float w = 700;
  float h = 50;
  float x = width/2 - w/2;
  float y = height - 80;
  
  fill(0, 0, 0, 220);
  stroke(colorPrimario);
  strokeWeight(2);
  rect(x, y, w, h, 10);
  
  fill(colorPrimario);
  textAlign(CENTER, CENTER);
  textSize(16);
  
  if (mensajeActual >= 0 && mensajeActual < baseConocimiento.size()) {
     text("💡 " + baseConocimiento.get(mensajeActual).mensaje, width/2, y + h/2);
  }
}

void dibujarBarraProgreso() {
  float progreso = float(tiempo) / float(tiempoObjetivo);
  
  noStroke();
  fill(50);
  rect(0, 46, width, 4); 
  
  fill(lerpColor(colorPeligro, colorPrimario, progreso));
  rect(0, 46, width * progreso, 4); // Barra delgada
}

int calcularPuntuacion() {
  int puntos = 0;
  puntos += recolectados * 100;          
  puntos += vidas * 500;                 
  puntos += int(distanciaRecorrida);   
  puntos += int(velocidad * 100);      
  puntos += misionesCompletadas * 500; 
  puntos += puntosDanioJefe; // Sumar daño al jefe
  if (combo > 1) {
    puntos += combo * 50;              
  }
  return puntos;
}

void crearExplosion(float x, float y, color col) {
  for (int i = 0; i < 15; i++) {
    particulas.add(new Particula(x, y, col));
  }
}

void agregarObstaculo() {
  float r = random(1);
  float distanciaBase = random(250, 400); 
  float proposedX = width + distanciaBase;
 
  for (QuizGate g : gates) {
    if (abs(g.x - proposedX) < 500) return; 
  }

  boolean puedePonerGate = true;
  if (gates.size() > 0) {
     if (width - gates.get(gates.size()-1).x < 600) puedePonerGate = false;
  }

  if (obstaculos.size() == 0 && gates.size() == 0) {
     gates.add(new QuizGate(width + 400));
     return;
  }
  
  if (r < 0.5 && puedePonerGate) { 
     gates.add(new QuizGate(width + distanciaBase));
     return; 
  }
  
 
  if (r < 0.4) { 
    
    int tipo = random(1) < 0.6 ? 0 : 1;
    
    if (tipo == 1 && ultimoTipoObstaculo == 1) tipo = 0;
    
    obstaculos.add(new Obstaculo(width + distanciaBase, tipo));
    ultimoTipoObstaculo = tipo;
    
  } else if (r < 0.7) {
    obstaculos.add(new Obstaculo(width + distanciaBase, 0));
    obstaculos.add(new Obstaculo(width + distanciaBase + 220, 1));
    ultimoTipoObstaculo = 1;
    
  } else if (r < 0.9) {
     
    obstaculos.add(new Obstaculo(width + distanciaBase, 0));
    obstaculos.add(new Obstaculo(width + distanciaBase + 140, 0)); 
    ultimoTipoObstaculo = 0;
    
  } else {
    obstaculos.add(new Obstaculo(width + distanciaBase, 1));
    obstaculos.add(new Obstaculo(width + distanciaBase + 200, 1));
    ultimoTipoObstaculo = 1;
  }
}

void agregarItem() {
  int tipo = int(random(0, 100));
  int tipoItem = 0;
  
  if (tipo < 60) {
    tipoItem = 0;
  } else if (tipo < 85) {
    tipoItem = 1; 
  } else {
    tipoItem = 2; 
  }
  
  float distancia = random(150, 250);
  float proposedX = width + distancia;
  
  
  for (QuizGate g : gates) {
    if (abs(g.x - proposedX) < 500) return; 
  }
  
  
  boolean superpuesto = false;
  for (Obstaculo obs : obstaculos) {
    if (abs(obs.x - proposedX) < 80) { 
      superpuesto = true;
      break;
    }
  }
  
  if (!superpuesto) {
    items.add(new ItemRecolectable(proposedX, tipoItem));
  }
}

void actualizarMisiones() {
  if (!mision1 && recolectados >= 10) {
    mision1 = true;
    misionesCompletadas++;
    tiempoMensaje = 120; // Revertido para 30fps
    mensajeActual = 0; 
  }
  
  if (!mision2 && combo >= 5) {
    mision2 = true;
    misionesCompletadas++;
    tiempoMensaje = 120; // Revertido para 30fps
  }
  

  tiempoSinDanio++;
  if (!mision3 && tiempoSinDanio >= 450) { 
    mision3 = true;
    misionesCompletadas++;
    tiempoMensaje = 120; 
  }
}

void dibujarPanelMisiones() {

  float w = 250;
  float h = 100;
  float x = width - w - 10;
  float y = height - h - 10;
  
  fill(0, 0, 0, 150);
  stroke(colorSecundario, 100);
  rect(x, y, w, h, 5);
  
  fill(colorSecundario);
  textSize(12);
  textAlign(LEFT);
  text("MISIONES", x + 10, y + 20);
  
  fill(mision1 ? colorPrimario : 150);
  text((mision1 ? "✓ " : "○ ") + "10 Corazones (" + recolectados + "/10)", x + 10, y + 40);
 
  fill(mision2 ? colorPrimario : 150);
  text((mision2 ? "✓ " : "○ ") + "Combo x5 (" + combo + ")", x + 10, y + 60);
  
  fill(mision3 ? colorPrimario : 150);
  int segs = tiempoSinDanio / 30;
  text((mision3 ? "✓ " : "○ ") + "15s Intacto (" + segs + "/15)", x + 10, y + 80);
}



class ItemRecolectable {
  float x, y;
  int tipo; 
  PImage img;
  
  ItemRecolectable(float x, int tipo) {
    this.x = x;
    this.tipo = tipo;
    this.img = item; 
    
    if (random(1) > 0.6) {
      this.y = 360;
    } else {
      this.y = 440; 
    }
  }
  
  void actualizar(float vel) {
    x -= vel;
  }
  
  void dibujar() {
    float offsetY = sin(frameCount * 0.15 + x * 0.01) * 5;
    
    if (tipo == 1) {
      tint(255, 215, 0);
      fill(255, 215, 0, 80);
      noStroke();
      circle(x + 25, y + offsetY + 25, 65 + sin(frameCount * 0.3) * 10);
    } else if (tipo == 2) {
      tint(0, 255, 200);
      fill(0, 255, 200, 80);
      noStroke();
      circle(x + 25, y + offsetY + 25, 70 + sin(frameCount * 0.25) * 15);
    } else {
      tint(150, 255, 150);
    }
    
    image(img, x, y + offsetY);
    noTint();
  }
  
  boolean recolectar(float px, float py) {
    return px + 40 > x && px < x + 50 && py + 40 > y && py < y + 60;
  }
}

class Particula {
  float x, y, vx, vy;
  color col;
  int vida;
  
  Particula(float x, float y, color col) {
    this.x = x;
    this.y = y;
    this.col = col;
    this.vx = random(-3, 3);
    this.vy = random(-5, -1);
    this.vida = 30;
  }
  
  void actualizar() {
    x += vx;
    y += vy;
    vy += 0.3;
    vida--;
  }
  
  void dibujar() {
    fill(col, map(vida, 0, 30, 0, 255));
    noStroke();
    circle(x, y, map(vida, 0, 30, 2, 6));
  }
  
  boolean estamuerta() {
    return vida <= 0;
  }
}
