//
//  Aluno.swift
//  PrototipoFrequencia
//
//  Created by Victor Bozelli Alvarez on 18/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import Foundation

final class AlunoDao {
    //MARK: Constants
    fileprivate struct CamposServidor {
        static let id = "CodigoAluno"
        static let matricula = "CodigoMatricula"
        static let ativo = "AlunoAtivo"
        static let chamada = "NumeroChamada"
        static let nome = "NomeAluno"
        static let numeroRa = "NumeroRa"
        static let digitoRa = "DigitoRa"
        static let ufRa = "UfRa"
        static let pais = "Pais"
        static let pai = "Pai"
        static let mae = "Mae"
        static let dataNascimento = "DtNascimento"
        static let possuiDeficiencia = "PossuiDeficiencia"
    }
    
    //MARK: Methods
    static func alunosDaTurma(turmaId: Int) -> [Aluno]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.aluno, predicate: NSPredicate(format: "turma.id == %d", turmaId))
    }
    
    static func alunoComId(alunoId: UInt32) -> Aluno? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.aluno, predicate: NSPredicate(format: "id == %d", alunoId), unique: true)?.first
    }
    
    static func removerAlunos() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.aluno)
    }

    static func salvar(json: [String:Any], turma: Turma) -> Aluno? {
        if let id = json[CamposServidor.id] as? UInt32, let chamada = json[CamposServidor.chamada] as? UInt16, let matricula = json[CamposServidor.matricula] as? UInt64, let ativo = json[CamposServidor.ativo] as? String, let nome = json[CamposServidor.nome] as? String, let numeroRa = json[CamposServidor.numeroRa] as? String, let digitoRa = json[CamposServidor.digitoRa] as? String, let ufra = json[CamposServidor.ufRa] as? String, let dataNascimento = json[CamposServidor.dataNascimento] as? String, let possuiDeficiencia = json[CamposServidor.possuiDeficiencia] as? String, let pais = json[CamposServidor.pais] as? [String:Any] {
            let aluno: Aluno = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.aluno)
            aluno.ativo = ativo
            aluno.codigoMatricula = matricula
            aluno.dataNascimento = dataNascimento
            aluno.digitoRa = digitoRa
            aluno.id = id
            aluno.nome = nome
            aluno.numeroChamada = chamada
            aluno.possuiDeficiencia = possuiDeficiencia
            aluno.ra = numeroRa
            aluno.turma = turma
            aluno.ufRa = ufra
            if let mae = pais[CamposServidor.mae] as? String {
                aluno.mae = mae
            }
            if let pai = pais[CamposServidor.pai] as? String {
                aluno.pai = pai
            }
            return aluno
        }
        return nil
    }
}
