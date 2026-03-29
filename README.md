# SISOP-1-2026-IT-022
#### Muhammad Satrio Utomo | 50272521022
## Repository Structure

![Struktur Repository](assets/soal%201/repo-structure.png)

## Reporting
### Soal 1

**Penjelasan** :

Pada Soal 1 diminta untuk menganalisa data pada file <u>passenger.csv</u> untuk melakukan : 
1. Menghitung jumlah seluruh penumpang
2. Jumlah gerbang penumpang
3. Mencari penumpang tertua
4. Menghitung rata-rata usia penumpang
5. Jumlah penumpang business class

Penyelesaian :

Menggunakan ```wget``` untuk mendownload file <u>passenger.csv</u> dari soal

![wget passenger.csv](assets/soal%201/wget-data.png)

Di soal, command penggunaan script berupa ```awk -f KANJ.sh passenger.csv a/b/c/d/e```, maka abjad harus dimasukkan ke dalam variabel & dihilangkan pada command agar tidak terbaca sebagai file.
```awk
BEGIN {
	FS = ","

	opsi = ARGV[2]
	delete ARGV[2]

	if(opsi != "a" && opsi != "b" && opsi != "c" && opsi != "d" && opsi != "e") {
		print("Soal tidak dikenali. Gunakan a, b, c, d, atau e.")
		print("Contoh penggunaan: awk -f file.sh data.csv a")

		exit 1
	}

	count_passenger = 0
	oldest = 0
	total_age = 0
	total_business = 0
}
```

Menentukan semua data yang diperlukan, menjumlah seluruh penumpang, menentukan gerbong, mencari penumpang tertua, menghitung rata-rata usia, & jumlah penumpang business class.
```awk
NR > 1 {
	name = $1
	age = $2
	class = $3
	carriage = $4

  #menghitung jumlah penumpang sekaligus total umur (untuk menghitung rata-rata nanti)
	if(name != "") {
		count_passenger++
		total_age += age
	}

  #mencatat nama gerbong yang unik
	if(carriage != ""){
		list_carriage[carriage] = 1
	}
  
  #cari penumpang tertua & namanya
	if(age > oldest){
		oldest = age
		oldest_name = name
	}

  #jumlah penumpang business class
	if(class ~ /Business/){
		total_business++
	}
}

```
Selanjutnya dilakukan if statement untuk output sesuai option input user.
```awk
END {
	if(opsi == "a") {
		print("Jumlah seluruh penumpang KANJ adalah", count_passenger, "orang.")
	}	else if (opsi == "b"){
		total_carriage = 0
		for(g in list_carriage){
			total_carriage++
		}
		print("Jumlah gerbong penumpang KANJ adalah", total_carriage)
	} else if (opsi == "c"){
		print(oldest_name, "adalah penumpang kereta tertua dengan usia", oldest, "tahun.")
	}	else if (opsi == "d"){
		average = total_age / count_passenger
		printf("Rata-rata usia penumpang adalah %.0f tahun\n", average)
	}	else if (opsi == "e"){
		print("Jumlah penumpang business class adalah", total_business, "orang")
	}
}
```
Ada kejanggalan pada output awal yakni jumlah gerbong penumpang yang ketika dicek pada file <u>passenger.csv</u> jumlah gerbong unik seharusnya hanya ada 4, sedangkan pada output malah jadi 5 :

![Gerbong Unik 5](assets/soal%201/wrong-output.png)

setelah dicek secara mendalam pada file <u>passenger.csv</u> dengan menggunakan ```cat -A passenger.csv``` ternyata terdapat karakter carriage return selain pada data baris terakhir.

![Carriage Return](assets/soal%201/carriage-return.png)

maka untuk menghapus carriage returnnya supaya Gerbong3 pada baris terakhir dihitung sama dengan Gerbong3 yang lain, dalam baris kode awknya ditambahkan ```sub(/\r$/, "")```. 
```awk
NR > 1 {
	sub(/\r$/, "")

	name = $1
	age = $2
	class = $3
	carriage = $4

	......
}
```

Output dari semua opsi :
* Opsi a (Jumlah seluruh penumpang):
  
  ![Output Opsi a](assets/soal%201/output-a.png)
* Opsi b (Jumlah gerbong penumpang) :
  
  ![Output Opsi b](assets/soal%201/output-b.png)
* Opsi c (Nama & umur penumpang tertua) :
  
  ![Output Opsi c](assets/soal%201/output-c.png)
* Opsi d (Rata-rata usia penumpang) :
  
  ![Output Opsi d](assets/soal%201/output-d.png)
* Opsi e (Penumpang business class) :
  
  ![Output Opsi e](assets/soal%201/output-e.png)
* Invalid Option
  
  ![Invalid Option](assets/soal%201/invalid-option.png)

**Kendala :**

