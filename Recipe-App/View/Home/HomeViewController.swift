//
//  HomeViewController.swift
//  Recipe-App
//
//  Created by Selina on 30/11/2020.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var recipeTableView: UITableView!
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var viewModel = HomeViewModel()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        picker = UIPickerView.init()
        configNavigation()
        configTableView()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        onDoneButtonTapped()
    }
    
    private func configTableView() {
        recipeTableView.register(RecipeTableViewCell.self)
        recipeTableView.dataSource = self
        recipeTableView.delegate = self
        recipeTableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc func addRecipeButtonTapped() {
        let addVC = AddRecipeViewController()
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    
    
    @objc func filterRecipeButoonTapped() {
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        view.endEditing(true)
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        
    }
    
    private func configNavigation() {
        navigationItem.title = "All Recipe"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-plus-selected "), style: .plain, target: self, action: #selector(addRecipeButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-filter"), style: .plain, target: self, action: #selector(filterRecipeButoonTapped))
    }
    
    private func setupUI(){
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfSections()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeue(RecipeTableViewCell.self, indexPath: indexPath)
        cell.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cell.layer.borderWidth = 0.2
        cell.viewModel = viewModel.viewModelForItems(at: indexPath)
        return cell
    }
}

extension HomeViewController: RecipeDetailViewControllerDelegate, AddRecipeViewControllerDelegate {
    func reloadRecipes() {
        viewModel.reloadRecipes()
        recipeTableView.reloadData()
    }
    
}
extension HomeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfComponents()
    }
}

extension HomeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.name(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.filterRecipeByTypeID(viewModel.name(row))
        navigationItem.title = viewModel.name(row)
        recipeTableView.reloadData()
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = RecipeDetailViewController()
        detailVC.delegate = self
        detailVC.viewModel = viewModel.getDetailViewModel(atIndexPath: indexPath)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

