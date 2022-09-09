# Printing Shader
AMスクリーニングを再現して解像度の低さをごまかすシェーダーです（[参考](https://twitter.com/lil_xyzw/status/1567923942278701056)）。`_lil/PrintingUnlit`はライティング非対応、`_lil/PrintingLit`はライティング対応です。他のシェーダーへの組み込みはUnlitの方を参考に以下の手順でできると思います。

- プロパティ、変数をそのままコピー
- `#pragma shader_feature_local _ APPLY_NOISE`を追加
- `#include "Printing.hlsl"`を追加
- Albedoに対して`lilAMScreening()`関数を適用