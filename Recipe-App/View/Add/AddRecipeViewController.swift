//
//  AddRecipeViewController.swift
//  Recipe-App
//
//  Created by Selina on 01/12/2020.
//

import UIKit
import Photos
import MobileCoreServices
import PKHUD

protocol AddRecipeViewControllerDelegate: class {
    func reloadRecipes()
}

class AddRecipeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var nameRecipeTextField: UITextField!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var stepsTextView: UITextView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addRecipeUIButton: UIButton!
    @IBOutlet weak var addImageUIButton: UIButton!
    fileprivate var imagePicker =  UIImagePickerController()
    var viewModel = AddRecipeViewModel()
    weak var delegate: AddRecipeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide Keyboard
        let hideKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(AddRecipeViewController.dismissKeyboard))
        scrollView.addGestureRecognizer(hideKeyboardTapGesture)
        
        //Move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupUI()
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if nameRecipeTextField.text != nil && !nameRecipeTextField.text!.isEmpty {
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Processing")
            PKHUD.sharedHUD.show()
            var imagePath: String?
            if imageView.image != nil {
                
                let imageName = "\(String(describing: nameRecipeTextField.text))\(String(Date.currentTimeStamp))"
                imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
                let imageUrl: URL = URL(fileURLWithPath: imagePath!)
                //Store Image
                try? imageView.image!.pngData()?.write(to: imageUrl)
                //add Recipe
                viewModel.addRecipe(name: nameRecipeTextField.text ?? "", type: typeTextField.text ?? "", ingredients: ingredientsTextView.text ?? "", steps: stepsTextView.text ?? "", imageUrl: "\(imageUrl)")
            }
            PKHUD.sharedHUD.hide()
            self.navigationController?.popViewController(animated: true)
            delegate?.reloadRecipes()
        }
        
    }
    
    @IBAction func addImageButtonTapped(_ sender: Any) {
        openGallery()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.pickerView.removeFromSuperview()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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
    private func setupUI(){
        navigationItem.title = "Add Recipe"
        
        //Set button in circle
        self.addImageUIButton.makeRounded()
        
        //Picker View
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.setValue(UIColor.black, forKey: "textColor")
        self.pickerView.autoresizingMask = .flexibleWidth
        self.pickerView.contentMode = .center
        self.pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 250)
        
        self.typeTextField.inputView = pickerView
        self.nameRecipeTextField.delegate = self
    }
}


extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openGallery() {
        PHPhotoLibrary.requestAuthorization({ status in
            DispatchQueue.main.async {
                if status == .authorized {
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                } else {
                    
                }
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let originalImage = info[.originalImage] as? UIImage {
            imageView.image = originalImage
        }
    }
}

extension AddRecipeViewController: UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextField) {
        if nameRecipeTextField.text != nil && !nameRecipeTextField.text!.isEmpty  {
            addRecipeUIButton.isEnabled = false
            
        } else {
            addRecipeUIButton.isEnabled = true
        }
    }
    
}
extension AddRecipeViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfComponents()
    }
}

extension AddRecipeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.recipeTypeList()[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = viewModel.recipeTypeList()[row].name
    }
}

