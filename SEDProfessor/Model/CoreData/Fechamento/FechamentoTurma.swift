//
//  FechamentoTurma.swift
//  SEDProfessor
//
//  Created by Richard on 14/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import CoreData

@objc(FechamentoTurma)

final class FechamentoTurma: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: String
    @NSManaged var aulasPlanejadas: UInt32
    @NSManaged var aulasRealizadas: UInt32
    @NSManaged var justificativa: String
    @NSManaged var serie: UInt16
    @NSManaged var dateServer: String?
    @NSManaged var turma: Turma
    @NSManaged var disciplina: Disciplina
    @NSManaged var bimestre: Bimestre
    @NSManaged var tipoFechamento: TipoFechamentoBimestre
    @NSManaged var fechamentosAlunos: NSSet
}
