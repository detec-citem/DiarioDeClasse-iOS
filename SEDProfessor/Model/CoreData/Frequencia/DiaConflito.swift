//
//  DiaConflito.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 12/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData

@objc(DiaConflito)

final class DiaConflito: NSManagedObject {
    //MARK: Variables
    @NSManaged var dia: String
    @NSManaged var disciplina: Disciplina
    @NSManaged var turma: Turma
    @NSManaged var horarios: NSSet
}
