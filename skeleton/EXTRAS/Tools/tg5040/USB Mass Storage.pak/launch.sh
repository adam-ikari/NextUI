#!/bin/sh
# Export the SD card to a USB host via the stock USB Mass Storage app.
# WARNING: exposing the SD card to a host while NextUI runs from it can corrupt data.
# Based on josegonzalez/trimui-brick-usb-mass-storage-pak (community-verified on tg5040).
PAK_DIR="$(dirname "$0")"
cd "$PAK_DIR" || exit 1

STOCK_APP=/usr/trimui/apps/usb_storage/launch.sh

show() {
	show2.elf --mode=simple --image "$SDCARD_PATH/.system/res/logo.png" --text="$1" --timeout=4
}

if [ ! -f "$STOCK_APP" ]; then
	show "USB Mass Storage unavailable: stock app not found"
	exit 1
fi

show "USB Mass Storage: connect USB cable, then OK. Do not power off during transfer."
echo "1" > /tmp/stay_awake
trap 'rm -f /tmp/stay_awake' EXIT INT TERM HUP QUIT
"$STOCK_APP"
sync
