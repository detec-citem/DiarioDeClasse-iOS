//
//  BuscarTurmasRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 06/03/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

class BuscarTurmasRequest {
    //MARK: Constants
    fileprivate struct Constants {
        static let campoAno = "Ano"
        static let campoCurriculos = "Curriculos"
        static let campoDiasComFrequencia = "DiasComFrequencia"
        static let campoDiasLetivos = "DiasLetivos"
        static let campoGrupo = "Grupo"
        static let campoMes = "Mes"
        static let campoCalendarioBimestreAtual = "CalendarioBimestreAtual"
        static let campoCalendarioBimestreAnterior = "CalendarioBimestreAnterior"
        static let campoFechamentos = "Fechamentos"
        static let campoFechamentoParametrizacao = "FechamentoParametrizacao"
        static let campoRegistrosAula = "RegistrosAula"
        static let campoTurmasFrequencia = "TurmasFrequencia"
        static let campoTurmasTurmas = "TurmasTurmas"
        static let buscarTurmasApi = "Offline3/Professor"
        static let buscarTurmasMock = "offline"
        static let totalBimestres = 4
        static let separador1 = "ás"
        static let separador2 = " ás "
        static let separador3 = "-"
    }
    
    //MARK: Methods
    static func buscarTurmas(primeiraVez: Bool, completion: @escaping ((Bool, String?) -> Void)) {
        if let usuarioLogado = LoginRequest.usuarioLogado, !Requests.Configuracoes.servidorHabilitado || (usuarioLogado.usuario == Requests.Configuracoes.LoginTeste.usuario && usuarioLogado.senha.base64Decoded == Requests.Configuracoes.LoginTeste.senha), let json = Requests.getLocalJsonData(name: Constants.buscarTurmasMock) as? [String:Any] {
            processarTurmas(primeiraVez: primeiraVez, json: json, completion: completion)
        }
        else if let url = URL(string: Requests.Configuracoes.urlServidor + Constants.buscarTurmasApi) {
            Requests.requestData(requisicao: URLRequest(url: url), metodoHttp: .get, completion: { data, error, _ in
                if error == nil, let data = data as? Data, let json = Requests.parseJson(data: data) as? [String: Any] {
                    processarTurmas(primeiraVez: primeiraVez, json: json, completion: completion)
                }
                else {
                    DispatchQueue.main.async {
                        completion(false, Requests.getMensagemErro(error: error))
                    }
                }
            })
        }
        else {
            completion(false, Localization.erroDesconhecido.localized)
        }
    }
    
    fileprivate static func processarCalendario(ano: Int, codigoTurmaServidor: UInt32, json: [[String:Any]], bimeste: Bimestre, turma: Turma) {
        let anoString = String(ano)
        let bimestreId = String(bimeste.id)
        let turmaIdString = String(codigoTurmaServidor)
        for calendarioJson in json {
            if let mes = calendarioJson[Constants.campoMes] as? Int, let diasJson = calendarioJson[Constants.campoDiasLetivos] as? [Int] {
                var mesString = String(mes)
                if mes < 10 {
                    mesString = "0" + mesString
                }
                for dia in diasJson {
                    var diaString = String(dia)
                    if dia < 10 {
                        diaString = "0" + diaString
                    }
                    DiaLetivoDao.salvar(id: turmaIdString + bimestreId + anoString + mesString + diaString, data: diaString + "/" + mesString + "/" + anoString, bimestre: bimeste, turma: turma)
                }
            }
        }
    }
    
