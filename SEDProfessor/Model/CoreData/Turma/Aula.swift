//
//  Aula.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Aula)

final class Aula: NSManagedObject {
    //MARK: Variables
    @NSManaged var inicioHora: String
    @NSManaged var fimHora: String
    @NSManaged var disciplina: Disciplina
    @NSManaged var frequencia: Frequencia
    @NSManaged var registrosAula: NSSet
    @NSManaged var faltasAluno: NSSet
}
