//
//  RxGithubSearchViewController.swift
//  PracticeRxSwiftMVVM
//
//  Created by koala panda on 2023/08/14.
//

import UIKit
import RxSwift
import RxCocoa

import RxOptional

class RxGithubSearchNoMVVMViewController: UIViewController {
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            let cell = UINib(nibName: "GithubTableViewCell", bundle: nil)
            tableView.register(cell, forCellReuseIdentifier: "Cell")
        }
    }

    @IBOutlet private weak var sortTypeSegmentedControl: UISegmentedControl!

    var responseData: [GithubModel] = []
    // これを追加しないとエラーがでた｡なぜ??
    let disposeBag = DisposeBag()

    //viewDidLoadで必要なストリームを決める
    override func viewDidLoad() {
        super.viewDidLoad()

        //----------------
        //文字列のストリーム (1)
        //0.5sec以上,変化している,nilでない,文字数0以上
        //であればテキストをストリームに流す
        let searchTextObservable: Observable<String> = urlTextField.rx.text
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filterNil()
            .filter { $0.isNotEmpty }

        //ソートのストリーム (2)
        //初回読み込み時または変化があれば
        //sortTypeSegmentedControlのindexをストリームに流す

        // ここは下から処理をみたほうがわかりやすい
        let sortTypeObservable = Observable.merge( //2つのストリームを合体させるmarge
            // 初期値をながす
            Observable.just(sortTypeSegmentedControl.selectedSegmentIndex),

            // Void型が流れてくる 値が変わったら処理をながす
            sortTypeSegmentedControl.rx.controlEvent(.valueChanged).map { self.sortTypeSegmentedControl.selectedSegmentIndex
            }
        ).map { $0 == 0 } // ここで流れてきた値を判断

        //(1),(2)を合成してストリームに値がきたらAPIを叩いてテーブルをリロード
        let getAPIObservable = Observable.combineLatest(
            searchTextObservable,
            sortTypeObservable
        ).flatMapLatest({ (searchWord, sortType) -> Observable<[GithubModel]> in // searchWord, sortType2つが取れる  Obserbable型にしないと型がながれてくれない
            GithubAPI.shared.rx.get(searchWord: searchWord, isDesc: sortType) // Obserbable型にしないと型がながれてくれないのを勝手にやってくれる
        })
        //-------------------

        //------------------
        //購買する 値が流れてくる末端
        getAPIObservable
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (models) in
                self?.responseData = models
                self?.tableView.reloadData()
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        //------------------

        //この書き方だとUITableViewDataSourceすらいらなくなるがtableviewの警告が出た
//            getAPIObservable.subscribe(on: MainScheduler.instance)
//              .bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: GithubTableViewCell.self)){(row, element, cell) in
//                  cell.configure(githubModel: element)
//              }.disposed(by: rx.disposeBag)
    }
    



}
extension RxGithubSearchNoMVVMViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let githubModel = responseData[safe: indexPath.item],
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? GithubTableViewCell
        else { return UITableViewCell() }
        cell.configure(githubModel: githubModel)
        return cell
    }
}
