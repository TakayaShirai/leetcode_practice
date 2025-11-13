/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     public var val: Int
 *     public var next: ListNode?
 *     public init() { self.val = 0; self.next = nil; }
 *     public init(_ val: Int) { self.val = val; self.next = nil; }
 *     public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
 * }
 */

// Step 1:
// 与えられるリストはすでにソートされていることを前提として解く。
// 以下のフローを、最初のノードから行うことでできる。
//   1. 次のノードと値が同じかどうかを比較する
//     - 値が同じである場合、一つ前のノードの位置を覚えておいて、値が異なるノードになるまで移動する。
//     - 覚えておいたノードの次のノードとして、値が異なるノードを設定する
//   2. 次のノードに移動する
//
// 最初のノードで重複が見つかった場合には、一つ前のノードがないため、ダミーのノードを用意する必要がある。

class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    let dummyHead = ListNode(0)
    var lastConfirmed: ListNode = dummyHead
    var nodeToCheck: ListNode? = head

    while let node = nodeToCheck {
      if let next = node.next, node.val == next.val {
        var weakChecking: ListNode? = next.next
        while let checking = weakChecking, node.val == checking.val {
          weakChecking = checking.next
        }

        nodeToCheck = weakChecking
      } else {
        lastConfirmed.next = node
        lastConfirmed = node
        nodeToCheck = node.next
        lastConfirmed.next = nil
      }
    }

    return dummyHead.next
  }
}

// Step 2:
// 弱参照という意味で、weak をおいてみたがわかりづらい気がするため、deleteCandidate という命名に変更

class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    let dummyHead = ListNode(0)
    var lastConfirmed: ListNode = dummyHead
    var nodeToCheck: ListNode? = head

    while let node = nodeToCheck {
      if let next = node.next, node.val == next.val {
        var deleteCandidate: ListNode? = next.next

        while let candidate = deleteCandidate, node.val == candidate.val {
          deleteCandidate = candidate.next
        }

        nodeToCheck = deleteCandidate
      } else {
        lastConfirmed.next = node
        lastConfirmed = node
        nodeToCheck = node.next
        lastConfirmed.next = nil
      }
    }

    return dummyHead.next
  }
}

// Step 3:
class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    let dummyHead = ListNode(0)
    var lastConfirmed: ListNode = dummyHead
    var nodeToCheck: ListNode? = head

    while let node = nodeToCheck {
      if let next = node.next, node.val == next.val {
        var deleteCandidate: ListNode? = next.next

        while let candidate = deleteCandidate, node.val == candidate.val {
          deleteCandidate = candidate.next
        }

        nodeToCheck = deleteCandidate
      } else {
        lastConfirmed.next = node
        lastConfirmed = node
        nodeToCheck = node.next
        lastConfirmed.next = nil
      }
    }

    return dummyHead.next
  }
}
