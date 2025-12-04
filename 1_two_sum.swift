// Step 1:
// 有名な問題ですね。
// 手作業でやる場合を考えます。
// 愚直にやるのであれば、全ての組み合わせを考えて、target に合致するペアがあれば、それらの添字を返してあげれば良い。
//
// それか、添字はきちんと追えるようにした状態で、数字を昇順にまず並べる。
// 最初の数字と最後の数字を足した数と目的の数を比較する。
// もし、和が目的の数より大きければ、和を少なくする必要があるので、後ろの数字を一つ前のものに置き換える。
// もし、和が目的の数より小さければ、和を大きくする必要があるので、前の数字を一つ前のものに置き換える。
// もし、和が目的の数と同じであれば、対応する添字を返してあげる。
// これを、前と後ろの数字が重なるまで繰り返す。
// 重なってしまったら、ペアがない。この時は空の配列を渡して、ペアがないことを示せば良いと思う。
//
// もう一つは、ペアに使用できる数字を表として用意しておく手法。
// もし、自分が誰かからこの仕事を頼まれたら、
// - 自分が持っている数字
// - ペアに使用できる数字が書かれた表
// - 目的の数字
// がわかっていれば、その時点でペアがあるかどうかは判断できる。
// もし、ペアがないのであれば、自分の数字を表に書き加えて、次の人に表を渡して仕事を引き継げば良い。
//
// 仕事の効率が早いのは、組み合わせを考えなくてよくて、並び替えもする必要がない最後のやつ。ただ表の文だけメモリは必要になる。
// nums はせいぜい 10^4 個が最大でそこまでの大きさにはならないから問題ないと思う。10K * (Int: 8Byte + Pointer: 8 Byte) = 160KB
//
// 最後の手法で解く。

class Solution {
  func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var seenNumsToIndex: [Int: Int] = [:]

    for (index, num) in nums.enumerated() {
      let valueToFind: Int = target - num

      guard let indexToFind = seenNumsToIndex[valueToFind] else {
        seenNumsToIndex[num] = index
        continue
      }

      return [index, indexToFind]
    }

    return []
  }
}

// それぞれの手法でかかる時間を計測してみた。
// === Two Sum Performance Benchmark ===
// | Algorithm       | Iterations | Avg Time (ns) |
// |-----------------|------------|---------------|

// [ Input Size: 100 ]
// | Hash Map        |       1000 回 | 18908.02 ns |
// | Sort + 2Ptr     |       1000 回 | 240935.92 ns |
// | Brute Force     |       1000 回 | 1206303.95 ns |

// [ Input Size: 1000 ]
// | Hash Map        |       1000 回 | 139840.01 ns |
// | Sort + 2Ptr     |       1000 回 | 2828801.99 ns |
// | Brute Force     |       1000 回 | 15930599.09 ns |

// [ Input Size: 10000 ]
// | Hash Map        |       1000 回 | 459985.97 ns |
// | Sort + 2Ptr     |       1000 回 | 19910923.00 ns |
// | Brute Force     |       1000 回 | 468267899.04 ns |

// 時間が計算量通りに増えていないのは、早めの段階でヒットしているからか？

// Step 2:
// 他の人のコードを読む。
//
// https://github.com/tNita/arai60/pull/1/files#diff-36e01301bf25ee19c79bcef7155d2589742c6534d5bc4790d6e0c9fbdfbc14f3R84
// 確かに、それぞれの数字に対して二分探索をしていく方法もあった。思いつかなかった。
//
// seenNumsToIndex でなく、単純に numToIndex で良さそう。

class Solution {
  func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var numToIndex: [Int: Int] = [:]

    for (index, num) in nums.enumerated() {
      let valueToFind: Int = target - num

      guard let indexToFind = numToIndex[valueToFind] else {
        numToIndex[num] = index
        continue
      }

      return [index, indexToFind]
    }

    return []
  }
}

// Step 3:

class Solution {
  func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var numToIndex: [Int: Int] = [:]

    for (index, num) in nums.enumerated() {
      let valueToFind: Int = target - num

      guard let indexToFind = numToIndex[valueToFind] else {
        numToIndex[num] = index
        continue
      }

      return [index, indexToFind]
    }

    return []
  }
}
