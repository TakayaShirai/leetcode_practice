// Step 1
// 今いる家での最高額は、
// - 隣の家までの最高額
// - 二つ隣の家までの最高額　+ 今いる家から盗める額
// これを随時更新していけば良いはず。
// だが、直線の場合は、一方向に進めば良かったが、円環の場合は、両方向に進める。
// 各地点で両方向に進んだ場合は、重複が生まれてしまうため、複雑になりそう。
// 一方向でやるにしても、どうやるのかが思いつかない。
// 10分ほど考えてもわからなかったため、他の人のコードをみる。

// Step 2
// leetcode のヒントとしては、
// > Since House[1] and House[n] are adjacent, they cannot be robbed together.
// > Therefore, the problem becomes to rob either House[1]-House[n-1] or House[2]-House[n], depending on which choice offers more money.
// らしい。
// 言われればそうだが、どうやって思いつくかの思考回路が知りたかったので、Claude に聞いてみた。
// 1. まず円環の厄介さを特定する: 直線の House Robber は解ける。円環で何が変わるかというと、「最初と最後が隣り合っている」という制約が1つ増えただけ。
// 2. その制約を消せないか考える: 厄介な制約が1つだけなら、場合分けで消せることが多い。最初の家を「盗む」か「盗まない」かで分ければ、最後の家との関係が確定する。
// 3. 場合分けしたら既知の問題に帰着するか確認する: どちらの場合も、最初と最後のつながりが消えて直線になる。直線版はもう解けるので、それを2回使えば終わり。
// 問題として、未知のものは、「最大の盗める量」、与えられているものは、「それぞれの家の盗める量」と、House Robber でも House Robber II でも、これらは変わらない。
// 異なるのは、条件の「最初と最後が隣り合っている」という部分。これを取り除けば、全く同じ問題に帰着するから、「この条件をどうやって取り除けば良いか」を考えるのが肝だった。
// 最近意識するのを忘れていたが、「未知のものは何か」、「与えられているものは何か」、「条件は何か」を意識するのは、どんな問題を解く上でもやはり重要。
class Solution {
  int robLine(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }
    if (nums.length == 1) {
      return nums[0];
    }

    var maxGainUpToPrevious = nums[0];
    var maxGainUpToCurrent = max(nums[0], nums[1]);

    for (var i = 2; i < nums.length; i++) {
      final maxGain = max(maxGainUpToPrevious + nums[i], maxGainUpToCurrent);
      maxGainUpToPrevious = maxGainUpToCurrent;
      maxGainUpToCurrent = maxGain;
    }

    return maxGainUpToCurrent;
  }

  // 自分で関数の名前を変えられるのなら、robRingにする。
  int rob(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }
    if (nums.length == 1) {
      return nums[0];
    }

    final maxGainWithoutFirst = robLine(nums.sublist(1));
    final maxGainWithoutLast = robLine(nums.sublist(0, nums.length - 1));

    return max(maxGainWithoutFirst, maxGainWithoutLast);
  }
}

// コメント集はなかった。
// 他の方のコードは、House Robber の時とあまり変化がなかったため、今回は書いていない。

// Step 3
class Solution {
  int robLine(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }
    if (nums.length == 1) {
      return nums[0];
    }

    var maxGainUpToPrevious = nums[0];
    var maxGainUpToCurrent = max(nums[0], nums[1]);

    for (var i = 2; i < nums.length; i++) {
      final maxGain = max(maxGainUpToPrevious + nums[i], maxGainUpToCurrent);
      maxGainUpToPrevious = maxGainUpToCurrent;
      maxGainUpToCurrent = maxGain;
    }

    return maxGainUpToCurrent;
  }

  int rob(List<int> nums) {
    if (nums.isEmpty) {
      return 0;
    }
    if (nums.length == 1) {
      return nums[0];
    }

    final maxGainWithoutFirst = robLine(nums.sublist(1));
    final maxGainWithoutLast = robLine(nums.sublist(0, nums.length - 1));

    return max(maxGainWithoutFirst, maxGainWithoutLast);
  }
}
