//
//  AvaliacaoLancamentoViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 24/08/15.
//  Copyright (c) 2015 Prodesp. All rights reserved.
//

import UIKit

final class NotasViewController: ViewController {
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
    fileprivate lazy var indexAlunoSelecionado: Int = 0
    fileprivate lazy var listButton = UIBarButtonItem()
    fileprivate lazy var listaAlunos = [Aluno]()
    fileprivate lazy var listaViewsAlunos = [AlunoAvaliacaoView]()
    fileprivate var isSyncFinished: Bool!
    fileprivate var diaLetivoSelecionado: DiaLetivoModel?
    fileprivate var screenWidth: CGFloat!
    var avaliacaoSelecionada: AvaliacaoModel?
    var bimestre: BimestreModel?
    var dataDeLancamento: String?
    var disciplinaSelecionada: DisciplinaModel?
    var headerTitle: String?
    var turmaSelecionada: TurmaModel?

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TitleText.AvaliacaoLancamento.rawValue.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: FontSize.size4.rawValue), NSAttributedString.Key.foregroundColor: UIColor.white]
        scrollView.bounces = true
        tableView.isHidden = true
        Requests.delegate = self
        containerHeaderView.backgroundColor = .groupTableViewBackground
        containerHeaderView.setShadow(enable: true)
        dataLancamentoLabel.text = dataDeLancamento
        backButton.title = ButtonText.Anterior.rawValue.uppercased()
        finishButton.title = ButtonText.Finish.rawValue.uppercased()
        if let nomeTurmaSerie = headerTitle, !nomeTurmaSerie.isEmpty {
            titleLabel.text = nomeTurmaSerie.uppercased()
        }
        UIViewController.showButtonItem(buttons: [finishButton, backButton], isShow: false)
        UIViewController.set(buttons: [backButton, finishButton, nextButton], font: .boldSystemFont(ofSize: FontSize.size5.rawValue))
        setupListButton(type: .vertical)
        if let dataDeLancamento = dataDeLancamento {
            diaLetivoSelecionado = DiaLetivoModel.diaLetivoNaData(data: dataDeLancamento)
        }
        if let alunos = turmaSelecionada?.turma?.alunos as? Set<Aluno> {
            listaAlunos = alunos.sorted(by: { (aluno1, aluno2) -> Bool in
                return aluno1.numeroChamada < aluno2.numeroChamada
            })
        }
        if !listaAlunos.isEmpty {
            listButton.isEnabled = true
        }
        else {
            listButton.isEnabled = false
        }
        setNextButton(isList: false, isHidden: false)
        let numeroAlunos = listaAlunos.count
        screenWidth = view.frame.width
        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(numeroAlunos), height: 0)
        scrollView.setContentOffset(.zero, animated: true)
        for view in scrollView.subviews {
            if view is AlunoAvaliacaoView {
                view.removeFromSuperview()
            }
        }
        tableView.reloadData()
        if let model = self.avaliacaoSelecionada, let serverDate = model.dataServidor, !serverDate.isEmpty,
            let notas = getNotasAlunoFromAvaliacaoSelecionada(), !notas.isEmpty {
            var alunosAtivos = 0
            for aluno in listaAlunos {
                if aluno.isActive() {
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
            var i = 0
            let numeroAlunos = listaAlunos.count
            let scrollViewHeight = scrollView.frame.height
            listaViewsAlunos.reserveCapacity(listaViewsAlunos.count)
            for aluno in listaAlunos {
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
                        nibName = XibName.AlunoAvaliacaoiPhone.rawValue
                    }
                    else {
                        nibName = XibName.AlunoAvaliacaoiPad.rawValue
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
        if let aluno = sender as? Aluno, segue.identifier == Segue.DetalhesAluno.rawValue, let detalhesAlunoViewController = segue.destination as? DetalhesAlunoController {
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
        var date: String!
        if let d = dataDeLancamento, !d.isEmpty {
            date = d
        }
        else {
            date = "---"
        }
        let sim = UIAlertAction(title: ButtonText.Yes.rawValue, style: .default) { _ in
            if Requests.isConnected() {
                var message: String?
                if let items = self.getNotasAlunoFromAvaliacaoSelecionada(), !items.isEmpty {
                    Loading.showLoading(view: self.view)
                    Requests.startSyncProcess(withType: .avaliacoes, completion: { error in
                        Loading.hideLoading(view: self.view)
                        self.showAlert(title: .Lancamento, error: error)
                    })
                }
                else {
                    message = MessageText.ErroAoTentarSincronizar.rawValue
                }
                if let message = message, !message.isEmpty {
                    self.showAlert(title: .Avaliacao, error: message)
                }
            }
            else {
                UIAlertController.createAlert(title: Localization.atencao.localized, message: Localization.avisoSemInternet.localized, style: .alert, actions: [UIAlertAction(title: ButtonText.Ok.rawValue, style: .default, handler: nil)], target: self)
            }
        }
        UIAlertController.createAlert(title: TitleText.Avaliacao.rawValue, message: "\(MessageText.AvaliacaoLancamento.rawValue) \(TitleText.Day.rawValue.lowercased()): \(date!)?", style: .alert, actions: [UIAlertAction(title: ButtonText.No.rawValue, style: .destructive, handler: nil), sim], target: self)
    }

    fileprivate func setNextButton(isList: Bool, isHidden: Bool) {
        if isList {
            nextButton.title = ButtonText.Listar.rawValue.uppercased()
        }
        else {
            nextButton.title = ButtonText.Proximo.rawValue.uppercased()
        }
        nextButton.setHidden(hidden: isHidden)
    }

    @objc fileprivate func iniciar() {
        indexAlunoSelecionado = 0
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
        let listaAlunos = self.listaAlunos.filter({ $0.ativo == TitleText.Ativo.rawValue })
        if !listaAlunos.isEmpty, let notas = getNotasAlunoFromAvaliacaoSelecionada(), !notas.isEmpty && notas.count == listaAlunos.count {
            enable = true
        } else {
            enable = false
        }
        setFinishButton(enable: enable, isHidden: false)
        tableView.isHidden = false
        tableView.startAnimation()
    }

    fileprivate func back(hasClick _: Bool, isTable _: Bool = false) {
        backButton.setHidden(hidden: false)
        if indexAlunoSelecionado == 0 {
            backButton.setHidden(hidden: true)
        }
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: self.screenWidth * CGFloat(self.indexAlunoSelecionado), y: 0), animated: true)
        }
    }

    fileprivate func next(hasClick: Bool, hasClickInStudent: Bool = false, isTable: Bool = false) {
        backButton.setHidden(hidden: false)
        if indexAlunoSelecionado == listaAlunos.count - 1 {
            setNextButton(isList: true, isHidden: false)
        }
        else if indexAlunoSelecionado == listaAlunos.count {
            listar()
        }
        if hasClick || isTable {
            if hasClickInStudent, indexAlunoSelecionado == listaAlunos.count - 1 {
                setNextButton(isList: true, isHidden: false)
            }
            DispatchQueue.main.async {
                self.scrollView.setContentOffset(CGPoint(x: self.screenWidth * CGFloat(self.indexAlunoSelecionado), y: 0), animated: true)
            }
        }
    }

    fileprivate func setFinishButton(enable: Bool, isHidden: Bool) {
        finishButton.isEnabled = enable
        finishButton.setHidden(hidden: isHidden)
        if isSyncFinished {
            finishButton.title = ButtonText.Finished.rawValue.uppercased()
        }
        else {
            finishButton.title = ButtonText.Finish.rawValue.uppercased()
        }
    }

    fileprivate func setupListButton(type: TypeListButton) {
        listButton.tag = type.rawValue
        if type == .vertical {
            listButton = UIBarButtonItem(image: UIImage(named: Image.Lista.rawValue), style: .plain, target: self, action: #selector(listar))
        }
        else {
            listButton = UIBarButtonItem(image: UIImage(named: Image.Carousel.rawValue), style: .plain, target: self, action: #selector(iniciar))
        }
        navigationItem.rightBarButtonItem = listButton
    }

    fileprivate func getNotaAluno(alunoId: UInt32?) -> NotaAluno? {
        if let notasAluno = avaliacaoSelecionada?.avaliacao?.notasAluno as? Set<NotaAluno> {
            for notaAluno in notasAluno {
                if notaAluno.aluno.id == alunoId {
                    return notaAluno
                }
            }
        }
        return nil
    }

    fileprivate func getNotasAlunoFromAvaliacaoSelecionada() -> [NotaAluno]? {
        var result = [NotaAluno]()
        if let avaliacaoModel = avaliacaoSelecionada, let data = avaliacaoModel.avaliacao?.notasAluno.allObjects as? [NotaAluno] {
            result = data
        }
        if !result.isEmpty {
            return result
        }
        return nil
    }

    fileprivate func showAlert(title: TitleText, error: String?, completion: (() -> Void)? = nil) {
        var message: String!
        var action: UIAlertAction!
        if let error = error, !error.isEmpty {
            message = error
            action = UIAlertAction(title: ButtonText.Ok.rawValue, style: .destructive, handler: nil)
        }
        else {
            message = MessageText.RealizadoComSucesso.rawValue
            action = UIAlertAction(title: ButtonText.Ok.rawValue, style: .default, handler: { _ in
                if let completion = completion {
                    completion()
                }
            })
        }
        UIAlertController.createAlert(title: title.rawValue, message: message, style: .alert, actions: [action], target: self)
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
            if isTable && index == listaAlunos.count - 1 {
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
        if let nota = view.valorNotaSelecionada, let avaliacao = avaliacaoSelecionada?.avaliacao {
            avaliacao.dataServidor = nil
            avaliacaoSelecionada?.dataServidor = nil
            NotaAlunoModel.salvarDadosNotaAluno(objeto: NotaAlunoModel(nota: nota, aluno: student, avaliacao: avaliacao))
            CoreDataManager.sharedInstance.saveContext()
        }
        let numeroAlunos = listaAlunos.count
        if indexAlunoSelecionado < numeroAlunos - 1 {
            for _ in indexAlunoSelecionado..<numeroAlunos {
                indexAlunoSelecionado += 1
                if listaAlunos[indexAlunoSelecionado].isActive() {
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

//MARK: RequestsDelegate
extension NotasViewController: RequestsDelegate {
    func finishSyncProccess(sent _: Bool) -> UIViewController? {
        return self
    }
}

//MARK: UITableViewDataSource
extension NotasViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return listaViewsAlunos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: NotaTableViewCell = tableView.dequeue(index: indexPath) {
            let aluno = listaAlunos[indexPath.row]
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
