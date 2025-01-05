# Envanter Yönetim Sistemi
Bu proje, Zenity kullanarak GNU/Linux sistemlerinde çalışabilen grafiksel bir envanter yönetim sistemi sunar. Kullanıcılar ürünleri ekleyebilir, listeleyebilir, güncelleyebilir ve silebilir. 

**Özellikler**

* **Ürün Ekleme:** Yeni ürünler ekleyebilme.
* **Ürün Listeleme:** Mevcut ürünleri görüntüleme.
* **Ürün Güncelleme:** Ürün bilgilerini güncelleme.
* **Ürün Silme:** Ürünleri sistemden silme.
* **Kullanıcı Yönetimi:** Yeni kullanıcı ekleyebilme, kullanıcıları silebilme ve kilitli hesapları açabilme.
* **Şifre Yönetimi:** Yönetici şifresini değiştirme.
* **Rapor Oluşturma:** Tüm ürünlerin listesini rapor olarak görüntüleme.
* **Program Yönetimi:** Dosya yedekleme ve programı kapatma seçenekleri.

**Kurulum**
   1. **Bağımlılıklar:** Sistemde *zenity* yüklü olmalıdır. Debian tabanlı sistemlerde:

          sudo apt-get install zenity 
   2. **Dosyaları İndirme:**
   
      o Bu repository'yi klonlayın:
   
          git clone [repo-url-here]
   3. **Kullanma:**

      o Script dosyasının bulunduğu dizinde terminal açın:

          cd [repository-dizini]
   
      o Script'i çalıştırın:

          bash depo_yonetim_sistemi.sh

**Kullanım**

   **Giriş Yapma**
   
   * **Kullanıcı Girişi:** Kullanıcı adı ve şifre ile giriş yapılır. Yönetici girişi için özel bir parola gereklidir.

   **Ana Menü Seçenekleri**

   * **Ürün Ekle:** Sadece yönetici rolüne sahip kullanıcılar yeni ürün ekleyebilir.
   * **Ürün Listele:** Hem yönetici hem de normal kullanıcılar tüm ürünleri listeleyebilir.
   * **Ürün Güncelle:** Yönetici rolündeki kullanıcılar ürün detaylarını güncelleyebilir.
   * **Ürün Sil:** Sadece yönetici rolündeki kullanıcılar ürünleri silebilir.
   * **Rapor Al:** Ürünlerin listesini bir rapor olarak alınabilir.
   * **Kullanıcı Yönetimi:** Yeni kullanıcılar ekleyebilir, mevcut kullanıcıları silebilir veya kilitli hesapları açabilir (yönetici).
   * **Şifre Yönetimi:** Yönetici şifresini değiştirme (yönetici).
   * **Program Yönetimi:** Dosyaları yedekleme ve programı kapatma (yönetici).

**Kullanıcı Arayüzü**

Uygulamamızdan bazı ekran görüntüleri aşağıda bulunmaktadır:

   **Giriş Ekranı**

   ![image](https://github.com/user-attachments/assets/f0d46842-4c91-4d5d-865b-d9685a2161e4)


   **Ana Menü**

   **Ürün Ekleme**

   **Ürün Listeleme**

   **Rapor Görüntüleme**


**Kullanım Videosu**

[YouTube Videosunu İzle](https://youtu.be/fndhLUfV8pM)

**Notlar**

   * **Güvenlik:** Şifreler ve hassas bilgiler dosya içinde saklanır, bu yüzden güvenlik açısından dikkatli olunmalıdır. Gerçek kullanımda daha güvenli bir yöntem kullanılmalıdır.
   * **Yedekleme:** Program Yönetimi seçeneği ile dosyalarınızı yedekleyebilirsiniz, bu önemli bir veri kaybı önleme yöntemidir.


**Katkıda Bulunma**

Hataları bulup bildirmek veya yeni özellikler eklemek için çekinmeyin. Pull requestlerinizi bekliyoruz!
