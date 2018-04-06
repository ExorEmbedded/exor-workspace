#!/bin/bash
#
# Generate basic commit log between two versions
#
# Instead of relying on text in commit messages, which may contain subtask
# details, we grab the ticket summary from Unfuddle.
#
# NOTES:
#   - only considers commits contaning a #ticket_id reference
#   - output most likely to require manual check and cleanup

UNFUDDLE_PROJECT_BSP="38"
UNFUDDLE_PROJECT_JMOBILE="1"

# XXX *WARNING* should diff only 999 tags because merges to 1.0.x do not contain all commit messages!!!
[ -z ${LOG_FROM_TAG} ] && LOG_FROM_TAG="rootfs-1.999.122"
[ -z ${LOG_TO_TAG} ] && LOG_TO_TAG="rootfs-1.999.180"

TICKET_IDS=$(./bsptool cmd git log --pretty="%B" ${LOG_FROM_TAG}..${LOG_TO_TAG} | \
    grep "^#[0-9]\+" | sed 's/^#\([0-9]\+\).*/\1/' | cut -d ' ' -f 1 | sort -u -n)

echo "Generating ticket log from ${LOG_FROM_TAG} to ${LOG_TO_TAG}"
echo "Grabbing ticket names from Unfuddle.."
echo "Please enter username"
read -s UNFUDDLE_USER
echo "Please enter password"
read -s UNFUDDLE_PASS
echo
echo "#TICKET_ID [PRIORITY (5=highest)] TICKET_SUMMARY"

grab_ticket_info()
{
    id=$1

    echo -n "#${id} "

    INFO=$(curl --fail -s -u "${UNFUDDLE_USER}:${UNFUDDLE_PASS}" https://exorint.unfuddle.com/api/v1/projects/${UNFUDDLE_PROJECT_BSP}/tickets/by_number/${id}.json 2>/dev/null)
    if [ $? -ne 0 ]; then
        # could not find ticket in BSP project, try JMobile Suite project
        INFO=$(curl --fail -s -u "${UNFUDDLE_USER}:${UNFUDDLE_PASS}" https://exorint.unfuddle.com/api/v1/projects/${UNFUDDLE_PROJECT_JMOBILE}/tickets/by_number/${id}.json)
    fi

    echo ${INFO} | python -c "import json,sys;obj=json.load(sys.stdin);sys.stdout.write('[' + obj['priority'] + '] ');print obj['summary'];" 
}

for id in $TICKET_IDS; do
    grab_ticket_info ${id}
done
