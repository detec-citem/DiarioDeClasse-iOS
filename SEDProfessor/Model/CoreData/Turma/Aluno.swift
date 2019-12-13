//
//  Aluno.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 25/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Aluno)

final class Aluno: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var codigoMatricula: UInt64
    @NSManaged var ativo: String
    @NSManaged var numeroChamada: UInt16
    @NSManaged var nome: String
    @NSManaged var ra: String
    @NSManaged var dataNascimento: String
    @NSManaged var possuiDeficiencia: String
    @NSManaged var digitoRa: String
    @NSManaged var ufRa: String
    @NSManaged var pai: String
    @NSManaged var mae: String
    @NSManaged var turma: Turma
    @NSManaged var average: Average
    @NSManaged var faltasAluno: NSSet
    @NSManaged var notasAluno: NSSet
    @NSManaged var totalFaltasAluno: NSSet
}

extension Aluno {
    func alunoAtivo() -> Bool {
        return ativo == "Ativo"
    }
}
