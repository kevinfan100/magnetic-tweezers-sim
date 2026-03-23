# Single-Pole APDL Tutorial — 學習筆記

本文件隨教學進度更新，記錄每個 Step 學到的 APDL 指令與概念。

---

## Step 1：環境設定 + Yoke 圓環

### 學習目標
- APDL 腳本的標準開頭結構
- `/PREP7` 前處理器
- `CYL4` 建立圓柱/圓環
- `VPLOT`、`/VIEW` 驗證幾何

---

### 腳本結構

APDL 腳本的標準開頭順序：

```
FINISH              ! 離開目前處理器
/CLEAR,NOSTART      ! 清除所有模型資料，從零開始
/TITLE, ...         ! 設定標題（顯示在圖形視窗上方）
/FILNAME, ...       ! 設定輸出檔案前綴
/PREP7              ! 進入前處理器（建模、網格、材料都在這裡）
```

### 全域設定指令

| 指令 | 功能 |
|------|------|
| `*afun, DEG` | 讓 sin/cos 等三角函數使用「角度」而非「弧度」 |
| `BTOL, 1e-6` | 布林運算（切割、合併）的容差 |
| `/UNITS, MKS` | 使用國際單位制（公尺、公斤、秒、安培） |

---

### CYL4 — 建立圓柱 / 圓環

```
CYL4, XCENTER, YCENTER, RAD1, THETA1, RAD2, THETA2, DEPTH
```

| 參數 | 意義 | Step 1 的值 |
|------|------|------------|
| `XCENTER` | 圓心 X 座標 | `0` |
| `YCENTER` | 圓心 Y 座標 | `0` |
| `RAD1` | 內半徑（0 = 實心） | `YOKE_IN_R` (42mm) |
| `THETA1` | 起始角度 | `0` |
| `RAD2` | 外半徑 | `YOKE_OUT_R` (53mm) |
| `THETA2` | 終止角度（360 = 完整圓） | `360` |
| `DEPTH` | Z 方向的高度 | `YOKE_H` (2mm) |

**俯視圖（XY 平面）：**
```
          ╱ ─ ╲
        ╱ RAD2  ╲
       │ ╱ ─ ╲  │
       │ RAD1  │ │    RAD1~RAD2 之間才有實體
       │ ╲   ╱  │    RAD1=0 → 實心圓柱
        ╲       ╱    THETA1~THETA2 控制扇形範圍
          ╲ ─ ╱
```

**側面圖（DEPTH 方向）：**
```
    Z
    ↑
    │  ┌────┐ ─┬─ DEPTH
    │  └────┘ ─┘
    └──────→ R
      RAD1  RAD2
```

**座標原點位置：** 圓環的中心底面。底面在 Z=0，頂面在 Z=DEPTH。

```
    Z
    ↑
    │  ┌────────┐  Z = 2mm（頂面）
    │  │  yoke  │
    ●──┴────────┘→ R     ● = 原點 (0,0,0)（底面中心）
   Z=0
```

---

### VPLOT — 顯示體積

`VPLOT` = **Volume Plot**，顯示目前模型中所有的 Volume。

APDL 幾何有 4 個層級，各有對應的 Plot 指令：

```
Keypoint (點)  →  Line (線)  →  Area (面)  →  Volume (體)
   KPLOT          LPLOT          APLOT          VPLOT
```

後續會用到的其他 Plot 指令：
- `EPLOT` — 顯示網格元素（Element）
- `NPLOT` — 顯示節點（Node）
- `PLNSOL,B,SUM` — 顯示磁場分布（求解後）

---

### /VIEW — 設定視角方向

```
/VIEW, WN, XV, YV, ZV
```

| 參數 | 意義 |
|------|------|
| `WN` | 視窗編號（通常 `1`） |
| `XV, YV, ZV` | 眼睛看向原點的方向向量 |

把 `(XV, YV, ZV)` 想成「你站在哪個方向看向原點」：

