# Text Forge Project Structure

If you are an editor developer, or even want to create a powerful and useful plugin, understanding and having an overview of the project structure will be very helpful for you. In this guide, we will examine the different parts of the editor.

## File Structure

Although files can be used in different parts of the project, categorizing them logically can determine their types.

### Project Files

- `action_scripts` - Location for storing Action Scripts and related items
  - `scenes` - Scenes used by action scripts and their scripts
- `addons` - Godot plugins and any third-party files related to the project
- `assets` - Icons and fonts
- `core` - Main editor
  - `autoload` - Contains autoload scripts
  - `classes` - Holds the classes used in the editor
    - `action_script_extension` - Holds special extensions for the action script class
  - `scripts` - Scripts used in the editor are stored here
- `data` - Information included with the editor at runtime, including themes, panels, translations, etc.
  - `panels` - Keeps panels in separate folders
  - `themes` - Stores default themes
- `docs` - Holds the project documentation, including this file
  - `img` - Holds the images used in the documentation
- `reports` - Local folder for test reports
- `tests` - Unit, automated, and manual tests

These files are stored in the project's source repository (except for `reports/`), and the `action_scripts/` and `data/` folders are also located next to the installation file.

### Data Files

- `backups/` - Stores backups along with their dedicated code
- `extensions/` - Location for storing extensions
- `logs/` - Stores editor logs
- `modes/` - Contains installed modes
- `project_icons/` - Stores cached versions of project icons
- `shader_cache/` - Stores shader cache
- `templates/` - Location for storing templates
- `themes/` - Installed themes
- `vulkan/` - Stores Vulkan cache
- `backups.ini` - Maps the main file name and backup time to the backup file
- `data.cfg` - Stores internal editor information
- `presets.cfg` - Stores additional editor settings information
- `recent_files.txt` - Keeps a list of recent files (up to 15 items)
- `recent_projects.txt` - Keeps a list of recent projects (up to 15 items)
- `settings.cfg` - Stores the value of settings made by the user

## Editor Structure

Text Forge utilizes the power of Godot's nodes, therefore it has a tree-structured editor.

```text
root/ <- Root of main window node
    Settings <- Settings and data API
    Signals <- SignalBus API
    TFT <- Translation API
    ExtensionHub <- Global hub for extensions communication
    Global <- Global access point
    Factory <- Node generator
    Extensions <- Extensions API
    BackupCore <- Backup API
    Tests <- Runtime tests handler
    Project <- Project API (Including Project Module)
    NetSuite <- Network API
    U <- Utilities
    Main (Core)/ <- Main editor scene
        Overlays <- Overlay panels, etc.
        EditorContainer/ <- Editor placement manager
            Menus <- Main menus
            FileLabel <- Current file name and path
            PanelManager/ <- Panels management
                LeftTabs <- Left tab buttons
                LeftSplitter/ <- Left tab splitter
                    LeftPanels <- Left tab panels
                    RightSplitter/ <- Right tab splitter
                        BottomSplitter/ <- Bottom tab splitter
                            Editor/ <- Editor
                                EditorAPI <- Editor API (Including TFM API)
                            BottomPanels <- Bottom tab panels
                        RightPanels <- Right tab panels
                RightTabs <- Right tab buttons
            BottomTabs <- Bottom tab buttons
            BottomBar <- Bottom [Status] bar
    Scripts <- Action scripts
    Sub-windows <- Sub-windows
```

### Settings API

- Access: `Settings`

This API allows you to utilize the settings and data capabilities of the editor and integrate your desired configurations. Settings are characteristics that can be customized by the user, while data is information that you need to store. To this end, two categories of functions are available to you in this API:

#### Working with Settings

- `define_preset(section: String, key: String, default: Variant = null)` - Initialize your new setting option
- `get_default(section: String, key: String)` - Get default value for given setting option
- `get_setting(section: String, key: String, default: Variant = null)` - Get saved value for given option
- `get_setting_bool(section: String, key: String, default: Variant = null)` - Safer version of `get_setting()` for boolean options
- `restore_default(section: String, key: String)` - Resets given option to defined default value
- `set_setting(section: String, key: String, value: Variant = null)` - Sets given option to a value

!!! Note
    
    For `get_setting()` function, you can use `section` and `key` parameters and leave `default` `null` to let API use defined default value in `define_preset()`.

#### Working with Data

- `read_data(section: String, key: String, default: Variant = null)` - Get saved data in given key
- `write_data(section: String, key: String, value: Variant = null)` - Save data in given key

### SignalBus

!!! Note

    This part and the following sections will be completed soon.