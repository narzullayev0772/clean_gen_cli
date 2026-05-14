# Clean Gen CLI Examples

This directory contains example configuration files that you can use with `clean_gen_cli`.

## Examples Included

- `auth.config.json`: A comprehensive example for an authentication feature with sign in, sign up, logout, and user list functions.
- `auth.test.json`: The same feature using the `.test.json` naming convention, ideal for API contract testing.
- `auth.config.yaml`: The same authentication feature defined in YAML format.
- `config.json`: A sample global configuration file to define shared imports and project-specific utility paths.

## How to use these examples

### 1. Create a feature from JSON
```bash
clean_gen create example/auth.config.json
```

### 2. Create a feature from YAML
```bash
clean_gen create example/auth.config.yaml
```

### 3. Initialize global config
```bash
clean_gen init example/config.json
```

For more details, please refer to the main [README.md](../README.md).
