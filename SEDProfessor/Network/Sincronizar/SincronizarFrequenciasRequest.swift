//
//  SincronizarFrequenciasRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 07/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import CoreData
import Foundation

final class SincronizarFrequenciasRequest {
    //MARK: Constants
    fileprivate struct Constants {
        static let diasComConflito = "DiasComConflito"
        static let parametroCodigoAula = "CodigoDaAula"
        static let parametroDia = "Dia"
        static let parametroDias = "Dias"
        static let parametroFrequencias = "Frequencias"
        static let parametroHorarios = "Horarios"
        static let parametroHorarioInicioAula = "HorarioInicioAula"
        static let parametroHorarioFimAula = "HorarioFimAula"
        static let salvarFrequenciasApi = "Frequencia/NovaFrequencia"
        static let separador = "-"
        static let statusCode = "Status"
        static let statusCodeConflito = 409
    }
    
    //MARK: Methods
    static func sincronizarFrequencias(erroFrequencias: @escaping () -> Void, progressoFrequencia: @escaping (Int, Int) -> Void, completion: @escaping (Bool, String?, NSManagedObjectContext?) -> Void) {
        var faltasEnviadas = 0
        let usuarioLogado = LoginRequest.usuarioLogado!
        let usuario = usuarioLogado.usuario
        let senha = usuarioLogado.senha
        var contextoFrequencias: NSManagedObjectContext?
        let totalFaltas = FaltaAlunoDao.numeroFrequenciasNaoSincronizadas()
        progressoFrequencia(.zero, totalFaltas)
        if totalFaltas > .zero {
            contextoFrequencias = CoreDataManager.sharedInstance.criarContexto()
            contextoFrequencias?.perform {
                if let contextoFrequencias = contextoFrequencias, let faltasParaSincronizar = FaltaAlunoDao.frequenciasNaoSincronizadas(contexto: contextoFrequencias), !faltasParaSincronizar.isEmpty {
                    var disciplinas = [UInt32:Disciplina]()
                    var turmas = [UInt32:Turma]()
                    var faltasDiasHorarios = [String:[String:[FaltaAluno]]]()
                    var faltasTurmas = [String:[String:[String:[FaltaAluno]]]]()
                    for falta in faltasParaSincronizar {
                        let turma = falta.turma
                        let turmaId = turma.id
                        turmas[turmaId] = turma
                        let aula = falta.aula
                        let disciplina = aula.disciplina
                        let disciplinaId = disciplina.id
                        disciplinas[disciplinaId] = disciplina
                        let chave = String(turmaId) + Constants.separador + String(disciplinaId)
                        if !faltasTurmas.keys.contains(chave) {
                            faltasTurmas[chave] = [String:[String:[FaltaAluno]]]()
                        }
                        let dia = falta.diaLetivo.dataAula
                        if !faltasDiasHorarios.keys.contains(dia) {
                            faltasDiasHorarios[dia] = [String:[FaltaAluno]]()
                        }
                        if let dias = faltasTurmas[chave]?.keys, !dias.contains(dia) {
                            faltasTurmas[chave]?[dia] = [String:[FaltaAluno]]()
                        }
                        let inicio = aula.inicioHora
                        let fim = aula.fimHora
                        let horario = inicio + Constants.separador + fim
                        if let horarios = faltasDiasHorarios[dia]?.keys, !horarios.contains(horario) {
                            faltasDiasHorarios[dia]?[horario] = [FaltaAluno]()
                        }
                        if let horarios = faltasTurmas[chave]?[dia]?.keys, !horarios.contains(horario) {
                            faltasTurmas[chave]?[dia]?[horario] = [FaltaAluno]()
                        }
                        faltasDiasHorarios[dia]?[horario]?.append(falta)
                        faltasTurmas[chave]?[dia]?[horario]?.append(falta)
                    }
                    var frequenciasSalvas: Int!
                    var erro: Error?
                    let offline = Requests.Configuracoes.servidorHabilitado && (usuario == Requests.Configuracoes.LoginTeste.usuario && senha.base64Decoded == Requests.Configuracoes.LoginTeste.senha)
                    let codigosTurmasDisciplinas = faltasTurmas.keys
                    let dispatchGroup = DispatchGroup()
                    let url = URL(string: Requests.Configuracoes.urlServidor + Constants.salvarFrequenciasApi)!
                    var request = URLRequest(url: url)
                    if offline {
                        frequenciasSalvas = 1
                    }
                    else {
                        frequenciasSalvas = .zero
                    }
                    for codigoTurmaDisciplina in codigosTurmasDisciplinas {
                        var disciplina: Disciplina!
                        var turma: Turma!
                        var turmaDisciplinaJson: [String:Any]!
                        var faltasDaTurma = [FaltaAluno]()
                        let codigos = codigoTurmaDisciplina.components(separatedBy: Constants.separador)
                        if let codigoTurma = codigos.first, let codigoDisciplina = codigos.last, let codigoTurmaInt = UInt32(codigoTurma), let codigoDisciplinaInt = UInt32(codigoDisciplina), let faltasDias = faltasTurmas[codigoTurmaDisciplina] {
                            disciplina = disciplinas[codigoDisciplinaInt]
                            turma = turmas[codigoTurmaInt]
                            let dias = faltasDias.keys
                            var diasJson = [[String:Any]]()
                            diasJson.reserveCapacity(dias.count)
                            for dia in dias {
                                var horariosJson = [[String:Any]]()
                                if let faltasHorarios = faltasDias[dia] {
                                    let horarios = faltasHorarios.keys
                                    horariosJson.reserveCapacity(horarios.count)
                                    for horario in horarios {
                                        var horarioJson: [String:Any]!
                                        let componentes = horario.components(separatedBy: Constants.separador)
                                        if let inicio = componentes.first, let fim = componentes.last {
                                            var faltasJson = [[String:Any]]()
                                            if let faltas = faltasHorarios[horario] {
                                                faltasJson.reserveCapacity(faltas.count)
                                                faltasDaTurma.append(contentsOf: faltas)
                                                for falta in faltas {
                                                    if offline {
                                                        DiaConflitoDao.removerDiasConflito(disciplina: disciplina, turma: turma, contexto: contextoFrequencias)
                                                        let hoje = DateFormatter.dataDateFormatter.string(from: Date())
                                                        for falta in faltas {
                                                            falta.dataServidor = hoje
                                                        }
                                                    }
                                                    else {
                                                        let faltaJson: [String:Any] = [FaltaAlunoDao.CamposServidor.codigoMotivo:0,FaltaAlunoDao.CamposServidor.justificativa:"",Constants.parametroCodigoAula:0,FaltaAlunoDao.CamposServidor.codigoTipo:falta.tipo,DisciplinaDao.CamposServidor.id:codigoDisciplinaInt,TurmaDao.CamposServidor.id:codigoTurmaInt,FaltaAlunoDao.CamposServidor.matricula:falta.aluno.codigoMatricula,FaltaAlunoDao.CamposServidor.dataAula:dia,FaltaAlunoDao.CamposServidor.presenca:falta.presenca,Constants.parametroHorarioFimAula:fim,Constants.parametroHorarioInicioAula:inicio]
                                                        faltasJson.append(faltaJson)
                                                    }
                                                }
                                            }
                                            if !offline {
                                                horarioJson = [AulaDao.CamposServidor.inicio:inicio,AulaDao.CamposServidor.fim:fim,Constants.parametroFrequencias:faltasJson]
                                            }
                                        }
                                        if !offline {
                                            horariosJson.append(horarioJson)
                                        }
                                    }
                                }
                                if !offline {
                                    let diaJson: [String:Any] = [Constants.parametroDia:dia,Constants.parametroHorarios:horariosJson]
                                    diasJson.append(diaJson)
                                }
                            }
                            if !offline {
                                turmaDisciplinaJson = [DisciplinaDao.CamposServidor.id:codigoDisciplinaInt,TurmaDao.CamposServidor.id:codigoTurmaInt,Constants.parametroDias:diasJson]
                            }
                        }
                        if !offline {
                            do {
                                request.httpBody = try JSONSerialization.data(withJSONObject: turmaDisciplinaJson as Any)
                                dispatchGroup.enter()
                                Requests.requestData(requisicao: request, metodoHttp: .post, completion: { data, error, _ in
                                    if error != nil {
                                        if erro == nil {
                                            erro = error
                                        }
                                    }
                                    else if let data = data as? Data, let json = Requests.parseJson(data: data) as? [String:Any], let statusCode = json[Constants.statusCode] as? Int, statusCode == Constants.statusCodeConflito, let diasConflitoJson = json[Constants.diasComConflito] as? [[String:Any]] {
                                        contextoFrequencias.perform {
                                            frequenciasSalvas += 1
                                            var diasConflitoSalvos = [String]()
                                            for diaConflitoJson in diasConflitoJson {
                                                if let dia = diaConflitoJson[DiaConflitoDao.CamposServidor.dia] as? String, let horariosConflitoJson = diaConflitoJson[DiaConflitoDao.CamposServidor.horariosComConflito] as? [[String:Any]] {
                                                    let diaConflito = DiaConflitoDao.salvar(dia: dia, disciplina: disciplina, turma: turma, contexto: contextoFrequencias)
                                                    var horariosConflitoSalvos = [String]()
                                                    horariosConflitoSalvos.reserveCapacity(horariosConflitoJson.count)
                                                    for horarioConflitoJson in horariosConflitoJson {
                                                        let horarioConflito = HorarioConflitoDao.salvar(horarioJson: horarioConflitoJson, diaConflito: diaConflito, contexto: contextoFrequencias)
                                                        horariosConflitoSalvos.append(horarioConflito.horario)
                                                    }
                                                    diasConflitoSalvos.append(dia)
                                                    HorarioConflitoDao.removerHorariosConflito(diaConflito: diaConflito, horariosConflitoSalvos: horariosConflitoSalvos, contexto: contextoFrequencias)
                                                }
                                            }
                                            if let diasConflitoParaDeletar = DiaConflitoDao.diasConflitoParaDeletar(diasConflitoSalvos: diasConflitoSalvos, disciplina: disciplina, turma: turma, contexto: contextoFrequencias) {
                                                let hoje = DateFormatter.dataDateFormatter.string(from: Date())
                                                for diaConflito in diasConflitoParaDeletar {
                                                    if let horariosConflito = diaConflito.horarios as? Set<HorarioConflito> {
                                                        HorarioConflitoDao.removerHorariosConflito(horariosConflito: horariosConflito, contexto: contextoFrequencias)
                                                    }
                                                    let dia = diaConflito.dia
                                                    DiaConflitoDao.removerDiaConflito(diaConflito: diaConflito, contexto: contextoFrequencias)
                                                    if let faltasHorarios = faltasDiasHorarios[dia] {
                                                        for faltaHorario in faltasHorarios {
                                                            let faltas = faltaHorario.value
                                                            for falta in faltas {
                                                                falta.dataServidor = hoje
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            DispatchQueue.main.async {
                                                faltasEnviadas += 1
                                                progressoFrequencia(faltasEnviadas, totalFaltas)
                                            }
                                            dispatchGroup.leave()
                                        }
                                    }
                                    else {
                                        contextoFrequencias.perform {
                                            frequenciasSalvas += 1
                                            if let diasConflitoParaDeletar = DiaConflitoDao.diasConflitoParaDeletar(disciplina: disciplina, turma: turma, contexto: contextoFrequencias) {
                                                for diaConflito in diasConflitoParaDeletar {
                                                    if let horariosConflito = diaConflito.horarios as? Set<HorarioConflito> {
                                                        HorarioConflitoDao.removerHorariosConflito(horariosConflito: horariosConflito, contexto: contextoFrequencias)
                                                    }
                                                    DiaConflitoDao.removerDiaConflito(diaConflito: diaConflito, contexto: contextoFrequencias)
                                                }
                                            }
                                            let hoje = DateFormatter.dataDateFormatter.string(from: Date())
                                            for falta in faltasDaTurma {
                                                falta.dataServidor = hoje
                                            }
                                            DispatchQueue.main.async {
                                                faltasEnviadas += 1
                                                progressoFrequencia(faltasEnviadas, totalFaltas)
                                            }
                                            dispatchGroup.leave()
                                        }
                                    }
                                })
                            }
                            catch {
                                completion(false, Requests.getMensagemErro(error: error), nil)
                                return
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main, execute: {
                        if frequenciasSalvas > .zero {
                            completion(true, nil, contextoFrequencias)
                        }
                        else {
                            completion(false, Requests.getMensagemErro(error: erro), contextoFrequencias)
                        }
                    })
                }
                else {
                    completion(true, nil, contextoFrequencias)
                }
            }
        }
        else {
            completion(true, nil, contextoFrequencias)
        }
    }
}
