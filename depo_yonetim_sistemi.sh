#!/bin/bash

# CSV Dosyası Kontrolü ve Oluşturma
check_and_create_files() {
    files_to_create=()  # Eksik dosyaların listesi
    total_files=0  # Toplam dosya sayısı

    # Dosya kontrolü ve oluşturma işlemleri
    if [ ! -f "depo.csv" ]; then
        files_to_create+=("depo.csv")  # Dosya listesine ekle
        total_files=$((total_files + 1))  # Toplam dosya sayısını artır
    fi

    if [ ! -f "kullanici.csv" ]; then
        files_to_create+=("kullanici.csv")
        total_files=$((total_files + 1))
    fi

    if [ ! -f "log.csv" ]; then
        files_to_create+=("log.csv")
        total_files=$((total_files + 1))
    fi

    # Eğer hiç dosya eksik değilse, işlemi sonlandır ve hiçbir mesaj göstermemek için geri dön
    if [ $total_files -eq 0 ]; then
        return
    fi

    # Dosya oluşturuluyor mesajı ile ilerleme çubuğu başlatılır
    progress=$(zenity --progress --title="Dosya Oluşturuluyor" \
        --text="Dosyalar oluşturuluyor..." --percentage=0 --auto-close --width=400 --height=200)

    current_file=0  # Şu anki dosya indexi

    # İlerleme çubuğu başlatıldı, her dosya için güncelleme yapılacak
    for file in "${files_to_create[@]}"; do
        # İlerleme çubuğunda gösterilecek metni oluştur
        current_file=$((current_file + 1))
        percentage=$((current_file * 100 / total_files))

        # İlerleme çubuğunu güncelle
        zenity --progress --title="Dosya Oluşturuluyor" --text="Dosya $current_file/$total_files yüklendi..." \
            --percentage=$percentage --width=400 --height=200

        # Dosyayı oluştur
        touch "$file"
        if [ "$file" == "depo.csv" ]; then
            echo "ID,Ürün Adı,Stok,Fiyat" > depo.csv  # depo.csv için başlangıç satırı
        fi

        touch "$file"
        if [ "$file" == "kullanici.csv" ]; then
            echo "Kullanıcı Adı,Şifre" > kullanici.csv  # kullanici.csv için başlangıç satırı
        fi

        # 2 saniye bekleme ekleyelim
        sleep 2

    done

    # Mesajı, eksik dosya sayısına göre özelleştirelim
    if [ $total_files -eq 1 ]; then
        zenity --info --text="Eksik dosya başarıyla oluşturuldu: ${files_to_create[*]}" --width=400 --height=200
    elif [ $total_files -eq 2 ]; then
        zenity --info --text="Eksik dosyalar başarıyla oluşturuldu: ${files_to_create[*]}" --width=400 --height=200
    elif [ $total_files -eq 3 ]; then
        zenity --info --text="Tüm dosyalar başarıyla oluşturuldu." --width=400 --height=200
    fi

    login  # Login penceresini başlat
}


# Yönetici şifresi
admin_password="admin123"
locked_accounts="locked_accounts.txt"  # Kilitli hesaplar

# Dosya kontrolünü başlatıyoruz.
check_and_create_files


# Kullanıcı girişi
login() {
    attempts=0
    while [ $attempts -lt 3 ]; do
        # Kullanıcıdan kullanıcı adı ve parola isteği
        username=$(zenity --entry --title="Kullanıcı Girişi" --text="Lütfen Kullanıcı Adınızı Girin:" --width=300)
        password=$(zenity --entry --title="Kullanıcı Girişi" --text="Lütfen Parolanızı Girin:" --hide-text --width=300)

        # Zenity'den dönen durumu kontrol et
        if [ $? -ne 0 ]; then
            confirm_exit
        fi
        
        # Hesap kilitlenmesi kontrolü
        if grep -q "$username" "$locked_accounts"; then
            zenity --error --title="Kilitli Hesap" --text="Hesabınız kilitlenmiştir.\nLütfen Yönetici ile İletişime Geçin." --width=300
            exit 1
        fi
        
        # Yönetici giriş kontrolü
        if [ "$username" == "admin" ] && [ "$password" == "$admin_password" ]; then
            user_role="admin"
            current_user="admin"
            current_user_role="Yönetici"
            zenity --info --title="Giriş Başarılı" --text="Yönetici olarak giriş yaptınız. Hoş geldiniz!" --width=300
            break
        # Kullanıcı girişi kontrolü
        elif grep -q "$username,$password" "kullanici.csv"; then
            user_role="user"
            current_user="$username"
            current_user_role=$(grep "^$username," kullanici.csv | cut -d',' -f3)
            zenity --info --title="Giriş Başarılı" --text="Kullanıcı olarak giriş yaptınız. Hoş geldiniz!" --width=300
            break
        else
            ((attempts++))
            if [ $attempts -ge 3 ]; then
                # Hatalı giriş loglama
                echo "$(date +'%Y-%m-%d %H:%M:%S') - Hatalı giriş: $username" >> log.csv
                # Hesap kilitleme
                echo "$username" >> "$locked_accounts"
                zenity --error --title="Hesap Kilitlendi" --text="3 başarısız giriş denemesi. Hesabınız kilitlenmiştir.\nYönetici ile iletişime geçin." --width=300
                exit 1
            else
                # Başarısız giriş uyarısı
                zenity --error --title="Giriş Başarısız" --text="Giriş bilgilerinizi kontrol edin ve tekrar deneyin.\nKalan deneme: $((3-attempts))" --width=300
            fi
        fi
    done
}


