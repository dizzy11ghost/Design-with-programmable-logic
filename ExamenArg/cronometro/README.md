*Sophia Leñero Gómez A01639462*
# Examen argumentativo - Cronómetro
## Instrucciones
Descripción del problema
El cronómetro debe cumplir con las siguientes características:
• Inicia el conteo del tiempo.
• Detiene el conteo del tiempo.
• Reinicia el cronómetro a cero.
• Debe contar en unidades de tiempo (pueden ser segundos, milisegundos)
• Mostrar el resultado en display de 7 seg.

## Sistema propuesto
El sistema que se implementó consiste en un cronómetro compuesto por tres módulos principales, el divisor de reloj, el cronómetro y el display de 7 segmentos, lo cuál fue todo unido en un top level entity para mayor limpieza. 
El divisor de reloj se usó para, a partir del reloj de 50MHz de la FPGA, redujera la frecuencia para hacer un reloj de 1MHz, lo que nos permite incrementar el contador una vez por segundo. El cronómetro, por otro lado, es el módulo que cuenta el tiempo. Hay dos always en este, uno usado para la señal de start y stop, que le indican cuando parar y reanudar por medio de una señal "running". El otro always es el contador de tiempo, que sólo cuenta si running está activo y el sistema habilitado por medio de un "enable".
Finalmente, se usaron los módulos BCD_display y BCD_module para poder usar el display de 7 segmentos para mostrar el paso de tiempo en segundos que ofrece el contador de nuestro cronómetro. 

## Test bench
Para la correcta validación y monitoreo de este sistema, se realizó un test bench para poner a prueba. En este, el cronómetro inicia después del pulso de start_stop, el contador comienza en 0 y incrementa correctamente con cada ciclo de clk mientras enable está activo, mostrando un conteo secuencial (001, 002, 003…).
<img width="1898" height="388" alt="image" src="https://github.com/user-attachments/assets/e9c7c275-d73a-435c-85b4-d2a16e6bbc61" />

## Evidencias de funcionamiento físico
A continuación, se adjuntan evidencias del sistema funcionando adecuadamente, los segundos son certeros y las señales de start y stop funcionan acorde a lo deseado.
https://github.com/user-attachments/assets/24c56b82-98e1-478a-971c-7e7aabe1f88c

https://github.com/user-attachments/assets/7efb4aa4-bac9-45cc-b078-3de3ed1e3958


