import 'dart:convert' as dc;
import 'general_enums.dart' hide ApiQueryParameter;
import 'model.dart' as model;

class Pool extends model.Pool {
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

  String get searchById => 'pool:$id';
  String get searchByName => 'pool:$name';

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

  factory Pool.fromRawJson(String str) => Pool.fromJson(dc.json.decode(str));

  factory Pool.fromJson(Map<String, dynamic> json) => Pool(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        creatorId: json["creator_id"],
        description: json["description"],
        isActive: json["is_active"],
        category: PoolCategory.fromJson(json["category"]),
        postIds: (json["post_ids"] as List).cast<int>(),
        creatorName: json["creator_name"],
        postCount: json["post_count"],
      );
}

class Note with model.BaseModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
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
    required this.id,
    required this.createdAt,
    required this.updatedAt,
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

  factory Note.fromRawJson(String str) => Note.fromJson(dc.json.decode(str));

  /// Safely handles the special value when a search yields no results.
  static Note? fromJsonSafe(Map<String, dynamic> json) =>
      json["notes"]?.runtimeType == List ? null : Note.fromJson(json);

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        creatorId: json["creator_id"],
        x: json["x"],
        y: json["y"],
        width: json["width"],
        height: json["height"],
        version: json["version"],
        isActive: json["is_active"],
        postId: json["post_id"],
        body: json["body"],
        creatorName: json["creator_name"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
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
      };
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

  factory User.fromRawJson(String str) {
    var t = dc.json.decode(str);
    return (t is List) ? User.fromJson(t[0]) : User.fromJson(t);
  }

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

  factory UserDetailed.fromRawJson(String str) =>
      UserDetailed.fromJson(dc.json.decode(str));

  @override
  String toRawJson() => dc.json.encode(toJson());

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

  factory UserLoggedIn.fromRawJson(String str) {
    var t = dc.json.decode(str);
    return (t is List) ? UserLoggedIn.fromJson(t[0]) : UserLoggedIn.fromJson(t);
  }

  @override
  String toRawJson() => dc.json.encode(toJson());

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

  factory UserLoggedInDetail.fromRawJson(String str) =>
      UserLoggedInDetail.fromJson(dc.json.decode(str));

  @override
  String toRawJson() => dc.json.encode(toJson());

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
}

