//
//  WeatherIcon.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    func get(forKey key: String) -> UIImage? { cache.object(forKey: key as NSString) }
    func set(_ image: UIImage, forKey key: String) { cache.setObject(image, forKey: key as NSString) }
}

final class RemoteImageLoader: ObservableObject {
    @Published var image: UIImage?

    func load(from urlString: String) {
        var fixed = urlString
        if fixed.hasPrefix("//") { fixed = "https:" + fixed }
        guard !fixed.isEmpty, let url = URL(string: fixed) else { return }

        if let cached = ImageCache.shared.get(forKey: fixed) {
            image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            ImageCache.shared.set(img, forKey: fixed)
            DispatchQueue.main.async { self?.image = img }
        }.resume()
    }
}

struct WeatherIcon: View {
    let urlString: String
    var size: CGFloat = 64

    @StateObject private var loader = RemoteImageLoader()

    var body: some View {
        Group {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "cloud.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .frame(width: size, height: size)
        .onAppear { loader.load(from: urlString) }
    }
}


struct WeatherIcon_Previews: PreviewProvider {
    static var previews: some View {
        WeatherIcon(urlString: "https://www.flaticon.com/free-icon/location_535239")
    }
}
