# Workflow: l Sensitivity Study

## 目的

量化「**pole-tip 正交連線長度 l 的變化對 B 場的影響**」。在其他幾何/材料/激勵條件固定下，僅改變 l（= opposing pair tip-to-tip 距離的一半，= R_sphere / R_norm），比較 **工作空間（WP 區域）**的 B 場量值差異。

**核心交付**：**工作空間 |B| vs l 的關係曲線**（多個 l 值 → B 場量值 → 擬合/繪圖）。

適用情境：評估磁鉗縮小/放大設計的磁場變化、確認 force-l 關係、為 point-charge model 提供 l-dependent 數據。

## 輸入參數

| 參數 | 說明 | 範例值 |
|------|------|--------|
| `pole_config` | Pole 配置 | `hexapole` / `quadrupole` |
| `n_poles` | 極數 | `6` / `4` |
| `design_root` | 設計根目錄 | `hung/` |
| `variant_tag` | 幾何變體標籤 | `Dfillet` |
| `baseline_geom_script` | 基底幾何腳本（含原始 l） | `{design_root}/apdl/geom/MT_Hung_Assembly_Dfillet.txt` |
| `baseline_l_um` | 基底 l 值（µm） | `500` |
| `l_values_um` | 要比較的 l 值清單（µm） | `[250, 500]`（至少 2 個） |
| `coils_to_run` | 要激勵的 coil 編號 | `[1]`（最省）或 `[1,2,3,4,5,6]`（完整） |
| `observation_points` | 比較 B 的位置 | 預設：WP center + 6 tip apex |

## 前置條件

### 共用 Pre-flight（所有 workflow 必做）

