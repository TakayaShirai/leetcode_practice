import 'dart:math';

class TreeNode {
  int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode([this.val = 0, this.left, this.right]);
}

// Step 1:
// 幅優先探索をすれば、層ごとのノードを集めることは簡単。
// その順序を層ごとにどう変えるか、というのが肝。
// 単純な方法としては、最初の高さを 0 として、偶数の時は、通常通り、奇数の時は、取得したノードの配列を反転して、
// 最終的な結果の配列に入れる方法。ただ、これだと、反転操作で結構時間を食う。
// ノードの個数を N とする。高さが logN でそのうち半分に対して反転操作をするから、 logN/2回の反転操作。
// それぞれの層の個数の平均は、高さを K としたら計算したら (2^(K+1) - 1)/(K+1) なので、計算量は O(N + logN * 2^(K+1) / (K+1))
// 2^K = N, K = logN、なので、計算量は O(N + logN * 2^(logN+1) / (logN+1)) で大体 O(N) になる。定数倍は大体 2ぐらい。

// あとは何があるかな。
// 値の格納と、次の層の格納をしなければならない。
// 分けて２回でやる方法がありそう。
// 箱の中でノードが一列に並んでいるとすれば、
// 値を格納する処理は、
// - 左から右で箱に格納されているノードを、そのままの前からの順で値を格納していく。
// - 右から左で箱に格納されているノードも、そのままの前からの順で値を格納していく。
// 次の層を格納する処理としては、
// - 左から右で箱に格納されているノードから、次の層のノードを右から左に格納する
// - 右から左に箱に格納されているノードから、次の層のノードを左から右に格納する
// つまり、
// - 左から右の順に格納されている場合は、最後尾から右、左の順に子ノードを格納する
// - 右から左の順に格納されている場合は、最後尾から左、右の順に子ノードを格納する。
// これを考えると、
// 値の格納と、次の層の格納の方向が逆で一度にどちらもやるのはむずかしそうに思える。だから、２回やりたい。
// もっといい方法があるかもしれないが、とりあえずこれでやってみる。計算量は O(N) で、2回走査が入るからそこの定数倍は入る。
// 処理としては、１回目の走査で、値の格納。２回目の走査で、子ノードの格納を２回。
// 結局走査が1回分増えるだけだから、3N か 4N の違いな気がする。だとするなら、N <= 2000 で Dart は 10^7 steps/s だとすると、
// 2000 / 10^7 = 2 * 10^-4 = 0.2 ms しか変わらないから、全く問題ない。後で合っているか確かめる。
// だいぶパズル的な要素があり、これを採用するのも、可読性的に微妙な気がする。

// 反転走査をやる方法
// 書いていて、今まで currentLevelNodes にキューを使用していたが、リストで全く問題ないことに気づいた。
class SolutionReverse {
  List<List<int>> zigzagLevelOrder(TreeNode? root) {
    if (root == null) {
      return [];
    }

    var isRightToLeft = false;
    var currentLevelNodes = <TreeNode>[root];
    var zigzagLevelOrderNodes = <List<int>>[];

    while (!currentLevelNodes.isEmpty) {
      var nextLevelNodes = <TreeNode>[];
      var nodeValues = <int>[];

      for (var node in currentLevelNodes) {
        nodeValues.add(node.val);

        if (node.left != null) {
          nextLevelNodes.add(node.left!);
        }
        if (node.right != null) {
          nextLevelNodes.add(node.right!);
        }
      }

      if (isRightToLeft) {
        nodeValues = nodeValues.reversed.toList();
      }

      isRightToLeft = !isRightToLeft;
      currentLevelNodes = nextLevelNodes;
      zigzagLevelOrderNodes.add(nodeValues);
    }

    return zigzagLevelOrderNodes;
  }
}

// 反転走査をしない方法
// wantsRightToLeft がコードを読まないとおそらく意味が伝わりづらい気がするのが懸念点。
// 先に、関数を定義しているからそこまで問題ない気もする。
class SolutionChildOrder {
  List<TreeNode> extractNextLevelNodes(
    List<TreeNode> nodes,
    bool wantsRightToLeft,
  ) {
    var nextLevelNodes = <TreeNode>[];

    for (var node in nodes.reversed) {
      var children = wantsRightToLeft
          ? [node.right, node.left]
          : [node.left, node.right];

      for (var child in children) {
        if (child != null) {
          nextLevelNodes.add(child!);
        }
      }
    }

    return nextLevelNodes;
  }