mixin UserMixin {
  int get id;
  DateTime get createdAt;
  String get name;
  int get level;
  int get baseUploadLimit;
  int get postUploadCount;
  int get postUpdateCount;
  int get noteUpdateCount;
  bool get isBanned;
  bool get canApprovePosts;
  bool get canUploadFree;
  UserLevel get levelString;
  int? get avatarId;
}
mixin UserDetailedMixin on UserMixin {
  int get wikiPageVersionCount;
  int get artistVersionCount;
  int get poolVersionCount;
  int get forumPostCount;
  int get commentCount;
  int get flagCount;
  int get favoriteCount;
  int get positiveFeedbackCount;
  int get neutralFeedbackCount;
  int get negativeFeedbackCount;
  int get uploadLimit;
  String get profileAbout;
  String get profileArtInfo;
}
mixin CurrentUser on UserMixin {
  bool get blacklistUsers;
  bool get descriptionCollapsedInitially;
  bool get hideComments;
  bool get showHiddenComments;
  bool get showPostStatistics;
  bool get receiveEmailNotifications;
  bool get enableKeyboardNavigation;
  bool get enablePrivacyMode;
  bool get styleUsernames;
  bool get enableAutoComplete;
  bool get enableSafeMode;
  bool get disableResponsiveMode;
  bool get noFlagging;
  bool get disableUserDmails;
  bool get enableCompactUploader;
  bool get replacementsBeta;
  DateTime get updatedAt;
  String get email;
  DateTime get lastLoggedInAt;
  DateTime get lastForumReadAt;
  String get recentTags;
  int get commentThreshold;
  DefaultImageSize get defaultImageSize;
  String get favoriteTags;
  String get blacklistedTags;

  /// https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  String get timeZone;
  int get perPage;
  String get customStyle;
  int get favoriteCount;
  int get apiRegenMultiplier;
  int get apiBurstLimit;
  int get remainingApiLimit;
  int get statementTimeout;
  int get favoriteLimit;
  int get tagQueryLimit;
  bool get hasMail;
  bool get disableCroppedThumbnails;
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

Type findUserModelType(Map<String, dynamic> json) =>
    json["wiki_page_version_count"] != null
        ? json["api_burst_limit"] != null
            ? UserLoggedInDetail
            : UserDetailed
        : json["api_burst_limit"] != null
            ? UserLoggedIn
            : User;

/// Gets the mot specific user model based on the provided [json].
User userFromJson(Map<String, dynamic> json) =>
    json["wiki_page_version_count"] != null
        ? json["api_burst_limit"] != null
            ? UserLoggedInDetail.fromJson(json)
            : UserDetailed.fromJson(json)
        : json["api_burst_limit"] != null
            ? UserLoggedIn.fromJson(json)
            : User.fromJson(json);

mixin UserHelpers on model.UserLoggedIn {
  Set<String> get blacklistedTagsSet => blacklistedTagsList.toSet();
  List<String> get blacklistedTagsList => blacklistedTags.split(RegExp(r'\s'));
}

/// https://e621.net/post_sets.json?35356
class PostSet {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int creatorId;
  final bool isPublic;
  final String name;
  final String shortname;
  final String description;
  final int postCount;
  final bool transferOnDelete;
  final List<int> postIds;

  String get searchById => 'set:$id';
  String get searchByShortname => 'set:$shortname';

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

  factory PostSet.fromRawJson(String str) =>
      PostSet.fromJson(dc.json.decode(str));

  String toRawJson() => dc.json.encode(toJson());

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
}

class Post {
  // #region Json Fields
  /// The ID number of the post.
  final int id;

  /// The time the post was created in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final DateTime createdAt;

  /// The time the post was last updated in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final DateTime updatedAt;

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

  Post({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
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

  factory Post.fromRawJson(String json) {
    var t = dc.jsonDecode(json);
    try {
      return Post.fromJson(t);
    } catch (e) {
      return Post.fromJson(t["post"]);
    }
  }
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

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"] as int,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        file: File.fromJson(json["file"]),
        preview: Preview.fromJson(json["preview"]),
        sample: Sample.fromJson(json["sample"]),
        score: Score.fromJson(json["score"]),
        tags: PostTags.fromJson(json["tags"]),
        lockedTags: (json["locked_tags"] as List).cast<String>(),
        changeSeq: json["change_seq"] as int,
        flags: PostBitFlags.fromJson(json["flags"]),
        rating: json["rating"] as String,
        favCount: json["fav_count"] as int,
        sources: (json["sources"] as List).cast<String>(),
        pools: (json["pools"] as List).cast<int>(),
        relationships: PostRelationships.fromJson(json["relationships"]),
        approverId: json["approver_id"] as int?,
        uploaderId: json["uploader_id"] as int,
        description: json["description"] as String,
        commentCount: json["comment_count"] as int,
        isFavorited: json["is_favorited"] as bool,
        hasNotes: json["has_notes"] as bool,
        duration: json["duration"] as num?,
      );
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
  File._useParentFromJson({
    required this.ext,
    required this.size,
    required this.md5,
    required Map<String, dynamic> json,
  }) : super.fromJsonGen(json);
  factory File.fromJson(Map<String, dynamic> json) => File._useParentFromJson(
        ext: json["ext"] as String,
        size: json["size"] as int,
        md5: json["md5"] as String,
        json: json,
      );
  @override
  File copyWith({
    String? ext,
    int? size,
    String? md5,
    String? url,
    int? width,
    int? height,
  }) =>
      File(
        ext: ext ?? this.ext,
        size: size ?? this.size,
        md5: md5 ?? this.md5,
        height: height ?? this.height,
        url: url ?? this.url,
        width: width ?? this.width,
      );
}

class Preview {
  /// The width of the file.
  final int width;

  /// The height of the file.
  final int height;

  /// {@template E6Preview.url}
  ///
  /// The URL where the preview file is hosted on E6
  ///
  /// If the post is a video, this is a preview image from the video
  ///
  /// If auth is not provided, [this may be null][1]. This is currently replaced
  /// with an empty string in from json.
  ///
  /// [1]: https://e621.net/help/global_blacklist
  ///
  /// {@endtemplate}
  final String url;

  const Preview({
    required this.width,
    required this.height,
    required this.url,
  });
  factory Preview.fromJson(Map<String, dynamic> json) => Preview(
        width: json["width"],
        height: json["height"],
        url: json["url"] as String? ?? "",
      );
  Preview.fromJsonGen(Map<String, dynamic> json)
      : width = json["width"],
        height = json["height"],
        url = json["url"] as String? ?? "";
  Preview copyWith({
    String? url,
    int? width,
    int? height,
  }) =>
      Preview(
        height: height ?? this.height,
        url: url ?? this.url,
        width: width ?? this.width,
      );
}

class Sample extends Preview {
  /// If the post has a sample/thumbnail or not. (True/False)
  final bool has;

  const Sample({
    required this.has,
    required super.width,
    required super.height,
    required super.url,
  });
  Sample._useParentFromJson({
    required this.has,
    required Map<String, dynamic> json,
  }) : super.fromJsonGen(json);
  factory Sample.fromJson(Map<String, dynamic> json) =>
      Sample._useParentFromJson(
        has: json["has"],
        json: json,
      );
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
  factory Score.fromJsonRaw(String json) => Score.fromJson(dc.jsonDecode(json));
  factory Score.fromJson(Map<String, dynamic> json) => Score(
        up: json["up"] as int,
        down: json["down"] as int,
        total: json["total"] as int,
      );

  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "total": total,
      };

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
}

/// Result of successful vote call.
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
  factory VoteResult.fromJsonRaw(String json) =>
      VoteResult.fromJson(dc.jsonDecode(json));
  factory VoteResult.fromJson(Map<String, dynamic> json) => VoteResult(
        up: json["up"] as int,
        down: json["down"] as int,
        score: json["score"] as int,
        ourScore: json["our_score"] as int,
      );

  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "score": score,
        "our_score": ourScore,
      };

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
}

