//
//  ViewController.swift
//  RxAlamofireExample
//
//  Created by Mobdev125 on 2/14/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import ObjectMapper
import RxAlamofire
import RxCocoa
import RxSwift

class RepositoriesViewController: UIViewController {

    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    var repositoryNetworkModel: RepositoryNetworkModel!
    
    var rx_searchBarText: Observable<String> {
        return searchBar
            .rx.text
            .orEmpty
            .filter { $0.count > 0 }
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "repositoryCell")
        setupRx()
    }
    
    func setupRx() {
        repositoryNetworkModel = RepositoryNetworkModel(withNameObservable: rx_searchBarText)
        
        repositoryNetworkModel
            .rx_repositories
            .drive(tableView.rx.items) { tableView, row, repository in
                let cell = tableView.dequeueReusableCell(withIdentifier: "repositoryCell", for: IndexPath(row: row, section: 0))
                cell.textLabel?.text = repository.name
                
                return cell
            }
            .disposed(by: disposeBag)
        
        repositoryNetworkModel
            .rx_repositories
            .drive(onNext: { (repositories) in
                if repositories.count == 0 {
                    let alert = UIAlertController(title: ":(", message: "No repositories for this user.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    if self.navigationController?.visibleViewController is UIAlertController {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            .disposed(by: disposeBag)
    }


}

