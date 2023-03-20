/* ---------------------------------- C-declarations section ( between '%{' and '%}' ) --------------------------------------------------- */
%{
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

// Variable used to highlight the code line number where there is an error
extern int line_number;    

//Costants used for the creation of the Symbol Table
#define SYMTABSIZE 3000
#define IDLENGTH 2500

    
// Enumeration of all the types of nodes that make up the parse tree    
enum NodeTypes {PROGRAM, BEGIN_NODE, MAIN_TYPE, INCLUDE_NODE, RETURN_NODE, STATEMENTS, STATEMENT, OUTPUT_STATEMENT, INPUT_STATEMENT,  STRING_VALUE_, IF_STATEMENT, ELSE_IF_STATEMENT, WHILE_STATEMENT, ASSIGNMENT_STATEMENT, TYPE, ID_VALUE, POINTER_VALUE, UNARY_OP, CONDITION, RELOP, EXPR, OPERATION, NUM_VALUE, FLOAT_NUM_value, CHAR_VALUE, STR_VALUE,};
    
// Tree nodes' names that will be used to print
char *NodeNames[] = {"PROGRAM", "BEGIN_NODE", "MAIN_TYPE", "INCLUDE_NODE","RETURN_NODE","STATEMENTS", "STATEMENT", "OUTPUT_STATEMENT","INPUT_STATEMENT", "STRING_VALUE_", "IF_STATEMENT", "ELSE_IF_STATEMENT","WHILE_STATEMENT", "ASSIGNMENT_STATEMENT", "TYPE","ID_VALUE", "POINTER_VALUE", "UNARY_OP", "CONDITION", "RELOP", "EXPR", "OPERATION", "NUM_VALUE", "FLOAT_NUM_value", "CHAR_VALUE", "STR_VALUE"};
    

/* PARSE TREE DEFINITION (It has 5 arguents: 1 for the recognized item during the parsing phase, 1 to identify the tree node with a specific name, and 3 possible children) */
struct tree_node {
	int item;
	int nodeIdentifier;
	struct tree_node *firstChild;
	struct tree_node *secondChild;
	struct tree_node *thirdChild;
};

//call the struct type(tree_node) in another simpler way(TREE_NODE)   
//  typedef <existing_name> <alias_name> 
typedef struct tree_node TREE_NODE;
typedef TREE_NODE *TREE;


//Tree and functions declarations: 
TREE create_node(int, int, TREE, TREE, TREE);
void PrintTree(TREE, int);
void create_code(TREE);
     
     
/* SYMBOL TABLE DEFINITION: it stores an identifier and its type */
struct symTabNode {
	char identifier[IDLENGTH];
};

//call the struct type(symTabNode) in another simpler way(SYMTABNODE)  
//   typedef <existing_name> <alias_name>    
typedef struct symTabNode SYMTABNODE;
typedef SYMTABNODE *SYMTABNODEPTR;

// Symbol table declaration:    
SYMTABNODEPTR symTab[SYMTABSIZE];    
int currentSymTabSize = 0;	
%}


// ---------------------------------- Bison declarations section --------------------------------------------------- 


// Tell Bison what is the start non-terminal for my grammar (it defines the first rule from which the parsing will begin):
%start program

 // Define the types that the LEXER will use to pass tokens to the parser-->with this you can use 'yylval' to pass token's info to the parser
%union {
	int iVal;
	 TREE tVal;
}

//Types of the tokens:
%token<iVal> FLOAT_NUM NUMBER ID INT FLOAT CHAR VOID CHARACTER STR ASSIGN INCLUDE POINTER PLUS_PLUS MINUS_MINUS
// Tokens that don't return a value
%token PRINTF SCANF WHILE IF ELSE ELSE_IF ADD SUBTRACT MULTIPLY DIVIDE GT LT LE GE EQ NE AND OR RETURN LPAREN RPAREN LBRACE RBRACE SEMI COMMA MAIN
// Specify names for non-terminals --> Grammar rules return a (tree) 'tVal' type 
%type<tVal> program begin main_type header end statements statement output_statement input_statement string_value if_statement else_if_statement while_statement assignment_statement type id_value unary_op condition relop expr operation value return_value

