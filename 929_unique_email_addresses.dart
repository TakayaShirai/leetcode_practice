// Step 1:
// 手作業でやる場合で考える。
//
// 考慮すべき条件：
//  - '@' を基準に、local name, domain name に分けられる。
//  - local name 内の '.' は無視する。
//  - local name 内に '+' がある場合は、'+' と '+' 以降の文字は全て無視される。
//  - domain は最後は '.com' で終わっている必要がある。
//  - domain は '.com' の前に最低一文字必要である。
//
// 上記の条件を考慮した上で、複数のメールアドレスが与えられ、その中から重複のないメールアドレスの数を数え上げれば良い。
// パッと思いつくのは、
// 1. 上に書いた条件をもとに、email を変換
// 2. 「既出のメール」をまとめる表みたいなものを用意して、それを見て既出かを確かめる。
// 3. 既出ではなければ、unique email として判断。「既出のメール」をまとめる表に追加。1. に戻る。
// 4. 既出であれば、何もせず、1. に戻る。
//
// 変換の方法は、
// 1. '@' を基準として、local, domain に分ける。
// 2. local で、'+' を基準として、前半部分のみを取り出す。
// 3. local の前半部分から、'.' を消去する。
// 4. 処理を施した local + '@' + domain で最終的なメールを得る。
//
// local の変換は、for 文で一文字目から順に走査して、'.' があればスキップ、'+'があればそこで終了。という形の方が one-way で終えられて早そう。
//
// これをやれば、unique なメールの集合を取得できる。ただ今回求められているのは数字だけだから、もっと簡単にもできそうな気がしている。
//
// 手作業から思いついたわけではないが、全てのメールアドレスを用いて Trie を作って、葉ノードの数を調べるのもありか。
// メリットとしては、空間計算量があまり必要としないがありそうだが、通常 DB でメールアドレスを保存するのに Trie は向かなそうだからメリットにならなそう。
// とりあえず、先ほどの手法を実装する。

class Solution {
  int numUniqueEmails(List<String> emails) {
    var uniqueEmails = <String>{};

    for (var email in emails) {
      if (!isValidEmail(email)) {
        continue;
      }

      var convertedEmail = convertEmail(email);
      uniqueEmails.add(convertedEmail);
    }

    return uniqueEmails.length;
  }

  bool isValidEmail(String email) {
    final parts = email.split('@');

    int atCount = parts.length - 1;
    int maxAtCount = 1;
    int minAtCount = 1;

    if (!(minAtCount <= atCount && atCount <= maxAtCount)) {
      return false;
    }

    String domain = parts.last;
    String domainTail = '.com';

    if (!domain.endsWith(domainTail)) {
      return false;
    }

    return domain != domainTail;
  }

  String convertEmail(String email) {
    final parts = email.split('@');

    String originalLocal = parts.first;
    String domain = parts.last;

    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < originalLocal.length; i++) {
      String char = originalLocal[i];

      if (char == '+') {
        break;
      }

      if (char == '.') {
        continue;
      }

      buffer.write(char);
    }

    return buffer.toString() + '@' + domain;
  }
}

// Step 2:
// 他の人のコードを読む
//
// https://github.com/naoto-iwase/leetcode/pull/14/changes#diff-3282ee8d1849a45b92b2a4a6e00440ecc86e0ae920337bcef2ea279c2d29b848R74
// split を一切使わないで、複数のフラグを立てて条件分岐することで email を変換する方法。書き方いろいろあるな。
//
// https://github.com/Yuto729/LeetCode_arai60/pull/19/changes#r2609508628
// parse_local_name という関数名に対して、
// > 関数名から、どのような値が返ってくるのかが分かりにくく感じました。比較のために正規化する意味合いを込めて、 canonicalize() はいかがでしょうか？
// これは、自分の convertEmail にも当てはまる。命名をもう少しわかりやすくしていきたい。
//
// https://github.com/plushn/SWE-Arai60/pull/14#discussion_r2051710985
// ここの議論は面白いなーと思いました。string 周りの話はいつも面倒になって中途半端な理解で終わってしまうから、どこかで一気にやりたい。
//
// https://github.com/hayashi-ay/leetcode/pull/25/changes#diff-d65d43698547a0f3cfcdb7f005de30ed4cd0c45ae015fd01094d6647cfa0a84aR202
// 正規表現の手法。
// 正規表現も書きたかったが、時間がないため一旦断念。

class Solution {
  int numUniqueEmails(List<String> emails) {
    var uniqueEmails = <String>{};

    for (var email in emails) {
      if (!isValidEmail(email)) {
        continue;
      }

      var canonicalizedEmail = canonicalizeEmail(email);
      uniqueEmails.add(canonicalizedEmail);
    }

    return uniqueEmails.length;
  }

  bool isValidEmail(String email) {
    final parts = email.split('@');

    int atCount = parts.length - 1;
    int maxAtCount = 1;
    int minAtCount = 1;

    if (!(minAtCount <= atCount && atCount <= maxAtCount)) {
      return false;
    }

    String domain = parts.last;
    String domainTail = '.com';

    if (!domain.endsWith(domainTail)) {
      return false;
    }

    return domain != domainTail;
  }

  String canonicalizeEmail(String email) {
    final parts = email.split('@');

    String originalLocal = parts.first;
    String domain = parts.last;

    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < originalLocal.length; i++) {
      String char = originalLocal[i];

      if (char == '+') {
        break;
      }

      if (char == '.') {
        continue;
      }

      buffer.write(char);
    }

    return buffer.toString() + '@' + domain;
  }
}

// Step 3:
class Solution {
  int numUniqueEmails(List<String> emails) {
    var uniqueEmails = <String>{};

    for (var email in emails) {
      if (!isValidEmail(email)) {
        continue;
      }

      final canonicalizedEmail = canonicalizeEmail(email);
      uniqueEmails.add(canonicalizedEmail);
    }

    return uniqueEmails.length;
  }

  bool isValidEmail(String email) {
    final parts = email.split('@');

    int atCount = parts.length - 1;
    int maxAtCount = 1;
    int minAtCount = 1;

    if (!(minAtCount <= atCount && atCount <= maxAtCount)) {
      return false;
    }

    String domain = parts.last;
    String domainTail = '.com';

    if (!domain.endsWith(domainTail)) {
      return false;
    }

    return domain != domainTail;
  }

  String canonicalizeEmail(String email) {
    final parts = email.split('@');

    String originalLocal = parts.first;
    String domain = parts.last;

    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < originalLocal.length; i++) {
      String char = originalLocal[i];

      if (char == '+') {
        break;
      }

      if (char == '.') {
        continue;
      }

      buffer.write(char);
    }

    return buffer.toString() + '@' + domain;
  }
}
