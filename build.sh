#!/usr/bin/env bash

# Install OpenWatcom for wlink
if [ ! -d 'WATCOM' ]; then
  if [ ! -f 'SETUP.EXE' ]; then
    wget 'https://openwatcom.org/ftp/install/open-watcom-c-dos-1.9.exe'
    mv 'open-watcom-c-dos-1.9.exe' 'SETUP.EXE'
  fi
  dosbox -c 'mount c .' \
    -c 'c:' \
    -c 'setup -s -ns' \
    -c 'exit'
fi

# Install Borland Turbo Assembler for tasm
if [ ! -d 'tasm/BIN' ]; then
  if [ ! -d 'tasm' ]; then
    echo "TASM submodule not initialized"
    exit
  fi

  # Merge all disks to mount a single folder
  mkdir -p tasm/INSTALL && cp -r tasm/DISK*/* tasm/INSTALL/

  dosbox -c 'mount c .' \
    -c 'mount a tasm/INSTALL -t floppy' \
    -c 'a:' \
    -c 'install' \
    -c 'exit'
fi

# Assemble and link
dosbox -c 'mount c .' \
  -c 'c:' \
  -c 'PATH C:\tasm\BIN;C:\WATCOM\BINW;%PATH%;' \
  -c 'SET INCLUDE=C:\WATCOM\H;' \
  -c 'SET WATCOM=C:\WATCOM' \
  -c 'wmake' \
  -c 'exit'

