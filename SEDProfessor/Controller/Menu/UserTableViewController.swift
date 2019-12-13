//
//  UserTableViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 10/11/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class UserTableViewController: UITableViewController {
    //MARK: Outlets
    @IBOutlet fileprivate var nomeLabel: UILabel!
    @IBOutlet fileprivate var usuarioLabel: UILabel!
    @IBOutlet fileprivate var rgLabel: UILabel!
    @IBOutlet fileprivate var cpfLabel: UILabel!
    @IBOutlet fileprivate var ultimoAcessoLabel: UILabel!
    @IBOutlet fileprivate var numeroTurmasLabel: UILabel!
    @IBOutlet fileprivate var doneButton: UIBarButtonItem!
    @IBOutlet fileprivate var imageView: UIImageView!

    //MARK: Constants
    fileprivate struct Constants {
        static let boldSystemFontSize: CGFloat = 15
        static let systemFontSize: CGFloat = 12
    }

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.professor.localized
        doneButton.title = Localization.ok.localized.capitalized
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: Constants.boldSystemFontSize)], for: .normal)
        if let usuario = LoginRequest.usuarioLogado {
            nomeLabel.text = usuario.nome.uppercased()
            usuarioLabel.text = usuario.usuario.lowercased()
            let rg = Localization.rg.localized
            rgLabel.text = rg + " " + usuario.rg + "-" + usuario.digitoRG
            UILabel.configure(label: rgLabel, font: .systemFont(ofSize: Constants.systemFontSize), color: .black, custom: (rg, .after))
            let cpf = Localization.cpf.localized
            cpfLabel.text = cpf + " " + usuario.cpf
            UILabel.configure(label: cpfLabel, font: .systemFont(ofSize: Constants.systemFontSize), color: .black, custom: (cpf, .after))
            let lastAccess = Localization.ultimoAcessso.localized
            ultimoAcessoLabel.text = lastAccess + " " + usuario.dataUltimoAcesso
            UILabel.configure(label: ultimoAcessoLabel, font: .systemFont(ofSize: Constants.systemFontSize), color: .black, custom: (lastAccess, .after))
            let totalTurmas = Localization.numeroDeTurmas.localized
            numeroTurmasLabel.text = totalTurmas + " " + String(TurmaDao.numeroDeTurmas())
            UILabel.configure(label: numeroTurmasLabel, font: .systemFont(ofSize: Constants.systemFontSize), color: .black, custom: (totalTurmas, .after))
        }
        tableView.reloadData()
    }

    //MARK: Actions
    @IBAction fileprivate func sair() {
        dismiss(animated: true, completion: nil)
    }
}
