import 'package:flutter/material.dart';
import 'package:flutter_rounded_textbox/flutter_rounded_textbox.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: RoundedTextDemo()
    );
  }
}

const testText =
    "Appends up to four conic curves weighted to describe an oval of radius and rotated by rotation (measured in degrees and clockwise). The first curve begins from the last point in the path and the last ends at arcEnd. The curves follow a path in a direction determined by clockwise and largeArc in such a way that the sweep angle is always less than 360 degrees. A simple line is appended if either radii are zero or the last point in the path is arcEnd. The radii are scaled to fit the last path point if both are greater than zero but too small to describe an arc.";

class RoundedTextDemo extends StatefulWidget {
  const RoundedTextDemo({Key? key}) : super(key: key);

  @override
  State<RoundedTextDemo> createState() => _RoundedTextDemoState();
}

class _RoundedTextDemoState extends State<RoundedTextDemo> {
  final TextEditingController _controller = TextEditingController(
    text: testText,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints.expand(),
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      return RoundedTextbox(
                        padding: 14,
                        radius: 8,
                        text: value.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.7,
                        ),
                        backgroundColor: Colors.red,
                        textAlign: TextAlign.center,
                      );
                    }),
              ),
            ),
            TextField(
              controller: _controller,
              maxLines: 4,
            )
          ],
        ),
      ),
    );
  }
}
