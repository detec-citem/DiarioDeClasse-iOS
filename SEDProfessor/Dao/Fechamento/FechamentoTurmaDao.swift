//
//  FechamentoTurmaModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 14/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import Foundation

typealias FilteredFechamentoCurrentToSync = (bimestreId: UInt32, turmaId: UInt32, disciplinaId: UInt32, serie: UInt16, tipo: UInt32)

final class FechamentoTurmaDao {
    //MARK: Constants
    struct CamposServidor {
        static let codigoTurma = "CodigoTurma"
        static let codigoDisciplina = "CodigoDisciplina"
        static let numeroSerie = "NumeroSerie"
        static let aulasPlanejadas = "AulasPlanejadas"
        static let aulasRealizadas = "AulasRealizadas"
        static let justificativa = "Justificativa"
        static let codigoTipoFechamento = "CodigoTipoFechamento"
        static let fechamentos = "Fechamentos"
    }
    
    //MARK: Methods
    static func buscarFechamento(id: String) -> FechamentoTurma? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.fechamentoTurma, predicate: NSPredicate(format: "id == %@", id), unique: true)?.first
    }
    
    static func buscarFechamento(serie: UInt16, bimestre: Bimestre, disciplina: Disciplina, tipoFechamento: TipoFechamentoBimestre, turma: Turma) -> FechamentoTurma? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.fechamentoTurma, predicate: NSPredicate(format: "bimestre.id = %d AND disciplina.id = %d AND serie = %d AND tipoFechamento.id = %@ AND turma.id = %d", bimestre.id, disciplina.id, serie, tipoFechamento.id, turma.id))?.first
    }
    
