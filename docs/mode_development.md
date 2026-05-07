# Mode Development

Text Forge has a powerful and feature-rich API for adding support for any language in the fastest way possible. We provide modes to help developers and users work with any file type simply by plugging in one module. On this page, we will show you the standard way to develop modes, along with best practices.

!!! Note
    
    Reading the [Modes Guide](modes.md) is highly recommended before developing modes. Please read that document first.

## Text Forge Mode API

To handle external modules, we need an API, so we provide the **Text Forge Mode API** (TFM API for short) as the connection layer for modes. TFM is a feature-packed API designed for any mode, offering a wide range of capabilities.

!!! Note

    We have multiple versions of the TFM API, and each editor version supports only one TFM API version (although a single TFM API version can be shared across many editor versions). Currently, the latest stable TFM API version is 2.2, and it supports Text Forge 0.2-stable and newer versions.

To take full advantage of all mode features, you should understand the API, so we will explain it in more detail. The TFM API consists of two parts: the first is the EditorAPI, which connects the editor to modes; the second is the `TextForgeMode` class, which keeps this connection standardized and provides some ready-made features.

You will work with **TextForgeMode** to build your mode. This class defines your mode, and the EditorAPI handles the rest. Therefore, a mode has one very important component: its script. This script extends the TextForgeMode class and customizes its behavior to implement your mode's logic.

## Make Your First Mode With a Template

We provide a mode template to help mode developers, especially for first-time testing. You can find it in the [mode template repository](https://github.com/text-forge/mode-template). You can download, clone, or fork it to get started quickly. Guides are included within the template.

## Useful Examples

You can explore our official modes, such as [Web Mode Kit](https://github.com/text-forge/web-mode-kit) and [GDScript Mode](https://github.com/text-forge/gdscript-mode), to find solutions for the most common challenges.