# Ürün Listeleme
list_products() {
    while true; do
        if [[ -f "depo.csv" ]]; then
            # CSV dosyasını kontrol et
            if [ $(wc -l < depo.csv) -le 1 ]; then
                zenity --info --title="Ürünler" --text="Şu an hiçbir ürün bulunmamaktadır." --width=400 --height=200
                main_menu
                return
            fi

            # Ürünleri Zenity formatına sok
            products=$(awk -F, 'NR>1 {print $1 ", " $2 ", " $3 ", " $4}' depo.csv)

            # Kullanıcıya ürünleri listelet
            selected_option=$(echo "$products" | zenity --list --title="Ürünler" --width=800 --height=500 \
                --text="Ürün Listesi" --column="ID, Ürün Adı, Stok, Fiyat" --separator="|")

            # Kullanıcı çıkış yaptıysa
            if [[ $? -ne 0 ]]; then
                main_menu
                return
            fi

            if [[ -z "$selected_option" ]]; then
                zenity --info --title="Bilgi" --text="Hiçbir ürün seçilmedi." --width=400 --height=200
            else
                id=$(echo "$selected_option" | awk -F', ' '{print $1}')
                name=$(echo "$selected_option" | awk -F', ' '{print $2}')
                stock=$(echo "$selected_option" | awk -F', ' '{print $3}')
                price=$(echo "$selected_option" | awk -F', ' '{print $4}')
                zenity --info --title="Ürün Detayları" \
                    --text="ID: $id\nÜrün Adı: $name\nStok: $stock\nFiyat: $price" --width=400 --height=200
            fi
        else
            zenity --error --text="Depo dosyası bulunamadı! Lütfen bir yöneticiye başvurun." --width=400 --height=200
            return
        fi
    done
}


