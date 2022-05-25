FC = gfortran
FFLAGS = -g -Wall -Wextra -Wpedantic
TRAPV_FLAGS = -ftrapv
SANITIZER_FLAGS = -fsanitize=undefined  -fsanitize=signed-integer-overflow -fsanitize-undefined-trap-on-error

all: overflow_test.exe overflow_8_test.exe narrowing_test.exe \
	trapv_overflow_test.exe trapv_overflow_8_test.exe trapv_narrowing_test.exe \
	sanitizer_overflow_test.exe sanitizer_overflow_8_test.exe sanitizer_narrowing_test.exe

SOURCES = $(wildcard *.f90)

trapv_overflow_test.exe: overflow_test.f90
	$(FC) $(FFLAGS) $(TRAPV_FLAGS) -o $@ $<

trapv_overflow_8_test.exe: overflow_8_test.f90
	$(FC) $(FFLAGS) $(TRAPV_FLAGS) -o $@ $<

trapv_narrowing_test.exe: narrowing_test.f90
	$(FC) $(FFLAGS) $(TRAPV_FLAGS) -o $@ $<

sanitizer_overflow_test.exe: overflow_test.f90
	$(FC) $(FFLAGS) $(SANITIZER_FLAGS) -o $@ $<

sanitizer_overflow_8_test.exe: overflow_8_test.f90
	$(FC) $(FFLAGS) $(SANITIZER_FLAGS) -o $@ $<

sanitizer_narrowing_test.exe: narrowing_test.f90
	$(FC) $(FFLAGS) $(SANITIZER_FLAGS) -o $@ $<

%.exe: %.f90
	$(FC) $(FFLAGS) -o $@ $<

clean:
	$(RM) $(wildcard *.exe) $(wildcard *.o)
