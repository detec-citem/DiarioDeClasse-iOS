//
//  BimestreModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import Foundation

final class BimestreDao {
    //MARK: Constants
    struct CamposServidor {
        static let id = "Numero"
        static let inicio = "Inicio"
        static let fim = "Fim"
    }
    
    //MARK: Methods
    static func todosBimestres(disciplina: Disciplina, turma: Turma) -> [Bimestre]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.bimestre, predicate: NSPredicate(format: "id IN %@ AND frequencia.disciplina.id == %d AND frequencia.turma.id == %d", [1, 2, 3, 4], disciplina.id, turma.id), sortBy: "id")
    }
    
    static func removerBimestres() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.bimestre)
    }

    static func salvar(json: [String:Any]) -> Bimestre {
        if let id = json[CamposServidor.id] as? UInt32, let inicio = json[CamposServidor.inicio] as? String, let fim = json[CamposServidor.fim] as? String {
            let bimestre: Bimestre = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.bimestre)
            bimestre.id = id
            bimestre.inicio = inicio
            bimestre.fim = fim
            return bimestre
        }
        return Bimestre()
    }
}
