//
//  AlunoAvaliacaoViewDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 13/12/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import Foundation

protocol AlunoAvaliacaoDelegate: class {
    func avaliouAluno(aluno student: Aluno, view: AlunoAvaliacaoView)
    func mostrarDetalhes(aluno: Aluno)
}
