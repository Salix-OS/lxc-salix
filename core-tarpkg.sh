#!/bin/sh

export LANG=en_US

if [ "$UID" != "0" ]; then
    echo "You need to be root to run this"
    exit 1
fi

TAR="salix-core-13.37"
rm $TAR
mkdir $TAR

# get the core pkgs list
CORE="2638"
COREfile="CORE?revision\=$CORE"

wget -c http://salix.svn.sourceforge.net/viewvc/salix/iso-creation/trunk/lists-xfce/CORE?revision=$CORE || return 1

rm core.list
mv $COREfile core.list

slapt-get -u
slapt-get --clean

{
	for i in `cat core.list`; do
	       slapt-get -d --no-dep --reinstall -i $i
	       done
	       
} 2>&1 | tee download.log
grep "connect to server" download.log
grep "No such" download.log

# make the tar archive
find /var/slapt-get -name *.t[gx]z -exec cp {} $TAR \;

(
    cd $TAR
    rm lilo*
    rm kernel*
    rm mkinitrd*
    ls . > ../$TAR.pkglist
    tar ccvf $TAR.tar .
    sha1sum $TAR.tar > ../$TAR.tar.sha1
    mv $TAR.tar ../
)

