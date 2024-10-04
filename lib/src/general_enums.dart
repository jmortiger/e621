import "dart:ui" show Color;

mixin ApiQueryParameter on Enum {
  String get query;
}

mixin JsonEnum on Enum {
  dynamic toJson();
}

enum PoolCategory with ApiQueryParameter, JsonEnum {
  collection,
  series;

  @override
  String get query => name;

  @override
  dynamic toJson() => name;
  static PoolCategory fromJson(dynamic json, [String? key]) =>
      switch (key != null ? json[key] : json) {
        "collection" => PoolCategory.collection,
        "series" => PoolCategory.series,
        dynamic v => throw UnsupportedError("Value $v not supported, "
            "must be `collection` or `series`.\n\tkey: $key\n\tjson: $json"),
      };
  static PoolCategory fromJsonNonStrict(dynamic json, [String? key]) =>
      switch ((key != null ? json[key] : json).toString().toLowerCase()) {
        "collection" => PoolCategory.collection,
        "series" => PoolCategory.series,
        dynamic v => throw UnsupportedError("Value $v not supported, "
            "must be `collection` or `series`.\n\tkey: $key\n\tjson: $json"),
      };
  @Deprecated("Use query")
  String toJsonString() => name;
  @Deprecated("Use query")
  String toParamString() => name;
  static PoolCategory fromParamString(String name) => switch (name) {
        "collection" => PoolCategory.collection,
        "series" => PoolCategory.series,
        _ => throw UnsupportedError(
            "Value $name not supported, must be `collection` or `series`.",
          ),
      };
}

enum UserLevel with JsonEnum {
  anonymous._default(0, 0, 9, "Anonymous"),
  blocked._default(10, 10, 11, "Blocked"),
  member._default(11, 20, 21, "Member"),
  privileged._default(21, 30, 31, "Privileged"),
  formerStaff._default(31, 34, 35, "Former Staff"),
  janitor._default(35, 35, 36, "Janitor"),
  moderator._default(36, 40, 41, "Moderator"),
  admin._default(41, 50, 51, "Admin");

  static const anonymousLevel = 0;
  static const blockedLevel = 10;
  static const memberLevel = 20;
  static const privilegedLevel = 30;
  static const formerStaffLevel = 34;
  static const janitorLevel = 35;
  static const moderatorLevel = 40;
  static const adminLevel = 50;
  final int min;
  final int value;
  final int max;
  final String namePretty;

  @override
  dynamic toJson() => namePretty;
  @override
  String toString() => namePretty;
  @Deprecated("Use toJson")
  String get jsonString => namePretty;
  // String get namePretty => "${name[0].toUpperCase()}${name.substring(1)}";
  int get level => switch (this) {
        anonymous => anonymousLevel,
        blocked => blockedLevel,
        member => memberLevel,
        privileged => privilegedLevel,
        formerStaff => formerStaffLevel,
        janitor => janitorLevel,
        moderator => moderatorLevel,
        admin => adminLevel,
      };
  const UserLevel._default(this.min, this.value, this.max, this.namePretty);
  factory UserLevel.fromJson(dynamic json, [String? key]) =>
      switch (key != null ? json[key] : json) {
        "Anonymous" => anonymous,
        "Blocked" => blocked,
        "Member" => member,
        "Privileged" => privileged,
        "Former Staff" => formerStaff,
        "Janitor" => janitor,
        "Moderator" => moderator,
        "Admin" => admin,
        dynamic v => throw ArgumentError.value(
            (v, key, json),
            "(output, key, json)",
            'must be a value of "Anonymous", "Blocked", "Member", "Privileged"'
                ', "Former Staff", "Janitor", "Moderator", or "Admin".',
          ),
      };
  factory UserLevel(String json) => switch (json) {
        "Anonymous" => anonymous,
        "Blocked" => blocked,
        "Member" => member,
        "Privileged" => privileged,
        "Former Staff" => formerStaff,
        "Janitor" => janitor,
        "Moderator" => moderator,
        "Admin" => admin,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of "Anonymous", "Blocked", "Member", '
                '"Privileged", "Former Staff", "Janitor", "Moderator", or "Admin".',
          ),
      };
  factory UserLevel.fromInt(int json) => switch (json) {
        == anonymousLevel => anonymous,
        == blockedLevel => blocked,
        == memberLevel => member,
        == privilegedLevel => privileged,
        == formerStaffLevel => formerStaff,
        == janitorLevel => janitor,
        == moderatorLevel => moderator,
        == adminLevel => admin,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of "Anonymous", "Blocked", "Member", '
                '"Privileged", "Former Staff", "Janitor", "Moderator", or "Admin".',
          ),
      };
  static const jsonPropertyName = "level_string";
  bool operator >(UserLevel rhs) => index > rhs.index;
  bool operator <(UserLevel rhs) => index < rhs.index;
  bool operator <=(UserLevel rhs) => index <= rhs.index;
  bool operator >=(UserLevel rhs) => index >= rhs.index;
  // @override
  // bool operator ==(Object rhs) => rhs is UserLevel && rhs.index == index;
}

