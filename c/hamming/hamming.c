#include "hamming.h"
#include <stdbool.h>

int compute(const char *lhs, const char *rhs)
{
    int diff_count = 0;

    char a;
    char b;
    do {
        a = *lhs++;
        b = *rhs++;

        if ((a | b) == 0)
        {
            break;
        } else if ((a & b) == 0) {
            return -1;
        }

        diff_count += (a != b);
    } while (true);

    return diff_count;
}