// Step 1
// 手作業でやるとしたらを考えようと思ったけど、手作業で考える方が難しいかもしれない。
// ある家での最大値を考える。
// 状態としては、
// - 今の家で盗む
// - 今の家で盗まない
// の二通りがある。
// 今の家で盗むなら、一つ前の家で盗んでいる場合を除かなければいけないから、二つ前の家までの最大値と今の家で盗んだ値を足した値が、最大値に等しい。
// 今の家で盗まないなら、一つ前までの最大値が、今の家での最大に等しい。
// ある家までの最大値を保存しておけば、上記のように今までの結果を利用して解ける。
// 計算量としては、One pass で O(n). n <= 100 らしいので、0.01ms ぐらいのオーダーで解けるはず。

// bottom up
class Solution {
  int rob(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }
    if (nums.length == 1) {
      return nums[0];
    }

    var maxMoneyAt = List<int>.filled(nums.length, 0);
    maxMoneyAt[0] = nums[0];
    maxMoneyAt[1] = max(nums[0], nums[1]);

    for (var i = 2; i < nums.length; i++) {
      maxMoneyAt[i] = max(maxMoneyAt[i - 1], maxMoneyAt[i - 2] + nums[i]);
    }

    return maxMoneyAt[nums.length - 1];
  }
}

// top down
class Solution {
  int rob(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }

    var maxMoneyAt = List<int?>.filled(nums.length, null);

    int helper(int position) {
      if (position < 0) {
        return 0;
      }
      if (position == 0) {
        maxMoneyAt[position] = nums[0];
        return nums[0];
      }
      if (maxMoneyAt[position] != null) {
        return maxMoneyAt[position]!;
      }

      maxMoneyAt[position] = max(
        helper(position - 1),
        helper(position - 2) + nums[position],
      );
      return maxMoneyAt[position]!;
    }

    return helper(nums.length - 1);
  }
}

// Step 2
// 他の人のコード・コメント集を見る。

// https://github.com/naoto-iwase/leetcode/pull/40/changes#diff-de2393432c5a0b463890b7f868c4dfac5b3329b357b9ada93b26a722beac4a08R101
// 配列ではなく、二変数で済ませる方法。
// せいぜい nums の数が 100 までなどの入力がそこまで大きくない場合は、配列でも特に問題はなさそう。状況にもよると思うが。

// https://github.com/Mike0121/LeetCode/pull/47#discussion_r1799964450
// > functools.lru_cacheを確認しておいて欲しいのと、inner function は定義するたびにオブジェクトとして作り直されていることを確認して欲しいです。
// > このコードはスレッドセーフティーという意味でどうなっているでしょうか。
// 今まで、スレッドセーフティーについては意識できていなかった。Claude に何を気をつければいいかを聞いてみた。
// 長いが一応全文を載せておく。データベースのトランザクションとかの話とだいぶ近い。

// ## スレッドセーフティで気にすべきこと
// 根本的な問いは「**複数のスレッドが同時に同じデータを触ったとき、おかしなことが起きないか**」です。
// ### 1. Race Condition（競合状態）
// 最も典型的な問題です。例えば「残高を読む → 計算する → 書き戻す」という3ステップの間に別スレッドが割り込むと、更新が消えたりします。
// ```
// スレッドA: 残高100を読む → 100+50=150を書く
// スレッドB: 残高100を読む → 100-30=70を書く
// 結果: 70（Aの+50が消えた）
// ```
// ### 2. Atomicity（原子性）
// ある操作が途中で割り込まれないかどうか。上の例では「読んで書く」が原子的でないことが原因です。言語やCPUレベルで何が原子的かは環境依存なので、自分で仮定しないことが大事です。
// ### 3. Visibility（可視性）
// あるスレッドが書いた値が、別のスレッドからいつ見えるか。CPUキャッシュやコンパイラの最適化によって、書き込みが他のスレッドにすぐ反映されないことがあります。JavaのvolatileやメモリバリアはこれをThe対処するための仕組みです。
// ### 4. Ordering（順序）
// コンパイラやCPUは命令を並べ替えることがあります。単一スレッドでは問題になりませんが、マルチスレッドでは「Aの後にBが実行された」という前提が崩れることがあります。
// ### 基本的な対策
// - **共有しない**: スレッドごとに独立したデータを持つのが最強。イミュータブルなデータも安全
// - **Lock / Mutex**: 共有する場合はロックで排他制御する
// - **スレッドセーフなデータ構造**: `ConcurrentHashMap`、`queue.Queue` など、言語が提供するものを使う
// - **できるだけ高レベルな抽象化を使う**: 自分でロックを細かく制御するよりも、Actor モデルやチャネルベースの通信（Goのgoroutine + channel など）の方がバグりにくい

// 二変数の方法でも書いておく
// もう少しいい命名がある気がするが、思いつかなかった。
class Solution {
  int rob(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }
    if (nums.length == 1) {
      return nums[0];
    }

    var maxGainUpToPrevious = nums[0];
    var maxGainUpToCurrent = max(nums[0], nums[1]);

    for (var i = 2; i < nums.length; i++) {
      var maxGain = max(maxGainUpToPrevious + nums[i], maxGainUpToCurrent);
      maxGainUpToPrevious = maxGainUpToCurrent;
      maxGainUpToCurrent = maxGain;
    }

    return maxGainUpToCurrent;
  }
}

// Step 3
class Solution {
  int rob(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }
    if (nums.length == 1) {
      return nums[0];
    }

    var maxGainUpToPrevious = nums[0];
    var maxGainUpToCurrent = max(nums[0], nums[1]);

    for (var i = 2; i < nums.length; i++) {
      var maxGain = max(maxGainUpToPrevious + nums[i], maxGainUpToCurrent);
      maxGainUpToPrevious = maxGainUpToCurrent;
      maxGainUpToCurrent = maxGain;
    }

    return maxGainUpToCurrent;
  }
}
