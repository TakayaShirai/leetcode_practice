// Step 1
//
// 入力として入ってくる数字が全て正の場合は、subarray の長さを増やしたときに必ず subarray の総和は増える。
// そのため、target よりも総和が大きければ左側の要素を一つ減らし、小さければ右側の要素を一つ増やす。のような sliding window の方法で行けそう。
// ただ、負の入力があるため、これができない。
//
// うーん、途中から自分が仕事を任されたとして、何があればこの仕事が行えるかを考えてみる。
// 「これまでに出てきた subarray の和（今の添字の一つ前が最後の要素になっているもの）」と「今持っている数字」と「target となる数字」があれば途中から渡されても平気。
// 要するに、これまでに出てきた subarray の和 と 今持っている数字を足して、target になるものがあれば、それは和が k になる新しい Subarray になる。
// とすると、「これまでに出てきた subarray の和」をどうやって求めるかが問題。
// 一つは、Brute Force 的に、毎回現在の添字の一つ前が末尾になっているような Subarray を毎回計算する。和の計算自体は、重複している部分があるため、メモ化可能。
// 例えば、subarray の初めと終わりの添字を (i, j) とすれば、(i, j+1)の和は (i, j)に j+1 の位置にある要素の数字を足すことで求められる。
// とりあえずこれでやってみる。subarray の和を key として、その出現回数を value として、カウントの回数は簡単にする。

// O(N^2)で TLE になりました。updateSumToCount が悪さをしてる。
class Solution {
  int subarraySum(List<int> nums, int k) {
    Map<int, int> updateSumToCount(Map<int, int> sumToCount, int num) {
      var newSumToCount = <int, int>{0: 1};

      for (var MapEntry(key: sum, value: count) in sumToCount.entries) {
        newSumToCount[sum + num] = (newSumToCount[sum + num] ?? 0) + count;
      }

      return newSumToCount;
    }

    var sumToCount = <int, int>{0: 1};
    var count = 0;

    for (var i = 0; i < nums.length; i++) {
      final target = k - nums[i];
      count += (sumToCount[target] ?? 0);

      sumToCount = updateSumToCount(sumToCount, nums[i]);
    }

    return count;
  }
}

// Step 2
// 他の人のコードを読む
//
// LLM に相談
// 直接 subarray の和を持つのではなく、累積和を持っておけば簡単に求められる。Sum(i, j) = Sum(0, j) - Sum(0, i-1)。
// k - Sum (i, j) = Sum (0, l) となるような累積和を探せばいい。
// 問題を言い換えて、より簡単な問題に変えていく。
class Solution {
  int subarraySum(List<int> nums, int k) {
    var count = 0;
    var cumulativeSum = 0;
    var sumToCount = <int, int>{0: 1};

    for (var num in nums) {
      cumulativeSum += num;
      final target = cumulativeSum - k;

      count += sumToCount[target] ?? 0;
      sumToCount[cumulativeSum] = (sumToCount[cumulativeSum] ?? 0) + 1;
    }

    return count;
  }
}

// https://github.com/Yuto729/LeetCode_arai60/pull/16#discussion_r2602118324
// 計算時間の概算の仕方。
// step 1 で書いたやつは O(N^2)の計算量。それで、N の長さは今回 2 * 10^4 が最大であるため、概算で最大 4 * 10^8 ステップぐらいかかる。
// 1億 (10^8)ステップ/秒として考えると、大体 4秒ほど。まあ TLE になりますね。ここら辺を次回から、ちゃんと実際に計算してオーダーが合うかどうかを確かめる。
// この計算時間の概算は習慣化する。コードを提出する前に計算しておく。

// https://discord.com/channels/1084280443945353267/1183683738635346001/1192145962479665304
// > なんか、抽象概念を抽象概念のまま処理しようとしているように感じました。
// > いや、累積和を日常で見る機会ってあると思うんですよ。たとえばですけれども、電車の各駅の距離とかかる時間が書かれていて、ちょうど10分かかる駅の組み合わせはどれか、
// > といわれたら、(これはマイナスが出ないので更に楽ですが、)終着駅から出発する電車が、どこを何時何分に通過するかを書き出しながら、その10分前に別の駅にいたかを確認したらいいですよね。
// こういった抽象的な概念の具体化、もしくは抽象化から別の具体的なものに結びつけるのが自然にできるようになりたいな。意識する。
//
// (問題とは関係ない)最近思うが、「いかにして問題をとくか」という本に書かれていることを意識するのがいい。

// Step 3
class Solution {
  int subarraySum(List<int> nums, int k) {
    var cumulativeSum = 0;
    var sumToCount = <int, int>{cumulativeSum: 1};
    var count = 0;

    for (var num in nums) {
      cumulativeSum += num;

      final target = cumulativeSum - k;
      count += sumToCount[target] ?? 0;

      sumToCount[cumulativeSum] = (sumToCount[cumulativeSum] ?? 0) + 1;
    }

    return count;
  }
}
