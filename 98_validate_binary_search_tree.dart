/**
 * Definition for a binary tree node.
 * class TreeNode {
 *   int val;
 *   TreeNode? left;
 *   TreeNode? right;
 *   TreeNode([this.val = 0, this.left, this.right]);
 * }
 */

// Step 1
//
// BST であるかどうかを確かめるには以下の条件を満たす必要がある。
// - 根ノードから見て、左側の木が BST かつ、その木の最大値が根ノードの値より小さい。
// - 根ノードから見て、右側の木が BST かつ、その木の最小値が根ノードの値より大きい。
// 部下に渡していく再帰的な発想でやるのであれば、これを繰り返せばいい。
class Solution {
  bool isValidBST(TreeNode? root) {
    ({bool isValid, int? min, int? max}) helper(TreeNode? node) {
      if (node == null) {
        return (isValid: true, min: null, max: null);
      }

      final left = helper(node.left);
      final right = helper(node.right);

      if (!left.isValid || !right.isValid) {
        return (isValid: false, min: null, max: null);
      }

      final isLeftSmaller = left.max == null || left.max! < node.val;
      final isRightLarger = right.min == null || node.val < right.min!;

      if (isLeftSmaller && isRightLarger) {
        final minValue = left.min ?? node.val;
        final maxValue = right.max ?? node.val;
        return (isValid: true, min: minValue, max: maxValue);
      }

      return (isValid: false, min: null, max: null);
    }

    return helper(root).isValid;
  }
}

// Step 2
// 他の人のコード・コメント集を読む
//
// https://github.com/akmhmgc/arai60/pull/24/changes#diff-12915c6bb1596db9039ea2c67b7b8642c14d4576238ddc9641cefeb689126859R51
// inorder で traverse して配列を取得してから、それが昇順になっているかを確認する方法。
// ものすごくシンプルで分かりやすい解法だが、全然気づかなかった。
// 配列にしなくてもできそう。

// https://github.com/naoto-iwase/leetcode/pull/33#discussion_r2479195403
// Iterative に書いたらこうなる。
// 今回は書く体力がないので、書くのはスキップ。

// https://github.com/mamo3gr/arai60/pull/26/changes#diff-76f9ae02b0354cd8190a5e54a28f2b1bf00fb51b71f4b488a3cf1ff63d032f9bR10
// top-down なアプローチ確かにシンプルで分かりやすい。

// inorder で順に見ていき、値が大きくなっているかを確認する
class Solution {
  bool isValidBST(TreeNode? root) {
    num previousValue = double.negativeInfinity;

    bool isValidBSTInorderTraverse(TreeNode? node) {
      if (node == null) {
        return true;
      }

      if (!isValidBSTInorderTraverse(node.left)) {
        return false;
      }

      if (node.val <= previousValue) {
        return false;
      }
      previousValue = node.val;

      return isValidBSTInorderTraverse(node.right);
    }

    return isValidBSTInorderTraverse(root);
  }
}

// top-down
class Solution {
  bool isValidBST(TreeNode? root) {
    if (root == null) {
      return true;
    }

    var nodesWithLimits = <(TreeNode, num, num)>[
      (root, double.negativeInfinity, double.infinity),
    ];

    while (!nodesWithLimits.isEmpty) {
      final (node, minLimit, maxLimit) = nodesWithLimits.removeLast();

      if (node.val <= minLimit || maxLimit <= node.val) {
        return false;
      }

      if (node.left != null) {
        nodesWithLimits.add((node.left!, minLimit, node.val));
      }
      if (node.right != null) {
        nodesWithLimits.add((node.right!, node.val, maxLimit));
      }
    }

    return true;
  }
}

class Solution {
  bool isValidBST(TreeNode? root) {
    bool helper(TreeNode? node, num min, num max) {
      if (node == null) {
        return true;
      }

      final isLarger = min < node.val;
      final isSmaller = node.val < max;

      if (!isLarger || !isSmaller) {
        return false;
      }

      return helper(node.left, min, node.val) &&
          helper(node.right, node.val, max);
    }

    return helper(root, double.negativeInfinity, double.infinity);
  }
}

// Step 3
class Solution {
  bool isValidBST(TreeNode? root) {
    if (root == null) {
      return true;
    }

    var nodesWithLimits = <(TreeNode, num, num)>[
      (root, double.negativeInfinity, double.infinity),
    ];

    while (!nodesWithLimits.isEmpty) {
      final (node, minLimit, maxLimit) = nodesWithLimits.removeLast();

      if (node.val <= minLimit || maxLimit <= node.val) {
        return false;
      }

      if (node.left != null) {
        nodesWithLimits.add((node.left!, minLimit, node.val));
      }
      if (node.right != null) {
        nodesWithLimits.add((node.right!, node.val, maxLimit));
      }
    }

    return true;
  }
}
