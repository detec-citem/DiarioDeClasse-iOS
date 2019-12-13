//
//  SincronizarRegistrosAulaRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 07/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class SincronizarRegistrosAulaRequest {
    //MARK: Constants
    fileprivate struct Constants {
        static let codigoDisciplina = "CodigoDisciplina"
        static let conteudos = "Conteudos"
        static let ocorrencias = "Ocorrencias"
        static let salvarRegistrosAulaApi = "RegistroAula"
    }
    
    //MARK: Methods
    static func sincronizarRegistrosAula(erroRegistro: @escaping () -> Void, progressoRegistro: @escaping (Int, Int) -> Void, completion: @escaping (Bool, String?, NSManagedObjectContext?) -> Void) {
        var registrosEnviados = 0
        var erro: Error? = nil
        let usuarioLogado = LoginRequest.usuarioLogado!
        let usuario = usuarioLogado.usuario
        let senha = usuarioLogado.senha
        var contextoRegistros: NSManagedObjectContext?
        let dispatchGroup = DispatchGroup()
        let totalRegistros = RegistroAulaDao.numeroRegistrosNaoSincronizados()
        progressoRegistro(.zero, totalRegistros)
        if totalRegistros > .zero {
            contextoRegistros = CoreDataManager.sharedInstance.criarContexto()
            contextoRegistros?.perform {
                if let contextoRegistros = contextoRegistros, let registrosNaoSincronizados = RegistroAulaDao.acessarRegistrosNaoSincronizados(contexto: contextoRegistros), !registrosNaoSincronizados.isEmpty {
                    for registroAula in registrosNaoSincronizados {
                        if Requests.Configuracoes.servidorHabilitado && (usuario != Requests.Configuracoes.LoginTeste.usuario && senha.base64Decoded != Requests.Configuracoes.LoginTeste.senha) {
                            let grupo = registroAula.grupo
                            var registroAulaJson: [String:Any] = [RegistroAulaDao.CamposServidor.bimestre:registroAula.bimestre.id,Constants.codigoDisciplina:grupo.disciplina.id,RegistroAulaDao.CamposServidor.codigoGrupoCurriculo:grupo.id,RegistroAulaDao.CamposServidor.codigoTurma:registroAula.turma.id,RegistroAulaDao.CamposServidor.observacoes:registroAula.observacoes,Constants.ocorrencias:""]
                            if let dataCriacao = registroAula.dataCriacao {
                                registroAulaJson[RegistroAulaDao.CamposServidor.dataCriacao] = dataCriacao
                            }
                            var horariosJson = [String]()
                            let horarios = registroAula.horarios as! Set<Aula>
                            for horario in horarios {
                                horariosJson.append(horario.inicioHora + " ás " + horario.fimHora)
                            }
                            registroAulaJson[RegistroAulaDao.CamposServidor.horarios] = horariosJson
                            var habilidadesConteudos = [UInt32:[UInt32]]()
                            let habilidadesRegistroAula = registroAula.habilidadesRegistroAula as! Set<HabilidadeRegistroAula>
                            for habilidadeRegistroAula in habilidadesRegistroAula {
                                var habilidadesConteudo: [UInt32]!
                                let habilidade = habilidadeRegistroAula.habilidade
                                let conteudoId = habilidade.conteudo.id
                                if !habilidadesConteudos.keys.contains(conteudoId) {
                                    habilidadesConteudo = [UInt32]()
                                }
                                else {
                                    habilidadesConteudo = habilidadesConteudos[conteudoId]
                                }
                                habilidadesConteudo.append(habilidade.id)
                                habilidadesConteudos[conteudoId] = habilidadesConteudo
                            }
                            var conteudosJson = [[String:Any]]()
                            let conteudoIds = habilidadesConteudos.keys
                            for conteudoId in conteudoIds {
                                conteudosJson.append([RegistroAulaDao.CamposServidor.codigoConteudo:conteudoId,RegistroAulaDao.CamposServidor.habilidades:habilidadesConteudos[conteudoId]!])
                            }
                            registroAulaJson[Constants.conteudos] = conteudosJson
                            var request = URLRequest(url: URL(string:Requests.Configuracoes.urlServidor + Constants.salvarRegistrosAulaApi)!)
                            do {
                                request.httpBody = try JSONSerialization.data(withJSONObject: registroAulaJson)
                                dispatchGroup.enter()
                                Requests.requestData(requisicao: request, metodoHttp: .post, completion: { data, error, _ in
                                    if erro == nil && error == nil, let data = data as? Data {
                                        do {
                                            if let responseJson = try JSONSerialization.jsonObject(with: data) as? [String:Any], let codigo = responseJson[RegistroAulaDao.CamposServidor.codigo] as? Int32 {
                                                contextoRegistros.perform {
                                                    registroAula.enviado = true
                                                    registroAula.id = codigo
                                                    DispatchQueue.main.async {
                                                        registrosEnviados += 1
                                                        progressoRegistro(registrosEnviados, totalRegistros)
                                                    }
                                                    dispatchGroup.leave()
                                                }
                                            }
                                        }
                                        catch {
                                            erro = error
                                            DispatchQueue.main.async {
                                                erroRegistro()
                                            }
                                            dispatchGroup.leave()
                                        }
                                    }
                                    else {
                                        erro = error
                                        DispatchQueue.main.async {
                                            erroRegistro()
                                        }
                                        dispatchGroup.leave()
                                    }
                                })
                            }
                            catch {
                                erro = error
                                DispatchQueue.main.async {
                                    erroRegistro()
                                }
                            }
                        }
                        else {
                            registroAula.enviado = true
                        }
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(erro == nil, Requests.getMensagemErro(error: erro), contextoRegistros)
        }
    }
}
