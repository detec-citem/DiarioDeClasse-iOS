//
//  CalendarioViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 02/10/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import FSCalendar
import UIKit

class CalendarioViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let mesAno = "MMMM yyyy"
        static let ptBr = "pt-BR"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var calendarioView: UIView!
    
    //MARK: Variables
    fileprivate lazy var primeiraVez = true
    fileprivate lazy var datasAula = Set<Date>()
    fileprivate var dataMinima: Date!
    fileprivate var calendario: FSCalendar!
    weak var delegate: CalendarioDelegate!
    var bimestreAtual: Bimestre!
    var turmaSelecionada: Turma!
    var calendarioLetivo: [DiaLetivo]!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if TipoFechamentoBimestreDao.getFechamentoAtual() != nil {
            var codigoBimestre = bimestreAtual.id
            if codigoBimestre == 1 {
                codigoBimestre = 4
            }
            else {
                codigoBimestre -= 1
            }
            if let diasLetivos = DiaLetivoDao.diaLetivosDaTurmaNoBimestre(codigoBimestre: codigoBimestre, turma: turmaSelecionada) {
                for diaLetivo in diasLetivos {
                    calendarioLetivo.append(diaLetivo)
                }
            }
        }
        if !calendarioLetivo.isEmpty {
            calendarioLetivo.sort(by: { (diaLetivo1, diaLetivo2) -> Bool in
                return DateFormatter.dataDateFormatter.date(from: diaLetivo1.dataAula)! < DateFormatter.dataDateFormatter.date(from: diaLetivo2.dataAula)!
            })
            if let primeiraDataString = calendarioLetivo.first?.dataAula, let primeiraData = DateFormatter.dataDateFormatter.date(from: primeiraDataString) {
                dataMinima = primeiraData
            }
            if (dataMinima < Date()) {
                for diaLetivo in calendarioLetivo {
                    if let diaLetivo = DateFormatter.dataDateFormatter.date(from: diaLetivo.dataAula) {
                        datasAula.insert(diaLetivo)
                    }
                }
            }
            else {
                let ok = UIAlertAction(title: Localization.ok.localized, style: .cancel, handler: { _ in
                    self.dismiss(animated: true, completion: {
                        self.delegate.cancelouSelecao()
                    })
                })
                UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.frequenciaPeriodoNaoLetivo.localized, estilo: .alert, acoes: [ok], alvo: self)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if primeiraVez {
            primeiraVez = false
            calendario = FSCalendar(frame: CGRect(x: .zero, y: .zero, width: calendarioView.frame.width, height: calendarioView.frame.height))
            calendario.backgroundColor = .clear
            calendario.dataSource = self
            calendario.delegate = self
            calendario.locale = Locale(identifier: Constants.ptBr)
            calendario.swipeToChooseGesture.isEnabled = true
            let calendarAppeareance = calendario.appearance
            calendarAppeareance.headerMinimumDissolvedAlpha = .zero
            calendarAppeareance.borderDefaultColor = .groupTableViewBackground
            calendarAppeareance.eventDefaultColor = Cores.itemsToSync
            calendarAppeareance.headerDateFormat = Constants.mesAno
            calendarAppeareance.headerTitleColor = Cores.aplicativo
            calendarAppeareance.selectionColor = .white
            calendarAppeareance.titleTodayColor = .black
            calendarAppeareance.todayColor = Cores.itemsToSync
            calendarAppeareance.weekdayTextColor = .white
            calendarAppeareance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]
            calendario.reloadData()
            calendario.setCurrentPage(Date(), animated: false)
            calendarioView.addSubview(calendario)
        }
    }
    
    //MARK: Actions
    @IBAction func sair(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate.cancelouSelecao()
        }
    }
    
    //MARK: Methods
    fileprivate func dataDesabilitada(data: Date) -> Bool {
        return data > Date() || !datasAula.contains(data) || Calendar.current.component(.month, from: data) != Calendar.current.component(.month, from: calendario.currentPage)
    }
    
    fileprivate func corDoTitulo(data: Date) -> UIColor? {
        if dataDesabilitada(data: data) {
            return .gray
        }
        if Calendar.current.isDateInToday(data) {
            return nil
        }
        if delegate.temLancamentoNaData(data: data) {
            return Cores.tituloDiaComLancamento
        }
        return Cores.tituloPadrao
    }
    
    fileprivate func fillColor(date: Date) -> UIColor {
        if dataDesabilitada(data: date) {
             return .lightGray
         }
         if Calendar.current.isDateInToday(date) {
             return Cores.itemsToSync
         }
         if delegate.temLancamentoNaData(data: date) {
             return Cores.fundoDiaComLancamento
         }
        return Cores.fundoPadrao
    }
}

//MARK: FSCalendarDataSource
extension CalendarioViewController: FSCalendarDataSource {
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return dataMinima
    }
}

//MARK: FSCalendarDelegate
extension CalendarioViewController: FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.bounds = bounds
        calendar.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if date > Date() {
            UIAlertController.criarAlerta(titulo: Localization.atencao.localized, mensagem: Localization.datasFuturas.localized, estilo: .alert, alvo: self)
            return
        }
        var diaLetivoSelecionado: DiaLetivo!
        if let calendarioLetivo = calendarioLetivo {
            let dateString = DateFormatter.dataDateFormatter.string(from: date)
            for diaLetivo in calendarioLetivo {
                if diaLetivo.dataAula == dateString {
                    diaLetivoSelecionado = diaLetivo
                    break
                }
            }
        }
        if delegate.podeSelecionar(diaLetivo: diaLetivoSelecionado) {
            dismiss(animated: true, completion: {
                self.delegate.selecionouDiaLetivo(data: date, diaLetivo: diaLetivoSelecionado)
            })
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if dataDesabilitada(data: date) {
            return false
        }
        return true
    }
}

//MARK: FSCalendarDelegateAppearance
extension CalendarioViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
         return fillColor(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return fillColor(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return corDoTitulo(data: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return corDoTitulo(data: date)
    }
}
