# NO MORE BULLYING - Juego Educativo Anti-Bullying y Ciberacoso

Proyecto Final  ED-POO - 2026
Universidad del Norte

## Descripcion

No More Bullying es un videojuego educativo desarrollado en Processing que crea conciencia sobre
el bullying y el ciberacoso. El jugador aprende a reconocer situaciones de acoso, actuar con
empatia y rechazar mensajes daninos mientras navega por dos niveles progresivos.

## Objetivos Educativos

1. Reconocer el Bullying: identificar situaciones de acoso escolar.
2. Empatia y Accion: actuar, no solo observar.
3. Ciberacoso: entender los riesgos del acoso en linea.
4. Reporte y Apoyo: pedir ayuda es un acto de valentia.

## Estructuras de Datos Implementadas

- ArrayList (Lista Enlazada): gestion de obstaculos, items, particulas, proyectiles y quiz gates
- Archivo de Texto (.txt): persistencia de perfiles de jugadores en disco
- TAD ConceptoEmpatia: encapsula mensajes educativos y preguntas de decision moral
- TAD PerfilJugador: gestiona nombre y puntajes del jugador
- Lista de QuizGates: puertas de decision moral generadas aleatoriamente

## Niveles

### Nivel 1 - Bullying Escolar
- Objetivo: sobrevivir 60 segundos esquivando mensajes de acoso
- Mecanica: runner con saltos y recoleccion de corazones de empatia
- Quiz Gates: puertas de decision moral
- Jefe: acosador digital + fase de deteccion de mensajes daninos

### Nivel 2 - Ciberacoso
- Objetivo: sobrevivir 70 segundos en el mundo digital
- Mecanica: velocidad y patrones mas exigentes
- Jefe: ciberacosador con ataques teledirigidos

## Controles

- Flecha ARRIBA: saltar (doble salto disponible)
- Flecha IZQUIERDA / DERECHA: moverse
- ESPACIO: disparar (solo en fase de jefe)
- F: reportar/rechazar mensaje danino
- V: marcar mensaje como legitimo
- ENTER: confirmar / avanzar pantalla
- ESC: volver al menu principal

## Como Ejecutar

1. Instalar Processing 3.5+ desde processing.org
2. Instalar la libreria Sound desde el Gestor de Librerias
3. Abrir la carpeta BullyingRunner/ en Processing
4. Presionar Run

## Estructura del Proyecto

BullyingRunner/
  BullyingRunner.pde  - Archivo principal: menus, clases, TADs
  Nivel1.pde          - Nivel 1: Bullying escolar + Jefe
  nivel2.pde          - Nivel 2: Ciberacoso + Jefe final
  perfiles.txt        - Persistencia de jugadores (archivo)
  data/               - Imagenes, sprites y audio

## Sistema de Puntuacion

- Corazon recolectado: +100 pts
- Vida restante al final: +500 pts c/u
- Distancia recorrida: +1 pt/px
- Mision completada: +500 pts
- Golpe al jefe: +50 pts
- Combo: +50 pts x combo
