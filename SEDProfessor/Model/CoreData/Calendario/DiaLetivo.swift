//
//  DiaLetivo.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(DiaLetivo)

final class DiaLetivo: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: String
    @NSManaged var dataAula: String
    @NSManaged var bimestre: Bimestre
    @NSManaged var turma: Turma
    @NSManaged var faltasAluno: NSSet
}
