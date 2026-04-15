# Claude Intent Sync — Development Progress

紀錄設計決策、踩坑、測試結果的時間線。最終會整理成 README / blog post。

---

## 2026-04-15 — 初始構想

### 問題
Claude Code 設定跨機器（Mac / Windows）同步時，chezmoi 等 dotfile 工具只能處理「檔案層級」的同步，碰到 OS-specific 的東西（cron、launchd、plugins、shell scripts）就要寫一堆 template 判斷，且有些東西（如 `/install-plugin`）根本不是檔案可以同步的。

### 核心概念：Sync Intent, Not Files

同步「任務意圖」而非檔案本身。讓目標機器的 Claude 讀任務 → 依本地 OS 量身執行 → 標記完成。

### 架構
```
~/.claude/cross-machine/
├── pending/    ← 任務等待執行
└── done/       ← 完成紀錄（各機器本地維護）
```

### 流程
```
Mac: Claude 做完 OS-specific 操作 → 問「同步到 Windows？」→ 寫 task md → push
Windows: /sync pull → 掃 pending/ vs done/ → 列出新任務 → 執行 → 寫 done/
```

---

## 設計決策記錄

### D1: 單向 or 雙向
**選擇：單向**（Mac 主力開發機 → Windows 接收端）
**理由：** 減少衝突複雜度。Windows 幾乎不主動 push，因此 done/ 的回報不強求 sync 回 Mac。

### D2: 觸發時機
**選擇：** Claude 做完 OS-specific 操作後主動問使用者
**理由：**
- 自動偵測 diff 會誤判（難定義什麼算 OS-specific）
- 在當下的 session context 裡判斷最準確
- 寫進 CLAUDE.md 當強制規則

### D3: 傳輸層
**選擇：純 Git repo**（不綁 chezmoi）
**理由：**
- 使用者只管 `~/.claude/` 一個目錄，chezmoi 是 overkill
- 降低他人使用門檻
- 純 git + 好的 .gitignore 就夠

### D4: pending / done 目錄管理
**選擇：兩個目錄都 git 追蹤，done 不會被 chezmoi/git 清掉**
**理由：** Git 只管它認識的檔案，機器本地新建的 done 檔不會被 pull 覆蓋。

### D5: 完成標記方式
**選擇：複製 pending 到 done，加 frontmatter completed_by / completed_at / summary**
**理由：** 保留完整歷史，同名比對來判斷是否已完成。

---

## 實作進度

### 已完成
- [x] 建立 `~/.claude/cross-machine/pending/` + `done/` 結構
- [x] 寫 4 個實際 task（session-backup、mempalace、cleanup-period、plugins）
- [x] 修改 `/sync-claude-setting-cross-platform` skill 加入 pull-side 掃描
- [x] CLAUDE.md 新增跨機器同步規則段落
- [x] Windows 端驗證：Claude 能讀 task、依本地環境適配執行
- [x] 建立 private repo `GGGODLIN/claude-config`
- [x] 寫 `.gitignore`（排除 session、plugins、cache、telemetry 等）
- [x] `git init` + 首次 add，驗證內容：784 檔、135k 行、0 secret
- [x] Push 到 https://github.com/GGGODLIN/claude-config （2026-04-15）
- [x] `/sync` skill 改成純 git 版（2026-04-15）
- [ ] Windows 端跑完整初始化流程（clone、sync、execute tasks）
- [ ] 退役 chezmoi（刪 `~/.local/share/chezmoi/`、刪 GGGODLIN/dotfiles repo）

### 待進行（本框架抽象化）
- [ ] 把這套東西從 `claude-config`（個人設定）抽象成 `claude-intent-sync`（框架）
- [ ] 寫 README 賣概念
- [ ] 準備發佈

---

## 踩過的坑

### Figma Make 66 版後 AI 幻覺
- 背景：使用者用 Figma Make 到第 66 版，AI 開始編造「hook 擋住 .jsx 編輯」的假藉口
- 根因：Figma Make 沒有 hook 系統，每個 version 都保存完整 prompt 歷史，context 溢出
- 解法：聯絡 Figma Support 清對話，或 duplicate 檔案開新 Make session
- 參考：[Figma Forum feature request](https://forum.figma.com/suggest-a-feature-11/feature-request-add-a-way-to-clear-or-manage-figma-make-prompt-history-memory-performance-issue-50233)

### MemPalace 索引膨脹 84GB
- 背景：對 `~/.claude` 整個目錄做 `mempalace mine`
- 根因：吃了 582 個 subagent jsonl 和各種 cache，ChromaDB HNSW 索引爆炸
- 解法：建立 `~/.mempalace/sessions-only/` 軟連結目錄，只 mine 主 session，降到 18MB
- 這次學到：chroma 向量 DB 對大檔案不友善，過濾來源是關鍵

### Hook 用錯 mine mode
- 背景：MemPalace `MEMPAL_DIR` 環境變數讓 hook 自動跑 `mempalace mine $DIR`
- 根因：hook 的 `_maybe_auto_ingest()` 沒帶 `--mode convos`，預設是 projects mode，無法解析 JSONL
- 解法：放棄 `MEMPAL_DIR`，改在 hook command 自己跑帶 `--mode convos` 的 mine

---

## 目錄結構（暫定）

這個資料夾未來要發佈為 `claude-intent-sync` repo：

```
claude-intent-sync/
├── README.md              # 賣概念 + 安裝教學
├── LICENSE                # MIT
├── docs/
│   ├── PROGRESS.md        # 本檔，開發時間線
│   ├── concept.md         # 核心概念說明
│   └── how-it-works.md    # pending/done 流程
├── skills/
│   └── sync.md            # 純 git 版 /sync skill
├── templates/
│   ├── task-template.md
│   ├── gitignore.template
│   └── CLAUDE.md.snippet
├── examples/
│   ├── install-plugins.md
│   ├── setup-cron-backup.md
│   ├── install-mcp-server.md
│   └── shell-script-adapter.md
└── install.sh / install.ps1
```
