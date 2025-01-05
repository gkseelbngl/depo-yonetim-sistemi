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

       bash ana_script.sh
