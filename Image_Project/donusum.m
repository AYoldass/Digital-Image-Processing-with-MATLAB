% 1. Normal resmi yükle
grayImage = imread('C:\Users\ahmet\Desktop\image proje\5.jpg'); % veya resminizin adını ve uzantısını kullanın

% 2. Üç kanallı bir matris oluştur
[rows, cols] = size(grayImage);
rgbImage = zeros(rows, cols, 3, 'uint8'); % 'uint8' tipinde bir matris kullanılır

% 3. Grayscale resmi üç kanallı resmin kırmızı kanalına kopyala
rgbImage(:, :, 1) = grayImage;

% 4. Yeşil ve mavi kanalları, kırmızı kanalın kopyasını kullanarak doldur
rgbImage(:, :, 2) = grayImage;
rgbImage(:, :, 3) = grayImage;

% Not: Eğer farklı renk dönüşümü yapmak istiyorsanız, her bir kanalı ayrı ayrı manipüle edebilirsiniz.

% 5. Sonucu görselleştir
imshow(rgbImage);

% 6. İsterseniz üç kanallı resmi bir dosyaya kaydedebilirsiniz
imwrite(rgbImage, 'deneme1.jpg'); % veya dosya adını ve uzantısını kullanın
