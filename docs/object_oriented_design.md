# Object Oriented Design

This page explains meaning and examples of OOP in Text Forge architecture.

## OOP in Text Forge, what and why?

We have a lot of concepts from XP (extreme programming) in Text Forge architecture to have very clean codebase,
and OOP is a tool for make them real; So we have an object-oriented like core for Text Forge (based on Godot 
limitations), it means everything in Text Forge are objects.

Also, we have a modular design to make Text Forge easy and sustainable expansion, OOP and its principles allow us to 
develop modules stable and powerful. (though the Godot structure creates restrictions)

## How we use OOP?

We use the Godot nodes system and object sampling to dynamically load the editor components, this can affect speed but 
maintain the editor's expansion. All in all, any module added to the editor (and its default modules) is a set of 
objects that are connected by the Godot scene tree and can communicate with other modules.