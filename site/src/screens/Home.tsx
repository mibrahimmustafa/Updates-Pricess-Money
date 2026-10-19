import { ErrorBanner, FxBar, LiveBadge, MetalCard, SkeletonCard, Updated } from '../components/ui';
import { useApp } from '../store/useApp';

export function Home() {
  const metals = useApp((s) => s.prefs.metals);
  const snapshot = useApp((s) => s.snapshot);
  const loading = useApp((s) => s.loading);
  const snapshotExists = !!snapshot;

  return (
    <>
      <div className="between" style={{ marginBottom: 12 }}>
        <LiveBadge />
        <Updated />
      </div>
      <ErrorBanner />
      <div style={{ height: 10 }} />
      <FxBar />
      <div style={{ height: 14 }} />
      {!snapshotExists && loading && [0, 1].map((i) => <SkeletonCard key={i} />)}
      {metals.map((m, i) => (
        <div key={m} style={{ marginBottom: 14 }}>
          <MetalCard symbol={m} delay={i * 90} />
        </div>
      ))}
      {snapshotExists && loading && (
        <div className="faint" style={{ textAlign: 'center' }}>↻ …</div>
      )}
    </>
  );
}