enum WarningType with ApiQueryParameter {
  warning._(),
  record._(),
  ban._(),
  unmark._(),
  ;

  const WarningType._();
  factory WarningType(String json) => switch (json) {
        "warning" => warning,
        "record" => record,
        "ban" => ban,
        "unmark" => unmark,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"warning" '
                '"record" '
                '"ban" '
                'or "unmark".',
          ),
      };

  @override
  String get query => name;
}

enum Modifier {
  add,
  remove,
  or;

  static const matcher = r"[\-\~]?";

  const Modifier();
  factory Modifier.fromString(String s) => switch (s) {
        "+" || "" => Modifier.add,
        "-" => Modifier.remove,
        "~" => Modifier.or,
        _ => throw UnsupportedError("Not supported: $s"),
      };
  String get symbol => switch (this) {
        Modifier.add => "",
        Modifier.remove => "-",
        Modifier.or => "~",
      };
}

mixin SearchableEnum on Enum {
  String get searchString;
}

mixin SearchableStatefulEnum<T> on Enum {
  String toSearch(T state);
}

enum Rating with SearchableEnum {
  safe,
  questionable,
  explicit;

  static const matcherNonStrictStr = "(${Modifier.matcher})($prefix)([^\\s]+)";
  static RegExp get matcherNonStrictGenerated => RegExp(matcherNonStrictStr);
  static const matcherStr = "(${Modifier.matcher})($prefix)"
      r"(s|q|e|safe|questionable|explicit)(?=\s|$)";
  static RegExp get matcherGenerated => RegExp(matcherStr);
  static const prefix = "rating:";
  @override
  String get searchString => searchStringShort;
  String get searchStringShort => "$prefix${name[0]}";
  String get searchStringLong => "$prefix$name";
  String get suffix => suffixShort;
  String get suffixShort => name[0];
  String get suffixLong => name;
  const Rating();
  factory Rating.fromTagText(String str) => switch (str) {
        "e" || "explicit" => explicit,
        "q" || "questionable" => questionable,
        "s" || "safe" => safe,
        _ => throw UnsupportedError("type not supported: $str"),
      };
  factory Rating.fromText(String str) => switch (str) {
        "${prefix}e" || "${prefix}explicit" => explicit,
        "${prefix}q" || "${prefix}questionable" => questionable,
        "${prefix}s" || "${prefix}safe" => safe,
        _ => Rating.fromTagText(str),
      };

  // @override
  // Rating? _retrieve(String str) => retrieve(str);
  static Rating? retrieve(String str) {
    if (!Rating.matcherGenerated.hasMatch(str)) {
      return null;
    }
    return Rating.fromTagText(matcherGenerated.firstMatch(str)!.group(3)!);
  }

