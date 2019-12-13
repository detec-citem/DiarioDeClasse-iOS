//
//  TipoFechamentoBimestreModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 15/08/2018.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import Foundation

final class TipoFechamentoBimestreDao {
    //MARK: Constants
    fileprivate struct CamposServidor {
        static let ano = "Ano"
        static let codigo = "CodigoTipoFechamento"
        static let inicio = "Inicio"
        static let fim = "Fim"
        static let nome = "Nome"
    }

    //MARK: Methods
    static func getFechamentoAtual() -> TipoFechamentoBimestre? {
        if let fechamentos: [TipoFechamentoBimestre] = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.tipoFechamentoBimestre, sortBy: "id") {
            let hoje = Date().comecoDoDia()
            for fechamento in fechamentos {
                let dataFim = fechamento.fim.comecoDoDia()
                let dataInicio = fechamento.inicio.comecoDoDia()
                if dataInicio <= hoje && dataFim >= hoje {
                    return fechamento
                }
            }
        }
        return nil
    }
    
    static func removerTiposFechamento() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.tipoFechamentoBimestre)
    }
    
    static func salvar(json: [String:Any]) -> TipoFechamentoBimestre {
        if let ano = json[CamposServidor.ano] as? UInt16, let codigo = json[CamposServidor.codigo] as? UInt32, let inicio = json[CamposServidor.inicio] as? String, let fim = json[CamposServidor.fim] as? String, let nome = json[CamposServidor.nome] as? String, let dataInicio = DateFormatter.dataDateFormatter.date(from: inicio), let dataFim = DateFormatter.dataDateFormatter.date(from: fim) {
            var uniqueId: UInt32 = 1
            if let tipoFechamentos: [TipoFechamentoBimestre] = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.tipoFechamentoBimestre), !tipoFechamentos.isEmpty {
                var tipoFechamentosBimestre = [[String:Any]]()
                for tipoFechamento in tipoFechamentos {
                    var result = [String: Any]()
                    result[CamposServidor.ano] = tipoFechamento.ano
                    result["id"] = tipoFechamento.id
                    result[CamposServidor.codigo] = tipoFechamento.codigo
                    result[CamposServidor.fim] = tipoFechamento.fim
                    result[CamposServidor.inicio] = tipoFechamento.inicio
                    result[CamposServidor.nome] = tipoFechamento.nome
                    tipoFechamentosBimestre.append(result)
                }
                uniqueId = Int.generateUniqueId(data: tipoFechamentosBimestre, key: "id", initialNumber: 1)
            }
            let tipoFechamento: TipoFechamentoBimestre = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.tipoFechamentoBimestre)
            tipoFechamento.ano = ano
            tipoFechamento.codigo = codigo
            tipoFechamento.fim = dataFim
            tipoFechamento.id = uniqueId
            tipoFechamento.inicio = dataInicio
            tipoFechamento.nome = nome
            return tipoFechamento
        }
        return TipoFechamentoBimestre()
    }
}
