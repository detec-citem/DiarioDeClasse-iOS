//
//  HorarioConflito.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 12/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData

@objc(HorarioConflito)

final class HorarioConflito: NSManagedObject {
    //MARK: Variables
    @NSManaged var horario: String
    @NSManaged var diaConflito: DiaConflito
}
