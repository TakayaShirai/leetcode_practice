// import 'package:collection/collection.dart';
import 'dart:math';

// Step 1
//
// 各位置における、subsequence の長さの最大値と、数字を保存しておけば、
// - その位置の数字より大きい場合は、その位置での最大値に 1 を足す。
// - その位置の数字と同じもしくは小さい場合は、その位置での数字を引き継ぐ。
// これを自分の位置に来るまで繰り返した中での、最大値を自分の値にする。
// これを繰り返せば大丈夫。ただ、O(n^2)であり、nums.length <= 2500 = 2.5 * 10^3。計算時間が少し心配。
// 2500^2 = 6.25 * 10^6. 10^7 steps/s だとして、0.1s ぐらい。まあ耐えてるか。

// Wrong Answer の回答
// そこまでの最大値ではなく、そこを含んだ時の最大値といった形で保存しておかないと
// 連続していない場合でも、連続しているとみなして更新してしまう場合がある。
// 例：[4,10,4,3,8,9] で 二つ目の 4 でも 2 が保存されており、8,9 と続くときに、
// 8が4より大きいため、2+1 で 3 が保存され、9が引き続き処理されて、4が保存されてしまう。
class SolutionWrong {
  int lengthOfLIS(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }

    var maxSubsequenceLengths = List<int>.filled(nums.length, 1);

    for (var i = 1; i < nums.length; i++) {
      final number = nums[i];

      for (var j = 0; j < i; j++) {
        final numToCompare = nums[j];

        if (numToCompare < number) {
          maxSubsequenceLengths[i] = max(
            maxSubsequenceLengths[i],
            maxSubsequenceLengths[j] + 1,
          );
        } else {
          maxSubsequenceLengths[i] = max(
            maxSubsequenceLengths[i],
            maxSubsequenceLengths[j],
          );
        }
      }
    }

    return maxSubsequenceLengths[nums.length - 1];
  }
}



// 直したやつ (O(n^2))
class SolutionLISN2 {
  int lengthOfLIS(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }

    var maxLengthsTo = List<int>.filled(nums.length, 1);
    var maxLength = 1;

    for (var i = 1; i < nums.length; i++) {
      final number = nums[i];

      for (var j = 0; j < i; j++) {
        final numToCompare = nums[j];

        if (numToCompare < number) {
          maxLengthsTo[i] = max(maxLengthsTo[i], maxLengthsTo[j] + 1);
        }
      }

      maxLength = max(maxLengthsTo[i], maxLength);
    }

    return maxLength;
  }
}

// 他の人のコード・コメント集を読む
// https://github.com/nanae772/leetcode-arai60/pull/30/changes#diff-1db223acbc455e7ff56f4c75ef24b5d22433e138e5943acad7739bc12c73889cR1
// 貪欲法。少しパズル的なので、初見だと思いつかなそうだなと思った。とりあえず長さだけは、早めに出すことができる。
// subsequence 自体を知ることはできない。
// これまでの数値より大きい数値がきたら、配列に追加。
// 大きくなければ、その配列の中で二分探索で入る位置の数字と置換。
// これを繰り返すことで、擬似的に長さを取得できる。

// https://github.com/naoto-iwase/leetcode/pull/36/changes#diff-d2458b523896b5b0f1801fe435c3323b5849e93f56f8ef25b350ad3702e1d41eR63
// https://github.com/mamo3gr/arai60/pull/29/changes#diff-1d544287674ca1fd87df032e88761e101b2fa16366cb2100eee51b412df022a9R5
// tails ではあまりピンときていなかったが、tails_by_lis_length でしっくりきた。
// lis_length がこの値の時の tail はこれですよ。みたいなイメージでやればいいのか。それで、現状一番長いものより値が大きければ、lis_length の max が増える。
// > tails配列（“長さLの増加列の末尾最小値”を保持）＋二分探索への置換で O(n log n) を狙える。
// 末尾最小値もポイントか。
// - 長さLの増加列の末尾最小値を保持
// - 二分探索（今回の数字が、どこの末尾最小値を更新するか、もしくは増加列を伸ばせるか）
//   - 既存の最長の増加列の末尾最小値よりも大きければ、新規の増加列の末尾を追加
//   - 小さければ、既存の末尾最小値を更新

