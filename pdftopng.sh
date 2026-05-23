#!/bin/bash

# 引数が0個（何も指定されなかった）場合の処理
if [ $# -eq 0 ]; then
    # nullglobを有効化 (該当ファイルがない場合に "*.eps" という文字になるのを防ぐ)
    shopt -s nullglob
    # カレントディレクトリの .eps / .EPS をすべて「引数」としてセットし直す
    set -- *.[pP][dD][fF]
    shopt -u nullglob

    # セットし直した結果、それでも引数が0個なら（EPSファイルが存在しない場合）
    if [ $# -eq 0 ]; then
        echo "No PDF files found in the current directory."
        exit 1
    fi
    echo "Auto-detecting all PDF files..."
fi

# ここから下は前回と同じ（渡された、あるいは自動取得したファイル群を処理）
for arg in "$@"; do
    if [[ "$arg" == *.[pP][dD][fF] ]]; then
        # 拡張子を取り除いたファイル名を取得（.eps と .EPS 両方に対応する書き方）
        filename=$(basename "$arg")
        filename="${filename%.*}"

        echo "Processing: $arg"

#        # 1. EPSをPDFに変換
#        epstopdf "$arg"

        # 2. PDFをPNGに変換 (300dpi)
        pdftoppm "$arg" -r 300 -png > "$filename.png"

        # 中間ファイルのPDFを削除
        # rm "$filename.pdf"
    else
        echo "Skip: $arg (Not an PDF file)"
    fi
done

echo "Done!"
