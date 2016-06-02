#!/bin/sh
rm distrib/*
FILES="*.cgi"
TGDIR="./distrib/unified"
#DISTR="./distrib"
#rm -rf $TGDIR
mkdir -p $TGDIR
#mkdir -p $TGDIR/unauthenticated
#mkdir -p $TGDIR/unauthenticated/js
#mkdir -p $TGDIR/unauthenticated/css
#mkdir -p $TGDIR/unauthenticated/templates
cp -R images $TGDIR
cp -R unauthenticated $TGDIR
#cp -R lang $TGDIR
#cp -R lib $TGDIR
#cp -R unauthenticated/js/*.min.js $TGDIR/unauthenticated/js
#cp -R unauthenticated/css/*.min.css $TGDIR/unauthenticated/css
#cp -R unauthenticated/templates $TGDIR/unauthenticated

#cp CHANGELOG.md $TGDIR
#cp LICENCE $TGDIR
#cp README.md $TGDIR
#cp acl_security.pl $TGDIR
cp config $TGDIR
#cp config.info $TGDIR
#cp defaultacl $TGDIR
cp mime.types $TGDIR
cp theme.info $TGDIR
cp unified.pl $TGDIR

for f in $FILES
do
  if [ -f $f -a -r $f ]; then
   cp $f "$TGDIR/$f"
  else
   echo "Error: Cannot read $f"
  fi
done

while IFS='=' read -r key value; do
    case $key in
        version)
            VERSION="$value"
            ;;
     esac
done < theme.info

echo "Packing version $VERSION"

cd distrib
#tar -zcf filemin-1.1.1.cdn.linux.wbm.gz filemin
tar -zcf unified-$VERSION.linux.wbt.gz unified
cd ../
rm -rf $TGDIR