  List<List<int>> zigzagLevelOrder(TreeNode? root) {
    if (root == null) {
      return [];
    }

    var wantsRightToLeft = true;
    var currentLevelNodes = <TreeNode>[root];
    var zigzagLevelOrderNodes = <List<int>>[];

    while (!currentLevelNodes.isEmpty) {
      var nodeValues = <int>[];
      for (var node in currentLevelNodes) {
        nodeValues.add(node.val);
      }

      final nextLevelNodes = extractNextLevelNodes(
        currentLevelNodes,
        wantsRightToLeft,
      );

      wantsRightToLeft = !wantsRightToLeft;
      currentLevelNodes = nextLevelNodes;
      zigzagLevelOrderNodes.add(nodeValues);
    }

    return zigzagLevelOrderNodes;
  }
}

// 反転走査をしない方法（リスト生成を避けた改良版）extractNextLevelNodes のみ、処置方法が違う。
class SolutionChildOrderOptimized {
  List<TreeNode> extractNextLevelNodes(
    List<TreeNode> nodes,
    bool wantsRightToLeft,
  ) {
    var nextLevelNodes = <TreeNode>[];

    for (var i = nodes.length - 1; i >= 0; i--) {
      final node = nodes[i];
      final first = wantsRightToLeft ? node.right : node.left;
      final second = wantsRightToLeft ? node.left : node.right;

      if (first != null) {
        nextLevelNodes.add(first);
      }
      if (second != null) {
        nextLevelNodes.add(second);
      }
    }

    return nextLevelNodes;
  }

  List<List<int>> zigzagLevelOrder(TreeNode? root) {
    if (root == null) {
      return [];
    }

    var wantsRightToLeft = true;
    var currentLevelNodes = <TreeNode>[root];
    var zigzagLevelOrderNodes = <List<int>>[];

    while (!currentLevelNodes.isEmpty) {
      var nodeValues = <int>[];
      for (var node in currentLevelNodes) {
        nodeValues.add(node.val);
      }

      final nextLevelNodes = extractNextLevelNodes(
        currentLevelNodes,
        wantsRightToLeft,
      );

      wantsRightToLeft = !wantsRightToLeft;
      currentLevelNodes = nextLevelNodes;
      zigzagLevelOrderNodes.add(nodeValues);
    }

    return zigzagLevelOrderNodes;
  }
}

// Step 2
// 他の人のコード・コメント集を読む。
//
// https://github.com/naoto-iwase/leetcode/pull/31/changes#diff-18873955c02f8e2268cf8385696e9d0aa7cce7bd5e4d5059818cb2903515da83R75
// 深さ優先探索でやる方法を思いついてなかったが、確かに全部走査し終わってから、反転したいところを反転させていく方法もあった。
// 結構シンプル。
//
// https://github.com/naoto-iwase/leetcode/pull/31/changes#diff-18873955c02f8e2268cf8385696e9d0aa7cce7bd5e4d5059818cb2903515da83R130
// インデックスで nodeValues に追加していく方法もある。

// インデックスでやる手法
class SolutionIndex {
  List<List<int>> zigzagLevelOrder(TreeNode? root) {
    if (root == null) {
      return [];
    }

    var isLeftToRight = true;
    var currentLevelNodes = <TreeNode>[root];
    var zigzagLevelOrderValues = <List<int>>[];

    while (!currentLevelNodes.isEmpty) {
      var nodesCount = currentLevelNodes.length;
      var nodeValues = List<int>.filled(nodesCount, 0);
      var nextLevelNodes = <TreeNode>[];

      for (int i = 0; i < nodesCount; i++) {
        var node = currentLevelNodes[i];

        var index = isLeftToRight ? i : nodesCount - 1 - i;
        nodeValues[index] = node.val;

        if (node.left != null) {
          nextLevelNodes.add(node.left!);
        }
        if (node.right != null) {
          nextLevelNodes.add(node.right!);
        }
      }

      zigzagLevelOrderValues.add(nodeValues);
      currentLevelNodes = nextLevelNodes;
      isLeftToRight = !isLeftToRight;
    }

    return zigzagLevelOrderValues;
  }
}

// 計測時間
// リスト生成には、時間がかかるらしい。インデックスの方法がやはり一番早いが、たいした違いはない。
// 
// | Height | Nodes       | reverse (ms)  | childOrder (ms) | childOrderOpt (ms) | index (ms)    |
// |--------|-------------|---------------|-----------------|--------------------| --------------|
// |      5 |          63 |       0.00651 |         0.00473 |            0.00240 |       0.00175 |
// |     10 |        2047 |       0.02753 |         0.04770 |            0.02560 |       0.01516 |
// |     15 |       65535 |       1.98642 |         2.94020 |            2.04103 |       1.23191 |
// |     20 |     2097151 |      98.13375 |       121.42813 |           92.00551 |      64.99191 |

