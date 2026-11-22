#!/bin/sh
# SSH Server toggle for TrimUI stock firmware (tg5050: Smart Pro S).
# Enables/disables the stock openssh daemon and persists the choice across reboots.
# Based on the community-verified nextui-nativessh-pak command sequence.

MARKER_BEGIN='# >>> nextui-ssh-managed >>>'
MARKER_END='# <<< nextui-ssh-managed <<<'
AUTO_PATH="$USERDATA_PATH/auto.sh"
STATE_PATH="$SHARED_USERDATA_PATH/.minui/ssh_enabled"

SSHD=/usr/sbin/sshd
SYSTEMVAL=/usr/trimui/bin/systemval

# Re-apply the persisted setting on every boot when invoked from auto.sh.
# auto.sh sources this file with "--boot" so it must not toggle or show UI.
if [ "$1" = "--boot" ]; then
	if [ -f "$STATE_PATH" ] && [ -x "$SSHD" ] && [ -x "$SYSTEMVAL" ]; then
		"$SYSTEMVAL" enablessh 1 >/dev/null 2>&1
		pidof sshd >/dev/null 2>&1 || "$SSHD" >/dev/null 2>&1
	fi
	exit 0
fi

if [ ! -x "$SSHD" ] || [ ! -x "$SYSTEMVAL" ]; then
	show2.elf --mode=simple --image "$SDCARD_PATH/.system/res/logo.png" \
		--text="SSH unavailable: stock sshd/systemval not found" --timeout=5
	exit 1
fi

if [ -f "$STATE_PATH" ]; then
	# currently enabled -> disable
	rm -f "$STATE_PATH"
	"$SYSTEMVAL" enablessh 0 >/dev/null 2>&1
	killall -9 sshd >/dev/null 2>&1
	MSG="SSH disabled"
else
	# currently disabled -> enable
	mkdir -p "$(dirname "$STATE_PATH")"
	: > "$STATE_PATH"
	"$SYSTEMVAL" enablessh 1 >/dev/null 2>&1
	pidof sshd >/dev/null 2>&1 || "$SSHD" >/dev/null 2>&1
	MSG="SSH enabled (port 22, user root)"
fi

# Ensure auto.sh re-applies the setting on next boot, without duplicating the block.
mkdir -p "$(dirname "$AUTO_PATH")"
[ -f "$AUTO_PATH" ] || : > "$AUTO_PATH"
if ! grep -qF "$MARKER_BEGIN" "$AUTO_PATH"; then
	# Absolute path: auto.sh runs with a different cwd than this pak.
	SSH_PAK="$SDCARD_PATH/Tools/$PLATFORM/SSH Server.pak/launch.sh"
	printf '\n%s\n"%s" --boot\n%s\n' "$MARKER_BEGIN" "$SSH_PAK" "$MARKER_END" >> "$AUTO_PATH"
fi

show2.elf --mode=simple --image "$SDCARD_PATH/.system/res/logo.png" --text="$MSG" --timeout=3
