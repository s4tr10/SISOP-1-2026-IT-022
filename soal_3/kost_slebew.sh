#!/bin/bash

DB_FILE="data/penghuni.csv"
HISTORY_FILE="sampah/history_hapus.csv"

if [ "$1" == "--check-tagihan" ]; then
    
    LOG_FILE="log/tagihan.log"
    WAKTU=$(date "+%Y-%m-%d %H:%M:%S")
    
    if [ -s "$DB_FILE" ]; then
        echo "=== Pengecekan Otomatis: $WAKTU ===" >> "$LOG_FILE"
        awk -F',' '
        BEGIN { count = 0 }
        {
            if (tolower($5) == "menunggak") {
                print "Peringatan: " $1 " (Kamar " $2 ") belum membayar sewa." >> "'"$LOG_FILE"'"
                count++
            }
        }
        END {
            if (count == 0) {
                print "Aman: Semua penghuni berstatus Aktif." >> "'"$LOG_FILE"'"
            }
            print "----------------------------------------" >> "'"$LOG_FILE"'"
        }' "$DB_FILE"
    fi
    exit 0
fi



option=0

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

    case "$option" in
        "1")
            clear
            echo "=========================================================="
            echo "                      TAMBAH PENGHUNI                     "
            echo "=========================================================="
            echo -n "Masukkan Nama: "
            read -r nama

            while true 
            do
                echo -n "Masukkan Kamar: "
                read -r kamar

                # Validasi Lapis 1: Cek apakah input murni angka DAN lebih besar dari 0
                if [[ "$kamar" =~ ^[0-9]+$ ]] && [ "$kamar" -gt 0 ]; then
                    
                    # Validasi Lapis 2: Cek apakah kamar sudah ada di database
                    kamar_ada=$(awk -F ',' -v k="$kamar" '$2 == k {print 1}' "$DB_FILE")

                    if [ "$kamar_ada" == "1" ]; then
                        echo "[-] Error: Kamar $kamar sudah terisi."
                    else
                        break # Lolos semua validasi, keluar dari loop
                    fi
                    
                else
                    echo "[-] Error: Nomor kamar harus berupa angka positif."
                fi
            done

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

            echo "$nama,$kamar,$harga,$tanggal,$status" >> "$DB_FILE"

            echo -e "\n[√] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status.\n"

            read -r -p "Tekan [ENTER] untuk kembalik ke menu..."
            ;;
        "2")
            clear
            echo "=========================================================="
            echo "                      HAPUS PENGHUNI                      "
            echo "=========================================================="
            echo -n "Masukkan nama penghuni yang akan dihapus: "
            read -r nama_hapus

            data_dihapus=$(awk -F ',' -v n="$nama_hapus" '$1 == n {print $0}' "$DB_FILE")
            if [ -n "$data_dihapus" ]; then
                tgl_hps=$(date +%Y-%m-%d)

                echo "$data_dihapus" | while IFS= read -r line; do
                    echo "$line,$tgl_hps" >> "$HISTORY_FILE"
                done

                awk -F',' -v n="$nama_hapus" '$1 != n' "$DB_FILE" > temp.csv
                mv temp.csv "$DB_FILE"

                echo -e "\n[√] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke $HISTORY_FILE dan dihapus dari sistem.\n"
            else
                echo -e "\n[-] Error: Data penghuni \"$nama_hapus\" tidak ditemukan di sistem.\n"
            fi

            read -r -p "Tekan [ENTER] untuk kembali ke menu..."
            ;;
        "3")
            clear

            if [ ! -s "$DB_FILE" ]; then
                echo -e "\n[-] Belum ada data penghuni di dalam sistem.\n"
            else 
                awk -F',' '
                BEGIN {
                    aktif = 0
                    menunggak = 0

                    printf "=================================================================\n"
                    printf "                       DAFTAR PENGHUNI KOST                      \n"
                    printf "=================================================================\n"
                    printf "%-3s | %-16s | %-7s | %-15s | %-10s |\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
                    printf "-----------------------------------------------------------------\n"
                }
                {
                    if (tolower($5) == "aktif") {
                        aktif++
                    } else if (tolower($5) == "menunggak") {
                        menunggak++
                    }

                    harga = $3
                    format_harga = ""
                    while (length(harga) > 3) {
                        format_harga = "." substr(harga, length(harga)-2, 3) format_harga
                        harga = substr(harga, 1, length(harga)-3)
                    }
                    format_harga = harga format_harga

                    printf "%-3s | %-16s | %-7s | Rp%-13s | %-10s |\n", NR, $1, $2, format_harga, $5
                }
                END {
                    print "-----------------------------------------------------------------"
                    printf "Total: %d penghuni | Aktif: %d | Menunggak: %d\n", NR, aktif, menunggak
                    print "================================================================="
                } 
                ' "$DB_FILE"
            fi

            echo ""
            read -r -p "Tekan [ENTER] untuk kembali ke menu..."
            ;;
        "4")
            clear
            echo "=================================================="
            echo "                   UPDATE STATUS                  "
            echo "=================================================="
            echo -n "Masukkan Nama Penghuni: "
            read -r nama_update

            cek_nama=$(awk -F',' -v n="$nama_update" '$1 == n {print 1}' "$DB_FILE")

            if [ "$cek_nama" == "1" ]; then
                while true; do
                    echo -n "Masukkan Status Baru(Akitf/Menunggak): "
                    read -r input_status

                    status_lower=$(echo "$input_status" | tr '[:upper:]' '[:lower:]')

                    if [ "$status_lower" == "aktif" ]; then
                        status_baru="Aktif"
                        break
                    elif [ "$status_lower" == "menunggak" ]; then
                        status_baru="Menunggak"
                        break
                    else
                        echo "[-] Error: Status harus diisi \"Aktif\" atau \"Menunggak\""
                    fi
                done

                awk -F',' -v n="$nama_update" -v s="$status_baru" 'BEGIN {OFS=","} {
                    if ($1 == n) {
                        $5 = s
                    }
                    print $0
                }' "$DB_FILE" > temp.csv
                mv temp.csv "$DB_FILE"

                echo -e "\n[√] Status $nama_update berhasil diubah menjadi: $status_baru\n"

            else 
                echo -e "\n[-] Error: Data penghuni \"$nama_update\" tidak ditemukan di sistem.\n"
            fi

            read -r -p "Tekan [ENTER] untuk kembali ke menu..."
            ;;
        "5")
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
                # Format Ribuan Aktif
                h_aktif = total_aktif
                f_aktif = ""
                if (h_aktif == 0 || h_aktif == "") f_aktif = "0"
                while (length(h_aktif) > 3) {
                    f_aktif = "." substr(h_aktif, length(h_aktif)-2, 3) f_aktif
                    h_aktif = substr(h_aktif, 1, length(h_aktif)-3)
                }
                f_aktif = "Rp" h_aktif f_aktif

                # Format Ribuan Menunggak
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

            # Tampilkan ke layar
            echo "$laporan"
            
            # Simpan ke file
            echo "$laporan" > "$LAPORAN_FILE"

            echo -e "\n[√] Laporan berhasil disimpan ke $LAPORAN_FILE\n"
            
            read -r -p "Tekan [ENTER] untuk kembali ke menu..."

            ;;
        "6")
            SCRIPT_PATH=$(realpath "$0")
            CRON_CMD="$SCRIPT_PATH --check-tagihan"

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

                case "$cron_opt" in
                    1)
                        echo -e "\n--- Daftar Cron Job Pengingat Tagihan ---"
                        crontab -l 2>/dev/null | grep "$CRON_CMD" || echo "Tidak ada cron job aktif."
                        
                        echo ""
                        read -r -p "Tekan [ENTER] untuk kembali..."
                        ;;
                    2)
                        echo ""
                        echo -n "Masukkan Jam (0-23): "
                        read -r jam
                        echo -n "Masukkan Menit (0-59): "
                        read -r menit

                        if [[ "$jam" =~ ^[0-9]+$ ]] && [ "$jam" -ge 0 ] && [ "$jam" -le 23 ] && \
                           [[ "$menit" =~ ^[0-9]+$ ]] && [ "$menit" -ge 0 ] && [ "$menit" -le 59 ]; then
                            
                            (crontab -l 2>/dev/null | grep -v "$CRON_CMD"; echo "$menit $jam * * * $CRON_CMD") | crontab -
                            
                            echo -e "\n[√] Cron job berhasil didaftarkan untuk pukul $jam:$menit."
                        else
                            echo -e "\n[-] Error: Jam atau Menit tidak valid!"
                        fi
                        
                        echo ""
                        read -r -p "Tekan [ENTER] untuk kembali..."
                        ;;
                    3)
                        crontab -l 2>/dev/null | grep -v "$CRON_CMD" | crontab -
                        
                        echo -e "\n[√] Cron job pengingat tagihan berhasil dihapus.\n"
                        read -r -p "Tekan [ENTER] untuk kembali..."
                        ;;
                    4)
                        break
                        ;;
                    *)
                        echo "Opsi tidak valid."
                        sleep 1
                        ;;
                esac
            done
            ;;
        "7")
            exit 1
            ;;
        *)
            echo "Opsi tidak tersedia."
    esac
done

