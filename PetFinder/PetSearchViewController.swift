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
	var isLoading = false
	var returnedPets = [Pet]()
	var imageDownloadTask: URLSessionDownloadTask?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//lowers the table view below the search bar so the first cell is seen
		tableview.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0	)
		//performs initial search will remove when other types are searchable

	}
	
	override func viewDidAppear(_ animated: Bool) {
		
	}
	
	func showNetworkError() {
		let alert = UIAlertController(title: "There seems to be an accident", message: "There was an error accessing the Pet Finder site. Please try again.", preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
		
	}
	
	func petFinderURL(searchText: String) -> URL {
		let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		
		let urlString = String(format: "https://api.petfinder.com/pet.find?key=d62ea251b3e02d378ee3dcfbb39b37db&animal=%@&location=Raleigh,NC&format=json", encodedText)
		
		let url = URL(string: urlString)
		print("This is the url '\(urlString)'")
		return url!
	}
	
	func performPetSearch(searchText: String) {
		print("initial called")
		
			didSearch = true
			//add searchText to quite warning of searchbar is only availabe on main thread.
			//let searchText = searchBar.text!
			searchBar.resignFirstResponder()
			isLoading = true
			tableview.reloadData()
			
			returnedPets = []
			let url = petFinderURL(searchText: searchBar.text!)
			
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
			return []
		}
		
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
			print("loop count \(i)")
			if let v = a[i]["media"]!["photos"]! as? [String: [AnyObject]] {
				
				for p in 0...2 {
					print("here is p \(p)")
					let thisAnimalPicture = v["photo"]![p] as! [String: String]
					//print(thisAnimalPicture["$t"]!)
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

}

extension PetSearchViewController: UISearchBarDelegate {
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
				performPetSearch(searchText: "rabbit")
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
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if returnedPets.count == 0 || isLoading {
			return nil
		} else {
			return indexPath
		}
		
	}
	
	
	
}
