#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/unistd.h>
#include <malloc.h>

#define NUM_MATRICES 50

void create_matrix(double ***mat, int size)
{
    int i = 0, j = 0;
    double *data = NULL;

    *mat = (double **)malloc(size * sizeof(double *));
    data = (double *)malloc(size * size * sizeof(double));

    for (i=0; i < size; ++i)
    {
        // (*mat)[i] = malloc(sizeof(double));
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


void read_matrix(double **matrix, int size)
{
    int i, j;
    for (i=0; i < size; ++i)
        for (j = 0; j < size; ++j)
            matrix[i][j] = matrix[i][j];
}

void free_matrix(double ***matrix, int size)
{
    free((*matrix)[0]);
    // free(*matrix);
}

int main(int argc, char **argv)
{
    int N = 512, i = 0;
    // double **mat1, **mat2;
    double **matrices[NUM_MATRICES];

    if ( argc >= 2 )
        N = atoi(argv[1]);

    srand(time(NULL));
    // create_matrix(&mat1, N);
    // create_matrix(&mat2, N);

    // read_matrix(mat1, N);
    // read_matrix(mat2, N);

    for (i = 0; i < NUM_MATRICES; ++i)
    {
        create_matrix(&matrices[i], N);
        read_matrix(matrices[i], N);
        // sleep(1);
        free_matrix(&matrices[i], N);
    }

    printf("Allocations complete, partial free done, Sleeping...\n");
    while (1)
    {
        sleep(10);
    }

    return 0;

}
