import { useEffect, useState, lazy, Suspense } from 'react';
import { useApp } from './store/useApp';
import { t, type Lang } from './core/l10n';
import { Home } from './screens/Home';
import { Jewelry } from './screens/Jewelry';
import { Converter } from './screens/Converter';
import { Settings } from './screens/Settings';
import { More, type SubView } from './screens/More';
import { Alerts } from './screens/Alerts';
import { SkeletonCard } from './components/ui';
import { POLL_INTERVAL_MS } from './core/constants';

// Recharts is heavy — split it out of the critical bundle.
const ChartScreen = lazy(() => import('./screens/ChartScreen').then((m) => ({ default: m.ChartScreen })));
const TimeMachine = lazy(() => import('./screens/TimeMachine').then((m) => ({ default: m.TimeMachine })));
const Banks = lazy(() => import('./screens/Banks').then((m) => ({ default: m.Banks })));

type Tab = 0 | 1 | 2 | 3 | 4;
const TAB_ICONS = ['💰', '💎', '🔁', '⚙️', '☰'];

export default function App() {
  const lang = useApp((s) => s.prefs.lang);
  const theme = useApp((s) => s.prefs.theme);
  const store = useApp((s) => s);
  const [tab, setTab] = useState<Tab>(0);
  const [sub, setSub] = useState<SubView>(null);

  const isArabic = lang === 'ar';

  // Boot: cached snapshot → refresh → 30s polling paused when hidden.
  useEffect(() => {
    store.refresh(true);
    const timer = setInterval(() => {
      if (!document.hidden) store.refresh(true);
    }, POLL_INTERVAL_MS);
    return () => clearInterval(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // html lang/dir + theme
  useEffect(() => {
    document.documentElement.lang = lang;
    document.documentElement.dir = isArabic ? 'rtl' : 'ltr';
  }, [lang, isArabic]);

  useEffect(() => {
    const mq = window.matchMedia('(prefers-color-scheme: light)');
    const apply = () => {
      const mode =
        theme === 'system' ? (mq.matches ? 'light' : 'dark') : theme;
      document.documentElement.setAttribute('data-theme', mode);
      document
        .querySelector('meta[name="theme-color"]')
        ?.setAttribute('content', mode === 'dark' ? '#111111' : '#f7f4ec');
    };
    apply();
    mq.addEventListener('change', apply);
    return () => mq.removeEventListener('change', apply);
  }, [theme]);

  // Toast dismiss handled in store; alerts toasts come from checkAlerts.

  const titles = [
    t(lang, 'tab_prices'),
    t(lang, 'tab_jewelry'),
    t(lang, 'tab_converter'),
    t(lang, 'tab_settings'),
    t(lang, 'tab_more'),
  ];

  const screen = sub ? (
    <Suspense fallback={<SkeletonCard />}>
      {sub === 'chart' ? <ChartScreen /> :
      sub === 'timemachine' ? <TimeMachine /> :
      sub === 'alerts' ? <Alerts /> :
      <Banks />}
    </Suspense>
  ) : tab === 0 ? <Home /> :
    tab === 1 ? <Jewelry /> :
    tab === 2 ? <Converter /> :
    tab === 3 ? <Settings /> :
    <More open={(v) => setSub(v)} />;

  const backTitle =
    sub === 'chart' ? t(lang, 'tab_chart')
    : sub === 'timemachine' ? t(lang, 'timemachine_title')
    : sub === 'alerts' ? t(lang, 'alerts_title')
    : t(lang, 'banks_title');

  return (
    <div className="shell">
      {/* desktop sidebar */}
      <nav className="sidenav" aria-label="main">
        <div className="brand" style={{ padding: '0 10px 18px' }}>
          <div className="logo-badge">PM</div>
          <div>
            <div className="brand-title" style={{ fontSize: 16 }}>{t(lang, 'title')}</div>
            <div className="brand-sub">{t(lang, 'tagline')}</div>
          </div>
        </div>
        {titles.map((title, i) => (
          <button
            key={title}
            className={`side-item ${tab === i && !sub ? 'active' : ''}`}
            onClick={() => { setTab(i as Tab); setSub(null); }}
          >
            <span className="nav-ico">{TAB_ICONS[i]}</span> {title}
          </button>
        ))}
      </nav>

      <div style={{ display: 'flex', flexDirection: 'column', flex: 1, minWidth: 0 }}>
        {/* appbar */}
        <header className="appbar">
          {sub ? (
            <button className="pill icon-only" onClick={() => setSub(null)} aria-label="back">
              <span className="ico">{isArabic ? '→' : '←'}</span>
            </button>
          ) : (
            <div className="brand">
              <div className="logo-badge">PM</div>
              <div>
                <div className="brand-title">{titles[tab]}</div>
                <div className="brand-sub" style={{ display: 'none' }} />
              </div>
            </div>
          )}
          {sub && <div className="brand-title" style={{ fontWeight: 800 }}>{backTitle}</div>}
          <div className="pills">
            <button
              className="pill icon-only"
              onClick={() => store.toggleTheme()}
              title={t(lang, 'theme')}
              aria-label="theme"
            >
              <span className="ico">{theme === 'light' ? '🌙' : '☀️'}</span>
            </button>
            <button className="pill" onClick={() => store.toggleLang()} title="EN / عربي">
              <span className="ico">🌐</span>
              {isArabic ? 'EN' : 'عربي'}
            </button>
          </div>
        </header>

        <main className="main" key={`${tab}-${sub}-${lang}`}>
          {screen}
        </main>

        {/* mobile bottom nav */}
        <nav className="bottomnav" aria-label="bottom">
          {titles.map((title, i) => (
            <button
              key={title}
              className={`nav-item ${tab === i && !sub ? 'active' : ''}`}
              onClick={() => { setTab(i as Tab); setSub(null); }}
            >
              <span className="nav-ico">{TAB_ICONS[i]}</span>
              {title}
            </button>
          ))}
        </nav>
      </div>

      <Toaster />
    </div>
  );
}

function Toaster() {
  const toasts = useApp((s) => s.toasts);
  const dismiss = useApp((s) => s.dismissToast);
  return (
    <div className="toasts">
      {toasts.map((tt) => (
        <div key={tt.id} className={`toast ${tt.kind}`}>
          <span className="t-ico">{tt.kind === 'alert' ? '🔔' : 'ℹ️'}</span>
          <span><span dir="auto">{tt.text}</span></span>
          <button className="t-x" onClick={() => dismiss(tt.id)} aria-label="close">✕</button>
        </div>
      ))}
    </div>
  );
}

export type { Lang };
