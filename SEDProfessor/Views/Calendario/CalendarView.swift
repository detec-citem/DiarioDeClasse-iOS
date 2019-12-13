//
//  Calendar.swift
//  Calendar
//
//  Created by Victor Bozelli Alvarez on 30/05/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit
import FSCalendar

//MARK: Protocols
protocol CalendarioViewDelegate: class {
    func maximumDate() -> Date
    func minimumDate() -> Date
    func calendarDidSelect(date: Date)
    func fillDefaultColorFor(date: Date) -> UIColor?
    func shouldSelectDate(date: Date) -> Bool
    func titleDefaultColorFor(date: Date) -> UIColor?
    func calendarWillDisapear(calendar: CalendarioView)
}

final class CalendarioView: NSObject {
    //MARK: Singleton
    static var sharedInstance = CalendarioView()
    
    //MARK: Variables
    fileprivate var adicionouSubviews = false
    fileprivate var calendar: FSCalendar!
    fileprivate var calendarBackground: UIView!
    weak var delegate: CalendarioViewDelegate?
    var datasComAula: [String]?
    
    //MARK: Constructor
    fileprivate override init() {
        super.init()
        if UIDevice.current.userInterfaceIdiom == .pad {
            NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    //MARK: Destructor
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    func mesSelecionado() -> Int {
        return Calendar.current.component(.month, from: CalendarioView.sharedInstance.calendar.currentPage)
    }
    
    func mostrarCalendario() {
        let keyWindow = UIApplication.shared.keyWindow!
        if !adicionouSubviews {
            adicionouSubviews = true
            let percentage = CGFloat(keyWindow.frame.size.width / 100.0)
            if UIDevice.current.userInterfaceIdiom == .phone {
                calendar = FSCalendar(frame: CGRect(x: 10 * percentage, y: 60, width: 80 * percentage, height: 75 * percentage))
            }
            else {
                calendar = FSCalendar(frame: CGRect(x: 10 * percentage, y: 60, width: 74 * percentage, height: 50 * percentage))
            }
            calendarBackground = UIView();
            calendarBackground.isUserInteractionEnabled = true
            calendarBackground.backgroundColor = UIColor(white: 0.3, alpha: 0.6)
            let recognizer = UITapGestureRecognizer()
            recognizer.addTarget(self, action: #selector(hideCalendar))
            calendarBackground.addGestureRecognizer(recognizer)
            calendar.clipsToBounds = true
            calendar.layer.cornerRadius = 5.0
            calendar.backgroundColor = .white
            calendar.dataSource = self
            calendar.delegate = self
            calendar.locale = Locale(identifier: "pt-BR")
            calendar.swipeToChooseGesture.isEnabled = true
            let calendarAppeareance = calendar.appearance
            calendarAppeareance.headerMinimumDissolvedAlpha = .zero
            calendarAppeareance.borderDefaultColor = .groupTableViewBackground
            calendarAppeareance.weekdayTextColor = .black
            calendarAppeareance.headerTitleFont = .boldSystemFont(ofSize: 16)
            calendarAppeareance.headerTitleColor = Cores.aplicativo
            calendarAppeareance.selectionColor = .white
            calendarAppeareance.todayColor = Cores.itemsToSync
            calendarAppeareance.headerDateFormat = "MMMM yyyy"
            calendarAppeareance.titleFont = .systemFont(ofSize: 14)
            calendarAppeareance.eventDefaultColor = Cores.itemsToSync
            calendarAppeareance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
            DispatchQueue.main.async {
                keyWindow.addSubview(self.calendarBackground)
                keyWindow.addSubview(self.calendar)
            }
        }
        else {
            calendar.isHidden = false
            calendarBackground.isHidden = false
        }
        calendarBackground.bounds = keyWindow.bounds
        let keyWindowCenter = keyWindow.center
        calendar.center = keyWindowCenter
        calendarBackground.center = keyWindowCenter
        calendar.reloadData()
    }
    
    @objc func hideCalendar() {
        calendar?.isHidden = true
        calendarBackground?.isHidden = true
        delegate?.calendarWillDisapear(calendar: self)
    }
    
    @objc fileprivate func deviceRotated() {
        let keyWindow = UIApplication.shared.keyWindow!
        calendarBackground?.bounds = keyWindow.bounds
        let keyWindowCenter = keyWindow.center
        calendar?.center = keyWindowCenter
        calendarBackground?.center = keyWindowCenter
    }
}

//MARK: FSCalendarDataSource
extension CalendarioView: FSCalendarDataSource {
    func maximumDate(for calendar: FSCalendar) -> Date {
        if let dataMaxima = delegate?.maximumDate() {
            return dataMaxima
        }
        return Date()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        if let dataMinima = delegate?.minimumDate() {
            return dataMinima
        }
        return Date()
    }
}

//MARK: FSCalendarDelegate
extension CalendarioView: FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.bounds = bounds
        calendar.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        delegate?.calendarDidSelect(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if let shouldSelectDate = delegate?.shouldSelectDate(date: date) {
            return shouldSelectDate
        }
        return false
    }
}

//MARK: FSCalendarDelegateAppearance
extension CalendarioView: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
         return delegate?.fillDefaultColorFor(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return delegate?.fillDefaultColorFor(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return delegate?.titleDefaultColorFor(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return delegate?.titleDefaultColorFor(date: date)
    }
}