/// TODO: Cancelling an unvote returns ourScore as 0. Change to reflect.
class UpdatedScore extends Score implements VoteResult {
  /// The total score (up + down).
  @override
  int get score => total;

  /// Our score is 1 (for upvoted), 0 (for no vote), or -1 (for downvoted).
  @override
  final int ourScore;

  /* /// Cast vote.
  @override
  final int? voteCast;

  /// Our score is 1 (for upvoted), 0 (for no vote), or -1 (for downvoted).
  int? get ourScoreTrue => noUnvote != null ? ourScore == 0 && noUnvote! ?  : null;

  @override
  final bool? noUnvote; */

  bool get isUpvoted => ourScore > 0;
  bool get isDownvoted => ourScore < 0;
  bool get isVotedOn => ourScore != 0;

  /// `true` if the user upvoted this post, `false` if the user downvoted this post, `null` if the user didn't vote on this post.
  bool? get voteState => switch (ourScore) {
        > 0 => true,
        < 0 => false,
        == 0 => null,
        _ => null,
      };

  const UpdatedScore.inherited({
    required super.up,
    required super.down,
    required super.total,
    required this.ourScore,
    /* this.castVote,
    this.noUnvote, */
  });
  const UpdatedScore({
    required super.up,
    required super.down,
    required int score,
    required this.ourScore,
    /* this.castVote,
    this.noUnvote, */
  }) : super(total: score);
  factory UpdatedScore.fromJsonRaw(String json) =>
      UpdatedScore.fromJson(dc.jsonDecode(json));
  UpdatedScore.fromJson(Map<String, dynamic> json)
      : this(
          up: json["up"] as int,
          down: json["down"] as int,
          score: json["score"] as int,
          ourScore: json["our_score"] as int,
        );

  @override
  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "score": score,
        "total": total,
        "our_score": ourScore,
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

class PostTags {
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

