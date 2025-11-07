# HTML/CSS DApp Landing Page

Modern, responsive landing page for Web3 decentralized applications.

## Features

- **Responsive Design**: Mobile-first, works on all devices
- **Modern UI**: Gradient accents, glassmorphism effects
- **Web3 Integration**: MetaMask wallet connection
- **Smooth Animations**: Scroll-based animations
- **Performance**: Optimized CSS and vanilla JavaScript
- **Accessibility**: Semantic HTML, ARIA labels

## Tech Stack

- **HTML5**: Semantic markup
- **CSS3**: Custom properties, Grid, Flexbox
- **Vanilla JavaScript**: No frameworks needed
- **Web3.js**: Ethereum integration (optional)

## Preview

The landing page includes:
- Hero section with call-to-action
- Feature cards highlighting capabilities
- Language showcase grid
- Project portfolio
- Responsive navigation
- Footer with links

## Setup

### Local Development

```bash
cd html-css/dapp-landing

# Serve with Python
python -m http.server 8000

# Or with Node.js
npx serve .
```

Open http://localhost:8000

### Deploy to GitHub Pages

1. Push to repository
2. Go to Settings → Pages
3. Select branch and folder
4. Your site will be live at `https://username.github.io/repo`

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd html-css/dapp-landing
vercel
```

### Deploy to Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod
```

## Customization

### Colors

Edit CSS variables in `styles.css`:

```css
:root {
    --primary-color: #6366f1;
    --secondary-color: #8b5cf6;
    --bg-dark: #0f172a;
    --bg-card: #1e293b;
}
```

### Content

Edit `index.html`:

```html
<h1 class="hero-title">
    Build the Future with
    <span class="gradient-text">Your Brand</span>
</h1>
```

### Add Web3 Functionality

Include Web3.js or Ethers.js:

```html
<script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js"></script>
```

Update `app.js`:

```javascript
const web3 = new Web3(window.ethereum);
const accounts = await web3.eth.requestAccounts();
const balance = await web3.eth.getBalance(accounts[0]);
```

## Features Explained

### Wallet Connection

```javascript
const accounts = await window.ethereum.request({
    method: 'eth_requestAccounts'
});
```

Connects to MetaMask and displays account.

### Smooth Scrolling

```javascript
target.scrollIntoView({
    behavior: 'smooth',
    block: 'start'
});
```

### Intersection Observer

```javascript
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
});
```

Animates elements on scroll.

## Responsive Breakpoints

```css
/* Mobile */
@media (max-width: 768px) {
    .hero-title {
        font-size: 2.5rem;
    }
}

/* Tablet */
@media (min-width: 769px) and (max-width: 1024px) {
    /* Styles */
}

/* Desktop */
@media (min-width: 1025px) {
    /* Styles */
}
```

## Performance Optimization

### Images

```html
<img src="image.jpg"
     srcset="image-480.jpg 480w,
             image-800.jpg 800w"
     sizes="(max-width: 768px) 100vw, 50vw"
     alt="Description"
     loading="lazy">
```

### CSS

```css
/* Use CSS Grid for layouts */
.grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}

/* Reduce repaints */
.element {
    will-change: transform;
    transform: translateZ(0);
}
```

### JavaScript

```javascript
// Debounce scroll events
let timeout;
window.addEventListener('scroll', () => {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
        // Handle scroll
    }, 100);
});
```

## SEO Optimization

### Meta Tags

```html
<meta name="description" content="Your description">
<meta name="keywords" content="web3, blockchain, dapp">
<meta property="og:title" content="Your Title">
<meta property="og:description" content="Description">
<meta property="og:image" content="preview.jpg">
<meta name="twitter:card" content="summary_large_image">
```

### Structured Data

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "Your DApp",
  "description": "Description"
}
</script>
```

## Accessibility

```html
<!-- Semantic HTML -->
<nav aria-label="Main navigation">
  <ul>
    <li><a href="#features">Features</a></li>
  </ul>
</nav>

<!-- ARIA labels -->
<button aria-label="Connect Wallet">
  Connect
</button>

<!-- Skip to content -->
<a href="#main" class="skip-link">
  Skip to main content
</a>
```

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## License

MIT
