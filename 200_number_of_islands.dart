// Step 1
// 手作業でやる場合を考える。
//
// 手作業でやる場合は、パッと上から見て、島がどこら辺にあるかを確認する。
// 繋がっていない、隔離された島の数を数える。などの流れになりそう。
// 繋がっていないかを判定するには、外周を全て確認済みとしておいて、全てが水or端になればそれは一つの島。
// 人間はパッと見で、島がどこにあるかを判定できるが、コンピュータは無理。
// 一つ一つのマスを確認させて、そこがかどうかを判定してもらうしかなさそう。
//
// 流れは以下になる。
// 1. 左上から右にマスをチェックしていく。
// 2. もし、マスが land だった場合、その島がどこまで続くかを確認していく。また、島のカウントを一つ増やす。
// 3. land を確認した場合は、そこのマスは確認済みマークをつけておく。
// 4. 続けてチェックをしていくが、そこが確認済みだった場合はスキップ。
// 5. これが、全てチェックし終わるまで続ける。
// 6. 最終的なカウントを返す。
//
// grid は最大で 300×300 で 9×10^4 ステップぐらい。Dart が 10^7steps/s ぐらいの性能と仮定すると、
// 10^-2/s = 0.01s = 10 ms ぐらいで処理が終わるはず。問題なさそう。
// 空間計算量は、最大で全て島のケースがあり、その場合は全ての「確認済み」データを保存するため、O(N×M) (N: 縦、M: 横)。
// これを改善する方法はありそうだが、とりあえず上の方針で一度解く。
import 'dart:collection';
import 'dart:math';

class Solution {
  int numIslands(List<List<String>> grid) {
    void checkIsland(List<List<String>> grid, int start_row, int start_col, Set<(int, int)> seenIslands) {
        var placesToCheck = Queue<(int, int)>.of([(start_row, start_col)]);

        while (!placesToCheck.isEmpty) {
            var place = placesToCheck.removeFirst();
            var row = place.$1;
            var col = place.$2;

            if (seenIslands.contains(place) || grid[row][col] == '0') {
                continue;
            }

            // 左
            if (col - 1 >= 0) {
                placesToCheck.add((row, col - 1));
            }

            // 右
            if (col + 1 < grid[0].length) {
                placesToCheck.add((row, col + 1));
            } 

            // 下
            if (row + 1 < grid.length) {
                placesToCheck.add((row + 1, col));
            }

            // 上
            if (row - 1 >= 0) {
                placesToCheck.add((row - 1, col));
            }
            
            seenIslands.add((row, col));
        }
    }

    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    var seenIslands = <(int, int)>{};
    var islandCount = 0;

    for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
            if (seenIslands.contains((row, col)) || grid[row][col] == '0') {
                continue;
            }

            checkIsland(grid, row, col, seenIslands);
            islandCount++;
        }
    }

    return islandCount;
  }
}

// Step 2:
// LLM に相談
// - 左や右などを個別に処理せず、directions にまとめた方がいい。DRY 原則。
// 最初からここら辺は書き直せるようにする。
// 
class SolutionBFS {
  int numIslands(List<List<String>> grid) {
    void checkIsland(List<List<String>> grid, int start_row, int start_col, Set<(int, int)> seenIslands) {
        var placesToCheck = Queue<(int, int)>.of([(start_row, start_col)]);
        var directions = [
            (1, 0),
            (-1, 0),
            (0, 1),
            (0, -1)
        ];

        while (!placesToCheck.isEmpty) {
            var place = placesToCheck.removeFirst();
            var row = place.$1;
            var col = place.$2;

            if (seenIslands.contains(place) || grid[row][col] == '0') {
                continue;
            }

            for (var direction in directions) {
                var newRow = row + direction.$1;
                var newCol = col + direction.$2;

                var isValidRow = (0 <= newRow && newRow < grid.length);
                var isValidCol = (0 <= newCol && newCol < grid[0].length);

                if (isValidRow && isValidCol) {
                   placesToCheck.add((newRow, newCol)); 
                }
            }
            
            seenIslands.add((row, col));
        }
    }

    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    var seenIslands = <(int, int)>{};
    var islandCount = 0;

    for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
            if (seenIslands.contains((row, col)) || grid[row][col] == '0') {
                continue;
            }

            checkIsland(grid, row, col, seenIslands);
            islandCount++;
        }
    }

    return islandCount;
  } 
}

