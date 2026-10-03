/* fs_halftone_mex.c - C/MEX implementation of floyd_steinberg.m
 * (identical arithmetic and scan order; used only for speed).
 * bw = fs_halftone_mex(gray, bias)
 * gray : double matrix in [0,255] (colorant density), bias : scalar
 * bw   : logical matrix, true = black (ink) dot
 * Build (Octave):  mkoctfile --mex fs_halftone_mex.c
 * Build (MATLAB):  mex fs_halftone_mex.c                                */
#include "mex.h"
#include <string.h>
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2) mexErrMsgTxt("usage: bw = fs_halftone_mex(gray, bias)");
    mwSize h = mxGetM(prhs[0]), w = mxGetN(prhs[0]);
    const double *g = mxGetPr(prhs[0]);
    double thresh = 128.0 + mxGetScalar(prhs[1]);
    double *img = (double*) mxMalloc(h * w * sizeof(double));
    memcpy(img, g, h * w * sizeof(double));
    plhs[0] = mxCreateLogicalMatrix(h, w);
    mxLogical *bw = mxGetLogicals(plhs[0]);
    for (mwSize i = 0; i < h; i++) {
        for (mwSize j = 0; j < w; j++) {
            double old = img[i + j*h];
            double nv = (old >= thresh) ? 255.0 : 0.0;
            bw[i + j*h] = (nv == 255.0);
            double err = old - nv;
            if (j + 1 < w)              img[i + (j+1)*h]     += err * 7 / 16;
            if (i + 1 < h && j >= 1)    img[(i+1) + (j-1)*h] += err * 3 / 16;
            if (i + 1 < h)              img[(i+1) + j*h]     += err * 5 / 16;
            if (i + 1 < h && j + 1 < w) img[(i+1) + (j+1)*h] += err * 1 / 16;
        }
    }
    mxFree(img);
}
