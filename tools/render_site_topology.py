#!/usr/bin/env python3
"""Render discovery and shared navigation from the site-topology register.

The register owns route topology and reader-facing discovery annotations. It
does not replace the source pages that own mathematical claims, source pins,
DOIs, or result statuses.

Run from the repository root:
    python3 -I tools/render_site_topology.py --write
    python3 -I tools/render_site_topology.py --check
"""
from __future__ import annotations

import argparse
import json
import re
from datetime import date
from html import escape as html_escape
from html.parser import HTMLParser
from pathlib import Path
from xml.sax.saxutils import escape


DEFAULT_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = Path("research/site-topology-v0.1.json")
OUTPUTS = (Path("sitemap.xml"), Path("llms.txt"), Path("llms-full.txt"))
STAGE_SENTINEL = ".coppalini-public-stage"
PRIMARY_NAV = re.compile(
    r'<nav\b(?=[^>]*\sclass\s*=\s*["\'][^"\']*(?<![A-Za-z0-9_-])primary-nav(?![A-Za-z0-9_-])[^"\']*["\'])[^>]*>.*?</nav>',
    re.IGNORECASE | re.DOTALL,
)


class PageMeta(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.canonicals: list[str] = []
        self.robots: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        rel_tokens = (values.get("rel") or "").casefold().split()
        if tag.casefold() == "link" and "canonical" in rel_tokens and values.get("href"):
            self.canonicals.append(values["href"])
        if tag.casefold() == "meta" and (values.get("name") or "").casefold() == "robots":
            self.robots.append(values.get("content") or "")


def fail(message: str) -> None:
    raise ValueError(message)


def load_manifest(root: Path) -> dict:
    path = root / MANIFEST_PATH
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail("site topology register is missing")
    except json.JSONDecodeError as exc:
        fail("site topology register is invalid JSON: " + str(exc))
    if not isinstance(value, dict):
        fail("site topology register must be an object")
    return value


def root_path(root: Path, relative: str, context: str) -> Path:
    root = root.resolve()
    relative_path = Path(relative) if isinstance(relative, str) else None
    if not isinstance(relative, str) or not relative or relative_path.is_absolute() or ".." in relative_path.parts:
        fail(context + ": invalid relative path")
    candidate = (root / relative_path).resolve()
    try:
        candidate.relative_to(root)
    except ValueError:
        fail(context + ": path escapes site root")
    return candidate


def route_file(root: Path, route: str) -> Path | None:
    route = route.split("#", 1)[0].split("?", 1)[0]
    if not route.startswith("/"):
        return None
    if route == "/":
        return root / "index.html"
    try:
        target = root_path(root, route.lstrip("/"), "route " + route)
    except ValueError:
        return None
    for candidate in (target, Path(str(target) + ".html"), target / "index.html"):
        if candidate.is_file():
            return candidate
    return None


def page_meta(path: Path) -> PageMeta:
    parser = PageMeta()
    parser.feed(path.read_text(encoding="utf-8"))
    return parser


def response_headers(root: Path) -> dict[str, dict[str, list[str]]]:
    """Read the small Netlify `_headers` subset needed for canonical checks."""
    path = root / "_headers"
    if not path.is_file():
        return {}
    entries: dict[str, dict[str, list[str]]] = {}
    current: str | None = None
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if raw[:1].isspace():
            if current is None or ":" not in stripped:
                fail("_headers:" + str(number) + ": header without a route")
            key, value = stripped.split(":", 1)
            entries[current].setdefault(key.strip().casefold(), []).append(value.strip())
            continue
        if not stripped.startswith("/"):
            fail("_headers:" + str(number) + ": route must start with /")
        current = stripped
        entries.setdefault(current, {})
    return entries


def in_nested_stage(root: Path, path: Path) -> bool:
    """Return whether path is inside a staged payload nested below root.

    A staged root itself must still be scanned. This only ignores a prior build
    directory when source validation is run from its containing checkout.
    """
    current = path.parent
    while current != root:
        if (current / STAGE_SENTINEL).is_file():
            return True
        current = current.parent
    return False


def excluded_from_source_inventory(root: Path, path: Path) -> bool:
    relative = path.relative_to(root).as_posix()
    return relative.startswith("archive/") or in_nested_stage(root, path)


def required_string(record: dict, key: str, context: str) -> str:
    value = record.get(key)
    if not isinstance(value, str) or not value:
        fail(context + ": missing non-empty " + key)
    return value


def markdown_link(base: str, link: dict) -> str:
    label = required_string(link, "label", "link")
    route = required_string(link, "route", "link")
    if route.startswith("/"):
        return f"[{label}]({base}{route})"
    return f"[{label}]({route})"


def format_links(base: str, links: list[dict]) -> str:
    return " · ".join(markdown_link(base, link) for link in links)


def nav_html(profile: list[dict], active: str | None) -> str:
    links: list[str] = []
    for item in profile:
        item_id = item["id"]
        current = ' aria-current="page"' if item_id == active else ""
        route = html_escape(item["route"], quote=True)
        label = html_escape(item["label"])
        links.append(f'<a href="{route}"{current}>{label}</a>')
    return '<nav class="primary-nav" aria-label="Primary">' + "".join(links) + "</nav>"


def topology_maps(manifest: dict) -> tuple[dict[str, dict], dict[str, dict], dict[str, list[dict]]]:
    routes = manifest.get("routes")
    groups = manifest.get("groups")
    profiles = manifest.get("nav_profiles")
    if not isinstance(routes, list) or not isinstance(groups, list) or not isinstance(profiles, dict):
        fail("topology register needs routes, groups, and nav_profiles")
    by_id: dict[str, dict] = {}
    by_route: dict[str, dict] = {}
    for record in routes:
        if not isinstance(record, dict):
            fail("topology route record is not an object")
        route_id = required_string(record, "id", "route record")
        route = required_string(record, "route", route_id)
        if not route.startswith("/"):
            fail(route_id + ": route must start with /")
        if route_id in by_id or route in by_route:
            fail("duplicate route id or path: " + route_id)
        by_id[route_id] = record
        by_route[route] = record
    group_map: dict[str, dict] = {}
    for group in groups:
        if not isinstance(group, dict):
            fail("topology group is not an object")
        group_id = required_string(group, "id", "group")
        if group_id in group_map:
            fail("duplicate group: " + group_id)
        required_string(group, "heading", group_id)
        route_ids = group.get("routes")
        if not isinstance(route_ids, list):
            fail(group_id + ": routes must be a list")
        group_map[group_id] = group
    normalized_profiles: dict[str, list[dict]] = {}
    for profile_id, profile in profiles.items():
        if not isinstance(profile_id, str) or not isinstance(profile, list) or not profile:
            fail("invalid navigation profile")
        seen: set[str] = set()
        normalized_profiles[profile_id] = []
        for item in profile:
            if not isinstance(item, dict):
                fail(profile_id + ": navigation item is not an object")
            item_id = required_string(item, "id", profile_id)
            if item_id in seen:
                fail(profile_id + ": duplicate navigation item " + item_id)
            seen.add(item_id)
            normalized_profiles[profile_id].append({
                "id": item_id,
                "label": required_string(item, "label", profile_id),
                "route": required_string(item, "route", profile_id),
            })
    if "primary" not in normalized_profiles:
        fail("topology register needs a primary navigation profile")
    return by_id, group_map, normalized_profiles


def validate_links(root: Path, record: dict, key: str) -> None:
    links = record.get(key, [])
    if not isinstance(links, list):
        fail(record["id"] + ": " + key + " must be a list")
    for link in links:
        if not isinstance(link, dict):
            fail(record["id"] + ": " + key + " link is not an object")
        required_string(link, "label", record["id"])
        route = required_string(link, "route", record["id"])
        if route.startswith("/") and route_file(root, route) is None:
            fail(record["id"] + ": missing " + key + " target " + route)


def validate_manifest(root: Path, manifest: dict, rendered_nav: bool = False) -> tuple[dict[str, dict], dict[str, dict], dict[str, list[dict]]]:
    root = root.resolve()
    if manifest.get("schema") != "CoppaliniArchitecture.Site-Topology/v0.1":
        fail("unexpected site topology schema")
    site = manifest.get("site")
    if not isinstance(site, dict):
        fail("topology register lacks site section")
    base = required_string(site, "base_url", "site").rstrip("/")
    for key in ("short_intro", "full_intro", "disclosures"):
        values = site.get(key)
        if not isinstance(values, list) or not values or not all(isinstance(value, str) and value for value in values):
            fail("site " + key + " must be a non-empty string list")
    by_id, groups, profiles = topology_maps(manifest)
    headers = response_headers(root)
    seen_group_routes: set[str] = set()
    for group in groups.values():
        for route_id in group["routes"]:
            if not isinstance(route_id, str) or route_id not in by_id:
                fail(group["id"] + ": unknown route id")
            record = by_id[route_id]
            if record.get("discovery") != "sitemap":
                fail(group["id"] + ": non-discovery route appears in group")
            if record.get("group") != group["id"]:
                fail(group["id"] + ": route has a mismatched group field: " + route_id)
            if route_id in seen_group_routes:
                fail("discovery route appears in more than one group: " + route_id)
            seen_group_routes.add(route_id)
    source_owners: dict[str, str] = {}
    primary_sources: set[str] = set()
    routes_by_path = {record["route"]: record for record in by_id.values()}
    for profile_id, profile in profiles.items():
        for item in profile:
            route = item["route"]
            target = routes_by_path.get(route)
            if target is None:
                fail(profile_id + ": navigation route is not registered: " + route)
            if target.get("area") == "development":
                fail(profile_id + ": navigation route points to development: " + route)
    for record in by_id.values():
        route_id = record["id"]
        discovery = record.get("discovery")
        if discovery not in {"sitemap", "exclude"}:
            fail(route_id + ": discovery must be sitemap or exclude")
        if record.get("area") not in {"locked", "development", "archive"}:
            fail(route_id + ": invalid area")
        if record.get("area") == "development" and discovery != "exclude":
            fail(route_id + ": development route cannot enter sitemap discovery")
        source_files = record.get("source_files")
        if not isinstance(source_files, list) or not source_files or not all(isinstance(item, str) and item for item in source_files):
            fail(route_id + ": source_files must be a non-empty string list")
        nav_profile = record.get("nav_profile")
        if nav_profile not in {"primary", "none"}:
            fail(route_id + ": invalid nav_profile")
        active = record.get("nav_active")
        if nav_profile == "primary" and active is not None and active not in {item["id"] for item in profiles["primary"]}:
            fail(route_id + ": unknown nav_active item")
        robots_header = record.get("robots_header")
        header_noindex = False
        if robots_header is not None:
            if not isinstance(robots_header, str) or not robots_header:
                fail(route_id + ": robots_header must be a non-empty string")
            if "noindex" not in robots_header.casefold():
                fail(route_id + ": robots_header must declare noindex")
            robot_paths = record.get("robots_header_paths", [record["route"]])
            if not isinstance(robot_paths, list) or not robot_paths or not all(isinstance(item, str) and item.startswith("/") for item in robot_paths):
                fail(route_id + ": robots_header_paths must be a non-empty route list")
            for robot_path in robot_paths:
                values = headers.get(robot_path, {}).get("x-robots-tag", [])
                if not any(robots_header.casefold() == value.casefold() for value in values):
                    fail(route_id + ": missing X-Robots-Tag header for " + robot_path)
            header_noindex = True
        resolved_sources: set[Path] = set()
        for source in source_files:
            path = root_path(root, source, route_id)
            normalized_source = path.relative_to(root).as_posix()
            if normalized_source in source_owners:
                fail(route_id + ": source file also owned by " + source_owners[normalized_source] + ": " + normalized_source)
            source_owners[normalized_source] = route_id
            resolved_sources.add(path)
            if nav_profile == "primary":
                primary_sources.add(normalized_source)
            if not path.is_file():
                fail(route_id + ": missing source file " + source)
            metadata = page_meta(path)
            canonical_policy = record.get("canonical")
            if canonical_policy not in {"required", "header", "absent"}:
                fail(route_id + ": canonical policy must be required, header, or absent")
            if canonical_policy == "required":
                expected = base + record["route"]
                if metadata.canonicals != [expected]:
                    fail(route_id + ": canonical mismatch in " + source)
            elif canonical_policy == "header":
                if metadata.canonicals:
                    fail(route_id + ": HTML canonical must be absent when response header is authoritative")
                header_paths = record.get("canonical_header_paths", [record["route"]])
                if not isinstance(header_paths, list) or not header_paths or not all(isinstance(item, str) and item.startswith("/") for item in header_paths):
                    fail(route_id + ": canonical_header_paths must be a non-empty route list")
                expected = f"<{base + record['route']}>; rel=\"canonical\""
                for header_path in header_paths:
                    if expected not in headers.get(header_path, {}).get("link", []):
                        fail(route_id + ": missing canonical Link header for " + header_path)
            elif metadata.canonicals:
                fail(route_id + ": canonical must be absent in " + source)
            noindex = any("noindex" in value.casefold() for value in metadata.robots)
            if discovery == "sitemap" and (noindex or header_noindex):
                fail(route_id + ": noindex source cannot be sitemap-discovered")
            if discovery == "exclude" and record.get("area") == "development" and not noindex:
                fail(route_id + ": development source must be noindex")
            nav_count = len(PRIMARY_NAV.findall(path.read_text(encoding="utf-8")))
            if nav_profile == "primary":
                if nav_count != 1:
                    fail(route_id + ": primary profile must have exactly one primary nav in " + source)
                if rendered_nav:
                    expected_nav = nav_html(profiles["primary"], active)
                    actual_nav = PRIMARY_NAV.findall(path.read_text(encoding="utf-8"))[0]
                    if actual_nav != expected_nav:
                        fail(route_id + ": staged primary nav differs from topology profile in " + source)
            elif nav_count:
                fail(route_id + ": none profile unexpectedly has primary nav in " + source)
        resolved_route = route_file(root, record["route"])
        if resolved_route is None or resolved_route.resolve() not in resolved_sources:
            fail(route_id + ": route does not resolve to a declared source file")
        if discovery == "sitemap":
            for key in ("title", "summary", "detail", "group"):
                required_string(record, key, route_id)
            if record["group"] not in groups:
                fail(route_id + ": unknown group")
            if route_id not in seen_group_routes:
                fail(route_id + ": sitemap route missing from group")
            lastmod = record.get("lastmod")
            if lastmod is not None:
                if not isinstance(lastmod, str) or len(lastmod) != 10:
                    fail(route_id + ": invalid lastmod")
                try:
                    date.fromisoformat(lastmod)
                except ValueError:
                    fail(route_id + ": invalid lastmod")
        validate_links(root, record, "formal_basis")
        validate_links(root, record, "check")
        validate_links(root, record, "source_records")
    if {record_id for record_id, record in by_id.items() if record.get("discovery") == "sitemap"} != seen_group_routes:
        fail("group topology does not cover exactly the sitemap routes")
    unregistered_navs: list[str] = []
    unregistered_indexable: list[str] = []
    for path in root.rglob("*.html"):
        relative = path.relative_to(root).as_posix()
        if excluded_from_source_inventory(root, path):
            continue
        metadata = page_meta(path)
        noindex = any("noindex" in value.casefold() for value in metadata.robots)
        if not noindex and relative not in source_owners:
            unregistered_indexable.append(relative)
        if PRIMARY_NAV.search(path.read_text(encoding="utf-8")) and relative not in primary_sources:
            unregistered_navs.append(relative)
    if unregistered_navs:
        fail("primary navigation source missing from topology register: " + ", ".join(sorted(unregistered_navs)))
    if unregistered_indexable:
        fail("indexable source missing from topology register: " + ", ".join(sorted(unregistered_indexable)))
    return by_id, groups, profiles


def ordered_sitemap_routes(manifest: dict) -> list[dict]:
    by_id, groups, _ = topology_maps(manifest)
    ordered: list[dict] = []
    for group in manifest["groups"]:
        ordered.extend(by_id[route_id] for route_id in group["routes"])
    return ordered


def render_sitemap(manifest: dict) -> str:
    base = manifest["site"]["base_url"].rstrip("/")
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
        '  <!-- Generated from research/site-topology-v0.1.json. -->',
    ]
    for record in ordered_sitemap_routes(manifest):
        url = escape(base + record["route"])
        date = record.get("lastmod")
        suffix = f"<lastmod>{date}</lastmod>" if date else ""
        lines.append(f"  <url><loc>{url}</loc>{suffix}</url>")
    lines.append("</urlset>")
    return "\n".join(lines) + "\n"


