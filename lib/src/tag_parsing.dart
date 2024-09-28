import 'package:e621/src/general_enums.dart';

/// Matches characters not allowed in new tags (some old, unused tags violate this).
///
/// https://e621.net/help/tags#guidelines
///
/// * 1 tag and 0 posts w/ `%` (`%82%b5%82%cc%82%e8%82%a8%82%f1_short_hair`)
/// * 0 tags w/ `#`
/// * 8 tags & 0 posts w/ (`,`)[https://e621.net/tags?search%5Bhide_empty%5D=0&search%5Bname_matches%5D=%2A%2C%2A]
/// * 34 tags & 0 posts w/ (`*`)[https://e621.net/tags?search%5Bhide_empty%5D=0&search%5Bname_matches%5D=%2A%5C%2A%2A]
/// * 175 tags & 0 posts w/ (`\`)[https://e621.net/tags?search%5Bhide_empty%5D=0&search%5Bname_matches%5D=%2A%5C%2A%2A]
const disallowedInTagName = r'%,#\\\*';
const disallowedInTagSearch = r'%,#';

/// The `\` is to escape the `-`
const disallowedAsFirstCharacterInTagName = r'\-~';

const allowedInTagName =
    "$allowedAnywhereInTagName|[$disallowedAsFirstCharacterInTagName]";
// const allowedAnywhereInTagName = "[a-zA-Z0-9.()'\"/]";
const allowedAnywhereInTagName = "[^$disallowedInTagName]";

/// A RegExp pattern that matches special characters used in meta-tags
/// * `:`: used for 2 term tags (e.g. `type:gif`)
/// * `!`: (used by the `user` tag to search with the user's id and not their name)[https://e621.net/help/cheatsheet#usermetatags]
/// * `.`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
/// * `/`: used in dates
/// * `*`: wildcard
/// * `"`: used for text searches with spaces
/// * ` `: used for text searches (when inside quotes)
/// * `<`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
/// * `>`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
/// * `=`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
const e6ValidMetaTagCharacters = ':!.-/*" <>=';
const validTag =
    '(?:[^$disallowedAsFirstCharacterInTagName])$allowedAnywhereInTagName*';

/// Successful matches are not necessarily valid, but they are parsed as separate tags.
///
/// Tokens are separated by whitespace. If there is a `"` preceded by a properly
/// formatted metatag supporting text searching (e.g. description, note, source,
/// delreason), either the next `"` or, if there is no next `"`, the next
/// whitespace character is the end of that token.
const tagTokenizer = r'(?<=\s|^|(?:description|note|source|delreason):"[^"]*")'
    r'([^\s]+'
    r'(?:'
    r'(?:'
    r'(?<=(?:description|note|source|delreason):"[^\s]*?)'
    r'[^"]*?(?:"|(?:(?=[^"]*$)\S*))'
    r')|(?=\s|$)'
    r')'
    r')';

/// Successful matches are not necessarily valid, but they are parsed as separate tags.
///
/// Tokens are separated by whitespace. If there is at least 1 pair of quotes, the second quote is the end of that token.
const tagAgnosticTokenizer =
    r'(?<=\s|^|")((?:[^\s"]+|(?="))(?:(?:"[^"]*?(?:"|(?:(?=$|[^"]+$)\S*)))|(?=\s|$)))';
// For Testing Searches
// jun_kobayashi -description" -has"-jun_kobayashi -9"10
// https://e621.net/tags?commit=Search&page=3&search%5Bhide_empty%5D=0&search%5Bname_matches%5D=%2A%22%2A&search%5Border%5D=date

// #region MetaTags
/// https://e621.net/help/cheatsheet#sorting
enum Order with SearchableEnum {
  /// Oldest to newest
  id("id"),

  /// Orders posts randomly *
  random("random"),

  /// Highest score first
  score("score"),

  /// Lowest score first
  scoreAsc("score_asc"),

  /// Most favorites first
  favCount("favcount"),

  /// Least favorites first
  favCountAsc("favcount_asc"),

  /// Most tags first
  tagCount("tagcount"),

  /// Least tags first
  tagCountAsc("tagcount_asc"),

  /// Most comments first
  commentCount("comment_count"),

  /// Least comments first
  commentCountAsc("comment_count_asc"),

  /// Posts with the newest comments
  commentBumped("comment_bumped"),

  /// Posts that have not been commented on for the longest time
  commentBumpedAsc("comment_bumped_asc"),

  /// Largest resolution first
  mPixels("mpixels"),

  /// Smallest resolution first
  mPixelsAsc("mpixels_asc"),

  /// Largest file size first
  fileSize("filesize"),

  /// Smallest file size first
  fileSizeAsc("filesize_asc"),

  /// Wide and short to tall and thin
  landscape("landscape"),

