import 'dart:async';
// import 'dart:collection' show ListQueue;
import 'dart:convert' as dc;
import 'package:e621/src/models.dart';
import 'package:http/http.dart' as http;

import 'credentials.dart';
import 'e621.dart';

// import 'general_enums.dart' as ge;
// import 'search_enums.dart' as se;
/// TODO: Copy to lib
class FutureResolver<T> implements Future<T> {
  final FutureOr<T> value;
  late final T $;
  Future<T> get $Async => hasValue
      ? Future.value($)
      : !hasError
          ? value as Future<T>
          : Future<T>.error(_error, _stackTrace);
  T? get $Safe => hasValue ? $ : null;
  bool _hasError = false, _isComplete = false;
  bool get isComplete => _isComplete;
  bool get hasValue => isComplete && !hasError;
  bool get hasError => _hasError;
  late final Object _error;
  late final StackTrace _stackTrace;
  FutureResolver(this.value) {
    switch (value) {
      case Future<T> f:
        f.then((v) {
          _isComplete = true;
          return $ = v;
        }, onError: (Object error, StackTrace stackTrace) {
          _hasError = true;
          _error = error;
          _stackTrace = stackTrace;
          return Error.throwWithStackTrace(error, stackTrace);
        });
        break;
      case T v:
        $ = v;
        _isComplete = true;
        break;
    }
  }
  Future<T> get _asFuture =>
      _ifStillFutureOrNotError ?? Future<T>.error(_error, _stackTrace);
  bool get isStillFuture => value is Future<T> && !isComplete;
  bool get isStillFutureOrNotError => !hasError;
  Future<T>? get _ifStillFuture => isStillFuture ? (value as Future<T>) : null;
  Future<T>? get _ifStillFutureOrNotError =>
      _ifStillFuture ?? (!hasError ? Future.value($) : null);
  @override
  Stream<T> asStream() => _ifStillFuture?.asStream() ?? Stream.empty();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _ifStillFuture?.catchError(onError, test: test) ??
      (!hasError
          ? Future.value($)
          : ((test?.call(_error) ?? true)
              ? Future.value(onError(_error, _stackTrace))
              : Future<T>.error(_error, _stackTrace)));

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) =>
      _ifStillFuture?.then(onValue, onError: onError) ??
      (!hasError
          ? (onError != null
              ? Future.value(onValue($)).catchError(onError)
              : Future.value(onValue($)))
          : Future<T>.error(_error, _stackTrace)
              .then(onValue, onError: onError));

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _asFuture.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _asFuture.whenComplete(action);
}

/// Use this to automatically enforce rate limit.
// ignore: unnecessary_late
late http.Client client = http.Client();

// #region Rate Limit
/// The hard rate limit in seconds per request.
///
/// `hardRateLimit = Duration(seconds: 1);`
const hardRateLimit = Duration(seconds: 1);

/// The soft rate limit in seconds per request.
///
/// `softRateLimit = Duration(seconds: 2);`
const softRateLimit = Duration(seconds: 2);

/// The ideal rate limit in seconds per request.
///
/// The ideal rate limit is a way to ensure that the true rate limit is never even approached.
///
/// `idealRateLimit = Duration(seconds: 3);`
const idealRateLimit = Duration(seconds: 3);
bool forceHardLimit = false;
bool useIdealLimit = true;
Duration get currentRateLimit => forceHardLimit
    ? hardRateLimit
    : useIdealLimit
        ? idealRateLimit
        : softRateLimit;
DateTime timeOfLastRequest =
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
// #region Burst
int defaultBurstLimit = 60;
int get currentBurstLimit => defaultBurstLimit;

/// TODO: Figure out and implement burst api call restrictions and allowances.
// ListQueue<DateTime> burstTimes = ListQueue(defaultBurstLimit - 1);
List<DateTime> burstTimes = <DateTime>[];

// #endregion Burst
extension _A on ApiStreamEvent {
  ApiStreamEvent addTo(StreamController<ApiStreamEvent> controller) {
    controller.add(this);
    return this;
  }
}

