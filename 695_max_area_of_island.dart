// Step 1:
// 手作業でやる場合を考える。
// 大まかな流れとしては、
// 1. 島を見つける
// 2. 各島の大きさを計算する。現状の最大値より大きければ、最大値を更新
// 3. 最大の大きさを出力する。
// といった形。
// 島を見つけるには、一マスずつ走査していけばいいし、
// 島の大きさを計算するには、land が見つかったタイミングでその land と連結している部分を繰り返し足していけばいい。
// Number of Island と同様に BFS でやっていけばいい。
// grid の縦横は 50 × 50 が最大なので、最大の計算時間は大体 2.5 * 10^3 / 10^4 = 0.25 ms ぐらい。
// 計算時間は大丈夫そう。
// Union Find で、連結要素が増えたときに島の大きさの最大値を増やしていくという手法でもできるけど、
// 実装が面倒なので Step 1 ではやらない。
import 'dart:collection';
import 'dart:math';

class SolutionBFSTuple {
  static const int land = 1;
  static const int water = 0;

  int maxAreaOfIsland(List<List<int>> grid) {
    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    var seenLands = <(int, int)>{};
    var maxArea = 0;

    bool isLand(int row, int col) {
        final isValidRow = (0 <= row && row < grid.length);
        final isValidCol = (0 <= col && col < grid[0].length);
        return isValidRow && isValidCol && grid[row][col] == land;
    }

    int calcAreaOfIsland(int startRow, int startCol) {
      // もし water が入ってきてもいいように最初に処理。 
      if (!isLand(startRow, startCol)) {
        return 0;
      }

      var landsToTraverse = Queue.of([(startRow, startCol)]);
      seenLands.add((startRow, startCol));
      var area = 1;
      final offsets = [
        (1, 0),
        (0, 1),
        (-1, 0),
        (0, -1)
      ];

      while (!landsToTraverse.isEmpty) {
        final land = landsToTraverse.removeFirst();
        final row = land.$1;
        final col = land.$2;

        for (var offset in offsets) {
            final newRow = row + offset.$1;
            final newCol = col + offset.$2;

            if (!isLand(newRow, newCol) || seenLands.contains((newRow, newCol))) {
                continue;
            }

            seenLands.add((newRow, newCol));
            landsToTraverse.add((newRow, newCol));
            area++;
        }
      }

      return area;
    }

    for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
            final place = grid[row][col];

            if (place == water || seenLands.contains((row, col))) {
                continue;
            }

            final area = calcAreaOfIsland(row, col);
            maxArea = max(area, maxArea);
        }
    }

    return maxArea;
  }
}

// Step 2
// 他の人の回答、コードを見る
// まずは LLM に改善案を聞いてみる
// 1. Set で重複判定ではなく、in-place でland を water に置き換えれば、必要なメモリの削減になるよ
// 2. タプルの生成でオブジェクト生成のコストがかかるから、row * cols + col とかで管理すれば？
// 1に関しては、in-place にすると2度と走査できなくなるため、個人的には避けたい。また、仕様に合わせて柔軟に変えれば良い。
// 2に関しては、速度にどれぐらいの違いがあるのかを実際に計算してみる。
//
// 他の人のコードを見る。
// https://github.com/akmhmgc/arai60/pull/15/changes#r2347265871
// 再帰で書いてみる方法。スッキリしていてわかりやすい。
// ただ、Dart では末尾最適化がされないため、再帰を行うときには注意。
// LLM に聞いてみたところ、Dart Web だと 10000 ~ 20000 ぐらい。
// Dart Native だと 20000 ~ 80000ぐらい (OSに依存)らしい。
// 300 × 300 などにも grid はなってもおかしくないため、再帰で書くのはやめた方が良い。
//
// https://github.com/naoto-iwase/leetcode/pull/18/changes#r2425067552
// > コマンドクエリ分離の考え方にもとづき
// >   - 返り値があるなら副作用を持たない
// >   - 副作用があるなら返り値を返さない(Noneにする)
// > という風に設計してもよいかと思いました。
// コマンドクエリ分離という考え方を初めて知った。
//
// 計測時間
// | Grid Size   | BFS Tuple (ms) | BFS (ms)      | Union Find (ms) |
// |-------------|----------------|---------------|-----------------|
// | 10 x 10     |        0.00379 |       0.00261 |         0.00169 |
// | 100 x 100   |        0.36062 |       0.29893 |         0.14390 |
// | 300 x 300   |        4.48944 |       3.35543 |         1.96879 |
//
// タプルより、int で管理した方が多少速度が速いが、それほど大きな差はないため、
// 実装上のわかりやすさを優先して、タプルで管理した方が良さそう。
// 計算時間的には、自分が思っている半分以下の時間で終わっていた。オーダーはあってた。
//
// タプルではなく、row * cols + col で seen を管理してみたやつ。
class SolutionBFS {
  static const int land = 1;
  static const int water = 0;

