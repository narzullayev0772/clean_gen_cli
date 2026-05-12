# Flutter Clean Architecture Generator - Copilot Instructions

## Project Overview

This project is a production-grade Dart CLI tool that generates scalable Flutter clean architecture boilerplate from a single YAML or JSON schema file.

The tool generates:

* feature-based architecture
* data/domain/presentation layers
* repositories
* datasources
* models
* entities
* usecases
* cubits/blocs
* dependency injection files
* route files
* tests
* API integrations

The goal is to eliminate repetitive Flutter architecture setup and provide enterprise-ready code scaffolding.

This is NOT a simple folder generator.

This project must prioritize:

* deterministic generation
* clean code
* extensibility
* regeneration safety
* developer experience
* maintainability
* modular architecture

---

# Core Principles

## 1. Modular Architecture

The project must be highly modular.

Separate packages/modules:

* cli
* parser
* generator
* templates
* writer
* analyzer
* formatter

Avoid tightly coupled logic.

---

# 2. Clean Code

Always generate:

* readable code
* formatted code
* null-safe code
* scalable code
* strongly typed code

Avoid dynamic types unless explicitly required.

---

# 3. Regeneration Safety

Never overwrite user-written files blindly.

Support:

* generated markers
* metadata tracking
* safe file updates
* partial regeneration

This is a critical system requirement.

---

# 4. Extensible Template System

The generator must support multiple architecture styles:

* bloc
* cubit
* riverpod
* dio
* retrofit
* freezed
* json_serializable

Templates must be swappable and configurable.

---

# 5. CLI UX

CLI experience must feel professional.

Requirements:

* colored logs
* progress messages
* clean error output
* helpful validation
* fast execution
* deterministic output

---

# 6. Schema Driven Generation

The YAML/JSON schema is the single source of truth.

Example:

feature: auth

functions:

* name: signIn
  api: /auth/login
  method: post

  request:
  phone: string
  password: string

  response:
  token: string

The generator must infer Dart types automatically.

---

# 7. Code Generation Rules

Generated code must:

* follow Flutter best practices
* support enterprise scaling
* use feature-first architecture
* avoid unnecessary abstractions
* minimize boilerplate
* support testing

---

# 8. File Structure Rules

Generated features must follow:

features/
auth/
data/
domain/
presentation/
di/

Avoid generating unnecessary files.

---

# 9. Preferred Technologies

Preferred stack:

* Dart CLI
* mason templates
* yaml parser
* dart_style formatter
* path package
* recase package

Avoid unnecessary dependencies.

---

# 10. Performance

Generation should be fast.

Avoid:

* unnecessary filesystem scans
* repeated parsing
* blocking operations

---

# 11. Future Goals

The architecture must support future features:

* OpenAPI import
* Swagger sync
* VSCode extension
* JetBrains plugin
* cloud sync
* AI-assisted generation
* team templates
* remote template registry

Design the codebase with future extensibility in mind.

---

# 12. Coding Style

Prefer:

* composition over inheritance
* immutable models
* explicit naming
* pure functions when possible

Avoid:

* god classes
* large files
* hidden side effects
* magic strings

---

# 13. Important Rule

This project is a developer tool product.

Every implementation decision must optimize:

* developer productivity
* scalability
* maintainability
* reliability
* extensibility
* developer experience
