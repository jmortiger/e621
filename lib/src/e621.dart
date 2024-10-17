import 'package:e621/e621.dart' show UserLoggedIn;
import 'package:http/http.dart' as http;

import 'credentials.dart';
import 'general_enums.dart' as ge;
import 'search_enums.dart' as se;

// #region URI
const hostNameSfw = "e926.net";
const hostNameNsfw = "e621.net";
final baseUriSfw = Uri.https(hostNameSfw);
final baseUriNsfw = Uri.https(hostNameNsfw);
Uri get baseUri => useNsfw ? baseUriNsfw : baseUriSfw;
String get baseHostName => useNsfw ? hostNameNsfw : hostNameSfw;

/// If `true`, the host used will be `e621.net`; otherwise,
/// it will be `e926.net`.
bool useNsfw = true;
// #endregion URI

const maxPageNumber = 750;
@Deprecated("Use maxPostSearchLimit")
const maxPostsPerSearch = maxPostSearchLimit;
/// The maximum value allowed for the limit parameter for a [initPostSearch].
const maxPostSearchLimit = 320;

/// If searching by page number, the max amount of posts that can be accessed.
const maxPostsPerSearchByPageNumber = maxPageNumber * maxPostSearchLimit;
const maxTagsPerSearch = 40;

// #region Credentials
String? activeUserAgent;
BaseCredentials? activeCredentials;

/// Adding the user agent appears to be disallowed on web, so this flag is
/// provided to cut out the multiple errors printed to the (browser) console.
bool addUserAgent = true;

bool validateCredentials(BaseCredentials? credentials,
        [bool throwIfNeeded = true]) =>
    ((credentials ?? activeCredentials) == null)
        ? throwIfNeeded
            ? throw ArgumentError.value(
                credentials,
                "credentials",
                "Either the static credentials or the argument credentials must be defined.",
              )
            : false
        : true;

BaseCredentials _getValidCredentials(BaseCredentials? credentials) =>
    credentials ??
    activeCredentials ??
    (throw ArgumentError.value(
      credentials,
      "credentials",
      "Either the static activeCredentials or the argument credentials must be non-null.",
    ));
// #endregion Credentials
// #region Helpers
String _getDbExportDate(DateTime dt) => dt.toIso8601String().substring(0, 10);
Map<String, String> _addUserAgentTo(
  Map<String, String> headers, [
  BaseCredentials? credentials,
]) =>
    !addUserAgent
        ? headers
        : activeUserAgent != null
            ? (headers..[AccessData.userAgentHeaderKey] = activeUserAgent!)
            : credentials is AccessData
                ? credentials.addToTyped(headers)
                : activeCredentials is AccessData
                    ? activeCredentials!.addToTyped(headers)
                    : headers;

// #region Base Init
http.Request _baseInitRequestCredentialsRequired({
  required String path,
  required String method,
  Map<String, dynamic>? queryParameters,
  BaseCredentials? credentials,
  bool useBodyFields = false,
}) {
  var uri = baseUri.replace(
      path: path,
      queryParameters:
          useBodyFields ? null : _prepareQueryParametersSafe(queryParameters));
  var req = http.Request(method, uri);
  _getValidCredentials(credentials).addToTyped(req.headers);
  _addUserAgentTo(req.headers);
  if (queryParameters != null && useBodyFields) {
    req.bodyFields =
        _prepareQueryParametersSafe(queryParameters)!.cast<String, String>();
  }
  return req;
}

http.Request _baseInitRequestCredentialsOptional({
  required String path,
  required String method,
  Map<String, dynamic>? queryParameters,
  BaseCredentials? credentials,
  bool useBodyFields = false,
}) {
  var uri = baseUri.replace(
      path: path,
      queryParameters:
          useBodyFields ? null : _prepareQueryParametersSafe(queryParameters));
  var req = http.Request(method, uri);
  (credentials ?? activeCredentials)?.addToTyped(req.headers);
  _addUserAgentTo(req.headers);
  if (queryParameters != null && useBodyFields) {
    req.bodyFields =
        _prepareQueryParametersSafe(queryParameters)!.cast<String, String>();
  }
  return req;
}

http.MultipartRequest _baseInitMultipartRequestCredentialsRequired({
  required String path,
  required String method,
  Map<String, dynamic>? queryParameters,
  BaseCredentials? credentials,
  bool useBodyFields = false,
  required http.MultipartFile file,
}) {
  var uri = baseUri.replace(
      path: path,
      queryParameters:
          useBodyFields ? null : _prepareQueryParametersSafe(queryParameters));
  var req = http.MultipartRequest(method, uri)..files.add(file);
  _getValidCredentials(credentials).addToTyped(req.headers);
  _addUserAgentTo(req.headers);
  if (queryParameters != null && useBodyFields) {
    req.fields.addAll(
        _prepareQueryParametersSafe(queryParameters)!.cast<String, String>());
  }
  return req;
}

http.MultipartRequest _baseInitMultipartRequestCredentialsOptional({
  required String path,
  required String method,
  Map<String, dynamic>? queryParameters,
  BaseCredentials? credentials,
  bool useBodyFields = false,
  required http.MultipartFile file,
}) {
  var uri = baseUri.replace(
      path: path,
      queryParameters:
          useBodyFields ? null : _prepareQueryParametersSafe(queryParameters));
  var req = http.MultipartRequest(method, uri)..files.add(file);
  (credentials ?? activeCredentials)?.addToTyped(req.headers);
  _addUserAgentTo(req.headers);
  if (queryParameters != null && useBodyFields) {
    req.fields.addAll(
        _prepareQueryParametersSafe(queryParameters)!.cast<String, String>());
  }
  return req;
}
// #endregion Base Init

/// [lowerBound] is inclusive, [upperBound] is exclusive.
int _validateLimit(
  int limit, {
  int lowerBound = 1,
  int upperBound = maxPostSearchLimit + 1,
  int valueIfFalse = 75,
}) =>
    (limit >= lowerBound && limit < upperBound) ? limit : valueIfFalse;

// TODO: Refactor page validation
/// Works for postId; presumably works for all id types (user, set, pool, note).
String? getPageString({
  String? pageModifier,
  int? id,
  int? pageNumber,
}) =>
    (id != null && (pageModifier == 'a' || pageModifier == 'b'))
        ? "$pageModifier$id"
        : pageNumber != null
            ? "$pageNumber"
            : null;

String? generateDiff(List<String> oldValues, List<String> newValues) {
  final origTags = oldValues.toSet();
  final editedTagSet = newValues.toSet();
  final newTags = editedTagSet
      .difference(origTags)
      .fold("", (acc, e) => "$acc $e")
      .trimLeft();
  final removedTags = origTags
      .difference(editedTagSet)
      .fold("", (acc, e) => "$acc -$e")
      .trimLeft();
  final combined = "$newTags $removedTags".trimLeft();
  return combined.isEmpty ? null : combined;
}

String foldIterableForUrl(Iterable i, {bool allowEmpty = true}) =>
    i.isNotEmpty || allowEmpty
        ? i
            .map((e) => e is ge.ApiQueryParameter ? e.query : e.toString())
            .fold("", (acc, e) => "$acc +$e")
            .trimLeft()
        : " ";

// #region Query Helpers
Map<String, dynamic>? _prepareQueryParametersSafe(
  Map<String, dynamic>? qp, {
  String? defaultSeparator,
  Map<String, String>? joinMap,
}) =>
    qp
      ?..updateAll((k, v) {
        dynamic recurse(val) => switch (val) {
              String v1 => v1,
              Iterable v1 when (joinMap?[k] ?? _doNotJoin) != _doNotJoin =>
                v1.map(recurse).join(joinMap![k]!),
              Iterable v1 when defaultSeparator != null =>
                v1.map(recurse).join(defaultSeparator),
              Iterable v1 => v1.map(recurse),
              ge.ApiQueryParameter _ => val.query,
              _ => val.toString(),
            };
        return recurse(v);
      });
const _doNotJoin = "DON'T JOIN";
const Map<String, String> _joinMap = {
  "search[antecedent_tag_category]": ",",
  "search[consequent_tag_category]": ",",
  "user[favorite_tags]": " ",
  "user[blacklisted_tags]": " ",
};

/* final class IterableOrSingle<T> {
  final T? single;
  final Iterable<T>? iterable;

  const IterableOrSingle.single(T this.single) : iterable = null;
  const IterableOrSingle.iterable(Iterable<T> this.iterable) : single = null;
  IterableOrSingle.iterableChecked(Iterable<T> iterable)
      : single = null,
        iterable = iterable.isNotEmpty
            ? iterable
            : throw ArgumentError.value(
                iterable, "iterable", "Must not be empty");
  IterableOrSingle.checked({this.single, this.iterable}) {
    if (single == null && (iterable?.isEmpty ?? true)) {
      throw ArgumentError.value((single, iterable), "(single, iterable)",
          "Must be at least 1 value between iterable and single");
    }
  }

  String join({
    String separator = "",
    String Function(T)? toString,
  }) =>
      toString == null
          ? (iterable?.isNotEmpty ?? false)
              ? (single != null
                      ? iterable!.followedBy([single as T])
                      : iterable!)
                  .join(separator)
              : single.toString()
          : (iterable?.isNotEmpty ?? false)
              ? (single != null
                      ? iterable!.followedBy([single as T])
                      : iterable!)
                  .map((e) => toString(e))
                  .join(separator)
              : toString(single as T);
}
 */
// #endregion Query Helpers
// #endregion Helpers

// TODO: Make naming conventions consistent.
// Format: [init|send][<item>Post|Set|Pool|...](?<action>Search|Get|Edit|Delete|Revert|...)(modifiers)
// Format: init/sendItemAction
// Format: initPostSearch

// #region Requests

// #region Db Exports
@Deprecated("Use initDbExportTagsGet")
http.Request initDbExportRequest({
  DateTime? date,
  BaseCredentials? credentials,
}) =>
    initDbExportTagsGet(date: date, credentials: credentials);

