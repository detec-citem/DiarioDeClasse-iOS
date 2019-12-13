//
//  NovaAvaliacaoViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 29/09/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import BetterSegmentedControl
import UIKit

protocol NovaAvaliacaoDelegate: class {
    func teveAlteracaoNasAvaliacoes(bimestre: UInt32)
}

final class NovaAvaliacaoViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let bimestre = "BIMESTRE"
        static let maximoCaracteresAvaliacao = 200
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate var bimestreLabel: UILabel!
    @IBOutlet fileprivate var notaSwitch: UISwitch!
    @IBOutlet fileprivate var nomeTextField: TextField!
    @IBOutlet fileprivate var dataTextfield: TextField!
    @IBOutlet fileprivate var segmentedControl: BetterSegmentedControl!
    
    //MARK: Variables
    fileprivate lazy var datasAula = Set<Date>()
    fileprivate var isUpdate = false
    fileprivate var valeNota = false
    fileprivate var codigoAvaliacao: Int32?
    fileprivate var codigoTipoAtividade: UInt32!
    fileprivate var selectedSegmentIndex: UInt32!
    fileprivate var dataMinima: Date!
    fileprivate var dataMaxima: Date!
    weak var delegate: NovaAvaliacaoDelegate!
    var avaliacaoSelecionada: Avaliacao?
    var bimestreSelecionado: Bimestre!
    var calendarioLetivo: [DiaLetivo]!
    var disciplinaSelecionada: Disciplina!
    var turmaSelecionada: Turma!
    var turmaSerie: String!
    var avaliacoes: [Avaliacao]?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CalendarioView.sharedInstance.delegate = self
        segmentedControl.backgroundColor = Cores.defaultApp
        segmentedControl.bouncesOnChange = true
        segmentedControl.cornerRadius = 3
        segmentedControl.indicatorViewInset = 2
        segmentedControl.indicatorViewBackgroundColor = .white
        segmentedControl.titleColor = .white
        segmentedControl.selectedTitleColor = Cores.defaultApp
        segmentedControl.selectedTitleFont = .boldSystemFont(ofSize: 12)
        segmentedControl.titleFont = .systemFont(ofSize: 12)
        segmentedControl.titles = [Atividade.Avaliacao.rawValue, Atividade.Atividade.rawValue, Atividade.Trabalho.rawValue, Atividade.Outros.rawValue]
        segmentedControl.setShadow(enable: true, shadowOffset: CGSize(width: .zero, height: 2), shadowRadius: 2, shadowOpacity: 0.4)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        let text = Constants.bimestre
        bimestreLabel.text = text + String(bimestreSelecionado.id)
        bimestreLabel?.setTextColor(color: Cores.defaultApp, after: text)
        if let avaliacaoSelecionada = self.avaliacaoSelecionada {
            isUpdate = true
            codigoAvaliacao = avaliacaoSelecionada.id
            dataTextfield.text = avaliacaoSelecionada.dataCadastro
            nomeTextField.text = avaliacaoSelecionada.nome
            notaSwitch.setOn(avaliacaoSelecionada.valeNota, animated: false)
            switch avaliacaoSelecionada.codigoTipoAtividade
            {
            case AtividadeCodigo.atividade.rawValue:
                codigoTipoAtividade = 1
            case AtividadeCodigo.trabalho.rawValue:
                codigoTipoAtividade = 2
            case AtividadeCodigo.outros.rawValue:
                codigoTipoAtividade = 3
            default:
                codigoTipoAtividade = .zero
            }
            selectedSegmentIndex = codigoTipoAtividade
            setSegmentedControl(index: selectedSegmentIndex)
        }
        else {
            codigoTipoAtividade = .zero
            selectedSegmentIndex = .zero
            setSegmentedControl(index: .zero)
        }
        if var calendarioLetivo = calendarioLetivo {
            if TipoFechamentoBimestreDao.getFechamentoAtual() != nil {
                var codigoBimestre = bimestreSelecionado.id
                if codigoBimestre == 1 {
                    codigoBimestre = 4
                }
                else {
                    codigoBimestre -= 1
                }
                if let diasLetivos = DiaLetivoDao.diaLetivosDaTurmaNoBimestre(codigoBimestre: codigoBimestre, turma: turmaSelecionada) {
                    for diaLetivo in diasLetivos {
                        calendarioLetivo.append(diaLetivo)
                    }
                }
            }
            calendarioLetivo.sort { (diaLetivo1, diaLetivo2) -> Bool in
                return DateFormatter.dataDateFormatter.date(from: diaLetivo1.dataAula)! < DateFormatter.dataDateFormatter.date(from: diaLetivo2.dataAula)!
            }
            if let primeiraDataString = calendarioLetivo.first?.dataAula {
                dataMinima = DateFormatter.dataDateFormatter.date(from: primeiraDataString)
            }
            if let ultimaDataString = calendarioLetivo.last?.dataAula {
                dataMaxima = DateFormatter.dataDateFormatter.date(from: ultimaDataString)
            }
            for diaLetivo in calendarioLetivo {
                if let diaLetivo = DateFormatter.dataDateFormatter.date(from: diaLetivo.dataAula) {
                    datasAula.insert(diaLetivo)
                }
            }
            self.calendarioLetivo = calendarioLetivo
        }
    }
    
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        dataTextfield.resignFirstResponder()
        nomeTextField.resignFirstResponder()
    }
    
    //MARK: Actions
    @IBAction fileprivate func cancelar() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction fileprivate func salvar() {
        dataTextfield.resignFirstResponder()
        nomeTextField.resignFirstResponder()
        if nomeTextField.text == nil || nomeTextField.text == "" {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.insiraONomeDaAtividade.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
        }
        else {
            codigoTipoAtividade = selectedSegmentIndex
            switch codigoTipoAtividade!
            {
            case 0:
                codigoTipoAtividade = AtividadeCodigo.avaliacao.rawValue
            case 1:
                codigoTipoAtividade = AtividadeCodigo.atividade.rawValue
            case 2:
                codigoTipoAtividade = AtividadeCodigo.trabalho.rawValue
            case 3:
                codigoTipoAtividade = AtividadeCodigo.outros.rawValue
            default:
                break
            }
            valeNota = notaSwitch.isOn
            if let disciplina = disciplinaSelecionada, let dataCadastro = dataTextfield.text, !dataCadastro.isEmpty, let nome = nomeTextField.text, !nome.isEmpty {
                var mobileId: Int32!
                if isUpdate {
                    mobileId = avaliacaoSelecionada?.mobileId
                }
                else {
                    mobileId = AvaliacaoDao.idMaximo() + 1
                }
                if let avaliacaoSelecionada: Avaliacao = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.avaliacao) {
                    avaliacaoSelecionada.dataServidor = nil
                    avaliacaoSelecionada.valeNota = valeNota
                    avaliacaoSelecionada.nome = nome
                    avaliacaoSelecionada.mobileId = mobileId
                    avaliacaoSelecionada.dataCadastro = dataCadastro
                    avaliacaoSelecionada.codigoTipoAtividade = codigoTipoAtividade
                    if let avaliacoes = avaliacoes, !avaliacoes.isEmpty {
                        if let codigo = self.codigoAvaliacao, isUpdate {
                            codigoAvaliacao = codigo
                            avaliacaoSelecionada.id = codigo
                        }
                        else {
                            codigoAvaliacao = nil
                        }
                        _ = AvaliacaoDao.salvar(avaliacao: avaliacaoSelecionada, bimestre: bimestreSelecionado, disciplina: disciplina, turma: turmaSelecionada)
                    }
                    CoreDataManager.sharedInstance.salvarBanco()
                }
                var mensagem: String!
                if isUpdate {
                    mensagem = Localization.atualizadaComSucesso.localized
                }
                else {
                    mensagem = Localization.cadastradaComSucesso.localized
                }
                UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: mensagem, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
                delegate.teveAlteracaoNasAvaliacoes(bimestre: bimestreSelecionado.id)
                dismiss(animated: true, completion: nil)
            }
            else {
                UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.erroCadastrarAtividade.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
            }
        }
    }
    
    //MARK: Methods
    @objc fileprivate func segmentedControlValueChanged(sender: BetterSegmentedControl) {
        selectedSegmentIndex = UInt32(sender.index)
    }
    
    fileprivate func setSegmentedControl(index: UInt32 = .zero) {
        do {
            try segmentedControl.setIndex(UInt(index), animated: true)
        }
        catch {
        }
    }
}

