//
//  LoginViewController.swift
//  Bundle.Sandbox.FileManager.HomeWork
//
//  Created by Sergey on 10.05.2024.
//


import UIKit
import KeychainAccess

final class LoginViewController: UIViewController {

    private let keyChain: Keychain = Keychain()
    private var savedPass: String?

    private lazy var infoText: UILabel = {
        let infoText = UILabel()
        
        infoText.font = UIFont.boldSystemFont(ofSize: 13)
        infoText.translatesAutoresizingMaskIntoConstraints = false
        
        return infoText
    }()

    private lazy var passTextField: UITextField = {
        let passTextField = UITextField()
        
        passTextField.layer.borderWidth = 0.5
        passTextField.layer.borderColor = UIColor.black.cgColor
        passTextField.layer.cornerRadius = 8.0
        passTextField.delegate = self
        passTextField.placeholder = "Enter Password"
        passTextField.textAlignment = .center
        passTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return passTextField
    }()

    private lazy var loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        
        loginButton.setTitle("LogIn", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8.0
        loginButton.backgroundColor = .systemBlue
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
        checkButton()
    }

    private func layout() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(passTextField)
        view.addSubview(loginButton)
        view.addSubview(infoText)
        
        NSLayoutConstraint.activate([

            infoText.bottomAnchor.constraint(equalTo: passTextField.topAnchor, constant: -15),
            infoText.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            infoText.heightAnchor.constraint(equalToConstant: 44),

            passTextField.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            passTextField.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            passTextField.heightAnchor.constraint(equalToConstant: 44),
            passTextField.widthAnchor.constraint(equalToConstant: 180),

            loginButton.topAnchor.constraint(equalTo: passTextField.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            loginButton.widthAnchor.constraint(equalToConstant: 180)
        ])
    }

    private func createNavigation() -> [UINavigationController] {

        let fileService = FilemanagerService()
        let documentsVC = ViewController(fileService: fileService)
        let documentsNavigationVC = UINavigationController(rootViewController: documentsVC)
        documentsNavigationVC.tabBarItem = UITabBarItem(title: "Documents", image: UIImage(systemName: "doc.on.doc"), tag: 0)

        let settingsVC = SettingsViewController()
        let settingsNavigationVC = UINavigationController(rootViewController: settingsVC)
        settingsNavigationVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        return [documentsNavigationVC, settingsNavigationVC]
    }

    private func moveToTabBar() {
        let mainTabBarController = UITabBarController()
        mainTabBarController.viewControllers = createNavigation()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }

    private func validate(pass: String) -> Bool {
        let minimumNumberOfChar = 4

        if pass.count < minimumNumberOfChar {
            passTextField.layer.borderColor = UIColor.red.cgColor
            infoText.text = "Minimum number of characters: 4"
            infoText.isHidden = false
            return false
        }
        savedPass = pass
        return true
    }

    private func validateSavedPass(_ string: String) -> Bool {
        do {
            if let token = try keyChain.get("newUser") {
                if token == string {
                    return true
                }
            } else {
                guard let savedPass = savedPass else {
                    if validate(pass: string) {
                        loginButton.setTitle("Повторите пароль", for: .normal)
                        passTextField.text = ""
                        passTextField.layer.borderColor = UIColor.black.cgColor
                        infoText.text = ""
                    }
                    return false
                }
                if savedPass == string {
                   try? keyChain.set(string, key: "newUser")
                    return true
                }
                infoText.text = "Пароли не совпадают"
                passTextField.layer.borderColor = UIColor.red.cgColor
                return false
            }
            infoText.text = "Неверный пароль"
            passTextField.layer.borderColor = UIColor.red.cgColor
            return false
        } catch {
            assertionFailure("Cannot get token")
            return false
        }
    }

    private func saveKeychain(string: String) {
        do {
            try keyChain.set(string, key: "newUser")
        } catch {
            assertionFailure("Cannot save password for user")
        }
    }

    private func checkButton() {
        do {
            if let _ = try keyChain.get("newUser") {
                loginButton.setTitle("Введите пароль", for: .normal)
            } else {
                loginButton.setTitle("Создать пароль", for: .normal)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    @objc func loginButtonTapped() {
        if validateSavedPass(passTextField.text!) {
            moveToTabBar()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
