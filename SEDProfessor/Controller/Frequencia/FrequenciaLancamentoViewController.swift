//
//  FrequenciaLancamentoViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 30/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import FSCalendar
import UIKit

final class FrequenciaLancamentoViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let calendarioNavigationController = "CalendarioNavigationController"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate var dataLancamentoButton: UIButton!
    @IBOutlet fileprivate var finishButton: UIButton!
    @IBOutlet fileprivate var horarioAulaButton: UIButton!
    @IBOutlet fileprivate var serieDisciplinaLabel: UILabel!
    @IBOutlet fileprivate var tableView: UITableView!

    //MARK: Variables
    fileprivate lazy var primeiraVez = true
    fileprivate lazy var numeroAlunosAtivos: Int = .zero
    fileprivate lazy var aulas = [Aula]()
    fileprivate var isSyncFinished = false
    fileprivate var diaLetivoSelecionado: DiaLetivo?
    fileprivate var aulasSelecionadas: [Aula]!
    fileprivate var faltasDaTurma: [String:[UInt32:FaltaAluno]]!
    fileprivate var totalFaltasAluno: [TotalFaltasAluno]?
    var dataDeLancamento: Date?
    var numeroAulasPorSemana: UInt16!
    var turmaSerie: String!
    var listaAlunos: [Aluno]!
    var totalAulas: TotalAulas!
    var bimestreAtual: Bimestre!
    var disciplinaSelecionada: Disciplina!
    var turmaSelecionada: Turma!
    var calendarioLetivo: [DiaLetivo]!

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.frequenciaLancamento.localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white]
        serieDisciplinaLabel.text = turmaSerie + " / " + disciplinaSelecionada.nome
        if let numeroAulasPorSemana = FrequenciaDao.buscarFrequencia(bimestre: bimestreAtual, turma: turmaSelecionada)?.numeroAulasPorSemana {
            self.numeroAulasPorSemana = numeroAulasPorSemana
        }
        if let alunos = turmaSelecionada.alunos as? Set<Aluno>, !alunos.isEmpty {
            for aluno in alunos {
                if aluno.alunoAtivo() {
                    numeroAlunosAtivos += 1
                }
            }
            listaAlunos = alunos.sorted(by: { (aluno1, aluno2) -> Bool in
                return aluno1.numeroChamada < aluno2.numeroChamada
            })
            if let calendarioNavigationController = storyboard?.instantiateViewController(withIdentifier: Constants.calendarioNavigationController) as? UINavigationController, let calendarioViewController = calendarioNavigationController.viewControllers.first as? CalendarioViewController {
                calendarioViewController.bimestreAtual = bimestreAtual
                calendarioViewController.calendarioLetivo = calendarioLetivo
                calendarioViewController.turmaSelecionada = turmaSelecionada
                calendarioViewController.delegate = self
                presentFormSheetViewController(viewController: calendarioNavigationController)
            }
        }
        else {
            tableView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataDeLancamento = nil
        diaLetivoSelecionado = nil
        totalFaltasAluno = nil
        aulas.removeAll()
        dataLancamentoButton.setTitle(nil, for: .normal)
    }

    //MARK: Actions
    @IBAction fileprivate func changeDate() {
        horarioAulaButton.resignFirstResponder()
        dataLancamentoButton.resignFirstResponder()
    }

    @IBAction func excluirChamada() {
        /*if let aula = aulaSelecionada, let data = diaLetivoSelecionado?.dataAula {
            FaltaAlunoDao.removerFaltasDaAulaNaData(aula: aula, data: data)
        }
        CoreDataManager.sharedInstance.salvarBanco()*/
    }
    
    @IBAction func replicarChamada(_: Any) {
        /*let sim = UIAlertAction(title: Localization.sim.localized, style: .default, handler: { _ in
            for aula in self.aulasDoDia {
                if aula.id != self.aulaSelecionada?.id {
                    for aluno in self.listaAlunos {
                        if let diaLetivo = self.diaLetivoSelecionado {
                            if let tipoFrequencia = self.faltasDaTurma[aluno.id]?.tipo, !tipoFrequencia.isEmpty {
                                let falta = FaltaAlunoModel(presenca: tipoFrequencia == TipoFrequencia.Compareceu.rawValue, dataCadastro: diaLetivo.dataAula, tipo: tipoFrequencia, aluno: aluno, aula: aula, diaLetivo: diaLetivo, turma: self.turmaSelecionada)
                                _ = FaltaAlunoDao.salvar(falta: falta)
                            }
                        }
                    }
                }
            }
            CoreDataManager.sharedInstance.salvarBanco()
        })
        DispatchQueue.main.async {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.replicarLancamentoParaOutraAula.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.nao.localized, style: .cancel), sim], alvo: self)
        }*/
    }
    
    @IBAction func selecionarHorario(_ sender: Any) {
        if let navigationController = storyboard?.instantiateViewController(withIdentifier: HorariosFrequenciaViewController.className) as? UINavigationController, let horariosFrequenciaViewController = navigationController.viewControllers.first as? HorariosFrequenciaViewController {
            horariosFrequenciaViewController.primeiraVez = primeiraVez
            horariosFrequenciaViewController.aulas = aulas
            horariosFrequenciaViewController.diaLetivo = diaLetivoSelecionado
            horariosFrequenciaViewController.disciplina = disciplinaSelecionada
            horariosFrequenciaViewController.numeroAlunosAtivos = numeroAlunosAtivos
            horariosFrequenciaViewController.numeroAulasPorSemana = numeroAulasPorSemana
            horariosFrequenciaViewController.turma = turmaSelecionada
            horariosFrequenciaViewController.delegate = self
            presentFormSheetViewController(viewController: navigationController)
        }
    }

    @IBAction func presencaParaTodos(_: Any) {
        if let diaLetivo = diaLetivoSelecionado {
            for aula in aulasSelecionadas {
                let inicioHora = aula.inicioHora
                var faltasNaAula = faltasDaTurma[inicioHora]
                for aluno in listaAlunos {
                    if aluno.alunoAtivo() {
                        let codigoAluno = aluno.id
                        if let faltaAluno = faltasNaAula?[codigoAluno] {
                            if !faltaAluno.presenca {
                                let tipoString = TipoFrequencia.Compareceu.rawValue
                                faltaAluno.dataServidor = nil
                                faltaAluno.presenca = true
                                faltaAluno.tipo = tipoString
                            }
                        }
                        else {
                            let faltaAluno: FaltaAluno = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.faltaAluno)
                            faltaAluno.dataServidor = nil
                            faltaAluno.presenca = true
                            faltaAluno.dataCadastro = diaLetivo.dataAula
                            faltaAluno.tipo = TipoFrequencia.Compareceu.rawValue
                            faltaAluno.aluno = aluno
                            faltaAluno.aula = aula
                            faltaAluno.diaLetivo = diaLetivo
                            faltaAluno.turma = turmaSelecionada
                            faltasNaAula?[codigoAluno] = faltaAluno
                        }
                    }
                }
                faltasDaTurma[inicioHora] = faltasNaAula
            }
            CoreDataManager.sharedInstance.salvarBanco()
            tableView.reloadData()
        }
    }

    @IBAction func salvar(_: Any) {
        if let numeroDeFaltas = faltasDaTurma.first?.value.count, numeroDeFaltas < numeroAlunosAtivos {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.frequenciaIncompleta.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default)], alvo: self)
        }
        else {
            let ok = UIAlertAction(title: Localization.ok.localized, style: .default) { _ in
                if let registroAulaViewController: RegistroAulaViewController = self.storyboard?.instantiateViewController() {
                    registroAulaViewController.frequencia = true
                    registroAulaViewController.aulasSelecionadas = self.aulasSelecionadas
                    registroAulaViewController.bimestreAtual = self.bimestreAtual
                    registroAulaViewController.calendarioLetivo = self.calendarioLetivo
                    registroAulaViewController.dataDeLancamento = self.dataDeLancamento
                    registroAulaViewController.diaLetivoSelecionado = self.diaLetivoSelecionado
                    registroAulaViewController.disciplinaSelecionada = self.disciplinaSelecionada
                    registroAulaViewController.turmaSelecionada = self.turmaSelecionada
                    registroAulaViewController.turmaSerie = self.turmaSerie
                    self.navigationController?.pushViewController(registroAulaViewController, animated: true)
                }
            }
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.sucessoFrequencia.localized, estilo: .alert, acoes: [ok], alvo: self)
        }
    }
}

