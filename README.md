# C to D Transpiler Project
![GitHub watchers](https://img.shields.io/github/watchers/d-elicio/C-to-D-Transpiler-Project?style=social) 
![GitHub forks](https://img.shields.io/github/forks/d-elicio/C-to-D-Transpiler-Project?style=social)
![GitHub Repo stars](https://img.shields.io/github/stars/d-elicio/C-to-D-Transpiler-Project?style=social)
![GitHub last commit](https://img.shields.io/github/last-commit/d-elicio/C-to-D-Transpiler-Project?style=plastic)

Design and implementation of a transpiler to convert simple programs written using a subset of C language in an equivalent working program in D language.

## 🚀 About Me
I'm a computer science Master's Degree student and this is one of my university project. 
See my other projects here on [GitHub](https://github.com/d-elicio)!

[![portfolio](https://img.shields.io/badge/my_portfolio-000?style=for-the-badge&logo=ko-fi&logoColor=white)](https://d-elicio.github.io)
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/domenico-elicio/)


# 💻 The project
A **Transpiler** is a software, sometimes called “*source-to-source compiler*", which converts a high-level language to another high-level language.

To reach the goal of the creation of a working transpiler, a *Lexer*, a *Parser* and a *Code Generator* have been implemented using tools like **Flex** and **Bison**.

Also some *good* and *bad test cases* will be attached to show the possibilities and the
limitations of the transpiler implemented for this project.


## Transpiler description
Compilers are divided into different parts, that define the various compiling steps. In the figure below all the phases computed for this project are shown. So, from a program written in a subset of **C** language, we pass through a **lexer** to recognize all the language’s *tokens*, then with a **parser** the *syntactic* correctness is verified and with the help of a **Symbol Table** and an **Abstract Syntax Tree (AST)** also the semantic correctness is verified. At the end through a code generation phase we create a new program in D language.

![transp](https://user-images.githubusercontent.com/96207365/225892632-38b30ea9-01aa-4fc2-9daa-95f0c3e9142d.png)


### Lexical Analysis
The lexical analysis part has been done with the help of **Flex**, a *scanner generator* used to read in input all the characters of a simple C-like program, group them into **lexemes** and recognize all the **tokens** that make up the program and pass them to the parser to continue all the computations in the later stages. The implemented lexical analyzer is also able to recognize *invalid inputs* and report them to the user highlighting the line number *where* the error has occurred.

Our transpiler can recognize (*and translate to D*) this restriction of **C** language:
- **3 different data types:** int, float and char
- **Arithmetical and logical comparison operators:** <, <=, >, >=, +, -, *, /, ==, !=, &&, ||
- **1 branching instruction:** if statement (and if-else statement)
- **1 loop instruction:** while statement
- **2 I/O instructions:** printf, scanf
It can recognize all **numbers** from 0 to 9, also negatives, **variable names** (IDs) composed by every letter from “a” to “z” upper and lower case even with an underscore in front.

The implemented scanner can also recognize *parenthesis* and *braces*, *commas* and *semicolons* and even the file inclusion directive (**#include**), the reserved words **main** and **return** and the unary operators **++** and **--**

Here is shown an example of the output from the *Lexical Analysis* phase: 
![lexical analysis](https://user-images.githubusercontent.com/96207365/226104069-fc743fd1-6384-45dd-a517-7e0223783868.png)



### Syntax Analysis
The parser analyzes all the data (**tokens**) he receives in input from the *scanner* and it determines the correctness of the structure by using a *grammar definition*. The parser used in this project has been realized thanks to **Bison**, a *parser generator* written in C.

To have a better understanding of all the syntactical rules we have to implement in this project, all the rules have been written in a **BNF (Backus-Naur Form)** form (see *BNF_parser.txt*).


The Bison file (**parser.y**) is divided into three section: in the *first section* all the functions and constants used in this project have been defined together with all the **#include** directives necessary to run the program. 

In the *second section*, the *“Bison declaration section”*, with the command **%token**, all the tokens returned by the scanner have been defined, with **%start** the starting rule from which start parsing the program has been declared, while with **%union** the token types have been specified. At the end of this section, a sequence of *precedence rules* have been defined with the **%left** and **%right** symbols to address some problems related to grammar rules ambiguities of the numerical expressions that have occurred during the implementation of this project. 

The *third section* of the Bison file instead regards the implementation of all the grammar rules that our C-like language has to satisfy to be a syntactically true program. Every syntactic rule is associated with an **action** the parser have to follow every time a rule is recognized.

The *last section* of the Bison file contains *additional C code instructions* useful for the creation of the Abstract Syntax Tree and the writing of the output D code. The file finishes with the declaration of a **main()** function useful to start the parsing program by calling Bison’s **yyparse()** function. At the end there is the declaration of **yyerror()**, a function used to print the number of the line where some errors can occur.


### Semantic Analysis
All the grammar rules written in Bison are followed by **actions** written in C that are executed every time a rule is matched.
All the semantic actions contains *pseudo-variables* indicated with a **$** symbol, and these actions have been used to build an **Abstract Syntax Tree (AST)** for all the C-like input programs passed in input to our transpiler.

Usually in this field, *binary trees* are used, but for this project, due to some problems related to the grammar rules design (e.g. the program rule, if_statement and assignment_statement), the resulting tree has the form of a **ternary tree** where every node has potentially three children.

In the figure below there are some examples of different ASTs produced for three types of assignment statements:
![image](https://user-images.githubusercontent.com/96207365/235991873-1e51c33b-f1f8-486f-8796-a1a9f7524c5e.jpg)


Here is shown an example of a simple C-like program and its relative computed AST:

![test3 in C](https://user-images.githubusercontent.com/96207365/226105395-915e345f-0b2b-4e87-b798-fee33a5bdaad.jpg)
![ParseTree](https://user-images.githubusercontent.com/96207365/226105445-f7baab61-1a27-4c02-b285-cd57fd1fc17c.png)


### Code generation
This is the last phase of our transpiler construction, consisting in the effective translation of the input **C-like** programs into the destination language, **D**.
After the *AST* has been created, having in this way a view of the semantic meaning of all the statements encountered during the *parsing phase*, through the *create_code()* function, the **D** language translation is then print to console for every node of the AST.

**C-like program in input:**
![test3 in C](https://user-images.githubusercontent.com/96207365/226105395-915e345f-0b2b-4e87-b798-fee33a5bdaad.jpg)

**D-program in output:**
![D_code](https://user-images.githubusercontent.com/96207365/226105859-778f95f5-c52f-4fc2-bc9b-f6d8b4be00a1.png)


## Start up guide
To run our transpiler giving in *input* a **C** program to have the respective **D** program in *output*, this are the steps to follow in **Linux**:
- **flex** scanner.l
- **bison -d** parser.y (for debugging purposes add: **-v** to produce the *parser.output* file,  **-t** to enable *Bison debugging mode*)
- **gcc -o** project.out parser.tab.c **-lfl** (at the end add **-DYYDEBUG** to enable *debug mode*)


To run the transpiler:
- **./project.out>** test_cases/good_test_case_1.c

To run the transpiler and save the output in a D file:
- **./project.out<** test_cases/good_test_case_1.c **>** D_code_test_case1.d


## References
- https://westes.github.io/flex/manual/index.html#SEC_Contents
- https://devdocs.io/c/
- https://www.gnu.org/software/bison/manual/bison.html#SEC_Contents
- https://aquamentus.com/flex_bison.html#2
- https://berthub.eu/lex-yacc/cvs/lex-yacc-howto.html
- https://youtube.com/playlist?list=PL3czsVugafjNLmIHA8ODBxuwWy8W4Uk9h
- A guide to Lex and Yacc by Tom Niemann
- Programming in D by Ali Çehreli
- https://www.skenz.it/compilers/flex_bison#data_types_of_semantic_values

## Support

For any support, error corrections, etc. please email me at domenico.elicio13@gmail.com