  // #region Undocumented
  /// A JSON array of all the copyright tags on the post.
  final List<String> copyright;
  // #endregion Undocumented

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
  factory PostTags.fromJson(Map<String, dynamic> json) => PostTags(
        general: (json["general"] as List).cast<String>(),
        species: (json["species"] as List).cast<String>(),
        character: (json["character"] as List).cast<String>(),
        artist: (json["artist"] as List).cast<String>(),
        invalid: (json["invalid"] as List).cast<String>(),
        lore: (json["lore"] as List).cast<String>(),
        meta: (json["meta"] as List).cast<String>(),
        copyright: (json["copyright"] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        "general": List<dynamic>.from(general.map((x) => x)),
        "species": List<dynamic>.from(species.map((x) => x)),
        "character": List<dynamic>.from(character.map((x) => x)),
        "artist": List<dynamic>.from(artist.map((x) => x)),
        "invalid": List<dynamic>.from(invalid.map((x) => x)),
        "lore": List<dynamic>.from(lore.map((x) => x)),
        "meta": List<dynamic>.from(meta.map((x) => x)),
        "copyright": List<dynamic>.from(copyright.map((x) => x)),
      };
}

class PostFlags {
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
  factory PostFlags.fromJson(Map<String, dynamic> json) => PostFlags(
        pending: json["pending"] as bool,
        flagged: json["flagged"] as bool,
        noteLocked: json["note_locked"] as bool,
        statusLocked: json["status_locked"] as bool,
        ratingLocked: json["rating_locked"] as bool,
        deleted: json["deleted"] as bool,
      );
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

  final int bit;
  const PostFlag({required this.bit});

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
  static int toInt(PostFlag f) => f.bit;
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

  bool hasFlag(int f) => (PostFlag.toInt(this) & f) == PostFlag.toInt(this);
}

class PostBitFlags implements PostFlags {
  @override
  bool get pending => (_data & pendingFlag) == pendingFlag;

  @override
  bool get flagged => (_data & flaggedFlag) == flaggedFlag;

  @override
  bool get noteLocked => (_data & noteLockedFlag) == noteLockedFlag;

  @override
  bool get statusLocked => (_data & statusLockedFlag) == statusLockedFlag;

  @override
  bool get ratingLocked => (_data & ratingLockedFlag) == ratingLockedFlag;

  @override
  bool get deleted => (_data & deletedFlag) == deletedFlag;
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
  factory PostBitFlags.fromJson(Map<String, dynamic> json) => PostBitFlags(
        pending: json["pending"] as bool,
        flagged: json["flagged"] as bool,
        noteLocked: json["note_locked"] as bool,
        statusLocked: json["status_locked"] as bool,
        ratingLocked: json["rating_locked"] as bool,
        deleted: json["deleted"] as bool,
      );
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

  static const int pendingFlag = 1; //int.parse("000001", radix: 2);
  static const int flaggedFlag = 2; //int.parse("000010", radix: 2);
  static const int noteLockedFlag = 4; //int.parse("000100", radix: 2);
  static const int statusLockedFlag = 8; //int.parse("001000", radix: 2);
  static const int ratingLockedFlag = 16; //int.parse("010000", radix: 2);
  static const int deletedFlag = 32; //int.parse("100000", radix: 2);
}

class PostRelationships {
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

  bool get hasParent => parentId != null;

  const PostRelationships({
    required this.parentId,
    required this.hasChildren,
    required this.hasActiveChildren,
    required this.children,
  });
  factory PostRelationships.fromJson(Map<String, dynamic> json) =>
      PostRelationships(
        parentId: json["parent_id"] as int?,
        hasChildren: json["has_children"] as bool,
        hasActiveChildren: json["has_active_children"] as bool,
        children: (json["children"] as List).cast<int>(),
      );
}

class Alternates {
  // Alternate? the480P;
  // Alternate? the720P;
  Alternate? original;
  Map<String, Alternate> alternates;

  Alternates({
    // this.the480P,
    // this.the720P,
    Alternate? original,
    required this.alternates,
  }) : original = original ?? alternates["original"];

  factory Alternates.fromJson(Map<String, dynamic> json) => Alternates(
        // the480P: json["480p"] == null ? null : Alternate.fromJson(json["480p"]),
        // the720P: json["720p"] == null ? null : Alternate.fromJson(json["720p"]),
        original: json["original"] == null
            ? null
            : Alternate.fromJson(json["original"]),
        alternates: {
          for (var e in json.entries) e.key: Alternate.fromJson(e.value)
        },
      );

  // Map<String, dynamic> toJson() => {
  //       "480p": the480P?.toJson(),
  //       "720p": the720P?.toJson(),
  //       "original": original?.toJson(),
  //     };
  Map<String, dynamic> toJson() => alternates;
}

class Alternate {
  int height;
  String type;

