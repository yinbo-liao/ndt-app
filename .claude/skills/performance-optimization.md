# Performance Optimization

## Target Metrics

| Metric | Target |
|--------|--------|
| Widget build time | <16ms (60fps) |
| Cold app start | <2s |
| Memory delta per screen | <5MB |
| APK size (release) | <30MB |
| Page generation (subagent) | <3s p95 |

## Build Performance

### Widget Layer
- `const` constructors for ALL widgets (reduces rebuilds 50%+)
- `RepaintBoundary` for independently animating sub-trees
- `ListView.builder` / `GridView.builder` (lazy construction)
- `AutomaticKeepAliveClientMixin` for preserving list state
- Avoid `Opacity` widget; use `AnimatedOpacity` or transparent colors

### State Management
- Prefer `select` to watch specific fields: `ref.watch(provider.select((s) => s.field))`
- Scoped providers for local state (don't put everything in global providers)
- `Provider.autoDispose` for providers that don't need to persist

### Memory Management
- `dispose()` controllers, focus nodes, animation controllers
- Limit `ImageCache`: `PaintingBinding.instance.imageCache.maximumSize = 200`
- Use `WeakReference` for caches
- Profile with Flutter DevTools Memory view

### Network Efficiency
- HTTP/2 multipΓöÇ├íÇöÇexing with Dio
- GraphQL query batching (if applicable)
- Response compression (Brotli preferred)
- Offline-first with Hive: serve from cache, update in background

### Animation
- `AnimatedBuilder` / `AnimatedWidget` instead of `setState`
- `TickerMode` to pause off-screen animations
- Lottie for complex animations (80% smaller than GIF/video)
- Pre-warm shader compilation: `flutter drive --cache-sksl`

### Startup Time
- Deferred loading: `import 'feature.dart' deferred as feature;`
- Lazy initialization of non-critical services
- Minimize main() work: only essential DI and error handlers

## Profiling Commands
```bash
flutter run --profile                    # Profile mode
flutter run --trace-startup              # Startup trace
flutter test --track-widget-creation     # Widget creation tracking
flutter build apk --analyze-size         # APK size analysis
```
