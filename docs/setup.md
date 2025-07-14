# Setup

Text Forge currently supports Linux and Windows (You can use it on other platforms with build it from source), Just download [latest](https://github.com/text-forge/text-forge/releases/latest) and install it! (or download portable version and extract it anywhere you want)

!!! Note

    You can see build guide here: [Open Text Forge source in Godot](build.md)

Now you can run Text Forge:

![image.png](https://text-forge.github.io/docs/img/setup_screenshot.png)

## Install Modes

Now, you have a very lightweight editor, it's more like a core. There is a lot of plugged modules like action scripts, 
panel, etc. but you need another type of module too for work with you editor. This type is **Mode**, you can find more 
about modes [here](modes.md), but for now let's get your modes from official mode library!

### Download Modes or Standard Package

You can go [here](https://github.com/text-forge/mode-library/releases/latest) and download modes you want, instead if
you like have a standard collection of modes you can use **Standard Package** (You can read more about packages [here](modes.md#packages)),
to get this package you should navigate to [this section](https://github.com/text-forge/mode-library/wiki/Packages#standard) 
in [packages list](https://github.com/text-forge/mode-library/wiki/Packages) and click on `Standard` to download package file.

Then, you have one (or more) `.zip` or `.tfmode` file, you can import them with `Settings > Mode Manager > Import Mode / Package`,
If everything done well, you will receive an **info** notification that says `"Load mode / package completed"` and you 
can use your new modes now without restart editor.

## Open A File

You have a ready code editor! Let's open a file:

- In top left of editor you have a list of menus. Click on `File` menu in top left.
- Click on `Open` and select you file from opened file dialog.
  - Based on your file type (extension), Text Forge will open it in one of these ways:
    1. **You have one installed mode for this file:** Here, Text Forge will use mode to load file in editor and loads syntax highlighter from mode.
    2. **You have some installed mode for this file:** A popup will show, and you can select a mode to open file, then we have first situation.
    3. **You haven't any installed mode for this file:** Text Forge will send a warning (You can see it in notification panel) and open file using UTF-8 encoding. With this behavior you can open any file type that encoded with UTF-8 without any mode (It means a lot of files!) but there is no syntax highlighter for these files.
- Well done!

!!! Tip

    You can open a file with `Ctrl + O` shortcut or using command palette (`Command > Command Palette` option in menus or `Ctrl + P`)