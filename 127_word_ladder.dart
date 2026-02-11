// Step 1
// 手作業でやる場合を考える
//
// 文字を一文字ずつ変えていって、beginWord から endWord に変えていく。
// この時に、beginWord から endWord に変換できる最小の処理の回数を返せ。変換できないなら、0 を返せ。
// という問題。
//
// うーん、手作業でやるとしても結構面倒。
// まず、beginWord と endWord が一致してたら、終わり。
// 一致していなければ、wordList 内の全ての文字で、「endWordと何文字違うか」、「どこの文字が違うか」を確認して、以下のような表を作る。
// | word | 何文字違うか | どこの文字が違うか（添字）|
// ---------------------------------------------
// | hit  |     3      |         (0, 1, 2)    |
// | hot  |     2      |         (0, 2)       |
// | dot  |     2      |         (0, 2)       |
// | dog  |     1      |         (0)          |
// | lot  |     2      |         (0, 2)       |
// | log  |     1      |         (0)          |
// | cog  |     0      |         ()           |
//
// 手元にある beginWord は、hit で 3文字違って、(0, 1, 2) が違うから、この表の中から、まず2文字違うやつを探す。
// 手元の文字を2文字違う文字に変える。
// そこから、また、「一文字違う」かつ「文字が違う場所が一致している」ものを探す。
// 手元の文字を1文字違う文字に変える。
// ここまできたら、最後の文字にはあと一回の処理で変えることができる。
// これを全ての通りでやっていけばいい。
// どれぐらい時間がかかるかを考える。
//
// Dart は 10^4 steps/ms を仮定する。
// 表を作る操作は、beginWord の長さを M、文字数を N とすると O (N*M)。
// いま、beginWord の最大の長さは 10, 文字数は 5000 なので、最大 50000 / 10^4 = 5ms。
// 全通りでやるとして、こっからの計算時間の見積もりが難しい。
// 以下の質問を LLM にした。
// 「N という数字が与えられたときに、和が N になるような数字の組み合わせで最大の積を持つ組み合わせはどんな組み合わせか」
// 「できるだけ 3 を多く使い、残りを 2 で調整する組み合わせ」らしい。
// 3^a * 2^b (3a + 2b = N) かつ b は {0, 1, 2} のうち、どれか。
// 要するに、ほとんど、3^(N/3)ということ。
// 3^1000 / 10 ^ 4 は log10(3) が 0.47 なので、log10(3^1000) = 470。よって、10^466 ms = 10^463s かかる。圧倒的 TLE。
//
// 全通りはダメっぽい。幅優先探索で、最短が見つかったら途中で打ち切る。これで多少おさえられる？
// あとは同じ文字にたどり着いたものが先にいたら、そっちは打ち切るとか。計算量の見積もりが難しかったので、とりあえず書いてみる。

// 以下、Wrong Answer の解答になります。
// 想定通りに動きません。
import 'dart:collection';
import 'dart:math';

class WordDifference {
  int diffCount;
  Map<int, int> diffIndexes;

  WordDifference(this.diffCount, this.diffIndexes);
}

class Solution {
  int ladderLength(String beginWord, String endWord, List<String> wordList) {
    Map<String, WordDifference> createWordToWordDifferences() {
      var wordToWordDifferences = <String, WordDifference>{};

      var wordDifference = WordDifference(0, {});

      for (var i = 0; i < beginWord.length; i++) {
        if (beginWord[i] != endWord[i]) {
          wordDifference.diffCount += 1;
          wordDifference.diffIndexes[i] = 1;
        }
      }

      wordToWordDifferences[beginWord] = wordDifference;

      for (var word in wordList) {
        if (word.length != endWord.length) {
          continue;
        }

        wordDifference = WordDifference(0, {});

        for (var i = 0; i < word.length; i++) {
          if (word[i] != endWord[i]) {
            wordDifference.diffCount += 1;
            wordDifference.diffIndexes[i] = 1;
          }
        }

        wordToWordDifferences[word] = wordDifference;
      }

      return wordToWordDifferences;
    }

    if (beginWord.length != endWord.length) {
      return 0;
    }

    if (beginWord == endWord) {
      return 0;
    }

    var wordToWordDifferences = createWordToWordDifferences();

    var wordToChange = Queue<String>.from([beginWord]);
    var seenWords = <String>{beginWord};
    var changeCount = 0;

    while (!wordToChange.isEmpty) {
      var levelSize = wordToChange.length;
      for (var i = 0; i < levelSize; i++) {
        var word = wordToChange.removeFirst();

        var wordDifference = wordToWordDifferences[word];

        if (wordDifference == null) {
          continue;
        }

        for (var MapEntry(key: nextWord, value: nextWordDifference)
            in wordToWordDifferences.entries) {
          if (seenWords.contains(nextWord) ||
              (nextWordDifference.diffCount - wordDifference.diffCount).abs() !=
                  1) {
            continue;
          }

          if (nextWord == endWord) {
            return changeCount + 1;
          }

          var lastIndex = nextWordDifference.diffIndexes.keys.last;

          for (var index in nextWordDifference.diffIndexes.keys) {
            if (wordDifference.diffIndexes[index] == null) {
              break;
            }

            if (index == lastIndex) {
              wordToChange.add(nextWord);
              seenWords.add(nextWord);
            }
          }
        }
      }

      changeCount++;
    }

    return 0;
  }
}

