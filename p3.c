
#include "p3.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>




void insert(const char* arr, const char* node){
    strcat(arr, node);
}


bool verify(const char* arr, const char* node){

        if(strstr(arr, node) != NULL) {
            printf("Gotcha!\n");

        }
        else{
            printf("not found\n");
        }
}