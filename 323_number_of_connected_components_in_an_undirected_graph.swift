// Step 1
// Dart がなかったため、今回は Swift で書く。
// 手作業でやる場合を考える。
// 手作業でやるなら、とりあえず、edges に書いてある連結をすべて繋いでしまう。
// そのあと、目視で何個の独立しているものがあるかを確認できるから、その数をいう。
// ただ、コンピュータで目視は無理だから（実際には人間も複雑なシステムが裏側で動いていると思うが）、どうするか考える。
// 一つの独立しているものを連結し終えたら、１増やしていけばいい。
//
// 連結を全て繋ぐには、どのような手法があるかを考える。
// 今回の場合は、個人的に Union Find がイメージがつきやすいかも。
// edges が連結のルールブックで、それを見ながら繋げていけば良い。
//
// DFS, BFSでやってもいい。
// DFS の場合は、手持ちのノードに新たなノードを繋げたら、手持ちを繋げたノードに置き換えて、それを繰り返してどんどん繋げていく。
// BFS は、手持ちのノードにつながるやつを全部つけてから、次のノードに持ちかえる。みたいなイメージ。
// 速さを一応確認。
// 条件としては edges が 5000 まで。
// Swift が 2 * 10^4 steps/ms で動くとして、繋げる動作が最大で 5000 だから、5000 /  (2 * 10^4) = 0.25 ms.
// DFS, BFS, Union Find どれも O(n) だからこれぐらいで動く。Union Find が今までの経験上最速。
// まあ今回はそこまで条件厳しくなさそうだから簡単な DFS で書く。
//
// 書いている最中に思ったが、元々の edges からだとそのノードからどのノードに繋がっているかの一覧がないから
// BFS, DFS の作業をするのが、困難になる。
// それ用の表を作成する。確か、隣接リストみたいな名前がついていた気がする。

// 計測用のmain関数
import Foundation

// 下記を書きましたが、通らないテストケースありです。
class Solution {
  func countComponents(_ n: Int, _ edges: [[Int]]) -> Int {
    var componentsCount: Int = 0
    var seenNodes: Set<Int> = []
    let adjacencyList: [[Int]] = createAdjacencyList(from: edges, nodesCount: n)

    for node in 0..<n {
      guard !seenNodes.contains(node) else {
        continue
      }

      connectEdges(from: node, using: adjacencyList, &seenNodes)
      componentsCount += 1
    }

    return componentsCount
  }

  func createAdjacencyList(from edges: [[Int]], nodesCount: Int) -> [[Int]] {
    let expectedEdgeCount: Int = 2
    var adjacencyList: [[Int]] = Array(repeating: [], count: nodesCount)

    for edge in edges {
      guard edge.count == expectedEdgeCount else {
        assertionFailure("Invalid edge count")
        continue
      }

      let smaller = min(edge[0], edge[1])
      let larger = max(edge[0], edge[1])

      adjacencyList[smaller].append(larger)
    }

    return adjacencyList
  }

  private func connectEdges(
    from node: Int, using adjacencyList: [[Int]], _ seenNodes: inout Set<Int>
  ) {
    var nodesToConnect: [Int] = adjacencyList[node]
    seenNodes.insert(node)

    while !nodesToConnect.isEmpty {
      let nodeToConnect = nodesToConnect.removeLast()

      guard !seenNodes.contains(nodeToConnect) else {
        continue
      }

      nodesToConnect.append(contentsOf: adjacencyList[nodeToConnect])
      seenNodes.insert(nodeToConnect)
    }
  }
}

// Step 2
// 隣接リストは双方向である必要があった。
// 単方向であると、[[2,0], [2,1]]などの場合に、0,1が2を通してつながっていない判定になってしまっていた。
//
// 他の人のコードを読む
//
// https://github.com/naoto-iwase/leetcode/pull/28/changes#diff-4f6b01b75cf61fa706e6463e0a6840a6a0685f9f0cfcc46cc7dfb3530e908b18R123
// Union Find の高速化まとめ。参考になる。
//
// コメント集はなかった。まあ、前の二問とかなりやっていることが同じではある。
//
// あとはいつものごとく、Union Find でも実装してみる。
//
// 計算時間の確認
// | Node Count | BFS (ms)      | Union Find (ms) |
// |------------|---------------|-----------------|
// |         10 |       0.01381 |         0.00992 |
// |        100 |       0.39340 |         0.40769 |
// |        300 |       2.37000 |         3.10349 |
//
// いつもは Union Find の方が速いが、今回は BFS の方が速い。

// 動くバージョンを書いたもの
class SolutionBFS {
  func countComponents(_ n: Int, _ edges: [[Int]]) -> Int {
    var componentsCount: Int = 0
    var seenNodes: Set<Int> = []
    let adjacencyList: [[Int]] = createAdjacencyList(from: edges, nodesCount: n)

    for node in 0..<n {
      guard !seenNodes.contains(node) else {
        continue
      }

      connectEdges(from: node, using: adjacencyList, &seenNodes)
      componentsCount += 1
    }

    return componentsCount
  }

  func createAdjacencyList(from edges: [[Int]], nodesCount: Int) -> [[Int]] {
    let expectedEdgeCount: Int = 2
    var adjacencyList: [[Int]] = Array(repeating: [], count: nodesCount)

    for edge in edges {
      guard edge.count == expectedEdgeCount else {
        assertionFailure("Invalid edge count")
        continue
      }

      let node1 = edge[0]
      let node2 = edge[1]

      adjacencyList[node1].append(node2)
      adjacencyList[node2].append(node1)
    }

    return adjacencyList
  }

