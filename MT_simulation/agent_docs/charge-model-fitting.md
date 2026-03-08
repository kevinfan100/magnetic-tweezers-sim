# Point-Charge Model Fitting: 完整數學推導與實現記錄

> 來源：Long 2016 dissertation Section 2.2.3, Eq. 2.1-2.4
> 實現：`analysis/fit_charge_model.m`, `analysis/point_charge_model.m`
> 最後更新：2026-03-08

---

## 目錄

1. [目標：我們在做什麼](#1-目標)
2. [物理背景：為什麼可以用點電荷](#2-物理背景)
3. [數學模型：Eq 2.1-2.4 完整推導](#3-數學模型)
4. [擬合策略：如何求解 ell 和 R_a](#4-擬合策略)
5. [符號約定：我們 vs 論文](#5-符號約定)
6. [程式碼實現：逐行對應數學](#6-程式碼實現)
7. [數學正確性驗證](#7-數學正確性驗證)
8. [實驗結果與診斷](#8-實驗結果與診斷)
9. [與論文的對比](#9-與論文的對比)
10. [已知限制與未解問題](#10-已知限制)

---

## 1. 目標

### 1.1 我們在做什麼

磁鑷（Magnetic Tweezers）有 6 根極頭（poles），每根纏繞 70 匝線圈。通電後在 workspace（WP）中心產生磁場，用來操控磁珠。

我們已經用 ANSYS FEM 模擬了每根線圈單獨通 1A 電流時的完整 3D 磁場（Stage 1-2）。現在要建立一個**解析模型**——用 6 個磁單極（point charges）來近似 FEM 的場。

### 1.2 為什麼需要解析模型

FEM 數據是離散的（~39 萬個節點），無法直接用於：
- 即時力計算（需要 B 場的解析梯度）
- 控制器設計（需要電流→力的閉式關係）
- 快速掃描不同電流組合

解析模型只有 2 個待定參數（`ell` 和 `R_a`），擬合完成後可以在任意位置瞬間計算 B 場。

### 1.3 兩個待定參數

| 參數 | 符號 | 物理意義 | 預期值 |
|------|------|----------|--------|
| 等效磁荷距離 | `ell` | 6 個磁荷到 WP 中心的距離 | ~900 μm（論文） |
| 空氣磁阻 | `R_a` | 極頭→WP 的等效空氣磁阻 | ~6.3×10⁸ A/Wb（論文） |

---

## 2. 物理背景

### 2.1 為什麼點電荷模型可行

極頭尖端半徑 = 40 μm，WP 中心到極頭 = 500 μm。
距離/尺寸比 = 500/40 ≈ 12.5 >> 1。

在這個距離上，有限大小的極頭「看起來」就像一個數學上的點源——就像從遠處看一個帶電球體，場等效於所有電荷集中在球心。

### 2.2 六極系統的結構

6 根極頭排列在 WP 中心周圍，分上下兩層：

```
下層（Lower）：P1 (0°), P3 (120°), P6 (240°)    — z_wp = -R_norm_z
上層（Upper）：P2 (180°), P4 (300°), P5 (60°)   — z_wp = +R_norm_z
```

其中：
- `R_norm = 500 μm`（WP 到極頭的幾何距離）
- `R_norm_xy = R_norm * sqrt(2/3) ≈ 408 μm`（xy 平面投影）
- `R_norm_z = R_norm / sqrt(3) ≈ 289 μm`（z 方向投影）

所有極頭到 WP 中心的距離相等 = `R_norm`（因為 `sqrt(R_norm_xy² + R_norm_z²) = R_norm`）。

### 2.3 座標系

- **APDL 座標**：原點在磁軛底面中心
- **WP 座標**：原點在 workspace 中心
- 轉換：`x_wp = x_apdl`, `y_wp = y_apdl`, `z_wp = z_apdl - SPH_OFST`
- `SPH_OFST ≈ -12.711 mm`（WP 中心的 APDL z 座標）
- 兩個座標系只差一個 z 方向平移，**B 場分量在兩個座標系中相同**

---

## 3. 數學模型

### 3.1 Eq 2.1：磁通量 → 等效磁荷

$$q_i = \frac{\Phi_i}{\mu_0}$$

| 符號 | 意義 | 單位 |
|------|------|------|
| $q_i$ | 第 $i$ 根極頭的等效磁荷 | A·m |
| $\Phi_i$ | 通過第 $i$ 根極頭的磁通量 | Wb |
| $\mu_0 = 4\pi \times 10^{-7}$ | 真空磁導率 | T·m/A |

物理直覺：磁荷的強度由通過該極的磁通量決定。磁通越大，等效磁荷越強。

### 3.2 Eq 2.2：單磁荷的 Coulomb 場

$$\mathbf{B}_i(\mathbf{p}) = k_m \cdot \frac{q_i \; \mathbf{r}_i}{\|\mathbf{r}_i\|^3}$$

| 符號 | 意義 |
|------|------|
| $\mathbf{p}$ | 場點位置（磁珠位置）[m] |
| $\mathbf{c}_i$ | 第 $i$ 個磁荷的位置 [m] |
| $\mathbf{r}_i = \mathbf{p} - \mathbf{c}_i$ | 從磁荷到場點的位移向量 [m] |
| $k_m = \mu_0/(4\pi) = 10^{-7}$ | 磁學 Coulomb 常數 [N/A²] |

注意分母是 $\|\mathbf{r}_i\|^3$ 而不是 $\|\mathbf{r}_i\|^2$，因為：

$$\frac{\mathbf{r}_i}{\|\mathbf{r}_i\|^3} = \frac{1}{\|\mathbf{r}_i\|^2} \cdot \frac{\mathbf{r}_i}{\|\mathbf{r}_i\|}$$

即「距離平方反比衰減 × 單位方向向量」合併書寫的結果。

### 3.3 磁荷的位置

6 個磁荷放在以 WP 中心為原點、半徑為 `ell` 的球面上，方向與實際極頭相同：

$$\mathbf{c}_i = \ell \cdot \hat{\mathbf{d}}_i$$

其中 $\hat{\mathbf{d}}_i$ 是從 WP 中心指向第 $i$ 根極頭的單位方向：

$$\hat{\mathbf{d}}_i = \begin{bmatrix} \cos\theta_i \cdot \sin\alpha \\ \sin\theta_i \cdot \sin\alpha \\ z\_sign_i \cdot \cos\alpha \end{bmatrix}$$

| 符號 | 意義 | 值 |
|------|------|-----|
| $\theta_i$ | 極頭的方位角 | P1=0°, P2=180°, P3=120°, P4=300°, P5=60°, P6=240° |
| $\alpha$ | 極頭的極角（與 z 軸的夾角） | `atan2(R_norm_xy, R_norm_z) ≈ 54.74°` |
| $z\_sign_i$ | 上下層標記 | 下層=-1 (P1,P3,P6)，上層=+1 (P2,P4,P5) |

驗證 $\alpha$ 的定義：
- `sin(alpha) = R_norm_xy / R_norm`
- `cos(alpha) = R_norm_z / R_norm`
- `sqrt(sin²(alpha) + cos²(alpha)) = 1` ✓
- 所以 `|c_i| = ell * 1 = ell` ✓（所有磁荷到中心的距離 = ell）

**重要：`ell` 不等於物理極頭距離（500 μm）。** `ell` 是讓點電荷模型最佳近似 FEM 的等效距離，擬合值 ~900 μm > 500 μm，因為真實極頭不是點，磁通從整個尖端表面擴散。

### 3.4 Eq 2.3：六極疊加

總場 = 6 個磁荷的場之和：

$$\mathbf{B}(\mathbf{p}) = \sum_{i=1}^{6} k_m \cdot \frac{q_i \; (\mathbf{p} - \mathbf{c}_i)}{\|\mathbf{p} - \mathbf{c}_i\|^3}$$

論文將此寫成矩陣形式（無量綱化後）：

$$\mathbf{B} = \frac{k_m}{\ell^2} \; \hat{\mathbf{R}}(\hat{\mathbf{p}}) \; \mathbf{Q}$$

其中 $\hat{\mathbf{R}}$ 是 $3 \times 6$ 的幾何矩陣（第 $i$ 列 = $\hat{\mathbf{r}}_i / \|\hat{\mathbf{r}}_i\|^3$，$\hat{\mathbf{r}}_i = (\mathbf{p} - \mathbf{c}_i)/\ell$）。

**我們的程式碼不使用無量綱形式**——直接用有量綱的 `r_i = p - c_i` 計算，數學上完全等價（已驗證，見 §7.4）。

### 3.5 Eq 2.4：電流 → 磁荷

$$\mathbf{Q} = \frac{N_c}{\mu_0 \, \mathcal{R}_a} \; \mathbf{K}_I \; \mathbf{I}$$

推導過程：

**Step 1：磁動力（MMF）**
$$\mathcal{F}_i = N_c \cdot I_i$$
- $N_c = 70$（線圈匝數），$I_i$ = 第 $i$ 個線圈的電流 [A]

**Step 2：Hopkinson's Law（磁路 Ohm 定律）**

單一磁路：$\Phi = \mathcal{F} / \mathcal{R}_a$

6 極耦合系統：$\boldsymbol{\Phi} = \frac{N_c}{\mathcal{R}_a} \; \mathbf{K}_I \; \mathbf{I}$

**Step 3：磁通 → 磁荷（Eq 2.1）**
$$\mathbf{Q} = \frac{\boldsymbol{\Phi}}{\mu_0} = \frac{N_c}{\mu_0 \, \mathcal{R}_a} \; \mathbf{K}_I \; \mathbf{I}$$

### 3.6 $\mathbf{K}_I$ 矩陣（Eq 2.8，名義值）

$$\mathbf{K}_I = \mathbf{I}_{6 \times 6} - \frac{1}{6} \mathbf{1}_{6 \times 6}$$

對角項 = $5/6 \approx 0.833$，非對角項 = $-1/6 \approx -0.167$

物理意義：激勵 P1 時，P1 保留 5/6 的磁通（主通路），其餘 5 極各回流 -1/6（回流路）。

性質：
- 每行加總 = 0（磁通守恆，$\nabla \cdot \mathbf{B} = 0$）
- 對稱矩陣（互易性）
- 奇異矩陣（等電流 → 零磁通）

### 3.7 完整模型：電流 → B 場

將 Eq 2.3 和 Eq 2.4 合併：

$$\mathbf{B}(\mathbf{p}) = \sum_{i=1}^{6} k_m \cdot Q_i \cdot \frac{\mathbf{p} - \mathbf{c}_i}{\|\mathbf{p} - \mathbf{c}_i\|^3}$$

其中：
$$Q_i = \frac{N_c}{\mu_0 \, \mathcal{R}_a} \cdot (\mathbf{K}_I \; \mathbf{I})_i$$

已知量：$N_c$, $\mu_0$, $k_m$, $\theta_i$, $\alpha$, $\mathbf{K}_I$, $\mathbf{I}$
待定參數：$\ell$（磁荷距離）, $\mathcal{R}_a$（空氣磁阻）

---

## 4. 擬合策略

### 4.1 目標函數

給定 FEM 數據 $\{(\mathbf{p}_j, \mathbf{B}_j^{\text{FEM}})\}_{j=1}^{N}$，最小化：

$$J(\ell, \mathcal{R}_a) = \sum_{j=1}^{N} \|\mathbf{B}_j^{\text{model}}(\ell, \mathcal{R}_a) - \mathbf{B}_j^{\text{FEM}}\|^2$$

每個節點貢獻 3 個分量（$B_x, B_y, B_z$），所以殘差向量的長度 = $3N$。

### 4.2 關鍵觀察：B 對 $\mathcal{R}_a$ 是線性的

定義 $C = \frac{N_c}{\mu_0 \, \mathcal{R}_a}$，則：

$$Q_i = C \cdot (\mathbf{K}_I \; \mathbf{I})_i$$

$$\mathbf{B}^{\text{model}}(\mathbf{p}; \ell, C) = C \cdot \underbrace{\sum_{i=1}^{6} k_m \cdot (\mathbf{K}_I \; \mathbf{I})_i \cdot \frac{\mathbf{p} - \mathbf{c}_i(\ell)}{\|\mathbf{p} - \mathbf{c}_i(\ell)\|^3}}_{\mathbf{B}^{\text{unit}}(\mathbf{p}; \ell)}$$

**$\mathbf{B}^{\text{unit}}$ 只取決於 $\ell$**（通過磁荷位置 $\mathbf{c}_i = \ell \cdot \hat{\mathbf{d}}_i$），不含 $C$。

因此：$\mathbf{B}^{\text{model}} = C \cdot \mathbf{B}^{\text{unit}}(\ell)$

### 4.3 為什麼 B 對 C 線性

更直觀的理解：改變 $C$（即改變 $\mathcal{R}_a$）只改變所有磁荷的**振幅**（大小），不改變它們的**位置**。位置由 $\ell$ 決定。所以 $C$ 就像一個整體的音量旋鈕——把所有磁荷同時放大或縮小，場的空間形狀不變，只有幅度改變。

### 4.4 降維：2D → 1D

利用 $\mathbf{B} = C \cdot \mathbf{B}^{\text{unit}}$，目標函數變成：

$$J(\ell, C) = \|C \cdot \mathbf{b}^{\text{unit}}(\ell) - \mathbf{b}^{\text{FEM}}\|^2$$

其中 $\mathbf{b}^{\text{unit}}$ 和 $\mathbf{b}^{\text{FEM}}$ 是 $3N \times 1$ 的向量（把所有節點的 $B_x, B_y, B_z$ 串起來）。

對固定的 $\ell$，這是一個 **scalar least-squares** 問題——找使 $J$ 最小的 $C$：

$$\frac{\partial J}{\partial C} = 2 \, (\mathbf{b}^{\text{unit}})^T (C \cdot \mathbf{b}^{\text{unit}} - \mathbf{b}^{\text{FEM}}) = 0$$

$$\boxed{C_{\text{opt}}(\ell) = \frac{(\mathbf{b}^{\text{unit}})^T \; \mathbf{b}^{\text{FEM}}}{(\mathbf{b}^{\text{unit}})^T \; \mathbf{b}^{\text{unit}}}}$$

這是**解析解**——不需要迭代，一個內積就算出來。

代入得到 $\ell$ 的一維目標函數：

$$J^*(\ell) = \|C_{\text{opt}}(\ell) \cdot \mathbf{b}^{\text{unit}}(\ell) - \mathbf{b}^{\text{FEM}}\|^2$$

### 4.5 一維搜尋 ell

**Phase 1：粗掃描**

在 $\ell \in [400, 2000]$ μm 上均勻取 300 個點，對每個 $\ell$ 計算 $J^*(\ell)$：

1. 用 $\ell$ 計算 6 個磁荷位置 $\mathbf{c}_i = \ell \cdot \hat{\mathbf{d}}_i$
2. 計算 $\mathbf{B}^{\text{unit}}$（令 $C=1$，即 $\mathcal{R}_a = N_c/\mu_0$）
3. 用解析公式算 $C_{\text{opt}}$
4. 算殘差 $J^* = \|C_{\text{opt}} \cdot \mathbf{b}^{\text{unit}} - \mathbf{b}^{\text{FEM}}\|^2$

找到最小的 $\ell_0$。

**Phase 2：精煉**

用 MATLAB `fminbnd` 在 $[\ell_0 - 200\text{μm}, \ell_0 + 200\text{μm}]$ 區間精煉，收斂精度 `TolX = 1e-8`（即 0.01 nm，遠超需要）。

**Phase 3：恢復 $\mathcal{R}_a$**

$$\mathcal{R}_a = \frac{N_c}{\mu_0 \cdot C_{\text{opt}}}$$

### 4.6 為什麼不直接 2D 優化

直接用 `lsqnonlin` 或 `fminsearch` 同時搜 $\ell$ 和 $\mathcal{R}_a$？可以，但有實務問題：

1. **尺度差異巨大**：$\ell \sim 10^{-3}$ m，$\mathcal{R}_a \sim 10^{9}$ A/Wb，相差 12 個數量級
2. **部分耦合**：$\ell$ 和 $\mathcal{R}_a$ 都影響幅度（$|\mathbf{B}| \propto C/\ell^2 = N_c / (\mu_0 \, \mathcal{R}_a \, \ell^2)$），但只有 $\ell$ 影響空間形狀
3. 實測中，2D 優化容易卡在 local minimum 或沿 $\ell^2 \cdot \mathcal{R}_a = \text{const}$ 的山谷滑動

利用線性化，1D 搜尋更穩健、更快、且保證找到 global minimum（在掃描範圍內）。

### 4.7 ell 和 R_a 的可分離性

直覺理解（燈泡類比）：

想像暗室裡一盞燈。你拿亮度計在不同位置量亮度，想反推：
- **燈泡瓦數**（亮度）↔ $\mathcal{R}_a$（磁阻越小 → 磁荷越強 → 場越大）
- **燈泡距離** ↔ $\ell$（磁荷到中心的距離）

只在一個位置量 → 無法區分「近處暗燈」和「遠處亮燈」
在多個位置量 → 衰減模式不同（近燈衰減快，遠燈衰減慢）→ 可以分離

數學上：

$$\frac{|\mathbf{B}(\mathbf{p}_1)|}{|\mathbf{B}(\mathbf{p}_2)|} = \frac{|\mathbf{S}(\mathbf{p}_1;\, \ell)|}{|\mathbf{S}(\mathbf{p}_2;\, \ell)|}$$

比值中 $\mathcal{R}_a$ 被消掉，**只取決於 $\ell$**。所以 $\ell$ 由空間衰減模式決定，$\mathcal{R}_a$ 由幅度決定。

**實務限制**：如果數據區域太小（$\ll \ell$），場幾乎均勻，衰減模式不明顯，$\ell$ 就無法被有效約束。這正是我們在 §8 中看到的問題。

---

## 5. 符號約定

### 5.1 我們的 Q vs 論文的 Q

**論文 Eq 2.4：**
$$\mathbf{Q} = \frac{N_c}{\mu_0 \, \mathcal{R}_a} \; \mathbf{K}_I \; \mathbf{I} \qquad \text{（無負號）}$$

**我們的程式碼：**
$$\mathbf{Q} = -\frac{N_c}{\mu_0 \, \mathcal{R}_a} \; \mathbf{K}_I \; \mathbf{I} \qquad \text{（有負號）}$$

### 5.2 為什麼需要負號

在我們的 APDL 模型中，激勵 Coil 1（P1）時，FEM 數據顯示 WP 中心的 B 場**指向 P1**（$B_x > 0$，P1 在 $\theta = 0°$）。

這意味著 P1 是 **flux sink**（磁通從 workspace 流入 P1 極頭）。

用 Coulomb 場驗證：

正磁荷（$q > 0$）在位置 $\mathbf{c}_1$ 產生的場在原點（p=0）：

$$\mathbf{B}(0) = k_m \cdot q \cdot \frac{0 - \mathbf{c}_1}{|\mathbf{c}_1|^3} = -\frac{k_m \, q}{\ell^2} \hat{\mathbf{d}}_1$$

正磁荷的 B 指向 **遠離** P1 的方向（$-\hat{\mathbf{d}}_1$）。但 FEM 顯示 B 指向 P1（$+\hat{\mathbf{d}}_1$），所以 P1 的磁荷必須是**負的**。

不加負號：$Q_{\text{P1}} = +\frac{5}{6}C > 0$ → B 指向遠離 P1 → **方向錯誤**
加上負號：$Q_{\text{P1}} = -\frac{5}{6}C < 0$ → B 指向 P1 → **方向正確** ✓

### 5.3 負號對擬合結果的影響

**數學上完全不影響。**

如果不加負號，$\mathbf{b}^{\text{unit}}$ 方向反轉，但 $C_{\text{opt}}$ 會變成負值來補償：

$$C_{\text{opt}} = \frac{(\mathbf{b}^{\text{unit}})^T \; \mathbf{b}^{\text{FEM}}}{(\mathbf{b}^{\text{unit}})^T \; \mathbf{b}^{\text{unit}}}$$

$\mathbf{b}^{\text{unit}}$ 反號 → 分子反號 → $C_{\text{opt}}$ 反號 → $C \cdot \mathbf{b}^{\text{unit}}$ 不變。

最終的 $\mathbf{B}^{\text{model}}$ 和 cost $J^*$ 完全相同。

唯一差別：加負號確保 $C_{\text{opt}} > 0$ 和 $\mathcal{R}_a > 0$，使參數具有物理可解釋性。

### 5.4 論文的可能情況

論文可能：
1. APDL 線圈繞法使 P1 成為 flux **source**（B 遠離 P1），此時不需要負號
2. 或者論文也需要負號但沒明寫（$\mathcal{R}_a$ 吸收了符號）

無論哪種情況，最終 B 場和擬合結果相同。

---

## 6. 程式碼實現

### 6.1 檔案結構

| 檔案 | 功能 |
|------|------|
| `mt_constants.m` | 幾何常數、極頭位置、物理常數 |
| `filter_iron_nodes.m` | 幾何錐體模型排除鐵芯節點 |
| `point_charge_model.m` | 計算 6 極點電荷 B 場 |
| `fit_charge_model.m` | 主擬合腳本（含 1D 搜尋 + 結果輸出） |

### 6.2 `point_charge_model.m` — 逐行數學對應

```matlab
function [Bx, By, Bz] = point_charge_model(p_wp, ell, R_a, I_vec, K_I, c)
```

**Step 1：計算 6 個磁荷位置** (lines 29-36)

```matlab
alpha = c.alpha;  % atan2(R_norm_xy, R_norm_z) ≈ 54.74°
for i = 1:6
    theta = c.pole_angles(i) * pi/180;
    z_sign = sign(c.pole_tip_z_wp(i));
    charge_pos(:,i) = ell * [cos(theta)*sin(alpha); ...
                              sin(theta)*sin(alpha); ...
                              z_sign*cos(alpha)];
end
```

→ $\mathbf{c}_i = \ell \cdot [\cos\theta_i \sin\alpha, \; \sin\theta_i \sin\alpha, \; z\_sign_i \cos\alpha]^T$

**Step 2：計算磁荷向量 Q** (line 41)

```matlab
Q = -(c.N_c / (c.mu_0 * R_a)) * (K_I * I_vec);
```

→ $Q_i = -\frac{N_c}{\mu_0 \, \mathcal{R}_a} \cdot (\mathbf{K}_I \; \mathbf{I})_i$

**Step 3：對 6 個磁荷累加 Coulomb 場** (lines 44-55)

```matlab
for i = 1:6
    dx = p_wp(:,1) - charge_pos(1,i);   % r_i = p - c_i
    dy = p_wp(:,2) - charge_pos(2,i);
    dz = p_wp(:,3) - charge_pos(3,i);
    r3 = (dx.^2 + dy.^2 + dz.^2).^(3/2); % |r_i|^3
    Bx = Bx + Q(i) * dx ./ r3;  % Σ Q_i * r_i / |r_i|^3
    By = By + Q(i) * dy ./ r3;
    Bz = Bz + Q(i) * dz ./ r3;
end
```

→ $\mathbf{B} = \sum_{i=1}^{6} Q_i \cdot \frac{\mathbf{p} - \mathbf{c}_i}{\|\mathbf{p} - \mathbf{c}_i\|^3}$（尚未乘 $k_m$）

**Step 4：乘上 Coulomb 常數** (lines 58-60)

```matlab
Bx = c.k_m * Bx;  % k_m = mu_0/(4*pi) = 1e-7
```

→ $\mathbf{B} = k_m \cdot \sum_{i=1}^{6} Q_i \cdot \frac{\mathbf{p} - \mathbf{c}_i}{\|\mathbf{p} - \mathbf{c}_i\|^3}$ ✓

### 6.3 `fit_ell_cost` — 1D cost function

```matlab
function [cost, C_opt] = fit_ell_cost(ell, p_wp, b_fem, I_vec, K_I, c)
    % Step 1: 計算 C=1 時的模型 B（令 R_a = N_c/mu_0 使 C=1）
    R_a_unit = c.N_c / c.mu_0;
    [bx, by, bz] = point_charge_model(p_wp, ell, R_a_unit, I_vec, K_I, c);
    b_unit = [bx; by; bz];  % 3N × 1

    % Step 2: 解析解求最佳 C
    C_opt = (b_unit' * b_fem) / (b_unit' * b_unit);

    % Step 3: 計算殘差
    residual = C_opt * b_unit - b_fem;
    cost = sum(residual.^2);
end
```

**為什麼 `R_a_unit = N_c / mu_0` 使 C = 1？**

$$C = \frac{N_c}{\mu_0 \cdot \mathcal{R}_a} = \frac{N_c}{\mu_0 \cdot (N_c / \mu_0)} = 1$$

所以 `b_unit` 就是 $C=1$ 的模型場。實際模型 $\mathbf{B}^{\text{model}} = C \cdot \mathbf{b}^{\text{unit}}$。

**驗證線性關係：**

實際 Q = $-C \cdot \mathbf{K}_I \cdot \mathbf{I}$，unit Q = $-1 \cdot \mathbf{K}_I \cdot \mathbf{I}$。

因為 Q → $C \cdot Q_{\text{unit}}$，且 $\mathbf{c}_i$ 不受 $C$ 影響：

$\mathbf{B}^{\text{model}} = C \cdot \mathbf{B}^{\text{unit}}$ ✓

### 6.4 `fit_charge_model.m` — 主流程

```
1. Load data          → import_ansys_data (Coil 1 WP)
2. Iron exclusion     → filter_iron_nodes (geometric cone model)
3. Coordinate xform   → z_wp = z_apdl - SPH_OFST
4. Define regions     → mask_A (100um cube), mask_B (R<500um sphere), mask_V (80um cube)
5. Fit A & B          → do_fit() with 1D scan + fminbnd
6. Validate           → evaluate both fits on 80um cube
7. Compare            → side-by-side table + figures
8. Save               → data/charge_model_fit.mat
```

### 6.5 鐵芯節點排除 (`filter_iron_nodes.m`)

磁荷模型只適用於空氣節點（鐵芯內部 B 由材料性質主導，不符合 Coulomb 場）。

排除演算法（對每根極頭，向量化處理所有 N 個節點）：

1. 計算從極頭頂端到每個節點的向量 $\mathbf{v} = \mathbf{p}_{\text{node}} - \mathbf{p}_{\text{tip}}$
2. 投影到極軸方向 $s = \mathbf{v} \cdot \hat{\mathbf{a}}_i$（正值 = 在極頭後方，朝極體方向）
3. 計算垂直距離 $r_{\perp} = \sqrt{|\mathbf{v}|^2 - s^2}$
4. 錐體半徑 $r_{\text{cone}}(s) = R_{\text{tip}} + s \cdot (R_{\text{base}} - R_{\text{tip}}) / L_{\text{cone}}$
5. 若 $s > 0$ 且 $r_{\perp} < r_{\text{cone}}$ 且 $s < L_{\text{cone}}$ → 鐵芯節點
6. 安全球：距離極頭 < 100 μm 的節點也排除（過渡區域）

結果：排除 ~49,000 / 390,000 節點（~12.6%）。

---

## 7. 數學正確性驗證

### 7.1 磁荷位置

$|\mathbf{c}_i| = \ell \cdot \sqrt{\sin^2\alpha + \cos^2\alpha} = \ell$ ✓

方向 = WP 中心 → 極頭的單位向量 ✓

### 7.2 Coulomb 場公式

$\mathbf{B} = k_m \cdot \sum Q_i \cdot (\mathbf{p} - \mathbf{c}_i) / |\mathbf{p} - \mathbf{c}_i|^3$

這是標準磁荷 Coulomb 場，$(\mathbf{p} - \mathbf{c}_i)$ 從磁荷指向場點 ✓

### 7.3 線性化的正確性

$\mathbf{B} = C \cdot \mathbf{B}^{\text{unit}}$ 因為：
- Q = $-C \cdot \mathbf{K}_I \cdot \mathbf{I}$（$C$ 只出現在 Q 的振幅）
- $\mathbf{c}_i = \ell \cdot \hat{\mathbf{d}}_i$（位置不含 $C$）
- 所以 $\mathbf{B}$ 對 $C$ 線性 ✓

$C_{\text{opt}} = (\mathbf{b}_u^T \mathbf{b}_f) / (\mathbf{b}_u^T \mathbf{b}_u)$ 是標準 scalar least-squares 解析解 ✓

### 7.4 與論文無量綱形式的等價性

論文：$\mathbf{B} = (k_m/\ell^2) \cdot \hat{\mathbf{R}} \cdot \mathbf{Q}$

$\hat{\mathbf{R}}$ 第 $i$ 列 = $\hat{\mathbf{r}}_i / \|\hat{\mathbf{r}}_i\|^3$，$\hat{\mathbf{r}}_i = (\mathbf{p}-\mathbf{c}_i)/\ell$

展開：

$$\frac{k_m}{\ell^2} \cdot \frac{(\mathbf{p}-\mathbf{c}_i)/\ell}{|(\mathbf{p}-\mathbf{c}_i)/\ell|^3} \cdot Q_i
= \frac{k_m}{\ell^2} \cdot \frac{\ell^2 (\mathbf{p}-\mathbf{c}_i)}{|\mathbf{p}-\mathbf{c}_i|^3} \cdot Q_i
= k_m \cdot Q_i \cdot \frac{\mathbf{p}-\mathbf{c}_i}{|\mathbf{p}-\mathbf{c}_i|^3}$$

與我們的直接計算完全一致 ✓

### 7.5 K_I 矩陣

`eye(6) - ones(6)/6` → 對角 5/6，非對角 -1/6 ✓

每行和 = 5/6 - 5×1/6 = 0 ✓（磁通守恆）

### 7.6 座標系與 B 分量

APDL → WP 是純平移（$\Delta z = -\text{SPH\_OFST}$），座標軸方向不變。
B 場是向量場，在平移變換下分量不變 ✓

### 7.7 符號正確性

使用負號：$Q_{\text{P1}} = -5C/6 < 0$

$\mathbf{B}(0) = k_m \sum_i Q_i \cdot (0 - \mathbf{c}_i) / \ell^3$

由對稱性 $\sum_i \hat{\mathbf{d}}_i = 0$，可得：

$\mathbf{B}(0) = (k_m C / \ell^2) \cdot \hat{\mathbf{d}}_1$ → 指向 P1 方向

與 FEM 數據一致（$B_x > 0$，P1 在 $+x$ 方向）✓

---

## 8. 實驗結果與診斷

### 8.1 兩種擬合範圍的結果

| | Fit A (100 μm 正方體) | Fit B (R < 500 μm 球) |
|---|---|---|
| 節點數 | 647 | 196,783 |
| ell | 835 μm | 799 μm |
| R_a | 9.21×10⁸ A/Wb | 1.06×10⁹ A/Wb |

### 8.2 在 80 μm 正方體（驗證區域）的誤差

| | Fit A | Fit B | 論文 Fig 2.6 |
|---|---|---|---|
| Mean error | 4.87% | 7.16% | 0.5-1.5% |
| Median error | 4.91% | 7.27% | — |
| 95th percentile | 6.58% | 8.66% | — |
| Max error | 7.32% | 9.67% | <2% |

### 8.3 Cost Landscape 分析

| | Fit A | Fit B |
|---|---|---|
| cost(500μm) / cost(min) | 2.28 | 6.85 |
| cost(1200μm) / cost(min) | 1.26 | 1.96 |
| 10% cost 寬度 | 321 μm (ell∈[705,1026]) | 144 μm (ell∈[737,882]) |

**Fit A 的 cost landscape 非常平坦**——ell 從 705 到 1026 μm，cost 變化不到 10%。100 μm 正方體內的場近乎均勻，無法有效約束 ell。這解釋了為什麼 Fit A (ell=835) 和之前 R<400μm 的結果 (ell=834) 幾乎相同——兩者都在同一個平坦谷底中。

**Fit B 的 cost landscape 更尖銳**——R<500 μm 的數據提供了充分的空間衰減資訊。但 ell=799 被壓低是因為需要兼顧接近磁荷位置的遠處節點。

### 8.4 中心場驗證

WP 中心（最近 FEM 節點）的 B 場對比（之前跑的結果）：

```
Model: Bx ≈ +8.8 mT, By ≈ 0, Bz ≈ -6.2 mT
FEM:   Bx ≈ +6.9 mT, By ≈ 0, Bz ≈ -5.3 mT
```

方向一致（都指向 P1），幅度差 ~15-27%。

---

## 9. 與論文的對比

### 9.1 參數對比

| 參數 | 我們 (Fit A) | 我們 (Fit B) | 論文 |
|------|-------------|-------------|------|
| ell | 835 μm | 799 μm | 900 μm |
| R_a | 9.21×10⁸ | 1.06×10⁹ | 6.3×10⁸ |
| 中心 error | ~5% | ~7% | <1% |

### 9.2 差異的原因

**主要原因：material model 不同**

- 我們的 APDL：`murx = 280`（線性，低場初始磁導率）
- 論文未明確指定，但在操作點 (B~1T in steel) 的 μ_r 可能在 ~1400 或使用非線性 B-H
- 低 μ_r → 鐵芯導磁能力差 → 更多磁通側向洩漏 → WP 中心場的高階多極成分更大 → 6 磁單極模型的近似精度下降

**次要原因：**

- 論文可能只用 ~100 μm 正方體的數據擬合（Fig 2.3(b) 的範圍），但他們的 FEM 在此區域就已經非常接近理想磁單極場
- 我們的 FEM 即使在中心，模型 error 也有 ~5%，說明是場分佈本身的差異而非擬合策略的問題

### 9.3 擬合方法的差異

| 方面 | 我們 | 論文 |
|------|------|------|
| 策略 | 1D scan (ell) + 解析 C_opt | 可能是 2D lsqnonlin/fminsearch |
| Q 的符號 | $-N_c/(\mu_0 R_a) \cdot K_I \cdot I$ | $+N_c/(\mu_0 R_a) \cdot K_I \cdot I$ |
| 結果等價性 | 完全等價（§5.3 證明） | — |

論文沒有詳細描述擬合的具體演算法，只說 "best fitting ... with that calculated using FEM analysis"。

---

## 10. 已知限制

### 10.1 模型本身的限制

- 6 個磁單極是近似——真實場有高階多極成分
- 模型在 $|\mathbf{p}| \to \ell$ 時精度下降（場點接近磁荷，1/r³ 發散）
- 名義 $\mathbf{K}_I$ 假設完美對稱，實際裝置上下層不對稱

### 10.2 我們 FEM 的限制

- `murx = 280` 可能不是最佳選擇——低 μ_r 導致場分佈偏離理想磁單極
- 線性材料模型（無飽和效應），但在 1A 激勵下鐵芯 B~1T 可能已接近非線性區

### 10.3 擬合區域的 trade-off

| 擬合區域 | 優點 | 缺點 |
|----------|------|------|
| 小（~100 μm 正方體） | 中心精度最高 | ell 約束弱，cost 平坦 |
| 大（R < 500 μm） | ell 約束強 | 遠處節點接近磁荷，增加整體 error |
| 中（R < 400 μm） | 折衷 | 仍有 ~15% mean error |

### 10.4 後續改進方向

1. 嘗試更高 murx 或非線性 B-H 曲線重跑 ANSYS
2. 提取 $\mathbf{K}_I^{\text{FEM}}$ 矩陣（用 6 coil 數據，不假設對稱）
3. 加入偏置向量 $\mathbf{b}_i$（6×3 = 18 個額外參數，讓每個磁荷位置可微調）