  // @override
  // (Modifier, Rating)? _retrieveWithModifier(String str) =>
  //     retrieveWithModifier(str);
  static (Modifier, Rating)? retrieveWithModifier(String str) {
    if (!Rating.matcherGenerated.hasMatch(str)) {
      return null;
    }
    final ms = Rating.matcherGenerated.allMatches(str);
    final tags = ms.fold(
      <(Modifier, Rating)>{},
      (previousValue, e) => previousValue
        ..add(
          (
            Modifier.fromString(e.group(1) ?? ""),
            Rating.fromTagText(e.group(3)!)
          ),
        ),
    );
    (Modifier, Rating)? r;
    for (final t in tags) {
      if (r == null) {
        r = t;
      } else {
        if (r.$1 == Modifier.add) {
          if (t.$1 == Modifier.remove && t.$2 == r.$2) {
            return null;
          } else if (t.$1 == Modifier.add && t.$2 != r.$2) {
            return null;
          } else if (t.$1 == Modifier.or) {
            continue;
            //return null;
          } /*  else if (t.$1 == Modifier.remove && t.$2 != r.$2) {
            continue;
          } */
        } else if (r.$1 == Modifier.remove) {
          if (t.$1 == Modifier.add && t.$2 == r.$2) {
            return null;
          } else if (t.$1 == Modifier.remove && t.$2 != r.$2) {
            r = (
              Modifier.add,
              switch ((r.$2, t.$2)) {
                (safe, questionable) => explicit,
                (questionable, safe) => explicit,
                (safe, explicit) => questionable,
                (explicit, safe) => questionable,
                (questionable, explicit) => safe,
                (explicit, questionable) => safe,
                (safe, safe) ||
                (questionable, questionable) ||
                (explicit, explicit) =>
                  throw StateError("Should be impossible"),
              }
            );
          } else if (t.$1 == Modifier.or && t.$2 == r.$2) {
            return null;
          }
        } else if (r.$1 == Modifier.or) {
          if (t.$1 == Modifier.add && t.$2 != r.$2) {
            return null;
          } else if (t.$1 == Modifier.or && t.$2 != r.$2) {
            r = (
              Modifier.remove,
              switch ((r.$2, t.$2)) {
                (safe, questionable) => explicit,
                (questionable, safe) => explicit,
                (safe, explicit) => questionable,
                (explicit, safe) => questionable,
                (questionable, explicit) => safe,
                (explicit, questionable) => safe,
                (safe, safe) ||
                (questionable, questionable) ||
                (explicit, explicit) =>
                  throw StateError("Should be impossible"),
              }
            );
          } else if (t.$1 == Modifier.remove && t.$2 != r.$2) {
            r = t;
          } else if (t.$1 == Modifier.remove && t.$2 == r.$2) {
            r = (Modifier.remove, r.$2);
          }
        }
      }
    }
    return r;
  }
}

/// https://e621.net/wiki_pages/11262
enum TagCategory with ApiQueryParameter {
  /// 0
  general,

  /// 1
  artist,

  /// 2; WHY
  _error,

  /// 3
  copyright,

  /// 4
  character,

  /// 5
  species,

  /// 6
  invalid,

  /// 7
  meta,

  /// 8
  lore;

  static const artistColor = Color(0xFFF2AC08);
  static const copyrightColor = Color(0xFFDD00DD);
  static const characterColor = Color(0xFF00AA00);
  static const speciesColor = Color(0xFFED5D1F);
  static const generalColor = Color(0xFFB4C7D9);
  static const loreColor = Color(0xFF228822);
  static const metaColor = Color(0xFFFFFFFF);
  static const invalidColor = Color(0xFFFF3D3D);
  // TODO: Remove from switch, make final member.
  Color get color => switch (this) {
        artist => artistColor,
        copyright => copyrightColor,
        character => characterColor,
        species => speciesColor,
        general => generalColor,
        lore => loreColor,
        meta => metaColor,
        invalid => invalidColor,
        _error => throw UnsupportedError(
            "This value is not valid. Cannot use TagCategory._error."), //Color(0x00000000)
      };
  bool get isTrueCategory => this != _error;
  bool get isValidCategory => this != _error && this != invalid;
  static const String categoryNameRegExpStr =
      "artist|character|copyright|species|general|meta|lore|invalid";
  dynamic toJson() => index.toString();
  factory TagCategory.fromJson(dynamic json, [String? key]) {
    final v = key != null ? json[key] : json;
    return v is! String || int.tryParse(v) != null
        ? switch (v is int ? v : int.tryParse(v as String)) {
            0 => TagCategory.general,
            1 => TagCategory.artist,
            3 => TagCategory.copyright,
            4 => TagCategory.character,
            5 => TagCategory.species,
            6 => TagCategory.invalid,
            7 => TagCategory.meta,
            8 => TagCategory.lore,
            // 2 => TagCategory._error,
            2 => throw UnsupportedError(
                "This value is not valid. Cannot use TagCategory._error."),
            null => TagCategory.fromName(v),
            _ => throw UnsupportedError("type not supported"),
          }
        : TagCategory.fromName(v);
  }
  factory TagCategory.fromName(String name) => switch (name) {
        "general" => TagCategory.general,
        "artist" => TagCategory.artist,
        "copyright" => TagCategory.copyright,
        "character" => TagCategory.character,
        "species" => TagCategory.species,
        "invalid" => TagCategory.invalid,
        "meta" => TagCategory.meta,
        "lore" => TagCategory.lore,
        // "_error" => TagCategory._error,
        "_error" => throw UnsupportedError(
            "This value is not valid. Cannot use TagCategory._error."),
        _ => throw UnsupportedError("type not supported"),
      };

  @override
  String get query => index.toString();
}
