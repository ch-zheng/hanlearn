import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:collection';
import 'dart:math';

//Maps vowels to tone-marked characters
const _pinyinVowels = {
	'a': ['ā', 'á', 'ǎ', 'à', 'a'],
	'e': ['ē', 'é', 'ě', 'è', 'e'],
	'i': ['ī', 'í', 'ǐ', 'ì', 'i'],
	'o': ['ō', 'ó', 'ǒ', 'ò', 'o'],
	'u': ['ū', 'ú', 'ǔ', 'ù', 'u'],
	'v': ['ǖ', 'ǘ', 'ǚ', 'ǜ', 'ü']
};

enum FlashcardType {character, word}

class Flashcard {
	FlashcardType type;
	String item, pinyin, definition;
	int id, level, streak;
	Flashcard(
		this.type, this.id, this.item, this.pinyin, this.definition,
		{this.level = 0, this.streak = 0}
	);
	String get prettyPinyin => pinyin.splitMapJoin(
		RegExp(r'[\s/]'),
		onMatch: (m) => m[0] ?? '',
		onNonMatch: (s) {
			switch (s[s.length - 1]) {
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
					var tone = int.parse(s[s.length - 1]) - 1;
					//Rule 1: 'a' or 'e' => It takes tone
					//Rule 2: 'ou' => 'o' takes tone
					//Rule 3: Otherwise, 2nd vowel takes tone
					var i = s.indexOf(RegExp('[ae]|ou'));
					if (i < 0) i = s.lastIndexOf(RegExp('[aeiouv]'));
					return s.substring(0, i)
						+ (_pinyinVowels[s[i]] as List<String>)[tone]
						+ s.substring(i + 1, s.length - 1);
				default:
					return s;
			}
		}
	);
	String get prettyDefinition => definition.splitMapJoin(
		'/',
		onMatch: (s) => '/',
		onNonMatch: (s) => s.substring(0, 1).toUpperCase() + s.substring(1)
	);
	/*
	@override
	String toString() => '($id, $item, $pinyin, $definition, $level, $streak)';
	*/
}

