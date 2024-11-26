**Assembly assignment**

**150909 George Fundi Kithinji ICS 3D**


****Question 1****

The program aims to classify a number as either positive or negative. It can be found in the Sign executable file and the Sign.asm assembly file.
The program uses both conditional and unconditional jumps. In this case, we are comparing the input number to zero. If the number is equal to zero(je), the function print_zero is called which printed the message zero. If the number is less than zero(jl), the function print_negative is called which printed the message negative. If none of the conditions are fulfilled, an unconditional jump is done which prints the message positive that shows that the input number is positive. Another unconditional jump is done to exit the program. 

****Question 2****

The program aims to reverse the positions of elements in an array. It can be found in the Array executable file and the Array.asm assembly file. 
It achieves this by creating two pointers that point to the start and the end of the array. It then moves the pointers to the centre of the array, one pointer pointing towards the next element(start pointer) and the other pointing towards the previous element(end pointer). This happens over an iteration of half the size of the array which serves a counter for the loop which iterates until it reaches zero. The main challenge is that there is no separate space for the swapped array, hence the program has to work on limited space.

****Question 3****

The program aims to calculate the factorial of a number by using subroutines and the stack. It can be found in the Factorial executable file and the Factorial.asm assembly file.
The program implements the use of stack data structure and recursion to calculate the factorial. First, the base case is established which is 1. If the number in the eax register is not equal to 1, the function is repeated over and over until the base case is reached. While performing recursion, the immediate results are stored in the stack and the final results are converted to ASCII for printing. 
The registers ecx and edx are used to store the data and the data length respectively. 

****Question 4****

The program aims to read the value of a sensor and perform an action based on what the sensor interprets. It can be found in the Sense.exe file and the Sense.asm assembly file.
The program first gets input and converts it to an integer. It is then compared to two numbers: 30 and 70. If the number is less than 30, the motor is activated. If the number is less than 70, the alarm is activated. If the number is moderately between 30 and 70, the motor is set to stop. The motor status is then compared against 1. If the status is equal to 1, the motor_on_msg is displayed. If not, the motor_off_msg is displayed. 
The alarm status is also compared against 1. If it is equal, the alarm_on_msg is displayed on the console and if it is not equal, the alarm_off_msg is displayed on the console. It uses the ecx register to display the messages while placing the eax and ebx register values as 4 and 1 respectively.

****Compiling and running the programs****

When compiling the files, you can use nasm as a compiler.
```
nasm -f elf64 -o filename.o -g - for 64 bit systems
nasm -f elf32 -o filename.o -g - for 32 bit systems
```
When creating the executable files for the program, you can use the ld which acts as a linker
```
ld filename.o -o filename - for 64 bit systems
ld -m elf_i386 filename.o -o filename - for 32 bit systems
```
****Challenges encountered****

The major challenges that were faced when performing these tasks were segmentation faults. This is mainly because of the use of 32-bit registers in 64-bit systems hence it wasn't easy to compile the assembly code. This also happened because of the use of 32-bit instructions that were run in 64-bit systems, bringing about errors of instructions not used in 64-bit systems.


