//
//  Parent Picker.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 04.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RxDataSources
import RealmSwift

final class ParentPickerView: UIView, InsertableView {
    typealias ParentSection = SectionModel<String, ParentInfo>
    
    var newStepObservable: Observable<RouteStep> = .empty()
    var dismissObservable: Observable<Void> = .empty()
    
    private var dataSource: RxTableViewSectionedReloadDataSource<ParentSection>!
    private let parentsDataSource = BehaviorRelay<[ParentInfo]>(value: [])
    private let gender: Gender
    private let disposeBag = DisposeBag()
    // MARK: - UI Elements
    
    private lazy var headerView: HeaderTitleView = {
        let view = HeaderTitleView(title: Localized.page_title_parents(), isBackButton: true)
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(viewType: ParentSectionHeaderView.self)
        tableView.register(cellType: ParentTableViewCell.self)

        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = safeAreaInsets.bottom + 6

        return tableView
    }()
    
    // MARK: - Lifecycle

    init(gender: Gender) {
        self.gender = gender
        super.init(frame: .zero)
        
        setupDataSource()
        setupBindings()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(colors: .pink)
        configureSubviews()
    }
}

// MARK: - Bindings

extension ParentPickerView {
    func setupBindings() {
        dismissObservable = headerView.menuButtonClicked
        newStepObservable = tableView.rx.modelSelected(ParentInfo.self)
            .map(ReceivableType.parent)
            .map(RouteStep.dismissAndPass)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let realmParents = RealmStorage.default.objects(Parent.self)

        Observable.collection(from: realmParents)
            .map { $0.map(ParentInfo.init) }
            .map { [unowned self] parents in parents.filter { $0.gender == self.gender } }
            .bind(to: parentsDataSource)
            .disposed(by: disposeBag)
            
        parentsDataSource
            .map { [SectionModel(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout

extension ParentPickerView {
    func configureLayout() {
        pin.vertically().horizontally()
    }
    
    private func setupSubviews() {
        addSubviews(headerView, tableView)
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()
        
        tableView.pin
            .below(of: headerView)
            .horizontally()
            .bottom()
    }
}

// MARK: - UITableViewDelegate

extension ParentPickerView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return parentsDataSource.value[indexPath.row].bloodLossDate == nil ? 137 : 173
    }
}

// MARK: - Data Source Configuration

extension ParentPickerView {
    private func setupDataSource() {
        dataSource = .init(
            configureCell: configureCell
        )
    }

    private var configureCell: RxTableViewSectionedReloadDataSource<ParentSection>.ConfigureCell {
        return { _, tableView, indexPath, parent in
            let cell: ParentTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(parent: parent)
            cell.hideHeaderButtons()
            
            return cell
        }
    }
}
