import UIKit
import RxSwift

class FooiyCell: UITableViewCell {

    static let cellId = "normalCell"
    var disposeBag = DisposeBag()
    
    var bigLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var smallLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var bottomLine: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - 메소드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            contentView.backgroundColor = FooiyColors.P50
        } else {
            contentView.backgroundColor = .white
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    func initUI() {
        // Set UI
    }
    
}
