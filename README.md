# ELF Jekyll

Welcome to v3.0 of the Extraordinary Lives Foundation website.

## Local Development

1. Clone this repo
2. Install ruby (if not installed already)
3. Run `bundle` to install all the packages
4. Run `jekyll serve` to start a local server

## Deployment

This site is currently running on [Netlify](https://netlify.com). Any pushes
to the `master` branch are automatically deployed to production, so a
"deployment" is as simple as `git push` from the `master` branch.

It is important to note that content creators to not commit to this repository
direcly. Instead, [SiteLeaf](https://siteleaf.com) is configured to provide
a CMS interface, which then performs commits to the same repository. Netlify
does not care where the commmits come from, it just re-builds the website as
needed.
