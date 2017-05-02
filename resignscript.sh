#!/bin/sh

# Created By: Matt Kiernan
# Date: 5/30/2016


#REPLACE WITH YOUR OWN PROVISIONING PROFILE AND CERTIFICATE!!!
    PROVISION="Nielsen_Enterprise_Distribution.mobileprovision"
    CERTIFICATE="iPhone Distribution: The Nielsen Company Ent." #found in Keychain Access. Have 'login' and 'Certificates' selected
#END OF USER EDITING

#####  HOW TO USE
# 1st: create folder on your Desktop with name: 'FilesToResign'
# 2nd: place all .ipa files to resign into 'FilesToResign' folder
#      place provisioning profile in 'FilesToResign'
#      place this file (resignscript.sh) in 'FilesToResign'
# 3rd: open Terminal (CMD+space, type: "terminal" press: Enter)
# 4th: in Terminal - type (or copy & paste): cd Desktop/FilesToResign
# 5th: (1st time use only) in Terminal - type (or copy & paste): chmod +x resignscript.sh
# 6th: in Terminal - type (or copy & paste): ./resignscript.sh



mkdir -p ~/Desktop/NEW\ RESIGNED\ APPS
mkdir -p ~/Desktop/OLD\ APPS

mkdir -p ~/Desktop/tmp1
mkdir -p ~/Desktop/tmp2
mkdir -p ~/Desktop/tmp3
mkdir -p ~/Desktop/tmp4
FILESARRAY=("*.ipa")

count=1

for element in ${FILESARRAY[@]}
  do
    case "$count" in
      1) mv "$element" ~/Desktop/tmp1;
          ((count++));;
      2) mv "$element" ~/Desktop/tmp2;
          ((count++));;
      3) mv "$element" ~/Desktop/tmp3;
          ((count++));;
      4) mv "$element" ~/Desktop/tmp4;
          count=1;;
esac
  done

  resign() {
    for element in $1
     do
        unzip "$element"
        FILENAME="${element%.ipa}"

        /usr/libexec/PlistBuddy -x -c "print :Entitlements " /dev/stdin <<< $(security cms -D -i ./$PROVISION) > entitlements.plist

        rm -r "Payload/$FILENAME.app/_CodeSignature" 2> /dev/null | true
        cp "$PROVISION" "Payload/$FILENAME.app/embedded.mobileprovision"

        /usr/bin/codesign -fv -s "$CERTIFICATE" "Payload/$FILENAME.app" --entitlements entitlements.plist

        zip -qry "resigned.$element" Payload
        rm -r "Payload" 2> /dev/null | true   #required to work correctly

        # copy all new resigned files to the new directory
        mv ./resigned.* ~/Desktop/NEW\ RESIGNED\ APPS
        # move all old files to another directory
        mv ./"$element" ~/Desktop/OLD\ APPS
    done

    rm -r "entitlements.plist" 2> /dev/null | true

  }

cd ~/Desktop/tmp1
tmp1ARRAY=("*.ipa")
resign "${tmp1ARRAY[@]}" &
cd ~/Desktop/tmp2
tmp2ARRAY=("*.ipa")
resign "${tmp2ARRAY[@]}" &
cd ~/Desktop/tmp3
tmp3ARRAY=("*.ipa")
resign "${tmp3ARRAY[@]}" &
cd ~/Desktop/tmp4
tmp4ARRAY=("*.ipa")
resign "${tmp4ARRAY[@]}" &
wait

# for element in ${FILESARRAY[@]}
#  do
#     unzip "$element"
#     FILENAME="${element%.ipa}"
#
#     /usr/libexec/PlistBuddy -x -c "print :Entitlements " /dev/stdin <<< $(security cms -D -i ./$PROVISION) > entitlements.plist
#
#     rm -r "Payload/$FILENAME.app/_CodeSignature" 2> /dev/null | true
#     cp "$PROVISION" "Payload/$FILENAME.app/embedded.mobileprovision"
#
#     /usr/bin/codesign -fv -s "$CERTIFICATE" "Payload/$FILENAME.app" --entitlements entitlements.plist
#
#     zip -qry "resigned.$element" Payload
#     rm -r "Payload" 2> /dev/null | true   #required to work correctly
#
#     # copy all new resigned files to the new directory
#     mv ./resigned.* ~/Desktop/NEW\ RESIGNED\ APPS
#     # move all old files to another directory
#     mv ./"$element" ~/Desktop/OLD\ APPS
# done
#
# rm -r "entitlements.plist" 2> /dev/null | true
#

rm -r ~/Desktop/tmp1
rm -r ~/Desktop/tmp2
rm -r ~/Desktop/tmp3
rm -r ~/Desktop/tmp4
echo
echo
echo ------- FILES HAVE BEEN RESIGNED --------
echo ------- RESIGNED APPS HAVE BEEN MOVED TO \'NEW RESIGNED APPS\' FOLDER ON DESKTOP ----------
echo ------- OLD APPS HAVE BEEN MOVED TO \'OLD APPS\' FOLDER ON DESKTOP --------
echo
echo
