/**
 * Definition for a binary tree node.
 * class TreeNode {
 *   int val;
 *   TreeNode? left;
 *   TreeNode? right;
 *   TreeNode([this.val = 0, this.left, this.right]);
 * }
 */

// Step 1:
// 手作業でやる場合を考える
//
// 手作業でやる場合は、パッと思いつくのは和を足しながら末端まで行く。
// 末端に着いたら、和を確認して、ターゲットと同じかを確認する。
// 同じであれば、そこで作業終了。
// 異なれば、分岐点まで戻って、違う末端に向かう。
// これをノードがなくなるまで繰り返す。
//
// 部下に渡していい場合を考える。まず自分の持っているノードが子ノードを持っていないなら、ターゲットと自分のノードの値が同じかどうかを見て終わり。
// 子ノードを持っている場合は、自分の値をターゲットから引いて、同じ仕事をしてもらって、その結果を聞くだけでいい。
//
// 幅優先で一段ずつ下げていく方法もある。
// この時も、和を次のノードに引き継いでいけば、ノードが葉ノードだった場合に、そこで和を確認することができる。
//
// 感覚的には木の構造によって、幅優先探索と、深さ優先探索を使い分けるのが良さそうだが、
// 感覚の域を出ない。そもそもあっているかもわからない。
// 浅いルートが多いやつだったり一本だけ驚異的に長いルートがあるなどの、長さに差がある木は、幅優先探索で、
// あまり長さに差がない木は、深さ優先探索を選んだ方が良さそう。
//
// 計算量はO(n)。ノードの数は 5000 が最大という条件なので、10^7 steps/s とすれば、
// 5 * 10^3 / 10^7 = 5 * 10^-4 = 0.5 ms ぐらいで、全然問題なし。
//

import "dart:collection";

// 再帰（部下に渡してくやつ）
class SolutionRecursiveBefore {
  bool hasPathSum(TreeNode? root, int targetSum) {
    if (root == null) {
      return false;
    }

    if (root.left == null && root.right == null) {
      return root.val == targetSum;
    }

    final hasLeftTargetSum = hasPathSum(root.left, targetSum - root.val);
    final hasRightTargetSum = hasPathSum(root.right, targetSum - root.val);

    return hasLeftTargetSum || hasRightTargetSum;
  }
}

// 深さ優先探索（Iterative）
class SolutionDFSIterative {
  bool isLeaf(TreeNode? node) {
    if (node == null) {
      return false;
    }

    return node.left == null && node.right == null;
  }

  bool hasPathSum(TreeNode? root, int targetSum) {
    var nodeWithTotal = List<(TreeNode?, int)>.from([(root, 0)]);

    while (!nodeWithTotal.isEmpty) {
      var (node, total) = nodeWithTotal.removeLast();

      if (node == null) {
        continue;
      }

      total += node.val;

      if (isLeaf(node) && total == targetSum) {
        return true;
      }

      nodeWithTotal.add((node.left, total));
      nodeWithTotal.add((node.right, total));
    }

    return false;
  }
}

// 幅優先探索
class SolutionBFS {
  bool isLeaf(TreeNode? node) {
    if (node == null) {
      return false;
    }

    return node.left == null && node.right == null;
  }

  bool hasPathSum(TreeNode? root, int targetSum) {
    var nodeWithTotal = Queue<(TreeNode?, int)>.from([(root, 0)]);

    while (!nodeWithTotal.isEmpty) {
      var (node, total) = nodeWithTotal.removeFirst();

      if (node == null) {
        continue;
      }

      total += node.val;

      if (isLeaf(node) && total == targetSum) {
        return true;
      }

      nodeWithTotal.add((node.left, total));
      nodeWithTotal.add((node.right, total));
    }

    return false;
  }
}

// Step 2:
// 他の人のコードを見る、コメント集を読む
//
// https://github.com/05ryt31/leetcode/pull/16/changes#r2683163531
// > こうすると途中で hasTarget が見つかったとしても、計算が打ち切られずに続きますね。
// 確かに途中で見つかっても計算が続いてしまう。
// 修正して元のやつと速度比較しよう。

