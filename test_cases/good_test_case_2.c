/*	GOOD TEST CASE 2
	1) There is an #include instruction
	2) main() has a 'int' type, so there is a 'return' at the end 
	2) 'int' variables definition and declaration ('x' and 'a')
	3) I/O intructions (printf and scanf) 
	4) If-else instructions with conditions and rules to follow if a condition is satisfied 
	5) Mathematical expression with variables, numerical values and parenthesis
*/

#include<stdio.h>

int main() {
	int x=10;
	int a;
	printf("value of X: %d\n",x);
	printf("Insert the value of a: ");
	scanf("%d", &a);
	if(x>a) {
	        printf("X is greater than A\n");
	        printf("Computation of a=(x*2)+10\n");
	        a = (x * 2)+ 10;	
	        printf("\n Final value of X: %d\n", x);
	        printf("\n Final value of A: %d\n\n", a);
        }
    	else if(x<a){
		printf("A is greater than X\n");
    	}    
    	else{
        	printf("A and X are equal");
    	}
return 0;
}