// Step 2:
// 手作業を考える作業は、「アルゴリズムを考える作業」。
// コードを書く作業は、「アルゴリズムを機械語に翻訳する作業」。
// 翻訳をスラスラできるようになるのも、このコーディング練習会の目的かなと思った。
// 今回は、どっちも難しく、そもそも手作業を間違えていた。コードに翻訳するのも手こずった。

// 他の人のコードをよむ。コメント集を読む。
// https://github.com/nanae772/leetcode-arai60/pull/20/changes#diff-68b637fa33b24b8f88d422b875693d432b6e22729cb91d14d39eee6c7bc63ee5R3-R6
// > beginWordから1文字ずつ変形させてwordListにある単語を経由してendWordに行けるかという問題。
// > これはwordを頂点とするグラフの最短経路問題と見ることができる。
// > 一文字違いのwordを辺でつないでグラフを作りbeginWordから幅優先探索してendWordを目指す。
// > 単語の長さをk, 単語数をnとすると最初にグラフを構築するのにO(kn^2)かかり、
// > BFSするのにO(n^2)かかるので時間計算量としてはO(kn^2)かかる。
// > 最大ケースがk = 10, n^2 = 2.5*10^7なのでkn^2 = 2.5 * 10^8 ほどで結構厳しいかもしれない。
// > PythonだとTLEするかもしれない…
// グラフの最短経路問題と見立てれば、確かに結構シンプルな問題に見える。ここら辺の感覚を養いたい。
// 計算時間に関しても、Dart だと, 2.5 * 10^8 / 10^4 = 2.5 * 10^4 ms = 25s。
//
// グラフを作成する方法がいくつかある。
// https://github.com/akmhmgc/arai60/pull/16/changes
// word の一文字を a-z に変えてみて、それを wordList から作成した Set の中に判別して、隣接を探す、グラフを作る方法。
//
// https://github.com/hayashi-ay/leetcode/pull/42/changes
// h*t など、ワイルドカードを用いて、隣接を探す、グラフを作成する手法。

// https://discord.com/channels/1084280443945353267/1200089668901937312/1201781408788389888
// > 要するに、関数にする意味というのは、「ここの範囲は、これをしていると名前をつける」「使う変数の範囲を明示し、テンポラリーな変数をはっきりさせる」の二つがあります。
// > たとえば、rotten_next_oranges は、dirs の変数を使って名前空間を汚したわけですが、関数を抜けるとそれが消えるわけです。
// ここら辺も感覚を養う。
//
// 実際に書いてみる。
// 隣接を探す手法は、関数に切り出して、複数手法で切り替えられるようにしておく。
//
// グラフの問題ということが意識できたら、スムーズに書けた。
// 計測時間としては、率直な方法が最速で、アルファベットが最遅だった。文字列の生成がボトルネックになっていると思う。
//
// 各サイズ 10000 回ループして平均を算出
// | Word Count | naive (ms)    | alphabet (ms) | wildcard (ms) |
// |------------|---------------|---------------|---------------|
// |         50 |       0.00841 |       1.87538 |       0.19723 |
// |        200 |       0.14213 |       7.52508 |       0.81961 |
// |        500 |       0.96173 |      19.75734 |       2.00651 |
//
// 計測をしやすくするために leetcode の関数形から少し変えています。
enum AdjacencyStrategy { naive, alphabet, wildcard }