//MARK: AlunoFrequenciaDelegateCell
extension FrequenciaLancamentoViewController: AlunoFrequenciaDelegateCell {
    func alunoFrequencia(atribuiuFrequencia: ListagemCellFrequencia, linha: Int) {
        if let aluno = atribuiuFrequencia.aluno, let diaLetivo = diaLetivoSelecionado, let tipoFrequencia = atribuiuFrequencia.tipoFalta {
            var salvar = false
            let codigoAluno = aluno.id
            for aulaSelecionada in aulasSelecionadas {
                let inicioHora = aulaSelecionada.inicioHora
                var faltasNaAula = faltasDaTurma[inicioHora]
                if let faltaAluno = faltasNaAula?[codigoAluno] {
                    if faltaAluno.tipo == tipoFrequencia.rawValue {
                        salvar = salvar || false
                    }
                    else {
                        salvar = salvar || true
                        faltaAluno.dataServidor = nil
                        faltaAluno.presenca = tipoFrequencia == .Compareceu
                        faltaAluno.tipo = tipoFrequencia.rawValue
                    }
                }
                else {
                    salvar = salvar || true
                    let faltaAluno: FaltaAluno = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.faltaAluno)
                    faltaAluno.dataServidor = nil
                    faltaAluno.presenca = tipoFrequencia == .Compareceu
                    faltaAluno.dataCadastro = diaLetivo.dataAula
                    faltaAluno.tipo = tipoFrequencia.rawValue
                    faltaAluno.aluno = aluno
                    faltaAluno.aula = aulaSelecionada
                    faltaAluno.diaLetivo = diaLetivo
                    faltaAluno.turma = turmaSelecionada
                    faltasNaAula?[codigoAluno] = faltaAluno
                }
                faltasDaTurma[inicioHora] = faltasNaAula
            }
            if salvar {
                CoreDataManager.sharedInstance.salvarBanco()
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: linha, section: .zero)], with: .none)
                tableView.endUpdates()
            }
        }
    }
}

