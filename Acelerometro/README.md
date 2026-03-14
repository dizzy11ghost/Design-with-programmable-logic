#### Miguel Alonso De La Rosa Zamora A01646106
#### Gregorio Alejandro Orozco Torres A01641967
#### A01639462 Sophia Leñero Gómez

# Sistema de control de brazo robótico por medio de una FPGA DE10-Lite

## Objetivo
El objetivo de este reto era poder usar Verilog HDL para implementar un sistema capaz de controlar un brazo robótico de 4 grados de libertad por medio del acelerómetro de una tarjeta FPGA DE10-Lite. El sistema tenía que ser capaz de funcionar en dos modos, el modo manual, en donde la tarjeta obtenía los valores del acelerómetro y los convertía en ángulos correspondientes a cada eje del brazo, para después transformarlos en señales PWM que controlarían los servomotres, permitiendo que siguieran sincronizadamente la tarjeta y su orientación.
El segundo modo a implementar era el modo automático, en el cuál el usuario le podía cargar al robot una rutina de hasta 5 pasos que sería guardada en una memoria RAM y utilizada más adelante por el robot de manera autónoma. 
En ambos modos, los ángulos de los diferentes ejes tenían que ser mostrados en un monitor VGA, indicando además en qué modo se encontraba el robot. 


## Ideación inicial
Para la ideación inicial, se empezó por definir un boceto preliminar de la arquitectura, idear qué módulos habría que usar y de qué manera conectarlos, además de cómo gestionar la parte de hardware. Fue en este proceso de ideación que se llegó al siguiente boceto de arquitectura del sistema;
<img width="1187" height="642" alt="image" src="https://github.com/user-attachments/assets/c8ec0f03-ca81-4740-a5d4-87104d405bda" /> 
Con esto ya hecho, se prosiguió a contruir y conectar el brazo y sus motores, para después iniciar con el proceso de implementación del sistema. 

## Materiales utilizados (Hardware)
-FPGA DE10-Lite 

-Cable USB blaster

-Chasis de brazo robótico impreso en PLA

-5 micro servomotores de 180°

-Cables DuPont

-Capacitor 2200 uF

-Protoboard

## Arquitectura
La arquitectura final se definió como se muestra en el diagrama a continuación;
<img width="945" height="918" alt="image" src="https://github.com/user-attachments/assets/09490837-8258-49e7-b145-860752e2e66a" />
Se trata de una arquitectura modular, en donde cada módulo se encarga de una tarea especíica dentro del control del brazo. Posteriormente se profundiza en la funcionalidad de cada uno de los módulos y de la máquina de estados utilizados.

## Diagrama FSM 
El control general del funcionamiento se realiza mediante una máquina de estados finistos, la cuál recibe las señales mode_sel, rst y load (para un contador de loads). Esta FSM es la que determina el modo de operación del sistema (manual o automático) y genera las señales de control necesarias para coordinar el acceso y almacenamiento de datos en la memoria.

<img width="989" height="768" alt="image" src="https://github.com/user-attachments/assets/c6dfa1df-1b7e-46d5-b5c4-432fa316626f" />

## Descripción de los módulos
El módulo **clk_divider** recibe el reloj interno del FPGA de 50 MHz y una señal de reinicio (rst), y genera una señal de reloj de salida (clk_div) con una frecuencia menor definida por el parámetro FREQ. La frecuencia de salida se obtiene mediante un contador que incrementa su valor en cada flanco positivo del reloj de entrada. Cuando el contador alcanza un valor calculado como constantNumber = CLK_FREQ / (2 * FREQ), este se reinicia y la señal de salida conmuta su estado lógico, logrando así la división de la frecuencia del reloj.

