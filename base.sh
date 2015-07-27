echo "this is base!!!"

echo $TR_REUSE_FLAG
echo $TR_NAME
echo $TR_VERSION
echo $TR_TARGET_SYSTEM
echo $TR_TARGET_ARCH
echo $TR_INSTALL_PATH
echo $TR_PKGS_PATH
echo $TR_CPU_CORE
echo $TR_INSTALL_PREFIX
echo $TR_PACKAGE_NAME
echo $TR_PACKAGE_PREFIX

function CheckImport() {
    echo "base script is imported"
}

function GetGitRev() {
    echo `git log --pretty=format:"%H" -1 | cut -c 1-10`
}

function GetSVNRev() {
    echo `svn info | grep '^Revision:' | sed 's/^Revision: \([0-9]\+\)/\1/'`
}


function make_version_name() {
    target_version=$1

    case $target_version in
        'HEAD')
            # edge version
            echo "head"
            ;;

        *)
            # normal version, replace "_" and "-" to "."
            echo "$target_version" | sed -s 's/(_|-)/\./g'
            ;;
    esac
}

function PackEdgeDebFromDir() {
    # Ex,
    # fpm -s dir -t rpm -n "slashbin" -v 1.0 /bin /sbin
    # makes "slashbin_1.0.x86_64.rpm"

    # parms
    # $1 = installed path
    # $2 = base package name
    # $3 = version
    # $4 = display version
    # $~ options for fpm

    installed_dir=$1
    base_package_name=$2
    raw_version=$3
    display_version=$4
    shift; shift; shift; shift;
    fpm_options=$@

    # package name will be "$prefix$name-$version"
    # package version will be date

    version_for_name=`make_version_name $raw_version`
    package_name="$TR_PACKAGE_PREFIX$base_package_name-$version_for_name"
    package_version=`date +'%Y%m%d%H%M%S'`  # date

    echo "package_name    => $package_name"
    echo "package_version => $package_version"

    # make
    mkdir /tmp/torigoya_generated_packages || exit -30
    cd /tmp/torigoya_generated_packages || exit -31

    # make package
    fpm $fpm_options --force -s dir -t deb -n $package_name -v $package_version --deb-compression xz --verbose $installed_dir

    pkg_file_name=`ls`
    echo "Generated pkg name: $pkg_file_name"

    # copy
    cp $pkg_file_name $TR_PKGS_PATH/.

    # generated result json
    cd $TR_PKGS_PATH || exit -32
    json_file_name="result-$base_package_name-$raw_version.json"
    echo "Writing result to $json_file_name ..."
    cat << EOF_JSON > $json_file_name
{
    "pkg_file_name": "$pkg_file_name",
    "pkg_name": "$package_name",
    "pkg_version": "$package_version",
    "display_version": "$display_version"
}
EOF_JSON
}


function PackDebFromDir() {
    # Ex,
    # fpm -s dir -t rpm -n "slashbin" -v 1.0 /bin /sbin
    # makes "slashbin_1.0.x86_64.rpm"

    # parms
    # $1 = installed path
    # $2 = base package name
    # $3 = version
    # $~ options for fpm

    installed_dir=$1
    base_package_name=$2
    raw_version=$3
    shift; shift; shift;
    fpm_options=$@

    # package name will be "$prefix$name-$version"
    # package version will be date

    version_for_name=`make_version_name $raw_version`
    package_name="$TR_PACKAGE_PREFIX$base_package_name-$version_for_name"
    package_version=`date +'%Y%m%d%H%M%S'`  # date

    echo "package_name    => $package_name"
    echo "package_version => $package_version"

    # make
    mkdir /tmp/torigoya_generated_packages || exit -30
    cd /tmp/torigoya_generated_packages || exit -31

    # make package
    fpm $fpm_options --force -s dir -t deb -n $package_name -v $package_version --deb-compression xz --verbose $installed_dir

    pkg_file_name=`ls`
    echo "Generated pkg name: $pkg_file_name"

    # copy
    cp $pkg_file_name $TR_PKGS_PATH/.

    # generated result json
    cd $TR_PKGS_PATH || exit -32
    json_file_name="result-$base_package_name-$raw_version.json"
    echo "Writing result to $json_file_name ..."
    cat << EOF_JSON > $json_file_name
{
    "pkg_file_name": "$pkg_file_name",
    "pkg_name": "$package_name",
    "pkg_version": "$package_version",
    "display_version": "$raw_version"
}
EOF_JSON
}
