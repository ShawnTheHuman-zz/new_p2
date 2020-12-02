%{
#define YYERROR_VERBOSE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern char *yytext;
extern int yylex();
extern void yyerror(char *);
extern int yyparse();
extern FILE *yyin;
/* ------------- some constants --------------------------------------------- */

#define SYMBOLTABLESIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

#ifdef DEBUG
char *NodeName[] =
{
    "PROGRAM", "BLOCK", "VARS", "EXPR", "N", "A", "R", "STATS", "MSTAT", "STAT",
    "IN", "OUT", "IF_STAT", "LOOP", "ASSIGN", "RO", "IDVAL", "NUMVAL"
};
#endif

enum ParseTreeNodeType
{
    PROGRAM, BLOCK, VARS, EXPR, N, A, R, STATS, MSTAT, STAT,
    IN, OUT,IF_STAT, LOOP, ASSIGN, RO, IDVAL, NUMVAL
};


#define TYPE_CHARACTER "char"
#define TYPE_INTEGER "int"
#define TYPE_REAL "double"

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

// definitions for parse tree

struct treeNode {
    int item;
    int nodeID;
    struct treeNode *first;
    struct treeNode *second;
};

typedef struct treeNode TREE_NODE;
typedef TREE_NODE *TREE;

TREE makeNode(int, int, TREE, TREE);

#ifdef DEBUG
void printTree(TREE, int);
#endif

// symbol table definitions.
struct symbolTableNode{
    char id[IDLENGTH];
};
typedef struct symbolTableNode SYMTABNODE;
typedef SYMTABNODE	*SYMTABNODEPTR;
SYMTABNODEPTR symtable[SYMBOLTABLESIZE];
int curSymSize = 0;


%}

%start program

%union {
    char *sVal;
    int iVal;
    TREE tVal;
}


// list of all tokens

%token SEMICOLON GE LE EQUAL COLON RBRACK LBRACK ASSIGNS LPAREN RPAREN COMMENT
%token DOT MOD PLUS MINUS DIV MULT RBRACE LBRACE START MAIN STOP LET COMMA
%token SCANF PRINTF IF ITER THEN FUNC

%left MULT DIV MOD ADD SUB

// tokens defined with values and rule names
%token<iVal> NUMBER ID
//%token<sVal> ID
%type<tVal> program type block vars expr N A R stats mStat stat in out if_stat loop assign RO


%%
program   :     START  vars  MAIN  block  STOP
                {
                    TREE tree;
                    tree = makeNode(NOTHING, PROGRAM, $2,$4);
                    #ifdef DEBUG
                    printTree(tree, 0);
                    #endif
                }
;

block   :       RBRACE vars stats LBRACE
                {
                    $$ = makeNode(NOTHING, BLOCK, $2, $3);
                }
 ;
vars    :       /*empty*/
                {
                $$ = makeNode(NOTHING, VARS,NULL,NULL);
                }
                | LET ID COLON NUMBER vars
                {
                    $$ = makeNode($2, VARS, $5,NULL);
                    printf("id: %d", $2);
                }
 ;
//variable:
//                type  ID{$$ = newNode($2,VARIABLE,$1,NULL,NULL);};
//type:
//                INT {$$ = newNode(INT,TYPE,NULL,NULL,NULL);}
//                | BOOL {$$ = newNode(BOOL,TYPE,NULL,NULL,NULL);}
//                | CHAR {$$ = newNode(CHAR,TYPE,NULL,NULL,NULL);}
//                | STRING{$$ = newNode(STRING,TYPE,NULL,NULL,NULL);};
expr         :       N  DIV  expr
                {
                $$ = makeNode(DIV, EXPR, $1, $3);
                }
                |  N  MULT  expr
                {
                $$ = makeNode(MULT, EXPR, $1, $3);
                }
                |  N
                {
                $$ = makeNode(NOTHING, EXPR, $1,NULL);
                }