  /// 0. the webm version (almost always null on original)
  /// 1. the mp4 version
  List<String?> urls;
  int width;

  Alternate({
    required this.height,
    required this.type,
    required this.urls,
    required this.width,
  });

  factory Alternate.fromJson(Map<String, dynamic> json) => Alternate(
        height: json["height"],
        type: json["type"],
        urls: List<String?>.from(json["urls"].map((x) => x)),
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "type": type,
        "urls": List<dynamic>.from(urls.map((x) => x)),
        "width": width,
      };
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

class WikiPage {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
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

  WikiPage({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
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
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
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
      };
  factory WikiPage.fromJson(Map<String, dynamic> json) => WikiPage(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        title: json["title"],
        body: json["body"],
        creatorId: json["creator_id"],
        isLocked: json["is_locked"],
        updaterId: json["updater_id"],
        isDeleted: json["is_deleted"],
        otherNames: (json["other_names"] as List).cast<String>(),
        parent: json["parent"],
        creatorName: json["creator_name"],
        categoryId: json["category_id"],
      );

  factory WikiPage.fromRawJson(String json) {
    final r = dc.jsonDecode(json);
    return WikiPage.fromJson(r is List ? r.first : r);
  }
  static Iterable<WikiPage> fromRawJsonResults(String json) {
    final r = dc.jsonDecode(json);
    return r is List
        ? r.map((e) => WikiPage.fromJson(e))
        : [WikiPage.fromJson(r)];
  }

  Map<String, dynamic> fromJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
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
      };
}

/// Database files contain upwards of a million entries. In cases where the
/// [TagDbEntry.id] is not important, this class may be used to minimize the
/// memory and performance cost of parsing and storing a large number of entries.
class TagDbEntrySlim implements Comparable<TagDbEntrySlim> {
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
  TagDbEntrySlim.fromJson(Map<String, dynamic> json)
      : name = json["name"] as String,
        category = json["category"] as TagCategory,
        postCount = json["post_count"] as int;
  Map<String, dynamic> toJson() => {
        "name": name,
        "category": category.index,
        "post_count": postCount,
      };
  TagDbEntrySlim.fromCsv(String csv)
      : name = csv.contains('"')
            ? csv.substring(csv.indexOf('"'), csv.lastIndexOf('"') + 1)
            : csv.split(",")[1],
        category = TagCategory.values[int.parse(csv.contains('"')
            ? csv.split(",")[csv.split(",").length - 2]
            : csv.split(",")[2])],
        postCount = int.parse(csv.split(",").last);
  static const csvHeader = "id,name,category,post_count";

  /// Database archives have upwards of a million entries. Use Flutter's
  /// [compute](https://api.flutter.dev/flutter/foundation/compute.html) or
  /// [Isolate.run](https://api.flutter.dev/flutter/dart-isolate/Isolate/run.html).
  static List<TagDbEntrySlim> parseCsv(String csv) => (csv.split("\n")
        ..removeAt(0)
        ..removeLast())
      .map(TagDbEntrySlim.fromCsv)
      .toList();
  @override
  int compareTo(TagDbEntrySlim other) => other.postCount - postCount;
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

/* class TagDbEntry implements TagDbEntrySlim {
  /// <numeric tag id>,
  final int id;

  /// <tag display name>,
  @override
  final String name;

  /// <numeric category id>,
  @override
  final TagCategory category;

  /// <# matching visible posts>,
  @override
  final int postCount;

  const TagDbEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.postCount,
  });
  TagDbEntry.fromJson(Map<String, dynamic> json)
      : id = json["id"] as int,
        name = json["name"] as String,
        category = json["category"] as TagCategory,
        postCount = json["post_count"] as int;
  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category.index,
        "post_count": postCount,
      };
  TagDbEntry.fromCsv(String csv)
      : id = int.parse(csv.split(",").first),
        name = csv.contains('"')
            ? csv.substring(csv.indexOf('"'), csv.lastIndexOf('"') + 1)
            : csv.split(",")[1],
        category = TagCategory.values[int.parse(csv.contains('"')
            ? csv.split(",")[csv.split(",").length - 2]
            : csv.split(",")[2])],
        postCount = int.parse(csv.split(",").last);
  String toCsv() => "$id,$name,${category.index},$postCount";
  static const csvHeader = "id,name,category,post_count";

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
    // if (t.length == 5) t = [t[0], t[1] + t[2], t[3], t[4]];
    if (t.length == 5) throw StateError("Shouldn't be possible");
    return t;
  }
} */
class TagDbEntry extends TagDbEntrySlim {
  /// <numeric tag id>,
  final int id;

