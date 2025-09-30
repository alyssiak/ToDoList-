import Foundation
import UIKit

final class EditTaskViewController: UIViewController, EditTaskViewInput, UITextViewDelegate {
    var output: EditTaskViewOutput?
    
    private let header = UIStackView()
    private let backButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let titleField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.textColor = .white
        field.font = .boldSystemFont(ofSize: 32)
        field.placeholder = "Название"
        field.tintColor = .systemYellow
        return field
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let descView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .black
        tv.textColor = .white
        tv.font = .systemFont(ofSize: 17)
        tv.tintColor = .systemYellow
        return tv
    }()
    
    // placeholder для UITextView
    private let descPlaceholder: UILabel = {
        let l = UILabel()
        l.text = "Описание"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 17)
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = ""
        descView.delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        backButton.setTitle("Назад", for: .normal)
        backButton.setTitleColor(.systemYellow, for: .normal)
        backButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.systemYellow, for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        header.axis = .horizontal
        header.distribution = .equalSpacing
        header.alignment = .center
        header.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 8, right: 16)
        header.isLayoutMarginsRelativeArrangement = true
        header.addArrangedSubview(backButton)
        header.addArrangedSubview(saveButton)
        
        view.addSubview(header)
        view.addSubview(titleField)
        view.addSubview(dateLabel)
        view.addSubview(descView)
        descView.addSubview(descPlaceholder)
        
        
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        descPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descPlaceholder.topAnchor.constraint(equalTo: descView.topAnchor, constant: 8),
            descPlaceholder.leadingAnchor.constraint(equalTo: descView.leadingAnchor)
        ])
        
        let df = DateFormatter()
        df.dateStyle = .short
        df.dateFormat = "dd/MM/yy"
        dateLabel.text = df.string(from: Date())
        
        output?.viewDidLoad()
        titleField.becomeFirstResponder()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let pad: CGFloat = 16
        let w = view.bounds.width - pad * 2
        let top = header.frame.maxY + pad
        
        titleField.frame = CGRect(x: pad, y: top, width: w, height: 60)
        dateLabel.frame = CGRect(x: pad, y: titleField.frame.maxY + 4, width: w, height: 16)
        descView.frame = CGRect(x: pad, y: dateLabel.frame.maxY + 12, width: w, height: view.bounds.height - (dateLabel.frame.maxY + 12) - pad)
        
        descPlaceholder.frame = CGRect(x: descView.frame.minX + 5, y: descView.frame.minY + 8, width: descView.frame.width - 10, height: 20
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Действия пользователя
    @objc private func cancelTapped() {
        output?.cancelTapped()
    }
    
    @objc private func saveTapped() {
        let titleText = titleField.text ?? ""
        let descText = descView.text
        output?.saveTapped(title: titleText, desc: descText)
    }
    
    // MARK: - EditTaskViewInput
    
    func fill(title: String, desc: String?) {
        titleField.text = title
        descView.text = desc
        descPlaceholder.isHidden = !(desc ?? "").isEmpty
        
    }
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let placeholder = descView.subviews.compactMap({ $0 as? UILabel }).first {
            placeholder.isHidden = !textView.text.isEmpty
        }
    }
    
}
