//
//  HorarioFrequenciaDao.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 27/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class HorarioFrequenciaDao {
    //MARK: Methods
    static func removerHorariosFrequencia() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.horarioFrequencia)
    }
    
    static func temHorarioComFrequencia(aula: Aula, diaLetivo: DiaLetivo, disciplina: Disciplina, turma: Turma) -> Bool {
        return CoreDataManager.sharedInstance.getCount(entity: Tabelas.horarioFrequencia, predicate: NSPredicate(format: "horario == %@ AND diaFrequencia.data == %@ AND diaFrequencia.frequencia.disciplina.id == %@ AND diaFrequencia.frequencia.turma.id == %@", argumentArray: [aula.inicioHora, DateFormatter.dataDateFormatter.date(from: diaLetivo.dataAula)!, disciplina.id, turma.id])) > .zero
    }
    
    static func salvar(horario: String, diaFrequencia: DiaFrequencia) {
        if CoreDataManager.sharedInstance.getCount(entity: Tabelas.horarioFrequencia, predicate: NSPredicate(format: "horario == %@ AND diaFrequencia.data == %@ AND diaFrequencia.frequencia.id == %@", argumentArray: [horario, diaFrequencia.data, diaFrequencia.frequencia.id])) == .zero {
            let horarioFrequencia: HorarioFrequencia = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.horarioFrequencia)
            horarioFrequencia.horario = horario
            horarioFrequencia.diaFrequencia = diaFrequencia
        }
    }
}
