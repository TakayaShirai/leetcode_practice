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
//
// パッと考えつくのは、すべてのルートを通って、葉ノードに辿りついた時に深さの最小値を更新する方法と
// 一層ずつ降りていって、葉ノードが出てきた時の深さをその場で返してしまう方法。
// 後者の方が、例えば片方だけかなり長いノードの場合に有利であるため、後者を選ぶ。
// 幅優先探索を行えば良い。
import "dart:collection";

class Solution {
  int minDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    var sameLevelNodes = Queue<TreeNode?>.from([root]);
    var depth = 1;

    while (!sameLevelNodes.isEmpty) {
      var nextLevelNodes = Queue<TreeNode?>();

      for (var node in sameLevelNodes) {
        if (node == null) {
          continue;
        }

        if (node.left == null && node.right == null) {
          return depth;
        }

        nextLevelNodes.add(node.left);
        nextLevelNodes.add(node.right);
      }

      depth++;
      sameLevelNodes = nextLevelNodes;
    }

    throw StateError(
      'Unexpected state: Tree traversal ended without finding a leaf node.',
    );
  }
}

// 深さ優先探索でも書いておく。
// 下を最初に書いて、片側にすべてのノードがあるケースを考えられておらず、Wrong Answer.
class Solution {
  int minDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    var leftTreeMinDepth = minDepth(root.left);
    var rightTreeMinDepth = minDepth(root.right);

    return min(leftTreeMinDepth, rightTreeMinDepth) + 1;
  }
}

// そのケースにどう対処するかで悩んだ。
// 単純に考えるのであれば、両方深さが　0 の場合は、0を選んで良い。
// 片方のみ深さが 0 の場合は、0 でない方を選ぶ。
// もう少しいいやり方がありそうだが、とりあえず次に進む。
class Solution {
  int minDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    var leftTreeMinDepth = minDepth(root.left);
    var rightTreeMinDepth = minDepth(root.right);

    if (leftTreeMinDepth == 0 && rightTreeMinDepth == 0) {
      return 1;
    } else if (leftTreeMinDepth == 0 || rightTreeMinDepth == 0) {
      return max(leftTreeMinDepth, rightTreeMinDepth) + 1;
    }

    return min(leftTreeMinDepth, rightTreeMinDepth) + 1;
  }
}

// Step 2
// 他の人のコード、コメント集を読む
//
// https://github.com/nanae772/leetcode-arai60/pull/22/changes#diff-497439c56602d18f31e788b6709fdbee9bfbd684cb546d266217561980ce99c7R9
// > if root.left is not None:
// >     min_depth = min(min_depth, self.minDepth(root.left) + 1)
// > if root.right is not None:
// >     min_depth = min(min_depth, self.minDepth(root.right) + 1)
// 深さで判断するのではなくて、root.left が null などで条件文を書く方法。こちらの方が意図が通りやすいと感じる。

// https://github.com/mamo3gr/arai60/pull/20/changes#diff-9eb4930f4da2d91034d920481ed8541eadf84051f4bf6bfec14f60f742f90ae4R51
// 二分木ではない場合でも対応できる、拡張性の高い書き方。勉強になる。

// 上記二つの方法で書いてみる。
// 条件文をの書き方を変更
class Solution {
  int minDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    if (root.left == null) {
      return minDepth(root.right) + 1;
    } else if (root.right == null) {
      return minDepth(root.left) + 1;
    }

    return min(minDepth(root.left), minDepth(root.right)) + 1;
  }
}

// 拡張性の高い書き方
// Dart で書くと長くなることがわかった。そして、Stack Overflow になる。
// calcMin を関数に切り出さない、クロージャーで書くのをやめるなどをしてみたが、依然 Stack Overflow のままだった。
// for 文や変数の宣言が原因そう。正直、明確な原因がわからなかった。
class Solution {
  int calcMin(List<int> nums) {
    if (nums.isEmpty) {
      throw ArgumentError('The list of numbers must not be empty.');
    }

    var minimum = nums[0];

    for (var num in nums) {
      minimum = min(minimum, num);
    }

    return minimum;
  }

  int minDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    final children = [root.left, root.right].whereType<TreeNode>();

    if (children.isEmpty) {
      return 1;
    }

    var childDepths = <int>[];

    for (var child in children) {
      childDepths.add(minDepth(child));
    }

    return calcMin(childDepths) + 1;
  }
}

// Step 3
// 今回は、幅優先探索が一番しっくりくるので、それで書く。
class Solution {
  int minDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    var sameLevelNodes = Queue<TreeNode?>.from([root]);
    var depth = 1;

    while (!sameLevelNodes.isEmpty) {
      var nextLevelNodes = Queue<TreeNode?>();

      for (var node in sameLevelNodes) {
        if (node == null) {
          continue;
        }

        if (node.left == null && node.right == null) {
          return depth;
        }

        nextLevelNodes.add(node.left);
        nextLevelNodes.add(node.right);
      }

      depth++;
      sameLevelNodes = nextLevelNodes;
    }

    throw StateError(
      'Unexpected state: Tree traversal ended without finding a leaf node.',
    );
  }
}