// https://github.com/naoto-iwase/leetcode/pull/29/changes#r2455081026
// > もし葉でtargetSumになるような経路を返却するとしたらどうでしょうか？
// > 設問としてはTrue/Falseなのですが、単純にTrue/Falseを得るよりはpathを実際に知るほうが意味があるのかなと思ったので...自分が面接だったら質問しそうです。
// 引数にこれまでの経路をリストで追加すればOKだと思う。ポインタを渡すようにすれば、空間計算量も問題ない。
// 全ての経路を得たい場合は、targetSum になる経路が見つかったら、経路をコピーして、リストに保存しておけばいいと思う。
// あとは、LLM に聞いたら、親の辞書を用意しておくのもありらしい。経路が見つかれば、最後から親のマップで逆順に戻っていって、それでリストを作成する。

// https://github.com/mamo3gr/arai60/pull/24/changes#diff-a734a4ed04f7a9849638d6840e5366836515b0fe916b3ed0b370b39096684f5dR7
// > 時間計算量は、ノード数を `N` とすると最良で `O(log N)`（最初のleafで条件を満たす）、
// > 最悪で `O(N)`. 処理としては (1) `node.val` を覚えている和に足す、(2) leafか判定する、(3) 子ノードに対して再帰する、
// > くらいなので3ステップと仮定すると、3 * 5000 / 10^6 [steps/sec] = 15ミリ秒くらいのオーダーを予想する。
// 定数倍を考えるのを今までやっていなかった。やらなくては。

// 再帰修正版（部下に渡してくやつ）
class SolutionRecursiveAfter {
  bool hasPathSum(TreeNode? root, int targetSum) {
    if (root == null) {
      return false;
    }

    if (root.left == null && root.right == null) {
      return root.val == targetSum;
    }

    return hasPathSum(root.left, targetSum - root.val) ||
        hasPathSum(root.right, targetSum - root.val);
  }
}

// 計測時間
// Skewed Tree (n >= 10000) は再帰でスタックオーバーフローするため、Iterative 版のみ測定
// 修正前後でほとんど変わらないことがわかった。再帰にしなくなると、queue を扱うオーバーヘッドなどが生まれるため少し遅くなるが、
// Stackoverflow が発生しなくなるのは大きな強み。
// こう考えると再帰よりも、Iterative の方が良いのかなと感じる。
// あとは、やはり完全に分木だと DFS の方が早い。

// === Results (mean ms) ===
// | case           | nodes   | rec_before | rec_after  | dfs_iter   | bfs        |
// |----------------|---------|------------|------------|------------|------------|
// | perfect_h10    |    2047 |     0.0146 |     0.0126 |     0.0596 |     0.0807 |
// | perfect_h12    |    8191 |     0.0347 |     0.0330 |     0.1543 |     0.2116 |
// | perfect_h14    |   32767 |     0.1395 |     0.1369 |     0.6264 |     1.5605 |
// | skewed_n500    |     500 |     0.0060 |     0.0060 |     0.0189 |     0.0081 |
// | skewed_n1000   |    1000 |     0.0128 |     0.0125 |     0.0245 |     0.0182 |
// | skewed_n2000   |    2000 |     0.0260 |     0.0251 |     0.0571 |     0.0341 |
// | skewed_n10000  |   10000 |          - |          - |     0.2791 |     0.1730 |
// | skewed_n50000  |   50000 |          - |          - |     1.2192 |     0.8579 |
// | skewed_n100000 |  100000 |          - |          - |     2.6785 |     1.8131 |

// Step 3
class SolutionStep3 {
  bool hasPathSum(TreeNode? root, int targetSum) {
    if (root == null) {
      return false;
    }

    if (root.left == null && root.right == null) {
      return root.val == targetSum;
    }

    return hasPathSum(root.left, targetSum - root.val) ||
        hasPathSum(root.right, targetSum - root.val);
  }
}

// ----------------------------
// ベンチマーク用のコード
// ----------------------------

// TreeNode 定義
class TreeNode {
  int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode([this.val = 0, this.left, this.right]);
}

// ----------------------------
// 木の生成ヘルパー
// ----------------------------