/// {@template dbExportEndpoint}
/// https://e621.net/db_export/
///
/// * [date] must be within 4 days of today (e.g. today and the 3 days prior).
/// Today's export should be done by 8:00 AM EST.
///
/// All exports are `.csv.gz` files.
/// {@endtemplate}
http.Request initDbExportTagsGet({
  DateTime? date,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/db_export/tags-"
            "${_getDbExportDate(date ?? DateTime.now())}.csv.gz",
        method: "GET",
        credentials: credentials);

/// {@macro dbExportEndpoint}
http.Request initDbExportPoolsGet({
  DateTime? date,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/db_export/pools-"
            "${_getDbExportDate(date ?? DateTime.now())}.csv.gz",
        method: "GET",
        credentials: credentials);

/// {@macro dbExportEndpoint}
http.Request initDbExportPostsGet({
  DateTime? date,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/db_export/posts-"
            "${_getDbExportDate(date ?? DateTime.now())}.csv.gz",
        method: "GET",
        credentials: credentials);

/// {@macro dbExportEndpoint}
http.Request initDbExportTagAliasesGet({
  DateTime? date,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/db_export/tag_aliases-"
            "${_getDbExportDate(date ?? DateTime.now())}.csv.gz",
        method: "GET",
        credentials: credentials);

/// {@macro dbExportEndpoint}
http.Request initDbExportTagImplicationsGet({
  DateTime? date,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/db_export/tag_implications-"
            "${_getDbExportDate(date ?? DateTime.now())}.csv.gz",
        method: "GET",
        credentials: credentials);

/// {@macro dbExportEndpoint}
http.Request initDbExportWikiPagesGet({
  DateTime? date,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/db_export/wiki_pages-"
            "${_getDbExportDate(date ?? DateTime.now())}.csv.gz",
        method: "GET",
        credentials: credentials);
// #endregion Db Exports
// #region Popular
/// [OpenAPI](https://e621.wiki/#:~:text=List%20Most%20Upvoted%20Posts)
///
/// The base URL is [`/popular.json`](https://e621.net/popular.json) called with `GET`.
///
/// * [date] : Sets the date to get popular posts from.
/// * [scale] : The time frame around [date] to get popular posts from.
///
/// This returns an object with a `posts` field containing a JSON array, for each post it returns:
/// {@macro PostListing}
http.Request initPopularSearch({
  DateTime? date,
  se.PopularTimeScale? scale,
  BaseCredentials? credentials,
}) =>
    initPopularSearchUnconstrained(
      date: date?.toIso8601String(),
      scale: scale?.name,
    );

/// [OpenAPI](https://e621.wiki/#:~:text=List%20Most%20Upvoted%20Posts)
///
/// The base URL is [`/popular.json`](https://e621.net/popular.json) called with `GET`.
///
/// * [date] : Sets the date to get popular posts from. Must be a ISO 8601 date-time string.
/// * [scale] : The time frame around [date] to get popular posts from. Must be:
///   * `null`,
///   * `"day"`,
///   * `"week"`, or
///   * `"month"`.
///
/// This returns an object with a `posts` field containing a JSON array, for each post it returns:
/// {@macro PostListing}
http.Request initPopularSearchUnconstrained({
  String? date,
  String? scale,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/popular.json",
        queryParameters: {
          if (date != null) "date": date,
          if (scale != null) "scale": scale,
        },
        method: "GET",
        credentials: credentials);
// #endregion Popular
// #region Posts
// #region Create
/// TODO: Test
/// https://pub.dev/documentation/http/latest/http/MultipartRequest-class.html#:~:text=A%20multipart%2Fform%2Ddata%20request,value%20set%20by%20the%20user
/// https://stackoverflow.com/questions/71424265/how-to-send-multipart-file-with-flutter
///
/// {@template postUpload}
/// [Create](https://e621.net/wiki_pages/2425#posts_create)
///
/// [OpenAPI](https://e621.wiki/#:~:text=Upload%20Post)
///
/// The base URL is [`/uploads.json`](https://e621.net/uploads.json) called with `POST`.
///
/// There are only four mandatory fields: you need to supply the file (either through a multipart form or through a source URL), the tags, a source (even if blank), and the rating.
///
/// If `upload[source]` is not supplied and `upload[direct_url]` is, the
/// wrapper will add that as a source to prevent an error.
///
/// * `upload[tag_string]` A space delimited list of tags.
/// * `upload[file]` The file data encoded as a multipart form. Mutually exclusive with `upload[direct_url]`.
/// * `upload[direct_url]` If this is a URL, e621 will download the file. Mutually exclusive with `upload[file]`.
/// * `upload[rating]` The rating for the post. Can be: s, q or e for safe, questionable, and explicit respectively.
/// * `upload[source]` This will be used as the post's 'Source' text. Separate multiple URLs with %0A (url-encoded newline) to define multiple sources. Limit of ten URLs
/// * `upload[description]` The description for the post.
/// * `upload[parent_id]` The ID of the parent post.
/// * `upload[as_pending]` Must have the "Unrestricted Uploads" permission.
/// * `upload[locked_rating]` Must be Privileged+ to use.
/// * `upload[locked_tags]` Must be Admin+ to use.
///
/// If the call fails, the following response reasons are possible:
///
/// * `MD5` mismatch This means you supplied an MD5 parameter and what e621 got doesn't match. Try uploading the file again.
/// * `duplicate` This post already exists in e621 (based on the MD5 hash). An additional attribute called location will be set, pointing to the (relative) URL of the original post.
/// * `other` Any other error will have its error message printed.
///
/// Response:
/// Success:
/// HTTP 200 OK
/// ```json
/// {
///     "success":true,
///     "location":"/posts/<Post_ID>",
///     "post_id":<Post_ID>
/// }
/// ```
/// Failed due to the post already existing:
/// HTTP 412
/// ```json
/// {
///     "success":false,
///     "reason":"duplicate",
///     "location":"/posts/<Post_ID>",
///     "post_id":<Post_ID>
/// }
/// ```
/// {@endtemplate}
http.BaseRequest initPostCreate({
  required String uploadTagString,
  String? uploadFileString,
  List<int>? uploadFileBytes,
  Stream<List<int>>? uploadFileStream,
  int? uploadFileStreamLength,
  required ge.Rating uploadRating,
  String? uploadDirectUrl,
  Iterable<String>? uploadSources,
  String? uploadSource,
  String? uploadDescription,
  int? uploadParentId,
  bool? uploadAsPending,
  bool? uploadLockedRating,
  bool? uploadLockedTags,
  BaseCredentials? credentials,
}) {
  final source = (uploadSources?.isNotEmpty ?? false)
      ? (uploadSource != null
              ? [uploadSource].followedBy(uploadSources!)
              : uploadSources!)
          .take(10)
          // .join("\n")
          .join("%0A")
      : (uploadSource ??
          uploadDirectUrl ??
          (throw ArgumentError.value((uploadSource, uploadSources),
              "(uploadSource, uploadSources)", "A source is required")));
  final Map<String, String> params = {
    "upload[tag_string]": uploadTagString,
    "upload[rating]": uploadRating.suffixShort,
    "upload[source]": source,
    if (uploadDescription != null) "upload[description]": uploadDescription,
    if (uploadParentId != null) "upload[parent_id]": uploadParentId.toString(),
    if (uploadAsPending != null)
      "upload[as_pending]": uploadAsPending.toString(),
    if (uploadLockedRating != null)
      "upload[locked_rating]": uploadLockedRating.toString(),
    if (uploadLockedTags != null)
      "upload[locked_tags]": uploadLockedTags.toString(),
  };
  return uploadDirectUrl == null
      ? _baseInitMultipartRequestCredentialsRequired(
          path: "/uploads.json",
          queryParameters: params,
          file: switch ((
            uploadFileStream,
            uploadFileStreamLength,
            uploadFileBytes,
            uploadFileString
          )) {
            (Stream<List<int>> stream, int length, _, _) =>
              http.MultipartFile("upload[file]", stream, length),
            (_, _, List<int> bytes, _) =>
              http.MultipartFile.fromBytes("upload[file]", bytes),
            (_, _, _, String string) =>
              http.MultipartFile.fromString("upload[file]", string),
            _ => throw ArgumentError("Either uploadFileBytes, "
                "uploadFileStream & uploadFileStreamLength, "
                "uploadFileString"
                "or uploadDirectUrl must be non-null"),
          },
          useBodyFields: true,
          method: "POST",
          credentials: credentials)
      : _baseInitRequestCredentialsRequired(
          path: "/uploads.json",
          queryParameters: params
            ..addAll({"upload[direct_url]": uploadDirectUrl}),
          useBodyFields: true,
          method: "POST",
          credentials: credentials);
}

http.Request initPostCreateWithDirectUrl({
  required String uploadTagString,
  required ge.Rating uploadRating,
  required String uploadDirectUrl,
  String? uploadSource,
  Iterable<String>? uploadSources,
  String? uploadDescription,
  int? uploadParentId,
  bool? uploadAsPending,
  bool? uploadLockedRating,
  bool? uploadLockedTags,
  BaseCredentials? credentials,
}) =>
    initPostCreate(
      uploadTagString: uploadTagString,
      uploadRating: uploadRating,
      uploadDirectUrl: uploadDirectUrl,
      uploadSources: uploadSources,
      uploadSource: uploadSource,
      uploadDescription: uploadDescription,
      uploadParentId: uploadParentId,
      uploadAsPending: uploadAsPending,
      uploadLockedRating: uploadLockedRating,
      uploadLockedTags: uploadLockedTags,
      credentials: credentials,
    ) as http.Request;
http.MultipartRequest initPostCreateWithFileStream({
  required String uploadTagString,
  required Stream<List<int>> uploadFileStream,
  required int uploadFileStreamLength,
  required ge.Rating uploadRating,
  String? uploadSource,
  Iterable<String>? uploadSources,
  String? uploadDescription,
  int? uploadParentId,
  bool? uploadAsPending,
  bool? uploadLockedRating,
  bool? uploadLockedTags,
  BaseCredentials? credentials,
}) =>
    initPostCreate(
      uploadTagString: uploadTagString,
      uploadRating: uploadRating,
      uploadFileStream: uploadFileStream,
      uploadFileStreamLength: uploadFileStreamLength,
      uploadSources: uploadSources,
      uploadSource: uploadSource,
      uploadDescription: uploadDescription,
      uploadParentId: uploadParentId,
      uploadAsPending: uploadAsPending,
      uploadLockedRating: uploadLockedRating,
      uploadLockedTags: uploadLockedTags,
      credentials: credentials,
    ) as http.MultipartRequest;
http.MultipartRequest initPostCreateWithFileBytes({
  required List<int> uploadFileBytes,
  required String uploadTagString,
  required ge.Rating uploadRating,
  String? uploadSource,
  Iterable<String>? uploadSources,
  String? uploadDescription,
  int? uploadParentId,
  bool? uploadAsPending,
  bool? uploadLockedRating,
  bool? uploadLockedTags,
  BaseCredentials? credentials,
}) =>
    initPostCreate(
      uploadFileBytes: uploadFileBytes,
      uploadTagString: uploadTagString,
      uploadRating: uploadRating,
      uploadSources: uploadSources,
      uploadSource: uploadSource,
      uploadDescription: uploadDescription,
      uploadParentId: uploadParentId,
      uploadAsPending: uploadAsPending,
      uploadLockedRating: uploadLockedRating,
      uploadLockedTags: uploadLockedTags,
      credentials: credentials,
    ) as http.MultipartRequest;
http.MultipartRequest initPostCreateWithFileString({
  required String uploadFileString,
  required String uploadTagString,
  required ge.Rating uploadRating,
  String? uploadSource,
  Iterable<String>? uploadSources,
  String? uploadDescription,
  int? uploadParentId,
  bool? uploadAsPending,
  bool? uploadLockedRating,
  bool? uploadLockedTags,
  BaseCredentials? credentials,
}) =>
    initPostCreate(
      uploadFileString: uploadFileString,
      uploadTagString: uploadTagString,
      uploadRating: uploadRating,
      uploadSources: uploadSources,
      uploadSource: uploadSource,
      uploadDescription: uploadDescription,
      uploadParentId: uploadParentId,
      uploadAsPending: uploadAsPending,
      uploadLockedRating: uploadLockedRating,
      uploadLockedTags: uploadLockedTags,
      credentials: credentials,
    ) as http.MultipartRequest;
// #endregion Create

/// [List](https://e621.net/wiki_pages/2425#posts_list)
///
/// [OpenAPI](https://e621.wiki/#:~:text=Search%20Posts)
///
/// The base URL is `/posts.json` called with `GET`.
///
/// Deleted posts are returned when `status:deleted`/`status:any` is in the searched tags.
///
/// The most efficient method to iterate a large number of posts is to search use the page parameter, using page=b<ID> and using the lowest ID retrieved from the previous list of posts. The first request should be made without the page parameter, as this returns the latest posts first, so you can then iterate using the lowest ID. Providing arbitrarily large values to obtain the most recent posts is not portable and may break in the future.
///
/// Note: Using page=<number> without a or b before the number just searches through pages. Posts will shift between pages if posts are deleted or created to the site between requests and page numbers greater than 750 will return an error.
///
/// * `limit` How many posts you want to retrieve. There is a hard limit of 320 posts per request. Defaults to the value set in user preferences.
/// * `tags` The tag search query. Any tag combination that works on the website will work here.
/// * `page` The page that will be returned. Can also be used with a or b + post_id to get the posts after or before the specified post ID. For example a13 gets every post after post_id 13 up to the limit. This overrides any ordering meta-tag, order:id_desc is always used instead.
///
/// This returns an object with a `posts` field containing a JSON array, for each post it returns:
///
/// {@template PostListing}
/// * `id` The ID number of the post.
/// * `created_at` The time the post was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
/// * `updated_at` The time the post was updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
/// * `file` (array group)
/// * `width` The width of the post.
/// * `height` The height of the post.
/// * `ext` The file’s extension.
/// * `size` The size of the file in bytes.
/// * `md5` The md5 of the file.
/// * `url` The URL where the file is hosted on E6
/// * `preview` (array group)
/// * `width` The width of the post preview.
/// * `height` The height of the post preview.
/// * `url` The URL where the preview file is hosted on E6
/// * `sample` (array group)
/// * `has` If the post has a sample/thumbnail or not. (True/False)
/// * `width` The width of the post sample.
/// * `height` The height of the post sample.
/// * `url` The URL where the sample file is hosted on E6.
/// * `score` (array group)
/// * `up` The number of times voted up.
/// * `down` A negative number representing the number of times voted down.
/// * `total` The total score (up + down).
/// * `tags` (array group)
/// * `general` A JSON array of all the general tags on the post.
/// * `species` A JSON array of all the species tags on the post.
/// * `character` A JSON array of all the character tags on the post.
/// * `artist` A JSON array of all the artist tags on the post.
/// * `invalid` A JSON array of all the invalid tags on the post.
/// * `lore` A JSON array of all the lore tags on the post.
/// * `meta` A JSON array of all the meta tags on the post.
/// * `locked_tags` A JSON array of tags that are locked on the post.
/// * `change_seq` An ID that increases for every post alteration on E6 (explained below)
/// * `flags` (array group)
/// * `pending` If the post is pending approval. (True/False)
/// * `flagged` If the post is flagged for deletion. (True/False)
/// * `note_locked` If the post has it’s notes locked. (True/False)
/// * `status_locked` If the post’s status has been locked. (True/False)
/// * `rating_locked` If the post’s rating has been locked. (True/False)
/// * `deleted` If the post has been deleted. (True/False)
/// * `rating` The post’s rating. Either s, q or e.
/// * `fav_count` How many people have favorited the post.
/// * `sources` The source field of the post.
/// * `pools` An array of Pool IDs that the post is a part of.
/// * `relationships` (array group)
/// * `parent_id` The ID of the post’s parent, if it has one.
/// * `has_children` If the post has child posts (True/False)
/// * `has_active_children`
/// * `children` A list of child post IDs that are linked to the post, if it has any.
/// * `approver_id` The ID of the user that approved the post, if available.
/// * `uploader_id` The ID of the user that uploaded the post.
/// * `description` The post’s description.
/// * `comment_count` The count of comments on the post.
/// * `is_favorited` If provided auth credentials, will return if the authenticated user has favorited the post or not.
/// * `change_seq` is a number that is increased every time a post is changed on the site. It gets updated whenever a post has any of these values change:
///     * `tag_string`
///     * `source`
///     * `description`
///     * `rating`
///     * `md5`
///     * `parent_id`
///     * `approver_id`
///     * `is_deleted`
///     * `is_pending`
///     * `is_flagged`
///     * `is_rating_locked`
///     * `is_pending`
///     * `is_flagged`
///     * `is_rating_locked`
/// {@endtemplate}
///
/// You cannot search for more than [UserLoggedIn.tagQueryLimit] tags at a time. This yields:
/// ```
/// HTTP 422
/// {
///   "success": false,
///   "message": "You cannot search for more than ## tags at a time",
///   "code": null
/// }
/// ```
http.Request initPostSearch({
  int? limit,
  String? tags,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/posts.json",
        queryParameters: {
          if (limit != null) "limit": limit,
          if (tags != null) "tags": tags,
          if (page != null) "page": page,
        },
        method: "GET",
        credentials: credentials);

///
/// [OpenAPI](https://e621.wiki/#:~:text=Get%20Random%20Post)
///
/// The base URL is `/posts/random.json` called with `GET`.
///
/// * `tags` The tag search query. Any tag combination that works on the website will work here.
///
/// ## Responses
/// #### 200 Success
/// {@macro postListing}
///
/// {@template response404}
/// #### 404 Not Found
/// ```json
/// {
///   "success": false,
///   "reason": "not found"
/// }
/// ```
/// {@endtemplate}
http.Request initPostRandom({
  String? tags,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/posts/random.json",
        queryParameters: {
          if (tags != null) "tags": tags,
        },
        method: "GET",
        credentials: credentials);

/// Same as [initPostSearch], but checks the [tags] length to
/// ensure it doesn't exceed the tag limit in [maxTagsPerSearch].
///
/// Throws an [ArgumentError] if you exceed the tag limit.
http.Request initPostSearchChecked({
  int? limit,
  List<String>? tags,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/posts.json",
        queryParameters: {
          if (limit != null) "limit": limit,
          if (tags != null)
            "tags": tags.length <= maxTagsPerSearch
                ? tags.fold("", (acc, e) => "$acc $e").trimLeft()
                : (throw ArgumentError.value(tags, "tags",
                    "You cannot search for more than 40 tags at a time")),
          if (page != null) "page": page,
        },
        method: "GET",
        credentials: credentials);

/// [List](https://e621.net/wiki_pages/2425#posts_list)
///
/// The base URL is /posts/<Post_ID>.json called with GET.
///
/// This returns a JSON object with a single "post" property, containing an object with the following:
/// {@macro PostListing}
///
/// If nonexistent, returns:
/// ```
/// HTTP 404
///
/// {"success":false,"reason":"not found"}
/// ```
http.Request initPostGet(
  int postId, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/posts/$postId.json", method: "GET", credentials: credentials);

/// [Update](https://e621.net/wiki_pages/2425#posts_update)
///
/// The base URL is `/posts/<Post_ID>.json` called with `PATCH`.
/// Leave parameters blank if you don't want to change them.
///
/// * `post[tag_string_diff]` A space delimited list of tag changes such as dog -cat. This is a much preferred method over the old version.
/// (The old method of updating a post’s tags still works, with `post[old_tag_string]` and `post[tag_string]`, but `post[tag_string_diff]` is preferred.)
///
/// * `post[source_diff]` A (URL encoded) newline delimited list of source changes. This works the same as `post[tag_string_diff]` but with sources.
/// (The old method of updating a post’s sources still works, with `post[old_source]` and `post[source]`, but `post[source_diff]` is preferred.)
///
/// * `post[parent_id]` The ID of the parent post.
/// * `post[old_parent_id]` The ID of the previously parented post.
/// * `post[description]` This will be used as the post's 'Description' text.
/// * `post[old_description]` Should include the same descriptions submitted to `post[description]` minus any intended changes.
/// * `post[rating]` The rating for the post. Can be: s, q or e for safe, questionable, and explicit respectively.
/// * `post[old_rating]` The previous post’s rating.
/// * `post[is_rating_locked]` Set to true to prevent others from changing the rating.
/// * `post[is_note_locked]` Set to true to prevent others from adding notes.
/// * `post[edit_reason]` The reason for the submitted changes. Inline DText allowed.
/// TODO: Handle default values, as null is acceptable for some.
http.Request initPostEdit({
  required int postId,
  String? postTagStringDiff,
  String? postSourceDiff,
  int? postParentId,
  int? postOldParentId,
  String? postDescription,
  String? postOldDescription,
  String? postRating,
  String? postOldRating,
  bool? postIsRatingLocked,
  bool? postIsNoteLocked,
  String? postEditReason,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
        path: "/posts/$postId.json",
        queryParameters: {
          if (postTagStringDiff?.isNotEmpty ?? false)
            "post[tag_string_diff]": postTagStringDiff,
          // if (postTagStringDiff != null)
          //   "post[tag_string_diff]": postTagStringDiff,
          if (postSourceDiff?.isNotEmpty ?? false)
            "post[source_diff]": postSourceDiff,
          // if (postSourceDiff != null) "post[source_diff]": postSourceDiff,
          if (postParentId != postOldParentId && (postParentId ?? -1) >= 0)
            "post[parent_id]": postParentId,
          if (postParentId != postOldParentId && (postOldParentId ?? -1) >= 0)
            "post[old_parent_id]": postOldParentId,
          // if ((postParentId ?? 1) >= 0) "post[parent_id]": postParentId,
          // if ((postOldParentId ?? 1) >= 0) "post[old_parent_id]": postOldParentId,
          if ((postDescription ?? "") != (postOldDescription ?? ""))
            "post[description]": postDescription,
          if ((postDescription ?? "") != (postOldDescription ?? ""))
            "post[old_description]": postOldDescription,
          // if (postDescription != null) "post[description]": postDescription,
          // if (postOldDescription != null)
          //   "post[old_description]": postOldDescription,
          if (postRating != null && postRating != postOldRating)
            "post[rating]": postRating,
          if (postOldRating != null && postRating != postOldRating)
            "post[old_rating]": postOldRating,
          // if (postRating != null) "post[rating]": postRating,
          // if (postOldRating != null) "post[old_rating]": postOldRating,
          if (postIsRatingLocked != null)
            "post[is_rating_locked]": postIsRatingLocked,
          if (postIsNoteLocked != null)
            "post[is_note_locked]": postIsNoteLocked,
          if (postEditReason != null) "post[edit_reason]": postEditReason,
        },
        method: "PATCH",
        credentials: credentials);
bool doesPostEditHaveChanges({
  String? postTagStringDiff,
  String? postSourceDiff,
  int? postParentId,
  int? postOldParentId,
  String? postDescription,
  String? postOldDescription,
  String? postRating,
  String? postOldRating,
}) =>
    (postTagStringDiff?.isNotEmpty ?? false) ||
    (postSourceDiff?.isNotEmpty ?? false) ||
    (postParentId != postOldParentId && (postParentId ?? -1) >= 0) ||
    (postParentId != postOldParentId && (postOldParentId ?? -1) >= 0) ||
    ((postDescription ?? "") != (postOldDescription ?? "")) ||
    (postRating != null &&
        postOldRating != null &&
        postRating != postOldRating);

// #region Post Vote
/// [Vote](https://e621.net/wiki_pages/2425#posts_vote)
///
/// The base URL is `/posts/<Post_ID>/votes.json` called with `POST`.
///
/// * `score` Set to 1 to vote up and -1 to vote down. Repeat the request to remove the vote.
/// * `no_unvote` Set to true to have this score replace the old score. Repeat votes will not remove the vote.
/// Response:
/// Success:
/// HTTP 200
///
/// {
///    "score":<total>,
///    "up":<up>,
///    "down":<down>,
///    "our_score":x
/// }
/// Where our_score is 1, 0, -1 depending on the action.
/// Failure:
/// HTTP 422
///
/// {
///     "success": false,
///     "message": "An unexpected error occurred.",
///     "code": null
/// }
http.Request initVotePostRequest({
  required int postId,
  required int score,
  bool? noUnvote,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
        path: "/posts/$postId/votes.json",
        queryParameters: {
          // "score": score,
          "score": switch (score) {
            < 0 => -1,
            > 0 => 1,
            // == 0 => 1,
            _ => throw ArgumentError.value(
                score, "score", "Must be +/- 1; cannot be 0"),
          },
          if (noUnvote != null) "no_unvote": noUnvote,
        },
        method: "POST",
        credentials: credentials);

/// {@template postVote}
/// [Vote](https://e621.net/wiki_pages/2425#posts_vote)
///
/// The base URL is `/posts/<Post_ID>/votes.json` called with `POST`.
///
/// * `score` If true, votes up with a value of 1. If false, votes down with a value of -1.
/// * `no_unvote` Set to true to have this score replace the old score. Repeat votes will not remove the vote.
/// Response:
///
/// * Success:
/// ```
/// HTTP 200
///
/// {
///    "score":<total>,
///    "up":<up>,
///    "down":<down>,
///    "our_score":x
/// }
/// ```
/// Where our_score is 1, 0, -1 depending on the action.
/// * Failure:
///
/// ```
/// HTTP 422
///
/// {
///     "success": false,
///     "message": "An unexpected error occurred.",
///     "code": null
/// }
/// ```
/// {@endtemplate}
http.Request initPostCastVoteRequest({
  required int postId,
  required bool voteUp,
  bool? noUnvote,
  BaseCredentials? credentials,
}) =>
    initVotePostRequest(postId: postId, score: voteUp ? 1 : -1);
// #endregion Post Vote

// #endregion Posts
// #region Tags
/// (Listing)[https://e621.net/wiki_pages/2425#tags_listing]
/// The base URL is `/tags.json` called with `GET`.
///
/// * `search[name_matches]` A tag name expression to match against, which can include * as a wildcard.
/// * `search[category]` Filters results to a particular category. Default value is blank (show all tags). See below for allowed values.
/// * `search[order]` Changes the sort order. Pass one of date (default), count, or name.
/// * `search[hide_empty]` Hide tags with zero visible posts. Pass true (default) or false.
/// * `search[has_wiki]` Show only tags with, or without, a wiki page. Pass true, false, or blank (default).
/// * `search[has_artist]` Show only tags with, or without an artist page. Pass true, false, or blank (default).
/// * `limit` Maximum number of results to return per query. Default is 75. There is a hard upper limit of 320.
/// * `page` The page that will be returned. Can also be used with a or b + tag_id to get the tags after or before the specified tag ID. For example a13 gets every tag after tag_id 13 up to the limit. This overrides the specified search ordering, date is always used instead.
/// <details>
/// <summary>Categories:</summary>
/// The following values can be specified.
/// * 0 general
/// * 1 artist
/// * 3 copyright
/// * 4 character
/// * 5 species
/// * 6 invalid
/// * 7 meta
/// * 8 lore
///
/// See here for a description of what different types of tags are and do.
/// </details>
///
/// ### Response:
/// #### Success:
/// HTTP 200
///
/// ```
/// [{
///    "id":<numeric tag id>,
///    "name":<tag display name>,
///    "post_count":<# matching visible posts>,
///    "related_tags":<space-delimited list of tags>,
///    "related_tags_updated_at":<ISO8601 timestamp>,
///    "category":<numeric category id>,
///    "is_locked":<boolean>,
///    "created_at":<ISO8601 timestamp>,
///    "updated_at":<ISO8601 timestamp>
/// },
/// ...
/// ]
/// ```
/// If your query succeeds but produces no results, you will receive instead the following special value:
/// `{ "tags":[] }`
http.Request initTagSearch({
  String? searchNameMatches,
  ge.TagCategory? searchCategory,
  String? searchOrder,
  bool? searchHideEmpty,
  bool? searchHasWiki,
  bool? searchHasArtist,
  int? limit = 75,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/tags.json",
        queryParameters: {
          if (searchNameMatches != null)
            "search[name_matches]": searchNameMatches,
          if (searchCategory != null) "search[category]": searchCategory.index,
          if (searchOrder != null) "search[order]": searchOrder,
          if (searchHideEmpty != null) "search[hide_empty]": searchHideEmpty,
          if (searchHasWiki != null) "search[has_wiki]": searchHasWiki,
          if (searchHasArtist != null) "search[has_artist]": searchHasArtist,
          if (limit != null) "limit": _validateLimit(limit),
          if (page != null) "page": page,
        },
        method: "GET",
        credentials: credentials);

/// (Listing)[https://e621.net/wiki_pages/2425#tag_alias_listing]
/// The base URL is `/tag_aliases.json` called with `GET`.
///
/// * `search[name_matches]` A tag name expression to match against, which can include * as a wildcard. Both the aliased-to and the aliased-by tag are matched.
/// * `search[antecedent_name]` Supports multiple tag names, comma-separated.
/// * `search[consequent_name]` Supports multiple tag names, comma-separated.
/// * `search[antecedent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
/// * `search[consequent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
/// * `search[creator_name]` Name of the creator.
/// * `search[approver_name]` Name of the approver.
/// * `search[status]` Filters aliases by status. Pass one of approved, active, pending, deleted, retired, processing, queued, or blank (default). *
/// * `search[order]` Changes the sort order. Pass one of status (default), created_at, updated_at, name, or tag_count.
/// * `limit` Maximum number of results to return per query.
/// * `page` The page that will be returned. Can also be used with a or b + alias_id to get the aliases after or before the specified alias ID. For example a13 gets every alias after alias_id 13 up to the limit. This overrides the specified search ordering, created_at is always used instead.
///
/// \* Some aliases have a status which is an error message, these show up in searches where status is omitted but there is no way to search for them specifically.
///
/// Response:
/// Success:
/// HTTP 200
/// ```json
/// [{
///    "id": <numeric alias id>,
///    "status": <status string>,
///    "antecedent_name": <aliased-by tag name>,
///    "consequent_name": <aliased-to tag name>,
///    "post_count": <# matching posts>,
///    "reason": <explanation>,
///    "creator_id": <user id>,
///    "approver_id": <user id>,
///    "created_at": <ISO8601 timestamp>,
///    "updated_at": <ISO8601 timestamp>,
///    "forum_post_id": <post id>,
///    "forum_topic_id": <topic id>,
/// },
/// ...
/// ]
/// ```
/// If your query succeeds but produces no results, you will receive instead the following special value:
///
/// `{ "tag_aliases":[] }`
http.Request initTagAliasSearch({
  String? searchNameMatches,
  String? searchAntecedentName,
  Iterable<String>? searchAntecedentNames,
  String? searchConsequentName,
  Iterable<String>? searchConsequentNames,
  ge.TagCategory? searchAntecedentTagCategory,
  Iterable<ge.TagCategory>? searchAntecedentTagCategories,
  ge.TagCategory? searchConsequentTagCategory,
  Iterable<ge.TagCategory>? searchConsequentTagCategories,
  String? searchCreatorName,
  String? searchApproverName,
  String? searchStatus,
  String? searchOrder,
  int? limit,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/tag_aliases.json",
        queryParameters: {
          if (searchNameMatches != null)
            "search[name_matches]": searchNameMatches,
          if ((searchAntecedentNames?.isNotEmpty ?? false) ||
              searchAntecedentName != null)
            "search[antecedent_name]":
                (searchAntecedentNames?.isNotEmpty ?? false)
                    ? (searchAntecedentName != null
                            ? searchAntecedentNames!
                                .followedBy([searchAntecedentName])
                            : searchAntecedentNames!)
                        .join(",")
                    : searchAntecedentName,
          if ((searchConsequentNames?.isNotEmpty ?? false) ||
              searchConsequentName != null)
            "search[consequent_name]":
                (searchConsequentNames?.isNotEmpty ?? false)
                    ? (searchConsequentName != null
                            ? searchConsequentNames!
                                .followedBy([searchConsequentName])
                            : searchConsequentNames!)
                        .join(",")
                    : searchConsequentName,
          if ((searchAntecedentTagCategories?.isNotEmpty ?? false) ||
              searchAntecedentTagCategory != null)
            "search[antecedent_tag_category]":
                (searchAntecedentTagCategories?.isNotEmpty ?? false)
                    ? (searchAntecedentTagCategory != null
                            ? searchAntecedentTagCategories!
                                .followedBy([searchAntecedentTagCategory])
                            : searchAntecedentTagCategories!)
                        .map((e) => e.index)
                        .join(",")
                    : searchAntecedentTagCategory!.index,
          if ((searchConsequentTagCategories?.isNotEmpty ?? false) ||
              searchConsequentTagCategory != null)
            "search[consequent_tag_category]":
                (searchConsequentTagCategories?.isNotEmpty ?? false)
                    ? (searchConsequentTagCategory != null
                            ? searchConsequentTagCategories!
                                .followedBy([searchConsequentTagCategory])
                            : searchConsequentTagCategories!)
                        .map((e) => e.index)
                        .join(",")
                    : searchConsequentTagCategory!.index,
          if (searchCreatorName != null)
            "search[creator_name]": searchCreatorName,
          if (searchApproverName != null)
            "search[approver_name]": searchApproverName,
          if (searchStatus != null) "search[status]": searchStatus,
          if (searchOrder != null) "search[order]": searchOrder,
          if (limit != null) "limit": limit, //_validateLimit(limit),
          if (page != null) "page": page,
        },
        method: "GET",
        credentials: credentials);

/// (Listing)[https://e621.net/wiki_pages/2425#tag_alias_listing]
/// The base URL is `/tag_implications.json` called with `GET`.
///
/// * `search[name_matches]` A tag name expression to match against, which can include * as a wildcard. Both the implied-to and the implied-by tag are matched.
/// * `search[antecedent_name]` Supports multiple tag names, comma-separated.
/// * `search[consequent_name]` Supports multiple tag names, comma-separated.
/// * `search[antecedent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
/// * `search[consequent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
/// * `search[creator_name]` Name of the creator.
/// * `search[approver_name]` Name of the approver.
/// * `search[status]` Filters implications by status. Pass one of approved, active, pending, deleted, retired, processing, queued, or blank (default). *
/// * `search[order]` Changes the sort order. Pass one of status (default), created_at, updated_at, name, or tag_count.
/// * `limit` Maximum number of results to return per query.
/// * `page` The page that will be returned. Can also be used with a or b + implication_id to get the implications after or before the specified implication ID. For example a13 gets every implication after implication_id 13 up to the limit. This overrides the specified search ordering, created_at is always used instead.
/// * Some implications have a status which is an error message, these show up in searches where status is omitted but there is no way to search for them specifically.
///
/// Response:
/// Success:
/// HTTP 200
///
/// [{
///    "id": <numeric implication id>,
///    "status": <status string>,
///    "antecedent_name": <implied-by tag name>,
///    "consequent_name": <implied-to tag name>,
///    "post_count": <# matching posts>,
///    "reason": <explanation>,
///    "creator_id": <user id>,
///    "approver_id": <user id>
///    "created_at": <ISO8601 timestamp>,
///    "updated_at": <ISO8601 timestamp>,
///    "forum_post_id": <post id>,
///    "forum_topic_id": <topic id>,
/// },
/// ...
/// ]
/// If your query succeeds but produces no results, you will receive instead the following special value:
///
/// { "tag_implications":[] }
http.Request initTagImplicationSearch({
  String? searchNameMatches,
  String? searchAntecedentName,
  Iterable<String>? searchAntecedentNames,
  String? searchConsequentName,
  Iterable<String>? searchConsequentNames,
  ge.TagCategory? searchAntecedentTagCategory,
  Iterable<ge.TagCategory>? searchAntecedentTagCategories,
  ge.TagCategory? searchConsequentTagCategory,
  Iterable<ge.TagCategory>? searchConsequentTagCategories,
  String? searchCreatorName,
  String? searchApproverName,
  String? searchStatus,
  String? searchOrder,
  int? limit,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/tag_implications.json",
        queryParameters: {
          if (searchNameMatches != null)
            "search[name_matches]": searchNameMatches,
          if ((searchAntecedentNames?.isNotEmpty ?? false) ||
              searchAntecedentName != null)
            "search[antecedent_name]":
                (searchAntecedentNames?.isNotEmpty ?? false)
                    ? (searchAntecedentName != null
                            ? searchAntecedentNames!
                                .followedBy([searchAntecedentName])
                            : searchAntecedentNames!)
                        .join(",")
                    : searchAntecedentName,
          if ((searchConsequentNames?.isNotEmpty ?? false) ||
              searchConsequentName != null)
            "search[consequent_name]":
                (searchConsequentNames?.isNotEmpty ?? false)
                    ? (searchConsequentName != null
                            ? searchConsequentNames!
                                .followedBy([searchConsequentName])
                            : searchConsequentNames!)
                        .join(",")
                    : searchConsequentName,
          if ((searchAntecedentTagCategories?.isNotEmpty ?? false) ||
              searchAntecedentTagCategory != null)
            "search[antecedent_tag_category]":
                (searchAntecedentTagCategories?.isNotEmpty ?? false)
                    ? (searchAntecedentTagCategory != null
                            ? searchAntecedentTagCategories!
                                .followedBy([searchAntecedentTagCategory])
                            : searchAntecedentTagCategories!)
                        .map((e) => e.index)
                        .join(",")
                    : searchAntecedentTagCategory!.index,
          if ((searchConsequentTagCategories?.isNotEmpty ?? false) ||
              searchConsequentTagCategory != null)
            "search[consequent_tag_category]":
                (searchConsequentTagCategories?.isNotEmpty ?? false)
                    ? (searchConsequentTagCategory != null
                            ? searchConsequentTagCategories!
                                .followedBy([searchConsequentTagCategory])
                            : searchConsequentTagCategories!)
                        .map((e) => e.index)
                        .join(",")
                    : searchConsequentTagCategory!.index,
          if (searchCreatorName != null)
            "search[creator_name]": searchCreatorName,
          if (searchApproverName != null)
            "search[approver_name]": searchApproverName,
          if (searchStatus != null) "search[status]": searchStatus,
          if (searchOrder != null) "search[order]": searchOrder,
          if (limit != null) "limit": limit, //_validateLimit(limit),
          if (page != null) "page": page,
        },
        method: "GET",
        credentials: credentials);
// #endregion Tags

// #region Favorites
/// {@template ListFavorites}
/// [Listing](https://e621.net/wiki_pages/2425#favorites_listing)
/// The base URL is `/favorites.json` called with `GET`.
///
/// * `user_id` Optional, the user to fetch the favorites from. If not specified will fetch the favorites from the currently authorized user. You must be the user or `Moderator+` if the user has their favorites hidden.
/// * `limit` How many posts you want to retrieve. There is a hard limit of 320 posts per request. Defaults to the value set in user preferences.
/// * `page` The page that will be returned. Can also be used with a or b + post_id to get the posts after or before the specified post ID. For example a13 gets every post after post_id 13 up to the limit. ??This overrides any ordering meta-tag, order:id_desc is always used instead.??
///
/// ### Response:
///
/// #### Success:
/// * HTTP 200
///
/// {@macro postListing}
/// See #posts_list for post data specification.
/// ```
/// {
///     "posts": [
///         <post data>
///     ]
/// }
/// ```
/// #### Error:
/// * HTTP 403 if the user has hidden their favorites.
/// * HTTP 404 if the specified user_id does not exist or user_id is not specified and the user is not authorized.
/// {@endtemplate}
http.Request initFavoriteSearch({
  int? userId,
  int? limit,
  String? page,
  BaseCredentials? credentials,
}) =>
    (userId ?? credentials ?? activeCredentials) == null
        ? (throw ArgumentError.value(
            (userId: userId, credentials: credentials),
            "(userId, credentials)",
            "At least one of userId, credentials, "
                "or activeCredentials must be non-null"))
        : _baseInitRequestCredentialsOptional(
            path: "/favorites.json",
            queryParameters: {
              if (userId != null) "user_id": userId,
              if (limit != null) "limit": limit,
              if (page != null) "page": page,
            },
            method: "GET",
            credentials: credentials);

/// {@template CreateFavorite}
/// [Create](https://e621.net/wiki_pages/2425#favorites_create)
/// The base URL is `/favorites.json` called with `POST`.
///
/// * `post_id` The post id you want to favorite.
///
/// ### Response:
///
/// #### Success:
/// * HTTP 200
///
/// {@macro postListing}
/// See #posts_list for post data specification.
/// ```
/// {
///     "posts": [
///         <post data>
///     ]
/// }
/// ```
/// #### Error:
/// * HTTP 422 if the user has hit the 80000 favorites cap with this body:
/// ```
/// {
///   "success": false,
///   "message": "You can only keep up to 80000 favorites.",
///   "code": null
/// }
/// ```
/// {@endtemplate}
http.Request initFavoriteCreate({
  required int postId,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
        path: "/favorites.json",
        queryParameters: {
          "post_id": postId,
        },
        method: "POST",
        credentials: credentials);

/// {@template DeleteFavorite}
/// [Delete](https://e621.net/wiki_pages/2425#favorites_delete)
/// The base URL is `/favorites/<post_id>.json` called with `DELETE`.
///
/// There is no response body.
/// Success: 204
/// {@endtemplate}
http.Request initFavoriteDelete({
  required int postId,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
        path: "/favorites/$postId.json",
        method: "DELETE",
        credentials: credentials);
// #region Redirects
/// {@macro ListFavorites}
http.Request initListFavoritesWithIdRequest({
  required int userId,
  int? limit,
  String? page,
  BaseCredentials? credentials,
}) =>
    initFavoriteSearch(
      userId: userId,
      credentials: credentials,
      limit: limit,
      page: page,
    );

/// {@macro ListFavorites}
http.Request initListFavoritesWithCredentialsRequest({
  required BaseCredentials credentials,
  int? limit,
  String? page,
}) =>
    initFavoriteSearch(
      credentials: credentials,
      limit: limit,
      page: page,
    );
// #endregion Redirects
// #endregion Favorites

// #region Notes
/// [Listing](https://e621.net/wiki_pages/2425#notes_listing)
///
/// The base URL is `/notes.json` called with `GET`.
///
/// * `search[body_matches]` The note's body matches the given terms. Use a * in the search terms to search for raw strings.
/// * `search[post_id]`
/// * `search[post_tags_match]` The note's post's tags match the given terms. Meta-tags are not supported.
/// * `search[creator_name]` The creator's name. Exact match.
/// * `search[creator_id]` The creator's user id.
/// * `search[is_active]` Can be: true, false
/// {@template limitRoot}
/// * `limit` The maximum number of results to return. Between 0 and 320.
/// {@endtemplate}
/// {@template pageRoot}
/// * `page` The page that will be returned. Between 1 and 750. Can also be used with a or b + item_id to get the items after or before the specified ID. For example a13 gets every item after item_id 13 up to the limit.
/// {@endtemplate}
///
/// This returns a JSON array, for each note it returns:
/// {@template noteListing}
/// * `id` The Note’s ID
/// * `created_at` The time the note was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
/// * `updated_at` The time the note was updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
/// * `creator_id` The ID of the user that created the note.
/// * `x` The X coordinate of the top left corner of the note in pixels from the top left of the post.
/// * `y` The Y coordinate of the top left corner of the note in pixels from the top left of the post.
/// * `width` The width of the box for the note.
/// * `height` The height of the box for the note.
/// * `version` How many times the note has been edited.
/// * `is_active` If the note is currently active. (True/False)
/// * `post_id` The ID of the post that the note is on.
/// * `body` The contents of the note.
/// * `creator_name` The name of the user that created the note.
/// {@endtemplate}
///
/// If no results are returned:
/// ```{"notes":[]}```
http.Request initNoteSearch({
  String? searchBodyMatches,
  String? searchPostId,
  String? searchPostTagsMatch,
  String? searchCreatorName,
  String? searchCreatorId,
  String? searchIsActive,
  int? limit,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/notes.json",
      method: "GET",
      queryParameters: {
        if (searchBodyMatches != null)
          "search[body_matches]": searchBodyMatches,
        if (searchPostId != null) "search[post_id]": searchPostId,
        if (searchPostTagsMatch != null)
          "search[post_tags_match]": searchPostTagsMatch,
        if (searchCreatorName != null)
          "search[creator_name]": searchCreatorName,
        if (searchCreatorId != null) "search[creator_id]": searchCreatorId,
        if (searchIsActive != null) "search[is_active]": searchIsActive,
        if (limit != null) "limit": limit,
      },
      credentials: credentials,
    );

/// [Create](https://e621.net/wiki_pages/2425#notes_create)
///
/// The base URL is `/notes.json` called with `POST`.
///
/// * note[post_id] The ID of the post you want to add a note to.
/// * note[x] The X coordinate of the top left corner of the note in pixels from the top left of the post.
/// * note[y] The Y coordinate of the top left corner of the note in pixels from the top left of the post.
/// * note[width] The width of the box for the note.
/// * note[height] The height of the box for the note.
/// * note[body] The contents of the note.
///
/// All fields are required.
///
/// If successful it will return the added note in the format:
/// {@macro noteListing}
http.Request initNoteCreate({
  required int notePostId,
  required int noteX,
  required int noteY,
  required int noteWidth,
  required int noteHeight,
  required String noteBody,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/notes.json",
      method: "POST",
      queryParameters: {
        "note[post_id]": notePostId,
        "note[x]": noteX,
        "note[y]": noteY,
        "note[width]": noteWidth,
        "note[height]": noteHeight,
        "note[body]": noteBody,
      },
      credentials: credentials,
    );

/// [Delete](https://e621.net/wiki_pages/2425#notes_delete)
///
/// The base URL is ``/notes/[noteId].json`` called with `DELETE`.
///
/// There is no response.
http.Request initNoteDelete(
  int noteId, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/notes/$noteId.json",
      method: "DELETE",
      credentials: credentials,
    );

/// [Revert](https://e621.net/wiki_pages/2425#notes_revert)
///
/// The base URL is ``/notes/[noteId]/revert.json`` called with PUT.
///
/// * `version_id` The note version id to revert to.
http.Request initNoteRevert(
  int noteId, {
  required int versionId,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/notes/$noteId.json",
      queryParameters: {"version_id": versionId},
      method: "PUT",
      credentials: credentials,
    );

// #endregion Notes
// #region Users
@Deprecated("Use initUserSearch")
http.Request initSearchUsersRequest({
  String? searchNameMatches,
  String? searchAboutMe,
  int? searchAvatarId,
  ge.UserLevel? searchLevel,
  ge.UserLevel? searchMinLevel,
  ge.UserLevel? searchMaxLevel,
  bool? searchCanUploadFree,
  bool? searchCanApprovePosts,
  se.UserOrder? searchOrder,
  int? limit = 75,
  String? page,
  BaseCredentials? credentials,
}) =>
    initUserSearch(
      searchNameMatches: searchNameMatches,
      searchAboutMe: searchAboutMe,
      searchAvatarId: searchAvatarId,
      searchLevel: searchLevel,
      searchMinLevel: searchMinLevel,
      searchMaxLevel: searchMaxLevel,
      searchCanUploadFree: searchCanUploadFree,
      searchCanApprovePosts: searchCanApprovePosts,
      searchOrder: searchOrder,
      limit: limit,
      page: page,
      credentials: credentials,
    );

/// https://e621.net/users.json?search%5Bname_matches%5D=a&search%5Babout_me%5D=a&search%5Bavatar_id%5D=1&search%5Blevel%5D=10&search%5Bmin_level%5D=10&search%5Bmax_level%5D=10&search%5Bcan_upload_free%5D=true&search%5Bcan_approve_posts%5D=true&search%5Border%5D=name
/// `/users.json` `GET`
/// * `search[name_matches]`
/// * `search[about_me]`
/// * `search[avatar_id]`
/// * `search[level]`
/// * `search[min_level]`
/// * `search[max_level]`
/// * `search[can_upload_free]`
/// * `search[can_approve_posts]`
/// * `search[order]`
/// * limit How many items you want to retrieve. There is a hard limit of 320 items per request. Defaults to 75.
/// * page The page that will be returned. Can also be used with a or b + item_id to get the items after or before the specified item ID. For example a13 gets every item after item_id 13 up to the limit.
http.Request initUserSearch({
  String? searchNameMatches,
  String? searchAboutMe,
  int? searchAvatarId,
  ge.UserLevel? searchLevel,
  ge.UserLevel? searchMinLevel,
  ge.UserLevel? searchMaxLevel,
  bool? searchCanUploadFree,
  bool? searchCanApprovePosts,
  se.UserOrder? searchOrder,
  int? limit = 75,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/users.json",
        queryParameters: {
          if (searchNameMatches != null)
            "search[name_matches]": searchNameMatches,
          if (searchAboutMe != null) "search[about_me]": searchAboutMe,
          if (searchAvatarId != null) "search[avatar_id]": searchAvatarId,
          if (searchLevel != null) "search[level]": searchLevel,
          if (searchMinLevel != null) "search[min_level]": searchMinLevel,
          if (searchMaxLevel != null) "search[max_level]": searchMaxLevel,
          if (searchCanUploadFree != null)
            "search[can_upload_free]": searchCanUploadFree,
          if (searchCanApprovePosts != null)
            "search[can_approve_posts]": searchCanApprovePosts,
          if (searchOrder != null) "search[order]": searchOrder,
          if (limit != null) "limit": _validateLimit(limit),
          if (page != null) "page": page,
        },
        method: "GET",
        credentials: credentials);
@Deprecated("Use initUserGet")
http.Request initGetUserRequest(
  int userId, {
  BaseCredentials? credentials,
}) =>
    initUserGet(
      userId,
      credentials: credentials,
    );

/// https://e621.net/users/248688.json
/// `/users/<User_ID>.json` `GET`
///
/// Responses
///
/// `204` Success No Body
///
/// `403` Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
///
/// `422` Invalid Input Data
/// ```
/// {
///   "errors": {
///     "key": [
///       "the error"
///     ]
///   }
/// }
/// ```
http.Request initUserGet(
  int userId, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
        path: "/users/$userId.json", method: "GET", credentials: credentials);
@Deprecated("Use initUserEdit")
http.Request initUpdateUserRequest({
  int userId = 1234,
  int? userCommentThreshold,
  String? userDefaultImageSize,
  String? userFavoriteTags,
  String? userBlacklistedTags,
  String? userTimeZone,
  int? userPerPage,
  String? userCustomStyle,
  bool? userDescriptionCollapsedInitially,
  bool? userHideComments,
  bool? userReceiveEmailNotifications,
  bool? userEnableKeyboardNavigation,
  bool? userEnablePrivacyMode,
  bool? userDisableUserDmails,
  bool? userBlacklistUsers,
  bool? userShowPostStatistics,
  bool? userStyleUsernames,
  bool? userShowHiddenComments,
  bool? userEnableAutocomplete,
  bool? userDisableCroppedThumbnails,
  bool? userEnableSafeMode,
  bool? userDisableResponsiveMode,
  int? userDmailFilterAttributesId,
  String? userDmailFilterAttributesWords,
  String? userProfileAbout,
  String? userProfileArtInfo,
  int? userAvatarId = -1,
  bool? userEnableCompactUploader,
  BaseCredentials? credentials,
}) =>
    initUserEdit(
      userId: userId,
      userCommentThreshold: userCommentThreshold,
      userDefaultImageSize: userDefaultImageSize,
      userFavoriteTags: userFavoriteTags,
      userBlacklistedTags: userBlacklistedTags,
      userTimeZone: userTimeZone,
      userPerPage: userPerPage,
      userCustomStyle: userCustomStyle,
      userDescriptionCollapsedInitially: userDescriptionCollapsedInitially,
      userHideComments: userHideComments,
      userReceiveEmailNotifications: userReceiveEmailNotifications,
      userEnableKeyboardNavigation: userEnableKeyboardNavigation,
      userEnablePrivacyMode: userEnablePrivacyMode,
      userDisableUserDmails: userDisableUserDmails,
      userBlacklistUsers: userBlacklistUsers,
      userShowPostStatistics: userShowPostStatistics,
      userStyleUsernames: userStyleUsernames,
      userShowHiddenComments: userShowHiddenComments,
      userEnableAutocomplete: userEnableAutocomplete,
      userDisableCroppedThumbnails: userDisableCroppedThumbnails,
      userEnableSafeMode: userEnableSafeMode,
      userDisableResponsiveMode: userDisableResponsiveMode,
      userDmailFilterAttributesId: userDmailFilterAttributesId,
      userDmailFilterAttributesWords: userDmailFilterAttributesWords,
      userProfileAbout: userProfileAbout,
      userProfileArtInfo: userProfileArtInfo,
      userAvatarId: userAvatarId,
      userEnableCompactUploader: userEnableCompactUploader,
      credentials: credentials,
    );

/// `/users/<User_ID>.json` `PATCH`
///
/// * `id` The ID of the user. The actual value is ignored, but something must
/// be supplied.
/// * `user[comment_threshold]`
/// * `user[default_image_size]`
/// * `user[favorite_tags]`
/// * `user[blacklisted_tags]`
/// * `user[time_zone]`
/// https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
/// * `user[per_page]`
/// * `user[custom_style]`
/// * `user[description_collapsed_initially]`
/// * `user[hide_comments]`
/// * `user[receive_email_notifications]`
/// * `user[enable_keyboard_navigation]`
/// * `user[enable_privacy_mode]`
/// * `user[disable_user_dmails]`
/// * `user[blacklist_users]`
/// * `user[show_post_statistics]`
/// * `user[style_usernames]`
/// * `user[show_hidden_comments]`
/// * `user[enable_autocomplete]`
/// * `user[disable_cropped_thumbnails]`
/// * `user[enable_safe_mode]`
/// * `user[disable_responsive_mode]`
/// * `user[dmail_filter_attributes][id]`
/// * `user[dmail_filter_attributes][words]`
/// * `user[profile_about]`
/// * `user[profile_artinfo]`
/// * `user[avatar_id]`
/// * `user[enable_compact_uploader]`
///
/// Note: As the actual value is ignored, the value is currently optional, for
/// if it becomes required at a later point.
http.Request initUserEdit({
  int userId = 1234,
  int? userCommentThreshold,
  String? userDefaultImageSize,
  String? userFavoriteTags,
  String? userBlacklistedTags,
  String? userTimeZone,
  int? userPerPage,
  String? userCustomStyle,
  bool? userDescriptionCollapsedInitially,
  bool? userHideComments,
  bool? userReceiveEmailNotifications,
  bool? userEnableKeyboardNavigation,
  bool? userEnablePrivacyMode,
  bool? userDisableUserDmails,
  bool? userBlacklistUsers,
  bool? userShowPostStatistics,
  bool? userStyleUsernames,
  bool? userShowHiddenComments,
  bool? userEnableAutocomplete,
  bool? userDisableCroppedThumbnails,
  bool? userEnableSafeMode,
  bool? userDisableResponsiveMode,
  int? userDmailFilterAttributesId,
  String? userDmailFilterAttributesWords,
  String? userProfileAbout,
  String? userProfileArtInfo,
  int? userAvatarId = -1,
  bool? userEnableCompactUploader,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/users/$userId.json",
      method: "PATCH",
      queryParameters: {
        if (userCommentThreshold != null)
          "user[comment_threshold]": userCommentThreshold,
        if (userDefaultImageSize != null)
          "user[default_image_size]": userDefaultImageSize,
        if (userFavoriteTags != null) "user[favorite_tags]": userFavoriteTags,
        if (userBlacklistedTags != null)
          "user[blacklisted_tags]": userBlacklistedTags,
        if (userTimeZone != null) "user[time_zone]`": userTimeZone,
        if (userPerPage != null) "user[per_page]": userPerPage,
        if (userCustomStyle != null) "user[custom_style]": userCustomStyle,
        if (userDescriptionCollapsedInitially != null)
          "user[description_collapsed_initially]":
              userDescriptionCollapsedInitially,
        if (userHideComments != null) "user[hide_comments]": userHideComments,
        if (userReceiveEmailNotifications != null)
          "user[receive_email_notifications]": userReceiveEmailNotifications,
        if (userEnableKeyboardNavigation != null)
          "user[enable_keyboard_navigation]": userEnableKeyboardNavigation,
        if (userEnablePrivacyMode != null)
          "user[enable_privacy_mode]": userEnablePrivacyMode,
        if (userDisableUserDmails != null)
          "user[disable_user_dmails]": userDisableUserDmails,
        if (userBlacklistUsers != null)
          "user[blacklist_users]": userBlacklistUsers,
        if (userShowPostStatistics != null)
          "user[show_post_statistics]": userShowPostStatistics,
        if (userStyleUsernames != null)
          "user[style_usernames]": userStyleUsernames,
        if (userShowHiddenComments != null)
          "user[show_hidden_comments]": userShowHiddenComments,
        if (userEnableAutocomplete != null)
          "user[enable_autocomplete]": userEnableAutocomplete,
        if (userDisableCroppedThumbnails != null)
          "user[disable_cropped_thumbnails]": userDisableCroppedThumbnails,
        if (userEnableSafeMode != null)
          "user[enable_safe_mode]": userEnableSafeMode,
        if (userDisableResponsiveMode != null)
          "user[disable_responsive_mode]": userDisableResponsiveMode,
        if (userDmailFilterAttributesId != null)
          "user[dmail_filter_attributes][id]": userDmailFilterAttributesId,
        if (userDmailFilterAttributesWords != null)
          "user[dmail_filter_attributes][words]":
              userDmailFilterAttributesWords,
        if (userProfileAbout != null) "user[profile_about]": userProfileAbout,
        if (userProfileArtInfo != null)
          "user[profile_artinfo]": userProfileArtInfo,
        if ((userAvatarId ?? 1) > 0) "user[avatar_id]": userAvatarId,
        if (userEnableCompactUploader != null)
          "user[enable_compact_uploader]": userEnableCompactUploader,
      },
      credentials: credentials,
    );
// #endregion Users
// #region Sets
/// https://e621.net/post_sets.json?search%5Bname%5D=*&search%5Bshortname%5D=*&search%5Bcreator_name%5D=baggie&search%5Bcreator_id%5D=427822&search%5Border%5D=name
/// `/post_sets.json` `GET`
/// * `search[name]` * wildcard
/// * `search[id]` * number (??or array of numbers??)
/// * `search[shortname]` * wildcard
/// * `search[creator_name]` Must be a username
/// * `search[creator_id]` Must be a user id
/// * `search[order]`
/// * `maintainer_id` A user with permissions to add and remove posts from the set; Must be a user id.
/// * `limit` How many items you want to retrieve. There is a hard limit of 320 items per request. Defaults to 75.
/// * `page` The page that will be returned. Can also be used with a or b + item_id to get the items after or before the specified item ID. For example a13 gets every item after item_id 13 up to the limit.
http.Request initSetSearch({
  String? searchName,
  String? searchShortname,
  // Iterable<int>? searchId,
  Iterable<int>? searchIds,
  int? searchId,
  String? searchCreatorName,
  int? searchCreatorId,
  se.SetOrder? searchOrder,
  int? maintainerId,
  int? limit = 75,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/post_sets.json",
      method: "GET",
      credentials: credentials,
      queryParameters: {
        if (searchName != null) "search[name]": searchName,
        if (searchShortname != null) "search[shortname]": searchShortname,
        // if (searchId?.isNotEmpty ?? false) "search[id]": searchId!.join(","),
        if ((searchIds?.isNotEmpty ?? false) && searchId != null)
          "search[id]": searchIds!.followedBy([searchId]).join(",")
        else if (searchId != null)
          "search[id]": searchId
        else if (searchIds?.isNotEmpty ?? false)
          "search[id]": searchIds!.join(","),
        if (searchCreatorName != null)
          "search[creator_name]": searchCreatorName,
        if (searchCreatorId != null) "search[creator_id]": searchCreatorId,
        if (searchOrder != null) "search[order]": searchOrder,
        if (maintainerId != null) "maintainer_id": maintainerId,
        if (limit != null) "limit": _validateLimit(limit),
        if (page != null) "page": page,
      },
    );

@Deprecated("Use initSetSearch")
http.Request initSearchSetsRequest({
  String? searchName,
  String? searchShortname,
  // Iterable<int>? searchId,
  Iterable<int>? searchIds,
  int? searchId,
  String? searchCreatorName,
  int? searchCreatorId,
  se.SetOrder? searchOrder,
  int? maintainerId,
  int? limit = 75,
  String? page,
  BaseCredentials? credentials,
}) =>
    initSearchSetsRequest(
      searchName: searchName,
      searchShortname: searchShortname,
      // searchId: searchId,
      searchIds: searchIds,
      searchId: searchId,
      searchCreatorName: searchCreatorName,
      searchCreatorId: searchCreatorId,
      searchOrder: searchOrder,
      maintainerId: maintainerId,
      limit: limit,
      page: page,
      credentials: credentials,
    );

/// https://e621.net/post_sets/35356.json
/// `/post_sets/$setId.json` `GET`
http.Request initSetGet(
  int setId, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/post_sets/$setId.json",
      method: "GET",
      credentials: credentials,
    );
@Deprecated("Use initSetGet")
http.Request initGetSetRequest(
  int setId, {
  BaseCredentials? credentials,
}) =>
    initSetGet(setId, credentials: credentials);

@Deprecated("Use initSetEdit")
http.Request initUpdateSetRequest(
  int setId, {
  String? postSetName,
  String? postSetShortname,
  String? postSetDescription,
  bool? postSetIsPublic,
  bool? postSetTransferOnDelete,
  BaseCredentials? credentials,
}) =>
    initSetEdit(
      setId,
      postSetName: postSetName,
      postSetShortname: postSetShortname,
      postSetDescription: postSetDescription,
      postSetIsPublic: postSetIsPublic,
      postSetTransferOnDelete: postSetTransferOnDelete,
      credentials: credentials,
    );

/// `/post_sets/$setId.json` `PATCH`
/// * `post_set[name]`
/// * `post_set[shortname]` The short name is used for the set's metatag name. Can only contain letters, numbers, and underscores and must contain at least one letter or underscore. set:example
/// * `post_set[description]`
/// * `post_set[is_public]` Private sets are only visible to you. Public sets are visible to anyone, but only you and users you assign as maintainers can edit the set. Only accounts three days or older can make public sets.
/// * `post_set[transfer_on_delete]` If "Transfer on Delete" is enabled, when a post is deleted from the site, its parent (if any) will be added to this set in its place. Disable if you want posts to simply be removed from this set with no replacement.
http.Request initSetEdit(
  int setId, {
  String? postSetName,
  String? postSetShortname,
  String? postSetDescription,
  bool? postSetIsPublic,
  bool? postSetTransferOnDelete,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/post_sets/$setId.json",
      method: "PATCH",
      credentials: credentials,
      queryParameters: {
        if (postSetName != null) "post_set[name]": postSetName,
        if (postSetShortname != null) "post_set[shortname]": postSetShortname,
        if (postSetDescription != null)
          "post_set[description]": postSetDescription,
        if (postSetIsPublic != null) "post_set[is_public]": postSetIsPublic,
        if (postSetTransferOnDelete != null)
          "post_set[transfer_on_delete]": postSetTransferOnDelete,
      },
    );
@Deprecated("Use initSetCreate")
http.Request initCreateSetRequest({
  required String postSetName,
  required String postSetShortname,
  String? postSetDescription,
  bool? postSetIsPublic,
  bool? postSetTransferOnDelete,
  BaseCredentials? credentials,
}) =>
    initSetCreate(
      postSetName: postSetName,
      postSetShortname: postSetShortname,
      postSetDescription: postSetDescription,
      postSetIsPublic: postSetIsPublic,
      postSetTransferOnDelete: postSetTransferOnDelete,
      credentials: credentials,
    );

/// `/post_sets/$setId.json` `POST`
/// * `post_set[name]`
/// * `post_set[shortname]` The short name is used for the set's metatag name. Can only contain letters, numbers, and underscores and must contain at least one letter or underscore. set:example
/// * `post_set[description]`
/// * `post_set[is_public]` Private sets are only visible to you. Public sets are visible to anyone, but only you and users you assign as maintainers can edit the set. Only accounts three days or older can make public sets.
/// * `post_set[transfer_on_delete]` If "Transfer on Delete" is enabled, when a post is deleted from the site, its parent (if any) will be added to this set in its place. Disable if you want posts to simply be removed from this set with no replacement.
///
/// Success: 201
///
/// Returns the created set.
/// {@macro setListing}
///
/// Error:
/// 422 {"errors":{"name":["must be between three and one hundred characters long"],"shortname":["must be between three and fifty characters long","must only contain numbers, lowercase letters, and underscores","must contain at least one lowercase letter or underscore"]}}
http.Request initSetCreate({
  required String postSetName,
  required String postSetShortname,
  String? postSetDescription,
  bool? postSetIsPublic,
  bool? postSetTransferOnDelete,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/post_sets.json",
      method: "POST",
      credentials: credentials,
      queryParameters: {
        "post_set[name]": postSetName,
        "post_set[shortname]": postSetShortname,
        if (postSetDescription != null)
          "post_set[description]": postSetDescription,
        if (postSetIsPublic != null) "post_set[is_public]": postSetIsPublic,
        if (postSetTransferOnDelete != null)
          "post_set[transfer_on_delete]": postSetTransferOnDelete,
      },
    );
@Deprecated("Use initSetAddPosts")
http.Request initAddToSetRequest(
  int setId,
  List<int> postIds, {
  BaseCredentials? credentials,
}) =>
    initSetAddPosts(
      setId,
      postIds,
      credentials: credentials,
    );

/// `/post_sets/$setId/add_posts.json` `POST`
/// * `post_ids[]` space separated list (i think)
///
/// Success: `HTTP 201` with the body of the chosen set.
http.Request initSetAddPosts(
  int setId,
  List<int> postIds, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/post_sets/$setId/add_posts.json",
      method: "POST",
      credentials: credentials,
      queryParameters: {
        "post_ids[]": postIds,
      },
    );
@Deprecated("Use initSetRemovePosts")
http.Request initRemoveFromSetRequest(
  int setId,
  List<int> postIds, {
  BaseCredentials? credentials,
}) =>
    initSetRemovePosts(
      setId,
      postIds,
      credentials: credentials,
    );

/// `/post_sets/$setId/remove_posts.json` `POST`
/// * `post_ids[]` space separated list (i think)
///
/// Success: `201` with the body of the chosen set.
http.Request initSetRemovePosts(
  int setId,
  List<int> postIds, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/post_sets/$setId/remove_posts.json",
      method: "POST",
      credentials: credentials,
      queryParameters: {
        "post_ids[]": postIds,
      },
    );
@Deprecated("Use initSetGetModifiable")
http.Request initGetModifiableSetsRequest({
  BaseCredentials? credentials,
}) =>
    initSetGetModifiable(credentials: credentials);

/// `/post_sets/for_select.json` `GET`
///
/// You must be the owner of the set, a maintainer (if public), or Admin+.
///
/// Responses:
/// * `200` See ModifiablePostSets.
/// * `403` Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
/// * `422` Invalid Input Data
/// ```
/// {
///   "errors": {
///     "key": [
///       "the error"
///     ]
///   }
/// }
/// ```
http.Request initSetGetModifiable({
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/post_sets/for_select.json",
      method: "GET",
      credentials: credentials,
    );

@Deprecated("Use initSetEditPosts")
http.Request initUpdateSetPostsRequest(
  int setId,
  List<int> postIds, {
  BaseCredentials? credentials,
}) =>
    initSetEditPosts(setId, postIds, credentials: credentials);

/// `/post_sets/$setId/update_posts.json` `POST`
/// * `post_ids_string[]` space separated list (i think) of ALL posts in set
///
/// Success: `302` with a redirect.
http.Request initSetEditPosts(
  int setId,
  List<int> postIds, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/post_sets/$setId/update_posts.json",
      method: "POST",
      credentials: credentials,
      queryParameters: {
        "post_set[post_ids_string]":
            foldIterableForUrl(postIds, allowEmpty: false),
      },
    );
// #endregion Sets
// #region Pools
@Deprecated("Use initPoolSearch")
http.Request initSearchPoolsRequest({
  String? searchNameMatches,
  Iterable<int>? searchIds,
  int? searchId,
  String? searchDescriptionMatches,
  String? searchCreatorName,
  int? searchCreatorId,
  bool? searchIsActive,
  ge.PoolCategory? searchCategory,
  se.PoolOrder? searchOrder,
  int? limit,
  BaseCredentials? credentials,
}) =>
    initPoolSearch(
      searchNameMatches: searchNameMatches,
      searchIds: searchIds,
      searchId: searchId,
      searchDescriptionMatches: searchDescriptionMatches,
      searchCreatorName: searchCreatorName,
      searchCreatorId: searchCreatorId,
      searchIsActive: searchIsActive,
      searchCategory: searchCategory,
      searchOrder: searchOrder,
      limit: limit,
      credentials: credentials,
    );

/// https://e621.net/wiki_pages/2425#pools_listing
///
/// The base URL is `/pools.json` called with `GET`.
///
/// * `search[name_matches]` Search pool names.
/// * `search[id]` Search for a pool ID.
/// {@macro cslParam}
/// * `search[description_matches]` Search pool descriptions.
/// * `search[creator_name]` Search for pools based on creator name.
/// * `search[creator_id]` Search for pools based on creator ID.
/// TODO: test for comma separated list support.
/// * `search[is_active]` If the pool is active or hidden. (True/False)
/// * `search[category]` Can either be “series” or “collection”.
/// * `search[order]` The order that pools should be returned, can be any of: name, created_at, updated_at, post_count. If not specified it orders by updated_at
/// * `limit` The limit of how many pools should be retrieved.
/// This returns a JSON array, for each pool it returns:
/// {@template poolListing}
/// * `id` The ID of the pool.
/// * `name` The name of the pool.
/// * `created_at` The time the pool was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
/// * `updated_at` The time the pool was updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
/// * `creator_id` the ID of the user that created the pool.
/// * `description` The description of the pool.
/// * `is_active` If the pool is active and still getting posts added. (True/False)
/// * `category` Can be `series` or `collection`. *[ge.PoolCategory]*
/// * `post_ids` An array group of posts in the pool.
/// * `creator_name` The name of the user that created the pool.
/// * `post_count` the amount of posts in the pool.
/// {@endtemplate}
http.Request initPoolSearch({
  String? searchNameMatches,
  Iterable<int>? searchIds,
  int? searchId,
  String? searchDescriptionMatches,
  String? searchCreatorName,
  int? searchCreatorId,
  bool? searchIsActive,
  ge.PoolCategory? searchCategory,
  se.PoolOrder? searchOrder,
  int? limit,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/pools.json",
      queryParameters: {
        if (searchNameMatches != null)
          "search[name_matches]": searchNameMatches,
        if ((searchIds?.isNotEmpty ?? false) && searchId != null)
          "search[id]": searchIds!.followedBy([searchId]).join(",")
        else if (searchIds?.isNotEmpty ?? false)
          "search[id]": searchIds!.join(",")
        else if (searchId != null)
          "search[id]": searchId,
        if (searchDescriptionMatches != null)
          "search[description_matches]": searchDescriptionMatches,
        if (searchCreatorName != null)
          "search[creator_name]": searchCreatorName,
        if (searchCreatorId != null) "search[creator_id]": searchCreatorId,
        if (searchIsActive != null) "search[is_active]": searchIsActive,
        if (searchCategory != null) "search[category]": searchCategory,
        if (searchOrder != null) "search[order]": searchOrder,
        if (limit != null) "limit": limit,
      },
      credentials: credentials,
      method: "GET",
    );

@Deprecated("Use initPoolGet")
http.Request initGetPoolRequest(
  int poolId, {
  BaseCredentials? credentials,
}) =>
    initPoolGet(poolId, credentials: credentials);

/// https://e621.net/wiki_pages/2425#pools_listing
///
/// The base URL is `/pools/$poolId.json` called with `GET`.
///
/// * `search[name_matches]` Search pool names.
/// * `search[id]` Search for a pool ID, you can search for multiple IDs at once, separated by commas.
/// * `search[description_matches]` Search pool descriptions.
/// * `search[creator_name]` Search for pools based on creator name.
/// * `search[creator_id]` Search for pools based on creator ID.
/// * `search[is_active]` If the pool is active or hidden. (True/False)
/// * `search[category]` Can either be “series” or “collection”.
/// * `search[order]` The order that pools should be returned, can be any of: name, created_at, updated_at, post_count. If not specified it orders by updated_at
/// * `limit` The limit of how many pools should be retrieved.
///
/// This returns a JSON object:
/// {@macro poolListing}
http.Request initPoolGet(
  int poolId, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/pools/$poolId.json",
      credentials: credentials,
      method: "GET",
    );
@Deprecated("Use initPoolEdit")
http.Request initUpdatePoolRequest(
  int poolId, {
  String? poolName,
  String? poolDescription,
  Iterable<int>? poolPostIds,
  int? poolIsActive,
  ge.PoolCategory? poolCategory,
  BaseCredentials? credentials,
}) =>
    initPoolEdit(
      poolId,
      poolName: poolName,
      poolDescription: poolDescription,
      poolPostIds: poolPostIds,
      poolIsActive: poolIsActive,
      poolCategory: poolCategory,
      credentials: credentials,
    );

/// https://e621.net/wiki_pages/2425#pools_update
///
/// The base URL is `/pools/$poolId.json` called with `PUT`.
///
/// Only post parameters you want to update.
///
/// * `pool[name]` The name of the pool.
/// * `pool[description]` The description of the pool.
/// * `pool[post_ids]` List of space delimited post ids in order of where they should be in the pool.
/// * `pool[is_active]` Can be either 1 or 0
/// TODO: Test which is true and which is false and then replace w/ an according boolean parameter.
/// * `pool[category]` Can be either `series` or `collection`.
///
/// Success will return the pool in the format:
/// {@macro poolListing}
http.Request initPoolEdit(
  int poolId, {
  String? poolName,
  String? poolDescription,
  Iterable<int>? poolPostIds,
  int? poolIsActive,
  ge.PoolCategory? poolCategory,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/pools/$poolId.json",
      queryParameters: {
        if (poolName != null) "pool[name]": poolName,
        if (poolDescription != null) "pool[description]": poolDescription,
        if (poolPostIds?.isNotEmpty ?? false)
          "pool[post_ids]": poolPostIds!.join(" "),
        // if (poolIsActive != null)
        if (poolIsActive == 0 || poolIsActive == 1)
          "pool[is_active]": poolIsActive,
        if (poolCategory != null) "pool[category]": poolCategory,
      },
      method: "PUT",
      credentials: credentials,
    );

/// https://e621.net/wiki_pages/2425#pools_create
///
/// The base URL is `/pools.json` called with `POST`.
///
/// The pool’s name and description are required, though the description can be empty.
///
/// * `pool[name]` The name of the pool.
/// * `pool[description]` The description of the pool.
/// * `pool[category]` Can be either `series` or `collection`.
/// * `pool[is_locked]` 1 or 0, whether or not the pool is locked. Admin only function.
///
/// Success will return the pool in the format:
/// {@macro poolListing}
http.Request initCreatePoolRequest({
  String? poolName,
  String? poolDescription,
  ge.PoolCategory? poolCategory,
  int? poolIsLocked,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/pools.json",
      queryParameters: {
        if (poolName != null) "pool[name]": poolName,
        if (poolDescription != null) "pool[description]": poolDescription,
        if (poolCategory != null) "pool[category]": poolCategory,
        if (poolIsLocked != null) "pool[is_locked]": poolIsLocked,
      },
      credentials: credentials,
      method: "POST",
    );

/// https://e621.net/wiki_pages/2425#pools_revert
///
/// The base URL is `/pools/<Pool_ID>/revert.json` called with `PUT`.
///
/// * `version_id` The version ID to revert to.
http.Request initRevertPoolRequest(
  int poolId, {
  int? versionId,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/pools/$poolId/revert.json",
      queryParameters: {
        if (versionId != null) "version_id": versionId,
      },
      method: "PUT",
      credentials: credentials,
    );
// #endregion Pools
// #region Comments
/// The base URL is `/comments.json` called with `GET`.
///
/// For searching comments, group_by=comment must be set. When no results are found, an object with a comments key is returned.
///
/// {@macro limitRoot}
/// {@macro pageRoot}
/// * `search[id]` Search for a specific id.
/// {@template cslParam}
/// Accepts a comma separated list.
/// {@endtemplate}
/// * `search[ip_addr]` Must be [ge.UserLevel.admin]+ to use. See
/// [postgres' documentation](https://www.postgresql.org/docs/9.3/functions-net.html)
///  for information on how this is parsed. Specifically, "is contained within
/// or equals" (<<=).
/// {@template orderRoot}
/// * `search[order]` The order that items should be returned, can be any of:
/// {@endtemplate}
/// `id_asc`, `id_desc`, `status`, `status_desc`~~, `updated_at_desc`~~. If not
/// specified it orders by ??? **Note**: the docs say `updated_at_desc` is an
/// option, and it works with the non-json endpoint, but fails if used. + there's
/// other seeming discrepancies. All the remaining values in [se.CommentOrder]
/// are validated to have the desired effect and not fail.
/// * `group_by` Can be either: `comment`, or `post`. If null, server treats as `post`. **Note**: As the
/// [se.CommentGrouping.post] option returns the posts and not the comments
/// grouped by posts, it's recommended to leave this at the default value of
/// [se.CommentGrouping.comment]. If null, server treats as `post`.
/// * `search[body_matches]` Search the body text.
/// TODO: test wildcard support.
/// * `search[post_id]` Search for items based on post ID.
/// {@macro cslParam}
/// * `search[post_tags_matches]` Search by post tags.
/// * `search[post_note_updater_name]`
/// * `search[post_note_updater_id]`
/// TODO: test for comma separated list support.
/// * `search[creator_name]` Search for items based on creator name.
/// TODO: test for comma separated list support.
/// * `search[creator_id]` Search for items based on creator ID.
/// * `search[is_sticky]` If the comment is sticky or not. (True/False)
/// * `search[is_hidden]` If the comment is hidden or not. (True/False) Only usable by Moderator+
/// * `search[do_not_bump_post]` (True/False)
///
/// This returns a JSON array, for each item it returns:
/// {@template jsonComment}
/// * `id` `number`
/// * `created_at` `date-time`
/// * `post_id` `number`
/// * `creator_id` `number`
/// * `body` `string`
/// * `score` `number`
/// * `updated_at` `date-time`
/// * `updater_id` `number`
/// * `do_not_bump_post` `boolean deprecated`
/// * `is_hidden` `boolean`
/// * `is_sticky` `boolean`
/// * `warning_type` `string | null ("warning","record","ban")`
/// * `warning_user_id` `number | null`
/// * `creator_name` `string`
/// * `updater_name` `string`
/// {@endtemplate}
http.Request initSearchCommentsRequest({
  int? limit,
  String? page,
  int? searchId,
  Iterable<int>? searchIds,
  String? searchIpAddr,
  se.CommentOrder? searchOrder,
  se.CommentGrouping? groupBy = se.CommentGrouping.comment,
  String? searchBodyMatches,
  int? searchPostId,
  Iterable<int>? searchPostIds,
  String? searchPostTagsMatches,
  String? searchPostNoteUpdaterName,
  int? searchPostNoteUpdaterId,
  String? searchCreatorName,
  int? searchCreatorId,
  bool? searchIsSticky,
  bool? searchIsHidden,
  bool? searchDoNotBumpPost,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/comments.json",
      queryParameters: {
        if (limit != null) "limit": limit,
        if (page != null) "page": page,
        if ((searchIds?.isNotEmpty ?? false) || searchId != null)
          "search[id]": (searchIds?.isNotEmpty ?? false)
              ? (searchId != null
                      ? searchIds!.followedBy([searchId])
                      : searchIds!)
                  .join(",")
              : searchId,
        // if (searchIds != null && searchId != null)
        //   "search[id]": searchIds
        //     ..add(searchId)
        //     ..join(",")
        // else if (searchIds != null)
        //   "search[id]": searchIds.join(",")
        // else if (searchId != null)
        //   "search[id]": searchId,
        if (searchIpAddr != null) "search[ip_addr]": searchIpAddr,
        if (searchOrder != null) "search[order]": searchOrder,
        if (groupBy != null) "group_by": groupBy,
        if (searchBodyMatches != null)
          "search[body_matches]": searchBodyMatches,
        if ((searchPostIds?.isNotEmpty ?? false) || searchPostId != null)
          "search[post_id]": (searchPostIds?.isNotEmpty ?? false)
              ? (searchPostId != null
                      ? searchPostIds!.followedBy([searchPostId])
                      : searchIds!)
                  .join(",")
              : searchPostId,
        // if (searchPostIds != null && searchPostId != null)
        //   "search[post_id]": searchPostIds.followedBy([searchPostId]).join(",")
        // else if (searchPostIds != null)
        //   "search[post_id]": searchPostIds.join(",")
        // else if (searchPostId != null)
        //   "search[post_id]": searchPostId,
        if (searchPostTagsMatches != null)
          "search[post_tags_matches]": searchPostTagsMatches,
        if (searchPostNoteUpdaterName != null)
          "search[post_note_updater_name]": searchPostNoteUpdaterName,
        if (searchPostNoteUpdaterId != null)
          "search[post_note_updater_id]": searchPostNoteUpdaterId,
        if (searchCreatorName != null)
          "search[creator_name]": searchCreatorName,
        if (searchCreatorId != null) "search[creator_id]": searchCreatorId,
        if (searchIsSticky != null) "search[is_sticky]": searchIsSticky,
        if (searchIsHidden != null) "search[is_hidden]": searchIsHidden,
        if (searchDoNotBumpPost != null)
          "search[do_not_bump_post]": searchDoNotBumpPost,
      },
      credentials: credentials,
      method: "GET",
    );

/// The base URL is `/comments/$id.json` called with `GET`.
///
/// If the comment is hidden, you must be the creator or Moderator+ to see it.
///
/// * `id` The ID of the comment.
///
/// Responses:
///
/// 200 Success {@macro jsonComment}
http.Request initGetCommentRequest({
  required int id,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/comments/$id.json",
      credentials: credentials,
      method: "GET",
    );

/// The base URL is `/comments.json` called with `POST`.
///
/// * `comment[body]`
/// * `comment[post_id]`
/// * `comment[do_not_bump_post]`
/// * `comment[is_sticky]` Only usable for Janitor+
/// * `comment[is_hidden]` Only usable for Moderator+
///
/// Responses:
/// 201 Success
/// {@macro jsonComment}
///
/// 403 Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
///
/// 422 Invalid Input Data
/// ```
/// {
///   "errors": {
///     "key": [
///       "the error"
///     ]
///   }
/// }
/// ```
http.Request initCreateCommentRequest({
  required String commentBody,
  required int commentPostId,
  bool? commentDoNotBumpPost,
  bool? commentIsSticky,
  bool? commentIsHidden,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/comments.json",
      queryParameters: {
        "comment[body]": commentBody,
        "comment[post_id]": commentPostId,
        if (commentDoNotBumpPost != null)
          "comment[do_not_bump_post]": commentDoNotBumpPost,
        if (commentIsSticky != null) "comment[is_sticky]": commentIsSticky,
        if (commentIsHidden != null) "comment[is_hidden]": commentIsHidden,
      },
      credentials: credentials,
      method: "POST",
    );

/// The base URL is `/comments/$id.json` called with `PATCH`.
///
/// You must be the creator of the comment, or Admin+ to edit. Marked comments cannot be edited.
///
/// * `id` The ID of the comment.
/// * `comment[body]`
/// * `comment[is_sticky]` Only usable for Janitor+
/// * `comment[is_hidden]` Only usable for Moderator+
///
/// Responses:
/// 204 Success ??No body??
///
/// 403 Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
///
/// 404 Not Found
/// ```
/// {
///   "success": false,
///   "reason": "not found"
/// }
/// ```
///
/// 422 Invalid Input Data
/// ```
/// {
///   "errors": {
///     "key": [
///       "the error"
///     ]
///   }
/// }
/// ```
http.Request initUpdateCommentRequest(
  int id, {
  String? commentBody,
  bool? commentIsSticky,
  bool? commentIsHidden,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/comments/$id.json",
      queryParameters: {
        if (commentBody != null) "comment[body]": commentBody,
        if (commentIsSticky != null) "comment[is_sticky]": commentIsSticky,
        if (commentIsHidden != null) "comment[is_hidden]": commentIsHidden,
      },
      credentials: credentials,
      method: "PATCH",
    );

/// The base URL is `/comments/$id.json` called with `DELETE`.
///
/// You must be Admin+.
///
/// * `id` The ID of the comment.
///
/// Responses:
/// 204 Success ??No body??
///
/// 403 Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
///
/// 404 Not Found
/// ```
/// {
///   "success": false,
///   "reason": "not found"
/// }
/// ```
///
/// 422 Invalid Input Data
/// ```
/// {
///   "errors": {
///     "key": [
///       "the error"
///     ]
///   }
/// }
/// ```
http.Request initDeleteCommentRequest(
  int id, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/comments/$id.json",
      credentials: credentials,
      method: "DELETE",
    );

/// The base URL is `/comments/$id/hide.json` called with `POST`.
///
/// You must be the creator or Moderator+.
///
/// * `id` The ID of the comment.
///
/// Responses:
/// 201 Success
/// {@macro jsonComment}
///
/// 403 Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
///
/// 404 Not Found
/// ```
/// {
///   "success": false,
///   "reason": "not found"
/// }
/// ```
http.Request initHideCommentRequest(
  int id, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/comments/$id/hide.json",
      credentials: credentials,
      method: "POST",
    );

/// The base URL is `/comments/$id/unhide.json` called with `POST`.
///
/// You must be Moderator+.
///
/// * `id` The ID of the comment.
///
/// Responses:
/// 201 Success
/// {@macro jsonComment}
///
/// 403 Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
///
/// 404 Not Found
/// ```
/// {
///   "success": false,
///   "reason": "not found"
/// }
/// ```
http.Request initUnhideCommentRequest(
  int id, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/comments/$id/unhide.json",
      credentials: credentials,
      method: "POST",
    );

/// The base URL is `/comments/$id/warning.json` called with `POST`.
///
/// You must be Moderator+.
///
/// * `id` The ID of the comment.
/// * `record_type`
///
/// Responses:
/// 201 Success
/// See DTextResponse
///
/// 403 Access Denied
/// ```
/// {
///   "success": false,
///   "reason": "Access Denied"
/// }
/// ```
///
/// 404 Not Found
/// ```
/// {
///   "success": false,
///   "reason": "not found"
/// }
/// ```
http.Request initWarnCommentRequest(
  int id,
  ge.WarningType recordType, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsRequired(
      path: "/comments/$id/warning.json",
      queryParameters: {"record_type": recordType.query},
      credentials: credentials,
      method: "POST",
    );

// #endregion Comments
// TODO: Post Versions endpoint
// #region Post Versions
/* /// https://e621.net/post_versions?search%5Bupdater_name%5D=a&search%5Bpost_id%5D=1&search%5Breason%5D=a&search%5Bdescription%5D=a&search%5Bdescription_changed%5D=true&search%5Brating_changed%5D=any&search%5Brating%5D=s&search%5Bparent_id%5D=10&search%5Bparent_id_changed%5D=1&search%5Btags%5D=1&search%5Btags_added%5D=1&search%5Btags_removed%5D=1&search%5Blocked_tags%5D=1&search%5Blocked_tags_added%5D=1&search%5Blocked_tags_removed%5D=1&search%5Bsource_changed%5D=true&search%5Buploads%5D=excluded&commit=Search
///
/// The base URL is `/post_versions.json` called with `GET`.
///
/// * `limit` The limit of how many items should be retrieved. */
// #endregion Post Versions
// TODO: Artists endpoint
// #region Artists
// https://e621.net/artists
// https://e621.net/artists.json
// #endregion Artists
// #region Wiki
/// [Search](https://e621.net/wiki_pages.json?search%5Btitle%5D=unknown_artist)
///
/// The base URL is `/wiki_pages.json` called with `GET`.
/// * `search[title]`: unknown_artist
/// * `search[body_matches]`:
/// * `search[creator_name]`:
/// {@template notWild}
/// Doesn't support * wildcard.
/// {@endtemplate}
/// Must be exact. Doesn't work for blocked users?
/// * `search[parent]`: The page this entry redirects to.
/// {@template wild}
/// Supports * wildcard.
/// {@endtemplate}
/// * `search[other_names_match]`:
/// * `search[other_names_present]`:
/// * `search[hide_deleted]`:
/// * `search[order]`:
/// {@macro limitRoot}
/// {@macro pageRoot}
///
/// NOTE: For some reason, `search[other_names_present]`
/// & `search[hide_deleted]`, if present, are sent as `Yes` or `No` in the
/// query string for the web form, and not as `true`/`false`. However, it
/// appears normal boolean values work fine.
/// TODO: RETURNS
http.Request initWikiSearchRequest({
  String? searchTitle,
  String? searchBodyMatches,
  String? searchCreatorName,
  String? searchParent,
  String? searchOtherNamesMatch,
  bool? searchOtherNamesPresent,
  bool? searchHideDeleted,
  se.WikiOrder? searchOrder,
  int? limit,
  String? page,
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/wiki_pages.json",
      queryParameters: {
        if (searchTitle != null) "search[title]": searchTitle,
        if (searchBodyMatches != null)
          "search[body_matches]": searchBodyMatches,
        if (searchCreatorName != null)
          "search[creator_name]": searchCreatorName,
        if (searchParent != null) "search[parent]": searchParent,
        if (searchOtherNamesMatch != null)
          "search[other_names_match]": searchOtherNamesMatch,
        if (searchOtherNamesPresent != null)
          "search[other_names_present]": searchOtherNamesPresent,
        if (searchHideDeleted != null)
          "search[hide_deleted]": searchHideDeleted,
        if (searchOrder != null) "search[order]": searchOrder,
        if (limit != null) "limit": limit,
        if (page != null) "page": page,
      },
      method: "GET",
      credentials: credentials,
    );

/// Get
/// https://e621.net/wiki_pages/118.json
/// The base URL is `/wiki_pages/${id}.json` called with `GET`.
/// id: Wiki Id
http.Request initWikiGetPageRequest(
  int id, {
  BaseCredentials? credentials,
}) =>
    _baseInitRequestCredentialsOptional(
      path: "/wiki_pages/$id.json",
      method: "GET",
      credentials: credentials,
    );
// #endregion Wiki
// #endregion Requests
