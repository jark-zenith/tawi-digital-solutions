
import React, { useEffect, useState } from 'react';
import { Link, NavLink } from 'react-router-dom';
import {
  ArrowRight, ArrowUpRight, Bot, Building2, CheckCircle2, Code2,
  Compass, Globe2, Headset, Layers3, Mail, MapPin, Menu, MessageCircle,
  PlayCircle, Rocket, ShieldCheck, Sparkles, Workflow, X
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import './public-site.css';

const CONTACT = { whatsapp: '', email: '' };

const services = [
  {
    id: 'ai',
    title: 'AI Solutions & Automation',
    short: 'Make everyday work smarter.',
    description: 'We help individuals and organizations explore practical AI tools and automated workflows that simplify repetitive tasks and create room for more valuable work.',
    detail: 'From identifying useful opportunities to planning and implementing an appropriate workflow, we focus on AI that serves a real purpose.',
    icon: Bot,
    points: ['AI-powered tools and integrations', 'Workflow and task automation', 'Practical AI adoption guidance']
  },
  {
    id: 'development',
    title: 'Website & Application Development',
    short: 'Build a stronger digital presence.',
    description: 'We design and develop modern websites and applications around your goals, your users and the experience you want to create.',
    detail: 'Whether you are starting with an idea or improving an existing digital product, we help turn requirements into a clear development plan.',
    icon: Code2,
    points: ['Business and personal websites', 'Web applications and digital products', 'Responsive user experiences']
  },
  {
    id: 'transformation',
    title: 'Digital Transformation',
    short: 'Improve how your work gets done.',
    description: 'We help clients identify opportunities to use digital tools, improve processes and modernize the way they work.',
    detail: 'Our approach starts with understanding the current process, then identifying realistic improvements that fit the organization.',
    icon: Workflow,
    points: ['Digital process improvement', 'Technology adoption planning', 'Connected tools and workflows']
  },
  {
    id: 'it',
    title: 'IT Consulting & Support',
    short: 'Make confident technology decisions.',
    description: 'We offer practical technology guidance and technical assistance to help individuals and organizations navigate IT challenges.',
    detail: 'We work to understand the issue, explain the available options and help identify a sensible next step.',
    icon: Headset,
    points: ['Technology planning and guidance', 'Technical troubleshooting', 'IT support and recommendations']
  }
];

const steps = [
  ['01', 'Understand', 'We listen to your goals, challenges and the people your solution needs to serve.'],
  ['02', 'Plan', 'We define the scope, explore suitable options and agree on a practical way forward.'],
  ['03', 'Build', 'We develop or implement the solution with attention to usability and quality.'],
  ['04', 'Improve', 'We review the result and identify opportunities for ongoing support and refinement.']
];

function Brand() {
  return <Link className="site-brand" to="/" aria-label="TAWI Digital Solutions home">
    <span className="site-brand-mark">T</span>
    <span><b>TAWI</b><small>DIGITAL SOLUTIONS</small></span>
  </Link>;
}

function Eyebrow({ children }) {
  return <div className="site-eyebrow"><i />{children}</div>;
}

function Header() {
  const [open, setOpen] = useState(false);
  const items = [['Home', '/', true], ['About', '/about'], ['Services', '/services'], ['Projects', '/projects'], ['Contact', '/contact']];
  return <header className="site-header">
    <div className="site-nav-wrap">
      <Brand />
      <button className="site-menu-toggle" onClick={() => setOpen(!open)} aria-label={open ? 'Close navigation' : 'Open navigation'}>
        {open ? <X size={22} /> : <Menu size={22} />}
      </button>
      <nav className={open ? 'site-nav open' : 'site-nav'}>
        {items.map(([label, path, end]) => <NavLink key={path} to={path} end={!!end} onClick={() => setOpen(false)} className={({ isActive }) => 'site-nav-link' + (isActive ? ' active' : '')}>{label}</NavLink>)}
        <Link className="site-button site-button-small" to="/contact" onClick={() => setOpen(false)}>Start a project <ArrowUpRight size={15} /></Link>
      </nav>
    </div>
  </header>;
}

function Footer() {
  const whatsapp = CONTACT.whatsapp.replace(/\D/g, '');
  return <footer className="site-footer">
    <div className="site-footer-main">
      <div className="site-footer-brand">
        <Brand />
        <p>Technology that moves your ideas forward. Practical digital solutions for individuals and businesses in Kenya and around the world.</p>
        <span className="site-location"><MapPin size={15} /> Kenya · Working globally</span>
      </div>
      <div className="site-footer-column">
        <b>Explore</b>
        <Link to="/about">About TAWI</Link>
        <Link to="/services">Our services</Link>
        <Link to="/projects">Projects</Link>
        <Link to="/contact">Contact</Link>
      </div>
      <div className="site-footer-column">
        <b>Our services</b>
        <Link to="/services">AI & automation</Link>
        <Link to="/services">Websites & applications</Link>
        <Link to="/services">Digital transformation</Link>
        <Link to="/services">IT consulting & support</Link>
      </div>
      <div className="site-footer-column site-footer-contact">
        <b>Get in touch</b>
        {CONTACT.email
          ? <a href={'mailto:' + CONTACT.email}><Mail size={15} />{CONTACT.email}</a>
          : <span><Mail size={15} />Email details coming soon</span>}
        {CONTACT.whatsapp
          ? <a href={'https://wa.me/' + whatsapp} target="_blank" rel="noreferrer"><MessageCircle size={15} />WhatsApp us</a>
          : <span><MessageCircle size={15} />WhatsApp details coming soon</span>}
        <Link to="/contact" className="site-footer-form-link">Send an enquiry <ArrowUpRight size={14} /></Link>
      </div>
    </div>
    <div className="site-footer-bottom">
      <span>© {new Date().getFullYear()} TAWI Digital Solutions. All rights reserved.</span>
      <span>Kenya-based · Globally available</span>
      <Link to="/admin/login">Team sign in</Link>
    </div>
  </footer>;
}

function ServiceCard({ item, index }) {
  const Icon = item.icon;
  return <article className="site-service-card">
    <div className="site-service-top"><span className="site-icon-box"><Icon size={22} /></span><span className="site-service-number">0{index + 1}</span></div>
    <h3>{item.title}</h3>
    <p className="site-service-short">{item.short}</p>
    <p>{item.description}</p>
    <Link to="/services" className="site-text-link">Explore service <ArrowUpRight size={15} /></Link>
  </article>;
}

function HomePage() {
  return <>
    <section className="site-hero">
      <div className="site-hero-inner">
        <div className="site-hero-copy">
          <Eyebrow>KENYA-BASED · WORKING GLOBALLY</Eyebrow>
          <h1>Technology that moves <em>your ideas forward.</em></h1>
          <p className="site-hero-lead">We help individuals and businesses turn ideas into practical digital solutions through AI, software development, digital transformation and technology support.</p>
          <div className="site-actions">
            <Link className="site-button" to="/contact">Start a project <ArrowRight size={17} /></Link>
            <Link className="site-button site-button-outline" to="/services">Explore our services</Link>
          </div>
          <div className="site-hero-proof"><span><CheckCircle2 size={15} /> Practical solutions</span><span><Globe2 size={15} /> Local and global clients</span></div>
        </div>
        <div className="site-hero-visual" aria-label="Abstract illustration of connected digital solutions">
          <div className="site-visual-glow" />
          <div className="site-visual-ring ring-one" />
          <div className="site-visual-ring ring-two" />
          <div className="site-visual-core"><span>T</span><small>TAWI DIGITAL</small></div>
          <div className="site-float-card float-ai"><span className="site-float-icon"><Bot size={18} /></span><span><b>AI & automation</b><small>Smarter workflows</small></span></div>
          <div className="site-float-card float-web"><span className="site-float-icon"><Code2 size={18} /></span><span><b>Digital products</b><small>Websites & applications</small></span></div>
          <div className="site-float-card float-it"><span className="site-float-icon"><Headset size={18} /></span><span><b>Technology support</b><small>Guidance that helps</small></span></div>
          <div className="site-visual-dots" />
        </div>
      </div>
      <div className="site-hero-bottom"><span>IDEAS INTO DIGITAL SOLUTIONS</span><span>01 — 04 <i /></span></div>
    </section>

    <section className="site-section site-services-section">
      <div className="site-section-heading">
        <div><Eyebrow>WHAT WE DO</Eyebrow><h2>One agency. <em>Four ways to move forward.</em></h2><p>We bring different areas of technology together to help you solve problems and make progress.</p></div>
        <Link to="/services" className="site-text-link">View all services <ArrowRight size={16} /></Link>
      </div>
      <div className="site-service-grid">{services.map((item, index) => <ServiceCard key={item.id} item={item} index={index} />)}</div>
    </section>

    <section className="site-about-band">
      <div className="site-about-graphic"><div className="site-about-square"><Layers3 size={45} /><span>IDEAS</span><i /><span>BUILT WITH PURPOSE</span></div></div>
      <div className="site-about-copy">
        <Eyebrow>ABOUT TAWI</Eyebrow>
        <h2>Good technology starts with <em>understanding people.</em></h2>
        <p>TAWI Digital Solutions is a Kenya-based digital agency working with individuals, entrepreneurs and businesses locally and internationally. We combine creative thinking and practical technology to build solutions around real needs.</p>
        <Link to="/about" className="site-text-link">Get to know TAWI <ArrowRight size={16} /></Link>
      </div>
    </section>

    <section className="site-section site-why-section">
      <div className="site-section-heading centered">
        <div><Eyebrow>THE TAWI APPROACH</Eyebrow><h2>Technology with <em>a clear purpose.</em></h2><p>We focus on understanding the challenge before deciding what to build.</p></div>
      </div>
      <div className="site-value-grid">
        <article><span><Compass size={22} /></span><h3>Thoughtful by design</h3><p>We start with your goals and choose an approach that makes sense for the problem.</p></article>
        <article><span><ShieldCheck size={22} /></span><h3>Clear and transparent</h3><p>We value honest conversations, realistic scope and clear expectations.</p></article>
        <article><span><Globe2 size={22} /></span><h3>Built for connection</h3><p>Based in Kenya and available to collaborate with clients across the world.</p></article>
      </div>
    </section>

    <section className="site-process-section">
      <div className="site-process-heading"><Eyebrow>HOW WE WORK</Eyebrow><h2>From first conversation <em>to meaningful progress.</em></h2><p>A straightforward process keeps the work focused and collaborative.</p><Link to="/contact" className="site-button site-button-light">Tell us about your idea <ArrowRight size={16} /></Link></div>
      <div className="site-steps">{steps.map(([number, title, description]) => <article key={number}><b>{number}</b><div><h3>{title}</h3><p>{description}</p></div></article>)}</div>
    </section>

    <section className="site-section site-project-preview">
      <div className="site-project-copy"><Eyebrow>SELECTED WORK</Eyebrow><h2>Ideas brought to life <em>through technology.</em></h2><p>Our project showcase is being prepared. We’ll be adding real project videos and demonstrations here.</p><Link to="/projects" className="site-text-link">Explore the project showcase <ArrowRight size={16} /></Link></div>
      <div className="site-project-placeholder"><div className="site-play-mark"><PlayCircle size={43} /></div><span>PROJECT SHOWCASE</span><b>Video demonstrations coming soon</b><small>Real work. Clear explanations. Practical solutions.</small></div>
    </section>

    <section className="site-final-cta"><div><Eyebrow>LET’S BUILD SOMETHING MEANINGFUL</Eyebrow><h2>Have an idea or a challenge to solve?</h2><p>Tell us what you have in mind. We’ll review your enquiry and get back to you.</p></div><Link className="site-button site-button-white" to="/contact">Send an enquiry <ArrowUpRight size={17} /></Link></section>
  </>;
}

function AboutPage() {
  return <main className="site-page">
    <section className="site-page-hero"><Eyebrow>ABOUT TAWI</Eyebrow><h1>A digital partner for <em>ideas worth building.</em></h1><p>We are a Kenya-based digital solutions agency helping individuals and businesses make better use of technology — wherever they are.</p></section>
    <section className="site-about-story"><div><span className="site-kicker">WHO WE ARE</span><h2>More than technology. <em>Solutions that make a difference.</em></h2></div><div><p>TAWI Digital Solutions brings together AI and automation, website and application development, digital transformation, and IT consulting and support.</p><p>We believe technology should be useful, understandable and shaped around the people who use it. That is why we begin by listening, understanding the challenge and identifying a practical way forward.</p><p>Our roots are in Kenya, and our work is open to clients and collaborators around the world.</p></div></section>
    <section className="site-mission-grid"><article><span>01 / OUR MISSION</span><h2>Make technology <em>work for people.</em></h2><p>To empower individuals and businesses through accessible, innovative and effective digital solutions.</p></article><article><span>02 / OUR VISION</span><h2>Help shape a more <em>connected future.</em></h2><p>To become a trusted digital solutions partner, contributing to a more connected, productive and technology-enabled future.</p></article></section>
    <section className="site-values"><div><Eyebrow>WHAT GUIDES US</Eyebrow><h2>Our values</h2></div><div className="site-values-list"><article><b>Purposeful innovation</b><p>We look for technology that addresses a real need.</p></article><article><b>Integrity and transparency</b><p>We communicate clearly and set honest expectations.</p></article><article><b>Quality and reliability</b><p>We care about thoughtful execution and dependable outcomes.</p></article><article><b>Continuous improvement</b><p>We keep learning, refining and finding better ways forward.</p></article></div></section>
    <section className="site-page-cta"><div><h2>Let’s explore what technology can do for your idea.</h2><p>Tell us what you are planning and start a conversation with TAWI.</p></div><Link className="site-button" to="/contact">Start a conversation <ArrowRight size={16} /></Link></section>
  </main>;
}

function ServicesPage() {
  return <main className="site-page">
    <section className="site-page-hero"><Eyebrow>OUR SERVICES</Eyebrow><h1>Practical technology for <em>what comes next.</em></h1><p>Four connected service areas. One focus: helping you move forward with solutions that fit your needs.</p></section>
    <section className="site-service-detail-list">{services.map((item, index) => { const Icon = item.icon; return <article key={item.id}><div className="site-detail-number">0{index + 1}</div><div className="site-detail-icon"><Icon size={25} /></div><div className="site-detail-content"><span>TAWI DIGITAL SOLUTIONS</span><h2>{item.title}</h2><h3>{item.short}</h3><p>{item.description}</p><p>{item.detail}</p><ul>{item.points.map(point => <li key={point}>{point}</li>)}</ul><Link to="/contact" className="site-text-link">Enquire about this service <ArrowUpRight size={15} /></Link></div></article>; })}</section>
    <section className="site-page-cta"><div><h2>Not sure which service you need?</h2><p>Describe your challenge in the enquiry form. We can help you explore the right starting point.</p></div><Link className="site-button" to="/contact">Tell us what you need <ArrowRight size={16} /></Link></section>
  </main>;
}

function ProjectsPage() {
  return <main className="site-page">
    <section className="site-page-hero"><Eyebrow>PROJECT SHOWCASE</Eyebrow><h1>Work that turns <em>ideas into experiences.</em></h1><p>Explore demonstrations and selected projects from TAWI Digital Solutions. This showcase is being prepared with project videos supplied for publication.</p></section>
    <section className="site-showcase-empty">
      <div className="site-showcase-icon"><PlayCircle size={35} /></div>
      <span>THE TAWI PROJECT SHOWCASE</span>
      <h2>Our first project videos are coming soon.</h2>
      <p>We’re preparing a collection of real demonstrations across AI and automation, websites and applications, digital transformation and IT solutions. Each feature will explain what the project does and the problem it is designed to address.</p>
      <Link to="/contact" className="site-button">Discuss a project <ArrowRight size={16} /></Link>
    </section>
    <div className="site-showcase-categories">{services.map(item => { const Icon = item.icon; return <div key={item.id}><Icon size={20} /><span>{item.title}</span></div>; })}</div>
  </main>;
}

const initialForm = { customer_name: '', customer_type: '', whatsapp: '', email: '', service_name: '', budget_range: '', message: '' };

function ContactPage() {
  const [form, setForm] = useState(initialForm);
  const [honeypot, setHoneypot] = useState('');
  const [status, setStatus] = useState('idle');
  const [error, setError] = useState('');

  function change(event) {
    setForm(current => ({ ...current, [event.target.name]: event.target.value }));
  }

  async function submit(event) {
    event.preventDefault();
    setError('');
    if (honeypot.trim()) { setStatus('sent'); return; }
    if (!supabase) { setError('The enquiry service is temporarily unavailable. Please try again later.'); return; }
    setStatus('sending');
    const payload = {
      customer_name: form.customer_name.trim(),
      customer_type: form.customer_type,
      whatsapp: form.whatsapp.trim(),
      email: form.email.trim() || null,
      service_name: form.service_name,
      budget_range: form.budget_range.trim() || null,
      message: form.message.trim(),
      status: 'new'
    };
    const { error: submitError } = await supabase.from('inquiries').insert(payload);
    if (submitError) {
      console.error('TAWI enquiry submission failed:', submitError);
      setError('We could not submit your enquiry right now. Please check your details and try again.');
      setStatus('idle');
      return;
    }
    setStatus('sent');
    setForm(initialForm);
  }

  return <main className="site-page site-contact-page">
    <section className="site-page-hero"><Eyebrow>CONTACT TAWI</Eyebrow><h1>Tell us what you’re <em>looking to build.</em></h1><p>Share a few details about your idea, project or technology challenge. Your enquiry goes directly to the TAWI team inbox, where our admins can review it and follow up with you.</p></section>
    <div className="site-contact-layout">
      <aside className="site-contact-aside">
        <div className="site-contact-note"><span><ShieldCheck size={20} /></span><b>Your enquiry goes to our team.</b><p>Our admins can review your details in the private TAWI workspace and contact you using the WhatsApp number you provide.</p></div>
        <div className="site-contact-method"><span><MessageCircle size={19} /></span><div><b>WhatsApp</b><small>{CONTACT.whatsapp ? 'Direct contact available' : 'Contact details coming soon'}</small></div></div>
        <div className="site-contact-method"><span><Mail size={19} /></span><div><b>Email</b><small>{CONTACT.email || 'Business email coming soon'}</small></div></div>
        <div className="site-contact-method"><span><Globe2 size={19} /></span><div><b>Where we work</b><small>Kenya and worldwide</small></div></div>
        <p className="site-contact-aside-foot">Prefer direct WhatsApp contact? That option will be enabled once our public contact number is added. For now, the enquiry form is the recommended way to reach us.</p>
      </aside>

      <section className="site-form-card">
        {status === 'sent' ? <div className="site-form-success" role="status"><span><CheckCircle2 size={34} /></span><Eyebrow>ENQUIRY RECEIVED</Eyebrow><h2>Thank you for reaching out.</h2><p>Your enquiry has been delivered to the TAWI team inbox. Our admins will review it and contact you using the WhatsApp number you provided.</p><button className="site-button" onClick={() => { setStatus('idle'); setError(''); }}>Submit another enquiry <ArrowRight size={16} /></button></div> : <>
          <div className="site-form-heading"><span>PROJECT ENQUIRY</span><h2>Let’s get to know your project.</h2><p>Fields marked with * are required.</p></div>
          <form className="site-enquiry-form" onSubmit={submit}>
            <label className="site-honeypot" aria-hidden="true">Leave this field empty<input tabIndex="-1" autoComplete="off" name="website" value={honeypot} onChange={event => setHoneypot(event.target.value)} /></label>
            <div className="site-form-grid">
              <label>Full name <b>*</b><input name="customer_name" value={form.customer_name} onChange={change} required maxLength="120" autoComplete="name" placeholder="Your name" /></label>
              <label>I am enquiring as <b>*</b><select name="customer_type" value={form.customer_type} onChange={change} required><option value="">Select one</option><option value="individual">An individual</option><option value="business">A business or organization</option></select></label>
              <label>WhatsApp number <b>*</b><input name="whatsapp" value={form.whatsapp} onChange={change} required minLength="7" maxLength="30" autoComplete="tel" placeholder="+254 7XX XXX XXX" /><small>Include your country code so our team can reach you.</small></label>
              <label>Email address <span>(optional)</span><input type="email" name="email" value={form.email} onChange={change} maxLength="254" autoComplete="email" placeholder="you@example.com" /></label>
              <label className="site-form-full">Service you’re interested in <b>*</b><select name="service_name" value={form.service_name} onChange={change} required><option value="">Choose a service</option>{services.map(item => <option key={item.id} value={item.title}>{item.title}</option>)}<option value="Not sure yet">Not sure yet</option></select></label>
              <label className="site-form-full">Estimated budget <span>(optional)</span><input name="budget_range" value={form.budget_range} onChange={change} maxLength="80" placeholder="Optional — include currency if known" /></label>
              <label className="site-form-full">Tell us about your project <b>*</b><textarea name="message" value={form.message} onChange={change} required minLength="10" maxLength="3000" rows="6" placeholder="What would you like to build, improve or get help with?" /></label>
            </div>
            {error && <p className="site-form-error" role="alert">{error}</p>}
            <button className="site-button" type="submit" disabled={status === 'sending'}>{status === 'sending' ? 'Submitting enquiry…' : 'Send enquiry'} <ArrowRight size={17} /></button>
            <p className="site-form-privacy">Your information is submitted securely and is only available to authorized TAWI team members for responding to your enquiry.</p>
          </form>
        </>}
      </section>
    </div>
  </main>;
}

function NotFoundPage() {
  return <main className="site-page site-not-found"><Eyebrow>404 · PAGE NOT FOUND</Eyebrow><h1>That page isn’t here.</h1><p>Let’s get you back to the TAWI Digital Solutions website.</p><Link to="/" className="site-button">Back to home <ArrowRight size={16} /></Link></main>;
}

export default function PublicSite({ page = 'home' }) {
  useEffect(() => {
    const titles = { home: 'TAWI Digital Solutions | Technology that moves your ideas forward', about: 'About | TAWI Digital Solutions', services: 'Services | TAWI Digital Solutions', projects: 'Projects | TAWI Digital Solutions', contact: 'Contact | TAWI Digital Solutions', notfound: 'Page not found | TAWI Digital Solutions' };
    document.title = titles[page] || titles.home;
    window.scrollTo({ top: 0, behavior: 'instant' });
  }, [page]);

  let content;
  if (page === 'about') content = <AboutPage />;
  else if (page === 'services') content = <ServicesPage />;
  else if (page === 'projects') content = <ProjectsPage />;
  else if (page === 'contact') content = <ContactPage />;
  else if (page === 'notfound') content = <NotFoundPage />;
  else content = <HomePage />;

  return <div className="public-site"><Header />{content}<Footer /></div>;
}
