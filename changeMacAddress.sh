#!/bin/bash
# Please fill in below variables with your MAC addresses!
MAC_MACBOOK=
MAC_IPHONE=
SUPPORTED_DEVICES=("iPhone" "Macbook")

usage() { echo "Usage: $0 ['iPhone'|'Macbook']" 1>&2; echo ""; exit 1; }

isIn () {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

changeMacAddressTo() {
    DEVICE=$1
    case "$DEVICE" in
        "iPhone") sudo ifconfig en0 ether $MAC_IPHONE
        ;;
        "Macbook") sudo ifconfig en0 ether $MAC_MACBOOK
        ;;
    esac
    sudo ifconfig en0 down
    sudo ifconfig en0 up
}

DEVICE=$1
isIn $DEVICE "${SUPPORTED_DEVICES[@]}"
existed=$?
if [ $existed -eq 1 ]; then
    usage
else
    changeMacAddressTo $DEVICE
fi
exit 0
