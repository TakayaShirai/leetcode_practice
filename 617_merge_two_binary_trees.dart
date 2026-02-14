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
// 手作業でやる場合を考える。もしくは、別の問題に言い換える。
//
// 一番シンプルに思いつくのは、部下二人に、左の木と右の木をそれぞれ二つずつ渡して、マージしたものを返してもらう。
// 自分は、自分の手元にあるノード二つの値を足して、そのノードに返ってきた二つの木をくっつけて終わりにする。
//
// もしくは、手作業のイメージはあまりないけど、幅優先探索でやる方法。
// null の場合でも、null をキューに入れるようにして、null, null の場合は、ノードなし
// null, ノードありの場合は、そのノードをそのままつける。
// ただ、前の層のノードを保持しておく必要があるから、面倒か。

import "dart:collection";

// 部下二人に分けていく方法
class Solution {
  TreeNode? mergeTrees(TreeNode? root1, TreeNode? root2) {
    if (root1 == null && root2 == null) {
      return null;
    }

    final root1Value = root1?.val ?? 0;
    final root2Value = root2?.val ?? 0;

    final newRoot = TreeNode(root1Value + root2Value);

    final mergedLeftTree = mergeTrees(root1?.left, root2?.left);
    final mergedRightTree = mergeTrees(root1?.right, root2?.right);

    newRoot.left = mergedLeftTree;
    newRoot.right = mergedRightTree;

    return newRoot;
  }
}

// 幅優先探索
// 何も考えずにベタガキで書いていしまったが、null もキューに入れるため、指数関数的にキューに入るノード数が増加。
// 当たり前だが、Out of Memory になってしまった。
// そして、コードに冗長な部分が多い。
// とりあえず、step 2 に移る。
class Solution {
  TreeNode? mergeNodes(TreeNode? node1, TreeNode? node2) {
    if (node1 == null && node2 == null) {
      return null;
    }

    final node1Value = node1?.val ?? 0;
    final node2Value = node2?.val ?? 0;

    return TreeNode(node1Value + node2Value);
  }

  TreeNode? mergeTrees(TreeNode? root1, TreeNode? root2) {
    if (root1 == null && root2 == null) {
      return null;
    }

    final newRoot = mergeNodes(root1, root2);

    var parentNodes = Queue<TreeNode?>.from([newRoot]);
    var sameLevelNodes1 = Queue<TreeNode?>.from([root1?.left, root1?.right]);
    var sameLevelNodes2 = Queue<TreeNode?>.from([root2?.left, root2?.right]);

    while (true) {
      final sameLevelNodesCount = sameLevelNodes1.length;

      var nextLevelNodes1 = Queue<TreeNode?>();
      var nextLevelNodes2 = Queue<TreeNode?>();

      for (var i = 0; i < (sameLevelNodesCount / 2); i++) {
        final leftNode1 = sameLevelNodes1.removeFirst();
        final rightNode1 = sameLevelNodes1.removeFirst();

        final leftNode2 = sameLevelNodes2.removeFirst();
        final rightNode2 = sameLevelNodes2.removeFirst();

        final parentNode = parentNodes.removeFirst();

        final newLeftNode = mergeNodes(leftNode1, leftNode2);
        final newRightNode = mergeNodes(rightNode1, rightNode2);

        nextLevelNodes1.add(leftNode1?.left);
        nextLevelNodes1.add(leftNode1?.right);
        nextLevelNodes1.add(rightNode1?.left);
        nextLevelNodes1.add(rightNode1?.right);

        nextLevelNodes2.add(leftNode2?.left);
        nextLevelNodes2.add(leftNode2?.right);
        nextLevelNodes2.add(rightNode2?.left);
        nextLevelNodes2.add(rightNode2?.right);

        parentNode?.left = newLeftNode;
        parentNode?.right = newRightNode;

        parentNodes.add(newLeftNode);
        parentNodes.add(newRightNode);
      }

      sameLevelNodes1 = nextLevelNodes1;
      sameLevelNodes2 = nextLevelNodes2;

      var existNonNullParent = false;

      for (var node in parentNodes) {
        if (node != null) {
          existNonNullParent = true;
        }
      }

      if (!existNonNullParent) {
        break;
      }
    }

    return newRoot;
  }
}

// Step 2：
// 他の人のコード・コメント集を読む。
//
// 再帰はどの人も読みやすいが、スタックを使った瞬間に、親と子の関係を知るための何かしらの工夫が持ち込まれるため、やはり多少の読みにくさを感じる。
// コードからそのロジックを類推する必要がある。
//
// https://github.com/naoto-iwase/leetcode/pull/22/changes#diff-71b591f216a80cf7ef1191bcc4e28df72fa47886531875cc18826914b5870065R94
// https://github.com/mamo3gr/arai60/pull/22/changes#diff-b0b7863f74ef869bf3ace46cd4597e72bc47300998299950826c7f7cb8bb8e11R10
// 基本的には、(親ノード、ノード１、ノード２)をキューに入れておいて、親にくっつける左右の子ノードを、ノード１、ノード２から作成。
// もし、左右の子ノードが存在するなら、それを親、ノード１、ノード２の子ノードを新たなノード１、ノード２としてキューに入れる。
// これを繰り返すといった感じ。最初に書いた再帰とイメージは似ている。
// なるべく意味が伝わるように変数を考えた。
//
class Solution {
  TreeNode? mergeNodes(TreeNode? node1, TreeNode? node2) {
    if (node1 == null && node2 == null) {
      return null;
    }

    final node1Value = node1?.val ?? 0;
    final node2Value = node2?.val ?? 0;

    return TreeNode(node1Value + node2Value);
  }

  TreeNode? mergeTrees(TreeNode? root1, TreeNode? root2) {
    if (root1 == null && root2 == null) {
      return null;
    }

    final mergedRoot = mergeNodes(root1, root2);
    var mergeSourcesWithParent = Queue<(TreeNode?, TreeNode?, TreeNode)>.from([
      (root1, root2, mergedRoot),
    ]);

    while (!mergeSourcesWithParent.isEmpty) {
      final (source1, source2, parent) = mergeSourcesWithParent.removeFirst();

      final mergedLeft = mergeNodes(source1?.left, source2?.left);
      final mergedRight = mergeNodes(source1?.right, source2?.right);

      parent.left = mergedLeft;
      parent.right = mergedRight;

      if (mergedLeft != null) {
        mergeSourcesWithParent.add((source1?.left, source2?.left, mergedLeft));
      }

      if (mergedRight != null) {
        mergeSourcesWithParent.add((
          source1?.right,
          source2?.right,
          mergedRight,
        ));
      }
    }

    return mergedRoot;
  }
}

// Step 3:
class Solution {
  TreeNode? mergeTrees(TreeNode? root1, TreeNode? root2) {
    if (root1 == null && root2 == null) {
      return null;
    }

    final root1Value = root1?.val ?? 0;
    final root2Value = root2?.val ?? 0;

    final newRoot = TreeNode(root1Value + root2Value);

    final leftMergedTree = mergeTrees(root1?.left, root2?.left);
    final rightMergedTree = mergeTrees(root1?.right, root2?.right);

    newRoot.left = leftMergedTree;
    newRoot.right = rightMergedTree;

    return newRoot;
  }
}
