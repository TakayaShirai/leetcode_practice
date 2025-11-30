// Step 1:
// まず、状況整理
// 整数の配列 nums とある整数 k が与えられて、nums のうち最も頻出度の高い k 個の要素を返すことができれば良い。
// 手作業でこれをやるならどうするか
// 手法１：
// - まず、全ての数字の頻出回数を調べて、表にまとめる。
// - 頻出回数が大きい順に、数字を並べ直す。
// - 上から順に k 個集めて、それを返す。
// これが一番最初に思いついた方法。
// それ以外の手作業が思いつかなかったので、とりあえずそれで実装する。

class Solution {
  func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
    var numCounter: [Int: Int] = createCounter(of: nums)
    let sortedNums: [Int] = sortNums(with: numCounter)
    return Array(sortedNums.prefix(k))
  }

  private func createCounter(of nums: [Int]) -> [Int: Int] {
    var counter: [Int: Int] = [:]

    for num in nums {
      counter[num, default: 0] += 1
    }

    return counter
  }

  // Map の効率的なソートの方法がすぐに思いうかばなかったため、とりあえず愚直に書いた。
  private func sortNums(with counter: [Int: Int]) -> [Int] {
    var pairs: [(Int, Int)] = []

    for (key, value) in counter {
      pairs.append((key, value))
    }

    let sortedPairs = pairs.sorted { $0.1 > $1.1 }
    var sortedKeys: [Int] = []

    for (key, value) in sortedPairs {
      sortedKeys.append(key)
    }

    return sortedKeys
  }
}

// 実装終了後に他に何があるかを考えてみた。
// 手法1について再考：
// 単純に、「頻出回数が大きい順に、数字を並べ直す」と書いていたがソート自体も複数選択肢があるから
// 本来は、それについても考えるべきだった。
// クイックソートなのか、バブルソートなのか、ブロックソートなのか、それとも別のソートなのか。
// 今回は、全て整数値で、そこまで入力の数も大きくないため、ブロックソートが良さそう。
// それぞれ今度実装して、利点・欠点について理解する。
//
// 手法二つ目：
// ヒープから逆算して考えてしまったが、以下もあり。
// もし数字とその出現頻度を入れたら、勝手に今までのデータと統合して、上から k 番目までの要素を出してくれる機械があれば、人間はデータを入れるだけで済む。
// よって、
// - 常に出現頻度上位 k 個を把握できる機械を作る。
// - 数字とその出現回数を記録する。
// - 記録した数字と出現頻度のデータをその機械に打ち込む。
// - 全てのデータを打ち込んだ後に、機械から上位 k 個目までの値を読み取る
// MinHeapで常に k 個のデータを保存するようにすれば、これはできる。
//
// 他にも手法はありそうではあるが、趣味の範囲になりそうなので、とりあえず step 2 に移る。

// Step 2:
// 他の人のコードを読む。
//
// https://github.com/kt-from-j/leetcode/pull/15
// https://discord.com/channels/1084280443945353267/1183683738635346001/1185972070165782688
// quick select なるものがあるらしい。クイックソートの片側をやらずに先に進んでいくようなもの。
// 先にクイックソートを実装してから実装してみよう。
//
// https://github.com/docto-rin/leetcode/pull/9
// クイックソートについて LLM と相談しながら考察をしていて良いなと感じた。
//
// ソートをバケットソートにしたもの、ヒープを用いたものを両方実装してみる。

// バケットソート
class Solution {
  func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
    let sortedNums: [Int] = sortByFrequency(nums)
    return Array(sortedNums.prefix(k))
  }

  private func sortByFrequency(_ nums: [Int]) -> [Int] {
    var counter: [Int: Int] = [:]
    var maxCount: Int = 0

    for num in nums {
      counter[num, default: 0] += 1
      maxCount = max(maxCount, counter[num, default: 0])
    }

    var frequencyGroups: [[Int]] = Array(repeating: [], count: maxCount + 1)

    for (num, count) in counter {
      frequencyGroups[count].append(num)
    }

    var sortedNums: [Int] = []

    for frequencyGroup in frequencyGroups.reversed() {
      guard !frequencyGroup.isEmpty else {
        continue
      }

      for num in frequencyGroup {
        sortedNums.append(num)
      }
    }

    return sortedNums
  }
}

// ヒープ
// 長すぎるため、次からは Swift では選択しないと思う。
class Solution {
  func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
    let occurrences: [Occurrence] = createOccurrences(of: nums)
    var topKOccurrences = MinHeap<Occurrence>()

    for occurrence in occurrences {
      guard topKOccurrences.count >= k else {
        topKOccurrences.insert(occurrence)
        continue
      }

      topKOccurrences.insert(occurrence)
      topKOccurrences.pop()
    }

    var topKFrequentNums: [Int] = []

    for i in 0..<k {
      guard let occurrence = topKOccurrences.pop() else {
        return topKFrequentNums
      }

      topKFrequentNums.append(occurrence.num)
    }

