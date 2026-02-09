#!/usr/bin/env python3
"""
Markdown to HTML converter for Deep Research reports.

Converts a research report markdown file to styled HTML using
type-specific templates from the templates/ directory.

Usage:
    python3 md_to_html.py <markdown_file> [--output <output_file>] [--open]

The script:
1. Reads the markdown report
2. Detects research type from <!-- TYPE: xxx --> comment
3. Selects the appropriate HTML template
4. Extracts title, date, source count, metrics, content, bibliography
5. Converts markdown content to HTML
6. Fills the template and writes the output
"""

import argparse
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import markdown
from markdown.extensions.tables import TableExtension
from markdown.extensions.fenced_code import FencedCodeExtension


# Template routing: research type -> HTML template filename
TEMPLATE_ROUTING = {
    "technical": "technical_report_template.html",
    "comparison": "comparison_report_template.html",
    "stock": "mckinsey_report_template.html",
    "market": "mckinsey_report_template.html",
    "general": "general_report_template.html",
    "exploratory": "general_report_template.html",
}

TEMPLATES_DIR = Path(__file__).parent.parent / "skills" / "deep-research" / "templates"


def detect_research_type(md_content: str) -> str:
    """Detect research type from <!-- TYPE: xxx --> comment in markdown."""
    match = re.search(r"<!--\s*TYPE:\s*(\w+)\s*-->", md_content)
    if match:
        return match.group(1).lower()
    return "general"


def extract_title(md_content: str) -> str:
    """Extract title from first # heading."""
    match = re.search(r"^#\s+(.+)$", md_content, re.MULTILINE)
    if match:
        return match.group(1).strip()
    return "Research Report"


def extract_date(md_content: str) -> str:
    """Extract date from Report Metadata or use today's date."""
    match = re.search(r"\*\*Generated:\*\*\s*(.+)", md_content)
    if match:
        return match.group(1).strip()
    return datetime.now().strftime("%Y-%m-%d")


def extract_source_count(md_content: str) -> str:
    """Extract total source count from metadata or bibliography."""
    # Try from Report Metadata
    match = re.search(r"\*\*Total Sources:\*\*\s*(\d+)", md_content)
    if match:
        return match.group(1)
    # Count bibliography entries
    bib_entries = re.findall(r"^\[(\d+)\]", md_content, re.MULTILINE)
    if bib_entries:
        return str(len(bib_entries))
    return "0"


def split_content_and_bibliography(md_content: str) -> tuple[str, str]:
    """Split markdown into main content and bibliography section."""
    # Find the Bibliography section (supports both English and Chinese)
    bib_pattern = r"^##\s+(?:Bibliography|参考文献)\s*$"
    match = re.search(bib_pattern, md_content, re.MULTILINE)

    if not match:
        return md_content, ""

    bib_start = match.start()

    # Find the next ## section after Bibliography (or end of file)
    rest = md_content[match.end():]
    next_section = re.search(r"^##\s+", rest, re.MULTILINE)

    if next_section:
        bib_end = match.end() + next_section.start()
        bibliography_md = md_content[match.end():bib_end].strip()
    else:
        bibliography_md = rest.strip()
        bib_end = len(md_content)

    return md_content[:bib_start], bibliography_md


def extract_main_content(md_content: str) -> str:
    """Extract the main report content, excluding title line, TYPE comment,
    template reference comments, Report Metadata, and Appendix sections."""
    lines = md_content.split("\n")
    content_lines = []
    found_first_heading = False
    stop_entirely = False

    for line in lines:
        stripped = line.strip()

        if stop_entirely:
            break

        # Skip the first # heading (title)
        if not found_first_heading and re.match(r"^#\s+", stripped):
            found_first_heading = True
            continue

        # Skip HTML comments (TYPE, template references)
        if re.match(r"^<!--.*-->$", stripped):
            continue

        # Stop entirely at Report Metadata (everything after is trailing)
        if re.match(r"^##\s+(?:Report Metadata|报告元数据)", stripped):
            stop_entirely = True
            continue

        # Skip Appendix sections but continue looking for more content
        if re.match(r"^##\s+(?:Appendix|附录)", stripped):
            # Skip until next ## that isn't Appendix or Report Metadata
            continue

        # Stop at Bibliography (handled separately)
        if re.match(r"^##\s+(?:Bibliography|参考文献)", stripped):
            continue

        content_lines.append(line)

    return "\n".join(content_lines).strip()


