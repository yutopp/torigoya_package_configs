#!/use/bin/env bash
. /etc/pkgconfigs/base.sh
CheckImport || exit -1

case "$TR_VERSION" in
    $TR_HEAD)
        branch_name="master" ;;

    *)
        # ex. 5.1.0
        # ${TR_VERSION:0:1} = 5
        # ${TR_VERSION:2:1} = 1
        # ${TR_VERSION:4:1} = 0
        branch_name="gcc-${TR_VERSION:0:1}_${TR_VERSION:2:1}_${TR_VERSION:4:1}-release" ;;
esac

# gcc source code
if [ -e gcc ]; then
    cd gcc
    git fetch origin || exit -1
    git reset --hard origin/master || exit -1
    git checkout $branch_name || exit -1
    cd ..
else
    git clone git://gcc.gnu.org/git/gcc.git gcc || exit -1
    cd gcc
    git checkout $branch_name || exit -1
    cd ..
fi


# gmp
GMP_version="5.1.3"
GMP_target_filename="gmp-${GMP_version}.tar.bz2"
GMP_dirname="gmp-${GMP_version}"

echo "==== GMP : $GMP_version"
if [ -e gcc/gmp ]; then
    rm -rf gcc/gmp
fi
if [ -e $GMP_dirname ]; then
    cp -r $GMP_dirname -T gcc/gmp
else
    wget http://ftp.gnu.org/gnu/gmp/$GMP_target_filename -O $GMP_target_filename
    tar -jxf $GMP_target_filename
    cp -r $GMP_dirname -T gcc/gmp
fi


# mpfr
MPFR_version="3.1.2"
MPFR_target_filename="mpfr-${MPFR_version}.tar.bz2"
MPFR_dirname="mpfr-${MPFR_version}"

echo "==== MPFR : $MPFR_version"
if [ -e gcc/mpfr ]; then
    rm -rf gcc/mpfr
fi
if [ -e $MPFR_dirname ]; then
    cp -r $MPFR_dirname -T gcc/mpfr
else
    wget http://ftp.gnu.org/gnu/mpfr/$MPFR_target_filename -O $MPFR_target_filename
    tar -jxf $MPFR_target_filename
    cp -r $MPFR_dirname -T gcc/mpfr
fi


# MPC
MPC_version="1.0.3"
MPC_target_filename="mpc-${MPC_version}.tar.gz"
MPC_dirname="mpc-${MPC_version}"

echo "==== MPC : $MPC_version"
if [ -e gcc/mpc ]; then
    rm -rf gcc/mpc
fi
if [ -e $MPC_dirname ]; then
    cp -r $MPC_dirname -T gcc/mpc
else
    wget http://ftp.gnu.org/gnu/mpc/$MPC_target_filename -O $MPC_target_filename
    tar xzvf $MPC_target_filename
    cp -r $MPC_dirname -T gcc/mpc
fi


# GCC version
if [ "$TR_VERSION" == $TR_HEAD ]; then
    cd gcc
    rev=`GetGitRev`
    timestamp=`GetTimeStamp`
    display_version="git($rev) [built=$timestamp]"
    echo "DisplayVersion => $display_version"
    cd ..
else
    #echo "Version => $PackageVersion"
    echo "none"
    exit -10
fi


# build gcc
case "$TR_VERSION" in
    "4.7.0" | "4.7.1" | "4.7.2")
        export MAKEINFO=missing ;;
esac


#
if [ -e $TR_INSTALL_PREFIX ]; then
    rm -rf $TR_INSTALL_PREFIX
fi
mkdir -p $TR_INSTALL_PREFIX/

cd gcc
if [ -e build_dir ]; then
    rm -rf build_dir
fi
mkdir build_dir
cd build_dir || exit -1

#
# configure
../configure \
    --prefix=$TR_INSTALL_PREFIX/ \
    --enable-languages=c,c++ \
    --build=$TR_TARGET_SYSTEM \
    --host=$TR_TARGET_SYSTEM \
    --target=$TR_TARGET_SYSTEM \
    --disable-nls \
    --disable-multilib \
    --disable-libstdcxx-pch \
    --disable-bootstrap

export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

if [ "$TR_VERSION" == $TR_HEAD ]; then
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TR_INSTALL_PREFIX/lib
    make all -j$TR_CPU_CORE || make -j$TR_CPU_CORE || exit -1
    make install

    PackEdgeDebFromDir $TR_INSTALL_PREFIX $TR_PACKAGE_NAME $TR_VERSION $display_version
    exit 0

else
    echo "none"
    exit -10
fi
