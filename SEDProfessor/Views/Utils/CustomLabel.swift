//
//  CustomLabel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 19/04/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class CustomLabel: UILabel {
    @IBInspectable var leftEdge: CGFloat = .zero
    @IBInspectable var rightEdge: CGFloat = .zero
    @IBInspectable var topEdge: CGFloat = .zero
    @IBInspectable var bottomEdge: CGFloat = .zero
    var edgeInsets: (left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat)?
    @IBInspectable var borderWidth: CGFloat = .zero {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var cornerRadius: CGFloat = .zero {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }

    override func drawText(in rect: CGRect) {
        var insets = UIEdgeInsets()
        if let edgeInsets = self.edgeInsets {
            insets = UIEdgeInsets(top: edgeInsets.top, left: edgeInsets.left, bottom: edgeInsets.bottom, right: edgeInsets.right)
        }
        else {
            insets = UIEdgeInsets(top: topEdge, left: leftEdge, bottom: bottomEdge, right: rightEdge)
        }
        super.drawText(in: rect.inset(by: insets))
    }
}
