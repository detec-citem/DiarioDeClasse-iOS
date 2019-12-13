//
//  AlunoFrequenciaView.swift
//  PrototipoFrequencia
//
//  Created by Victor Bozelli Alvarez on 18/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

protocol AlunoFrequenciaDelegate {
    func alunoFrequencia(atribuiuFrequencia: AlunoFrequenciaView)
}

final class AlunoFrequenciaView: UIView {
    //MARK: Constants
    fileprivate struct Constants {
        static let alunoFrequenciaView = "AlunoFrequenciaView"
        static let alunoFrequenciaViewPad = "AlunoFrequenciaViewPad"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate var nome: UILabel!
    @IBOutlet fileprivate var faltasAno: UILabel!
    @IBOutlet fileprivate var faltasBimestre: UILabel!
    @IBOutlet fileprivate var presenca: CustomLabel!
    @IBOutlet fileprivate var compareceu: CustomButton!
    @IBOutlet fileprivate var faltou: CustomButton!
    @IBOutlet fileprivate var naoAplica: CustomButton!
    
    //MARK: Variables
    fileprivate var aluno: Aluno!
    fileprivate var totalAulas: TotalAulas! = (0, 0)
    fileprivate var faltaAluno: FaltaAluno!
    fileprivate var tipoFalta: TipoFrequencia!
    fileprivate var totalFaltasAluno: TotalFaltasAluno!
    fileprivate var customView: UIView!
    
    var delegate: AlunoFrequenciaDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var nibName: String!
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            nibName = Constants.alunoFrequenciaView
        }
        else {
            nibName = Constants.alunoFrequenciaViewPad
        }
        customView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[.zero] as? UIView
        customView.center = center
        addSubview(customView)
    }
    
    override func draw(_: CGRect) {
        customView.layer.cornerRadius = 6
        customView.setShadow(enable: true, shadowOffset: CGSize(width: .zero, height: 3), shadowOpacity: 0.4)
    }
    
    @IBAction fileprivate func btnCLick(sender: UIButton) {
        if let delegate = self.delegate {
            var tipo: TipoFrequencia?
            switch sender.tag
            {
            case .zero:
                tipo = .Transferido
            case 1:
                tipo = .Faltou
            case 2:
                tipo = .Compareceu
            default:
                break
            }
            if let tipo = tipo {
                configurarStatus(tipo: tipo)
                tipoFalta = tipo
                delegate.alunoFrequencia(atribuiuFrequencia: self)
            }
        }
    }
    
    func getAluno() -> Aluno? {
        return aluno
    }
    
    func getFaltaAluno() -> FaltaAluno? {
        return faltaAluno
    }
    
    func getTipoFalta() -> TipoFrequencia? {
        return tipoFalta
    }
    
    func set(faltaAluno: FaltaAluno, totalFaltasAluno: TotalFaltasAluno, totalAulas: TotalAulas) {
        self.faltaAluno = faltaAluno
        self.totalFaltasAluno = totalFaltasAluno
        self.totalAulas = totalAulas
    }
    
    func set(aluno: Aluno, count: UInt16, isSyncFinished: Bool) {
        self.aluno = aluno
        nome.text = String(aluno.numeroChamada) + "/" + String(count) + " - " + aluno.nome.uppercased()
        if aluno.alunoAtivo() {
            setupFaltas(novaFalta: false)
            setupTransferido(isTransferido: false)
            if isSyncFinished {
                setButtons(enable: true)
            }
            if let faltaAluno = faltaAluno?.tipo {
                switch faltaAluno {
                case TipoFrequencia.Compareceu.rawValue:
                    configurarStatus(tipo: .Compareceu)
                case TipoFrequencia.Faltou.rawValue:
                    configurarStatus(tipo: .Faltou)
                default:
                    configurarStatus(tipo: .Transferido)
                }
            }
            else {
                presenca.isHidden = true
            }
        }
        else {
            setupTransferido(isTransferido: true)
        }
    }
    
    fileprivate func setButtons(enable: Bool) {
        compareceu.isEnabled = enable
        faltou.isEnabled = enable
        naoAplica.isEnabled = enable
    }
    
    fileprivate func setupFaltas(novaFalta: Bool) {
        if var faltasAno = totalFaltasAluno?.faltasAnuais, var faltasBimestre = totalFaltasAluno?.faltasBimestrais, let totalAulasAno = totalAulas?.aulasAno, let totalAulasBimestre = totalAulas?.aulasBimestre {
            if novaFalta {
                faltasAno += 1
                faltasBimestre += 1
            }
            
            let fPerAno = (Double(faltasAno) * 100) / Double(totalAulasAno)
            let fPerBimestre = (Double(faltasBimestre) * 100) / Double(totalAulasBimestre)
            self.faltasAno.text = "\(faltasAno) (\(String.localizedStringWithFormat("%.1f", fPerAno))%)".uppercased()
            self.faltasBimestre.text = "\(faltasBimestre) (\(String.localizedStringWithFormat("%.1f", fPerBimestre))%)".uppercased()
        }
    }
    
    fileprivate func configurarStatus(tipo: TipoFrequencia) {
        presenca.isHidden = false
        switch tipo {
        case .Transferido:
            presenca.text = Localization.naoAplicavel.localized
            presenca.backgroundColor = Cores.naoAplicavel
            setupFaltas(novaFalta: false)
        case .Faltou:
            presenca.text = Localization.faltou.localized
            presenca.backgroundColor = Cores.falta1
            setupFaltas(novaFalta: true)
        case .Compareceu:
            presenca.text = Localization.compareceu.localized
            presenca.backgroundColor = Cores.defaultApp
            setupFaltas(novaFalta: false)
        default:
            break
        }
    }
    
    fileprivate func setupTransferido(isTransferido: Bool) {
        presenca.isHidden = false
        setButtons(enable: !isTransferido)
        naoAplica.setShadow(enable: !isTransferido)
        faltou.setShadow(enable: !isTransferido)
        compareceu.setShadow(enable: !isTransferido)
        presenca.setShadow(enable: !isTransferido)
        if isTransferido {
            let corDiaNaoLetivo = Cores.diaNaoLetivo.withAlphaComponent(0.7)
            compareceu.backgroundColor = corDiaNaoLetivo
            faltou.backgroundColor = corDiaNaoLetivo
            naoAplica.backgroundColor = corDiaNaoLetivo
            presenca.text = aluno?.ativo.uppercased()
            presenca.backgroundColor = corDiaNaoLetivo
        }
        else {
            compareceu.backgroundColor = Cores.defaultApp
            faltou.backgroundColor = Cores.falta1
            naoAplica.backgroundColor = Cores.naoAplicavel
        }
    }
}
