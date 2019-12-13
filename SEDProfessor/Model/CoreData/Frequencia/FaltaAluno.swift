//
//  FaltasAluno.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(FaltaAluno)

final class FaltaAluno: NSManagedObject {
    //MARK: Variables
    @NSManaged var tipo: String
    @NSManaged var justificativa: String
    @NSManaged var dataServidor: String?
    @NSManaged var dataCadastro: String
    @NSManaged var codigoMotivo: UInt32
    @NSManaged var presenca: Bool
    @NSManaged var aluno: Aluno
    @NSManaged var aula: Aula
    @NSManaged var diaLetivo: DiaLetivo
    @NSManaged var usuario: Usuario
    @NSManaged var turma: Turma
}
