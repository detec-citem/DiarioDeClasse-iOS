//
//  HabilidadeTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 30/10/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class HabilidadeTableViewCell: UITableViewCell {
    //MARK: Variables
    var row: Int!
    var habilidade: Habilidade!
    
    //MARK: Methods
    func configurarCelula(selecionada: Bool, row: Int, habilidade: Habilidade) {
        tag = row
        textLabel?.numberOfLines = .zero
        textLabel?.font = .systemFont(ofSize: 15.0)
        textLabel?.textColor = .darkGray
        textLabel?.text = habilidade.descricao
        textLabel?.sizeToFit()
        if selecionada {
            accessoryType = .checkmark
        }
        else {
            accessoryType = .none
        }
    }
}
