A01639462 - Sophia Leñero Gómez

# Práctica 1 - Detector combinacional de números primos

## Objetivo
El objetivo de esta practica era diseñar e implementar un sistema digital utilizando verilog capaz de determinar si un número binario de 4 bits corresponde a un número primo (dentro del rango de 0-15, considerando la cantidad de bits que estamos usando), activando una salida lógico en caso de ser primo.

## Funcionamiento 
El sistema diseñado se compone de dos módulos, num_prim y top. num_prim se encarga de implementar la lógica combinacional que detecta si el número de entrada es primo o no. Para esto, utilicé expresiones booleanas construidas como suma de minterminos, en los que la salida se activa sólo para 0010 (2), 0011(3), 0101(5), 0111(7), 1011(11) y 1101(13). 

Aparte esta el módulo top, que instancia el módulo num_prim para conectar los switches físicos a las entradas del detector. La salida se conecta al LED del FPGA, el cuál se activa con una señal positiva en caso de detectar un número primo.

## Entradas y salidas
### Entradas: 
Las entradas se encuentran en SW[3:0], vector de 4 bits que representa el número binario a evaluar.

### Salidas:
La salida es LEDR[0], que funciona como una señal de 1 bit que indica si el número es primo (1) o no (0).

## Test bench
Para validar el funcionamiento del sistema se desarrolló un testbench que aplica distintos valores a la entrada SW cada 10 ns. Se probaron específicamente los números primos dentro del rango de 4 bits y algunos valores no primos para comprobar que diera la salida adecuadamente.
Durante la simulación se generó un archivo .vcd para observar las formas de onda. Los resultados obtenidos muestran lo siguiente:
<img width="1936" height="197" alt="image" src="https://github.com/user-attachments/assets/da6c07de-6e57-4d78-b5ad-3ff9a142a64d" />

La salida es 1 únicamente cuando el número corresponde a un primo. Para valores como 0 y 15 la salida permanece en 0, lo que confirma que la función booleana implementada es correcta.

## Video demostrativo 
https://drive.google.com/file/d/176wm5JKxSb1lU10sASC33awN5NF6hjsd/view?usp=drivesdk

## Resultados
Como se puede apreciar en el video demostrativo, se logra detectar números primos por medio del led LEDR0 exitosamente. 

## Aprendizajes y conclusiones
En esta práctica se reforzaron varios conceptos, entre ellos la implementación de funciones booleanas, la conexión e intsaciación entre módulos y la importancia del test bench para validar resultados. Aparte hubo el aprendizaje personal de verificar con más cuidado las expresiones booleanas, ya que son los pequeños errores los que pueden arruinar el funcionamiento entero. 


