import 'dart:convert' as dc;

import 'package:e621/src/model_enums.dart';
import 'package:e621/src/tag_parsing.dart';

import 'general_enums.dart' hide ApiQueryParameter;
import 'model.dart' as model;

Type findUserModelType(Map<String, dynamic> json) =>
    json["wiki_page_version_count"] != null
        ? json["api_burst_limit"] != null
            ? UserLoggedInDetail
            : UserDetailed
        : json["api_burst_limit"] != null
            ? UserLoggedIn
            : User;

/// Gets the most specific user model based on the provided [json].
User userFromJson(Map<String, dynamic> json) =>
    json["wiki_page_version_count"] != null
        ? json["api_burst_limit"] != null
            ? UserLoggedInDetail.fromJson(json)
            : UserDetailed.fromJson(json)
        : json["api_burst_limit"] != null
            ? UserLoggedIn.fromJson(json)
            : User.fromJson(json);

class Alternate with model.BaseModel {
  /// `0`. the webm version (almost always null on original)
  ///
  /// `1`. the mp4 version
  final List<String?> urls;
  /* String? get urlWebm => urls[0];
  String? get urlMp4 => urls[1];
  String? get url => urls[0] ?? urls[1]; */
  final int width;
  final int height;
  final String type;

  const Alternate({
    required this.height,
    required this.type,
    required this.urls,
    required this.width,
  });

  /// {@macro Preview.fromJson.NullUrlFix}
  ///
  Alternate.fromJson(
    Map<String, dynamic> json, {
    bool deleted = false,
    String? deletedUrlReplacement,
    String? otherUrlReplacement,
  })  : height = json["height"],
        type = json["type"],
        urls = List.from((json["urls"]).map((x) =>
            (x as String?) ?? (deleted ? deletedUrlReplacement : otherUrlReplacement))),
        width = json["width"];

  @override
  Map<String, dynamic> toJson() => {
        "height": height,
        "type": type,
        "urls": urls,
        "width": width,
      };
}

class AlternateNonNull extends Alternate {
  @override
  List<String> get urls => super.urls.cast<String>();
  const AlternateNonNull({
    required super.height,
    required super.type,
    required List<String> super.urls,
    required super.width,
  });
  AlternateNonNull.fromJson(
    super.json, {
    super.deleted = false,
    String super.deletedUrlReplacement = "",
    String super.otherUrlReplacement = "",
  }) : super.fromJson();
}

class Alternates with model.BaseModel {
  Alternate? get $480p => alternates["480p"];
  Alternate? get $720p => alternates["720p"];
  Alternate? get original => alternates["original"];
  final Map<String, Alternate> alternates;

  const Alternates({required this.alternates});

  Alternates.fromJson(
    Map<String, dynamic> json, {
    bool deleted = false,
    String? deletedUrlReplacement,
    String? otherUrlReplacement,
  }) : alternates = {
          for (var e in json.entries)
            e.key: Alternate.fromJson(
              e.value,
              deleted: deleted,
              deletedUrlReplacement: deletedUrlReplacement,
              otherUrlReplacement: otherUrlReplacement,
            )
        };

  @override
  Map<String, dynamic> toJson() => alternates;
}

class AlternatesNonNull with model.BaseModel implements Alternates {
  @override
  AlternateNonNull? get $480p => alternates["480p"];
  @override
  AlternateNonNull? get $720p => alternates["720p"];
  @override
  AlternateNonNull? get original => alternates["original"];
  @override
  final Map<String, AlternateNonNull> alternates;

  const AlternatesNonNull({required this.alternates});

  AlternatesNonNull.fromJson(
    Map<String, dynamic> json, {
    bool deleted = false,
    String deletedUrlReplacement = "",
    String otherUrlReplacement = "",
  }) : alternates = {
          for (var e in json.entries)
            e.key: AlternateNonNull.fromJson(
              e.value,
              deleted: deleted,
              deletedUrlReplacement: deletedUrlReplacement,
              otherUrlReplacement: otherUrlReplacement,
            )
        };

  @override
  Map<String, dynamic> toJson() => alternates;
}

class Artist extends _PNameIdDatesIsActiveBase with model.BaseModel {
  final List<String> otherNames;
  final List<ArtistUrl> urls;
  final List<ArtistDomain> domains;
  final String groupName;
  final String? notes;
  final int? linkedUserId;
  final int creatorId;
  final bool isLocked;

  const Artist({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    required this.otherNames,
    required this.urls,
    required this.domains,
    required this.groupName,
    required this.notes,
    required this.linkedUserId,
    required this.creatorId,
    required this.isLocked,
  });

  Artist.fromJson(super.json)
      : otherNames = (json["other_names"] as List).cast<String>(),
        urls =
            (json["urls"] as List).map((e) => ArtistUrl.fromJson(e)).toList(),
        domains = (json["domains"] as List)
            .map((e) => ArtistDomain.fromJson(e))
            .toList(),
        groupName = json["group_name"],
        notes = json["notes"],
        linkedUserId = json["linked_user_id"],
        creatorId = json["creator_id"],
        isLocked = json["is_locked"],
        super.fromJson();
  factory Artist.fromRawJson(String json) =>
      Artist.fromJson(dc.jsonDecode(json));

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "other_names": otherNames,
      "urls": urls,
      "domains": domains,
      "group_name": groupName,
      "notes": notes,
      "linked_user_id": linkedUserId,
      "creator_id": creatorId,
      "is_locked": isLocked,
    });
}

class ArtistDomain /*  with model.BaseModel */ {
  final String domain;
  final int timesUsedInPostSources;

  const ArtistDomain({
    required this.domain,
    required this.timesUsedInPostSources,
  });

  // factory ArtistDomain.fromRawJson(String json) =>
  //     ArtistDomain.fromJson(dc.jsonDecode(json));
  ArtistDomain.fromJson(List json)
      : domain = json[0],
        timesUsedInPostSources = json[1];

  // @override
  List toJson() => [domain, timesUsedInPostSources];
}

class ArtistUrl extends _PNameIdDatesIsActiveBase with model.BaseModel {
  final Uri url;
  final Uri normalizedUrl;

  const ArtistUrl({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    required this.url,
    required this.normalizedUrl,
    required super.isActive,
  });

  ArtistUrl.fromJson(super.json)
      : url = Uri.parse(json["url"]),
        normalizedUrl = Uri.parse(json["normalized_url"]),
        super.fromJson();
  factory ArtistUrl.fromRawJson(String json) =>
      ArtistUrl.fromJson(dc.jsonDecode(json));

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "url": url.toString(),
      "normalized_url": normalizedUrl.toString(),
    });
}

class ArtistVersion extends _PNameIdDatesIsActiveBase with model.BaseModel {
  final List<String> otherNames;
  final List<String> urls;
  // final String groupName;
  // final int linkedUserId;
  // final int creatorId;
  final int artistId;
  final int updaterId;
  // final bool isLocked;
  final bool notesChanged;

  const ArtistVersion({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    required this.otherNames,
    required this.urls,
    // required this.groupName,
    // required this.linkedUserId,
    // required this.creatorId,
    required this.artistId,
    required this.updaterId,
    // required this.isLocked,
    required this.notesChanged,
  });

  ArtistVersion.fromJson(super.json)
      : otherNames = (json["other_names"] as List).cast<String>(),
        urls = (json["urls"] as List).cast<String>(),
        // groupName = json["group_name"],
        // linkedUserId = json["linked_user_id"],
        // creatorId = json["creator_id"],
        artistId = json["artist_id"],
        updaterId = json["updater_id"],
        // isLocked = json["is_locked"],
        notesChanged = json["notes_changed"],
        super.fromJson();
  factory ArtistVersion.fromRawJson(String json) =>
      ArtistVersion.fromJson(dc.jsonDecode(json));

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "other_names": otherNames,
      "urls": urls,
      // "group_name": groupName,
      // "linked_user_id": linkedUserId,
      // "creator_id": creatorId,
      "artist_id": artistId,
      "updater_id": updaterId,
      // "is_locked": isLocked,
      "notes_changed": notesChanged,
    });
}

class Comment extends _PIdDatesBase {
  /// post_id
  final int postId;

  /// creator_id
  final int creatorId;

  /// body
  final String body;

  /// score
  final int score;

  /// updater_id
  final int updaterId;

  /// do_not_bump_post
  final bool? /* deprecated */ doNotBumpPost;

  /// is_hidden
  final bool isHidden;

  /// is_sticky
  final bool isSticky;

  /// warning_type
  ///
  /// MUST NOT BE [WarningType.unmark]
  final WarningType? warningType;

  /// warning_user_id
  final int? warningUserId;

  /// creator_name
  final String creatorName;

  /// updater_name
  final String updaterName;

  const Comment({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.postId,
    required this.creatorId,
    required this.body,
    required this.score,
    required this.updaterId,
    required this.doNotBumpPost,
    required this.isHidden,
    required this.isSticky,
    required this.warningType,
    required this.warningUserId,
    required this.creatorName,
    required this.updaterName,
  });

  Comment.fromJson(super.json)
      : postId = json["post_id"],
        creatorId = json["creator_id"],
        body = json["body"],
        score = json["score"],
        updaterId = json["updater_id"],
        doNotBumpPost = json["do_not_bump_post"],
        isHidden = json["is_hidden"],
        isSticky = json["is_sticky"],
        warningType = json["warning_type"] != null
            ? WarningType(json["warning_type"])
            : null,
        warningUserId = json["warning_user_id"],
        creatorName = json["creator_name"],
        updaterName = json["updater_name"],
        super.fromJson();
  factory Comment.fromRawJson(String json) {
    final r = dc.jsonDecode(json);
    return Comment.fromJson(r is List ? r.first : r);
  }
  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "post_id": postId,
      "creator_id": creatorId,
      "body": body,
      "score": score,
      "updater_id": updaterId,
      "do_not_bump_post": doNotBumpPost,
      "is_hidden": isHidden,
      "is_sticky": isSticky,
      "warning_type": warningType?.query,
      "warning_user_id": warningUserId,
      "creator_name": creatorName,
      "updater_name": updaterName,
    });

  static Iterable<Comment> fromRawJsonResults(String json) {
    final r = dc.jsonDecode(json);
    return r is List
        ? r.map((e) => Comment.fromJson(e))
        : r["comments"] == null
            ? [Comment.fromJson(r)]
            : (r["comments"] as List).map((e) => Comment.fromJson(e));
  }
}

mixin CurrentUser on UserMixin {
  int get apiBurstLimit;
  int get apiRegenMultiplier;
  String get blacklistedTags;
  bool get blacklistUsers;
  int get commentThreshold;
  String get customStyle;
  DefaultImageSize get defaultImageSize;
  bool get descriptionCollapsedInitially;
  bool get disableCroppedThumbnails;
  bool get disableResponsiveMode;
  bool get disableUserDmails;
  String get email;
  bool get enableAutoComplete;
  bool get enableCompactUploader;
  bool get enableKeyboardNavigation;
  bool get enablePrivacyMode;
  bool get enableSafeMode;
  int get favoriteCount;
  int get favoriteLimit;
  String get favoriteTags;
  bool get hasMail;
  bool get hideComments;
  DateTime get lastForumReadAt;
  DateTime get lastLoggedInAt;
  bool get noFlagging;

  int get perPage;
  bool get receiveEmailNotifications;
  String get recentTags;
  int get remainingApiLimit;
  bool get replacementsBeta;
  bool get showHiddenComments;
  bool get showPostStatistics;
  int get statementTimeout;
  bool get styleUsernames;
  int get tagQueryLimit;

  /// https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  String get timeZone;
  DateTime get updatedAt;
}

/// TODO: Pull out fields that match w/ Post
///
class DTextPost with model.BaseModel {
  /// id
  final int id;

  /// flags
  final String flags;

  /// tags
  final String tags;

  /// rating
  final Rating rating;

  /// file_ext
  final String fileExt;

  /// width
  final int width;

  /// height
  final int height;

  /// size
  final int size;

  /// created_at
  final DateTime createdAt;

  /// uploader
  final String uploader;

  /// uploader_id
  final int uploaderId;

  /// score
  final int score;

  /// fav_count
  final int favCount;

  /// is_favorited
  final bool isFavorited;

  /// pools
  final List<int> pools;

  /// md5
  final String md5;

  /// preview_url
  final String? previewUrl;

  /// large_url
  final String? largeUrl;

  /// file_url
  final String? fileUrl;

  /// preview_width
  final int previewWidth;

  /// preview_height
  final int previewHeight;

  const DTextPost({
    required this.id,
    required this.flags,
    required this.tags,
    required this.rating,
    required this.fileExt,
    required this.width,
    required this.height,
    required this.size,
    required this.createdAt,
    required this.uploader,
    required this.uploaderId,
    required this.score,
    required this.favCount,
    required this.isFavorited,
    required this.pools,
    required this.md5,
    required this.previewUrl,
    required this.largeUrl,
    required this.fileUrl,
    required this.previewWidth,
    required this.previewHeight,
  });

