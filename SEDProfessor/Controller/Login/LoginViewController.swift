//
//  LoginViewController.swift
//  PrototipoFrequencia
//
//  Created by Victor Bozelli Alvarez on 19/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import MBProgressHUD
import UIKit

final class LoginViewController: ViewController {
    //MARK: Outlets
    @IBOutlet fileprivate var entrarButton: UIButton!
    @IBOutlet fileprivate var imagemAlturaConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var imagemCentroConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var imagemComprimentoConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var senhaTextField: UITextField!
    @IBOutlet fileprivate var usuarioTextField: UITextField!

    //MARK: Variables
    fileprivate var tecladoVisivel = false

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Requests.Configuracoes.servidorHabilitado {
            usuarioTextField.text = Requests.Configuracoes.LoginTeste.usuario
            senhaTextField.text = Requests.Configuracoes.LoginTeste.senha
        }
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoVaiAparecer), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoVaiDesaparecer), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        usuarioTextField.resignFirstResponder()
        senhaTextField.resignFirstResponder()
    }

    //MARK: Actions
    @IBAction fileprivate func login() {
        if Requests.Configuracoes.servidorHabilitado {
            if Requests.conectadoInternet() {
                if Requests.conectadoDadosMoveis() {
                    let yes = UIAlertAction(title: Localization.sim.localized, style: .default) { _ in
                        self.fazerLogin()
                    }
                    UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.avisoRedesMoveis.localized, estilo: .alert, acoes: [yes, UIAlertAction(title: Localization.nao.localized, style: .cancel)], alvo: self)
                }
                else {
                    fazerLogin()
                }
            }
            else {
                UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.avisoSemInternet.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
            }
        }
        else {
            fazerLogin()
        }
    }

    //MARK: Notifications
    @objc fileprivate func tecladoVaiAparecer() {
        var y: CGFloat = .zero
        var constraintWidth = imagemComprimentoConstraint.constant
        var constraintHeight = imagemAlturaConstraint.constant
        if !tecladoVisivel {
            constraintWidth = imagemComprimentoConstraint.constant.getPercent(number: imagemComprimentoConstraint.constant, from: 25)
            constraintHeight = imagemAlturaConstraint.constant.getPercent(number: imagemAlturaConstraint.constant, from: 25)
            switch UIScreen.main.bounds.height
            {
            case .zero ..< 568:
                y = -Utils.getDeviceHeightValueFrom(view: view, percent: 12)
            case 568 ..< 736:
                y = -Utils.getDeviceHeightValueFrom(view: view, percent: 17)
            default:
                y = -Utils.getDeviceHeightValueFrom(view: view, percent: 15)
                constraintWidth = imagemComprimentoConstraint.constant.getPercent(number: imagemComprimentoConstraint.constant, from: .zero)
                constraintHeight = imagemAlturaConstraint.constant.getPercent(number: imagemAlturaConstraint.constant, from: .zero)
                break
            }
            UIView.animate(withDuration: 0.3) {
                self.imagemComprimentoConstraint.constant -= constraintWidth
                self.imagemAlturaConstraint.constant -= constraintHeight
                self.view.frame.origin.y = y
                self.view.layoutIfNeeded()
            }
            tecladoVisivel = true
        }
    }

    @objc fileprivate func tecladoVaiDesaparecer() {
        if tecladoVisivel {
            UIView.animate(withDuration: 0.3) {
                self.imagemComprimentoConstraint.constant = 310
                self.imagemAlturaConstraint.constant = 210
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.2) {
                self.view.frame.origin.y = .zero
                self.view.layoutIfNeeded()
            }
            tecladoVisivel = false
        }
    }

    //MARK: Methods
    fileprivate func fazerLogin() {
        usuarioTextField.resignFirstResponder()
        senhaTextField.resignFirstResponder()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let login = self.usuarioTextField.text, !login.isEmpty, let password = self.senhaTextField.text, !password.isEmpty {
            let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
            progressHud.label.text = Localization.carregando.localized
            progressHud.detailsLabel.text = Localization.autenticandoUsuario.localized
            LoginRequest.fazerLogin(usuario: login, senha: password, completion: { token, _, error in
                if error == nil {
                    DispatchQueue.main.async {
                        progressHud.detailsLabel.text = Localization.baixandoDados.localized
                    }
                    BuscarTurmasRequest.buscarTurmas(primeiraVez: true, completion: { (sucesso, erro) in
                        self.pararCarregamento(progressHud: progressHud)
                        if sucesso {
                            DispatchQueue.main.async {
                                if let homeNavigationController = self.storyboard?.instantiateViewController(withIdentifier: MenuViewController.className) as? UINavigationController {
                                    UIApplication.shared.keyWindow?.rootViewController = homeNavigationController
                                }
                            }
                        }
                        else if let erro = erro {
                            let ok = UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: { (_) -> Void in
                                UserDefaults.standard.removeObject(forKey: Chaves.anoLetivo.rawValue)
                                UserDefaults.standard.synchronize()
                                CoreDataManager.sharedInstance.deletarBancoDeDados()
                                Utils.changeControllerWithAnimation(identifier: LoginViewController.className, target: self)
                            })
                            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.dadosNaoForamBaixados.localized + "\n\n Erro: " + erro, estilo: .alert, acoes: [ok], alvo: self)
                        }
                    })
                }
                else if let error = error {
                    self.pararCarregamento(progressHud: progressHud)
                    self.exibirErro(message: error.description)
                }
            })
        }
        else {
            exibirErro(message: Localization.inserirUsuarioSenha.localized)
        }
    }
    
    fileprivate func pararCarregamento(progressHud: MBProgressHUD) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            progressHud.hide(animated: true)
        }
    }
    
    fileprivate func exibirErro(message: String) {
        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: message, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: nil)], alvo: self)
    }
}

//MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        if usuarioTextField.isFirstResponder {
            senhaTextField.becomeFirstResponder()
        }
        else {
            login()
        }
        return true
    }
}
