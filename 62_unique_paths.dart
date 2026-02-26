// Step 1
// 縦のマスを m, 横のマスを n とした場合に、全経路の数は m-1 個の「→」とn-1個の「↓」の並び替えでできる数とみなせるので、全経路の数は(m+n-2)C(m-1)ある。
// よって、ただこれを計算すれば良いだけだが、これはコーディングインタビューで求められている解法ではないだろう。
// 数学を使わずにゴリゴリにやるとしたら、全ての経路を通ってから、その経路を set で保存して、その set の長さを返せばいい。
// 全ての経路をしらみつぶしに通るには、O(2^(m+n-2))通りを処理する必要がある。
// 今 n, m <= 100 なので、2^198 になり、これはとてもではないが計算できない。2^198 ~ 2^200 = (2^10)^20 ~ (10^3)^20 = 10^60.
// 10^7 steps/s を仮定すると、10^53 s かかる。とても現実的ではない。

// 何回も同じ場所を通っているはずなので、メモ化できる部分をメモ化する。
// 基本的には、(row, col) の位置に辿り着いて、もうすでにそこの結果がわかっている場合は、処理を打ち切って良い。
// もしない場合は、(row, col)の位置には、上からか左からかしか辿り着けないので、上と左の結果をそこに代入する。
// これを Finish 地点まで続ければ良い。

// 数学的な解法
class Solution {
  // Calculates (num1)C(num2).
  int combination(int num1, int num2) {
    if (num2 > num1) {
      throw Exception("num1 should be larger than num2.");
    }

    if (num2 > num1 - num2) {
      num2 = num1 - num2;
    }

    var combination = 1;
    for (var i = 0; i < num2; i++) {
      combination = combination * (num1 - i) ~/ (i + 1);
    }

    return combination;
  }

  int uniquePaths(int m, int n) {
    return combination(m + n - 2, m - 1);
  }
}

// メモ化
class Solution {
  int uniquePaths(int m, int n) {
    if (m < 0 || n < 0) {
      throw Exception("Both of inputs should be larger than 0.");
    }

    var uniquePathsCounts = List.generate(m, (_) => List<int?>.filled(n, null));

    int helper(int row, int col) {
      if (row < 0 || col < 0) {
        return 0;
      }
      if (row == 0 || col == 0) {
        uniquePathsCounts[row][col] = 1;
        return uniquePathsCounts[row][col]!;
      }

      if (uniquePathsCounts[row][col] != null) {
        return uniquePathsCounts[row][col]!;
      }

      uniquePathsCounts[row][col] = helper(row - 1, col) + helper(row, col - 1);
      return uniquePathsCounts[row][col]!;
    }

    helper(m - 1, n - 1);
    return uniquePathsCounts[m - 1][n - 1]!;
  }
}

// 右から下に埋めていけば順に埋めていけばいいから、Iterative でも簡単に書ける。
class Solution {
  int uniquePaths(int m, int n) {
    var uniquePathsCounts = List.generate(m, (_) => List<int>.filled(n, 0));

    for (var row = 0; row < m; row++) {
      for (var col = 0; col < n; col++) {
        if (row == 0 || col == 0) {
          uniquePathsCounts[row][col] = 1;
          continue;
        }

        uniquePathsCounts[row][col] =
            uniquePathsCounts[row - 1][col] + uniquePathsCounts[row][col - 1];
      }
    }

    return uniquePathsCounts[m - 1][n - 1];
  }
}

// (m-1, n-1) から進めても良いが、やることがほとんど変わらないためスキップ。

// Step 2
// 他の人のコード・コメント集を読む。
// https://github.com/mamo3gr/arai60/pull/31/changes#diff-0515b2d35730ff4b80a3d403e6011799fb6d63e45fe6f492fb8ecad8136833abR4
// 自分は再帰で巡りつつ、メモに残していたが、確かにメモに残さなくて再帰だけで書ける。
// ただ、メモに残さないと途中での打ち切りができないため、計算時間が犠牲になる。

// https://discord.com/channels/1084280443945353267/1322513618217996338/1343221128096780420
// 計算量の見積もりの話。
// ホチキスに止めることで、請求書が一部なくなるから、請求書の数　- 1 = 必要なホチキスの数。
// トーナメントで優勝者を決めるのに必要な試合数を求めるのと同じ。

// https://github.com/mamo3gr/arai60/pull/31/changes#diff-4b564fa6f99600dc5488db8d487f42a4cd6ce15179c10eb1fbde685766c9cc5aR20
// あー、そっか。各行ごとの情報しかいらないから、一次元配列だけ保持するだけで問題ないのか。
// 可読性は下がるため、メモリに心配がある状況で使いたいかも。

// https://github.com/naoto-iwase/leetcode/pull/38/changes#diff-8a6ff63343e74cc80d732f8899ddf515ccf1d52a91f0f73f0d8b022fd23400cbR44
// パッと出されると、何をしているのかを解読するのに時間がかかる。
// この問題を解いたことがない状態から考えると尚更かかるだろうから、空間計算量節約したい時以外はあんま使いたくないなーと感じた。

// 一次元配列の方法も書いておく
class Solution {
  int uniquePaths(int m, int n) {
    var uniquePathsCounts = List<int>.filled(n, 1);

    for (var row = 0; row < m; row++) {
      for (var col = 0; col < n; col++) {
        if (row == 0 || col == 0) {
          continue;
        }

        uniquePathsCounts[col] =
            uniquePathsCounts[col] + uniquePathsCounts[col - 1];
      }
    }

    return uniquePathsCounts[n - 1];
  }
}

// Step 3
// 可読性を重視して、二次元配列の方法でかく
class Solution {
  int uniquePaths(int m, int n) {
    var uniquePathsCounts = List.generate(m, (_) => List<int>.filled(n, 0));

    for (var row = 0; row < m; row++) {
      for (var col = 0; col < n; col++) {
        if (row == 0 || col == 0) {
          uniquePathsCounts[row][col] = 1;
          continue;
        }

        uniquePathsCounts[row][col] =
            uniquePathsCounts[row - 1][col] + uniquePathsCounts[row][col - 1];
      }
    }

    return uniquePathsCounts[m - 1][n - 1];
  }
}
