//
//  FrequenciaModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import Foundation

final class FrequenciaDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigoTurma = "CodigoTurma"
        static let codigoDiretoria = "CodigoDiretoria"
        static let codigoEscola = "CodigoEscola"
        static let codigoTipoEnsino = "CodigoTipoEnsino"
        static let aulasBimestre = "AulasBimestre"
        static let aulasAno = "AulasAno"
        static let numeroAulasPorSemana = "NumeroAulasPorSemana"
        static let bimestreAnterior = "BimestreAnterior"
        static let bimestreAtual = "BimestreAtual"
        static let bimestreCalendario = "BimestreCalendario"
        static let disciplina = "Disciplina"
        static let calendarioBimestreAtual = "CalendarioBimestreAtual"
        static let serie = "Serie"
        static let avaliacoes = "Avaliacoes"
    }

    //MARK: Methods
    static func buscarFrequencia(bimestre: Bimestre, turma: Turma) -> Frequencia? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.frequencia, predicate: NSPredicate(format: "bimestre.id == %d AND codigoTurma == %d", bimestre.id, turma.id), unique: true)?.first
    }
    
    static func todasFrequencias() -> [Frequencia]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.frequencia)
    }
    
    static func removerFrequencias() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.frequencia)
    }
    
    static func salvar(json: [String: Any], bimestre: Bimestre, disciplina: Disciplina, turma: Turma) -> Frequencia {
        if let aulasBimestre = json[CamposServidor.aulasBimestre] as? UInt32, let aulasAno = json[CamposServidor.aulasAno] as? UInt32, let codigoDiretoria = json[CamposServidor.codigoDiretoria] as? UInt32, let codigoEscola = json[CamposServidor.codigoEscola] as? UInt32, let codigoTipoEnsino = json[CamposServidor.codigoTipoEnsino] as? UInt32, let codigoTurma = json[CamposServidor.codigoTurma] as? UInt32, let serie = json[CamposServidor.serie] as? UInt16, let numeroAulasPorSemana = json[CamposServidor.numeroAulasPorSemana] as? UInt16 {
            let stringId = "ID-" + String(bimestre.id) + "-" + String(codigoDiretoria) + "-" + String(codigoEscola) + "-" + String(codigoTipoEnsino) + "-" + String(codigoTurma) + "-" + String(serie) + "-" + String(disciplina.id)
            let frequencia: Frequencia = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.frequencia)
            frequencia.aulasBimestre = aulasBimestre
            frequencia.aulasAno = aulasAno
            frequencia.id = stringId
            frequencia.codigoDiretoria = codigoDiretoria
            frequencia.codigoEscola = codigoEscola
            frequencia.codigoTipoEnsino = codigoTipoEnsino
            frequencia.codigoTurma = codigoTurma
            frequencia.numeroAulasPorSemana = numeroAulasPorSemana
            frequencia.serie = serie
            frequencia.bimestre = bimestre
            frequencia.disciplina = disciplina
            frequencia.turma = turma
            return frequencia
        }
        return Frequencia()
    }
}
