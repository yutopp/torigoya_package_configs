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
        git clone https://github.com/D-Programming-Language/dmd.git || exit -1
    else
        cd dmd
        git fetch origin || exit -1
        git reset --hard origin/master || exit -1
        cd ../
    fi

    if [ ! -e druntime ]; then
        git clone https://github.com/D-Programming-Language/druntime.git || exit -1
    else
        cd druntime
        git fetch origin || exit -1
        git reset --hard origin/master || exit -1
        cd ../
    fi

    if [ ! -e phobos ]; then
        git clone https://github.com/D-Programming-Language/phobos.git || exit -1
    else
        cd phobos
        git fetch origin || exit -1
        git reset --hard origin/master || exit -1
        cd ../
    fi

    #
    cd dmd
    rev=`GetGitRev`
    timestamp=`GetTimeStamp`
    display_version="git($rev) [built=$timestamp]"
    echo "DisplayVersion => $display_version"
    cd ../

    # build
    cd dmd/src
    make -f posix.mak -j$CPUCore MODEL=64 AUTO_BOOTSTRAP=1 || exit -1
    cd ../../druntime
    make -f posix.mak -j$CPUCore MODEL=64 DMD=../dmd/src/dmd || exit -1
    cd ../phobos
    make -f posix.mak -j$CPUCore MODEL=64 DMD=../dmd/src/dmd || exit -1
    cd ../

    #
    if [ -e $TR_INSTALL_PREFIX ]; then
        rm -rf $TR_INSTALL_PREFIX
    fi
    mkdir -p $TR_INSTALL_PREFIX/

    #
    cd dmd/src
    mkdir -p $TR_INSTALL_PREFIX/bin64
    cp dmd $TR_INSTALL_PREFIX/bin64 || exit -1

    cd ../../druntime
    mkdir -p $TR_INSTALL_PREFIX/src/druntime
    cp -r import $TR_INSTALL_PREFIX/src/druntime/. || exit -1

    cd ../phobos
    mkdir -p $TR_INSTALL_PREFIX/lib64
    cp generated/linux/release/64/libphobos2.a $TR_INSTALL_PREFIX/lib64 || exit -1  # for 64-bit version
    # cp generated/linux/release/32/libphobos2.a $TR_INSTALL_PREFIX/lib || exit -1  # for 32-bit version

    mkdir -p $TR_INSTALL_PREFIX/src/phobos
    cp -r std $TR_INSTALL_PREFIX/src/phobos/. || exit -1
    cp -r etc $TR_INSTALL_PREFIX/src/phobos/. || exit -1
    cd ../

    # must quote $display_version
    PackEdgeDebFromDir $TR_INSTALL_PREFIX $TR_PACKAGE_NAME $TR_VERSION "$display_version"
    exit 0

else
    echo "none"
fi
