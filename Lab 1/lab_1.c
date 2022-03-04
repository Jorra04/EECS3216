#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define STR_SIZE 256
int main() {
    char *str = (char*) malloc(sizeof(char) * STR_SIZE);
    int i;
    while(fgets(str, STR_SIZE, stdin) != NULL) {
        i = 0;
        char* buffer = (char*) malloc(sizeof(char) * STR_SIZE);
        int bufferIndex = 0;
        while(str[i] != ' ') {
            i ++;
        }
        i++;
        for(i; i < strlen(str) && str[i] != ' '; i ++) {
            if(str[i] != '\n') {
                buffer[bufferIndex] = str[i];
                bufferIndex++;
            }       
        }
        printf("%s\n", buffer);
        memset(buffer, 0, sizeof buffer);
    }
    return 0;
}