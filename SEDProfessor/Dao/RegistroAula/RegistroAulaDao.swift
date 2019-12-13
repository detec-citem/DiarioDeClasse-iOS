//
//  RegistroAulaModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 10/10/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class RegistroAulaDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigo = "Codigo"
        static let bimestre = "Bimestre"
        static let codigoConteudo = "CodigoConteudo"
        static let codigoGrupoCurriculo = "CodigoGrupoCurriculo"
        static let codigoHabilidade = "CodigoHabilidade"
        static let codigoTurma = "CodigoTurma"
        static let dataCriacao = "DataCriacao"
        static let habilidades = "Habilidades"
        static let horarios = "Horarios"
        static let observacoes = "Observacoes"
    }
    
    //MARK: Methods
    static func temRegistro(data: Date, bimestre: Bimestre, disciplina: Disciplina, turma: Turma) -> Bool {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.registroAula, predicate: NSPredicate(format: "dataCriacao == %@ AND bimestre.id == %d AND grupo.disciplina.id == %d AND turma.id == %d", DateFormatter.dataDateFormatter.string(from: data), bimestre.id, disciplina.id, turma.id)) > .zero
    }
    
    static func temRegistro(data: Date, aula: Aula, bimestre: Bimestre, disciplina: Disciplina, turma: Turma) -> Bool {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.registroAula, predicate: NSPredicate(format: "dataCriacao == %@ AND bimestre.id == %d AND grupo.disciplina.id == %d AND turma.id == %d AND SUBQUERY(horarios, $horario, $horario.inicioHora == %@).@count > 0", DateFormatter.dataDateFormatter.string(from: data), bimestre.id, disciplina.id, turma.id, aula.inicioHora)) > .zero
    }

    static func acessarRegistroAula(data: Date, bimestre: Bimestre, discplina: Disciplina, turma: Turma, aulas: [Aula]) -> RegistroAula? {
        var horarios = [String]()
        for aula in aulas {
            horarios.append(aula.inicioHora)
        }
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.registroAula, predicate: NSPredicate(format: "dataCriacao == %@ AND bimestre.id == %d AND grupo.disciplina.id == %d AND turma.id == %d AND SUBQUERY(horarios, $horario, $horario.inicioHora IN %@).@count > 0", DateFormatter.dataDateFormatter.string(from: data), bimestre.id, discplina.id, turma.id, horarios))?.first
    }
    
    static func acessarRegistrosNaoSincronizados(contexto: NSManagedObjectContext = CoreDataManager.sharedInstance.contextoPrincipal) -> [RegistroAula]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.registroAula, predicate: NSPredicate(format: "enviado == false"), contexto: contexto)
    }
    
    static func numeroRegistrosNaoSincronizados() -> Int {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.registroAula, predicate: NSPredicate(format: "enviado == false"))
    }
    
    static func salvar(primeiraVez: Bool, json: [String:Any], bimestre: Bimestre, grupo: Grupo, turma: Turma, horarios: [Aula]) -> RegistroAula {
        if let codigo = json[CamposServidor.codigo] as? Int32, let dataCriacao = json[CamposServidor.dataCriacao] as? String {
            if !primeiraVez, let registroAula: RegistroAula = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.registroAula, predicate: NSPredicate(format: "id == %d", codigo), unique: true)?.first {
                registroAula.enviado = true
                registroAula.dataCriacao = dataCriacao
                registroAula.bimestre = bimestre
                registroAula.grupo = grupo
                registroAula.turma = turma
                registroAula.horarios = NSSet(array: horarios)
                if let observacoes = json[CamposServidor.observacoes] as? String {
                    registroAula.observacoes = observacoes
                }
                return registroAula
            }
            let registroAula: RegistroAula = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.registroAula)
            registroAula.enviado = true
            registroAula.id = codigo
            registroAula.dataCriacao = dataCriacao
            registroAula.bimestre = bimestre
            registroAula.grupo = grupo
            registroAula.turma = turma
            registroAula.horarios = NSSet(array: horarios)
            if let observacoes = json[CamposServidor.observacoes] as? String {
                registroAula.observacoes = observacoes
            }
            return registroAula
        }
        return RegistroAula()
    }
    
    static func salvar(insertRegistroAula: RegistroAula) {
        if let registroAula: RegistroAula = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.registroAula, predicate: NSPredicate(format: "id == %d AND bimestre.id == %d AND grupo.id == %d AND turma.id == %d", insertRegistroAula.id, insertRegistroAula.bimestre.id, insertRegistroAula.grupo.id, insertRegistroAula.turma.id))?.first {
            registroAula.dataCriacao = insertRegistroAula.dataCriacao
            registroAula.enviado = insertRegistroAula.enviado
            registroAula.observacoes = insertRegistroAula.observacoes
            registroAula.bimestre = insertRegistroAula.bimestre
            registroAula.grupo = insertRegistroAula.grupo
            registroAula.turma = insertRegistroAula.turma
            registroAula.habilidadesRegistroAula = insertRegistroAula.habilidadesRegistroAula
            registroAula.horarios = insertRegistroAula.horarios
        }
    }
}
