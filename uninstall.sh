#!/bin/bash
#
# uninstall/removes g910-gkeys.
#
# options:
#  -a: will also remove /etc/g910-gkeys/ configuration directory.
#  -d: dry-run: will display actions without doing anything
#
# TODO: remove possible faulty previous versions files (in /etc/systemd/system
#       and /usr/lib/systemd/system)
#
# BUGS: files.txt is not correct:
#     - it does not contain directories.
#     - files added later (_pycache__) are not removed
#   I would suggest to use egg directory, instead of a list of files.
#

FILESLST=files.txt
PIPCMD=""
REMOVECONF=n
DRYRUN=""
CONFDIR=/etc/g910-gkeys

# check if we are 'root' user.
(( $EUID != 0 )) && echo Must be root to run this script. Exiting. &&
    exit 1

usage() {
    echo "usage: ${0##*/}" [-a][-d]
    echo Exiting.
}

# in case we need more options, better to use getopts.
while getopts ad opt; do
    case "$opt" in
        a) REMOVECONF=y
           ;;
        d) DRYRUN="echo"
           ;;
        *) usage
           exit 1
           ;;
    esac
done

# determine if we should use pip or pip3, pip3 being preferred
for p in pip pip3; do
    type "$p" &>/dev/null && PIPCMD="$p"
done

# stops and disable service
systemctl disable --now g910-gkeys

# remove all installed files (not configuration files, in /etc/g910-gkeys)
[[ -f "$FILESLST" ]] && ${DRYRUN} xargs --arg-file="$FILESLST" rm -rf

# remove configuration file[s] if requested
[[ "$REMOVECONF" = y ]] && ${DRYRUN} rm -rf "$CONFDIR"

if [[ -n "$PIPCMD" ]]; then
    PIPLST=$($PIPCMD list | grep 'g910-gkeys' | cut -d " " -f 1)
    [[ -n "$PIPLST" ]] && ${DRYRUN} ${PIPCMD} uninstall "$PIPLST"
fi

echo
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo + Please remove "g910-gkeys.service" in "/usr/lib/systemd/system"
echo + and "/etc/systemd/system.conf", if they exist.
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
