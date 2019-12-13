//
//  FechamentoTurmaModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 11/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class FechamentoTurmaModel {
    //MARK: Variables
    var id: String!
    var aulasPlanejadas: UInt32!
    var aulasRealizadas: UInt32!
    var justificativa: String!
    var serie: UInt16!
    var dateServer: String?
    var turma: Turma!
    var disciplina: Disciplina!
    var bimestre: Bimestre!
    var tipoFechamento: TipoFechamentoBimestre!
    
    //MARK: Constructors
    init(serie: UInt16, aulasPlanejadas: UInt32, aulasRealizadas: UInt32, justificativa: String, turma: Turma, disciplina: Disciplina, bimestre: Bimestre, tipoFechamento: TipoFechamentoBimestre, dateServer: String? = nil) {
        self.serie = serie
        self.aulasPlanejadas = aulasPlanejadas
        self.aulasRealizadas = aulasRealizadas
        self.justificativa = justificativa
        self.turma = turma
        self.disciplina = disciplina
        self.bimestre = bimestre
        self.tipoFechamento = tipoFechamento
        self.dateServer = dateServer
        id = "ID-" + String(bimestre.id) + "-" + String(disciplina.id) + "-" + String(serie) + "-" + String(tipoFechamento.codigo) + "-" + String(turma.id)
    }
}
