//
//  ViewController.swift
//  Bundle.Sandbox.FileManager.HomeWork
//
//  Created by Sergey on 19.04.2024.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    var action: (([String]) -> Void)?

    private let fileservice: FilemanagerService
    var itemsArray: [String]?

    lazy var documentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init (fileService: FilemanagerService) {
        self.fileservice = fileService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateArray()
        initialFetch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
    }

    private func layout() {
        self.navigationItem.title = fileservice.pathForFolder.components(separatedBy: "/").last
        changeNavigationItem()
        view.addSubview(documentsTableView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            documentsTableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            documentsTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            documentsTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            documentsTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    private func changeNavigationItem() {
        let firstRightItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(folderButtonTapped))
        let secondRightItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plustButtonTapped))
        navigationItem.rightBarButtonItems = [secondRightItem, firstRightItem]
    }

    private func updateView() {
        action = { [weak self] sortedArray in
            self?.itemsArray = sortedArray
            self?.documentsTableView.reloadData()
        }
    }

    private func initialFetch() {

        guard let sortedValue = UserDefaults.standard.value(forKey: "sorted") as? String else { return }

        switch sortedValue {
        case "soertedLower":
            fileservice.fetchData()
            fileservice.sort(by: .soertedLower)
            itemsArray = fileservice.items
            documentsTableView.reloadData()
        case "sortedUpper":
            fileservice.fetchData()
            fileservice.sort(by: .sortedUpper)
            itemsArray = fileservice.items
            documentsTableView.reloadData()
        case "notSorted":
            break
        default: break
        }
    }

    @objc func folderButtonTapped() {

        let alert = UIAlertController(title: "Create new Folder", message: "Please enter name", preferredStyle: .alert)

        alert.addTextField()

        let action = UIAlertAction(title: "Cancel", style: .destructive)

        action.titleTextColor = UIColor(red: 0/255, green: 0/255, blue: 139/255, alpha: 1)

        let secondAction = UIAlertAction(title: "Create", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.fileservice.createDirectory(name: (alert.textFields?.first?.text)!)
            self.fileservice.fetchData()
            self.initialFetch()
            self.itemsArray = self.fileservice.items
            self.documentsTableView.reloadData()
        }

        secondAction.titleTextColor = UIColor(red: 0/255, green: 0/255, blue: 139/255, alpha: 0.7)

        alert.addAction(action)
        alert.addAction(secondAction)

        self.present(alert, animated: true)
    }

    @objc func plustButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        self.present(imagePicker, animated: true)
    }

    private func updateArray() {
        fileservice.fetchData()
        itemsArray = fileservice.items
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = fileservice.pathForFolder.components(separatedBy: "/")
        return title.last?.uppercased()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = itemsArray {
            return items.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()
            content.text = itemsArray![indexPath.row]
            cell.accessoryType = fileservice.isDirectoryAtIndex(indexPath.row) ? .disclosureIndicator : .checkmark
            cell.contentConfiguration = content
        return cell
    }
}


extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fileservice.removeContent(at: indexPath.row)
            fileservice.fetchData()
            initialFetch()
            itemsArray = fileservice.items
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fileservice.isDirectoryAtIndex(indexPath.row) {
            let path = fileservice.getPath(at: indexPath.row)
            let fileService = FilemanagerService(pathForFolder: path)
            let nextVieController = ViewController(fileService: fileService)
            navigationController?.pushViewController(nextVieController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var fileName = ""
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            fileName = url.lastPathComponent
        }

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageJpegData = image.jpegData(compressionQuality: 1.0)
            fileservice.createFile(name: fileName, content: imageJpegData!)
            fileservice.fetchData()
            initialFetch()
            itemsArray = fileservice.items
            self.documentsTableView.reloadData()
          } else {
              let uiAlert = UIAlertController(title: "Ошибка сохранения", message: "Не удалось сохранить изображение", preferredStyle: .alert)
              let action = UIAlertAction(title: "Cancel", style: .cancel)
              uiAlert.addAction(action)
              self.navigationController?.present(uiAlert, animated: true)
          }

        dismiss(animated: true, completion: nil)
    }
}

private extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
