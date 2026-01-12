# Object Oriented Design

This page explains the meaning and examples of OOP in Text Forge's architecture.

## OOP in Text Forge – What and Why?

We incorporate many concepts from XP (Extreme Programming) in Text Forge's architecture to maintain a very clean codebase, and OOP is a tool for making them real. As a result, we have an object-oriented-like core for Text Forge (based on Godot's limitations), meaning everything in Text Forge is an object.

Additionally, we use a modular design to allow for easy and sustainable expansion of Text Forge. OOP and its principles enable us to develop modules in a stable and powerful way (though the Godot structure imposes certain restrictions).

## How Do We Use OOP?

We use the Godot node system and object instantiation to dynamically load the editor's components. This can affect speed but preserves the editor's expandability. All in all, any module added to the editor (including its default modules) is a set of objects connected through the Godot scene tree, capable of communicating with other modules.