  DTextPost.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        flags = json["flags"],
        tags = json["tags"],
        rating = Rating.fromTagText(json["rating"]),
        fileExt = json["file_ext"],
        width = json["width"],
        height = json["height"],
        size = json["size"],
        createdAt = DateTime.parse(json["created_at"]),
        uploader = json["uploader"],
        uploaderId = json["uploader_id"],
        score = json["score"],
        favCount = json["fav_count"],
        isFavorited = json["is_favorited"],
        pools = (json["pools"] as List).cast<int>(),
        md5 = json["md5"],
        previewUrl = json["preview_url"],
        largeUrl = json["large_url"],
        fileUrl = json["file_url"],
        previewWidth = json["preview_width"],
        previewHeight = json["preview_height"];
  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "flags": flags,
        "tags": tags,
        "rating": rating.suffixShort,
        "file_ext": fileExt,
        "width": width,
        "height": height,
        "size": size,
        "created_at": createdAt,
        "uploader": uploader,
        "uploader_id": uploaderId,
        "score": score,
        "fav_count": favCount,
        "is_favorited": isFavorited,
        "pools": pools,
        "md5": md5,
        "preview_url": previewUrl,
        "large_url": largeUrl,
        "file_url": fileUrl,
        "preview_width": previewWidth,
        "preview_height": previewHeight,
      };
}

class DTextResponse with model.BaseModel {
  final String html;
  final Map<int, DTextPost> posts;

  const DTextResponse({required this.html, required this.posts});

  DTextResponse.fromJson(Map<String, dynamic> json)
      : html = json["html"],
        posts = (json["posts"] as Map)
            .map((k, v) => MapEntry(k, DTextPost.fromJson(v)));
  @override
  Map<String, dynamic> toJson() => {"html": html, "posts": posts};
}

class File extends Preview {
  /// The file’s extension.
  final String ext;

  /// The size of the file in bytes.
  final int size;

  /// The md5 of the file.
  final String md5;

  const File({
    required super.width,
    required super.height,
    required this.ext,
    required this.size,
    required this.md5,
    required super.url,
  });

  /// {@macro Preview.fromJson.NullUrlFix}
  File.fromJson(
    super.json, {
    super.deleted = false,
    super.deletedUrlReplacement,
    super.otherUrlReplacement,
  })  : ext = json["ext"] as String,
        size = json["size"] as int,
        md5 = json["md5"] as String,
        super.fromJson();
  @override
  File copyWith({
    String? ext,
    int? size,
    String? md5,
    String? url = "",
    int? width,
    int? height,
  }) =>
      File(
        ext: ext ?? this.ext,
        size: size ?? this.size,
        md5: md5 ?? this.md5,
        height: height ?? this.height,
        url: (url ?? "s").isNotEmpty ? url : this.url,
        width: width ?? this.width,
      );
}
class FileNonNull extends File {
  @override
  String get url => super.url!;

  const FileNonNull({
    required super.width,
    required super.height,
    required super.ext,
    required super.size,
    required super.md5,
    required String super.url,
  });

  /// {@macro Preview.fromJson.NullUrlFix}
  FileNonNull.fromJson(
    super.json, {
    super.deleted = false,
    String super.deletedUrlReplacement = "",
    String super.otherUrlReplacement = "",
  })  : super.fromJson();
  @override
  FileNonNull copyWith({
    String? ext,
    int? size,
    String? md5,
    String? url,
    int? width,
    int? height,
  }) =>
      FileNonNull(
        ext: ext ?? this.ext,
        size: size ?? this.size,
        md5: md5 ?? this.md5,
        height: height ?? this.height,
        url: url ?? this.url,
        width: width ?? this.width,
      );
}

class ModifiablePostSets with model.BaseModel {
  final List<({String name, int id})> owned;
  final List<({String name, int id})> maintained;
  const ModifiablePostSets({required this.owned, required this.maintained});

  ModifiablePostSets.fromJson(Map<String, dynamic> json)
      : maintained = (json["Maintained"] as List)
            .map<({String name, int id})>(
                (e) => (name: (e as List).first, id: e.last))
            .toList(),
        owned = (json["Owned"] as List)
            .map<({String name, int id})>(
                (e) => (name: (e as List).first, id: e.last))
            .toList();

  factory ModifiablePostSets.fromRawJson(String json) =>
      ModifiablePostSets.fromJson(dc.jsonDecode(json));
  List<({String name, int id})> get all => owned + maintained;
  @override
  Map<String, dynamic> toJson() => {
        "maintained": maintained.map(elementToJson),
        "owned": owned.map(elementToJson),
      };
  static List elementToJson(({String name, int id}) e) => [e.name, e.id];
}

class Note extends _PIdDatesBase {
  final int creatorId;
  final int x;
  final int y;
  final int width;
  final int height;
  final int version;
  final bool isActive;
  final int postId;
  final String body;
  final String creatorName;

  const Note({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.creatorId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.version,
    required this.isActive,
    required this.postId,
    required this.body,
    required this.creatorName,
  });

  Note.fromJson(super.json)
      : creatorId = json["creator_id"],
        x = json["x"],
        y = json["y"],
        width = json["width"],
        height = json["height"],
        version = json["version"],
        isActive = json["is_active"],
        postId = json["post_id"],
        body = json["body"],
        creatorName = json["creator_name"],
        super.fromJson();

  Note.fromRawJson(String str) : this.fromJson(dc.json.decode(str));

  Note copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? creatorId,
    int? x,
    int? y,
    int? width,
    int? height,
    int? version,
    bool? isActive,
    int? postId,
    String? body,
    String? creatorName,
  }) =>
      Note(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        creatorId: creatorId ?? this.creatorId,
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        postId: postId ?? this.postId,
        body: body ?? this.body,
        creatorName: creatorName ?? this.creatorName,
      );

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "creator_id": creatorId,
      "x": x,
      "y": y,
      "width": width,
      "height": height,
      "version": version,
      "is_active": isActive,
      "post_id": postId,
      "body": body,
      "creator_name": creatorName,
    });

  /// Safely handles the special value when a search yields no results.
  static Note? fromJsonSafe(Map<String, dynamic> json) =>
      json["notes"]?.runtimeType == List ? null : Note.fromJson(json);
}

class Pool extends model.Pool with model.PostCollection<Pool> {
  /// The ID of the pool.
  @override
  final int id;

  /// The name of the pool.
  @override
  final String name;

  /// The time the pool was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  @override
  final DateTime createdAt;

  /// The time the pool was updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  @override
  final DateTime updatedAt;

  /// The ID of the user that created the pool.
  @override
  final int creatorId;

  /// The description of the pool.
  @override
  final String description;

  /// If the pool is active and still getting posts added. (True/False)
  @override
  final bool isActive;

  /// Can be “series” or “collection”.
  @override
  final PoolCategory category;

  /// An array group of posts in the pool.
  @override
  final List<int> postIds;

  /// The name of the user that created the pool.
  @override
  final String creatorName;

  /// The amount of posts in the pool.
  @override
  final int postCount;

  const Pool({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.description,
    required this.isActive,
    required this.category,
    required this.postIds,
    required this.creatorName,
    required this.postCount,
  });

  Pool.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        createdAt = DateTime.parse(json["created_at"]),
        updatedAt = DateTime.parse(json["updated_at"]),
        creatorId = json["creator_id"],
        description = json["description"],
        isActive = json["is_active"],
        category = PoolCategory.fromJson(json["category"]),
        postIds = (json["post_ids"] as List).cast<int>(),
        creatorName = json["creator_name"],
        postCount = json["post_count"];

  factory Pool.fromRawJson(String str) {
    final f = dc.json.decode(str);
    return Pool.fromJson(f is List ? f.first : f);
  }
  String get searchById => 'pool:$id';

  /// Some names contain characters that are not valid in a search. These can't
  /// be searched through their names.
  ///
  /// See [disallowedInTagName] & [disallowedAsFirstCharacterInTagName].
  String? get searchByName => name.contains(disallowedInTagName) ||
          name.startsWith(disallowedAsFirstCharacterInTagName)
      ? null
      : 'pool:$name';

  @override
  Pool copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? creatorId,
    String? description,
    bool? isActive,
    PoolCategory? category,
    List<int>? postIds,
    String? creatorName,
    int? postCount,
  }) =>
      Pool(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        creatorId: creatorId ?? this.creatorId,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        category: category ?? this.category,
        postIds: postIds ?? this.postIds,
        creatorName: creatorName ?? this.creatorName,
        postCount: postCount ?? this.postCount,
      );

  static Iterable<Pool> fromRawJsonResults(String str) {
    final f = dc.json.decode(str);
    return f is List ? f.map((e) => Pool.fromJson(e)) : [Pool.fromJson(f)];
  }
}

class Post extends _PIdDatesBase {
  // #region Json Fields
  /// (array group)
  final File file;

  /// (array group)
  final Preview preview;

  /// (array group)
  final Sample sample;

  /// (array group)
  final Score score;

  /// (array group)
  final PostTags tags;

  /// A JSON array of tags that are locked on the post.
  final List<String> lockedTags;

  /// An ID that increases for every post alteration on E6 (explained below)
  final int changeSeq;

  /// (array group)
  final PostFlags flags;

  /// The post’s rating. Either s, q or e.
  final String rating;

  /// How many people have favorited the post.
  final int favCount;

  /// The source field of the post.
  final List<String> sources;

  /// An array of Pool IDs that the post is a part of.
  final List<int> pools;

  /// (array group)
  final PostRelationships relationships;

  /// The ID of the user that approved the post, if available.
  final int? approverId;

  /// The ID of the user that uploaded the post.
  final int uploaderId;

  /// The post’s description.
  final String description;

  /// The count of comments on the post.
  final int commentCount;

  /// If provided auth credentials, will return if the authenticated user has
  /// favorited the post or not. If not provided, will be false.
  final bool isFavorited;

  // #region Not Documented
  /// Guess
  final bool hasNotes;

  /// If post is a video, the video length. Otherwise, null.
  final num? duration;
  // #endregion Not Documented
  // #endregion Json Fields

  const Post({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.file,
    required this.preview,
    required this.sample,
    required this.score,
    required this.tags,
    required this.lockedTags,
    required this.changeSeq,
    required this.flags,
    required this.rating,
    required this.favCount,
    required this.sources,
    required this.pools,
    required this.relationships,
    required this.approverId,
    required this.uploaderId,
    required this.description,
    required this.commentCount,
    required this.isFavorited,
    required this.hasNotes,
    required this.duration,
  });

  /// {@macro Preview.fromJson.NullUrlFix}
  Post.fromJson(
    super.json, {
    String? deletedUrlReplacement,
    String? otherUrlReplacement,
  })  : file = File.fromJson(
          json["file"],
          deleted: (json["flags"]["deleted"] as bool),
          deletedUrlReplacement: deletedUrlReplacement,
          otherUrlReplacement: otherUrlReplacement,
        ),
        preview = Preview.fromJson(
          json["preview"],
          deleted: (json["flags"]["deleted"] as bool),
          deletedUrlReplacement: deletedUrlReplacement,
          otherUrlReplacement: otherUrlReplacement,
        ),
        sample = Sample.fromJson(
          json["sample"],
          deleted: (json["flags"]["deleted"] as bool),
          deletedUrlReplacement: deletedUrlReplacement,
          otherUrlReplacement: otherUrlReplacement,
        ),
        score = Score.fromJson(json["score"]),
        tags = PostTags.fromJson(json["tags"]),
        lockedTags = (json["locked_tags"] as List).cast<String>(),
        changeSeq = json["change_seq"] as int,
        flags = PostBitFlags.fromJson(json["flags"]),
        rating = json["rating"] as String,
        favCount = json["fav_count"] as int,
        sources = (json["sources"] as List).cast<String>(),
        pools = (json["pools"] as List).cast<int>(),
        relationships = PostRelationships.fromJson(json["relationships"]),
        approverId = json["approver_id"] as int?,
        uploaderId = json["uploader_id"] as int,
        description = json["description"] as String,
        commentCount = json["comment_count"] as int,
        isFavorited = json["is_favorited"] as bool,
        hasNotes = json["has_notes"] as bool,
        duration = json["duration"] as num?,
        super.fromJson();
  factory Post.fromRawJson(String json) {
    var t = dc.jsonDecode(json);
    try {
      return Post.fromJson(t);
    } catch (_) {
      try {
        return Post.fromJson(t["post"]);
      } catch (_) {
        return Post.fromJson(t["posts"]);
      }
    }
  }

