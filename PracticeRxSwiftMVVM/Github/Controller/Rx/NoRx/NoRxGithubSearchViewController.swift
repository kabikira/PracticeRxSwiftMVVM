//
//  NoRxGithubSearchViewController.swift
//  PracticeRxSwiftMVVM
//
//  Created by koala panda on 2023/08/14.
//

import UIKit

class NoRxGithubSearchViewController: UIViewController {

    private var start = Date()
    private var preText: String = ""

    @IBOutlet private weak var urlTextField: UITextField!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            let cell = UINib(nibName: "GithubTableViewCell", bundle: nil)
            tableView.register(cell, forCellReuseIdentifier: "Cell")
        }
    }

    @IBOutlet private weak var sortTypeSegmentedControl: UISegmentedControl!

    var responseDate: [GithubModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //UITextFieldのdelegateにはテキストが変わったことを検知するdelegateがないので自分で登録
        urlTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    //APIを叩いてテーブルをリロードするメソッド
    private func reload(searcWord: String, isDesc: Bool) {
        GithubAPI.shared.get(searchWord: searcWord, isDesc: isDesc, success: {[weak self] (models) in
            //インクリメンタルサーチ機能のために最後の取得時間を保存
            self?.start = Date()
            //インクリメンタルサーチ機能のために最後のサーチワードを保存
            self?.preText = searcWord
            //APIからのデータを保存
            self?.responseDate = models
            //テーブルのリロード
            self?.tableView.reloadData()

        }, error: nil)

    }
    //テキストフィールドの値が変わったら処理する
    @objc func textFieldDidChange(_ textField: UITextField) {
        //文字列が１文字以上あるか
        //前回と違う文字列か
        //前回の取得から0.5sec以上経ったか
        guard
            let searchWord = textField.text, searchWord.count > 0,
            searchWord != preText, Date().timeIntervalSince(start) > 0.5
        else { return }
        //ソートタイプは昇順か
        let isDesc = self.sortTypeSegmentedControl.selectedSegmentIndex == 0
        //リロード
        self.reload(searcWord: searchWord, isDesc: isDesc)
    }
    //ソートタイプの値が変わったら処理する
    @IBAction func changeSortType(_ sender: Any) {
        //文字列が１文字以上あるか
        //前回と違う文字列か
        //前回の取得から0.5sec以上経ったか
        guard
            let searchWord = self.urlTextField.text, searchWord.count > 0,
        searchWord != preText, Date().timeIntervalSince(start) > 0.5
        else { return }
        //ソートタイプは昇順か
        let isDesc = self.sortTypeSegmentedControl.selectedSegmentIndex == 0
        //リロード
        self.reload(searcWord: searchWord, isDesc: isDesc)
    }
}

extension NoRxGithubSearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseDate.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let githubModel = responseDate[safe: indexPath.item],
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? GithubTableViewCell else { return UITableViewCell() }
        cell.configure(githubModel: githubModel)
        return cell
    }
}
