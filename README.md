# Lumen Pack

**Ruby** · **v0.1.0**

_Static blog generator: dated Markdown posts to HTML with RSS feed_

---

## Features

- Posts named YYYY-MM-DD-slug.md, sorted newest first
- Hand-written Markdown parser (headers, bold, italic, links, lists)
- Generates an index page and an RSS feed, zero dependencies

## Installation

```bash
git clone https://github.com/DevCode01/lumen-pack.git
cd lumen-pack
```

## Usage

```bash
ruby lumen-pack.rb posts site
```

## How it works

Posts are named `YYYY-MM-DD-slug.md` with the title on the first `# ` heading line; the rest is converted with a small hand-written Markdown parser. Posts are sorted by the date embedded in the filename (newest first), then an index page and an RSS feed are generated alongside each post's HTML page.

## Options

- `<posts_dir>` - directory of `YYYY-MM-DD-slug.md` files (required)
- `<out_dir>` - output directory (default `site`)

## Example

```bash
$ ruby lumen-pack.rb posts site
Built 2 post(s) into site/
  - second.html (2026-02-20) A second post
  - welcome.html (2026-01-10) Welcome to my blog
```

## Testing

```bash
bash tests/run.sh
```

Includes a functional check against real captured output, plus the build/syntax check.

## License

MIT
