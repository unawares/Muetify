//
//  SettingsViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/23/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import Contacts
import PhoneNumberKit
import FirebaseAuth

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var avatarImageView: CircularImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    var token: String!
    var userData: UserData?
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func initUserData(userData: UserData?) {
        if let userData = userData {
            nameTextField.text = userData.firstName
            surnameTextField.text = userData.lastName
            
            if let urlString = userData.avatar, let url = URL(string: urlString) {
                DispatchQueue.main.async { [weak self] in
                    if let data = try? Data(contentsOf: url) {
                        self?.avatarImageView.image = UIImage(data: data)
                    } else {
                        self?.avatarImageView.image = nil
                    }
                }
            } else {
                avatarImageView.image = nil
            }
            
        }
        self.userData = userData
    }
    
    func loadUserData() {
        indicator.startAnimating()
        AuthService().setToken(token: token).getUser() { [weak self] user, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showMessage(title: "Error", message: error.localizedDescription)
                } else {
                    self?.initUserData(userData: user)
                }
                self?.indicator.stopAnimating()
            }
        }
    }
    
    func uploadContacts(phoneNumbers: [String]) {
        AppService().setToken(token: token).addContacts(phoneNumbers: phoneNumbers) { [weak self] phoneNumbers, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showMessage(title: "Error", message: error.localizedDescription)
                } else {
                    self?.showMessage(title: "Успешно", message: "Контакты синхронизированы.")
                }
                self?.indicator.stopAnimating()
            }
        }
    }
    
    func processContacts(contacts: [CNContact]) {
        let phoneNumberKit = PhoneNumberKit()
        var phoneNumbers: [String] = []

        for contact in contacts {
            if !contact.phoneNumbers.isEmpty {
                for phoneNumber in contact.phoneNumbers {
                    let phoneNumberStruct = phoneNumber.value as CNPhoneNumber
                    let phoneNumberString = phoneNumberStruct.stringValue
                    if let number = try? phoneNumberKit.parse(phoneNumberString) {
                        phoneNumbers.append(phoneNumberKit.format(number, toType: .e164))
                    }
                }
            }
        }

        uploadContacts(phoneNumbers: phoneNumbers)
    }
    
    func fetchContacts() {
        indicator?.startAnimating()
        DispatchQueue.main.async { [weak self] in
            let contactStore = CNContactStore()

            let keysToFetch = [CNContactPhoneNumbersKey]

            var allContainers: [CNContainer] = []

            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }

            var results: [CNContact] = []

            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print("Error fetching results for container")
                }
            }

            self?.processContacts(contacts: results)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "token")
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserData()
    }
    
    @IBAction func save(_ sender: Any) {
        
        let saveAlert = UIAlertController(title: "Сохранение", message: "Сохранить ваши данные?", preferredStyle: UIAlertController.Style.alert)

        saveAlert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
            DispatchQueue.main.async { [weak self] in
                self?.indicator.startAnimating()
                if var userData = self?.userData, let firstName = self?.nameTextField.text, let lastName = self?.surnameTextField.text, let token = self?.token  {
                    if firstName.count > 0 && lastName.count > 0 {
                        userData.firstName = firstName
                        userData.lastName = lastName
                        AuthService().setToken(token: token).changeUser(userData: userData) {[weak self] userData, error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    self?.showMessage(title: "Error", message: error.localizedDescription)
                                } else {
                                    self?.navigationController?.popViewController(animated: true)
                                }
                                self?.indicator.stopAnimating()
                            }
                        }
                    } else if firstName.count == 0 {
                        self?.showMessage(title: "Имя пуст", message: "Пожалуйста, заполните имю")
                        self?.indicator.stopAnimating()
                    } else {
                        self?.showMessage(title: "Фамилия пуст", message: "Пожалуйста, заполните фамилию")
                        self?.indicator.stopAnimating()
                    }
                    
                }
            }
        }))

        saveAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (action: UIAlertAction!) in
            self.closeButtonClicked(self)
        }))
        
        present(saveAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func signOut(_ sender: Any) {
        let signOutAlert = UIAlertController(title: "Подтверждение", message: "Выйти из аккауна?", preferredStyle: UIAlertController.Style.alert)

        signOutAlert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
            AuthService().setToken(token: self.token).signOut {[weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                    } else {
                        UserDefaults.standard.removeObject(forKey: "token")
                        try? Auth.auth().signOut()
                        if let viewController = self?.storyboard?.instantiateViewController(withIdentifier: "auth") {
                            self?.present(viewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }))

        signOutAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        present(signOutAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func syncContacts(_ sender: Any) {
        let syncAlert = UIAlertController(title: "Синхронизация", message: "Синхронизировать ваши конакты?", preferredStyle: UIAlertController.Style.alert)

        syncAlert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
            DispatchQueue.main.async(execute: self.fetchContacts)
        }))

        syncAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(syncAlert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}
