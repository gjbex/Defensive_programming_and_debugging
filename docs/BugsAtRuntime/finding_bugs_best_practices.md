# Debugging best practices

The debugging process is very often quite ad-hoc.  You don't really know what you are looking for, which makes it hard to follow a systematic approach.  However, there is some advice you can follow to help cut down on the time you spend hunting bugs.


## Reproducibility

The most important thing that makes debugging easier is reproducibility.  When you cannot reliably reproduce a bug, it will be very hard to find.
Scientific code that relies on pseudo-random number generators are a good example of this.  Depending on the sequence of random numbers, the bug may or may not be triggered.  Hence it is useful to ensure that

  * you seed the pseudo-random number generator systematically with the same seed while developing, and
  * that you test with a range of seed values.

Although the latter doesn't guarantee that a lurking bug would be triggered, it at least increases the likelihood a bit.

Some memory-related bugs may only be triggered when the memory is tight, so explicitly maxing out the memory consumption of your code to ensure it should run into trouble allows you to systematically test that this situation is dealt with gracefully. When you add test cases that use long arrays sizes or other large data structures, checking for errors you expect will help.

When dealing with parallel code, you typically loose determinism, so heisenbugs (now you see it, now you don't) can occur.  Typically, there is not much to be done about that.


## Debugging strategies

Trying to solve a problem systematically helps a lot.

An aphorism attributed to Albert Einstein states that "everything should be as simple as it can be, but not simpler".  To simplify the process of identifying a bug, it is good practice to try and reduce the code to the minimum that still exhibits the bug.
Typically, it is not necessary to rewrite your code, but rather to construct a test case that reproduces the problem.
Once the bug is captured in a reproducible test case, it is easier to find and fix. The test case remains in the code base and serves as a regression test.

For longer debug sessions, it may be hard to remember what you've already tried.  Many developers will keep track of their debugging efforts by keeping a log.

An important point that was already raised when we discussed unit testing is the granularity of your development process.  It is more likely that bugs have been introduced in code that was recently added. Hence it is a good idea to add new code in small increments and add tests immediately.  This way the amount of code you have to review is typically limited.
Of course, a bug may actually be triggered by some code that was written a while ago and that is now used in new ways.

A very good way to figure out issues with your code is explaining it to someone else.  You can only explain something you truly understand yourself. While thinking about how to explain it, you are forced to another person's point of view, and typically spot problems more easily.
When no one is at hand, some developers actually explain their code to a rubber duck. I'm quite certain that can be substituted with your favourite teddy bear, though. Although this may sound somewhat ridiculous, it may actually help you.
