/**
 * Warm Landing Page Example
 * Aesthetic: Warm/Human
 * Font: Satoshi (humanist sans-serif)
 * Color: Coral (#FF6B6B), cream (#FFF8F0), teal accent (#4ECDC4)
 * Layout: Asymmetric hero, feature cards, soft rounded corners
 */

export function WarmLandingPage() {
  return (
    <div className="min-h-screen bg-[#FFF8F0] font-['Satoshi',sans-serif]">
      {/* Navigation */}
      <nav className="flex items-center justify-between px-8 py-6">
        <div className="text-[24px] font-semibold text-[#2D3436]">
          storyteller
        </div>
        <div className="flex items-center gap-8">
          <a href="#features" className="text-[14px] text-[#636E72] hover:text-[#2D3436] transition-colors">
            Features
          </a>
          <a href="#pricing" className="text-[14px] text-[#636E72] hover:text-[#2D3436] transition-colors">
            Pricing
          </a>
          <button className="bg-[#FF6B6B] text-white px-6 py-2 rounded-[8px] text-[14px] font-semibold hover:scale-[1.02] transition-transform">
            Sign up free
          </button>
        </div>
      </nav>

      {/* Hero section - Asymmetric layout */}
      <section className="grid grid-cols-12 gap-8 px-8 py-32">
        <div className="col-span-7">
          <div className="inline-block px-4 py-2 bg-[#4ECDC4] bg-opacity-10 rounded-full text-[12px] text-[#4ECDC4] font-semibold mb-6">
            ✨ Now in public beta
          </div>

          <h1 className="text-[64px] leading-tight text-[#2D3436] mb-6">
            Write stories that{' '}
            <span className="relative inline-block">
              <span className="text-[#FF6B6B]">matter</span>
              <svg className="absolute -bottom-2 left-0 w-full" height="8" viewBox="0 0 200 8" fill="none">
                <path d="M2 6C50 2 150 2 198 6" stroke="#FF6B6B" strokeWidth="4" strokeLinecap="round"/>
              </svg>
            </span>
          </h1>

          <p className="text-[20px] text-[#636E72] mb-8 leading-relaxed max-w-lg">
            The creative writing tool for indie authors who care about craft.
            Focus on your story, we'll handle the rest.
          </p>

          <div className="flex items-center gap-4">
            <button className="bg-[#FF6B6B] text-white px-8 py-4 rounded-[12px] text-[16px] font-semibold hover:scale-[1.02] transition-transform shadow-[0_4px_12px_rgba(255,107,107,0.3)]">
              Start writing free
            </button>
            <button className="px-8 py-4 rounded-[12px] text-[16px] text-[#2D3436] border-2 border-[#2D3436] hover:bg-[#2D3436] hover:text-white transition-colors">
              Watch demo
            </button>
          </div>

          <div className="flex items-center gap-6 mt-12">
            <div className="flex -space-x-3">
              {[1, 2, 3, 4].map((i) => (
                <div
                  key={i}
                  className="w-10 h-10 rounded-full bg-gradient-to-br from-[#FF6B6B] to-[#4ECDC4] border-2 border-white"
                />
              ))}
            </div>
            <div className="text-[14px] text-[#636E72]">
              <span className="text-[#2D3436] font-semibold">2,000+</span> authors already writing
            </div>
          </div>
        </div>

        {/* Empty space creates asymmetry */}
        <div className="col-span-5" />
      </section>

      {/* Features section */}
      <section id="features" className="px-8 pb-32">
        <div className="text-center mb-16">
          <h2 className="text-[40px] font-semibold text-[#2D3436] mb-4">
            Everything you need to write
          </h2>
          <p className="text-[18px] text-[#636E72]">
            Powerful features that stay out of your way
          </p>
        </div>

        <div className="grid grid-cols-3 gap-8">
          <FeatureCard
            icon="✨"
            title="Distraction-free editor"
            description="Beautiful, minimal writing environment. Just you and your words."
          />
          <FeatureCard
            icon="📚"
            title="Story organization"
            description="Keep track of characters, plotlines, and worldbuilding with ease."
          />
          <FeatureCard
            icon="🎯"
            title="Daily writing goals"
            description="Build a consistent writing habit with customizable goals and streaks."
          />
          <FeatureCard
            icon="💬"
            title="AI writing assistant"
            description="Get intelligent suggestions without losing your unique voice."
          />
          <FeatureCard
            icon="📊"
            title="Progress analytics"
            description="Track your writing journey with detailed insights and milestones."
          />
          <FeatureCard
            icon="🌍"
            title="Export anywhere"
            description="Publish to your favorite platform or download as PDF/EPUB."
          />
        </div>
      </section>

      {/* CTA section */}
      <section className="px-8 pb-32">
        <div className="bg-[#2D3436] rounded-[24px] p-12 text-center">
          <h2 className="text-[40px] font-semibold text-white mb-4">
            Ready to start your story?
          </h2>
          <p className="text-[18px] text-[rgba(255,255,255,0.7)] mb-8 max-w-lg mx-auto">
            Join thousands of indie authors who are already writing their next masterpiece.
          </p>
          <button className="bg-[#FF6B6B] text-white px-8 py-4 rounded-[12px] text-[16px] font-semibold hover:scale-[1.02] transition-transform">
            Start writing free
          </button>
        </div>
      </section>

      {/* Footer */}
      <footer className="px-8 py-8 border-t border-[rgba(0,0,0,0.08)]">
        <div className="flex items-center justify-between">
          <div className="text-[14px] text-[#636E72]">
            © 2024 Storyteller. Made with ❤️ for indie authors.
          </div>
          <div className="flex items-center gap-6">
            <a href="#" className="text-[14px] text-[#636E72] hover:text-[#2D3436]">
              Privacy
            </a>
            <a href="#" className="text-[14px] text-[#636E72] hover:text-[#2D3436]">
              Terms
            </a>
            <a href="#" className="text-[14px] text-[#636E72] hover:text-[#2D3436]">
              Contact
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: string;
  title: string;
  description: string;
}) {
  return (
    <div className="bg-white p-8 rounded-[16px] shadow-[0_2px_8px_rgba(0,0,0,0.06)] hover:shadow-[0_4px_16px_rgba(0,0,0,0.1)] transition-shadow">
      <div className="text-[32px] mb-4">{icon}</div>
      <h3 className="text-[20px] font-semibold text-[#2D3436] mb-2">{title}</h3>
      <p className="text-[14px] text-[#636E72] leading-relaxed">{description}</p>
    </div>
  );
}