// 大体の時間の概算があっているかを確認する。
// | Grid Size   | Avg Time (ms) |
// |-------------|---------------|
// | 10 x 10     |       0.00614 |
// | 100 x 100   |       0.71391 |
// | 300 x 300   |       8.80403 |
// 大体 10ms と予想していたが、おおよそあっていた。
//
// 他の人のコードを読む
//
// https://github.com/akmhmgc/arai60/pull/14/changes#diff-8f4b552352a653109e67c53b16609739ce9ebc36e1c5663fda5ba1c7f8365ed1R24
// '0' を water で表現しておりわかりやすい。water, land の二つぐらいならそれぞれ定義しても良いが、より多く種類があるのであれば何か enum で設定するのが良さそう。
// 拡張性を意識するのであれば、最初から enum にしておくべきか。
//
// https://github.com/nanae772/leetcode-arai60/pull/18/changes#diff-394b6d5b6fbf1f8d32209e5ad9d58387413418caa3aa72aa12d683aef8537ee3R3
// checkIsland という自分の関数の命名に納得がいっていなかったが、traverseIsland としていた。こっちの方が良い！
//
// https://github.com/naoto-iwase/leetcode/pull/17/changes#diff-5c15b5a457745340b0829a41cc85d0ec21654a482447ccb1facec02bdcd5e432R106
// Dart では TLE になっていなかったが、Python では TLE になっていた。Python が Dart の大体100倍遅いから確かにそうなりそう。
// 避けるには、
// > BFSで「キューに入れる時点で訪問済みにしない」実装になっているため、同じセルが複数回キューに積まれるケースが多発します。
// > 格子では同一セルに対して最大4方向から到達し得るので、visited を pop 時に追加すると重複 enqueue が増え、BFSは特にそれが顕在化してTLEになりやすいです。
// > 対策は「push 時に visited に入れる」か「push 時に grid を '0' などで潰す」ことです。
// キューの役割が「landが続いているかチェックすべき場所」といった形なので、確かに先に visited 判定して良さそう。ただ、その場合 visited や seen は少し違和感がある気もする。
//
// https://github.com/nanae772/leetcode-arai60/pull/18/changes#diff-eb2e62c1f3fb01d3b790a2bad80beae6313ed7d3ee98437b4e973f51a374f892R1
// https://discord.com/channels/1084280443945353267/1183683738635346001/1197738650998415500
// https://github.com/ichika0615/arai60/pull/9#discussion_r1954436002
// UnionFind をそもそも知らなかった。調べる。
//
// https://www.youtube.com/watch?v=wU6udHRIkcc (Abdul Bari さんという方の Youtube はいつもわかりやすい印象)
// https://ja.wikipedia.org/wiki/%E7%B4%A0%E9%9B%86%E5%90%88%E3%83%87%E3%83%BC%E3%82%BF%E6%A7%8B%E9%80%A0
// 二次元配列である grid を、扱いやすい形の素集合データ構造に変えていく過程で Union Find を使用する。
// 小学生の頃に時々やっていた「じゃんけん列車」にかなり近い印象を受けた。
// じゃんけんをして先頭を決める部分が Union に当たり、自分の列車の先頭が Find で見つかる親に当たる。現実だと、親と子の関係は双方向の linked list かな。
// 問題も作れそう。
// じゃんけん列車に N人の参加者がいて、じゃんけんの結果を入力として与える。
// 最終的に、ある特定の2人が同じ列車に属しているかを判定せよ、あるいは最終的な列車の数を求めよ、といった問題。
// Union の親を決めるロジックがじゃんけんになる。
//
// Union Find で今回の問題を解いてみる。
class SolutionUnionFind {
  int numIslands(List<List<String>> grid) {
    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    var numberRows = grid.length;
    var numberCols = grid[0].length;

    var places = UnionFind(numberRows * numberCols);
    var numberWaters = 0;

    var offsets = [(1, 0), (0, 1)];

    for (var row = 0; row < numberRows; row++) {
        for (var col = 0; col < numberCols; col++) {
            if (grid[row][col] == '0') {
                numberWaters++;
                continue;
            }

            for (var offset in offsets) {
                var newRow = row + offset.$1;
                var newCol = col + offset.$2;

                if (newRow < numberRows && newCol < numberCols && grid[newRow][newCol] == '1') {
                    places.union(row * numberCols + col, newRow * numberCols + newCol);
                }
            }
        }
    }

    return places.getSetCount() - numberWaters;
  }
}

class UnionFind {
    List<int> _parents;
    List<int> _sizes;
    int _setCount;

    UnionFind(int n)
        : _parents = List.generate(n, (i) => i),
          _sizes = List.generate(n, (i) => 1),
          _setCount = n;

    void union(int x, int y) {
        var rootX = find(x);
        var rootY = find(y);

        if (rootX == rootY) {
            return;
        }

        var smaller = rootX;
        var larger = rootY;

        if ((_sizes[smaller] > _sizes[larger])) {
            var tmp = larger;
            larger = smaller;
            smaller = tmp;
        }

        _parents[smaller] = larger;
        _sizes[larger] = _sizes[smaller] + _sizes[larger];
        _sizes[smaller] = _sizes[larger];

        _setCount--;
    }

