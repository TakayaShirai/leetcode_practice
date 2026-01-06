// Step 1
// 手作業でどうやるか考える
// まず、intersection について把握。
// intersection は 二つの数の集合の中で、重複している数字の集合
// この intersection を、数の集合を二つ与えられたときに、導ければ良い。
//
// 単純に思いつくのは、片方の集合(集合Aとする)を手元に置きながら、もう片方の集合(集合Bとする)の数字を一つずつ見ていく。
// そのとき、集合Bの数字が集合Aに入っているかを確認して、集合Aにあれば、intersection の要素と判断する。（すでに intersection として追加されていた場合は、それは追加しない）
// これを、集合B の数字全てに対して行えば、intersection が得られる。
//
// もしくは、二つの集合をまず昇順でソートする。
// その後、二つの集合のうち一番小さい数字を比較する。
// 同じであれば、intersection の要素として判断。
// 数字が小さい方は、一つ大きい数字に増やす。
// これを片方の集合の一番大きい数字に辿り着いて、比較をするまで行う。
//
// それ以外の方法はパッと思いつかなかった。
// 最初の方法としては、最初に Set を作ってしまえば、比較自体はO(1)ですんで、それをもう片方の集合の数の分(O(n))だけ比較をすれば良い。
// 手法がこちらの方が単純に感じるため、こちらでとく。

class Solution {
  List<int> intersection(List<int> nums1, List<int> nums2) {
    var uniqueNums = nums1.toSet();
    var intersection = <int>{};

    for (var num in nums2) {
      if (uniqueNums.contains(num)) {
        intersection.add(num);
      }
    }

    return intersection.toList();
  }
}

// Step2:
// 他の人のコードを読む。
//
// https://github.com/Yuto729/LeetCode_arai60/pull/18/changes#diff-28c119488e952cedcb1564a4346e460ac7401048a03e2384b1f9ce9e4149476bR7
// 空集合がある場合に、早期リターンで空の配列を返していた。確かにこれをすべき。
//
// https://github.com/katataku/leetcode/pull/12#discussion_r1893968021
// > 片方がとても大きくて、片方がとても小さいときには、大きい方を set にするのは大変じゃないでしょうか、特に大きいほうが sort 済みのときにはどうしますか。
// 小さい方を Set で用意して、大きい方でイテレーションをしていく。
// 大きい方がソート済みの場合は、小さい方の値をピックアップして、大きい方でバイナリサーチをしていけば、大きい方を Set にするという大変な作業が減る。
//
// 早期リターン + 小さい方の Set の用意
class Solution {
  List<int> intersection(List<int> nums1, List<int> nums2) {
    if (nums1.isEmpty || nums2.isEmpty) {
      return [];
    }

    if (nums1.length > nums2.length) {
      var tmp = nums1;
      nums1 = nums2;
      nums2 = tmp;
    }

    var uniqueNums = nums1.toSet();
    var intersection = <int>{};

    for (var num in nums2) {
      if (uniqueNums.contains(num)) {
        intersection.add(num);
      }
    }

    return intersection.toList();
  }
}

// バイナリサーチで探索していく手法 (ソートされていることを想定するために、nums2 はソートしておく。実際はしない。)
class Solution {
  List<int> intersection(List<int> nums1, List<int> nums2) {
    if (nums1.isEmpty || nums2.isEmpty) {
      return [];
    }

    if (nums1.length > nums2.length) {
      var tmp = nums1;
      nums1 = nums2;
      nums2 = tmp;
    }

    nums2.sort(); // 実際は、この処理はいらない。
    var intersection = <int>{};

    for (var num in nums1) {
      if (existNum(num, nums2)) {
        intersection.add(num);
      }
    }

    return intersection.toList();
  }

  bool existNum(int target, List<int> nums) {
    int low = 0;
    int high = nums.length - 1;

    while (low <= high) {
      int mid = low + (high - low) ~/ 2;

      if (nums[mid] == target) {
        return true;
      } else if (nums[mid] < target) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return false;
  }
}

// Step 3:
class Solution {
  List<int> intersection(List<int> nums1, List<int> nums2) {
    if (nums1.isEmpty || nums2.isEmpty) {
      return [];
    }

    if (nums1.length > nums2.length) {
      var tmp = nums1;
      nums1 = nums2;
      nums2 = tmp;
    }

    var uniqueNums = nums1.toSet();
    var intersection = <int>{};

    for (var num in nums2) {
      if (uniqueNums.contains(num)) {
        intersection.add(num);
      }
    }

    return intersection.toList();
  }
}
