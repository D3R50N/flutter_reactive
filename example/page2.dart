import 'package:flutter/material.dart';
import 'package:flutter_reactive/widgets/stream_builder.dart';

import 'main.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReactiveStreamBuilder<String>(
        reactive: summary,
        builder:
            (c, s) => Text(
              s.data!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }
}
