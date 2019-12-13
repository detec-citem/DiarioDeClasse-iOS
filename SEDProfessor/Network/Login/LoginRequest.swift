//
//  LoginRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 06/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class LoginRequest {
    //MARK: Variables
    static var usuarioLogado: Usuario?
    
    //MARK: Constants
    fileprivate struct Constants {
        static let appDiarioClasse = "App Di@rio de Classe"
        static let loginApi = "Login"
        static let loginMock = "usuario"
        static let refLogin = "RefLogin"
        static let selecionarPerfilApi = "Login/SelecionarPerfil?perfilSelecionado=4&token="
        static let senha = "senha"
        static let usuario = "user"
    }
    
    static func fazerLogin(usuario: String, senha: String, completion: @escaping ((String?, Bool, String?) -> Void)) {
        let parametros = [Constants.refLogin: Constants.appDiarioClasse, Constants.usuario: usuario, Constants.senha: senha]
        let usuarioTeste = Requests.Configuracoes.LoginTeste.usuario
        let senhaTeste = Requests.Configuracoes.LoginTeste.senha
        if !Requests.Configuracoes.servidorHabilitado || (usuario == usuarioTeste && senha == senhaTeste), let json = Requests.getLocalJsonData(name: Constants.loginMock) as? [String:Any] {
            let hoje = DateFormatter.dataDateFormatter.string(from: Date())
            usuarioLogado = UsuarioDao.salvar(dataUltimoAcesso: hoje, username: usuarioTeste, senha: senhaTeste, json: json)
            CoreDataManager.sharedInstance.salvarBanco()
            completion("", true, nil)
        }
        else if let url = URL(string: Requests.Configuracoes.urlServidor + Constants.loginApi) {
            var request = URLRequest(url: url)
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parametros)
                Requests.requestData(requisicao: request, metodoHttp: .post, completion: { data, error, _ in
                    if error == nil, let data = data as? Data, let json = Requests.parseJson(data: data) as? [String: Any] {
                        if let token = json[UsuarioDao.CamposServidor.token] as? String, let url = URL(string: Requests.Configuracoes.urlServidor + Constants.selecionarPerfilApi + token) {
                            usuarioLogado?.token = token
                            Requests.requestData(requisicao: URLRequest(url: url), metodoHttp: .get, completion: { _, error, _ in
                                if error == nil {
                                    let hoje = DateFormatter.dataDateFormatter.string(from: Date())
                                    usuarioLogado = UsuarioDao.salvar(dataUltimoAcesso: hoje, username: usuario, senha: senha, json: json)
                                    if usuarioLogado == nil {
                                        completion(nil, false, "Erro ao fazer login")
                                    }
                                    else {
                                        CoreDataManager.sharedInstance.salvarBanco()
                                        completion(token, true, nil)
                                    }
                                }
                                else {
                                    completion(token, false, "")
                                }
                            })
                        }
                        else {
                            completion(nil, false, "")
                        }
                    }
                    else {
                        completion(nil, false, Requests.getMensagemErro(error: error))
                    }
                })
            }
            catch {
                completion(nil, false, Requests.getMensagemErro(error: error))
            }
        }
        else {
            completion(nil, false, Localization.erroDesconhecido.localized)
        }
    }
}
