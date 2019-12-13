//
//  Bimestre.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Bimestre)

final class Bimestre: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var atual: Bool
    @NSManaged var fim: String
    @NSManaged var inicio: String
    @NSManaged var frequencia: Frequencia
    @NSManaged var curriculos: NSSet
    @NSManaged var diasLetivos: NSSet
    @NSManaged var avaliacoes: NSSet
    @NSManaged var fechamentosTurmas: NSSet
    @NSManaged var registrosAula: NSSet
}
