//
//  InputView.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 02/07/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

//MARK: Protocols
protocol InputViewDelegate {
    func input(valor: String)
    func inputCancelou()
}

final class InputView: UIView {
    //MARK: Variables
    fileprivate var listaOpcoes: [String]!
    fileprivate lazy var buttonDone = UIBarButtonItem(title: Localization.ok.localized, style: .plain, target: self, action: #selector(self.prosseguir))
    fileprivate lazy var buttonCancel = UIBarButtonItem(title: Localization.cancelar.localized.uppercased(), style: .plain, target: self, action: #selector(cancelar))
    lazy var picker = UIPickerView()
    var delegate: InputViewDelegate?

    //MARK: Constructors
    init(comLista: [String], delegate: InputViewDelegate) {
        super.init(frame: CGRect(x: .zero, y: .zero, width: (delegate as? UIViewController)!.view.frame.size.width, height: 206))
        self.delegate = delegate
        listaOpcoes = comLista
        picker.frame = CGRect(x: .zero, y: 44, width: self.frame.size.width, height: 162)
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: .zero, y: .zero, width: self.frame.size.width, height: 44))
        buttonCancel.tintColor = Cores.falta2
        buttonDone.tintColor = Cores.defaultApp
        let atributos = [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)]
        buttonCancel.setTitleTextAttributes(atributos, for: .normal)
        buttonDone.setTitleTextAttributes(atributos, for: .normal)
        toolbar.setItems([self.buttonCancel, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.buttonDone], animated: false)
        addSubview(toolbar)
        addSubview(self.picker)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    //MARK: Methods
    @objc fileprivate func cancelar() {
        self.delegate?.inputCancelou()
    }

    @objc fileprivate func prosseguir() {
        self.delegate?.input(valor: self.listaOpcoes[self.picker.selectedRow(inComponent: .zero)])
    }
}

//MARK: UIPickerViewDataSource
extension InputView: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return listaOpcoes.count
    }
}

//MARK: UIPickerViewDelegate
extension InputView: UIPickerViewDelegate {
    func pickerView(_: UIPickerView, rowHeightForComponent _: Int) -> CGFloat {
        return 35
    }

    func pickerView(_: UIPickerView, widthForComponent _: Int) -> CGFloat {
        return 200
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return listaOpcoes[row]
    }

    func pickerView(_: UIPickerView, viewForRow row: Int, forComponent _: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if view == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = Cores.defaultApp
        }

        pickerLabel?.attributedText = NSAttributedString(string: listaOpcoes[row], attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white])
        pickerLabel?.textAlignment = .center
        return pickerLabel!
    }
}
