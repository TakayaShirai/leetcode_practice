/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     public var val: Int
 *     public var next: ListNode?
 *     public init() { self.val = 0; self.next = nil; }
 *     public init(_ val: Int) { self.val = val; self.next = nil; }
 *     public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
 * }
**/

// Step 1:
// 入力はすでにソートしてある状態だとして（問題の条件設定から）、訪れたノードの値を Set で記録しておいて、
// 各ノードを訪れた際に、Set 内にすでにノードの値があるかを確認する。
//   - ある場合、一つ前のノードの next のポインタを、一つ次のノードにする。
//   - ない場合、そのまま処理を続ける。
// をやれば、問題でやりたい内容はできるはず。
// Set のためのメモリで必要なのは、出てくる値の種類の数だけ必要だけど、Int で大きくて 8 byte。
// 仮に100万種類きても理論的には、 1M * 8 = 8 MB. オーバーヘッドがあっても、問題なさそう。

class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var seenValues = Set<Int>()
    seenValues.insert(head.val)

    var previousNode: ListNode = head
    var nodeToCheckDuplicates: ListNode? = head.next

    while let node = nodeToCheckDuplicates {
      // Swift では、guard を使用すると強制的に early exits をさせることが可能。(early exits がない場合は、compile error になる)
      // Ref: https://google.github.io/swift/#guards-for-early-exits
      // 値が重複している場合と重複していない場合とで行う操作が異なるため、確実に操作が分かれるようにするために guard を使用した。
      // ただ、if-else で書いた方が直感的な分岐にはなるため、認知的負荷は if-else の方が少なそう。
      guard !seenValues.contains(node.val) else {
        previousNode.next = node.next
        nodeToCheckDuplicates = node.next
        continue
      }

      seenValues.insert(node.val)
      previousNode = node
      nodeToCheckDuplicates = node.next
    }

    return head
  }
}

// Step 2:
// ソートされてるなら、Set なしで前後の値だけ見ればいいことに気づき、Set を用いない手法に変更
class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var previousNode: ListNode = head
    var nodeToCheckDuplicates: ListNode? = head.next

    while let node = nodeToCheckDuplicates {
      if previousNode.val == node.val {
        previousNode.next = node.next
      } else {
        previousNode = node
      }

      nodeToCheckDuplicates = node.next
    }

    return head
  }
}

// Step 3:
// 他の人の解法を見て、値が重複している限りはループを続けて最後に値が異なるノードと最後のノードを繋げる手法を確認したため、そちらも書いてみた。
// 書き込みを減らせるが、減らせる書き込みの回数は連結リストの長さよりはそもそも大きくならないから、たいした違いにはならないはず。
// L1 ~ L3キャッシュ で全ておさまるのであれば、問題で与えられたノードの個数 300 個以下なら ns 単位の違いでおさまりそう。(計測したら μs 単位の違いでした)
// Ref: https://gist.github.com/jboner/2841832

class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var previousNode: ListNode = head
    var nodeToCheckDuplicates: ListNode? = head.next

    while let node = nodeToCheckDuplicates {
      if previousNode.val == node.val {
        previousNode.next = node.next
      } else {
        previousNode = node
      }

      nodeToCheckDuplicates = node.next
    }

    return head
  }
}

class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var node: ListNode? = head

    while let nodeToKeep = node, nodeToKeep.next != nil {
      var forward = nodeToKeep.next

      while let checkingNode = forward, nodeToKeep.val == checkingNode.val {
        forward = checkingNode.next
      }

      nodeToKeep.next = forward
      node = forward
    }

    return head
  }
}
