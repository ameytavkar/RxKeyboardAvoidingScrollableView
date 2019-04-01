//
//  RxKeyboardAvoidingScrollableViewTests.swift
//  RxKeyboardAvoidingScrollableViewTests
//
//  Created by Amey Tavkar on 30/03/19.
//  Copyright © 2019 Amey Tavkar. All rights reserved.
//

import XCTest
@testable import RxKeyboardAvoidingScrollableView

class RxKeyboardAvoidingScrollableViewTests: XCTestCase {
    
    var testScrollView = RxKeyboardAvoidingScrollView(frame: CGRect(x: 0, y: 44, width: 375, height: 734))
    var mockKeyboard = MockKeyboard(with: CGRect(x: 0, y: 550, width: 414, height: 346))
    
    func test_keyboardFrameChange_shouldUpdateContentIntent() {
        mockKeyboard.show()
        let expectedInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: testScrollView.bounds.height - mockKeyboard.origin.y + 44,
            right: 0)
        XCTAssertEqual(testScrollView.contentInset, expectedInsets)
    }
}
