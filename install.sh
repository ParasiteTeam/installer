#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

TEAM="ParasiteTeam"
REPOS=("kext" "library")
TMP_DIR="/tmp/parasite"

FRAMEWORK="ParasiteRuntime.framework"
FRAMEWORK_DEST="/Library/Frameworks"
KEXT="Parasite.kext"
KEXT_DEST="/Library/Extensions"
LA="com.shinvou.parasite.loader.plist"
LA_DEST="/Library/LaunchDaemons"

mkdir -p $TMP_DIR
cd $TMP_DIR

for REPO in "${REPOS[@]}"; do
  LINK=$(curl -s https://api.github.com/repos/$TEAM/$REPO/releases/latest | grep 'browser_' | cut -d\" -f4)
  echo "Downloading...$REPO"
  curl -sL $LINK > "$REPO.zip"
  echo "Unpacking...$REPO"
  unzip -qq "$REPO.zip"
  rm "$REPO.zip"
done

mv $FRAMEWORK "$FRAMEWORK_DEST/$FRAMEWORK"
chmod -R 755 "$FRAMEWORK_DEST/$FRAMEWORK"
chown -R root:wheel "$FRAMEWORK_DEST/$FRAMEWORK"
mv $KEXT "$KEXT_DEST/$KEXT"
chmod -R 755 "$KEXT_DEST/$KEXT"
chown -R root:wheel "$KEXT_DEST/$KEXT"
mv $LA "$LA_DEST/$LA"
chmod 644 "$LA_DEST/$LA"
chown root:wheel "$LA_DEST/$LA"

mkdir -p "/Library/Parasite/Extensions"

kextload "$KEXT_DEST/$KEXT"


rm -r $TMP_DIR
