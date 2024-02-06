//
//  AppTableViewCell.swift
//  KSH_CodeTestProj
//
//  Created by lyl on 2024/2/4.
//

import UIKit

class AppTableViewCell: UITableViewCell {
    
    let itemImageView = UIImageView()
    let trackNameLabel = UILabel()
    let artistNameLabel = UILabel()
    let priceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(itemImageView)
        addSubview(trackNameLabel)
        addSubview(artistNameLabel)
        addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            // 约束图片视图
            itemImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            itemImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            itemImageView.widthAnchor.constraint(equalToConstant: 80),
            itemImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // 约束 trackNameLabel
            trackNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            trackNameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 16),
            trackNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // 约束 artistNameLabel
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 10),
            artistNameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 16),
            artistNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // 约束 priceLabel
            priceLabel.bottomAnchor.constraint(equalTo: itemImageView.bottomAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        // 样式配置
        itemImageView.contentMode = .scaleAspectFit
        trackNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    func configureWith(_ item: AppStoreItem) {
        if let imageUrl = item.artworkUrl100{
            itemImageView.loadImage(fromURL: imageUrl)
        }
        trackNameLabel.text = item.trackName
        artistNameLabel.text = item.artistName
        priceLabel.text = String(format: "Price: HK$%.2f", item.trackPrice ?? 0.0)
    }
}


// 图片缓存
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(fromURL urlString: String) {
        let cacheKey = NSString(string: urlString)
        // 检查缓存
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        // 确保URL有效
        guard let url = URL(string: urlString) else { return }
        // 异步下载图片
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, error == nil, let data = data, let downloadedImage = UIImage(data: data) else { return }
            // 更新缓存
            imageCache.setObject(downloadedImage, forKey: cacheKey)
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
}
