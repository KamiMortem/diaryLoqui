#!/bin/bash

ayuda () {
	echo "--------- diaryLoqui -----------"
	echo "Este script, es para llevar un registro diario encriptado y seguro, con gpg."
	echo ""
	echo "Opciones a emplear:"
	echo "			-r   "destinado, o llave personal" "
	echo "			-u   "firmar" "
	echo "			-e   "usar un editor diferente al que viene por defecto" "
	echo "			-m   "usar para modificar un registro anterior al actual" "
	echo "			-b   "buscar por etiqueta" "
	echo " 			-n   "escribir una nota, elijiendo el conjunto de notas y agruparlos "(con menu)"" "
	echo " "
	echo "			-v   "usar para ver un registro de un dia en particular" "
	echo "			-eti "usar para listar todas las fechas con sus respectivas etiquetas" "
	echo "			-ayuda "Muestra el pequeño instructivo" "

	echo " "
	echo "Ejemplos:"
	echo "		* diaryLoqui ./home/emilio/reg.zip -r Emilio -u Emilio -e vim 		<- Ingresa a ese comprimido, un archivo de texto encriptado y firmado el cual crearemos al abrirse el editor de texto vim "
	echo "		* diaryLoqui ./home/emilio/reg.zip -r Emilio 		<- Ingresa a ese comprimido, un archivo de texto encriptado, el cual crearemos al abrirse el editor de texto por defecto del sistema. "
	echo "		* diaryLoqui ./home/emilio/ -r Emilio 		<- Crea en esa carpeta, un comprimido, en el cual se ingresara un archivo de texto encriptado, el cual crearemos al abrirse el editor de texto por defecto del sistema. "

	echo "Licencia: GNU GENERAL PUBLIC LICENSE Versión 3"
	echo "Creado por: Emilio Jesus Calderon"
}

# Codigo...

#		Funiones...


borradoSeguro () {
	if [ "$tipoUbicacion" == "comp" ]; then
		yaGuardados=$(unzip -l $ubicacion)
		for a in $yaGuardados
		do
			if [ "$a" == "$nombre.gpg" ]; then
				bandBorrar="true"
			fi
		done
	else
		if [ $( unzip -l $ubicacion/$nombre-Loqui.zip 2> /dev/null | wc -l) != 1 ]; then
			bandBorrar="true"
		fi
	fi
	if [ "$bandBorrar" == "true" ]; then
		tmp="true"
		cant=$( wc -l $nombre | awk '{print $1}')
		for num in $(seq 1 $cant)
		do
			if [ "$tmp" == "true" ]; then
				$( echo "asdasdasdasdasdasdasdasdasdasdasdasdasdasdadasdasdas" > $nombre )
				tmp="false"
			else
				$( echo "asdasdasdasdasdasdasdasdasdasdasdasdasdasdadasdasdas00-*+|" >> $nombre )
			fi
		done
		$( rm $nombre )
		$( rm $nombre.gpg )
		if [ "$parameN" != "true" ]; then
			$( rm $nombreEtiqueta )
			$( rm $nombreEtiqueta.gpg )
		fi
	else
		echo "- - - - - - - - - - - - - - - - - - - - - - - -"
		echo "- - - - - - - - - - - - - - - - - - - - - - - -"
		echo "- - - - - - - - - - - - - - - - - - - - - - - -"
		echo " FALLO EN ENCRIPTAR, NO SE BORRARA EL ARCHIVO 	"
		echo "- - - - - - - - - - - - - - - - - - - - - - - -"
		echo "- - - - - - - - - - - - - - - - - - - - - - - -"
		echo "- - - - - - - - - - - - - - - - - - - - - - - -"
	fi
}

guardarEnc () {
	if [ "$tipoUbicacion" == "carp" ]; then
		$( zip "$nombre-Loqui.zip" "$nombre.gpg" > /dev/null)
		$( mv "$nombre-Loqui.zip" $ubicacion )
		$( zip -u $ubicacion "$nombreEtiqueta.gpg"  > /dev/null)
	elif [ "$tipoUbicacion" == "comp" ]; then
		$( zip -u $ubicacion "$nombre.gpg"  > /dev/null)
		$( zip -u $ubicacion "$nombreEtiqueta.gpg"  > /dev/null)
	else
		echo " ERROR no se pudo comprimir"
	fi
}

encriptado () {
	if [ "$parameU" == "true" ]; then
		echo "firmando..."
		$( gpg -se -r $destinatario -u $remitente $nombre )
			if [ "$parameN" != "true" ]; then
				$( gpg -se -r $destinatario -u $remitente $nombreEtiqueta )
			fi
	else
		$( gpg -e -r $destinatario $nombre )
			if [ "$parameN" != "true" ]; then
				$( gpg -e -r $destinatario $nombreEtiqueta )
			fi
	fi
}

