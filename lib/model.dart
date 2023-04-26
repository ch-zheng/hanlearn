import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';

const pinyinVowels = {
	'a': ['ā', 'á', 'ǎ', 'à'],
	'e': ['ē', 'é', 'ě', 'è'],
	'i': ['ī', 'í', 'ǐ', 'ì'],
	'o': ['ō', 'ó', 'ǒ', 'ò'],
	'u': ['ū', 'ú', 'ǔ', 'ù'],
	'v': ['ǖ', 'ǘ', 'ǚ', 'ǜ']
};

class Flashcard {
	String item, pinyin, definition;
	int id, level, streak;
	Flashcard(this.id, this.item, this.pinyin, this.definition, {this.level = 0, this.streak = 0});
	String get prettyPinyin {
		return pinyin.splitMapJoin(
			',',
			onMatch: (s) => ', ',
			onNonMatch: (s) {
				switch (s[s.length - 1]) {
					case '1':
					case '2':
					case '3':
					case '4':
						var tone = int.parse(s[s.length - 1]) - 1;
						//Rule 1: 'a' or 'e' => It takes tone
						//Rule 2: 'ou' => 'o' takes tone
						//Rule 3: Otherwise, 2nd vowel takes tone
						var i = s.indexOf(RegExp('[ae]|ou'));
						if (i < 0) i = s.lastIndexOf(RegExp('[aeiouv]'));
						return s.substring(0, i)
							+ (pinyinVowels[s[i]] as List<String>)[tone]
							+ s.substring(i + 1, s.length - 1);
					default:
						return s;
				}
			}
		);
	}
	String get prettyDefinition {
		return definition.replaceAll(',', ', ').splitMapJoin(
			';',
			onMatch: (s) => '; ',
			onNonMatch: (s) => s.substring(0, 1).toUpperCase() + s.substring(1)
		);
	}
}

class Model {
	late final Database db;
	Model();
	Future<void> initialize() async {
		List<List<dynamic>> characters = await rootBundle.loadStructuredData(
			'assets/characters.csv',
			(text) => Future.value(const CsvToListConverter(eol: "\n").convert(text))
		);
		db = await openDatabase(
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
	}
	Future<List<Flashcard>> drawFlashcards(int count) async {
		final rows = await db.query(
			'characters',
			groupBy: 'RANDOM()',
			limit: count
		);
		final result = <Flashcard>[];
		for (final row in rows) {
			result.add(Flashcard(
				row['id'] as int,
				row['character'] as String,
				row['pinyin'] as String,
				row['definition'] as String,
				level: row['level'] as int,
				streak: row['streak'] as int
			));
		}
		return result;
	}
	Future<List<Flashcard>> getFlashcards({int? count, int? offset}) async {
		final rows = await db.query(
			'characters',
			limit: count,
			offset: offset
		);
		final result = <Flashcard>[];
		for (final row in rows) {
			result.add(Flashcard(
				row['id'] as int,
				row['character'] as String,
				row['pinyin'] as String,
				row['definition'] as String,
				level: row['level'] as int,
				streak: row['streak'] as int
			));
		}
		return result;
	}
}
