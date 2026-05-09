import React, { useMemo, useState } from "react";

const Icon = ({ name, className = "" }) => {
  const icons = {
    search: "⌕",
    plus: "+",
    home: "⌂",
    folder: "▣",
    date: "◷",
    stats: "▥",
    setting: "⚙",
    arrow: "›",
    clock: "◴",
    edit: "✎",
    trash: "⌫",
    phone: "▯",
    database: "▤",
    bellOff: "🔕",
    shield: "✓",
    close: "×",
  };

  return (
    <span className={`inline-flex items-center justify-center leading-none ${className}`} aria-hidden="true">
      {icons[name] || "•"}
    </span>
  );
};

const navItems = [
  { key: "home", label: "首页", icon: "home" },
  { key: "category", label: "分类", icon: "folder" },
  { key: "date", label: "日期", icon: "date" },
  { key: "stats", label: "统计", icon: "stats" },
  { key: "setting", label: "设置", icon: "setting" },
];

const tasks = [
  {
    id: 1,
    status: "todo",
    title: "完成任务记录器需求分析",
    desc: "整理第一版核心功能与页面结构",
    folder: "毕设",
    time: "09:20",
  },
  {
    id: 2,
    status: "done",
    title: "整理 App 页面结构",
    desc: "首页、分类、日期、统计、设置",
    folder: "学习",
    time: "10:45",
  },
  {
    id: 3,
    status: "partial",
    title: "修改查询功能设计",
    desc: "加入状态筛选和日期筛选",
    folder: "毕设",
    time: "14:10",
  },
  {
    id: 4,
    status: "todo",
    title: "",
    desc: "没有标题时，默认展示任务描述前几个字作为标题",
    folder: "未分类",
    time: "16:30",
  },
];

const folders = [
  { name: "学习", count: 12, desc: "课程、资料、复习" },
  { name: "毕设", count: 8, desc: "论文、图表、系统设计" },
  { name: "工作", count: 5, desc: "待办、会议、文档" },
  { name: "运动", count: 3, desc: "步数、跑步、训练" },
  { name: "生活", count: 10, desc: "日常、购物、整理" },
  { name: "未分类", count: 3, desc: "默认分类，不可删除" },
];

const dateGroups = [
  { title: "今天", date: "2026年5月8日", count: 6, done: 3 },
  { title: "昨天", date: "2026年5月7日", count: 4, done: 2 },
  { title: "本月", date: "2026年5月", count: 23, done: 14 },
  { title: "更早", date: "2026年4月", count: 41, done: 28 },
];

export function getTaskDisplayTitle(task, limit = 14) {
  if (!task) return "";
  if (task.title && task.title.trim()) return task.title.trim();
  const desc = task.desc || "未命名任务";
  return desc.length > limit ? `${desc.slice(0, limit)}...` : desc;
}

export function calculateCompletionRate(done, total) {
  if (!total || total <= 0) return 0;
  return Math.round((done / total) * 100);
}

export function getNextStatus(status) {
  const order = ["todo", "done", "partial"];
  const index = order.indexOf(status);
  return order[(index + 1) % order.length] || "todo";
}

export function getCreatePanelTitle(type) {
  if (type === "task") return "新建任务";
  if (type === "folder") return "新建文件夹";
  return "";
}

export function getPreviewPageCount(pages) {
  return Array.isArray(pages) ? pages.length : 0;
}

function runSelfTests() {
  const unnamedTask = { title: "", desc: "没有标题时默认展示描述" };
  console.assert(getTaskDisplayTitle(unnamedTask, 6) === "没有标题时...", "fallback title should use task desc prefix");
  console.assert(calculateCompletionRate(3, 6) === 50, "completion rate should be 50 when 3 of 6 are done");
  console.assert(calculateCompletionRate(0, 0) === 0, "completion rate should be 0 when total is 0");
  console.assert(getNextStatus("todo") === "done", "todo should switch to done");
  console.assert(getNextStatus("done") === "partial", "done should switch to partial");
  console.assert(getNextStatus("partial") === "todo", "partial should switch back to todo");
  console.assert(getCreatePanelTitle("task") === "新建任务", "task panel title should be 新建任务");
  console.assert(getCreatePanelTitle("folder") === "新建文件夹", "folder panel title should be 新建文件夹");
  console.assert(getPreviewPageCount(["home", "category", "date", "stats", "setting"]) === 5, "preview should contain five pages");
}

