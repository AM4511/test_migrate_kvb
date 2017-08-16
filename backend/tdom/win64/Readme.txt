#######################################################################
# Compiling tDOM under MSYS2 64 bits (MSYS2 MinGW 64-bit) using gcc
#######################################################################
1) In windows install MSYS2
2) From the Windows start menu start: /MSYS2 64 bits/MSYS2 MinGW 64-bit shell
3) In the MSYS2 shell:

 # Configure the proxy if required
 export http_proxy='http://username:password@webproxy_url:port'
 export https_proxy='http://username:password@webproxy_url:port'

 # Download the gcc tool chain (the i686 not required if compiling only 64 bits windows apps)
 pacman -Syuu
 pacman -S --needed base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain git subversion mingw-w64-i686-cmake mingw-w64-x86_64-cmake

 #Verify that gcc is correctly installed
 gcc -v
 
 # Change to the sandbox dir
 cd /c/work/github

 # Clone the git hub repository in the current folder
 git clone https://github.com/tDOM/tdom.git

 # Jump in the tdom directory
 cd tdom/unix

 # Run the build tool chain
 ../configure --disable-tdomalloc
 make
 make test
 make install
