//
//  DiaLetivoModel.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/08/16.
//  Copyright © 2016 prodesp. All rights reserved.
//

import Foundation

final class DiaLetivoDao {
    //MARK: Methods
    static func diaLetivoNaData(data: String) -> DiaLetivo? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.diaLetivo, predicate: NSPredicate(format: "dataAula == %@", data))?.first
    }
    
    static func diaLetivosDaTurmaNoBimestre(codigoBimestre: UInt32, turma: Turma) -> [DiaLetivo]? {
        return CoreDataManager.sharedInstance.buscarDados(tabela: Tabelas.diaLetivo, predicate: NSPredicate(format: "bimestre.id == %d AND turma.id == %d", codigoBimestre, turma.id))
    }
    
    static func removerDiasLetivos() {
        CoreDataManager.sharedInstance.deletarDados(tabela: Tabelas.diaLetivo)
    }

    static func salvar(id: String, data: String, bimestre: Bimestre, turma: Turma) {
        let diaLetivo: DiaLetivo = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.diaLetivo)
        diaLetivo.id = id
        diaLetivo.dataAula = data
        diaLetivo.bimestre = bimestre
        diaLetivo.turma = turma
    }
}
