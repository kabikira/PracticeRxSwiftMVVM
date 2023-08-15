//
//  Array+.swift
//  PracticeRxSwiftMVVM
//
//  Created by koala panda on 2023/08/14.
//

import Foundation
import UIKit

extension Array {
    subscript (safe index: Int) -> Element? {
        return index >= 0 && index < self.count ? self[index] : nil
    }
}
/*
 このArrayの拡張（extension）は、配列の要素にセーフにアクセスするためのものです。


 subscriptは、Swiftの特殊なメソッドで、クラスや構造体に対して、ブラケット([])を使ってアクセスするためのものです。この拡張により、配列にブラケットを使ってアクセスする際に、新しい方法が追加されます。

 safeという名前の新しいパラメータがsubscriptに導入されています。このsafeを使うことで、この拡張を使って配列にアクセスすることができます。

 配列内の要素にアクセスする際、インデックスが配列の範囲外の場合、通常は実行時エラーが発生します。しかし、この拡張を使用すると、インデックスが配列の範囲内にある場合にのみ要素にアクセスし、範囲外の場合はnilを返します。これにより、範囲外のインデックスを使って配列にアクセスしたときのエラーを防ぐことができます

 使用例
 let array = [1, 2, 3, 4, 5]

 print(array[safe: 2])  // Optional(3)
 print(array[safe: 7])  // nil

 */
