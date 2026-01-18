/**
 * Minimalist Dashboard Example
 * Aesthetic: Technical/Precise
 * Font: Geist Mono (monospace)
 * Color: Cool blue, gray, white
 * Layout: Asymmetric sidebar + main content
 */

import { useState } from 'react';

export function MinimalistDashboard() {
  const [activeTab, setActiveTab] = useState('projects');

  return (
    <div className="flex h-screen bg-[#FAFAFA] font-['Geist_Mono',monospace]">
      {/* Sidebar - Asymmetric width */}
      <aside className="w-64 border-r border-[rgba(0,0,0,0.08)] bg-white">
        <div className="p-6">
          <h1 className="text-[18px] font-semibold tracking-tight text-[#1A1A1A]">
            devtool
          </h1>
        </div>

        <nav className="px-4 py-2 space-y-1">
          <SidebarItem
            label="Projects"
            active={activeTab === 'projects'}
            onClick={() => setActiveTab('projects')}
          />
          <SidebarItem
            label="Tasks"
            active={activeTab === 'tasks'}
            onClick={() => setActiveTab('tasks')}
          />
          <SidebarItem
            label="Team"
            active={activeTab === 'team'}
            onClick={() => setActiveTab('team')}
          />
          <SidebarItem
            label="Settings"
            active={activeTab === 'settings'}
            onClick={() => setActiveTab('settings')}
          />
        </nav>

        {/* User section at bottom */}
        <div className="absolute bottom-0 left-0 w-64 p-4 border-t border-[rgba(0,0,0,0.08)]">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-[#0066FF] rounded-[4px]" />
            <div className="text-[14px] text-[#1A1A1A]">john@example.com</div>
          </div>
        </div>
      </aside>

      {/* Main content area */}
      <main className="flex-1 p-8 overflow-auto">
        {/* Header */}
        <header className="mb-8">
          <h2 className="text-[40px] font-semibold tracking-tight text-[#1A1A1A]">
            Projects
          </h2>
          <p className="text-[14px] text-[#666] mt-2">
            Manage your development projects
          </p>
        </header>

        {/* Metrics grid */}
        <div className="grid grid-cols-3 gap-6 mb-8">
          <MetricCard
            label="Active Projects"
            value="12"
            change="+2 this week"
            trend="up"
          />
          <MetricCard
            label="Tasks Completed"
            value="48"
            change="+12 this week"
            trend="up"
          />
          <MetricCard
            label="Overdue Tasks"
            value="3"
            change="-1 from last week"
            trend="down"
          />
        </div>

        {/* Projects table */}
        <div className="bg-white border border-[rgba(0,0,0,0.08)] rounded-[4px] overflow-hidden">
          <table className="w-full">
            <thead className="border-b border-[rgba(0,0,0,0.08)]">
              <tr className="text-[12px] uppercase tracking-wider text-[#666] text-left">
                <th className="px-6 py-4 font-medium">Project</th>
                <th className="px-6 py-4 font-medium">Status</th>
                <th className="px-6 py-4 font-medium">Progress</th>
                <th className="px-6 py-4 font-medium">Due</th>
              </tr>
            </thead>
            <tbody>
              <ProjectRow
                name="API Redesign"
                status="In Progress"
                progress={75}
                due="2024-02-15"
              />
              <ProjectRow
                name="Dashboard v2"
                status="Review"
                progress={90}
                due="2024-02-20"
              />
              <ProjectRow
                name="Mobile App"
                status="Planning"
                progress={15}
                due="2024-03-01"
              />
            </tbody>
          </table>
        </div>
      </main>
    </div>
  );
}

function SidebarItem({ label, active, onClick }: { label: string; active: boolean; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className={`w-full px-4 py-2 text-[14px] text-left rounded-[4px] transition-colors ${
        active
          ? 'bg-[#0066FF] text-white'
          : 'text-[#666] hover:bg-[rgba(0,0,0,0.04)]'
      }`}
    >
      {label}
    </button>
  );
}

function MetricCard({
  label,
  value,
  change,
  trend,
}: {
  label: string;
  value: string;
  change: string;
  trend: 'up' | 'down';
}) {
  return (
    <div className="bg-white border border-[rgba(0,0,0,0.08)] rounded-[4px] p-6 shadow-[0_1px_3px_rgba(0,0,0,0.05)]">
      <div className="text-[12px] uppercase tracking-wider text-[#666] mb-2">
        {label}
      </div>
      <div className="text-[32px] font-semibold text-[#1A1A1A] mb-2">{value}</div>
      <div className={`text-[12px] ${trend === 'up' ? 'text-[#00A859]' : 'text-[#FF6B6B]'}`}>
        {change}
      </div>
    </div>
  );
}

function ProjectRow({
  name,
  status,
  progress,
  due,
}: {
  name: string;
  status: string;
  progress: number;
  due: string;
}) {
  return (
    <tr className="border-b border-[rgba(0,0,0,0.04)] hover:bg-[rgba(0,0,0,0.02)]">
      <td className="px-6 py-4 text-[14px] text-[#1A1A1A]">{name}</td>
      <td className="px-6 py-4">
        <span className="px-3 py-1 text-[12px] rounded-[4px] bg-[rgba(0,102,255,0.1)] text-[#0066FF]">
          {status}
        </span>
      </td>
      <td className="px-6 py-4">
        <div className="flex items-center gap-3">
          <div className="flex-1 h-2 bg-[rgba(0,0,0,0.08)] rounded-full overflow-hidden">
            <div
              className="h-full bg-[#0066FF] rounded-full transition-all"
              style={{ width: `${progress}%` }}
            />
          </div>
          <span className="text-[12px] text-[#666] w-8">{progress}%</span>
        </div>
      </td>
      <td className="px-6 py-4 text-[14px] text-[#666]">{due}</td>
    </tr>
  );
}
