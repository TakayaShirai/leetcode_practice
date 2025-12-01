// Step 1:
// 手作業でやるならどうやるかを考える。
// 4:53 ~
// 求められていること
// - 二つの数字の配列 nums1, nums2 が与えられており、これらは昇順に並び替えられている。
// - もう一つの数字 k が与えられる。
// この条件下で、それぞれの配列から一つずつ数字を取り出してできる数字の組み合わせの中で、
// 合計が最も小さい k 個の数字の組み合わせを作ってください。
//
// ものすごく単純にやるのであれば、全ての組み合わせを作成し、それらを小さい順に並び替えて、一番前から k 個を返せば良い。
// 最終的に全ての組み合わせが必要になるなどの状況であれば、これでもいいかもしれないが、作るべき組み合わせの量は、最大 10^5 * 10^5 で100億である。
// Int が 64 bit で 8Byte とすると、必要なメモリ数は 10G * 8 で 80GB ほどになるため、通常のコンピュータでメモリに乗らない。
// ということは通常使えない手法。
//
// 他のやり方で行くなら、降順に並び替えられていることを活用する。
// 他の方法思いつかず、回答を見る。
//
// この説明が一番わかりやすかった。
// https://github.com/yas-2023/leetcode_arai60/pull/10/files#diff-827c4dfd5a4181b5e45f25a627a2129cd5fb00a3e682ac0284e943b4ca91962eR12
// - 昇順にソート済みであることを考えると、最小はnum1[0],num2[0]
// - 次に小さいのはnum1[0],num2[1] or num1[1],num1[0]のいずれか
// - 2次元の表だと考えて、最初の列をheapに入れれば、後は行方向のみ考えれば良くなる

class Solution {
  func kSmallestPairs(_ nums1: [Int], _ nums2: [Int], _ k: Int) -> [[Int]] {
    guard !nums1.isEmpty && !nums2.isEmpty && k > 0 else { return [] }

    var kSmallestCandiates: Heap<ComparablePair> = []

    for (num1Index, num1) in nums1.enumerated() {
      let pair = ComparablePair(num1Index: num1Index, num2Index: 0, sum: num1 + nums2[0])
      kSmallestCandiates.insert(pair)
    }

    var smallestPairs: [[Int]] = []

    for _ in 0..<k {
      guard let smallestPair = kSmallestCandiates.popMin() else { break }

      let num1Index: Int = smallestPair.num1Index
      let num2Index: Int = smallestPair.num2Index

      smallestPairs.append([nums1[num1Index], nums2[num2Index]])

      let newNum2Index: Int = num2Index + 1

      guard newNum2Index < nums2.count else { continue }

      let pair = ComparablePair(
        num1Index: num1Index,
        num2Index: newNum2Index,
        sum: nums1[num1Index] + nums2[newNum2Index]
      )
      kSmallestCandiates.insert(pair)
    }

    return smallestPairs
  }
}

struct ComparablePair: Comparable {
  let num1Index: Int
  let num2Index: Int
  let sum: Int

  static func < (lhs: ComparablePair, rhs: ComparablePair) -> Bool {
    return lhs.sum < rhs.sum
  }
}

