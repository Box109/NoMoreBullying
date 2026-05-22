ArrayList<Obstaculo2> obstaculos2 = new ArrayList<Obstaculo2>();
ArrayList<ItemRecolectable2> items2 = new ArrayList<ItemRecolectable2>();
ArrayList<Particula2> particulas2 = new ArrayList<Particula2>();

class Obstaculo2 {
  float x, y;
  int tipo; 
  PImage img;

  Obstaculo2(float x, int tipo) {
    this.x = x;
    this.tipo = tipo;
    this.img = obstaculo; 

    if (tipo == 1) {
      this.y = 330;  
    } else {
      this.y = 435;
    }
  }

  void actualizar(float vel) {
    x -= vel;
  }

  void dibujar() {
    pushMatrix();
    translate(x + 35, y + 35); 
    float pulsacion = 1.0 + 0.08 * sin(frameCount * 0.2);
    scale(pulsacion);
    rotate(radians(frameCount * -2.0)); 
    
    tint(255, 140 + 115 * abs(sin(frameCount * 0.1)));
    image(img, -35, -35);
    noTint();
    popMatrix();
  }

  boolean colisiona(float px, float py) {
    return px + 45 > x && px < x + 55 && py + 65 > y && py < y + 50;
  }
}

class ItemRecolectable2 {
  float x, y;
  int tipo; 
  PImage img;

  ItemRecolectable2(float x, int tipo) {
    this.x = x;
    this.tipo = tipo;
    this.img = item; 

    if (random(1) > 0.5) this.y = 350;
    else this.y = 440;
  }

  void actualizar(float vel) {
    x -= vel;
  }

  void dibujar() {
    float floatY = sin(frameCount * 0.18 + x * 0.015) * 6;

    if (tipo == 1) {
      tint(255, 200, 0);
      fill(255, 200, 0, 80);
      circle(x + 25, y + floatY + 25, 70);
    }
    else if (tipo == 2) {
      tint(0, 180, 255);
      fill(0, 180, 255, 80);
      circle(x + 25, y + floatY + 25, 80);
    }
    else {
      tint(100, 255, 150);
    }

    image(img, x, y + floatY);
    noTint();
  }

  boolean recolectar(float px, float py) {
    return px + 40 > x && px < x + 55 && py + 50 > y && py < y + 60;
  }
}

class Particula2 {
  float x, y, vx, vy;
  color col;
  int vida;

  Particula2(float x, float y, color col) {
    this.x = x;
    this.y = y;
    this.col = col;

    vx = random(-3, 3);
    vy = random(-4, -1);
    vida = 28;
  }

  void actualizar() {
    x += vx;
    y += vy;
    vy += 0.25;
    vida--;
  }

  void dibujar() {
    fill(col, map(vida, 0, 28, 0, 255));
    noStroke();
    circle(x, y, map(vida, 0, 28, 2, 7));
  }

  boolean muerta() {
    return vida <= 0;
  }
}

void nivel2Setup() {
  frameRate(30); 

  fondo1 = loadImage("fondo.jpeg");
  if (fondo1 != null) fondo1.resize(width, height);
  
  fondo2 = loadImage("fondo.jpeg");
  if (fondo2 != null) fondo2.resize(width, height);
  
  fondoX1 = 0;
  fondoX2 = fondo1.width;

  for (int i = 0; i < correr.length; i++)
    correr[i] = loadImage("player" + i + ".png");

  obstaculos2.clear();
  items2.clear();
  particulas2.clear();
  
  gates.clear();

  vidas = 3;
  recolectados = 0;
  distanciaRecorrida = 0;
  tiempo = 0;
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

  for(ConceptoConvivencia c : baseConocimiento) {
    c.desbloqueado = false;
  }
  if(baseConocimiento.size() > 0) baseConocimiento.get(0).desbloqueado = true;

  combo = 0;
  comboTimer = 0;

  velocidad = 6;    
  velocidadMaxima = 11; 

  escudoActivo = false;
  tiempoEscudo = 0;

  mision1 = false; 
  mision2 = false;
  mision3 = false;
  misionesCompletadas = 0;

  tiempoSinDanio = 0;
  puntosDanioJefe = 0; 

  puntuacionSesionNivel2 = 0;

  modoJefe = false;
  proyectilesJugador.clear();
  proyectilesJefe.clear();
  municion = 5;
  fasePhishing = false;

  for (int i = 0; i < 3; i++) agregarObstaculo2();
  for (int i = 0; i < 2; i++) agregarItem2();
}