mostrarEtiquetasPorFecha () {
	echo " "
	obtenerListaEtiqueta
	echo " "
	echo " "
	echo "Las fechas con sus etiquetas:"
	#echo "$(cat eti.txt)"
	echo " "
	echo "- - - - - - - - - - - - - - - - - - - - - - - "
	echo "Archivos                   Etiquetas"
	etiAnterior=""
	for x in $(cat "eti.txt")
	do
		if [ "$etiAnterior" != $(echo "$x" | cut -d ";" -f 2) ]; then
			etiAnterior="$(echo "$x" | cut -d ";" -f 2)"
			echo "- - - - - - - - - - - - - - - - - - - - - - - "
			echo "$(echo "$x" | cut -d ";" -f 2)     $(echo "$x" | cut -d ";" -f 1)"
		else
			echo "                           $(echo "$x" | cut -d ";" -f 1)"
		fi
		echo ""
	done
	echo "- - - - - - - - - - - - - - - - - - - - - - - "
	$(rm "eti.txt")
}

carpetasNotas () {
	for x in $(unzip -l $ubicacion)
	do
		if [ "$(echo "$x" | grep carpetasDeNotas.txt.gpg)" == "$x" ]; then
			echo "Las Carpetas son:"
			$( unzip -j $ubicacion "$x"  )
			$( gpg -o ${x%.gpg} -d $x )
			echo " "
			echo " "
			cat carpetasDeNotas.txt
			$(rm $x)
		fi
	done
	if [ ! -f "carpetasDeNotas" ]; then
		$(touch carpetasDeNotas.txt)
	fi
	echo " "
	echo " "
	echo "Elija una de las carpetas o ingrese un nuevo nombre para crearla"
	echo " "
	read carpeta
	existeCarpeta="false"
	for x in $(cat carpetasDeNotas.txt)
	do
		if [ "$x" == "$carpeta" ]; then
			existeCarpeta="true"
		fi
	done
	nombre=carpetasDeNotas.txt
	if [ "$existeCarpeta" == "false" ]; then
		$(echo $carpeta >> carpetasDeNotas.txt)
		encriptado
		$( zip -u $ubicacion "$nombre.gpg"  > /dev/null)
		$(rm "$nombre.gpg")
	fi
	$(rm "$nombre")

}

notas () {
	carpetasNotas
	echo " "
	echo "Las notas dentro de esta carpeta, que escribio son: "
	echo " "
	for x in $(unzip -l $ubicacion)
	do
		if [ "$(echo "$x" | grep $carpeta-Not)" == "$x" ]; then
			echo "${x%"-$carpeta-Not.txt.gpg"}"
		fi
	done
	echo " "
	echo "Escriba una de las notas anteriores para modificarlas o ingrese un nuevo nombre para crear una nueva nota"
	echo " "
	read nombre
	nombre="${nombre%.gpg}-$carpeta-Not.txt"
	echo " "
}

obtenerListaEtiqueta () {
	yaGuardados=$(unzip -l $ubicacion)
	for x in $yaGuardados
	do
		if [ "$(echo "$x" | grep Eti)" == "$x" ]; then
			$(unzip -j $ubicacion $x)
			for en in $(gpg -d "$x")
			do
				$(echo "$en;$x " >> eti.txt)
				#echo "$en;$x "
			done
		fi
	done
	$(rm *Eti.txt.gpg)
}

buscarPorEtiqueta () {
	obtenerListaEtiqueta
	echo " "
	echo " "
	echo " "
	echo "Elija desde las siguientes etiquetas:"
	echo " "
	echo "$(cat "eti.txt" | cut -d ";" -f 1 | sort | uniq )"
	echo " "
	echo "Escriba las etiquetas elejidas: (Si elije mas de una, separarlas con un espacio entre ellas)"
	read etiquetas
	listaFechas=""
	etiAnterior=""
	for x in $(cat "eti.txt")
	do
		if [ "$etiAnterior" != $(echo "$x" | cut -d ";" -f 2) ]; then
			contEti=0
			etiAnterior="$(echo "$x" | cut -d ";" -f 2)"
		fi
		for et in $etiquetas
		do
			if [ "$et" == "$(echo "$x" | cut -d ";" -f 1 | grep $et)" ]; then
				contEti=$(expr $contEti + 1)
			fi
		done
		if [ "$contEti" -ge "$(echo "$etiquetas" | wc -w )" ]; then
			listaFechasEtiquetas="$(echo "$x" | cut -d ";" -f 2)"
			listaFechas="$listaFechas\n${listaFechasEtiquetas%Eti.txt.gpg}Reg.txt.gpg "
		fi
	done
	listaFechas="$(echo -e "$listaFechas" | sort | uniq)"
	
	if [ "$(echo "$listaFechas" | wc -w)" -eq 0 ]; then
		echo " "
		echo " "
		echo "No se encontraron fechas con todas esas etiquetas a la vez..."
		echo " "
		echo "Apriete ENTER para continuar, o apriete CTRL + C para salir"
		$(rm "eti.txt")
		read
		buscarPorEtiqueta
	fi
	echo " "
	echo "Las fechas que corresponden con esas etiquetas son:"
	echo " "
	echo "$listaFechas"
	echo " "
	echo "Escriba la fecha a ir:"
	read buscar
	echo " "
	echo "La fecha $buscar, tiene como etiquetas:"
	for x in $(cat "eti.txt")
	do
		if [ "$(echo "$x" | cut -d ";" -f 2)" == "${buscar%Reg.txt.gpg}Eti.txt.gpg" ]; then
			echo "$(echo "${x%Eti.txt.gpg}Reg.txt.gpg" | cut -d ";" -f 1)"
		fi
	done
	echo " "
	echo "Apriete ENTER para continuar, o apriete CTRL + C para salir"
	$(rm "eti.txt")
	read
	comprobarExiste
	escribirArchivo
	encriptado
	guardarEnc
	borradoSeguro
}

