// Step 1
// 前回と同様に、ロボットが「右」か「下」かにしか移動ができないので、
// ある位置の「経路数」= 左からの「経路数」+ 上からの「経路数」で求められる。
// 石がある位置は、経路数の更新を行わず、常に 0 としておけば、石がある場所からの経路も増えないため、これで問題ない。

// 最初に書いて間違えたやつ。Wrong Answer。
// 境界線上にいる場合で、row = 0 の場合は、それより左に石がある場合、col = 0 の場合に、それより上に石がある場合には、
// ロボットが上や左にはいけないため、そこにたどり着くことはできない。
// 純粋に、横着せずに左からの経路数と上からの経路数を足さなければならない。
// ただし、最初の位置は例外的に処理をする必要あり。初期位置の左と上はどちらも経路数は必ず 0 であるため。
class Solution {
  static const obstacle = 1;

  int uniquePathsWithObstacles(List<List<int>> obstacleGrid) {
    if (obstacleGrid.isEmpty || obstacleGrid[0].isEmpty) {
      throw Exception("input should not be empty.");
    }

    final rows = obstacleGrid.length;
    final cols = obstacleGrid[0].length;

    var uniquePathsCount = List.generate(
      rows,
      (_) => List<int>.filled(cols, 0),
    );

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (obstacleGrid[row][col] == obstacle) {
          continue;
        }
        if (row == 0 || col == 0) {
          uniquePathsCount[row][col] = 1;
          continue;
        }

        uniquePathsCount[row][col] =
            uniquePathsCount[row - 1][col] + uniquePathsCount[row][col - 1];
      }
    }

    return uniquePathsCount[rows - 1][cols - 1];
  }
}

// 修正したもの
class Solution {
  static const obstacle = 1;

  int uniquePathsWithObstacles(List<List<int>> obstacleGrid) {
    if (obstacleGrid.isEmpty || obstacleGrid[0].isEmpty) {
      throw Exception("input should not be empty.");
    }

    final rows = obstacleGrid.length;
    final cols = obstacleGrid[0].length;
    if (obstacleGrid[0][0] == obstacle ||
        obstacleGrid[rows - 1][cols - 1] == obstacle) {
      return 0;
    }

    var uniquePathsCount = List.generate(
      rows,
      (_) => List<int>.filled(cols, 0),
    );
    uniquePathsCount[0][0] = 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (obstacleGrid[row][col] == obstacle || (row == 0 && col == 0)) {
          continue;
        }

        final pathsFromLeft = col == 0 ? 0 : uniquePathsCount[row][col - 1];
        final pathsFromTop = row == 0 ? 0 : uniquePathsCount[row - 1][col];

        uniquePathsCount[row][col] = pathsFromLeft + pathsFromTop;
      }
    }

    return uniquePathsCount[rows - 1][cols - 1];
  }
}

// Step 2
// 他の人のコード・コメント集を読む
// https://github.com/garunitule/coding_practice/pull/34/changes#diff-79463779f4419708dbe72bb4f7c983ec1f5f23e4b0b99995639bc6b48285880aR25
// > 障害物が出てくるまで1を追加、出てきたら残りを0で埋めてbreak
// 初期配列の作成の工夫が面白い。
//
// https://github.com/nanae772/leetcode-arai60/pull/33/changes#diff-b402852f4da5a317c585777f3dcf33ff908ae0e32b061603188a507741adaa5eR28
// > 配る DP
// ある意味、「貰う DP」との違いはどの人に焦点を当てているかだけの違いな気がする。

// https://github.com/naoto-iwase/leetcode/pull/39/changes#diff-042c78470386ca298406a9bced08a518d6a43ef689bdbd6c52798b73e13d5f8bR55
// top down の手法
// > 答えが0になるあらゆるパターンでearly returnになることに気づき、top-downの優れている点だと感じた。
// 確かに、二次元配列だと毎回最後まで処理をする必要があるが、答えが 0 になる場合は、top-down の方が早く終わる。
// 再帰の深さ的には、row + col - 2 までいく可能性があるから、そこでスタックオーバーフローになる可能性があるかの注意はすべき。

