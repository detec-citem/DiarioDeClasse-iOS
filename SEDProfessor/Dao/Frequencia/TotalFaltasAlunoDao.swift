//
//  TotalFaltasAluno.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import Foundation

final class TotalFaltasAlunoDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigoMatricula = "CodigoMatricula"
        static let faltasAnuais = "FaltasAnuais"
        static let faltasBimestrais = "FaltasBimestre"
        static let faltasSequenciais = "FaltasSequenciais"
    }
    
    //MARK: Methods
    static func buscarFaltas(aluno: Aluno, disciplina: Disciplina) -> [TotalFaltasAluno]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.totalFaltasAluno, predicate: NSPredicate(format: "aluno.id == %d AND disciplina.id == %d", aluno.id, disciplina.id))
    }
    
    static func totalFaltas(disciplina: Disciplina?, turma: Turma?) -> [TotalFaltasAluno]? {
        if let codigoDisciplina = disciplina?.id, let codigoTurma = turma?.id {
            return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.totalFaltasAluno, predicate: NSPredicate(format: "disciplina.id == %d AND aluno.turma.id == %d", codigoDisciplina, codigoTurma), sortBy: "aluno.numeroChamada")
        }
        return nil
    }
    
    static func removerTotalFaltasAluno() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.totalFaltasAluno)
    }

    static func salvar(json: [String: Any], aluno: Aluno, disciplina: Disciplina) {
        if let faltasAnuais = json[CamposServidor.faltasAnuais] as? UInt32, let faltasBimestrais = json[CamposServidor.faltasBimestrais] as? UInt32, let faltasSequenciais = json[CamposServidor.faltasSequenciais] as? UInt32 {
            let totalFaltasAluno: TotalFaltasAluno = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.totalFaltasAluno)
            totalFaltasAluno.faltasAnuais = faltasAnuais
            totalFaltasAluno.faltasBimestrais = faltasBimestrais
            totalFaltasAluno.faltasSequenciais = faltasSequenciais
            totalFaltasAluno.aluno = aluno
            totalFaltasAluno.disciplina = disciplina
        }
    }
}
