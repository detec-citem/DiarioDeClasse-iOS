//
//  BimestreCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/2018.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class BimestreCollectionViewCell: UICollectionViewCell {
    //MARK: Outlets
    @IBOutlet fileprivate var bimestreLabel: UILabel!

    //MARK: Variables
    var bimestre: String! {
        didSet {
            configurarCelula()
        }
    }

    var selecionado: Bool! {
        didSet {
            configurarSelecionado()
        }
    }

    //MARK: Methods
    fileprivate func configurarCelula() {
        bimestreLabel.text = bimestre
    }

    fileprivate func configurarSelecionado() {
        layer.borderWidth = 1
        if selecionado {
            layer.borderColor = UIColor.blue.cgColor
            layer.backgroundColor = UIColor(red: 22.0/255.0, green: 176.0/255.0, blue: 92.0/255.0, alpha: 1).cgColor
        }
        else {
            layer.borderColor = UIColor.clear.cgColor
            layer.backgroundColor = UIColor(red: .zero, green: 144.0/255.0, blue: 71.0/255.0, alpha: 1).cgColor
        }
    }
}
