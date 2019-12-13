//
//  MenuViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 19/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import Crashlytics
import FirebaseAnalytics
import MessageUI
import MZFormSheetPresentationController
import MBProgressHUD
import StoreKit
import UIKit

final class MenuViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let acaoSincronizar = "Acão_Sincronizar"
        static let assuntoEmail = "Avaliação do aplicativo Di@rio de Classe - Versão iOS"
        static let avaliarAplicativoImage = "AvaliarAplicativo"
        static let avaliacaoAppMinima = 3
        static let avaliacaoSegue = "AvaliacaoSegue"
        static let buttonId = "ButtonId"
        static let chaveAbriuApp = "abriuApp"
        static let chaveAvaliouApp = "avaliouApp"
        static let chaveImagem = "image"
        static let chaveVersaoNaLoja = "versaoNaLoja"
        static let compartilharImage = "Compartilhar"
        static let conflitosNavigationController = "ConflitosNavigationController"
        static let corpoEmail = "Estrelas: %@\n\nLogin: %@\n\nVersão do aplicativo: %@\n\nAvaliação: Escreva aqui a sua avaliação"
        static let email = "seesp.mobile@gmail.com"
        static let fechamentoSegue = "FechamentoSegue"
        static let linhaModuloFrequencia = 0
        static let linhaModuloRegistro = 1
        static let linhaModuloAvaliacao = 2
        static let linhaModuloFechamento = 3
        static let linhaModuloTurmas = 4
        static let linhaModuloCarteirinha = 5
        static let logoutImage = "Shutdown-50"
        static let moduloAvaliacao = "Mód_Avaliação"
        static let moduloAvaliacaoTableViewCell = "ModuloAvaliacaoTableViewCell"
        static let moduloCarteirinha = "Mód_Carteirinha"
        static let moduloCarteirinhaTableViewCell = "ModuloCarteirinhaTableViewCell"
        static let moduloFechamento = "Mód_Fechamento"
        static let moduloFechamentoTableViewCell = "ModuloFechamentoTableViewCell"
        static let moduloFrequencia = "Mód_Frequência"
        static let moduloFrequenciaTableViewCell = "ModuloFrequenciaTableViewCell"
        static let moduloRegistroAulas = "Mód_RegistroAulas"
        static let moduloRegistroTableViewCell = "ModuloRegistroTableViewCell"
        static let moduloTurmas = "Mód_Turmas"
        static let moduloTurmasTableViewCell = "ModuloTurmasTableViewCell"
        static let numeroDeModulos = 5
        static let registroSegue = "RegistroSegue"
        static let separadorVersao = "."
        static let sincronizeImage = "Synchronize-50"
        static let sincronizarNavigationController = "SincronizarNavigationController"
        static let sobreImage = "Sobre"
        static let turmasSegue = "TurmasSegue"
        static let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id1052266973")!
        static let userDetailsNavigationController = "UserDetailsNavigationController"
        static let versao = "CFBundleShortVersionString"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate var usuarioLabel: UILabel!
    @IBOutlet fileprivate var usuarioButton: UIButton!
    @IBOutlet fileprivate var tapGesture: UITapGestureRecognizer!
    
    //MARK: Variables
    fileprivate var versao: String!

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.titulo.localized
        usuarioLabel.addGestureRecognizer(tapGesture)
        let usuarioAtual = LoginRequest.usuarioLogado
        #if DEBUG
        #else
        Crashlytics.sharedInstance().setUserIdentifier(usuarioAtual?.usuario)
        Crashlytics.sharedInstance().setUserName(usuarioAtual?.nome)
        #endif
        usuarioLabel.text = usuarioAtual?.nome.uppercased()
        usuarioButton.isHidden = false
        versao = Bundle.main.infoDictionary?[Constants.versao] as? String
        var versaoNaLoja: Int!
        let userDefaults = UserDefaults.standard
        if Requests.conectadoInternet() {
            let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
            progressHud.label.text = "Consultando versão do aplicativo"
            progressHud.detailsLabel.text = "Consultando versão do aplicativo... Por favor aguarde..."
            VersaoAppRequest.consultarVersaoApp(completion: { versao, erro in
                DispatchQueue.main.async {
                    progressHud.hide(animated: true)
                    if let versaoNaLoja = versao, let versaoDoAplicativo = Int(self.versao.replacingOccurrences(of: Constants.separadorVersao, with: "")) {
                        userDefaults.set(versaoNaLoja, forKey: Constants.chaveVersaoNaLoja)
                        self.verificarVersaoAplicativo(userDefaults: userDefaults, versaoDoAplicativo: versaoDoAplicativo, versaoNaLoja: versaoNaLoja)
                    }
                    else {
                        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: erro, estilo: .alert, alvo: self)
                    }
                }
            })
        }
        else if let versaoDoAplicativo = Int(versao.replacingOccurrences(of: Constants.separadorVersao, with: "")) {
            versaoNaLoja = userDefaults.integer(forKey: Constants.chaveVersaoNaLoja)
            verificarVersaoAplicativo(userDefaults: userDefaults, versaoDoAplicativo: versaoDoAplicativo, versaoNaLoja: versaoNaLoja)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let identifier = segue.identifier {
            if identifier == Constants.avaliacaoSegue || identifier == Constants.fechamentoSegue || identifier == Constants.turmasSegue || identifier == Constants.registroSegue, let turmasViewController = segue.destination as? TurmasViewController {
                var tipoTurma: TipoTela
                if identifier == Constants.avaliacaoSegue {
                    tipoTurma = .avaliacaoLancamento
                }
                else if identifier == Constants.fechamentoSegue {
                    tipoTurma = .fechamentoLancamento
                }
                else if identifier == Constants.registroSegue {
                    tipoTurma = .registroLancamento
                }
                else {
                    tipoTurma = .listagem
                }
                turmasViewController.tipoTela = tipoTurma
            }
            else if let tabBarController = segue.destination as? UITabBarController, let tabBarController0 = tabBarController.viewControllers?.first as? TurmasViewController, let tabBarController1 = (segue.destination as? UITabBarController)?.viewControllers?[1] as? TurmasViewController {
                tabBarController0.tipoTela = .frequenciaLancamento
                tabBarController1.tipoTela = .frequenciaLancamento
            }
        }
    }

    //MARK: Actions
    @IBAction func acaoSincronizar(_: Any) {
        sincronizar()
    }

    @IBAction fileprivate func mostrarOpcoesMenu(sender: UIBarButtonItem) {
        let compartilhar = UIAlertAction(title: Localization.compartilhar.localized, style: .default) { _ in
        }
        compartilhar.setValue(UIImage(named: Constants.compartilharImage), forKey: Constants.chaveImagem)
        let avaliarApp = UIAlertAction(title: Localization.avaliarAplicativo.localized, style: .default) { _ in
            self.avaliarAplicativo()
        }
        avaliarApp.setValue(UIImage(named: Constants.avaliarAplicativoImage), forKey: Constants.chaveImagem)
        let sobre = UIAlertAction(title: Localization.sobre.localized, style: .default) { _ in
            UIAlertController.criarAlerta(titulo: Localization.sobre.localized, mensagem: Localization.sobre.localized + " " + self.versao, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
        }
        sobre.setValue(UIImage(named: Constants.sobreImage), forKey: Constants.chaveImagem)
        let atualizarBanco = UIAlertAction(title: Localization.sincronizar.localized, style: .default) { _ in
            self.sincronizar()
        }
        atualizarBanco.setValue(UIImage(named: Constants.sincronizeImage), forKey: Constants.chaveImagem)
        let sair = UIAlertAction(title: Localization.sair.localized, style: .default) { _ in
            let sim = UIAlertAction(title: Localization.sim.localized, style: .default) { _ -> Void in
                if let registrosNaoSincronizados = RegistroAulaDao.acessarRegistrosNaoSincronizados(), let frequenciasNaoSincronizadas = FaltaAlunoDao.frequenciasNaoSincronizadas(), !frequenciasNaoSincronizadas.isEmpty || !registrosNaoSincronizados.isEmpty {
                    let nao = UIAlertAction(title: Localization.nao.localized, style: .destructive, handler: { _ in
                        self.logout()
                    })
                    let sim = UIAlertAction(title: Localization.sim.localized, style: .default, handler: { _ in
                        self.sincronizar()
                    })
                    UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.existemDadosNaoSincronizados.localized, estilo: .alert, acoes: [nao, sim, UIAlertAction(title: Localization.cancelar.localized, style: .cancel, handler: nil)], alvo: self)
                }
                else {
                    self.logout()
                }
            }
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.desejaSair.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.nao.localized, style: .destructive, handler: nil), sim], alvo: self)
        }
        sair.setValue(UIImage(named:Constants.logoutImage), forKey: Constants.chaveImagem)
        let cancelar = UIAlertAction(title: Localization.cancelar.localized, style: .destructive, handler: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            UIAlertController.criarAlerta(estilo: .actionSheet, acoes: [compartilhar, avaliarApp, sobre, atualizarBanco, sair, cancelar], alvo: self, popover: true, botaoPopover: sender)
        }
        else {
            UIAlertController.criarAlerta(estilo: .actionSheet, acoes: [compartilhar, avaliarApp, sobre, atualizarBanco, sair, cancelar], alvo: self)
        }
    }

    @IBAction fileprivate func mostrarDetalhesUsuario() {
        if let navigationController = storyboard?.instantiateViewController(withIdentifier: Constants.userDetailsNavigationController) as? UINavigationController {
            presentFormSheetViewController(viewController: navigationController)
        }
    }

    //MARK: Methods
    fileprivate func avaliarAplicativo() {
        if let avaliarAplicativoViewController: AvaliarAplicativoViewController = storyboard?.instantiateViewController() {
            avaliarAplicativoViewController.delegate = self
            present(avaliarAplicativoViewController, animated: true)
        }
    }
    
    fileprivate func enviarEvento(evento: String) {
        #if DEBUG
        #else
        let parametros: [String:Any] = [Constants.buttonId:UInt8.zero,AnalyticsParameterContentType:evento]
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: parametros)
        Analytics.logEvent(evento, parameters: parametros)
        #endif
    }
    
    fileprivate func fazerSincronizacao() {
        if TurmaDao.numeroDeTurmas() == .zero {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.dadosIncompletosServidor.localized, estilo: .alert, alvo: self)
        }
        else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            enviarEvento(evento: Constants.acaoSincronizar)
            if let sincronizarNavigationController = storyboard?.instantiateViewController(withIdentifier: Constants.sincronizarNavigationController) as? UINavigationController, let sincronizarViewController = sincronizarNavigationController.viewControllers.first as? SincronizarViewController {
                presentFormSheetViewController(viewController: sincronizarNavigationController, completion: {
                    SincronizarRequest.sincronizar(erroAvaliacao: {
                        sincronizarViewController.erroSincronizar = true
                    }, erroFrequencias: {
                        sincronizarViewController.erroSincronizar = true
                    }, erroRegistro: {
                        sincronizarViewController.erroSincronizar = true
                    }, erroOffline: {
                        sincronizarViewController.configurarErroOffline()
                    }, progressoAvaliacao: { (avaliacoesEnviadas, totalAvaliacoes) in
                        sincronizarViewController.totalAvaliacoes = totalAvaliacoes
                        sincronizarViewController.avaliacoesEnviadas = avaliacoesEnviadas
                    }, progressoFrequencia: { (faltasEnviadas, totalFaltas) in
                        sincronizarViewController.totalFaltas = totalFaltas
                        sincronizarViewController.faltasEnviadas = faltasEnviadas
                    }, progressoRegistro: { (registrosEnviados, totalRegistros) in
                        sincronizarViewController.totalRegistrosAula = totalRegistros
                        sincronizarViewController.registrosEnviados = registrosEnviados
                    }, progressoOffline: {
                        sincronizarViewController.iniciarOffline()
                    }, sucessoOffline: {
                        sincronizarViewController.configurarSucessoOffline()
                    }, completion: { sucesso, erro in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        var acao: UIAlertAction!
                        var mensagem: String!
                        if sucesso {
                            mensagem = Localization.syncSucesso.localized
                            acao = UIAlertAction(title: Localization.ok.localized, style: .default, handler: { _ in
                                if let diasConflito = DiaConflitoDao.todosDiasConflito(), !diasConflito.isEmpty, let conflitosNavigationController = self.storyboard?.instantiateViewController(withIdentifier: Constants.conflitosNavigationController) as? UINavigationController, let conflitosViewController = conflitosNavigationController.viewControllers.first as? ConflitosViewController {
                                    conflitosViewController.diasConflito = diasConflito
                                    self.presentFormSheetViewController(viewController: conflitosNavigationController)
                                }
                            })
                        }
                        else {
                            mensagem = erro
                            acao = UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: nil)
                        }
                        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: mensagem, estilo: .alert, acoes: [acao], alvo: self)
                    })
                })
            }
        }
    }

    fileprivate func logout() {
        UserDefaults.standard.removeObject(forKey: Chaves.anoLetivo.rawValue)
        UserDefaults.standard.synchronize()
        CoreDataManager.sharedInstance.deletarBancoDeDados()
        Utils.changeControllerWithAnimation(identifier: LoginViewController.className, target: self)
    }

    fileprivate func sincronizar() {
        if Requests.conectadoInternet() {
            if Requests.conectadoDadosMoveis() {
                let sim = UIAlertAction(title: Localization.sim.localized, style: .default) { _ in
                    self.fazerSincronizacao()
                }
                UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.avisoRedesMoveis.localized, estilo: .alert, acoes: [sim, UIAlertAction(title: Localization.nao.localized, style: .cancel)], alvo: self)
            }
            else {
                fazerSincronizacao()
            }
        }
        else {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.avisoSemInternet.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
        }
    }
    
    fileprivate func verificarAssociacao(evento: String, segue: String) {
        if TurmaDao.numeroDeTurmas() == .zero {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.dadosIncompletosServidor.localized, estilo: .alert, alvo: self)
        }
        else {
            enviarEvento(evento: evento)
            performSegue(withIdentifier: segue, sender: nil)
        }
    }
    
    fileprivate func verificarVersaoAplicativo(userDefaults: UserDefaults, versaoDoAplicativo: Int, versaoNaLoja: Int) {
        if versaoDoAplicativo < versaoNaLoja {
        }
        else {
            let chaves = userDefaults.dictionaryRepresentation().keys
            if chaves.contains(Constants.chaveAvaliouApp) {
                let avaliouApp = userDefaults.bool(forKey: Constants.chaveAvaliouApp)
                if !avaliouApp {
                    var vezesAbriuApp = userDefaults.integer(forKey: Constants.chaveAbriuApp)
                    vezesAbriuApp += 1
                    if vezesAbriuApp == 3 {
                        avaliarAplicativo()
                    }
                    else {
                        userDefaults.set(vezesAbriuApp, forKey: Constants.chaveAbriuApp)
                    }
                }
            }
            else {
                userDefaults.set(false, forKey: Constants.chaveAvaliouApp)
                userDefaults.set(1, forKey: Constants.chaveAbriuApp)
            }
        }
        userDefaults.synchronize()
    }
}