| 指令 | 方向向量 | 視角 | 看到什麼 |
|------|---------|------|---------|
| `/VIEW,1,0,0,1` | (0,0,1) | 從 Z 上方往下看 | 俯視圖（XY 平面） |
| `/VIEW,1,0,-1,0` | (0,-1,0) | 從 -Y 前方往前看 | 正面圖（XZ 平面） |
| `/VIEW,1,1,1,1` | (1,1,1) | 從斜上方 45° 看 | 3D 等角視圖 |

```
        Z
        ↑   ↙ (1,1,1) 等角視圖
        │
        │  ┌──┐
        │  │  │ ← yoke
   ─────┼──┴──┴──→ X
       ╱
      Y
```

**注意：** `/VIEW` 只改視角，不會重新畫圖。改完要再下 `VPLOT`（或 `/REPLOT`）才會更新畫面。

---

### 其他實用指令

| 指令 | 功能 |
|------|------|
| `/AUTO,1` | 自動縮放，將模型填滿畫面 |
| `/REPLOT` | 重新繪製目前的圖（不改內容，只刷新） |
| `/CLEAR,NOSTART` | 清除所有資料，重新開始（出錯時用） |

---

### MAPDL GUI 操作

**滑鼠控制（Graphics Window）：**
- 滾輪：縮放
- 中鍵拖曳：旋轉模型
- Ctrl + 中鍵拖曳：平移
- 右鍵：功能選單

**重新執行腳本的流程：**
1. 修改 `single_pole.txt` 並存檔
2. 在 MAPDL 指令列輸入 `/CLEAR,NOSTART`
3. 重新輸入 `/INPUT,'...single_pole','txt'`

---

### Step 1 參數總結

| 參數 | 值 | 說明 |
|------|-----|------|
| `YOKE_IN_R` | 42 mm | Yoke 內半徑 |
| `YOKE_OUT_R` | 53 mm | Yoke 外半徑 |
| `YOKE_H` | 2 mm | Yoke 厚度 |

建出的圓環：圓心在原點，底面 Z=0，頂面 Z=2mm，壁厚 11mm。

### Step 1 驗證結果 ✓ 通過

**VLIST,ALL：** 確認只有 1 個 Volume，由 6 個 Area 組成。

**VSUM：** TOTAL VOLUME = 6.566 × 10⁻⁶ m³
- 手算：pi × (0.053² - 0.042²) × 0.002 = 6.567 × 10⁻⁶ m³ ✓
- CENTER OF MASS: ZC = 0.001m（圓環正中間）✓

---

## Step 2：Protrusion + VADD

### 學習目標
- `WPOFFS` 工作平面偏移
- `CYL4` 用負 DEPTH 向下建
- `VADD` 合併 Volume
- `WPLANE` / `WPcsys` 重設工作平面

---

### 新概念：CYL4 的 DEPTH 可以是負數

```
CYL4, X, Y, R, , , , DEPTH
                      ↑
            正 = 往 +Z 長
            負 = 往 -Z 長
```

```
側面圖：
      Z=2mm  ┌──────────────┐  yoke 頂面
      Z=0    ├──────────────┤  yoke 底面
             │  protrusion  │  ← DEPTH = -7mm
      Z=-7mm └──────────────┘    從 Z=0 往下長到 Z=-7mm
```

---

### 新概念：WPLANE / WPcsys — 重設工作平面

建新幾何之前，先重設工作平面到已知位置，避免累積偏移：

```
WPLANE, 1, 0,0,0, , , , , ,    ! WP 移到原點
WPcsys, -1, 0                  ! WP 對齊全域座標系
```

這兩行像是「回到原點、面朝北」，是建模前的標準起手式。

---

### 新概念：VADD — 合併 Volume

```
VADD, ALL        ! 合併所有 Volume 為一個
VADD, 1, 2       ! 只合併 Volume 1 和 2
```

合併後原本的 Volume 會被刪除，產生一個新的 Volume（編號會變）。

---

### 新概念：WPOFFS — 移動工作平面

```
WPOFFS, dX, dY, dZ    ! 把工作平面沿 X/Y/Z 偏移
```