// Step 3
// インデックスでやる方法で書く。
class Solution {
  List<List<int>> zigzagLevelOrder(TreeNode? root) {
    if (root == null) {
      return [];
    }

    var isLeftToRight = true;
    var currentLevelNodes = <TreeNode>[root];
    var zigzagLevelOrderNodes = <List<int>>[];

    while (!currentLevelNodes.isEmpty) {
      var nodesCount = currentLevelNodes.length;
      var nextLevelNodes = <TreeNode>[];
      var nodeValues = List<int>.filled(nodesCount, 0);

      for (var i = 0; i < nodesCount; i++) {
        final node = currentLevelNodes[i];
        final valueIndex = isLeftToRight ? i : nodesCount - 1 - i;

        nodeValues[valueIndex] = node.val;

        if (node.left != null) {
          nextLevelNodes.add(node.left!);
        }
        if (node.right != null) {
          nextLevelNodes.add(node.right!);
        }
      }

      currentLevelNodes = nextLevelNodes;
      zigzagLevelOrderNodes.add(nodeValues);
      isLeftToRight = !isLeftToRight;
    }

    return zigzagLevelOrderNodes;
  }
}

// ベンチマーク用ユーティリティ
TreeNode _generatePerfectBinaryTree(int height, Random rng) {
  if (height <= 0) {
    return TreeNode(rng.nextInt(1000));
  }

  var root = TreeNode(rng.nextInt(1000));
  root.left = _generatePerfectBinaryTree(height - 1, rng);
  root.right = _generatePerfectBinaryTree(height - 1, rng);
  return root;
}

void main() {
  final solutionReverse = SolutionReverse();
  final solutionChildOrder = SolutionChildOrder();
  final solutionChildOrderOpt = SolutionChildOrderOptimized();
  final solutionIndex = SolutionIndex();
  final rng = Random(42);

  final heights = [5, 10, 15, 20];

  print('計測開始...\n');
  print(
    '| Height | Nodes       | reverse (ms)  | childOrder (ms) | childOrderOpt (ms) | index (ms)    |',
  );
  print(
    '|--------|-------------|---------------|-----------------|--------------------| --------------|',
  );

  for (final h in heights) {
    final tree = _generatePerfectBinaryTree(h, rng);
    final nodeCount = (1 << (h + 1)) - 1; // 2^(h+1) - 1

    final iterations = h <= 15 ? 1000 : (h <= 20 ? 100 : 10);

    double measureReverse() {
      for (var i = 0; i < 3; i++) {
        solutionReverse.zigzagLevelOrder(tree);
      }

      final sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        solutionReverse.zigzagLevelOrder(tree);
      }
      sw.stop();
      return sw.elapsedMicroseconds / iterations / 1000.0;
    }

    double measureChildOrder() {
      for (var i = 0; i < 3; i++) {
        solutionChildOrder.zigzagLevelOrder(tree);
      }

      final sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        solutionChildOrder.zigzagLevelOrder(tree);
      }
      sw.stop();
      return sw.elapsedMicroseconds / iterations / 1000.0;
    }

    double measureChildOrderOpt() {
      for (var i = 0; i < 3; i++) {
        solutionChildOrderOpt.zigzagLevelOrder(tree);
      }

      final sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        solutionChildOrderOpt.zigzagLevelOrder(tree);
      }
      sw.stop();
      return sw.elapsedMicroseconds / iterations / 1000.0;
    }

    double measureIndex() {
      for (var i = 0; i < 3; i++) {
        solutionIndex.zigzagLevelOrder(tree);
      }

      final sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        solutionIndex.zigzagLevelOrder(tree);
      }
      sw.stop();
      return sw.elapsedMicroseconds / iterations / 1000.0;
    }

    final reverseMs = measureReverse();
    final childOrderMs = measureChildOrder();
    final childOrderOptMs = measureChildOrderOpt();
    final indexMs = measureIndex();

    final heightStr = h.toString().padLeft(6);
    final nodeStr = nodeCount.toString().padLeft(11);
    final reverseStr = reverseMs.toStringAsFixed(5).padLeft(13);
    final childOrderStr = childOrderMs.toStringAsFixed(5).padLeft(15);
    final childOrderOptStr = childOrderOptMs.toStringAsFixed(5).padLeft(18);
    final indexStr = indexMs.toStringAsFixed(5).padLeft(13);

    print('| $heightStr | $nodeStr | $reverseStr | $childOrderStr | $childOrderOptStr | $indexStr |');
  }
}