//Precedence rules:
%left LPAREN RPAREN
%left ADD SUBTRACT
%left MULTIPLY DIVIDE
%left GT LT GE LE
%left EQ NE
%left OR
%left AND
%right ASSIGN
%left COMMA


%%


// ---------------------------------- Bison Rules section ---------------------------------------------------

								//Tree creation, tree printing and creation of D code:
program: begin MAIN LPAREN RPAREN LBRACE statements end	{TREE ParseTree; ParseTree = create_node(-1, PROGRAM, $1,$6, $7);
		   				  				PrintTree(ParseTree, 5);
		   				  				create_code(ParseTree);}
;

begin: header main_type					{$$ = create_node(-1, BEGIN_NODE, $1, $2, NULL);}
| main_type 							{$$ = create_node(-1, BEGIN_NODE, $1, NULL, NULL);}
;

main_type: INT							{$$ = create_node($1, MAIN_TYPE, NULL, NULL, NULL);}
| VOID								{$$ = create_node($1, MAIN_TYPE, NULL, NULL, NULL);}
;

header: INCLUDE 						{$$ = create_node($1, INCLUDE_NODE, NULL, NULL, NULL);}
;

end: RETURN return_value SEMI RBRACE				{$$ = create_node(-1, RETURN_NODE, $2, NULL, NULL);}
| RBRACE							{$$ = create_node(-1, RETURN_NODE, NULL, NULL, NULL);}
;

statements: statement						{$$ = create_node(-1, STATEMENTS, $1, NULL, NULL);}
| statement statements						{$$ = create_node(-1, STATEMENTS, $1, $2	, NULL);}
;

statement: if_statement					{$$ = create_node(-1, STATEMENT, $1, NULL, NULL);}
| while_statement						{$$ = create_node(-1, STATEMENT, $1, NULL, NULL);}
| assignment_statement						{$$ = create_node(-1, STATEMENT, $1, NULL, NULL);}
| output_statement						{$$ = create_node(-1, STATEMENT, $1, NULL, NULL);}
| input_statement						{$$ = create_node(-1, STATEMENT, $1, NULL, NULL);}
;

output_statement: PRINTF LPAREN string_value RPAREN SEMI	{$$ = create_node(-1, OUTPUT_STATEMENT, $3, NULL, NULL);}
| PRINTF LPAREN string_value COMMA id_value RPAREN SEMI	{$$ = create_node(-1, OUTPUT_STATEMENT, $3, $5, NULL);}
;

input_statement: SCANF LPAREN string_value COMMA id_value RPAREN SEMI	{$$ = create_node(-1, INPUT_STATEMENT, $3, $5, NULL);}
;

string_value: STR								{$$ = create_node($1, STRING_VALUE_, NULL, NULL, NULL);}
;

if_statement: IF LPAREN condition RPAREN LBRACE statements RBRACE		{$$ = create_node(-1, IF_STATEMENT, $3, $6, NULL);}
| IF LPAREN condition RPAREN LBRACE statements RBRACE else_if_statement	{$$ = create_node(-1, IF_STATEMENT, $3, $6, $8);}
;

else_if_statement: ELSE_IF LPAREN condition RPAREN LBRACE statements RBRACE	{$$ = create_node(-1, ELSE_IF_STATEMENT, $3, $6, NULL);}
| ELSE_IF LPAREN condition RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE	{$$ = create_node(-1, ELSE_IF_STATEMENT, $3, $6, $10);}
| ELSE LBRACE statements RBRACE						{$$ = create_node(-1, ELSE_IF_STATEMENT, $3, NULL, NULL);}
;

while_statement: WHILE LPAREN condition RPAREN LBRACE statements RBRACE	{$$ = create_node(-1, WHILE_STATEMENT, $3, $6, NULL);}
;

assignment_statement: type id_value ASSIGN value SEMI	{$$ = create_node($3, ASSIGNMENT_STATEMENT, $1,$2,$4);} 
| type id_value SEMI						{$$ = create_node(-1, ASSIGNMENT_STATEMENT, $1,$2,NULL);}
| id_value ASSIGN expr SEMI					{$$ = create_node($2, ASSIGNMENT_STATEMENT, $1,NULL,$3);}
| type id_value ASSIGN expr SEMI				{$$ = create_node($3, ASSIGNMENT_STATEMENT, $1,$2,$4);}
| id_value unary_op SEMI					{$$ = create_node(-1,ASSIGNMENT_STATEMENT, $1,$2,NULL);}
;