  Post copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    File? file,
    Preview? preview,
    Sample? sample,
    Score? score,
    PostTags? tags,
    List<String>? lockedTags,
    int? changeSeq,
    PostFlags? flags,
    String? rating,
    int? favCount,
    List<String>? sources,
    List<int>? pools,
    PostRelationships? relationships,
    int? approverId = -1,
    int? uploaderId,
    String? description,
    int? commentCount,
    bool? isFavorited,
    bool? hasNotes,
    num? duration = -1,
  }) =>
      Post(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        file: file ?? this.file,
        preview: preview ?? this.preview,
        sample: sample ?? this.sample,
        score: score ?? this.score,
        tags: tags ?? this.tags,
        lockedTags: lockedTags ?? this.lockedTags,
        changeSeq: changeSeq ?? this.changeSeq,
        flags: flags ?? this.flags,
        rating: rating ?? this.rating,
        favCount: favCount ?? this.favCount,
        sources: sources ?? this.sources,
        pools: pools ?? this.pools,
        relationships: relationships ?? this.relationships,
        approverId: (approverId ?? 1) < 0 ? approverId : this.approverId,
        uploaderId: uploaderId ?? this.uploaderId,
        description: description ?? this.description,
        commentCount: commentCount ?? this.commentCount,
        isFavorited: isFavorited ?? this.isFavorited,
        hasNotes: hasNotes ?? this.hasNotes,
        duration: (duration ?? 1) < 0 ? duration : this.duration,
      );
  static Iterable<Post> fromRawJsonResults(String json) {
    var t = dc.jsonDecode(json);
    return t["posts"] != null
        ? (t["posts"] as Iterable).map((e) => Post.fromJson(e))
        : t is Iterable
            ? t.map((e) => Post.fromJson(e))
            : t["post"] != null
                ? [Post.fromJson(t["post"])]
                : [Post.fromJson(t)];
  }
}

class PostBitFlags with model.BaseModel implements PostFlags {
  static const int pendingFlag = 1; //int.parse("000001", radix: 2);

  static const int flaggedFlag = 2; //int.parse("000010", radix: 2);

  static const int noteLockedFlag = 4; //int.parse("000100", radix: 2);

  static const int statusLockedFlag = 8; //int.parse("001000", radix: 2);

  static const int ratingLockedFlag = 16; //int.parse("010000", radix: 2);

  static const int deletedFlag = 32; //int.parse("100000", radix: 2);
  final int _data;
  PostBitFlags({
    required bool pending,
    required bool flagged,
    required bool noteLocked,
    required bool statusLocked,
    required bool ratingLocked,
    required bool deleted,
  }) : _data = (pending ? pendingFlag : 0) +
            (flagged ? flaggedFlag : 0) +
            (noteLocked ? noteLockedFlag : 0) +
            (statusLocked ? statusLockedFlag : 0) +
            (ratingLocked ? ratingLockedFlag : 0) +
            (deleted ? deletedFlag : 0);
  PostBitFlags.fromJson(Map<String, dynamic> json)
      : this(
          pending: json["pending"] as bool,
          flagged: json["flagged"] as bool,
          noteLocked: json["note_locked"] as bool,
          statusLocked: json["status_locked"] as bool,
          ratingLocked: json["rating_locked"] as bool,
          deleted: json["deleted"] as bool,
        );
  @override
  bool get deleted => (_data & deletedFlag) == deletedFlag;

  @override
  bool get flagged => (_data & flaggedFlag) == flaggedFlag;
  @override
  bool get noteLocked => (_data & noteLockedFlag) == noteLockedFlag;
  @override
  bool get pending => (_data & pendingFlag) == pendingFlag;
  @override
  bool get ratingLocked => (_data & ratingLockedFlag) == ratingLockedFlag;
  @override
  bool get statusLocked => (_data & statusLockedFlag) == statusLockedFlag;
  static int getValue({
    bool pending = false,
    bool flagged = false,
    bool noteLocked = false,
    bool statusLocked = false,
    bool ratingLocked = false,
    bool deleted = false,
  }) =>
      (pending ? pendingFlag : 0) +
      (flagged ? flaggedFlag : 0) +
      (noteLocked ? noteLockedFlag : 0) +
      (statusLocked ? statusLockedFlag : 0) +
      (ratingLocked ? ratingLockedFlag : 0) +
      (deleted ? deletedFlag : 0);

  @override
  Map<String, dynamic> toJson() => {
        "pending": pending,
        "flagged": flagged,
        "note_locked": noteLocked,
        "status_locked": statusLocked,
        "rating_locked": ratingLocked,
        "deleted": deleted,
      };
}

class PostEvent with model.BaseModel {
  final int id;
  final int creatorId;
  final int postId;
  final PostEventAction action;
  final DateTime createdAt;

  const PostEvent({
    required this.id,
    required this.creatorId,
    required this.postId,
    required this.action,
    required this.createdAt,
  });
  PostEvent.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        creatorId = json["creator_id"],
        postId = json["post_id"],
        action = PostEventAction.fromJson(json["action"]),
        createdAt = DateTime.parse(json["created_at"]);

  factory PostEvent.fromRawJson(String json) =>
      PostEvent.fromJson(dc.jsonDecode(json));

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "creator_id": creatorId,
        "post_id": postId,
        "action": action.toJson(),
        "created_at": createdAt.toIso8601String(),
      };
}

class PostFlags with model.BaseModel {
  /// If the post is pending approval. (True/False)
  final bool pending;

  /// If the post is flagged for deletion. (True/False)
  final bool flagged;

  /// If the post has it’s notes locked. (True/False)
  final bool noteLocked;

  /// If the post’s status has been locked. (True/False)
  final bool statusLocked;

  /// If the post’s rating has been locked. (True/False)
  final bool ratingLocked;

  /// If the post has been deleted. (True/False)
  final bool deleted;

  const PostFlags({
    required this.pending,
    required this.flagged,
    required this.noteLocked,
    required this.statusLocked,
    required this.ratingLocked,
    required this.deleted,
  });
  PostFlags.fromJson(Map<String, dynamic> json)
      : pending = json["pending"] as bool,
        flagged = json["flagged"] as bool,
        noteLocked = json["note_locked"] as bool,
        statusLocked = json["status_locked"] as bool,
        ratingLocked = json["rating_locked"] as bool,
        deleted = json["deleted"] as bool;
  @override
  Map<String, dynamic> toJson() => {
        "pending": pending,
        "flagged": flagged,
        "note_locked": noteLocked,
        "status_locked": statusLocked,
        "rating_locked": ratingLocked,
        "deleted": deleted,
      };
}

class PostRelationships with model.BaseModel {
  /// The ID of the post’s parent, if it has one.
  final int? parentId;

  /// If the post has child posts (True/False)
  final bool hasChildren;

  /// If the post has active child posts (True/False)
  ///
  /// J's Note: I assume "active" means not deleted
  final bool hasActiveChildren;

  /// A list of child post IDs that are linked to the post, if it has any.
  final List<int> children;

  const PostRelationships({
    required this.parentId,
    required this.hasChildren,
    required this.hasActiveChildren,
    required this.children,
  });

  PostRelationships.fromJson(Map<String, dynamic> json)
      : this(
          parentId: json["parent_id"] as int?,
          hasChildren: json["has_children"] as bool,
          hasActiveChildren: json["has_active_children"] as bool,
          children: (json["children"] as List).cast<int>(),
        );
  bool get hasParent => parentId != null;
  @override
  Map<String, dynamic> toJson() => {
        "parent_id": parentId,
        "has_children": hasChildren,
        "has_active_children": hasActiveChildren,
        "children": children,
      };
}

/// https://e621.net/post_sets.json?35356
///
class PostSet with model.BaseModel, model.PostCollection<PostSet> {
  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int creatorId;
  final bool isPublic;
  @override
  final String name;
  final String shortname;
  final String description;
  @override
  final int postCount;
  final bool transferOnDelete;
  @override
  final List<int> postIds;

  const PostSet({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.isPublic,
    required this.name,
    required this.shortname,
    required this.description,
    required this.postCount,
    required this.transferOnDelete,
    required this.postIds,
  });
  PostSet.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        createdAt = DateTime.parse(json["created_at"]),
        updatedAt = DateTime.parse(json["updated_at"]),
        creatorId = json["creator_id"],
        isPublic = json["is_public"],
        name = json["name"],
        shortname = json["shortname"],
        description = json["description"],
        postCount = json["post_count"],
        transferOnDelete = json["transfer_on_delete"],
        postIds = (json["post_ids"] as List).cast();

  factory PostSet.fromRawJson(String str) {
    final t = dc.json.decode(str);
    return PostSet.fromJson(t is List ? t.first : t);
  }

  String get searchById => 'set:$id';

  String get searchByShortname => 'set:$shortname';
  @override
  PostSet copyWith({
    DateTime? createdAt,
    int? creatorId,
    String? description,
    int? id,
    bool? isPublic,
    String? name,
    int? postCount,
    List<int>? postIds,
    String? shortname,
    bool? transferOnDelete,
    DateTime? updatedAt,
  }) =>
      PostSet(
        createdAt: createdAt ?? this.createdAt,
        creatorId: creatorId ?? this.creatorId,
        description: description ?? this.description,
        id: id ?? this.id,
        isPublic: isPublic ?? this.isPublic,
        name: name ?? this.name,
        postCount: postCount ?? this.postCount,
        postIds: postIds ?? this.postIds,
        shortname: shortname ?? this.shortname,
        transferOnDelete: transferOnDelete ?? this.transferOnDelete,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "creator_id": creatorId,
        "is_public": isPublic,
        "name": name,
        "shortname": shortname,
        "description": description,
        "post_count": postCount,
        "transfer_on_delete": transferOnDelete,
        "post_ids": postIds,
      };

  static Iterable<PostSet> fromJsonResults(dynamic json) => json is List
      ? json.map((e) => PostSet.fromJson(e))
      : json["post_sets"] != null
          ? json["post_sets"]!.map((e) => PostSet.fromJson(e))
          : json["id"] != null
              ? [PostSet.fromJson(json)]
              : [];
  static Iterable<PostSet> fromRawJsonResults(String str) =>
      fromJsonResults(dc.json.decode(str));
}

class PostTags with model.BaseModel {
  /// A JSON array of all the general tags on the post.
  final List<String> general;

  /// A JSON array of all the species tags on the post.
  final List<String> species;

  /// A JSON array of all the character tags on the post.
  final List<String> character;

  /// A JSON array of all the artist tags on the post.
  final List<String> artist;

  /// A JSON array of all the invalid tags on the post.
  final List<String> invalid;

  /// A JSON array of all the lore tags on the post.
  final List<String> lore;

  /// A JSON array of all the meta tags on the post.
  final List<String> meta;

  /// A JSON array of all the copyright tags on the post. ?undocumented?
  final List<String> copyright;
  const PostTags({
    required this.general,
    required this.species,
    required this.character,
    required this.artist,
    required this.invalid,
    required this.lore,
    required this.meta,
    required this.copyright,
  });
  PostTags.fromJson(Map<String, dynamic> json)
      : this(
          general: (json["general"] as List).cast<String>(),
          species: (json["species"] as List).cast<String>(),
          character: (json["character"] as List).cast<String>(),
          artist: (json["artist"] as List).cast<String>(),
          invalid: (json["invalid"] as List).cast<String>(),
          lore: (json["lore"] as List).cast<String>(),
          meta: (json["meta"] as List).cast<String>(),
          copyright: (json["copyright"] as List).cast<String>(),
        );

  List<String> getByCategory(TagCategory c) =>
      getByCategorySafe(c) ??
      (throw ArgumentError.value(c, "c", "Can't be TagCategory._error"));
  List<String>? getByCategorySafe(TagCategory c) => switch (c) {
        TagCategory.general => general,
        TagCategory.species => species,
        TagCategory.character => character,
        TagCategory.artist => artist,
        TagCategory.invalid => invalid,
        TagCategory.lore => lore,
        TagCategory.meta => meta,
        TagCategory.copyright => copyright,
        _ => null,
      };

  @override
  Map<String, dynamic> toJson() => {
        "general": general,
        "species": species,
        "character": character,
        "artist": artist,
        "invalid": invalid,
        "lore": lore,
        "meta": meta,
        "copyright": copyright,
      };
}

class Preview with model.BaseModel {
  /// The width of the file.
  final int width;

  /// The height of the file.
  final int height;

  /// {@template Preview.url}
  ///
  /// The URL where the preview file is hosted on E6
  ///
  /// If the post is a video, this is a preview image from the video
  ///
  /// If auth is not provided, [this may be null][1].
  ///
  /// [1]: https://e621.net/help/global_blacklist
  ///
  /// {@endtemplate}
  final String? url;

  const Preview({
    required this.width,
    required this.height,
    required this.url,
  });

  /// Allows null url if both [deletedUrlReplacement] and [otherUrlReplacement] are null.
  static Map<String, dynamic> replaceNullUrls(
    Map<String, dynamic> json,
    String? deletedUrlReplacement,
    String? otherUrlReplacement, {
    final String urlKey = "url",
  }) {
    if (deletedUrlReplacement == null && otherUrlReplacement == null) {
      return json;
    }
    return json
      ..[urlKey] ??= (json["flags"]["deleted"] as bool)
          ? deletedUrlReplacement
          : otherUrlReplacement;
  }