El módulo **pwm** recibe una señal de reloj (clk), una señal de reinicio activa en alto (rst_p) y una entrada de 8 bits (pwm_in) que representa un ángulo entre 0° y 180°, y genera una señal PWM de salida (pwm_out) para controlar la posición de un servomotor. Los parámetros MIN y MAX definen el ciclo de trabajo mínimo y máximo como porcentaje del período, calculados de forma estática al momento de síntesis. Un contador cíclico de 500,000 ciclos establece el período de la señal y al final de cada período el valor de pwm_in se captura en un registro interno para evitar glitches durante el ciclo activo. El umbral de comparación se calcula mediante interpolación lineal entre los límites mínimo y máximo, y la salida se mantiene en alto mientras el contador sea menor a dicho umbral.

El módulo **converter** recibe un valor con signo de 16 bits (coord) proveniente del acelerómetro y genera un ángulo de 8 bits (angle) en el rango de 0° a 180°. La señal de entrada se limita al rango definido entre SENSOR_MIN (-270) y SENSOR_MAX (270), y posteriormente se escala al rango de salida mediante una operación aritmética con signo.

El módulo **fsm** implementa una máquina de estados de cuatro estados que controla el flujo del sistema entre los modos de grabación y reproducción automática. Recibe el reloj del sistema, dos botones (KEY) y un switch de modo (sw_auto), y genera las señales de habilitación de escritura (write_enable), habilitación del contador (counter_enable) y el estado actual (current_state). El avance entre estados se controla mediante un pulso generado a partir del botón KEY[1]. En el estado S1 el sistema espera instrucciones; en S2 registra posiciones en la RAM hasta alcanzar un máximo de cinco, momento en que activa la señal done; en S3 habilita la reproducción automática en bucle mientras el switch sw_auto permanezca activo.

El módulo **counter** genera una dirección de memoria (addr) de 3 bits que se utiliza para recorrer las posiciones almacenadas en la RAM. Recibe señales de reloj, reinicio, habilitación y un indicador de modo bucle (loop_mode). En modo bucle avanza la dirección automáticamente cada segundo, ciclando de 0 a 4 de forma continua. Fuera del modo bucle, la dirección avanza un paso cada vez que la señal enable genera un flanco de subida, permitiendo el avance manual posición a posición durante la grabación.

El módulo **memory_RAM** implementa una memoria RAM de lectura y escritura síncrona parametrizable en ancho de palabra (NBits) y número de bits de dirección (NAddr). Recibe una señal de reloj, un reset asíncrono activo en bajo (rst_a), una señal de habilitación de escritura (wr_en), el dato de entrada y la dirección, y entrega de forma combinacional el dato almacenado en la dirección indicada. Al activarse el reset, todas las posiciones se inicializan a cero.

El módulo **hvsync_generator** recibe una señal de reloj y una señal de habilitación de píxel (pixel_tick), y genera las señales de sincronización horizontal y vertical para VGA (vga_h_sync, vga_v_sync), los contadores de posición CounterX y CounterY de 10 bits, y la señal inDisplayArea que indica si el píxel actual se encuentra dentro del área visible. El contador horizontal se reinicia al llegar a 799 y el vertical al llegar a 524, generando una resolución de 640x480 píxeles a 60 Hz. Los pulsos de sincronización se generan en las regiones de blanking definidas por el estándar VGA y las señales de salida se niegan debido a la lógica activa en bajo del estándar.

El módulo **font_rom** implementa una memoria ROM de solo lectura que almacena los patrones de píxeles de una fuente de caracteres. Recibe una dirección de 11 bits compuesta por el código ASCII del carácter y la fila dentro del mismo, y entrega una salida de 8 bits que representa una fila horizontal de píxeles del carácter solicitado. El contenido de la ROM se carga al iniciar desde un archivo externo font_rom.hex.

