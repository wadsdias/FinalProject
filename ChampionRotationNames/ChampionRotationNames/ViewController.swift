//
//  ViewController.swift
//  ChampionRotationNames
//
//  Created by Wanderson Dias Ferreira on 5/7/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var champions: [String] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background1.jpg")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
       

        tableView.delegate = self
        tableView.dataSource = self

        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChampionCell")
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return champions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChampionCell", for: indexPath)
        cell.textLabel?.text = champions[indexPath.row]
        return cell
    }
    
    @IBAction func getChampionsClicked(_ sender: Any) {
        
        fetchChampionIDs { championIDs in
            guard let championIDs = championIDs else {
                print("Failed to fetch champion IDs")
                return
            }
            
            
            let jsonURLString = "https://ddragon.leagueoflegends.com/cdn/14.9.1/data/en_US/champion.json" 
            
           
            guard let jsonURL = URL(string: jsonURLString) else {
                print("Invalid URL")
                return
            }
            
            
            do {
                let jsonData = try Data(contentsOf: jsonURL)
                
                
                guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                      let championData = jsonObject["data"] as? [String: Any] else {
                    print("Failed to parse JSON object")
                    return
                }
                
                
                for championID in championIDs {
                    if let champion = championData.values.first(where: { ($0 as? [String: Any])?["key"] as? String == "\(championID)" }) as? [String: Any],
                       let championName = champion["name"] as? String {
                        
                        self.champions.append(championName)
                    }
                }
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching or parsing JSON: \(error.localizedDescription)")
            }
        }
    }
    
    
    func fetchChampionIDs(completion: @escaping ([Int]?) -> Void) {
        let url = URL(string: "https://na1.api.riotgames.com/lol/platform/v3/champion-rotations?api_key=RGAPI-91a595bc-b82f-45e2-ab2c-5ba096ca5a6a")
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!) { (data1, response1, error1) in
            if let error = error1 {
                print("Error fetching champion IDs: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let data = data1 {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let freeChampionIds = jsonResponse["freeChampionIds"] as? [Int] {
                                print("Champion IDs: \(freeChampionIds)")
                                completion(freeChampionIds)
                            } else {
                                print("Error parsing champion IDs")
                                completion(nil)
                            }
                        } else {
                            print("Error parsing JSON response")
                            completion(nil)
                        }
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                        completion(nil)
                    }
                } else {
                    print("No data received")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}
