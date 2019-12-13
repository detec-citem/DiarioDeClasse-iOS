//
//  Turma.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 25/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Turma)

final class Turma: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var nome: String
    @NSManaged var codigoDiretoria: UInt32
    @NSManaged var nomeDiretoria: String
    @NSManaged var codigoEscola: UInt32
    @NSManaged var nomeEscola: String
    @NSManaged var codigoTipoEnsino: UInt32
    @NSManaged var nomeTipoEnsino: String
    @NSManaged var anoLetivo: UInt16
    @NSManaged var serie: UInt16
    @NSManaged var alunos: NSSet
    @NSManaged var avaliacoes: NSSet
    @NSManaged var diasConflito: NSSet
    @NSManaged var diasLetivos: NSSet
    @NSManaged var faltasAluno: NSSet
    @NSManaged var fechamentosTurmas: NSSet
    @NSManaged var frequencias: NSSet
    @NSManaged var notasAluno: NSSet
    @NSManaged var registrosAula: NSSet
}
