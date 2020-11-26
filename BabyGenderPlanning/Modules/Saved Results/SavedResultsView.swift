//
//  SavedResultsView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 06.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import PinLayout

final class SavedResultsView: UIView {
    typealias ResultSection = SectionModel<String, CalculationInfo>
    
    private var dataSource: RxTableViewSectionedReloadDataSource<ResultSection>!
    
    private let presenter: SavedResultsPresenterProtocol
    private let disposeBag = DisposeBag()
    
    private let deleteCalculation = PublishRelay<CalculationInfo>()
    private let showAllDates = PublishRelay<CalculationInfo>()
    private let recommendations = PublishRelay<Gender>()
    
    // MARK: - UI Elements
    
    private lazy var headerView: HeaderTitleView = {
        return HeaderTitleView(title: Localized.sideMenu_savedResults())
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(cellType: SavedResultTableViewCell.self)

        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset.top = safeAreaInsets.top + 10
        tableView.contentInset.bottom = safeAreaInsets.bottom + 120

        return tableView
    }()
    
    private lazy var newPlanningButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.newReckoning_button_title(), for: .normal)
        
        return button
    }()

    // MARK: - Lifecycle

    init(_ presenter: SavedResultsPresenterProtocol) {
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
        applyGradient(colors: .pink)
        configureSubviews()
    }
}

// MARK: - UI Bindings

extension SavedResultsView {
    private func setupBindings() {
        let input = SavedResultsPresenter.Input(
            deleteCalculation: deleteCalculation.asObservable(),
            showAllDates: showAllDates.asObservable(),
            recommendations: recommendations.asObservable(),
            didTapNewPlanning: newPlanningButton.rx.tap.asObservable()
        )
        
        let output = presenter.buildOutput(with: input)
        
        disposeBag.insert(
            tableView.rx.setDelegate(self),
            output.dataSource.drive(tableView.rx.items(dataSource: dataSource))
        )
    }
}

// MARK: - Private Methods

extension SavedResultsView {
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        addSubviews(headerView, tableView, newPlanningButton)
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
        
        newPlanningButton.pin
            .height(55)
            .width(275)
            .bottom(45)
            .hCenter()
    }
}

// MARK: - UITableViewDelegate

extension SavedResultsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 283
    }
}

// MARK: - Data Source Configuration

extension SavedResultsView {
    private func setupDataSource() {
        dataSource = .init(
            configureCell: configureCell
        )
    }

    private var configureCell: RxTableViewSectionedReloadDataSource<ResultSection>.ConfigureCell {
        return { [weak self] _, tableView, indexPath, calculationInfo in
            let cell: SavedResultTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(calculationInfo: calculationInfo)

            guard let self = self else { return cell }
            
            cell.recommendations.bind(to: self.recommendations).disposed(by: cell.disposeBag)
            cell.delete.bind(to: self.deleteCalculation).disposed(by: cell.disposeBag)
            cell.allDates.bind(to: self.showAllDates).disposed(by: cell.disposeBag)

            return cell
        }
    }
}
