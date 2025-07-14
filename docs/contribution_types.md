# Contribution Types

This is a list of available types for contributing, you can choose your contribution type from this list based on your
abilities or find new way to contribute, feel free!

!!! Note

    You can share your ideas about what you will do in [discussions](https://github.com/text-forge/text-forge/discussions)
    to receive others comments to be sure about what you want or get tips.

You can find contribution guides [CONTRIBUTING.md](contributing.md),
If you can't find the right guidance or have a question, [Discussions](https://github.com/text-forge/text-forge/discussions) are always available for guidance.

## Programming

This section is for peoples with programming experience, specially who know about [OOP](https://www.bing.com/ck/a?!&&p=884f008f70c8bd91a7398ae34eaeff00571a7db0f1fe4d255995619348c533e4JmltdHM9MTc1MjM2NDgwMA&ptn=3&ver=2&hsh=4&fclid=09a8c98b-e870-67ad-2bfe-dce3e96466d1&psq=wikipedia+oop&u=a1aHR0cHM6Ly9lbi53aWtpcGVkaWEub3JnL3dpa2kvT2JqZWN0LW9yaWVudGVkX3Byb2dyYW1taW5n&ntb=1)
and modularity, with knowledge about GDScript, C# or other languages Godot supports.

### Codebase Review

- Audit every file for adherence to style, modularity, Text Forge philosophy, and Godot best practices.
- Identify duplicate, dead, or outdated code and remove them.

### Repository Restructuring

- Consider in-repo documentation (README, CONTRIBUTING, architecture overview).
- Improve folder structure for modes, core, plugins, and utils.

!!! Note

    Change files structure needs change code in most cases, be sure your changes will not break anything!

## Writing Docs

This section is for all peoples, everyone can contribute in improve docs.

!!! Important

    We use `text-forge/docs` repo to build and deploy our docs, this repo will sync automaticly with `docs/` folder in
    main repo (`text-forge/text-forge`), so DON'T commit your changes based on docs repo! Just commit them same as regular changes.

- Sync external docs and internal docs (`docs/` folder with `##` docs in codes).
- Write uncompleted docs or do spell checks, etc.

## Testing

- Add or improve unit/integration tests.
- Improve CI/CD (GitHub Actions).
- Do manual test.

## Issue Triage

- Review existing issues, triage, and tag (bug, enhancement, doc, etc.).
- Close outdated or resolved issues.

!!! Note
    
    If you are a new contributor and haven't premission to change tags and close issues, add comment in that issue and mention
    someone with **Triage**, Write, Maintain, or Admin role, you can find them from [Contributors List](https://github.com/text-forge/text-forge/graphs/contributors).

## Code Quality

- Refactor for readability and maintainability (naming, file sizes, comments).

## Extensibility Improvements

- Standardize API for adding new modes/plugins.
- Document plugin/mode interface, Specially internal docs.
- Make demo for plugin, mode or other modules.

## Performance Review

- Identify and address bottlenecks, especially for large file editing and multi-language support.

## User Experience

- Review UI/UX for consistency and accessibility.
- Add onboarding guides and example configurations.

## Community Health

- Suggest issue/PR templates.
