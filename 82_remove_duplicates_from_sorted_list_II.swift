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

// Step 4:
// ループの中の不変条件として、以下を意識して書いてみた。
//   - 数字を取り除く必要がある場合は、取り除く作業は一度に全て完了させる。
//   - 重複がないことが確定したデータについても、その時点では全て更新されている状態にする。
// なるべくネストが深くならないようにした。
// また while 文内で early return を入れることで、認知負荷を下げることをねらった。

class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    let dummyHead = ListNode(0)
    var lastConfirmed: ListNode = dummyHead
    var node = head

    while node != nil {
      guard node!.next != nil && node!.val == node!.next!.val else {
        lastConfirmed.next = node
        lastConfirmed = node!
        node = node!.next
        lastConfirmed.next = nil
        continue
      }

      let valueToRemove = node!.val
      while node != nil && node!.val == valueToRemove {
        node = node!.next
      }
    }

    return dummyHead.next
  }
}

// dummyHead を使用しない方法を書いてみた。
// 上の解答と比べて、重複を削除しない場合のコードのほうが複雑になったため、early return する条件を変えてみた。
// 認知負荷をなるべく減らすため。
class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var firstConfirmed: ListNode? = nil
    var lastConfirmed: ListNode? = nil
    var node = head

    while node != nil {
      guard node!.next == nil || node!.val != node!.next!.val else {
        let valueToRemove = node!.val
        while node != nil && node!.val == valueToRemove {
          node = node!.next
        }
        continue
      }

      if firstConfirmed == nil {
        firstConfirmed = node
        lastConfirmed = node
      } else {
        lastConfirmed!.next = node
        lastConfirmed = node!
      }

      node = node!.next
      lastConfirmed!.next = nil
    }

    return firstConfirmed
  }
}

// Step 5:
// force-unwrapping 多用は確かに保守性・可読性の観点からよくなかった。
// force-unwrapping を使用しないできちんと書き直す。
class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    let dummyHead = ListNode(0)
    var lastConfirmed: ListNode = dummyHead
    var nodeToCheck: ListNode? = head

    while let node = nodeToCheck {
      guard let next = node.next, node.val == next.val else {
        lastConfirmed.next = node
        lastConfirmed = node
        nodeToCheck = node.next
        lastConfirmed.next = nil
        continue
      }

      let valueToRemove = node.val
      var removeCandidate: ListNode? = node
      while let candidate = removeCandidate, candidate.val == valueToRemove {
        removeCandidate = candidate.next
      }
      nodeToCheck = removeCandidate
    }

    return dummyHead.next
  }
}

// dummyHead を使わない手法の書き直し。
class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    func skipDuplicates(_ node: ListNode?) -> ListNode? {
      guard let node else { return nil }
      guard let next = node.next, node.val == next.val else {
        return node
      }

      let valueToRemove = node.val
      var removeCandidate: ListNode? = node
      while let candidate = removeCandidate, candidate.val == valueToRemove {
        removeCandidate = candidate.next
      }

      return skipDuplicates(removeCandidate)
    }

    guard let firstConfirmed = skipDuplicates(head) else { return nil }

    var lastConfirmed: ListNode = firstConfirmed
    var nodeToCheck: ListNode? = firstConfirmed.next
    firstConfirmed.next = nil
    lastConfirmed.next = nil

    while let node = skipDuplicates(nodeToCheck) {
      lastConfirmed.next = node
      lastConfirmed = node
      nodeToCheck = node.next
      lastConfirmed.next = nil
    }

    return firstConfirmed
  }
}

// skipDuplicates を外部に出してみた。skipDuplicates のテストがしやすかったり、
// 責務の分離、再利用性に優れていると感じるため、個人的にはこちらのほうが好み。
// ただ、deleteDuplicates のみに使用されるならそこまでしなくても良い？

class Solution {
  func deleteDuplicates(_ head: ListNode?) -> ListNode? {
    guard let firstConfirmed = skipDuplicates(head) else { return nil }

    var lastConfirmed: ListNode = firstConfirmed
    var nodeToCheck: ListNode? = firstConfirmed.next
    firstConfirmed.next = nil
    lastConfirmed.next = nil

    while let node = skipDuplicates(nodeToCheck) {
      lastConfirmed.next = node
      lastConfirmed = node
      nodeToCheck = node.next
      lastConfirmed.next = nil
    }

    return firstConfirmed
  }

  private func skipDuplicates(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }
    guard let next = head.next, head.val == next.val else {
      return head
    }

    let valueToRemove = head.val
    var removeCandidate: ListNode? = head
    while let candidate = removeCandidate, candidate.val == valueToRemove {
      removeCandidate = candidate.next
    }

    return skipDuplicates(removeCandidate)
  }
}
