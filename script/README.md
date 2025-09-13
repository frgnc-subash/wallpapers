# This is wana.

Ammmm... hi ☺️ — this is **wana**. I'm a simple bash script that can rename your wallpapers.

> Just run me and give me the path to your wallpapers. Easy peasy :3


## Quick Start

Make the script executable (one-time):

```bash
chmod +x ./wana.sh
```

Run the script:

```bash
./wana.sh
```

When prompted, give the path to your wallpapers as follows (dont forget to put your own username):

```bash
/home/username/Pictures/wallpapers
```

## Dependencies for graphical use
If you want to use graphically
### zenity
If you are on linux/gnome/hyprland etc.
### kdialog
If you are on linux/kde-plasma.
### osascript 
If you are on mac-os.

## Troubleshooting

- If the script says "permission denied": make sure you ran ` sudo chmod +x ./wana.sh` (Terminal Use).
- If it can't find your folder: ensure the path exists and you typed it exactly (copy-paste avoids typos).
- If nothing changes: check `wana.sh`'s logic and whether it filters files by extension.


## Contributing

If you want improvements (preview changes, dry-run mode, support for subfolders, undo log), open a PR or tell me what features to add.

