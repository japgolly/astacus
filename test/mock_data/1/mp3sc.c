#include "mp3sc.h"

// #include <sndfile.h>
#include <strings.h>

mpg123_handle *mh;

struct mp3info mp3;

int mp3sc_cleanup()
{
    mpg123_close(mh);
    mpg123_delete(mh);
    mh = NULL;
    
    mpg123_exit();

    return 0;
}

int mp3sc_init()
{
    int err = 0;

    if (mh != NULL)
    {
        mp3sc_cleanup();
    }
    
    err = mpg123_init();
    if ((err != MPG123_OK) || (mh = mpg123_new(NULL, &err)) == NULL)
    {
        return -1;
    }

    return 0;
}

int mp3sc_load_mp3fd(int fd)
{
    return 0;
}

int mp3sc_load_mp3(char * fn)
{
    int channels = 0;
    int encoding = 0;
    long rate = 0;
    int err = MPG123_OK;

    int buffer_size = 0;
    long nsamples = 0;
        
    if ((mh == NULL) ||
        (mpg123_open(mh, fn) != MPG123_OK) ||
        (mpg123_getformat(mh, &rate, &channels, &encoding) != MPG123_OK))
    {
        printf("error\n");
        
        return -1;
    }
    
    if (encoding != MPG123_ENC_SIGNED_16)
    {
        printf("coding: not MPG123_ENC_SIGNED_16\n");
    }
    printf("coding: MPG123_ENC_SIGNED_16\n");

    mp3.channels = channels;
    mp3.encoding = encoding;
    mp3.rate = rate;

    mpg123_format_none(mh);
    mpg123_format(mh, rate, channels, encoding);

    buffer_size = mpg123_outblock(mh);

    nsamples = mpg123_length(mh);
    if (nsamples <= 0)
    {
        return  -1;
    }

    printf("nsamples: %ld, channels: %d, sample length: %d\n", nsamples, channels, sizeof(short));
    
    mp3.buffer = malloc(nsamples * sizeof(short) * channels);
    printf("malloc %lu bytes for orig mp3\n", nsamples * sizeof(short) * channels);

    mp3.nsamples = nsamples;

    unsigned int i = 0;
    unsigned int done = 0;
    do 
    {
        err = mpg123_read(mh, (void *)((unsigned int)(mp3.buffer) + i * sizeof(short) * channels), buffer_size, &done);
        i += done / sizeof(short) / channels;
        
        //printf("err: %d, done: %d, current samples: %d\n", err, done, i);
    }
    while (err == MPG123_OK);
    printf("read %u bytes.\n", i * sizeof(short) * channels);

    return 0;
}

int mp3sc_set_processor(int policy)
{
    mp3.policy = policy;

    return mp3.policy;
}

int mp3sc_process_wav(char *fn, double scale)
{
    return -1;
    /*
    SNDFILE * sndfile = NULL;
    SF_INFO sfinfo;
    
    bzero(&sfinfo, sizeof(sfinfo));
    sfinfo.samplerate = mp3.rate;
    sfinfo.channels = mp3.channels;
    sfinfo.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;
    sndfile = sf_open(fn, SFM_WRITE, &sfinfo);
    if (sndfile == NULL)
    {
        printf("can't create wave file.\n");
        return -1;
    }

    printf("samples number: %lu\n", mp3.nsamples);
    
    unsigned long off = 0;
    int i = 0;

    printf("samples: %lu, scale: %f\n", mp3.nsamples, scale);
    
    unsigned long new_nsamples = (unsigned long)((double)(mp3.nsamples) * scale + 1);
    printf("new nsamples: %lu\n", new_nsamples);
    
    short * new_buffer = malloc(new_nsamples * mp3.channels * sizeof(short));

    unsigned int j = 0, k = 0;
    
    if (mp3.policy == MP3SC_POLICY_DEFAULT)
    {
        mp3.policy = MP3SC_POLICY_DIRECT;
    }
    
    if (mp3.policy == MP3SC_POLICY_DIRECT)
    {
        for ( j = 0; j < new_nsamples; j += scale * mp3.channels)
        {
            for (k = 0; k < mp3.channels; k++)
            {
                *(new_buffer + j + k) = *((short *)(mp3.buffer) + (unsigned int)((double)j / scale) + k);
            }
        }
    }
    else if (mp3.policy == MP3SC_POLICY_FILTER_ALPHA)
    {
        printf("mp3.policy: %s\n", "MP3SC_POLICY_FILTER_ALPHA\n");

        for ( j = 0; j < new_nsamples; j += scale * mp3.channels)
        {
            for (k = 0; k < mp3.channels; k++)
            {
                *(new_buffer + j + k) = *((short *)(mp3.buffer) + (unsigned int)((double)j / scale) + k);
            }
        }
*
        for (j = mp3.channels; j < new_nsamples; j += scale * mp3.channels * 2)
        {
            for (k = 0; k < mp3.channels; k++)
            {
                *(new_buffer + j + k) = (*(new_buffer + j + k) + *(new_buffer + j + k - mp3.channels)) / 2;
            }
        }
*
    }
    
    mp3.nsamples = new_nsamples;
    free(mp3.buffer);
    mp3.buffer = new_buffer;
    
    while(1)
    {
        i = sf_write_short(sndfile, (short *)((unsigned int)(mp3.buffer) + off * mp3.channels * sizeof(short)), mp3.nsamples - off > 1024? 1024: mp3.nsamples - off);

        //printf("output %u frame.\n", i);
        
        if (i <= 0) break;

        off += i / mp3.channels;
        
        if (off >= mp3.nsamples)
        {
            break;
            
        }
    }
    
    sf_close(sndfile);

    return 0;
    */
}

int mp3sc_process_mp3(char *fn, double scale)
{
/*    SNDFILE * sndfile = NULL;
    SF_INFO sfinfo;
*/  
    return 0;
}


