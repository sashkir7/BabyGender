//
//  ParentsListView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ParentsListView: UIView {
    typealias ParentSection = SectionModel<String, ParentInfo>

    private let presenter: ParentsListPresenterProtocol
    private let disposeBag = DisposeBag()

    private var dataSource: RxTableViewSectionedReloadDataSource<ParentSection>!
    
    // MARK: - Relays
    
    let editParent = PublishRelay<ParentInfo>()
    let deleteParent = PublishRelay<ParentInfo>()

    // MARK: - UI Elements

    private lazy var headerView: HeaderTitleView = {
        let view = HeaderTitleView(title: Localized.page_title_parents(), optionsButtonImage: Image.add())
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(viewType: ParentSectionHeaderView.self)
        tableView.register(cellType: ParentTableViewCell.self)

        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = safeAreaInsets.bottom + 6

        return tableView
    }()

    // MARK: - Lifecycle
    
    init(_ presenter: ParentsListPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)

        setupSubviews()
        setupDataSource()
        setupBindings()
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

// MARK: - UI Bindings

extension ParentsListView {
    private func setupBindings() {
        let input = ParentsListPresenter.Input(
            addNewParent: headerView.optionsButtonClicked,
            editParent: editParent.asObservable(),
            deleteParent: deleteParent.asObservable()
        )
        
        let output = presenter.buildOutput(with: input)

        disposeBag.insert(
            tableView.rx.setDelegate(self),
            output.dataSource.drive(tableView.rx.items(dataSource: dataSource))
        )
    }
}

// MARK: - Layout

extension ParentsListView {
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

extension ParentsListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = dataSource[indexPath.section].items[indexPath.row]
        return row.bloodLossDate == nil ? 137 : 173
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: ParentSectionHeaderView = tableView.dequeueReusableHeaderFooterView()
        let gender = dataSource[section].items.first?.gender ?? .male
        view.configure(with: gender)

        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - Data Source Configuration

extension ParentsListView {
    private func setupDataSource() {
        dataSource = .init(
            configureCell: configureCell
        )
    }

    private var configureCell: RxTableViewSectionedReloadDataSource<ParentSection>.ConfigureCell {
        return { [weak self] _, tableView, indexPath, parent in
            let cell: ParentTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(parent: parent)

            guard let self = self else { return cell }
            
            cell.edit.bind(to: self.editParent).disposed(by: cell.disposeBag)
            cell.delete.bind(to: self.deleteParent).disposed(by: cell.disposeBag)

            return cell
        }
    }
}