  /// Tall and thin to wide and short
  portrait("portrait"),

  /// Sorts by last update sequence
  change("change"),

  /// Video duration longest to shortest
  duration("duration"),

  /// Video duration shortest to longest
  durationAsc("duration_asc");

  static const matcherNonStrictStr = "($prefix)([^\\s]+)";
  static const matcherStr = "($prefix)(id|random|score|score_asc|"
      "favcount|favcount_asc|tagcount|tagcount_asc|comment_count|"
      "comment_count_asc|comment_bumped|comment_bumped_asc|mpixels|"
      "mpixels_asc|filesize|filesize_asc|landscape|portrait|change|"
      r"duration|duration_asc)(?=\s|$)";
  static RegExp get matcherGenerated => RegExp(matcherStr);
  static const prefix = "order:";
  final String tagSuffix;

  @override
  String get searchString => "$prefix$tagSuffix";

  const Order(this.tagSuffix);
  factory Order.fromTagText(String tagText) =>
      switch (tagText.replaceAll(("$prefix|${r"\s"}"), "")) {
        "id" => id,
        "random" => random,
        "score" => score,
        "score_asc" => scoreAsc,
        "favcount" => favCount,
        "favcount_asc" => favCountAsc,
        "tagcount" => tagCount,
        "tagcount_asc" => tagCountAsc,
        "comment_count" => commentCount,
        "comment_count_asc" => commentCountAsc,
        "comment_bumped" => commentBumped,
        "comment_bumped_asc" => commentBumpedAsc,
        "mpixels" => mPixels,
        "mpixels_asc" => mPixelsAsc,
        "filesize" => fileSize,
        "filesize_asc" => fileSizeAsc,
        "landscape" => landscape,
        "portrait" => portrait,
        "change" => change,
        "duration" => duration,
        "duration_asc" => durationAsc,
        _ => throw ArgumentError.value(tagText, "tagText", "Value not of type"),
      };
  factory Order.fromText(String text) =>
      switch (text.replaceAll(("$prefix|${r"\s"}"), "")) {
        "id" => id,
        String t when t == id.name => id,
        "random" => random,
        String t when t == random.name => random,
        "score" => score,
        String t when t == score.name => score,
        "score_asc" => scoreAsc,
        String t when t == scoreAsc.name => scoreAsc,
        "favcount" => favCount,
        String t when t == favCount.name => favCount,
        "favcount_asc" => favCountAsc,
        String t when t == favCountAsc.name => favCountAsc,
        "tagcount" => tagCount,
        String t when t == tagCount.name => tagCount,
        "tagcount_asc" => tagCountAsc,
        String t when t == tagCountAsc.name => tagCountAsc,
        "comment_count" => commentCount,
        String t when t == commentCount.name => commentCount,
        "comment_count_asc" => commentCountAsc,
        String t when t == commentCountAsc.name => commentCountAsc,
        "comment_bumped" => commentBumped,
        String t when t == commentBumped.name => commentBumped,
        "comment_bumped_asc" => commentBumpedAsc,
        String t when t == commentBumpedAsc.name => commentBumpedAsc,
        "mpixels" => mPixels,
        String t when t == mPixels.name => mPixels,
        "mpixels_asc" => mPixelsAsc,
        String t when t == mPixelsAsc.name => mPixelsAsc,
        "filesize" => fileSize,
        String t when t == fileSize.name => fileSize,
        "filesize_asc" => fileSizeAsc,
        String t when t == fileSizeAsc.name => fileSizeAsc,
        "landscape" => landscape,
        String t when t == landscape.name => landscape,
        "portrait" => portrait,
        String t when t == portrait.name => portrait,
        "change" => change,
        String t when t == change.name => change,
        "duration" => duration,
        String t when t == duration.name => duration,
        "duration_asc" => durationAsc,
        String t when t == durationAsc.name => durationAsc,
        _ => throw ArgumentError.value(text, "text", "Value not of type"),
      };
  static Order? retrieve(String str) {
    try {
      return Order.fromTagText(
          Order.matcherGenerated.firstMatch(str)!.group(2)!);
    } catch (e) {
      return null;
    }
  }

  static (Modifier, Order)? retrieveWithModifier(String str) {
    final v = retrieve(str);
    return v == null ? null : (Modifier.add, v);
  }

  static Iterable<(Modifier, Order)>? retrieveAllWithModifier(String str) {
    try {
      return Order.matcherGenerated
          .allMatches(str)
          .map((e) => (Modifier.add, Order.fromTagText(e.group(2)!)));
    } catch (e) {
      return null;
    }
  }
}

enum FileType with SearchableEnum {
  jpg,
  png,
  gif,
  swf,
  webm;

