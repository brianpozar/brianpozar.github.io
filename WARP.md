# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common development commands

This repository is a Jekyll site built with the `github-pages` gem and Bundler.

- **Install Ruby dependencies** (first time or after Gemfile changes): `bundle install`
- **Run the local development server** (auto-rebuild on changes): `bundle exec jekyll serve`
  - Site will be available at `http://localhost:4000` by default.
- **Build the static site locally** (mirrors what GitHub Pages does): `bundle exec jekyll build`
  - Output is written to the `_site/` directory (do not commit or edit files there manually).
- **Check for build/template issues**: rely on `bundle exec jekyll build` or `bundle exec jekyll serve` failing on configuration or Liquid errors.

There is no dedicated automated test or linting setup in this repo beyond Jekyll’s own build-time checks.

Deployment is handled by GitHub Pages when changes are pushed to the default branch of this `username.github.io` repository.

## Project architecture

### Jekyll configuration and navigation

- `_config.yml` defines global site settings (title, description, base URL, permalink style) and the single `posts` collection.
- The `nav` array in `_config.yml` drives the primary navigation items (Home, CV, Apps, Articles, Contact). Update this list to add/remove top-level navigation links used by the header include.
- `headshot` in `_config.yml` points to the author’s image under `assets/img/` and is used in both the home page and CV layout.

### Layouts and includes

- `_layouts/default.html` is the base HTML skeleton for all pages.
  - It includes shared partials via `_includes/head.html`, `_includes/header.html`, and `_includes/footer.html`.
  - It wraps all page content in a `.site-shell` container and loads `assets/js/theme-toggle.js` at the end of the body.
- `_layouts/home.html` extends `default` and implements the landing page hero, topic strip, and "On this site" / "Latest Articles" sections.
  - "Latest Articles" uses `site.posts | slice: 0, 3` to show the three most recent posts.
- `_layouts/page.html` is the generic layout for static pages such as the CV, Apps, and Contact pages.
  - It expects `title` and optional `subtitle` in front matter and renders the page body within `.page-content`.
- `_layouts/post.html` is the layout for individual blog posts.
  - It renders the post date, title, optional subtitle, and the main content.

The `_includes/` directory contains reusable fragments for the `<head>`, site header/navigation, and footer; these are responsible for wiring up the navigation defined in `_config.yml` and any shared markup or metadata.

### Pages, posts, and sections

- `index.md` uses the `home` layout and acts as the main landing page.
- `about.md` is the CV page (`/cv/`), using the `page` layout and primarily Markdown content.
- `projects.md` is the Apps overview page (`/apps/`), also using the `page` layout and linking into more detailed app-specific pages.
- `blog/index.html` is the Articles index page (`/blog/`), using the `page` layout and then rendering its own listing of all `site.posts`.
- The `contact/` directory contains `index.html`, a `page` layout-backed contact form that:
  - Uses a simple HTML form with client-side JavaScript.
  - Assembles the destination email address and message body in JavaScript, then opens the user’s email client via a `mailto:` link (no backend).
- `wellsaid.md` and `wellsaid-privacy-policy.md` are standalone pages for an app and its privacy policy.
- Blog posts live under `_posts/` using standard Jekyll naming and the `post` layout.

### Assets and client-side behavior

- `assets/css/` contains the site’s stylesheet(s) defining the layout, typography, and theming for the layouts and components referenced above.
- `assets/js/theme-toggle.js` controls light/dark mode:
  - Reads a stored preference from `localStorage` (`bp-theme`) or falls back to the OS `prefers-color-scheme` setting, defaulting to dark.
  - Applies the theme via a `data-theme` attribute on the `<html>` element.
  - Attaches a click handler to `.theme-toggle` to toggle between light and dark themes and persist the choice.
- `assets/img/` holds images including the headshot referenced from `_config.yml` and `home.html`.
- `CNAME` configures the custom domain for GitHub Pages.

### Generated and vendor content

- `_site/` contains the generated static site output from `jekyll build` or `jekyll serve` and should be treated as a build artifact (do not edit files here; edit the source templates/content instead).
- `vendor/` and `.bundle/` contain vendored Ruby gems and Bundler metadata to support GitHub Pages and local builds; these should not be hand-edited except when updating dependencies via Bundler.
