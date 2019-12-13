//
//  TurmaTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 19/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class TurmaTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet fileprivate weak var disciplinaLabel: UILabel!
    @IBOutlet fileprivate weak var tipoDeEnsinoLabel: UILabel!
    @IBOutlet fileprivate weak var nomeLabel: UILabel!

    //MARK: Variables
    fileprivate var accessoryButton = UIButton()
    var tipoTurma: TipoTela!
    var frequencia: Frequencia! {
        didSet {
            configurarCelula()
        }
    }
    
    //MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    //MARK: Methods
    fileprivate func configurarCelula() {
        let disciplina = frequencia.disciplina
        disciplinaLabel.text = disciplina.nome.uppercased()
        let turma = frequencia.turma
        tipoDeEnsinoLabel.text = turma.nomeTipoEnsino.uppercased()
        nomeLabel.text = turma.nome.uppercased()
        UILabel.configure(labels: [disciplinaLabel], font: .boldSystemFont(ofSize: 13), color: .black)
        UILabel.configure(labels: [tipoDeEnsinoLabel], font: .systemFont(ofSize: 13), color: Cores.lightBlack)
        UILabel.configure(labels: [nomeLabel], font: .boldSystemFont(ofSize: 14), color: Cores.defaultApp)
    }
}
