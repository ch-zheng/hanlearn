import 'settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
	final _batchSizeEditor = TextEditingController();
	final _advanceSizeEditor = TextEditingController();
	SettingsPage({super.key});
	@override
	Widget build(BuildContext context) => Consumer<Settings>(
		builder: (context, settings, child) {
			_batchSizeEditor.value = TextEditingValue(text: settings.batchSize.toString());
			_advanceSizeEditor.value = TextEditingValue(text: settings.advanceSize.toString());
			return SingleChildScrollView(child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16),
				child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
					//Batch size
					Text('Batch size', style: Theme.of(context).textTheme.titleMedium),
					TextField(
						controller: _batchSizeEditor,
						keyboardType: TextInputType.number,
						textInputAction: TextInputAction.done,
						decoration: const InputDecoration(
							icon: Icon(Icons.horizontal_split),
							labelText: 'Batch size',
							helperText: 'Number of flashcards seen at once'
						),
						maxLength: 3,
						inputFormatters: [FilteringTextInputFormatter.digitsOnly],
						onSubmitted: (input) => settings.batchSize = int.parse(input)
					),
					const Divider(),
					//Maximum level
					Text('Maximum level', style: Theme.of(context).textTheme.titleMedium),
					Slider(
						value: settings.maxLevel.toDouble(),
						onChanged: (value) => settings.maxLevel = value.toInt(),
						min: 1,
						max: 4,
						divisions: 3,
						label: settings.maxLevel.toString()
					),
					const Divider(),
					//Flashcard types
					Text('Flashcard type', style: Theme.of(context).textTheme.titleMedium),
					Column(children: [
						RadioListTile<int>(
							value: 0,
							groupValue: settings.flashcardType,
							onChanged: (value) => settings.flashcardType = value ?? 0,
							title: const Text('Characters')
						),
						RadioListTile<int>(
							value: 1,
							groupValue: settings.flashcardType,
							onChanged: (value) => settings.flashcardType = value ?? 1,
							title: const Text('Words')
						),
						RadioListTile<int>(
							value: 2,
							groupValue: settings.flashcardType,
							onChanged: (value) => settings.flashcardType = value ?? 2,
							title: const Text('Characters & Words')
						),
					]),
					const Divider(),
					//Advancement size
					Text('Advancement size', style: Theme.of(context).textTheme.titleMedium),
					TextField(
						controller: _advanceSizeEditor,
						keyboardType: TextInputType.number,
						textInputAction: TextInputAction.done,
						decoration: const InputDecoration(
							icon: Icon(Icons.arrow_forward),
							labelText: 'Advancement size',
							helperText: 'Number of characters learned at once'
						),
						maxLength: 4,
						inputFormatters: [FilteringTextInputFormatter.digitsOnly],
						onSubmitted: (input) => settings.advanceSize = int.parse(input)
					),
				])
			));
		}
	);
}
