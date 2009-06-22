FLAG=-g -O0 -ggdb -Wall -Werror

#MPG123_CFLAGS := $(shell pkgconfig --cflags libmpg123)
#MPG123_LDFLAGS := $(shell pkgconfig --libs   libmpg123)
#MPG123_CFLAGS := --cflags libmpg123
#MPG123_LDFLAGS := --libs   libmpg123

CFLAGS := $(FLAG) $(MPG123_CFLAGS) -Ilibmpg123 -L/usr/local/lib/libmpg123.la -l /usr/local/lib/libmpg123.la -L/usr/local/lib/libmpg123.dll.a
LDFLAGS := $(FLAG) $(MPG123_LDFLAGS) -Ilibmpg123 -L/usr/local/lib/libmpg123.la -l /usr/local/lib/libmpg123.la -L/usr/local/lib/libmpg123.dll.a

all: mp3sc

mp3sc: main.o mp3sc.o 

main.o: main.c

mp3sc.o: mp3sc.c mp3sc.h

.PHONY: all clean

clean:
	rm -rf *.o
	rm -rf mp3sc
