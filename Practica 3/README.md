*Sophia Leñero Gómez A01639462*
# Practica 3 - Contador ascendente y descendente con display de 7 segmentos
## Objetivo
El objetivo de esta práctica era realizar por medio de Verilog HDL, un sistema capaz de contar incremental o decrementalmente en un rango de 0 a 100. Además, el contador tenía que ser capaz de cargar un número y contar a partir de dicho valor. Para esto, se implementó un contador de capaz de mostrar la cuenta en el display de 7 segmentos de la tarjeta FPGA que pudiera hacer el conteo, usando 1 switch y los dos botones KEY para decidir de qué forma o desde dónde contar.

##Arquitectura del sistema
Para este sistema se utilizaron los módulos top, count100, clk_divider, BCD_module y BCD_display. Se trata de una arquitectura jerárquica, puesto que top se encarga de conectar todos los módulos internos y de interactuar con los componentes físicos de la FPGA. 

## Funcionamiento del sistema y módulos utilizados
El módulo Top, como mencionado anteriormente, es el nivel superior del diseño, por lo tanto el encargado de conectar las entradas físicas de la tarjeta FPGA con los módulos internos del sistema. 
El módulo count100 es el que implementa la lógica principal del contador. Funciona con una serie de condicionales que lo delimitan a reiniciar en 0 si el _rst_ es activado, tomar el valor de _data_in_ si _load_ está activo (esto para contar desde algún número en especifico), contar en órden incremental si _up_down_ esta activo y contar de forma decremental si _up_down_ esta inactivo.
El módulo de clk_divider se utiliza para reducir la frecuencia del reloj de la FPGA y de esta manera poder visualizar a una velocidad especificamente inducida el conteo de datos. 
Los módulos de BCD_display y BCD_module son los encargados de poder mostrar los valores numericos en el display de 7 segmentos, usando centenas, decenas y unidades.

## Entradas y salidas del sistema
El sistema recibe como entradas el reloj de la FPGA (MAX10_CLK1_50), los switches de la tarjeta (para poder seleccionar la dirección y valor del conteo y de la carga) y los botones KEY para reset y para activar la señal de carga del contador. Como salidas, el sistema genera las señales HEX0, HEX1 y HEX2, usadas para mostrar el valor actual del contador en el display. 

## Test bench
Para poder verificar el correcto funcionamiento del sistema, se implementó el siguiente test bench, en el cuál podemos observar que cuando las entradas cambian, las salidas de los displays se actualizan, mostrando así los valores correspondientes al número generado por el contador.
<img width="2048" height="323" alt="image" src="https://github.com/user-attachments/assets/ec8b15ee-680b-4629-bdb6-9efb9a212de5" />

## Evidencias de implementación física
A continuación se adjuntan las evidencias de las pruebas en físico;
https://drive.google.com/file/d/15myD_7ljm7-U47zYvA5hjOje1aeEal_h/view?usp=sharing

## Aprendizajes y conclusiones
En esta práctica definitivamente hubo varios aprendizajes, entre ellos, y para mi el más relevante, la importancia de entender bien lo que intenta resolver un problema antes de empezar a implementarlo. Es sólo cuando eres capaz de diagramar, explicar y descomponer un problema que describirlo con verilog se vuelve posible y sencillo. Aparte, hubo varios conceptos importantes puestos en práctica, como el divisor de reloj, el contador y la carga numérica. 


