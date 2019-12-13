//
//  AlunoAvaliacaoView.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 07/10/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit
import SQLite3

final class AlunoAvaliacaoView: UIView {
    //MARK: Constants
    fileprivate struct Constants {
        static let arrayNotaInteira = [semNota, zero, "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        static let arrayNotaDecimal = [zero, "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        static let arrayNotaCentena = [zero, "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        static let ponto = "."
        static let semNota = "S/N"
        static let virgula = ","
        static let zero = "0"
    }
    
    //MARK: Outlets
    @IBOutlet weak var alturaConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var notaView: UIView!
    @IBOutlet fileprivate weak var labelNome: UILabel!
    @IBOutlet fileprivate weak var labelNota: UILabel!
    @IBOutlet fileprivate weak var buttonConfirmar: UIButton!
    @IBOutlet fileprivate weak var pickerInteiro: UIPickerView!
    @IBOutlet fileprivate weak var pickerDecimal: UIPickerView!
    @IBOutlet fileprivate weak var pickerCentena: UIPickerView!
    
    //MARK: Variables
    weak var delegate: AlunoAvaliacaoDelegate!
    var totalAlunos: Int!
    var valorNotaSelecionada: Float?
    var notaAluno: NotaAluno?
    var aluno: Aluno! {
        didSet {
            configureView()
        }
    }

    //MARK: Constructor
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notaView.setShadow(enable: true, shadowOffset: CGSize(width: .zero, height: 3), shadowOpacity: 0.4)
    }

    //MARK: Actions
    @IBAction fileprivate func aplicar(sender _: UIButton) {
        delegate.avaliouAluno(aluno: aluno, view: self)
    }

    @IBAction func mostrarDetalhesDoAluno(_ sender: Any) {
        delegate.mostrarDetalhes(aluno: aluno)
    }
    
    //MARK: Methods
    fileprivate func getListaParaOPicker(tag: Int) -> [String] {
        return [Constants.arrayNotaInteira, Constants.arrayNotaDecimal, Constants.arrayNotaCentena][tag]
    }

    fileprivate func setConfirmButtonEnable(isEnable: Bool, showColor: Bool) {
        buttonConfirmar.isEnabled = isEnable
        buttonConfirmar.backgroundColor = Cores.confirmaNota
        buttonConfirmar.setShadow(enable: isEnable)
        if !isEnable && !showColor {
            buttonConfirmar.backgroundColor = Cores.diaNaoLetivo.withAlphaComponent(0.7)
        }
    }
    
    fileprivate func configureView() {
        labelNome.text = String(aluno.numeroChamada) + " - " + aluno.nome.uppercased()
        let ativo = aluno.alunoAtivo()
        pickerInteiro.isUserInteractionEnabled = ativo
        pickerCentena.isUserInteractionEnabled = ativo
        pickerDecimal.isUserInteractionEnabled = ativo
        if !ativo {
            setConfirmButtonEnable(isEnable: false, showColor: false)
        }
        else {
            setConfirmButtonEnable(isEnable: true, showColor: true)
        }
        valorNotaSelecionada = nil
        if let nota = notaAluno?.nota {
            let arrayNota = String(nota).components(separatedBy: Constants.ponto)
            if !arrayNota.isEmpty {
                var decimal = Constants.zero
                var centena = Constants.zero
                if arrayNota.count > 1, let ultimaNota = arrayNota.last, ultimaNota.count > 1 {
                    let nota = arrayNota[1]
                    decimal = String(nota.first!)
                    centena = String(nota.last!)
                }
                else {
                    decimal = String(arrayNota.last!.first!)
                }
                setNota(isActive: ativo, inteira: arrayNota.first!, decimal: decimal, centena: centena)
            }
        }
        else {
            setNota(isActive: ativo, inteira: Constants.semNota, decimal: Constants.zero, centena: Constants.zero)
        }
    }

    fileprivate func setNota(isActive: Bool, inteira: String, decimal: String, centena: String) {
        if inteira == "10" {
            pickerDecimal.isUserInteractionEnabled = false
            pickerCentena.isUserInteractionEnabled = false
        }
        pickerInteiro.selectRow(Constants.arrayNotaInteira.firstIndex(of: inteira)!, inComponent: .zero, animated: true)
        pickerDecimal.selectRow(Constants.arrayNotaDecimal.firstIndex(of: decimal)!, inComponent: .zero, animated: true)
        pickerCentena.selectRow(Constants.arrayNotaCentena.firstIndex(of: centena)!, inComponent: .zero, animated: true)
        let isInt = Int(inteira) != nil
        if isActive {
            if isInt {
                setConfirmButtonEnable(isEnable: true, showColor: true)
            }
            else {
                setConfirmButtonEnable(isEnable: false, showColor: true)
            }
        }
        var nota = Localization.nota.localized + String(inteira)
        if isInt {
            nota = nota + Constants.virgula + String(decimal) + String(centena)
        }
        labelNota.text = nota
    }
}

//MARK: UIPickerViewDataSource
extension AlunoAvaliacaoView: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return getListaParaOPicker(tag: pickerView.tag).count
    }
}

//MARK: UIPickerViewDelegate
extension AlunoAvaliacaoView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        return NSAttributedString(string: getListaParaOPicker(tag: pickerView.tag)[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        if pickerView.tag == .zero && (row == .zero || row == getListaParaOPicker(tag: .zero).count - 1) {
            pickerDecimal.isUserInteractionEnabled = false
            pickerCentena.isUserInteractionEnabled = false
            pickerDecimal.selectRow(.zero, inComponent: .zero, animated: true)
            pickerCentena.selectRow(.zero, inComponent: .zero, animated: true)
        }
        else {
            pickerDecimal.isUserInteractionEnabled = true
            pickerCentena.isUserInteractionEnabled = true
        }
        var nota = Localization.nota.localized
        if pickerInteiro.selectedRow(inComponent: .zero) == .zero {
            nota += Constants.arrayNotaInteira[.zero]
            valorNotaSelecionada = nil
            setConfirmButtonEnable(isEnable: false, showColor: true)
        }
        else {
            setConfirmButtonEnable(isEnable: true, showColor: true)
            let notaSelecionada = "\(Constants.arrayNotaInteira[pickerInteiro!.selectedRow(inComponent: .zero)]),\(Constants.arrayNotaDecimal[pickerDecimal!.selectedRow(inComponent: .zero)])\(Constants.arrayNotaCentena[pickerCentena!.selectedRow(inComponent: .zero)])"
            nota += notaSelecionada
            if let value = Float(notaSelecionada.replacingOccurrences(of: Constants.virgula, with: Constants.ponto)) {
                let formatedValue = value.roundToDecimal(digits: 2)
                valorNotaSelecionada = formatedValue
            }
        }
        labelNota?.text = nota
    }
}
