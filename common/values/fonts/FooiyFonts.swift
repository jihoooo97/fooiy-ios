import UIKit

enum FooiyFonts {

    static let Heading1 = UIFont(name: "Pretendard-Bold", size: 48)
    static let Heading2 = UIFont(name: "Pretendard-Medium", size: 36)
    static let Heading3 = UIFont(name: "Pretendard-Medium", size: 22)
    static let Heading3b = UIFont(name: "Pretendard-Medium", size: 24)
    
    static let SubTitle1 = UIFont(name: "Pretendard-SemiBold", size: 18)
    static let SubTitle2 = UIFont(name: "Pretendard-SemiBold", size: 16)
    static let SubTitle3 = UIFont(name: "Pretendard-SemiBold", size: 14)
    static let SubTitle4 = UIFont(name: "Pretendard-Regular", size: 14)
    
    static let Caption1 = UIFont(name: "Pretendard-Regular", size: 12)
    static let Caption1b = UIFont(name: "Pretendard-SemiBold", size: 12)
    static let Caption2 = UIFont(name: "Pretendard-SemiBold", size: 10)
    static let Caption3 = UIFont(name: "Pretendard-SemiBold", size: 14)
    
    static let Body1 = UIFont(name: "Pretendard-Regular", size: 16)
    static let Body2 = UIFont(name: "Pretendard-Regular", size: 14)
    static let Body2b = UIFont(name: "Pretendard-SemiBold", size: 14)
    
    static let Button = UIFont(name: "Pretendard-SemiBold", size: 16)
    
    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "Pretendard-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func semiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Pretendard-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func medium(size: CGFloat) -> UIFont {
        return UIFont(name: "Pretendard-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func regular(size: CGFloat) -> UIFont {
        return UIFont(name: "Pretendard-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
}