例如 `WPOFFS, 0, 0, 0.002` 把工作平面往 Z 上移 2mm。
之後用 `CYL4` 建的東西就會從 Z=2mm 開始。

完整模型中，上方的 protrusion 就是這樣建的：
1. `WPOFFS, 0, 0, YOKE_H` — 工作平面移到 yoke 頂面
2. `CYL4, ..., PROT_H` — 正 DEPTH 往上長

---

### 新概念：VGEN — 移動已存在的 Volume

如果幾何已經建好，想整體平移：

```
VGEN, , NV1, , , DX, DY, DZ, , , 1
                               └─ 1=移動, 0=複製
```

例如把 Volume 1 往 Z 移 5mm：
```
VGEN, , 1, , , , , 5e-3, , , 1
```

---

### Step 2 參數總結

| 參數 | 值 | 說明 |
|------|-----|------|
| `YOKE_MID_R` | 47.5 mm | Yoke 壁厚中心半徑 = protrusion 中心位置 |
| `PROT_R` | 5 mm | Protrusion 半徑 |
| `PROT_H` | 7 mm | Protrusion 高度 |

### Step 2 驗證方法

1. `VLIST,ALL` → 應該只有 **1 個 Volume**（VADD 後合併了）
2. `VSUM` → 體積應該 = yoke + protrusion
   - Yoke: 6.566e-6 m³
   - Protrusion: pi × 0.005² × 0.007 = 5.50e-7 m³
   - 合計: 約 **7.12e-6 m³**
3. `/VIEW,1,0,-1,0` → `VPLOT` → 正面圖應該看到 yoke 下方掛著一個圓柱

---

## APDL 指令分類速查表

### 指令命名規則
| 前綴/模式 | 意義 | 例子 |
|-----------|------|------|
| `/` 開頭 | 顯示、環境控制 | `/VIEW`, `/PREP7`, `/TITLE` |
| `*` 開頭 | 流程控制、變數 | `*DO`, `*IF`, `*GET`, `*DIM` |
| `V` 開頭 | Volume 相關 | `VPLOT`, `VLIST`, `VSUM`, `VSEL`, `VMESH`, `VADD` |
| `A` 開頭 | Area 相關 | `APLOT`, `ALIST`, `ASEL` |
| `K` 開頭 | Keypoint 相關 | `KPLOT`, `KLIST` |
| `N` 開頭 | Node 相關 | `NPLOT`, `NLIST`, `NSEL` |
| `E` 開頭 | Element 相關 | `EPLOT`, `ELIST`, `ESEL` |
| `PL` 開頭 | 畫圖（Plot） | `PLNSOL`, `PLVECT` |
| `PR` 開頭 | 印數值（Print） | `PRNSOL` |

### 1. 環境控制（腳本開頭用）
| 指令 | 功能 |
|------|------|
| `FINISH` | 離開目前處理器 |
| `/CLEAR,NOSTART` | 清除所有模型資料 |
| `/TITLE` | 設定標題 |
| `/FILNAME` | 設定輸出檔案前綴 |
| `/UNITS, MKS` | 使用國際單位制 |
| `*afun, DEG` | 三角函數用角度 |
| `BTOL` | 布林運算容差 |

### 2. 三大處理器
| 指令 | 階段 | 做什麼 |
|------|------|--------|
| `/PREP7` | 前處理 | 建幾何、設材料、切網格 |
| `/SOLU` | 求解 | 設邊界條件、計算 |
| `/POST1` | 後處理 | 看結果、畫圖、輸出數值 |

### 3. 建立幾何（/PREP7）

**幾何原件（直接建 Volume）：**
| 指令 | 建出什麼 |
|------|---------|
| `CYL4` | 圓柱 / 圓環 |
| `BLOCK` | 長方體 |
| `SPHERE` | 球體 |

**點→線→面→體（手動建構）：**
| 指令 | 功能 |
|------|------|
| `K` | 建立 Keypoint（點） |
| `L` | 兩點連直線 |
| `LARC` | 兩點+圓心建弧線 |
| `AL` | 用多條線圍成面 |
| `VROTAT` | 面繞軸旋轉成體 |

