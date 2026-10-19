import { t } from '../core/l10n';
import { useApp } from '../store/useApp';

export type SubView = 'chart' | 'timemachine' | 'banks' | 'alerts' | null;

export function More({ open }: { open: (v: Exclude<SubView, null>) => void }) {
  const lang = useApp((s) => s.prefs.lang);
  const items: Array<{ icon: string; label: string; view: Exclude<SubView, null> }> = [
    { icon: '🔔', label: t(lang, 'alerts_title'), view: 'alerts' },
    { icon: '📈', label: t(lang, 'tab_chart'), view: 'chart' },
    { icon: '🕰', label: t(lang, 'timemachine_title'), view: 'timemachine' },
    { icon: '🏦', label: t(lang, 'banks_title'), view: 'banks' },
  ];
  return (
    <>
      <div className="dim" style={{ marginBottom: 10 }}>{t(lang, 'more_subtitle')}</div>
      {items.map((it, i) => (
        <div
          key={it.view}
          className="card menu-card"
          style={{ marginBottom: 10, animationDelay: `${i * 60}ms` }}
          onClick={() => open(it.view)}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => e.key === 'Enter' && open(it.view)}
        >
          <div className="menu-ico">{it.icon}</div>
          <div style={{ fontWeight: 800 }}>{it.label}</div>
          <span className="chev">{lang === 'ar' ? '‹' : '›'}</span>
        </div>
      ))}
    </>
  );
}

