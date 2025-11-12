/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     public var val: Int
 *     public var next: ListNode?
 *     public init(_ val: Int) {
 *         self.val = val
 *         self.next = nil
 *     }
 * }
 */

// Step 1:
// 同じノードに2回たどり着けばわかる、周回していることがわかる。
// 同じノードにたどり着いたかどうかは、通ったノードを都度記録し、現在のノードと比較することでわかる。
// ただ、ループがかなり大きい場合はメモリを多く使用しそうだから他の方法を考えたい。
// 考え方を変えて、陸上の枠組みで考える。トラックを走る場合、複数走者がいて、周回遅れが発生したら、ビリと一位がもう一度出会う。
// これは、周回していない会場で起こることはない。
// そのため、この問題についても、二人の速度の違う走者を走らせてみて、二人がもう一度出会うかを考えれば良い。
// もし、追いついた場合は周回しているし、追いつかずにゴールした場合は、周回していない。

class Solution {
  func hasCycle(_ head: ListNode?) -> Bool {
    guard let nonNilHead = head else { return false }

    var slowPointer: ListNode? = nonNilHead
    var fastPointer: ListNode? = nonNilHead.next

    while fastPointer != nil && fastPointer!.next != nil {
      if slowPointer === fastPointer {
        return true
      }

      slowPointer = slowPointer!.next
      fastPointer = fastPointer!.next!.next
    }

    return false
  }
}

// Step 2:
// force-unwrap を多用しており、クラッシュの原因になりかねないのが気になる。
// while文の条件で確実に事前にチェックしていることは現段階では保証できている。
// ただ、もし実務などの状況であれば、リファクタリングで force-unwrap を保証できなくなるかもだから変えておきたい。
// 通常の Optional に変更。

class Solution {
  func hasCycle(_ head: ListNode?) -> Bool {
    guard let nonNilHead = head else { return false }

    var slowPointer: ListNode? = nonNilHead
    var fastPointer: ListNode? = nonNilHead.next

    while fastPointer != nil && fastPointer?.next != nil {
      if slowPointer === fastPointer {
        return true
      }

      slowPointer = slowPointer?.next
      fastPointer = fastPointer?.next?.next
    }

    return false
  }
}

// Step 3:
// 他の人のコードやコメントを見て、確かに今回の方法は若干手品っぽくパッと見ではわかりづらいと感じた。
// 最初にメモリ使用量を懸念した一度通ったノードを記録するより自然な方法について、set を用いて解いてみた。
// メモリ使用量は実際は、Int64 で考えると、Int と ポインタのみで考えるなら 8 + 8 で 16 byte で 10000 個あっても 160KB だから
// それほど影響はなさそう。

class Solution {
  func hasCycle(_ head: ListNode?) -> Bool {
    guard let nonNilHead = head else { return false }

    var slowPointer: ListNode? = nonNilHead
    var fastPointer: ListNode? = nonNilHead.next

    while fastPointer != nil && fastPointer?.next != nil {
      if slowPointer === fastPointer {
        return true
      }

      slowPointer = slowPointer?.next
      fastPointer = fastPointer?.next?.next
    }

    return false
  }
}

class Solution {
  func hasCycle(_ head: ListNode?) -> Bool {
    // Set を使用する場合には、Hashable プロトコルに準拠している必要があるが、
    // ListNode は Hashable には準拠していないため、代わりに class などのインスタンスの比較に
    // 用いられる ObjectIdentifier を使用した。
    var visitedNodes = Set<ObjectIdentifier>()
    var curNode: ListNode? = head

    while let node = curNode {
      let nodeId = ObjectIdentifier(node)

      if visitedNodes.contains(nodeId) {
        return true
      }

      visitedNodes.insert(nodeId)
      curNode = node.next
    }

    return false
  }
}

// Step 4:
// レビューを受けて、以下の点を改善
//   - head が nil の場合は、early return で false を返すようにした
//   - curNode が cur をつける文脈上つける意味があまりないため、nodeToCheckCycle という名前を使用。 単なる node でも良かったが、node を使用すると
//     while let node = node となり、while 文内の node = node.next で代入ができなくなるため、node とは異なる名前を使用した。
//     単なる node を使用し、while let nodeToCheckCycle = node とすることも考えたが、node = nodeToCheckCycle.next などで意味が分かりづらくなると考え採用しなかった
//   - 実際には、visitedNodes は Node の集合ではないため、visitedNodeIds という名前を使用するようにした

class Solution {
  func hasCycle(_ head: ListNode?) -> Bool {
    guard let head else { return false }

    // Set を使用する場合には、Hashable プロトコルに準拠している必要があるが、
    // ListNode は Hashable には準拠していないため、代わりに class などのインスタンスの比較に
    // 用いられる ObjectIdentifier を使用した。
    var visitedNodeIds = Set<ObjectIdentifier>()
    var nodeToCheckCycle: ListNode? = head

    while let node = nodeToCheckCycle {
      let nodeId = ObjectIdentifier(node)

      if visitedNodeIds.contains(nodeId) {
        return true
      }

      visitedNodeIds.insert(nodeId)
      nodeToCheckCycle = node.next
    }

    return false
  }
}
