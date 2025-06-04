int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

#define STDIN_FD  0
#define STDOUT_FD 1

void decimal_to_hexadecimal(int decimal, char * formated_hex){
    int n = decimal;
    char hexadecimal[9];
    int i = 0;
    while(n!=0){
        int temp = 0;
        temp = n % 16;
        if(temp < 10){
            hexadecimal[8-i] = temp + 48;
        }
        else{
            hexadecimal[8-i] = temp + 55;
        }
        n = n / 16;
        i++;
    }
    formated_hex[0] = '0';
    formated_hex[1] = 'x';
    formated_hex[2+i] = '\n';
    // formated_hex[2+i+1] = '\0';
    for (int j = i; j>0; j--){
        formated_hex[2-j+i] = hexadecimal[9-j];
    }
}

void decimal_to_binary(int decimal, char * formated_bin){
    int n = decimal;
    char binary[35];
    int i = 0;
    while(n!=0){
        binary[34-i] = n % 2 + '0';
        n = n / 2;
        i++;
    }
    formated_bin[2+i] = '\n';
    formated_bin[0] = '0';
    formated_bin[1] = 'b';
    for (int j = i; j>0; j--){
        formated_bin[2-j+i] = binary[35-j];
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

void negative_decimal_to_binary(int decimal, char *formated_bin) {

    // Step 1:Initialize the formated_bin array
    formated_bin[0] = '0';
    formated_bin[1] = 'b';
    formated_bin[34] = '\n';

    // Step 2: Convert the absolute value to binary (ignoring the sign)
    for (int i = 33; i >= 2; i--) {
        formated_bin[i] = (decimal % 2) ? '1' : '0';
        decimal /= 2;
    }

    // Step 3: Invert all the bits for 2's complement
    for (int i = 2; i < 34; i++) {
        formated_bin[i] = (formated_bin[i] == '0') ? '1' : '0';
    }

    // Step 4: Add 1 to the inverted bits (2's complement)
    for (int i = 33; i >= 2; i--) {
        if (formated_bin[i] == '0') {
            formated_bin[i] = '1';
            break;
        } else {
            formated_bin[i] = '0';
        }
    }
}

void negative_decimal_to_hexadecimal(int decimal, char *formated_hex) {
    // Initialize the hexadecimal string with '0's
    for (int i = 0; i < 11; i++) {
        formated_hex[i] = '0';
    }
    formated_hex[0] = '0';
    formated_hex[1] = 'x';
    formated_hex[10] = '\n';

    // Convert the decimal to hexadecimal manually
    for (int i = 9; i >= 2; i--) {
        int hex_digit = decimal % 16;
        decimal /= 16;

        if (hex_digit < 10) {
            formated_hex[i] = '0' + hex_digit;
        } else {
            formated_hex[i] = 'A' + (hex_digit - 10);
        }
    }

    // Invert the bits (1's complement)
    for (int i = 2; i < 10; i++) {
        char c = formated_hex[i];
        switch(c){
            case '0':
                formated_hex[i] = 'F';
                break;
            case '1':
                formated_hex[i] = 'E';
                break;
            case '2':
                formated_hex[i] = 'D';
                break;
            case '3':
                formated_hex[i] = 'C';
                break;
            case '4':
                formated_hex[i] = 'B';
                break;
            case '5':
                formated_hex[i] = 'A';
                break;
            case '6':
                formated_hex[i] = '9';
                break;
            case '7':
                formated_hex[i] = '8';
                break;
            case '8':
                formated_hex[i] = '7';
                break;
            case '9':
                formated_hex[i] = '6';
                break;
            case 'A':
                formated_hex[i] = '5';
                break;
            case 'B':
                formated_hex[i] = '4';
                break;
            case 'C':
                formated_hex[i] = '3';
                break;
            case 'D':
                formated_hex[i] = '2';
                break;
            case 'E':
                formated_hex[i] = '1';
                break;
            case 'F':
                formated_hex[i] = '0';
                break;
    }
}

    // Add 1 to complete 2's complement
    for (int i = 9; i >= 2; i--) {
        if (formated_hex[i] == 'F') {
            formated_hex[i] = '0';
        } else {
            if (formated_hex[i] >= '0' && formated_hex[i] <= '8') {
                formated_hex[i] += 1;
            } else if (formated_hex[i] >= 'A' && formated_hex[i] <= 'E') {
                formated_hex[i] += 1;
            }
            break;
        }
    }
}

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
        return -value;
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

void num_to_str(int num, char *str){
    unsigned int n = num;
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

int main()
{
  char str[11];
  int num = read(STDIN_FD, str, 20);
  // Check if the number is hexadecimal
  if (str[1] == 'x'){
    //hexadecimal_to_binary(str, bin);
    int n;
    add_zeros(str);
    // n can be negative
    n = hexadecimal_to_decimal(str);
    char str_decimal[11];
    num_to_str(n, &str_decimal);
    if (n>0){
        write(STDOUT_FD, str_decimal, 11);
    }
    else{
        char neg_dec_str[12];
        neg_dec_str[0] = '-';
        for (int i = 0; i < 11; i++){
            neg_dec_str[i+1] = str_decimal[i];
        }
        write(STDOUT_FD, neg_dec_str, 12);
    }
    write(STDOUT_FD, str, num);
  }

  else{
    // If the number is in the decimal format
    if (str[0]!='-'){
        // The number is positive
        int n = str_to_num(str);
        char bin[35];
        decimal_to_binary(n, bin);
        write(STDOUT_FD, bin, 35);
        write(STDOUT_FD, str, num);
        char hex[11];
        decimal_to_hexadecimal(n, hex);
        add_zeros(hex);
        write(STDOUT_FD, hex, 11);
    }
    else{
        // The number is negative
        int n = str_to_num(&str[1]);
        char bin[35];
        negative_decimal_to_binary(n, bin);
        write(STDOUT_FD, bin, 35);
        write(STDOUT_FD, str, num);
        char hex[11];
        negative_decimal_to_hexadecimal(n, hex);
        write(STDOUT_FD, hex, 11);
    }
  }
  return 0;
}