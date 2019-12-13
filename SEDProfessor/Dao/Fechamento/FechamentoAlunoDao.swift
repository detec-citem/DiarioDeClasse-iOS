//
//  FechamentoAlunoModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 15/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import Foundation

final class FechamentoAlunoDao {
    //MARK: Constants
    struct CamposServidor {
        static let aluno = "Aluno"
        static let codigo = "Codigo"
        static let codigoMatricula = "CodigoMatricula"
        static let faltas = "Faltas"
        static let faltasAcumuladas = "FaltasAcumuladas"
        static let faltasCompensadas = "FaltasCompensadas"
        static let fechamentoTurma = "FechamentoTurma"
        static let justificativa = "Justificativa"
        static let nota = "Nota"
    }

    //MARK: Methods
    static func salvar(primeiraVez: Bool, json: [String:Any], aluno: Aluno, fechamentoTurma: FechamentoTurma) {
        if let codigo = json[CamposServidor.codigo] as? UInt32, let codigoMatricula = json[CamposServidor.codigoMatricula] as? UInt64, let faltas = json[CamposServidor.faltas] as? UInt32, let faltasAcumuladas = json[CamposServidor.faltasAcumuladas] as? UInt32, let faltasCompensadas = json[CamposServidor.faltasCompensadas] as? UInt32 {
            let id = "ID-" + String(fechamentoTurma.id) + "-" + String(codigoMatricula)
            if !primeiraVez, let fechamentoAluno: FechamentoAluno = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.fechamentoAluno, predicate: NSPredicate(format: "id == %@", id), unique: true)?.first {
                fechamentoAluno.codigo = codigo
                fechamentoAluno.codigoMatricula = aluno.codigoMatricula
                fechamentoAluno.faltas = faltas
                fechamentoAluno.faltasAcumuladas = faltasAcumuladas
                fechamentoAluno.faltasCompensadas = faltasCompensadas
                fechamentoAluno.aluno = aluno
                fechamentoAluno.fechamentoTurma = fechamentoTurma
                if let justificativa = json[CamposServidor.justificativa] as? String {
                    fechamentoAluno.justificativa = justificativa
                }
                if let nota = json[CamposServidor.nota] as? Int {
                    fechamentoAluno.nota = NSNumber(value: nota)
                }
                return
            }
            let fechamentoAluno: FechamentoAluno = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.fechamentoAluno)
            fechamentoAluno.id = id
            fechamentoAluno.codigo = codigo
            fechamentoAluno.codigoMatricula = UInt64(codigoMatricula)
            fechamentoAluno.faltas = faltas
            fechamentoAluno.faltasAcumuladas = faltasAcumuladas
            fechamentoAluno.faltasCompensadas = faltasCompensadas
            fechamentoAluno.aluno = aluno
            fechamentoAluno.fechamentoTurma = fechamentoTurma
            if let justificativa = json[CamposServidor.justificativa] as? String {
                fechamentoAluno.justificativa = justificativa
            }
            if let nota = json[CamposServidor.nota] as? Int {
                fechamentoAluno.nota = NSNumber(value: nota)
            }
        }
    }
}