runSelfTests();

function StatusMark({ status }) {
  if (status === "done") {
    return (
      <span className="flex h-7 w-7 items-center justify-center rounded-full bg-emerald-100 text-base font-bold text-emerald-600">
        √
      </span>
    );
  }
  if (status === "partial") {
    return (
      <span className="flex h-7 w-7 items-center justify-center rounded-full bg-amber-100 text-base font-bold text-amber-600">
        √̶
      </span>
    );
  }
  return (
    <span className="flex h-7 w-7 items-center justify-center rounded-full border-2 border-slate-300 bg-white text-sm font-semibold text-slate-400">
      □
    </span>
  );
}

function TaskCard({ task }) {
  const fallbackTitle = getTaskDisplayTitle(task);
  return (
    <div className="group flex items-start gap-3 rounded-2xl border border-slate-100 bg-white p-3 shadow-sm transition active:scale-[0.98]">
      <StatusMark status={task.status} />
      <div className="min-w-0 flex-1">
        <div className="flex items-start justify-between gap-2">
          <div>
            <p className="line-clamp-1 text-sm font-semibold text-slate-900">{fallbackTitle}</p>
            <p className="mt-1 line-clamp-1 text-xs text-slate-500">{task.desc}</p>
          </div>
          <Icon name="arrow" className="mt-1 h-4 w-4 shrink-0 text-lg text-slate-300" />
        </div>
        <div className="mt-2 flex items-center gap-2 text-[11px] text-slate-500">
          <span className="rounded-full bg-slate-100 px-2 py-0.5">{task.folder}</span>
          <span className="flex items-center gap-1"><Icon name="clock" className="h-3 w-3" />{task.time}</span>
        </div>
      </div>
    </div>
  );
}

function SectionTitle({ title, desc, action }) {
  return (
    <div className="mb-3 flex items-end justify-between">
      <div>
        <h2 className="text-base font-bold text-slate-900">{title}</h2>
        {desc && <p className="mt-0.5 text-xs text-slate-500">{desc}</p>}
      </div>
      {action && <button className="text-xs font-semibold text-indigo-600">{action}</button>}
    </div>
  );
}

function HomePage({ onSearch }) {
  return (
    <div className="space-y-4 px-4 pb-24 pt-4">
      <button
        onClick={onSearch}
        className="w-full rounded-3xl bg-white/90 p-3 text-left shadow-sm backdrop-blur transition active:scale-[0.98]"
        aria-label="进入查询任务页面"
      >
        <div className="flex items-center gap-2 rounded-2xl bg-slate-100 px-3 py-3 text-slate-400">
          <Icon name="search" className="h-4 w-4 text-lg" />
          <span className="text-sm">搜索任务标题、描述、备注</span>
        </div>
      </button>

      <div className="overflow-hidden rounded-[28px] bg-gradient-to-br from-indigo-500 via-violet-500 to-fuchsia-500 p-5 text-white shadow-lg shadow-indigo-200">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-xs font-medium text-white/75">今日任务信息</p>
            <h1 className="mt-2 text-2xl font-black tracking-tight">今天 · 5月8日</h1>
            <p className="mt-2 text-sm text-white/85">共 6 个任务，已完成 3 个</p>
          </div>
          <div className="rounded-2xl bg-white/20 px-3 py-2 text-center backdrop-blur">
            <p className="text-2xl font-black">50%</p>
            <p className="text-[10px] text-white/80">完成率</p>
          </div>
        </div>
        <div className="mt-5 grid grid-cols-3 gap-2 text-center text-xs">
          <div className="rounded-2xl bg-white/15 p-2 backdrop-blur"><b className="block text-lg">3</b>已完成</div>
          <div className="rounded-2xl bg-white/15 p-2 backdrop-blur"><b className="block text-lg">2</b>未完成</div>
          <div className="rounded-2xl bg-white/15 p-2 backdrop-blur"><b className="block text-lg">1</b>部分完成</div>
        </div>
      </div>

      <section>
        <SectionTitle title="今日任务" desc="点击左侧状态可切换：□ → √ → √̶" action="全部" />
        <div className="space-y-3">
          {tasks.map((task) => <TaskCard key={task.id} task={task} />)}
        </div>
      </section>
    </div>
  );
}

