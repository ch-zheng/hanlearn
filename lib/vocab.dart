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
					child: Consumer<Model>(
						builder: (context, model, child) => Text(
							_flashcardType == FlashcardType.character ?
								'${model.knownChars} characters active'
								: '${model.knownWords.length} words active',
							style: Theme.of(context).textTheme.bodyMedium
						)
					)
				),
				const Divider(height: 1, thickness: 1),
				//Vocabulary list
				Expanded(child: VocabList(_flashcardType, controller: _scrollController)),
			]),
			//Floating action buttons
			Positioned(right: 8, bottom: 0, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
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
						label: const Text('Advance'),
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
						label: const Text('Withdraw'),
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
				/*
				FloatingActionButton.extended(
					onPressed: () => 0,
					label: const Text('Edit'),
					icon: const Icon(Icons.segment)
				)
				*/
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
		content: TextField(
			controller: _textController,
			keyboardType: TextInputType.number,
			textInputAction: TextInputAction.done,
			decoration: const InputDecoration(
				icon: Icon(Icons.arrow_forward),
				labelText: 'Position'
			),
			inputFormatters: [FilteringTextInputFormatter.digitsOnly]
		),
		actions: [
			TextButton(
				onPressed: () => Navigator.pop(context),
				child: const Text('Cancel')
			),
			TextButton(
				onPressed: () {
					var position = double.tryParse(_textController.text);
					if (position != null) {
						position = max(position - 1, 0);
						scrollController.animateTo(
							65 * position,
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

class VocabList extends StatelessWidget {
	final FlashcardType _flashcardType;
	final ScrollController? controller;
	const VocabList(this._flashcardType, {required this.controller, super.key});
	@override
	Widget build(BuildContext context) {
		final model = Provider.of<Model>(context);
		final deck = _flashcardType == FlashcardType.character ? model.chars : model.knownWords;
		return ListView.separated(
			controller: controller,
			itemBuilder: (context, index) {
				final flashcard = deck[index];
				return SizedBox(height: 64, child: ListTile(
					key: ValueKey(index),
					leading: Row(mainAxisSize: MainAxisSize.min, children: [
						Text('${flashcard.id + 1}'),
						const SizedBox(width: 16),
						Text(
							flashcard.item,
							style: Theme.of(context).textTheme.titleLarge?.apply(
								color: Theme.of(context).colorScheme.primary,
								fontWeightDelta: 1
							)
						)
					]),
					title: Text(
						flashcard.prettyPinyin,
						style: Theme.of(context).textTheme.labelLarge
					),
					subtitle: Text(
						flashcard.prettyDefinition,
						style: Theme.of(context).textTheme.bodyMedium,
						overflow: TextOverflow.ellipsis
					),
					trailing: SizedBox(
						width: 64,
						child: LinearProgressIndicator(value: flashcard.level.toDouble() / 4.0)
					),
					enabled: flashcard.level > 0,
					onTap: flashcard.level > 0 ? () {
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