// ライブラリであるはずだが、なぜかローカルで動かなかったので、LLM に実装してもらった。
// leetcode上では、なくても動く。
int _lowerBound(List<num> list, num value) {
  var lo = 0;
  var hi = list.length;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (list[mid].compareTo(value) < 0) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}

// O(nlogn) の方法で書いてみる
class SolutionLISNLogN {
  int lengthOfLIS(List<int> nums) {
    var minTailsByLISLength = <num>[double.negativeInfinity];

    for (var num in nums) {
      final minTailPosition = _lowerBound(minTailsByLISLength, num);

      if (minTailsByLISLength.length <= minTailPosition) {
        minTailsByLISLength.add(num);
        continue;
      }

      minTailsByLISLength[minTailPosition] = num;
    }

    return minTailsByLISLength.length - 1;
  }
}

// 計測開始 (各サイズ 1000 回ループして平均を算出)...
// 速さは断然 nlogn。

// | nums.length | O(n^2) (ms)   | O(n log n) (ms) |
// |-------------|---------------|-----------------|
// |         100 |       0.00922 |         0.00500 |
// |         500 |       0.21837 |         0.01563 |
// |        1000 |       0.96534 |         0.04234 |
// |        2500 |       7.28253 |         0.13101 |

// Step 3
// 最初の解法の方が、LIS 自体を取得したい場合に有利だと思うので、最初の解法で書く。
class SolutionLISN2Step3 {
  int lengthOfLIS(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }

    var lisLengthsByTail = List<int>.filled(nums.length, 1);
    var maxLisLength = 1;

    for (var i = 1; i < nums.length; i++) {
      final tailNum = nums[i];

      for (var j = 0; j < i; j++) {
        final priorTailNum = nums[j];

        if (priorTailNum < tailNum) {
          lisLengthsByTail[i] = max(
            lisLengthsByTail[i],
            lisLengthsByTail[j] + 1,
          );
        }
      }

      maxLisLength = max(maxLisLength, lisLengthsByTail[i]);
    }

    return maxLisLength;
  }
}

// 計測: O(n^2) と O(n log n) の比較

/// ソート済みリストで value 以上となる最初の index。存在しなければ list.length。]

List<int> _randomNums(Random rng, int length, int maxValue) {
  return List.generate(length, (_) => rng.nextInt(maxValue));
}

void main() {
  final solutionN2 = SolutionLISN2();
  final solutionNLogN = SolutionLISNLogN();
  final rng = Random(0);

  final sizes = [100, 500, 1000, 2500];
  const maxValue = 100000;
  const iterations = 1000;

  print('計測開始 (各サイズ $iterations 回ループして平均を算出)...\n');
  print('| nums.length | O(n^2) (ms)   | O(n log n) (ms) |');
  print('|-------------|---------------|-----------------|');

  for (final n in sizes) {
    final nums = _randomNums(rng, n, maxValue);

    double measureN2() {
      for (var i = 0; i < 5; i++) {
        solutionN2.lengthOfLIS(nums);
      }
      final sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        solutionN2.lengthOfLIS(nums);
      }
      sw.stop();
      return sw.elapsedMicroseconds / iterations / 1000.0;
    }

    double measureNLogN() {
      for (var i = 0; i < 5; i++) {
        solutionNLogN.lengthOfLIS(nums);
      }
      final sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        solutionNLogN.lengthOfLIS(nums);
      }
      sw.stop();
      return sw.elapsedMicroseconds / iterations / 1000.0;
    }

    final n2Ms = measureN2();
    final nLogNMs = measureNLogN();

    final sizeStr = n.toString().padLeft(11);
    final n2Str = n2Ms.toStringAsFixed(5).padLeft(13);
    final nLogNStr = nLogNMs.toStringAsFixed(5).padLeft(15);

    print('| $sizeStr | $n2Str | $nLogNStr |');
  }
}
