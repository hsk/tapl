## TAPL ソースリーディング

TAPLのソースを理解するためにソースを書き換えたり名前を変えたりコメントを書いています。

Typechecker Implementations of Types and Programming Languages
http://www.cis.upenn.edu/~bcpierce/tapl/

- 3 arith 型無し算術式
- 4 arith
- 5 fulluntyped 型無しλフルセット
- 6 fulluntyped
- 7 untyped, fulluntyped 型無しλ

- 8 tyarith 型付き算術式
- 9 fullsimple 型付きλフルセット
- 10 simplebool 型付きboolのみ

- 13 fullref 型付き参照ありフルセット
- 14 fullerror 型付きエラーありフルセット
- 15 fullsub 型付き部分型付けありフルセット
- 16 bot 下限型あり型付き計算

- 20 fullequirec 再帰型フルセット
- 20 fullisorec 再帰型をfold,unfoldするフルセット
- 21 equirec 再帰型

- 22 recon, fullrecon 単相型推論、単相型推論フルセット

- 23 fullpoly fullomega 多相型フルセット、多相型ωフルセット
- 24 fullpoly 

- 26 fullfomsub fullfsub
- 27 fullfomsubref
- 29 fullomega
- 30 fullomega
- 31 fullomsub fullfsub
- 32 fullupdate

arith, untyped, fulluntyped 型なし３兄弟
tyarith, simplebool, fullsimple型あり３兄弟


| name          | bool | nat | float | string | record | lambda | let  | fix | type | as type | variant | ref | unify | kindof |
| -----------  =| ---- | --- | ----  | ----   | ----   | ----   | ---- | --- | ---- | ------- | ------- | --- | ----- | ------ |
| arith        =| o    | o   | -     | -      | -      | -      | -    | -   | -    | -       | -       | -   | -     | -      |
| untyped      =| -    | -   | -     | -      | -      | o      | -    | -   | -    | -       | -       | -   | -     | -      |
| fulluntyped  =| o    | o   | o     | o      | o      | o      | o    | -   | o    | -       | -       | -   | -     | -      |
| tyarith      =| o    | o   | -     | -      | -      | -      | -    | -   | o    | -       | -       | -   | -     | -      |
| simplebool   =| o    | -   | -     | -      | -      | o      | -    | -   | o    | -       | -       | -   | -     | -      |
| fullsimple   =| o    | o   | o     | ?      | o      | o      | o    | -   | o    | o       | o       | -   | -     | -      |
| fullref      =| o    | o   | ?     | ?      | ?      | o      | -    | -   | o    | o       | o       | o   | -     | -      |
| fullequirec  =| o    | o   | ?     | ?      | ?      | o      | -    | -   | o    | o       | o       | ?   | -     | -      |
| fullisorec   =| o    | o   | ?     | ?      | ?      | o      | -    | -   | o    | o       | o       | ?   | -     | -      |
| recon        =| ?    | ?   | ?     | ?      | ?      | ?      | ?    | ?   | ?    | ?       | ?       | ?   | o     | -      |
| fullrecon    =| ?    | ?   | ?     | ?      | ?      | ?      | ?    | ?   | ?    | ?       | ?       | ?   | o     | -      |
| fullfsubref  =| o    | o   | ?     | ?      | ?      | o      | -    | -   | o    | o       | o       | o   | -     | -      |
| fullfomsubref=| o    | o   | ?     | ?      | ?      | o      | -    | -   | o    | o       | o       | o   | -     | o      |
| fomega       =| ?    | ?   | ?     | ?      | ?      | ?      | ?    | ?   | ?    | ?       | ?       | ?   | ?     | o      |
| fullomega    =| ?    | ?   | ?     | ?      | ?      | ?      | ?    | ?   | ?    | ?       | ?       | ?   | ?     | o      |
| fomsub       =| ?    | ?   | ?     | ?      | ?      | ?      | ?    | ?   | ?    | ?       | ?       | ?   | ?     | o      |
| fullfomsub   =| ?    | ?   | ?     | ?      | ?      | ?      | ?    | ?   | ?    | ?       | ?       | ?   | ?     | o      |
| fullupdate   =| ?    | ?   | ?     | ?      | ?      | ?      | ?    | ?   | ?    | ?       | ?       | ?   | ?     | o      |

