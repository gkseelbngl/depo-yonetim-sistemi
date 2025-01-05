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

   ![image](https://github.com/user-attachments/assets/c34e420b-9794-4b16-a330-be023f5133b0)   ![image](https://github.com/user-attachments/assets/e1584312-f594-4168-8df5-9d0863a02920)   ![image](https://github.com/user-attachments/assets/d3b74ed1-2897-437d-a4f1-edc9fa84aac9)





   **Ana Menü**

   ![image](https://github.com/user-attachments/assets/95403533-a6c0-4b42-9cb2-07549ef067a3)


   **Ürün Ekleme**

   ![image](https://github.com/user-attachments/assets/1aa25fdb-d295-42fb-9664-66f3f007a2cc)   ![image](https://github.com/user-attachments/assets/445decec-120c-427f-92d1-f69d90129ee0)   ![image](https://github.com/user-attachments/assets/836e4ebc-177c-453f-a453-e9bb807ebb2c)   ![image](https://github.com/user-attachments/assets/4bd75794-d70f-4548-8750-2629dade082e)




   **Ürün Listeleme**

   **Rapor Görüntüleme**


**Kullanım Videosu**

[YouTube Videosunu İzle](https://youtu.be/fndhLUfV8pM)

**Notlar**

   * **Güvenlik:** Şifreler ve hassas bilgiler dosya içinde saklanır, bu yüzden güvenlik açısından dikkatli olunmalıdır. Gerçek kullanımda daha güvenli bir yöntem kullanılmalıdır.
   * **Yedekleme:** Program Yönetimi seçeneği ile dosyalarınızı yedekleyebilirsiniz, bu önemli bir veri kaybı önleme yöntemidir.


**Katkıda Bulunma**

Hataları bulup bildirmek veya yeni özellikler eklemek için çekinmeyin. Pull requestlerinizi bekliyoruz!
