import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Analytics from './pages/Analytics';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="analytics" element={<Analytics />} />
          <Route path="profile" element={<div className="animate-fade"><h1>Profile</h1><div className="card"><p>User profile information details.</p></div></div>} />
          <Route path="settings" element={<div className="animate-fade"><h1>Settings</h1><div className="card"><p>System and account preferences.</p></div></div>} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
