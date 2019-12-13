//
//  Grupo.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Grupo)

final class Grupo: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var anoLetivo: UInt16
    @NSManaged var codigoTipoEnsino: UInt32
    @NSManaged var serie: UInt16
    @NSManaged var disciplina: Disciplina
    @NSManaged var curriculos: NSSet
    @NSManaged var registrosAula: NSSet
}