    fileprivate static func processarTurmas(primeiraVez: Bool, json: [String:Any], completion: @escaping ((Bool, String?) -> Void)) {
        DispatchQueue.main.async {
            if let ano = json[Constants.campoAno] as? Int, let turmasJson = json[Constants.campoTurmasTurmas] as? [[String:Any]] {
                UserDefaults.standard.set(ano, forKey: Chaves.anoLetivo.rawValue)
                UserDefaults.standard.synchronize()
                if !turmasJson.isEmpty {
                    var turmasSaved = [Bool]()
                    var frequenciasSaved = [Bool]()
                    
                    // Tipos de Fechamento
                    TipoFechamentoBimestreDao.removerTiposFechamento()
                    var tiposFechamento = [UInt32:TipoFechamentoBimestre]()
                    if let fechamentosJson = json[Constants.campoFechamentoParametrizacao] as? [[String:Any]] {
                        for fechamentoJson in fechamentosJson {
                            let tipoFechamento = TipoFechamentoBimestreDao.salvar(json: fechamentoJson)
                            tiposFechamento[tipoFechamento.id] = tipoFechamento
                        }
                    }
                    
                    // Turmas
                    var alunos = [UInt64:Aluno]()
                    var disciplinas = [UInt32:Disciplina]()
                    var turmas = [UInt32:Turma]()
                    AlunoDao.removerAlunos()
                    DisciplinaDao.removerDisciplinas()
                    TurmaDao.removerTurmas()
                    for turmaJson in turmasJson {
                        if turmasSaved.contains(false) {
                            break
                        }
                        else {
                            let turma = TurmaDao.salvar(json: turmaJson)
                            turmas[turma.id] = turma
                            if let alunosJson = turmaJson[TurmaDao.CamposServidor.alunos] as? [[String:Any]] {
                                // Alunos
                                for alunoJson in alunosJson {
                                    if let aluno = AlunoDao.salvar(json: alunoJson, turma: turma) {
                                        alunos[aluno.codigoMatricula] = aluno
                                    }
                                    else {
                                        turmasSaved.append(false)
                                        break
                                    }
                                }
                            }
                            if let disciplinasJson = turmaJson[TurmaDao.CamposServidor.disciplinas] as? [[String:Any]] {
                                //Disciplinas
                                for disciplinaJson in disciplinasJson {
                                    //Não adicionar as disciplinas Geografia (2100) e História (2200)
                                    if let codigoDisciplina = disciplinaJson[DisciplinaDao.CamposServidor.id] as? UInt32, codigoDisciplina != TipoDisciplina.geografia.rawValue && codigoDisciplina != TipoDisciplina.historia.rawValue {
                                        disciplinas[codigoDisciplina] = DisciplinaDao.salvar(json: disciplinaJson)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Frequencias
                    var aulas = [UInt32:[String:Aula]]()
                    var bimestresTotais = [UInt32:Bimestre]()
                    var bimestresTurmaDisciplina = [UInt32:[UInt32:[UInt32:Bimestre]]]()
                    var frequenciasTurmaDisciplina = [UInt32:[UInt32:Frequencia]]()
                    AulaDao.removerAulas()
                    BimestreDao.removerBimestres()
                    DiaFrequenciaDao.removerDiasFrequencia()
                    DiaLetivoDao.removerDiasLetivos()
                    FrequenciaDao.removerFrequencias()
                    HorarioFrequenciaDao.removerHorariosFrequencia()
                    TotalFaltasAlunoDao.removerTotalFaltasAluno()
                    if let turmasFrequenciasJson = json[Constants.campoTurmasFrequencia] as? [[String:Any]] {
                        for turmaFrequenciaJson in turmasFrequenciasJson {
                            if let codigoTurmaServidor = turmaFrequenciaJson[FrequenciaDao.CamposServidor.codigoTurma] as? UInt32, let turma = turmas[codigoTurmaServidor] {
                                if let disciplinaJson = turmaFrequenciaJson[FrequenciaDao.CamposServidor.disciplina] as? [String:Any], let codigoDisciplina = disciplinaJson[DisciplinaDao.CamposServidor.id] as? UInt32 {
                                    
                                    // Disciplina
                                    var disciplina: Disciplina!
                                    if disciplinas.keys.contains(codigoDisciplina) {
                                        disciplina = disciplinas[codigoDisciplina]
                                    }
                                    else {
                                        disciplina = DisciplinaDao.salvar(json: disciplinaJson)
                                        disciplinas[codigoDisciplina] = disciplina
                                    }
                                    
                                    // Bimestre Atual
                                    var bimestreAtual: Bimestre!
                                    var bimestresDisciplina: [UInt32:[UInt32:Bimestre]]!
                                    if bimestresTurmaDisciplina.keys.contains(codigoTurmaServidor) {
                                        bimestresDisciplina = bimestresTurmaDisciplina[codigoTurmaServidor]
                                    }
                                    else {
                                        bimestresDisciplina = [UInt32:[UInt32:Bimestre]]()
                                    }
                                    var bimestres: [UInt32:Bimestre]!
                                    let codigoDisciplina = disciplina.id
                                    if bimestresDisciplina.keys.contains(codigoDisciplina) {
                                        bimestres = bimestresDisciplina[codigoDisciplina]
                                    }
                                    else {
                                        bimestres = [UInt32:Bimestre]()
                                    }
                                    if let bimestreAtualJson = turmaFrequenciaJson[FrequenciaDao.CamposServidor.bimestreAtual] as? [String:Any], let codigoBimestreAtual = bimestreAtualJson[BimestreDao.CamposServidor.id] as? UInt32, let bimestresJson = turmaFrequenciaJson[FrequenciaDao.CamposServidor.bimestreCalendario] as? [[String:Any]] {
                                        for bimestreJson in bimestresJson {
                                            let bimestre = BimestreDao.salvar(json: bimestreJson)
                                            let codigoBimestre = bimestre.id
                                            bimestres[codigoBimestre] = bimestre
                                            if bimestresTotais.count < Constants.totalBimestres {
                                                bimestresTotais[codigoBimestre] = bimestre
                                            }
                                            if codigoBimestre == codigoBimestreAtual {
                                                bimestre.atual = true
                                                bimestreAtual = bimestre
                                            }
                                        }
                                    }
                                    bimestresDisciplina[codigoDisciplina] = bimestres
                                    bimestresTurmaDisciplina[codigoTurmaServidor] = bimestresDisciplina
                                    
                                    // Bimestre Anterior
                                    var bimestreAnterior: Bimestre!
                                    if let bimestreAnteriorJson = turmaFrequenciaJson[FrequenciaDao.CamposServidor.bimestreAnterior] as? [String:Any], let bimestreAnteriorId = bimestreAnteriorJson[BimestreDao.CamposServidor.id] as? UInt32 {
                                        bimestreAnterior = bimestres[bimestreAnteriorId]
                                    }
                                    
                                    // Calendario Bimestre Atual
                                    if let calendarioBimestreAtualJson = turmaFrequenciaJson[Constants.campoCalendarioBimestreAtual] as? [[String:Any]] {
                                        processarCalendario(ano: ano, codigoTurmaServidor: codigoTurmaServidor, json: calendarioBimestreAtualJson, bimeste: bimestreAtual, turma: turma)
                                    }
                                    
                                    // Calendario Bimestre Anterior
                                    if let calendarioBimestreAnteriorJson = turmaFrequenciaJson[Constants.campoCalendarioBimestreAnterior] as? [[String:Any]] {
                                        processarCalendario(ano: ano, codigoTurmaServidor: codigoTurmaServidor, json: calendarioBimestreAnteriorJson, bimeste: bimestreAnterior, turma: turma)
                                    }
                                    
                                    // Frequencia
                                    var frequenciasDisciplina: [UInt32:Frequencia]!
                                    if frequenciasTurmaDisciplina.keys.contains(codigoTurmaServidor) {
                                        frequenciasDisciplina = frequenciasTurmaDisciplina[codigoTurmaServidor]
                                    }
                                    else {
                                        frequenciasDisciplina = [UInt32:Frequencia]()
                                    }
                                    let frequencia = FrequenciaDao.salvar(json: turmaFrequenciaJson, bimestre: bimestreAtual, disciplina: disciplina, turma: turma)
                                    frequenciasDisciplina[codigoDisciplina] = frequencia
                                    frequenciasTurmaDisciplina[codigoTurmaServidor] = frequenciasDisciplina
                                    for bimestre in bimestres.values {
                                        bimestre.frequencia = frequencia
                                    }
                                    
                                    // Aulas
                                    if let aulasJson = disciplinaJson[DisciplinaDao.CamposServidor.aulas] as? [[String:Any]] {
                                        for aulaJson in aulasJson {
                                            if aulas[codigoDisciplina] == nil {
                                                aulas[codigoDisciplina] = [String:Aula]()
                                            }
                                            let aula = AulaDao.salvar(json: aulaJson, disciplina: disciplina, frequencia: frequencia)
                                            aulas[codigoDisciplina]?[aula.inicioHora] = aula
                                        }
                                    }
                                    
                                    // Total Faltas Aluno
                                    if let faltasJson = disciplinaJson[DisciplinaDao.CamposServidor.faltasAlunos] as? [[String:Any]] {
                                        for faltaJson in faltasJson {
                                            if let codigoMatricula = faltaJson[TotalFaltasAlunoDao.CamposServidor.codigoMatricula] as? UInt64, let aluno = alunos[codigoMatricula] {
                                                TotalFaltasAlunoDao.salvar(json: faltaJson, aluno: aluno, disciplina: disciplina)
                                            }
                                        }
                                    }
                                    
                                    //DisciplinasQuebra
                                    if let disciplinasQuebraJson = disciplinaJson[DisciplinaDao.CamposServidor.disciplinasQuebra] as? [[String:Any]] {
                                        for var disciplinaQuebraJson in disciplinasQuebraJson {
                                            //Não adicionar as disciplinas Geografia (2100) e História (2200)
                                            if let codigoDisciplinaQuebra = disciplinaQuebraJson[DisciplinaDao.CamposServidor.codigoDisciplinaQuebra] as? UInt32, codigoDisciplinaQuebra != TipoDisciplina.geografia.rawValue && codigoDisciplinaQuebra != TipoDisciplina.historia.rawValue {
                                                var disciplina: Disciplina!
                                                if disciplinas.keys.contains(codigoDisciplinaQuebra) {
                                                    disciplina = disciplinas[codigoDisciplinaQuebra]
                                                }
                                                else {
                                                    disciplinaQuebraJson[DisciplinaDao.CamposServidor.id] = codigoDisciplinaQuebra
                                                    disciplina = DisciplinaDao.salvar(json: disciplinaQuebraJson)
                                                    disciplinas[codigoDisciplina] = disciplina
                                                }
                                                disciplina.anoInicial = true
                                            }
                                        }
                                    }
                                    
                                    // DiasFrequencia
                                    if let diasFrequenciaJson = turmaFrequenciaJson[Constants.campoDiasComFrequencia] as? [String] {
                                        var diasFrequencia = [String:DiaFrequencia]()
                                        for diaFrequencia in diasFrequenciaJson {
                                            if let dataCompleta = DateFormatter.isoDataHorarioFormatter.date(from: diaFrequencia) {
                                                var diaFrequencia: DiaFrequencia!
                                                let data = DateFormatter.dataDateFormatter.string(from: dataCompleta)
                                                let horario = DateFormatter.horarioFormatter.string(from: dataCompleta)
                                                if diasFrequencia.keys.contains(data) {
                                                    diaFrequencia = diasFrequencia[data]
                                                }
                                                else {
                                                    diaFrequencia = DiaFrequenciaDao.salvar(dataString: data, frequencia: frequencia)
                                                    diasFrequencia[data] = diaFrequencia
                                                }
                                                HorarioFrequenciaDao.salvar(horario: horario, diaFrequencia: diaFrequencia)
                                            }
                                        }
                                    }
                                    
                                    // Avaliações
                                    if let avaliacoesJson = turmaFrequenciaJson[FrequenciaDao.CamposServidor.avaliacoes] as? [[String:Any]] {
                                        var codigosAvaliacoesSalvas = Set<Int32>()
                                        for avaliacaoJson in avaliacoesJson {
                                            if let codigoBimestre = avaliacaoJson[AvaliacaoDao.CamposServidor.bimestre] as? UInt32, let codigoDisciplinaAvaliacao = avaliacaoJson[AvaliacaoDao.CamposServidor.codigoDisciplina] as? UInt32, let bimestre = bimestres[codigoBimestre], let disciplinaAvaliacao = disciplinas[codigoDisciplinaAvaliacao] {
                                                let avaliacao = AvaliacaoDao.salvar(primeiraVez: primeiraVez, dadosServidor: avaliacaoJson, bimestre: bimestre, disciplina: disciplinaAvaliacao, turma: turma)
                                                codigosAvaliacoesSalvas.insert(avaliacao.id)
                                                
                                                // Notas
                                                if let notasJson = avaliacaoJson[AvaliacaoDao.CamposServidor.notas] as? [[String:Any]] {
                                                    for notaJson in notasJson {
                                                        if let matricula = notaJson[NotaAlunoDao.CamposServidor.codigoMatriculaAluno] as? UInt64, let aluno = alunos[matricula] {
                                                            NotaAlunoDao.salvar(primeiraVez: primeiraVez, json: notaJson, aluno: aluno, avaliacao: avaliacao)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        NotaAlunoDao.removerNotasDasAvaliacoes(codigosAvaliacoesSalvas: codigosAvaliacoesSalvas)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        frequenciasSaved.append(false)
                    }
                    
                    // Fechamentos
                    if let fechamentosJson = json[Constants.campoFechamentos] as? [[String:Any]] {
                        for fechamentoJson in fechamentosJson {
                            if let codigoDisciplina = fechamentoJson[FechamentoTurmaDao.CamposServidor.codigoDisciplina] as? UInt32, let codigoTipoFechamento = fechamentoJson[FechamentoTurmaDao.CamposServidor.codigoTipoFechamento] as? UInt32, let codigoTurma = fechamentoJson[FechamentoTurmaDao.CamposServidor.codigoTurma] as? UInt32, let disciplina = disciplinas[codigoDisciplina], let tipoFechamento = tiposFechamento[codigoTipoFechamento], let turma = turmas[codigoTurma], let bimestre = frequenciasTurmaDisciplina[codigoTurma]?[codigoDisciplina]?.bimestre {
                                let fechamentoTurma = FechamentoTurmaDao.salvar(json: fechamentoJson, bimestre: bimestre, disciplina: disciplina, tipoFechamento: tipoFechamento, turma: turma)
                                if let fechamentosAlunosJson = fechamentoJson[FechamentoTurmaDao.CamposServidor.fechamentos] as? [[String: Any]] {
                                    for fechamentoAlunoJson in fechamentosAlunosJson {
                                        if let codigoMatricula = fechamentoAlunoJson[FechamentoAlunoDao.CamposServidor.codigoMatricula] as? UInt64, let aluno = alunos[codigoMatricula] {
                                            FechamentoAlunoDao.salvar(primeiraVez: primeiraVez, json: fechamentoAlunoJson, aluno: aluno, fechamentoTurma: fechamentoTurma)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Grupos
                    ConteudoDao.removerConteudos()
                    CurriculoDao.removerCurriculos()
                    GrupoDao.removerGrupos()
                    HabilidadeDao.removerHabilidades()
                    var grupos = [UInt32:Grupo]()
                    var habilidades = [UInt32:[UInt32:Habilidade]]()
                    if let curriculosJson = json[Constants.campoCurriculos] as? [[String: Any]] {
                        for curriculoJson in curriculosJson {
                            if let grupoJson = curriculoJson[Constants.campoGrupo] as? [String: Any], let codigoDisciplina = grupoJson[GrupoDao.CamposServidor.codigoDisciplina] as? UInt32, let disciplina = disciplinas[codigoDisciplina] {
                                let grupo = GrupoDao.salvar(json: grupoJson, disciplina: disciplina)
                                grupos[grupo.id] = grupo
                                
                                // Curriculo
                                if let curriculos = grupoJson[GrupoDao.CamposServidor.curriculos] as? [[String:Any]] {
                                    for curriculoServidor in curriculos {
                                        if let codigoBimestre = curriculoServidor[CurriculoDao.CamposServidor.bimestre] as? UInt32, let bimestre = bimestresTotais[codigoBimestre] {
                                            let curriculo = CurriculoDao.salvar(dadosServidor: curriculoServidor, bimestre: bimestre, grupo: grupo)
                                            
                                            // Conteudos
                                            if let conteudosJson = curriculoServidor[CurriculoDao.CamposServidor.conteudos] as? [[String:Any]] {
                                                for conteudoJson in conteudosJson {
                                                    let conteudo = ConteudoDao.salvar(json: conteudoJson, curriculo: curriculo)
                                                    let codigoConteudo = conteudo.id
                                                    
                                                    // Habilidades
                                                    if let habilidadesJson = conteudoJson[ConteudoDao.CamposServidor.habilidades] as? [[String: Any]] {
                                                        for habilidadeJson in habilidadesJson {
                                                            let habilidade = HabilidadeDao.salvar(json: habilidadeJson, conteudo: conteudo)
                                                            if habilidades[codigoConteudo] == nil {
                                                                habilidades[codigoConteudo] = [UInt32:Habilidade]()
                                                            }
                                                            habilidades[codigoConteudo]?[habilidade.id] = habilidade
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // RegistroAula
                    if let registrosAulaJson = json[Constants.campoRegistrosAula] as? [[String:Any]] {
                        for registroAulaJson in registrosAulaJson {
                            if let codigoBimestre = registroAulaJson[RegistroAulaDao.CamposServidor.bimestre] as? UInt32, let codigoGrupo = registroAulaJson[RegistroAulaDao.CamposServidor.codigoGrupoCurriculo] as? UInt32, let codigoTurma = registroAulaJson[RegistroAulaDao.CamposServidor.codigoTurma] as? UInt32, let horariosJson = registroAulaJson[RegistroAulaDao.CamposServidor.horarios] as? [String], let habilidadesJson = registroAulaJson[RegistroAulaDao.CamposServidor.habilidades] as? [[String:Any]], let grupo = grupos[codigoGrupo], let turma = turmas[codigoTurma], let aulasDaDisciplina = aulas[grupo.disciplina.id], let bimestre = bimestresTurmaDisciplina[codigoTurma]?[grupo.disciplina.id]?[codigoBimestre] {
                                var horarios = [Aula]()
                                horarios.reserveCapacity(horariosJson.count)
                                for horarioJson in horariosJson {
                                    if horarioJson.contains(Constants.separador1), let inicioHora = horarioJson.components(separatedBy: Constants.separador2).first, let aula = aulasDaDisciplina[inicioHora] {
                                        horarios.append(aula)
                                    }
                                    else if horarioJson.contains(Constants.separador3), let inicioHora = horarioJson.components(separatedBy: Constants.separador3).first, let aula = aulasDaDisciplina[inicioHora] {
                                        horarios.append(aula)
                                    }
                                }
                                let registroAula = RegistroAulaDao.salvar(primeiraVez: primeiraVez, json: registroAulaJson, bimestre: bimestre, grupo: grupo, turma: turma, horarios: horarios)
                                var habilidadesRegistroAula = Set<HabilidadeRegistroAula>()
                                for habilidadeJson in habilidadesJson {
                                    if let codigoConteudo = habilidadeJson[RegistroAulaDao.CamposServidor.codigoConteudo] as? UInt32, let codigoHabilidade = habilidadeJson[RegistroAulaDao.CamposServidor.codigoHabilidade] as? UInt32, let habilidade = habilidades[codigoConteudo]?[codigoHabilidade] {
                                        let habilidadeRegistroAula = HabilidadeRegistroAulaDao.salvar(selecionada: true, habilidade: habilidade, registroAula: registroAula)
                                        habilidadesRegistroAula.insert(habilidadeRegistroAula)
                                    }
                                }
                                registroAula.habilidadesRegistroAula = habilidadesRegistroAula as NSSet
                            }
                        }
                    }
                    if frequenciasSaved.contains(false) || turmasSaved.contains(false) {
                        CoreDataManager.sharedInstance.rollback()
                        completion(false, Localization.naoFoiPossivelAcessarDados.localized)
                    }
                    else {
                        CoreDataManager.sharedInstance.salvarBanco()
                        completion(true, nil)
                    }
                }
                else {
                    completion(true, nil)
                }
            }
        }
    }
}