# Ürün Ekleme
add_product() {
    # Kullanıcı kimliği kontrolü
    if [[ -z "$current_user" ]]; then
        hata_mesaji="Ürün ekleme işlemi için kullanıcı oturumu gerekli!"
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        return
    fi

    # Kullanıcı rolünü kontrol et
    if [[ "$current_user_role" == "Kullanıcı" ]]; then
        hata_mesaji="Sadece yönetici rolündeki kullanıcılar ürün ekleyebilir!"
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Kullanıcı Rolü: $current_user_role" >> log.csv
        return
    fi

    # Ürün adını al
    product_name=$(zenity --entry --title="Yeni Ürün Ekle" --text="Ürün adı giriniz:" --width=400)
    if [ -z "$product_name" ]; then
        hata_mesaji="Ürün adı boş olamaz."
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # Stok miktarını al
    product_stock=$(zenity --entry --title="Yeni Ürün Ekle" --text="Stok miktarı giriniz:" --width=400)
    if [ -z "$product_stock" ] || ! [[ "$product_stock" =~ ^[0-9]+$ ]]; then
        hata_mesaji="Stok miktarı pozitif bir sayı olmalıdır."
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        add_product
        return
    fi

    # Fiyatı al
    product_price=$(zenity --entry --title="Yeni Ürün Ekle" --text="Fiyat giriniz:" --width=400)
    if [ -z "$product_price" ] || ! [[ "$product_price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        hata_mesaji="Fiyat pozitif bir sayı olmalıdır."
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        add_product
        return
    fi

    # Ürün ID'si oluştur
    if [ -f depo.csv ]; then
        last_id=$(tail -n +2 depo.csv | awk -F, '{print $1}' | sort -n | tail -1)
        product_id=$((last_id + 1))
    else
        product_id=1
    fi

    # Aynı isimde ürün kontrolü
    if grep -q ",$product_name," depo.csv; then
        hata_mesaji="Bu isimde bir ürün zaten mevcut."
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Ürün Adı: $product_name" >> log.csv
        main_menu  # Hata mesajı sonrası ana menüye dön
        return
    fi

    # Ürünü depo.csv dosyasına ekle
    echo "$product_id,$product_name,$product_stock,$product_price" >> depo.csv
    if [ $? -eq 0 ]; then
        zenity --info --text="Ürün başarıyla eklendi: $product_name" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),Ürün eklendi: $product_name, ID: $product_id" >> log.csv
        list_products  # Listeyi yenile
    else
        hata_mesaji="Ürün eklenirken bir hata oluştu."
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
    fi
}


# Ürün Güncelleme Fonksiyonu
update_product() {
    # Kullanıcı kimliği kontrolü
    if [[ -z "$current_user" ]]; then
        hata_mesaji="Güncelleme işlemi için yönetici oturumu gerekli!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # Kullanıcı rolünü kontrol et
    if [[ "$current_user_role" == "Kullanıcı" ]]; then
        hata_mesaji="Sadece yönetici rolündeki kullanıcılar ürün güncelleyebilir!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Kullanıcı Rolü: $current_user_role" >> log.csv
        main_menu
        return
    fi

    # Güncellenmek istenen ürünün adını al
    name=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürünün adını girin:" --ok-label="Devam" --cancel-label="İptal")

    if [[ -z "$name" ]]; then
        hata_mesaji="İşlem iptal edildi."
        zenity --info --text="$hata_mesaji" --width=400 --height=200
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # CSV dosyasını kontrol et
    csv_dosya="depo.csv"
    if [[ ! -f "$csv_dosya" ]]; then
        hata_mesaji="Ürün dosyası ($csv_dosya) bulunamadı!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        return
    fi

    # Ürün bilgilerini arayın
    satir=$(grep -i ",$name," "$csv_dosya")

    if [[ -z "$satir" ]]; then
        hata_mesaji="Ürün bulunamadı: $name"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # Mevcut ürün bilgilerini göster
    zenity --info --title="Mevcut Ürün Bilgisi" --text="Mevcut bilgiler:\n$satir"

    # Satır ID'sini al (dosya formatından bağımsız olarak ilk alan ID'dir)
    satir_id=$(echo "$satir" | cut -d ',' -f 1)

    # Yeni stok miktarını al
    new_stock=$(zenity --entry --title="Ürün Güncelle" --text="Yeni stok miktarını girin:" --ok-label="Güncelle" --cancel-label="İptal")

    if [[ -z "$new_stock" ]]; then
        hata_mesaji="İşlem iptal edildi."
        zenity --info --text="$hata_mesaji" --width=400 --height=200
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # Yeni birim fiyatını al
    new_price=$(zenity --entry --title="Ürün Güncelle" --text="Yeni birim fiyatını girin:" --ok-label="Güncelle" --cancel-label="İptal")

    if [[ -z "$new_price" ]]; then
        hata_mesaji="İşlem iptal edildi."
        zenity --info --text="$hata_mesaji" --width=400 --height=200
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        update_product
        return
    fi

    # Sayısal kontrol
    if ! [[ "$new_stock" =~ ^[0-9]+$ ]] || ! [[ "$new_price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        hata_mesaji="Stok ve fiyat sadece sayısal değer olmalıdır. Lütfen tekrar deneyin."
        zenity --error --text="$hata_mesaji" --width=400 --height=200
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        update_product
        return
    fi

    # Satırı güncelle
    yeni_satir="$satir_id,$name,$new_stock,$new_price,$current_user"

    sed -i "s|^$satir$|$yeni_satir|" "$csv_dosya"

    if [[ $? -eq 0 ]]; then
        zenity --info --text="Ürün başarıyla güncellendi: $name\nYeni bilgiler:\n$name,$new_stock,$new_price" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),Ürün başarıyla güncellendi: $name,$new_stock,$new_price" >> log.csv
        list_products
    else
        hata_mesaji="Ürün güncellenirken bir hata oluştu."
        zenity --error --text="$hata_mesaji" --width=400
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
    fi
}



# Ürün silme
delete_product() {
    # Kullanıcı kimliği kontrolü
    if [[ -z "$current_user" ]]; then
        hata_mesaji="Ürün silme işlemi için yönetici oturumu gerekli!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # Kullanıcı rolünü kontrol et
    if [[ "$current_user_role" == "Kullanıcı" ]]; then
        hata_mesaji="Sadece yönetici rolündeki kullanıcılar ürün silebilir!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Kullanıcı: $current_user" >> log.csv
        main_menu
        return
    fi

    # Ürün adı al
    product_name=$(zenity --entry --title="Ürün Silme" --text="Silmek istediğiniz ürün adını giriniz:" --width=400)
    
    if [[ -z "$product_name" ]]; then
        hata_mesaji="Ürün adı boş bırakılamaz!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # CSV dosyasını kontrol et
    csv_dosya="depo.csv"
    if [[ ! -f "$csv_dosya" ]]; then
        hata_mesaji="Ürün dosyası ($csv_dosya) bulunamadı!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        return
    fi

    # Ürün bilgilerini kontrol et
    satir=$(grep -i ",$product_name," "$csv_dosya")
    if [[ -z "$satir" ]]; then
        hata_mesaji="Ürün bulunamadı: $product_name"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
        main_menu
        return
    fi

    # Mevcut ürün bilgilerini göster
    zenity --info --title="Silinecek Ürün Bilgisi" --text="Bulunan ürün:\n$satir"

    # Silme onayı
    zenity --question --text="Bu ürünü silmek istediğinizden emin misiniz?" --width=400
    if [ $? -eq 0 ]; then
        # Ürünü sil
        sed -i "/,$product_name,/d" "$csv_dosya"
        if [ $? -eq 0 ]; then
            zenity --info --text="Ürün başarıyla silindi: $product_name" --width=400
            echo "$(date +'%Y-%m-%d %H:%M:%S'),Ürün başarıyla silindi: $product_name" >> log.csv
            main_menu
        else
            hata_mesaji="Ürün silme sırasında bir hata oluştu!"
            zenity --error --text="$hata_mesaji" --width=400
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji" >> log.csv
            main_menu
        fi
    else
        zenity --info --text="Silme işlemi iptal edildi." --width=400
        main_menu
    fi
}


# Ana Menü
main_menu() {
    # Admin kontrolü ve seçenekler
    if [ "$user_role" == "admin" ]; then
        action=$(zenity --list --title="Ana Menü" --column="Seçim" \
            "Ürün Ekle" "Ürün Listele" "Ürün Güncelle" "Ürün Sil" \
            "Rapor Al" "Kullanıcı Yönetimi" "Şifre Yönetimi" "Program Yönetimi" "Çıkış" \
            --ok-label="Seç" --cancel-label="Geri" --width=400 --height=300)
    else
        action=$(zenity --list --title="Ana Menü" --column="Seçim" \
            "Ürün Listele" "Rapor Al" "Çıkış" \
            --ok-label="Seç" --cancel-label="Geri" --width=400 --height=300)
    fi

    # Kullanıcı seçim yapmazsa geri dön
    if [ $? -ne 0 ]; then
        confirm_exit
        return
    fi

    case $action in
        "Ürün Ekle") 
            add_product
            ;;
        "Ürün Listele") 
            list_products
            ;;
        "Ürün Güncelle") 
            update_product
            ;;
        "Ürün Sil") 
            delete_product
            ;;
        "Rapor Al") 
            generate_report
            ;;
        "Kullanıcı Yönetimi") 
            user_management
            ;;
        "Şifre Yönetimi") 
            password_management
            ;;
        "Program Yönetimi")
            program_management
            ;;
        "Çıkış") 
            confirm_exit
            ;;
        *) 
            zenity --error --text="Geçersiz seçim. Lütfen bir seçenek belirleyin."
            main_menu
            ;;
    esac
}


