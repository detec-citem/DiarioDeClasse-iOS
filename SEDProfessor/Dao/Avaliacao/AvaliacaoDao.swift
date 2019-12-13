//
//  Avaliacao.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 07/04/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class AvaliacaoDao {
    //MARK: Constants
    struct CamposServidor {
        static let bimestre = "Bimestre"
        static let id = "Codigo"
        static let data = "Data"
        static let codigoDisciplina = "CodigoDisciplina"
        static let codigoMatriculaAluno = "CodigoMatriculaAluno"
        static let codigoTipoAtividade = "CodigoTipoAtividade"
        static let codigoTurma = "CodigoTurma"
        static let mobileId = "MobileId"
        static let nome = "Nome"
        static let nota = "Nota"
        static let notas = "Notas"
        static let valeNota = "ValeNota"
    }
    
    struct Constants {
        static let deletar = "deletar"
    }
    
    //MARK: Methods
    static func idMaximo() -> Int32 {
        return Int32(CoreDataManager.sharedInstance.maximo(entity: Tabelas.avaliacao, campo: "mobileId"))
    }
    
    static func buscarAvaliacoes(codigoBimestre: UInt32, codigoDisciplina: UInt32, codigoTurma: UInt32) -> [Avaliacao]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "bimestre.id == %d AND disciplina.id == %d AND turma.id == %d AND (dataServidor == nil OR dataServidor != %@)", codigoBimestre, codigoDisciplina, codigoTurma, Constants.deletar))
    }
    
    static func avaliacaoComId(id: Int32) -> Avaliacao? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "id == %d", id))?.first
    }
    
    static func avaliacoesNaoSincronizadas(contexto: NSManagedObjectContext) -> [Avaliacao]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "dataServidor == nil"), contexto: contexto)
    }
    
    static func avaliacoesParaDeletar(contexto: NSManagedObjectContext) -> [Avaliacao]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "dataServidor == %@", Constants.deletar), propertiesToFetch: ["id"], contexto: contexto)
    }
    
    static func numeroAvaliacoesParaDeletar() -> Int {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.avaliacao, predicate: NSPredicate(format: "dataServidor == %@", Constants.deletar))
    }
    
    static func numeroAvaliacoesParaSincronizar() -> Int {
         return CoreDataManager.sharedInstance.getCount(entity: Tabelas.avaliacao, predicate: NSPredicate(format: "dataServidor == nil"))
    }
    
    static func removerAvaliacao(avaliacao: Avaliacao) {
        CoreDataManager.sharedInstance.deletarObjeto(objeto: avaliacao)
    }
    
    static func removerAvaliacoes(contextoDeletar: NSManagedObjectContext, codigosAvaliacoesDeletadas: Set<Int32>) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "id IN %@", codigosAvaliacoesDeletadas), contexto: contextoDeletar)
    }
    
    static func removerAvaliacoes(codigosAvaliacoesSalvas: Set<Int32>) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "NOT (id IN %@)", codigosAvaliacoesSalvas))
    }
    
    static func avaliacoesNaoSalvas(avaliacoesSalvas: Set<Int32>) -> [Avaliacao]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "NOT (id IN %@)", avaliacoesSalvas))
    }
    
    static func salvar(avaliacao: Avaliacao, bimestre: Bimestre, disciplina: Disciplina, turma: Turma) -> Avaliacao {
        if let avaliacaoSalva: Avaliacao = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "mobileId = %d", avaliacao.mobileId), unique: true)?.first {
            avaliacaoSalva.codigoTipoAtividade = avaliacao.codigoTipoAtividade
            avaliacaoSalva.dataCadastro = avaliacao.dataCadastro
            avaliacaoSalva.dataServidor = nil
            avaliacaoSalva.id = avaliacao.id
            avaliacaoSalva.mobileId = avaliacao.mobileId
            avaliacaoSalva.nome = avaliacao.nome
            avaliacaoSalva.valeNota = avaliacao.valeNota
            avaliacaoSalva.bimestre = bimestre
            avaliacaoSalva.disciplina = disciplina
            avaliacaoSalva.turma = turma
            return avaliacaoSalva
        }
        let avaliacaoSalva: Avaliacao = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.avaliacao)
        avaliacaoSalva.codigoTipoAtividade = avaliacao.codigoTipoAtividade
        avaliacaoSalva.dataCadastro = avaliacao.dataCadastro
        avaliacaoSalva.dataServidor = nil
        avaliacaoSalva.id = avaliacao.id
        avaliacaoSalva.mobileId = avaliacao.mobileId
        avaliacaoSalva.nome = avaliacao.nome
        avaliacaoSalva.valeNota = avaliacao.valeNota
        avaliacaoSalva.bimestre = bimestre
        avaliacaoSalva.disciplina = disciplina
        avaliacaoSalva.turma = turma
        return avaliacaoSalva
    }

    static func salvar(primeiraVez: Bool, dadosServidor: [String:Any], bimestre: Bimestre, disciplina: Disciplina, turma: Turma) -> Avaliacao {
        if let valeNota = dadosServidor[CamposServidor.valeNota] as? Bool, let id = dadosServidor[CamposServidor.id] as? Int32, let mobileId = dadosServidor[CamposServidor.mobileId] as? Int32, let codigoTipoAtividade = dadosServidor[CamposServidor.codigoTipoAtividade] as? UInt32, let dataCadastro = dadosServidor[CamposServidor.data] as? String {
            if !primeiraVez, let avaliacao: Avaliacao = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.avaliacao, predicate: NSPredicate(format: "id = %d", id), unique: true)?.first {
                avaliacao.codigoTipoAtividade = codigoTipoAtividade
                avaliacao.dataCadastro = dataCadastro
                avaliacao.dataServidor = DateFormatter.dataDateFormatter.string(from: Date())
                avaliacao.mobileId = mobileId
                avaliacao.valeNota = valeNota
                avaliacao.bimestre = bimestre
                avaliacao.disciplina = disciplina
                avaliacao.turma = turma
                if let nome = dadosServidor[CamposServidor.nome] as? String {
                    avaliacao.nome = nome
                }
                return avaliacao
            }
            let avaliacao: Avaliacao = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.avaliacao)
            avaliacao.codigoTipoAtividade = codigoTipoAtividade
            avaliacao.dataCadastro = dataCadastro
            avaliacao.dataServidor = DateFormatter.dataDateFormatter.string(from: Date())
            avaliacao.id = id
            avaliacao.mobileId = mobileId
            avaliacao.valeNota = valeNota
            avaliacao.bimestre = bimestre
            avaliacao.disciplina = disciplina
            avaliacao.turma = turma
            if let nome = dadosServidor[CamposServidor.nome] as? String {
                avaliacao.nome = nome
            }
            return avaliacao
        }
        return Avaliacao()
    }
}
