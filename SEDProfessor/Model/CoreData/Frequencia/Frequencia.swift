//
//  Frequencia.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 25/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Frequencia)

final class Frequencia: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: String
    @NSManaged var codigoTurma: UInt32
    @NSManaged var codigoDiretoria: UInt32
    @NSManaged var codigoEscola: UInt32
    @NSManaged var codigoTipoEnsino: UInt32
    @NSManaged var aulasBimestre: UInt32
    @NSManaged var aulasAno: UInt32
    @NSManaged var numeroAulasPorSemana: UInt16
    @NSManaged var serie: UInt16
    @NSManaged var bimestre: Bimestre
    @NSManaged var disciplina: Disciplina
    @NSManaged var turma: Turma
    @NSManaged var aulas: NSSet
    @NSManaged var bimestres: NSSet
    @NSManaged var diasFrequencia: NSSet
}
