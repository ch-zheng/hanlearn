import '../model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class StudyPage extends StatefulWidget {
	final Model model;
	const StudyPage(this.model, {super.key});
	@override
	State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> 
	with AutomaticKeepAliveClientMixin<StudyPage> {
	var flashcards = <Flashcard>[];
	int flashcardIndex = 0;
	bool flashcardShown = false;
	final pageController = PageController();
	@override
	initState() {
		super.initState();
		widget.model.drawFlashcards(10).then(
			(value) => setState(() => flashcards = value)
		);
	}
	@override
	Widget build(BuildContext context) {
		super.build(context);
		final flashcard = flashcards.isNotEmpty ?
			flashcards[flashcardIndex]
			: Flashcard(0, '', '', '');
		return Column(children: [
			Expanded(child: GestureDetector(
				onTap: () => setState(() => flashcardShown = !flashcardShown),
				child: PageView.builder(
					controller: pageController,
					onPageChanged: (value) => setState(() {
						flashcardIndex = value;
						flashcardShown = false;
					}),
					itemBuilder: (context, index) {
						return Center(child: Padding (
							padding: const EdgeInsets.all(32),
							child: FlashcardWidget(
								flashcards[index],
								shown: index == flashcardIndex && flashcardShown
							)
						));
					},
					itemCount: flashcards.length
				)
			)),
			Text(
				'${flashcardIndex+1} / ${flashcards.length}',
				style: Theme.of(context).textTheme.labelLarge as TextStyle
			),
			const Divider(),
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16),
				child: Column(
					children: [
						FractionallySizedBox(
							widthFactor: 1,
							child: ElevatedButton.icon(
								onPressed: () => 0, //TODO
								icon: const Icon(Icons.thumb_up),
								label: const Text('Recalled')
							)
						),
						FractionallySizedBox(
							widthFactor: 1,
							child: ElevatedButton.icon(
								onPressed: () => 0, //TODO
								icon: const Icon(Icons.thumb_down),
								label: const Text('Forgot')
							)
						),
						Row(children: [
							Text('Familiarity', style: Theme.of(context).textTheme.labelLarge as TextStyle),
							Expanded(child: Slider(
								value: max(flashcard.level.toDouble(), 1),
								onChanged: (double value) =>
									setState(() => flashcards[flashcardIndex].level = value.toInt()),
								min: 1,
								max: 4,
								divisions: 3,
								label: flashcard.level.toString()
							)),
						]),
						TextButton(
							onPressed: () {
								pageController.animateToPage(
									0,
									duration: Duration(milliseconds: 100 * flashcardIndex),
									curve: Curves.decelerate
								);
								widget.model.drawFlashcards(10).then(
									(value) => setState(() {
										flashcards = value;
										flashcardIndex = 0;
									})
								);
							},
							child: const Text('Next Batch')
						)
					]
				)
			)
		]);
	}
	@override
	bool get wantKeepAlive => true;
}

class FlashcardWidget extends StatelessWidget {
	final Flashcard flashcard;
	final bool shown;
	const FlashcardWidget(this.flashcard, {this.shown = false, super.key});
	@override
	Widget build(BuildContext context) {
		Widget contents;
		if (!shown) {
			contents = Text(
				key: UniqueKey(),
				flashcard.item,
				style: Theme.of(context).textTheme.displayLarge as TextStyle,
				textAlign: TextAlign.center
			);
		} else {
			contents = Column(
				key: UniqueKey(),
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Text(
						flashcard.item,
						style: Theme.of(context).textTheme.displayLarge as TextStyle,
						textAlign: TextAlign.center
					),
					const Divider(indent: 16, endIndent: 16),
					Text(
						flashcard.prettyPinyin,
						style: Theme.of(context).textTheme.headlineLarge as TextStyle,
						textAlign: TextAlign.center
					),
					const Divider(indent: 16, endIndent: 16),
					Text(
						flashcard.prettyDefinition,
						style: Theme.of(context).textTheme.headlineSmall as TextStyle,
						textAlign: TextAlign.center
					)
				]
			);
		}
		return Card(child: Center(child: Padding(
			padding: const EdgeInsets.all(8),
			child: AnimatedSwitcher(
				duration: const Duration(milliseconds: 50),
				child: contents
			)
		)));
	}
}
