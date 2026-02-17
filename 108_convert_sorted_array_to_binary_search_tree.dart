/**
 * Definition for a binary tree node.
 * class TreeNode {
 *   int val;
 *   TreeNode? left;
 *   TreeNode? right;
 *   TreeNode([this.val = 0, this.left, this.right]);
 * }
 */

import "dart:collection";

// 計測用に TreeNode を定義
class TreeNode {
  int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode([this.val = 0, this.left, this.right]);
}

// Step 1
// 手作業でやる場合を考える。
// 与えられたリストの中で、中央に位置しているのを親にする。
// そのあと、親から左のリストを部下に渡して、BSTを作ってもらう。
// 右のリストも同様に、もう一人の部下に渡して、BSTを作ってもらう。
// 作ってもらった、BST を自分の手持ちのノードにくっつける。
// それを完成品とする。

// スライス + 再帰
class SolutionSliceRecursive {
  TreeNode? sortedArrayToBST(List<int> nums) {
    if (nums.isEmpty) {
        return null;
    }

    final midIndex = nums.length ~/ 2;
    final root = TreeNode(nums[midIndex]);

    final leftBST = sortedArrayToBST(nums.sublist(0, midIndex));
    final rightBST = sortedArrayToBST(nums.sublist(midIndex + 1));

    root.left = leftBST;
    root.right = rightBST;

    return root;
  }
}

// Step 2
// 他の人のコード・コメント集読む
//
// https://github.com/nanae772/leetcode-arai60/pull/24/changes#diff-ca858d2e233a2396fd0c9e7a3aadc7fe6c7f046232ba27363c5da3df485c6b90R1
// スライスではなく、インデックスを渡す方法
// スライスを作ってしまうと、確かにそこで無駄な作業が発生するが、インデックスを渡すことでその処理をしなくて済むようになる。
// 後で、時間がどれぐらい変わるかを計測する。

// https://github.com/naoto-iwase/leetcode/pull/23/changes#diff-778924daa69a7bf675983570da8fa86f8c82bfcc997c74ef37854f3540e7f574R60
// Iterative な方法。変数名や関数名が役割を端的に表していて、読みやすい。

// https://github.com/mamo3gr/arai60/pull/23/changes#diff-349460ef4782a0b8fdb5cbbf1c3703606b5c1e4e9bbf3eb9c09fc55a74c4eec0R10
// 一つ上のリンクでは、左と右の配列に分けてから、キューに入れていたが、配列を入れてから、分けるのは各自でやってもらう手法。
// こっちの方がわかりやすいかも。

// インデックスを渡す方法（再帰）
class SolutionIndex {
    TreeNode? sortedArrayToBSTIndex(List<int> nums, int startIndex, int lastIndex) {
        if (startIndex > lastIndex) {
            return null;
        }

        final midIndex = startIndex + (lastIndex - startIndex) ~/ 2;
        final root = TreeNode(nums[midIndex]);

        final leftBST = sortedArrayToBSTIndex(nums, startIndex, midIndex - 1);
        final rightBST = sortedArrayToBSTIndex(nums, midIndex + 1, lastIndex);

        root.left = leftBST;
        root.right = rightBST;

        return root;
    }

    TreeNode? sortedArrayToBST(List<int> nums) {
        return sortedArrayToBSTIndex(nums, 0, nums.length - 1);
    }
}

// スライス + Iterative な解法
class SolutionSliceIterative {
    TreeNode? sortedArrayToBST(List<int> nums) {
        TreeNode? buildRoot(List<int> nums) {
            if (nums.isEmpty) {
                return null;
            }

            return TreeNode(nums[nums.length ~/ 2]);
        }

        var root = buildRoot(nums);
        var parentWithNums = Queue<(TreeNode?, List<int>)>.from([(root, nums)]);

        while (!parentWithNums.isEmpty) {
            final (parent, nums) = parentWithNums.removeFirst();

            if (parent == null) {
                continue;
            }

            final leftNums = nums.sublist(0, nums.length ~/ 2);
            final rightNums = nums.sublist(nums.length ~/ 2 + 1);
            final leftNode = buildRoot(leftNums);
            final rightNode = buildRoot(rightNums);

            parent.left = leftNode;
            parent.right = rightNode;

            parentWithNums.add((leftNode, leftNums));
            parentWithNums.add((rightNode, rightNums));
        }

        return root;
    }
}

