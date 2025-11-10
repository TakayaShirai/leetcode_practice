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
// Set で一度訪れたノードを記録しておく。
// もし、Set で重複が見つからないまま、Linked List の最後のノード（next が nil）に辿り着けば、サイクルはないので nil を返せば良い。
// もし、重複が見つかった場合は、そこからサイクルが始まっているため、そのノードを返り値として渡せば良い。

class Solution {
  func detectCycle(_ head: ListNode?) -> ListNode? {
    var node: ListNode? = head
    // ObjectIdentifier を使用する理由:
    // ListNode は参照型（クラス）のため、同じ値（val）を持つ異なるノードインスタンスを区別する必要がある。
    // ObjectIdentifier は各インスタンスの一意の識別子を提供し、同じインスタンスへの参照を正確に検出できる。
    // また、ListNode は Hashable プロトコルに準拠していないため、Set<ListNode> として直接使用できない。
    var visitedNodes = Set<ObjectIdentifier>()

    while let curNode = node {
      let curNodeId = ObjectIdentifier(curNode)

      if visitedNodes.contains(curNodeId) {
        return curNode
      }

      visitedNodes.insert(curNodeId)
      node = curNode.next
    }

    return nil
  }
}

// Step 2:
// node は nil になる可能性があるため、それを名前につけた方がよりわかりやすそうと考え、node を nullableNode に変更

class Solution {
  func detectCycle(_ head: ListNode?) -> ListNode? {
    var nullableNode: ListNode? = head
    // ObjectIdentifier を使用する理由:
    // ListNode は参照型（クラス）のため、同じ値（val）を持つ異なるノードインスタンスを区別する必要がある。
    // ObjectIdentifier は各インスタンスの一意の識別子を提供し、同じインスタンスへの参照を正確に検出できる。
    // また、ListNode は Hashable プロトコルに準拠していないため、Set<ListNode> として直接使用できない。
    var visitedNodes = Set<ObjectIdentifier>()

    while let node = nullableNode {
      let nodeId = ObjectIdentifier(node)

      if visitedNodes.contains(nodeId) {
        return node
      }

      visitedNodes.insert(nodeId)
      nullableNode = node.next
    }

    return nil
  }
}

// Step 3:
class Solution {
  func detectCycle(_ head: ListNode?) -> ListNode? {
    var nullableNode: ListNode? = head
    // ObjectIdentifier を使用する理由:
    // ListNode は参照型（クラス）のため、同じ値（val）を持つ異なるノードインスタンスを区別する必要がある。
    // ObjectIdentifier は各インスタンスの一意の識別子を提供し、同じインスタンスへの参照を正確に検出できる。
    // また、ListNode は Hashable プロトコルに準拠していないため、Set<ListNode> として直接使用できない。
    var visitedNodes = Set<ObjectIdentifier>()

    while let node = nullableNode {
      let nodeId = ObjectIdentifier(node)

      if visitedNodes.contains(nodeId) {
        return node
      }

      visitedNodes.insert(nodeId)
      nullableNode = node.next
    }

    return nil
  }
}
