// Step 1
// 手作業でやる場合を考える
//
// 以前は Swift で書いていたが、就職した後は言語としては主に Dart を使うことになりそうなので、Dart でやることにした。
//
// 1. 文字列内の各文字とその文字の数をまとめるための表を用意
// 2. 文字列の各文字の数を数える
// 3. 各文字とその数が一致しているものがすでに表にあれば、そこの行に文字列を追加
// 4. 一致しているものがなければ、新しい行を追加
// これを繰り返せば良い。
//
// 上記のものをやろうとしたが、Swift ではできたが、Dart ではできなさそうだった。
// 理由は、Swift は連想配列を値型として扱うが、Dart は参照型として扱うから。
// Swift: https://developer.apple.com/documentation/swift/dictionary
// Dart: https://api.dart.dev/stable/2.15.1/dart-core/Map-class.html
// Dart だと、Map は Mutable なため、Map を key にした場合に急に key の値が変わる可能性がある。
// この場合、以前の key では値が取り出せなくなるため致命的。
// また、そもそも参照型であるため、値が同じ場合でもポインタは違うため、同じ key と判定できない。
// よって、文字列をソートして anagram かどうかを判定することとする。
//
// 結局のところ、手作業は以下のように一般化できるから、anagram の判定に使う要素が各文字の数からソートした値になっただけ。
// 1. anagram の判定に使える要素に変換
// 2. その要素を元に、グループ分けを行う。(グループ分けに使うのに、表が必要)

class Solution {
  List<List<String>> groupAnagrams(List<String> strs) {
    var sortedToStrings = <String, List<String>>{};

    for (var str in strs) {
      final sortedStr = sortString(str);
      (sortedToStrings[sortedStr] ??= []).add(str);
    }

    return sortedToStrings.values.toList();
  }

  String sortString(String str) {
    final charList = str.split('');
    charList.sort();
    return charList.join('');
  }
}

// Step 2
// 他の人のコードを読む
//
// https://github.com/docto-rin/leetcode/pull/12/changes#diff-fe2d4c2dc887ab0e20b792b5554f8825a47ae7cb967d7cce8e23a4ea022e660fR27
// この手法を用いれば、参照型でも sort しないで十分に anagram ごとのグループ化ができる。
// ただ、コードの複雑度は上がるように思われるため、sort の方が個人的には好み。
//
// https://github.com/Yuto729/LeetCode_arai60/pull/17/changes#diff-b46ca2e7aa3b0f8d0b763135aa8a7a77eb71b31bc42af6092009ebfd19d9c9a5R10
// key を文字列として与えるのもあり。ランレングス圧縮。
// a: 3, b: 2 -> "a3b2"
// ただ、文字列に数字が入っていた場合に意図しない動作が起きてしまう。
// https://github.com/ichika0615/arai60/pull/11#discussion_r1975712971
// エスケープシーケンスなどを用いることで、上記の問題は回避できる。
//

// 文字の数を数える方法でもやってみる。
// 無駄に複雑になっているため、これはやりたくない。
class Solution {
  List<List<String>> groupAnagrams(List<String> strs) {
    var charCounters = <Map<String, int>>[];
    var stringsGroupedByAnagram = <List<String>>[];

    for (var str in strs) {
      final counter = createCharCounter(str);
      final groupIndex = calcGroupIndex(counter, charCounters);

      if (groupIndex == null) {
        charCounters.add(counter);
        stringsGroupedByAnagram.add([str]);
        continue;
      }

      stringsGroupedByAnagram[groupIndex].add(str);
    }

    return stringsGroupedByAnagram;
  }

  int? calcGroupIndex(
    Map<String, int> counter,
    List<Map<String, int>> counters,
  ) {
    for (int i = 0; i < counters.length; i++) {
      final tmpCounter = counters[i];

      if (isSameMap(counter, tmpCounter)) {
        return i;
      }
    }

    return null;
  }

  Map<String, int> createCharCounter(String str) {
    var counter = <String, int>{};

    for (var char in str.split('')) {
      counter[char] = (counter[char] ?? 0) + 1;
    }

    return counter;
  }

  bool isSameMap(Map<String, int> map1, Map<String, int> map2) {
    if (map1.length != map2.length) {
      return false;
    }

    for (var key in map1.keys) {
      if (map1[key] != map2[key]) {
        return false;
      }
    }

    return true;
  }
}

// Step 3
// ソートをするやり方で書く
//
class Solution {
  List<List<String>> groupAnagrams(List<String> strs) {
    var sortedToStrings = <String, List<String>>{};

    for (var str in strs) {
      final sortedStr = sortString(str);
      (sortedToStrings[sortedStr] ??= []).add(str);
    }

    return sortedToStrings.values.toList();
  }

  String sortString(String str) {
    var characters = str.split('');
    characters.sort();
    return characters.join('');
  }
}
