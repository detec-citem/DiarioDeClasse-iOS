//
//  HorariosFrequenciaViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 23/11/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import MBProgressHUD
import UIKit

final class HorariosFrequenciaViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let traco = "-"
        static let horarioFrequenciaTableViewCell = "HorarioFrequenciaTableViewCell"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var okBarButtonItem: UIBarButtonItem!
    
    //MARK: Variables
    fileprivate lazy var selecionadas = [Bool]()
    fileprivate lazy var conflitosOffline = [FaltaAluno?]()
    fileprivate lazy var temLancamento = [Bool]()
    fileprivate lazy var temHorarioComFrequencia = [Bool]()
    weak var delegate: HorariosFrequenciaDelegate!
    var primeiraVez: Bool!
    var numeroAlunosAtivos: Int!
    var frequenciasNaSemana: UInt16!
    var numeroAulasPorSemana: UInt16!
    var diaLetivo: DiaLetivo!
    var disciplina: Disciplina!
    var turma: Turma!
    var aulas: [Aula]!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        aulas.sort(by: { (aula1, aula2) -> Bool in
            return aula1.inicioHora < aula2.inicioHora
        })
        let numeroDeAulas = aulas.count
        selecionadas.reserveCapacity(numeroDeAulas)
        conflitosOffline.reserveCapacity(numeroDeAulas)
        temHorarioComFrequencia.reserveCapacity(numeroDeAulas)
        temLancamento.reserveCapacity(numeroDeAulas)
        frequenciasNaSemana = UInt16(FaltaAlunoDao.frequenciasNaSemana(numeroAlunos: numeroAlunosAtivos, diaLetivo: diaLetivo, disciplina: disciplina, turma: turma))
        for aula in aulas {
            selecionadas.append(false)
            let temHorarioComFrequencia = HorarioFrequenciaDao.temHorarioComFrequencia(aula: aula, diaLetivo: diaLetivo, disciplina: disciplina, turma: turma)
            self.temHorarioComFrequencia.append(temHorarioComFrequencia)
            let temFaltas = FaltaAlunoDao.temFaltas(aula: aula, diaLetivo: diaLetivo, disciplina: disciplina, turma: turma)
            temLancamento.append(temFaltas || temHorarioComFrequencia)
            let conflitoOffline = FaltaAlunoDao.temConflitoOffline(aula: aula, data: diaLetivo.dataAula, disciplina: disciplina, turma: turma)
            conflitosOffline.append(conflitoOffline)
        }
        tableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction func sair(_ sender: Any) {
        dismiss(animated: true)
        if primeiraVez, let navigationController = presentingViewController as? UINavigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func selecionouAulas(_ sender: Any) {
        let numeroAulas = selecionadas.count
        var aulasSelecionadas = [Aula]()
        for i in 0 ..< numeroAulas {
            if selecionadas[i] {
                aulasSelecionadas.append(aulas[i])
            }
        }
        dismiss(animated: true) {
            self.delegate.selecionouAulas(aulas: aulasSelecionadas)
        }
    }
    
    //MARK: Methods
    fileprivate func excluirLancamento(aula: Aula, indice: Int) {
        self.temLancamento[indice] = false
        FaltaAlunoDao.removerFaltas(aula: aula, diaLetivo: self.diaLetivo, disciplina: self.disciplina, turma: self.turma)
        CoreDataManager.sharedInstance.salvarBanco()
        self.tableView.reloadData()
        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: "Lançamento de frequência excluído com sucesso!", estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
    }
}

//MARK: HorariosDelegate
extension HorariosFrequenciaViewController: HorariosFrequenciaDelegate {
    func editarFrequencia(aula: Aula) {
        delegate.selecionouAulas(aulas: [aula])
    }
    
    func excluirFrequencia(aula: Aula, indice: Int) {
        if temHorarioComFrequencia[indice] || FaltaAlunoDao.temFaltasSincronizadas(aula: aula, diaLetivo: diaLetivo, disciplina: disciplina, turma: turma) {
            if Requests.conectadoInternet() {
                let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
                progressHud.label.text = Localization.excluindoFrequencia.localized
                progressHud.detailsLabel.text = Localization.excluindoFrequenciaPorFavorAguarde.localized
                ExcluirFrequenciaRequest.excluirFrequencia(aula: aula, diaLetivo: diaLetivo, turma: turma, completion: { sucesso, erro in
                    progressHud.hide(animated: true)
                    if sucesso {
                        self.excluirLancamento(aula: aula, indice: indice)
                    }
                    else {
                        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: erro, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
                    }
                })
            }
            else {
                UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.avisoSemInternet.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
            }
        }
        else {
            excluirLancamento(aula: aula, indice: indice)
        }
    }
    
    func selecionouAulas(aulas: [Aula]) {
    }
}

//MARK: UITableViewDataSource
extension HorariosFrequenciaViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aulas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.horarioFrequenciaTableViewCell, for: indexPath) as? HorarioFrequenciaTableViewCell {
            let indice = indexPath.row
            let aula = aulas[indice]
            let temLancamentoNoHorario = temLancamento[indice]
            cell.configurarCelula(aula: aula, temLancamento: temLancamentoNoHorario, indice: indice, delegate: self)
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension HorariosFrequenciaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linha = indexPath.row
        let aula = aulas[linha]
        if let conflitoOffline = conflitosOffline[linha] {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: String(format: Localization.conflitoFrequenciaOffline.localized, conflitoOffline.turma.nome, diaLetivo.dataAula, disciplina.nome, aula.inicioHora, aula.fimHora), estilo: .alert, alvo: self)
        }
        else {
            var selecionada = selecionadas[linha]
            if !selecionada {
                var numeroHorarios = frequenciasNaSemana
                for selecionado in selecionadas {
                    if selecionado {
                        numeroHorarios! += 1
                    }
                }
                if numeroHorarios == numeroAulasPorSemana {
                    let mensagem = String(format: Localization.limiteAulasPorSemanaHorario.localized, diaLetivo.dataAula, turma.nome, disciplina.nome, numeroAulasPorSemana)
                    UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: mensagem, estilo: .alert, alvo: self)
                    return
                }
            }
            selecionada = !selecionada
            selecionadas[linha] = selecionada
            let cell = tableView.cellForRow(at: indexPath) as? HorarioFrequenciaTableViewCell
            cell?.selecionada = selecionada
            var habilitarBotao = false
            if selecionada {
                habilitarBotao = true
            }
            else {
                for selecionada in selecionadas {
                    if selecionada {
                        habilitarBotao = true
                        break
                    }
                }
            }
            okBarButtonItem.isEnabled = habilitarBotao
        }
    }
}
