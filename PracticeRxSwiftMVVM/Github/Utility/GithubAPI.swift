//
//  GithubAPI.swift
//  PracticeRxSwiftMVVM
//
//  Created by koala panda on 2023/08/14.
//

import Foundation
import Alamofire
import RxSwift

final class GithubAPI {
    static let shared = GithubAPI()

    private init() {}

    func get(searchWord: String, isDesc: Bool = true, success:
             (([GithubModel]) -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        guard searchWord.count > 0 else {
            success?([])
            return
        }
        AF.request("https://api.github.com/search/repositories?q=\(searchWord)&sort=stars&order=\(isDesc ? "desc" : "asc")").response { (response) in
            switch response.result {
            case .success:
                guard
                    let data = response.data,
                    let githubResponse = try?
                        JSONDecoder().decode(GithubResonse.self, from: data),
                    let models = githubResponse.items
                else
                {
                    success?([])
                    return
                }
                success?(models)
            case .failure(let err):
                error?(err)
            }
        }
    }
}
//自作のGithubAPIクラスのfunctionをRx対応させる
extension GithubAPI: ReactiveCompatible {}
extension Reactive where Base: GithubAPI {
    func get(searchWord: String, isDesc: Bool = true) ->
    Observable<[GithubModel]> {
        return Observable.create { observer in
            GithubAPI.shared.get(searchWord: searchWord, isDesc: isDesc, success: {
                (models) in
                observer.on(.next(models))
            }, error: { err in
                observer.on(.error(err))
            })
            return Disposables.create()
        }
        .share(replay: 1, scope: .whileConnected)
    }
}
/*
このコードは GithubのAPIを叩く機能はアプリに1つしかいらないのでシングルトーンパターン
getメソッドで検索するワードが0以下のときはからの配列を返す
  AlamoFireでリクエスURLを取得してそのレスポンスが成功していればデコードしてモデルを返す
 失敗していたらエラーを返すということでいいのでしょうか?
 ここでなぜResult型をつかってないのが疑問です｡Alamofireだからなのでしょうか?
 この質問を確認してわかりやすく解答してください

 この`GithubAPI`クラスは、GitHubのAPIを使ってリポジトリを検索する機能を提供します。以下は、コードに関しての説明と、あなたの質問に対する答えです。

 ### コードの説明:
 1. **シングルトンパターン**: `GithubAPI`クラスはシングルトーンパターンを使っています。`static let shared`により、このクラスの唯一のインスタンスが生成されます。これにより、APIリクエストの機能はアプリ内で一つしか存在しないことが保証されます。

 2. **getメソッド**:
   - `searchWord`の文字数が0以下の場合、空の配列が成功として返されます
   - Alamofireを使ってGitHubのAPIにリクエストを送り、レスポンスを受け取っています。
   - レスポンスが成功の場合、データを`GithubResonse`というモデルにデコードし、それをさらに返します。
   - レスポンスが失敗の場合、エラーを返します。

 ### Result型に関する質問:
 Alamofireは`Result`型を内部的に使用しています。このコードでは、Alamofireの`response`メソッドが返す`response.result`が実際に`Result`型です。ここでの`.success`と`.failure`は、この`Result`型のケースです。

 ただし、この`get`メソッドは、成功の場合とエラーの場合にそれぞれ異なるクロージャを受け取り、それを使って結果を返しています。一つの`Result`型のクロージャを使う代わりに、2つのクロージャ（`success`と`error`）を使っています。

 このような設計の選択は、エンジニアやチームの好みによるものです。`Result`型のクロージャを使うことで、成功と失敗の両方の結果を一つのクロージャで扱うことができます。しかし、2つのクロージャを使うことで、成功と失敗のロジックを明確に分けることができます。

 このコードが`Result`型のクロージャを直接使っていない理由は、設計の選択や、前の実装の遺産など、さまざまな理由が考えられます。

 let api = GithubAPI.shared
 api.get(searchWord: "Swift") { (models) in
     // 成功した場合の処理
     print("取得したリポジトリ数: \(models.count)")
 } error: { (err) in
     // エラーが発生した場合の処理
     print("エラー: \(err.localizedDescription)")
 }
 上記のコードでは、"Swift"という検索語でGitHub APIにリクエストを行います。リクエストが成功した場合、successクロージャが呼び出され、取得されたリポジトリの数が表示されます。リクエストが失敗した場合、errorクロージャが呼び出され、エラーの説明が表示されます。
*/
