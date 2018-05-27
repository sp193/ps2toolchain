# Newlib #
Newlib for the r5900 is built with the following flags:

 * --enable-newlib-io-long-long
 * --enable-newlib-io-c99-formats
 * --enable-newlib-mb
 * --enable-newlib-nano-malloc
 * --enable-newlib-retargetable-locks

Multithreading support is enabled by default.

## Choosing a file I/O library ##
Newlib now has support for both file I/O libraries provided with ps2sdk but only
one can be compiled in at a time.

Add "-DUSE_FILEXIO" to TARGET_CFLAGS to switch to fileXio.
```sh
TARGET_CFLAGS="-DUSE_FILEXIO" make
```

## Profiling ##
Add "-pg" to TARGET_CFLAGS to compile in profiling support.

Define GMON_OUT to a string literal to customize the output. The default value
is "host:gmon.out".

Define MCOUNT_USE_T0 to use the first hardware timer, otherwise __mcount uses T1
by default.

For example:
```sh
TARGET_CFLAGS='-pg -DGMON_OUT=\"mass:/gmon.out\"' make
```
For gmon.out to be written to a usb mass storage device.

## Reentrancy ##
To use newlib's reentrancy.

Newlib declares a global _reent structure for single threaded applications and
_impure_ptr points to that _reent structure.

\_\_DYNAMIC_REENT\_\_ is unsupported.

When creating a thread:

1. Declare a global struct _reent reent for that context and set _impure_ptr
   to it within the context.
```c
   struct _reent reent0 = _REENT_INIT (reent0);
   . . .
   int thread_func()
   {
     
     _impure_ptr = &reent0;
     while(1) { do_something(); }
   }
```
2. When the context switches, set _impure_ptr to the address of the current
   context's reent structure in order to preserve thread specific information.

3. Referring to the reentrancy structures.

  * _global_impure_ptr stores the original _impure_ptr address.
  * _REENT can be used to get the local _reent structure
  * _GLOBAL_REENT can be used to refer to the _global_impure_ptr

To set the _REENT structure back to the original:
```c
 _REENT = _GLOBAL_REENT;
 ```
The reentrant versions of the functions only set the reentrant errno if an error
occurs.

## Errno ##
Using errno with newlib.

When including errno.h and setting errno, if you don't wish to use the builtin
reentrant errno, then do the following:
```c
#include <errno.h>
#undef errno
extern int errno;
```
## Wide character support and locales ##
--enable-newlib-mb is enabled by default which defines _MB_CAPABLE and enables
newlib to be built with the following wide character formats.

From newlib's libc documentation:

> The following charsets are recognized: "UTF-8", "JIS", "EUCJP", "SJIS",
	"KOI8-R", "KOI8-U", "GEORGIAN-PS", "PT154", "TIS-620",
	"ISO-8859-x" with 1 <= x <= 16, or
	"CPxxx" with xxx in
	[437, 720, 737, 775, 850, 852, 855, 857, 858,
	 862, 866, 874, 932, 1125, 1250, 1251, 1252, 1253, 1254, 1255, 1256,
	 1257, 1258].

Use setlocale() to switch locales.

The following configure flags enables conversion between wide character
formats using iconv. For example, between UTF-8 and EUC-JP.

 * --enable-newlib-iconv
 * --enable-newlib-iconv-encodings=utf8,eucjp

See newlib/libc/iconv/encoding.aliases for a list of supported encodings


