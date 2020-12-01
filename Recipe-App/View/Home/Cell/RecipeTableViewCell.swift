//
//  RecipeTableViewCell.swift
//  Recipe-App
//
//  Created by Selina on 30/11/2020.
//

import UIKit
import SDWebImage

class RecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var viewModel: RecipeTableViewCellViewModel? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        guard let viewModel = viewModel else {
            return
        }
        recipeNameLabel.text = viewModel.nameRecipe
        
        let imageUrl: URL = URL(fileURLWithPath: viewModel.imageUrl)
        guard FileManager.default.fileExists(atPath: viewModel.imageUrl) else {
            recipeImageView.sd_setImage(with: URL(string: viewModel.imageUrl), placeholderImage: #imageLiteral(resourceName: "attach_image_icon"))
            return // No image found!
        }
        if let imageData: Data = try? Data(contentsOf: imageUrl) {
            DispatchQueue.main.async {
                self.recipeImageView.image = UIImage(data: imageData)
            }
        }
    }
    
}
