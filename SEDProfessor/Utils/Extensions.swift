//  Extensions.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 31/07/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.

import UIKit
import MZFormSheetPresentationController

extension CGFloat {
    func getPercent(number: CGFloat, from: CGFloat) -> CGFloat {
        return number * from / 100
    }
}

extension Collection {
    func removeDuplicates(bykey: String) -> [[String: Any]]? {
        var result = [[String: Any]]()
        let array = self as? [[String: Any]]

        if let array = array, !array.isEmpty {
            let arrayCount = array.count
            for i in 0 ..< arrayCount {
                if let id = array[i][bykey] as? Int {
                    if i == 0 {
                        result = [[String: Any]]()
                    }
                    if result.filter({ $0[bykey] as? Int == id }).isEmpty {
                        result.append(array[i])
                    }
                }
                else if let id = array[i][bykey] as? String {
                    if i == 0 {
                        result = [[String: Any]]()
                    }
                    if result.filter({ $0[bykey] as? String == id }).isEmpty {
                        result.append(array[i])
                    }
                }
                else {
                    break
                }
            }
        }
        if !result.isEmpty {
            return result
        }
        return nil
    }
}

extension Date {
    static func getNumValuesFromDate(date: Date) -> (dia: Int, mes: Int, ano: Int, diaDaSemana: Int) {
        let components = Calendar.current.dateComponents([.day, .month, .year, .weekday], from: date)
        return (components.day!, components.month!, components.year!, components.weekday!)
    }
    
    func comecoDoDia() -> Date {
        let calendario = Calendar.current
        var componentesDaData = calendario.dateComponents([.day, .month, .year, .hour, .minute, .second, .nanosecond], from: self)
        componentesDaData.hour = .zero
        componentesDaData.minute = .zero
        componentesDaData.second = .zero
        return calendario.date(from: componentesDaData)!
    }
}

extension DateFormatter {
    static let dataDateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()
    
    static let isoDataHorarioFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
    
    static let isoDataFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    static let horarioFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
}

extension Float {
    func roundToDecimal(digits: Int) -> Float {
        let multiplier = pow(10, Float(digits))
        return Float(Darwin.round(self * Float(multiplier))) / multiplier
    }
}

extension Int {
    /// Use this function to create a unique id (Int).
    ///
    /// - Parameters:
    ///   - data: The array with another data if existed.
    ///   - key: The key of the id
    ///   - initialNumber: The number that you want to start. The default is 20
    /// - Returns: The new id result (Int)
    static func generateUniqueId(data: [[String: Any]]?, key: String?, initialNumber: UInt32 = 20, unique: UInt32 = .zero) -> UInt32 {
        var unique = unique

        if let data = data, !data.isEmpty {
            var e = Set<UInt32>()
            unique += 1

            for obj in data {
                if let key = key, let value = obj[key] as? UInt32 {
                    e.insert(value)
                }
            }

            if e.count < 1 {
                unique = initialNumber
            }
            else if e.contains(unique) || unique < initialNumber {
                unique = generateUniqueId(data: data, key: key, initialNumber: initialNumber, unique: unique)
            }
        }
        else {
            unique = initialNumber
        }
        return unique
    }
}

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

