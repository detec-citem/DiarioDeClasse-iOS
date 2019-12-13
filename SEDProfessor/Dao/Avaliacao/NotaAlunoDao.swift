//
//  NotasAlunoModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import Foundation

final class NotaAlunoDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigoMatriculaAluno = "CodigoMatriculaAluno"
        static let nota = "Nota"
    }
    
    //MARK: Methods
    static func removerNotasDaAvaliacao(avaliacao: Avaliacao) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.notaAluno, predicate: NSPredicate(format: "avaliacao.id == %d", avaliacao.id))
    }
    
    static func removerNotasDasAvaliacoes(codigosAvaliacoesDeletadas: Set<Int32>) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.notaAluno, predicate: NSPredicate(format: "avaliacao.id IN %@", codigosAvaliacoesDeletadas))
    }
    
    static func removerNotasDasAvaliacoes(codigosAvaliacoesSalvas: Set<Int32>) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.notaAluno, predicate: NSPredicate(format: "NOT (avaliacao.id IN %@)", codigosAvaliacoesSalvas))
    }

    static func salvar(nota: NotaAlunoModel) {
        if let notaAluno: NotaAluno = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.notaAluno, predicate: NSPredicate(format: "id == %@", nota.id), unique: true)?.first {
            notaAluno.nota = nota.nota
            notaAluno.aluno = nota.aluno
            notaAluno.avaliacao = nota.avaliacao
            return
        }
        let notaAluno: NotaAluno = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.notaAluno)
        notaAluno.id = nota.id
        notaAluno.nota = nota.nota
        notaAluno.aluno = nota.aluno
        notaAluno.avaliacao = nota.avaliacao
    }
    
    static func salvar(primeiraVez: Bool, json: [String:Any], aluno: Aluno, avaliacao: Avaliacao) {
        if let nota = json[CamposServidor.nota] as? Float {
            let id = "NOTA-ALUNO-ID-" + String(aluno.id) + "-" + String(avaliacao.id)
            if !primeiraVez, let notaAluno: NotaAluno = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.notaAluno, predicate: NSPredicate(format: "id == %@", id), unique: true)?.first {
                notaAluno.nota = nota
                notaAluno.aluno = aluno
                notaAluno.avaliacao = avaliacao
                return
            }
            let notaAluno: NotaAluno = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.notaAluno)
            notaAluno.id = id
            notaAluno.nota = nota
            notaAluno.aluno = aluno
            notaAluno.avaliacao = avaliacao
        }
    }
}