function CategoryPage() {
  return (
    <div className="space-y-4 px-4 pb-24 pt-4">
      <TopTitle title="分类" desc="用户可自行新建文件夹分类" />
      <div className="space-y-3">
        {folders.map((folder) => (
          <div key={folder.name} className="flex items-center gap-3 rounded-3xl bg-white p-4 shadow-sm">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-indigo-50 text-indigo-600">
              <Icon name="folder" className="text-xl" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="font-bold text-slate-900">{folder.name}</p>
              <p className="text-xs text-slate-500">{folder.desc}</p>
            </div>
            <div className="text-right">
              <p className="text-sm font-bold text-slate-900">{folder.count}</p>
              <p className="text-[10px] text-slate-400">个任务</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function DatePage() {
  return (
    <div className="space-y-4 px-4 pb-24 pt-4">
      <TopTitle title="日期记录" desc="系统自动按创建日期归档" />
      <div className="space-y-3">
        {dateGroups.map((item) => (
          <div key={item.date} className="rounded-3xl bg-white p-4 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-bold text-slate-900">{item.title}</p>
                <p className="mt-1 text-xs text-slate-500">{item.date}</p>
              </div>
              <div className="text-right">
                <p className="text-sm font-bold text-slate-900">{item.count} 个任务</p>
                <p className="text-xs text-emerald-600">完成 {item.done} 个</p>
              </div>
            </div>
            <div className="mt-3 h-2 overflow-hidden rounded-full bg-slate-100">
              <div className="h-full rounded-full bg-indigo-500" style={{ width: `${calculateCompletionRate(item.done, item.count)}%` }} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function StatsPage() {
  const stats = useMemo(() => [
    { label: "总任务", value: 8 },
    { label: "已完成", value: 4 },
    { label: "未完成", value: 3 },
    { label: "部分完成", value: 1 },
  ], []);

  return (
    <div className="space-y-4 px-4 pb-24 pt-4">
      <TopTitle title="今日统计" desc="部分完成不计入完成率" />
      <div className="rounded-[30px] bg-white p-5 shadow-sm">
        <div className="mx-auto flex h-36 w-36 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 text-center text-white shadow-lg shadow-indigo-100">
          <div>
            <p className="text-4xl font-black">50%</p>
            <p className="text-xs text-white/75">完成率</p>
          </div>
        </div>
        <div className="mt-5 grid grid-cols-2 gap-3">
          {stats.map((item) => (
            <div key={item.label} className="rounded-2xl bg-slate-50 p-3 text-center">
              <p className="text-2xl font-black text-slate-900">{item.value}</p>
              <p className="text-xs text-slate-500">{item.label}</p>
            </div>
          ))}
        </div>
      </div>
      <div className="rounded-3xl bg-white p-4 shadow-sm">
        <SectionTitle title="周期统计" desc="第一版只做简单统计" />
        <div className="space-y-3 text-sm">
          <Row label="本周完成数" value="16 个" />
          <Row label="本月完成数" value="45 个" />
          <Row label="今日部分完成" value="1 个" />
        </div>
      </div>
    </div>
  );
}

function SettingPage() {
  return (
    <div className="space-y-4 px-4 pb-24 pt-4">
      <TopTitle title="设置" desc="第一版保持简单，不加入账号系统" />
      <div className="rounded-[30px] bg-slate-900 p-5 text-white shadow-lg shadow-slate-200">
        <div className="flex items-center gap-3">
          <div className="rounded-2xl bg-white/10 p-3">
            <Icon name="database" className="text-xl" />
          </div>
          <div>
            <p className="font-bold">仅本机保存</p>
            <p className="mt-1 text-xs text-white/60">卸载 App 后数据可能被清除</p>
          </div>
        </div>
      </div>
      <div className="rounded-3xl bg-white p-4 shadow-sm">
        <Row label="默认首页" value="今日任务" />
        <Row label="任务排序" value="创建时间" />
        <Row label="删除确认" value="开启" />
        <Row label="清空全部数据" value="谨慎操作" danger />
      </div>
      <div className="grid grid-cols-3 gap-3">
        <InfoTile icon="phone" label="无需登录" />
        <InfoTile icon="bellOff" label="无提醒" />
        <InfoTile icon="shield" label="本地数据" />
      </div>
    </div>
  );
}

function TopTitle() {
  return null;
}

function Row({ label, value, danger }) {
  return (
    <div className="flex items-center justify-between border-b border-slate-100 py-3 last:border-none">
      <p className={`text-sm font-medium ${danger ? "text-rose-600" : "text-slate-700"}`}>{label}</p>
      <div className="flex items-center gap-2 text-sm text-slate-400">
        <span>{value}</span>
        <Icon name="arrow" className="h-4 w-4 text-lg" />
      </div>
    </div>
  );
}

function InfoTile({ icon, label }) {
  return (
    <div className="rounded-3xl bg-white p-4 text-center shadow-sm">
      <Icon name={icon} className="mx-auto h-5 w-5 text-lg text-indigo-500" />
      <p className="mt-2 text-xs font-semibold text-slate-600">{label}</p>
    </div>
  );
}

function CreateTaskSheet({ onClose }) {
  return (
    <div className="space-y-4">
      <div>
        <p className="text-xs font-semibold text-indigo-500">任务记录</p>
        <h2 className="mt-1 text-2xl font-black text-slate-950">新建任务</h2>
        <p className="mt-1 text-sm text-slate-500">默认状态为未完成，创建日期由系统自动记录。</p>
      </div>

      <div className="space-y-3">
        <label className="block">
          <span className="mb-1 block text-xs font-bold text-slate-500">任务标题</span>
          <div className="rounded-2xl bg-slate-100 px-4 py-3 text-sm text-slate-400">例如：完成毕业设计需求分析</div>
        </label>
        <label className="block">
          <span className="mb-1 block text-xs font-bold text-slate-500">任务描述</span>
          <div className="h-20 rounded-2xl bg-slate-100 px-4 py-3 text-sm text-slate-400">补充任务说明、完成要求或备注...</div>
        </label>
        <div className="grid grid-cols-2 gap-3">
          <label className="block">
            <span className="mb-1 block text-xs font-bold text-slate-500">所属分类</span>
            <div className="rounded-2xl bg-indigo-50 px-4 py-3 text-sm font-semibold text-indigo-600">毕设 ▾</div>
          </label>
          <label className="block">
            <span className="mb-1 block text-xs font-bold text-slate-500">任务状态</span>
            <div className="rounded-2xl bg-slate-100 px-4 py-3 text-sm font-semibold text-slate-600">□ 未完成</div>
          </label>
        </div>
        <label className="block">
          <span className="mb-1 block text-xs font-bold text-slate-500">备注</span>
          <div className="rounded-2xl bg-slate-100 px-4 py-3 text-sm text-slate-400">可填写完成情况或其他说明</div>
        </label>
      </div>

      <div className="grid grid-cols-2 gap-3 pt-1">
        <button onClick={onClose} className="rounded-2xl bg-slate-100 py-3 text-sm font-bold text-slate-600">取消</button>
        <button onClick={onClose} className="rounded-2xl bg-indigo-600 py-3 text-sm font-bold text-white shadow-lg shadow-indigo-100">保存任务</button>
      </div>
    </div>
  );
}

function CreateFolderSheet({ onClose }) {
  return (
    <div className="space-y-4">
      <div>
        <p className="text-xs font-semibold text-indigo-500">文件夹分类</p>
        <h2 className="mt-1 text-2xl font-black text-slate-950">新建文件夹</h2>
        <p className="mt-1 text-sm text-slate-500">用于把任务放入不同分类，未选择分类时进入“未分类”。</p>
      </div>

      <div className="space-y-3">
        <label className="block">
          <span className="mb-1 block text-xs font-bold text-slate-500">文件夹名称</span>
          <div className="rounded-2xl bg-slate-100 px-4 py-3 text-sm text-slate-400">例如：毕设 / 学习 / 运动</div>
        </label>
        <label className="block">
          <span className="mb-1 block text-xs font-bold text-slate-500">文件夹说明</span>
          <div className="h-20 rounded-2xl bg-slate-100 px-4 py-3 text-sm text-slate-400">可选，用于说明这个分类存放哪些任务...</div>
        </label>
        <div className="rounded-2xl bg-amber-50 px-4 py-3 text-xs leading-5 text-amber-700">
          删除文件夹时，文件夹内任务会移动到“未分类”；“未分类”不能被删除。
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 pt-1">
        <button onClick={onClose} className="rounded-2xl bg-slate-100 py-3 text-sm font-bold text-slate-600">取消</button>
        <button onClick={onClose} className="rounded-2xl bg-indigo-600 py-3 text-sm font-bold text-white shadow-lg shadow-indigo-100">保存文件夹</button>
      </div>
    </div>
  );
}

function CreatePanel({ type, onClose }) {
  if (!type) return null;
  return (
    <div className="absolute inset-0 z-40 flex items-end bg-slate-950/35 px-3 pb-3 backdrop-blur-sm">
      <button className="absolute inset-0 cursor-default" aria-label="关闭弹窗" onClick={onClose} />
      <div className="relative w-full rounded-[30px] bg-white p-5 shadow-2xl">
        <button
          onClick={onClose}
          className="absolute right-4 top-4 flex h-8 w-8 items-center justify-center rounded-full bg-slate-100 text-xl font-bold text-slate-400"
          aria-label="关闭"
        >
          <Icon name="close" />
        </button>
        {type === "task" ? <CreateTaskSheet onClose={onClose} /> : <CreateFolderSheet onClose={onClose} />}
      </div>
    </div>
  );
}

function PhonePreview({ title, pageKey, children, overlayType, onCloseOverlay, onNewTask }) {
  return (
    <section id={`preview-${pageKey}`} className="space-y-3">

      <div className="relative mx-auto h-[780px] w-[390px] overflow-hidden rounded-[44px] border-[10px] border-slate-900 bg-slate-50 shadow-2xl shadow-slate-300">
        <div className="absolute left-1/2 top-2 z-20 h-6 w-28 -translate-x-1/2 rounded-full bg-slate-900" />
        <div className="h-full overflow-y-auto bg-gradient-to-b from-slate-50 to-indigo-50/80 pt-7 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
          {children}
        </div>
        <button
          className="absolute bottom-24 right-5 z-30 flex h-14 w-14 items-center justify-center rounded-3xl bg-indigo-600 text-2xl font-black text-white shadow-xl shadow-indigo-200"
          aria-label="新建任务"
          onClick={onNewTask}
        >
          +
        </button>
        <div className="absolute bottom-0 left-0 right-0 z-20 border-t border-slate-100 bg-white/95 px-3 pb-4 pt-2 backdrop-blur">
          <div className="grid grid-cols-5 gap-1">
            {navItems.map(({ key, label, icon }) => {
              const active = pageKey === key;
              return (
                <button
                  key={key}
                  className={`flex flex-col items-center justify-center rounded-2xl px-1 py-2 text-[11px] font-semibold transition ${active ? "bg-indigo-50 text-indigo-600" : "text-slate-400"}`}
                  type="button"
                >
                  <Icon name={icon} className="mb-1 h-5 w-5 text-lg" />
                  {label}
                </button>
              );
            })}
          </div>
        </div>
        <CreatePanel type={overlayType} onClose={onCloseOverlay} />
      </div>
    </section>
  );
}

function MiniPreview({ title, children }) {
  return (
    <div className="rounded-[30px] border border-slate-100 bg-white p-4 shadow-sm">
      <p className="mb-3 text-sm font-bold text-slate-900">{title}</p>
      {children}
    </div>
  );
}

export default function TaskRecorderUI() {
  const [overlay, setOverlay] = useState({ pageKey: null, type: null });

  const openCreateTask = (pageKey) => setOverlay({ pageKey, type: "task" });
  const closeOverlay = () => setOverlay({ pageKey: null, type: null });

  const previewPages = [
    {
      key: "home",
      title: "首页",
      node: <HomePage onSearch={() => {}} />,
    },
    {
      key: "category",
      title: "分类页",
      node: <CategoryPage />,
    },
    {
      key: "date",
      title: "日期页",
      node: <DatePage />,
    },
    {
      key: "stats",
      title: "统计页",
      node: <StatsPage />,
    },
    {
      key: "setting",
      title: "设置页",
      node: <SettingPage />,
    },
  ];

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,#e0e7ff,transparent_35%),linear-gradient(135deg,#f8fafc,#eef2ff)] p-6 text-slate-900">
      <div className="mx-auto max-w-7xl space-y-8">
        <header className="rounded-[36px] bg-white/90 p-6 shadow-xl shadow-indigo-100 backdrop-blur">
          <p className="text-sm font-bold text-indigo-600">方案 B · 每个页面独立手机预览</p>
          <h1 className="mt-2 text-3xl font-black tracking-tight text-slate-950">任务记录器 App UI 拆分展示</h1>
          <p className="mt-3 max-w-3xl leading-7 text-slate-600">
            现在每个页面都单独放进一个手机壳中展示，方便逐页截图、对比布局和继续修改单个页面。任意手机右下角“+”可预览新建任务。
          </p>
          <div className="mt-5 flex flex-wrap gap-2 text-xs font-semibold text-slate-600">
            <span className="rounded-full bg-indigo-50 px-3 py-2 text-indigo-600">首页</span>
            <span className="rounded-full bg-indigo-50 px-3 py-2 text-indigo-600">分类页</span>
            <span className="rounded-full bg-indigo-50 px-3 py-2 text-indigo-600">日期页</span>
            <span className="rounded-full bg-indigo-50 px-3 py-2 text-indigo-600">统计页</span>
            <span className="rounded-full bg-indigo-50 px-3 py-2 text-indigo-600">设置页</span>
          </div>
        </header>

        <div className="grid gap-8 xl:grid-cols-2 2xl:grid-cols-3">
          {previewPages.map((page) => (
            <PhonePreview
              key={page.key}
              title={page.title}
              pageKey={page.key}
              overlayType={overlay.pageKey === page.key ? overlay.type : null}
              onCloseOverlay={closeOverlay}
              onNewTask={() => openCreateTask(page.key)}
            >
              {page.node}
            </PhonePreview>
          ))}
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <MiniPreview title="首页交互">
            <div className="space-y-2 text-sm text-slate-600">
              <p className="rounded-2xl bg-slate-50 p-3">搜索框：仅保留首页入口样式</p>
              <p className="rounded-2xl bg-slate-50 p-3">右下角 +：打开新建任务表单</p>
            </div>
          </MiniPreview>
          <MiniPreview title="任务状态">
            <div className="space-y-3 text-sm">
              <div className="flex items-center gap-3"><StatusMark status="todo" /> 未完成</div>
              <div className="flex items-center gap-3"><StatusMark status="done" /> 已完成</div>
              <div className="flex items-center gap-3"><StatusMark status="partial" /> 部分完成 / 已处理未完成</div>
            </div>
          </MiniPreview>
        </div>
      </div>
    </div>
  );
}
