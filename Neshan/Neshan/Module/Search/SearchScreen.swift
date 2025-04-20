import UIKit
import Combine

class SearchScreen: UIViewController {
    let viewModel: SearchViewModel

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = Colors.textColor
        return indicator
    }()

    
    private var cancellables = Set<AnyCancellable>()

    var items = [SearchItemDto]()
    var searchTerm: String = ""
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.viewModel.cancel.send(())
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.textField.endEditing(true)
        self.viewModel.cancel.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
        setupLoading()
    }

    fileprivate func setupUI() {
        tableView.estimatedRowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupLoading() {
        tableView.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 50),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
    
    fileprivate func binding() {
        viewModel.isLoading
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingIndicator.startAnimating(): self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        NotificationCenter.default
                    .publisher(for: UITextField.textDidChangeNotification, object: textField)
                    .map( {
                        ($0.object as? UITextField)?.text ?? ""
                    })
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .sink { [weak self] txt in
                guard let self = self else { return }
                self.searchTerm = txt
                self.viewModel.searchTerm.send(txt)
            }
            .store(in: &cancellables)
  
        viewModel.searchResult
            .sink { [weak self] list in
                guard let self = self else { return }
                self.items.removeAll()
                self.tableView.reloadData()
                self.items.append(contentsOf: list ?? [])
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension SearchScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var items = self.items
        var item: SearchItemDto?
        
        if let index = self.items.firstIndex(where: { $0 == self.items[indexPath.row]}) {
            item = items.remove(at: index)
        }
        self.viewModel.selectedItem.send((term: self.searchTerm, selectedItem: item!, result: items))  
    }
}

extension SearchScreen: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            return cell
        }()
        cell.semanticContentAttribute = .forceRightToLeft
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = self.items[indexPath.row].title
        
        return cell
    }
}
