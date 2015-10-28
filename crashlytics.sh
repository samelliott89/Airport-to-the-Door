#!/bin/bash

# ./Fabric.framework/run 8c52c89c4204a4e3a71ea26a6e5d2cfc97b02b91 c12dfe4dffc9a0f2c191a596d0218c2a3dba7c7c2c5f282eea82d82bcc97be71

CORDOVA_PROJECT="Ruby"
CRASHLYTICS_KEY="8c52c89c4204a4e3a71ea26a6e5d2cfc97b02b91"
ZIPFILE="extras/com.crashlytics.sdk.ios-default.zip"

# Requires:
# - build ios to have run
# - Ruby to be installed
# - Gem xcoder
# - ZIPFILE to be downloaded

TEMP_DIR=$(mktemp -d -t crashlytics)
TEMP_Framework=$(mktemp -d -t crashlytics.Framework)

echo "Extracting latest Crashlytics"
ditto -xk "$ZIPFILE" "$TEMP_DIR"

echo "Extracting Framework"
ditto -xk "$ZIPFILE" "$TEMP_Framework"

echo "Removing previous crashlytics framework"
rm -rf platforms/ios/Crashlytics.framework

echo "Copying the Crashlytics.framework"
mv "$TEMP_Framework/Crashlytics.framework" "platforms/ios/Crashlytics.framework"

flag=$(grep "Crashlytics/Crashlytics.h" "platforms/ios/$CORDOVA_PROJECT/Classes/AppDelegate.m")
if [ -z "$flag" ]
then
  echo "Adding Crashlytics header to AppDelegate.m"
sed -i '' '1i\
#import <Crashlytics/Crashlytics.h>\
' "platforms/ios/$CORDOVA_PROJECT/Classes/AppDelegate.m"
else
  echo "Crashlytics Header already found in AppDelegate.m"
fi

flag=$(grep "startWithAPIKey" "platforms/ios/$CORDOVA_PROJECT/Classes/AppDelegate.m")
if [ -z "$flag" ]
then
  echo "Adding Crashlytics startWithAPIKey to AppDelegate.m"

sed -i '' "
/didFinishLaunchingWithOptions/ {
n
a\\
[Crashlytics startWithAPIKey:@\"$CRASHLYTICS_KEY\"];
}" "platforms/ios/$CORDOVA_PROJECT/Classes/AppDelegate.m"

else
  echo "Crashlytics startWithAPIKey already in AppDelegate.m"
fi

echo "cleaning up"
rm -rf "$TEMP_DIR"
rm -rf "$TEMP_Framework"