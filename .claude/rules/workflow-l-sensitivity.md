# l-Sensitivity 觸發規則

當使用者要求執行 **l 敏感度研究**（改變 pole-tip 正交連線一半長度 l，觀察 B 場變化）時，**必須嚴格按流程文檔執行**。

## 流程文檔位置

`docs/plans/workflow-l-sensitivity.md`

## 觸發條件

當使用者說以下任何一句（**或類似意思**）時，啟動此流程：

- 「跑 l-sensitivity」/「執行 l-sensitivity」
- 「l 敏感度」/「l 敏感度分析」/「l 敏感度研究」
- 「比較 l」/「改 l 看磁場」
- 「halve l」/「把 l 減半」/「l 減半」
- 「l 的影響」/「l 對 B 場的影響」

**如果使用者問「怎麼跑 l-sensitivity」、「l 敏感度流程是什麼」、「我忘了要說什麼」等**，
Claude 回答：

> 你只要說「**跑 l-sensitivity**」或「**比較 l**」，我會自動引導你。
> 我會依序問你下列參數：
> 1. `pole_config`（hexapole / quadrupole）
> 2. `design_root`（例如 `hung/`）
> 3. `variant_tag`（例如 `Dfillet`）
> 4. `baseline_geom_script`（基底幾何腳本路徑）
> 5. `l_values_um`（要比的 l 值清單，µm）
> 6. `coils_to_run`（要激勵哪些 coil）
>
> 詳細流程文檔在 `docs/plans/workflow-l-sensitivity.md`。

**如果使用者沒有提供參數**，Claude 必須主動按順序提問，不自行假設值。

## 強制規則

1. **每次執行前必須先讀取 workflow 文檔**，確認最新步驟
2. **必須先完成 `docs/plans/README.md` 的共用 Pre-flight 5 項檢查**才能進入本 workflow 的 Step 1；特別是第 3 項 **geom/sim 腳本參數一致性** 發現漂移時，Claude **不得自行繼續**，必須向使用者報告並問該統一到哪個值
3. **嚴格按步驟順序執行**，不跳步
4. **單一 Checkpoint 不可省**：Step 4 跑 FEM 前，使用者必須在 SolidWorks 檢查 IGES 幾何；未批准不進下一步
5. **IGES/ 與 IGES_converted/ 必須同步**（見 `.claude/rules/hung-docs.md`）；Step 3 的 sed 轉換是必經動作
6. **只改 l，其他幾何不動**：pole 尺寸、fillet、block、yoke、coil 全保持原值；這是研究目的（隔離 l 的影響）
7. **跨設計、跨 pole 配置通用**：SOP 以參數化輸入撰寫，適用 hexapole（6 極）與 quadrupole（4 極）
8. **設計專屬細節**見 `{design_root}/docs/` 和對應 path-scoped rule（例如 `.claude/rules/hung-docs.md`），本檔不重複
