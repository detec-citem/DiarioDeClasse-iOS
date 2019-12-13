//
//  Turma.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 29/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import Foundation

final class TurmaDao {
    //MARK: Constants
    struct CamposServidor {
        static let id = "CodigoTurma"
        static let anoLetivo = "Ano"
        static let alunos = "Alunos"
        static let codigoDiretoria = "CodigoDiretoria"
        static let codigoEscola = "CodigoEscola"
        static let codigoTipoEnsino = "CodigoTipoEnsino"
        static let disciplinas = "Disciplinas"
        static let nome = "NomeTurma"
        static let nomeDiretoria = "NomeDiretoria"
        static let nomeEscola = "NomeEscola"
        static let nomeTipoEnsino = "NomeTipoEnsino"
        static let serie = "Serie"
    }
    
    //MARK: Methods
    static func numeroDeTurmas() -> Int {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.turma)
    }
    
    static func turmaComId(id: UInt32) -> Turma? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.turma, predicate: NSPredicate(format: "id == %d", id), unique: true)?.first as? Turma
    }
    
    static func removerTurmas() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.turma)
    }
    
    static func salvar(json: [String:Any]) -> Turma {
        if let id = json[CamposServidor.id] as? UInt32, let codigoDiretoria = json[CamposServidor.codigoDiretoria] as? UInt32, let codigoEscola = json[CamposServidor.codigoEscola] as? UInt32, let codigoTipoEnsino = json[CamposServidor.codigoTipoEnsino] as? UInt32, let anoLetivo = json[CamposServidor.anoLetivo] as? UInt16, let serie = json[CamposServidor.serie] as? UInt16, let nomeDiretoria = json[CamposServidor.nomeDiretoria] as? String, let nomeEscola = json[CamposServidor.nomeEscola] as? String, let nome = json[CamposServidor.nome] as? String, let nomeTipoEnsino = json[CamposServidor.nomeTipoEnsino] as? String {
            let turma: Turma = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.turma)
            turma.anoLetivo = anoLetivo
            turma.codigoDiretoria = codigoDiretoria
            turma.codigoEscola = codigoEscola
            turma.codigoTipoEnsino = codigoTipoEnsino
            turma.id = id
            turma.nome = nome
            turma.nomeDiretoria = nomeDiretoria
            turma.nomeEscola = nomeEscola
            turma.nomeTipoEnsino = nomeTipoEnsino
            turma.serie = serie
            return turma
        }
        return Turma()
    }
}
