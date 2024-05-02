//
//  ViewController.swift
//  Bundle.Sandbox.FileManager.HomeWork
//
//  Created by Sergey on 19.04.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private let fileService: FileManagerService
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init(fileService: FileManagerService) {
        self.fileService = fileService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        layout()
    }

    private func setupView() {
        
        let createFolderButton = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.plus"),
            style: .done,
            target: self,
            action: #selector(createFolderTapped))
        
        let addPhotoButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .done,
            target: self,
            action: #selector(addPhotoTapped))
        
        navigationItem.rightBarButtonItems = [addPhotoButton, createFolderButton]
    }
    
    @objc func createFolderTapped() {
        showAlert { folderName in
            self.fileService.createDirectory(name: folderName)
            self.tableView.reloadData()
        }
    }
    
    @objc func addPhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    private func showAlert(completion: @escaping(String) -> Void) {
        let alert = UIAlertController(title: "Create new folder",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField()
        
        let createAction = UIAlertAction(title: "Create", style: .default) {_ in
            guard let folderName = alert.textFields?[0].text, folderName != "New folder"
            else {return}
            
            completion(folderName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func layout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fileService.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        let contentArray = fileService.getContent()
        
        content.text = contentArray[indexPath.row].name
        
        cell.contentConfiguration = content
        cell.accessoryType = (contentArray[indexPath.row].type == ContetntType.folder) ? .disclosureIndicator : .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = UILabel()
        title.text = "Documents"
        title.font = UIFont.boldSystemFont(ofSize: 50)

        return title.text
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fileService.removeContent(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = fileService.getPath(at: indexPath.row)
        let fileService = FileManagerService(pathForFolder: path)
        let nextViewController = ViewController(fileService: fileService)
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            let imageName = UUID().uuidString + ".jpeg"
            fileService.createFile(name: imageName, content: pickedImage)
        }
        picker.dismiss(animated: true)
        tableView.reloadData()
    }
}
