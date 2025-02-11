import UIKit

final class StatisticViewController: UIViewController {
    
    // MARK: - Private Dependencies
    private var alertService: AlertServiceProtocol?
    private var statisticViewModel: StatisticViewModelProtocol
    
    // MARK: - Private Properties
    private lazy var refreshControl = UIRefreshControl()
    
    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .whiteDay
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StatisticCollectionViewCell.self)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    init(statisticViewModel: StatisticViewModelProtocol) {
        self.statisticViewModel = statisticViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupUI()
        setupTargets()
        setupNavBar()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarClear(true)
        blockUI(withBlur: true)
        statisticViewModel.fetchUsersRating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.instance.sentEvent(screen: .statisticMain, item: .screen, event: .open)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.instance.sentEvent(screen: .statisticMain, item: .screen, event: .close)
    }
}

// MARK: - DataSource
extension StatisticViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        statisticViewModel.usersRatingObservable.wrappedValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StatisticCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.setupNumberLabelText(text: String(indexPath.row + 1))
        cell.setupCellUI(model: statisticViewModel.usersRatingObservable.wrappedValue[indexPath.row])
        return cell
    }
}

// MARK: - DelegateFlowLayout
extension StatisticViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let statisticUserViewModel = StatisticUserViewModel(
            profile: statisticViewModel.usersRatingObservable.wrappedValue[indexPath.row])
        
        let statisticUserViewController = StatisticUserViewController(statisticUserViewModel: statisticUserViewModel)
        AnalyticsService.instance.sentEvent(screen: .statisticMain, item: .buttonGoToUserSite, event: .close)
        navigationController?.pushViewController(statisticUserViewController, animated: true)
    }
}

extension StatisticViewController {
    
    // MARK: - Objc Methods:
    @objc
    private func didTapSortButton() {
        showActionSheet()
        AnalyticsService.instance.sentEvent(screen: .statisticMain, item: .buttonSorting, event: .click)
    }
    
    @objc private func refreshNFTCatalog() {
        blockUI(withBlur: false)
        statisticViewModel.fetchUsersRating()
        AnalyticsService.instance.sentEvent(screen: .statisticMain, item: .buttonSorting, event: .pull)
    }
    
    // MARK: - Private Functions
    private func showActionSheet() {
        alertService = UniversalAlertService()
        alertService?.showActionSheet(title: L10n.Sorting.title, sortingOptions: [.byName, .byRating, .close], on: self) { selectedOptions in
            self.performSorting(selectedOptions)
        }
    }
    
    private func performSorting(_ selectedOptions: SortingOption) {
        switch selectedOptions {
        case .byName:
            statisticViewModel.sortUsers(by: .byName, usersList: statisticViewModel.usersRatingObservable.wrappedValue)
            AnalyticsService.instance.sentEvent(screen: .statisticMain, item: .buttonSortingByName, event: .click)
        case .byRating:
            statisticViewModel.sortUsers(by: .byRating, usersList: statisticViewModel.usersRatingObservable.wrappedValue)
            AnalyticsService.instance.sentEvent(screen: .statisticMain, item: .buttonSortingByRating, event: .click)
        default:
            break
        }
        alertService = nil
    }
    
    private func bind() {
        statisticViewModel.usersRatingObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.resumeMethodOnMainThread(self.endRefreshing, with: ())
            self.resumeMethodOnMainThread(self.collectionView.reloadData, with: ())
        }
        
        statisticViewModel.networkErrorObservable.bind { [weak self] errorText in
            guard let self = self else { return }
            if errorText == nil {
                self.resumeMethodOnMainThread(self.endRefreshing, with: ())
            } else {
                self.resumeMethodOnMainThread(self.endRefreshing, with: ())
                self.resumeMethodOnMainThread(self.showNotificationBanner, with: errorText ?? "")
            }
        }
    }
    
    private func endRefreshing() {
        self.refreshControl.endRefreshing()
        self.unblockUI()
        self.isNavigationBarClear(false)
    }
    
    private func setupViews() {
        view.setupView(collectionView)
        setupBackButtonItem()
        collectionView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = .whiteDay
    }
    
    private func setupTargets() {
        refreshControl.addTarget(self, action: #selector(refreshNFTCatalog), for: .valueChanged)
    }
    
    private func setupNavBar() {
        let sortButton = SortNavBarBaseButton()
        sortButton.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
    }
}