  /// {@template Preview.fromJson.NullUrlFix}
  /// Allows null url if both [deletedUrlReplacement] and [otherUrlReplacement] are null.
  ///
  /// If [deleted] is true and `json["url"]` is null, the value of [url] will be [deletedUrlReplacement].
  /// If [deleted] is false and `json["url"]` is null, the value of [url] will be [otherUrlReplacement].
  /// {@endtemplate}
  Preview.fromJson(
    Map<String, dynamic> json, {
    bool deleted = false,
    String? deletedUrlReplacement,
    String? otherUrlReplacement,
  })  : width = json["width"],
        height = json["height"],
        url = json["url"] ??
            (deleted ? deletedUrlReplacement : otherUrlReplacement);
  Preview copyWith({
    String? url = "",
    int? width,
    int? height,
  }) =>
      Preview(
        height: height ?? this.height,
        url: (url ?? "s").isNotEmpty ? url : this.url,
        width: width ?? this.width,
      );
  @override
  Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "url": url,
      };
}
class PreviewNonNull extends Preview {
  @override
  String get url => super.url!;

  const PreviewNonNull({
    required super.width,
    required super.height,
    required String super.url,
  });

  /// {@template Preview.fromJson.NullUrlFix}
  /// Allows null url if both [deletedUrlReplacement] and [otherUrlReplacement] are null.
  ///
  /// If [deleted] is true and `json["url"]` is null, the value of [url] will be [deletedUrlReplacement].
  /// If [deleted] is false and `json["url"]` is null, the value of [url] will be [otherUrlReplacement].
  /// {@endtemplate}
  PreviewNonNull.fromJson(
    super.json, {
    super.deleted = false,
    String super.deletedUrlReplacement = "",
    String super.otherUrlReplacement = "",
  })  : super.fromJson();
  @override
  PreviewNonNull copyWith({
    String? url,
    int? width,
    int? height,
  }) =>
      PreviewNonNull(
        height: height ?? this.height,
        url: url ?? this.url,
        width: width ?? this.width,
      );
}

class RelatedTag with model.BaseModel {
  final String name;
  final TagCategory category;
  const RelatedTag({
    required this.name,
    required this.category,
  });

  RelatedTag.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        category = TagCategory.fromJson(json["category_id"]);

  factory RelatedTag.fromRawJson(String json) =>
      RelatedTag.fromJson(dc.jsonDecode(json));
  int get categoryId => category.index;

  @override
  Map<String, dynamic> toJson() =>
      {"name": name, "category_id": category.toJson()};
}

class Sample extends Preview {
  /// If the post has a sample/thumbnail or not. (True/False)
  final bool has;
  final Alternates? alternates;

  const Sample({
    required this.has,
    required super.width,
    required super.height,
    required super.url,
    required this.alternates,
  });

  /// {@macro Preview.fromJson.NullUrlFix}
  Sample.fromJson(
    super.json, {
    super.deleted = false,
    super.deletedUrlReplacement,
    super.otherUrlReplacement,
  })  : has = json["has"],
        alternates = json["alternates"] != null
            ? Alternates.fromJson(json["alternates"],
                deleted: deleted,
                deletedUrlReplacement: deletedUrlReplacement,
                otherUrlReplacement: otherUrlReplacement)
            : null,
        super.fromJson();
}
class SampleNonNull extends Sample {
  @override
  AlternatesNonNull? get alternates => super.alternates as AlternatesNonNull?;

  const SampleNonNull({
    required super.has,
    required super.width,
    required super.height,
    required super.url,
    required AlternatesNonNull? super.alternates,
  });

  /// {@macro Preview.fromJson.NullUrlFix}
  SampleNonNull.fromJson(
    super.json, {
    super.deleted = false,
    String super.deletedUrlReplacement = "",
    String super.otherUrlReplacement = "",
  })  : super.fromJson();
}

class Score {
  /// The number of times voted up.
  final int up;

  /// A negative number representing the number of times voted down.
  final int down;

  /// The total score (up + down).
  final int total;

  const Score({
    required this.up,
    required this.down,
    required this.total,
  });
  Score.fromJson(Map<String, dynamic> json)
      : this(
          up: json["up"] as int,
          down: json["down"] as int,
          total: json["total"] as int,
        );
  Score.fromJsonRaw(String json) : this.fromJson(dc.jsonDecode(json));

  Score copyWith({
    int? up,
    int? down,
    int? total,
  }) =>
      Score(
        up: up ?? this.up,
        down: down ?? this.down,
        total: total ?? this.total,
      );

  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "total": total,
      };
}

/// https://e621.wiki/#operations-Tags-searchTags
/// 
class Tag extends TagDbEntry {
  /// <space-delimited list of tags>,???
  final List<String> relatedTags;

  /// <ISO8601 timestamp>,
  final DateTime? relatedTagsUpdatedAt;

  // /// <numeric category id>,
  // final TagCategory category;

  /// <boolean>,
  final bool isLocked;

  /// <ISO8601 timestamp>,
  final DateTime createdAt;

  /// <ISO8601 timestamp>
  final DateTime updatedAt;

  const Tag({
    required super.id,
    required super.name,
    required super.postCount,
    required this.relatedTags,
    required this.relatedTagsUpdatedAt,
    required super.category,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });
  Tag.fromJson(super.json)
      : relatedTags = (json["related_tags"] as List).cast<String>(),
        relatedTagsUpdatedAt = json["related_tags_updated_at"] as DateTime?,
        isLocked = json["is_locked"] as bool,
        createdAt = json["created_at"] as DateTime,
        updatedAt = json["updated_at"] as DateTime,
        super.fromJson();
  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      // "id": id,
      // "name": name,
      // "post_count": postCount,
      "related_tags": relatedTags,
      "related_tags_updated_at": relatedTagsUpdatedAt,
      // "category": category.index,
      "is_locked": isLocked,
      "created_at": createdAt,
      "updated_at": updatedAt,
    });
}

class TagDbEntry extends TagDbEntrySlim {
  static const csvHeader = "id,name,category,post_count";

  /// <numeric tag id>,
  final int id;
  const TagDbEntry({
    required this.id,
    required super.name,
    required super.category,
    required super.postCount,
  });
  TagDbEntry.fromCsv(super.csv)
      : id = int.parse(csv.split(",").first),
        super.fromCsv();
  TagDbEntry.fromJson(super.json)
      : id = json["id"] as int,
        super.fromJson();
  String toCsv() => "$id,$name,${category.index},$postCount";
  @override
  Map<String, dynamic> toJson() => super.toJson()..addAll({"id": id});

  /// Database archives have upwards of a million entries. Use Flutter's
  /// [compute](https://api.flutter.dev/flutter/foundation/compute.html) or
  /// [Isolate.run](https://api.flutter.dev/flutter/dart-isolate/Isolate/run.html).
  static List<TagDbEntry> parseCsv(String csv) => (csv.split("\n")
        ..removeAt(0)
        ..removeLast())
      .map(TagDbEntry.fromCsv)
      .toList();

  static List<String> rootParse(String e) {
    var t = e.split(",");
    if (e.contains('"')) {
      t = [
        t[0],
        e.substring(e.indexOf('"'), e.lastIndexOf('"') + 1),
        t[t.length - 2],
        t.last
      ];
    }
    if (t.length == 5) throw StateError("Shouldn't be possible");
    return t;
  }
}

/// Database files contain upwards of a million entries. In cases where the
/// [TagDbEntry.id] is not important, this class may be used to minimize the
/// memory and performance cost of parsing and storing a large number of entries.
class TagDbEntrySlim implements Comparable<TagDbEntrySlim> {
  static const csvHeader = "id,name,category,post_count";

  /// <tag display name>,
  final String name;

  /// <numeric category id>,
  final TagCategory category;

  /// <# matching visible posts>,
  final int postCount;
  const TagDbEntrySlim({
    required this.name,
    required this.category,
    required this.postCount,
  });
  TagDbEntrySlim.fromCsv(String csv)
      : name = csv.contains('"')
            ? csv.substring(csv.indexOf('"'), csv.lastIndexOf('"') + 1)
            : csv.split(",")[1],
        category = TagCategory.values[int.parse(csv.contains('"')
            ? csv.split(",")[csv.split(",").length - 2]
            : csv.split(",")[2])],
        postCount = int.parse(csv.split(",").last);
  TagDbEntrySlim.fromJson(Map<String, dynamic> json)
      : name = json["name"] as String,
        category = json["category"] as TagCategory,
        postCount = json["post_count"] as int;
  @override
  int compareTo(TagDbEntrySlim other) => other.postCount - postCount;

  Map<String, dynamic> toJson() => {
        "name": name,
        "category": category.index,
        "post_count": postCount,
      };

  /// Database archives have upwards of a million entries. Use Flutter's
  /// [compute](https://api.flutter.dev/flutter/foundation/compute.html) or
  /// [Isolate.run](https://api.flutter.dev/flutter/dart-isolate/Isolate/run.html).
  static List<TagDbEntrySlim> parseCsv(String csv) => (csv.split("\n")
        ..removeAt(0)
        ..removeLast())
      .map(TagDbEntrySlim.fromCsv)
      .toList();
  // int compareTo(TagDbEntrySlim other) =>
  //     (other.postCount - (other.postCount % 5)) - (postCount - postCount % 5);
  static List<String> rootParse(String e) {
    var t = e.split(",");
    if (e.contains('"')) {
      t = [
        t[0],
        e.substring(e.indexOf('"'), e.lastIndexOf('"') + 1),
        t[t.length - 2],
        t.last
      ];
    }
    // if (t.length == 5) t = [t[0], t[1] + t[2], t[3], t[4]];
    if (t.length == 5) throw StateError("Shouldn't be possible");
    return t;
  }
}

/// TODO: Cancelling an unvote returns ourScore as 0. Change to reflect.
/// 
class UpdatedScore extends Score implements VoteResult {
  /// Our score is 1 (for upvoted), 0 (for no vote), or -1 (for downvoted).
  @override
  final int ourScore;

  const UpdatedScore({
    required super.up,
    required super.down,
    required int score,
    required this.ourScore,
    /* this.castVote,
    this.noUnvote, */
  }) : super(total: score);

  UpdatedScore.fromJson(Map<String, dynamic> json)
      : this(
          up: json["up"] as int,
          down: json["down"] as int,
          score: json["score"] as int,
          ourScore: json["our_score"] as int,
        );
  UpdatedScore.fromJsonRaw(String json) : this.fromJson(dc.jsonDecode(json));
  const UpdatedScore.inherited({
    required super.up,
    required super.down,
    required super.total,
    required this.ourScore,
    /* this.castVote,
    this.noUnvote, */
  });

  bool get isDownvoted => ourScore < 0;

  /* /// Cast vote.
  @override
  final int? voteCast;

  /// Our score is 1 (for upvoted), 0 (for no vote), or -1 (for downvoted).
  int? get ourScoreTrue => noUnvote != null ? ourScore == 0 && noUnvote! ?  : null;

  @override
  final bool? noUnvote; */

  bool get isUpvoted => ourScore > 0;
  bool get isVotedOn => ourScore != 0;

  /// The total score (up + down).
  @override
  int get score => total;

  /// `true` if the user upvoted this post, `false` if the user downvoted this post, `null` if the user didn't vote on this post.
  bool? get voteState => switch (ourScore) {
        > 0 => true,
        < 0 => false,
        == 0 => null,
        _ => null,
      };

  @override
  UpdatedScore copyWith({
    int? up,
    int? down,
    int? score,
    int? total,
    int? ourScore,
  }) =>
      UpdatedScore(
        up: up ?? this.up,
        down: down ?? this.down,
        score: score ?? total ?? this.score,
        ourScore: ourScore ?? this.ourScore,
      );

  @override
  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "score": score,
        "total": total,
        "our_score": ourScore,
      };
  static int determineOurTrueScore(int castVote, int ourScore, bool noUnvote) {
    if (noUnvote) {
      if (castVote > 0 && ourScore >= 0) {
        return 1;
      } else if (castVote < 0 && ourScore <= 0) {
        return -1;
      } else {
        return ourScore;
      }
    } else {
      return ourScore;
    }
  }
}

class User extends model.User with UserMixin {
  /// From User
  @override
  final int id;

  /// From User
  @override
  final DateTime createdAt;

  /// From User
  @override
  final String name;

  /// From User
  @override
  final int level;

  /// From User
  @override
  final int baseUploadLimit;

  /// From User
  @override
  final int noteUpdateCount;

  /// From User
  @override
  final int postUpdateCount;

  /// From User
  @override
  final int postUploadCount;

  /// From User
  @override
  final bool isBanned;

  /// From User
  @override
  final bool canApprovePosts;

  /// From User
  @override
  final bool canUploadFree;

  /// From User
  @override
  final UserLevel levelString;

  /// From User
  @override
  final int? avatarId;

  const User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.level,
    required this.baseUploadLimit,
    required this.noteUpdateCount,
    required this.postUpdateCount,
    required this.postUploadCount,
    required this.isBanned,
    required this.canApprovePosts,
    required this.canUploadFree,
    required this.levelString,
    required this.avatarId,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        createdAt = DateTime.parse(json["created_at"]),
        name = json["name"],
        level = json["level"],
        baseUploadLimit = json["base_upload_limit"],
        noteUpdateCount = json["note_update_count"],
        postUpdateCount = json["post_update_count"],
        postUploadCount = json["post_upload_count"],
        isBanned = json["is_banned"],
        canApprovePosts = json["can_approve_posts"],
        canUploadFree = json["can_upload_free"],
        levelString = UserLevel(json["level_string"]),
        avatarId = json["avatar_id"];

