//
//  AulasModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import Foundation

final class AulaDao {
    //MARK: Constants
    struct CamposServidor {
        static let fim = "Fim"
        static let inicio = "Inicio"
    }
    
    //MARK: Methods
    static func buscarAulas(bimestre: Bimestre, disciplina: Disciplina, turma: Turma) -> [Aula]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.aula, predicate: NSPredicate(format: "disciplina.id == %d AND frequencia.bimestre.id == %d AND frequencia.turma.id == %d", disciplina.id, bimestre.id, turma.id))
    }
    
    static func buscarAulas(disciplina: Disciplina, frequencia: Frequencia) -> [Aula]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.aula, predicate: NSPredicate(format: "disciplina.id == %d AND frequencia.id == %@", disciplina.id, frequencia.id))
    }
    
    static func removerAulas() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.aula)
    }

    static func salvar(json: [String:Any], disciplina: Disciplina, frequencia: Frequencia) -> Aula {
        if let fim = json[CamposServidor.fim] as? String, let inicio = json[CamposServidor.inicio] as? String {
            let aula: Aula = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.aula)
            aula.inicioHora = inicio
            aula.fimHora = fim
            aula.disciplina = disciplina
            aula.frequencia = frequencia
            return aula
        }
        return Aula()
    }
}
