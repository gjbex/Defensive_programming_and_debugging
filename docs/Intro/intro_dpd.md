# Introduction to defensive programming and debugging

When writing code, it is important to keep in mind the entire life cycle of the project. In the context of research, the initial scope is often just a single experiment. The quality of your code seems a minor concern since science is your core business, and code is just a means to an end.

However, successful research is reproduced and built upon. The original code base will be extended beyond its original scope, either by you or your colleagues.

Of course, the same argument also holds for code developed for business applications.

It is important that you realize that code is more than just telling a piece of hardware what to do. It is also a means of communication with other researchers or developers, including your future self. Indeed, there will be those who actually read your code, and use it as a building block, or even the foundation for their work.

No doubt, you've opened a source file, stared at it for minutes in dismay, wondering "what the heck?"  Obviously, the author failed to clearly communicate his intentions, his reasoning.  Do keep in mind that this author might have been you, a few months previously.

Such experiences should serve as motivation to try to convey your intentions and reasoning clearly. In a way, you can view coding as story telling. So source code should be clear, and pleasant to read. That will make it easy to follow the narrative. By sticking to a few simple rules, you can ensure that you write good code. In this section, we will discuss some coding best practices.

Another potential source of problems is using someone else's software. Quite likely, you already got frustrated at the lack of documentation or relevant examples.  So when you make your own application or library available to others, documentation should be an integral part of the release. Documentation should be clearly written, with ample examples. It should also be up-to-date with the latest version of your code. We will discuss a number of dos and don'ts for writing documentation. We will also introduce some tools to help you generate nicely formatted texts.

Donald Knuth once said "Beware of bugs in the above code; I have only proved it correct, not tried it." You could paraphrase that as follows, "code that has not been tested doesn't work."
Writing good tests is an important part of any sizable software development project. We will cover both unit testing and integration testing since they target specific and complementary aspects of an application. Both testing best practices and testing frameworks will be discussed.
