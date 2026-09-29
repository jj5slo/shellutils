#!/bin/bash

# 引数なしで実行されたかどうかの判定用フラグ
AUTO_MODE=0

# 引数が0個（何も指定されなかった）場合の処理
if [ $# -eq 0 ]; then
    AUTO_MODE=1
    # nullglobを有効化 (該当ファイルがない場合に "*.pdf" という文字になるのを防ぐ)
    shopt -s nullglob
    # カレントディレクトリの .pdf / .PDF をすべて「引数」としてセットし直す
    set -- *.[pP][dD][fF]
    shopt -u nullglob

    # セットし直した結果、それでも引数が0個なら（PDFファイルが存在しない場合）
    if [ $# -eq 0 ]; then
        echo "No PDF files found in the current directory."
        exit 1
    fi
    echo "Auto-detecting all PDF files..."
fi

# ここから下は渡された、あるいは自動取得したファイル群を処理
for arg in "$@"; do
    if [[ "$arg" == *.[pP][dD][fF] ]]; then
        # 拡張子を取り除いたファイル名を取得（.pdf と .PDF 両方に対応する書き方）
        filename=$(basename "$arg")
        filename="${filename%.*}"
        png_file="${filename}.png"

        # 引数なし（自動モード）で実行された場合のみ更新日時を比較
        if [ "$AUTO_MODE" -eq 1 ]; then
            # PNGファイルが既に存在し、かつPDFファイルがPNGファイルより新しくない場合はスキップ
            if [ -f "$png_file" ] && [ ! "$arg" -nt "$png_file" ]; then
                echo "Skip: $arg (PNG is already up-to-date)"
                continue
            fi
        fi

        echo "Processing: $arg"

        # PDFをPNGに変換 (300dpi)
        pdftoppm "$arg" -r 300 -png > "$png_file"

    else
        echo "Skip: $arg (Not a PDF file)"
    fi
done

echo "Done!"
