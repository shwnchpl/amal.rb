#include "foo.h"
#include "bar.h"
#include "bas/bas.h"

void foo(int a, int b)
{
    struct bas baz;
    bas(&baz, a, b);
    bar(baz);
}