typedef ApiStreamEvent = (FutureResolver<http.Response>, DateTime);
final StreamController<ApiStreamEvent> _responseStreamController =
    StreamController<ApiStreamEvent>.broadcast(
  onListen: _onListen,
  onCancel: _onCancel,
);
Stream<ApiStreamEvent> get responseStream => _responseStreamController.stream;

void _onListen() {}
// void _onPause() {}
// void _onResume() {}
void _onCancel() {}
Future<http.Response> _streamedToNon(http.StreamedResponse v) =>
    v.stream.toBytes().then((t) => http.Response.bytes(
          t,
          v.statusCode,
          headers: v.headers,
          isRedirect: v.isRedirect,
          persistentConnection: v.persistentConnection,
          reasonPhrase: v.reasonPhrase,
          request: v.request,
        ));
Future<http.Response> _addToController(
  Future<http.StreamedResponse> r,
  DateTime ts,
) =>
    r.then((v) => (FutureResolver(_streamedToNon(v)), ts)
        .addTo(_responseStreamController)
        .$1
        ._asFuture);

/// Won't blow the rate limit
///
/// If [addToStream] is true, will add to [responseStream] and return a
/// [http.Response]; else, will not add to [responseStream] and will return
/// a [http.StreamedResponse].
Future<T> _sendRequest<T extends http.BaseResponse>(
  http.BaseRequest request, {
  @Deprecated("Does nothing; needs more research to implement correctly")
  bool useBurst = false,
  bool overrideRateLimit = false,
  bool addToStream = true,
}) {
  Future<T> doTheThing() async => (await (/* addToStream */ T == http.Response
      ? _addToController(
          client.send(request),
          timeOfLastRequest = DateTime.timestamp(),
        )
      : (() {
          timeOfLastRequest = DateTime.timestamp();
          return client.send(request);
        })())) as T;

  var t = DateTime.timestamp().difference(timeOfLastRequest);
  if (t >= currentRateLimit || overrideRateLimit) {
    return doTheThing();
  } else {
    // if (useBurst && burstTimes.length < currentBurstLimit) {
    //   doTheThing() {
    //     final ts = DateTime.timestamp();
    //     burstTimes.add(ts);
    //     print(burstTimes.length);
    //     // Future.delayed(currentRateLimit, () => burstTimes.remove(ts)).ignore();
    //     return client.send(request)
    //       ..then((v) => burstTimes.remove(
    //           ts)) /* ..then((v) => _responseStreamController.add((v, ts))).ignore() */;
    //   }

    //   var t = DateTime.timestamp()
    //       .difference(burstTimes.lastOrNull ?? timeOfLastRequest);
    //   return t >= softRateLimit || overrideRateLimit
    //       ? doTheThing()
    //       : Future.delayed(softRateLimit - t, doTheThing);
    // }
    return Future.delayed(currentRateLimit - t, doTheThing);
  }
}

/// Won't blow the rate limit
///
/// Will not add to the [responseStream]
Future<http.StreamedResponse> sendRequestStreamed(
  http.BaseRequest request, {
  @Deprecated("Does nothing; needs more research to implement correctly")
  bool useBurst = false,
  bool overrideRateLimit = false,
}) =>
    _sendRequest<http.StreamedResponse>(request,
        // ignore: deprecated_member_use_from_same_package
        useBurst: useBurst,
        overrideRateLimit: overrideRateLimit,
        addToStream: false);

/// Won't blow the rate limit
Future<http.Response> sendRequest(
  http.BaseRequest request, {
  @Deprecated("Does nothing; needs more research to implement correctly")
  bool useBurst = false,
  bool overrideRateLimit = false,
  bool addToStream = true,
}) =>
    addToStream
        ? _sendRequest<http.Response>(request,
            // ignore: deprecated_member_use_from_same_package
            useBurst: useBurst,
            addToStream: true)
        : _sendRequest<http.StreamedResponse>(request,
                // ignore: deprecated_member_use_from_same_package
                useBurst: useBurst,
                addToStream: false)
            .then((v) async => http.Response(
                  await v.stream.bytesToString(),
                  v.statusCode,
                  headers: v.headers,
                  isRedirect: v.isRedirect,
                  persistentConnection: v.persistentConnection,
                  reasonPhrase: v.reasonPhrase,
                  request: v.request,
                ));
