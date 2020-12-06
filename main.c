#define BUF_SIZE 1024
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



extern FILE* yyin;
extern yyparse();

int main(int argc, char* argv[]){

    if(argc < 2){
        FILE* fp = fopen("temp.txt", "a");

        printf("Entering data: \n");


        void *content = malloc(BUF_SIZE);

        if (fp == 0)
            printf("error opening file");

        int read;
        while ((read = fread(content, BUF_SIZE, 1, stdin))){
            fwrite(content, read, 1, fp);
        }
        if (ferror(stdin))
            printf("There was an error reading from stdin");
        fclose(fp);

        yyparse(fp);
    }

    if(argc == 2){

        yyin = fopen(argv[1], "r");

        if(!yyin)
        {

            perror(argv[1]);
            printf("ERROR: file does not exist.\n");
            return 0;

        }

        yyparse (yyin);
    }
    return 0;
}
void yyerror(char *s){
    fprintf(stderr, "error: exiting %s \n", s);
}
