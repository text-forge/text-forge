# Build Text Forge from source

This page is a complete guide to get Text Forge running from source, to build a release from it,
and to run its test suite.

## Get the Engine

Text Forge is built on Godot **4.5.stable** (`v4.5.stable.official [876b29033]`). Get that exact
version from the [Godot download archive](https://godotengine.org/download/archive/4.5-stable).
A newer Godot can open the project, but Text Forge is only tested against 4.5.x, and the export
templates have to match the editor version.

## Get the Source

```bash
git clone https://github.com/text-forge/text-forge.git
```

Or open the [official repo](https://github.com/text-forge/text-forge), click `Code > Open with
GitHub Desktop` and configure it there.

!!! Important

    If your clone is for contribution, always create a new branch for new PRs.

## Run it from the Editor

Open the `project.godot` of the cloned repository with Godot 4.5. The first import takes a moment,
it builds the resources of the editor and of the bundled test addon.

- `F5` runs the editor.
- `F6` runs the current scene.

The editor keeps its data in the `user://` folder, which is
`%APPDATA%\Godot\app_userdata\Text Forge` on Windows. Deleting that folder resets the editor to a
fresh state, which is the way to recover from a broken setting.

## Build a Release

### 1. Install the export templates

Download the **export templates for 4.5-stable** (`Godot_v4.5-stable_export_templates.tpz`) and
install them in the Godot editor: `Editor > Manage Export Templates > Install from file`. The
templates have to match the editor version, otherwise the export fails.

### 2. Export

Text Forge ships two presets in `export_presets.cfg`:

| Preset | Platform | Output |
| --- | --- | --- |
| `Windows Desktop` | Windows | `TextForge.exe` |
| `Linux` | Linux | `TextForge.x86_64` |

In the editor: `Project > Export`, pick the preset, and press `Export Project`. Pick an empty
folder, the export writes the executable there. Copy the `data` folder of the repository next to
it, it holds the menu configuration, the themes and the default modes. It is not a Godot resource,
so it is not part of the exported `.pck` and the editor cannot find it without it.

!!! Note

    Enable **Export With Debug**, the same way the release workflow exports. The official builds
    are debug exports, and a release export leaves out files the editor needs.

#### From the command line (Linux)

Unpack the export templates into the folder Godot looks in, the version has to match the editor:

```bash
unzip Godot_v4.5-stable_export_templates.tpz
mkdir -p ~/.local/share/godot/export_templates/4.5.stable/
cp templates/* ~/.local/share/godot/export_templates/4.5.stable/
```

Import the project once, so Godot builds its resources, then export:

```bash
godot --headless --import
godot --headless --export-debug "Linux" $(pwd)/TextForge.x86_64 --quit
```

The binary is the one that was written, run it from the folder that holds `data`:

```bash
./TextForge.x86_64
```

### 3. Package

A release archive holds the exported files plus the files that are not resources:

```
TextForge/          # the exported editor
data/               # menu configuration, themes, default modes
icon.png
README.md
CHANGELOG.md
SECURITY.md
LICENSE
```

### 4. Or let CI do it

The release workflow (`.github/workflows/release.yml`) does all of that for you. It is triggered by
pushing a tag:

```bash
git tag v0.5.0-stable
git push origin v0.5.0-stable
```

The workflow exports both presets, builds the two archives and attaches them to a **draft** GitHub
release. The draft is not published, review the notes and publish it when it looks right. Keep the
tag when you publish it: a draft published without its tag gets an `untagged-<sha>` tag, that tag
fires the workflow again and it puts the release back in draft.

Tags follow `v<major>.<minor>.<patch>-<suffix>`, for example `v0.3.0-stable` or `v0.2.0-rc1`. The
version in `project.godot`, the one in `core/classes/static.gd` (`S.EDITOR_VERSION`) and the
`CHANGELOG.md` entry belong to the same release.

## Run the Tests

The unit tests use [gdUnit4](https://github.com/MikeSchulze/gdUnit4), which is enabled as an addon
in `project.godot`. From the command line:

```bash
export GODOT_BIN=/path/to/godot
./addons/gdUnit4/runtest.sh -a res://tests/                              # all suites
./addons/gdUnit4/runtest.sh -a res://tests/core/autoload/utils_test.gd   # one suite
```

Headless runs need `--ignoreHeadlessMode`, and suites that drive the interface only pass inside
the editor, so run those from the `gdUnit4` panel. There is no flag for a single test case, select
it in the panel.

The reports are written to `reports/`, the numbers of the last run are in
[the test overview](https://github.com/text-forge/text-forge/blob/main/tests/README.md).
