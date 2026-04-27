import React from 'react';
import { Search, Bell, UserCircle } from 'lucide-react';

const Navbar = () => {
  return (
    <header className="navbar">
      <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', flex: 1 }}>
        <Search size={18} color="#94a3b8" />
        <input 
          type="text" 
          placeholder="Search..." 
          style={{ 
            background: 'transparent', 
            border: 'none', 
            color: 'white', 
            outline: 'none',
            width: '100%',
            maxWidth: '400px'
          }} 
        />
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
        <Bell size={20} color="#94a3b8" style={{ cursor: 'pointer' }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', cursor: 'pointer' }}>
          <UserCircle size={28} color="#6366f1" />
          <span style={{ fontSize: '0.875rem', fontWeight: 500 }}>Rashid M.</span>
        </div>
      </div>
    </header>
  );
};

export default Navbar;
