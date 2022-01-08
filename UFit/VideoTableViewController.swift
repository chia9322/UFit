//
//  VideoTableViewController.swift
//  UFit
//
//  Created by Chia on 2022/01/06.
//

import UIKit

class VideoTableViewController: UITableViewController {
    
    var videos =  [Video]()
    var favoriteVideos = [Video]()
    var segmentedControlIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Define which video list to show (All or Favorite)
        if segmentedControlIndex == 0 {
            return videos.count
        } else {
            favoriteVideos = videos.filter{$0.isFavorite}
            return favoriteVideos.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoTableViewCell
        
        // Define which video list to show (All or Favorite)
        var video: Video
        if segmentedControlIndex == 0 {
            video = videos[indexPath.row]
        } else {
            video = favoriteVideos[indexPath.row]
        }
        
        cell.titleLabel.text = video.title
        cell.thumbnailImageView.image = getImageFromUrl(url: video.thumbnailUrl)
        cell.heartButton.imageView?.image = video.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        
        // 用tag區分使用者點選了哪個按鈕
        cell.heartButton.tag = indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoId = videos[indexPath.row].videoId
        guard let youtubeUrl = URL(string: "youtube://\(videoId)") else { return }
        if UIApplication.shared.canOpenURL(youtubeUrl) {
            UIApplication.shared.open(youtubeUrl)
        } else {
            guard let videoUrl = URL(string: "https://www.youtube.com/watch?v=\(videoId)") else { return }
            UIApplication.shared.open(videoUrl)
        }
    }
    
    @IBAction func heartButtonPressed(_ sender: UIButton) {
        videos[sender.tag].isFavorite = !videos[sender.tag].isFavorite
//        sender.imageView?.image = videos[sender.tag].isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
//        tableView.reloadData()
        tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        segmentedControlIndex = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    func getImageFromUrl(url: URL) -> UIImage {
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch {
            return UIImage()
        }
    }
    
    func fetchData() {
        let channelId = "UUd0pUnH7i5CM-Y8xRe7cZVg"
        let apiKey = "YOUR API KEY"
        
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails,status&playlistId=\(channelId)&key=\(apiKey)&maxResults=50"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = data {
                    do {
                        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                        // 將解碼後的資料取出需要的項目整理到新的array中
                        var newVideos: [Video] = []
                        for item in searchResponse.items {
                            let newVideo = Video(title: item.snippet.title,
                                                 thumbnailUrl: item.snippet.thumbnails.standard.url,
                                                 videoId: item.snippet.resourceId.videoId)
                            newVideos += [newVideo]
                        }
                        self.videos = newVideos
                        // 更新畫面必須要用main thread
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }

}
