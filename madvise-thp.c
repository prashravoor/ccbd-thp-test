#include <stdio.h>
#include <malloc.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <time.h>

void create_matrix(double ***mat, int size)
{
    int i = 0, j = 0;
    double *data = NULL;

    if ( posix_memalign((void **)mat, 1UL << 21UL, size * sizeof(double *)) )
       perror("Failed to allocate pointers!");
    // printf("Starting address: 0x%lu\n", (unsigned long)*mat);

    madvise(*mat,
            size * sizeof(double *),
            MADV_HUGEPAGE);

    if ( posix_memalign((void **)&data, 1UL << 21UL, size * size * sizeof(double)) )
       perror("Failed to allocated data!");

    // printf("Data starts: 0x%lu\n", (unsigned long)data);
    madvise(data,
            size * size * sizeof(double),
            MADV_HUGEPAGE);

    for (; i < size; ++i)
    {
        (*mat)[i] = data + i * size;
    }

    for (i = 0; i < size; ++i)
    {
        for (j = 0; j < size; ++j)
        {
            (*mat)[i][j] = rand() % 1000;
        }
    }

}

void free_matrix(double ***mat)
{
    free((*mat)[0]);
    free(*mat);
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

int main(int argc, char **argv)
{
    int SIZE = 512;
    double **matrix, **m2, **m3;

    if (argc >= 2)
        SIZE = atoi(argv[1]);
    srand(time(NULL));
    create_matrix(&matrix, SIZE);
    create_matrix(&m2, SIZE);
    create_matrix(&m3, SIZE);
    mat_mul(matrix, m2, m3, SIZE);
    read_matrix(m3, SIZE);
    // sleep(100);
    free_matrix(&matrix);
    free_matrix(&m2);
    free_matrix(&m3);
    return 0;
}
