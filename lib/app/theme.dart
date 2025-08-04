import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../common/theme/my_theme.dart';

part 'theme.g.dart';

@riverpod
MyTheme theme(ThemeRef ref) {
  return MyTheme();
}
