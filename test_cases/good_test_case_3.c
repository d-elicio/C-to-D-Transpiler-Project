/*	GOOD TEST CASE 3
	1) There is an #include instruction
	2) main() has a 'void' type, so there isn't a 'return' at the end 
	2) 'int' variables definition and declaration ('a' variable's name start with an underscore )
	3) I/O intruction (printf) 
	4) While instruction with condition and rules to follow until the condition is satisfied 
	5) int variables increment and decrease using unary operators 
*/
#include<stdio.h>

void main() {
    int _a=300;
    //First, declaration of 'd':
    int d;
    //Now, 'd' definition:
    d=0;
    printf("Hello\n");
    while(d<4){
    	_a--;
    	printf("%d\n", _a);
    	d++;
    }
}









