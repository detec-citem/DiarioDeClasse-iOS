//
//  Frequencia.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 16/07/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class FaltaAlunoDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigoDisciplina = "CodigoDisciplina"
        static let codigoMotivo = "CodigoMotivoFrequencia"
        static let codigoTipo = "CodigoTipoFrequencia"
        static let codigoTurma = "CodigoTurma"
        static let dataAula = "DataDaAula"
        static let justificativa = "Justificativa"
        static let matricula = "CodigoMatriculaAluno"
        static let presenca = "Presenca"
    }
    
    static func acessarFaltas(aula: Aula, diaLetivo: DiaLetivo, disciplina: Disciplina, turma: Turma) -> [FaltaAluno]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.faltaAluno, predicate: NSPredicate(format: "aula.inicioHora == %@ AND aula.fimHora == %@ AND aula.disciplina.id == %d AND diaLetivo.id == %@ AND turma.id == %d", aula.inicioHora, aula.fimHora, disciplina.id, diaLetivo.id, turma.id))
    }
    
    static func frequenciasNaoSincronizadas(contexto: NSManagedObjectContext = CoreDataManager.sharedInstance.contextoPrincipal) -> [FaltaAluno]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.faltaAluno, predicate: NSPredicate(format: "dataServidor == nil"), contexto: contexto)
    }
    
    static func frequenciasNaSemana(numeroAlunos: Int, diaLetivo: DiaLetivo, disciplina: Disciplina, turma: Turma) -> Int {
        let calendario = Calendar.current
        if let dataDiaLetivo = DateFormatter.dataDateFormatter.date(from: diaLetivo.dataAula) {
            var componentesSegunda = calendario.dateComponents([.weekOfYear, .yearForWeekOfYear], from: dataDiaLetivo)
            componentesSegunda.weekday = 2
            var componentesTerca = calendario.dateComponents([.weekOfYear, .yearForWeekOfYear], from: dataDiaLetivo)
            componentesTerca.weekday = 3
            var componentesQuarta = calendario.dateComponents([.weekOfYear, .yearForWeekOfYear], from: dataDiaLetivo)
            componentesQuarta.weekday = 4
            var componentesQuinta = calendario.dateComponents([.weekOfYear, .yearForWeekOfYear], from: dataDiaLetivo)
            componentesQuinta.weekday = 5
            var componentesSexta = calendario.dateComponents([.weekOfYear, .yearForWeekOfYear], from: dataDiaLetivo)
            componentesSexta.weekday = 6
            if let segunda = calendario.date(from: componentesSegunda), let terca = calendario.date(from: componentesTerca), let quarta = calendario.date(from: componentesQuarta), let quinta = calendario.date(from: componentesQuinta), let sexta = calendario.date(from: componentesSexta) {
                let segundaString = DateFormatter.dataDateFormatter.string(from: segunda)
                let tercaString = DateFormatter.dataDateFormatter.string(from: terca)
                let quartaString = DateFormatter.dataDateFormatter.string(from: quarta)
                let quintaString = DateFormatter.dataDateFormatter.string(from: quinta)
                let sextaString = DateFormatter.dataDateFormatter.string(from: sexta)
                return CoreDataManager.sharedInstance.getCount(entity: Tabelas.faltaAluno, predicate: NSPredicate(format: "turma.id == %d AND aula.disciplina.id == %d AND dataCadastro IN %@", turma.id, disciplina.id, [segundaString, tercaString, quartaString, quintaString, sextaString])) / numeroAlunos
            }
        }
        return .zero
    }
    
    static func numeroFrequenciasNaoSincronizadas() -> Int {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.faltaAluno, predicate: NSPredicate(format: "dataServidor == nil"))
    }
    
    static func removerFaltas(aula: Aula, diaLetivo: DiaLetivo, disciplina: Disciplina, turma: Turma) {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.faltaAluno, predicate: NSPredicate(format: "aula.inicioHora == %@ AND aula.fimHora == %@ AND aula.disciplina.id == %d AND diaLetivo.id == %@ AND turma.id == %d", aula.inicioHora, aula.fimHora, disciplina.id, diaLetivo.id, turma.id))
    }
    
    static func temConflitoOffline(aula: Aula, data: String, disciplina: Disciplina, turma: Turma) -> FaltaAluno? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.faltaAluno, predicate: NSPredicate(format: "aula.inicioHora == %@ AND aula.fimHora == %@ AND diaLetivo.dataAula == %@ AND (aula.disciplina.id != %d OR turma.id != %d)", aula.inicioHora, aula.fimHora, data, disciplina.id, turma.id))?.first
    }
    
    static func temFaltas(data: Date, disciplina: Disciplina, turma: Turma) -> Bool {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.faltaAluno, predicate: NSPredicate(format: "aula.disciplina.id == %d AND diaLetivo.dataAula == %@ AND turma.id == %d", disciplina.id, DateFormatter.dataDateFormatter.string(from: data), turma.id)) > .zero
    }
    
    static func temFaltas(aula: Aula, diaLetivo: DiaLetivo, disciplina: Disciplina, turma: Turma) -> Bool {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.faltaAluno, predicate: NSPredicate(format: "aula.inicioHora == %@ AND aula.fimHora == %@ AND aula.disciplina.id == %d AND diaLetivo.id == %@ AND turma.id == %d", aula.inicioHora, aula.fimHora, disciplina.id, diaLetivo.id, turma.id)) > .zero
    }
    
    static func temFaltasNaoSincronizadas(aula: Aula, diaLetivo: DiaLetivo, disciplina: Disciplina, turma: Turma) -> Bool {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.faltaAluno, predicate: NSPredicate(format: "dataServidor == nil AND aula.inicioHora == %@ AND aula.fimHora == %@ AND aula.disciplina.id == %d AND diaLetivo.id == %@ AND turma.id == %d", aula.inicioHora, aula.fimHora, disciplina.id, diaLetivo.id, turma.id)) > .zero
    }
    
    static func temFaltasSincronizadas(aula: Aula, diaLetivo: DiaLetivo, disciplina: Disciplina, turma: Turma) -> Bool {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.faltaAluno, predicate: NSPredicate(format: "dataServidor != nil AND aula.inicioHora == %@ AND aula.fimHora == %@ AND aula.disciplina.id == %d AND diaLetivo.id == %@ AND turma.id == %d", aula.inicioHora, aula.fimHora, disciplina.id, diaLetivo.id, turma.id)) > .zero
    }
}
