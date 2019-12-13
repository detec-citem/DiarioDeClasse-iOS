//
//  SincronizarRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 07/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class SincronizarRequest {
    //MARK: Methods
    static func sincronizar(erroAvaliacao: @escaping () -> Void, erroFrequencias: @escaping () -> Void, erroRegistro: @escaping () -> Void, erroOffline: @escaping () -> Void, progressoAvaliacao: @escaping (Int, Int) -> Void, progressoFrequencia: @escaping (Int, Int) -> Void, progressoRegistro: @escaping (Int, Int) -> Void, progressoOffline: @escaping () -> Void, sucessoOffline: @escaping () -> Void, completion: @escaping (Bool, String?) -> Void) {
        var erro: String?
        var sucessoAvaliacao: Bool!
        let dispatchGroupSincronizar = DispatchGroup()
        var contextoAvaliacao: NSManagedObjectContext?
        var contextoDeletar: NSManagedObjectContext?
        var contextoFrequencias: NSManagedObjectContext?
        var contextoRegistrosAula: NSManagedObjectContext?
        dispatchGroupSincronizar.enter()
        SincronizarAvaliacaoRequest.sincronizarAvaliacao(erroAvaliacao: erroAvaliacao, progressoAvaliacao: progressoAvaliacao, completion: { (sucesso, error, contexto1, contexto2) in
                erro = error
                sucessoAvaliacao = sucesso
                contextoAvaliacao = contexto1
                contextoDeletar = contexto2
                dispatchGroupSincronizar.leave()
        })
        var sucessoFrequencias: Bool!
        dispatchGroupSincronizar.enter()
        SincronizarFrequenciasRequest.sincronizarFrequencias(erroFrequencias: erroFrequencias, progressoFrequencia: progressoFrequencia, completion: { sucesso, error, contexto  in
            erro = error
            sucessoFrequencias = sucesso
            contextoFrequencias = contexto
            dispatchGroupSincronizar.leave()
        })
        var sucessoRegistroAula: Bool!
        dispatchGroupSincronizar.enter()
        SincronizarRegistrosAulaRequest.sincronizarRegistrosAula(erroRegistro: erroRegistro, progressoRegistro: progressoRegistro, completion: { sucesso, error, contexto in
            erro = error
            sucessoRegistroAula = sucesso
            contextoRegistrosAula = contexto
            dispatchGroupSincronizar.leave()
        })
        dispatchGroupSincronizar.notify(queue: .main) {
            let dispatchGroup = DispatchGroup()
            if sucessoAvaliacao {
                
                if let contextoAvaliacao = contextoAvaliacao {
                    dispatchGroup.enter()
                    contextoAvaliacao.perform {
                        do {
                            try contextoAvaliacao.save()
                        }
                        catch {
                        }
                        dispatchGroup.leave()
                    }
                }
                if let contextoDeletar = contextoDeletar {
                    dispatchGroup.enter()
                    contextoDeletar.perform {
                        do {
                            try contextoDeletar.save()
                        }
                        catch {
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            else {
                if let contextoAvaliacao = contextoAvaliacao {
                    dispatchGroup.enter()
                    contextoAvaliacao.perform {
                        contextoAvaliacao.rollback()
                        contextoAvaliacao.reset()
                        dispatchGroup.leave()
                    }
                }
                if let contextoDeletar = contextoDeletar {
                    dispatchGroup.enter()
                    contextoDeletar.perform {
                        contextoDeletar.rollback()
                        contextoDeletar.reset()
                        dispatchGroup.leave()
                    }
                }
            }
            if sucessoFrequencias {
                if let contextoFrequencias = contextoFrequencias {
                    dispatchGroup.enter()
                    contextoFrequencias.perform {
                        do {
                            try contextoFrequencias.save()
                        }
                        catch {
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            else if let contextoFrequencias = contextoFrequencias {
                dispatchGroup.enter()
                contextoFrequencias.perform {
                    contextoFrequencias.rollback()
                    contextoFrequencias.reset()
                    dispatchGroup.leave()
                }
            }
            if sucessoRegistroAula {
                if let contextoRegistrosAula = contextoRegistrosAula {
                    dispatchGroup.enter()
                    contextoRegistrosAula.perform {
                        do {
                            try contextoRegistrosAula.save()
                        }
                        catch {
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            else if let contextoRegistrosAula = contextoRegistrosAula {
                dispatchGroup.enter()
                contextoRegistrosAula.perform {
                    contextoRegistrosAula.rollback()
                    contextoRegistrosAula.reset()
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                if sucessoAvaliacao || sucessoFrequencias || sucessoRegistroAula {
                    CoreDataManager.sharedInstance.salvarBanco()
                    progressoOffline()
                    BuscarTurmasRequest.buscarTurmas(primeiraVez: false, completion: { (sucesso, erro) in
                        if sucesso {
                            sucessoOffline()
                            completion(true, nil)
                        }
                        else {
                            erroOffline()
                            completion(false, erro)
                        }
                    })
                }
                else {
                    CoreDataManager.sharedInstance.rollback()
                    CoreDataManager.sharedInstance.resetarContexto()
                    completion(false, erro)
                }
            }
        }
    }
}
