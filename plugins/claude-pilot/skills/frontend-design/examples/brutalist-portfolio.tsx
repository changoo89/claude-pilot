/**
 * Brutalist Portfolio Example
 * Aesthetic: Bold, experimental
 * Font: Space Mono (monospace)
 * Color: Black (#000000), white (#FFFFFF), red accent (#FF0000)
 * Layout: Sharp edges, heavy borders, hard shadows
 */

export function BrutalistPortfolio() {
  return (
    <div className="min-h-screen bg-white font-['Space_Mono',monospace]">
      {/* Brutalist header */}
      <header className="border-b-3 border-black p-8">
        <nav className="flex justify-between items-center">
          <h1 className="text-[24px] uppercase tracking-widest">
            DEV_PORTFOLIO
          </h1>
          <div className="flex gap-8">
            <a href="#work" className="uppercase text-[14px] hover:bg-black hover:text-white px-2 py-1 transition-colors">
              Work
            </a>
            <a href="#about" className="uppercase text-[14px] hover:bg-black hover:text-white px-2 py-1 transition-colors">
              About
            </a>
            <a href="#contact" className="uppercase text-[14px] hover:bg-black hover:text-white px-2 py-1 transition-colors">
              Contact
            </a>
          </div>
        </nav>
      </header>

      {/* Hero section with hard shadow */}
      <section className="p-8">
        <div className="border-3 border-black shadow-[8px_8px_0_black] p-12">
          <h2 className="text-[48px] uppercase leading-tight mb-6">
            I build <span className="text-[#FF0000]">websites</span> that don't
            look like everything else
          </h2>
          <p className="text-[20px] leading-relaxed mb-8 max-w-2xl">
            Creative developer focused on distinctive interfaces and bold design choices.
            Based in Seoul. Available for freelance projects worldwide.
          </p>
          <div className="flex items-center gap-4">
            <button className="bg-black text-white px-8 py-4 uppercase text-[14px] tracking-wider hover:bg-[#FF0000] transition-colors">
              View Work
            </button>
            <button className="border-3 border-black px-8 py-4 uppercase text-[14px] tracking-wider hover:bg-black hover:text-white transition-colors">
              Contact Me
            </button>
          </div>
        </div>
      </section>

      {/* Projects grid */}
      <section id="work" className="p-8">
        <div className="mb-8">
          <h3 className="text-[32px] uppercase tracking-wider mb-2">
            Selected Work
          </h3>
          <div className="h-1 bg-black w-32" />
        </div>

        <div className="grid grid-cols-2 gap-8">
          <ProjectCard
            title="Project One"
            year="2024"
            tags={['React', 'TypeScript', 'Tailwind']}
            description="E-commerce platform with brutalist aesthetic"
          />
          <ProjectCard
            title="Project Two"
            year="2024"
            tags={['Next.js', 'Prisma', 'PostgreSQL']}
            description="Developer tools dashboard"
          />
          <ProjectCard
            title="Project Three"
            year="2023"
            tags={['Vue', 'GraphQL', 'Node.js']}
            description="Real-time collaboration app"
          />
          <ProjectCard
            title="Project Four"
            year="2023"
            tags={['React Native', 'Expo']}
            description="Mobile app for creative professionals"
          />
        </div>
      </section>

      {/* About section */}
      <section id="about" className="p-8">
        <div className="grid grid-cols-2 gap-8">
          <div className="border-3 border-black p-8">
            <h3 className="text-[32px] uppercase tracking-wider mb-6">
              About
            </h3>
            <p className="text-[16px] leading-relaxed mb-4">
              I'm a creative developer with 5+ years of experience building distinctive
              digital products. I believe websites should be memorable, not just functional.
            </p>
            <p className="text-[16px] leading-relaxed mb-4">
              My approach combines technical precision with bold design choices. I avoid
              generic templates and "AI slop" at all costs.
            </p>
            <p className="text-[16px] leading-relaxed">
              Currently based in Seoul, working remotely with clients worldwide.
            </p>
          </div>

          <div className="border-3 border-black p-8">
            <h3 className="text-[32px] uppercase tracking-wider mb-6">
              Skills
            </h3>
            <div className="space-y-4">
              <SkillItem name="Frontend Development" level="95" />
              <SkillItem name="UI/UX Design" level="85" />
              <SkillItem name="Backend Development" level="75" />
              <SkillItem name="Creative Direction" level="80" />
            </div>
          </div>
        </div>
      </section>

      {/* Contact section */}
      <section id="contact" className="p-8">
        <div className="border-3 border-black shadow-[8px_8px_0_black] p-12">
          <h3 className="text-[32px] uppercase tracking-wider mb-6">
            Let's Work Together
          </h3>
          <p className="text-[20px] mb-8">
            Have a project in mind? I'd love to hear about it.
          </p>
          <a
            href="mailto:hello@example.com"
            className="inline-block bg-black text-white px-8 py-4 uppercase text-[14px] tracking-wider hover:bg-[#FF0000] transition-colors"
          >
            Get In Touch
          </a>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t-3 border-black p-8">
        <div className="flex justify-between items-center">
          <div className="text-[12px] uppercase">
            © 2024 // All Rights Reserved
          </div>
          <div className="flex gap-6">
            <a href="#" className="text-[12px] uppercase hover:bg-black hover:text-white px-2 py-1 transition-colors">
              GitHub
            </a>
            <a href="#" className="text-[12px] uppercase hover:bg-black hover:text-white px-2 py-1 transition-colors">
              Twitter
            </a>
            <a href="#" className="text-[12px] uppercase hover:bg-black hover:text-white px-2 py-1 transition-colors">
              LinkedIn
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

function ProjectCard({
  title,
  year,
  tags,
  description,
}: {
  title: string;
  year: string;
  tags: string[];
  description: string;
}) {
  return (
    <div className="border-3 border-black p-6 hover:bg-black hover:text-white transition-colors group">
      <div className="flex justify-between items-start mb-4">
        <h4 className="text-[24px] uppercase">{title}</h4>
        <span className="text-[12px] uppercase">{year}</span>
      </div>
      <p className="text-[14px] mb-4 opacity-80 group-hover:opacity-100">
        {description}
      </p>
      <div className="flex gap-2 flex-wrap">
        {tags.map((tag) => (
          <span
            key={tag}
            className="px-2 py-1 border-2 border-current text-[12px] uppercase"
          >
            {tag}
          </span>
        ))}
      </div>
    </div>
  );
}

function SkillItem({ name, level }: { name: string; level: number }) {
  return (
    <div>
      <div className="flex justify-between mb-2">
        <span className="text-[14px] uppercase">{name}</span>
        <span className="text-[14px]">{level}%</span>
      </div>
      <div className="h-2 border-2 border-black">
        <div
          className="h-full bg-black"
          style={{ width: `${level}%` }}
        />
      </div>
    </div>
  );
}
