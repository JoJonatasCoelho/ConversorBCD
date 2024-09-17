#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Função para converter binário para BCD
unsigned short bin_to_bcd(unsigned char bin) {
    unsigned short bcd = 0;
    int shift = 0;
    
    while (bin > 0) {
        // Pega o último dígito do número decimal (binário convertido para decimal)
        bcd |= (bin % 10) << (shift * 4);
        bin /= 10;  // Remove o dígito processado
        shift++;
    }
    
    return bcd;
}

// Função para converter um número em binário para uma string
void bin_to_str(unsigned int num, int bits, char* str) {
    for (int i = bits - 1; i >= 0; i--) {
        str[bits - 1 - i] = (num & (1 << i)) ? '1' : '0';
    }
    str[bits] = '\0';  // Null-terminator
}

int main() {
    // Inicializar gerador de números aleatórios
    srand(time(NULL));

    // Arquivos de entrada e saída
    FILE *input_file = fopen("input_vectors_bcd_sa.txt", "w");
    FILE *output_file = fopen("output_vectors_bcd_sa.txt", "w");

    if (!input_file || !output_file) {
        printf("Erro ao abrir os arquivos.\n");
        return 1;
    }

    // Buffer para armazenar as strings binárias
    char bin_str[9];  // 8 bits + terminador nulo
    char bcd_str[17]; // 16 bits + terminador nulo

    // Gerar 8 valores binários aleatórios entre 10 (0x0A) e 160 (0xA0)
    for (int i = 0; i < 8; i++) {
        unsigned char bin = (rand() % (9999 - 10 + 1)) + 10;  // Valor binário aleatório entre 10 e 9999
        unsigned short bcd = bin_to_bcd(bin);  // Converter para BCD

        // Converter os números binários para strings
        bin_to_str(bin, 8, bin_str);   // Binário de 8 bits
        bin_to_str(bcd, 16, bcd_str);  // BCD de 16 bits

        // Escrever valores nos arquivos
        fprintf(input_file, "%s\n", bin_str);   // Valor binário de entrada
        fprintf(output_file, "%s\n", bcd_str);  // Valor BCD de saída
    }

    // Fechar os arquivos
    fclose(input_file);
    fclose(output_file);

    printf("Arquivos gerados com sucesso.\n");

    return 0;
}
