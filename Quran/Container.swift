//
//  Container.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/20/16.
//  Copyright © 2016 Quran.com. All rights reserved.
//

import UIKit

class Container {

    private static let DownloadsBackgroundIdentifier = "com.quran.ios.downloading.audio"

    private let imagesCache: Cache = {
        let cache = NSCache()
        cache.countLimit = 10
        return cache
    }()

    private var downloadManager: DownloadManager! = nil

    init() {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("DownloadsBackgroundIdentifier")
        downloadManager = URLSessionDownloadManager(configuration: configuration, persistence: createSimplePersistence())
    }

    func createRootViewController() -> UIViewController {
        let controller = MainTabBarController()
        controller.viewControllers = [createSurasNavigationController(),
                                      createJuzsNavigationController(),
                                      createBookmarksController()]
        return controller
    }

    func createSurasNavigationController() -> UIViewController {
        return SurasNavigationController(rootViewController: createSurasViewController())
    }

    func createJuzsNavigationController() -> UIViewController {
        return JuzsNavigationController(rootViewController: createJuzsViewController())
    }

    func createSurasViewController() -> UIViewController {
        return SurasViewController(dataRetriever: createSurasRetriever(), quranControllerCreator: createBlockCreator(createQuranController))
    }

    func createJuzsViewController() -> UIViewController {
        return JuzsViewController(dataRetriever: createQuartersRetriever(), quranControllerCreator: createBlockCreator(createQuranController))
    }

    func createSearchController() -> UIViewController {
        return SearchNavigationController(rootViewController: SearchViewController())
    }

    func createSettingsController() -> UIViewController {
        return SettingsNavigationController(rootViewController: SettingsViewController())
    }

    func createBookmarksController() -> UIViewController {
        return BookmarksNavigationController(rootViewController: createBookmarksViewController())
    }

    func createBookmarksViewController() -> UIViewController {
        return BookmarksTableViewController(persistence: createSimplePersistence(),
                                            quranControllerCreator: createBlockCreator(createQuranController))
    }

    func createQariTableViewController() -> QariTableViewController {
        return QariTableViewController(style: .Plain)
    }

    func createSurasRetriever() -> AnyDataRetriever<[(Juz, [Sura])]> {
        return SurasDataRetriever().erasedType()
    }

    func createQuartersRetriever() -> AnyDataRetriever<[(Juz, [Quarter])]> {
        return QuartersDataRetriever().erasedType()
    }

    func createQuranPagesRetriever() -> AnyDataRetriever<[QuranPage]> {
        return QuranPagesDataRetriever().erasedType()
    }

    func createQarisDataRetriever() -> AnyDataRetriever<[Qari]> {
        return QariDataRetriever().erasedType()
    }

    func createAyahInfoStorage() -> AyahInfoStorage {
        return AyahInfoPersistenceStorage()
    }

    func createAyahTextStorage() -> AyahTextStorageProtocol {
        return AyahTextPersistenceStorage()
    }

    func createAyahInfoRetriever() -> AyahInfoRetriever {
        return SQLiteAyahInfoRetriever(persistence: createAyahInfoStorage())
    }

    func createQuranController() -> QuranViewController {
        return QuranViewController(
            persistence: createSimplePersistence(),
            imageService: createQuranImageService(),
            dataRetriever: createQuranPagesRetriever(),
            ayahInfoRetriever: createAyahInfoRetriever(),
            audioViewPresenter: createAudioBannerViewPresenter(),
            qarisControllerCreator: createBlockCreator(createQariTableViewController)
        )
    }

    func createBlockCreator<CreatedObject>(creationClosure: () -> CreatedObject) -> AnyCreator<CreatedObject> {
        return BlockCreator(creationClosure: creationClosure).erasedType()
    }

    func createQuranImageService() -> QuranImageService {
        return DefaultQuranImageService(imagesCache: createImagesCache())
    }

    func createImagesCache() -> Cache {
        return imagesCache
    }

    func createAudioBannerViewPresenter() -> AudioBannerViewPresenter {
        return DefaultAudioBannerViewPresenter(persistence: createSimplePersistence(),
                                               qariRetreiver: createQarisDataRetriever(),
                                               gaplessAudioPlayer: createGaplessAudioPlayerInteractor(),
                                               gappedAudioPlayer: createGappedAudioPlayerInteractor())
    }

    func createUserDefaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }

    func createSimplePersistence() -> SimplePersistence {
        return UserDefaultsSimplePersistence(userDefaults: createUserDefaults())
    }

    func createSuraLastAyahFinder() -> LastAyahFinder {
        return SuraBasedLastAyahFinder()
    }

    func createPageLastAyahFinder() -> LastAyahFinder {
        return PageBasedLastAyahFinder()
    }

    func createJuzLastAyahFinder() -> LastAyahFinder {
        return JuzBasedLastAyahFinder()
    }

    func createDownloadManager() -> DownloadManager {
        return downloadManager
    }

    func createGappedAudioDownloader() -> AudioFilesDownloader {
        return GappedAudioFilesDownloader(downloader: createDownloadManager())
    }

    func createGaplessAudioDownloader() -> AudioFilesDownloader {
        return GaplessAudioFilesDownloader(downloader: createDownloadManager())
    }

    func createGappedAudioPlayer() -> AudioPlayer {
        return GappedAudioPlayer()
    }

    func createGaplessAudioPlayer() -> AudioPlayer {
        return GaplessAudioPlayer(timingRetriever: createQariTimingRetriever())
    }

    func createGaplessAudioPlayerInteractor() -> AudioPlayerInteractor {
        return GaplessAudioPlayerInteractor(downloader: createGaplessAudioDownloader(),
                                            lastAyahFinder: createJuzLastAyahFinder(),
                                            player: createGaplessAudioPlayer())
    }

    func createGappedAudioPlayerInteractor() -> AudioPlayerInteractor {
        return GappedAudioPlayerInteractor(downloader: createGappedAudioDownloader(),
                                           lastAyahFinder: createJuzLastAyahFinder(),
                                           player: createGappedAudioPlayer())
    }

    func createQariTimingRetriever() -> QariTimingRetriever {
        return SQLiteQariTimingRetriever(persistence: createQariAyahTimingPersistenceStorage())
    }

    func createQariAyahTimingPersistenceStorage() -> QariAyahTimingPersistenceStorage {
        return SQLiteAyahTimingPersistenceStorage()
    }
}
