//
//  RecipeDetailViewController.swift
//  Recipe-App
//
//  Created by Selina on 30/11/2020.
//

import UIKit
import Photos
import MobileCoreServices
import PKHUD

protocol RecipeDetailViewControllerDelegate: class {
    func reloadRecipes()
}

class RecipeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameRecipe: UITextField!
    @IBOutlet weak var typeRecipe: UITextField!
    @IBOutlet weak var ingredientsRecipe: UITextView!
    @IBOutlet weak var stepsRecipe: UITextView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addImageUIButton: UIButton!
    fileprivate var imagePicker =  UIImagePickerController()
    var viewModel = RecipeDetailViewModel()
    weak var delegate: RecipeDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(RecipeDetailViewController.dismissKeyboard))
        scrollView.addGestureRecognizer(hideKeyboardTapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupUI()
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        if nameRecipe.text != nil && !nameRecipe.text!.isEmpty {
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Processing")
            PKHUD.sharedHUD.show()
            var imagePath: String?
            let imageName = "\(String(viewModel.repcie!.id))\(String(describing: nameRecipe.text))\(String(Date.currentTimeStamp))"
            imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
            let imageUrl: URL = URL(fileURLWithPath: imagePath!)
            //Store Image
            try? imageView.image!.pngData()?.write(to: imageUrl)
            //Update Recipe
            viewModel.saveRecipe(recipe: viewModel.repcie!, name: nameRecipe.text ?? "", type: typeRecipe.text ?? "", ingredients: ingredientsRecipe.text ?? "", steps: stepsRecipe.text ?? "", imageUrl: "\(imageUrl)")
            PKHUD.sharedHUD.hide()
            
            self.navigationController?.popViewController(animated: true)
            delegate?.reloadRecipes()
        }
    }
    
    @IBAction func addImage(_ sender: Any) {
        openGallery()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.pickerView.removeFromSuperview()
    }
    
    private func setupUI() {
        //set up Navigation
        navigationItem.title = "Recipe Detail"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-delete"), style: .plain, target: self, action: #selector(deleteRecipeButtonTapped))
        //Set button in circle
        self.addImageUIButton.makeRounded()
        
        self.typeRecipe.inputView = pickerView
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.nameRecipe.text = viewModel.repcie?.name
        self.typeRecipe.text = viewModel.repcie?.type
        self.ingredientsRecipe.text = viewModel.repcie?.ingredients
        self.stepsRecipe.text = viewModel.repcie?.steps
        
        let imageUrl: URL = URL(fileURLWithPath: viewModel.repcie!.imageUrl)
        //Check out the image contained in Store Image
        guard FileManager.default.fileExists(atPath: viewModel.repcie!.imageUrl) else {
            imageView.sd_setImage(with: URL(string: viewModel.repcie!.imageUrl), placeholderImage: #imageLiteral(resourceName: "attach_image_icon"))
            return //No found image
        }
        if let imageData: Data = try? Data(contentsOf: imageUrl) {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    @objc func deleteRecipeButtonTapped() {
        if viewModel.repcie != nil {
            viewModel.deleteRecipe(viewModel.repcie!)
        }
        self.navigationController?.popViewController(animated: true)
        delegate?.reloadRecipes()
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
}

extension RecipeDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension RecipeDetailViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfComponents()
    }
}

extension RecipeDetailViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.recipeTypeList()[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeRecipe.text = viewModel.recipeTypeList()[row].name
    }
}
