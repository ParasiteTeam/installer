#!/bin/bash
#####################################
# Parasite Installer Justin0a0 2016 #
#####################################

if [ "$EUID" -ne 0 ]; then
    printf "\nPlease run this script as root.\n\n"
    exit
fi

REPOS=('kext' 'library' 'Crucible')
DIRS=('/tmp/parasite' '/Library/Parasite/Crucible' '/Library/Parasite/Extensions' '/Library/Parasite')
KEXT=('Parasite.kext' '/Library/Extensions')
FRAMEWORK=('ParasiteRuntime.framework' '/Library/Frameworks')
CRUCIBLE=('Crucible.bundle' '/Library/Parasite/Extensions')

funcTestFiles() {
  if [ -e ${KEXT[1]}/${KEXT[0]} ] || [ -e ${FRAMEWORK[1]}/${FRAMEWORK[0]} ] || [ -e ${CRUCIBLE[1]}/${CRUCIBLE[0]} ]
    then
      return 0
    else
      return 1
  fi
}

funcTestInstall() {
  if [ $1 ];
    then
      if funcTestFiles;
        then
          printf '\nAlready installed either uninstall \nor Update Parasite.\n\n'
          funcRemoveTemp
          exit
      fi
    else
      if ! funcTestFiles;
        then
          printf '\nParasite not found!\nPlease Install first.\n\n'
          funcRemoveTemp
          exit
      fi
  fi
}

funcDownload() {
  printf 'Downloading Files...\n'
  for REPO in "${REPOS[@]}"; do
    LINK=$(curl -s https://api.github.com/repos/ParasiteTeam/$REPO/releases/latest | grep 'browser_' | cut -d\" -f4)
    printf "Downloading $REPO...\n"
    curl -sL $LINK > "$REPO.zip"
    printf "Done.\n"
    printf "Unpacking $REPO...\n"
    unzip -qq "$REPO.zip"
    printf "Done.\n"
    rm "$REPO.zip"
  done
}

funcMoveFiles() {
  printf 'Moving files into place...\n'
  mv -f ${KEXT[0]} ${KEXT[1]}/${KEXT[0]}
  mv -f ${FRAMEWORK[0]} ${FRAMEWORK[1]}/${FRAMEWORK[0]}
  mv -f ${CRUCIBLE[0]} ${CRUCIBLE[1]}/${CRUCIBLE[0]}
}

funcSetPerms() {
  printf 'Setting file permissions...\n'
  chmod -R 755 {${KEXT[1]}/${KEXT[0]},${FRAMEWORK[1]}/${FRAMEWORK[0]}}
  chown -R root:wheel {${KEXT[1]}/${KEXT[0]},${FRAMEWORK[1]}/${FRAMEWORK[0]}}
}

funcKext() {
  if [ $1 ];
    then 
      kextload ${KEXT[1]}/${KEXT[0]} 2>&1
      if [ $? != 0 ];
        then
          printf 'Kext loading failed. Did you read the notice?\nIf it is disabled please let us know\nhttps://github.com/ParasiteTeam/installer/issues'
        else
          printf 'Kext successfully loaded!\n'
      fi
    else
      kextunload ${KEXT[1]}/${KEXT[0]} 2>&1
      if [ $? != 0 ];
        then
          printf 'Kext is currently unloaded.\n'
        else
          printf 'Kext successfully unloaded!\n'
      fi
  fi
}

funcRemoveFiles() {
  printf 'Removing files...\n'
  rm -rf ${KEXT[1]}/${KEXT[0]}
  rm -rf ${FRAMEWORK[1]}/${FRAMEWORK[0]}
  rm -rf ${CRUCIBLE[1]}/${CRUCIBLE[0]}
  rm -f ${DIRS[3]}/.accepted
}

funcRemoveDirs() {
  printf '\n-----------------------NOTICE---------------------------\nRemoving Directories will delete anything you have\ninstalled for Parasite or Crucible.\n--------------------------------------------------------\n'
  printf 'Would you like to remove the directories?[Y/n]'
  read ans
    case "$ans" in
    y|Y)
      printf 'Removing Parasite directories...\n'
      rm -rf ${DIRS[3]}
    ;;
    *);;
    esac
}

funcRemoveTemp() {
  rm -r ${DIRS[0]}
}

funcNotices() {
  printf '\n-----------------------NOTICE---------------------------\nParasite requires kext signature checking to be disabled.\nTo disable please reboot your computer into recovery mode\nOpen terminal from the utilities menu and enter\n"csrutil enable --without kext" to disable kext signature\nchecking or "csrutil disable" to disable SIP in its\nentirety (Not Recomended)\n--------------------------------------------------------\n'
  printf 'Have you already disabled checking kext signatures?[Y/n]'
  read ans
    case "$ans" in
    y|Y);;
    *) exit;;
    esac
  
  printf '\n-----------------------WARNING--------------------------\nParasite allows runtime code injection. As such it is\npossible for somebody to abuse this for malware and\nother nefarious purposes. Please take note to what you\ninstall, and only install from trusted sources!!!\n--------------------------------------------------------\n'
  printf 'Do you understand and accept the above risks with Parasite?[Y/n]'
  read ans
    case "$ans" in
    y|Y);;
    *) exit;;
    esac
}

for DIR in "${DIRS[@]}"; do
  mkdir -p $DIR
done

cd ${DIRS[0]}

select choice in 'Install Parasite' 'Update Parasite' 'Uninstall Parasite' 'Exit'
do
  case $REPLY in
    1)
      if [[ ! -e  ${DIRS[3]}/.accepted ]]; then
        funcNotices
      fi
      funcTestInstall 1
      printf 'Installing Parasite...\n'
      funcDownload
      funcMoveFiles
      funcSetPerms
      funcKext 1
      printf 'Parasite successfully installed!\n'
      touch ${DIRS[3]}/.accepted
      funcRemoveTemp
    ;;
    2)
      funcTestInstall
      printf 'Updating Parasite...\n'
      funcKext
      funcRemoveFiles
      funcDownload
      funcMoveFiles
      funcSetPerms
      funcKext 1
      printf 'Parasite updated!\n'
      funcRemoveTemp
    ;;
    3)
      funcTestInstall
      printf 'Uninstalling Parasite...\n'
      funcKext
      funcRemoveFiles
      funcRemoveDirs
      printf 'Parasite has been uninstalled.\nSorry to see you go :(\n'
    ;;
    4)
      printf '\nExiting...\n\n'
    ;;
  esac
  break
done
