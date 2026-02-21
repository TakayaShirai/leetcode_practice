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
// うーん、とっかかりが難しい。
// わかっていることを挙げてみる。
// - preorder の最初の要素が root.
// - preorder の最初の要素で、inorder の左右の木は分けられる。
// なんかこれで再帰でいけそうな気がするな。
// 1. preorder で root を取得
// 2. inorder をその root で分離
// 3. preorder もどうにかして、左右に分離
// 4. 左右用の、preorder と inorder の配列を再度構築
// 5. root に左右で同じ処理をしたやつをくっつける。
// 6. root を返す。

// 問題は、
// - preorder の左右の分離方法は何か。
// - 左右に分離しただけで、その後も、preorder, inorder になっているか。
// これらが分かれば、再帰で書ける。
// preorder の左右の分離法について
// - preorder の左右の分離は、左の木のノードの個数が分かれば、その分だけ添字を増やせば、右の木の root にたどり着く。
// - 左の木の数が 1 なら、root と 左の木の数を合わせて２個なので、配列の三番目に右のroot がある。
// - 左の木の数は、inorder で分けた時の、root より左の数だからすぐわかる。これで分離はできる。
// では、左右に分離しただけで、その後も、preorder, inorder になっているか。
// - これはなっているはず。ずっと再帰で回せるということは、どこでも同じ処理をしているということ。
// - 途中で切っても、inorder, preorder になっているはず。

// てことで、まとめるとどうなるか
// 1. preorder の最初の要素で、root を確定。
// 2. root を元に、inorder でも root の位置を特定。
// 3. root を境に、inorder の配列を左右の木で分離。
// 4. root より左側の要素数で、左側の木の数を特定。
// 5. preorder も、一つ前のステップで確認した左側の木の数を用いて、左右に分離
// 6. 二人の部下に、左の木の preorder, inorder, 右の木の preorder, inorder を渡す。
// 7. 返ってきた木を、自分の root の左右にくっつける。
// 8. 完成。
// って感じか。問題をどんどんシンプルに言い換えていくと、案外最初分からなくてもいける。

// 書いた後に気づいたが、これはノードの値が全て異なるという条件を元にできる手法。
// 同じ値があると root を見つけるときに、違うものを root と判定する可能性がある。
class Solution {
  TreeNode? buildTree(List<int> preorder, List<int> inorder) {
    if (preorder.length != inorder.length) {
      throw Exception('preorder and inorder have different lengths.');
    }

    if (preorder.isEmpty || inorder.isEmpty) {
      return null;
    }

    final rootValue = preorder[0];
    final root = TreeNode(rootValue);
    var rootIndex = 0;

    for (var i = 0; i < inorder.length; i++) {
      if (inorder[i] == rootValue) {
        rootIndex = i;
        break;
      }
    }

    final leftNodesCount = rootIndex;

    final leftTree = buildTree(
      preorder.sublist(1, leftNodesCount + 1),
      inorder.sublist(0, rootIndex),
    );
    final rightTree = buildTree(
      preorder.sublist(leftNodesCount + 1),
      inorder.sublist(rootIndex + 1),
    );

    root.left = leftTree;
    root.right = rightTree;

    return root;
  }
}

// Step 2
// とりあえず、Step 1 でざっと書いたやつを綺麗にする。
class Solution {
  TreeNode? buildTree(List<int> preorder, List<int> inorder) {
    int pickInorderRootIndex(List<int> inorder, int rootValue) {
      var rootIndex = 0;

      for (var i = 0; i < inorder.length; i++) {
        if (inorder[i] == rootValue) {
          return i;
        }
      }

      throw Exception('inorder does not have the given rootValue.');
    }

    if (preorder.length != inorder.length) {
      throw Exception('preorder and inorder have different lengths.');
    }

    if (preorder.isEmpty || inorder.isEmpty) {
      return null;
    }

    final root = TreeNode(preorder[0]);
    final rootIndex = pickInorderRootIndex(inorder, preorder[0]);
    final leftNodesCount = rootIndex;

    final leftTree = buildTree(
      preorder.sublist(1, leftNodesCount + 1),
      inorder.sublist(0, rootIndex),
    );
    final rightTree = buildTree(
      preorder.sublist(leftNodesCount + 1),
      inorder.sublist(rootIndex + 1),
    );

    root.left = leftTree;
    root.right = rightTree;

    return root;
  }
}

