//
//  Constants.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 26/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

enum AlturaAparelho: CGFloat {
    case iPhone4s = 480
    case iPhone5s = 568
    case iPhone6s = 667
    case iPhone6sPlus = 736
    case iPad = 768
}

enum Atividade: String {
    case Todas
    case Avaliacao = "Avaliação"
    case Atividade
    case Trabalho
    case Outros
}

enum AtividadeCodigo: UInt32 {
    case avaliacao = 11
    case atividade = 12
    case trabalho = 13
    case outros = 14
    case todas = 15
}

enum Chaves: String {
    case anoLetivo = "KEY_ANO_LETIVO"
    case segueIdentifier = "KEY_SEGUE_IDENTIFIER"
    case sync = "KEY_SYNC"
}

struct Cores {
    static let aplicativo = UIColor(red: 69.0/255.0, green: 154.0/255.0, blue: 214.0/255.0, alpha: 1)
    static let confirmaNota = UIColor(red: .zero, green:0.80, blue:0.40, alpha:1.0)
    static let defaultApp = UIColor(red:0.27, green:0.60, blue:0.84, alpha:1.0)
    static let defaultLight = UIColor(red: 69.0/255.0, green: 154.0/255.0, blue: 214.0/255.0, alpha: 0.5)
    static let diaNaoLetivo = UIColor(red:0.78, green:0.78, blue:0.78, alpha:1.0)
    static let falta1 = UIColor(red:0.79, green:0.37, blue:0.37, alpha:1.0)
    static let falta2 = UIColor(red:0.95, green:0.08, blue:0.08, alpha:1.0)
    static let fundoDiaComLancamento = UIColor(red:0.74, green:0.90, blue:0.71, alpha:1.0)
    static let fundoPadrao = UIColor(red:0.56, green:0.79, blue:0.98, alpha:1.0)
    static let itemsToSync = UIColor(red:0.95, green:0.69, blue:0.13, alpha:1.0)
    static let lightBlack = UIColor(red:0.25, green:0.27, blue:0.30, alpha:1.0)
    static let naoAplicavel = UIColor(red:0.92, green:0.73, blue:0.04, alpha:1.0)
    static let tituloDiaComLancamento = UIColor(red:0.37, green:0.54, blue:0.35, alpha:1.0)
    static let tituloPadrao = UIColor(red:0.10, green:0.46, blue:0.82, alpha:1.0)
}

enum FaltasPeriodo: String {
    case Anual
    case Bimestral
    case Sequencial
}

enum Imagens: String {
    case IcAvaliacao = "ic_avaliacao"
    case IcFrequencia = "ic_frequencia"
    case IcPlanejamento = "ic_planejamento"
    case IcFechamento = "ic_fechamento"
    case IcFechamentoDisabled = "ic_fechamento_disabled"
    case IcTurmas = "ic_turmas"
}

enum Segue: String {
    case DetalhesAluno = "detalhesAluno"
    case TurmasSegue
    case RegistroSegue
    case ListarAlunos = "listarAlunos"
    case LancamentoFrequencia
    case RegistroLancamento
    case LancamentoAvaliacao
    case FrequenciaSegue
    case MostrarHome = "mostrarHome"
    case NovaAvaliacaoSegue
    case LancarNotasSegue
    case FrequenciaTabBar
    case ConsultaFrequencia
    case ConsultaAvaliacao
    case AvaliacaoSegue
    case FechamentoSegue
    case FechamentoBimestre
    case FechamentoLista
}

enum TipoDisciplina: UInt32 {
    case disciplinaInicial = 1000
    case ciencias = 7245
    case geografia = 2100
    case historia = 2200
}

enum TipoFechamento: String {
    case Confirmou = "C"
    case ConfirmouSemNota = "SN"
    case NaoConfirmou = "N"
    case NaoConfirmouSemNota = "NSN"
    case Transferido = "T"
}

enum TipoFrequencia: String {
    case Faltou = "F"
    case Compareceu = "C"
    case NA = "N"
    case Transferido = "Ina-"
}

enum TipoTela: Int {
    case listagem = 1
    case frequenciaLancamento = 2
    case frequenciaConsulta = 3
    case registroLancamento = 4
    case registroConsulta = 5
    case avaliacaoLancamento = 6
    case fechamentoLancamento = 7
}

enum TipoTurmaNome: String {
    case Nome1 = "Turmas"
    case Nome2 = "Registro de Aulas"
    case Nome3 = "Frequência"
    case Nome4 = "Avaliações"
    case Nome5 = "Fechamento"
}

enum TypeId: Int {
    case arithmetic = 1
    case weighted = 2
    case sum = 3
}

enum TypeListButton: Int {
    case vertical = 0
    case horizontal = 1
}

enum TypeName: String {
    case arithmetic = "Aritmética"
    case weighted = "Ponderada"
    case sum = "Soma"
}

struct SyncDates {
    var date: String?
    var isSync: Bool?
    init(date: String, isSync: Bool = false) {
        self.date = date
        self.isSync = isSync
    }
}
