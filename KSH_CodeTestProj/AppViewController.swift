//
//  AppViewController.swift
//  KSH_CodeTestProj
//
//  Created by lyl on 2024/2/4.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftUI
import ProgressHUD

class AppViewController: UIViewController,UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let section1 = MyCodeTest.shared
    private let viewModel = AppListViewModel()
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(AppTableViewCell.self, forCellReuseIdentifier: "AppCell")
        return table
    }()
    
    let searchBar = UISearchBar()
    let offButton = UIButton()
    let sortByPriceButton = UIButton()
    let stackView = UIStackView()
    let filterStackView = UIStackView()
    
    let priceFilterButton = UIButton(type: .system)
    let dateFilterButton = UIButton(type: .system)
    let pricePickerView = UIPickerView()
    var minPriceValues: [Int] = Array(0...100)
    var maxPriceValues: [Int] = Array(0...100)
    let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
//MARK: UI
    private func setupViews() {
        // 配置 UISearchBar
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        // 配置过滤按钮
        priceFilterButton.setTitle("价格", for: .normal)
        dateFilterButton.setTitle("日期", for: .normal)
        // 设置按钮的点击事件
        priceFilterButton.rx.tap
            .bind { [weak self] in self?.showPricePicker() }
            .disposed(by: disposeBag)
        dateFilterButton.rx.tap
            .bind { [weak self] in self?.showDatePicker() }
            .disposed(by: disposeBag)
        dateFilterButton.rx.tap
            .bind {  }
            .disposed(by: disposeBag)
        
        // 配置UIStackView
        filterStackView.axis = .horizontal
        filterStackView.distribution = .fillEqually
        filterStackView.spacing = 10
        filterStackView.addArrangedSubview(priceFilterButton)
        filterStackView.addArrangedSubview(dateFilterButton)
        
        // 配置选择器
        pricePickerView.delegate = self
        pricePickerView.dataSource = self
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        
        // 配置排序按钮
        configureButton(offButton, title: "Off", isSelected: true)
        configureButton(sortByPriceButton, title: "Sort by Price", isSelected: false)
        
        // 配置 StackView
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .lightGray
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true
        stackView.spacing = 0
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)  // 设置 StackView 与子视图之间的间距
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(offButton)
        stackView.addArrangedSubview(sortByPriceButton)
        // 配置 UITableView
        tableView.register(AppTableViewCell.self, forCellReuseIdentifier: "AppCell")
        view.addSubview(searchBar)
        view.addSubview(filterStackView)
        view.addSubview(stackView)
        view.addSubview(tableView)
        setupConstraints()
    }
    
    private func configureButton(_ button: UIButton, title: String, isSelected: Bool) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(isSelected ? .lightGray : .black, for: .normal)
        button.backgroundColor = isSelected ? .white : .lightGray
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
        button.isSelected = isSelected
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterStackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            filterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            
            stackView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func showPricePicker() {
        let alert = UIAlertController(title: "请选择价格范围", message: "单位:HK$\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
    
        let selectAction = UIAlertAction(title: "确定", style: .default) { _ in
            let minPrice = self.minPriceValues[self.pricePickerView.selectedRow(inComponent: 0)]
            let maxPrice = self.maxPriceValues[self.pricePickerView.selectedRow(inComponent: 1)]
            let criteria = FilterCriteria(minPrice: Double(minPrice), maxPrice: Double(maxPrice), releaseDateRange: nil)
            self.viewModel.filterCriteria.onNext(criteria)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(selectAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: { self.pricePickerView.frame.size.width = alert.view.frame.size.width
            alert.view.addSubview(self.pricePickerView)
        })
    }
    
    func showDatePicker() {
            let alert = UIAlertController(title: "选择日期", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
            alert.view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
                datePicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, multiplier: 0.95),
                datePicker.heightAnchor.constraint(equalToConstant: 160)
            ])

            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak self] _ in
                let selectedDate = self?.datePicker.date
                let criteria = FilterCriteria(minPrice: nil, maxPrice: nil, releaseDateRange: selectedDate!...selectedDate!)
//                self?.viewModel.filterCriteria.onNext(criteria)
            }))

            present(alert, animated: true, completion: nil)
        }
    @objc func toggleButtonTapped(_ sender: UIButton) {
        let isOffButton = sender == offButton
        offButton.isSelected = isOffButton
        sortByPriceButton.isSelected = !isOffButton
        updateButtonStyles()
        // 通知 ViewModel 进行排序
        let sortType: SortType = isOffButton ? .none : .trackPrice
        viewModel.sortType.onNext(sortType)
    }
    
    private func updateButtonStyles() {
        // 更新按钮样式基于它们的选中状态
        configureButton(offButton, title: offButton.currentTitle ?? "Off", isSelected: offButton.isSelected)
        configureButton(sortByPriceButton, title: sortByPriceButton.currentTitle ?? "Sort by Price", isSelected: sortByPriceButton.isSelected)
    }
    
    @objc func toggleOff(sender: UIButton) {
        viewModel.sortType.onNext(.none)
    }
    
    @objc func toggleSortByPrice(sender: UIButton) {
        viewModel.sortType.onNext(.trackPrice)
    }
//MARK: Action
    private func bindViewModel() {
        // 绑定 searchBar 输入到 viewModel 的搜索词
//        searchBar.rx.text.orEmpty
//            .filter { !$0.isEmpty }
//            .bind(to: viewModel.searchTerm)
//            .disposed(by: disposeBag)
        
        offButton.rx.tap
            .map { .none }
            .bind(to: viewModel.sortType)
            .disposed(by: disposeBag)
        
        // 绑定 sortByPriceButton 点击事件进行排序
        sortByPriceButton.rx.tap
            .map { .trackPrice }
            .bind(to: viewModel.sortType)
            .disposed(by: disposeBag)
        
        // 绑定 viewModel 的 items 到 tableView
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: "AppCell", cellType: AppTableViewCell.self)) { index, model, cell in
                cell.configureWith(model)
            }
            .disposed(by: disposeBag)
        
        //loading
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {  isLoading in
                if isLoading {
                    ProgressHUD.show("请稍后...")
                } else {
                    ProgressHUD.dismiss()
                }
            })
            .disposed(by: disposeBag)
        //报错信息
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {  message in
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        // 处理 tableView item 选择
        tableView.rx.modelSelected(AppStoreModel.self)
            .subscribe(onNext: {  item in
                
            })
            .disposed(by: disposeBag)
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return minPriceValues.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = "\(minPriceValues[row])"
        return component == 0 ? "\(value)" : "\(value)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let minPrice = minPriceValues[pricePickerView.selectedRow(inComponent: 0)]
        let maxPrice = maxPriceValues[pricePickerView.selectedRow(inComponent: 1)]
        
        // 防止左列大于👉🏻列
        if maxPrice < minPrice {
            if component == 0 {
                if let newIndex = maxPriceValues.firstIndex(where: { $0 >= minPrice }) {
                    pickerView.selectRow(newIndex, inComponent: 1, animated: true)
                }
            } else {
                if let newIndex = minPriceValues.firstIndex(where: { $0 <= maxPrice }) {
                    pickerView.selectRow(newIndex, inComponent: 0, animated: true)
                }
            }
        }
    }
    
}

extension AppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
extension AppViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let searchText = searchBar.text {
            viewModel.searchTerm.onNext(searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        // 取消搜索,重置数据源
        viewModel.searchTerm.onNext("")
    }
}

struct AppViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AppViewController {
        return AppViewController()
    }
    
    func updateUIViewController(_ uiViewController: AppViewController, context: Context) {
    }
}