comprobarExiste () {
	if [ "$tipoUbicacion" == "comp" ]; then
		yaGuardados=$(unzip -l $ubicacion)
		parameVsin="true"
		if [ "$parameM" == "true" -o "$parameB" == "true" -o "$parameV" == "true" ]; then
			nombre="${buscar%.gpg}"
			nombreEtiqueta="${buscar%-Reg.txt.gpg}-Eti.txt"
		else
			nombre="$nombre"
			nombreEtiqueta="$nombreEtiqueta"
		fi
		for x in $yaGuardados
		do
			if [ "$parameV" == "true" ]; then
				if [ "$x" == "$nombre.gpg" ]; then
					$( unzip -j $ubicacion "$x" )
					$( unzip -j $ubicacion "$nombreEtiqueta.gpg"  )
					echo " "
					echo " "
					echo "Las etiquetas son: "
					gpg -d $nombreEtiqueta.gpg
					echo " "
					echo "apriete ENTER para continuar"
					read
					echo " "
					gpg -d $x
					echo " "
					$( rm $x)
					$( rm $nombreEtiqueta.gpg )
					parameVsin="false"
				fi
			elif [ "$x" == "$nombre.gpg" ]; then
				$( unzip -j $ubicacion "$x"  )
				$( unzip -j $ubicacion "$nombreEtiqueta.gpg"  )
				if [ "$parameB" != "true" ]; then
					echo "YA HAY UN REGISTRO DE ESTE DIA, INGRESE LA CONTRASEÑA PARA DESENCRIPTARLO Y MODIFICARLO"
				else
					parameVsin="false"
				fi
				$( gpg -o $nombre -d $x )
				$( gpg -o $nombreEtiqueta -d "$nombreEtiqueta.gpg" )
				$( zip -d $ubicacion $x )
				$( zip -d $ubicacion "$nombreEtiqueta.gpg" )
				$( rm $x )
				$( rm $nombreEtiqueta.gpg )
			fi
		done
		if [ "$parameB" == "true" -o "$parameV" == "true" -a "$parameVsin" == "true" ]; then
			echo "NO SE LO ENCONTRO, SEGURAMENTE TIPIO MAL-"
		fi
	fi
}

escribirArchivo () {
	if [ "$parameM" == "true" ]; then
		echo " "
		echo "Esta fecha tiene como etiquetas: "
		echo "$(cat $nombreEtiqueta 2> /dev/null)"
		echo " "
		echo "Apriete ENTER para continuar"
		read
	else
		#obtenerListaEtiqueta
		echo " "
		echo " "
		#echo "Todas las etiquetas que hasta ahora uso son:"
		#echo "$(cat "eti.txt" | cut -d ";" -f 1 | sort | uniq )"
		echo " "
		#echo "Apriete ENTER para continuar "
		#read
		#$(rm "eti.txt")
	fi
	$( echo "------------------------------" >> $nombre )
	$( echo "- $( date +%F--%H:%M:%S ) -" >> $nombre )
	$( echo "------------------------------" >> $nombre )
	$( echo " " >> $nombre )
	if [ "$parameE" == "true" ]; then
		$editor $nombre
		echo " "
		echo " "
		if [ "$parameN" != "true" ]; then
			echo " Apriete ENTER y luego escriba las etiquetas del registro "
			read
			$editor $nombreEtiqueta
		fi
	else
		if [ "$EDITOR" != "" ]; then
			$EDITOR $nombre
			echo " "
			echo " "
			if [ "$parameN" != "true" ]; then
				echo " Apriete ENTER y luego escriba las etiquetas del registro "
				read
				$EDITOR $nombreEtiqueta
			fi
		else
			nano $nombre
			echo " "
			echo " "
			if [ "$parameN" != "true" ]; then
				echo " Apriete ENTER y luego escriba las etiquetas del registro "
				read
				nano $nombreEtiqueta
			fi
		fi
	fi
	$( echo "------------------------------" >> $nombre )
	$( echo " " >> $nombre )

	#echo "--------------------------------"
	#echo "Ingrese la informacion:"
	#
	#until [ "$text" == "fin" ]
	#do
	#	read text
	#	$( echo "$text" >> $nombre )
	#done
	#
	#echo "--------------------------------"
}

