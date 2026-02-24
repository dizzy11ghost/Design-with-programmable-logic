A01639462 Sophia Leñero Gómez

# Práctica 2 - BCD 4 displays 

## Descripción
Para esta práctica, se tenía que implementar un sistema de HDL usando verilog capaz de convertir un valor númerico de formato binario de hasta 4 dígitos decimales a señales de control para poder mostrar 4 displays de 7 segmentos que separaran unidades, decenas, centenas y millares. 

## Funcionamiento
Para este sistema, se implementaron dos módulos; BCD_module y BCD_4displays. El primer módulo mencionado es el que se encarga de convertir el valor BCD al patrón de número correspondiente para un display de 7 segmentos. Este módulo es instanciado dentro de BCD_4displays, el cuál recibe un número de N_in bits y extrae cada dígito decimal mediante operaciones aritméticas para poder separarlo. 

## Entradas y salidas 
La entrada que utiliza el sistema es únicamente bcd_in, que tiene un tamaño de N_in bits (cómo se mencionó previamente) y se encarga del valor numérico de entrada. Las salidas que utiliza son D_un, D_de, C_ce y D_mi, cada una tiene un tamaño de 7 bits y se disponen respectivamente para las unidades, decenas, centenas y millares.
Este sistema utiliza una arquitectura combinacional, por lo que depende únicamente de sus entradas y no rqeuiere un reloj o un reset. 

## Test bench
Para el test bench, se usan diferentes números aleatorios para luego proceder a separarlos entre unidades, decenas, centenas y millares, y de esa forma comprobar que todo funcione adecuadamente
<img width="1200" height="1600" alt="image" src="https://github.com/user-attachments/assets/aff89fd3-da7b-4364-a087-f4aeefa120b7" />

## Fotografías evidenciando la práctica
<img width="1600" height="1200" alt="image" src="https://github.com/user-attachments/assets/a77d9155-3e1c-4856-bd16-f112f1ad8355" />
<img width="1200" height="1600" alt="image" src="https://github.com/user-attachments/assets/6f1b501f-859f-4e54-9a60-1b0bcd37c28f" />
<img width="1600" height="773" alt="image" src="https://github.com/user-attachments/assets/dc9a011f-5bbc-4f47-8ed4-42579d226863" />

## Aprendizajes y conclusiones
Definitivamente hubo mucho aprendizaje en esta práctica. Aprendimos a usar módulos de display para mostrar digitos en el FPGA y aprendimos prácticamente cómo desarrollar un sistema conteniendo múltiples módulos, instanciando entre si y aplicando lógica para realizar el objetivo. 
