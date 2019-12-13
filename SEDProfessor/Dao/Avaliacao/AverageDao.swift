//
//  AverageDao.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 18/01/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//
//

import Foundation

final class AverageDao {
    //MARK: Methods
    static func averageComId(id: String) -> Average? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.average, predicate: NSPredicate(format: "id == %@", id), unique: true)?.first
    }
    
    static func salvar(average: Average) {
        
        if let objects: [Average] = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.average, predicate: NSPredicate(format: "id == %@", average.id), unique: true), !objects.isEmpty {
            for entity in objects {
                entity.initialValue = average.initialValue
                entity.numberEvaluations = average.numberEvaluations
                entity.selectedType = average.selectedType
                entity.student = average.student
                entity.value = average.value
            }
            return
        }
        let entity: Average = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.average)
        entity.id = average.id
        entity.initialValue = average.initialValue
        entity.numberEvaluations = average.numberEvaluations
        entity.selectedType = average.selectedType
        entity.student = average.student
        entity.value = average.value
    }

    struct AverageTypeModel {
        var id: TypeId?
        var name: TypeName?
        init(id: TypeId, name: TypeName) {
            self.id = id
            self.name = name
        }

        static func getData() -> [AverageTypeModel] {
            return [AverageTypeModel(id: .arithmetic, name: .arithmetic), AverageTypeModel(id: .weighted, name: .weighted), AverageTypeModel(id: .sum, name: .sum)]
        }

        final class WeightedModel {
            var id: Int32? // Set the evaluation id
            var weight: Int?
            var evaluation: Avaliacao?
            
            init() {
            }
            
            init(weight: Int, evaluation: Avaliacao) {
                self.id = evaluation.id
                self.weight = weight
                self.evaluation = evaluation
            }

            fileprivate init(id: Int32?, weight: Int?) {
                guard let id = id else {
                    return
                }
                self.id = id
                self.weight = weight
            }


            class func save(model: WeightedModel) {
                if let id = model.id, let evaluationId = model.evaluation?.id, let weight = model.weight {
                    let json = "{\"id\":" + String(evaluationId) + ",\"weight\":" + String(weight) + "}"
                    let key = String(id)
                    UserDefaults.standard.removeObject(forKey: key)
                    UserDefaults.standard.set(json, forKey: key)
                    UserDefaults.standard.synchronize()
                }
            }

            class func getData(fromEvaluationModel: Avaliacao? = nil, fromEvaluation: Avaliacao? = nil) -> WeightedModel? {
                guard let id = fromEvaluationModel?.id else { return nil }
                if let stringJson = UserDefaults.standard.string(forKey: String(id)), let jsonData = stringJson.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String:Any] {
                    let model = WeightedModel()
                    model.id = json["id"] as? Int32
                    model.weight = json["weight"] as? Int
                    if let evaluationModel = fromEvaluationModel {
                        model.evaluation = evaluationModel
                    }
                    else if let evaluation = fromEvaluation {
                        model.evaluation = AvaliacaoDao.avaliacaoComId(id: evaluation.id)
                    }
                    else {
                        return nil
                    }
                    return model
                }
                return nil
            }
        }
    }
}
