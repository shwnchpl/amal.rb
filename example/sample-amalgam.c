/********************************************************************
*          AMALGAMATED BY amal.rb AT 2021-06-30T05:25:12Z           *
*********************************************************************/

/******* BEGIN FILE include/top-level.h *******/
#ifndef TOP_LEVEL_H_
#define TOP_LEVEL_H_

#define VESRSION    123

#endif /* TOP_LEVEL_H_ */
/******* END FILE include/top-level.h *******/
/******* BEGIN FILE src/bar.c *******/
/******* BEGIN FILE src/bar.h *******/
#ifndef BAR_H_
#define BAR_H_

/******* BEGIN FILE src/bas/bas.h *******/
#ifndef BAS_H_
#define BAS_H_

struct bas
{
    int a;
    int b;
};

void bas(struct bas *bas, int a, int b);

#endif /* BAS_H_ */
/******* END FILE src/bas/bas.h *******/

void bar(struct bas b);

#endif /* BAR_H_ */
/******* END FILE src/bar.h *******/

#include <stdio.h>

void bar(struct bas b)
{
    printf("%d\n", b.a + b.b);
}
/******* END FILE src/bar.c *******/
/******* BEGIN FILE src/bas/bas.c *******/
/* #include "bas.h" */

void bas(struct bas *bas, int a, int b)
{
    bas->a = a;
    bas->b = b;
}
/******* END FILE src/bas/bas.c *******/
/******* BEGIN FILE src/foo.c *******/
/******* BEGIN FILE src/foo.h *******/
#ifndef FOO_H_
#define FOO_H_

void foo(int a, int b);

#endif /* FOO_H_ */
/******* END FILE src/foo.h *******/
/* #include "bar.h" */
/* #include "bas/bas.h" */

void foo(int a, int b)
{
    struct bas baz;
    bas(&baz, a, b);
    bar(baz);
}
/******* END FILE src/foo.c *******/
/******* BEGIN FILE src/main.c *******/
/* #include "foo.h" */
/* #include "top-level.h" */

/* #include <stdio.h> */

int main(void)
{
    foo(2, 6);
    printf("Ok\n");
    return 0;
}
/******* END FILE src/main.c *******/

/********************************************************************
*                    END amal.rb AMALGAMATED CODE                   *
*********************************************************************/
