//
//  TextFieldWCursor.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 14/07/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

final class TextFieldWCursor: UITextField {
    override func caretRect(for _: UITextPosition) -> CGRect {
        return .zero
    }

    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        super.addGestureRecognizer(gestureRecognizer)
    }

    override func canPerformAction(_: Selector, withSender _: Any?) -> Bool {
        return false
    }
}

class TextField: UITextField {
    let padding = UIEdgeInsets(top: .zero, left: 5, bottom: .zero, right: 5)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return newBounds(bounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return newBounds(bounds: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return newBounds(bounds: bounds)
    }

    fileprivate func newBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += padding.left
        newBounds.origin.y += padding.top
        newBounds.size.height -= padding.top + padding.bottom
        newBounds.size.width -= padding.left + padding.right
        return newBounds
    }
}