  factory User.fromRawJson(String str) {
    var t = dc.json.decode(str);
    return (t is List) ? User.fromJson(t[0]) : User.fromJson(t);
  }

  User copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    int? level,
    int? baseUploadLimit,
    int? noteUpdateCount,
    int? postUpdateCount,
    int? postUploadCount,
    bool? isBanned,
    bool? canApprovePosts,
    bool? canUploadFree,
    UserLevel? levelString,
    int? avatarId = -1,
  }) =>
      User(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        level: level ?? this.level,
        baseUploadLimit: baseUploadLimit ?? this.baseUploadLimit,
        noteUpdateCount: noteUpdateCount ?? this.noteUpdateCount,
        postUpdateCount: postUpdateCount ?? this.postUpdateCount,
        postUploadCount: postUploadCount ?? this.postUploadCount,
        isBanned: isBanned ?? this.isBanned,
        canApprovePosts: canApprovePosts ?? this.canApprovePosts,
        canUploadFree: canUploadFree ?? this.canUploadFree,
        levelString: levelString ?? this.levelString,
        avatarId: avatarId == -1 ? this.avatarId : avatarId,
      );

  User copyWithInstance(User? other) => (other ?? this).copyWith();
}

class UserDetailed extends User with UserDetailedMixin {
  // #region Fields
  /// From UserDetailed
  ///
  /// wiki_page_version_count
  @override
  final int wikiPageVersionCount;

  /// From UserDetailed
  ///
  /// artist_version_count
  @override
  final int artistVersionCount;

  /// From UserDetailed
  ///
  /// pool_version_count
  @override
  final int poolVersionCount;

  /// From UserDetailed
  ///
  /// forum_post_count
  @override
  final int forumPostCount;

  /// From UserDetailed
  ///
  /// comment_count
  @override
  final int commentCount;

  /// From UserDetailed
  ///
  /// flag_count
  @override
  final int flagCount;

  /// From UserDetailed
  ///
  /// positive_feedback_count
  @override
  final int positiveFeedbackCount;

  /// From UserDetailed
  ///
  /// neutral_feedback_count
  @override
  final int neutralFeedbackCount;

  /// From UserDetailed
  ///
  /// negative_feedback_count
  @override
  final int negativeFeedbackCount;

  /// From UserDetailed
  ///
  /// upload_limit
  @override
  final int uploadLimit;

  /// From UserDetailed
  ///
  /// profile_about
  @override
  final String profileAbout;

  /// From UserDetailed
  ///
  /// profile_artinfo
  @override
  final String profileArtInfo;

  @override
  final int favoriteCount;
  // #endregion Fields

  const UserDetailed({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.level,
    required super.baseUploadLimit,
    required super.postUploadCount,
    required super.postUpdateCount,
    required super.noteUpdateCount,
    required super.isBanned,
    required super.canApprovePosts,
    required super.canUploadFree,
    required super.levelString,
    required super.avatarId,
    required this.wikiPageVersionCount,
    required this.artistVersionCount,
    required this.poolVersionCount,
    required this.forumPostCount,
    required this.commentCount,
    required this.flagCount,
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
    required this.uploadLimit,
    required this.profileAbout,
    required this.profileArtInfo,
    required this.favoriteCount,
  });
  UserDetailed.fromJson(super.json)
      : wikiPageVersionCount = json["wiki_page_version_count"],
        artistVersionCount = json["artist_version_count"],
        poolVersionCount = json["pool_version_count"],
        forumPostCount = json["forum_post_count"],
        commentCount = json["comment_count"],
        flagCount = json["flag_count"],
        favoriteCount = json["favorite_count"],
        positiveFeedbackCount = json["positive_feedback_count"],
        neutralFeedbackCount = json["neutral_feedback_count"],
        negativeFeedbackCount = json["negative_feedback_count"],
        uploadLimit = json["upload_limit"],
        profileAbout = json["profile_about"],
        profileArtInfo = json["profile_artinfo"],
        super.fromJson();
  factory UserDetailed.fromRawJson(String str) =>
      UserDetailed.fromJson(dc.json.decode(str));

  @override
  UserDetailed copyWith({
    int? avatarId = -1,
    int? id,
    DateTime? createdAt,
    String? name,
    int? level,
    int? baseUploadLimit,
    int? postUploadCount,
    int? postUpdateCount,
    int? noteUpdateCount,
    bool? isBanned,
    bool? canApprovePosts,
    bool? canUploadFree,
    UserLevel? levelString,
    int? wikiPageVersionCount,
    int? artistVersionCount,
    int? poolVersionCount,
    int? forumPostCount,
    int? commentCount,
    int? flagCount,
    int? favoriteCount,
    int? positiveFeedbackCount,
    int? neutralFeedbackCount,
    int? negativeFeedbackCount,
    int? uploadLimit,
    String? profileAbout,
    String? profileArtInfo,
  }) =>
      UserDetailed(
        avatarId: (avatarId ?? 1) > 0 ? avatarId : this.avatarId,
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        level: level ?? this.level,
        baseUploadLimit: baseUploadLimit ?? this.baseUploadLimit,
        postUploadCount: postUploadCount ?? this.postUploadCount,
        postUpdateCount: postUpdateCount ?? this.postUpdateCount,
        noteUpdateCount: noteUpdateCount ?? this.noteUpdateCount,
        isBanned: isBanned ?? this.isBanned,
        canApprovePosts: canApprovePosts ?? this.canApprovePosts,
        canUploadFree: canUploadFree ?? this.canUploadFree,
        levelString: levelString ?? this.levelString,
        wikiPageVersionCount: wikiPageVersionCount ?? this.wikiPageVersionCount,
        artistVersionCount: artistVersionCount ?? this.artistVersionCount,
        poolVersionCount: poolVersionCount ?? this.poolVersionCount,
        forumPostCount: forumPostCount ?? this.forumPostCount,
        commentCount: commentCount ?? this.commentCount,
        flagCount: flagCount ?? this.flagCount,
        positiveFeedbackCount:
            positiveFeedbackCount ?? this.positiveFeedbackCount,
        neutralFeedbackCount: neutralFeedbackCount ?? this.neutralFeedbackCount,
        negativeFeedbackCount:
            negativeFeedbackCount ?? this.negativeFeedbackCount,
        uploadLimit: uploadLimit ?? this.uploadLimit,
        profileAbout: profileAbout ?? this.profileAbout,
        profileArtInfo: profileArtInfo ?? this.profileArtInfo,
        favoriteCount: favoriteCount ?? this.favoriteCount,
      );

  @override
  UserDetailed copyWithInstance(User? other) {
    var userD = other is UserDetailed ? other : null;
    return switch (other) {
      UserLoggedInDetail _ => other.copyWithInstance(null),
      UserLoggedIn _ => UserLoggedInDetail(
          wikiPageVersionCount: wikiPageVersionCount,
          artistVersionCount: artistVersionCount,
          poolVersionCount: poolVersionCount,
          forumPostCount: forumPostCount,
          commentCount: commentCount,
          flagCount: flagCount,
          positiveFeedbackCount: positiveFeedbackCount,
          neutralFeedbackCount: neutralFeedbackCount,
          negativeFeedbackCount: negativeFeedbackCount,
          uploadLimit: uploadLimit,
          profileAbout: profileAbout,
          profileArtInfo: profileArtInfo,
          favoriteCount: other.favoriteCount,
          id: other.id,
          createdAt: other.createdAt,
          name: other.name,
          level: other.level,
          baseUploadLimit: other.baseUploadLimit,
          postUploadCount: other.postUploadCount,
          postUpdateCount: other.postUpdateCount,
          noteUpdateCount: other.noteUpdateCount,
          isBanned: other.isBanned,
          canApprovePosts: other.canApprovePosts,
          canUploadFree: other.canUploadFree,
          levelString: other.levelString,
          avatarId: other.avatarId,
          blacklistUsers: other.blacklistUsers,
          descriptionCollapsedInitially: other.descriptionCollapsedInitially,
          hideComments: other.hideComments,
          showHiddenComments: other.showHiddenComments,
          showPostStatistics: other.showPostStatistics,
          receiveEmailNotifications: other.receiveEmailNotifications,
          enableKeyboardNavigation: other.enableKeyboardNavigation,
          enablePrivacyMode: other.enablePrivacyMode,
          styleUsernames: other.styleUsernames,
          enableAutoComplete: other.enableAutoComplete,
          disableCroppedThumbnails: other.disableCroppedThumbnails,
          enableSafeMode: other.enableSafeMode,
          disableResponsiveMode: other.disableResponsiveMode,
          noFlagging: other.noFlagging,
          disableUserDmails: other.disableUserDmails,
          enableCompactUploader: other.enableCompactUploader,
          replacementsBeta: other.replacementsBeta,
          updatedAt: other.updatedAt,
          email: other.email,
          lastLoggedInAt: other.lastLoggedInAt,
          lastForumReadAt: other.lastForumReadAt,
          recentTags: other.recentTags,
          commentThreshold: other.commentThreshold,
          defaultImageSize: other.defaultImageSize,
          favoriteTags: other.favoriteTags,
          blacklistedTags: other.blacklistedTags,
          timeZone: other.timeZone,
          perPage: other.perPage,
          customStyle: other.customStyle,
          apiRegenMultiplier: other.apiRegenMultiplier,
          apiBurstLimit: other.apiBurstLimit,
          remainingApiLimit: other.remainingApiLimit,
          statementTimeout: other.statementTimeout,
          favoriteLimit: other.favoriteLimit,
          tagQueryLimit: other.tagQueryLimit,
          hasMail: other.hasMail,
        ),
      _ => UserDetailed(
          id: (other ?? this).id,
          createdAt: (other ?? this).createdAt,
          name: (other ?? this).name,
          level: (other ?? this).level,
          baseUploadLimit: (other ?? this).baseUploadLimit,
          postUploadCount: (other ?? this).postUploadCount,
          postUpdateCount: (other ?? this).postUpdateCount,
          noteUpdateCount: (other ?? this).noteUpdateCount,
          isBanned: (other ?? this).isBanned,
          canApprovePosts: (other ?? this).canApprovePosts,
          canUploadFree: (other ?? this).canUploadFree,
          levelString: (other ?? this).levelString,
          avatarId: (other ?? this).avatarId,
          wikiPageVersionCount: (userD ?? this).wikiPageVersionCount,
          artistVersionCount: (userD ?? this).artistVersionCount,
          poolVersionCount: (userD ?? this).poolVersionCount,
          forumPostCount: (userD ?? this).forumPostCount,
          commentCount: (userD ?? this).commentCount,
          flagCount: (userD ?? this).flagCount,
          positiveFeedbackCount: (userD ?? this).positiveFeedbackCount,
          neutralFeedbackCount: (userD ?? this).neutralFeedbackCount,
          negativeFeedbackCount: (userD ?? this).negativeFeedbackCount,
          uploadLimit: (userD ?? this).uploadLimit,
          profileAbout: (userD ?? this).profileAbout,
          profileArtInfo: (userD ?? this).profileArtInfo,
          favoriteCount: (userD ?? this).favoriteCount,
        ),
    };
  }

  @override
  Map<String, dynamic> toJson() => {
        "wiki_page_version_count": wikiPageVersionCount,
        "artist_version_count": artistVersionCount,
        "pool_version_count": poolVersionCount,
        "forum_post_count": forumPostCount,
        "comment_count": commentCount,
        "flag_count": flagCount,
        "positive_feedback_count": positiveFeedbackCount,
        "neutral_feedback_count": neutralFeedbackCount,
        "negative_feedback_count": negativeFeedbackCount,
        "upload_limit": uploadLimit,
        "favorite_count": favoriteCount,
        "profile_about": profileAbout,
        "profile_artinfo": profileArtInfo,
      }..addAll(super.toJson());
  @override
  String toRawJson() => dc.json.encode(toJson());
}

mixin UserDetailedMixin on UserMixin {
  int get artistVersionCount;
  int get commentCount;
  int get favoriteCount;
  int get flagCount;
  int get forumPostCount;
  int get negativeFeedbackCount;
  int get neutralFeedbackCount;
  int get poolVersionCount;
  int get positiveFeedbackCount;
  String get profileAbout;
  String get profileArtInfo;
  int get uploadLimit;
  int get wikiPageVersionCount;
}

mixin UserHelpers on model.UserLoggedIn {
  List<String> get blacklistedTagsList => blacklistedTags.split(RegExp(r'\s'));
  Set<String> get blacklistedTagsSet => blacklistedTagsList.toSet();
}

class UserLoggedIn extends User with CurrentUser {
  // #region Fields
  /// From UserLoggedIn
  @override
  final bool blacklistUsers;

  /// From UserLoggedIn
  @override
  final bool descriptionCollapsedInitially;

  /// From UserLoggedIn
  @override
  final bool hideComments;

  /// From UserLoggedIn
  @override
  final bool showHiddenComments;

