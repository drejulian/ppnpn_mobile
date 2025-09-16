part of 'theme.dart';

String _$themeHash() => r'02dcd025a79312114e8c7bdd92a43bc1f80cbf66';

/// See also [theme].
@ProviderFor(theme)
final themeProvider = AutoDisposeProvider<MyTheme>.internal(
  theme,
  name: r'themeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$themeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ThemeRef = AutoDisposeProviderRef<MyTheme>;