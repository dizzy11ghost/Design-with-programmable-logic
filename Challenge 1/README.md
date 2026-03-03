A01639462 Sophia Leñero Gómez
# Challenge 1 - Debouncer

## Objetivo
El objetivo de este reto era implementar por medio de Verilog un sistema de debouncer. Este sistema es muy útil y también importante de saber implementar porque un botón real no cambia de 0 a 1 de manera limpia, cuando lo presionamos o soltamos, el contacto rebota durante algunos milisegundos antes de estabilizarse. Esto puede disminuir la precisión, causando una serie de problemas como incrementar contadores varias veces, disparas fsms múltiples veces o inclusive romper la lógica del sistema. El debouncer básicamente va a filtrar esos rebotes, detectando una sóla pulsación y generando por tanto un sólo pulso limpio de un ciclo. 
## Funcionamiento
Para este sistema, se implementaron dos módulos; BCD_module y BCD_4displays. El primer módulo mencionado es el que se encarga de convertir el valor BCD al patrón de número correspondiente para un display de 7 segmentos. Este módulo es instanciado dentro de BCD_4displays, el cuál recibe un número de N_in bits y extrae cada dígito decimal mediante operaciones aritméticas para poder separarlo. 

## Arquitectura
Con referencia al trabajo realizado por FPGA4student en 2017 (https://www.fpga4student.com/2017/04/simple-debouncing-verilog-code-for.html) podemos realizar una aruitectura de sistema donde se use un módulo de clock divider conectado a dos flip flops tipo D, cómo se muestra en el diagrama a continuación; <img width="640" height="260" alt="image" src="https://github.com/user-attachments/assets/4bebce63-524b-4ab8-959c-755169157961" />
. 

## Entradas y salidas
En el top, se utilizan las entradas físicas del botón (KEY 0), el reset (KEY 1). Aparte se usa en el top module el reloj dividido, la salida del flipflop 1, la salida del flipflop 2 y el pulso (Nota - el pulso funciona en este challenge de manera similar a un one shot). La salida se muestra una vez que se estabilizó la señal de entrada mandada por el botón, y enciende el LEDR 0 para mostrar esto. 

## Test bench
Para el test bench, se simula un rebote de botón usando "d", y a partir de ahí, podemos observar como la señal del flipflop 1 sube en el flanco positivo del reloj, y la del flipflop 2 sube cuando la salida del flipflop 1 se estabiliza. Esto se muestra de la siguiente manera:
<img width="2264" height="399" alt="image" src="https://github.com/user-attachments/assets/a0d7d69a-c61e-4cc0-8db4-659a67f2b49e" />

## Evidencias de funcionamiento
https://drive.google.com/file/d/1dTWrsz2jam1koEAkbFL1SO7NT3QT3aTy/view?usp=drivesdk 

## Aprendizajes y conclusiones
A manera de conclusión, este challenge fue muy útil para aprender acerca del funcionamiento interno de la FPGA y cómo apoyarme de Verilog para implementar funcionalidades útiles para respaldar los mecanismos internos de la tarjeta.
