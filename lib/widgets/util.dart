import '../model.dart';
import 'package:flutter/material.dart';

//StatefulWidget subclass template
/*
class Bar extends StatefulWidget {
	const Bar({super.key});
	@override
	State<Bar> createState() => _BarState();
}
class _BarState extends State<Bar> {
	@override
	Widget build(BuildContext context) => null;
}
*/

class FlashcardSlider extends StatefulWidget {
	final Model model;
	final Flashcard flashcard;
	const FlashcardSlider(this.model, this.flashcard, {super.key});
	@override
	State<FlashcardSlider> createState() => _FlashcardSliderState();
}
class _FlashcardSliderState extends State<FlashcardSlider> {
	@override
	Widget build(BuildContext context) => Slider(
		value: widget.flashcard.level.toDouble(),
		onChanged: (value) => setState(() => widget.flashcard.level = value.toInt()),
		min: 0,
		max: 4,
		divisions: 4,
		label: widget.flashcard.level.toString()
	);
}
