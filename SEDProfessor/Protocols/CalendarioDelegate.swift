//
//  CalendarioDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 02/10/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

protocol CalendarioDelegate: class {
    func cancelouSelecao()
    func podeSelecionar(diaLetivo: DiaLetivo) -> Bool
    func selecionouDiaLetivo(data: Date, diaLetivo: DiaLetivo)
    func temLancamentoNaData(data: Date) -> Bool
}
