//
//  AudioDownloadManager.swift
//  WorldNoor
//
//  Created by Awais on 28/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

class AudioDownloadManager {
    static let shared = AudioDownloadManager()

    private let downloadDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    private let cache = NSCache<NSURL, NSData>()
    private var downloadTasks: [URL: URLSessionDownloadTask] = [:]

    func downloadCacheAudio(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let destinationURL = downloadDirectory.appendingPathComponent("audio_\(url.lastPathComponent)")
        let cacheURL = cacheDirectory.appendingPathComponent("audio_\(url.lastPathComponent)")

        if FileManager.default.fileExists(atPath: cacheURL.path) {
            completion(.success(cacheURL))
            return
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            do {
                try FileManager.default.copyItem(at: destinationURL, to: cacheURL)
                completion(.success(destinationURL))
            } catch {
                LogClass.debugLog("Failed to copy item to cache: \(error)")
            }

            return
        }

        if let existingTask = downloadTasks[url] {
            existingTask.resume()
            return
        }

        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (temporaryURL, _, error) in
            guard let self = self else { return }

            defer { self.downloadTasks[url] = nil }

            if let error = error {
                completion(.failure(error))
            } else if let temporaryURL = temporaryURL {
                do {
                    try FileManager.default.moveItem(at: temporaryURL, to: destinationURL)
                    try FileManager.default.copyItem(at: destinationURL, to: cacheURL)

                    completion(.success(destinationURL))
                } catch {
                    LogClass.debugLog("Failed audio file to move/copy: \(error)")
                    completion(.failure(error))
                }
            }
        }

        downloadTasks[url] = downloadTask
        downloadTask.resume()
    }
    
    func downloadCacheDataAudio(from url: URL, completion: @escaping (Result<(URL, Data), Error>) -> Void) {
        let destinationURL = downloadDirectory.appendingPathComponent("audio_\(url.lastPathComponent)")

        if let cachedData = cache.object(forKey: url as NSURL) as? Data {

            completion(.success((destinationURL, cachedData)))
            return
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            do {
                let data = try Data(contentsOf: destinationURL)
                cache.setObject(data as NSData, forKey: url as NSURL)

                completion(.success((destinationURL, data)))
            } catch {
                LogClass.debugLog("Failed to copy item to cache: \(error)")
            }

            return
        }

        if let existingTask = downloadTasks[url] {
            existingTask.resume()
            return
        }

        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (temporaryURL, _, error) in
            guard let self = self else { return }

            defer { self.downloadTasks[url] = nil }

            if let error = error {
                completion(.failure(error))
            } else if let temporaryURL = temporaryURL {
                do {
                    try FileManager.default.moveItem(at: temporaryURL, to: destinationURL)

                    let data = try Data(contentsOf: destinationURL)
                    cache.setObject(data as NSData, forKey: url as NSURL)

                    completion(.success((destinationURL, data)))
                } catch {
                    LogClass.debugLog("Failed audio file to move/copy: \(error)")
                    completion(.failure(error))
                }
            }
        }

        downloadTasks[url] = downloadTask
        downloadTask.resume()
    }

    func downloadAudio(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let destinationURL = downloadDirectory.appendingPathComponent("audio_\(url.lastPathComponent)")

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            completion(.success(destinationURL))
            return
        }

        if let existingTask = downloadTasks[url] {
            existingTask.resume()
            return
        }

        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (temporaryURL, _, error) in
            guard let self = self else { return }

            defer { self.downloadTasks[url] = nil }

            if let error = error {
                completion(.failure(error))
            } else if let temporaryURL = temporaryURL {
                do {
                    try FileManager.default.moveItem(at: temporaryURL, to: destinationURL)

                    completion(.success(destinationURL))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        downloadTasks[url] = downloadTask
        downloadTask.resume()
    }
}
