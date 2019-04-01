//
//  RxKeyboardAvoidingScrollView.swift
//  RxKeybaordAvoidingScrollableView
//
//  Created by Amey Tavkar on 28/03/19.
//  Copyright © 2019 Amey Tavkar. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

public class RxKeyboardAvoidingScrollView: UIScrollView, UITextFieldDelegate {
    private let disposeBag = DisposeBag()
    private let keyboardFrame = BehaviorRelay<CGRect>(value: CGRect.zero)
    
    private var keyboardAnimationDuration: Float = 0.0
    private var keyboardAnimationCurve: Int = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        
        setupTextFields(in: self)
        
        let defaultFrame = CGRect(
            x: 0,
            y: UIScreen.main.bounds.height,
            width: UIScreen.main.bounds.width,
            height: 0
        )
        
        let willChangeFrame = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .map { [weak self] notification -> CGRect in
                let rectValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                self?.keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Float ?? 0.0
                self?.keyboardAnimationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
                return rectValue?.cgRectValue ?? defaultFrame
            }
        
        let willHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { notification -> CGRect in
                let rectValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                return rectValue?.cgRectValue ?? defaultFrame
            }
        
        Observable.of(willChangeFrame, willHide)
            .merge()
            .bind(to: keyboardFrame)
            .disposed(by: disposeBag)
        
        keyboardFrame
            .subscribe(onNext: { frame in
                var newInset = self.contentInset;
                newInset.bottom = self.bounds.height - frame.origin.y + 44
                self.contentInset = newInset
                self.scrollIndicatorInsets = newInset
            })
            .disposed(by: disposeBag)
        
        willChangeFrame
            .subscribe(onNext: { [unowned self] frame in
                self.scrollToResponder()
            })
            .disposed(by: disposeBag)
    }
    
    private func firstResponder(in view: UIView) -> UIView? {
        
        guard !view.subviews.isEmpty else { return nil }
        
        func tailRecFirstResponder(in head: UIView, tail: [UIView]) -> UIView? {
            
            if head.isFirstResponder {
                return head
            }
            if let firstResponder = firstResponder(in: head) {
                return firstResponder
            }
            if !tail.isEmpty {
                return tailRecFirstResponder(in: tail.first!, tail: Array(tail.dropFirst()))
            }
            return nil
        }
        
        return tailRecFirstResponder(in: view.subviews.first!, tail: Array(view.subviews.dropFirst()))
    }
    
    private func contentOffset(for view: UIView) -> CGPoint {
        let viewableHeight = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom
        
        var offset: CGFloat = 0.0
        let subviewRect = view.convert(view.bounds, to: self)
        let padding = max((viewableHeight - subviewRect.height)/2, 10)
        offset = min(subviewRect.origin.y - padding - self.contentInset.top, (contentSize.height - viewableHeight))
        if offset < -self.contentInset.top {
            offset = -self.contentInset.top
        }
        return CGPoint(x: self.contentOffset.x, y: offset)
    }
    
    private func setupTextFields(in view: UIView) {
        
        guard !view.subviews.isEmpty else { return }
        
        func tailRecSetupTextFields(in head: UIView, tail: [UIView]) {
            
            if let textfield = head as? UITextField {
                textfield.delegate = self
            }
            setupTextFields(in: head)
            if !tail.isEmpty {
                return tailRecSetupTextFields(in: tail.first!, tail: Array(tail.dropFirst()))
            }
        }
        
        return tailRecSetupTextFields(in: view.subviews.first!, tail: Array(view.subviews.dropFirst()))
    }
    
    private func scrollToResponder() {
        if let firstResponderView = self.firstResponder(in: self) {
            UIView.animate(
                withDuration: TimeInterval(self.keyboardAnimationDuration),
                delay: 0,
                options: UIView.AnimationOptions(rawValue: UInt(self.keyboardAnimationCurve)),
                animations: { [unowned self] () -> Void in
                    self.setContentOffset(self.contentOffset(for: firstResponderView), animated: false)
                    self.layoutIfNeeded()
            }) { (finished) -> Void in
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextResponder = self.nextResponder() {
            nextResponder.becomeFirstResponder()
            scrollToResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    private func nextResponder() -> UIView? {
        guard !self.subviews.isEmpty else { return nil }
    
        var shouldBecomeFirstResponder = false
        
        func findNextResponder(in views: [UIView]) -> UIView? {
            for view in views {
                if view.isFirstResponder {
                    shouldBecomeFirstResponder = true
                } else if view.canBecomeFirstResponder, shouldBecomeFirstResponder {
                    return view
                } else if let nextResponder = findNextResponder(in: view.subviews) {
                    return nextResponder
                }
            }
            return nil
        }

        return findNextResponder(in: subviews)
    }
}
