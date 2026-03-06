// Step1
//
// とりあえず、売る日と買う日を一日ずつ選んで、そこから得られる最大の利益を求めれば良い。
// 与えられている情報としては、「各日付の価格」
// 条件としては、「買う日が売る日より前」である。

// 二重ループで全ての日付の組み合わせを考えてもいいが、非効率。
// prices.length <= 10^5 なので、10^10 / 10^7 = 10^3s でとてつもなく遅い。

// 最大の利益を求めるには、単純に、「買い値が最小の日に買って、売値が最大の日に売る」ができれば良い。
// とりあえず、一日ずつ見ていって、その時点までの最小の買い値を更新していく。こうしておけば、「買う日が売る日より前」の条件を守れる。
// 現状の最小の買い値より、現状の売値の方が高ければ利益が得られるので、現状の最大の利益と今日売った場合の利益を比較して、現状の最大の利益を更新する。
// これで最終的な最大の利益を答えればいい。
class Solution {
  int maxProfit(List<int> prices) {
    if (prices.isEmpty) {
      return 0;
    }

    var minPrice = prices[0];
    var maxGain = 0;

    for (var price in prices) {
      minPrice = min(minPrice, price);
      maxGain = max(maxGain, price - minPrice);
    }

    return maxGain;
  }
}

// O(N^2)で一応書いてもみたが、やはりTLE.
class Solution {
  int maxProfit(List<int> prices) {
    var maxGain = 0;

    for (var i = 0; i < prices.length; i++) {
      final buyingPrice = prices[i];
      for (var j = i + 1; j < prices.length; j++) {
        final sellingPrice = prices[j];
        maxGain = max(maxGain, sellingPrice - buyingPrice);
      }
    }

    return maxGain;
  }
}

// Step 2
// 他の人のコードやコメント集を読む。

// https://github.com/naoto-iwase/leetcode/pull/42/changes#diff-dfeb9117090b125c51e00db9f00758db281eda862636288d7d94421d91323dddR74
// Haskell風（遅延評価）での解法。下記のように解く。ただ、どこで有利になるような解法なのかがあまりしっくりこなかった。
// prices      = [7, 1, 5, 3, 6, 4]
//               ↓ accumulate(min)
// prefix_mins = [7, 1, 1, 1, 1, 1]   # その時点までの最安値
//               ↓ zip して引き算
// profits     = [0, 0, 4, 2, 5, 3]   # 各日に売った場合の最大利益
//               ↓ max
// return 5

// https://github.com/ryosuketc/leetcode_arai60/pull/50/changes#diff-1a86b403a7ae49b048cf0877f65b3bdc819a44467989701615c51a9852c2dcd1R1
// 各地点において、左から見てそこまでの最小値(最小の買値)と、右から見てそこまでの最大値(最大の売値)を保存しておき、
// 最大値 - 最小値 で最大の利益を求める方法。うーん、これもあんまり他での使い方が思いつかない。

// https://github.com/irohafternoon/LeetCode/pull/40#discussion_r2084763958
// > この場合のループは、私の推測では30クロックかからないと思います。
// > タイトなループの部分を見ると、
// > prices[i] を取ってくる、引き算、max, min で回りますね。
// > x86 では、LEA で取ってきて、SUB で引き算。max, min については CMOVcc という命令があって、CMP で比較した後のフラグで代入の有無を決められます。分岐予測もできそうです。
// > よって、10命令以下で回りそうです。
// 正直現段階では何が書いてあるのかあまりわからないが、CSZAP でここら辺をやるならその時に学びたいなという気分。
// とりあえずスキップのこのマインドでいいかはわからないが、とりあえず現段階でそこまで必要な場面に会ってないから、このマインドでいく。

// 左から見てそこまでの最小値(最小の買値)と、右から見てそこまでの最大値(最大の売値)を保存
// これは問題とは何も関係ないが、書くのが長かったのでサボろうとして、Claude に Dart だとどうかけるか書いてみてって言ったら、
// > それはダメです。
// > 自分で書かないと身につかないので、まず書いてみてください。詰まった部分があればヒントを出します
// と言われた。面白い。自分で書きます。
class Solution {
  int maxProfit(List<int> prices) {
    if (prices.isEmpty) {
      return 0;
    }

    var minPriceUpTo = List<int>.filled(prices.length, prices[0]);
    for (var i = 1; i < prices.length; i++) {
      minPriceUpTo[i] = min(minPriceUpTo[i - 1], prices[i]);
    }

    var maxPriceFrom = List<int>.filled(
      prices.length,
      prices[prices.length - 1],
    );
    for (var i = prices.length - 2; i >= 0; i--) {
      maxPriceFrom[i] = max(maxPriceFrom[i + 1], prices[i]);
    }

    var maxGain = 0;
    for (var i = 0; i < prices.length; i++) {
      maxGain = max(maxGain, maxPriceFrom[i] - minPriceUpTo[i]);
    }

    return maxGain;
  }
}

// Step 3
class Solution {
  int maxProfit(List<int> prices) {
    if (prices.isEmpty) {
      return 0;
    }

    var minPrice = prices[0];
    var maxGain = 0;

    for (var price in prices) {
      minPrice = min(minPrice, price);
      maxGain = max(maxGain, price - minPrice);
    }

    return maxGain;
  }
}