// 計測時間の結果
// やはり Index の方が早いが、大した差はないみたい。
// それより、Iterative の方がかなり遅くなっている。
// LLM によると、原因は以下らしい。
// - Queue の操作コスト
//   - Queue.add() と Queue.removeFirst() は各ノードごとに呼ばれる
//   - キューにタプル (TreeNode?, List<int>) を格納するため、オブジェクト生成のオーバーヘッドがある
//   - 再帰ではコールスタックを使うだけなので、この明示的なデータ構造管理が不要
//
// | Array Size | Slice+Recursive (ms) | Slice+Iterative (ms) | Index+Recursive (ms) |
// |------------|----------------------|----------------------|----------------------|
// |         10 |              0.00228 |              0.01044 |              0.00086 |
// |        100 |              0.00618 |              0.07964 |              0.00141 |
// |       1000 |              0.04283 |              0.73359 |              0.01099 |
// |      10000 |              0.45789 |              8.73829 |              0.10450 |

// Step 3
// 再帰の方が直感的ですぐ書けるが、感覚的に書けるやつ練習してもあまり意味がないので、面倒な方で書く。
class Solution {
    TreeNode? sortedArrayToBST(List<int> nums) {
        TreeNode? buildRoot(List<int> nums) {
            if (nums.isEmpty) {
                return null;
            }

            return TreeNode(nums[nums.length ~/ 2]);
        }

        var root = buildRoot(nums);
        var parentWithNums = Queue<(TreeNode?, List<int>)>.from([(root, nums)]);

        while (!parentWithNums.isEmpty) {
            final (parent, nums) = parentWithNums.removeFirst();

            if (parent == null) {
                continue;
            }

            final leftNums = nums.sublist(0, nums.length ~/ 2);
            final rightNums = nums.sublist(nums.length ~/ 2 + 1);
            final leftNode = buildRoot(leftNums);
            final rightNode = buildRoot(rightNums);

            parent.left = leftNode;
            parent.right = rightNode;

            parentWithNums.add((leftNode, leftNums));
            parentWithNums.add((rightNode, rightNums));
        }

        return root;
    }
}

// ============================================
// 計測用コード
// ============================================

// ソート済み配列生成関数
List<int> generateSortedArray(int n) {
  return List<int>.generate(n, (i) => i);
}

void main() {
  final solutionSliceRecursive = SolutionSliceRecursive();
  final solutionSliceIterative = SolutionSliceIterative();
  final solutionIndex = SolutionIndex();

  final sizes = [10, 100, 1000, 10000];
  final iterations = 1000;

  print("計測開始 (各サイズ $iterations 回ループして平均を算出)...\n");
  print("| Array Size | Slice+Recursive (ms) | Slice+Iterative (ms) | Index+Recursive (ms) |");
  print("|------------|----------------------|----------------------|----------------------|");

  for (final n in sizes) {
    final nums = generateSortedArray(n);

    // Slice+Recursive のウォームアップ
    for (var i = 0; i < 5; i++) {
      solutionSliceRecursive.sortedArrayToBST(List.from(nums));
    }

    // Slice+Recursive の計測
    final stopwatchSliceRecursive = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionSliceRecursive.sortedArrayToBST(List.from(nums));
    }
    stopwatchSliceRecursive.stop();
    final avgSliceRecursive = (stopwatchSliceRecursive.elapsedMicroseconds / iterations / 1000).toStringAsFixed(5);

    // Slice+Iterative のウォームアップ
    for (var i = 0; i < 5; i++) {
      solutionSliceIterative.sortedArrayToBST(List.from(nums));
    }

    // Slice+Iterative の計測
    final stopwatchSliceIterative = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionSliceIterative.sortedArrayToBST(List.from(nums));
    }
    stopwatchSliceIterative.stop();
    final avgSliceIterative = (stopwatchSliceIterative.elapsedMicroseconds / iterations / 1000).toStringAsFixed(5);

    // Index+Recursive のウォームアップ
    for (var i = 0; i < 5; i++) {
      solutionIndex.sortedArrayToBST(List.from(nums));
    }

    // Index+Recursive の計測
    final stopwatchIndex = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionIndex.sortedArrayToBST(List.from(nums));
    }
    stopwatchIndex.stop();
    final avgIndex = (stopwatchIndex.elapsedMicroseconds / iterations / 1000).toStringAsFixed(5);

    // 結果の出力
    final sizeStr = n.toString().padLeft(10);
    final avgSliceRecursiveStr = avgSliceRecursive.padLeft(20);
    final avgSliceIterativeStr = avgSliceIterative.padLeft(20);
    final avgIndexStr = avgIndex.padLeft(20);
    print("| $sizeStr | $avgSliceRecursiveStr | $avgSliceIterativeStr | $avgIndexStr |");
  }
}