**布林運算：**
| 指令 | 功能 | 比喻 |
|------|------|------|
| `VADD` | 合併多個 Volume | 黏在一起 |
| `VSBV` | A 減去 B | 用模具切麵團 |
| `VOVLAP` | 重疊，保留交集 | 找重疊部分 |
| `VGLUE` | 黏合，共享接觸面 | 貼在一起 |

**工作平面：**
| 指令 | 功能 |
|------|------|
| `WPLANE` | 重設工作平面位置 |
| `WPcsys` | 工作平面對齊座標系 |
| `WPOFFS` | 工作平面偏移 |
| `WPROTA` | 工作平面旋轉 |

### 4. 材料 & 元素（/PREP7）
| 指令 | 功能 |
|------|------|
| `MP, MURX, N, val` | 材料 N 的相對磁導率 |
| `ET, N, SOLID96` | 元素類型 N = 3D 磁場元素 |
| `R` | 定義 Real Constants（線圈參數） |
| `VATT` | 材料+元素指派給 Volume |

### 5. 網格（/PREP7）
| 指令 | 功能 |
|------|------|
| `SMRT, N` | SmartSize 等級（1 最細，10 最粗） |
| `MSHAPE, 1, 3D` | 四面體形狀 |
| `MSHKEY, 0` | 自由網格 |
| `VMESH, ALL` | 對所有 Volume 切網格 |

### 6. 選取操作（任何階段）
| 指令 | 功能 |
|------|------|
| `VSEL, S/A/U, VOLU,, N` | 選取 Volume |
| `ASEL` | 選取 Area |
| `NSEL` | 選取 Node |
| `ESEL` | 選取 Element |
| `ALLSEL, ALL` | **全選（記得恢復！）** |

S = 重新選、A = 追加、U = 移除

### 7. 邊界條件 & 求解（/SOLU）
| 指令 | 功能 |
|------|------|
| `D, ALL, MAG, 0` | 選取的節點磁位 = 0 |
| `LOCAL` | 定義局部座標系 |
| `CSYS` | 切換座標系 |
| `MAGSOLV, 3` | DSP 磁場求解 |

### 8. 後處理（/POST1）
| 指令 | 功能 | 輸出位置 |
|------|------|---------|
| `PLNSOL, B, SUM` | 磁場分布彩色圖 | Graphics Window |
| `PLVECT, B` | 磁場向量箭頭 | Graphics Window |
| `PRNSOL, B` | 列出每個節點磁場數值 | Command Window |

### 9. 顯示控制
| 指令 | 功能 |
|------|------|
| `VPLOT` / `APLOT` / `EPLOT` | 畫 Volume / Area / Element |
| `/VIEW, 1, x, y, z` | 設定視角 |
| `/AUTO, 1` | 自動縮放 |
| `/REPLOT` | 重畫 |
| `/COLOR, VOLU, RED, N` | Volume N 設紅色 |
| `/TRLCY, VOLU, 0.5, N` | Volume N 半透明 |
| `/PNUM, VOLU, 1` | 顯示 Volume 編號 |

### 10. 查詢 & 驗證
| 指令 | 功能 | 輸出位置 |
|------|------|---------|
| `VLIST, ALL` | 列出所有 Volume 資訊 | Command Window |
| `VSUM` | 計算體積數值 | Command Window |
| `ALIST, ALL` | 列出所有 Area | Command Window |
| `KLIST, ALL` | 列出所有 Keypoint 座標 | Command Window |

### 11. 流程控制
| 指令 | 功能 |
|------|------|
| `*DO, i, 1, 6, 1` ... `*ENDDO` | 迴圈 |
| `*IF, i, LE, 3, THEN` ... `*ENDIF` | 條件判斷 |
| `*DIM, ARR,, 6` | 定義陣列 |
| `*GET, n, VOLU,, NUM, MAX` | 取得數值存入變數 |
