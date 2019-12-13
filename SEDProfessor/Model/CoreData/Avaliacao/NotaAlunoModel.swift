//
//  NotaAlunoModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 11/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class NotaAlunoModel {
    //MARK: Variables
    var id: String!
    var nota: Float!
    var aluno: Aluno!
    var avaliacao: Avaliacao!
    
    //MARK: Constructor
    init(nota: Float, aluno: Aluno, avaliacao: Avaliacao) {
        self.nota = nota
        self.aluno = aluno
        self.avaliacao = avaliacao
        self.id = "NOTA-ALUNO-ID-" + String(aluno.id) + "-" + String(avaliacao.id)
    }
}