/// Perfect binary tree（完全二分木）を生成
/// height=0 -> 1 node, height=h -> 2^(h+1)-1 nodes
TreeNode? buildPerfectTree(int height, {int val = 1}) {
  if (height < 0) {
    return null;
  }
  final root = TreeNode(val);
  if (height == 0) {
    return root;
  }
  root.left = buildPerfectTree(height - 1, val: val);
  root.right = buildPerfectTree(height - 1, val: val);
  return root;
}

/// Skewed tree（偏った木）を生成
/// n nodes がすべて一方向（left または right）に連なる
TreeNode? buildSkewedTree(int n, {int val = 1, String direction = "left"}) {
  if (n <= 0) {
    return null;
  }
  final root = TreeNode(val);
  var cur = root;
  for (var i = 1; i < n; i++) {
    final nxt = TreeNode(val);
    if (direction == "left") {
      cur.left = nxt;
    } else {
      cur.right = nxt;
    }
    cur = nxt;
  }
  return root;
}

// ----------------------------
// 既存クラスをラップしたベンチマーク用関数
// ----------------------------

final _solutionRecursiveBefore = SolutionRecursiveBefore();
final _solutionRecursiveAfter = SolutionRecursiveAfter();
final _solutionDFSIterative = SolutionDFSIterative();
final _solutionBFS = SolutionBFS();

bool hasPathSumRecursiveBefore(TreeNode? root, int targetSum) =>
    _solutionRecursiveBefore.hasPathSum(root, targetSum);

bool hasPathSumRecursiveAfter(TreeNode? root, int targetSum) =>
    _solutionRecursiveAfter.hasPathSum(root, targetSum);

bool hasPathSumDFSIterative(TreeNode? root, int targetSum) =>
    _solutionDFSIterative.hasPathSum(root, targetSum);

bool hasPathSumBFS(TreeNode? root, int targetSum) =>
    _solutionBFS.hasPathSum(root, targetSum);

// ----------------------------
// ベンチマークユーティリティ
// ----------------------------

typedef PathSumFn = bool Function(TreeNode? root, int targetSum);

class BenchmarkResult {
  final double meanUs;
  final double medianUs;
  final double minUs;
  final double maxUs;
  final int loops;

  BenchmarkResult({
    required this.meanUs,
    required this.medianUs,
    required this.minUs,
    required this.maxUs,
    required this.loops,
  });
}

BenchmarkResult bench(PathSumFn fn, TreeNode? root, int target,
    {int loops = 50}) {
  // ウォームアップ
  fn(root, target);

  final times = <double>[];
  for (var i = 0; i < loops; i++) {
    final sw = Stopwatch()..start();
    fn(root, target);
    sw.stop();
    times.add(sw.elapsedMicroseconds.toDouble());
  }

  times.sort();
  final mean = times.reduce((a, b) => a + b) / times.length;
  final median = times.length.isOdd
      ? times[times.length ~/ 2]
      : (times[times.length ~/ 2 - 1] + times[times.length ~/ 2]) / 2;
  final minVal = times.first;
  final maxVal = times.last;

  return BenchmarkResult(
    meanUs: mean,
    medianUs: median,
    minUs: minVal,
    maxUs: maxVal,
    loops: loops,
  );
}

// ----------------------------
// ベンチマーク実行
// ----------------------------

