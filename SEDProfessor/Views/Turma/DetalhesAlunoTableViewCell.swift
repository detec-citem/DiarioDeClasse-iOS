//
//  DetalhesAlunoTableViewCell.swift
//  SEDProfessor
//
//  Created by Kesley Ribeiro on 29/06/2018.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class DetalhesAlunoTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet fileprivate var turmaLabel: UILabel!
    @IBOutlet fileprivate var raAlunoLabel: UILabel!
    @IBOutlet fileprivate var statusAlunoLabel: UILabel!
    @IBOutlet fileprivate var dataNascimentoAlunoLabel: UILabel!
    @IBOutlet fileprivate var alunoPossuiDeficienciaLabel: UILabel!
    @IBOutlet fileprivate var responsaveisLabel: UILabel!
    @IBOutlet fileprivate var nomePaiLabel: UILabel!
    @IBOutlet fileprivate var nomeMaeLabel: UILabel!

    //MARK: Variables
    var aluno: Aluno? {
        didSet {
            configureCell()
        }
    }

    //MARK: Methods
    fileprivate func configureCell() {
        UILabel.configure(labels: [turmaLabel, raAlunoLabel, statusAlunoLabel, dataNascimentoAlunoLabel, alunoPossuiDeficienciaLabel, responsaveisLabel, nomePaiLabel, nomeMaeLabel], font: .boldSystemFont(ofSize: 13), color: .darkGray)
        let turmaText = "Turma: "
        if let turma = aluno?.turma.nome {
            turmaLabel.text = turmaText + turma.uppercased()
        }
        else {
            turmaLabel.text = turmaText
        }
        let raText = "RA: "
        if let ra = aluno?.ra, let digitoRa = aluno?.digitoRa {
            raAlunoLabel.text = raText + ra + "-" + digitoRa
        }
        else {
            raAlunoLabel.text = raText
        }
        let statusText = Localization.status.localized
        if let status = aluno?.ativo, !status.isEmpty {
            if status == Localization.ativo.localized {
                statusAlunoLabel.text = statusText + Localization.ativo.localized.uppercased()
            }
            else {
                statusAlunoLabel.text = statusText + Localization.inativo.localized
            }
        }
        else {
            statusAlunoLabel.text = statusText
        }
        let dataNascimentoText = "Data Nascimento: "
        if let data = aluno?.dataNascimento {
            dataNascimentoAlunoLabel.text = dataNascimentoText + data
        }
        else {
            dataNascimentoAlunoLabel.text = dataNascimentoText
        }
        let possuiDeficienciaText = "Necessidades Especiais: "
        if let necessidade = aluno?.possuiDeficiencia {
            alunoPossuiDeficienciaLabel.text = possuiDeficienciaText + necessidade
        }
        else {
            alunoPossuiDeficienciaLabel.text = possuiDeficienciaText
        }
        let nomePaiText = "Nome do pai: "
        if let nomePai = aluno?.pai, !nomePai.isEmpty {
            nomePaiLabel.text = nomePaiText + nomePai.uppercased()
        }
        else {
            nomePaiLabel.text = nomePaiText
        }
        let nomeMaeText = "Nome da mãe: "
        if let nomeMae = aluno?.mae, !nomeMae.isEmpty {
            nomeMaeLabel.text = nomeMaeText + nomeMae.uppercased()
        }
        else {
            nomeMaeLabel.text = nomeMaeText
        }
        responsaveisLabel.textColor = UIColor.black
        let lightBlackColor = Cores.lightBlack
        alunoPossuiDeficienciaLabel.setTextColor(color: lightBlackColor, to: possuiDeficienciaText)
        dataNascimentoAlunoLabel.setTextColor(color: lightBlackColor, to: dataNascimentoText)
        nomeMaeLabel.setTextColor(color: lightBlackColor, to: nomeMaeText)
        nomePaiLabel.setTextColor(color: lightBlackColor, to: nomePaiText)
        raAlunoLabel.setTextColor(color: lightBlackColor, to: raText)
        statusAlunoLabel.setTextColor(color: lightBlackColor, to: statusText)
        turmaLabel.setTextColor(color: lightBlackColor, to: turmaText)
    }
}
