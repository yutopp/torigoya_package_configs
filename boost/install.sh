#!/use/bin/env bash
. /etc/pkgconfigs/base.sh
CheckImport || exit -1

if [ "$TR_VERSION" == "$TR_HEAD" ]; then
    echo "none"
    exit -1

else
    # TODO: fix
    dir_name=boost_`echo "$TR_VERSION" | sed -s 's/\./\_/g'`
    echo "boost => $dir_name"

    wget http://sourceforge.net/projects/boost/files/boost/$TR_VERSION/${dir_name}.tar.gz/download -O ${dir_name}.tar.gz
    tar xzvf ${dir_name}.tar.gz

    #
    if [ -e $TR_INSTALL_PREFIX ]; then
        rm -rf $TR_INSTALL_PREFIX
    fi
    mkdir -p $TR_INSTALL_PREFIX/

    cd ${dir_name}
    ./bootstrap.sh -prefix=$TR_INSTALL_PREFIX

    if [ "$TR_DEP_PKG_NAME" == "gcc" ]; then
        toolset="gcc"
        flags=""

        export PATH="$TR_DEP_PKG_PATH/bin:$PATH"
        export LD_LIBRARY_PATH="$TR_DEP_PKG_PATH/lib/../lib64"

    else
        echo "toolset $TR_DEP_PKG_NAME is not supported"
        exit -1
    fi

    echo "toolset         => $toolset"
    echo "PATH            => $PATH"
    echo "LD_LIBRARY_PATH => $LD_LIBRARY_PATH"

    ./b2 --with-system \
         -j2 \
         toolset=$toolset \
         cxxflags="-std=c++11 $flags" \
         link=static \
         install \
        || exit -1

    cd ../

    PackDebFromDir $TR_INSTALL_PREFIX $TR_PACKAGE_NAME $TR_VERSION
    exit 0
fi
