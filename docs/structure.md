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
  - `main.gd` - Script of the main scene (class `Core`)
  - `main.gdshader` - Shader applied by the UI filter overlay
  - `main.tscn` - Main editor scene
  - `panels` - Panels of the editor, each panel in its own folder
  - `scripts` - Scripts used in the editor are stored here
  - `translations` - Translation files of the editor
- `data` - Information included with the editor at runtime, such as themes and default modes
  - `default_modes.tfmode` - Packaged default modes
  - `main_ui.ini` - Main menu configuration
  - `shortcuts.tres` - Default shortcut map
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
    Signals <- SignalBus API
    Global <- Global access point
    Tests <- Runtime tests handler
    Settings <- Settings and data API
    Notif <- Notification manager
    Factory <- Node generator
    ExtensionHub <- Global hub for extensions communication
    Extensions <- Extensions API
    U <- Utilities
    NetSuite <- Network API
    BackupCore <- Backup API
    Project <- Project API (Including Project Module)
    Main (Core)/ <- Main editor scene
        UIFilter <- UI filter layer
            OverlayShader <- Shader overlay using main.gdshader
        Overlays <- Overlay panels, etc.
            Replace popup <- Replace popup for template completion
        Background <- Background panel
        Margin <- Main layout container
            Sections <- Main sections container
                MenuBar <- Main menus
                FileLabel <- Current file name and path
                PanelManager/ <- Panels management
                    LeftTab <- Left tab buttons
                    LeftSpliter/ <- Left tab splitter
                        LeftPanel <- Left tab panels
                        RightSpliter/ <- Right tab splitter
                            BottomSpliter/ <- Bottom tab splitter
                                Editor/ <- Editor
                                    API <- Editor API (Including TFM API)
                                BottomPanel <- Bottom tab panels
                            RightPanel <- Right tab panels
                    RightTab <- Right tab buttons
                BottomTab <- Bottom tab buttons
                BottomBar <- Bottom [Status] bar
        Scripts <- Action scripts
        About <- About window
```

### Settings API

- Access: `Settings`

This API allows you to utilize the settings and data capabilities of the editor and integrate your desired configurations. Settings are characteristics that can be customized by the user, while data is information that you need to store. To this end, two categories of functions are available to you in this API:

#### Working with Settings

- `define_preset(section: String, key: String, default: Variant = null)` - Initialize your new setting option
- `get_default(section: String, key: String)` - Get default value for given setting option
- `get_setting(section: String, key: String, default: Variant = null)` - Get saved value for given option
- `restore_default(section: String, key: String)` - Resets given option to defined default value
- `set_setting(section: String, key: String, value: Variant = null, force_silent := false)` - Sets given option to a value
- `flush() -> Error` - Saves data, presets, and settings to their files

!!! Note
    
    For `get_setting()` function, you can use `section` and `key` parameters and leave `default` `null` to let API use defined default value in `define_preset()`.

#### Working with Data

- `read_data(section: String, key: String, default = null)` - Get saved data in given key
- `write_data(section: String, key: String, value = null, force_flush := false)` - Save data in given key

### SignalBus

!!! Note

    This part and the following sections will be completed soon.