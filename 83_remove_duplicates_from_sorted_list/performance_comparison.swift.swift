import Foundation

// AI で生成したコードで計測してみた

// 実行結果
// ベンチマーク開始（100回実行）...
// テストデータ: 300 要素 (3種類の値, 100回連続)

// --- 解法1 ---
// 平均時間: 31395.44 ns (ナノ秒)

// --- 解法2 (書き込みが少ないコード) ---
// 平均時間: 25680.39 ns (ナノ秒)

// --- 平均時間の差 (解法1 - 解法2) ---
// 時間差: 5715.05 ns (ナノ秒)
// 時間差: 5.72 μs (マイクロ秒)

public class ListNode {
  public var val: Int
  public var next: ListNode?
  public init(_ val: Int) {
    self.val = val
    self.next = nil
  }
}

func createList(from array: [Int]) -> ListNode? {
  guard !array.isEmpty else { return nil }
  let head = ListNode(array[0])
  var current = head
  for i in 1..<array.count {
    current.next = ListNode(array[i])
    current = current.next!
  }
  return head
}

class Solution {
  // 計測したい関数 (1つ目の解法)
  func deleteDuplicates_Solution1(_ head: ListNode?) -> ListNode? {
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

  // 比較したい関数 (2つ目の解法)
  func deleteDuplicates_Solution2(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }
    var node: ListNode? = head

    while let strongNode = node, strongNode.next != nil {
      var forward = strongNode.next
      while let strongForward = forward, strongNode.val == strongForward.val {
        forward = strongForward.next
      }
      strongNode.next = forward
      node = forward
    }
    return head
  }
}

// --- 計測の実行 ---

let sol = Solution()
let iterations = 100

// 3つの値 (0, 1, 2) のみを使用し、
// 各値が100回連続するリストを作成 (100 * 3 = 300要素)
// [0,0,...,0(100個), 1,1,...,1(100個), 2,2,...,2(100個)]
let testData = (0..<300).map { $0 / 100 % 3 }

print("ベンチマーク開始（\(iterations)回実行）...")
print("テストデータ: \(testData.count) 要素 (3種類の値, 100回連続)")

// --- 解法1の計測 ---
var totalFuncTime1_ns: UInt64 = 0
for _ in 0..<iterations {
  let head = createList(from: testData)
  let startFunc = DispatchTime.now()
  _ = sol.deleteDuplicates_Solution1(head)
  let endFunc = DispatchTime.now()
  totalFuncTime1_ns += (endFunc.uptimeNanoseconds - startFunc.uptimeNanoseconds)
}

let avgFunc1_ns = Double(totalFuncTime1_ns) / Double(iterations)
print("\n--- 解法1 ---")
print(String(format: "平均時間: %.2f ns (ナノ秒)", avgFunc1_ns))

// --- 解法2の計測 ---
var totalFuncTime2_ns: UInt64 = 0
for _ in 0..<iterations {
  let head = createList(from: testData)
  let startFunc = DispatchTime.now()
  _ = sol.deleteDuplicates_Solution2(head)
  let endFunc = DispatchTime.now()
  totalFuncTime2_ns += (endFunc.uptimeNanoseconds - startFunc.uptimeNanoseconds)
}

let avgFunc2_ns = Double(totalFuncTime2_ns) / Double(iterations)
print("\n--- 解法2 (書き込みが少ないコード) ---")
print(String(format: "平均時間: %.2f ns (ナノ秒)", avgFunc2_ns))

print("\n--- 平均時間の差 (解法1 - 解法2) ---")
print(String(format: "時間差: %.2f ns (ナノ秒)", avgFunc1_ns - avgFunc2_ns))
print(String(format: "時間差: %.2f μs (マイクロ秒)", (avgFunc1_ns - avgFunc2_ns) / 1_000))
