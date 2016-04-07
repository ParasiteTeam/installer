#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    printf "\nPlease run this script as root.\n\n"
    exit
fi

REPOS=("kext" "library" "Crucible")
TMP_DIR="/tmp/parasite"

LA="com.shinvou.parasite.loader.plist"
LA_DEST="/Library/LaunchDaemons"

KEXT="Parasite.kext"
KEXT_DEST="/Library/Extensions"

FRAMEWORK="ParasiteRuntime.framework"
FRAMEWORK_DEST="/Library/Frameworks"

CRUCIBLE="Crucible.bundle"
CRUCIBLE_DEST="/Library/Parasite/Extensions"

mkdir -p "/Library/Parasite/Crucible"
mkdir -p "/Library/Parasite/Extensions"
mkdir -p $TMP_DIR

cd $TMP_DIR

for REPO in "${REPOS[@]}"; do
    LINK=$(curl -s https://api.github.com/repos/ParasiteTeam/$REPO/releases/latest | grep 'browser_' | cut -d\" -f4)
    printf "Downloading $REPO ...\n"
    curl -sL $LINK > "$REPO.zip"
    printf "Done.\n"
    printf "Unpacking $REPO ...\n"
    unzip -qq "$REPO.zip"
    printf "Done.\n"
    rm "$REPO.zip"
done

mv $LA "$LA_DEST/$LA"
chmod 644 "$LA_DEST/$LA"
chown root:wheel "$LA_DEST/$LA"

mv $KEXT "$KEXT_DEST/$KEXT"
chmod -R 755 "$KEXT_DEST/$KEXT"
chown -R root:wheel "$KEXT_DEST/$KEXT"

mv $FRAMEWORK "$FRAMEWORK_DEST/$FRAMEWORK"
chmod -R 755 "$FRAMEWORK_DEST/$FRAMEWORK"
chown -R root:wheel "$FRAMEWORK_DEST/$FRAMEWORK"

mv $CRUCIBLE "$CRUCIBLE_DEST/$CRUCIBLE"

EXIT_STATUS=$(kextload "$KEXT_DEST/$KEXT" 2>&1)

if [ -z "$EXIT_STATUS" ]; then
    printf "\nSuccessfully installed Parasite.\n"
else
    printf "\nThe kext couldn't be loaded. Please make sure you either disabled kext validation (csrutil enable --without kext) or completely disabled SIP (csrutil disable).\n\n"
fi

rm -rf $TMP_DIR