//MARK: CalendarioDelegate
extension FrequenciaLancamentoViewController: CalendarioDelegate {
    func cancelouSelecao() {
        if dataDeLancamento != nil {
            tableView.isHidden = false
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func podeSelecionar(diaLetivo: DiaLetivo) -> Bool {
        let frequenciasNaSemana = FaltaAlunoDao.frequenciasNaSemana(numeroAlunos: numeroAlunosAtivos, diaLetivo: diaLetivo, disciplina: disciplinaSelecionada, turma: turmaSelecionada)
        if frequenciasNaSemana == numeroAulasPorSemana {
            let mensagem = String(format: Localization.limiteAulasPorSemanaDia.localized, diaLetivo.dataAula, turmaSelecionada.nome, disciplinaSelecionada.nome, numeroAulasPorSemana)
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: mensagem, estilo: .alert, alvo: presentedViewController)
            return false
        }
        return true
    }
    
    func selecionouDiaLetivo(data: Date, diaLetivo: DiaLetivo) {
        dataDeLancamento = data
        diaLetivoSelecionado = diaLetivo
        dataLancamentoButton.setTitle(DateFormatter.dataDateFormatter.string(from: data), for: .normal)
        totalFaltasAluno = TotalFaltasAlunoDao.totalFaltas(disciplina: disciplinaSelecionada, turma: turmaSelecionada)
        if let disciplinaSelecionada = disciplinaSelecionada, let aulas = AulaDao.buscarAulas(bimestre: bimestreAtual, disciplina: disciplinaSelecionada, turma: turmaSelecionada) {
            self.aulas = aulas
        }
        selecionarHorario("")
    }
    
    func temLancamentoNaData(data: Date) -> Bool {
        return FaltaAlunoDao.temFaltas(data: data, disciplina: disciplinaSelecionada, turma: turmaSelecionada)
    }
}

//MARK: HorariosDelegate
extension FrequenciaLancamentoViewController: HorariosFrequenciaDelegate {
    func editarFrequencia(aula: Aula) {
    }
    
    func excluirFrequencia(aula: Aula, indice: Int) {
    }
    
    func selecionouAulas(aulas: [Aula]) {
        primeiraVez = false
        aulasSelecionadas = aulas
        if let aula = aulas.first {
            let horario = aula.inicioHora + "-" + aula.fimHora
            horarioAulaButton.setTitle(horario, for: .normal)
        }
        faltasDaTurma = [String:[UInt32:FaltaAluno]]()
        for aula in aulas {
            let inicioHora = aula.inicioHora
            var faltasNaAula: [UInt32:FaltaAluno]!
            if !faltasDaTurma.keys.contains(inicioHora) {
                faltasNaAula = [UInt32:FaltaAluno]()
            }
            else {
                faltasNaAula = faltasDaTurma[inicioHora]
            }
            if let turmaSelecionada = turmaSelecionada, let diaLetivoSelecionado = diaLetivoSelecionado, let faltasDaTurma = FaltaAlunoDao.acessarFaltas(aula: aula, diaLetivo: diaLetivoSelecionado, disciplina: disciplinaSelecionada, turma: turmaSelecionada) {
                for falta in faltasDaTurma {
                   faltasNaAula[falta.aluno.id] = falta
                }
            }
            faltasDaTurma[inicioHora] = faltasNaAula
        }
        tableView.dataSource = self
        tableView.reloadData()
        if !disciplinaSelecionada.disciplinaAnosIniciais() {
            presentedViewController?.dismiss(animated: true)
        }
    }
}

//MARK: UITableViewDataSource
extension FrequenciaLancamentoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if listaAlunos.count > .zero {
            tableView.isHidden = false
            return listaAlunos.count
        }
        tableView.isHidden = true
        return .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: ListagemCellFrequencia = tableView.dequeue(index: indexPath) {
            cell.delegate = self
            cell.totalFaltasAno = totalAulas.aulasAno
            cell.totalFaltasBimestre = totalAulas.aulasBimestre
            let linha = indexPath.row
            let faltas = totalFaltasAluno?[linha]
            cell.faltasAnoVar = faltas?.faltasAnuais
            cell.faltasBimestreVar = faltas?.faltasBimestrais
            let aluno = listaAlunos[linha]
            let falta = faltasDaTurma?.first?.value[aluno.id]
            cell.configurarCelula(aluno: aluno, falta: falta, linha: linha)
            return cell
        }
        return UITableViewCell()
    }
}
