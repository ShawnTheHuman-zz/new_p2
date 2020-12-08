
#include "p3.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>




void insert(const char* arr, const char* node){
    strcat(arr, node);
    return;
}


bool verify(const char* arr, const char* node){

        if(strstr(arr, node) != NULL) {
            return true;
        }
        else if(strstr(arr, node) == NULL){
                        return false;
        }
}