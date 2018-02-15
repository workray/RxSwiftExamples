//
//  ViewController.swift
//  RxDataSourceExample
//
//  Created by Mobdev125 on 2/14/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var dataSource: RxTableViewSectionedReloadDataSource<DefaultSection>?
    var shownCitiesSection: DefaultSection!
    var allCities = [String]()
    var sections = PublishSubject<[DefaultSection]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let dataSource = RxTableViewSectionedReloadDataSource<DefaultSection>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cityPrototypeCell") ?? UITableViewCell(style: .default, reuseIdentifier: "cityPrototypeCell")
                cell.textLabel?.text = "Item \(item)"
                
                return cell
        },
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
        }
        )
        
        self.dataSource = dataSource
        
        allCities = ["New York", "London", "Oslo", "Warsaw", "Berlin", "Praga"]
        shownCitiesSection = DefaultSection(header: "Cities", items: allCities.toItems(), updated: Date())
        sections.onNext([shownCitiesSection])
        dataSource.configureCell = { (_, tableView, indexPath, index) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cityPrototypeCell", for: indexPath)
            cell.textLabel?.text = self.shownCitiesSection.items[indexPath.row].title
            return cell
        }
        
        sections
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag) // Instead of creating the bag again and again, use the extension NSObject_rx
        
        searchBar
            .rx.text
            .filter { $0 != nil }
            .map { $0! }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] query in
                let items: [String]
                if query.count > 0 {
                    items = self.allCities.filter { $0.hasPrefix(query) }
                } else {
                    items = self.allCities
                }
                self.shownCitiesSection = DefaultSection(
                    original: self.shownCitiesSection,
                    items: items.toItems()
                )
                
                self.sections.onNext([self.shownCitiesSection])
            })
            .disposed(by: rx.disposeBag)
    }
    
}

extension Collection where Self.Iterator.Element == String {
    func toItems() -> [DefaultItem] {
        return self.map { DefaultItem(title: $0, dateChanged: Date()) }
    }
}
