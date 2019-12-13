//
//  CurriculoModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 30/10/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class CurriculoDao {
    //MARK: Constants
    struct CamposServidor {
        static let bimestre = "Bimestre"
        static let codigo = "Codigo"
        static let conteudos = "Conteudos"
    }
    
    //MARK: Methods
    static func removerCurriculos() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.curriculo)
    }
    
    static func salvar(dadosServidor: [String:Any], bimestre: Bimestre, grupo: Grupo) -> Curriculo {
        if let codigo = dadosServidor[CamposServidor.codigo] as? UInt32 {
            let curriculo: Curriculo = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.curriculo)
            curriculo.id = codigo
            curriculo.bimestre = bimestre
            curriculo.grupo = grupo
            return curriculo
        }
        return Curriculo()
    }
}
