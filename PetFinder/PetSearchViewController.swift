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
	
	//create search bar titles
	let scopeButtonTitles = ["Rabbit", "Dog", "Cat", "Bird", "Reptile", "Horse"]
	//not needed because of the rabbit search will keep for future development
	var didSearch = false
	//for activity indicator
	var isLoading = false
	
	
	//returned value from search
	var returnedPets = [Pet]()
	var imageDownloadTask: URLSessionDownloadTask?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//lowers the table view below the search bar so the first cell is seen
		tableview.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0	)
		searchBar.scopeButtonTitles = scopeButtonTitles
		searchBar.showsScopeBar = true
		//initial search
		performPetSearch(searchText: "rabbit")
	}
	
	func showNetworkError() {
		let alert = UIAlertController(title: "There seems to be an accident", message: "There was an error accessing the Pet Finder site. Please try again.", preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	func petFinderURL(searchText: String) -> URL {
		//set the search text to lowercase. Ask me about capital R
		let lowerCaseSearchText = searchText.lowercased()
		//encode search text for safe url querys  ex %20 for spacing
		let encodedText = lowerCaseSearchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		
		let urlString = String(format: "https://api.petfinder.com/pet.find?key=d62ea251b3e02d378ee3dcfbb39b37db&animal=%@&location=Raleigh,NC&format=json", encodedText)
		
		let url = URL(string: urlString)
		print("This is the url '\(urlString)'")
		return url!
	}
	
	func performPetSearch(searchText: String) {
		
		//tells app there has been a search
		didSearch = true
		
		searchBar.resignFirstResponder()
		//turns on activity indicator
		isLoading = true
		tableview.reloadData()
		
		returnedPets = []
		let url = petFinderURL(searchText: searchText)
		
		let session = URLSession.shared
		
		let dataTask = session.dataTask(with: url,
										completionHandler: { data, response, error in
											if let error  = error {
												print("Failure: \(error)")
											} else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
												if let data = data {
													self.returnedPets = self.parse(dictionary: data)
													DispatchQueue.main.async {
														self.isLoading = false
														self.tableview.reloadData()
													}
													return
												}
											} else {
												print("Failure! \(response!)")
											}
											DispatchQueue.main.async {
												self.didSearch = false
												self.isLoading = false
												self.tableview.reloadData()
												self.showNetworkError()
											}
		})
		dataTask.resume()
		
	}
	
	func parse(dictionary: Data) -> [Pet] {
		
		//breaks down the first dictionary petfinder
		do {
			let json = try JSONSerialization.jsonObject(with: dictionary, options: []) as! [String: Any]
			
			guard let resultArray = json["petfinder"] as? [String: Any] else {
				print("Expected 'result array'")
				return []
			}
			//breaks down the group of pets to inidvidual pets
			guard let resultPetsArray = resultArray["pets"] as? [String: AnyObject] else {
				print("Expected 'pet array'")
				//user entered a non-category throw alert
				let alert = UIAlertController(title: "Sorry no matches", message: "Limit your search to the tabs below the search box. Please try again.", preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
					self.isLoading = false
					self.tableview.reloadData()
				})
				alert.addAction(action)
				present(alert, animated: true, completion: nil)
				//tableview.reloadData()
				return []
			}
			
			
			//if a user searches for an existing category and the return is 0 throw alert
			if  resultPetsArray["pet"] == nil {
				
				let alert = UIAlertController(title: "Sorry no matches", message: "Limit your search to the tabs below the search box. Please try again.", preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
					self.isLoading = false
					self.tableview.reloadData()
				})
				alert.addAction(action)
				present(alert, animated: true, completion: nil)
				//tableview.reloadData()
				return []
			}
			
			//gets the total number of pets returned.
			var petCount = resultPetsArray["pet"]!.count as Int
			// decrease petcount for looping
			if petCount > 0 {
				petCount -= 1
			} else {
				let alert = UIAlertController(title: "Sorry no matches", message: "Limit your search to the tabs below the search box. Please try again.", preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: nil)
				alert.addAction(action)
				present(alert, animated: true, completion: nil)
			}
			//There are pets in this documents.
			let a = resultPetsArray["pet"]! as! Array<[String: AnyObject]>
			
			for i in 0...petCount {
				let newPet = Pet()
				//pet name, description, age, sex, size, id, first layer of dictionary
				if let thisAnimalName = a[i]["name"]!["$t"]! {
					newPet.name = thisAnimalName as? String
				} else {
					newPet.name = "No Name"
				}
				//goes through pet object until it finds the description
				if let thisAnimalDescription = a[i]["description"]!["$t"]! {
					newPet.description = thisAnimalDescription as? String
				} else {
					newPet.description = "No Description."
				}
				
				if let thisAnimalAge = a[i]["age"]!["$t"]! {
					newPet.age = thisAnimalAge as? String
				} else {
					newPet.age = "Age is unknown."
				}
				
				if let thisAnimalSize = a[i]["size"]!["$t"]! {
					newPet.size = thisAnimalSize as? String
				} else {
					newPet.size = "Size is unknown."
				}
				
				if let thisAnimalID = a[i]["id"]!["$t"]! {
					newPet.id = thisAnimalID as? String
				} else {
					newPet.id = "ID is unknown."
				}
				
				if let thisAnimalGender = a[i]["sex"]!["$t"]! {
					newPet.gender = thisAnimalGender as? String
				} else {
					newPet.gender = "ID is unknown."
				}
				
				//contact information burried another layer down
				if let contactInfo = a[i]["contact"]! as? [String: AnyObject] {
					newPet.address1 = contactInfo["address1"]!["$t"]! as? String
					newPet.city = contactInfo["city"]!["$t"]! as? String
					newPet.state = contactInfo["state"]!["$t"]! as? String
					newPet.zip = contactInfo["zip"]!["$t"]! as? String
					newPet.email = contactInfo["email"]!["$t"]! as? String
					newPet.phoneNumber = contactInfo["phone"]!["$t"]! as? String
				}
				
				//breed could either be in a dictionary or another nested dictionary
				if let petBreed = a[i]["breeds"]! as? [String: AnyObject] {
					if let newPetBreed = petBreed["breed"]!["$t"] as? String {
						newPet.breed.append(newPetBreed)
					}
				} else if let petBreed = a[i]["breeds"]! as? [String: [AnyObject]] {
					for b in 0...2 {
						let newPetBreedArray = petBreed["breed"]![b] as! [String: String]
						let newPetBreed = newPetBreedArray["$t"]!
						newPet.breed.append(newPetBreed)
					}
					
				}
				
				//get picture urls from nested dictionary of the 60px for thumbnails and 500px for large images
				if let v = a[i]["media"]!["photos"]! as? [String: [AnyObject]] {
					
					for p in 0...2 {
						let thisAnimalPicture = v["photo"]![p] as! [String: String]
						if p == 0 {
							newPet.thumbnailImageURL = thisAnimalPicture["$t"]!
						} else if p == 2 {
							newPet.imageURL = thisAnimalPicture["$t"]!
						}
					}
				}
				self.returnedPets.append(newPet)
			}
			
		} catch {
			print("something went wrong \(error.localizedDescription)")
		}
		return returnedPets
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "petDetails" {
			let pdVC = segue.destination as! PetDetailsViewContoller
			pdVC.thisPet = sender as! Pet
		}
	}
	
}

