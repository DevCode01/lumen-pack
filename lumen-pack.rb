#!/usr/bin/env ruby
# Static blog generator: Markdown posts -> HTML site + RSS feed.
require "fileutils"
require "date"

TEMPLATE = <<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head><meta charset="utf-8"><title>%s</title>
  <style>
    body { font-family: -apple-system, sans-serif; max-width: 680px; margin: 40px auto; padding: 0 20px; color: #24292e; }
    a { color: #0366d6; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .meta { color: #6a737d; font-size: 0.9em; }
    .post-item { margin-bottom: 18px; padding-bottom: 12px; border-bottom: 1px solid #eaecef; }
  </style>
  </head>
  <body>
  %s
  </body>
  </html>
HTML

def escape_html(text)
  text.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
end

def inline_markdown(text)
  text = escape_html(text)
  text = text.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
  text = text.gsub(/\*(.+?)\*/, '<em>\1</em>')
  text = text.gsub(/`(.+?)`/, '<code>\1</code>')
  text.gsub(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')
end

def markdown_to_html(body)
  lines = body.split("\n")
  html = []
  in_list = false
  lines.each do |line|
    stripped = line.strip
    is_item = stripped.start_with?("- ")
    if is_item && !in_list
      html << "<ul>"
      in_list = true
    elsif !is_item && in_list
      html << "</ul>"
      in_list = false
    end

    if is_item
      html << "<li>#{inline_markdown(stripped[2..])}</li>"
    elsif stripped.start_with?("## ")
      html << "<h2>#{inline_markdown(stripped[3..])}</h2>"
    elsif stripped.start_with?("# ")
      html << "<h1>#{inline_markdown(stripped[2..])}</h1>"
    elsif stripped.empty?
      html << ""
    else
      html << "<p>#{inline_markdown(line)}</p>"
    end
  end
  html << "</ul>" if in_list
  html.join("\n")
end

def parse_post(path)
  raw = File.read(path)
  filename = File.basename(path, ".md")
  # Expect: YYYY-MM-DD-slug.md, first non-empty line is title (# Title)
  date_match = filename.match(/^(\d{4}-\d{2}-\d{2})-(.+)$/)
  date = date_match ? date_match[1] : "1970-01-01"
  slug = date_match ? date_match[2] : filename

  lines = raw.split("\n")
  title_line = lines.find { |l| l.strip.start_with?("# ") }
  title = title_line ? title_line.strip[2..] : slug
  body = lines.reject { |l| l.equal?(title_line) }.join("\n")

  { title: title, date: date, slug: slug, body: body.strip }
end

def build(posts_dir, out_dir, site_title = "My Blog")
  FileUtils.mkdir_p(out_dir)
  files = Dir.glob(File.join(posts_dir, "*.md")).sort
  posts = files.map { |f| parse_post(f) }
  posts.sort_by! { |p| p[:date] }
  posts.reverse!

  posts.each do |post|
    body_html = markdown_to_html(post[:body])
    page_body = <<~HTML
      <p class="meta"><a href="index.html">&larr; Back to blog</a></p>
      <h1>#{escape_html(post[:title])}</h1>
      <p class="meta">#{post[:date]}</p>
      #{body_html}
    HTML
    File.write(File.join(out_dir, "#{post[:slug]}.html"), TEMPLATE % [escape_html(post[:title]), page_body])
  end

  items = posts.map do |p|
    "<div class=\"post-item\"><a href=\"#{p[:slug]}.html\">#{escape_html(p[:title])}</a> <span class=\"meta\">#{p[:date]}</span></div>"
  end.join("\n")
  index_body = "<h1>#{escape_html(site_title)}</h1>\n#{items}"
  File.write(File.join(out_dir, "index.html"), TEMPLATE % [escape_html(site_title), index_body])

  rss_items = posts.map do |p|
    "<item><title>#{escape_html(p[:title])}</title><pubDate>#{p[:date]}</pubDate></item>"
  end.join("\n")
  rss = "<?xml version=\"1.0\"?><rss version=\"2.0\"><channel><title>#{escape_html(site_title)}</title>#{rss_items}</channel></rss>"
  File.write(File.join(out_dir, "feed.xml"), rss)

  posts
end

if ARGV.empty?
  puts "Usage: blog.rb <posts_dir> [out_dir]"
  exit 1
end

posts_dir = ARGV[0]
out_dir = ARGV[1] || "site"
posts = build(posts_dir, out_dir)
puts "Built #{posts.size} post(s) into #{out_dir}/"
posts.each { |p| puts "  - #{p[:slug]}.html (#{p[:date]}) #{p[:title]}" }
