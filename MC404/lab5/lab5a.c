int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
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
    "li a7, 93           # syscall exit (93) \n"
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

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

void read_int(int *n, char *str){
    int is_negative = 0;
    if (str[0] == '-'){
        is_negative = 1;
    }

    for (int i = 1; i < 5; i++){
        *n = *n * 10 + str[i] - '0';
    }
    if (is_negative){
        *n = -(*n);
    }
}

void pack(int input, int start_bit, int end_bit, int *val) {
    /*
    int input: 1000
    int start_bit: 2
    int end_bit: 3
    int *val: 0
    */
    int n_bits = end_bit - start_bit + 1;
    int mask = 0;
    for (int i = 0; i < n_bits; i++){
        mask = mask | (1 << i);
    }
    int wanted_bits = input & mask;
    wanted_bits = wanted_bits << start_bit;
    *val = *val | wanted_bits;
}

int main() {
    char str[30];
    int n = read(STDIN_FD, str, 30);
    int output = 0;
    int n1 = 0, n2 = 0, n3 = 0, n4 = 0, n5 = 0;
    read_int(&n1, str);
    read_int(&n2, str + 6);
    read_int(&n3, str + 12);
    read_int(&n4, str + 18);
    read_int(&n5, str + 24);
    pack(n1, 0, 2, &output);
    pack(n2, 3, 10, &output);
    pack(n3, 11, 15, &output);
    pack(n4, 16, 20, &output);
    pack(n5, 21, 31, &output);
    hex_code(output);
    return 0;
}