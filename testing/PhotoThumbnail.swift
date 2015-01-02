import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    @IBOutlet var imgView : UIImageView!
    
    @IBOutlet weak var photoName: UILabel!
    
    
    func setThumbnailImage(thumbnailImage: UIImage){
        self.imgView.image = thumbnailImage
    }
    
}
