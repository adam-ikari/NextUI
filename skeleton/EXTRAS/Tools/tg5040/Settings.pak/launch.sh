#!/bin/sh

cd "$(dirname "$0")" || exit 1
./settings.elf > settings.log 2>&1

# Settings can register an external tool by writing its name to this request file
# and exiting. Run it within the same PAK lifecycle so returning goes back to the menu.
REQUEST="$SHARED_USERDATA_PATH/.minui/settings_launch"
TOOL=$(cat "$REQUEST" 2>/dev/null)
rm -f "$REQUEST"

case "$TOOL" in
ledcontrol)
	# Remove the stock LED daemon so it stops overwriting our settings.
	rm -R /etc/LedControl 2>/dev/null
	if [ -f /etc/init.d/lcservice ]; then
		/etc/init.d/lcservice disable
		rm /etc/init.d/lcservice 2>/dev/null
	fi

	# Seed defaults once; afterwards the shared file belongs to the user.
	for cfg in ledsettings.txt ledsettings_brick.txt ledsettings_brickpro.txt; do
		TARGET="$SHARED_USERDATA_PATH/$cfg"
		if [ ! -f "$TARGET" ] && [ -f "$cfg" ]; then
			cp "$cfg" "$TARGET"
		fi
	done

	./ledcontrol.elf > ledcontrol.log 2>&1
	;;
esac
