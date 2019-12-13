//
//  AvaliacaoListaViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 24/08/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import MZFormSheetPresentationController
import UIKit

final class AvaliacaoViewController: ViewController {
    //MARK: Outlets
    @IBOutlet fileprivate weak var disciplinaButton: UIButton!
    @IBOutlet fileprivate weak var serieDisciplinaLabel: UILabel!
    @IBOutlet fileprivate weak var avaliacaoButton: UIButton!
    @IBOutlet fileprivate weak var bimestreButton: UIButton!
    @IBOutlet fileprivate weak var tableView: UITableView!

    //MARK: Variables
    fileprivate var primeiraVez = true
    fileprivate var codigoAtividadeSelecionada: UInt32!
    fileprivate var avaliacaoSelecionada: Avaliacao?
    fileprivate var disciplinaAnosIniciais: Disciplina?
    fileprivate var fechamentoAtual: TipoFechamentoBimestre?
    fileprivate var avaliacoes: [Avaliacao]?
    var turmaSerie: String!
    var bimestreSelecionado: Bimestre!
    var disciplinaSelecionada: Disciplina!
    var turmaSelecionada: Turma!
    var calendarioLetivo: [DiaLetivo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.avaliacao.localized
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        serieDisciplinaLabel.text = turmaSerie.uppercased()
        bimestreButton.setTitle(String(bimestreSelecionado.id), for: .normal)
        fechamentoAtual = TipoFechamentoBimestreDao.getFechamentoAtual()
        if !disciplinaSelecionada.disciplinaAnosIniciais() {
            disciplinaButton.isEnabled = false
            disciplinaButton.setTitle(disciplinaSelecionada!.nome, for: .normal)
        }
        else {
            disciplinaAnosIniciais = disciplinaSelecionada
            mudarDisciplinaInicial("")
        }
    }

    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avaliacaoSelecionada = nil
        updateUI()
        resetarAtividadeFiltro()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, !identifier.isEmpty {
            switch identifier {
            case Segue.LancarNotasSegue.rawValue:
                let controller = segue.destination as! NotasViewController
                controller.avaliacaoSelecionada = avaliacaoSelecionada
                controller.bimestre = bimestreSelecionado
                controller.dataDeLancamento = avaliacaoSelecionada?.dataCadastro
                controller.disciplinaSelecionada = disciplinaSelecionada
                controller.turmaSelecionada = turmaSelecionada
                if let indexPath = sender as? IndexPath {
                    controller.headerTitle = avaliacoes?[indexPath.row].nome
                }
            default:
                break
            }
        }
    }

    //MARK: Actions
    @IBAction func mostrarAvaliacoes() {
        if let navigationController = storyboard?.instantiateViewController(withIdentifier: AvaliacoesViewController.className) as? UINavigationController, let avaliacoesViewController = navigationController.viewControllers.first as? AvaliacoesViewController {
            avaliacoesViewController.delegate = self
            presentFormSheetViewController(viewController: navigationController)
        }
    }
    
    @IBAction func mostrarBimestres() {
        if let navigationController = storyboard?.instantiateViewController(withIdentifier: BimestresViewController.className) as? UINavigationController, let bimestresViewController = navigationController.viewControllers.first as? BimestresViewController {
            bimestresViewController.disciplina = disciplinaSelecionada
            bimestresViewController.turma = turmaSelecionada
            bimestresViewController.delegate = self
            presentFormSheetViewController(viewController: navigationController)
        }
    }
    
    @IBAction func mudarDisciplinaInicial(_ sender: Any) {
        if let navigationController = storyboard?.instantiateViewController(withIdentifier: DisciplinasIniciaisViewController.className) as? UINavigationController, let disciplinasIniciaisViewController = navigationController.viewControllers.first as? DisciplinasIniciaisViewController {
            disciplinasIniciaisViewController.primeiraVez = primeiraVez
            disciplinasIniciaisViewController.delegate = self
            presentFormSheetViewController(viewController: navigationController)
        }
    }
    
    @IBAction fileprivate func novaAvaliacao() {
        if let navigationController = storyboard?.instantiateViewController(withIdentifier: NovaAvaliacaoViewController.className) as? UINavigationController, let novaAvaliacaoViewController = navigationController.viewControllers.first as? NovaAvaliacaoViewController {
            novaAvaliacaoViewController.delegate = self
            novaAvaliacaoViewController.avaliacaoSelecionada = avaliacaoSelecionada
            novaAvaliacaoViewController.bimestreSelecionado = bimestreSelecionado
            novaAvaliacaoViewController.calendarioLetivo = calendarioLetivo
            novaAvaliacaoViewController.disciplinaSelecionada = disciplinaSelecionada
            novaAvaliacaoViewController.avaliacoes = avaliacoes
            novaAvaliacaoViewController.turmaSelecionada = turmaSelecionada
            novaAvaliacaoViewController.turmaSerie = turmaSerie
            presentSheetViewController(contentViewController: navigationController)
        }
    }

    //MARK: Methods
    @objc fileprivate func navBackToHome() {
        navigationController?.popToRootViewController(animated: true)
    }

    fileprivate func resetarAtividadeFiltro() {
        codigoAtividadeSelecionada = AtividadeCodigo.todas.rawValue
        avaliacaoButton.setTitle(Atividade.Todas.rawValue, for: .normal)
    }

    fileprivate func getCodigoAvaliacaoSelecionada() -> UInt32? {
        if let selecionada = avaliacaoButton.title(for: .normal), !selecionada.isEmpty {
            switch selecionada {
            case Atividade.Avaliacao.rawValue:
                return AtividadeCodigo.avaliacao.rawValue
            case Atividade.Atividade.rawValue:
                return AtividadeCodigo.atividade.rawValue
            case Atividade.Trabalho.rawValue:
                return AtividadeCodigo.trabalho.rawValue
            case Atividade.Outros.rawValue:
                return AtividadeCodigo.outros.rawValue
            default:
                return AtividadeCodigo.todas.rawValue
            }
        }
        return nil
    }
    
    fileprivate func presentSheetViewController(contentViewController: UIViewController) {
        var size: CGSize!
        var topSet = CGFloat(33)
        let windowSize = UIApplication.shared.keyWindow!.frame.size
        let width = windowSize.width
        let height = windowSize.height
        if UIDevice.current.userInterfaceIdiom == .pad {
            size = CGSize(width: width * 0.65, height: height * 0.6)
            topSet *= 3
        }
        else {
            size = CGSize(width: width * 0.86, height: height * 0.83)
        }
        let sheetViewController = MZFormSheetPresentationViewController(contentViewController: contentViewController)
        sheetViewController.presentationController?.contentViewSize = size
        sheetViewController.presentationController?.portraitTopInset = topSet
        sheetViewController.presentationController?.landscapeTopInset = topSet
        sheetViewController.contentViewControllerTransitionStyle = .slideAndBounceFromBottom
        present(sheetViewController, animated: true, completion: nil)
    }

    fileprivate func updateUI() {
        if var codigoBimestre = bimestreSelecionado?.id {
            self.avaliacoes = AvaliacaoDao.buscarAvaliacoes(codigoBimestre: codigoBimestre, codigoDisciplina: disciplinaSelecionada.id, codigoTurma: turmaSelecionada.id)
            if fechamentoAtual != nil {
                if codigoBimestre == 1 {
                    codigoBimestre = 4
                }
                else {
                    codigoBimestre -= 1
                }
                if let avaliacaoesFechamento = AvaliacaoDao.buscarAvaliacoes(codigoBimestre: codigoBimestre, codigoDisciplina: disciplinaSelecionada.id, codigoTurma: turmaSelecionada.id) {
                    self.avaliacoes?.append(contentsOf: avaliacaoesFechamento)
                }
            }
        }
        if let codigoAvaliacaoSelecionada = getCodigoAvaliacaoSelecionada() {
            codigoAtividadeSelecionada = codigoAvaliacaoSelecionada
            if let listaAvaliacoes = self.avaliacoes, codigoAtividadeSelecionada != AtividadeCodigo.todas.rawValue {
                var avaliacoesFiltradas = [Avaliacao]()
                for avaliacao in listaAvaliacoes {
                    if avaliacao.codigoTipoAtividade == codigoAtividadeSelecionada {
                        avaliacoesFiltradas.append(avaliacao)
                    }
                }
                self.avaliacoes = avaliacoesFiltradas
            }
        }
        if let avaliacoes = self.avaliacoes, !avaliacoes.isEmpty {
            tableView.backgroundColor = .white
            tableView.tableFooterView = UIView()
        }
        else {
            tableView.tableFooterView = nil
        }
        self.avaliacoes?.sort(by: { (avaliacao1, avaliacao2) -> Bool in
            if let dataCadastro1 = DateFormatter.dataDateFormatter.date(from: avaliacao1.dataCadastro), let dataCadastro2 = DateFormatter.dataDateFormatter.date(from: avaliacao2.dataCadastro) {
                return dataCadastro1 < dataCadastro2
            }
            return false
        })
        tableView.reloadData()
    }
}

