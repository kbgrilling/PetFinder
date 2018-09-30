//
//  ViewController.swift
//  PetFinder
//
//  Created by KENNETH BLUE on 9/28/18.
//  Copyright © 2018 Kenneth Blue. All rights reserved.
//

import UIKit

class PetSearchViewController: UIViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableview: UITableView!
	
	
	
	
	var didSearch = false
	var searchResults = [Pet]()
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//lowers the table view below the search bar so the first cell is seen
		tableview.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0	)
		//performs initial search will remove when other types are searchable
		
		
	}
	
	func petFinderURL(searchText: String) -> URL {
		let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		
		let urlString = String(format: "https://api.petfinder.com/pet.find?key=d62ea251b3e02d378ee3dcfbb39b37db&animal=%@&location=Raleigh,NC&format=json", encodedText)
		
		let url = URL(string: urlString)
		print("This is the url '\(urlString)'")
		return url!
	}
	
	func performPetSearchRequest(with url: URL) -> [String: Any]? {
		do {
			let data = try Data(contentsOf: url)
			do {
				let object = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
				
				return object
			} catch {
				print("something went wrong \(error.localizedDescription)")
			}
		} catch let error as NSError {
			print("error: \(error.localizedDescription)")
		}
		return nil
	}
	/*
	func parse(data: Data) -> [Pet] {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(PetsResultArray.self, from: data)
			return result.petFinder
		} catch {
			print("JSON error: \(error)")
			return []
		}
	}*/
	func parse(dictionary: [String: Any]) -> [Pet] {
		//breaks down the first dictionary petfinder
		print("here is the dictionary: \(dictionary)")

		guard let resultArray = dictionary["petfinder"] as? [String: Any] else {
			print("Expected 'result array'")
			return []
		}
			//breaks down the group of pets to inidvidual pets
		guard let resultPetsArray = resultArray["pets"] as? [String: AnyObject] else {
			print("Expected 'pet array'")
			return []
		}
		// returned array of Pet objects
		var returnedPets = [Pet]()
		//gets the total number of pets returned.  25 is the max from the petFinder api
		var petCount = resultPetsArray["pet"]!.count as Int
		// decrease petcount for looping
		petCount -= 1
		
		
		let a = resultPetsArray["pet"]! as! Array<[String: AnyObject]>
		
		for i in 0...petCount {
			let newPet = Pet()
			//goes through pet object until it finds the name
			if let thisAnimalName = a[i]["name"]!["$t"]! {
				//print(thisAnimalName)
				newPet.name = thisAnimalName as? String
			} else {
				newPet.name = "No Name"
			}
			//goes through pet object until it finds the name
			if let thisAnimalDescription = a[i]["description"]!["$t"]! {
				//print(thisAnimalDescription)
				newPet.description = thisAnimalDescription as? String
			} else {
				newPet.description = "No Description"
			}
			let v = a[i]["media"]!["photos"]! as! [String: [AnyObject]]
			for p in 0...2 {
				let thisAnimalPicture = v["photo"]![p] as! [String: String]
				//print(thisAnimalPicture["$t"]!)
				if p == 0 {
					newPet.thumbnailImageURL = thisAnimalPicture["$t"]!
				} else if p == 2 {
					newPet.thumbnailImageURL = thisAnimalPicture["$t"]!
				}
			}
			returnedPets.append(newPet)
		}
			print(returnedPets)
			self.searchResults = returnedPets
			return returnedPets
	}

}

extension PetSearchViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		didSearch = true
		searchBar.resignFirstResponder()

		let url = petFinderURL(searchText: "rabbit")
		print("URL: \(url)")
		if let data = performPetSearchRequest(with: url) {
			let results = self.parse(dictionary: data)
				print("got dictionary \(results)")
			
			}
			tableview.reloadData()
		}
	
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

extension PetSearchViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !didSearch {
			return 1
		} else {
			return searchResults.count
		}
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
		let imageView = cell.viewWithTag(1000) as! UIImageView
		let nameLabel = cell.viewWithTag(1001) as! UILabel
		let descriptionLabel = cell.viewWithTag(1002) as! UILabel
		
		if !didSearch {
			//imageView.image = UIImage(named: "NOICON")
			nameLabel.text = " "
			descriptionLabel.text = "Use the search bar above to find your new friend!"
			cell.accessoryType = .none
			
		} else {
			cell.accessoryType = .detailButton
			imageView.image = UIImage(named: "NOICON")
			nameLabel.text = searchResults[indexPath.row].name!
			descriptionLabel.text = searchResults[indexPath.row].description!
		}
		
		
		return cell
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if searchResults.count == 0 {
			return nil
		} else {
			return indexPath
		}
		
	}
	
	
}
