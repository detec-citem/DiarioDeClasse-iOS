//
//  AvaliacaoTableViewCell.swift
//  SEDProfessor
//
//  Created by Alexandre Furquim on 04/02/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class NotaTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet var labelNome: UILabel!
    
    //MARK: Variables
    var statusButton = CustomButton()
    var aluno: Aluno!
    var nota: Float? {
        didSet {
            configureCell()
        }
    }
    
    //MARK: Methods
    fileprivate func configureCell() {
        statusButton.frame = CGRect(x: .zero, y: .zero, width: 37, height: 37)
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.cornerRadius = statusButton.frame.size.height / 2
        let chamadaString = String(aluno.numeroChamada)
        labelNome.text = chamadaString + " - " + aluno.nome.uppercased()
        labelNome.setFont(font: .boldSystemFont(ofSize: 15), to: chamadaString)
        if aluno.alunoAtivo() {
            labelNome.textColor = .black
            if let nota = nota {
                setupButton(tipo: .Compareceu, nota: nota)
            }
            else {
                setupButton(tipo: .NA, nota: nil)
            }
        }
        else {
            labelNome.textColor = .darkGray
            setupButton(tipo: .Transferido, nota: nil)
        }
    }
    
    fileprivate func setupButton(tipo: TipoFrequencia, nota: Float?) {
        accessoryType = .none
        accessoryView = statusButton
        switch tipo
        {
        case .Transferido:
            statusButton.backgroundColor = Cores.diaNaoLetivo.withAlphaComponent(0.7)
            statusButton.titleLabel?.font = .systemFont(ofSize: 16)
            statusButton.setTitle(TipoFrequencia.Transferido.rawValue, for: .normal)
            statusButton.setShadow(enable: false)
        case .Compareceu:
            if let nota = nota {
                statusButton.backgroundColor = Cores.defaultApp
                statusButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
                statusButton.setTitle("\(nota.roundToDecimal(digits: 2))".replacingOccurrences(of: ".", with: ","), for: .normal)
                statusButton.setShadow(enable: true)
            }
        default:
            accessoryView = nil
            accessoryType = .disclosureIndicator
        }
    }
}