//MARK: AvaliarAplicativoDelegate
extension MenuViewController: AvaliarAplicativoDelegate {
    func avaliouAplicativo(estrelas: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: Constants.chaveAvaliouApp)
        userDefaults.synchronize()
        if estrelas < Constants.avaliacaoAppMinima {
            if MFMailComposeViewController.canSendMail() {
                let emailViewController = MFMailComposeViewController()
                emailViewController.setToRecipients([Constants.email])
                emailViewController.setSubject(Constants.assuntoEmail)
                if let usuarioLogado = LoginRequest.usuarioLogado {
                    emailViewController.setMessageBody(String(format: Constants.corpoEmail, estrelas, usuarioLogado.usuario, versao), isHTML: false)
                }
                present(emailViewController, animated: true)
            }
        }
        else if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
        else if UIApplication.shared.canOpenURL(Constants.urlAppStore) {
            let ok = UIAlertAction(title: Localization.ok.localized, style: .default, handler: { _ in
                UIApplication.shared.openURL(Constants.urlAppStore)
            })
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.avaliarAplicativoAppStore.localized, estilo: .alert, acoes: [ok], alvo: self)
        }
    }
    
    func avaliarMaisTarde() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(Int.zero, forKey: Constants.chaveAbriuApp)
        userDefaults.synchronize()
    }
    
    func nunca() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: Constants.chaveAvaliouApp)
        userDefaults.synchronize()
    }
}

