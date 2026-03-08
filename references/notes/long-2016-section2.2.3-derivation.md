# Section 2.2.3 Hexapole Magnetic Field Model — 完整推導

> 來源：Fei Long 博士論文 (2016), pp. 17-21, Eq. 2.1-2.4
> 本文件包含所有數學符號定義、逐步推導、物理直覺、以及與我們 ANSYS 模擬的對應關係。
>
> **符號對照：** 論文中 workspace 半徑使用草寫 $\ell$（script L），本文件統一使用 $\ell$。
> 我們的 MATLAB/ANSYS 程式碼中對應的變數名為 `rho`（因程式碼不方便用草寫符號）。

---

## 目錄

1. [前置背景：FEM 觀察 → 點電荷假設的動機](#1-前置背景)
2. [Eq. 2.1：磁通量 → 等效磁荷](#2-eq-21磁通量--等效磁荷)
3. [Eq. 2.2：單磁荷的 Coulomb 場](#3-eq-22單磁荷的-coulomb-場)
4. [Eq. 2.3：六極疊加 → 矩陣形式（含無量綱化推導）](#4-eq-23六極疊加--矩陣形式)
5. [Eq. 2.4：電流 → 磁荷（Hopkinson's Law + K_I）](#5-eq-24電流--磁荷)
6. [K_I 矩陣的物理意義](#6-ki-矩陣的物理意義)
7. [擬合 rho 和 R_a 的完整過程](#7-擬合-rho-和-ra)
8. [提取 K_I^FEM 矩陣](#8-提取-kifem-矩陣)
9. [整體邏輯串聯：電流 → 磁場 → 力](#9-整體邏輯串聯)
10. [完整 Notation 表](#10-完整-notation-表)
11. [與我們 ANSYS 模擬的對應](#11-與我們-ansys-模擬的對應)

---

## 1. 前置背景

### 1.1 FEM 觀察（Section 2.2.2）

作者在 ANSYS 中對 Coil 1 施加 1A 電流，在三張圖中觀察到：

- **Fig.2.3(a)** 全局俯視圖：磁場在磁極和磁軛的引導下形成封閉迴路
- **Fig.2.3(b)** WP 中心 100 μm 立方體：所有 $\mathbf{B}$ 場向量都指向 P1 極頭 → 看起來就像一個「點源」產生的場
- **Fig.2.3(c)** P1 極頭附近：向量強烈匯聚到尖端 → 進一步驗證「尖端像點電荷」的假設
- **Fig.2.4** $|\mathbf{B}|$ 等高線圖：workspace 附近場約 8–30 mT

### 1.2 點電荷假設的物理動機

極頭尖端的半徑只有 40 μm，而 workspace 中心距離極頭 ~500 μm。
距離/尺寸 比值 $= 500/40 \approx 12.5 \gg 1$。

在這個距離上，有限大小的尖端「看起來」就像一個數學上的點源，就像在遠處觀察一個帶電球體，場等價於所有電荷集中在球心的點電荷。

這就是建立解析模型的基礎。

---

## 2. Eq. 2.1：磁通量 → 等效磁荷

$$
q_i = \frac{\Phi_i}{\mu_0} \tag{2.1}
$$

### 符號定義

| 符號 | 意義 | 單位 |
|------|------|------|
| $q_i$ | 第 $i$ 根極頭的等效磁荷 | A·m |
| $\Phi_i$ | 通過第 $i$ 根極頭的磁通量 | Wb（韋伯）|
| $\mu_0 = 4\pi \times 10^{-7}$ | 真空磁導率 | T·m/A |
| $i = 1, 2, \dots, 6$ | 極頭編號 | — |

### 物理意義

這是靜磁學中的「磁荷」(magnetic charge) 概念。雖然真正的磁單極子不存在（磁力線永遠是封閉的），但在數學上可以用一個等效的磁荷來描述**極頭尖端**對遠處產生的場效應。

類比靜電學：

$$
\text{靜電：} Q_e \;(\text{電荷}) \;\longrightarrow\; \text{產生 } \mathbf{E} \text{ 場}
$$

$$
\text{靜磁：} q = \Phi/\mu_0 \;(\text{磁荷}) \;\longrightarrow\; \text{產生 } \mathbf{B} \text{ 場}
$$

磁荷的大小由通過該極的磁通量決定：磁通越大，等效磁荷越強。

---

## 3. Eq. 2.2：單磁荷的 Coulomb 場

### 3.1 論文原文形式（拆成距離 + 方向）

$$
\mathbf{B}_i(\mathbf{p},\, \mathbf{b}_i) = k_m \cdot \frac{q_i}{\| \mathbf{r}_i(\mathbf{p},\, \mathbf{b}_i) \|^2} \cdot \mathbf{u}_i(\mathbf{p},\, \mathbf{b}_i), \quad i = 1 \sim 6 \tag{2.2}
$$

### 3.2 符號定義

| 符號 | 意義 | 大小 |
|------|------|------|
| $\mathbf{B}_i$ | 第 $i$ 個磁荷在磁珠位置產生的磁通量密度向量 [T] | $3 \times 1$ |
| $\mathbf{p} = [x,\, y,\, z]^T$ | 磁珠的位置 [m] | $3 \times 1$ |
| $\mathbf{b}_i = [\xi_i,\, \eta_i,\, \zeta_i]^T$ | 第 $i$ 個磁荷的**偏置向量** (bias) [m] | $3 \times 1$ |
| $\mathbf{c}_i$ | 第 $i$ 個磁荷的實際位置 $=$ 極頭理想位置 $+ \mathbf{b}_i$ | $3 \times 1$ |
| $k_m = \dfrac{\mu_0}{4\pi} = 1.0 \times 10^{-7}$ | 磁學 Coulomb 常數 | [N/A²] |
| $\mathbf{r}_i = \mathbf{p} - \mathbf{c}_i$ | 從磁荷 $i$ 到磁珠的位移向量 [m] | $3 \times 1$ |
| $\|\mathbf{r}_i\|$ | $\mathbf{r}_i$ 的長度（歐幾里得範數）$=$ 磁荷到磁珠的距離 [m] | 標量 |
| $\mathbf{u}_i = \dfrac{\mathbf{r}_i}{\|\mathbf{r}_i\|}$ | 從磁荷指向磁珠的**單位方向向量** | $3 \times 1$ |

### 3.3 $\mathbf{u}_i$ 和 $\mathbf{r}_i$ 的關係

$\mathbf{u}_i$ 就是 $\mathbf{r}_i$ 歸一化成長度為 1 的版本：

$$
\mathbf{u}_i = \frac{\mathbf{r}_i}{\|\mathbf{r}_i\|}
$$

所以 Eq. 2.2 可以改寫成**只用 $\mathbf{r}_i$ 的等價形式**：

$$
\mathbf{B}_i
= k_m \cdot \frac{q_i}{\|\mathbf{r}_i\|^2} \cdot \mathbf{u}_i
= k_m \cdot \frac{q_i}{\|\mathbf{r}_i\|^2} \cdot \frac{\mathbf{r}_i}{\|\mathbf{r}_i\|}
= k_m \cdot \frac{q_i \, \mathbf{r}_i}{\|\mathbf{r}_i\|^3}
\tag{2.2'}
$$

> 驗證：分母 $\|\mathbf{r}_i\|^2 \cdot \|\mathbf{r}_i\| = \|\mathbf{r}_i\|^3$ ✓

**兩種形式完全等價：**

| 形式 | 表達式 | 拆解 |
|------|--------|------|
| A（論文原文）| $\mathbf{B}_i = k_m \dfrac{q_i}{\|\mathbf{r}_i\|^2} \, \mathbf{u}_i$ | 距離平方反比 × 單位方向 |
| B（合併）| $\mathbf{B}_i = k_m \dfrac{q_i \, \mathbf{r}_i}{\|\mathbf{r}_i\|^3}$ | 位移向量 / 距離的三次方 |

形式 B 更簡潔，後面做矩陣推導時會用到。

### 3.4 與靜電學 Coulomb 定律的完全類比

$$
\text{靜電場：} \quad \mathbf{E} = \frac{1}{4\pi\varepsilon_0} \cdot \frac{Q_e \, \mathbf{r}}{\|\mathbf{r}\|^3}
$$

$$
\text{磁荷場：} \quad \mathbf{B} = \frac{\mu_0}{4\pi} \cdot \frac{q \, \mathbf{r}}{\|\mathbf{r}\|^3} = k_m \cdot \frac{q \, \mathbf{r}}{\|\mathbf{r}\|^3}
$$

結構完全對應。

### 3.5 偏置向量 $\mathbf{b}_i$ 的物理意義

論文原文 (p.18): *"the optimal location to model the magnetic charge $q_i$ is not necessarily at the tip of the pole"*

為什麼？因為真實的極頭不是數學上的點：
- 極頭有 40 μm 的半徑
- 磁通從整個尖端表面擴散出來，不是從一個點發出
- 如果硬要用「一個點」代替這個分佈式的源，那個最佳等效位置會在極頭**後方**（更深入極體內部）

後面擬合的結果證實了這一點：$\ell = 900\;\mu\text{m} \gg$ 物理尖端距離 $500\;\mu\text{m}$。

---

## 4. Eq. 2.3：六極疊加 → 矩陣形式

### 4.1 疊加原理

磁珠感受到的總場 $=$ 6 個磁荷各自產生的場之和：

$$
\mathbf{B}(\mathbf{p},\, \mathbf{b})
= \sum_{i=1}^{6} \mathbf{B}_i(\mathbf{p},\, \mathbf{b}_i)
= \sum_{i=1}^{6} k_m \cdot \frac{q_i \, \mathbf{r}_i}{\|\mathbf{r}_i\|^3}
$$

### 4.2 無量綱化——為什麼出現三次方

#### 4.2.1 為什麼要無量綱化

我們的起點是 Eq. (2.2') 的疊加：

$$
\mathbf{B} = \sum_{i=1}^{6} k_m \frac{q_i \, \mathbf{r}_i}{\|\mathbf{r}_i\|^3}
$$

這裡面 $\mathbf{r}_i$ 有量綱（單位是 m），不方便寫成統一的矩陣形式。
我們想把所有長度除以一個**參考長度** $\ell$（workspace 半徑），
讓位移向量變成無量綱（沒有單位）的 $\hat{\mathbf{r}}_i$，
然後把 $\ell$ 的影響集中到一個前面的係數裡。

#### 4.2.2 定義無量綱變數

選擇 $\ell$（workspace 半徑，也是磁荷到中心的等效距離）作為參考長度：

$$
\hat{\mathbf{r}}_i \;\equiv\; \frac{\mathbf{r}_i}{\ell}
\qquad \Longleftrightarrow \qquad
\mathbf{r}_i = \ell \;\hat{\mathbf{r}}_i
$$

- $\mathbf{r}_i$ 是**有量綱**的位移向量 [m]，例如 $\mathbf{r}_i = (0.0003,\; 0.0002,\; -0.0001)$ m
- $\hat{\mathbf{r}}_i$ 是**無量綱**的，例如當 $\ell = 0.0009$ m 時，$\hat{\mathbf{r}}_i = (0.333,\; 0.222,\; -0.111)$

向量的長度（範數）也跟著縮放：

$$
\|\mathbf{r}_i\| = \|\ell \;\hat{\mathbf{r}}_i\| = \ell \;\|\hat{\mathbf{r}}_i\|
$$

> 這一步用到了範數的性質：$\|a \mathbf{v}\| = |a| \cdot \|\mathbf{v}\|$（正數 $\ell > 0$ 可以直接提出來）。

#### 4.2.3 代入——逐行展開

**起點：** 單磁荷場的合併形式 (Eq. 2.2')

$$
\mathbf{B}_i = k_m \cdot \frac{q_i \;\mathbf{r}_i}{\|\mathbf{r}_i\|^3}
$$

**Step 1：** 把 $\mathbf{r}_i$ 和 $\|\mathbf{r}_i\|$ 都用 $\ell$ 和 $\hat{\mathbf{r}}_i$ 替換

$$
\mathbf{B}_i = k_m \cdot \frac{q_i \cdot \overbrace{\ell \;\hat{\mathbf{r}}_i}^{\mathbf{r}_i}}{\underbrace{\bigl(\ell \;\|\hat{\mathbf{r}}_i\|\bigr)^3}_{\|\mathbf{r}_i\|^3}}
$$

> 分子：$\mathbf{r}_i = \ell \;\hat{\mathbf{r}}_i$（定義）
>
> 分母：$\|\mathbf{r}_i\|^3 = (\ell \;\|\hat{\mathbf{r}}_i\|)^3$（範數代換後取三次方）

**Step 2：** 展開分母的三次方

$$
\bigl(\ell \;\|\hat{\mathbf{r}}_i\|\bigr)^3
= \ell^3 \cdot \|\hat{\mathbf{r}}_i\|^3
$$

> $(ab)^3 = a^3 b^3$，沒有交叉項。

代入得：

$$
\mathbf{B}_i = k_m \cdot \frac{q_i \cdot \ell \;\hat{\mathbf{r}}_i}{\ell^3 \cdot \|\hat{\mathbf{r}}_i\|^3}
$$

**Step 3：** 約分 $\ell$

分子有 $\ell^1$，分母有 $\ell^3$：

$$
\frac{\ell^1}{\ell^3} = \frac{1}{\ell^2}
$$

所以：

$$
\mathbf{B}_i
= k_m \cdot q_i \cdot \frac{1}{\ell^2} \cdot \frac{\hat{\mathbf{r}}_i}{\|\hat{\mathbf{r}}_i\|^3}
$$

整理：

$$
\boxed{
\mathbf{B}_i = \frac{k_m \; q_i}{\ell^2} \cdot \frac{\hat{\mathbf{r}}_i}{\|\hat{\mathbf{r}}_i\|^3}
}
$$

#### 4.2.4 結果的結構

無量綱化之後，$\mathbf{B}_i$ 被拆成三個部分：

$$
\mathbf{B}_i =
\underbrace{\frac{k_m}{\ell^2}}_{\substack{\text{通用前因子} \\ \text{（常數）}}}
\;\times\;
\underbrace{q_i}_{\substack{\text{磁荷強度} \\ \text{（由電流決定）}}}
\;\times\;
\underbrace{\frac{\hat{\mathbf{r}}_i}{\|\hat{\mathbf{r}}_i\|^3}}_{\substack{\text{無量綱幾何因子} \\ \text{（由位置決定）}}}
$$

| 部分 | 包含什麼 | 取決於 |
|------|---------|--------|
| $k_m / \ell^2$ | 物理常數和幾何尺度 | 固定（擬合後不變）|
| $q_i$ | 第 $i$ 極的磁荷 | 電流 $\mathbf{I}$ |
| $\hat{\mathbf{r}}_i / \|\hat{\mathbf{r}}_i\|^3$ | 方向和距離的綜合效應 | 磁珠位置 $\hat{\mathbf{p}}$ |

#### 4.2.5 三次方的直覺解釋

為什麼結果有 $\|\hat{\mathbf{r}}_i\|^3$ 而不是 $\|\hat{\mathbf{r}}_i\|^2$？

回到 Eq. (2.2) 原始形式：

$$
\mathbf{B}_i = k_m \frac{q_i}{\|\mathbf{r}_i\|^2} \cdot \mathbf{u}_i
= k_m \frac{q_i}{\|\mathbf{r}_i\|^2} \cdot \frac{\mathbf{r}_i}{\|\mathbf{r}_i\|}
$$

這裡有**兩個 $\|\mathbf{r}_i\|$**：
- 一個 $\|\mathbf{r}_i\|^2$ 來自 Coulomb 定律（場強反比距離平方）
- 一個 $\|\mathbf{r}_i\|^1$ 來自歸一化方向（把 $\mathbf{r}_i$ 變成單位向量 $\mathbf{u}_i$）

$$
\underbrace{\frac{1}{\|\mathbf{r}_i\|^2}}_{\text{Coulomb 衰減}} \times \underbrace{\frac{1}{\|\mathbf{r}_i\|^1}}_{\text{方向歸一化}} = \frac{1}{\|\mathbf{r}_i\|^3}
$$

所以 $\|\mathbf{r}_i\|^3 = \|\mathbf{r}_i\|^{2+1}$，是 Coulomb 衰減和方向歸一化的**聯合效應**，不是什麼新的三次方衰減定律。

> **結論：** 分母的三次方不代表場以 $1/r^3$ 衰減。場仍然以 $1/r^2$ 衰減（Coulomb 定律），三次方只是因為我們把方向向量 $\mathbf{u}_i$ 和距離 $r_i$ 合併書寫在同一個分數裡。

### 4.3 寫成矩陣形式

把 6 個磁荷的場加起來：

$$
\mathbf{B} = \sum_{i=1}^{6} \frac{k_m \, q_i}{\ell^2} \cdot \frac{\hat{\mathbf{r}}_i}{\|\hat{\mathbf{r}}_i\|^3}
= \frac{k_m}{\ell^2} \sum_{i=1}^{6} \frac{\hat{\mathbf{r}}_i}{\|\hat{\mathbf{r}}_i\|^3} \, q_i
$$

這個求和可以寫成矩陣乘法：

$$
\boxed{
\mathbf{B}(\hat{\mathbf{p}},\, \mathbf{b})
= \frac{k_m}{\ell^2} \; \hat{\mathbf{R}}(\hat{\mathbf{p}},\, \mathbf{b}) \; \mathbf{Q}
}
\tag{2.3}
$$

### 4.4 $\hat{\mathbf{R}}$ 矩陣的結構

$\hat{\mathbf{R}}$ 是 $3 \times 6$ 矩陣，**每一列**對應一個磁荷：

$$
\hat{\mathbf{R}} = \begin{bmatrix}
\dfrac{\hat{\mathbf{r}}_1}{\|\hat{\mathbf{r}}_1\|^3} &
\dfrac{\hat{\mathbf{r}}_2}{\|\hat{\mathbf{r}}_2\|^3} &
\dfrac{\hat{\mathbf{r}}_3}{\|\hat{\mathbf{r}}_3\|^3} &
\dfrac{\hat{\mathbf{r}}_4}{\|\hat{\mathbf{r}}_4\|^3} &
\dfrac{\hat{\mathbf{r}}_5}{\|\hat{\mathbf{r}}_5\|^3} &
\dfrac{\hat{\mathbf{r}}_6}{\|\hat{\mathbf{r}}_6\|^3}
\end{bmatrix}_{3 \times 6}
$$

矩陣乘法 $\hat{\mathbf{R}} \, \mathbf{Q}$ 就是：

$$
\hat{\mathbf{R}} \, \mathbf{Q}
= \frac{\hat{\mathbf{r}}_1}{\|\hat{\mathbf{r}}_1\|^3} q_1
+ \frac{\hat{\mathbf{r}}_2}{\|\hat{\mathbf{r}}_2\|^3} q_2
+ \cdots
+ \frac{\hat{\mathbf{r}}_6}{\|\hat{\mathbf{r}}_6\|^3} q_6
$$

正好就是我們要的疊加。

### 4.5 各符號在 Eq. 2.3 中的角色

| 符號 | 大小 | 名稱 | 角色 |
|------|------|------|------|
| $k_m / \ell^2$ | 標量 | — | 控制場的整體幅度 |
| $\hat{\mathbf{R}}(\hat{\mathbf{p}},\, \mathbf{b})$ | $3 \times 6$ | Charge-Bead Distribution Matrix | 純幾何量，取決於磁珠位置和磁荷位置 |
| $\mathbf{Q} = [q_1, \dots, q_6]^T$ | $6 \times 1$ | Charge Vector | 純磁學量，取決於各極的磁通量 |

**核心思想：場 $=$ 幅度 $\times$ 幾何分佈 $\times$ 磁荷強度，三者解耦。**

---

## 5. Eq. 2.4：電流 → 磁荷

### 5.1 方程

$$
\boxed{
\mathbf{Q} = \frac{\boldsymbol{\Phi}}{\mu_0}
= \frac{N_c}{\mu_0 \, \mathcal{R}_a} \, \mathbf{K}_I \, \mathbf{I}
}
\tag{2.4}
$$

### 5.2 逐步推導

**Step 1：磁動力 (Magnetomotive Force, MMF)**

$$
\mathcal{F}_i = N_c \, I_i
$$

- $N_c = 70$（每個線圈的匝數）
- $I_i$ $=$ 第 $i$ 個線圈的電流 [A]
- $\mathcal{F}_i$ $=$ 磁動力 [A·turns]，驅動磁通流動的「電壓」
- 類比電路：EMF（電壓）驅動電流

**Step 2：Hopkinson's Law（磁路版 Ohm 定律）**

對**單一**磁路：

$$
\Phi = \frac{\mathcal{F}}{\mathcal{R}_a}
$$

- $\mathcal{R}_a$ $=$ 空氣磁阻 [A/Wb]，等價於電路中的電阻
- 類比：$I = V/R \;\longleftrightarrow\; \Phi = \mathcal{F}/\mathcal{R}_a$

但我們的系統有 6 根極頭通過磁軛環連接，不是單一迴路。每根極的磁通不只由自己的線圈決定，還受其他 5 根極的影響。

**Step 3：引入耦合矩陣 $\mathbf{K}_I$**

$$
\boldsymbol{\Phi}
= \frac{1}{\mathcal{R}_a} \, \mathbf{K}_I \,
\begin{bmatrix} N_c I_1 \\ N_c I_2 \\ \vdots \\ N_c I_6 \end{bmatrix}
= \frac{N_c}{\mathcal{R}_a} \, \mathbf{K}_I \, \mathbf{I}
$$

$\mathbf{K}_I$ 是 $6 \times 6$ 矩陣，描述 6 根極之間的磁通耦合。

**Step 4：磁通 → 磁荷（用 Eq. 2.1）**

$$
\mathbf{Q} = \frac{\boldsymbol{\Phi}}{\mu_0}
= \frac{N_c}{\mathcal{R}_a} \cdot \frac{\mathbf{K}_I \, \mathbf{I}}{\mu_0}
= \frac{N_c}{\mu_0 \, \mathcal{R}_a} \, \mathbf{K}_I \, \mathbf{I}
\quad \checkmark \;\text{得到 Eq. 2.4}
$$

### 5.3 符號定義

| 符號 | 值/大小 | 意義 | 單位 |
|------|---------|------|------|
| $N_c$ | 70 | 線圈匝數 | — |
| $\mathcal{R}_a$ | 待擬合 | 空氣集總磁阻（極頭 → WP 中心）| A/Wb |
| $\mathbf{K}_I$ | $6 \times 6$ | Flux Distribution Matrix（磁通分配矩陣）| — |
| $\mathbf{I} = [I_1, \dots, I_6]^T$ | $6 \times 1$ | 輸入電流向量 | A |
| $\boldsymbol{\Phi} = [\Phi_1, \dots, \Phi_6]^T$ | $6 \times 1$ | 磁通量向量 | Wb |
| $\mathbf{Q} = [q_1, \dots, q_6]^T$ | $6 \times 1$ | 磁荷向量 | A·m |

### 5.4 磁路類比

$$
\underbrace{I = \frac{V}{R}}_{\text{電路 Ohm's law}}
\quad \longleftrightarrow \quad
\underbrace{\Phi = \frac{\mathcal{F}}{\mathcal{R}_a}}_{\text{磁路 Hopkinson's law}}
$$

但 6 極耦合 → 不能用單一 Ohm's law → 需要矩陣 $\mathbf{K}_I$ 描述耦合。

類比：電路中有 6 個電壓源通過共同電阻網絡連接，每個節點的電流取決於所有電壓源，需要用矩陣（阻抗矩陣的逆）來描述。

---

## 6. $\mathbf{K}_I$ 矩陣的物理意義

### 6.1 理想對稱的 $\mathbf{K}_I$（Eq. 2.8）

$$
\mathbf{K}_I = \begin{bmatrix}
 \frac{5}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} \\[4pt]
-\frac{1}{6} &  \frac{5}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} \\[4pt]
-\frac{1}{6} & -\frac{1}{6} &  \frac{5}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} \\[4pt]
-\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} &  \frac{5}{6} & -\frac{1}{6} & -\frac{1}{6} \\[4pt]
-\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} &  \frac{5}{6} & -\frac{1}{6} \\[4pt]
-\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} & -\frac{1}{6} &  \frac{5}{6}
\end{bmatrix}
\tag{2.8}
$$

### 6.2 用具體例子理解

假設只有 Coil 1 通電：$\mathbf{I} = [1,\, 0,\, 0,\, 0,\, 0,\, 0]^T$

$$
\mathbf{K}_I \, \mathbf{I} = \text{第一列} = \left[\frac{5}{6},\; -\frac{1}{6},\; -\frac{1}{6},\; -\frac{1}{6},\; -\frac{1}{6},\; -\frac{1}{6}\right]^T
$$

| 極 | 磁通比例 | 意義 |
|----|----------|------|
| P1 | $+5/6$ | 磁通主要從 P1 極頭「射出」（N 極）|
| P2 | $-1/6$ | 磁通從 P2 極頭「回流」（S 極）|
| P3 | $-1/6$ | 同上 |
| P4 | $-1/6$ | 同上 |
| P5 | $-1/6$ | 同上 |
| P6 | $-1/6$ | 同上 |

### 6.3 為什麼是 $5/6$ 和 $-1/6$？

來自磁路分析（出自 Zhang 2010 [53]）：

> **前提：** 6 根極頭都連接在同一個磁軛環上，假設磁軛磁阻 $\ll$ 空氣磁阻

激勵 Coil 1 時：
1. 產生的磁動力 $\mathcal{F}_1 = N_c I_1$ 驅動磁通從 P1 出發
2. 磁通必須形成封閉迴路（磁通守恆，$\nabla \cdot \mathbf{B} = 0$）
3. 通過磁軛「均勻」分配到其他 5 根極回流
4. 每根回流極分到 $1/6$ 的磁通（6 個極，對稱分配）

因此：

$$
\text{P1 自己的淨磁通} = 1 - \frac{1}{6} = \frac{5}{6}
$$

$$
\text{其他每根極的磁通} = -\frac{1}{6} \quad (\text{負號 = 方向相反，是回流})
$$

### 6.4 $\mathbf{K}_I$ 的關鍵性質

**性質 1：每行加總 $= 0$（磁通守恆）**

$$
\frac{5}{6} + 5 \times \left(-\frac{1}{6}\right) = \frac{5}{6} - \frac{5}{6} = 0
$$

所有極的磁通代數和為零（有出必有回）。

**性質 2：對稱矩陣**

$$
\mathbf{K}_I = \mathbf{K}_I^T
$$

互易性：Coil $j$ 對 Pole $i$ 的耦合 $=$ Coil $i$ 對 Pole $j$ 的耦合。

**性質 3：可以分解為**

$$
\mathbf{K}_I = \mathbf{I}_{6 \times 6} - \frac{1}{6} \, \mathbf{1}_{6 \times 6}
$$

其中 $\mathbf{I}_{6 \times 6}$ 是單位矩陣，$\mathbf{1}_{6 \times 6}$ 是全 1 矩陣。

驗證：對角項 $1 - 1/6 = 5/6$ ✓，非對角項 $0 - 1/6 = -1/6$ ✓

**性質 4：奇異矩陣**

因為每行加總 $= 0$，所以 $[1,1,1,1,1,1]^T$ 是零特徵向量。

物理意義：如果所有電流相等，則所有極的淨磁通 $= 0$（全部出 $=$ 全部入）。

### 6.5 真實 vs 理想 $\mathbf{K}_I$

| | 對角項（下層）| 對角項（上層）| 比值 |
|---|---|---|---|
| 理想 $\mathbf{K}_I$（Eq. 2.8） | $5/6 \approx 0.833$ | $5/6 \approx 0.833$ | 1.00 |
| 論文校準 $\hat{\mathbf{K}}_I$（Eq. 2.19）| P1=0.60, P3=0.63, P6=0.61 | P2=0.93, P4=0.90, P5=0.90 | ~1.50 |
| 我們 FEM（WP 中心 $|\mathbf{B}|$）| 8.69, 8.63, 8.76 mT | 8.95, 8.91, 8.93 mT | ~1.03 |

我們的 FEM 幾何近似理想，3% 差異來自上下層極長不同（42 vs 45 mm）。論文中 50% 的差異還包含了加工時下層極被銑平移除材料的影響。

---

## 7. 擬合 $\ell$ 和 $\mathcal{R}_a$

### 7.1 為什麼需要擬合

Eq. 2.3 + 2.4 構成了完整的解析模型：

$$
\mathbf{B}^{\text{model}}(\mathbf{p})
= \frac{k_m}{\ell^2} \; \hat{\mathbf{R}}\!\left(\frac{\mathbf{p}}{\ell}\right) \cdot \frac{N_c}{\mu_0 \, \mathcal{R}_a} \, \mathbf{K}_I \, \mathbf{I}
$$

其中 $\mathbf{K}_I$ 用理論值 (Eq. 2.8)，$\mathbf{I}$ 已知（單位激勵），但 $\ell$ 和 $\mathcal{R}_a$ 是未知的，需要用 FEM 數據來確定。

### 7.2 兩個參數各自的角色

$\ell$ **影響兩件事：**

$$
\underbrace{\frac{1}{\ell^2}}_{\text{(a) 場的整體幅度}} \quad \times \quad
\underbrace{\hat{\mathbf{R}}\!\left(\frac{\mathbf{p}}{\ell}\right)}_{\text{(b) 場的空間形狀}}
$$

> 改變 $\ell$ 會改變歸一化座標 $\hat{\mathbf{p}} = \mathbf{p}/\ell$，從而改變場隨空間變化的模式。

$\mathcal{R}_a$ **只影響一件事：**

$$
\frac{1}{\mathcal{R}_a} \quad \longrightarrow \quad \text{場的整體幅度}
$$

合併看幅度部分：

$$
|\mathbf{B}| \;\propto\; \frac{k_m \, N_c}{\ell^2 \, \mu_0 \, \mathcal{R}_a}
$$

就幅度而言，$\ell^2 \cdot \mathcal{R}_a$ 是一組（增大 $\ell$ 可用減小 $\mathcal{R}_a$ 補償）。但因為 $\ell$ 還影響**形狀**，所以兩個參數可以被分離。

> **直覺：** 先靠「形狀」定 $\ell$（場的空間衰減模式鎖定 $\ell$），再靠「幅度」定 $\mathcal{R}_a$。

### 7.3 $\ell$ 和 $\mathcal{R}_a$ 的部分耦合 — 直覺理解

#### 7.3.1 燈泡類比——最直覺的理解方式

想像你在黑暗房間裡，有一盞燈。你拿著亮度計在不同位置量亮度，想反推兩件事：

- **燈泡的瓦數**（多亮）$\longleftrightarrow$ 類比 $\mathcal{R}_a$（磁阻越小 $\to$ 磁荷越強 $\to$ 場越大）
- **燈泡離你多遠** $\longleftrightarrow$ 類比 $\ell$（等效磁荷到 WP 中心的距離）

你量到的亮度 $=$ 瓦數 $/$ 距離$^2$。

**如果你只在一個位置量**，你無法區分：

- 「一盞**暗燈**在**近處**」 vs 「一盞**亮燈**在**遠處**」

兩者給出完全相同的讀數。這就是**耦合**——兩個參數不可分。

**但如果你在很多不同位置量**，兩種情況的**衰減模式**不同：

- 近燈：走幾步亮度**劇烈變化**（$1/r^2$ 衰減快）
- 遠燈：走幾步亮度**變化不大**（$1/r^2$ 衰減慢）

這個空間衰減的快慢鎖定了距離，然後再用絕對亮度反推瓦數。

回到我們的問題：

| 參數 | 控制什麼 | 燈泡類比 |
|------|---------|---------|
| $\ell$ | 場的空間衰減模式 **+** 場的幅度 | 燈泡的距離 |
| $\mathcal{R}_a$ | **只有**場的幅度 | 燈泡的瓦數 |

「部分耦合」$=$ 兩者都影響幅度，但**只有 $\ell$ 影響空間形狀**。所以用多點數據可以分離。

#### 7.3.2 數學上的精確表述

將模型拆成兩部分：

$$
\mathbf{B}^{\text{model}}(\mathbf{p})
= \underbrace{\frac{k_m \, N_c}{\mu_0 \, \ell^2 \, \mathcal{R}_a}}_{\displaystyle A(\ell,\, \mathcal{R}_a)}
\;\times\;
\underbrace{\hat{\mathbf{R}}\!\left(\frac{\mathbf{p}}{\ell}\right) \mathbf{K}_I \, \mathbf{I}}_{\displaystyle \mathbf{S}(\mathbf{p};\, \ell)}
$$

- **幅度因子** $A$：包含 $\ell$ 和 $\mathcal{R}_a$（以乘積 $\ell^2 \cdot \mathcal{R}_a$ 出現）
- **形狀函數** $\mathbf{S}$：**只包含 $\ell$**，不含 $\mathcal{R}_a$

**耦合來源：** 在 $A$ 中，$\ell^2 \cdot \mathcal{R}_a$ 是一組——增大 $\ell$ 可以用減小 $\mathcal{R}_a$ 補償，幅度不變。

**解耦機制：** $\mathbf{S}$ 只含 $\ell$。兩個不同位置的場強比值：

$$
\frac{|\mathbf{B}(\mathbf{p}_1)|}{|\mathbf{B}(\mathbf{p}_2)|} = \frac{|\mathbf{S}(\mathbf{p}_1;\, \ell)|}{|\mathbf{S}(\mathbf{p}_2;\, \ell)|}
$$

比值中 $A$ 被消掉了，**只取決於 $\ell$，與 $\mathcal{R}_a$ 完全無關**。

#### 7.3.3 對擬合過程的實際影響

| 情況 | 影響 |
|------|------|
| 數據只在 WP 正中心一個點 | **無法擬合**——$\ell$ 和 $\mathcal{R}_a$ 完全不可分 |
| 數據在很小的區域（$\ll \ell$）| 擬合不穩定——場幾乎均勻，$\ell$ 的形狀效應很弱 |
| 數據跨越 $\sim 2\ell$ 範圍 | **可以良好分離**——這是我們的情況 |
| 數據從中心延伸到極頭附近 | 最理想——衰減模式完全暴露 |

我們的 WP 數據範圍 $\pm 2$ mm，$\ell \approx 0.9$ mm $\to$ 數據覆蓋了約 $4\ell$ 的範圍。
論文報告的擬合誤差 $< 1\%$ 也證實了分離性良好。

實際操作：用 MATLAB 的 `lsqnonlin` 同時擬合兩個參數即可，不需要特殊處理。

#### 7.3.4 擬合的物理意義 vs 數學形式

這個擬合**不是**純粹的數學遊戲，但參數**也不是**可以直接測量的物理量。

**有物理意義的部分：**

| 方面 | 為什麼是物理的 |
|------|--------------|
| 模型結構（Coulomb + 磁路）| 基於電磁學基本定律，不是任意假設的函數形式 |
| $\ell = 900\;\mu\text{m}$ 的值 | 可解釋：等效磁荷在極頭**後方**（$> 500\;\mu\text{m}$ 的物理尖端距離），因為真實極頭有 40 $\mu$m 曲面半徑，磁通從整個表面擴散而非一個點發出 |
| $\mathcal{R}_a = 6.3 \times 10^8$ A/Wb | 對應極頭到 WP 的空氣磁阻，原則上可從幾何計算（但因極頭形狀複雜，擬合更準確）|
| $< 1\%$ 擬合誤差 | 驗證了點電荷假設的正確性——隨便湊的數學模型，用 2 個參數擬合幾千個節點的 3D 向量場，不可能達到 $< 1\%$ |

**是等效參數的部分：**

| 方面 | 為什麼是等效的 |
|------|--------------|
| $\ell$ 的值 | 你不能說「磁荷就在離中心 900 $\mu$m 的地方」——那裡什麼都沒有。它是讓簡化模型最佳近似 FEM 的**數學最佳位置** |
| $\mathcal{R}_a$ 的值 | 真實磁路不是集總電路，空氣中的磁通分佈是三維的。$\mathcal{R}_a$ 是把複雜的分佈式磁阻**等效成一個數字** |
| 兩者不可獨立測量 | 你無法用物理儀器分別量出 $\ell$ 和 $\mathcal{R}_a$——它們只能通過擬合同時確定 |

#### 7.3.5 一句話總結

> 這個擬合操作是：**用 2 個有物理意義的等效參數，讓一個有物理基礎的簡化模型，去逼近嚴格的 FEM 解。**
> 模型的正確性由 $< 1\%$ 的擬合誤差驗證；參數的物理意義由它們的可解釋性支撐。

### 7.4 擬合的具體步驟

#### 輸入

- ANSYS FEM 結果：workspace 區域 $N$ 個節點的 $\mathbf{B}_j^{\text{FEM}}$（$3 \times 1$ 向量）
- 對應的節點位置 $\mathbf{p}_j$（$3 \times 1$）
- 6 個磁荷的角度位置（由極頭幾何決定）
- 電流 $\mathbf{I} = [1,0,0,0,0,0]^T$（Coil 1 激勵）
- $\mathbf{K}_I = \text{nominal}$（Eq. 2.8）

#### 待定參數

$$
\ell \;(\text{workspace 半徑}), \quad \mathcal{R}_a \;(\text{空氣磁阻})
$$

#### 對每個節點 $j$，計算模型預測 $\mathbf{B}_j^{\text{model}}(\ell,\, \mathcal{R}_a)$

**Step 1：** 計算 6 個磁荷的位置（以 $\ell$ 為參數）

每個磁荷在以 WP 中心為原點的球面上，距離 $= \ell$：

$$
\mathbf{c}_i = \ell \,
\begin{bmatrix}
\cos\theta_i \sin\alpha \\
\sin\theta_i \sin\alpha \\
\pm \cos\alpha
\end{bmatrix}
$$

其中 $\theta_i$ 是極的方位角，$\alpha$ 是極軸與 $z$ 軸的夾角，$+$ 代表上層，$-$ 代表下層。

**Step 2：** 計算 $\hat{\mathbf{R}}$ 矩陣

$$
\hat{\mathbf{r}}_i = \frac{\mathbf{p}_j - \mathbf{c}_i}{\ell}, \qquad
\hat{\mathbf{R}} \text{ 第 } i \text{ 列} = \frac{\hat{\mathbf{r}}_i}{\|\hat{\mathbf{r}}_i\|^3}
$$

**Step 3：** 計算磁荷向量 $\mathbf{Q}$

$$
\mathbf{Q} = \frac{N_c}{\mu_0 \, \mathcal{R}_a} \, \mathbf{K}_I \, \mathbf{I}
= \frac{70}{\mu_0 \, \mathcal{R}_a} \left[\frac{5}{6},\; -\frac{1}{6},\; -\frac{1}{6},\; -\frac{1}{6},\; -\frac{1}{6},\; -\frac{1}{6}\right]^T
$$

**Step 4：** 計算模型預測

$$
\mathbf{B}_j^{\text{model}} = \frac{k_m}{\ell^2} \; \hat{\mathbf{R}}_j \; \mathbf{Q}
$$

#### 目標函數（最小平方）

$$
J(\ell,\, \mathcal{R}_a) = \sum_{j=1}^{N} \left\| \mathbf{B}_j^{\text{FEM}} - \mathbf{B}_j^{\text{model}}(\ell,\, \mathcal{R}_a) \right\|^2
$$

$\mathbf{B}$ 是 $3 \times 1$ 向量，所以每個節點的誤差有 3 個分量（$x, y, z$）。

#### 最小化

用 MATLAB 的 `fminsearch` / `lsqnonlin` 最小化 $J(\ell, \mathcal{R}_a)$ → 得到最佳的 $\ell^*$ 和 $\mathcal{R}_a^*$。

### 7.5 擬合結果

$$
\ell^* = 900 \;\mu\text{m}, \qquad \mathcal{R}_a^* = 6.3 \times 10^8 \;\text{A/Wb}
$$

驗證 (Fig. 2.6)：
- (a) FEM 向量 vs 模型向量：方向和大小幾乎重合
- (b) 歸一化誤差範數：$\|\mathbf{B}^{\text{FEM}} - \mathbf{B}^{\text{model}}\| \,/\, \|\mathbf{B}^{\text{FEM}}\| < 1\%$（大部分節點）

### 7.6 $\ell = 900\;\mu\text{m}$ 的物理解釋

| | 值 | 意義 |
|---|---|---|
| 物理尖端距離 | 500 μm | 幾何設計值（CAD 中極頭到 WP 中心）|
| 擬合等效距離 $\ell$ | 900 μm | 等效磁荷的最佳位置 |

差異原因：
- 真實極頭不是數學上的「點」，而是半徑 40 μm 的曲面
- 磁通從整個尖端表面擴散，不是從一個點發射
- 等效磁荷的最佳位置在極頭**後方**（更深入極體內部）

> $\ell$ 是一個「擬合參數」，不是物理距離。它讓簡化的點電荷模型最好地近似複雜的 FEM 場分佈。

---

## 8. 提取 $\mathbf{K}_I^{\text{FEM}}$ 矩陣

### 8.1 這是什麼意思

論文中的 $\mathbf{K}_I$ (Eq. 2.8) 是**理論值**（假設完美對稱的磁路）。但實際裝置的上下層極不對稱（下層被銑平），$\mathbf{K}_I$ 也不對稱。

「提取 $\mathbf{K}_I^{\text{FEM}}$」$=$ 用我們 6 個 coil 的 FEM 模擬結果，**反算出 FEM 模型對應的實際 $\mathbf{K}_I$ 矩陣**。

### 8.2 原理推導

在 WP 中心 $\mathbf{p} = \mathbf{0}$ 時，Eq. 2.3 簡化。因為所有磁荷到中心的距離都等於 $\ell$：

$$
\mathbf{r}_i = \mathbf{0} - \mathbf{c}_i = -\mathbf{c}_i
$$

$$
\|\mathbf{r}_i\| = \|\mathbf{c}_i\| = \ell
$$

$$
\hat{\mathbf{r}}_i = \frac{\mathbf{r}_i}{\ell} = \frac{-\mathbf{c}_i}{\ell} = -\hat{\mathbf{c}}_i
$$

$$
\|\hat{\mathbf{r}}_i\| = 1
$$

$\hat{\mathbf{R}}$ 在中心的第 $i$ 列：

$$
\frac{\hat{\mathbf{r}}_i}{\|\hat{\mathbf{r}}_i\|^3} = \frac{-\hat{\mathbf{c}}_i}{1^3} = -\hat{\mathbf{c}}_i
$$

所以：

$$
\hat{\mathbf{R}}(\mathbf{0}) = \begin{bmatrix} -\hat{\mathbf{c}}_1 & -\hat{\mathbf{c}}_2 & -\hat{\mathbf{c}}_3 & -\hat{\mathbf{c}}_4 & -\hat{\mathbf{c}}_5 & -\hat{\mathbf{c}}_6 \end{bmatrix}_{3 \times 6}
$$

這是**已知的**矩陣（純由 6 根極的角度位置決定）。

### 8.3 建立方程

對第 $n$ 個 coil 激勵（$\mathbf{I} = \mathbf{e}_n$，第 $n$ 個分量為 1，其餘為 0）：

$$
\mathbf{B}_{\text{center}}^{(n)}
= \frac{k_m}{\ell^2} \; \hat{\mathbf{R}}(\mathbf{0}) \cdot \frac{N_c}{\mu_0 \, \mathcal{R}_a} \, \mathbf{K}_I \, \mathbf{e}_n
= \alpha \; \hat{\mathbf{R}}(\mathbf{0}) \; \mathbf{K}_I[:,n]
$$

其中：

$$
\alpha = \frac{k_m \, N_c}{\ell^2 \, \mu_0 \, \mathcal{R}_a} \quad (\text{所有 coil 共用的常數標量})
$$

把 6 個 coil 的結果排成矩陣：

$$
\underbrace{\begin{bmatrix} \mathbf{B}^{(1)} & \mathbf{B}^{(2)} & \cdots & \mathbf{B}^{(6)} \end{bmatrix}}_{3 \times 6,\;\text{FEM 結果}}
= \alpha \; \hat{\mathbf{R}}(\mathbf{0}) \; \mathbf{K}_I
$$

### 8.4 求解 $\mathbf{K}_I$

$$
\mathbf{K}_I = \frac{1}{\alpha} \; \hat{\mathbf{R}}(\mathbf{0})^{+} \; \mathbf{B}_{\text{matrix}}
$$

其中 $\hat{\mathbf{R}}(\mathbf{0})^{+}$ 是 $3 \times 6$ 矩陣的偽逆（pseudo-inverse）。

> **注意：** 需要先做第 7 節的擬合（得到 $\ell$ 和 $\mathcal{R}_a$）才能算 $\alpha$。
> 或者，可以用 $\mathbf{K}_I$ 的約束性質（每行加總 $= 0$、$\text{trace}$ 值）來消除 $\alpha$。

### 8.5 不做完整擬合也可以做的定性驗證

用 WP 中心場的**比值**驗證上下層對稱性：

| Coil | 論文極名 | 層 | WP 中心 $|\mathbf{B}|$ |
|------|----------|----|------------------------|
| 1 | P1 | 下 | 8.691 mT |
| 2 | P3 | 下 | 8.633 mT |
| 3 | P6 | 下 | 8.759 mT |
| 4 | P5 | 上 | 8.951 mT |
| 5 | P2 | 上 | 8.908 mT |
| 6 | P4 | 上 | 8.929 mT |

$$
\text{上/下比值} = \frac{\bar{B}_{\text{upper}}}{\bar{B}_{\text{lower}}} = \frac{8.93}{8.69} = 1.03
$$

| 來源 | 比值 | 說明 |
|------|------|------|
| 理想 $\mathbf{K}_I$ | 1.00 | 完全對稱 |
| 論文校準 $\hat{\mathbf{K}}_I$ | ~1.52 | 嚴重不對稱（下層被銑平）|
| 我們 FEM | 1.03 | 微小不對稱（FEM 幾何近似理想）|

---

## 9. 整體邏輯串聯

### 9.1 從電流到磁場

$$
\underset{6 \times 1}{\mathbf{I}}
\;\xrightarrow{\;\text{Eq. 2.4}\;}\;
\underset{6 \times 1}{\mathbf{Q}}
\;\xrightarrow{\;\text{Eq. 2.3}\;}\;
\underset{3 \times 1}{\mathbf{B}(\mathbf{p})}
$$

展開：

$$
\mathbf{Q} = \frac{N_c}{\mu_0 \, \mathcal{R}_a} \, \mathbf{K}_I \, \mathbf{I}
\qquad \text{(電流 → 磁動力 → 磁路 → 磁通 → 磁荷)}
$$

$$
\mathbf{B} = \frac{k_m}{\ell^2} \, \hat{\mathbf{R}}(\hat{\mathbf{p}}) \, \mathbf{Q}
\qquad \text{(6 個 Coulomb 場疊加)}
$$

### 9.2 從磁場到力（Eq. 2.5-2.7，後續章節）

$$
\mathbf{B}(\mathbf{p})
\;\xrightarrow{\;\text{Eq. 2.5-2.6}\;}\;
\mathbf{F}
$$

梯度力：

$$
\mathbf{F} = \frac{1}{2} \nabla (\mathbf{m} \cdot \mathbf{B})
$$

寫成二次型 (Eq. 2.6)：

$$
F_i(\hat{\mathbf{p}},\, \boldsymbol{\Phi}) = \frac{f_\Phi}{\mu_0^2} \; \boldsymbol{\Phi}^T \, \mathbf{L}_i(\hat{\mathbf{p}}) \, \boldsymbol{\Phi}, \quad i = x, y, z
$$

合併所有步驟 → current-based force model (Eq. 2.7)：

$$
\boxed{
F_i(\hat{\mathbf{p}},\, \mathbf{I}) = g_I \; \mathbf{I}^T \, \mathbf{K}_I^T \, \mathbf{L}_i(\hat{\mathbf{p}}) \, \mathbf{K}_I \, \mathbf{I}, \quad i = x, y, z
}
\tag{2.7}
$$

> 力是電流的**二次型** (quadratic form)，正比於電流的平方。

### 9.3 模型中的三類參數

| 類別 | 參數 | 來源 |
|------|------|------|
| **幾何（已知）** | 極頭角度、層別、$N_c = 70$ | CAD 設計 |
| **FEM 擬合（2 個）** | $\ell = 900\;\mu\text{m}$，$\mathcal{R}_a = 6.3 \times 10^8$ A/Wb | 最小平方擬合 |
| **磁珠性質（1 個）** | $g_I$（或 $f_Q$, $f_\Phi$）| 力校準實驗 |

> 只需要 **3 個參數** 就能完整描述「電流 → 磁場 → 力」的關係。這就是解析模型的威力。

---

## 10. 完整 Notation 表

### 10.1 基本物理常數

| 符號 | 值 | 意義 | 單位 |
|------|------|------|------|
| $\mu_0$ | $4\pi \times 10^{-7}$ | 真空磁導率 | T·m/A |
| $k_m$ | $\mu_0/(4\pi) = 10^{-7}$ | 磁學 Coulomb 常數 | N/A² |

### 10.2 裝置幾何參數

| 符號 | 值 | 意義 | 單位 |
|------|------|------|------|
| $N_c$ | 70 | 每個線圈的匝數 | — |
| $\ell$（code: `rho`）| 900（擬合值）| 等效磁荷到 WP 中心距離（workspace 半徑）| μm |
| $\mathcal{R}_a$ | $6.3 \times 10^8$（擬合值）| 空氣集總磁阻 | A/Wb |
| — | 500 | 物理尖端到 WP 中心距離 | μm |
| — | 40 | 極頭半徑 | μm |
| $I_{\max}$ | 3 | 最大線圈電流 | A |

### 10.3 向量和位置

| 符號 | 大小 | 意義 | 單位 |
|------|------|------|------|
| $\mathbf{p} = [x,y,z]^T$ | $3 \times 1$ | 磁珠位置 | m |
| $\hat{\mathbf{p}} = \mathbf{p}/\ell$ | $3 \times 1$ | 無量綱位置 | — |
| $\mathbf{c}_i$ | $3 \times 1$ | 第 $i$ 個磁荷的空間位置 | m |
| $\hat{\mathbf{c}}_i = \mathbf{c}_i / \|\mathbf{c}_i\|$ | $3 \times 1$ | 第 $i$ 個磁荷的方向單位向量 | — |
| $\mathbf{b}_i$ | $3 \times 1$ | 第 $i$ 個磁荷的偏置向量（偏離理想位置的修正）| m |
| $\mathbf{b} = [\mathbf{b}_1;\dots;\mathbf{b}_6]$ | $18 \times 1$ | 6 個偏置向量的串聯 | m |
| $\mathbf{r}_i = \mathbf{p} - \mathbf{c}_i$ | $3 \times 1$ | 磁荷 $i$ → 磁珠的位移向量 | m |
| $\hat{\mathbf{r}}_i = \mathbf{r}_i / \ell$ | $3 \times 1$ | 無量綱位移 | — |
| $\mathbf{u}_i = \mathbf{r}_i / \|\mathbf{r}_i\|$ | $3 \times 1$ | 單位方向向量 | — |

### 10.4 磁學量

| 符號 | 大小 | 意義 | 單位 |
|------|------|------|------|
| $\mathbf{I} = [I_1, \dots, I_6]^T$ | $6 \times 1$ | 輸入電流向量 | A |
| $\hat{\mathbf{I}} = \mathbf{I} / I_{\max}$ | $6 \times 1$ | 歸一化電流 | — |
| $\mathcal{F}_i = N_c I_i$ | 標量 | 第 $i$ 個線圈的磁動力 (MMF) | A·turns |
| $\Phi_i$ | 標量 | 第 $i$ 根極頭的磁通量 | Wb |
| $\boldsymbol{\Phi} = [\Phi_1, \dots, \Phi_6]^T$ | $6 \times 1$ | 磁通量向量 | Wb |
| $q_i = \Phi_i / \mu_0$ | 標量 | 第 $i$ 根極頭的等效磁荷 | A·m |
| $\mathbf{Q} = [q_1, \dots, q_6]^T$ | $6 \times 1$ | 磁荷向量 | A·m |
| $\mathbf{B}_i$ | $3 \times 1$ | 第 $i$ 個磁荷在磁珠處產生的場 | T |
| $\mathbf{B}$ | $3 \times 1$ | 總磁通量密度（6 個磁荷疊加）| T |

### 10.5 矩陣

| 符號 | 大小 | 名稱 | 定義式 |
|------|------|------|--------|
| $\mathbf{K}_I$ | $6 \times 6$ | Flux Distribution Matrix | $\mathbf{Q} = \dfrac{N_c}{\mu_0 \mathcal{R}_a} \mathbf{K}_I \mathbf{I}$ |
| $\hat{\mathbf{R}}$ | $3 \times 6$ | Charge-Bead Distribution Matrix | 第 $i$ 列 $= \hat{\mathbf{r}}_i / \|\hat{\mathbf{r}}_i\|^3$ |
| $\mathbf{L}_x,\, \mathbf{L}_y,\, \mathbf{L}_z$ | 各 $6 \times 6$ | Charge-Bead Gradient Matrix | $\nabla(\hat{\mathbf{R}}^T \hat{\mathbf{R}})$ 的分量 |

### 10.6 $\mathbf{K}_I$ 矩陣元素

| 元素位置 | 理想值 | 物理意義 |
|----------|--------|----------|
| 對角項 $K_I(i,i)$ | $5/6 \approx 0.833$ | 激勵第 $i$ 極時，自身保留的磁通比例 |
| 非對角項 $K_I(i,j)$ | $-1/6 \approx -0.167$ | 激勵第 $j$ 極時，第 $i$ 極的回流磁通比例 |
| 每行加總 | 0 | 磁通守恆 |

### 10.7 力學量

| 符號 | 意義 | 定義 |
|------|------|------|
| $f_Q$ | Magnetic Charge Force Gain | $\dfrac{3V(\mu - \mu_0) k_m^2}{2\mu_0(\mu + 2\mu_0) \ell^4}$ |
| $f_\Phi$ | Magnetic Flux Force Gain | $f_Q \cdot \mu_0^2$ |
| $g_I$ | Current-based Force Gain | $f_\Phi \cdot \left(\dfrac{N_c}{\mu_0 \mathcal{R}_a}\right)^2 \cdot \dfrac{1}{\ell}$ |
| $F_N$ | Normalized Force Gain | $g_I \cdot I_{\max}^2$ |
| $\hat{F}$ | 無量綱力 | $F / F_N$ |
| $V$ | 磁珠體積 | m³ |
| $\mu$ | 磁珠磁導率 | T·m/A |

### 10.8 方程索引

| 編號 | 方程 | 一句話總結 |
|------|------|-----------|
| 2.1 | $q_i = \Phi_i / \mu_0$ | 磁通 → 磁荷 |
| 2.2 | $\mathbf{B}_i = k_m \, q_i \, \mathbf{r}_i \,/\, \|\mathbf{r}_i\|^3$ | 單磁荷 Coulomb 場 |
| 2.3 | $\mathbf{B} = (k_m / \ell^2) \, \hat{\mathbf{R}} \, \mathbf{Q}$ | 6 磁荷疊加（矩陣形式）|
| 2.4 | $\mathbf{Q} = N_c / (\mu_0 \mathcal{R}_a) \cdot \mathbf{K}_I \mathbf{I}$ | 電流 → 磁荷（Hopkinson）|
| 2.5 | $\mathbf{F} = f_Q \, \nabla(\mathbf{Q}^T \hat{\mathbf{R}}^T \hat{\mathbf{R}} \, \mathbf{Q})$ | 梯度力（通用形式）|
| 2.6 | $F_i = (f_\Phi / \mu_0^2) \, \boldsymbol{\Phi}^T \mathbf{L}_i \boldsymbol{\Phi}$ | 力 = 磁通的二次型 |
| 2.7 | $F_i = g_I \, \mathbf{I}^T \mathbf{K}_I^T \mathbf{L}_i \mathbf{K}_I \mathbf{I}$ | 力 = 電流的二次型 |
| 2.8 | $\mathbf{K}_I = \mathbf{I}_{6} - \frac{1}{6}\mathbf{1}_{6 \times 6}$ | 理想對稱 $\mathbf{K}_I$ |
| 2.9 | $F_N = g_I \cdot I_{\max}^2$ | 力歸一化常數 |
| 2.10 | $\hat{F}_i = \hat{\mathbf{I}}^T \mathbf{K}_I^T \mathbf{L}_i \mathbf{K}_I \hat{\mathbf{I}}$ | 無量綱力場 |

---

## 11. 與我們 ANSYS 模擬的對應

| 論文步驟 | 對應的我們的檔案/結果 | 狀態 |
|----------|----------------------|------|
| FEM 求解（1A, 6 coils） | `MT_Modeling_..._Coil[1-6].txt` | 完成，6 coil 全 PASS |
| Workspace $\mathbf{B}$ 場資料 | `import_ansys_data(dir, 'wp')` | 可載入 |
| Fig. 2.3 向量圖 | `verify_coil1.m` Fig (a)(b) | 完成 |
| Fig. 2.4 $|\mathbf{B}|$ 等高線圖 | `generate_contour_figures.m` Fig C, D | 完成 |
| 擬合 $\ell$ 和 $\mathcal{R}_a$ | 需寫新腳本 | Priority 2 |
| 驗證 Fig. 2.6（< 1% 誤差）| 需擬合後比對 | Priority 2 |
| 提取 $\mathbf{K}_I^{\text{FEM}}$ 矩陣 | 需從 6 coil WP 中心場反算 | Priority 2 |
| Eq. 2.7 力模型驗證 | 需擬合後計算 | Priority 2+ |
