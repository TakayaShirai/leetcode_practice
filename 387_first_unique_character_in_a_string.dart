import 'dart:collection';
// Step 1:
//
// 最初にパッと思いつく解答は、２回走査をする方法。
// 一回目の走査で、重複していない文字を特定して、２回目の走査で、重複していない文字の中で一番最初に出会った文字が得たい文字。
//
// 一回の走査でできないかを考えてみる。
// 毎回のループで「現状最初の重複がない文字と添字」、「次の重複がない候補」、「重複を調べるための表」があれば良い。
// 流れとしては以下？
// 1. 重複がない文字と添字を一つ保持する。
// 2. 重複がないかを一文字ずつの走査で検証していく。
// 3. 出てきた文字は、全てその出現回数を記録しておく。
// 4. もし、比較したもう一方の文字の出現回数が0な場合は、それを候補のキューに入れておく。
// 5. もし、比較したもう一方の文字が出現回数が0より大きい場合はキューには入れない。
// 6. もし、今保持している文字で重複が発生した場合は、キューから一つ候補を取り出す。キューに候補がない場合は、走査において次の文字を一旦保持する。
// 7. 取り出した候補が重複していないかを、出現回数から調べる。
// 8. もし、重複済みな場合は、次の候補を取り出し、これを繰り返す。
// 9. もし、重複がない場合は、そのまま走査を進める。
// 10. もう確かめる文字列がなくなった場合は、その時に保持していた添字が答え。
// 11. 候補が全てなくなった場合は、-1 を返す。
// 結構処理が複雑になるから、最初の手法が良さそう。

class Solution {
  int firstUniqChar(String s) {
    var uniqueChars = findUniqueChars(s);

    for (var i = 0; i < s.length; i++) {
      if (uniqueChars.contains(s[i])) {
        return i;
      }
    }

    return -1;
  }

  Set<String> findUniqueChars(String s) {
    var uniqueChars = <String>{};
    var duplicatedChars = <String>{};

    for (var i = 0; i < s.length; i++) {
      if (duplicatedChars.contains(s[i])) {
        continue;
      }

      if (uniqueChars.contains(s[i])) {
        duplicatedChars.add(s[i]);
        uniqueChars.remove(s[i]);
        continue;
      }

      uniqueChars.add(s[i]);
    }

    return uniqueChars;
  }
}

// Step 2:
// 他の人のコードを見る前に、もう一方の手法でも書いてみる。

class Solution {
  int firstUniqChar(String s) {
    if (s.isEmpty) {
      return -1;
    }

    if (s.length == 1) {
      return 0;
    }

    var curCandidate = (0, s[0]);
    var candidateQueue = Queue<(int, String)>();
    var charCounter = <String, int>{s[0]: 1};

    for (var i = 1; i < s.length; i++) {
      charCounter[s[i]] = (charCounter[s[i]] ?? 0) + 1;

      if (charCounter[s[i]] == 1) {
        candidateQueue.add((i, s[i]));
      }

      if (charCounter[curCandidate.$2]! > 1) {
        while (candidateQueue.isNotEmpty) {
          var candidate = candidateQueue.removeFirst();

          if (charCounter[candidate.$2] == 1) {
            curCandidate = candidate;
            break;
          }
        }

        if (charCounter[curCandidate.$2]! > 1) {
          if (charCounter[s[i]] == 1) {
            curCandidate = (i, s[i]);
          }
        }
      }
    }

    if (charCounter[curCandidate.$2] == 1) {
      return curCandidate.$1;
    }

    return -1;
  }
}

