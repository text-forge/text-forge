# Modes In Text Forge

Text Forge is lightweight and language-agnostic, so there is no default dependency on any language. But how can you work with any file type and have special features like syntax highlighters and linters? This is where modes come in. A mode is a special module designed to adapt to certain types of files and languages. You can install the modes and leave the rest to the editor; everything is automatically managed so you can work with your files seamlessly.

## Mode Features

Below is a list of all standard features available for modes. Some modes may have additional custom features, while others might lack one or more features from this list. In short, you can identify optional features with the *optional* tag. The features of a mode depend on its developers:

- **Save & Load**

    Modes can encode and decode files. With this customizable encoding system, you can work with a wide variety of files, even those that aren't plain text files!

- **Syntax Highlighter** *optional*

    We provide both simple and advanced syntax highlighting capabilities to mode developers, ranging from basic highlighters to fully customized ones. Currently, highlighters support only one theme, and highlighter colors are completely mode-driven.

- **Advanced Comment Handling** *optional*

    We offer an easy API for defining comment delimiters and logic. The editor provides line folding and other features based on this information.

- **Mode Panels** *optional*

    Modes can have their own panels, allowing you to configure a mode visually according to its features.

- **Auto Format** & **Auto Indent** *optional*

    We provide auto format and auto indent options separately. You can run these actions to clean up your files using the mode's capabilities. These features are available in `Format > Indentation > Auto Indent` and `Format > Auto Format`. To see the shortcuts, type `Auto Indent` or `Auto Format` in the command palette.

- **Initialization Lifecycle**

    We maintain high standards for your file safety. A mode will load completely before working with your file, and if initialization fails, the task will be canceled.

- **Code Completion** *optional*

    We provide mode-based code completion with a complete API for mode developers. The features and intelligence of this functionality depend on your current mode.

- **Preview Rendering** *optional*

    Modes can generate a live preview based on your file, which you can view in the **Preview Panel** on the right side of the editor.

- **File Outline** *optional*

    You can navigate between sections in your file or review them in the **Outline Panel** on the left side of the editor. This is also a mode-driven feature, so its capabilities are based on your mode.

- **Linting** *optional*

    We currently do not support LSP & DAP clients ([feature tracking issue↗️](https://github.com/text-forge/text-forge/issues/88)) for complete language-based features, but we do offer a simple mode-driven linting feature. You can view your file's problems in the **Problems Panel** at the bottom of the editor. In this panel, all errors and warnings provided by the mode are displayed, and you can navigate between them by clicking on an item.

- **Indentation Settings** *optional*

   Starting with TFM API v2.2 (Text Forge v0.2), modes can provide indentation settings. This allows you to use multiple modes and be confident that indentation options will be set automatically when you switch modes. For example, YAML requires spaces for indentation, but GDScript recommends tabs. A YAML mode can provide 2 spaces as indentation, while a GDScript mode can provide a single tab with a width of 4, so you don't need to change the indentation type and size each time you open a new file.

   To customize this feature for each mode, use the **Indentation Settings** menu in the bottom-right corner of the editor (a button with text like `Tabs (4)`). Open a file with the target mode and use this button to set custom settings. You can also use `Format > Indentation > Reset To Mode Indentation Settings` to restore the original settings. If you want to disable this feature and use the editor's indentation settings for all files, enable `Format > Indentation > Lock Indentation Settings`.

!!! Note

    A lot of the above features were added in TFM API v2.0. You can read more about this API [here](mode_development.md#text-forge-mode-api). We provide many of these features as optional because a mode can work with simple text or non-code files, so there are many optional but fundamental features.

!!! Note

    After TFM API v2.0, we use buffer-based save and load instead of file-based behavior. This new system provides safer error handling, and modes can no longer directly see the file paths on your system when you save or load a file.

!!! Important

    Modes are unlimited modules! You should always verify a mode before installing it, as modes can access your file contents. For a completely safe experience, download official and community modes from the [mode library](https://github.com/text-forge/mode-library).

!!! Note

    Auto Format and Auto Indent are triggerable actions. There is an **Auto Indent New Lines** toggleable feature in the `Format > Indentation` menu that will automatically adjust indentation when you create a new line.

## Mode Kits

In the programming world, there are many types of programmers. For example, if you are a web developer, your basic workflow requires working with files like `.html`, `.css`, and `.js`. To accommodate this, we provide mode kits—a mode kit is a collection of related modes created for a specific type of user.

## Installing

You can install modes in different ways. This section explains the standard methods.

### From Marketplace

The Marketplace is a useful feature for installing modes in the simplest way. This method also protects you from incompatible modes and limits associated risks.

To install a mode or mode kit from the Marketplace, go to **Settings > Marketplace**, select the **Modes** category, and click on a mode to view its details. Use the **Install** button to download and install the mode. If this button is disabled, your editor is not compatible with that mode; you can find another mode or try alternative installation methods.

After clicking the Install button, wait until you see the **Package Installed!** notification. You can then use your new mode without restarting the editor.

!!! Note

    You can install modes this way:
    - Modes in the [Marketplace](https://github.com/text-forge/marketplace)

### From Mode Manager

You can download mode installation files, which are `.zip` or `.tfmode` files, from mode providers. Open the **Mode Manager** (`Settings > Mode Manager` in menus) and select the file using `Import Mode / Mode Kit`. After loading, you’ll receive a completion info notification. You can then use your new modes without restarting the editor.

!!! Caution

    This installation method does not check for mode compatibility!

!!! Note

    You can install modes this way:
    - Modes in the [Mode Library](https://github.com/text-forge/mode-library)
    - Modes under [GitHub's `text-forge` topic](https://github.com/topics/text-forge)
    - Any mode that provides a `.zip` or `.tfmode` installation file

### From Mode Source

Modes work in an isolated environment, so you can transfer their files to another editor's data folder and use them there. For this installation method, you need the mode's source code, which you can obtain from GitHub or another source. To install one or more modes from source, use **Settings > Open Data Folder** and paste the mode folder into the `modes/` directory. After restarting your editor, the new mode will be available.

!!! Note

    You can install modes this way:
    - Modes in the [Mode Library](https://github.com/text-forge/mode-library)
    - Modes under [GitHub's `text-forge` topic](https://github.com/topics/text-forge)
    - Modes installed on another device or user data
    - Any mode that provides source code
