import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, BarChart3, User, Settings, Zap } from 'lucide-react';

const Sidebar = () => {
  return (
    <aside className="sidebar">
      <a href="/" className="logo">
        <Zap size={24} fill="currentColor" />
        <span>Antigravity</span>
      </a>
      
      <nav>
        <ul className="nav-links">
          <li>
            <NavLink to="/" className={({isActive}) => isActive ? "nav-link active" : "nav-link"} end>
              <LayoutDashboard size={20} />
              Dashboard
            </NavLink>
          </li>
          <li>
            <NavLink to="/analytics" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
              <BarChart3 size={20} />
              Analytics
            </NavLink>
          </li>
          <li>
            <NavLink to="/profile" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
              <User size={20} />
              Profile
            </NavLink>
          </li>
          <li>
            <NavLink to="/settings" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
              <Settings size={20} />
              Settings
            </NavLink>
          </li>
        </ul>
      </nav>
    </aside>
  );
};

export default Sidebar;
