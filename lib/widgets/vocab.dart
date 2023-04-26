import '../model.dart';
import 'package:flutter/material.dart';

class VocabPage extends StatefulWidget {
	final Model model;
	const VocabPage(this.model, {super.key});
	@override
	State<VocabPage> createState() => _VocabState();
}

class _VocabState extends State<VocabPage> 
	with AutomaticKeepAliveClientMixin<VocabPage> {
	var flashcards = <Flashcard>[];
	@override
	initState() {
		super.initState();
		widget.model.getFlashcards(count: 30).then(
			(value) => setState(() => flashcards = value)
		);
	}
	@override
	Widget build(BuildContext context) {
		super.build(context);
		return Column(children: [
			Expanded(child: ListView.separated(
				itemBuilder: (context, index) => VocabListItem(flashcards[index]),
				separatorBuilder: (context, index) => const Divider(height: 2, thickness: 2),
				itemCount: flashcards.length
			))
		]);
	}
	@override
	bool get wantKeepAlive => true;
}

class VocabListItem extends StatelessWidget {
	final Flashcard flashcard;
	const VocabListItem(this.flashcard, {super.key});
	@override
	Widget build(BuildContext context) => Container(
		padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
		color: Theme.of(context).cardColor,
		child: Row(children: [
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text((flashcard.id + 1).toString())
			),
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text(
					flashcard.item,
					style: Theme.of(context).textTheme.labelLarge as TextStyle
				)
			),
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text(
					flashcard.prettyPinyin,
					style: Theme.of(context).textTheme.labelLarge as TextStyle
				)
			),
			Expanded(child: Text(
				flashcard.prettyDefinition,
				style: Theme.of(context).textTheme.bodyMedium as TextStyle,
				overflow: TextOverflow.ellipsis
			)),
			Container(
				margin: const EdgeInsets.only(left: 16),
				child: SizedBox(
					width: 64,
					child: LinearProgressIndicator(value: flashcard.level.toDouble() / 4.0)
				)
			),
			Container(
				margin: const EdgeInsets.only(left: 16),
				child: Text(
					flashcard.level.toString(),
					style: Theme.of(context).textTheme.labelLarge as TextStyle
				)
			),
		])
	);
}
