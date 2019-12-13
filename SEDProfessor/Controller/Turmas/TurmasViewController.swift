//
//  TurmasViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 29/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

final class TurmasViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let alturaLinha: CGFloat = 86
        static let turmaVaziaCell = "TurmaVaziaCellView"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var nomeUsuarioLabel: UILabel!
    @IBOutlet fileprivate weak var serieDisciplinaLabel: UILabel!
    
    //MARK: Variables
    fileprivate lazy var anoLetivo = UserDefaults.standard.object(forKey: Chaves.anoLetivo.rawValue) as? Int
    fileprivate lazy var calendarioLetivo = [DiaLetivo]()
    fileprivate lazy var dadosFrequencia = [String:[Frequencia]]()
    fileprivate var indexPathHolded: IndexPath?
    fileprivate var serieDisciplinaSelecionada: String?
    fileprivate var totalAulas: TotalAulas = (0, 0)
    fileprivate var bimestreSelecionado: Bimestre!
    fileprivate var disciplinaSelecionada: Disciplina?
    fileprivate var turmaSelecionada: Turma?
    fileprivate var aulas: [Aula]!
    var tipoTela: TipoTela = .listagem
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = buttonItem
        tabBarController?.navigationItem.backBarButtonItem = buttonItem
        var titulo: String!
        switch tipoTela {
        case .registroLancamento:
            titulo = Localization.registroDeAulas.localized
            break
        case .frequenciaLancamento, .frequenciaConsulta:
            titulo = Localization.frequencia.localized
            break
        case .avaliacaoLancamento:
            titulo = Localization.avaliacao.localized
            break
        default:
            titulo = Localization.turmas.localized
            break
        }
        navigationItem.title = titulo
        tabBarController?.navigationItem.title = titulo
        tableView.estimatedRowHeight = Constants.alturaLinha
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        TurmaTableViewCell.register(tableView)
        tableView.register(UINib(nibName: Constants.turmaVaziaCell, bundle: nil), forCellReuseIdentifier: Constants.turmaVaziaCell)
        if let nomeCompleto = LoginRequest.usuarioLogado?.nome {
            nomeUsuarioLabel.text = nomeCompleto.uppercased()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dadosFrequencia.removeAll()
        if let frequencias = FrequenciaDao.todasFrequencias() {
            for frequencia in frequencias {
                let turma = frequencia.turma
                let key = turma.nomeEscola + "/" + turma.nomeDiretoria
                if dadosFrequencia[key] == nil {
                    dadosFrequencia[key] = [Frequencia]()
                }
                dadosFrequencia[key]?.append(frequencia)
                serieDisciplinaLabel.text = key
            }
        }
        let chaves = dadosFrequencia.keys
        if dadosFrequencia.keys.isEmpty {
            tableView.allowsSelection = false
        }
        else {
            for chave in chaves {
                dadosFrequencia[chave]?.sort(by: { (frequencia1, frequencia2) -> Bool in
                    return frequencia1.turma.id < frequencia2.turma.id
                })
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tabBarIndex = tabBarController?.selectedIndex {
            if let segue = UserDefaults.standard.object(forKey: Chaves.segueIdentifier.rawValue) as? String {
                if tabBarIndex == 1 && segue == Segue.FrequenciaTabBar.rawValue {
                    tipoTela = .frequenciaConsulta
                }
                else if segue == Segue.FrequenciaTabBar.rawValue {
                    tipoTela = .frequenciaLancamento
                }
            }
            if let items = tabBarController?.tabBar.items {
                var i: Int = .zero
                for item in items {
                    if i == 0 {
                        item.title = Localization.lancamento.localized
                    }
                    else if i == 1 {
                        item.title = Localization.consulta.localized
                    }
                    item.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
                    item.setTitleTextAttributes([.foregroundColor: Cores.defaultApp], for: .selected)
                    i += 1
                }
            }
        }
        tableView.contentInset.bottom = Constants.alturaLinha
        tableView.reloadData()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch tipoTela {
        case .listagem:
            let controller = segue.destination as? AlunosViewController
            controller?.turmaSelecionada = turmaSelecionada
            controller?.turmaSerie = serieDisciplinaSelecionada
            break
        case .registroLancamento:
            let controller = segue.destination as? RegistroAulaViewController
            controller?.turmaSelecionada = turmaSelecionada
            controller?.turmaSerie = serieDisciplinaSelecionada
            controller?.calendarioLetivo = calendarioLetivo
            controller?.disciplinaSelecionada = disciplinaSelecionada
            controller?.bimestreAtual = bimestreSelecionado
            break
        case .frequenciaLancamento:
            let controller = segue.destination as? FrequenciaLancamentoViewController
            controller?.turmaSerie = serieDisciplinaSelecionada
            controller?.turmaSelecionada = turmaSelecionada
            controller?.calendarioLetivo = calendarioLetivo
            controller?.disciplinaSelecionada = disciplinaSelecionada
            controller?.bimestreAtual = bimestreSelecionado
            controller?.totalAulas = totalAulas
            break
        case .frequenciaConsulta:
            let controller = segue.destination as? FrequenciaConsultaViewController
            controller?.turmaSerie = serieDisciplinaSelecionada
            controller?.turmaSelecionada = turmaSelecionada
            controller?.disciplinaSelecionada = disciplinaSelecionada
            break
        case .avaliacaoLancamento:
            let controller = segue.destination as? AvaliacaoViewController
            controller?.turmaSerie = serieDisciplinaSelecionada
            controller?.disciplinaSelecionada = disciplinaSelecionada
            controller?.bimestreSelecionado = bimestreSelecionado
            controller?.turmaSelecionada = turmaSelecionada
            controller?.calendarioLetivo = calendarioLetivo
            break
        case .fechamentoLancamento:
            let controller = segue.destination as? FechamentoBimestreViewController
            controller?.turmaSerie = serieDisciplinaSelecionada
            controller?.ano = anoLetivo
            controller?.turmaSelecionada = turmaSelecionada
            controller?.bimestreSelecionado = bimestreSelecionado
            controller?.disciplinaSelecionada = disciplinaSelecionada
            break
        default:
            break
        }
    }
}

//MARK: UITableViewDataSource
extension TurmasViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let chaves = dadosFrequencia.keys
        if !chaves.isEmpty {
            return chaves.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !dadosFrequencia.isEmpty {
            let chave = Array(dadosFrequencia.keys)[section]
            if let data = dadosFrequencia[chave], !data.isEmpty {
                return data.count
            }
        }
        return .zero
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !dadosFrequencia.keys.isEmpty {
            return Constants.alturaLinha
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TurmaTableViewCell!
        if !dadosFrequencia.keys.isEmpty {
            let chave = Array(dadosFrequencia.keys)[indexPath.section]
            let item = dadosFrequencia[chave]?[indexPath.row]
            cell = tableView.dequeue(index: indexPath)
            cell.frequencia = item
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.turmaVaziaCell, for: indexPath) as? TurmaTableViewCell
        }
        return cell
    }
}

