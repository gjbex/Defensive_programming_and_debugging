# Python documentation

In Python, documentation is a first-class citizen.  Although you
can use tools such as doxygen for a Python code base, it is
actually part of the language itself.

You can document a function simply by providing its documentation
as a string, e.g.,

```python
def factorial(n):
    '''Compute the factorial of a positive integer

    Parameters
    ----------
    n : int
        positive integer to compute the factorial of.

    Returns
    -------
    int
        the factorial of n, i.e., n!

    Raises
    -----
    ValueError
        for strictly negative argument values

    Examples
    --------
    >>> factorial(5)
    120
    >>> factorial(0)
    1
    '''
    if n < 0:
        raise ValueError()
    return 1 if n <= 2 else n*factorial(n - 1)
```

This is called a docstring in Python parlance.  It will be
displayed when you call the `help` function in ipython or
jupyter notebooks, or shown as a tool tip in an IDE.

There are a number of conventions to format function-level
documentation.  The example above is the style used by the
numpy/scipy projects.  As such, any convention will do as
long as you are consistent.

## Structure of function documentation

The example above is fairly typical.  It consists of a
description of the functions purpose and behavior, and a
number of sections such as `Parameters`, `Returns`,
`Raises`, `Notes` and `Examples`.  Of course, each of those sections
is optional, but it makes a lot of sense to add at least
`Parameters` and `Returns`.

## Other documentation

Besides functions you can document the following syntactic units
using docstrings:

1. functions
1. classes
1. methods in classes
1. modules
1. packages

Modules are documented by adding a docstring at the top of the file, the
documentation of packages is added to the `__init__.py` file that is
required for Python to recognize a directory as a Python package.

## doctest

You may have noticed that the format of the `Examples` section in our
example above was special.  The statements were prefixed by `>>>`.
This can be used for testing purposes, i.e., if you run your script
or module, say `my_code.py` as follows, these statements will be
evaluated:
```bash
$ python  -m doctest  my_code.py
```

All lines in docstrings that are prefixed by `>>>` will be executed,
and the output is compared to the string output below.

*Note:* This is a simple string comparison which limits the scope of
doctest to very simple cases.  Additionally, the comparison is purely
a string comparison, making it tedious to test functions that return
floating point values due to rounding issue.

More comprehensive tests are often required, and Python has a number of
unit testing frameworks to accomplish this, e.g., `unittest` as part of
Python's standard library, and `pytest` that follows more modern design
patterns and is easier to use. 