**見 [`README.md` → 共用 Pre-flight 檢查](README.md#共用-pre-flight-檢查所有-workflow-都必做)**：Pole 配置規範、設計專屬文件、**Geom/sim 參數一致性**、ANSYS 可用性、目錄存在性（IGES/、IGES_converted/）。

### 計畫專屬前置

- 確認基底 l（`baseline_l_um`）的 FEM 結果已存在作為對照（例如 `{design_root}/results/coil1/{variant_tag}/`）；若無，計畫中也要跑一份基底
- **基底幾何參數 = 各 l 變體的幾何參數**（共用 pre-flight 第 3 項延伸）：baseline 用什麼 fillet、pole 尺寸、block、yoke、coil，所有變體也必須用同一組。**只有 `R_sphere`（l 本身）可以變**，其他全鎖定。

## Checkpoint（使用者審查關卡，不可省）

本 workflow 只有**一個**必經人工審查關卡：

| 關卡 | 位置 | 審什麼 | 目的 |
|------|------|--------|------|
| **Checkpoint** | Step 3 之後、Step 5 之前 | IGES 在 SolidWorks 中的幾何 | 確認 l 確實改正、尺寸/球面/正交/pole 形狀無誤 |

Claude **不需要**事先請使用者審 APDL 腳本文字 — 腳本由 Claude 編寫並直接交給 ANSYS 執行；任何問題會在 SolidWorks 的幾何檢查中暴露。

Checkpoint 必須由使用者明確批准後才進下一步。Claude 不可自行假設通過。

## IGES vs IGES_converted 差異（重要）

兩個資料夾**必須同步**。任何一邊更新必須同步更新另一邊。

| 資料夾 | 內容 | Unit flag | 用途 |
|--------|------|----------|------|
| `{design_root}/IGES/` | ANSYS 原始匯出 | `6`（聲稱 mm，但內部數值為英寸，因腳本用 `MM = 1/25.4`） | SolidWorks 開檔會正確顯示 mm（SolidWorks 忽略 flag，當英寸讀再 ×25.4） |
| `{design_root}/IGES_converted/` | unit flag 改為 `1`（實話：是英寸） | `1` | 再匯出成 STEP 或給其他 CAD 軟體時 flag 一致、避免尺寸錯誤 |

轉換一行指令：
```bash
cp {design_root}/IGES/<file>.iges {design_root}/IGES_converted/<file>.iges
sed -i "s/,1.0,6,,/,1.0,1,,/" {design_root}/IGES_converted/<file>.iges
```

## 步驟

### Step 1：建立 l-variant 幾何腳本（每個 `l_values_um` 一份）

對每個 `l_um` in `l_values_um`（若該 l 已有既存腳本與 IGES 則跳過）：

1. 複製基底腳本：
   ```bash
   cp {baseline_geom_script} {design_root}/apdl/geom/{baseline_name}_l{l_um}.txt
   ```
2. 修改新腳本：
   - 頭部註解加 `[MODIFIED for l-sensitivity] l = {l_um} µm`
   - `/CWD` 改為**當前機器**的絕對路徑（指向 `{design_root}/IGES/`）
   - `R_sphere = 0.5*MM` → `R_sphere = {l_um/1000}*MM`（若基底用其他變數名亦比照）
   - `IGESOUT` 與 `SAVE` 的檔名加 `_l{l_um}` 後綴

### Step 1.5（⏸ Checkpoint A）：使用者檢查 APDL 腳本

Claude 呈交下列資料給使用者：

1. **新腳本路徑**：`{design_root}/apdl/geom/{baseline_name}_l{l_um}.txt`
2. **Diff 摘要**（相對基底腳本，應該只有 4 處變更）：
   - 頭部註解（註記 l 變更）
   - `/CWD` 絕對路徑（改為當前機器路徑）
   - `R_sphere` 數值（原 `0.5*MM` → 新 `{l_um/1000}*MM`）
   - `IGESOUT` / `SAVE` 檔名（加 `_l{l_um}` 後綴）
3. **不應該有其他變更**（pole 尺寸、fillet、block、yoke、coil 全部不動）

**使用者明確批准後**才進 Step 2。若有需要調整，回 Step 1 修改腳本再重新進 Checkpoint A。

### Step 2：執行 ANSYS 建模 + 匯出 IGES

**先確認 ANSYS 可執行性**（見上方「ANSYS 執行環境」）。

對每個 l variant：

```bash
"<ANSYS_EXE>" -b -np 4 -m 8000 \
  -dir "{design_root}/results/l{l_um}_build" \
  -j "l{l_um}_build" \
  -i "{design_root}/apdl/geom/{baseline_name}_l{l_um}.txt" \
  -o "{design_root}/results/l{l_um}_build/build.out"
```

`-dir` 只接 ANSYS 臨時檔；IGES/DB 由腳本內 `/CWD` 指定輸出到 `{design_root}/IGES/`。

無 ANSYS 環境時，Claude 把此指令呈給使用者外部執行，並等使用者回報完成後再進 Step 3。

### Step 3：同步 IGES_converted

```bash
cp {design_root}/IGES/Full_Assembly_{variant_tag}_l{l_um}.iges \
   {design_root}/IGES_converted/Full_Assembly_{variant_tag}_l{l_um}.iges

sed -i "s/,1.0,6,,/,1.0,1,,/" \
   {design_root}/IGES_converted/Full_Assembly_{variant_tag}_l{l_um}.iges
```

### Step 4（⏸ Checkpoint B）：使用者驗證幾何（必經）

通知使用者在 SolidWorks 開 `{design_root}/IGES/Full_Assembly_{variant_tag}_l{l_um}.iges`，驗證：

- [ ] 6 個 tip 落在 R = `{l_um/1000}` mm 的球面上
- [ ] Opposing pair tip-to-tip = `{2*l_um/1000}` mm
- [ ] 3 對 pair 方向兩兩正交（hexapole）
- [ ] Pole 形狀、fillet、block、yoke 與基底一致

**經使用者批准後**才能進 Step 5。

### Step 5：建立 sim 腳本 + 跑 FEM

對每個 `l_um` × 每個 `coil_n` in `coils_to_run`：

1. 複製對應基底 sim 腳本：
   ```
   {design_root}/apdl/sim/MT_<...>_Coil{n}_{variant_tag}.txt
   → {design_root}/apdl/sim/MT_<...>_Coil{n}_{variant_tag}_l{l_um}.txt
   ```
2. 修改：
   - `R_sphere`、`/CWD`、`SAVE`、結果檔名比照 Step 1/2
   - 將其內 `CURR_ARRAY` 保持原 sim 腳本設定
3. 執行 FEM：
   ```bash
   "<ANSYS_EXE>" -b -np 4 -m 8000 \
     -dir "{design_root}/results/coil{n}/{variant_tag}_l{l_um}" \
     -j "coil{n}_l{l_um}" \
     -i "{design_root}/apdl/sim/MT_<...>_Coil{n}_{variant_tag}_l{l_um}.txt" \
     -o "{design_root}/results/coil{n}/{variant_tag}_l{l_um}/solve.out"
   ```

### Step 6：匯出 B 場數據

用對應的 `post_export_data_coil{n}.txt` 匯出 WP 區域 + 全域 `.dat`，結果路徑：

```
{design_root}/results/coil{n}/{variant_tag}_l{l_um}/coil{n}_{coord,bfield}_{all,wp}.dat
```

### Step 7：萃取工作空間 B 值

用 `post_extract_wp.txt` 或 MATLAB 讀 `.dat`，對每個 l 值萃取下列「工作空間 B 代表量」：

| 代表量 | 意義 | 預設 |
|--------|------|------|
| `B_wp_center` | WP 中心點 (0,0,0) 的 \|B\| | ✓ 必做 |
| `B_wp_mean` | WP 附近 ±50 µm cube 內所有節點的 \|B\| 平均 | 可選 |
| `B_wp_max` | 同區域 \|B\| 最大值 | 可選 |
| `B_tip_apex[1..n]` | 各 pole tip apex 表面 \|B\| | 可選（參考用） |

使用者可指定要哪幾個代表量；至少要 `B_wp_center`。

### Step 8：彙整 B vs l 表 + 關係曲線

**核心交付**：B（工作空間）vs l 的關係。

1. 數值表 `{design_root}/data/l_sensitivity_{variant_tag}.csv`（或 `.mat`）：

   | 欄 | 說明 |
   |----|------|
   | `l_um` | 本次 l 值 |
   | `coil_n` | 激勵 coil 編號 |
   | `B_wp_center_mT` | WP 中心 \|B\| |
   | `B_wp_mean_mT` | WP 區域平均 \|B\|（若萃取） |
   | `B_tip_<P>_mT` | 各 pole tip \|B\|（若萃取） |

2. 關係曲線 `{design_root}/figures/analytic/l_sensitivity_{variant_tag}.png`：

   - **X 軸**：l (µm)
   - **Y 軸**：|B| at 工作空間 (mT)
   - **每條線**：不同代表量（WP center / mean / max）
   - 可選：加上解析預測線（例如 `|B| ∝ 1/l²` 或 point-charge 模型）作對照

3. **物理解讀簡評**（寫在 MATLAB 腳本註解或一份 `.md` 報告）：
   - l 減半 → |B| 變化幾倍？
   - 與 1/l² 或其他預期 scaling 吻合度？
   - 實務意義（例如對縮小版磁鉗力量的推估）

**產圖前先與使用者討論內容與樣式**（依 `CLAUDE.md` 的 Figure Production 規則），不自行出圖。

## 驗證 / 交付產物

- [ ] `{design_root}/apdl/geom/{baseline_name}_l{l_um}.txt`（每個 l 一份）
- [ ] `{design_root}/IGES/Full_Assembly_{variant_tag}_l{l_um}.iges`
- [ ] `{design_root}/IGES_converted/Full_Assembly_{variant_tag}_l{l_um}.iges`（unit flag=1）
- [ ] 使用者 SolidWorks 驗證通過（Step 4）
- [ ] `{design_root}/results/coil{n}/{variant_tag}_l{l_um}/` 下完整 FEM 結果
- [ ] `.dat` 匯出完整
- [ ] 數值表 + 比較圖

## 常見陷阱

- **`/CWD` 使用者名稱寫死** → 基底腳本常有前人寫死的絕對路徑，複製後必改為當前機器路徑
- **只更新 IGES/ 忘了 IGES_converted/** → 兩邊必須同步（`.claude/rules/hung-docs.md` 有強制規則）
- **R_sphere 只是 hexapole 的 l；quadrupole 可能叫別的變數** → 要看設計的 geom 腳本實際變數名
- **減半 l 不會自動減半 tip fillet / pole 長度** → 本 workflow **只改 l**，pole 尺寸、fillet、block、yoke 全保持不變（這正是研究目標：隔離 l 的影響）
- **基底 l 的 FEM 結果若不存在，記得也要跑一份對照**
- **Sim 腳本內部若也有 `R_sphere` 宣告（非 include geom 腳本）**，sim 腳本也要同步改（詳見 `{design_root}/apdl/sim/` 實際內容）

## 跨設計 / 跨 pole 配置適用性

勾選實際驗證過的組合：

### Hexapole

- [ ] `hung/` + `Dfillet`（進行中：l = 500 → 250 µm）
- [ ] `hung/` + `RoundFillet`
- [ ] `hexapole-long2016/`

### Quadrupole

- [ ] （未來 `quadrupole-<name>/` 驗證後勾選）

### 其他

- [ ] （新設計依本 SOP 試跑後更新此表）