// なんか長いなーと思って LLM に相談したら、queue の最初の要素を常に最新の候補にしておけば、わざわざ候補を別の変数で保持しなくて良いと言われた。
// 確かにそう。要するにそれぞれのループで不変条件として、以下を設定すればもっと簡単にかける。
// - queue の先頭は、常に重複がない最初の文字と添字。
// - counter には、今までの文字の出現回数が含まれている。
// この二つの要素があれば、重複の判定と、現状の最初の重複がないやつは常にループで簡単に追える。
class Solution {
  int firstUniqChar(String s) {
    var charCounter = <String, int>{};
    var candidates = Queue<(int, String)>();

    for (var i = 0; i < s.length; i++) {
      var char = s[i];

      charCounter[char] = (charCounter[char] ?? 0) + 1;

      if (charCounter[char] == 1) {
        candidates.add((i, char));
      }

      while (candidates.isNotEmpty && charCounter[candidates.first.$2]! > 1) {
        candidates.removeFirst();
      }
    }

    return candidates.isEmpty ? -1 : candidates.first.$1;
  }
}

// 他の人のコードを見る
// https://github.com/nanae772/leetcode-arai60/pull/16/changes#diff-e308788644c01fa89479cb10fb1675ed0a1d04fd0acdf5153ea12f658889942cR12
// > sの文字を左から見ていってs[i]を見たときにs[i+1:]に同じ文字があるかループを回してチェックする方法(O(N^2))
// Brute Force のやり方を思いついていなかった。確かにこれでもいける。
//
// https://github.com/nanae772/leetcode-arai60/pull/16/changes#diff-e308788644c01fa89479cb10fb1675ed0a1d04fd0acdf5153ea12f658889942cR31
// > 最初にsをCounterにぶち込んでからもう一度sを前から見てcount=1のものがあったらそれを返す、という方法があった。
// > そのほうがシンプルで分かりやすいかも。
// 自分は Set を用いて重複を判定していたが、counter での重複の方がコードが簡潔に済んで良い。
//
// https://github.com/t0hsumi/leetcode/pull/15#discussion_r1930362913
// 重複がないことの証明として、「左から読んだときと右から読んだときで、添字が変わらない」ことを使っていた。
// 思いつかなかった。
//
// https://discord.com/channels/1084280443945353267/1233603535862628432/1238208008182562927
// 不変条件を意識するのは大事。LinkedHashMap があれば、一つ気にしなければいけない要素を減らせる。
// Dart の Map はデフォルトで LinkedHashMap になっているらしい。
//
// Linked Hash Map
class Solution {
  int firstUniqChar(String s) {
    var charToIndex = <String, int>{};

    for (var i = 0; i < s.length; i++) {
      if (charToIndex.containsKey(s[i])) {
        charToIndex[s[i]] = -1;
        continue;
      }
      charToIndex[s[i]] = i;
    }

    for (var index in charToIndex.values) {
      if (index != -1) {
        return index;
      }
    }

    return -1;
  }
}

// 左から読んだ時と、右から読んで添字が変わらない
class Solution {
  int firstUniqChar(String s) {
    for (int i = 0; i < s.length; i++) {
      if (s.indexOf(s[i]) == s.lastIndexOf(s[i])) {
        return i;
      }
    }

    return -1;
  }
}

// Counter のみ
class Solution {
  int firstUniqChar(String s) {
    var charCounter = createCounter(s);

    for (var i = 0; i < s.length; i++) {
      if (charCounter[s[i]] == 1) {
        return i;
      }
    }

    return -1;
  }

  Map<String, int> createCounter(String s) {
    var counter = <String, int>{};

    for (var i = 0; i < s.length; i++) {
      counter[s[i]] = (counter[s[i]] ?? 0) + 1;
    }

    return counter;
  }
}

// Step 3
class Solution {
  int firstUniqChar(String s) {
    var counter = createCounter(s);

    for (var i = 0; i < s.length; i++) {
      if (counter[s[i]] == 1) {
        return i;
      }
    }

    return -1;
  }

  Map<String, int> createCounter(String s) {
    var counter = <String, int>{};

    for (var i = 0; i < s.length; i++) {
      counter[s[i]] = (counter[s[i]] ?? 0) + 1;
    }

    return counter;
  }
}
