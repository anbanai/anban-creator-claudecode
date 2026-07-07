#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import struct
from pathlib import Path


GALLERY_ASSETS = [
    "assets/hero-command-center.png",
    "assets/hero-global-filmmaker-mode.png",
    "assets/infographic-skill-capabilities.png",
    "assets/infographic-cdn-delivery-map.png",
    "assets/infographic-reference-role-map.png",
    "assets/infographic-production-delivery.png",
    "assets/infographic-professional-qc-stack.png",
]

CORE_BITMAP_ASSETS = [
    *GALLERY_ASSETS,
    "assets/hero-cinematic.png",
    "assets/skill-os-infographic.png",
    "assets/skill-map-cinematic.png",
]


def png_dimensions(path: Path) -> tuple[int, int] | None:
    with path.open("rb") as handle:
        header = handle.read(24)
    if len(header) < 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        return None
    return struct.unpack(">II", header[16:24])


def check_png_asset(
    root: Path,
    rel: str,
    label: str,
    errors: list[str],
    *,
    min_bytes: int = 100_000,
    min_width: int = 1200,
    min_height: int = 650,
) -> None:
    path = root / rel
    if not path.exists():
        errors.append(f"missing asset: {rel}")
        return
    if path.stat().st_size < min_bytes:
        errors.append(f"{rel} appears too small for a real {label} image")
    size = png_dimensions(path)
    if size is None:
        errors.append(f"{rel} is not a valid PNG")
        return
    width, height = size
    if width < min_width or height < min_height:
        errors.append(f"{rel} is too small for skill visual display ({width}x{height})")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("repo", nargs="?", default=".")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()

    root = Path(args.repo).resolve()
    errors = []

    skill_entry = root / "SKILL.md"
    if not skill_entry.exists():
        errors.append("SKILL.md missing")
    else:
        text = skill_entry.read_text(encoding="utf-8")
        for required in [
            "Seedance 2.0 Skill OS",
            "references/examples.md",
            "delivery-qc",
            "pro-filmmaking-standards",
            "multilingual-community-examples",
        ]:
            if required not in text:
                errors.append(f"SKILL.md missing `{required}`")

    migrated_index = root / "references" / "migrated" / "index.md"
    if not migrated_index.exists():
        errors.append("missing references/migrated/index.md")
    else:
        migrated_text = migrated_index.read_text(encoding="utf-8", errors="ignore")
        if "not active guidance" not in migrated_text:
            errors.append("references/migrated/index.md must clearly mark migrated bodies as inactive guidance")

    redesign_doc = root / "docs" / "frontend-redesign.md"
    if args.strict and not redesign_doc.exists():
        errors.append("missing docs/frontend-redesign.md")
    elif redesign_doc.exists():
        doc_text = redesign_doc.read_text(encoding="utf-8").lower()
        if "text-rich infographics" not in doc_text or "infographic-cdn-delivery-map.png" not in doc_text:
            errors.append("docs/frontend-redesign.md missing text-rich gallery guidance")

    design_system = root / "references" / "frontend-design-system.md"
    if not design_system.exists():
        errors.append("missing references/frontend-design-system.md")
    else:
        ds_text = design_system.read_text(encoding="utf-8").lower()
        if "text-rich infographics" not in ds_text or "reject garbled" not in ds_text:
            errors.append("references/frontend-design-system.md missing text-rich infographic quality rules")

    assets_dir = root / "assets"
    if args.strict or assets_dir.exists():
        for rel in CORE_BITMAP_ASSETS:
            check_png_asset(root, rel, "skill visual", errors)

        for rel in ["assets/hero-dark.svg", "assets/hero-light.svg", "assets/skill-map.svg"]:
            path = root / rel
            if not path.exists():
                errors.append(f"missing asset: {rel}")
                continue
            svg = path.read_text(encoding="utf-8", errors="ignore")
            if "<svg" not in svg:
                errors.append(f"{rel} is not an SVG")
            if "<title>" not in svg or "<desc>" not in svg:
                errors.append(f"{rel} missing accessible title/desc")
            if re.search(r"<script|href=[\"\']https?://|xlink:href=[\"\']https?://", svg, re.I):
                errors.append(f"{rel} must not include scripts or external resources")
            if "linearGradient" in svg or "feGaussianBlur" in svg:
                errors.append(f"{rel} must follow the editorial standard: no gradients or blur filters")
            if "Georgia" not in svg or "ui-monospace" not in svg:
                errors.append(f"{rel} missing the editorial serif/monospace type stacks")

    if errors:
        print("Design audit errors:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Design audit passed: skill entry, migrated index, and visual assets are structured and accessible.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