    return topKFrequentNums
  }

  private func createOccurrences(of nums: [Int]) -> [Occurrence] {
    let counter = createCounter(of: nums)
    var occurrences: [Occurrence] = []

    for (num, count) in counter {
      occurrences.append(Occurrence(num: num, count: count))
    }

    return occurrences
  }

  private func createCounter(of nums: [Int]) -> [Int: Int] {
    var counter: [Int: Int] = [:]

    for num in nums {
      counter[num, default: 0] += 1
    }

    return counter
  }
}

struct Occurrence: Comparable {
  let num: Int
  let count: Int

  static func < (lhs: Occurrence, rhs: Occurrence) -> Bool {
    return lhs.count < rhs.count
  }
}

// Heap (Min-heap) の実装。以下の動画を参考にして、自分で一から実装してみた。
// https://www.youtube.com/watch?v=HqPJF2L5h9U
public class MinHeap<T: Comparable> {

  private var values: [T]
  private var lastValueIdx: Int

  init(values: [T] = []) {
    self.values = values
    self.lastValueIdx = values.count - 1
    heapify()
  }

  public var count: Int {
    return lastValueIdx + 1
  }

  public var isEmpty: Bool {
    return lastValueIdx < 0
  }

  public func insert(_ value: T) -> T {
    if lastValueIdx == values.count - 1 {
      values.append(value)
    } else {
      values[lastValueIdx + 1] = value
    }

    lastValueIdx += 1
    swapUp(nodeIdx: lastValueIdx)

    return top()!
  }

  public func pop() -> T? {
    guard let minValue = top() else {
      return nil
    }

    swapValues(value1Idx: 0, value2Idx: lastValueIdx)
    lastValueIdx -= 1

    if lastValueIdx >= 0 {
      swapDown(nodeIdx: 0)
    }

    return minValue
  }

  public func top() -> T? {
    guard !isEmpty else {
      return nil
    }

    return values[0]
  }

  private func heapify() {
    guard lastValueIdx >= 0 else { return }

    let startIdx = (lastValueIdx - 1) / 2

    for i in (0...startIdx).reversed() {
      swapDown(nodeIdx: i)
    }
  }

  private func swapUp(nodeIdx: Int) {
    guard 0 < nodeIdx && nodeIdx <= lastValueIdx else {
      return
    }

    let parentIdx: Int = (nodeIdx - 1) / 2

    guard values[parentIdx] > values[nodeIdx] else {
      return
    }

    swapValues(value1Idx: parentIdx, value2Idx: nodeIdx)
    swapUp(nodeIdx: parentIdx)
  }

  private func swapDown(nodeIdx: Int) {
    guard 0 <= nodeIdx && nodeIdx <= lastValueIdx else {
      return
    }

    let child1Idx: Int = nodeIdx * 2 + 1
    let child2Idx: Int = nodeIdx * 2 + 2

    guard child1Idx <= lastValueIdx else {
      return
    }

    let nodeValue: T = values[nodeIdx]

    guard child2Idx <= lastValueIdx else {
      let child1Value: T = values[child1Idx]

      if nodeValue > child1Value {
        swapValues(value1Idx: nodeIdx, value2Idx: child1Idx)
        swapDown(nodeIdx: child1Idx)
      }

      return
    }

    let child1Value = values[child1Idx]
    let child2Value = values[child2Idx]

    var smallerValue: T
    var smallerValueIdx: Int

    if child1Value < child2Value {
      smallerValue = child1Value
      smallerValueIdx = child1Idx
    } else {
      smallerValue = child2Value
      smallerValueIdx = child2Idx
    }

    guard nodeValue > smallerValue else {
      return
    }

    swapValues(value1Idx: nodeIdx, value2Idx: smallerValueIdx)
    swapDown(nodeIdx: smallerValueIdx)
  }

  private func swapValues(value1Idx: Int, value2Idx: Int) {
    guard value1Idx < values.count && value2Idx < values.count else {
      return
    }

    let tmp: T = values[value1Idx]
    values[value1Idx] = values[value2Idx]
    values[value2Idx] = tmp
  }
}

// Step 3:
class Solution {
  func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
    let sortedNums: [Int] = sortByFrequency(nums)
    return Array(sortedNums.prefix(k))
  }

  private func sortByFrequency(_ nums: [Int]) -> [Int] {
    var counter: [Int: Int] = [:]
    var maxCount: Int = 0

    for num in nums {
      counter[num, default: 0] += 1
      maxCount = max(maxCount, counter[num, default: 0])
    }

    var frequencyGroups: [[Int]] = Array(repeating: [], count: maxCount + 1)

    for (num, count) in counter {
      frequencyGroups[count].append(num)
    }

    var sortedNums: [Int] = []

    for frequencyGroup in frequencyGroups.reversed() {
      guard !frequencyGroup.isEmpty else {
        continue
      }

      for num in frequencyGroup {
        sortedNums.append(num)
      }
    }

    return sortedNums
  }
}