extension String {
    var base64Decoded: String? {
        if let data = Data(base64Encoded: self, options: .init(rawValue: .zero)) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    var base64Encoded: String? {
        let data = self.data(using: .utf8)
        return data?.base64EncodedString(options: .init(rawValue: .zero))
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

extension UIAlertController {
    static func criarAlerta(titulo: String? = nil, mensagem: String? = nil, estilo: UIAlertController.Style, acoes: [UIAlertAction]? = nil, alvo: AnyObject?, popover: Bool = false, botaoPopover: UIBarButtonItem? = nil) {
        let alert = UIAlertController(title: titulo, message: mensagem, preferredStyle: estilo)
        if let actions = acoes {
            for action in actions {
                alert.addAction(action)
            }
        }
        else {
            let ok = UIAlertAction(title: Localization.ok.localized, style: .default)
            alert.addAction(ok)
        }
        if popover {
            alert.modalPresentationStyle = .popover
            let popover = alert.popoverPresentationController!
            popover.barButtonItem = botaoPopover
            popover.sourceRect = CGRect(x: .zero, y: 10, width: .zero, height: .zero)
            popover.backgroundColor = .white
        }
        DispatchQueue.main.async {
            alvo?.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIBarButtonItem {
    func setHidden(hidden: Bool) {
        if hidden {
            isEnabled = false
            tintColor = .clear
        }
        else {
            isEnabled = true
            tintColor = Cores.defaultApp
        }
    }

    func setFont(font: UIFont) {
        setTitleTextAttributes([.font: font], for: .normal)
    }
}

extension UICollectionView {
    func dequeue<T: UICollectionViewCell>(index: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: T.className, for: index) as? T
    }
}

extension UICollectionViewCell {
    class func register(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: className, bundle: nil), forCellWithReuseIdentifier: className)
    }
}

extension UILabel {
    static func configure(labels: [UILabel?]? = nil, label: UILabel? = nil, font: UIFont? = nil, color: UIColor? = nil, custom: (text: String, textPosition: TextPosition)? = nil) {
        if let labels = labels, labels.isEmpty == false {
            for label in labels {
                if let label = label {
                    if let custom = custom {
                        setup(color: color, font: font, position: custom.textPosition, text: custom.text, label: label)
                    }
                    else {
                        label.font = font
                        label.textColor = color
                    }
                }
            }
        }

        if let label = label, let custom = custom {
            setup(color: color, font: font, position: custom.textPosition, text: custom.text, label: label)
        }
    }

    func setFont(font: UIFont, to: String) {
        setFont(font: font, range: rangeTo(string: to))
    }

    func setTextColor(color: UIColor, after: String) {
        setTextColor(color: color, range: rangeAfter(string: after))
    }

    func setTextColor(color: UIColor, to: String) {
        setTextColor(color: color, range: rangeTo(string: to))
    }

    fileprivate func mutableAttributedString() -> NSMutableAttributedString {
        if attributedText != nil {
            return NSMutableAttributedString(attributedString: attributedText!)
        }
        else {
            return NSMutableAttributedString(string: text ?? "")
        }
    }

    fileprivate func rangeAfter(string: String) -> NSRange? {
        guard var range = rangeOf(string: string) else { return nil }
        range.location = range.location + range.length
        range.length = text!.count - range.location
        return range
    }

    fileprivate func rangeBefore(string: String) -> NSRange? {
        guard var range = rangeOf(string: string) else { return nil }
        range.length = range.location
        range.location = .zero
        return range
    }

    fileprivate func rangeFrom(string: String) -> NSRange? {
        guard var range = rangeOf(string: string) else { return nil }
        range.length = text!.count - range.location
        return range
    }

    fileprivate func rangeOf(string: String) -> NSRange? {
        let range = NSString(string: text ?? "").range(of: string)
        return range.location != NSNotFound ? range : nil
    }

    fileprivate func rangeTo(string: String) -> NSRange? {
        guard var range = rangeOf(string: string) else { return nil }
        range.length = range.location + range.length
        range.location = .zero
        return range
    }

    fileprivate func setFont(font: UIFont, after: String) {
        setFont(font: font, range: rangeAfter(string: after))
    }

    fileprivate func setFont(font: UIFont, before: String) {
        setFont(font: font, range: rangeBefore(string: before))
    }

    fileprivate func setFont(font: UIFont, from: String) {
        setFont(font: font, range: rangeFrom(string: from))
    }

    fileprivate func setFont(font: UIFont, range: NSRange?) {
        guard let range = range else { return }
        let text = mutableAttributedString()
        text.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attributedText = text
    }

    fileprivate func setTextColor(color: UIColor, before: String) {
        setTextColor(color: color, range: rangeBefore(string: before))
    }

    fileprivate func setTextColor(color: UIColor, from: String) {
        setTextColor(color: color, range: rangeFrom(string: from))
    }

    fileprivate func setTextColor(color: UIColor, range: NSRange?) {
        guard let range = range else { return }
        let text = mutableAttributedString()
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributedText = text
    }

    fileprivate static func setup(color: UIColor? = nil, font: UIFont? = nil, position: TextPosition, text: String, label: UILabel) {
        var rColor: UIColor!
        var rFont: UIFont!

        if let color = color {
            rColor = color
        }

        if let font = font {
            rFont = font
        }

        switch position {
        case .after:
            label.setFont(font: rFont, after: text)
            label.setTextColor(color: rColor, after: text)
        case .before:
            label.setFont(font: rFont, before: text)
            label.setTextColor(color: rColor, before: text)
        case .from:
            label.setFont(font: rFont, from: text)
            label.setTextColor(color: rColor, from: text)
        case .to:
            label.setFont(font: rFont, to: text)
            label.setTextColor(color: rColor, to: text)
        }
    }
}

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T? {
        return instantiateViewController(withIdentifier: T.className) as? T
    }
}

extension UITableView {
    func dequeue<T: UITableViewCell>(index: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: T.className, for: index) as? T
    }

    func tableViewScrollToTop(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.scrollToRow(at: IndexPath(row: .zero, section: .zero), at: .top, animated: animated)
        }
    }
}

