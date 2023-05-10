import 'model.dart';
import 'settings.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:collection';

enum _StreakStatus {neutral, good, bad}

class StudyPage extends StatefulWidget {
	const StudyPage({super.key});
	@override
	State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> 
	with AutomaticKeepAliveClientMixin<StudyPage> {
	var _flashcards = UnmodifiableListView<Flashcard>([]);
	var _streaks = <_StreakStatus>[];
	int _flashcardIndex = 0;
	bool _flashcardShown = false;
	final _pageController = PageController();
	void _nextBatch() {
		final model = Provider.of<Model>(context, listen: false);
		//Update streaks
		for (var i = 0; i < _flashcards.length; ++i) {
			final flashcard = _flashcards[i];
			final streak = _streaks[i];
			switch (streak) {
				case _StreakStatus.good:
					flashcard.streak += 1;
					break;
				case _StreakStatus.bad:
					flashcard.streak = 0;
					break;
				case _StreakStatus.neutral:
					break;
			}
		}
		model.updateSet(_flashcards);
		_drawFlashcards();
	}
	void _drawFlashcards() {
		final model = Provider.of<Model>(context, listen: false);
		final settings = Provider.of<Settings>(context, listen: false);
		final batchSize = settings.batchSize;
		final maxLevel = settings.maxLevel;
		switch (settings.flashcardType) {
			case 0:
				_flashcards = model.drawChars(batchSize, maxLevel: maxLevel);
				break;
			case 1:
				_flashcards = model.drawWords(batchSize, maxLevel: maxLevel);
				break;
			case 2:
				_flashcards = model.draw(batchSize, maxLevel: maxLevel);
				break;
		}
		_streaks = List.filled(_flashcards.length, _StreakStatus.neutral);
	}
	@override
	void initState() {
		super.initState();
		_drawFlashcards();
	}
	@override
	Widget build(BuildContext context) {
		super.build(context);
		final Widget deck, goodButton, badButton, slider;
		if (_flashcards.isNotEmpty) {
			final flashcard = _flashcards[_flashcardIndex];
			deck = GestureDetector(
				onTap: () => setState(() => _flashcardShown = !_flashcardShown),
				child: PageView.builder(
					controller: _pageController,
					onPageChanged: (value) => setState(() {
						_flashcardIndex = value;
						_flashcardShown = false;
					}),
					itemBuilder: (context, index) {
						return Center(child: Padding (
							padding: const EdgeInsets.all(32),
							child: _Flashcard(
								key: ValueKey(flashcard.item),
								flashcard,
								shown: index == _flashcardIndex && _flashcardShown
							)
						));
					},
					itemCount: _flashcards.length
				)
			);
			goodButton = ElevatedButton.icon(
				onPressed: () => setState(() {
					switch (_streaks[_flashcardIndex]) {
						case _StreakStatus.neutral:
						case _StreakStatus.bad:
							_streaks[_flashcardIndex] = _StreakStatus.good;
							ScaffoldMessenger.of(context).showSnackBar(SnackBar(
								content: Text(
									'Streak incremented to ${flashcard.streak + 1}',
									style: Theme.of(context).textTheme.bodyMedium?.apply(
										color: Theme.of(context).colorScheme.onInverseSurface
									)
								),
								duration: const Duration(milliseconds: 500)
							));
							break;
						case _StreakStatus.good:
							_streaks[_flashcardIndex] = _StreakStatus.neutral;
							break;
					}
				}),
				style: _streaks[_flashcardIndex] == _StreakStatus.good ?
					ElevatedButton.styleFrom(
						foregroundColor: Theme.of(context).colorScheme.onSecondary,
						backgroundColor: Theme.of(context).colorScheme.secondary
					) : null,
				icon: const Icon(Icons.thumb_up),
				label: const Text('Recalled')
			);
			badButton = ElevatedButton.icon(
				onPressed: () => setState(() {
					switch (_streaks[_flashcardIndex]) {
						case _StreakStatus.neutral:
						case _StreakStatus.good:
							_streaks[_flashcardIndex] = _StreakStatus.bad;
							ScaffoldMessenger.of(context).showSnackBar(SnackBar(
								content: Text(
									'Streak reset to 0',
									style: Theme.of(context).textTheme.bodyMedium?.apply(
										color: Theme.of(context).colorScheme.onInverseSurface
									)
								),
								duration: const Duration(milliseconds: 500)
							));
							break;
						case _StreakStatus.bad:
							_streaks[_flashcardIndex] = _StreakStatus.neutral;
							break;
					}
				}),
				style: _streaks[_flashcardIndex] == _StreakStatus.bad ?
					ElevatedButton.styleFrom(
						foregroundColor: Theme.of(context).colorScheme.onSecondary,
						backgroundColor: Theme.of(context).colorScheme.secondary
					) : null,
				icon: const Icon(Icons.thumb_down),
				label: const Text('Forgot')
			);
			slider = Slider(
				value: max(flashcard.level.toDouble(), 1),
				onChanged: (value) => setState(() {
					flashcard.level = value.toInt();
					final model = Provider.of<Model>(context, listen: false);
					model.update(flashcard);
				}),
				min: 1,
				max: 4,
				divisions: 3,
				label: flashcard.level.toString()
			);
		} else {
			deck = Center(child: Text(
				'No Flashcards',
				style: Theme.of(context).textTheme.titleLarge
			));
			goodButton = ElevatedButton.icon(
				onPressed: null,
				icon: const Icon(Icons.thumb_up),
				label: const Text('Recalled')
			);
			badButton = ElevatedButton.icon(
				onPressed: null,
				icon: const Icon(Icons.thumb_down),
				label: const Text('Forgot')
			);
			slider = const Slider(value: 0, onChanged: null);
		}
		return Column(children: [
			Expanded(child: deck),
			Text(
				_flashcards.isNotEmpty ? '${_flashcardIndex+1} / ${_flashcards.length}' : '',
				style: Theme.of(context).textTheme.labelLarge
			),
			const Divider(),
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16),
				child: Column(children: [
					FractionallySizedBox(widthFactor: 1, child: goodButton),
					FractionallySizedBox(widthFactor: 1, child: badButton),
					Row(children: [
						Text('Familiarity', style: Theme.of(context).textTheme.labelLarge),
						Expanded(child: slider)
					]),
					TextButton(
						onPressed: () => setState(() {
							if (_flashcards.isNotEmpty) {
								_pageController.animateToPage(
									0,
									duration: Duration(milliseconds: min(100 * _flashcardIndex, 500)),
									curve: Curves.decelerate
								).then((value) => setState(() => _nextBatch()));
							} else {
								_nextBatch();
							}
						}),
						child: const Text('Next Batch')
					)
				])
			)
		]);
	}
	@override
	bool get wantKeepAlive => true;
}

