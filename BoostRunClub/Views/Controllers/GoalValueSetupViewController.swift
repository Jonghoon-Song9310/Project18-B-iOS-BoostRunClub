//
//  GoalValueSetupViewController.swift
//  BoostRunClub
//
//  Created by 조기현 on 2020/11/26.
//

import Combine
import UIKit

class GoalValueSetupViewController: UIViewController {
    var keyboardType: UIKeyboardType = .default
    let goalValueView = GoalValueView()
    var viewModel: GoalValueSetupViewModelTypes?
    var cancellables = Set<AnyCancellable>()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(with goalValueVM: GoalValueSetupViewModelTypes) {
        super.init(nibName: nil, bundle: nil)
        viewModel = goalValueVM
    }

    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        keyboardType = viewModel.outputs.goalType == GoalType.distance ? .decimalPad : .numberPad

        viewModel.outputs.goalValueObservable
            .receive(on: RunLoop.main)
            .sink { [weak self] goalValue in
                let value = goalValue.isEmpty ? "0" : goalValue
                self?.goalValueView.setLabelText(goalValue: value, goalUnit: viewModel.outputs.goalType.unit)
                self?.view.layoutIfNeeded()
            }
            .store(in: &cancellables)
    }
}

// MARK: - LifeCycle

extension GoalValueSetupViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItems()
        configureLayout()
        bindViewModel()
        goalValueView.becomeFirstResponder()
    }
}

// MARK: - Actions

extension GoalValueSetupViewController {
    @objc
    func didTapCancelItem() {
        viewModel?.inputs.didTapCancelButton()
    }

    @objc
    func didTapApplyItem() {
        viewModel?.inputs.didTapApplyButton()
    }
}

// MARK: UIKeyInput

extension GoalValueSetupViewController: UIKeyInput {
    var hasText: Bool {
        return false
    }

    func insertText(_ text: String) {
        viewModel?.inputs.didInputNumber(text)
    }

    func deleteBackward() {
        viewModel?.inputs.didDeleteBackward()
    }

    override var canBecomeFirstResponder: Bool { true }
}

// MARK: - Configure

extension GoalValueSetupViewController {
    private func configureLayout() {
        view.addSubview(goalValueView)
        goalValueView.translatesAutoresizingMaskIntoConstraints = false
        let constraint = goalValueView.centerYAnchor.constraint(equalTo: view.topAnchor)
        constraint.constant = UIScreen.main.bounds.height / 3
        NSLayoutConstraint.activate([
            goalValueView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            constraint,
            goalValueView.underline.leadingAnchor.constraint(equalTo: goalValueView.setGoalDetailButton.leadingAnchor, constant: -5),
        ])
    }

    private func configureNavigationItems() {
        guard let viewModel = viewModel else { return }

        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "목표 \(viewModel.outputs.goalType.description)"

        let cancelItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(didTapCancelItem)
        )
        navigationItem.setLeftBarButton(cancelItem, animated: true)

        let applyItem = UIBarButtonItem(
            title: "설정",
            style: .plain,
            target: self,
            action: #selector(didTapApplyItem)
        )
        navigationItem.setRightBarButton(applyItem, animated: true)
    }
}
