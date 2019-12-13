//
//  HabilidadeModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 23/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import Foundation

final class HabilidadeDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigo = "Codigo"
        static let descricao = "Descricao"
    }
    
    //MARK: Methods
    static func removerHabilidades() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.habilidade)
    }
    
    static func salvar(json: [String:Any], conteudo: Conteudo) -> Habilidade {
        if let codigo = json[CamposServidor.codigo] as? UInt32, let descricao = json[CamposServidor.descricao] as? String {
            if let habilidade: Habilidade = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.habilidade, predicate: NSPredicate(format: "id == %d && conteudo.id == %d", codigo, conteudo.id), unique: true)?.first {
                habilidade.descricao = descricao.replacingOccurrences(of: "¿", with: "")
                habilidade.conteudo.id = conteudo.id
                habilidade.conteudo.descricao = conteudo.descricao
                habilidade.conteudo.habilidades = conteudo.habilidades
                return habilidade
            }
            let habilidade: Habilidade = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.habilidade)
            habilidade.id = codigo
            habilidade.descricao = descricao.replacingOccurrences(of: "¿", with: "")
            habilidade.conteudo = conteudo
            return habilidade
        }
        return Habilidade()
    }
}