def convert_md_to_html(md_text: str) -> str:
    """Convert markdown text to HTML using Python-Markdown with extensions."""
    md = markdown.Markdown(
        extensions=[
            "tables",
            "fenced_code",
            "sane_lists",
        ],
        output_format="html5",
    )
    return md.convert(md_text)


def post_process_html(html: str) -> str:
    """Apply template-specific CSS classes to converted HTML elements."""

    # Add CSS classes to headings
    html = re.sub(
        r"<h2>(.*?)</h2>",
        r'<div class="section-title">\1</div>',
        html,
    )
    html = re.sub(
        r"<h3>(.*?)</h3>",
        r'<div class="subsection-title">\1</div>',
        html,
    )

    # Add CSS class to tables
    html = html.replace("<table>", '<table class="data-table">')

    # Convert citation references [N] to styled spans
    html = re.sub(
        r"\[(\d+)\]",
        r'<span class="citation">[\1]</span>',
        html,
    )

    # Wrap Executive Summary content in styled div (supports both Chinese and English)
    html = re.sub(
        r'(<div class="section-title">(?:Executive Summary|执行摘要)</div>\s*)(.*?)(<div class="section-title">)',
        lambda m: (
            m.group(1)
            + '<div class="executive-summary">'
            + m.group(2)
            + "</div>"
            + m.group(3)
        ),
        html,
        count=1,
        flags=re.DOTALL,
    )

    # Remove emojis (careful to avoid CJK ranges U+4E00-U+9FFF)
    emoji_pattern = re.compile(
        "["
        "\U0001F600-\U0001F64F"  # emoticons
        "\U0001F300-\U0001F5FF"  # symbols & pictographs
        "\U0001F680-\U0001F6FF"  # transport & map
        "\U0001F1E0-\U0001F1FF"  # flags
        "\U0001F900-\U0001F9FF"  # supplemental symbols
        "\U0001FA00-\U0001FA6F"  # chess symbols
        "\U0001FA70-\U0001FAFF"  # symbols extended-A
        "\u2702-\u27B0"          # dingbats
        "\u2600-\u26FF"          # misc symbols
        "\u2700-\u27BF"          # dingbats
        "\u23E9-\u23F3"          # media control
        "\u23F8-\u23FA"          # media control
        "\u200d"                 # zero width joiner
        "\ufe0f"                 # variation selector
        "]+",
        flags=re.UNICODE,
    )
    html = emoji_pattern.sub("", html)

    return html


def format_bibliography(bib_md: str) -> str:
    """Convert bibliography markdown to styled HTML entries."""
    entries = []
    # Match [N] entries - each entry may span multiple lines
    raw_entries = re.split(r"(?=^\[\d+\])", bib_md, flags=re.MULTILINE)

    for entry in raw_entries:
        entry = entry.strip()
        if not entry:
            continue

        match = re.match(r"^\[(\d+)\]\s*(.*)", entry, re.DOTALL)
        if match:
            num = match.group(1)
            text = match.group(2).strip()
            # Convert URLs to links
            text = re.sub(
                r"(https?://\S+)",
                r'<a href="\1" target="_blank">\1</a>',
                text,
            )
            entries.append(
                f'<div class="bib-entry">'
                f'<span class="bib-number">[{num}]</span> {text}'
                f"</div>"
            )

    return "\n".join(entries)