extension UITableViewCell {
    class func register(_ tableView: UITableView) {
        tableView.register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: className)
    }
}

extension UIView {
    func setShadow(enable: Bool, shadowOffset: CGSize = .zero, shadowColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), shadowRadius: CGFloat = 4, shadowOpacity: Float = 0.25, masksToBounds: Bool = false, clipsToBounds: Bool = false) {
        if enable {
            layer.shadowOffset = shadowOffset
            layer.shadowColor = shadowColor.cgColor
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = shadowOpacity
            layer.masksToBounds = masksToBounds
            self.clipsToBounds = clipsToBounds
        }
        else {
            layer.shadowOffset = .zero
            layer.shadowColor = UIColor.clear.cgColor
            layer.shadowRadius = .zero
            layer.shadowOpacity = .zero
        }
    }
}

extension UIViewController {
    static func hideKeyboard(fields: [UIView]) {
        for field in fields {
            if let textField = field as? UITextField {
                textField.resignFirstResponder()
            }
            else if let textView = field as? UITextView {
                textView.resignFirstResponder()
            }
        }
    }
    
    func presentFormSheetViewController(viewController: UIViewController, completion: (() -> Void)? = nil) {
        var size: CGSize!
        let sizeWindow = UIApplication.shared.keyWindow!.frame.size
        let width = sizeWindow.width
        let height = sizeWindow.height
        var topSet = CGFloat(33)
        if UIDevice.current.userInterfaceIdiom == .pad {
            size = CGSize(width: width * 0.65, height: height * 0.6)
            topSet *= 3
        }
        else {
            size = CGSize(width: width * 0.86, height: height * 0.83)
        }
        let sheetViewController = MZFormSheetPresentationViewController(contentViewController: viewController)
        sheetViewController.contentViewControllerTransitionStyle = .slideAndBounceFromBottom
        let presentationController = sheetViewController.presentationController
        presentationController?.contentViewSize = size
        presentationController?.portraitTopInset = topSet
        presentationController?.landscapeTopInset = topSet
        present(sheetViewController, animated: true, completion: completion)
    }

    static func set(buttons: [Any?], font: UIFont? = nil, color: UIColor? = nil) {
        for button in buttons {
            if let button = button as? UIBarButtonItem {
                if let font = font {
                    button.setFont(font: font)
                }
                if let color = color {
                    button.tintColor = color
                }
            }
            else if let button = button as? UIButton {
                if let font = font {
                    button.titleLabel?.font = font
                }
                if let color = color {
                    button.setTitleColor(color, for: .normal)
                }
            }
        }
    }

    static func showButtonItem(buttons: [UIBarButtonItem], isShow: Bool) {
        if !buttons.isEmpty {
            for button in buttons {
                if isShow {
                    button.isEnabled = true
                    button.tintColor = Cores.defaultApp
                }
                else {
                    button.isEnabled = false
                    button.tintColor = .clear
                }
            }
        }
    }
}
