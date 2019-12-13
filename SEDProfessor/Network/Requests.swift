//
//  Requests.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 04/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import Foundation
import Reachability

final class Requests {
    //MARK: Constants
    fileprivate struct Constants {
        static let campoErro = "Erro"
        static let campoMensagem = "Message"
        static let jsonFileExtension = "json"
        static let timeoutInterval: TimeInterval = 86400
    }
    
    fileprivate struct HttpHeaderFieldsKey {
        static let acceptEncoding = "Accept-Encoding"
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
    }
    
    fileprivate struct HttpHeaderFieldsValue {
        static let acceptEncoding = "gzip"
        static let contentType = "application/json"
    }
    
    struct HttpStatusCode {
        static let error = 201
        static let forbiddenAccess1 = 400
        static let forbiddenAccess2 = 401
        static let internalServerError = 500
        static let notFound = 404
        static let sucess1 = 200
        static let sucess2 = 202
        static let sucess3 = 300
    }
    
    enum MetodoHttp: String {
        case get = "GET"
        case post = "POST"
    }
    
    struct Configuracoes {
        fileprivate struct UrlsServidor {
            static let desenvolvimento = "https://desenvolvimentosed.educacao.sp.gov.br/SedApi/Api/"
            static let homologacao = "https://homologacao-sed.educacao.sp.gov.br/SedApi/Api/"
            static let producao = "https://sed.educacao.sp.gov.br/SedApi/Api/"
        }
        
        struct LoginTeste {
            static let usuario = "administrador"
            static let senha = "administrador"
        }
        
        static let servidorHabilitado: Bool = true
        
        #if DEBUG
        static let urlServidor: String = UrlsServidor.desenvolvimento
        #else
        static let urlServidor: String = UrlsServidor.producao
        #endif
    }
    
    fileprivate enum NetError: Error, CustomStringConvertible {
        case notFound(Int)
        case forbidden(Int)
        case serverError(String)
        case serverResponseError(Int)
        case fatalError(String)
        case noConnection
        case timeout
        case unknown
        
        var description: String {
            switch self
            {
            case let .notFound(statusCode):
                return "Página não encontrada (Erro \(statusCode))"
            case let .forbidden(statusCode):
                return "Acesso não permitido (Erro \(statusCode))"
            case let .serverError(errorDescription):
                return errorDescription
            case let .serverResponseError(statusCode):
                return "Servidor não está respondendo no momento (Erro \(statusCode))"
            case let .fatalError(errorDescription):
                return "Fatal error: \(errorDescription)"
            case .noConnection:
                return "Você está desconectado da internet"
            case .timeout:
                return "Serviço não disponível no momento. Tente novamente mais tarde."
            default:
                return "Erro desconhecido"
            }
        }
    }
    
    //MARK: Variables
    fileprivate static var sessao: URLSession!
    
    //MARK: Methods
    static func conectadoDadosMoveis() -> Bool {
        if let reachability = Reachability.forInternetConnection(), reachability.isReachableViaWWAN() && !reachability.isReachableViaWiFi() {
            return true
        }
        return false
    }
    
    static func conectadoInternet() -> Bool {
        if Reachability.forInternetConnection().isReachable() {
            return true
        }
        return false
    }
    
    static func getLocalJsonData(name: String) -> Any? {
        if let path = Bundle.main.path(forResource: name, ofType: Constants.jsonFileExtension) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return json
            }
            catch {
            }
        }
        return nil
    }
    
    static func getMensagemErro(error: Error?) -> String? {
        if error is NetError {
            return (error as! NetError).description
        }
        if let description = error?.localizedDescription {
            return description
        }
        return nil
    }
    
    static func parseJson(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data)
        }
        catch {
        }
        return nil
    }
    
    static func requestData(requisicao: URLRequest, metodoHttp: MetodoHttp, completion: ((Any?, Error?, Int?) -> Void)?) {
        var requisicao = requisicao
        requisicao.cachePolicy = .reloadIgnoringLocalCacheData
        requisicao.timeoutInterval = Constants.timeoutInterval
        requisicao.httpMethod = metodoHttp.rawValue
        requisicao.setValue(HttpHeaderFieldsValue.acceptEncoding, forHTTPHeaderField: HttpHeaderFieldsKey.acceptEncoding)
        requisicao.setValue(HttpHeaderFieldsValue.contentType, forHTTPHeaderField: HttpHeaderFieldsKey.contentType)
        if let token = LoginRequest.usuarioLogado?.token {
            requisicao.setValue(token, forHTTPHeaderField: HttpHeaderFieldsKey.authorization)
        }
        if sessao == nil {
            let configuracao = URLSessionConfiguration.default
            configuracao.timeoutIntervalForRequest = Constants.timeoutInterval
            configuracao.timeoutIntervalForResource = Constants.timeoutInterval
            sessao = URLSession(configuration: configuracao)
        }
        sessao.dataTask(with: requisicao) { dados, resposta, erro in
            if let resposta = resposta as? HTTPURLResponse, erro == nil {
                let statuscCode = resposta.statusCode
                switch statuscCode {
                case HttpStatusCode.sucess1, HttpStatusCode.sucess2..<HttpStatusCode.sucess3:
                    completion?(dados ?? nil, nil, statuscCode)
                case HttpStatusCode.error:
                    if let dados = dados, let json = parseJson(data: dados) as? [String: Any], let erro = json[Constants.campoErro] as? String {
                        completion?(nil, NetError.serverError(erro), statuscCode)
                    }
                case HttpStatusCode.forbiddenAccess1:
                    if let usuarioLogado = LoginRequest.usuarioLogado, let senha = usuarioLogado.senha.base64Decoded {
                        LoginRequest.fazerLogin(usuario: usuarioLogado.usuario, senha: senha, completion: { _, sucess, _ in
                            if sucess {
                                requestData(requisicao: requisicao, metodoHttp: metodoHttp, completion: completion)
                            }
                            else {
                                completion?("anything happened and I don know what!", NetError.unknown, statuscCode)
                            }
                        })
                    }
                case HttpStatusCode.forbiddenAccess2:
                    completion?(nil, NetError.forbidden(statuscCode), statuscCode)
                case HttpStatusCode.notFound:
                    completion?(nil, NetError.notFound(statuscCode), statuscCode)
                case let x where x >= 500:
                    completion?(nil, NetError.serverResponseError(statuscCode), statuscCode)
                default:
                    completion?("anything happened and I don know what!", NetError.unknown, statuscCode)
                }
            }
            else if erro?._code == NSURLErrorTimedOut {
                completion?(nil, NetError.timeout, nil)
            }
            else {
                completion?("no response from server.", erro, nil)
            }
        }.resume()
    }
}