  static const matcherNonStrictStr =
      "(${Modifier.matcher})($prefixFull)" r"([^\s]+)";
  static final matcherNonStrict = RegExp(matcherNonStrictStr);
  static RegExp get matcherNonStrictGenerated => RegExp(matcherNonStrictStr);
  static const matcherStr = "(${Modifier.matcher})"
      "($prefixFull)"
      r"(jpg|png|gif|swf|webm)(?=\s|$)";
  static final matcher = RegExp(matcherStr);
  static RegExp get matcherGenerated => RegExp(matcherStr);
  static const prefixFull = "type:";
  static const prefix = "type";
  @override
  String get searchString => "$prefixFull$name";
  String get suffix => name;
  factory FileType.fromTagText(String str) => switch (str) {
        "jpeg" => jpg,
        "jpg" => jpg,
        "png" => png,
        "gif" => gif,
        "swf" => swf,
        "webm" => webm,
        _ => throw UnsupportedError("type not supported"),
      };
  factory FileType.fromText(String str) => switch (str) {
        "${prefixFull}jpeg" => jpg,
        "${prefixFull}jpg" => jpg,
        "${prefixFull}png" => png,
        "${prefixFull}gif" => gif,
        "${prefixFull}swf" => swf,
        "${prefixFull}webm" => webm,
        _ => FileType.fromTagText(str),
      };

  static List<(Modifier, FileType)>? retrieveAllWithModifier(String str) {
    if (!FileType.matcherGenerated.hasMatch(str)) {
      return null;
    }
    final ms = FileType.matcherGenerated.allMatches(str);
    final tags = ms.fold(
      <(Modifier, FileType)>{},
      (previousValue, e) => previousValue
        ..add(
          (
            Modifier.fromString(e.group(1) ?? ""),
            FileType.fromTagText(e.group(2)!)
          ),
        ),
    );
    return tags.toList();
  }
}

enum BooleanSearchTag with SearchableStatefulEnum<bool> {
  isChild("ischild"),
  isParent("isparent"),
  hasSource("hassource"),
  hasDescription("hasdescription"),
  ratingLocked("ratinglocked"),
  noteLocked("notelocked"),
  inPool("inpool"),
  pendingReplacements("pending_replacements");

  final String tagPrefix;
  const BooleanSearchTag(this.tagPrefix);
  factory BooleanSearchTag.fromTagText(String str) => switch (str) {
        "ischild" => isChild,
        "isparent" => isParent,
        "hassource" => hasSource,
        "hasdescription" => hasDescription,
        "ratinglocked" => ratingLocked,
        "notelocked" => noteLocked,
        "inpool" => inPool,
        "pending_replacements" => pendingReplacements,
        _ => throw UnsupportedError("type not supported"),
      };
  factory BooleanSearchTag.fromText(String str) => switch (str) {
        "ischild:true" => isChild,
        "ischild:false" => isChild,
        "isparent:true" => isParent,
        "isparent:false" => isParent,
        "hassource:true" => hasSource,
        "hassource:false" => hasSource,
        "hasdescription:true" => hasDescription,
        "hasdescription:false" => hasDescription,
        "ratinglocked:true" => ratingLocked,
        "ratinglocked:false" => ratingLocked,
        "notelocked:true" => noteLocked,
        "notelocked:false" => noteLocked,
        "inpool:true" => inPool,
        "inpool:false" => inPool,
        "pending_replacements:true" => pendingReplacements,
        "pending_replacements:false" => pendingReplacements,
        _ => BooleanSearchTag.fromTagText(str),
      };
  String toSearchTagNullable(bool? value) =>
      value == null ? "" : "$tagPrefix:$value";
  @override
  String toSearch(bool state) => "$tagPrefix:$state";

  static const String matcherStr = "(${Modifier.matcher})"
      r"(ischild|isparent|hassource|hasdescription|ratinglocked|notelocked|inpool|pending_replacements):(true|false)";
  static RegExp get matcher => RegExp(matcherStr);
  // static List<(Modifier, (BooleanSearchTag, bool))>? retrieveAllWithModifier(
  //     String str) {
  //   if (!BooleanSearchTag.matcher.hasMatch(str)) {
  //     return null;
  //   }
  //   validate(Set<(Modifier, (BooleanSearchTag, bool))> set,
  //       (Modifier, (BooleanSearchTag, bool)) e) {
  //     final prior =
  //         set.firstWhere((element) => element.$1 == e.$1, orElse: () => e);
  //     return switch (prior) {
  //       (Modifier m, (_, bool b)) when m == e.$1 && b == e.$2.$2 => set
  //         ..remove(prior)
  //         ..add(e),
  //       (Modifier m, (_, bool b)) when m == e.$1 && b != e.$2.$2 => set..remove(prior),
  //       (Modifier m, (_, bool b)) when m != e.$1 && b == e.$2.$2 => switch ((m,b,e.$1)) {
  //         (Modifier.or, _, Modifier.add) || (Modifier.or, _, Modifier.remove) => set..remove(prior)..add(e),
  //         (Modifier.add, _, Modifier.or) || (Modifier.remove, _, Modifier.or) => set,
  //         (Modifier p1, bool p2,Modifier c) when p1 == Modifier.or =>set..remove(prior)..add(e),
  //         _ => throw UnsupportedError("type not supported"),
  //       },
  //       (Modifier m, (_, bool b)) when m != e.$1 && b == e.$2.$2 => switch ((m,b,e.$1,e.$2.$2)) {
  //         (Modifier p1, bool p2,Modifier c1,bool c2) when p1 == Modifier.or =>set..remove(prior),
  //         _ => throw UnsupportedError("type not supported"),
  //       },
  //     };
  //   }

