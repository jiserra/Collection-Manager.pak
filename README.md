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

Browse to `Tools > Collection Manager` and press `A` to turn on the collection manager.

### Export Roms List

This will export the roms list to the `roms.txt` file and upload the file to the server. A QR code will be displayed to allow you to download the roms list.

### Download Collection

This will download the specified collection from the server and copy it to the `Collections` folder on your SD card.

### Remove Collection

This will list all the collections in the `Collections` folder and allow you to remove one.

### Debug Logging

To enable debug logging, create a file named `debug` in the pak folder. Logs will be written to the `$SDCARD_PATH/.userdata/$PLATFORM/logs/` folder.

## Development

### Testing Versions

Each CI run will create a new release artifact and attach it to the workflow run. You can download the artifact from the workflow run page.

### Manual Release

Create a new git tag and upload it to Github:

```bash
git tag 0.1.0
git push origin 0.1.0
```

This will trigger a release workflow on Github Actions.

### Automatic Release

After at least 1 release exists, you can run the `bump-version` workflow manually in the Github Actions tab. This workflow requires a MINUI_ACCESS_TOKEN environment variable to be set in the repository secrets.
