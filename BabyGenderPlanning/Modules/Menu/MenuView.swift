//
//  MenuView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

final class MenuView: UIView {
    typealias MenuSection = SectionModel<String, MenuRow>

    private let presenter: MenuPresenterProtocol
    private let disposeBag = DisposeBag()

    private var dataSource: RxTableViewSectionedReloadDataSource<MenuSection>!

    // MARK: - UI Elements

    private lazy var headerView: MenuHeaderView = {
        return MenuHeaderView()
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cellType: MenuTableViewCell.self)

        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        tableView.rowHeight = 38
        tableView.estimatedRowHeight = 38

        return tableView
    }()
    
    // MARK: - Lifecycle
    
    init(_ presenter: MenuPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)

        backgroundColor = .appWhite

        setupSubviews()
        setupDataSource()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
}

// MARK: - UI Bindings

extension MenuView {
    private func setupBindings() {
        let input = MenuPresenter.Input(
            selectedBlock: tableView.rx.modelSelected(MenuRow.self).asObservable()
        )
        let output = presenter.buildOutput(with: input)

        disposeBag.insert(
            output.dataSource.drive(tableView.rx.items(dataSource: dataSource))
        )
    }
}

// MARK: - Layout

extension MenuView {
    
    private func setupSubviews() {
        addSubviews(headerView, tableView)
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(20)
            .top(pin.safeArea)
            .horizontally(15)
            .marginTop(25)
        
        tableView.pin
            .below(of: headerView)
            .horizontally()
            .bottom(pin.safeArea)
            .marginTop(25)
    }
}

// MARK: - Data Source Configuration

extension MenuView {
    private func setupDataSource() {
        dataSource = .init(
            configureCell: configureCell
        )
    }

    private var configureCell: RxTableViewSectionedReloadDataSource<MenuSection>.ConfigureCell {
        return { _, tableView, indexPath, row in
            let cell: MenuTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(row: row)

            return cell
        }
    }
}
