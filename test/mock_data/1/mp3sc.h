#include "/usr/local/include/mpg123.h"
// ##include <sndfile.h>
#include <stdlib.h>
#include <stdio.h>

extern mpg123_handle * mh;

int mp3sc_cleanup();
int mp3sc_init();

int mp3sc_load_mp3(char * fn);
int mp3sc_load_mp3fd(int fd);

int mp3sc_process_wav(char *fn, double scale);
int mp3sc_process_mp3(char *fn, double scale);

int mp3sc_set_processor(int policy);
#define MP3SC_POLICY_DEFAULT 0
#define MP3SC_POLICY_DIRECT 1
#define MP3SC_POLICY_FILTER_ALPHA 2

struct mp3info
{
    char * fn_orig;
    char * fn;
    
    void * buffer;
    
    int channels;
    int encoding;
    long rate;

    long nsamples;

    int policy;
};


