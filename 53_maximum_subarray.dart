// Step 1
// 累積和を使って解けば良いのではと、感じた。
// まず、累積和の配列を一回の走査で作成する。
// 最初の要素に戻り、これまでの最小の累積和、とこれまでの最大の subarray の値を保持しておく。
// 現在の要素を末尾とした　subarray で最大の値を持つのは、その値までの累積和　- これまでの最小の累積和。
// これを、これまでの最大の　subarray の値と比較し、それより大きければ更新すれば良い。
// これが終わったら、これまでの最小の累積和も更新する必要があれば、更新する。
// 計算量としては、O(n)で定数倍はあるが、基本的には　10^5 のオーダー。
// 10^5 / 10^7 = 10^-2 = 0.01 s ぐらいのオーダーでできるはず。問題なし。

class Solution {
  List<int> createPrefixSums(List<int> nums) {
    if (nums.isEmpty) {
      throw Exception("input should not be empty.");
    }

    var prefixSums = <int>[0];
    var total = 0;

    for (var num in nums) {
      total += num;
      prefixSums.add(total);
    }

    return prefixSums;
  }

  int maxSubArray(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }

    final prefixSums = createPrefixSums(nums);
    var maxSubarraySum = nums[0];
    var minPrefixSum = prefixSums[0];

    for (var i = 0; i < nums.length; i++) {
      final prefixSumToNum = prefixSums[i + 1];
      final maxSubarraySumCandidate = prefixSumToNum - minPrefixSum;

      maxSubarraySum = max(maxSubarraySum, maxSubarraySumCandidate);
      minPrefixSum = min(minPrefixSum, prefixSumToNum);
    }

    return maxSubarraySum;
  }
}

// DP で解けるかを考える。
// 例えば、自分を末尾とした最大の subarray の和が、自分の前までわかっていたとしたらどうだろうか。
// 自分の値が正であれ、負であれ、とりあえず自分はその最大の和に値を足して、自分自身の値と、その値がどちらが大きいかを比較するだけ。
// そして、自分の「自分を末尾とした最大の subarray の和」を追加して、次の人に引き継げばいい。
// 引き継ぎの際に、これまでの subarray の和の最大も引き継げば、最後の人が終わった段階で、subarray の和の最大が求まる。
class Solution {
  int maxSubArray(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }

    var maxSubarraySumsByTail = <int>[];
    var maxSubArraySum = nums[0];

    for (var tail = 0; tail < nums.length; tail++) {
      if (maxSubarraySumsByTail.isEmpty) {
        maxSubarraySumsByTail.add(nums[tail]);
        continue;
      }

      final priorSubarraySum = maxSubarraySumsByTail[tail - 1];
      final subarraySum = max(nums[tail], priorSubarraySum + nums[tail]);
      maxSubarraySumsByTail.add(subarraySum);
      maxSubArraySum = max(maxSubArraySum, subarraySum);
    }

    return maxSubArraySum;
  }
}

// Step 2
// 他の人のコード・コメント集を読む。
//
// https://github.com/nanae772/leetcode-arai60/pull/31/changes#r2409367929
// > Kadaneは自然なdpからやれば出てくる気がした。dp[i] = (iで終わる連続部分配列の最大和)とすれば
// > - dp[i] = max(dp[i - 1] + nums[i], nums[i])
// > - 最終的な答えはmax(dp)
// > と考えられて、よく見るとdp[i]を計算するときにdp[i-1]しか使ってないので適当な変数にすると
// > Kadane's algorithmになる。
// > そうですね。
// > prefix_sum - min_prefix_sum を整理してもこれになります。
// 確かに結局一つ前しか使っていないから、配列として保存する必要なかった。

// https://github.com/naoto-iwase/leetcode/pull/37/changes#diff-52347f58ca1366895729356e24b384b058a947b881fb21e28e844969b8396244R15
// > 一般化して、nums[i]を第i世代の生涯収支とみなし、負になったら子供に相続させるのを取りやめるという例えがはまった。
// なるほど。負になってしまったら自己破産。そっからはまた一からやるとかでも一緒かな。
// 砂時計とかも考えてみたが、少し違った。

// https://github.com/naoto-iwase/leetcode/pull/37/changes#diff-52347f58ca1366895729356e24b384b058a947b881fb21e28e844969b8396244R96
// 分割統治法を用いて解く方法。
// 左部分列、右部分列、中央を跨ぐ部分列に分けて、その中の最大を選ぶ。
// 結構理解するのに時間がかかった。アルゴリズムが複雑かつ時間計算量もO(n) であり、他の手法に比べたメリットが思い浮かばなかった。

// https://discord.com/channels/1084280443945353267/1206101582861697046/1208414507735453747
// 最初の 3重ループなどの解法を考えずに初めてしまうことが多々あるため、きちんとそこから考察を始める癖をつける。

// https://github.com/Mike0121/LeetCode/pull/51#discussion_r1969030728
// > オプショナルで、テストケースを考えてみましょう。
// > (ここまで分かっているならば、現実に近づけて、ジャッジシステムというテストケースなどが与えられている状況ではなくて、そういうものがないときに、
// > どうやって自分のコードが問題のないものであるということを提示するか、考えてみましょうという話の帰結です。)
// コーディング面接の時も、自分でテストケースを考えるが、実務でもだいぶ大事だと感じる。
// AI でコード自体は書かなくなってきているが、テストケースの考慮はできないとまずい。(AI が出力したものの検証含め)

// 分割統治法
class Solution {
  int maxSubArray(List<int> nums) {
    if (nums.isEmpty) {
      throw Exception("input should not be empty.");
    }

    ({int total, int maxFromStart, int maxToEnd, int subArrayMax}) helper(
      int start,
      int end,
    ) {
      if (start == end) {
        return (
          total: nums[start],
          maxFromStart: nums[start],
          maxToEnd: nums[start],
          subArrayMax: nums[start],
        );
      }

      final mid = (start + end) ~/ 2;
      final left = helper(start, mid);
      final right = helper(mid + 1, end);

      final total = left.total + right.total;
      final maxFromStart = max(
        left.maxFromStart,
        left.total + right.maxFromStart,
      );
      final maxToEnd = max(
        right.maxToEnd,
        left.maxToEnd + right.total
      );
      final includingMid = left.maxToEnd + right.maxFromStart;

      final subArrayMax = max(
        max(left.subArrayMax, right.subArrayMax),
        includingMid,
      );

      return (
        total: total,
        maxFromStart: maxFromStart,
        maxToEnd: maxToEnd,
        subArrayMax: subArrayMax,
      );
    }

    return helper(0, nums.length - 1).subArrayMax;
  }
}

// Step 3
class Solution {
  int maxSubArray(List<int> nums) {
    if (nums.isEmpty) {
      throw Exception("input should not be empty.");
    }

    var cumulativeSum = 0;
    var maxSubArraySum = nums[0];

    for (var num in nums) {
      cumulativeSum += num;
      maxSubArraySum = max(maxSubArraySum, cumulativeSum);

      if (cumulativeSum < 0) {
        cumulativeSum = 0;
      }
    }

    return maxSubArraySum;
  }
}
