/*	GOOD TEST CASE 1
	1) No #include instruction
	2) main() has a 'void' type, so there is no need of a return at the end 
	2) Different types of variable definition and declaration (int, float, char) 
	3) First variable declaration, then variable definition of var 'b'
	4) Matemathical expression with numerical values, variables and parenthesis
*/

void main () {
	int a = 10;
	char xx = 'h';
	float f = 2.4;
	// Variable 'b' declaration
	int b;
	// Variable definition
	b = 50;
	// Variable definition of 'd' as an expression of variables and numbers	
	int d = a * b +(2/a); 
}

