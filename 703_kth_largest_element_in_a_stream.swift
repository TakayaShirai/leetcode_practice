// Step 1:
//
// 満たすべき条件を確認
//   - 上位 k 番目のスコアを常時確認可能にする
//
// 本来なら確認したいなと思ったこと
// スコアの取り消しがないと考える場合は、一度上位 k 個から外れた値が、再度上位 k 個に戻ることはないため、
// 上位 k 個のスコアのみを確保しておいて、k 個のスコアを常に更新すれば、k番目のスコアは確認できる。
// しかし、大学入試ではカンニングなどによる受験資格失効などの場合もありうるから、
// 上位 k 個以外のスコアも保存しておく必要がありそう。上位 k 個以外のスコアも保存する方針でやってみる。
//
// 手作業でやるとしたら
// 1. まず、「k 番目までのスコアの集合」と「k 番目以降のスコアの集合」に分ける。
//      - この時、それぞれで「k 番目のスコアが何であるか」、「k+1 番目のスコアが何であるか」を常に確認できるようにしたい。
// 2. 新しいスコアが来たら、k 番目のスコア以上かを確認する
//      - k番目のスコアより大きいなら、「k番目までのスコアの集合」を更新して、k+1 番目のスコアを「k番目以降のスコアの集合」に移す
//      - k番目のスコアより小さいなら、「k番目以降のスコアの集合」に追加する。
//      - この時も、「k 番目のスコアが何であるか」、「k+1 番目のスコアが何であるか」を常に確認できるようにしたい。
// 3. 更新後に、「k 番目までのスコアの集合」を確認して k 番目のスコアを返す。
//   （追加したいスコアが k 番目のスコアよりも小さければすぐに返して、そのあと更新しても良さそう。）
//
// それぞれで「k 番目のスコアが何であるか」、「k+1 番目のスコアが何であるか」を常に確認できるようにしたい
// この要件をどう実現するかが問題
//
// 配列でやるとすれば、常にソートされているのならこれの確認は、それぞれの配列の末尾と先頭を確認すれば良いため、O(1)で可能。
// ただし、配列を更新する際にある位置に値を挿入する場合にO(N)かかる。
// もし、削除機能を追加する場合、スコアを削除するにはその値を配列から見つけるためにO(logN)、削除するのにO(N)なので、削除全体でO(N)。
// というか、上位k個を分けることに固執しているが、配列でやるとしたらわざわざ二つに分けないでも、一つで管理して添え字が"k-1"の値を取り続けるのでもいいか。
// まあ、それでもわかりやすくはなるけど計算量自体は変わらないか。
//
// ヒープで行えば、「k 番目までのスコアの集合」で Minヒープ、「k 番目以降のスコアの集合」で Max ヒープを使えば常時確認を実現できる。
// 確認はO(1), 挿入はO(logN)、削除では値を探すのにO(N)、削除自体にO(logN)かかるため、削除全体ではO(N)。
//
// 確認・削除については、配列、ヒープどちらも同じで空間計算量も同じ。挿入はヒープの方が計算量が少ないため、ヒープでやる。
// ただ、ヒープがどのような仕組みで実装されているかをほとんどわかっていないため、自分でヒープも実装してみたい。
// 直近の取れる時間がないため、土日にやる。

// Heap: https://swiftpackageindex.com/apple/swift-collections/1.3.0/documentation/heapmodule/heap
// 注意：restValues は問題としては必要ない。もし、remove などの関数が必要になった場合に必要。
class KthLargest {

  let numOfScoresToTrack: Int
  var kMaxScores: Heap<Int>
  var restScores: Heap<Int>

  init(_ k: Int, _ nums: [Int]) {
    numOfScoresToTrack = k
    kMaxScores = []
    restScores = []

    for score in nums {
      add(score)
    }
  }

  func add(_ val: Int) -> Int {
    guard kMaxScores.count >= numOfScoresToTrack else {
      kMaxScores.insert(val)
      return kMaxScores.min!
    }

    let kthMaxScore: Int = kMaxScores.min!

    if val <= kthMaxScore {
      restScores.insert(val)
    } else {
      kMaxScores.insert(val)
      let scoreToSwap = kMaxScores.popMin()!
      restScores.insert(scoreToSwap)
    }

    return kMaxScores.min!
  }
}

// restScores ないバージョン
class KthLargest {

  let numOfScoresToTrack: Int
  var kMaxScores: Heap<Int>

  init(_ k: Int, _ nums: [Int]) {
    numOfScoresToTrack = k
    kMaxScores = []

    for score in nums {
      add(score)
    }
  }

  func add(_ val: Int) -> Int {
    guard kMaxScores.count >= numOfScoresToTrack else {
      kMaxScores.insert(val)
      return kMaxScores.min!
    }

    let kthMaxScore: Int = kMaxScores.min!

    guard val > kthMaxScore else {
      return kthMaxScore
    }

    kMaxScores.popMin()
    kMaxScores.insert(val)

    return kMaxScores.min!
  }
}