Terdapat ketidakselarasan pada opsi b yaitu gerbong penumpang, yang seharusnya cuma ada 4 gerbong unik, sedangkan output yang dikeluarkan ternyata 5. Oleh karena itu harus diulik lebih dalam file ```passenger.csv```-nya dan ketemu bahwa terdapat carriage return disemua barisnya kecuali baris terakhir. akhirnya harus cari cara biar carriage returnnya hilang.

### Soal 2
**Penjelasan** : 

Pada soal 2, diminta untuk mencari <u>koordinat benda pusaka</u>. Diketahui sejumlah clue dari soal untuk memecahkan koordinat benda pusaka yang dicari.

Penyelesaian :

Step 1 :
Download file <u>peta-ekspedisi-amba.pdf</u> dengan menggunakan tools ```gdown```.

![gdown peta-ekspedisi-amba.pdf](assets/soal%202/gdown-file.png)

Selanjutnya, dari file <u>peta-ekspedisi-amba.pdf</u> dibedah isinya dengan menggunakan ```cat peta-ekspedisi-amba.pdf``` dan ditemukan clue selanjutnya berupa link github.

![Clue berupa link github](assets/soal%202/github-link-found.png)

Dilanjut dengan melakukan ```git clone https://github.com/pocongcyber77/peta-gunung-kawi.git``` dan didapat file json (```gsxtrack.json```)

![Git Clone](assets/soal%202/clone-repo.png)v

Step 2 : Membuat shell script dengan nama file ```parserkoordinat.sh``` yang menggunakan regex untuk mengambil data site_name, latitude (x), longitude(y) dari file ```gsxtrack.json``` dengan format ```id```, ```site_name```, ```latitude```, ```longitude```. Hasil diurutkan dan disimpan ke dalam file '```titik-penting.txt```'.

