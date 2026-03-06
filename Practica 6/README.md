#### Miguel Alonso De La Rosa Zamora A01646106
#### Gregorio Alejandro Orozco Torres A01641967
#### A01639462 Sophia Leñero Gómez

# Práctica 6 - Protocolo de comunicación UART 

## Descripción del proyecto
  Para esta práctica, se solicitaba crear por medio de Verilog HDL un sistema capaz de generar comunicación entre dos tarjetas FPGA utilizando el protocolo UART (Universal Asynchronus Receiver Transmitter). Este es un protocolo de comunicación serial esencial en el ámbito digital, puesto que es ampliamente utilizado para transmitir datos entre dispositivos sin necesidad de una señal de reloj compartida.
Para la implementación de este proyecto, se implementó un sistema compuesto de principalmente un transmisor (RX) y un receptor (Tx), ambos integrados por medio de un wrapper que permite tanto el envío como la recepción de datos seriales utilizando un reloj de 50 MHz y una velocidad de transmición de 9600 baudios. A continuación se relata su proceso de realización. 

## Arquitectura del sistema
  El diseño de este sistema sigue una arquitectura jerárquica, en donde la integración general del sistema la realiza el modulo top.v. De ahí, se utiliza un Wrapper que junta los módulos de UART_Tx (transmisor) y UART_Rx (Receptor). Finalmente, se utiliza un módulo BCD_module para reflejar los datos transmitidos en el display de 7 segmentos de la tarjeta. 
La arquitectura se muestra en el diagrama de a continuación;

<img width="323" height="469" alt="image" src="https://github.com/user-attachments/assets/0da54261-c383-4e59-bcc5-899d0985822e" />

## Funcionamiento del sistema
  El funcionamiento del sistema consiste en que se introduce en cualquiera de las dos tarjetas un dato en _data_in_, en donde se mostrará en los displays. Tras esto, se activa la señal start y después, el UART_Tx transmite el dato de manera serial. El módulo UART_Rx recibe entonces el dato y lo reconstruye. Cuando el dato esta disponible, se activa data_Ready y se envía a BCD_module para mostrar el valor en los displays de la tarjeta receptora.


## Entradas y salidas 
  El módulo UART recibe como entradas la señal de _clk_ (50 MHz), la señal de reinicio _rst_, el dato de 8 bits _data_in_ (la información a transmitir) y la señal _start_, que le indica al transmisor cuando empezar a enviar datos. 
Las salidas del sistema son la señal _busy_, que indica cuando el transmisor se encuentra ocupado en una transmisión, el dato _data_out_ de 8 bits (el dato recibido) y la señal _data_Ready_, que indica al receptor que ha terminado de recibir el dato. 


## Test bench
  Para poder probar el sistema y su correcto funcionamiento, se realizó un test bench (_UART_tb_) que simula el comportamiento del módulo UART y permite observar el intercambio de datos. En este, se genera una señal periódica de 50 MHz (el reloj). Después de esto y de inicializar las señales en 0, se inicia una secuencia de prueba que consiste en activar la señal de reset para inicializar el sistema, espera a que que estabilice, genera 10 datos aleatorios para probar la transmisión, activa _start_ para empezar a transmitir, esperar a que _data_ready_ indique la correcta recepción del dato y finalmente mostrar en consola el dato transmitido y recibido.


## Evidencias de la práctica 
El contenido multimedia evidenciando la implementación de la práctica en físico se adjuntan a continuación; 

https://drive.google.com/drive/folders/16P0-7iwm08brlSdnRSv-dWuADJgj4b0D?usp=drive_link

## Aprendizajes y conclusiones
  En esta practica se adquirieron varios aprendizajes, pero sobre todo, mucho conocimiento relacionado con el diseño de sistemas digitales y comunicación serial. Entendimos a profundidad el funcionamiento del protocolo UART y el proyecto nos ayudó a comprender mejor los conceptos vistos en clase. 
A manera de conclusión, en este proyecto se desarrolló de manera exitosa un sistema de comuniación UART. La implementación nos permitió transmitir datos convertidos a formato serial y posteriormente reconstruirlos correctamente en el receptor. Las pruebas tanto en el test bench como en físico demostraron que los datos transmitidos coinciden con los datos recibidos, validando así el correcto funcionamiento del sistema. 
Esta práctica fue muy valiosa ya que, como ingenieros, es vital que entendamos de manera profunda y conscisa conceptos fundamentales de diseño digital, como lo es la comunicación serial.