// Step 2:
// 他の人のコードを読む
// https://github.com/docto-rin/leetcode/pull/8/files#diff-7cc49926a76cf0dcdcce4baa67d2f64e35b83ab2e3a1868b4b2fef1e035e3381R89
// >> あとは変数の命名について、self.topk_numsのtopkの意味がわかりにくいので、self.k_largest_numsとかにします。
// max を使って命名していたが、確かに largest の方が英語として正しいし、自然。
//
// https://github.com/kazizi55/coding-challenges/pull/8/files#r2493593015
// https://github.com/Ryotaro25/leetcode_first60/pull/66#discussion_r2020117414
// 時間計算量だけでなく、きちんとどれぐらいの時間がかかるかの概算もできるようになりたい。
//
// https://discord.com/channels/1084280443945353267/1206101582861697046/1208473290881110117
// >> 東京から新宿まで移動してくれと言われたら、中央線もあれば、丸ノ内線もあれば、タクシーを拾ってもいいし、自分で運転してもいいし、歩いていってもいいじゃないですか。
// >> これくらいの幅を持って見ていて、その中には愚直なのもあれば、短いのもあれば、速いのもあれば、遅いのもあり、色々なバランスを見て、今日はこれくらいにしておくかな、くらいの感覚で選んでいます。
// 問題とは直接関係ないですが、これをどのような問題に対しても自然にできるようになりたいなと思ったため載せました。
// 複数選択肢思いつくためには、そもそもの知識もそうだけど、普段から色々とああできないか、こうできないかと考えるのが重要なのかな。
// まあやってみないとわからないので、とりあえずああできないか、こうできないかを試行錯誤する習慣をまずはつける。
// とりあえず今回ので配列とヒープ以外に別手法がなかったか考えたが、連結リストでやってもいいかと思った。
// ただ、もしソートされている連結リストを単純に使うなら、追加、削除はO(N)、k番目の確認にO(1)かかる。(「k 番目までのスコアの集合(昇順)」と「k 番目以降のスコアの集合(降順)」で分ける)
//
// k 個のスコアが集まっていない状態で、何を返り値とするかにばらつきがあった。
// - None を返り値として返す
// - その時点での最小の値を返り値として
// ここについてどちらを返すかは要件次第な気がするが、最小の値を返してしまうとそれが本当にk番目の値なのか、それともk個ないからとりあえず最小の値を返しているのかがわからないため、
// None を返すのが良いのではないかと感じた。
//
// 以上を踏まえて、命名の変更、nil を返すように変更。ただし、leetcode 上では、返り値を変えることは許されていないようなのでエラーが出ます。
// restScores ないバージョンで書く。

class KthLargest {

  let numOfScoresToTrack: Int
  var kLargestScores: Heap<Int>

  init(_ k: Int, _ nums: [Int]) {
    numOfScoresToTrack = k
    kLargestScores = []

    for score in nums {
      add(score)
    }
  }

  func add(_ val: Int) -> Int? {
    guard kLargestScores.count >= numOfScoresToTrack else {
      kLargestScores.insert(val)
      return nil
    }

    let kthLargestScore: Int = kLargestScores.min!

    guard val > kthLargestScore else {
      return kthLargestScore
    }

    kLargestScores.popMin()
    kLargestScores.insert(val)

    return kLargestScores.min
  }
}

// Step 3:
class KthLargest {

  let numOfScoresToTrack: Int
  var kLargestScores: Heap<Int>

  init(_ k: Int, _ nums: [Int]) {
    numOfScoresToTrack = k
    kLargestScores = []

    for score in nums {
      add(score)
    }
  }

  func add(_ val: Int) -> Int {
    guard kLargestScores.count >= numOfScoresToTrack else {
      kLargestScores.insert(val)
      return kLargestScores.min!
    }

    let kthLargestScore: Int = kLargestScores.min!

    guard val > kthLargestScore else {
      return kthLargestScore
    }

    kLargestScores.popMin()
    kLargestScores.insert(val)

    return kLargestScores.min!
  }
}

// Step 4:
// Heap (Min-heap) の実装をやってみる
// 以下の動画を見て、他の人のコードなどは参考にせず実装してみた。練習のおかげか意外とできた。
// https://www.youtube.com/watch?v=HqPJF2L5h9U
public class MinHeap {

  private var values: [Int]
  private var lastValueIdx: Int

  init(nums: [Int] = []) {
    values = nums
    lastValueIdx = nums.count - 1
    heapify()
  }

  public var count: Int {
    return lastValueIdx + 1
  }

  public var isEmpty: Bool {
    return lastValueIdx >= 0
  }

  public func insert(_ value: Int) -> Int {
    if lastValueIdx == values.count - 1 {
      values.append(value)
    } else {
      values[lastValueIdx + 1] = value
    }

    lastValueIdx += 1
    swapUp(nodeIdx: lastValueIdx)

    return top()!
  }

  public func pop() -> Int? {
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

  public func top() -> Int? {
    guard !values.isEmpty else {
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

    let nodeValue: Int = values[nodeIdx]

    guard child2Idx <= lastValueIdx else {
      let child1Value: Int = values[child1Idx]

      if nodeValue > child1Value {
        swapValues(value1Idx: nodeIdx, value2Idx: child1Idx)
        swapDown(nodeIdx: child1Idx)
      }

      return
    }

    let child1Value = values[child1Idx]
    let child2Value = values[child2Idx]

    var smallerValue: Int
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

    let tmp: Int = values[value1Idx]
    values[value1Idx] = values[value2Idx]
    values[value2Idx] = tmp
  }
}
