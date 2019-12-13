//
//  HabilidadeTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 25/10/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class ConteudoTableViewCell: UITableViewCell {
    //MARK: Variables
    var row: Int!
    var conteudo: Conteudo!

    //MARK: Methods
    func configurarCelula(selecionado: Bool, row: Int, conteudo: Conteudo) {
        tag = row
        textLabel?.numberOfLines = .zero
        textLabel?.font = .systemFont(ofSize: 15.0)
        textLabel?.textColor = .darkGray
        textLabel?.text = conteudo.descricao
        textLabel?.sizeToFit()
        if selecionado {
            accessoryType = .checkmark
        }
        else {
            accessoryType = .none
        }
    }
}
