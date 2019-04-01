//
//  File.swift
//  RxKeybaordAvoidingScrollableViewTests
//
//  Created by Amey Tavkar on 29/03/19.
//  Copyright © 2019 Amey Tavkar. All rights reserved.
//

import UIKit

class MockKeyboard {
    
    private let frame: CGRect
    
    var origin: CGPoint {
        return frame.origin
    }
    
    init(with frame: CGRect) {
        self.frame = frame
    }
    
    func show() {
        let value = NSValue(cgRect: frame)
        let userInfo = [UIResponder.keyboardFrameEndUserInfoKey: value]
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: userInfo)
    }
    
    func hide() {
        
    }
}