// Step 2:
// 他の人のコードを読む
//
// https://github.com/Yoshiki-Iwasa/Arai60/pull/9/files#diff-911dbcaf9231de51eb4685fb3e690b3584a9cd21c478e732ee7c5b1bcf528eb7
// 最初に nums1 の要素を全て網羅するのではなく、nums[0], nums[0] のペアを入れた後に、
// その時点で最小と判定されたペアの位置の右と下のペアを入れていく方法。右と下で入れていく時に、重複があり得るため、Set を使用する。
// 個人的には、最初に nums1 の要素を全て網羅してしまう方法の方が、考えることが少なくて好み。
//
// https://github.com/Yoshiki-Iwasa/Arai60/pull/9#discussion_r1647019606
// > (0, 0) のみを入れて、pop したものに対して、その下と右を入れる、ただ、その入れるものの、上と左がすでに出てきていなければ、入れる必要ないですね。
// > これを実現するためには、set を使うか、そうでなければ、
// > 「i 列目は次何を出すかを入れる配列、j 行目は次何を出すかを入れる配列をそれぞれ用意して、両方とも次に出すやつだったら (i, j) 出せますね。」
// なるほどー、確かにSet でなくても配列で縦、横別々に管理する方法もあるか。ただ、Set の方が一つで管理できるためわかりやすいと感じる。
//
// https://github.com/TORUS0818/leetcode/pull/12#discussion_r1703339056
// > うーん、いや、また別の側面から話しますが、なんか旅行でも文化祭でも仕事でも道案内でも、なんでもいいんですが複数人で何かをするときに、自然言語ではどう説明してますか。
// > 大きな目的や全体像は伝えて、それから個々の部分は局所的に分かるようにしますよね。これを足がかりに追加情報を小出しにしていって全体像を伝えます。
// 少し本筋から離れるが「関数化」って、全体像を先に伝えて、それから詳細を伝えるという役割もあるか。だから、関数化をすると読みやすいのか。
//
// 個人的には、「2次元の表だと考えて、最初の列をheapに入れれば、後は行方向のみ考えれば良くなる」の手法が一番しっくりくるので、それで書く。
// 以下の変数名がわかりづらいと感じるため、修正した。
// ComparablePair -> IndexedPair: ComparablePair は比較可能と書いているだけで、なんのペアなのかを明示していない。インデックス化されたペアであることを強調。
// kSmallestCandiates -> smallestPairCandidates: 最小の k 個の候補と読み違えそうなため、最小のペアの候補とした。単なる candidates と書いても良いが、これだと
// コードの先を読まないと、なんの候補であるかが伝わらず、使用するワーキングメモリーが増えると考えたため、単なる candidates の使用は避けた。

class Solution {
  func kSmallestPairs(_ nums1: [Int], _ nums2: [Int], _ k: Int) -> [[Int]] {
    guard !nums1.isEmpty && !nums2.isEmpty && k > 0 else { return [] }

    var smallestPairCandidates: Heap<IndexedPair> = []

    for (num1Index, num1) in nums1.enumerated() {
      let pair = IndexedPair(num1Index: num1Index, num2Index: 0, sum: num1 + nums2[0])
      smallestPairCandidates.insert(pair)
    }

    var smallestPairs: [[Int]] = []

    for _ in 0..<k {
      guard let smallestPair = smallestPairCandidates.popMin() else { break }

      let num1Index: Int = smallestPair.num1Index
      let num2Index: Int = smallestPair.num2Index

      smallestPairs.append([nums1[num1Index], nums2[num2Index]])

      let newNum2Index: Int = num2Index + 1
      guard newNum2Index < nums2.count else { continue }

      let pair = IndexedPair(
        num1Index: num1Index,
        num2Index: newNum2Index,
        sum: nums1[num1Index] + nums2[newNum2Index]
      )
      smallestPairCandidates.insert(pair)
    }

    return smallestPairs
  }
}

struct IndexedPair: Comparable {
  let num1Index: Int
  let num2Index: Int
  let sum: Int

  static func < (lhs: IndexedPair, rhs: IndexedPair) -> Bool {
    return lhs.sum < rhs.sum
  }
}

// Step 3:
// 書いてから感じたが、IndexedPair の pair と、[Int] の pair が入り混じっており、少しわかりづらいような気もした。
// ただ indexedPair とわざわざ書くのは長く冗長でもあると感じたため、そのままにすることにした。
class Solution {
  func kSmallestPairs(_ nums1: [Int], _ nums2: [Int], _ k: Int) -> [[Int]] {
    guard !nums1.isEmpty && !nums2.isEmpty && k > 0 else { return [] }

    var smallestPairCandidates: Heap<IndexedPair> = []

    for (index, num) in nums1.enumerated() {
      let pair = IndexedPair(num1Index: index, num2Index: 0, sum: num + nums2[0])
      smallestPairCandidates.insert(pair)
    }

    var smallestPairs: [[Int]] = []

    for _ in 0..<k {
      guard let smallestPair = smallestPairCandidates.popMin() else { return smallestPairs }

      let num1Index: Int = smallestPair.num1Index
      let num2Index: Int = smallestPair.num2Index

      smallestPairs.append([nums1[num1Index], nums2[num2Index]])

      let newNum2Index = num2Index + 1
      guard newNum2Index < nums2.count else { continue }

      let pair = IndexedPair(
        num1Index: num1Index,
        num2Index: newNum2Index,
        sum: nums1[num1Index] + nums2[newNum2Index]
      )
      smallestPairCandidates.insert(pair)
    }

    return smallestPairs
  }
}

struct IndexedPair: Comparable {
  let num1Index: Int
  let num2Index: Int
  let sum: Int

  static func < (lhs: IndexedPair, rhs: IndexedPair) -> Bool {
    return lhs.sum < rhs.sum
  }
}
