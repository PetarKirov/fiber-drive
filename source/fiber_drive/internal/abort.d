///
module fiber_drive.internal.abort;

@safe @nogc nothrow pure:

alias enforce_zero = enforce_false;

void enforce_false(T)(T condition, string msg)
{
    enforce(!condition, msg);
}

void enforce(T)(T condition, string msg)
{
    assert (condition, msg);
}
