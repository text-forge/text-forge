# Themes in Text Forge
Text Forge supports customizable themes for UI elements. This page explains how themes work, how to create your own, and how to install or share them.

## Theme Structure
Each theme is defined as a `.tres` file. This file is a text-based Godot resource in INI format. You can style UI elements with this file.

## Getting Themes
Text Forge has some internal themes:

- Dark (default) `dark`

You can find other themes here:

- [Text Forge awesome themes](https://text-forge.github.io/awesome-themes)

## Installing Themes
To install a theme, open **Settings > Open Data Folder**, go to the `themes/` folder, and paste the `.tres` file there.

!!! Note

    You can use installed themes without restarting the editor.

## Changing Editor Theme
To change the theme, go to **Settings > Preferences > Editor UI > Theme Name**, enter the theme file name (without the extension), and close the Preferences window. The editor will load the new theme.

## Creating a Theme
If you want to create themes, use the Godot editor. See the guide for opening the Text Forge source in Godot:

- [Build Text Forge from source](build.md)

Then edit `res://data/themes/dark.tres` in the Godot Theme Editor or create a new theme in that folder. When your theme is complete, rename it and share it. You can test it directly; the editor copies `res://data/themes/` to `user://themes/` when you run it.

## Themes Location
The editor loads all themes from the `themes/` folder in the editor data directory. Internal themes live at `res://data/themes/`.
