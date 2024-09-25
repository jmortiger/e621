import 'general_enums.dart';

enum SetOrder with ApiQueryParameter {
  name._default("name"),
  shortname._default("shortname"),
  postCount._default("post_count"),
  createdAt._default("created_at"),
  updatedAt._default("updated_at");

  @override
  final String query;

  @override
  String toString() => query;
  @Deprecated("Use query")
  String get jsonString => query;
  const SetOrder._default(this.query);
  factory SetOrder(String json) => switch (json) {
        "name" => name,
        "shortname" => shortname,
        "post_count" => postCount,
        "created_at" => createdAt,
        "updated_at" => updatedAt,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"name", '
                '"shortname", '
                '"post_count", '
                '"created_at", '
                'or "updated_at".',
          ),
      };
}

enum PoolOrder with ApiQueryParameter {
  name._default("name"),
  postCount._default("post_count"),
  createdAt._default("created_at"),
  updatedAt._default("updated_at");

  @override
  final String query;

  @override
  String toString() => query;
  @Deprecated("Use query")
  String get jsonString => query;
  const PoolOrder._default(this.query);
  factory PoolOrder(String json) => switch (json) {
        "name" => name,
        "post_count" => postCount,
        "created_at" => createdAt,
        "updated_at" => updatedAt,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"name", '
                '"post_count", '
                '"created_at", '
                'or "updated_at".',
          ),
      };
}

enum CommentOrder with ApiQueryParameter {
  idAsc._default("id_asc"),
  idDesc._default("id_desc"),
  status._default("status"),
  statusDesc._default("status_desc"),
  updatedAtDesc._default("updated_at_desc");

  @override
  final String query;

  @override
  String toString() => query;
  const CommentOrder._default(this.query);
  factory CommentOrder(String json) => switch (json) {
        "id_asc" => idAsc,
        "id_desc" => idDesc,
        "status" => status,
        "status_desc" => statusDesc,
        "updated_at_desc" => updatedAtDesc,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"id_asc", '
                '"id_desc", '
                '"status", '
                '"status_desc", '
                'or "updated_at_desc".',
          ),
      };
}

enum CommentGrouping with ApiQueryParameter {
  comment._default("comment"),
  post._default("post");

  @override
  final String query;

  @override
  String toString() => query;
  const CommentGrouping._default(this.query);
  factory CommentGrouping(String json) => switch (json) {
        "comment" => comment,
        "post" => post,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"comment" '
                'or "post".',
          ),
      };
}

enum UserOrder with ApiQueryParameter {
  joinDate._default("date"),
  name._default("name"),
  postUploadCount._default("post_upload_count"),
  noteCount._default("note_count"),
  postUpdateCount._default("post_update_count");

  @override
  final String query;

  @override
  String toString() => query;
  @Deprecated("Use query")
  String get jsonString => query;
  const UserOrder._default(this.query);
  factory UserOrder(String json) => switch (json) {
        "name" => name,
        "date" => joinDate,
        "post_upload_count" => postUploadCount,
        "note_count" => noteCount,
        "post_update_count" => postUpdateCount,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"name", '
                '"date", '
                '"post_upload_count", '
                '"post_update_count", '
                'or "note_count".',
          ),
      };
}

enum PopularTimeScale with ApiQueryParameter {
  day,
  week,
  month;

  @override
  String get query => name;
}

enum WikiOrder with ApiQueryParameter {
  title._("title"),
  time._("time"),
  postCount._("post_count");

  const WikiOrder._(this.query);
  @override
  final String query;
  factory WikiOrder(String query) => switch (query) {
        "title" => title,
        "time" => time,
        "post_count" => postCount,
        _ => throw ArgumentError.value(
            query,
            "query",
            'must be a value of "title", "time", or "post_count", ',
          ),
      };
}
