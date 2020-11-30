%{
#define YYERROR_VERBOSE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern void yyerror(char *);

/* ------------- some constants --------------------------------------------- */

#define SYMBOLTABLESIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

#ifdef DEBUG
char *NodeName[] =
{
    "PROGRAM", "BLOCK", "VARS", "EXPR", "N", "A", "R", "STATS", "MSTAT", "STAT",
    "IN", "OUT", "IF_STAT", "LOOP", "ASSIGN", "RO", "IDVAL", "NUMBERVAL"
};
#endif

enum ParseTreeNodeType
{
    PROGRAM, BLOCK, VARS, EXPR, N, A, R, STATS, MSTAT, STAT,
    IN, OUT,IF_STAT, LOOP, ASSIGN, RO
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
    struct treeNode *third;
};

typedef struct treeNode TREE_NODE;
typedef TREE_NODE *TERNARY_TREE;

TERNARY_TREE makeNode(int, int, TERNARY_TREE, TERNARY_TREE, TERNARY_TREE);

#ifdef DEBUG
void printTree(TERNARY_TREE, int);
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
    char* s;
    int iVal;
    TERNARY_TREE tVal;
}


// list of all tokens

%token SEMICOLON GE LE EQUAL COLON RBRACK LBRACK ASSIGNS LPAREN RPAREN COMMENT
%token DOT MOD PLUS MINUS DIV MULT RBRACE LBRACE START MAIN STOP LET COMMA
%token SCANF PRINTF IF ITER THEN FUNC

%left MULT DIV MOD ADD SUB

// tokens defined with values and rule names
%token<iVal> ID NUMBER
%type<tVal> program block vars expr N A R stats mStat stat in out if_stat loop assign RO


%%
program   :     START  vars  MAIN  block  STOP
                {
                    TERNARY_TREE tree;
                    tree = makeNode(NOTHING, PROGRAM, $2,$4,NULL);
                    #ifdef DEBUG
                    printTree(tree, 0);
                    #endif
                }
;

block   :       RBRACE vars stats LBRACE
                {
                    $$ = makeNode(NOTHING, BLOCK, $2, $3, NULL);
                }
 ;
vars    :       /*empty*/
                {
                $$ = makeNode(NOTHING, VARS, NULL, NULL, NULL);
                }
                | LET ID COLON NUMBER vars
                {
                $$ = makeNode($2, VARS, $5, NULL, NULL);
                }
 ;
expr         :       N  DIV  expr
                {
                $$ = makeNode(DIV, EXPR, $1, $3, NULL);
                }
                |  N  MULT  expr
                {
                $$ = makeNode(MULT, EXPR, $1, $3, NULL);
                }
                |  N
                {
                $$ = makeNode(NOTHING, EXPR, $1, NULL, NULL);
                }
;
N              :        A  PLUS  N
                {
                $$ = makeNode(PLUS, N, $1, $3, NULL);
                }
                |  A MINUS  N
                {
                $$ = makeNode(MINUS, N, $1, $3, NULL);
                }
                |  A
                {
                $$ = makeNode(NOTHING, N, $1, NULL, NULL);
                        }
 ;
A               :     MOD  A
                {
                        $$ = makeNode($2, A, NULL, NULL, NULL);
                }
                |   R
                {
                $$ = makeNode(NOTHING, A, $1, NULL, NULL);
                }
;
R               :      LBRACK  expr RBRACK
                {
                $$ = makeNode(NOTHING, R, $2, NULL, NULL);
                }
                | ID
                {
                $$ = makeNode($1, ID, NULL, NULL, NULL);
                }
                | NUMBER
                {
                $$ = makeNode($1, NUMBER, NULL, NULL, NULL);
                }
 ;
stats          :       stat    mStat
                {
                        $$ = makeNode(NOTHING, STATS, $1, $2, NULL);
                }
 ;
mStat           :  /* empty */
                {
                $$ = makeNode(NOTHING, MSTAT, NULL, NULL, NULL);
                }
                |   stat    mStat
                {
                        $$ = makeNode(NOTHING, MSTAT, $1, $2, NULL);
                }
 ;
stat            :       in  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1, NULL, NULL);
                }
                |  out  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1, NULL, NULL);
                }
                |  block
                {
                $$ = makeNode(NOTHING, STAT, $1, NULL, NULL);
                }
                |  if_stat  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1, NULL, NULL);
                }
                |  loop  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1, NULL, NULL);
                }
                |  assign  DOT
                {
                        $$ = makeNode(NOTHING, STAT, $1, NULL, NULL);
                }
;
in               :      SCANF LBRACK ID RBRACK
                {
                        $$ = makeNode($3, IN, NULL, NULL, NULL);
                }
;
out             :        PRINTF LBRACK  expr  RBRACK
                {
                        $$ = makeNode($3, OUT, NULL, NULL, NULL);
                }
;
if_stat         :      IF LBRACK  expr   RO   expr  RBRACK THEN  block
                {
                        $$ = makeNode(NOTHING, IF_STAT, $4, $8, NULL);
                }
;
loop           :      ITER LBRACK  expr   RO   expr  RBRACK   block
                {
                $$ = makeNode(NOTHING, LOOP, $4, $7, NULL);
                }
;
assign          :      ID  ASSIGNS  expr
                {
                $$ = makeNode($1, ASSIGN, $3, NULL, NULL);
                }
;
RO              :      LE
                {
                $$ = makeNode(LE, RO, NULL, NULL, NULL);
                }
                | GE
                {
                $$ = makeNode(GE, RO, NULL, NULL, NULL);
                }
                |  EQUAL
                {
                $$ = makeNode(EQUAL, RO, NULL, NULL, NULL);
                }
                |   COLON COLON
                {
                        $$ = makeNode(EQUAL, RO, NULL, NULL, NULL);
                }
 ;

 %%

// node generator
TERNARY_TREE makeNode(int iVal, int nodeID, TERNARY_TREE p1,
                      TERNARY_TREE p2, TERNARY_TREE p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));

    t->item = iVal;
    t->nodeID = nodeID;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    //printf("NODE CREATED");
    return(t);
}
#ifdef DEBUG

// prints the tree with indentation for depth
void printTree(TERNARY_TREE  tree, int depth){
    int i;
	if(tree == NULL) return;
	for(i=depth;i;i--)
		printf(" ");
	if(tree->nodeID == NUMBER)
		printf("INT: %d ",tree->item);
	else if(tree->nodeID == ID){
		if(tree->item > 0 && tree->item < SYMBOLTABLESIZE )
			printf("id: %s ",symtable[tree->item]->id);
		else
			printf("unknown id: %d ", tree->item);
	}
	if(tree->item != NOTHING){
		printf("Data: %d ",tree->item);
	}
	if (tree->nodeID < 0 || tree->nodeID > sizeof(NodeName))
		printf("Unknown ID: %d\n",tree->nodeID);
	else
		printf("%s\n",NodeName[tree->nodeID]);
	printTree(tree->first,depth+2);
	printTree(tree->second,depth+2);
	printTree(tree->third,depth+2);
 }
#endif



#include "lex.yy.c"