def build_metrics_dashboard(md_content: str, research_type: str) -> str:
    """Build metrics dashboard HTML from report metadata."""
    source_count = extract_source_count(md_content)

    # Extract research mode
    mode_match = re.search(r"\*\*Research Mode:\*\*\s*(.+)", md_content)
    mode = mode_match.group(1).strip() if mode_match else "Standard"

    # Count sections (## headings)
    sections = re.findall(r"^##\s+", md_content, re.MULTILINE)
    section_count = len(sections)

    # Estimate word count
    word_count = len(md_content.split())
    if word_count >= 1000:
        word_display = f"{word_count // 1000}K+"
    else:
        word_display = str(word_count)

    # Extract confidence level if present
    confidence_match = re.search(
        r"\*\*(?:信心等级|Confidence Level|信心水平)\*?\*?[:：]\s*(.+?)(?:\n|$)",
        md_content,
    )
    confidence = confidence_match.group(1).strip() if confidence_match else None

    metrics = [
        ("Sources", source_count),
        ("Sections", str(section_count)),
        ("Words", word_display),
        ("Mode", mode),
    ]

    if confidence:
        # Strip leftover markdown bold markers and truncate long text
        conf_short = confidence.strip("* ")
        conf_short = conf_short.split("（")[0].split("(")[0].strip()
        metrics.append(("Confidence", conf_short))

    metric_html_parts = []
    for label, value in metrics:
        metric_html_parts.append(
            f'<div class="metric">'
            f'<span class="metric-number">{value}</span>'
            f'<span class="metric-label">{label}</span>'
            f"</div>"
        )

    return (
        '<div class="metrics-dashboard">'
        + "\n".join(metric_html_parts)
        + "</div>"
    )


def convert_report(md_path: str, output_path: str = None, open_browser: bool = False):
    """Main conversion function."""
    md_path = Path(md_path)
    if not md_path.exists():
        print(f"Error: File not found: {md_path}", file=sys.stderr)
        sys.exit(1)

    # Read markdown
    md_content = md_path.read_text(encoding="utf-8")

    # Detect research type and select template
    research_type = detect_research_type(md_content)
    template_file = TEMPLATE_ROUTING.get(research_type, TEMPLATE_ROUTING["general"])
    template_path = TEMPLATES_DIR / template_file

    if not template_path.exists():
        print(f"Error: Template not found: {template_path}", file=sys.stderr)
        sys.exit(1)

    print(f"Research type: {research_type}")
    print(f"Template: {template_file}")

    # Read template
    template = template_path.read_text(encoding="utf-8")

    # Extract components
    title = extract_title(md_content)
    date = extract_date(md_content)
    source_count = extract_source_count(md_content)

    print(f"Title: {title}")
    print(f"Date: {date}")
    print(f"Sources: {source_count}")

    # Split content and bibliography
    content_md_full, bibliography_md = split_content_and_bibliography(md_content)

    # Extract main content (excluding title, metadata, appendix)
    main_content_md = extract_main_content(content_md_full)

    # Convert markdown to HTML
    content_html = convert_md_to_html(main_content_md)
    content_html = post_process_html(content_html)

    # Format bibliography
    bibliography_html = format_bibliography(bibliography_md)

    # Build metrics dashboard
    metrics_html = build_metrics_dashboard(md_content, research_type)

    # Fill template
    html = template.replace("{{TITLE}}", title)
    html = html.replace("{{DATE}}", date)
    html = html.replace("{{SOURCE_COUNT}}", source_count)
    html = html.replace("{{METRICS_DASHBOARD}}", metrics_html)
    html = html.replace("{{CONTENT}}", content_html)
    html = html.replace("{{BIBLIOGRAPHY}}", bibliography_html)

    # Set language to zh-CN for Chinese reports
    html = html.replace('<html lang="en">', '<html lang="zh-CN">')

    # Determine output path
    if output_path is None:
        output_path = md_path.with_suffix(".html")
    else:
        output_path = Path(output_path)

    # Write output
    output_path.write_text(html, encoding="utf-8")
    print(f"Output: {output_path}")
    print(f"Size: {output_path.stat().st_size:,} bytes")

    # Open in browser if requested
    if open_browser:
        if sys.platform == "darwin":
            subprocess.run(["open", str(output_path)])
        elif sys.platform == "linux":
            subprocess.run(["xdg-open", str(output_path)])
        print("Opened in browser.")


def main():
    parser = argparse.ArgumentParser(
        description="Convert Deep Research markdown reports to styled HTML."
    )
    parser.add_argument("markdown_file", help="Path to the markdown report file")
    parser.add_argument(
        "--output", "-o", help="Output HTML file path (default: same name with .html)"
    )
    parser.add_argument(
        "--open", action="store_true", help="Open the HTML file in browser after conversion"
    )

    args = parser.parse_args()
    convert_report(args.markdown_file, args.output, args.open)


if __name__ == "__main__":
    main()