void main() {
  final rows = <Map<String, dynamic>>[];
  const loops = 80;

  final allImplementations = <String, PathSumFn>{
    'recursive_before': hasPathSumRecursiveBefore,
    'recursive_after': hasPathSumRecursiveAfter,
    'dfs_iterative': hasPathSumDFSIterative,
    'bfs': hasPathSumBFS,
  };

  // Iterative のみ（再帰でスタックオーバーフローする深いケース用）
  final iterativeOnly = <String, PathSumFn>{
    'dfs_iterative': hasPathSumDFSIterative,
    'bfs': hasPathSumBFS,
  };

  print('ベンチマーク開始...\n');

  // ----------------------------
  // Perfect Tree のテスト
  // height を下げる（10, 12, 14）: Dart の再帰スタック制限を考慮
  // ----------------------------
  for (final h in [10, 12, 14]) {
    final root = buildPerfectTree(h, val: 1);
    // 不可能な target を設定して全探索を強制
    final target = (h + 1) + 1;
    final nodes = (1 << (h + 1)) - 1; // 2^(h+1) - 1

    for (final entry in allImplementations.entries) {
      final name = entry.key;
      final fn = entry.value;
      final r = bench(fn, root, target, loops: loops);
      rows.add({
        'case': 'perfect_h$h',
        'nodes': nodes,
        'impl': name,
        'mean_us': r.meanUs,
        'median_us': r.medianUs,
        'min_us': r.minUs,
        'max_us': r.maxUs,
      });
    }
  }

  // ----------------------------
  // Skewed Tree のテスト
  // 再帰はスタックオーバーフローしやすいので、小さいサイズのみ
  // 大きいサイズは BFS のみで測定
  // ----------------------------

  // 小さいサイズ: 再帰もテスト可能（2000 ノード程度なら大丈夫）
  for (final n in [500, 1000, 2000]) {
    final root = buildSkewedTree(n, val: 1);
    final target = n + 1;

    for (final entry in allImplementations.entries) {
      final name = entry.key;
      final fn = entry.value;
      final r = bench(fn, root, target, loops: loops);
      rows.add({
        'case': 'skewed_n$n',
        'nodes': n,
        'impl': name,
        'mean_us': r.meanUs,
        'median_us': r.medianUs,
        'min_us': r.minUs,
        'max_us': r.maxUs,
      });
    }
  }

  // 大きいサイズ: Iterative のみ（再帰はスタックオーバーフロー）
  print('\n注意: Skewed Tree (n >= 10000) は再帰でスタックオーバーフローするため、Iterative 版のみ測定\n');
  for (final n in [10000, 50000, 100000]) {
    final root = buildSkewedTree(n, val: 1);
    final target = n + 1;
    final localLoops = n < 100000 ? loops : 30;

    for (final entry in iterativeOnly.entries) {
      final name = entry.key;
      final fn = entry.value;
      final r = bench(fn, root, target, loops: localLoops);
      rows.add({
        'case': 'skewed_n$n',
        'nodes': n,
        'impl': name,
        'mean_us': r.meanUs,
        'median_us': r.medianUs,
        'min_us': r.minUs,
        'max_us': r.maxUs,
      });
    }
  }

  // ----------------------------
  // 結果の表示
  // ----------------------------
  print('=== Results (mean ms) ===');
  print(
      '| case           | nodes   | rec_before | rec_after  | dfs_iter   | bfs        |');
  print(
      '|----------------|---------|------------|------------|------------|------------|');

  // case と nodes でグループ化
  final groupedData = <String, Map<String, double>>{};
  final nodesMap = <String, int>{};

  for (final row in rows) {
    final caseKey = row['case'] as String;
    final impl = row['impl'] as String;
    final meanUs = row['mean_us'] as double;

    groupedData[caseKey] ??= {};
    groupedData[caseKey]![impl] = meanUs / 1000.0; // μs -> ms
    nodesMap[caseKey] = row['nodes'] as int;
  }

  for (final caseKey in groupedData.keys) {
    final data = groupedData[caseKey]!;
    final nodes = nodesMap[caseKey]!;

    final recBefore = data['recursive_before'] ?? 0;
    final recAfter = data['recursive_after'] ?? 0;
    final dfsIter = data['dfs_iterative'] ?? 0;
    final bfs = data['bfs'] ?? 0;

    final caseStr = caseKey.padRight(14);
    final nodesStr = nodes.toString().padLeft(7);
    final recBeforeStr =
        recBefore > 0 ? recBefore.toStringAsFixed(4).padLeft(10) : '-'.padLeft(10);
    final recAfterStr =
        recAfter > 0 ? recAfter.toStringAsFixed(4).padLeft(10) : '-'.padLeft(10);
    final dfsIterStr =
        dfsIter > 0 ? dfsIter.toStringAsFixed(4).padLeft(10) : '-'.padLeft(10);
    final bfsStr = bfs.toStringAsFixed(4).padLeft(10);

    print(
        '| $caseStr | $nodesStr | $recBeforeStr | $recAfterStr | $dfsIterStr | $bfsStr |');
  }
}
