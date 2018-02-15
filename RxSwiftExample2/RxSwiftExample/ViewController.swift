//
//  ViewController.swift
//  RxSwiftExample
//
//  Created by Mobdev125 on 2/14/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import RxSwift
import RxCocoa
import ChameleonFramework

class ViewController: UIViewController {

    var circleView: UIView!
    var circleViewModel: CircleViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        // draw view of circle shape
        circleView = UIView(frame: CGRect.init(origin: view.center, size: CGSize.init(width: 100.0, height: 100.0)))
        circleView.layer.cornerRadius = circleView.frame.width / 2.0
        circleView.center = view.center
        circleView.backgroundColor = .green
        view.addSubview(circleView)
        
        circleViewModel = CircleViewModel()
        // Bind the center of CircleView to centerObservable
        circleView
            .rx.observe(CGPoint.self, "center")
            .bind(to: circleViewModel.centerVariable)
            .disposed(by: disposeBag)
        
        // Subscribe the backgroundObservable to get a new color of the ViewModel
        circleViewModel.backgroundColorObservable
            .subscribe(onNext: { [weak self] (backgroundColor) in
                UIView.animate(withDuration: 0.1, animations: {
                    self?.circleView.backgroundColor = backgroundColor
                    // Get complementary olors for a given background color
                    let viewBackgroundColor = UIColor(complementaryFlatColorOf: backgroundColor)
                    // Checks whether the new background color is difference from the existing background color
                    if viewBackgroundColor != backgroundColor {
                        // Assign a new background color to the original background color
                        // We just want a different color from which we can see the circles in the view
                        self?.view.backgroundColor = viewBackgroundColor
                    }
                })
            })
            .disposed(by: disposeBag)
        
        // add gesture recognizer
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(circleMoved(_:)))
        circleView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func circleMoved(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)
        UIView.animate(withDuration: 0.1) {
            self.circleView.center = location
        }
    }


}

