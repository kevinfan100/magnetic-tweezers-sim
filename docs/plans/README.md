# Magnetic Tweezers Workflows 索引

本資料夾收錄**跨設計、跨 pole 配置**的計畫 SOP。每個 workflow 對應一個 `.claude/rules/workflow-<代號>.md` 觸發規則。

**適用範圍**：

- **Hexapole**（6 極，例如 `hung/`、`hexapole-long2016/`）
- **Quadrupole**（4 極，未來新增）
- 未來其他 pole 配置的設計

workflow SOP 以**參數化**方式撰寫，`pole_config` 變數區分不同 pole 配置，個別計畫再依需要加專屬參數。

## 目前計畫狀態

| # | 代號 | 用途 | 觸發片語 | SOP | Rule |
|---|------|------|---------|-----|------|
| 1 | `plan1` | **TBD** | TBD | [workflow-plan1.md](workflow-plan1.md) | [../../.claude/rules/workflow-plan1.md](../../.claude/rules/workflow-plan1.md) |
| 2 | `plan2` | **TBD** | TBD | [workflow-plan2.md](workflow-plan2.md) | [../../.claude/rules/workflow-plan2.md](../../.claude/rules/workflow-plan2.md) |
| 3 | `plan3` | **TBD** | TBD | [workflow-plan3.md](workflow-plan3.md) | [../../.claude/rules/workflow-plan3.md](../../.claude/rules/workflow-plan3.md) |

**策略**：使用者決定**一次做一個計畫**，三個 placeholder 依序填內容。每填完一個就 rename 為正式代號、更新本表與 `CLAUDE.md` Quick Triggers。

## 我該選哪一個（決策樹）

三項計畫內容尚未定義，本節等各計畫填內容後補上：

- 想做 X（情境描述）→ 計畫 `<代號>`
- 想做 Y（情境描述）→ 計畫 `<代號>`
- 想做 Z（情境描述）→ 計畫 `<代號>`

## 共用 Pre-flight 檢查（所有 workflow 都必做）

任何 workflow 在進入自己的 Step 1 之前，都必須完成這些檢查。這是單一真相來源，個別 workflow **不重複**這些內容，只在前置條件「指向這裡」。

### 1. Pole 配置規範

依 `pole_config` 讀對應 simulation reference：

- `hexapole` → `docs/hexapole-simulation-reference.md`（α=54.74° 不可改、3 pair 正交、60° 方位偏移）
- `quadrupole` → `docs/quadrupole-simulation-reference.md`（未來建立）

### 2. 設計專屬文件

- 讀 `{design_root}/docs/troubleshooting.md`（若存在）
- 讀對應 path-scoped rule（例如 `.claude/rules/hung-docs.md`）

### 3. Geom / sim 腳本參數一致性（**必查**）

同一設計的 `{design_root}/apdl/geom/` 與 `{design_root}/apdl/sim/` 腳本可能因歷史修改而發散。**任何變體研究前必須先驗證以下關鍵參數在 geom 與 sim 腳本中的值相同**：

| 參數類別 | 檢查項目 |
|---------|---------|
| Pole 幾何 | `POLE_R`、`POLE_CONE_LEN`、`POLE_TOTAL_LEN`、`POLE_FLAT_LEN` |
| Fillet | `POLE_TIP_R` |
| 傾斜角 | `TILT_UP`、`TILT_DN`（或等效的 quadrupole 參數） |
| 球面半徑 | `R_sphere` / `R_norm`（= `l`） |
| Block / Yoke / Coil | `BLK_T`、`YOKE_RI`、`YOKE_RO`、`YOKE_T`、`COIL_H`、`TURNS` 等 |

**檢查指令範例**（Hung 案例）：

```bash
grep -n "POLE_TIP_R\s*=" hung/apdl/geom/*.txt hung/apdl/sim/*.txt
```

**發現漂移**時：
- **不得自行選擇**哪個值正確
- 向使用者報告 geom vs sim 的差異，問該統一到哪個值（通常統一到 baseline FEM 結果使用的 sim 腳本值）
- 統一後才進入該 workflow 的 Step 1

**為什麼重要**：IGES 可視版本來自 geom 腳本，FEM 實際求解用的是 sim 腳本。兩者參數不一致 → 使用者看的幾何跟 FEM 算的幾何**不是同一個東西**，任何 B 場比較都失去意義。此坑歷史上踩過（Hung Dfillet：geom 20 µm / sim 40 µm fillet）。

### 4. ANSYS 可用性

- 確認 MAPDL.exe 路徑存在（見 `CLAUDE.md` Commands 區塊；本機在 `G:\ANSYS Inc\v252\ansys\bin\winx64\MAPDL.exe`）
- 若不可用，Claude 準備可複製貼上的指令，使用者外部執行

### 5. 目錄存在性

- `{design_root}/IGES/` 與 `{design_root}/IGES_converted/` 必須存在（IGES 產出目標）
- `{design_root}/results/` 若不存在則建立

---

## 跨設計、跨 pole 配置使用方式

所有 workflow 都以**參數化輸入**撰寫，下列變數由使用者在執行時提供：

| 變數 | 說明 | 範例 |
|------|------|------|
| `pole_config` | Pole 配置類型 | `hexapole`、`quadrupole` |
| `n_poles` | 極數 | `6`（hexapole）、`4`（quadrupole） |
| `design_root` | 設計根目錄 | `hung/`、`hexapole-long2016/`、未來 `quadrupole-<name>/` |
| `geom_script` | 幾何腳本路徑 | `{design_root}/apdl/geom/MT_Hung_Assembly_Dfillet.txt` |
| `variant_tag` | 幾何變體短標籤 | `Dfillet`、`RoundFillet` |
| `results_dir` | 結果資料夾 | `{design_root}/results/{variant_tag}/` |

個別 workflow 會再加上計畫專屬的輸入參數。

**Pole 配置專屬規範**：

- **Hexapole** 必讀 `docs/hexapole-simulation-reference.md`（強制約束：α=54.74°、3 pair 正交、60° 方位偏移）
- **Quadrupole** 必讀 `docs/quadrupole-simulation-reference.md`（未來建立）
- workflow SOP 本身**不重複**這些約束，只在 `前置條件` 欄位要求使用者確認

## 載入機制（Claude 怎麼找到這些 workflow）

使用者不必記關鍵字。Claude 靠四層機制找到正確 workflow：

1. **總索引**（本檔）— 使用者/Claude 打開就看到全部計畫
2. **多同義觸發詞** — `CLAUDE.md` Quick Triggers 列多個觸發片語 + 「類似意思」做意圖匹配
3. **迷路求救** — 使用者說「列出計畫」/「help」/「我可以做什麼」→ Claude 讀本索引
4. **主動意圖匹配** — 使用者用自然語言描述需求時，Claude 主動建議匹配的 workflow

## 新增計畫

1. 複製 `_template-workflow.md` → `workflow-<代號>.md`，填 SOP 內容
2. 複製 `../../.claude/rules/_template-rule.md` → `../../.claude/rules/workflow-<代號>.md`，填觸發條件
3. 在本 README 的「目前計畫狀態」表新增一列
4. 在 `CLAUDE.md` Quick Triggers 新增一條觸發
5. 測試 discoverability（新 conversation 說觸發詞 + 迷路詞 + 自然語言描述都能正確路由）

## 我完全不知道要做什麼

直接說「**列出計畫**」或「**help**」，Claude 會把本索引摘要給你。
