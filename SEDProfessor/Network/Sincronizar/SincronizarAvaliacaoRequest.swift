//
//  SincronizarAvaliacaoRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 07/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class SincronizarAvaliacaoRequest {
    //MARK: Constants
    fileprivate struct Constants {
        static let excluirAvaliacaoApi = "AvaliacaoNova/Excluir"
        static let salvarAvaliacaoApi = "AvaliacaoNova/Salvar"
    }
    
    //MARK: Methods
    static func sincronizarAvaliacao(erroAvaliacao: @escaping () -> Void, progressoAvaliacao: @escaping (Int,Int) -> Void, completion: @escaping (Bool, String?, NSManagedObjectContext?, NSManagedObjectContext?) -> Void) {
        var avaliacoesEnviadas = 0
        var erro: Error?
        let usuarioLogado = LoginRequest.usuarioLogado!
        let usuario = usuarioLogado.usuario
        let senha = usuarioLogado.senha
        var contextoDeletar: NSManagedObjectContext?
        var codigosAvaliacoesDeletadas = Set<Int32>()
        let dispatchGroupRequisicoes = DispatchGroup()
        let numeroAvaliacoesParaDeletar = AvaliacaoDao.numeroAvaliacoesParaDeletar()
        let numeroAvaliacoesParaEnviar = AvaliacaoDao.numeroAvaliacoesParaSincronizar()
        let totalAvaliacoes = numeroAvaliacoesParaDeletar + numeroAvaliacoesParaEnviar
        progressoAvaliacao(.zero, totalAvaliacoes)
        if numeroAvaliacoesParaDeletar > .zero {
            contextoDeletar = CoreDataManager.sharedInstance.criarContexto()
            dispatchGroupRequisicoes.enter()
            contextoDeletar?.perform {
                if let avaliacoesParaDeletar = AvaliacaoDao.avaliacoesParaDeletar(contexto: contextoDeletar!), !avaliacoesParaDeletar.isEmpty {
                    let dispatchGroupDeletar = DispatchGroup()
                    codigosAvaliacoesDeletadas.reserveCapacity(avaliacoesParaDeletar.count)
                    for avaliacao in avaliacoesParaDeletar {
                        let codigoAvaliacao = avaliacao.id
                        if Requests.Configuracoes.servidorHabilitado && (usuario != Requests.Configuracoes.LoginTeste.usuario && senha.base64Decoded != Requests.Configuracoes.LoginTeste.senha) {
                            var request = URLRequest(url: URL(string: Requests.Configuracoes.urlServidor + Constants.excluirAvaliacaoApi)!)
                            do {
                                request.httpBody = try JSONSerialization.data(withJSONObject: [AvaliacaoDao.CamposServidor.id:codigoAvaliacao])
                                dispatchGroupDeletar.enter()
                                Requests.requestData(requisicao: request, metodoHttp: .post) { (_, error, statusCode) in
                                    if erro == nil {
                                        if error != nil {
                                            erro = error
                                            DispatchQueue.main.async {
                                                erroAvaliacao()
                                            }
                                            dispatchGroupDeletar.leave()
                                        }
                                        else {
                                            DispatchQueue.main.async {
                                                avaliacoesEnviadas += 1
                                                codigosAvaliacoesDeletadas.insert(codigoAvaliacao)
                                                progressoAvaliacao(avaliacoesEnviadas, totalAvaliacoes)
                                                dispatchGroupDeletar.leave()
                                            }
                                        }
                                    }
                                    else {
                                        dispatchGroupDeletar.leave()
                                    }
                                }
                            }
                            catch {
                                erro = error
                            }
                        }
                        else {
                            codigosAvaliacoesDeletadas.insert(codigoAvaliacao)
                        }
                    }
                    dispatchGroupDeletar.notify(queue: .main) {
                        dispatchGroupRequisicoes.leave()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        dispatchGroupRequisicoes.leave()
                    }
                }
            }
        }
        var contextoAvaliacoes: NSManagedObjectContext?
        if numeroAvaliacoesParaEnviar > .zero {
            contextoAvaliacoes = CoreDataManager.sharedInstance.criarContexto()
            dispatchGroupRequisicoes.enter()
            contextoAvaliacoes?.perform {
                if let avaliacoesNaoSincronizadas = AvaliacaoDao.avaliacoesNaoSincronizadas(contexto: contextoAvaliacoes!), !avaliacoesNaoSincronizadas.isEmpty {
                    let dispatchGroupSincronizar = DispatchGroup()
                    for avaliacao in avaliacoesNaoSincronizadas {
                        if Requests.Configuracoes.servidorHabilitado && (usuario != Requests.Configuracoes.LoginTeste.usuario && senha.base64Decoded != Requests.Configuracoes.LoginTeste.senha) {
                            var notas = [[String:Any]]()
                            if let notasAluno = avaliacao.notasAluno as? Set<NotaAluno> {
                                notas.reserveCapacity(notasAluno.count)
                                for notaAluno in notasAluno {
                                    notas.append([AvaliacaoDao.CamposServidor.nota:notaAluno.nota, AvaliacaoDao.CamposServidor.codigoMatriculaAluno:notaAluno.aluno.codigoMatricula])
                                }
                            }
                            var json: [String:Any] = [AvaliacaoDao.CamposServidor.codigoTurma:avaliacao.turma.id,AvaliacaoDao.CamposServidor.codigoDisciplina:avaliacao.disciplina.id,AvaliacaoDao.CamposServidor.codigoTipoAtividade:avaliacao.codigoTipoAtividade,AvaliacaoDao.CamposServidor.mobileId:avaliacao.mobileId,AvaliacaoDao.CamposServidor.nome:avaliacao.nome,AvaliacaoDao.CamposServidor.data:avaliacao.dataCadastro,AvaliacaoDao.CamposServidor.bimestre:avaliacao.bimestre.id,AvaliacaoDao.CamposServidor.valeNota:avaliacao.valeNota,AvaliacaoDao.CamposServidor.notas:notas]
                            let codigoAvaliacao = avaliacao.id
                            if codigoAvaliacao != -1 {
                                json[AvaliacaoDao.CamposServidor.id] = codigoAvaliacao
                            }
                            var request = URLRequest(url: URL(string: Requests.Configuracoes.urlServidor + Constants.salvarAvaliacaoApi)!)
                            do {
                                request.httpBody = try JSONSerialization.data(withJSONObject: json)
                                dispatchGroupSincronizar.enter()
                                Requests.requestData(requisicao: request, metodoHttp: .post, completion: { data, error, _ in
                                    if erro == nil {
                                        if error != nil {
                                            erro = error
                                            DispatchQueue.main.async {
                                                erroAvaliacao()
                                            }
                                            dispatchGroupSincronizar.leave()
                                        }
                                        else {
                                            do {
                                                if let data = data as? Data, let json = try JSONSerialization.jsonObject(with: data) as? [String:Any], let codigoAvaliacao = json[AvaliacaoDao.CamposServidor.id] as? Int32, let mobileId = json[AvaliacaoDao.CamposServidor.mobileId] as? Int32 {
                                                    contextoAvaliacoes?.perform {
                                                        avaliacao.id = codigoAvaliacao
                                                        avaliacao.mobileId = mobileId
                                                        DispatchQueue.main.async {
                                                            avaliacoesEnviadas += 1
                                                            progressoAvaliacao(avaliacoesEnviadas, totalAvaliacoes)
                                                        }
                                                        dispatchGroupSincronizar.leave()
                                                    }
                                                }
                                            }
                                            catch {
                                                erro = error
                                                dispatchGroupSincronizar.leave()
                                            }
                                        }
                                    }
                                    else {
                                        dispatchGroupSincronizar.leave()
                                    }
                                })
                            }
                            catch {
                                erro = error
                            }
                        }
                    }
                    dispatchGroupSincronizar.notify(queue: .main) {
                        if erro == nil {
                            contextoAvaliacoes?.perform {
                                let hoje = DateFormatter.dataDateFormatter.string(from: Date())
                                for avaliacao in avaliacoesNaoSincronizadas {
                                    avaliacao.dataServidor = hoje
                                }
                                dispatchGroupRequisicoes.leave()
                            }
                        }
                        else {
                            dispatchGroupRequisicoes.leave()
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        dispatchGroupRequisicoes.leave()
                    }
                }
            }
        }
        dispatchGroupRequisicoes.notify(queue: .main) {
            if erro != nil {
                completion(false, Requests.getMensagemErro(error: erro), contextoAvaliacoes, contextoDeletar)
            }
            else if codigosAvaliacoesDeletadas.isEmpty {
                completion(true, nil, contextoAvaliacoes, contextoDeletar)
            }
            else {
                let dispatchGroupSalvar = DispatchGroup()
                if let contextoAvaliacoes = contextoAvaliacoes {
                    dispatchGroupSalvar.enter()
                    contextoAvaliacoes.perform {
                        NotaAlunoDao.removerNotasDasAvaliacoes(codigosAvaliacoesDeletadas: codigosAvaliacoesDeletadas)
                        dispatchGroupSalvar.leave()
                    }
                }
                if let contextoDeletar = contextoDeletar {
                    dispatchGroupSalvar.enter()
                    contextoDeletar.perform {
                        AvaliacaoDao.removerAvaliacoes(contextoDeletar: contextoDeletar, codigosAvaliacoesDeletadas: codigosAvaliacoesDeletadas)
                        dispatchGroupSalvar.leave()
                    }
                }
                dispatchGroupSalvar.notify(queue: .main) {
                    completion(true, nil, contextoAvaliacoes, contextoDeletar)
                }
            }
        }
    }
}
