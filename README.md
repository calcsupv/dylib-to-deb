# Dylib to Deb Converter

**.dylib を .deb に変換する sh スクリプト**

## 機能
- dylib から deb に変換
- Rootless / Rootful 対応
- 日本語

## 引用元（Based on）
- **元スクリプト**: [cs59/Dylib-to-Deb-Converter](https://github.com/cs59/Dylib-to-Deb-Converter)
- 作者: cs59 さん

## ライセンス
- **GPLv3**（元リポから）
- 詳細: [LICENSE](LICENSE)

---

## 使用方法 (iOS)

Filza などのファイルマネージャーで、任意の場所にスクリプトを配置します。  
ターミナルでそのフォルダに移動し、以下を実行：

```bash
chmod +x iDebCreator.sh
sudo ./iDebCreator.sh
```
作成された .deb ファイルは現在のフォルダに出力されます。

**動作確認済み環境**
iPhone 8 / iOS 16.1.1
