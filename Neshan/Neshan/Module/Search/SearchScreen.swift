import UIKit
import Combine

class SearchScreen: UIViewController {
    let viewModel: SearchViewModel

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var cancellables = Set<AnyCancellable>()  // Replace DisposeBag with Set<AnyCancellable>

    var items = [SearchItemDto]()
    var searchTerm: String = ""
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.textField.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
    }

    fileprivate func setupUI() {
        tableView.estimatedRowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func binding() {
        // Replacing RxSwift's textField.rx.text with Combine's textField.publisher
        NotificationCenter.default
                    .publisher(for: UITextField.textDidChangeNotification, object: textField)
                    .map( {
                        ($0.object as? UITextField)?.text ?? ""
                    })
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main) // Debounce
            .sink { [weak self] txt in
                guard let self = self else { return }
                self.searchTerm = txt
                self.viewModel.searchTerm.send(txt)  // Send value using Combine's PassthroughSubject
            }
            .store(in: &cancellables)
        
        // Binding searchResult to update UI
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
        self.viewModel.selectedItem.send((term: self.searchTerm, selectedItem: item!, result: items))  // Send value using PassthroughSubject
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
