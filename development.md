## Other notes

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

After at least 1 release exists, you can run the `RELEASE` workflow manually in the Github Actions tab.
