# 4-Layer UI Architecture

## Layer Overview

```
Layer 1: Page    — Route handlers, state composition, NO UI details
Layer 2: Business — Domain-specific composite widgets
Layer 3: Base     — Design system primitives (ONLY layer with Material/Cupertino)
Layer 4: Official — NEVER imported directly
```

## Import Rules (Enforced by CI)

| Import | Page | Business | Base | Official |
|--------|------|----------|------|----------|
| `package:flutter/material.dart` | ❌ | ❌ | ✅ | ✅ |
| `package:flutter/cupertino.dart` | ❌ | ❌ | ✅ | ✅ |
| Base layer widgets | ✅ | ✅ | N/A | ❌ |
| Business layer widgets | ✅ | ✅ | ❌ | ❌ |
| Providers | ✅ | ✅ | ❌ | ❌ |
| API calls (Dio/http) | ❌ | ❌ | ❌ | ❌ |

## What Goes Where

### Page Layer (`presentation/pages/`)
- One file per route/screen
- Watches Riverpod providers
- Composes Business-layer widgets
- Handles routing and navigation events
- Contains NO: colors, fonts, padding values, Material widgets

### Business Layer (`presentation/business/`)
- Domain-specific widget compositions (LoginForm, OrderCard)
- Receives ALL data via constructor parameters
- Uses Base layer for all rendering: AppText, AppButton, AppCard
- Makes NO API calls directly

### Base Layer (`presentation/base/`)
- Design system widgets: AppButton, AppText, AppInput, AppCard, AppDialog
- Theme definitions: color tokens, typography, spacing
- The ONLY layer that imports `material.dart` or `cupertino.dart`
- All widgets must support: light, dark, high-contrast, accessibility labels

### Official Layer (`presentation/official/`)
- Contains a README: "Never import directly"
- Material/Cupertino widgets are wrapped by Base layer
- No other code imports from this directory

## Examples

### ✅ Correct — Page layer
```dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenInsets,
          child: const LoginForm(), // Business layer
        ),
      ),
    );
  }
}
```

### ❌ Wrong — Page layer importing Material directly
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Login', style: TextStyle(fontSize: 24)), // VIOLATION!
        ElevatedButton(onPressed: (){}, child: Text('Go')), // VIOLATION!
      ],
    );
  }
}
```
