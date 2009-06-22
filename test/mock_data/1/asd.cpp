#include <stdio.h>
#include <strings.h>
#include <stdlib.h>
#include <iostream>

#include <mpg123.h>

using namespace std;


int main(int argc, char *argv[]) {
    if (argc != 2) {
        cout << "Wow!\n";
        exit(1);
    }

    cout << "Ok!" << argv[1] << endl;

    int err = mpg123_init();
    mpg123_handle *mh;
    if ((err != MPG123_OK) || (mh = mpg123_new(NULL, &err)) == NULL) {
        cout << "Failed to init. " << err << endl;
        exit(2);
    }

    //err = MPG123_OK;
    //int buffer_size = 0;
    //long nsamples = 0;

    if (mpg123_open(mh, argv[1]) != MPG123_OK) {
        cout << "Failed to open file: " << argv[1] << endl;
        exit(3);
    }

    int channels = 0;
    int encoding = 0;
    long rate = 0;
    if (mpg123_getformat(mh, &rate, &channels, &encoding) != MPG123_OK) {
        cout << "Failed get format." << endl;
        exit(4);
    }
    cout << "Rate: " << rate << endl;
    cout << "Channels: " << channels << endl;
    cout << "Encoding: " << encoding << endl;

    long nsamples = mpg123_length(mh);
    cout << "nsamples: " << nsamples << endl;

    double tpf = mpg123_tpf(mh);
    cout << "tpf: " << tpf << endl;


    return 0;
}


