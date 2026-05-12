# Clean Gen CLI - Examples & Usage

## Quick Start

**Single Command to Rule Them All!**

```bash
clean_gen create <path-to-config.json> [--output <output-dir>]
```

That's it! One command handles everything based on your config file.

## How It Works

### 1. **Empty Functions** → Folders Only
```bash
clean_gen create config/settings.config.json --output lib/features
```
Result: Creates clean architecture folder structure with `.arch.json` metadata

### 2. **With Functions** → Folders + Complete Files
```bash
clean_gen create config/auth.config.json --output lib/features
```
Result: Generates folder structure + all code files (services, use cases, cubits, DI, etc.)

---

## Config File Format

The feature name is extracted from the config filename:
- `auth.config.json` → feature name is `auth`
- `product.config.json` → feature name is `product` 
- `user_settings.config.json` → feature name is `user_settings`

### Minimal Config (Folders Only)
```json
{
  "name": "settings",
  "functions": []
}
```

### Complete Config (Full Generation)
```json
{
  "name": "auth",
  "functions": [
    {
      "name": "signIn",
      "api": "/api/auth/sign-in",
      "method": "POST",
      "request": {
        "email": "string",
        "password": "string"
      },
      "response": {
        "token": "string"
      }
    },
    {
      "name": "logout",
      "api": "/api/auth/logout",
      "method": "POST"
    }
  ]
}
```

---

## Generated Structure

### With Functions (Complete Feature)
```
auth/
├── .arch.json                          # Feature metadata
├── auth_di.dart                        # Dependency injection
├── data/
│   ├── bodies/
│   │   ├── sign_in_body.dart
│   │   └── logout_body.dart
│   ├── data_sources/
│   │   └── auth_api_service.dart       # Retrofit service
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart        # Interface
│   └── use_cases/
│       ├── sign_in_use_case.dart
│       ├── logout_use_case.dart
│       └── index.dart
├── presentation/
│   ├── cubit/
│   │   ├── auth_cubit.dart
│   │   └── auth_state.dart
│   ├── pages/
│   │   └── auth_screen.dart
│   └── widgets/
└── di/
```

### Without Functions (Folders Only)
```
settings/
├── .arch.json
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── cubit/
│   ├── pages/
│   └── widgets/
└── di/
```

---

## Examples in This Folder

### `auth.config.json`
Generate a complete auth feature with sign-in, sign-up, and logout APIs

### `user/` (Pre-Generated Example)
Already generated complete user feature with 14 files

---

## Workflow

### Step 1: Create Config
```bash
mkdir config
cat > config/auth.config.json << 'EOF'
{
  "name": "auth",
  "functions": [
    {
      "name": "signIn",
      "api": "/api/auth/sign-in",
      "method": "POST"
    }
  ]
}
EOF
```

### Step 2: Generate Feature
```bash
clean_gen create config/auth.config.json --output lib/features
```

### Result
✅ Clean architecture folder structure  
✅ All code files generated  
✅ Ready to implement  

---

## JSON Schema

```typescript
{
  "name": string,
  "functions": [
    {
      "name": string,                // Function/API name
      "api": string,                 // API endpoint
      "method": "GET" | "POST" | "PUT" | "DELETE",
      "request"?: object,            // Request schema (optional)
      "response"?: object | array,   // Response schema (optional)
      "pagination"?: boolean         // Pagination support
    }
  ]
}
```

---

## Generated Files

| File | Purpose |
|------|---------|
| `*_api_service.dart` | Retrofit API client |
| `*_repository.dart` | Repository interface |
| `*_repository_impl.dart` | Repository implementation |
| `*_use_case.dart` | Business logic (one per function) |
| `*_cubit.dart` | State management |
| `*_di.dart` | Dependency injection |
| `*_screen.dart` | UI template |

---

## Tips

✅ Store configs in a `config/` folder  
✅ One config per feature  
✅ Start with empty functions, add later  
✅ Update config as APIs evolve  
✅ Regenerate when adding new APIs  


