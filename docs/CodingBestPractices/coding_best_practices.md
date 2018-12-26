# Coding best practices: reading material

A number of very simple things go a long way towards improving your code substantially. For good programmers, they are second nature, and you should strive to make them a habit.

In this section, we will use the term function in a very broad sense, simply to keep the text easy to read. In the context of Fortran, a function refers to a program unit, any procedure, either a function or a subroutine. It also refers to a method defined in a class. In the context of C++, we will use the term function for methods as well.

Similarly, we use the term variable for constants, and also for attributes of objects and classes, whenever that doesn't lead to confusion.


## Format your code nicely

To quote Robert C. Martin, "Code formatting is about communication, and communication is the professional developer’s first order of business".

All programming languages have one or possible multiple conventions about how to format source code. For example, consistent indentation of code helps considerably to assess the structure of a function at a glance. For multi-level indentation, always use the same width, e.g., multiples of four spaces.

The convention you have to use is often determined by the community you are working with, like your co-workers.  It is best to stick to that convention, since coding is communicating. If no convention is established, consider introducing one.  The one which is prevalent in the programming language community is most likely to be your best choice.

Whichever convention you follow, be consistent!


## Use language idioms

Linguists use the term "idiom" for an expression that is very specific to a certain language and that cannot be translated literally to another. For instance, the English idiom "it is raining cats and dogs" would translate to "il pleut des cordes" in French.  The corresponding idiom in French is completely unrelated to its counterpart in English. Mastering idioms is one of the requirements for C1 certification, i.e., to be considered to have a proficiency close to that of native speakers.

We observe a similar phenomenon for programming languages. Some syntactic constructs are typical for a specific programming language but, when translated one-to-one into another language, lead to code constructs that are unfamiliar to programmers who are proficient in that language.  The code fragments below illustrate this for Fortran and C.

Although you could write line 4 of the C function below in this way, you most likely wouldn't since it is not idiomatic C.

~~~~c
int factorial(int n) {
    fac = 1;
    for (int i = 2; i <= n; i++)
        fac = fac*i;
    return fac;
}
~~~~

The idiomatic formulation of line 4 would be `fac *= i`.

In Fortran for example, you would write

~~~~fortran
REAL, DIMENSION(10) :: a
...
a = value
~~~~

rather than

~~~~fortran
INTEGER :: i
REAL, DIMENSION(10) :: a
...
DO i = 1, 10
    a(i) = value
END DO
~~~~

Using idioms, i.e., expressions that are particular to a (programming) language, will make your code much easier to interpret correctly by programmers that are fluent in that language.


## Choose descriptive names

In a way, programming is storytelling. The data are the protagonist in the story, and the functions are the actions they take, or what happens to them. Hence variable names should be nouns and functions names should be verbs. If a function returns a property, it should be phrased as a question.

Any editor worth its salt provides completion, so you can't argue in favour of short but less descriptive names to save typing. A long but descriptive name is just a tab character away.

Choosing descriptive names for variables and functions is another aspect that can make reading your code much easier. Consider the following pseudo-code fragment, and although I'll grant that it is something of a caricature, I've seen some in the wild that are not significantly better.

~~~~
f = open(fn, 'r')
for i in f:
    x = get(i)
    if condition(x):
        a = compute(x)
        if a < 3.14:
            do_something(a)
f.close()
~~~~

A key principle of good software design is that of the least surprise. Choosing appropriate names for our variables and functions helps a lot in this respect.


## Keep it *simple*

Ideally, code is simple.  A function should have two levels of indentation at most.  This is advice you'll find in the literature on general purpose programming. Although this is good advice, there are some caveats in the context of scientific computing.

However, the gist is clear: code is as simple as possible, but not simpler.

Even for scientific code, a function has no more lines of code than fit comfortably on your screen. It is all too easy to lose track of the semantics if you can't get an overview of the code. Remember, not everyone has the budget for a 5K monitor.

If you find yourself writing a very long code fragment, ask yourself whether that is atomic, or whether the task it represents can be broken up into subtasks. If so, and that is very likely, introduce new functions for those subtasks with descriptive names. This will make the narrative all the easier to understand.

A function should have a single purpose, i.e., you should design it to do one thing, and one thing only.

For function signatures, simplicity matters as well.  Functions that take many arguments may lead to confusion.  In C and C++, you have to remember the order of the function arguments.  Accidentally swapping argument values with the same type in a function call can lead to interesting debugging sessions.

The same advice applies to Fortran procedures, keep the number of arguments limited.  However, Fortran supports using keyword arguments, a nice feature that makes your code more robust.  Consider the following procedure signature:

~~~fortran
real function random_gaussian(mu, sigma)
    implicit none
    real, intent(in) :: mu, sigma
    ...
end function random_gaussian
~~~

You would have to check the documentation to know the order of the function arguments.  Consider the following four function calls:

  1. `random_gaussian(0.0, 1.0)`: okay;
  1. `random_gaussian(1.0, 0.0)`: not okay;
  1. `random_gaussian(mu=0.0, sigma=1.0)`: okay;
  1. `random_gaussian(sigma=1.0, mu=0.0)`: okay.

The two last versions of this call are easier to understand, since the meaning of the numbers is clear.  Moreover, since you can use any order, it eliminates a source of bugs.

Unfortunately, neither C nor C++ support this feature.


## Limit scope

Many programmers will declare all variables at the start of a block, or even at the start of a function's implementation. This is a syntax requirement in C89 and Fortran.  However, C99 and C++ allow you to declare variables anywhere before their first use. Since the scope of a variable starts from its declaration, and extends throughout the block, that means it is in fact too wide.

Limiting the scope of declarations to a minimum reduces the probability of inadvertently using the variable, but it also improves code quality: the declaration of the variable is at the same location where the variable is first used, so the narrative is easier to follow.

In C++ this may even have performance benefits since a declaration may trigger a call to a potentially expensive constructor.

Fortran requires that variables are declared at the start of a compilation unit, i.e., `PROGRAM`, `FUNCTION`, `SUBROUTINE`, `MODULE`, but Fortran 2008 introduced the `BLOCK` statement in which local variables can be declared. Their scope doesn't extend beyond the `BLOCK`. Modern compilers support this Fortran 2008 feature.

Note that Fortran still allows variables to be implicitly typed, i.e., if you don't declare a variable explicitly, its type will be `INTEGER` if its starts with the characters `i` to `n`, otherwise its type will be `REAL`.

Consider the code fragment below. Since the variables were not declared explicitly, `i` is interpreted as `INTEGER` and `total` as `REAL`. However, the misspelled `totl` is also implicitly typed as `REAL`, initialised to `0.0`, and hence the value of `total` will be `10.0` when the iterations ends, rather than `100.0` as was intended.

~~~~fortran
INTEGER :: i
REAL :: total
DO i = 1, 10
    total = totl + 10.0
END DO
~~~~

To avoid these problems caused by simple typos, use the `IMPLICIT NONE` statement before variable declarations in `PROGRAM`, `MODULE`, `FUNCTION`, `SUBROUTINE`, and `BLOCK`, e.g,

~~~~fortran
IMPLICIT NONE
INTEGER :: i
REAL :: total
DO i = 1, 10
    total = totl + 10.0
END DO
~~~~

The compiler would give an error for the code fragment above since all variables have to be declared explicitly, and `totl` was not.

When developing multithreaded C/C++ programs using OpenMP, limiting the scope of variables to parallel regions makes those variables thread-private, hence reducing the risk of data races. We will discuss this in more detail in a later section.

This recommendation is [mentioned](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-scope) in the C++ core guidelines.


## Be explicit about constants

If a variable's value is not supposed to change during the runtime of a program, declare it as a constant, so that the compiler will warn you if you inadvertently modify its value. In C/C++, use the `const` qualifier, in Fortran, use `PARAMETER`.

If arguments passed to function should be read-only, use `const` in C/C++ code, and `INTENT(IN)` in Fortran. Although Fortran doesn't require that you state the intent of arguments passed to procedures, it is nevertheless wise to do so. The compiler will catch at least some programming mistakes if you do.

However, this is not quite watertight, in fact, one can still change the value of a variable that is declared as a constant in C.  Compile and run the following program, and see what happens.

~~~~c
#include <stdio.h>

void do_mischief(int *n) {
    *n = 42;
}

int main(void) {
    const int n = 5;
    printf("originally, n = %d\n", n);
    do_mischief((int *) &n);
    printf("mischief accomplished, n = %d\n", n);
    return 0;
}
~~~~

In fact, this is [explicitly mentioned](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-casts-const) in the C++ core guidelines.


## Control access

When defining classes in C++ and Fortran, some attention should be paid to accessibility of object attributes. An object's state is determined by its attributes' values, so allowing unrestricted access to these attributes may leave the object in an inconsistent state.

In C++, object attributes and methods are private by default, while structure fields and methods are public.  For Fortran, fields in user defined types and procedures defined in modules are public by default. Regardless of the defaults, it is useful to specify the access restrictions explicitly. It is good practice to specify private access as the default, and public as the exception to that rule.