# Çıkış Onayı
confirm_exit() {
    response=$(zenity --question --title="Çıkış Onayı" --text="Uygulamadan çıkmak istediğinize emin misiniz?" \
        --ok-label="Evet" --cancel-label="Hayır" --width=400 --height=200)
    
    if [ $? -eq 0 ]; then
        zenity --info --text="Uygulamadan çıkılıyor. Görüşmek üzere!" --width=400 --height=200
        exit 0  # Kullanıcı 'Evet' seçerse çık
    else
        zenity --info --text="Ana menüye geri dönülüyor." --width=400 --height=200
        main_menu  # Kullanıcı 'Hayır' seçerse ana menüye dön
    fi
}


# Şifre Yönetimi
password_management() {
    # Yönetici şifresini kontrol et (Yönetici şifresi admin_password değişkeniyle tutuluyor)
    if [[ "$current_user_role" != "Yönetici" ]]; then
        zenity --error --text="Yönetici şifre değiştirme yetkiniz yok." --width=400 --height=200
        main_menu
        return
    fi

    # Yeni şifreyi kullanıcıdan al
    new_password=$(zenity --entry --title="Yeni Şifre" --text="Yeni şifreyi girin:" --hide-text --ok-label="Değiştir" --cancel-label="İptal" --width=400 --height=200)

    # Şifre geçerliliğini kontrol et
    if [[ -z "$new_password" || "$new_password" =~ \  ]]; then
        zenity --error --text="Şifre geçerli değil. Şifre boş olamaz ve boşluk içeremez. Lütfen tekrar deneyin." --width=400 --height=200
        main_menu
        return
    fi

    # admin_password değişkenini güncelle ve yeni şifreyi dosyaya kaydet
    admin_password="$new_password"
    echo "admin_password=\"$new_password\"" > admin_password.txt

    # Başarı mesajı
    zenity --info --text="Şifreniz başarıyla değiştirildi." --width=400 --height=200

    # Ana menüyü göster
    main_menu
}


