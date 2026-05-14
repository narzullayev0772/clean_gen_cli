## 1.1.1

- Automatic release on push to main (2026-05-14)

## 1.1.0

- **New Command**: Added `update` command to incrementally add new functions to existing features.
- **Smart Injection**: Implemented logic to inject methods into DataSources, Repositories, and DI files without overwriting manual changes.
- **Automatic DI Registration**: New UseCases are now automatically registered in the feature's DI file.
- **Improved Code Generation**: Optimized imports and URL constant generation during updates.

## 1.0.4

- Improved CLI documentation and help messages.
- Added support for JSON/YAML configuration for feature generation.
- Implemented global configuration for project-wide imports.
- Enhanced model generation strategies (`empty`, `serialize`, `generate`).
- Optimized folder structure for Clean Architecture.

## 1.0.0

- Initial release with basic feature generation.
