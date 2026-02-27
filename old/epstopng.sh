#!/bin/bash

# 引数がない場合に使い方を表示
if [ $# -eq 0 ]; then
    echo "Usage: epstopng file1.eps file2.eps ..."
    exit 1
fi

# 渡されたすべての引数に対してループ処理
for arg in "$@"; do
    # 拡張子が .eps かどうかチェック（大文字小文字を区別しない）
    if [[ "$arg" == *.[eE][pP][sS] ]]; then
        filename=$(basename "$arg" .eps)
        filename=$(basename "$filename" .EPS) # 大文字対策

        echo "Processing: $arg"

        # 1. EPSをPDFに変換
        epstopdf "$arg"

        # 2. PDFをPNGに変換 (300dpi)
        pdftoppm "$filename.pdf" -r 300 -png > "$filename.png"

        # 中間ファイルのPDFを削除（不要なら残してもOK）
        # rm "$filename.pdf"
    else
        echo "Skip: $arg (Not an EPS file)"
    fi
done

echo "Done!"
