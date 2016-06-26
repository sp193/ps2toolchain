#!/bin/bash
# ps2sdk.sh by Dan Peori (danpeori@oopo.net)
# changed to use Git by Mathias Lafeldt <misfire@debugon.org>

# make sure ps2sdk's makefile does not use it
unset PS2SDKSRC

 ## Download the source code.
 if test ! -d "ps2sdk/.git"; then
  git clone https://github.com/sp193/ps2sdk && cd ps2sdk || exit 1
 else
  cd ps2sdk &&
  git pull && git fetch origin &&
  git reset --hard origin/master || exit 1
 fi

 ## Determine the maximum number of processes that Make can work with.
 ## MinGW's Make doesn't work properly with multi-core processors.
 OSVER=$(uname)
 if [ ${OSVER:0:10} == MINGW32_NT ]; then
 	PROC_NR=2
 else
 	PROC_NR=$(nproc)
 fi

 ## Build and install
 make clean && make -j $PROC_NR && make release && make clean || { exit 1; }

 ## Replace Newlib's crt0 with the one in ps2sdk.
# ln -sf "$PS2SDK/ee/startup/crt0.o" "$PS2DEV/ee/lib/gcc/mips64r5900el-ps2-elf/5.3.0/crt0.o" || { exit 1; }
# ln -sf "$PS2SDK/ee/startup/crt0.o" "$PS2DEV/ee/mips64r5900el-ps2-elf/lib/crt0.o" || { exit 1; }
