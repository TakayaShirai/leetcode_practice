// Step 1:
// 右括弧がきた時に、最新の左括弧がそれに対応した括弧かどうかを調べればよい。
// そして、最後まで入力を読み込んだ時に、左括弧に余りがないことをチェックする。
// あまりがなければ、Valid とみなすことができる。
//
// この作業は、「左括弧を格納し最新の左括弧がすぐに取り出せる容器」と、「右括弧と左括弧の対応表」があればできる。
// 一つの括弧をチェックするのを一つのループとして、
// 左括弧であるなら、容器に格納
// 右括弧であるなら、容器から最新の左括弧を取り出し、対応表で正しい対応かを確認。
//   容器に何もない、もしくは対応表と照らし合わせて正しくないならエラーを報告。
//   正しければ作業続行。
// という作業を行う。
// 全てのループが問題なく終了したら、容器の中身を確認する。
// まだ中身があれば、エラーを報告。なければ、入力は正当なものであったと判断する。
// これをコードにすれば良い。

class Solution {
  func isValid(_ s: String) -> Bool {
    var leftBrackets: [Character] = []
    let rightToLeftBracketMap: [Character: Character] = ["}": "{", ")": "(", "]": "["]

    for bracket in s {
      guard let expectedLeftBracket = rightToLeftBracketMap[bracket] else {
        leftBrackets.append(bracket)
        continue
      }

      guard let lastLeftBracket = leftBrackets.popLast(),
        lastLeftBracket == expectedLeftBracket
      else {
        return false
      }
    }

    return leftBrackets.isEmpty
  }
}

// Step 2:
// 他の人のコード・コメントを読む
//
// https://discord.com/channels/1084280443945353267/1201211204547383386/1202541275115425822
// うーん、ここに出てきている単語は常識だそうだが、全てわからなかった。調べる。
// チョムスキー階層、タイプ-2、文脈自由文法、プッシュダウンオートマトン
// 正規言語、正規文法、有限オートマトン
// PDA: https://www.jaist.ac.jp/~uehara/course/2006/ti113/09pda.pdf
// CSZAP の資料：https://discord.com/channels/1084280443945353267/1394676785194733619/1413443095181266945
//
// https://github.com/tarinaihitori/leetcode/pull/7/files#r1812923237
// 気をつけて書いてはいるつもりだが、認知負荷が上がらないように continue を使用するなどは、引き続き心がけたい。
//
// https://github.com/yas-2023/leetcode_arai60/pull/6/files#diff-a8291082daa35feea10bd57e3cd3c361e2924071e16ec70e0f4708959678687bR1
// 与えられた文字列から、閉じている括弧をペアでどんどんと消していく手法。確かにこれもできるか。
// 閉じている括弧のペアの空文字への置換や、文字列内での探索があるため遅くはなる。
//
// https://github.com/yus-yus/leetcode/pull/6#discussion_r1944970090
// 確かに副作用のある処理を条件文に記載するのは、条件以外でその処理自体についても考える必要ができてしまうため避けた方が良さそう。
//
// https://discord.com/channels/1084280443945353267/1225849404037009609/1231648833914802267
// "(aiu)[eo]" が入力としてきたときに、プログラムの挙動として好ましいのは何だと考えますか?
// 問題文上起きないとはいえ、確かにこのようなケースについて考えられていなかった。
//
// 以上を踏まえて書き直してみる。
//
class Solution {
  func isValid(_ s: String) -> Bool {
    var openBrackets: [Character] = []
    let closeToOpenBracketMap: [Character: Character] = [")": "(", "}": "{", "]": "["]
    let validBrackets: Set<Character> = ["(", ")", "{", "}", "[", "]"]

    for inputChar in s {
      // 括弧以外の文字列も許容する
      guard validBrackets.contains(inputChar) else { continue }

      guard let expectedOpenBracket = closeToOpenBracketMap[inputChar] else {
        openBrackets.append(inputChar)
        continue
      }

      guard !openBrackets.isEmpty else { return false }
      let lastOpenBracket = openBrackets.popLast()!
      guard lastOpenBracket == expectedOpenBracket else {
        return false
      }
    }

    return openBrackets.isEmpty
  }
}

// Step 3:
class Solution {
  func isValid(_ s: String) -> Bool {
    var openBrackets: [Character] = []
    let closeToOpenBrackets: [Character: Character] = [")": "(", "}": "{", "]": "["]
    let validBrackets: Set<Character> = ["(", ")", "{", "}", "[", "]"]

    for inputChar in s {
      guard validBrackets.contains(inputChar) else { continue }

      guard let expectedOpenBracket = closeToOpenBrackets[inputChar] else {
        openBrackets.append(inputChar)
        continue
      }

      guard !openBrackets.isEmpty else { return false }
      let lastOpenBracket = openBrackets.popLast()!
      guard lastOpenBracket == expectedOpenBracket else {
        return false
      }
    }

    return openBrackets.isEmpty
  }
}

// Step 4:
class Solution {
  func isValid(_ s: String) -> Bool {
    var openBrackets: [Character] = []
    let closeToOpen: [Character: Character] = [")": "(", "}": "{", "]": "["]
    let bracketsToCheck: Set<Character> = ["(", ")", "{", "}", "[", "]"]

    for inputChar in s {
      guard bracketsToCheck.contains(inputChar) else { continue }

      let isCloseBracket = closeToOpen[inputChar] != nil
      guard isCloseBracket else {
        openBrackets.append(inputChar)
        continue
      }

      guard !openBrackets.isEmpty else { return false }
      let expectedOpenBracket = closeToOpen[inputChar]!
      guard openBrackets.popLast() == expectedOpenBracket else {
        return false
      }
    }

    return openBrackets.isEmpty
  }
}
