//
//  GithubTableViewCell.swift
//  PracticeRxSwiftMVVM
//
//  Created by koala panda on 2023/08/14.
//

import UIKit

final class GithubTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var urlLabel: UILabel!

    func configure(githubModel: GithubModel) {
        titleLabel.text = githubModel.name
        urlLabel.text = githubModel.urlStr
    }
}
