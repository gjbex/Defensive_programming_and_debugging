# Taxonomy of bugs: introduction

## Motivation

Consider the work of an entomologist.  To identify an insect, a modern day researcher could simply sample some DNA, have it sequenced, do an assembly and a BLAST.  It would work, be very accurate, and wildly expensive, even at current prices.  It would also take a couple of days, not to mention that most entomologists in the field don't carry a sequencer and a powerful workstation in their backpack.  That is the reason biologists typically still learn how to identify species of interest by their morphological characteristics.  It just requires a careful look and a good memory (and perhaps a book), a few minutes of quality time with a magnifying glass will be all that is required.  Of course, this will not work in all situations.  From time to time, identification will be hard, and that's where the heavy machinery comes in.

You can also think of the work of a physician.  She observes symptoms, and tries to deduce probable causes.  These are just hypotheses, so some additional examinations and experiments will be required to narrow down the options, and try to confirm the actual disease.  You can imagine that without that initial step, i.e., identifying a number of potential diseases based on the symptoms experienced by the patient, you wouldn't be very successful as a doctor.

These two examples illustrate that having a taxonomy in your mind considerably improves your efficiency for many activities.  For a biologist, that would be a taxonomy of the organisms she is interested in.  For the physician, the diseases that are relevant in her field of specialisation.

Although a bug is a bug, there are in fact many types.  When you have a taxonomy in mind, it may help you in several ways.

  * If you can map symptoms to potential causes, this will speed up the debugging process considerably.
  * Some types of bugs will occur in specific stages of development, and realising that helps you to pay extra attention to those types when required.
  * You may not be aware of certain issues and the consequences they can have.  Identifying them will be much harder in that case.

Hopefully, the analogies to the two examples are clear.


## High-level taxonomy

Any taxonomy tends to be a bit fuzzy, and is of course, like everything in science, subject to debate and improvement.  You should view the taxonomy of bugs presented here as a guideline, nothing more.

  * Requirements
  * Structural bugs
  * Arithmetic bugs
  * Bugs in data

In many classification schemes for bugs, arithmetic bugs are considered structural bugs.  However, since this arithmetic bugs are of prime importance in scientific programming, they merit their own category in this course.

Each category will be defined and discussed in turn.
