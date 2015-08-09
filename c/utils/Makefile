# compiler to use
CC = clang

# flags to pass compiler
CFLAGS = -ggdb3 -std=c99 -Wall -Werror

# name for executable
EXE = options

# space-separated list of header files
HDRS = input.h

# space-separated list of libraries, if any,
# each of which should be prefixed with -l
LIBS =

# space-separated list of source files
SRCS = options.c input.c

# automatically generated list of object files
OBJS = $(SRCS:.c=.o)

# default target
$(EXE): $(OBJS) $(HDRS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS)

# dependencies
$(OBJS): $(HDRS) Makefile

# housekeeping
clean:
	rm -f core $(EXE) *.o
