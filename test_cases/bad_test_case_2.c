/*	BAD TEST CASE 2 (PARSING ERRORS)
	- Lines with error are commented (uncomment the lines one at a time to see the different errors)
	
	1) There isn't a 'main' function (Parsing error)
	2) In the first variable definition ('int x =10;') the final ';' is missing (Parsing error)
	3) The 'printf' function has no arguments (Parsing error)
	4) The last '}' to close the 'if' statement is missing (Parsing error)
*/
#include<stdio.h>
//ERROR 1
//int main() 
int main(){
	//ERROR 2:
	//int x=10
	int x=10;
	int a;
	//ERROR 3:
	//printf();
	printf("value of X: %d\n",x);
	printf("Insert the value of a: ");
	scanf("%d", &a);
	if(x>a) {
	        printf("X is greater than A\n");
	        printf("Computation of a=(x*2)+10\n");
	        a = (x * 2)+ 10;
	        //ERROR 4:
	        // }
		}
return 0;
}
