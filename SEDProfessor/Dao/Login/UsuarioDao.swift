//
//  Professor.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 26/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import Foundation

struct UsuarioAtributos {
    static let ativo = "ativo"
    static let cpf = "cpf"
    static let dataUltimoAcesso = "dataUltimoAcesso"
    static let digitoRG = "digitoRG"
    static let id = "id"
    static let nome = "nome"
    static let rg = "rg"
    static let senha = "senha"
    static let token = "token"
    static let usuario = "usuario"
}

final class UsuarioDao {
    //MARK: Constants
    struct CamposServidor {
        static let digitoRg = "digitoRg"
        static let id = "IdUsuario"
        static let nome = "Nome"
        static let rg = "numeroRg"
        static let token = "Token"
    }
    
    //MARK: Methods
    static func salvar(dataUltimoAcesso: String, username: String, senha: String, json: [String:Any]) -> Usuario? {
        if let id = json[CamposServidor.id] as? UInt32, let digitoRG = json[CamposServidor.digitoRg] as? String, let token = json[CamposServidor.token] as? String, let nome = json[CamposServidor.nome] as? String, let rg = json[CamposServidor.rg] as? String, let encodedPass = senha.base64Encoded {
            if let usuario: Usuario = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.usuario, predicate: NSPredicate(format: "id == %d", id), unique: true)?.first {
                usuario.id = id
                usuario.dataUltimoAcesso = dataUltimoAcesso
                usuario.digitoRG = digitoRG
                usuario.token = token
                usuario.nome = nome
                usuario.rg = rg
                usuario.senha = encodedPass
                usuario.usuario = username
                return usuario
            }
            let usuario: Usuario = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.usuario)
            usuario.id = id
            usuario.dataUltimoAcesso = dataUltimoAcesso
            usuario.digitoRG = digitoRG
            usuario.token = token
            usuario.nome = nome
            usuario.rg = rg
            usuario.senha = encodedPass
            usuario.usuario = username
            return usuario
        }
        return nil
    }

    static func usuarioLogado() -> Usuario? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.usuario)?.first
    }
}
