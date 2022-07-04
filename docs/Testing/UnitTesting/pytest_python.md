# Pytest

Pytest is a modern and versatile unit testing framework for Python.
Although it is not part of Python's standard library, it is easy to
install using your favorite environment manager.

The standard library contains `unittest`, a framework that is more
akin to unit testing framwwrks such as `CUnit`.


## Simple tests

By default, pytest expects your unit tests to be in files that have
names starting with `test_`.  When you run `pytest` from the command line,
it will scan the working directory for such files, and executes the tests
it finds in them.  You should import the `pytest` module in such files.

Tests are essentially functions that have names starting with `test_` as
well.  To verify assumptions, pytest relies on the assert keyword.  For
instance, consider the following function under test:

```python
def fac(n):
    if n == 0 or n == 1:
        return 1;
    elif n >= 2:
        result = 1
        for i in range(2, n + 1):
            result *= i;
        return result
    else:
        raise ValueError('fac argument must be positive')
```

You can write a test for the "normal" behavior, i.e., when the `fac` function
is called with arguments that are not edge cases.

```python
def test_normal():
    assert fac(2) == 2
    assert fac(3) == 6
    assert fac(4) == 24
    assert fac(5) == 120
```

Additionally, you can test for the edge cases.  It probably makes sense to
write two tests, one for 0, the other for 1.

```python
def test_edge_case_0():
    assert fac(0) == 1

def test_edge_case_1():
    assert fac(1) == 1
```


## Exceptions

The `fac` example function above raises an exception.  Since this is part of the
error handling, i.e., the normal behavior of the function, you should test for it
as well.  pytest uses a context manager for this purpose.

```python
def test_exception():
    with pytest.raises(ValueError):
        _ = fac(-1)
```


## Floating point values

Obviously, you should not assert equality for floating point numbers since they
are subject to rounding differences.  The `math` module in Python's standard
library has a very useful function for this purpose: `isclose`.

```python
def distance(p1, p2):
    return math.sqrt((p1[0] - p2[0])**2 + (p1[0] - p2[0])**2)
```

You could write the following test:

```python
def test_distance():
    assert math.isclose(5.0, distance((0.0, 4.0), (3.0, 0.0)))
```

The optional arguments `rel_tol` and `abs_tol` allow you to control the
accuracy of the comparison, i.e., it allows for a relative or absolute margin
respectively.


## Fixtures

Although unit tests should be designed to be independent of one another, it
is sometimes useful or even necessary to creae a fixture.  For instance, an
n artifact to test may be expensive to create

Fixtures can be defined for various scopes, `function` (default), `class`,
`module`, `package` and `session`.  Here, we will discuss only `function` and
`module`, the other scopes are similar.

A fixture is defined by a function that sets up the fixture, and use `yield` to
return it.  The statements after `yield` will tear down the fixture.  The
example below creates a file with a given number of lines and words oin its
setup part, and removes it in the tear down part.  Since this file should be
used by several tests, its scope is `module`.

```python
import pathlib
...
@pytest.fixture(scope='module')
def text_file():
    file_path = Path('my_text.txt')
    nr_lines, nr_words = 10, 0
    with open(file_path, 'w') as out_file:
        for line_nr in range(nr_lines):
            print(' '.join(['bla']*(line_nr + 1)), file=out_file)
            nr_words += line_nr + 1
    yield file_path, nr_lines, nr_words
    file_path.unlink()
```

This fixture will be set up before the first test in the module is executed,
and it will be torn down after the last test in the module was executed. Now
you can define two tests for the Linux `wc` command called 

```python
import subprocess
...
def test_wc_l(text_file):
    path, nr_lines, _ = text_file
    output = check_output(['wc', '-l', path])
    lines, _ = output.decode(encoding='utf-8').split()
    assert int(lines) == nr_lines

def test_wc_w(text_file):
    path, _, nr_words = text_file
    output = check_output(['wc', '-w', path])
    words, _ = output.decode(encoding='utf-8').split()
    assert int(words) == nr_words
```

Note that the fixture is passed as an argument to the test functions, you
simply specify the name of the function that sets up and tears down the fixture
as name of the argument passed to the filter.  If the function returns multiple
values, they willl be passed to the test as a tuple.

Since unit testing frameworks typically can execute tests in any order, your
test should be independent.  That is exactly why `function` scope is the
default for pytest.

Consider the following trivial example.  The fixture will simply set up a list
of 5 numbres.

```python
@pytest.fixture
def non_empty_list():
    return list(range(5)) 
```

Suppose you would like to test whether adding and removing elements to this
list work as expected, you would define two tests.

```python
def test_pop(non_empty_list):
    orig_len = len(non_empty_list)
    assert non_empty_list[-1] == orig_len - 1
    non_empty_list.pop()
    assert len(non_empty_list) == orig_len - 1
    assert non_empty_list[-1] == orig_len - 2


def test_append(non_empty_list):
    orig_len = len(non_empty_list)
    assert non_empty_list[-1] == orig_len - 1
    non_empty_list.append(orig_len)
    assert len(non_empty_list) == orig_len + 1
    assert non_empty_list[-1] == orig_len
```

Since the `non_empty_list` fixture has function scope, the list is set
up before each test in the module.  After each test, it will be torn
down (for this example, there is no tear down required).  This implies
that the `test_pop` and `test_append` can be executed in any order.
