//
//  ViewController.swift
//  RxMKMapViewExample
//
//  Created by Mobdev125 on 2/14/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa
import RxMKMapView
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    func setupRx() {
        mapView
            .rx.willStartLoadingMap
            .asDriver()
            .drive(onNext: {
                print("Will start loading map")
            })
            .disposed(by: disposeBag)
        
        mapView
            .rx.didFinishLoadingMap
            .asDriver()
            .drive(onNext: {
                print("Finished loading map")
            })
            .disposed(by: disposeBag)
        mapView
            .rx.willStartRenderingMap
            .asDriver()
            .drive(onNext: {
                print("Will start rendering map")
            })
            .disposed(by: disposeBag)
        mapView
            .rx.didFinishRenderingMap
            .asDriver()
            .drive(onNext: { (fullyRendered) in
                print("Finished rendering map? Is it fully rendered tho? Of course \(fullyRendered)!")
            })
            .disposed(by: disposeBag)
    }
    
}
