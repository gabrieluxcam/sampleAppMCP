import UIKit

class ProfileViewController: UIViewController {
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let changePhotoButton = UIButton(type: .system)
    private let infoStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfileData()
        setupUI()
        setupConstraints()
    }
    
    private func loadProfileData() {
        // Load saved profile image if exists
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        // Configure profile image
        profileImageView.image = profileImageView.image ?? UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemBlue
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 60
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.systemBlue.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Configure name label
        nameLabel.text = UserDefaults.standard.string(forKey: "userName") ?? "John Doe"
        nameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .label
        
        // Configure email label
        emailLabel.text = UserDefaults.standard.string(forKey: "userEmail") ?? "john.doe@example.com"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textAlignment = .center
        emailLabel.textColor = .secondaryLabel
        
        // Configure change photo button
        changePhotoButton.setTitle("Change Photo", for: .normal)
        changePhotoButton.backgroundColor = .systemGreen
        changePhotoButton.setTitleColor(.white, for: .normal)
        changePhotoButton.layer.cornerRadius = 8
        changePhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        
        // Configure edit button
        editButton.setTitle("Edit Profile", for: .normal)
        editButton.backgroundColor = .systemBlue
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 12
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        
        // Configure stack view
        infoStackView.axis = .vertical
        infoStackView.spacing = 12
        infoStackView.alignment = .center
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(emailLabel)
        
        // Add info rows
        addInfoRow(title: "Location", value: UserDefaults.standard.string(forKey: "userLocation") ?? "San Francisco, CA")
        addInfoRow(title: "Member Since", value: "January 2024")
        addInfoRow(title: "Posts", value: "42")
        
        view.addSubview(profileImageView)
        view.addSubview(changePhotoButton)
        view.addSubview(infoStackView)
        view.addSubview(editButton)
    }
    
    private func addInfoRow(title: String, value: String) {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .secondaryLabel
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        infoStackView.addArrangedSubview(containerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Profile image
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Change photo button
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
            changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePhotoButton.widthAnchor.constraint(equalToConstant: 120),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Info stack view
            infoStackView.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 20),
            infoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Edit button
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            editButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func profileImageTapped() {
        changePhotoTapped()
    }
    
    @objc private func changePhotoTapped() {
        let alert = UIAlertController(title: "Change Profile Photo", message: "Choose an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { _ in
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")
            UserDefaults.standard.removeObject(forKey: "profileImage")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = changePhotoButton
            popover.sourceRect = changePhotoButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let alert = UIAlertController(title: "Not Available", message: "The selected source is not available on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func editTapped() {
        let alert = UIAlertController(title: "Edit Profile", message: "Update your information", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = self.nameLabel.text
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.text = self.emailLabel.text
            textField.keyboardType = .emailAddress
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Location"
            textField.text = UserDefaults.standard.string(forKey: "userLocation") ?? "San Francisco, CA"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let name = alert.textFields?[0].text, !name.isEmpty {
                self.nameLabel.text = name
                UserDefaults.standard.set(name, forKey: "userName")
            }
            
            if let email = alert.textFields?[1].text, !email.isEmpty {
                self.emailLabel.text = email
                UserDefaults.standard.set(email, forKey: "userEmail")
            }
            
            if let location = alert.textFields?[2].text, !location.isEmpty {
                UserDefaults.standard.set(location, forKey: "userLocation")
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
            // Save image to UserDefaults
            if let imageData = editedImage.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "profileImage")
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            // Save image to UserDefaults
            if let imageData = originalImage.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "profileImage")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
} 