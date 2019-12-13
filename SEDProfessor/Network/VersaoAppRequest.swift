//
//  VersaoAppRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 09/12/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class VersaoAppRequest {
    //MARK: Constants
    fileprivate struct Constants {
        static let campoVersaoApp = "VersaoApp"
        static let versaoAplicativoApi = "VersaoAplicativo?codigoApp=2"
    }
    
    //MARK: Methods
    static func consultarVersaoApp(completion: @escaping ((Int?,String?) -> Void)) {
        if let usuarioLogado = LoginRequest.usuarioLogado, !Requests.Configuracoes.servidorHabilitado || (usuarioLogado.usuario == Requests.Configuracoes.LoginTeste.usuario && usuarioLogado.senha.base64Decoded == Requests.Configuracoes.LoginTeste.senha) {
            completion(.zero, nil)
        }
        else if let url = URL(string: Requests.Configuracoes.urlServidor + Constants.versaoAplicativoApi) {
            Requests.requestData(requisicao: URLRequest(url: url), metodoHttp: .get, completion: { data, error, _ in
                if error == nil, let data = data as? Data, let json = Requests.parseJson(data: data) as? [String: Any], let versaoApp = json[Constants.campoVersaoApp] as? Int {
                    completion(versaoApp, nil)
                }
                else {
                    completion(nil, Requests.getMensagemErro(error: error))
                }
            })
        }
    }
}
