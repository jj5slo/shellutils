#!/bin/bash

# ファイル名から拡張子を除いた部分を取得
filename=$(basename "$1" .eps)

# 1. EPSをPDFに変換
epstopdf "$1"

# 2. PDFをPNGに変換 (300dpi)
# ※pdftoppmはデフォルトで -1 などの接尾辞がつくため、sed等でリネーム処理を含めています
pdftoppm "$filename.pdf" -r 300 -png > "$filename.png"

# 中間ファイルのPDFを削除したい場合は、下の行のコメントアウト(#)を外してください
# rm "$filename.pdf"

echo "Conversion complete: $filename.png"
