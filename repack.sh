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

tmpdir=$(mktemp -d -t repacker-XXXXXXXXXX)

echo -ne "[ ] smali\r"
smali assemble $DIR/$SMALI -o $tmpdir/classes.dex  > /dev/null
echo "[x] smali"

echo -ne "[ ] zip\r"
cp -r $DIR/AndroidManifest.xml $DIR/res $DIR/resources.arsc $tmpdir/
cd $tmpdir
zip -r $DIR/$OUT.tmp.apk AndroidManifest.xml classes.dex res/ resources.arsc > /dev/null
cd - > /dev/null
echo "[x] zip"

echo -ne "[ ] sign apk\r"
java -jar signapk/signapk.jar signapk/certificate.pem signapk/key.pk8 $DIR/$OUT.tmp.apk $DIR/$OUT.signed.apk
echo "[x] sign apk"

echo -ne "[ ] zip align\r"
zipalign -a 4 -i $DIR/$OUT.signed.apk -o $DIR/$OUT.apk
echo "[x] zip align"

echo -ne "[ ] cleanup\r"
rm $DIR/$OUT.tmp.apk
rm $DIR/$OUT.signed.apk
echo "[x] cleanup"

echo "Done!"
echo "Result at $OUT.apk"