//MARL: UITableViewDelegate
extension TurmasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathHolded = indexPath
        let frequencia = dadosFrequencia[Array(dadosFrequencia.keys)[indexPath.section]]?[indexPath.row]
        if let frequencia = frequencia {
            let disciplina = frequencia.disciplina
            let turma = frequencia.turma
            let turmaNome = turma.nome
            disciplinaSelecionada = disciplina
            turmaSelecionada = turma
            bimestreSelecionado = frequencia.bimestre
            serieDisciplinaSelecionada = turmaNome + " / " + disciplina.nome
            if tipoTela == .listagem {
                performSegue(withIdentifier: Segue.ListarAlunos.rawValue, sender: indexPath)
            }
            else if tipoTela == .fechamentoLancamento {
                performSegue(withIdentifier: Segue.FechamentoBimestre.rawValue, sender: indexPath)
            }
            else {
                var mostrarTela = true
                if disciplinaSelecionada?.disciplinaAnosIniciais() == false {
                    if tipoTela == .avaliacaoLancamento && disciplinaSelecionada?.permiteLancamentoAvaliacao == false {
                        mostrarTela = false
                        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: String(format: Localization.permissaoAvaliacao.localized, turmaNome, disciplina.nome), estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: nil)], alvo: self)
                    }
                    else if tipoTela == .frequenciaLancamento && disciplinaSelecionada?.permiteLancamentoFrequencia == false {
                        mostrarTela = false
                        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: String(format: Localization.permissaoFrequencia.localized, turmaNome, disciplina.nome), estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: nil)], alvo: self)
                    }
                }
                if mostrarTela {
                    aulas = [Aula]()
                    if let data = AulaDao.buscarAulas(disciplina: disciplina, frequencia: frequencia) {
                        aulas = data
                    }
                    totalAulas = (frequencia.aulasAno, frequencia.aulasBimestre)
                    if let diasLetivos =  DiaLetivoDao.diaLetivosDaTurmaNoBimestre(codigoBimestre: bimestreSelecionado.id, turma: turma), !diasLetivos.isEmpty {
                        calendarioLetivo = diasLetivos
                    }
                    if !aulas.isEmpty {
                        let identifier = Utils.getSegueIdentifier(tipoTurma: tipoTela)
                        performSegue(withIdentifier: identifier, sender: indexPath)
                    }
                    else {
                        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.nenhumaAulaEncontradaParaTurma.localized + Localization.paraATurma.localized.lowercased() + " : " + turmaNome, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: nil)], alvo: self)
                    }
                }
            }
        }
    }
}
