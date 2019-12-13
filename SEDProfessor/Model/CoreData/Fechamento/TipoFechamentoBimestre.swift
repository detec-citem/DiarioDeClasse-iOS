//
//  TipoFechamentoBimestre.swift
//  SEDProfessor
//
//  Created by Kesley Ribeiro on 10/08/2018.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import CoreData

@objc(TipoFechamentoBimestre)

final class TipoFechamentoBimestre: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var ano: UInt16
    @NSManaged var inicio: Date
    @NSManaged var fim: Date
    @NSManaged var nome: String
    @NSManaged var codigo: UInt32
    @NSManaged var fechamentosTurma: NSSet
}
