# Build Text Forge from source

!!! Note

    This page currently haven't complete guide for build, there is just manual for open project source in Godot.     To build editor from source use [this guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html) from official Godot docs.

## Get Engine

Text Forge built on Godot (v4.5.stable.official [876b29033]), you can get this version from [this page](https://godotengine.org/download/archive/4.5-stable).

## Get Source

To get source you can use `git clone` or with GitHub Desktop:
```bash
git clone https://github.com/text-forge/text-forge.git
```
Or open [official repo](https://github.com/text-forge/text-forge) and click on `Code > Open with GitHub Desktop` and configure it.

## Edit Project

Now you can use Godot to import project and edit it, or press `F5` to run project.

!!! Important

    If your clone is for contribution, always create a new branch for new PRs.

## Export Project

### In Godot GUI

1. From the **Project** menu, open **Export**.
2. Click the **Export Project...** button.
3. Choose the destination directory.
!!! Note
    Currently, you must enable the **Export With Debug** option to ensure all required files are included.

4. After exporting, copy the `data` and `action_scripts` directories to the same output directory.

### In CLI (Linux)
First get Godot

You also need Godot templates (Godot_v{version}-stable_export_templates.tpz)
They can be downloaded from Godot's [GitHub](https://github.com/godotengine/godot/releases)
(Preferred version is 4.5 stable)

Then extract .tpz templates
```bash
unzip Godot_v4.5-stable_export_templates.tpz
cd templates
mkdir -p ~/.local/share/godot/export_templates/4.5.stable/
cp templates/* ~/.local/share/godot/export_templates/4.5.stable/
```
In your cloned or extracted Text-Forge project directory, run:

Import Text-Forge project into Godot first
```bash
godot --headless --import
```

Export Text-Forge
```bash
Godot_v4.5-stable_linux.x86_64 <path/to/text-forge/project.godot> --headless --export-debug Linux <output/path/TextForge.x86_64> --verbose --quit
```
If you have Godot installed globally or available in your PATH as godot:
```bash
godot --verbose --headless $(pwd)/project.godot --export-debug Linux $(pwd)/TextForge.x86_64 --quit
```

Run the exported binary:
```bash
./TextForge.x86_64
```

**Note:** If you want TextForge in a different directory, copy the binaries and directories `data` and `action_scripts` to your desired location.
