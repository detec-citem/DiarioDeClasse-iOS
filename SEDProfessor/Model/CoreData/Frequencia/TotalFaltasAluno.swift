//
//  TotalFaltasAluno.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(TotalFaltasAluno)

final class TotalFaltasAluno: NSManagedObject {
    //MARK: Variables
    @NSManaged var faltasAnuais: UInt32
    @NSManaged var faltasBimestrais: UInt32
    @NSManaged var faltasSequenciais: UInt32
    @NSManaged var aluno: Aluno
    @NSManaged var disciplina: Disciplina
}
