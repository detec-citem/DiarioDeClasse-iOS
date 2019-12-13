//
//  AlunoFechamentoView.swift
//  SEDProfessor
//
//  Created by Richard on 20/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import UIKit

protocol AlunoFechamentoDelegate: class {
    func alunoFechamento(atribuiuFechamento: AlunoFechamentoView)
    // func showDetails(student: AlunoModel?)
}

final class AlunoFechamentoView: UIView, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    //MARK: Outlets
    @IBOutlet fileprivate var pickerNota: UIPickerView!
    @IBOutlet fileprivate var pickerFalta: UIPickerView!
    @IBOutlet fileprivate var pickerFaltasCompensadas: UIPickerView!
    @IBOutlet fileprivate var labelFaltasAcumuladas: UILabel!
    @IBOutlet fileprivate var buttonConfirmar: UIButton!
    @IBOutlet fileprivate var nome: CustomLabel!
    
    //MARK: Variables
    fileprivate var confirmed = false
    fileprivate var faltas: UInt32 = .zero
    fileprivate var faltasAcumuladas: UInt32 = .zero
    fileprivate var faltasCompensadas: UInt32 = .zero
    fileprivate var quantidadeAlunos: UInt16?
    fileprivate var nota: Int?
    fileprivate var numberOfFaults: Int = 101
    fileprivate var aluno: Aluno!
    fileprivate var averageAluno: Average?
    fileprivate var fechamentoAluno: FechamentoAluno?
    fileprivate var totalFaltasAluno: TotalFaltasAluno?
    fileprivate var pickerNotaValues = ["S/N", 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] as [Any]
    fileprivate var customView: UIView?
    weak var delegate: AlunoFechamentoDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customView = Bundle.main.loadNibNamed(AlunoFechamentoView.className, owner: self, options: nil)?[0] as? UIView
        customView?.center = center
        if let view = customView {
            addSubview(view)
        }
    }
    
    override func draw(_: CGRect) {
        customView?.layer.cornerRadius = 6
        customView?.setShadow(enable: true, shadowOffset: CGSize(width: .zero, height: 3), shadowOpacity: 0.4)
    }
    
    //    @IBAction fileprivate func showDetails() {
    //        self.delegate?.showDetails(student: getAluno())
    //    }
    
    @IBAction fileprivate func btnCLick(sender _: UIButton) {
        `set`(confirm: true)
        if let delegate = self.delegate {
            delegate.alunoFechamento(atribuiuFechamento: self)
        }
    }
    
    func isConfirmed() -> Bool {
        return confirmed
    }
    
    func getAluno() -> Aluno? {
        return aluno
    }
    
    func getNota() -> Int? {
        return nota
    }
    
    func getFaltas() -> UInt32 {
        return faltas
    }
    
    func getFaltasAcumuladas() -> UInt32 {
        return faltasAcumuladas
    }
    
    func getFaltasCompensadas() -> UInt32 {
        return faltasCompensadas
    }
    
    func set(fechamentoAluno: FechamentoAluno?, averageAluno: Average?, totalFaltasAluno: TotalFaltasAluno?) {
        self.fechamentoAluno = fechamentoAluno
        self.averageAluno = averageAluno
        self.totalFaltasAluno = totalFaltasAluno
    }
    
    func set(aluno: Aluno, count: UInt16) {
        self.aluno = aluno
        quantidadeAlunos = count
        var chamada = String()
        if let qtdAlunos = quantidadeAlunos {
            chamada = "\(aluno.numeroChamada)/\(qtdAlunos)"
        }
        else {
            chamada = "\(aluno.numeroChamada)"
        }
        nome.text = "\(chamada) - \(aluno.nome)".uppercased()
        if aluno.alunoAtivo() {
            setupTransferido(isTransferido: false)
            guard let fechamentoAluno = fechamentoAluno else {
                if let faltasBimestre = totalFaltasAluno?.faltasBimestrais {
                    self.faltas = faltasBimestre
                    pickerFalta.selectRow(Int(faltasBimestre), inComponent: .zero, animated: true)
                }
                if let averageValue = averageAluno?.value {
                    setup(nota: Int(averageValue))
                }
                
                set(confirm: false)
                return
            }
            set(confirm: true)
            let faltas = fechamentoAluno.faltas
            self.faltas = faltas
            pickerFalta.selectRow(Int(faltas), inComponent: .zero, animated: true)
            let faltasCompensadas = fechamentoAluno.faltasCompensadas
            self.faltasCompensadas = faltasCompensadas
            pickerFalta.selectRow(Int(faltasCompensadas), inComponent: .zero, animated: true)
            if let nota = fechamentoAluno.nota as? Int {
                setup(nota: nota)
            }
        }
        else {
            setupTransferido(isTransferido: true)
        }
    }
    
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        if pickerView == pickerNota {
            return pickerNotaValues.count
        }
        if pickerView == pickerFaltasCompensadas {
            return Int(faltas + 1)
        }
        return numberOfFaults
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        if pickerView == pickerNota {
            return "\(pickerNotaValues[row])"
        }
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow _: Int, inComponent _: Int) {
        set(confirm: false)
        switch pickerView
        {
        case pickerNota:
            nota = pickerNotaValues[pickerNota.selectedRow(inComponent: .zero)] as? Int
        case pickerFalta:
            faltas = UInt32(pickerFalta.selectedRow(inComponent: .zero))
        case pickerFaltasCompensadas:
            faltasCompensadas = UInt32(pickerFaltasCompensadas.selectedRow(inComponent: .zero))
        default:
            break
        }
        if pickerView == pickerFalta || pickerView == pickerFaltasCompensadas {
            pickerFaltasCompensadas.reloadComponent(.zero)
            faltasAcumuladas = faltas - faltasCompensadas
            labelFaltasAcumuladas.text = "\(faltasAcumuladas)"
        }
    }
    
    fileprivate func setup(nota: Int?) {
        self.nota = nota
        if let nota = nota {
            pickerNota.selectRow(nota + 1, inComponent: .zero, animated: true)
        } else {
            pickerNota.selectRow(.zero, inComponent: .zero, animated: true)
        }
    }
    
    fileprivate func set(confirm: Bool) {
        confirmed = confirm
        if confirm {
            buttonConfirmar.isEnabled = false
            buttonConfirmar.setTitle(Localization.confirmado.localized, for: .normal)
            buttonConfirmar.backgroundColor = Cores.defaultApp.withAlphaComponent(0.7)
        }
        else {
            buttonConfirmar.isEnabled = true
            buttonConfirmar.setTitle(Localization.confirmar.localized, for: .normal)
            buttonConfirmar.backgroundColor = Cores.confirmaNota.withAlphaComponent(0.7)
        }
    }
    
    fileprivate func setupTransferido(isTransferido: Bool) {
        if isTransferido {
            isUserInteractionEnabled = false
            pickerNota.alpha = 0.6
            pickerFalta.alpha = 0.6
            pickerFaltasCompensadas.alpha = 0.6
            labelFaltasAcumuladas.alpha = 0.6
            buttonConfirmar.setTitle(aluno.ativo.uppercased(), for: .normal)
            buttonConfirmar.backgroundColor = Cores.diaNaoLetivo.withAlphaComponent(0.7)
            pickerNotaValues = ["S/N"]
            pickerNota.reloadComponent(.zero)
            numberOfFaults = 1
            pickerFalta.reloadComponent(.zero)
        }
        else {
            isUserInteractionEnabled = true
            labelFaltasAcumuladas.alpha = 1
            pickerFalta.alpha = 1
            pickerFaltasCompensadas.alpha = 1
            pickerNota.alpha = 1
            buttonConfirmar.setTitle(Localization.confirmar.localized, for: .normal)
            buttonConfirmar.backgroundColor = Cores.confirmaNota.withAlphaComponent(0.7)
        }
    }
}