//MARK: CalendarioViewDelegate
extension NovaAvaliacaoViewController: CalendarioViewDelegate {
    func calendarWillDisapear(calendar: CalendarioView) {
    }
    
    func maximumDate() -> Date {
        return self.dataMaxima
    }
    
    func minimumDate() -> Date {
        return self.dataMinima
    }
    
    func fillDefaultColorFor(date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) && datasAula.contains(date) {
            return Cores.itemsToSync
        }
        if !datasAula.contains(date) || Calendar.current.component(.month, from: date) != CalendarioView.sharedInstance.mesSelecionado() {
            return .lightGray
        }
        return Cores.fundoPadrao
    }
    
    func shouldSelectDate(date: Date) -> Bool {
        if Calendar.current.isDateInToday(date) && datasAula.contains(date) {
            return true
        }
        if !datasAula.contains(date) || Calendar.current.component(.month, from: date) != CalendarioView.sharedInstance.mesSelecionado() {
            return false
        }
        return true
    }
    
    func titleDefaultColorFor(date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) && datasAula.contains(date) {
            return nil
        }
        if !datasAula.contains(date) || Calendar.current.component(.month, from: date) != CalendarioView.sharedInstance.mesSelecionado() {
            return .gray
        }
        return Cores.tituloPadrao
    }
    
    func calendarDidSelect(date: Date) {
        dataTextfield.text = DateFormatter.dataDateFormatter.string(from: date)
        CalendarioView.sharedInstance.hideCalendar()
    }
}

//MARK: UITextFieldDelegate
extension NovaAvaliacaoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nomeTextField.isFirstResponder {
            dataTextfield.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dataTextfield {
            CalendarioView.sharedInstance.mostrarCalendario()
            nomeTextField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nomeTextField {
            return textField.text!.count + (string.count - range.length) <= Constants.maximoCaracteresAvaliacao
        }
        return true
    }
}
