# Build Openfish DE automatically
A build script for compiling Openfish DE automatically.

This script enables Debian/Ubuntu-based Linux distros to install Openfish DE with apt(dpkg) or install it directly with `make install`. However it should be kept in mind that 2 packages, grub-theme and plymouth-theme, are not able to install without apt because they don't use CMake to build.
