//
//  User.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 25/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Usuario)

final class Usuario: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var usuario: String
    @NSManaged var senha: String
    @NSManaged var nome: String
    @NSManaged var cpf: String
    @NSManaged var rg: String
    @NSManaged var digitoRG: String
    @NSManaged var dataUltimoAcesso: String
    @NSManaged var token: String
    @NSManaged var faltasAluno: NSSet
}
