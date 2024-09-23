/// Matches characters not allowed in new tags (some old, unused tags violate this).
///
/// https://e621.net/help/tags#guidelines
///
/// * 1 tag and 0 posts w/ `%` (`%82%b5%82%cc%82%e8%82%a8%82%f1_short_hair`)
/// * 0 tags w/ `#`
/// * 8 tags & 0 posts w/ (`,`)[https://e621.net/tags?search%5Bhide_empty%5D=0&search%5Bname_matches%5D=%2A%2C%2A]
/// * 34 tags & 0 posts w/ (`*`)[https://e621.net/tags?search%5Bhide_empty%5D=0&search%5Bname_matches%5D=%2A%5C%2A%2A]
/// * 175 tags & 0 posts w/ (`\`)[https://e621.net/tags?search%5Bhide_empty%5D=0&search%5Bname_matches%5D=%2A%5C%2A%2A]
const disallowedInTagName = r'%,#\\\*';
const disallowedInTagSearch = r'%,#';

/// The `\` is to escape the `-`
const disallowedAsFirstCharacterInTagName = r'\-~';

const allowedInTagName =
    "$allowedAnywhereInTagName|[$disallowedAsFirstCharacterInTagName]";
// const allowedAnywhereInTagName = "[a-zA-Z0-9.()'\"/]";
const allowedAnywhereInTagName = "[^$disallowedInTagName]";

/// A RegExp pattern that matches special characters used in meta-tags
/// * `:`: used for 2 term tags (e.g. `type:gif`)
/// * `!`: (used by the `user` tag to search with the user's id and not their name)[https://e621.net/help/cheatsheet#usermetatags]
/// * `.`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
/// * `/`: used in dates
/// * `*`: wildcard
/// * `"`: used for text searches with spaces
/// * ` `: used for text searches (when inside quotes)
/// * `<`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
/// * `>`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
/// * `=`: (range syntax)[https://e621.net/help/cheatsheet#rangesyntax]
const e6ValidMetaTagCharacters = ':!.-/*" <>=';
const validTag =
    '(?:[^$disallowedAsFirstCharacterInTagName])$allowedAnywhereInTagName*';

/// Successful matches are not necessarily valid, but they are parsed as separate tags.
///
/// Tokens are separated by whitespace. If there is a `"` preceded by a properly
/// formatted metatag supporting text searching (e.g. description, note, source,
/// delreason), either the next `"` or, if there is no next `"`, the next 
/// whitespace character is the end of that token.
const tagTokenizer = r'(?<=\s|^|(?:description|note|source|delreason):"[^"]*")'
    r'([^\s]+'
    r'(?:'
    r'(?:'
    r'(?<=(?:description|note|source|delreason):"[^\s]*?)'
    r'[^"]*?(?:"|(?:(?=[^"]*$)\S*))'
    r')|(?=\s|$)'
    r')'
    r')';

/// Successful matches are not necessarily valid, but they are parsed as separate tags.
///
/// Tokens are separated by whitespace. If there is at least 1 pair of quotes, the second quote is the end of that token.
const tagAgnosticTokenizer =
    r'(?<=\s|^|")((?:[^\s"]+|(?="))(?:(?:"[^"]*?(?:"|(?:(?=$|[^"]+$)\S*)))|(?=\s|$)))';