class Model extends ChangeNotifier {
	final Database _db;
	final List<Flashcard> _chars;
	final List<Flashcard> _words;
	var _knownChars = 0;
	var _knownWords = 0;
	final _knownRunes = Set<int>.of('\u2026'.runes);
	Model(this._db, this._chars, this._words) {
		while (_knownChars < _chars.length && _chars[_knownChars].level > 0) {
			++_knownChars;
		}
		while (_knownWords < _words.length && _words[_knownWords].level > 0) {
			++_knownWords;
		}
		for (var i = 0; i < _knownChars; ++i) {
			final flashcard = _chars[i];
			_knownRunes.addAll(flashcard.item.runes);
		}
	}
	UnmodifiableListView<Flashcard> get chars => UnmodifiableListView(_chars);
	UnmodifiableListView<Flashcard> get words => UnmodifiableListView(_words);
	int get knownChars => _knownChars;
	int get knownWords => _knownWords;
	//How many character flashcards are eligible to be drawn
	int activeCharCount(int maxLevel) {
		int active = 0;
		for (var i = 0; i < _knownChars; ++i) {
			final flashcard = _chars[i];
			active += flashcard.level <= maxLevel ? 1 : 0;
		}
		return active;
	}
	//How many word flashcards are eligible to be drawn
	int activeWordCount(int maxLevel) {
		int result = 0;
		for (var i = 0; i < _knownWords; ++i) {
			final flashcard = _words[i];
			result += flashcard.level <= maxLevel ? 1 : 0;
		}
		return result;
	}
	void update(Flashcard flashcard) {
		final String table;
		switch (flashcard.type) {
			case FlashcardType.character:
				table = 'characters';
				break;
			case FlashcardType.word:
				table = 'words';
				break;
		}
		_db.update(
			table,
			{'level': flashcard.level, 'streak': flashcard.streak},
			where: 'id = ?',
			whereArgs: [flashcard.id]
		);
		notifyListeners();
	}
	void updateSet(Iterable flashcards) {
		final batch = _db.batch();
		for (final flashcard in flashcards) {
			switch (flashcard.type) {
				case FlashcardType.character:
					batch.update(
						'characters',
						{'level': flashcard.level, 'streak': flashcard.streak},
						where: 'id = ?',
						whereArgs: [flashcard.id]
					);
					break;
				case FlashcardType.word:
					batch.update(
						'words',
						{'level': flashcard.level, 'streak': flashcard.streak},
						where: 'id = ?',
						whereArgs: [flashcard.id]
					);
					break;
			}
		}
		batch.commit(noResult: true);
		notifyListeners();
	}
	//Add new characters to study
	int advance(int count) {
		final batch = _db.batch();
		//Add characters
		final limit = min(_knownChars + count, _chars.length);
		final result = limit - _knownChars;
		while (_knownChars < limit) {
			final flashcard = _chars[_knownChars];
			flashcard.level = 1;
			batch.update(
				'characters',
				{'level': flashcard.level},
				where: 'id = ?',
				whereArgs: [flashcard.id]
			);
			_knownRunes.addAll(flashcard.item.runes);
			++_knownChars;
		}
		//Add words
		for (var i = _knownWords; i < _words.length; ++i) {
			final flashcard = _words[i];
			if (_knownRunes.containsAll(flashcard.item.runes)) {
				flashcard.level = 1;
				batch.update(
					'words',
					{'level': flashcard.level},
					where: 'id = ?',
					whereArgs: [flashcard.id]
				);
				++_knownWords;
			} else {
				break;
			}
		}
		batch.commit(noResult: true);
		notifyListeners();
		return result;
	}
	//Remove characters from study
	int retreat(int count) {
		final batch = _db.batch();
		//Remove characters
		final limit = max(_knownChars - count, 0);
		final result = _knownChars - limit;
		while (_knownChars > limit) {
			--_knownChars;
			final flashcard = _chars[_knownChars];
			flashcard.level = 0;
			flashcard.streak = 0;
			batch.update(
				'characters',
				{
					'level': flashcard.level,
					'streak': flashcard.streak
				},
				where: 'id = ?',
				whereArgs: [flashcard.id]
			);
			_knownRunes.removeAll(flashcard.item.runes);
		}
		//Remove words
		while (_knownWords > 0) {
			final flashcard = _words[_knownWords];
			if (!_knownRunes.containsAll(flashcard.item.runes)) {
				flashcard.level = 0;
				flashcard.streak = 0;
				batch.update(
					'words',
					{
						'level': flashcard.level,
						'streak': flashcard.streak
					},
					where: 'id = ?',
					whereArgs: [flashcard.id]
				);
				--_knownWords;
			} else {
				break;
			}
		}
		batch.commit(noResult: true);
		notifyListeners();
		return result;
	}
	void editCharRange(int start, int end, int level) {
		assert(start >= 0);
		assert(start < end);
		assert(end <= _knownChars);
		assert(level > 0 && level <= 4);
		for (var i = start; i < end; ++i) {
			_chars[i].level = level;
		}
		_db.update(
			'characters',
			{'level': level},
			where: 'id >= ? AND id < ?',
			whereArgs: [start, end]
		);
		notifyListeners();
	}
	void editWordRange(int start, int end, int level) {
		assert(start >= 0);
		assert(start < end);
		assert(end <= _knownWords);
		assert(level > 0 && level <= 4);
		for (var i = start; i < end; ++i) {
			_words[i].level = level;
		}
		_db.update(
			'words',
			{'level': level},
			where: 'id >= ? AND id < ?',
			whereArgs: [start, end]
		);
		notifyListeners();
	}
	UnmodifiableListView<Flashcard> draw(int count, {int maxLevel = 4}) {
		assert(count >= 0);
		assert(maxLevel > 0);
		assert(maxLevel <= 4);
		final candidates = <Flashcard>[];
		candidates
			..insertAll(candidates.length, _chars.sublist(0, _knownChars))
			..insertAll(candidates.length, _words.sublist(0, _knownWords))
			..retainWhere((item) => item.level <= maxLevel)
			..shuffle();
		return UnmodifiableListView(candidates.getRange(0, min(count, candidates.length)));
	}
	UnmodifiableListView<Flashcard> drawChars(int count, {int maxLevel = 4}) {
		assert(count >= 0);
		final candidates = _chars.sublist(0, _knownChars)
			..retainWhere((item) => item.level <= maxLevel)
			..shuffle();
		return UnmodifiableListView(candidates.getRange(0, min(count, candidates.length)));
	}
	UnmodifiableListView<Flashcard> drawWords(int count, {int maxLevel = 4}) {
		assert(count >= 0);
		final candidates = _words.sublist(0, _knownWords)
			..retainWhere((item) => item.level <= maxLevel)
			..shuffle();
		return UnmodifiableListView(candidates.getRange(0, min(count, candidates.length)));
	}
	static Future<Model> build() async {
		//Create SQL database
		final db = await openDatabase(
			'hanlearn.db',
			version: 2,
			onCreate: (Database db, int version) async {
				//Define tables
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
				db.execute(
					'CREATE TABLE words ('
						'id INT PRIMARY KEY,'
						'word TEXT,'
						'pinyin TEXT,'
						'definition TEXT,'
						'level INTEGER DEFAULT 0,'
						'streak INTEGER DEFAULT 0'
					')'
				);
				//Load CSV data
				final List<List<dynamic>> charData = await rootBundle.loadStructuredData(
					'assets/characters.csv',
					(text) => Future.value(const CsvToListConverter(eol: "\n").convert(text))
				);
				final List<List<dynamic>> wordData = await rootBundle.loadStructuredData(
					'assets/words.csv',
					(text) => Future.value(const CsvToListConverter(eol: "\n").convert(text))
				);
				//Insert data into tables
				final batch = db.batch();
				//Insert characters
				for (var i = 1; i < charData.length; ++i) {
					final row = charData[i];
					batch.insert(
						'characters',
						{
							'id': i - 1,
							'character': row[0],
							'pinyin': row[1],
							'definition': row[2]
						},
						conflictAlgorithm: ConflictAlgorithm.replace
					);
				}
				//Insert words
				for (var i = 1; i < wordData.length; ++i) {
					final row = wordData[i];
					batch.insert(
						'words',
						{
							'id': i - 1,
							'word': row[0],
							'pinyin': row[1],
							'definition': row[2]
						},
						conflictAlgorithm: ConflictAlgorithm.replace
					);
				}
				batch.commit(noResult: true);
			},
			onUpgrade: (Database db, int oldVersion, int newVersion) async {
				//Load CSV data
				final List<List<dynamic>> wordData = await rootBundle.loadStructuredData(
					'assets/words.csv',
					(text) => Future.value(const CsvToListConverter(eol: "\n").convert(text))
				);
				//Inflate into flashcards
				final words = <Flashcard>[];
				for (var i = 1; i < wordData.length; ++i) {
					final row = wordData[i];
					words.add(Flashcard(
						FlashcardType.word,
						i - 1,
						row[0],
						row[1],
						row[2]
					));
				}
				//Merge with existing data
				final lookup = HashMap<String, int>();
				for (final word in words) {
					lookup[word.item] = word.id;
				}
				for (final row in await db.query('words')) {
					final index = lookup[row['word']];
					if (index != null) {
						final word = words[index];
						word.level = row['level'] as int;
						word.streak = row['streak'] as int;
					}
				}
				final last = words.lastIndexWhere((word) => word.level > 0);
				for (var i = 0; i < last; ++i) {
					final word = words[i];
					word.level = max(word.level, 1);
				}
				//Insert words
				final batch = db.batch();
				for (final word in words) {
					batch.insert(
						'words',
						{
							'id': word.id,
							'word': word.item,
							'pinyin': word.pinyin,
							'definition': word.definition,
							'level': word.level,
							'streak': word.streak
						},
						conflictAlgorithm: ConflictAlgorithm.replace
					);
				}
				batch.commit(noResult: true);
			}
		);
		//Create character flashcards
		final characters = <Flashcard>[];
		for (final row in await db.query('characters')) {
			characters.add(Flashcard(
				FlashcardType.character,
				row['id'] as int,
				row['character'] as String,
				row['pinyin'] as String,
				row['definition'] as String,
				level: row['level'] as int,
				streak: row['streak'] as int
			));
		}
		//Create word flashcards
		final words = <Flashcard>[];
		for (final row in await db.query('words')) {
			words.add(Flashcard(
				FlashcardType.word,
				row['id'] as int,
				row['word'] as String,
				row['pinyin'] as String,
				row['definition'] as String,
				level: row['level'] as int,
				streak: row['streak'] as int
			));
		}
		return Model(db, characters, words);
	}
}
