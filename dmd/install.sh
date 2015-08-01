#!/use/bin/env bash
. /etc/pkgconfigs/base.sh
CheckImport || exit -1

if [ "$TR_VERSION" == "HEAD" ]; then
    #if [ -e dmd ]; then
    #    rm -rf dmd
    #fi
    #
    #if [ -e druntime ]; then
    #    rm -rf druntime
    #fi
    #
    #if [ -e phobos ]; then
    #    rm -rf druntime
    #fi

    if [ ! -e dmd ]; then
        git clone https://github.com/D-Programming-Language/dmd.git
    else
        cd dmd
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi

    if [ ! -e druntime ]; then
        git clone https://github.com/D-Programming-Language/druntime.git
    else
        cd druntime
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi

    if [ ! -e phobos ]; then
        git clone https://github.com/D-Programming-Language/phobos.git
    else
        cd phobos
        git fetch origin
        git reset --hard origin/master
        cd ../
    fi

    #
    cd dmd
    rev=`GetGitRev`
    display_version="git($rev)"
    echo "DisplayVersion => $display_version"
    cd ../

    # build
    cd dmd/src
    make -f posix.mak -j$CPUCore MODEL=64 AUTO_BOOTSTRAP=1
    cd ../../druntime
    make -f posix.mak -j$CPUCore MODEL=64 DMD=../dmd/src/dmd
    cd ../phobos
    make -f posix.mak -j$CPUCore MODEL=64 DMD=../dmd/src/dmd
    cd ../

    #
    if [ -e $TR_INSTALL_PREFIX ]; then
        rm -rf $TR_INSTALL_PREFIX
    fi
    mkdir -p $TR_INSTALL_PREFIX/

    #
    cd dmd/src
    mkdir -p $TR_INSTALL_PREFIX/bin64
    cp dmd $TR_INSTALL_PREFIX/bin64

    cd ../../druntime
    mkdir -p $TR_INSTALL_PREFIX/src/druntime
    cp -r import $TR_INSTALL_PREFIX/src/druntime/.

    cd ../phobos
    mkdir -p $TR_INSTALL_PREFIX/lib64
    cp generated/linux/release/64/libphobos2.a $TR_INSTALL_PREFIX/lib64    # for 64-bit version
    # cp generated/linux/release/32/libphobos2.a $TR_INSTALL_PREFIX/lib    # for 32-bit version

    mkdir -p $TR_INSTALL_PREFIX/src/phobos
    cp -r std $TR_INSTALL_PREFIX/src/phobos/.
    cp -r etc $TR_INSTALL_PREFIX/src/phobos/.
    cd ../

    PackEdgeDebFromDir $TR_INSTALL_PREFIX $TR_PACKAGE_NAME $TR_VERSION $display_version
    exit 0

else
    echo "none"
fi
