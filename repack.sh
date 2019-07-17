#!/bin/bash -e
# -e Any subsequent(*) commands which fail will cause the shell script to exit immediately



if [ -z "$1" ]
then
    echo "must specify a working directory"
    exit
fi

if [ -z "$2" ]
then
    echo "must specify a smali source directory"
    exit
fi

DIR=$1
SMALI=$2
OUT=${3:-app}

echo "repacking $SMALI into $OUT.apk in directory $DIR"

smali assemble $DIR/$SMALI -o $DIR/classes.dex

cd $DIR
zip -r $OUT.tmp.apk AndroidManifest.xml $DIR/classes.dex $DIR/res/ resources.arsc
cd -

java -jar signapk/signapk.jar signapk/certificate.pem signapk/key.pk8 $DIR/$OUT.tmp.apk $DIR/$OUT.signed.apk

zipalign -a 4 -i $DIR/$OUT.signed.apk -o $DIR/$OUT.apk

rm $DIR/$OUT.tmp.apk
rm $DIR/$OUT.signed.apk

echo "Done!"
