//
//  SincronizarViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 14/11/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import UIKit

final class SincronizarViewController: UIViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let avaliacoes = "Avaliações"
        static let enviadosFormat = "%d / %d %@"
        static let faltas = "Faltas"
        static let fechamento = "Fechamento"
        static let registrosAula = "Registros de Aula"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var avaliacoesLabel: UILabel!
    @IBOutlet fileprivate weak var avaliacoesActivity: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var avaliacoesProgressView: UIProgressView!
    @IBOutlet fileprivate weak var avaliacoesCheckbox: VKCheckbox!
    @IBOutlet fileprivate weak var faltasLabel: UILabel!
    @IBOutlet fileprivate weak var faltasActivityView: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var faltasProgressView: UIProgressView!
    @IBOutlet fileprivate weak var faltasCheckbox: VKCheckbox!
    @IBOutlet fileprivate weak var fechamentosLabel: UILabel!
    @IBOutlet fileprivate weak var fechamentosActivity: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var fechamentosProgressView: UIProgressView!
    @IBOutlet fileprivate weak var fechamentosCheckbox: VKCheckbox!
    @IBOutlet fileprivate weak var registrosAulaLabel: UILabel!
    @IBOutlet fileprivate weak var registrosAulaActivity: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var registrosAulaProgressView: UIProgressView!
    @IBOutlet fileprivate weak var registrosAulaCheckbox: VKCheckbox!
    @IBOutlet fileprivate weak var resultadoLabel: UILabel!
    @IBOutlet fileprivate weak var offlineActivity: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var offlineProgressView: UIProgressView!
    @IBOutlet fileprivate weak var offlineCheckbox: VKCheckbox!
    
    //MARK: Variables
    var erroSincronizar: Bool! = false
    var totalAvaliacoes: Int!
    var totalFaltas: Int!
    var totalFechamentos: Int!
    var totalRegistrosAula: Int!
    var avaliacoesEnviadas: Int! {
        didSet {
            configurarAvaliacoes()
        }
    }
    var faltasEnviadas: Int! {
        didSet {
            configurarFaltas()
        }
    }
    var fechamentosEnviados: Int! {
        didSet {
        }
    }
    var registrosEnviados: Int! {
        didSet {
            configurarRegistrosAula()
        }
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarCheckbox(checkbox: avaliacoesCheckbox)
        configurarCheckbox(checkbox: faltasCheckbox)
        configurarCheckbox(checkbox: fechamentosCheckbox)
        configurarCheckbox(checkbox: registrosAulaCheckbox)
        configurarCheckbox(checkbox: offlineCheckbox)
        fechamentosActivity.stopAnimating()
        fechamentosCheckbox.isHidden = false
        fechamentosCheckbox.setOn(true, animated: true)
        fechamentosLabel.text = "Todos fechamentos sincronizados!"
        fechamentosProgressView.progressTintColor = Cores.fundoDiaComLancamento
        fechamentosProgressView.setProgress(1, animated: true)
    }
    
    //MARK: Methods
    func configurarErroOffline() {
        offlineActivity.stopAnimating()
        offlineProgressView.progressTintColor = .systemRed
        offlineProgressView.setProgress(1, animated: true)
        configurarErro()
    }
    
    func configurarSucessoOffline() {
        offlineActivity.isHidden = true
        offlineActivity.stopAnimating()
        offlineCheckbox.isHidden = false
        offlineCheckbox.setOn(true, animated: true)
        offlineProgressView.progressTintColor = Cores.fundoDiaComLancamento
        offlineProgressView.setProgress(1, animated: true)
        resultadoLabel.text = "SINCRONIZAÇÃO REALIZADA COM SUCESSO"
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.dismiss(animated: true)
        })
    }
    
    func iniciarOffline() {
        if avaliacoesEnviadas == totalAvaliacoes && faltasEnviadas == totalFaltas && registrosEnviados == totalRegistrosAula {
            offlineActivity.startAnimating()
        }
    }
    
    fileprivate func configurarAvaliacoes() {
        if erroSincronizar {
            avaliacoesActivity.stopAnimating()
            avaliacoesCheckbox.isHidden = false
            avaliacoesCheckbox.setOn(false, animated: true)
            avaliacoesLabel.text = "Erro na sincronização!"
            avaliacoesLabel.textColor = .systemRed
            avaliacoesProgressView.progressTintColor = .systemRed
            configurarErro()
        }
        else {
            if totalAvaliacoes == .zero || avaliacoesEnviadas == totalAvaliacoes {
                avaliacoesActivity.stopAnimating()
                avaliacoesCheckbox.isHidden = false
                avaliacoesCheckbox.setOn(true, animated: true)
                avaliacoesProgressView.progressTintColor = Cores.fundoDiaComLancamento
                avaliacoesProgressView.setProgress(1, animated: true)
            }
            if totalAvaliacoes == .zero {
                avaliacoesLabel.text = "Nenhuma avaliação para sincronizar"
            }
            else if avaliacoesEnviadas == totalAvaliacoes {
                avaliacoesLabel.text = "Todas avaliações sincronizadas!"
                iniciarOffline()
            }
            else {
                avaliacoesLabel.text = String(format: Constants.enviadosFormat, avaliacoesEnviadas, totalAvaliacoes, Constants.avaliacoes)
                avaliacoesProgressView.setProgress(Float(avaliacoesEnviadas) / Float(totalAvaliacoes), animated: true)
            }
        }
    }
    
    fileprivate func configurarCheckbox(checkbox: VKCheckbox) {
        checkbox.line = .thin
        checkbox.bgColorSelected = Cores.fundoDiaComLancamento
        checkbox.bgColor = .white
        checkbox.borderColor = Cores.fundoDiaComLancamento
        checkbox.borderWidth = 2
        checkbox.color = .white
        checkbox.cornerRadius = 18.5
    }
    
    fileprivate func configurarErro() {
        resultadoLabel.textColor = .systemRed
        resultadoLabel.text = "OCORREU UM ERRO NA SINCRONIZAÇÃO"
    }
    
    fileprivate func configurarFaltas() {
        if erroSincronizar {
            faltasActivityView.stopAnimating()
            faltasCheckbox.isHidden = false
            faltasCheckbox.setOn(false, animated: true)
            faltasLabel.text = "Erro na sincronização!"
            faltasProgressView.progressTintColor = .systemRed
            configurarErro()
        }
        else {
            if totalFaltas == .zero || faltasEnviadas == totalFaltas {
                faltasActivityView.stopAnimating()
                faltasCheckbox.isHidden = false
                faltasCheckbox.setOn(true, animated: true)
                faltasProgressView.progressTintColor = Cores.fundoDiaComLancamento
                faltasProgressView.setProgress(1, animated: true)
            }
            if totalFaltas == .zero {
                faltasLabel.text = "Nenhuma falta para sincronizar"
            }
            else if faltasEnviadas == totalFaltas {
                faltasLabel.text = "Todas faltas sincronizadas!"
                iniciarOffline()
            }
            else {
                faltasLabel.text = String(format: Constants.enviadosFormat, faltasEnviadas, totalFaltas, Constants.faltas)
                faltasProgressView.setProgress(Float(faltasEnviadas) / Float(totalFaltas), animated: true)
            }
        }
    }
    
    fileprivate func configurarRegistrosAula() {
        if erroSincronizar {
            registrosAulaActivity.stopAnimating()
            registrosAulaCheckbox.isHidden = false
            registrosAulaCheckbox.setOn(false, animated: true)
            registrosAulaLabel.text = "Erro na sincronização!"
            registrosAulaProgressView.progressTintColor = .systemRed
            configurarErro()
        }
        else {
            if totalRegistrosAula == .zero || registrosEnviados == totalRegistrosAula {
                registrosAulaActivity.stopAnimating()
                registrosAulaCheckbox.isHidden = false
                registrosAulaCheckbox.setOn(true, animated: true)
                registrosAulaProgressView.progressTintColor = Cores.fundoDiaComLancamento
                registrosAulaProgressView.setProgress(1, animated: true)
            }
            if totalRegistrosAula == .zero {
                registrosAulaLabel.text = "Nenhum registro de aula para sincronizar"
            }
            else if registrosEnviados == totalRegistrosAula {
                registrosAulaLabel.text = "Todos registros de aula sincronizados!"
                iniciarOffline()
            }
            else {
                registrosAulaLabel.text = String(format: Constants.enviadosFormat, registrosEnviados, totalRegistrosAula, Constants.registrosAula)
                registrosAulaProgressView.setProgress(Float(registrosEnviados) / Float(totalRegistrosAula), animated: true)
            }
        }
    }
}
