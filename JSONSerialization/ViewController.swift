//
//  ViewController.swift
//  JSONSerialization
//
//  Created by Nikita Koniukh on 27/05/2020.
//  Copyright © 2020 Nikita Koniukh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Outlets
    @IBOutlet weak var tableView: UITableView!

    // Properties
    private let stringUrl = "https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/100/explicit.json"
    typealias jsonDictionary = Dictionary<String, Any>
    var artistsArray = [Artist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        parseJson { result in
            self.artistsArray = result
            self.tableView.reloadData()
        }
    }

    func parseJson(comletion: @escaping([Artist]) -> Void) {
        var tempArtistsArray = [Artist]()
        guard let url = URL(string: stringUrl) else { return }
        let request = NSURLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let err = error {
                print("Error is: \(err.localizedDescription)")
                return
            }
            guard let data = data else { return }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! jsonDictionary

                let feed = json["feed"] as! jsonDictionary
                let results = feed["results"] as! [jsonDictionary]

                for result in results {
                    let artistName = result["artistName"] as! String
                    let releaseDate = result["releaseDate"] as! String
                    tempArtistsArray.append(Artist(artistName: artistName, releaseDate: releaseDate))
                }
                DispatchQueue.main.async {
                    comletion(tempArtistsArray)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let artist = artistsArray[indexPath.row]

        cell.textLabel?.text = artist.artistName
        cell.detailTextLabel?.text = artist.releaseDate
        return cell
    }
}

struct Artist {
    let artistName: String
    let releaseDate: String
}

