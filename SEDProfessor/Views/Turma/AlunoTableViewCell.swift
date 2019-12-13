//
//  ListaAlunoTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 09/03/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class AlunoTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet fileprivate var studentNameLabel: UILabel!
    @IBOutlet fileprivate var studentStatusLabel: UILabel!

    //MARK: Variables
    var aluno: Aluno! {
        didSet {
            configurarCelula()
        }
    }

    //MARK: Methods
    fileprivate func configurarCelula() {
        studentNameLabel.text = aluno.nome.uppercased()
        UILabel.configure(labels: [studentNameLabel], font: .boldSystemFont(ofSize: 13), color: .black)
        UILabel.configure(labels: [studentStatusLabel], font: .systemFont(ofSize: 13), color: .darkGray)
        let studentStatusText = Localization.status.localized
        if aluno.alunoAtivo() {
            studentStatusLabel.text = studentStatusText + Localization.ativo.localized.uppercased()
        }
        else {
            studentStatusLabel.text = studentStatusText + Localization.inativo.localized
        }
        studentStatusLabel.setTextColor(color: Cores.lightBlack, to: studentStatusText)
    }
}
