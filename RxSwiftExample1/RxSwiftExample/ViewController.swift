//
//  ViewController.swift
//  RxSwiftExample
//
//  Created by Mobdev125 on 2/14/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    var shownCities = [String]()
    let allCities = ["New York", "London", "Oslo", "Warsaw", "Berlin", "Praga"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cityPrototypeCell")
        
        searchBar
            .rx.text                                            // Observable of RxCocoa
            .orEmpty                                            // make it not Optional ( String? -> String )
            .debounce(0.5, scheduler: MainScheduler.instance)   // wait 0.5 sec
            .distinctUntilChanged()                             // make sure the new value is the same as the previous value.
//            .filter{ !$0.isEmpty }                              // If the new value is really new, filter it for non-empty queries.
            .subscribe(onNext: { [weak self] (query) in
                self?.shownCities = (self?.allCities.filter{ $0.hasPrefix(query) })!
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownCities.count == 0 ? allCities.count : shownCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityPrototypeCell", for: indexPath)
        if shownCities.count == 0 {
            cell.textLabel?.text = allCities[indexPath.row]
        }
        else {
            cell.textLabel?.text = shownCities[indexPath.row]
        }
        return cell
    }
}

