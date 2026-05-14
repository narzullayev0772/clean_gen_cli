# Clean Gen CLI

A powerful command-line tool for Flutter developers to automate the generation of Clean Architecture features. Define your feature structure, API endpoints, and data models in JSON or YAML, and let `clean_gen` handle the boilerplate.

## Features

- 🏗️ **Clean Architecture Structure**: Automatically generates `data`, `domain`, and `presentation` layers.
- 📂 **Standardized Folder Structure**: Creates folders for `data_sources`, `models`, `repositories`, `use_cases`, `cubits`, `pages`, and `widgets`.
- 🚀 **Boilerplate Generation**: Generates API services (compatible with Chopper/Retrofit patterns), Repositories, Use Cases, and Models.
- ⚙️ **Config-Driven**: Uses simple JSON or YAML files to define feature requirements.
- 🛠️ **Customizable**: Supports global and feature-specific configurations for imports and utility paths.
- 🔄 **Smart Model Handling**: Supports manual models, serialized models, or fully generated models based on example payloads.
- 🛠️ **Incremental Updates**: Use the `update` command to add new API endpoints to existing features without losing your manual code changes.

## Installation

Activate the CLI globally using Dart:

```bash
dart pub global activate clean_gen_cli
```

## Getting Started

### 1. Initialize Global Configuration

Before creating features, it's recommended to initialize a global configuration file to define common imports (like your `DataState`, `UseCase` base classes, or `ServiceLocator`).

```bash
clean_gen init
```

This will create a `config/config.json` file. Update it to match your project's core utility paths.

### 2. Create a Feature Configuration

Create a configuration file for your feature (e.g., `auth.config.json`):

```json
{
  "name": "auth",
  "functions": [
    {
      "name": "signIn",
      "api": "/api/v1/auth/login",
      "method": "POST",
      "request": {
        "email": "string",
        "password": "string"
      },
      "response": {
        "token": "string",
        "user": "$UserModel"
      }
    }
  ]
}
```

### 3. Generate the Feature

Run the `create` command pointing to your config file:

```bash
clean_gen create config/auth.config.json
```

By default, this will generate the feature in `lib/src/features/auth`.

## Commands

### `init`
Initializes the global configuration file.
```bash
clean_gen init [path/to/config.json]
```

### `create`
Generates a feature based on a config file.
```bash
clean_gen create <config-file> [options]
```

**Options:**
- `-o, --output`: Set the output directory (default: `lib/src/features`).
- `-m, --model`: Model generation strategy: `empty`, `serialize`, or `generate` (default: `generate`).

### `update`
Updates an existing feature with new functions. It will only add missing UseCases, Repository methods, and DataSource endpoints without overwriting your existing manual changes.
```bash
clean_gen update <config-file> [options]
```

**Options:**
- `-o, --output`: Set the output directory where the feature exists.
- `-m, --model`: Model generation strategy for new models.

### `test`
Tests the API endpoints defined in your configuration file against a live server. It validates status codes and ensures the response structure matches your examples.
```bash
clean_gen test <config-file> --base-url <url> [options]
```

**Options:**
- `-b, --base-url`: The root URL of your API (Required).
- `-t, --token`: Bearer token for authentication.
- `-H, --header`: Additional headers (e.g., `-H "X-Custom: Value"`).
- `-v, --verbose`: Show detailed request and response information.

### `version`
Prints the current version of the CLI.

## Configuration Guide

### Feature Config (`<name>.config.json` or `<name>.test.json`)
The CLI recognizes files ending in `.config.json`, `.config.yaml`, `.test.json`, and `.test.yaml`. The filename prefix is used as the feature name.

| Property | Type | Description |
| --- | --- | --- |
| `name` | String | The name of the feature (required). |
| `functions` | List | API methods to generate (DataSources, Repositories, UseCases). |
| `imports` | Object | Override global imports for this specific feature. |

### Function Definition

| Property | Type | Description |
| --- | --- | --- |
| `name` | String | Method name (e.g., `getUserProfile`). |
| `api` | String | API endpoint path. |
| `method` | String | HTTP method: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`. |
| `pagination`| Boolean| Whether the endpoint supports pagination. |
| `query` | Boolean| If `true`, parameters are passed as Query params. |
| `request` | Object/String| Example payload or magic model (e.g., `$MyModel`). |
| `response` | Object/String| Example response or magic model. |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
