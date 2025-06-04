#include <stdio.h>

int hexadecimal_to_decimal(char *hex) {
    int value = 0;
    int is_negative = (hex[2] >= '8'); // Check if the first bit indicates a negative number
    int i;
    if (is_negative) {
        // Invert the bits (1's complement)
        for (i = 9; i >= 2; i--) {
            char c = hex[i];
            switch(c){
                case '0':
                    hex[i] = 'F';
                    break;
                case '1':
                    hex[i] = 'E';
                    break;
                case '2':
                    hex[i] = 'D';
                    break;
                case '3':
                    hex[i] = 'C';
                    break;
                case '4':
                    hex[i] = 'B';
                    break;
                case '5':
                    hex[i] = 'A';
                    break;
                case '6':
                    hex[i] = '9';
                    break;
                case '7':
                    hex[i] = '8';
                    break;
                case '8':
                    hex[i] = '7';
                    break;
                case '9':
                    hex[i] = '6';
                    break;
                case 'A':
                    hex[i] = '5';
                    break;
                case 'B':
                    hex[i] = '4';
                    break;
                case 'C':
                    hex[i] = '3';
                    break;
                case 'D':
                    hex[i] = '2';
                    break;
                case 'E':
                    hex[i] = '1';
                    break;
                case 'F':
                    hex[i] = '0';
                    break;
            }
        }
        // Add 1 to complete 2's complement
        for (i = 9; i >= 2; i--) {
            if (hex[i] == 'F') {
                hex[i] = '0';
            } else {
                if (hex[i] >= '0' && hex[i] <= '8') {
                    hex[i] += 1;
                } else if (hex[i] >= 'A' && hex[i] <= 'E') {
                    hex[i] += 1;
                }
                break;
            }
        }
        for (i = 2; i <= 9; i++) {
            value = value * 16; // Shift the current value by 4 bits (equivalent to multiplying by 16)

            if (hex[i] >= '0' && hex[i] <= '9') {
                value += hex[i] - '0'; // Convert '0'-'9' to 0-9
            } else if (hex[i] >= 'A' && hex[i] <= 'F') {
                value += hex[i] - 'A' + 10; // Convert 'A'-'F' to 10-15
            } else if (hex[i] >= 'a' && hex[i] <= 'f') {
                value += hex[i] - 'a' + 10; // Convert 'a'-'f' to 10-15
            }
        }
        return value;
        }
    else{
        // If the number is positive
        for (i = 2; i <= 9; i++) {
            value = value * 16; // Shift the current value by 4 bits (equivalent to multiplying by 16)

            if (hex[i] >= '0' && hex[i] <= '9') {
                value += hex[i] - '0'; // Convert '0'-'9' to 0-9
            } else if (hex[i] >= 'A' && hex[i] <= 'F') {
                value += hex[i] - 'A' + 10; // Convert 'A'-'F' to 10-15
            } else if (hex[i] >= 'a' && hex[i] <= 'f') {
                value += hex[i] - 'a' + 10; // Convert 'a'-'f' to 10-15
            }
        }
        return value;
    }
}


int str_to_num(char *str){
    int n = 0;
    int i = 0;
    while(str[i] != '\n'){
        n = n * 10 + str[i] - '0';
        i++;
    }
    return n;
}

void add_zeros(char *str){
    int num;
    for (int i = 0; i < 11; i++){
        if (str[i] == '\n'){
            num = i;
        }
    }
    if (num == 10){
        return;
    }
    for (int i = 0; i <= num-2; i++){
        str[10-i] = str[num-i];
    }
    for (int i = 0; i < 10-num; i++){
        str[2+i] = '0';
    }  
}

void num_to_str(int num, char *str){
    int n = num;
    char s[11];
    int i = 0;
    while(n!=0){
        s[9-i] = n % 10 + '0';
        n = n / 10;
        i++;
    }
    s[10] = '\n';
    for (int j = i; j>0; j--){
        str[10-j] = s[10-j];
    }
}

int main(){
    char str[11] = "0x545648\n";
    add_zeros(str);
    int decimal;
    decimal = hexadecimal_to_decimal(str);
    char dec_str[11];
    num_to_str(decimal, dec_str);
    printf("%d\n", decimal);
    for (int i = 0; i < 11; i++){
        printf("%c", dec_str[i]);
    }
    return 0;
}