El módulo **VGACounterDemo** recibe el reloj del sistema, los ángulos mapeados de los cuatro ejes del brazo (angle_x, angle_y, angle_y2, angle_z) y una señal de modo, y genera la imagen VGA con la información del sistema superpuesta en pantalla. Internamente instancia hvsync_generator para la sincronización y font_rom para renderizar texto. Los ángulos se descomponen en dígitos decimales, se convierten a su código ASCII y se renderizan mediante consultas a la ROM de fuente, mostrando en pantalla los valores numéricos de cada eje. Adicionalmente muestra el modo de operación actual como texto ("MANUAL" o "AUTOMATICO") en una región independiente de la pantalla.

El módulo **top** integra todos los subsistemas del brazo robótico. Recibe el reloj interno de 50 MHz, los botones KEY, los switches SW y la interfaz del acelerómetro GSENSOR, y genera las señales PWM para los cinco servomotores a través de ARDUINO_IO, así como la salida de video VGA. Instancia el módulo accel para la lectura del sensor, la fsm para el control de modos, el counter y la memory_RAM para la grabación y reproducción de posiciones, y VGACounterDemo para la visualización en pantalla. Un conjunto de filtros de rampa suaviza las transiciones entre posiciones en modo automático. Un multiplexor selecciona entre las señales PWM del modo manual (generadas directamente por accel) y las del modo automático (generadas a partir de los datos recuperados de la RAM) según el estado actual de la máquina de estados. La garra se controla mediante SW[9] en modo manual y mediante el valor almacenado en RAM en modo automático.

El módulo **accel** integra la lectura del acelerómetro ADXL345 vía SPI y la generación de señales PWM para cuatro servomotores. Recibe múltiples señales de reloj y de interfaz SPI, y expone como salidas los datos crudos de los tres ejes (raw_x, raw_y, raw_z), los ángulos mapeados (mapped_out_x, mapped_out_y1, mapped_out_y2, mapped_out_z) y las señales PWM correspondientes. Internamente, un PLL genera las frecuencias requeridas para la comunicación SPI. Los datos del sensor se muestrean a 2 Hz y se convierten a ángulos de 0° a 180° mediante instancias del módulo converter. Cada eje cuenta con un filtro de rampa independiente que suaviza el movimiento interpolando gradualmente hacia el ángulo objetivo, con distintas velocidades y estrategias según el eje. Los ángulos suavizados se mapean al rango requerido por cada servo y se alimentan a cuatro instancias del módulo pwm con parámetros MIN y MAX ajustados individualmente.

## RTL Viewer
Gracias a la herramienta de RTL Viewer de Quartus es que podemos ver el funcionamiento interno de nuestro sistema, lo que es vital para poder comprenderlo, oprimizarlo y escalarlo. A continuación se adjunta el RTL Viewer del brazo robótico; <img width="1555" height="839" alt="image" src="https://github.com/user-attachments/assets/bb91c48e-5705-4bb4-adce-3b86103eba1d" />

## Demo 
Resultados del brazo funcionando tanto en modo manual como automático, con el movimiento de garra también implementado, además de una breve introducción y conceptualización del proyecto; 
https://drive.google.com/file/d/14mrwJvIVxQPNWUMQ5MN9XGOmeYwhTrp_/view?usp=sharing

## Conclusiones y aprendizajes
Como ingenieros, es vital para nosotros estar en constante búsqueda de retos que nos forcen a pensar de manera creativa, analítica e innovadora, por lo que este reto fue uno de gran aprendizaje, ya que gracias a su nivel de complejidad, se pudieron poner en práctica toda la teoría y práctica vistas en clase, desde conceptos básicos de verilog como lógica combinacional contra lógica secuencial hasta cosas más complejas como filtrado de señales, VGA y control. 
Fue sin duda un proyecto con varios retos, entre ellos, el quitar todo el ruido de la señal PWM fue sin duda un desafío, por lo que al final se usaron tanto elementos de software y hardware para regularlo. También el uso de un Pin Planner con relación a la VGA fue un obstáculo que requirió paciencia para enfrentar. Pero a pesar de los retos, este proyecto fue sin duda extremadamente enriquecedor y satisfactorio de realizar, dejandonos con muchos aprendizajes. 

