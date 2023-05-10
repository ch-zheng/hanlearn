import 'model.dart';
import 'settings.dart';
import 'util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';
import 'dart:math';

class VocabPage extends StatelessWidget {
	const VocabPage({super.key});
	@override
	Widget build(BuildContext context) => DefaultTabController(length: 2, child:
		Column(children: [
			const TabBar(tabs: [
				Tab(text: 'Characters'),
				Tab(text: 'Words')
			]),
			Expanded(child: TabBarView(
				physics: const NeverScrollableScrollPhysics(),
				children: [
					VocabTab(FlashcardType.character),
					VocabTab(FlashcardType.word)
				], 
			))
		])
	);
}

class VocabTab extends StatelessWidget {
	final FlashcardType _flashcardType;
	final _scrollController = ScrollController();
	VocabTab(this._flashcardType, {super.key});
	@override
	Widget build(BuildContext context) {
		return Stack(children: [
			Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
				Container(
					padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
					child: Consumer2<Model, Settings>(
						builder: (context, model, settings, child) {
							final maxLevel = settings.maxLevel;
							return Text(
								_flashcardType == FlashcardType.character ?
									'${model.activeCharCount(maxLevel)} out of ${model.knownChars} characters active'
									: '${model.activeWordCount(maxLevel)} out of ${model.knownWords.length} words active',
								style: Theme.of(context).textTheme.bodyMedium
							);
						}
					)
				),
				const Divider(height: 1, thickness: 1),
				//Vocabulary list
				Expanded(child: VocabList(_flashcardType, controller: _scrollController)),
			]),
			//Floating action buttons
			Positioned(right: 8, bottom: 8, child: ExpandableFab([
				//Advance
				if (_flashcardType == FlashcardType.character) Container(
					margin: const EdgeInsets.only(bottom: 8),
					child: FloatingActionButton.extended(
						onPressed: () {
							final model = Provider.of<Model>(context, listen: false);
							final settings = Provider.of<Settings>(context, listen: false);
							final count = model.advance(settings.advanceSize);
							ScaffoldMessenger.of(context).showSnackBar(SnackBar(
								content: Text(
									'Added $count characters',
									style: Theme.of(context).textTheme.bodyMedium?.apply(
										color: Theme.of(context).colorScheme.onInverseSurface
									)
								),
								duration: const Duration(seconds: 1)
							));
						},
						label: const Text('Add'),
						icon: const Icon(Icons.add)
					)
				),
				//Retreat
				if (_flashcardType == FlashcardType.character) Container(
					margin: const EdgeInsets.only(bottom: 8),
					child: FloatingActionButton.extended(
						onPressed: () {
							final model = Provider.of<Model>(context, listen: false);
							final settings = Provider.of<Settings>(context, listen: false);
							final count = model.retreat(settings.advanceSize);
							ScaffoldMessenger.of(context).showSnackBar(SnackBar(
								content: Text(
									'Removed $count characters',
									style: Theme.of(context).textTheme.bodyMedium?.apply(
										color: Theme.of(context).colorScheme.onInverseSurface
									)
								),
								duration: const Duration(seconds: 1)
							));
						},
						label: const Text('Remove'),
						icon: const Icon(Icons.remove)
					)
				),
				//Jump
				Container(margin: const EdgeInsets.only(bottom: 8), child: FloatingActionButton.extended(
					onPressed: () => showDialog(
						context: context,
						builder: (context) => _JumpDialog(_scrollController)
					),
					label: const Text('Jump'),
					icon: const Icon(Icons.arrow_forward)
				)),
				//Edit
				Container(margin: const EdgeInsets.only(bottom: 8), child: FloatingActionButton.extended(
					onPressed: () => showDialog(
						context: context,
						builder: (context) => _EditDialog(_flashcardType)
					),
					label: const Text('Edit'),
					icon: const Icon(Icons.segment)
				))
			]))
		]);
	}
}

class _JumpDialog extends StatelessWidget {
	final ScrollController scrollController;
	final _textController = TextEditingController();
	_JumpDialog(this.scrollController);
	@override
	Widget build(BuildContext context) => AlertDialog(
		title: const Text('Jump'),
		content: TextField(
			controller: _textController,
			decoration: const InputDecoration(
				labelText: 'Position'
			),
			keyboardType: TextInputType.number,
			textInputAction: TextInputAction.done,
			inputFormatters: [FilteringTextInputFormatter.digitsOnly]
		),
		actions: [
			TextButton(
				onPressed: () => Navigator.pop(context),
				child: const Text('Cancel')
			),
			TextButton(
				onPressed: () {
					final position = double.tryParse(_textController.text);
					if (position != null) {
						scrollController.animateTo(
							65 * max(position - 1, 0),
							duration: const Duration(seconds: 1),
							curve: Curves.decelerate
						);
					}
					Navigator.pop(context);
				},
				child: const Text('Go')
			)
		]
	);
}

