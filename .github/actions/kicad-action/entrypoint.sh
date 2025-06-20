#!/usr/bin/env bash

set -o nounset
set -o pipefail

DIRECTORY=${1:-""}
SCH_FILES=${2:-""}
PCB_FILES=${3:-""}

check_erc() {
    local BASENAME=$1
    local OPTS=${2:-""}
    echo "Running ERC on ${BASENAME}.kicad_sch"
    kicad-cli sch erc --exit-code-violations ${OPTS} ${BASENAME}.kicad_sch
    if [[ $? -ne 0 ]]; then
        RETCODE=1
    fi
    echo "---------- BEGIN ERC REPORT ----------"
    cat ${BASENAME}-erc.rpt
    echo "---------- END ERC REPORT ----------"
}

check_drc() {
    local BASENAME=$1
    local OPTS=${2:-""}
    echo "Running DRC on ${BASENAME}.kicad_pcb"
    kicad-cli pcb drc --schematic-parity --exit-code-violations ${OPTS} ${BASENAME}.kicad_pcb
    if [[ $? -ne 0 ]]; then
        RETCODE=1
    fi
    echo "---------- BEGIN DRC REPORT ----------"
    cat ${BASENAME}-drc.rpt
    echo "---------- END DRC REPORT ----------"
}

cd ${DIRECTORY}
echo "Running ERC and DRC checks in ${DIRECTORY}"
ls -1 *.kicad_*
RETCODE=0

for i in ${SCH_FILES}; do
    check_erc ${i} --severity-error
done

for i in ${PCB_FILES}; do
    check_drc ${i} --severity-error
done

exit ${RETCODE}
