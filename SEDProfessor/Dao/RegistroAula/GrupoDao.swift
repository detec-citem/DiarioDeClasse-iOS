//
//  GrupoModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import Foundation

final class GrupoDao {
    //MARK: Constants
    struct CamposServidor {
        static let anoLetivo = "AnoLetivo"
        static let codigo = "Codigo"
        static let codigoDisciplina = "CodigoDisciplina"
        static let codigoTipoEnsino = "CodigoTipoEnsino"
        static let curriculos = "Curriculos"
        static let serie = "Serie"
    }
    
    //MARK: Methods
    static func buscarGrupos(serie: UInt16, codigoTipoEnsino: UInt32, disciplina: Disciplina) -> [Grupo]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.grupo, predicate: NSPredicate(format: "codigoTipoEnsino == %d AND serie == %d AND disciplina.id == %d", codigoTipoEnsino, serie, disciplina.id))
    }
    
    static func removerGrupos() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.grupo)
    }
    
    static func salvar(json: [String:Any], disciplina: Disciplina) -> Grupo {
        if let codigo = json[CamposServidor.codigo] as? UInt32, let anoLetivo = json[CamposServidor.anoLetivo] as? UInt16, let codigoTipoEnsino = json[CamposServidor.codigoTipoEnsino] as? UInt32, let serie = json[CamposServidor.serie] as? UInt16 {
            let grupo: Grupo = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.grupo)
            grupo.id = codigo
            grupo.anoLetivo = anoLetivo
            grupo.codigoTipoEnsino = codigoTipoEnsino
            grupo.serie = serie
            grupo.disciplina = disciplina
            return grupo
        }
        return Grupo()
    }
}
