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

class ExpandableFab extends StatefulWidget {
	final List<Widget> children;
	const ExpandableFab(this.children, {super.key});
	@override
	State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> {
	bool _expanded = false;
	@override
	Widget build(BuildContext context) {
		final buttons = <Widget>[];
		for (final child in widget.children) {
			buttons.add(IgnorePointer(
				ignoring: !_expanded,
				child: AnimatedSlide(
					offset: Offset(_expanded ? 0 : 1, 0),
					curve: Curves.ease,
					duration: const Duration(milliseconds: 200),
					child: AnimatedOpacity(
						opacity: _expanded ? 1 : 0,
						curve: Curves.easeInOut,
						duration: const Duration(milliseconds: 100),
						child: child
					)
				)
			));
		}
		buttons.add(FloatingActionButton.large(
			onPressed: () => setState(() => _expanded = !_expanded),
			child: AnimatedRotation(
				turns: _expanded ? 0.25 : 0,
				duration: const Duration(milliseconds: 200),
				child: const Icon(Icons.add)
			)
		));
		return Column(
			crossAxisAlignment: CrossAxisAlignment.end,
			children: buttons
		);
	}
}
