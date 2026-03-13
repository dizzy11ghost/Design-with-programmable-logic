*Sophia Leñero Gómez A01639462*

# Práctica 7 - Generación de patrón de ajedrez en VGA

## Descripción
Para esta práctica, se tenía que implementar un sistema HDL utilizando verilog que fuera capaz de generar una señal de video compatible con VGA. El sistema tenía que producir las señales de horizontal y vertical sync para controlar un monitor VGA y generar un patrón en la pantalla, en este caso, cuadros negros y blancos, representando un patrón de tablero de ajedrez. 

## Funcionamiento 
El sistema se compone de dos módulos, VGADemo y hysync_generator. El hysync_generator es el que va a estar generando señales de sync horizontal y vertical, asi como contadores de posición CounterX y CounterY para los pixeles. 
Dentro del módulo principal también se genera una señal llamada pixel_tick, la cual funciona como una señal de habilitación que se activa a una velocidad menor que el reloj principal.
El patrón visual se genera utilizando los valores de los contadores de posición. En particular, se aplica una operación XOR entre ciertos bits de CounterX y CounterY, lo que produce un patrón alternado de cuadros blancos y negros.

## Entradas y salidas 
La entrada del sistema es el reloj de 50MHz de la FPGA y las salidas son pixel (para color RGB), hysync_out (para sincronización horizontal) y vysync (sincronización vertical)

## Evidencias de la práctica


https://github.com/user-attachments/assets/58b5802c-34f0-41cb-b556-d645dafeead2



## Aprendizajes y conclusiones
Esta práctica fue de enorme utilidad para nosotros estudiantes de ingeniería en robótica y sistemas digitales ya que interactuar con un display siempre será una pieza vital para todo lo que hagamos, ya que representa esa interacción entre sistema y usuario, y verlo a un nivel tan bajo como lo es VGA por medio de verilog definitivamente nos expandió mucho el panoráma de cómo funciona y cómo usarlo en otros proyectos. 
