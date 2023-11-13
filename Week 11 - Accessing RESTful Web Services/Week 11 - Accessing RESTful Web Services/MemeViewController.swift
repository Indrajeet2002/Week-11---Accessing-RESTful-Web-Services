//
//  ViewController.swift
//  Week 11 - Accessing RESTful Web Services
//
//  Created by Indrajeet Patwardhan on 10/31/23.
//

import UIKit

class MemeViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    
    var imgFlip: ImgFlip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.imgFlip = ImgFlip()
        
        self.imgFlip.getMemes{
            (getMemesResult) in

            switch getMemesResult{
            case let .success(templates):
                print("Successfully found \(templates.count) meme templates")
                if let firstTemplate = templates.first{

//                    print("First template is \(firstTemplate.templateID) at \(firstTemplate.url ?? "?")")
                    self.updateImageView(for: firstTemplate)
                }
                else{
                    print("First template didn't exist :(")
                }
            case let .failure(error):
                print("Error fetching meme templates: \(error)")
            }
        }
    }

    func updateImageView(for memeTemplate: ImgFlipMemeTemplate){
        self.imgFlip.downloadMemeTemplateImage(for: memeTemplate){
            (imageResult) in
            switch imageResult{
            case let.success(image):
                print("Successfully downloaded image for template: \(memeTemplate)")
                self.imageView.image = image
            case let.failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }
}