class _Flashcard extends StatelessWidget {
	final dynamic _flashcard;
	final bool shown;
	const _Flashcard(this._flashcard, {this.shown = false, super.key});
	@override
	Widget build(BuildContext context) {
		final prettyDefinition = _flashcard.prettyDefinition;
		final Widget contents = !shown ? Text(
			_flashcard.item,
			style: Theme.of(context).textTheme.displayLarge?.apply(
				//color: Theme.of(context).colorScheme.onInverseSurface
				color: Theme.of(context).colorScheme.primary
			),
			textAlign: TextAlign.center
		) : Column(
			mainAxisAlignment: MainAxisAlignment.center,
			children: [
				Text(
					_flashcard.item,
					style: Theme.of(context).textTheme.displayLarge?.apply(
						//color: Theme.of(context).colorScheme.onInverseSurface
						color: Theme.of(context).colorScheme.primary
					),
					textAlign: TextAlign.center
				),
				const Divider(indent: 16, endIndent: 16),
				Text(
					_flashcard.prettyPinyin,
					style: Theme.of(context).textTheme.headlineLarge?.apply(
						//color: Theme.of(context).colorScheme.onInverseSurface
					),
					textAlign: TextAlign.center
				),
				const Divider(indent: 16, endIndent: 16),
				Text(
					prettyDefinition,
					style: Theme.of(context).textTheme.bodyLarge?.apply(
						fontSizeFactor: max(2 - 0.04 * prettyDefinition.length, 1),
						//color: Theme.of(context).colorScheme.onInverseSurface
					),
					textAlign: TextAlign.center
				)
			]
		);
		return Card(
			//color: Theme.of(context).colorScheme.inverseSurface,
			child: Center(child: SingleChildScrollView(child: Padding(
				padding: const EdgeInsets.all(8),
				child: PageTransitionSwitcher(
					duration: const Duration(milliseconds: 200),
					reverse: !shown,
					transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
						animation: primary,
						secondaryAnimation: secondary,
						transitionType: SharedAxisTransitionType.vertical,
						fillColor: Colors.transparent,
						child: child
					),
					child: contents
				)
			)))
		);
	}
}
