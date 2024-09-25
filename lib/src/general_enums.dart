mixin ApiQueryParameter on Enum {
  String get query;
}

enum PoolCategory with ApiQueryParameter {
  collection,
  series;

  @override
  String get query => name;

  dynamic toJson() => name;
  static PoolCategory fromJson(dynamic json) => _fromJsonString(json);
  static PoolCategory fromJsonNonStrict(dynamic json) =>
      _fromJsonString(json.toString().toLowerCase());

  String toJsonString() => name;
  @Deprecated("Use PoolCategory.fromJson")
  static PoolCategory fromJsonString(String name) => _fromJsonString(name);
  static PoolCategory _fromJsonString(String name) => switch (name) {
        "collection" => collection,
        "series" => series,
        _ => throw UnsupportedError(
            "Value $name not supported, must be `collection` or `series`.",
          ),
      };
  @Deprecated("Use PoolCategory.fromJsonNonStrict")
  static PoolCategory fromJsonStringNonStrict(String name) =>
      _fromJsonString(name.toLowerCase());
  String toParamString() => name;
  static PoolCategory fromParamString(String name) => _fromJsonString(name);
}

enum UserLevel {
  anonymous._default(0, 0, 9),
  blocked._default(10, 10, 11),
  member._default(11, 20, 21),
  privileged._default(21, 30, 31),
  formerStaff._default(31, 34, 35),
  janitor._default(35, 35, 36),
  moderator._default(36, 40, 41),
  admin._default(41, 50, 51);

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
  @override
  String toString() => namePretty;
  String get jsonString => namePretty;
  String get namePretty => "${name[0].toUpperCase()}${name.substring(1)}";
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
  const UserLevel._default(this.min, this.value, this.max);
  // static UserLevel fromJsonString(String json) => switch (json) {
  // factory UserLevel.fromJsonString(String json) => switch (json) {
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
        // int t when t > anonymous.min && t < anonymous.max => anonymous,
        == blockedLevel => blocked,
        // int t when t > blocked.min && t < blocked.max => blocked,
        == memberLevel => member,
        // int t when t > member.min && t < member.max => member,
        == privilegedLevel => privileged,
        // int t when t > privileged.min && t < privileged.max => privileged,
        == formerStaffLevel => formerStaff,
        // int t when t > formerStaff.min && t < formerStaff.max => formerStaff,
        == janitorLevel => janitor,
        // int t when t > janitor.min && t < janitor.max => janitor,
        == moderatorLevel => moderator,
        // int t when t > moderator.min && t < moderator.max => moderator,
        == adminLevel => admin,
        // int t when t > admin.min && t < admin.max => admin,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of "Anonymous", "Blocked", "Member", '
                '"Privileged", "Former Staff", "Janitor", "Moderator", or "Admin".',
          ),
      };
  static const jsonPropertyName = "level_string";
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
        "e" => explicit,
        "explicit" => explicit,
        "q" => questionable,
        "questionable" => questionable,
        "s" => safe,
        "safe" => safe,
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
                (safe, safe) => throw StateError("Should be impossible"),
                (questionable, questionable) =>
                  throw StateError("Should be impossible"),
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
                (safe, safe) => throw StateError("Should be impossible"),
                (questionable, questionable) =>
                  throw StateError("Should be impossible"),
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