  private func connectEdges(
    from node: Int, using adjacencyList: [[Int]], _ seenNodes: inout Set<Int>
  ) {
    var nodesToConnect: [Int] = adjacencyList[node]
    seenNodes.insert(node)

    while !nodesToConnect.isEmpty {
      let nodeToConnect = nodesToConnect.removeLast()

      guard !seenNodes.contains(nodeToConnect) else {
        continue
      }

      for node in adjacencyList[nodeToConnect] {
        guard !seenNodes.contains(node) else {
          continue
        }

        nodesToConnect.append(node)
        seenNodes.insert(node)
      }
    }
  }
}

// Union Find
// 今回は、Union Find の方がしっくりくる。グラフを繋げていく動作が、Union Find の方が自分のイメージに近いからだと思う。
class UnionFind {

  private var parents: [Int]
  private var sizes: [Int]
  private(set) var groupCount: Int

  init(_ num: Int) {
    parents = Array(0..<num)
    sizes = Array(repeating: 1, count: num)
    groupCount = num
  }

  public func union(_ key1: Int, _ key2: Int) {
    let parent1 = find(key1)
    let parent2 = find(key2)

    guard parent1 != parent2 else {
      return
    }

    let smaller: Int
    let larger: Int

    (smaller, larger) = sizes[parent1] < sizes[parent2] ? (parent1, parent2) : (parent2, parent1)

    parents[smaller] = larger
    sizes[larger] += sizes[smaller]
    sizes[smaller] = sizes[larger]
    groupCount -= 1
  }

  public func find(_ key: Int) -> Int {
    guard parents[key] != key else {
      return key
    }

    parents[key] = find(parents[key])
    return parents[key]
  }
}

class SolutionUnionFind {
  func countComponents(_ n: Int, _ edges: [[Int]]) -> Int {
    let expectedEdgeCount = 2
    let connectedComponents = UnionFind(n)

    for edge in edges {
      guard edge.count == expectedEdgeCount else {
        assertionFailure("Invalid edge count")
        continue
      }

      let node1 = edge[0]
      let node2 = edge[1]

      connectedComponents.union(node1, node2)
    }

    return connectedComponents.groupCount
  }
}

// Step 3
class Solution {
  func countComponents(_ n: Int, _ edges: [[Int]]) -> Int {
    let expectedEdgeCount = 2
    var connectedComponents = UnionFind(n)

    for edge in edges {
      guard edge.count == expectedEdgeCount else {
        assertionFailure("Invalid edge count")
        continue
      }

      let node1 = edge[0]
      let node2 = edge[1]

      connectedComponents.union(node1, node2)
    }

    return connectedComponents.groupCount
  }
}

// 計測用のグラフ生成関数
func generateGraph(_ n: Int, density: Double) -> [[Int]] {
  var edges: [[Int]] = []
  var edgeSet: Set<String> = []

  let maxEdges = n * (n - 1) / 2
  let targetEdges = Int(Double(maxEdges) * density)

  while edges.count < targetEdges && edgeSet.count < maxEdges {
    let node1 = Int.random(in: 0..<n)
    var node2 = Int.random(in: 0..<n)

    // 自己ループを避ける
    while node2 == node1 {
      node2 = Int.random(in: 0..<n)
    }

    // 重複エッジを避ける
    let edgeKey1 = "\(min(node1, node2))-\(max(node1, node2))"
    if !edgeSet.contains(edgeKey1) {
      edges.append([node1, node2])
      edgeSet.insert(edgeKey1)
    }
  }

  return edges
}

func main() {
  let solutionBFS = SolutionBFS()
  let solutionUnionFind = SolutionUnionFind()
  let sizes = [10, 100, 300]
  let iterations = 10000

  print("計測開始 (各サイズ \(iterations) 回ループして平均を算出)...\n")
  print("| Node Count | BFS (ms)      | Union Find (ms) |")
  print("|------------|---------------|-----------------|")

  for n in sizes {
    let edges = generateGraph(n, density: 0.2)

    // BFS のウォームアップ
    for _ in 0..<5 {
      _ = solutionBFS.countComponents(n, edges)
    }

    // BFS の計測
    let startBFS = CFAbsoluteTimeGetCurrent()
    for _ in 0..<iterations {
      _ = solutionBFS.countComponents(n, edges)
    }
    let elapsedBFS = CFAbsoluteTimeGetCurrent() - startBFS
    let avgBFS = String(format: "%.5f", (elapsedBFS * 1000.0) / Double(iterations))

    // Union Find のウォームアップ
    for _ in 0..<5 {
      _ = solutionUnionFind.countComponents(n, edges)
    }

    // Union Find の計測
    let startUnionFind = CFAbsoluteTimeGetCurrent()
    for _ in 0..<iterations {
      _ = solutionUnionFind.countComponents(n, edges)
    }
    let elapsedUnionFind = CFAbsoluteTimeGetCurrent() - startUnionFind
    let avgUnionFind = String(format: "%.5f", (elapsedUnionFind * 1000.0) / Double(iterations))

    let sizeStr = String(format: "%10d", n)
    let avgBFSStr = String(repeating: " ", count: max(0, 13 - avgBFS.count)) + avgBFS
    let avgUnionFindStr =
      String(repeating: " ", count: max(0, 15 - avgUnionFind.count)) + avgUnionFind
    print("| \(sizeStr) | \(avgBFSStr) | \(avgUnionFindStr) |")
  }
}

// 実行
main()
