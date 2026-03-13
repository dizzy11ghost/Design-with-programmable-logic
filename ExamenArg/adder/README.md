# Examen argumentativo - Summation

## Instrucciones
Diseñar un sistema en Verilog que:
1. Reciba un número de entrada mediante los switches.
2. Al activar una señal de start, calcule la sumatoria desde 0 hasta el número ingresado.
3. Muestre el resultado de la sumatoria en una salida, como LEDs o displays de 7
segmentos.
4. NO SE PUEDE UTILIZAR LA FORMULA DE GAUSS.

## Sistema implementado
La arquitectura de este sistema incluye un BCD_display y BCD_module para usar los displays de 7 segmentos, un clock divider para usar otra frecuencia de reloj, un summation para implementar la lógica de la sumatoria, y finalmente un top para unir todo
Para la sumatoria, tiene que haber un input ded 4 bits (data_in) que va a representar valores de entre o a 15. Al activarse start, el sistema comenzará a calcular la suma de todos los números desde 0 hasta el valor ingresado. El valor que salga será almacenado en sum, la cuál tiene 8 bits para procurar que quepa el valor máximo de la sumatoria. También, para este módulo, es vital señalar el count y el busy. Count sirve para generar los números que se irán sumando, y busy indica si el sistema esta actualmente realizando alguna operación. 

## Evidencias físicas
El ejercicio funcionando se muestra a continuación



https://github.com/user-attachments/assets/49a6ba2b-f89b-4431-b461-dc56b8ec60f8