//MARK: UICollectionViewDataSource
extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numeroDeModulos
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let linha = indexPath.row
        if linha == Constants.linhaModuloFrequencia {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.moduloFrequenciaTableViewCell, for: indexPath)
        }
        else if linha == Constants.linhaModuloRegistro {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.moduloRegistroTableViewCell, for: indexPath)
        }
        else if linha == Constants.linhaModuloAvaliacao {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.moduloAvaliacaoTableViewCell, for: indexPath)
        }
        else if linha == Constants.linhaModuloFechamento {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.moduloFechamentoTableViewCell, for: indexPath)
        }
        else if linha == Constants.linhaModuloTurmas {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.moduloTurmasTableViewCell, for: indexPath)
        }
        else if linha == Constants.linhaModuloCarteirinha {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.moduloCarteirinhaTableViewCell, for: indexPath)
        }
        return cell
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linha = indexPath.row
        if linha == Constants.linhaModuloFrequencia {
            verificarAssociacao(evento: Constants.moduloFrequencia, segue: Segue.FrequenciaTabBar.rawValue)
        }
        else if linha == Constants.linhaModuloRegistro {
            verificarAssociacao(evento: Constants.moduloRegistroAulas, segue: Constants.registroSegue)
        }
        else if linha == Constants.linhaModuloAvaliacao {
            verificarAssociacao(evento: Constants.moduloAvaliacao, segue: Constants.avaliacaoSegue)
        }
        else if linha == Constants.linhaModuloFechamento {
            verificarAssociacao(evento: Constants.moduloFechamento, segue: Constants.fechamentoSegue)
        }
        else if linha == Constants.linhaModuloTurmas {
            verificarAssociacao(evento: Constants.moduloTurmas, segue: Constants.turmasSegue)
        }
        else if linha == Constants.linhaModuloCarteirinha {
            enviarEvento(evento: Constants.moduloCarteirinha)
        }
    }
}
