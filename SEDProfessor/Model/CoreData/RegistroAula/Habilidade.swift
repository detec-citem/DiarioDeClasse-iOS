//
//  Habilidade.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import CoreData

@objc(Habilidade)

final class Habilidade: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var descricao: String
    @NSManaged var conteudo: Conteudo
    @NSManaged var habilidadesRegistroAula: NSSet
}
