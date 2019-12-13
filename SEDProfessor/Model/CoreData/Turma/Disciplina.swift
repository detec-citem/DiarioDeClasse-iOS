//
//  Disciplina.swift
//  SEDProfessor
//
//  Created by Richard on 26/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import CoreData

@objc(Disciplina)

final class Disciplina: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: UInt32
    @NSManaged var anoInicial: Bool
    @NSManaged var nome: String
    @NSManaged var permiteLancamentoAvaliacao: Bool
    @NSManaged var permiteLancamentoFrequencia: Bool
    @NSManaged var aulas: NSSet
    @NSManaged var avaliacoes: NSSet
    @NSManaged var diasConflito: NSSet
    @NSManaged var frequencias: NSSet
    @NSManaged var fechamentosTurmas: NSSet
    @NSManaged var grupos: NSSet
    @NSManaged var totalFaltasAluno: NSSet
    
    //MARK: Methods
    func disciplinaAnosIniciais() -> Bool {
        return id == TipoDisciplina.disciplinaInicial.rawValue
    }
}
