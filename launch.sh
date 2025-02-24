#!/bin/sh
echo "$0" "$@"
progdir="$(dirname "$0")"
cd "$progdir" || exit 1
set -x

show_qr() {
    message="$1"
    killall sdl2imgshow >/dev/null 2>&1 || true
    echo "$message"
    "$progdir/bin/sdl2imgshow" \
        -i "$progdir/res/background.png" \
        -P "center" \
        -S "original" \
        -i "$progdir/qr.png" \
        -f "$progdir/res/fonts/BPreplayBold.otf" \
        -s 27 \
        -c "220,220,220" \
        -p "topcenter" \
        -t "Collections: $message" \
        -p "bottomcenter" \
        -t "Press any key to dismiss" \
        -w
}

show_message() {
    message="$1"
    seconds="$2"

    if [ -z "$seconds" ]; then
        seconds="forever"
    fi

    killall sdl2imgshow >/dev/null 2>&1 || true
    echo "$message"
    if [ "$seconds" = "forever" ]; then
        "$progdir/bin/sdl2imgshow" \
            -f "$progdir/res/fonts/BPreplayBold.otf" \
            -s 27 \
            -c "220,220,220" \
            -q \
            -t "$message" >/dev/null 2>&1 &
    else
        "$progdir/bin/sdl2imgshow" \
            -f "$progdir/res/fonts/BPreplayBold.otf" \
            -s 27 \
            -c "220,220,220" \
            -q \
            -t "$message" >/dev/null 2>&1
        sleep "$seconds"
    fi
}

collection_done() {
    collection="$1"
    killall sdl2imgshow >/dev/null 2>&1 || true
    "$progdir/bin/sdl2imgshow" \
        -i "$progdir/res/background.png" \
        -f "$progdir/res/fonts/BPreplayBold.otf" \
        -s 27 \
        -c "220,220,220" \
        -p "center" \
        -t "Collection $collection added!" \
        -q >/dev/null 2>&1
    sleep 1
}

export_roms() {
    enabled="$(cat /sys/class/net/wlan0/operstate)"
    if [ "$enabled" != "up" ]; then
        show_message "You need to be connected to WiFi first" 2
        return
    else
        show_message "Exporting Roms list..."
        cd "$SDCARD_PATH" || exit 1
        find "Roms" | sort > roms.txt

        response=$(curl -k --http1.1 POST \
            -H "Content-Type: text/plain" \
            -H "Expect:" \
            --data-binary "@roms.txt" \
            https://minuicm.com/api/generateUrl)

        url=$(echo "$response" | sed -n '1p')
        echo "$response" | sed -n '2p' | base64 -d > "$progdir/qr.png"

        show_qr "$url"
    fi
}

import_collection() {
    show_message "Downloading Collection..."
    id="$1"
    cd "$progdir" || exit 1
    response=$(curl -k --http1.1 \
        -H "Content-Type: text/plain" \
        -H "Expect:" \
        https://minuicm.com/api/getCollection/"$id")

    title=$(echo "$response" | sed -n '1p')
    mkdir -p "$SDCARD_PATH/Collections"
    echo "$response" | sed '1d' > "$SDCARD_PATH/Collections/$title.txt"
    collection_done "$title"
}

main() {
    if [ "$PLATFORM" = "tg3040" ] && [ -z "$DEVICE" ]; then
        export DEVICE="brick"
    fi
    option="$(echo -e "Export Roms list\nDownload Collection" | "$progdir/bin/minui-list" --format text --header "Collection Manager" --file -)"
    exit_code=$?

    echo "List exit code: '$exit_code'"

    if echo "$option" | grep -q "Export Roms list"; then
        export_roms
    elif echo "$option" | grep -q "Download Collection"; then
        enabled="$(cat /sys/class/net/wlan0/operstate)"
        if [ "$enabled" != "up" ]; then
            show_message "You need to be connected to WiFi first" 2
            return
        else
            output=$("$progdir/bin/minui-keyboard"  --header "Enter Collection ID")
            import_collection "$output"
        fi
    fi

    exit "$exit_code"
}
