# Templates in Text Forge

You can use templates to save time and reuse frequently used patterns. This page explains how to create and use templates.

## Create Your First Template

Let's create your first template. In this example, we'll write a template for recording daily reports. To start, create a new file using the New option.

!!! Tip

    You can select **File > New** from the menu, use the shortcut `Ctrl + N`, or execute this command from the command palette.

You can write your template like any other file. Use {{{}}} for placeholders to enable quick completion features when using the template. There are also several predefined internal placeholders that you can use:

- `{{{!file_name}}}` - The name of the file created from the template
- `{{{!file_path}}}` - The path of the file created from the template
- `{{{!time}}}` - The creation time of the instance in HH:MM:SS format
- `{{{!date}}}` - The creation date of the instance in YYYY-MM-DD format
- `{{{!datetime}}}` - The creation date and time of the instance in YYYY-MM-DD HH:MM:SS format

For example, we create this template:

```markdown
# Daily Report - {{{!date}}}

## Project: {{{project}}}
## Author: {{{author}}}

### Completed Tasks
- {{{task_1}}}
- {{{task_2}}}
- {{{task_3}}}

### Key Notes
- {{{note_1}}}
- {{{note_2}}}

### Plan for Tomorrow
- {{{next_step_1}}}
- {{{next_step_2}}}

---

🕐 Logged at: {{{!time}}}
```

Our template is ready. To save it, select **Save As Template** from the **Format** menu, confirm the pop-up,  and enter a name for your template. Once you save it, you can use it as a template from now on.

## Using a Template

Templates help you create new files quickly, so we've placed them alongside other new file creation  options. You can see the available templates and select one from **File > New With Template**.

After selecting a template, the new file is created with the template, and you enter Placeholder  replacement mode:

![image.png](https://text-forge.github.io/docs/img/placeholder-replacement.png)

On the left side of the replace panel, the Auto Insert option is displayed, indicating that `{{{!date}}}` is a predefined placeholder. If you hover your mouse over it, you can see more information. We can use this option to replace the placeholder with the current date, or we can enter our desired value. In any case, after pressing the `Enter` key, the replacement is done, and the next placeholder is selected. After completing this placeholder, the `{{{project}}}` placeholder is selected, and since it is not a predefined placeholder, the Auto Insert option is not available.

There are other options in this panel:

- Next: Takes you to the next placeholder
- Previous: Takes you to the previous placeholder
- Close: Exits Placeholder replacement mode

You can continue completing and then save the file, but you can postpone completion. To do this, use the `Escape` key or the Close option. You can return to completion mode at any time using the **Format > Continue Placeholder Completion** option.

## Editing and Deleting Templates

So far, we have examined the methods of creating and using templates. Another feature is the Template  Manager, which allows you to easily edit or delete templates. To open it, you can use the **Format > Templates...** option. In the window that opens, you can select templates, preview them, and edit or delete them.