Dengan menggunakan ```grep``` untuk mengambil kata kunci dan isinya, lalu dilanjut ```sed``` untuk merapikan output dengan menghilangkan tanda petik dua ( " ).
```bash
#!/bin/bash

grep -E '"id":|"site_name":|"latitude":|"longitude":' gsxtrack.json | \
sed -E 's/.*"id": "([^"]+)".*/\1/' | \
sed -E 's/.*"site_name": "([^"]+)".*/\1/' | \
sed -E 's/.*"latitude": ([-.0-9]+).*/\1/' | \
sed -E 's/.*"longitude": ([-.0-9]+).*/\1/' | \
awk '{
    if (NR%4 == 1) id=$0
    else if (NR%4 == 2) site=$0
    else if (NR%4 == 3) lat=$0
    else if (NR%4 == 0) print id "," site "," lat "," $0
}' | sort > titik-penting.txt 
```

Output ```titik-penting.txt``` :

![Output titik-penting.txt](assets/soal%202/output-titik-penting.png)

Untuk menemukan titik tengah dari keempat koordinat tersebut, dilakukan pencarian titik tengah dengan metode titik simetri diagonal, yaitu menghitung titik tengah dari dua koordinat saling berseberangan. Rumus tersebut diimplementasikan dalam shellscript pada file ```nemupusaka.sh``` dan mencetak outputnya ke dalam ```posisipusaka.txt```.

```bash
#!/bin/bash

awk -F',' '
	NR == 1 { y1=$3; x1=$4 }
	NR == 3 { y2=$3; x2=$4 }

	END{
		x_mid = (x1 + x2) / 2
		y_mid = (y1 + y2) / 2

		print "Koordinat pusat:"
		print y_mid, ",", x_mid
	}
' titik-penting.txt | tee posisipusaka.txt
```

dan menghasilkan titik pusat sebagai berikut

![koordinat titik pusat](assets/soal%202/output-titik-pusat.png)

**Kendala :**

Terdapat kendala saat set up kebutuhan pada soal ini, karena secara default memang belum terinstall toolsnya seperti tools ```gdown```, akhirnya harus nyari tutorial untuk install ```gdown```.

### Soal 3
**Penjelasan** : 

Pada soal nomor 3, Mas Amba ingin membuat program untuk mengelola "Kost Slebew", yang dimana didalam program tersebut ada opsi untuk menambah data penghuni, menghapus data penghuni, menampilkan daftar penghuni, mengupdate status data penghuni, mencetak laporan keuangan, dan juga program untuk mengingatkan untuk penghuni membayar tagihan.

User Interface dibuat looping kecuali saat memilih opsi 7 ( exit ), maka dibuat User Interface seperti berikut :

```bash
while [ "$option" != "7" ]
do
    clear

    echo "    __ __           __     _____ __     __"
    echo "   / //_/___  _____/ /_   / ___// /__  / /_  ___ _      __"
    echo "  / ,< / __ \/ ___/ __/   \__ \/ / _ \/ __ \/ _ \ | /| / /"
    echo " / /| / /_/ (__  ) /_    ___/ / /  __/ /_/ /  __/ |/ |/ /"
    echo "/_/ |_\____/____/\__/   /____/_/\___/_.___/\___/|__/|__/"

    echo "=========================================================="
    echo "             SISTEM MANAJEMEN KOST SLEBEW                 "
    echo "=========================================================="
    echo "ID | OPTION"
    echo "----------------------------------------------------------"
    echo " 1 | Tambah Penghuni Baru"
    echo " 2 | Hapus Penghuni"
    echo " 3 | Tampilkan Daftar Penghuni"
    echo " 4 | Update Status Penghuni"
    echo " 5 | Cetak Laporan Keuangan"
    echo " 6 | Kelola Cron (Pengingat Tagihan)"
    echo " 7 | Exit Program"
    echo "=========================================================="
    echo -n "Enter Option [1-7]: "
    read -r option
done
```
Contoh output dari tampilan awal :

![Tampilan Awal Kost Slebew](assets/soal%203/image-1.png)

---
untuk **OPSI NOMOR 1** ( Tambah Penghuni Baru ), didalamnya user bakal menginput nama penghuni, nomer kamar, harga sewa kostnya, tanggal masuk dengan format (YYYY-MM-DD), status awal ( aktif jika lunas / menunggak jika nyicil ). Dibuat header & user interface seperti berikut :
```bash
clear
echo "=========================================================="
echo "                      TAMBAH PENGHUNI                     "
echo "=========================================================="
echo -n "Masukkan Nama: "
read -r nama
echo -n "Masukkan Kamar: "
read -r kamar
echo -n "Masukkan Hara Sewa: "
echo -n "Masukkan Tanggal Masuk (YYYY-MM-DD): "
read -r tanggal
echo -n "Masukkan Status Awal (Aktif/Menunggak): "
read -r status
```
Untuk menyimpan semua data dari penghuni, maka dibuat sistem database yang menyimpan semua data penghuni kost slebew. data disimpan di dalam file <u>penghuni.csv</u>.
```bash
DB_FILE="data/penghuni.csv"
```
Selanjutnya, terdapat input validate agar data yang dimasukkan valid dan sesuai dengan format yang tertera, untuk input Nomor Kamar harus terdapat validate agar kamar yang ditinggali tidak bentrok dengan penghuni lain yang sudah terdaftar. Dengan cara mencari di database penghuni apakah nomor kamar sudah ditempati atau belum. 
```bash
while true 
do
	echo -n "Masukkan Kamar: "
	read -r kamar

	kamar_ada=$(awk -F ',' -v k="$kamar" '$2 == k {print 1}' "$DB_FILE")

	if [ "$kamar_ada" == 1 ]; then
			echo "[-] Error: Kamar $kamar sudah terisi."
	else
			break
	fi
done
```
Untuk format harga sewa, harus berupa angka dan bernilai positif.
```bash
while true
do
	echo -n "Masukkan Harga Sewa: "
	read -r harga

	if [[ "$harga" =~ ^[0-9]+$ ]] && [ "$harga" -gt 0 ]; then
			break
	else
			echo "[-] Error: Harga sewa harus positif."
	fi
done
```
Selanjutnya, untuk tanggal masuk harus sesuai format YYYY-MM-DD, tanggal harus valid (contoh tidak valid : tanggal 30 Februari), dan tanggal tidak boleh melebihi hari ini (contoh tidak valid : hari ini tanggal 25 Maret 2026, input tnaggal 27 Maret 2026).
```bash
while true 
do
	echo -n "Masukkan Tanggal Masuk (YYYY-MM-DD): "
	read -r tanggal

	if date -d "$tanggal" >/dev/null 2>&1; then
			input_sec=$(date -d "$tanggal" +%s)
			now_sec=$(date +%s)

			if [ "$input_sec" -le "$now_sec" ]; then
					break
			else
					echo "[-] Error: Tanggal tidak boleh melebihi hari ini."
			fi
	else
			echo "[-] Error: Format tanggal salah! Gunakan YYYY-MM-DD (contoh: 2026-03-06)."
	fi
done
```
Selanjutnya, input status divalidate agar format inputnya sama dengan yang diinginkan ( aktif / menunggak ). Agar input menjadi case insensitive ( hurufnya bisa gede atau kecil ) maka ditambahkan ```status_lowcase="${status,,}"``` , line ini berguna buat menerima semua karakter input menjadi lower case. Untuk kode lengkapnya :
```bash
while true
do
	echo -n "Masukkan Status Awal (Aktif/Menunggak): "
	read -r status

	status_lowcase="${status,,}"

	if [[ "$status_lowcase" == "aktif" || "$status_lowcase" == "menunggak" ]]; then
			if [[ "$status_lowcase" == "aktif" ]]; then
					status="Aktif"
			else 
					status="Menunggak"
			fi

			break
	else 
			echo "[-] Error: Status harus diisi \"Aktif\" atau \"Menunggak\"."
	fi
done
```
Setelah semua input didapat, data dari input dimasukkan ke file ```DB_FILE``` ( data/penghuni.csv ).
```bash
echo "$nama,$kamar,$harga,$tanggal,$status" >> "$DB_FILE"
```
Agar setelah menginput data tidak langsung balik ke user interface awal, maka diberikan output & input konfirmasi ( tekan enter untuk kembali ) 
```bash
echo -e "\n[√] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status.\n"

read -r -p "Tekan [ENTER] untuk kembalik ke menu..."
```
Contoh output :

User Interface untuk opsi "tambah penguhuni baru" :
![User Interface opsi 1](assets/soal%203/image-2.png)

Tampilan jika semua input valid dan berhasil masuk ke dalam database :
![Berhasil ditambahkan](assets/soal%203/image-3.png)

Output jika nomor kamar sudah terdaftar dalam database :

![Nomor kamar sudah ada](assets/soal%203/image-4.png)

Output jika harga sewa tidak berupa angka atau harga sewa negatif :

![Harga sewa tidak valid](assets/soal%203/image-5.png)

Output jika penulisan format tanggal salah, tanggal tidak valid (tidak ada dalam kalender), dan apabila penanggalan melebihi tanggal hari ini :

![Format tanggal salah](assets/soal%203/image-6.png)

Output jiks terdapat typo pada penulisan status :

![Typo Status](assets/soal%203/image-7.png)

Contoh isi file ```DB_FILES``` :

![Isi file penghuni.csv](assets/soal%203/image-8.png)

---
**OPSI NOMOR 2** ( Hapus Data Penghuni ), yang berfungsi untuk menghapus data penghuni kost yang sudah terdaftar dalam database. Di dalam opsi ini, user memberi input berupa nama lengkap penghuni kost yang ingin dihapus. Dibuat user interface seperti berikut.
```bash
clear
echo "=========================================================="
echo "                      HAPUS PENGHUNI                      "
echo "=========================================================="
echo -n "Masukkan nama penghuni yang akan dihapus: "v
read -r nama_hapus
```
Untuk mencocokkan nama input dengan nama yang sudah ada di database penghuni, digunakan bantuan ```awk``` untuk mengambil nama yang sesuai dengan input user.
```bash
data_dihapus=$(awk -F ',' -v n="$nama_hapus" '$1 == n {print $0}' "$DB_FILE")
```
Jika nama yang diinput user tidak ada dalam database, baik jika inputnya typo, atau memang tidak ada namanya, maka program memberi pesan jika nama yang dicari tidak ada dalam list penghuni.
```bash
echo -e "\n[-] Error: Data penghuni \"$nama_hapus\" tidak ditemukan di sistem.\n"
```

Jika ditemukan maka inisialisasikan variabel buat menyimpan tanggal penghapusan dengan format ( YYYY-MM-DD ).
```bash
tgl_hps=$(date +%Y-%m-%d)
```
Lalu data tanggal hapus & isinya akan  disimpan ke dalam <u>sampah/history_hapus.csv</u>.
```bash
echo "$data_dihapus" | while IFS= read -r line; do
		echo "$line,$tgl_hps" >> "$HISTORY_FILE"
done
```
Kode diatas akan membaca nama orang baris demi baris buat berjaga jaga kalau ada lebih dari satu orang yang punya nama yang sama, diterapkan dalam baris kode ```while IFS= read -r line``` lalu menggabungkan variabel ```tgl_hps``` dengan data penghuni yang dihapus, lalu diappend ke dalam file ```HISTORY_FILE="sampah/history_hapus.csv"```.

Untuk menghapus baris data di dalam ```DB_FILE``` digunakan metode memindahkan semua baris database kecuali baris data yang ingin di hapus ke dalam file sementara, lalu mengganti file sementara tersebut menjadi file database baru yang sudah bersih dari nama penghuni yang dihapus.
```bash
awk -F',' -v n="$nama_hapus" '$1 != n' "$DB_FILE" > temp.csv
mv temp.csv "$DB_FILE"
```
Jika semua langkah berhasil, program akan memberikan output pemberitahuan jika data penghuni berhasil dihapus.
```bash
echo -e "\n[√] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke $HISTORY_FILE dan dihapus dari sistem.\n"
```
Contoh Output :

Output jika berhasil menghapus penghuni.

![Hapus Penghuni](assets/soal%203/image-9.png)

Output jika nama penghuni yang ingin dihapus tidak ditemukan atau terdapat typo di input namanya.

![Nama Penghuni Tidak Ditemukan](assets/soal%203/image-10.png)

Isi file history_hapus.csv

![History Hapus](assets/soal%203/image-11.png)


---
**OPSI NOMOR 3** berfungsi untuk menampilkan daftar semua penghuni kost slebew, apabila belum ada penghuni yang tercatat dalam database, program akan memberi output pemberitahuan jika belum ada data pada sistem.
```bash
if [ ! -s "$DB_FILE" ]; then
	echo -e "\n[-] Belum ada data penghuni di dalam sistem.\n"
```
Jika ada penghuni, maka program bakal memberi output tabel daftar penghuni, lengkap dengan nama penghuni, nomer kamar yang dihuni, harga sewa unitnya, dan statusnya. Untuk menghasilkan bentuk tabel yang rapi, maka perlu bantuan format specifier dari ```printf```. Kode buat tampilan header tabel seperti berikut.
```bash
printf "=================================================================\n"
printf "                       DAFTAR PENGHUNI KOST                      \n"
printf "=================================================================\n"
printf "%-3s | %-16s | %-7s | %-15s | %-10s |\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
printf "-----------------------------------------------------------------\n"
```
Selain menampilkan data nama, nomer kamar, harga sewa, dan statusnya. tabel juga menampilkan total jumlah penghuni, jumlah penghuni yang berstatus aktif, dan juga jumlah penghuni yang masih berstatus menunggak. Dibuat variabel untuk menyimpan jumlah penghuni aktif dan menunggak pada bagian ```BEGIN```.
```awk
 BEGIN {
	aktif = 0
	menunggak = 0

	...
)
```
Selanjutnya di body ```awk```-nya digunakan untuk membaca status semua penghuninya dan menjumlahkan masing-masing statusnya sesuai kategorinya.
```bash
if (tolower($5) == "aktif") {
		aktif++
} else if (tolower($5) == "menunggak") {
		menunggak++
}
```
Data awal harga sewa berupa string angka yang susah dibaca nominalnya, misal 5000000. Agar mudah dibaca oleh user, maka formatnya diganti menjadi Rp5.000.000 dengan cara per tiga angka paling belakang dari string angkanya, akan ditambahkan karakter titik ( . ). 
```bash
harga = $3
format_harga = ""
while (length(harga) > 3) {
		format_harga = "." substr(harga, length(harga)-2, 3) format_harga
		harga = substr(harga, 1, length(harga)-3)
}
format_harga = harga format_harga
```
dan ditampilkan ke dalam tabel yang rapi sesuai dengan ukuran format specifier headernya.
```bash
 printf "%-3s | %-16s | %-7s | Rp%-13s | %-10s |\n", NR, $1, $2, format_harga, $5
 ```
 Dibawah tabel yang menampilkan data penghuni, terdapat tabel untuk menampilkan total penghuni, penghuni yang berstatus aktif, dan penghuni yang berstatus menunggak.
 ```bash
 END {
	print "-----------------------------------------------------------------"
	printf "Total: %d penghuni | Aktif: %d | Menunggak: %d\n", NR, aktif, menunggak
	print "================================================================="
} 
 ```
Contoh Output :

Tampilan tabel yang menampilkan daftar penghuni kost slebew.

![Daftar Penghuni](assets/soal%203/image-12.png)

---
**OPSI NOMOR 4** berfungsi untuk mengupdate atau memperbarui status penghuni kost slebew. status penghuni bisa diupdate menjadi berstatus aktif atau berstatus menunggak. Dibuat dengan user interface sederhana seperti berikut.
```bash
echo "=================================================="
echo "                   UPDATE STATUS                  "
echo "=================================================="
echo -n "Masukkan Nama Penghuni: "
read -r nama_update
```
User harus memberi input nama penghuni secara lengkap supaya dapat ditemukan dalam database.
```bash
cek_nama=$(awk -F',' -v n="$nama_update" '$1 == n {print 1}' "$DB_FILE")
```
Kode diatas digunakan untuk mencari nama pengguna yang ingin diupdate statusnya, dengan cara apabila nama tersebut ada, ditandai dengan angka 1 yang digunakan untuk if statement berikut.
```bash
if [ "$cek_nama" == "1" ]; then
	...
else
	...
fi
```
Apabila nama yang diinput tidak valid, baik terdapat typo atau memang tidak ada nama tersebut di data base, program akan memberikan output pemberitahuan.
```bash
echo -e "\n[-] Error: Data penghuni \"$nama_update\" tidak ditemukan di sistem.\n"
```
Apabila nama tersebut ditemukan, maka user harus menginput status barunya.
```bash
while true; do
	echo -n "Masukkan Status Baru(Akitf/Menunggak): "
	read -r input_status
done
```
Karena input bisa case insensitive maka bisa diakali dengan setiap huruf input dibuat lower case dengan cara seperti berikut.
```bash
status_lower=$(echo "$input_status" | tr '[:upper:]' '[:lower:]')
```
kode diatas menyalurkan input status untuk dintranslate dari upper case menjadi lower case. Lalu input dicek apakah penulisannya benar atau tidak.
```bash
if [ "$status_lower" == "aktif" ]; then
		status_baru="Aktif"
		break
elif [ "$status_lower" == "menunggak" ]; then
		status_baru="Menunggak"
		break
else
		echo "[-] Error: Status harus diisi \"Aktif\" atau \"Menunggak\""
fi
```
Setelah itu, dilakukan update pada database lama agar kolom status penghuni berubah menjadi status yang baru. Metode yang digunakan dengan menggunakan bantuan ```awk``` untuk mencari nama yang penghuni lalu mengganti kolom statusnya menjadi status yang sudah diupdate.
```bash
awk -F',' -v n="$nama_update" -v s="$status_baru" 'BEGIN {OFS=","} {
		if ($1 == n) {
				$5 = s
		}
		print $0
}' "$DB_FILE" > temp.csv
mv temp.csv "$DB_FILE"

echo -e "\n[√] Status $nama_update berhasil diubah menjadi: $status_baru\n"
```

Contoh Output :

Output jika nama tidak ditemukan dalam database penghuni.

![Nama tidak ditemukan](assets/soal%203/image-13.png)

Jika ditemukan, user harus menginput update status penghuni.

![User input perubahan status](assets/soal%203/image-14.png)

Output jika input update terdapat typo atau salah ketik (tidak valid).

![Invalid input](assets/soal%203/image-15.png)

Output jika berhasil mengupdate status penghuni.

![Berhasil mengupdate status penghuni](assets/soal%203/image-16.png)

---

**OPSI NOMOR 5** Berguna untuk mencetak laporan keuangan yang dimana isinya ada total pemasukan bagi penghuni yang aktif dan total tunggakan bagi penghuni yang menunggak, terdapat juga informasi jumlah kamar yang terisi, dan juga nama nama penghuni yang masih terdapat tunggakan. Lalu hasil laporan disimpan ke dalam file ```rekap/laporan_bulanan.txt```.

```bash
clear

LAPORAN_FILE="rekap/laporan_bulanan.txt"

laporan=$(awk -F',' '
BEGIN {
		total_aktif = 0
		total_nunggak = 0
		kamar_terisi = 0
		list_nunggak = ""
		count_nunggak = 0
}
{
		kamar_terisi++
		harga = $3
		status = tolower($5)
		nama = $1

		if (status == "aktif") {
				total_aktif += harga
		} else if (status == "menunggak") {
				total_nunggak += harga
				count_nunggak++
				list_nunggak = list_nunggak "    " count_nunggak ". " nama "\n"
		}
} 
END {
		h_aktif = total_aktif
		f_aktif = ""
		if (h_aktif == 0 || h_aktif == "") f_aktif = "0"
		while (length(h_aktif) > 3) {
				f_aktif = "." substr(h_aktif, length(h_aktif)-2, 3) f_aktif
				h_aktif = substr(h_aktif, 1, length(h_aktif)-3)
		}
		f_aktif = "Rp" h_aktif f_aktif

		h_nunggak = total_nunggak
		f_nunggak = ""
		if (h_nunggak == 0 || h_nunggak == "") f_nunggak = "0"
		while (length(h_nunggak) > 3) {
				f_nunggak = "." substr(h_nunggak, length(h_nunggak)-2, 3) f_nunggak
				h_nunggak = substr(h_nunggak, 1, length(h_nunggak)-3)
		}
		f_nunggak = "Rp" h_nunggak f_nunggak

		print "=========================================================="
		print "               LAPORAN KEUANGAN KOST SLEBEW               "
		print "=========================================================="
		print "Total pemasukan (Aktif)  : " f_aktif
		print "Total tunggakan          : " f_nunggak
		print "Jumlah kamar terisi      : " kamar_terisi
		print "----------------------------------------------------------"
		print "Daftar penghuni menunggak:"
		
		if (count_nunggak == 0) {
				print "    Tidak ada tunggakan."
		} else {
				printf "%s", list_nunggak
		}
		
		print ""
		print "=========================================================="
}' "$DB_FILE")

echo "$laporan"

echo "$laporan" > "$LAPORAN_FILE"

echo -e "\n[√] Laporan berhasil disimpan ke $LAPORAN_FILE\n"
```
Kode diatas diawal dengan membuat variabel untuk total pendapatan, total tunggakan, total kamar yang terisi,dan menjumlah berapa orang yang masih berstatus menunggak. Disana juga terdapat variabel kosong yang nantinya diisi oleh nama orang yang berstatus menunggak.

Didalam bagian ```END``` agar output total pendapatan dan total tunggakan bisa dibaca dengan mudah, maka digunakan logika yang sama seperti di opsi 3.
```bash
#untuk total pendapatan
h_aktif = total_aktif
f_aktif = ""
if (h_aktif == 0 || h_aktif == "") f_aktif = "0"
while (length(h_aktif) > 3) {
		f_aktif = "." substr(h_aktif, length(h_aktif)-2, 3) f_aktif
		h_aktif = substr(h_aktif, 1, length(h_aktif)-3)
}
f_aktif = "Rp" h_aktif f_aktif

#untuk total tunggakan
h_nunggak = total_nunggak
f_nunggak = ""
if (h_nunggak == 0 || h_nunggak == "") f_nunggak = "0"
while (length(h_nunggak) > 3) {
		f_nunggak = "." substr(h_nunggak, length(h_nunggak)-2, 3) f_nunggak
		h_nunggak = substr(h_nunggak, 1, length(h_nunggak)-3)
}
f_nunggak = "Rp" h_nunggak f_nunggak
```
Lalu output dari laporan ditampilkan dan disimpan ke dalam file ```LAPORAN_FILE="rekap/laporan_bulanan.txt"```.
```bash
echo "$laporan"

echo "$laporan" > "$LAPORAN_FILE"
```

Contoh Output :

![Output laporan keuangan](assets/soal%203/image-17.png)

Isi file ```laporan_bulanan.txt```.

![Isi laporan_bulanan.txt](assets/soal%203/image-18.png)

---
**OPSI NOMOR 6** berfungsi untuk mengelola otomatisasi pengingat tagihan menggunakan Cron Job. Fitur ini terbagi menjadi dua bagian, yaitu logika eksekusi di latar belakang dan menu kelola cron untuk user. Untuk logika eksekusi latar belakang, kode diletakkan pada baris paling awal skrip agar dieksekusi sebelum looping menu utama muncul.

Dibuat blok kode ```if``` yang mendeteksi argumen ```--check-tagihan``` saat program dijalankan. Argumen ini nantinya dipicu secara otomatis oleh perintah Cron. Jika argumen tersebut ada, program akan menginisialisasi direktori file log dan mengambil data waktu saat ini.
```bash
if [ "$1" == "--check-tagihan" ]; then
    
    LOG_FILE="log/tagihan.log"
    WAKTU=$(date "+%Y-%m-%d %H:%M:%S")
```

Selanjutnya, dilakukan validasi keberadaan file database menggunakan ```-s``` untuk memastikan ```DB_FILE``` ada dan tidak kosong. Jika valid, program akan mencetak header penanda waktu ke dalam file log.
```bash
if [ -s "$DB_FILE" ]; then
        echo "=== Pengecekan Otomatis: $WAKTU ===" >> "$LOG_FILE"
```
Untuk memproses data tagihan penghuni, digunakan bantuan ```awk``` untuk mengecek status penghuni baris demi baris. Status pada kolom kelima diubah menjadi lower case dan dicek apakah bernilai "menunggak". Jika iya, nama dan nomor kamar dicetak ke file log sebagai peringatan, dan variabel ```count``` ditambahkan nilainya.
```bash
awk -F',' '
BEGIN { count = 0 }
{
		if (tolower($5) == "menunggak") {
				print "Peringatan: " $1 " (Kamar " $2 ") belum membayar sewa." >> "'"$LOG_FILE"'"
				count++
		}
}
```
Pada bagian ```END```, jika variabel ```count``` tetap bernilai 0 (tidak ada yang menunggak), maka program akan mencetak pesan bahwa semua penghuni berstatus aman. Terakhir, diberikan ```exit 0``` agar program langsung berhenti dan tidak mengeksekusi perulangan User Interface menu utama saat dijalankan oleh sistem Cron di latar belakang.
```bash
        END {
            if (count == 0) {
                print "Aman: Semua penghuni berstatus Aktif." >> "'"$LOG_FILE"'"
            }
            print "----------------------------------------" >> "'"$LOG_FILE"'"
        }' "$DB_FILE"
    fi
    exit 0
fi
```

Setelah logika eksekusi latar belakang selesai didefinisikan, program dilanjutkan dengan membuat user interface agar user dapat mendaftarkan, melihat, atau menghapus jadwal Cron Job tersebut dengan mudah tanpa harus mengetik perintah Linux secara manual.

Langkah pertama pada bagian menu ini adalah mendeteksi lokasi absolut (absolute path) dari skrip ini berada.
```bash
SCRIPT_PATH=$(realpath "$0")
CRON_CMD="$SCRIPT_PATH --check-tagihan"
```
Variabel ```CRON_CMD``` akan menyimpan perintah lengkap yang nantinya didaftarkan ke dalam sistem Cron (contoh: ```/home/user/soal_3/kost_slebew.sh --check-tagihan```).

Lalu selanjutnya membuat user interfacenya.
```bash
while true; do
	clear
	echo "=================================================="
	echo "                 MENU KELOLA CRON                 "
	echo "=================================================="
	echo " 1. Lihat Cron Job Aktif"
	echo " 2. Daftarkan Cron Job Pengingat"
	echo " 3. Hapus Cron Job Pengingat"
	echo " 4. Kembali"
	echo "=================================================="
	echo -n "Pilih [1-4]: "
	read -r cron_opt
```
Pada Sub-opsi 1 (Lihat Cron Job Aktif), program menggunakan perintah ```crontab -l``` untuk melihat daftar jadwal yang ada di sistem, lalu disaring menggunakan ```grep``` khusus untuk mencari variabel ```$CRON_CMD```. Jika tidak ditemukan, program akan memunculkan pesan "Tidak ada cron job aktif." menggunakan operator || (OR).
```bash
1)
	echo -e "\n--- Daftar Cron Job Pengingat Tagihan ---"
	crontab -l 2>/dev/null | grep "$CRON_CMD" || echo "Tidak ada cron job aktif."
```
Pada Sub-opsi 2 (Daftarkan Cron Job Pengingat), user diminta memasukkan jam dan menit eksekusi. Dilakukan validasi menggunakan Regex (```=~ ^[0-9]+$```) dan komparasi numerik untuk memastikan input jam berada di rentang 0-23 dan menit di rentang 0-59.
```bash
2)
	echo ""
	echo -n "Masukkan Jam (0-23): "
	read -r jam
	echo -n "Masukkan Menit (0-59): "
	read -r menit

	if [[ "$jam" =~ ^[0-9]+$ ]] && [ "$jam" -ge 0 ] && [ "$jam" -le 23 ] && \
			[[ "$menit" =~ ^[0-9]+$ ]] && [ "$menit" -ge 0 ] && [ "$menit" -le 59 ]; then
```

Jika input valid, program akan mendaftarkannya ke sistem. Untuk mencegah duplikasi jadwal, program terlebih dahulu mengambil list crontab saat ini, membuang jadwal lama yang berhubungan dengan skrip ini (```grep -v```), menambahkan jadwal baru dengan format standar cron (```$menit $jam * * *```), lalu memasukkannya kembali ke sistem menggunakan | crontab -.
```bash
(crontab -l 2>/dev/null | grep -v "$CRON_CMD"; echo "$menit $jam * * * $CRON_CMD") | crontab -
echo -e "\n[√] Cron job berhasil didaftarkan untuk pukul $jam:$menit."
```
Pada Sub-opsi 3 (Hapus Cron Job Pengingat), logikanya mirip dengan sub-opsi 2, namun program hanya mengambil list crontab saat ini, membuang baris yang mengandung perintah skrip (```grep -v```), dan langsung menyimpannya kembali. Hasilnya, jadwal otomatis terhapus dari sistem.
```bash
 3)
	crontab -l 2>/dev/null | grep -v "$CRON_CMD" | crontab -
	echo -e "\n[√] Cron job pengingat tagihan berhasil dihapus.\n"
```

Contoh Output :

Tampilan User Interface pada opsi 6 (cron management).

![UI cron management](assets/soal%203/image-19.png)

Output jika belum ada jadwal cron yang dibuat.

![Cron belom tersedia](assets/soal%203/image-20.png)

Output jika sudah ada jadwal cron yang dibuat.

![cron tersedia](assets/soal%203/image-21.png)

Output pada sub-opsi 2 (mendaftarkan cron job)

![daftarkan cronjob](assets/soal%203/image-22.png)

Output jika pada sub-opsi 2 input yang dimasukkan tidak valid.

![input tidak valid](assets/soal%203/image-23.png)

Output untuk sub-opsi 3 (menghapus cron job pengingat)

![hapus cron job](assets/soal%203/image-24.png)

---
**OPSI NOMOR 7** berfungsi untuk mengakhiri program, yaitu dengan menggunakan ```exit 1```.

```bash
"7")
	exit 1
	;;
```

---
Jika opsi yang diinput tidak sesuai dengan opsi yang tersedia maka program akan memberi output "Opsi Tidak Tersedia.".
```bash
*)
	echo "Opsi tidak tersedia."
```

**Kendala :**

Untuk soal nomor 3 ini banyak bangettt... harus bener bener nguli. lalu juga untuk bagian cron job karena belum familiar, jadi perlu bantuan AI banyak banget.


## REVISI

Untuk output **SOAL 1** opsi d yaitu menghitung rata-rata. Output yang benar adalah membulatkan rata-rata usia penumpang ke bawah (menjadi 37 bukan 38). maka diubah dalam kode dari :
```bash
else if (opsi == "d"){
	average = total_age / count_passenger
	printf("Rata-rata usia penumpang adalah %.0f tahun\n", average)
```
menjadi menggunakan tipe data integer :
```bash
else if (opsi == "d"){
	average = total_age / count_passenger
	printf("Rata-rata usia penumpang adalah %d tahun\n", int(average))
```
maka output yang sekarang menjadi :
![revisi opsi d](assets/soal%201/revisi-d.png)

Untuk **SOAL 3** ditambahkan contraint ```[ "$kamar" -gt 0 ]```pada pilihan opsi tambah penghuni ketika memberi input nomor kamar agar tidak memberi input angka negatif.
![menambahkan constraint pada opsi nomor kamar](assets/soal%203/revisi-1.png)

---
DENGAN BEGINI LAPORAN RESMI SISOP MODUL 1 TELAH SELESAI ! ! ! ! ! ! ! !

![MENGKEREN](assets/soal%203/mengkeren.png)