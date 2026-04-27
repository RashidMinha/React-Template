import React from 'react';
import { TrendingUp, Users, DollarSign, Activity } from 'lucide-react';

const Dashboard = () => {
  const stats = [
    { title: 'Total Revenue', value: '$45,231.89', change: '+20.1% from last month', icon: <DollarSign />, color: 'icon-primary' },
    { title: 'Subscriptions', value: '+2350', change: '+180.1% from last month', icon: <Users />, color: 'icon-accent' },
    { title: 'Sales', value: '+12,234', change: '+19% from last month', icon: <TrendingUp />, color: 'icon-primary' },
    { title: 'Active Now', value: '+573', change: '+201 since last hour', icon: <Activity />, color: 'icon-accent' },
  ];

  return (
    <div className="animate-fade">
      <h1>Dashboard Overview</h1>
      <div className="dashboard-grid">
        {stats.map((stat, i) => (
          <div key={i} className="card stat-card">
            <div className={`icon-box ${stat.color}`}>
              {stat.icon}
            </div>
            <div>
              <p style={{ fontSize: '0.875rem', marginBottom: '0.25rem' }}>{stat.title}</p>
              <h2 style={{ margin: 0, fontSize: '1.5rem' }}>{stat.value}</h2>
              <p style={{ fontSize: '0.75rem', marginTop: '0.25rem' }}>{stat.change}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="card" style={{ height: '300px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <p>Interactive chart visualization will be rendered here.</p>
      </div>
    </div>
  );
};

export default Dashboard;
