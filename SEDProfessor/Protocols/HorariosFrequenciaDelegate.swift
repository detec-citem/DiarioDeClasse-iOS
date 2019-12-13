//
//  HorariosDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 23/11/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import Foundation

protocol HorariosFrequenciaDelegate: class {
    func editarFrequencia(aula: Aula)
    func excluirFrequencia(aula: Aula, indice: Int)
    func selecionouAulas(aulas: [Aula])
}