// #endregion Rate Limit

/// Attempts to clear the vote from the selected post.
///
/// {@macro postVote}
Future<http.Response> clearPostVote({
  required int postId,
  BaseCredentials? credentials,
}) =>
    sendRequest(
      initVotePostRequest(postId: postId, score: 1, credentials: credentials),
    ).then((r) => r.statusCode >= 200 && r.statusCode < 300 // Is successful
        ? dc.jsonDecode(r.body)["our_score"] == 0
            ? r as FutureOr<http.Response>
            : sendRequest(initVotePostRequest(
                postId: postId,
                score: 1,
                credentials: credentials,
              ))
        : r);

/// TODO: FINISH
enum Endpoint {
  /// [OpenAPI](https://e621.wiki/#:~:text=Search%20Artists)
  artistSearch._(["artists"], _get),

  /// [OpenAPI](https://e621.wiki/#:~:text=Create%20Artist)
  artistCreate._(["artists"], _post),

  /// [OpenAPI](https://e621.wiki/#:~:text=Get%20Artist)
  artistGet._(["artists", intOrStringPathSeg], _get),

  /// [OpenAPI](https://e621.wiki/#:~:text=Edit%20Artist)
  artistEdit._(["artists", intOrStringPathSeg], _patch),

  /// [OpenAPI](https://e621.wiki/#:~:text=Delete%20Artist)
  artistDelete._(["artists", intOrStringPathSeg], _delete),

  /// [OpenAPI](https://e621.wiki/#:~:text=Revert%20Artist)
  artistRevert._(["artists", intOrStringPathSeg, "revert"], _put),

  /// [OpenAPI](https://e621.wiki/#:~:text=Search%20Posts)
  postSearch._(["posts"], _get),

  /// [OpenAPI](https://e621.wiki/#:~:text=Get%20Post)
  postGet._(["posts", intPathSeg], _get),

  /// [OpenAPI](https://e621.wiki/#:~:text=Edit%20Post)
  postEdit._(["posts", intPathSeg], _patch),

  /// [OpenAPI](https://e621.wiki/#:~:text=/posts/{id}/update_iqdb.json)
  postUpdateIqdb._(["posts", intPathSeg, "update_iqdb"], _get),

  /// [OpenAPI](https://e621.wiki/#:~:text=/posts/{id}/mark_as_translated.json)
  postEditMarkTranslated._(["posts", intPathSeg, "mark_as_translated"], _post),

  /// [OpenAPI](https://e621.wiki/#:~:text=/posts/{id}/copy_notes.json)
  postEditCopyNotesTo._(["posts", intPathSeg, "copy_notes"], _put),

  /// [OpenAPI](https://e621.wiki/#:~:text=/posts/{id}/revert.json)
  postRevert._(["posts", intPathSeg, "revert"], _post),

  /// [OpenAPI](https://e621.wiki/#:~:text=/posts/{id}/show_seq.json)
  postGetInSequence._(
    ["posts", intPathSeg, "show_seq"],
    _get,
    f: ResponseFormat(
        type: ResponseType.mapOf, map: {"post": ResponseType.post}),
  ),

  /// [OpenAPI](https://e621.wiki/#:~:text=/posts/{id}/flag.json)
  postEditUnflag._(["posts", intPathSeg, "flag"], _delete),

  /// [OpenAPI](https://e621.wiki/#:~:text=/posts/random.json)
  postGetRandom._(["posts", "random"], _get),

  /// [OpenAPI](https://e621.wiki/#:~:text=Upload%20Post)
  postCreate._(["uploads", intPathSeg], _patch),

