//
//  AvaliacaoLancamentoViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 24/08/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

final class NotasViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let alunoAvaliacaoiPad = "AlunoAvaliacaoViewPad"
        static let alunoAvaliacaoiPhone = "AlunoAvaliacaoView"
        static let carouselImage = "carousel-50"
        static let detalhesAlunoSegue = "detalhesAluno"
        static let listaImage = "lista"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var nextButton: UIBarButtonItem!
    @IBOutlet fileprivate var backButton: UIBarButtonItem!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var dataLancamentoLabel: UILabel!
    @IBOutlet fileprivate var finishButton: UIBarButtonItem!
    @IBOutlet fileprivate var containerHeaderView: UIView!
    
    //MARK: Variables
    fileprivate lazy var primeiraVez = true
    fileprivate lazy var indexAlunoSelecionado: Int = .zero
    fileprivate lazy var listButton = UIBarButtonItem()
    fileprivate lazy var alunos = [Aluno]()
    fileprivate lazy var listaViewsAlunos = [AlunoAvaliacaoView]()
    fileprivate var isSyncFinished: Bool!
    fileprivate var diaLetivoSelecionado: DiaLetivo?
    fileprivate var screenWidth: CGFloat!
    var avaliacaoSelecionada: Avaliacao?
    var bimestre: Bimestre!
    var dataDeLancamento: String!
    var disciplinaSelecionada: Disciplina!
    var headerTitle: String!
    var turmaSelecionada: Turma!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.avaliacaoLancamento.localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white]
        scrollView.bounces = true
        containerHeaderView.backgroundColor = .groupTableViewBackground
        containerHeaderView.setShadow(enable: true)
        dataLancamentoLabel.text = dataDeLancamento
        backButton.title = Localization.anterior.localized
        finishButton.title = Localization.finalizar.localized
        if let nomeTurmaSerie = headerTitle, !nomeTurmaSerie.isEmpty {
            titleLabel.text = nomeTurmaSerie.uppercased()
        }
        UIViewController.showButtonItem(buttons: [finishButton, backButton], isShow: false)
        UIViewController.set(buttons: [backButton, finishButton, nextButton], font: .boldSystemFont(ofSize: 12))
        setupListButton(type: .vertical)
        diaLetivoSelecionado = DiaLetivoDao.diaLetivoNaData(data: dataDeLancamento)
        if let alunos = turmaSelecionada.alunos as? Set<Aluno> {
            self.alunos = alunos.sorted(by: { (aluno1, aluno2) -> Bool in
                return aluno1.numeroChamada < aluno2.numeroChamada
            })
        }
        if !alunos.isEmpty {
            listButton.isEnabled = true
        }
        else {
            listButton.isEnabled = false
        }
        setNextButton(isList: false, isHidden: false)
        let numeroAlunos = alunos.count
        screenWidth = view.frame.width
        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(numeroAlunos), height: .zero)
        scrollView.setContentOffset(.zero, animated: true)
        for view in scrollView.subviews {
            if view is AlunoAvaliacaoView {
                view.removeFromSuperview()
            }
        }
        tableView.reloadData()
        if let dataServidor = avaliacaoSelecionada?.dataServidor, !dataServidor.isEmpty,
            let notas = avaliacaoSelecionada?.notasAluno.allObjects as? [NotaAluno], !notas.isEmpty {
            var alunosAtivos: Int = .zero
            for aluno in alunos {
                if aluno.alunoAtivo() {
                    alunosAtivos += 1
                }
            }
            isSyncFinished = alunosAtivos == notas.count
        }
        else {
            isSyncFinished = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if primeiraVez {
            primeiraVez = false
            var i: Int = .zero
            let numeroAlunos = alunos.count
            let scrollViewHeight = scrollView.frame.height
            listaViewsAlunos.reserveCapacity(listaViewsAlunos.count)
            for aluno in alunos {
                let notaAluno = getNotaAluno(alunoId: aluno.id)
                if listaViewsAlunos.count > i {
                    let alunoView = listaViewsAlunos[i]
                    alunoView.totalAlunos = numeroAlunos
                    alunoView.notaAluno = notaAluno
                    alunoView.aluno = aluno
                }
                else {
                    var nibName: String!
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        nibName = Constants.alunoAvaliacaoiPhone
                    }
                    else {
                        nibName = Constants.alunoAvaliacaoiPad
                    }
                    let alunoAvaliacaoView = Bundle.main.loadNibNamed(nibName, owner: nil)![0] as! AlunoAvaliacaoView
                    alunoAvaliacaoView.delegate = self
                    alunoAvaliacaoView.totalAlunos = numeroAlunos
                    alunoAvaliacaoView.notaAluno = notaAluno
                    alunoAvaliacaoView.aluno = aluno
                    alunoAvaliacaoView.alturaConstraint.constant = scrollViewHeight
                    alunoAvaliacaoView.frame.size.height = scrollViewHeight
                    alunoAvaliacaoView.frame.size.width = screenWidth
                    alunoAvaliacaoView.frame.origin.x = screenWidth * CGFloat(i)
                    alunoAvaliacaoView.layoutIfNeeded()
                    scrollView.addSubview(alunoAvaliacaoView)
                    listaViewsAlunos.append(alunoAvaliacaoView)
                }
                i += 1
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let aluno = sender as? Aluno, segue.identifier == Constants.detalhesAlunoSegue, let detalhesAlunoViewController = segue.destination as? DetalhesAlunoController {
            detalhesAlunoViewController.aluno = aluno
        }
    }
    
    //MARK: Actions
    @IBAction fileprivate func goNext() {
        indexAlunoSelecionado += 1
        next(hasClick: true)
    }
    
    @IBAction fileprivate func goBack() {
        indexAlunoSelecionado -= 1
        back(hasClick: true)
    }
    
    @IBAction func confirmar() {
        UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.sucessoNotas.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.ok.localized, style: .default)], alvo: self)
    }
    
    fileprivate func setNextButton(isList: Bool, isHidden: Bool) {
        if isList {
            nextButton.title = Localization.listar.localized
        }
        else {
            nextButton.title = Localization.proximo.localized
        }
        nextButton.setHidden(hidden: isHidden)
    }
    
    @objc fileprivate func iniciar() {
        indexAlunoSelecionado = .zero
        tableView.isHidden = true
        scrollView.setContentOffset(.zero, animated: true)
        setupListButton(type: .vertical)
        setNextButton(isList: false, isHidden: false)
        setFinishButton(enable: false, isHidden: true)
    }
    
    @objc fileprivate func listar() {
        backButton.setHidden(hidden: true)
        setNextButton(isList: true, isHidden: true)
        setupListButton(type: .horizontal)
        var enable: Bool!
        var alunosAtivos = [Aluno]()
        for aluno in alunos {
            if aluno.alunoAtivo() {
                alunosAtivos.append(aluno)
            }
        }
        if !alunosAtivos.isEmpty, let notas = avaliacaoSelecionada?.notasAluno, notas.count == alunosAtivos.count {
            enable = true
        }
        else {
            enable = false
        }
        setFinishButton(enable: enable, isHidden: false)
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    fileprivate func back(hasClick _: Bool, isTable _: Bool = false) {
        backButton.setHidden(hidden: false)
        if indexAlunoSelecionado == .zero {
            backButton.setHidden(hidden: true)
        }
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: self.screenWidth * CGFloat(self.indexAlunoSelecionado), y: .zero), animated: true)
        }
    }
    
    fileprivate func next(hasClick: Bool, hasClickInStudent: Bool = false, isTable: Bool = false) {
        backButton.setHidden(hidden: false)
        if indexAlunoSelecionado == alunos.count - 1 {
            setNextButton(isList: true, isHidden: false)
        }
        else if indexAlunoSelecionado == alunos.count {
            listar()
        }
        if hasClick || isTable {
            if hasClickInStudent, indexAlunoSelecionado == alunos.count - 1 {
                setNextButton(isList: true, isHidden: false)
            }
            DispatchQueue.main.async {
                self.scrollView.setContentOffset(CGPoint(x: self.screenWidth * CGFloat(self.indexAlunoSelecionado), y: .zero), animated: true)
            }
        }
    }
    
    fileprivate func setFinishButton(enable: Bool, isHidden: Bool) {
        finishButton.isEnabled = enable
        finishButton.setHidden(hidden: isHidden)
        if isSyncFinished {
            finishButton.title = Localization.finalizado.localized
        }
        else {
            finishButton.title = Localization.finalizar.localized
        }
    }
    
    fileprivate func setupListButton(type: TypeListButton) {
        if type == .vertical {
            listButton = UIBarButtonItem(image: UIImage(named: Constants.listaImage), style: .plain, target: self, action: #selector(listar))
        }
        else {
            listButton = UIBarButtonItem(image: UIImage(named: Constants.carouselImage), style: .plain, target: self, action: #selector(iniciar))
        }
        navigationItem.rightBarButtonItem = listButton
    }
    
    fileprivate func getNotaAluno(alunoId: UInt32?) -> NotaAluno? {
        if let notasAluno = avaliacaoSelecionada?.notasAluno as? Set<NotaAluno> {
            for notaAluno in notasAluno {
                if notaAluno.aluno.id == alunoId {
                    return notaAluno
                }
            }
        }
        return nil
    }
    
    fileprivate func setAlunoSelecionado(index: Int?, isTable: Bool = false) {
        if let index = index {
            if index > indexAlunoSelecionado {
                indexAlunoSelecionado = index
                next(hasClick: false, isTable: isTable)
            }
            else if index < indexAlunoSelecionado {
                indexAlunoSelecionado = index
                back(hasClick: false, isTable: isTable)
            }
            if isTable && index == alunos.count - 1 {
                indexAlunoSelecionado = index
                setNextButton(isList: true, isHidden: false)
                backButton.setHidden(hidden: false)
            }
        }
    }
}

//MARK: AlunoAvaliacaoDelegate
extension NotasViewController: AlunoAvaliacaoDelegate {
    func avaliouAluno(aluno student: Aluno, view: AlunoAvaliacaoView) {
        if let nota = view.valorNotaSelecionada, let avaliacaoSelecionada = avaliacaoSelecionada {
            avaliacaoSelecionada.dataServidor = nil
            NotaAlunoDao.salvar(nota: NotaAlunoModel(nota: nota, aluno: student, avaliacao: avaliacaoSelecionada))
            CoreDataManager.sharedInstance.salvarBanco()
        }
        let numeroAlunos = alunos.count
        if indexAlunoSelecionado < numeroAlunos - 1 {
            for _ in indexAlunoSelecionado..<numeroAlunos {
                indexAlunoSelecionado += 1
                if alunos[indexAlunoSelecionado].alunoAtivo() {
                    break
                }
            }
            next(hasClick: true, hasClickInStudent: true)
        }
    }
    
    func mostrarDetalhes(aluno: Aluno) {
        performSegue(withIdentifier: Segue.DetalhesAluno.rawValue, sender: aluno)
    }
}

//MARK: UITableViewDataSource
extension NotasViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return listaViewsAlunos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: NotaTableViewCell = tableView.dequeue(index: indexPath) {
            let aluno = alunos[indexPath.row]
            cell.aluno = aluno
            cell.nota = getNotaAluno(alunoId: aluno.id)?.nota
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension NotasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isHidden = true
        backButton.setHidden(hidden: false)
        setNextButton(isList: false, isHidden: false)
        setFinishButton(enable: false, isHidden: true)
        setupListButton(type: .vertical)
        setAlunoSelecionado(index: indexPath.row, isTable: true)
    }
}