  //   final ms = BooleanSearchTag.matcher.allMatches(str);
  //   final tags = ms.fold(
  //       <(Modifier, (BooleanSearchTag, bool))>{},
  //       (previousValue, e) =>
  //           validate(previousValue, retrieveWithModifier(e.group(0)!))
  //       // previousValue..add(retrieveWithModifier(e.group(0)!)),
  //       );
  //   return tags.toList();
  // }

  static List<(BooleanSearchTag, bool)>? retrieveAll(String str) {
    if (!BooleanSearchTag.matcher.hasMatch(str)) {
      return null;
    }
    validate(Set<(BooleanSearchTag, bool)> set, (BooleanSearchTag, bool) e) {
      final prior =
          set.firstWhere((element) => element.$1 == e.$1, orElse: () => e);
      return switch (prior.$2) {
        bool t when t == e.$2 => set
          ..remove(prior)
          ..add(e),
        bool t when t != e.$2 => set..remove(prior),
        true || false => throw UnimplementedError(),
      };
    }

    final ms = BooleanSearchTag.matcher.allMatches(str);
    final tags = ms.fold(
        <(BooleanSearchTag, bool)>{},
        (previousValue, e) =>
            validate(previousValue, parseSearchFragment(e.group(0)!))
        // previousValue..add(parseSearchFragment(e.group(0)!)),
        );
    return tags.toList();
  }

  static (Modifier, (BooleanSearchTag, bool))? retrieveWithModifier(
      String str) {
    final m = BooleanSearchTag.matcher.firstMatch(str);
    return m == null
        ? null
        : (
            Modifier.fromString(m.group(1)!),
            (BooleanSearchTag.fromTagText(m.group(2)!), bool.parse(m.group(3)!))
          );
  }

  static (BooleanSearchTag, bool)? tryParseSearchFragment(String str) {
    final m = BooleanSearchTag.matcher.firstMatch(str);
    return m == null
        ? null
        : (
            BooleanSearchTag.fromTagText(m.group(2)!),
            Modifier.fromString(m.group(1)!) != Modifier.remove
                ? bool.parse(m.group(3)!)
                : !bool.parse(m.group(3)!)
          );
  }

  static (BooleanSearchTag, bool) parseSearchFragment(String str) =>
      tryParseSearchFragment(str)!;
}

enum Status with SearchableEnum {
  pending,
  active,
  deleted,
  flagged,
  modqueue,
  any;

  static const prefix = "status";
  static const prefixFull = "status:";
  static const String matcherStr = "(${Modifier.matcher})$prefixFull"
      r"(pending|active|deleted|flagged|modqueue|any)(?=\s|$)";
  static RegExp get matcher => RegExp(matcherStr);

  @override
  String get searchString => "$prefixFull$name";
  factory Status.fromTagText(String str) => switch (str) {
        "pending" => pending,
        "active" => active,
        "deleted" => deleted,
        "flagged" => flagged,
        "modqueue" => modqueue,
        "any" => any,
        _ => throw UnsupportedError("type not supported"),
      };
  factory Status.fromText(String str) => switch (str) {
        "${prefixFull}pending" => pending,
        "${prefixFull}active" => active,
        "${prefixFull}deleted" => deleted,
        "${prefixFull}flagged" => flagged,
        "${prefixFull}modqueue" => modqueue,
        "${prefixFull}any" => any,
        _ => Status.fromTagText(str),
      };

  static List<(Modifier, Status)>? retrieveAllWithModifier(String str) {
    if (!Status.matcher.hasMatch(str)) {
      return null;
    }
    final ms = Status.matcher.allMatches(str);
    final tags = ms.fold(
      <(Modifier, Status)>{},
      (previousValue, e) => previousValue
        ..add(
          (
            Modifier.fromString(e.group(1) ?? ""),
            Status.fromTagText(e.group(2)!)
          ),
        ),
    );
    return tags.toList();
  }
}
// #endregion MetaTags