def render_short_llms(manifest: dict) -> str:
    site = manifest["site"]
    base = site["base_url"].rstrip("/")
    by_id, groups, _ = topology_maps(manifest)
    lines = [
        "<!-- Generated from research/site-topology-v0.1.json; do not hand-edit. -->",
        "# Coppalini Architecture — source-indexed public record",
        "",
        "Canonical site: " + base + "/",
        "",
    ]
    lines.extend(site["short_intro"])
    lines.extend(["", "## Scope", ""])
    lines.extend("- " + disclosure for disclosure in site["disclosures"])
    for group in manifest["groups"]:
        lines.extend(["", "## " + group["heading"], ""])
        for route_id in group["routes"]:
            record = by_id[route_id]
            lines.append(f"<!-- topology:{route_id} -->")
            lines.append(f"- [{record['title']}]({base}{record['route']}) — {record['summary']}")
    return "\n".join(lines) + "\n"


def render_full_llms(manifest: dict) -> str:
    site = manifest["site"]
    base = site["base_url"].rstrip("/")
    by_id, groups, _ = topology_maps(manifest)
    lines = [
        "<!-- Generated from research/site-topology-v0.1.json; do not hand-edit. -->",
        "# Coppalini Architecture — source-indexed public record",
        "",
        "Canonical site: " + base + "/",
        "",
    ]
    lines.extend(site["full_intro"])
    lines.extend(["", "## Scope", ""])
    lines.extend("- " + disclosure for disclosure in site["disclosures"])
    for group in manifest["groups"]:
        lines.extend(["", "## " + group["heading"]])
        for route_id in group["routes"]:
            record = by_id[route_id]
            lines.extend([
                "",
                f"<!-- topology:{route_id} -->",
                "### " + record["title"],
                "",
                "URL: " + base + record["route"],
                "",
                "Summary: " + record["detail"],
            ])
            if record.get("formal_basis"):
                lines.extend(["", "Formal basis: " + format_links(base, record["formal_basis"])])
            if record.get("source_records"):
                lines.extend(["", "Source record: " + format_links(base, record["source_records"])])
            if record.get("check"):
                lines.extend(["", "Check / record: " + format_links(base, record["check"])])
            if record.get("boundary"):
                lines.extend(["", "Boundary: " + record["boundary"]])
    return "\n".join(lines) + "\n"


