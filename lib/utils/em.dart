class Em {
  static regCate(String origin) {
    String str = origin;
    RegExp exp = RegExp('<[^>]*>([^<]*)</[^>]*>');
    Iterable<Match> matches = exp.allMatches(origin);
    for (Match match in matches) {
      str = match.group(1)!;
    }
    return str;
  }

  static regTitle(String origin) {
    RegExp exp = RegExp('<[^>]*>([^<]*)</[^>]*>');
    List res = [];

    origin.splitMapJoin(exp, onMatch: (Match match) {
      String matchStr = match[0]!;
      Map map = {'type': 'em', 'text': regCate(matchStr)};
      res.add(map);
      return regCate(matchStr);
    }, onNonMatch: (String str) {
      if (str != '') {
        str = str
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&apos;', "'")
            .replaceAll('&nbsp;', " ")
            .replaceAll('&amp;', "&");

        // 处理类似 &#x27; &#34; 这类的 HTML 实体字符
        final entityRegex = RegExp(r'&#x([0-9A-Fa-f]+);|&#(\d+);');
        str = str.replaceAllMapped(entityRegex, (match) {
          if (match[1] != null) {
            final hexValue = int.tryParse(match[1]!, radix: 16);
            if (hexValue != null) {
              return String.fromCharCode(hexValue);
            }
          } else if (match[2] != null) {
            final decimalValue = int.tryParse(match[2]!, radix: 10);
            if (decimalValue != null) {
              return String.fromCharCode(decimalValue);
            }
          }
          return match.group(0)!;
        });

        Map map = {'type': 'text', 'text': str};
        res.add(map);
      }
      return str;
    });

    return res;
  }
}
