# <計畫 X> 觸發規則（範本）

> 複製本檔改名為 `workflow-<代號>.md` 後填內容。
> 對應 SOP 檔：`docs/plans/workflow-<代號>.md`

當使用者要求執行 <計畫 X> 時，**必須嚴格按流程文檔執行**。

## 流程文檔位置

`docs/plans/workflow-<代號>.md`

## 觸發條件

當使用者說以下任何一句（**或類似意思**）時，啟動此流程：

- 「跑 <X>」
- 「做 <X> 分析」
- 「<X> 流程」
- <其他同義觸發詞>

**如果使用者問「怎麼跑 <X>」、「<X> 流程是什麼」、「我忘了要說什麼」等**，
Claude 回答：

> 你只要說「**跑 <X>**」，我會自動引導你。
> 我會依序問你 N 個參數：
> 1. <參數 1>
> 2. <參數 2>
> ...
>
> 詳細流程文檔在 `docs/plans/workflow-<代號>.md`。

**如果使用者沒有提供參數**，Claude 必須主動按順序提問。

## 強制規則

1. **每次執行前必須先讀取 workflow 文檔**，確認最新步驟
2. **必須先完成 `docs/plans/README.md` 的共用 Pre-flight 5 項檢查**才能進入本 workflow 的 Step 1；特別是第 3 項 **geom/sim 腳本參數一致性** 發現漂移時，Claude **不得自行繼續**，必須向使用者報告並問該統一到哪個值
3. **嚴格按步驟順序執行**，不跳步
4. **必須向使用者收集所有 `[USER]` 參數**才能開始，不自行假設值
5. **使用 workflow 中已測試通過的程式碼**，不自行重寫
6. **跨設計、跨 pole 配置通用**：workflow 以參數化輸入撰寫，適用 hexapole（6 極）與 quadrupole（4 極）任何設計（hung、hexapole-long2016、未來 quadrupole-<name> 等）
7. **設計專屬細節**（APDL 陷阱、材料、coil 設定等）見 `{design_root}/docs/` 和對應的 path-scoped rule（例如 `.claude/rules/hung-docs.md`），本檔不重複