// top down も書いてみる。
class Solution {
  TreeNode? buildTree(List<int> preorder, List<int> inorder) {
    int pickInorderRootIndex(List<int> inorder, int rootValue) {
      var rootIndex = 0;

      for (var i = 0; i < inorder.length; i++) {
        if (inorder[i] == rootValue) {
          return i;
        }
      }

      throw Exception('inorder does not have the given rootValue.');
    }

    if (preorder.length != inorder.length) {
      throw Exception('preorder and inorder have different lengths.');
    }

    if (preorder.isEmpty || inorder.isEmpty) {
      return null;
    }

    final root = TreeNode(preorder[0]);
    var rootWithValues = <(TreeNode, List<int>, List<int>)>[
      (root, preorder, inorder),
    ];

    while (!rootWithValues.isEmpty) {
      final (node, preorderValues, inorderValues) = rootWithValues.removeLast();

      final rootIndex = pickInorderRootIndex(inorderValues, preorderValues[0]);
      final leftTreeNodesCount = rootIndex;

      final leftInorder = inorderValues.sublist(0, rootIndex);
      final leftPreorder = preorderValues.sublist(1, leftTreeNodesCount + 1);
      if (!leftPreorder.isEmpty) {
        node.left = TreeNode(leftPreorder[0]);
        rootWithValues.add((node.left!, leftPreorder, leftInorder));
      }

      final rightInorder = inorderValues.sublist(rootIndex + 1);
      final rightPreorder = preorderValues.sublist(leftTreeNodesCount + 1);
      if (rightPreorder.isNotEmpty) {
        node.right = TreeNode(rightPreorder[0]);
        rootWithValues.add((node.right!, rightPreorder, rightInorder));
      }
    }

    return root;
  }
}

// 他の人のコード・コメント集を読む。
// https://github.com/nanae772/leetcode-arai60/pull/29/changes#diff-e3979ba28fc9231b5cd059f74aa1b5c1f4068b08eba40d941242242972da445fR1
// 辞書を使うことで、いちいち for 文回さなくても、inorder の root の位置を特定できる。
// preorder の　root の動かし方がパズル的になっていて、その変数名も抽象的で少し読みづらい部分もあった。
// step 3 では、変数名がはっきりして少し読みやすくなった。

// https://github.com/naoto-iwase/leetcode/pull/34/changes#diff-86a988a9907513dbac3de48f76153f817d379538d53ad5fd334ebef6b0276052R95
// 解法自体が難しいなと感じた。inorder の特性と preorder の特性を十分に理解している必要があると感じる。
// まあ、自分が上で書いた解法もinorder の特性と preorder の特性を十分に理解している必要があるか。

// https://github.com/mamo3gr/arai60/pull/28/changes#diff-4298635e808820604d74d3c43a2bcce0a2e36a9627af25d32462a8c12e01beeaR8
// 解き方が一緒。

// Step 3
class Solution {
  TreeNode? buildTree(List<int> preorder, List<int> inorder) {
    int pickInorderRootIndex(List<int> inorder, int rootValue) {
      var rootIndex = 0;

      for (var i = 0; i < inorder.length; i++) {
        if (inorder[i] == rootValue) {
          return i;
        }
      }

      throw Exception('inorder does not have the given rootValue.');
    }

    if (preorder.length != inorder.length) {
      throw Exception('preorder and inorder have different lengths.');
    }

    if (preorder.isEmpty || inorder.isEmpty) {
      return null;
    }

    final root = TreeNode(preorder[0]);
    final rootIndex = pickInorderRootIndex(inorder, preorder[0]);
    final leftNodesCount = rootIndex;

    root.left = buildTree(
      preorder.sublist(1, leftNodesCount + 1),
      inorder.sublist(0, rootIndex),
    );
    root.right = buildTree(
      preorder.sublist(leftNodesCount + 1),
      inorder.sublist(rootIndex + 1),
    );

    return root;
  }
}
