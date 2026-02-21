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
// 手作業でやる場合を考える。
// とりあえず、末端のノードまでいく道を全て調べて、最も深かった道の長さを返すだけ。
// 深さ優先探索でやればいい。
// 幅優先探索でもできるけど、個人的に直感的なのは深さ優先探索。
// 計算量は、O(N)で全部のノードを回る必要がある。最大数は 10^4 らしく、Dart はだいたい 10^4 steps/ms なので、1ms ぐらいで終わる。

import "dart:collection";

class Solution {
  int maxDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    var maxDepth = 1;
    var nodesWithDepths = [(root, 1)];

    while (!nodesWithDepths.isEmpty) {
      var (node, depth) = nodesWithDepths.removeLast();
      maxDepth = max(depth, maxDepth);

      if (node.left != null) {
        nodesWithDepths.add((node.left!, depth + 1));
      }

      if (node.right != null) {
        nodesWithDepths.add((node.right!, depth + 1));
      }
    }

    return maxDepth;
  }
}

// 再帰で書く。
class Solution {
  int maxDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    final leftTreeDepth = maxDepth(root.left);
    final rightTreeDepth = maxDepth(root.right);

    return 1 + max(leftTreeDepth, rightTreeDepth);
  }
}

class Solution {
  int maxDepth(TreeNode? root) {
    int maxDepthHelper(TreeNode? node, int previousDepth) {
      if (node == null) {
        return previousDepth;
      }

      return max(
        maxDepthHelper(node.left, previousDepth + 1),
        maxDepthHelper(node.right, previousDepth + 1),
      );
    }

    return maxDepthHelper(root, 0);
  }
}

// 一応幅優先探索もかく。
class Solution {
  int maxDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    var depth = 0;
    var sameLevelNodes = Queue<TreeNode>.from([root]);

    while (!sameLevelNodes.isEmpty) {
      final nodesCount = sameLevelNodes.length;
      var nextLevelNodes = Queue<TreeNode>();

      for (var i = 0; i < nodesCount; i++) {
        var node = sameLevelNodes.removeFirst();

        if (node.left != null) {
          nextLevelNodes.add(node.left!);
        }

        if (node.right != null) {
          nextLevelNodes.add(node.right!);
        }
      }

      depth++;
      sameLevelNodes = nextLevelNodes;
    }

    return depth;
  }
}

// Step 2:
// コメント集、他の人のコードも読む。
//
// https://github.com/naoto-iwase/leetcode/pull/20/changes#diff-4888d90f21aa6972ed6808284b2125b5a2c17a69b8e80975819c489b26a80330R29
// node の追加を関数で切り分けることで、メインの流れをスッキリさせていて良かった。
// 幅優先探索の場合、自分は for 文の回数をnode の数から決めて回していたが、
// nextLevelNodes を分けているなら、 確かに for (var node in sameLevelNodes) みたいな形で書いても良い。
//
// どのコメントだったかを見失ってしまったが、
// ノードが null かどうかを確認してから、Queue, Stack に入れるのではなく、確認せずに入れて、後で処理をする際に null の確認をする方針もある。
// 後者の方がコードとしてはスッキリしそう。
//

// スタックの解法（null の確認を後でやる）
class Solution {
  int maxDepth(TreeNode? root) {
    var maxDepth = 0;
    var nodesWithDepths = [(root, 1)];

    while (!nodesWithDepths.isEmpty) {
      var (node, depth) = nodesWithDepths.removeLast();

      if (node == null) {
        continue;
      }

      maxDepth = max(depth, maxDepth);
      nodesWithDepths.add((node.left, depth + 1));
      nodesWithDepths.add((node.right, depth + 1));
    }

    return maxDepth;
  }
}

// もしくは、関数で切り分ける。（色々な書き方を試すために、幅優先探索でかく。）
// 書いて思ったが、これだけのために関数に切り出すのは大袈裟な気もした。
// 単純に null でも Queue に入れてしまって、後から null チェックしてもいい。
class Solution {
  int maxDepth(TreeNode? root) {
    void addNodesIfExist(TreeNode? node, Queue<TreeNode?> nodes) {
      if (node != null) {
        nodes.add(node);
      }
    }

    if (root == null) {
      return 0;
    }

    var depth = 0;
    var sameLevelNodes = Queue<TreeNode>.from([root]);

    while (!sameLevelNodes.isEmpty) {
      var nextLevelNodes = Queue<TreeNode>();

      for (var node in sameLevelNodes) {
        addNodesIfExist(node?.left, nextLevelNodes);
        addNodesIfExist(node?.right, nextLevelNodes);
      }

      depth++;
      sameLevelNodes = nextLevelNodes;
    }

    return depth;
  }
}

// null でも Queue に入れてしまって、後から null チェックをする方法。
class Solution {
  int maxDepth(TreeNode? root) {
    var sameLevelNodes = Queue<TreeNode?>.from([root]);
    var depth = 0;

    while (!sameLevelNodes.isEmpty) {
      var nextLevelNodes = Queue<TreeNode?>();

      for (var node in sameLevelNodes) {
        if (node == null) {
          continue;
        }

        nextLevelNodes.add(node.left);
        nextLevelNodes.add(node.right);
      }

      if (nextLevelNodes.isEmpty) {
        break;
      }

      depth++;
      sameLevelNodes = nextLevelNodes;
    }

    return depth;
  }
}

// Step 3:
// DFS の再帰が一番しっくりくるので、それで書く。
class Solution {
  int maxDepth(TreeNode? root) {
    if (root == null) {
      return 0;
    }

    final leftTreeDepth = maxDepth(root.left);
    final rightTreeDepth = maxDepth(root.right);

    return 1 + max(leftTreeDepth, rightTreeDepth);
  }
}
