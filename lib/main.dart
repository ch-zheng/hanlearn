import 'model.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	//Load vocabulary database
	List<List<dynamic>> characters = await rootBundle.loadStructuredData(
		'assets/characters.csv',
		(text) => Future.value(const CsvToListConverter(eol: "\n").convert(text))
	);
	final db = await openDatabase(
		'hanlearn.db',
		version: 1,
		onCreate: (Database db, int version) {
			db.execute(
				'CREATE TABLE characters ('
					'id INT PRIMARY KEY,'
					'character TEXT,'
					'pinyin TEXT,'
					'definition TEXT,'
					'level INTEGER DEFAULT 0,'
					'streak INTEGER DEFAULT 0'
				')'
			);
		},
		onOpen: (Database db) {
			final query = StringBuffer(
				'INSERT INTO characters(id, character, pinyin, definition) VALUES '
			);
			for (var i = 1; i < characters.length; ++i) {
				final row = characters[i];
				final values = <String>[(i - 1).toString()];
				for (final item in row) {values.add("'$item'");}
				query.write('(');
				query.writeAll(values, ',');
				if (i < characters.length - 1) {query.write('), ');}
				else {query.write(')');}
			}
			query.write(
				' ON CONFLICT(id) DO UPDATE SET'
				'(character, pinyin, definition)'
				'=(excluded.character, excluded.pinyin, excluded.definition)'
			);
			db.execute(query.toString());
		}
	);
	runApp(App(Model(db)));
}
