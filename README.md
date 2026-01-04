# Godot Space Emulation Project

Un proyecto de entorno espacial de alta fidelidad para Godot 4.3+, diseñado para simular la vista del espacio sideral desde el interior de una nave espacial con efectos avanzados de profundidad y paralaje.

## 🚀 Características Principales

### 🌌 Shader de Espacio Procedural (`space_background.gdshader`)

Un shader de cielo avanzado que genera un universo infinito de forma matemática:

- **Nebulosas Dinámicas**: Utiliza técnicas de _Domain Warping_ para crear nubes de gas realistas y filamentosas.
- **Estrellas Multi-capa**: Tres capas de estrellas (fondo, medio y primer plano) con diferentes tamaños y comportamientos.
- **Estrellas Cromáticas**: Variación de color basada en temperatura estelar (azules y naranjas).
- **Efecto de Parpadeo (Twinkle)**: Animación sutil y ajustable para las estrellas más cercanas.
- **Glow & Halos**: Resplandor dinámico integrado para una apariencia cinematográfica.

### 🎛️ Sky Controller (`sky_controller.gd`)

Un nodo de utilidad que permite ajustar todos los parámetros del espacio directamente desde el Inspector de Godot, sin tener que navegar por los materiales.

- **Uso**: Selecciona el nodo `SkyController` en la escena para ver los controles.
- **Modo Editor**: Los cambios se ven reflejados en tiempo real mientras diseñas.

### 🚶 Player Controller (`player_controller.gd`)

Un controlador FPS básico para caminar dentro de la nave:

- **Movimiento**: WASD para caminar, Ratón para mirar.
- **Parallax Real**: El script comunica la posición de la cámara al shader, permitiendo que las estrellas se muevan ligeramente según tu posición, creando una sensación de profundidad astronómica.
- **Colisiones**: Sistema preparado para interactuar con la estructura de la nave.

## 🛠️ Estructura del Proyecto

- `main.tscn`: Escena principal que contiene la nave, el entorno y el jugador.
- `space_background.gdshader`: Código del shader del universo.
- `sky_controller.gd`: Script de herramientas para el editor.
- `player_controller.gd`: Lógica de movimiento del jugador.
- `project.godot`: Configuración del proyecto Godot.

## 🎮 Controles

- **WASD**: Movimiento por la cabina.
- **Mouse**: Rotación de la cámara.
- **ESC**: Liberar/Capturar el ratón.

## 📦 Instalación

1. Clona o descarga este repositorio.
2. Abre Godot 4.3 o superior.
3. Importa el proyecto seleccionando el archivo `project.godot`.
4. Abre la escena `main.tscn` y presiona **F5** para ejecutar.

---

_Desarrollado para emular la inmersión de estar en el abismo del espacio._