//MARK: AvaliacaoDelegate
extension AvaliacaoViewController: AvaliacaoDelegate {
    func editarAvaliacao(avaliacao: Avaliacao) {
        avaliacaoSelecionada = avaliacao
        novaAvaliacao()
    }
    
    func removerAvaliacao(indice: Int, avaliacao: Avaliacao) {
        avaliacao.dataServidor = AvaliacaoDao.Constants.deletar
        avaliacoes?.remove(at: indice)
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.tableView.reloadData()
        })
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: indice, section: .zero)], with: .right)
        tableView.endUpdates()
        CATransaction.commit()
        CoreDataManager.sharedInstance.salvarBanco()
    }
}

//MARK: AvaliacoesDelegate
extension AvaliacaoViewController: AvaliacoesDelegate {
    func selecionouAvaliacao(avaliacao: String) {
        avaliacaoButton.setTitle(avaliacao, for: .normal)
        if let codigo = getCodigoAvaliacaoSelecionada() {
            codigoAtividadeSelecionada = codigo
        }
        updateUI()
    }
}

//MARK: BimestreDelegate
extension AvaliacaoViewController: BimestreDelegate {
    func selecionouBimestre(bimestre: Bimestre) {
        bimestreSelecionado = bimestre
        bimestreButton.setTitle(String(bimestre.id), for: .normal)
        updateUI()
    }
}

