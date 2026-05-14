## 1.4.1

- **Naming Support**: Added support for `.test.json` and `.test.yaml` naming conventions.
- **Verbose Output**: Added `-v` / `--verbose` flag to the `test` command to show detailed request and response logs.

## 1.4.0

- **New Command**: Added `test` command to validate API endpoints against a live server.
- **Contract Validation**: The `test` command compares the real server response with the examples provided in your config.
- **Headers Support**: Support for Bearer tokens and custom headers in the `test` command.

## 1.3.1

- **Maintenance**: Finalized formatting and documentation improvements.

## 1.3.0

- **Improved Pub Score**: Updated dependencies to the latest stable versions.
- **Documentation**: Added comprehensive dartdoc comments to all public classes and methods.
- **Example**: Added an example documentation and ensured the example folder is correctly structured for pub.dev.
- **Repository**: Fixed repository and homepage URLs.

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
