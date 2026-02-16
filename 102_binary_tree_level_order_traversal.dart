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
// 一層ずつlist を作って、それを全体のリストに加えればいいだけ。
// 幅優先探索で簡単にできる。
// 深さ優先探索でも、高さの情報を引き継いであげればできる。
// 今までの easy の問題とやること自体は一緒なのに、なぜ medium になっているのかが正直あまりわからなかった。

import "dart:collection";

// 幅優先探索
class Solution {
  List<List<int>> levelOrder(TreeNode? root) {
    var curLevelNodes = Queue<TreeNode?>.from([root]);
    var valuesByLevel = <List<int>>[];

    while (!curLevelNodes.isEmpty) {
      var nextLevelNodes = Queue<TreeNode?>();
      var nodeValues = <int>[];

      for (var node in curLevelNodes) {
        if (node == null) {
          continue;
        }

        nodeValues.add(node.val);
        nextLevelNodes.add(node.left);
        nextLevelNodes.add(node.right);
      }

      curLevelNodes = nextLevelNodes;

      if (!nodeValues.isEmpty) {
        valuesByLevel.add(nodeValues);
      }
    }

    return valuesByLevel;
  }
}

// 深さ優先探索
class Solution {
  List<List<int>> levelOrder(TreeNode? root) {
    var nodesWithLevel = List<(TreeNode?, int)>.from([(root, 0)]);
    var valuesByLevel = List<List<int>>.from([]);

    while (!nodesWithLevel.isEmpty) {
      final (node, level) = nodesWithLevel.removeLast();

      if (node == null) {
        continue;
      }

      while (valuesByLevel.length <= level) {
        valuesByLevel.add([]);
      }

      valuesByLevel[level].add(node.val);
      nodesWithLevel.add((node.right, level + 1));
      nodesWithLevel.add((node.left, level + 1));
    }

    return valuesByLevel;
  }
}

// Step 2:
// 他の人のコード、コメント集をみる

// https://github.com/nanae772/leetcode-arai60/pull/26/changes#diff-e54e08c4251bd51b112daef4301433dd2a027a83c8e870d50f6633c83299859eR1
// preorder の再帰。Iterative では書いたが、recursive でもで書いておく。
// ただ、recursive の場合は、前回意外と簡単にスタックオーバーフローになることがわかったので、
// 何も考えずに再帰で書くことに少し抵抗が出るようになってきた。iterative に書けて、可読性もあまり落ちないのであれば、iterative でいい気がする。
// Dart は再帰の方が少し早くなるため、速度の最適化を求める場合や、入力があまり大きくないことが確定している場合は、recursive でもいいかも。

// https://github.com/naoto-iwase/leetcode/pull/30/changes#diff-40c0807c5c71abb50c5c8ebe78ffc21551f9ab6d80ccd6a156c960d1febd1882R59
// > 実装1で、Noneチェックをキューから取り出すときにやる実装も書いてみる。
// > メリットはNoneチェックを1箇所で書けることや、root is Noneを特別扱いしなくて良い。
// > デメリットとしては、whileループが常に(深さ + 1)回ることや、それに伴う後処理が直感的でない（一種のパズルになっている）こと。
// > 個人的には実装1のが素直で好み、可読性も高いと感じる。
// 自分でも書いているときに、デメリットの後処理が結構可読性を下げそうだなと感じた。
// 今回は None チェックをキューに入れる段階でやる方が自然でいいかもしれない。

// 再帰
class Solution {
  List<List<int>> levelOrder(TreeNode? root) {
    var levelOrderValues = <List<int>>[];

    void helper(TreeNode? node, int level) {
      if (node == null) {
        return;
      }

      while (levelOrderValues.length <= level) {
        levelOrderValues.add([]);
      }

      levelOrderValues[level].add(node.val);
      helper(node.left, level + 1);
      helper(node.right, level + 1);
    }

    helper(root, 0);
    return levelOrderValues;
  }
}

// None チェックしてからキューに入れる。
class Solution {
  List<List<int>> levelOrder(TreeNode? root) {
    if (root == null) {
      return [];
    }

    var curLevelNodes = Queue<TreeNode>.from([root]);
    var levelOrderValues = <List<int>>[];

    while (!curLevelNodes.isEmpty) {
      var nextLevelNodes = Queue<TreeNode>();
      var nodeValues = <int>[];

      for (var node in curLevelNodes) {
        nodeValues.add(node.val);

        if (node.left != null) {
          nextLevelNodes.add(node.left!);
        }
        if (node.right != null) {
          nextLevelNodes.add(node.right!);
        }
      }

      levelOrderValues.add(nodeValues);
      curLevelNodes = nextLevelNodes;
    }

    return levelOrderValues;
  }
}

// Step 3
class Solution {
  List<List<int>> levelOrder(TreeNode? root) {
    if (root == null) {
      return [];
    }

    var curLevelNodes = Queue<TreeNode>.from([root]);
    var levelOrderValues = <List<int>>[];

    while (!curLevelNodes.isEmpty) {
      var nextLevelNodes = Queue<TreeNode>();
      var nodeValues = <int>[];

      for (var node in curLevelNodes) {
        nodeValues.add(node.val);

        if (node.left != null) {
          nextLevelNodes.add(node.left!);
        }
        if (node.right != null) {
          nextLevelNodes.add(node.right!);
        }
      }

      levelOrderValues.add(nodeValues);
      curLevelNodes = nextLevelNodes;
    }

    return levelOrderValues;
  }
}
