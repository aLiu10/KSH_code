//
//  AppListViewModel.swift
//  KSH_CodeTestProj
//
//  Created by lyl on 2024/2/4.
//

import Foundation
import RxSwift
import RxCocoa
import ProgressHUD


enum SortType {
    case none
    case name
    case trackPrice
}

struct FilterCriteria {
    let minPrice: Double?
    let maxPrice: Double?
    let releaseDateRange: ClosedRange<Date>?
}

class AppListViewModel {
    
    // Input
    var searchTerm = PublishSubject<String>()//处理搜索
    var sortType = PublishSubject<SortType>()//处理排序
    var filterCriteria = PublishSubject<FilterCriteria>()//处理过滤
    var isLoading = PublishSubject<Bool>()//处理请求loading
    var errorMessage = PublishSubject<String>()//处理错误信息展示
    
    var items: Observable<[AppStoreModel]> {
        return itemsSubject.asObservable()
    }
    
    private let itemsSubject = BehaviorSubject<[AppStoreModel]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        setupBindings()
    }
    
    //开始绑定
    private func setupBindings() {
        Observable
            .combineLatest(
                searchTerm.debounce(.milliseconds(600), scheduler: MainScheduler.instance).distinctUntilChanged(),
                sortType.startWith(.name),
                filterCriteria.startWith(FilterCriteria(minPrice: nil, maxPrice: nil, releaseDateRange: nil))
            )
            .flatMapLatest { searchTerm, sortType, filterCriteria in
                return self.fetchAndProcessApps(searchTerm: searchTerm, sortType: sortType, filterCriteria: filterCriteria)
            }
            .bind(to: itemsSubject)
            .disposed(by: disposeBag)
        
        sortType
            .flatMapLatest { sortType -> Observable<[AppStoreModel]> in
                let currentItems = (try? self.itemsSubject.value()) ?? []
                let sortedItems = self.sortItems(items: currentItems, by: sortType)
                return Observable.just(sortedItems)
            }
            .bind(to: itemsSubject)
            .disposed(by: disposeBag)
        filterCriteria
            .flatMapLatest { criteria -> Observable<[AppStoreModel]> in
                let currentItems = (try? self.itemsSubject.value()) ?? []
                let sortedItems = self.filterItems(items: currentItems, by: criteria)
                return Observable.just(sortedItems)
            }
            .bind(to: itemsSubject)
            .disposed(by: disposeBag)
    }
    
    private func fetchAndProcessApps(searchTerm: String, sortType: SortType, filterCriteria: FilterCriteria) -> Observable<[AppStoreModel]> {
        return self.searchApps(searchTerm: searchTerm)
            .map { items in
                self.filterItems(items: items, by: filterCriteria)
            }
            .map { items in
                self.sortItems(items: items, by: sortType)
            }
    }
    //搜索请求
    private  func searchApps(searchTerm: String) -> Observable<[AppStoreModel]> {
        return Observable.create { observer in
            self.isLoading.onNext(true)
            APIManager().searchApps(searchTerm: searchTerm) { result in
                self.isLoading.onNext(false)
                switch result {
                case .success(let items):
                    observer.onNext(items)
                    observer.onCompleted()
                    
                case .failure(let error):
                    self.errorMessage.onNext(error.localizedDescription)
                }
            }
            return Disposables.create()
        }
    }
    
    //排序
    private func sortItems(items: [AppStoreModel], by sortType: SortType) -> [AppStoreModel] {
        switch sortType {
        case .name:
            return items.sorted(by: { $0.trackName < $1.trackName })
        case .trackPrice:
            return items.sorted(by: { ($0.trackPrice ?? 0) < ($1.trackPrice ?? 0) })
            // Add additional cases for other sort types if needed
        case .none:
            return items
        }
    }
    
    private func filterItems(items: [AppStoreModel], by criteria: FilterCriteria) -> [AppStoreModel] {
        return items.filter { item in
            //处理价格过滤
            let isWithinPriceRange = (criteria.minPrice == nil || item.trackPrice ?? 0 >= criteria.minPrice!) &&
            (criteria.maxPrice == nil || item.trackPrice ?? 0 <= criteria.maxPrice!)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let releaseDate = dateFormatter.date(from: item.releaseDate) ?? Date.distantPast
            let isWithinReleaseDateRange = criteria.releaseDateRange == nil || criteria.releaseDateRange!.contains(releaseDate)
            return isWithinPriceRange && isWithinReleaseDateRange
        }
    }
    
}

