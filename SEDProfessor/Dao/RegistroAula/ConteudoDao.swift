//
//  ConteudoModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 23/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import Foundation

final class ConteudoDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigo = "Codigo"
        static let descricao = "Descricao"
        static let habilidades = "Habilidades"
    }
    
    //MARK: Methods
    static func conteudos(bimestre: Bimestre, grupo: Grupo) -> [Conteudo]? {
        if var conteudos: [Conteudo] = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.conteudo, predicate: NSPredicate(format: "curriculo.bimestre.id == %d AND curriculo.grupo.id == %d", bimestre.id, grupo.id)) {
            conteudos.sort { (conteudo1, conteudo2) -> Bool in
                return conteudo1.id < conteudo2.id
            }
            return conteudos
        }
        return nil
    }
    
    static func removerConteudos() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.conteudo)
    }

    static func salvar(json: [String:Any], curriculo: Curriculo) -> Conteudo {
        if let codigo = json[CamposServidor.codigo] as? UInt32, let descricao = json[CamposServidor.descricao] as? String {
            let conteudo: Conteudo = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.conteudo)
            conteudo.id = codigo
            conteudo.descricao = descricao
            conteudo.curriculo = curriculo
            return conteudo
        }
        return Conteudo()
    }
}
