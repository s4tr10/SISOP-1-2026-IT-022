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

NR > 1 {
	sub(/\r$/, "")

	name = $1
	age = $2
	class = $3
	carriage = $4

	if(name != "") {
		count_passenger++
		total_age += age
	}

	if(carriage != ""){
		list_carriage[carriage] = 1
	}

	if(age > oldest){
		oldest = age
		oldest_name = name
	}

	if(class ~ /Business/){
		total_business++
	}
}

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
		printf("Rata-rata usia penumpang adalah %d tahun\n", int(average))
	}	else if (opsi == "e"){
		print("Jumlah penumpang business class adalah", total_business, "orang")
	}
}

