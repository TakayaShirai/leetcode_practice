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
// それぞれの連結リストを走査して、Int として保存。
// Int の足し算をしてから、それぞれの位を取り出して連結リストを作成する。
// これでもできそうだけど、入力としては 100 桁までくるから、最大101桁の数字になる可能性がある。
// Int が 64bit だとすると、2^63 まで表現できるが、// log10(2^63)= 63 * log10(2) ~= 63 * 0.301 = 18.963 で19桁までしか表現できない。
// これだと圧倒的に足りないから別手法を考える必要あり。
//
// 以下の足し算のループを回していけば良さそう。
//   - 事前に、計算結果が確定したノードをつなげていく用の連結リストを用意する。
//   - 各位のノードで、それぞれのノードと繰り上がりを足す。
//   - 和の計算結果から、「位の値」と「繰り上がり」を計算する。
//   - 繰り上がりは保存し、位の値は計算結果が確定したので、計算結果が確定したノードの最後尾に付け加える。
//   - これを、ノードもしくは繰り上がりがなくなるまで繰り返す。
// ループで共通する不変条件は以下。
//   - その位の計算は完了する。
//   - 繰り上がりがある場合は、次の計算に向けて新しい繰り上がりを保存する。
//   - 計算結果が確定した連結リストは、常に前回までの足し算の結果が完全に保存されている。

class Solution {
  func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    guard l1 != nil || l2 != nil else { return nil }

    let dummyHead = ListNode(0)
    var lastConfirmed: ListNode = dummyHead

    var l1Node: ListNode? = l1
    var l2Node: ListNode? = l2
    var carry: Int = 0

    while l1Node != nil || l2Node != nil || carry != 0 {
      let l1Value: Int = l1Node != nil ? l1Node!.val : 0
      let l2Value: Int = l2Node != nil ? l2Node!.val : 0

      let sum: Int = l1Value + l2Value + carry

      let digitNum: Int = sum % 10
      carry = sum / 10

      let newDigitNode = ListNode(digitNum)
      lastConfirmed.next = newDigitNode
      lastConfirmed = newDigitNode
      lastConfirmed.next = nil

      l1Node = l1Node?.next
      l2Node = l2Node?.next
    }

    return dummyHead.next
  }
}

// Step 2:
// 三項演算子で書いていたが、let l1Value = l1Node?.val ?? 0 とした方がわかりやすい。(?? の前の値 が nil の時に ?? の後の値 が入る。)
// また、newDigitNode をインスタンス化した時、next にはすでに nil が入っているため、
// lastConfirmed.next = nil は不要だった。ただ、ListNode の init によって next に何が設定されるかは変わるため、
// next を明示しておかないと、読み手が一度 ListNode を読みに行く必要がありそう。そのため、next の引数として nil を明示する。
// newDigitNode は新しい桁のノードというより、計算が完了した位のノードだから confirmedDigit とかの方が良さそう。
// 上記を考慮して、もう一度書き直す。

class Solution {
  func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    guard l1 != nil || l2 != nil else { return nil }

    let dummyHead = ListNode(0, nil)
    var lastConfirmed: ListNode = dummyHead

    var l1Node: ListNode? = l1
    var l2Node: ListNode? = l2
    var carry: Int = 0

    while l1Node != nil || l2Node != nil || carry != 0 {
      let l1Value: Int = l1Node?.val ?? 0
      let l2Value: Int = l2Node?.val ?? 0

      let sum: Int = l1Value + l2Value + carry

      let digitNum: Int = sum % 10
      carry = sum / 10

      let confirmedDigit = ListNode(digitNum, nil)
      lastConfirmed.next = confirmedDigit
      lastConfirmed = confirmedDigit

      l1Node = l1Node?.next
      l2Node = l2Node?.next
    }

    return dummyHead.next
  }
}

// 他の人の解答を見に行く。
//
// https://github.com/chanseok-lim/arai60/pull/14#discussion_r2087504459
// https://github.com/kazizi55/coding-challenges/pull/5#discussion_r2483866702
// l1Node = l1Node?.next などの次のノードに行く操作を途中に挟むのもあるのかー。
// 三項演算子や ?? などのオプショナルチェーニングを使いたくない場合は、こちらでも良さそう。
// 個人的には、最後に書く方が「今回のループを主軸にした処理」と「次のループに移るための処理」で分けられるため好みだが、
// どちらの方が一般的に読みやすいんだろうか。
//
// 三項演算子は確かに認知負荷が上がるから避けた方が良さそう。
// オプショナルチェーニングで書き直した後は、let l1Val: Int = l1Node?.val ?? 0 で短いが、これは許容範囲だろうか。
// 横幅は短くなるが、l1Node?.val が nil でないなら l1Node?.val を代入して、nil なら 0 を代入と、結局三項演算子とやっていることは変わらない。
// うーん、ただ慣れているせいか短いせいか、オプショナルチェーニングは個人的にはそこまでの認知負荷はかかっていない気がする。
//
// https://github.com/TrsmYsk/leetcode/pull/7/files
// 不変条件あってループなら確かに再帰でかけるはずか。選択肢として思いつきたかった。
//
// 再帰書いてみる。書いてみたけど、スタック領域で余計にメモリを取るし、可読性も低下するため、元のループのやつの方が良さそう。
// 行きがけ
class Solution {
  func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    guard l1 != nil || l2 != nil else { return nil }

