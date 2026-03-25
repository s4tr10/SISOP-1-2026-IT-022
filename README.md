# SISOP-1-2026-IT-022
#### Muhammad Satrio Utomo | 50272521022
## Repository Structure
![Struktur Repository](assets/soal%201/repo-structure.png)

## Reporting
### Soal 1

Deskripsi :

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

### Soal 2
Deskripsi : 

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

### Soal 3
Deskripsi : 

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

Selanjutnya, untuk opsi nomer 1 ( Tambah Penghuni Baru ), didalamnya user bakal menginput nama penghuni, nomer kamar, harga sewa kostnya, tanggal masuk dengan format (YYYY-MM-DD), status awal ( aktif jika lunas / menunggak jika nyicil ). Dibuat header & user interface seperti berikut :
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
