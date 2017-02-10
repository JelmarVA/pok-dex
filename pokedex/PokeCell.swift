//
//  PokeCell.swift
//  pokedex
//
//  Created by Jelmar Van Aert on 08/02/2017.
//  Copyright © 2017 Jelmar Van Aert. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var pokemon: Pokemon!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5.0
    }
    func configurCell(_ pokemon: Pokemon){
        
        self.pokemon = pokemon
        
        nameLbl.text = self.pokemon.name.capitalized
        thumbImage.image = UIImage(named: "\(self.pokemon.pokedexId)")
    }
    
}