def rendered_outputs(manifest: dict) -> dict[Path, str]:
    return {
        Path("sitemap.xml"): render_sitemap(manifest),
        Path("llms.txt"): render_short_llms(manifest),
        Path("llms-full.txt"): render_full_llms(manifest),
    }


def write_if_changed(path: Path, value: str) -> bool:
    if path.is_file() and path.read_text(encoding="utf-8") == value:
        return False
    path.write_text(value, encoding="utf-8")
    return True


def render_navigation(root: Path, manifest: dict) -> int:
    _, _, profiles = topology_maps(manifest)
    changed = 0
    for record in manifest["routes"]:
        if record.get("nav_profile") != "primary":
            continue
        expected = nav_html(profiles["primary"], record.get("nav_active"))
        for source in record["source_files"]:
            path = root_path(root, source, record["id"])
            text = path.read_text(encoding="utf-8")
            updated, count = PRIMARY_NAV.subn(expected, text)
            if count != 1:
                fail(record["id"] + ": cannot render exactly one primary nav in " + source)
            if updated != text:
                path.write_text(updated, encoding="utf-8")
                changed += 1
    return changed


def check_outputs(root: Path, manifest: dict) -> None:
    for relative, expected in rendered_outputs(manifest).items():
        actual_path = root / relative
        if not actual_path.is_file() or actual_path.read_text(encoding="utf-8") != expected:
            fail(relative.as_posix() + " differs from the topology renderer output")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="site root; defaults to this repository")
    parser.add_argument("--write", action="store_true", help="write sitemap and LLM discovery outputs")
    parser.add_argument("--check", action="store_true", help="check rendered outputs against the files on disk")
    parser.add_argument("--render-nav", action="store_true", help="render or check primary navigation profiles")
    args = parser.parse_args()
    root = args.root.resolve()
    manifest = load_manifest(root)
    validate_manifest(root, manifest, rendered_nav=args.check and args.render_nav)
    changed = 0
    if args.write:
        for relative, value in rendered_outputs(manifest).items():
            changed += int(write_if_changed(root / relative, value))
        if args.render_nav:
            changed += render_navigation(root, manifest)
    if args.check:
        check_outputs(root, manifest)
    if not args.write and not args.check:
        print("PASS: topology manifest validates")
    else:
        print(f"PASS: topology render/check complete; {changed} file(s) changed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print("FAIL:", error)
        raise SystemExit(1)
