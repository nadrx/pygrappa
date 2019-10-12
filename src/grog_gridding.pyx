# distutils: language = c++
# cython: language_level=3

cimport numpy as np
from libcpp.vector cimport vector
cimport cython
from cython cimport view

cdef extern from "math.h":
    double round(double d)

ctypedef np.complex COMPLEX_t

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
def grog_gridding(
        const double[::1] tx,
        const double[::1] ty,
        const double[::1] kx,
        const double[::1] ky,
        const complex[:, ::1] k,
        const vector[vector[int]] idx,
        np.ndarray[COMPLEX_t, ndim=2] res,
        const unsigned int[::1] inside,
        Dx,
        Dy,
        const unsigned int precision):
    '''Do GROG.

    Notes
    -----
    `res` is modified in-place.
    '''

    cdef:
        unsigned int ii, jj, N, M, idx0, in0
        double pfac, key_x, key_y

    pfac = 10.0**precision
    N = len(tx)
    for ii in range(N):
        M = idx[ii].size()
        in0 = inside[ii]
        for jj in range(M):
            idx0 = idx[ii][jj]
            key_x = round((tx[ii] - kx[idx0])*pfac)/pfac
            key_y = round((ty[ii] - ky[idx0])*pfac)/pfac
            Gxf = Dx[key_x]
            Gyf = Dy[key_y]

            res[in0, :] = res[in0, :] + Gxf @ Gyf @ k[idx0, :]

        # Finish the averaging (dividing step)
        if M:
            res[in0, :] = res[in0, :]/M