// https://github.com/mamo3gr/arai60/pull/32/changes#diff-627cf394e4cf4a14ec918b793631f02d2153f00aad733491b99fc4a879e2a066R20
// > upper_cell = unique_paths[col]
// 一次元配列で解く時に、変数を置くことでわかりやすくしている。
// 好みは分かれそうだが、個人的にはこちらのように変数をおいてあげる方が、将来みたときにコードの意味が分かりやすそうで好み。

// top down(メモ化 + 再帰)
class Solution {
  static const obstacle = 1;

  int uniquePathsWithObstacles(List<List<int>> obstacleGrid) {
    if (obstacleGrid.isEmpty || obstacleGrid[0].isEmpty) {
      throw Exception("input should not be empty.");
    }

    final rows = obstacleGrid.length;
    final cols = obstacleGrid[0].length;
    if (obstacleGrid[0][0] == obstacle ||
        obstacleGrid[rows - 1][cols - 1] == obstacle) {
      return 0;
    }

    var uniquePathsCount = List.generate(
      rows,
      (_) => List<int?>.filled(cols, null),
    );
    uniquePathsCount[0][0] = 1;

    int uniquePaths(int row, int col) {
      if (row < 0 || row >= rows || col < 0 || col >= cols) {
        return 0;
      }
      if (obstacleGrid[row][col] == obstacle) {
        uniquePathsCount[row][col] = 0;
        return 0;
      }
      if (uniquePathsCount[row][col] != null) {
        return uniquePathsCount[row][col]!;
      }

      uniquePathsCount[row][col] =
          uniquePaths(row - 1, col) + uniquePaths(row, col - 1);
      return uniquePathsCount[row][col]!;
    }

    return uniquePaths(rows - 1, cols - 1);
  }
}

// 一次元配列
class Solution {
  static const obstacle = 1;

  int uniquePathsWithObstacles(List<List<int>> obstacleGrid) {
    if (obstacleGrid.isEmpty || obstacleGrid[0].isEmpty) {
      throw Exception("input should not be empty.");
    }

    final rows = obstacleGrid.length;
    final cols = obstacleGrid[0].length;
    if (obstacleGrid[0][0] == obstacle ||
        obstacleGrid[rows - 1][cols - 1] == obstacle) {
      return 0;
    }

    var uniquePathsCount = List<int>.filled(cols, 0);
    uniquePathsCount[0] = 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (obstacleGrid[row][col] == obstacle) {
          uniquePathsCount[col] = 0;
          continue;
        }

        final topCount = uniquePathsCount[col];
        final leftCount = col == 0 ? 0 : uniquePathsCount[col - 1];
        uniquePathsCount[col] = topCount + leftCount;
      }
    }

    return uniquePathsCount[cols - 1];
  }
}

// Step 3
class Solution {
  static const obstacle = 1;

  int uniquePathsWithObstacles(List<List<int>> obstacleGrid) {
    if (obstacleGrid.isEmpty || obstacleGrid[0].isEmpty) {
      throw Exception("input should not be empty.");
    }

    final rows = obstacleGrid.length;
    final cols = obstacleGrid[0].length;
    if (obstacleGrid[0][0] == obstacle ||
        obstacleGrid[rows - 1][cols - 1] == obstacle) {
      return 0;
    }

    var uniquePathsCount = List<int>.filled(cols, 0);
    uniquePathsCount[0] = 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (obstacleGrid[row][col] == obstacle) {
          uniquePathsCount[col] = 0;
          continue;
        }

        final upperCount = uniquePathsCount[col];
        final leftCount = col == 0 ? 0 : uniquePathsCount[col - 1];
        uniquePathsCount[col] = upperCount + leftCount;
      }
    }

    return uniquePathsCount[cols - 1];
  }
}
