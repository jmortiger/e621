import 'package:e621/src/general_enums.dart';

enum PostEventAction with JsonEnum, SearchableEnum {
  deleted._("deleted"),
  undeleted._("undeleted"),
  approved._("approved"),
  unapproved._("unapproved"),
  flagCreated._("flag_created"),
  flagRemoved._("flag_removed"),
  favoritesMoved._("favorites_moved"),
  favoritesReceived._("favorites_received"),
  ratingLocked._("rating_locked"),
  ratingUnlocked._("rating_unlocked"),
  statusLocked._("status_locked"),
  statusUnlocked._("status_unlocked"),
  noteLocked._("note_locked"),
  noteUnlocked._("note_unlocked"),
  commentLocked._("comment_locked"),
  commentUnlocked._("comment_unlocked"),
  replacementAccepted._("replacement_accepted"),
  replacementRejected._("replacement_rejected"),
  replacementPromoted._("replacement_promoted"),
  replacementDeleted._("replacement_deleted"),
  expunged._("expunged"),
  changedBgColor._("changed_bg_color");

  @override
  final String searchString;
  const PostEventAction._(this.searchString);

  /// If [key] is provided, expects [json] to be a `Map<String, dynamic>` with the supplied key.
  /// Otherwise, expects a [String] of either `collection` or `series`.
  factory PostEventAction.fromJson(dynamic json, [String? key]) =>
      switch (key != null ? json[key] : json) {
        "deleted" => deleted,
        "undeleted" => undeleted,
        "approved" => approved,
        "unapproved" => unapproved,
        "flag_created" => flagCreated,
        "flag_removed" => flagRemoved,
        "favorites_moved" => favoritesMoved,
        "favorites_received" => favoritesReceived,
        "rating_locked" => ratingLocked,
        "rating_unlocked" => ratingUnlocked,
        "status_locked" => statusLocked,
        "status_unlocked" => statusUnlocked,
        "note_locked" => noteLocked,
        "note_unlocked" => noteUnlocked,
        "comment_locked" => commentLocked,
        "comment_unlocked" => commentUnlocked,
        "replacement_accepted" => replacementAccepted,
        "replacement_rejected" => replacementRejected,
        "replacement_promoted" => replacementPromoted,
        "replacement_deleted" => replacementDeleted,
        "expunged" => expunged,
        "changed_bg_color" => changedBgColor,
        dynamic v => JsonEnum.fromJsonThrow(
            v, values.map((e) => e.searchString), json, key),
      };
  factory PostEventAction.fromJsonNonStrict(dynamic json, [String? key]) =>
      PostEventAction.fromJson(
          (key != null ? json[key] : json).toString().toLowerCase());
  @override
  String toJson() => searchString;
}


enum AlternateResolution {
  $720p(1280, 720),
  $480p(640, 480),
  original(double.infinity, double.infinity);

  final num maxVerticalResolution;
  final num maxHorizontalResolution;
  const AlternateResolution(
      this.maxHorizontalResolution, this.maxVerticalResolution);
  factory AlternateResolution.fromJson(String json) => switch (json) {
        "720p" => $720p,
        "480p" => $480p,
        "original" => original,
        _ => throw ArgumentError.value(
            json,
            "json",
            "must be "
                "720p, "
                "480p, "
                "or original"),
      };
  @override
  String toString() => switch (this) {
        $720p => "720p",
        $480p => "480p",
        original => "original",
      };
  static const AlternateResolution nhd = $480p;
  static const AlternateResolution sd = $480p;
  static const AlternateResolution vga = $480p;
  static const AlternateResolution hd = $720p;
  static const AlternateResolution hdtv = $720p;
  static const AlternateResolution wxga = $720p;
}

enum PostDataType {
  png,
  jpg,
  gif,
  webm,
  mp4,
  swf;

  bool isResourceOfDataType(String url) =>
      url.endsWith(toString()) ||
      (this == PostDataType.jpg && url.endsWith("jpeg"));
}

enum PostType {
  image,
  video,
  flash,
  ;
}
enum DefaultImageSize {
  large._(),
  fit._(),
  fitv._(),
  original._();

  const DefaultImageSize._();
  factory DefaultImageSize.fromJson(String json) => switch (json) {
        "large" => large,
        "fit" => fit,
        "fitv" => fitv,
        "original" => original,
        _ => throw ArgumentError.value(json, "json", "type not supported"),
      };
  String toJson() => name;
}

enum PostFlag {
  /// int.parse("000001", radix: 2);
  pending(bit: 1),

  /// int.parse("000010", radix: 2);
  flagged(bit: 2),

  /// int.parse("000100", radix: 2);
  noteLocked(bit: 4),

  /// int.parse("001000", radix: 2);
  statusLocked(bit: 8),

  /// int.parse("010000", radix: 2);
  ratingLocked(bit: 16),

  /// int.parse("100000", radix: 2);
  deleted(bit: 32);

  /// int.parse("000001", radix: 2);
  static const int pendingFlag = 1;
  /// int.parse("000010", radix: 2);
  static const int flaggedFlag = 2;

  /// int.parse("000100", radix: 2);
  static const int noteLockedFlag = 4;

  /// int.parse("001000", radix: 2);
  static const int statusLockedFlag = 8;

  /// int.parse("010000", radix: 2);
  static const int ratingLockedFlag = 16;

  /// int.parse("100000", radix: 2);
  static const int deletedFlag = 32;

  final int bit;

  const PostFlag({required this.bit});
  bool hasFlag(int f) => (PostFlag.toInt(this) & f) == PostFlag.toInt(this);
  static List<PostFlag> getFlags(int f) {
    var l = <PostFlag>[];
    if (f & pending.bit == pending.bit) l.add(pending);
    if (f & flagged.bit == flagged.bit) l.add(flagged);
    if (f & noteLocked.bit == noteLocked.bit) l.add(noteLocked);
    if (f & statusLocked.bit == statusLocked.bit) l.add(statusLocked);
    if (f & ratingLocked.bit == ratingLocked.bit) l.add(ratingLocked);
    if (f & deleted.bit == deleted.bit) l.add(deleted);
    return l;
  }

  static int toInt(PostFlag f) => f.bit;
}