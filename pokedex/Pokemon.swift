//
//  Pokemon.swift
//  pokedex
//
//  Created by Jelmar Van Aert on 08/02/2017.
//  Copyright © 2017 Jelmar Van Aert. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionName: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLevel: String!
    private var _pokemonURL: String!
    private var _moves: Dictionary<String, Dictionary<String, String>>!
    
    var name: String {return _name}
    var pokedexId: Int {return _pokedexId}
    var attack: String {return _attack ?? ""}
    var nextEvolutionText: String {get {return _nextEvolutionTxt ?? ""} set {_nextEvolutionTxt = newValue}}
    var weight: String {return _weight ?? ""}
    var height: String {return _height ?? ""}
    var defense: String {return _defense ?? ""}
    var type: String {return _type ?? ""}
    var description: String {return _description ?? ""}
    var nextEvolutionName: String {return _nextEvolutionName ?? ""}
    var nextEvolutionId: String {return _nextEvolutionId ?? ""}
    var nextEvolutionLevel: String {return _nextEvolutionLevel ?? ""}
    var moves: Dictionary<String, Dictionary<String,String>> {return _moves ?? Dictionary<String,Dictionary<String,String>>()}
    
    init(name: String, pokedexId: Int) {
        self._pokedexId = pokedexId
        self._name = name
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(pokedexId)/"
    }
    
    func downloadPokemonDetail(completed: @escaping DonwloadComplete) {
        Alamofire.request(self._pokemonURL).responseJSON { (response) in
            
            if let dict = response.result.value as? Dictionary<String,AnyObject> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                if let height = dict["height"] as? String {
                    self._height = height
                }
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                if let types = dict["types"] as? [Dictionary<String, String>], types.count > 0 {
                    if let name = types[0]["name"]{
                        self._type = name.capitalized
                    }
                    if types.count > 1 {
                        for x in 1..<types.count {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                }
                if let descriptionArray = dict["descriptions"] as? [Dictionary<String, String>], descriptionArray.count > 0 {
                    if let url = descriptionArray[0]["resource_uri"]{
                        let descURL = "\(URL_BASE)\(url)"
                        
                        Alamofire.request(descURL).responseJSON(completionHandler:  {(response) in
                            if let descDict = response.result.value as? Dictionary<String, AnyObject> {
                                if let description = descDict["description"] as? String {
                                    let newDescription = description.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                    
                                    print(newDescription)
                                    self._description = newDescription
                                }
                            }
                            completed()
                        })
                    }
                }
                
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutions.count > 0 {
                    if let nextEvo = evolutions[0]["to"] as? String {
                        if nextEvo.range(of: "mega") == nil {
                            self._nextEvolutionName = nextEvo
                            if let uri = evolutions [0]["resource_uri"] as? String {
                                let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                let nextEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                self._nextEvolutionId = nextEvoId
                                
                                if let lvlExist = evolutions[0]["level"] {
                                    if let lvl = lvlExist as? Int {
                                        self._nextEvolutionLevel = "\(lvl)"
                                    }
                                }else {
                                    self._nextEvolutionLevel = ""
                                }
                            }
                        }
                    }
                }
                let test = dict["moves"] as? [Dictionary<String, String>]
                print(test?.count ?? "It does not exist!!!!!!!!!!!!!!!!!!")
                if let moves = dict["moves"] as? [Dictionary<String, String>] {
                    print("it got in")
                    for x in 0..<moves.count{
                        
                        let uri = moves[x]["resource_uri"]
                        let url = "\(URL_BASE)\(uri)"
                        var strengthDict: Dictionary<String, String>!
                        
                        Alamofire.request(url).responseJSON(completionHandler: {(response) in
                            if let moveDict = response.result.value as? Dictionary<String, AnyObject> {
                                if let power = moveDict["power"] {
                                    strengthDict["power"] = "\(power)"
                                }
                                if let accuracy = moveDict["accuracy"] {
                                    strengthDict["accuracy"] = "\(accuracy)"
                                }
                            }
                            if let name = moves[x]["name"] {
                                self._moves[name] = strengthDict
                            }
                            print(strengthDict["power"]!)
                            print(strengthDict["accuracy"]!)
                            
                            completed()
                        })
                    }
                }
            }
            self.nextEvolutionText = "Next Evolution: \(self.nextEvolutionName) - LVL \(self.nextEvolutionLevel)"
            completed()
        }
    }
}
