//
//  FechamentoTableViewCell.swift
//  SEDProfessor
//
//  Created by Richard on 03/03/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import UIKit

final class FechamentoTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet fileprivate var labelNome: UILabel!
    @IBOutlet fileprivate var labelFaltas: UILabel!
    @IBOutlet fileprivate var labelFaltasAcumuladas: UILabel!
    @IBOutlet fileprivate var labelFaltasCompensadas: UILabel!

    //MARK: Variables
    fileprivate lazy var statusButton = CustomButton()
    var alunoFechamentoView: AlunoFechamentoView? {
        didSet {
            labelFaltas.text = "-"
            labelFaltas.textColor = .black
            labelFaltasAcumuladas.text = "-"
            labelFaltasAcumuladas.textColor = .black
            labelFaltasCompensadas.text = "-"
            labelFaltasCompensadas.textColor = .black
            labelNome.textColor = .black
            statusButton.frame = CGRect(x: .zero, y: .zero, width: 37, height: 37)
            statusButton.setTitleColor(.white, for: .normal)
            statusButton.cornerRadius = statusButton.frame.size.height / 2
            if let aluno = alunoFechamentoView?.getAluno() {
                let numeroChamadaString = String(aluno.numeroChamada)
                labelNome.text = numeroChamadaString + " - " + aluno.nome.uppercased()
                labelNome.setFont(font: .boldSystemFont(ofSize: 15), to: numeroChamadaString)
                if aluno.alunoAtivo() {
                    if let alunoFechamentoView = alunoFechamentoView {
                        let faltas = alunoFechamentoView.getFaltas()
                        var faltasString = String(faltas)
                        if faltas == 1 {
                            faltasString += " Falta"
                        }
                        else {
                            faltasString += " Faltas"
                        }
                        labelFaltas.text = faltasString
                        labelFaltasAcumuladas.text = String(alunoFechamentoView.getFaltasAcumuladas()) + " F/A"
                        labelFaltasCompensadas.text = String(alunoFechamentoView.getFaltasCompensadas()) + " F/C"
                        let isConfirmed = alunoFechamentoView.isConfirmed()
                        guard let nota = alunoFechamentoView.getNota() else {
                            if isConfirmed {
                                setupButton(tipo: .ConfirmouSemNota, nota: nil)
                            }
                            else {
                                setupButton(tipo: .NaoConfirmouSemNota, nota: nil)
                            }
                            return
                        }
                        setupButton(tipo: .NaoConfirmou, nota: nota)
                        if isConfirmed {
                            setupButton(tipo: .Confirmou, nota: nota)
                        }
                    }
                    else {
                        setupButton(tipo: .ConfirmouSemNota, nota: nil)
                    }
                    labelNome.textColor = .black
                }
                else {
                    labelFaltas.textColor = .darkGray
                    labelFaltasAcumuladas.textColor = .darkGray
                    labelFaltasCompensadas.textColor = .darkGray
                    labelNome.textColor = .darkGray
                    setupButton(tipo: .Transferido, nota: nil)
                }
            }
        }
    }

    fileprivate func setupButton(tipo: TipoFechamento, nota: Int?) {
        accessoryType = .none
        accessoryView = statusButton
        switch tipo {
        case .Transferido:
            statusButton.setTitle(TipoFrequencia.Transferido.rawValue, for: .normal)
            statusButton.titleLabel?.font = .systemFont(ofSize: 16)
            statusButton.backgroundColor = Cores.diaNaoLetivo.withAlphaComponent(0.7)
            statusButton.setShadow(enable: false)
        case .Confirmou:
            guard let nota = nota else { return }
            statusButton.setTitle("\(nota)", for: .normal)
            statusButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            statusButton.backgroundColor = Cores.defaultApp
            statusButton.setShadow(enable: true)
        case .NaoConfirmou:
            guard let nota = nota else { return }
            statusButton.setTitle("\(nota)", for: .normal)
            statusButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            statusButton.backgroundColor = Cores.confirmaNota.withAlphaComponent(0.7)
            statusButton.setShadow(enable: true)
        case .ConfirmouSemNota:
            statusButton.setTitle("S/N", for: .normal)
            statusButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
            statusButton.backgroundColor = Cores.defaultApp
            statusButton.setShadow(enable: true)
        default:
            statusButton.setTitle("S/N", for: .normal)
            statusButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
            statusButton.backgroundColor = Cores.confirmaNota.withAlphaComponent(0.7)
            statusButton.setShadow(enable: true)
            break
        }
    }
}
