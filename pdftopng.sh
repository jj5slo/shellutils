#!/bin/bash

# ----------------------------------------
# 1つのPDFファイルを処理する関数
# ----------------------------------------
process_pdf() {
	local pdf_file="$1"
	local auto_mode="$2"

	# 拡張子チェック
	if [[ ! "$pdf_file" == *.[pP][dD][fF] ]]; then
		echo "Skip: $pdf_file (Not a PDF file)"
		return
	fi

	# PDFの存在するディレクトリパスとファイル名を取得
	local dirpath=$(dirname "$pdf_file")
	local filename=$(basename "$pdf_file")
	filename="${filename%.*}"
	
	# 出力プレフィックス（ディレクトリ + ファイル名）
	local output_prefix="${dirpath}/${filename}"

	# 自動モードの場合は更新日時を比較
	if [ "$auto_mode" -eq 1 ]; then
		shopt -s nullglob
		local existing_pngs=("${output_prefix}_"*.png)
		shopt -u nullglob

		# 既に変換済みのPNGが存在し、かつPDFより新しければスキップ
		if [ ${#existing_pngs[@]} -gt 0 ] && [ ! "$pdf_file" -nt "${existing_pngs[0]}" ]; then
			echo "Skip: $pdf_file (PNG is already up-to-date)"
			return
		fi
	fi

	echo "Processing: $pdf_file -> ${output_prefix}_*.png"

	# PDFを複数ページのPNGに変換 (300dpi, 区切り文字を "_" に指定)
	pdftoppm "$pdf_file" -r 300 -png -sep "_" "$output_prefix"
}

# ----------------------------------------
# 引数なし（何も指定されなかった）場合の処理
# ----------------------------------------
if [ $# -eq 0 ]; then
	shopt -s nullglob
	pdf_files=(*.[pP][dD][fF])
	shopt -u nullglob

	# PDFファイルが存在しない場合
	if [ ${#pdf_files[@]} -eq 0 ]; then
		echo "No PDF files found in the current directory."
		exit 1
	fi
	
	echo "Auto-detecting all PDF files..."
	for pdf in "${pdf_files[@]}"; do
		process_pdf "$pdf" 1  # AUTO_MODE=1 として実行
	done
	
	echo "Done!"
	exit 0
fi

# ----------------------------------------
# 引数がある場合の処理（ディレクトリ、または個別ファイル）
# ----------------------------------------
for arg in "$@"; do
	# 1. 引数がディレクトリの場合
	if [ -d "$arg" ]; then
		shopt -s nullglob
		# 指定ディレクトリ直下のPDFを取得
		dir_pdfs=("$arg"/*.[pP][dD][fF])
		shopt -u nullglob

		if [ ${#dir_pdfs[@]} -eq 0 ]; then
			echo "No PDF files found in directory: $arg"
			continue
		fi

		echo "Directory detected: $arg (Found ${#dir_pdfs[@]} PDF files)"
		for pdf in "${dir_pdfs[@]}"; do
			# ディレクトリの一括処理は自動モード扱い（スキップ判定を有効に）する
			process_pdf "$pdf" 1
		done

	# 2. 引数がファイルの場合
	elif [ -f "$arg" ]; then
		# 個別にファイル指定された場合は強制上書き（AUTO_MODE=0）として処理する
		process_pdf "$arg" 0
		
	# 3. 存在しない、または無効なパスの場合
	else
		echo "Skip: $arg (Not found or not a valid file/directory)"
	fi
done

echo "Done!"
