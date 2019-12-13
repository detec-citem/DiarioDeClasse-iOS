//
//  FechamentoBimestreViewController.swift
//  SEDProfessor
//
//  Created by Richard on 06/01/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import UIKit

final class FechamentoBimestreViewController: ViewController {
    //MARK: Outlets
    @IBOutlet fileprivate var aulasPlanejadasTextField: UITextField!
    @IBOutlet fileprivate var aulasRealizadasTextField: UITextField!
    @IBOutlet fileprivate var justificativaTextField: UITextField!
    @IBOutlet fileprivate var titleView: UIView!
    @IBOutlet fileprivate var serieDisciplinaLabel: CustomLabel!
    @IBOutlet fileprivate var nomeFechamentoBimestreLabel: CustomLabel!

    //MARK: Variables
    fileprivate var isUpped = false
    fileprivate var originalPosition: CGFloat = .zero
    fileprivate var atualFechamentoBimestre: TipoFechamentoBimestre?
    fileprivate var fechamentoTurma: FechamentoTurma?
    var ano: Int?
    var bimestreSelecionado: Bimestre!
    var disciplinaSelecionada: Disciplina!
    var turmaSerie: String!
    var turmaSelecionada: Turma!

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.fechamento.localized
        titleView.setShadow(enable: true)
        serieDisciplinaLabel.text = turmaSerie.uppercased()
        atualFechamentoBimestre = TipoFechamentoBimestreDao.getFechamentoAtual()
        nomeFechamentoBimestreLabel.text = atualFechamentoBimestre?.nome
        if let fechamentoBimestre = atualFechamentoBimestre {
            fechamentoTurma = FechamentoTurmaDao.buscarFechamento(serie: turmaSelecionada.serie, bimestre: bimestreSelecionado, disciplina: disciplinaSelecionada, tipoFechamento: fechamentoBimestre, turma: turmaSelecionada)
        }
        if let fechamentoTurma = fechamentoTurma {
            aulasPlanejadasTextField.text = String(fechamentoTurma.aulasPlanejadas)
            aulasRealizadasTextField.text = String(fechamentoTurma.aulasRealizadas)
            justificativaTextField.text = fechamentoTurma.justificativa
        }
        if UIScreen.main.bounds.height < 667.0 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        UIViewController.hideKeyboard(fields: [aulasPlanejadasTextField, aulasRealizadasTextField, justificativaTextField])
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == Segue.FechamentoLista.rawValue {
            let controller = segue.destination as? FechamentoListaViewController
            controller?.turmaSerie = turmaSerie
            controller?.turmaSelecionada = turmaSelecionada
            controller?.disciplinaSelecionada = disciplinaSelecionada
            controller?.bimestreAtual = bimestreSelecionado
            controller?.fechamentoTurma = fechamentoTurma
        }
    }

    //MARK: Actions
    @IBAction func confirmarAulas(_: Any) {
        var mensagemErro = ""
        if let atualFechamentoBimestre = atualFechamentoBimestre {
            if let stringAulasPlanejadas = aulasPlanejadasTextField.text, let stringAulasRealizadas = aulasRealizadasTextField.text, let aulasPlanejadas = UInt32(stringAulasPlanejadas), let aulasRealizadas = UInt32(stringAulasRealizadas) {
                if aulasPlanejadas > 0 {
                    if aulasRealizadas <= aulasPlanejadas {
                        if aulasRealizadas == aulasPlanejadas || (aulasRealizadas != aulasPlanejadas && !justificativaTextField.text!.isEmpty) {
                            var justificativa = ""
                            if let justificativaTxt = justificativaTextField.text {
                                justificativa = justificativaTxt
                            }
                            let fechamentoTurma = FechamentoTurmaModel(serie: turmaSelecionada.serie, aulasPlanejadas: aulasPlanejadas, aulasRealizadas: aulasRealizadas, justificativa: justificativa, turma: turmaSelecionada, disciplina: disciplinaSelecionada, bimestre: bimestreSelecionado, tipoFechamento: atualFechamentoBimestre)
                            FechamentoTurmaDao.salvar(fechamentoTurma: fechamentoTurma)
                            performSegue(withIdentifier: Segue.FechamentoLista.rawValue, sender: nil)
                        }
                        else {
                            mensagemErro = Localization.preencherJustificativa.localized
                        }
                    }
                    else {
                        mensagemErro = Localization.preencherAulasRealizadas.localized
                    }
                }
                else {
                    mensagemErro = Localization.preencherAulasPlanejadas.localized
                }
            }
            else {
                mensagemErro = Localization.preencherCampos.localized
            }
        }
        else {
            mensagemErro = Localization.erroFechamentoTurma.localized
        }
        if !mensagemErro.isEmpty {
            UIAlertController.criarAlerta(titulo: Localization.fechamento.localized, mensagem: mensagemErro, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: nil)], alvo: self)
        }
    }

    //MARK: Methods
    @objc fileprivate func keyboardWillAppear() {
        if !isUpped {
            isUpped = true
            originalPosition = view.frame.origin.y
        }
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 10
            self.view.layoutIfNeeded()
        }
    }

    @objc fileprivate func keyboardWillDisappear() {
        isUpped = false
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.view.frame.origin.y = self.originalPosition
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: UITextFieldDelegate
extension FechamentoBimestreViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