//    static func formateDataToSync(syncType: Requests.SyncOptionsType, currentFilter: FilteredFechamentoCurrentToSync? = nil) -> (json: [[String: Any]], dataModel: [FechamentoTurmaModel])? {
//        var array = [[String: Any]]()
//        var objectToSync = [FechamentoTurmaModel]()
//        let resultModelData = getData()
//        switch syncType
//        {
//        case .current:
//            if let currentFilter = currentFilter, let resultData = resultModelData {
//                objectToSync = filterWith(data: resultData, currentFilter: currentFilter)
//            }
//        default:
//            if let resultData = resultModelData {
//                objectToSync = resultData
//            }
//        }
//        if objectToSync.isEmpty == false {
//            for object in objectToSync {
//                var fechamentos: [[String: Any]] {
//                    var result = [[String: Any]]()
//                    if let data = object.fechamentoTurma?.fechamentosAlunos.allObjects as? [FechamentoAluno], data.isEmpty == false {
//                        for model in data {
//                            var item = [String: Any]()
//                            item[FechamentoAlunoModel.AttributesServer.codigo] = model.codigo
//                            item[FechamentoAlunoModel.AttributesServer.nota] = model.nota
//                            item[FechamentoAlunoModel.AttributesServer.faltas] = model.faltas
//                            item[FechamentoAlunoModel.AttributesServer.faltasCompensadas] = model.faltasCompensadas
//                            item[FechamentoAlunoModel.AttributesServer.faltasAcumuladas] = model.faltasAcumuladas
//                            item[FechamentoAlunoModel.AttributesServer.justificativa] = model.justificativa
//                            item[FechamentoAlunoModel.AttributesServer.aluno] = model.codigoMatricula
//                            result.append(item)
//                        }
//                    }
//                    return result
//                }
//                if let turmaId = object.turma?.id, let disciplinaId = object.disciplina?.id, let serie = object.serie, let aulasPlanejadas = object.aulasPlanejadas, let aulasR = object.aulasRealizadas, let tipo = object.tipoFechamento?.codigo {
//                    var justificativa: String
//                    if let objectJustificatica = object.justificativa {
//                        justificativa = objectJustificatica
//                    } else {
//                        justificativa = ""
//                    }
//                    array.append([AttributesServer.turmaId: turmaId, AttributesServer.disciplinaId: disciplinaId, AttributesServer.serie: serie, AttributesServer.aulasPlanejadas: aulasPlanejadas, AttributesServer.aulasRealizadas: aulasR, AttributesServer.tipoId: tipo, AttributesServer.justificativa: justificativa, AttributesServer.fechamentos: fechamentos])
//                }
//            }
//        }
//        if array.isEmpty == false {
//            return (array, objectToSync)
//        }
//        return nil
//    }
    
    static func salvar(fechamentoTurma: FechamentoTurma) {
        if let fechamentoTurmaSalva: FechamentoTurma = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.fechamentoTurma, predicate: NSPredicate(format: "id == %@", fechamentoTurma.id), unique: true)?.first {
            fechamentoTurmaSalva.aulasPlanejadas = fechamentoTurma.aulasPlanejadas
            fechamentoTurmaSalva.aulasRealizadas = fechamentoTurma.aulasRealizadas
            fechamentoTurmaSalva.justificativa = fechamentoTurma.justificativa
            fechamentoTurmaSalva.serie = fechamentoTurma.serie
            fechamentoTurmaSalva.bimestre = fechamentoTurma.bimestre
            fechamentoTurmaSalva.disciplina = fechamentoTurma.disciplina
            fechamentoTurmaSalva.tipoFechamento = fechamentoTurma.tipoFechamento
            fechamentoTurmaSalva.turma = fechamentoTurma.turma
            fechamentoTurmaSalva.dateServer = DateFormatter.dataDateFormatter.string(from: Date())
            return
        }
        let fechamentoTurmaSalva: FechamentoTurma = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.fechamentoTurma)
        fechamentoTurmaSalva.aulasPlanejadas = fechamentoTurma.aulasPlanejadas
        fechamentoTurmaSalva.aulasRealizadas = fechamentoTurma.aulasRealizadas
        fechamentoTurmaSalva.id = fechamentoTurma.id
        fechamentoTurmaSalva.justificativa = fechamentoTurma.justificativa
        fechamentoTurmaSalva.serie = fechamentoTurma.serie
        fechamentoTurmaSalva.bimestre = fechamentoTurma.bimestre
        fechamentoTurmaSalva.disciplina = fechamentoTurma.disciplina
        fechamentoTurmaSalva.tipoFechamento = fechamentoTurma.tipoFechamento
        fechamentoTurmaSalva.turma = fechamentoTurma.turma
        fechamentoTurmaSalva.dateServer = DateFormatter.dataDateFormatter.string(from: Date())
    }
    
    static func salvar(fechamentoTurma: FechamentoTurmaModel) {
        if let fechamentoTurmaSalva: FechamentoTurma = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.fechamentoTurma, predicate: NSPredicate(format: "id == %@", fechamentoTurma.id), unique: true)?.first {
            fechamentoTurmaSalva.aulasPlanejadas = fechamentoTurma.aulasPlanejadas
            fechamentoTurmaSalva.aulasRealizadas = fechamentoTurma.aulasRealizadas
            fechamentoTurmaSalva.justificativa = fechamentoTurma.justificativa
            fechamentoTurmaSalva.serie = fechamentoTurma.serie
            fechamentoTurmaSalva.bimestre = fechamentoTurma.bimestre
            fechamentoTurmaSalva.disciplina = fechamentoTurma.disciplina
            fechamentoTurmaSalva.tipoFechamento = fechamentoTurma.tipoFechamento
            fechamentoTurmaSalva.turma = fechamentoTurma.turma
            fechamentoTurmaSalva.dateServer = DateFormatter.dataDateFormatter.string(from: Date())
            return
        }
        let fechamentoTurmaSalva: FechamentoTurma = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.fechamentoTurma)
        fechamentoTurmaSalva.aulasPlanejadas = fechamentoTurma.aulasPlanejadas
        fechamentoTurmaSalva.aulasRealizadas = fechamentoTurma.aulasRealizadas
        fechamentoTurmaSalva.id = fechamentoTurma.id
        fechamentoTurmaSalva.justificativa = fechamentoTurma.justificativa
        fechamentoTurmaSalva.serie = fechamentoTurma.serie
        fechamentoTurmaSalva.bimestre = fechamentoTurma.bimestre
        fechamentoTurmaSalva.disciplina = fechamentoTurma.disciplina
        fechamentoTurmaSalva.tipoFechamento = fechamentoTurma.tipoFechamento
        fechamentoTurmaSalva.turma = fechamentoTurma.turma
        fechamentoTurmaSalva.dateServer = DateFormatter.dataDateFormatter.string(from: Date())
    }

    static func salvar(json: [String:Any], bimestre: Bimestre, disciplina: Disciplina, tipoFechamento: TipoFechamentoBimestre, turma: Turma) -> FechamentoTurma {
        if let aulasPlanejadas = json[CamposServidor.aulasPlanejadas] as? UInt32, let aulasRealizadas = json[CamposServidor.aulasRealizadas] as? UInt32, let serie = json[CamposServidor.numeroSerie] as? UInt16 {
            let id = "ID-" + String(bimestre.id) + "-" + String(disciplina.id) + "-" + String(serie) + "-" + String(tipoFechamento.codigo) + "-" + String(turma.id)
            if let fechamentoTurma: FechamentoTurma = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.fechamentoTurma, predicate: NSPredicate(format: "id == %@", id), unique: true)?.first {
                fechamentoTurma.aulasPlanejadas = aulasPlanejadas
                fechamentoTurma.aulasRealizadas = aulasRealizadas
                fechamentoTurma.serie = serie
                fechamentoTurma.bimestre = bimestre
                fechamentoTurma.disciplina = disciplina
                fechamentoTurma.tipoFechamento = tipoFechamento
                fechamentoTurma.turma = turma
                fechamentoTurma.dateServer = DateFormatter.dataDateFormatter.string(from: Date())
                if let justificativa = json[CamposServidor.justificativa] as? String {
                    fechamentoTurma.justificativa = justificativa
                }
                return fechamentoTurma
            }
            let fechamentoTurma: FechamentoTurma = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.fechamentoTurma)
            fechamentoTurma.aulasPlanejadas = aulasPlanejadas
            fechamentoTurma.aulasRealizadas = aulasRealizadas
            fechamentoTurma.id = id
            fechamentoTurma.serie = serie
            fechamentoTurma.bimestre = bimestre
            fechamentoTurma.disciplina = disciplina
            fechamentoTurma.tipoFechamento = tipoFechamento
            fechamentoTurma.turma = turma
            fechamentoTurma.dateServer = DateFormatter.dataDateFormatter.string(from: Date())
            if let justificativa = json[CamposServidor.justificativa] as? String {
                fechamentoTurma.justificativa = justificativa
            }
            return fechamentoTurma
        }
        return FechamentoTurma()
    }
    
    static func update(dateServer: String, id: String) {
        if let fechamentoTurma: FechamentoTurma = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.fechamentoTurma, predicate: NSPredicate(format: "id == %@", id))?.first {
            fechamentoTurma.dateServer = dateServer
        }
    }

    fileprivate static func filterWith(data: [FechamentoTurma], currentFilter: FilteredFechamentoCurrentToSync) -> [FechamentoTurma] {
        var result = [FechamentoTurma]()
        result = data.filter({ $0.bimestre.id == currentFilter.bimestreId && $0.turma.id == currentFilter.turmaId && $0.disciplina.id == currentFilter.disciplinaId && $0.serie == currentFilter.serie && $0.tipoFechamento.codigo == currentFilter.tipo })
        return result
    }
}