  int maxAreaOfIsland(List<List<int>> grid) {
    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    var seenLandKeys = <int>{};
    var maxArea = 0;
    final columnLength = grid[0].length;

    bool isLand(int row, int col) {
        final isValidRow = (0 <= row && row < grid.length);
        final isValidCol = (0 <= col && col < grid[0].length);
        return (isValidRow && isValidCol && grid[row][col] == land);
    }

    int calcAreaOfIsland(int startRow, int startCol) {
        if (!isLand(startRow, startCol)) {
            return 0;
        }

        var landsToTraverse = Queue.of([(startRow, startCol)]);
        seenLandKeys.add(startRow * columnLength + startCol);
        var area = 0;
        var offsets = [
            (1, 0),
            (0, 1),
            (-1, 0),
            (0, -1)
        ];
        
        while (!landsToTraverse.isEmpty) {
            final point = landsToTraverse.removeFirst();
            final row = point.$1;
            final col = point.$2;
            area++;

            for (var offset in offsets) {
                final newRow = row + offset.$1;
                final newCol = col + offset.$2;
                final newLandKey = newRow * columnLength + newCol;

                if (!isLand(newRow, newCol) || seenLandKeys.contains(newLandKey)) {
                    continue;
                }

                seenLandKeys.add(newLandKey);
                landsToTraverse.add((newRow, newCol));
            }
        }

        return area;
    }

    for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
            final landKey = row * columnLength + col;
            
            if (grid[row][col] == water || seenLandKeys.contains(landKey)) {
                continue;
            }

            var area = calcAreaOfIsland(row, col);
            maxArea = max(maxArea, area);
        }
    }

    return maxArea;
  }
}

// Union Find でも一応実装する。
class SolutionUnionFind {
  static const int land = 1;
  static const int water = 0;

  int maxAreaOfIsland(List<List<int>> grid) {
    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    final columnLength = grid[0].length;
    var maxArea = 0;
    var islands = UnionFind(grid.length * grid[0].length);
    var offsets = [
        (1, 0),
        (0, 1),
        (-1, 0),
        (0, -1)
    ];

    bool isLand(int row, int col) {
        final isValidRow = (0 <= row && row < grid.length);
        final isValidCol = (0 <= col && col < grid[0].length);
        return (isValidRow && isValidCol && grid[row][col] == land);
    }

    for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
            if (grid[row][col] == water) {
                continue;
            }

            final key = row * columnLength + col;
            maxArea = max(maxArea, islands.getSize(key));

            for (var offset in offsets) {
                var newRow = row + offset.$1;
                var newCol = col + offset.$2;
                final newKey = newRow * columnLength + newCol;

                if (!isLand(newRow, newCol)) {
                    continue;
                }

                islands.union(key, newKey);
                var area = islands.getSize(newKey);
                maxArea = max(maxArea, area);
            }
        }
    }

    return maxArea;
  }
}

class UnionFind {
  List<int> _parents;
  List<int> _sizes;

  UnionFind(int num) 
    : _parents = List.generate(num, (i) => i),
      _sizes = List.filled(num, 1);

  void union(int key1, int key2) {
    var smaller = find(key1);
    var larger = find(key2);

    if (smaller == larger) {
        return;
    }

    if (_sizes[smaller] > _sizes[larger]) {
        final tmp = smaller;
        smaller = larger;
        larger = tmp;
    }

    _parents[smaller] = larger;
    _sizes[larger] += _sizes[smaller];
    _sizes[smaller] = _sizes[larger];
  }

