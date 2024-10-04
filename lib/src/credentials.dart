import 'dart:convert' as dc;

/// TODO: Credential reform
/// TODO: Use user agent in api calls
final class AccessData extends E6Credentials {
  final String userAgent;
  E6Credentials get cred => this as E6Credentials;

  AccessData({
    required super.apiKey,
    required super.username,
    required this.userAgent,
  }); // : cred = E6Credentials(username: username, apiKey: apiKey);
  AccessData._directCred({
    // required this.username,
    required this.userAgent,
    required E6Credentials cred,
  }) : super._direct(username: cred.username, headerValue: cred.headerValue);
  const AccessData._directHeader({
    required super.headerValue,
    required super.username,
    required this.userAgent,
  }) : super._direct();
  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll({"userAgent": userAgent});
  AccessData.fromJson(super.json)
      : userAgent = json["userAgent"],
        super.fromJson();

  static const userAgentHeaderKey = "User-Agent";

  @override
  Map<String, dynamic> addTo(Map<String, dynamic> headers) =>
      super.addTo(headers)..addAll({userAgentHeaderKey: userAgent});
  @Deprecated("Use addTo")
  @override
  Map<String, dynamic> addToHeadersMap(Map<String, dynamic> headers) =>
      addTo(headers);
  @override
  Map<String, String> addToTyped(Map<String, String> headers) =>
      headers..addEntries(this.headers);
  List<MapEntry<String, String>> get headers =>
      [super.header, MapEntry(userAgentHeaderKey, userAgent)];
  Map<String, String> get headerMap => {
        BaseCredentials.headerKey: super.headerValue,
        userAgentHeaderKey: userAgent
      };
  List<String> get headerValues => [super.headerValue, userAgent];
}

final class AccessDataFull implements AccessData {
  final String apiKey;
  @override
  final String username;
  @override
  final String userAgent;
  @override
  E6Credentials get cred => E6Credentials(username: username, apiKey: apiKey);

  const AccessDataFull({
    required this.apiKey,
    required this.username,
    required this.userAgent,
  });
  @override
  Map<String, dynamic> toJson() => {
        "apiKey": apiKey,
        "username": username,
        "userAgent": userAgent,
      };
  factory AccessDataFull.fromJson(Map<String, dynamic> json) => AccessDataFull(
        apiKey: json["apiKey"] as String,
        username: json["username"] as String,
        userAgent: json["userAgent"] as String,
      );

  @override
  MapEntry<String, String> get header => cred.header;

  @override
  String get headerValue => cred.headerValue;

  static const userAgentHeaderKey = "User-Agent";

  @override
  Map<String, dynamic> addTo(Map<String, dynamic> headers) =>
      cred.addTo(headers)..addAll({userAgentHeaderKey: userAgent});
  @Deprecated("Use addTo")
  @override
  Map<String, dynamic> addToHeadersMap(Map<String, dynamic> headers) =>
      addTo(headers);
  @override
  Map<String, String> addToTyped(Map<String, String> headers) =>
      cred.addToTyped(headers)..addAll({userAgentHeaderKey: userAgent});
  @override
  List<MapEntry<String, String>> get headers =>
      [cred.header, MapEntry(userAgentHeaderKey, userAgent)];
  @override
  List<String> get headerValues => [cred.headerValue, userAgent];
  @override
  Map<String, String> get headerMap => {
        BaseCredentials.headerKey: cred.headerValue,
        userAgentHeaderKey: userAgent
      };
}

class BaseCredentials {
  static const headerKey = "Authorization";
  MapEntry<String, String> get header => MapEntry(headerKey, headerValue);
  Map<String, dynamic> addTo(Map<String, dynamic> headers) {
    headers[headerKey] = headerValue;
    return headers;
  }

  Map<String, String> addToTyped(Map<String, String> headers) {
    headers[headerKey] = headerValue;
    return headers;
  }

  @Deprecated("Use addTo")
  Map<String, dynamic> addToHeadersMap(Map<String, dynamic> headers) =>
      addTo(headers);

  final String headerValue;
  BaseCredentials({
    required String identifier,
    required String secret,
  }) : headerValue = 'Basic ${dc.base64Encode(dc.ascii.encode(
          '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
        ))}';

  static String getAuthHeaderValue(
    String identifier,
    String secret,
  ) =>
      'Basic ${dc.base64Encode(dc.ascii.encode(
        '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
      ))}';
  const BaseCredentials._direct(this.headerValue);
  BaseCredentials.fromJson(Map<String, dynamic> json,
      {String identifierKey = "identifier", String secretKey = "secret"})
      : headerValue = json["headerValue"] ??
            getAuthHeaderValue(json[identifierKey], json[secretKey]);
  Map<String, dynamic> toJson() => {"headerValue": headerValue};
}

class E6Credentials extends BaseCredentials {
  static E6Credentials? currentCredentials;
  final String username;
  // final String apiKey;

  E6Credentials({
    required this.username,
    // required this.apiKey,
    required String apiKey,
  }) : super(identifier: username, secret: apiKey);
  const E6Credentials._direct({
    required this.username,
    // required this.apiKey,
    required String headerValue,
  }) : super._direct(headerValue);
  E6Credentials.fromJson(super.json)
      : username = json["username"],
        super.fromJson(identifierKey: "username", secretKey: "apiKey");
  @override
  Map<String, dynamic> toJson() => {
        "username": username,
        // "apiKey": apiKey,
        "headerValue": headerValue,
      };
}
