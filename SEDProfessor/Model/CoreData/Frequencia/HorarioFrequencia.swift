//
//  HorarioFrequencia.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 27/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData

@objc(HorarioFrequencia)

final class HorarioFrequencia: NSManagedObject {
    @NSManaged var horario: String
    @NSManaged var diaFrequencia: DiaFrequencia
}