type: INT							{$$ = create_node($1, TYPE, NULL, NULL, NULL);}
| FLOAT							{$$ = create_node($1, TYPE,NULL, NULL, NULL);}
| CHAR								{$$ = create_node($1, TYPE, NULL, NULL, NULL);}
| VOID								{$$ = create_node($1, TYPE, NULL, NULL, NULL);}
;

id_value: ID							{$$ = create_node($1, ID_VALUE, NULL, NULL, NULL);}
| POINTER							{$$ = create_node($1, POINTER_VALUE, NULL, NULL, NULL);}
;

unary_op: PLUS_PLUS						{$$ = create_node($1, UNARY_OP, NULL, NULL, NULL);}
| MINUS_MINUS							{$$ = create_node($1, UNARY_OP, NULL, NULL, NULL);}
;

condition: expr relop expr					{$$ = create_node(-1, CONDITION, $1, $2, $3);}
;

relop: GT							{$$ = create_node(GT, RELOP, NULL, NULL, NULL);} 
| LT								{$$ = create_node(LT, RELOP, NULL, NULL, NULL);}
| LE								{$$ = create_node(LE, RELOP, NULL, NULL, NULL);}
| GE								{$$ = create_node(GE, RELOP, NULL, NULL, NULL);}
| EQ								{$$ = create_node(EQ, RELOP, NULL, NULL, NULL);}
| NE								{$$ = create_node(NE, RELOP, NULL, NULL, NULL);}
| AND								{$$ = create_node(AND, RELOP, NULL, NULL, NULL);}
| OR								{$$ = create_node(OR, RELOP, NULL, NULL, NULL);}
;

expr: value operation expr					{$$ = create_node(-1, EXPR, $1, $2, $3);}
| LPAREN expr RPAREN 						{$$ = create_node(-1, EXPR, NULL, $2, NULL);}
| LPAREN expr RPAREN operation expr 				{$$ = create_node(-1, EXPR, $2, $4, $5);}
| value							{$$ = create_node(-1, EXPR, $1, NULL, NULL);}  
;

operation: ADD							{$$ = create_node(ADD, OPERATION, NULL, NULL, NULL);}
| SUBTRACT							{$$ = create_node(SUBTRACT, OPERATION, NULL, NULL, NULL);}
| DIVIDE							{$$ = create_node(DIVIDE, OPERATION, NULL, NULL, NULL);}
| MULTIPLY							{$$ = create_node(MULTIPLY, OPERATION, NULL, NULL, NULL);}
;

value: NUMBER							{$$ = create_node($1, NUM_VALUE, NULL, NULL, NULL);}
| ID								{$$ = create_node($1, ID_VALUE, NULL, NULL, NULL);}
| POINTER							{$$ = create_node($1, POINTER_VALUE, NULL, NULL, NULL);}
| FLOAT_NUM							{$$ = create_node($1, FLOAT_NUM_value, NULL, NULL, NULL);}
| CHARACTER							{$$ = create_node($1, CHAR_VALUE, NULL, NULL, NULL);}
| STR								{$$ = create_node($1, STR_VALUE, NULL, NULL, NULL);}
;

return_value: NUMBER						{$$ = create_node($1, NUM_VALUE, NULL, NULL, NULL);}
;


%%


// ---------------------------------- Additional C code section ---------------------------------------------------



/* Function definition for the tree creation. It has 5 arguments:
	1) the final item to save that represents the node  (the recognized item during the parsing phase)
	2) the node name
	3-4-5) the three node's children*/
TREE create_node(int ival, int node_name, TREE p1, TREE p2, TREE p3){
	TREE t;
	t = (TREE)malloc(sizeof(TREE_NODE));
	t->item = ival;
	t->nodeIdentifier = node_name;
	t->firstChild = p1;
	t->secondChild = p2;
	t->thirdChild = p3;
	return (t);
}



