#!/use/bin/env bash
. /etc/pkgconfigs/base.sh
CheckImport || exit -1

if [ "$TR_VERSION" == "$TR_HEAD" ]; then
    echo "none"
    exit -1

else
    # TODO: fix
    wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz/download -O boost_1_59_0.tar.gz
    tar xzvf boost_1_59_0.tar.gz

    #
    if [ -e $TR_INSTALL_PREFIX ]; then
        rm -rf $TR_INSTALL_PREFIX
    fi
    mkdir -p $TR_INSTALL_PREFIX/

    cd boost_1_59_0
    ./bootstrap.sh -prefix=$TR_INSTALL_PREFIX

    # TODO: set toolchain
    ./b2 --with-system \
         -j 2 cxxflags="-std=c++11" link=static install

    cd ../

    PackDebFromDir $TR_INSTALL_PREFIX $TR_PACKAGE_NAME $TR_VERSION
    exit 0
fi
