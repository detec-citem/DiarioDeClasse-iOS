//
//  FechamentoAluno.swift
//  SEDProfessor
//
//  Created by Richard on 15/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import CoreData

@objc(FechamentoAluno)

final class FechamentoAluno: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: String
    @NSManaged var codigo: UInt32
    @NSManaged var codigoMatricula: UInt64
    @NSManaged var faltasCompensadas: UInt32
    @NSManaged var faltas: UInt32
    @NSManaged var faltasAcumuladas: UInt32
    @NSManaged var justificativa: String
    @NSManaged var nota: NSNumber?
    @NSManaged var aluno: Aluno
    @NSManaged var fechamentoTurma: FechamentoTurma
}
