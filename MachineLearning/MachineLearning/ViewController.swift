//
//  ViewController.swift
//  MachineLearning
//
//  Created by Esat Gözcü on 29.11.2017.
//  Copyright © 2017 Esat Gözcü. All rights reserved.
//

import UIKit
//Machine Learning için Gerekli Kütüphaneleri import ediyoruz
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var sonucLabel: UILabel!
    @IBOutlet weak var resimView: UIImageView!
    var chosenImage = CIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func resimButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        //Kamerayıda seçebiliriz  picker.sourceType = .camera
        //Resim galerisine gidiyoruz
        picker.sourceType = .photoLibrary
        //Fotoğrafı düzenlemeyi aktif hale getiriyoruz
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //Resimi seçtikten sonra..
        resimView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //Kullanıcının seçtiği resimi CIImage imajına dönüştürüyoruz
        if let ciImage = CIImage(image : resimView.image!)
        {
            self.chosenImage = ciImage
        }
        görüntüisleme(image: chosenImage)
        
    }
    func görüntüisleme(image : CIImage){
        
        sonucLabel.text = "Hesaplanıyor...."
        //Modelimizi oluşturuyoruz
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model)
        {
            //Modelimizi sorgumuza aktarıyoruz
            let request = VNCoreMLRequest(model: model, completionHandler: { (vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation]
                {
                    //Eğer sorgumuzu alabilirsek sonucu topResult değişkenine aktarıyoruz
                    let topResult = results.first
                    
                    //Program kitlenmemesi için DispatchQueue kullanıyoruz ve işlemler background'da çalışıyor
                    DispatchQueue.main.async {
                        
                        //Yüzde kaç ihtimalle doğru olduğunu hesaplıyoruz
                        let conf = (topResult?.confidence)! * 100
                        //Sonucu yazdırıyoruz
                        self.sonucLabel.text = "\(conf)%  \(topResult!.identifier)"
                    }
                }
            })
            //request oluşturduktan sonra handler oluşturup sorgumuzu değerlendiriyoruz
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    //Sorgumuzu handler(çalıştırıyoruz) ediyoruz
                    try handler.perform([request])
                }
                catch{
                    print("error")
                }
            }
        }
    }
}

