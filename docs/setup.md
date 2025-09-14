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

### Download Modes or Mode Kits

You can go [here](https://github.com/text-forge/mode-library) to find and download modes you want. Just click on name of
mode you want and read setup guide in mode repository.

Then, you have one (or more) `.zip` or `.tfmode` file, you can import them with `Settings > Mode Manager > Import Mode / Mode Kit`,
If everything done well, you will receive an **info** notification that says `"Load mode / mode kit completed"` and you 
can use your new modes now without restart editor.

## Open A File

You have a ready code editor! Let's open a file:

- In top left of editor you have a list of menus. Click on `File` menu in top left.
- Click on `Open` and select your file in opened file dialog.
  - Based on your file type (extension), Text Forge will open it in one of these ways:
    1. **You have one installed mode for this file:** Here, Text Forge will use mode to load file in editor and loads syntax highlighter from mode.
    2. **You have some installed mode for this file:** A popup will show, and you can select a mode to open file, then we have first situation.
    3. **You haven't any installed mode for this file:** Text Forge will send a warning (You can see it in notification panel) and open file using UTF-8 encoding. With this behavior you can open any file type that encoded with UTF-8 without any mode (It means a lot of files!) but there is no syntax highlighter for these files.
- Well done!

!!! Tip

    You can open a file with `Ctrl + O` shortcut or using command palette (`Command > Command Palette` option in menus or `Ctrl + P`)

!!! Note

    On windows, use RMB on file and click on **Open With**, then select Text Forge runnable `.exe`.
    After this you will be able to open files with Text Forge without open it directly.

## Create New Project

!!! Note

    Unlike most editors, you don't need to create a project before creating a file, so this section is optional.

If you've used other editors, you'll notice a different **project** concept. In other editors:

- A project is a folder.
- Project information is stored in a subfolder of that folder (e.g., `.textforge`).

In Text Forge:

- A project is a `.tfproj` file.
- Project information is stored in that file.

But why? We have specific reasons for this design:

|Feature                |Folder-based projects          |`.tfproj` projects      |
|-----------------------|-------------------------------|------------------------|
|File Path Flexibility  |Only files inside the folder   |Any file from any path  |
|Single-File Projects   |Requires a folder              |A single file is enough |
|Custom Project Settings|Scattered across multiple files|Centralized in `.tfproj`|

Overall, this design gives you more flexibility. You can keep parts of a larger project in different
folders and switch between them in the editor with a single click.

Let's see Text Forge projects in action. You can create a project from **Project > New Project**.
This opens the **New Project** window with these fields:

- **Project File** — Path to your `.tfproj` file.
- **Name** — Project name.
- **Details** — Optional project details.
- **Icon** — Optional project icon.
- **Tags** — Optional comma-separated list of tags.
- **Include** — Folders and files to add to the project.
- **Exclude** — Folders and files to exclude from the project.

When you press the **Create** button, the editor creates the project, and you can use **Project > Open Project**
to open it. Then, navigate between project files in the **Files** panel on the left side of the editor.
To automatically save files when moving between project files, enable
**Settings > Preferences... > Files > Save Files When Moving Between Project Files**.

!!! Tip
    See also: [Project menu](menus.md#project)