# Yönetici şifresi başlangıçta dosyadan okunur
if [[ -f admin_password.txt ]]; then
    source admin_password.txt
else
    admin_password="admin123"
    echo "admin_password=\"$admin_password\"" > admin_password.txt
fi


# Rapor Al
generate_report() {
    if [[ -f "depo.csv" ]]; then
        # Hem yönetici hem de kullanıcı tüm ürünleri görebilir
        report=$(awk -F, 'NR>1 {print $1 "\t" $2 "\t" $3 "\t" $4}' depo.csv)

        if [ -z "$report" ]; then
            zenity --info --text="Raporlanacak ürün bulunmamaktadır." --width=400 --height=200
        else
            # Ürün raporunu kullanıcıya göster
            echo -e "ID\tÜrün Adı\tStok\tFiyat\n$report" | zenity --text-info --title="Ürün Raporu" \
                --width=600 --height=400 --ok-label="Tamam" --cancel-label="Geri"
        fi
    else
        zenity --error --text="Depo dosyası bulunamadı!" --width=400 --height=200
    fi
    main_menu
}


# Kullanıcı Yönetimi
user_management() {
    if [[ "$current_user_role" != "Yönetici" ]]; then
        zenity --error --text="Bu işlem için yönetici yetkisi gerekli." --width=400 --height=300
        return
    fi

    action=$(zenity --list --title="Kullanıcı Yönetimi" --column="Seçim" "Kullanıcı Ekle" "Kullanıcı Sil" "Hesap Kilidi Aç" "Geri" --width=400 --height=300)

    case $action in
        "Kullanıcı Ekle")
            add_user
            ;;
        "Kullanıcı Sil")
            delete_user
            ;;
        "Hesap Kilidi Aç")
            unlock_account
            ;;
        "Geri")
            main_menu
            ;;
        *)
            zenity --error --text="Geçersiz seçim."
            ;;
    esac
}


# Hesap Kilidi Açma
unlock_account() {
    username=$(zenity --entry --title="Hesap Kilidi Aç" --text="Kilitli kullanıcı adını girin:" --width=300)
    if [ -z "$username" ]; then return; fi

    if grep -q "^$username$" "$locked_accounts"; then
        sed -i "/^$username$/d" "$locked_accounts"
        zenity --info --text="Kullanıcı $username'in kilidi başarıyla açıldı." --width=300
    else
        zenity --error --text="Kullanıcı kilitli değil veya bulunamadı." --width=300
        main_menu
    fi
}


# Kullanıcı Ekle
add_user() {
    username=$(zenity --entry --title="Kullanıcı Ekle" --text="Kullanıcı adı:")
    if [ -z "$username" ]; then 
    user_management    
    return; fi
    password=$(zenity --entry --title="Kullanıcı Ekle" --text="Şifre:" --hide-text)
    if [ -z "$password" ]; then
    user_management
    return; fi

    if grep -q "^$username," kullanici.csv; then
        zenity --error --text="Bu kullanıcı adı zaten mevcut."
    else
        echo "$username,$password,$role" >> kullanici.csv
        zenity --info --text="Kullanıcı $username başarıyla eklendi."
        user_management
        return
    fi
}


