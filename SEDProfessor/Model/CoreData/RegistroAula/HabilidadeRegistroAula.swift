//
//  HabilidadeRegistroAula.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 23/10/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData

@objc(HabilidadeRegistroAula)

final class HabilidadeRegistroAula: NSManagedObject {
    @NSManaged var selecionada: Bool
    @NSManaged var habilidade: Habilidade
    @NSManaged var registroAula: RegistroAula
}
