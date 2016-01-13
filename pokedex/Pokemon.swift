//
//  Pokemon.swift
//  pokedex
//
//  Created by Jesse Tellez on 1/10/16.
//  Copyright © 2016 SunCat Developers. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    //open in JSON formatter to understand the nesting of conditionals
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvoId: String!
    private var _nextEvoLevel: String!
    //no one needs access to this one
    private var _pokemonURL: String!

    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    var nextEvoTxt: String  {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    var nextEvoLevel: String {
        if _nextEvoLevel == nil {
            _nextEvoLevel = ""
        }
        return _nextEvoLevel
    }
    
    var nextEvoId: String {
        if _nextEvoId == nil {
            _nextEvoId = ""
        }
        return _nextEvoId
    }
    var name: String {
        return _name
    }
    var pokedexId: Int {
        return _pokedexId
    }
    
    //when ever you click a specific pokemon, THEN download that data, not when the app loads
    
    init(name: String, pokedexId: Int) {
        //forcing a value to name and ID so we can use the !
        self._name = name
        self._pokedexId = pokedexId
        _pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        //make sure data is availible
        let url = NSURL(string: _pokemonURL)!
        Alamofire.request(.GET, url).responseJSON { response in
            let result = response.result
            //print(result)
            if let dict = result.value as? Dictionary<String, AnyObject> {
                //grab searches out
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attact = dict["attack"] as? Int {
                    self._attack = "\(attact)"
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                
                if let types = dict["types"] as? [Dictionary<String, String>] where types.count > 0 {
                    if let name = types[0]["name"] {
                        //get first item and then get the name property of that dictionary
                        self._type = name.capitalizedString
                    }
                    if types.count > 1 {
                        for var x = 1; x < types.count; x++ {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalizedString)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                
                //print(self._type)
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>] where descArr.count > 0 {
                    if let url = descArr[0]["resource_uri"] {
                        let fullURL = NSURL(string: "\(URL_BASE)\(url)")!
                        Alamofire.request(.GET, fullURL).responseJSON(completionHandler: { response in
                            let result2 = response.result
                            if let descDict = result2.value as? Dictionary<String, AnyObject> {
                                if let description = descDict["description"] as? String {
                                    self._description = description
                                    //print(self._description)
                                }
                            }
                            completed()
                        })
                    }
                }else {
                    self._description = ""
                }
                
                //evolutions
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>] where evolutions.count > 0 {
                    if let to = evolutions[0]["to"] as? String {
                        
                        //mega is not found
                        if to.rangeOfString("mega") == nil {
                            if let str = evolutions[0]["resource_uri"] as? String {
                                let newStr = str.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString:"")
                                let number = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
                                self._nextEvoId = number
                                self._nextEvolutionTxt = to
                                
                                if let level = evolutions[0]["level"] as? Int {
                                    self._nextEvoLevel = "\(level)"
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
}