extension PetSearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
	//search from scope buttons
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		performPetSearch(searchText: searchBar.scopeButtonTitles![selectedScope])
		searchBar.text = searchBar.scopeButtonTitles![selectedScope]
	}
	// search from search box
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if !searchBar.text!.isEmpty {
			performPetSearch(searchText: searchBar.text!)
		}
	}
	
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

extension PetSearchViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !didSearch || isLoading {
			return 1
		} else {
			return returnedPets.count
		}
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if isLoading {
			let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
			
			let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
			spinner.startAnimating()
			return cell
		} else {
			
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
				
				if let thumbnailURL = returnedPets[indexPath.row].thumbnailImageURL {
					let imageURL = URL(string: thumbnailURL)
					imageDownloadTask = imageView.loadImage(url: imageURL!)
					
				} else {
					imageView.image = UIImage(named: "NOICON")
				}
				if let currentAnimalName = returnedPets[indexPath.row].name {
					nameLabel.text = currentAnimalName
				} else {
					nameLabel.text = "un-named"
				}
				if let currentAnimalDescription = returnedPets[indexPath.row].description {
					descriptionLabel.text = currentAnimalDescription
				} else {
					descriptionLabel.text = "Description coming soon..."
				}
				
			}
			return cell
		}
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let pet = returnedPets[indexPath.row]
		performSegue(withIdentifier: "petDetails", sender: pet)
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if returnedPets.count == 0 || isLoading {
			return nil
		} else {
			return indexPath
		}
		
	}
}

