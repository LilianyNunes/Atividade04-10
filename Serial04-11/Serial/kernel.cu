// kernel_serial.cu
#include <iostream>
#include <cstdlib>
#include <chrono>

#define N 100000 // Tamanho da matriz/vetor

void multiplicacaoMatrizVetor(float* matriz, float* vetor, float* resultado, int n) {
    for (int i = 0; i < n; ++i) {
        float soma = 0.0;
        for (int j = 0; j < n; ++j) {
            soma += matriz[i * n + j] * vetor[j];
        }
        resultado[i] = soma;
    }
}

int main() {
    int n = N;
    size_t bytes = n * n * sizeof(float);
    size_t bytesVetor = n * sizeof(float);

    float* h_matriz = (float*)malloc(bytes);
    float* h_vetor = (float*)malloc(bytesVetor);
    float* h_resultado = (float*)malloc(bytesVetor);

    // Inicialização aleatória da matriz e vetor
    for (int i = 0; i < n; ++i) {
        h_vetor[i] = rand() % 100;
        for (int j = 0; j < n; ++j) {
            h_matriz[i * n + j] = rand() % 100;
        }
    }

    // Teste de tempo
    auto inicio = std::chrono::high_resolution_clock::now();
    multiplicacaoMatrizVetor(h_matriz, h_vetor, h_resultado, n);
    auto fim = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float> duracao = fim - inicio;

    std::cout << "Tempo de execução (Serial): " << duracao.count() << " segundos\n";

    free(h_matriz);
    free(h_vetor);
    free(h_resultado);

    return 0;
}
