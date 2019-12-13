//
//  NotaAluno.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(NotaAluno)

final class NotaAluno: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: String
    @NSManaged var nota: Float
    @NSManaged var aluno: Aluno
    @NSManaged var avaliacao: Avaliacao
}
