//
//  DisciplinasIniciaisDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 06/11/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import Foundation

protocol DisciplinasIniciaisDelegate: class {
    func podeSelecionar(disciplina: Disciplina) -> Bool
    func selecionouDisciplina(disciplina: Disciplina)
}
