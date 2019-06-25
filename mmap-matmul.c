#include <stdio.h>
#include <malloc.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <time.h>

extern int errno;

void create_matrix(double ***mat, int size)
{
    int i = 0, j = 0;
    double *data = NULL;

    *mat = (double **)mmap(NULL, sizeof(double *),
            PROT_READ| PROT_WRITE, 
            MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
    // printf("Setting address mapping to 0x%lx\n", (unsigned long)(*mat));
    
    data = (double *)mmap(NULL, sizeof(double) * size * size,
            PROT_READ | PROT_WRITE,
            MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);

    if ( data == (void *) -1)
    {
        perror("Failed to allocate memory");
        exit(1);
    }

    // printf("Setting data address to 0x%lx\n", (unsigned long) data);
    for (i = 0; i < size; ++i)
        (*mat)[i] = data + i * size;

    for ( i = 0; i < size; ++i)
    {
        for (j = 0; j < size; ++j)
        {
            (*mat)[i][j] = rand() % 1000;
        }
    }
}

void read_matrix(double **matrix, int size)
{
    int i, j;
    for (i=0; i < size; ++i)
        for (j = 0; j < size; ++j)
            matrix[i][j] = matrix[i][j];
}

void mat_mul(double **A, double **B, double **C, int size)
{
    int i,j,k;

    for (i = 0; i < size; ++i)
    {
        for (j = 0; j < size; ++j)
        {
            for (k = 0; k < size; ++k)
            {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
}

void free_matrix(double ***mat, int size)
{
    munmap((*mat)[0], size * size * sizeof(double));
    munmap(*mat, sizeof(double *));
}

int main(int argc, char **argv)
{
    int SIZE = 512;
    double **matrix, **B, **C;
    int i, j;

    if (argc >= 2) 
        SIZE = atoi(argv[1]);

    srand(time(NULL));
    create_matrix(&matrix, SIZE);
    create_matrix(&B, SIZE);
    create_matrix(&C, SIZE);

    mat_mul(matrix, B, C, SIZE);
    read_matrix(C, SIZE);

    // sleep(100);
    free_matrix(&matrix, SIZE);
    free_matrix(&B, SIZE);
    free_matrix(&C, SIZE);
    return 0;
}
