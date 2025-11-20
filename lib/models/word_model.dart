class WordModel {
  final String word;
  final String? phonetic;
  final List<Meaning> meanings;
  final List<String> phonetics;

  WordModel({
    required this.word,
    this.phonetic,
    required this.meanings,
    required this.phonetics,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      word: json['word'] ?? '',
      phonetic: json['phonetic'],
      meanings: (json['meanings'] as List<dynamic>?)
              ?.map((m) => Meaning.fromJson(m))
              .toList() ??
          [],
      phonetics: (json['phonetics'] as List<dynamic>?)
              ?.map((p) => p['text'] as String? ?? '')
              .where((p) => p.isNotEmpty)
              .toList() ??
          [],
    );
  }

  String get firstDefinition {
    if (meanings.isNotEmpty && meanings[0].definitions.isNotEmpty) {
      return meanings[0].definitions[0].definition;
    }
    return 'No definition available';
  }

  String get partOfSpeech {
    if (meanings.isNotEmpty) {
      return meanings[0].partOfSpeech;
    }
    return '';
  }

  List<String> get exampleSentences {
    final examples = <String>[];
    for (final meaning in meanings) {
      for (final def in meaning.definitions) {
        if (def.example != null && def.example!.isNotEmpty) {
          examples.add(def.example!);
        }
      }
    }
    return examples;
  }
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'] ?? '',
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((d) => Definition.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.definition,
    this.example,
    required this.synonyms,
    required this.antonyms,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] ?? '',
      example: json['example'],
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      antonyms: (json['antonyms'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          [],
    );
  }
}


