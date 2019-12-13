//
//  HorarioDao.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 12/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class HorarioConflitoDao {
    //MARK: Constants
    fileprivate struct CamposServidor {
        static let horario = "Horario"
    }
    
    //MARK: Methods
    static func removerHorariosConflito(diaConflito: DiaConflito, horariosConflitoSalvos: [String], contexto: NSManagedObjectContext) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.horarioConflito, predicate: NSPredicate(format: "diaConflito.dia == %@ AND diaConflito.disciplina.id == %d AND diaConflito.turma.id == %d AND NOT (horario IN %@)", diaConflito.dia, diaConflito.disciplina.id, diaConflito.turma.id, horariosConflitoSalvos), contexto: contexto)
    }
    
    static func removerHorariosConflito(horariosConflito: Set<HorarioConflito>, contexto: NSManagedObjectContext) {
        for horarioConflito in horariosConflito {
            contexto.delete(horarioConflito)
        }
    }
    
    static func salvar(horarioJson: [String:Any], diaConflito: DiaConflito, contexto: NSManagedObjectContext) -> HorarioConflito {
        if let horario = horarioJson[CamposServidor.horario] as? String {
            if let horarioConflito: HorarioConflito = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.horarioConflito, predicate: NSPredicate(format: "horario == %@ AND diaConflito.dia == %@ AND diaConflito.disciplina.id == %d AND diaConflito.turma.id == %d", horario, diaConflito.dia, diaConflito.disciplina.id, diaConflito.turma.id), contexto: contexto)?.first {
                return horarioConflito
            }
            let horarioConflito: HorarioConflito = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.horarioConflito, contexto: contexto)
            horarioConflito.horario = horario
            horarioConflito.diaConflito = diaConflito
            return horarioConflito
        }
        return HorarioConflito()
    }
}
