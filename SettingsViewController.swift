//
//  SettingsViewController.swift
//  Bundle.Sandbox.FileManager.HomeWork
//
//  Created by Sergey on 10.05.2024.
//

import UIKit
import KeychainAccess

enum Sorting: String {
    case notSorted
    case sortedUpper
    case soertedLower
}

final class SettingsViewController: UIViewController {

    private var keyChain: Keychain = Keychain()
    var sortingEnum = Sorting.notSorted

    private lazy var infoView: UIView = {
        let infoView = UIView()
        
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 0.2)
        infoView.layer.borderColor = UIColor(named: "black")?.cgColor
        infoView.layer.cornerRadius = 10.0
        infoView.layer.borderWidth = 0.5
        
        return infoView
    }()

    private lazy var alphabeticalText: UILabel = {
        let alphabeticalText = UILabel()
        
        alphabeticalText.translatesAutoresizingMaskIntoConstraints = false
        alphabeticalText.text = "Алфавитный порядок"
        alphabeticalText.font = UIFont.systemFont(ofSize: 9)
        alphabeticalText.textColor = .black
        
        return alphabeticalText
    }()

    private lazy var backwardSortText: UILabel = {
        let backwardSortText = UILabel()
        
        backwardSortText.translatesAutoresizingMaskIntoConstraints = false
        backwardSortText.text = "Обратный порядок"
        backwardSortText.font = UIFont.systemFont(ofSize: 9)
        backwardSortText.textColor = .black
        
        return backwardSortText
    }()

    private lazy var alphabeticalSort: UIButton = {
        let infoButton = UIButton(type: .system)
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.layer.borderColor = UIColor(named: "blue")?.cgColor
        infoButton.layer.borderWidth = 1.0
        infoButton.layer.cornerRadius = 10.0
        infoButton.addTarget(self, action: #selector(alphabeticalSortButtonTapped(_:)), for: .touchUpInside)
        
        return infoButton
    }()

    private lazy var sortBackWard: UIButton = {
        let infoButton = UIButton(type: .system)
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.layer.borderColor = UIColor(named: "blue")?.cgColor
        infoButton.layer.borderWidth = 1.0
        infoButton.layer.cornerRadius = 10.0
        infoButton.addTarget(self, action: #selector(backwardSortButtonTapped), for: .touchUpInside)
        
        return infoButton
    }()

    private lazy var changePassButton = {
        let changePassButton = UIButton(type: .system)
        
        changePassButton.translatesAutoresizingMaskIntoConstraints = false
        changePassButton.backgroundColor = .systemBlue
        changePassButton.setTitle("Change Password", for: .normal)
        changePassButton.setTitleColor(.white, for: .normal)
        changePassButton.layer.cornerRadius = 8.0
        changePassButton.addTarget(self, action: #selector(changePassButtonTapped(_:)), for: .touchUpInside)
        
        return changePassButton
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(filterButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
    }

    private func layout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(changePassButton)
        
        NSLayoutConstraint.activate( [
            changePassButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            changePassButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }

    private func updateLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(infoView)
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 5),
            infoView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -5),
            infoView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    private func updateButton() {
        
        infoView.addSubview(alphabeticalSort)
        infoView.addSubview(sortBackWard)
        infoView.addSubview(alphabeticalText)
        infoView.addSubview(backwardSortText)
        
        NSLayoutConstraint.activate([
            alphabeticalText.topAnchor.constraint(equalTo: alphabeticalSort.topAnchor),
            alphabeticalText.leadingAnchor.constraint(equalTo: alphabeticalSort.trailingAnchor, constant: 10),
            alphabeticalText.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -5),
            alphabeticalText.heightAnchor.constraint(equalToConstant: 25),

            alphabeticalSort.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 10),
            alphabeticalSort.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 10),
            alphabeticalSort.heightAnchor.constraint(equalToConstant: 25),
            alphabeticalSort.widthAnchor.constraint(equalToConstant: 25),

            backwardSortText.leadingAnchor.constraint(equalTo: sortBackWard.trailingAnchor, constant: 10),
            backwardSortText.topAnchor.constraint(equalTo: sortBackWard.topAnchor),
            backwardSortText.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -5),
            backwardSortText.heightAnchor.constraint(equalToConstant: 25),

            sortBackWard.topAnchor.constraint(equalTo: alphabeticalSort.bottomAnchor, constant: 10),
            sortBackWard.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 10),
            sortBackWard.heightAnchor.constraint(equalToConstant: 25),
            sortBackWard.widthAnchor.constraint(equalToConstant: 25)
        ])
    }


    @objc func filterButtonTapped() {
        updateLayout()
        updateButton()
    }

    @objc func alphabeticalSortButtonTapped(_ sender: UIButton) {
            alphabeticalSort.backgroundColor = .blue
            alphabeticalSort.setImage(UIImage(systemName: "checkmark"), for: .normal)
            alphabeticalSort.tintColor = .white
        sortingEnum = .sortedUpper
        UserDefaults.standard.set(sortingEnum.rawValue, forKey: "sorted")
        if sortBackWard.isEnabled {
            sortBackWard.backgroundColor = .clear
        }
        infoView.removeFromSuperview()
    }

    @objc func backwardSortButtonTapped() {
            sortBackWard.backgroundColor = .blue
            sortBackWard.setImage(UIImage(systemName: "checkmark"), for: .normal)
            sortBackWard.tintColor = .white
        sortingEnum = .soertedLower
        UserDefaults.standard.set(sortingEnum.rawValue, forKey: "sorted")
        if alphabeticalSort.isEnabled {
            alphabeticalSort.backgroundColor = .clear
        }
        infoView.removeFromSuperview()
    }

    @objc func changePassButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Введите новый пароль", message: "Минимум 4 цифры", preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "Введите новый пароль"
            textfield.borderStyle = .roundedRect
        }
        let createAction = UIAlertAction(title: "Обновить", style: .destructive) { [weak self] action in
            guard let self else { return }
            if self.validate(pass: (alert.textFields?.first?.text)!) {
                let secondAlert = UIAlertController(title: "Невозможно создать", message: "Минимальное кол-во символов - 4", preferredStyle: .alert)
                let secondAction = UIAlertAction(title: "Отмена", style: .destructive)
                secondAlert.addAction(secondAction)
                self.present(secondAlert, animated: true)
            } else {
                do {
                    try self.keyChain.set((alert.textFields?.first?.text)!, key: "newUser")
                    self.dismiss(animated: true)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func validate(pass: String) -> Bool {
        let minimumNumberOFchcarcters = 4
       return  pass.count < minimumNumberOFchcarcters ?  true : false
    }
}
