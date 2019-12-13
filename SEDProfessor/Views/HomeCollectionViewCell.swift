//
//  SEDHomeCollectionView.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 26/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell {
    //MARK: Variables
    var textLabel: UILabel!
    var imageView: UIImageView!
    var home: MenuItem! {
        didSet {
            configurarCelula()
        }
    }

    //MARK: Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView == nil {
            clipsToBounds = false
            contentView.clipsToBounds = false
            var altura: CGFloat = frame.size.height
            if UIDevice.current.userInterfaceIdiom == .pad {
                altura = frame.size.height * 2 / 1.8
            }
            imageView = UIImageView(frame: CGRect(x: .zero, y: .zero, width: frame.size.width, height: altura))
            imageView.contentMode = .scaleAspectFit
            contentView.addSubview(imageView)
            textLabel = UILabel(frame: CGRect(x: .zero, y: imageView.frame.size.height + 7, width: frame.size.width + 30, height: frame.size.height / 5))
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.backgroundColor = .clear
            textLabel.textAlignment = .center
            textLabel.textColor = .black
            textLabel.center.x = contentView.center.x
            textLabel.font = .boldSystemFont(ofSize: 16)
            contentView.addSubview(textLabel)
        }
    }
    
    //MARK: Methods
    fileprivate func configurarCelula() {
        layoutIfNeeded()
        textLabel.text = home.title
        if let image = home.imageName {
            imageView.image = UIImage(named: image)
        }
    }
}
