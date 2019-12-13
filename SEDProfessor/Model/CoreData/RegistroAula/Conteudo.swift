//
//  Conteudo.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Conteudo)

final class Conteudo: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var descricao: String
    @NSManaged var curriculo: Curriculo
    @NSManaged var habilidades: NSSet
}