  int find(int key) {
    if (key == _parents[key]) {
        return key;
    }

    _parents[key] = find(_parents[key]);
    return _parents[key];
  }

  int getSize(int key) {
    return _sizes[find(key)];
  }
}

// Step 3:
class Solution {
  static const int land = 1;
  static const int water = 0;

  int maxAreaOfIsland(List<List<int>> grid) {
    if (grid.isEmpty || grid[0].isEmpty) {
        return 0;
    }

    var seenLands = <(int, int)>{};
    var maxArea = 0;

    bool isLand(int row, int col) {
        final isValidRow = (0 <= row && row < grid.length);
        final isValidCol = (0 <= col && col < grid[0].length);
        return isValidRow && isValidCol && grid[row][col] == land;
    }

    int calcAreaOfIsland(int startRow, int startCol) {
        if (!isLand(startRow, startCol)) {
            return 0;
        }

        var landsToTraverse = Queue.of([(startRow, startCol)]);
        seenLands.add((startRow, startCol));
        var area = 0;
        final offsets = [
            (1, 0),
            (0, 1),
            (-1, 0),
            (0, -1)
        ];

        while (!landsToTraverse.isEmpty) {
            var (row, col) = landsToTraverse.removeFirst();
            area++;

            for (var offset in offsets) {
                var newRow = row + offset.$1;
                var newCol = col + offset.$2;

                if(!isLand(newRow, newCol) || seenLands.contains((newRow, newCol))) {
                    continue;
                }

                landsToTraverse.add((newRow, newCol));
                seenLands.add((newRow, newCol));
            }

        }

        return area;
    }

    for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
            if (grid[row][col] != land || seenLands.contains((row, col))) {
                continue;
            }

            var area = calcAreaOfIsland(row, col);
            maxArea = max(maxArea, area);
        }
    }

    return maxArea;
  }
}


// 計算時間を出力するためのコード
void main() {
  final solutionBFSTuple = SolutionBFSTuple();
  final solutionBFS = SolutionBFS();
  final solutionUnionFind = SolutionUnionFind();
  final sizes = [10, 100, 300];
  const iterations = 10000;

  print('計測開始 (各サイズ $iterations 回ループして平均を算出)...\n');
  print('| Grid Size   | BFS Tuple (ms) | BFS (ms)      | Union Find (ms) |');
  print('|-------------|----------------|---------------|-----------------|');

  for (final n in sizes) {
    final grid = generateGrid(n, n, density: 0.2); 

    // BFS Tuple の計測
    for(var i=0; i<5; i++) solutionBFSTuple.maxAreaOfIsland(grid);
    final stopwatchBFSTuple = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionBFSTuple.maxAreaOfIsland(grid);
    }
    stopwatchBFSTuple.stop();
    final avgBFSTuple = (stopwatchBFSTuple.elapsedMicroseconds / iterations / 1000.0).toStringAsFixed(5);

    // BFS の計測
    for(var i=0; i<5; i++) solutionBFS.maxAreaOfIsland(grid);
    final stopwatchBFS = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionBFS.maxAreaOfIsland(grid);
    }
    stopwatchBFS.stop();
    final avgBFS = (stopwatchBFS.elapsedMicroseconds / iterations / 1000.0).toStringAsFixed(5);

    // Union Find の計測
    for(var i=0; i<5; i++) solutionUnionFind.maxAreaOfIsland(grid);
    final stopwatchUnionFind = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      solutionUnionFind.maxAreaOfIsland(grid);
    }
    stopwatchUnionFind.stop();
    final avgUnionFind = (stopwatchUnionFind.elapsedMicroseconds / iterations / 1000.0).toStringAsFixed(5);

    final sizeStr = '$n x $n';
    print('| ${sizeStr.padRight(11)} | ${avgBFSTuple.padLeft(14)} | ${avgBFS.padLeft(13)} | ${avgUnionFind.padLeft(15)} |');
  }
}

List<List<int>> generateGrid(int rows, int cols, {double density = 0.5}) {
  final rng = Random();
  return List.generate(rows, (_) {
    return List.generate(cols, (_) {
      return rng.nextDouble() < density ? 1 : 0;
    });
  });
}
