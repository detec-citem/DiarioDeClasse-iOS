//
//  DiaFrequenciaModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 20/02/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class DiaFrequenciaDao {
    //MARK: Methods
    static func removerDiasFrequencia() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.diaFrequencia)
    }
    
    static func salvar(dataString: String, frequencia: Frequencia) -> DiaFrequencia {
        if let data = DateFormatter.dataDateFormatter.date(from: dataString) {
            let diaFrequencia: DiaFrequencia = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.diaFrequencia)
            diaFrequencia.data = data
            diaFrequencia.frequencia = frequencia
            return diaFrequencia
        }
        return DiaFrequencia()
    }
}