comprobarAnterior () {
	if [ "$parametroAnterior" == "-r" ]; then
		destinatario="$parametro"
		if [ -n "$(gpg --list-secret-keys | grep $destinatario)" ]; then
       parameR="true"
    else
      echo "ERROR:No se encontro llave"
      todoOkey="false"
    fi
	elif [ "$parametroAnterior" == "-u" ]; then
		remitente="$parametro"
		if [ -n "$(gpg --list-public-keys | grep $remitente)" ]; then
       parameU="true"
		else
			echo "ERROR:No se encontro llave"
      todoOkey="false"
		fi
	elif [ "$parametroAnterior" == "-e" ]; then
		editor="$parametro"
		if [ $( find /usr/bin/ -name "$editor" | wc -l) == 1 ]; then
			parameE="true"
		else
			echo "No es un editor instalado"
			todoOkey="false"
		fi
	fi
}

comprobarParametro () {
	if [ "$parametro" == "-ayuda" ]; then
		ayuda
		parameAyuda="true"
	elif [ "$parametro" == "-v" ]; then
		parameV="true"
		if [ "$parameR" == "true" -o "$parameU" == "true" ]; then
			todoOkey="false"
			echo "NO SE PUEDE PONER -R O -U CON -V"
		fi
	elif [ "$parametro" == "-eti" ]; then
		parameETI="true"
		if [ "$parameR" == "true" -o "$parameU" == "true" ]; then
			todoOkey="false"
			echo "NO SE PUEDE PONER -R O -U CON -ETI"
		fi
	elif [ "$parametro" == "-m" ]; then
		parameM="true"
	elif [ "$parametro" == "-b" ]; then
		parameB="true"
	elif [ "$parametro" == "-n" ]; then
		parameN="true"
	else
		if [ "$parametro" != "$primero" ]; then
			comprobarAnterior
		elif [ "$parametro" == "$primero" ]; then
			if [ -d $parametro ]; then
				ubicacion="$parametro"
				tipoUbicacion="carp"
			elif [ -e $parametro ]; then
				ubicacion="$parametro"
				tipoUbicacion="comp"
			else
				echo "error, no toma tipo ubicacion"
				todoOkey="false"
			fi
		else
			echo "errorasoooooooooooooooooooo"
		fi
	fi
}

#		Main...

todoOkey="true"
nombre="$(date +"%F")-Reg.txt"
nombreEtiqueta="$(date +"%F")-Eti.txt"
primero="$1"

for parametro in $*
do
	comprobarParametro
	parametroAnterior="$parametro"
done

if [ "$todoOkey" == "true" -a "$parameV" == "true" -a "$tipoUbicacion" == "comp" ]; then
	echo "$(echo "$(unzip -l $ubicacion)" | grep "Reg.txt.gpg")"
	echo "--- escriba tal cual uno de estos nombres para verlo ---"
	read buscar
	comprobarExiste
elif [ "$todoOkey" == "true" -a "$parameB" == "true" -a "$tipoUbicacion" == "comp" ]; then
	buscarPorEtiqueta
elif [ "$todoOkey" == "true" -a "$parameETI" == "true" ]; then
	mostrarEtiquetasPorFecha
elif [ "$todoOkey" == "true" -a "$parameR" == "true" ]; then
	echo "Ejecutando..."
	if [ "$parameM" == "true" ]; then
		echo "$(echo "$(unzip -l $ubicacion)" | grep "Reg.txt.gpg")"
		echo "--- escriba tal cual uno de estos nombres para verlo ---"
		read buscar
	elif [ "$parameN" == "true" ]; then
		notas
	fi
	comprobarExiste
	escribirArchivo
	encriptado
	guardarEnc
	borradoSeguro
else
	if [ "$parameAyuda" == "false" ]; then
		echo "ERROR, COMPRUEBA LOS PARAMETROS NUEVAMENTE"
	fi
fi


#"Licencia: GNU GENERAL PUBLIC LICENSE Versión 3"
#"Creado por: Emilio Jesus Calderon"