  /// From UserLoggedIn
  @override
  final bool showPostStatistics;

  /// From UserLoggedIn
  @override
  final bool receiveEmailNotifications;

  /// From UserLoggedIn
  @override
  final bool enableKeyboardNavigation;

  /// From UserLoggedIn
  @override
  final bool enablePrivacyMode;

  /// From UserLoggedIn
  @override
  final bool styleUsernames;

  /// From UserLoggedIn
  @override
  final bool enableAutoComplete;

  /// From UserLoggedIn
  @override
  final bool disableCroppedThumbnails;

  /// From UserLoggedIn
  @override
  final bool enableSafeMode;

  /// From UserLoggedIn
  @override
  final bool disableResponsiveMode;

  /// From UserLoggedIn
  @override
  final bool noFlagging;

  /// From UserLoggedIn
  @override
  final bool disableUserDmails;

  /// From UserLoggedIn
  @override
  final bool enableCompactUploader;

  /// From UserLoggedIn
  @override
  final bool replacementsBeta;

  /// From UserLoggedIn
  @override
  final DateTime updatedAt;

  /// From UserLoggedIn
  @override
  final String email;

  /// From UserLoggedIn
  @override
  final DateTime lastLoggedInAt;

  /// From UserLoggedIn
  @override
  final DateTime lastForumReadAt;

  /// From UserLoggedIn
  @override
  final String recentTags;

  /// From UserLoggedIn
  @override
  final int commentThreshold;

  /// From UserLoggedIn
  @override
  final DefaultImageSize defaultImageSize;

  /// From UserLoggedIn
  @override
  final String favoriteTags;

  /// From UserLoggedIn
  @override
  final String blacklistedTags;

  /// From UserLoggedIn
  @override
  final String timeZone;

  /// From UserLoggedIn
  @override
  final int perPage;

  /// From UserLoggedIn
  @override
  final String customStyle;

  /// From UserLoggedIn
  @override
  final int favoriteCount;

  /// From UserLoggedIn
  @override
  final int apiRegenMultiplier;

  /// From UserLoggedIn
  @override
  final int apiBurstLimit;

  /// From UserLoggedIn
  @override
  final int remainingApiLimit;

  /// From UserLoggedIn
  @override
  final int statementTimeout;

  /// From UserLoggedIn
  ///
  /// Defaults to 80000.
  @override
  final int favoriteLimit;

  /// From UserLoggedIn
  ///
  /// Defaults to 40.
  @override
  final int tagQueryLimit;

  /// From UserLoggedIn
  @override
  final bool hasMail;
  // #endregion Fields

  const UserLoggedIn({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.level,
    required super.baseUploadLimit,
    required super.postUploadCount,
    required super.postUpdateCount,
    required super.noteUpdateCount,
    required super.isBanned,
    required super.canApprovePosts,
    required super.canUploadFree,
    required super.levelString,
    required super.avatarId,
    required this.favoriteCount,
    required this.blacklistUsers,
    required this.descriptionCollapsedInitially,
    required this.hideComments,
    required this.showHiddenComments,
    required this.showPostStatistics,
    required this.receiveEmailNotifications,
    required this.enableKeyboardNavigation,
    required this.enablePrivacyMode,
    required this.styleUsernames,
    required this.enableAutoComplete,
    required this.disableCroppedThumbnails,
    required this.enableSafeMode,
    required this.disableResponsiveMode,
    required this.noFlagging,
    required this.disableUserDmails,
    required this.enableCompactUploader,
    required this.replacementsBeta,
    required this.updatedAt,
    required this.email,
    required this.lastLoggedInAt,
    required this.lastForumReadAt,
    required this.recentTags,
    required this.commentThreshold,
    required this.defaultImageSize,
    required this.favoriteTags,
    required this.blacklistedTags,
    required this.timeZone,
    required this.perPage,
    required this.customStyle,
    required this.apiRegenMultiplier,
    required this.apiBurstLimit,
    required this.remainingApiLimit,
    required this.statementTimeout,
    required this.favoriteLimit,
    required this.tagQueryLimit,
    required this.hasMail,
  });

  UserLoggedIn.fromJson(super.json)
      : blacklistUsers = json["blacklist_users"],
        descriptionCollapsedInitially = json["description_collapsed_initially"],
        hideComments = json["hide_comments"],
        showHiddenComments = json["show_hidden_comments"],
        showPostStatistics = json["show_post_statistics"],
        receiveEmailNotifications = json["receive_email_notifications"],
        enableKeyboardNavigation = json["enable_keyboard_navigation"],
        enablePrivacyMode = json["enable_privacy_mode"],
        styleUsernames = json["style_usernames"],
        enableAutoComplete = json["enable_auto_complete"],
        disableCroppedThumbnails = json["disable_cropped_thumbnails"],
        enableSafeMode = json["enable_safe_mode"],
        disableResponsiveMode = json["disable_responsive_mode"],
        noFlagging = json["no_flagging"],
        disableUserDmails = json["disable_user_dmails"],
        enableCompactUploader = json["enable_compact_uploader"],
        replacementsBeta = json["replacements_beta"],
        updatedAt = DateTime.parse(json["updated_at"]),
        email = json["email"],
        lastLoggedInAt = DateTime.parse(json["last_logged_in_at"]),
        lastForumReadAt = DateTime.parse(json["last_forum_read_at"]),
        recentTags = json["recent_tags"],
        commentThreshold = json["comment_threshold"],
        defaultImageSize =
            DefaultImageSize.fromJson(json["default_image_size"]),
        favoriteTags = json["favorite_tags"],
        blacklistedTags = json["blacklisted_tags"],
        timeZone = json["time_zone"],
        perPage = json["per_page"],
        customStyle = json["custom_style"],
        favoriteCount = json["favorite_count"],
        apiRegenMultiplier = json["api_regen_multiplier"],
        apiBurstLimit = json["api_burst_limit"],
        remainingApiLimit = json["remaining_api_limit"],
        statementTimeout = json["statement_timeout"],
        favoriteLimit = json["favorite_limit"],
        tagQueryLimit = json["tag_query_limit"],
        hasMail = json["has_mail"],
        super.fromJson();
  factory UserLoggedIn.fromRawJson(String str) {
    var t = dc.json.decode(str);
    return (t is List) ? UserLoggedIn.fromJson(t[0]) : UserLoggedIn.fromJson(t);
  }

  @override
  UserLoggedIn copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    int? level,
    int? baseUploadLimit,
    int? postUploadCount,
    int? postUpdateCount,
    int? noteUpdateCount,
    bool? isBanned,
    bool? canApprovePosts,
    bool? canUploadFree,
    UserLevel? levelString,
    int? avatarId = -1,
    bool? blacklistUsers,
    bool? descriptionCollapsedInitially,
    bool? hideComments,
    bool? showHiddenComments,
    bool? showPostStatistics,
    bool? receiveEmailNotifications,
    bool? enableKeyboardNavigation,
    bool? enablePrivacyMode,
    bool? styleUsernames,
    bool? enableAutoComplete,
    bool? disableCroppedThumbnails,
    bool? enableSafeMode,
    bool? disableResponsiveMode,
    bool? noFlagging,
    bool? disableUserDmails,
    bool? enableCompactUploader,
    bool? replacementsBeta,
    DateTime? updatedAt,
    String? email,
    DateTime? lastLoggedInAt,
    DateTime? lastForumReadAt,
    String? recentTags,
    int? commentThreshold,
    DefaultImageSize? defaultImageSize,
    String? favoriteTags,
    String? blacklistedTags,
    String? timeZone,
    int? perPage,
    String? customStyle,
    int? favoriteCount,
    int? apiRegenMultiplier,
    int? apiBurstLimit,
    int? remainingApiLimit,
    int? statementTimeout,
    int? favoriteLimit,
    int? tagQueryLimit,
    bool? hasMail,
  }) =>
      UserLoggedIn(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        level: level ?? this.level,
        baseUploadLimit: baseUploadLimit ?? this.baseUploadLimit,
        postUploadCount: postUploadCount ?? this.postUploadCount,
        postUpdateCount: postUpdateCount ?? this.postUpdateCount,
        noteUpdateCount: noteUpdateCount ?? this.noteUpdateCount,
        isBanned: isBanned ?? this.isBanned,
        canApprovePosts: canApprovePosts ?? this.canApprovePosts,
        canUploadFree: canUploadFree ?? this.canUploadFree,
        levelString: levelString ?? this.levelString,
        avatarId: avatarId == -1 ? this.avatarId : avatarId,
        blacklistUsers: blacklistUsers ?? this.blacklistUsers,
        descriptionCollapsedInitially:
            descriptionCollapsedInitially ?? this.descriptionCollapsedInitially,
        hideComments: hideComments ?? this.hideComments,
        showHiddenComments: showHiddenComments ?? this.showHiddenComments,
        showPostStatistics: showPostStatistics ?? this.showPostStatistics,
        receiveEmailNotifications:
            receiveEmailNotifications ?? this.receiveEmailNotifications,
        enableKeyboardNavigation:
            enableKeyboardNavigation ?? this.enableKeyboardNavigation,
        enablePrivacyMode: enablePrivacyMode ?? this.enablePrivacyMode,
        styleUsernames: styleUsernames ?? this.styleUsernames,
        enableAutoComplete: enableAutoComplete ?? this.enableAutoComplete,
        disableCroppedThumbnails:
            disableCroppedThumbnails ?? this.disableCroppedThumbnails,
        enableSafeMode: enableSafeMode ?? this.enableSafeMode,
        disableResponsiveMode:
            disableResponsiveMode ?? this.disableResponsiveMode,
        noFlagging: noFlagging ?? this.noFlagging,
        disableUserDmails: disableUserDmails ?? this.disableUserDmails,
        enableCompactUploader:
            enableCompactUploader ?? this.enableCompactUploader,
        replacementsBeta: replacementsBeta ?? this.replacementsBeta,
        updatedAt: updatedAt ?? this.updatedAt,
        email: email ?? this.email,
        lastLoggedInAt: lastLoggedInAt ?? this.lastLoggedInAt,
        lastForumReadAt: lastForumReadAt ?? this.lastForumReadAt,
        recentTags: recentTags ?? this.recentTags,
        commentThreshold: commentThreshold ?? this.commentThreshold,
        defaultImageSize: defaultImageSize ?? this.defaultImageSize,
        favoriteTags: favoriteTags ?? this.favoriteTags,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        timeZone: timeZone ?? this.timeZone,
        perPage: perPage ?? this.perPage,
        customStyle: customStyle ?? this.customStyle,
        favoriteCount: favoriteCount ?? this.favoriteCount,
        apiRegenMultiplier: apiRegenMultiplier ?? this.apiRegenMultiplier,
        apiBurstLimit: apiBurstLimit ?? this.apiBurstLimit,
        remainingApiLimit: remainingApiLimit ?? this.remainingApiLimit,
        statementTimeout: statementTimeout ?? this.statementTimeout,
        favoriteLimit: favoriteLimit ?? this.favoriteLimit,
        tagQueryLimit: tagQueryLimit ?? this.tagQueryLimit,
        hasMail: hasMail ?? this.hasMail,
      );

  @override
  UserLoggedIn copyWithInstance(User? other) {
    var userL = other is UserLoggedIn ? other : null;
    return switch (other) {
      UserLoggedInDetail _ => other.copyWithInstance(null),
      UserDetailed _ => UserLoggedInDetail(
          wikiPageVersionCount: other.wikiPageVersionCount,
          artistVersionCount: other.artistVersionCount,
          poolVersionCount: other.poolVersionCount,
          forumPostCount: other.forumPostCount,
          commentCount: other.commentCount,
          flagCount: other.flagCount,
          positiveFeedbackCount: other.positiveFeedbackCount,
          neutralFeedbackCount: other.neutralFeedbackCount,
          negativeFeedbackCount: other.negativeFeedbackCount,
          uploadLimit: other.uploadLimit,
          profileAbout: other.profileAbout,
          profileArtInfo: other.profileArtInfo,
          favoriteCount: other.favoriteCount,
          id: other.id,
          createdAt: other.createdAt,
          name: other.name,
          level: other.level,
          baseUploadLimit: other.baseUploadLimit,
          postUploadCount: other.postUploadCount,
          postUpdateCount: other.postUpdateCount,
          noteUpdateCount: other.noteUpdateCount,
          isBanned: other.isBanned,
          canApprovePosts: other.canApprovePosts,
          canUploadFree: other.canUploadFree,
          levelString: other.levelString,
          avatarId: other.avatarId,
          blacklistUsers: blacklistUsers,
          descriptionCollapsedInitially: descriptionCollapsedInitially,
          hideComments: hideComments,
          showHiddenComments: showHiddenComments,
          showPostStatistics: showPostStatistics,
          receiveEmailNotifications: receiveEmailNotifications,
          enableKeyboardNavigation: enableKeyboardNavigation,
          enablePrivacyMode: enablePrivacyMode,
          styleUsernames: styleUsernames,
          enableAutoComplete: enableAutoComplete,
          disableCroppedThumbnails: disableCroppedThumbnails,
          enableSafeMode: enableSafeMode,
          disableResponsiveMode: disableResponsiveMode,
          noFlagging: noFlagging,
          disableUserDmails: disableUserDmails,
          enableCompactUploader: enableCompactUploader,
          replacementsBeta: replacementsBeta,
          updatedAt: updatedAt,
          email: email,
          lastLoggedInAt: lastLoggedInAt,
          lastForumReadAt: lastForumReadAt,
          recentTags: recentTags,
          commentThreshold: commentThreshold,
          defaultImageSize: defaultImageSize,
          favoriteTags: favoriteTags,
          blacklistedTags: blacklistedTags,
          timeZone: timeZone,
          perPage: perPage,
          customStyle: customStyle,
          apiRegenMultiplier: apiRegenMultiplier,
          apiBurstLimit: apiBurstLimit,
          remainingApiLimit: remainingApiLimit,
          statementTimeout: statementTimeout,
          favoriteLimit: favoriteLimit,
          tagQueryLimit: tagQueryLimit,
          hasMail: hasMail,
        ),
      _ => UserLoggedIn(
          id: (other ?? this).id,
          createdAt: (other ?? this).createdAt,
          name: (other ?? this).name,
          level: (other ?? this).level,
          baseUploadLimit: (other ?? this).baseUploadLimit,
          postUploadCount: (other ?? this).postUploadCount,
          postUpdateCount: (other ?? this).postUpdateCount,
          noteUpdateCount: (other ?? this).noteUpdateCount,
          isBanned: (other ?? this).isBanned,
          canApprovePosts: (other ?? this).canApprovePosts,
          canUploadFree: (other ?? this).canUploadFree,
          levelString: (other ?? this).levelString,
          avatarId: other == null ? avatarId : other.avatarId,
          favoriteCount: (userL ?? this).favoriteCount,
          blacklistUsers: (userL ?? this).blacklistUsers,
          descriptionCollapsedInitially:
              (userL ?? this).descriptionCollapsedInitially,
          hideComments: (userL ?? this).hideComments,
          showHiddenComments: (userL ?? this).showHiddenComments,
          showPostStatistics: (userL ?? this).showPostStatistics,
          receiveEmailNotifications: (userL ?? this).receiveEmailNotifications,
          enableKeyboardNavigation: (userL ?? this).enableKeyboardNavigation,
          enablePrivacyMode: (userL ?? this).enablePrivacyMode,
          styleUsernames: (userL ?? this).styleUsernames,
          enableAutoComplete: (userL ?? this).enableAutoComplete,
          disableCroppedThumbnails: (userL ?? this).disableCroppedThumbnails,
          enableSafeMode: (userL ?? this).enableSafeMode,
          disableResponsiveMode: (userL ?? this).disableResponsiveMode,
          noFlagging: (userL ?? this).noFlagging,
          disableUserDmails: (userL ?? this).disableUserDmails,
          enableCompactUploader: (userL ?? this).enableCompactUploader,
          replacementsBeta: (userL ?? this).replacementsBeta,
          updatedAt: (userL ?? this).updatedAt,
          email: (userL ?? this).email,
          lastLoggedInAt: (userL ?? this).lastLoggedInAt,
          lastForumReadAt: (userL ?? this).lastForumReadAt,
          recentTags: (userL ?? this).recentTags,
          commentThreshold: (userL ?? this).commentThreshold,
          defaultImageSize: (userL ?? this).defaultImageSize,
          favoriteTags: (userL ?? this).favoriteTags,
          blacklistedTags: (userL ?? this).blacklistedTags,
          timeZone: (userL ?? this).timeZone,
          perPage: (userL ?? this).perPage,
          customStyle: (userL ?? this).customStyle,
          apiRegenMultiplier: (userL ?? this).apiRegenMultiplier,
          apiBurstLimit: (userL ?? this).apiBurstLimit,
          remainingApiLimit: (userL ?? this).remainingApiLimit,
          statementTimeout: (userL ?? this).statementTimeout,
          favoriteLimit: (userL ?? this).favoriteLimit,
          tagQueryLimit: (userL ?? this).tagQueryLimit,
          hasMail: (userL ?? this).hasMail,
        )
    };
  }

  @override
  Map<String, dynamic> toJson() => {
        // "id": id,
        // "created_at": createdAt.toIso8601String(),
        // "name": name,
        // "level": level,
        // "base_upload_limit": baseUploadLimit,
        // "post_upload_count": postUploadCount,
        // "post_update_count": postUpdateCount,
        // "note_update_count": noteUpdateCount,
        // "is_banned": isBanned,
        // "can_approve_posts": canApprovePosts,
        // "can_upload_free": canUploadFree,
        // "level_string": levelString,
        // "avatar_id": avatarId,
        "blacklist_users": blacklistUsers,
        "description_collapsed_initially": descriptionCollapsedInitially,
        "hide_comments": hideComments,
        "show_hidden_comments": showHiddenComments,
        "show_post_statistics": showPostStatistics,
        "receive_email_notifications": receiveEmailNotifications,
        "enable_keyboard_navigation": enableKeyboardNavigation,
        "enable_privacy_mode": enablePrivacyMode,
        "style_usernames": styleUsernames,
        "enable_auto_complete": enableAutoComplete,
        "disable_cropped_thumbnails": disableCroppedThumbnails,
        "enable_safe_mode": enableSafeMode,
        "disable_responsive_mode": disableResponsiveMode,
        "no_flagging": noFlagging,
        "disable_user_dmails": disableUserDmails,
        "enable_compact_uploader": enableCompactUploader,
        "replacements_beta": replacementsBeta,
        "updated_at": updatedAt.toIso8601String(),
        "email": email,
        "last_logged_in_at": lastLoggedInAt.toIso8601String(),
        "last_forum_read_at": lastForumReadAt.toIso8601String(),
        "recent_tags": recentTags,
        "comment_threshold": commentThreshold,
        "default_image_size": defaultImageSize.name,
        "favorite_tags": favoriteTags,
        "blacklisted_tags": blacklistedTags,
        "time_zone": timeZone,
        "per_page": perPage,
        "custom_style": customStyle,
        "favorite_count": favoriteCount,
        "api_regen_multiplier": apiRegenMultiplier,
        "api_burst_limit": apiBurstLimit,
        "remaining_api_limit": remainingApiLimit,
        "statement_timeout": statementTimeout,
        "favorite_limit": favoriteLimit,
        "tag_query_limit": tagQueryLimit,
        "has_mail": hasMail,
      }..addAll(super.toJson());

  @override
  String toRawJson() => dc.json.encode(toJson());
}

