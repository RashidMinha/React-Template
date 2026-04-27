import React from 'react';

const Analytics = () => {
  return (
    <div className="animate-fade">
      <h1>Analytics Insights</h1>
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1.5rem' }}>
        <div className="card" style={{ height: '400px' }}>
          <h2>Traffic Distribution</h2>
          <div style={{ width: '100%', height: '300px', background: 'rgba(255,255,255,0.02)', borderRadius: '0.5rem', border: '1px dashed var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <p>Main Traffic Chart Mockup</p>
          </div>
        </div>
        <div className="card">
          <h2>Top Sources</h2>
          <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '1rem', marginTop: '1rem' }}>
            {['Direct', 'Social Media', 'Referral', 'Organic Search'].map(source => (
              <li key={source} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0.5rem 0', borderBottom: '1px solid var(--border)' }}>
                <span>{source}</span>
                <span style={{ fontWeight: 600 }}>{Math.floor(Math.random() * 100)}%</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default Analytics;