class Solution {
  // 率直な方法
  Map<String, List<String>> createAdjacentWordsMap(List<String> wordList) {
    bool isAdjacentWord(String word1, String word2) {
      if (word1.length != word2.length) {
        return false;
      }

      var differenceCount = 0;

      for (var i = 0; i < word1.length; i++) {
        if (word1[i] != word2[i]) {
          differenceCount += 1;
        }

        if (differenceCount >= 2) {
          return false;
        }
      }

      return differenceCount == 1;
    }

    var adjacentWordsMap = <String, List<String>>{};

    for (var i = 0; i < wordList.length; i++) {
      var word = wordList[i];

      for (var j = 0; j < wordList.length; j++) {
        if (i == j) {
          continue;
        }

        var adjacentCandidate = wordList[j];

        if (isAdjacentWord(word, adjacentCandidate)) {
          (adjacentWordsMap[word] ??= []).add(adjacentCandidate);
        }
      }
    }

    return adjacentWordsMap;
  }

  // a-z を使用する方法
  Map<String, List<String>> createAdjacentWordsMapAlphabet(
    List<String> wordList,
  ) {
    var adjacentWordsMap = <String, List<String>>{};
    var wordsSet = Set<String>.from(wordList);

    final int charACode = 'a'.codeUnitAt(0);
    final int charZCode = 'z'.codeUnitAt(0);

    for (var word in wordList) {
      for (var i = 0; i < word.length; i++) {
        for (var code = charACode; code <= charZCode; code++) {
          final char = String.fromCharCode(code);

          if (word[i] == char) {
            continue;
          }

          var changedWord =
              word.substring(0, i) + char + word.substring(i + 1, word.length);

          if (wordsSet.contains(changedWord)) {
            (adjacentWordsMap[word] ??= []).add(changedWord);
          }
        }
      }
    }

    return adjacentWordsMap;
  }

  // ワイルドカードを使用する方法
  Map<String, List<String>> createAdjacentWordsMapWildCard(
    List<String> wordList,
  ) {
    var patternMap = <String, List<String>>{};

    for (var word in wordList) {
      for (var i = 0; i < word.length; i++) {
        final pattern =
            word.substring(0, i) + "*" + word.substring(i + 1, word.length);
        (patternMap[pattern] ??= []).add(word);
      }
    }

    var adjacentWordsMap = <String, List<String>>{};

    for (var word in wordList) {
      for (var i = 0; i < word.length; i++) {
        final pattern =
            word.substring(0, i) + "*" + word.substring(i + 1, word.length);
        (adjacentWordsMap[word] ??= []).addAll(patternMap[pattern] ?? []);
      }
    }

    return adjacentWordsMap;
  }

  // メインの流れ
  int ladderLength(
    String beginWord,
    String endWord,
    List<String> wordList, {
    AdjacencyStrategy strategy = AdjacencyStrategy.wildcard,
  }) {
    final allWordsList = [...wordList, beginWord];

    // グラフ作成手法を strategy で切り替える
    final adjacentWordsMap = switch (strategy) {
      AdjacencyStrategy.naive => createAdjacentWordsMap(allWordsList),
      AdjacencyStrategy.alphabet => createAdjacentWordsMapAlphabet(
        allWordsList,
      ),
      AdjacencyStrategy.wildcard => createAdjacentWordsMapWildCard(
        allWordsList,
      ),
    };

    var changeCount = 0;
    var adjacentWords = Queue<String>.from([beginWord]);
    var seenWords = <String>{};

    while (!adjacentWords.isEmpty) {
      var adjacentCount = adjacentWords.length;
      var nextAdjacentWords = Queue<String>();

      changeCount++;

      for (var i = 0; i < adjacentCount; i++) {
        final word = adjacentWords.removeFirst();

        if (word == endWord) {
          return changeCount;
        }

        for (var adjacent in adjacentWordsMap[word] ?? []) {
          if (seenWords.contains(adjacent)) {
            continue;
          }

          nextAdjacentWords.add(adjacent);
          seenWords.add(adjacent);
        }
      }

      adjacentWords = nextAdjacentWords;
    }

    return 0;
  }
}