//Declaration of the function used to print the parse tree:("nodeIdentifier" are the tree node's names, "identifier" refers to the SymTable)
void PrintTree(TREE t, int indentation) {
	// variable used to 'pretty printing' the tree giving a different indentation to the various children:
	int i;
	
	// if the tree is empty (or there have been errors) abort
	if (t==NULL) { 
		return;
		}
	//To print names and spaces between different nodes of the tree:	
	for(i=indentation; i; i--) {
		printf(" ");
		}
		if (t->nodeIdentifier == TYPE)
			printf("\tType: %s ", symTab[t->item]->identifier);
		else if (t->nodeIdentifier == MAIN_TYPE)
			printf("\tMain type: %s ", symTab[t->item]->identifier);	
		else if(t->nodeIdentifier == ID_VALUE )
			if (t->item > 0 && t->item < SYMTABSIZE)
			printf("\tVariable: %s ",symTab[t->item]->identifier);
			else printf("Unknown Identifier: %d ",t->item);	
		else if (t-> nodeIdentifier == NUM_VALUE)
			printf("\tNumber: %d ", t->item);
		else if (t-> nodeIdentifier == FLOAT_NUM_value)
			printf("\tFloat Number: %s ", symTab[t->item]->identifier);
		else if (t-> nodeIdentifier == CHAR_VALUE)
			printf("\tChar: %s ", symTab[t->item]->identifier);
		else if (t-> nodeIdentifier == STR_VALUE)
			printf("\tString: %s ", symTab[t->item]->identifier);
		else if (t-> nodeIdentifier == OPERATION)
			printf("\tMath operation ");
		else if(t-> nodeIdentifier == STRING_VALUE_)	
			printf("\tString: %s ", symTab[t->item]->identifier);
		
		//print the final item that represents the node
		else if(t->item != -1) {
			//(control to not broke the code) "if the item exists and the table is not finished":
			if (t->item>0 && t->item < SYMTABSIZE)  
			printf("  Identifier: %s   ", symTab[t->item]->identifier);
		}
			
	//Now make a control to be sure that the Node name is already known(see line 20 of the code)--> if not, print "Unkwnown Identifier"
	if (t->nodeIdentifier <0 || t->nodeIdentifier > sizeof(NodeNames)){
		printf("  Unknown nodeIdentifier: %d\n", t->nodeIdentifier);
		}
	// If the node name is already known, print it:
	else {
		printf("        %s\n", NodeNames[t->nodeIdentifier]);
		PrintTree(t->firstChild, indentation+3);
		PrintTree(t->secondChild, indentation+3);
		PrintTree(t->thirdChild, indentation+3);
	}
}