# Kullanıcı Sil
delete_user() {
    username=$(zenity --entry --title="Kullanıcı Sil" --text="Kullanıcı adı:")
    if [ -z "$username" ]; then 
    user_management    
    return; fi
    if grep -q "^$username," kullanici.csv; then
        if zenity --question --text="Kullanıcı $username'yi silmek istediğinizden emin misiniz?"; then
            sed -i "/^$username,/d" kullanici.csv
            zenity --info --text="Kullanıcı $username silindi."
        fi
    else
        zenity --error --text="Kullanıcı bulunamadı."
        user_management
    fi
}


# Program Yönetimi
function program_management() {
    # Kullanıcı rolü kontrolü
    if [[ "$current_user_role" != "Yönetici" ]]; then
        hata_mesaji="Sadece yönetici rolündeki kullanıcılar program yönetimi işlemlerini yapabilir!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Kullanıcı: $current_user" >> log.csv
        return
    fi

    while true; do
        action=$(zenity --list --title="Program Yönetimi" --column="Seçim" \
        "Dosyaları Yedekle" "Programı Kapat" "Geri Dön")

        case $action in
            "Dosyaları Yedekle")
                backup_file
                ;;
            "Programı Kapat")
                exit 0
                ;;
            "Geri Dön")
                main_menu
                return
                ;;
            *)
                hata_mesaji="Geçersiz seçenek!"
                zenity --error --text="$hata_mesaji"
                echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Kullanıcı: $current_user" >> log.csv
                ;;
        esac
    done
}


# Dosya Yedekleme
function backup_file() {
    # Yedekleme dizinini seçme
    backup_dir=$(zenity --file-selection --directory --title="Yedekleme Dizini Seç")

    if [[ -z "$backup_dir" ]]; then
        hata_mesaji="Yedekleme dizini seçilmedi!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Kullanıcı: $current_user" >> log.csv
        return
    fi

    # Yedekleme işlemi
    if [[ -n "$current_user" ]]; then
        # Verileri yedekle
        grep ",$current_user$" depo.csv > "$backup_dir/depo_$current_user.csv.bak"
        grep "^$current_user," kullanici.csv > "$backup_dir/kullanici_$current_user.csv.bak"
        grep "$current_user" log.csv > "$backup_dir/log_$current_user.csv.bak"

        # Her dosya için kontrol ve bilgi mesajları
        if [[ -s "$backup_dir/depo_$current_user.csv.bak" ]]; then
            depo_mesaji="Depo dosyası başarıyla yedeklendi: depo_$current_user.csv.bak"
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$depo_mesaji, Kullanıcı: $current_user" >> log.csv
        else
            depo_mesaji="Depo dosyası boş olduğu için yedeklenmedi!"
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$depo_mesaji, Kullanıcı: $current_user" >> log.csv
        fi

        if [[ -s "$backup_dir/kullanici_$current_user.csv.bak" ]]; then
            kullanici_mesaji="Kullanıcı dosyası başarıyla yedeklendi: kullanici_$current_user.csv.bak"
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$kullanici_mesaji, Kullanıcı: $current_user" >> log.csv
        else
            kullanici_mesaji="Kullanıcı dosyası boş olduğu için yedeklenmedi!"
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$kullanici_mesaji, Kullanıcı: $current_user" >> log.csv
        fi

        if [[ -s "$backup_dir/log_$current_user.csv.bak" ]]; then
            log_mesaji="Log dosyası başarıyla yedeklendi: log_$current_user.csv.bak"
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$log_mesaji, Kullanıcı: $current_user" >> log.csv
        else
            log_mesaji="Log dosyası boş olduğu için yedeklenmedi!"
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$log_mesaji, Kullanıcı: $current_user" >> log.csv
        fi

        # Kullanıcıya genel bir bilgi mesajı göster
        zenity --info --text="Yedekleme işlemi tamamlandı! Yedekleme dizini: $backup_dir
        $depo_mesaji
        $kullanici_mesaji
        $log_mesaji"
    else
        hata_mesaji="current_user değişkeni boş. Yedekleme yapılamadı!"
        zenity --error --text="$hata_mesaji"
        echo "$(date +'%Y-%m-%d %H:%M:%S'),$hata_mesaji, Kullanıcı: $current_user" >> log.csv
    fi
}


# Başlangıç
login  # Giriş işlemi başlatılır
main_menu  # Giriş başarılı ise ana menüye geçiş yapılır