//MARK: DisciplinasIniciaisDelegate
extension AvaliacaoViewController: DisciplinasIniciaisDelegate {
    func podeSelecionar(disciplina: Disciplina) -> Bool {
        if !disciplina.permiteLancamentoAvaliacao {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: String(format: Localization.permissaoAvaliacao.localized, turmaSelecionada.nome, disciplina.nome), estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .destructive, handler: nil)], alvo: presentedViewController)
            return false
        }
        return true
    }
    
    func selecionouDisciplina(disciplina: Disciplina) {
        primeiraVez = false
        disciplinaSelecionada = disciplina
        disciplinaButton.setTitle(disciplina.nome, for: .normal)
        updateUI()
    }
}

//MARK: NovaAvaliacaoDelegate
extension AvaliacaoViewController: NovaAvaliacaoDelegate {
    func teveAlteracaoNasAvaliacoes(bimestre: UInt32) {
        bimestreButton.setTitle(String(bimestre), for: .normal)
        resetarAtividadeFiltro()
        updateUI()
    }
}

//MARK: UITableViewDataSource
extension AvaliacaoViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let avaliacoes = avaliacoes, !avaliacoes.isEmpty {
            return avaliacoes.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: AvaliacaoTableViewCell = tableView.dequeue(index: indexPath) {
            let row = indexPath.row
            cell.indice = row
            cell.delegate = self
            cell.avaliacao = avaliacoes?[row]
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension AvaliacaoViewController: UITableViewDelegate {
    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: 3)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let avaliacao = avaliacoes?[indexPath.row], avaliacao.valeNota {
            if let dataAvaliacao = DateFormatter.dataDateFormatter.date(from: avaliacao.dataCadastro), dataAvaliacao > Date() {
                UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.notasAvaliacoesFuturas.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default, handler: nil)], alvo: self)
            }
            else {
                avaliacaoSelecionada = avaliacao
                performSegue(withIdentifier: Segue.LancarNotasSegue.rawValue, sender: indexPath)
            }
        }
    }
}
