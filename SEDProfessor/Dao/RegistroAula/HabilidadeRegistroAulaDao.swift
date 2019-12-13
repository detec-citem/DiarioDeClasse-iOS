//
//  HabilidadeRegistroAulaDao.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 23/10/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class HabilidadeRegistroAulaDao {
    //MARK: Methods
    static func salvar(selecionada: Bool, habilidade: Habilidade, registroAula: RegistroAula) -> HabilidadeRegistroAula {
        if let habilidadeRegistroAula: HabilidadeRegistroAula = CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.habilidadeRegistroAula, predicate: NSPredicate(format: "habilidade.id == %d AND registroAula.id == %d", habilidade.id, registroAula.id), unique: true)?.first {
            habilidadeRegistroAula.selecionada = selecionada
            return habilidadeRegistroAula
        }
        let habilidadeRegistroAula: HabilidadeRegistroAula = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.habilidadeRegistroAula)
        habilidadeRegistroAula.selecionada = selecionada
        habilidadeRegistroAula.habilidade = habilidade
        habilidadeRegistroAula.registroAula = registroAula
        return habilidadeRegistroAula
    }
    
    static func remover(registroAula: RegistroAula, habilidades: [Habilidade]) {
        var habilidadesIds = [UInt32]()
        habilidadesIds.reserveCapacity(habilidades.count)
        for habilidade in habilidades {
            habilidadesIds.append(habilidade.id)
        }
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.habilidadeRegistroAula, predicate: NSPredicate(format: "registroAula.id == %d AND NOT (habilidade.id IN %@)", registroAula.id, habilidadesIds))
    }
}
