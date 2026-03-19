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
// スタックを使う方法が一番最初に思い浮かんだ。
//   - 前から順番にスタックに値を格納
//   - 全て格納し終えたら、スタックから順に値を取り出し、ノードを形成して連結リストに接続
//   - スタックから値が消えるまでこれを繰り返せば、逆順の連結リストが完成する
//   - ただし、返り値は先頭のノードを返す必要があるので、最初にそのポインタは保存しておく。
//
// この方法の懸念点としては、与えられている連結リストのメモリのおおよそ2倍のメモリが必要なこと。
// in-place でやらないことが確定しているなら良さそうだけど、使用するメモリに懸念はあるか？
// 確認してみる。Int で 8Byte 、ポインタで 8Byte、その他オーバーヘッドが 16 Byte あるとして、インスタンス一つで　32 Byte と仮定。
// 条件は 5000 ノードが上限だが、仮に 100 万ノードあっても、1M × 32 = 32 MB。iPhone12 でも RAM は 4GB あるから大丈夫そう。
// とりあえず、これでやってみる。
// Inner Function は使用せず書いた。単一責任原則に反すると感じたため。
class Solution {
  func reverseList(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }
    let nodeValues: [Int] = extractValues(from: head)
    let reversedValues: [Int] = nodeValues.reversed()
    let list: ListNode? = createLinkedList(from: reversedValues)
    return list
  }

  private func extractValues(from head: ListNode?) -> [Int] {
    guard let head else { return [] }
    var nodeToCheck: ListNode? = head
    var extractedValues: [Int] = []

    while let node = nodeToCheck {
      extractedValues.append(node.val)
      nodeToCheck = node.next
    }

    return extractedValues
  }

  private func createLinkedList(from values: [Int]) -> ListNode? {
    let dummyHead = ListNode(0, nil)
    var node: ListNode = dummyHead

    for value in values {
      let newNode = ListNode(value, nil)
      node.next = newNode
      node = node.next!
    }

    return dummyHead.next
  }
}

// Step 2:
// 他の人のコードを見る前にもう一手法書く。
// もし連結リストが目の前にあり、自分が手作業でやるとしたら、値の格納などはせず、単に連結部分を全て逆にする作業をするはず。
// なるべく早めに　Step 1 を終わらせようとしたせいでこの手法を Step 1 で検討できなかったが、これも選択肢として検討すべきだった。

class Solution {
  func reverseList(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var previous: ListNode? = nil
    var current: ListNode? = head

    while let node = current {
      let next: ListNode? = node.next

      node.next = previous
      previous = node
      current = next
    }

    return previous
  }
}

// 他の人のコード・コメントを見る
//
// https://github.com/t0hsumi/leetcode/pull/7#discussion_r1875385145
// > 仕事をループの途中で引き継いだとしましょう。
// > これが node と previous ね、という書き置きがあったら何言っているんだって感じじゃないですか。
// > 先頭からひっくり返していって「まだひっくり返していない部分」と「もうひっくり返した部分」という引き継ぎになるでしょう。
// previous を返すのが少し気持ち悪いと感じていたが、previous という命名そのものが良くなかった。何も意味していないから。
// これまでの重複を消す問題などで、「重複をまだ消していない部分」、「重複をすでに消した部分」などで分けていたのに
// 今回「まだひっくり返していない部分」と「もうひっくり返した部分」で考えられていなかったのは反省。
//
// https://github.com/docto-rin/leetcode/pull/7
// 再帰についてトレードオフを考えた上で、iterative な手法をとっているのが良いなと感じた。
//
// 命名方法を改善したもの
class Solution {
  func reverseList(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var reversedHead: ListNode? = nil
    var unreversedHead: ListNode? = head

    while let node = unreversedHead {
      let nextUnreversed: ListNode? = node.next

      node.next = reversedHead
      reversedHead = node
      unreversedHead = nextUnreversed
    }

    return reversedHead
  }
}

// 再帰
// 参考リンク：
// https://github.com/goto-untrapped/Arai60/pull/27#discussion_r1638693522
// https://discord.com/channels/1084280443945353267/1231966485610758196/1239417493211320382
//

// 帰りがけ(あるノード以降のノード全てを逆順にしたものを返してもらう。そこから、自分のノードと返してもらったノードを繋げる。)
// 仕事を任せる、任せた仕事を引き取る時、自分と相手は何が必要？
// 相手は、「逆順にしなければならないリストの先頭」が欲しい。
// 自分は、自分で逆順にしたリストを、相手が逆順にしたリストに連結した上で、先頭から並べたいから、
// 自分のリストを連結する「相手の逆順のリストの末尾」と、先頭として並べるべき「相手の逆順のリストの先頭」が欲しい。
// ただし実際は、相手に渡した「リストの先頭」が必ず「相手の逆順のリストの末尾」になるため、これはもらわなくてもわかる。
// helperReverseList っていう関数名はありなのだろうか。
// leetcode 上だから二つ関数を用意しているけど、本来なら一つでいいから、そこまで気にしなくても良い気もする。

class Solution {
  func reverseList(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }
    return helperReverseList(head)
  }

  private func helperReverseList(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }
    guard let next = head.next else { return head }

    let reversedHead: ListNode? = helperReverseList(next)
    head.next = nil
    next.next = head
    return reversedHead
  }
}

// 行きがけ(自分で途中までを逆順にする。そのあとそれを相手に渡して、全部逆順にし終わったものを受け取る。)
// ここまで終わりましたよ。の目印と、ここから仕事してくださいよ。の目印が欲しい。
// 最終的な成果物は、逆順にしたリストの先頭が欲しい。

class Solution {
  func reverseList(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }
    return helperReverseList(reversedHead: nil, unreversedHead: head)
  }

  private func helperReverseList(reversedHead: ListNode?, unreversedHead: ListNode?) -> ListNode? {
    guard let node = unreversedHead else { return reversedHead }

    let nextUnreversed = node.next
    node.next = reversedHead
    return helperReverseList(reversedHead: node, unreversedHead: nextUnreversed)
  }
}

// Step 3:
class Solution {
  func reverseList(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }

    var reversedHead: ListNode? = nil
    var unreversedHead: ListNode? = head

    while let node = unreversedHead {
      let nextUnreversed: ListNode? = node.next

      node.next = reversedHead
      reversedHead = node
      unreversedHead = nextUnreversed
    }

    return reversedHead
  }
}
