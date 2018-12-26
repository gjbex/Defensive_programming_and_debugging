# Arithmetic bugs

Given that computing numerical results is at the heart of almost all scientific software, this category of bugs is quite important. The primary source of issues is that you will be thinking in mathematical terms, rather than computational terms.


## Integers

In mathematics, the set of integer number is infinite, while in most programming languages, integers are represented by 8, 16, 32 or 64 bits.  For simplicity, we will only consider 32 bit integers, but the same argument holds for the other representations.


### Overflow

This means that the largest signed integer that can be represented using 32 bits is `2^31 - 1`.  The smallest signed 32 bits integer is `-2^31`.

Adding 1 to that number causes a numerical overflow, and will result in a negative number, `-2^31`. Obviously, all further computations based on that result are meaningless.  The situation is of course symmetric, similar problems will arise when substracting 1 from the smallest integer.

Integer numerical overflow can be trapped at runtime using compiler flags.


### Divide by zero

Interestingly, an integer division by zero will result in runtime error due to a floating point exception.  The application will crash.


## Real numbers

For real numbers, the situation is more complicated.  Again, in mathematics the set of real number is infinite, but there are infinitely many real numbers between any given two real numbers as well.  Real numbers are represented as floating point numbers with 16 bits (half precision), 32 bits (single precision), 64  bits (double precision), or 128 bits (quadruple precision).  This implies that almost no real number can be represented exactly as a floating point number, which has a number of unpleasant consequences.

For simplicity, we will only discuss the 32 bit (single precision) representation, the same arguments hold for all other representations with the corresponding values for the constants involved.


### Overflow

Just like for integers, overflow can be an issue. The largest floating point number is `3.40282347E+38`. When a computation results in a number larger than this value, an overflow occurs, and the result will be `Infinity`.  All further computations will results in either infinity, or `NaN` (Not a Number).


### Underflow

The smallest strictly positive floating point number that can be represented is `1.17549435E-38`.  Computations that result in smaller strictly positive values will be rounded to zero, which is an underflow.  This type of problem is of course harder to spot.  The result might genuinely be zero, so this situation has to be handled with care if it can arise.  Underflow may be the result of multiplying two small floating point numbers.  Just like for overflow, underflow illustrates that associativity may not always hold.  For example, consider

~~~~
(1.0E20 * 1.0E-20) * (1.0E-20 * 1.0E20)
~~~~

versus

~~~~
1.0E20 * (1.0E-20 * 1.0E-20) * 1.0E20
~~~~

The first expression evaluates to 1.0, the second to 0.0, although they are mathematically equivalent.

Another source of numerical underflow would be applying the `exp` function to a large negative number.


### Round off & loss of precision

Round off errors can also have unpleasant consequences.  The smallest floating point value that can be added to 1 such that the result is different from 1 is `1.19209290E-07`., so in single precision, `1.0 + 1.0E-08` would be rounded to `1.0`.

Round off also implies that the addition of floating point numbers is not associative, i.e., `a + (b + c)` is not necessarily equal to `(a + b) + c`. It is especially important that you realize this when adding many floating point numbers that have different orders of magnitude.  As a trivial illustration, consider the following two expressions:

~~~~c
(1.0 + 7.0E-08) + 7.0E-08
~~~~

versus

~~~~c
1.0 + (7.0E-08 + 7.0E-08)
~~~~

From a mathematical point of view, they should yield the same result, however, this is not the case for floating point numbers.

Although in general this is fairly innocent, it may lead to entirely wrong results when the numerical algorithm is not robust against this issue.  You may solve the issue by choosing a more precise floating point representation, but that will come at a price.  Your application will require more memory to store the data, and the performance may be impacted by as much has a factor of 2.  Usually, it pays to check whether another algorithm may be a better solution.


### Divide by zero and invalid operations

Dividing a floating point number by zero results in `Infinity`, and no exception is thrown by default.  Division by zero can be caught at runtime when using GCC's sanitizer.

Similar, operations that are invalid, e.g., `sqrt(-1.0)` will result in `NaN` (Not a Number), while your application will happily continue to compute nonsense.