Interestingly, both Fortran and C++ have the keyword `protected`, albeit with very different semantics.  In Fortran, `protected` means that a variable defined in a module can be read by the compilation unit that uses it, but not modified.  In the module where it is defined, it can be modified though.  In C++, an attribute or a method that is declared `protected` can be accessed from derived classes as well as the class that defines it.  However, like attributes and methods declared `private`, it can not be accessed elsewhere.

This is another example where getting confused about the semantics can lead to interesting bugs.

In summary:

| access modifier | C++                                           | Fortran |
|-----------------|-----------------------------------------------|---------|
| private         | access restricted to class/struct             | access restricted to module |
| protected       | access restricted to class/struct and derived | variables: modify access restricted to module, read everywhere |
| public          | attributes and methods can be accessed from everwhere | variables, types and procedures can be accessed from everywhere |
| none            | class: private, struct: public                | public |


## Variable initialisation

Although Fortran doesn't require you to initialise variables, and will set `INTEGER` and `REAL` to zero for you, it is nevertheless good practice to always initialise variables explicitly. It makes your intent clear. Although C/C++ will likely produce nonsense results when you forget to initialise a variable, the compilers will typically let you get away with it. However, most compilers have optional flags that catch expressions involving uninitialised variables. We will discuss these and other compiler flags in a later section.

When initialising or, more generally, assigning a value to a variable that involves constants, your code will be easier to understand when those values indicate the intended type. For example, using `1.0` rather than `1` for floating point is more explicit. This may also avoid needless conversions. This also prevents arithmetic bugs since `1/2` will evaluate to `0` in C, C++ as well as Fortran.  Perhaps even more subtly, `1.25 + 1/2` will also evaluate to `1.25`, since the division will be computed using integer values, evaluating to `0`, which is subsequently converted to the floating point value `0.0`, and added to `1.25`.


## To comment or not to comment?

Comments should never be a substitute for code that is easy to understand. In almost all circumstances, if your code requires a comment without which it can not be understood, it can be rewritten to be more clear.

Obviously, there are exceptions to this rule. Sometimes we have no alternative but to sacrifice a clean coding style for performance, or we have to add an obscure line of code to prevent a problem caused by over-eager compilers.

If you need to add a comment, remember that it should be kept up-to-date with the code. All too often, we come across comments that are no longer accurate because the code has evolved, but the corresponding comment didn't. In such situations, the comment is harmful, since it can confuse us about the intentions of the developer, and at the least, it will cost us time to disambiguate.

The best strategy is to make sure that the code tells its own story, and requires no comments.

A common abuse of comments is to disable code fragments that are no longer required, but that you still want to preserve. This is bad practice. Such comments make reading the code more difficult, and take up valuable screen real estate.
Moreover, when you use a version control system such as git or subversion in your development process, you can delete with impunity, in the sure knowledge that you can easily retrieve previous versions of your files. If you don't use a version control system routinely, you really should. See the additional material section for some pointers to information and  tutorials.


## Stick to the standard

The official syntax and semantics of languages like C, C++ and Fortran is defined in official specifications. All compilers that claim compliance with these standards have to implement these specifications.

However, over the years, compiler developers have added extensions to the specifications. The Intel Fortran compiler for instance has a very long history that can trace its ancestry back to the DEC compiler, and implements quite a number of Fortran extensions. Similarly, the GCC C++ compiler supports some non-standard features.

It goes without saying that your code should not rely on such compiler specific extensions, even if that compiler is mainstream and widely available. There is no guarantee that future releases of that same compiler will still support the extension, and the only official information about that extension would be available in the compiler documentation, not always the most convenient source.

Moreover, that implies that even if your code compiles with a specific compiler, that doesn't mean it complies with the official language specification. An other compiler would simply generate error message for the same code, and would fail to compile it.

Using language extensions makes code harder to read. As a proficient programmer, you're still not necessarily familiar with language extensions, so you may interpret those constructs incorrectly.

Hence I'd encourage you strongly to strictly adhere to a specific language specification.  For C there are three specifications that are still relevant, C89, C99, and C11.  For C++ that would be C++11, and C++14.  The relevant specification for Fortran are those of 2003 and 2008. References to those specifications can be found in the section on additional material.


## Copy/paste is evil

If you find yourself copying and pasting a fragment of code from one file location to another, or from one file to another, you should consider turning it into a function.  Apart from making your code easier to understand, it makes it also easier to maintain.

Suppose there is a bug in the fragment.  If you copy/pasted it, you would have to remember to fix the bug in each instance of that code fragment.  If it was encapsulated in a function, you would have to fix the problem in a single spot only.
