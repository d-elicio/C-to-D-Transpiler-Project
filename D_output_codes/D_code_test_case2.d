import std.stdio;

int main()
{
    int x = 10;
    int a;
    writeln("value of X: %d\n", x);
    writeln("Insert the value of a: ");
    readf("%d", &a);
    if (x > a)
    {
        writeln("X is greater than A\n");
        writeln("Computation of a=(x*2)+10\n");
        a = x * 2 + 10;
        writeln("\n Value of X: %d\n", x);
        writeln("\n Final value of A: %d\n\n", a);
    }
    else
    {
        if (x < a)
        {
            writeln("A is greater than X\n");
        }
        else
        {
            writeln("A and X are equal");
        }
    }
    return 0;
}
