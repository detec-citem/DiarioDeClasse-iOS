//
//  DiaFrequencia.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 20/02/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData

@objc(DiaFrequencia)

final class DiaFrequencia: NSManagedObject {
    //MARK: Variables
    @NSManaged var data: Date
    @NSManaged var frequencia: Frequencia
    @NSManaged var horariosFrequencia: NSSet
}
