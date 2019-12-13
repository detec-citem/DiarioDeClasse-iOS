//
//  RegistroAula.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 30/10/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import CoreData

@objc(RegistroAula)

final class RegistroAula: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: Int32
    @NSManaged var enviado: Bool
    @NSManaged var observacoes: String
    @NSManaged var dataCriacao: String?
    @NSManaged var bimestre: Bimestre
    @NSManaged var grupo: Grupo
    @NSManaged var turma: Turma
    @NSManaged var habilidadesRegistroAula: NSSet
    @NSManaged var horarios: NSSet
}
