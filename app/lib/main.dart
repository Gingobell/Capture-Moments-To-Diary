import 'package:flutter/widgets.dart';

void main() => runApp(const CaptureMomentApp());

/// M0 bootstrap only. Product navigation and themes are implemented in M2.
class CaptureMomentApp extends StatelessWidget {
  const CaptureMomentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Phase 1 Day background, docs/05-design-system.md §2.
    return const ColoredBox(color: Color(0xFFFBFBF7));
  }
}
