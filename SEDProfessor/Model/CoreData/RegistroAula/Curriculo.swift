//
//  Curriculo.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 30/10/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import CoreData

@objc(Curriculo)

final class Curriculo: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var bimestre: Bimestre
    @NSManaged var grupo: Grupo
    @NSManaged var conteudos: NSSet
}
