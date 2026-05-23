#!/bin/bash

# 引数が0個（何も指定されなかった）場合の処理
if [ $# -eq 0 ]; then
    # nullglobを有効化 (該当ファイルがない場合に "*.svg" という文字になるのを防ぐ)
    shopt -s nullglob
    # カレントディレクトリの .svg / .SVG をすべて「引数」としてセットし直す
    set -- *.[sS][vV][gG]
    shopt -u nullglob

    # セットし直した結果、それでも引数が0個なら（SVGファイルが存在しない場合）
    if [ $# -eq 0 ]; then
        echo "No SVG files found in the current directory."
        exit 1
    fi
    echo "Auto-detecting all SVG files..."
fi

for arg in "$@"; do
    # 拡張子が大文字小文字問わずSVGであるか判定
    if [[ "$arg" == *.[sS][vV][gG] ]]; then
        # 拡張子を取り除いたファイル名を取得
        filename=$(basename "$arg")
        filename="${filename%.*}"

        echo "Processing: $arg"

        # 1. SVGをPDFに変換 (Inkscape v1.0以降を使用)
        inkscape "$arg" --export-filename="$filename.pdf"
        
        # ※ Inkscapeがない環境で rsvg-convert (librsvg) を使う場合はこちら:
        # rsvg-convert -f pdf -o "$filename.pdf" "$arg"

        # 2. PDFをPNGに変換 (前回と同様 pdftoppm を使用、300dpi)
        pdftoppm "$filename.pdf" -r 300 -png > "$filename.png"

        # 中間ファイルのPDFを削除したい場合はコメントアウトを外す
        # rm "$filename.pdf"
    else
        echo "Skip: $arg (Not an SVG file)"
    fi
done

echo "Done!"
