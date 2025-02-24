#!/bin/sh
echo "$0" "$@"
progdir="$(dirname "$0")"
cd "$progdir" || exit 1
[ -f "$progdir/debug" ] && set -x
PAK_NAME="$(basename "$progdir")"

show_qr() {
    message="$1"
    killall sdl2imgshow >/dev/null 2>&1 || true
    echo "$message"
    "$progdir/bin/sdl2imgshow" \
        -i "$progdir/res/background.png" \
        -P "center" \
        -S "original" \
        -i "$USERDATA_PATH/$PAK_NAME/qr.png" \
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
        mkdir -p "$USERDATA_PATH/$PAK_NAME"
        find "Roms" | sort >"$USERDATA_PATH/$PAK_NAME/roms.txt"

        response=$(curl -k --http1.1 POST \
            -H "Content-Type: text/plain" \
            -H "Expect:" \
            --data-binary "@$USERDATA_PATH/$PAK_NAME/roms.txt" \
            https://minuicm.com/api/generateUrl)

        url=$(echo "$response" | sed -n '1p')
        echo "$response" | sed -n '2p' | base64 -d >"$USERDATA_PATH/$PAK_NAME/qr.png"

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

    #check if the response is an error
    if echo "$response" | grep -q "error"; then
        show_message "Collection not found! Double check the ID" 2
        exit 1
    else
        title=$(echo "$response" | sed -n '1p')
        mkdir -p "$SDCARD_PATH/Collections"
        echo "$response" | sed '1d' > "$SDCARD_PATH/Collections/$title.txt"
        collection_done "$title"
    fi
}

main() {
    if [ "$PLATFORM" = "tg3040" ] && [ -z "$DEVICE" ]; then
        export DEVICE="brick"
        export PLATFORM="tg5040"
    fi

    allowed_platforms="tg5040 rg35xxplus"
    if ! echo "$allowed_platforms" | grep -q "$PLATFORM"; then
        show_message "$PLATFORM is not a supported platform" 2
        return 1
    fi

    if [ ! -f "$progdir/bin/minui-keyboard-$PLATFORM" ]; then
        show_message "$progdir/bin/minui-keyboard-$PLATFORM not found" 2
        return 1
    fi
    if [ ! -f "$progdir/bin/minui-list-$PLATFORM" ]; then
        show_message "$progdir/bin/minui-list-$PLATFORM not found" 2
        return 1
    fi

    chmod +x "$progdir/bin/minui-keyboard-$PLATFORM"
    chmod +x "$progdir/bin/minui-list-$PLATFORM"
    chmod +x "$progdir/bin/sdl2imgshow"

    minui_list_file="/tmp/minui-list"
    rm -f "$minui_list_file"
    touch "$minui_list_file"

    {
        echo "Export Roms list"
        echo "Download Collection"
        echo "Remove Collection"
    } >>"$minui_list_file"

    option="$("$progdir/bin/minui-list-$PLATFORM" --format text --header "Collection Manager" --file "$minui_list_file")"
    exit_code=$?

    echo "List exit code: '$exit_code'"

    if echo "$option" | grep -q "^Export Roms list$"; then
        export_roms
    elif echo "$option" | grep -q "^Download Collection$"; then
        enabled="$(cat /sys/class/net/wlan0/operstate)"
        if [ "$enabled" != "up" ]; then
            show_message "You need to be connected to WiFi first" 2
            return
        else
            output=$("$progdir/bin/minui-keyboard-$PLATFORM" --header "Enter Collection ID")
            exit_code=$?
            if [ "$exit_code" -eq 0 ]; then
                import_collection "$output"
            fi
        fi
    elif echo "$option" | grep -q "^Remove Collection$"; then
        #list all the collections in the collections folder
        collections=$(ls "$SDCARD_PATH/Collections")
        #if collections is empty, show message and exit
        if [ -z "$collections" ]; then
            show_message "No collections found" 2
            exit "$exit_code"
        fi

        collection=$(echo "$collections" | "$progdir/bin/minui-list-$PLATFORM" --format text --header "Select Collection to remove" --confirm-text "REMOVE" --cancel-text "CANCEL" --file -)
        exit_code=$?
        if [ "$exit_code" -eq 0 ]; then
            rm "$SDCARD_PATH/Collections/$collection"
            show_message "Collection removed" 2
        fi
    fi

    exit "$exit_code"
}

main "$@" >"$LOGS_PATH/$PAK_NAME.txt" 2>&1
