# minui-collection-manager.pak

A MinUI Collection Manager for RG35XX/TG3040/TG5040

## Requirements

This pak is designed and tested on the following MinUI Platforms and devices:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro
- `rg35xxplus`: RG-35XX Plus, RG-34XX, RG-35XX H, RG-35XX SP

Use the correct platform for your device.

## Installation

1. Mount your MinUI SD card.
2. Download the latest release from Github. It will be named `Collection Manager.pak.zip`.
3. Copy the zip file to `/Tools/$PLATFORM/Collection Manager.pak.zip`. Please ensure the new zip file name is `Collection Manager.pak.zip`, without a dot (`.`) between the words `Collection` and `Manager`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/$PLATFORM/Collection Manager.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your MinUI device.

## Usage

> [!IMPORTANT]
> If the zip file was not extracted correctly, the pak may show up under `Tools > Collection Manager`. Rename the folder to `Collection Manager.pak` to fix this.

Browse to `Tools > Collection Manager` and press `A` to open the Collection Manager.

### Export Roms List

This will export the roms list to a `roms.txt` file and upload the file to the server. A URL with an ID to [minuicm.com](https://minuicm.com) and a QR code will be displayed to allow you to start creating Collections based on your own Roms list of your device.

### Download Collection

This will download a specific collection that you created in the web, and copy it to the `Collections` folder on your SD card so you can enjoy your Collection!

### Remove Collection

This will list all the collections in the `Collections` folder and allow you to remove anyone that you like.