void nivel2Draw() {
  background(colorFondo);
  
  gestionarGlitch();

  puntuacionSesionNivel2 = calcularPuntuacion2();

  if (juegoTerminado == 1) { estadoJuego = 6; return; }

  if (tiempo >= 60 * 30 && !modoJefe) { 
    modoJefe = true;
    jefeActual = new Boss(2, 500); 
    obstaculos2.clear();
    items2.clear();
    escudoActivo = false;
    tiempoEscudo = 0;
  }
  
  if (modoJefe) {
    dibujarEscenarioJefe2();
    return;
  }
  image(fondo1, fondoX1, 0);
  image(fondo2, fondoX2, 0);

  float factorVelocidad = (modoGlitch && tipoGlitch == 2) ? 0.5 : 1.0; 
  float velocidadReal = velocidad * factorVelocidad;

  fondoX1 -= velocidadReal;
  fondoX2 -= velocidadReal;

  if (fondoX1 <= -fondo1.width) fondoX1 = fondoX2 + fondo1.width;
  if (fondoX2 <= -fondo2.width) fondoX2 = fondoX1 + fondo2.width;

  distanciaRecorrida += velocidadReal;

  if (frameCount % 80 == 0) velocidad = min(velocidad + 0.5, velocidadMaxima); 

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
      crearExplosion2(movex + 25, movey + 60, color(255, 255, 255, 100));
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
    stroke(0, 200, 255);
    noFill();
    strokeWeight(3);
    circle(movex + 25, movey + 30, 75 + sin(frameCount * 0.3) * 10);
    strokeWeight(1);
  }

  // Rotación leve al saltar
  if (salto == 1) {
    pushMatrix();
    translate(movex + 25, movey + 30);
    rotate(radians(velY * 2));
    image(velY < 0 ? correr[6] : correr[7], -25, -30);
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

  for (int i = obstaculos2.size() - 1; i >= 0; i--) {
    Obstaculo2 o = obstaculos2.get(i);
    o.actualizar(velocidadReal);
    o.dibujar();

    if (o.x < -100) {
      obstaculos2.remove(i);
      continue;
    }

    if (!escudoActivo && o.colisiona(movex, movey)) {
      vidas--;
      reproducirSonidoDanio();
      crearExplosion2(movex + 25, movey + 30, colorPeligro);

      if (random(1) < 0.4) {
        activarModoGlitch();
      }
      
      obstaculos2.remove(i);
      combo = 0;
      comboTimer = 0;
      tiempoSinDanio = 0;

      if (vidas <= 0) juegoTerminado = 1;
    }
  }

  if (obstaculos2.size() > 0) {
    Obstaculo2 ult = obstaculos2.get(obstaculos2.size() - 1);
    if (width - ult.x > 150) agregarObstaculo2();
  } else agregarObstaculo2();

  for (int i = items2.size() - 1; i >= 0; i--) {
    ItemRecolectable2 it = items2.get(i);
    it.actualizar(velocidadReal);
    it.dibujar();

    if (it.x < -100) {
      items2.remove(i);
      continue;
    }

    if (it.recolectar(movex, movey)) {
      items2.remove(i);

      combo++;
      comboTimer = 60; 

      if (it.tipo == 1) {
        recolectados += 2;
        crearExplosion2(movex + 25, movey + 30, color(255, 220, 0));
      }
      else if (it.tipo == 2) {
        escudoActivo = true;
        tiempoEscudo = 180; 
        crearExplosion2(movex + 25, movey + 30, color(0, 200, 255));
        recolectados++;
      }
      else {
        recolectados++;
        crearExplosion2(movex + 25, movey + 30, colorPrimario);
      }

      for(ConceptoConvivencia c : baseConocimiento) {
        if(!c.desbloqueado) {
          c.desbloqueado = true;
          mensajeActual = baseConocimiento.indexOf(c); 
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

  if (items2.size() > 0) {
    ItemRecolectable2 ult = items2.get(items2.size() - 1);
    if (width - ult.x > 250) agregarItem2();
  } else agregarItem2();

  if (comboTimer > 0) comboTimer--;
  else if (combo > 0) combo = 0;

  actualizarMisiones2();

  for (int i = particulas2.size() - 1; i >= 0; i--) {
    Particula2 p = particulas2.get(i);
    p.actualizar();
    p.dibujar();
    if (p.muerta()) particulas2.remove(i);
  }

  dibujarHUD2();

  if (tiempoMensaje > 0) { dibujarMensajeEducativo(); tiempoMensaje--; }

  dibujarBarraProgreso2();
}

void dibujarEscenarioJefe2() {
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
    estadoJuego = 8; 
  }
}

void agregarObstaculo2() {
  float r = random(1);
  float dist = random(220, 380); 
  float proposedX = width + dist;

  for (QuizGate g : gates) {
    if (abs(g.x - proposedX) < 500) return; 
  }

  if (r < 0.35) {
    int tipo = random(1) < 0.5 ? 0 : 1;
    obstaculos2.add(new Obstaculo2(width + dist, tipo));
    
  } else if (r < 0.65) {
    obstaculos2.add(new Obstaculo2(width + dist, 0));
    obstaculos2.add(new Obstaculo2(width + dist + 120, 1)); 
    
  } else if (r < 0.85) {
    obstaculos2.add(new Obstaculo2(width + dist, 0));
    obstaculos2.add(new Obstaculo2(width + dist + 160, 0));
    obstaculos2.add(new Obstaculo2(width + dist + 320, 1));
    
  } else {
    obstaculos2.add(new Obstaculo2(width + dist, 1));
    obstaculos2.add(new Obstaculo2(width + dist + 200, 1));
    obstaculos2.add(new Obstaculo2(width + dist + 400, 0));
  }
}

void agregarItem2() {
  int r = int(random(0, 100));
  int tipo = 0;

  if (r < 60) tipo = 0;
  else if (r < 85) tipo = 1; 
  else tipo = 2;

  float dist = random(150, 260);
  float proposedX = width + dist;

  for (QuizGate g : gates) {
    if (abs(g.x - proposedX) < 500) return; 
  }

  boolean superpuesto = false;
  for (Obstaculo2 obs : obstaculos2) {
    if (abs(obs.x - proposedX) < 80) {
      superpuesto = true;
      break;
    }
  }

  if (!superpuesto) {
    items2.add(new ItemRecolectable2(proposedX, tipo));
  }
}

void crearExplosion2(float x, float y, color c) {
  for (int i = 0; i < 15; i++) {
    particulas2.add(new Particula2(x, y, c));
  }
}


void actualizarMisiones2() {

  if (!mision1 && recolectados >= 15) {
    mision1 = true;
    misionesCompletadas++;
    tiempoMensaje = 120; 
  }

  if (!mision2 && combo >= 7) {
    mision2 = true;
    misionesCompletadas++;
    tiempoMensaje = 120; 
  }

  tiempoSinDanio++;
  if (!mision3 && tiempoSinDanio >= 600) { 
    mision3 = true;
    misionesCompletadas++;
    tiempoMensaje = 120; 
  }
}

void dibujarHUD2() {
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
  text("💾 " + recolectados, x, 25);
 
  fill(colorSecundario);
  textAlign(CENTER, CENTER);
  int segundos = tiempo / 30;
  int objetivo = 60; // 60 segundos
  text("⏱ " + segundos + "s / " + objetivo + "s", width/2, 25);

  fill(colorPrimario);
  textAlign(RIGHT, CENTER);
  text("SCORE: " + puntuacionSesionNivel2, width - 20, 25);
 
  if (combo > 1) {
    fill(255, 215, 0);
    textSize(16);
    text("COMBO x" + combo, width - 20, 65);
  }

  if (escudoActivo) {
    fill(0, 200, 255);
    textAlign(LEFT);
    textSize(14);
    int segsEscudo = tiempoEscudo / 30;
    text("FIREWALL: " + segsEscudo + "s", 20, 65);
  }

  // Misiones
  dibujarPanelMisiones2();
}

void dibujarPanelMisiones2() {
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
  text("MISIONES NIVEL 2", x + 10, y + 20);

  fill(mision1 ? colorPrimario : 150);
  textSize(12);
  text((mision1 ? "✓ " : "○ ") + "15 Chips (" + recolectados + "/15)", x + 10, y + 40);

  fill(mision2 ? colorPrimario : 150);
  text((mision2 ? "✓ " : "○ ") + "Combo x7 (" + combo + ")", x + 10, y + 60);

  fill(mision3 ? colorPrimario : 150);
  int s = tiempoSinDanio/30; 
  text((mision3 ? "✓ " : "○ ") + "20s Intacto (" + s + "/20)", x + 10, y + 80);
}

void dibujarBarraProgreso2() {
  
  float progreso = float(tiempo) / float(60*30);

  noStroke();
  fill(50);
  rect(0, 46, width, 4); 

  fill(lerpColor(colorPeligro, colorPrimario, progreso));
  rect(0, 46, width * progreso, 4); 
}



int calcularPuntuacion2() {
  int pts = 0;

  pts += recolectados * 120;
  pts += vidas * 500;
  pts += distanciaRecorrida;
  pts += velocidad * 90;
  pts += combo * 60;
  pts += misionesCompletadas * 500;
  pts += puntosDanioJefe; 

  return pts;
}