class UserLoggedInDetail extends UserLoggedIn
    with UserMixin, CurrentUser, UserDetailedMixin
    implements UserDetailed {
  // #region Fields
  /// From UserDetailed
  @override
  final int wikiPageVersionCount;

  /// From UserDetailed
  @override
  final int artistVersionCount;

  /// From UserDetailed
  @override
  final int poolVersionCount;

  /// From UserDetailed
  @override
  final int forumPostCount;

  /// From UserDetailed
  @override
  final int commentCount;

  /// From UserDetailed
  @override
  final int flagCount;

  /// From UserDetailed
  @override
  final int positiveFeedbackCount;

  /// From UserDetailed
  @override
  final int neutralFeedbackCount;

  /// From UserDetailed
  @override
  final int negativeFeedbackCount;

  /// From UserDetailed
  @override
  final int uploadLimit;

  /// From UserDetailed
  @override
  final String profileAbout;

  /// From UserDetailed
  @override
  final String profileArtInfo;
  // #endregion Fields

  UserLoggedInDetail({
    required this.wikiPageVersionCount,
    required this.artistVersionCount,
    required this.poolVersionCount,
    required this.forumPostCount,
    required this.commentCount,
    required this.flagCount,
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
    required this.uploadLimit,
    required this.profileAbout,
    required this.profileArtInfo,
    required super.favoriteCount,
    required super.id,
    required super.createdAt,
    required super.name,
    required super.level,
    required super.baseUploadLimit,
    required super.postUploadCount,
    required super.postUpdateCount,
    required super.noteUpdateCount,
    required super.isBanned,
    required super.canApprovePosts,
    required super.canUploadFree,
    required super.levelString,
    required super.avatarId,
    required super.blacklistUsers,
    required super.descriptionCollapsedInitially,
    required super.hideComments,
    required super.showHiddenComments,
    required super.showPostStatistics,
    required super.receiveEmailNotifications,
    required super.enableKeyboardNavigation,
    required super.enablePrivacyMode,
    required super.styleUsernames,
    required super.enableAutoComplete,
    required super.disableCroppedThumbnails,
    required super.enableSafeMode,
    required super.disableResponsiveMode,
    required super.noFlagging,
    required super.disableUserDmails,
    required super.enableCompactUploader,
    required super.replacementsBeta,
    required super.updatedAt,
    required super.email,
    required super.lastLoggedInAt,
    required super.lastForumReadAt,
    required super.recentTags,
    required super.commentThreshold,
    required super.defaultImageSize,
    required super.favoriteTags,
    required super.blacklistedTags,
    required super.timeZone,
    required super.perPage,
    required super.customStyle,
    required super.apiRegenMultiplier,
    required super.apiBurstLimit,
    required super.remainingApiLimit,
    required super.statementTimeout,
    required super.favoriteLimit,
    required super.tagQueryLimit,
    required super.hasMail,
  });

  UserLoggedInDetail.fromJson(super.json)
      : wikiPageVersionCount = json["wiki_page_version_count"],
        artistVersionCount = json["artist_version_count"],
        poolVersionCount = json["pool_version_count"],
        forumPostCount = json["forum_post_count"],
        commentCount = json["comment_count"],
        flagCount = json["flag_count"],
        positiveFeedbackCount = json["positive_feedback_count"],
        neutralFeedbackCount = json["neutral_feedback_count"],
        negativeFeedbackCount = json["negative_feedback_count"],
        uploadLimit = json["upload_limit"],
        profileAbout = json["profile_about"],
        profileArtInfo = json["profile_artinfo"],
        super.fromJson();
  factory UserLoggedInDetail.fromRawJson(String str) =>
      UserLoggedInDetail.fromJson(dc.json.decode(str));

  @override
  UserLoggedInDetail copyWith({
    int? wikiPageVersionCount,
    int? artistVersionCount,
    int? poolVersionCount,
    int? forumPostCount,
    int? commentCount,
    int? flagCount,
    int? favoriteCount,
    int? positiveFeedbackCount,
    int? neutralFeedbackCount,
    int? negativeFeedbackCount,
    int? uploadLimit,
    String? profileAbout,
    String? profileArtInfo,
    int? id,
    DateTime? createdAt,
    String? name,
    int? level,
    int? baseUploadLimit,
    int? postUploadCount,
    int? postUpdateCount,
    int? noteUpdateCount,
    bool? isBanned,
    bool? canApprovePosts,
    bool? canUploadFree,
    UserLevel? levelString,
    int? avatarId = -1,
    bool? blacklistUsers,
    bool? descriptionCollapsedInitially,
    bool? hideComments,
    bool? showHiddenComments,
    bool? showPostStatistics,
    bool? receiveEmailNotifications,
    bool? enableKeyboardNavigation,
    bool? enablePrivacyMode,
    bool? styleUsernames,
    bool? enableAutoComplete,
    bool? disableCroppedThumbnails,
    bool? enableSafeMode,
    bool? disableResponsiveMode,
    bool? noFlagging,
    bool? disableUserDmails,
    bool? enableCompactUploader,
    bool? replacementsBeta,
    DateTime? updatedAt,
    String? email,
    DateTime? lastLoggedInAt,
    DateTime? lastForumReadAt,
    String? recentTags,
    int? commentThreshold,
    DefaultImageSize? defaultImageSize,
    String? favoriteTags,
    String? blacklistedTags,
    String? timeZone,
    int? perPage,
    String? customStyle,
    int? apiRegenMultiplier,
    int? apiBurstLimit,
    int? remainingApiLimit,
    int? statementTimeout,
    int? favoriteLimit,
    int? tagQueryLimit,
    bool? hasMail,
  }) =>
      UserLoggedInDetail(
        wikiPageVersionCount: wikiPageVersionCount ?? this.wikiPageVersionCount,
        artistVersionCount: artistVersionCount ?? this.artistVersionCount,
        poolVersionCount: poolVersionCount ?? this.poolVersionCount,
        forumPostCount: forumPostCount ?? this.forumPostCount,
        commentCount: commentCount ?? this.commentCount,
        flagCount: flagCount ?? this.flagCount,
        favoriteCount: favoriteCount ?? this.favoriteCount,
        positiveFeedbackCount:
            positiveFeedbackCount ?? this.positiveFeedbackCount,
        neutralFeedbackCount: neutralFeedbackCount ?? this.neutralFeedbackCount,
        negativeFeedbackCount:
            negativeFeedbackCount ?? this.negativeFeedbackCount,
        uploadLimit: uploadLimit ?? this.uploadLimit,
        profileAbout: profileAbout ?? this.profileAbout,
        profileArtInfo: profileArtInfo ?? this.profileArtInfo,
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        level: level ?? this.level,
        baseUploadLimit: baseUploadLimit ?? this.baseUploadLimit,
        postUploadCount: postUploadCount ?? this.postUploadCount,
        postUpdateCount: postUpdateCount ?? this.postUpdateCount,
        noteUpdateCount: noteUpdateCount ?? this.noteUpdateCount,
        isBanned: isBanned ?? this.isBanned,
        canApprovePosts: canApprovePosts ?? this.canApprovePosts,
        canUploadFree: canUploadFree ?? this.canUploadFree,
        levelString: levelString ?? this.levelString,
        avatarId: avatarId == -1 ? this.avatarId : avatarId,
        blacklistUsers: blacklistUsers ?? this.blacklistUsers,
        descriptionCollapsedInitially:
            descriptionCollapsedInitially ?? this.descriptionCollapsedInitially,
        hideComments: hideComments ?? this.hideComments,
        showHiddenComments: showHiddenComments ?? this.showHiddenComments,
        showPostStatistics: showPostStatistics ?? this.showPostStatistics,
        receiveEmailNotifications:
            receiveEmailNotifications ?? this.receiveEmailNotifications,
        enableKeyboardNavigation:
            enableKeyboardNavigation ?? this.enableKeyboardNavigation,
        enablePrivacyMode: enablePrivacyMode ?? this.enablePrivacyMode,
        styleUsernames: styleUsernames ?? this.styleUsernames,
        enableAutoComplete: enableAutoComplete ?? this.enableAutoComplete,
        disableCroppedThumbnails:
            disableCroppedThumbnails ?? this.disableCroppedThumbnails,
        enableSafeMode: enableSafeMode ?? this.enableSafeMode,
        disableResponsiveMode:
            disableResponsiveMode ?? this.disableResponsiveMode,
        noFlagging: noFlagging ?? this.noFlagging,
        disableUserDmails: disableUserDmails ?? this.disableUserDmails,
        enableCompactUploader:
            enableCompactUploader ?? this.enableCompactUploader,
        replacementsBeta: replacementsBeta ?? this.replacementsBeta,
        updatedAt: updatedAt ?? this.updatedAt,
        email: email ?? this.email,
        lastLoggedInAt: lastLoggedInAt ?? this.lastLoggedInAt,
        lastForumReadAt: lastForumReadAt ?? this.lastForumReadAt,
        recentTags: recentTags ?? this.recentTags,
        commentThreshold: commentThreshold ?? this.commentThreshold,
        defaultImageSize: defaultImageSize ?? this.defaultImageSize,
        favoriteTags: favoriteTags ?? this.favoriteTags,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        timeZone: timeZone ?? this.timeZone,
        perPage: perPage ?? this.perPage,
        customStyle: customStyle ?? this.customStyle,
        apiRegenMultiplier: apiRegenMultiplier ?? this.apiRegenMultiplier,
        apiBurstLimit: apiBurstLimit ?? this.apiBurstLimit,
        remainingApiLimit: remainingApiLimit ?? this.remainingApiLimit,
        statementTimeout: statementTimeout ?? this.statementTimeout,
        favoriteLimit: favoriteLimit ?? this.favoriteLimit,
        tagQueryLimit: tagQueryLimit ?? this.tagQueryLimit,
        hasMail: hasMail ?? this.hasMail,
      );

  @override
  UserLoggedInDetail copyWithInstance(User? other) {
    var userD = other is UserDetailed ? other : null;
    var userL = other is UserLoggedIn ? other : null;
    return UserLoggedInDetail(
      wikiPageVersionCount: userD?.wikiPageVersionCount ?? wikiPageVersionCount,
      artistVersionCount: userD?.artistVersionCount ?? artistVersionCount,
      poolVersionCount: userD?.poolVersionCount ?? poolVersionCount,
      forumPostCount: userD?.forumPostCount ?? forumPostCount,
      commentCount: userD?.commentCount ?? commentCount,
      flagCount: userD?.flagCount ?? flagCount,
      favoriteCount:
          userL?.favoriteCount ?? userD?.favoriteCount ?? favoriteCount,
      positiveFeedbackCount:
          userD?.positiveFeedbackCount ?? positiveFeedbackCount,
      neutralFeedbackCount: userD?.neutralFeedbackCount ?? neutralFeedbackCount,
      negativeFeedbackCount:
          userD?.negativeFeedbackCount ?? negativeFeedbackCount,
      uploadLimit: userD?.uploadLimit ?? uploadLimit,
      profileAbout: userD?.profileAbout ?? profileAbout,
      profileArtInfo: userD?.profileArtInfo ?? profileArtInfo,
      id: other?.id ?? id,
      createdAt: other?.createdAt ?? createdAt,
      name: other?.name ?? name,
      level: other?.level ?? level,
      baseUploadLimit: other?.baseUploadLimit ?? baseUploadLimit,
      postUploadCount: other?.postUploadCount ?? postUploadCount,
      postUpdateCount: other?.postUpdateCount ?? postUpdateCount,
      noteUpdateCount: other?.noteUpdateCount ?? noteUpdateCount,
      isBanned: other?.isBanned ?? isBanned,
      canApprovePosts: other?.canApprovePosts ?? canApprovePosts,
      canUploadFree: other?.canUploadFree ?? canUploadFree,
      levelString: other?.levelString ?? levelString,
      avatarId: other == null ? avatarId : other.avatarId,
      blacklistUsers: userL?.blacklistUsers ?? blacklistUsers,
      descriptionCollapsedInitially:
          userL?.descriptionCollapsedInitially ?? descriptionCollapsedInitially,
      hideComments: userL?.hideComments ?? hideComments,
      showHiddenComments: userL?.showHiddenComments ?? showHiddenComments,
      showPostStatistics: userL?.showPostStatistics ?? showPostStatistics,
      receiveEmailNotifications:
          userL?.receiveEmailNotifications ?? receiveEmailNotifications,
      enableKeyboardNavigation:
          userL?.enableKeyboardNavigation ?? enableKeyboardNavigation,
      enablePrivacyMode: userL?.enablePrivacyMode ?? enablePrivacyMode,
      styleUsernames: userL?.styleUsernames ?? styleUsernames,
      enableAutoComplete: userL?.enableAutoComplete ?? enableAutoComplete,
      disableCroppedThumbnails:
          userL?.disableCroppedThumbnails ?? disableCroppedThumbnails,
      enableSafeMode: userL?.enableSafeMode ?? enableSafeMode,
      disableResponsiveMode:
          userL?.disableResponsiveMode ?? disableResponsiveMode,
      noFlagging: userL?.noFlagging ?? noFlagging,
      disableUserDmails: userL?.disableUserDmails ?? disableUserDmails,
      enableCompactUploader:
          userL?.enableCompactUploader ?? enableCompactUploader,
      replacementsBeta: userL?.replacementsBeta ?? replacementsBeta,
      updatedAt: userL?.updatedAt ?? updatedAt,
      email: userL?.email ?? email,
      lastLoggedInAt: userL?.lastLoggedInAt ?? lastLoggedInAt,
      lastForumReadAt: userL?.lastForumReadAt ?? lastForumReadAt,
      recentTags: userL?.recentTags ?? recentTags,
      commentThreshold: userL?.commentThreshold ?? commentThreshold,
      defaultImageSize: userL?.defaultImageSize ?? defaultImageSize,
      favoriteTags: userL?.favoriteTags ?? favoriteTags,
      blacklistedTags: userL?.blacklistedTags ?? blacklistedTags,
      timeZone: userL?.timeZone ?? timeZone,
      perPage: userL?.perPage ?? perPage,
      customStyle: userL?.customStyle ?? customStyle,
      apiRegenMultiplier: userL?.apiRegenMultiplier ?? apiRegenMultiplier,
      apiBurstLimit: userL?.apiBurstLimit ?? apiBurstLimit,
      remainingApiLimit: userL?.remainingApiLimit ?? remainingApiLimit,
      statementTimeout: userL?.statementTimeout ?? statementTimeout,
      favoriteLimit: userL?.favoriteLimit ?? favoriteLimit,
      tagQueryLimit: userL?.tagQueryLimit ?? tagQueryLimit,
      hasMail: userL?.hasMail ?? hasMail,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "wiki_page_version_count": wikiPageVersionCount,
        "artist_version_count": artistVersionCount,
        "pool_version_count": poolVersionCount,
        "forum_post_count": forumPostCount,
        "comment_count": commentCount,
        "flag_count": flagCount,
        "positive_feedback_count": positiveFeedbackCount,
        "neutral_feedback_count": neutralFeedbackCount,
        "negative_feedback_count": negativeFeedbackCount,
        "upload_limit": uploadLimit,
        "profile_about": profileAbout,
        "profile_artinfo": profileArtInfo,
      }..addAll(super.toJson());

  @override
  String toRawJson() => dc.json.encode(toJson());
}

mixin UserMixin on model.BaseModel {
  int? get avatarId;
  int get baseUploadLimit;
  bool get canApprovePosts;
  bool get canUploadFree;
  DateTime get createdAt;
  int get id;
  bool get isBanned;
  int get level;
  UserLevel get levelString;
  String get name;
  int get noteUpdateCount;
  int get postUpdateCount;
  int get postUploadCount;
}

/// Result of successful vote call.
///
class VoteResult {
  /// The number of times voted up.
  final int up;

  /// A negative number representing the number of times voted down.
  final int down;

  /// The total score (up + down).
  final int score;

  /// Our score is 1 (for upvoted), 0 (for no vote), or -1 (for downvoted).
  final int ourScore;

  const VoteResult({
    required this.up,
    required this.down,
    required this.score,
    required this.ourScore,
  });
  VoteResult.fromJson(Map<String, dynamic> json)
      : this(
          up: json["up"] as int,
          down: json["down"] as int,
          score: json["score"] as int,
          ourScore: json["our_score"] as int,
        );
  VoteResult.fromJsonRaw(String json) : this.fromJson(dc.jsonDecode(json));

  VoteResult copyWith({
    int? up,
    int? down,
    int? score,
    int? ourScore,
  }) =>
      VoteResult(
        up: up ?? this.up,
        down: down ?? this.down,
        score: score ?? this.score,
        ourScore: ourScore ?? this.ourScore,
      );

  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "score": score,
        "our_score": ourScore,
      };
}