;
N              :        A  PLUS  N
                {
                $$ = makeNode(PLUS, N, $1, $3);
                }
                |  A MINUS  N
                {
                $$ = makeNode(MINUS, N, $1, $3);
                }
                |  A
                {
                $$ = makeNode(NOTHING, N, $1,NULL);
                        }
 ;
A               :     MOD  A
                {
                        $$ = makeNode(NOTHING, A, $2,NULL);
                }
                |   R
                {
                $$ = makeNode(NOTHING, A, $1,NULL);
                }
;
R               :      LBRACK  expr RBRACK
                {
                $$ = makeNode(NOTHING, R, $2,NULL);
                }
                | ID
                {
                $$ = makeNode($1, IDVAL, NULL,NULL);
                }
                | NUMBER
                {
                $$ = makeNode($1, NUMVAL, NULL,NULL);
                }
 ;
stats          :       stat    mStat
                {
                        $$ = makeNode(NOTHING, STATS, $1, $2);
                }
 ;
mStat           :  /* empty */
                {
                $$ = makeNode(NOTHING, MSTAT, NULL,NULL);
                }
                |   stat    mStat
                {
                        $$ = makeNode(NOTHING, MSTAT, $1, $2);
                }
 ;
stat            :       in  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1,NULL);
                }
                |  out  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1,NULL);
                }
                |  block
                {
                $$ = makeNode(NOTHING, STAT, $1,NULL);
                }
                |  if_stat  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1,NULL);
                }
                |  loop  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1,NULL);
                }
                |  assign  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1,NULL);
                }
;
in               :      SCANF LBRACK ID RBRACK
                {
                        $$ = makeNode($3, IN,NULL,NULL);
                }
;
out             :        PRINTF LBRACK  expr  RBRACK
                {
                        $$ = makeNode(NOTHING, OUT,$3,NULL);
                }
;
if_stat         :      IF LBRACK  expr   RO   expr  RBRACK THEN  block
                {
                        $$ = makeNode(NOTHING, IF_STAT, $4, $8);
                }
;
loop           :      ITER LBRACK  expr   RO   expr  RBRACK   block
                {
                $$ = makeNode(NOTHING, LOOP, $4, $7);
                }
;
assign          :      ID  ASSIGNS  expr
                {
                $$ = makeNode($1, ASSIGN, $3,NULL);
                }
;
RO              :      LE
                {
                $$ = makeNode(LE, RO, NULL,NULL);
                }
                | GE
                {
                $$ = makeNode(GE, RO, NULL,NULL);
                }
                |  EQUAL
                {
                $$ = makeNode(EQUAL, RO, NULL,NULL);
                }
                |   COLON COLON
                {
                        $$ = makeNode(EQUAL, RO, NULL,NULL);
                }
 ;

 %%

// node generator
TREE makeNode(int iVal, int nodeID, TREE p1, TREE p2)
{
    TREE t;
    t = (TREE)malloc(sizeof(TREE_NODE));

    t->item = iVal;
    t->nodeID = nodeID;
    t->first = p1;
    t->second = p2;

    //printf("NODE CREATED");
    return(t);
}


// prints the tree with indentation for depth
void printTree(TREE tree, int depth){
    int i;
	if(tree == NULL) return;
	for(i=depth;i;i--)
		printf(" ");
	if(tree->nodeID == NUMBER)
		printf("INT: %d ",tree->item);
	else if(tree->nodeID == IDVAL){
		if(tree->item > 0 && tree->item < SYMBOLTABLESIZE )
			printf("id: %s ",symtable[tree->item]->id);
		else
			printf("unknown id: %d ", tree->item);
	}
	if(tree->item != NOTHING){

		printf("Data: %d ",tree->item);
	}
	// If out of range of the table
	if (tree->nodeID < 0 || tree->nodeID > sizeof(NodeName))
		printf("Unknown ID: %d\n",tree->nodeID);
	else
		printf("%s\n",NodeName[tree->nodeID]);
	printTree(tree->first,depth+2);
	printTree(tree->second,depth+2);

 }




#include "lex.yy.c"