class _EditDialog extends StatefulWidget {
	final FlashcardType _flashcardType;
	final _textController = TextEditingController();
	_EditDialog(this._flashcardType);
	@override
	State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
	int _sliderValue = 1;
	@override
	Widget build(BuildContext context) => AlertDialog(
		title: const Text('Edit'),
		content: Column(mainAxisSize: MainAxisSize.min, children: [
			TextField(
				controller: widget._textController,
				decoration: const InputDecoration(
					labelText: 'Position'
				),
				keyboardType: TextInputType.number,
				textInputAction: TextInputAction.done,
				inputFormatters: [FilteringTextInputFormatter.digitsOnly]
			),
			Slider(
				value: _sliderValue.toDouble(),
				onChanged: (value) => setState(() => _sliderValue = max(value.toInt(), 1)),
				min: 0,
				max: 4,
				divisions: 4,
				label: _sliderValue.toString()
			)
		]),
		actions: [
			TextButton(
				onPressed: () => Navigator.pop(context),
				child: const Text('Cancel')
			),
			TextButton(
				onPressed: () {
					final count = double.tryParse(widget._textController.text)?.toInt();
					if (count != null) {
						final model = Provider.of<Model>(context, listen: false);
						switch (widget._flashcardType) {
							case FlashcardType.character:
								model.setCharPrefix(count, _sliderValue);
								break;
							case FlashcardType.word:
								model.setWordPrefix(count, _sliderValue);
								break;
						}
					}
					Navigator.pop(context);
				},
				child: const Text('Edit')
			)
		]
	);
}

class VocabList extends StatelessWidget {
	final FlashcardType _flashcardType;
	final ScrollController? controller;
	const VocabList(this._flashcardType, {required this.controller, super.key});
	@override
	Widget build(BuildContext context) {
		final model = Provider.of<Model>(context);
		final deck = _flashcardType == FlashcardType.character ? model.chars : model.knownWords;
		return ListView.separated(
			key: PageStorageKey(_flashcardType),
			controller: controller,
			itemBuilder: (context, index) {
				final flashcard = deck[index];
				final enabled = flashcard.level > 0;
				return SizedBox(height: 64, child: ListTile(
					key: ValueKey(index),
					leading: Row(mainAxisSize: MainAxisSize.min, children: [
						Text('${flashcard.id + 1}'),
						const SizedBox(width: 16),
						Text(
							flashcard.item,
							style: Theme.of(context).textTheme.titleLarge?.apply(
								color: enabled ? Theme.of(context).colorScheme.primary
									: Theme.of(context).colorScheme.secondary,
								fontWeightDelta: 1
							)
						)
					]),
					title: Text(
						flashcard.prettyPinyin,
						style: Theme.of(context).textTheme.labelLarge?.apply(
							color: enabled ? null : Theme.of(context).disabledColor
						)
					),
					subtitle: Text(
						flashcard.prettyDefinition,
						style: Theme.of(context).textTheme.bodyMedium?.apply(
							color: enabled ? null : Theme.of(context).disabledColor
						),
						overflow: TextOverflow.ellipsis
					),
					trailing: Visibility.maintain(visible: enabled, child: SizedBox(
						width: 64,
						child: LinearProgressIndicator(
							value: enabled ? (flashcard.level.toDouble() - 1) / 3.0 : 0
						)
					)),
					enabled: enabled,
					onTap: enabled ? () {
						final sheetRef = Provider.of<Reference<PersistentBottomSheetController>>(context, listen: false);
						final closed = sheetRef.value?.closed ?? Future.value(null);
						closed.then((_) => sheetRef.value = Scaffold.of(context)
							.showBottomSheet((_) => _VocabSheet(flashcard)));
						sheetRef.value?.close();
					} : null
				));
			},
			separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
			itemCount: deck.length
		);
	}
}

class _VocabSheet extends StatelessWidget {
	final Flashcard _flashcard;
	const _VocabSheet(this._flashcard);
	@override
	Widget build(BuildContext context) => FractionallySizedBox(
		widthFactor: 1,
		child: Padding(
			padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
			child: Table(
				columnWidths: const {0: IntrinsicColumnWidth()},
				defaultVerticalAlignment: TableCellVerticalAlignment.middle,
				children: [
					//Definition
					TableRow(children: [
						Column(children: [
							Text(
								_flashcard.item,
								style: Theme.of(context).textTheme.headlineMedium?.apply(
									color: Theme.of(context).colorScheme.primary
								)
							),
							Text(
								_flashcard.prettyPinyin,
								style: Theme.of(context).textTheme.titleMedium,
							)
						]),
						Text(
							_flashcard.prettyDefinition,
							style: Theme.of(context).textTheme.bodyLarge,
						)
					]),
					//Familiarity
					TableRow(children: [
						Text('Familiarity', style: Theme.of(context).textTheme.labelLarge),
						Consumer<Model>(
							builder: (context, model, child) => Slider(
								value: _flashcard.level.toDouble(),
								onChanged: (value) {
									_flashcard.level = value.toInt();
									model.update(_flashcard);
								},
								min: 1,
								max: 4,
								divisions: 3,
								label: _flashcard.level.toString()
							)
						)
					]),
					//Streak
					TableRow(children: [
						Text('Streak', style: Theme.of(context).textTheme.labelLarge),
						Row(children: [
							Text(
								_flashcard.streak.toString(),
								style: Theme.of(context).textTheme.titleMedium?.apply(
									color: Theme.of(context).colorScheme.primary
								)
							),
							const Padding(
								padding: EdgeInsets.symmetric(horizontal: 8),
								child: Icon(Icons.done_all)
							)
						])
					])
				]
			)
		)
	);
}
