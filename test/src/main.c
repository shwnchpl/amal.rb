#include "foo.h"
#include "top-level.h" /* yeah okay */

#include <stdio.h> // foo

int main(void)
{
    foo(2, 6);
    printf("Ok\n");
    return 0;
}
