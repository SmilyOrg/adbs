# adbs
Sets the screen density and size via adb with the provided device name (list maintained by dpi.lv)

```
adbs (adb screen)

Sets the screen density and size via adb with the provided device name.

List maintained by dpi.lv

Usage: adbs DEVICE NAME

Examples:

adbs nexus 7 13  Sets the density and size to the 2013 edition of the Nexus 7.
adbs reset       Resets the density and size.
adbs --help      Shows help.

  -d, --dry        Dry run - don't execute any adb commands.
  -h, --help       Print this help message.
  -u, --update     Update the list from the default remote server.
```