// Function to write the new code in D language:
void create_code(TREE t){
	// if the tree is empty (or there have been errors) abort
	if (t==NULL) return;
	
		//Write the new code using the names of the nodes of the parse tree to respect the semantic meaning
		switch(t->nodeIdentifier)
		{
			case(PROGRAM):
				create_code(t->firstChild);
				printf(" main()\n { \n");				
				create_code(t->secondChild);
				create_code(t->thirdChild);
				return;				
			case(MAIN_TYPE):
				create_code(t->firstChild);
				printf("%s", symTab[t->item]->identifier);
				return;
			case(INCLUDE_NODE):
				printf("\n\n\nimport std.stdio;\n\n");
				return;
			case(STATEMENTS):
				create_code(t->firstChild);
				create_code(t->secondChild);
				return;
			case(RETURN_NODE):
				if(t->firstChild != NULL){
					printf("\treturn ");
					create_code(t->firstChild);
					printf(";");
					printf("\n}\n");
				}
				else {
					printf("}\n");
				}
				return;
			case(IF_STATEMENT):
				printf("\tif (");
				create_code(t->firstChild);
				printf(")\n\t {\n");
				printf("\t");
				create_code(t->secondChild);
				printf("\t}\n");
				create_code(t->thirdChild);
				return;
			case(ELSE_IF_STATEMENT):
				if(t->secondChild == NULL && t->thirdChild== NULL){
					printf("\telse \n{\n");
					create_code(t->firstChild);
					printf("\t}\n");
				}
				else if(t->thirdChild==NULL){
					printf("\telse \n{\n\tif(");
					create_code(t->firstChild);
					printf(") \n{");
					create_code(t->secondChild);
					printf("\t}\n");
					printf("\t}\n");
				}
				else {
					printf("\telse \n{\n\tif(");
					create_code(t->firstChild);
					printf(") \n{");
					create_code(t->secondChild);
					printf("\t}\n");
					printf("\telse \n{");
					create_code(t->thirdChild);
					printf("\t}\n");
					printf("\t}\n");
				}				
				return;
			case(WHILE_STATEMENT):
				printf("\twhile (");
				create_code(t->firstChild);
				printf(")\n \t{\n");
				printf("\t");
				create_code(t->secondChild);
				printf("\t}\n");
				return;
			case(ASSIGNMENT_STATEMENT):
				if (t->firstChild != NULL && t->secondChild != NULL && t->thirdChild != NULL){
					create_code(t->firstChild);
					create_code(t->secondChild);
					printf(" = ");	
					create_code(t->thirdChild);
					printf(";\n");	
				}
				else if (t->secondChild == NULL){
					printf("\t");
					create_code(t->firstChild);
					printf(" = ");
					create_code(t->thirdChild);
					printf(";\n");
				}
				else {
					create_code(t->firstChild);
					create_code(t->secondChild);
					create_code(t->thirdChild);
					printf(";\n");
				}
				return;
			case(OUTPUT_STATEMENT):
				if(t->secondChild==NULL){
					printf("\twriteln(");
					create_code(t->firstChild);
					printf(");\n");
				}
				else {
					printf("\twriteln(");
					create_code(t->firstChild);
					printf(", ");
					create_code(t->secondChild);
					printf(");\n");
				}
				return;
			case(INPUT_STATEMENT):
				printf("\treadf(");
				create_code(t->firstChild);
				printf(", ");
				create_code(t->secondChild);
				printf(");\n");
				return;
			case(NUM_VALUE):
				printf(" %d ", t->item);
				return;	
			case(ID_VALUE):
				printf("%s", symTab[t->item]->identifier);
				return;
			case(POINTER_VALUE):
				printf("%s", symTab[t->item]->identifier);
				return;
			case(UNARY_OP):
				printf("%s", symTab[t->item]->identifier);
				return;
			case(TYPE):
				printf("\t%s ", symTab[t->item]->identifier);	
				return;		
			case(FLOAT_NUM_value):
				printf(" %s", symTab[t->item]->identifier);
				return;
			case(CHAR_VALUE):
				printf(" %s", symTab[t->item]->identifier);
				return;
			case(STR_VALUE):
				printf(" %s", symTab[t->item]->identifier);
				return;
			case(STRING_VALUE_):
				printf("%s", symTab[t->item]->identifier);
				return;
			case(EXPR):
				if (t->firstChild == NULL && t->secondChild != NULL){
				printf(" (");
				create_code(t->secondChild);
				printf(")");
				}
				else {
					create_code(t->firstChild);
					create_code(t->secondChild);
					create_code(t->thirdChild);
				};
				return;	
			case(OPERATION):
				switch(t->item) {
					case(ADD):
					printf(" + ");
					return;
					case(SUBTRACT):
					printf(" - ");
					return;
					case(MULTIPLY):
					printf(" * ");
					return;
					case(DIVIDE):
					printf(" / ");
					return;
				}	
			case(RELOP):
				switch(t->item){
					case(GT):
					printf(" > ");
					return;
					case(LT):
					printf(" < ");
					return;
					case(LE):
					printf(" <= ");
					return;
					case(GE):
					printf(" >= ");
					return;
					case(EQ):
					printf(" == ");
					return;
					case(NE):
					printf(" != ");
					return;
					case(AND):
					printf(" && ");
					return;
					case(OR):
					printf(" || ");
					return;
					case(LPAREN):
					printf("( ");
					return;
					case(RPAREN):
					printf(" )");
					return;
				}
					
		}
	create_code(t->firstChild);
	create_code(t->secondChild);
	create_code(t->thirdChild);
}



/* main() function calling the yyparse() function to start the parser.
During the creation of this project, the Bison debugging functionalities have been used to solve some problems.
To debug write on the CLI: 
	>>bison -dt parser.y
	>>flex lexer.l
	>>gcc -o project.out parser.tab.c -lfl -DYYDEBUG
*/
int main() {
	#if YYDEBUG == 1
	extern int yydebug;
	yydebug = 1;
	#endif
 
	yyparse(); 
}

// yyerror() function definition to print the number of the line where some errors could occur:
int yyerror(int s) {
    printf("Error at line: %d\n",line_number);
 }

// Call the lexer and have the tokens' definitions:
#include "lex.yy.c"