class WikiPage extends _PIdDatesBase {
  final String title;
  final String body;
  final int creatorId;
  final bool isLocked;
  final int? updaterId;
  final bool isDeleted;
  final List<String> otherNames;
  final int? parent;
  final String creatorName;
  final int categoryId;

  const WikiPage({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.title,
    required this.body,
    required this.creatorId,
    required this.isLocked,
    required this.updaterId,
    required this.isDeleted,
    required this.otherNames,
    required this.parent,
    required this.creatorName,
    required this.categoryId,
  });
  WikiPage.fromJson(super.json)
      : title = json["title"],
        body = json["body"],
        creatorId = json["creator_id"],
        isLocked = json["is_locked"],
        updaterId = json["updater_id"],
        isDeleted = json["is_deleted"],
        otherNames = (json["other_names"] as List).cast<String>(),
        parent = json["parent"],
        creatorName = json["creator_name"],
        categoryId = json["category_id"],
        super.fromJson();
  factory WikiPage.fromRawJson(String json) {
    final r = dc.jsonDecode(json);
    return WikiPage.fromJson(r is List ? r.first : r);
  }
  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "title": title,
      "body": body,
      "creator_id": creatorId,
      "is_locked": isLocked,
      "updater_id": updaterId,
      "is_deleted": isDeleted,
      "other_names": otherNames,
      "parent": parent,
      "creator_name": creatorName,
      "category_id": categoryId,
    });

  static Iterable<WikiPage> fromRawJsonResults(String json) {
    final r = dc.jsonDecode(json);
    return r is List
        ? r.map((e) => WikiPage.fromJson(e))
        : [WikiPage.fromJson(r)];
  }
}

abstract interface class _PIdDatesBase with model.BaseModel {
  /// The ID number of the item.
  final int id;

  /// The time the item was created in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final DateTime createdAt;

  /// The time the item was last updated in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final DateTime updatedAt;
  const _PIdDatesBase({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  _PIdDatesBase.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        createdAt = DateTime.parse(json["created_at"]),
        updatedAt = DateTime.parse(json["updated_at"]);
  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

abstract interface class _PNameIdDatesBase extends _PIdDatesBase {
  final String name;
  const _PNameIdDatesBase({
    required this.name,
    required super.id,
    required super.createdAt,
    required super.updatedAt,
  });

  _PNameIdDatesBase.fromJson(super.json)
      : name = json["name"],
        super.fromJson();
  @override
  Map<String, dynamic> toJson() => super.toJson()..addAll({"name": name});
}

abstract interface class _PNameIdDatesIsActiveBase extends _PNameIdDatesBase {
  final bool isActive;
  const _PNameIdDatesIsActiveBase({
    required super.name,
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.isActive,
  }) : super();

  _PNameIdDatesIsActiveBase.fromJson(super.json)
      : isActive = json["isActive"],
        super.fromJson();
  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll({"is_active": isActive});
}