// Step 3:
// 率直な方法で書く。
class Solution {
  Map<String, List<String>> createAdjacentWordsMap(List<String> wordList) {
    bool isAdjacentWord(String word1, String word2) {
      if (word1.length != word2.length) {
        return false;
      }

      var differenceCount = 0;

      for (var i = 0; i < word1.length; i++) {
        if (word1[i] != word2[i]) {
          differenceCount++;
        }

        if (differenceCount > 1) {
          return false;
        }
      }

      return differenceCount == 1;
    }

    var adjacentWordsMap = <String, List<String>>{};

    for (var i = 0; i < wordList.length; i++) {
      for (var j = 0; j < wordList.length; j++) {
        if (i == j) {
          continue;
        }

        if (isAdjacentWord(wordList[i], wordList[j])) {
          (adjacentWordsMap[wordList[i]] ??= []).add(wordList[j]);
        }
      }
    }

    return adjacentWordsMap;
  }

  int ladderLength(String beginWord, String endWord, List<String> wordList) {
    final allWords = [...wordList, beginWord];
    final adjacentWordsMap = createAdjacentWordsMap(allWords);

    var changeCount = 0;
    var seenWords = <String>{};
    var adjacentWords = Queue<String>.from([beginWord]);

    while (!adjacentWords.isEmpty) {
      var adjacentCount = adjacentWords.length;
      var nextAdjacentWords = Queue<String>();

      changeCount++;

      for (var i = 0; i < adjacentCount; i++) {
        var word = adjacentWords.removeFirst();

        if (word == endWord) {
          return changeCount;
        }

        for (var adjacent in adjacentWordsMap[word] ?? []) {
          if (seenWords.contains(adjacent)) {
            continue;
          }

          nextAdjacentWords.add(adjacent);
          seenWords.add(adjacent);
        }
      }

      adjacentWords = nextAdjacentWords;
    }

    return 0;
  }
}

// 計測用のユーティリティ
String _randomWord(Random rng, int length) {
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  return String.fromCharCodes(
    List.generate(
      length,
      (_) => letters.codeUnitAt(rng.nextInt(letters.length)),
    ),
  );
}

class _BenchmarkCase {
  final String beginWord;
  final String endWord;
  final List<String> wordList;

  _BenchmarkCase(this.beginWord, this.endWord, this.wordList);
}

_BenchmarkCase _generateBenchmarkCase(
  int wordCount,
  int wordLength,
  Random rng,
) {
  // ランダムな単語リストを生成（重複は避ける）
  final wordsSet = <String>{};
  while (wordsSet.length < wordCount) {
    wordsSet.add(_randomWord(rng, wordLength));
  }
  final words = wordsSet.toList(growable: false);

  // beginWord / endWord はリストから選ぶ
  final beginWord = words.first;
  final endWord = words.length > 1 ? words[1] : _randomWord(rng, wordLength);

  return _BenchmarkCase(beginWord, endWord, words);
}

void main() {
  final solution = Solution();
  final rng = Random(0); // 再現性のため seed 固定

  // 単語数のサイズ
  final sizes = [50, 200, 500];
  const wordLength = 10;
  const iterations = 10000;

  print('計測開始 (各サイズ $iterations 回ループして平均を算出)...\n');
  print('| Word Count | naive (ms)    | alphabet (ms) | wildcard (ms) |');
  print('|------------|---------------|---------------|---------------|');

  for (final n in sizes) {
    final benchmark = _generateBenchmarkCase(n, wordLength, rng);

    double _measure(AdjacencyStrategy strategy) {
      // ウォームアップ
      for (var i = 0; i < 5; i++) {
        solution.ladderLength(
          benchmark.beginWord,
          benchmark.endWord,
          benchmark.wordList,
          strategy: strategy,
        );
      }

      final sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        solution.ladderLength(
          benchmark.beginWord,
          benchmark.endWord,
          benchmark.wordList,
          strategy: strategy,
        );
      }
      sw.stop();

      return sw.elapsedMicroseconds / iterations / 1000.0;
    }

    final naiveMs = _measure(AdjacencyStrategy.naive);
    final alphabetMs = _measure(AdjacencyStrategy.alphabet);
    final wildcardMs = _measure(AdjacencyStrategy.wildcard);

    final sizeStr = n.toString().padLeft(10);
    final naiveStr = naiveMs.toStringAsFixed(5).padLeft(13);
    final alphabetStr = alphabetMs.toStringAsFixed(5).padLeft(13);
    final wildcardStr = wildcardMs.toStringAsFixed(5).padLeft(13);

    print('| $sizeStr | $naiveStr | $alphabetStr | $wildcardStr |');
  }
}
