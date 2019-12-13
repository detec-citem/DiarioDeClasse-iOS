//
//  Avaliacao.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Avaliacao)

final class Avaliacao: NSManagedObject {
    //MARK: Variables
    @NSManaged var valeNota: Bool
    @NSManaged var nome: String
    @NSManaged var mobileId: Int32
    @NSManaged var id: Int32
    @NSManaged var dataServidor: String?
    @NSManaged var dataCadastro: String
    @NSManaged var codigoTipoAtividade: UInt32
    @NSManaged var bimestre: Bimestre
    @NSManaged var disciplina: Disciplina
    @NSManaged var turma: Turma
    @NSManaged var notasAluno: NSSet
}
