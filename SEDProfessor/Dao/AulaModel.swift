//
//  AulasModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 Prodesp. All rights reserved.
//

import Foundation

enum AulaAtributos: String {
    case Id = "id"
    case InicioHora = "inicioHora"
    case FimHora = "fimHora"
    case DiaSemana = "diaSemana"
    case Disciplina = "disciplina"
    case DisciplinaId = "disciplina.id"
    case Hora = "hora"
    case Frequencia = "frequencia"
    case FrequenciaId = "frequencia.id"
}

enum AulaAtributosServidor: String {
    case Id = "CodigoAula"
    case InicioHora = "Inicio"
    case FimHora = "Fim"
    case DiaSemana
}

final class AulaModel {
    //MARK: Variables
    var id: UInt32?
    var inicioHora: String?
    var fimHora: String?
    var diaSemana: UInt16?
    var disciplina: Disciplina?
    var aula: Aula?
    var frequencia: Frequencia?
    var hora: String?

    //MARK: Constructors
    init() {
    }

    static func getIdWith(horarioAula: String?, aulas: [AulaModel]?) -> UInt32? {
        return aulas?.filter({ $0.inicioHora == horarioAula }).first?.id
    }

    static func getAulas(aulas: [AulaModel], dataLancamento: Date?) -> (horarios: [String], aulasDoDia: [AulaModel])? {
        var retorno: (horarios: [String], aulasDoDia: [AulaModel])?
        var aulasDoDia = [AulaModel]()
        var horarios = [String]()
        if let dataLancamento = dataLancamento {
            let numDate = Date.getNumValuesFromDate(date: dataLancamento)
            for aula in aulas {
                if let diaSemana = aula.diaSemana,
                    diaSemana == numDate.diaDaSemana - 1,
                    let horaInicial = aula.inicioHora,
                    let horaFinal = aula.fimHora {
                    let hora = "\(horaInicial) - \(horaFinal)"
                    let aulaDoDia = aula
                    aulaDoDia.hora = hora
                    aulasDoDia.append(aulaDoDia)
                    horarios.append(hora)
                }
            }

            if !aulasDoDia.isEmpty && !horarios.isEmpty {
                retorno = (horarios, aulasDoDia)
            }
        }
        if retorno != nil {
            return retorno
        }
        return nil
    }
    
    static func accessarDadosAula(predicate: NSPredicate? = nil) -> [AulaModel]? {
        var aulas: [AulaModel]? = nil
        let dados = CoreDataManager.sharedInstance.getData(entity: Tabelas.aula, predicate: predicate)
        if let dados = dados as? [Aula], !dados.isEmpty {
            aulas = [AulaModel]()
            aulas?.reserveCapacity(dados.count)
            for entity in dados {
                let aula = AulaModel()
                aula.diaSemana = entity.diaSemana
                aula.id = entity.id
                aula.inicioHora = entity.inicioHora
                aula.fimHora = entity.fimHora
                aula.disciplina = entity.disciplina
                aula.frequencia = entity.frequencia
                aula.aula = entity
                aulas?.append(aula)
            }
        }
        return aulas
    }

    static func salvarDadosAula(dadosServidor: [String: Any], disciplina: Disciplina, frequencia: Frequencia) {
        if let id = dadosServidor[AulaAtributosServidor.Id.rawValue] as? UInt32, let diaSemana = dadosServidor[AulaAtributosServidor.DiaSemana.rawValue] as? UInt16, let inicioHora = dadosServidor[AulaAtributosServidor.InicioHora.rawValue] as? String, let fimHora = dadosServidor[AulaAtributosServidor.FimHora.rawValue] as? String {
            let dados = CoreDataManager.sharedInstance.getData(entity: Tabelas.aula, predicate: NSPredicate(format: "id == %d", id), unique: true, propertiesToFetch: ["id"])
            if let aula = dados?.first as? Aula {
                aula.diaSemana = diaSemana
                aula.inicioHora = inicioHora
                aula.fimHora = fimHora
                aula.disciplina = disciplina
                aula.frequencia = frequencia
                return
            }

            let aula = CoreDataManager.sharedInstance.createObject(entity: Tabelas.aula) as! Aula
            aula.id = id
            aula.diaSemana = diaSemana
            aula.inicioHora = inicioHora
            aula.fimHora = fimHora
            aula.disciplina = disciplina
            aula.frequencia = frequencia
        }
    }
}
