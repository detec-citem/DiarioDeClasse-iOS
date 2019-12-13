//
//  ListagemCellFrequencia.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 03/02/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

protocol AlunoFrequenciaDelegateCell {
    func alunoFrequencia(atribuiuFrequencia: ListagemCellFrequencia, linha: Int)
}

final class ListagemCellFrequencia: UITableViewCell {
    //MARK: Outlets
    @IBOutlet var labelNome: UILabel!
    @IBOutlet var resultadoBtn: UIButton!
    @IBOutlet var faltaButton: UIButton!
    @IBOutlet var naoSeAplicaButton: UIButton!
    @IBOutlet var compareceuButton: UIButton!
    @IBOutlet var faltasAnoLabel: UILabel!
    @IBOutlet var faltasBimestreLabel: UILabel!
    
    //MARK: Variables
    fileprivate var totalAulas: TotalAulas? = (0, 0)
    var linha: Int!
    var delegate: AlunoFrequenciaDelegateCell!
    var faltasAnoVar : UInt32!
    var faltasBimestreVar: UInt32!
    var totalFaltasAno: UInt32!
    var totalFaltasBimestre: UInt32!
    var aluno: Aluno!
    var faltaAluno: FaltaAluno?
    var tipoFalta: TipoFrequencia?
    var totalFaltasAluno: TotalFaltasAluno!
    
    //MARK: Actions
    @IBAction fileprivate func btnCLick(sender: UIButton) {
        var tipo: TipoFrequencia?
        switch sender.tag {
        case 0:
            tipo = .NA
        case 1:
            tipo = .Compareceu
        case 2:
            tipo = .Faltou
        default:
            break
        }
        if let tipo = tipo {
            resultadoBtn.isHidden = false
            configurarStatus(tipoFrequencia: tipo)
            tipoFalta = tipo
            delegate.alunoFrequencia(atribuiuFrequencia: self, linha: linha)
        }
    }
    
    //MARK: Methods
    func configurarCelula(aluno: Aluno, falta: FaltaAluno?, linha: Int) {
        self.linha = linha
        self.aluno = aluno
        faltaAluno = falta
        let chamadaString = String(aluno.numeroChamada)
        labelNome.text = chamadaString + " - " + aluno.nome.uppercased()
        labelNome.setFont(font: .boldSystemFont(ofSize: 14), to: chamadaString)
        if aluno.alunoAtivo() {
            resultadoBtn.isHidden = false
            labelNome.textColor = .black
            if let falta = falta {
                switch falta.tipo {
                case TipoFrequencia.Compareceu.rawValue:
                    configurarStatus(tipoFrequencia: .Compareceu)
                case TipoFrequencia.Faltou.rawValue:
                    configurarStatus(tipoFrequencia: .Faltou)
                case TipoFrequencia.NA.rawValue:
                    configurarStatus(tipoFrequencia: .NA)
                case TipoFrequencia.Transferido.rawValue:
                    configurarStatus(tipoFrequencia: .Transferido)
                default:
                    configurarStatus(tipoFrequencia: .NA)
                    break
                }
            }
            else {
                resultadoBtn.setTitle(nil, for: .normal)
                resultadoBtn.setTitleColor(.white, for: .normal)
                resultadoBtn.backgroundColor = .white
                setHiddenButtons(hidden: false)
                setEnabledButtons(compareceuBtn: true, faltaBtn: true, naoSeAplicaBtn: true)
            }
        }
        else {
            resultadoBtn.isHidden = false
            configurarStatus(tipoFrequencia: .Transferido)
            labelNome.textColor = Cores.diaNaoLetivo
        }
    }
    
    func setHiddenButtons(hidden: Bool) {
        compareceuButton.isHidden = hidden
        faltaButton.isHidden = hidden
        naoSeAplicaButton.isHidden = hidden
    }
    
    func setEnabledButtons(compareceuBtn: Bool, faltaBtn: Bool, naoSeAplicaBtn: Bool) {
        compareceuButton.isEnabled = compareceuBtn
        faltaButton.isEnabled = faltaBtn
        naoSeAplicaButton.isEnabled = naoSeAplicaBtn
    }
    
    fileprivate func configurarStatus(tipoFrequencia: TipoFrequencia) {
        switch tipoFrequencia {
        case .NA:
            resultadoBtn.setTitle(tipoFrequencia.rawValue, for: .normal)
            resultadoBtn.setTitleColor(UIColor.white, for: .normal)
            resultadoBtn.backgroundColor = Cores.naoAplicavel
            setHiddenButtons(hidden: false)
            setupFaltas(novaFalta: false)
            setEnabledButtons(compareceuBtn: true, faltaBtn: true, naoSeAplicaBtn: false)
        case .Transferido:
            resultadoBtn.setTitle(tipoFrequencia.rawValue, for: .normal)
            resultadoBtn.setTitleColor(Cores.naoAplicavel, for: .normal)
            resultadoBtn.backgroundColor = UIColor.white
            setHiddenButtons(hidden: true)
            setupFaltas(novaFalta: false)
        case .Faltou:
            resultadoBtn.setTitle(tipoFrequencia.rawValue, for: .normal)
            resultadoBtn.setTitleColor(UIColor.white, for: .normal)
            resultadoBtn.backgroundColor = Cores.falta1
            setHiddenButtons(hidden: false)
            setupFaltas(novaFalta: true)
            setEnabledButtons(compareceuBtn: true, faltaBtn: false, naoSeAplicaBtn: true)
        case .Compareceu:
            resultadoBtn.setTitle(tipoFrequencia.rawValue, for: .normal)
            resultadoBtn.setTitleColor(UIColor.white, for: .normal)
            resultadoBtn.backgroundColor = Cores.defaultApp
            setHiddenButtons(hidden: false)
            setupFaltas(novaFalta: false)
            setEnabledButtons(compareceuBtn: false, faltaBtn: true, naoSeAplicaBtn: true)
        }
    }
    
    fileprivate func setupFaltas(novaFalta: Bool) {
        if novaFalta {
            faltasAnoVar += 1
            faltasBimestreVar += 1
            totalFaltasAno += 1
            totalFaltasBimestre += 1
        }
        let fPerAno = (Double(faltasAnoVar) * 100) / Double(totalFaltasAno)
        let fPerBimestre = (Double(faltasBimestreVar) * 100) / Double(totalFaltasBimestre)
        faltasAnoLabel.text = String(faltasAnoVar) + " " + String.localizedStringWithFormat("%.1f", fPerAno) + "%"
        faltasBimestreLabel.text = String(faltasBimestreVar) + " " + String.localizedStringWithFormat("%.1f", fPerBimestre) + "%"
    }
}
