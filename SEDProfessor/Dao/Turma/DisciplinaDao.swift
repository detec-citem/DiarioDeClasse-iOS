//
//  DisciplinaModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//
import Foundation

final class DisciplinaDao {
    //MARK: Constants
    struct CamposServidor {
        static let id = "CodigoDisciplina"
        static let codigoDisciplinaQuebra = "CodigoDisciplinaQuebra"
        static let disciplinasQuebra = "DisciplinasQuebra"
        static let nomeDisciplina = "NomeDisciplina"
        static let permiteLancamentoAvaliacao = "PermiteLancamentoAvaliacao"
        static let permiteLancamentoFrequencia = "PermiteLancamentoFrequencia"
        static let aulas = "Aulas"
        static let faltasAlunos = "FaltasAlunos"
    }
    
    //MARK: Methods
    static func disciplinaComId(id: UInt32) -> Disciplina? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.disciplina, predicate: NSPredicate(format: "id == %d", id))?.first
    }
    
    static func disciplinasAnosIniciais() -> [Disciplina]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.disciplina, predicate: NSPredicate(format: "anoInicial == 1"))
    }
    
    static func removerDisciplinas() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.disciplina)
    }

    static func salvar(json: [String:Any]) -> Disciplina {
        if let id = json[CamposServidor.id] as? UInt32, let nome = json[CamposServidor.nomeDisciplina] as? String {
            let disciplina: Disciplina = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.disciplina)
            disciplina.id = id
            disciplina.nome = nome
            if let permiteLancamentoAvaliacao = json[CamposServidor.permiteLancamentoAvaliacao] as? Bool {
                disciplina.permiteLancamentoAvaliacao = permiteLancamentoAvaliacao
            }
            if let permiteLancamentoFrequencia = json[CamposServidor.permiteLancamentoFrequencia] as? Bool {
                disciplina.permiteLancamentoFrequencia = permiteLancamentoFrequencia
            }
            return disciplina
        }
        return Disciplina()
    }
}
