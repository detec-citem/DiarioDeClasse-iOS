//
//  DiaConflitoDao.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 12/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class DiaConflitoDao {
    //MARK: Constants
    struct CamposServidor {
        static let dia = "Dia"
        static let horariosComConflito = "HorariosComConflito"
    }
    
    //MARK: Methods
    static func todosDiasConflito() -> [DiaConflito]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.diaConflito)
    }
    
    static func diasConflitoParaDeletar(disciplina: Disciplina, turma: Turma, contexto: NSManagedObjectContext) -> [DiaConflito]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.diaConflito, predicate: NSPredicate(format: "disciplina.id == %d AND turma.id == %d", disciplina.id, turma.id), contexto: contexto)
    }
    
    static func diasConflitoParaDeletar(diasConflitoSalvos: [String], disciplina: Disciplina, turma: Turma, contexto: NSManagedObjectContext) -> [DiaConflito]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.diaConflito, predicate: NSPredicate(format: "disciplina.id == %d AND turma.id == %d AND NOT (dia IN %@)", disciplina.id, turma.id, diasConflitoSalvos), contexto: contexto)
    }
    
    static func conflitos(disciplina: Disciplina, turma: Turma) -> [DiaConflito]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.diaConflito, predicate: NSPredicate(format: "disciplina.id == %d AND turma.id == %d", disciplina.id, turma.id))
    }
    
    static func removerDiaConflito(diaConflito: DiaConflito, contexto: NSManagedObjectContext) {
        contexto.delete(diaConflito)
    }
    
    static func removerDiasConflito(disciplina: Disciplina, turma: Turma, contexto: NSManagedObjectContext) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.diaConflito, predicate: NSPredicate(format: "disciplina.id == %d AND turma.id == %d", disciplina.id, turma.id), contexto: contexto)
    }
    
    static func salvar(dia: String, disciplina: Disciplina, turma: Turma, contexto: NSManagedObjectContext) -> DiaConflito {
        if let diaConflito: DiaConflito = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.diaConflito, predicate: NSPredicate(format: "dia == %@ AND disciplina.id == %d AND turma.id == %d", dia, disciplina.id, turma.id), contexto: contexto)?.first {
            return diaConflito
        }
        let diaConflito: DiaConflito = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.faltaAluno, contexto: contexto)
        diaConflito.dia = dia
        diaConflito.disciplina = disciplina
        diaConflito.turma = turma
        return diaConflito
    }
}
