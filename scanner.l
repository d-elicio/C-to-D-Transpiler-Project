%{ 
	/* ---------------------------------- C-declarations section ( between '%{' and '%}' ) ------------------------------------*/
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "parser.tab.h" 	
	
    	/*Symbol Table Type and Array declaration as imported types */
	extern SYMTABNODEPTR symTab[SYMTABSIZE];
	extern int currentSymTabSize; 
	int installId(char *);
	/*To count the code line numbers: */
	int line_number=1;
        
%}

		/* ---------------------------------- Flex definitions section --------------------------------------------------- */


		/*To generate a scanner that maintains the number of the current line read from the input in the global variable yylineno*/ 
		/*%option yylineno*/

		/* Regular expressions and lexems:*/
alphabet [_a-z_A-Z]
numbers [0-9]

%%

		/* ---------------------------------- Flex rules section ---------------------------------------------------*/
							
^"#include"[ ]*<stdio\.h>				{printf("Found a INCLUDE word\n"); return INCLUDE;}
"main"							{printf("Found a MAIN word\n"); return MAIN;}	
							/* Put an ID in the symbol table and return to the parser the lexer token type */
"char"							{printf("Found a CHAR word\n"); yylval.iVal = installId(yytext); return CHAR;}
"int"							{printf("Found a INT word\n"); yylval.iVal = installId(yytext); return INT;}
"float"						{printf("Found a FLOAT word\n"); yylval.iVal = installId(yytext); return FLOAT;}
"void"							{printf("Found a VOID word\n"); yylval.iVal = installId(yytext);return VOID;}

"if"							{printf("Found a IF word\n"); return IF;}
"else"							{printf("Found a ELSE word\n"); return ELSE;}
"else if"						{printf("Found a ELSE IF word\n"); return ELSE_IF;}
"while"						{printf("Found a WHILE word\n"); return WHILE;}
"return"						{printf("Found a RETURN word\n"); return RETURN;}

"printf"						{printf("Found a PRINTF instruction\n"); return PRINTF;}
"scanf"						{printf("Found a SCANF instruction\n"); return SCANF;}

[-]?{numbers}+\.{numbers}{1,6}			{printf("Found a float number: %s\n",yytext); yylval.iVal = installId(yytext); return 								FLOAT_NUM;}		 
[-]?{numbers}+						{yylval.iVal=atoi(yytext); printf("Found a number: %d \n", yylval.iVal); return 								NUMBER;}  
{alphabet}({alphabet}|{numbers})* 			{printf("Found an ID\n"); yylval.iVal = installId(yytext); return ID;}
"&"{alphabet}						{printf("Found a POINTER\n"); yylval.iVal = installId(yytext); return 							POINTER;}			 	 
['].[']						{printf("Found a CHARACTER:%s \n",yytext); yylval.iVal = installId(yytext); return 								CHARACTER;}
["].*["]						{printf("Found a STRING:%s \n",yytext); yylval.iVal = installId(yytext); return STR;}

"++"							{printf("Found a UNARY operator: %s \n",yytext); yylval.iVal = installId(yytext); 								return PLUS_PLUS;}
"--"							{printf("Found a UNARY operator: %s \n",yytext); yylval.iVal = installId(yytext); 								return MINUS_MINUS;}
"<="                      				{printf("Found <=\n"); return LE;}
">="                        				{printf("Found >=\n"); return GE;}
"=="                        				{printf("Found ==\n"); return EQ;}
"!="                        				{printf("Found !=\n"); return NE;}
">"	                    				{printf("Found >\n"); return GT;}
"<"							{printf("Found <\n"); return LT;}
"&&"							{printf("Found &&\n"); return AND;}
"||"							{printf("Found ||\n"); return OR;}
"+"							{printf("Found +   (math operation)\n"); return ADD;}
"-"							{printf("Found -   (math operation)\n"); return SUBTRACT;}
"/"							{printf("Found /   (math operation)\n"); return DIVIDE;}
"*"							{printf("Found *   (math operation)\n"); return MULTIPLY;}
							/*If find '//' or other commented lines, or tab, or spaces--> do nothing:   */ 
\/\/.*							{ line_number++; }
\/\*(.*\n)*.*\*\/					{ line_number++; } 
[ \t]*							{ ; }
							/*At every new line of the input file analyzed, increase the variable 'line_number'*/
[\n]							{ line_number++; }

"("      						{printf("Found L-PARENTHESIS \n"); return LPAREN;}
")"      						{printf("Found R-PARENTHESIS \n"); return RPAREN;}
"{"      						{ printf("Found L-BRACELET \n"); return LBRACE;}
"}"      						{printf("Found R-BRACELET \n"); return RBRACE;}
";"      						{printf("Found SEMICOLON \n"); return SEMI;}
","      						{printf("Found COMMA \n"); return COMMA;}
"="      						{printf("Found ASSIGNMENT \n"); yylval.iVal = installId(yytext); return ASSIGN;}
						/*If an unexpected value is encontered, it's printed with the line position where is at*/
.	 						{printf("---- Unexpected value: %s -------   ", yytext);yyerror(line_number);}

%%


/* ---------------------------------- Additional C code section --------------------------------------------------- */


/*Symbol table creation, which is an array of pointers to structs, each of which contains an identifier */
SYMTABNODEPTR newSymTabNode() {
	return ((SYMTABNODEPTR) malloc(sizeof(SYMTABNODE)));
}


/*Function to look up an identifier in the symbol table. If it is present, its index is returned. If it isn't there, it is placed in the end position, until the table isn't full, and return its index.*/
int lookup(char *s){
	extern SYMTABNODEPTR symTab[SYMTABSIZE];
	extern int currentSymTabSize;
	int i;
	
	for(i=0; i<currentSymTabSize; i++){
		if(strncmp(s,symTab[i]->identifier, IDLENGTH) == 0){
			return (i);
		}
	}
	return(-1);
}

/*Funtion to save an identifier of a recognized token inside the symbol table */
int installId(char *id) 
{
	extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
	extern int currentSymTabSize;
	int index;

	index = lookup(id);
	//if the id already exists in the symbol table:
	if (index >= 0) {
		return (index);
	}
	else if (currentSymTabSize >= SYMTABSIZE) {
		/* SYMTAB is full */
		return (-1);
	}
	else {
	/*create a new node in the symbol table */
	symTab[currentSymTabSize] = newSymTabNode();
       	/* code for preventing buffer overflows */
	strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
	symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
	return(currentSymTabSize++);
	}
}

