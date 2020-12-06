%{

#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"


extern SYMTABNODEPTR symtable[SYMBOLTABLESIZE];
extern int curSymSize;


%}
%option noyywrap
%option nounput yylineno

%%

"stop" return STOP;
"iter" return ITER;



"scanf"     return SCANF;
"printf"    return PRINTF;
"main"      return MAIN;
"if"        return IF;
"then"      return THEN;
"let"       return LET;

"func"      return FUNC;
"//"	    return COMMENT; printf("\n");
"start"     return START;
"="         return ASSIGN;
"=<"        return LE;
"=>"        return GE;
":"         return COLON;
"+"         return PLUS;
"-"         return MINUS;
"*"         return MULT;
"/"         return DIV;
"%"         return MOD;
"."         return DOT;
"("         return RPAREN;
")"         return LPAREN;
","         return COMMA;
"{"         return RBRACE;
"}"         return LBRACE;
";"         return SEMICOLON;
"["         return LBRACK;
"]"         return RBRACK;
"=="	    return EQUAL;


[A-Z][a-z]*             { printf("SYNTAX ERROR: Identifiers must start with lower case. "); }
[a-zA-Z][_a-zA-Z0-9]*	{
                            printf("string: %s \n", yytext);
                            yylval.iVal = addSymbol(yytext);
                            return ID;
                        }
[0-9]+		            {
                            yylval.iVal = atoi(yytext);
                            printf("num: %s \n", yytext);
                            return NUMBER; }
[ _\t\r\s\n]			;
^"#".+$			        return COMMENT;

.			            {printf("ERROR: Invalid Character "); yyterminate();}
<<EOF>>                 { printf("EOF: line %d\n", yylineno); yyterminate(); }
%%

// stores all variable id is in an array

SYMTABNODEPTR newSymTabNode()
{
	return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int addSymbol(char *s)
{
	extern SYMTABNODEPTR symtable[SYMBOLTABLESIZE];
	extern int curSymSize;
	int i;
	i = lookup(s);
	if(i >= 0){
		return(i);
	}
	else if(curSymSize >= SYMBOLTABLESIZE)
	{
		return (NOTHING);
	}
	else{
		symtable[curSymSize] = newSymTabNode();
		strncpy(symtable[curSymSize]->id,s,IDLENGTH);
		symtable[curSymSize]->id[IDLENGTH-1] = '\0';
		return(curSymSize++);
	}
}
int lookup(char *s)
{
	extern SYMTABNODEPTR symtable[SYMBOLTABLESIZE];
	extern int curSymSize;
	int i;
	for(i=0;i<curSymSize;i++)
	{
		if(strncmp(s,symtable[i]->id,IDLENGTH) == 0){
			return (i);
		}
	}
	return(-1);
}
// used to wrap all the lexical rules



