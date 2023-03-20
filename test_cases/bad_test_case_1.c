/*	BAD TEST CASE 1 (LEXICAL ERRORS)
	- Lines with error are commented (uncomment the lines one at a time to see the different errors)
	
	1) In the '#include' instruction '#' is missing (Lexical + parsing error)
	2) The c program is correct (it compiles), but the lexer recognize an unexpected value ('###') and its position inside the code (Lexical error)
*/


//ERROR 1
//include <stdio.h>
#include <stdio.h>
void main() {
    int a=300;
    int d=0;
    while(d<4){
    	a--;
    	printf("%d\n",a);
    	d++;
    }    
// ERROR 2    
//###
}