  const TagDbEntry({
    required this.id,
    required super.name,
    required super.category,
    required super.postCount,
  });
  TagDbEntry.fromJson(super.json)
      : id = json["id"] as int,
        super.fromJson();
  @override
  Map<String, dynamic> toJson() => super.toJson()..addAll({"id": id});
  TagDbEntry.fromCsv(super.csv)
      : id = int.parse(csv.split(",").first),
        super.fromCsv();
  String toCsv() => "$id,$name,${category.index},$postCount";
  static const csvHeader = "id,name,category,post_count";

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

/// https://e621.wiki/#operations-Tags-searchTags
class Tag extends TagDbEntry {
  // /// <numeric tag id>,
  // final int id;

  // /// <tag display name>,
  // final String name;

  // /// <# matching visible posts>,
  // final int postCount;

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

class Comment {
  /// id
  final int id;

  /// created_at
  final DateTime createdAt;

  /// post_id
  final int postId;

  /// creator_id
  final int creatorId;

  /// body
  final String body;

  /// score
  final int score;

  /// updated_at
  final DateTime updatedAt;

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
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.creatorId,
    required this.body,
    required this.score,
    required this.updatedAt,
    required this.updaterId,
    required this.doNotBumpPost,
    required this.isHidden,
    required this.isSticky,
    required this.warningType,
    required this.warningUserId,
    required this.creatorName,
    required this.updaterName,
  });

  Comment.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        createdAt = DateTime.parse(json["created_at"]),
        postId = json["post_id"],
        creatorId = json["creator_id"],
        body = json["body"],
        score = json["score"],
        updatedAt = DateTime.parse(json["updated_at"]),
        updaterId = json["updater_id"],
        doNotBumpPost = json["do_not_bump_post"],
        isHidden = json["is_hidden"],
        isSticky = json["is_sticky"],
        warningType = json["warning_type"] != null
            ? WarningType(json["warning_type"])
            : null,
        warningUserId = json["warning_user_id"],
        creatorName = json["creator_name"],
        updaterName = json["updater_name"];
  factory Comment.fromRawJson(String json) {
    final r = dc.jsonDecode(json);
    return Comment.fromJson(r is List ? r.first : r);
  }
  static Iterable<Comment> fromRawJsonResults(String json) {
    final r = dc.jsonDecode(json);
    return r is List
        ? r.map((e) => Comment.fromJson(e))
        : r["comments"] == null
            ? [Comment.fromJson(r)]
            : (r["comments"] as List).map((e) => Comment.fromJson(e));
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "post_id": postId,
        "creator_id": creatorId,
        "body": body,
        "score": score,
        "updated_at": updatedAt,
        "updater_id": updaterId,
        "do_not_bump_post": doNotBumpPost,
        "is_hidden": isHidden,
        "is_sticky": isSticky,
        "warning_type": warningType?.query,
        "warning_user_id": warningUserId,
        "creator_name": creatorName,
        "updater_name": updaterName,
      };
}

class DTextResponse {
  final String html;
  final Map<int, DTextPost> posts;

  const DTextResponse({required this.html, required this.posts});

  DTextResponse.fromJson(Map<String, dynamic> json)
      : html = json["html"],
        posts = (json["posts"] as Map)
            .map((k, v) => MapEntry(k, DTextPost.fromJson(v)));
}

class DTextPost {
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

class ModifiablePostSets {
  final List<({String name, int id})> owned;
  final List<({String name, int id})> maintained;
  List<({String name, int id})> get all => owned + maintained;

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
  Map<String, dynamic> toJson() => {
        "maintained": maintained.map(elementToJson),
        "owned": owned.map(elementToJson),
      };
  static List elementToJson(({String name, int id}) e) => [e.name, e.id];
}
