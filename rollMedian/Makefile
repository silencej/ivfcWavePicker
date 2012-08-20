# wangcf's Makefile template.

### specify srcs here. ###
SRCS= main.cpp rollMedian.cpp
GLOBALS= debugMode.h
# PROJ= getRollMed
PROJ= rollMedian
#HEADS= rollMedian.h

### First Rule. ###
.PHONY: all

all: ${PROJ}
#	${MAKE} ${PROJ}


### specify dependency here. ###

# main.o: main.cpp rollMedian.o

# rollMedian.o: rollMedian.cpp


### Specify parameters. ###
CFLAGS= -O2 -g -Wall -I.
LDFLAGS= -Wall
#CFLAGS: -O2, -g, -I
#LDFLAGS: -L -l
CC= g++
OBJS= ${SRCS:.cpp=.o}
MAKE= make
#project.

### Template. ###

.PHONY: exe
exe:
	chmod a+x ${PROJ}

install:
#DEBUG=-O2
#${MAKE} clean
#${MAKE} ${PROJ} DEBUG=-O2 

.PHONY: clean
clean:
#	rm -f ${PROJ}
	rm -rf ${OBJS}
#	-rm getRollMedian.exe

${PROJ}: ${OBJS} ${GLOBALS}
	${CC} ${LDFLAGS} ${OBJS} -o ${PROJ}

%.o: %.cpp ${GLOBALS} %.h
	${CC} ${CFLAGS} -c $<

main.o: main.cpp ${GLOBALS}
	${CC} ${CFLAGS} -c $<

