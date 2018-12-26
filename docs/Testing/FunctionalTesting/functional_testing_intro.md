# Intorudction to integration testing

Unit testing is a great help during the development process. It iwll help us spot problems introduced by code changes immediately after they have been introduced. They help test the functionality at the level of individual functions and methods.

However, to test an entire application that is, e.g., run from the command line with various parameters, unit tests are not really the right tool. The literature on software development refers to this type of testing as integration testing. Tests are more coarse grained, and are likely to take longer to run than you are comfortable with during an intensive edit/test/commit development cycle.

Hence it is acceptable to run integration tests less often, for instance only when a feature has been added to the software, or a bug has been fixed that may have involved a considerable number of file edits and commits. We rely on unit testing to ensure that this process didn't break low-level integrity of the code.

Although ideally, integration testing would be done automatically for a release with an online tool such as Travis CI for continuous integration, this would lead us too far. In this section we will discuss how to use `shunit2` to test command line applications.

We will illustrate how integration testing can detect code defects that would go unnoticed by unit testing, showing that both testing strategies are complementing one another.