    func confirmDigits(_ node1: ListNode?, _ node2: ListNode?, carry: Int, lastConfirmed: ListNode)
    {
      guard node1 != nil || node2 != nil || carry != 0 else { return }

      var node1Value: Int = node1?.val ?? 0
      var node2Value: Int = node2?.val ?? 0

      let sum: Int = node1Value + node2Value + carry
      let digitNum: Int = sum % 10
      let newCarry: Int = sum / 10

      let confirmedDigit = ListNode(digitNum, nil)
      lastConfirmed.next = confirmedDigit

      confirmDigits(node1?.next, node2?.next, carry: newCarry, lastConfirmed: confirmedDigit)
    }

    var dummyHead = ListNode(0, nil)
    confirmDigits(l1, l2, carry: 0, lastConfirmed: dummyHead)
    return dummyHead.next
  }
}

// 帰りがけ
class Solution {
  func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    guard l1 != nil || l2 != nil else { return nil }

    func confirmDigits(_ node1: ListNode?, _ node2: ListNode?, carry: Int) -> ListNode? {
      guard node1 != nil || node2 != nil || carry != 0 else { return nil }

      var node1Value: Int = node1?.val ?? 0
      var node2Value: Int = node2?.val ?? 0

      let sum: Int = node1Value + node2Value + carry
      let digitNum: Int = sum % 10
      let newCarry: Int = sum / 10

      var firstConfirmed = ListNode(digitNum, nil)
      let restConfirmed = confirmDigits(node1?.next, node2?.next, carry: newCarry)
      firstConfirmed.next = restConfirmed

      return firstConfirmed
    }

    return confirmDigits(l1, l2, carry: 0)
  }
}

// あと、番兵なしバージョンも練習で書く。
class Solution {
  func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    guard l1 != nil || l2 != nil else { return nil }

    // 未初期化として、nil で埋めておく。
    // Ref: https://github.com/seal-azarashi/leetcode/pull/5#discussion_r1639556137
    // confirmed という命名をしているのに nil を入れるのは違和感があるため、head, tail に変更。
    var head: ListNode? = nil
    var tail: ListNode? = nil

    var l1Node: ListNode? = l1
    var l2Node: ListNode? = l2
    var carry: Int = 0

    while l1Node != nil || l2Node != nil || carry != 0 {
      let l1Value: Int = l1Node?.val ?? 0
      let l2Value: Int = l2Node?.val ?? 0

      let sum: Int = l1Value + l2Value + carry

      let digitNum: Int = sum % 10
      carry = sum / 10

      let confirmedDigit = ListNode(digitNum, nil)

      if head == nil {
        head = confirmedDigit
        tail = confirmedDigit
      } else {
        tail?.next = confirmedDigit
        tail = confirmedDigit
      }

      l1Node = l1Node?.next
      l2Node = l2Node?.next
    }

    return head
  }
}

// Step 3:
// While ループで、番兵ありバージョンで書く。
class Solution {
  func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    guard l1 != nil || l2 != nil else { return nil }

    var l1Node: ListNode? = l1
    var l2Node: ListNode? = l2
    var carry: Int = 0

    var dummyHead = ListNode(0, nil)
    var lastConfirmed: ListNode = dummyHead

    while l1Node != nil || l2Node != nil || carry != 0 {
      let l1Value: Int = l1Node?.val ?? 0
      let l2Value: Int = l2Node?.val ?? 0

      let sum: Int = l1Value + l2Value + carry

      let newCarry: Int = sum / 10
      let digitNum: Int = sum % 10

      carry = newCarry
      let confirmedDigit = ListNode(digitNum, nil)
      lastConfirmed.next = confirmedDigit
      lastConfirmed = confirmedDigit

      l1Node = l1Node?.next
      l2Node = l2Node?.next
    }

    return dummyHead.next
  }
}
