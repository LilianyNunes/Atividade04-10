// kernel_parallel.cu
#include <iostream>
#include <cstdlib>
#include <chrono>
#include <cuda.h>

#define N 100000 // Tamanho da matriz/vetor

__global__ void multiplicacaoMatrizVetorKernel(float* matriz, float* vetor, float* resultado, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
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

    float* d_matriz, * d_vetor, * d_resultado;
    cudaMalloc(&d_matriz, bytes);
    cudaMalloc(&d_vetor, bytesVetor);
    cudaMalloc(&d_resultado, bytesVetor);

    cudaMemcpy(d_matriz, h_matriz, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_vetor, h_vetor, bytesVetor, cudaMemcpyHostToDevice);

    int blockSize = 100000; // Pode ser alterado para 512 se desejado
    int gridSize = (n + blockSize - 1) / blockSize; // Número de blocos

    // Teste de tempo
    auto inicio = std::chrono::high_resolution_clock::now();
    multiplicacaoMatrizVetorKernel << <gridSize, blockSize >> > (d_matriz, d_vetor, d_resultado, n);
    cudaDeviceSynchronize();
    auto fim = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float> duracao = fim - inicio;

    // Copiar resultado para a memória do host (sem exibir)
    cudaMemcpy(h_resultado, d_resultado, bytesVetor, cudaMemcpyDeviceToHost);

    std::cout << "Tempo de execução (Paralelo): " << duracao.count() << " segundos\n";

    // Liberar memória
    cudaFree(d_matriz);
    cudaFree(d_vetor);
    cudaFree(d_resultado);
    free(h_matriz);
    free(h_vetor);
    free(h_resultado);

    return 0;
}
