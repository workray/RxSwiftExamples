//
//  ViewController.swift
//  RxActionExample
//
//  Created by Mobdev125 on 2/14/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Action
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet var formFields: [UITextField]!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    var currentTranslation: CGFloat = 0
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupRX()
        setupUI()
    }
    
    func setupRX() {
        let validUsernameCollection = formFields // take array of inputs
            .map { input in
                input.rx.text
                    .filter { $0 != nil }
                    .map { $0! }
                    .map { $0.count > 0 } // map them into array of Observable<Bool>
        } // this allows us to use combineLatest, which fires up whenever any of the observables emits a signal
        
        let validUsername = Observable.combineLatest(validUsernameCollection) { filters in
            return filters.filter { $0 }.count == filters.count // if every input has length > 0, emit true
        }
        
        let action = Action<Void, Void>(enabledIf: validUsername) { input in
            let alert = UIAlertController(title: "Wooo!", message: "Registration completed!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return .empty()
        }
        
        registerButton.rx.action = action
    }
    
    func setupUI() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let margin: CGFloat = 10.0
        var responderY: CGFloat!
        formFields.forEach { field in
            if field.isFirstResponder {
                responderY = field.frame.maxY + stackView.frame.minY
                return
            }
        }
        currentTranslation = currentTranslation + responderY - keyboardFrame.minY + margin
        if currentTranslation != 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.stackView.transform = CGAffineTransform(translationX: 0.0, y: (-1)*self.currentTranslation)
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.currentTranslation = 0.0
            self.stackView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }


}

