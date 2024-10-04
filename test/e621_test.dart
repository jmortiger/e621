import 'package:http/http.dart';
import 'package:j_util/web_full.dart';
import 'package:e621/e621.dart';
import 'package:e621/e621_api.dart' as api;

import 'dev_data.dart';
import 'package:test/test.dart';
import 'package:test/test.dart' as lib;

void main() {
  logRequestData(Request req) {
    print(req);
    print(req.method);
    print(req.body);
    print(req.url);
    print(req.headers);
  }

  logResponseData(Response res) {
    print(res);
    print(res.body);
    print(res.statusCode);
    print(res.reasonPhrase);
    print(res.statusCodeInfo);
    if (res.statusCodeInfo.isRedirect) {
      print(
          "Location header: ${res.headers["location"] ?? res.headers["Location"]}");
    }
  }

  makeSummarizedString<T>(T inst, List members) =>
      "$inst {${members.length < 3 ? " " : "\n\t"}${members.join(",${members.length < 3 ? " " : "\n\t"}")}${members.length < 3 ? " " : "\n"}}";

  searchPostId(int postId, BaseCredentials? c) async => (await api
      .initPostGet(
        postId,
        credentials: c,
      )
      .send()
      .toResponse());

  searchSetId(int setId, BaseCredentials? c) async => (await api
      .initGetSetRequest(
        setId,
        credentials: c,
      )
      .send()
      .toResponse());

  group("Set", () {
    late E6Credentials c;
    late int postId, postId2, setId;
    setUp(() {
      api.addUserAgent = !Platform.isWeb;
      c = E6Credentials.fromJson(devData["e621"]);
      postId = devData["e621"]["posts"][0]["id"];
      postId2 = devData["e621"]["posts"][1]["id"];
      setId = devData["e621"]["sets"][0]["id"];
    });
    removeSetPostSlim([Response? priorStartState]) async {
      var req = api.initRemoveFromSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
    }

    addSetPostSlim([Response? priorStartState]) async {
      var req = api.initAddToSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
    }

    test("AddSetPost", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (initialIds.contains(postId)) {
        await removeSetPostSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      var req = api.initAddToSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
    });
    test("RemoveSetPost", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (!initialIds.contains(postId)) {
        await addSetPostSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      var req = api.initRemoveFromSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
    });
    addSetPostsSlim([Response? priorStartState]) async {
      var req = api.initAddToSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isIn(t.postIds));
    }

    removeSetPostsSlim([Response? priorStartState]) async {
      var req = api.initRemoveFromSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isNot(isIn(t.postIds)));
    }

    test("AddSetPosts", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (initialIds.contains(postId) || initialIds.contains(postId2)) {
        await removeSetPostsSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      // addSetPostsSlim(priorStartState);
      var req = api.initAddToSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isIn(t.postIds));
    });
    test("RemoveSetPosts", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (!initialIds.contains(postId) || !initialIds.contains(postId2)) {
        await addSetPostsSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      // removeSetPostsSlim(priorStartState);
      var req = api.initRemoveFromSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isNot(isIn(t.postIds)));
    });
    test("UpdateSetPosts", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (!initialIds.contains(postId) || !initialIds.contains(postId2)) {
        await addSetPostsSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      print("Testing removing 1 keeping 1");
      var req = api.initUpdateSetPostsRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await api.sendRequest(req);
        logResponseData(res);
      }
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isNot(isIn(t.postIds)));
      print("Testing switching kept post");
      req = api.initUpdateSetPostsRequest(
        setId,
        [postId2],
        credentials: c,
      );
      logRequestData(req);
      res = await api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await api.sendRequest(req);
        logResponseData(res);
      }
      t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isIn(t.postIds));
      print("Testing adding both");
      req = api.initUpdateSetPostsRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      res = await api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await api.sendRequest(req);
        logResponseData(res);
      }
      t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isIn(t.postIds));
      print("Testing Removing both");
      req = api.initUpdateSetPostsRequest(
        setId,
        [],
        credentials: c,
      );
      logRequestData(req);
      res = await api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await api.sendRequest(req);
        logResponseData(res);
      }
      t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isNot(isIn(t.postIds)));
    });
    tearDown(() {
      api
          .initRemoveFromSetRequest(
            setId,
            [postId, postId2],
            credentials: c,
          )
          .send();
    });
  });
  group("Favorite", () {
    late E6Credentials c;
    late int postId;
    setUp(() {
      api.addUserAgent = !Platform.isWeb;
      c = E6Credentials.fromJson(devData["e621"]);
      postId = devData["e621"]["posts"][2]["id"];
    });
    late final Future<void> Function([Response? priorStartState]) removeFav;
    addFav([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchPostId(postId, c));
      print(startState.body);
      await Future.delayed(api.softRateLimit);
      if (Post.fromRawJson(startState.body).isFavorited) {
        await removeFav();
      }
      var req = api.initFavoriteCreate(
        postId: postId,
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      Post t = Post.fromRawJson(res.body);
      expect(postId, t.id);
      expect(t.isFavorited, true);
    }

    removeFav = ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchPostId(postId, c));
      print(startState.body);
      await Future.delayed(api.softRateLimit);
      if (!Post.fromRawJson(startState.body).isFavorited) {
        await addFav(startState);
      }
      var req = api.initFavoriteDelete(
        postId: postId,
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 204);
      expect(res.body, "");
      await Future.delayed(api.softRateLimit);
      var p = await api
          .initPostGet(postId, credentials: c)
          .send()
          .toResponse();
      Post t = Post.fromRawJson(p.body);
      expect(postId, t.id);
      expect(t.isFavorited, false);
    };

    test("AddFav", addFav);
    test("RemoveFav", removeFav);
  });
  group("Comments", () {
    late E6Credentials c;
    late List<int> postIds;
    late List<int> commentIds;
    setUp(() {
      api.addUserAgent = !Platform.isWeb;
      c = AccessData.fromJson(devData["e621"]);
      postIds = [
        devData["e621"]["posts"][3]["id"],
        devData["e621"]["posts"][4]["id"]
      ];
      commentIds = [
        devData["e621"]["comments"][0]["id"],
        // devData["e621"]["comments"][1]["id"]
      ];
    });
    group("Search Comments Parameters", () {
      test("post_id & group_by", () async {
        print("Testing by post id");
        print("Testing `group_by: comment`");
        var req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.comment,
          searchPostIds: postIds,
          credentials: c,
        );
        logRequestData(req);
        var res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        var comments = Comment.fromRawJsonResults(res.body);
        expect(comments.length, isNot(0));
        print("Testing `group_by: post`");
        req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.post,
          searchPostIds: postIds,
          credentials: c,
        );
        logRequestData(req);
        res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        expect(() => comments = Comment.fromRawJsonResults(res.body),
            lib.throwsA(isA<Error>()));
        expect(() => Post.fromRawJsonResults(res.body).toList(),
            lib.returnsNormally);
        // expect(Post.fromRawJsonResults(res.body).toList(), lib.isA<List<Post>>());
        print("Testing `group_by: null`");
        req = api.initSearchCommentsRequest(
          groupBy: null,
          searchPostIds: postIds,
          credentials: c,
        );
        logRequestData(req);
        res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        expect(() => comments = Comment.fromRawJsonResults(res.body),
            lib.throwsA(isA<Error>()));
        expect(() => Post.fromRawJsonResults(res.body).toList(),
            lib.returnsNormally);
        // expect(Post.fromRawJsonResults(res.body).toList(), lib.isA<List<Post>>());
      });
      test("id & group_by", () async {
        print("Again by comment id and not post id");
        print("Testing `group_by: comment`");
        var req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.comment,
          searchIds: commentIds,
          credentials: c,
        );
        logRequestData(req);
        var res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        var comments = Comment.fromRawJsonResults(res.body);
        expect(comments.length, isNot(0));
        print("Testing `group_by: post`");
        req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.post,
          searchIds: commentIds,
          credentials: c,
        );
        logRequestData(req);
        res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        expect(() => comments = Comment.fromRawJsonResults(res.body),
            lib.throwsA(isA<Error>()));
        expect(() => Post.fromRawJsonResults(res.body).toList(),
            lib.returnsNormally);
        // expect(Post.fromRawJsonResults(res.body).toList(), lib.isA<List<Post>>());
        print("Testing `group_by: null`");
        req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.post,
          searchIds: commentIds,
          credentials: c,
        );
        logRequestData(req);
        res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        expect(() => comments = Comment.fromRawJsonResults(res.body),
            lib.throwsA(isA<Error>()));
        expect(() => Post.fromRawJsonResults(res.body).toList(),
            lib.returnsNormally);
        // expect(Post.fromRawJsonResults(res.body).toList(), lib.isA<List<Post>>());
      });
    });
    group("searchOrder", () {
      /* test("postIdAsc", () async {
        var req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.comment,
          searchPostIds: postIds,
          searchOrder: CommentOrder.postIdAsc,
          credentials: c,
        );
        logRequestData(req); 
        var res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        var comments = Comment.fromRawJsonResults(res.body).toList();
        expect(comments.length, greaterThanOrEqualTo(1));
        print("first: ${makeSummarizedString("", [
              comments.first.id,
              comments.first.postId
            ])}");
        print("last: ${makeSummarizedString("", [
              comments.last.id,
              comments.last.postId
            ])}");
        expect(comments.first.postId, lib.lessThanOrEqualTo(comments.last.postId));
      }); */
      test("postIdDesc", () async {
        var req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.comment,
          searchPostIds: postIds,
          searchOrder: CommentOrder.postIdDesc,
          credentials: c,
        );
        logRequestData(req);
        var res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        var comments = Comment.fromRawJsonResults(res.body).toList();
        expect(comments.length, greaterThanOrEqualTo(1));
        print("first: ${makeSummarizedString(comments.first, [
              comments.first.id,
              comments.first.postId
            ])}");
        print("last: ${makeSummarizedString(comments.last, [
              comments.last.id,
              comments.last.postId
            ])}");
        expect(comments.first.postId, lib.greaterThan(comments.last.postId));
      });
      test("idAsc", () async {
        var req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.comment,
          searchPostIds: postIds,
          searchOrder: CommentOrder.idAsc,
          credentials: c,
        );
        logRequestData(req);
        var res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        var comments = Comment.fromRawJsonResults(res.body).toList();
        expect(comments.length, greaterThanOrEqualTo(1));
        print("first: ${makeSummarizedString(comments.first, [
              comments.first.id,
              comments.first.body
            ])}");
        print("last: ${makeSummarizedString(comments.last, [
              comments.last.id,
              comments.last.body
            ])}");
        expect(comments.first.id, lib.lessThan(comments.last.id));
      });
      test("idDesc", () async {
        var req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.comment,
          searchPostIds: postIds,
          searchOrder: CommentOrder.idDesc,
          credentials: c,
        );
        logRequestData(req);
        var res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        var comments = Comment.fromRawJsonResults(res.body).toList();
        expect(comments.length, greaterThanOrEqualTo(1));
        print("first: ${makeSummarizedString(comments.first, [
              comments.first.id,
              comments.first.body
            ])}");
        print("last: ${makeSummarizedString(comments.last, [
              comments.last.id,
              comments.last.body
            ])}");
        expect(comments.first.id, lib.greaterThan(comments.last.id));
      });
      test("scoreDesc", () async {
        var req = api.initSearchCommentsRequest(
          groupBy: CommentGrouping.comment,
          searchPostIds: postIds,
          searchOrder: CommentOrder.scoreDesc,
          credentials: c,
        );
        logRequestData(req);
        var res = await req.send().toResponse();
        logResponseData(res);
        expect(res.statusCode, inInclusiveRange(200, 299));
        var comments = Comment.fromRawJsonResults(res.body).toList();
        expect(comments.length, greaterThanOrEqualTo(1));
        print("first: ${makeSummarizedString(comments.first, [
              comments.first.id,
              comments.first.score,
            ])}");
        print("last: ${makeSummarizedString(comments.last, [
              comments.last.id,
              comments.last.score,
            ])}");
        expect(comments.first.score, lib.greaterThan(comments.last.score));
      });
      // test("updated_at_desc", () async {
      //   print("Testing `group_by: comment`");
      //   var req = api.initSearchCommentsRequest(
      //     groupBy: CommentGrouping.comment,
      //     searchPostIds: postIds,
      //     searchOrder: CommentOrder.updatedAtDesc,
      //     credentials: c,
      //   );
      //   logRequestData(req);
      //   var res = await req.send().toResponse();
      //   logResponseData(res);
      //   expect(res.statusCode, inInclusiveRange(200, 299));
      //   var comments = Comment.fromRawJsonResults(res.body).toList();
      //   print("first: ${makeSummarizedString(comments.first, [
      //         comments.first.id,
      //         comments.first.updatedAt
      //       ])}");
      //   print("last: ${makeSummarizedString(comments.last, [
      //         comments.last.id,
      //         comments.last.updatedAt
      //       ])}");
      //   expect(comments.length, greaterThanOrEqualTo(1));
      //   expect(
      //       comments.first.updatedAt.isAfter(comments.last.updatedAt), isTrue);
      // });
    });
  });
}
