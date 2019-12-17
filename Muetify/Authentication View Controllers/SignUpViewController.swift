//
//  SignUpViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/16/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var phoneNumber: String!
    var authData: AuthData!
    var authTask: URLSessionDataTask!
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        phoneNumberLabel.text = phoneNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            firstName.count > 0 && lastName.count > 0 {
            
            self.view.isUserInteractionEnabled = false
            authTask?.cancel()
            
            authTask = AuthService().syncSignUp(forSignUpData: SignUpData(
                uuid: authData.uuid!,
                data: authData.data!,
                userData: UserData(
                    id: -1,
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber,
                    avatar: nil
                )
            )) { [weak self] tokenAuthData, error in
                
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showMessage(title: "Error", message: error.localizedDescription)
                    } else if let tokenAuthData = tokenAuthData {
                        if let navigationController = self?.storyboard?.instantiateViewController(withIdentifier: "main") as? MainNavigationController {
                            navigationController.tokenAuthData = tokenAuthData
                            self?.present(navigationController, animated: true, completion: nil)
                        }
                    }
                    self?.indicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
                
            }
            
        } else {
            showMessage(title: "Invalid Fields", message: "Please, fill in the blanks.")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
