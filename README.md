This package adds the RoundedTextbox widget, which draws text with a rounded box
(contour) around it, whith the concave corners also rounded. This behaviour is
similar to Instagram and TikTok text backgrounds.

## Getting started

Import the package:
```dart
import 'package:flutter_rounded_textbox/flutter_rounded_textbox.dart';
```

## Usage

```dart
RoundedTextbox(
	padding: 14,
	radius: 8,
	text: "This text has a background,\nand all the\ncorners of the background are rounded,\neven the concave\nones.",
	style: TextStyle(
		color: Colors.white,
		fontSize: 15,
		height: 1.7,
	),
	backgroundColor: Colors.red,
	textAlign: TextAlign.center,
);
```
![Example screenshot](https://github.com/daem-on/flutter_rounded_textbox/blob/master/example/screenshot.png?raw=true)

## Contributing

If you would like to contribute, please [submit a pull request](https://github.com/daem-on/flutter_rounded_textbox/pulls).
