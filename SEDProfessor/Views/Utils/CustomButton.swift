//
//  CustomButton.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 24/02/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

@IBDesignable
final class CustomButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = .zero {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

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

    @IBInspectable var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }

    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowRadius: CGFloat = .zero{
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var shadowOpacity: Float = .zero {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
}
