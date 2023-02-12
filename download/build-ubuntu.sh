#!/bin/env bash

set -eo pipefail

echo '    Welcome to Openfish DE build script! This script works on most Debian/Ubuntu-based distros and aims at making Openfish DE usable on other Linux distros.'
echo '    This script can build and install one component / all of the components of Openfish DE automatically based on your choice.'
# shellcheck disable=SC2016
echo '    By default, all of the git repositories will be cloned to ~/cutefishos from https://github.com/cutefishos. You can change them by simply modifing $REPO_PATH and $GIT_REPO_URL.'
echo '------'
echo 'Authors: Moore2253: Original author'
echo '         wujunyi:   Co-author'
echo '         Fuyuki S.: Co-author and English translation'
echo '         Titenko Maksym.: Co-author and Adapting Opefish DE for Ubuntu '
echo '------'
echo 'You should read all the above before starting to build.'

echo "The next step will install necessary dependencies for building."
read -r -p "Continue? [Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
        echo "------"
        ;;
    *)
        echo "Quitting."
        exit 1
        ;;
esac

# Set repository path & URL here.
# Please mind that NO SPLASH ("/") should appear at the end of the path.
REPO_PATH=~/cutefishos
GIT_REPO_URL=https://github.com/cutefishos

mkdir -p $REPO_PATH

echo 'Installing dependencies:'
sudo apt install libpolkit-qt5-1-dev qml-module-qtquick-dialogs libxcb-damage0-dev libicu-dev libqapt-dev libkf5solid-dev pkg-config extra-cmake-modules libpam0g-dev libxcb-util-dev lintian libsm-dev libkf5screen-dev libxcb-composite0-dev qml-module-qt-labs-settings libqt5sensors5-dev libcanberra-dev qml-module-qtqml debhelper libfreetype6-dev libkf5bluezqt-dev qml-module-qtquick-shapes libapt-pkg-dev xserver-xorg-dev qtbase5-dev libx11-dev libcrypt-dev libfontconfig1-dev cmake qml-module-qtquick-particles2 libxcb1-dev xserver-xorg-input-synaptics-dev libkf5idletime-dev libkf5networkmanagerqt-dev automake libqt5x11extras5-dev git libxcb-dri2-0-dev qml-module-qtquick2 libxcursor-dev qttools5-dev qml-module-qtquick-layouts libcanberra-pulse libxcb-keysyms1-dev libsystemd-dev gcc -y libxcb-glx0-dev qttools5-dev-tools qml-module-qtquick-window2 libxcb-image0-dev libcap-dev libpulse-dev libxcb-randr0-dev qml-module-qtquick-controls2 libxcb-shm0-dev libxcb-ewmh-dev equivs libxcb-icccm4-dev qtdeclarative5-dev libkf5kio-dev qtquickcontrols2-5-dev libkf5coreaddons-dev devscripts libxcb-xfixes0-dev libxcb-record0-dev qml-module-qt-labs-platform libxtst-dev libxcb-dpms0-dev build-essential libkf5windowsystem-dev xserver-xorg-input-libinput-dev autotools-dev libx11-xcb-dev libxcb-dri3-dev qml-module-org-kde-kwindowsystem libkf5globalaccel-dev qtbase5-private-dev modemmanager-qt-dev libpolkit-agent-1-dev curl libxcb-shape0-dev --no-install-recommends -y
echo 'Dependencies installed.'
echo '------'

function standardBuild_apt(){
    echo "$1 build start:"
        pushd "$REPO_PATH"
        if [ ! -d "$REPO_PATH/$1" ]; then
            echo "Cloning:"
            git clone "$GIT_REPO_URL/$1.git"
        else
            echo "Git directory already exists! Fetching:"
            git fetch
        fi
        cd "$1"
        echo "Installing the dependencies:"
        sudo mk-build-deps ./debian/control -i -t "apt-get --yes" -r
        echo "Building:"
        dpkg-buildpackage -b -uc -us
        popd
    echo "$1 built"

    echo "$1 installation start:"
        sudo apt-get install $REPO_PATH/*"$1"_*.deb
        # This step is able to prevent installing dbgsym for its name being xxx-dbgsym_v.e.r_architect.deb .
    echo "$1 installed."
    echo '------'
}

function standardBuild_make(){
    echo "$1 build start:"
        pushd "$REPO_PATH"
        if [ ! -d "$REPO_PATH/$1" ]; then
            echo "Cloning:"
            git clone "$GIT_REPO_URL/$1.git"
        else
            echo "Git directory already exists! Fetching:"
            git fetch
        fi
        cd "$1"
        echo "Installing the dependencies:"
        sudo mk-build-deps ./debian/control -i -t "apt-get --yes" -r
        echo "Building:"
        cmake -B build -S . -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE:BOOL=Release
        make -C build
        popd
    echo "$1 built."

    echo "$1 installation start:"
        sudo make -C build install
    echo "$1 installed."
    echo '------'
}

WAY_TO_INSTALL=""

function Build(){
    case $WAY_TO_INSTALL in 
        apt)
            standardBuild_apt "$1"
        ;;
        make)
            standardBuild_make "$1"
        ;;
        *)
            echo "Unknown ERROR"
            exit 1
        ;;
    esac
}

# Package list here. Once new packages were added please add the repository name here.
PAC_LIST="fishui libcutefish qt-plugins kwin-plugins core texteditor wallpapers filemanager screenshot screenlocker launcher dock terminal settings statusbar updator icons daemon sddm-theme debinstaller appmotor gtk-themes cursor-themes calculator videoplayer plymouth-theme"

function Selection()
{
    echo 'Input the number of the component you want to build and press enter (1 for all, 2 to quit)'
    PS3='Input a number (ENTER to see the list):'
    select i in ALL QUIT $PAC_LIST
    do
        if test "$i" == "ALL" ;
        then
            for j in $PAC_LIST
            do
                Build "$j"
            done
        elif test "$i" == "QUIT" ;
        then
            echo "Quitting."
            exit 0
        elif test "$i" != "" ;
        then
            Build "$i"
        else
            echo 'Invalid number. Please check your input.'
        fi
    done
}

echo 'In which way would you like to install?'
select QUE in "apt - Build Debian packages and install with APT (Easy to remove)" "make install - Install the binaries directly"
do
    if test "$QUE" == "apt - Build Debian packages and install with APT (Easy to remove)"
    then
        WAY_TO_INSTALL="apt"
        echo '------'
        Selection
    elif test "$QUE" == "make install - Install the binaries directly"
    then
        WAY_TO_INSTALL="make"
        echo '------'
        Selection
    fi
done

