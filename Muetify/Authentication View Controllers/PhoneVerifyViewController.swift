//
//  PhoneVerifyViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/16/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import PhoneNumberKit
import FirebaseAuth
import FirebaseFirestore

class PhoneVerifyViewController: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var codeTextField: UITextField!
    var authTask: URLSessionDataTask!
    var phoneNumber: String!
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func syncSignInAuth(authData: FirebaseAuthData) {
        authTask = AuthService().syncSignIn(forSignInData: SignInData(
            uuid: authData.uuid!,
            data: authData.data!
        )) { [weak self] tokenAuthData, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showMessage(title: "Error", message: error.localizedDescription)
                } else if let tokenAuthData = tokenAuthData {
                    if let navigationController = self?.storyboard?.instantiateViewController(withIdentifier: "main") as? MainNavigationController {
                        navigationController.tokenAuthData = tokenAuthData
                        navigationController.modalPresentationStyle = .fullScreen
                        self?.present(navigationController, animated: true, completion: nil)
                    }
                }
                self?.indicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
            }
            
        }
    }
    
    func syncSignUpAuth(authData: FirebaseAuthData) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "sign_up") as? SignUpViewController {
            viewController.phoneNumber = phoneNumber
            viewController.authData = authData
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        self.view.isUserInteractionEnabled = true
        self.indicator.stopAnimating()
    }
    
    func syncAuth() {
        let db = Firestore.firestore()
        let reference = db.collection("users").document(phoneNumber)
        reference.getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let authData = FirebaseAuthData(snapshot: document)
                    if let isRegistered = authData.isRegistered {
                        if isRegistered {
                            self?.syncSignInAuth(authData: authData)  // Next level
                        } else {
                            self?.syncSignUpAuth(authData: authData)  // Next level
                        }
                    } else {
                        self?.showMessage(title: "Error", message: "Something went wrong.")
                        self?.view.isUserInteractionEnabled = true
                        self?.indicator.stopAnimating()
                    }
                    
                } else {
                    self?.showMessage(title: "Error", message: "Something went wrong.")
                    self?.view.isUserInteractionEnabled = true
                    self?.indicator.stopAnimating()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        if let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") {
            
            if let verificationCode = codeTextField.text {
                self.view.isUserInteractionEnabled = false
                self.indicator.startAnimating()

                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                        verificationCode: verificationCode)
                Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                            self?.view.isUserInteractionEnabled = true
                            self?.indicator.stopAnimating()
                            return
                        }
                        self?.syncAuth()  // Next level
                    }
                }

            } else {
                showMessage(title: "Provide Sent Code", message: "Please, fill in the code which has been sent.")
            }
            
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}