  // TODO: Moderator post endpoints
  ;

  static const intPathSeg = r"!^[0-9]+$";
  static const anyStringPathSeg = r"!^.+?$";
  static const intOrStringPathSeg = r"!^[0-9]+$|^.+?$";
  List<Pattern> get baseUrlFormat => _baseUrlFormat
      .map((e) => e.startsWith("!") ? RegExp(e.substring(1)) : e)
      .toList(growable: false) /* ..last += ".json" */;
  final List<String> _baseUrlFormat;
  final String method;
  final ResponseFormat? responseFormat;

  const Endpoint._(this._baseUrlFormat, this.method, {ResponseFormat? f})
      : responseFormat = f;

  // #region misc
  static const _get = "GET";
  static const _patch = "PATCH";
  static const _put = "PUT";
  static const _post = "POST";
  static const _delete = "DELETE";
  // #endregion misc
}

enum ResponseType {
  artist(Artist),
  artistUrl(ArtistUrl),
  artistVersion(ArtistVersion),
  avoidPosting(/* AvoidPosting */),
  avoidPostingVersion(/* AvoidPostingVersion */),
  ban(/* Ban */),
  blip(/* Blip */),
  bulkRelatedTag(/* BulkRelatedTag */),
  bulkUpdateRequest(/* BulkUpdateRequest */),
  comment(Comment),
  currentUser(CurrentUser),
  dMail(/* DMail */),
  deferredPost(/* DeferredPost */),
  dTextResponse(DTextResponse),
  emailBlacklist(/* EmailBlacklist */),
  forumPost(/* ForumPost */),
  forumPostVote(/* ForumPostVote */),
  forumTopic(/* ForumTopic */),
  fullCurrentUser(UserLoggedInDetail),
  fullUser(UserDetailed),
  help(/* Help */),
  ipBan(/* IpBan */),
  iqdbPost(/* IqdbPost */),
  iqdbResponse(/* IqdbResponse */),
  mascot(/* Mascot */),
  modAction(/* ModAction */),
  newsUpdate(/* NewsUpdate */),
  note(Note),
  noteVersion(/* NoteVersion */),
  pool(Pool),
  poolVersion(/* PoolVersion */),
  post(Post),
  postApproval(/* PostApproval */),
  postDisapproval(/* PostDisapproval */),
  postEvent(PostEvent),
  postFlag(/* PostFlag */),
  postReplacement(/* PostReplacement */),
  postSampleAlternate(Alternate),
  postSet(PostSet),
  postVersion(/* PostVersion */),
  relatedTag(RelatedTag),
  tag(Tag),
  tagAlias(/* TagAlias */),
  tagImplication(/* TagImplication */),
  tagPreview(/* TagPreview */),
  tagTypeVersion(/* TagTypeVersion */),
  takedown(/* Takedown */),
  ticket(/* Ticket */),
  uploadWhitelist(/* UploadWhitelist */),
  upload(/* Upload */),
  user(User),
  userFeedback(/* UserFeedback */),
  userNameChangeRequest(/* UserNameChangeRequest */),
  wikiPage(WikiPage),
  wikiPageVersion(/* WikiPageVersion */),

  /// A map with keys of `String` and values of primitives, [mapOf]s, arrays, or [ResponseType]s.
  mapOf(Map<String, dynamic>),

  /// An array of primitives, [mapOf]s, arrays, or [ResponseType]s.
  arrayOf(List),
  intPrimitive(int),
  doublePrimitive(double),
  numberPrimitive(num),
  string(String),
  uri(Uri),
  dateTime(DateTime),
  ;

  final Type? correspondingType;

  const ResponseType([this.correspondingType]);
}

class ResponseFormat {
  final ResponseType type;
  bool get isMap => type == ResponseType.mapOf;
  final bool isArrayOf;
  final Map<String, ResponseType>? map;

  const ResponseFormat({
    required this.type,
    this.isArrayOf = false,
    this.map,
  });
}
