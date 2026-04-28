# 計畫 <X> Workflow（範本）

> 複製本檔改名為 `workflow-<代號>.md` 後填內容。
> 同步建立一份 `.claude/rules/workflow-<代號>.md`（rule 檔範本在 `.claude/rules/_template-rule.md`）。

## 目的

<一段話描述：本計畫要達成什麼、交付什麼、適用情境>

## 輸入參數

| 參數 | 說明 | 範例值 |
|------|------|--------|
| `pole_config` | Pole 配置類型 | `hexapole` 或 `quadrupole` |
| `n_poles` | 極數 | `6` 或 `4` |
| `design_root` | 設計根目錄 | `hung/` |
| `geom_script` | 幾何腳本路徑 | `{design_root}/apdl/geom/MT_Hung_Assembly_Dfillet.txt` |
| `variant_tag` | 變體標籤 | `Dfillet` |
| `results_dir` | 結果資料夾 | `{design_root}/results/{variant_tag}/` |
| <計畫專屬參數 1> | ... | ... |
| <計畫專屬參數 2> | ... | ... |

## 前置條件

### 共用 Pre-flight（所有 workflow 必做）

**見 [`README.md` → 共用 Pre-flight 檢查](README.md#共用-pre-flight-檢查所有-workflow-都必做)**，內含 5 項必做檢查：

1. Pole 配置規範（依 `pole_config` 讀 hexapole 或 quadrupole simulation-reference）
2. 設計專屬文件（`{design_root}/docs/troubleshooting.md` + path-scoped rule）
3. **Geom / sim 腳本參數一致性**（發現漂移必統一後才繼續）
4. ANSYS 可用性
5. 目錄存在性（IGES/ 與 IGES_converted/）

**共用 pre-flight 全部通過**才進入下方計畫專屬前置。

### 計畫專屬前置

- <計畫 X 獨有的前置條件 1>
- <計畫 X 獨有的前置條件 2>

## 步驟

### Step 1: <名稱>

<說明為何做這步>

```
<指令 / 程式碼 / APDL，使用 {變數} 佔位，不寫死路徑>
```

### Step 2: <名稱>

...

## 驗證 / 交付產物

- [ ] 產物 1 — 路徑樣板：`{results_dir}/...`
- [ ] 產物 2 — ...
- [ ] 可量化驗證點（例如某量 < 某閾值）

## 常見陷阱

- <陷阱 1> → <解法>
- <陷阱 2> → <解法>

## 跨設計 / 跨 pole 配置適用性

勾選實際驗證過的組合：

### Hexapole

- [ ] `hung/` + `Dfillet`
- [ ] `hung/` + `RoundFillet`
- [ ] `hexapole-long2016/`

### Quadrupole

- [ ] （未來 `quadrupole-<name>/` 驗證後勾選）

### 其他

- [ ] （新設計依本 SOP 試跑後更新此表）