    int find(int x) {
        if (_parents[x] == x) {
            return x;
        }

        _parents[x] = (find(_parents[x]));
        return _parents[x];
    }

    int getSetCount() {
        return _setCount;
    }
}

// Step 3:
// DFS を書いていなかったので、DFS で 3回書く。
// ちなみに、それぞれの手法の計測時間は以下。
// 計測開始 (各サイズ 10000 回ループして平均を算出)...
// | Grid Size   | BFS (ms)      | DFS (ms)      | Union Find (ms) |
// |-------------|---------------|---------------|-----------------|
// | 10 x 10     |       0.00699 |       0.00559 |         0.00181 |
// | 100 x 100   |       0.79609 |       0.68011 |         0.07018 |
// | 300 x 300   |       8.88698 |       8.10401 |         1.41394 |
//
// Union Find が最速な理由はハッシュの計算がいらない、２方向で済むなど？完全に理解できていない。

class SolutionDFS {
  int numIslands(List<List<String>> grid) {
    final land = '1';
    final water = '0';

    void traverseIsland(int startRow, int startCol, Set<(int, int)> seenPlaces) {
        var placesToCheck = <(int, int)>[(startRow, startCol)];
        var offsets = [(1, 0), (0, 1), (-1, 0), (0, -1)];

        seenPlaces.add((startRow, startCol));

        while (!placesToCheck.isEmpty) {
            var place = placesToCheck.removeLast();
            var row = place.$1;
            var col = place.$2;

            for (var offset in offsets) {
                var newRow = row + offset.$1;
                var newCol = col + offset.$2;

                var isValidRow = (0 <= newRow && newRow < grid.length);
                var isValidCol = (0 <= newCol && newCol < grid[0].length);

                if (!isValidRow || !isValidCol) {
                    continue;
                }

                if (!seenPlaces.contains((newRow, newCol)) && grid[newRow][newCol] == land) {
                    placesToCheck.add((newRow, newCol));
                    seenPlaces.add((newRow, newCol));
                }
            }
        }
    }

    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    var seenPlaces = <(int, int)>{};
    var placesToCheck = <(int, int)>[];
    var islandCount = 0;

    for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
            if (seenPlaces.contains((row, col)) || grid[row][col] == water) {
                continue;
            }

            traverseIsland(row, col, seenPlaces);
            islandCount++;
        }
    }

    return islandCount;
  }
}

// 以下、計算時間計測のためのコード。

void main() {
  final solutionBFS = SolutionBFS();
  final solutionDFS = SolutionDFS();
  final solutionUnionFind = SolutionUnionFind();
  final sizes = [10, 100, 300];
  const iterations = 10000;

  print('計測開始 (各サイズ $iterations 回ループして平均を算出)...\n');
  print('| Grid Size   | BFS (ms)      | DFS (ms)      | Union Find (ms) |');
  print('|-------------|---------------|---------------|-----------------|');

  for (final n in sizes) {
    final grid = generateGrid(n, n, density: 0.2); 

    // BFS の計測
    for(var i=0; i<5; i++) solutionBFS.numIslands(grid);
    final stopwatchBFS = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionBFS.numIslands(grid);
    }
    stopwatchBFS.stop();
    final avgBFS = (stopwatchBFS.elapsedMicroseconds / iterations / 1000.0).toStringAsFixed(5);

    // DFS の計測
    for(var i=0; i<5; i++) solutionDFS.numIslands(grid);
    final stopwatchDFS = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionDFS.numIslands(grid);
    }
    stopwatchDFS.stop();
    final avgDFS = (stopwatchDFS.elapsedMicroseconds / iterations / 1000.0).toStringAsFixed(5);

    // Union Find の計測
    for(var i=0; i<5; i++) solutionUnionFind.numIslands(grid);
    final stopwatchUnionFind = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionUnionFind.numIslands(grid);
    }
    stopwatchUnionFind.stop();
    final avgUnionFind = (stopwatchUnionFind.elapsedMicroseconds / iterations / 1000.0).toStringAsFixed(5);

    final sizeStr = '$n x $n';
    print('| ${sizeStr.padRight(11)} | ${avgBFS.padLeft(13)} | ${avgDFS.padLeft(13)} | ${avgUnionFind.padLeft(15)} |');
  }
}

List<List<String>> generateGrid(int rows, int cols, {double density = 0.5}) {
  final rng = Random();
  return List.generate(rows, (_) {
    return List.generate(cols, (_) {
      return rng.nextDouble() < density ? '1' : '0';
    });
  });
}